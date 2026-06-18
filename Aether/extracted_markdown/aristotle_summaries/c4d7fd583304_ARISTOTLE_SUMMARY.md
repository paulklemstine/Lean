# Summary of changes for run 4fdb9f5c-b68a-4060-a086-a7ff14fccfc4
Delivered a new self-contained Lean 4 file `Catalog/Applications/FibonacciRankDeepening.lean` that deepens the Fibonacci rank-of-apparition theory from `Catalog/Applications/RankOfApparition.lean`. It restates the spine core (existence + the law of apparition `m ∣ F n ↔ fibRank m ∣ n`) and proves five new theorems, all `sorry`-free and verified to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`:

1. `fibRank_lcm` — the exact join (lattice) law `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`, with no coprimality hypothesis (the `fibRank` analogue of the catalog's `fibEntry_lcm`).
2. `fibRank_mul_coprime` — corollary for coprime factors: `fibRank (a·b) = lcm (fibRank a) (fibRank b)`.
3. `fib_dvd_sq_sub_one` — the deep arithmetic result: for a prime `p ∉ {2,5}`, `p ∣ F(p²−1)`, proved via the Fibonacci companion matrix's eigenvalues in `AlgebraicClosure (ZMod p)` and Frobenius (a Binet-formula argument over `𝔽_{p²}`).
4. `fibRank_prime_dvd_sq_sub_one` — the classical prime square law `fibRank p ∣ p²−1` for primes `p ∉ {2,5}`, connecting the matrix bound to the rank via the spine.
5. `fibRank_semiprime_dvd_lcm` — a new cross-result combining the lattice and arithmetic axes: for distinct primes `p, q ∉ {2,5}`, `fibRank (p·q) ∣ lcm(p²−1, q²−1)`.

Each theorem carries a brief `-- !-- ... -- !--` proof sketch and a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis). A file-level heartbeat option was added so the heavy eigenvalue proof elaborates reliably in full-file context.

Also delivered `FUTURE_DIRECTIONS.md` with a synthesis, a results table, and five falsifiable research directions (each with a "The key insight is..." sentence and a "Why now?" justification): the sharp Legendre-symbol prime law `fibRank p ∣ p−(5∣p)`, Wall's prime-power lifting law, the full multiplicative reduction of `fibRank` over prime-power factors, closing the open composite-case `sorry` of Carmichael's theorem in `Catalog/Shared/CarmichaelProof.lean`, and a Pisano-period stratification.

Note: the project's Lake targets are misconfigured (lib globs reference `Algebra.+` etc. while sources live under `Catalog/`), so the catalog does not build via `lake build`; following the established catalog pattern, the new file imports only Mathlib and was validated/verified through the language server.