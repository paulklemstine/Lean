/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Probability.SparseEntropyBound

/-!
# The entropy estimate for sparse neural codes is exact up to `log (N + 1)`

`SparseEntropyBound.lean` proved the Chernoff-style *upper* bound

`∑_{j ≤ k} C(N, j) ≤ exp (N · binEntropy (k / N))`   (for `2k ≤ N`).

This file supplies the matching *lower* bound, so that the exponential rate of a
`k`-sparse neural population is pinned down exactly:

`exp (N · binEntropy (k / N)) / (N + 1) ≤ ∑_{j ≤ k} C(N, j)`.

The proof is the classical "method of types" argument.  Let `p = k / N` and
weight the patterns by the Bernoulli(`p`) product measure.  The weights
`T j = C(N, j) p^j (1-p)^{N-j}` sum to `1` over `0 ≤ j ≤ N` (binomial theorem),
and `T` is maximal at `j = k` precisely because `p = k / N`.  Hence
`1 ≤ (N + 1) T k`, and `T k = C(N,k) exp (-N binEntropy p)`.

## Main results

* `binTerm` — the Bernoulli weight `C(N,j) p^j (1-p)^{N-j}`;
* `binTerm_le_succ`, `binTerm_succ_le` — the weight increases up to `j = k` and
  decreases afterwards, when `p = k / N`;
* `binTerm_le_mode` — `k` is a mode of the binomial distribution `Bin(N, k/N)`;
* `sum_binTerm` — the weights sum to `1`;
* `exp_binEntropy_le_choose` — `exp (N · binEntropy (k/N)) ≤ (N + 1) · C(N,k)`;
* `sum_choose_ge_exp_binEntropy` — the lower bound for the sparse code size;
* `log_sum_choose_sub_entropy_abs_le` — combining with the upper bound of
  `SparseEntropyBound.lean`, `|log (∑_{j≤k} C(N,j)) - N·binEntropy(k/N)| ≤ log (N+1)`:
  the entropy estimate is exact to within an additive `log (N + 1)` nats, hence
  the *rate* `log (∑) / N` equals `binEntropy (k/N)` up to `O(log N / N)`.
-/

namespace Catalog.Probability.NeuralCoding.SparseEntropy

open Finset Real

/-- The Bernoulli(`p`) weight of the set of patterns of weight `j` on `N` neurons. -/
noncomputable def binTerm (p : ℝ) (N j : ℕ) : ℝ :=
  (N.choose j : ℝ) * (p ^ j * (1 - p) ^ (N - j))

theorem binTerm_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (N j : ℕ) :
    0 ≤ binTerm p N j := by
  have : (0 : ℝ) ≤ 1 - p := by linarith
  unfold binTerm
  positivity

/-- The Bernoulli weights sum to `1` (binomial theorem). -/
theorem sum_binTerm (p : ℝ) (N : ℕ) :
    ∑ j ∈ range (N + 1), binTerm p N j = 1 := by
  have hbin : (p + (1 - p)) ^ N =
      ∑ j ∈ range (N + 1), p ^ j * (1 - p) ^ (N - j) * (N.choose j : ℝ) :=
    add_pow p (1 - p) N
  simp only [add_sub_cancel, one_pow] at hbin
  unfold binTerm
  calc ∑ j ∈ range (N + 1), (N.choose j : ℝ) * (p ^ j * (1 - p) ^ (N - j))
      = ∑ j ∈ range (N + 1), p ^ j * (1 - p) ^ (N - j) * (N.choose j : ℝ) :=
        Finset.sum_congr rfl (fun j _ => by ring)
    _ = 1 := hbin.symm

/-- Cast form of the recurrence `C(N, j+1)·(j+1) = C(N, j)·(N - j)`. -/
theorem choose_succ_cast {N j : ℕ} (hj : j < N) :
    (N.choose (j + 1) : ℝ) * ((j : ℝ) + 1) = (N.choose j : ℝ) * ((N : ℝ) - j) := by
  have h : N.choose (j + 1) * (j + 1) = N.choose j * (N - j) := Nat.choose_succ_right_eq N j
  have hc : ((N.choose (j + 1) * (j + 1) : ℕ) : ℝ) = ((N.choose j * (N - j) : ℕ) : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) h
  push_cast [Nat.cast_sub hj.le] at hc
  linarith

/-- **Below the mode the binomial weight increases**: for `p = k/N` and `j < k`. -/
theorem binTerm_le_succ {N k j : ℕ} (hkN : k ≤ N) (hjk : j < k) :
    binTerm ((k : ℝ) / N) N j ≤ binTerm ((k : ℝ) / N) N (j + 1) := by
  have hjN : j < N := lt_of_lt_of_le hjk hkN
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := lt_of_le_of_lt (Nat.zero_le j) hjN
    exact_mod_cast this
  set p : ℝ := (k : ℝ) / N with hp
  have hp0 : 0 ≤ p := by rw [hp]; positivity
  have hp1 : p ≤ 1 := by
    rw [hp, div_le_one hNpos]; exact_mod_cast hkN
  have hq0 : (0 : ℝ) ≤ 1 - p := by linarith
  set m : ℕ := N - (j + 1) with hm
  have hsub : N - j = m + 1 := by omega
  have hineq : (1 - p) * ((j : ℝ) + 1) ≤ ((N : ℝ) - j) * p := by
    have hjk' : ((j : ℝ) + 1) ≤ (k : ℝ) := by exact_mod_cast hjk
    have hkN' : (k : ℝ) ≤ (N : ℝ) := by exact_mod_cast hkN
    have hk0 : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    rw [hp, ← sub_nonneg]
    have hrw : ((N : ℝ) - j) * ((k : ℝ) / N) - (1 - (k : ℝ) / N) * ((j : ℝ) + 1)
        = (((N : ℝ) - j) * k - ((N : ℝ) - k) * ((j : ℝ) + 1)) / N := by
      field_simp
    rw [hrw]
    refine div_nonneg ?_ hNpos.le
    nlinarith
  have hApos : (0 : ℝ) ≤ (N.choose j : ℝ) * (p ^ j * (1 - p) ^ m) := by positivity
  have hchoose := choose_succ_cast (N := N) (j := j) hjN
  have key : binTerm p N j * ((j : ℝ) + 1) ≤ binTerm p N (j + 1) * ((j : ℝ) + 1) := by
    unfold binTerm
    rw [hsub, show N - (j + 1) = m from hm.symm]
    have e1 : (N.choose j : ℝ) * (p ^ j * (1 - p) ^ (m + 1)) * ((j : ℝ) + 1)
        = ((N.choose j : ℝ) * (p ^ j * (1 - p) ^ m)) * ((1 - p) * ((j : ℝ) + 1)) := by ring
    have e2 : (N.choose (j + 1) : ℝ) * (p ^ (j + 1) * (1 - p) ^ m) * ((j : ℝ) + 1)
        = ((N.choose j : ℝ) * (p ^ j * (1 - p) ^ m)) * (((N : ℝ) - j) * p) := by
      have e : (N.choose (j + 1) : ℝ) * (p ^ (j + 1) * (1 - p) ^ m) * ((j : ℝ) + 1)
          = ((N.choose (j + 1) : ℝ) * ((j : ℝ) + 1)) * (p ^ (j + 1) * (1 - p) ^ m) := by ring
      rw [e, hchoose]; ring
    rw [e1, e2]
    exact mul_le_mul_of_nonneg_left hineq hApos
  have hjpos : (0 : ℝ) < (j : ℝ) + 1 := by positivity
  exact le_of_mul_le_mul_right key hjpos

/-- **Above the mode the binomial weight decreases**: for `p = k/N` and `k ≤ j < N`. -/
theorem binTerm_succ_le {N k j : ℕ} (hkN : k ≤ N) (hkj : k ≤ j) (hjN : j < N) :
    binTerm ((k : ℝ) / N) N (j + 1) ≤ binTerm ((k : ℝ) / N) N j := by
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := lt_of_le_of_lt (Nat.zero_le j) hjN
    exact_mod_cast this
  set p : ℝ := (k : ℝ) / N with hp
  have hp0 : 0 ≤ p := by rw [hp]; positivity
  have hp1 : p ≤ 1 := by
    rw [hp, div_le_one hNpos]; exact_mod_cast hkN
  have hq0 : (0 : ℝ) ≤ 1 - p := by linarith
  set m : ℕ := N - (j + 1) with hm
  have hsub : N - j = m + 1 := by omega
  have hineq : ((N : ℝ) - j) * p ≤ (1 - p) * ((j : ℝ) + 1) := by
    have hkj' : (k : ℝ) ≤ (j : ℝ) := by exact_mod_cast hkj
    have hjN' : ((j : ℝ) + 1) ≤ (N : ℝ) := by exact_mod_cast hjN
    have hk0 : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    rw [hp, ← sub_nonneg]
    have hrw : (1 - (k : ℝ) / N) * ((j : ℝ) + 1) - ((N : ℝ) - j) * ((k : ℝ) / N)
        = (((N : ℝ) - k) * ((j : ℝ) + 1) - ((N : ℝ) - j) * k) / N := by
      field_simp
    rw [hrw]
    refine div_nonneg ?_ hNpos.le
    nlinarith
  have hApos : (0 : ℝ) ≤ (N.choose j : ℝ) * (p ^ j * (1 - p) ^ m) := by positivity
  have hchoose := choose_succ_cast (N := N) (j := j) hjN
  have key : binTerm p N (j + 1) * ((j : ℝ) + 1) ≤ binTerm p N j * ((j : ℝ) + 1) := by
    unfold binTerm
    rw [hsub, show N - (j + 1) = m from hm.symm]
    have e1 : (N.choose j : ℝ) * (p ^ j * (1 - p) ^ (m + 1)) * ((j : ℝ) + 1)
        = ((N.choose j : ℝ) * (p ^ j * (1 - p) ^ m)) * ((1 - p) * ((j : ℝ) + 1)) := by ring
    have e2 : (N.choose (j + 1) : ℝ) * (p ^ (j + 1) * (1 - p) ^ m) * ((j : ℝ) + 1)
        = ((N.choose j : ℝ) * (p ^ j * (1 - p) ^ m)) * (((N : ℝ) - j) * p) := by
      have e : (N.choose (j + 1) : ℝ) * (p ^ (j + 1) * (1 - p) ^ m) * ((j : ℝ) + 1)
          = ((N.choose (j + 1) : ℝ) * ((j : ℝ) + 1)) * (p ^ (j + 1) * (1 - p) ^ m) := by ring
      rw [e, hchoose]; ring
    rw [e1, e2]
    exact mul_le_mul_of_nonneg_left hineq hApos
  have hjpos : (0 : ℝ) < (j : ℝ) + 1 := by positivity
  exact le_of_mul_le_mul_right key hjpos

/-- Weights below the mode. -/
theorem binTerm_le_mode_of_le {N k : ℕ} (hkN : k ≤ N) :
    ∀ d j : ℕ, k - j = d → j ≤ k →
      binTerm ((k : ℝ) / N) N j ≤ binTerm ((k : ℝ) / N) N k := by
  intro d
  induction d with
  | zero =>
      intro j hd _
      have hjk : j = k := by omega
      rw [hjk]
  | succ d ih =>
      intro j hd hjk
      have hlt : j < k := by omega
      exact le_trans (binTerm_le_succ hkN hlt) (ih (j + 1) (by omega) (by omega))

/-- Weights above the mode. -/
theorem binTerm_le_mode_of_ge {N k : ℕ} (hkN : k ≤ N) :
    ∀ j : ℕ, k ≤ j → j ≤ N → binTerm ((k : ℝ) / N) N j ≤ binTerm ((k : ℝ) / N) N k := by
  intro j hkj
  induction j, hkj using Nat.le_induction with
  | base => intro _; exact le_rfl
  | succ j hkj ih =>
      intro hjN
      have hj : j < N := by omega
      exact le_trans (binTerm_succ_le hkN hkj hj) (ih (by omega))

/-- **`k` is a mode of `Bin(N, k/N)`.** -/
theorem binTerm_le_mode {N k : ℕ} (hkN : k ≤ N) {j : ℕ} (hj : j ≤ N) :
    binTerm ((k : ℝ) / N) N j ≤ binTerm ((k : ℝ) / N) N k := by
  by_cases h : j ≤ k
  · exact binTerm_le_mode_of_le hkN (k - j) j rfl h
  · exact binTerm_le_mode_of_ge hkN j (by omega) hj

/-- **The modal weight is at least `1 / (N + 1)`.** -/
theorem one_le_succ_mul_binTerm {N k : ℕ} (hkN : k ≤ N) :
    1 ≤ ((N : ℝ) + 1) * binTerm ((k : ℝ) / N) N k := by
  have hsum := sum_binTerm ((k : ℝ) / N) N
  have hle : ∑ j ∈ range (N + 1), binTerm ((k : ℝ) / N) N j
      ≤ ∑ _j ∈ range (N + 1), binTerm ((k : ℝ) / N) N k := by
    refine Finset.sum_le_sum (fun j hj => ?_)
    exact binTerm_le_mode hkN (by simpa [Nat.lt_succ_iff] using mem_range.mp hj)
  rw [hsum, Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hle
  push_cast at hle
  linarith

/-- The entropy exponential is the reciprocal modal Bernoulli weight. -/
theorem exp_binEntropy_eq {N k : ℕ} (hk : 0 < k) (hkN : k < N) :
    Real.exp (N * Real.binEntropy ((k : ℝ) / N))
      = (((k : ℝ) / N) ^ k * (1 - (k : ℝ) / N) ^ (N - k))⁻¹ := by
  have hN : 0 < N := by omega
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  set p : ℝ := (k : ℝ) / N with hpdef
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hp0 : 0 < p := div_pos hkR hNR
  have hp1 : p < 1 := by
    rw [hpdef, div_lt_one hNR]; exact_mod_cast hkN
  have hq0 : (0 : ℝ) < 1 - p := by linarith
  have hNk : ((N - k : ℕ) : ℝ) = (N : ℝ) - k := Nat.cast_sub hkN.le
  have hexp : (N : ℝ) * Real.binEntropy p
      = (k : ℝ) * Real.log p⁻¹ + ((N : ℝ) - k) * Real.log (1 - p)⁻¹ := by
    have h1 : (N : ℝ) * p = k := by rw [hpdef]; field_simp
    have h2 : (N : ℝ) * (1 - p) = (N : ℝ) - k := by rw [mul_sub, mul_one, h1]
    simp only [Real.binEntropy]
    rw [mul_add, ← mul_assoc, ← mul_assoc, h1, h2]
  rw [hexp, Real.exp_add, ← hNk]
  have e1 : Real.exp ((k : ℝ) * Real.log p⁻¹) = (p⁻¹) ^ k := by
    rw [Real.exp_nat_mul, Real.exp_log (by positivity)]
  have e2 : Real.exp (((N - k : ℕ) : ℝ) * Real.log (1 - p)⁻¹) = ((1 - p)⁻¹) ^ (N - k) := by
    rw [Real.exp_nat_mul, Real.exp_log (by positivity)]
  rw [e1, e2, mul_inv, inv_pow, inv_pow]

/-- **Type-class lower bound.**  `exp (N · binEntropy (k/N)) ≤ (N + 1) · C(N, k)`. -/
theorem exp_binEntropy_le_choose {N k : ℕ} (hk : 0 < k) (hkN : k < N) :
    Real.exp ((N : ℝ) * Real.binEntropy ((k : ℝ) / N)) ≤ ((N : ℝ) + 1) * (N.choose k : ℝ) := by
  have hN : 0 < N := by omega
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  set p : ℝ := (k : ℝ) / N with hpdef
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hp0 : 0 < p := div_pos hkR hNR
  have hp1 : p < 1 := by rw [hpdef, div_lt_one hNR]; exact_mod_cast hkN
  have hw : (0 : ℝ) < p ^ k * (1 - p) ^ (N - k) := by
    have : (0 : ℝ) < 1 - p := by linarith
    positivity
  have hmode := one_le_succ_mul_binTerm (N := N) (k := k) hkN.le
  rw [binTerm] at hmode
  -- `1 ≤ (N+1) * (C(N,k) * w)` with `w = p^k (1-p)^{N-k}`
  have hstep : 1 ≤ (((N : ℝ) + 1) * (N.choose k : ℝ)) * (p ^ k * (1 - p) ^ (N - k)) := by
    rw [mul_assoc]; exact hmode
  rw [exp_binEntropy_eq hk hkN, ← hpdef]
  rw [inv_le_iff_one_le_mul₀ hw]
  linarith

/-- **Lower bound for sparse code size.**  For `0 < k` and `2k ≤ N`,
`exp (N · binEntropy (k/N)) / (N + 1) ≤ ∑_{j ≤ k} C(N, j)`. -/
theorem sum_choose_ge_exp_binEntropy {N k : ℕ} (hk : 0 < k) (h2k : 2 * k ≤ N) :
    Real.exp ((N : ℝ) * Real.binEntropy ((k : ℝ) / N)) / ((N : ℝ) + 1)
      ≤ ∑ j ∈ range (k + 1), (N.choose j : ℝ) := by
  have hkN : k < N := by omega
  have hNR : (0 : ℝ) < (N : ℝ) + 1 := by positivity
  have hmain := exp_binEntropy_le_choose hk hkN
  have hterm : (N.choose k : ℝ) ≤ ∑ j ∈ range (k + 1), (N.choose j : ℝ) := by
    refine Finset.single_le_sum (f := fun j => (N.choose j : ℝ)) (fun i _ => by positivity) ?_
    simp
  rw [div_le_iff₀ hNR]
  calc Real.exp ((N : ℝ) * Real.binEntropy ((k : ℝ) / N))
      ≤ ((N : ℝ) + 1) * (N.choose k : ℝ) := hmain
    _ ≤ (∑ j ∈ range (k + 1), (N.choose j : ℝ)) * ((N : ℝ) + 1) := by
        rw [mul_comm]
        exact mul_le_mul_of_nonneg_right hterm hNR.le

/-- **The entropy estimate is exact up to `log (N + 1)` nats.**  Combining the
Chernoff upper bound of `SparseEntropyBound.lean` with the type-class lower bound
above, the log-size of a `k`-sparse population code differs from
`N · binEntropy (k/N)` by at most `log (N + 1)`. -/
theorem log_sum_choose_sub_entropy_abs_le {N k : ℕ} (hk : 0 < k) (h2k : 2 * k ≤ N) :
    |Real.log (∑ j ∈ range (k + 1), (N.choose j : ℝ))
        - (N : ℝ) * Real.binEntropy ((k : ℝ) / N)| ≤ Real.log ((N : ℝ) + 1) := by
  have hkN : k < N := by omega
  have hNR : (0 : ℝ) < (N : ℝ) + 1 := by positivity
  have hpos : (0 : ℝ) < ∑ j ∈ range (k + 1), (N.choose j : ℝ) := by
    refine Finset.sum_pos (fun j hj => ?_) ⟨0, by simp⟩
    have hjk : j ≤ k := by simpa [Nat.lt_succ_iff] using mem_range.mp hj
    exact_mod_cast Nat.choose_pos (le_trans hjk hkN.le)
  have hup : Real.log (∑ j ∈ range (k + 1), (N.choose j : ℝ))
      ≤ (N : ℝ) * Real.binEntropy ((k : ℝ) / N) := by
    have h := sum_choose_le_exp_binEntropy N k hk h2k
    calc Real.log (∑ j ∈ range (k + 1), (N.choose j : ℝ))
        ≤ Real.log (Real.exp ((N : ℝ) * Real.binEntropy ((k : ℝ) / N))) :=
          Real.log_le_log hpos h
      _ = (N : ℝ) * Real.binEntropy ((k : ℝ) / N) := Real.log_exp _
  have hlow : (N : ℝ) * Real.binEntropy ((k : ℝ) / N) - Real.log ((N : ℝ) + 1)
      ≤ Real.log (∑ j ∈ range (k + 1), (N.choose j : ℝ)) := by
    have h := sum_choose_ge_exp_binEntropy hk h2k
    have hlg : Real.log (Real.exp ((N : ℝ) * Real.binEntropy ((k : ℝ) / N)) / ((N : ℝ) + 1))
        ≤ Real.log (∑ j ∈ range (k + 1), (N.choose j : ℝ)) := by
      refine Real.log_le_log (by positivity) h
    rw [Real.log_div (by positivity) (ne_of_gt hNR), Real.log_exp] at hlg
    linarith
  rw [abs_le]
  constructor <;> linarith

end Catalog.Probability.NeuralCoding.SparseEntropy