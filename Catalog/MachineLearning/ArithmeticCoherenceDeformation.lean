import Mathlib
import NumberTheory.LanglandsCoherenceTransition

/-!
# Deformation-stable arithmetic coherence thresholds

A threshold statistic and its response law play logically different roles.  The
arithmetic statistic determines whether activation occurs; a response function determines
only how strongly the active phase is expressed.  This separation is made exact here for
cyclotomic character counts.

For a threshold `c`, the nonnegative excess is `max (x-c) 0`.  Any response function that
vanishes exactly at zero therefore has the same activation boundary, independently of its
shape.  Continuous monotone response functions preserve continuity and monotonicity of the
resulting order parameter.  Power responses additionally satisfy an exact rescaling law,
which identifies their critical exponent without moving the boundary.

The arithmetic application uses the cyclotomic `GL(1)` character count from
`Catalog.NumberTheory.LanglandsCoherenceTransition`: at prime conductor `p`, activation is
unchanged by every zero-reflecting deformation and occurs exactly when `10001 < p`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the activation boundary of an arithmetic phase model is an
order-theoretic invariant, while the critical exponent belongs to the analytic response
law.  Thus every continuous monotone zero-reflecting deformation should preserve the
prime-conductor cutoff, and power responses should realize arbitrary positive exponents.

Experiment (Experimenter): the model was factored through the positive-part map
`x ↦ max (x-c) 0`.  First its zero set and monotonicity were isolated.  These statements
were then transported through an abstract response function.  Finally, the catalog's
cyclotomic character-count theorem converted the generic real threshold back to the exact
prime-conductor inequality.

Analysis (Analyst): zero reflection, rather than continuity or monotonicity, is the exact
hypothesis controlling the boundary.  Continuity and monotonicity instead control regularity
away from and across the threshold.  For a power response, translation by the threshold and
positive scaling give an exact homogeneity identity, so the exponent can vary independently
of the arithmetic cutoff.

Critique (Critic): regular variation by itself is not encoded as a primitive notion here;
the power-law subclass is treated exactly, while arbitrary response functions receive only
the boundary theorem justified by their hypotheses.  No empirical universality claim is
made.  The prime result depends on the established cyclotomic count and does not infer a
higher-rank correspondence.

Synthesis (Principal Investigator): the resulting hierarchy separates three reusable
layers: positive-part threshold geometry, abstract response-law invariance, and cyclotomic
arithmetic specialization.  It proves deformation stability of the existing arithmetic
phase diagram and an exact family of critical exponents.
-- !-- Lab Notes -- !--
-/

namespace ArithmeticCoherenceDeformation

open LanglandsCoherenceTransition MathematicsPhaseTransition

/-- The nonnegative excess of a statistic `x` above a threshold `c`. -/
def excess (c x : ℝ) : ℝ := max (x - c) 0

/-- The excess vanishes exactly on the inactive side of the threshold. -/
lemma excess_eq_zero_iff {c x : ℝ} : excess c x = 0 ↔ x ≤ c := by
  simp [excess]

/-- Increasing the statistic cannot decrease its threshold excess. -/
lemma monotone_excess (c : ℝ) : Monotone (excess c) := by
  exact fun x y hxy => max_le_max (by linarith) (le_refl 0)

/-- The threshold excess depends continuously on the statistic. -/
lemma continuous_excess (c : ℝ) : Continuous (excess c) := by
  unfold excess
  exact (continuous_id.sub continuous_const).max continuous_const

/-- A response law applied to threshold excess. -/
def deformedCoherence (F : ℝ → ℝ) (c x : ℝ) : ℝ := F (excess c x)

/-- Every zero-reflecting response law preserves the exact activation boundary. -/
theorem deformed_eq_zero_iff_le {F : ℝ → ℝ} {c x : ℝ}
    (hF : ∀ y, 0 ≤ y → (F y = 0 ↔ y = 0)) :
    deformedCoherence F c x = 0 ↔ x ≤ c := by
  unfold deformedCoherence excess
  constructor
  · intro h
    have := hF (max (x - c) 0) (le_max_right _ _) |>.mp h
    have h1 : max (x - c) 0 ≥ 0 := le_max_right _ _
    have h2 : max (x - c) 0 ≤ 0 → x ≤ c := fun hle => by linarith [le_max_left (x - c) 0]
    exact h2 (le_of_eq (le_antisymm this.le h1))
  · intro h
    simp [h, hF 0 (by norm_num)]

/-- A monotone response law produces a monotone deformed order parameter. -/
theorem monotone_deformedCoherence {F : ℝ → ℝ} (hF : Monotone F) (c : ℝ) :
    Monotone (deformedCoherence F c) := by
  intro x y hxy
  unfold deformedCoherence
  apply hF
  exact monotone_excess c hxy

/-- A continuous response law produces a continuous deformed order parameter. -/
theorem continuous_deformedCoherence {F : ℝ → ℝ} (hF : Continuous F) (c : ℝ) :
    Continuous (deformedCoherence F c) := by
  exact hF.comp (continuous_excess c)

/-- Power-law deformation with real exponent `α`. -/
noncomputable def powerCoherence (α c x : ℝ) : ℝ := (excess c x) ^ α

/-- Positive power responses preserve the threshold exactly. -/
theorem powerCoherence_eq_zero_iff_le {α c x : ℝ} (hα : 0 < α) :
    powerCoherence α c x = 0 ↔ x ≤ c := by
  unfold powerCoherence excess
  rw [Real.rpow_eq_zero_iff_of_nonneg (le_max_right _ _)]
  simp [hα.ne']

/-- Exact homogeneity above threshold: rescaling distance from criticality by `a > 0`
rescales a power response by `a^α`.  This is the precise critical-exponent law. -/
theorem powerCoherence_rescale {α c t a : ℝ} (ht : 0 < t) (ha : 0 < a) :
    powerCoherence α c (c + a * t) = a ^ α * powerCoherence α c (c + t) := by
  unfold powerCoherence excess
  simp only [add_sub_cancel_left]
  rw [max_eq_left (by nlinarith : 0 ≤ a * t)]
  rw [max_eq_left (le_of_lt ht)]
  rw [Real.mul_rpow (le_of_lt ha) (le_of_lt ht)]

/-- Every zero-reflecting deformation preserves the cyclotomic prime-conductor cutoff.
The response is inactive exactly for primes at most `10001`. -/
theorem prime_deformed_eq_zero_iff (F : ℝ → ℝ)
    (hF : ∀ y, 0 ≤ y → (F y = 0 ↔ y = 0))
    (p : ℕ) [Fact (Nat.Prime p)] (L : Type*) [Field L] [Algebra ℚ L]
    [IsCyclotomicExtension {p} ℚ L] :
    deformedCoherence F numberTheoryCriticalEdges (connectionCount p L : ℝ) = 0 ↔
      p ≤ 10001 := by
  rw [deformed_eq_zero_iff_le hF]
  rw [prime_connectionCount p L]
  norm_cast
  rw [Nat.sub_le_iff_le_add, numberTheoryCriticalEdges]

/-- Consequently every positive power exponent gives the same prime-conductor activation
boundary, while `powerCoherence_rescale` supplies its independently chosen exponent. -/
theorem prime_power_activation_iff (α : ℝ) (hα : 0 < α)
    (p : ℕ) [Fact (Nat.Prime p)] (L : Type*) [Field L] [Algebra ℚ L]
    [IsCyclotomicExtension {p} ℚ L] :
    0 < powerCoherence α numberTheoryCriticalEdges (connectionCount p L : ℝ) ↔
      10001 < p := by
  have h_nonneg : 0 ≤ powerCoherence α numberTheoryCriticalEdges (connectionCount p L : ℝ) := by
    unfold powerCoherence
    apply Real.rpow_nonneg
    unfold excess
    apply le_max_right
  rw [lt_iff_le_and_ne]
  simp only [h_nonneg, true_and]
  rw [Ne, eq_comm]
  rw [not_congr (powerCoherence_eq_zero_iff_le hα)]
  rw [not_le]
  norm_cast
  exact prime_above_threshold_iff p L

end ArithmeticCoherenceDeformation