# Computational evidence

All numbers below were produced before formalisation and every claim that survived is
now a Lean theorem in `Catalog/MachineLearning/FreeWitness*.lean`.  Entries marked
*(theorem)* are machine-checked; entries marked *(search)* are exploratory data that
motivated a theorem but are not themselves verified.

## 1. The SIGK prediction: `σ_k(pq) = (1 + p^k)(1 + q^k)`

Exhaustive check for all semiprimes `pq` with `3 ≤ p < q < 60`, comparing the direct
divisor sum with the predicted product: agreement in every case *(search; now a
theorem: `FreeWitness.sigma_semiprime`)*.

| `N = p·q` | `σ₂(N)` | `(1+p²)(1+q²)` | `p²+q² = σ₂−1−N²` | trace `√(σ₂+2N−1−N²)` |
|---|---|---|---|---|
| 15 = 3·5   | 260  | 10·26 = 260   | 34  | 8  = 3+5  |
| 21 = 3·7   | 500  | 10·50 = 500   | 58  | 10 = 3+7  |
| 33 = 3·11  | 1220 | 10·122 = 1220 | 130 | 14 = 3+11 |
| 35 = 5·7   | 1300 | 26·50 = 1300  | 74  | 12 = 5+7  |
| 77 = 7·11  | 6100 | 50·122 = 6100 | 170 | 18 = 7+11 |

Recovery of the factors from `(N, σ₂(N))` succeeded in all cases
*(theorem: `FreeWitness.sigma_two_trace_sqrt`, `FreeWitness.sigma_two_recovers_factors`)*.

## 2. Counterexample hunt for the polynomial barrier

An integer polynomial always satisfies `a − b ∣ P(a) − P(b)`.  Searching semiprime pairs
for a violation:

| witness | pair | `ΔN` | `ΔW` | divides? |
|---|---|---|---|---|
| `σ₂` | 33, 15 | 18 | 960 | no → not polynomial |
| `σ₁` | 33, 15 | 18 | 24  | no → not polynomial |
| `C` (circle count) | 21, 15 | 6 | 16 | no → not polynomial |
| `H` (half-plane count) | 35, 15 | 20 | 2 | no → not polynomial |

*(theorems: `FreeWitness.sigma_two_not_polynomial_witness`,
`FreeWitness.circleCount_not_polynomial`, `FreeWitness.halfPlaneCount_not_polynomial`;
the general statement for all `k ≥ 1` is `FreeWitness.sigma_not_polynomial`, proved by
rigidity rather than by these witnesses.)*

## 3. The 2-adic sealing search (§5 of the source paper)

For all semiprimes `N = pq` with `3 ≤ p < q < 300` we searched for a pair
`N₁ ≡ N₂ (mod 2^k)` whose witness values are incongruent mod `2^k`:

| modulus | 8 | 16 | 32 | 64 | 128 | 256 |
|---|---|---|---|---|---|---|
| `σ₂` | none | none | none | none | **found** | **found** |
| `C`  | none | none | **found** | **found** | **found** | **found** |

Separating pair in every "found" cell: `15 = 3·5` and `527 = 17·31` (note `527 − 15 = 512`).
`σ₂(15) = 260 ≡ 4`, `σ₂(527) = 278980 ≡ 68 (mod 128)`; `C(15) = 16`, `C(527) = 512`.

The "none" entries are *not* an artefact of the search range: they are explained by the
identity `σ_{2j}(N) ≡ 2 + 2N^{2j} (mod 64)`
*(theorem: `FreeWitness.sigma_even_two_adic`)*, and the `2^7` separation is
*(theorem: `FreeWitness.sigma_two_no_mod_formula`)*.

## 4. The rank-one test on the CRT square (characters-only boundary)

CRT square for `15 = 3·5`, entries indexed by `(x mod 3, x mod 5)`:

```
        b=0  b=1  b=2  b=3  b=4
 a=0 |   0    6   12    3    9
 a=1 |  10    1    7   13    4
 a=2 |   5   11    2    8   14
```

Truncated ("half-plane") weight `[2x < 15]` on the same square:

```
        b=0  b=1  b=2  b=3  b=4
 a=0 |   1    1    0    1    0
 a=1 |   0    1    1    0    1
 a=2 |   1    0    1    0    0
```

The 2×2 block on `{0,1} × {0,1}` gives `f(0)·f(1) = 1 ≠ 0 = f(6)·f(10)`, so the weight is
not a product of local weights *(theorem: `FreeWitness.truncWeight_not_splits`)*, whereas
the weight `[x² ≡ 1 mod 15]` is exactly the outer product of its two local indicators
*(theorem: `FreeWitness.sqrtOneWeight_splits`)*.

## 5. The ω-channel

| `N` | factorisation | `σ₂(N)` | `v₂(σ₂(N))` | `ω(N)` |
|---|---|---|---|---|
| 15    | 3·5          | 260       | 2 | 2 |
| 105   | 3·5·7        | 13000     | 3 | 3 |
| 1155  | 3·5·7·11     | 1586000   | 4 | 4 |
| 15015 | 3·5·7·11·13  | 269620000 | 5 | 5 |

*(theorem: `FreeWitness.omega_eq_two_adic_valuation`)*.

## 6. OEIS

`σ₂` is A001157 (`1, 5, 10, 21, 26, 50, 50, 85, 91, 130, …`); the divisor sum `σ₁` is
A000203.  The semiprime restriction used here, `σ₂(pq) = (1+p²)(1+q²)`, is the standard
Euler-product specialisation and is not a separate sequence.  No new sequence arose in
this project; the derived quantity `σ₂(N) − 1 − N² = p² + q²` on semiprimes is the
2-power sum of the factors.
