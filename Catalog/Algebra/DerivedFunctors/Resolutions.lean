import Mathlib

/-!
# Concrete projective and injective resolutions

This file constructs two concrete resolutions in the category of `ℤ`-modules
(equivalently, abelian groups):

* `Catalog.DerivedFunctors.zmodShortComplex k`: the short exact sequence
  `0 → ℤ --(·k)--> ℤ --(mod k)--> ZMod k → 0`, which is the standard length-one
  free (hence projective) resolution of the cyclic group `ZMod k` for `k ≠ 0`.

These are used in `Algebra.DerivedFunctors.Ext` to compute `Ext`-groups.
-/

universe u

open CategoryTheory Abelian Limits

namespace Catalog.DerivedFunctors

section ZMod

variable (k : ℕ)

/-- Multiplication by `k` on `ℤ`, as a morphism of `ℤ`-modules. -/
noncomputable def mulZ : ModuleCat.of ℤ ℤ ⟶ ModuleCat.of ℤ ℤ :=
  ModuleCat.ofHom ((k : ℤ) • LinearMap.id)

/-- Reduction modulo `k`, as a morphism of `ℤ`-modules. -/
noncomputable def redZ : ModuleCat.of ℤ ℤ ⟶ ModuleCat.of ℤ (ZMod k) :=
  ModuleCat.ofHom (Int.castAddHom (ZMod k)).toIntLinearMap

@[simp] lemma mulZ_apply (x : ℤ) : (ModuleCat.Hom.hom (mulZ k)) x = (k : ℤ) * x := by
  simp [mulZ]

@[simp] lemma redZ_apply (x : ℤ) : (ModuleCat.Hom.hom (redZ k)) x = (x : ZMod k) := rfl

lemma mulZ_comp_redZ : mulZ k ≫ redZ k = 0 := by
  ext
  show ((((k : ℤ) • (1 : ℤ)) : ℤ) : ZMod k) = 0
  simp

/-- The two-term free resolution `0 → ℤ --(·k)--> ℤ → ZMod k → 0` of `ZMod k`,
packaged as a short complex of `ℤ`-modules. -/
noncomputable def zmodShortComplex : ShortComplex (ModuleCat.{0} ℤ) :=
  ShortComplex.mk _ _ (mulZ_comp_redZ k)

@[simp] lemma zmodShortComplex_f : (zmodShortComplex k).f = mulZ k := rfl
@[simp] lemma zmodShortComplex_g : (zmodShortComplex k).g = redZ k := rfl

/-- Multiplication by a nonzero `k` is injective on `ℤ`. -/
lemma mulZ_injective (hk : k ≠ 0) : Function.Injective (ModuleCat.Hom.hom (mulZ k)) := by
  intro a b hab
  have h : (k : ℤ) * a = (k : ℤ) * b := by simpa [mulZ, mul_comm] using hab
  exact mul_left_cancel₀ (Int.natCast_ne_zero.mpr hk) h

/-- Reduction mod `k` is surjective. -/
lemma redZ_surjective : Function.Surjective (ModuleCat.Hom.hom (redZ k)) := fun y =>
  ZMod.intCast_surjective y

/-- Exactness in the middle: an integer that reduces to `0` mod `k` is a multiple of `k`. -/
lemma zmodShortComplex_exact : (zmodShortComplex k).Exact := by
  rw [ShortComplex.moduleCat_exact_iff]
  intro x hx
  have hx' : (((show ℤ from x)) : ZMod k) = 0 := hx
  rw [ZMod.intCast_zmod_eq_zero_iff_dvd] at hx'
  obtain ⟨y, hy⟩ := hx'
  exact ⟨y, by simpa [mulZ, LinearMap.smul_apply, smul_eq_mul] using hy.symm⟩

/-- The standard resolution of `ZMod k` is short exact when `k ≠ 0`. -/
theorem zmodShortComplex_shortExact (hk : k ≠ 0) : (zmodShortComplex k).ShortExact where
  exact := zmodShortComplex_exact k
  mono_f := (ModuleCat.mono_iff_injective _).2 (mulZ_injective k hk)
  epi_g := (ModuleCat.epi_iff_surjective _).2 (redZ_surjective k)

end ZMod

section Injective

/-- The divisible group `ℚ⧸ℤ`, viewed as a `ℤ`-module. -/
abbrev QmodZ := ℚ ⧸ (AddSubgroup.zmultiples (1 : ℚ))

/-- `ℚ` is a divisible group, hence an injective `ℤ`-module. -/
noncomputable instance : Injective (ModuleCat.of ℤ ℚ) :=
  Module.injective_object_of_injective_module (inj := (Module.Baer.of_divisible ℚ).injective)

noncomputable instance : DivisibleBy QmodZ ℤ :=
  haveI : DivisibleBy ℚ ℕ := AddGroup.divisibleByNatOfDivisibleByInt ℚ
  AddGroup.divisibleByIntOfDivisibleByNat QmodZ

/-- `ℚ⧸ℤ` is divisible, hence an injective `ℤ`-module. -/
noncomputable instance : Injective (ModuleCat.of ℤ QmodZ) :=
  Module.injective_object_of_injective_module (inj := (Module.Baer.of_divisible QmodZ).injective)

/-- The inclusion `ℤ → ℚ`, as a morphism of `ℤ`-modules. -/
noncomputable def iotaQ : ModuleCat.of ℤ ℤ ⟶ ModuleCat.of ℤ ℚ :=
  ModuleCat.ofHom (Int.castAddHom ℚ).toIntLinearMap

/-- The projection `ℚ → ℚ⧸ℤ`, as a morphism of `ℤ`-modules. -/
noncomputable def projQ : ModuleCat.of ℤ ℚ ⟶ ModuleCat.of ℤ QmodZ :=
  ModuleCat.ofHom (QuotientAddGroup.mk' (AddSubgroup.zmultiples (1 : ℚ))).toIntLinearMap

lemma iotaQ_comp_projQ : iotaQ ≫ projQ = 0 := by
  ext
  show (QuotientAddGroup.mk' (AddSubgroup.zmultiples (1 : ℚ))) ((1 : ℤ) : ℚ) = 0
  simp [QuotientAddGroup.eq_zero_iff]

/-- The two-term injective resolution `0 → ℤ → ℚ → ℚ⧸ℤ → 0` of `ℤ`, packaged as a
short complex of `ℤ`-modules. -/
noncomputable def qShortComplex : ShortComplex (ModuleCat.{0} ℤ) :=
  ShortComplex.mk _ _ iotaQ_comp_projQ

@[simp] lemma qShortComplex_f : qShortComplex.f = iotaQ := rfl
@[simp] lemma qShortComplex_g : qShortComplex.g = projQ := rfl

/-- The standard injective resolution of `ℤ` is short exact. -/
theorem qShortComplex_shortExact : qShortComplex.ShortExact where
  exact := by
    rw [ShortComplex.moduleCat_exact_iff]
    intro x hx
    have hx' : (show ℚ from x) ∈ AddSubgroup.zmultiples (1 : ℚ) := by
      have h : (QuotientAddGroup.mk' (AddSubgroup.zmultiples (1 : ℚ))) (show ℚ from x) = 0 := hx
      simpa [QuotientAddGroup.eq_zero_iff] using h
    obtain ⟨n, hn⟩ := hx'
    exact ⟨n, by simpa using hn⟩
  mono_f := (ModuleCat.mono_iff_injective _).2 (by
    intro a b h
    have h' : ((show ℤ from a : ℤ) : ℚ) = ((show ℤ from b : ℤ) : ℚ) := h
    exact_mod_cast h')
  epi_g := (ModuleCat.epi_iff_surjective _).2 QuotientAddGroup.mk_surjective

end Injective

end Catalog.DerivedFunctors