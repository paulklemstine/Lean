import Mathlib

/-!
# Molecular computing limits: a contrarian finite-state formalization

This file separates theorem-level consequences of explicit models from empirical
claims.  A discrete mass-action CRN exactly simulates every finite deterministic
transition system using one species per configuration and one unary reaction per
transition.  This supplies the finite-trace compiler underlying CRN universality,
but does not identify finite-state simulation with a finite universal Turing machine.

The resource results prove an exact ceiling-division volume law and a constant-factor
end-to-end parallel-search bound when candidate preparation is charged.  Two overly
bold variants are disproved: exact integral proportionality fails because of rounding,
and the constant-factor bound fails when preparation is free.  Finally, storage
capacity alone is shown not to imply any throughput ceiling or throughput guarantee.
-/

namespace MolecularComputingV26

open Function
open scoped BigOperators

section CRN

variable {ι : Type*} [DecidableEq ι]

/-- A population is a molecule count for every species. -/
abbrev Population (ι : Type*) := ι → ℕ

/-- Reactant and product stoichiometry of a discrete reaction. -/
structure Reaction (ι : Type*) where
  reactant : Population ι
  product : Population ι

/-- A reaction is enabled when all reactants are available. -/
def Reaction.Enabled (r : Reaction ι) (x : Population ι) : Prop :=
  ∀ i, r.reactant i ≤ x i

/-- Fire a reaction by consuming reactants and producing products. -/
def Reaction.fire (r : Reaction ι) (x : Population ι) : Population ι :=
  fun i => x i - r.reactant i + r.product i

/-- One molecule of species `q` and no other molecules. -/
def oneHot (q : ι) : Population ι := fun i => if i = q then 1 else 0

/-- Compile transition `q ↦ next q` to the unary reaction `q → next q`. -/
def transitionReaction (next : ι → ι) (q : ι) : Reaction ι where
  reactant := oneHot q
  product := oneHot (next q)

/-- Firing the compiled source reaction performs exactly one machine transition. -/
theorem fire_transitionReaction (next : ι → ι) (q : ι) :
    (transitionReaction next q).fire (oneHot q) = oneHot (next q) := by
  ext i
  simp [Reaction.fire, transitionReaction, oneHot]

/-- Scheduled execution of the compiled reactions. -/
def runCompiled (next : ι → ι) : ℕ → ι → Population ι
  | 0, q => oneHot q
  | t + 1, q => (transitionReaction next ((next^[t]) q)).fire (runCompiled next t q)

/-- **Finite-state CRN universality.** Every finite trace of every deterministic
transition system is exactly reproduced by its compiled unary CRN. -/
theorem crn_exact_finite_trace (next : ι → ι) (q : ι) :
    ∀ t : ℕ, runCompiled next t q = oneHot ((next^[t]) q) := by
  intro t
  induction t with
  | zero => rfl
  | succ t ih =>
    simp only [runCompiled, ih]
    rw [fire_transitionReaction, iterate_succ_apply']

/-- Discrete stochastic mass-action propensity, using falling factorials. -/
def massActionPropensity [Fintype ι]
    (rate : ℕ) (r : Reaction ι) (x : Population ι) : ℕ :=
  rate * ∏ i, (x i).descFactorial (r.reactant i)

/-- At its one-hot source, a compiled unary reaction has exactly its kinetic rate. -/
theorem compiled_massAction_rate [Fintype ι]
    (rate : ℕ) (next : ι → ι) (q : ι) :
    massActionPropensity rate (transitionReaction next q) (oneHot q) = rate := by
  simp only [massActionPropensity, transitionReaction, oneHot]
  have hprod : ∏ i : ι, (if i = q then 1 else 0).descFactorial
      (if i = q then 1 else 0) = 1 := by
    apply Finset.prod_eq_one
    intro i hi
    by_cases h : i = q <;> simp [h]
  rw [hprod, Nat.mul_one]

/-- The one-hot execution conserves exactly one molecule, so simulation does not
hide exponential molecular duplication. -/
theorem compiled_trace_mass_one [Fintype ι]
    (next : ι → ι) (q : ι) (t : ℕ) :
    ∑ i, runCompiled next t q i = 1 := by
  rw [crn_exact_finite_trace]
  simp [oneHot, Finset.sum_ite_eq']

end CRN

section Volume

/-- A `k`-bit description fits volume `v` at density `b` when `k ≤ b*v`. -/
def FitsDescription (bitsPerVolume volume complexity : ℕ) : Prop :=
  complexity ≤ bitsPerVolume * volume

/-- Information-theoretic minimum volume at fixed bit density. -/
def minimumVolume (bitsPerVolume complexity : ℕ) : ℕ :=
  complexity ⌈/⌉ bitsPerVolume

/-- The ceiling-division model gives an exact feasibility characterization. -/
theorem minimumVolume_iff_fits {b k v : ℕ} (hb : 0 < b) :
    minimumVolume b k ≤ v ↔ FitsDescription b v k := by
  exact ceilDiv_le_iff_le_mul hb

/-- At unit density, minimum volume is exactly description complexity. -/
theorem unit_density_exact_proportionality (k : ℕ) :
    minimumVolume 1 k = k := by
  simp [minimumVolume]

/-- **Disproof of an overstrong proportionality claim.** At density two there is no
natural constant `c` for which minimum volume equals `c*k` for every complexity.
Ceiling effects at complexities one and two already contradict it. -/
theorem no_exact_integral_proportionality_density_two :
    ¬ ∃ c : ℕ, ∀ k : ℕ, minimumVolume 2 k = c * k := by
  rintro ⟨c, hc⟩
  have hv1 : minimumVolume 2 1 = 1 := by decide
  have hv2 : minimumVolume 2 2 = 1 := by decide
  have h1 := hc 1
  have h2 := hc 2
  rw [hv1] at h1
  rw [hv2] at h2
  omega

/-- Nevertheless the claimed asymptotic relationship has sharp elementary bounds:
`k ≤ b * minimumVolume b k`, while rounding wastes less than one volume unit. -/
theorem minimumVolume_two_sided {b k : ℕ} (hb : 0 < b) :
    k ≤ b * minimumVolume b k ∧ minimumVolume b k ≤ k + 1 := by
  constructor
  · exact le_smul_ceilDiv hb
  · apply (ceilDiv_le_iff_le_mul hb).2
    nlinarith

/-- `k` two-state molecular units can represent exactly `2^k` states. -/
theorem boolean_register_state_count (k : ℕ) :
    Fintype.card (Fin k → Bool) = 2 ^ k := by
  simp

/-- The numerical storage claim, treated as a bit-count premise, corresponds to
`2^(10^18)` Boolean states; this theorem does not assert physical attainability. -/
theorem claimed_dna_register_state_count :
    Fintype.card (Fin (10 ^ 18) → Bool) = 2 ^ (10 ^ 18) := by
  simp

end Volume

section Parallelism

/-- End-to-end molecular-search time: prepare `n` candidates at cost `p` each,
then test all candidates in one parallel round. -/
def molecularTime (p n : ℕ) : ℕ := p * n + 1

/-- Prepare and test the same candidates sequentially. -/
def sequentialTime (p n : ℕ) : ℕ := (p + 1) * n

/-- **No exponential end-to-end speedup in the charged-preparation model.**
Sequential search costs at most twice molecular search. -/
theorem charged_preparation_constant_factor (p n : ℕ) (hp : 1 ≤ p) :
    sequentialTime p n ≤ 2 * molecularTime p n := by
  simp only [sequentialTime, molecularTime]
  have hn : n ≤ p * n := by nlinarith
  linarith

/-- The same bound applies to an exponential Boolean candidate space. -/
theorem boolean_search_constant_factor (p variableCount : ℕ) (hp : 1 ≤ p) :
    sequentialTime p (2 ^ variableCount) ≤ 2 * molecularTime p (2 ^ variableCount) := by
  exact charged_preparation_constant_factor p (2 ^ variableCount) hp

/-- **Counterexample showing the preparation hypothesis is essential.** If candidate
preparation is free, even three candidates violate the factor-two conclusion. -/
theorem free_preparation_refutes_uniform_factor_two :
    2 * molecularTime 0 3 < sequentialTime 0 3 := by
  norm_num [molecularTime, sequentialTime]

/-- Machine-checked small cases for one unit of preparation cost. -/
theorem preparation_small_cases :
    molecularTime 1 (2 ^ 0) = 2 ∧ sequentialTime 1 (2 ^ 0) = 2 ∧
    molecularTime 1 (2 ^ 1) = 3 ∧ sequentialTime 1 (2 ^ 1) = 4 ∧
    molecularTime 1 (2 ^ 2) = 5 ∧ sequentialTime 1 (2 ^ 2) = 8 ∧
    molecularTime 1 (2 ^ 3) = 9 ∧ sequentialTime 1 (2 ^ 3) = 16 ∧
    molecularTime 1 (2 ^ 4) = 17 ∧ sequentialTime 1 (2 ^ 4) = 32 ∧
    molecularTime 1 (2 ^ 5) = 33 ∧ sequentialTime 1 (2 ^ 5) = 64 ∧
    molecularTime 1 (2 ^ 6) = 65 ∧ sequentialTime 1 (2 ^ 6) = 128 ∧
    molecularTime 1 (2 ^ 7) = 129 ∧ sequentialTime 1 (2 ^ 7) = 256 := by
  norm_num [molecularTime, sequentialTime]

end Parallelism

section ThroughputIndependence

/-- A deliberately minimal physical specification separating storage and throughput. -/
structure DeviceSpec where
  storageBits : ℕ
  operationsPerSecond : ℕ

/-- Storage capacity alone permits every throughput value in this abstract model. -/
theorem storage_does_not_determine_throughput (throughput : ℕ) :
    ∃ d : DeviceSpec,
      d.storageBits = 10 ^ 18 ∧ d.operationsPerSecond = throughput := by
  exact ⟨⟨10 ^ 18, throughput⟩, rfl, rfl⟩

/-- In particular, the `10^18`-bit premise is compatible both with zero throughput
and with the conjectured `10^15` operations per second, so an empirical kinetic
premise is indispensable. -/
theorem same_storage_radically_different_throughput :
    ∃ slow fast : DeviceSpec,
      slow.storageBits = 10 ^ 18 ∧ fast.storageBits = 10 ^ 18 ∧
      slow.operationsPerSecond = 0 ∧ fast.operationsPerSecond = 10 ^ 15 := by
  exact ⟨⟨10 ^ 18, 0⟩, ⟨10 ^ 18, 10 ^ 15⟩, rfl, rfl, rfl, rfl⟩

end ThroughputIndependence

end MolecularComputingV26