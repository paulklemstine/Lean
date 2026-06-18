# Summary of changes for run c0dc9554-f7a8-439e-bf91-7a7cd208ae27
Added a new, fully proven Lean development of the **Eastin–Knill no-go theorem** for fault-tolerant quantum computation, in the Computation domain of the catalog.

**New files (under `Catalog/Computation/`):**
- `EastinKnill.lean` — a self-contained, `sorry`-free formalization of the algebraic core of Eastin–Knill in a finite-dimensional matrix setting over ℂ.
- `EastinKnill_FUTURE_DIRECTIONS.md` — five testable, falsifiable research conjectures extending the work (each with a "key insight" and a "why now" justification).

**Mathematical content.** A quantum code is modeled as a Hermitian idempotent projector `P` (`QECCode`). An operator is *detectable* with scalar `c` when its compression satisfies `P A P = c • P` (the compressed Knill–Laflamme error-detection condition). The file proves:
- `detectable_one`, `detectable_zero`, `detectable_add`, `detectable_smul`, `detectable_sum` — detectable operators contain the identity and are closed under linear combinations and finite sums (the "transversal = sum of single-site terms" closure);
- `detectable_unique` — the detection scalar is unique for a nonzero code;
- `detectable_logical_central` — the logical action of a detectable operator is **central** in the logical operator algebra (the abstract obstruction to universality);
- `eastin_knill_transversal_scalar` and `eastin_knill_transversal_central` — the headline result: a transversal generator (modeled by a `TransversalGenerator` structure) compresses to a scalar `(∑ cᵢ)•P` and is logically central, so no transversal generator of an error-detecting code can be universal;
- `logical_noncentral_without_detection` — a boundary/counterexample (trivial distance-1 code, Pauli X and Z) showing the error-detection hypothesis is genuinely necessary.

**Verification.** The module builds successfully (`Computation.EastinKnill`), contains no `sorry` on any result, and all main theorems depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`. Proof sketches are included inline as `-- !-- ... -- !--` comment blocks. This delivers well beyond the requested 2–4 proved theorems (11 theorems, all proved).