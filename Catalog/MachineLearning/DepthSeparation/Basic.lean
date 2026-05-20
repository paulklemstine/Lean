import Speculative.DepthSeparation.Defs
import Mathlib

/-!
# Iterated Exponentials — Basic Properties

This file proves fundamental properties of `iterExp`: the recursion equation,
positivity, monotonicity in `k`, and lower bounds on `[0,1]`.

## Main results

* `iterExp_succ` — `iterExp (k+1) x = exp(iterExp k x)`
* `iterExp_zero` — `iterExp 0 x = x`
* `iterExp_pos_of_pos` — positivity on positive inputs
* `iterExp_nonneg_on_Icc` — nonnegativity on `[0,1]`
* `one_le_iterExp_succ_of_nonneg` — `1 ≤ iterExp (k+1) x` for `x ≥ 0`
* `iterExp_monotone_in_k` — `iterExp k x ≤ iterExp (k+1) x` for `x ≥ 0`
-/

noncomputable section

open Real Set Finset

@[simp]
theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl

@[simp]
theorem iterExp_succ (k : ℕ) (x : ℝ) :
    iterExp (k + 1) x = Real.exp (iterExp k x) := rfl

theorem iterExp_one (x : ℝ) : iterExp 1 x = Real.exp x := rfl

/-
`iterExp k x > 0` for all `k ≥ 1`, regardless of `x`.
-/
theorem iterExp_pos_of_succ (k : ℕ) (x : ℝ) : 0 < iterExp (k + 1) x := by
  exact Real.exp_pos _

/-
`iterExp k x ≥ 0` for `x ∈ [0,1]`.
-/
theorem iterExp_nonneg_on_Icc (k : ℕ) {x : ℝ} (hx : x ∈ Icc (0 : ℝ) 1) :
    0 ≤ iterExp k x := by
  induction' k with k ih generalizing x;
  · exact hx.1;
  · exact Real.exp_nonneg _

/-
`1 ≤ iterExp (k+1) x` for `x ≥ 0`.
-/
theorem one_le_iterExp_succ_of_nonneg (k : ℕ) {x : ℝ} (hx : 0 ≤ x) :
    1 ≤ iterExp (k + 1) x := by
  -- By definition of `iterExp`, we know that `iterExp k x ≥ 0` for all `k` and `x ≥ 0`.
  have h_iterExp_nonneg : ∀ k x, 0 ≤ x → 0 ≤ iterExp k x := by
    intro k x hx; induction' k with k ih generalizing x <;> simp_all +decide [ iterExp ] ; positivity;
  exact Real.one_le_exp ( h_iterExp_nonneg _ _ hx )

/-
`x ≤ exp x` implies towers grow with depth.
-/
theorem iterExp_le_iterExp_succ (k : ℕ) {x : ℝ} (hx : 0 ≤ x) :
    iterExp k x ≤ iterExp (k + 1) x := by
  exact Real.add_one_le_exp _ |> le_trans ( by linarith [ one_le_iterExp_succ_of_nonneg k hx ] )

/-
The sequence `k ↦ iterExp k x` is monotone for `x ≥ 0`.
-/
theorem iterExp_monotone_in_k {x : ℝ} (hx : 0 ≤ x) :
    Monotone (fun k : ℕ => iterExp k x) := by
  exact monotone_nat_of_le_succ fun k => iterExp_le_iterExp_succ k hx

/-
`iterExp k` is monotone as a function of `x`.
-/
theorem iterExp_mono_in_x (k : ℕ) : Monotone (iterExp k) := by
  -- We proceed by induction on `k`. Base case: `k = 0`.
  induction' k with k ih <;> simp [Monotone];
  aesop

/-
`iterExp k` is continuous.
-/
theorem continuous_iterExp (k : ℕ) : Continuous (iterExp k) := by
  induction' k with k ih;
  · exact continuous_id;
  · exact Real.continuous_exp.comp ih

/-
`iterExp k` is differentiable.
-/
theorem differentiable_iterExp (k : ℕ) : Differentiable ℝ (iterExp k) := by
  induction' k with k ih;
  · exact differentiable_id;
  · exact Differentiable.exp ih

end