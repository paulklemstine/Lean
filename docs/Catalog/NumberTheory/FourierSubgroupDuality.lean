/-
# Subgroups, annihilators and extremals of the uncertainty principle

Building on `Catalog.Shared.FourierFiniteAbelian`, this file studies the Fourier transform of
the indicator function of a subgroup `H ≤ G` of a finite abelian group.

Main results:

* `FourierFA.sum_char_over_subgroup` : `∑_{x ∈ H} ψ x = |H| ⬝ [ψ ∈ H^⊥]`.
* `FourierFA.dft_indic` : the Fourier transform of `1_H` is `|H| ⬝ 1_{H^⊥}`.
* `FourierFA.card_subgroup_mul_card_annihilator` : `|H| * |H^⊥| = |G|`, obtained *from Plancherel*
  rather than from Pontryagin duality of the quotient.
* `FourierFA.uncertainty_eq_subgroup` : subgroup indicators are extremal for the Donoho–Stark
  uncertainty principle, i.e. `|supp 1_H| * |supp (1_H)^| = |G|` exactly.
* `FourierFA.poisson_summation` : `|G| * ∑_{x ∈ H} f x = |H| * ∑_{ψ ∈ H^⊥} f̂ ψ`.
-/

import Mathlib
import Shared.FourierFiniteAbelian

open Finset Fintype ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]
  (H : AddSubgroup G) [DecidablePred (· ∈ H)]

/-- The underlying finset of a subgroup. -/
def subFinset : Finset G := Finset.univ.filter (· ∈ H)

/-- The indicator function of a subgroup. -/
noncomputable def indic : G → ℂ := fun x => if x ∈ H then 1 else 0

/-- The annihilator (orthogonal complement) of `H` inside the dual group. -/
noncomputable def annih : Finset (AddChar G ℂ) :=
  Finset.univ.filter (fun ψ : AddChar G ℂ => ∀ x ∈ H, ψ x = 1)

variable {H}

omit [DecidableEq G] in
@[simp] lemma mem_subFinset {x : G} : x ∈ subFinset H ↔ x ∈ H := by simp [subFinset]

omit [DecidableEq G] in
@[simp] lemma mem_annih {ψ : AddChar G ℂ} : ψ ∈ annih H ↔ ∀ x ∈ H, ψ x = 1 := by
  simp [annih]

omit [DecidableEq G] in
lemma subFinset_nonempty : (subFinset H).Nonempty := ⟨0, mem_subFinset.2 H.zero_mem⟩

omit [DecidableEq G] in
lemma card_subFinset_pos : 0 < (subFinset H).card :=
  Finset.card_pos.2 subFinset_nonempty

omit [DecidableEq G] in
lemma supp_indic : supp (indic H) = subFinset H := by
  ext x
  simp [mem_supp, indic, subFinset]

/-- Orthogonality relation over a subgroup: a character sums to `|H|` over `H` if it is trivial
on `H`, and to `0` otherwise. -/
theorem sum_char_over_subgroup (ψ : AddChar G ℂ) :
    ∑ x ∈ subFinset H, ψ x = if ψ ∈ annih H then ((subFinset H).card : ℂ) else 0 := by
  by_cases h : ψ ∈ annih H
  · rw [if_pos h]
    rw [Finset.sum_congr rfl (fun x hx => mem_annih.1 h x (mem_subFinset.1 hx))]
    simp
  · rw [if_neg h]
    rw [mem_annih] at h
    push_neg at h
    obtain ⟨x₀, hx₀H, hx₀⟩ := h
    -- translation by `x₀` permutes `H`
    have himg : (subFinset H).image (fun x => x₀ + x) = subFinset H := by
      refine Finset.eq_of_subset_of_card_le ?_ ?_
      · intro y hy
        simp only [Finset.mem_image] at hy
        obtain ⟨x, hx, rfl⟩ := hy
        exact mem_subFinset.2 (H.add_mem hx₀H (mem_subFinset.1 hx))
      · rw [Finset.card_image_of_injective _ (add_right_injective x₀)]
    have hre : ∑ x ∈ subFinset H, ψ (x₀ + x) = ∑ x ∈ subFinset H, ψ x := by
      conv_rhs => rw [← himg]
      rw [Finset.sum_image (fun a _ b _ hab => add_right_injective x₀ hab)]
    have hmul : ψ x₀ * ∑ x ∈ subFinset H, ψ x = ∑ x ∈ subFinset H, ψ x := by
      rw [Finset.mul_sum]
      simp_rw [← ψ.map_add_eq_mul]
      exact hre
    have hz : (ψ x₀ - 1) * ∑ x ∈ subFinset H, ψ x = 0 := by
      rw [sub_mul, one_mul, hmul, sub_self]
    rcases mul_eq_zero.1 hz with h1 | h2
    · exact absurd (sub_eq_zero.1 h1) hx₀
    · exact h2

/-- The Fourier transform of the indicator of a subgroup is `|H|` times the indicator of the
annihilator. -/
theorem dft_indic (ψ : AddChar G ℂ) :
    dft (indic H) ψ = if ψ ∈ annih H then ((subFinset H).card : ℂ) else 0 := by
  have e1 : ∑ x ∈ subFinset H, conj (ψ x) * indic H x = ∑ x : G, conj (ψ x) * indic H x := by
    refine Finset.sum_subset (Finset.subset_univ _) ?_
    intro x _ hx
    have : indic H x = 0 := by
      simp only [indic, if_neg (fun hxH : x ∈ H => hx (mem_subFinset.2 hxH))]
    rw [this, mul_zero]
  have h1 : dft (indic H) ψ = ∑ x ∈ subFinset H, conj (ψ x) := by
    rw [dft, ← e1]
    refine Finset.sum_congr rfl fun x hx => ?_
    have : indic H x = 1 := by
      simp only [indic, if_pos (mem_subFinset.1 hx)]
    rw [this, mul_one]
  have h2 : ∀ x : G, conj (ψ x) = (-ψ) x := by
    intro x
    rw [AddChar.neg_apply', AddChar.inv_apply_eq_conj]
  have h3 : ((-ψ) ∈ annih H) ↔ (ψ ∈ annih H) := by
    simp only [mem_annih]
    constructor
    · intro h x hx
      have := h x hx
      rw [AddChar.neg_apply', inv_eq_one] at this
      exact this
    · intro h x hx
      rw [AddChar.neg_apply', h x hx, inv_one]
  rw [h1]
  simp_rw [h2]
  rw [sum_char_over_subgroup (-ψ)]
  by_cases h : ψ ∈ annih H
  · rw [if_pos (h3.2 h), if_pos h]
  · rw [if_neg (fun hc => h (h3.1 hc)), if_neg h]

/-- The support of the Fourier transform of `1_H` is exactly the annihilator `H^⊥`. -/
theorem supp_dft_indic : supp (dft (indic H)) = annih H := by
  ext ψ
  rw [mem_supp, dft_indic]
  by_cases h : ψ ∈ annih H
  · simp [h, card_subFinset_pos.ne']
  · simp [h]

/-- **`|H| * |H^⊥| = |G|`**, derived from Plancherel's theorem. -/
theorem card_subgroup_mul_card_annihilator :
    (subFinset H).card * (annih H).card = Fintype.card G := by
  have hpar := parseval_norm (indic H)
  -- right-hand side
  have hR : ∑ x : G, ‖indic H x‖ ^ 2 = ((subFinset H).card : ℝ) := by
    have : ∀ x : G, ‖indic H x‖ ^ 2 = if x ∈ subFinset H then (1 : ℝ) else 0 := by
      intro x
      by_cases hx : x ∈ H
      · simp [indic, hx, mem_subFinset]
      · simp [indic, hx, mem_subFinset]
    simp_rw [this]
    rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul, mul_one]
  -- left-hand side
  have hL : ∑ ψ : AddChar G ℂ, ‖dft (indic H) ψ‖ ^ 2
      = ((annih H).card : ℝ) * ((subFinset H).card : ℝ) ^ 2 := by
    have : ∀ ψ : AddChar G ℂ, ‖dft (indic H) ψ‖ ^ 2
        = if ψ ∈ annih H then ((subFinset H).card : ℝ) ^ 2 else 0 := by
      intro ψ
      rw [dft_indic]
      by_cases h : ψ ∈ annih H
      · simp [h]
      · simp [h]
    simp_rw [this]
    rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]
  rw [hL, hR] at hpar
  have hpos : (0 : ℝ) < ((subFinset H).card : ℝ) := by exact_mod_cast card_subFinset_pos
  have hmul : ((annih H).card : ℝ) * ((subFinset H).card : ℝ)
      = (Fintype.card G : ℝ) := by
    have h2 : ((annih H).card : ℝ) * ((subFinset H).card : ℝ) * ((subFinset H).card : ℝ)
        = (Fintype.card G : ℝ) * ((subFinset H).card : ℝ) := by
      calc ((annih H).card : ℝ) * ((subFinset H).card : ℝ) * ((subFinset H).card : ℝ)
          = ((annih H).card : ℝ) * ((subFinset H).card : ℝ) ^ 2 := by ring
        _ = (Fintype.card G : ℝ) * ((subFinset H).card : ℝ) := hpar
    exact mul_right_cancel₀ (ne_of_gt hpos) h2
  rw [mul_comm] at hmul
  exact_mod_cast hmul

/-- Subgroup indicators are **extremal** for the uncertainty principle: they attain equality in
`|supp f| * |supp f̂| ≥ |G|`. -/
theorem uncertainty_eq_subgroup :
    (supp (indic H)).card * (supp (dft (indic H))).card = Fintype.card G := by
  rw [supp_indic, supp_dft_indic]
  exact card_subgroup_mul_card_annihilator

/-- **Poisson summation** for a subgroup `H ≤ G`:
`|G| * ∑_{x ∈ H} f x = |H| * ∑_{ψ ∈ H^⊥} f̂ ψ`. -/
theorem poisson_summation (f : G → ℂ) :
    (Fintype.card G : ℂ) * ∑ x ∈ subFinset H, f x
      = ((subFinset H).card : ℂ) * ∑ ψ ∈ annih H, dft f ψ := by
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have hf : ∀ x : G, (Fintype.card G : ℂ) * f x = ∑ ψ : AddChar G ℂ, ψ x * dft f ψ := by
    intro x
    conv_lhs => rw [← dft_inversion f]
    rw [idft, ← mul_assoc, mul_inv_cancel₀ hcard, one_mul]
  calc (Fintype.card G : ℂ) * ∑ x ∈ subFinset H, f x
      = ∑ x ∈ subFinset H, (Fintype.card G : ℂ) * f x := by rw [Finset.mul_sum]
    _ = ∑ x ∈ subFinset H, ∑ ψ : AddChar G ℂ, ψ x * dft f ψ :=
        Finset.sum_congr rfl fun x _ => hf x
    _ = ∑ ψ : AddChar G ℂ, (∑ x ∈ subFinset H, ψ x) * dft f ψ := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun ψ _ => by rw [Finset.sum_mul]
    _ = ∑ ψ : AddChar G ℂ, (if ψ ∈ annih H then ((subFinset H).card : ℂ) else 0) * dft f ψ := by
        exact Finset.sum_congr rfl fun ψ _ => by rw [sum_char_over_subgroup ψ]
    _ = ∑ ψ ∈ annih H, ((subFinset H).card : ℂ) * dft f ψ := by
        simp_rw [ite_mul, zero_mul]
        rw [Finset.sum_ite_mem, Finset.univ_inter]
    _ = ((subFinset H).card : ℂ) * ∑ ψ ∈ annih H, dft f ψ := by rw [Finset.mul_sum]

end FourierFA