/-
# Newton-Hodge Polygon Theory for p-adic Langlands GL₂(ℚ_p)

This module formalizes the Newton-Hodge polygon constraints that govern
the p-adic Langlands correspondence for GL₂(ℚ_p). The key theorem is that
for a weakly admissible filtered φ-module of dimension 2, the Newton polygon
lies on or above the Hodge polygon with matching endpoints.

## Mathematical Context

For a 2-dimensional crystalline representation V of Gal(Q̄_p/Q_p):
- The **Hodge polygon** is determined by Hodge-Tate weights w₁ ≤ w₂
- The **Newton polygon** is determined by Frobenius slopes s₁ ≤ s₂
- Weak admissibility requires: s₁ + s₂ = w₁ + w₂ (endpoint match)
  and s₁ ≥ w₁ (Newton above Hodge)

These constraints are the foundation of the Colmez-Fontaine theorem
(weakly admissible = admissible) and underpin the entire p-adic
Langlands program.
-/

import Mathlib

open Finset BigOperators

/-! ## Core Structures -/

/-- Hodge-Tate weights for a 2-dimensional p-adic Galois representation.
    By convention, `w₁ ≤ w₂`. For a crystalline representation attached to
    a modular form of weight k, the weights are (0, k-1). -/
structure HodgeTateWeights where
  w₁ : ℤ
  w₂ : ℤ
  ordered : w₁ ≤ w₂

/-- Newton slopes for a 2-dimensional filtered φ-module.
    These are the p-adic valuations of the eigenvalues of Frobenius.
    By convention, `s₁ ≤ s₂`. -/
structure NewtonSlopes where
  s₁ : ℚ
  s₂ : ℚ
  ordered : s₁ ≤ s₂

/-- The Hodge number tH: sum of Hodge-Tate weights. -/
def HodgeTateWeights.tH (w : HodgeTateWeights) : ℤ := w.w₁ + w.w₂

/-- The Newton number tN: sum of Newton slopes. -/
def NewtonSlopes.tN (s : NewtonSlopes) : ℚ := s.s₁ + s.s₂

/-- A weakly admissible filtered φ-module datum for GL₂(ℚ_p). -/
structure WeaklyAdmissibleDatum where
  weights : HodgeTateWeights
  slopes : NewtonSlopes
  endpoint_match : slopes.tN = ↑weights.tH
  newton_above_hodge : slopes.s₁ ≥ ↑weights.w₁

/-! ## Main Theorems: Slope-Weight Inequalities -/

/-
**Slope upper bound**: The larger slope is bounded above by the larger weight.
-/
theorem slope_upper_bound (D : WeaklyAdmissibleDatum) :
    D.slopes.s₂ ≤ ↑D.weights.w₂ := by
  linarith [ D.endpoint_match, D.newton_above_hodge, D.slopes.ordered, show ( D.slopes.s₁ : ℚ ) + D.slopes.s₂ = D.weights.w₁ + D.weights.w₂ by exact_mod_cast D.endpoint_match, show ( D.slopes.s₁ : ℚ ) ≥ D.weights.w₁ by exact_mod_cast D.newton_above_hodge ]

/-
**Full slope-weight interlacing**: w₁ ≤ s₁ ≤ s₂ ≤ w₂ (as rationals).
-/
theorem slope_weight_interlacing (D : WeaklyAdmissibleDatum) :
    (↑D.weights.w₁ : ℚ) ≤ D.slopes.s₁ ∧
    D.slopes.s₁ ≤ D.slopes.s₂ ∧
    D.slopes.s₂ ≤ ↑D.weights.w₂ := by
  grind +suggestions

/-
**Slope gap bounded by weight gap**: The spread of slopes is bounded
    by the spread of weights.
-/
theorem slope_gap_le_weight_gap (D : WeaklyAdmissibleDatum) :
    D.slopes.s₂ - D.slopes.s₁ ≤ ↑D.weights.w₂ - ↑D.weights.w₁ := by
  linarith [ slope_weight_interlacing D ]

/-
**Average slope equals average weight**.
-/
theorem average_slope_eq_weight (D : WeaklyAdmissibleDatum) :
    (D.slopes.s₁ + D.slopes.s₂) / 2 = (↑D.weights.w₁ + ↑D.weights.w₂) / 2 := by
  convert congr_arg ( · / 2 ) D.endpoint_match using 1;
  norm_cast

/-! ## Ordinary and Supersingular Classification -/

/-- A datum is ordinary when Newton = Hodge at all vertices. -/
def WeaklyAdmissibleDatum.isOrdinary (D : WeaklyAdmissibleDatum) : Prop :=
  D.slopes.s₁ = ↑D.weights.w₁ ∧ D.slopes.s₂ = ↑D.weights.w₂

/-- A datum is supersingular when both slopes are equal. -/
def WeaklyAdmissibleDatum.isSupersingular (D : WeaklyAdmissibleDatum) : Prop :=
  D.slopes.s₁ = D.slopes.s₂

/-
**Supersingular slope value**: Both slopes equal the average weight.
-/
theorem supersingular_slope_value (D : WeaklyAdmissibleDatum)
    (hss : D.isSupersingular) :
    D.slopes.s₁ = (↑D.weights.w₁ + ↑D.weights.w₂) / 2 := by
  unfold WeaklyAdmissibleDatum.isSupersingular at hss;
  linarith [ average_slope_eq_weight D ]

/-
**Supersingular integral slopes imply even weight sum**.
-/
theorem supersingular_even_weight_sum (D : WeaklyAdmissibleDatum)
    (hss : D.isSupersingular) (hint : ∃ n : ℤ, D.slopes.s₁ = ↑n) :
    Even (D.weights.w₁ + D.weights.w₂) := by
  -- From supersingular_slope_value: � s�₁ = � (�w₁+w₂ �)/�2.
  have h_slope_eq_avg : (D.slopes.s₁ : ℚ) = (D.weights.w₁ + D.weights.w₂) / 2 :=
    supersingular_slope_value D hss
  obtain ⟨ n, hn ⟩ := ‹∃ n : ℤ, D.slopes.s₁ = n›; use n; rw [ ← @Int.cast_inj ℚ ] ; push_cast; linarith;

/-
**Ordinary with distinct weights gives distinct slopes**.
-/
theorem ordinary_distinct_slopes (D : WeaklyAdmissibleDatum)
    (hord : D.isOrdinary) (hdist : D.weights.w₁ < D.weights.w₂) :
    D.slopes.s₁ < D.slopes.s₂ := by
  convert hdist using 1;
  rw [ ← @Int.cast_lt ℚ ] ; simp +decide [ hord.1, hord.2 ]

/-! ## Newton and Hodge Polygon Functions -/

/-- The Hodge polygon evaluated at integer points 0, 1, 2. -/
def hodgePolygonAt (w : HodgeTateWeights) : Fin 3 → ℚ
  | ⟨0, _⟩ => 0
  | ⟨1, _⟩ => ↑w.w₁
  | ⟨2, _⟩ => ↑w.w₁ + ↑w.w₂

/-- The Newton polygon evaluated at integer points 0, 1, 2. -/
def newtonPolygonAt (s : NewtonSlopes) : Fin 3 → ℚ
  | ⟨0, _⟩ => 0
  | ⟨1, _⟩ => s.s₁
  | ⟨2, _⟩ => s.s₁ + s.s₂

/-
**Newton above Hodge pointwise**.
-/
theorem newton_above_hodge_pointwise (D : WeaklyAdmissibleDatum) :
    ∀ i : Fin 3, hodgePolygonAt D.weights i ≤ newtonPolygonAt D.slopes i := by
  intro i;
  fin_cases i <;> simp +decide [ hodgePolygonAt, newtonPolygonAt, slope_weight_interlacing D ];
  convert D.endpoint_match.ge using 1 ; ring;
  norm_cast

/-
**Hodge polygon concavity**: slopes of Hodge polygon are non-decreasing.
-/
theorem hodge_polygon_concave (w : HodgeTateWeights) :
    hodgePolygonAt w ⟨1, by omega⟩ - hodgePolygonAt w ⟨0, by omega⟩ ≤
    hodgePolygonAt w ⟨2, by omega⟩ - hodgePolygonAt w ⟨1, by omega⟩ := by
  unfold hodgePolygonAt; norm_num; linarith [ w.ordered ] ;

/-
**Newton polygon convexity**: slopes of Newton polygon are non-decreasing.
-/
theorem newton_polygon_convex (s : NewtonSlopes) :
    newtonPolygonAt s ⟨1, by omega⟩ - newtonPolygonAt s ⟨0, by omega⟩ ≤
    newtonPolygonAt s ⟨2, by omega⟩ - newtonPolygonAt s ⟨1, by omega⟩ := by
  convert s.ordered using 1;
  · exact sub_zero _;
  · exact sub_eq_iff_eq_add'.mpr ( by unfold newtonPolygonAt; ring! )

/-! ## Weight Duality -/

/-- The dual weights: if V has weights (w₁, w₂), then V*(1) has weights (-w₂, -w₁). -/
def HodgeTateWeights.dual (w : HodgeTateWeights) : HodgeTateWeights where
  w₁ := -w.w₂
  w₂ := -w.w₁
  ordered := Int.neg_le_neg w.ordered

/-
**Duality is an involution**.
-/
@[simp]
theorem dual_involution (w : HodgeTateWeights) :
    w.dual.dual = w := by
  cases w;
  rename_i a b h; unfold HodgeTateWeights.dual; norm_num;

/-
**Weight sum negation under duality**.
-/
theorem dual_tH (w : HodgeTateWeights) :
    w.dual.tH = -w.tH := by
  unfold HodgeTateWeights.tH HodgeTateWeights.dual; ring;

/-! ## Classical Weights -/

/-- A weight is *classical* if it corresponds to a modular form weight k ≥ 2,
    i.e., the Hodge-Tate weights are (0, k-1) for some k ≥ 2. -/
def HodgeTateWeights.isClassical (w : HodgeTateWeights) : Prop :=
  w.w₁ = 0 ∧ w.w₂ ≥ 1

/-
**Classical weight sum is positive**.
-/
theorem classical_weight_sum_pos (w : HodgeTateWeights)
    (hcl : w.isClassical) : w.tH ≥ 1 := by
  cases hcl ; unfold HodgeTateWeights.tH ; linarith

/-
**Classical ordinary has zero first slope**.
-/
theorem classical_ordinary_zero_slope (D : WeaklyAdmissibleDatum)
    (hcl : D.weights.isClassical)
    (hord : D.isOrdinary) : D.slopes.s₁ = 0 := by
  convert hord.1 using 1 ; norm_cast ; linarith [ hcl.1 ]

/-! ## Ordinary Slopes are Integral -/

/-
**Ordinary slopes are integers** (they equal the integer weights).
-/
theorem ordinary_slopes_integral (D : WeaklyAdmissibleDatum)
    (hord : D.isOrdinary) :
    (∃ n : ℤ, D.slopes.s₁ = ↑n) ∧ (∃ n : ℤ, D.slopes.s₂ = ↑n) := by
  exact ⟨ ⟨ _, hord.1 ⟩, ⟨ _, hord.2 ⟩ ⟩

/-! ## Tropical Connection -/

/-- The tropical invariant: min of slopes (tropical evaluation of char poly of φ). -/
def tropicalInvariant (s : NewtonSlopes) : ℚ := min s.s₁ s.s₂

/-
**Tropical invariant equals first slope** (slopes are ordered).
-/
theorem tropical_invariant_eq_first_slope (s : NewtonSlopes) :
    tropicalInvariant s = s.s₁ := by
  exact min_eq_left s.ordered

/-
**Tropical invariant bounded by weights**.
-/
theorem tropical_invariant_weight_bound (D : WeaklyAdmissibleDatum) :
    (↑D.weights.w₁ : ℚ) ≤ tropicalInvariant D.slopes ∧
    tropicalInvariant D.slopes ≤ ↑D.weights.w₂ := by
  grind +suggestions

/-! ## Breuil-Mézard Multiplicity (Conjecture / Testable) -/

/-- **Breuil-Mézard multiplicity** for weight 2 deformation rings.
    When the Frobenius eigenvalue ratio is ±1 (scalar case), the multiplicity
    doubles due to reducibility of the residual representation. -/
def breuilMezardMultiplicity (_p : ℕ) (α_is_pm_one : Bool) : ℕ :=
  if α_is_pm_one then 2 else 1

/-
Breuil-Mézard multiplicity is always positive.
-/
theorem breuil_mezard_pos (p : ℕ) (b : Bool) :
    breuilMezardMultiplicity p b ≥ 1 := by
  unfold breuilMezardMultiplicity; split_ifs <;> norm_num;

/-
Breuil-Mézard multiplicity is at most 2 in weight 2.
-/
theorem breuil_mezard_le_two (p : ℕ) (b : Bool) :
    breuilMezardMultiplicity p b ≤ 2 := by
  cases b <;> simp +decide [ breuilMezardMultiplicity ]

/-! ## Colmez Functor Realization -/

/-- A 2-dimensional Galois representation with sorted weights. -/
structure GaloisRep2d (p : ℕ) [Fact (Nat.Prime p)] where
  w₁ : ℤ
  w₂ : ℤ
  ordered : w₁ ≤ w₂

/-- Extract Hodge-Tate weights from a 2d Galois representation. -/
def GaloisRep2d.toHodgeTateWeights {p : ℕ} [Fact (Nat.Prime p)]
    (ρ : GaloisRep2d p) : HodgeTateWeights where
  w₁ := ρ.w₁
  w₂ := ρ.w₂
  ordered := ρ.ordered

/-- The Colmez functor realization for GL₂: pairs a 2d Galois representation
    with Newton slopes satisfying the determinant constraint. -/
structure ColmezRealization (p : ℕ) [Fact (Nat.Prime p)] where
  galois : GaloisRep2d p
  slopes : NewtonSlopes
  det_constraint : slopes.tN = ↑(galois.w₁ + galois.w₂)

/-- Extract a WeaklyAdmissibleDatum from a ColmezRealization
    when the Newton-above-Hodge condition holds. -/
def ColmezRealization.toWeaklyAdmissible {p : ℕ} [Fact (Nat.Prime p)]
    (C : ColmezRealization p)
    (h_nah : C.slopes.s₁ ≥ ↑C.galois.w₁) :
    WeaklyAdmissibleDatum where
  weights := C.galois.toHodgeTateWeights
  slopes := C.slopes
  endpoint_match := by
    simp [HodgeTateWeights.tH, GaloisRep2d.toHodgeTateWeights]
    rw [C.det_constraint]; push_cast; ring
  newton_above_hodge := by
    simp [GaloisRep2d.toHodgeTateWeights]
    exact h_nah

/-
The Colmez functor preserves the interlacing property.
-/
theorem colmez_interlacing {p : ℕ} [Fact (Nat.Prime p)]
    (C : ColmezRealization p)
    (h_nah : C.slopes.s₁ ≥ ↑C.galois.w₁) :
    (↑C.galois.w₁ : ℚ) ≤ C.slopes.s₁ ∧
    C.slopes.s₁ ≤ C.slopes.s₂ ∧
    C.slopes.s₂ ≤ ↑C.galois.w₂ := by
  convert slope_weight_interlacing ( C.toWeaklyAdmissible h_nah ) using 1

/-! ## Filtration Jump Theory -/

/-- The number of filtration jumps in [a, b] for weights (w₁, w₂). -/
def filtrationJumps (w : HodgeTateWeights) (a b : ℤ) : ℕ :=
  (if a ≤ w.w₁ ∧ w.w₁ ≤ b then 1 else 0) +
  (if a ≤ w.w₂ ∧ w.w₂ ≤ b then 1 else 0)

/-
**Total filtration jumps**: Over the full weight range, exactly 2 jumps.
-/
theorem filtration_jumps_total (w : HodgeTateWeights) :
    filtrationJumps w w.w₁ w.w₂ = 2 := by
  unfold filtrationJumps;
  simp +decide [ w.ordered ]

/-
**No jumps outside weight range**.
-/
theorem filtration_jumps_outside_zero (w : HodgeTateWeights) (a b : ℤ)
    (hab : b < w.w₁ ∨ w.w₂ < a) :
    filtrationJumps w a b = 0 := by
  rcases hab with ( h | h ) <;> unfold filtrationJumps <;> split_ifs <;> linarith [ w.ordered ]

/-
**Filtration jumps are monotone in the interval**.
-/
theorem filtration_jumps_monotone (w : HodgeTateWeights) (a₁ b₁ a₂ b₂ : ℤ)
    (ha : a₂ ≤ a₁) (hb : b₁ ≤ b₂) :
    filtrationJumps w a₁ b₁ ≤ filtrationJumps w a₂ b₂ := by
  unfold filtrationJumps;
  grind

/-! ## Monodromy Defect Theory -/

/-- The monodromy defect: how far slopes deviate from the ordinary case. -/
def monodromyDefect (D : WeaklyAdmissibleDatum) : ℚ :=
  D.slopes.s₁ - ↑D.weights.w₁

/-
**Monodromy defect is non-negative**.
-/
theorem monodromy_defect_nonneg (D : WeaklyAdmissibleDatum) :
    monodromyDefect D ≥ 0 := by
  exact sub_nonneg_of_le ( D.newton_above_hodge )

/-
**Monodromy defect symmetry**: defect from below = defect from above.
-/
theorem monodromy_defect_symmetric (D : WeaklyAdmissibleDatum) :
    monodromyDefect D = ↑D.weights.w₂ - D.slopes.s₂ := by
  unfold monodromyDefect;
  linarith [ show ( D.slopes.s₁ : ) + D.slopes.s₂ = D.weights.w₁ + D.weights.w₂ from mod_cast D.endpoint_match ]

/-
**Zero monodromy defect characterizes ordinary**.
-/
theorem monodromy_defect_zero_iff_ordinary (D : WeaklyAdmissibleDatum) :
    monodromyDefect D = 0 ↔ D.isOrdinary := by
  constructor <;> intro h;
  · constructor;
    · exact eq_of_sub_eq_zero h;
    · linarith [ monodromy_defect_symmetric D ];
  · exact sub_eq_zero_of_eq h.1

/-! ## Crystalline + Classical Slope Range -/

/-- A datum is crystalline if all slopes are non-negative. -/
def WeaklyAdmissibleDatum.isCrystalline (D : WeaklyAdmissibleDatum) : Prop :=
  D.slopes.s₁ ≥ 0

/-
**Crystalline + classical gives slopes in [0, w₂]**.
-/
theorem crystalline_classical_slope_range (D : WeaklyAdmissibleDatum)
    (_hcl : D.weights.isClassical)
    (hcrys : D.isCrystalline) :
    0 ≤ D.slopes.s₁ ∧ D.slopes.s₂ ≤ ↑D.weights.w₂ := by
  exact ⟨ hcrys, slope_upper_bound D ⟩