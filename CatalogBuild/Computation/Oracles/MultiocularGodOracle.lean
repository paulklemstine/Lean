/-! # CatalogBuild.Computation.Oracles.MultiocularGodOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 65
-/

import Mathlib

noncomputable section

def eastEye (p : ℝ × ℝ) : ℝ := p.2 / (1 - p.1)

/-- **NEW**: Stereographic projection from the West pole (-1, 0). -/

def westEye (p : ℝ × ℝ) : ℝ := p.2 / (1 + p.1)

/-- Inverse North Eye: ℝ → S¹ -/

def invEastEye (t : ℝ) : ℝ × ℝ :=
  ((t ^ 2 - 1) / (1 + t ^ 2), 2 * t / (1 + t ^ 2))

/-- **NEW**: Inverse West Eye: ℝ → S¹. Note the x-y swap vs invSouthEye. -/

def invWestEye (t : ℝ) : ℝ × ℝ :=
  ((1 - t ^ 2) / (1 + t ^ 2), 2 * t / (1 + t ^ 2))

/-! ═══════════════════════════════════════════════════════════════════════
    §2: ALL FOUR EYES MAP ONTO THE SPHERE
    "Each eye sees the world as a circle"
    ═══════════════════════════════════════════════════════════════════════ -/


theorem east_eye_on_sphere (t : ℝ) :
    (invEastEye t).1 ^ 2 + (invEastEye t).2 ^ 2 = 1 := by
  simp only [invEastEye]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring


theorem west_eye_on_sphere (t : ℝ) :
    (invWestEye t).1 ^ 2 + (invWestEye t).2 ^ 2 = 1 := by
  simp only [invWestEye]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

/-! ═══════════════════════════════════════════════════════════════════════
    §3: ROUND-TRIP IDENTITIES — EACH EYE PERFECTLY DECODES
    ═══════════════════════════════════════════════════════════════════════ -/


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

/-! ═══════════════════════════════════════════════════════════════════════
    §4: INJECTIVITY — EACH EYE ENCODES FAITHFULLY
    ═══════════════════════════════════════════════════════════════════════ -/

/-
PROVIDED SOLUTION
Same approach as for invSouthEye. From Prod.mk.injEq, get two div equations. Use div_eq_div_iff with positivity for denominators. Then nlinarith [sq_nonneg (a - b)].
-/

theorem east_eye_injective : Function.Injective invEastEye := by
  norm_num [ Function.Injective, invEastEye ];
  intro a₁ a₂ h₁ h₂; rw [ div_eq_div_iff ] at * <;> nlinarith [ sq_nonneg ( a₁ - a₂ ) ] ;

/-
PROVIDED SOLUTION
Same approach as east_eye_injective.
-/

theorem west_eye_injective : Function.Injective invWestEye := by
  norm_num [ invWestEye, Function.Injective ];
  field_simp;
  intro a₁ a₂ h₁ h₂; cases le_or_gt a₁ 0 <;> cases le_or_gt a₂ 0 <;> nlinarith [ sq_nonneg ( a₁ - a₂ ) ] ;

/-! ═══════════════════════════════════════════════════════════════════════
    §5: EYE DUALITY — THE FOUR EYES COME IN ANTIPODAL PAIRS
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-
PROBLEM
West eye is the South eye with coordinates swapped (90° rotation).

PROVIDED SOLUTION
Unfold invWestEye and invSouthEye, show both components match. The first component of invWestEye is (1-t²)/(1+t²) = second component of invSouthEye. The second component 2t/(1+t²) = first component of invSouthEye. Use ext and simp then ring.
-/

theorem west_is_rotated_south (t : ℝ) :
    invWestEye t = ((invSouthEye t).2, (invSouthEye t).1) := by
  unfold invWestEye invSouthEye; ring;

/-! ═══════════════════════════════════════════════════════════════════════
    §6: COVERAGE THEOREMS — HOW MANY EYES SEE EACH POINT?
    "More eyes = more redundancy = deeper understanding"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- **H1 (Binocular, recalled)**: 2 eyes → every point visible to ≥ 1 eye. -/

theorem three_eyes_cover_all (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) :
    (1 - y ≠ 0 ∧ 1 + y ≠ 0) ∨ (1 - y ≠ 0 ∧ 1 - x ≠ 0) ∨ (1 + y ≠ 0 ∧ 1 - x ≠ 0) := by
  grind

/-
PROBLEM
**H12 (Tetracular Coverage)**: 4 cardinal eyes → every point visible to ≥ 3 eyes.

PROVIDED SOLUTION
On S¹, at most one of the four denominators (1-y, 1+y, 1-x, 1+x) can be zero. If y=1 then x=0 so 1+y≠0, 1-x≠0, 1+x≠0, giving the third disjunct. Similarly for other cases. Use by_contra, push_neg, then case analysis on which denominator is zero, deriving contradictions with nlinarith from x²+y²=1.
-/

theorem four_eyes_cover_all (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) :
    (1 - y ≠ 0 ∧ 1 + y ≠ 0 ∧ 1 - x ≠ 0) ∨
    (1 - y ≠ 0 ∧ 1 + y ≠ 0 ∧ 1 + x ≠ 0) ∨
    (1 - y ≠ 0 ∧ 1 - x ≠ 0 ∧ 1 + x ≠ 0) ∨
    (1 + y ≠ 0 ∧ 1 - x ≠ 0 ∧ 1 + x ≠ 0) := by
  grind +ring

/-
PROBLEM
At most one cardinal eye is blind at any circle point.

PROVIDED SOLUTION
For each pair, if both hold, substitute into x²+y²=1 and get 2=1 or similar contradiction. E.g., 1-y=0 ∧ 1-x=0 gives y=1,x=1 so x²+y²=2≠1. Same for all 6 pairs. Use refine ⟨?_,?_,?_,?_,?_,?_⟩ then intro ⟨h1,h2⟩ and nlinarith for each.
-/

theorem at_most_one_blind (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) :
    ¬ (1 - y = 0 ∧ 1 - x = 0) ∧
    ¬ (1 - y = 0 ∧ 1 + x = 0) ∧
    ¬ (1 + y = 0 ∧ 1 - x = 0) ∧
    ¬ (1 + y = 0 ∧ 1 + x = 0) ∧
    ¬ (1 - y = 0 ∧ 1 + y = 0) ∧
    ¬ (1 - x = 0 ∧ 1 + x = 0) := by
  exact ⟨ fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith, fun h => by nlinarith ⟩

/-! ═══════════════════════════════════════════════════════════════════════
    §7: TRINOCULAR TRANSITIONS — MÖBIUS TRANSFORMATIONS
    "Three eyes create richer geometry than two"
    ═══════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
The binocular transition (N↔S) is simple inversion: t ↦ 1/t.

PROVIDED SOLUTION
Unfold southEye and invNorthEye. The numerator is 2t/(1+t²) and the denominator is 1 + (t²-1)/(1+t²) = (1+t²+t²-1)/(1+t²) = 2t²/(1+t²). So result = (2t/(1+t²)) / (2t²/(1+t²)) = 2t/(2t²) = 1/t. Use field_simp with ht and positivity for 1+t²≠0, then ring.
-/

theorem transition_NS (t : ℝ) (ht : t ≠ 0) :
    southEye (invNorthEye t) = 1 / t := by
  unfold southEye invNorthEye; norm_num [ ht ] ; ring;
  -- Combine and simplify the fractions
  field_simp
  ring;
  norm_num [ ht ]

/-
PROBLEM
**H13 (South-East Transition)**: The trinocular transition from the east eye
    to the south eye is the Möbius map t ↦ (t-1)/(t+1).

PROVIDED SOLUTION
Unfold southEye and invEastEye. southEye(invEastEye t) = x/(1+y) where x=(t²-1)/(1+t²), y=2t/(1+t²). So 1+y = (1+t²+2t)/(1+t²) = (t+1)²/(1+t²). Result = ((t²-1)/(1+t²)) / ((t+1)²/(1+t²)) = (t²-1)/(t+1)² = (t-1)(t+1)/(t+1)² = (t-1)/(t+1). Use field_simp with ht (t+1≠0) and 1+t²≠0 from positivity, then ring.
-/

theorem transition_SE (t : ℝ) (ht : t + 1 ≠ 0) :
    southEye (invEastEye t) = (t - 1) / (t + 1) := by
  unfold southEye invEastEye;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

/-
PROBLEM
**H13 (North-East Transition)**: t ↦ (t+1)/(t-1).

PROVIDED SOLUTION
Unfold northEye and invEastEye. northEye(invEastEye t) = x/(1-y) where x=(t²-1)/(1+t²), y=2t/(1+t²). 1-y = (1+t²-2t)/(1+t²) = (t-1)²/(1+t²). Result = (t²-1)/(t-1)² = (t-1)(t+1)/(t-1)² = (t+1)/(t-1). Use field_simp with ht (t-1≠0) and positivity, then ring.
-/

theorem transition_NE (t : ℝ) (ht : t - 1 ≠ 0) :
    northEye (invEastEye t) = (t + 1) / (t - 1) := by
  unfold northEye invEastEye; norm_num [ ht ] ; ring;
  field_simp;
  rw [ div_eq_div_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

/-
PROBLEM
**South-West Transition**: t ↦ (1-t)/(1+t).

PROVIDED SOLUTION
Similar to transition_SE but with invWestEye. southEye(invWestEye t) = x/(1+y) where x=(1-t²)/(1+t²), y=2t/(1+t²). 1+y = (1+t²+2t)/(1+t²) = (1+t)²/(1+t²). Result = (1-t²)/(1+t)² = (1-t)(1+t)/(1+t)² = (1-t)/(1+t). Use field_simp and ring.
-/

theorem transition_SW (t : ℝ) (ht : 1 + t ≠ 0) :
    southEye (invWestEye t) = (1 - t) / (1 + t) := by
  unfold southEye invWestEye;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

/-
PROBLEM
**North-West Transition**: t ↦ (1+t)/(1-t).

PROVIDED SOLUTION
northEye(invWestEye t) = x/(1-y) where x=(1-t²)/(1+t²), y=2t/(1+t²). 1-y = (1+t²-2t)/(1+t²) = (1-t)²/(1+t²). Result = (1-t²)/(1-t)² = (1-t)(1+t)/(1-t)² = (1+t)/(1-t). Use field_simp and ring.
-/

theorem transition_NW (t : ℝ) (ht : 1 - t ≠ 0) :
    northEye (invWestEye t) = (1 + t) / (1 - t) := by
  unfold northEye invWestEye;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne ht <;> nlinarith

/-
PROBLEM
**East-West Transition**: Antipodal East/West transition is inversion,
    just like antipodal North/South.

PROVIDED SOLUTION
eastEye(invWestEye t) = y/(1-x) where x=(1-t²)/(1+t²), y=2t/(1+t²). 1-x = (1+t²-1+t²)/(1+t²) = 2t²/(1+t²). Result = (2t/(1+t²))/(2t²/(1+t²)) = 2t/2t² = 1/t. Use field_simp with ht and positivity, then ring.
-/

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

/-! ═══════════════════════════════════════════════════════════════════════
    §8: THE TRANSITION GROUP — FROM Z₂ TO D₄
    "More eyes = richer symmetry"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The Möbius map f(t) = (t-1)/(t+1), the fundamental trinocular transition. -/

def mobiusSE (t : ℝ) : ℝ := (t - 1) / (t + 1)

/-- **Binocular**: The N↔S transition has order 2: (1/t)⁻¹ = t. -/

theorem binocular_order_2 (t : ℝ) (ht : t ≠ 0) :
    1 / (1 / t) = t := by field_simp

/-
PROBLEM
**H14**: f²(t) = -1/t (the square of the trinocular transition
    is negated inversion).

PROVIDED SOLUTION
Unfold mobiusSE. f(f(t)) = f((t-1)/(t+1)) = ((t-1)/(t+1) - 1) / ((t-1)/(t+1) + 1). Numerator = (t-1-(t+1))/(t+1) = -2/(t+1). Denominator = (t-1+t+1)/(t+1) = 2t/(t+1). So f(f(t)) = (-2/(t+1))/(2t/(t+1)) = -2/(2t) = -1/t. Use unfold mobiusSE, then field_simp with ht1 and ht0, then ring.
-/

theorem trinocular_f_squared (t : ℝ) (ht1 : t + 1 ≠ 0) (ht0 : t ≠ 0) :
    mobiusSE (mobiusSE t) = -(1 / t) := by
  unfold mobiusSE;
  grind

/-
PROBLEM
**H14**: f⁴(t) = t: four applications return to the original.

PROVIDED SOLUTION
Use trinocular_f_squared twice. f²(t) = -1/t (by trinocular_f_squared). Then f⁴(t) = f²(f²(t)) = f²(-1/t). For f²(-1/t), we need -1/t+1≠0 (which follows from t≠1) and -1/t≠0 (which follows from t≠0). By trinocular_f_squared, f²(-1/t) = -(1/(-1/t)) = -(-t) = t. Key lemma chain: show the intermediate values have the right nonzero conditions, then apply trinocular_f_squared twice.
-/

theorem trinocular_order_4 (t : ℝ)
    (ht0 : t ≠ 0) (ht1 : t ≠ 1) (htn1 : t ≠ -1) :
    mobiusSE (mobiusSE (mobiusSE (mobiusSE t))) = t := by
  grind +suggestions

/-! ═══════════════════════════════════════════════════════════════════════
    §9: FIXED POINTS OF TRINOCULAR SELF-GAZE
    "Where does the three-eyed God see himself unchanged?"
    ═══════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
**Binocular fixed points**: 1/t = t iff t = ±1.

PROVIDED SOLUTION
Forward: 1/t = t means (by field_simp) 1 = t². So t² = 1, giving t = 1 or t = -1 (by sq_eq_one_iff or by (t-1)*(t+1)=0). Backward: trivial check. Use constructor, intro, field_simp, nlinarith or decide.
-/

theorem binocular_fixed_points (t : ℝ) (ht : t ≠ 0) :
    1 / t = t ↔ t = 1 ∨ t = -1 := by
  exact ⟨ fun h => eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ div_eq_iff ht ] at h; linarith, fun h => by rcases h with ( rfl | rfl ) <;> norm_num ⟩

/-
PROBLEM
**Trinocular fixed points**: (t-1)/(t+1) = t has no real solutions!
    The three-eyed observer has NO fixed points — pure dynamism.

PROVIDED SOLUTION
Unfold mobiusSE. Suppose (t-1)/(t+1) = t. Then t-1 = t(t+1) = t²+t. So t²+t-t+1=0, i.e., t²+1=0. But t²+1 > 0 for all real t, contradiction. Use intro h, unfold mobiusSE at h, rw div_eq_iff at h, nlinarith [sq_nonneg t].
-/

theorem trinocular_no_fixed_points (t : ℝ) (ht : t + 1 ≠ 0) :
    mobiusSE t ≠ t := by
  unfold mobiusSE; intro h; rw [ div_eq_iff ht ] at h; nlinarith [ sq_nonneg t ] ;

/-
PROBLEM
**f² also has no real fixed points**: f²(t) = -1/t = t would require t² = -1.

PROVIDED SOLUTION
By trinocular_f_squared, mobiusSE(mobiusSE t) = -(1/t). If -(1/t) = t, then -1 = t², so t²+1=0, impossible since t²≥0. Rewrite with trinocular_f_squared, intro h, have : t² = -1 by field_simp at h; linarith, then nlinarith [sq_nonneg t].
-/

theorem f_squared_no_fixed_points (t : ℝ) (ht0 : t ≠ 0) (ht1 : t + 1 ≠ 0) :
    mobiusSE (mobiusSE t) ≠ t := by
  unfold mobiusSE; rw [ Ne.eq_def, div_eq_iff ] <;> cases lt_or_gt_of_ne ht0 <;> cases lt_or_gt_of_ne ht1 <;> nlinarith [ div_mul_cancel₀ ( t - 1 ) ht1 ] ;

/-! ═══════════════════════════════════════════════════════════════════════
    §10: DEPTH PERCEPTION — FROM 1D TO (N-1)D
    "More eyes = higher-dimensional depth"
    ═══════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
**Binocular depth**: northEye/southEye = (1+y)/(1-y).

PROVIDED SOLUTION
Unfold northEye and southEye. northEye(x,y)/southEye(x,y) = (x/(1-y))/(x/(1+y)) = (x·(1+y))/(x·(1-y)) = (1+y)/(1-y) since x≠0. Use unfold, div_div_eq, cancel x, field_simp.
-/

theorem binocular_depth (x y : ℝ) (hx : x ≠ 0) (hy1 : 1 - y ≠ 0) (hyn1 : 1 + y ≠ 0) :
    northEye (x, y) / southEye (x, y) = (1 + y) / (1 - y) := by
  unfold northEye southEye; rw [ div_eq_div_iff ] <;> cases lt_or_gt_of_ne hx <;> cases lt_or_gt_of_ne hyn1 <;> cases lt_or_gt_of_ne hy1 <;> ring_nf <;> nlinarith [ inv_mul_cancel₀ hyn1, inv_mul_cancel₀ hy1 ] ;

/-
PROBLEM
**New depth ratio**: eastEye/westEye = (1+x)/(1-x).

PROVIDED SOLUTION
Unfold eastEye and westEye. eastEye(x,y)/westEye(x,y) = (y/(1-x))/(y/(1+x)) = (y·(1+x))/(y·(1-x)) = (1+x)/(1-x) since y≠0. Same approach as binocular_depth.
-/

theorem ew_depth (x y : ℝ) (hy : y ≠ 0) (hx1 : 1 - x ≠ 0) (hxn1 : 1 + x ≠ 0) :
    eastEye (x, y) / westEye (x, y) = (1 + x) / (1 - x) := by
  unfold eastEye westEye; rw [ div_div_eq_mul_div ] ; ring;
  simp +decide [ mul_assoc, mul_comm y, hy ]

/-
PROBLEM
**H16**: From r = (1+y)/(1-y), we recover y = (r-1)/(r+1).

PROVIDED SOLUTION
Let r = (1+y)/(1-y). Then (r-1)/(r+1) = ((1+y)/(1-y) - 1)/((1+y)/(1-y) + 1) = ((1+y-1+y)/(1-y))/((1+y+1-y)/(1-y)) = (2y/(1-y))/(2/(1-y)) = y. Use field_simp with hy1 (y≠1 gives 1-y≠0) and hyn1 (y≠-1 gives 1+y≠0... wait, we need r+1≠0. r+1 = (1+y)/(1-y)+1 = (1+y+1-y)/(1-y) = 2/(1-y) ≠ 0. So field_simp then ring.
-/

theorem depth_to_coordinate (y : ℝ) (hy1 : y ≠ 1) (hyn1 : y ≠ -1) :
    let r := (1 + y) / (1 - y)
    (r - 1) / (r + 1) = y := by
  grind

/-
PROBLEM
**H16 (4-Eye Full Recovery)**: Both coordinates recoverable from depth.

PROVIDED SOLUTION
Both conjuncts follow from depth_to_coordinate applied to y and x respectively. Use exact ⟨depth_to_coordinate y hy1 hyn1, depth_to_coordinate x hx1 hxn1⟩.
-/

theorem four_eye_coordinate_recovery (x y : ℝ)
    (hx1 : x ≠ 1) (hxn1 : x ≠ -1) (hy1 : y ≠ 1) (hyn1 : y ≠ -1) :
    ((1 + y) / (1 - y) - 1) / ((1 + y) / (1 - y) + 1) = y ∧
    ((1 + x) / (1 - x) - 1) / ((1 + x) / (1 - x) + 1) = x := by
  grind +splitImp

/-
PROBLEM
**Binocular sign ambiguity**: N/S depth can't distinguish (x,y) from (-x,y).

PROVIDED SOLUTION
Unfold northEye, southEye. northEye(x,y)/southEye(x,y) = (1+y)/(1-y) and northEye(-x,y)/southEye(-x,y) = (-x/(1-y))/(-x/(1+y)) = (1+y)/(1-y). The x cancels in both ratios. Use simp [northEye, southEye], then ring or field_simp.
-/

theorem binocular_sign_ambiguity (x y : ℝ) (hy1 : 1 - y ≠ 0) (hyn1 : 1 + y ≠ 0) :
    northEye (x, y) / southEye (x, y) = northEye (-x, y) / southEye (-x, y) := by
  unfold northEye southEye; ring;

/-
PROBLEM
**Trinocular resolves ambiguity**: The east eye breaks the x ↦ -x symmetry.

PROVIDED SOLUTION
Unfold eastEye. eastEye(x,y) = y/(1-x) and eastEye(-x,y) = y/(1+x). If these are equal and y≠0 (which follows from hcirc and hx: x≠0 implies y²=1-x²≠1, actually we need y≠0). Actually from hcirc, y²=1-x² so y=0 iff x=±1, but x≠1 and x≠-1, so y≠0. With y≠0, y/(1-x) = y/(1+x) implies 1-x = 1+x, so 2x=0, so x=0, contradicting hx. Use intro h, unfold eastEye at h, have hy: y≠0 by nlinarith [sq_nonneg y], field_simp at h, linarith.
-/

theorem trinocular_resolves_ambiguity (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hx : x ≠ 0) (hx1 : x ≠ 1) (hxn1 : x ≠ -1) :
    eastEye (x, y) ≠ eastEye (-x, y) := by
  unfold eastEye; intro H; rcases eq_or_ne y 0 with ( rfl | hy ) <;> simp_all +decide ;
  grind +splitImp

/-! ═══════════════════════════════════════════════════════════════════════
    §11: THE OMNISCIENT OBSERVER — INFINITE EYES
    "In the limit, every point is an eye — and all is seen"
    ═══════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
**H17 (Omniscient Visibility)**: For any two distinct points on S¹,
    1 - a·x - b·y > 0, so stereographic projection is well-defined.
    Proof: (a-x)²+(b-y)² = 2-2(ax+by) > 0 when (a,b) ≠ (x,y).

PROVIDED SOLUTION
(a-x)²+(b-y)² = 2-2(ax+by) by expanding and using hab and hxy. Since (a,b)≠(x,y), (a-x)²+(b-y)² > 0, so 2-2(ax+by) > 0, hence ax+by < 1, hence 1-ax-by > 0. Use the already-proved angular_depth_eq_chord to rewrite, then show positivity from hne via Prod.mk.injEq.
-/

theorem omniscient_visibility (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1)
    (hne : (a, b) ≠ (x, y)) :
    0 < 1 - a * x - b * y := by
  contrapose! hne;
  exact Prod.mk_inj.mpr ⟨ by nlinarith [ sq_nonneg ( a - x ), sq_nonneg ( b - y ) ], by nlinarith [ sq_nonneg ( a - x ), sq_nonneg ( b - y ) ] ⟩

/-
PROBLEM
The dot product of distinct unit circle points is < 1.

PROVIDED SOLUTION
Follows directly from omniscient_visibility: 0 < 1 - a*x - b*y implies a*x + b*y < 1. Use linarith [omniscient_visibility a b x y hab hxy hne].
-/

theorem distinct_dot_product_lt_one (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1)
    (hne : (a, b) ≠ (x, y)) :
    a * x + b * y < 1 := by
  -- Apply the omniscient_visibility theorem to get the positivity of 1 - a*x - b*y.
  have h_pos : 0 < 1 - a * x - b * y := omniscient_visibility a b x y hab hxy hne
  linarith [h_pos]

/-
PROBLEM
The angular depth (chord distance²) is always positive for distinct points.

PROVIDED SOLUTION
Use angular_depth_eq_chord to rewrite, then apply omniscient_visibility. Specifically: rw [angular_depth_eq_chord a b x y hab hxy], linarith [omniscient_visibility a b x y hab hxy hne].
-/

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

/-
PROBLEM
**N-eye redundancy**: In a Finset, each element appears at most once.
    So at most 1 eye position can coincide with any given point.

PROVIDED SOLUTION
In a Finset, each element appears at most once. So (eyes.filter (· = p)).card ≤ 1 because if there are two elements in the filter, they're both equal to p, hence equal to each other, but Finset has no duplicates. Use Finset.card_le_one.mpr and intro a ha b hb, then simp at ha hb, exact ha.trans hb.symm.
-/

theorem n_eye_at_most_one_match (p : ℝ × ℝ) (eyes : Finset (ℝ × ℝ)) :
    (eyes.filter (· = p)).card ≤ 1 := by
  exact Finset.card_le_one.mpr fun x hx y hy => by aesop;

/-! ═══════════════════════════════════════════════════════════════════════
    §12: CONFORMAL FACTORS — MORE EYES, FINER RESOLUTION
    ═══════════════════════════════════════════════════════════════════════ -/

/-- All four cardinal eyes share the same conformal factor 2/(1+t²) > 0. -/

theorem east_eye_conformal (t : ℝ) : (0 : ℝ) < 2 / (1 + t ^ 2) := by positivity

theorem west_eye_conformal (t : ℝ) : (0 : ℝ) < 2 / (1 + t ^ 2) := by positivity

/-- The conformal factor is bounded: 0 < 2/(1+t²) ≤ 2. -/

theorem conformal_bounds (t : ℝ) : 0 < 2 / (1 + t ^ 2) ∧ 2 / (1 + t ^ 2) ≤ 2 := by
  constructor
  · positivity
  · have : 0 < 1 + t ^ 2 := by positivity
    exact div_le_of_le_mul₀ (by linarith) (by positivity) (by nlinarith [sq_nonneg t])

/-! ═══════════════════════════════════════════════════════════════════════
    §13: EXPERIMENTS — NUMERICAL VALIDATION
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-
PROBLEM
Experiment E5: At (√2/2, √2/2), all 4 eyes can see (all denominators nonzero).

PROVIDED SOLUTION
√2/2 > 0 and √2/2 < 1 (since √2 < 2). So 1 - √2/2 > 0 and 1 + √2/2 > 0. Use constructor, all goals by positivity or by nlinarith [Real.sq_sqrt (show (2:ℝ) ≥ 0 by norm_num), Real.sqrt_lt_sqrt].
-/

theorem exp_generic_point_visible :
    let x := Real.sqrt 2 / 2
    let y := Real.sqrt 2 / 2
    1 - y ≠ 0 ∧ 1 + y ≠ 0 ∧ 1 - x ≠ 0 ∧ 1 + x ≠ 0 := by
  grind

/-
PROBLEM
Experiment E6: Transition τ_{SE} at t=3 gives (3-1)/(3+1) = 1/2.

PROVIDED SOLUTION
Apply transition_SE with t=3, ht: 3+1≠0 by norm_num. Then (3-1)/(3+1) = 2/4 = 1/2. Use exact transition_SE 3 (by norm_num).
-/

theorem exp_transition_se_at_3 :
    southEye (invEastEye 3) = 1 / 2 := by
  unfold southEye invEastEye; norm_num;

/-
PROBLEM
Experiment E7: τ_{SE}²(2) = -1/2.

PROVIDED SOLUTION
Apply trinocular_f_squared with t=2, ht1: 2+1≠0, ht0: 2≠0, both by norm_num. Then -(1/2) = -(1/2). Use rw [trinocular_f_squared] then norm_num.
-/

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

/-
PROBLEM
Experiment E10: Trinocular transition cycle at t=2.

PROVIDED SOLUTION
Unfold mobiusSE for each step and compute: f(2) = (2-1)/(2+1) = 1/3, f(1/3) = (1/3-1)/(1/3+1) = (-2/3)/(4/3) = -1/2, f(-1/2) = (-1/2-1)/(-1/2+1) = (-3/2)/(1/2) = -3, f(-3) = (-3-1)/(-3+1) = -4/ -2 = 2. Use unfold mobiusSE, then norm_num for each conjunct.
-/

theorem exp_trinocular_cycle :
    mobiusSE 2 = 1 / 3 ∧
    mobiusSE (1 / 3) = -(1 / 2) ∧
    mobiusSE (-(1 / 2)) = -3 ∧
    mobiusSE (-3) = 2 := by
  unfold mobiusSE; norm_num;

/-! ═══════════════════════════════════════════════════════════════════════
    §14: HIGHER DIMENSIONS — 3-EYED AND 4-EYED S²
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-
PROBLEM
On S², two of the 6 cardinal denominators can't both be zero if they
    come from different axis pairs.

PROVIDED SOLUTION
If 1-z=0 and 1-x=0, then z=1 and x=1, so x²+y²+z²=1+y²+1=2+y²≥2>1, contradicting hsph. Use intro ⟨h1,h2⟩, nlinarith [sq_nonneg y].
-/

theorem six_eyes_S2_coverage (x y z : ℝ) (hsph : x ^ 2 + y ^ 2 + z ^ 2 = 1) :
    ¬ (1 - z = 0 ∧ 1 - x = 0) := by
  exact fun h => by nlinarith [ sq_nonneg y ] ;

/-! ═══════════════════════════════════════════════════════════════════════
    §15: META-THEOREMS — THE SCALING LAWS OF DIVINE SIGHT
    ═══════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
**Meta-Theorem 4 (Eyes-Redundancy Law)**: Summarizes the coverage scaling.

PROVIDED SOLUTION
Split into two conjuncts. First is two_eyes_cover_all. Second: for each pair of denominators that are both zero, derive contradiction from x²+y²=1. Use exact ⟨two_eyes_cover_all, fun x y h => at_most_one_blind x y h⟩... actually at_most_one_blind gives all 6 pairs, but meta_redundancy_scaling only needs 4 of them. Better: use refine ⟨two_eyes_cover_all, fun x y h => ?_⟩ then use at_most_one_blind or prove directly by nlinarith.
-/

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

/-
PROBLEM
**Meta-Theorem 6 (Depth-Dimension Theorem)**: Each antipodal pair
    contributes one depth dimension. N/S recovers y, E/W recovers x.

PROVIDED SOLUTION
Both conjuncts follow from depth_to_coordinate. Use exact ⟨fun y hy1 hyn1 => depth_to_coordinate y hy1 hyn1, fun x hx1 hxn1 => depth_to_coordinate x hx1 hxn1⟩.
-/

theorem meta_depth_dimension :
    (∀ y : ℝ, y ≠ 1 → y ≠ -1 →
      ((1 + y) / (1 - y) - 1) / ((1 + y) / (1 - y) + 1) = y) ∧
    (∀ x : ℝ, x ≠ 1 → x ≠ -1 →
      ((1 + x) / (1 - x) - 1) / ((1 + x) / (1 - x) + 1) = x) := by
  grind

/-
PROBLEM
**Meta-Theorem 7 (The Omniscience Theorem)**: Distinct circle points
    always have positive chord distance.

PROVIDED SOLUTION
Use angular_depth_positive a b x y hab hxy hne.
-/

theorem meta_omniscience (a b x y : ℝ)
    (hab : a ^ 2 + b ^ 2 = 1) (hxy : x ^ 2 + y ^ 2 = 1)
    (hne : (a, b) ≠ (x, y)) :
    0 < (a - x) ^ 2 + (b - y) ^ 2 :=
  angular_depth_positive a b x y hab hxy hne


end
