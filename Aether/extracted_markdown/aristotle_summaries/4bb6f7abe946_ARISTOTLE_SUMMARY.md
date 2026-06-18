# Summary of changes for run 01c422e4-c8d8-40bb-bec1-0803f513a39f
I formalized the quantitative heart of the **Razborov–Rudich natural proofs barrier** in a new, fully-proved Lean file plus a research roadmap.

**New file:** `Catalog/Computation/NaturalProofsBarrier.lean` (module `Computation.NaturalProofsBarrier`). It builds with zero `sorry` and depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

This extends the *qualitative* natural-proofs skeleton already in `Catalog/Computation/BarrierFramework.lean` (which only produced an existence statement, `natural_proof_distinguisher`) into an exact, quantitative distinguisher stated with rational densities. Boolean functions on `n` inputs are modeled as truth tables (`TruthTable n`), a "property" as a `Finset` of truth tables, and pseudorandomness as a bound on exact statistical advantage. The Razborov–Rudich conditions are formalized as: *constructive* (membership test lies in an admissible test class), *large* (`δ ≤ density P`), and *useful* (`Disjoint P G`).

Main results (12 proved theorems/examples):
- `naturalProperty_advantage_eq` — a useful property's membership test accepts a random function with probability exactly `density P` and a pseudorandom one with probability `0`, so its distinguishing advantage **equals** `density P`.
- `naturalProperty_distinguishes` — a large + useful property distinguishes the uniform and pseudorandom ensembles with advantage `≥ δ`.
- `razborov_rudich_barrier` — if the ensemble is `ε`-pseudorandom against the admissible tests and a constructive, `δ`-large, useful property exists with `ε < δ`, we reach a contradiction: **secure pseudorandomness forbids natural proofs.**
- `no_natural_proof_of_secure_prf` — the headline corollary: against a genuinely pseudorandom ensemble there is *no* constructive, large, useful (natural) property.
- `testAdvantage_le_density_accSet` / `naturalProperty_advantage_le` — the boundary result that advantage is capped by accepted-input density, proving **largeness is necessary**.
- Supporting identities (`accSet_memTest`, `accProbUniv_memTest`, `accProbOn_memTest_of_disjoint`, `accProbOn_nonneg`, `testAdvantage_eq`) and a concrete worked instance over the two-point ensemble (advantage `= 1/2`).

Each theorem carries a brief `-- !-- … -- !--` proof sketch, and the design connects the circuit-barrier (`Computation`) domain with the indistinguishability notion from the `Cryptography` directory.

**Roadmap file:** `Catalog/Computation/NaturalProofsBarrier_FUTURE_DIRECTIONS.md` — a narrative listing 5 falsifiable conjectures (advantage amplification, tight largeness/security threshold, relativized/algebrized barriers, distinguisher-to-inverter hybrid, and naturalizability of Shannon counting bounds), each with a "The key insight is…" sentence and a "Why now?" justification referencing existing catalog results.