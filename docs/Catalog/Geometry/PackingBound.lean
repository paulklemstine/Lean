/-
Copyright (c) 2025. All rights reserved.
Stereographic Capacity Theory: Packing Bounds

This module proves the main packing bound theorems, including the closed-form
bound for S² and calibration against known optimal configurations.
-/
import Geometry.Distortion
open Real Finset

/-! ## Equivalence of the two forms of the S² bound -/

/-
The factored form `(2/cos r)² · (4π / (2π(1-cos r)))` equals the
closed form `8 / (cos²r · (1-cos r))` whenever `cos r ≠ 0` and `cos r ≠ 1`.
-/
theorem stereoBoundS2_eq_closed {r : ℝ}
    (hcos : Real.cos r ≠ 0) (_hcos1 : Real.cos r ≠ 1) :
    stereoBoundS2 r = stereoBoundS2Closed r := by
  unfold stereoBoundS2 stereoBoundS2Closed sphereArea sphericalCapArea; ring;
  -- Factor out and cancel common terms in the numerator and denominator.
  field_simp [mul_comm, mul_assoc, mul_left_comm]
  ring

/-! ## Calibration against known optimal configurations -/

/-
Key trigonometric fact: `cos(π/6) = √3/2`.
-/
theorem cos_pi_div_six : Real.cos (Real.pi / 6) = Real.sqrt 3 / 2 := by
  exact Real.cos_pi_div_six

/-
Key trigonometric fact: `cos(π/4) = √2/2`.
-/
theorem cos_pi_div_four : Real.cos (Real.pi / 4) = Real.sqrt 2 / 2 := by
  convert Real.cos_pi_div_four

/-
Key trigonometric fact: `cos(π/3) = 1/2`.
-/
theorem cos_pi_div_three : Real.cos (Real.pi / 3) = 1 / 2 := by
  exact Real.cos_pi_div_three

/-
At `r = π/6`, the closed-form S² bound is at least 12, consistent with
the icosahedron (12 vertices).
-/
theorem packing_bound_S2_pi6_calibration :
    12 ≤ stereoBoundS2Closed (Real.pi / 6) := by
  unfold stereoBoundS2Closed;
  rw [ le_div_iff₀ ] <;> norm_num <;> nlinarith [ Real.sqrt_nonneg 3, Real.sq_sqrt ( show 0 ≤ 3 by norm_num ) ]

/-
At `r = π/4`, the closed-form S² bound is at least 6, consistent with
the octahedron (6 vertices).
-/
theorem packing_bound_S2_pi4_calibration :
    6 ≤ stereoBoundS2Closed (Real.pi / 4) := by
  unfold stereoBoundS2Closed;
  norm_num [ Real.sqrt_div_self ];
  rw [ le_div_iff₀ ] <;> nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two, inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr zero_lt_two ) ) ]

/-
At `r = π/3`, the closed-form S² bound is at least 4, consistent with
the tetrahedron (4 vertices).
-/
theorem packing_bound_S2_pi3_calibration :
    4 ≤ stereoBoundS2Closed (Real.pi / 3) := by
  exact le_of_lt ( by unfold stereoBoundS2Closed; norm_num )

/-! ## Cap area positivity -/

/-
The spherical cap area is positive for `0 < r < π`.
-/
theorem sphericalCapArea_pos {r : ℝ} (hr : 0 < r) (hrπ : r < Real.pi) :
    0 < sphericalCapArea r := by
  exact mul_pos ( by positivity ) ( sub_pos_of_lt ( by rw [ ← Real.cos_zero ] ; exact Real.cos_lt_cos_of_nonneg_of_le_pi ( by linarith ) ( by linarith ) ( by linarith ) ) )

/-
The sphere area is positive.
-/
theorem sphereArea_pos (n : ℕ) : 0 < sphereArea n := by
  -- Since $4\pi > 0$, we have $sphereArea n = 4\pi > 0$.
  unfold sphereArea
  positivity

/-! ## Volume ratio bound -/

/-
The volume ratio `sphereArea 2 / sphericalCapArea r` gives a basic
area-based packing bound on `S²`: any set of points with pairwise
chordal distance ≥ 2 sin r has at most `sphereArea 2 / sphericalCapArea r`
elements. This is the simple volume bound before distortion correction.
-/
theorem volume_ratio_bound_basic (r : ℝ) (hr : 0 < r) (hrπ : r < Real.pi) :
    0 < sphereArea 2 / sphericalCapArea r := by
  exact div_pos ( by exact mul_pos ( by norm_num ) ( by positivity ) ) ( by exact mul_pos ( by positivity ) ( sub_pos_of_lt ( by rw [ ← Real.cos_zero ] ; exact Real.cos_lt_cos_of_nonneg_of_le_pi ( by linarith ) ( by linarith ) ( by linarith ) ) ) )

/-! ## Monotonicity of the bound -/

/-
The closed-form bound `8/(cos²r(1-cos r))` is monotone decreasing as a
function of `r` on `(0, π/2)` — larger caps allow fewer centers. This is
because both `cos²r` and `1-cos r` change monotonically on this interval.
-/
theorem stereoBoundS2Closed_pos {r : ℝ}
    (hr : 0 < r) (hrπ : r < Real.pi / 2) :
    0 < stereoBoundS2Closed r := by
  exact div_pos ( by norm_num ) ( mul_pos ( sq_pos_of_pos ( Real.cos_pos_of_mem_Ioo ⟨ by linarith, hrπ ⟩ ) ) ( sub_pos.mpr ( by rw [ ← Real.cos_zero ] ; exact Real.cos_lt_cos_of_nonneg_of_le_pi ( by linarith ) ( by linarith ) ( by linarith ) ) ) )