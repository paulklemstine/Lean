# Computational Evidence — Prime-Base Binomial Congruences

Target congruence (base `q`): find `n` with `C(q·n, n) ≡ qⁿ (mod n)`.

## 1. Small-case solution search

`#eval` over `2 ≤ n < 40`, testing `Nat.choose (q*n) n % n == q^n % n`:

| base `q` | solutions `n < 40` |
|----------|--------------------|
| `q = 2`  | 2, 3, 5, 7, 11, **12**, 13, 17, 19, 23, 29, **30**, 31, 37 |
| `q = 3`  | 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, **36**, 37 |

**Observation.** *Every* prime `< 40` appears in both lists. The only composites
are `12 = 2²·3`, `30 = 2·3·5` (base 2) and `36 = 2²·3²` (base 3). This is the
empirical seed of the headline theorem `prime_solves`: the prime fibre `n = p`
always solves the congruence.

Note `12 = 2²·3` has exactly the Guedes–Machado shape `n = qᵗ·p` with `q = 2`,
`t = 2`, `p = 3`; `30` and `36` do not, and belong to other composite families.

## 2. The driver integer `Aₜ = C(q^{t+1}, qᵗ) − q^{qᵗ}`

`#eval` of `A q t`:

| `(q,t)` | `C(q^{t+1}, qᵗ)` | `q^{qᵗ}` | `Aₜ` | factorisation of `Aₜ` |
|---------|------------------|----------|------|------------------------|
| `(2,1)` | `C(4,2)=6`       | `2²=4`   | `2`  | `2` |
| `(2,2)` | `C(8,4)=70`      | `2⁴=16`  | `54` | `2·3³` |
| `(2,3)` | `C(16,8)=12870`  | `2⁸=256` | `12614` | `2·7·17·53` |
| `(3,1)` | `C(9,3)=84`      | `3³=27`  | `57` | `3·19` |
| `(3,2)` | `C(27,9)=4686825`| `3⁹=19683`| `4667142` | `2·3·…` |

**Observation.** In every row the base `q` divides `Aₜ` **exactly once**
(`A mod q = 0`, `A mod q² ≠ 0`: measured values `A 2 1 % 4 = 2`,
`A 2 2 % 4 = 2`, `A 3 1 % 9 = 3`). This is the empirical seed of
`A_qadic_valuation` (`q ∥ Aₜ`). The residual `Aₜ/q` (`1, 27, 6307, 19, …`)
carries all the candidate primes `p ≠ q`.

## 3. Central prime-power binomial valuation

`#eval ((2^3).choose (2^2)).factorization 2 = 1`,
`#eval ((3^2).choose (3^1)).factorization 3 = 1`.

Confirms `v_q(C(q^{t+1}, qᵗ)) = 1` (Kummer: exactly one base-`q` carry in
`qᵗ + (q−1)qᵗ = q^{t+1}`), the seed of `central_choose_factorization`.

## 4. OEIS

The base-`q` congruence family `C(qn,n) ≡ qⁿ (mod n)` and its prime-base
refinement relate to the attached reference `OEIS:A080469` and the
`A080170`-style binomial-GCD sequences already in the catalog
(`Catalog/Novelty/BinomialGCDA080170.lean`).

## 5. Counterexample hunt

The universal claim tested and *confirmed* (no counterexample) up to the search
bound: for every prime `p ≤ 100` and base `q ∈ {2,3,5}`, `C(qp,p) ≡ qᵖ (mod p)`.
This matches the proved theorem `prime_solves`, which makes the statement
unconditional for all primes and all bases.
