-- ============================================================
--  RPSAI · Supabase backend schema
--  Usage: Supabase dashboard -> SQL Editor -> paste all -> Run
-- ============================================================

-- 1) player profiles (with country, for national ranking)
create table if not exists public.profiles (
  id           uuid primary key references auth.users on delete cascade,
  display_name text,
  avatar       text default '🦊',
  country      text default 'XX',
  sol_address  text,
  wins         int  default 0,
  losses       int  default 0,
  ties         int  default 0,
  updated_at   timestamptz default now()
);
alter table public.profiles add column if not exists country text default 'XX';
alter table public.profiles add column if not exists sol_address text;
alter table public.profiles add column if not exists name_locked boolean default false;
alter table public.profiles add column if not exists wallet_locked boolean default false;

alter table public.profiles enable row level security;
drop policy if exists "read all"   on public.profiles;
drop policy if exists "update own" on public.profiles;
drop policy if exists "insert own" on public.profiles;
create policy "read all"   on public.profiles for select using (true);
create policy "update own" on public.profiles for update using (auth.uid() = id);
create policy "insert own" on public.profiles for insert with check (auth.uid() = id);

-- 2) auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users for each row execute function public.handle_new_user();

-- 3) record a round result (+1 only; clients can't set totals)
create or replace function public.record_result(outcome text)
returns void language plpgsql security definer set search_path = public as $$
begin
  update public.profiles set
    wins   = wins   + case when outcome = 'win'  then 1 else 0 end,
    losses = losses + case when outcome = 'lose' then 1 else 0 end,
    ties   = ties   + case when outcome = 'tie'  then 1 else 0 end,
    updated_at = now()
  where id = auth.uid();
end; $$;

-- 4) update name / avatar (username set-once: locked after name_locked)
create or replace function public.update_profile(new_name text, new_avatar text)
returns void language plpgsql security definer set search_path = public as $$
begin
  update public.profiles set
    display_name = case when name_locked then display_name
                        else coalesce(nullif(new_name,''), display_name) end,
    name_locked  = name_locked or (nullif(new_name,'') is not null),
    avatar       = coalesce(nullif(new_avatar,''), avatar),
    updated_at   = now()
  where id = auth.uid();
end; $$;

create or replace function public.set_country(c text)
returns void language plpgsql security definer set search_path = public as $$
begin
  update public.profiles set country = c where id = auth.uid();
end; $$;

-- bind SOL wallet address (set-once before airdrop: locked after wallet_locked)
create or replace function public.set_wallet(addr text)
returns void language plpgsql security definer set search_path = public as $$
begin
  update public.profiles set
    sol_address   = case when wallet_locked then sol_address else nullif(addr,'') end,
    wallet_locked = wallet_locked or (nullif(addr,'') is not null),
    updated_at    = now()
  where id = auth.uid();
end; $$;

-- 5) scoring base: Wilson 95% lower bound (z=1.96, z^2=3.8416)
create or replace view public.lb_base as
with b as (
  select id, display_name, avatar, country, wins, losses, ties,
         (wins + losses) as decisive, (wins + losses + ties) as games
  from public.profiles
)
select
  id, display_name, avatar, country, wins, losses, ties, decisive, games,
  case when decisive = 0 then 0 else round(wins::numeric / decisive * 100, 1) end as win_rate,
  case when decisive = 0 then 0 else
    (
      (wins::numeric/decisive) + 1.9208/decisive
      - 1.96 * sqrt( ((wins::numeric/decisive)*(1-(wins::numeric/decisive)) + 0.9604/decisive) / decisive )
    ) / (1 + 3.8416/decisive)
  end as score
from b;

-- 6) global leaderboard (overall) + national (partitioned by country)
create or replace view public.leaderboard as
  select *, rank() over (order by score desc, decisive desc) as rank from public.lb_base;

create or replace view public.leaderboard_national as
  select *, rank() over (partition by country order by score desc, decisive desc) as rank from public.lb_base;

grant select on public.lb_base, public.leaderboard, public.leaderboard_national to anon, authenticated;

-- done
