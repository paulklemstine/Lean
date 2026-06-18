# Future Directions — Noise-Stable Prime Spectrum in Definable Quantum Walks

## Synthesis

This cycle built a small but load-bearing bridge between three previously separate
catalog arcs: the **Fibonacci primitive-divisor / Carmichael** thread
(`Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelHelper`, whose engine
is the Fibonacci entry-point and the strong divisibility law `Nat.fib_gcd`), the
language of **discrete-time quantum walks on arithmetic Cayley graphs**
`G_n = Cay(ℤ/nℤ, Sₙ)`, and the **additive-order spectrum** of `ℤ/nℤ`. The new file
`Catalog/Bridges/NoiseStablePrimeSpectrum.lean` proves, sorry-free, that the
single-step Cayley walk operator `T_s f = f(· + s)` is always an ℓ²-isometry
(probability-conserving), that its orbit closes at exactly `addOrderOf s`, and —
the conceptual core — that the order spectrum **collapses** (every nonzero step has
full order `n`, i.e. every walk is fully mixing) **iff `n` is prime**
(`prime_iff_all_steps_generate`). A direct corollary (`fib_step_generates`) feeds
the Carmichael picture back in: any Fibonacci step `F(k)` with `p ∤ F(k)` generates
the whole prime cycle.

## Results Summary

* `prime_step_generates` — prime ⇒ every nonzero step is fully mixing (`addOrderOf = p`).
* `step_generates_imp_prime` — full mixing for all nonzero steps ⇒ prime (for `n ≥ 2`).
* `prime_iff_all_steps_generate` — the bridge biconditional.
* `walk_isometry` — unitarity / probability conservation of the one-step walk.
* `walk_period` — the walk's orbit closes at the additive order of the step.
* `fib_step_generates` — Fibonacci step `F(k)` with `p ∤ F(k)` is fully mixing on `ℤ/pℤ`.

## Bold, Falsifiable Directions

### 1. The full mixing-order spectrum equals the divisor lattice of `n`.
Conjecture: for every `n ≥ 1`, the set `{ addOrderOf s : s : ℤ/nℤ }` equals
`{ n / d : d ∣ n }`, i.e. exactly the divisor set of `n`; consequently the spectrum
has cardinality `τ(n)` (the number of divisors), and `τ(n) = 2` recovers primality.
The key insight is that `ZMod.addOrderOf_coe` already computes each order as
`n / gcd(n, a)`, so the spectrum is the *image of the gcd map*, which is precisely
the divisor set — turning the "prime ⇔ collapse" result into a fine-grained
divisor-counting statement. Why now? `prime_iff_all_steps_generate` is the
two-element special case, and the only missing ingredient (`addOrderOf` as
`n / gcd`) is a single Mathlib lemma already used in this file, so the general
statement is within immediate reach.

### 2. Mixing time of multi-step walks is controlled by the smallest prime factor.
Conjecture: for the Cayley walk on `Cay(ℤ/nℤ, S)` with a *symmetric generating*
step set `S`, the diameter (worst-case number of steps to reach any vertex) is
`Θ(n / p)` where `p` is the smallest prime factor of `n`, and is exactly `⌊n/2⌋`
in the prime, single-generator regime `S = {±1}`. The key insight is that the orbit
structure proved in `walk_period` localizes the walk to the cyclic subgroup
`⟨gcd(n, S)⟩`, so reachability is a covering-radius question on a quotient cycle of
length `n / gcd`. Why now? `walk_period` already pins the single-step orbit length
to `addOrderOf s`; extending from one generator to a generated subgroup is a
`AddSubgroup.closure` argument with no new analytic content.

### 3. Walk unitarity upgrades to a genuine `LinearIsometryEquiv` and a Fourier diagonalization.
Conjecture: `walk n s` extends to a unitary `T_s : EuclideanSpace ℂ (ZMod n) ≃ₗᵢ[ℂ]`
whose eigenvalues are exactly the `n`-th roots of unity `exp(2πi k·s / n)`, so the
*quantum* spectrum is the additive-order spectrum read multiplicatively. The key
insight is that `walk_isometry` is the norm-level shadow of the permutation
`Equiv.addRight s`, and any permutation operator is diagonalized by the finite
Fourier transform on `ℤ/nℤ`. Why now? `walk_isometry` already gives the isometry on
the nose; Mathlib's `ZMod` Fourier / character API supplies the eigenbasis, so the
diagonalization is assembly rather than discovery.

### 4. Fibonacci steps detect primitivity: `F(k)` mixes on `ℤ/pℤ` iff `k` is below the entry point.
Conjecture: for prime `p`, the Fibonacci step `F(k)` is fully mixing on `ℤ/pℤ`
*precisely* when `k` is strictly below the Fibonacci entry point `α(p)` of `p`; at
`k = α(p)` the step degenerates (`addOrderOf = 1`), and the entry point `α(p)`
divides the Pisano period `π(p)`. The key insight is that `fib_step_generates` is
one half of an iff whose converse is exactly the definition of the entry point in
`CarmichaelHelper.entryPt`, so the walk's mixing/degeneracy dichotomy *is* the
Carmichael primitivity dichotomy. Why now? Both halves now live in the same library
after this cycle's bridge, so the iff is a direct gluing of `fib_step_generates`
with `CarmHelper.entryPt_min`.

### 5. Noise stability: small random perturbations of the step preserve full mixing on primes.
Conjecture: on `ℤ/pℤ` (`p` prime) the "fully mixing" property is *noise-stable* in
the strongest possible sense — the set of full-mixing steps is the entire punctured
group `ℤ/pℤ \ {0}`, so any perturbation `s ↦ s + δ` with `δ ≠ -s` stays fully
mixing, and the fraction of mixing steps is `1 - 1/p → 1`. On composite `n` this
fraction drops to `φ(n)/n`, the density of generators, which is bounded away from 1.
The key insight is that `prime_step_generates` says *every* nonzero step works, so
the prime regime is the unique regime with zero "bad set" measure — noise stability
and primality coincide. Why now? The exact mixing/non-mixing classification is
already proved this cycle (`prime_iff_all_steps_generate` plus the `n / gcd` order
formula of Direction 1), so the density statement is a `Nat.totient` count over the
classified set.
