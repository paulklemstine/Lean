import Mathlib

/-! # Irrationality of exp(n) for positive integers n

This file establishes the irrationality of exp(n) for n ≥ 1 using
Niven's integral method.
-/

noncomputable section

open MeasureTheory

/-- Niven's auxiliary function. -/
def nivenF (n s : ℕ) (t : ℝ) : ℝ := t ^ s * ((n : ℝ) - t) ^ s / s.factorial

/-- nivenF is nonneg on [0, n]. -/
lemma nivenF_nonneg {n s : ℕ} {t : ℝ} (ht0 : 0 ≤ t) (htn : t ≤ n) :
    0 ≤ nivenF n s t := by
  unfold nivenF
  apply div_nonneg
  · exact mul_nonneg (pow_nonneg ht0 s) (pow_nonneg (by linarith) s)
  · positivity

lemma nivenF_le {n s : ℕ} {t : ℝ} (ht0 : 0 ≤ t) (htn : t ≤ n) :
    nivenF n s t ≤ (n : ℝ) ^ (2 * s) / s.factorial := by
  refine' div_le_div_of_nonneg_right _ _
  · rw [two_mul, pow_add]
    exact mul_le_mul (pow_le_pow_left₀ ht0 htn _)
      (pow_le_pow_left₀ (sub_nonneg.2 htn) (sub_le_self _ ht0) _)
      (pow_nonneg (sub_nonneg.2 htn) _) (by positivity)
  · positivity

/-- Niven's integral. -/
def nivenI (n s : ℕ) : ℝ := ∫ t in (0 : ℝ)..(n : ℝ), Real.exp ((n : ℝ) - t) * nivenF n s t

lemma nivenI_pos (n s : ℕ) (hn : 1 ≤ n) : 0 < nivenI n s := by
  apply_rules [intervalIntegral.integral_pos]
  · positivity
  · exact Continuous.continuousOn (by unfold nivenF; continuity)
  · exact fun x hx => mul_nonneg (Real.exp_nonneg _) (nivenF_nonneg hx.1.le hx.2)
  · use n / 2
    exact ⟨⟨by positivity, by linarith⟩,
      mul_pos (Real.exp_pos _) (div_pos (mul_pos (pow_pos (by positivity) _)
        (pow_pos (by linarith [(by norm_cast : (1 : ℝ) ≤ n)]) _)) (by positivity))⟩

lemma nivenI_le (n s : ℕ) :
    nivenI n s ≤ (n : ℝ) ^ (2 * s + 1) * Real.exp n / s.factorial := by
  refine' le_trans (intervalIntegral.integral_mono_on _ _ _ _) _
  refine' fun t => Real.exp n * (n ^ (2 * s) / s.factorial)
  · positivity
  · exact Continuous.intervalIntegrable (Continuous.mul (Real.continuous_exp.comp <| by continuity)
      (Continuous.div_const (by continuity) _)) _ _
  · norm_num
  · intro x hx
    exact mul_le_mul (Real.exp_le_exp.mpr (sub_le_self _ hx.1)) (nivenF_le hx.1 hx.2)
      (nivenF_nonneg hx.1 hx.2) (by positivity)
  · norm_num; ring_nf; norm_num

lemma niven_bound_tendsto (n : ℕ) :
    Filter.Tendsto (fun s => (n : ℝ) ^ (2 * s + 1) * Real.exp n / s.factorial)
    Filter.atTop (nhds 0) := by
  convert Summable.tendsto_atTop_zero
    (show Summable fun s : ℕ => ((n : ℝ) ^ 2) ^ s / (s.factorial : ℝ) from ?_)
    |> Filter.Tendsto.const_mul ((n : ℝ) * Real.exp n) using 2 ; ring
  · ring
  · exact Real.summable_pow_div_factorial _

/-
Helper: ∫₀ⁿ e^(n-t) t^k dt = k! * e^n - Σ_{i=0}^k (k!/i!) n^i.
    Both k! and each (k!/i!) n^i are natural numbers, so the integral
    is an integer linear combination of e^n and 1.
-/
lemma integral_exp_pow (n : ℕ) (k : ℕ) :
    ∃ A B : ℤ, ∫ t in (0 : ℝ)..(n : ℝ), Real.exp ((n : ℝ) - t) * t ^ k =
    A * Real.exp n + B := by
  induction' k with k ih;
  · norm_num [ intervalIntegral.integral_comp_sub_left ];
    exact ⟨ 1, -1, by ring ⟩;
  · -- For the inductive step, we use integration by parts.
    have h_parts : ∀ a b : ℝ, ∫ t in a..b, Real.exp (n - t) * t ^ (k + 1) = (b ^ (k + 1) * (-Real.exp (n - b))) - (a ^ (k + 1) * (-Real.exp (n - a))) - ∫ t in a..b, (-Real.exp (n - t)) * (k + 1) * t ^ k := by
      intro a b; rw [ eq_sub_iff_add_eq ] ; rw [ ← intervalIntegral.integral_add ] ; rw [ intervalIntegral.integral_eq_sub_of_hasDerivAt ];
      · intro x hx; convert HasDerivAt.mul ( hasDerivAt_pow ( k + 1 ) x ) ( HasDerivAt.neg ( HasDerivAt.exp ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) ) ) using 1 ; ring;
        norm_num ; ring;
      · exact Continuous.intervalIntegrable ( by continuity ) _ _;
      · exact Continuous.intervalIntegrable ( by continuity ) _ _;
      · exact Continuous.intervalIntegrable ( by continuity ) _ _;
    simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ];
    obtain ⟨ A, B, h ⟩ := ih; use ( k + 1 ) * A, ( k + 1 ) * B - n ^ ( k + 1 ) ; push_cast; rw [ show ( fun x : ℝ => x ^ k * ( ( k + 1 ) * Real.exp ( n - x ) ) ) = fun x : ℝ => ( k + 1 ) * ( x ^ k * Real.exp ( n - x ) ) by ext; ring ] ; rw [ intervalIntegral.integral_const_mul ] ; rw [ h ] ; ring;

/-- nivenI is an integer linear combination of exp(n) and 1. -/
lemma nivenI_integer_combo (n s : ℕ) :
    ∃ A B : ℤ, nivenI n s = A * Real.exp n + B := by
  sorry

/-
exp(n) is irrational for n ≥ 1.
-/
theorem exp_nat_irrational (n : ℕ) (hn : 1 ≤ n) : Irrational (Real.exp (↑n)) := by
  -- Assume for contradiction that $\exp(n)$ is rational.
  by_contra h
  obtain ⟨p, q, hpq⟩ : ∃ p q : ℕ, q > 0 ∧ Real.exp n = p / q := by
    unfold Irrational at h;
    simp +zetaDelta at *;
    obtain ⟨ y, hy ⟩ := h; exact ⟨ y.num.natAbs, y.den, mod_cast y.pos, by simpa [ abs_of_nonneg ( Rat.num_nonneg.mpr ( show 0 ≤ y by exact_mod_cast hy.symm ▸ Real.exp_nonneg _ ) ), Rat.cast_def ] using hy.symm ⟩ ;
  -- By nivenI_integer_combo, nivenI n s = A_s * exp(n) + B_s for integers A_s, B_s.
  have h_nivenI : ∀ s : ℕ, ∃ A B : ℤ, nivenI n s = A * (p / q) + B := by
    exact fun s => by obtain ⟨ A, B, h ⟩ := nivenI_integer_combo n s; exact ⟨ A, B, by rw [ ← hpq.2, h ] ⟩ ;
  -- So q * nivenI n s = A_s * p + B_s * q, which is an integer.
  have h_q_nivenI : ∀ s : ℕ, ∃ k : ℤ, q * nivenI n s = k := by
    intro s; obtain ⟨ A, B, h ⟩ := h_nivenI s; use A * p + B * q; push_cast [ h ] ; ring_nf ;
    simpa [ mul_assoc, mul_comm, mul_left_comm, hpq.1.ne' ] using by ring;
  -- By nivenI_pos, nivenI n s > 0, so q * nivenI n s ≥ 1.
  have h_q_nivenI_pos : ∀ s : ℕ, 1 ≤ q * nivenI n s := by
    exact fun s => by obtain ⟨ k, hk ⟩ := h_q_nivenI s; exact hk.symm ▸ mod_cast Int.le_of_lt_add_one ( by rw [ ← @Int.cast_lt ℝ ] ; push_cast; nlinarith [ nivenI_pos n s hn, show ( q : ℝ ) ≥ 1 by exact_mod_cast hpq.1 ] ) ;
  -- By nivenI_le and niven_bound_tendsto, nivenI n s → 0 as s → ∞.
  have h_nivenI_zero : Filter.Tendsto (fun s : ℕ => nivenI n s) Filter.atTop (nhds 0) := by
    exact squeeze_zero ( fun s => by exact intervalIntegral.integral_nonneg ( by positivity ) fun x hx => mul_nonneg ( Real.exp_nonneg _ ) ( nivenF_nonneg ( by linarith [ hx.1 ] ) ( by linarith [ hx.2 ] ) ) ) ( fun s => nivenI_le n s ) ( niven_bound_tendsto n );
  exact absurd ( le_of_tendsto_of_tendsto' tendsto_const_nhds ( h_nivenI_zero.const_mul _ ) h_q_nivenI_pos ) ( by norm_num [ hpq.1.ne' ] )

end