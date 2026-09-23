/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Catalog.Physics.InfoFreeWerewolf.Bounds

/-!
# Parity-corrected asymptotics of the information-free game

This file proves the main conjecture: **for every fixed wolf count `k ≥ 1` the
wolf-win probability of the information-free game has two distinct asymptotic
expansions according to the parity of the initial population**, with the same
leading behaviour but different first-order constants whose ratio is exactly `π/2`.

## Main results

* `surv_eq_wallis_mul`  : `surv (2m+1) = W m * surv (2m)`, where `W` is the Wallis
  partial product.  Combined with `surv n * surv (n+1) = 1/(n+1)` this yields the exact
  identities `(2m+1) * surv(2m+1)^2 = W m` and `(2m+1) * surv(2m)^2 * W m = 1`.
* `tendsto_scaled_surv_even_pop` / `tendsto_scaled_surv_odd_pop` :
  `√n · surv n → √(2/π)` along even `n`, and `→ √(π/2)` along odd `n`.
* `tendsto_scaled_failProb_even_pop` / `tendsto_scaled_failProb_odd_pop` :
  for every `k`, `√n · failProb (n-k) k → k √(2/π)` along even `n` and
  `→ k √(π/2)` along odd `n`.
* `parity_constant_ratio` : `√(π/2) / √(2/π) = π/2` — the two first-order constants
  differ by exactly the Wallis factor, *independently of `k`*.
* `not_tendsto_scaled_failProb` : consequently, for `k ≥ 1` the scaled sequence
  `√n · failProb (n-k) k` does **not** converge; the even/odd oscillation is genuine.
* `tendsto_villageWin_even_pop` / `tendsto_villageWin_odd_pop` : the village
  nevertheless wins with probability tending to `1` along either parity.

The proof route is: exact one-wolf product formula (`Exact.lean`) → exact Wallis
identities → parity-split square-root limits → transport to general `k` by the
two-sided union bound of `Bounds.lean`.
-/

namespace InfoFreeWerewolf

open Real Filter Topology

/-! ### Exact Wallis identities for the survival products -/

/-- The odd survival product is the Wallis partial product times the even one. -/
theorem surv_eq_wallis_mul : ∀ m : ℕ,
    ((surv (2 * m + 1) : ℚ) : ℝ) = Real.Wallis.W m * ((surv (2 * m) : ℚ) : ℝ)
  | 0 => by norm_num [Real.Wallis.W]
  | (m + 1) => by
      have h := surv_eq_wallis_mul m
      have e1 : 2 * (m + 1) + 1 = (2 * m + 1) + 2 := by omega
      have e2 : 2 * (m + 1) = (2 * m) + 2 := by omega
      rw [e1, e2, surv_succ_succ, surv_succ_succ, Real.Wallis.W_succ]
      push_cast
      push_cast at h
      rw [h]
      have h1 : (2 * (m : ℝ) + 1) ≠ 0 := by positivity
      have h2 : (2 * (m : ℝ) + 2) ≠ 0 := by positivity
      have h3 : (2 * (m : ℝ) + 3) ≠ 0 := by positivity
      field_simp
      ring

theorem surv_mul_succ_real (m : ℕ) :
    ((surv (2 * m) : ℚ) : ℝ) * ((surv (2 * m + 1) : ℚ) : ℝ) = 1 / (2 * (m : ℝ) + 1) := by
  have h := congrArg (fun q : ℚ => (q : ℝ)) (surv_mul_succ m)
  push_cast at h
  exact h

theorem surv_nonneg_real (n : ℕ) : (0 : ℝ) ≤ ((surv n : ℚ) : ℝ) := by
  exact_mod_cast (surv_pos n).le

/-- Exact identity in the odd-population case. -/
theorem sq_odd (m : ℕ) :
    (2 * (m : ℝ) + 1) * ((surv (2 * m + 1) : ℚ) : ℝ) ^ 2 = Real.Wallis.W m := by
  have h1 := surv_eq_wallis_mul m
  have h2 := surv_mul_succ_real m
  have hne : (2 * (m : ℝ) + 1) ≠ 0 := by positivity
  field_simp at h2
  rw [h1] at h2 ⊢
  linear_combination (Real.Wallis.W m) * h2

/-- Exact identity in the even-population case. -/
theorem sq_even (m : ℕ) :
    (2 * (m : ℝ) + 1) * ((surv (2 * m) : ℚ) : ℝ) ^ 2 * Real.Wallis.W m = 1 := by
  have h1 := surv_eq_wallis_mul m
  have h2 := surv_mul_succ_real m
  have hne : (2 * (m : ℝ) + 1) ≠ 0 := by positivity
  field_simp at h2
  rw [h1] at h2
  linear_combination h2

/-! ### Square-root limits, split by parity -/

theorem tendsto_2m1_atTop : Tendsto (fun m : ℕ => 2 * (m : ℝ) + 1) atTop atTop :=
  tendsto_atTop_add_const_right _ 1 (tendsto_natCast_atTop_atTop.const_mul_atTop (by norm_num))

theorem tendsto_inv_2m1 : Tendsto (fun m : ℕ => (2 * (m : ℝ) + 1)⁻¹) atTop (𝓝 0) :=
  tendsto_2m1_atTop.inv_tendsto_atTop

theorem scaled_surv_odd_eq (m : ℕ) :
    Real.sqrt (2 * (m : ℝ) + 1) * ((surv (2 * m + 1) : ℚ) : ℝ) = Real.sqrt (Real.Wallis.W m) := by
  rw [← sq_odd m, Real.sqrt_mul (by positivity), Real.sqrt_sq (surv_nonneg_real _)]

/-- **Odd populations.**  `√n · surv n → √(π/2)` along `n = 2m+1`. -/
theorem tendsto_scaled_surv_odd_pop :
    Tendsto (fun m : ℕ => Real.sqrt (2 * (m : ℝ) + 1) * ((surv (2 * m + 1) : ℚ) : ℝ)) atTop
      (𝓝 (Real.sqrt (π / 2))) := by
  simp only [scaled_surv_odd_eq]
  exact (Real.continuous_sqrt.tendsto _).comp Real.Wallis.tendsto_W_nhds_pi_div_two

theorem tendsto_scaled_sq_even :
    Tendsto (fun m : ℕ => (2 * (m : ℝ) + 1) * ((surv (2 * m) : ℚ) : ℝ) ^ 2) atTop (𝓝 (2 / π)) := by
  have hpi : (π / 2) ≠ 0 := by positivity
  have h : Tendsto (fun m : ℕ => (Real.Wallis.W m)⁻¹) atTop (𝓝 (π / 2)⁻¹) :=
    Real.Wallis.tendsto_W_nhds_pi_div_two.inv₀ hpi
  rw [inv_div] at h
  refine h.congr fun m => ?_
  have hW : Real.Wallis.W m ≠ 0 := ne_of_gt (Real.Wallis.W_pos m)
  field_simp
  linear_combination -sq_even m

/-- **Even populations.**  `√n · surv n → √(2/π)` along `n = 2m`. -/
theorem tendsto_scaled_surv_even_pop :
    Tendsto (fun m : ℕ => Real.sqrt (2 * (m : ℝ)) * ((surv (2 * m) : ℚ) : ℝ)) atTop
      (𝓝 (Real.sqrt (2 / π))) := by
  have hs2 : Tendsto (fun m : ℕ => ((surv (2 * m) : ℚ) : ℝ) ^ 2) atTop (𝓝 0) := by
    have h := tendsto_scaled_sq_even.mul tendsto_inv_2m1
    simp only [mul_zero] at h
    refine h.congr fun m => ?_
    have hne : (2 * (m : ℝ) + 1) ≠ 0 := by positivity
    field_simp
  have hg : Tendsto (fun m : ℕ => 2 * (m : ℝ) * ((surv (2 * m) : ℚ) : ℝ) ^ 2) atTop
      (𝓝 (2 / π)) := by
    have h := tendsto_scaled_sq_even.sub hs2
    simp only [sub_zero] at h
    refine h.congr fun m => ?_
    ring
  have h2 := (Real.continuous_sqrt.tendsto _).comp hg
  refine h2.congr fun m => ?_
  simp only [Function.comp_apply]
  rw [Real.sqrt_mul (by positivity), Real.sqrt_sq (surv_nonneg_real _)]

/-! ### Transporting the limits to an arbitrary wolf count -/

/-- Generic transfer lemma.  Along any sequence of populations `n m → ∞` (eventually at
least `k`) for which the scaled single-wolf survival probability converges to `L`, the
scaled `k`-wolf wolf-win probability converges to `k · L`.  This is where the two-sided
union bound of `Bounds.lean` is used. -/
theorem tendsto_scaled_failProb_of (k : ℕ) (n : ℕ → ℕ) (L : ℝ)
    (hn : Tendsto (fun m => ((n m : ℕ) : ℝ)) atTop atTop)
    (hk : ∀ᶠ m in atTop, k ≤ n m)
    (hL : Tendsto (fun m => Real.sqrt ((n m : ℝ)) * ((surv (n m) : ℚ) : ℝ)) atTop (𝓝 L)) :
    Tendsto (fun m => Real.sqrt ((n m : ℝ)) * ((failProb (n m - k) k : ℚ) : ℝ)) atTop
      (𝓝 ((k : ℝ) * L)) := by
  obtain ⟨A, hA0, hA⟩ := failProb_sandwich k
  have hsqrt : Tendsto (fun m => Real.sqrt ((n m : ℝ))) atTop atTop :=
    Real.tendsto_sqrt_atTop.comp hn
  have hzero : Tendsto (fun m => Real.sqrt ((n m : ℝ)) / (n m : ℝ)) atTop (𝓝 0) := by
    simp only [Real.sqrt_div_self]
    exact hsqrt.inv_tendsto_atTop
  have hupper := hL.const_mul (k : ℝ)
  have hlower : Tendsto
      (fun m => (k : ℝ) * (Real.sqrt ((n m : ℝ)) * ((surv (n m) : ℚ) : ℝ))
        - (A : ℝ) * (Real.sqrt ((n m : ℝ)) / (n m : ℝ))) atTop (𝓝 ((k : ℝ) * L)) := by
    have h := hupper.sub (hzero.const_mul (A : ℝ))
    simpa using h
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlower hupper ?_ ?_
  · filter_upwards [hk] with m hkm
    obtain ⟨h1, -⟩ := hA (n m - k)
    have hidx : (n m - k) + k = n m := by omega
    rw [hidx] at h1
    have hcast : ((n m - k : ℕ) : ℚ) + k = (n m : ℚ) := by
      have h : ((n m - k : ℕ) : ℚ) = (n m : ℚ) - k := by
        push_cast [Nat.cast_sub hkm]; ring
      rw [h]; ring
    rw [hcast] at h1
    have h1R : (k : ℝ) * ((surv (n m) : ℚ) : ℝ) - (A : ℝ) / (n m : ℝ)
        ≤ ((failProb (n m - k) k : ℚ) : ℝ) := by
      have h2 := (Rat.cast_le (K := ℝ)).2 h1
      push_cast at h2
      exact h2
    have hs : 0 ≤ Real.sqrt ((n m : ℝ)) := Real.sqrt_nonneg _
    have h3 := mul_le_mul_of_nonneg_left h1R hs
    calc (k : ℝ) * (Real.sqrt ((n m : ℝ)) * ((surv (n m) : ℚ) : ℝ))
          - (A : ℝ) * (Real.sqrt ((n m : ℝ)) / (n m : ℝ))
        = Real.sqrt ((n m : ℝ)) * ((k : ℝ) * ((surv (n m) : ℚ) : ℝ) - (A : ℝ) / (n m : ℝ)) := by
          ring
      _ ≤ Real.sqrt ((n m : ℝ)) * ((failProb (n m - k) k : ℚ) : ℝ) := h3
  · filter_upwards [hk] with m hkm
    obtain ⟨-, h2⟩ := hA (n m - k)
    have hidx : (n m - k) + k = n m := by omega
    rw [hidx] at h2
    have h2R : ((failProb (n m - k) k : ℚ) : ℝ) ≤ (k : ℝ) * ((surv (n m) : ℚ) : ℝ) := by
      have h3 := (Rat.cast_le (K := ℝ)).2 h2
      push_cast at h3
      exact h3
    have hs : 0 ≤ Real.sqrt ((n m : ℝ)) := Real.sqrt_nonneg _
    have h4 := mul_le_mul_of_nonneg_left h2R hs
    calc Real.sqrt ((n m : ℝ)) * ((failProb (n m - k) k : ℚ) : ℝ)
        ≤ Real.sqrt ((n m : ℝ)) * ((k : ℝ) * ((surv (n m) : ℚ) : ℝ)) := h4
      _ = (k : ℝ) * (Real.sqrt ((n m : ℝ)) * ((surv (n m) : ℚ) : ℝ)) := by ring

/-- **Even-population asymptotics for every wolf count.** -/
theorem tendsto_scaled_failProb_even_pop (k : ℕ) :
    Tendsto (fun m : ℕ => Real.sqrt (2 * (m : ℝ)) * ((failProb (2 * m - k) k : ℚ) : ℝ)) atTop
      (𝓝 ((k : ℝ) * Real.sqrt (2 / π))) := by
  have hn : Tendsto (fun m : ℕ => ((2 * m : ℕ) : ℝ)) atTop atTop := by
    simpa using tendsto_natCast_atTop_atTop.const_mul_atTop (show (0 : ℝ) < 2 by norm_num)
  have hk : ∀ᶠ m : ℕ in atTop, k ≤ 2 * m := by
    filter_upwards [eventually_ge_atTop k] with m hm
    omega
  have hL : Tendsto (fun m : ℕ => Real.sqrt (((2 * m : ℕ) : ℝ)) * ((surv (2 * m) : ℚ) : ℝ)) atTop
      (𝓝 (Real.sqrt (2 / π))) := by
    simpa using tendsto_scaled_surv_even_pop
  simpa using tendsto_scaled_failProb_of k (fun m => 2 * m) _ hn hk hL

/-- **Odd-population asymptotics for every wolf count.** -/
theorem tendsto_scaled_failProb_odd_pop (k : ℕ) :
    Tendsto (fun m : ℕ => Real.sqrt (2 * (m : ℝ) + 1) * ((failProb (2 * m + 1 - k) k : ℚ) : ℝ))
      atTop (𝓝 ((k : ℝ) * Real.sqrt (π / 2))) := by
  have hn : Tendsto (fun m : ℕ => ((2 * m + 1 : ℕ) : ℝ)) atTop atTop := by
    simpa using tendsto_2m1_atTop
  have hk : ∀ᶠ m : ℕ in atTop, k ≤ 2 * m + 1 := by
    filter_upwards [eventually_ge_atTop k] with m hm
    omega
  have hL : Tendsto
      (fun m : ℕ => Real.sqrt (((2 * m + 1 : ℕ) : ℝ)) * ((surv (2 * m + 1) : ℚ) : ℝ)) atTop
      (𝓝 (Real.sqrt (π / 2))) := by
    simpa using tendsto_scaled_surv_odd_pop
  simpa using tendsto_scaled_failProb_of k (fun m => 2 * m + 1) _ hn hk hL

/-! ### The parity gap -/

theorem sqrt_two_div_pi_pos : 0 < Real.sqrt (2 / π) := Real.sqrt_pos.2 (by positivity)

/-- **The two parity constants differ by exactly the Wallis factor `π/2`.**
This ratio is independent of the wolf count `k`, since both constants are
proportional to `k`. -/
theorem parity_constant_ratio : Real.sqrt (π / 2) / Real.sqrt (2 / π) = π / 2 := by
  rw [← Real.sqrt_div (by positivity)]
  have h : (π / 2) / (2 / π) = (π / 2) ^ 2 := by
    have := Real.pi_ne_zero
    field_simp
  rw [h, Real.sqrt_sq (by positivity)]

/-- The odd-population constant strictly exceeds the even-population one, for every
`k ≥ 1`: the two asymptotic expansions are genuinely different. -/
theorem parity_gap (k : ℕ) (hk : 1 ≤ k) :
    (k : ℝ) * Real.sqrt (2 / π) < (k : ℝ) * Real.sqrt (π / 2) := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hlt : Real.sqrt (2 / π) < Real.sqrt (π / 2) := by
    have hpi : (2 : ℝ) / π < π / 2 := by
      have h3 := Real.pi_gt_three
      have hp := Real.pi_pos
      rw [div_lt_div_iff₀ hp (by norm_num)]
      nlinarith
    exact Real.sqrt_lt_sqrt (by positivity) hpi
  exact mul_lt_mul_of_pos_left hlt (lt_of_lt_of_le zero_lt_one hkR)

/-- **The oscillation is real.**  For `k ≥ 1` the scaled wolf-win probability
`√n · failProb (n-k) k` has no limit as the population `n → ∞`: the even and odd
subsequences converge to different values.  In particular no single asymptotic
expansion in `n` can describe the game. -/
theorem not_tendsto_scaled_failProb (k : ℕ) (hk : 1 ≤ k) :
    ¬ ∃ L : ℝ, Tendsto (fun n : ℕ => Real.sqrt (n : ℝ) * ((failProb (n - k) k : ℚ) : ℝ))
      atTop (𝓝 L) := by
  rintro ⟨L, hL⟩
  have hev : Tendsto (fun m : ℕ => 2 * m) atTop atTop :=
    tendsto_atTop_atTop.2 fun b => ⟨b, fun a ha => by omega⟩
  have hod : Tendsto (fun m : ℕ => 2 * m + 1) atTop atTop :=
    tendsto_atTop_atTop.2 fun b => ⟨b, fun a ha => by omega⟩
  have h1 : Tendsto
      (fun m : ℕ => Real.sqrt (2 * (m : ℝ)) * ((failProb (2 * m - k) k : ℚ) : ℝ)) atTop
      (𝓝 L) := by
    have h := hL.comp hev
    simp only [Function.comp_def, Nat.cast_mul, Nat.cast_ofNat] at h
    exact h
  have h2 : Tendsto
      (fun m : ℕ => Real.sqrt (2 * (m : ℝ) + 1) * ((failProb (2 * m + 1 - k) k : ℚ) : ℝ)) atTop
      (𝓝 L) := by
    have h := hL.comp hod
    simp only [Function.comp_def, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one] at h
    exact h
  have e1 : L = (k : ℝ) * Real.sqrt (2 / π) :=
    tendsto_nhds_unique h1 (tendsto_scaled_failProb_even_pop k)
  have e2 : L = (k : ℝ) * Real.sqrt (π / 2) :=
    tendsto_nhds_unique h2 (tendsto_scaled_failProb_odd_pop k)
  have h3 := parity_gap k hk
  rw [← e1, ← e2] at h3
  exact lt_irrefl L h3

/-- **Headline form of the conjecture.**  For every fixed wolf count `k ≥ 1` the ratio of
the odd-population scaled wolf-win probability to the even-population one converges to
`π/2`, a constant independent of `k`. -/
theorem tendsto_parity_ratio (k : ℕ) (hk : 1 ≤ k) :
    Tendsto (fun m : ℕ =>
        (Real.sqrt (2 * (m : ℝ) + 1) * ((failProb (2 * m + 1 - k) k : ℚ) : ℝ)) /
          (Real.sqrt (2 * (m : ℝ)) * ((failProb (2 * m - k) k : ℚ) : ℝ))) atTop
      (𝓝 (π / 2)) := by
  have hk0 : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hne : (k : ℝ) * Real.sqrt (2 / π) ≠ 0 := by
    have := sqrt_two_div_pi_pos
    positivity
  have h := (tendsto_scaled_failProb_odd_pop k).div (tendsto_scaled_failProb_even_pop k) hne
  have hval : ((k : ℝ) * Real.sqrt (π / 2)) / ((k : ℝ) * Real.sqrt (2 / π)) = π / 2 := by
    rw [mul_div_mul_left _ _ (ne_of_gt hk0)]
    exact parity_constant_ratio
  rwa [hval] at h

/-! ### The village still wins asymptotically -/

/-- Along even populations the village win probability tends to `1` for every fixed
wolf count. -/
theorem tendsto_villageWin_even_pop (k : ℕ) :
    Tendsto (fun m : ℕ => ((villageWin (2 * m - k) k : ℚ) : ℝ)) atTop (𝓝 1) := by
  have hn : Tendsto (fun m : ℕ => Real.sqrt (2 * (m : ℝ))) atTop atTop :=
    Real.tendsto_sqrt_atTop.comp (by
      simpa using tendsto_natCast_atTop_atTop.const_mul_atTop (show (0 : ℝ) < 2 by norm_num))
  have hinv : Tendsto (fun m : ℕ => (Real.sqrt (2 * (m : ℝ)))⁻¹) atTop (𝓝 0) :=
    hn.inv_tendsto_atTop
  have hf : Tendsto (fun m : ℕ => ((failProb (2 * m - k) k : ℚ) : ℝ)) atTop (𝓝 0) := by
    have h := (tendsto_scaled_failProb_even_pop k).mul hinv
    rw [mul_zero] at h
    refine h.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with m hm
    have hmR : (0 : ℝ) < 2 * (m : ℝ) := by
      have hmm : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
      linarith
    have hs : Real.sqrt (2 * (m : ℝ)) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hmR)
    field_simp
  have h : Tendsto (fun m : ℕ => (1 : ℝ) - ((failProb (2 * m - k) k : ℚ) : ℝ)) atTop
      (𝓝 ((1 : ℝ) - 0)) := tendsto_const_nhds.sub hf
  rw [sub_zero] at h
  refine h.congr fun m => ?_
  simp [villageWin]

/-- Along odd populations the village win probability tends to `1` for every fixed
wolf count. -/
theorem tendsto_villageWin_odd_pop (k : ℕ) :
    Tendsto (fun m : ℕ => ((villageWin (2 * m + 1 - k) k : ℚ) : ℝ)) atTop (𝓝 1) := by
  have hn : Tendsto (fun m : ℕ => Real.sqrt (2 * (m : ℝ) + 1)) atTop atTop :=
    Real.tendsto_sqrt_atTop.comp tendsto_2m1_atTop
  have hinv : Tendsto (fun m : ℕ => (Real.sqrt (2 * (m : ℝ) + 1))⁻¹) atTop (𝓝 0) :=
    hn.inv_tendsto_atTop
  have hf : Tendsto (fun m : ℕ => ((failProb (2 * m + 1 - k) k : ℚ) : ℝ)) atTop (𝓝 0) := by
    have h := (tendsto_scaled_failProb_odd_pop k).mul hinv
    rw [mul_zero] at h
    refine h.congr fun m => ?_
    have hs : Real.sqrt (2 * (m : ℝ) + 1) ≠ 0 := by
      have hp : (0 : ℝ) < 2 * (m : ℝ) + 1 := by positivity
      exact ne_of_gt (Real.sqrt_pos.2 hp)
    field_simp
  have h : Tendsto (fun m : ℕ => (1 : ℝ) - ((failProb (2 * m + 1 - k) k : ℚ) : ℝ)) atTop
      (𝓝 ((1 : ℝ) - 0)) := tendsto_const_nhds.sub hf
  rw [sub_zero] at h
  refine h.congr fun m => ?_
  simp [villageWin]

end InfoFreeWerewolf