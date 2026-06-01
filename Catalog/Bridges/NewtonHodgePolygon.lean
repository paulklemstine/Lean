import Mathlib
import Bridges.NewtonHodgeDefs

/-!
# Newton-Hodge Polygon Theorems for the p-adic Langlands Correspondence

This file proves the core structural theorems of the Newton-Hodge polygon
framework for 2-dimensional filtered φ-modules, as arise in the p-adic
Langlands correspondence for GL₂(ℚ_p).

## Main Results

### Monodromy Defect Theory
* `monodromy_defect_symmetry` — The defect δ = s₁ - w₁ = w₂ - s₂
* `monodromy_defect_nonneg` — δ ≥ 0 for weakly admissible modules
* `monodromy_defect_upper_bound` — δ ≤ (w₂ - w₁)/2

### Newton-Hodge Inequality
* `newton_above_hodge_all` — Newton polygon ≥ Hodge polygon at all vertices

### Classification
* `ordinary_iff_defect_zero` — Ordinary ↔ δ = 0
* `supersingular_iff_defect_maximal` — Supersingular ↔ δ = (w₂ - w₁)/2

### Tropical Structure
* `admissibility_polytope_nonempty` — The polytope is always nonempty
* `tropical_distance_on_polytope` — Distance formula on the polytope
-/

noncomputable section

open Real

variable (M : FilteredPhiModule)

/-! ## Part I: Monodromy Defect Theory -/

/-
**Monodromy Defect Symmetry**: δ = s₁ - w₁ = w₂ - s₂.
    Follows from endpoint matching: s₁ + s₂ = w₁ + w₂.
-/
theorem monodromy_defect_symmetry (hwa : WeakAdmissibility M) :
    MonodromyDefect M = M.w₂ - M.s₂ := by
  exact sub_eq_sub_iff_add_eq_add.mpr ( by linarith [ hwa.endpoint_match ] )

/-
**Monodromy defect is non-negative** for weakly admissible modules.
-/
theorem monodromy_defect_nonneg (hwa : WeakAdmissibility M) :
    0 ≤ MonodromyDefect M := by
  exact sub_nonneg_of_le hwa.newton_above_hodge

/-
**Upper bound on monodromy defect**: δ ≤ (w₂ - w₁)/2.
-/
theorem monodromy_defect_upper_bound (hwa : WeakAdmissibility M) :
    MonodromyDefect M ≤ HodgeSpectralGap M / 2 := by
  unfold MonodromyDefect HodgeSpectralGap;
  linarith [ hwa.newton_above_hodge, hwa.endpoint_match, M.newton_le ]

/-
**s₁ from defect**: s₁ = w₁ + δ.
-/
theorem monodromy_defect_determines_s₁ :
    M.s₁ = M.w₁ + MonodromyDefect M := by
  simp [MonodromyDefect]

/-
**s₂ from defect**: s₂ = w₂ - δ (requires weak admissibility).
-/
theorem monodromy_defect_determines_s₂ (hwa : WeakAdmissibility M) :
    M.s₂ = M.w₂ - MonodromyDefect M := by
  unfold MonodromyDefect;
  linarith [ hwa.endpoint_match ]

/-! ## Part II: Newton-Hodge Inequality -/

/-
**Newton above Hodge at all vertices**: For weakly admissible modules,
    the Newton polygon lies on or above the Hodge polygon at every vertex.
-/
theorem newton_above_hodge_all (hwa : WeakAdmissibility M) (x : ℕ) (hx : x ≤ 2) :
    HodgePolygon M x ≤ NewtonPolygon M x := by
  interval_cases x <;> simp +decide [ *, HodgePolygon, NewtonPolygon ];
  · exact hwa.newton_above_hodge;
  · linarith [ hwa.newton_above_hodge, hwa.endpoint_match ]

/-
**Endpoint matching at 0**: Both polygons start at 0.
-/
theorem newton_hodge_match_at_zero :
    NewtonPolygon M 0 = HodgePolygon M 0 := by
  simp [NewtonPolygon, HodgePolygon]

/-
**Endpoint matching at 2**: Both polygons end at the same value.
-/
theorem newton_hodge_match_at_two (hwa : WeakAdmissibility M) :
    NewtonPolygon M 2 = HodgePolygon M 2 := by
  exact hwa.endpoint_match

/-! ## Part III: Classification by Monodromy Defect -/

/-
**Ordinary iff defect zero**: Ordinary ↔ δ = 0.
-/
theorem ordinary_iff_defect_zero (hwa : WeakAdmissibility M) :
    IsOrdinary M ↔ MonodromyDefect M = 0 := by
  constructor <;> intro h <;> unfold IsOrdinary MonodromyDefect at *;
  · linarith;
  · constructor <;> linarith [ hwa.newton_above_hodge, hwa.endpoint_match ]

/-
**Supersingular iff defect maximal**: s₁ = s₂ ↔ δ = (w₂ - w₁)/2.
-/
theorem supersingular_iff_defect_maximal (hwa : WeakAdmissibility M) :
    IsSupersingular M ↔ MonodromyDefect M = HodgeSpectralGap M / 2 := by
  constructor <;> intro h <;> unfold IsSupersingular MonodromyDefect HodgeSpectralGap at * <;> linarith [ hwa.1, hwa.2 ]

/-
**Supersingular slope value**: When supersingular and weakly admissible,
    both slopes equal (w₁ + w₂)/2.
-/
theorem supersingular_slope_value (hwa : WeakAdmissibility M) (hss : IsSupersingular M) :
    M.s₁ = (M.w₁ + M.w₂) / 2 := by
  linarith [ hwa.newton_above_hodge, hwa.endpoint_match, hss.symm ▸ hwa.endpoint_match ]

/-! ## Part IV: Slope Discriminant -/

/-
**Discriminant from defect**: Δ = (w₂ - w₁ - 2δ)².
-/
theorem discriminant_from_defect (hwa : WeakAdmissibility M) :
    SlopeDiscriminant M = (HodgeSpectralGap M - 2 * MonodromyDefect M) ^ 2 := by
  unfold SlopeDiscriminant HodgeSpectralGap MonodromyDefect;
  rw [ show M.s₂ = M.w₁ + M.w₂ - M.s₁ by linarith [ hwa.2 ] ] ; ring

/-
**Discriminant vanishes iff supersingular**
-/
theorem discriminant_zero_iff_supersingular :
    SlopeDiscriminant M = 0 ↔ IsSupersingular M := by
  exact sq_eq_zero_iff.trans ( sub_eq_zero )

/-! ## Part V: Tropical Structure -/

/-
**Tropical invariant equals first slope** for ordered slopes.
-/
theorem tropical_invariant_eq_first_slope :
    TropicalInvariant M = M.s₁ := by
  exact min_eq_left M.newton_le

/-
**Tropical invariant bounded below by w₁** for weakly admissible modules.
-/
theorem tropical_invariant_lower_bound (hwa : WeakAdmissibility M) :
    M.w₁ ≤ TropicalInvariant M := by
  exact le_min hwa.newton_above_hodge ( hwa.newton_above_hodge.trans M.newton_le )

/-
**Admissibility polytope is nonempty**: The ordinary point is always admissible.
-/
theorem admissibility_polytope_nonempty (w₁ w₂ : ℝ) (h : w₁ ≤ w₂) :
    (AdmissibilityPolytope w₁ w₂).Nonempty := by
  -- Take the point (w₁, w �₂) which satisfies all the inequalities and is in the � ad�miss �ibility� polytope.
  use (w₁, w₂);
  exact ⟨ le_rfl, h, rfl ⟩

/-
**Polytope membership from defect**: δ ↦ (w₁ + δ, w₂ - δ) maps [0,(w₂-w₁)/2] into polytope.
-/
theorem admissibility_polytope_membership (w₁ w₂ : ℝ) (_h : w₁ ≤ w₂) (δ : ℝ)
    (hδ_lo : 0 ≤ δ) (hδ_hi : δ ≤ (w₂ - w₁) / 2) :
    (w₁ + δ, w₂ - δ) ∈ AdmissibilityPolytope w₁ w₂ := by
  exact ⟨ by linarith, by linarith, by ring ⟩

/-
**Tropical distance on the polytope**: d((w₁+δ₁,w₂-δ₁),(w₁+δ₂,w₂-δ₂)) = |δ₁-δ₂|.
-/
theorem tropical_distance_on_polytope (w₁ w₂ δ₁ δ₂ : ℝ) :
    TropicalDistance (w₁ + δ₁, w₂ - δ₁) (w₁ + δ₂, w₂ - δ₂) = |δ₁ - δ₂| := by
  unfold TropicalDistance; ring_nf;
  rw [ neg_add_eq_sub, abs_sub_comm, max_self ]

/-
**Slope gap from spectral gap**: s₂ - s₁ = (w₂ - w₁) - 2δ.
-/
theorem slope_gap_from_spectral_gap (hwa : WeakAdmissibility M) :
    M.s₂ - M.s₁ = HodgeSpectralGap M - 2 * MonodromyDefect M := by
  unfold HodgeSpectralGap MonodromyDefect; linarith [ hwa.2 ] ;

/-! ## Part VI: Falsifiable Conjecture -/

/-
**Slope Midpoint Conjecture**: The midpoint ((w₁+w₂)/2, (w₁+w₂)/2) is always
    in the admissibility polytope.
-/
theorem slope_midpoint_in_polytope (w₁ w₂ : ℝ) (h : w₁ ≤ w₂) :
    ((w₁ + w₂) / 2, (w₁ + w₂) / 2) ∈ AdmissibilityPolytope w₁ w₂ := by
  exact ⟨ by linarith, by linarith, by ring ⟩

end