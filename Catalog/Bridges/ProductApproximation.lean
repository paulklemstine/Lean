/-
# Stone–Weierstrass for Compact Product Codomains via Factorwise Approximation

This file proves that if continuous maps into `Y` and into `Z` can each be uniformly
approximated from respective classes `AY` and `AZ`, then continuous maps into the
product `Y × Z` can be uniformly approximated by "paired" maps from `AY` and `AZ`.

The key insight is that Mathlib's product metric on `Y × Z` is the sup/max metric:
  `dist (a, b) (c, d) = max (dist a c) (dist b d)`
so coordinatewise `< ε` estimates immediately yield a product `< ε` estimate with
no need to split `ε/2`.

## Main results

- `dist_prod_mk_lt_of_lt`: coordinatewise `< ε` implies productwise `< ε`
- `ContinuousMap.prodMk_projFst_projSnd`: decomposition identity for maps into products
- `PairClass`: the set of paired maps from two approximation classes
- `pairClass_uniform_dense`: the main product approximation theorem
- `denseRange_pair_of_denseRange_fst_snd`: alternative formulation
- `eml_uniform_dense_prod`: specialization to any EML-like predicate
- `pairClass_uniform_dense_triple`: ternary product corollary

## References

The argument is the standard factorwise approximation + diagonal assembly strategy,
a routine consequence of the product (sup) metric structure.
-/

import Mathlib

open scoped Topology
open ContinuousMap

noncomputable section

/-! ## §1. Product Metric Estimates -/

/-- The product metric is bounded by the max of coordinate distances. In fact, for
Mathlib's `Prod.dist`, this is an equality (`Prod.dist_eq`), so this lemma is just
a convenience wrapper providing the `≤` form. -/
theorem dist_prod_le_max
    {Y Z : Type*}
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (a b : Y × Z) :
    dist a b ≤ max (dist a.1 b.1) (dist a.2 b.2) := by
  rw [Prod.dist_eq]

/-- If both coordinate distances are strictly less than `ε`, then the product
distance is strictly less than `ε`. This is the key estimate for the
factorwise approximation argument. -/
theorem dist_prod_mk_lt_of_lt
    {Y Z : Type*}
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    {y₁ y₂ : Y} {z₁ z₂ : Z} {ε : ℝ}
    (hy : dist y₁ y₂ < ε) (hz : dist z₁ z₂ < ε) :
    dist (y₁, z₁) (y₂, z₂) < ε := by
  rw [Prod.dist_eq]
  exact max_lt hy hz

/-! ## §2. Coordinate Decomposition for Continuous Maps -/

/-- The projection of `f : C(X, Y × Z)` to the first coordinate. -/
def ContinuousMap.projFst {X Y Z : Type*}
    [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    (f : C(X, Y × Z)) : C(X, Y) :=
  ⟨fun x => (f x).1, continuous_fst.comp f.continuous⟩

/-- The projection of `f : C(X, Y × Z)` to the second coordinate. -/
def ContinuousMap.projSnd {X Y Z : Type*}
    [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    (f : C(X, Y × Z)) : C(X, Z) :=
  ⟨fun x => (f x).2, continuous_snd.comp f.continuous⟩

/-- Decomposition identity: pairing the coordinate projections recovers the
original map. This is the categorical product property for continuous maps. -/
theorem ContinuousMap.prodMk_projFst_projSnd
    {X Y Z : Type*}
    [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    (f : C(X, Y × Z)) :
    ContinuousMap.prodMk f.projFst f.projSnd = f := by
  ext x <;> rfl

/-! ## §3. PairClass and the Main Approximation Theorem -/

/-- The class of continuous maps into `Y × Z` obtained by pairing a map from `AY`
with a map from `AZ`. -/
def PairClass
    {X Y Z : Type*} [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    (AY : Set (C(X, Y))) (AZ : Set (C(X, Z))) : Set (C(X, Y × Z)) :=
  {f | ∃ g ∈ AY, ∃ h ∈ AZ, f = ContinuousMap.prodMk g h}

/-- **Main theorem: factorwise uniform approximation for product codomains.**

If `AY` uniformly approximates all continuous maps into `Y`, and `AZ` uniformly
approximates all continuous maps into `Z`, then `PairClass AY AZ` uniformly
approximates all continuous maps into `Y × Z`.

The proof decomposes the target map `f` into its coordinate projections,
approximates each coordinate separately using the same tolerance `ε`,
and assembles the result using `dist_prod_mk_lt_of_lt`. -/
theorem pairClass_uniform_dense
    {X Y Z : Type*}
    [TopologicalSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (AY : Set (C(X, Y))) (AZ : Set (C(X, Z)))
    (hY : ∀ f : C(X, Y), ∀ ε > 0, ∃ g ∈ AY, ∀ x, dist (g x) (f x) < ε)
    (hZ : ∀ f : C(X, Z), ∀ ε > 0, ∃ g ∈ AZ, ∀ x, dist (g x) (f x) < ε) :
    ∀ f : C(X, Y × Z), ∀ ε > 0,
      ∃ g ∈ PairClass AY AZ, ∀ x, dist (g x) (f x) < ε := by
  intro f ε hε
  obtain ⟨gY, hgY, happroxY⟩ := hY f.projFst ε hε
  obtain ⟨gZ, hgZ, happroxZ⟩ := hZ f.projSnd ε hε
  exact ⟨ContinuousMap.prodMk gY gZ, ⟨gY, hgY, gZ, hgZ, rfl⟩, fun x =>
    dist_prod_mk_lt_of_lt (happroxY x) (happroxZ x)⟩

/-- Alternative formulation exposing the witnesses `gY` and `gZ` directly. -/
theorem denseRange_pair_of_denseRange_fst_snd
    {X Y Z : Type*}
    [TopologicalSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (AY : Set (C(X, Y))) (AZ : Set (C(X, Z)))
    (hY : ∀ f : C(X, Y), ∀ ε > 0, ∃ g ∈ AY, ∀ x, dist (g x) (f x) < ε)
    (hZ : ∀ f : C(X, Z), ∀ ε > 0, ∃ g ∈ AZ, ∀ x, dist (g x) (f x) < ε) :
    ∀ f : C(X, Y × Z), ∀ ε > 0,
      ∃ gY ∈ AY, ∃ gZ ∈ AZ,
        ∀ x, dist (gY x, gZ x) (f x) < ε := by
  intro f ε hε
  obtain ⟨gY, hgY, happroxY⟩ := hY f.projFst ε hε
  obtain ⟨gZ, hgZ, happroxZ⟩ := hZ f.projSnd ε hε
  exact ⟨gY, hgY, gZ, hgZ, fun x => dist_prod_mk_lt_of_lt (happroxY x) (happroxZ x)⟩

/-! ## §4. Specialization to EML-like Predicates -/

/-- **EML product approximation theorem.**

Given any predicate `P` on continuous maps (e.g. "is EML-realizable"), if `P`-maps
uniformly approximate maps into `Y` and into `Z` separately, and if `P` is closed
under pairing (`prodMk`), then `P`-maps uniformly approximate maps into `Y × Z`. -/
theorem eml_uniform_dense_prod
    {X Y Z : Type*}
    [TopologicalSpace X]
    [PseudoMetricSpace Y]
    [PseudoMetricSpace Z]
    (PY : C(X, Y) → Prop)
    (PZ : C(X, Z) → Prop)
    (PYZ : C(X, Y × Z) → Prop)
    (hY : ∀ f : C(X, Y), ∀ ε > 0, ∃ g : C(X, Y), PY g ∧ ∀ x, dist (g x) (f x) < ε)
    (hZ : ∀ f : C(X, Z), ∀ ε > 0, ∃ g : C(X, Z), PZ g ∧ ∀ x, dist (g x) (f x) < ε)
    (hpair : ∀ {g : C(X, Y)} {h : C(X, Z)}, PY g → PZ h →
      PYZ (ContinuousMap.prodMk g h)) :
    ∀ f : C(X, Y × Z), ∀ ε > 0,
      ∃ g : C(X, Y × Z), PYZ g ∧ ∀ x, dist (g x) (f x) < ε := by
  intro f ε hε
  obtain ⟨gY, hgY_eml, happroxY⟩ := hY f.projFst ε hε
  obtain ⟨gZ, hgZ_eml, happroxZ⟩ := hZ f.projSnd ε hε
  exact ⟨ContinuousMap.prodMk gY gZ, hpair hgY_eml hgZ_eml, fun x =>
    dist_prod_mk_lt_of_lt (happroxY x) (happroxZ x)⟩

/-! ## §5. Ternary Product Corollary -/

/-- **Ternary product approximation** by two applications of the binary theorem.

This demonstrates the compositional nature of the product approximation result:
once binary products work, iterated products follow automatically. -/
theorem pairClass_uniform_dense_triple
    {X Y Z W : Type*}
    [TopologicalSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z] [PseudoMetricSpace W]
    (AY : Set (C(X, Y))) (AZ : Set (C(X, Z))) (AW : Set (C(X, W)))
    (hY : ∀ f : C(X, Y), ∀ ε > 0, ∃ g ∈ AY, ∀ x, dist (g x) (f x) < ε)
    (hZ : ∀ f : C(X, Z), ∀ ε > 0, ∃ g ∈ AZ, ∀ x, dist (g x) (f x) < ε)
    (hW : ∀ f : C(X, W), ∀ ε > 0, ∃ g ∈ AW, ∀ x, dist (g x) (f x) < ε) :
    ∀ f : C(X, Y × Z × W), ∀ ε > 0,
      ∃ gY ∈ AY, ∃ gZW ∈ PairClass AZ AW,
        ∀ x, dist (gY x, gZW x) (f x) < ε := by
  have hZW := pairClass_uniform_dense AZ AW hZ hW
  exact denseRange_pair_of_denseRange_fst_snd AY (PairClass AZ AW) hY hZW

/-! ## §6. Closure Properties of PairClass -/

/-- `PairClass` is monotone: if `AY' ⊆ AY` and `AZ' ⊆ AZ`,
then `PairClass AY' AZ' ⊆ PairClass AY AZ`. -/
theorem PairClass_mono
    {X Y Z : Type*} [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    {AY AY' : Set (C(X, Y))} {AZ AZ' : Set (C(X, Z))}
    (hY : AY' ⊆ AY) (hZ : AZ' ⊆ AZ) :
    PairClass AY' AZ' ⊆ PairClass AY AZ := by
  intro f ⟨g, hg, h, hh, hf⟩
  exact ⟨g, hY hg, h, hZ hh, hf⟩

/-- Every element of `PairClass AY AZ` has its first projection in `AY`. -/
theorem PairClass_projFst_mem
    {X Y Z : Type*} [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    {AY : Set (C(X, Y))} {AZ : Set (C(X, Z))}
    {f : C(X, Y × Z)} (hf : f ∈ PairClass AY AZ) :
    f.projFst ∈ AY := by
  obtain ⟨g, hg, h, _, rfl⟩ := hf
  have : (g.prodMk h).projFst = g := by ext x; simp [ContinuousMap.projFst]
  rw [this]; exact hg

/-- Every element of `PairClass AY AZ` has its second projection in `AZ`. -/
theorem PairClass_projSnd_mem
    {X Y Z : Type*} [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    {AY : Set (C(X, Y))} {AZ : Set (C(X, Z))}
    {f : C(X, Y × Z)} (hf : f ∈ PairClass AY AZ) :
    f.projSnd ∈ AZ := by
  obtain ⟨g, _, h, hh, rfl⟩ := hf
  have : (g.prodMk h).projSnd = h := by ext x; simp [ContinuousMap.projSnd]
  rw [this]; exact hh

end