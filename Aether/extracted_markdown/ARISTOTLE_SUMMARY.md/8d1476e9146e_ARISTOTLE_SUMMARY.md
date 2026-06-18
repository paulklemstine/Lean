# Summary of changes for run f1e8e3a0-9dde-462b-8b92-8deaadd0e4c2
## Phase A deliverable: Quantitative formalization of the Razborov–Rudich natural proofs barrier

I added a new, fully proved (no `sorry`) Lean file and a research-directions document.

### New file: `Catalog/Computation/NaturalProofsBarrier.lean`
This extends the existing catalog skeletons — the natural-proofs template in `Computation/BarrierFramework.lean` (`natural_proof_distinguisher`, `IsLargeProperty`, `IsUsefulAgainst`) and the relativization/algebrization barriers in `Computation/CircuitBarriers.lean` — by supplying the *actual quantitative distinguisher* those skeletons only gestured at.

It models a property `P` on a finite universe of truth tables `F` as a statistical test, with `randomProb` (uniform acceptance) and `pseudoProb` (acceptance under a pseudorandom family `g : S → F`), and `advantage = |randomProb − pseudoProb|`. Main results (all built and depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`):

- `pseudoProb_eq_zero_of_useful` — usefulness collapses the pseudorandom acceptance mass to 0.
- `natural_property_distinguishes` — **the heart of Razborov–Rudich**: largeness (`δ ≤ randomProb P`) + usefulness ⇒ distinguishing advantage `≥ δ`.
- `natural_property_distinguishes_approx` — a genuine strengthening allowing the test to leak on an `ε`-fraction of seeds, still giving advantage `≥ δ − ε`.
- `useful_of_class_useful` — bridge from "useful against a circuit class containing the family" to "useful against the family".
- `natural_proofs_barrier` — a property that is natural (constructive + large) for a class against which `g` is `δ`-secure cannot be useful against `g`.
- `razborov_rudich` — headline: a constructive, large property useful against a circuit class that contains a `δ`-secure PRF breaks that PRF's security.
- `barrier_needs_largeness` — boundary case proving largeness is indispensable (the always-false property is vacuously useful but yields advantage 0).

Each theorem carries a one–two sentence proof sketch comment, and the proofs are clean. The file compiles as module `Computation.NaturalProofsBarrier` with zero warnings.

### `FUTURE_DIRECTIONS.md` (also mirrored at `Catalog/Computation/NaturalProofsBarrier_FUTURE_DIRECTIONS.md`)
Five falsifiable research conjectures, each with a "The key insight is…" sentence and a "Why now?" justification: (1) constructivity as an explicit circuit-size budget on the test using the catalog's `BoolFormula`; (2) deriving largeness from the Shannon counting bound `num_boolean_functions`; (3) a universally-quantified "if PRFs exist then no natural proof" corollary; (4) a unified `BarrierSchema` capturing relativization, algebrization, and naturalization as one fixed-point obstruction; (5) a degree-parametrized algebraic distinguisher bridging the natural-proofs and algebrization barriers via `AlgebraicOracle`.