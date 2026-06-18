# Future Directions — Rips–Tropical Functoriality for Finite Metrics

## Synthesis

We built a bridge from the **tropical (min-plus) order on pairwise distance data** to the
**Vietoris–Rips threshold-graph filtration** of `Catalog/Applications/PoincareData/MetricFiltration.lean`.
The development replaces the typeclass distance behind the catalog's `ripsGraph` with explicit
`DistData X` (a symmetric `ℝ`-valued function), which is what is needed to *compare two distance
functions on one carrier*. The headline finding is **adversarial**: the brief's literal claim (1)
— `D₁ ≼ε D₂ ⟹ rips D₁ r ≤ rips D₂ (r+ε)` for `D₁ ≼ε D₂ : ∀ x y, D₁ x y ≤ D₂ x y + ε` — is
**false** (`naive_containment_false`). The pointwise bound lower-bounds `D₂`, while containment of
`rips D₁ r` needs an *upper* bound on `D₂`. The Rips functor is **order-reversing** in the distance:
smaller distances yield more edges. With the direction repaired we obtained genuine functoriality
(`rips_le_of_tropLE`), an ε-interleaving sandwich (`rips_interleaving`), additive composition of
tropical certificates (`tropLE_trans`), one-sided stability of monotone graph functionals
(`monotone_functional_stability`), and inheritance of the clique/simplex complex along inclusions
(`clique_inherited`). Notably, **no metric axiom beyond symmetry is used**, so the bridge holds for
arbitrary symmetric dissimilarities, not just genuine metrics.

## Results Summary

- `DistData`, `DistData.rips`, `DistData.ofPseudoMetric` — explicit-distance Rips graph; strict
  generalisation of catalog `ripsGraph` (`rips_ofPseudoMetric_adj` confirms definitional agreement).
- `rips_mono` — scale monotonicity in the poset index `r` (generalises `ripsGraph_mono`).
- `tropLE_refl`, `tropLE_mono_eps`, `tropLE_trans` — the tropical order is a reflexive preorder
  whose error slack composes additively (min-plus functoriality).
- `rips_le_of_tropLE` — corrected functoriality: `D₁ ≼ε D₂ ⟹ rips D₂ r ≤ rips D₁ (r+ε)`.
- `naive_containment_false` — proven refutation of the brief's literal claim (1).
- `rips_interleaving`, `monotone_functional_stability`, `clique_inherited` — interleaving and its
  stability/topological consequences.

## Bold, Falsifiable Research Directions

### 1. A quantitative interleaving distance equals the tropical sup-norm
Define `d_TROP(D₁,D₂) := sup_{x,y} |D₁ x y − D₂ x y|` and the graph-interleaving distance
`d_INT` as the least `ε` for which the two-sided sandwich of `rips_interleaving` holds at every
scale `r`. **Conjecture:** `d_INT(D₁,D₂) = d_TROP(D₁,D₂)` for finite carriers.
*The key insight is* that `tropLE_trans` makes `ε` behave like a genuine (additive) metric on
certificates, so the interleaving parameter should be *exactly* the entrywise sup-norm rather than
merely bounded by it — the `≤` direction is `rips_le_of_tropLE`, and the `≥` direction should follow
from a single critical pair attaining the sup. *Why now?* All ingredients (the corrected direction,
additive composition, the counterexample pinning the constant) are already formalised; this upgrades
qualitative functoriality to an isometry theorem and is falsifiable by exhibiting a pair where the
graph interleaving is strictly smaller than the sup-norm.

### 2. Persistence of connected components (π₀) is 1-Lipschitz under tropical perturbation
Let `b(D,r)` be the number of connected components of `D.rips r`. **Conjecture:** `D₁ ≼ε D₂` and
`D₂ ≼ε D₁` imply `b(D₁, r+ε) ≤ b(D₂, r) ≤ b(D₁, r−ε)` (a bottleneck-style sandwich on the π₀
barcode). *The key insight is* that component count is *antitone* in edges, so it is a monotone graph
functional after sign flip and plugs directly into `monotone_functional_stability`; the interleaving
then squeezes the whole persistence profile. *Why now?* The catalog already has
`completeGraph_connected` and connectivity API, and `monotone_functional_stability` is general over
any `Preorder β`; this is the first genuinely *topological* (not merely combinatorial) stability
statement reachable without homology and is falsifiable on small explicit point clouds.

### 3. The tropical order reverses to an order *isomorphism* of filtration posets
View each `D` as a functor `r ↦ D.rips r` from `(ℝ,≤)` to `(SimpleGraph X, ≤)`. **Conjecture:** the
assignment `D ↦ (r ↦ D.rips r)` is a *fully faithful contravariant* embedding of the tropical preorder
`(DistData X, ≼0)` into the poset of `ℝ`-indexed filtrations under natural transformations, and the
slack `ε` indexes exactly the shifted natural transformations. *The key insight is* that
`rips_le_of_tropLE` plus `rips_mono` already exhibit the shift-by-`ε` maps as the components of a
natural transformation; faithfulness is the converse `rips D₂ ⊆ rips D₁ at all r ⟹ D₁ ≼0 D₂`,
testable via the threshold `r = D₂ x y`. *Why now?* The order-reversal phenomenon was just discovered
adversarially here; promoting it to a categorical (contravariant) equivalence is the natural next
abstraction and is falsifiable by a faithfulness counterexample on a 3-point carrier.

### 4. Sharp tightness of the scale shift: `r+ε` cannot be improved to `r+ε−δ`
**Conjecture:** for every `δ > 0` there exist `D₁ ≼ε D₂` and `r` with
`rips D₂ r ⊄ rips D₁ (r+ε−δ)`. *The key insight is* that the witness powering
`naive_containment_false` (a single pair realising the extreme distance gap) can be tuned so the
inclusion fails at any sub-`ε` shift, certifying that `rips_le_of_tropLE` is *optimal*, not merely
sufficient. *Why now?* The counterexample machinery is already in the file; turning it into a
two-sided sharpness statement converts a one-off refutation into a structural optimality theorem, and
it is falsifiable by a proof that some smaller shift always suffices.

### 5. Tropical certificates compose into a certified *pipeline* with metric-distortion guarantees
Chain perturbations `D₁ ≼ε₁ D₂ ≼ε₂ D₃` (e.g. quantisation, then denoising) and ask how Rips
invariants of the endpoints relate. **Conjecture:** every monotone functional satisfies the telescoped
bound `F(rips D₃ r) ≤ F(rips D₁ (r + ε₁ + ε₂))`, with the additive budget `ε₁+ε₂` *exactly* the
tropical path length, and equality achievable. *The key insight is* that `tropLE_trans` already gives
the additive law at the certificate level, so composing `monotone_functional_stability` along the
chain should incur no slack beyond the summed errors — a "no hidden cost" guarantee for staged data
pipelines. *Why now?* With `tropLE_trans` and `monotone_functional_stability` formalised, the
telescoping bound is one composition away, and it directly suggests an algorithm emitting certified
containment relations from per-stage error certificates; falsifiable if any pipeline forces slack
strictly exceeding `ε₁+ε₂`.
