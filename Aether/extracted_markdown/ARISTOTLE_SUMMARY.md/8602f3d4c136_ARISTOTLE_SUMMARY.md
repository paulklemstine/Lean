# Summary of changes for run aeb56d7a-20f4-4b66-a164-581bcfac6c9a
Added a new cross-domain bridge file `Catalog/Bridges/NeuralSimulationPreorder.lean` plus `FUTURE_DIRECTIONS.md`.

## What was built
The file connects the catalog's coalgebraic neural semantics (`Bridges/CoalgebraicNeuralMyhillNerode.lean`: `NeuralObservationSystem`, `neural_behavior`, `NeuralHom`, `neural_hom_preserves_behavior`) with the Cook–Reckhow proof-complexity preorder (`Logic/ProofComplexity/SimulationPreorder.lean`: `ProofComplexity.Simulates`, `ProofSystem`, and the lattice study `isGLB_sumSystem` in `DegreeLattice.lean`).

The unifying device is an abstract **coverage relation** `Covers vA vB := ∀ b, ∃ a, vA a = vB b` (equivalently reverse range inclusion), bundled as a genuine `Preorder` (`coveragePreorder`) and `Setoid` (`vpEquivSetoid`).

## Main theorems (all proofs complete, `sorry = 0`, axioms ⊆ {propext, Classical.choice, Quot.sound})
- `nsimulates_iff_vcovers` / `nsimulates_iff`: neural trace-simulation `NSimulates` is *definitionally* coverage of the trace maps; hence a preorder (`neuralSimulationPreorder`).
- `nhom_nsimulates`: behaviour-preserving `NeuralHom`s induce simulation witnesses (codomain simulates domain).
- `npequiv_iff_range_eq`: bisimulation / behaviour-set equality is exactly mutual simulation (antisymmetry on degrees).
- `nsum_isGLB`: the neural coproduct `nsum` is the greatest lower bound of `{S,T}` in the simulation preorder — the neural mirror of the catalog's `isGLB_sumSystem`.
- `simulates_imp_covers` / `coverage_bridge`: the size-forgetful bridge — Cook–Reckhow `p`-simulation *refines* coverage, so both domains live in one abstract preorder (neural simulation *equals* coverage; proof simulation *strictly stronger* via the polynomial size bound).

The key conceptual finding (recorded in the in-file Lab Notebook): the honest common denominator is *range inclusion of a value map*, not proof size — in proof complexity the coverage layer is trivial (completeness) and content lives in `size`, whereas in neural systems there is no size and all content lives in coverage. A naive attempt to force neural systems into `ProofSystem` collapses because `complete` forces surjectivity; bridging at the coverage layer is what makes it work.

## Deliverables
- Lean file with the theorems above, concise `-- !-- comment -- !--` proof sketches, and a `-- !-- Lab Notebook -- !--` block (Hypothesis/Result/Insight/Failure analysis).
- `FUTURE_DIRECTIONS.md`: synthesis, results summary, and 5 falsifiable conjectures (size-graded neural simulation, a Fibonacci-style neural separation, full lattice via a trace-product join, faithful-but-not-full functor characterization, and a weighted/semiring quantitative coverage preorder), each with a "key insight" and "Why now?" justification.

## Build status
The new module builds cleanly on its own (`lake build Bridges.NeuralSimulationPreorder`: built, 0 errors/warnings, no `sorry`). Note: the project's whole-default-target build fails for a pre-existing, unrelated reason (a default target references a missing file `Algebra/Jacobian/Defs.lean`); this was present before and is independent of the added file. The correct Lean package root is the `Catalog/` subdirectory.