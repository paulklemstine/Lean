/-
# Derivative Theory for Iterated Exponentials

This file establishes the derivative recurrence for iterated exponentials
and proves that derivative growth is the analytic signature of depth.

## Main results

* `deriv_iterExp_succ` — the derivative recurrence:
    `(iterExp (k+1))'(x) = exp(iterExp k x) · (iterExp k)'(x)`
* `deriv_iterExp_lower_bound` — on [0,1], `deriv (iterExp k) x ≥ 1`
* `deriv_iterExp_ge_iterExp` — the stronger bound:
    `iterExp k x ≤ deriv (iterExp (k+1)) x` on [0,1]

## Tags

derivative envelope, sensitivity amplification, depth hierarchy
-/
import Mathlib
import Speculative.DepthHierarchy.Basic

noncomputable section

open Real Set

/-! ## Derivative recurrence -/

/-
The derivative of `iterExp (k+1)` factors as
    `exp(iterExp k x) * deriv(iterExp k) x`.
-/
theorem deriv_iterExp_succ (k : ℕ) (x : ℝ) :
    deriv (iterExp (k + 1)) x =
      Real.exp (iterExp k x) * deriv (iterExp k) x := by
  convert deriv_comp _ ( Real.differentiableAt_exp ) ( show DifferentiableAt ℝ ( fun x => iterExp k x ) _ from iterExp_differentiable k _ ) using 1;
  rw [ Real.deriv_exp ]

/-
The derivative of `iterExp 0` is 1 (identity function).
-/
theorem deriv_iterExp_zero (x : ℝ) : deriv (iterExp 0) x = 1 := by
  -- By definition of iterExp, we know that iterExp 0 is the identity function.
  have h_id : iterExp 0 = fun x => x := by
    exact List.map_inj.mp rfl
  rw [h_id]
  simp [deriv]

/-
The derivative of `iterExp 1` is `exp(x)`.
-/
theorem deriv_iterExp_one (x : ℝ) : deriv (iterExp 1) x = Real.exp x := by
  exact HasDerivAt.deriv ( by simpa using HasDerivAt.exp ( hasDerivAt_id x ) )

/-! ## Derivative lower bounds — the analytic signature of depth -/

/-
**Derivative lower bound**: On [0,1], the derivative of `iterExp k` is at least 1.

This is the foundational analytic invariant: each exponential layer preserves
the property that the function grows at least as fast as the identity.
-/
theorem deriv_iterExp_lower_bound (k : ℕ) (x : ℝ) (hx : x ∈ Icc (0 : ℝ) 1) :
    1 ≤ deriv (iterExp k) x := by
  induction' k with k ih generalizing x <;> simp_all +decide [ deriv_iterExp_succ ];
  · rw [ show iterExp 0 = fun x => x from funext fun x => rfl ] ; norm_num;
  · exact one_le_mul_of_one_le_of_one_le ( Real.one_le_exp ( by linarith [ show 0 ≤ iterExp k x from Nat.recOn k ( by linarith [ iterExp_zero x ] ) fun n ihn => by rw [ iterExp_succ ] ; positivity ] ) ) ( ih x hx.1 hx.2 )

/-
**Derivative product formula**: The derivative of `iterExp k` equals
    the product of `exp(iterExp j x)` for `j = 0, ..., k-1`.

    `(iterExp k)'(x) = ∏_{j=0}^{k-1} exp(iterExp j x)`
-/
theorem deriv_iterExp_eq_prod (k : ℕ) (x : ℝ) :
    deriv (iterExp k) x = ∏ j ∈ Finset.range k, Real.exp (iterExp j x) := by
  induction' k with k ih generalizing x <;> simp_all +decide [ Finset.prod_range_succ ];
  · exact deriv_id x;
  · convert deriv_iterExp_succ k x using 1 ; rw [ ih ] ; ring

/-
**Stronger derivative lower bound**: On [0,1],
    `iterExp k x ≤ deriv (iterExp (k+1)) x`.

    This captures the key insight: the derivative of the next tower level
    is at least as large as the current tower value, because
    `(iterExp (k+1))'(x) = exp(iterExp k x) · (iterExp k)'(x) ≥ exp(iterExp k x) ≥ iterExp k x`.

    This is the "sensitivity amplification" phenomenon.
-/
theorem deriv_iterExp_ge_iterExp (k : ℕ) (x : ℝ) (hx : x ∈ Icc (0 : ℝ) 1) :
    iterExp k x ≤ deriv (iterExp (k + 1)) x := by
  rw [ deriv_iterExp_succ ];
  exact le_trans ( by linarith [ Real.add_one_le_exp ( iterExp k x ) ] ) ( mul_le_mul_of_nonneg_left ( deriv_iterExp_lower_bound k x hx ) ( Real.exp_nonneg _ ) )

end