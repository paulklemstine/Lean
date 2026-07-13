# Computational Evidence — Order-Four Maximal Determinant with Bounded Entries

## 1. The claim under test

Let `c ≥ 0` and consider `4 × 4` integer matrices `M` with `|M i j| ≤ c`. Write
`D(c)` for the maximum determinant. The circulating guess (with `c = 2k − 1`) is

```
D(2k-1) =? (2k-1)^4 - 2*(2k-1)^2 + 1 = (c^2 - 1)^2.
```

## 2. Small-case calculations

The order-4 Hadamard matrix

```
H = [ 1  1  1  1 ;
      1 -1  1 -1 ;
      1  1 -1 -1 ;
      1 -1 -1  1 ]
```

has `det H = 16`. Scaling every entry by `c` scales the determinant by `c^4`:

| c (= 2k-1) | k | achievable det = 16·c⁴ | guessed (c²-1)² | gap |
|-----------:|--:|-----------------------:|----------------:|----:|
| 1  | 1 |    16 |    0 | 16 |
| 3  | 2 |  1296 |   64 | 1232 |
| 5  | 3 | 10000 |  576 | 9424 |
| 7  | 4 | 38416 | 2304 | 36112 |

Already at `k = 1` (ternary entries `{−1,0,1}`) the guess predicts `0`, while a
determinant of `16` is realised. The guessed formula is therefore not merely
non-maximal — it is not even an upper bound.

## 3. Two-sided bounds actually established

* Lower (achievability): `16·c⁴ ≤ D(c)`, via the scaled Hadamard matrix.
* Upper (Leibniz / permanent bound): `D(c) ≤ 4!·c⁴ = 24·c⁴`.

So `16·c⁴ ≤ D(c) ≤ 24·c⁴`, and the lower endpoint is attained. The sharp upper
constant is `16` (Hadamard's inequality for order four); closing the `16`–`24`
gap is recorded as a future direction.

## 4. Structural congruence check

For `±1` matrices of order 4 the determinant is always divisible by `8` (the
`2^{n-1}` law with `n = 4`). Spot check: `det H = 16 = 8·2`. Subtracting the
first row from the other three turns their entries into elements of `{−2,0,2}`,
exposing the factor `2³ = 8`. This congruence is the order-four shadow of the
Ehlich–Wojtas / Hadamard divisibility restrictions on maximal determinants.

## 5. Counterexample hunt

Target of the hunt: the universal claim "`D(2k−1) = (2k−1)⁴ − 2(2k−1)² + 1`".
Outcome: **refuted for every `k ≥ 1`** by the scaled Hadamard witness above; the
attained value `16(2k−1)⁴` strictly exceeds the guessed value for all `k ≥ 1`.

## 6. OEIS

The achievable values `16, 1296, 10000, 38416, …` are `16·c⁴` for odd `c`.
The order-4 maximal determinant over `{0,1}` matrices is `3`; over `{±1}` it is
`16`. We do not assert a specific OEIS identifier here, since the two-sided
normalisation used above differs from the standard tabulations.
