# Host the App — Vercel + GitHub

Same flow you used for the PPC CRM: push to a GitHub repo, Vercel auto-deploys on every commit, you get a live URL to share with the moms.

## What you'll need first

- Supabase set up (see `SUPABASE_SETUP.md`) and your `SUPABASE_URL` + `SUPABASE_ANON_KEY` already pasted into `summer-schedule.html`.
- A GitHub account (you already have one).
- A Vercel account connected to that GitHub (same).

## Steps

### 1. Create a new GitHub repo (~2 min)

1. Go to **https://github.com/new**.
2. Repo name: `summer-2026-schedule` (or whatever).
3. **Private** — recommended, since the family names and Supabase config are in the file. (The Supabase anon key is technically meant to be public, but private repos keep it from being indexed by random scrapers.)
4. Don't check any of the "Initialize with README/license/.gitignore" boxes — keep it empty so we can push from your computer cleanly.
5. Click **Create repository**.

### 2. Push your file to GitHub

Two options depending on how you usually work.

**Option A — GitHub Desktop (easiest if you're not in the terminal much):**
1. Open GitHub Desktop → **File → Clone repository** → pick your new repo → clone it to wherever you keep code.
2. Copy `summer-schedule.html` into that cloned folder. (You can include the other markdown files too if you want them version-controlled — they don't deploy or affect anything.)
3. In GitHub Desktop you'll see the file as a new change. Type a summary like "Initial commit" → **Commit to main** → **Push origin**.

**Option B — Terminal (if you prefer):**
```bash
cd "C:\Users\carol\OneDrive\Documents\Claude\Projects\Summer 2027"
git init
git add summer-schedule.html SUPABASE_SETUP.md HOSTING.md INVITE_GUIDE.md NOTIFICATIONS.md supabase-migration.sql
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/summer-2026-schedule.git
git push -u origin main
```

### 3. Connect to Vercel (~1 min)

1. Go to **https://vercel.com/new**.
2. Click **Import Git Repository** → find `summer-2026-schedule` → click **Import**.
3. Framework preset: should auto-detect as **Other** (it's a static HTML file, no build).
4. Root directory: leave as `.`.
5. Build & Output Settings: leave default — no build command, no output dir override.
6. Click **Deploy**.

Wait ~30 seconds. You'll get a URL like `https://summer-2026-schedule.vercel.app` (Vercel will pick the name).

> **Heads up:** Vercel deploys serve the file at `/summer-schedule.html`, not at the root. So your live URL is actually `https://summer-2026-schedule.vercel.app/summer-schedule.html`. To make it work at the root, do step 4.

### 4. (Optional but nice) Make the app load at the root URL

Add a tiny `vercel.json` to the repo so visiting the bare domain serves the schedule. From your local repo folder, create a file called `vercel.json` with this content:

```json
{
  "rewrites": [
    { "source": "/", "destination": "/summer-schedule.html" }
  ]
}
```

Commit and push. Vercel redeploys automatically. Now `https://summer-2026-schedule.vercel.app` lands directly on the app.

### 5. Tell Supabase about the URL (critical — don't skip)

Magic-link emails from Supabase need to know where to redirect users back to.

1. Supabase dashboard → **Authentication** → **URL Configuration**.
2. **Site URL**: your Vercel URL (e.g., `https://summer-2026-schedule.vercel.app`).
3. **Redirect URLs**: add the same URL. Also add `http://localhost:*` if you ever want to test locally.
4. Save.

If you skip this, sign-in links will redirect to wrong place and break.

### 6. Pick a friendly name (optional)

The auto-generated `summer-2026-schedule-abc123.vercel.app` is ugly. In Vercel: project → **Settings → Domains**. Add a custom name like `summer-2026.vercel.app` (if available) or attach your own domain (e.g., `summer.planpivotcollective.com`) for free.

If you change the URL, update the Supabase Site URL and Redirect URLs to match.

### 7. Share with the moms

Send each parent the Vercel URL. They open it, type their email, click the magic link in their inbox, pick which family they are, done. (See `INVITE_GUIDE.md` for the message to send them.)

---

## Updating the app later

This is the killer reason to use Vercel + GitHub over Netlify Drop. To ship a change:

1. Edit `summer-schedule.html` (or the other files).
2. Commit and push.
3. Vercel auto-deploys within ~30 seconds.

No drag-drop, no manual step. Every push to `main` is live.

GitHub gives you full version history if you need to roll back — Vercel also keeps every previous deploy and lets you instantly switch back from the dashboard.

## Privacy

Anyone with the URL sees the sign-in screen, but only invited parents (added in Supabase Auth) can actually sign in. So you can share the URL freely — anyone snooping just hits a sign-in wall.

The GitHub repo being private means strangers can't grep it for the Supabase anon key (which is technically public-safe, but no need to volunteer it).

## Troubleshooting

**Push to GitHub fails with auth error.** Set up a personal access token in GitHub Settings → Developer settings → Personal access tokens, or use GitHub Desktop which handles it for you.

**Vercel deploy succeeds but the page shows a 404.** Make sure `summer-schedule.html` is in the repo root, not in a subfolder. If you use the `vercel.json` rewrite from step 4, the bare URL serves the schedule.

**Magic links go to the wrong page.** Re-check Supabase → Auth → URL Configuration. The Site URL needs to *exactly* match what's in the browser (no trailing slash differences, http vs https, etc.).

**Want a staging URL for testing changes before they go live to the moms.** Vercel does this automatically — every git branch gets its own preview URL. Push to a branch named `staging` or anything other than `main` and you'll get `summer-2026-schedule-git-staging-yourname.vercel.app` to test on. Merge to `main` when ready.
