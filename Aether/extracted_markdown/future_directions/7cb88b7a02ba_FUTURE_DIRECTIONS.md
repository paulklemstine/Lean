# Future Directions — the `ordEGF` (order–generating) bridge

These conjectures extend `Catalog/Cryptography/OrderEGFBridge.lean`, which
establishes the order spectrum `ordCount G d = #{a : G | orderOf a = d}`, the
partition identity `∑_{d ∣ |G|} ordCount G d = |G|`, its cyclic specialization
`ordCount G d = φ(d)`, the existence of a Diffie–Hellman generator, and the
Pohlig–Hellman torsion count `#{a | a^d = 1} = gcd(d, |G|)`.

Each direction below is stated as a precise, falsifiable Lean target.

## C1. Exponent (Carmichael λ) refinement of the spectrum
**Conjecture.** For any finite group `G`, every `d` with `ordCount G d ≠ 0`
divides the group exponent `Monoid.exponent G`, and
`∑_{d ∣ Monoid.exponent G} ordCount G d = |G|`.
This sharpens `ordCount_sum_eq_card` (which sums over divisors of `|G|`) to the
*smallest* index set, the divisors of the exponent. For `(ZMod n)ˣ` the exponent
is the Carmichael function `λ(n)`, giving a spectrum identity indexed by `λ(n)`
rather than `φ(n)` — the genuinely cryptographic modulus invariant.

## C2. Non-cyclic order spectrum is sub-totient
**Conjecture.** For any finite abelian group `G` and `d ∣ |G|`,
`ordCount G d ≥ φ(d)` iff `G` has a cyclic subgroup of order `d`, and in general
`ordCount G d` is a multiple-of-`φ(d)` determined by the number of cyclic
subgroups of order `d`. A clean testable form: in an elementary abelian
`(ZMod p)^k`, `ordCount G p = p^k - 1` and `ordCount G 1 = 1`, so the spectrum is
supported on `{1, p}` — a falsifiable closed form to verify in Lean.

## C3. EGF form over the symmetric tower
**Conjecture.** Define `aₙ(m) = #{σ : Equiv.Perm (Fin n) | σ ^ m = 1}`. Then the
exponential generating function satisfies
`∑_{n} aₙ(m) xⁿ/n! = exp(∑_{d ∣ m} x^d / d)`.
This is the *true EGF* incarnation of the bridge (the `m = 2` case counts
involutions, `exp(x + x²/2)`). Target: prove the recurrence
`aₙ₊₁(m) = ∑_{d ∣ m} (n)_{d-1} · a_{n+1-d}(m)` in Lean, the finite shadow of the
EGF identity, avoiding full `PowerSeries` machinery.

## C4. Generator density and DLP key-space lower bound
**Conjecture.** For a cyclic group of order `n`, the generator fraction
`φ(n)/n` is bounded below by `c / log log n`; consequently a uniformly random
element is a generator with non-negligible probability. Testable Lean milestone:
`φ(n)/n ≥ 1 / (e^γ · log log n + 3 / log log n)` (Rosser–Schoenfeld) specialized
to the orders arising in `OrderEGFBridge.exists_generator_cyclic`, certifying
that DH key sampling succeeds without rejection blow-up.

## C5. Cross-link to the Fibonacci/Carmichael catalog
**Conjecture.** The primitive-divisor results in
`Catalog/Speculative/AutoResearch/FibonacciPrimitiveDivisorBounded.lean`
(`fib_gcd_identity`, `fib_primitive_divisor_*`) are the `orderOf`-in-`(ZMod p)ˣ`
shadow of the order spectrum: a prime `p` is a *primitive* divisor of `F(n)` iff
the rank of apparition `α(p)` equals `n`, i.e. iff `n` lies in the order spectrum
of the Fibonacci entry-point map mod `p`. Target: a Lean lemma
`p ∣ F(n) ∧ (∀ k < n, ¬ p ∣ F(k)) ↔ ordCount_entry p n ≠ 0`, bridging the
`ordEGF` framework to the composite Carmichael tail still open in
`Catalog/Shared/CarmichaelProof.lean`.
