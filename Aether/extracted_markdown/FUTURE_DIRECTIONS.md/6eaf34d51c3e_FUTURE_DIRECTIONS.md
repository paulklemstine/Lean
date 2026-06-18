# Future Directions — Proof-Complexity Holography meets Carmichael Primitivity

## Synthesis

This cycle attacked the priority target `CarmichaelComposite` and the broken
`Shared.CarmichaelHelper` dependency through the lens of the catalog's
**proof-complexity holography** program (`Logic.ProofComplexity.Holography`), whose
organizing principle is *local-to-global propagation*: a local one-step bound propagates
holographically to a global metric statement (`translate_deriv`,
`minDerivLen_translate_le`).

The Fibonacci **entry point** (rank of apparition) — the least `k > 0` with `p ∣ F_k` — is
the number-theoretic twin of the proof metric `minDerivLen`: both are minimal-index
functionals. We showed Carmichael's primitive-divisor theorem obeys *the same* local→global
pattern: the local hypothesis "`n` is prime" propagates to a global primitivity statement
about **every** prime factor of `F_n` at once, with the strong-divisibility identity
`F_{gcd(m,n)} = gcd(F_m, F_n)` (`Nat.fib_gcd`) as the entire engine. This isolates all the
analytic difficulty in the *composite* case, exactly where `gcd(k,n)` can be a nontrivial
proper divisor (the "slack" that the prime/chain case lacks).

## Results summary

New file `Shared/CarmichaelHelper.lean` (previously missing — its absence broke
`CarmichaelProof`, `CarmichaelComposite`, `FibPrimitive`):
* `CarmichaelHelper.fib_dvd_gcd` — the gcd–Fibonacci bridge.
* `CarmichaelHelper.fib_prime_all_divisors_primitive` — for prime `n`, **every** prime
  divisor of `F_n` is primitive (unconditional, no growth bound).
* `CarmichaelHelper.fib_primitive_divisor_prime` (+ root alias) — the prime branch consumed
  by the downstream Carmichael files.

New file `Logic/ProofComplexity/FibonacciPrimitiveHolography.lean`:
* `prime_index_all_prime_factors_primitive` — holographic propagation over
  `(F_n).primeFactors`.
* `fib_prime_has_primitive` — existence at the **sharp** threshold `n ≥ 3` (sharpening the
  consumers' `n ≥ 13`).
* `prime_index_coprime_earlier_product` — "global newness": a prime factor of `F_n` is
  coprime to `∏_{1 ≤ k < n} F_k`.
* `fib_six_no_primitive`, `fib_twelve_no_primitive` — the two genuine exceptions, pinning the
  boundary where Carmichael's theorem switches on.

All new theorems are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The single remaining `sorry` in the project,
`Shared.CarmichaelProof.fib_carmichael_composite` (composite `n > 10000`), is the analytic
heart of Carmichael's theorem and is the subject of Direction 1 below.

## Research directions

### 1. Close the composite tail via the cyclotomic primitive part
The lone open `sorry` is: for composite `n > 10000`, `F_n` has a primitive prime divisor.
The classical route is the **primitive part** `Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}`, which collects
exactly the primes of entry point `n`. The key insight is that `Φ_n` is the value at the
golden ratio of the `n`-th *Lucas cyclotomic factor*, and a non-primitive `Φ_n` is forced to
equal a single small "intrinsic" prime dividing `n`; a lower bound `Φ_n > n` (from
`F_n ≥ φ^{n-2}` and `∑_{d<n, d∣n} F_d` being geometrically dominated) then guarantees a
primitive factor. **Why now?** The entry-point API (`fib_dvd_gcd`,
`fib_prime_all_divisors_primitive`, `prime_index_coprime_earlier_product`) is exactly the
divisibility scaffolding such a proof needs; only the Möbius/growth estimate is missing, and
Mathlib already has `Nat.fib` growth lemmas and `ArithmeticFunction.moebius`. Falsifiable:
the conjectured bound `Φ_n > n` for composite `n ≥ 13` is a finite-plus-asymptotic claim that
can be stress-tested by `#eval` before formalization.

### 2. Lifting-the-Exponent (LTE) for Fibonacci `v_p(F_{mk}) = v_p(F_m) + v_p(k)`
For an odd prime `p` with entry point `m = z(p)`, the `p`-adic valuation satisfies
`v_p(F_{mk}) = v_p(F_m) + v_p(k)`. The key insight is that this is the ordinary LTE
(`padicValNat.pow_sub_pow`, already in Mathlib) transported along the eigenvalue
factorization `F_n = (φ^n - ψ^n)/√5` in `ℤ_p[√5]`, so that `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`.
**Why now?** This single identity reduces the prime-power case of Direction 1 to bookkeeping,
and the eigenvalue companion-matrix viewpoint connects directly to the catalog's
`Algebra.CharpolyRecognition`. Falsifiable: the congruence `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`
is `decide`-checkable for many concrete `(m,p)`.

### 3. Entry point as a genuine quasi-metric ("rank holography")
Define `rank p = entryPoint p` and study the map `p ↦ rank p` as a minimal-index functional
parallel to `minDerivLen`. The key insight is that `rank` satisfies a divisibility "triangle
law" `rank p ∣ gcd(k, n)` whenever `p ∣ F_k` and `p ∣ F_n`, the multiplicative analogue of
the additive `derivOfLen_comp`. **Why now?** `Holography.minDerivLen_translate_le` gives the
exact template (a Lipschitz/propagation inequality); proving the rank version would make
"proof-complexity holography" and "primitive-divisor theory" two instances of one abstract
minimal-functional theorem. Falsifiable: claim `rank` is *exactly* multiplicative on coprime
arguments — almost surely **false** (carry/coincidence primes), and locating the first
counterexample is itself a result.

### 4. Zsygmondy for general Lucas sequences `U_n(P,Q)`
Generalize from Fibonacci (`P=1, Q=-1`) to arbitrary nondegenerate Lucas sequences
`U_n(P,Q)`. The key insight is that the prime-index argument of
`fib_prime_all_divisors_primitive` uses *only* the strong-divisibility law
`gcd(U_m, U_n) = U_{gcd(m,n)}`, which holds for every Lucas sequence with `gcd(P,Q)=1`; hence
the entire prime case generalizes verbatim. **Why now?** Mathlib lacks a general Lucas-sequence
`fib_gcd`, but it is a clean induction; once present, the prime case of Zsygmondy's theorem
follows for free, a strict generalization of this cycle's headline. Falsifiable: the
strong-divisibility law fails when `gcd(P,Q) ≠ 1` — pinpointing exactly which Lucas sequences
retain primitivity is a sharp, testable boundary.

### 5. Effective exception census across `(P,Q)`
Conjecture: across nondegenerate Lucas sequences, the indices `n` with **no** primitive divisor
form a finite, explicitly computable set depending only on `(P,Q)` (for Fibonacci: exactly
`{1,2,6,12}`, as `fib_six_no_primitive` and `fib_twelve_no_primitive` confirm two of them).
The key insight is that exceptions occur precisely when the primitive part `Φ_n` collapses to
a divisor of `n`, a condition checkable by a verified `native_decide` sweep bounded by the
growth estimate of Direction 1. **Why now?** The `interval_cases`-plus-`decide` exception
proofs here scale directly into a certified census once the growth bound caps the search range.
Falsifiable: the claim "Fibonacci has *no* exception beyond `n = 12`" is exactly the composite
tail of Direction 1, and any `n` violating it would refute Carmichael outright.
