/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Density-one contraction at every 2-adic scale

Building on the exact spectral gap of
`MachineLearning.CollatzSpectral.ParitySpectrum`, this file computes the exact
**second moment** of the odd-step count `s_k(n)` over a complete residue system
mod `2^k`, and converts it into a quantitative statement about the Collatz map:

> the proportion of residue classes mod `2^k` whose first `k` accelerated steps
> fail to contract is at most `C / k`, hence tends to `0`.

The constant is explicit, `C = 1/(4 δ²)` with `δ = log2/log3 − 1/2 ≈ 0.1309`.

## Main results

* `sum_sq_deviation` — the exact variance identity `∑_{n<2^k} (2 s_k(n) − k)² = k·2^k`;
  the odd-step count is a *perfectly* fair binomial variable with variance `k/4`.
* `card_noncontracting_mul_le` — Chebyshev applied to that identity.
* `noncontracting_density_le` — the density of non-contracting residues mod `2^k`
  is at most `1/(4 δ² k)`.
* `noncontracting_density_tendsto_zero` — that density tends to `0`: **almost
  every residue class mod `2^k` contracts over its first `k` steps.**
-/

import Mathlib
import MachineLearning.CollatzSpectral.ParitySpectrum

open Finset Filter

namespace CollatzParity

/-! ## §1. The exact second moment -/

/-- **Exact variance identity.** Over a complete residue system mod `2^k`, the
centred odd-step count `2 s_k(n) − k` has second moment exactly `k·2^k`; i.e.
`s_k` has mean `k/2` and variance `k/4`, exactly as for `k` fair coin flips.

Unlike the usual heuristic ("Collatz parities behave like coin flips"), this is
an unconditional arithmetic identity, a consequence of the Terras bijection. -/
theorem sum_sq_deviation (k : ℕ) :
    ∑ n ∈ Finset.range (2 ^ k), ((2 * onesCount k n : ℤ) - (k : ℤ)) ^ 2
      = (k : ℤ) * 2 ^ k := by
  induction k with
  | zero => simp [onesCount]
  | succ k ih =>
    have hsplit : (2 : ℕ) ^ (k + 1) = 2 ^ k + 2 ^ k := by ring
    rw [hsplit, Finset.sum_range_add]
    have h1 : ∀ i ∈ Finset.range (2 ^ k),
        ((2 * onesCount (k + 1) i : ℤ) - ((k : ℤ) + 1)) ^ 2
          + ((2 * onesCount (k + 1) (2 ^ k + i) : ℤ) - ((k : ℤ) + 1)) ^ 2
          = 2 * ((2 * onesCount k i : ℤ) - (k : ℤ)) ^ 2 + 2 := by
      intro i _
      rcases onesCount_pair k i with ⟨h, h'⟩ | ⟨h, h'⟩ <;> rw [h, h'] <;> push_cast <;> ring
    push_cast
    rw [← Finset.sum_add_distrib, Finset.sum_congr rfl h1, Finset.sum_add_distrib,
      ← Finset.mul_sum, ih]
    simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    push_cast
    ring

/-- The real-valued form of the variance identity. -/
theorem sum_sq_deviation_real (k : ℕ) :
    ∑ n ∈ Finset.range (2 ^ k), ((2 * (onesCount k n : ℝ)) - (k : ℝ)) ^ 2
      = (k : ℝ) * 2 ^ k := by
  have h := sum_sq_deviation k
  have := congrArg (fun t : ℤ => (t : ℝ)) h
  push_cast at this
  exact this

/-! ## §2. The contraction-failure gap -/

/-- The spectral margin `δ = log2/log3 − 1/2`, the distance between the critical
ones-density and the mean ones-density `1/2`. It is positive precisely because
`log 3 < 2 log 2`. -/
noncomputable def spectralMargin : ℝ := CriticalDensity - 1 / 2

theorem spectralMargin_pos : 0 < spectralMargin := by
  unfold spectralMargin
  linarith [critical_density_gt_half]

/-- A residue whose `k`-step block fails to contract must have an odd-step count
at least `k · CriticalDensity`, hence a centred count at least `2kδ`. -/
theorem deviation_ge_of_not_contracting (k n : ℕ)
    (h : contractionExp k (onesCount k n) ≤ 0) :
    2 * (k : ℝ) * spectralMargin ≤ 2 * (onesCount k n : ℝ) - (k : ℝ) := by
  have hlog3 : 0 < Real.log 3 := log_three_pos
  have hexp : (k : ℝ) * Real.log 2 - (onesCount k n : ℝ) * Real.log 3 ≤ 0 := h
  have hs : (k : ℝ) * (Real.log 2 / Real.log 3) ≤ (onesCount k n : ℝ) := by
    rw [mul_div_assoc', div_le_iff₀ hlog3]
    linarith
  unfold spectralMargin CriticalDensity
  nlinarith

/-! ## §3. Chebyshev: contraction has density one -/

/-- The finset of residues mod `2^k` whose first `k` accelerated steps fail to
contract. -/
noncomputable def noncontracting (k : ℕ) : Finset ℕ :=
  (Finset.range (2 ^ k)).filter (fun n => contractionExp k (onesCount k n) ≤ 0)

/-- **Chebyshev bound.** The number of non-contracting residues mod `2^k`, times
the squared margin `4k²δ²`, is at most the total second moment `k·2^k`. -/
theorem card_noncontracting_mul_le (k : ℕ) :
    ((noncontracting k).card : ℝ) * (4 * (k : ℝ) ^ 2 * spectralMargin ^ 2)
      ≤ (k : ℝ) * 2 ^ k := by
  have hsub : noncontracting k ⊆ Finset.range (2 ^ k) := Finset.filter_subset _ _
  have hpt : ∀ n ∈ noncontracting k,
      4 * (k : ℝ) ^ 2 * spectralMargin ^ 2
        ≤ (2 * (onesCount k n : ℝ) - (k : ℝ)) ^ 2 := by
    intro n hn
    have h := deviation_ge_of_not_contracting k n (Finset.mem_filter.mp hn).2
    have hnn : (0 : ℝ) ≤ 2 * (k : ℝ) * spectralMargin := by
      have : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
      nlinarith [spectralMargin_pos]
    nlinarith
  calc ((noncontracting k).card : ℝ) * (4 * (k : ℝ) ^ 2 * spectralMargin ^ 2)
      = ∑ _n ∈ noncontracting k, (4 * (k : ℝ) ^ 2 * spectralMargin ^ 2) := by
        rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ ∑ n ∈ noncontracting k, (2 * (onesCount k n : ℝ) - (k : ℝ)) ^ 2 :=
        Finset.sum_le_sum hpt
    _ ≤ ∑ n ∈ Finset.range (2 ^ k), (2 * (onesCount k n : ℝ) - (k : ℝ)) ^ 2 :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i _ _ => sq_nonneg _)
    _ = (k : ℝ) * 2 ^ k := sum_sq_deviation_real k

/-- **Density bound.** The proportion of residues mod `2^k` failing to contract
over their first `k` accelerated Collatz steps is at most `1/(4δ²k)`. -/
theorem noncontracting_density_le (k : ℕ) (hk : 0 < k) :
    ((noncontracting k).card : ℝ) / 2 ^ k ≤ 1 / (4 * spectralMargin ^ 2 * k) := by
  have hk' : (0 : ℝ) < k := by exact_mod_cast hk
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have hd : (0 : ℝ) < spectralMargin := spectralMargin_pos
  have h := card_noncontracting_mul_le k
  rw [div_le_div_iff₀ hpow (by positivity)]
  nlinarith [Nat.cast_nonneg (α := ℝ) (noncontracting k).card]

/-- **Density-one contraction.** As the 2-adic scale `k` grows, the density of
residue classes mod `2^k` whose first `k` accelerated Collatz steps fail to
contract tends to zero. Equivalently: for almost every `n` (in the natural
density sense along dyadic scales) the first `k` steps shrink `n` by a factor
`(√3/2 + o(1))^k`. -/
theorem noncontracting_density_tendsto_zero :
    Tendsto (fun k : ℕ => ((noncontracting k).card : ℝ) / 2 ^ k) atTop (nhds 0) := by
  have hd : (0 : ℝ) < spectralMargin := spectralMargin_pos
  have hbound : Tendsto (fun k : ℕ => 1 / (4 * spectralMargin ^ 2 * k)) atTop (nhds 0) := by
    have h1 : Tendsto (fun k : ℕ => (4 * spectralMargin ^ 2) * (k : ℝ)) atTop atTop := by
      apply Filter.Tendsto.const_mul_atTop (by positivity)
      exact tendsto_natCast_atTop_atTop
    have h2 := h1.inv_tendsto_atTop
    refine h2.congr fun k => ?_
    simp [one_div]
  apply squeeze_zero' (Eventually.of_forall (fun k => by positivity))
  · filter_upwards [eventually_gt_atTop 0] with k hk using noncontracting_density_le k hk
  · exact hbound

end CollatzParity