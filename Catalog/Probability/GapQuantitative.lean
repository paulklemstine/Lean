/-
# How wide is the parity gap, and why primality is essential

Conjecture A says that the parity-weighted exponent counter `permCoeff S T` does not vanish
identically.  Since the counter also has total mass zero (`sum_permCoeff_eq_zero`), nonvanishing
at one point forces a *two-sided* gap.  This file records the resulting quantitative statements
and then shows that primality of the modulus cannot be dropped.

Main results:

* `ParityGap.sum_sign_eq_zero` — half of the permutations of `Fin n` (`n ≥ 2`) are even;
* `ParityGap.exists_pos_permCoeff`, `ParityGap.exists_neg_permCoeff` — some residue is realised
  by strictly more even than odd permutations, and some other residue by strictly more odd
  than even ones;
* `ParityGap.two_le_card_support_permCoeff` — at least two residues carry a nonzero counter;
* `ParityGap.two_le_sum_sq_permCoeff` — the `ℓ²` mass of the counter is at least `2`;
* `ParityGap.permCoeff_eq_zero_of_permExp_const` and
  `ParityGap.parity_gap_closes_mod_four` — over `ZMod 4` the gap **does** close for the
  injective pair `S = T = ![0, 2]`: Conjecture A is a genuinely arithmetic statement about
  primes, not a formal consequence of the combinatorics.
-/

import Mathlib
import Probability.Chebotarev

open Finset PrimeUncertainty

namespace ParityGap

/-! ## Signs and constant exponent maps (no primality needed) -/

/-- For `n ≥ 2` exactly half of the permutations of `Fin n` are even. -/
theorem sum_sign_eq_zero {n : ℕ} (hn : 2 ≤ n) :
    ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ) = 0 := by
  have h01 : (⟨0, by omega⟩ : Fin n) ≠ ⟨1, by omega⟩ := by simp [Fin.ext_iff]
  set τ : Equiv.Perm (Fin n) := Equiv.swap ⟨0, by omega⟩ ⟨1, by omega⟩ with hτ
  have hsgnτ : (Equiv.Perm.sign τ : ℚ) = -1 := by
    rw [hτ, Equiv.Perm.sign_swap h01]; simp
  have hshift : ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ)
      = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign (σ * τ) : ℚ) :=
    (Fintype.sum_equiv (Equiv.mulRight τ) _ _ fun _ => rfl).symm
  have hneg : ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign (σ * τ) : ℚ)
      = -∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ) := by
    rw [← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun σ _ => ?_
    rw [map_mul]
    push_cast
    rw [hsgnτ]
    ring
  rw [hneg] at hshift
  linarith

/-- If every permutation realises the *same* exponent, the parity-weighted counter vanishes
identically: the gap closes.  (No primality is assumed here.) -/
theorem permCoeff_eq_zero_of_permExp_const {m n : ℕ} (hn : 2 ≤ n) (S T : Fin n → ZMod m)
    (e : ZMod m) (h : ∀ σ : Equiv.Perm (Fin n), permExp S T σ = e) (r : ZMod m) :
    permCoeff S T r = 0 := by
  classical
  simp only [permCoeff, h]
  by_cases hr : e = r
  · simp only [hr, if_true]
    exact sum_sign_eq_zero hn
  · simp [hr]

/-! ## The gap is two-sided (`p` prime) -/

variable {p : ℕ} [hp : Fact p.Prime] {n : ℕ}

/-- Some residue is hit by strictly more even than odd permutations. -/
theorem exists_pos_permCoeff (S T : Fin n → ZMod p) (hn : 2 ≤ n) (hS : Function.Injective S)
    (hT : Function.Injective T) : ∃ r : ZMod p, 0 < permCoeff S T r := by
  classical
  by_contra hall
  push_neg at hall
  obtain ⟨r₀, hr₀⟩ := exists_permCoeff_ne_zero S T hS hT
  have hsum := sum_permCoeff_eq_zero S T hn
  have := (Finset.sum_eq_zero_iff_of_nonpos (fun r _ => hall r)).mp hsum
  exact hr₀ (this r₀ (Finset.mem_univ r₀))

/-- Some residue is hit by strictly more odd than even permutations. -/
theorem exists_neg_permCoeff (S T : Fin n → ZMod p) (hn : 2 ≤ n) (hS : Function.Injective S)
    (hT : Function.Injective T) : ∃ r : ZMod p, permCoeff S T r < 0 := by
  classical
  by_contra hall
  push_neg at hall
  obtain ⟨r₀, hr₀⟩ := exists_permCoeff_ne_zero S T hS hT
  have hsum := sum_permCoeff_eq_zero S T hn
  have := (Finset.sum_eq_zero_iff_of_nonneg (fun r _ => hall r)).mp hsum
  exact hr₀ (this r₀ (Finset.mem_univ r₀))

/-- **The parity gap is at least two residues wide.** -/
theorem two_le_card_support_permCoeff (S T : Fin n → ZMod p) (hn : 2 ≤ n)
    (hS : Function.Injective S) (hT : Function.Injective T) :
    2 ≤ (univ.filter (fun r : ZMod p => permCoeff S T r ≠ 0)).card := by
  classical
  obtain ⟨r, hr⟩ := exists_pos_permCoeff S T hn hS hT
  obtain ⟨s, hs⟩ := exists_neg_permCoeff S T hn hS hT
  have hrs : r ≠ s := by
    intro h
    rw [h] at hr
    linarith
  have hsub : ({r, s} : Finset (ZMod p)) ⊆ univ.filter (fun r : ZMod p => permCoeff S T r ≠ 0) := by
    intro x hx
    rcases Finset.mem_insert.mp hx with rfl | hx'
    · exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, ne_of_gt hr⟩
    · rw [Finset.mem_singleton] at hx'
      subst hx'
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, ne_of_lt hs⟩
  calc (2 : ℕ) = ({r, s} : Finset (ZMod p)).card := by rw [Finset.card_pair hrs]
    _ ≤ _ := Finset.card_le_card hsub

/-- The `ℓ²` mass of the parity-weighted counter is at least `2`. -/
theorem two_le_sum_sq_permCoeff (S T : Fin n → ZMod p) (hn : 2 ≤ n)
    (hS : Function.Injective S) (hT : Function.Injective T) :
    2 ≤ ∑ r : ZMod p, (permCoeff S T r) ^ 2 := by
  classical
  obtain ⟨r, hr⟩ := exists_pos_permCoeff S T hn hS hT
  obtain ⟨s, hs⟩ := exists_neg_permCoeff S T hn hS hT
  have hrs : r ≠ s := by
    intro h; rw [h] at hr; linarith
  -- each nonzero coefficient is an integer, hence has square at least `1`
  have hone : ∀ t : ZMod p, permCoeff S T t ≠ 0 → 1 ≤ (permCoeff S T t) ^ 2 := by
    intro t ht
    have hint : ∃ z : ℤ, permCoeff S T t = (z : ℚ) := ⟨_, permCoeff_eq_intCast S T t⟩
    obtain ⟨z, hz⟩ := hint
    have hz0 : z ≠ 0 := by
      intro h; rw [h] at hz; simp at hz; exact ht hz
    have : (1 : ℤ) ≤ z ^ 2 := by
      rcases lt_or_gt_of_ne hz0 with h | h <;> nlinarith
    rw [hz]
    exact_mod_cast this
  have hsub : ({r, s} : Finset (ZMod p)) ⊆ univ := Finset.subset_univ _
  have hnonneg : ∀ t ∈ (univ : Finset (ZMod p)), t ∉ ({r, s} : Finset (ZMod p)) →
      0 ≤ (permCoeff S T t) ^ 2 := fun t _ _ => sq_nonneg _
  have hsplit : ∑ t ∈ ({r, s} : Finset (ZMod p)), (permCoeff S T t) ^ 2
      ≤ ∑ t : ZMod p, (permCoeff S T t) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub hnonneg
  have hpair : (2 : ℚ) ≤ ∑ t ∈ ({r, s} : Finset (ZMod p)), (permCoeff S T t) ^ 2 := by
    rw [Finset.sum_pair hrs]
    have h1 := hone r (ne_of_gt hr)
    have h2 := hone s (ne_of_lt hs)
    linarith
  linarith

/-! ## Primality is essential: the gap closes modulo `4` -/

/-- **Boundary of Conjecture A.**  Over `ZMod 4` the injective pair `S = T = ![0, 2]` makes the
parity-weighted counter vanish identically: every residue is realised by equally many even and
odd permutations.  Thus Conjecture A really uses that the modulus is prime. -/
theorem parity_gap_closes_mod_four :
    ∃ S T : Fin 2 → ZMod 4, Function.Injective S ∧ Function.Injective T ∧
      ∀ r : ZMod 4, permCoeff S T r = 0 := by
  classical
  refine ⟨![0, 2], ![0, 2], ?_, ?_, ?_⟩
  · decide
  · decide
  · refine permCoeff_eq_zero_of_permExp_const (by norm_num) _ _ 0 (fun σ => ?_)
    have hzero : ∀ i j : Fin 2, (![0, 2] : Fin 2 → ZMod 4) i * (![0, 2] : Fin 2 → ZMod 4) j = 0 := by
      decide
    rw [permExp]
    exact Finset.sum_eq_zero fun j _ => hzero (σ j) j

end ParityGap