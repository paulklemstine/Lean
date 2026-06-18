# Summary of changes for run 583e0e72-328d-4215-9cdb-677e5f210bc2
Delivered a new, self-contained Lean 4 file `Catalog/Applications/RankOfApparition.lean` (imports only Mathlib, compiles cleanly, **0 sorry**, axioms = propext/Classical.choice/Quot.sound) that develops the *rank of apparition* (Fibonacci entry point) as the unifying spine of the catalog's Carmichael / primitive-divisor program. It proves 8 theorems, all machine-verified:

- `hasFibRank_of_pos` — every positive modulus divides some positive-index Fibonacci number (apparition always occurs), via finiteness of the pair sequence mod m and reversibility of the Fibonacci shift.
- `fibRank_dvd_iff` — **the spine**: `m ∣ F n ↔ fibRank m ∣ n`, for *every* modulus with a rank. This generalizes the catalog's `dvd_fib_iff_index_dvd_of_primitive` by dropping the primitivity hypothesis.
- `fibRank_pos`, `fibRank_dvd_fib`, `fibRank_min` — the defining specification of the rank.
- `fibRank_dvd_of_dvd` — `fibRank` is an order morphism `(ℕ, ∣) → (ℕ, ∣)`.
- `fibRank_fib` — `fibRank (F k) = k` for `k ≥ 3` (the rank pins Fibonacci values exactly).
- `fib_prime_index_has_primitive` — Carmichael's prime case, derived in a few lines from the spine: every prime index `p ≥ 3` yields a primitive prime divisor of `F p`.

The file contains a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis) and per-section `-- !--` proof sketches, and cites the relevant catalog results it builds on (`FibonacciPrimitiveDivisors`, `StrongDivisibilitySequences`, `FibonacciApparitionLattice`, the Carmichael program).

Also added `FUTURE_DIRECTIONS.md` with a synthesis, a results summary, and 5 falsifiable research directions (each with a "The key insight is…" statement and a "Why now?" justification), including a concrete program for the still-open deep composite tail of Carmichael's theorem.

Scope note: the only pre-existing `sorry` in the Carmichael program is the deep `n > 10000` composite tail in `Catalog/Shared/CarmichaelProof.lean` (a Zsygmondy/cyclotomic-strength result), and that file is additionally blocked by a missing `Shared.CarmichaelHelper` dependency. Rather than leave a false or vacuous proof there, I proved the right-sized, fully verifiable core — the apparition spine and the prime case — and laid out the cyclotomic + Lifting-the-Exponent route to the composite tail as Research Direction 1. The new file is consistent with the catalog's existing layout (other `Catalog/Applications/*` files are likewise standalone `import Mathlib` modules); it was verified to elaborate with `lake env lean`.