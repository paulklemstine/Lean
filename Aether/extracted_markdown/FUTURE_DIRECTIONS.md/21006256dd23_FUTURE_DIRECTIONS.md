# Future Directions — Tropical Myhill–Nerode Separation via Valuation Profiles

## Synthesis

This cycle fused two previously disconnected catalog theories into a single concrete
separation theory. `Bridges/CoalgebraicNeuralMyhillNerode.lean` gives a coalgebraic
Myhill–Nerode account of neural state compression (`NeuralObservationSystem`,
`neural_behavior`, `neural_derivative`, `neural_equiv`, `NeuralHom`, behavioral quotients).
`Bridges/CategoricalTropicalUltrametric.lean` gives a tropical-to-ultrametric reconstruction
functor with the value semiring `tropicalization_base : TropicalValuationObject ℕ`.

The bridge is one structural move: **tropicalize the observation map**. Composing the
observation function with a valuation `v : β → V` yields a derived system `tropicalize N v`
whose visible output is the tropical valuation of the original output. Every state then
carries a *valuation profile* `VP s w = v (neural_behavior N s w)`, and the tropical
Myhill–Nerode relation `s ~t t` ("equal valuation profiles") is *definitionally*
`neural_equiv (tropicalize N v)`. This identity is what makes the whole catalog toolkit
transfer verbatim, with no new infinitary machinery.

## Results summary (`Catalog/Bridges/TropicalNeuralMyhillNerode.lean`, all proved, `sorry = 0`)

1. **Profile separation & refinement.** `~t` is an equivalence relation (`tropSetoid`),
   coincides with profile equality (`tropEquiv_iff_profile_eq`) and with behavioral
   equivalence of the tropicalized system (`tropEquiv_iff_neural_equiv`), and behavioral
   equivalence refines into it (`neural_equiv_refines_tropEquiv`).
2. **Finite tropical index.** A finite *separating family* `W` of derivative contexts over a
   finite valuation alphabet forces the tropical behavior quotient `X / ~t` to be finite
   (`trop_finite_index`), with the explicit partition bound
   `|X / ~t| ≤ |V| ^ |W|` (`trop_index_card_le`) — the termination certificate for tropical
   partition refinement.
3. **Tropical ultrametric pseudometric.** `tropDist s t = ⨆ k, [profiles disagree by depth k]·2^{-k}`
   is nonnegative, bounded by 1, vanishes on `~t`-classes, is symmetric, and satisfies the
   strong (ultrametric) triangle inequality (`tropDist_ultrametric`). Every behavior-preserving
   neural morphism descends to the quotient (`tropEquiv_of_hom`) and is **nonexpansive**
   for `tropDist` (`tropDist_nonexpansive`).

All main theorems depend only on `propext`, `Classical.choice`, and `Quot.sound`.

## Research directions

### 1. The pseudometric is exactly `2^{-d}` at the first disagreement depth, and is a genuine `PseudoMetricSpace`.
We proved `tropDist` is nonnegative, symmetric, ≤ 1, and ultrametric. The natural next claim
is the sharp closed form: if `s` and `t` first disagree at depth `d` (the least `k` with
`¬ tropAgree N v k s t`), then `tropDist N v s t = 2^{-d}`, and `tropDist s t = 0 ↔ tropEquiv s t`.
This would let us register `Quotient (tropSetoid N v)` as a Mathlib `PseudoMetricSpace`/`MetricSpace`
with an honest ultrametric (`dist_triangle` strengthened to the strong inequality).
**The key insight is** that depth-bounded agreement `tropAgree` is downward closed, so the
indicator sequence `k ↦ [disagree at k]·2^{-k}` is `0` up to `d-1` and then a decreasing
geometric tail, making its supremum exactly its first nonzero value `2^{-d}`.
**Why now?** The ultrametric inequality and the bddAbove/iSup scaffolding are already in place;
the only missing step is extracting the least disagreement depth via `Nat.find`, which is
routine, and it immediately upgrades the qualitative pseudometric into a quantitative metric
object usable by all of Mathlib's metric API.

### 2. A tropical Myhill–Nerode criterion: finite tropical index ⇔ a finite separating family exists.
We proved one direction (separating family ⇒ finite index). The converse — finite index ⇒
some finite `W` separates — would complete the criterion and mirror the classical
Myhill–Nerode theorem.
**The key insight is** that when the quotient is finite, picking one distinguishing context
for each of the finitely many unordered pairs of distinct classes yields a finite family that
separates every pair, hence the whole relation; over an infinite context space this is a finite
choice from a `Fintype` of pair-witnesses.
**Why now?** `trop_finite_index`/`trop_index_card_le` already encode the signature-injection
machinery; the converse only needs a finite-choice argument over `Finset`s of class pairs,
and proving it turns two one-directional lemmas into a single sharp equivalence.

### 3. Depth-stratified refinement converges to `~t` in finitely many rounds on finite state spaces.
Define the depth-`k` tropical partition by `tropAgree N v k`. On a finite state space the
chain of partitions `tropAgree 0 ⊇ tropAgree 1 ⊇ …` stabilizes, and the conjecture is that
the stabilization round is bounded by `|X| - 1` and that the stable partition equals `~t`.
**The key insight is** that each refinement round that fails to stabilize strictly increases
the number of classes, which is bounded by `|X|`, so at most `|X|-1` proper refinements can
occur — the tropical analogue of Hopcroft/Moore partition-refinement termination.
**Why now?** The catalog already has `finite_depth_refinement_monotone` and
`finite_depth_refinement_stabilizes_sufficient` for the un-tropicalized relation; transporting
them through `tropicalize` plus a strict-monotonicity counting argument gives an explicit
round bound, turning the abstract finiteness of direction 2 into an algorithmic complexity bound.

### 4. Valuation profiles are functorial: `tropicalize` and `VP` form a contraction-preserving functor into ultrametric objects.
We showed neural morphisms are nonexpansive for `tropDist`. The structural upgrade is to show
`s ↦ VP s` is a functor from the category of neural observation systems (with `NeuralHom`s) to
`UltraNormObj`/`UltraHom` from `CategoricalTropicalUltrametric.lean`, sending each system to the
ultrametric space of its valuation profiles and each morphism to a nonexpansive map, compatibly
with `valuationReconstruct`.
**The key insight is** that `tropDist` is literally the ultrametric attached, via the catalog's
`valuationReconstruct`, to the tropical valuation `2^{-d}` on profiles, so morphism
nonexpansiveness (`tropDist_nonexpansive`) is exactly the `UltraHom` `norm_nonexpansive'` law in
disguise.
**Why now?** Both the morphism nonexpansiveness lemma and the `UltraNormObj`/`UltraHom`
infrastructure already exist and compose; assembling them exhibits the bridge as a bona fide
functor rather than a collection of compatible lemmas, the kind of conceptual unification the
catalog prizes.

### 5. Tropical index is sub-multiplicative under products of observation systems.
For the product system `product_neural_system N₁ N₂` (already in the catalog) with the product
valuation `v = (v₁, v₂)`, conjecture that the tropical index satisfies
`|X₁×X₂ / ~t| ≤ |X₁ / ~t₁| · |X₂ / ~t₂|`, and that `tropDist` on the product is the max of the
component distances (a genuine ultrametric product).
**The key insight is** that `product_behavior_components` makes the product valuation profile the
pair of component profiles, so the product signature injects into the product of component
signatures, and `max` of two ultrametrics is again an ultrametric.
**Why now?** `product_behavior_components` and `product_equiv_implies_component_equiv` are already
proved in the catalog; pairing them with the new `tropSig`/`trop_index_card_le` injection gives the
sub-multiplicative bound directly, yielding compositional (divide-and-conquer) minimization bounds
for parallel neural sub-networks.
