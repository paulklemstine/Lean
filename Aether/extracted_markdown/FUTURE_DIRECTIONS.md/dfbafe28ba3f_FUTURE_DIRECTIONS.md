# Future Directions — The Lucas Bridge and the Rank of Apparition

## Synthesis

This cycle closed the last open gap in the *Fibonacci-only* picture of the rank of
apparition by adding its missing companion: the **Lucas sequence** `L`. Where the catalog
already pinned Fibonacci divisibility to the ideal `m ∣ F k ↔ α(m) ∣ k`, the new file
`Catalog/Applications/FibonacciLucasBridge.lean` shows that the *even-index* half of that
ideal factors through `L` via the doubling identity `F(2n) = F n · L n`, and that for an
**odd prime** `p` with rank `r = α(p)`,
```
p ∣ L n   ↔   (r ∣ 2n  ∧  r ∤ n).
```
In other words, the Lucas apparition set of an odd prime is exactly the set of indices that
the rank "reaches only after doubling" — the indices `n` with `r ∣ 2n` but `r ∤ n`. Together
with the supporting identities `L n² − 5 F n² = 4·(−1)ⁿ`, `gcd(L n, F n) ∣ 2`, and a fully
self-contained pigeonhole proof that *every* positive modulus has a rank, the rank of
apparition is now a two-sided object governing both the Fibonacci and Lucas worlds.

## Results Summary

All proofs are complete (`sorry = 0`), depending only on `propext`, `Classical.choice`,
`Quot.sound`.

- `lucasNum` — the Lucas sequence, new to both Mathlib and the catalog.
- `fib_two_mul_eq_fib_mul_lucas` : `F(2n) = F n · L n` (the doubling bridge).
- `lucas_sq_sub_five_fib_sq` : `L n² − 5 F n² = 4·(−1)ⁿ` over `ℤ`.
- `gcd_lucas_fib_dvd_two` : `gcd(L n, F n) ∣ 2`.
- `exists_pos_dvd_fib` : every positive modulus divides some positive-index Fibonacci.
- `dvd_fib_iff_rank_dvd` : the ideal-structure theorem, restated self-containedly.
- `prime_dvd_lucas_iff_rank` : the marquee Lucas-apparition criterion for odd primes.

## Research Directions

### 1. The 2-adic refinement: `p ∣ L n ↔ v₂(n) = v₂(r) − 1` for odd primes
The criterion `r ∣ 2n ∧ r ∤ n` is secretly a statement about the 2-adic valuation `v₂`.
Writing `r = 2^a · s` and `n = 2^b · t` with `s, t` odd, the conjecture is that for an odd
prime `p` with rank `r`, `p ∣ L n` holds **iff** `s ∣ t` and `b = a − 1` (so in particular
`a ≥ 1`, i.e. `r` is even). This would turn the divisibility test into a single valuation
equation and explain *why exactly one residue class of `v₂(n)` works*.
**The key insight is** that `r ∣ 2n ∧ r ∤ n` forces `v₂(2n) ≥ v₂(r) > v₂(n)`, which pins
`v₂(n)` to the unique value `v₂(r) − 1`. **Why now?** We already have
`prime_dvd_lucas_iff_rank` and Mathlib's `Nat.factorization`/`padicValNat`, so this is a
pure ℕ-valuation lemma layered on a proven biconditional — falsifiable by a single `#eval`
sweep over small primes if the valuation equation ever disagrees with `p ∣ L n`.

### 2. A Lucas rank of apparition and a Lucas ideal theorem
Define `β(m)` = least `k > 0` with `m ∣ L k` (when it exists). Unlike `F`, the sequence `L`
is **not** a divisibility sequence (`gcd(L m, L n) ≠ L (gcd m n)` in general), so the index
set `{k : m ∣ L k}` is *not* a principal ideal. The conjecture is a precise description:
for an odd prime `p` with even rank `r = α(p)`, `{n : p ∣ L n}` is the arithmetic
progression `(r/2) + r·ℕ` (and is empty when `r` is odd).
**The key insight is** that the marquee theorem already computes this set as
`{n : r ∣ 2n ∧ r ∤ n}`, which collapses to a single coset mod `r` exactly when `r` is even.
**Why now?** `prime_dvd_lucas_iff_rank` reduces the whole question to elementary coset
algebra in `ℤ/r`, so the AP description is within immediate reach and is falsified the moment
a prime's Lucas-divisor indices fail to form one progression.

### 3. Carmichael's primitive-divisor theorem for Lucas numbers
The catalog has Carmichael for Fibonacci (modulo the `n > 10000` tail in
`Shared/CarmichaelProof.lean`). The Lucas analogue states that `L n` has a primitive prime
divisor for all `n ∉ {1, 6}`. Direction 2 gives the engine: a prime `p` is a *primitive*
divisor of `L n` iff its even rank satisfies `r/2 = n` with `r ∤ k` for `k < n`, i.e. iff
`α(p) = 2n`. So Lucas primitivity transfers **exactly** to Fibonacci apparition at the
doubled index.
**The key insight is** that the doubling bridge makes "primitive divisor of `L n`" literally
equal to "prime of Fibonacci rank `2n`", so Carmichael-for-Lucas is a *corollary* of
Carmichael-for-Fibonacci at even indices — no new analytic input is needed.
**Why now?** With `fib_two_mul_eq_fib_mul_lucas` and `dvd_fib_iff_rank_dvd` proven, the
reduction is formal; it also isolates `n = 6` (where `F 12 = 144` is the classical
non-primitive index) as the unique Lucas exception, a falsifiable, computable claim.

### 4. The Pisano period as the localization length: `r(m) ∣ π(m)` and `π/r ∈ {1,2,4}`
The pigeonhole proof `exists_pos_dvd_fib` secretly constructs the **Pisano period** `π(m)`
(the period of the pair sequence `(F k, F(k+1)) mod m`). The classical theorem is that the
rank divides the period and the quotient `π(m)/r(m)` is always `1`, `2`, or `4`, governed by
the order of `F(r+1)` modulo `m`. Framed homotopically: the orbit of `(0,1)` under the shift
permutation is a *loop of length `π(m)`*, and `r(m)` is the first return to the `F`-axis —
the quotient measures how many times the loop wraps before closing.
**The key insight is** that `F(r(m)+1) mod m` is a unit whose multiplicative order is exactly
`π/r`, and `(−1)^r` constraints (from `L r² − 5 F r² = 4(−1)^r`, already proven) force that
order into `{1,2,4}`. **Why now?** The shift permutation and its finiteness are now formalized
inside `exists_pos_dvd_fib`; promoting that orbit to a defined `pisanoPeriod` and proving
`r ∣ π` is the next mechanical step, with the `{1,2,4}` bound as the deep, falsifiable payoff.

### 5. The rank as a localization functor on the divisibility poset
View `(ℕ, ∣)` as a thin category. The map `α : m ↦ rank m` sends it into `(ℕ, ∣)` and the
ideal theorem `m ∣ F k ↔ α(m) ∣ k` says `α` is the **left adjoint / localization** that
inverts exactly the Fibonacci-divisibility relations: `α` is `lcm`-multiplicative on coprime
moduli and `gcd`-compatible. The conjecture is that `α` factors as a composite of the
prime-power restriction with a `lcm`-colimit, making `α(m)` the colimit of `α` over the
prime-power divisors of `m` — a genuinely categorical reconstruction theorem.
**The key insight is** that `prime_dvd_lucas_iff_rank` and `dvd_fib_iff_rank_dvd` together
exhibit `α` as preserving the lattice operations that the localization must invert, so the
universal property is *already witnessed* on objects. **Why now?** The catalog's
`FibonacciEntryPointMultiplicative` proved the `lcm` law on coprime factors; packaging it as
an honest adjunction/colimit statement in Mathlib's `CategoryTheory` is the natural unifying
capstone, and it is falsifiable by exhibiting any `m` whose rank is not the `lcm` of its
prime-power ranks.
