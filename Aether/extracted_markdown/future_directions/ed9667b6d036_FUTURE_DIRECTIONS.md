# FUTURE DIRECTIONS — Valuation-Depth → Tropical Functor

This document collects bold, falsifiable conjectures arising from the deepening cycle
recorded in:

* `Catalog/Bridges/ValuationDepthTropicalFunctor.lean` (foundations: the upper bound
  `depth (eval t) ≤ maxLeafDepth t + height t`),
* `Catalog/Speculative/AutoResearch/ValuationDepthFollowups.lean` (C1–C5: sharpness,
  least Lipschitz constant, balanced/caterpillar, Hensel),
* `Catalog/Speculative/AutoResearch/ValuationDepthDeepening.lean` (D1–D5: the universal
  height–leaf duality `⌈log₂ numLeaves⌉ ≤ height ≤ numLeaves − 1`, the optimality
  sandwich, the generalized cost constant, the two-sided witness bound, and the universal
  linear-overhead bound),
* `Catalog/Speculative/AutoResearch/ValuationDepthOptimal.lean` (D6, **now proved**: the
  median-split tree `mkBalanced` attains height `⌈log₂ m⌉` for *every* leaf count `m ≥ 1`,
  so the cycle-1 lower bound is tight for all `m`, not only powers of two).

The unifying slogan now proved in both directions is:

> **height is the only cost, and `⌈log₂ leaves⌉ ≤ height ≤ leaves − 1` pins it on both sides.**

---

## D6 — Optimal reassociation exists for *every* leaf count  —  **RESOLVED (cycle 2)**

**Theorem (was conjecture).** For every `m ≥ 1` and every leaf value `k` there is a
combination tree `t` with `t.numLeaves = m` and `t.height = Nat.clog 2 m`; the universal
lower bound `clog_numLeaves_le_height` is *attained* for all `m`, not only powers of two.
Proved in `ValuationDepthOptimal.lean` via the median-split tree `mkBalanced` (split `m`
into `⌈m/2⌉ = (m+1)/2` and `⌊m/2⌋ = m/2`), `numLeaves_mkBalanced`, `height_mkBalanced`
(using `Nat.clog 2 m = Nat.clog 2 ⌈m/2⌉ + 1`), `optimal_height_attained`, and
`unitCost_optimal_depth`.  This upgrades D2 from the dyadic witnesses to a complete
optimality statement.  **Next:** D7 below now becomes the natural open frontier.

## D7 — The reassociation optimum equals `maxLeafDepth + ⌈log₂ leaves⌉`

**Conjecture.** Fix a multiset `L` of `m` leaf values on the unit-cost witness carrier.
The minimum of `t.eval unitCostAdd` over all trees `t` whose leaf multiset is `L` equals
`maxLeafDepth L + ⌈log₂ m⌉` when all leaf values are equal, and in general is governed by a
*tropical Huffman/Kraft* formula `min_t eval = ` the smallest `D` with
`∑_{ℓ∈L} 2^{depth(ℓ) − D} ≤ 1`.

*Test.* Prove the Kraft-style inequality `∑_{leaves} 2^{−(eval − value)} ≤ 1` for the
unit-cost evaluation (a tropical analogue of Kraft's inequality), then show the Huffman
construction attains it. The lower bound side already follows from D1.

## D8 — Carrier morphisms make `depth` a genuine lax functor (2-categorical upgrade)

**Conjecture.** Depth carriers and *cost-non-increasing maps* (`f : X.K → Y.K` with
`Y.depth (f a) ≤ X.depth a` and `f (X.add a b) = Y.add (f a) (f b)`) form a category, and
`depthTropMap` extends to a lax functor into `(ℕ, max, +1)` such that the tree bound
`depth_eval_add_le` is *natural*: it is preserved and reflected along carrier morphisms.

*Test.* Bundle `CarrierHom`, prove identity/composition laws, and show
`Y.depth ((t.map f).eval Y.add) ≤ X.depth (t.eval X.add)` (a functorial refinement of
`depth_eval_le_numLeaves`). This turns the "bridge" into a verified 2-functor.

## D9 — Mixed-cost carriers and a weighted-height invariant

**Conjecture.** If each *node* of the tree may use its own cost `cᵢ ∈ {0,1}` (idempotent vs
unit), then `depth (eval t) ≤ maxLeafDepth t + (number of unit-cost nodes on the longest
root-to-leaf path)`. The `c·height` bound of D3 is the constant-cost specialization, and
`depth_eval_add_le_strict` (all `cᵢ = 0`) is the zero-cost specialization; this conjecture
*interpolates* between them with a single weighted-height invariant.

*Test.* Annotate `OpTree` nodes with a `Bool` cost flag, define `weightedHeight`, and prove
the interpolating bound by structural induction. Verify it recovers D3 and the strict
theorem at the two extremes.

## D10 — Quantitative Hensel/Newton tower from the cost constant

**Conjecture.** The cost constant `c` of D3 controls p-adic precision *multiplicatively*:
a balanced cost-`c` Newton tower of height `n` reaches precision exactly `p^{c·n}` (so
classical quadratic convergence is the `c = 1`, base-`p²` instance, and `c ≥ 2` models
higher-order Householder iterations). C5's `hensel_depth_eq_height_and_precision` is the
`c = 1` case; `cost_eval_le_balanced` already gives the depth `b + c·n`.

*Test.* State precision as `p ^ ((costWitness c).depth (eval (balanced 0 n) ...))` and prove
it equals `p ^ (c·n)` from `cost_eval_le_balanced`; then connect to a concrete order-`(1+c)`
iteration on `ℤ_p` to certify the convergence rate.

---

### Methodological note

Each conjecture above is stated so that its *lower-bound half* already follows from a proved
theorem (D1/D3/C5), leaving an explicit **construction** to supply the matching upper bound.
This makes them immediately actionable for the next cycle: build the witness
(`mkBalanced`, Huffman tree, `CarrierHom`, weighted/annotated `OpTree`, Newton tower) and
discharge the equality via the existing bound.
