import Mathlib

/-!
# Inverse Stereographic Renormalization Group

This file develops the theory of **geometric renormalization via stereographic dynamics**.
The central idea: a coupling parameter `g : ℝ` is compactified to the projective line
via inverse stereographic projection, evolved by changing the stereographic pole, and returned
to affine coordinates. The resulting map is a Möbius transformation encoding a geometric
renormalization step.

## Main results

* `rgUpdate_eq_moebiusF` — The two-pole composition equals the Möbius map F_{a,b}.
* `rgUpdate_no_real_fixed_point` — For distinct poles, the RG update has no real fixed points.
* `rgUpdate_eq_id_implies_same_pole` — The RG update is the identity iff poles coincide.
* `deriv_moebiusF'_formula` — Explicit derivative of the two-pole composition.
* `energy_deriv_zero_of_rgUpdate_compat` — Energy conservation under compatible RG.
-/

noncomputable section

/-- The pole map M_a(t) = (at + 1)/(t - a). -/
def poleMap (a t : ℝ) : ℝ := (a * t + 1) / (t - a)

/-- The two-pole Möbius map F_{a,b} =
((ab+1)t + (b-a)) / ((a-b)t + (ab+1)). -/
def moebiusF' (a b t : ℝ) : ℝ :=
  ((a * b + 1) * t + (b - a)) / ((a - b) * t + (a * b + 1))

/-- A single RG step with pole `a`. -/
def rgStep (a : ℝ) (g : ℝ) : ℝ := poleMap a g

/-- The two-pole RG update: compose pole maps with poles a then b. -/
def rgUpdate (a b : ℝ) (g : ℝ) : ℝ := rgStep b (rgStep a g)

/-- Geometric beta observable: deviation from identity. -/
def betaGeom (a b g : ℝ) : ℝ := rgUpdate a b g - g

/-- Fixed point of the two-pole RG update. -/
def IsRGFixedPoint (a b g : ℝ) : Prop := rgUpdate a b g = g

/-- Energy compatibility: E is preserved by the RG update. -/
def EnergyCompatibleRG (E : ℝ → ℝ) (a b : ℝ) : Prop :=
  ∀ g, E (rgUpdate a b g) = E g

/-- Iterated RG update. -/
def rgIter (a b : ℝ) : ℕ → ℝ → ℝ
  | 0 => id
  | n + 1 => rgUpdate a b ∘ rgIter a b n

/-! ## Fundamental identities -/

theorem poleMap_involution (a t : ℝ) (ht : t ≠ a) (hmt : poleMap a t ≠ a) :
    poleMap a (poleMap a t) = t := by
  grind +locals

theorem rgUpdate_eq_moebiusF (a b g : ℝ) (hg : g ≠ a) (hm : rgStep a g ≠ b) :
    rgUpdate a b g = moebiusF' a b g := by
  unfold rgUpdate moebiusF';
  unfold rgStep poleMap at *;
  grind

theorem moebiusF'_same_pole (a g : ℝ) : moebiusF' a a g = g := by
  unfold moebiusF';
  rw [ div_eq_iff ] <;> nlinarith

/-! ## Theorem 1: Nontriviality -/

/-
For distinct poles, the RG update has no real fixed points.
-/
theorem rgUpdate_no_real_fixed_point {a b : ℝ} (hab : a ≠ b)
    (g : ℝ) (hg : g ≠ a) (hm : rgStep a g ≠ b) :
    ¬ IsRGFixedPoint a b g := by
  unfold IsRGFixedPoint;
  -- By definition of $rgUpdate$, we have $rgUpdate a b g = poleMap b (poleMap a g)$.
  unfold rgUpdate;
  nontriviality;
  by_contra h_contra;
  -- Multiply both sides of the equation by the denominator to clear the fraction.
  have h_mul : (b * ((a * g + 1) / (g - a)) + 1) = g * ((a * g + 1) / (g - a) - b) := by
    unfold rgStep at h_contra;
    unfold poleMap at h_contra;
    rwa [ div_eq_iff ( sub_ne_zero_of_ne <| by tauto ) ] at h_contra;
  -- Simplify the equation obtained after multiplying both sides.
  have h_simplified : (a - b) * (g^2 + 1) = 0 := by
    grind;
  exact mul_ne_zero ( sub_ne_zero_of_ne hab ) ( by positivity ) h_simplified

/-
If the RG update is identity on all nonsingular inputs, poles coincide.
-/
theorem rgUpdate_eq_id_implies_same_pole {a b : ℝ}
    (h : ∀ g : ℝ, g ≠ a → rgStep a g ≠ b → rgUpdate a b g = g) :
    a = b := by
  by_contra h_contra_contra;
  -- Consider $g = a + 1$. We have $g \neq a$.
  have hg : a + 1 ≠ a := by
    norm_num;
  -- Consider two cases: $a^2 + a + 1 = b$ and $a^2 + a + 1 \neq b$.
  by_cases h_case : a^2 + a + 1 = b;
  · -- Consider $g = a + 2$. We have $g \neq a$.
    have hg2 : a + 2 ≠ a := by
      linarith;
    have := h ( a + 2 ) hg2 ?_ <;> norm_num [ rgUpdate, rgStep, poleMap ] at *;
    · rw [ div_eq_iff ] at this <;> cases lt_or_gt_of_ne h_contra_contra <;> nlinarith [ sq_nonneg ( a + 1 ) ];
    · cases lt_or_gt_of_ne h_contra_contra <;> nlinarith;
  · have h_case1 : rgUpdate a b (a + 1) = a + 1 := by
      apply h (a + 1) hg;
      unfold rgStep poleMap; contrapose! h_case; nlinarith [ mul_div_cancel₀ ( a * ( a + 1 ) + 1 ) ( show ( a + 1 ) - a ≠ 0 by linarith ) ] ;
    have h_case1_contra : ¬ IsRGFixedPoint a b (a + 1) := by
      apply rgUpdate_no_real_fixed_point h_contra_contra (a + 1) hg (by
      unfold rgStep; unfold poleMap; norm_num; contrapose! h_case; nlinarith;)
    exact h_case1_contra h_case1

/-
Fixed point iff poles coincide.
-/
theorem isRGFixedPoint_iff_eq_poles (a b g : ℝ)
    (hg : g ≠ a) (hm : rgStep a g ≠ b) :
    IsRGFixedPoint a b g ↔ a = b := by
  by_cases hab : a = b;
  · grind +locals;
  · exact iff_of_false ( fun h => rgUpdate_no_real_fixed_point hab g hg hm h ) hab

/-! ## Theorem 2: Derivative formulas -/

/-
Derivative of the pole map.
-/
theorem deriv_poleMap (a g : ℝ) (hg : g ≠ a) :
    deriv (poleMap a) g = -(1 + a ^ 2) / (g - a) ^ 2 := by
  convert HasDerivAt.deriv ( HasDerivAt.div ( HasDerivAt.const_mul a ( hasDerivAt_id' g ) |> HasDerivAt.add <| hasDerivAt_const _ _ ) ( hasDerivAt_id' g |> HasDerivAt.sub <| hasDerivAt_const _ _ ) _ ) using 1 <;> norm_num [ hg, sub_ne_zero ];
  ring

/-
Derivative of moebiusF': the geometric beta coefficient.
-/
theorem deriv_moebiusF'_formula (a b g : ℝ)
    (hd : (a - b) * g + (a * b + 1) ≠ 0) :
    deriv (moebiusF' a b) g =
      (1 + a ^ 2) * (1 + b ^ 2) / ((a - b) * g + (a * b + 1)) ^ 2 := by
  unfold moebiusF';
  norm_num [ mul_comm ] at *;
  norm_num [ hd ] ; ring

/-- The derivative of moebiusF' is always positive. -/
theorem deriv_moebiusF'_pos (a b g : ℝ)
    (hd : (a - b) * g + (a * b + 1) ≠ 0) :
    0 < deriv (moebiusF' a b) g := by
  rw [deriv_moebiusF'_formula a b g hd]
  apply div_pos
  · apply mul_pos <;> nlinarith [sq_nonneg a, sq_nonneg b]
  · positivity

/-! ## Theorem 3: Energy conservation -/

theorem energy_conserved_under_rgUpdate
    {E g : ℝ → ℝ} {a b : ℝ}
    (hcompat : EnergyCompatibleRG E a b) (t : ℝ) :
    E (rgUpdate a b (g t)) = E (g t) :=
  hcompat (g t)

theorem energy_trajectory_invariance
    {E g : ℝ → ℝ} {a b : ℝ}
    (hcompat : EnergyCompatibleRG E a b)
    (hcons : ∀ t, E (g t) = E (g 0)) (t : ℝ) :
    E (rgUpdate a b (g t)) = E (g 0) := by
  rw [energy_conserved_under_rgUpdate hcompat, hcons]

theorem energy_deriv_zero_of_rgUpdate_compat
    {E g : ℝ → ℝ} {a b : ℝ}
    (hcompat : EnergyCompatibleRG E a b)
    (hcons : ∀ t, E (g t) = E (g 0)) :
    ∀ t, deriv (fun t => E (rgUpdate a b (g t))) t = 0 := by
  intro t
  have : (fun t => E (rgUpdate a b (g t))) = fun _ => E (g 0) := by
    ext s; exact energy_trajectory_invariance hcompat hcons s
  rw [this]; simp

/-! ## Theorem 4: Algebraic structure -/

/-- Determinant of the Möbius matrix factors as Gaussian norms. -/
theorem rgUpdate_det (a b : ℝ) :
    (a * b + 1) ^ 2 - (b - a) * (a - b) = (1 + a ^ 2) * (1 + b ^ 2) := by ring

theorem rgUpdate_det_pos (a b : ℝ) :
    0 < (1 + a ^ 2) * (1 + b ^ 2) := by positivity

/-
Composition transitivity: F_{b,c} ∘ F_{a,b} = F_{a,c}.
-/
theorem rgUpdate_composition (a b c g : ℝ)
    (h1 : (a - b) * g + (a * b + 1) ≠ 0)
    (h2 : (b - c) * moebiusF' a b g + (b * c + 1) ≠ 0) :
    moebiusF' b c (moebiusF' a b g) = moebiusF' a c g := by
  unfold moebiusF' at *;
  grind

/-
Reverse poles give inverse: F_{b,a} ∘ F_{a,b} = id.
-/
theorem rgUpdate_reverse_is_inverse (a b g : ℝ)
    (h1 : (a - b) * g + (a * b + 1) ≠ 0)
    (h2 : (b - a) * moebiusF' a b g + (b * a + 1) ≠ 0) :
    moebiusF' b a (moebiusF' a b g) = g := by
  unfold moebiusF' at *;
  grind

/-! ## Theorem 5: Elliptic classification -/

/-- The discriminant is -4(a-b)² ≤ 0. -/
theorem rgUpdate_discriminant_nonpos (a b : ℝ) :
    -4 * (a - b) ^ 2 ≤ 0 := by nlinarith [sq_nonneg (a - b)]

/-- For distinct poles, strictly negative discriminant. -/
theorem rgUpdate_strictly_elliptic {a b : ℝ} (hab : a ≠ b) :
    -4 * (a - b) ^ 2 < 0 := by
  have hab' : a - b ≠ 0 := sub_ne_zero.mpr hab
  have : 0 < (a - b) ^ 2 := by positivity
  linarith

/-
The conformal factor is bounded by 2.
-/
theorem conformal_factor_le_two (t : ℝ) : 2 / (1 + t ^ 2) ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-
Inverse stereographic image lies on S¹.
-/
theorem invStereo_on_circle (g : ℝ) :
    (2 * g / (1 + g ^ 2)) ^ 2 + ((1 - g ^ 2) / (1 + g ^ 2)) ^ 2 = 1 := by
  -- Combine and simplify the fractions in the numerator.
  field_simp
  ring

/-
Conformal distortion of the pole map.
-/
theorem rgStep_conformal_distortion (a g : ℝ) (hg : g ≠ a) :
    |deriv (poleMap a) g| = (1 + a ^ 2) / (g - a) ^ 2 := by
  unfold poleMap;
  norm_num [ mul_comm a, sub_ne_zero.mpr hg ];
  rw [ abs_div, abs_sq ] ; ring;
  rw [ abs_of_nonpos ] <;> linarith [ sq_nonneg a ]

@[simp] theorem rgIter_zero (a b g : ℝ) : rgIter a b 0 g = g := rfl
@[simp] theorem rgIter_one (a b g : ℝ) : rgIter a b 1 g = rgUpdate a b g := rfl

end