# Future Directions — Proof-Complexity Holography meets Carmichael Primitivity

## Synthesis

This cycle repaired the broken `Shared.CarmichaelHelper` dependency — whose absence had
disabled `Shared.CarmichaelProof` and `Speculative.AutoResearch.CarmichaelComposite` (both
consume the top-level symbol `fib_primitive_divisor_prime`) — and re-read the Carmichael
primitive-divisor problem through the catalog's **proof-complexity holography** lens
(`Logic.ProofComplexity.Holography`), whose organizing principle is *local-to-global
propagation*. The Fibonacci **entry point** (rank of apparition: the least `k > 0` with
`p ∣ F_k`) is the number-theoretic twin of the proof metric `minDerivLen`: both are
*minimal-index functionals*.

The structural discovery is that the **prime-index** case of Carmichael's theorem is purely
holographic — it needs *no* growth or analytic input whatsoever. A single engine, the strong-
divisibility law `F_{gcd(m,n)} = gcd(F_m, F_n)` (`Nat.fib_gcd`), packaged here as `fib_dvd_gcd`,
propagates the *local* hypothesis "`n` is prime" into a *global* statement about **every** prime
factor of `F_n` at once (`prime_index_all_prime_factors_primitive`), and even into coprimality
of those factors with the entire earlier product `∏_{1 ≤ k < n} F_k`
(`prime_index_coprime_earlier_product`). When the index `n` is prime, every gcd with a smaller
positive index collapses to `1`, so one divisibility law controls all earlier indices
simultaneously.

What *failed* — productively — was the temptation to assert primitivity for all `n`. The
exception theorems `fib_six_no_primitive` (`F_6 = 8`, with `2 ∣ F_3`) and
`fib_twelve_no_primitive` (`F_12 = 144`, with `2 ∣ F_3` and `3 ∣ F_4`) show the prime
hypothesis is load-bearing and pin down exactly why Carmichael's classical threshold is
`n = 13`. This isolates *all* remaining analytic difficulty in the composite tail — the lone
open `sorry` in `Shared.CarmichaelProof.fib_carmichael_composite` (composite `n > 10000`).

The unifying thread for the directions below: "entry point" and "minimal derivation length" are
two instances of one abstract minimal-index functional, and the divisibility "triangle law" for
entry points is the multiplicative analogue of the additive propagation inequality in
`Holography`.

## Results Summary (file `Catalog/Shared/CarmichaelHelper.lean`, all `sorry`-free)

- `fib_dvd_gcd` — the gcd–Fibonacci bridge `p ∣ F_m → p ∣ F_n → p ∣ F_{gcd(m,n)}`; the single
  engine for the entire prime-index branch.
- `fib_prime_all_divisors_primitive` — for prime index `n`, *every* divisor `> 1` of `F_n` is
  primitive (unconditional, no growth bound).
- `fib_prime_has_primitive` — existence at the **sharp** threshold `n ≥ 3`, sharpening the
  consumers' `n ≥ 13`.
- `fib_primitive_divisor_prime` — prime case of Carmichael for `n ≥ 13`; the symbol consumed by
  the downstream Carmichael files (dependency now restored).
- `prime_index_all_prime_factors_primitive` — holographic propagation over the whole set
  `(F_n).primeFactors`.
- `prime_index_coprime_earlier_product` — "global newness": a prime factor of `F_n` (prime `n`)
  is coprime to `∏_{1 ≤ k < n} F_k`.
- `fib_six_no_primitive` — refutation: `F_6 = 8` has no primitive prime divisor.
- `fib_twelve_no_primitive` — refutation: `F_12 = 144` has no primitive prime divisor.

## Research Directions

### Direction 1: Close the composite tail via the cyclotomic primitive part
For composite `n ≥ 13`, the Fibonacci primitive part `Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}` should
satisfy `Φ_n > n`, and any non-primitive `Φ_n` should be forced to equal a single small prime
dividing `n`; hence `F_n` always has a primitive prime divisor. A first falsifiable test is to
`#eval` the bound `Φ_n > n` over composite `13 ≤ n ≤ 10^4`, then formalize the Möbius/growth
estimate from `F_n ≥ φ^{n-2}` and geometric domination of `∑_{d < n, d ∣ n} F_d`. The key
insight is that the lone remaining `sorry` is now *analytically isolated*: the entire
combinatorial/divisibility half is done, supplied by `fib_dvd_gcd`,
`fib_prime_all_divisors_primitive`, and `prime_index_coprime_earlier_product`. **Why now?**
Mathlib already has `Nat.fib` growth lemmas and `ArithmeticFunction.moebius`, so only the
single growth estimate stands between this project and a fully `sorry`-free Carmichael theorem.
If true, Carmichael becomes complete here; if a composite `n` with `Φ_n ≤ n` exists it would
refute Carmichael outright — so even a near-miss sharpens the true growth constant.

### Direction 2: Lifting-the-Exponent for Fibonacci, `v_p(F_{mk}) = v_p(F_m) + v_p(k)`
For an odd prime `p` with entry point `m = z(p)`, the `p`-adic valuation should obey
`v_p(F_{mk}) = v_p(F_m) + v_p(k)`, equivalently `F_{mp}/F_m ≡ p · r^{p-1} (mod p²)`. Test it by
`decide`-checking the congruence for many concrete `(m, p)`, then transport the standard LTE
(`padicValNat.pow_sub_pow`) along the eigenvalue factorization `F_n = (φ^n − ψ^n)/√5` in
`ℤ_p[√5]`. The key insight is that the prime-*power* case of Direction 1 reduces entirely to
this one valuation identity, and the companion-matrix eigenvalue viewpoint links directly to
the catalog's `Algebra.CharpolyRecognition`. **Why now?** Direction 1's prime-power bookkeeping
is the only place the divisibility scaffolding of this cycle does not already suffice, and LTE
is exactly the missing ingredient. If false, the failure pinpoints the ramified prime `p = 5`
where naive LTE breaks — itself a sharp, citable boundary.

### Direction 3: Entry point as a quasi-metric ("rank holography")
Define `rank p = z(p)`. Then `rank` should satisfy a divisibility *triangle law* — `z(p) ∣ k`
and `z(p) ∣ n` whenever `p ∣ F_k` and `p ∣ F_n`, hence `z(p) ∣ gcd(k, n)` — the multiplicative
analogue of the additive propagation step in `Holography`; but `rank` should **not** be exactly
multiplicative on coprime arguments. Prove the triangle law directly from `fib_dvd_gcd` (it is
essentially immediate), then `#eval`-search for the first coprime pair where
`z(p·q) ≠ lcm(z(p), z(q))` to disprove exact multiplicativity. The key insight is that proving
the rank version would exhibit "proof-complexity holography" and "primitive-divisor theory" as
two instances of *one* abstract minimal-index functional theorem. **Why now?**
`Holography.minDerivLen_translate_le` already supplies the exact propagation/Lipschitz template,
so the abstraction has a ready home. If true it yields a reusable minimal-index-functional
interface spanning the Logic and Number-Theory branches; if multiplicativity fails, the first
counterexample is a concrete datum about coincidence primes.

### Direction 4: Zsygmondy for general Lucas sequences `U_n(P,Q)`
For every nondegenerate Lucas sequence with `gcd(P, Q) = 1`, the strong-divisibility law
`gcd(U_m, U_n) = U_{gcd(m,n)}` should hold, and therefore the prime-index argument of
`fib_prime_all_divisors_primitive` should generalize verbatim: for prime `n`, every prime
divisor of `U_n` is primitive. Prove the general `U`-gcd law by induction (Mathlib lacks it for
general `U`), then re-derive the prime case of Zsygmondy mechanically. The key insight is that
this cycle's prime-index proof uses *only* the gcd law and nothing Fibonacci-specific, so the
generalization is a clean import once the law is in place. **Why now?** The Fibonacci proof was
deliberately written through the single abstract engine `fib_dvd_gcd`, making the swap to a
general `U` a matter of replacing one lemma. If true it is a strict generalization of this
cycle's headline (the prime case of Zsygmondy); if false, the exact `(P,Q)` where strong
divisibility fails (necessarily `gcd(P,Q) ≠ 1`) delimits which Lucas sequences retain
primitivity.

### Direction 5: Effective exception census across `(P,Q)`
Across nondegenerate Lucas sequences, the indices `n` with **no** primitive divisor should form
a finite, explicitly computable set depending only on `(P,Q)`; for Fibonacci it is exactly
`{1, 2, 6, 12}` (this cycle proved the `6` and `12` exceptions). Test with a verified
`native_decide` sweep, range-bounded by the growth estimate of Direction 1, enumerating the
exceptional `n` for each small `(P,Q)`. The key insight is that exceptions occur precisely when
the primitive part `Φ_n` collapses onto a divisor of `n`, a `decide`-checkable condition; the
`interval_cases`-plus-`decide` exception proofs (`fib_six_no_primitive`,
`fib_twelve_no_primitive`) here scale directly once a growth bound caps the search range.
**Why now?** The decision procedure and the two seed exceptions are already in hand; only the
range bound from Direction 1 is needed to make the census exhaustive and certified. If true it
is a machine-checked effective form of Carmichael's classification; if "Fibonacci has no
exception beyond `n = 12`" fails, the violating `n` refutes Carmichael — a headline result.
