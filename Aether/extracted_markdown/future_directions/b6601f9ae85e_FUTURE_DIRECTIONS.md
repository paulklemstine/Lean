# FUTURE DIRECTIONS — Bridges / Strong Divisibility & Primitive Divisors

This cycle established `Catalog/Bridges/PrimeIndexPrimitiveDivisors.lean`: the *prime-index*
case of Carmichael's primitive-divisor theorem, lifted from Fibonacci to an arbitrary
**strong divisibility sequence** `s : StrongDivSeq` (extending
`Catalog/Bridges/StrongDivisibilitySequences.lean`). The single generic theorem
`StrongDivSeq.isPrimitive_of_prime_index` specialises to both the Fibonacci prime case
(`fib_prime_index_primitive`) and a new Mersenne / Zsygmondy-flavoured statement
(`mersenne_prime_index_primitive`). The decisive structural ingredient is the side
condition `p ∤ s 1`, which is *free* for Fibonacci (`F 1 = 1`) but *load-bearing* for
Mersenne (a divisor of `b - 1` is never primitive) — verified by an explicit
counterexample in the file.

The conjectures below are concrete and falsifiable; each is a candidate for a follow-up
cycle.

## Conjecture 1 — Mersenne primitive existence (Bang–Zsygmondy)
For every base `b ≥ 2` and exponent `n ≥ 2` with `(b, n) ∉ {(2, 6)} ∪ {(2^k - 1, 2)}`,
the number `b^n - 1` has a prime divisor `p` with `p ∤ b - 1`. By
`mersenne_prime_index_primitive`, for *prime* `n` such a `p` is automatically a primitive
divisor of the sequence `b^n - 1`.
*Testable:* `native_decide` the existence of a coprime-to-`(b-1)` prime factor for all
`2 ≤ b ≤ B`, `2 ≤ n ≤ N`; the asymptotic tail mirrors Conjecture 3.

## Conjecture 2 — A generic Carmichael criterion for growing SDS
Let `s : StrongDivSeq` satisfy an exponential lower bound `s n ≥ c · r^n` (`r > 1`) and a
bounded-contamination hypothesis: for each `n`, the product of primes `p ∣ s n` whose entry
point is a *proper* divisor of `n`, counted with multiplicity, is at most a fixed polynomial
in `n`. Then for all sufficiently large `n`, `s n` has a primitive divisor.
*Testable:* a single generic theorem that, instantiated at `fibSDS` and `mersenneSDS b`,
discharges both tails uniformly; isolates exactly which growth/contamination hypotheses are
needed.

## Conjecture 3 — The Fibonacci composite tail (the remaining open `sorry`)
Define the primitive part `Φ n = ∏_{d ∣ n} F(d)^{μ(n/d)}`. Then `F n = ∏_{d ∣ n} Φ d`, and
`Φ n > n` for all `n > 12`. Consequently every composite `n > 12` admits a primitive prime
divisor of `F n`, closing the unfinished composite-tail `sorry` in
`Catalog/Shared/CarmichaelProof.lean` (`fib_carmichael_composite`, case `n > 10000`).
*Decomposition:* (a) define `Φ` via Möbius inversion; (b) prove the factorisation
`F n = ∏_{d∣n} Φ d`; (c) show every non-primitive prime of `Φ n` is the largest prime factor
of `n`, appearing to the first power (Fibonacci LTE, Conjecture 4); (d) the growth bound
`Φ n > n` from `F n ≥ φ^{n-2}`.

## Conjecture 4 — Lifting-the-Exponent for strong divisibility sequences
For a "regular" `s : StrongDivSeq` (e.g. a non-degenerate Lucas sequence) and an odd prime
`p` with entry point `α = entryPoint p`, `v_p (s (α · k)) = v_p (s α) + v_p k` for all
`k ≥ 1`. This is the p-adic refinement of the entry-point divisibility law
`dvd_iff_entryPoint_dvd` and the engine behind Conjectures 1–3.
*Testable:* prove first for `fibSDS` from `padicValNat.pow_sub_pow`, then identify the
abstract axioms (a companion-matrix / binomial expansion) that make it generic.

## Conjecture 5 — The entry-point lattice morphism
For `s : StrongDivSeq`, the map `p ↦ entryPoint p` carries the meet/join structure of the
divisibility relation on values to `gcd`/`lcm` on indices: for primes `p, q` with positive
entry points, `entryPoint (p * q)`-type statements and the established
`simultaneous_apparition` (join via `lcm`) and `dvd_gcd_iff` (meet via `gcd`) assemble into a
lattice homomorphism from the sublattice of primitive values into `(ℕ, gcd, lcm)`.
*Testable:* state and verify the homomorphism laws generically, then instantiate at `fibSDS`,
`mersenneSDS`, and `idSDS`; the `idSDS` instance should collapse to the identity lattice,
giving a built-in sanity check.
