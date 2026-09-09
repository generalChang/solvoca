# Solvoca

A local-only app for Korean learners of English. The learner studies a small prepared set of cards each day; there is no server, no dictionary of senses, and no backup. Progress and learner-made Cards live on the device. The only place a Card is graded is today's Queue. Lists group Cards for browsing and editing, not for a second study path. The product name is Solvoca; UI copy is Korean.

## Language

### Study unit

**Card**:
The atomic unit of study. The front is an English expression (a word or a phrase); the back is one Korean meaning. The only other fact a Card has is which List it belongs to. Two Cards may share a front if their backs differ; two Cards may not share both front and back. Editing a Card's back is still that Card.
_Avoid_: Word, entry, sense, vocabulary item, flashcard

**List**:
A named grouping of Cards. Every Card belongs to exactly one List. A Card can move between Lists without changing New, Learning, or Mastered. Learners can create Lists and must choose a List when adding a Card. The app always has at least one List. A List is for browsing, adding, moving, and returning a Mastered Card to Learning — not for grading.
_Avoid_: Category, tag, deck, folder, wordbook, inbox

**Queue**:
The Cards selected for one device-local calendar day. First fill is at most ten, Learning before New. Learning over the cap is a random subset. New slots are spread across Lists, random within a List. Leaving mid-Queue pauses it; opening it again continues from Cards not yet graded that day. Deleting a Card drops it from the remaining Queue. Didn't-know reinserts can lengthen it the same day. There is no skip without a Grade. Finishing it does not create another Queue until the next calendar day.
_Avoid_: Session, lesson, assignment, today's list

**Day complete**:
The day's Queue has been finished. There may still be New or Learning Cards left for tomorrow.
_Avoid_: Session complete, done, finished

**Cleared**:
There is no Card in New or Learning, so a Queue cannot be filled. Remaining Cards, if any, are Mastered.
_Avoid_: Empty, finished, done, all done

### Grading

**Grade**:
The learner's self-judgment after revealing the back: Knew or Didn't know. The most recent Grade can be undone once, restoring the Card's place in the Queue and its Streak.
_Avoid_: Score, result, answer, pass/fail

**New**:
A Card the learner has never graded.
_Avoid_: Unseen, unseen card, fresh

**Learning**:
A Card that has been graded and is not yet Mastered. Didn't know keeps it here. It can reappear later in the same day's Queue.
_Avoid_: Reviewing, young, in progress

**Streak**:
The number of consecutive days a Learning Card has been graded Knew. Didn't know sets it to zero. A Knew grade also removes the Card from the rest of that day's Queue.
_Avoid_: Score, points, interval, ease

**Mastered**:
A Card whose Streak has reached three. It is not in the default Queue unless the learner returns it to Learning. That return makes it eligible from the next calendar day, not by reopening today's Queue.
_Avoid_: Known, graduated, done, retired

## Experience

**Study moment**:
One or two short sessions per day, about five to ten minutes, often one-handed. The UI stays calm and low-friction; it never feels like a task list or a marathon.
_Avoid_: Long desk session, power-user density, notification-driven engagement

**Mood**:
A quiet corner of a cafe with soft ambient music — warm and unhurried, but not sleepy. Studying feels like a small ritual, not grinding through a queue.
_Avoid_: Gamified, sterile office tool, flashcard factory

**Craft**:
The visual and layout bar is Korean consumer apps like Toss and Danggeorn: generous spacing, few accent colors, clear type hierarchy, soft transitions, warm neutrals, and one obvious primary action per screen. Every surface — tab bar, lists, buttons, sheets, headers, empty states — must feel finished enough to show anyone. When Craft and Mood pull in different directions, Mood wins — Craft means considered layout, not Toss-like density or contrast.
_Avoid_: Material default, boilerplate Flutter, feature-first layout, demo-quality chrome

**Card surface**:
During a Queue, the learner sees one Card as a single rounded card at the center of the screen. The card keeps a fixed height when the back is revealed — only the content fades, the frame does not resize. Chrome stays minimal so the card feels like an object in hand, not a form.
_Avoid_: Full-screen text only, dense dashboard, admin-panel layout, height jump on reveal

**Appearance**:
Light mode only for v1. No dark theme.
_Avoid_: Dark mode, system theme toggle

**Palette**:
Latte cream: warm ivory background, cream card surface, brown text, terracotta accent.
_Avoid_: Cool Material seed palette, high-contrast fintech default, soft sage, warm paper

**Type**:
One Korean sans-serif family across the app (e.g. Pretendard). English and Korean share the same face; hierarchy comes from size and weight, not mixing families.
_Avoid_: System default only, serif for English, mixed typefaces

**Reveal**:
Showing the back of a Card is a soft in-place transition — content fades within the same card surface. No flip, no game-like motion.
_Avoid_: 3D flip, snap cut, celebratory animation

**Icons**:
Material Outlined, tuned to the theme. Icons support labels; they are not the primary visual language.
_Avoid_: Custom icon set, icon-heavy chrome, filled icon default

**Shape**:
Generously rounded corners across the app — study Card ~24px, buttons ~14px. Soft and cafe-like, not sharp or corporate.
_Avoid_: Small 4–8px radius, square corners, mixed radius with no system

**Depth**:
Subtle lift — soft shadow on cards, the tab bar, and FAB so surfaces feel layered, not flat Material sheets. Shadows follow the surface's corner radius (one decorated container), never a rectangular shadow behind a rounded shape. Never heavy or game-like elevation.
_Avoid_: Fully flat UI, harsh drop shadows, Material default elevation only, `Ink` shadows that ignore border radius

**Navigation**:
Two bottom tabs: Today (study) and Cards (browse and edit). Structure stays. The tab bar is a floating pill above the bottom inset with icon and label side by side in each segment — not a full-width stock `NavigationBar`.
_Avoid_: Single home hub, drawer navigation, restructuring tabs in v1, edge-to-edge default Material navigation, label-only tab emphasis

**List row**:
Each List appears as its own rounded card row with spacing between rows — warm cream surfaces on the ivory background, not gray-tinted cards. Not `ListTile` on a flat `Divider` list.
_Avoid_: Flat divider rows, dense table layout, stock `ListTile`, cool gray row backgrounds

**Primary action**:
Main buttons (Start, Reveal, Knew) use filled terracotta on cream text — full contrast, generous tap height.
_Avoid_: Default `FilledButton`, ghost primary, tiny tap targets

**Secondary action**:
Supporting buttons (Didn't know, cancel-style choices) use cream background with terracotta text and a hairline terracotta border (~1px) — outline, not filled, never heavy-stroked.
_Avoid_: Same style as primary, text-only with no affordance, thick or loud borders

**Components**:
Screens are built from a small Solvoca component set (floating tab bar, card rows, primary/secondary buttons, sheets, headers, the study Card surface) styled from Palette, Type, Shape, and Depth. Material widgets are implementation detail underneath, not what the user sees.
_Avoid_: Raw `NavigationBar`, default `FilledButton`/`Card`/`ListTile`/FAB stack as the finished UI, theme-only reskin
