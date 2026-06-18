# Future Directions: Closing Carmichael's Theorem for Fibonacci Numbers

## Synthesis

This cycle hardened and *connected* the catalog's Fibonacci primitive-divisor
skeleton rather than re-deriving it. Three things happened.

First, the build itself was repaired: the package had no `srcDir` (so every module
path such as `Shared.CarmichaelProof` resolved to a non-existent file), the
`Applications` library — on which the entire rank-of-apparition development lives —
was never declared, and `FibPrimitive.lean` was missing the opening `/-` of its
module docstring. With those fixed, the catalog's rank theory
(`Applications/RankOfApparition.lean`: the spine `m ∣ F n ↔ z(m) ∣ n`, the
prime-case existence theorem, the lcm/gcd apparition laws) builds again and becomes
reusable.

Second, the previously *missing* `Shared/CarmichaelHelper.lean` was supplied. Rather
than reprove the prime case, it re-exports the catalog's
`RankOfApparition.fib_prime_index_has_primitive` as `fib_primitive_divisor_prime`,
the interface `CarmichaelComposite.lean` and `FibPrimitive.lean` expected. This
single packaging gap was what broke both composite-case files.

Third, two genuinely new sorry-free theorems were added. `fib_no_primitive_of_exception`
completes the *sharpness* side of Carmichael's theorem: it rules out a primitive
prime divisor for the **entire** classical exception set `{1, 2, 6, 12}` (the catalog
had recorded only `n = 12`). And `fib_primitive_on_verified_range` *synthesises* the
two independent strands — the rank-theoretic prime case and the `native_decide`
GCD-residual certificate for composites — into one unconditional existence statement
for every `n ∈ [13, 50000]`, with no appeal to the open asymptotic tail.

What remains genuinely open is exactly one thing: the asymptotic composite case
`fib_carmichael_composite` for `n > 10000` (the lone `sorry` in
`Shared/CarmichaelProof.lean`). The directions below are a concrete, staged program
to close it, plus two structural generalisations the present results make natural.

## Results Summary

* `Shared/CarmichaelHelper.fib_primitive_divisor_prime` — prime case `n ≥ 13`,
  re-exported from the catalog rank spine (sorry-free).
* `FibPrimitiveExceptions.fib_no_primitive_of_exception` — no primitive prime
  divisor for any `n ∈ {1, 2, 6, 12}` (sorry-free; extends the catalog's `n = 12`).
* `FibCarmichaelVerified.fib_primitive_on_verified_range` — unconditional existence
  for all `13 ≤ n ≤ 50000`, prime or composite (sorry-free synthesis).
* Build infrastructure: `srcDir = "Catalog"`, an `Applications` library declaration,
  and the `FibPrimitive.lean` docstring delimiter were repaired.

## Research Directions

### 1. Formalise the Möbius primitive part `Φ_n` and the factorisation `F_n = ∏_{d ∣ n} Φ_d`

Define `Φ : ℕ → ℤ` by `Φ_n = ∏_{d ∣ n} F_d ^ μ(n/d)` and prove it is a positive
integer with `F_n = ∏_{d ∣ n} Φ_d` and `Φ_n ∣ F_n`. **The key insight is** that
integrality is not an analytic fact but a *telescoping* one: `F_n = ∏_{d ∣ n} Φ_d`
is Möbius inversion over the divisor lattice, and the catalog's strong-divisibility
spine (`fib_dvd_fib_iff`, `Nat.fib_gcd`) already controls every `gcd(F_a, F_b)`, so
the product can be built and inverted entirely inside `ℕ` without ever leaving for
`ℚ`. *Why now?* The rank spine and the divisor-indexed `Finset.prod` machinery are
both in place, and `fib_primitive_on_verified_range` gives a decidable oracle to
unit-test any candidate `Φ_n` against for `n ≤ 50000`. Falsifiable: if some composite
`n ≤ 50000` had `Φ_n` non-integral or `Φ_n ∤ F_n`, a `native_decide` check would
expose it immediately.

### 2. Prove the Fibonacci lifting-the-exponent identity `v_p(F_{mp}) = v_p(F_m) + 1`

For an odd prime `p` with rank of apparition `z(p) = m`, establish
`v_p(F_{mk}) = v_p(F_m) + v_p(k)`. **The key insight is** that this is the genuine
*localisation* of the sequence at `p`: in `ℤ_p[√5]` the companion matrix has
eigenvalues `α, β`, and `(rI + V)^p ≡ r^p I (mod p)` with `V² = (5 F_m² / 4) I`,
so the binomial term linear in `V` contributes exactly one factor of `p` — precisely
the standard LTE for `α^k - β^k`. *Why now?* Mathlib already carries
`multiplicity`/`padicValNat` LTE lemmas (`pow_sub_pow`-style), and the rank spine
pins down `z(p)`, which is the only datum LTE needs. Falsifiable: the predicted
`v_p` values are computable, so a single mismatch on small `p, m, k` refutes the
formalised statement.

### 3. Close the asymptotic case via the growth bound `Φ_n > n` for composite `n > 12`

Combine Directions 1–2: a non-primitive prime of `Φ_n` must divide `n` with
multiplicity `1` (Direction 2), so the non-primitive part of `Φ_n` is at most the
largest prime factor `P(n) ≤ n`; hence `Φ_n > n` forces a primitive prime divisor,
discharging `fib_carmichael_composite` for `n > 10000`. **The key insight is** that
the threshold is *exactly* where golden-ratio growth overtakes linear growth:
`Φ_n ≥ (α - 1)^{φ(n)}` with `α = (1+√5)/2`, and `φ(n) ≥ √n` for `n > 12`, so the
inequality `Φ_n > n` fails only for the finite exceptional set already pinned down by
`fib_no_primitive_of_exception`. *Why now?* The exact exceptional set and the entire
verified range `[13, 50000]` are now theorems, so only a clean asymptotic tail
estimate is missing — the qualitative shape of the bound is fully constrained.
Falsifiable: the claim `Φ_n > n` for all composite `13 ≤ n ≤ 50000` is decidable and
can be checked before any analytic work is invested.

### 4. Transport sharpness to Lucas and general Lehmer sequences via the strong-divisibility bridge

Using `StrongDivisibilityRankBridge` (which abstracts the rank of apparition to any
strong divisibility sequence and identifies it with `orderOf` for the Mersenne
family), characterise the exception set for the Lucas numbers and for `aⁿ − 1`.
**The key insight is** that "no primitive divisor at `n`" is the statement that the
homogeneous cyclotomic value `Φ_n(α, β)` is a *unit*, a condition that is sequence-
independent once phrased through the abstract rank — so the Fibonacci exceptions
`{1, 2, 6, 12}` and the Mersenne exception `n = 6` (Zsygmondy) become two instances
of one bridge theorem. *Why now?* The bridge already exists and is sorry-free, and
`fib_no_primitive_of_exception` provides the concrete template to abstract.
Falsifiable: the predicted exception sets are finite and computable per sequence.

### 5. Reframe the appearance pattern as a localisation / quotient functor

Phrase the rank spine `p ∣ F_k ↔ z(p) ∣ k` as: the "appearance" map sends the index
line `ℕ` onto the cyclic quotient `ℕ / z(p)·ℕ`, with primitive prime divisors of
`F_n` being exactly the primes whose quotient is generated by `n`. **The key insight
is** that the whole primitive-divisor question is the search for *generators* of these
cyclic localisations — a homotopy/path-space style statement in which `z` is a functor
from the divisibility poset to cyclic groups and Carmichael's theorem is its
essential surjectivity outside `{1, 2, 6, 12}`. *Why now?* The spine, the lcm/gcd
apparition laws, and `fibRank_dvd_of_dvd` (functoriality on the divisibility poset)
are all already proven, so only the categorical wrapper is missing. Falsifiable: the
functor laws (`z(lcm) = lcm(z, z)`, `z` monotone) are already theorems, so any
proposed quotient description must reproduce them exactly or be wrong.
