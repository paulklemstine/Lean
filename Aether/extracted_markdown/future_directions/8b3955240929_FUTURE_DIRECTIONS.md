# Future Directions — Closing the Fibonacci Divisibility Calculus and the Road to Carmichael

## Synthesis

This cycle hardened the foundation that the Carmichael primitive-divisor
development was *resting on but had not actually isolated*. The previous
Carmichael files (`Catalog/Speculative/CarmichaelPrimitiveDivisor.lean`,
`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`,
`Catalog/Shared/CarmichaelProof.lean`) repeatedly re-derive the same descent
step — "if `p ∣ F(m)` and `p ∣ F(n)` then `p ∣ F(gcd m n)`" — inline, from
`Nat.fib_gcd`, each time. We extracted this once and cleanly, and went further:
we proved the **sharp divisibility characterization** `F m ∣ F n ↔ m ∣ n`
(`m ≥ 3`), the exact converse to Mathlib's `Nat.fib_dvd`, which to our knowledge
is *not* in Mathlib. The new file
`Catalog/Applications/FibonacciDivisibilityCalculus.lean` is therefore both a
de-duplication and a genuine strengthening.

The strategic picture: the Fibonacci sequence is a *strong divisibility
sequence* (SDS). Every SDS over `ℕ` carries a "calculus" turning index gcd into
value gcd. The interesting frontier is how far this calculus determines, and is
determined by, the **rank-of-apparition** (entry-point) function, and whether
the *primitive-divisor* phenomenon (Carmichael) is a formal consequence of SDS
axioms plus a single growth inequality.

## Results Summary

Proven sorry-free this cycle (axioms: `propext`, `Classical.choice`,
`Quot.sound`):

1. `fib_gcd_identity` — `F(gcd m n) = gcd(F m, F n)` (the SDS law, restated).
2. `fib_coprime_of_coprime` — coprime indices ⇒ coprime Fibonacci values.
3. `fib_dvd_iff` — `F m ∣ F n ↔ m ∣ n` for `m ≥ 3` (the missing converse to
   `Nat.fib_dvd`; hypothesis `m ≥ 3` shown to be exactly sharp).
4. `prime_dvd_fib_gcd` — the rank-of-apparition descent step, isolated once.

## Research Directions

### 1. The entry-point function is a divisor-respecting "logarithm" of the SDS.

Define `α(p)` = the rank of apparition of a prime `p` (least `k > 0` with
`p ∣ F(k)`). Conjecture: for every prime `p ≠ 5`, `p ∣ F(n) ↔ α(p) ∣ n`, and
moreover `α` is the *unique* function `ℕ → ℕ` with `α(p) ∣ n ↔ p ∣ F(n)` for all
`n`. This makes `α` a literal logarithm: it linearizes the multiplicative
divisor lattice of `{F(n)}` into the additive divisibility lattice of `ℕ`.
**The key insight is** that `fib_dvd_iff` already gives the index-level skeleton
(`F m ∣ F n ↔ m ∣ n`), so the prime-level statement is its "atomization" — one
only needs that `α(p)` is well defined and minimal, which `prime_dvd_fib_gcd`
supplies via descent to the gcd. **Why now?** Both load-bearing lemmas were just
proved in this cycle; the remaining step is a clean minimization argument with no
appeal to Pisano periods, which is exactly the kind of self-contained target the
prover handles well. *Falsifiable:* the prime `5` (with `α(5) = 5` and `25 ∣
F(25)` but the lifting-the-exponent behaviour) is the stress test — if the clean
`↔` fails anywhere, it fails at `p = 5`.

### 2. Carmichael's theorem is SDS + one exponential-vs-polynomial inequality.

The open `sorry` in `Catalog/Shared/CarmichaelProof.lean` (the composite tail
`n > 10000`) should not need any Fibonacci-specific input beyond growth.
Conjecture: for `n` large, the *primitive part* `P(n) = F(n) / ∏_{d∣n, d<n}
(F(d)-stripped factors)` satisfies `P(n) > n`, hence `P(n) > 1`, hence a
primitive prime exists. The bound `P(n) > n` follows from `F(n) ≥ φ^{n-2}` and
the fact that the total non-primitive content is at most `∏_{d∣n,d<n} F(d) ≤
F(n/2)^{d(n)} = φ^{O(n^{1/2+ε})}`. **The key insight is** that the descent lemma
`prime_dvd_fib_gcd` reduces "primitive divisor of `F(n)`" to "coprime to all
`F(d)` for proper `d ∣ n`", so the entire infinite tail collapses to a single
*size* comparison rather than any new arithmetic — exactly the structure the
existing computational `native_decide` band exploits, now made asymptotic.
**Why now?** The finite band (`n ≤ 10000`) is already discharged by
`native_decide`; the only missing piece is the growth inequality, which is a
real-analytic estimate (`Real.log`-based) of the kind that decomposes cleanly
into 3–4 sub-lemmas. *Falsifiable:* compute `P(n)` for `n` a highly composite
number near the crossover; if `P(n) ≤ n` for any composite `n > 12`, the bound
(and the strategy) is wrong.

### 3. Universality: every strong divisibility sequence over `ℕ` has a calculus.

Abstract away from Fibonacci. Conjecture: if `a : ℕ → ℕ` satisfies
`a(gcd m n) = gcd(a m, a n)` (the SDS axiom) and is eventually strictly
increasing, then `a m ∣ a n ↔ m ∣ n` for all sufficiently large `m`, with the
threshold determined solely by where `a` becomes injective. **The key insight
is** that our proof of `fib_dvd_iff` used *only* `fib_gcd_identity` plus
`StrictMonoOn` injectivity — nothing else about Fibonacci — so it lifts verbatim
to the abstract SDS setting (Lucas sequences, Mersenne numbers `2^n - 1`,
`q`-integers `[n]_q`, elliptic divisibility sequences over `ℤ`). **Why now?**
The Fibonacci proof is a one-screen template; generalizing it produces an
immediately reusable Mathlib-grade lemma (`StrongDivisibilitySeq.dvd_iff`) that
several catalog files (`StrongDivPrimitiveCriterion`,
`StrongDivisibilityEntryPoint`, `StrongDivisibilityRankBridge`) currently
re-prove case by case. *Falsifiable:* a non-monotone SDS where the `↔` fails
above every threshold would refute the "eventually increasing suffices" claim.

### 4. The coprimality functor is exact on the Fibonacci divisor lattice.

`fib_coprime_of_coprime` is one half of a stronger statement: the map
`n ↦ F(n)` should be a *lattice homomorphism* from `(ℕ, gcd, lcm)` into the
multiplicative monoid of `ℕ` modulo units, exact on the gcd side. Conjecture:
`lcm(F m, F n) ∣ F(lcm m n)`, with equality iff `gcd m n ∈ {1, 2}`. **The key
insight is** that `gcd(F m, F n) = F(gcd m n)` (equality) but `lcm` can only
*divide*, and the obstruction is precisely the doubled factor at `gcd m n` — the
same `F(1) = F(2) = 1` defect that forced `m ≥ 3` in `fib_dvd_iff`. **Why now?**
The gcd side is closed; the lcm side is its formal dual and the defect locus is
already characterized, so the proof reduces to one `Nat.gcd_mul_lcm`
manipulation. *Falsifiable:* a pair `(m, n)` with `gcd m n ≥ 3` and
`lcm(F m, F n) = F(lcm m n)` would refute the equality criterion.

### 5. Entry points realize every modulus: an inverse Carmichael phenomenon.

Conjecture (bold): for every `k ≥ 1` there exists a prime `p` with rank of
apparition exactly `k`, *except* `k ∈ {1, 2}` — i.e. the entry-point function is
surjective onto `ℕ_{≥3}` restricted to primes. This is the prime-existence
strengthening of Carmichael: not only does `F(k)` have a primitive prime divisor
for `k ≥ 13`, but the *small* exceptional `k` are an explicit finite list.
**The key insight is** that a primitive prime divisor of `F(k)` is exactly a
prime with `α(p) = k` (by `prime_dvd_fib_gcd` + minimality), so Carmichael's
theorem *is* the surjectivity statement for `k ≥ 13`, and the residual cases
`3 ≤ k ≤ 12` are a `decide`. **Why now?** Once direction 2 closes the composite
tail, surjectivity is a corollary requiring only the finite check — turning a
deep theorem into a packaging step. *Falsifiable:* find `k ≥ 3` such that every
prime dividing `F(k)` also divides some `F(j)` with `j < k` (a `k` with no
primitive divisor); the smallest candidates are `k = 6` (`F(6) = 8 = 2^3`,
`α(2) = 3`) — already a genuine exception, sharpening the conjecture's lower
bound to `k ∉ {1, 2, 6}`.
