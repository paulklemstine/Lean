# Future Directions: Fibonacci Rank of Apparition and Primitive Divisors

## Synthesis

This cycle isolated the *rank of apparition* `r(p) = min { k > 0 : p ∣ F(k) }`
as the single organizing principle behind the divisibility structure of the
Fibonacci sequence, and proved (in `Shared/FibonacciRankTheory.lean`, `sorry = 0`):

- `fib_coprime_of_coprime_index`: coprime indices give coprime Fibonacci numbers;
- `fib_dvd_iff_rank_dvd`: `p ∣ F(n) ↔ r(p) ∣ n` (no primality needed);
- `fibRank_eq_iff_primitive`: `p` is a primitive divisor of `F(n)` iff `r(p) = n`;
- `carmichael_range`: an algorithmic, `native_decide`-certified proof that every
  `F(n)` for `n ∈ [3,60] \ {6,12}` has a primitive prime divisor, bridged through
  `(F n).primeFactorsList` to the genuine number-theoretic statement.

These are exactly the "key ingredients" the catalog's `Shared/CarmichaelProof.lean`
and `Speculative/AutoResearch/CarmichaelComposite.lean` need: those files reduce
Carmichael's theorem to (i) a finite computational check on a bounded range and
(ii) an *infinite tail* for composite `n > 10000`, which remains the lone `sorry`
in `CarmichaelProof.lean`. The rank/primitivity characterization here is the
clean conceptual core that any honest tail argument must invoke.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_coprime_of_coprime_index` | `Coprime m n → Coprime (F m) (F n)` | proved |
| `fib_dvd_iff_rank_dvd` | `p ∣ F n ↔ r(p) ∣ n` | proved |
| `fibRank_eq_iff_primitive` | primitive at `n` ↔ `r(p) = n` | proved |
| `carmichael_range` | primitive divisor exists for `n ∈ [3,60]\{6,12}` | proved (`native_decide`) |

## Research Directions

### 1. Closing the composite infinite tail of Carmichael's theorem

The outstanding `sorry` in `Shared/CarmichaelProof.lean` asserts that every
composite `n > 10000` yields a Fibonacci number `F(n)` with a primitive prime
divisor. The conjecture to attack constructively: for `n ≥ 13`, the *primitive
part* `Φ_n := F(n) / ∏_{d | n, d < n} gcd(F(n), F(d))` always exceeds `1`, and
moreover `Φ_n` is divisible by a prime `p` with `r(p) = n`.
**The key insight is** that `fibRank_eq_iff_primitive` reduces "primitive divisor
exists" to "some prime has rank exactly `n`", so the tail becomes a statement
about the multiplicative size of the cyclotomic-like factor `Φ_n` versus the
product of intrinsic (non-primitive, i.e. `p ∣ n`) prime powers — a comparison
that admits explicit lower bounds from `F(n) ~ φ^n` growth.
**Why now?** With `fib_dvd_iff_rank_dvd` and `fibRank_eq_iff_primitive` already
formalized, the remaining gap is purely an analytic size estimate; the
combinatorial/divisibility scaffolding no longer has to be reproved.

### 2. Sharp bound on intrinsic primes (a falsifiable size estimate)

Conjecture: the only primes that can divide `F(n)` non-primitively and obstruct a
primitive divisor are those `p` with `p ∣ n`, and their total `p`-adic
contribution to `F(n)` is at most `n · log_φ(n)` in logarithmic size. Concretely,
`∑_{p | n} v_p(F(n)) · log p < log F(n)` for all `n ∉ {1,2,6,12}`.
**The key insight is** Lifting-the-Exponent: `v_p(F(n)) = v_p(F(r(p))) + v_p(n / r(p))`
when `p | n`, so the intrinsic contribution is logarithmic while `log F(n)` is
linear in `n`. **Why now?** The `Algebra/...Lifting_the_Exponent...` catalog file
already states `fib_gcd_identity`; combining it with `fib_dvd_iff_rank_dvd` makes
this a finite-data inequality amenable to `interval_cases` + growth bounds.

### 3. Generalization to Lucas sequences `U_n(P,Q)`

Conjecture: every theorem in `FibonacciRankTheory.lean` holds verbatim for a
nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1`, with `F` replaced by
`U` and `Nat.fib_gcd` replaced by the strong divisibility `gcd(U_m,U_n)=U_{gcd}`.
**The key insight is** that none of the four proofs used anything specific to
`F` beyond strong divisibility and `U_1 = 1`; the rank machinery is an abstract
consequence of a *divisibility sequence*. **Why now?** Abstracting to a typeclass
`StrongDivisibilitySequence` would let the catalog's many Fibonacci files share a
single proof, eliminating duplication flagged in the catalog-synthesis brief.

### 4. Decidable rank computation and a verified `r(p)` algorithm

Conjecture: there is a `decide`-checkable function `rankBudget : ℕ → ℕ` with
`r(p) ≤ rankBudget p` for all primes `p`, namely `rankBudget p = p + 1` (since
`p ∣ F(p - (5/p))` by the entry-point/Pisano bound). Hence `fibRank` is
computable and `r(p) ∣ p ± 1` for `p ≠ 5`.
**The key insight is** that the rank divides the Pisano period, which divides
`6p` and is bounded by `6p`, giving an a-priori search bound that turns the
noncomputable `fibRank` into an effective algorithm. **Why now?** The
`native_decide` infrastructure in `carmichael_range` shows the kernel can already
evaluate Fibonacci divisibility fast; a proven search bound upgrades `fibRank`
from `noncomputable` to executable.

### 5. Extending the certified Carmichael range and density of primitive primes

Conjecture: `carmichael_range` extends to all `n ≤ N` for any fixed `N` (the
`{6,12}` exceptions never recur), and furthermore the *count* of distinct
primitive prime divisors of `F(n)` grows: `#{ p : r(p) = n } ≥ 1` always, and
`≥ 2` for all `n > 30`.
**The key insight is** that primitive primes of `F(n)` are exactly the prime
factors of the primitive part `Φ_n`, so counting them is counting prime factors
of an explicit integer — fully decidable per `n`. **Why now?** The
`primeFactorsList`-restricted witness search proved here is fast enough to push
`native_decide` verification to much larger ranges, turning the multiplicity
question into reproducible computational data that can seed a general proof.
