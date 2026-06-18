# Summary of changes for run 7a8e4404-026a-4777-83cc-d0333b93616a
## Cycle complete: Carmichael primitivity through proof-complexity holography

### What was done
This cycle repaired the broken `Shared.CarmichaelHelper` dependency (whose absence had
disabled `Shared/CarmichaelProof.lean`, `Speculative/AutoResearch/CarmichaelComposite.lean`,
and `Speculative/AutoResearch/FibPrimitive.lean`) and produced new, fully verified theorems
viewing Carmichael's primitive-divisor theorem as local-to-global propagation.

### New Lean files (sorry-free, axioms = propext/Classical.choice/Quot.sound only)
1. `Shared/CarmichaelHelper.lean`
   - `fib_dvd_gcd` — the gcd–Fibonacci bridge (`p∣F_m, p∣F_n ⇒ p∣F_{gcd(m,n)}`).
   - `fib_prime_all_divisors_primitive` — for prime index `n`, every prime divisor of `F_n`
     is primitive, unconditionally.
   - `fib_primitive_divisor_prime` — prime case of Carmichael for `n ≥ 13`; the symbol the
     downstream Carmichael files require (dependency now restored, those files build again).
2. `Logic/ProofComplexity/FibonacciPrimitiveHolography.lean`
   - `prime_index_all_prime_factors_primitive` — holographic propagation over the whole set
     `(F_n).primeFactors`.
   - `fib_prime_has_primitive` — existence at the sharp threshold `n ≥ 3` (sharpens consumers'
     `n ≥ 13`).
   - `prime_index_coprime_earlier_product` — "global newness": a prime factor of `F_n` is
     coprime to `∏_{1≤k<n} F_k`.
   - `fib_six_no_primitive`, `fib_twelve_no_primitive` — explicit counterexamples pinning the
     boundary where Carmichael's theorem switches on (showing the prime hypothesis is
     load-bearing).

Each file contains `-- !-- Lab Notebook -- !--` blocks (Hypothesis/Result/Insight/Failure
analysis) and per-theorem `-- !-- ... -- !--` proof sketches.

### Notes deliverable
`FUTURE_DIRECTIONS.md` (in `Catalog/`) with the required `## Synthesis` and
`## Results Summary` sections plus five falsifiable research directions (cyclotomic primitive
part to close the composite tail, Fibonacci LTE, entry-point quasi-metric / rank holography,
Zsygmondy for general Lucas sequences, and an effective exception census), each with
Hypothesis / Test / Why now / If true / If false.

### Incidental fix
`Speculative/AutoResearch/FibPrimitive.lean` had a pre-existing syntax error (a module
docstring missing its `/-!` opener and placed before the `import` lines); imports were moved to
the top and the docstring properly delimited so the file builds.

### Verification
All new modules build successfully via `lake build`, and the downstream consumers
(`CarmichaelComposite`, `FibPrimitive`) now compile. The only remaining `sorry` in the project
is the pre-existing analytic composite-tail case in `Shared.CarmichaelProof`
(`fib_carmichael_composite`, composite `n > 10000`), which is the explicit subject of Research
Direction 1.