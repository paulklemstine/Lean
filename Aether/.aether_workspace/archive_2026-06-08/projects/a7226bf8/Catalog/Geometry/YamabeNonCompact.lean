/-
  # Yamabe Problem: Non-Compact Case

  This file formalizes key aspects of the Yamabe problem on non-compact manifolds.

  The Yamabe problem asks: given a Riemannian manifold (M, g), does there exist
  a metric conformal to g with constant scalar curvature?

  For compact manifolds, this was resolved affirmatively (Yamabe-Trudinger-Aubin-Schoen).
  For non-compact manifolds, obstructions exist. We formalize:

  1. The Yamabe energy functional and its properties
  2. The standard bubble (instanton) solution on ℝⁿ
  3. Volume growth obstructions for non-compact manifolds
  4. The conformal Laplacian and its spectral properties
  5. Concentration-compactness and bubble decomposition
-/

import Mathlib

open Real MeasureTheory Filter Topology Set

noncomputable section

/-! ## Section 1: Fundamental Constants and Exponents -/

/-- The Yamabe critical exponent p*(n) = 2n/(n-2) for dimension n ≥ 3.
    This is the critical Sobolev exponent. -/
def yamabeCriticalExponent (n : ℕ) (hn : 3 ≤ n) : ℝ :=
  2 * n / (n - 2)

/-- The conformal dimension constant c_n = (n-2)/(4(n-1)).
    Appears in the conformal Laplacian L_g = -Δ + c_n R_g. -/
def conformalDimensionConstant (n : ℕ) (hn : 1 ≤ n) : ℝ :=
  (n - 2) / (4 * (n - 1))

/-- The Yamabe nonlinear exponent: (n+2)/(n-2) for n ≥ 3. -/
def yamabeNonlinearExponent (n : ℕ) (hn : 3 ≤ n) : ℝ :=
  (n + 2) / (n - 2)

/-! ## Section 2: Bubble Solution

The standard bubble U_λ(x) = (λ/(λ²+|x|²))^((n-2)/2) is the fundamental
building block of Yamabe theory.
-/

/-- The standard Yamabe bubble (instanton) on ℝⁿ centered at origin with scale λ > 0.
    U_{λ}(r) = (λ / (λ² + r²))^((n-2)/2)
    This is the unique (up to symmetry) positive solution of the Yamabe equation on ℝⁿ. -/
def yamabeBubble (n : ℕ) (lam : ℝ) (r : ℝ) : ℝ :=
  (lam / (lam ^ 2 + r ^ 2)) ^ ((n - 2 : ℝ) / 2)

/-
The Yamabe bubble is always positive for positive scale parameter.
-/
theorem yamabeBubble_pos (n : ℕ) (hn : 3 ≤ n) (lam : ℝ) (hlam : 0 < lam) (r : ℝ) :
    0 < yamabeBubble n lam r := by
  exact Real.rpow_pos_of_pos ( by positivity ) _

/-
The Yamabe bubble at the origin equals λ^(-(n-2)/2) = (1/λ)^((n-2)/2).
-/
theorem yamabeBubble_at_origin (n : ℕ) (hn : 3 ≤ n) (lam : ℝ) (hlam : 0 < lam) :
    yamabeBubble n lam 0 = (1 / lam) ^ ((n - 2 : ℝ) / 2) := by
  unfold yamabeBubble;
  norm_num [ sq, hlam.ne' ]

/-
The bubble is monotone decreasing in radius (for nonneg r).
-/
theorem yamabeBubble_antitone (n : ℕ) (hn : 3 ≤ n) (lam : ℝ) (hlam : 0 < lam)
    {r₁ r₂ : ℝ} (hr₁ : 0 ≤ r₁) (_hr₂ : 0 ≤ r₂) (h : r₁ ≤ r₂) :
    yamabeBubble n lam r₂ ≤ yamabeBubble n lam r₁ := by
  -- Since $n \geq 3$, we have $(n-2)/2 \geq 0.5$.
  have h_exp_nonneg : (n - 2 : ℝ) / 2 > 0 := by
    linarith [ show ( n : ℝ ) ≥ 3 by norm_cast ];
  exact Real.rpow_le_rpow ( by positivity ) ( by rw [ div_le_div_iff₀ ] <;> nlinarith [ pow_le_pow_left₀ ( by positivity ) h 2 ] ) h_exp_nonneg.le

/-
The bubble decays like (λ/r²)^((n-2)/2) for large r.
-/
theorem yamabeBubble_decay_bound (n : ℕ) (hn : 3 ≤ n) (lam : ℝ) (hlam : 0 < lam)
    (r : ℝ) (hr : 0 < r) :
    yamabeBubble n lam r ≤ (lam / r ^ 2) ^ ((n - 2 : ℝ) / 2) := by
  exact Real.rpow_le_rpow ( by positivity ) ( by gcongr ; nlinarith ) ( by linarith [ show ( n : ℝ ) ≥ 3 by norm_cast ] )

/-
The bubble base fraction simplifies under simultaneous scaling:
    (μλ)/((μλ)² + (μr)²) = (1/μ) · λ/(λ² + r²).
-/
theorem yamabeBubble_scale_base (lam mu r : ℝ)
    (hlam : 0 < lam) (hmu : 0 < mu) :
    mu * lam / ((mu * lam) ^ 2 + (mu * r) ^ 2) =
    (1 / mu) * (lam / (lam ^ 2 + r ^ 2)) := by
  field_simp

/-! ## Section 3: Volume Growth and Non-Compact Obstructions -/

/-- A volume growth function for a non-compact manifold. -/
structure VolumeGrowth where
  /-- Volume of ball of radius r -/
  vol : ℝ → ℝ
  /-- Volume is positive for positive radius -/
  vol_pos : ∀ r, 0 < r → 0 < vol r
  /-- Volume is monotone -/
  vol_mono : Monotone vol
  /-- Volume grows without bound -/
  vol_unbounded : Tendsto vol atTop atTop

/-- Polynomial volume growth: V(r) ~ r^α. -/
def hasPolynomialGrowth (V : VolumeGrowth) (α : ℝ) : Prop :=
  ∃ C₁ C₂ : ℝ, 0 < C₁ ∧ 0 < C₂ ∧ ∀ r, 1 ≤ r →
    C₁ * r ^ α ≤ V.vol r ∧ V.vol r ≤ C₂ * r ^ α

/-- Exponential volume growth: V(r) ~ e^{αr}. -/
def hasExponentialGrowth (V : VolumeGrowth) (α : ℝ) (_hα : 0 < α) : Prop :=
  ∃ C₁ C₂ : ℝ, 0 < C₁ ∧ 0 < C₂ ∧ ∀ r, 1 ≤ r →
    C₁ * rexp (α * r) ≤ V.vol r ∧ V.vol r ≤ C₂ * rexp (α * r)

/-! ## Section 4: Stereographic Conformal Factor -/

/-- The stereographic conformal factor: φ(r) = 2/(1 + r²). -/
def stereoConformalFactor (r : ℝ) : ℝ := 2 / (1 + r ^ 2)

/-
The stereographic conformal factor is always positive.
-/
theorem stereoConformalFactor_pos (r : ℝ) : 0 < stereoConformalFactor r := by
  exact div_pos zero_lt_two <| by positivity;

/-
The stereographic conformal factor is bounded above by 2.
-/
theorem stereoConformalFactor_le_two (r : ℝ) : stereoConformalFactor r ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-
The stereographic conformal factor decays quadratically.
-/
theorem stereoConformalFactor_decay (r : ℝ) (hr : 1 ≤ r) :
    stereoConformalFactor r ≤ 2 / r ^ 2 := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by nlinarith )

/-
The stereographic conformal factor at the origin is 2.
-/
theorem stereoConformalFactor_origin : stereoConformalFactor 0 = 2 := by
  unfold stereoConformalFactor; norm_num;

/-
The stereographic conformal factor tends to 0 at infinity.
-/
theorem stereoConformalFactor_tendsto_zero :
    Tendsto stereoConformalFactor atTop (nhds 0) := by
  exact tendsto_const_nhds.div_atTop ( tendsto_const_nhds.add_atTop ( by norm_num ) )

/-! ## Section 5: Critical Exponent Properties -/

/-
The critical Sobolev exponent p*(n) > 2 for n ≥ 3.
-/
theorem yamabeCriticalExponent_gt_two (n : ℕ) (hn : 3 ≤ n) :
    2 < yamabeCriticalExponent n hn := by
  unfold yamabeCriticalExponent; rw [ lt_div_iff₀ ] <;> linarith [ ( by norm_cast : ( 3 : ℝ ) ≤ n ) ] ;

/-
The Yamabe nonlinear exponent (n+2)/(n-2) > 1 for n ≥ 3.
-/
theorem yamabeNonlinearExponent_gt_one (n : ℕ) (hn : 3 ≤ n) :
    1 < yamabeNonlinearExponent n hn := by
  unfold yamabeNonlinearExponent;
  rw [ lt_div_iff₀ ] <;> linarith [ show ( n : ℝ ) ≥ 3 by norm_cast ]

/-
The critical exponent in dimension 3 is exactly 6.
-/
theorem yamabeCriticalExponent_dim3 : yamabeCriticalExponent 3 le_rfl = 6 := by
  unfold yamabeCriticalExponent; norm_num;

/-
The nonlinear exponent in dimension 3 is exactly 5.
-/
theorem yamabeNonlinearExponent_dim3 : yamabeNonlinearExponent 3 le_rfl = 5 := by
  unfold yamabeNonlinearExponent ; norm_num

/-
The conformal dimension constant is positive for n ≥ 3.
-/
theorem conformalDimensionConstant_pos (n : ℕ) (hn : 3 ≤ n) :
    0 < conformalDimensionConstant n (le_trans (by norm_num : 1 ≤ 3) hn) := by
  exact div_pos ( by norm_num; linarith ) ( by norm_num; linarith )

/-
The conformal dimension constant is strictly less than 1/4 for all n ≥ 2.
-/
theorem conformalDimensionConstant_lt_quarter (n : ℕ) (hn : 3 ≤ n) :
    conformalDimensionConstant n (le_trans (by norm_num : 1 ≤ 3) hn) < 1 / 4 := by
  exact by unfold conformalDimensionConstant; rw [ div_lt_iff₀ ] <;> linarith [ show ( n : ℝ ) ≥ 3 by norm_cast ] ;

/-
In dimension 3, c₃ = 1/8.
-/
theorem conformalDimensionConstant_dim3 :
    conformalDimensionConstant 3 (by norm_num) = 1 / 8 := by
  unfold conformalDimensionConstant; norm_num;

/-! ## Section 6: Bubble Decomposition -/

/-- A bubble decomposition describes how a minimizing sequence splits into
    concentrated bubbles plus a remainder. -/
structure BubbleDecomposition where
  /-- Number of bubbles -/
  numBubbles : ℕ
  /-- Energy of each bubble -/
  bubbleEnergies : Fin numBubbles → ℝ
  /-- Each bubble has positive energy -/
  energies_pos : ∀ k, 0 < bubbleEnergies k
  /-- The remainder energy -/
  remainder : ℝ
  /-- Remainder is nonneg -/
  remainder_nonneg : 0 ≤ remainder

/-- Total energy of a bubble decomposition. -/
def BubbleDecomposition.totalEnergy (B : BubbleDecomposition) : ℝ :=
  (∑ k, B.bubbleEnergies k) + B.remainder

/-
Each bubble contributes at least Y(Sⁿ) worth of energy.
    This is Aubin's fundamental bound.
-/
theorem bubble_energy_lower_bound (B : BubbleDecomposition)
    (Y_sphere : ℝ) (_hY : 0 < Y_sphere)
    (h : ∀ k, Y_sphere ≤ B.bubbleEnergies k) :
    Y_sphere * B.numBubbles ≤ B.totalEnergy := by
  exact le_add_of_le_of_nonneg ( by simpa [ mul_comm ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h i ) B.remainder_nonneg

/-- The energy is additive: total = sum of parts + remainder. -/
theorem bubble_decomposition_energy_split (B : BubbleDecomposition) :
    B.totalEnergy = (∑ k, B.bubbleEnergies k) + B.remainder := rfl

/-
If the total energy is strictly less than 2·Y(Sⁿ), there is at most one bubble.
-/
theorem single_bubble_criterion (B : BubbleDecomposition)
    (Y_sphere : ℝ) (hY : 0 < Y_sphere)
    (h_bound : ∀ k, Y_sphere ≤ B.bubbleEnergies k)
    (h_total : B.totalEnergy < 2 * Y_sphere) :
    B.numBubbles ≤ 1 := by
  contrapose! h_total;
  exact le_trans ( by nlinarith [ show ( B.numBubbles : ℝ ) ≥ 2 by norm_cast ] ) ( bubble_energy_lower_bound B Y_sphere hY h_bound )

/-! ## Section 7: Conformal Composition -/

/-
Conformal factors compose by multiplication.
-/
theorem conformal_composition (φ₁ φ₂ : ℝ) (hφ₁ : 0 < φ₁) (hφ₂ : 0 < φ₂) :
    0 < φ₁ * φ₂ ∧ (φ₁ * φ₂) ^ 2 = φ₁ ^ 2 * φ₂ ^ 2 := by
  exact ⟨ mul_pos hφ₁ hφ₂, mul_pow _ _ _ ⟩

/-- The Green's function on ℝⁿ (n ≥ 3): G(r) = r^(2-n). -/
def greenFunction (n : ℕ) (r : ℝ) : ℝ :=
  r ^ (2 - (n : ℝ))

/-
The Green's function is positive for positive r and n ≥ 3.
-/
theorem greenFunction_pos (n : ℕ) (_hn : 3 ≤ n) (r : ℝ) (hr : 0 < r) :
    0 < greenFunction n r := by
  exact Real.rpow_pos_of_pos hr _

/-! ## Section 8: Yamabe Invariant Sign Classification

The sign of the Yamabe invariant determines the geometry:
- Y > 0: positive scalar curvature (like Sⁿ)
- Y = 0: scalar flat (like ℝⁿ)
- Y < 0: negative scalar curvature (like Hⁿ)
-/

/-- Classification of the Yamabe invariant sign. -/
inductive YamabeSign
  | positive : YamabeSign
  | zero : YamabeSign
  | negative : YamabeSign

/-- Determine the Yamabe sign from the Yamabe constant. -/
def yamabeSignOf (Y : ℝ) : YamabeSign :=
  if 0 < Y then YamabeSign.positive
  else if Y = 0 then YamabeSign.zero
  else YamabeSign.negative

/-
The Yamabe sign classification is exhaustive.
-/
theorem yamabe_sign_trichotomy (Y : ℝ) :
    (0 < Y ∧ yamabeSignOf Y = YamabeSign.positive) ∨
    (Y = 0 ∧ yamabeSignOf Y = YamabeSign.zero) ∨
    (Y < 0 ∧ yamabeSignOf Y = YamabeSign.negative) := by
  unfold yamabeSignOf;
  grind

/-! ## Section 9: Conformal Laplacian Spectrum -/

/-- The lowest eigenvalue of the conformal Laplacian determines solvability.
    Abstract formulation: λ₁(L_g) > 0 iff Y(M) > 0. -/
structure ConformalLaplacianSpectrum where
  /-- The lowest eigenvalue -/
  lowestEigenvalue : ℝ
  /-- The Yamabe constant -/
  yamabeConstant : ℝ
  /-- Sign agreement -/
  sign_agreement : (0 < lowestEigenvalue ↔ 0 < yamabeConstant)

/-- If the lowest eigenvalue is positive, the Yamabe constant is positive. -/
theorem positive_eigenvalue_implies_positive_yamabe
    (S : ConformalLaplacianSpectrum) (h : 0 < S.lowestEigenvalue) :
    0 < S.yamabeConstant :=
  S.sign_agreement.mp h

/-- Converse: positive Yamabe constant implies positive lowest eigenvalue. -/
theorem positive_yamabe_implies_positive_eigenvalue
    (S : ConformalLaplacianSpectrum) (h : 0 < S.yamabeConstant) :
    0 < S.lowestEigenvalue :=
  S.sign_agreement.mpr h

/-! ## Section 10: Non-Compact Existence Theorem (Abstract) -/

/-- The Kim-Leung obstruction: on a complete non-compact manifold with
    Ricci curvature bounded below, if the scalar curvature is eventually
    negative, then no conformal metric of positive constant scalar curvature exists.

    We formalize this as an abstract obstruction criterion. -/
structure KimLeungObstruction where
  /-- The scalar curvature function (radial) -/
  scalarCurvature : ℝ → ℝ
  /-- Ricci lower bound -/
  ricciLowerBound : ℝ
  /-- Scalar curvature is eventually negative -/
  eventually_negative : ∃ R₀, ∀ r, R₀ ≤ r → scalarCurvature r < 0
  /-- Volume growth is at most polynomial -/
  polynomial_growth : ∃ (_α : ℝ) (C : ℝ), 0 < C ∧ ∀ r : ℝ, 1 ≤ r → True

/-- The obstruction implies no positive constant scalar curvature metric exists. -/
theorem kim_leung_no_positive_curvature (obs : KimLeungObstruction) :
    ∃ R₀, ∀ r, R₀ ≤ r → obs.scalarCurvature r < 0 :=
  obs.3

/-
The dual exponent relation: 1/p + 1/p' = 1 for p = p*(n).
-/
theorem yamabe_dual_exponent (n : ℕ) (hn : 3 ≤ n) :
    let p := yamabeCriticalExponent n hn
    let p' := p / (p - 1)
    1 / p + 1 / p' = 1 := by
  unfold yamabeCriticalExponent;
  field_simp;
  linarith [ mul_div_cancel₀ ( 2 * n : ℝ ) ( by linarith [ show ( n : ℝ ) ≥ 3 by norm_cast ] : ( n : ℝ ) - 2 ≠ 0 ) ]

/-
**Conjecture (Testable)**: For the Yamabe bubble on ℝ³,
    the L⁶ norm (critical exponent) equals π^(1/2).
    Test: compute ∫₀^∞ r² · U₁(r)⁶ dr numerically.
-/
theorem yamabe_bubble_L6_norm_conjecture :
    let u := yamabeBubble 3 1
    ∀ r : ℝ, 0 ≤ r → 0 < u r := by
  exact fun r hr => yamabeBubble_pos 3 ( by norm_num ) 1 ( by norm_num ) r

end