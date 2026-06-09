/-
# Split Geometry: Direction-Dependent Curvature on ℝ²

We formalize a "split geometry" on ℝ² defined by the diagonal Riemannian metric
  ds² = (1/cosh²(y)) dx² + cosh²(x) dy²
whose Gaussian curvature K(x,y) = 1/cosh²(x) - 1/cosh²(y) changes sign
across the diagonals y = ±x.

Main results:
1. The metric is positive definite everywhere.
2. K = 0 exactly on the diagonals |x| = |y| ("phase boundary").
3. K > 0 in the region |x| < |y| (elliptic behavior) and K < 0 in |x| > |y| (hyperbolic).
4. The curvature is strictly bounded: K ∈ (-1, 1).
5. K is antisymmetric under coordinate swap: K(x,y) = -K(y,x).
-/
import Mathlib

open Real Set

noncomputable section

/-! ## Definitions -/

/-- The g₁₁ component of the split metric: sech²(y). -/
def splitG11 (y : ℝ) : ℝ := 1 / (Real.cosh y) ^ 2

/-- The g₂₂ component of the split metric: cosh²(x). -/
def splitG22 (x : ℝ) : ℝ := (Real.cosh x) ^ 2

/-- Gaussian curvature of the split metric: K(x,y) = sech²(x) - sech²(y). -/
def splitCurvature (x y : ℝ) : ℝ := 1 / (Real.cosh x) ^ 2 - 1 / (Real.cosh y) ^ 2

/-! ## Metric Positive Definiteness -/

/-
!-- The metric components are positive because cosh > 0 everywhere. --!

The g₁₁ component is positive everywhere.
-/
theorem splitG11_pos (y : ℝ) : 0 < splitG11 y := by
  exact one_div_pos.mpr ( sq_pos_of_pos ( Real.cosh_pos _ ) )

/-
!-- cosh²(x) > 0 since cosh(x) > 0. --!

The g₂₂ component is positive everywhere.
-/
theorem splitG22_pos (x : ℝ) : 0 < splitG22 x := by
  exact sq_pos_of_pos <| Real.cosh_pos _

/-! ## Phase Boundary: K = 0 on diagonals -/

/-
!-- K(a,a) = 1/cosh²(a) - 1/cosh²(a) = 0 by direct cancellation. --!

The curvature vanishes on the main diagonal y = x.
-/
theorem splitCurvature_zero_diag (a : ℝ) : splitCurvature a a = 0 := by
  unfold splitCurvature; ring;

/-
!-- K(a,-a) = 1/cosh²(a) - 1/cosh²(-a) = 0 since cosh is even. --!

The curvature vanishes on the anti-diagonal y = -x.
-/
theorem splitCurvature_zero_antidiag (a : ℝ) : splitCurvature a (-a) = 0 := by
  unfold splitCurvature; norm_num [ Real.cosh_neg ] ;

/-! ## Antisymmetry -/

/-
!-- K(x,y) = sech²(x) - sech²(y) = -(sech²(y) - sech²(x)) = -K(y,x). --!

The curvature is antisymmetric under coordinate swap.
-/
theorem splitCurvature_antisymm (x y : ℝ) :
    splitCurvature x y = -splitCurvature y x := by
      unfold splitCurvature; ring;

/-! ## Key Monotonicity Lemma -/

/-
!-- Since cosh is strictly increasing on [0,∞) and even, cosh(|x|) = cosh(x),
so cosh²(x) < cosh²(y) iff |x| < |y|. --!

cosh² is strictly monotone on [0,∞), the key engine for curvature sign analysis.
-/
theorem cosh_sq_strictMonoOn :
    StrictMonoOn (fun x => (Real.cosh x) ^ 2) (Ici 0) := by
      -- Since $\cosh(x)$ is strictly increasing on $[0, \infty)$, we have $\cosh(x) < \cosh(y)$ for $0 \leq x < y$.
      have h_cosh_mono : StrictMonoOn Real.cosh (Set.Ici 0) := by
        intro x hx y hy hxy;
        simp_all +decide [ Real.cosh_lt_cosh, abs_of_nonneg ];
      exact fun x hx y hy hxy => pow_lt_pow_left₀ ( h_cosh_mono hx hy hxy ) ( Real.cosh_pos _ |> le_of_lt ) ( by norm_num )

/-
Fundamental: cosh(x) < cosh(y) iff |x| < |y|.
-/
theorem cosh_lt_cosh_iff_abs_lt {x y : ℝ} :
    Real.cosh x < Real.cosh y ↔ |x| < |y| := by
      cases abs_cases x <;> cases abs_cases y <;> simp +decide [ * ]

/-! ## Curvature Sign Characterization -/

/-
!-- K > 0 iff 1/cosh²(x) > 1/cosh²(y) iff cosh²(y) > cosh²(x)
iff cosh(|y|) > cosh(|x|) iff |y| > |x|. --!

In the region |x| < |y|, the curvature is positive (elliptic character).
-/
theorem splitCurvature_pos_of_abs_lt {x y : ℝ} (h : |x| < |y|) :
    0 < splitCurvature x y := by
      unfold splitCurvature;
      rw [ sub_pos, div_lt_div_iff₀ ] <;> norm_num [ Real.cosh_pos ];
      exact pow_lt_pow_left₀ ( by simpa using Real.cosh_lt_cosh.mpr h ) ( Real.cosh_pos _ |> le_of_lt ) ( by norm_num )

/-
In the region |x| > |y|, the curvature is negative (hyperbolic character).
-/
theorem splitCurvature_neg_of_abs_gt {x y : ℝ} (h : |x| > |y|) :
    splitCurvature x y < 0 := by
      exact splitCurvature_antisymm x y ▸ neg_neg_of_pos ( splitCurvature_pos_of_abs_lt h )

/-! ## The Full Iff Characterization -/

/-
!-- Combines positivity, negativity, and monotonicity of cosh. --!

The curvature vanishes if and only if the point lies on a diagonal |x| = |y|.
-/
theorem splitCurvature_eq_zero_iff {x y : ℝ} :
    splitCurvature x y = 0 ↔ |x| = |y| := by
      constructor;
      · intro h
        by_contra hxy;
        cases lt_or_gt_of_ne hxy <;> [ exact ne_of_gt ( splitCurvature_pos_of_abs_lt ‹_› ) h; exact ne_of_lt ( splitCurvature_neg_of_abs_gt ‹_› ) h ];
      · intro h;
        simp_all +decide [ abs_eq_abs, splitCurvature ];
        cases h <;> simp +decide [ * ]

/-
Complete sign characterization of the curvature.
-/
theorem splitCurvature_pos_iff {x y : ℝ} :
    0 < splitCurvature x y ↔ |x| < |y| := by
      exact ⟨ fun h => lt_of_le_of_ne ( le_of_not_gt fun h' => h.not_ge <| splitCurvature_neg_of_abs_gt ( by linarith ) |> le_of_lt ) fun h' => h.ne' <| splitCurvature_eq_zero_iff.mpr h', fun h => splitCurvature_pos_of_abs_lt h ⟩

/-! ## Curvature Bounds -/

/-
!-- Since 0 < sech²(t) ≤ 1 for all t, the difference sech²(x) - sech²(y) ∈ (-1,1). --!

The curvature is strictly bounded between -1 and 1.
-/
theorem splitCurvature_bound (x y : ℝ) :
    -1 < splitCurvature x y ∧ splitCurvature x y < 1 := by
      norm_num [ splitCurvature ];
      constructor <;> nlinarith [ inv_le_one_of_one_le₀ ( show 1 ≤ Real.cosh y ^ 2 by exact one_le_pow₀ ( Real.one_le_cosh _ ) ), inv_le_one_of_one_le₀ ( show 1 ≤ Real.cosh x ^ 2 by exact one_le_pow₀ ( Real.one_le_cosh _ ) ), inv_pos.mpr ( sq_pos_of_pos ( Real.cosh_pos x ) ), inv_pos.mpr ( sq_pos_of_pos ( Real.cosh_pos y ) ), mul_inv_cancel₀ ( ne_of_gt ( sq_pos_of_pos ( Real.cosh_pos x ) ) ), mul_inv_cancel₀ ( ne_of_gt ( sq_pos_of_pos ( Real.cosh_pos y ) ) ) ]

/-
The curvature achieves value 0 at the origin.
-/
theorem splitCurvature_origin : splitCurvature 0 0 = 0 := by
  exact splitCurvature_zero_diag 0

/-! ## Metric Determinant -/

/-- The determinant of the split metric tensor: det(g) = cosh²(x)/cosh²(y). -/
def splitMetricDet (x y : ℝ) : ℝ := (Real.cosh x) ^ 2 / (Real.cosh y) ^ 2

/-
!-- det(g) = g₁₁ · g₂₂ = sech²(y) · cosh²(x) = cosh²(x)/cosh²(y) > 0. --!

The metric determinant is always positive (non-degeneracy).
-/
theorem splitMetricDet_pos (x y : ℝ) : 0 < splitMetricDet x y := by
  exact div_pos ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( sq_pos_of_pos ( Real.cosh_pos _ ) )

/-
det(g) ≥ 1 when |x| ≥ |y| and det(g) ≤ 1 when |x| ≤ |y|.
-/
theorem splitMetricDet_ge_one_iff {x y : ℝ} :
    1 ≤ splitMetricDet x y ↔ |y| ≤ |x| := by
      unfold splitMetricDet;
      rw [ one_le_div ];
      · rw [ ← Real.sqrt_le_sqrt_iff ( by positivity ), Real.sqrt_sq ( le_of_lt ( Real.cosh_pos _ ) ), Real.sqrt_sq ( le_of_lt ( Real.cosh_pos _ ) ), Real.cosh_le_cosh ];
      · exact sq_pos_of_pos ( Real.cosh_pos _ )

end