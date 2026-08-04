import Mathlib

/-!
# Universal coefficients: flat coefficients and the failure of flatness

The universal coefficient theorem for homology relates `H_n(C ⊗ G)` with `H_n(C) ⊗ G` and a
correction term `Tor₁(H_{n-1}(C), G)`. This file formalises the two extreme phenomena:

* `Catalog.DerivedFunctors.homologyTensorFlatIso`: **the universal coefficient theorem with flat
  coefficients**. If `G` is a flat `R`-module, the correction term disappears and
  `H_n(C ⊗ G) ≅ H_n(C) ⊗ G` for every complex `C` of `R`-modules (any complex shape).
  A `LinearEquiv` version is `Catalog.DerivedFunctors.homologyTensorFlatLinearEquiv`, and
  `Catalog.DerivedFunctors.homology_tensor_eq_zero_of_flat` records that tensoring with a flat
  module preserves acyclicity.

* `Catalog.DerivedFunctors.tensor_zmod_not_exact`: for non-flat coefficients the correction term is
  really needed. The short complex `0 → ℤ --(·k)--> ℤ` of `ℤ`-modules is exact (multiplication by
  `k ≠ 0` is injective, i.e. `H₁` of the two-term complex vanishes), yet after tensoring with
  `ZMod k` (`k ≥ 2`) it is no longer exact: a nonzero class survives, which is exactly the
  `Tor₁(ZMod k, ZMod k)`-term of the universal coefficient sequence.
-/

universe u v

open CategoryTheory MonoidalCategory Limits HomologicalComplex
open scoped TensorProduct

namespace Catalog.DerivedFunctors

section Flat

variable {R : Type u} [CommRing R] (G : ModuleCat.{u} R) [Module.Flat R G]
  {ι : Type v} {c : ComplexShape ι}

/-- **Universal coefficient theorem, flat coefficients.**
For a flat module `G` the homology of `G ⊗ C` is `G ⊗ H(C)`. -/
noncomputable def homologyTensorFlatIso (K : HomologicalComplex (ModuleCat.{u} R) c) (n : ι) :
    (((tensorLeft G).mapHomologicalComplex c).obj K).homology n ≅
      (tensorLeft G).obj (K.homology n) :=
  (K.sc n).mapHomologyIso (tensorLeft G)

/-- The `R`-linear isomorphism version of `homologyTensorFlatIso`. -/
noncomputable def homologyTensorFlatLinearEquiv (K : HomologicalComplex (ModuleCat.{u} R) c)
    (n : ι) :
    (((tensorLeft G).mapHomologicalComplex c).obj K).homology n ≃ₗ[R]
      G ⊗[R] (K.homology n) :=
  (homologyTensorFlatIso G K n).toLinearEquiv

/-- Tensoring with a flat module preserves acyclicity. -/
theorem homology_tensor_eq_zero_of_flat (K : HomologicalComplex (ModuleCat.{u} R) c) (n : ι)
    (hK : ∀ x : K.homology n, x = 0)
    (x : (((tensorLeft G).mapHomologicalComplex c).obj K).homology n) : x = 0 := by
  haveI : Subsingleton (K.homology n) := ⟨fun a b => by rw [hK a, hK b]⟩
  have h : IsZero (K.homology n) := ModuleCat.isZero_of_subsingleton _
  have h' : IsZero ((tensorLeft G).obj (K.homology n)) := Functor.map_isZero (tensorLeft G) h
  haveI : Subsingleton ((tensorLeft G).obj (K.homology n)) :=
    ModuleCat.isZero_iff_subsingleton.1 h'
  refine (homologyTensorFlatIso G K n).toLinearEquiv.injective ?_
  rw [map_zero]
  exact Subsingleton.elim _ _

end Flat

section NotFlat

/-- Multiplication by `k` on `ℤ`, as a short complex `0 → ℤ → ℤ`. -/
noncomputable def mulShortComplex (k : ℕ) : ShortComplex (ModuleCat.{0} ℤ) :=
  ShortComplex.mk (0 : ModuleCat.of ℤ PUnit ⟶ ModuleCat.of ℤ ℤ)
    (ModuleCat.ofHom ((k : ℤ) • LinearMap.id)) (by simp)

/-- The short complex `0 → ℤ --(·k)--> ℤ` is exact for `k ≠ 0`: multiplication by `k` is
injective, i.e. the two-term complex `ℤ --(·k)--> ℤ` has vanishing `H₁`. -/
theorem mulShortComplex_exact (k : ℕ) (hk : k ≠ 0) : (mulShortComplex k).Exact := by
  rw [ShortComplex.moduleCat_exact_iff]
  intro x hx
  refine ⟨0, ?_⟩
  have hx' : (k : ℤ) * (show ℤ from x) = 0 := by
    simpa [mulShortComplex, mul_comm] using hx
  have : (show ℤ from x) = 0 :=
    (mul_eq_zero.1 hx').resolve_left (Int.natCast_ne_zero.mpr hk)
  simpa [mulShortComplex] using this.symm

/-- **The correction term in the universal coefficient theorem is genuinely needed.**
Although `0 → ℤ --(·k)--> ℤ` is exact, tensoring with the (non-flat) coefficient module `ZMod k`
destroys exactness for `k ≥ 2`: the class of `1 ⊗ 1` is a nonzero cycle which is not a boundary.
This surviving class is the `Tor₁`-term of the universal coefficient sequence. -/
theorem tensor_zmod_not_exact (k : ℕ) (hk : 2 ≤ k) :
    ¬ ((mulShortComplex k).map (tensorLeft (ModuleCat.of ℤ (ZMod k)))).Exact := by
  intro hex
  rw [ShortComplex.moduleCat_exact_iff] at hex
  set x : (ZMod k) ⊗[ℤ] ℤ := (1 : ZMod k) ⊗ₜ[ℤ] (1 : ℤ) with hxdef
  have hgx : (ConcreteCategory.hom ((mulShortComplex k).map
      (tensorLeft (ModuleCat.of ℤ (ZMod k)))).g) x = 0 := by
    show ((ModuleCat.of ℤ (ZMod k)) ◁ (ModuleCat.ofHom ((k : ℤ) • LinearMap.id)))
      ((1 : ZMod k) ⊗ₜ[ℤ] (1 : ℤ)) = 0
    rw [ModuleCat.MonoidalCategory.whiskerLeft_apply]
    show (1 : ZMod k) ⊗ₜ[ℤ] ((k : ℤ) • (1 : ℤ)) = 0
    rw [TensorProduct.tmul_smul, TensorProduct.smul_tmul']
    have hz : ((k : ℤ) • (1 : ZMod k)) = 0 := by simp [zsmul_eq_mul]
    rw [hz, TensorProduct.zero_tmul]
  obtain ⟨y, hy⟩ := hex x hgx
  have hf : (ConcreteCategory.hom ((mulShortComplex k).map
      (tensorLeft (ModuleCat.of ℤ (ZMod k)))).f) y = 0 := by
    simp [mulShortComplex]
  have hx0 : x = 0 := by rw [← hy, hf]
  have h1 : (TensorProduct.rid ℤ (ZMod k)) ((1 : ZMod k) ⊗ₜ[ℤ] (1 : ℤ)) = 0 := by
    rw [← hxdef, hx0]; simp
  simp at h1
  haveI : Fact (1 < k) := ⟨by omega⟩
  exact one_ne_zero h1

end NotFlat

end Catalog.DerivedFunctors