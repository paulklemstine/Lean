/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# From spectral density to genuine Collatz descent

The previous files are statements about *parity words* and *residue classes*.
This file cashes them in as statements about honest integers: for a set of
residue classes mod `2^k` of density `≥ 1 − 1/(4δ²k)`, **every sufficiently
large integer in those classes strictly decreases after `k` accelerated Collatz
steps**.

The bridge is again the Terras transport formula
`T^[k](r + 2^k m) = T^[k] r + 3^{s_k(r)} m`: on the class of `r` the `k`-step map
is affine with slope `3^{s_k(r)}/2^k`, so a contracting parity word forces
descent as soon as the class representative is large enough.

## Main results

* `contractionExp_pos_iff` — `0 < contractionExp k s ↔ 3^s < 2^k`; the analytic
  contraction condition is an exact arithmetic inequality.
* `iterate_T_le` — the crude bound `T^[k] x ≤ 2^k x`, giving a uniform threshold.
* `descent_of_contracting` — affine descent on a contracting residue class.
* `descent_uniform` — an explicit threshold `2^k·4^k` above which every integer
  in a contracting class descends in `k` steps.
* `density_one_descent` — the density of residues mod `2^k` enjoying uniform
  `k`-step descent is at least `1 − 1/(4δ²k) → 1`.
-/

import Mathlib
import MachineLearning.CollatzSpectral.DensityContraction

open Finset Filter

namespace CollatzParity

/-! ## §1. Contraction is an exact arithmetic inequality -/

/-- The analytic contraction condition `k·log 2 > s·log 3` is *equivalent* to the
arithmetic inequality `3^s < 2^k`. -/
theorem contractionExp_pos_iff (k s : ℕ) : 0 < contractionExp k s ↔ 3 ^ s < 2 ^ k := by
  have h3 : ((3 : ℝ)) ^ s = ((3 ^ s : ℕ) : ℝ) := by push_cast; ring
  have h2 : ((2 : ℝ)) ^ k = ((2 ^ k : ℕ) : ℝ) := by push_cast; ring
  constructor
  · intro h
    have hlog : (s : ℝ) * Real.log 3 < (k : ℝ) * Real.log 2 := by
      have : contractionExp k s = (k : ℝ) * Real.log 2 - (s : ℝ) * Real.log 3 := rfl
      linarith [this ▸ h]
    have : Real.log ((3 : ℝ) ^ s) < Real.log ((2 : ℝ) ^ k) := by
      rw [Real.log_pow, Real.log_pow]
      exact_mod_cast hlog
    have hlt : ((3 : ℝ)) ^ s < ((2 : ℝ)) ^ k :=
      (Real.log_lt_log_iff (by positivity) (by positivity)).mp this
    rw [h3, h2] at hlt
    exact_mod_cast hlt
  · intro h
    have hlt : ((3 : ℝ)) ^ s < ((2 : ℝ)) ^ k := by
      rw [h3, h2]; exact_mod_cast h
    have := Real.log_lt_log (by positivity) hlt
    rw [Real.log_pow, Real.log_pow] at this
    have hexp : contractionExp k s = (k : ℝ) * Real.log 2 - (s : ℝ) * Real.log 3 := rfl
    rw [hexp]
    linarith

/-! ## §2. A uniform growth bound for the accelerated map -/

theorem one_le_T {x : ℕ} (hx : 1 ≤ x) : 1 ≤ T x := by
  unfold T
  by_cases h : x % 2 = 0
  · simp only [h, if_true]
    omega
  · simp only [h, if_false]
    omega

theorem T_le_two_mul {x : ℕ} (hx : 1 ≤ x) : T x ≤ 2 * x := by
  unfold T
  by_cases h : x % 2 = 0
  · simp only [h, if_true]; omega
  · simp only [h, if_false]; omega

/-- Crude but uniform: `k` accelerated steps multiply a positive integer by at
most `2^k`. -/
theorem iterate_T_le (k : ℕ) {x : ℕ} (hx : 1 ≤ x) : T^[k] x ≤ 2 ^ k * x := by
  induction k with
  | zero => simp
  | succ k ih =>
    have h1 : 1 ≤ T^[k] x := by
      clear ih
      induction k with
      | zero => simpa using hx
      | succ k ihk => rw [Function.iterate_succ_apply']; exact one_le_T ihk
    rw [Function.iterate_succ_apply']
    calc T (T^[k] x) ≤ 2 * T^[k] x := T_le_two_mul h1
      _ ≤ 2 * (2 ^ k * x) := by omega
      _ = 2 ^ (k + 1) * x := by ring

/-! ## §3. Descent on a contracting residue class -/

theorem T_iterate_zero (k : ℕ) : T^[k] 0 = 0 := by
  induction k with
  | zero => simp
  | succ k ihk => rw [Function.iterate_succ_apply', ihk]; simp [T]

/-- **Affine descent.** On a residue class mod `2^k` whose parity word contracts
(`3^{s} < 2^k`), every representative `r + 2^k m` with `m > T^[k] r` strictly
decreases after `k` accelerated steps. -/
theorem descent_of_contracting (k r m : ℕ) (hcon : 3 ^ onesCount k r < 2 ^ k)
    (hm : T^[k] r < m) : T^[k] (r + 2 ^ k * m) < r + 2 ^ k * m := by
  rw [(terras k r m).1]
  have h1 : 3 ^ onesCount k r * m + m ≤ 2 ^ k * m := by
    have h2 : 3 ^ onesCount k r + 1 ≤ 2 ^ k := hcon
    nlinarith
  omega

/-- **Uniform threshold.** Above `2^k · 4^k`, every integer whose residue mod
`2^k` has a contracting parity word descends in `k` accelerated steps. -/
theorem descent_uniform (k n : ℕ)
    (hcon : 3 ^ onesCount k (n % 2 ^ k) < 2 ^ k) (hn : 2 ^ k * 4 ^ k ≤ n) :
    T^[k] n < n := by
  have hpow : 0 < 2 ^ k := by positivity
  have hnr : n % 2 ^ k + 2 ^ k * (n / 2 ^ k) = n := Nat.mod_add_div n (2 ^ k)
  have hmge : 4 ^ k ≤ n / 2 ^ k :=
    (Nat.le_div_iff_mul_le hpow).mpr (by rw [mul_comm] at hn; exact hn)
  have hrlt : n % 2 ^ k < 2 ^ k := Nat.mod_lt _ hpow
  have hsq : (2 : ℕ) ^ k * 2 ^ k = 4 ^ k := by rw [← mul_pow]; norm_num
  have hTr : T^[k] (n % 2 ^ k) < n / 2 ^ k := by
    rcases Nat.eq_zero_or_pos (n % 2 ^ k) with h0 | h0
    · rw [h0, T_iterate_zero]
      calc 0 < 4 ^ k := by positivity
        _ ≤ n / 2 ^ k := hmge
    · have h1 : T^[k] (n % 2 ^ k) ≤ 2 ^ k * (n % 2 ^ k) := iterate_T_le k h0
      have h2 : 2 ^ k * (n % 2 ^ k) < 2 ^ k * 2 ^ k := Nat.mul_lt_mul_of_pos_left hrlt hpow
      omega
  have := descent_of_contracting k (n % 2 ^ k) (n / 2 ^ k) hcon hTr
  rwa [hnr] at this

/-! ## §4. Density one descent -/

/-- The residues mod `2^k` whose parity word contracts. By `descent_uniform`
these are exactly the classes on which the `k`-step map descends above the
explicit threshold `2^k·4^k`. -/
noncomputable def descending (k : ℕ) : Finset ℕ :=
  Finset.range (2 ^ k) \ noncontracting k

/-- **Every descending class really descends.** -/
theorem mem_descending_descent (k r : ℕ) (hr : r ∈ descending k) :
    ∀ n, n % 2 ^ k = r → 2 ^ k * 4 ^ k ≤ n → T^[k] n < n := by
  intro n hn hlarge
  rw [descending, Finset.mem_sdiff, noncontracting, Finset.mem_filter] at hr
  obtain ⟨hmem, hnot⟩ := hr
  have hpos : 0 < contractionExp k (onesCount k r) := by
    by_contra hc
    exact hnot ⟨hmem, not_lt.mp hc⟩
  refine descent_uniform k n ?_ hlarge
  rw [hn]
  exact (contractionExp_pos_iff k _).mp hpos

theorem card_descending (k : ℕ) :
    ((descending k).card : ℝ) = 2 ^ k - ((noncontracting k).card : ℝ) := by
  have hsub : noncontracting k ⊆ Finset.range (2 ^ k) := Finset.filter_subset _ _
  have hc : (descending k).card = (Finset.range (2 ^ k)).card - (noncontracting k).card := by
    rw [descending]
    exact Finset.card_sdiff_of_subset hsub
  have hle : (noncontracting k).card ≤ (Finset.range (2 ^ k)).card := Finset.card_le_card hsub
  rw [hc]
  rw [Nat.cast_sub hle]
  simp

/-- **Density-one descent.** For every scale `k ≥ 1`, the proportion of residue
classes mod `2^k` on which the `k`-step accelerated Collatz map is *strictly
decreasing above the explicit threshold* `2^k·4^k` is at least `1 − 1/(4δ²k)`. -/
theorem density_one_descent (k : ℕ) (hk : 0 < k) :
    1 - 1 / (4 * spectralMargin ^ 2 * k) ≤ ((descending k).card : ℝ) / 2 ^ k := by
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have hdens := noncontracting_density_le k hk
  rw [card_descending k, sub_div, div_self (ne_of_gt hpow)]
  linarith [hdens]

/-- The lower bound tends to `1`: descent holds on a set of residue classes of
asymptotic density one. -/
theorem descending_density_tendsto_one :
    Tendsto (fun k : ℕ => 1 - 1 / (4 * spectralMargin ^ 2 * k)) atTop (nhds 1) := by
  have hd : (0 : ℝ) < spectralMargin := spectralMargin_pos
  have h1 : Tendsto (fun k : ℕ => (4 * spectralMargin ^ 2) * (k : ℝ)) atTop atTop := by
    apply Filter.Tendsto.const_mul_atTop (by positivity)
    exact tendsto_natCast_atTop_atTop
  have h2 : Tendsto (fun k : ℕ => 1 / (4 * spectralMargin ^ 2 * k)) atTop (nhds 0) := by
    have h3 := h1.inv_tendsto_atTop
    refine h3.congr fun k => ?_
    simp [one_div]
  simpa using tendsto_const_nhds.sub h2

end CollatzParity