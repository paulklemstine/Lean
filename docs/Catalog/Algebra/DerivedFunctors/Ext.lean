import Algebra.DerivedFunctors.Resolutions

/-!
# Computations of `Ext`-groups of `ℤ`-modules

Using the two concrete resolutions built in `Algebra.DerivedFunctors.Resolutions` together
with the long exact sequences for `Ext` we compute:

* `Catalog.DerivedFunctors.ext_zmod_eq_zero`: `Extⁿ(ZMod k, Y) = 0` for `n ≥ 2`
  (the cyclic group `ZMod k`, `k ≠ 0`, has projective dimension at most one);
* `Catalog.DerivedFunctors.ext_int_eq_zero`: `Extⁿ(X, ℤ) = 0` for `n ≥ 2`
  (the `ℤ`-module `ℤ` has injective dimension at most one);
* `Catalog.DerivedFunctors.ext_one_zmod_eq_zero_iff`: `Ext¹(ZMod k, Y) = 0` if and only if
  the module `Y` is `k`-divisible;
* consequences: `Ext¹(ZMod k, ℚ) = 0` and `Ext¹(ZMod k, ℤ) ≠ 0` for `k ≥ 2`.
-/

universe u

open CategoryTheory Abelian Limits

namespace Catalog.DerivedFunctors

/-- **Projective dimension one.** For `k ≠ 0` the cyclic module `ZMod k` admits the length-one
free resolution `0 → ℤ → ℤ → ZMod k → 0`, so all higher `Ext`-groups out of it vanish. -/
theorem ext_zmod_eq_zero (k : ℕ) (hk : k ≠ 0) (Y : ModuleCat.{0} ℤ) (n : ℕ)
    (x : Ext (ModuleCat.of ℤ (ZMod k)) Y (n + 2)) : x = 0 := by
  have hS := zmodShortComplex_shortExact k hk
  haveI : Projective (zmodShortComplex k).X₁ := inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  haveI : Projective (zmodShortComplex k).X₂ := inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  obtain ⟨x₁, hx₁⟩ := Ext.contravariant_sequence_exact₃ (S := zmodShortComplex k) hS Y x
    (Ext.eq_zero_of_projective _) (n₀ := n + 1) (by omega)
  rw [← hx₁, show x₁ = 0 from Ext.eq_zero_of_projective x₁]
  simp

/-- **Injective dimension one.** `ℤ` admits the length-one injective resolution
`0 → ℤ → ℚ → ℚ⧸ℤ → 0`, so all higher `Ext`-groups into it vanish. -/
theorem ext_int_eq_zero (X : ModuleCat.{0} ℤ) (n : ℕ)
    (x : Ext X (ModuleCat.of ℤ ℤ) (n + 2)) : x = 0 := by
  haveI : Injective qShortComplex.X₂ := inferInstanceAs (Injective (ModuleCat.of ℤ ℚ))
  haveI : Injective qShortComplex.X₃ := inferInstanceAs (Injective (ModuleCat.of ℤ QmodZ))
  obtain ⟨x₃, hx₃⟩ := Ext.covariant_sequence_exact₁ (S := qShortComplex) X
    qShortComplex_shortExact x (Ext.eq_zero_of_injective _) (n₀ := n + 1) (by omega)
  rw [← hx₃, show x₃ = 0 from Ext.eq_zero_of_injective x₃]
  simp

section OneDimensional

variable (Y : ModuleCat.{0} ℤ)

/-- The morphism of `ℤ`-modules `ℤ ⟶ Y` sending `1` to `y`. -/
noncomputable def homOfElt (y : Y) : ModuleCat.of ℤ ℤ ⟶ Y :=
  ModuleCat.ofHom (LinearMap.toSpanSingleton ℤ Y y)

@[simp] lemma homOfElt_apply_one (y : Y) : (ModuleCat.Hom.hom (homOfElt Y y)) 1 = y := by
  simp [homOfElt, LinearMap.toSpanSingleton_apply]

lemma hom_eq_homOfElt (h : ModuleCat.of ℤ ℤ ⟶ Y) :
    h = homOfElt Y ((ModuleCat.Hom.hom h) 1) := by
  ext
  show (ModuleCat.Hom.hom h) 1 = _
  simp [homOfElt, LinearMap.toSpanSingleton_apply]

lemma mulZ_comp_homOfElt (k : ℕ) (y : Y) :
    mulZ k ≫ homOfElt Y y = homOfElt Y ((k : ℤ) • y) := by
  ext
  show (ModuleCat.Hom.hom (homOfElt Y y)) ((k : ℤ) • (1 : ℤ)) = _
  simp only [homOfElt, ModuleCat.hom_ofHom, LinearMap.toSpanSingleton_apply]
  simp [Nat.cast_smul_eq_nsmul]

lemma homOfElt_injective {y z : Y} (h : homOfElt Y z = homOfElt Y y) : z = y := by
  have h' := congrArg (fun (f : ModuleCat.of ℤ ℤ ⟶ Y) => (ModuleCat.Hom.hom f) 1) h
  simpa [homOfElt, LinearMap.toSpanSingleton_apply] using h'

/-- If `Y` is `k`-divisible then `Ext¹(ZMod k, Y)` vanishes. -/
theorem ext_one_zmod_eq_zero_of_divisible (k : ℕ) (hk : k ≠ 0)
    (hdiv : ∀ y : Y, ∃ z : Y, (k : ℤ) • z = y) (x : Ext (ModuleCat.of ℤ (ZMod k)) Y 1) :
    x = 0 := by
  have hS := zmodShortComplex_shortExact k hk
  haveI : Projective (zmodShortComplex k).X₁ := inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  haveI : Projective (zmodShortComplex k).X₂ := inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  obtain ⟨x₁, hx₁⟩ := Ext.contravariant_sequence_exact₃ (S := zmodShortComplex k) hS Y x
    (Ext.eq_zero_of_projective _) (n₀ := 0) (by omega)
  obtain ⟨z, hz⟩ := hdiv
    ((ModuleCat.Hom.hom (Ext.homEquiv₀ (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₁))) 1)
  have key : (Ext.mk₀ (zmodShortComplex k).f).comp (Ext.mk₀ (homOfElt Y z)) (zero_add 0) = x₁ := by
    rw [Ext.mk₀_comp_mk₀]
    show Ext.mk₀ (mulZ k ≫ homOfElt Y z) = x₁
    rw [mulZ_comp_homOfElt, hz, ← hom_eq_homOfElt]
    exact Ext.mk₀_homEquiv₀_apply (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₁)
  rw [← hx₁, ← key]
  exact hS.extClass_comp_assoc _

/-- If `Ext¹(ZMod k, Y)` vanishes then `Y` is `k`-divisible. -/
theorem divisible_of_ext_one_zmod_eq_zero (k : ℕ) (hk : k ≠ 0)
    (hx : ∀ x : Ext (ModuleCat.of ℤ (ZMod k)) Y 1, x = 0) (y : Y) :
    ∃ z : Y, (k : ℤ) • z = y := by
  have hS := zmodShortComplex_shortExact k hk
  obtain ⟨x₂, hx₂⟩ := Ext.contravariant_sequence_exact₁ (S := zmodShortComplex k) hS Y
    (n₀ := 0) (x₁ := Ext.mk₀ (homOfElt Y y)) (n₁ := 1) (by omega) (hx _)
  refine ⟨(ModuleCat.Hom.hom (Ext.homEquiv₀ (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₂))) 1, ?_⟩
  have h1 : Ext.mk₀ (mulZ k ≫ Ext.homEquiv₀ (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₂))
      = Ext.mk₀ (homOfElt Y y) := by
    rw [← Ext.mk₀_comp_mk₀, Ext.mk₀_homEquiv₀_apply (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₂)]
    exact hx₂
  have h2 : mulZ k ≫ Ext.homEquiv₀ (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₂)
      = homOfElt Y y := (Ext.mk₀_bijective _ _).1 h1
  refine homOfElt_injective Y ?_
  rw [← mulZ_comp_homOfElt, ← hom_eq_homOfElt]
  exact h2

/-- **`Ext¹` out of a cyclic group detects divisibility.**
`Ext¹(ZMod k, Y) = 0` if and only if the `ℤ`-module `Y` is `k`-divisible. -/
theorem ext_one_zmod_eq_zero_iff (k : ℕ) (hk : k ≠ 0) :
    (∀ x : Ext (ModuleCat.of ℤ (ZMod k)) Y 1, x = 0) ↔ ∀ y : Y, ∃ z : Y, (k : ℤ) • z = y :=
  ⟨divisible_of_ext_one_zmod_eq_zero Y k hk, ext_one_zmod_eq_zero_of_divisible Y k hk⟩

end OneDimensional

section Examples

/-- `Ext¹(ZMod k, ℚ) = 0`: the divisible group `ℚ` has no nontrivial extension by a cyclic
group. -/
theorem ext_one_zmod_rat_eq_zero (k : ℕ) (hk : k ≠ 0)
    (x : Ext (ModuleCat.of ℤ (ZMod k)) (ModuleCat.of ℤ ℚ) 1) : x = 0 := by
  refine ext_one_zmod_eq_zero_of_divisible _ k hk (fun y => ⟨(y : ℚ) / (k : ℚ), ?_⟩) x
  have hk' : (k : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hk
  show ((k : ℤ) • ((y : ℚ) / (k : ℚ)) : ℚ) = y
  rw [zsmul_eq_mul]
  push_cast
  field_simp

/-- `Ext¹(ZMod k, ℤ) ≠ 0` for `k ≥ 2`: the extension `0 → ℤ → ℤ → ZMod k → 0` does not split. -/
theorem ext_one_zmod_int_ne_zero (k : ℕ) (hk : 2 ≤ k) :
    ∃ x : Ext (ModuleCat.of ℤ (ZMod k)) (ModuleCat.of ℤ ℤ) 1, x ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨z, hz⟩ := divisible_of_ext_one_zmod_eq_zero (ModuleCat.of ℤ ℤ) k (by omega) hcon 1
  have hz' : (k : ℤ) * z = 1 := by
    simpa [zsmul_eq_mul] using hz
  have hdvd : (k : ℤ) ∣ 1 := ⟨z, hz'.symm⟩
  have : (k : ℤ) ≤ 1 := Int.le_of_dvd one_pos hdvd
  omega

end Examples

end Catalog.DerivedFunctors