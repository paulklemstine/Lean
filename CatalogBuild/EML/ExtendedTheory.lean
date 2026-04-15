/-! # CatalogBuild.EML.ExtendedTheory

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 40
-/

import Mathlib

noncomputable section

/-- The real EML operator. -/
def emlE (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal EML map: d(z) = exp(z) - ln(z). -/

def emlDiagonal (z : ℝ) : ℝ := Real.exp z - Real.log z

/-! ## Section 1: Diagonal Map Has No Real Fixed Points -/

/-
exp(z) - ln(z) > z for all z > 0.
-/

theorem emlDiagonal_gt_of_pos (z : ℝ) (hz : 0 < z) : emlDiagonal z > z := by
  unfold emlDiagonal;
  have := @Real.exp_one_gt_d9.le;
  rw [ show z = 1 + ( z - 1 ) by ring, Real.exp_add ];
  nlinarith [ Real.add_one_le_exp ( z - 1 ), Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( z - 1 ) ) ]

/-
exp(z) - ln(z) > z for all z ≤ 0.
    Since ln(z) = 0 for z ≤ 0 in Mathlib, we get exp(z) > z.
-/

theorem emlDiagonal_gt_of_nonpos (z : ℝ) (hz : z ≤ 0) : emlDiagonal z > z := by
  unfold emlDiagonal;
  by_cases h : z = 0 <;> simp_all +decide [ Real.log_le_iff_le_exp ];
  linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos <| neg_pos.mpr <| lt_of_le_of_ne hz h, Real.log_neg_eq_log z ]

/-
The diagonal EML map has no real fixed point.
-/

theorem emlDiagonal_no_real_fixedPoint : ∀ z : ℝ, emlDiagonal z ≠ z := by
  intro z;
  by_cases hz : 0 < z;
  · exact ne_of_gt ( emlDiagonal_gt_of_pos z hz );
  · exact ne_of_gt ( emlDiagonal_gt_of_nonpos z ( le_of_not_gt hz ) )

/-! ## Section 2: EML Monotonicity Structure -/

/-
EML is strictly increasing in its first argument.
-/

theorem emlE_strictMono_fst (y : ℝ) : StrictMono (fun x => emlE x y) := by
  exact fun x y hxy => sub_lt_sub_right ( Real.exp_lt_exp.mpr hxy ) _

/-
EML is strictly decreasing in its second argument for y > 0.
-/

theorem emlE_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => emlE x y) (Ioi 0) := by
  exact fun y hy z hz hyz => sub_lt_sub_left ( Real.log_lt_log hy hyz ) _

/-
EML in the first argument is convex (since exp is convex).
-/

theorem emlE_convexOn_fst (y : ℝ) : ConvexOn ℝ Set.univ (fun x => emlE x y) := by
  apply ConvexOn.add;
  · exact convexOn_exp;
  · exact convexOn_const _ ( convex_univ )

/-
EML in the second argument is convex on (0,∞) (since -ln is convex).
-/

theorem emlE_convexOn_snd (x : ℝ) : ConvexOn ℝ (Ioi 0) (fun y => emlE x y) := by
  fapply convexOn_of_deriv2_nonneg;
  · exact convex_Ioi 0;
  · exact ContinuousOn.sub ( continuousOn_const ) ( Real.continuousOn_log.mono fun y hy => ne_of_gt hy );
  · exact DifferentiableOn.sub ( differentiableOn_const _ ) ( differentiableOn_id.log fun y hy => ne_of_gt <| interior_subset hy );
  · refine' DifferentiableOn.congr _ _;
    exact fun y => -1 / y;
    · exact DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun y hy => ne_of_gt <| interior_subset hy;
    · unfold emlE; norm_num [ div_eq_mul_inv ] ;
      exact fun y hy => by simp +decide [ hy.ne' ];
  · unfold emlE;
    norm_num [ sub_eq_add_neg ];
    exact fun x hx => sq_nonneg x

/-! ## Section 3: EML Lower Bound -/

/-
For all z > 0, exp(z) - ln(z) ≥ 1.
-/

theorem emlDiagonal_ge_one (z : ℝ) (hz : 0 < z) : emlDiagonal z ≥ 1 := by
  unfold emlDiagonal;
  linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ]

/-! ## Section 4: Negation and Subtraction via EML -/

/-
Key identity: eml(0, exp(x)) = 1 - x. Combined with zero generation, this
    recovers negation: -x = eml(0, exp(x)) - 1 = eml(0, exp(x)) + eml(1, eml(eml(1,1),1)).
-/

theorem emlE_zero_exp (x : ℝ) : emlE 0 (Real.exp x) = 1 - x := by
  unfold emlE; norm_num

/-
Subtraction via EML: eml(ln(a), exp(b)) = a - b for a > 0.
-/

theorem emlE_subtraction (a b : ℝ) (ha : 0 < a) :
    emlE (Real.log a) (Real.exp b) = a - b := by
  unfold emlE; rw [ Real.exp_log ha, Real.log_exp ] ;

/-
Addition via EML and negation: a + b = eml(ln(a), exp(-b)) for a > 0.
-/

theorem emlE_addition (a b : ℝ) (ha : 0 < a) :
    emlE (Real.log a) (Real.exp (-b)) = a + b := by
  unfold emlE; rw [ Real.exp_log ha ] ; norm_num;

/-! ## Section 5: Power Function via EML -/

/-
For a > 0: a^b = exp(b * ln(a)).
-/

theorem power_via_exp_log (a b : ℝ) (ha : 0 < a) :
    a ^ b = Real.exp (b * Real.log a) := by
  rw [ Real.rpow_def_of_pos ha, mul_comm ]

/-! ## Section 6: EML Iteration Bounds -/

/-- The e-tower. -/

def eTowerE : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTowerE n)

/-
The e-tower grows faster than n.
-/

theorem eTowerE_ge_n (n : ℕ) : eTowerE n ≥ n := by
  induction' n with n ih <;> norm_num [ eTowerE ] at *;
  linarith [ Real.add_one_le_exp ( eTowerE n ) ]

/-! ## Section 7: EML-Generated Constants -/

/-
eml(1, e) = e - 1.
-/

theorem emlE_generates_e_minus_one : emlE 1 (Real.exp 1) = Real.exp 1 - 1 := by
  unfold emlE; norm_num;

/-
eml(0, exp(exp(1))) = 1 - e.
-/

theorem emlE_generates_one_minus_e : emlE 0 (Real.exp (Real.exp 1)) = 1 - Real.exp 1 := by
  unfold emlE; norm_num

/-
eml(e-1, 1) = exp(e-1).
-/

theorem emlE_generates_exp_e_minus_one :
    emlE (Real.exp 1 - 1) 1 = Real.exp (Real.exp 1 - 1) := by
  unfold emlE;
  norm_num

/-! ## Section 8: Lambert W Connection -/

/-
If z* = e - ln(z*), then z* + ln(z*) = e.
-/

theorem fixedPoint_lambert_connection (z : ℝ) (hz : 0 < z)
    (hfp : Real.exp 1 - Real.log z = z) :
    z + Real.log z = Real.exp 1 := by
  grind +revert

/-
At the fixed point: z * exp(z) = exp(exp(1)).
-/

theorem fixedPoint_product_form (z : ℝ) (hz : 0 < z)
    (hfp : z + Real.log z = Real.exp 1) :
    z * Real.exp z = Real.exp (Real.exp 1) := by
  rw [ ← hfp, Real.exp_add, Real.exp_log hz ];
  ring

/-! ## Section 9: Catalan Numbers -/

/-- Catalan number via recurrence. -/

def catalanNum : ℕ → ℕ
  | 0 => 1
  | n + 1 => (2 * (2 * n + 1) * catalanNum n) / (n + 2)


theorem catalanNum_zero : catalanNum 0 = 1 := by rfl

theorem catalanNum_one : catalanNum 1 = 1 := by native_decide

theorem catalanNum_two : catalanNum 2 = 2 := by native_decide

theorem catalanNum_three : catalanNum 3 = 5 := by native_decide

theorem catalanNum_four : catalanNum 4 = 14 := by native_decide

theorem catalanNum_five : catalanNum 5 = 42 := by native_decide

theorem catalanNum_six : catalanNum 6 = 132 := by native_decide

theorem catalanNum_seven : catalanNum 7 = 429 := by native_decide

/-! ## Section 10: Master Formula Growth -/

/-- Master formula parameter count: P(n) = 5 · 2^n - 6. -/

def masterParams (n : ℕ) : ℕ := 5 * 2^n - 6

/-
The parameter count grows superlinearly.
-/

theorem masterParams_double_approx (n : ℕ) (hn : n ≥ 2) :
    masterParams (n + 1) > 2 * masterParams n := by
  unfold masterParams;
  grind

/-! ## Section 11: 2D EML Dynamical System -/

/-- The symmetric 2D EML map: Φ(x,y) = (eml(x,y), eml(y,x)). -/

def emlSymmetricMap (p : ℝ × ℝ) : ℝ × ℝ :=
  (emlE p.1 p.2, emlE p.2 p.1)

/-
Trace identity: eml(x,y) + eml(y,x) = exp(x) + exp(y) - ln(x) - ln(y).
-/

theorem emlSymmetricMap_trace (x y : ℝ) :
    (emlSymmetricMap (x, y)).1 + (emlSymmetricMap (x, y)).2 =
    (Real.exp x + Real.exp y) - (Real.log x + Real.log y) := by
  unfold emlSymmetricMap;
  unfold emlE; ring

/-
Difference: eml(x,y) - eml(y,x) = (exp(x) - exp(y)) + (ln(x) - ln(y)).
-/

theorem emlSymmetricMap_diff (x y : ℝ) :
    (emlSymmetricMap (x, y)).1 - (emlSymmetricMap (x, y)).2 =
    (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold emlSymmetricMap; ring;
  unfold emlE; ring;

/-
The diagonal is invariant under the symmetric map.
-/

theorem emlSymmetricMap_diagonal (z : ℝ) :
    emlSymmetricMap (z, z) = (emlDiagonal z, emlDiagonal z) := by
  exact?

/-! ## Section 12: Fundamental Inequalities -/

/-
exp(x) ≥ 1 + x for all x.
-/

theorem exp_ge_one_add (x : ℝ) : Real.exp x ≥ 1 + x := by
  linarith [ Real.add_one_le_exp x ]

/-
ln(x) ≤ x - 1 for all x > 0.
-/

theorem log_le_sub_one (x : ℝ) (hx : 0 < x) : Real.log x ≤ x - 1 := by
  exact Real.log_le_sub_one_of_pos hx

/-
eml(x, exp(x)) = exp(x) - x ≥ 1 for all x.
-/

theorem eml_x_expx_ge_one (x : ℝ) : emlE x (Real.exp x) ≥ 1 := by
  unfold emlE;
  have := Real.add_one_le_exp x; norm_num at *; linarith

/-
ln(eml(x, 1)) = x: logarithm inverts the exponential EML.
-/

theorem eml_log_inverse (x : ℝ) : Real.log (emlE x 1) = x := by
  unfold emlE ;
  norm_num

end

end
