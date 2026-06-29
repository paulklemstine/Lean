# Three Words the Machine Cannot Say: The Counting Wall Behind Computability

## A riddle in a library

Imagine a vast library that contains a definitive verdict on every yes-or-no
question you could ever pose. Not just "yes" and "no," but a third honest option:
"undecided." For each statement the library holds exactly one of three tokens —
**true**, **false**, or **undetermined**. This is what we will call an *oracle*:
a perfect answer-book that never hesitates and never contradicts itself.

Now suppose you want to *carry* this library around — not the whole building, but
a compact set of instructions, a program, that reproduces the library's verdicts
on demand. You don't need to store every answer; you only need a recipe short
enough to fit in your pocket that, when run, regenerates the answers one by one.

The question that organizes everything below is deceptively simple:

> **Can a fixed stock of short recipes reproduce every possible answer-book?**

The answer is no — and the reason is not subtle logic, not the halting problem,
not Gödel's ghost. It is *counting*. There are simply too many answer-books and
not enough recipes. This article tells the story of that counting wall, why it is
sharper than it first appears, and why it refuses to fall even when you try every
trick to knock it down.

## The arithmetic of indecision

Fix a number `N` of statements you care about — say the `N` open conjectures in
some field, or `N` propositions in a logical system. An oracle assigns each of
the `N` statements one of three tokens. How many distinct oracles are there?

For each statement you make an independent three-way choice, and there are `N`
statements, so the count is `3` multiplied by itself `N` times:

> **The Census of Oracles.** There are exactly `3^N` three-valued oracles on `N`
> statements.

This is the single fact from which everything flows. With `N = 1` there are `3`
oracles; with `N = 10` there are `59,049`; with `N = 100` there are already more
oracles than there are atoms in the observable universe. The space of possible
answer-books explodes.

Against this explosion stands your stock of recipes. Whatever your programming
language, however clever your compression, *you have only finitely many recipes of
any bounded size.* If each recipe is, say, a string of at most `k` symbols drawn
from an alphabet of size `b`, then there are at most `b^k` of them. That number is
large but **fixed** — it does not grow with `N`.

Here is the collision, stated as cleanly as it can be:

> **The Coverage Barrier.** If your program space `P` has strictly fewer than
> `3^N` members, then no matter how you assign a program to each answer-book, some
> oracle is left uncovered: there exists an oracle that *no* program in `P`
> reproduces.

The proof is the pigeonhole principle wearing formal dress. A map from a small set
onto a large set cannot exist; if `P` has fewer than `3^N` elements, the function
sending each program to the oracle it computes cannot be onto, so at least one
oracle is missed. Nothing about the number "3" is used here — only that the target
set is bigger than the source.

## The "3" was never the point

This is the first surprise, and it is a structural one. The coverage barrier holds
for **any** alphabet of verdicts, not just three. Whether your oracles answer with
2 tokens, 3 tokens, or 17 tokens, the same statement is true:

> **The Generic Barrier.** Fix an alphabet of `a` possible verdicts. If the program
> space `P` has fewer than `a^N` members, then some `a`-valued oracle on `N`
> statements escapes every program.

The three-valued case is just the line `a = 3`. The lesson is that *coverage* — the
impossibility of reproducing every answer-book — is a pure counting phenomenon that
knows nothing about logic, decidability, or even what the verdicts mean. It is a
fact about sizes of sets.

So where does the number "3" actually matter? It matters in a second, logically
*independent* obstruction: the obstruction of **information**.

## Two true things, one false economy

Suppose you try to *describe* an oracle with a binary string of length `N` — one
bit per statement. A bit is a two-way choice; an oracle's verdict is a three-way
choice. You are trying to pour three liters into a two-liter bottle, once per
statement. The counts make the failure exact:

> **The Information Deficit.** For every `N ≥ 1`, binary descriptions of length `N`
> are strictly too poor to name all oracles: `2^N < 3^N`.

(The single exception is `N = 0`, the empty world, where there is exactly one
oracle and one empty description — the boundary case where the deficit vanishes.)

This is a different failure from the coverage barrier. Coverage said "too many
answer-books for finitely many recipes." Information says "each binary name is too
narrow to capture a three-way verdict." One is about the *number* of descriptions;
the other is about their *width*. They are independent, and recognizing that is the
heart of the whole story.

We can make the information deficit quantitative — and beautiful. What *fraction*
of all oracles can a length-`N` binary description reach? Divide the reachable count
by the total:

> **The Geometric Law.** The fraction of oracles reachable by length-`N` binary
> descriptions is exactly
>
> `2^N / 3^N = (2/3)^N`.

This is not an approximation; it is an identity. And `(2/3)^N` marches relentlessly
to zero. At `N = 10` you can name about 1.7% of all oracles; at `N = 20`, under
0.03%; at `N = 100`, a number with forty-some leading zeros. The describable world
is a vanishing sliver of the possible world, and it vanishes *geometrically*.

The same vanishing holds for any *constant* budget of programs, not just binary
names of matching length:

> **The Computable Fraction Collapses.** For any fixed budget of `C` programs, the
> fraction `C / 3^N` of nameable oracles tends to `0` as `N` grows.

Pick your favorite finite library of recipes — a billion, a googol, any constant.
As the world of statements grows, the share of answer-books you can reproduce drips
to nothing.

## The wall you can point at

A skeptic might say: "Fine, *some* oracle escapes — but can you show me which one?"
For the cleanest case the answer is yes, and it is a flourish straight out of
Cantor's nineteenth-century playbook.

Suppose your recipes are indexed by the very statements they describe — `N`
descriptions for `N` statements, the `i`-th recipe attempting to reproduce some
oracle. Build a new oracle `g` by walking down the diagonal: for statement `i`,
look at what the `i`-th recipe says about statement `i`, and *change it* — add one
to the token and wrap around (if it said the last token, loop back to the first).

> **The Diagonal Escape.** The oracle `g` built this way disagrees with the `i`-th
> recipe precisely at statement `i`. Therefore `g` is reproduced by *no* recipe in
> your stock — and we have it explicitly in hand.

No contradiction, no proof by absurdity, no abstract pigeonhole. We literally
write down the renegade oracle. (And again the "3" is incidental: the diagonal flip
works for any alphabet of two or more tokens — there is always a different token to
flip to.) This is the same move by which Cantor showed the real numbers outnumber
the integers, and by which Turing built an undecidable problem. Here it appears in
finite, fully constructive form: a wall you can put your finger on.

## Climbing one rung: the finite jump

In the theory of computation there is a celebrated phenomenon called the *Turing
jump*: given any oracle, the question "does this machine halt when it can consult
that oracle?" is strictly harder than the oracle itself. Each oracle has a more
powerful oracle above it; the hierarchy never closes. The classical jump leans on
the halting problem and an infinite, subtle diagonal argument.

The counting wall reproduces this ascent in miniature, with nothing but arithmetic.
Consider not *evaluating* oracles but *transforming* them — maps that take an oracle
and return another oracle. How many such transformations are there? Each
transformation must specify an output oracle for every one of the `3^N` input
oracles, and each output is one of `3^N` possibilities. The count is a tower:

> **The Composition Census.** The space of oracle-to-oracle transformations has
> size `(3^N)^(3^N) = 3^(N · 3^N)`.

Compare that to the `3^N` plain oracles. For every `N ≥ 1` the tower strictly
dominates:

> **The Finite Jump.** For `N ≥ 1`, there are strictly more oracle transformations
> than there are oracles: `3^N < 3^(N · 3^N)`. Describing how to *transform* answer-
> books is strictly costlier than describing the answer-books themselves — and the
> transformation space outruns every fixed program budget.

This is a Turing jump with the mysticism removed. No halting problem, no infinite
regress — just the observation that a function space is enormously larger than its
domain. The hierarchy of "harder and harder" is, at bottom, a hierarchy of
"bigger and bigger."

## The wall refuses to crumble

Surely, you might think, the barrier is an artifact of allowing *arbitrary* answer-
books. Real oracles obey logic: if statement `i` implies statement `j`, an honest
oracle that calls `i` true must not call `j` anything but true. Constraints like
these prune the space of oracles. Could enough logical structure shrink the count
below the program budget and let computability sneak back in?

The answer is a firm no, and it pinpoints exactly why. Suppose, after imposing all
your consistency rules, there still remain `k` statements that are mutually
*independent* — none forces any other. Across those `k` statements an oracle is free
to choose any of the three tokens independently, so the consistent oracles contain a
faithful copy of all `3^k` free assignments.

> **Robustness to Logic.** If the consistent oracles contain an independent block of
> `k` mutually unconstrained statements, then any program space with fewer than `3^k`
> members still misses some *consistent* oracle. Logical structure does not restore
> computability.

The barrier only needs one uncluttered corner of the space — one antichain of
independent statements — to keep biting. To defeat it, your consistency rules would
have to entangle *almost everything*, collapsing the independent block to a sliver.
Short of that totalitarian degree of constraint, the counting wall stands.

## Why this is more than a puzzle

Strip away the dressing and the message is this: **in any world rich enough to admit
a third answer — "I don't know" — the space of honest verdict-assignments grows so
fast that no fixed toolkit can keep up.** This is the finite, elementary shadow of
the deepest facts in logic and computation:

- **Cantor's diagonal**, which showed some infinities dwarf others, here becomes an
  explicit construction of an unreachable answer-book.
- **Turing's undecidability and the jump hierarchy**, which placed an endless ladder
  of ever-harder problems above any starting point, here become a one-line cardinal
  inequality between a set and the functions on it.
- **Shannon's source coding**, which set the price of describing information, here
  appears as the exact geometric law `(2/3)^N` and the vanishing of every constant
  budget's reach.

And the framing is timely. Modern systems — automated theorem provers, formal
verifiers, AI assistants that issue confidence verdicts — increasingly traffic in
three-valued judgments: *proved*, *refuted*, *unknown*. The counting wall says that
no fixed-size such system, however large, can correctly classify all statements in a
sufficiently large universe; the unreachable fraction is not merely positive but
overwhelming, and it grows geometrically. The third word — "I don't know" — is
precisely the word that makes the space too big to tame.

What makes the result satisfying is how *little* it assumes. There is no appeal to
the structure of programs, no clever encoding, no subtle limit. Two independent walls
— one about the *number* of descriptions, one about their *width* — are each erected
by a single line of counting, and together they enclose the entire territory. The
deepest barriers in the theory of computation, it turns out, were standing on a
foundation of plain arithmetic all along.
