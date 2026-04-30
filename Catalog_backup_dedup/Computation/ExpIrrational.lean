import Mathlib

/-! # Irrationality of exp(n) for positive integers n

This file establishes the irrationality of exp(n) for n ≥ 1 using
Niven's integral method.

## Key idea

Define `K(a,b) = ∫₀ⁿ e^(n-t) t^a (n-t)^b dt`. Integration by parts gives
the recurrence `K(a,b) = a · K(a-1,b) - b · K(a,b-1)` for `a, b ≥ 1`.

The base cases `K(a,0)` and `K(0,b)` are integer combinations of `exp(n)` and 1
(from the standard integration-by-parts formula for `∫ e^(n-t) t^k dt`).

By induction on `min(a,b)`, we show `min(a,b)!` divides both coefficients of
`K(a,b) = C · exp(n) + D`. Since `nivenI(n,s) = K(s,s)/s!`, the result
`nivenI_integer_combo` follows.
-/

noncomputable section

open MeasureTheory

set_option maxHeartbeats 800000

/-! ## Niven's auxiliary function and integral -/

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

/-! ## The K integral and its properties -/

/-- The generalized integral K(n, a, b) = ∫₀ⁿ e^(n-t) t^a (n-t)^b dt. -/
def K (n : ℕ) (a b : ℕ) : ℝ :=
  ∫ t in (0 : ℝ)..(n : ℝ), Real.exp ((n : ℝ) - t) * (t ^ a * ((n : ℝ) - t) ^ b)

/-
K(n, a, 0) is an integer combination of exp(n) and 1.
-/
lemma K_base_right (n : ℕ) (a : ℕ) :
    ∃ C D : ℤ, K n a 0 = C * Real.exp n + D := by
  induction' a with a ih generalizing n;
  · unfold K;
    norm_num [ intervalIntegral.integral_comp_sub_left ];
    exact ⟨ 1, -1, by ring ⟩;
  · -- By integration by parts, we have:
    have h_parts : K n (a + 1) 0 = -n^(a + 1) + (a + 1) * K n a 0 := by
      -- Apply integration by parts with $u = t^{a+1}$ and $dv = e^{n-t} dt$.
      have h_parts : ∀ {a : ℕ} {n : ℕ}, ∫ t in (0 : ℝ)..n, t^(a + 1) * Real.exp (n - t) = -n^(a + 1) * Real.exp (n - n) + (a + 1) * ∫ t in (0 : ℝ)..n, t^a * Real.exp (n - t) := by
        intros a n; rw [ intervalIntegral.integral_mul_deriv_eq_deriv_mul ];
        any_goals intro x hx; exact hasDerivAt_pow _ _;
        rotate_right;
        use fun x => -Real.exp ( n - x );
        · norm_num [ mul_assoc ];
        · exact fun x hx => by simpa using HasDerivAt.neg ( HasDerivAt.exp ( hasDerivAt_id x |> HasDerivAt.const_sub _ ) ) ;
        · norm_num;
        · exact Continuous.intervalIntegrable ( by continuity ) _ _;
      convert h_parts using 1 ; norm_num [ K ] ; ring!;
      unfold K; norm_num [ mul_comm ] ;
    obtain ⟨ C, D, hCD ⟩ := ih n; exact ⟨ ( a + 1 ) * C, ( a + 1 ) * D - n ^ ( a + 1 ), by push_cast [ h_parts, hCD ] ; ring ⟩ ;

/-
K(n, 0, b) is an integer combination of exp(n) and 1.
-/
lemma K_base_left (n : ℕ) (b : ℕ) :
    ∃ C D : ℤ, K n 0 b = C * Real.exp n + D := by
  revert n b;
  intro n
  induction' n with n ih
  generalize_proofs at *;
  · unfold K;
    exact fun b => ⟨ 0, 0, by norm_num ⟩;
  · intro b
    have h_subst : ∀ b : ℕ, K (n + 1) 0 b = ∫ t in (0 : ℝ)..n + 1, Real.exp t * t ^ b := by
      intro b
      simp [K];
      convert intervalIntegral.integral_comp_sub_left _ ( n + 1 : ℝ ) using 2 <;> norm_num
    generalize_proofs at *; (
    induction' b with b ih <;> simp_all +decide [ Nat.factorial_succ, mul_assoc, mul_comm, mul_left_comm, intervalIntegral.integral_comp_mul_right ];
    · exact ⟨ 1, -1, by push_cast; ring ⟩;
    · rw [ intervalIntegral.integral_mul_deriv_eq_deriv_mul ] <;> norm_num [ Real.differentiableAt_exp ];
      any_goals intro x hx; exact hasDerivAt_pow _ _;
      any_goals intro x hx; exact Real.hasDerivAt_exp x;
      · norm_num [ mul_assoc ] at * ; obtain ⟨ C, D, hCD ⟩ := ih ; exact ⟨ ( n + 1 ) ^ ( b + 1 ) - ( b + 1 ) * C, - ( b + 1 ) * D, by push_cast; linear_combination' - ( b + 1 ) * hCD ⟩ ;
      · norm_num);

/-
Integration by parts recurrence: K(n, a, b) = a · K(n, a-1, b) - b · K(n, a, b-1)
    for a, b ≥ 1.
-/
lemma K_recurrence (n : ℕ) (a b : ℕ) (ha : 1 ≤ a) (hb : 1 ≤ b) :
    K n a b = a * K n (a - 1) b - b * K n a (b - 1) := by
  -- By integration by parts, we have:
  have h_parts : ∀ t ∈ Set.Icc (0 : ℝ) n, deriv (fun t => -Real.exp (n - t) * t ^ a * (n - t) ^ b) t = Real.exp (n - t) * t ^ a * (n - t) ^ b - a * Real.exp (n - t) * t ^ (a - 1) * (n - t) ^ b + b * Real.exp (n - t) * t ^ a * (n - t) ^ (b - 1) := by
    intro t ht; norm_num [ sub_eq_add_neg, mul_assoc, mul_comm, mul_left_comm ] ; ring;
    norm_num [ Real.exp_add, Real.exp_neg, Real.differentiableAt_exp, mul_assoc, mul_comm, mul_left_comm, sub_eq_add_neg ] ; ring;
    erw [ deriv_mul ] <;> norm_num [ Real.exp_ne_zero, Real.differentiableAt_exp, neg_add_eq_sub ] ; ring;
    · erw [ deriv_comp ] <;> norm_num [ sub_eq_add_neg ] ; ring;
      · erw [ deriv_pow, deriv_sub ] <;> norm_num ; ring;
        simpa [ sq, mul_assoc, Real.exp_ne_zero ] using by ring;
      · exact DifferentiableAt.pow ( differentiableAt_id ) _;
      · exact differentiableAt_id.const_sub _;
    · exact DifferentiableAt.pow ( differentiableAt_id.const_sub _ ) _;
  -- Integrate both sides of the equation from $0$ to $n$.
  have h_int_parts : ∫ t in (0 : ℝ)..n, deriv (fun t => -Real.exp (n - t) * t ^ a * (n - t) ^ b) t = (-Real.exp (n - n) * n ^ a * (n - n) ^ b) - (-Real.exp (n - 0) * 0 ^ a * (n - 0) ^ b) := by
    rw [ intervalIntegral.integral_deriv_eq_sub ];
    · fun_prop;
    · apply_rules [ ContinuousOn.intervalIntegrable ];
      fun_prop;
  rw [ intervalIntegral.integral_congr fun x hx => h_parts x <| by simpa using hx ] at h_int_parts;
  rw [ intervalIntegral.integral_add, intervalIntegral.integral_sub ] at h_int_parts <;> norm_num at *;
  · simp_all +decide [ mul_assoc, K ];
    cases a <;> cases b <;> norm_num at * ; linarith;
  · exact Continuous.intervalIntegrable ( by continuity ) _ _;
  · exact Continuous.intervalIntegrable ( by continuity ) _ _;
  · exact Continuous.intervalIntegrable ( by continuity ) _ _;
  · exact Continuous.intervalIntegrable ( by continuity ) _ _

/-
K(n, a, b) = C * exp(n) + D with min(a,b)! ∣ C and min(a,b)! ∣ D.
-/
lemma K_int_combo_with_divisibility (n : ℕ) (a b : ℕ) :
    ∃ C D : ℤ, K n a b = C * Real.exp n + D ∧
      ((min a b).factorial : ℤ) ∣ C ∧ ((min a b).factorial : ℤ) ∣ D := by
  revert a b;
  intro a b; induction' a using Nat.strong_induction_on with a ih generalizing b; induction' b using Nat.strong_induction_on with b ih';
  rcases a with ( _ | a ) <;> rcases b with ( _ | b ) <;> simp_all +decide [ Nat.factorial_succ ];
  · exact K_base_right n 0;
  · exact K_base_left n _;
  · exact K_base_right _ _;
  · obtain ⟨ C₁, D₁, h₁, h₂, h₃ ⟩ := ih a le_rfl ( b + 1 ) ; obtain ⟨ C₂, D₂, h₄, h₅, h₆ ⟩ := ih' b le_rfl ; simp_all +decide [ K_recurrence ];
    cases le_total a b <;> simp_all +decide [ Nat.factorial_succ, mul_assoc, mul_left_comm, mul_comm ];
    · cases min_cases a ( b + 1 ) <;> cases min_cases ( a + 1 ) b <;> simp_all +decide [ Nat.factorial_succ ];
      · refine' ⟨ ( a + 1 ) * C₁ - ( b + 1 ) * C₂, ( a + 1 ) * D₁ - ( b + 1 ) * D₂, _, _, _ ⟩ <;> norm_num [ mul_comm, mul_assoc, mul_left_comm ];
        · ring;
        · exact dvd_sub ( mul_dvd_mul h₂ dvd_rfl ) ( dvd_mul_of_dvd_left ( by simpa only [ mul_comm ] using h₅ ) _ );
        · exact dvd_sub ( mul_dvd_mul h₃ dvd_rfl ) ( dvd_mul_of_dvd_left ( by simpa only [ mul_comm ] using h₆ ) _ );
      · cases ‹b ≤ a + 1 ∧ b ≤ a›.2.eq_or_lt <;> first | linarith | simp_all +decide [ Nat.factorial_succ ];
        exact ⟨ ( a + 1 ) * C₁ - ( a + 1 ) * C₂, ( a + 1 ) * D₁ - ( a + 1 ) * D₂, by push_cast; ring, by obtain ⟨ k, hk ⟩ := h₂; obtain ⟨ l, hl ⟩ := h₅; exact ⟨ k - l, by nlinarith ⟩, by obtain ⟨ k, hk ⟩ := h₃; obtain ⟨ l, hl ⟩ := h₆; exact ⟨ k - l, by nlinarith ⟩ ⟩;
      · linarith;
      · linarith;
    · refine' ⟨ ( a + 1 ) * C₁ - ( b + 1 ) * C₂, ( a + 1 ) * D₁ - ( b + 1 ) * D₂, _, _, _ ⟩ <;> norm_num [ ← mul_assoc, ← Int.natCast_dvd_natCast ] at *;
      · ring;
      · cases le_iff_exists_add'.mp ‹_› ; simp_all +decide [ Nat.factorial_succ, mul_comm, mul_assoc, mul_left_comm, dvd_add_right, dvd_add_left, dvd_mul_of_dvd_right, dvd_mul_of_dvd_left ];
        cases min_cases ( ‹_› + b ) ( b + 1 ) <;> simp_all +decide [ Nat.factorial_succ, mul_comm, mul_assoc, mul_left_comm, dvd_add_right, dvd_add_left, dvd_mul_of_dvd_right, dvd_mul_of_dvd_left ];
        · cases ‹ℕ› <;> simp_all +decide [ Nat.factorial_succ, mul_comm, mul_assoc, mul_left_comm, dvd_add_right, dvd_add_left, dvd_mul_of_dvd_right, dvd_mul_of_dvd_left ];
          · exact dvd_sub ( mul_dvd_mul h₂ dvd_rfl ) ( mul_dvd_mul h₅ dvd_rfl );
          · simp_all +decide [ add_comm, add_left_comm, add_assoc ];
            exact dvd_sub ( by obtain ⟨ k, hk ⟩ := h₂; exact ⟨ k * ( b + 2 ), by push_cast [ Nat.factorial_succ ] at *; nlinarith ⟩ ) ( by obtain ⟨ k, hk ⟩ := h₅; exact ⟨ k, by push_cast [ Nat.factorial_succ ] at *; nlinarith ⟩ );
        · refine' dvd_sub ( dvd_mul_of_dvd_left h₂ _ ) _;
          exact mul_dvd_mul ( by simpa [ min_eq_right ( by linarith : b ≤ ‹_› + b + 1 ) ] using h₅ ) dvd_rfl;
      · cases le_iff_exists_add'.mp ‹_› ; simp_all +decide [ Nat.factorial_succ, mul_comm, mul_assoc, mul_left_comm, dvd_add_right, dvd_add_left, dvd_mul_of_dvd_right, dvd_mul_of_dvd_left ];
        cases min_cases ( ‹_› + b ) ( b + 1 ) <;> simp_all +decide [ Nat.factorial_succ, mul_comm, mul_assoc, mul_left_comm, dvd_add_right, dvd_add_left, dvd_mul_of_dvd_right, dvd_mul_of_dvd_left ];
        · cases ‹ℕ› <;> simp_all +decide [ Nat.factorial_succ, mul_comm, mul_assoc, mul_left_comm, dvd_add_right, dvd_add_left, dvd_mul_of_dvd_right, dvd_mul_of_dvd_left ];
          · exact dvd_sub ( mul_dvd_mul h₃ dvd_rfl ) ( mul_dvd_mul h₆ dvd_rfl );
          · simp_all +decide [ add_comm, add_left_comm, add_assoc ];
            obtain ⟨ k, hk ⟩ := h₃; obtain ⟨ l, hl ⟩ := h₆; simp_all +decide [ Nat.factorial_succ, mul_assoc, mul_comm, mul_left_comm ] ;
            exact ⟨ k * ( b + 2 ) - l, by ring ⟩;
        · refine' dvd_sub ( dvd_mul_of_dvd_left h₃ _ ) _;
          exact mul_dvd_mul ( dvd_trans ( by norm_num [ min_eq_right ( by linarith : b ≤ ‹_› + b + 1 ) ] ) h₆ ) dvd_rfl

/-
nivenI is an integer linear combination of exp(n) and 1.
-/
lemma nivenI_integer_combo (n s : ℕ) :
    ∃ A B : ℤ, nivenI n s = A * Real.exp n + B := by
  -- By definition of nivenI, we have nivenI n s = K n s s / s.factorial.
  have hnivenI_def : nivenI n s = K n s s / Nat.factorial s := by
    unfold nivenI K nivenF; norm_num [ div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm, ← intervalIntegral.integral_const_mul ] ;
  obtain ⟨ C, D, hCD, hC, hD ⟩ := K_int_combo_with_divisibility n s s;
  cases' hC with A hA; cases' hD with B hB; use A, B; simp_all +decide [ min_eq_left ] ;
  rw [ div_eq_iff ( by positivity ) ] ; ring

/-! ## Main theorem -/

/-
exp(n) is irrational for n ≥ 1.
-/
theorem exp_nat_irrational (n : ℕ) (hn : 1 ≤ n) : Irrational (Real.exp (↑n)) := by
  by_contra h_contra;
  -- Let $q$ be the denominator of $\exp n$.
  obtain ⟨q, hq⟩ : ∃ q : ℕ, q > 0 ∧ ∃ p : ℤ, Real.exp n = p / q := by
    obtain ⟨ p, hp ⟩ := Classical.not_not.1 h_contra;
    exact ⟨ p.den, Nat.cast_pos.mpr p.pos, p.num, by simpa only [ Rat.cast_def ] using hp.symm ⟩;
  -- Then $q \cdot I(s)$ is an integer for all $s$.
  have hqI_int : ∀ s : ℕ, ∃ k : ℤ, q * nivenI n s = k := by
    intro s
    obtain ⟨A, B, hA⟩ := nivenI_integer_combo n s
    use A * hq.right.choose + B * q
    field_simp [hq.right.choose_spec] at hA ⊢;
    have := hq.2.choose_spec; rw [ eq_div_iff ( Nat.cast_ne_zero.mpr hq.1.ne' ) ] at this; push_cast; rw [ hA ] ; linear_combination' this * A;
  -- But $q \cdot I(s) \geq 1$ for all $s$.
  have hqI_ge_one : ∀ s : ℕ, 1 ≤ q * nivenI n s := by
    intro s; obtain ⟨ k, hk ⟩ := hqI_int s; exact hk.symm ▸ mod_cast ( show ( 1 : ℤ ) ≤ k from by exact_mod_cast hk ▸ mul_pos ( Nat.cast_pos.mpr hq.1 ) ( nivenI_pos n s hn ) ) ;
  -- But $q \cdot I(s) \to 0$ as $s \to \infty$.
  have hqI_zero : Filter.Tendsto (fun s : ℕ => q * nivenI n s) Filter.atTop (nhds 0) := by
    exact squeeze_zero ( fun s => mul_nonneg ( Nat.cast_nonneg _ ) ( le_of_lt ( nivenI_pos n s hn ) ) ) ( fun s => mul_le_mul_of_nonneg_left ( nivenI_le n s ) ( Nat.cast_nonneg _ ) ) ( by simpa using tendsto_const_nhds.mul ( niven_bound_tendsto n ) );
  exact absurd ( le_of_tendsto_of_tendsto' tendsto_const_nhds hqI_zero hqI_ge_one ) ( by norm_num )

end