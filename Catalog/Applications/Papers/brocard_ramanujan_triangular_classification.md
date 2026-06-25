# Computational Evidence — Brocard–Ramanujan via Triangular Numbers

Topic: the only `n` for which `n!/8` is a triangular number (equivalently the
only Brown numbers `n! + 1 = m²`).

## 1. Small-case table

The bridge is `8 · T_y + 1 = (2y+1)²`, so `n!/8 = T_y` ⟺ `n!+1 = (2y+1)²`.

| n  | n!       | n!/8     | is n!/8 triangular? | index y | n!+1     | m (=2y+1) |
|----|----------|----------|---------------------|---------|----------|-----------|
| 0  | 1        | 0 (1/8)  | n!/8 not integer    | —       | 2        | —         |
| 1  | 1        | —        | not integer         | —       | 2        | —         |
| 2  | 2        | —        | not integer         | —       | 3        | —         |
| 3  | 6        | —        | not integer         | —       | 7        | —         |
| 4  | 24       | 3        | **yes**, T_2 = 3    | **2**   | 25       | **5**     |
| 5  | 120      | 15       | **yes**, T_5 = 15   | **5**   | 121      | **11**    |
| 6  | 720      | 90       | no (T_12=78,T_13=91)| —       | 721      | —         |
| 7  | 5040     | 630      | **yes**, T_35 = 630 | **35**  | 5041     | **71**    |
| 8  | 40320    | 5040     | no                  | —       | 40321    | —         |
| 9  | 362880   | 45360    | no                  | —       | 362881   | —         |
| 10 | 3628800  | 453600   | no                  | —       | 3628801  | —         |

Note `8 ∣ n!` exactly when `n ≥ 4`, so the question is only nontrivial there.
The three hits `n = 4, 5, 7` give triangular indices `2, 5, 35`.

## 2. OEIS

* Brown numbers / `n! + 1 = m²` solutions `n = 4, 5, 7`: OEIS **A085692**
  (and related A146968 for the corresponding `m = 5, 11, 71`).
* Triangular numbers `T_y`: OEIS **A000217** (`0,1,3,6,10,15,21,28,36,45,55,...`).
  Indices appearing here: `T_2=3, T_5=15, T_35=630`.

## 3. Counterexample hunt

We searched `8 ≤ n ≤ 50` for any triangular witness (equivalently any perfect
square `n!+1`) using `Nat.sqrt`. No counterexample was found; this is formalized
as `BrocardTriangular.no_triangular_witness_8_to_50` (proved, 0 sorries, via
`interval_cases` + `Nat.sqrt`). The companion file
`Catalog/Probability/BrocardBorelCantelli.lean` independently verifies the range
up to 1000 (`brocard_no_others_below_1000`). No Brown number other than 4,5,7
exists in any checked range.

## 4. Status of the universal claim

The full statement "n = 4, 5, 7 are the ONLY such n" is exactly the
**Brocard–Ramanujan problem**, an open conjecture. It is NOT asserted as a
theorem. What is proved unconditionally:

* the geometric equivalence `n!/8 triangular ⟺ n!+1 square`
  (`factorial_eq_eight_triangular_iff_brown`);
* the general triangular-number test `t triangular ⟺ 8t+1 square`
  (`triangular_iff_eight_succ_square`);
* the three solutions and the finite verification above.
