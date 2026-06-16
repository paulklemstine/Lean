# The Only Cost Is Height: How the Shape of a Computation Determines Its Depth

## A question hidden in plain sight

Suppose you are handed a long arithmetic expression — a chain of values that must
be combined two at a time, like folding a stack of papers together or merging a
tournament bracket of teams. You may combine them in any order you like, as long
as the final answer is the same. Some orders feel "tall and skinny," combining one
new item at a time into a growing pile. Others feel "short and wide," pairing items
up, then pairing the pairs, then pairing those — the way a knockout tournament
collapses sixty-four teams into a champion in just six rounds.

A natural question follows immediately: **does the order matter?** And if it does,
*by how much*?

This article is about a clean, complete answer to that question — one that turns out
to govern a surprising range of mathematics, from the *p*-adic valuations of number
theory, to the max-plus "tropical" geometry now fashionable in algebraic geometry,
to the precision guarantees of Newton's method and Hensel's lemma. The punchline is
a slogan we can state before we have defined a single symbol:

> **Height is the only cost — and the height of any combination is pinned between
> `⌈log₂ (number of items)⌉` and `(number of items) − 1`.**

Everything below unpacks what this means, why it is true, and why it is the same
phenomenon wearing many disguises.

## The cost of combining things

Let us be precise about what "cost" means. Imagine each value `x` carries a number
`depth(x)` — a measure of how complicated, deep, or expensive it is. When we combine
two values `x` and `y` into a new value `x ⊕ y`, the result should not be wildly more
complex than its parts. We demand exactly one rule, the **unit-cost law**:

> `depth(x ⊕ y) ≤ max(depth(x), depth(y)) + 1`.

In words: combining two things costs you, at worst, one unit of depth on top of the
deeper of the two inputs. This single inequality is astonishingly common in disguise.

- In **number theory**, if `depth` is something like a *p*-adic valuation level, then
  combining two approximations can deepen the valuation by at most one notch per step.
- In **tropical geometry**, the "addition" is literally `max`, and the `+1` is a unit
  cost layered on top — the unit-cost law *is* the statement that `depth` is a
  1-Lipschitz map into the tropical semiring `(ℕ, max, +)`.
- In **iterative algorithms** such as Newton's method or Hensel lifting, each step
  roughly doubles your precision; phrased in terms of depth, each composition of two
  steps adds one to a depth counter while squaring a precision.

We package these uniformly. A **depth carrier** is simply a set `K` with a combining
operation `⊕` and a depth function `depth : K → ℕ` obeying the unit-cost law. That is
the entire setup. From it, a complete quantitative theory falls out.

## Trees: the shape of a computation

When you combine `m` items with a two-input operation, the *order* in which you do so
is recorded by a **binary tree**. The leaves are your original items; each internal
node is one combination `⊕`. A tournament bracket is a tree; so is the lopsided "add
the next number to the running total" loop. Two numbers describe the shape of such a
tree:

- its **height** — the number of combination steps along the *longest* path from the
  root down to a leaf; and
- its **number of leaves** — how many original items it combines.

The height is exactly the number of "rounds" the computation needs if independent
combinations could happen in parallel. The leaf count is the size of the problem.

Now we can evaluate a tree `t` inside a depth carrier: plug the items into the leaves,
apply `⊕` at every node, and read off the depth of the final value. How deep can it be?

## The fundamental bound: height is the overhead

Here is the foundational theorem, true for **every** depth carrier and **every** tree:

> **Combination-tree depth bound.**
> `depth(eval t) ≤ (maximum leaf depth of t) + (height of t)`.

Read it slowly. The depth of the final answer is at most the depth of the *deepest
ingredient* plus the *height of the tree*. Nothing else enters. Not the number of
leaves, not the particular values, not the operation beyond the unit-cost law. The
**only** overhead you ever pay for combining things is the height of the tree you
chose. This is why we say *height is the only cost*.

The proof is a clean induction on the tree. A leaf costs nothing beyond its own depth.
At a node combining a left subtree `l` and a right subtree `r`, the unit-cost law gives
one extra unit on top of the deeper of the two evaluated children, and the heights of
the subtrees combine via `max` plus one — exactly mirroring the recursion. The two
sides march in lockstep.

A small but striking corollary: if your operation happens to be *strict* — meaning it
obeys the stronger law `depth(x ⊕ y) ≤ max(depth(x), depth(y))` with **no** `+1` — then
the height overhead **vanishes entirely**, and the depth of any combination never
exceeds the deepest ingredient, no matter how you associate. This is the idempotent,
"free" regime; the unit cost is precisely what separates it from the generic case.

## How small, and how large, can height be?

If height is the only cost, the next question is forced: for a fixed number of items
`m`, how much can we control the height by choosing a clever order?

Two simple shapes anchor the extremes.

- The **balanced tree**: pair items up, then pair the pairs, and so on — a tournament
  bracket. With `m = 2ⁿ` items it has height exactly `n`.
- The **caterpillar**: a single long spine, folding one new item at a time into the
  running result — the naive accumulation loop. With `m` items it has height `m − 1`.

The deepening results of this work prove that these two shapes are not just examples
but the **universal extremes**, via a beautiful structural duality between height and
leaf count that holds for *every* binary tree:

> **Height–leaf duality.** For every combination tree,
> `numLeaves ≤ 2^height` and `height + 1 ≤ numLeaves`.

The first inequality says a tree of height `h` can fit at most `2ʰ` leaves — you cannot
combine more than `2ʰ` things in `h` parallel rounds, exactly like a knockout bracket.
The second says a tree with `m` leaves must have at least `m − 1` internal nodes along
*some* path is impossible to avoid only in the degenerate caterpillar; more precisely
its height is at most `m − 1`. Taking base-2 logarithms of the first inequality turns
it into the **universal lower bound** on height:

> **`⌈log₂ (numLeaves)⌉ ≤ height ≤ numLeaves − 1`.**

This is the sandwich in the slogan. And it is *tight at both ends*:

- the **balanced tree attains the floor** — its height equals `⌈log₂ (numLeaves)⌉`;
- the **caterpillar attains the ceiling** — its height equals `numLeaves − 1`.

So balanced reassociation is *provably optimal*, and the naive accumulation loop is
*provably worst*. There is no cleverer order than balancing, and no order can rescue
the caterpillar.

## The exponential payoff of balancing

Putting the pieces together yields a dramatic quantitative statement. Take the **same**
number of items, `2ⁿ` of them, and combine them under the canonical unit-cost operation
(where `depth` literally counts combination rounds). Then:

- the balanced tree produces depth exactly `n = log₂(2ⁿ)`;
- the caterpillar produces depth exactly `2ⁿ − 1`.

That is the difference between **logarithmic** and **linear** cost in the number of
items — an *exponential* gap, opened or closed entirely by the choice of order. If you
have ever wondered why summing a million numbers pairwise is numerically and
structurally so much better behaved than summing them one at a time into an
accumulator, this is the abstract heart of it: the height of the computation, and
hence its depth cost, drops from a million to twenty.

## Optimality for *every* size, not just powers of two

A skeptic might object that `2ⁿ` is a special, convenient size. What about `m = 1000`,
which is not a power of two? Does an optimal tree still exist?

It does — and this is one of the deepening results that closed a genuine open gap. Using
a **median-split** construction (split `m` items into a top half of `⌈m/2⌉` and a bottom
half of `⌊m/2⌋`, recurse, and combine), one builds, for *every* `m ≥ 1`, a tree with
exactly `m` leaves and height exactly `⌈log₂ m⌉`. So the universal lower bound is
attained for **all** leaf counts, not merely powers of two. Optimal reassociation always
exists, and it always meets the information-theoretic floor.

## Turning the dial: a tunable cost

What if combining is not unit-cost but charges some fixed amount `c` per step — perhaps
each merge in a distributed system costs `c` units of latency? The whole theory simply
*scales*. Replacing the `+1` by `+c` gives a **cost-`c` carrier**, and the fundamental
bound becomes

> `depth(eval t) ≤ (maximum leaf depth) + c · (height)`.

The unit theory is recovered at `c = 1`, and the constant `c` is again the *least* one
that works across all carriers. The entire framework is *scale-covariant* in the cost:
nothing about the structure changes, only the units on the axis. This is the kind of
robustness that signals you have found the right abstraction.

## No value is ever lost, and no overhead is ever wasted

Two final refinements complete the picture and are worth savoring.

First, on the canonical unit-cost carrier the evaluated depth is **sandwiched on both
sides**:

> `(maximum leaf depth) ≤ depth(eval t) ≤ (maximum leaf depth) + height`,

with both ends attainable. The lower bound is a conservation law: combining can only
*increase* depth, so **no leaf's information is ever lost** in the fold. The upper
bound is the familiar overhead. Reality lives somewhere in between, and both extremes
genuinely occur.

Second, there is a universal *crude* guarantee that needs no knowledge of the tree's
shape at all: the extra depth paid by **any** depth carrier on **any** tree never
exceeds `numLeaves − 1`. Whatever associativity structure you are handed, the overhead
is at most one less than the number of ingredients. It is the worst case made explicit,
and it is the caterpillar's signature.

## Why this matters

It is tempting to dismiss all this as bookkeeping about trees. But the unit-cost law is
a genuine bridge. It is the same inequality that controls:

- **Hensel lifting and Newton's method**, where the `k`-fold quadratic-doubling tree has
  depth exactly `k` and *p*-adic precision exactly `2ᵏ` — the famous exponential-precision
  certificate, here revealed to be nothing more than a balanced tree of height `k`;
- **composition of maps**, where composing functions of bounded "depth" obeys the same
  max-plus-one law, so the entire tree theory transfers verbatim from `⊕` to `∘`;
- **tropical and ultrametric geometry**, where `max` is the addition and the unit cost is
  the 1-Lipschitz constant of a functor from depth carriers into the tropical semiring.

Three apparently different worlds — number-theoretic valuations, functional composition,
and max-plus geometry — share one arithmetic skeleton. Once you see that skeleton, the
optimal strategy in each is the same: **balance your trees**. The cost you pay is the
height, the height you can always drive down to `⌈log₂ m⌉`, and you can never do better
than that.

## The shape of the answer

So, does the order of combination matter? Yes — and the answer is sharp. The cost is the
height of the computation, no more and no less. The height is trapped between the
logarithm and the predecessor of the number of items. Balancing hits the logarithm;
the naive loop hits the predecessor; and the gap between them is, in the worst case,
exponential. The next time you fold a long list together, remember that the difference
between a tournament bracket and a single-file line is the whole difference between
`log m` and `m` — and that this small, sharp truth is the same one that powers Newton's
method, tropical geometry, and the deep structure of *p*-adic numbers.
