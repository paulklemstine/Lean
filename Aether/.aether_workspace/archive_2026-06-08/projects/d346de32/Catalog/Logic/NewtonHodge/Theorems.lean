/-
  Newton-Hodge Polygon Theorems for 2-Dimensional Filtered φ-Modules

  Main results establishing the monodromy defect δ as the universal parameter:
  1. Defect Symmetry: δ = s₁ - w₁ = w₂ - s₂
  2. Defect Upper Bound: δ ≤ γ/2 (from slope ordering)
  3. Newton-Hodge Inequality: Newton ≥ Hodge iff δ ≥ 0
  4. Slope Spread Formula: σ = γ - 2δ (discriminant formula)
  5. Ordinary Characterization: ordinary iff δ = 0
  6. Supersingular Characterization: supersingular iff δ = γ/2
  7. Polygon Gap at Midpoint: G(1) = δ
  8. Tropical Metric: d(M₁, M₂) = |δ₁ - δ₂| satisfies metric axioms
  9. Normalized Defect Range: δ_norm ∈ [0, 1/2]
-/

import Logic.NewtonHodge.Defs

open FilteredPhiModule2

/-! ## 1. Defect Symmetry -/

/-
**Defect Symmetry Theorem**: The defect δ = s₁ - w₁ equals w₂ - s₂.
    This reveals a hidden duality: the Newton slope's excess over the first
    Hodge weight equals the second Hodge weight's excess over the Newton slope.
    Proof: from s₁ + s₂ = w₁ + w₂, we get s₁ - w₁ = w₂ - s₂.
-/
theorem defect_symmetry (M : FilteredPhiModule2) :
    M.defect = M.w₂ - M.s₂ := by
  unfold FilteredPhiModule2.defect;
  linarith [ M.endpoint_match ]

/-! ## 2. Defect Bounds -/

/-
**Defect Upper Bound**: The defect is at most half the Hodge gap.
    This follows from the Newton slope ordering s₁ ≤ s₂ combined with
    endpoint matching: 2s₁ ≤ s₁ + s₂ = w₁ + w₂, so s₁ ≤ (w₁+w₂)/2,
    hence δ = s₁ - w₁ ≤ (w₂ - w₁)/2.
-/
theorem defect_le_half_hodgeGap (M : FilteredPhiModule2) :
    M.defect ≤ M.hodgeGap / 2 := by
  -- From the endpoint match, we have s₂ = w₁ + w₂ - s₁.
  have h_s2 : M.s₂ = M.w₁ + M.w₂ - M.s₁ := by
    linarith [ M.endpoint_match ];
  unfold FilteredPhiModule2.defect FilteredPhiModule2.hodgeGap; linarith [ M.newton_le ] ;

/-
The Hodge gap is always nonneg (from w₁ ≤ w₂).
-/
theorem hodgeGap_nonneg (M : FilteredPhiModule2) :
    0 ≤ M.hodgeGap := by
  exact sub_nonneg_of_le M.hodge_le

/-! ## 3. Slope Spread Formula -/

/-
**Discriminant Formula**: The Newton spread σ = s₂ - s₁ equals γ - 2δ.
    This connects the spread of Newton slopes to the defect via the Hodge gap.
    Equivalently, the "slope discriminant" is controlled by the defect.
-/
theorem slope_spread_formula (M : FilteredPhiModule2) :
    M.newtonSpread = M.hodgeGap - 2 * M.defect := by
  unfold FilteredPhiModule2.newtonSpread FilteredPhiModule2.hodgeGap FilteredPhiModule2.defect;
  linarith [ M.endpoint_match ]

/-! ## 4. Weak Admissibility Characterization -/

/-
**Admissibility via Defect**: A module is weakly admissible iff δ ≥ 0.
-/
theorem weaklyAdmissible_iff_defect_nonneg (M : FilteredPhiModule2) :
    M.WeaklyAdmissible ↔ 0 ≤ M.defect := by
  unfold FilteredPhiModule2.WeaklyAdmissible FilteredPhiModule2.defect; aesop;

/-! ## 5. Ordinary and Supersingular Characterizations -/

/-
**Ordinary Characterization**: A module is ordinary iff the defect vanishes.
-/
theorem ordinary_iff_zero_defect (M : FilteredPhiModule2) :
    M.IsOrdinary ↔ M.defect = 0 := by
  unfold FilteredPhiModule2.IsOrdinary FilteredPhiModule2.defect;
  rw [ sub_eq_zero ]

/-
**Supersingular Characterization**: A module is supersingular (equal Newton slopes)
    iff the defect achieves its maximum value γ/2.
-/
theorem supersingular_iff_max_defect (M : FilteredPhiModule2) :
    M.IsSupersingular ↔ M.defect = M.hodgeGap / 2 := by
  constructor <;> intro h <;> unfold FilteredPhiModule2.IsSupersingular FilteredPhiModule2.defect FilteredPhiModule2.hodgeGap at * <;> linarith [ M.endpoint_match ]

/-
Ordinary implies weakly admissible.
-/
theorem ordinary_weaklyAdmissible (M : FilteredPhiModule2) (h : M.IsOrdinary) :
    M.WeaklyAdmissible := by
  -- By definition of ordinary �,� we have s₁ = w₁.
  unfold FilteredPhiModule2.IsOrdinary at h; unfold FilteredPhiModule2.WeaklyAdmissible; aesop

/-
Supersingular implies weakly admissible (when Hodge gap is nonneg).
-/
theorem supersingular_weaklyAdmissible (M : FilteredPhiModule2)
    (h : M.IsSupersingular) : M.WeaklyAdmissible := by
  obtain ⟨h₁, h₂⟩ := M;
  unfold FilteredPhiModule2.IsSupersingular FilteredPhiModule2.WeaklyAdmissible at * ; linarith

/-! ## 6. Polygon Gap Analysis -/

/-
**Midpoint Gap Theorem**: The polygon gap at x = 1 equals the defect.
    G(1) = N(1) - H(1) = s₁ - w₁ = δ.
-/
theorem polygonGap_at_one (M : FilteredPhiModule2) :
    M.polygonGap 1 = M.defect := by
  unfold FilteredPhiModule2.polygonGap FilteredPhiModule2.newtonPolygon FilteredPhiModule2.hodgePolygon FilteredPhiModule2.defect; norm_num;

/-
The polygon gap vanishes at x = 0.
-/
theorem polygonGap_at_zero (M : FilteredPhiModule2) :
    M.polygonGap 0 = 0 := by
  unfold FilteredPhiModule2.polygonGap FilteredPhiModule2.newtonPolygon FilteredPhiModule2.hodgePolygon; norm_num;

/-
The polygon gap vanishes at x = 2 (endpoint matching).
-/
theorem polygonGap_at_two (M : FilteredPhiModule2) :
    M.polygonGap 2 = 0 := by
  unfold FilteredPhiModule2.polygonGap FilteredPhiModule2.newtonPolygon FilteredPhiModule2.hodgePolygon; norm_num; linarith [ M.endpoint_match ] ;

/-
**Newton ≥ Hodge at midpoint iff admissible**: The Newton polygon value at x = 1
    is at least the Hodge polygon value iff the module is weakly admissible.
-/
theorem newton_ge_hodge_at_one_iff (M : FilteredPhiModule2) :
    M.hodgePolygon 1 ≤ M.newtonPolygon 1 ↔ M.WeaklyAdmissible := by
  -- By definition of hodgePolygon and newtonPolygon, we have hodgePolygon 1 = M.w₁ and newtonPolygon 1 = M.s₁.
  simp [hodgePolygon, newtonPolygon, WeaklyAdmissible]

/-! ## 7. Tropical Metric Properties -/

/-
**Tropical Symmetry**: d(M₁, M₂) = d(M₂, M₁).
-/
theorem tropicalDist_symm (M₁ M₂ : FilteredPhiModule2) :
    tropicalDist M₁ M₂ = tropicalDist M₂ M₁ := by
  exact abs_sub_comm _ _

/-
**Tropical Nonnegativity**: d(M₁, M₂) ≥ 0.
-/
theorem tropicalDist_nonneg (M₁ M₂ : FilteredPhiModule2) :
    0 ≤ tropicalDist M₁ M₂ := by
  exact abs_nonneg _

/-
**Tropical Self-Distance**: d(M, M) = 0.
-/
theorem tropicalDist_self (M : FilteredPhiModule2) :
    tropicalDist M M = 0 := by
  unfold FilteredPhiModule2.tropicalDist; norm_num;

/-
**Tropical Triangle Inequality**: d(M₁, M₃) ≤ d(M₁, M₂) + d(M₂, M₃).
-/
theorem tropicalDist_triangle (M₁ M₂ M₃ : FilteredPhiModule2) :
    tropicalDist M₁ M₃ ≤ tropicalDist M₁ M₂ + tropicalDist M₂ M₃ := by
  exact abs_sub_le _ _ _

/-! ## 8. Defect Determines Module (Rigidity) -/

/-
**Defect Rigidity**: Two modules with the same Hodge weights and the same
    defect have the same Newton slopes. The defect is a complete invariant
    (given the Hodge data).
-/
theorem defect_determines_slopes (M₁ M₂ : FilteredPhiModule2)
    (hw₁ : M₁.w₁ = M₂.w₁) (hw₂ : M₁.w₂ = M₂.w₂)
    (hδ : M₁.defect = M₂.defect) :
    M₁.s₁ = M₂.s₁ ∧ M₁.s₂ = M₂.s₂ := by
  constructor <;> have := M₁.endpoint_match <;> have := M₂.endpoint_match <;> simp_all +decide [ FilteredPhiModule2.defect ] ; linarith;

/-! ## 9. Newton Spread Bounds -/

/-
The Newton spread is nonneg (it equals s₂ - s₁ ≥ 0).
-/
theorem newtonSpread_nonneg (M : FilteredPhiModule2) :
    0 ≤ M.newtonSpread := by
  exact sub_nonneg_of_le M.newton_le

/-
The Newton spread is at most the Hodge gap (for weakly admissible modules).
-/
theorem newtonSpread_le_hodgeGap (M : FilteredPhiModule2)
    (h : M.WeaklyAdmissible) :
    M.newtonSpread ≤ M.hodgeGap := by
  linarith [ defect_determines_slopes M M rfl rfl rfl, slope_spread_formula M, show M.defect ≥ 0 from ( weaklyAdmissible_iff_defect_nonneg M ).mp h ]

/-
The Newton spread equals the Hodge gap iff ordinary.
-/
theorem newtonSpread_eq_hodgeGap_iff (M : FilteredPhiModule2) :
    M.newtonSpread = M.hodgeGap ↔ M.IsOrdinary := by
  -- Use slope_spread_formula and ordinary_iff_zero_defect.
  rw [slope_spread_formula, ordinary_iff_zero_defect];
  constructor <;> intro h <;> linarith

/-
The Newton spread is zero iff supersingular.
-/
theorem newtonSpread_zero_iff (M : FilteredPhiModule2) :
    M.newtonSpread = 0 ↔ M.IsSupersingular := by
  unfold FilteredPhiModule2.newtonSpread FilteredPhiModule2.IsSupersingular; constructor <;> intro h <;> linarith;

/-! ## 10. Normalized Defect -/

/-
**Normalized Defect Range**: For a weakly admissible module with positive
    Hodge gap, the normalized defect lies in [0, 1/2].
-/
theorem normalizedDefect_range (M : FilteredPhiModule2)
    (hadm : M.WeaklyAdmissible) (hgap : 0 < M.hodgeGap) :
    0 ≤ M.normalizedDefect ∧ M.normalizedDefect ≤ 1 / 2 := by
  unfold FilteredPhiModule2.normalizedDefect at *; norm_num at *;
  split_ifs <;> simp_all +decide [ div_le_iff₀ ];
  exact ⟨ div_nonneg ( by linarith [ show M.defect ≥ 0 from by simpa [ FilteredPhiModule2.defect ] using hadm ] ) hgap.le, by linarith [ show M.defect ≤ M.hodgeGap / 2 from by linarith [ show M.defect ≤ M.hodgeGap / 2 from by exact defect_le_half_hodgeGap M ] ] ⟩