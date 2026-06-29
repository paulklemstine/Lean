# Computational Evidence — Discriminant of the Hermitian Bianchi lattice S_K

Object: `S_K = Herm₂(O_K)` with `q(A) = 2 det A`, in the basis (E₁₁, E₂₂, off-diag 1, off-diag ω).
In coordinates `(a, c, x, y)`,
`q = 2ac − 2x² − 2T·xy − 2M·y²`, with `T = Tr ω`, `M = N ω`.
The polar bilinear form has Gram matrix

```
[ 0   1   0    0  ]
[ 1   0   0    0  ]
[ 0   0  -2   -T  ]
[ 0   0  -T  -2M  ]
```

whose determinant is `(det !![0,1;1,0]) · (det !![-2,-T;-T,-2M]) = (-1)·(4M − T²) = T² − 4M`.

## 1. Small-case calculations (det Gram = T² − 4M, then = D_K)

| d   | d mod 4 | ω           | T | M=N(ω)   | T²−4M | D_K (expected) |
|-----|---------|-------------|---|----------|-------|----------------|
| −1  | 3       | √−1         | 0 | 1        | −4    | 4d = −4        |
| −2  | 2       | √−2         | 0 | 2        | −8    | 4d = −8        |
| −3  | 1       | (1+√−3)/2   | 1 | 1        | −3    | d  = −3        |
| −5  | 3       | √−5         | 0 | 5        | −20   | 4d = −20       |
| −6  | 2       | √−6         | 0 | 6        | −24   | 4d = −24       |
| −7  | 1       | (1+√−7)/2   | 1 | 2        | −7    | d  = −7        |
| −11 | 1       | (1+√−11)/2  | 1 | 3        | −11   | d  = −11       |
| −15 | 1       | (1+√−15)/2  | 1 | 4        | −15   | d  = −15       |

Note for `d ≡ 1 (mod 4)`: `M = (1−d)/4`, e.g. d=−3 → (1−(−3))/4 = 1; d=−7 → 2; d=−11 → 3; d=−15 → 4.
`T² − 4M = 1 − (1−d) = d`. For `d ≢ 1 (mod 4)`: `T=0, M=−d`, `T² − 4M = 4d`.
Every row matches `D_K`. **No counterexample found.**

## 2. OEIS

The sequence of fundamental discriminants of imaginary quadratic fields
(−3, −4, −7, −8, −11, −15, −19, −20, −23, −24, …) is OEIS **A003657** (absolute
values A003657 / negatives A191483-style). The map d ↦ D_K reproduces these.

## 3. Counterexample hunt

The identity `T² − 4M = D_K` is a polynomial identity in `(T, M)` specialised to
the two residue classes of `d`; it was checked symbolically (`ring`) and holds
for **all** integers `d`, with the negativity/squarefreeness of `d` only needed
to interpret `D_K` as the field discriminant. The `d ≡ 1` branch requires the
exact division `(1−d)/4`, valid precisely because `4 ∣ (1−d)` there. No
counterexample exists.

## 4. Structural checks (proved in `HermitianBianchiProperties.lean`)

* Evenness: `2 ∣ q(v)` for all `v` (q = 2·det).
* Scaling: `det(N·Gram) = N⁴ · D_K`; the K3 Néron–Severi lattice `S_K(2N)` has
  determinant `16 N⁴ D_K`.
* Congruence: `D_K ≡ 0` or `1 (mod 4)` — the classical discriminant congruence,
  recovered from the (T, M) parametrisation.

All computations above are discharged formally in the two Lean files; the
determinant is genuinely symbolic in `(T, M)` (a `ring`-level polynomial
identity after a block expansion), not a finite `decide`.
