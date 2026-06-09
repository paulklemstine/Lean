/-
# Entropy-Bounded Computation: Foundations

This file defines the core structures of the Entropy-Bounded Computation (EBC)
framework, which formalizes the connection between computational complexity
and thermodynamics through Landauer's principle.

## Core Structures

* `LandauerCost` — The thermodynamic cost model based on Landauer's principle
* `EntropyBudgetSystem` — A computation with a finite entropy budget
* `IrreversibleStep` — A single bit-erasing computational step
* `ReversibleComputation` — A bijective (entropy-preserving) computation
* `MaxwellDemon` — An agent that must pay entropy cost for information gained

## Key Insight

The central observation is that every irreversible computational step (one that
erases information) has a minimum thermodynamic cost of kT·ln(2) per bit erased
(Landauer's principle). This creates a resource theory where the total entropy
budget constrains the number of irreversible operations a computation can perform.
-/

import Mathlib

open Real Finset BigOperators

namespace EBC

/-! ## Landauer Cost Model -/

/-- Parameters for the Landauer cost model. The `tempFactor` represents kT·ln(2),
the minimum energy dissipated per bit erased at temperature T. -/
structure LandauerParams where
  /-- The Landauer cost per bit: kT · ln(2). Must be positive. -/
  tempFactor : ℝ
  tempFactor_pos : 0 < tempFactor

/-- An irreversible computational step that erases `bitsErased` bits of information.
The Landauer cost is `bitsErased * kT * ln(2)`. -/
structure IrreversibleStep (params : LandauerParams) where
  /-- Number of bits erased by this step (≥ 0) -/
  bitsErased : ℝ
  bitsErased_nonneg : 0 ≤ bitsErased

/-- The Landauer cost of a single irreversible step -/
noncomputable def IrreversibleStep.cost (params : LandauerParams)
    (step : IrreversibleStep params) : ℝ :=
  step.bitsErased * params.tempFactor

/-- A sequence of irreversible computational steps -/
structure StepSequence (params : LandauerParams) where
  /-- Number of steps -/
  numSteps : ℕ
  /-- The steps, indexed by Fin numSteps -/
  steps : Fin numSteps → IrreversibleStep params

/-- Total cost of a step sequence -/
noncomputable def StepSequence.totalCost (params : LandauerParams)
    (seq : StepSequence params) : ℝ :=
  ∑ i : Fin seq.numSteps, (seq.steps i).cost params

/-! ## Entropy Budget System -/

/-- An entropy budget system constrains a computation by limiting the total
entropy (information) that can be erased. The budget represents the maximum
total Landauer cost the computation can incur. -/
structure EntropyBudgetSystem where
  /-- The Landauer parameters (temperature, etc.) -/
  params : LandauerParams
  /-- The total entropy budget (in energy units) -/
  budget : ℝ
  budget_nonneg : 0 ≤ budget

/-- The maximum number of single-bit erasures affordable under the budget -/
noncomputable def EntropyBudgetSystem.maxSteps (ebs : EntropyBudgetSystem) : ℝ :=
  ebs.budget / ebs.params.tempFactor

/-! ## Reversible Computation -/

/-- A reversible computation on a type α is a bijection. Reversible computations
have zero Landauer cost because they erase no information. -/
structure ReversibleComputation (α : Type*) where
  /-- The forward computation -/
  forward : α → α
  /-- The inverse computation -/
  backward : α → α
  /-- Forward then backward is identity -/
  left_inv : ∀ x, backward (forward x) = x
  /-- Backward then forward is identity -/
  right_inv : ∀ x, forward (backward x) = x

/-! ## Maxwell's Demon -/

/-- A Maxwell's demon is an information-processing agent that must pay entropy
cost for the information it acquires. The demon performs `measurements` each
erasing one bit, at a cost of kT·ln(2) per measurement. -/
structure MaxwellDemon (params : LandauerParams) where
  /-- Number of measurements (bits of information acquired) -/
  measurements : ℕ
  /-- The demon's memory is finite -/
  memoryBits : ℕ
  /-- Demon can't gain more information than its memory holds -/
  memory_bound : measurements ≤ memoryBits

/-- The entropy cost of a Maxwell's demon's operation -/
noncomputable def MaxwellDemon.entropyCost (params : LandauerParams)
    (demon : MaxwellDemon params) : ℝ :=
  demon.measurements * params.tempFactor

/-! ## Complexity-Entropy Duality -/

/-- A search problem of size n requires exploring a space of size `searchSpace n`.
The entropy cost is determined by how many bits must be erased during the search. -/
structure SearchProblem where
  /-- The search space size as a function of input length -/
  searchSpace : ℕ → ℕ
  /-- The search space is always nonempty -/
  searchSpace_pos : ∀ n, 0 < searchSpace n

end EBC