import Mathlib
import Bridges.UniversalCoefficients

/-!
# Flatness is exactly the vanishing locus of the universal-coefficient correction term

`Catalog/Bridges/UniversalCoefficients.lean` proves the "easy" half of the universal
coefficient theorem: if `M` is flat then `H_i(M ⊗ K) ≅ M ⊗ H_i(K)` for every complex `K`
(`Catalog.Bridges.flatTensorHomologyIso`), and it exhibits one explicit failure of this
statement for the non-flat module `ℤ/2`.

This file closes the converse, which was Conjecture 4 of `FUTURE_DIRECTIONS.md`: the
correction term vanishes for *all* complexes **only if** `M` is flat, and moreover the
two-term complexes already detect this.  The two headline results are

* `Catalog.Bridges.flat_iff_tensorLeft_preserves_exactAt` — `M` is flat iff `M ⊗ -`
  preserves exactness of chain complexes of `R`-modules in every degree;
* `Catalog.Bridges.flat_iff_tensor_homology_iso` — `M` is flat iff for every chain
  complex `K` and every degree `i` there is *some* isomorphism
  `H_i(M ⊗ K) ≅ M ⊗ H_i(K)`.

The mechanism is that a two-term complex `X₀ --f--> X₁` is exact in the degree carrying
`X₀` exactly when `f` is a monomorphism, so running the hypothesis on
`HomologicalComplex.double` converts "no correction term" into "`M ⊗ -` preserves
monomorphisms", which is one of the standard characterisations of flatness.
-/

universe v u

namespace Catalog.Bridges

open CategoryTheory Category Limits MonoidalCategory HomologicalComplex

section Double

variable {V : Type u} [Category.{v} V] [Abelian V] {ι : Type*} {c : ComplexShape ι}
  {i₀ i₁ : ι} (hi : c.Rel i₀ i₁)

/-- The differential of a two-term complex `X₀ --f--> X₁` landing in the *source* degree
`i₀` is zero, provided the two degrees are distinct. -/
lemma double_d_to_source {X₀ X₁ : V} (f : X₀ ⟶ X₁) (hne : i₀ ≠ i₁) (a : ι) :
    (double f hi).d a i₀ = 0 :=
  double_d_eq_zero₁ f hi a i₀ hne

/-- The two-term complex `X₀ --f--> X₁` is exact in the degree `i₀` carrying `X₀` exactly
when its differential is a monomorphism. -/
lemma exactAt_double_iff_mono {X₀ X₁ : V} (f : X₀ ⟶ X₁) (hne : i₀ ≠ i₁) :
    (double f hi).ExactAt i₀ ↔ Mono ((double f hi).d i₀ i₁) := by
  rw [(double f hi).exactAt_iff' (c.prev i₀) i₀ i₁ rfl (c.next_eq' hi),
    ShortComplex.exact_iff_mono _ (double_d_to_source hi f hne _)]
  exact Iff.rfl

/-- **A two-term complex is exact in its source degree iff its differential is monic.**
For `f` a monomorphism, the complex `X₀ --f--> X₁` is exact at `i₀`. -/
lemma exactAt_double_of_mono {X₀ X₁ : V} (f : X₀ ⟶ X₁) [Mono f] (hne : i₀ ≠ i₁) :
    (double f hi).ExactAt i₀ := by
  rw [exactAt_double_iff_mono hi f hne, double_d f hi hne]
  infer_instance

variable {W : Type*} [Category* W] [Abelian W]

/-- If an additive functor `F` sends the two-term complex `X₀ --f--> X₁` to a complex
which is exact in degree `i₀`, then `F f` is a monomorphism. -/
lemma mono_map_of_exactAt_mapDouble (F : V ⥤ W) [F.Additive] {X₀ X₁ : V} (f : X₀ ⟶ X₁)
    (hne : i₀ ≠ i₁)
    (h : (((F.mapHomologicalComplex c).obj (double f hi)).ExactAt i₀)) :
    Mono (F.map f) := by
  rw [((F.mapHomologicalComplex c).obj (double f hi)).exactAt_iff'
    (c.prev i₀) i₀ i₁ rfl (c.next_eq' hi), ShortComplex.exact_iff_mono] at h
  · have hmono : Mono (F.map ((double f hi).d i₀ i₁)) := h
    have hd : F.map ((double f hi).d i₀ i₁) =
        F.map (doubleXIso₀ f hi).hom ≫ F.map f ≫ F.map (doubleXIso₁ f hi hne).inv := by
      rw [double_d f hi hne, F.map_comp, F.map_comp]
    have hfac : F.map f =
        inv (F.map (doubleXIso₀ f hi).hom) ≫ F.map ((double f hi).d i₀ i₁) ≫
          inv (F.map (doubleXIso₁ f hi hne).inv) := by
      rw [hd]; simp
    rw [hfac]
    infer_instance
  · show F.map ((double f hi).d (c.prev i₀) i₀) = 0
    rw [double_d_to_source hi f hne, F.map_zero]

end Double

section FlatCriterion

variable {R : Type u} [CommRing R]

lemma rel_down_one_zero : (ComplexShape.down ℕ).Rel 1 0 := by simp

/-- Left-tensoring, read on underlying linear maps. -/
lemma tensorLeft_map_hom (M : ModuleCat.{u} R) {A B : ModuleCat.{u} R} (f : A ⟶ B) :
    ((tensorLeft M).map f).hom = LinearMap.lTensor M f.hom :=
  ModuleCat.hom_whiskerLeft M f

/-- If `M ⊗ -` preserves monomorphisms of `R`-modules, then `M` is flat. -/
theorem flat_of_mono_tensorLeft_map (M : ModuleCat.{u} R)
    (h : ∀ {A B : ModuleCat.{u} R} (f : A ⟶ B), Mono f → Mono ((tensorLeft M).map f)) :
    Module.Flat R M := by
  rw [Module.Flat.iff_lTensor_preserves_injective_linearMap]
  intro N N' _ _ _ _ f hf
  have hmono : Mono (ModuleCat.ofHom f : ModuleCat.of R N ⟶ ModuleCat.of R N') := by
    rw [ModuleCat.mono_iff_injective]
    exact hf
  have := h (ModuleCat.ofHom f) hmono
  rw [ModuleCat.mono_iff_injective] at this
  simpa [tensorLeft_map_hom] using this

/-- **Flatness is exactly preservation of exactness of complexes.**  A module `M` is flat
if and only if `M ⊗ -` carries every chain complex which is exact in a degree to a complex
which is exact in that degree. -/
theorem flat_iff_tensorLeft_preserves_exactAt (M : ModuleCat.{u} R) :
    Module.Flat R M ↔
      ∀ (K : ChainComplex (ModuleCat.{u} R) ℕ) (i : ℕ), K.ExactAt i →
        ((((tensorLeft M).mapHomologicalComplex (ComplexShape.down ℕ)).obj K).ExactAt i) := by
  constructor
  · intro hM K i hK
    rw [HomologicalComplex.exactAt_iff_isZero_homology] at hK ⊢
    refine IsZero.of_iso ?_ (flatTensorHomologyIso M K i)
    exact Functor.map_isZero _ hK
  · intro h
    refine flat_of_mono_tensorLeft_map M ?_
    intro A B f hf
    refine mono_map_of_exactAt_mapDouble rel_down_one_zero (tensorLeft M) f one_ne_zero ?_
    exact h _ 1 (exactAt_double_of_mono rel_down_one_zero f one_ne_zero)

/-- **Conjecture 4, resolved: the universal-coefficient correction term vanishes for all
complexes precisely when the coefficient module is flat.**  Moreover the two-term
complexes `X₀ --f--> X₁` already suffice as test objects: they are what the proof of the
backwards direction feeds to the hypothesis. -/
theorem flat_iff_tensor_homology_iso (M : ModuleCat.{u} R) :
    Module.Flat R M ↔
      ∀ (K : ChainComplex (ModuleCat.{u} R) ℕ) (i : ℕ),
        Nonempty (((((tensorLeft M).mapHomologicalComplex (ComplexShape.down ℕ)).obj
            K).homology i) ≅ (tensorLeft M).obj (K.homology i)) := by
  constructor
  · intro hM K i
    exact ⟨flatTensorHomologyIso M K i⟩
  · intro h
    rw [flat_iff_tensorLeft_preserves_exactAt]
    intro K i hK
    obtain ⟨e⟩ := h K i
    rw [HomologicalComplex.exactAt_iff_isZero_homology] at hK ⊢
    exact IsZero.of_iso (Functor.map_isZero _ hK) e

/-- **Two-term complexes are enough test objects.**  `M` is flat as soon as `M ⊗ -`
preserves exactness of the two-term complexes `X₀ --f--> X₁` (in degree `1`), and
conversely. -/
theorem flat_iff_tensorLeft_exactAt_double (M : ModuleCat.{u} R) :
    Module.Flat R M ↔
      ∀ (A B : ModuleCat.{u} R) (f : A ⟶ B), Mono f →
        ((((tensorLeft M).mapHomologicalComplex (ComplexShape.down ℕ)).obj
          (double f rel_down_one_zero)).ExactAt 1) := by
  constructor
  · intro hM A B f hf
    haveI := hf
    exact (flat_iff_tensorLeft_preserves_exactAt M).1 hM _ 1
      (exactAt_double_of_mono rel_down_one_zero f one_ne_zero)
  · intro h
    refine flat_of_mono_tensorLeft_map M ?_
    intro A B f hf
    exact mono_map_of_exactAt_mapDouble rel_down_one_zero (tensorLeft M) f one_ne_zero
      (h A B f hf)

end FlatCriterion

end Catalog.Bridges