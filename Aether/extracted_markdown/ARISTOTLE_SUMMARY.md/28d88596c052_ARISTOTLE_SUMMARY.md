# Summary of changes for run 06e7a400-d741-42f8-83fc-401b9316b8ab
## Completed: Self-Modifying Computation and the Halting Problem

Created `Computation/SelfModifyingHalt.lean` — a fully verified Lean 4 formalization (403 lines, 0 sorries, clean build with no warnings).

### Mathematical Content

The file formalizes self-modifying computation and proves that the halting problem for self-modifying programs is **equivalent to** (not strictly harder than) the classical halting problem. This corrects the folk intuition stated in the concept description.

### Key Definitions
- `SelfModMachine P S` — a machine whose program (type `P`) can change at each step
- `StdMachine S` — a standard fixed-program machine
- `SelfModMachine.toStd` — the standard simulation that encodes the program into the state
- `ManyOneReduces` — many-one reducibility between predicates

### Proved Theorems (all with full PEGB: Proof, Example, Generalization, Boundary)

**Section 1 — Abstract Diagonalization:**
- `diagonal_no_decider` — Cantor's diagonal argument: no surjection `α → (α → Bool)` exists
- `diagonal_no_decider_general` — generalization to any type with ≥ 2 elements

**Section 3 — Simulation:**
- `selfmod_run_eq_std_run` — step-by-step behavioral equivalence of self-mod and standard runs
- `selfmod_steps_eq_std_steps` — halting at step n is preserved by simulation
- `selfmod_halts_iff_standard` — **main simulation theorem**: self-mod halts ↔ standard simulation halts

**Section 4 — Undecidability:**
- `no_selfmod_decider_of_no_std_decider` — undecidability transfers from standard to self-modifying

**Section 5 — Equivalence:**
- `selfmod_halting_reduces_to_standard` — forward many-one reduction (≤₁)
- `standard_halting_reduces_to_selfmod` — reverse many-one reduction
- `selfmod_halting_turing_equiv` — mutual reducibility (equivalence)
- `many_one_equiv_not_pointwise` — many-one equivalence ≠ pointwise equality

**Section 6 — Virus Paradox:**
- `virus_paradox` — Rice's theorem for self-modifying machines: no nontrivial behavioral property is decidable

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).