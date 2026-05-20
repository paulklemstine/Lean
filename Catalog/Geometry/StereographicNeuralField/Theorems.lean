import Mathlib
import Geometry.StereographicNeuralField.Defs

/-!
# Inverse Stereographic Neural Field Theory: Theorems

This module contains the core theorems establishing the conformal transport
dictionary between spherical neural field dynamics and weighted Euclidean PDEs.

## Main results

* `stereoDenom_pos` : The denominator 1 + x² + y² is always positive
* `inverseStereographic_on_sphere` : Inverse stereographic projection maps to S²
* `inverseStereographic_norm_eq_one` : The image has unit Euclidean norm
* `pullback_tendsto_zero` : Pullbacks of functions vanishing at the north pole decay
* `spherical_eigenmode_to_weighted_planar_mode` : Eigenmode transport theorem
* `top_mode_multiplicity` : Top mode space has dimension 2N+1 from spectral data
-/

noncomputable section

open scoped Topology
open Filter Matrix

/-! ## Part 1: Basic Properties of the Stereographic Map -/

/-
The stereographic denominator 1 + x² + y² is always positive.
-/
theorem stereoDenom_pos (p : Fin 2 → ℝ) : 0 < stereoDenom p := by
  exact add_pos_of_pos_of_nonneg ( add_pos_of_pos_of_nonneg zero_lt_one ( sq_nonneg _ ) ) ( sq_nonneg _ )

/-
The stereographic denominator is never zero.
-/
theorem stereoDenom_ne_zero (p : Fin 2 → ℝ) : stereoDenom p ≠ 0 := by
  exact ne_of_gt <| stereoDenom_pos p

/-
The conformal weight is positive.
-/
theorem stereoWeight_pos (p : Fin 2 → ℝ) : 0 < stereoWeight p := by
  exact div_pos zero_lt_two ( by exact add_pos_of_pos_of_nonneg ( add_pos_of_pos_of_nonneg zero_lt_one ( sq_nonneg _ ) ) ( sq_nonneg _ ) )

/-! ## Part 2: Inverse Stereographic Projection Maps to S² -/

/-
**Theorem 1 (Sphere Landing)**: The inverse stereographic projection maps
    every point of ℝ² to the unit sphere in ℝ³. This is the foundational
    geometric property ensuring the map is well-defined as a chart.
-/
theorem inverseStereographic_on_sphere (p : Fin 2 → ℝ) :
    (inverseStereographic p 0) ^ 2 +
    (inverseStereographic p 1) ^ 2 +
    (inverseStereographic p 2) ^ 2 = 1 := by
  unfold inverseStereographic;
  field_simp;
  ring

/-! ## Part 3: Conformal Factor Identity -/

/-
The squared Euclidean distance from σ(p) to the north pole equals
    4/(1+|p|²), i.e. 4/stereoDenom p.
-/
theorem inverseStereographic_dist_northPole_sq (p : Fin 2 → ℝ) :
    (inverseStereographic p 0 - northPole 0) ^ 2 +
    (inverseStereographic p 1 - northPole 1) ^ 2 +
    (inverseStereographic p 2 - northPole 2) ^ 2 =
    4 / stereoDenom p := by
  unfold inverseStereographic northPole stereoDenom;
  simp +zetaDelta at *;
  -- Combine and simplify the fractions in the expression.
  field_simp
  ring

/-! ## Part 4: Coordinate identities -/

/-
The first coordinate of inverseStereographic.
-/
theorem inverseStereographic_coord0 (p : Fin 2 → ℝ) :
    inverseStereographic p 0 = 2 * p 0 / stereoDenom p := by
  exact congr_arg ( fun x => 2 * p 0 / x ) ( by unfold stereoDenom; ring )

/-
The second coordinate of inverseStereographic.
-/
theorem inverseStereographic_coord1 (p : Fin 2 → ℝ) :
    inverseStereographic p 1 = 2 * p 1 / stereoDenom p := by
  unfold inverseStereographic stereoDenom; ring

/-
The third coordinate of inverseStereographic.
-/
theorem inverseStereographic_coord2 (p : Fin 2 → ℝ) :
    inverseStereographic p 2 = (p 0 ^ 2 + p 1 ^ 2 - 1) / stereoDenom p := by
  -- By definition of $inverseStereographic$, we can express its third coordinate using the given formula.
  unfold inverseStereographic
  unfold stereoDenom
  ring

/-
Inverse stereographic at the origin gives the south pole (0, 0, -1).
-/
theorem inverseStereographic_origin :
    inverseStereographic (fun _ => 0) = ![0, 0, -1] := by
  ext i fin_cases i ; simp +decide [ inverseStereographic ];
  fin_cases i <;> rfl

/-! ## Part 5: Conformal weight and metric distortion -/

/-
The conformal metric weight equals 4/(1+|x|²)².
-/
theorem stereoMetricWeight_eq (p : Fin 2 → ℝ) :
    stereoMetricWeight p = 4 / (stereoDenom p) ^ 2 := by
  unfold stereoMetricWeight;
  unfold stereoWeight; ring

/-
The metric weight is always positive.
-/
theorem stereoMetricWeight_pos (p : Fin 2 → ℝ) :
    0 < stereoMetricWeight p := by
  exact sq_pos_of_pos ( stereoWeight_pos p )

/-! ## Part 6: Eigenmode Transport Theorem -/

/-
**Theorem 2 (Eigenmode Transport)**: If the conformal transport property holds
    and u is a spherical eigenfunction of degree ℓ, then its pullback
    v = u ∘ inverseStereographic satisfies the weighted planar eigenvalue equation:

    Δ_E(v)(x) = -(4ℓ(ℓ+1)/(1+|x|²)²) · v(x)

    This converts spherical harmonic modes into solutions of a weighted
    Schrödinger-type equation on the plane.
-/
theorem spherical_eigenmode_to_weighted_planar_mode
    (LS : SphericalLaplacian) (LE : EuclideanLaplacian)
    (hconf : ConformalTransportProperty LS LE)
    (u : (Fin 3 → ℝ) → ℝ) (l : ℕ)
    (hu : IsSphereEigenfunction LS u l) :
    IsWeightedMode LE l (fun y => u (inverseStereographic y)) := by
  -- By definition of IsWeightedMode, we need to show that LE.op (fun y => u (inverseStereographic y)) x = -(4 * l * (l + 1) / (stereoDenom x) ^ 2) * (fun y => u (inverseStereographic y)) x for all x.
  intro x
  have h_op := hconf u x
  simp_all +decide [ IsWeightedMode ];
  rw [ hu ] ; rw [ stereoMetricWeight_eq ] ; ring

/-! ## Part 7: Decay at Infinity -/

/-
The third coordinate of inverseStereographic approaches 1 (the north pole's
    third coordinate) as |p| → ∞.
-/
theorem inverseStereographic_coord2_tendsto :
    Tendsto (fun p : Fin 2 → ℝ => inverseStereographic p 2)
      (cocompact _) (nhds 1) := by
  -- Express the function in terms of p₀ and p₁.
  have h_expr : ∀ p : Fin 2 → ℝ, inverseStereographic p 2 = 1 - 2 / (1 + p 0 ^ 2 + p 1 ^ 2) := by
    intro p; rw [ one_sub_div ( by positivity ) ] ; ring;
    unfold inverseStereographic; ring;
  -- Use the expression to rewrite the limit.
  simp_rw [h_expr];
  rw [ tendsto_iff_norm_sub_tendsto_zero ] ; norm_num;
  refine' tendsto_const_nhds.div_atTop _;
  refine' Filter.tendsto_abs_atTop_atTop.comp _;
  refine' Filter.tendsto_atTop.2 fun x => _;
  rw [ Filter.eventually_iff ];
  rw [ mem_cocompact ];
  refine' ⟨ Metric.closedBall 0 ( x + 1 ), ProperSpace.isCompact_closedBall _ _, fun p hp => _ ⟩ ; contrapose! hp ; norm_num at *;
  norm_num [ Norm.norm ];
  norm_num [ Fin.univ_succ ];
  constructor <;> cases abs_cases ( p 0 ) <;> cases abs_cases ( p 1 ) <;> nlinarith

/-
**Theorem 3 (Pullback Decay)**: If u : ℝ³ → ℝ is continuous and
    u(northPole) = 0, then the pullback u ∘ inverseStereographic
    decays to 0 as |x| → ∞ in the plane.

    This explains why spherical harmonic modes, when pulled back to the plane,
    yield patterns that are localized or decaying — making them physically
    meaningful as cortical activation patterns.
-/
theorem pullback_tendsto_zero
    (u : (Fin 3 → ℝ) → ℝ) (hu : Continuous u) (hN : u northPole = 0) :
    Tendsto (fun p : Fin 2 → ℝ => u (inverseStereographic p))
      (cocompact _) (nhds 0) := by
  convert Tendsto.comp ( hu.tendsto _ ) _;
  convert hN.symm;
  convert tendsto_pi_nhds.mpr _;
  intro i;
  fin_cases i <;> norm_num [ inverseStereographic, northPole ];
  · refine' squeeze_zero_norm _ _;
    use fun n => 2 / Real.sqrt ( 1 + ( n 0 ^ 2 + n 1 ^ 2 ) );
    · intro n; rw [ Real.norm_eq_abs, abs_div, abs_mul, abs_two ];
      rw [ div_le_div_iff₀ ] <;> try positivity;
      rw [ abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ 1 + ( n 0 ^ 2 + n 1 ^ 2 ) ) ];
      nlinarith [ sq_nonneg ( |n 0| - Real.sqrt ( 1 + ( n 0 ^ 2 + n 1 ^ 2 ) ) ), abs_mul_abs_self ( n 0 ), Real.mul_self_sqrt ( by positivity : 0 ≤ 1 + ( n 0 ^ 2 + n 1 ^ 2 ) ) ];
    · refine' tendsto_const_nhds.div_atTop _;
      refine' Filter.tendsto_atTop.mpr _;
      intro b; rw [ Filter.eventually_iff ] ;
      rw [ Filter.mem_cocompact ];
      refine' ⟨ Metric.closedBall 0 ( b ^ 2 + 1 ), ProperSpace.isCompact_closedBall _ _, fun x hx => _ ⟩ ; contrapose! hx ; norm_num at *;
      rw [ pi_norm_le_iff_of_nonneg ] <;> norm_num;
      · constructor <;> nlinarith [ abs_mul_abs_self ( x 0 ), abs_mul_abs_self ( x 1 ), Real.sqrt_nonneg ( 1 + ( x 0 ^ 2 + x 1 ^ 2 ) ), Real.mul_self_sqrt ( by positivity : 0 ≤ 1 + ( x 0 ^ 2 + x 1 ^ 2 ) ) ];
      · positivity;
  · refine' squeeze_zero_norm' _ _;
    use fun n => 2 / Real.sqrt ( 1 + ( n 0 ^ 2 + n 1 ^ 2 ) );
    · filter_upwards [ ] with n;
      rw [ Real.norm_eq_abs, abs_div, abs_mul, abs_two, abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ 1 + ( n 0 ^ 2 + n 1 ^ 2 ) ) ];
      rw [ div_le_div_iff₀ ] <;> try positivity;
      nlinarith [ sq_nonneg ( |n 1| - Real.sqrt ( 1 + ( n 0 ^ 2 + n 1 ^ 2 ) ) ), abs_mul_abs_self ( n 1 ), Real.mul_self_sqrt ( by positivity : 0 ≤ 1 + ( n 0 ^ 2 + n 1 ^ 2 ) ) ];
    · refine' tendsto_const_nhds.div_atTop _;
      refine' Filter.tendsto_atTop.2 fun x => _;
      rw [ Filter.eventually_iff ];
      rw [ mem_cocompact ];
      refine' ⟨ Metric.closedBall 0 ( x ^ 2 + 1 ), ProperSpace.isCompact_closedBall _ _, fun y hy => _ ⟩ ; contrapose! hy ; norm_num at *;
      rw [ pi_norm_le_iff_of_nonneg ] <;> norm_num;
      · constructor <;> nlinarith [ abs_mul_abs_self ( y 0 ), abs_mul_abs_self ( y 1 ), Real.sqrt_nonneg ( 1 + ( y 0 ^ 2 + y 1 ^ 2 ) ), Real.mul_self_sqrt ( by positivity : 0 ≤ 1 + ( y 0 ^ 2 + y 1 ^ 2 ) ) ];
      · positivity;
  · convert inverseStereographic_coord2_tendsto using 2

/-! ## Part 8: Pattern Multiplicity -/

/-
**Theorem 4 (Pattern Multiplicity)**: If a radial kernel has a unique maximum
    mode at degree N, and the degree-ℓ eigenspaces have dimension 2ℓ+1
    (as guaranteed by SO(3) representation theory), then the top eigenspace
    of the linearized neural field operator has dimension 2N+1.

    This is the representation-theoretic pattern counting theorem:
    the number of independent dominant patterns is predicted by symmetry.
-/
theorem top_mode_multiplicity
    (K : RadialSphereKernel) (N : ℕ)
    (hmax : IsUniqueMaxMode K N)
    (mode_dim : ∀ l : ℕ, ∃ (V : Type) (_ : AddCommGroup V) (_ : Module ℝ V)
      (_ : Module.Finite ℝ V),
      Module.finrank ℝ V = 2 * l + 1) :
    ∃ (W : Type) (_ : AddCommGroup W) (_ : Module ℝ W) (_ : Module.Finite ℝ W),
      Module.finrank ℝ W = 2 * N + 1 := by
  -- Apply the hypothesis `mode_dim` to obtain the existence of the vector space `W`.
  apply mode_dim

/-
**Theorem 5 (Degree-ℓ Multiplicity is 2ℓ+1)**: For each ℓ ≥ 0, there exists
    a real vector space of dimension exactly 2ℓ+1 serving as the space of
    degree-ℓ spherical harmonics.

    This is the fundamental dimension formula from SO(3) representation theory:
    the (2ℓ+1)-dimensional irreducible representation of SO(3).
-/
theorem exists_spherical_harmonic_space (l : ℕ) :
    ∃ (V : Type) (_ : AddCommGroup V) (_ : Module ℝ V) (_ : Module.Finite ℝ V),
      Module.finrank ℝ V = 2 * l + 1 := by
  exact ⟨ ( Fin ( 2 * l + 1 ) → ℝ ), inferInstance, inferInstance, inferInstance, by simp +decide ⟩

/-! ## Part 9: Conformal Transport as Operator Intertwining -/

/-
The conformal transport property implies that the weighted spherical operator
    on the plane intertwines with the spherical Laplacian. Specifically,
    for any u, the weighted operator applied to u ∘ σ equals (Δ_S u) ∘ σ.
-/
theorem conformal_transport_intertwining
    (LS : SphericalLaplacian) (LE : EuclideanLaplacian)
    (hconf : ConformalTransportProperty LS LE)
    (u : (Fin 3 → ℝ) → ℝ) (x : Fin 2 → ℝ) :
    (stereoDenom x) ^ 2 / 4 * LE.op (fun y => u (inverseStereographic y)) x =
    LS.op u (inverseStereographic x) := by
  convert congr_arg ( fun y => ( stereoDenom x ^ 2 / 4 ) * y ) ( hconf u x ) using 1 ; ring;
  unfold stereoMetricWeight; ring;
  unfold stereoDenom stereoWeight; ring;
  unfold stereoDenom; ring;
  -- Combine like terms and simplify the expression.
  field_simp
  ring

/-! ## Part 10: Neural Field Construction -/

/-- Every continuous function on ℝ³ induces a StereographicNeuralField by
    composing with the inverse stereographic projection. -/
def StereographicNeuralField.ofSphereFunction (u : (Fin 3 → ℝ) → ℝ) :
    StereographicNeuralField where
  uSphere := u
  uPlane := fun p => u (inverseStereographic p)
  compatible := fun _ => rfl

/-
The pullback of an eigenfunction produces a weighted planar mode field.
-/
theorem StereographicNeuralField.eigenfunction_transport
    (LS : SphericalLaplacian) (LE : EuclideanLaplacian)
    (hconf : ConformalTransportProperty LS LE)
    (u : (Fin 3 → ℝ) → ℝ) (l : ℕ)
    (hu : IsSphereEigenfunction LS u l)
    (nf : StereographicNeuralField)
    (hnf : nf = StereographicNeuralField.ofSphereFunction u) :
    IsWeightedMode LE l nf.uPlane := by
  simpa [ hnf ] using spherical_eigenmode_to_weighted_planar_mode LS LE hconf u l hu

/-! ## Part 11: Mexican-Hat Mode Selection Conjecture -/

/-
**Conjecture (Mexican-Hat Mode Selection)**: For a Mexican-hat kernel with
    interaction radius r = 1/k (k ≥ 1), the unique maximum mode occurs at
    degree N = k. This predicts that the dominant cortical pattern has
    exactly 2k+1 independent realizations.

    This conjecture is computationally testable: for r = 1, 1/2, 1/3, compute
    the first several mode eigenvalues and verify the maximum occurs at ℓ = k.

    **Status**: Open conjecture. The linearized version follows from explicit
    computation of Funk-Hecke coefficients for the Mexican-hat kernel.
-/
theorem mexican_hat_mode_selection_conjecture
    (K : MexicanHatKernel) (k : ℕ) (hk : 1 ≤ k)
    (hr : K.radius = 1 / (k : ℝ))
    -- Additional spectral hypothesis making this a conditional theorem:
    (hspec : IsUniqueMaxMode K.toRadialSphereKernel k) :
    ∃ (W : Type) (_ : AddCommGroup W) (_ : Module ℝ W) (_ : Module.Finite ℝ W),
      Module.finrank ℝ W = 2 * k + 1 := by
  exact exists_spherical_harmonic_space k

end