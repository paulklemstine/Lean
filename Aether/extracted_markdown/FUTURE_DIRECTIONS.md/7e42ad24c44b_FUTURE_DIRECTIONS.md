# Future Directions: Entry-Point Theory and Carmichael's Primitive-Divisor Theorem

## Synthesis

This cycle closed the load-bearing gaps in the catalog's Baker–Norine-adjacent
Fibonacci divisor theory and welded two previously separate strands together: the
**entry-point (rank-of-apparition) characterization** and **Carmichael's
primitive-divisor theorem**.

The organizing principle that emerged is that essentially all *qualitative*
divisibility facts about Fibonacci numbers are governed by a single bridge lemma,
`FibEntryChar.fib_dvd_iff_entryPt_dvd : m ∣ F(k) ↔ α(m) ∣ k`, which states that the
apparition-index set `{k | m ∣ F k}` is the principal ideal `(α m)` of `(ℕ, ∣)`.
Every theorem proved this cycle is a consequence of that ideal structure plus
elementary lattice algebra in `ℕ`; the Fibonacci-specific content is fully localized
in `Nat.fib_gcd`. The one place where this principle is *not* enough — and where
genuinely quantitative (size/growth) input is required — is the composite tail of
Carmichael's theorem, which is now the sharply isolated frontier (Direction 1).

## Results Summary (all `sorry`-free, axioms = `propext, Classical.choice, Quot.sound`)

1. **`FibEntryChar.fibEntryPt_mul_coprime`** (was a `sorry` research target): the
   multiplicative **lcm law** `α(a·b) = lcm(α a, α b)` for coprime `a, b`. This was
   the keystone that unlocks the already-present finite lcm law
   `FibEntryChar.fibEntryPt_prod_coprime`, i.e. reconstruction of `α(m)` from the
   prime-power factorization of `m`.

2. **`fib_primitive_divisor_prime`** (reconstructed the missing
   `Shared/CarmichaelHelper.lean`): the **prime-index case** of Carmichael's
   primitive-divisor theorem — for prime `n ≥ 13`, `F(n)` has a primitive prime
   divisor. The proof is fully elementary: a prime index collapses the divisor
   lattice of `n` to `{1, n}`.

3. **`FibPrimitivePrimeIndex.{fibEntryPt_eq_of_prime_index,
   primitive_iff_dvd_of_prime_index, primitive_set_eq_dvd_set_of_prime_index}`**
   (new file): a conceptual upgrade showing that *at a prime index every prime
   divisor of `F(n)` is automatically primitive*, so the set of primitive prime
   divisors of `F(n)` literally equals the set of all its prime divisors.

The remaining open `sorry` in the project is exactly one statement,
`fib_carmichael_composite` for `n > 10000` (the composite tail), which is the
content of Direction 1 below.

## Research Directions

### 1. The composite tail of Carmichael's theorem via a Fibonacci-cyclotomic lower bound

For composite `n > 10000` we still owe a proof that `F(n)` has a primitive prime
divisor; the finite range `13 ≤ n ≤ 10000` is already discharged by `native_decide`
on the explicit coprime-part construction (`fibCoprimePart`). Formalize the
Fibonacci-cyclotomic value `Φ_n` with `F(n) = ∏_{d ∣ n} Φ_d`, prove the growth
lower bound `Φ_n > n + 1`, and prove that at most one *intrinsic* prime (the largest
prime factor of `n`, dividing `Φ_n` to the first power only) can fail to be
primitive; conclude `fibCoprimePart n > 1`. **The key insight is** that the obstruction
to primitivity is a single, explicitly bounded intrinsic prime, so a clean numerical
inequality `Φ_n > p_max(n)` — not deep transcendence theory — suffices to win for all
large `n`. **Why now?** The entry-point ideal theorem and the computational
`fibCoprimePart` reduction are both already in place, so the only missing component is
the standalone real-analytic bound on `Φ_n`; the problem has been reduced to a
self-contained inequality. This is falsifiable: exhibit a composite `n > 12` with no
primitive divisor (Carmichael predicts none exist), or a value of `n` where
`Φ_n ≤ p_max(n)`.

### 2. The prime-power lifting law `α(p^e) = p^{e-1} · α(p)` (away from Wall–Sun–Sun)

The lcm law reconstructs `α` across coprime factors; the missing piece is `α` on a
single prime power. Conjecture: for an odd prime `p` that is *not* a Wall–Sun–Sun
prime, `α(p^e) = p^{e-1} · α(p)` for all `e ≥ 1`. **The key insight is** that this is
a lifting-the-exponent phenomenon: `v_p(F_k)` jumps by exactly one each time `k`
passes a multiple of `p · α(p)`, so the apparition index of `p^e` scales by `p` per
extra exponent. **Why now?** With `fibEntryPt_mul_coprime` and
`fibEntryPt_prod_coprime` proved, the prime-power law is the *last* ingredient needed
for a complete closed-form `α(m)` from `m`'s factorization. Falsifiable: any prime
power `p^e` with `α(p^e) ≠ p^{e-1} α(p)` would either be a Wall–Sun–Sun witness
(famous open search) or refute the conjecture.

### 3. A decidable, verified algorithm computing `α(m)` from the factorization

Package Directions 1–2 into an executable `decide`/`#eval`-able function
`fibEntryPtAlgo : ℕ → ℕ` together with a theorem `fibEntryPtAlgo m = α(m)` for all
`m ≥ 1`, by combining the (to-be-proved) prime-power law with the proven finite lcm
law over the prime-power factors. **The key insight is** that `α` is *fully
multiplicative-via-lcm* on coprime parts, so once `α` on prime powers is computable,
`α` on all of `ℕ` is computable by a single `Finset.lcm` over the factorization —
no search over Fibonacci indices is needed. **Why now?** The reduction is already
proved (`fibEntryPt_prod_coprime`); only the per-prime-power evaluator and its
correctness lemma remain, turning an `O(α(m))`-search definition into an
`O(log m)`-after-factorization algorithm. Falsifiable by `#eval`: any `m` where the
algorithm disagrees with a brute-force search for the least `k` with `m ∣ F(k)`.

### 4. Counting and density of primitive prime divisors

Define `primCount n` = number of primes `p` with `α(p) = n`, equivalently (by this
cycle's `entryPt_eq_iff_primitive`) the number of primitive prime divisors of `F(n)`.
Carmichael gives `primCount n ≥ 1` for `n ∉ {1,2,6,12}`; conjecture and formalize the
sharper `primCount n ≥ 2` for all sufficiently large `n`, and that the primitive part
`F(n) / (intrinsic factor)` is composite for large `n`. **The key insight is** that
the size bound from Direction 1 (`Φ_n` grows like `φ^{φ(n)}`) vastly exceeds a single
prime, forcing *multiple* primitive divisors once `Φ_n` exceeds `p_max(n)^2`. **Why
now?** The set-level identity `primitive_set_eq_dvd_set_of_prime_index` proved here
gives an exact handle on the prime-index case, the natural base case for an induction
on the number of prime factors. Falsifiable: a large `n` with a *prime* primitive
part would refute the "≥ 2" conjecture.

### 5. Lifting the entry-point ideal theorem to general Lucas sequences

The proof of `fib_dvd_iff_entryPt_dvd` used only the strong-divisibility identity
`gcd(F_m, F_n) = F_{gcd(m,n)}`. Abstract the entire entry-point package
(`fibEntryPt`, the ideal theorem, the lcm law, monotonicity under divisibility) to an
arbitrary **strong divisibility sequence** `a : ℕ → ℤ` satisfying
`gcd(a_m, a_n) = a_{gcd(m,n)}`, then instantiate it at the Lucas sequences `U_n(P,Q)`
and at `a_n = x^n - 1` (recovering classical cyclotomic order theory). **The key
insight is** that *nothing* in the qualitative theory is special to Fibonacci: the
ideal structure of the apparition set is a formal consequence of the gcd identity
alone, so a single abstract development subsumes Fibonacci, Mersenne, and cyclotomic
rank-of-apparition theory. **Why now?** This cycle demonstrated that all the proofs
factor through `Nat.fib_gcd`; generalizing the hypothesis to an abstract strong
divisibility law is a mechanical refactor with high reuse across the catalog's number
theory files. Falsifiable: any strong divisibility sequence whose apparition set is
*not* an ideal of `(ℕ, ∣)` would break the abstraction.
