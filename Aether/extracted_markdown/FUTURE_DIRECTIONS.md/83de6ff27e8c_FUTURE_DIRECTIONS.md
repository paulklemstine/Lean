# Future Directions — The Rank Characterization of Primitive Divisors

## Synthesis

This cycle closed the broken-import gap in the Carmichael arc (the historical module
`Shared.CarmichaelHelper` is now restored as a re-export of the proved prime-case helper),
and it added a new self-contained development,
`Catalog/Speculative/AutoResearch/PrimitiveDivisorCompositeLaw.lean`, that lifts the
*composite-index* primitive-divisor theory off of `Nat.fib` and onto the abstract
rank-of-apparition engine `UnifiedRank`.

The organizing discovery is a single equation:

> a prime `q ∣ u n` is a **primitive** divisor of `u n`  ⟺  `rank u q = n`.

Everything classical in this corner of number theory is downstream of it. The
characterization itself, the fact that a prime is primitive for *at most one* index, and the
reformulation "`u n` has a primitive divisor ⟺ some prime has rank exactly `n`" turned out
to need **no hypothesis on the sequence at all** — they are facts about the rank function
(`rank_min`, `dvd_rank`). Only the *proper-divisor reduction* (test divisors of `n`, never
all `k < n`) consumes the strong-divisibility / gcd-meet law `IsStrongDivSeq`. Both the
Fibonacci/Carmichael composite case and the Mersenne/`aⁿ − 1` (Bang–Zsygmondy) composite
case fall out as one-line instances of the same generic reduction.

What remains genuinely open is **existence**: producing the rank-`n` prime for composite
`n`. That is exactly the lone surviving `sorry` in the project, the infinite tail
`n > 10000` of `Shared.CarmichaelProof.fib_carmichael_composite`. The new theorem
`hasPrimitiveDivisor_iff_exists_rank` makes the missing step precise: the whole tail is the
single existential `∃ q, Nat.Prime q ∧ rank Nat.fib q = n`.

## Results Summary

* `isPrimitiveDivisor_iff_rank` — primitivity ⟺ `rank u q = n` (hypothesis-free).
* `rank_of_isPrimitiveDivisor` — the birth index of a primitive prime is its rank.
* `isPrimitiveDivisor_iff_not_proper` — primitivity ⟺ avoiding *proper-divisor* terms
  (biconditional generalization of the Fibonacci-only
  `CarmichaelComposite.primitive_of_not_dvd_proper_divisors`).
* `hasPrimitiveDivisor_of_prime_not_proper` — the existence form Carmichael actually uses.
* `isPrimitiveDivisor_unique_index` — a prime is primitive for at most one index.
* `hasPrimitiveDivisor_iff_exists_rank` — existence ⟺ a prime of rank exactly `n`.
* `fib_hasPrimitiveDivisor_of_not_proper`, `mersenne_hasPrimitiveDivisor_of_not_proper` —
  the two classical instances from one engine.
* Build repair: `Shared/CarmichaelHelper.lean` restored; the Carmichael chain
  (`Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`,
  `PrimitiveDivisorEntryLaw`) compiles again, and the root `lakefile.toml` now points at the
  real `Catalog/` source tree.

## Research Directions

### 1. Close the Carmichael infinite tail via a primitive-part lower bound

State and prove that for every composite `n > 12` the Fibonacci *primitive part*
`Φ_n := ∏_{d ∣ n} F(d)^{μ(n/d)}` exceeds the largest prime factor of `n`, hence
`hasPrimitiveDivisor_iff_exists_rank` yields a rank-`n` prime and discharges the open
`sorry` in `Shared.CarmichaelProof`. **The key insight is** that, by the proper-divisor
reduction, the only obstruction to a primitive divisor is a non-primitive prime, and
Carmichael's intrinsic-divisor lemma forces every non-primitive prime of `Φ_n` to be the
largest prime factor `P` of `n` with multiplicity one; so `Φ_n > P` is *sufficient*, and
`Φ_n ≍ φ^{φ(n)}` with `φ(n) ≥ √(n/2)` dwarfs `P ≤ n` for `n` beyond a tiny bound. This is
falsifiable: a single composite `n` with `Φ_n ≤ P` (or with no rank-`n` prime) refutes it.
**Why now?** The reduction is already formal (`hasPrimitiveDivisor_iff_exists_rank`); the
remaining work is two quantitative lemmas (integrality+growth of `Φ_n`, and the
intrinsic-divisor multiplicity bound), each independently checkable, rather than a monolith.

### 2. A generic Zsygmondy theorem for exponentially growing strong divisibility sequences

Conjecture: every `IsStrongDivSeq u` with `u 1 = 1`, strict positivity, and exponential
growth `u n ≥ c ρ^n` (`ρ > 1`) has a primitive divisor at *every* index `n` past an
explicit threshold depending only on `c, ρ`. **The key insight is** that
`isPrimitiveDivisor_iff_not_proper` shows the non-primitive part of `u n` is supported on
primes whose rank is a *proper* divisor of `n`, so it divides `∏_{p ∣ n} u(n/p)`, a quantity
of size at most `ρ^{n·∑ 1/p}` — strictly smaller than `u n ≈ ρ^n` once the prime-divisor sum
of `n` is bounded away from `1`. Falsifiable: exhibit such a `u` and an index past the
threshold with no primitive divisor. **Why now?** `PrimitiveDivisorCompositeLaw` already
proves the structural reduction for *arbitrary* SDS; only the analytic size comparison is
missing, and it is uniform across Fibonacci, Mersenne, and Lucas sequences simultaneously.

### 3. Bang–Zsygmondy for `2ⁿ − 1` from the same engine

Specialize Direction 2 to `u n = aⁿ − 1`: for `a ≥ 2` and `n ∉ {1, 6}` (and `a + 1` not a
power of two when `n = 2`), `aⁿ − 1` has a primitive prime divisor. **The key insight is**
that `mersenne_hasPrimitiveDivisor_of_not_proper` already reduces this to proper-divisor
avoidance, and the size bound here is *elementary*: `aⁿ − 1 > a^{n - n/p_min}` beats the
product of the maximal proper terms, so the cyclotomic detour Fibonacci needs is avoidable.
Falsifiable: any `n ≥ 7` with `2ⁿ − 1` all of whose prime factors already divide some
`2ᵏ − 1`, `k < n`, refutes it. **Why now?** The Mersenne instance is the cleanest test bed
for the generic growth argument before tackling the harder Fibonacci constant `φ`, and it
delivers a second classical theorem from infrastructure already in the file.

### 4. The rank spectrum: which `n` are hit, and how often

Define the *rank spectrum* `S_u := { rank u q : q prime }` and conjecture that for
`u = Nat.fib` we have `S_fib = ℕ_{>0} \ {finite set}` — i.e. all but finitely many indices
are some prime's rank — quantitatively `#{n ≤ X : HasPrimitiveDivisor Nat.fib n} = X - O(1)`.
**The key insight is** that `isPrimitiveDivisor_unique_index` makes `q ↦ rank u q` a
well-defined "birth-index tag," so primitive divisors at distinct indices are carried by
*distinct* primes; counting indices with a primitive divisor becomes counting the image of a
genuine partition of the prime divisors of the `u n`. Falsifiable: a positive-density set of
composite `n` with empty fibre would refute it (and would also refute Carmichael). **Why
now?** The uniqueness/tagging theorem is freshly available, turning a vague density question
into a statement about the fibres of an explicit map.

### 5. Cross-domain synchronization of Fibonacci and Mersenne ranks

Conjecture a quantitative incompatibility: there is no prime `q > 5` with
`rank Nat.fib q = rank (fun k => 2^k - 1) q`, i.e. a prime never makes its *first*
appearance at the same index in the Fibonacci and Mersenne worlds (apart from small
exceptions). **The key insight is** that `rank Nat.fib q` is governed by `q`'s behavior
modulo the Pisano period while `rank (2^· - 1) q` is the multiplicative order of `2` mod `q`;
these are controlled by *different* characters of `(ℤ/qℤ)^×`, so coincidences should be
sparse — and `hasPrimitiveDivisor_iff_exists_rank` translates any coincidence into a shared
primitive index for two unrelated sequences. Falsifiable directly: search primes `q` and
compare the two ranks. **Why now?** Both rank functions live in one engine (`UnifiedRank`)
for the first time, so the comparison is a single computation rather than two separate
theories, and the unique-index tagging gives the statement a clean formal shape.
