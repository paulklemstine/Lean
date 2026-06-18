# Summary of changes for run 4f67dabc-79c0-45d3-968c-2a486e7f22c7
## What was delivered

I added a new, fully-proved Lean 4 development plus a research roadmap, following the team research loop and the catalog-synthesis requirement.

### New Lean file: `Speculative/FibonacciRankOfApparition.lean`
A self-contained file (builds cleanly, `sorry = 0` on all results, only the standard axioms `propext, Classical.choice, Quot.sound`). It closes a foundational gap underneath the catalog's Fibonacci primitive-divisor work, where the "entry point" / rank of apparition is always introduced behind an *assumed* existence guard (verified per-prime or with a `0` fallback) in `Shared/CarmichaelProof.lean`, `Speculative/AutoResearch/CarmichaelComposite.lean`, `Algebra/Tropical_..._Fibonacci_Primitive_Divisors.lean`, and `Cryptography/FibonacciDivisibilityLattice.lean`.

Main theorems (all proved):
- `fib_rank_exists` — for **every** modulus `m ≥ 1` there is a positive `k` with `m ∣ F_k` (the catalog only ever obtained this for primes/specific moduli). Proof observes the *paired state* `(F_n, F_{n+1}) mod m` as the orbit of `(0,1)` under the invertible shift `(a,b) ↦ (b, a+b)` on the finite set `(ZMod m)²`; reversibility forces pure periodicity back to `(0,1)`.
- `fib_dvd_iff_rank_dvd` — `m ∣ F_n ↔ z(m) ∣ n` (exception-free divisibility dictionary).
- `fib_index_set_eq` — `{n | m ∣ F_n} = {n | z(m) ∣ n}` (order-theoretic restatement).
- `prime_primitive_iff_rank_eq` — a prime `p` is a primitive divisor of `F_n` iff `z(p) = n`, recasting Carmichael's theorem (`fib_carmichael`) as a statement about the range of the rank map.
- `fib_gcd_identity` — `F_{gcd(m,n)} = gcd(F_m, F_n)`, the engine of the dictionary.

The file includes the required `-- !-- ... -- !--` proof-sketch blocks for each non-trivial theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

### `FUTURE_DIRECTIONS.md`
A freeform narrative with a Synthesis, a Results Summary table, and 5 bold, falsifiable research directions (lattice homomorphism property of the rank map; a growth/counting bound to finish Carmichael's open `n > 10000` tail; adaptive-vs-static observation via the Pisano period `orderOf (fibShift m)`; generalization to all Lucas sequences; finiteness of the primitive-prime fiber `z⁻¹(n)`). Each direction includes a "The key insight is..." sentence and a "Why now?" justification, and each ties back to catalog theorems cited by name.

### Notes on the catalog
The catalog sources live under `Catalog/` with their own (un-built) lakefile, while the buildable project (with Mathlib prebuilt) is rooted where the new file was placed; I therefore made the new file self-contained on Mathlib and referenced catalog results by name in the sketches and roadmap rather than importing the un-built tree. The priority targets were addressed conceptually: `fib_gcd_identity` is proved here, and `prime_primitive_iff_rank_eq` reframes the open Carmichael composite case (the `sorry` in `Shared/CarmichaelProof.lean`) as a range statement about the rank map, with Direction 2 outlining the growth inequality that would close it.