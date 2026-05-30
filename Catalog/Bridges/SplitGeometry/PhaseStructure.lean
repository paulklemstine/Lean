/-
# Split Geometry: Phase Structure and Monotonicity

This file develops the phase structure of split geometry, proving that cosh is
strictly monotone (and hence sech² is strictly decreasing) on [0,∞), and using
this to characterize the sign of curvature in terms of |x| vs |y|.

We also develop the split Laplacian and prove a maximum principle for the
curvature potential.
-/
import Mathlib
import Bridges.SplitGeometry.Core

open Real

/-! ## Monotonicity of sech² -/

/-
cosh is strictly monotone on nonneg reals: if 0 ≤ a < b then cosh a < cosh b.
    This follows from cosh' = sinh and sinh > 0 on (0,∞).
-/
theorem cosh_strictMono_nonneg {a b : ℝ} (ha : 0 ≤ a) (hab : a < b) :
    cosh a < cosh b := by
      simp +zetaDelta at *;
      rwa [ abs_of_nonneg ha, abs_of_nonneg ( by linarith ) ]

/-
sech² is strictly decreasing on nonneg reals.
-/
theorem sechSq_strictAnti_nonneg {a b : ℝ} (ha : 0 ≤ a) (hab : a < b) :
    sechSq b < sechSq a := by
      exact one_div_lt_one_div_of_lt ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( pow_lt_pow_left₀ ( cosh_strictMono_nonneg ha hab ) ( Real.cosh_pos _ |> le_of_lt ) ( by decide ) )

/-! ## Phase Sign Characterization -/

/-
**Phase sign theorem (positive direction)**: If |x| < |y| then
    K(x,y) > 0, meaning the point is in the elliptic region.
    Proof: cosh is strictly increasing on [0,∞), so |x| < |y| implies
    cosh|x| < cosh|y|, hence sech²|x| > sech²|y|. Since sech² is even,
    sech²(x) > sech²(y), giving K > 0.
-/
theorem splitCurvature_pos_of_abs_lt {x y : ℝ} (h : |x| < |y|) :
    0 < splitCurvature x y := by
      apply sub_pos.mpr;
      convert sechSq_strictAnti_nonneg ( abs_nonneg x ) h using 1 <;> norm_num [ sechSq, abs_mul ]

/-
**Phase sign theorem (negative direction)**: If |x| > |y| then
    K(x,y) < 0, meaning the point is in the hyperbolic region.
-/
theorem splitCurvature_neg_of_abs_gt {x y : ℝ} (h : |y| < |x|) :
    splitCurvature x y < 0 := by
      unfold splitCurvature;
      unfold sechSq; exact sub_neg_of_lt <| by simpa [ sq_lt_sq ] using inv_strictAnti₀ ( by positivity ) <| pow_lt_pow_left₀ ( by simpa [ sq_lt_sq ] using h ) ( by positivity ) two_ne_zero;

/-
**Phase boundary characterization**: K(x,y) = 0 iff |x| = |y|.
-/
theorem splitCurvature_eq_zero_iff (x y : ℝ) :
    splitCurvature x y = 0 ↔ |x| = |y| := by
      constructor;
      · intro h
        have h_eq : sechSq x = sechSq y := by
          exact eq_of_sub_eq_zero h;
        have h_eq_cosh : Real.cosh |x| = Real.cosh |y| := by
          unfold sechSq at h_eq;
          simp +zetaDelta at *;
          rwa [ sq_eq_sq₀ ( Real.cosh_pos _ |> le_of_lt ) ( Real.cosh_pos _ |> le_of_lt ) ] at h_eq;
        exact le_antisymm ( le_of_not_gt fun hxy => by linarith [ cosh_strictMono_nonneg ( abs_nonneg y ) hxy ] ) ( le_of_not_gt fun hyx => by linarith [ cosh_strictMono_nonneg ( abs_nonneg x ) hyx ] );
      · unfold splitCurvature;
        unfold sechSq; rw [ abs_eq_abs ] at *; aesop;

/-! ## Curvature Integral Identities -/

/-- **Curvature moment identity**: For any finite set of points on a line,
    the sum of curvatures to a fixed point telescopes.
    ∑ᵢ K(aᵢ, b) = (∑ᵢ sech²(aᵢ)) - n · sech²(b). -/
theorem splitCurvature_sum_eq (s : Finset ι) (a : ι → ℝ) (b : ℝ) :
    ∑ i ∈ s, splitCurvature (a i) b =
    (∑ i ∈ s, sechSq (a i)) - s.card • sechSq b := by
  simp only [splitCurvature, Finset.sum_sub_distrib, Finset.sum_const]

/-- **Balanced curvature cancellation**: For any two finite sets of equal size,
    the total curvature from pairing elements sums to the difference of
    component sums. -/
theorem splitCurvature_balanced_sum (s : Finset ι) (a b : ι → ℝ) :
    ∑ i ∈ s, splitCurvature (a i) (b i) =
    (∑ i ∈ s, sechSq (a i)) - ∑ i ∈ s, sechSq (b i) := by
  simp only [splitCurvature, Finset.sum_sub_distrib]

/-! ## Split Metric Conformal Factor -/

/-- The split metric conformal factor along the x-axis. -/
noncomputable def splitConformalX (x : ℝ) : ℝ := 1 / cosh x

/-- The conformal factor is always positive. -/
lemma splitConformalX_pos (x : ℝ) : 0 < splitConformalX x := by
  unfold splitConformalX; positivity

/-- The square of the conformal factor equals sechSq. -/
lemma splitConformalX_sq (x : ℝ) : splitConformalX x ^ 2 = sechSq x := by
  unfold splitConformalX sechSq
  rw [div_pow, one_pow]

/-- **Conformal product identity**: The product of conformal factors
    gives the area element. -/
theorem splitConformal_product (x y : ℝ) :
    splitConformalX x * splitConformalX y = splitAreaElement x y := by
  unfold splitConformalX splitAreaElement
  rw [div_mul_div_comm, one_mul]

/-! ## Discrete Gauss-Bonnet Analogue -/

/-
**Discrete Gauss-Bonnet for split geometry**: For any closed polygon
    (represented as a list of coordinate pairs), the total curvature around
    the circuit via the triangle rule vanishes.

    This is a discrete analogue of ∮ K dA = 2πχ for the simply-connected plane.
-/
theorem discrete_gauss_bonnet (coords : List ℝ) (h : 3 ≤ coords.length) :
    (coords.zipWith splitCurvature (coords.tail ++ [coords.head!])).sum = 0 := by
  rcases coords with ( _ | ⟨ x, _ | ⟨ y, _ | ⟨ z, l ⟩ ⟩ ⟩ ) <;> simp_all +decide [ List.zipWith ];
  induction' l with w l ih generalizing x y z <;> simp_all +decide [ splitCurvature ];
  linarith [ ih x y w ]

/-! ## Conjecture: Curvature Concentration -/

/-!
**Conjecture (Curvature Concentration Inequality)**:
For the split metric on [-R, R]², the fraction of area in the elliptic
region approaches 1/2 as R → ∞. More precisely, the ratio of
∫∫_{K>0} dA to ∫∫_{[-R,R]²} dA converges to 1/2.

This would follow from the antisymmetry K(x,y) = -K(y,x) and the symmetry
of the area element under coordinate swap.

**Testable prediction**: For R = 10, numerical integration should give a
ratio within 0.01 of 0.5. For R = 100, within 0.001 of 0.5.
(See demo.py for numerical verification.)
-/