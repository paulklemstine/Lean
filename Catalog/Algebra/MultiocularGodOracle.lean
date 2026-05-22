import Mathlib

/-! # CatalogBuild.Computation.Oracles.MultiocularGodOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 65
-/

noncomputable section

/-- **NEW**: Stereographic projection from the East pole (1, 0). -/
def eastEye (p : ℝ × ℝ) : ℝ := p.2 / (1 - p.1)

/-- **NEW**: Stereographic projection from the West pole (-1, 0). -/
def westEye (p : ℝ × ℝ) : ℝ := p.2 / (1 + p.1)

/-- **NEW**: Inverse East Eye: ℝ → S¹. Note the x-y swap vs invNorthEye. -/
def invEastEye (t : ℝ) : ℝ × ℝ :=
  ((t ^ 2 - 1) / (1 + t ^ 2), 2 * t / (1 + t ^ 2))

/-- **NEW**: Inverse West Eye: ℝ → S¹. Note the x-y swap vs invSouthEye. -/
def invWestEye (t : ℝ) : ℝ × ℝ :=
  ((1 - t ^ 2) / (1 + t ^ 2), 2 * t / (1 + t ^ 2))

/-- [Section: # CatalogBuild.Computation.Oracles.MultiocularGodOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 65] -/
theorem east_eye_on_sphere (t : ℝ) :
    (invEastEye t).1 ^ 2 + (invEastEye t).2 ^ 2 = 1 := by
  simp only [invEastEye]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

/-- [Section: # CatalogBuild.Computation.Oracles.MultiocularGodOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 65] -/
theorem west_eye_on_sphere (t : ℝ) :
    (invWestEye t).1 ^ 2 + (invWestEye t).2 ^ 2 = 1 := by
  simp only [invWestEye]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

theorem east_round_trip (t : ℝ) : eastEye (invEastEye t) = t := by
  simp only [eastEye, invEastEye]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

theorem west_round_trip (t : ℝ) : westEye (invWestEye t) = t := by
  simp only [westEye, invWestEye]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

theorem east_eye_injective : Function.Injective invEastEye := by
  norm_num [ Function.Injective, invEastEye ];
  intro a₁ a₂ h₁ h₂; rw [ div_eq_div_iff ] at * <;> nlinarith [ sq_nonneg ( a₁ - a₂ ) ] ;

theorem west_eye_injective : Function.Injective invWestEye := by
  norm_num [ invWestEye, Function.Injective ];
  field_simp;
  intro a₁ a₂ h₁ h₂; cases le_or_gt a₁ 0 <;> cases le_or_gt a₂ 0 <;> nlinarith [ sq_nonneg ( a₁ - a₂ ) ] ;

/-- North and South eyes produce opposite y-coordinates. -/
theorem ns_y_duality (t : ℝ) :
    (invNorthEye t).2 = -(invSouthEye t).2 := by
  simp [invNorthEye, invSouthEye]; ring

/-- East and West eyes produce opposite x-coordinates. -/
theorem ew_x_duality (t : ℝ) :
    (invEastEye t).1 = -(invWestEye t).1 := by
  simp [invEastEye, invWestEye]; ring

/-- North/South eyes share x-coordinates. -/
theorem ns_x_agreement (t : ℝ) :
    (invNorthEye t).1 = (invSouthEye t).1 := by
  simp [invNorthEye, invSouthEye]

/-- East/West eyes share y-coordinates. -/
theorem ew_y_agreement (t : ℝ) :
    (invEastEye t).2 = (invWestEye t).2 := by
  simp [invEastEye, invWestEye]

/-- East eye is the North eye with coordinates swapped (90° rotation). -/
theorem east_is_rotated_north (t : ℝ) :
    invEastEye t = ((invNorthEye t).2, (invNorthEye t).1) := by
  simp [invEastEye, invNorthEye]

theorem west_is_rotated_south (t : ℝ) :
    invWestEye t = ((invSouthEye t).2, (invSouthEye t).1) := by
  unfold invWestEye invSouthEye; ring;

theorem three_eyes_cover_all (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) :
    (1 - y ≠ 0 ∧ 1 + y ≠ 0) ∨ (1 - y ≠ 0 ∧ 1 - x ≠ 0) ∨ (1 + y ≠ 0 ∧ 1 - x ≠ 0) := by
  grind

theorem four_eyes_cover_all (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) :
    (1 - y ≠ 0 ∧ 1 + y ≠ 0 ∧ 1 - x ≠ 0) ∨
    (1 - y ≠ 0 ∧ 1 + y ≠ 0 ∧ 1 + x ≠ 0) ∨
    (1 - y ≠ 0 ∧ 1 - x ≠ 0 ∧ 1 + x ≠ 0) ∨
    (1 + y ≠ 0 ∧ 1 - x ≠ 0 ∧ 1 + x ≠ 0) := by
  grind +ring

theorem at_most_one_blind (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) :
    ¬ (1 - y = 0 ∧ 1 - x = 0) ∧
    ¬ (1 - y = 0 ∧ 1 + x = 0) ∧
    ¬ (1 + y = 0 ∧ 1 - x = 0) ∧
    ¬ (1 + y = 0 ∧ 1 + x = 0) ∧
    ¬ (1 - y = 0 ∧ 1 + y = 0) ∧
    ¬ (1 - x = 0 ∧ 1 + x = 0) := by
  exact ⟨ fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith ⟩

theorem transition_NS (t : ℝ) (ht : t ≠ 0) :
    southEye (invNorthEye t) = 1 / t := by
  unfold southEye invNorthEye; norm_num [ ht ] ; ring;
  -- Combine and simplify the fractions
  field_simp
  ring;
  norm_num [ ht ]

theorem transition_SE (t : ℝ) (ht : t + 1 ≠ 0) :
    southEye (invEastEye t) = (t - 1) / (t + 1) := by
  unfold southEye invEastEye;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

theorem transition_NE (t : ℝ) (ht : t - 1 ≠ 0) :
    northEye (invEastEye t) = (t + 1) / (t - 1) := by
  unfold northEye invEastEye; norm_num [ ht ] ; ring;
  field_simp;
  rw [ div_eq_div_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

theorem transition_SW (t : ℝ) (ht : 1 + t ≠ 0) :
    southEye (invWestEye t) = (1 - t) / (1 + t) := by
  unfold southEye invWestEye;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

theorem transition_NW (t : ℝ) (ht : 1 - t ≠ 0) :
    northEye (invWestEye t) = (1 + t) / (1 - t) := by
  unfold northEye invWestEye;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

theorem transition_EW (t : ℝ) (ht : t ≠ 0) :
    eastEye (invWestEye t) = 1 / t := by
  unfold eastEye invWestEye; norm_num [ ht ] ; ring;
  -- Combine like terms and simplify the expression.
  field_simp
  ring_nf at *;
  norm_num [ ht ]

/-- **Composition Consistency**: τ_{SN} ∘ τ_{NE} = τ_{SE}. -/
theorem transition_composition (t : ℝ) (ht1 : t - 1 ≠ 0) (ht2 : t + 1 ≠ 0) :
    1 / ((t + 1) / (t - 1)) = (t - 1) / (t + 1) := by
  field_simp

/-- The Möbius map f(t) = (t-1)/(t+1), the fundamental trinocular transition. -/
def mobiusSE (t : ℝ) : ℝ := (t - 1) / (t + 1)

/-- **Binocular**: The N↔S transition has order 2: (1/t)⁻¹ = t. -/
theorem binocular_order_2 (t : ℝ) (ht : t ≠ 0) :
    1 / (1 / t) = t := by field_simp

theorem trinocular_f_squared (t : ℝ) (ht1 : t + 1 ≠ 0) (ht0 : t ≠ 0) :
    mobiusSE (mobiusSE t) = -(1 / t) := by
  unfold mobiusSE;
  grind

theorem trinocular_order_4 (t : ℝ)
    (ht0 : t ≠ 0) (ht1 : t ≠ 1) (htn1 : t ≠ -1) :
    mobiusSE (mobiusSE (mobiusSE (mobiusSE t))) = t := by
  grind +suggestions

theorem binocular_fixed_points (t : ℝ) (ht : t ≠ 0) :
    1 / t = t ↔ t = 1 ∨ t = -1 := by
  exact ⟨ fun h => eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ div_eq_iff ht ] at h; linarith, fun h => by rcases h with ( rfl | rfl ) <;> norm_num ⟩

theorem trinocular_no_fixed_points (t : ℝ) (ht : t + 1 ≠ 0) :
    mobiusSE t ≠ t := by
  unfold mobiusSE; intro h; rw [ div_eq_iff ht ] at h; nlinarith [ sq_nonneg t ] ;

theorem f_squared_no_fixed_points (t : ℝ) (ht0 : t ≠ 0) (ht1 : t + 1 ≠ 0) :
    mobiusSE (mobiusSE t) ≠ t := by
  unfold mobiusSE; rw [ Ne.eq_def, div_eq_iff ] <;> cases lt_or_gt_of_ne ht0 <;> cases lt_or_gt_of_ne ht1 <;> nlinarith [ div_mul_cancel₀ ( t - 1 ) ht1 ] ;

theorem binocular_depth (x y : ℝ) (hx : x ≠ 0) (hy1 : 1 - y ≠ 0) (hyn1 : 1 + y ≠ 0) :
    northEye (x, y) / southEye (x, y) = (1 + y) / (1 - y) := by
  unfold northEye southEye; rw [ div_eq_div_iff ] <;> cases lt_or_gt_of_ne hx <;> cases lt_or_gt_of_ne hyn1 <;> cases lt_or_gt_of_ne hy1 <;> ring_nf <;> nlinarith [ inv_mul_cancel₀ hyn1, inv_mul_cancel₀ hy1 ] ;

theorem ew_depth (x y : ℝ) (hy : y ≠ 0) (hx1 : 1 - x ≠ 0) (hxn1 : 1 + x ≠ 0) :
    eastEye (x, y) / westEye (x, y) = (1 + x) / (1 - x) := by
  unfold eastEye westEye; rw [ div_div_eq_mul_div ] ; ring;
  simp +decide [ mul_assoc, mul_comm y, hy ]

theorem depth_to_coordinate (y : ℝ) (hy1 : y ≠ 1) (hyn1 : y ≠ -1) :
    let r := (1 + y) / (1 - y)
    (r - 1) / (r + 1) = y := by
  grind

theorem four_eye_coordinate_recovery (x y : ℝ)
    (hx1 : x ≠ 1) (hxn1 : x ≠ -1) (hy1 : y ≠ 1) (hyn1 : y ≠ -1) :
    ((1 + y) / (1 - y) - 1) / ((1 + y) / (1 - y) + 1) = y ∧
    ((1 + x) / (1 - x) - 1) / ((1 + x) / (1 - x) + 1) = x := by
  grind +splitImp

theorem binocular_sign_ambiguity (x y : ℝ) (hy1 : 1 - y ≠ 0) (hyn1 : 1 + y ≠ 0) :
    northEye (x, y) / southEye (x, y) = northEye (-x, y) / southEye (-x, y) := by
  unfold northEye southEye; ring;

theorem trinocular_resolves_ambiguity (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hx : x ≠ 0) (hx1 : x ≠ 1) (hxn1 : x ≠ -1) :
    eastEye (x, y) ≠ eastEye (-x, y) := by
  unfold eastEye; intro H; rcases eq_or_ne y 0 with ( rfl | hy ) <;> simp_all +decide ;
  grind +splitImp

theorem omniscient_visibility (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1)
    (hne : (a, b) ≠ (x, y)) :
    0 < 1 - a * x - b * y := by
  contrapose! hne;
  exact Prod.mk_inj.mpr ⟨ by nlinarith [ sq_nonneg ( a - x ), sq_nonneg ( b - y ) ], by nlinarith [ sq_nonneg ( a - x ), sq_nonneg ( b - y ) ] ⟩

theorem distinct_dot_product_lt_one (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1)
    (hne : (a, b) ≠ (x, y)) :
    a * x + b * y < 1 := by
  -- Apply the omniscient_visibility theorem to get the positivity of 1 - a*x - b*y.
  have h_pos : 0 < 1 - a * x - b * y := omniscient_visibility a b x y hab hxy hne
  linarith [h_pos]

theorem angular_depth_positive (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1)
    (hne : (a, b) ≠ (x, y)) :
    0 < (a - x) ^ 2 + (b - y) ^ 2 := by
  exact not_le.mp fun h => hne <| Prod.mk_inj.mpr ⟨ by nlinarith only [ h ], by nlinarith only [ h ] ⟩

/-- The angular depth equals 2 - 2·dot_product. -/
theorem angular_depth_eq_chord (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1) :
    (a - x) ^ 2 + (b - y) ^ 2 = 2 - 2 * (a * x + b * y) := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg x, sq_nonneg y]

theorem n_eye_at_most_one_match (p : ℝ × ℝ) (eyes : Finset (ℝ × ℝ)) :
    (eyes.filter (· = p)).card ≤ 1 := by
  exact Finset.card_le_one.mpr fun x hx y hy => by aesop;

/-- All four cardinal eyes share the same conformal factor 2/(1+t²) > 0. -/
theorem east_eye_conformal (t : ℝ) : (0 : ℝ) < 2 / (1 + t ^ 2) := by positivity

theorem west_eye_conformal (t : ℝ) : (0 : ℝ) < 2 / (1 + t ^ 2) := by positivity

/-- The conformal factor is bounded: 0 < 2/(1+t²) ≤ 2. -/
theorem conformal_bounds (t : ℝ) : 0 < 2 / (1 + t ^ 2) ∧ 2 / (1 + t ^ 2) ≤ 2 := by
  constructor
  · positivity
  · have : 0 < 1 + t ^ 2 := by positivity
    exact div_le_of_le_mul₀ (by linarith) (by positivity) (by nlinarith [sq_nonneg t])

/-- Experiment E1: The east eye maps t=0 to the west pole (-1, 0). -/
theorem exp_east_at_zero : invEastEye 0 = (-1, 0) := by
  simp [invEastEye]

/-- Experiment E2: The west eye maps t=0 to the east pole (1, 0). -/
theorem exp_west_at_zero : invWestEye 0 = (1, 0) := by
  simp [invWestEye]

/-- Experiment E3: The east eye maps t=1 to (0, 1) = north pole. -/
theorem exp_east_at_one : invEastEye 1 = (0, 1) := by
  unfold invEastEye; norm_num

/-- Experiment E4: The west eye maps t=1 to (0, 1) = north pole. -/
theorem exp_west_at_one : invWestEye 1 = (0, 1) := by
  unfold invWestEye; norm_num

theorem exp_generic_point_visible :
    let x := Real.sqrt 2 / 2
    let y := Real.sqrt 2 / 2
    1 - y ≠ 0 ∧ 1 + y ≠ 0 ∧ 1 - x ≠ 0 ∧ 1 + x ≠ 0 := by
  grind

theorem exp_transition_se_at_3 :
    southEye (invEastEye 3) = 1 / 2 := by
  unfold southEye invEastEye; norm_num;

theorem exp_f_squared_at_2 :
    mobiusSE (mobiusSE 2) = -(1 / 2) := by
  unfold mobiusSE; norm_num;

/-- Experiment E8: The 4-eye depth ratios at (3/5, 4/5). -/
theorem exp_pythagorean_depth :
    (1 + (4:ℝ)/5) / (1 - (4:ℝ)/5) = 9 := by norm_num

theorem exp_pythagorean_depth_x :
    (1 + (3:ℝ)/5) / (1 - (3:ℝ)/5) = 4 := by norm_num

/-- Experiment E9: Coordinate recovery from depth ratios. -/
theorem exp_depth_recovery :
    ((9:ℝ) - 1) / ((9:ℝ) + 1) = 4 / 5 ∧
    ((4:ℝ) - 1) / ((4:ℝ) + 1) = 3 / 5 := by
  constructor <;> norm_num

theorem exp_trinocular_cycle :
    mobiusSE 2 = 1 / 3 ∧
    mobiusSE (1 / 3) = -(1 / 2) ∧
    mobiusSE (-(1 / 2)) = -3 ∧
    mobiusSE (-3) = 2 := by
  unfold mobiusSE; norm_num;

/-- 3D Inverse East Eye: ℝ² → S² (projection from (1,0,0)). -/
def invEastEye3D (u v : ℝ) : ℝ × ℝ × ℝ :=
  let d := 1 + u ^ 2 + v ^ 2
  ((u ^ 2 + v ^ 2 - 1) / d, 2 * u / d, 2 * v / d)

/-- The 3D east eye maps onto S². -/
theorem east_eye_3D_on_sphere (u v : ℝ) :
    let p := invEastEye3D u v
    p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 = 1 := by
  simp only [invEastEye3D]
  have h : (1 : ℝ) + u ^ 2 + v ^ 2 ≠ 0 := by positivity
  field_simp
  ring

theorem six_eyes_S2_coverage (x y z : ℝ) (hsph : x ^ 2 + y ^ 2 + z ^ 2 = 1) :
    ¬ (1 - z = 0 ∧ 1 - x = 0) := by
  exact fun h => by nlinarith [ sq_nonneg y ] ;

theorem meta_redundancy_scaling :
    (∀ x y : ℝ, x ^ 2 + y ^ 2 = 1 →
      (1 - y ≠ 0) ∨ (1 + y ≠ 0)) ∧
    (∀ x y : ℝ, x ^ 2 + y ^ 2 = 1 →
      ¬ (1 - y = 0 ∧ 1 - x = 0) ∧
      ¬ (1 - y = 0 ∧ 1 + x = 0) ∧
      ¬ (1 + y = 0 ∧ 1 - x = 0) ∧
      ¬ (1 + y = 0 ∧ 1 + x = 0)) := by
  exact ⟨ fun x y h => not_and_or.mp fun h' => by nlinarith, fun x y h => ⟨ by rintro ⟨ h₁, h₂ ⟩ ; nlinarith, by rintro ⟨ h₁, h₂ ⟩ ; nlinarith, by rintro ⟨ h₁, h₂ ⟩ ; nlinarith, by rintro ⟨ h₁, h₂ ⟩ ; nlinarith ⟩ ⟩

/-- **Meta-Theorem 5 (Transition Order Scaling)**: Antipodal transitions
always have order 2, regardless of number of eyes. -/
theorem meta_transition_scaling :
    (∀ t : ℝ, t ≠ 0 → 1 / (1 / t) = t) := by
  intro t ht; field_simp

theorem meta_depth_dimension :
    (∀ y : ℝ, y ≠ 1 → y ≠ -1 →
      ((1 + y) / (1 - y) - 1) / ((1 + y) / (1 - y) + 1) = y) ∧
    (∀ x : ℝ, x ≠ 1 → x ≠ -1 →
      ((1 + x) / (1 - x) - 1) / ((1 + x) / (1 - x) + 1) = x) := by
  grind

theorem meta_omniscience (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1)
    (hne : (a, b) ≠ (x, y)) :
    0 < (a - x) ^ 2 + (b - y) ^ 2 :=
  angular_depth_positive a b x y hab hxy hne

end