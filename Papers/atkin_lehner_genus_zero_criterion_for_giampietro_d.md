# Computational Evidence

All computations below were checked in Lean (`#eval` / `decide`) before formalizing.

## 1. The Atkin–Lehner composition law `d ⋆ e = d·e / gcd(d,e)²`

For squarefree levels, `⋆` realizes symmetric difference of prime supports.

| `d`  | `e`  | primes(d) | primes(e) | symmDiff | `d ⋆ e` | `∏ symmDiff` |
|------|------|-----------|-----------|----------|---------|--------------|
| 6    | 10   | {2,3}     | {2,5}     | {3,5}    | 15      | 15           |
| 6    | 6    | {2,3}     | {2,3}     | {}       | 1       | 1            |
| 30   | 5    | {2,3,5}   | {5}       | {2,3}    | 6       | 6            |
| 2·3  | 3·5  | {2,3}     | {3,5}     | {2,5}    | 10      | 10           |

These match `AtkinLehner.alMul_prod`: `alMul (∏ A) (∏ B) = ∏ (A ∆ B)`.

## 2. Order of the Atkin–Lehner group = number of divisors = `2^ω(N)`

For squarefree `N`, `#divisors(N) = 2^{ω(N)}`:

| `N` | ω(N) | #divisors | 2^ω |
|-----|------|-----------|-----|
| 6   | 2    | 4         | 4   |
| 10  | 2    | 4         | 4   |
| 22  | 2    | 4         | 4   |
| 30  | 3    | 8         | 8   |
| 210 | 4    | 16        | 16  |

Formalized as `AtkinLehner.card_divisors_squarefree` and `AtkinLehner.AL_group_order`.

## 3. Parity hypothesis and the Möbius function

For squarefree `N`, `μ(N) = (-1)^{ω(N)}`, so `μ(N) = 1 ⟺ ω(N)` even. The classical
Giampietro–Darmon genus-zero levels `N ∈ {6, 10, 22}` all have `ω(N) = 2` (even),
consistent with the parity hypothesis of the main theorem. Formalized as
`AtkinLehner.moebius_eq_one_iff_even` and `AtkinLehner.genusZeroExamples`.

## 4. Elementary abelian 2-group structure

Every Atkin–Lehner involution `w_d` satisfies `w_d² = w_1` (identity): `d ⋆ d = 1`
(`AtkinLehner.alMul_self`), and abstractly `x + x = 0` (`ALG.two_torsion`). Hence the
group is `(ℤ/2)^{ω(N)}`.
