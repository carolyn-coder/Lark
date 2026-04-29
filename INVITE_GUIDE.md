# Inviting the Other Moms — 60 Seconds Per Person

Public sign-ups are off, so the only way to get into the app is to be added by you (the project owner) in the Supabase dashboard.

## To invite a parent

1. Go to **https://supabase.com/dashboard** and open your `summer-2026-schedule` project.
2. Sidebar → **Authentication** → **Users**.
3. Click **Add user** (top right) → **Send invitation**.
4. Type their email → click **Send invitation**.
5. They'll get an email from Supabase with a "Confirm your mail" link. They click it → they're in. Send them the app's URL (whatever Netlify gave you in `HOSTING.md`).
6. First time they open the app, they'll be asked to sign in (enter their email → click magic link in their inbox), then to pick which family they are. Done.

That's it. No password to share, no shared Firebase config, no per-family setup.

## Who you'll invite

Based on what you've told me:

- **Borntrager / Randi** — you (carolyn@planpivotcollective.com)
- **Waldo / Lillian** — Lillian's parent's email
- **Hanna / Harper** — Harper's parent's email
- **Nuber / Kat** — Kat's parent's email

If a parent has multiple emails (work + personal), use the one they actually check on their phone. The magic-link emails go there.

## What they need to do

Send each parent a short note. Sample:

> Hi [name]! I built a little summer schedule app for our crew so we can coordinate pool days, who's hosting, and who needs help with the girls. Open this link: **[your Netlify URL]**, sign in with the email I just invited (you'll get a confirmation from Supabase), and pick which family you are. We can post offers (I can host Friday 9–4!) and asks (Need someone to watch Randi while I'm in meetings July 7) and chat in there.

## Removing someone

1. Auth → Users in the dashboard.
2. Find their row → click the three-dot menu → **Delete user**.

Their old entries and messages stay (so the history isn't broken), but they can't sign in anymore.

## Adding a fifth or sixth family later

If your group grows, two things to update:

1. **Add the user in Supabase** — same steps above.
2. **Add the family to the app** — open `summer-schedule.html` in a text editor, find the `FAMILIES` array near the top, and add a new entry like:

   ```js
   { id: 'lastname', name: 'Lastname', kid: 'Kidname', color: '#0ea5e9' }
   ```

   Save the file, re-upload to Netlify (drag onto your dashboard's deploys page), and the new family appears in the welcome picker. Pick a color that's not already used (the existing palette is amber, emerald, red, purple).

If you add a new shared location (a new country club, a new family's house), update the `LOCATIONS` array the same way.

## Common issues

**The magic-link email never arrives.** Check spam. Also check that you typed the email correctly in the Add user step — Supabase doesn't validate it.

**They click the link but get bounced back to the sign-in screen.** Their email's auto-link-preview probably "consumed" the one-time code before they got to it. Have them enter their email again on the sign-in screen — Supabase will send a fresh link.

**"This site can't be reached" when they click the link.** The redirect URL needs to match where the app is hosted. In Supabase dashboard → Authentication → URL Configuration, make sure the **Site URL** matches your Netlify URL. Add the Netlify URL to the **Redirect URLs** list too.

**A parent wants to use their own browser bookmark instead of the magic link every time.** Once signed in, the session persists for ~1 week by default. They only need to do the magic link about once a week. If you want longer sessions, that's tunable in Auth settings (JWT expiry).
