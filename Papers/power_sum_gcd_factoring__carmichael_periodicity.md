# Computational Evidence — Power-Sum GCD Factoring & Carmichael Periodicity

All numbers below were produced by evaluating Lean definitions
(`F N k = ∑_{a=1}^N a^k`, `g N k = gcd (F N k) N`) with `#eval` inside this project's
Lean/Mathlib toolchain. They are *exploratory* data; the statements they support are proved
independently in `Catalog/Combinatorics/PowerSum*.lean` (no `native_decide`, no `sorry`).

## 1. The reveal formula on eight test semiprimes

For each pair `(p,q)` we list `N = pq`, `λ = lcm(p-1,q-1)`, the least exponent `k ≥ 1` whose
gcd is a proper nontrivial divisor, and that gcd.

| p | q | N | λ = lcm(p-1,q-1) | first hit k\* | g(k\*) |
|---|---|---|---|---|---|
| 3 | 5 | 15 | 4 | 2 | 5 |
| 3 | 7 | 21 | 6 | 2 | 7 |
| 5 | 7 | 35 | 12 | 4 | 7 |
| 11 | 13 | 143 | 60 | 10 | 13 |
| 7 | 23 | 161 | 66 | 6 | 23 |
| 13 | 17 | 221 | 48 | 12 | 17 |
| 31 | 37 | 1147 | 180 | 30 | 37 |
| 89 | 113 | 10057 | 1232 | 88 | 113 |

In every row `k* = min(p-1, q-1) = p-1` and `g(k*) = q`, matching
`PowerSumReveal.first_reveal`.

Checked exhaustively for `k = 1, …, 2λ` on all eight semiprimes:

* `g(k) = (if (p-1) ∣ k then 1 else p) · (if (q-1) ∣ k then 1 else q)` — **true** in all cases
  (this is `PowerSumReveal.gcd_powerSum_semiprime`);
* `g(k + λ) = g(k)` — **true** in all cases (`PowerSumReveal.revealGcd_periodic`).

Sample trace, `N = 143 = 11·13` (`k = 1 … 24`), showing the two visible "hit" patterns
`k ≡ 0 (mod 10)` → `13` and `k ≡ 0 (mod 12)` → `11`:

```
k :  1   2   3   4   5   6   7   8   9  10  11  12
g : 143 143 143 143 143 143 143 143 143  13 143  11
k : 13  14  15  16  17  18  19  20  21  22  23  24
g : 143 143 143 143 143 143 143  13 143 143 143  11
```

## 2. Counterexample hunt against the informal write-up

The write-up claims `p + q = N − λ(N) + 1`. Computed side by side:

| p | q | p+q | N − λ + 1 | N + 1 − φ(N) |
|---|---|---|---|---|
| 3 | 5 | 8 | 12 | 8 |
| 3 | 7 | 10 | 16 | 10 |
| 5 | 7 | 12 | 24 | 12 |
| 11 | 13 | 24 | 84 | 24 |
| 7 | 23 | 30 | 96 | 30 |
| 13 | 17 | 30 | 174 | 30 |
| 31 | 37 | 68 | 968 | 68 |
| 89 | 113 | 202 | 8826 | 202 |

The claimed formula **fails in all eight cases**; the correct one is
`p + q = N + 1 − φ(N)` with `φ(N) = λ(N) · gcd(p−1, q−1)`.
Formalised as `PowerSumReveal.factors_from_period` (correct version) and
`PowerSumReveal.paper_period_formula_fails` (the claimed version fails for *every* pair of
odd primes).

## 3. Non-squarefree moduli: a permanent obstruction

`g(N,k)` for `k = 1 … 12`:

| N | factorisation | g(N,1..12) |
|---|---|---|
| 12 | 2²·3 | 6, 2, 12, 2, 12, 2, 12, 2, 12, 2, 12, 2 |
| 45 | 3²·5 | 45, 15, 45, 3, 45, 15, 45, 3, 45, 15, 45, 3 |
| 50 | 2·5² | 25, 25, 25, 5, 25, 25, 25, 5, 25, 25, 25, 5 |
| 99 | 3²·11 | 99, 33, 99, 33, 99, 33, 99, 33, 99, 3, 99, 33 |

A prime whose square divides `N` divides `g(N,k)` for *every* `k` (2 for `N=12`, 3 for
`N=45, 99`, 5 for `N=50`): repeated factors are never separated. Proved as
`PowerSumReveal.sq_dvd_dvd_revealGcd`.

## 4. `k = 1` is always useless for odd `N`

`g(N,1) = N` for `N = 15, 21, 35, 143, 161, 221, 1147, 10057` (all odd), because
`2·F(N,1) = N(N+1)`. Proved as `PowerSumReveal.dvd_powerSum_one_of_odd`; the exact criterion
"the reveal is nontrivial at every exponent iff `N` is even" is
`PowerSumReveal.always_reveals_iff_even`.

## 5. Degree barrier: the phenomenon is not about monomials

For `N = 143` (so `min(p−1,q−1) = 10`) three integer polynomials of degree 9 with arbitrary
coefficients, e.g. `3 + x + 4x² + x³ + 5x⁴ + 9x⁵ + 2x⁶ + 6x⁷ + 5x⁸ + 3x⁹`, all give

`∑_{a=1}^{143} f(a) ≡ 0 (mod 143)` — no information.

At degree exactly 10 the barrier breaks: `∑_{a=1}^{143} a^{10} ≡ 130 (mod 143)` and
`gcd = 13`. Proved as `PowerSumReveal.polySum_degree_barrier` and
`PowerSumReveal.degree_threshold`.

## 6. The coprime-restricted variant

`F*(N,k) = ∑_{a ≤ N, gcd(a,N)=1} a^k`. Checked for `(p,q) ∈ {(3,5),(3,7),(5,7),(11,13),(7,23),(13,17)}`
and `k = 1 … 40`: the criterion

`p ∣ F*(pq,k) ↔ ((p−1) ∤ k ∨ p ∣ q−1)`

holds in **all** 240 cases (proved as `PowerSumReveal.prime_dvd_coprimeSum_iff`).

The variant is a strict *loss*, not an improvement: for `N = 21`, `k = 2`,
`F*(21,2) = 1806`, `gcd(1806, 21) = 21` (nothing), while the full sum gives
`gcd(F(21,2), 21) = 7`. Proved as `PowerSumReveal.coprime_variant_strictly_worse`.

## 7. Partial sums escape the degree barrier

The degree barrier concerns sums over the complete interval `[1,N]`. Searching partial sums
`∑_{a=1}^{M} a^k mod N` for `N = 143`, `k ≤ 4`, `M ≤ 142` gives 188 hits (out of 568 pairs)
with a proper nontrivial gcd — already at `k = 1`, e.g. `M = 10`: `55`, `gcd(55,143) = 11`.
Similarly for `N = 10057`: `k = 1, M = 88` gives the factor `89`.
The deterministic version, `gcd(∑_{a=1}^{p-1} a, pq) = p` for odd `p < q`, is proved as
`PowerSumReveal.partial_sum_reveal`; note that locating such an `M` still costs `Ω(√N)`
queries.

## 8. OEIS

No OEIS lookup was performed (this environment has no network access), so no OEIS
identifiers are claimed. The underlying integer sequences are the Faulhaber power sums
`∑_{a=1}^{N} a^k`; the derived object studied here, `k ↦ gcd(F(N,k), N)`, is by
`gcd_powerSum_squarefree` completely determined by the divisor lattice of `λ(N)` and is
therefore not an independent numerical sequence.
