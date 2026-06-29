# How Many Questions Does It Take to Tell Things Apart?

## A game of twenty questions, played seriously

Imagine you are handed a sealed box containing one of a hundred objects, and your
only tool is a stack of index cards. On each card you may write a single
yes-or-no question — "Is it heavier than a brick?", "Does it fit in your pocket?",
"Is it alive?" — and an oracle will answer truthfully. Your goal is not to *guess*
the object, but something subtler and more demanding: to write down enough
questions that **no two of the hundred objects could ever give the same set of
answers**. You want your questionnaire to be a perfect fingerprinting machine.

How many cards do you need?

The instinctive answer is "it depends on the questions" — surely a clever set of
questions beats a clumsy one. And that is true. But there is a floor beneath all
cleverness, a hard limit that no amount of ingenuity can break, and a matching
ceiling that even a modest strategy can reach. The two meet at a single number,
and that number is astonishingly small: for a hundred objects, **seven questions
suffice, and six never can.**

This is the story of that number. It is a story about information, about the
difference between *knowing* and *distinguishing*, and about a surprising piece of
news for anyone who has ever tried to be clever: in this game, cleverness — the
ability to choose your next question based on the answers so far — buys you
*nothing at all*.

## From objects to observations

Let us make the game precise. We have a finite collection of possibilities — call
the collection `A`, and write `|A|` for how many things are in it. An
**observation** is any yes/no question we can ask about an element: formally, a
function that takes an element and returns a single bit, true or false. A whole
**observation system** of depth `n` is just a list of `n` such questions.

Run all `n` questions on a given element and you get a string of `n` bits — its
**profile**, or fingerprint. Two elements that happen to produce the *same*
profile are what we will call **twins**: as far as our questionnaire is concerned,
they are indistinguishable. They might be wildly different objects in reality, but
our instruments cannot separate them.

The dream is a questionnaire with **no twins** — a system in which every element
has a unique fingerprint. When that happens, we say the system *distinguishes* `A`.
The question of the whole article is: what is the smallest depth `n` for which such
a twin-free system exists?

## The counting floor: you cannot fingerprint more than your bits allow

Here is the first and most important observation, and it requires no cleverness at
all — only counting.

A profile is a string of `n` bits. How many *different* strings of `n` bits are
there? Exactly `2^n`: two choices for the first bit, two for the second, and so on.
That is the entire universe of possible fingerprints your `n` questions can ever
produce.

Now suppose your collection `A` has *more* than `2^n` elements. You are trying to
assign each of more than `2^n` elements its own fingerprint, but there are only
`2^n` fingerprints to go around. By the **pigeonhole principle** — that humble,
unbreakable law that says you cannot fit more pigeons than holes without doubling
up — at least two of your elements must collide. Two elements, one fingerprint.
You have twins, and no choice of questions can prevent it.

> **The Pigeonhole of Observation.** If `|A| > 2^n`, then *every* system of `n`
> yes/no questions has a twin pair. The discriminating power of `n` questions is
> capped at `2^n` distinct objects, forever.

This is the floor. It tells us that to fingerprint `|A|` objects we need enough
questions that `2^n` is at least `|A|` — that is, `n` must be at least the
smallest power to which we can raise 2 and reach `|A|`. Mathematicians call that
number the **ceiling logarithm base 2**, written `⌈log₂ |A|⌉`. For `|A| = 100`, we
need `2^n ≥ 100`; since `2^6 = 64` falls short and `2^7 = 128` clears the bar, the
floor is `n = 7`. Six questions can fingerprint at most 64 things — never a
hundred.

## The construction ceiling: binary spelling always works

A floor on its own is only half a theorem. It tells us seven questions are
*necessary*; it does not yet tell us they are *enough*. Maybe the pigeonhole bound
is hopelessly optimistic and the real cost is much higher.

It is not. And the reason is something every computer does a trillion times a
second: **binary encoding.**

Line up your `|A|` objects and label them `0, 1, 2, …`. Each label, written in
binary, is a string of bits. Now design your questions to simply *read off those
bits*: question `i` asks, "Is the `i`-th bit of this element's label equal to 1?"

With `n = ⌈log₂ |A|⌉` such bit-reading questions, every label from `0` up to
`|A|−1` fits inside `n` binary digits, and two elements with the same answers to
all `n` questions have identical binary labels — which means they are the same
element. No twins. The questionnaire is a perfect fingerprinting machine, and it
has exactly the depth the floor demanded.

> **The Sufficiency Ceiling.** Every finite collection `A` admits a system of
> exactly `⌈log₂ |A|⌉` yes/no questions that distinguishes all of its elements —
> namely, the questions that spell out each element's binary label.

Floor meets ceiling. The smallest possible depth is *neither more nor less* than
`⌈log₂ |A|⌉`. This is the exact price of distinguishability, and it is Shannon's
century-old insight — that information is measured in bits, and each yes/no answer
delivers at most one — turned into a precise, provable equation.

> **The Observation Complexity Theorem.** The minimum number of yes/no
> observations required to distinguish every element of a finite collection `A`
> is exactly `⌈log₂ |A|⌉`.

## The twist: cleverness is worthless here

So far we have assumed a rigid setup: you write down all your questions in advance,
hand the stack to the oracle, and collect the answers in a batch. But surely a
*smarter* player would do better by **adapting** — listening to each answer before
deciding what to ask next, like a doctor whose follow-up tests depend on the first
results, or like the game of twenty questions itself, where "Is it an animal?"
sensibly steers everything that follows.

This adaptive strategy is a **decision tree**. You start at the root with one
question. The "yes" answer sends you down one branch to a new question; the "no"
answer sends you down another, possibly entirely different one. The *depth* of the
tree is the length of its longest path — the worst-case number of questions you
might have to ask.

Intuition screams that adaptivity should help. In so many areas of life and
computation, the ability to react to information mid-stream is a genuine advantage.
Surely a tailored line of questioning beats a fixed checklist.

And yet — for the pure task of telling everything apart — it does not. Not even a
little.

The reason is beautiful in its simplicity. Whatever path an element takes through
your decision tree, the sequence of answers it generates is still just a string of
bits — one bit per question, along a path of length at most `n`. So every element
still ends up with a bit-string fingerprint of length at most `n`, and there are
still only `2^n` such fingerprints in existence. The pigeonhole does not care
whether your questions were fixed or adaptive; it only counts the fingerprints.
The very same floor applies.

> **No speedup from adaptivity.** An adaptive decision tree that distinguishes all
> of `A` must also have depth at least `⌈log₂ |A|⌉`. Since a plain fixed
> questionnaire already *achieves* that depth, the cleverness of adaptation saves
> not a single question.

This is the deepest and most counterintuitive part of the story. The optimal
strategy for the worst case is the dumbest one imaginable: write down `⌈log₂ |A|⌉`
fixed questions and ask them all. The grandmaster's adaptive cunning and the
clerk's rigid checklist tie for first place.

Two cautions keep this honest. First, *no speedup* refers to the worst-case depth
of guaranteeing every element is separated. Adaptivity can absolutely help with the
*average* number of questions, or when some outcomes are more likely than others —
that is the whole point of efficient codes and of twenty questions in practice. But
to *guarantee* full separation against an adversary, the worst-case price is fixed.
Second, the floor is a statement about every system, while the ceiling is a single
explicit construction; it is the meeting of these two opposite kinds of argument —
"all systems must" and "this one does" — that pins the answer down exactly.

## Beyond yes and no: questions with more answers

What if our questions are not binary? Suppose each observation can return one of
`k` possible values — a die roll returns one of six, a letter grade one of five, a
colored light one of three. How does the count change?

The pigeonhole adapts effortlessly. A profile is now a string of `n` symbols, each
drawn from a `k`-letter alphabet, so there are `k^n` possible fingerprints. To
distinguish `|A|` elements we therefore need `k^n ≥ |A|`, which means

> at least `⌈log_k |A|⌉` observations are necessary when each can take `k` values.

Richer questions need fewer of them, exactly as you would expect: a hundred objects
need seven binary questions, but only five ternary ones, and just two questions
with ten possible answers each (since `10^2 = 100`). The logarithm simply changes
its base.

There is one revealing edge case. What if `k = 1` — a "question" with only one
possible answer? Then `k^n = 1` for every `n`: no matter how many such questions
you ask, there is only one possible fingerprint, and nothing can ever be told
apart. The formula honestly reports a cost of zero useful questions, because a
question that can only be answered one way is no question at all. The logarithmic
law genuinely requires at least two possible answers — at least one *real* bit of
choice — to do any work. That degenerate case is not a bug; it is the theory
explaining, from first principles, why discrimination requires genuine alternatives.

## Why this matters beyond the puzzle

This is a clean piece of mathematics, but its fingerprints are everywhere.

**Sensor design and diagnostics.** Engineers placing sensors on a machine, or
designing a panel of medical tests, are playing exactly this game: how few
measurements does it take to pin down which of many internal states the system is
in? The theorem says the irreducible answer is logarithmic in the number of
states — and that you should not expect adaptive test ordering to reduce the
worst-case battery you must be prepared to run.

**Databases and keys.** A "key" in a database is precisely a set of fields whose
combined values are unique to each record — a twin-free observation system. The
theorem quantifies the minimum width of a binary key: a table of a million rows
needs at least twenty bits of key, and twenty well-chosen bits suffice.

**Coding and compression.** That every element can be fingerprinted by its
`⌈log₂ |A|⌉`-bit binary label is the seed of all fixed-length coding. The
construction in our ceiling proof *is* the binary code, and the floor is the
statement that no fixed-length code can be shorter.

**Searching and sorting.** The same `2^n` counting argument is why comparison-based
sorting and searching have logarithmic and `n log n` lower bounds: each comparison
is one yes/no observation, and you cannot distinguish all `n!` orderings of a list
with fewer comparisons than the logarithm of `n!` demands.

In every one of these settings, the lesson is the same, and it is bracing in its
finality. There is a hard, logarithmic floor on the number of observations needed
to resolve ambiguity; that floor is *achievable*; and against the worst case, the
freedom to adapt your questions on the fly — the strategy we instinctively reach
for — wins you exactly nothing.

## The shape of the answer

Step back and the whole result fits on a single line:

> To tell `|A|` things apart, you need exactly `⌈log₂ |A|⌉` yes/no observations —
> no fewer, and that many always suffice, whether you plan your questions in
> advance or adapt them as you go.

It is the kind of statement mathematics is built to deliver: a question that
sounds like it should have a messy, situation-dependent answer ("how many
questions?") turns out to have a single, exact, universal one. The messiness — the
particular objects, the particular questions, the particular order — all dissolves
into one clean logarithm. And hidden inside that logarithm is a quiet, humbling
truth about the limits of cleverness: when the only goal is to leave nothing
ambiguous, the simplest strategy is already the best one possible.
