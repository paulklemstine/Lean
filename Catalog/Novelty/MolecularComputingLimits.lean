import Bridges.MolecularComputingLimitsV25.MolecularComputingLimits
import Applications.MolecularComputing.StorageCapacity

/-!
# Molecular computation: universality, capacity, and preparation bounds

This file builds on the catalog's discrete CRN semantics and information-theoretic
storage model.  The results deliberately separate mathematical consequences of an
explicit model from empirical density and reaction-rate claims.

The universality result is an exact compiler theorem: for the transition function of
any deterministic machine (including a Turing machine configuration transition), the
compiled unary CRN follows every finite execution trace.  This is the standard precise
sense in which the reaction formalism simulates the machine; it does not assert that a
particular laboratory chemistry realizes an infinite species family.
-/

namespace MolecularComputingNovelty

open MolecularComputingLimits
open scoped BigOperators

section MassAction

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Discrete stochastic mass-action propensity, using falling factorials for the
number of available reactant tuples. -/
def massActionPropensity (rate : ℕ) (r : Reaction ι) (x : Population ι) : ℕ :=
  rate * ∏ i, (x i).descFactorial (r.reactant i)

/-- A compiled unary transition has exactly its rate as propensity at the one-hot
population representing its source configuration. -/
theorem transition_massActionPropensity (rate : ℕ) (next : ι → ι) (q : ι) :
    massActionPropensity rate (transitionReaction next q) (oneHot q) = rate := by
  simp only [massActionPropensity, transitionReaction, oneHot]
  have hprod : ∏ i : ι, (if i = q then 1 else 0).descFactorial
      (if i = q then 1 else 0) = 1 := by
    apply Finset.prod_eq_one
    intro i hi
    by_cases h : i = q <;> simp [h]
  rw [hprod, Nat.mul_one]

/-- At a one-hot source, the compiled reaction is both enabled and has positive
mass-action propensity whenever its kinetic rate is positive. -/
theorem enabled_and_positive_propensity (rate : ℕ) (hrate : 0 < rate)
    (next : ι → ι) (q : ι) :
    (transitionReaction next q).Enabled (oneHot q) ∧
      0 < massActionPropensity rate (transitionReaction next q) (oneHot q) := by
  constructor
  · exact transitionReaction_enabled next q
  · simpa [transition_massActionPropensity] using hrate

end MassAction

section Universality

variable {Configuration Output : Type*} [DecidableEq Configuration]

/-- Exact finite-trace simulation for an arbitrary deterministic machine transition.
Instantiating `Configuration` with a Turing machine's instantaneous descriptions and
`step` with its transition function gives the CRN simulation theorem. -/
theorem crn_simulates_deterministic_machine
    (step : Configuration → Configuration) (initial : Configuration) (time : ℕ) :
    runCompiled step time initial = oneHot ((step^[time]) initial) := by
  exact runCompiled_eq_oneHot_iterate step initial time

/-- Simulation preserves every decoded observation of the machine state.  Thus a
halting/output decoder reads the same answer from the CRN trace and machine trace. -/
theorem crn_preserves_decoded_output
    (step : Configuration → Configuration) (decode : Configuration → Output)
    (initial : Configuration) (time : ℕ) :
    (∃ q, runCompiled step time initial = oneHot q ∧ decode q = decode ((step^[time]) initial)) := by
  refine ⟨(step^[time]) initial, ?_, rfl⟩
  exact runCompiled_eq_oneHot_iterate step initial time

/-- If a machine reaches a fixed halting configuration, every later compiled CRN
trace remains at the corresponding one-hot population. -/
theorem crn_preserves_halting
    (step : Configuration → Configuration) (halt : Configuration)
    (hhalt : step halt = halt) (time : ℕ) :
    runCompiled step time halt = oneHot halt := by
  rw [runCompiled_eq_oneHot_iterate]
  congr 1
  induction time with
  | zero => rfl
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih, hhalt]

end Universality

section DescriptionVolume

/-- At positive bit density, ceiling division is the exact minimum volume: it has
sufficient capacity. -/
theorem minimumVolume_fits {bitsPerVolume complexity : ℕ} (hbits : 0 < bitsPerVolume) :
    FitsDescription bitsPerVolume (minimumVolume bitsPerVolume complexity) complexity := by
  exact le_smul_ceilDiv hbits

/-- The exact minimum volume is characterized by feasibility and minimality. -/
theorem minimumVolume_iff {bitsPerVolume complexity volume : ℕ}
    (hbits : 0 < bitsPerVolume) :
    minimumVolume bitsPerVolume complexity ≤ volume ↔
      FitsDescription bitsPerVolume volume complexity := by
  exact ceilDiv_le_iff_le_mul hbits

/-- No strictly smaller volume can fit the same description. -/
theorem smaller_than_minimumVolume_does_not_fit
    {bitsPerVolume complexity volume : ℕ} (hbits : 0 < bitsPerVolume)
    (hsmall : volume < minimumVolume bitsPerVolume complexity) :
    ¬ FitsDescription bitsPerVolume volume complexity := by
  intro hfit
  exact (Nat.not_le_of_lt hsmall) (minimumVolume_le_of_fits hbits hfit)

/-- With one bit per volume unit, minimum physical volume equals description length
exactly.  This is a rigorous proportionality theorem under the explicit unit-capacity
model, rather than an unconditional physical claim about Kolmogorov complexity. -/
theorem unit_density_volume_eq_complexity (complexity : ℕ) :
    minimumVolume 1 complexity = complexity := by
  simp [minimumVolume]

/-- A register advertised as holding `10^18` bits has `2^(10^18)` possible Boolean
states in the catalog's bit-register model.  This theorem records the mathematical
content of the capacity figure without asserting its empirical premise. -/
theorem dna_10e18_bit_state_count :
    Fintype.card (Fin (10 ^ 18) → Bool) = 2 ^ (10 ^ 18) := by
  simp

end DescriptionVolume

section MolecularParallelism

/-- Even for an exponentially large Boolean candidate space, charged preparation
makes sequential elapsed time at most twice molecular elapsed time. -/
theorem molecular_sat_search_constant_factor
    (preparationCost variableCount : ℕ) (hcost : 1 ≤ preparationCost) :
    sequentialTime preparationCost (2 ^ variableCount) ≤
      2 * molecularTime preparationCost (2 ^ variableCount) := by
  exact sequentialTime_le_two_mul_molecularTime preparationCost (2 ^ variableCount) hcost

/-- Preparation alone is a linear lower bound on molecular elapsed time. -/
theorem preparation_is_linear_lower_bound (preparationCost candidates : ℕ) :
    preparationCost * candidates ≤ molecularTime preparationCost candidates := by
  simp [molecularTime]

/-- The claimed `10^15` operations/second follows only conditionally from a model
performing that many operations in one second; no empirical chemistry premise is
smuggled into the theorem. -/
theorem conditional_dna_throughput
    (operations elapsedSeconds : ℕ)
    (hops : operations = 10 ^ 15) (htime : elapsedSeconds = 1) :
    operations = (10 ^ 15) * elapsedSeconds := by
  omega

/-- Checked small cases for the preparation-cost model. -/
theorem preparation_evidence :
    molecularTime 1 (2 ^ 0) = 2 ∧ sequentialTime 1 (2 ^ 0) = 2 ∧
    molecularTime 1 (2 ^ 1) = 3 ∧ sequentialTime 1 (2 ^ 1) = 4 ∧
    molecularTime 1 (2 ^ 2) = 5 ∧ sequentialTime 1 (2 ^ 2) = 8 ∧
    molecularTime 1 (2 ^ 3) = 9 ∧ sequentialTime 1 (2 ^ 3) = 16 ∧
    molecularTime 1 (2 ^ 4) = 17 ∧ sequentialTime 1 (2 ^ 4) = 32 ∧
    molecularTime 1 (2 ^ 5) = 33 ∧ sequentialTime 1 (2 ^ 5) = 64 ∧
    molecularTime 1 (2 ^ 6) = 65 ∧ sequentialTime 1 (2 ^ 6) = 128 ∧
    molecularTime 1 (2 ^ 7) = 129 ∧ sequentialTime 1 (2 ^ 7) = 256 := by
  norm_num [molecularTime, sequentialTime]

end MolecularParallelism

end MolecularComputingNovelty