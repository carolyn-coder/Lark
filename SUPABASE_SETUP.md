# Supabase Setup — 5-Minute Walkthrough

This is the same pattern you used for the PPC CRM, just a separate Supabase project for this app so the moms aren't given access to your client work.

## Why a separate project

Supabase auth is project-level. If you reused your PPC CRM project, anyone you invited to summer-schedule could also sign into your CRM. Cleaner to keep them separate. New projects are free, and you can have many on the free tier.

## Steps

### 1. Create a new Supabase project (2 min)

1. Go to **https://supabase.com/dashboard** and sign in.
2. Click **New project**.
3. Org: pick whichever org your PPC CRM is in (or create a personal one).
4. Name: `summer-2026-schedule` (or whatever you like).
5. Generate a strong database password. **Save it somewhere** — you won't usually need it, but you'll regret losing it if you ever do.
6. Region: pick the one closest to your group (e.g., `East US (N. Virginia)`).
7. Plan: **Free**. Click **Create new project**. Wait ~1 minute while it provisions.

### 2. Run the migration (1 min)

1. In the Supabase sidebar click **SQL Editor**.
2. Click **New query**.
3. Open `supabase-migration.sql` (in this folder) in any text editor, copy the **entire** contents, paste into the SQL Editor.
4. Click **Run** (bottom right). You should see "Success. No rows returned." — that's correct, the migration creates empty tables.

### 3. Lock down sign-ups (1 min)

By default Supabase lets anyone sign up with their email. We want only invited parents.

1. Sidebar → **Authentication** → **Sign In / Up** (or **Providers** → **Email**).
2. Find **Allow new users to sign up** and toggle it **OFF**.
3. Save.

Now only users you explicitly add (next file: `INVITE_GUIDE.md`) can sign in.

### 4. Get your project URL and anon key (30 sec)

1. Sidebar → **Project Settings** (gear icon, bottom left) → **API**.
2. Copy the **Project URL** (looks like `https://abcdefghij.supabase.co`).
3. Copy the **anon / public** key (a long JWT string starting with `eyJ...`).

### 5. Paste into the app (30 sec)

1. Open `summer-schedule.html` in a text editor (Notepad / TextEdit / VS Code — whatever).
2. Near the top of the `<script type="module">` section, find:

   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-KEY";
   ```

3. Replace each placeholder with the value you just copied. Keep the quotes.
4. Save.

### 6. Test it

Double-click `summer-schedule.html`. You should see the **Sign in** screen with the lilac background.

Enter your email → click **Send sign-in link**. (The first time only, you'll need to invite yourself — see **INVITE_GUIDE.md** step 1.)

After clicking the magic link in your inbox, you'll land back on the app already signed in. Pick which family you are on the welcome screen and you're set.

### 7. Host it & invite the moms

- Hosting: **HOSTING.md** walks through Netlify Drop. Same flow as PPC CRM.
- Inviting parents: **INVITE_GUIDE.md** explains how to add Randi's, Lillian's, Harper's, and Kat's parents to the auth allow-list.

---

## Realtime sync — already on

The migration script enables Supabase Realtime for the `entries` and `messages` tables. When one parent posts, every signed-in browser updates within ~1 second. No setup needed.

## Costs

Free tier covers:
- Up to 500 MB of database (you'll use single-digit MB)
- 2 GB of egress per month (way more than this group will hit)
- Up to 50,000 monthly active users (you'll have ~6)

You won't pay anything for this app.

## If you ever want to nuke and start over

Re-run the migration SQL. It drops and recreates the tables. Auth users are preserved.
