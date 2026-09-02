# Computational Evidence — Reed–Solomon dimension and MDS equality

All numbers below were produced by executing Lean 4 code (`#eval`) in the same toolchain as the
formal development. They guided (and stress-tested) the statements later proved in
`Catalog/Physics/ReedSolomonMDS.lean`.

## 1. Setup

For a prime `q`, evaluation points `α i = i` for `i < n`, and message space of polynomials of
degree `< k`, the codewords are the vectors `(p(0), p(1), …, p(n-1))`. A brute-force enumeration
over all `q^k` coefficient vectors computes

```
minDistBrute q n k = min { weight(codeword) : codeword ≠ 0 }.
```

## 2. Minimum distance of `RS[n, k]` — small cases

| `q` | `n` | `k` | brute-force `d` | predicted `n - k + 1` |
|----|----|----|-----------------|-----------------------|
| 3  | 3  | 1  | 3               | 3                     |
| 3  | 3  | 2  | 2               | 2                     |
| 3  | 3  | 3  | 1               | 1                     |
| 5  | 5  | 1  | 5               | 5                     |
| 5  | 5  | 2  | 4               | 4                     |
| 5  | 5  | 3  | 3               | 3                     |
| 5  | 5  | 4  | 2               | 2                     |
| 5  | 5  | 5  | 1               | 1                     |
| 7  | 5  | 2  | 4               | 4                     |
| 7  | 5  | 3  | 3               | 3                     |
| 7  | 5  | 4  | 2               | 2                     |
| 7  | 7  | 2  | 6               | 6                     |
| 7  | 7  | 3  | 5               | 5                     |
| 7  | 7  | 5  | 3               | 3                     |

**No counterexample was found**: in every case the exhaustive minimum equals `n - k + 1`, i.e. the
Singleton bound is met with equality (MDS). Note that `k = n` is included and behaves correctly
(`d = 1`), and `k = 1` (repetition-like code) gives `d = n`.

## 3. Dual codes — evidence for MDS duality

Enumerating all `q^n` vectors and keeping those orthogonal to the whole code (standard bilinear
form `∑ y_i c_i`) gives the dual code; its minimum weight was computed exhaustively:

| `q` | `n` | `k` | dual `d⊥` | predicted `k + 1` |
|----|----|----|-----------|-------------------|
| 5  | 5  | 1  | 2         | 2                 |
| 5  | 5  | 2  | 3         | 3                 |
| 5  | 5  | 3  | 4         | 4                 |
| 5  | 5  | 4  | 5         | 5                 |
| 7  | 5  | 2  | 3         | 3                 |
| 7  | 5  | 3  | 4         | 4                 |

Since `dim C⊥ = n - k`, the value `k + 1 = n - (n - k) + 1` is again the Singleton bound: the dual
is MDS too. This evidence motivated the formal theorem
`ReedSolomonMDS.minDist_dualCode_code`.

## 4. Counterexample hunt for the *general* Singleton bound

The general bound proved here is: for any subspace `C ≤ F^n`, if every nonzero codeword has
weight `≥ d` and `1 ≤ d ≤ n`, then `dim C + d ≤ n + 1`. The hypothesis `d ≤ n` is *not* cosmetic:
for `C = ⊥` the weight hypothesis is vacuous and `d` may be arbitrarily large while `dim C = 0`,
so `dim C + d ≤ n + 1` fails for `d > n + 1`. This corner case was found while testing the
statement and is the reason the formal statement carries `hdn : d ≤ n` (automatically satisfied
whenever `C` contains a nonzero word).

## 5. Formal cross-check inside Lean

The concrete instance `q = 5`, `n = 5`, `k = 3` is not left at the level of `#eval`: the theorem
`ReedSolomonMDS.rs_zmod5_parameters` derives, from the general results,

```
dim (RS[5,3] over ZMod 5) = 3,  d = 3,  dim dual = 2,  d⊥ = 4,
```

matching rows 6 and 3 of the tables above. Only that Lean theorem (not the `#eval` output) counts
as verified.
