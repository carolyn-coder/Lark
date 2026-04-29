# Daily Email Digest — Setup Walkthrough

This sends every parent an email each morning summarizing what's scheduled today, tomorrow, and which asks are still open and need help. Free, ~10 minutes to set up once.

## The approach

We'll use **Google Apps Script** — Google's free automation tool that runs in the cloud. It reads from your Supabase database via the REST API and uses Gmail to send the emails. No servers, no credit cards, no maintenance.

> **Why not text messages?** SMS requires a paid service like Twilio (~$0.01/message but still needs a credit card and a phone-number setup). For most family groups, a daily email lands on phones via Mail and feels just as timely. If email isn't enough, ask me about adding Twilio.

## Before you start

You need:
- Supabase set up (see `SUPABASE_SETUP.md`) and the migration run
- Your Supabase **Project URL** and **anon key** (same ones you pasted into the app)
- The email addresses of every parent in the group

## Steps

### 1. Open Google Apps Script

Go to **https://script.google.com** and sign in.

Click **New project** (top-left). Rename it: top-left "Untitled project" → `Summer 2026 Digest`.

### 2. Paste the script

Delete whatever's in the default `Code.gs` and paste this block. You'll customize the values at the top.

```javascript
// ============================================================
// Summer 2026 — Daily Email Digest (Supabase backend)
// ============================================================

// ---- FILL THESE IN ----
const SUPABASE_URL  = 'https://YOUR-PROJECT.supabase.co';
const SUPABASE_ANON = 'YOUR-ANON-KEY';

const RECIPIENTS = [
  'carolyn@planpivotcollective.com',
  'lillians-parent@example.com',
  'harpers-parent@example.com',
  'kats-parent@example.com'
];

const SEND_HOUR = 7;                   // 7 = 7am
const TIMEZONE  = 'America/New_York';  // change if needed

// ---- FAMILY & LOCATION LOOKUPS (must match the app) ----
const FAMILIES = {
  borntrager: { name: 'Borntrager', kid: 'Randi',   color: '#f59e0b' },
  waldo:      { name: 'Waldo',      kid: 'Lillian', color: '#10b981' },
  hanna:      { name: 'Hanna',      kid: 'Harper',  color: '#ef4444' },
  nuber:      { name: 'Nuber',      kid: 'Kat',     color: '#8b5cf6' }
};
const LOCATIONS = {
  brookside_cc:     'Brookside Country Club',
  worthington_cc:   'Worthington Hills Country Club',
  borntrager_house: 'Borntrager House',
  waldo_house:      'Waldo House',
  hanna_house:      'Hanna House',
  nuber_house:      'Nuber House',
  camp:             'Camp',
  other:            'Other'
};

// ==================== MAIN ====================
function sendDailyDigest() {
  const all = fetchEntries();
  const today = localDate(0);
  const tomorrow = localDate(1);

  const todayEntries = all.filter(e => e.date === today);
  const tomorrowEntries = all.filter(e => e.date === tomorrow);
  const openAsks = all.filter(e => e.type === 'asking' && e.date >= today && !e.finalized);

  const subject = 'Summer schedule — ' + formatNice(today);
  const html = renderDigestHTML({ today, tomorrow, todayEntries, tomorrowEntries, openAsks });

  RECIPIENTS.forEach(to => {
    MailApp.sendEmail({ to: to, subject: subject, htmlBody: html });
  });
  console.log('Sent to ' + RECIPIENTS.length + ' recipients.');
}

// ==================== HELPERS ====================
function fetchEntries() {
  // Supabase REST: GET /rest/v1/entries?select=*
  const url = SUPABASE_URL.replace(/\/$/, '') + '/rest/v1/entries?select=*';
  const resp = UrlFetchApp.fetch(url, {
    headers: {
      apikey: SUPABASE_ANON,
      Authorization: 'Bearer ' + SUPABASE_ANON
    }
  });
  return JSON.parse(resp.getContentText()) || [];
}
function localDate(offsetDays) {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return Utilities.formatDate(d, TIMEZONE, 'yyyy-MM-dd');
}
function formatNice(isoDate) {
  const d = new Date(isoDate + 'T00:00:00');
  return Utilities.formatDate(d, TIMEZONE, 'EEEE, MMM d');
}
function fmtTime(t) {
  if (!t) return '';
  const p = t.split(':').map(Number);
  const suf = p[0] >= 12 ? 'pm' : 'am';
  const h = ((p[0] + 11) % 12) + 1;
  return p[1] === 0 ? h + suf : h + ':' + String(p[1]).padStart(2,'0') + suf;
}
function fmtTimeRange(s, e) {
  if (!s && !e) return 'all day';
  if (s) s = s.slice(0,5);
  if (e) e = e.slice(0,5);
  if (s && e) return fmtTime(s) + '–' + fmtTime(e);
  if (s)      return 'from ' + fmtTime(s);
  return 'until ' + fmtTime(e);
}
function renderEntry(e) {
  const fam = FAMILIES[e.family_id] || { name: '?', kid: '?', color: '#999' };
  const who = fam.kid || fam.name;
  const loc = LOCATIONS[e.location] || '';
  const time = fmtTimeRange(e.start_time, e.end_time);
  const lock = e.finalized ? ' 🔒' : '';
  const responses = e.responses ? Object.values(e.responses) : [];
  const respText = responses.length ? ' · ✓ ' +
    responses.map(r => (FAMILIES[r.familyId]?.kid || FAMILIES[r.familyId]?.name || '?')).join(', ') : '';
  let line = '';
  if (e.type === 'hosting')      line = '🤝 <b style="color:' + fam.color + '">' + who + '</b> can help/host' + (loc ? ' at ' + loc : '') + ' · ' + time;
  else if (e.type === 'asking')  line = '🙏 <b style="color:' + fam.color + '">' + who + '</b> needs help' + (loc ? ' at ' + loc : '') + ' · ' + time;
  else if (e.type === 'going')   line = '🏊 <b style="color:' + fam.color + '">' + who + '</b> → ' + loc + ' · ' + time;
  else if (e.type === 'busy')    line = '🚫 <b style="color:' + fam.color + '">' + who + '</b> busy · ' + time;
  if (e.notes) line += ' — <i>' + e.notes + '</i>';
  return line + respText + lock;
}
function renderDigestHTML(ctx) {
  const section = (title, items) =>
    '<h2 style="color:#9333ea;margin-top:22px;font-size:17px;font-weight:500;">' + title + '</h2>' +
    (items.length
      ? '<ul style="padding-left:18px;line-height:1.7;">' + items.map(e => '<li>' + renderEntry(e) + '</li>').join('') + '</ul>'
      : '<p style="color:#6b5b8a;margin:4px 0 0 4px;">Nothing scheduled.</p>');
  return '<div style="font-family:-apple-system,Segoe UI,sans-serif;color:#2d1b4e;max-width:600px;">' +
    '<h1 style="color:#9333ea;font-size:22px;font-weight:500;">🏖️ Summer 2026 — Daily Digest</h1>' +
    section('Today · ' + formatNice(ctx.today), ctx.todayEntries) +
    section('Tomorrow · ' + formatNice(ctx.tomorrow), ctx.tomorrowEntries) +
    (ctx.openAsks.length ? section('🙏 Open asks (still need help)', ctx.openAsks) : '') +
    '<p style="margin-top:28px;color:#6b5b8a;font-size:12px;">Sent from your shared family schedule. Open the app to respond or make changes.</p>' +
    '</div>';
}

// ==================== SETUP — run this ONCE ====================
function installDailyTrigger() {
  ScriptApp.getProjectTriggers().forEach(function(t) {
    if (t.getHandlerFunction() === 'sendDailyDigest') ScriptApp.deleteTrigger(t);
  });
  ScriptApp.newTrigger('sendDailyDigest')
    .timeBased()
    .atHour(SEND_HOUR)
    .everyDays(1)
    .inTimezone(TIMEZONE)
    .create();
  console.log('Daily trigger installed for ~' + SEND_HOUR + ':00 ' + TIMEZONE);
}
```

### 3. Customize the values at the top

- `SUPABASE_URL` and `SUPABASE_ANON` — same values as in your `summer-schedule.html`
- `RECIPIENTS` — array of email addresses, one per parent
- `SEND_HOUR` — 24h format (7 = 7am, 17 = 5pm)
- `TIMEZONE` — change if you're not Eastern. Common: `America/Chicago`, `America/Denver`, `America/Los_Angeles`, `America/Phoenix`

### 4. Save and test once manually

1. **Ctrl+S** (Cmd+S on Mac) to save.
2. Function dropdown at the top → pick **`sendDailyDigest`**.
3. Click **Run**.
4. First time: Google asks for permissions. Click **Review permissions** → sign in → **Advanced** → **Go to Summer 2026 Digest (unsafe)** → **Allow**. (This is Google warning you about your own code — normal.)
5. Check your inbox. The digest should be there.

### 5. Install the daily trigger

1. Function dropdown → **`installDailyTrigger`** → **Run**.
2. Done — every morning at the hour you set, all parents get the digest.

To verify: click the **Triggers** icon in the left sidebar. You should see one trigger pointing at `sendDailyDigest`.

## Changing things later

- **Add or remove a parent**: edit `RECIPIENTS`, save.
- **Change the send time**: edit `SEND_HOUR`, save, run `installDailyTrigger` again.
- **Pause emails**: open Triggers (sidebar) → delete the trigger. Run `installDailyTrigger` again to resume.
- **Add a fifth family**: keep `FAMILIES` and `LOCATIONS` here in sync with the HTML app.

## If something breaks

- **"UrlFetchApp isn't authorized"** — rerun once; Google should prompt for permissions.
- **"401 Unauthorized" or empty list** — check `SUPABASE_URL` and `SUPABASE_ANON` are correct, no extra spaces, no trailing slash on the URL.
- **"Nothing scheduled" when there are entries** — check `TIMEZONE`. The script computes "today" in that zone; a mismatch makes dates not line up.
- **Emails land in spam** — first few might. Have each parent mark one as "not spam" and it'll calm down.

## Why this works without a logged-in user

The Supabase RLS policies for `entries` and `messages` require an authenticated user. *But* this script uses the anon key, which doesn't authenticate. So why does it work? It actually doesn't — by default the anon key can't read these tables.

To make the Apps Script work, you have two options:

**Option A (simpler, slightly less secure):** Add a public-read policy to `entries` so the script can fetch without authentication. In Supabase SQL Editor, run:

```sql
CREATE POLICY "anon_read_entries" ON entries FOR SELECT TO anon USING (true);
```

This lets anyone with your anon key (which is in the HTML, so essentially public anyway) read entries. Writes still require auth. This is what most small projects do.

**Option B (more secure, more setup):** Create a Supabase Edge Function with a service role key that the Apps Script calls. Worth it if you ever expose the database to a wider audience. Tell me if you want to go this route.

For your group of 4 families, Option A is fine. Run that SQL once, then the Apps Script will work as written.
