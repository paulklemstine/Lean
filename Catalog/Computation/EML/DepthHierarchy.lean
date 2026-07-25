import Mathlib

/-! # CatalogBuild.Computation.DepthHierarchy

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21
-/


noncomputable section

/-- The EML operation. -/
def EML_h (a b : ℝ) : ℝ := Real.exp a - Real.log b




/-- Iterated exponential: exp^{(n)}(x). -/
def iterExp_h : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp_h n x)




/-- The e-tower: e↑↑n = exp^{(n)}(1). -/
def eTower_h (n : ℕ) : ℝ := iterExp_h n 1




/-- [Section: # CatalogBuild.Computation.DepthHierarchy
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21] -/
theorem iterExp_h_succ (n : ℕ) (x : ℝ) :
    iterExp_h (n + 1) x = Real.exp (iterExp_h n x) := rfl




/-- [Section: # CatalogBuild.Computation.DepthHierarchy
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21] -/
theorem iterExp_h_pos (n : ℕ) (x : ℝ) (hn : 0 < n) : 0 < iterExp_h n x := by
  cases n with
  | zero => omega
  | succ n => exact Real.exp_pos _




/-- exp^{(n)}(x) ≥ x + n for x ≥ 0. -/
theorem iterExp_h_ge_add (n : ℕ) (x : ℝ) (hx : 0 ≤ x) :
    iterExp_h n x ≥ x + n := by
  induction n with
  | zero => simp [iterExp_h]
  | succ n ih =>
    simp only [iterExp_h_succ]; push_cast
    linarith [Real.add_one_le_exp (iterExp_h n x)]




theorem iterExp_h_strictMono_x (n : ℕ) : StrictMono (iterExp_h n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => intro a b hab; exact Real.exp_lt_exp.mpr (ih hab)




theorem iterExp_h_strictMono_n (x : ℝ) (hx : 0 ≤ x) :
    StrictMono (fun n => iterExp_h n x) := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [iterExp_h_succ]
  linarith [Real.add_one_le_exp (iterExp_h n x)]




theorem eTower_h_pos (n : ℕ) : 0 < eTower_h n := by
  induction n with
  | zero => norm_num [eTower_h, iterExp_h]
  | succ _ _ => exact Real.exp_pos _




theorem eTower_h_strictMono : StrictMono eTower_h :=
  iterExp_h_strictMono_n 1 (by norm_num)




/-- e↑↑n → ∞. -/
theorem eTower_h_tendsto : Filter.Tendsto eTower_h Filter.atTop Filter.atTop := by
  apply Filter.tendsto_atTop_atTop.mpr
  intro b
  use ⌈b⌉₊
  intro n hn
  have h := iterExp_h_ge_add n 1 (by norm_num)
  simp only [eTower_h]
  have : (⌈b⌉₊ : ℝ) ≥ b := Nat.le_ceil b
  linarith [show (n : ℝ) ≥ ⌈b⌉₊ from by exact_mod_cast hn]




/-- exp(exp(x)) > C * exp(x) + D for sufficiently large x. -/
theorem exp_exp_dominates_linear_exp (C D : ℝ) :
    ∀ᶠ x in Filter.atTop, Real.exp (Real.exp x) > C * Real.exp x + D := by
  have h : ∀ᶠ t in Filter.atTop, Real.exp t > C * t + D := by
    rw [Filter.eventually_atTop]
    use max 0 (2 * (|C| + |D| + 1))
    intro t ht
    have ht0 : t ≥ 0 := le_trans (le_max_left 0 _) ht
    have htlarge : t ≥ 2 * (|C| + |D| + 1) := le_trans (le_max_right 0 _) ht
    have hexp : Real.exp t ≥ 1 + t + t ^ 2 / 2 := quadratic_le_exp_of_nonneg ht0
    have hC : C * t ≤ |C| * t := by nlinarith [abs_nonneg C, le_abs_self C]
    have hD : D ≤ |D| := le_abs_self D
    nlinarith [abs_nonneg C, abs_nonneg D, sq_nonneg t,
               mul_le_mul_of_nonneg_right (show |C| + |D| + 1 ≤ t / 2 by linarith) ht0]
  exact (Real.tendsto_exp_atTop).eventually h




/-- iterExp_h n tends to ∞ as x → ∞. -/
theorem iterExp_h_tendsto_atTop (n : ℕ) :
    Filter.Tendsto (iterExp_h n) Filter.atTop Filter.atTop := by
  induction n with
  | zero => exact tendsto_id
  | succ n ih => exact Real.tendsto_exp_atTop.comp ih




/-- Growth rate separation for depth n vs n+1. -/
theorem depth_separation (n : ℕ) (C D : ℝ) :
    ∀ᶠ x in Filter.atTop,
      iterExp_h (n + 2) x > C * iterExp_h (n + 1) x + D := by
  have h : ∀ᶠ t in Filter.atTop, Real.exp t > C * t + D := by
    rw [Filter.eventually_atTop]
    use max 0 (2 * (|C| + |D| + 1))
    intro t ht
    have ht0 : t ≥ 0 := le_trans (le_max_left 0 _) ht
    have htlarge : t ≥ 2 * (|C| + |D| + 1) := le_trans (le_max_right 0 _) ht
    have hexp : Real.exp t ≥ 1 + t + t ^ 2 / 2 := quadratic_le_exp_of_nonneg ht0
    have hC : C * t ≤ |C| * t := by nlinarith [abs_nonneg C, le_abs_self C]
    have hD : D ≤ |D| := le_abs_self D
    nlinarith [abs_nonneg C, abs_nonneg D, sq_nonneg t,
               mul_le_mul_of_nonneg_right (show |C| + |D| + 1 ≤ t / 2 by linarith) ht0]
  exact (iterExp_h_tendsto_atTop (n + 1)).eventually h




def EMLTree.eval : EMLTree → ℝ
  | .leaf => 1
  | .node l r => EML_h l.eval r.eval




theorem EMLTree_depth_zero_eval (t : EMLTree) (ht : t.depth = 0) :
    t.eval = 1 := by
  cases t with
  | leaf => rfl
  | node l r => simp [EMLTree.depth] at ht




theorem EMLTree_depth_one_eval (t : EMLTree) (ht : t.depth = 1) :
    t.eval = Real.exp 1 := by
  cases t with
  | leaf => simp [EMLTree.depth] at ht
  | node l r =>
    simp [EMLTree.depth] at ht
    have hl := EMLTree_depth_zero_eval l (by omega)
    have hr := EMLTree_depth_zero_eval r (by omega)
    simp [EMLTree.eval, hl, hr, EML_h, Real.log_one]




/-- The chain tree C(n) = node(C(n-1), leaf). -/
def chainTree : ℕ → EMLTree
  | 0 => .leaf
  | n + 1 => .node (chainTree n) .leaf




theorem chainTree_depth (n : ℕ) : (chainTree n).depth = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [chainTree, EMLTree.depth, ih]; omega




theorem chainTree_eval (n : ℕ) : (chainTree n).eval = eTower_h n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp [chainTree, EMLTree.eval, ih, EML_h, Real.log_one, eTower_h, iterExp_h]




/-- BB_EML(d) ≥ e↑↑d. -/
theorem BB_EML_lower_bound (d : ℕ) :
    ∃ t : EMLTree, t.depth ≤ d ∧ t.eval = eTower_h d := by
  exact ⟨chainTree d, le_of_eq (chainTree_depth d), chainTree_eval d⟩




end