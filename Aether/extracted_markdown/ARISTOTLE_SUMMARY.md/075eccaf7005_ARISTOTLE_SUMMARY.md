# Summary of changes for run 84e9ab6b-8200-45e3-830c-45ad656ee7dd
Created a new, fully `sorry`-free Lean 4 development isolating the *algebraic kernel* of the **Eastin–Knill no-go theorem** for transversal quantum gates, plus the required research notes.

## Deliverables

**1. Lean file — `Computation/EastinKnill.lean`** (builds cleanly, no warnings, no `sorry`).
It models a code as a Hermitian idempotent projector `P` (`structure QECCode`), defines an operator as *detectable* with scalar `c` when `P A P = c • P` (the compressed Knill–Laflamme condition), and proves:

- `Detectable.smul`, `Detectable.add`, `Detectable.sum` — detectable operators form a scalar-valued, linear, sum-closed family (the additivity behind charge conservation).
- `eastin_knill_transversal_scalar` — a transversal generator (finite sum of detectable single-site terms, packaged as `structure TransversalGenerator`) compresses to the single scalar `(∑ cᵢ) • P`.
- `detectable_logical_central` and `eastin_knill_transversal_central` — the headline no-go: a detectable operator, hence any transversal generator, is **central** in the logical operator algebra (its compression commutes with the compression of every operator), the precise obstruction to logical universality. The core insight proved is that idempotency `P*P = P` alone forces a scalar-compressing operator to be central.
- `logical_noncentral_without_detection` — boundary theorem: on the trivial distance-1 code (`P = 1`) the compressions of Pauli `X` and `Z` fail to commute, certifying the detection hypothesis is essential.
- `basisCode` / `diagonal_detectable` — a concrete rank-1 code witnessing that detectability is inhabited non-trivially.

All eight main theorems depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`).

**2. Requested annotations.** The file contains `-- !-- … -- !--` one/two-sentence proof-sketch blocks above each theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) in the module header.

**3. `Computation/FUTURE_DIRECTIONS.md`** — a narrative synthesis, results summary, and five falsifiable research directions (Lie-algebra → gate-group upgrade via matrix exponentials; tensor-product realization of single-site detectability; quantitative/approximate Eastin–Knill; the Wigner–Araki–Yanase covariance bridge; and an interpolating conjecture relating the transversal gate set to code distance). Each direction includes a "The key insight is…" sentence and a "Why now?" justification, and references the catalog theorems it builds on.

The file is placed in the `Computation` library matching the referenced path and uses `import Mathlib`.