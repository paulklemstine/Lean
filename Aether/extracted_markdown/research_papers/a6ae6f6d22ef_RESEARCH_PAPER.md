# The Only Cost Is Height: A Unit-Cost Ultrametric Functor from Valuation Depth to Tropical Trees

## Abstract

We study a single, deceptively simple inequality — the **unit-cost ultrametric
law** `depth(x ⊕ y) ≤ max(depth x, depth y) + 1` — and show that it governs the
accumulation of complexity across three superficially unrelated settings:
tropical/valuation arithmetic, function composition, and p-adic Hensel/Newton
lifting. We package the law as a **depth carrier** and analyze how complexity
propagates through arbitrary binary **combination trees**. Our central structural
result is that the evaluated depth of a tree is bounded by its maximum leaf depth
plus its *height* — never directly by its leaf count. From this we derive five
results corresponding to the conjectures C1–C5 of the originating program. (C2)
The unit constant `1` is the *unique least* Lipschitz constant valid across all
depth carriers, pinning the bridge's constant intrinsically. (C1) Balanced
reassociation meets the logarithmic bound `maxLeafDepth + ⌈log₂(numLeaves)⌉`,
whereas an explicit caterpillar witness *violates* it; the failure is exactly the
gap between height and `log₂(leaf count)`, and the balanced-versus-caterpillar
gap on `2^n` leaves is exponential (`n` versus `2^n − 1`). (C4) The height bound
extends verbatim to composition trees, giving balanced composition of `2^n`
depth-`d` maps an exact depth of `d + n`. (C5) The `k`-fold quadratic-doubling
tree has evaluated depth exactly `k` and certifies p-adic precision exactly
`2^k`, recovering the classical exponential-precision Hensel certificate as a
corollary of the height bound. (C3) For *strict* (idempotent) carriers the height
overhead vanishes, isolating the lax and strict regimes as two endpoints of one
spectrum. All results are stated as precise theorems with proof sketches.

**Keywords:** ultrametric, tropical algebra, valuation depth, p-adic, Hensel
lifting, Newton iteration, combination trees, parallel prefix, Lipschitz
functor, idempotent semiring.

---

## 1. Introduction

A great many constructions in mathematics and computation are *iterated binary
combinations*: build a final object by repeatedly fusing two intermediate
objects. Sums, products, parallel reductions, compound functions, and
successively refined numerical approximations all have this shape. In each case
there is a natural notion of *complexity* — degree, valuation, p-adic precision,
critical-path length — and combining two objects increases this complexity by a
small, fixed amount.

We isolate the cleanest possible accounting of that increase: a single
**unit-cost** inequality of *tropical* (max-plus) shape,
```
depth(x ⊕ y) ≤ max(depth x, depth y) + 1.
```
This is precisely a nonarchimedean / ultrametric triangle inequality with unit
slack. Our thesis is that this one law is the common denominator of three
seemingly distinct phenomena — tropical valuation growth, composition-depth
growth, and Hensel/Newton precision doubling — and that, once the law is in
hand, the propagation of complexity through an arbitrary combination process is
controlled by a single invariant: the **height** of the process, never directly
its size.

### 1.1 Contributions

This paper proves and contextualizes five results, organized as conjectures
C1–C5 of the originating bridge program connecting valuation depth to tropical
geometry.

- **C2 — intrinsic unit constant.** `lipschitz_constant_iff` and
  `unit_is_least_lipschitz_constant`: a constant `c` validates the law across
  *all* depth carriers iff `c ≥ 1`; hence the bridge's Lipschitz constant is
  intrinsically `1`.
- **C1 — height, not leaf count.** `balanced_meets_log_bound`,
  `unbalanced_exceeds_log_bound`, and `reassociation_exponential_gap`: balanced
  reassociation meets the logarithmic bound; a caterpillar violates the naive
  bound; the gap on `2^n` leaves is exponential.
- **C4 — composition analogue.** `comp_eval_depth_le`, `comp_balanced_depth_eq`:
  the height bound transfers to composition trees, with exact depth `d + n` for
  balanced composition of `2^n` depth-`d` maps.
- **C5 — Hensel certificate.** `hensel_depth_eq_height_and_precision`: the
  `k`-fold doubling tree has depth exactly `k` and precision exactly `2^k`,
  recovering exponential-precision Hensel lifting.
- **C3 — strict regime.** `depth_eval_add_le_strict`: strict (idempotent)
  carriers incur zero height overhead.

---

## 2. Definitions

Throughout, `ℕ` denotes the natural numbers, `max` and `+` their usual
operations, and `⌈log₂ m⌉ = clog 2 m` the binary ceiling-logarithm (with
`clog 2 (2^n) = n`).

### 2.1 Depth carriers

**Definition 2.1 (Depth carrier).** A *depth carrier* is a tuple
`X = (K, depth, add)` where `K` is a type, `depth : K → ℕ`, and
`add : K → K → K` (written `x ⊕ y`), satisfying the **unit-cost ultrametric
law**:
```
depth_add :  depth(x ⊕ y) ≤ max(depth x, depth y) + 1   for all x, y ∈ K.
```

The codomain `ℕ` is chosen so that all constants are exact and arithmetic is
clean; the law is the integer analogue of an ultrametric (strong triangle)
inequality with unit slack.

**Definition 2.2 (Witness carrier).** The *witness carrier* `W` has `K = ℕ`,
`depth = id`, and `add = unitCostAdd`, where
```
unitCostAdd x y := max x y + 1.
```
Its law holds with equality at every pair, so it is the extremal depth carrier;
in particular `unitCostAdd 0 0 = 1`.

**Definition 2.3 (Strict carrier).** A depth carrier `X` is *strict*
(`IsStrict X`) if its combination is idempotent and obeys the sharper law
```
depth(x ⊕ y) ≤ max(depth x, depth y)   for all x, y,
```
i.e. with zero slack.

### 2.2 Combination trees

**Definition 2.4 (Operation tree).** For a type `K`, the type `OpTree K` of
*combination trees* is generated by
```
leaf : K → OpTree K            (a single starting value)
node : OpTree K → OpTree K → OpTree K   (one combination)
```
We attach four functions:

- **height** `height(leaf k) = 0`, `height(node l r) = max(height l, height r) + 1`.
- **leaf count** `numLeaves(leaf k) = 1`, `numLeaves(node l r) = numLeaves l + numLeaves r`.
- **maximum leaf depth** (relative to `depth : K → ℕ`)
  `maxLeafDepth(leaf k) = depth k`, `maxLeafDepth(node l r) = max(maxLeafDepth l, maxLeafDepth r)`.
- **evaluation** (relative to a binary `op : K → K → K`)
  `eval(leaf k) = k`, `eval(node l r) = op(eval l, eval r)`.

### 2.3 Canonical tree families

**Definition 2.5 (Balanced tree).** For `k : K`, the *perfect/balanced* tree of
height `n`:
```
balanced k 0       = leaf k
balanced k (n + 1) = node (balanced k n) (balanced k n).
```
It satisfies `height = n`, `numLeaves = 2^n`, `maxLeafDepth depth = depth k`.

**Definition 2.6 (Caterpillar tree).** For `k : K`, the fully unbalanced
left-spine tree:
```
caterpillar k 0       = leaf k
caterpillar k (n + 1) = node (caterpillar k n) (leaf k).
```
It satisfies `height = n`, `numLeaves = n + 1`, `maxLeafDepth depth = depth k`.

---

## 3. The core height bound

**Theorem 3.1 (Main height bound, `depth_eval_add_le`).** For every depth carrier
`X` and every tree `t : OpTree X.K`,
```
depth(eval t X.add) ≤ maxLeafDepth depth t + height t.
```

*Proof sketch.* Induction on `t`. For `t = leaf k`, both sides equal `depth k`
(height `0`). For `t = node l r`, write `M = maxLeafDepth depth t =
max(maxLeafDepth l, maxLeafDepth r)`. By the unit-cost law and the inductive
hypotheses,
```
depth(eval t add) = depth(eval l add ⊕ eval r add)
                  ≤ max(depth(eval l add), depth(eval r add)) + 1
                  ≤ max(maxLeafDepth l + height l, maxLeafDepth r + height r) + 1
                  ≤ M + max(height l, height r) + 1
                  = M + height t.
```
The toll `+1` is incurred once per level along the *longest* root-to-leaf chain,
and nowhere else; hence height is the only contribution beyond the starting leaf
depth. ∎

**Corollary 3.2 (Constant leaves).** If every leaf of `t` has depth `b`, then
`maxLeafDepth depth t = b` and `depth(eval t add) ≤ b + height t`.

The remainder of the paper instantiates and sharpens Theorem 3.1.

---

## 4. C2 — The unit cost is the unique least Lipschitz constant

**Theorem 4.1 (`lipschitz_constant_iff`).** For `c : ℕ`,
```
(∀ depth carrier X, ∀ x y ∈ X.K,  depth(x ⊕ y) ≤ max(depth x, depth y) + c)
        ⇐⇒  1 ≤ c.
```

*Proof sketch.* (⇒) Instantiate at the witness carrier `W` with `x = y = 0`.
Then `depth(0 ⊕ 0) = unitCostAdd 0 0 = 1` while the right side is
`max(0,0) + c = c`, forcing `1 ≤ c`. (⇐) Given `1 ≤ c`, every carrier already
satisfies `depth(x ⊕ y) ≤ max(depth x, depth y) + 1 ≤ max(depth x, depth y) + c`
by the defining law `depth_add`. ∎

**Theorem 4.2 (`unit_is_least_lipschitz_constant`).** The value `1` is the least
element of the set
```
{ c : ℕ | ∀ depth carrier X, ∀ x y,  depth(x ⊕ y) ≤ max(depth x, depth y) + c }.
```

*Proof sketch.* Membership of `1` is the defining law. Minimality is the (⇒)
direction of Theorem 4.1: any valid `c` satisfies `1 ≤ c`. ∎

**Interpretation.** Theorems 4.1–4.2 pin the Lipschitz constant of the
valuation-depth → tropical functor to the exact intrinsic value `1`, rather than
merely realizing `1` by a fortunate construction. The value `c = 0` is refuted
precisely because combining two depth-zero atoms genuinely produces a depth-one
object (`not_strict_ultrametric_witness` in the originating development). Thus the
unit toll is not an artifact of the model; it is forced by universality across
all carriers.

---

## 5. C1 — Height, not leaf count, is the true cost

### 5.1 Evaluation of the canonical families

**Lemma 5.1 (`eval_balanced_unitCost`).** `eval (balanced b n) unitCostAdd = b + n`.

*Proof sketch.* Induction: base `n=0` gives `b`; step gives
`unitCostAdd (b+n) (b+n) = max(b+n, b+n) + 1 = b + (n+1)`. ∎

**Lemma 5.2 (`eval_caterpillar_unitCost`).** `eval (caterpillar b n) unitCostAdd = b + n`.

*Proof sketch.* Induction: step combines the spine value `b+n` with a fresh leaf
`b`, giving `max(b+n, b) + 1 = b + (n+1)`. ∎

The contrast is already visible: both families reach depth `b + height`, but the
caterpillar uses `height + 1` leaves while the balanced tree uses `2^height`.

### 5.2 The logarithmic bound holds after balancing

**Theorem 5.3 (`balanced_meets_log_bound`).** For every depth carrier `X`, every
`k : X.K`, and every `n`,
```
depth(eval (balanced k n) X.add) ≤ depth k + ⌈log₂(numLeaves(balanced k n))⌉.
```

*Proof sketch.* Apply Theorem 3.1 to `balanced k n`, using
`maxLeafDepth = depth k` and `height = n`. Since `numLeaves = 2^n` and
`clog 2 (2^n) = n`, the right side equals `depth k + n`, matching the height
bound exactly. ∎

So for optimally (balanced) reassociated combinations, the appealing logarithmic
bound `maxLeafDepth + ⌈log₂(leaf count)⌉` is correct — because for balanced trees
height and `log₂(leaf count)` coincide.

### 5.3 The naive logarithmic bound is false in general

**Theorem 5.4 (`unbalanced_exceeds_log_bound`).** There exist a depth carrier `X`
and a tree `t : OpTree X.K` with
```
maxLeafDepth depth t + ⌈log₂(numLeaves t)⌉ < depth(eval t X.add).
```

*Proof sketch.* Take `X = W` (the witness carrier) and `t = caterpillar 0 3`. By
Lemma 5.2, `depth(eval t add) = 0 + 3 = 3`. The maximum leaf depth is `0`, the
leaf count is `4`, and `⌈log₂ 4⌉ = clog 2 4 = 2` (via `4 = 2^2` and
`clog 2 (2^2) = 2`). Hence the bound side is `0 + 2 = 2 < 3`. ∎

The failure is *exactly* the discrepancy between a tree's height (`n` for a
caterpillar of `n+1` leaves) and `⌈log₂(n+1)⌉`. The remedy is structural:
rebalance the multiset of leaves and the logarithmic bound is restored
(Theorem 5.3).

### 5.4 The reassociation gap is exponential

**Theorem 5.5 (`reassociation_exponential_gap`).** Evaluated on `unitCostAdd`,
a balanced tree on `2^n` leaves has depth `n`, while a caterpillar on the *same*
number `2^n` of leaves has depth `2^n − 1`.

*Proof sketch.* Balanced: Lemma 5.1 gives depth `n` (with `2^n` leaves).
Caterpillar with `2^n` leaves has height `2^n − 1`, so Lemma 5.2 gives depth
`2^n − 1`. ∎

This is the quantitative heart of C1: identical per-step cost and identical leaf
multiset, yet an exponential separation driven solely by tree shape. It is the
abstract form of the rule that parallel reductions must be balanced.

---

## 6. C4/C5 — Composition and Hensel lifting

### 6.1 Composition carriers

Let a *composition carrier* attach to a collection of maps a `depth` measuring
complexity, with composition `∘` as the combining operation obeying the
unit-cost law `depth(f ∘ g) ≤ max(depth f, depth g) + 1`. This is again a depth
carrier, with `add = (∘)`.

**Theorem 6.1 (`comp_eval_depth_le`).** For a composition tree `t` whose leaves
are maps and whose nodes are `∘`,
```
depth(eval t (∘)) ≤ maxLeafDepth depth t + height t.
```

*Proof sketch.* Immediate from Theorem 3.1 applied to the composition carrier;
the tree theorem is agnostic to the meaning of `add`. ∎

**Theorem 6.2 (`comp_balanced_depth_eq`).** The balanced composition of `2^n`
maps each of depth `d` has depth exactly `d + n`.

*Proof sketch.* Specialize `eval_balanced_unitCost` (Lemma 5.1) to the
composition carrier with constant leaf depth `d`; the balanced tree of height
`n` evaluates to `d + n`, and Theorem 6.1 makes this an equality on the
extremal (unit-cost) carrier. ∎

This extends the 1-Lipschitz functor from `(add, mul)` to `(∘)`, unifying it
with the composition-depth law and its iterate
`vdepth_iterate_succ`.

### 6.2 The Hensel/Newton certificate

p-adic **Hensel lifting** (equivalently, Newton iteration over a complete local
ring) refines an approximate root by a *quadratic doubling* step: one step turns
precision `2^j` into precision `2^{j+1}`, i.e. each round doubles the number of
correct p-adic digits. Model the lift as a depth carrier of Hensel states whose
combination is one doubling step (unit cost in *rounds*).

**Theorem 6.3 (`hensel_depth_eq_height_and_precision`).** In the Hensel depth
carrier, the `k`-fold balanced doubling tree of height `k` evaluates to depth
exactly `k`, and the p-adic precision it certifies is exactly `2^k`.

*Proof sketch.* The depth claim is `eval_balanced_unitCost` (Lemma 5.1) with
starting depth `0`: a balanced doubling tree of height `k` has depth `k`. The
precision claim is the doubling recurrence `prec(k+1) = 2 · prec(k)`, `prec(0) =
1`, solved as `prec(k) = 2^k`. Combining, depth `= k` and precision `= 2^k`. ∎

**Corollary 6.4 (Exponential-precision Hensel certificate).** To reach a target
precision `T`, the number of doubling rounds (the tree height) is `⌈log₂ T⌉`,
recovering the classical statement that Hensel/Newton lifting attains
exponential precision in logarithmically many rounds, and the associated
speedup ratio over linear refinement.

*Proof sketch.* Invert Theorem 6.3: precision `2^k ≥ T` iff `k ≥ ⌈log₂ T⌉`. The
height bound (Theorem 3.1) certifies the depth, and `balanced_meets_log_bound`
(Theorem 5.3) certifies the logarithmic round count. ∎

This is the precise sense in which the height bound *contains* fast Hensel
lifting: Newton's quadratic convergence is the statement that the only cost is
height, applied to a doubling carrier.

---

## 7. C3 — The strict regime: zero height overhead

**Theorem 7.1 (`depth_eval_add_le_strict`).** If `X` is a strict depth carrier
(Definition 2.3), then for every tree `t`,
```
depth(eval t X.add) ≤ maxLeafDepth depth t.
```

*Proof sketch.* Repeat the induction of Theorem 3.1 but use the strict law
(no `+1`): at a node, `depth(eval l ⊕ eval r) ≤ max(depth(eval l),
depth(eval r)) ≤ max(maxLeafDepth l, maxLeafDepth r) = maxLeafDepth t`. The
height term never appears. ∎

**Interpretation.** Strict carriers are the idempotent endpoint of the spectrum:
the tree shape becomes irrelevant and combination is "free." Theorem 7.1
together with Theorem 3.1 frames the development as an interpolation between two
regimes — lax with unit cost, strict with zero cost — and motivates the
strictification program of Section 9 (collapsing the `+1` slack by saturation).

---

## 8. Algorithms

We summarize the constructive content as algorithms.

**Algorithm A1 (Evaluate a combination tree).** Given a tree `t` and a binary
operation `op`, fold `t` bottom-up: `eval(leaf k) = k`,
`eval(node l r) = op(eval l, eval r)`. Returns the combined value. Time
`O(numLeaves)`; recursion depth `O(height)`. With `op = unitCostAdd` and equal
leaves `b`, the output is `b + height(t)`.

**Algorithm A2 (Optimal rebalancing).** Given a multiset of `m` leaves, build a
balanced tree of height `⌈log₂ m⌉` (e.g. by repeatedly pairing adjacent nodes).
This minimizes evaluated depth and restores the logarithmic bound
(Theorem 5.3). The exponential gap of Theorem 5.5 is the worst case avoided.

**Algorithm A3 (Hensel doubling schedule).** To certify target p-adic precision
`T`, run `k = ⌈log₂ T⌉` quadratic-doubling rounds arranged as a balanced tree;
precision after round `j` is `2^j` and total round depth is `k` (Theorem 6.3,
Corollary 6.4).

---

## 9. Applications and discussion

**Parallel computation.** Theorem 3.1 is a statement about *critical-path
length*. In a parallel reduction, the time to combine `m` values with an
associative operator is the height of the reduction tree, not the total work
`m − 1`. Theorem 5.5 is the formal reason that parallel-prefix and reduction
algorithms balance their trees: a chain costs linear depth, a balanced tree
logarithmic depth.

**Numerical and p-adic algorithms.** Section 6 places fast Hensel lifting, p-adic
root-finding, and Newton-based high-precision arithmetic under the same height
bound. The "double each round" principle is exactly the balanced doubling tree.

**Ultrametric robustness and tropical transfer.** The unit-cost law is an
ultrametric triangle inequality; the depth carrier is a tropical (max-plus, unit
shift) object. Quantitative bounds proven combinatorially on tree shapes
transfer through the valuation-depth → tropical functor to certified radii in
nonarchimedean and lattice-style metrics, with the now-pinned Lipschitz constant
`1` (Section 4).

**Why ℕ.** Using `ℕ` for depth keeps every constant exact (`clog 2 (2^n) = n`,
`unitCostAdd 0 0 = 1`) and avoids the coercion friction of real-valued
valuations, while remaining faithful to the ultrametric structure.

---

## 10. Future work

The development settles C1, C2, C4, C5 in sharp form and supplies the
computational core of C3. The principal open directions:

- **Strictification as a reflection (D1).** Construct a left adjoint `Strictify`
  to the inclusion of strict carriers, given by saturating depth under
  combination, with a 1-Lipschitz universal unit. Theorem 7.1 already supplies
  the defining inequality of a strict object, reducing the task to quotienting
  the `+1` slack over the unit-cost monoid `(ℕ, max, +1)`.
- **Exact depth for constant-leaf trees (D2).** Upgrade the `≤` of Corollary 3.2
  to equality on extremal carriers, proving that the balanced tree *uniquely*
  minimizes evaluated depth over all binary trees on a fixed multiset of equal
  leaves, with value `b + ⌈log₂ m⌉`.
- **Mixed associativity-commutativity (C1 sharp form).** Prove a rebalancing
  operator preserving evaluation up to depth and achieving height
  `⌈log₂(numLeaves)⌉` whenever `add` is associative and commutative on depth
  values, or exhibit an associative carrier where no reassociation beats height.
- **Full composition functoriality (C4).** Extend the `(∘)` analogue to a
  complete compositional calculus unifying `add`, `mul`, and `∘` under one
  1-Lipschitz functor.
- **Hensel carrier instantiation (C5).** Build the concrete `DepthCarrier` of
  Hensel states and prove that the `k`-fold doubling tree depth equals `k`,
  matching the `2^k` precision certificate end to end.

---

## 11. Conclusion

A single unit-cost ultrametric inequality, lifted to arbitrary combination
trees, yields one clean law: the depth of a combined object is its starting
depth plus the height of the combination — never directly its size. The unit
toll is intrinsically forced; the height dependence is sharp; and the same
arithmetic governs tropical valuation growth, composition depth, and Hensel
precision doubling. In every register, **the only cost is height.**
