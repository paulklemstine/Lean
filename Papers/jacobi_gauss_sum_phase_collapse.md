# Computational evidence: Jacobi Gauss-sum phase collapse

All numbers below come from a direct floating-point evaluation of

    τ(N) = Σ_{n=0}^{N-1} (n/N) · e^{2πin/N}        ((n/N) = Jacobi symbol)

for the 13 test semiprimes `N = p·q`.  This is *numerical exploration only*; the
verified statements are the Lean theorems in
`Catalog/Novelty/JacobiGaussPhaseCollapse.lean`.

## 1. Small-case table

|   N |  p |  q | p mod 4 | q mod 4 | N mod 4 |            τ(N)            | τ(N)/√N |
|----:|---:|---:|--------:|--------:|--------:|---------------------------:|:--------|
|  15 |  3 |  5 |       3 |       1 |       3 |        0.000000 + 3.872983i | i |
|  21 |  3 |  7 |       3 |       3 |       1 |        4.582576 + 0.000000i | 1 |
|  33 |  3 | 11 |       3 |       3 |       1 |        5.744563 + 0.000000i | 1 |
|  35 |  5 |  7 |       1 |       3 |       3 |        0.000000 + 5.916080i | i |
|  51 |  3 | 17 |       3 |       1 |       3 |        0.000000 + 7.141428i | i |
|  65 |  5 | 13 |       1 |       1 |       1 |        8.062258 + 0.000000i | 1 |
|  77 |  7 | 11 |       3 |       3 |       1 |        8.774964 + 0.000000i | 1 |
|  85 |  5 | 17 |       1 |       1 |       1 |        9.219544 + 0.000000i | 1 |
|  91 |  7 | 13 |       3 |       1 |       3 |        0.000000 + 9.539392i | i |
| 115 |  5 | 23 |       1 |       3 |       3 |        0.000000 +10.723805i | i |
| 143 | 11 | 13 |       3 |       1 |       3 |        0.000000 +11.958261i | i |
| 187 | 11 | 17 |       3 |       1 |       3 |        0.000000 +13.674794i | i |
| 209 | 11 | 19 |       3 |       3 |       1 |       14.456832 + 0.000000i | 1 |

In every case `|τ(N)| = √N` to floating-point accuracy and `τ(N)/√N ∈ {1, i}`, with
value `1` exactly when `N ≡ 1 (mod 4)`, i.e. exactly when `p ≡ q (mod 4)`.

## 2. Counterexample hunt

The universal claim tested was

    arg τ(pq) depends only on (pq) mod 4, and not on the pair (p mod 4, q mod 4).

The critical comparison is the `(1,1)` class against the `(3,3)` class, since both give
`N ≡ 1 (mod 4)`:

* `(1,1)`: N = 65 (5·13), 85 (5·17)  →  τ/√N = 1
* `(3,3)`: N = 21 (3·7), 33 (3·11), 77 (7·11), 209 (11·19)  →  τ/√N = 1

No separation was found: the four classes collapse to the two values `1, i`.  This is what
the Lean file proves: unconditionally `τ(N)² = ±N` with sign `+` iff `N ≡ 1 (4)`
(`JacobiGaussPhase.tau_sq`), and — given the classical sign determination of the *prime*
Gauss sum — exactly `τ(N) ∈ {√N, i√N}` (`JacobiGaussPhase.tau_eq_of_gaussSign`).

## 3. Prime Gauss sums (the two "independent" channels)

|  p | p mod 4 | g_p = Σ_a (a/p) e^{2πia/p} |
|---:|--------:|:---------------------------|
|  3 |       3 | i√3  ≈ 1.732051i           |
|  5 |       1 | √5   ≈ 2.236068            |
|  7 |       3 | i√7  ≈ 2.645751i           |
| 11 |       3 | i√11 ≈ 3.316625i           |
| 13 |       1 | √13  ≈ 3.605551            |

So the *individual* Gauss sums do see `p mod 4` (real vs. purely imaginary).  The
information is destroyed only after multiplying by the reciprocity sign
`(q/p)(p/q) = (-1)^{((p-1)/2)((q-1)/2)}`, which is `-1` exactly in the `(3,3)` case — the
same case in which `i · i = -1`.  The two sign sources cancel identically.

The values `g_3 = i√3`, `g_5 = √5` and `g_7 = i√7` are proved unconditionally in Lean
(`gaussSumPrime_three`, `gaussSumPrime_five`, `gaussSumPrime_seven`), which yields the two
unconditional instances `τ(15) = i√15` (`tau_fifteen`, the mixed case) and `τ(21) = √21`
(`tau_twentyone`, the `(3,3)` case in which the cancellation actually happens).

## 4. Sequence note

The normalised phases `τ(N)/√N` form the sequence `i, 1, 1, i, i, 1, 1, 1, i, i, i, i, 1`
over the list above, i.e. exactly the indicator of `N ≡ 3 (mod 4)`; no OEIS lookup is
meaningful beyond the trivial period-4 pattern of `N mod 4`.
