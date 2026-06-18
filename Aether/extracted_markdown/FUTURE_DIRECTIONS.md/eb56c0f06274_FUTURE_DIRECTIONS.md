# FUTURE DIRECTIONS — Valuation-Depth → Tropical Functor (Cycle 3)

This cycle reconstructed the missing combinatorial foundation
`Catalog/Bridges/ValuationDepthTropicalFunctor.lean` (the free combination tree `OpTree`, its
measures `numLeaves`/`height`/`maxLeafDepth`/`eval`, the unit-cost `DepthCarrier`, the
universal bound `depth (eval t) ≤ maxLeafDepth + height` and the sharp lower companion
`⌈log₂ numLeaves⌉ ≤ height`), and then **resolved** two frontier conjectures on top of it:

* `Catalog/Speculative/AutoResearch/ValuationDepthKraft.lean` — **D7 (sharp tropical Kraft)**:
  the exact dyadic mass identity `∑_{leaves} 2^{-depth} = 1` for every `OpTree`
  (`kraft_eq_one`), the leaf bookkeeping (`leafDepths_length`, `leafDepth_le_height`), and the
  packing corollary `numLeaves · 2^{-height} ≤ 1` (`kraft_card_bound`).
* `Catalog/Speculative/AutoResearch/ValuationDepthWeighted.lean` — **D9 (mixed-cost height)**:
  flag-annotated trees `MTree` with a per-node `Bool` cost, the interpolating bound
  `depth (eval t) ≤ maxLeafDepth + weightedHeight` (`depth_eval_le_weightedHeight`), and the
  proof that it strictly refines both extremes (`mixed_recovers_unit`, `mixed_recovers_zero`,
  `mixed_recovers_strict`).

The unifying slogan, now proved along two new axes:

> **height is the only cost** — it saturates Kraft *with equality*, and it refines node-by-node
> into the weighted height, with idempotent nodes contributing nothing.

---

## D11 — Weighted Huffman optimum for mixed-cost carriers

**Conjecture.** Fix a leaf multiset `L` and a node-cost assignment in `{0,1}`. The minimum of
`MTree.eval` over all flag-annotated trees on `L` equals the smallest `D` with
`∑_{ℓ∈L} 2^{value(ℓ) − D} ≤ 1`, where only unit-cost (`true`) nodes contribute to the
exponent. When all nodes are unit-cost this is the ordinary tropical Kraft/Huffman optimum of
D7; when all nodes are idempotent the optimum collapses to `maxLeafDepth L`.

*The key insight is* that `kraft_eq_one` and `depth_eval_le_weightedHeight` are two halves of a
single saturation phenomenon: the Kraft identity says a unit-cost tree spends exactly one bit
of dyadic mass per level, while the weighted-height bound shows idempotent nodes spend none —
so a mixed tree's optimum is governed by a Kraft sum that counts *only* the unit nodes.

*Why now?* Both ingredients are freshly proved and 0-sorry this cycle (`kraft_eq_one`,
`kraft_card_bound`, `depth_eval_le_weightedHeight`); the only missing piece is the Huffman
*construction* matching the lower bound, already modelled by `mkBalanced`/`mark`.

## D12 — A converse Kraft realizability for depth lists

**Conjecture.** A finite list `d₁,…,dₘ ∈ ℕ` is the `leafDepths` of *some* `OpTree` if and only
if it satisfies the exact dyadic identity `∑ 2^{-dᵢ} = 1` (not merely the Kraft inequality
`≤ 1`). Thus `kraft_eq_one` is not only necessary but a complete invariant of full binary
combination shapes up to leaf-depth multiset.

*The key insight is* that `kraft_eq_one` already proves necessity; the standard McMillan
construction builds the tree greedily from the sorted depths, and the equality (rather than
inequality) is exactly the obstruction that forces the tree to be *full* — every internal node
binary — which is precisely the `OpTree.node` shape.

*Why now?* `leafDepths_length`, `leafDepth_le_height`, and `kraft_eq_one` supply every forward
invariant; the reverse direction is a single well-founded recursion on `∑ 2^{-dᵢ}` decreasing
by the smallest available dyadic mass, reusing the `numLeaves`/`height` bookkeeping.

## D13 — The mixed-cost weighted height is the unique monotone interpolant

**Conjecture.** Among all `Φ : MTree K → ℕ` for which `depth (eval t) ≤ maxLeafDepth + Φ(t)`
holds for *every* mixed-cost carrier, `weightedHeight` is the pointwise *least*; moreover it is
the unique such `Φ` that is additive across nodes and agrees with `height` on all-unit trees.

*The key insight is* that the per-node refinement of D9 is pinned from both sides
simultaneously: `mixed_recovers_unit` makes a unit-cost witness attain equality at every
`true` node, and `mixed_recovers_zero`/`mixed_recovers_strict` make an idempotent witness
attain equality at every `false` node — together forcing the interpolant node by node.

*Why now?* `mixed_recovers_unit`, `mixed_recovers_zero`, and `mixed_recovers_strict` already
establish equality at the two extremes; an extremal-witness argument over a single mixed node
closes minimality with no new infrastructure.

## D14 — Concrete order-`(1+c)` Householder tower on ℤ_p

**Conjecture.** The balanced-height precision count is realized by a concrete order-`(1+c)`
Householder iteration on `ℤ_p`: an explicit `N_c : ℤ_p → ℤ_p` whose `n`-fold balanced
composition certifies a root to p-adic precision exactly `p^{c·n}`, with `c = 1` Newton's
method and `c = 2` Halley's method.

*The key insight is* that the balanced tree of height `n` evaluates (under the unit-cost
carrier `witnessCarrier`) to depth exactly `n`, so `2^{depth} = 2^n` already identifies the
precision *exponent* with the tree height; attaching a genuine `ℤ_p` contraction turns the
combinatorial count into a certified analytic convergence rate.

*Why now?* The foundation supplies `depth_eval_add_le` and the attaining `witnessCarrier`, and
the **Computation** domain (`Catalog/Computation/PadicValuationDepth.lean`) supplies the p-adic
ultrametric; only the explicit `ℤ_p` iterate `N_c` and its contraction estimate remain.
