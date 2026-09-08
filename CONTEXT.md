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
