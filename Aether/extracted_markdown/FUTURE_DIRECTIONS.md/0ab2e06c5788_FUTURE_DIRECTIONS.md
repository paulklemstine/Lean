# Future Directions: Rank of Apparition as an Arithmetic Bridge

## Synthesis

The cycle set out to build a *valuation-controlled* bridge from Fibonacci
divisibility to Carmichael-type composite witnesses, expecting (per the concept
brief) that the converse divisibility law `m ∣ F n ⟹ a(m) ∣ n` for prime powers
would need p-adic valuation-depth subadditivity (`vdepth_sum_le`-style control of
recurrence growth). The central discovery of `Bridges/FibRankApparition.lean` is
that this expectation is *wrong in a productive way*: the single gcd identity
`Nat.fib_gcd` collapses the entire prime-power valuation ladder. The converse
holds for **every** modulus simultaneously, because `m ∣ F n` and `m ∣ F a(m)`
together force `m ∣ F (gcd n a(m))`, and minimality of `a(m)` pins the gcd to
`a(m)`. As a consequence the divisibility profile `m ∣ F n ↔ a(m) ∣ n`, the
coprime composition law `a(mn) = lcm(a(m), a(n))`, and the composite-witness
theorem all fall out of pure index lattice arithmetic. The only genuinely
non-trivial analytic input is *existence* of `a(m)` — a Pisano-period statement
absent from Mathlib — which we proved by pigeonhole on the invertible pair map
`n ↦ (F n, F (n+1))` in `ZMod m`.

## Results Summary

- `exists_pos_dvd_fib`: every positive modulus has a rank of apparition.
- `dvd_fib_iff_rankApp_dvd`: the full divisibility profile, for all `m`.
- `fib_divisor_set_eq_multiples`: `{n | m ∣ F n}` is exactly the multiples of `a(m)`.
- `rankApp_coprime_mul`: `a(mn) = lcm(a(m), a(n))` for coprime `m, n`.
- `carmichael_fib_witness`: composite `mn` whose Fibonacci divisibility test is
  governed by a single index class `lcm(a(m), a(n))`.
- Concrete computed ranks via `decide`, including the worked witness `a(10) = 15`.

## Research Directions

### 1. Quantitative Pisano bound from the pigeonhole witness
Our existence proof extracts a positive index `d ≤ m²` with `m ∣ F d` purely from
the finiteness of `(ZMod m)²`. Conjecture: `rankApp m ≤ m² ` for all `m ≥ 1`, and
moreover `rankApp m ≤ 6m` with equality iff `m = 2·5^k` (the classical worst case).
**The key insight is** that the pigeonhole collision already lands inside the
single orbit through `(0,1)`, so the *first* return — not merely some return —
is what the period controls, turning a counting bound into an orbit-length bound.
**Why now?** The constructive collision witness is already formalized; upgrading
"some `d ≤ m²`" to "the least such `d`" only requires relating `rankApp` to the
order of the companion matrix in `GL₂(ZMod m)`, a finite-group computation Mathlib
fully supports.

### 2. Multiplicativity of the rank-to-period ratio
Define `pis m` = Pisano period and study `pis m / rankApp m ∈ {1, 2, 4}`. Conjecture:
this ratio is determined by `m` mod small powers of 2 and 5, and is itself
"coprime-multiplicative" in the sense `ratio(mn) = lcm` of factor ratios for
coprime `m, n`. **The key insight is** that both `pis` and `rankApp` are governed
by the *same* companion-matrix order data, so their ratio measures only the order
of `(-1)`-type scalars, a bounded local invariant. **Why now?** `rankApp` and its
coprime-composition law are proved; defining `pis` via the same `ZMod m` pair map
and proving its lcm-composition is a direct structural analogue we can copy.

### 3. Fibonacci pseudoprimes as apparition-collision witnesses
A composite `n` is a *Fibonacci pseudoprime* when `n ∣ F_{n - (5|n)}`. Conjecture:
`carmichael_fib_witness` produces infinitely many composite `n = m·k` (coprime,
both `> 1`) for which the Jacobi-symbol-shifted index `n - (5|n)` is a multiple of
`lcm(a(m), a(k))`, hence indistinguishable from prime behaviour under the Fibonacci
test. **The key insight is** that pseudoprimality is exactly the statement that the
*global* index `n ± 1` lands in the *local* index class governed by the lcm of
apparition ranks — our profile theorem makes this a divisibility check, not an
analytic estimate. **Why now?** The profile `{n | m ∣ F n} = multiples of a(m)` is
formal, so pseudoprimality reduces to an arithmetic congruence on `lcm(a m) (a k)`
that is decidable and searchable by `#eval`.

### 4. Lucas-sequence generalization of the bridge
Replace `Nat.fib` by a general Lucas sequence `U_n(P,Q)` with `gcd(Q, m) = 1`.
Conjecture: the gcd identity `U_{gcd(i,j)} = gcd(U_i, U_j)` (mod the discriminant)
persists, so `dvd_fib_iff_rankApp_dvd`, coprime composition, and the composite
witness all generalize verbatim, yielding a uniform apparition calculus for all
strong-Lucas primality tests. **The key insight is** that the bridge never used
anything about Fibonacci beyond `U_{gcd} = gcd(U)` and invertibility of the
recurrence over `ZMod m`; isolating these two axioms abstracts the whole file into
a reusable `LucasLike` typeclass. **Why now?** Our proofs already factor through
exactly those two facts, so abstracting them is refactoring, not new mathematics.

### 5. Entropy of the divisibility profile and a Carmichael census
Treat the index class `a(m)` as a "code" and measure the Shannon entropy of the
residue distribution `{F n mod m}` over one period. Conjecture: composite witnesses
from `carmichael_fib_witness` are precisely the moduli where this entropy attains
the prime-power value, giving an information-theoretic Carmichael census linking to
`Shared/SelbergClassCensus.lean` and `Shared/EntropyLatticeCrypto.lean`. **The key
insight is** that "indistinguishability" of a composite from a prime under the
Fibonacci test is literally equality of two profile entropies, converting a
number-theoretic census into an entropy-equality search. **Why now?** With the
profile pinned to `multiples of a(m)`, the period and its residue multiset are
finite, computable objects, so the entropy is `#eval`-able and the census is a
finite search the next cycle can run directly.
