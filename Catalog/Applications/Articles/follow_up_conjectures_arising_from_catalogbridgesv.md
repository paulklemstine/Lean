# The Only Cost Is Height: How a Single Rule Governs Depth Across Algebra

## A puzzle hiding in plain sight

Imagine you are building something out of smaller pieces — a tournament bracket
out of matches, a sum out of additions, a compound function out of simpler
ones, or a high-precision approximation out of repeated refinements. Every time
you combine two pieces into one, you pay a small toll. The toll is always the
same: **one unit of complexity**.

Here is the natural question. After you have combined everything together into a
single final object, how much complexity have you accumulated? Is it the *number
of pieces* you started with? Is it the *logarithm* of that number? Is it
something messier that depends on the exact order in which you combined them?

The surprising answer, which we make precise below, is this:

> **The total cost depends only on the *height* of the combination process —
> the length of the longest chain of combinations — and on the complexity you
> started with. It does not depend directly on how many pieces you had.**

This sounds almost too clean. And the cleanest part is the punchline that gives
this article its title: when every combination costs exactly one unit, *the only
thing that costs anything is height*. Two builders who combine the same thousand
pieces can end up paying wildly different tolls — not because one of them was
wasteful per step, but because one of them built a tall, lopsided ladder while
the other built a short, balanced tree.

## The single rule

Let us name the toll precisely. Suppose every object we work with carries a
number called its **depth** — think of it as a measure of complexity, of
"how far down a hierarchy" the object sits, or of how much arithmetic precision
it represents. We have one operation, written `x ⊕ y`, that combines two objects
into one. The single rule governing everything is the **unit-cost law**:

> **Unit-cost law.** For all `x` and `y`,
> `depth(x ⊕ y) ≤ max(depth x, depth y) + 1`.

In words: combining two objects produces something no deeper than the deeper of
the two, plus one. The "plus one" is the toll. The "max" is what makes this a
*tropical* rule rather than an ordinary additive one — in tropical arithmetic,
addition behaves like taking a maximum. This law is exactly the shape of a
nonarchimedean, or *ultrametric*, triangle inequality, the kind that governs
p-adic numbers and valuation theory. Any structure obeying it we call a
**depth carrier**.

Three very different worlds obey this same law, and recognizing that they are
"the same" is the whole point:

1. **Tropical / valuation arithmetic.** Take the natural numbers, let `depth` be
   the number itself, and let `x ⊕ y = max(x, y) + 1`. This is the cleanest
   possible depth carrier; we call it the *witness carrier* because it witnesses
   that the toll really can be exactly one and never less.
2. **Function composition.** Let objects be maps, let `depth` measure how
   complex a map is, and let `⊕` be composition. Composing two maps raises
   complexity by at most one level — the same law.
3. **Hensel / Newton lifting.** In p-adic number theory, one refines an
   approximate root of an equation by a doubling step: each refinement squares
   the error, doubling the number of correct digits. Here `depth` counts
   refinement rounds, and combining two half-built approximations costs one
   round — again the same law.

## Trees, height, and the main theorem

To talk about combining many pieces, we use **combination trees**. A tree is
either a single leaf (one starting piece) or a node joining two smaller trees
(one combination). Three numbers describe a tree:

- its **height** — the length of the longest root-to-leaf path, i.e. the longest
  chain of consecutive combinations;
- its **leaf count** — how many starting pieces it has;
- its **maximum leaf depth** — the depth of the deepest starting piece.

To *evaluate* a tree means to actually carry out all its combinations with `⊕`,
collapsing it to a single object. The central result is:

> **Main bound.** For every depth carrier and every combination tree `t`,
> `depth(evaluate t) ≤ (maximum leaf depth of t) + (height of t)`.

The proof is a short induction that mirrors the rule itself. A leaf costs
nothing beyond its own depth. A node combines a left subtree of evaluated depth
at most `M + h_L` and a right subtree of evaluated depth at most `M + h_R`,
where `M` is the maximum leaf depth; the unit-cost law then bounds the combined
depth by `max(M + h_L, M + h_R) + 1 = M + max(h_L, h_R) + 1 = M + height`. The
"+1" toll is paid once per level of the longest chain — and *only* along that
chain. This is the precise sense in which **the only cost is height.**

## Two builders, same pieces, different bills

Now watch what the main bound does when two builders start from the same pieces.

**The balanced builder** arranges `2^n` identical pieces into a perfectly
balanced tree of height `n`. Evaluating it on the witness operation
`max + 1` gives final depth exactly `n` above the starting depth. With `2^n`
leaves, the height is `log₂` of the leaf count — the smallest height any binary
tree on that many leaves can have.

**The caterpillar builder** arranges pieces into a long lopsided spine: combine
two, then bolt on a third, then a fourth, and so on. A caterpillar with `n + 1`
pieces has height `n`. Evaluating it on the same `max + 1` operation gives final
depth exactly `n` — *much* worse than the balanced builder for the same number
of pieces.

Concretely, with `2^n` pieces the balanced builder pays `n`, while a caterpillar
on the same `2^n` pieces pays `2^n − 1`. That is an **exponential gap**, created
purely by the shape of the build, with identical per-step cost.

This has a sharp consequence for a tempting but *false* shortcut. One might guess
that the cost is always at most `(max leaf depth) + ⌈log₂(leaf count)⌉` — height
replaced by the logarithm of the number of pieces. For the balanced builder this
is exactly right. But it is **false in general**: a caterpillar of four pieces,
each of depth `0`, evaluates to depth `3`, whereas the guess would cap it at
`⌈log₂ 4⌉ = 2`. The naive logarithmic bound fails, and it fails by exactly the
gap between a tree's height and `log₂` of its leaf count. The fix is not to
patch the bound but to *rebalance the tree*: optimal reassociation restores the
logarithmic bound, because for a balanced tree, height and `log₂(leaf count)`
coincide.

## The toll is exactly one — no more, no less

Why "one" unit? Could a cleverer accounting make the toll zero, or might some
exotic structure force it above one? The answer is exact:

> **The constant is intrinsically one.** A constant `c` makes the law
> `depth(x ⊕ y) ≤ max(depth x, depth y) + c` hold across *every* depth carrier
> if and only if `c ≥ 1`. Hence `1` is the least universal toll.

Sufficiency is just the unit-cost law itself. Necessity is witnessed by the
cleanest example: in the witness carrier, `0 ⊕ 0 = max(0,0) + 1 = 1`, but a
toll of `c = 0` would demand `0 ⊕ 0 ≤ 0`. Combining two depth-zero atoms
genuinely produces something of depth one. So the toll cannot be cheapened; one
is forced. In categorical language, this pins the **Lipschitz constant** of the
bridge between valuation-depth and tropical geometry to the exact value `1`,
intrinsically rather than by lucky construction.

There is a flip side. Some structures are *strict*: their combination is
idempotent and obeys the sharper law `depth(x ⊕ y) ≤ max(depth x, depth y)`
with no `+1` at all. For these, the main bound improves to
`depth(evaluate t) ≤ (maximum leaf depth)`, with **zero height overhead** — the
tree shape stops mattering entirely. The general world and this strict world are
the two endpoints of a single spectrum: lax with unit cost on one side, strict
with zero cost on the other.

## The same arithmetic three times over

The most satisfying part is that this is not one theorem but a template that
fires in three registers at once.

**Composition.** Replace combination of values with composition of maps. A
balanced composition of `2^n` maps, each of complexity `d`, has complexity
exactly `d + n`. The very same height arithmetic — `d + height` — governs how
deep a stack of functions can get.

**Hensel lifting.** The crown jewel is p-adic Newton iteration. Each
quadratic-doubling step doubles the number of correct p-adic digits. Arrange `k`
doubling steps as a balanced tree of height `k`: its evaluated depth is exactly
`k`, and the precision it certifies is exactly `2^k`. This *recovers*, as a
special case of the height bound, the classical fact that Hensel lifting reaches
exponential precision in a logarithmic number of rounds — the engine behind fast
modular root-finding and factorization. The number of refinement rounds you need
to reach a target precision is the height of a balanced doubling tree, namely
`log₂` of the target plus a constant. Newton's quadratic convergence is, in this
light, simply the statement that *the only cost is height*.

## Why this matters beyond the page

The unit-cost law is a humble inequality, but its reach is wide because so many
real processes are "combine two things, pay a little" processes.

- **Parallel and distributed computation.** The depth of a computation — its
  *critical path* — is what limits how fast it can run on many processors, not
  the total amount of work. The main bound is precisely the statement that the
  critical path is the tree's height. The exponential balanced-vs-caterpillar
  gap is the daily bread of parallel-prefix and reduction-tree design: arrange
  the same additions as a balanced tree and finish in logarithmic time; arrange
  them as a chain and crawl.
- **Numerical and symbolic precision.** Hensel/Newton lifting, fast integer and
  polynomial arithmetic, and p-adic algorithms all live and die by the
  "double the precision each round" principle, which is exactly the height
  reading of the bound.
- **Robustness and ultrametric geometry.** The unit-cost law is an ultrametric
  triangle inequality. Bounds proved in this tropical, max-plus world transfer
  to certified robustness radii in nonarchimedean and lattice-style metrics — a
  bridge from combinatorial tree shapes to quantitative guarantees.

The moral is a single, portable sentence. Whenever you build a big thing by
repeatedly combining two smaller things at a fixed unit cost, do not count your
pieces and do not fear their number. Count the longest chain of combinations.
Make it short — make your tree balanced — and the rest is free. **The only cost
is height.**
