/-! # CatalogBuild.Geometry.Stereographic.IntegerPoleCharts

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 26
-/

import Mathlib

noncomputable section

/-- The integer-pole chart map T_{n,m}(z) = (nz + m)/(z + 1).
Maps ∞ → n (North Pole) and 0 → m (South Pole). -/
def intPoleChart (n m z : ℝ) : ℝ := (n * z + m) / (z + 1)

/-- The inverse chart map T_{n,m}⁻¹(w) = (w - m)/(n - w).
    Maps n → ∞ and m → 0. -/

def intPoleChartInv (n m w : ℝ) : ℝ := (w - m) / (n - w)

/-- The transition map from (n₁,m₁)-chart to (n₂,m₂)-chart. -/

def chartTransition (n₁ m₁ n₂ m₂ w : ℝ) : ℝ :=
  ((n₂ - m₂) * w + (m₂ * n₁ - n₂ * m₁)) / (n₁ - m₁)

/-! ## Part II: Basic Properties -/

/-- T_{n,m}(0) = m: South Pole maps to m. -/

theorem intPoleChart_south (n m : ℝ) : intPoleChart n m 0 = m := by
  simp [intPoleChart]

/-- T_{n,m}(1) = (n+m)/2: the equatorial point maps to the arithmetic mean. -/

theorem intPoleChart_equator (n m : ℝ) : intPoleChart n m 1 = (n + m) / 2 := by
  unfold intPoleChart; ring

/-- The determinant n - m of the chart matrix is nonzero when n ≠ m. -/

theorem intPoleChart_det_ne_zero {n m : ℝ} (h : n ≠ m) : n - m ≠ 0 := by
  intro h'; exact h (by linarith)

/-! ## Part III: Inverse Properties -/

/-
PROBLEM
T_{n,m}⁻¹(T_{n,m}(z)) = z for z ≠ -1 and n ≠ m.

PROVIDED SOLUTION
Unfold intPoleChart and intPoleChartInv. We get ((nz+m)/(z+1) - m) / (n - (nz+m)/(z+1)). Numerator: (nz+m-m(z+1))/(z+1) = (nz+m-mz-m)/(z+1) = z(n-m)/(z+1). Denominator: (n(z+1)-(nz+m))/(z+1) = (nz+n-nz-m)/(z+1) = (n-m)/(z+1). Ratio = z(n-m)/(n-m) = z. Use field_simp and ring with hypotheses z+1≠0 (from hz) and n-m≠0 (from hnm).
-/

theorem intPoleChart_inv_left (n m z : ℝ) (hz : z ≠ -1) (hnm : n ≠ m) :
    intPoleChartInv n m (intPoleChart n m z) = z := by
  unfold intPoleChartInv intPoleChart;
  grind

/-
PROBLEM
T_{n,m}(T_{n,m}⁻¹(w)) = w for w ≠ n and n ≠ m.

PROVIDED SOLUTION
Unfold intPoleChart and intPoleChartInv. We get (n*((w-m)/(n-w)) + m) / ((w-m)/(n-w) + 1). Numerator: (n(w-m)+m(n-w))/(n-w) = (nw-nm+mn-mw)/(n-w) = w(n-m)/(n-w). Denominator: ((w-m)+(n-w))/(n-w) = (n-m)/(n-w). Ratio = w(n-m)/(n-m) = w. Use field_simp and ring.
-/

theorem intPoleChart_inv_right (n m w : ℝ) (hw : w ≠ n) (hnm : n ≠ m) :
    intPoleChart n m (intPoleChartInv n m w) = w := by
  unfold intPoleChart intPoleChartInv;
  grind

/-! ## Part IV: Transition Maps -/

/-
PROBLEM
The transition map T_{n₂,m₂} ∘ T_{n₁,m₁}⁻¹ equals the affine map
    w ↦ ((n₂-m₂)w + m₂n₁ - n₂m₁) / (n₁-m₁).

PROVIDED SOLUTION
Unfold intPoleChart, intPoleChartInv, chartTransition. We need (n₂*((w-m₁)/(n₁-w)) + m₂) / ((w-m₁)/(n₁-w) + 1) = ((n₂-m₂)*w + m₂*n₁ - n₂*m₁)/(n₁-m₁). The LHS numerator is (n₂(w-m₁)+m₂(n₁-w))/(n₁-w) = ((n₂-m₂)w + m₂n₁-n₂m₁)/(n₁-w). The LHS denominator is ((w-m₁)+(n₁-w))/(n₁-w) = (n₁-m₁)/(n₁-w). So LHS = ((n₂-m₂)w + m₂n₁-n₂m₁)/(n₁-m₁) = RHS. Use field_simp and ring.
-/

theorem transition_is_affine (n₁ m₁ n₂ m₂ w : ℝ)
    (hw : w ≠ n₁) (h₁ : n₁ ≠ m₁) (h₂ : n₂ ≠ m₂) :
    intPoleChart n₂ m₂ (intPoleChartInv n₁ m₁ w) = chartTransition n₁ m₁ n₂ m₂ w := by
  unfold intPoleChart intPoleChartInv chartTransition ; ring;
  grind

/-! ## Part V: Pole-Swap Duality -/

/-
PROBLEM
The classical pole-swap t → 1/t is an involution.

PROVIDED SOLUTION
Use field_simp and the hypothesis ht : t ≠ 0.
-/

theorem pole_swap_involution (t : ℝ) (ht : t ≠ 0) : 1 / (1 / t) = t := by
  norm_num [ ht ]

/-
PROBLEM
The dual chart transition (n,m) ↔ (m,n) is the reflection w → -w + (n+m).

PROVIDED SOLUTION
Unfold chartTransition. We get ((m-n)*w + (n*n - m*m))/(n-m). Factor: (m-n) = -(n-m). n²-m² = (n-m)(n+m). So ((-(n-m))*w + (n-m)(n+m))/(n-m) = -w + (n+m). Use field_simp and ring with n-m ≠ 0.
-/

theorem dual_is_reflection (n m w : ℝ) (hnm : n ≠ m) :
    chartTransition n m m n w = -w + (n + m) := by
  rw [ chartTransition ] ; rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne hnm <;> nlinarith;

/-
PROBLEM
The midpoint (n+m)/2 is the self-dual point: it is fixed under the dual transition.

PROVIDED SOLUTION
Use dual_is_reflection to reduce to -((n+m)/2) + (n+m) = (n+m)/2. This is immediate by ring. Or: unfold chartTransition, field_simp, ring.
-/

theorem self_dual_point (n m : ℝ) (hnm : n ≠ m) :
    chartTransition n m m n ((n + m) / 2) = (n + m) / 2 := by
  rw [ chartTransition ] ; rw [ div_eq_iff ( sub_ne_zero_of_ne hnm ) ] ; ring;

/-! ## Part VI: The Pole Map and Involution -/

/-- The change-of-pole map M_a(t) = (at + 1)/(t - a). -/

def poleChangeMap (a t : ℝ) : ℝ := (a * t + 1) / (t - a)

/-- M_0(t) = 1/t: at a = 0, the pole change is classical inversion. -/

theorem poleChangeMap_zero (t : ℝ) (ht : t ≠ 0) :
    poleChangeMap 0 t = 1 / t := by
  simp [poleChangeMap]

/-- The denominator 1 + a² is always positive. -/

theorem one_add_sq_pos (a : ℝ) : (0 : ℝ) < 1 + a ^ 2 := by positivity

/-! ## Part VII: Crystallization and Rational Structure -/

/-- The k-th crystal point in the (n,m)-chart is (nk + m)/(k + 1). -/

def crystalPoint (n m : ℤ) (k : ℤ) : ℚ := (n * k + m : ℤ) / (k + 1 : ℤ)

/-- At k = 0, the crystal point equals m. -/

theorem crystalPoint_zero (n m : ℤ) : crystalPoint n m 0 = m := by
  simp [crystalPoint]

/-- At k = 1, the crystal point equals (n + m)/2. -/

theorem crystalPoint_one (n m : ℤ) : crystalPoint n m 1 = (n + m : ℤ) / 2 := by
  simp [crystalPoint]

/-! ## Part VIII: Gaussian Integer Connection -/

/-- The effective denominator in the (n,m)-chart: D_{n,m}(w) = (n-m)² + (w-m)². -/

def effectiveDenom (n m w : ℝ) : ℝ := (n - m) ^ 2 + (w - m) ^ 2

/-- The effective denominator is always nonneg. -/

theorem effectiveDenom_nonneg (n m w : ℝ) : 0 ≤ effectiveDenom n m w := by
  unfold effectiveDenom; positivity

/-
PROBLEM
The effective denominator is positive when n ≠ m.

PROVIDED SOLUTION
(n-m)^2 > 0 since n ≠ m, and (w-m)^2 ≥ 0, so sum is positive. Use sq_pos_of_ne_zero for (n-m) and sq_nonneg for (w-m), then add.
-/

theorem effectiveDenom_pos (n m w : ℝ) (hnm : n ≠ m) : 0 < effectiveDenom n m w := by
  exact add_pos_of_pos_of_nonneg ( sq_pos_of_ne_zero ( sub_ne_zero.mpr hnm ) ) ( sq_nonneg _ )

/-! ## Part IX: Transition Group Properties -/

/-- The scale factor of the transition from (n₁,m₁) to (n₂,m₂). -/

def transitionScale (n₁ m₁ n₂ m₂ : ℝ) : ℝ := (n₂ - m₂) / (n₁ - m₁)

/-- The translation of the transition from (n₁,m₁) to (n₂,m₂). -/

def transitionShift (n₁ m₁ n₂ m₂ : ℝ) : ℝ := (m₂ * n₁ - n₂ * m₁) / (n₁ - m₁)

/-- The identity transition: (n,m) → (n,m) has scale 1 and shift 0. -/

theorem transition_identity_scale (n m : ℝ) (hnm : n ≠ m) :
    transitionScale n m n m = 1 := by
  unfold transitionScale
  have : n - m ≠ 0 := sub_ne_zero.mpr hnm
  field_simp

/-
PROBLEM
The identity transition maps w to w.

PROVIDED SOLUTION
Unfold chartTransition. We get ((n-m)*w + (m*n - n*m))/(n-m) = (n-m)*w/(n-m) = w. Use field_simp with n-m ≠ 0, then ring.
-/

theorem transition_identity (n m w : ℝ) (hnm : n ≠ m) :
    chartTransition n m n m w = w := by
  grind +locals

/-
PROBLEM
The dual scale factor is -1.

PROVIDED SOLUTION
Unfold transitionScale. (m-n)/(n-m) = -(n-m)/(n-m) = -1. Use field_simp with n-m ≠ 0, then ring.
-/

theorem dual_scale (n m : ℝ) (hnm : n ≠ m) :
    transitionScale n m m n = -1 := by
  unfold transitionScale; rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne hnm <;> nlinarith;


end
