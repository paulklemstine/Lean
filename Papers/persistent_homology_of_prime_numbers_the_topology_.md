# Computational Evidence — Persistent homology of the prime point cloud

All numbers below come from a sieve of Eratosthenes up to `10^6` followed by an exact
computation of the `H₀` barcode of the prime point cloud (which, for a cloud on a line,
is the multiset of consecutive prime gaps; this identification is a theorem of the catalog,
`PrimePH.line_component_iff` / `PrimePH.adjacent_component_iff`).

Reproduction: sieve to `N = 10^6`, form `gaps[i] = p_{i+1} - p_i`, and read off the
statistics below. The identities marked **(proved)** are the ones that are now formal
theorems in `Catalog/NumberTheory/`; the rest are exploratory data.

## 1. Basic barcode statistics up to `10^6`

| quantity | value |
|---|---|
| `π(10^6)` | 78 498 |
| number of finite `H₀` bars | 78 497 |
| total persistence `Σ bar length` | 999 981 |
| `p_n − 2` | 999 981 **(proved: `PrimeBarcode.prime_totalPersistence`)** |
| mean bar length | 12.7391 |
| `log 10^6` | 13.8155 |
| longest bar | 114 (at `p = 492113`) |
| bars of odd length | **1** (the bar `2 → 3`, length 1) |
| bars of length `< 2` | **1** **(proved: `PrimeBarcodeArith.card_short_bars_eq_one`)** |

## 2. Bar-length histogram (first values)

| length | 1 | 2 | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 22 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| count | 1 | 8169 | 8143 | 13549 | 5569 | 7079 | 8005 | 4233 | 2881 | 4909 | 2401 | 2172 |

Observation: **no odd length after the first bar**, and the histogram is strongly
non-monotone (the length-6 class dominates, then 2, 4, 12, 10 …), which is incompatible
with a monotone exponential density.  The parity phenomenon is now a theorem
(`PrimeBarcodeArith.primeGap_even`, `PrimeBarcodeArith.barLength_lattice`).

## 3. Counterexample hunt against the Poisson / exponential conjecture

The conjecture predicts that bar lengths are exponential with mean `μ ≈ log x`.  Test
statistic: the number of bars of length `< 2`.

* exponential prediction with the *empirical* mean `μ = 12.7391`:
  `78497 · (1 − e^{−2/μ}) ≈ 11405`;
* exponential prediction with `μ = log 10^6 = 13.8155`: `≈ 10579`;
* actual count: **1**.

The discrepancy is not a tail effect but a support effect: the empirical barcode measure
sits on the lattice `{1} ∪ 2ℕ`, which has measure zero for any absolutely continuous law.
This computation is what motivated the formal refutation
`PrimeBarcodeArith.poisson_short_bar_prediction_fails`, which holds for **every** mean
`μ > 0`, not just for the two above.

## 4. Betti numbers and twin primes

With `n = 78 497` bars (primes below `10^6`):

* `b₀(2, n) = 1 + #{i : gap_i > 2} = 70 328`;
* `#twin bars = #{i : gap_i = 2} = 8 169`;
* `b₀(2, n) + #twins = 70328 + 8169 = 78497 = n`
  **(proved: `PrimeBarcodeArith.bettiZero_two_add_twinIndexCount`)**;
* `b₀(1, n) = n = 78 497`, hence `b₀(1,n) − b₀(2,n) = 8169 = #twins`
  **(proved: `PrimeRigid.twinIndexCount_eq_betti_difference`)**.

## 5. Degree-one homology

Exploratory GF(2) linear algebra on the primes below `2000` (303 points): for several
scales we computed the cycle rank `|E| - |V| + #components` of the Rips graph and the rank
of the subspace spanned by the boundaries of the Rips triangles.  Their difference is
`dim H₁`.

| `ε` | `|E|` | components | cycle rank | triangle-span rank | `dim H₁` |
|---|---|---|---|---|---|
| 2 | 62 | 241 | 0 | 0 | 0 |
| 4 | 127 | 178 | 2 | 2 | 0 |
| 6 | 256 | 99 | 52 | 52 | 0 |
| 10 | 404 | 44 | 145 | 145 | 0 |
| 20 | 864 | 5 | 566 | 566 | 0 |
| 34 | 1477 | 1 | 1175 | 1175 | 0 |
| 50 | 2209 | 1 | 1907 | 1907 | 0 |

(These ranks come from an ad-hoc GF(2) elimination, not from a Lean-checked computation, so
they are evidence rather than verification.)  The pattern is exactly what
`RipsH1.prime_H1_vanishes` now proves in general: no essential `1`-cycle exists at any
scale, for any point cloud on a line.

By contrast, the four-point square configuration of `RipsH1Sharpness.lean` does carry an
essential `1`-cycle at scale `1`: four edges, zero triangles.

## 6. OEIS cross-references

* prime gaps `1, 2, 2, 4, 2, 4, 2, 4, 6, 2, …` — A001223;
* number of primes below `10^6`, `78498` — consistent with A006880;
* maximal gap `114` below `10^6` — consistent with the record-gap table A005250.

No new integer sequence was produced by this cycle: the `H₀` barcode of the primes *is*
A001223, which is precisely the content of the identification theorem.
