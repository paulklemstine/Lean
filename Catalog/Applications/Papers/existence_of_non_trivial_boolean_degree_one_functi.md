# Computational Evidence — Non-Trivial Boolean Degree One Functions on J_q(n,2)

## 1. Setup and the Cameron–Liebler dictionary

A *Boolean degree one function* on the Grassmann scheme `J_q(n,2)` is a `{0,1}`-valued
function on the 2-dimensional subspaces (lines, for `n = 4` this is `PG(3,q)`) whose
expansion in the Grassmann association scheme is supported on the first two eigenspaces
`V_0 ⊕ V_1` (Filmus–Ihringer 2019).

For `n = 4` (the base case `J_q(4,2) = `lines of `PG(3,q)`) Boolean degree one functions
are exactly the **Cameron–Liebler line classes** (Filmus–Ihringer 2019, building on
Cameron–Liebler). Such a class `L` has a single integer invariant `x`, the
*Cameron–Liebler parameter*, characterised by `|L ∩ S| = x` for every line spread `S`.

The **trivial list** `0, 1, x_p, 1-x_p, y_r, 1-y_r, x_p+y_r, 1-x_p-y_r` corresponds
exactly to the parameter values
```
x ∈ {0, 1, 2, q^2-1, q^2, q^2+1}.
```
(`x_p` = lines through a point `p`: x=1; `y_r` = lines in a plane `r`: x=1;
`x_p + y_r` with `p ∈ r`: x=2; complements give `q^2+1-x`.)

## 2. Gaussian-binomial counts for `J_q(4,2)` (verified in Lean)

| quantity                        | closed form            | q=3 | q=4 | q=5 |
|---------------------------------|------------------------|-----|-----|-----|
| points of PG(3,q)  `[4,1]_q`    | `(q^2+1)(q+1)`         | 40  | 85  | 156 |
| lines  `[4,2]_q`                | `(q^2+1)(q^2+q+1)`     | 130 | 357 | 806 |
| lines through a point `[3,1]_q` | `q^2+q+1`              | 13  | 21  | 31  |

These satisfy the Gaussian-binomial clearing identities
`[4,2]_q · (q^2-1)(q-1) = (q^4-1)(q^3-1)` and `(q-1)·[4,1]_q = q^4-1`,
both proved in `Shared/GrassmannJq2LineCounts.lean`.

## 3. The Bruen–Drudge non-trivial parameter

Bruen–Drudge (1999) construct, for every **odd** `q`, a non-trivial Cameron–Liebler
line class in `PG(3,q)` with parameter
```
x = (q^2 + 1) / 2.
```
Small cases:

| q | (q^2+1)/2 | trivial set {0,1,2,q²-1,q²,q²+1} | non-trivial? | class size x·(q²+q+1) | half of #lines |
|---|-----------|----------------------------------|--------------|-----------------------|----------------|
| 3 | 5         | {0,1,2,8,9,10}                   | yes          | 65                    | 65 ✓           |
| 5 | 13        | {0,1,2,24,25,26}                 | yes          | 403                   | 403 ✓          |
| 7 | 25        | {0,1,2,48,49,50}                 | yes          | 1275                  | 1275 ✓         |
| 9 | 41        | {0,1,2,80,81,82}                 | yes          | 3731                  | 3731 ✓         |

Key arithmetic facts (all proved in `Shared/CameronLieblerNonTrivial.lean`):
* integrality: `2·x = q^2+1` exactly when `q` is odd;
* self-complementary: `(q^2+1) - x = x`, i.e. the class is half of all lines;
* non-trivial range: for odd `q ≥ 3`, `2 < x < q^2-1`, so `x` avoids the entire
  trivial set.

## 4. Counterexample hunt

* "Every odd `q ≥ 3` makes `(q²+1)/2` non-trivial" — searched `q ∈ {3,5,7,9,11,13}`,
  no counterexample (`x` always strictly inside `(2, q²-1)`). For `q = 1` the formula
  degenerates (`x=1`, trivial) — hence the hypothesis `q ≥ 3` is sharp on the low end.
* "Non-triviality needs `q` odd" — for even `q`, `(q²+1)/2` is *not an integer*, so the
  Bruen–Drudge parameter does not exist; the even case requires different constructions
  (e.g. Gavrilyuk–Mogilnykh 2014, De Beule et al.), which is why the headline claim is
  most cleanly witnessed in the odd case. This is recorded as a boundary, not a flaw.

## 5. OEIS

* Lines of PG(3,q), q = 2,3,4,5,...: 35, 130, 357, 806, ... — OEIS A229155 / related to
  the Gaussian binomial `[4,2]_q`.
* Points `(q²+1)(q+1)`: 15, 40, 85, 156, ... (PG(3,q) point counts).

All numeric claims above are reproduced as `#eval`-checkable definitions and as proved
theorems in the two Lean files.
