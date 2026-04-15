/-! # CatalogBuild.New.OISCC_V9.DepthHierarchy

Auto-generated from theorem catalog database.
Domain: New/OISCC_V9
Declarations: 15
-/

import Mathlib

noncomputable section

/-- iterExp 0 is the identity. -/
theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl


/-- iterExp 1 is exp. -/
theorem iterExp_one (x : ℝ) : iterExp 1 x = Real.exp x := rfl


/-- iterExp is always positive for n ≥ 1. -/
theorem iterExp_pos (n : ℕ) (x : ℝ) (hn : 0 < n) : 0 < iterExp n x := by
  cases n with
  | zero => omega
  | succ n => exact Real.exp_pos _


/-- iterExp (n+1) = exp ∘ iterExp n. -/
theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl


/-- exp^{(n)}(x) ≥ x + n for x ≥ 0. -/
theorem iterExp_ge_add (n : ℕ) (x : ℝ) (hx : 0 ≤ x) :
    iterExp n x ≥ x + n := by
  induction n with
  | zero => simp [iterExp]
  | succ n ih =>
    simp only [iterExp_succ]
    push_cast
    linarith [Real.add_one_le_exp (iterExp n x)]


/-- iterExp is strictly increasing in n for x ≥ 0. -/
theorem iterExp_strictMono_n (x : ℝ) (hx : 0 ≤ x) :
    StrictMono (fun n => iterExp n x) := by
  apply strictMono_nat_of_lt_succ
  intro n
  simp only [iterExp_succ]
  linarith [Real.add_one_le_exp (iterExp n x)]


/-- eTower n ≥ n + 1. -/
theorem eTower_ge (n : ℕ) : eTower n ≥ ↑n + 1 := by
  have := iterExp_ge_add n 1 (by norm_num : (0 : ℝ) ≤ 1)
  simp [eTower] at this ⊢
  linarith


/-- eTower is unbounded. -/
theorem eTower_unbounded : ∀ M : ℝ, ∃ n : ℕ, eTower n > M := by
  intro M
  exact ⟨⌊M⌋₊, by linarith [Nat.lt_floor_add_one M, eTower_ge ⌊M⌋₊]⟩


/-- [Section: ## Section 3: Growth Separation] -/
theorem growth_sep_depth1_depth2 (C D : ℝ) :
    ∀ᶠ x in atTop, Real.exp (Real.exp x) > Real.exp (C * x + D) := by
  norm_num +zetaDelta at *;
  have h_exp_growth : Filter.Tendsto (fun x => Real.exp x / x) Filter.atTop Filter.atTop := by
    simpa using Real.tendsto_exp_div_pow_atTop 1;
  have := h_exp_growth.eventually_gt_atTop ( |C| + |D| + 1 );
  exact Filter.eventually_atTop.mp ( this.and ( Filter.eventually_ge_atTop 1 ) ) |> fun ⟨ a, ha ⟩ ↦ ⟨ a, fun x hx ↦ by cases abs_cases C <;> cases abs_cases D <;> nlinarith [ ha x hx, mul_div_cancel₀ ( Real.exp x ) ( show x ≠ 0 by linarith [ ha x hx ] ) ] ⟩


theorem growth_sep_depth (n : ℕ) (C D : ℝ) :
    ∀ᶠ x in atTop, iterExp (n + 2) x > iterExp (n + 1) (C * x + D) := by
  induction' n with n ih generalizing C D;
  · convert growth_sep_depth1_depth2 C D using 1;
  · simp_all +decide [ iterExp_succ ]


/-- EML(x, 1) = exp(x), which is the maximum-growth operation. -/
theorem EML_max_growth (x : ℝ) : EML x 1 = Real.exp x := by
  simp [EML, Real.log_one]


/-- For depth-1 trees from {1}: the only value is e = EML(1,1). -/
theorem depth1_value : EML 1 1 = Real.exp 1 := by
  simp [EML, Real.log_one]


/-- DEPTH(1) ⊋ DEPTH(0): exp(1) ≠ 1. -/
theorem depth1_strictly_larger_than_depth0 :
    Real.exp 1 ≠ 1 := by
  intro h; linarith [Real.exp_one_gt_d9]


/-- DEPTH(2) ⊋ DEPTH(1): exp(exp(1)) > exp(1). -/
theorem depth2_contains_new_value :
    Real.exp (Real.exp 1) > Real.exp 1 := by
  apply Real.exp_lt_exp.mpr
  linarith [Real.exp_one_gt_d9]


/-- [Section: ## Section 5: Depth Hierarchy Separation — Low Depths] -/
theorem triple_exp_exceeds_double :
    Real.exp (Real.exp (Real.exp 1)) > Real.exp (Real.exp 1) + Real.exp 1 := by
  have := Real.add_one_le_exp ( Real.exp ( Real.exp 1 ) - 1 );
  rw [ Real.exp_sub ] at this ; nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( Real.exp 1 ), mul_div_cancel₀ ( Real.exp ( Real.exp ( Real.exp 1 ) ) ) ( ne_of_gt ( Real.exp_pos 1 ) ) ] ;


end
