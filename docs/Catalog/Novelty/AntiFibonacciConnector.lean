import Mathlib

/-!
# The anti-Fibonacci exclusion rule collapses

The phrase “the smallest positive integer not equal to `x + y`” excludes only one
integer.  Consequently it is `2` exactly when `x + y = 1`, and is `1` otherwise.
With initial values `1, 1`, the resulting sequence is therefore constant.

We also connect this recurrence with extremal graph theory: joining two time indices
when their values sum to `2` produces the complete graph, so its edge count is
`n.choose 2`.  Finally, an analytic theorem shows that quadratic normalization tends
to zero, not `1/4`.
-/

namespace AntiFibonacci

/-- The least positive natural number different from the single forbidden value `x + y`. -/
def leastPositiveAvoidingSum (x y : ℕ) : ℕ := if x + y = 1 then 2 else 1

/-- The sequence specified by the literal recurrence in the prompt. -/
def antiFib : ℕ → ℕ
  | 0 => 1
  | 1 => 1
  | n + 2 => leastPositiveAvoidingSum (antiFib (n + 1)) (antiFib n)

/-
The closed form for the least positive integer outside a singleton.
-/
theorem leastPositiveAvoidingSum_spec (x y : ℕ) :
    0 < leastPositiveAvoidingSum x y ∧
      leastPositiveAvoidingSum x y ≠ x + y ∧
      ∀ m : ℕ, 0 < m → m ≠ x + y → leastPositiveAvoidingSum x y ≤ m := by
  unfold leastPositiveAvoidingSum;
  grind

/-
The literal anti-Fibonacci recurrence collapses to the constant sequence `1`.
-/
theorem antiFib_eq_one (n : ℕ) : antiFib n = 1 := by
  induction' n using Nat.twoStepInduction with n ih;
  · rfl;
  · rfl;
  · exact if_neg ( by linarith )

/-- The displayed prefix already contradicts the literal rule at indices `2` and `3`. -/
theorem displayed_prefix_is_not_generated : antiFib 2 ≠ 2 ∧ antiFib 3 ≠ 4 := by
  rw [antiFib_eq_one, antiFib_eq_one]
  norm_num

/-- Pairs of time indices whose anti-Fibonacci values sum to two. -/
def sumTwoEdges (n : ℕ) : Finset (Finset (Fin n)) :=
  ((Finset.univ : Finset (Fin n)).powersetCard 2).filter fun e =>
    ∀ i ∈ e, ∀ j ∈ e, i ≠ j → antiFib i + antiFib j = 2

/-
Connector to extremal graph theory: the induced graph is complete.
-/
theorem sumTwoEdges_eq_complete (n : ℕ) :
    sumTwoEdges n = (Finset.univ : Finset (Fin n)).powersetCard 2 := by
  simp +decide [ sumTwoEdges, antiFib_eq_one ]

/-
Hence the graph has the maximal possible number of edges.
-/
theorem card_sumTwoEdges (n : ℕ) : (sumTwoEdges n).card = n.choose 2 := by
  norm_num [ sumTwoEdges_eq_complete ]

/-
Connector to asymptotic analysis: quadratic normalization converges to zero.
-/
theorem antiFib_quadratic_normalization :
    Filter.Tendsto (fun n : ℕ => (antiFib n : ℝ) / (n : ℝ) ^ 2)
      Filter.atTop (nhds 0) := by
  simpa [ antiFib_eq_one ] using tendsto_inv_atTop_zero.comp ( by simpa only [ sq ] using tendsto_natCast_atTop_atTop.atTop_mul_atTop₀ tendsto_natCast_atTop_atTop )

/-- An exact millionth-index check, reduced using the proved closed form. -/
theorem millionth_normalized_value :
    (antiFib 1000000 : ℚ) / (1000000 : ℚ) ^ 2 = 1 / 1000000000000 := by
  rw [antiFib_eq_one]
  norm_num

/-- The proposed limit `1/4` is therefore impossible. -/
theorem not_tendsto_one_quarter :
    ¬ Filter.Tendsto (fun n : ℕ => (antiFib n : ℝ) / (n : ℝ) ^ 2)
      Filter.atTop (nhds (1 / 4)) := by
  intro h
  have heq : (0 : ℝ) = 1 / 4 := tendsto_nhds_unique antiFib_quadratic_normalization h
  norm_num at heq

end AntiFibonacci