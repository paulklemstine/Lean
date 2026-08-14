/-
# A matching lower bound: the diffusion really needs `Θ((log N)²)` steps

`Algebra.SpectralFreeWitness` proves that `n = 8 (M+1)²` half-lazy diffusion steps
suffice for exact order recovery.  Here we prove the converse for the extremal
Mersenne cycle `r = 2^M - 1`: if `154 n ≤ M (M+1)` then the rounding **fails**,

  `round (1 / p_n(e)) ≠ r`,

so the quadratic step count is not an artefact of the analysis — the lacunary dyadic
diffusion genuinely needs `Ω((log N)²)` steps.  Together with the upper bound this
pins the diffusion time of the spectral free-witness at `Θ((log N)²)`.

Ingredients:

* `exp_neg_two_mul_le_one_sub` — the elementary bound `e^{-2δ} ≤ 1 - δ` for `δ ≤ 1/2`
  (the reverse of the usual `1 - δ ≤ e^{-δ}`), which converts the sharpness bound on
  the top eigenvalue into a lower bound on its `n`-th power.
* `lazyEigen_mersenne_ge` — `μ₁ ≥ 1 - 53/(M+1)` from the sharpness result.
* `heatReturn_ge_two_terms` — dropping all but the two leading spectral terms.

No `sorry`, no `native_decide`.
-/

import Mathlib
import Algebra.SpectralFreeWitness
import Algebra.SpectralFreeWitnessSharp

namespace SpectralFreeWitness

open Finset Real

/-- The reverse exponential bound: `e^{-2δ} ≤ 1 - δ` for `0 ≤ δ ≤ 1/2`. -/
lemma exp_neg_two_mul_le_one_sub (δ : ℝ) (h0 : 0 ≤ δ) (h1 : δ ≤ 1 / 2) :
    Real.exp (-(2 * δ)) ≤ 1 - δ := by
  have hexp : (1 : ℝ) + 2 * δ ≤ Real.exp (2 * δ) := by
    have := Real.add_one_le_exp (2 * δ)
    linarith
  have hpos : (0 : ℝ) < 1 + 2 * δ := by linarith
  have hstep : Real.exp (-(2 * δ)) ≤ 1 / (1 + 2 * δ) := by
    rw [Real.exp_neg, inv_eq_one_div]
    exact one_div_le_one_div_of_le hpos hexp
  have hfrac : 1 / (1 + 2 * δ) ≤ 1 - δ := by
    rw [div_le_iff₀ hpos]
    nlinarith
  linarith

/-- The half-lazy eigenvalue of the Mersenne cycle is at least `1 - 53/(M+1)`. -/
lemma lazyEigen_mersenne_ge (M : ℕ) (hM : 1 ≤ M) :
    1 - 53 / ((M : ℝ) + 1) ≤ lazyEigen (2 ^ M - 1) M 1 := by
  have h := dyadicEigen_mersenne_ge M hM
  have hMpos : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  rw [lazyEigen, le_div_iff₀ (by norm_num : (0 : ℝ) < 2)]
  have hexpand : (1 - 53 / ((M : ℝ) + 1)) * 2 = 2 - 106 / ((M : ℝ) + 1) := by ring
  rw [hexpand]
  linarith

/-- Keeping only the trivial character and the first nontrivial one. -/
lemma heatReturn_ge_two_terms (r M n : ℕ) (hr : 2 ≤ r) :
    (1 + (lazyEigen r M 1) ^ n) / (r : ℝ) ≤ heatReturn r M n := by
  have hr0 : (0 : ℝ) < r := by positivity
  have hrpos : 0 < r := by omega
  have h0 : 0 ∈ range r := mem_range.mpr (by omega)
  have h1 : (1 : ℕ) ∈ (range r).erase 0 := by
    rw [Finset.mem_erase, mem_range]
    exact ⟨by omega, by omega⟩
  have hsplit : ∑ k ∈ range r, (lazyEigen r M k) ^ n
      = (lazyEigen r M 0) ^ n + ∑ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n :=
    (Finset.add_sum_erase _ _ h0).symm
  have hsplit2 : ∑ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n
      = (lazyEigen r M 1) ^ n + ∑ k ∈ ((range r).erase 0).erase 1, (lazyEigen r M k) ^ n :=
    (Finset.add_sum_erase _ _ h1).symm
  have hrest : 0 ≤ ∑ k ∈ ((range r).erase 0).erase 1, (lazyEigen r M k) ^ n :=
    Finset.sum_nonneg fun i _ => pow_nonneg (lazyEigen_nonneg _ _ _) _
  rw [heatReturn, div_le_div_iff_of_pos_right hr0, hsplit, hsplit2,
    lazyEigen_zero r M, one_pow]
  linarith

/-- **Necessity of quadratic diffusion time.**  For the Mersenne cycle
`r = 2^M - 1` with `M ≥ 106`, any step count with `154 n ≤ M (M+1)` makes the rounding
of the heat-kernel value miss the order. -/
theorem heat_kernel_needs_quadratic_time (M n : ℕ) (hM : 106 ≤ M)
    (hn : 154 * n ≤ M * (M + 1)) :
    round (1 / heatReturn (2 ^ M - 1) M n) ≠ ((2 ^ M - 1 : ℕ) : ℤ) := by
  intro hround
  -- basic facts about the Mersenne cycle
  have hpow : (2 : ℕ) ^ 106 ≤ 2 ^ M := Nat.pow_le_pow_right (by norm_num) hM
  have h106 : (2 : ℕ) ^ 106 ≥ 4 := by
    calc (4 : ℕ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ 106 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
  set r : ℕ := 2 ^ M - 1 with hrdef
  have hr2 : 2 ≤ r := by omega
  have hrR : (r : ℝ) = (2 : ℝ) ^ M - 1 := by
    rw [hrdef, Nat.cast_sub (by omega)]
    push_cast
    ring
  have hMR : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  have hMbig : (106 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
  -- the top eigenvalue and its gap
  set δ : ℝ := 1 - lazyEigen r M 1 with hδ
  have hμle : lazyEigen r M 1 ≤ 1 := lazyEigen_le_one r M 1
  have hδ0 : 0 ≤ δ := by rw [hδ]; linarith
  have hδle : δ ≤ 53 / ((M : ℝ) + 1) := by
    have := lazyEigen_mersenne_ge M (by omega)
    rw [hδ]
    linarith
  have hδhalf : δ ≤ 1 / 2 := by
    have hb : (53 : ℝ) / ((M : ℝ) + 1) ≤ 1 / 2 := by
      rw [div_le_div_iff₀ hMR (by norm_num)]
      linarith
    linarith
  -- lower bound on the surviving spectral mass
  have hμ : lazyEigen r M 1 = 1 - δ := by rw [hδ]; ring
  have hexp1 : Real.exp (-(2 * δ)) ≤ lazyEigen r M 1 := by
    rw [hμ]
    exact exp_neg_two_mul_le_one_sub δ hδ0 hδhalf
  have hpow1 : Real.exp (-(2 * δ * n)) ≤ (lazyEigen r M 1) ^ n := by
    have hstep : (Real.exp (-(2 * δ))) ^ n ≤ (lazyEigen r M 1) ^ n :=
      pow_le_pow_left₀ (le_of_lt (Real.exp_pos _)) hexp1 n
    rwa [← Real.exp_nat_mul, show (n : ℝ) * -(2 * δ) = -(2 * δ * n) by ring] at hstep
  -- the exponent is small enough
  have hlog2 : (0.6931 : ℝ) < Real.log 2 := by
    have := Real.log_two_gt_d9
    linarith
  have hnR : 154 * (n : ℝ) ≤ (M : ℝ) * ((M : ℝ) + 1) := by exact_mod_cast hn
  have hexponent : 2 * δ * n ≤ (M : ℝ) * Real.log 2 := by
    have h1 : 2 * δ * n ≤ 2 * (53 / ((M : ℝ) + 1)) * n := by
      have hn0 : (0 : ℝ) ≤ n := Nat.cast_nonneg n
      nlinarith
    have h2 : 2 * (53 / ((M : ℝ) + 1)) * (n : ℝ) ≤ (M : ℝ) * 0.6931 := by
      have hexpand : 2 * (53 / ((M : ℝ) + 1)) * (n : ℝ) = (106 * (n : ℝ)) / ((M : ℝ) + 1) := by
        field_simp
        ring
      rw [hexpand, div_le_iff₀ hMR]
      nlinarith [hnR, Nat.cast_nonneg (α := ℝ) n]
    nlinarith [hMbig]
  have hexp2 : ((2 : ℝ) ^ M)⁻¹ ≤ Real.exp (-(2 * δ * n)) := by
    have h2M : ((2 : ℝ) ^ M) = Real.exp ((M : ℝ) * Real.log 2) := by
      rw [Real.exp_nat_mul, Real.exp_log (by norm_num : (0 : ℝ) < 2)]
    rw [h2M, ← Real.exp_neg, Real.exp_le_exp]
    linarith
  -- put the pieces together: the heat kernel is too large
  have hmass : ((2 : ℝ) ^ M)⁻¹ ≤ (lazyEigen r M 1) ^ n := le_trans hexp2 hpow1
  have hr0 : (0 : ℝ) < r := by
    rw [hrR]
    have : (4 : ℝ) ≤ 2 ^ M := by exact_mod_cast le_trans h106 hpow
    linarith
  have hlow : (1 + (lazyEigen r M 1) ^ n) / (r : ℝ) ≤ heatReturn r M n :=
    heatReturn_ge_two_terms r M n hr2
  -- but the rounding hypothesis forces it to be small
  have hp0 : 0 < heatReturn r M n :=
    lt_of_lt_of_le (by positivity) (heatReturn_lower r M n (by omega))
  have hfloor : ((r : ℤ) : ℝ) ≤ 1 / heatReturn r M n + 1 / 2 := by
    rw [round_eq, Int.floor_eq_iff] at hround
    exact hround.1
  have hinv : (r : ℝ) - 1 / 2 ≤ 1 / heatReturn r M n := by
    push_cast at hfloor
    linarith
  have hr2R : (2 : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr2
  have hrhalf : (0 : ℝ) < (r : ℝ) - 1 / 2 := by linarith
  have hple : heatReturn r M n ≤ 1 / ((r : ℝ) - 1 / 2) := by
    rw [le_div_iff₀ hrhalf]
    rw [le_div_iff₀ hp0] at hinv
    linarith
  -- contradiction: the surviving mass is bigger than the rounding tolerance
  have hkey : (1 + (lazyEigen r M 1) ^ n) / (r : ℝ) ≤ 1 / ((r : ℝ) - 1 / 2) :=
    le_trans hlow hple
  rw [div_le_div_iff₀ hr0 hrhalf] at hkey
  have hbig : 1 / ((2 : ℝ) * r - 1) < (lazyEigen r M 1) ^ n := by
    have h2r : (2 : ℝ) * r - 1 = 2 * ((2 : ℝ) ^ M - 1) - 1 := by rw [hrR]
    have hpowpos : (0 : ℝ) < (2 : ℝ) ^ M := by positivity
    have hgt : (2 : ℝ) ^ M < 2 * r - 1 := by
      rw [h2r]
      have : (4 : ℝ) ≤ 2 ^ M := by exact_mod_cast le_trans h106 hpow
      linarith
    calc 1 / ((2 : ℝ) * r - 1) < 1 / (2 : ℝ) ^ M := by
          apply one_div_lt_one_div_of_lt hpowpos hgt
      _ = ((2 : ℝ) ^ M)⁻¹ := one_div _
      _ ≤ (lazyEigen r M 1) ^ n := hmass
  have h2r1 : (0 : ℝ) < 2 * (r : ℝ) - 1 := by linarith
  rw [div_lt_iff₀ h2r1] at hbig
  nlinarith

end SpectralFreeWitness