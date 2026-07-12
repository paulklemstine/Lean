# Computational Evidence

Enumerative layer of the `m`-Tamari / `(m+1)`-constellation correspondence.
All numbers below were computed inside Lean (`#eval`) with the definitions used in
`FussCatalanEnumeration.lean`.

## 1. Fuss–Catalan element counts `Cat_m(n) = C((m+1)n, n) − m·C((m+1)n, n−1)`

| m \ n | 0 | 1 | 2 | 3 | 4 |
|------:|--:|--:|--:|---:|----:|
| m=1   | 1 | 1 | 2 | 5  | 14  |
| m=2   | 1 | 1 | 3 | 12 | 55  |
| m=3   | 1 | 1 | 4 | 22 | 140 |

* `m=1`: `1,1,2,5,14,42,…` — Catalan numbers, **OEIS A000108**.
* `m=2`: `1,1,3,12,55,273,…` — ternary-tree / Fuss–Catalan, **OEIS A001764**.
* `m=3`: `1,1,4,22,140,969,…` — quaternary Fuss–Catalan, **OEIS A002293**.

Sanity check of the *closed form* `(mn+1)·Cat_m(n) = C((m+1)n, n)`:
e.g. `m=2, n=3`: `(2·3+1)·12 = 7·12 = 84 = C(9,3)` ✓.

## 2. `m`-Tamari interval numbers `Int_m(n) = (m+1)/(n(mn+1))·C((m+1)²n+m, n−1)`

| m \ n | 1 | 2 | 3  | 4   | 5   |
|------:|--:|--:|---:|----:|----:|
| m=1   | 1 | 3 | 13 | 68  | 399 |
| m=2   | 1 | 6 | 58 | 703 |  –  |

* `m=1`: `1,3,13,68,399,…` — **OEIS A000260**, the number of intervals in the
  Tamari lattice, equinumerous with rooted planar triangulations (Chapoton).
* `m=2`: `1,6,58,703,…` — the 2-Tamari interval numbers (Bousquet-Mélou–Chapoton),
  conjecturally the number of planar 3-constellations.

Each of these is a genuine *integer* even though the defining formula is rational;
`FussCatalanEnumeration.lean` verifies `Int_1(1..4)` and `Int_2(2..3)` exactly over
`ℚ`.

## 3. Elements vs. intervals

`Int_m(n) ≥ Cat_m(n)` in every computed case, with equality only at `n=1`:

| n | Cat_1(n) | Int_1(n) |
|--:|---------:|---------:|
| 1 | 1        | 1        |
| 2 | 2        | 3        |
| 3 | 5        | 13       |
| 4 | 14       | 68       |

The strict inequality at `n=2` is proved (`interval_gt_element`).

## 4. Counterexample hunt

* **Symmetry** `Cat_m(n) = Cat_n(m)`? FALSE: `Cat_1(2)=2 ≠ 1=Cat_2(1)`
  (proved: `not_symmetric`).
* **`m`-free two-term** `Cat_m(n) = C((m+1)n,n) − C((m+1)n,n−1)`? FALSE:
  at `m=n=2` the RHS is `15−6=9 ≠ 3` (proved: `not_binomial_difference_without_m`).
  The multiplier `m` on the second binomial is essential.
* **Divisibility** `(mn+1) ∣ C((m+1)n, n)`? TRUE for all tested `m,n` — and proved
  in general (`fussCatalan_dvd`).
