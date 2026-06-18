# Summary of changes for run 411d7889-5e0f-4a8b-9f75-39230e411e2e
## Phase A complete — Korselt's criterion & Carmichael numbers

I built a new, self-contained Lean 4 file, `Catalog/Novelty/KorseltCarmichael.lean`, that formalizes the structural backbone of **Carmichael number theory** — a topic Mathlib's own `NumberTheory/FermatPsp.lean` explicitly notes is *"not yet defined"*. This is a genuine cross-domain bridge into Mathlib's existing `Nat.FermatPsp` API.

### Deliverables
- **1 Lean file, 0 sorries on all results**, verified to depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`). The file compiles cleanly with no warnings.
- **8 proven declarations** built first-principles from two reusable engine lemmas:
  - `pow_eq_self_zmod` — in each residue field `ZMod p`, `(p-1) ∣ (n-1)` forces `x^n = x` for all `x` (local mechanism).
  - `prime_dvd_pow_sub_self` — per-prime divisibility `(p:ℤ) ∣ a^n - a`.
  - `dvd_pow_sub_self` — **the Korselt identity**: squarefree + `(p-1)∣(n-1)` for all primes `p∣n` ⟹ `(n:ℤ) ∣ a^n - a` for *every* integer `a` (global recombination via pairwise-coprime prime factors).
  - `fermatPsp_of_coprime` — **the headline bridge**: a Korselt number is `Nat.FermatPsp n b` for every coprime base, i.e. it is a Carmichael number.
  - `odd`, `not_eq_mul_two_primes`, `three_le_card_primeFactors` — structural theorems: every Carmichael number is odd and has at least three distinct prime factors.
  - `korselt_561` / `fermatPsp_561` — the verified canonical instance `561 = 3·11·17`, the smallest Carmichael number.
- **Proof sketches** as `-- !-- … -- !--` blocks before each lemma (one to two sentences each).
- **Lab Notebook** (`-- !-- Lab Notebook -- !--`) with Hypothesis, Result, Insight, and Failure analysis (notably: `decide` does not evaluate `Squarefree`/`primeFactors`, so the `561` instance routes through `Nat.squarefree_mul_iff` and prime-divisor peeling).
- **`FUTURE_DIRECTIONS.md`** with a synthesis, results table, and 5 bold, falsifiable directions (the converse iff via primitive roots, Chernick's three-prime family, the small-smallest-prime-factor bound, a Knödel-number generalization, and forcing squarefreeness) — each with a "The key insight is…" sentence and a "Why now?" justification.

### Catalog synthesis
The work extends the catalog's number-theoretic thread (the Fibonacci `gcd`-bridge `Nat.fib_gcd` and the Fermat-pseudoprime direction) by gluing finite-field exponentiation (`ZMod.pow_card_sub_one_eq_one`) through a CRT-style product over `Nat.primeFactors` (`Finset.prod_dvd_of_coprime`) into Mathlib's `Nat.FermatPsp`, supplying machinery Mathlib flags as missing.