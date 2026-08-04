import Algebra.DerivedFunctors.Ext

/-!
# `Ext¹(ℤ/k, Y)` is `Y/kY`

Dually to the computation `Tor₁(G, ℤ/k) ≅ G[k]` of `Algebra.DerivedFunctors.TorZMod`, we compute
the first `Ext`-group out of a cyclic group.  Using the short exact sequence
`0 → ℤ --(·k)--> ℤ → ℤ/k → 0` and its class in `Ext¹(ℤ/k, ℤ)` we build the map

`Y → Ext¹(ℤ/k, Y)`,  `y ↦ extClass ∘ (1 ↦ y)`

and show that it is an additive surjection whose kernel is exactly `kY`.  Consequently

`Ext¹(ℤ/k, Y) ≅ Y/kY`  (`Catalog.DerivedFunctors.extOneZModEquiv`).

Specialising to `Y = ℤ` recovers `Ext¹(ℤ/k, ℤ) ≅ ℤ/k`.
-/

open CategoryTheory Abelian Limits

namespace Catalog.DerivedFunctors

variable (k : ℕ) (hk : k ≠ 0) (Y : ModuleCat.{0} ℤ)

/-- The map `Y → Ext¹(ℤ/k, Y)` sending `y` to the class of the extension
`0 → ℤ → ℤ → ℤ/k → 0` pushed forward along `1 ↦ y`. -/
noncomputable def extOneOfElt (y : Y) : Ext (ModuleCat.of ℤ (ZMod k)) Y 1 :=
  (zmodShortComplex_shortExact k hk).extClass.comp (Ext.mk₀ (homOfElt Y y)) (add_zero 1)

lemma extOneOfElt_add (y z : Y) :
    extOneOfElt k hk Y (y + z) = extOneOfElt k hk Y y + extOneOfElt k hk Y z := by
  have h : homOfElt Y (y + z) = homOfElt Y y + homOfElt Y z := by
    ext; simp [homOfElt, LinearMap.toSpanSingleton_apply]
  simp [extOneOfElt, h, Ext.mk₀_add, Ext.comp_add]

/-- `y ↦ extClass ∘ (1 ↦ y)` as a homomorphism of abelian groups `Y →+ Ext¹(ℤ/k, Y)`. -/
noncomputable def extOneHom : Y →+ Ext (ModuleCat.of ℤ (ZMod k)) Y 1 :=
  AddMonoidHom.mk' (extOneOfElt k hk Y) (extOneOfElt_add k hk Y)

@[simp] lemma extOneHom_apply (y : Y) : extOneHom k hk Y y = extOneOfElt k hk Y y := rfl

/-- **Every class in `Ext¹(ℤ/k, Y)` comes from an element of `Y`.** -/
theorem extOneHom_surjective : Function.Surjective (extOneHom k hk Y) := by
  intro x
  have hS := zmodShortComplex_shortExact k hk
  haveI : Projective (zmodShortComplex k).X₁ := inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  haveI : Projective (zmodShortComplex k).X₂ := inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  obtain ⟨x₁, hx₁⟩ := Ext.contravariant_sequence_exact₃ (S := zmodShortComplex k) hS Y x
    (Ext.eq_zero_of_projective _) (n₀ := 0) (by omega)
  refine ⟨(ModuleCat.Hom.hom (Ext.homEquiv₀ (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₁))) 1, ?_⟩
  rw [extOneHom_apply, extOneOfElt, ← hx₁]
  congr 1
  rw [← hom_eq_homOfElt]
  exact Ext.mk₀_homEquiv₀_apply (show Ext (ModuleCat.of ℤ ℤ) Y 0 from x₁)

/-- A class `extOneOfElt y` vanishes exactly when `y` is divisible by `k`. -/
theorem extOneOfElt_eq_zero_iff (y : Y) :
    extOneOfElt k hk Y y = 0 ↔ ∃ z : Y, (k : ℤ) • z = y := by
  constructor
  · intro h
    have hS := zmodShortComplex_shortExact k hk
    obtain ⟨x₂, hx₂⟩ := Ext.contravariant_sequence_exact₁ (S := zmodShortComplex k) hS Y
      (n₀ := 0) (x₁ := Ext.mk₀ (homOfElt Y y)) (n₁ := 1) (by omega) h
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
  · rintro ⟨z, hz⟩
    have hS := zmodShortComplex_shortExact k hk
    have key : (Ext.mk₀ (zmodShortComplex k).f).comp (Ext.mk₀ (homOfElt Y z)) (zero_add 0)
        = Ext.mk₀ (homOfElt Y y) := by
      rw [Ext.mk₀_comp_mk₀]
      show Ext.mk₀ (mulZ k ≫ homOfElt Y z) = _
      rw [mulZ_comp_homOfElt, hz]
    rw [extOneOfElt, ← key]
    exact hS.extClass_comp_assoc _

/-- The subgroup `kY ⊆ Y`. -/
def smulSubgroup : AddSubgroup Y :=
  AddMonoidHom.range
    (AddMonoidHom.mk' (fun z : Y => (k : ℤ) • z) (fun a b => by simp [smul_add]))

@[simp] lemma mem_smulSubgroup {y : Y} :
    y ∈ smulSubgroup k Y ↔ ∃ z : Y, (k : ℤ) • z = y := Iff.rfl

/-- The kernel of `y ↦ extClass ∘ (1 ↦ y)` is exactly `kY`. -/
theorem ker_extOneHom : (extOneHom k hk Y).ker = smulSubgroup k Y := by
  ext y
  simpa [AddMonoidHom.mem_ker] using extOneOfElt_eq_zero_iff k hk Y y

/-- **`Ext¹(ℤ/k, Y) ≅ Y/kY`.**  For `k ≠ 0` the first `Ext`-group out of the cyclic group `ℤ/k`
is the cokernel of multiplication by `k` on `Y`. -/
noncomputable def extOneZModEquiv :
    (Y ⧸ smulSubgroup k Y) ≃+ Ext (ModuleCat.of ℤ (ZMod k)) Y 1 :=
  (QuotientAddGroup.quotientAddEquivOfEq (ker_extOneHom k hk Y)).symm.trans
    (QuotientAddGroup.quotientKerEquivOfSurjective _ (extOneHom_surjective k hk Y))

end Catalog.DerivedFunctors