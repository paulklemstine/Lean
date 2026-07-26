import Mathlib

/-!
# A toy percolation model for mathematical coherence

This file gives a deliberately minimal mathematical model, rather than claiming that
historical mathematical development has already been measured this way.  A real control
parameter `x` records the number (or density) of cross-field connections, `c` is a critical
threshold, and `κ > 0` is a coupling strength.  The coherence order parameter is

`C(x) = √(κ max (x - c) 0)`.

The proved chain establishes an inactive phase, a coherent phase, continuity at the
threshold, and the square-root critical exponent characteristic of a mean-field continuous
transition.  The final results specialize the threshold to 10,000 edges.  That number is a
model parameter, not an empirical prediction established by these proofs.
-/

namespace MathematicsPhaseTransition

/-- Mean-field order parameter for coherence at connection level `x`. -/
noncomputable def coherence (κ c x : ℝ) : ℝ :=
  Real.sqrt (κ * max (x - c) 0)

/-
The coherence order parameter is always nonnegative.
-/
theorem coherence_nonneg (κ c x : ℝ) : 0 ≤ coherence κ c x := by
  exact Real.sqrt_nonneg _

/-
Squaring coherence recovers the positive-part linear law when the coupling is
nonnegative.
-/
theorem coherence_sq (κ c x : ℝ) (hκ : 0 ≤ κ) :
    (coherence κ c x) ^ 2 = κ * max (x - c) 0 := by
  exact Real.sq_sqrt <| mul_nonneg hκ <| le_max_right _ _

/-
Below the critical connection level, coherence vanishes.
-/
theorem coherence_eq_zero_of_le (κ c x : ℝ) (hκ : 0 ≤ κ) (hx : x ≤ c) :
    coherence κ c x = 0 := by
  have hsquare := coherence_sq κ c x hκ
  have hnonneg := coherence_nonneg κ c x
  rw [max_eq_right (sub_nonpos.mpr hx), mul_zero] at hsquare
  nlinarith

/-
At the critical point the order parameter is zero.
-/
theorem coherence_at_critical (κ c : ℝ) (hκ : 0 ≤ κ) :
    coherence κ c c = 0 := by
  exact coherence_eq_zero_of_le κ c c hκ le_rfl

/-
Above threshold, the square of coherence grows linearly with excess connections.
-/
theorem coherence_sq_of_critical_lt (κ c x : ℝ) (hκ : 0 ≤ κ) (hx : c < x) :
    (coherence κ c x) ^ 2 = κ * (x - c) := by
  convert coherence_sq _ _ _ hκ using 1 ; rw [ max_eq_left ( by linarith ) ]

/-
With positive coupling, coherence is strictly positive above threshold.
-/
theorem coherence_pos_of_critical_lt (κ c x : ℝ) (hκ : 0 < κ) (hx : c < x) :
    0 < coherence κ c x := by
  have hsquare := coherence_sq_of_critical_lt κ c x hκ.le hx
  have hnonneg := coherence_nonneg κ c x
  have hproduct : 0 < κ * (x - c) := mul_pos hκ (sub_pos.mpr hx)
  nlinarith

/-
Exact square-root scaling above threshold: the critical exponent is `1/2`.
-/
theorem coherence_eq_sqrt_scaling (κ c x : ℝ) (hκ : 0 ≤ κ) (hx : c < x) :
    coherence κ c x = Real.sqrt κ * Real.sqrt (x - c) := by
  unfold coherence;
  rw [ max_eq_left ( by linarith ), Real.sqrt_mul hκ ]

/-
Coherence is monotone in the number of connections.
-/
theorem coherence_mono (κ c : ℝ) (hκ : 0 ≤ κ) :
    Monotone (coherence κ c) := by
  exact fun x y hxy ↦ Real.sqrt_le_sqrt <| mul_le_mul_of_nonneg_left ( max_le_max ( sub_le_sub_right hxy _ ) le_rfl ) hκ

/-
A quantitative approach-to-criticality estimate from the coherent side.
-/
theorem coherence_lt_of_excess_lt (κ c x ε : ℝ)
    (hκ : 0 ≤ κ) (hε : 0 < ε) (hx : c < x)
    (hexcess : x - c < ε ^ 2 / (κ + 1)) :
    coherence κ c x < ε := by
  convert Real.sqrt_lt_sqrt ?_ ?_ using 1;
  rw [ Real.sqrt_sq hε.le ];
  · positivity;
  · rw [ lt_div_iff₀ ] at hexcess <;> cases max_cases ( x - c ) 0 <;> nlinarith

/-
Sequential right-continuity at the transition, stated without invoking topology APIs.
-/
theorem coherence_tends_to_zero_from_above (κ c : ℝ) (hκ : 0 ≤ κ)
    (x : ℕ → ℝ) (habove : ∀ n, c < x n)
    (happroach : ∀ ε > 0, ∃ N, ∀ n ≥ N, x n - c < ε ^ 2 / (κ + 1)) :
    ∀ ε > 0, ∃ N, ∀ n ≥ N, coherence κ c (x n) < ε := by
  intros ε hε;
  exact Exists.elim ( happroach ε hε ) fun N hN => ⟨ N, fun n hn => coherence_lt_of_excess_lt κ c ( x n ) ε hκ hε ( habove n ) ( hN n hn ) ⟩

/-- The proposed number-theory threshold, represented as an exact model parameter. -/
def numberTheoryCriticalEdges : ℕ := 10000

/-
At or below 10,000 edges, the integer-indexed model remains incoherent.
-/
theorem number_theory_inactive_at_or_below (κ : ℝ) (hκ : 0 ≤ κ) (edges : ℕ)
    (hedges : edges ≤ numberTheoryCriticalEdges) :
    coherence κ numberTheoryCriticalEdges edges = 0 := by
  exact coherence_eq_zero_of_le _ _ _ hκ (mod_cast hedges)

/-
Above 10,000 edges, positive coupling gives positive modeled coherence.
-/
theorem number_theory_active_above (κ : ℝ) (hκ : 0 < κ) (edges : ℕ)
    (hedges : numberTheoryCriticalEdges < edges) :
    0 < coherence κ numberTheoryCriticalEdges edges := by
  convert coherence_pos_of_critical_lt κ ( numberTheoryCriticalEdges : ℝ ) edges hκ _;
  norm_cast

end MathematicsPhaseTransition