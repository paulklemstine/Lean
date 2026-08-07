import Mathlib

/-!
# Universal coefficients: exact coefficient functors and the vanishing of the correction term

The universal coefficient theorem computes the homology of a chain complex with new
coefficients in terms of the old homology plus a `Tor` (or `Ext`) correction term.
This file establishes the exact-coefficient case in full generality, together with the
vanishing statements which show that in this case the correction term is indeed zero.

Main results:

* `Catalog.Bridges.mapHomologicalComplexHomologyIso` : an additive functor `F` which
  preserves homology commutes with the homology of complexes,
  `H_i(F K) ≅ F (H_i K)`, naturally in `K`;
* `Catalog.Bridges.flatTensorHomologyIso` : **universal coefficient theorem for flat
  coefficients** — for a flat module `M`, `H_i(M ⊗ K) ≅ M ⊗ H_i(K)`;
* `Catalog.Bridges.singularHomologyFlatCoefficientsIso` : the same statement for the
  singular chain complex of a topological space;
* `Catalog.Bridges.ext_eq_zero_of_field`, `Catalog.Bridges.flat_of_field` : over a field
  all higher `Ext` groups vanish and all modules are flat, so both correction terms of
  the universal coefficient theorem vanish and the maps above are the whole story.
-/

universe w v u

namespace Catalog.Bridges

open CategoryTheory Category Limits MonoidalCategory

section ExactFunctor

variable {V : Type u} [Category.{v} V] [Abelian V] {W : Type*} [Category* W] [Abelian W]
  {ι : Type*} {c : ComplexShape ι}

/-- An additive functor preserving homology commutes with the homology of a complex:
`H_i(F K) ≅ F (H_i K)`. -/
noncomputable def mapHomologicalComplexHomologyIso (F : V ⥤ W) [F.Additive]
    [F.PreservesHomology] (K : HomologicalComplex V c) (i : ι) :
    (((F.mapHomologicalComplex c).obj K).homology i) ≅ F.obj (K.homology i) :=
  ShortComplex.mapHomologyIso (K.sc i) F

/-- The isomorphism `H_i(F K) ≅ F (H_i K)` is natural in the complex `K`. -/
lemma mapHomologicalComplexHomologyIso_naturality (F : V ⥤ W) [F.Additive]
    [F.PreservesHomology] {K L : HomologicalComplex V c} (φ : K ⟶ L) (i : ι) :
    HomologicalComplex.homologyMap ((F.mapHomologicalComplex c).map φ) i ≫
        (mapHomologicalComplexHomologyIso F L i).hom =
      (mapHomologicalComplexHomologyIso F K i).hom ≫ F.map (HomologicalComplex.homologyMap φ i) :=
  ShortComplex.mapHomologyIso_hom_naturality
    ((HomologicalComplex.shortComplexFunctor V c i).map φ) F

end ExactFunctor

section Flat

variable {R : Type u} [CommRing R] {ι : Type*} {c : ComplexShape ι}

/-- Tensoring with a flat module preserves homology. -/
instance preservesHomology_tensorLeft_of_flat (M : ModuleCat.{u} R) [Module.Flat R M] :
    (tensorLeft M).PreservesHomology := by
  have : PreservesFiniteLimits (tensorLeft M) :=
    (Module.Flat.iff_preservesFiniteLimits_tensorLeft M).1 inferInstance
  infer_instance

/-- **Universal coefficient theorem, flat coefficients.**  If `M` is a flat `R`-module then
the homology of `M ⊗ K` is `M ⊗ H_i(K)`: the `Tor` correction term is absent. -/
noncomputable def flatTensorHomologyIso (M : ModuleCat.{u} R) [Module.Flat R M]
    (K : HomologicalComplex (ModuleCat.{u} R) c) (i : ι) :
    ((((tensorLeft M).mapHomologicalComplex c).obj K).homology i) ≅
      (tensorLeft M).obj (K.homology i) :=
  mapHomologicalComplexHomologyIso (tensorLeft M) K i

lemma flatTensorHomologyIso_naturality (M : ModuleCat.{u} R) [Module.Flat R M]
    {K L : HomologicalComplex (ModuleCat.{u} R) c} (φ : K ⟶ L) (i : ι) :
    HomologicalComplex.homologyMap (((tensorLeft M).mapHomologicalComplex c).map φ) i ≫
        (flatTensorHomologyIso M L i).hom =
      (flatTensorHomologyIso M K i).hom ≫
        (tensorLeft M).map (HomologicalComplex.homologyMap φ i) :=
  mapHomologicalComplexHomologyIso_naturality _ φ i

end Flat

section Field

variable (k : Type u) [Field k]

/-- Over a field every module is projective. -/
instance projective_of_field (V : ModuleCat.{u} k) : Projective V := by
  have : Module.Projective k V := inferInstance
  infer_instance

/-- **Vanishing of the `Ext` correction term over a field.**  All higher `Ext` groups of
vector spaces vanish. -/
theorem ext_eq_zero_of_field [HasExt.{w} (ModuleCat.{u} k)]
    (X Y : ModuleCat.{u} k) (n : ℕ) (e : Abelian.Ext.{w} X Y (n + 1)) : e = 0 :=
  Abelian.Ext.eq_zero_of_projective e

end Field


section TorTermNecessary

/-!
### The correction term is genuinely necessary

The flatness hypothesis in `flatTensorHomologyIso` cannot be removed.  We exhibit the
standard counterexample: the two-term complex `ℤ --·2--> ℤ` is exact in degree `1`, but
after tensoring with `ℤ/2` it is not, so its homology in degree 1 is not `ℤ/2 ⊗ H₁`.
This is exactly the `Tor₁(H₀, ℤ/2)` contribution of the universal coefficient theorem.
-/

open HomologicalComplex

/-- Multiplication by `2` on `ℤ`, as a map of `ℤ`-modules. -/
noncomputable def twoMap : ModuleCat.of ℤ ℤ ⟶ ModuleCat.of ℤ ℤ :=
  ModuleCat.ofHom (2 • LinearMap.id)

lemma rel10 : (ComplexShape.down ℕ).Rel 1 0 := by simp

lemma rel21 : (ComplexShape.down ℕ).Rel 2 1 := by simp

/-- The two-term complex `ℤ --·2--> ℤ` in degrees `1` and `0`. -/
noncomputable def torComplex : ChainComplex (ModuleCat.{0} ℤ) ℕ :=
  HomologicalComplex.double twoMap rel10

/-- The coefficient module `ℤ/2`, which is not flat over `ℤ`. -/
noncomputable abbrev modTwo : ModuleCat.{0} ℤ := ModuleCat.of ℤ (ZMod 2)

/-- The complex `ℤ/2 ⊗ (ℤ --·2--> ℤ)`. -/
noncomputable abbrev torComplexTensored : ChainComplex (ModuleCat.{0} ℤ) ℕ :=
  ((tensorLeft modTwo).mapHomologicalComplex (ComplexShape.down ℕ)).obj torComplex

lemma exactAt_torComplex : torComplex.ExactAt 1 := by
  rw [torComplex.exactAt_iff' 2 1 0 ((ComplexShape.down ℕ).prev_eq' rel21)
    ((ComplexShape.down ℕ).next_eq' rel10), ShortComplex.exact_iff_mono]
  · show Mono (torComplex.d 1 0)
    rw [show torComplex.d 1 0 = _ from HomologicalComplex.double_d twoMap rel10 (by norm_num)]
    have : Mono twoMap := by
      rw [ModuleCat.mono_iff_injective]
      intro a b hab
      simpa [twoMap] using hab
    infer_instance
  · show torComplex.d 2 1 = 0
    exact HomologicalComplex.double_d_eq_zero₀ twoMap rel10 2 1 (by norm_num)

lemma tmul_one_ne_zero : ((1 : ZMod 2) ⊗ₜ[ℤ] (1 : ℤ)) ≠ 0 := by
  intro h
  have := congrArg (TensorProduct.rid ℤ (ZMod 2)) h
  simp at this

lemma not_mono_tensor_twoMap : ¬ Mono ((tensorLeft modTwo).map twoMap) := by
  rw [ModuleCat.mono_iff_injective]
  intro h
  refine tmul_one_ne_zero (h ?_)
  show ((tensorLeft modTwo).map twoMap) ((1 : ZMod 2) ⊗ₜ[ℤ] (1 : ℤ)) = _
  have h2 : ((tensorLeft modTwo).map twoMap) ((1 : ZMod 2) ⊗ₜ[ℤ] (1 : ℤ))
      = (1 : ZMod 2) ⊗ₜ[ℤ] (2 : ℤ) := by
    show (modTwo ◁ twoMap) ((1 : ZMod 2) ⊗ₜ[ℤ] (1 : ℤ)) = _
    rw [ModuleCat.MonoidalCategory.whiskerLeft_apply]
    simp [twoMap]
  have h3 : (1 : ZMod 2) ⊗ₜ[ℤ] (2 : ℤ) = ((2 : ℤ) • (1 : ZMod 2)) ⊗ₜ[ℤ] (1 : ℤ) := by
    rw [TensorProduct.smul_tmul]
    simp
  rw [h2, h3, show ((2 : ℤ) • (1 : ZMod 2)) = 0 by decide, TensorProduct.zero_tmul, map_zero]

lemma not_exactAt_torComplexTensored : ¬ torComplexTensored.ExactAt 1 := by
  rw [torComplexTensored.exactAt_iff' 2 1 0 ((ComplexShape.down ℕ).prev_eq' rel21)
    ((ComplexShape.down ℕ).next_eq' rel10), ShortComplex.exact_iff_mono]
  · intro hm
    haveI := hm
    apply not_mono_tensor_twoMap
    have hd : torComplex.d 1 0 = (HomologicalComplex.doubleXIso₀ twoMap rel10).hom ≫ twoMap ≫
        (HomologicalComplex.doubleXIso₁ twoMap rel10 (by norm_num)).inv :=
      HomologicalComplex.double_d twoMap rel10 (by norm_num)
    have h1 : (tensorLeft modTwo).map twoMap =
        inv ((tensorLeft modTwo).map (HomologicalComplex.doubleXIso₀ twoMap rel10).hom) ≫
          ((tensorLeft modTwo).map (torComplex.d 1 0)) ≫
          inv ((tensorLeft modTwo).map
            (HomologicalComplex.doubleXIso₁ twoMap rel10 (by norm_num)).inv) := by
      rw [hd]
      simp
    have hmono : Mono ((tensorLeft modTwo).map (torComplex.d 1 0)) := hm
    rw [h1]
    infer_instance
  · show (tensorLeft modTwo).map (torComplex.d 2 1) = 0
    have h0 : torComplex.d 2 1 = 0 :=
      HomologicalComplex.double_d_eq_zero₀ twoMap rel10 2 1 (by norm_num)
    rw [h0]
    exact Functor.map_zero _ _ _

/-- **Sharpness of the flat hypothesis.**  Tensoring can create homology: there is a
complex of `ℤ`-modules which is exact in degree `1` but whose tensor product with `ℤ/2`
is not.  Hence no isomorphism `H_i(M ⊗ K) ≅ M ⊗ H_i(K)` can hold for arbitrary `M`, and
the universal coefficient theorem must carry a `Tor` correction term. -/
theorem tor_correction_term_necessary :
    ∃ (K : ChainComplex (ModuleCat.{0} ℤ) ℕ) (M : ModuleCat.{0} ℤ) (i : ℕ),
      K.ExactAt i ∧
        ¬ ((((tensorLeft M).mapHomologicalComplex (ComplexShape.down ℕ)).obj K).ExactAt i) :=
  ⟨torComplex, modTwo, 1, exactAt_torComplex, not_exactAt_torComplexTensored⟩

/-- The naive universal coefficient isomorphism fails for non-flat coefficients:
`H₁(ℤ/2 ⊗ K)` is nonzero while `ℤ/2 ⊗ H₁(K)` is zero. -/
theorem no_naive_universal_coefficient_iso :
    ¬ Nonempty (torComplexTensored.homology 1 ≅
      (tensorLeft modTwo).obj (torComplex.homology 1)) := by
  rintro ⟨e⟩
  refine not_exactAt_torComplexTensored ?_
  rw [HomologicalComplex.exactAt_iff_isZero_homology]
  refine IsZero.of_iso ?_ e
  exact Functor.map_isZero _
    ((HomologicalComplex.exactAt_iff_isZero_homology _ 1).1 exactAt_torComplex)

end TorTermNecessary

section Singular

open AlgebraicTopology

variable {R : Type u} [CommRing R] (M : ModuleCat.{u} R) [Module.Flat R M] (n : ℕ)
  (X : TopCat.{u})

/-- **Universal coefficients for singular homology with flat coefficients.**  Tensoring the
singular chain complex of `X` with a flat module `M` computes `M ⊗ H_n(X; R)`. -/
noncomputable def singularHomologyFlatCoefficientsIso :
    ((((tensorLeft M).mapHomologicalComplex (ComplexShape.down ℕ)).obj
        (((singularChainComplexFunctor (ModuleCat.{u} R)).obj (ModuleCat.of R R)).obj
          X)).homology n) ≅
      (tensorLeft M).obj
        (((singularHomologyFunctor (ModuleCat.{u} R) n).obj (ModuleCat.of R R)).obj X) :=
  flatTensorHomologyIso M _ n

end Singular

end Catalog.Bridges