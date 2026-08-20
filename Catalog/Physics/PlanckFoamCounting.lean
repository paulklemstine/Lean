import Physics.PlanckFoamUniversal
import Physics.PlanckFoamEntropy

/-!
# Entropy–geometry duality: the foam's excess cardinality is its entropy budget

This file bridges the two halves of the Planck-foam theory developed so far:

* the **combinatorial** side, where `card_foam` counts the points of the foam,
  and
* the **information-theoretic** side, where `foamEntropy_eq` computes the
  Shannon entropy of the Bernoulli foam measure.

The bridge is the notion of **excess**: the number of points a foam has over and
above its macroscopic shadow,

`foamExcess = Nat.card (Foam X S ι) - Nat.card X = |S| * (|ι| - 1)`
(`card_foam_eq_card_add_excess`, `foamExcess_eq`),

i.e. exactly one extra point per branch point per extra sheet.  For two-sheeted
(Bool) foam the excess is the number of Planck branch points, and the main
theorem `foamEntropy_eq_log_two_pow_excess` states that the maximal-entropy
(`p = 1/2`) Bernoulli foam over a cell set `s` has entropy

`H = log (2 ^ excess)`,

the logarithm of the number of distinct foam geometries the branch bits can
produce.  Thus the "one bit per Planck cell" bound proved in
`Physics.PlanckFoamEntropy` is *exactly* the counting entropy of the skeleton
decomposition: geometry and information agree on the nose, with no `o(|X|)`
slack.
-/

open Finset

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι]
  [DiscreteTopology ι] {S : Set X}

/-! ### The excess cardinality of a foam -/

omit [DiscreteTopology ι] in
/-- **Excess counting formula.** A foam has exactly `|S| * (|ι| - 1)` more points
than its macroscopic shadow: one per branch point per extra sheet. -/
theorem card_foam_eq_card_add_excess [Finite X] [Finite ι] [Nonempty ι] :
    Nat.card (Foam X S ι) = Nat.card X + Nat.card S * (Nat.card ι - 1) := by
  have hsplit : Nat.card S + Nat.card (Sᶜ : Set X) = Nat.card X := by
    simpa [Nat.card_coe_set_eq] using Set.ncard_add_ncard_compl S
  obtain ⟨k, hk⟩ : ∃ k, Nat.card ι = k + 1 :=
    ⟨Nat.card ι - 1, (Nat.succ_pred_eq_of_pos Nat.card_pos).symm⟩
  rw [card_foam (S := S) (ι := ι), hk, Nat.add_sub_cancel]
  have hmul : Nat.card S * (k + 1) = Nat.card S * k + Nat.card S := Nat.mul_succ _ _
  omega

/-- The number of extra points a foam carries over its macroscopic shadow. -/
noncomputable def foamExcess (X : Type*) [TopologicalSpace X] (S : Set X)
    (ι : Type*) [TopologicalSpace ι] : ℕ :=
  Nat.card (Foam X S ι) - Nat.card X

omit [DiscreteTopology ι] in
theorem foamExcess_eq [Finite X] [Finite ι] [Nonempty ι] :
    foamExcess X S ι = Nat.card S * (Nat.card ι - 1) := by
  rw [foamExcess, card_foam_eq_card_add_excess (S := S) (ι := ι)]
  omega

omit [DiscreteTopology ι] in
/-- For two-sheeted foam the excess is precisely the number of Planck branch
points. -/
theorem foamExcess_bool [Finite X] : foamExcess X S Bool = Nat.card S := by
  simp [foamExcess_eq (S := S) (ι := Bool), Nat.card_eq_fintype_card]

/-! ### The entropy–geometry bridge -/

namespace Stochastic

variable {α : Type*} [DecidableEq α] [TopologicalSpace α] [Finite α]

omit [DecidableEq α] in
/-- The excess of the two-sheeted foam whose branch locus is the cell set `s`
is the number of cells. -/
theorem foamExcess_coe_finset (s : Finset α) :
    foamExcess α (↑s : Set α) Bool = s.card := by
  rw [foamExcess_bool]
  simp

/-- **Entropy–geometry duality.** The maximal-entropy (`p = 1/2`) Bernoulli foam
on the cell set `s` has Shannon entropy equal to the logarithm of `2` raised to
the excess cardinality of the corresponding two-sheeted foam: the entropy budget
of the foam is exactly the logarithm of the number of geometries its extra
points can realise. -/
theorem foamEntropy_eq_log_two_pow_excess (s : Finset α) :
    foamEntropy (1 / 2 : ℝ) s = Real.log (2 ^ foamExcess α (↑s : Set α) Bool) := by
  have h : foamEntropy (1 / 2 : ℝ) s = s.card * Real.log 2 := by
    rw [foamEntropy_eq (by norm_num) (by norm_num) s]
    rw [show (1 / 2 : ℝ) = 2⁻¹ by norm_num, Real.binEntropy_two_inv]
  rw [h, foamExcess_coe_finset s, Real.log_pow]

/-- Consequently the one-bit-per-cell bound is saturated exactly by the counting
entropy of the skeleton: no foam over the cell set `s` can carry more than
`log (2 ^ excess)` nats of Planck information. -/
theorem foamEntropy_le_log_two_pow_excess {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (s : Finset α) :
    foamEntropy p s ≤ Real.log (2 ^ foamExcess α (↑s : Set α) Bool) := by
  rw [← foamEntropy_eq_log_two_pow_excess s, foamEntropy_eq hp0 hp1 s,
    foamEntropy_eq (by norm_num) (by norm_num) s,
    show (1 / 2 : ℝ) = 2⁻¹ by norm_num, Real.binEntropy_two_inv]
  have hle : Real.binEntropy p ≤ Real.log 2 := Real.binEntropy_le_log_two
  have hcard : (0 : ℝ) ≤ (s.card : ℝ) := Nat.cast_nonneg _
  exact mul_le_mul_of_nonneg_left hle hcard

end Stochastic

end PlanckFoam