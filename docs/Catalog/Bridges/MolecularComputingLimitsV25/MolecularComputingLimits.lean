import Mathlib

/-!
# Molecular computing limits: exact finite-state CRN simulation and preparation cost

This file isolates two rigorous cores of the broad molecular-computing programme.

First, a chemical reaction network is given discrete mass-action semantics: a reaction
is enabled when every reactant count is available, and firing subtracts reactants and
adds products.  Every deterministic transition system on a finite configuration type
is compiled into unary reactions.  Starting from a one-hot molecular population, one
reaction exactly simulates one machine step; induction gives exact finite-trace
simulation and conservation of one-hot mass.

Second, an explicit cost model charges for preparing every molecular candidate.  If
one reaction round tests all prepared candidates in parallel, its elapsed time is
`p*n + 1`, versus `(p+1)*n` for sequential testing.  For positive preparation cost,
the sequential time is at most twice the molecular time.  Thus this model rules out
an exponential end-to-end speedup even though the reaction stage itself is fully
parallel.  This is a theorem about the stated cost model, not an empirical claim
about all laboratory implementations.

Finally, a bit-capacity model gives a description-length lower bound on volume.  It
makes precise the direction in which Kolmogorov complexity can constrain physical
volume, conditional on an encoding and a per-volume bit capacity.
-/

namespace MolecularComputingLimits

open Function

section CRNSimulation

variable {ι : Type*} [DecidableEq ι]

/-- A molecular population records the count of each species. -/
abbrev Population (ι : Type*) := ι → ℕ

/-- A discrete chemical reaction, represented by reactant and product stoichiometry. -/
structure Reaction (ι : Type*) where
  reactant : Population ι
  product : Population ι

/-- A reaction is enabled when all required reactants are present. -/
def Reaction.Enabled (r : Reaction ι) (x : Population ι) : Prop :=
  ∀ i, r.reactant i ≤ x i

/-- Discrete firing semantics: consume reactants and then produce products. -/
def Reaction.fire (r : Reaction ι) (x : Population ι) : Population ι :=
  fun i => x i - r.reactant i + r.product i

/-- The one-hot population encoding a single machine configuration. -/
def oneHot (q : ι) : Population ι := fun i => if i = q then 1 else 0

/-- Compile one deterministic transition `q ↦ next q` into a unary reaction. -/
def transitionReaction (next : ι → ι) (q : ι) : Reaction ι where
  reactant := oneHot q
  product := oneHot (next q)

/-- The compiled transition reaction is enabled at the corresponding one-hot state. -/
theorem transitionReaction_enabled (next : ι → ι) (q : ι) :
    (transitionReaction next q).Enabled (oneHot q) := by
  intro i
  exact le_refl _

/-- Firing a compiled unary reaction exactly performs one deterministic machine step. -/
theorem fire_transitionReaction (next : ι → ι) (q : ι) :
    (transitionReaction next q).fire (oneHot q) = oneHot (next q) := by
  ext i
  simp [Reaction.fire, transitionReaction, oneHot]

/-- One CRN step, selecting the reaction indexed by the represented configuration. -/
def compiledStep (next : ι → ι) (q : ι) (x : Population ι) : Population ι :=
  (transitionReaction next q).fire x

/-- The compiled CRN step commutes with the one-hot encoding. -/
theorem compiledStep_oneHot (next : ι → ι) (q : ι) :
    compiledStep next q (oneHot q) = oneHot (next q) := by
  exact fire_transitionReaction next q

/-- A recursively scheduled CRN execution that chooses the reaction for the current
machine configuration. -/
def runCompiled (next : ι → ι) : ℕ → ι → Population ι
  | 0, q => oneHot q
  | t + 1, q => compiledStep next ((next^[t]) q) (runCompiled next t q)

/-- Exact finite-trace simulation: after `t` reactions the molecular state is the
one-hot encoding of the machine configuration after `t` transitions. -/
theorem runCompiled_eq_oneHot_iterate (next : ι → ι) (q : ι) :
    ∀ t : ℕ, runCompiled next t q = oneHot ((next^[t]) q) := by
  intro t
  induction t with
  | zero => rfl
  | succ t ih =>
    simp [runCompiled, ih, compiledStep_oneHot, iterate_succ_apply']

/-- Consequently, the compiled execution always contains exactly one molecule.
This conservation law rules out hidden duplication in the finite-state simulation. -/
theorem runCompiled_total_mass [Fintype ι] (next : ι → ι) (q : ι) (t : ℕ) :
    ∑ i, runCompiled next t q i = 1 := by
  rw [runCompiled_eq_oneHot_iterate next q]
  simp [oneHot, Finset.sum_ite_eq']

end CRNSimulation

section PreparationCost

/-- End-to-end elapsed time for a fully parallel molecular search over `n` candidates:
preparation is charged `p` steps per candidate and all tests then take one round. -/
def molecularTime (p n : ℕ) : ℕ := p * n + 1

/-- Time for preparing and testing `n` candidates sequentially. -/
def sequentialTime (p n : ℕ) : ℕ := (p + 1) * n

/-- Positive per-candidate preparation cost dominates the number of candidates. -/
theorem candidates_le_preparation (p n : ℕ) (hp : 1 ≤ p) : n ≤ p * n := by
  nlinarith

/-- Charging preparation prevents the fully parallel model from beating sequential
search by more than a factor of two. -/
theorem sequentialTime_le_two_mul_molecularTime (p n : ℕ) (hp : 1 ≤ p) :
    sequentialTime p n ≤ 2 * molecularTime p n := by
  simp only [sequentialTime, molecularTime]
  have h := candidates_le_preparation p n hp
  linarith

/-- Equivalent multiplicative lower bound: molecular elapsed time is at least half
of sequential elapsed time. -/
theorem no_exponential_end_to_end_speedup (p n : ℕ) (hp : 1 ≤ p) :
    sequentialTime p n / 2 ≤ molecularTime p n := by
  apply Nat.div_le_of_le_mul
  simpa [Nat.mul_comm] using sequentialTime_le_two_mul_molecularTime p n hp

/-- The same constant-factor bound applies when the candidate space has size `2^k`,
as in exhaustive search over `k` Boolean choices. -/
theorem boolean_search_no_exponential_speedup (p k : ℕ) (hp : 1 ≤ p) :
    sequentialTime p (2 ^ k) / 2 ≤ molecularTime p (2 ^ k) := by
  exact no_exponential_end_to_end_speedup p (2 ^ k) hp

/-- A concrete ten-bit instance of the preceding general Boolean-search bound. -/
theorem ten_bit_search_bound :
    sequentialTime 1 (2 ^ 10) / 2 ≤ molecularTime 1 (2 ^ 10) := by
  exact boolean_search_no_exponential_speedup 1 10 (by omega)

/-- Concrete values used in the accompanying computational-evidence table. -/
theorem preparation_cost_small_cases :
    molecularTime 1 1 = 2 ∧ sequentialTime 1 1 = 2 ∧
    molecularTime 1 2 = 3 ∧ sequentialTime 1 2 = 4 ∧
    molecularTime 1 4 = 5 ∧ sequentialTime 1 4 = 8 ∧
    molecularTime 1 8 = 9 ∧ sequentialTime 1 8 = 16 := by
  norm_num [molecularTime, sequentialTime]

end PreparationCost

section DescriptionVolume

/-- A physical encoding with volume `v` and capacity `b` bits per volume unit can
carry a description of length `k` only if `k ≤ b*v`. -/
def FitsDescription (bitsPerVolume volume complexity : ℕ) : Prop :=
  complexity ≤ bitsPerVolume * volume

/-- Any volume fitting a description has the corresponding capacity lower bound. -/
theorem complexity_le_capacity {b v k : ℕ} (h : FitsDescription b v k) :
    k ≤ b * v := by
  exact h

/-- If capacity is at most `b` bits per volume unit, any implementation of description
complexity `k` needs enough volume that `k ≤ b*v`.  This is the precise, assumption-
explicit lower-bound direction behind complexity-versus-volume claims. -/
theorem description_volume_lower_bound {b v k : ℕ}
    (hfit : FitsDescription b v k) : k ≤ b * v := by
  exact complexity_le_capacity hfit

/-- The information-theoretic minimum volume at capacity `b` is ceiling division. -/
def minimumVolume (bitsPerVolume complexity : ℕ) : ℕ :=
  complexity ⌈/⌉ bitsPerVolume

/-- Any feasible implementation occupies at least the ceiling of description length
divided by bit capacity. -/
theorem minimumVolume_le_of_fits {b v k : ℕ} (hb : 0 < b)
    (hfit : FitsDescription b v k) : minimumVolume b k ≤ v := by
  apply (ceilDiv_le_iff_le_mul hb).2
  exact complexity_le_capacity hfit

/-- Increasing available volume preserves feasibility of an encoded computation. -/
theorem fitsDescription_mono_volume {b v₁ v₂ k : ℕ}
    (hfit : FitsDescription b v₁ k) (hv : v₁ ≤ v₂) :
    FitsDescription b v₂ k := by
  exact hfit.trans (Nat.mul_le_mul_left b hv)

end DescriptionVolume

end MolecularComputingLimits