import Mathlib

/-! # The deterministic backbone of the Cramér prime model

In Cramér's probabilistic model of the primes, an integer `n` is "prime" with
probability `1 / log n`.  The *expected number of model primes up to `N`* is the
finite sum

  `CramerSum N = ∑_{n=2}^N 1 / log n`.

This file develops the elementary deterministic facts about this sum:

* positivity of the summand `1 / log n` for `n ≥ 2`;
* monotonicity of the real function `x ↦ 1 / log x` on `x > 1`, and the resulting
  monotonicity of the natural-indexed summand;
* monotonicity of `CramerSum` in `N`;
* the standard sum-vs-integral comparison bounds for the decreasing positive
  integrand (left/right Riemann comparison); and
* an elementary `N / log N`-scale lower bound, exhibiting the prime-number-theorem
  order of growth without any deep analytic input.

All results use only finite sums and standard real analysis already in Mathlib
(`Real.log`, positivity/monotonicity lemmas, and
`Mathlib.Analysis.SumIntegralComparisons`).
-/

open Set MeasureTheory

namespace CramerPrimeModel

/-- The Cramér expectation sum: the expected number of "random primes" up to `N`
in Cramér's model, where `n` is prime with probability `1 / log n`. -/
noncomputable def CramerSum (N : ℕ) : ℝ := ∑ n ∈ Finset.Icc 2 N, (Real.log (n : ℝ))⁻¹

/-! ## Positivity of the summand -/

/-
For `n ≥ 2`, `log n` is strictly positive.
-/
lemma log_natCast_pos {n : ℕ} (hn : 2 ≤ n) : 0 < Real.log (n : ℝ) := by
  exact Real.log_pos <| Nat.one_lt_cast.mpr hn

/-
For `n ≥ 2`, the summand `1 / log n` is strictly positive.
-/
lemma cramerTerm_pos {n : ℕ} (hn : 2 ≤ n) : 0 < (Real.log (n : ℝ))⁻¹ := by
  exact inv_pos.mpr ( Real.log_pos ( Nat.one_lt_cast.mpr hn ) )

/-! ## Monotonicity of the summand -/

/-
The map `x ↦ 1 / log x` is antitone (decreasing) on `(1, ∞)`: for `1 < x ≤ y`,
both `log x` and `log y` are positive and `log x ≤ log y`, so the inverses reverse
the inequality.
-/
lemma invLog_antitoneOn : AntitoneOn (fun x : ℝ => (Real.log x)⁻¹) (Set.Ioi 1) := by
  exact fun x hx y hy hxy => inv_anti₀ ( Real.log_pos hx ) ( Real.log_le_log ( lt_trans zero_lt_one hx ) hxy )

/-
Monotonicity of the natural-indexed summand: if `3 ≤ m ≤ n` then
`1 / log n ≤ 1 / log m`.
-/
lemma cramerTerm_anti {m n : ℕ} (hm : 3 ≤ m) (hmn : m ≤ n) :
    (Real.log (n : ℝ))⁻¹ ≤ (Real.log (m : ℝ))⁻¹ := by
  gcongr;
  exact Real.log_pos <| by norm_cast; linarith;

/-! ## Monotonicity of the Cramér sum -/

/-
`CramerSum` is monotone in `N`: enlarging the range only adds nonnegative
terms.
-/
lemma cramerSum_mono {N M : ℕ} (h : N ≤ M) : CramerSum N ≤ CramerSum M := by
  exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.Icc_subset_Icc_right h ) fun _ _ _ => inv_nonneg.2 ( Real.log_nonneg ( by norm_cast; linarith [ Finset.mem_Icc.1 ‹_› ] ) )

/-! ## Sum-vs-integral comparison

We compare `CramerSum N` to integrals of the decreasing positive integrand
`x ↦ 1 / log x`, using `Mathlib.Analysis.SumIntegralComparisons`.

* The **lower** bound is the clean right-Riemann comparison over `[2, N+1]`.
* For the **upper** bound, the literal interval `[1, N]` is unusable because
  `1 / log x → +∞` as `x → 1⁺`, so `1 / log x` is not integrable near `1`.  We
  therefore use the standard reformulation that isolates the first term: with
  `f(n) ≤ ∫_{n-1}^n f` for `n ≥ 3` summed against the integral over `[2, N]`,
  giving `CramerSum N ≤ 1/log 2 + ∫_2^N 1/log x dx`.  This matches the usual
  left-Riemann comparison while staying inside the integrable range `[2, N]`. -/

/-
Lower bound: the integral of `1 / log x` over `[2, N+1]` is at most
`CramerSum N`.
-/
theorem cramerSum_lower_integral {N : ℕ} (hN : 3 ≤ N) :
    (∫ x in (2 : ℝ)..((N : ℝ) + 1), (Real.log x)⁻¹) ≤ CramerSum N := by
  have h_integral_le_sum : ∫ x in (2 : ℝ)..((N + 1) : ℝ), (Real.log x)⁻¹ ≤ ∑ k ∈ Finset.Ico 2 (N + 1), ∫ x in (k : ℝ)..((k + 1) : ℝ), (Real.log x)⁻¹ := by
    convert le_of_eq ?_;
    erw [ Finset.sum_Ico_eq_sum_range ];
    symm;
    convert intervalIntegral.sum_integral_adjacent_intervals _ <;> norm_num;
    · ring;
    · rw [ Nat.cast_sub ] <;> push_cast <;> linarith;
    · intro k hk; apply_rules [ ContinuousOn.intervalIntegrable ];
      exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.inv₀ ( Real.continuousAt_log ( by cases Set.mem_uIcc.mp hx <;> linarith ) ) ( ne_of_gt ( Real.log_pos ( by cases Set.mem_uIcc.mp hx <;> linarith ) ) );
  refine le_trans h_integral_le_sum <| Finset.sum_le_sum fun i hi => ?_;
  refine' le_trans ( intervalIntegral.integral_mono_on _ _ _ _ ) _ <;> norm_num;
  refine' fun x => ( Real.log i ) ⁻¹;
  · apply_rules [ ContinuousOn.intervalIntegrable ];
    exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.inv₀ ( Real.continuousAt_log ( by cases Set.mem_uIcc.mp hx <;> linarith [ show ( i : ℝ ) ≥ 2 by norm_cast; linarith [ Finset.mem_Ico.mp hi ] ] ) ) ( ne_of_gt ( Real.log_pos ( by cases Set.mem_uIcc.mp hx <;> linarith [ show ( i : ℝ ) ≥ 2 by norm_cast; linarith [ Finset.mem_Ico.mp hi ] ] ) ) );
  · norm_num;
  · exact fun x hx₁ hx₂ => inv_anti₀ ( Real.log_pos <| by norm_cast; linarith [ Finset.mem_Ico.mp hi ] ) ( Real.log_le_log ( by norm_cast; linarith [ Finset.mem_Ico.mp hi ] ) hx₁ );
  · norm_num

/-
Upper bound: `CramerSum N` is at most `1/log 2` plus the integral of
`1 / log x` over `[2, N]`.  (Reformulation of the `[1, N]` comparison that avoids
the non-integrable singularity at `x = 1`; see the section comment.)
-/
theorem cramerSum_upper_integral {N : ℕ} (hN : 3 ≤ N) :
    CramerSum N ≤ (Real.log 2)⁻¹ + ∫ x in (2 : ℝ)..(N : ℝ), (Real.log x)⁻¹ := by
  convert add_le_add_left ( AntitoneOn.sum_le_integral_Ico ?_ ?_ ) ( ( Real.log 2 ) ⁻¹ ) using 1;
  rotate_left;
  convert add_comm _ _;
  · linarith;
  · exact fun x hx y hy hxy => inv_anti₀ ( Real.log_pos <| by norm_num at *; linarith ) ( Real.log_le_log ( by norm_num at *; linarith ) hxy );
  · unfold CramerSum;
    erw [ Finset.sum_Ico_eq_sub _ _, Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ Finset.sum_range_succ' ] ; linarith;
    linarith

/-! ## Elementary `N / log N`-scale lower bound

Each of the `N - 1` terms `1 / log n` with `2 ≤ n ≤ N` is at least `1 / log N`,
so `CramerSum N ≥ (N-1) / log N ≥ (1/2) · N / log N`, exhibiting the
prime-number-theorem order of growth by purely elementary means. -/

/-
Crude lower bound: `CramerSum N ≥ (N - 1) / log N`.
-/
lemma cramerSum_ge_card_div_log {N : ℕ} (hN : 2 ≤ N) :
    ((N : ℝ) - 1) * (Real.log (N : ℝ))⁻¹ ≤ CramerSum N := by
  convert Finset.sum_le_sum fun i hi => inv_anti₀ ( Real.log_pos <| Nat.one_lt_cast.2 <| Finset.mem_Icc.mp hi |>.1 ) ( Real.log_le_log ( Nat.cast_pos.2 <| Finset.mem_Icc.mp hi |>.1.trans_lt' <| by linarith ) ( Nat.cast_le.2 <| Finset.mem_Icc.mp hi |>.2 ) ) using 1;
  cases N <;> norm_num at *;
  exact Or.inl <| by ring;

/-
Explicit `N / log N`-scale lower bound: for `N ≥ 2`,
`(1/2) · N / log N ≤ CramerSum N`.
-/
theorem cramerSum_scale_lower {N : ℕ} (hN : 2 ≤ N) :
    (N : ℝ) / (2 * Real.log (N : ℝ)) ≤ CramerSum N := by
  refine le_trans ?_ ( cramerSum_ge_card_div_log hN );
  rw [ ← div_eq_mul_inv, div_le_div_iff₀ ] <;> nlinarith [ show ( N : ℝ ) ≥ 2 by norm_cast, Real.log_pos <| show ( N : ℝ ) > 1 by norm_cast ]

end CramerPrimeModel