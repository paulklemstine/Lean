# Summary of changes for run 28e2acc3-1baf-4b2a-a5eb-c65f72701791
Created `Catalog/Shared/CarmichaelHelper.lean`, repairing the previously broken `Shared.CarmichaelHelper` dependency that had disabled `Shared/CarmichaelProof.lean` and `Speculative/AutoResearch/CarmichaelComposite.lean` (both consume the top-level symbol `fib_primitive_divisor_prime`, which was undefined). The downstream files now resolve that import and elaborate (their own pre-existing composite-tail `sorry` in `fib_carmichael_composite` is left untouched, as it is the open analytic problem flagged in the future directions).

The new file develops the **prime-index branch of Carmichael's primitive-divisor theorem** read through the catalog's proof-complexity holography lens (local-to-global propagation). It contains 8 theorems, all proved with zero `sorry` and verified to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`:

- `fib_dvd_gcd` — the strong-divisibility engine `p ∣ F_m → p ∣ F_n → p ∣ F_{gcd(m,n)}`.
- `fib_prime_all_divisors_primitive` — for prime index `n`, every divisor `>1` of `F_n` is primitive (no growth bound).
- `fib_prime_has_primitive` — existence of a primitive prime divisor at the sharp threshold `n ≥ 3`.
- `fib_primitive_divisor_prime` — prime case of Carmichael for `n ≥ 13` (the symbol consumed downstream).
- `prime_index_all_prime_factors_primitive` — propagation over the whole set `(F_n).primeFactors`.
- `prime_index_coprime_earlier_product` — coprimality of a prime factor of `F_n` with `∏_{1≤k<n} F_k`.
- `fib_six_no_primitive`, `fib_twelve_no_primitive` — refutations showing `F_6=8` and `F_12=144` have no primitive prime divisor, proving the prime-index hypothesis is load-bearing and pinning Carmichael's `n=13` threshold.

Each theorem carries the required `-- !-- ... -- !--` proof-sketch and `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis). The file cross-references the catalog's `Applications/FibonacciPrimitiveDivisors.lean`, `Logic/ProofComplexity/Holography.lean`, and `Shared/CarmichaelProof.lean`.

Also wrote `FUTURE_DIRECTIONS.md` with a Synthesis, a Results Summary, and 5 falsifiable research directions (composite-tail closure via the cyclotomic primitive part; Fibonacci Lifting-the-Exponent; entry point as a quasi-metric / "rank holography"; Zsygmondy for general Lucas sequences; an effective exception census), each including a "The key insight is..." statement and a "Why now?" justification.

Note: the project's `lakefile.toml` has a pre-existing misconfiguration (library globs point at the repository root while sources live under `Catalog/`), so a top-level `lake build` of the default targets does not succeed; this is unrelated to the new work. Each new theorem was verified individually through the Lean language server and `lean_verify`, confirming clean elaboration and standard-axioms-only proofs.