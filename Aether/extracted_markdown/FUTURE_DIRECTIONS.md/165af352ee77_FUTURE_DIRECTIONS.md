# Future Directions: The Carmichael Frontier of Fibonacci Primitive Divisors

This cycle attacked the primitive-divisor theory of the Fibonacci sequence — the assertion,
due to Carmichael (1913), that `F n` carries a *primitive* prime divisor (a prime dividing
`F n` but no earlier `F k`) for every `n` outside the small exceptional set `{1, 2, 6, 12}`.

We rebuilt the foundations from first principles in two new, fully `sorry`-free files:

* `Catalog/Shared/CarmichaelHelper.lean` — the gcd bridge `p ∣ F m → p ∣ F n → p ∣ F (gcd m n)`,
  the *finite* characterisation of primitivity (`isPrimitiveDivisor_iff_proper`: a prime factor
  of `F n` is primitive iff it avoids `F d` for every proper divisor `d ∣ n`), and a complete,
  unconditional proof of **the prime case** (`exists_primitiveDivisor_of_prime`: every prime
  index `n ≥ 3` has a primitive divisor — in fact *every* prime factor of `F n` is primitive).
* `Catalog/Shared/FibonacciRankApparition.lean` — the *rank of apparition* `ρ(p) = min{k>0 : p∣F k}`
  and its dictionary: `p ∣ F n ↔ ρ(p) ∣ n` (`dvd_fib_iff_rank_dvd`), culminating in
  `isPrimitiveDivisor_iff_rank_eq`: a prime factor of `F n` is primitive **iff** `ρ(p) = n`.

These supply the missing `Shared.CarmichaelHelper` dependency that the composite-case file
consumed, and they recast Carmichael's theorem into a single sharp question:
*is `n` itself the rank of apparition of some prime?* What remains — the analytic heart for
composite `n > 10000` — is exactly the content of the `sorry` in
`Catalog/Shared/CarmichaelProof.lean`.

Below are five falsifiable directions, ordered by how directly they close that gap.

## Direction 1 — Lifting-the-exponent for Fibonacci numbers

**Conjecture.** For an odd prime `p` with rank `r = ρ(p)` and `r ∣ n`, the `p`-adic valuation
satisfies `v_p(F n) = v_p(F r) + v_p(n / r)` (with the usual `p ∈ {2,5}` adjustments). This is
the single ingredient that, combined with a size bound, settles the composite tail of
`fib_carmichael_composite`.

The key insight is that the rank dictionary already proved here (`dvd_fib_iff_rank_dvd`) controls
*whether* `p` divides `F n`; LTE upgrades this to control *how often*, which is precisely what
distinguishes a primitive prime (full multiplicity concentrated at index `n`) from an imported
one. Why now? Because with `Fibonacci.rank` and `isPrimitiveDivisor_iff_rank_eq` in place, LTE is
no longer a free-floating identity: it can be stated and tested against the rank invariant, and
its only consumer (the primitive-part lower bound) is now a one-line corollary away.

## Direction 2 — A Binet growth bound `F n ≥ φ^(n-2)` in `ℝ`

**Conjecture.** `(Nat.fib n : ℝ) ≥ goldenRatio ^ (n - 2)` for all `n ≥ 1`, and dually
`F n ≤ φ^(n-1)`. Equivalently, `F n` is the nearest integer to `φ^n / √5`.

The key insight is that primitivity for *composite* `n` is ultimately a competition between the
exponential growth of `F n` and the merely polynomial number (`≤ log₂ n`) of proper divisors that
could absorb its prime factors; a clean two-sided Binet bound is the referee. Why now? Mathlib
already carries `Real.goldenRatio` and the Binet formula `Nat.fib`–`goldenRatio` link, so this is
a packaging-and-induction task rather than new theory, and it is the missing analytic half of
Direction 1's contradiction.

## Direction 3 — The primitive part `Φ_n` as an integer-valued multiplicative object

**Conjecture.** Define `Φ n := ∏_{d ∣ n} (F d) ^ (μ (n / d))`. Then `Φ n` is a positive integer
for all `n ≥ 1`, `F n = ∏_{d ∣ n} Φ d`, and for `n > 12` every prime factor of `Φ n` is a
primitive divisor of `F n` except possibly the largest prime factor of `n`, which can occur to
exponent at most one.

The key insight is that Möbius inversion turns the additive divisor lattice into a multiplicative
factorisation `F n = ∏ Φ d`, isolating the *new* primes at level `n` into the single factor `Φ n`;
Carmichael's theorem then reduces to `Φ n > p_max(n)`. Why now? The rank dictionary identifies
exactly which primes live in `Φ n` (those with `ρ(p) = n`), so the integrality and product
identity can be proved and audited prime-by-prime against `isPrimitiveDivisor_iff_rank_eq`.

## Direction 4 — Coprimality of primitive divisors across coprime indices

**Conjecture.** If `gcd(m, n) = 1` and `m, n ≥ 3`, then no prime is simultaneously a primitive
divisor of `F m` and of `F n`; more strongly, `gcd(Φ m, Φ n) = 1`. Consequently the map
`n ↦ (smallest primitive divisor of F n)` is injective on `{n ≥ 13}`.

The key insight is that `ρ(p) = m` and `ρ(p) = n` cannot both hold unless `m = n`, so the rank
function partitions primes by the index they first appear at — primitivity is a *bijective
labelling* of primes by indices. Why now? This is an immediate, fully provable corollary of
`isPrimitiveDivisor_iff_rank_eq` (a prime has a unique rank), needing none of the hard analytic
machinery, and it yields a clean injectivity statement of independent interest.

## Direction 5 — Generalisation to Lucas sequences and a uniform Zsygmondy statement

**Conjecture.** The entire development (rank dictionary + finite characterisation + prime case)
transfers verbatim to any non-degenerate Lucas sequence `U_n(P, Q)` with `gcd(P, Q) = 1`, giving
`p ∣ U n ↔ ρ(p) ∣ n` and a primitive divisor for all `n` beyond an explicit, sequence-independent
bound — the Bilu–Hanrot–Voutier form of Zsygmondy's theorem.

The key insight is that nothing in `CarmichaelHelper` or `FibonacciRankApparition` used Binet or
the specific recurrence beyond the divisibility identity `U(gcd m n) ∣ gcd(U m, U n)`; the proofs
are *structural*, so abstracting `Nat.fib` to a divisibility sequence costs only a typeclass. Why
now? Carving the Fibonacci-specific facts (Direction 1–3) away from the structural skeleton makes
the abstraction boundary visible, and a generic `IsDivisibilitySequence` interface would let the
prime case and rank dictionary be reused across number theory rather than re-proved per sequence.
