/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The abundancy index: multiplicativity and divisibility monotonicity

The *abundancy index* of a natural number `n` is the rational number `σ₁(n) / n`,
where `σ₁(n) = ∑_{d ∣ n} d` is the sum-of-divisors function.  It measures how
"abundant" a number is: `n` is perfect exactly when its abundancy index equals `2`.

This file establishes two basic structural facts about the abundancy index:

* **Multiplicativity** (`abundancy_mul_of_coprime`): for coprime `m, n`,
  `abundancy (m * n) = abundancy m * abundancy n`.
* **Divisibility monotonicity** (`abundancy_le_of_dvd`, `abundancy_lt_of_dvd_lt`):
  if `d ∣ n` then `abundancy d ≤ abundancy n`, with strict inequality when `d < n`.

## Breaking the circular dependency

A common pitfall is to prove multiplicativity *via* a monotonicity/embedding
argument and monotonicity *via* multiplicativity, producing a circular development.
Here the two results are proved completely independently:

* Multiplicativity rests only on the multiplicativity of `σ₁` itself
  (`ArithmeticFunction.isMultiplicative_sigma`) together with the field identity
  `mul_div_mul_comm`.
* Monotonicity rests on a *direct* divisor-sum comparison, with no reference to
  multiplicativity or to any coprime factorisation: each divisor `e` of `d` is sent
  to the divisor `e * (n / d)` of `n`.  This map is injective, so the image of
  `d.divisors` is a subset of `n.divisors` whose elementwise sum is exactly
  `(n / d) · σ₁(d)`.  Comparing sums of nonnegative terms gives
  `σ₁(d) · (n / d) ≤ σ₁(n)`, i.e. `σ₁(d) · n ≤ σ₁(n) · d`, which is precisely
  `abundancy d ≤ abundancy n`.  When `d < n` the divisor `1 ∈ n.divisors` is missing
  from the image (its only preimage would require `n / d = 1`), yielding the strict
  inequality.
-/
import Mathlib

open ArithmeticFunction Finset

namespace PerfectNumbers

/-- The abundancy index of `n`, namely `σ₁(n) / n` as a rational number.
For `n = 0` this evaluates to `0` by the junk-value convention for division. -/
noncomputable def abundancy (n : ℕ) : ℚ := (ArithmeticFunction.sigma 1 n : ℚ) / (n : ℚ)

/-- A perfect number is one whose abundancy index equals `2`. -/
def IsPerfect (n : ℕ) : Prop := abundancy n = 2

/-!
## The core divisor-sum comparison (no multiplicativity used)

The map `e ↦ e * (n / d)` injects `d.divisors` into `n.divisors`.  Summing over the
image and comparing with the full sum over `n.divisors` gives the basic inequality
`σ₁(d) · (n / d) ≤ σ₁(n)`.
-/

/-- **Scaled embedding of divisor sums.** If `d ∣ n`, then `σ₁(d) · (n / d) ≤ σ₁(n)`.

The proof embeds `d.divisors` into `n.divisors` via `e ↦ e * (n / d)` and compares
sums of nonnegative terms; it does *not* use any multiplicativity of `σ₁`. -/
theorem sigma_one_mul_div_le {d n : ℕ} (hdn : d ∣ n) :
    sigma 1 d * (n / d) ≤ sigma 1 n := by
  rcases Nat.eq_zero_or_pos n with hn0 | hn
  · subst hn0; simp
  have hd : 0 < d := Nat.pos_of_dvd_of_pos hdn hn
  set q := n / d with hq
  have hdq : d * q = n := Nat.mul_div_cancel' hdn
  have hqpos : 0 < q := by
    rcases Nat.eq_zero_or_pos q with h0 | h0
    · rw [h0, Nat.mul_zero] at hdq; omega
    · exact h0
  rw [sigma_one_apply, sigma_one_apply]
  have hinj : Set.InjOn (fun e => e * q) ↑d.divisors := by
    intro a _ b _ h
    simpa [Nat.mul_left_inj (by omega : q ≠ 0)] using h
  have himg : (∑ x ∈ d.divisors.image (fun e => e * q), x) = ∑ e ∈ d.divisors, e * q := by
    rw [Finset.sum_image (fun a ha b hb h => hinj ha hb h)]
  have hsub : d.divisors.image (fun e => e * q) ⊆ n.divisors := by
    intro x hx
    simp only [Finset.mem_image] at hx
    obtain ⟨e, he, rfl⟩ := hx
    rw [Nat.mem_divisors] at he ⊢
    exact ⟨by rw [← hdq]; exact Nat.mul_dvd_mul_right he.1 q, by omega⟩
  calc (∑ e ∈ d.divisors, e) * q = ∑ e ∈ d.divisors, e * q := by rw [Finset.sum_mul]
    _ = ∑ x ∈ d.divisors.image (fun e => e * q), x := himg.symm
    _ ≤ ∑ x ∈ n.divisors, x := Finset.sum_le_sum_of_subset hsub

/-- **Strict scaled embedding of divisor sums.** If `d ∣ n` and `d < n`, then
`σ₁(d) · (n / d) < σ₁(n)`.

When `d < n` the quotient `n / d` is at least `2`, so the divisor `1 ∈ n.divisors`
is not in the image of `e ↦ e * (n / d)`, which makes the inequality strict. -/
theorem sigma_one_mul_div_lt {d n : ℕ} (hdn : d ∣ n) (hlt : d < n) :
    sigma 1 d * (n / d) < sigma 1 n := by
  have hn : 0 < n := lt_of_le_of_lt (Nat.zero_le d) hlt
  have hd : 0 < d := Nat.pos_of_dvd_of_pos hdn hn
  set q := n / d with hq
  have hdq : d * q = n := Nat.mul_div_cancel' hdn
  have hqge : 2 ≤ q := by
    by_contra h
    interval_cases q <;> omega
  rw [sigma_one_apply, sigma_one_apply]
  have hinj : Set.InjOn (fun e => e * q) ↑d.divisors := by
    intro a _ b _ h
    simpa [Nat.mul_left_inj (by omega : q ≠ 0)] using h
  have himg : (∑ x ∈ d.divisors.image (fun e => e * q), x) = ∑ e ∈ d.divisors, e * q := by
    rw [Finset.sum_image (fun a ha b hb h => hinj ha hb h)]
  have hsub : d.divisors.image (fun e => e * q) ⊆ n.divisors := by
    intro x hx
    simp only [Finset.mem_image] at hx
    obtain ⟨e, he, rfl⟩ := hx
    rw [Nat.mem_divisors] at he ⊢
    exact ⟨by rw [← hdq]; exact Nat.mul_dvd_mul_right he.1 q, by omega⟩
  have h1mem : (1 : ℕ) ∈ n.divisors := Nat.one_mem_divisors.mpr (by omega)
  have h1not : (1 : ℕ) ∉ d.divisors.image (fun e => e * q) := by
    simp only [Finset.mem_image, not_exists, not_and]
    intro e he heq
    have hepos : 0 < e := Nat.pos_of_mem_divisors he
    nlinarith
  have hcore : (∑ x ∈ d.divisors.image (fun e => e * q), x) < ∑ x ∈ n.divisors, x :=
    Finset.sum_lt_sum_of_subset hsub h1mem h1not (by norm_num) (by intro j _ _; positivity)
  calc (∑ e ∈ d.divisors, e) * q = ∑ e ∈ d.divisors, e * q := by rw [Finset.sum_mul]
    _ = ∑ x ∈ d.divisors.image (fun e => e * q), x := himg.symm
    _ < ∑ x ∈ n.divisors, x := hcore

/-- Cross-multiplied form of the divisor-sum comparison: `σ₁(d) · n ≤ σ₁(n) · d`. -/
theorem sigma_one_cross_le {d n : ℕ} (hdn : d ∣ n) : sigma 1 d * n ≤ sigma 1 n * d := by
  have h := sigma_one_mul_div_le hdn
  have hnd : n / d * d = n := Nat.div_mul_cancel hdn
  calc sigma 1 d * n = sigma 1 d * (n / d) * d := by rw [mul_assoc, hnd]
    _ ≤ sigma 1 n * d := Nat.mul_le_mul_right d h

/-- Strict cross-multiplied form: if `d ∣ n` and `d < n` then `σ₁(d) · n < σ₁(n) · d`. -/
theorem sigma_one_cross_lt {d n : ℕ} (hdn : d ∣ n) (hlt : d < n) :
    sigma 1 d * n < sigma 1 n * d := by
  have h := sigma_one_mul_div_lt hdn hlt
  have hd : 0 < d := Nat.pos_of_dvd_of_pos hdn (lt_of_le_of_lt (Nat.zero_le d) hlt)
  have hnd : n / d * d = n := Nat.div_mul_cancel hdn
  calc sigma 1 d * n = sigma 1 d * (n / d) * d := by rw [mul_assoc, hnd]
    _ < sigma 1 n * d := by gcongr

/-!
## Divisibility monotonicity of the abundancy index
-/

/-- **Divisibility monotonicity.** If `d ∣ n` with `0 < n`, then
`abundancy d ≤ abundancy n`.

This is proved directly from the divisor-sum comparison `sigma_one_cross_le`, with no
appeal to multiplicativity. -/
theorem abundancy_le_of_dvd {d n : ℕ} (hn : 0 < n) (hdn : d ∣ n) :
    abundancy d ≤ abundancy n := by
  have hd : 0 < d := Nat.pos_of_dvd_of_pos hdn hn
  unfold abundancy
  rw [div_le_div_iff₀ (by exact_mod_cast hd) (by exact_mod_cast hn)]
  exact_mod_cast sigma_one_cross_le hdn

/-- **Strict divisibility monotonicity.** If `d ∣ n` and `d < n`, then
`abundancy d < abundancy n`. -/
theorem abundancy_lt_of_dvd_lt {d n : ℕ} (hdn : d ∣ n) (hlt : d < n) :
    abundancy d < abundancy n := by
  have hn : 0 < n := lt_of_le_of_lt (Nat.zero_le d) hlt
  have hd : 0 < d := Nat.pos_of_dvd_of_pos hdn hn
  unfold abundancy
  rw [div_lt_div_iff₀ (by exact_mod_cast hd) (by exact_mod_cast hn)]
  exact_mod_cast sigma_one_cross_lt hdn hlt

/-!
## Multiplicativity of the abundancy index
-/

/-- **Multiplicativity.** For coprime `m` and `n`,
`abundancy (m * n) = abundancy m * abundancy n`.

The proof uses only the multiplicativity of `σ₁`
(`ArithmeticFunction.isMultiplicative_sigma`) and the field identity
`mul_div_mul_comm`; it does not use the monotonicity results above. -/
theorem abundancy_mul_of_coprime {m n : ℕ} (h : m.Coprime n) :
    abundancy (m * n) = abundancy m * abundancy n := by
  unfold abundancy
  rw [ArithmeticFunction.isMultiplicative_sigma.2 h]
  push_cast
  rw [mul_div_mul_comm]

end PerfectNumbers