# Future Directions: Deepening the Fibonacci Rank of Apparition

## Synthesis

This cycle deepened the rank-of-apparition spine `r(p) = fibRank p = min { k > 0 : p ∣ F(k) }`
established in `Catalog/Applications/RankOfApparition.lean`. The spine is the single
biconditional `m ∣ F n ↔ fibRank m ∣ n` (`fibRank_dvd_iff`), which converts every question
about Fibonacci divisibility into a question about divisibility of *indices*. The catalog had
developed the spine, the value-rigidity `fibRank (F k) = k`, the divisibility biconditional
`F a ∣ F b ↔ a ∣ b`, and Carmichael's prime case. What it lacked, and what this cycle supplies
in `Catalog/Applications/FibonacciRankDeepening.lean`, is the *algebra* of the rank function on
two axes:

1. **The lattice axis.** `fibRank` is an exact join-morphism of divisibility lattices:
   `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` with no coprimality hypothesis
   (`fibRank_lcm`), specializing to `fibRank (a·b) = lcm (fibRank a) (fibRank b)` for coprime
   factors (`fibRank_mul_coprime`). This is the `RankOfApparition.fibRank` analogue of the
   catalog's `FibonacciApparitionLattice.fibEntry_lcm`, now derived directly from the spine.

2. **The arithmetic axis.** For a prime `p ∉ {2,5}` the rank is constrained by the field
   `𝔽_{p²}`: the companion matrix `Q = !![1,1;1,0]` is diagonalizable over `AlgebraicClosure
   (ZMod p)` (discriminant `5 ≠ 0`), its eigenvalues satisfy `x^{p²−1} = 1` by Frobenius, hence
   `p ∣ F(p²−1)` (`fib_dvd_sq_sub_one`) and so `fibRank p ∣ p²−1` (`fibRank_prime_dvd_sq_sub_one`).

The two axes then **cooperate**: `fibRank_semiprime_dvd_lcm` bounds the rank of a semiprime
modulus `p·q` (distinct primes `∉ {2,5}`) by the explicit, computable number
`lcm(p²−1, q²−1)`. This is the prototype of a general reduction: the lattice law reduces the
rank of any modulus to the ranks of its prime-power factors, and the arithmetic law bounds each
prime factor's rank. All five results are `sorry`-free and use only `propext`,
`Classical.choice`, `Quot.sound`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fibRank_lcm` | `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` | proved |
| `fibRank_mul_coprime` | coprime factors: `fibRank (a·b) = lcm (fibRank a) (fibRank b)` | proved |
| `fib_dvd_sq_sub_one` | prime `p ∉ {2,5}`: `p ∣ F(p²−1)` | proved |
| `fibRank_prime_dvd_sq_sub_one` | prime `p ∉ {2,5}`: `fibRank p ∣ p²−1` | proved |
| `fibRank_semiprime_dvd_lcm` | distinct primes `∉ {2,5}`: `fibRank (p·q) ∣ lcm(p²−1, q²−1)` | proved |

## Research Directions

### 1. The sharp prime law: `fibRank p ∣ p − (5∣p)` (Legendre symbol refinement)

The matrix bound `fibRank p ∣ p²−1` is the *weak* form. The classical sharp statement is that
`fibRank p` divides `p − 1` when `p ≡ ±1 (mod 5)` and `p + 1` when `p ≡ ±2 (mod 5)`, i.e.
`fibRank p ∣ p − (5∣p)` where `(5∣p)` is the Legendre symbol. Since `p − (5∣p)` always divides
`p²−1`, this strictly refines `fibRank_prime_dvd_sq_sub_one`.
**The key insight is** that over `𝔽_p` itself (not `𝔽_{p²}`) the golden ratio `α` lives in `𝔽_p`
exactly when `5` is a quadratic residue, so the Frobenius `α^p = α^{(5∣p)}`-type identity already
forces `α^{p−(5∣p)} = 1`, collapsing the eigenvalue order from `p²−1` to `p−(5∣p)`.
**Why now?** The eigenvalue/Frobenius machinery is already built and verified in
`fib_dvd_sq_sub_one`; the only new ingredient is a quadratic-residue case split on `(5∣p)`, for
which Mathlib's `ZMod.legendreSym` / `legendreSym.eq_pow` API is directly available. This is a
falsifiable, fully formalizable upgrade with an explicit small-prime check (`p=11 ⇒ r=10 ∣ 10`,
`p=7 ⇒ r=8 ∣ 8`).

### 2. Wall's prime-power lifting law for `fibRank`

Conjecture: for a prime `p` and `k ≥ 1`, `fibRank (p^{k+1}) ∈ {fibRank (p^k), p · fibRank (p^k)}`,
and generically `fibRank (p^k) = p^{k−1} · fibRank p` once `p^2 ∤ F(fibRank p)`.
**The key insight is** that the `p`-adic valuation `v_p(F n)` is governed by Lifting-the-Exponent:
`v_p(F n) = v_p(F(fibRank p)) + v_p(n / fibRank p)` for `fibRank p ∣ n`, so raising the modulus
to `p^{k+1}` raises the required index by exactly one factor of `p` whenever the LTE base term is
minimal. **Why now?** The catalog already contains an LTE framework for Fibonacci
(`Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`, `fib_lte`); combining
it with the spine `fibRank_dvd_iff` of this cycle turns the prime-power law into pure valuation
bookkeeping. The conjecture is falsifiable by the (heuristically nonexistent below `10^{14}`)
Wall–Sun–Sun primes, where `fibRank(p²) = fibRank p`.

### 3. The full multiplicative reduction `fibRank m = lcm_{pᵏ ‖ m} fibRank(pᵏ)`

Conjecture: for every `m ≥ 1`, `fibRank m = lcm over prime powers p^k exactly dividing m of
fibRank(p^k)`, giving a complete formula for `fibRank` from its prime-power values.
**The key insight is** that `fibRank_lcm` (proved this cycle) is exactly the inductive step:
factor `m = (p^k) · m'` with `gcd(p^k, m') = 1` and apply `fibRank_mul_coprime` repeatedly over
the factorization. **Why now?** With `fibRank_mul_coprime` in hand the only remaining work is a
`Nat.factorization`-driven induction (`Nat.recOnPrimeCoprime` or
`UniqueFactorizationMonoid` recursion), so the result is a short formalization away and would
make `fibRank` *computable* from a primality-tested factorization — a directly testable
`#eval`-able formula.

### 4. Carmichael's composite tail (the open `sorry` in `Shared/CarmichaelProof.lean`)

The composite case of Carmichael's primitive-divisor theorem is verified by `native_decide` for
`13 ≤ n ≤ 10000` but left as `sorry` for `n > 10000` in `fib_carmichael_composite`.
**The key insight is** that the primitive part `Φ_n = F(n) / ∏_{d∣n, d<n} (intrinsic factors)`
satisfies `|Φ_n| > n` for all `n > 12` via the homogeneous bound
`|Φ_n| ≥ (golden ratio)^{φ(n)} / (n+1)` together with `φ(n) ≥ √n`; once `Φ_n > n` the primitive
part cannot be supported entirely on the (at most `log_2 n`) "intrinsic" prime factors, so a
genuine primitive prime divisor must exist. **Why now?** This cycle's `fib_dvd_sq_sub_one`
supplies the eigenvalue/Binet growth estimates over `𝔽_{p²}`, and the catalog already has the
exponential lower bound `fib_exponential_lower_bound`; assembling these into the
`|Φ_n| > n` inequality closes the last `sorry` and yields *unconditional* Carmichael for all
`n ∉ {1,2,6,12}`. Falsifiable: any counterexample `n` would be a Fibonacci number with no
primitive divisor, contradicting tabulated data.

### 5. Pisano-period stratification: `fibRank m ∣ π(m)` and the index `π(m)/fibRank m ∈ {1,2,4}`

The Pisano period `π(m)` (period of `F mod m`) is a multiple of `fibRank m`, and the quotient
`π(m)/fibRank m` is always `1`, `2`, or `4`.
**The key insight is** that `π(m)` is the multiplicative order of the companion matrix `Q` in
`GL₂(ZMod m)`, while `fibRank m` is the order of its *off-diagonal vanishing*; the quotient
measures the order of the determinant-eigenvalue `(−1)`-twist, which lies in the 2-group
`{±1}` raised to a power dividing 4. **Why now?** The matrix viewpoint `((Nat.fib n : ZMod p) =
(Q^n) 0 1)` is already formalized inside `fib_dvd_sq_sub_one` this cycle; promoting it from a
single Frobenius computation to the order of `Q` in `Matrix.GeneralLinearGroup` connects the
spine to Mathlib's `orderOf` API and makes the `{1,2,4}` trichotomy a finite case analysis on
`det Q = −1`. Falsifiable by direct `#eval` of `π(m)/fibRank m` over any range of moduli.
