# Summary of changes for run f8b66339-f0d3-4d83-99b3-90fdb572f903
Completed the "prove" research cycle on Korselt's criterion and the multiplicative-order bridge. All main theorems are fully proved (0 sorries) and use only the standard axioms (propext, Classical.choice, Quot.sound), verified against the project's Lean 4.28 / Mathlib toolchain via `lake build`.

## Deliverables

**1. `Catalog/Shared/KorseltCriterion.lean`** — the number-theoretic core.
- Imports and builds on the existing catalog file `Algebra/KorseltUnitsBridge.lean`, reusing its bridge `prime_sub_one_dvd_of_forall_units_pow_eq_one`.
- **C2 (Generalized Korselt):** `generalized_korselt` and `generalized_korselt_modEq` — for squarefree `n` and *any* exponent `e`, every unit mod `n` satisfies `u^e = 1` iff `(p−1) ∣ e` for every prime `p ∣ n`. Supporting lemmas: a Chinese-remainder reassembly `dvd_of_squarefree_forall_prime_dvd`, the constructive `pow_modEq_one_of_prime_factor`, the units↔ModEq bridge `forall_units_pow_one_iff_modEq`, and the arbitrary-exponent converse `prime_sub_one_dvd_of_forall_units_pow_one`.
- **C1 (the hard converse):** `squarefree_of_forall_units_pow_one` (squarefreeness forced via Cauchy's theorem on `(ℤ/p²ℤ)ˣ`), assembled into the full iff `korselt_iff_absFermatPsp` (`IsAbsFermatPsp n ↔ IsKorselt n` for `n > 1`), its units form `korselt_iff_forall_units_pow_one`, and the Carmichael wrapper `carmichael_iff`. (The `¬n.Prime` hypothesis was found unnecessary for the core iff and is kept only in the faithful Carmichael wrapper.)

**2. `Catalog/Cryptography/KorseltGroupActionBridge.lean`** — the cross-domain bridge (imports the core file).
- Abstract order/exponent collapse from a universal relation: `orderOf_dvd_of_forall_pow_eq_one`, `exponent_dvd_of_forall_pow_eq_one`, and geometric-triviality lemmas over arbitrary `MulAction`s (`pow_smul_eq_self`, `free_smul_iff`).
- Korselt specializations on `(ℤ/nℤ)ˣ`: `korselt_orderOf_dvd` (C3 first-class fact), `korselt_exponent_dvd` and `korselt_exponent_le` (C5 key-space collapse, `Monoid.exponent (ℤ/nℤ)ˣ ≤ n−1`), and the geometric Korselt statements `korselt_action_pow_trivial` and the regular-torsor iff `korselt_iff_regular_pow_trivial` (C4).

**3. `FUTURE_DIRECTIONS.md`** — five bold, falsifiable conjectures (Carmichael-λ = per-prime lcm; Korselt ⇒ ≥3 prime factors; order-collapse density / single-witness test; free-action GAIP impossibility with √(n−1) attack; strong-pseudoprime 2-adic refinement), each with a "The key insight is…" sentence and a "Why now?" justification derived from this cycle's proven lemmas.

Both Lean files contain `-- !-- Lab Notes -- !--` blocks documenting the Hypothesize / Experiment / Analyze / Critique / Synthesize loop. No trivial proofs, no `native_decide`/`axiom`/`sorry`, and no forbidden artifacts were introduced.