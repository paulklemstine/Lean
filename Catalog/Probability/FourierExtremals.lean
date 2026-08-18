/-
# Symmetries of the discrete Fourier transform and extremals of the uncertainty principle

Building on `Catalog.Shared.FourierFiniteAbelian` and `Catalog.Shared.FourierSubgroupDuality`,
this file records how the DFT interacts with the three basic symmetries of `G → ℂ`
(scaling, translation, modulation) and deduces a large family of functions attaining
equality in the Donoho–Stark uncertainty principle `|supp f| * |supp f̂| ≥ |G|`.

Main results:

* `FourierFA.dft_transl` : `(f(· - a))^(ψ) = conj (ψ a) · f̂(ψ)` (translation ↦ modulation).
* `FourierFA.dft_modul` : `(χ · f)^(ψ) = f̂(ψ - χ)` (modulation ↦ translation in the dual).
* `FourierFA.IsExtremal` : the property `|supp f| * |supp f̂| = |G|`.
* `FourierFA.IsExtremal.smul`, `.transl`, `.modul` : the extremal functions form a set invariant
  under the three symmetries.
* `FourierFA.isExtremal_coset_modulation` : every function of the form
  `x ↦ c · χ x · 1_H (x - a)` (with `c ≠ 0`, `H` a subgroup) is extremal.
-/

import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality

open Finset ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The three symmetries -/

/-- Translation of a function by `a`. -/
def transl (a : G) (f : G → ℂ) : G → ℂ := fun x => f (x - a)

/-- Modulation of a function by a character. -/
def modul (χ : AddChar G ℂ) (f : G → ℂ) : G → ℂ := fun x => χ x * f x

omit [DecidableEq G] in
/-- Translating a function modulates its Fourier transform. -/
theorem dft_transl (a : G) (f : G → ℂ) (ψ : AddChar G ℂ) :
    dft (transl a f) ψ = conj (ψ a) * dft f ψ := by
  rw [dft, dft, Finset.mul_sum]
  rw [← Equiv.sum_comp (Equiv.addRight a) (fun x => conj (ψ x) * transl a f x)]
  refine Finset.sum_congr rfl fun y _ => ?_
  have hy : (Equiv.addRight a) y = y + a := rfl
  rw [hy]
  have h1 : transl a f (y + a) = f y := by
    rw [transl, add_sub_cancel_right]
  have h2 : conj (ψ (y + a)) = conj (ψ y) * conj (ψ a) := by
    rw [ψ.map_add_eq_mul, map_mul]
  rw [h1, h2]
  ring

omit [DecidableEq G] in
/-- Modulating a function translates its Fourier transform in the dual group. -/
theorem dft_modul (χ : AddChar G ℂ) (f : G → ℂ) (ψ : AddChar G ℂ) :
    dft (modul χ f) ψ = dft f (ψ - χ) := by
  rw [dft, dft]
  refine Finset.sum_congr rfl fun x _ => ?_
  have h : conj ((ψ - χ) x) = conj (ψ x) * χ x := by
    have h1 : (ψ - χ) x = ψ x * (χ x)⁻¹ := by
      rw [AddChar.sub_apply' ψ χ x, div_eq_mul_inv]
    rw [h1, map_mul, map_inv₀, ← AddChar.inv_apply_eq_conj χ x, inv_inv]
  rw [h, modul]
  ring

/-! ## Supports under the symmetries -/

omit [AddCommGroup G] [DecidableEq G] in
@[simp] lemma supp_smul {c : ℂ} (hc : c ≠ 0) (f : G → ℂ) : supp (c • f) = supp f := by
  ext x
  simp [mem_supp, hc]

lemma card_supp_transl (a : G) (f : G → ℂ) : (supp (transl a f)).card = (supp f).card := by
  have himg : supp (transl a f) = (supp f).image (fun x => x + a) := by
    ext x
    simp only [Finset.mem_image, mem_supp, transl]
    constructor
    · intro h
      exact ⟨x - a, h, by abel⟩
    · rintro ⟨y, hy, rfl⟩
      simpa using hy
  rw [himg, Finset.card_image_of_injective _ (add_left_injective a)]

omit [DecidableEq G] in
lemma supp_modul (χ : AddChar G ℂ) (f : G → ℂ) : supp (modul χ f) = supp f := by
  ext x
  have hχ : χ x ≠ 0 := fun h => by simpa [h] using AddChar.norm_apply χ x
  simp [mem_supp, modul, hχ]

omit [DecidableEq G] in
lemma card_supp_dft_transl (a : G) (f : G → ℂ) :
    (supp (dft (transl a f))).card = (supp (dft f)).card := by
  have h : supp (dft (transl a f)) = supp (dft f) := by
    ext ψ
    have hz : ψ a ≠ 0 := fun h => by simpa [h] using AddChar.norm_apply ψ a
    have hψ : conj (ψ a) ≠ 0 := by simpa using hz
    simp [mem_supp, dft_transl, hψ]
  rw [h]

omit [DecidableEq G] in
lemma card_supp_dft_modul (χ : AddChar G ℂ) (f : G → ℂ) :
    (supp (dft (modul χ f))).card = (supp (dft f)).card := by
  classical
  have himg : supp (dft (modul χ f)) = (supp (dft f)).image (fun ψ => ψ + χ) := by
    ext ψ
    simp only [Finset.mem_image, mem_supp, dft_modul]
    constructor
    · intro h
      exact ⟨ψ - χ, h, by abel⟩
    · rintro ⟨ξ, hξ, rfl⟩
      simpa using hξ
  rw [himg, Finset.card_image_of_injective _ (add_left_injective χ)]

/-! ## Extremal functions -/

/-- A function is *extremal* for the uncertainty principle when `|supp f| * |supp f̂| = |G|`,
the smallest value allowed by `FourierFA.uncertainty`. -/
def IsExtremal (f : G → ℂ) : Prop :=
  (supp f).card * (supp (dft f)).card = Fintype.card G

omit [DecidableEq G] in
theorem IsExtremal.smul {c : ℂ} (hc : c ≠ 0) {f : G → ℂ} (hf : IsExtremal f) :
    IsExtremal (c • f) := by
  have hdft : dft (c • f) = c • dft f := dft_smul c f
  rw [IsExtremal, supp_smul hc, hdft, supp_smul hc]
  exact hf

theorem IsExtremal.transl (a : G) {f : G → ℂ} (hf : IsExtremal f) : IsExtremal (transl a f) := by
  rw [IsExtremal, card_supp_transl, card_supp_dft_transl]
  exact hf

omit [DecidableEq G] in
theorem IsExtremal.modul (χ : AddChar G ℂ) {f : G → ℂ} (hf : IsExtremal f) :
    IsExtremal (modul χ f) := by
  rw [IsExtremal, supp_modul, card_supp_dft_modul]
  exact hf

/-- Subgroup indicators are extremal (restatement of `uncertainty_eq_subgroup`). -/
theorem isExtremal_indic (H : AddSubgroup G) [DecidablePred (· ∈ H)] :
    IsExtremal (indic H) := uncertainty_eq_subgroup

/-- **A large family of extremals**: any nonzero multiple of a modulated translate of a subgroup
indicator attains equality in the uncertainty principle. -/
theorem isExtremal_coset_modulation (H : AddSubgroup G) [DecidablePred (· ∈ H)]
    {c : ℂ} (hc : c ≠ 0) (χ : AddChar G ℂ) (a : G) :
    IsExtremal (c • modul χ (transl a (indic H))) :=
  (((isExtremal_indic H).transl a).modul χ).smul hc

/-- Concretely: `x ↦ c · χ x · 1_H (x - a)` has `|supp f| * |supp f̂| = |G|`. -/
theorem uncertainty_eq_coset_modulation (H : AddSubgroup G) [DecidablePred (· ∈ H)]
    {c : ℂ} (hc : c ≠ 0) (χ : AddChar G ℂ) (a : G) :
    (supp (fun x => c * (χ x * indic H (x - a)))).card
        * (supp (dft (fun x => c * (χ x * indic H (x - a))))).card
      = Fintype.card G := by
  have h := isExtremal_coset_modulation H hc χ a
  have hfun : (c • modul χ (transl a (indic H))) = fun x => c * (χ x * indic H (x - a)) := by
    funext x
    rfl
  rw [hfun] at h
  exact h

end FourierFA