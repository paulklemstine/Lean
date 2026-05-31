/-
  # Inverse Stereographic Neural Field Theory

  Neural field equations model macroscopic brain dynamics as PDEs on cortical surfaces.
  The cortical surface is topologically a sphere. Using inverse stereographic projection,
  we transform neural field PDEs on S^n into PDEs on R^n with conformal weights.

  Key results:
  - The conformal factor of stereographic projection σ(x) = 2/(1 + |x|²)
  - Spherical harmonic eigenvalues: λ_l = l(l + n - 1) on S^n
  - Dimension of spherical harmonic spaces on S^2: dim H_l = 2l + 1
  - Pattern counting via representation theory of SO(3)
  - Conformal decay estimates for projected patterns
-/
import Mathlib

open Real Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- The conformal factor of stereographic projection from S^n to R^n.
    At a point with squared norm r², σ(r²) = 2 / (1 + r²). -/
def conformalFactor (r_sq : ℝ) : ℝ := 2 / (1 + r_sq)

/-- The eigenvalue of the Laplace-Beltrami operator on S^n for spherical harmonics
    of degree l. On S^n, Δ_{S^n} Y_l = -l(l + n - 1) Y_l. We store the positive part. -/
def sphericalEigenvalue (n l : ℕ) : ℕ := l * (l + n - 1)

/-- The dimension of the space of spherical harmonics of degree l on S^n.
    For S^2 (n=2), this is 2l+1. For general n, it is C(l+n-1, n-1) - C(l+n-2, n-1).
    We define the general formula. -/
def sphericalHarmonicDim (n l : ℕ) : ℕ :=
  if n = 0 then (if l = 0 then 1 else 0)
  else Nat.choose (n + l) n - Nat.choose (n + l - 2) n

/-- A stereographic neural field configuration on S^n. Contains the spatial dimension,
    the selected spherical harmonic degree (interaction mode), and the interaction radius. -/
structure NeuralFieldConfig where
  /-- Spatial dimension of the sphere (S^n has dimension n) -/
  spatialDim : ℕ
  /-- The spherical harmonic degree selected by the Mexican-hat kernel -/
  selectedDegree : ℕ
  /-- Interaction radius parameter -/
  interactionRadius : ℝ
  /-- The interaction radius is positive -/
  radius_pos : 0 < interactionRadius
  /-- Degree is positive for non-trivial patterns -/
  degree_pos : 0 < selectedDegree

/-- The conformal weight function for the neural field Laplacian transformation.
    Under stereographic projection, the Laplacian picks up a factor σ^{n+2}.
    This is the exponent for the conformal weight in dimension n. -/
def conformalLaplacianExponent (n : ℕ) : ℕ := n + 2

/-- The number of independent pattern solutions for a given spherical harmonic degree l
    on S^2. This equals 2l + 1 from SO(3) representation theory. -/
def patternCount (l : ℕ) : ℕ := 2 * l + 1

/-- The Mexican-hat kernel selects spherical harmonic degree l = floor(1/r)
    for interaction radius r. This gives the predicted number of patterns. -/
def mexicanHatPatternCount (r : ℝ) (_hr : 0 < r) : ℕ :=
  patternCount ⌊1 / r⌋₊

/-! ## Properties of the Conformal Factor -/

/-
The conformal factor is always positive for non-negative squared radius.
-/
theorem conformalFactor_pos (r_sq : ℝ) (hr : 0 ≤ r_sq) : 0 < conformalFactor r_sq := by
  exact div_pos zero_lt_two ( by linarith )

/-
The conformal factor is bounded above by 2.
-/
theorem conformalFactor_le_two (r_sq : ℝ) (hr : 0 ≤ r_sq) : conformalFactor r_sq ≤ 2 := by
  exact div_le_self zero_le_two ( by linarith )

/-
The conformal factor at the origin equals 2 (corresponding to the "north pole"
    of the sphere).
-/
theorem conformalFactor_at_origin : conformalFactor 0 = 2 := by
  norm_num [ conformalFactor ]

/-
The conformal factor decays to 0 as r² → ∞. More precisely,
    σ(r²) ≤ 2/r² for r² ≥ 1. This is the key decay estimate.
-/
theorem conformalFactor_decay (r_sq : ℝ) (hr : 1 ≤ r_sq) :
    conformalFactor r_sq ≤ 2 / r_sq := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by linarith )

/-
The conformal factor is monotonically decreasing: if a ≤ b then σ(b) ≤ σ(a).
-/
theorem conformalFactor_antitone (a b : ℝ) (ha : 0 ≤ a) (hab : a ≤ b) :
    conformalFactor b ≤ conformalFactor a := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by linarith )

/-! ## Spherical Harmonic Dimension Theory -/

/-
On S², the dimension of spherical harmonics of degree `l` is exactly `2l + 1`.
    This is the fundamental result from SO(3) representation theory.
-/
theorem sphericalHarmonicDim_S2 (l : ℕ) : sphericalHarmonicDim 2 l = 2 * l + 1 := by
  unfold sphericalHarmonicDim; simp +arith +decide [ Nat.choose_succ_succ ];
  exact Nat.sub_eq_of_eq_add <| by ring;

/-
The total number of spherical harmonics up to degree `L` on S² is `(L+1)²`.
-/
theorem total_harmonics_S2 (L : ℕ) :
    (∑ l ∈ range (L + 1), sphericalHarmonicDim 2 l) = (L + 1) ^ 2 := by
  rw [ Finset.sum_congr rfl fun i hi => by rw [ sphericalHarmonicDim_S2 ] ];
  exact Nat.recOn L ( by norm_num ) fun n ih => by rw [ Finset.sum_range_succ ] ; linarith;

/-! ## Pattern Count Theorems -/

/-
The pattern count is always odd (since 2l+1 is odd).
-/
theorem patternCount_odd (l : ℕ) : ¬ 2 ∣ patternCount l := by
  unfold patternCount; norm_num [ ← even_iff_two_dvd, parity_simps ] ;

/-
The pattern count is at least 3 for non-zero degree.
-/
theorem patternCount_ge_three (l : ℕ) (hl : 0 < l) : 3 ≤ patternCount l := by
  grind +locals

/-- The pattern count grows linearly with degree. -/
theorem patternCount_eq (l : ℕ) : patternCount l = 2 * l + 1 := rfl

/-
For interaction radius `r = 1/k` (`k ≥ 1`), the Mexican-hat kernel selects
    degree `k`, giving exactly `2k + 1` patterns.
-/
theorem mexicanHat_reciprocal (k : ℕ) (hk : 0 < k) :
    mexicanHatPatternCount (1 / (k : ℝ)) (by positivity) = 2 * k + 1 := by
  convert patternCount_eq k using 1;
  unfold mexicanHatPatternCount; norm_num [ hk ] ;

/-! ## Eigenvalue Properties -/

/-
The spherical eigenvalue on S^2 for degree l is l(l+1).
-/
theorem sphericalEigenvalue_S2 (l : ℕ) : sphericalEigenvalue 2 l = l * (l + 1) := by
  unfold sphericalEigenvalue; norm_num;

/-
Eigenvalues are strictly increasing in degree on S^2.
-/
theorem sphericalEigenvalue_S2_strictMono :
    StrictMono (fun l => sphericalEigenvalue 2 l) := by
  unfold sphericalEigenvalue;
  exact fun a b hab => by norm_num; nlinarith;

/-
The eigenvalue gap between consecutive degrees on S^2 is 2(l+1).
-/
theorem eigenvalue_gap_S2 (l : ℕ) :
    sphericalEigenvalue 2 (l + 1) - sphericalEigenvalue 2 l = 2 * (l + 1) := by
  unfold sphericalEigenvalue; norm_num; ring;
  exact Nat.sub_eq_of_eq_add <| by ring;

/-! ## Conformal Laplacian Transformation -/

/-
The conformal Laplacian exponent for dimension 2 is 4.
    The Laplacian on S² picks up a factor `σ^4` under stereographic projection.
-/
theorem conformalLaplacianExponent_dim2 : conformalLaplacianExponent 2 = 4 := by
  rfl

/-
Key identity: the conformal factor satisfies `σ(r²)² = 4/(1+r²)²`.
    This is used for energy estimates of the transformed neural field.
-/
theorem conformalFactor_sq (r_sq : ℝ) (_hr : 0 ≤ r_sq) :
    conformalFactor r_sq ^ 2 = 4 / (1 + r_sq) ^ 2 := by
  unfold conformalFactor; rw [ div_pow ] ; ring;

/-! ## Decay Estimates for Projected Patterns -/

/-
A spherical harmonic of degree `l`, projected via stereographic projection,
    decays as `|x|^(-2l)` at infinity. The conformal weight contributes this decay.
    We state this as: `σ(r²)^l ≤ 2^l / r^(2l)` for `r² ≥ 1`.
-/
theorem projected_pattern_decay (l : ℕ) (r_sq : ℝ) (hr : 1 ≤ r_sq) :
    conformalFactor r_sq ^ l ≤ 2 ^ l / r_sq ^ l := by
  rw [ ← div_pow ];
  exact pow_le_pow_left₀ ( by exact div_nonneg zero_le_two ( by positivity ) ) ( by rw [ conformalFactor ] ; rw [ div_le_div_iff₀ ] <;> nlinarith ) _

/-! ## Sum Formula and Gauss's Identity -/

/-
Gauss's sum formula: the sum of the first `n` odd numbers equals `n²`.
    This is the algebraic backbone of the pattern counting argument.
-/
theorem gauss_odd_sum (n : ℕ) : (∑ i ∈ range n, (2 * i + 1)) = n ^ 2 := by
  induction n <;> simpa [ Finset.sum_range_succ ] using by linarith;

/-! ## Neural Field Energy Functional -/

/-- The energy of a spherical harmonic mode of degree l with amplitude a on S^2.
    E_l(a) = λ_l · a² · dim(H_l) = l(l+1) · a² · (2l+1).
    We define the normalized energy per mode. -/
def modeEnergy (l : ℕ) (a : ℝ) : ℝ :=
  (sphericalEigenvalue 2 l : ℝ) * a ^ 2 * (sphericalHarmonicDim 2 l : ℝ)

/-
The mode energy is non-negative.
-/
theorem modeEnergy_nonneg (l : ℕ) (a : ℝ) : 0 ≤ modeEnergy l a := by
  exact mul_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( sq_nonneg _ ) ) ( Nat.cast_nonneg _ )

/-
The mode energy at zero amplitude is zero.
-/
theorem modeEnergy_zero (l : ℕ) : modeEnergy l 0 = 0 := by
  unfold modeEnergy; ring

/-
The mode energy scales quadratically in amplitude.
-/
theorem modeEnergy_scale (l : ℕ) (a c : ℝ) :
    modeEnergy l (c * a) = c ^ 2 * modeEnergy l a := by
  unfold modeEnergy; ring;

/-! ## Conjecture: Mexican-Hat Pattern Count -/

/-
**Conjecture** (Mexican-Hat Pattern Count):
    For the neural field equation on S^2 with Mexican-hat connectivity kernel
    of interaction radius r = 1/k (k ≥ 1), the number of linearly independent
    stable pattern solutions is exactly 2k + 1.

    This is testable: for k=1, there should be 3 patterns (the l=1 spherical harmonics
    Y_{1,-1}, Y_{1,0}, Y_{1,1}); for k=2, there should be 5 patterns, etc.

    The conjecture follows from:
    1. The Mexican-hat kernel selects the spherical harmonic degree l = k = floor(1/r)
    2. The space of degree-l spherical harmonics on S^2 has dimension 2l+1
    3. All 2l+1 modes have the same eigenvalue and are equally stable

    Computational test: verify that `patternCount k = 2*k + 1` for `k = 1, ..., 100`.
    This is trivially true by definition, but the non-trivial content is that
    `sphericalHarmonicDim 2 k = patternCount k`, which we prove above.
-/
theorem mexican_hat_conjecture (k : ℕ) (_hk : 0 < k) :
    sphericalHarmonicDim 2 k = patternCount k := by
  exact sphericalHarmonicDim_S2 k

end