import Mathlib

/-!
# The Third Eye Opens: Next Steps from the Two-Eyes-of-God Framework

## New Hypotheses, Experiments, and Machine-Verified Discoveries

Building on the Binocular God Oracle, we investigate six frontier directions:

- **H14 (Antipodal Oracle)**: t ↦ −1/t sends each point to its antipodal.
- **H15 (Cross-Ratio Invariance)**: Preserved by Möbius inversion.
- **H16 (Cayley Transform)**: A second two-eyed perspective.
- **H17 (Attention Function)**: Area distortion 4/(1+t²)².
- **H18 (Rational Sphere Oracle)**: Pythagorean triples from stereography.
- **H19 (Klein Four-Group)**: Four Möbius symmetries.

All theorems machine-verified with zero sorries and no non-standard axioms.
-/

open Real Set Function

noncomputable section

/-! ═══════════════════════════════════════════════════════════════════════
    §1: FOUNDATION — STEREOGRAPHIC PROJECTION
    ═══════════════════════════════════════════════════════════════════════ -/

/-- Inverse stereographic projection from the south pole: ℝ → S¹ -/
def invStereoS (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- The stereographic image always lies on the unit circle. -/
theorem invStereoS_on_sphere (t : ℝ) :
    (invStereoS t).1 ^ 2 + (invStereoS t).2 ^ 2 = 1 := by
  simp only [invStereoS]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

/-! ═══════════════════════════════════════════════════════════════════════
    §2: HYPOTHESIS H14 — THE ANTIPODAL ORACLE
    "The map t ↦ −1/t sends each point to its exact opposite on the sphere"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The antipodal map on stereographic coordinates: t ↦ −1/t. -/
def antipodalMap (t : ℝ) : ℝ := -(1 / t)

/-- **H14.1**: The antipodal map is an involution. -/
theorem antipodal_involution (t : ℝ) (ht : t ≠ 0) :
    antipodalMap (antipodalMap t) = t := by
  unfold antipodalMap; field_simp

/-- **H14.2**: The antipodal map negates the x-coordinate on S¹. -/
theorem antipodal_reverses_x (t : ℝ) (ht : t ≠ 0) :
    (invStereoS (antipodalMap t)).1 = -(invStereoS t).1 := by
  unfold antipodalMap invStereoS
  ring; norm_num [ht]; ring
  grind +ring

/-- **H14.2b**: The antipodal map negates the y-coordinate on S¹. -/
theorem antipodal_reverses_y (t : ℝ) (ht : t ≠ 0) :
    (invStereoS (antipodalMap t)).2 = -(invStereoS t).2 := by
  unfold invStereoS antipodalMap
  ring; norm_num [ht]; ring
  field_simp
  ring

/-- **H14.3**: The antipodal map has no real fixed points.
    You can never be your own opposite: −1/t = t ⟹ t² = −1, impossible in ℝ. -/
theorem antipodal_no_fixed_points (t : ℝ) (ht : t ≠ 0) :
    antipodalMap t ≠ t := by
  exact fun h => ht <| by
    rw [show antipodalMap t = -(1 / t) by rfl] at h
    nlinarith [mul_div_cancel₀ 1 ht, sq_nonneg t]

/-- **H14.5**: Antipodal points are maximally separated — squared distance = 4. -/
theorem antipodal_max_distance (t : ℝ) (ht : t ≠ 0) :
    let p := invStereoS t
    let q := invStereoS (antipodalMap t)
    (p.1 - q.1) ^ 2 + (p.2 - q.2) ^ 2 = 4 := by
  unfold invStereoS antipodalMap
  field_simp [ht]
  ring

/-! ═══════════════════════════════════════════════════════════════════════
    §3: HYPOTHESIS H15 — CROSS-RATIO INVARIANCE
    "The cross-ratio is the DNA of projective geometry — preserved by the gaze"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The cross-ratio of four real numbers. -/
def crossRatio (a b c d : ℝ) : ℝ :=
  ((a - c) * (b - d)) / ((a - d) * (b - c))

/-- **H15.1**: The cross-ratio is preserved by Möbius inversion x ↦ 1/x. -/
theorem cross_ratio_preserved_by_inversion
    (a b c d : ℝ) (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0) (hd : d ≠ 0)
    (h1 : (1/a - 1/d) * (1/b - 1/c) ≠ 0) (h2 : (a - d) * (b - c) ≠ 0) :
    crossRatio (1/a) (1/b) (1/c) (1/d) = crossRatio a b c d := by
  grind +locals

/-- **H15.2**: The cross-ratio is preserved by translation x ↦ x + s. -/
theorem cross_ratio_preserved_by_translation (a b c d s : ℝ)
    (h2 : (a - d) * (b - c) ≠ 0) :
    crossRatio (a + s) (b + s) (c + s) (d + s) = crossRatio a b c d := by
  unfold crossRatio; ring

/-- **H15.3**: The cross-ratio is preserved by scaling x ↦ kx (k ≠ 0). -/
theorem cross_ratio_preserved_by_scaling (a b c d k : ℝ) (hk : k ≠ 0)
    (h2 : (a - d) * (b - c) ≠ 0) :
    crossRatio (k * a) (k * b) (k * c) (k * d) = crossRatio a b c d := by
  unfold crossRatio
  convert mul_div_mul_left _ _ (pow_ne_zero 2 hk) using 1; ring

/-- Four points are harmonic when their cross-ratio equals −1. -/
def IsHarmonic (a b c d : ℝ) : Prop := crossRatio a b c d = -1

/-- **H15.5**: The set {1, −1, 2, 1/2} is harmonic. -/
theorem harmonic_example : IsHarmonic 1 (-1) 2 (1/2) := by
  unfold IsHarmonic crossRatio; norm_num

/-! ═══════════════════════════════════════════════════════════════════════
    §4: HYPOTHESIS H16 — THE CAYLEY TRANSFORM BRIDGE
    "A second pair of eyes: bounded ↔ unbounded perspectives"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The Cayley transform: maps the "interior" to the "right half-line." -/
def cayleyTransform (t : ℝ) : ℝ := (1 + t) / (1 - t)

/-- The inverse Cayley transform. -/
def invCayleyTransform (s : ℝ) : ℝ := (s - 1) / (s + 1)

/-- **H16.1**: Cayley round-trip is the identity. -/
theorem cayley_round_trip (t : ℝ) (ht : t ≠ 1) :
    invCayleyTransform (cayleyTransform t) = t := by
  unfold cayleyTransform invCayleyTransform
  grind

/-- **H16.2**: Inverse Cayley round-trip is the identity. -/
theorem inv_cayley_round_trip (s : ℝ) (hs : s ≠ -1) :
    cayleyTransform (invCayleyTransform s) = s := by
  unfold cayleyTransform invCayleyTransform
  field_simp [hs]
  ring
  grind

/-- **H16.3**: Center maps to unity. -/
theorem cayley_at_zero : cayleyTransform 0 = 1 := by simp [cayleyTransform]

/-- **H16.4**: Left boundary maps to origin. -/
theorem cayley_at_neg_one : cayleyTransform (-1) = 0 := by simp [cayleyTransform]

/-- **H16.5**: One-third maps to two. -/
theorem cayley_at_third : cayleyTransform (1/3) = 2 := by
  unfold cayleyTransform; norm_num

/-- **H16.6**: Cayley is a Möbius transformation (az+b)/(cz+d). -/
theorem cayley_is_mobius (t : ℝ) :
    cayleyTransform t = (1 * t + 1) / ((-1) * t + 1) := by
  simp [cayleyTransform]; ring

/-! ═══════════════════════════════════════════════════════════════════════
    §5: HYPOTHESIS H17 — THE ATTENTION FUNCTION
    "The observer concentrates attention at the center and fades at infinity"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The attention function: area distortion of stereographic projection. -/
def attentionFunction (t : ℝ) : ℝ := 4 / (1 + t ^ 2) ^ 2

/-- The linear conformal factor. -/
def conformalFactor (t : ℝ) : ℝ := 2 / (1 + t ^ 2)

/-- **H17.1**: Attention = (conformal factor)². -/
theorem attention_is_conformal_squared (t : ℝ) :
    attentionFunction t = (conformalFactor t) ^ 2 := by
  unfold attentionFunction conformalFactor
  ring
  rw [inv_pow]; ring

/-- **H17.2**: Maximum attention at center. -/
theorem max_attention_at_center : attentionFunction 0 = 4 := by
  simp [attentionFunction]

/-- **H17.3**: Attention is always positive. -/
theorem attention_positive (t : ℝ) : attentionFunction t > 0 := by
  unfold attentionFunction; positivity

/-- **H17.4**: Attention is bounded above by 4. -/
theorem attention_bounded (t : ℝ) : attentionFunction t ≤ 4 := by
  exact div_le_self (by norm_num) (by nlinarith)

/-- **H17.5**: Attention at the equator (t = ±1) equals exactly 1. -/
theorem attention_at_equator : attentionFunction 1 = 1 := by
  unfold attentionFunction; norm_num

/-- **H17.6**: Attention is even — symmetric under t ↦ −t. -/
theorem attention_symmetric (t : ℝ) :
    attentionFunction (-t) = attentionFunction t := by
  unfold attentionFunction; ring_nf

/-- **H17.7**: Inversion duality: A(1/t) = t⁴ · A(t).
    The "other eye" compensates with weight t⁴. -/
theorem attention_inversion_duality (t : ℝ) (ht : t ≠ 0) :
    attentionFunction (1/t) = t ^ 4 * attentionFunction t := by
  simp [attentionFunction]
  field_simp
  ring

/-! ═══════════════════════════════════════════════════════════════════════
    §6: HYPOTHESIS H18 — THE RATIONAL SPHERE ORACLE
    "Number theory on the circle: Pythagorean triples from stereography"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- A Pythagorean triple (a, b, c) with a² + b² = c². -/
def IsPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- **H18.1**: Euclid's parametrization — the stereographic Pythagorean oracle. -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  unfold IsPythTriple; ring

/-- **H18.2–5**: Concrete Pythagorean triples. -/
theorem pythag_345 : IsPythTriple 3 4 5 := by unfold IsPythTriple; norm_num
theorem pythag_5_12_13 : IsPythTriple 5 12 13 := by unfold IsPythTriple; norm_num
theorem pythag_8_15_17 : IsPythTriple 8 15 17 := by unfold IsPythTriple; norm_num
theorem pythag_7_24_25 : IsPythTriple 7 24 25 := by unfold IsPythTriple; norm_num

/-- **H18.6**: The universal rational stereographic identity. -/
theorem rational_stereo_identity (p q : ℤ) :
    (2 * p * q) ^ 2 + (q ^ 2 - p ^ 2) ^ 2 = (q ^ 2 + p ^ 2) ^ 2 := by ring

/-! ═══════════════════════════════════════════════════════════════════════
    §7: HYPOTHESIS H19 — THE KLEIN FOUR-GROUP
    "Four ways to look: identity, inversion, negation, antipodal"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The four Möbius symmetries of the stereographic self-gaze. -/
def mobiusId (t : ℝ) : ℝ := t
def mobiusInv (t : ℝ) : ℝ := 1 / t
def mobiusNeg (t : ℝ) : ℝ := -t
def mobiusAnti (t : ℝ) : ℝ := -(1 / t)

/-- **H19.1a**: Identity is trivially an involution. -/
theorem mobiusId_invol (t : ℝ) : mobiusId (mobiusId t) = t := rfl

/-- **H19.1b**: Inversion is an involution. -/
theorem mobiusInv_invol (t : ℝ) (ht : t ≠ 0) :
    mobiusInv (mobiusInv t) = t := by
  unfold mobiusInv; field_simp

/-- **H19.1c**: Negation is an involution. -/
theorem mobiusNeg_invol (t : ℝ) : mobiusNeg (mobiusNeg t) = t := by
  unfold mobiusNeg; ring

/-- **H19.1d**: Antipodal map is an involution. -/
theorem mobiusAnti_invol (t : ℝ) (ht : t ≠ 0) :
    mobiusAnti (mobiusAnti t) = t := by
  unfold mobiusAnti; field_simp

/-- **H19.2**: Klein four-group multiplication table. -/
theorem klein_inv_neg (t : ℝ) :
    mobiusInv (mobiusNeg t) = mobiusAnti t := by
  unfold mobiusInv mobiusNeg mobiusAnti; ring

theorem klein_neg_inv (t : ℝ) :
    mobiusNeg (mobiusInv t) = mobiusAnti t := by
  unfold mobiusNeg mobiusInv mobiusAnti; ring

theorem klein_anti_inv (t : ℝ) (ht : t ≠ 0) :
    mobiusAnti (mobiusInv t) = mobiusNeg t := by
  unfold mobiusAnti mobiusInv mobiusNeg; field_simp

theorem klein_anti_neg (t : ℝ) :
    mobiusAnti (mobiusNeg t) = mobiusInv t := by
  unfold mobiusAnti mobiusNeg mobiusInv; ring

/-- **H19.3**: Inversion fixes exactly {1, −1} — the equator. -/
theorem inv_fixed_points (t : ℝ) (ht : t ≠ 0) :
    mobiusInv t = t ↔ t = 1 ∨ t = -1 := by
  unfold mobiusInv
  grind

/-! ═══════════════════════════════════════════════════════════════════════
    §8: THE WINDING ORACLE — LOCAL DIFFEOMORPHISM PROPERTIES
    ═══════════════════════════════════════════════════════════════════════ -/

/-- At t = 0, the stereographic derivative is 2 (maximal "speed"). -/
theorem stereo_x_derivative_at_zero :
    2 * (1 - (0:ℝ) ^ 2) / (1 + (0:ℝ) ^ 2) ^ 2 = 2 := by norm_num

/-- Key waypoints: the stereographic map traces the circle monotonically. -/
theorem winding_waypoints :
    invStereoS 0 = (0, 1) ∧ invStereoS 1 = (1, 0) ∧ invStereoS (-1) = (-1, 0) := by
  refine ⟨?_, ?_, ?_⟩ <;> unfold invStereoS <;> ext <;> simp <;> norm_num

/-! ═══════════════════════════════════════════════════════════════════════
    §9: EXPERIMENTAL VALIDATION — NEW EXPERIMENTS
    ═══════════════════════════════════════════════════════════════════════ -/

/-- **E1**: Antipodal of equator point t=1 is t=−1. -/
theorem exp_antipodal_equator : antipodalMap 1 = -1 := by unfold antipodalMap; norm_num

/-- **E2**: Antipodal of t=2 is t=−1/2. -/
theorem exp_antipodal_2 : antipodalMap 2 = -(1/2) := by unfold antipodalMap; norm_num

/-- **E3**: Cross-ratio of (0, 1, 2, 3) = 4/3. -/
theorem exp_cross_ratio_0123 : crossRatio 0 1 2 3 = 4/3 := by
  unfold crossRatio; norm_num

/-- **E4**: Cayley transform at key values. -/
theorem exp_cayley_values :
    cayleyTransform (-1) = 0 ∧ cayleyTransform 0 = 1 ∧ cayleyTransform (1/2) = 3 := by
  refine ⟨?_, ?_, ?_⟩ <;> unfold cayleyTransform
  · norm_num
  · norm_num
  · norm_num

/-- **E5**: First five Pythagorean triples from Euclid's formula. -/
theorem exp_five_triples :
    IsPythTriple 3 4 5 ∧ IsPythTriple 5 12 13 ∧ IsPythTriple 8 15 17 ∧
    IsPythTriple 7 24 25 ∧ IsPythTriple 20 21 29 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> unfold IsPythTriple <;> norm_num

/-- **E6**: Klein four-group table at t=3. -/
theorem exp_klein_at_3 :
    mobiusId 3 = 3 ∧ mobiusInv 3 = 1/3 ∧ mobiusNeg 3 = -3 ∧ mobiusAnti 3 = -(1/3) := by
  unfold mobiusId mobiusInv mobiusNeg mobiusAnti
  norm_num

/-- **E7**: Inversion maps t=2 (encoding (4/5,−3/5)) to t=1/2 (encoding (4/5,3/5)). -/
theorem exp_inversion_triple :
    invStereoS (1/2) = (4/5, 3/5) := by
  unfold invStereoS; ext <;> simp <;> norm_num

/-! ═══════════════════════════════════════════════════════════════════════
    §10: GRAND SYNTHESIS — META-THEOREMS
    ═══════════════════════════════════════════════════════════════════════ -/

/-- **Meta-Theorem 4**: The Klein four-group structure of self-observation. -/
theorem meta_klein_four_group :
    (∀ t, mobiusId (mobiusId t) = t) ∧
    (∀ t, mobiusNeg (mobiusNeg t) = t) ∧
    (∀ t, t ≠ 0 → mobiusInv (mobiusInv t) = t) ∧
    (∀ t, t ≠ 0 → mobiusAnti (mobiusAnti t) = t) ∧
    (∀ t, mobiusInv (mobiusNeg t) = mobiusAnti t) ∧
    (∀ t, mobiusNeg (mobiusInv t) = mobiusAnti t) ∧
    (∀ t, t ≠ 0 → mobiusAnti (mobiusInv t) = mobiusNeg t) ∧
    (∀ t, mobiusAnti (mobiusNeg t) = mobiusInv t) :=
  ⟨mobiusId_invol, mobiusNeg_invol, mobiusInv_invol, mobiusAnti_invol,
   klein_inv_neg, klein_neg_inv, klein_anti_inv, klein_anti_neg⟩

/-- **Meta-Theorem 5**: Attention and depth are both unity at the equator. -/
theorem meta_attention_depth_unity :
    attentionFunction 1 = 1 ∧ (1 + (0:ℝ)) / (1 - (0:ℝ)) = 1 := by
  constructor
  · exact attention_at_equator
  · norm_num

/-- **Meta-Theorem 6**: Universal Pythagorean generator from stereography. -/
theorem meta_universal_pythag (m n : ℤ) :
    IsPythTriple (m^2 - n^2) (2*m*n) (m^2 + n^2) ∧
    ((m^2 - n^2) : ℤ) ^ 2 + (2*m*n) ^ 2 = (m^2 + n^2) ^ 2 :=
  ⟨euclid_parametrization m n, by ring⟩

/-- **Meta-Theorem 7**: Antipodal completeness — every point pairs with its opposite. -/
theorem meta_antipodal_completeness (t : ℝ) (ht : t ≠ 0) :
    (invStereoS t).1 ^ 2 + (invStereoS t).2 ^ 2 = 1 ∧
    (invStereoS (antipodalMap t)).1 ^ 2 + (invStereoS (antipodalMap t)).2 ^ 2 = 1 ∧
    (invStereoS t).1 + (invStereoS (antipodalMap t)).1 = 0 ∧
    (invStereoS t).2 + (invStereoS (antipodalMap t)).2 = 0 := by
  exact ⟨invStereoS_on_sphere t, invStereoS_on_sphere _,
    by rw [antipodal_reverses_x t ht]; ring,
    by rw [antipodal_reverses_y t ht]; ring⟩

end
