import Logic.HilbertSpace.AdvancedTheorems
import MachineLearning.ShefferFunction.Lean.ExtendedTheorems
import Bridges.FutureTheorems
import Computation.Factoring.NewTheorems
import MachineLearning.ShefferFunction.Lean.ShefferAlgebra
-- import EML.Lean.SoftplusBasic
import Mathlib

/-! # CatalogBuild.EML.OpenQuestions

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 20
-/

noncomputable section

/-- Softplus is C∞ (infinitely differentiable).
This follows because log is C∞ on (0,∞) and 1 + eˣ > 0 for all x. -/
theorem softplus_contDiff : ContDiff ℝ ⊤ softplus := by
  unfold softplus
  exact ContDiff.log (contDiff_const.add Real.contDiff_exp)
    (fun x => ne_of_gt (one_plus_exp_pos x))

/-- Every Sheffer expression defines a C∞ function.
This is the **Higher Smoothness Barrier** (Q23): not only is every
Sheffer expression differentiable, but ALL derivatives exist.
Functions that are Cⁿ but not Cⁿ⁺¹ are excluded. -/
theorem sheffer_expr_contDiff (e : ShefferExpr) : ContDiff ℝ ⊤ e.eval := by
  induction e with
  | base => exact softplus_contDiff
  | affine_pre a b e ih =>
    show ContDiff ℝ ⊤ (fun x => e.eval (a * x + b))
    exact ih.comp ((contDiff_const.mul contDiff_id).add contDiff_const)
  | affine_comb α β γ e₁ e₂ ih₁ ih₂ =>
    show ContDiff ℝ ⊤ (fun x => α * e₁.eval x + β * e₂.eval x + γ)
    exact ((contDiff_const.mul ih₁).add (contDiff_const.mul ih₂)).add contDiff_const
  | comp e₁ e₂ ih₁ ih₂ =>
    exact ih₁.comp ih₂

/-- Corollary: every function in the Sheffer algebra is C∞. -/
theorem sheffer_algebra_contDiff {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) :
    ContDiff ℝ ⊤ f := by
  obtain ⟨e, he⟩ := hf
  rw [he]
  exact sheffer_expr_contDiff e

/-- The Sheffer algebra is contained in C∞ ∩ Lip.
This is the **Two-Barrier Characterization** from the paper,
now strengthened from C¹ to C∞. -/
theorem sheffer_algebra_subset_smooth_lip {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) :
    ContDiff ℝ ⊤ f ∧ (∃ C : ℝ, C ≥ 0 ∧ ∀ x y : ℝ, |f x - f y| ≤ C * |x - y|) := by
  obtain ⟨e, he⟩ := hf
  exact ⟨he ▸ sheffer_expr_contDiff e, he ▸ sheffer_expr_lipschitz e⟩

/-- σ(n·x) ≤ n·σ(x) for all natural numbers n ≥ 1.
Proof by induction using σ(x+y) ≤ σ(x) + σ(y). -/
theorem softplus_nat_mul_ineq (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    softplus (n * x) ≤ n * softplus x := by
  induction n with
  | zero => omega
  | succ k ih =>
    by_cases hk : k = 0
    · simp [hk]
    · have hk1 : k ≥ 1 := Nat.one_le_iff_ne_zero.mpr hk
      have h_sub := softplus_subadditive (k * x) x
      have h1 : (k : ℝ) * x + x = ((k : ℝ) + 1) * x := by ring
      rw [h1] at h_sub
      have h_ih := ih hk1
      push_cast at *
      linarith

/-- Iterated softplus at 0 is bounded above by (n+1) · log 2.
Since σ(0) = log 2 and σ is subadditive with σ(x) ≤ x + log 2 for x ≥ 0. -/
theorem softplus_iter_zero_upper (n : ℕ) :
    softplus_iter n 0 ≤ (n + 1) * Real.log 2 := by
  induction n with
  | zero => simp [softplus_iter, Real.log_nonneg one_le_two]
  | succ k ih =>
    simp only [softplus_iter, Function.comp]
    have h_ub := softplus_upper_bound (softplus_iter k 0)
    have h_pos : softplus_iter k 0 ≥ 0 := by
      cases k with
      | zero => simp [softplus_iter]
      | succ m => exact le_of_lt (softplus_iter_pos m 0)
    rw [max_eq_left h_pos] at h_ub
    push_cast at *
    linarith

/-- Iterated softplus at 0 is bounded below: σⁿ(0) ≥ log 2 for n ≥ 1 -/
theorem softplus_iter_zero_lower (n : ℕ) (hn : n ≥ 1) :
    softplus_iter n 0 ≥ Real.log 2 := by
  cases n with
  | zero => omega
  | succ k =>
    have : softplus_iter (k + 1) 0 ≥ softplus 0 := by
      induction k with
      | zero => simp [softplus_iter]
      | succ m ih =>
        simp only [softplus_iter, Function.comp]
        have ihm := ih (by omega)
        exact le_of_lt (softplus_strictMono (lt_of_lt_of_le (softplus_gt_id 0) ihm))
    rw [softplus_zero] at this
    exact this

/-- Softplus has no fixed point: σ(x) ≠ x for all x.
This follows because σ(x) > x for all x. -/
theorem softplus_no_fixed_point : ∀ x : ℝ, softplus x ≠ x :=
  fun x => ne_of_gt (softplus_gt_id x)

/-- [Section: # CatalogBuild.EML.OpenQuestions
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 20] -/
theorem ring_completion_not_lipschitz :
    ∃ f g : ℝ → ℝ, f ∈ ShefferAlgebra ∧ g ∈ ShefferAlgebra ∧
      ¬∃ C : ℝ, C ≥ 0 ∧ ∀ x y : ℝ, |(f x * g x) - (f y * g y)| ≤ C * |x - y| := by
  refine' ⟨ fun x => x, fun x => x, _, _, _ ⟩ <;> norm_num;
  · exact?;
  · exact?;
  · exact fun x hx => ⟨ x + 1, 0, by rw [ abs_of_nonneg, abs_of_nonneg ] <;> nlinarith ⟩

/-- The derivative of softplus is bounded by 1. -/
theorem softplus_deriv_le_one (x : ℝ) : |deriv softplus x| ≤ 1 := by
  rw [softplus_deriv]
  rw [abs_of_pos (logisticSigmoid_pos x)]
  exact le_of_lt (logisticSigmoid_lt_one x)

/-- The softplus inverse function: σ⁻¹(y) = log(eʸ - 1) for y > 0 -/
def softplusInv (y : ℝ) : ℝ := Real.log (Real.exp y - 1)

/-- σ(σ⁻¹(y)) = y for y > 0 -/
theorem softplus_right_inverse {y : ℝ} (hy : y > 0) :
    softplus (softplusInv y) = y := by
  unfold softplus softplusInv
  rw [Real.exp_log (by nlinarith [Real.add_one_le_exp y])]
  ring_nf
  rw [Real.log_exp]

/-- σ⁻¹(σ(x)) = x for all x -/
theorem softplus_left_inverse (x : ℝ) :
    softplusInv (softplus x) = x := by
  unfold softplusInv softplus
  rw [Real.exp_log (one_plus_exp_pos x)]
  ring_nf
  rw [Real.log_exp]

/-- The logit function: logit(p) = log(p/(1-p)) -/
def logit (p : ℝ) : ℝ := Real.log (p / (1 - p))

/-- [Section: # CatalogBuild.EML.OpenQuestions
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 20] -/
theorem logit_sigmoid_inverse (x : ℝ) :
    logit (logisticSigmoid x) = x := by
  unfold logit logisticSigmoid; ring_nf;
  field_simp;
  norm_num

/-- The zero function is in the Sheffer algebra -/
theorem zero_mem_sheffer : (fun _ : ℝ => (0 : ℝ)) ∈ ShefferAlgebra :=
  const_mem_sheffer 0

/-- The Sheffer algebra is closed under addition with constants -/
theorem sheffer_add_const_closed {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) (c : ℝ) :
    (fun x => f x + c) ∈ ShefferAlgebra := by
  have hc := const_mem_sheffer c
  have := sheffer_affine_comb_closed hf hc 1 1 0
  convert this using 1; ext x; ring

/-- Three-argument log-sum-exp associativity:
log(eˣ + eʸ + eᶻ) = log(exp(log(eˣ + eʸ)) + eᶻ) -/
theorem logsumexp_assoc (x y z : ℝ) :
    Real.log (Real.exp x + Real.exp y + Real.exp z) =
    Real.log (Real.exp (Real.log (Real.exp x + Real.exp y)) + Real.exp z) := by
  congr 1
  rw [Real.exp_log (by positivity)]

/-- The Sheffer algebra is infinite-dimensional: for each n ≠ m, σ(x+n) ≠ σ(x+m) -/
theorem sheffer_infinite_dim : ∀ n m : ℕ, n ≠ m →
    (fun x => softplus (x + n)) ≠ (fun x => softplus (x + m)) := by
  intro n m hnm h
  have := congr_fun h 0
  simp at this
  have := softplus_strictMono.injective this
  exact hnm (Nat.cast_injective this)

/-- Every Sheffer expression has at most linear growth:
there exist A, B such that |f(x)| ≤ A|x| + B for all x.
This is a consequence of the Lipschitz property. -/
theorem sheffer_expr_linear_growth (e : ShefferExpr) :
    ∃ A B : ℝ, A ≥ 0 ∧ B ≥ 0 ∧ ∀ x : ℝ, |e.eval x| ≤ A * |x| + B := by
  obtain ⟨C, hC, hLip⟩ := sheffer_expr_lipschitz e
  refine ⟨C, |e.eval 0|, hC, abs_nonneg _, fun x => ?_⟩
  have h := hLip x 0
  simp at h
  have h1 : |e.eval x| ≤ |e.eval x - e.eval 0| + |e.eval 0| := by
    linarith [abs_sub_abs_le_abs_sub (e.eval x) (e.eval 0)]
  linarith

end