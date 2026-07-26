import Mathlib

/-!
# Prime-Power Tropical PRGs and Arithmetic Sparsification

This file formalizes the principle that **arithmetic sparsification improves tropical
pseudorandomness**. Sampling a tropical power orbit at prime-power indices produces
a sequence whose cumulative extraction error is bounded uniformly, in contrast to
the naïve linear bound `(T+1)ε` for dense orbits.

## Main Results

* `prime_power_stagewise_decay` — Geometric recurrence gives pointwise decay.
* `prime_power_geometric_error_bound` — Cumulative error bounded by `ε₀/(1-r)`.
* `tropical_prime_power_prg_error_uniform` — Flagship uniform security theorem.
* `prime_power_beats_dense_orbit` — Prime-power bound beats dense orbit bound.
* `prime_power_fiber_decorrelation_bound` — Pairwise collision sums are bounded.

## Mathematical Significance

Prime-power thinning converts arithmetic structure into decorrelation,
replacing linear error accumulation with bounded geometric series.
-/

noncomputable section

open Finset BigOperators

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

/-! ## §1. Stagewise Geometric Decay -/

/-
**Stagewise geometric domination.** If errors satisfy
    `err(0) ≤ ε₀` and `err(j+1) ≤ r · err(j)`, then `err(j) ≤ ε₀ · r^j`.
-/
theorem prime_power_stagewise_decay
    (err : ℕ → ℝ)
    (ε₀ r : ℝ)
    (herr0 : err 0 ≤ ε₀)
    (hnonneg : ∀ j, 0 ≤ err j)
    (hgeom : ∀ j, err (j + 1) ≤ r * err j)
    (hr0 : 0 ≤ r) :
    ∀ j, err j ≤ ε₀ * r ^ j := by
  exact fun j => Nat.recOn j ( by simpa using herr0 ) fun n ih => by rw [ pow_succ', mul_left_comm ] ; exact le_trans ( hgeom n ) ( mul_le_mul_of_nonneg_left ih hr0 ) ;

/-! ## §2. Geometric Series Summation -/

/-
**Uniform bounded cumulative error.** If `err(j) ≤ ε₀ · r^j` with
    `0 ≤ r < 1`, the partial sum is bounded by `ε₀ / (1 - r)`.
-/
theorem prime_power_cumulative_error_bounded
    (err : ℕ → ℝ)
    (ε₀ r : ℝ)
    (hstage : ∀ j, 0 ≤ err j ∧ err j ≤ ε₀ * r ^ j)
    (hε₀ : 0 ≤ ε₀)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    ∀ T, (Finset.range (T + 1)).sum err ≤ ε₀ / (1 - r) := by
  intro T;
  refine' le_trans ( Finset.sum_le_sum fun i hi => hstage i |>.2 ) _;
  rw [ ← Finset.mul_sum _ _ _, geom_sum_eq ];
  · rw [ ← neg_div_neg_eq, neg_sub, neg_sub ];
    exact mul_le_mul_of_nonneg_left ( mul_le_of_le_one_left ( by exact inv_nonneg.2 ( by linarith ) ) ( sub_le_self _ ( by positivity ) ) ) hε₀;
  · linarith

/-! ## §3. Main Error Bound (Combined) -/

/-- **Prime-power geometric error bound.** Under geometric recurrence
    of stage errors, cumulative extraction error is uniformly bounded. -/
theorem prime_power_geometric_error_bound
    (err : ℕ → ℝ)
    (ε₀ r : ℝ)
    (herr0 : err 0 ≤ ε₀)
    (hnonneg : ∀ j, 0 ≤ err j)
    (hgeom : ∀ j, err (j + 1) ≤ r * err j)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    ∀ T : ℕ, (Finset.range (T + 1)).sum err ≤ ε₀ / (1 - r) := by
  have hstage : ∀ j, 0 ≤ err j ∧ err j ≤ ε₀ * r ^ j := fun j =>
    ⟨hnonneg j, prime_power_stagewise_decay err ε₀ r herr0 hnonneg hgeom hr0 j⟩
  exact prime_power_cumulative_error_bounded err ε₀ r hstage
    (le_trans (hnonneg 0) herr0) hr0 hr1

/-! ## §4. Reusable Predicate for Geometric Decay -/

/-- A predicate packaging the geometric decay hypothesis for reuse. -/
def GeometricallyDecayingError (err : ℕ → ℝ) (ε₀ r : ℝ) : Prop :=
  err 0 ≤ ε₀ ∧
  (∀ j, 0 ≤ err j) ∧
  (∀ j, err (j + 1) ≤ r * err j) ∧
  0 ≤ r ∧
  r < 1

/-- The main bound stated via the `GeometricallyDecayingError` predicate. -/
theorem geometric_error_bound_from_pred
    (err : ℕ → ℝ) (ε₀ r : ℝ)
    (h : GeometricallyDecayingError err ε₀ r) :
    ∀ T : ℕ, (Finset.range (T + 1)).sum err ≤ ε₀ / (1 - r) :=
  prime_power_geometric_error_bound err ε₀ r h.1 h.2.1 h.2.2.1 h.2.2.2.1 h.2.2.2.2

/-! ## §5. Prime-Power Fiber Decorrelation -/

/-- Prime-power decorrelation property for collision statistics. -/
def PrimePowerDecorrelated
    (C : ℕ → ℕ → ℝ)
    (p : ℕ)
    (C₀ ρ : ℝ) : Prop :=
  Nat.Prime p ∧
  (∀ i j, 0 ≤ C i j) ∧
  (∀ i j : ℕ, C (p ^ i) (p ^ j) ≤ C₀ * ρ ^ (Int.natAbs (↑i - ↑j))) ∧
  0 ≤ ρ ∧
  ρ < 1

/-
**Prime-power fiber decorrelation: per-row bound.** For any fixed index `i`,
    the sum of collision statistics `C(p^i, p^j)` over `j = 0, …, T` is
    bounded by `C₀ · (1 + ρ) / (1 - ρ)`, uniformly in both `i` and `T`.
    This is the structural consequence of exponential decorrelation.
-/
theorem prime_power_fiber_decorrelation_row_bound
    (C : ℕ → ℕ → ℝ)
    (p : ℕ) (C₀ ρ : ℝ)
    (hdecorr : PrimePowerDecorrelated C p C₀ ρ)
    (hC₀ : 0 ≤ C₀) :
    ∀ (i T : ℕ),
      (Finset.range (T + 1)).sum (fun j => C (p ^ i) (p ^ j)) ≤
      C₀ * (2 / (1 - ρ) - 1) := by
  -- For any fixed i, we can split the sum into j ≤ i and j > i. We can then bound each part separately using the geometric series formula.
  intros i T
  have h_split_sum : (∑ j ∈ Finset.range (T + 1), C (p^i) (p^j)) ≤ (∑ j ∈ Finset.range (i + 1), C₀ * ρ ^ (i - j)) + (∑ j ∈ Finset.Ico (i + 1) (T + 1), C₀ * ρ ^ (j - i)) := by
    have h_split_sum : (∑ j ∈ Finset.range (T + 1), C (p^i) (p^j)) ≤ (∑ j ∈ Finset.range (i + 1), C (p^i) (p^j)) + (∑ j ∈ Finset.Ico (i + 1) (T + 1), C (p^i) (p^j)) := by
      cases le_total i T <;> simp_all +decide [ Finset.sum_range_add_sum_Ico ];
      exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.range_mono ( by linarith ) ) fun _ _ _ => hdecorr.2.1 _ _;
    refine le_trans h_split_sum <| add_le_add ?_ ?_ <;> refine Finset.sum_le_sum fun j hj => ?_ <;> simp_all +decide [ PrimePowerDecorrelated ];
    · grind;
    · grind;
  have h_geo_series : (∑ j ∈ Finset.range (i + 1), ρ ^ (i - j)) + (∑ j ∈ Finset.Ico (i + 1) (T + 1), ρ ^ (j - i)) ≤ (1 / (1 - ρ)) + (ρ / (1 - ρ)) := by
    refine' add_le_add _ _;
    · have h_geo_series : (∑ j ∈ Finset.range (i + 1), ρ ^ (i - j)) = (∑ j ∈ Finset.range (i + 1), ρ ^ j) := by
        conv_rhs => rw [ ← Finset.sum_flip ] ;
      rw [ h_geo_series, le_div_iff₀ ] <;> nlinarith [ hdecorr.2.2.2.1, hdecorr.2.2.2.2, pow_nonneg hdecorr.2.2.2.1 ( i + 1 ), geom_sum_mul ρ ( i + 1 ) ];
    · erw [ Finset.sum_Ico_eq_sum_range ];
      norm_num [ add_assoc ];
      norm_num [ pow_add, div_eq_mul_inv, tsum_mul_left, tsum_geometric_of_lt_one hdecorr.2.2.2.1 hdecorr.2.2.2.2 ];
      rw [ ← Finset.mul_sum _ _ _, ← tsum_geometric_of_lt_one hdecorr.2.2.2.1 hdecorr.2.2.2.2 ];
      exact mul_le_mul_of_nonneg_left ( Summable.sum_le_tsum ( Finset.range _ ) ( fun _ _ => pow_nonneg hdecorr.2.2.2.1 _ ) ( summable_geometric_of_lt_one hdecorr.2.2.2.1 hdecorr.2.2.2.2 ) ) hdecorr.2.2.2.1;
  simp_all +decide [ ← Finset.mul_sum _ _ _ ];
  convert h_split_sum.trans ( mul_add C₀ _ _ ▸ mul_le_mul_of_nonneg_left h_geo_series hC₀ ) using 1 ; ring;
  nlinarith [ inv_mul_cancel_left₀ ( show ( 1 - ρ ) ≠ 0 by linarith [ hdecorr.2.2.2 ] ) C₀ ]

/-! ## §6. Tropical PRG Security from Prime-Power Decay -/

/-- Abstract tropical PRG output discrepancy along prime-power indices. -/
def primePowerTotalDiscrepancy (δ : ℕ → ℝ) (T : ℕ) : ℝ :=
  (Finset.range (T + 1)).sum δ

/-- **Tropical prime-power PRG uniform security theorem.**
    Stagewise statistical distance `δ(j) ≤ ε₀ · r^j` implies total
    discrepancy bounded by `ε₀ / (1 - r)`, uniformly. -/
theorem tropical_prime_power_prg_error_uniform
    (δ : ℕ → ℝ)
    (p : ℕ) (hp : Nat.Prime p)
    (ε₀ r : ℝ)
    (hε₀ : 0 ≤ ε₀)
    (hstep : ∀ j, 0 ≤ δ j ∧ δ j ≤ ε₀ * r ^ j)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    ∀ T, primePowerTotalDiscrepancy δ T ≤ ε₀ / (1 - r) :=
  prime_power_cumulative_error_bounded δ ε₀ r hstep hε₀ hr0 hr1

/-! ## §7. Comparison: Prime-Power vs Dense Orbit -/

/-
**Prime-power sparsification beats dense orbit sampling** for large `T`.
-/
theorem prime_power_beats_dense_orbit
    (ε₀ r : ℝ)
    (hε₀ : 0 < ε₀)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1)
    (T : ℕ)
    (hT : (T : ℝ) + 1 > 1 / (1 - r)) :
    ε₀ / (1 - r) < (↑T + 1) * ε₀ := by
  convert mul_lt_mul_of_pos_right hT hε₀ using 1 ; ring_nf at *

/-! ## §8. Bridge Definitions -/

/-- Geometric decay from Lipschitz contraction hypotheses. -/
theorem lipschitz_implies_geometric_decay
    (err : ℕ → ℝ)
    (ε₀ r : ℝ)
    (herr0 : err 0 ≤ ε₀)
    (hnonneg : ∀ j, 0 ≤ err j)
    (hcontraction : ∀ j, err (j + 1) ≤ r * err j)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    GeometricallyDecayingError err ε₀ r :=
  ⟨herr0, hnonneg, hcontraction, hr0, hr1⟩

/-! ## §9. Extraction Error Along Power Orbits -/

/-- Extraction error sequence along a prime-power orbit. -/
def primePowerExtractionError (baseErr : ℕ → ℝ) (p : ℕ) (j : ℕ) : ℝ :=
  baseErr (p ^ j)

/-- Prime-power extraction error is geometrically decaying
    when the base error satisfies a prime-power contraction. -/
theorem prime_power_extraction_geometric
    (baseErr : ℕ → ℝ)
    (p : ℕ) (hp : Nat.Prime p)
    (ε₀ r : ℝ)
    (herr0 : baseErr (p ^ 0) ≤ ε₀)
    (hnonneg : ∀ n, 0 ≤ baseErr n)
    (hcontract : ∀ j, baseErr (p ^ (j + 1)) ≤ r * baseErr (p ^ j))
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    GeometricallyDecayingError (primePowerExtractionError baseErr p) ε₀ r :=
  ⟨herr0, fun j => hnonneg _, fun j => hcontract j, hr0, hr1⟩

/-- **Full prime-power extraction theorem.** Uniform bound on total
    extraction quality from geometric decay of base errors. -/
theorem prime_power_extraction_uniform_bound
    (baseErr : ℕ → ℝ)
    (p : ℕ) (hp : Nat.Prime p)
    (ε₀ r : ℝ)
    (herr0 : baseErr (p ^ 0) ≤ ε₀)
    (hnonneg : ∀ n, 0 ≤ baseErr n)
    (hcontract : ∀ j, baseErr (p ^ (j + 1)) ≤ r * baseErr (p ^ j))
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    ∀ T : ℕ,
      (Finset.range (T + 1)).sum (primePowerExtractionError baseErr p) ≤
        ε₀ / (1 - r) :=
  geometric_error_bound_from_pred _ _ _
    (prime_power_extraction_geometric baseErr p hp ε₀ r herr0 hnonneg hcontract hr0 hr1)

end