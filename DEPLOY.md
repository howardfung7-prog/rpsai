# 上线到 rpsai.io

整个站点是**纯静态**（一个 `index.html` + 图标 + manifest），任何静态托管都能跑。推荐 **Cloudflare Pages**（免费、自带 HTTPS、绑定自有域名最省事）。

## 需要上传的文件
```
index.html      主程序
manifest.json   PWA（可安装到手机桌面）
icon-192.png    应用图标
icon-512.png    应用图标
og.png          社交分享预览图（1200×630）
```
（`schema.sql` / `SETUP.md` / `DEPLOY.md` 是文档，不用部署。）

## 方案 A：Cloudflare Pages（推荐）
1. https://dash.cloudflare.com → **Workers & Pages** → **Create** → **Pages** → **Upload assets**
2. 把上面 5 个文件拖进去 → Deploy，先拿到一个 `*.pages.dev` 临时地址，测通。
3. 该项目 → **Custom domains** → 添加 `rpsai.io`（和 `www.rpsai.io`）。
   - 如果域名 DNS 已在 Cloudflare：一键生效。
   - 如果在别处（注册商）：按提示把 DNS 指过来，或加它给的 CNAME/A 记录。
4. 等 HTTPS 证书签发（通常几分钟），打开 https://rpsai.io 。

## 方案 B：Vercel / Netlify
- Vercel：`npx vercel` 在本目录部署，或网页版拖拽；Project → Domains 添加 `rpsai.io`。
- Netlify：把目录拖到 https://app.netlify.com/drop ，再在 Domain settings 绑定 `rpsai.io`。

## 上线后必做：更新 Supabase 回调
（接了真登录才需要，见 [SETUP.md](SETUP.md)）
Supabase → **Authentication → URL Configuration**：
- **Site URL** = `https://rpsai.io`
- **Redirect URLs** 加上 `https://rpsai.io/**`
- 若开了 Google 登录：Google Cloud 的授权重定向 URI 保持 `https://<项目>.supabase.co/auth/v1/callback` 不变。

## 验证社交预览
发到微信/X 前，先用调试器刷新缓存：
- X/Twitter：https://cards-dev.twitter.com/validator
- Facebook：https://developers.facebook.com/tools/debug/ → 输入 `https://rpsai.io` → Scrape Again
- 应显示 `og.png`（✊✌️🖐️ RPS 3000 · rpsai.io）

## 备注
- 摄像头需要 HTTPS——上述托管都自带，✅。
- 改动只需重新上传 `index.html` 即可，其它文件基本不变。
- 想要"添加到主屏幕"变成真 App 图标：手机浏览器打开 → 分享 → 添加到主屏幕（靠 manifest + icon 生效）。
