# Future Directions — Renormalization Fixed Points in In-Context Learning via p-adic Attention

## Synthesis of this cycle

This cycle built the two load-bearing pillars of the conjecture as fully verified
Lean 4 theorems, deliberately split along the Archimedean / non-Archimedean seam:

* **Geometry (`Catalog/MachineLearning/PadicAttentionTree.lean`).** The
  non-Archimedean *compression* of attention summaries into a hierarchical tree is
  not an empirical hope but a theorem: ultrametric balls are nested or disjoint
  (`ultrametric_balls_nested_or_disjoint`), the same-resolution relation is an
  equivalence at every scale (`clusterSetoid`), cluster classes are exactly closed
  balls (`cluster_eq_closedBall`), and shrinking the resolution strictly refines the
  partition (`sameCluster_mono`, `clusters_nested_or_disjoint`). The dendrogram is
  *forced* by the strong triangle inequality — no learned or probabilistic structure
  is required. This extends `Attention.lean` from the Euclidean to the ultrametric
  regime and shares the backbone of `UltrametricKLDivergence.lean`.

* **Dynamics (`Catalog/MachineLearning/PadicRGFixedPoint.lean`).** The
  renormalization flow of in-context-learning error has a *universal* fixed point.
  In the real (affine) model: a unique fixed point `b/(1-g)`, the exact flow law
  `gⁿ·(x-x*)`, convergence for every initialization (`rg_flow_converges`), and exact
  independence of initialization (`rg_universality`). In the p-adic model the RG map
  is multiplication by the uniformizer `p`, which is intrinsically contracting:
  `‖pⁿ·x‖ = p^(-n)‖x‖` (`padicRG_norm`), giving universal convergence to `0`
  (`padicRG_converges`) and exact *data collapse* of normalized error curves onto
  `n ↦ p^(-n)` (`padicRG_data_collapse`). This generalizes the linear single-mode
  contraction of `RGFlowTraining.lean` to an affine flow with a genuine nonzero IR
  fixed point and source term.

## Results summary

| Theorem | Statement | File |
|---|---|---|
| `ultrametric_balls_nested_or_disjoint` | ultrametric balls are nested or disjoint (tree property) | PadicAttentionTree |
| `clusterSetoid` | same-resolution clustering is an equivalence relation | PadicAttentionTree |
| `clusters_nested_or_disjoint` | the multi-scale dendrogram is a genuine rooted tree | PadicAttentionTree |
| `rg_flow_converges` | every initialization reaches the same RG fixed point | PadicRGFixedPoint |
| `rg_universality` | any two trajectories flow together (init/corpus irrelevant) | PadicRGFixedPoint |
| `padicRG_converges` | p-adic RG flow converges to the universal fixed point `0` | PadicRGFixedPoint |
| `padicRG_data_collapse` | normalized error curves collapse onto `n ↦ p^(-n)` | PadicRGFixedPoint |

All main results are `sorry`-free.

## Bold, falsifiable directions for the next cycle

### 1. Relevant/irrelevant operator dichotomy as a spectral gap in the p-adic gain

Generalize the scalar p-adic step to a *diagonal* RG operator on a finite product
`∏ ℚ_[p]` whose `i`-th coordinate is scaled by `p^{aᵢ}` with `aᵢ ∈ ℤ`. Conjecture:
the flow has a finite-dimensional unstable manifold of dimension `#{i : aᵢ < 0}` (the
"relevant operators"), and the surviving long-prompt behavior is governed *only* by
those coordinates; refutation occurs if any `aᵢ = 0` coordinate (a marginal operator)
contributes a non-power-law correction that breaks the collapse.
**The key insight is** that in the non-Archimedean world the critical exponents are
*integers* (valuations), so the relevant/irrelevant split is a clean sign condition
`aᵢ < 0` rather than a fine-tuned real threshold — making the universality class
combinatorially rigid. **Why now?** We already have the exact per-step norm law
(`padicRG_norm`) and the real multi-mode template in `RGFlowTraining.lean`; combining
them is a direct, provable next step.

### 2. Ultrametric Lipschitz stability of the compression map

Conjecture: the attention-to-tree compression `x ↦ (cluster of x at each scale)` is
1-Lipschitz from `ℚ_[p]` to the tree metric, so that two models with attention
matrices within p-adic distance `p^{-k}` produce dendrograms agreeing to depth `k`.
Refutation: exhibit a compression that strictly increases some ultrametric distance.
**The key insight is** that `cluster_eq_closedBall` already identifies tree nodes with
closed balls, so "predictive scaling structure is preserved" becomes the statement
that the quotient map onto `clusterSetoid` is distance-non-increasing — provable from
the same `dist_triangle_max` used here. **Why now?** The clustering equivalence and
its closed-ball description are in hand this cycle; only the quotient-metric wrapper
remains.

### 3. Universal critical exponent is `1` in `log_p` units, independent of architecture

Conjecture: for *any* p-adic RG step that is multiplication by a unit times `p^a`
(`a ≥ 1`), the rescaled error decays as `p^{-a n}` and the dimensionless exponent
`-log‖·‖ / (n log p)` converges to the integer `a`, the same for every initialization
and every unit factor. Refutation: a unit-times-`p^a` map whose exponent depends on
the unit or the initialization. **The key insight is** that multiplying by a p-adic
*unit* leaves the norm invariant, so the entire universality class is indexed by the
single integer `a` and the prime `p` — an exact "architecture-stable universality
class". **Why now?** `padicRG_data_collapse` proves the `a = 1` case exactly; the
general `a` and unit-invariance are one `norm_mul`/`Padic.norm_p_pow` step away.

### 4. Basin geometry: convergence rate sets define an ultrametric filtration of init space

Conjecture: for the real affine flow, the sets `B_k = {x : |x - x*| ≤ p^{-k}}` of
initializations whose error is already within `p^{-k}` form a nested filtration whose
RG image satisfies `rgStep(B_k) = B_{k+ν}` for an integer shift `ν` tied to `g`; this
makes the basin of attraction itself an ultrametric tree. Refutation: a gain `g` for
which the image of a ball is not a ball. **The key insight is** that contraction by a
constant factor maps balls to balls, fusing the *dynamics* (Pillar 2) with the *tree
geometry* (Pillar 1) into a single self-similar object — the RG flow acting on its own
phase space as a tree automorphism. **Why now?** Both ingredients — `rg_iterate_sub`
(exact contraction) and `ultrametric_balls_nested_or_disjoint` (ball algebra) — are
proven here; the synthesis is the natural cross-domain theorem.

### 5. Source-term universality: the fixed point depends only on the relevant operators

Conjecture: in the affine model, perturbing the source `b` by an *irrelevant*
component (one annihilated after one RG step) leaves `rgFixed` unchanged, while only
the relevant component of `b` moves the fixed point — a Lean-verifiable analogue of
"universal up to a finite set of relevant operators". Refutation: an irrelevant
perturbation of `b` that shifts the fixed point. **The key insight is** that
`rgFixed g b = b/(1-g)` is *linear* in `b`, so decomposing `b` into RG-eigencomponents
exactly separates which operators control the IR physics. **Why now?** The closed-form
fixed point and flow law from this cycle make the decomposition a finite linear-algebra
computation rather than an analytic estimate.
