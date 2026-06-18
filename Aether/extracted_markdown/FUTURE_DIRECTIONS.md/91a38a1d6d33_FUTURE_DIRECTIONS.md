# Future Directions — Prime-power reduction of the Fibonacci rank of apparition

This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which closes the
multiplicative theory of the Fibonacci rank of apparition `FibonacciApparition.fibEntry`.
The catalog already contained the two-factor coprime law
(`FibonacciEntryPointInvariant.fibEntry_mul_coprime`) and the unrestricted join law
(`FibonacciApparitionLattice.fibEntry_lcm`). The new file proves the **full prime-power
reduction**

> `fibEntry n = lcm_{p ∈ supp(n)} fibEntry (p ^ vₚ(n))`  (theorem `fibEntry_factorization`),

routed through a reusable multi-factor join engine `fibEntry_prod_coprime` and the CRT
divisibility shape `coprime_prod_dvd_iff`, with monotonicity
`fibEntry_dvd_of_factorization_le` and the base case `fibEntry_one`. Everything is
`sorry`-free and depends only on the standard axioms. The directions below extend this
frontier.

## 1. The Wall–Sun–Sun barrier: `fibEntry (p²) = p · fibEntry p`?

For every known prime `p`, the rank of apparition of `p²` is exactly `p · fibEntry p`; a
prime where `fibEntry (p²) = fibEntry p` instead is precisely a **Wall–Sun–Sun prime**,
none of which are known. Combined with `fibEntry_factorization`, settling the exponent
behaviour `fibEntry (p^(k+1)) = p · fibEntry (p^k)` for `k ≥ 1` would make `fibEntry`
*completely* explicit from its values on primes alone.

The key insight is that `fibEntry_factorization` already isolates the prime-power case as
the *only* remaining unknown, so the entire mystery of the rank of apparition collapses to
the single lifting-the-exponent step `fibEntry (p^{k+1}) / fibEntry (p^k) ∈ {1, p}`,
provable from `Catalog/Shared/FibonacciLTE.lean` for `k ≥ 1` except on the Wall–Sun–Sun
locus.

**Why now?** The reduction theorem proved this cycle is exactly the statement that makes
the prime-power recurrence the *sole* obstruction; before it, an exponent law would not
have determined `fibEntry` on composite moduli. With `FibonacciLTE` already in the catalog,
the `p`-adic valuation machinery needed for the lift is in place.

## 2. Pisano period vs. rank of apparition: `π(n) = lcm` over prime powers too

The Pisano period `π(n)` (the period of `F_k mod n`) satisfies the same prime-power
reduction `π(n) = lcm_{p} π(p^{vₚ(n)})`, and is a bounded multiple of `fibEntry n`
(the ratio `π(n)/fibEntry(n) ∈ {1,2,4}`). Formalizing `π` as `addOrderOf` of the Fibonacci
shift on `ZMod n × ZMod n` and proving its reduction would let one transport
`fibEntry_prod_coprime` verbatim.

The key insight is that both invariants are join-homomorphisms out of `(ℕ_{>0}, ·)`, so the
abstract engine `fibEntry_prod_coprime` should be re-provable once for *any* function
satisfying the law of apparition `m ∣ u k ↔ entry m ∣ k`, with Pisano period and rank of
apparition as two instances.

**Why now?** The engine is already stated for an arbitrary pairwise-coprime family; only
the law-of-apparition interface is Fibonacci-specific. Abstracting that interface (mirroring
`StrongDivSeq` in `FibonacciEntryPointInvariant.lean`) is a small refactor that immediately
yields the Pisano reduction.

## 3. Carmichael-style primitive divisors of composite indices

`fibEntry_factorization` says a modulus `m` is primitive for `F_n` (entry point `= n`) iff
`n = lcm` of the prime-power entry points dividing `m`. This gives a *computable*
characterization of which composite `m` can be primitive divisors, refining the catalog's
prime-only `FibonacciApparition.prime_primitive_divisor_iff`.

The key insight is that primitivity of a composite `m` is now a pure lattice condition on
the multiset `{fibEntry (p^{vₚ(m)})}`, namely that their lcm has no proper realization at a
smaller index — a condition checkable from the prime-power data alone.

**Why now?** The composite case was previously inaccessible because no reduction expressed
`fibEntry m` for composite `m`; with the reduction proved this cycle, the composite
primitive-divisor predicate becomes a finite lattice computation over the factorization
support `n.factorization.support`.

## 4. Effective bounds: `fibEntry n ≤ ψ(n)` via the prime-power reduction

Each prime-power entry point satisfies `fibEntry (p^k) ≤ p^{k-1}(p+1)` (a classical bound),
so the reduction gives `fibEntry n ∣ lcm_p p^{vₚ(n)-1}(p+1)`, dividing `n·∏_{p∣n}(1+1/p)`.
Formalizing the per-prime bound and pushing it through `Finset.lcm` would yield the first
machine-checked effective bound on the Fibonacci rank of apparition.

The key insight is that `Finset.lcm_dvd_iff` turns the global bound into independent
per-prime-power bounds, exactly the divide-and-conquer structure the reduction theorem
exposes.

**Why now?** `Finset.lcm_dvd_iff` is the only nontrivial glue, and it is already used inside
`fibEntry_prod_coprime`; the remaining work is the single-prime estimate, which is a finite
`p`-adic computation supported by `Catalog/Shared/FibonacciLTE.lean`.

## 5. Universality: prime-power reduction for all strong divisibility sequences

`FibonacciEntryPointInvariant.lean` already abstracts the *gcd* half of the theory to
arbitrary strong divisibility sequences `u` (those with `gcd(u m, u n) = u(gcd m n)`),
covering Fibonacci, Lucas, and base-`a` Mersenne/repunit sequences. The natural completion
is to prove the *lcm* (prime-power reduction) half abstractly: `entry_u (∏ p^{vₚ(n)}) =
lcm entry_u (p^{vₚ(n)})` for every such `u`.

The key insight is that the engine `fibEntry_prod_coprime` used *only* the law of apparition
and `coprime_prod_dvd_iff`, both of which hold for any strong divisibility sequence whose
entry map is total — so a single abstract theorem would simultaneously deliver the
prime-power reduction for Fibonacci, Lucas, and Mersenne numbers.

**Why now?** The abstract `StrongDivSeq.entry` and `entry_dvd` infrastructure already exists
in the catalog; pairing it with the now-proven concrete reduction shows precisely which two
ingredients (totality + coprime-product divisibility) must be abstracted, making the
universal statement a guided generalization rather than a fresh development.
