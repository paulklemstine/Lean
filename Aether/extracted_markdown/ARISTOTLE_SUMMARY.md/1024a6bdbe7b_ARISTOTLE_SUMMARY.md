# Summary of changes for run be166a0a-6a98-48c1-82af-f7e0fd85dcab
Completed a full research cycle on Fibonacci entry points and primitive divisors, building on the catalog's entry-point/Carmichael theory.

## Build infrastructure fix
The project did not compile at all: `lakefile.toml` was missing `srcDir = "Catalog"`, so Lean could not locate any source module. Added it (strict improvement; nothing built before).

## New verified Lean files (0 sorries, axioms restricted to propext/Classical.choice/Quot.sound[/ofReduceBool/trustCompiler])
1. `Catalog/Shared/CarmichaelHelper.lean` — supplies the previously **missing** file that two catalog files imported (`fib_primitive_divisor_prime`), closing the prime-index branch of Carmichael's primitive-divisor theorem via the already-proved `fib_prime_has_primitive`. This also unblocks `Shared.CarmichaelProof` and `Speculative.AutoResearch.CarmichaelComposite`, which now compile.
2. `Catalog/Speculative/AutoResearch/FibEntryPointCongruence.lean` — new results extending the catalog:
   - `fibEntryPoint_dvd_sq_sub_one`: the rank of apparition `z(p) ∣ p² − 1` for odd primes `p ≠ 5` (law of apparition, upper bound).
   - `primitive_divisor_dvd_sq_sub_one`: any primitive prime divisor `p` of `F_n` (`n ≥ 6`) satisfies `n ∣ p² − 1`.
   - `primitive_divisor_sq_ge`: such `p` satisfies `n + 1 ≤ p²` (primitive divisors grow like √n).
   - `fib_carmichael_iff_le_10000`: **Carmichael's theorem fully verified on [1, 10000]** — `F_n` has a primitive prime divisor iff `n ∉ {1,2,6,12}` — assembled through a deliberately sorry-free dependency chain (avoiding the open composite-tail lemma), plus the new small cases `fib_eight/nine/ten/eleven_has_primitive`.

## Lab notes
Both new files contain `-- !-- Lab Notes -- !--` blocks recording hypotheses, computational experiments (entry-point and ±1-mod-n checks), insights, and failure analysis. An explanatory lab note was also added at the one remaining `sorry`.

## FUTURE_DIRECTIONS.md
Five precise, testable conjectures: (1) closing the infinite composite tail of Carmichael via cyclotomic–Fibonacci factorization; (2) the sharp `p ≡ ±1 (mod n)` congruence for primitive divisors (verified computationally for 7 ≤ n ≤ 24); (3) the sharp law of apparition `z(p) ∣ p − legendre(5,p)`; (4) `p ≥ n − 1` size bound; (5) a Lucas-number analogue toward the general Bilu–Hanrot–Voutier theorem.

## Honest status of the priority targets
- `Fib_gcd_identity`: already present and proved in the catalog (no sorry) — reused.
- `CarmichaelComposite`/`CarmichaelProof`: the prime case and the finite range [1, 10000] are now fully proved sorry-free. The genuinely deep **infinite composite tail** (`fib_carmichael_composite` for n > 10000) remains an open formalization requiring cyclotomic-Fibonacci machinery; it is left as a documented `sorry` (a subagent attempt confirmed it is beyond a single proof search) and logged as priority Conjecture 1.

Note: a pre-existing, unrelated set of files under `Catalog/Algebra/Jacobian/` depends on a missing `Algebra.Jacobian.Defs` module; this predates and is outside this Fibonacci/Carmichael cycle and was left untouched to avoid introducing unverified mathematics. All files I created or modified build successfully via targeted `lake build` and pass `#print axioms` checks.