# BookTruf — Product Requirements & UI Specification
**Version:** 1.0 — Draft  
**Platforms in scope:** iOS app · Android app · Owner web dashboard · Staff web view · Public marketing site · Shareable booking web page

---

## Table of Contents
1. [Platform Overview](#1-platform-overview)
2. [User Roles & Permissions](#2-user-roles--permissions)
3. [Feature List](#3-feature-list)
4. [Customer App — Full Flow](#4-customer-app--full-flow)
5. [Owner Web Dashboard — Full Flow](#5-owner-web-dashboard--full-flow)
6. [Staff Web View — Full Flow](#6-staff-web-view--full-flow)
7. [Public Marketing & Landing Page](#7-public-marketing--landing-page)
8. [Shareable Booking Web Page](#8-shareable-booking-web-page)
9. [QR Code Flow](#9-qr-code-flow)
10. [Notifications & Reminders](#10-notifications--reminders)
11. [Audit Logs](#11-audit-logs)
12. [Data & Backend Notes](#12-data--backend-notes)
13. [Open Questions & Future Scope](#13-open-questions--future-scope)

---

## 1. Platform Overview

BookTruf is a sports court discovery and booking platform. Customers use a mobile app to find and book courts across cities. Venue owners manage their listings, courts, pricing, and staff via a web dashboard. Staff members handle day-to-day booking operations. The platform acts as a discovery and scheduling layer — payments happen directly between customer and venue.

### Core Philosophy
- **Customer UX must be delightful and fast.** Every empty state, error, and wait moment should feel fun and human, never clinical.
- **Owner onboarding must be frictionless.** An owner should be able to go live within 15 minutes.
- **Mobile-first for customers, web-first for owners.**

---

## 2. User Roles & Permissions

| Capability | Customer | Staff Member | Owner |
|---|---|---|---|
| Search & browse courts | ✅ | — | — |
| Create booking | ✅ | ✅ | — |
| View bookings | Own only | All venue bookings | All venue bookings |
| Confirm booking | — | ✅ | ✅ |
| Cancel booking | Own only | ✅ | ✅ |
| Leave a review | ✅ (post-booking) | — | — |
| Reply to review | — | — | ✅ |
| Manage venue details | — | — | ✅ |
| Manage courts | — | — | ✅ |
| Manage operating hours | — | — | ✅ |
| Add/remove staff | — | — | ✅ |
| View reports | — | — | ✅ |
| View audit logs | — | — | ✅ |

### Role Notes
- A customer account and a staff member account are separate. Staff members are regular users who have been linked to a venue.
- An owner can currently manage only one venue (v1 constraint).
- Staff members have no sub-roles or granular permissions in v1 — any staff member can perform any booking action.
- All booking mutations by staff are recorded in audit logs.

---

## 3. Feature List

### Customer Features
- City/town selection with memory (first launch only)
- Sport discovery by city — filtered, sorted by distance, rating, or price
- Court browsing with slot availability (default: today)
- Slot booking with instant or owner-approval flow (per venue setting)
- Booking cancellation (self-service, any time before the slot)
- Post-booking review: star rating (1–5) + written review + photos
- Upcoming bookings pinned to top of home screen
- Sport/court recommendations based on past bookings
- Shareable booking link (deep link → web → app install prompt)
- Booking saved automatically when app installed via shared link
- Push notifications: day-of-booking morning reminder + 30 min before
- QR code scan → court web page → app install prompt

### Owner Features
- Owner-specific signup flow (separate from customer signup)
- Email verification + Google OAuth
- Guided onboarding (4 steps): venue info → operating hours → courts → (optional) staff
- Venue management: name, address, images
- Operating hours per day of week, including closed days and ad-hoc closures
- Court management: sport type, court name, slot duration, flexible pricing rules, images
- Booking approval mode: instant confirm or manual approval per venue
- Ad-hoc court closures (block out specific time windows)
- Staff management: invite by email, track invite status
- Reports: revenue per court/period, occupancy rate, total bookings, peak hours heatmap, cancellation rate, staff activity / audit log export
- Reply to customer reviews

### Staff Features
- View all upcoming and past bookings for the venue
- Create manual bookings (walk-in customers)
- Confirm pending bookings
- Cancel bookings
- All actions logged in audit trail

### Platform / Web Features
- Public marketing landing page with customer + owner sections
- Customer signup link + owner signup link (separate entry points)
- Shareable booking web page (booking details, fun design, app install prompt)
- QR code web landing page (court details + app install prompt)
- Court QR code generation (per court, encodes city + town + court ID)

---

## 4. Customer App — Full Flow

---

### 4.1 First Launch — Location & City Selection

**Trigger:** First time the app is opened, or if no city is stored.

**Screen: Welcome / City Picker**
- Full-screen illustration of a city skyline with a sports theme (court nets, balls in the background). Bright, fun, playful palette.
- Headline: *"Where are you playing today?"*
- Two options presented as large tappable cards:
  - **"Use my location"** — detects city automatically via GPS. Shows a small animated pin dropping onto a city silhouette while detecting.
  - **"Pick a city"** — opens a searchable dropdown/sheet with a list of available cities. Each city shows the count of sports available (e.g. "Lahore · 6 sports").
- After city is selected, a fun confirmation micro-animation plays (e.g. a ball bouncing into the city name).
- City preference is saved locally (and to user profile if logged in). Never asked again unless user changes it manually from settings.
- Below the options: small text link *"Not in Pakistan? We're expanding — stay tuned 🌍"*

---

### 4.2 Home Screen — No Bookings State

**Trigger:** User has no past or upcoming bookings.

**Screen: Home**

**Header area:**
- Greeting with first name if logged in: *"Hey Ali, pick your sport 🎾"*
- City name shown with a small map pin icon. Tappable to change city/town.
- Town filter chip row (scrollable horizontally) below the city — shows towns/areas within the city. Default: "All areas". Selecting a town filters courts to that area.

**Sport grid:**
- All sports available in the selected city displayed as a grid of large illustrated sport cards (2 columns).
- Each card shows: sport illustration (fun, bold icon style), sport name, number of courts available today.
- If a sport has zero slots today, the card is slightly dimmed with a label: *"Check other dates"* instead of a slot count.

**Empty state (no sports in city yet):**
- Illustration of a sleepy sports ball.
- Message: *"Looks like [City] is still warming up! We're adding courts every week — check back soon 🏗️"*

---

### 4.3 Home Screen — Returning User State

**Trigger:** User has at least one past booking.

**Screen: Home (personalised)**

**Section 1 — Upcoming bookings (if any):**
- Shown as a horizontal scroll strip at the very top.
- Each card shows: sport icon, court name, date & time, status badge (Confirmed / Pending / Cancelled).
- Tapping opens booking detail screen.
- If no upcoming bookings: section is hidden entirely.

**Section 2 — Your sports (personalised):**
- Sports the user has previously booked are shown first in the grid, with a subtle *"Your go-to"* label.
- Remaining sports follow below.

**Section 3 — Discover:**
- Sports the user has never tried, with a label: *"Try something new?"*

---

### 4.4 Sport → Court Listing Screen

**Trigger:** User taps a sport card.

**Screen: Courts for [Sport] in [City]**

**Top bar:**
- Back arrow + sport name + city name.
- Filter/sort bar: chips for **Nearest**, **Top rated**, **Lowest price**.
- Town filter (same as home screen) accessible here too.
- Default sort: **Nearest** (requires location permission — if denied, default to Top rated with a soft nudge banner: *"Allow location for nearest-first results"*).
- Date selector: defaults to today. Horizontal scroll strip of upcoming 7 days. Each day chip shows count of available slots (e.g. "Today · 4 slots", "Thu · 0 slots").

**Court cards (list view):**
Each card contains:
- Court photo (thumbnail)
- Venue name + court name
- Sport type badge
- Distance from user (if location available)
- Star rating + review count
- Price: lowest slot price shown (e.g. "From Rs. 800/slot")
- Availability indicator: green dot if slots today, grey if not
- Town/area label

**No slots for today (fun empty state):**
- Animated illustration (e.g. a clock spinning, a court with cobwebs — light humour).
- Message options (randomised): 
  - *"This court is having a spa day 🧖 — try tomorrow?"*
  - *"No slots today — but [next available date] is wide open! Want to check it?"*
- CTA button: *"See next available date"* — auto-scrolls to the next date with availability in the date strip.

---

### 4.5 Court Detail Screen

**Trigger:** User taps a court card.

**Screen: Court Detail**

**Hero section:**
- Photo carousel (swipeable). Full-width, rounded bottom corners.
- Venue name (large) + court name below it.
- Town · Distance · Rating row.

**Info tabs (horizontal scrollable tabs below hero):**
- **Slots** (default tab)
- **About**
- **Reviews**

**Slots tab:**
- Date selector strip (same as listing screen, synced to the selected date).
- Available time slots displayed as a grid of pill buttons.
  - Available: solid accent colour.
  - Booked/unavailable: greyed out, not tappable.
  - Selected: highlighted with a checkmark.
- Slot shows time + price (e.g. "10:00 AM · Rs. 1,200").
- Selecting a slot reveals a sticky bottom sheet: *"Book this slot"* CTA + slot summary.

**About tab:**
- Venue address with map thumbnail (tappable, opens maps app).
- Operating hours for each day of week.
- Amenities/features listed (if owner provided).
- Owner/venue profile mini card.

**Reviews tab:**
- Average star rating (large, prominent).
- Total review count.
- Review cards: reviewer name + avatar initial, stars, date, written review, photos (if any).
- Owner reply shown nested below any review that has one, labelled *"Owner replied:"*.
- Load more button if more than 5 reviews.

---

### 4.6 Booking Confirmation Flow

**Trigger:** User taps "Book this slot" on a selected slot.

**Step 1 — Login gate (if not logged in):**
- Bottom sheet: *"Almost there! Sign in to lock in your slot 🔒"*
- Options: **Continue with Google**, **Continue with Apple**, **Sign in with email**.
- After auth, returns to booking flow automatically.

**Step 2 — Booking Summary Screen:**
- Court name, date, time, duration, price (clearly labelled as "Pay at venue").
- Cancellation policy: *"You can cancel anytime before your slot for free."*
- Note for venues with manual approval: *"This venue reviews bookings — you'll get a confirmation notification shortly."*
- Big **"Confirm Booking"** button.

**Step 3a — Instant Confirmation (venue setting = instant):**
- Full-screen success animation (confetti, bouncing ball, or similar fun celebration).
- Message: *"You're booked! See you on the court 🎉"*
- Booking summary card shown below.
- Two CTAs: **"Share with friends"** and **"View my bookings"**.

**Step 3b — Pending Approval (venue setting = manual):**
- Animated pending state (e.g. a spinning hourglass with a sports theme).
- Message: *"Booking sent! The venue will confirm shortly. We'll notify you 🔔"*
- CTA: **"View my bookings"**.

---

### 4.7 My Bookings Screen

**Sections:**
- **Upcoming** (tab): sorted chronologically. Each booking card shows sport icon, court name, date/time, status badge, and a **Share** button.
- **Past** (tab): past bookings. Each shows a **Leave a Review** button if no review submitted yet.
- **Cancelled** (tab): cancelled bookings with cancellation timestamp.

**Booking Detail Screen (tapping any booking):**
- Full booking details: venue, court, date, time, price paid note.
- Status with clear visual badge.
- Court location with map link.
- **Cancel Booking** button (shown only for upcoming, confirmed bookings — with a playful confirm dialog: *"Sure you want to cancel? The court will miss you 🥺"* with **"Yes, cancel"** and **"Actually, I'll go"** options).
- **Share** button.
- **Review** button (past bookings only, if review not submitted).

---

### 4.8 Review Submission Screen

**Trigger:** User taps "Leave a Review" on a past booking.

**Screen: Review [Court Name]**
- Large star rating selector (interactive, animated stars that fill on tap).
- Text area: *"Tell others what you thought... (optional)"* — placeholder changes each time (fun rotating prompts: *"Was the net up? Were the lights bright? Spill it all."*).
- Photo upload: row of + tiles. Max 5 photos. Tapping opens camera or gallery.
- **Submit Review** button.
- After submit: fun animation + message: *"Review posted! You're officially a court critic 🌟"*

---

### 4.9 Share Booking Flow

**Trigger:** User taps "Share" on a booking.

**Step 1 — Link Preview Screen (in-app):**
- Before sharing, app shows a fun preview card of how the shared page will look:
  - Sport illustration + court name + date/time + a fun message like *"[Name] is hitting the court — join them!"*
  - CTA: *"Share this link"*
- Tapping Share opens the native iOS/Android share sheet with the deep link URL.

**What happens when recipient opens the link:**
- Opens the **Shareable Booking Web Page** (see Section 8).
- If the recipient installs the app via the web page and creates an account, the booking is automatically saved into their "Saved Bookings" / history — no join prompt, just silently present (friend circle lite).

---

### 4.10 Customer Signup Flow

**Trigger:** User tries to book without being logged in, or taps signup from marketing page.

**Screen: Create Account**
- Headline: *"Join the game 🏃"*
- Three options as large cards:
  - **Continue with Google** (icon + label)
  - **Continue with Apple** (icon + label)
  - **Sign up with email**
- Subtle note below: *"Already have an account? Sign in"*

**Email Signup sub-flow:**
1. Email field → password field → confirm password.
2. First name + last name.
3. Verification email sent. Screen shows: *"Check your inbox! We sent a verification link to [email] 📬"* with a **Resend email** link.
4. After verification, user is logged in and returned to the interrupted flow (e.g. booking confirmation).

**Google/Apple OAuth:**
- Standard OAuth flow. On first login, app checks if name is returned — if not, shows a one-field screen: *"What should we call you?"* (first name only, last name optional).
- No additional steps. User lands on home screen immediately.

---

### 4.11 Settings & Profile Screen

- Edit profile: name, profile photo.
- Change city/town preference.
- Notification preferences: toggle day-of reminder, toggle 30-min reminder.
- Linked accounts (Google/Apple).
- Sign out.
- Delete account (with confirmation).
- App version + links to Terms, Privacy Policy, Contact support.

---

## 5. Owner Web Dashboard — Full Flow

---

### 5.1 Owner Signup

**Entry point:** Dedicated owner signup URL from marketing page (e.g. `booktruf.com/owner/signup`).

**Screen: Owner Signup**
- Clearly labelled: *"List your venue on BookTruf"*
- Two options:
  - **Sign up with Google** (preferred, faster)
  - **Sign up with email**
- Email signup collects: first name, last name, email, password.
- After email signup: verification email sent. Dashboard locked with a banner: *"Verify your email to continue — check your inbox 📬"* with resend option.
- After Google OAuth: proceeds directly to onboarding.
- Backend records: owner ID, email, signup method, onboarding step = 0.

---

### 5.2 Owner Onboarding

Onboarding is a stepped wizard. Progress is saved after each step — owner can close and return to where they left off. The backend tracks `onboarding_step` per owner.

A persistent progress bar at the top shows: **Step 1 of 4** with step labels (Venue Info, Hours, Courts, Staff).

---

#### Step 1 — Venue Information

**Fields:**
- Venue name (required)
- Address: street, city, area/town (required). Address field has autocomplete via maps API.
- Venue images: drag-and-drop or click-to-upload. Minimum 1 image required to proceed. Max 10 images. Previewed as a thumbnail row. Reorderable.

**UI notes:**
- Large, clean card layout. One field group per card.
- Image upload area is a large dashed border box with an illustration of a camera and text: *"Show off your venue! Upload at least one photo."*
- **Save & Continue** button at the bottom.
- On save: backend stores venue record, links owner ID, marks step 1 complete.

---

#### Step 2 — Operating Hours

**Layout:**
- One row per day of the week (Monday → Sunday).
- Each row has:
  - Day label
  - Toggle: **Open / Closed**
  - If Open: time pickers for **Opening time** and **Closing time**
  - A **"Same as above"** checkbox that copies the previous day's hours (makes Mon–Fri setup fast).

**Shortcuts:**
- **"Apply weekday hours to all weekdays"** button: copies Mon's hours to Tue–Fri.
- **"Apply weekend hours to both weekend days"** button.

**Closed days:**
- Toggling a day to Closed greys out the time pickers for that row.
- A venue can be open weekends only, or have any custom combination.

**Required fields:** Opening and closing time are required for any day marked Open. System validates that closing time is after opening time.

**UI notes:**
- Clean table-style layout. Alternating row background for readability.
- Time pickers are dropdowns in 30-minute increments.
- **Save & Continue** at bottom.

---

#### Step 3 — Add Courts

This is the most complex step. It supports adding multiple courts.

**Layout:**
- Each court is a collapsible card.
- When adding the first court, the card is expanded by default.
- When owner clicks **"+ Add another court"**, the current court card collapses to a summary row (sport icon + court name) and a new expanded card appears below.

**Per court — fields:**

**Basic info section:**
- Sport type: dropdown (Cricket, Football, Badminton, Tennis, Padel, Basketball, Squash, Volleyball, etc.)
- Court name: text field. Must be unique within the same sport at this venue. Placeholder: *"e.g. Court A, Padel 1, Main Pitch"*
- Slot duration: dropdown (30 min, 45 min, 1 hr, 1.5 hr, 2 hr). This is the fixed block size customers will book.
- Court images: upload up to 8 images. Same upload UI as venue images.

**Booking mode (per court):**
- Toggle: **Instant Confirm** / **Manual Approval**
- Helper text: *"Instant: customers are confirmed immediately. Manual: you or your staff review each booking before confirming."*

**Pricing rules section:**
- Pricing is flexible — owner can define multiple rules for different time windows and days.
- Each pricing rule is a row with:
  - Days of week (multi-select chips: Mon, Tue, Wed, Thu, Fri, Sat, Sun)
  - From time → To time
  - Price per slot (in local currency)
- **"+ Add pricing rule"** link to add more rows.
- Example pricing setup: Mon–Fri 6am–5pm = Rs. 800, Mon–Fri 5pm–10pm = Rs. 1,400, Sat–Sun all day = Rs. 1,600.
- Rules are validated for time overlaps within the same days.

**Copy pricing from another court:**
- A **"Same pricing as [Court Name]"** dropdown appears once more than one court exists. Selecting it copies all pricing rules from the chosen court. Owner can then edit from that baseline.

**UI notes:**
- Collapsed court card shows: sport icon, court name, slot size, price range (auto-calculated from rules), and an Edit button.
- Validation: at least one pricing rule required per court.
- At least one court must be added to complete this step.
- **Save & Continue** at bottom (saves all courts in current state).

---

#### Step 4 — Add Staff (Optional)

**Screen:**
- Headline: *"Invite your team (optional)"*
- Subtext: *"Staff members can view, confirm, and manage bookings. You can also do this later from your dashboard."*

**Invite flow:**
- Email input field + **"Send Invite"** button.
- After sending: invite appears in a list below the input showing email + status badge (**Pending**).
- Owner can add multiple staff members.
- Invited users receive an email with a link to sign up as a regular customer account; once signed up, their account is linked to the venue with staff role and the invite status changes to **Active**.
- Owner can remove a pending or active invite from this list.

**Skip option:**
- Prominent **"Skip for now"** link below the invite area — styled friendly, not punishing.
- **"Finish & Go to Dashboard"** CTA at bottom (available whether staff were added or not).

---

### 5.3 Owner Dashboard — Home

After onboarding, owner lands on the main dashboard.

**Layout:** Sidebar navigation (left) + main content area.

**Sidebar items:**
- Overview (home)
- Bookings
- Courts
- Operating Hours
- Staff
- Reports
- Settings

**Overview page:**
- Summary stats cards: Today's bookings, This week's revenue (label: "Est. based on slot prices"), Court utilisation today.
- Upcoming bookings table (next 24 hours): court, customer name (or "Walk-in"), time, status.
- Quick actions: **"Add court closure"**, **"View pending bookings"** (if any).

---

### 5.4 Bookings Management

**Screen: All Bookings**
- Filter bar: date range picker, court selector, status filter (All / Pending / Confirmed / Cancelled).
- Bookings table: customer name, court, date, time, status, booked at timestamp, booked by (customer/staff name).
- Clicking a booking opens a detail panel (slide-in from right):
  - All booking details.
  - Status with action buttons: **Confirm** (if pending), **Cancel** (if upcoming).
  - Audit log for this booking (who created, who confirmed, who cancelled, with timestamps).

**Manual booking creation (walk-in):**
- **"+ New Booking"** button top right.
- Opens a form: court selector, date, slot time, customer name (free text for walk-ins), optional notes.
- Staff-created bookings are always instant-confirmed and flagged as "Walk-in" in the audit log.

---

### 5.5 Courts Management

**Screen: Courts**
- List of all courts as cards.
- Each card: court name, sport, slot duration, price range, booking mode badge (Instant / Manual), status (Active / Paused).
- Actions per card: **Edit**, **Add closure**, **Pause / Resume**.

**Edit Court:** Opens the same form as onboarding Step 3.

**Court closures:**
- **"Add closure"** opens a date/time range picker with an optional note (e.g. "Maintenance", "Tournament day").
- Closures block all slots in that window. Existing bookings are NOT auto-cancelled — owner must manually cancel affected bookings (system warns them).
- Active closures are shown as a list with delete option.

---

### 5.6 Operating Hours Management

Same UI as onboarding Step 2, but editable at any time. Changes take effect immediately (don't affect existing bookings).

**Ad-hoc full venue closure:**
- A separate **"Close venue for a day"** section — date picker + reason. Blocks all courts on that date.

---

### 5.7 Staff Management

**Screen: Staff**
- Two tabs: **Active** and **Pending Invites**.
- Active tab: staff member name, email, date joined, **Remove** button.
- Pending tab: email, date invited, **Resend invite** and **Revoke invite** buttons.
- **"+ Invite staff member"** button → email input modal.

---

### 5.8 Reports

**Screen: Reports**
- Date range selector (presets: This week, This month, Last month, Custom).
- Court selector: All courts or specific court.

**Report cards available:**
- **Revenue:** Total slot value in selected period. Breakdown by court (bar chart). Note: *"Revenue shown is based on slot prices. Actual collected amounts depend on your payment process."*
- **Occupancy rate:** % of available slots that were booked. Per court breakdown.
- **Total bookings:** Count over time (line chart by day/week).
- **Peak hours heatmap:** 7-day × time-of-day grid showing booking density. Helps owner understand demand.
- **Cancellation rate:** % of bookings cancelled. Trend over time.
- **Staff activity:** Table of all booking actions taken by staff (see Audit Logs).

**Export:** Each report has a **Download CSV** button.

---

### 5.9 Owner Settings

- Venue details (edit name, address, images).
- Notification preferences (email notifications for new bookings, cancellations).
- Change password / linked Google account.
- Danger zone: delete venue (with confirmation flow).

---

## 6. Staff Web View — Full Flow

Staff access the same web app as owners but see a restricted interface.

**Login:** Staff sign in with their regular customer credentials. The system detects the venue link and shows the staff view.

**Navigation (simplified):**
- Bookings
- New Booking
- Profile / Sign out

**Bookings screen:**
Same as owner's booking management screen but without access to: court management, hours, reports, settings, or staff management.

**Actions available:**
- View all bookings (all courts, all statuses)
- Confirm pending bookings
- Cancel bookings
- Create manual (walk-in) bookings
- View booking audit log per booking (read-only)

**All staff actions are written to the audit log** with the staff member's name, action type, and timestamp.

---

## 7. Public Marketing & Landing Page

**URL:** `booktruf.com`

**Design direction:** Playful, colourful, community-oriented. Bold sport illustrations. Generous whitespace. Fun copy. Feels like it was designed for people who love playing sport, not for corporate procurement.

---

### Section 1 — Hero

- Full-width section with a vibrant illustrated background: sports equipment (rackets, balls, nets) arranged in a playful collage style.
- Headline (large, bold): *"Find a court. Book a slot. Just play."*
- Subheading: *"Discover and book sports courts near you — cricket, football, padel, tennis, and more."*
- Two CTA buttons side by side:
  - **"Get the app"** (primary) → scrolls to app download section / opens app store link.
  - **"List your venue"** (secondary, outlined) → scrolls to owner section or opens owner signup.
- Animated elements: balls gently floating, subtle parallax on scroll.

---

### Section 2 — How it works (Customer)

- Three-step visual flow with large illustrated icons:
  1. 🗺️ **Pick your sport & city** — *"Tell us where you are. We'll show you every court nearby."*
  2. 📅 **Find a slot** — *"Browse availability in real time. Filter by distance, rating, or price."*
  3. ✅ **Book & play** — *"Tap to confirm. Show up. Game on."*
- Below: phone mockup screenshots of the app (home screen, court detail, booking confirmation).

---

### Section 3 — Sports we cover

- Horizontal scrollable row of sport illustration cards.
- Each card: sport illustration + sport name.
- Caption: *"And more being added every week."*

---

### Section 4 — Social proof / Reviews

- 3–5 customer quote cards (real or placeholder for launch):
  - Name, city, sport they play, short quote.
  - Star rating shown visually.
- Fun layout: cards at slight angles, colourful backgrounds per card.

---

### Section 5 — App Download

- Section headline: *"It's all in the app 📱"*
- Phone mockup (left) + download badges (right):
  - **Download on the App Store** (Apple badge)
  - **Get it on Google Play** (Google badge)
- QR code (centre, scannable) for direct download link.

---

### Section 6 — For Venue Owners (distinct section, scrollable anchor)

- Visually distinct background colour to separate from customer sections.
- Headline: *"Own a sports venue? You belong here."*
- Four benefit points with icons:
  - 📋 *"List your courts in under 15 minutes"*
  - 📅 *"Manage bookings, hours, and pricing — all in one place"*
  - 👥 *"Add your team and keep everyone in sync"*
  - 📊 *"See what's working with real usage reports"*
- Owner CTA: **"List my venue →"** → goes to `booktruf.com/owner/signup`.
- Secondary link: *"Already have an account? Sign in"*

---

### Section 7 — Policies & Info

- Tabs or accordion sections for:
  - **How bookings work** (customer explains: search, book, pay at venue, cancel)
  - **Cancellation policy** (customer can cancel any time, no fees)
  - **For venue owners** (what listing means, our role, contact)
  - **Privacy Policy** (link to full page)
  - **Terms of Service** (link to full page)
  - **Contact us** (email address or form)

---

### Section 8 — Footer

- Logo + tagline.
- Links: About, Contact, For Owners, Privacy, Terms.
- Social media links.
- App store badges (repeated).
- *"Made with ❤️ for players everywhere."*

---

## 8. Shareable Booking Web Page

**URL format:** `booktruf.com/b/[booking-id]`

**Purpose:** When a customer shares their booking, this page is what recipients see.

### Design

- Fun, celebratory design. Think: sports ticket aesthetic.
- Large sport illustration at the top matching the booked sport.
- Booking info displayed in a "ticket" card layout:
  - Sport
  - Venue name + court name
  - Date & time
  - Address with map link
  - Shared by: "[Name] invited you to the court 🎉"
- Fun tagline below ticket: *"Don't let [Name] play alone!"*

### App Install Prompt

- Persistent sticky banner at bottom: *"Get BookTruf — book your own courts, manage your squad."*
- Detects device:
  - iOS → links to App Store.
  - Android → links to Google Play.
  - Desktop → shows both + QR code.
- After app is installed and user signs up, the booking is saved to their history automatically (deferred deep link).

### Link Preview (OG tags)

- The page has rich Open Graph metadata so that when the link is pasted into WhatsApp, iMessage, Instagram etc., it renders a rich preview:
  - Preview image: sport illustration + venue name + date/time (dynamically generated).
  - Title: *"[Name] is playing [Sport] at [Venue] — join them!"*
  - Description: *"Book your own courts on BookTruf."*

---

## 9. QR Code Flow

### QR Code Generation

- Each court gets a unique QR code generated by the system.
- QR code encodes: `booktruf.com/court/[court-id]`
- The court record in the DB includes city + town, so the landing page can access this.
- Owner can download the QR code as a PNG from the Courts management screen (per court). Suitable for printing and displaying physically at the court.

### QR Code Web Landing Page

**URL:** `booktruf.com/court/[court-id]`

**Screen flow:**

1. **App install prompt (primary):**
   - Full-screen or near-full-screen prompt.
   - Headline: *"You found a BookTruf court! 🎾"*
   - Court name + venue name + city/town displayed.
   - Detects device and shows the appropriate store badge prominently.
   - Large **"Download BookTruf"** CTA button.
   - Smaller secondary link: *"View court details without the app"* → scrolls down to court info.

2. **Court details (below fold):**
   - Court name, sport, venue name, address.
   - A static slot availability message: *"See live availability in the app."*
   - Map embed or link.

---

## 10. Notifications & Reminders

### Customer Push Notifications

| Trigger | Message | Timing |
|---|---|---|
| Booking confirmed (instant) | *"You're all set! [Court] on [Date] at [Time] is locked in 🎉"* | Immediately |
| Booking confirmed (after manual approval) | *"Great news! [Venue] confirmed your booking for [Date] at [Time] 🎾"* | On approval |
| Booking cancelled by owner/staff | *"Heads up — your booking at [Venue] on [Date] was cancelled. We're sorry!"* | Immediately |
| Day-of reminder | *"Court day! You've got [Court] at [Time] today. Get ready 🏃"* | 8:00 AM on the day of booking |
| 30-minute reminder | *"30 minutes to go! Head over to [Venue] — [Court] is waiting."* | 30 min before slot |

### Email Notifications (Owner)

| Trigger | Email sent |
|---|---|
| New booking created | Summary of booking with customer name, court, time |
| Booking cancelled by customer | Cancellation notice |
| New review posted | Review content + link to reply |
| Staff invite accepted | Confirmation that [email] joined as staff |

---

## 11. Audit Logs

Audit logs exist for all booking-related actions. They are accessible by owners only.

### What is logged

Every log entry records:

- Booking ID
- Action type: `created` / `confirmed` / `cancelled` / `updated`
- Performed by: user ID + name + role (customer / staff / owner / system)
- Timestamp (UTC)
- Before/after state snapshot (status change)
- Optional notes (e.g. cancellation reason if entered)

### Where logs are visible

- **Per booking:** In the booking detail panel, a collapsible "Activity" section shows the full log for that booking.
- **Reports → Staff activity:** A filterable table of all log entries across all bookings, filterable by staff member and date range. Exportable as CSV.

---

## 12. Data & Backend Notes

### Key Entities

- **User** — shared model for customers, staff, and owners. Role is determined by relationships (venue_staff table, venue.owner_id).
- **Venue** — one per owner (v1). Has onboarding_step field (0–4).
- **Court** — belongs to venue. Has sport_type, slot_duration, booking_mode (instant/manual), is_active.
- **PricingRule** — belongs to court. Has days_of_week (bitmask or array), from_time, to_time, price_per_slot.
- **OperatingHours** — belongs to venue. One row per day of week.
- **CourtClosure** — belongs to court. Has start_datetime, end_datetime, reason.
- **VenueClosure** — belongs to venue. Has date, reason.
- **Booking** — belongs to court and user. Has slot_start, slot_end, status, created_by_role, created_by_id.
- **AuditLog** — belongs to booking. Has action, performed_by_id, performed_by_role, timestamp, snapshot.
- **Review** — belongs to booking (one per booking). Has rating, text, photos[], owner_reply.
- **StaffMember** — join table between user and venue. Has status (pending/active), invited_at, joined_at.
- **StaffInvite** — email, venue_id, token, status, expires_at.

### City & Town

- Cities and towns are seeded/managed by the platform admin (not owner-managed in v1).
- Courts are tagged with city and town on creation.
- User's preferred city is stored on the user profile (and locally on device as fallback).

### Deep Links

- Booking share links use deferred deep linking: if app is not installed, web captures intent; after install, app retrieves and saves the booking.
- Implementation: store `booking_id` in a cookie/local storage on web before redirecting to store; after app install and first launch, app checks for pending deep link data via the platform's SDK (Branch.io or similar).

### QR Code

- QR codes are generated server-side on court creation.
- Stored as a reference URL. Owner dashboard serves a downloadable PNG.
- Court landing page (`/court/[id]`) uses server-side rendering for OG tags.

---

## 13. Open Questions & Future Scope

### Confirmed v1 Constraints
- One venue per owner.
- No in-app payments — pay at venue model.
- No SMS — push notifications only.
- No Apple sign-in for owner dashboard in v1 (web only, consider later).
- Staff has no sub-roles or granular permissions.

### Open Questions to Resolve Before Build
1. **Admin panel:** Is there an internal BookTruf admin panel (for managing cities, towns, owners, flagging reviews)? Not specified — assumed out of v1 scope but likely needed soon after launch.
2. **Court capacity:** Do any courts support multiple bookings at the same time (e.g. a large ground with two sides)? Current model assumes one booking per slot.
3. **Waiting list:** If a slot is fully booked, should customers be able to join a waitlist?
4. **Multi-venue (owner):** When to unlock? Is this a paid tier or just a v2 feature?
5. **Review moderation:** Can owners flag/report inappropriate reviews? Who reviews them?
6. **Cancellation by owner:** When owner/staff cancels a booking, should the customer receive an in-app credit note or just a notification? (Currently: just a notification.)
7. **Languages/localisation:** Should the app support Urdu in v1?

### Future Scope (Post-v1)
- In-app payments and payout to owners.
- Recurring / subscription bookings (e.g. weekly slot).
- Multi-venue owner accounts.
- Customer loyalty / reward points.
- Team/group features (shared squad, group booking).
- Owner mobile app.
- Tournament / event bookings.
- Apple sign-in for owner dashboard.
- SMS reminders (if phone number added).

---

*Document prepared based on requirements review and clarification sessions. Last updated: April 2026.*
