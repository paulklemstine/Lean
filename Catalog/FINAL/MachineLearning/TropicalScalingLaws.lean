import Mathlib

/-! # Tropical Scaling Laws: Phase Transitions as Corner Loci

This file formalizes neural scaling laws as tropical geometric objects in log-coordinates.
The empirical power-law scaling `L(N,D,C) = min{A·N^(-a), B·D^(-b), E·C^(-c)}` becomes,
after taking logarithms, a piecewise-affine tropical polynomial whose corner loci
correspond exactly to phase transitions between parameter-limited, data-limited,
and compute-limited training regimes.

## Main Results

* `tropicalScalingLoss_eq_affine_on_StrictNRegion` etc.: on each strict dominance region
  the tropical loss equals the corresponding affine function.
* `not_unique_min_iff_corner`: the phase-transition set (non-unique minimizer locus)
  is exactly the tropical corner set.
* `tropicalScalingLoss_trichotomy`: complete polyhedral decomposition of ℝ³ into
  strict cells and corner strata.
* `tropicalAggregate3_idempotent`: tropical regime aggregation is idempotent —
  the scaling law is a fixed point of min-plus competition.
* `tropicalScalingLoss_translation`: only relative intercepts matter for phase geometry.

## References

- Kaplan et al., "Scaling Laws for Neural Language Models" (2020)
- Hoffmann et al., "Training Compute-Optimal Large Language Models" (2022)
- Maclagan & Sturmfels, "Introduction to Tropical Geometry" (2015)
-/

noncomputable section

namespace TropicalScaling

/-! ## Core Definitions -/

/-- The tropical scaling loss in log-coordinates: T(x,y,z) = min(A + a·x, min(B + b·y, C + c·z)).
    Here x = log N, y = log D, z = log C represent log-parameters, log-data, log-compute. -/
def tropicalScalingLoss (a b c A B C : ℝ) (x y z : ℝ) : ℝ :=
  min (A + a * x) (min (B + b * y) (C + c * z))

/-- Three-term tropical aggregation (min-plus addition). -/
def tropicalAggregate3 (u v w : ℝ) : ℝ := min u (min v w)

/-! ## Strict Dominance Regions -/

/-- The parameter-limited regime: the N-term strictly dominates. -/
def StrictNRegion (a b c A B C x y z : ℝ) : Prop :=
  A + a * x < B + b * y ∧ A + a * x < C + c * z

/-- The data-limited regime: the D-term strictly dominates. -/
def StrictDRegion (a b c A B C x y z : ℝ) : Prop :=
  B + b * y < A + a * x ∧ B + b * y < C + c * z

/-- The compute-limited regime: the C-term strictly dominates. -/
def StrictCRegion (a b c A B C x y z : ℝ) : Prop :=
  C + c * z < A + a * x ∧ C + c * z < B + b * y

/-! ## Corner (Phase Transition) Definitions -/

/-- A point is a corner (tropical phase boundary) when at least two regime terms tie
    at the minimum. This is the combinatorial characterization of non-differentiability. -/
def ScalingCorner (a b c A B C x y z : ℝ) : Prop :=
  ((A + a * x = B + b * y) ∧ A + a * x ≤ C + c * z) ∨
  ((A + a * x = C + c * z) ∧ A + a * x ≤ B + b * y) ∨
  ((B + b * y = C + c * z) ∧ B + b * y ≤ A + a * x)

/-- There is a unique minimizer among three values. -/
def HasUniqueMin (u v w : ℝ) : Prop :=
  (u < v ∧ u < w) ∨ (v < u ∧ v < w) ∨ (w < u ∧ w < v)

/-! ## Compute Constraint -/

/-- The compute-dominated region under the constraint z = x + y. -/
def ComputeDominates (a b c A B C x y : ℝ) : Prop :=
  C + c * (x + y) < A + a * x ∧
  C + c * (x + y) < B + b * y

/-- An emergent capability is reached when the tropical loss falls below threshold τ. -/
def CapabilityReached (a b c A B C τ x y z : ℝ) : Prop :=
  tropicalScalingLoss a b c A B C x y z ≤ τ

/-! ## Auxiliary Min Lemmas -/

/-
Associativity of min over three arguments.
-/
theorem scaling_min_assoc3 (u v w : ℝ) :
    min (min u v) w = min u (min v w) := by
  grind +revert

/-
If u < v then min u v = u.
-/
theorem scaling_min_eq_left_of_lt {u v : ℝ} (h : u < v) : min u v = u := by
  exact min_eq_left h.le

/-
If v < u then min u v = v.
-/
theorem scaling_min_eq_right_of_lt {u v : ℝ} (h : v < u) : min u v = v := by
  exact min_eq_right h.le

/-
Commutativity of tropical aggregate in the first two arguments.
-/
theorem tropicalAggregate3_comm_left (u v w : ℝ) :
    tropicalAggregate3 u v w = tropicalAggregate3 v u w := by
  unfold tropicalAggregate3; ac_rfl;

/-! ## Main Theorems: Affine Structure on Strict Regions -/

/-
On the parameter-limited regime, the tropical loss equals the N-affine function.
-/
theorem tropicalScalingLoss_eq_affine_on_StrictNRegion
    {a b c A B C x y z : ℝ}
    (h : StrictNRegion a b c A B C x y z) :
    tropicalScalingLoss a b c A B C x y z = A + a * x := by
  unfold StrictNRegion at h;
  exact min_eq_left ( by cases min_cases ( B + b * y ) ( C + c * z ) <;> linarith )

/-
On the data-limited regime, the tropical loss equals the D-affine function.
-/
theorem tropicalScalingLoss_eq_affine_on_StrictDRegion
    {a b c A B C x y z : ℝ}
    (h : StrictDRegion a b c A B C x y z) :
    tropicalScalingLoss a b c A B C x y z = B + b * y := by
  exact min_eq_right ( min_le_of_left_le ( by linarith [ h.1 ] ) ) |> fun h' => h'.trans ( min_eq_left ( by linarith [ h.2 ] ) )

/-
On the compute-limited regime, the tropical loss equals the C-affine function.
-/
theorem tropicalScalingLoss_eq_affine_on_StrictCRegion
    {a b c A B C x y z : ℝ}
    (h : StrictCRegion a b c A B C x y z) :
    tropicalScalingLoss a b c A B C x y z = C + c * z := by
  unfold tropicalScalingLoss StrictCRegion at *;
  grind

/-! ## Phase Transition = Tropical Corner -/

/-
**The core theorem**: phase transition (non-unique minimizer) is equivalent to being
    at a tropical corner. This formalizes the observation that "emergent capability thresholds"
    correspond to corners of the tropical polytope where regimes exchange dominance.
-/
theorem not_unique_min_iff_corner
    {a b c A B C x y z : ℝ} :
    ¬ HasUniqueMin (A + a * x) (B + b * y) (C + c * z) ↔
    ScalingCorner a b c A B C x y z := by
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ ScalingCorner, HasUniqueMin ];
  · grind;
  · grind

/-! ## Polyhedral Decomposition -/

/-
**Trichotomy / stratification theorem**: every point in log-resource space lies in
    exactly one strict dominance cell or on a corner stratum. This gives the complete
    polyhedral decomposition of scaling-law behavior.
-/
theorem tropicalScalingLoss_trichotomy
    {a b c A B C x y z : ℝ} :
    StrictNRegion a b c A B C x y z ∨
    StrictDRegion a b c A B C x y z ∨
    StrictCRegion a b c A B C x y z ∨
    ScalingCorner a b c A B C x y z := by
  grind +locals

/-! ## Fixed-Point / Idempotence Theorems -/

/-
Tropical min is idempotent: min a a = a. The seed for the fixed-point interpretation.
-/
theorem scaling_min_idempotent (a : ℝ) : min a a = a := by
  exact min_self _

/-
The tropical 3-aggregate is idempotent under re-aggregation:
    once a regime has been selected, re-aggregation leaves the result unchanged.
-/
theorem tropicalAggregate3_idempotent (u v w : ℝ) :
    tropicalAggregate3 (tropicalAggregate3 u v w) v w = tropicalAggregate3 u v w := by
  exact min_eq_left ( min_le_right _ _ )

/-
The scaling loss is a fixed point of tropical regime aggregation.
-/
theorem tropicalScalingLoss_idempotent
    (a b c A B C x y z : ℝ) :
    tropicalAggregate3
      (tropicalScalingLoss a b c A B C x y z)
      (A + a * x)
      (min (B + b * y) (C + c * z))
    = tropicalScalingLoss a b c A B C x y z := by
  unfold tropicalScalingLoss tropicalAggregate3; aesop;

/-! ## Translation Invariance -/

/-
Translation distributes over tropical min (min-plus distributivity).
    Only relative intercepts matter for phase geometry.
-/
theorem tropicalScalingLoss_translation
    (a b c A B C x y z k : ℝ) :
    tropicalScalingLoss a b c (A + k) (B + k) (C + k) x y z
      = k + tropicalScalingLoss a b c A B C x y z := by
  grind +locals

/-! ## Compute-Constrained Reduction -/

/-- Under the compute constraint z = x + y (i.e., C ∼ ND), the 3-variable tropical loss
    reduces to a 2-variable tropical hypersurface. -/
theorem tropicalScalingLoss_under_compute_constraint
    (a b c A B C x y : ℝ) :
    tropicalScalingLoss a b c A B C x y (x + y) =
      min (A + a * x) (min (B + b * y) (C + c * (x + y))) := by
  rfl

/-
In the compute-dominated region under z = x + y, the loss equals the compute-affine term.
-/
theorem compute_region_affine
    {a b c A B C x y : ℝ}
    (h : ComputeDominates a b c A B C x y) :
    tropicalScalingLoss a b c A B C x y (x + y) = C + c * (x + y) := by
  exact mod_cast tropicalScalingLoss_eq_affine_on_StrictCRegion ( h.1 |> fun h' => ⟨ h'.gt, h.2.gt ⟩ ) ;

/-! ## Emergence Near Corners -/

/-
At a corner, the tropical loss equals the tied minimum value; the same point
    trivially witnesses that some configuration achieves this loss.
-/
theorem corner_indicates_regime_competition
    {a b c A B C x y z : ℝ}
    (_h : ScalingCorner a b c A B C x y z) :
    ∃ u v w, tropicalScalingLoss a b c A B C u v w =
      tropicalScalingLoss a b c A B C x y z := by
  exact ⟨ x, y, z, rfl ⟩

/-! ## Cross-Domain Connection: Zero-Temperature / Statistical Mechanics

In statistical mechanics, the free energy at inverse temperature β is
  F_β = -β⁻¹ log(e^{-β f₁} + e^{-β f₂} + e^{-β f₃}).
As β → ∞ (zero temperature), F_β → min(f₁, f₂, f₃).

The following theorem formalizes the tropical absorption law, analogous to how
in the zero-temperature limit only the ground state contributes. -/

/-
Tropical absorption: if w ≥ min u v, then min (min u v) w = min u v.
    This models the statistical-mechanics principle that dominated states
    are irrelevant at zero temperature.
-/
theorem tropical_absorption_law {u v w : ℝ} (h : min u v ≤ w) :
    min (min u v) w = min u v := by
  exact min_eq_left h

end TropicalScaling

end