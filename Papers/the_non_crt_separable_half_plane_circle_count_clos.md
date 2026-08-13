# Computational Evidence — Half-Plane Circle Count `H(N)`

All numbers below were produced by `#eval` on the *same* Lean definitions that the
theorems are stated about (`Catalog/MachineLearning/HalfPlaneCircleBasic.lean`), so
there is no gap between the exploration and the formalisation.

Definitions (`x, y` range over representatives in `[0,N)`):

* `C(N)  = #{(x,y) : x² + y² ≡ 1 (mod N)}`                     — `circleCount`
* `H(N)  = #{(x,y) on the circle : 2(x+y) < N}`                — `halfPlaneCount`
  (the sum `x+y` is an **integer** sum: this is the non-CRT-separable cut)
* `high(N) = #{(x,y) on the circle : 2(x+y) > 3N}`             — `highCount`
* `R(N)  = #{u < N : u² ≡ 1 (mod N), 2u < N}`                  — `unitRootCount`
* `D(N)  = #{x : 2x² ≡ 1 (mod N), 4x < N}`                     — `fixDiagCount`

## 1. Small-case table (full enumeration)

```
N    C(N)  H(N)  high(N)  R(N)  D(N)
 3     4     2      0      1     0
 4     8     2      0      1     0
 5     4     2      0      1     0
 7     8     2      0      1     0
 8    16     4      0      2     0
 9    12     4      2      1     0
12    32     6      2      2     0
15    16     4      0      2     0
16    32     6      2      2     0
17    16     3      1      1     1
21    32     4      0      2     0
24    64    12      4      4     0
25    20     6      4      1     0
28    64    10      6      2     0
31    32     7      5      1     1
33    48     8      4      2     0
35    32     6      2      2     0
36    96    14     10      2     0
```

## 2. Exhaustive checks of the formalised statements

Checked for **all `N < 200`** by enumeration, with zero exceptions:

| claim | Lean theorem | exceptions found |
|---|---|---|
| `H(N) = high(N) + 2R(N)` (`N ≥ 2`) | `halfPlaneCount_eq_highCount_add` | none |
| `4·high(N) ≤ C(N)` | `four_mul_highCount_le_circleCount` | none |
| `H(N) ≡ D(N) (mod 2)` | `halfPlaneCount_parity` | none |
| `2R(N) = S(N)` (`N ≥ 3`) | `two_mul_unitRootCount` | none |
| `C(mn) = C(m)C(n)` (coprime) | `circleCount_mul_of_coprime` | none |

## 3. Counterexample hunt: is `H` CRT-separable?

It is **not**, and the smallest witnesses are tiny:

```
H(35) = 6   vs  H(5)·H(7)  = 2·2 = 4
H(33) = 8   vs  H(3)·H(11) = 2·2 = 4
high(33) = 4 vs high(3)·high(11) = 0
```

Both are formalised (`halfPlaneCount_not_multiplicative`,
`highCount_not_multiplicative`).  By contrast `C(15) = C(3)C(5) = 16`,
`C(35) = C(5)C(7) = 32`, `C(105) = 128 = 4·4·8`, in agreement with the proved
closed form `C(N) = ∏_{p|N}(p - χ_p(-1))`.

## 4. Sharpness of the quadrant constant

`4·high(N) ≤ C(N)` is proved.  The constant cannot be raised to `8`:

```
N = 9 : high = 2, C = 12 < 16 = 8·high
N = 25: high = 4, C = 20 < 32
N = 31: high = 5, C = 32 < 40
```

(`exists_eight_mul_highCount_gt`).  Likewise `8H(N) ≤ C(N)` — the naive
"density `1/8`" bound — is **false** for many small `N` (e.g. `N = 9`: `8H = 32`
vs `C = 12`); the heuristic `H ≈ C/8` is asymptotic only, which is exactly why the
proved bound is stated as `4H(N) ≤ C(N) + 4S(N)`.

## 5. Prime data supporting the conic count

```
p        3   5   7  11  13  17  19  23  29  31  37  41
C(p)     4   4   8  12  12  16  20  24  28  32  36  40
p∓1      4   4   8  12  12  16  20  24  28  32  36  40
```
matching `C(p) = p - χ(-1)` (`circleCount_prime`), proved via the stereographic
parametrisation rather than by table lookup.

## 6. OEIS

`C(N)` for `N = 1, 2, 3, …` begins `1, 2, 4, 8, 4, 8, 8, 16, 12, 8, 12, 32, …`
(the number of points of `x²+y²=1` over `Z/N`).  The odd-index subsequence is the
classical multiplicative function `N ∏_{p|N}(1 - χ_p(-1)/p)`.  We make no OEIS
identity claim for `H(N)` (`1, 0, 2, 2, 2, 2, 2, 4, 4, 2, 2, 6, 2, 2, 4, 6, 3, …`);
we did not find it in a search and it is not needed for any theorem here.

## 7. Prime powers (cycle 5)

```
p^k      9    27    81    25   125    49   121
C(p^k)  12    36   108    20   100    56   132
p^{k-1}(p - χ_p(-1))
        3·4  9·4  27·4  5·4  25·4  7·8  11·12
```
Every column agrees, and the general statement
`C(N) = ∏_{p|N} p^{v_p(N)-1}(p - χ_p(-1))` for odd `N` is now proved
(`circleCount_odd`), so the table is a consistency check rather than evidence for
an open claim.
