# Computational Evidence

## 1. Block-repetition threshold (`exists_repeated_mer`)

The number of distinct length-`m` blocks over a `q`-letter alphabet is `q ^ m`.

| alphabet `q` | block `m` | `q ^ m` | first window count forcing a repeat |
|---|---|---|---|
| 4 (DNA) | 1 | 4 | 5 |
| 4 (DNA) | 4 | 256 | 257 |
| 4 (DNA) | 6 | 4096 | 4097 |
| 2 | 3 | 8 | 9 |

A length-`L` string exposes `L - m + 1` window positions. For DNA hexamers a
repeat is forced once `L - 5 > 4096`, i.e. `L ≥ 4102` bases — correcting the naive
"4097 nucleotides" slogan (that counts bases, not windows). This correction is
recorded in `dna_repeated_hexamer`.

## 2. Sharpness (de Bruijn)

For `q = 2, m = 3` the cyclic de Bruijn sequence `00010111` has all eight `3`-mers
distinct, meeting `N = q ^ m = 8` exactly. This confirms the extremal bound
`merInjective_length_le` is tight and cannot be lowered.

## 3. Ramsey `R(3,3)`

- A 2-colouring of `K₅` with **no** monochromatic triangle exists (the 5-cycle vs.
  its complement), so five vertices do **not** suffice: the threshold is exactly 6.
- Exhaustive reasoning over the `2^15` symmetric colourings of `K₆` finds a
  monochromatic triangle in every case; the formal proof replaces this brute count
  by a two-level pigeonhole (`three_same_color_among_five` + fixed-vertex case
  split), so no `native_decide` is used in the main theorem.

## OEIS

- Distinct-`m`-mer capacities `q ^ m` for `q = 4`: `4, 16, 64, 256, 1024, 4096, …`
  (powers of four, OEIS A000302).
- Diagonal Ramsey numbers `R(n,n)`: `2, 6, 18, …` (OEIS A212954 / classical),
  with `R(3,3) = 6` the case proved here.

No counterexamples were found to any stated theorem.
