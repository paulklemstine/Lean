# Counting Below the Line: How Error-Correcting Codes Hide a Convolution

## A number that should have been simple

Here is an innocent-looking question about error-correcting codes. Take a code — a
carefully chosen collection of binary strings, the kind that lets your phone, your
hard drive, and the Voyager probe recover data after noise has chewed holes in it.
Now sort its codewords by *weight*, the number of `1`s they contain. Ask: how many
codewords are "light," weighing at most some threshold `t`?

That count — call it `wcount(C, t)` — is the simplest possible summary of a code's
shape. It is a running total, a staircase that climbs as you raise the bar `t` and
finally levels off at the total number of codewords. Statisticians would recognize it
instantly: it is a **cumulative distribution function**, the discrete CDF of weight.

You might expect such a humble quantity to behave blandly. It does not. When you
combine two codes in the most natural way — by gluing their codewords end to end — the
running totals do not simply multiply. They *convolve*. And buried inside that
convolution is a strict, quantifiable inequality: a fingerprint of additive structure
that the usual bookkeeping of code theory throws away. This article is about that
fingerprint, why it appears, and what it tells us.

## The cast: codes, weights, and a famous octuplet

Let us fix vocabulary, building everything from scratch so nothing is taken on faith.

A **binary linear code** of length `n` is a set `C` of strings of `0`s and `1`s, each
of length `n`, closed under coordinatewise addition modulo 2. The strings are called
**codewords**. The **Hamming weight** of a codeword `c`, written `wt(c)`, is simply the
number of `1`s in it. Weight is the natural notion of "size" here because it measures
how far a codeword sits from the all-zeros string, and distance is exactly what error
correction is about.

The star example of this story is the **extended Hamming code** `[8, 4, 4]`, an
eight-bit code with sixteen codewords. (Coding theorists also know it as the
Reed–Muller code `RM(1,3)`, and number theorists recognize it as the modulo-2 shadow
of the celebrated `E8` lattice.) Its sixteen codewords have a strikingly sparse
distribution of weights:

- exactly **1** codeword of weight `0` (the all-zeros string),
- exactly **14** codewords of weight `4`,
- exactly **1** codeword of weight `8` (the all-ones string).

That is the whole spectrum: `1 + 14 + 1 = 16`. Coding theorists encode this as a
polynomial, the *weight enumerator* `1 + 14x⁴ + x⁸`, and it is one of the most
beautiful objects in the subject — the smallest "Type II" self-dual weight polynomial.

Now compute the cumulative count for this code. As we slide the threshold `t` upward:

| threshold `t` | `wcount(Hamming, t)` | what just entered |
|:-:|:-:|:--|
| 0 | 1 | the zero word |
| 1, 2, 3 | 1 | nothing — no light words |
| 4 | 15 | the fourteen weight-4 words |
| 5, 6, 7 | 15 | nothing |
| 8 | 16 | the all-ones word |

The staircase jumps at exactly the weights that occur — at `0`, at `4`, at `8` — and is
flat everywhere else. **Every stratum of the code is visible as a jump.** This is the
crucial advantage of the cumulative count over coarser summaries: it loses nothing.

## Gluing codes together

Codes are not solitary. The most basic way to build a big code from two small ones is
the **direct sum**, written `C ⊕ D`: take every codeword `a` from `C`, every codeword
`b` from `D`, and stick them together into the single longer string `a` followed by
`b`. If `C` has length `m` and `D` has length `n`, then `C ⊕ D` has length `m + n`, and
it has `|C| · |D|` codewords — one for each pairing.

The single most important fact about this construction is almost too simple to notice:
weight is **additive** under gluing. If you concatenate `a` and `b`, the number of `1`s
in the result is just the number in `a` plus the number in `b`:

> **Additivity of weight.** `wt(a followed by b) = wt(a) + wt(b)`.

This one identity is the hinge on which everything turns. Because weight adds, *every*
weight-based invariant of a direct sum is governed by how additions of weights
interact. And additions, when you are counting things that lie *below* a threshold, are
the natural habitat of an operation called convolution.

## The naive answer, and why it is too crude

Here is the temptation. Since `C ⊕ D` has `|C| · |D|` codewords, and counting all
codewords is just `wcount` at the maximal threshold, surely the cumulative counts
multiply too? Surely `wcount(C ⊕ D, t)` is roughly `wcount(C, t) · wcount(D, t)`?

No. And the reason is instructive. To produce a glued codeword of weight at most `t`,
you cannot independently pick a light `a` and a light `b`. Their weights *add*, so the
real constraint is `wt(a) + wt(b) ≤ t` — a *shared budget*, not two separate ones. If
`a` already spends weight `5`, then `b` must come in under `t − 5`, not under `t`. The
threshold for the second block **slides** depending on how much the first block used.

This is precisely the structure of a convolution, and it gives the first main result.

> **The exact convolution law.** For every threshold `t`,
> `wcount(C ⊕ D, t) = Σ over codewords a of C with wt(a) ≤ t of wcount(D, t − wt(a))`.

In words: to count light glued words, walk through each codeword `a` of the first code
that is itself light enough, and for each one, count how many words of the second code
fit in the *remaining* budget `t − wt(a)`. Add up those contributions. The proof is a
clean bijection: every light glued word splits uniquely into its two halves, the split
respects the weight budget exactly because weight is additive, and gluing is injective
so nothing is double-counted.

Let us watch it work on `Hamming ⊕ Hamming`, the 16-bit code with `256` codewords, at
threshold `t = 8`. The first block `a` can have weight `0`, `4`, or `8`:

- `a` of weight `0` (1 such word): leftover budget `8`, and `wcount(Hamming, 8) = 16`
  words fit. Contribution: `1 × 16 = 16`.
- `a` of weight `4` (14 such words): leftover budget `4`, and `wcount(Hamming, 4) = 15`
  fit. Contribution: `14 × 15 = 210`.
- `a` of weight `8` (1 such word): leftover budget `0`, and only the zero word fits, so
  `wcount(Hamming, 0) = 1`. Contribution: `1 × 1 = 1`.

Total: `16 + 210 + 1 = 227`. The sliding budget is the whole story; freeze it and you
get the wrong answer.

## The tropical heart of the matter: a strict inequality

The convolution identity is exact but intricate. Hidden inside it is something cleaner
and, in a sense, deeper — an *inequality* that captures the additive grading in a
single stroke.

Suppose you have two separate budgets, `s` for the first block and `r` for the second.
Any light-`a` (weight `≤ s`) glued to any light-`b` (weight `≤ r`) produces a glued
word of weight `≤ s + r`. So the rectangle of pairs `{wt ≤ s} × {wt ≤ r}` injects into
the set `{wt ≤ s + r}` of the direct sum. Counting both sides:

> **The supermultiplicative bound.** For all thresholds `s` and `r`,
> `wcount(C, s) · wcount(D, r) ≤ wcount(C ⊕ D, s + r)`.

Take logarithms and this says the function `t ↦ −log wcount(C, t)` is **subadditive** —
the defining property of a tropical valuation. ("Tropical" mathematics replaces
ordinary addition and multiplication with *minimum* and *addition*; it is the natural
language for anything graded additively, like weight.) The bound is the discrete shadow
of the classical fact that weight enumerators *multiply* under direct sum, but refined
from whole polynomials down to individual thresholds — and demoted from an equality to
an inequality, because thresholds remember more than polynomials do.

Why an inequality and not an equality? Because the rectangle `{wt ≤ s} × {wt ≤ r}` is
not all of the triangle `{wt(a) + wt(b) ≤ s + r}`. There are pairs that blow the
individual budgets yet stay within the shared one: a heavy `a` compensated by a feather-
light `b`. Those *cross-strata* live in the simplex but outside the rectangle, and they
are exactly what makes the inequality strict.

## The headline: 225 is not 227

Now we can state the punchline that gives this whole research line its slogan —
*convolution, not product*. Return to `Hamming ⊕ Hamming` and set both budgets to `4`.

The rectangle lower bound is

`wcount(Hamming, 4) · wcount(Hamming, 4) = 15 · 15 = 225.`

The true count is

`wcount(Hamming ⊕ Hamming, 8) = 227.`

So `225 < 227`, a **strict** gap of exactly `2`. And the two missing codewords are not
mysterious: they are the cross-strata `(8, 0)` and `(0, 8)` — the all-ones block glued
to a zero block, and vice versa. Each has total weight `8` (within budget) but violates
the individual cap of `4` in one block. They sit in the triangle, outside the rectangle,
and they are precisely the deficit.

This tiny gap of `2` is the entire point. It certifies, beyond argument, that the
cumulative count is **not multiplicative**. If it were, `225` would equal `227` and the
inequality would be vacuous. The gap proves that the threshold count carries strictly
more information than cardinality — it sees the *interior* of the weight distribution,
not just its endpoints. (At the extreme thresholds the inequality does collapse to
equality: at `s = r = 0` both sides are `1`, and at `s = r = 8` both sides are `256`,
recovering the familiar `|C ⊕ D| = |C| · |D|`. The action is all in between.)

## Sharpening the picture: the weight distribution convolves perfectly

The cumulative count is a CDF; its differences form the PMF, the **weight
distribution** `wexact(C, t) = #{codewords of weight exactly t}`. This finer object
obeys not an inequality but a flawless convolution, the discrete echo of multiplying
polynomials:

> **Cauchy convolution of weight distributions.**
> `wexact(C ⊕ D, t) = Σ over s ≤ t of wexact(C, s) · wexact(D, t − s)`.

The cumulative count is recovered by summing the PMF up to the threshold, so the two
laws are two faces of one structure. On `Hamming ⊕ Hamming` the weight-`8` stratum
reconstructs as

`wexact(Hamming, 0)·wexact(Hamming, 8) + wexact(Hamming, 4)·wexact(Hamming, 4)
 + wexact(Hamming, 8)·wexact(Hamming, 0) = 1·1 + 14·14 + 1·1 = 198,`

and the full sixteen-bit spectrum becomes `1, 28, 198, 28, 1` across weights
`0, 4, 8, 12, 16` — adding to `256`, as it must. Summing the first three (`1 + 28 + 198
= 227`) reproduces the headline count from a different direction. The whole edifice is
internally consistent, and the strict gap is its signature.

## A dictionary of refinements

Step back and the results assemble into a hierarchy of invariants for the direct sum,
each strictly finer than the next:

- **Cardinality** `|C ⊕ D| = |C| · |D|` — a plain product. Sees only the totals.
- **Weight distribution** `wexact` — an exact Cauchy convolution. Sees every stratum.
- **Cumulative count** `wcount` — a convolution *inequality*, strict in the interior.
  Sees every stratum as a cumulative threshold and exposes the cross-strata as a gap.
- **Tropical enumerator** — the min-plus hull of the spectrum. Sees only the convex
  outline, erasing interior strata such as the minimum distance.

The cumulative count occupies a sweet spot: detailed enough to register every jump in
the weight spectrum, yet structured enough to satisfy a clean tropical (subadditive)
law. It is the bridge between the exact algebra of weight enumerators and the
piecewise-linear world of tropical geometry.

## Why it matters beyond the puzzle

Cumulative distribution functions are everywhere a quantity has a budget: bit-error
counts in a noisy channel, energy levels in a physical lattice, costs in an
optimization. The lesson here — that gluing two systems makes their CDFs *convolve*,
with a strict supermultiplicative inequality whose deficit counts the cross-budget
configurations — is a template, not a one-off. It says: whenever your underlying
quantity is *additive* under composition, the right way to combine thresholds is
convolution, the right bound is supermultiplicative, and the slack in that bound is a
census of the trades you could have made between components.

For coding theory specifically, the cumulative count gives a threshold-level invariant
that, unlike the tropical enumerator, never loses the minimum distance or any interior
stratum, and that, unlike cardinality, behaves richly under the basic constructions of
the subject. The strict `225 < 227` gap on the smallest Type II code is a compact,
unforgeable certificate that this extra resolution is real.

A simple count below a line, it turns out, was hiding a convolution all along.
