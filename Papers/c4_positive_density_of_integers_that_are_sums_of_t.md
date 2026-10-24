# Computational Evidence — sums of two anti-Fibonacci numbers

Convention: `antiFib n = n(n+1)/2 + 1`, giving `1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, 67, …`
(OEIS A000124, the "central polygonal / lazy caterer" numbers). The catalog file that should
contain `antiFib` was not in the project, so this normalisation was reconstructed: it is the
one for which `8·antiFib n = (2n+1)² + 7`. That identity is exactly what produces the stated
equivalence "representable ⟺ `8m − 14` is a sum of two squares" and the stated `2/9` bound.

All numbers below come from a plain enumeration script (direct marking of
`antiFib a + antiFib b ≤ 10⁷`). They are **exploratory data and were not checked in Lean**.
The Lean files prove the structural statements themselves (see `Catalog/Computation/`).

## 1. Small cases
Representable `m` (first 30): `2, 3, 4, 5, 6, 8, 9, 11, 12, 13, 14, 15, 17, 18, 20, 22, 23, 24,
26, 27, 29, 30, 31, 32, 33, 36, 38, 39, 40, 41`.
Non-representable values start `0, 1, 7, 10, 16, 19, 21, 25, 28, 34, 35, 37, …`. Every
`m ≡ 1, 7 (mod 9)` appears, as `not_isAntiFibSum_of_mod_nine` predicts.

## 2. Testing the equivalence
For every `m ≤ 10⁵`: `m` is representable ⟺ `8m − 14 ≥ 0` is a sum of two squares.
**0 mismatches.** (Proved in Lean for all `m`: `AntiFib.isAntiFibSum_iff_int`.)

## 3. The 2/9 bound
| k | #non-rep in `[0, 9k)` | `2k` |
|---|---|---|
| 10 | 32 | 20 |
| 10³ | 4 626 | 2 000 |
| 10⁵ | 539 287 | 200 000 |
| 10⁶ | 5 649 983 | 2 000 000 |

Fraction of non-representable `m` in each residue class mod 9, for `m ≤ 10⁷`:
`[0.510, 1.000, 0.510, 0.510, 0.602, 0.510, 0.510, 1.000, 0.510]` for classes 0–8. Classes 1 and 7
are fully obstructed. Class 4 (where `9 ∣ 4m−7`) is somewhat more obstructed than the
others.

## 4. The Landau-type ratio (the falsifiability test)
| N | count `R(N)` | `R(N)/N` | `R(N)·√(log N)/N` |
|---|---|---|---|
| 10² | 65 | 0.650 | 1.3949 |
| 10³ | 552 | 0.552 | 1.4508 |
| 10⁴ | 4 834 | 0.483 | 1.4671 |
| 10⁵ | 43 544 | 0.435 | 1.4775 |
| 10⁶ | 399 341 | 0.399 | 1.4843 |
| 3·10⁶ | 1 155 219 | 0.385 | 1.4871 |
| 10⁷ | 3 710 683 | 0.371 | 1.4897 |

* `R(N)/N` keeps decreasing. This matches the Lean theorem `tendsto_card_rep_div_zero`
  (density 0), so the title's "positive density" can only be meant in the `N/√log N` sense.
* `R(N)·√log N / N` increases slowly and stays bounded over the range tested. The predicted
  limit (heuristic, not proved) is `K = 2·b ≈ 1.52845`, where `b = 0.764223…` is the
  Landau–Ramanujan constant. Reasoning: `m ↦ 4m − 7` maps representable `m ≤ N` onto
  the odd sums of two squares up to `4N`, which make up half of all sums of two squares by the
  Euler factor at 2. That gives `(b/2)·4N/√log(4N)`. The slow upward drift fits the known
  `1 + O(1/log N)` second-order term in Landau's theorem.

## 5. Counterexample hunt
* Equivalence: no counterexample up to `10⁵`. It is now a theorem.
* `2/9` bound: holds for every tested `k`. It is now a theorem.
* "Positive density": refuted. The density is 0 (theorem).

## 6. OEIS
`antiFib` = A000124. The representable `m` correspond under `m ↦ 4m − 7` to the sums of
two squares `≡ 1 (mod 4)` (an odd sub-sequence of A001481).
