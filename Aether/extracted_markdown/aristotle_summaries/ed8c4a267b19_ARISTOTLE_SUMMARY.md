# Summary of changes for run 0d3e2f6d-aa67-4b2e-a0f0-b3796ab43521
## What was delivered

I extended the catalog's strong-divisibility-sequence ("rank of apparition" / entry-point) program with a new, self-contained, fully verified Lean file plus a future-directions writeup.

### New Lean file: `Catalog/Speculative/AutoResearch/EntryPointMultiplicativity.lean`
Placed under the registered `Speculative` Lake library so it builds independently (the whole-project build is pre-broken by missing files such as `Algebra/Jacobian/Defs.lean`, unrelated to this work). It proves, for an arbitrary strong divisibility sequence `u` (only the identity `gcd(u m)(u n) = u(gcd m n)` plus `u 0 = 0`), the two facts the catalog previously had only for Fibonacci (via the now-missing `FibonacciApparition` module):

- `dvd_iff_entry_dvd` — the abstract **law of apparition**: `m ∣ u k ↔ entry u m ∣ k`.
- `entry_eq_of_dvd_iff` — **rigidity**: the entry point is the unique positive generator of the appearance set (needs only the gcd identity).
- `entry_dvd_entry_of_dvd` — **order side of the lattice morphism**: `d ∣ m → entry u d ∣ entry u m`.
- `entry_mul_coprime` — **multiplicativity / join law**: `entry u (a·b) = lcm (entry u a) (entry u b)` on coprime moduli.

Two cross-domain instantiations are harvested for free:
- `mersenne_entry_mul_coprime` (for `u n = aⁿ−1`, where `entry` is the multiplicative order, recovering `ord_{a·b} = lcm(ord_a, ord_b)`), and
- `fib_entry_mul_coprime` (recovering the catalog's `fibEntry_mul_coprime`).

All six results are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`). The file builds cleanly with no warnings. It includes `-- !--` proof-sketch comments on each new theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), and documents that `u 0 = 0` is load-bearing only for the `k = 0` edge case of the law of apparition.

### `FUTURE_DIRECTIONS.md` (project root)
A narrative synthesis, a results table, and 5 falsifiable directions (each with a "The key insight is…" sentence and a "Why now?" justification): (1) discharging Fibonacci totality via Pisano periodicity; (2) prime-power reconstruction of the entry point; (3) the dual meet law; (4) identifying the Mersenne entry point with `orderOf` in `ZMod`; and (5) a concrete path to close the genuine remaining open `sorry` — the infinite-tail case of Carmichael's Fibonacci primitive-divisor theorem in `Shared/CarmichaelProof.lean`.

### Note on the "close proofs" mandate
The actual code-level `sorry`s in the catalog are research-grade hard (Carmichael's primitive-divisor theorem infinite tail; Rabin's 1/4 liar bound in `PrimalityTesting/MillerRabin.lean`). Rather than leave a false claim, I built the abstract entry-point bridge that directly reduces the Carmichael "primitive divisor exists" question to "some prime has entry point exactly n", and laid out the concrete route to closing it in FUTURE_DIRECTIONS.md.