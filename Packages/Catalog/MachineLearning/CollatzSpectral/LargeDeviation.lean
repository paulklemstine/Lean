/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exponential decay of the non-contracting density

`DensityContraction.lean` used the exact *second* moment of the odd-step count
to obtain a `1/(4δ²k)` bound on the density of residues mod `2^k` that fail to
contract. But the generating identity
`∑_{n<2^k} x^{s_k(n)} = (1+x)^k` encodes *all* moments at once, so it supports a
Chernoff argument, and the polynomial bound can be upgraded to an exponential
one.

Taking `x = 2` gives `∑_{n<2^k} 2^{s_k(n)} = 3^k`. On the non-contracting set
`3^{s} ≥ 2^k`, which forces the purely arithmetic inequality `5 s ≥ 3 k`
(because `27 ≤ 32`). Markov's inequality then yields

  `#{r < 2^k : 3^{s_k(r)} ≥ 2^k}^5 · 8^k ≤ 243^k`,

i.e. the density `ρ_k` satisfies `ρ_k^5 ≤ (243/256)^k`: exponential decay with
an explicit rate.

## Main results

* `five_mul_onesCount_ge` — `2^k ≤ 3^s → 3k ≤ 5s`, an integer Chernoff constraint.
* `sum_two_pow_onesCount` — `∑_{n<2^k} 2^{s_k(n)} = 3^k`.
* `card_noncontracting_pow_le` — the arithmetic Chernoff bound.
* `noncontracting_density_pow_le` — `ρ_k^5 ≤ (243/256)^k`, exponential decay.
-/

import Mathlib
import MachineLearning.CollatzSpectral.NaturalDensity

open Finset Filter

namespace CollatzParity

/-! ## §1. The integer Chernoff constraint -/

/-- **`27 ≤ 32` in disguise.** If `3^s ≥ 2^k` then `5s ≥ 3k`. This is the
arithmetic shadow of `log 2 / log 3 > 3/5`. -/
theorem five_mul_onesCount_ge {k s : ℕ} (h : 2 ^ k ≤ 3 ^ s) : 3 * k ≤ 5 * s := by
  by_contra hlt
  push_neg at hlt
  have h1 : (3 : ℕ) ^ (5 * s) < 3 ^ (3 * k) := Nat.pow_lt_pow_right (by norm_num) hlt
  have h2 : (3 : ℕ) ^ (3 * k) ≤ 2 ^ (5 * k) := by
    have : (3 : ℕ) ^ (3 * k) = 27 ^ k := by rw [pow_mul]; norm_num
    have h3 : (2 : ℕ) ^ (5 * k) = 32 ^ k := by rw [pow_mul]; norm_num
    rw [this, h3]
    exact Nat.pow_le_pow_left (by norm_num) k
  have h4 : (2 : ℕ) ^ (5 * k) ≤ 3 ^ (5 * s) := by
    rw [mul_comm 5 k, mul_comm 5 s, pow_mul, pow_mul]
    exact Nat.pow_le_pow_left h 5
  omega

/-! ## §2. The exponential moment -/

/-- The exponential moment of the odd-step count at `x = 2`. -/
theorem sum_two_pow_onesCount (k : ℕ) :
    ∑ n ∈ Finset.range (2 ^ k), 2 ^ onesCount k n = 3 ^ k := by
  have h := onesCount_generating_function (2 : ℕ) k
  rw [show (1 + 2 : ℕ) = 3 by norm_num] at h
  exact h

/-- Membership in the non-contracting set is the arithmetic condition
`2^k ≤ 3^{s_k(r)}`. -/
theorem mem_noncontracting_iff (k r : ℕ) :
    r ∈ noncontracting k ↔ r < 2 ^ k ∧ 2 ^ k ≤ 3 ^ onesCount k r := by
  rw [noncontracting, Finset.mem_filter, Finset.mem_range]
  constructor
  · rintro ⟨hr, hc⟩
    refine ⟨hr, ?_⟩
    by_contra hlt
    push_neg at hlt
    exact absurd ((contractionExp_pos_iff k _).mpr hlt) (not_lt.mpr hc)
  · rintro ⟨hr, hc⟩
    refine ⟨hr, ?_⟩
    by_contra hpos
    push_neg at hpos
    exact absurd ((contractionExp_pos_iff k _).mp hpos) (not_lt.mpr hc)

/-! ## §3. The Chernoff bound -/

/-- **Arithmetic Chernoff bound.** With `B_k` the set of non-contracting
residues mod `2^k`, `|B_k|^5 · 8^k ≤ 243^k`. -/
theorem card_noncontracting_pow_le (k : ℕ) :
    (noncontracting k).card ^ 5 * 8 ^ k ≤ 243 ^ k := by
  set q := (3 * k + 4) / 5 with hqdef
  have hq5 : 3 * k ≤ 5 * q := by omega
  have hstep : ∀ n ∈ noncontracting k, 2 ^ q ≤ 2 ^ onesCount k n := by
    intro n hn
    have h := (mem_noncontracting_iff k n).mp hn
    have h5 := five_mul_onesCount_ge h.2
    exact Nat.pow_le_pow_right (by norm_num) (by omega)
  have hsum : (noncontracting k).card * 2 ^ q ≤ 3 ^ k := by
    calc (noncontracting k).card * 2 ^ q
        = ∑ _n ∈ noncontracting k, 2 ^ q := by rw [Finset.sum_const, smul_eq_mul]
      _ ≤ ∑ n ∈ noncontracting k, 2 ^ onesCount k n := Finset.sum_le_sum hstep
      _ ≤ ∑ n ∈ Finset.range (2 ^ k), 2 ^ onesCount k n :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
            (fun i _ _ => Nat.zero_le _)
      _ = 3 ^ k := sum_two_pow_onesCount k
  have hpow : (8 : ℕ) ^ k ≤ 2 ^ (5 * q) := by
    have h8 : (8 : ℕ) ^ k = 2 ^ (3 * k) := by rw [pow_mul]; norm_num
    rw [h8]
    exact Nat.pow_le_pow_right (by norm_num) hq5
  calc (noncontracting k).card ^ 5 * 8 ^ k
      ≤ (noncontracting k).card ^ 5 * 2 ^ (5 * q) :=
        Nat.mul_le_mul_left _ hpow
    _ = ((noncontracting k).card * 2 ^ q) ^ 5 := by
        rw [mul_pow, ← pow_mul, mul_comm q 5]
    _ ≤ (3 ^ k) ^ 5 := Nat.pow_le_pow_left hsum 5
    _ = 243 ^ k := by rw [← pow_mul, mul_comm k 5, pow_mul]; norm_num

/-- **Exponential decay of the non-contracting density.** Writing
`ρ_k = |B_k| / 2^k` for the density of residues mod `2^k` failing to contract,
`ρ_k^5 ≤ (243/256)^k`. Since `243/256 < 1`, the density decays exponentially in
`k` — strictly stronger than the Chebyshev bound `1/(4δ²k)`. -/
theorem noncontracting_density_pow_le (k : ℕ) :
    (((noncontracting k).card : ℝ) / 2 ^ k) ^ 5 ≤ ((243 : ℝ) / 256) ^ k := by
  have hkey := card_noncontracting_pow_le k
  have hR : (((noncontracting k).card : ℝ)) ^ 5 * 8 ^ k ≤ 243 ^ k := by
    have := (Nat.cast_le (α := ℝ)).mpr hkey
    push_cast at this
    exact this
  have h2 : (0 : ℝ) < 2 ^ k := by positivity
  have h8 : (0 : ℝ) < 8 ^ k := by positivity
  rw [div_pow, div_pow, div_le_div_iff₀ (by positivity) (by positivity)]
  have hfact : ((2 : ℝ) ^ k) ^ 5 = 32 ^ k := by
    rw [← pow_mul, mul_comm k 5, pow_mul]; norm_num
  have h256 : (256 : ℝ) ^ k = 32 ^ k * 8 ^ k := by
    rw [← mul_pow]; norm_num
  rw [hfact, h256]
  nlinarith [hR, pow_pos (show (0:ℝ) < 32 by norm_num) k, h8]

/-- The decay rate is genuinely exponential: `243/256 < 1`. -/
theorem decay_rate_lt_one : (243 : ℝ) / 256 < 1 := by norm_num

/-! ## §4. Exponentially small failure density for actual integers -/

theorem card_noncontracting_le_two_pow (k : ℕ) : (noncontracting k).card ≤ 2 ^ k := by
  have h := Finset.card_le_card (Finset.filter_subset
    (fun n => contractionExp k (onesCount k n) ≤ 0) (Finset.range (2 ^ k)))
  simpa [noncontracting] using h

/-- **Exponentially small failure density.** Counting integers up to `N = 64^k`,
the proportion failing to descend in `k` accelerated Collatz steps is at most
the dyadic density `ρ_k` plus `2/8^k`; combined with
`noncontracting_density_pow_le` this is exponentially small in `k`. -/
theorem nondescending_density_at_scale (k : ℕ) :
    ((nondescending k (64 ^ k)).card : ℝ) / 64 ^ k
      ≤ ((noncontracting k).card : ℝ) / 2 ^ k + 2 / 8 ^ k := by
  have hN : 0 < 64 ^ k := by positivity
  have h := nondescending_density_bound_general k (64 ^ k) hN
  have hcast : (((64 : ℕ) ^ k : ℕ) : ℝ) = (64 : ℝ) ^ k := by push_cast; ring
  rw [hcast] at h
  refine h.trans ?_
  have hnc : ((noncontracting k).card : ℝ) ≤ 2 ^ k := by
    have := (Nat.cast_le (α := ℝ)).mpr (card_noncontracting_le_two_pow k)
    push_cast at this
    exact this
  have h2 : (0 : ℝ) < 2 ^ k := by positivity
  have h8 : (0 : ℝ) < (8 : ℝ) ^ k := by positivity
  have h64 : ((64 : ℝ)) ^ k = 8 ^ k * 8 ^ k := by rw [← mul_pow]; norm_num
  have hkey : (((noncontracting k).card : ℝ) + 2 ^ k * 4 ^ k) / (64 : ℝ) ^ k ≤ 2 / 8 ^ k := by
    rw [h64, div_le_div_iff₀ (by positivity) h8]
    have h24 : (2 : ℝ) ^ k * 4 ^ k = 8 ^ k := by rw [← mul_pow]; norm_num
    have h2le : (2 : ℝ) ^ k ≤ 8 ^ k := by
      exact pow_le_pow_left₀ (by norm_num) (by norm_num) k
    nlinarith [hnc, h8, h2le, h24]
  linarith

/-- The final quantitative statement: at `N = 64^k`, the density of integers
failing to descend, minus the `2/8^k` boundary term, has fifth power at most
`(243/256)^k`. Both correction terms are exponentially small in `k`. -/
theorem nondescending_density_at_scale_decay (k : ℕ) :
    (((nondescending k (64 ^ k)).card : ℝ) / 64 ^ k - 2 / 8 ^ k) ^ 5
      ≤ ((243 : ℝ) / 256) ^ k := by
  have h := nondescending_density_at_scale k
  have hle : ((nondescending k (64 ^ k)).card : ℝ) / 64 ^ k - 2 / 8 ^ k
      ≤ ((noncontracting k).card : ℝ) / 2 ^ k := by linarith
  have hodd : Odd 5 := by decide
  calc (((nondescending k (64 ^ k)).card : ℝ) / 64 ^ k - 2 / 8 ^ k) ^ 5
      ≤ (((noncontracting k).card : ℝ) / 2 ^ k) ^ 5 := by
        exact (hodd.pow_le_pow (R := ℝ)).mpr hle
    _ ≤ ((243 : ℝ) / 256) ^ k := noncontracting_density_pow_le k

end CollatzParity