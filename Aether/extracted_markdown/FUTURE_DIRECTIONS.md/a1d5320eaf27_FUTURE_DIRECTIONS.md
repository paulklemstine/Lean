# Future Directions — Closing Carmichael: from the certified band to the asymptotic tail

## Synthesis

This cycle was about *closing proofs* in the Fibonacci primitive-divisor program.
On arrival the Carmichael subsystem was, in fact, not even building: the module
`Shared.CarmichaelProof` and its dependents imported a `Shared.CarmichaelHelper`
file that did not exist, `Speculative.CarmichaelPrimitiveDivisor` imported the
composite module under the wrong path, and the package source root was
misconfigured. We repaired all three, then supplied the genuinely missing
mathematics: the **prime-index case** of Carmichael's theorem.

The prime case turns out to be elementary once phrased through the
rank-of-apparition: every prime factor of `F p` (`p` prime) has entry point a
divisor of `p`, hence `1` or `p`; the value `1` is impossible because `F 1 = 1`.
We proved this in `Shared/CarmichaelHelper.lean` (`fib_primitive_divisor_prime`)
and then *synthesized* it, in `Speculative/CarmichaelSynthesis.lean`, with the
two other strands already present in the catalog — the `native_decide`
composite certificate of `Speculative.AutoResearch.CarmichaelComposite` and the
entry-point theory of the LTE file
`Algebra.…Fibonacci_Primitive_Divisors`. The synthesis yields a `sorry`-free
Carmichael theorem on the **certified band** `13 ≤ n ≤ 10000`, a strengthening
that *all* prime factors of `F p` are primitive for prime `p`, the entry-point
bridge `fibEntryPoint q = p`, and an injectivity corollary giving infinitely
many primes as Fibonacci primitive divisors.

## Results summary

Fully proved this cycle (`sorry = 0`, only `propext`/`Classical.choice`/`Quot.sound`,
plus `Lean.ofReduceBool` for the `native_decide` band):

* `CarmichaelHelper.fib_primitive_divisor_prime` — Carmichael, prime index `≥ 13`.
* `CarmichaelSynthesis.fib_all_prime_factors_primitive` — for prime `p ≥ 3`,
  *every* prime factor of `F p` is primitive.
* `CarmichaelSynthesis.fib_carmichael_certified_band` — Carmichael on `13 ≤ n ≤ 10000`,
  glued from the prime branch and the computational composite certificate without
  touching the open tail.
* `CarmichaelSynthesis.fib_prime_entryPoint_eq` — entry point of a prime factor of
  `F p` equals `p`.
* `CarmichaelSynthesis.fib_primitive_primes_injective_on_primes` — distinct prime
  indices give distinct least primitive primes ⇒ infinitude.

Still open (one `sorry`, deliberately documented): the **asymptotic composite
tail** `fib_carmichael_composite` for composite `n > 10000` in
`Shared/CarmichaelProof.lean`.

## Direction 1 — Close the composite tail via the cyclotomic/primitive part `Φ_n`

The remaining `sorry` is the infinite composite tail: for composite `n > 10000`,
`F n` has a primitive prime divisor. The right object is the *primitive part*
`Φ_n := ∏_{d ∣ n} F_d ^ μ(n/d)`, the Fibonacci analogue of the cyclotomic value.
**The key insight is** that, by Lifting-the-Exponent (already formalized as
`fib_lte`), every prime dividing `Φ_n` is primitive *except possibly the largest
prime factor `P` of `n`, which can occur only to the first power*; hence a single
size comparison `Φ_n > P` (and `Φ_n > 1`) produces a primitive divisor. Concretely:
prove `Φ_n ∣ F_n`, prove the "at most one exceptional prime, valuation ≤ 1"
lemma from `fib_lte` + `entry_point_dvd_sq_sub_one`, and bound
`Φ_n ≥ φ^{φ(n)} / C > n ≥ P` using the existing `fib_exponential_lower_bound`.
**Why now?** The two hardest ingredients already exist and are `sorry`-free in
this very project — the Fibonacci LTE lemma and the matrix-diagonalization proof
that `z(p) ∣ p² − 1`. Only the bookkeeping product `Φ_n` and one growth estimate
are missing, so the tail is now a *finite* assembly task rather than new theory.

## Direction 2 — Replace `native_decide` on `[13,10000]` by a uniform proof

The certified band currently rests on a `native_decide` over the coprime-part
algorithm. **The key insight is** that the same `Φ_n` machinery from Direction 1,
once it covers `n > 10000`, almost certainly covers the *entire* range `n ≥ 13`
with at most a handful of genuinely exceptional small `n` ({1,2,6,12}), removing
the artificial `10000` cutoff and the trust placed in `Lean.ofReduceBool`.
**Why now?** With `fib_carmichael_certified_band` already isolating the band as a
standalone lemma, swapping its proof is a drop-in replacement that cannot regress
the public theorem; the cutoff `10000` is exposed as a pure proof artifact, not
mathematics, making it a clean falsifiable target (does the `Φ_n` bound already
bite at `n = 13`?).

## Direction 3 — Quantitative primitive divisors: a lower bound on `ω(Φ_n)`

Beyond mere existence, Carmichael-type results predict *how many* primitive primes
appear. **The key insight is** that `Φ_n / gcd(Φ_n, P)` is a product of distinct
primitive primes, so `log Φ_n` divided by `log` of the largest Fibonacci prime
factor gives an explicit lower bound on the number of primitive prime divisors of
`F_n`, computable from `fib_exponential_lower_bound`. A falsifiable form: for all
`n ≥ 30`, `F_n` has at least `2` distinct primitive prime divisors — testable by
`#eval` and then provable from the same size estimate. **Why now?** The injectivity
theorem `fib_primitive_primes_injective_on_primes` already shows primitivity is the
correct invariant for *counting*; upgrading from "≥ 1" to "≥ k" reuses exactly the
entry-point bookkeeping just built.

## Direction 4 — Transport the entry-point method to Lucas and general Lehmer sequences

The whole argument used only: a strong divisibility law (`gcd(U_m,U_n)=U_{gcd}`),
an LTE lemma, and exponential growth. **The key insight is** that these three
hypotheses can be abstracted into a typeclass `StrongDivisibilitySequence` so that
the prime-index Carmichael theorem, the entry-point bridge, and the injectivity
corollary become *one* generic proof instantiated by Fibonacci, Lucas `L_n`, and
Mersenne `2^n − 1`. **Why now?** Our prime-case proof already factors through only
`Nat.fib_gcd` and `Nat.fib_one`; nothing Fibonacci-specific survives, so the
generalization is a refactor that immediately triples the catalog's theorem count
(Fibonacci ∪ Lucas ∪ Mersenne) at near-zero marginal proof cost — and it predicts
the Bang–Zsygmondy exceptional sets, a sharp falsifiable claim.
