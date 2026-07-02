# 登录 + 全球排行榜 · 5 分钟接入 Supabase

游戏**不配也能跑**：没填密钥时自动进入「本地 Demo 模式」（昵称登录 + 假排行榜），方便先看 UI。
下面几步接上真实的全球排名。

## 1. 建项目
1. 打开 https://supabase.com → 用 GitHub/邮箱登录 → **New project**
2. 记下项目的 **Project URL** 和 **anon public key**
   （控制台左下 ⚙️ → **API** → `Project URL` 和 `anon` `public`）

## 2. 建表
控制台左侧 **SQL Editor** → New query → 把本仓库的 [`schema.sql`](schema.sql) 全部粘进去 → **Run**。
看到 “Success” 即可（建了 profiles 表、排行榜视图、记录函数）。

## 3. 开登录方式
控制台 **Authentication → Providers**：
- **Email**：默认开启（用邮箱魔法链接登录，免密码）✅
- **Google**（可选，即"用 Gmail 登录"）：打开 Google，填入 Google Cloud 的 OAuth Client ID / Secret
  （建 OAuth 凭据时，把 Supabase 给的回调地址 `https://<你的项目>.supabase.co/auth/v1/callback` 填进 Google 授权重定向 URI）

**Authentication → URL Configuration**：把 `Site URL` 和 `Redirect URLs` 加上你的游戏地址
（本地测试就是那个 `https://xxx.trycloudflare.com`，正式部署后换成你的域名）。

## 4. 填密钥
打开 [`index.html`](index.html)，找到顶部这两行，填进去：
```js
const SUPABASE_URL  = "https://你的项目.supabase.co";
const SUPABASE_ANON = "你的 anon public key";
```
保存 → 刷新页面。登录按钮和 🏆 排行榜就是真数据了。

## 排名怎么算？
胜率 = 胜 /（胜+负），用 **Wilson 95% 置信下限**综合"局数 + 胜率"排序：
局数太少即使全胜也排不到前面，防止刷榜。公式在 `schema.sql` 的 `lb_base` 视图里。
- **全球榜** = `leaderboard` 视图（全体排名）
- **本国榜** = `leaderboard_national` 视图（按 `country` 分区排名）
- 排行榜显示 **Top 100 + 我的排名**（不在前 100 也会在顶部横幅显示"第 N 名 / 击败 Z%"）

**国家怎么来的？** 前端登录后自动用 IP（ipapi.co）判定国家码写入 `country`，失败则回退到系统区域设置。无需用户手动选。

## 关于防作弊（先了解）
记分走 `record_result()` 函数，客户端**只能给自己 +1**，不能直接改总数——已挡住最粗暴的作弊。
但真正的防刷（防止有人脚本狂调 +1）需要"服务端裁判"，属于后续工程，meme 原型阶段够用了。
