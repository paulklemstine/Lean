# Future Directions — The Rips ↔ Tropical Diameter Bridge

## Synthesis of this cycle

This cycle built a precise bridge between two previously disconnected catalog domains:
the **Rips graph filtration** machinery in `Applications/PoincareData/MetricFiltration.lean`
(`ripsGraph`, `ripsGraph_mono`) and the **categorical tropical valuation language** in
`Bridges/CategoricalTropicalUltrametric.lean` (`TropicalValuationObject`, `TropObj`,
`tropicalization_base`). The connecting object is the **diameter / birth-scale valuation**
`β(S) = subsetDiameter S = sup { nndist a b | a,b ∈ S } ∈ ℝ≥0`, formalized in
`Catalog/Bridges/RipsDiameterTropicalBridge.lean`.

Results established (all `sorry`-free, only standard axioms):

1. `subsetDiameter_mono` — `β` is monotone under inclusion.
2. `rips_isClique_iff_subsetDiameter_le` — **the threshold law**: a finite set is a Rips
   simplex at scale `r ≥ 0` iff `β(S) ≤ r`. Simplex membership *is* a sublevel set of `β`.
3. `ripsGraph_adj_iff_subsetDiameter` — **reconstruction**: the Rips filtration is recovered
   edge-by-edge by thresholding `β` on 2-point sets.
4. `subsetDiameter_image_nonexpansive_le` and `rips_isClique_image_of_nonexpansive` —
   **functoriality**: nonexpansive maps contract `β` and send Rips simplices to Rips simplices.
5. `tropicalNNReal` — a new `TropicalValuationObject ℝ≥0` (max-times semiring), extending
   the catalog's ℕ-valued `tropicalization_base`, into whose order `β` lands.

The most important *negative* result is a correction to the originating concept: the proposed
tropical max law `β(S ∪ T) ≤ max(β S, β T)` is **false** (`subsetDiameter_union_max_law_false`,
counterexample `S = {0}, T = {1}`). Diameter is join-*super*additive; only the reverse
`le_subsetDiameter_union` holds. The honest categorical reading is that `β` is a *monotone
threshold/sublevel* presentation of the Rips filtration, **not** a homomorphism on the Boolean
algebra `(Finset X, ∪)`. The genuine max-plus structure lives on the simplex/threshold order.

## Research directions

### 1. A presheaf of Rips clique complexes whose sections recover global connectivity

Extend the edge-level reconstruction `ripsGraph_adj_iff_subsetDiameter` to the full clique
complex: define, for each scale `r`, the simplicial set of finite `S` with `β(S) ≤ r`, and
organize these over the scale poset `(ℝ, ≤)` as a presheaf of complexes with restriction maps
given by lowering `r`. Conjecture: the sublevel presheaf `r ↦ {S : β(S) ≤ r}` is a sheaf for
the down-interval topology on `ℝ`, and its global sections over `(-∞, r]` reconstruct exactly
the Rips clique complex at scale `r`. **The key insight is** that the threshold law turns a
geometric filtration into the sublevel functor of a single ℝ≥0-valued valuation, so gluing
local simplices is governed entirely by the order structure of `β`, not by metric data. **Why
now?** The edge-level case is already proved here (`ripsGraph_adj_iff_subsetDiameter`) and the
catalog's `Bridges/SheafPersistence.lean` provides the persistence-sheaf vocabulary to state
the gluing axiom; the missing step is purely the order-theoretic sheaf condition, which is
falsifiable on small finite point clouds.

### 2. Cohomological obstruction to lifting nonexpansive maps to filtration isomorphisms

We proved nonexpansive maps induce *morphisms* (`subsetDiameter_image_nonexpansive_le`). Ask
when such a map is a filtration *isomorphism*. Conjecture: a nonexpansive surjection `f : X → Y`
induces an isomorphism of Rips filtrations at all scales iff a single ℝ≥0-valued obstruction
class `obs(f) := sup_S (β_X(S) - β_Y(f(S)))` vanishes, and `obs` is subadditive under
composition (a 1-cocycle-style law `obs(g∘f) ≤ obs(g) + obs(f)`). **The key insight is** that
the contraction defect of `β` under a map is a single scalar obstruction that measures exactly
the failure of the threshold sublevel sets to be preserved, so filtration faithfulness is
detected by one number rather than by checking every scale. **Why now?** Functoriality is now a
theorem in this file, and `Bridges/CategoricalTropicalUltrametric.lean` already formalizes
quantitative "bound transfer" functors (`UltraLipschitzData`); the obstruction is the natural
quantitative refinement and is directly falsifiable by exhibiting `f` with `obs(f)=0` but a
non-isomorphic filtration.

### 3. The diameter valuation as a genuine `TropHom` on the clique-lattice, not the subset-lattice

The counterexample `subsetDiameter_union_max_law_false` shows `β` is not tropical on
`(Finset X, ∪)`. Conjecture: there is a *different* idempotent operation — the "clique join"
`S ⊔_r T :=` the largest common Rips-simplex refinement at scale `r` — under which `β` becomes
an honest tropical homomorphism into `tropicalNNReal`, i.e. `β(S ⊔ T) = max(β S, β T)` on the
sublattice of Rips simplices. **The key insight is** that the max-plus law fails on arbitrary
unions only because cross-pairs are unconstrained; restricting to the simplex order (where all
pairs are already within scale) removes exactly those cross-pairs, so the max law should hold
on the threshold sublattice. **Why now?** We have both the failure (on subsets) and the success
candidate (the simplex order from `rips_isClique_iff_subsetDiameter_le`) formalized; closing
this would upgrade the monotone valuation `subsetDiameter_monotone_into_tropObj` to a full
`TropHom`, completing the categorical bridge into `TropObj`.

### 4. Stability: the diameter valuation is 1-Lipschitz in Gromov–Hausdorff perturbation

Conjecture: if two finite metric spaces are within Gromov–Hausdorff distance `ε`, then the
diameter valuations of corresponding subsets differ by at most `2ε`, giving an
interleaving/stability theorem for the Rips-tropical bridge:
`|β_X(S) - β_Y(φ(S))| ≤ 2 · d_GH(X,Y)` for an optimal correspondence `φ`. **The key insight
is** that `β` is a `sup` of pairwise distances and each pairwise distance is itself 2ε-stable
under a GH correspondence, so the `sup` inherits the bound with no loss. **Why now?** The
nonexpansive contraction lemma `subsetDiameter_image_nonexpansive_le` is the one-sided special
case (`ε = 0` correspondences); the symmetric two-sided bound is the natural next theorem and
connects to the perturbation-stability theme already present in `MetricFiltration.lean`
(`sphere_perturbation_stability`). It is falsifiable by computing `β` on ε-perturbed point
clouds.

### 5. Persistent diameter barcodes from the tropical valuation, with an algebraic stability bound

Conjecture: the multiset of "birth scales" `{β(S) : S a maximal Rips simplex}` forms a tropical
analogue of a persistence barcode, and its bottleneck distance is bounded by the
`tropicalNNReal`-valued sup-norm of the difference of the two valuation functions:
`d_bottleneck(bar(X), bar(Y)) ≤ ‖β_X - β_Y‖_∞`. **The key insight is** that because simplex
membership is exactly a sublevel set of `β` (proved here), the entire barcode is a function of
the single valuation, so barcode distance must be controlled by valuation distance — collapsing
topological persistence to one ℝ≥0-valued object. **Why now?** The threshold law makes the
barcode a deterministic readout of `β`, and the catalog already has persistence infrastructure
in `Catalog/Tropical/PersistentHomology/Theorems.lean` and `Bridges/SheafPersistence.lean` to
state bottleneck distance; the conjecture is the precise quantitative bridge between them and is
testable on explicit finite examples.
