/-
# Finite Log-Sum-Exp Inequalities

A reusable convex-analytic toolkit for finite information-theoretic inequalities.
These results form the backbone of regret bounds in online learning,
evidence accumulation in Bayesian inference, and free-energy principles
in statistical mechanics.

## Main results

* `weighted_le_log_sum_exp` — Jensen's inequality: weighted mean ≤ log of weighted exponential mean
* `max_le_log_sum_exp` — Maximum is bounded by log-sum-exp
* `log_sum_exp_le_max_add_log_card` — Log-sum-exp is bounded by max + log(n)
* `cumulative_mean_le_log_average_exp` — Finite Jensen: arithmetic mean ≤ log of geometric mean of exp
-/
import Mathlib

open Finset BigOperators Real

/-! ## Positivity lemma for log-sum-exp arguments -/

/-- The weighted exponential sum is positive when weights are nonneg, sum to 1. -/
lemma pos_weighted_exp_sum {n : ℕ} (_hn : 0 < n)
    (w x : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : (∑ i, w i) = 1) :
    0 < ∑ i, w i * Real.exp (x i) := by
  have hw_pos : 0 < ∑ i, w i := by linarith
  obtain ⟨i, hi⟩ : ∃ i, w i > 0 :=
    not_forall_not.mp fun h =>
      hw_pos.ne' <| Finset.sum_eq_zero fun i _ =>
        le_antisymm (le_of_not_gt <| h i) (hw_nonneg i)
  exact lt_of_lt_of_le (mul_pos hi (Real.exp_pos _))
    (Finset.single_le_sum (fun i _ => mul_nonneg (hw_nonneg i) (Real.exp_nonneg (x i)))
      (Finset.mem_univ i))

/-! ## Theorem A: Weighted Jensen / Log-Sum-Exp -/

/-- **Jensen's inequality for log-sum-exp over finite types.**

If `w` is a probability distribution over `Fin n` and `x` is any real-valued
function, then the weighted mean of `x` is at most the log of the weighted
exponential mean. This is the finite convexity backbone for regret bounds,
evidence accumulation, and free-energy inequalities.

The proof applies `ConvexOn.map_sum_le` with `convexOn_exp` to get
`exp(∑ wᵢxᵢ) ≤ ∑ wᵢ exp(xᵢ)`, then takes `log` of both sides. -/
theorem weighted_le_log_sum_exp
    {n : ℕ} (hn : 0 < n)
    (w x : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : (∑ i, w i) = 1) :
    (∑ i, w i * x i) ≤ Real.log (∑ i, w i * Real.exp (x i)) := by
  rw [Real.le_log_iff_exp_le]
  · have h_jensen : ConvexOn ℝ (Set.univ : Set ℝ) Real.exp := convexOn_exp
    convert h_jensen.map_sum_le _ _ _ <;> aesop
  · exact pos_weighted_exp_sum hn w x hw_nonneg hw_sum

/-! ## Theorem B: Max bound via log-sum-exp -/

/-- The sum of exponentials is positive. -/
lemma pos_sum_exp {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    0 < ∑ i, Real.exp (x i) :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) ⟨⟨0, hn⟩, Finset.mem_univ _⟩

/-- **Lower bound: max ≤ log-sum-exp.**

For any vector `x : Fin n → ℝ`, every component is at most the log of the
sum of exponentials. This gives the "softmax dominates max" principle. -/
theorem max_le_log_sum_exp
    {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    ∀ i : Fin n, x i ≤ Real.log (∑ j, Real.exp (x j)) :=
  fun i => (Real.le_log_iff_exp_le (pos_sum_exp hn x)).2 <|
    Finset.single_le_sum (fun i _ => Real.exp_nonneg (x i)) (Finset.mem_univ i)

/-- **Upper bound: log-sum-exp ≤ max + log(n).**

The log-sum-exp function is sandwiched between `max(x)` and `max(x) + log(n)`.
Together with `max_le_log_sum_exp`, this gives the sharp two-sided estimate. -/
theorem log_sum_exp_le_max_add_log_card
    {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    Real.log (∑ i, Real.exp (x i))
      ≤ (Finset.univ.sup' (by haveI : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
                              exact Finset.univ_nonempty) x) + Real.log n := by
  rw [Real.log_le_iff_le_exp
    (Finset.sum_pos (fun _ _ ↦ Real.exp_pos _) ⟨⟨0, hn⟩, Finset.mem_univ _⟩)]
  have h_exp_le_max : ∀ i, Real.exp (x i) ≤
      Real.exp (Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) x) :=
    fun i => Real.exp_le_exp.mpr (Finset.le_sup' x (Finset.mem_univ i))
  convert Finset.sum_le_sum fun i _ => h_exp_le_max i using 1
  norm_num [Real.exp_add, Real.exp_log, hn]
  ring

/-! ## Theorem C: Finite Jensen / Mean bound -/

/-- **Finite Jensen inequality for arithmetic mean vs log-exp-mean.**

The arithmetic mean of `x` is at most the log of the arithmetic mean of `exp(x)`.
This is Jensen's inequality applied with uniform weights `w_i = 1/n`, and serves as a
bridge between "expert regret" style nonnegativity and evidence accumulation. -/
theorem cumulative_mean_le_log_average_exp
    {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    ((∑ i, x i) / n) ≤ Real.log ((∑ i, Real.exp (x i)) / n) := by
  have := @weighted_le_log_sum_exp n hn (fun _ => (1 : ℝ) / n) x
  simp_all +decide [Finset.sum_div _ _ _]
  simpa only [div_eq_inv_mul, Finset.mul_sum _ _ _] using
    this (mul_inv_cancel₀ (by positivity))