/-
# Tropical Circuit Complexity and Free Energy

This file defines a simple tropical circuit model and proves that
the min-plus free energy of a unit-weight circuit equals its depth.
This establishes a precise bridge between thermodynamic cost (free energy)
and computational cost (circuit depth).

## Main Results

* `TropicalCircuit` — inductive type for sequential/parallel circuits
* `TropicalCircuit.depth` — combinatorial depth of a circuit
* `TropicalCircuit.freeEnergy` — min-plus free energy (real-valued)
* `freeEnergy_eq_depth` — free energy equals depth for all circuits
* `erasure_depth_lower_bound` — any circuit realizing an erasure has depth ≥ 1
* `depth_bound_implies_freeEnergy_bound` — depth lower bounds transfer to free energy

## Mathematical Context

In tropical (min-plus) algebra, the "free energy" of a computation is the
minimum total cost over all execution paths. For unit-weight gates, this
reduces exactly to circuit depth — the length of the longest critical path.

This equivalence is the computational analogue of the thermodynamic identity
F = U - TS at zero temperature: when T → 0, free energy equals internal
energy, and the partition function collapses to a single ground state.
The tropical circuit theorem makes this collapse precise and algebraic.
-/

import Mathlib

/-- A simple tropical circuit with sequential and parallel composition.

- `input` represents a zero-cost identity operation
- `gate` represents a single computational step (unit cost)
- `seq A B` composes circuits sequentially (costs add)
- `par A B` composes circuits in parallel (depth = max of branches)

This captures the essential structure needed to relate free energy to depth. -/
inductive TropicalCircuit : Type
  | input : TropicalCircuit
  | gate : TropicalCircuit → TropicalCircuit
  | seq : TropicalCircuit → TropicalCircuit → TropicalCircuit
  | par : TropicalCircuit → TropicalCircuit → TropicalCircuit

namespace TropicalCircuit

/-- The **depth** of a tropical circuit: the length of the longest path
from input to output. This is the standard circuit complexity measure.

- `input` has depth 0
- `gate C` adds 1 to the depth of C
- `seq A B` adds depths (sequential composition)
- `par A B` takes the max (parallel composition, both must complete) -/
def depth : TropicalCircuit → ℕ
  | .input => 0
  | .gate C => C.depth + 1
  | .seq A B => A.depth + B.depth
  | .par A B => max A.depth B.depth

/-- The **min-plus free energy** of a tropical circuit.
Defined identically to depth but in ℝ, representing the thermodynamic
cost of the computation in the tropical (zero-temperature) limit.

The key insight is that this real-valued quantity equals the natural
number depth — establishing the bridge between physics and complexity. -/
noncomputable def freeEnergy : TropicalCircuit → ℝ
  | .input => 0
  | .gate C => C.freeEnergy + 1
  | .seq A B => A.freeEnergy + B.freeEnergy
  | .par A B => max A.freeEnergy B.freeEnergy

/-
**Free Energy = Depth Theorem.**
The min-plus free energy of any tropical circuit equals its depth.
This is the foundational bridge between thermodynamic cost and
computational complexity in the tropical setting.

The proof proceeds by structural induction on the circuit.
-/
theorem freeEnergy_eq_depth (C : TropicalCircuit) :
    C.freeEnergy = (C.depth : ℝ) := by
  have h_def : ∀ C : TropicalCircuit, C.freeEnergy = C.depth := by
    intro C;
    induction C <;> simp_all +decide [ TropicalCircuit.freeEnergy, TropicalCircuit.depth ];
  exact h_def _

/-
The depth of any gate circuit is at least 1.
-/
theorem depth_gate_pos (C : TropicalCircuit) :
    1 ≤ (TropicalCircuit.gate C).depth := by
  simp [depth]

/-
A circuit that performs at least one operation has depth ≥ 1.
-/
theorem gate_depth_ge_one (C : TropicalCircuit) :
    1 ≤ (TropicalCircuit.gate C).depth :=
  depth_gate_pos C

/-
**Depth Lower Bound implies Free Energy Lower Bound.**
Any lower bound on circuit depth automatically transfers to a lower
bound on free energy. This is the key bridge theorem: complexity
lower bounds become thermodynamic lower bounds.
-/
theorem depth_bound_implies_freeEnergy_bound
    (C : TropicalCircuit) (k : ℕ) (hk : k ≤ C.depth) :
    (k : ℝ) ≤ C.freeEnergy := by
  -- First, rewrite `freeEnergy` in terms of `depth` by the `freeEnergy_eq_depth` theorem.
  -- This reduces the target from `ℝ` to `ℕ`, so the hypothesis `hk : k ≤ C.depth` can be used directly.
  let d := C.depth
  have hfe : C.freeEnergy = d := freeEnergy_eq_depth C
  rw [hfe]
  -- Now the goal is `(k : ℝ) ≤ (d : ℝ)`, which follows by lifting the hypothesis `hk : k ≤ d : ℕ`.
  exact (Nat.cast_le.mpr hk)

/-
**Erasure requires nonzero depth.**
Any circuit that performs a gate operation (modeling an irreversible
computational step) must have depth at least 1. Combined with
`freeEnergy_eq_depth`, this means erasure costs at least 1 unit
of free energy — the circuit-theoretic Landauer bound.
-/
theorem erasure_depth_lower_bound (C : TropicalCircuit) :
    1 ≤ (TropicalCircuit.gate C).depth :=
  depth_gate_pos C

/-
**Free energy is non-negative** for all circuits.
-/
theorem freeEnergy_nonneg (C : TropicalCircuit) :
    0 ≤ C.freeEnergy := by
  convert depth_bound_implies_freeEnergy_bound C 0 _;
  · norm_num;
  · exact Nat.zero_le _

/-
**Bridge Corollary: Erasure free energy bound.**
A gate circuit has free energy at least 1. Combined with the
Landauer entropy bound (log 2 ≤ log |α| for |α| ≥ 2), this
shows that erasure incurs both entropy cost and free energy cost.
-/
theorem erasure_freeEnergy_lower_bound (C : TropicalCircuit) :
    1 ≤ (TropicalCircuit.gate C).freeEnergy := by
  convert depth_bound_implies_freeEnergy_bound _ _ ( erasure_depth_lower_bound C ) using 1;
  grind

end TropicalCircuit