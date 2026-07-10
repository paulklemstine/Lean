# Computational Evidence: Hypergraph Ramsey Numbers

This note records the small-case data that motivates the formalized results in
`Logic/HypergraphRamsey.lean`.

## 1. The boundary family `R_r(r, l)` (the part we prove exactly)

A red clique `K_r^{(r)}` is a *single* red `r`-edge, so the diagonal-boundary
Ramsey number collapses to a clean formula:

| r | l | R_r(r,l) | reason                                              |
|---|---|----------|-----------------------------------------------------|
| 3 | 3 | 3        | the one 3-subset of a 3-set is red or blue          |
| 3 | 4 | 4        | any red 3-edge, else all-blue on 4 points is a K_4  |
| 3 | 5 | 5        | same argument                                       |
| 2 | 2 | 2        | one edge of K_2 is red or blue                      |
| 2 | l | l        | classical: a red edge, or an all-blue K_l           |
| r | l | l        | (for r ≤ l)                                         |

The general pattern `R_r(r, l) = l` for `r ≤ l` is exactly `RamseyNumber_r_l`,
with matching upper bound (`RamseyProp_r_l_upper`) and lower bound
(`not_RamseyProp_r_l`). The diagonal `R_r(r,r) = r` is the specialization
`RamseyNumber_diag_eq`.

## 2. The hard diagonal `R_3(k, k)` (the conjecture, not proved)

Known / bounded values (literature):

| k | R_3(k,k)      |
|---|---------------|
| 3 | 3             |
| 4 | 13   (known)  |
| 5 | 34 – 55       |
| 6 | 82 – ~6000    |

These are far beyond exhaustive verification: the number of 2-colorings of the
3-subsets of an n-set is `2^{C(n,3)}`, e.g. `2^{C(13,3)} = 2^286`, so a direct
`decide` search is infeasible. This is why the file proves the *boundary* family
exactly and treats the diagonal growth only through the tower function.

## 3. Growth-rate separation (the tower function)

`tower 2 k` (height-2 tower, `= 2^2^…`) is the conjectured order of `R_3(k,k)`.

| k | tower 2 k |  4^k  |
|---|-----------|-------|
| 0 | 1         | 1     |
| 1 | 2         | 4     |
| 2 | 4         | 16    |
| 3 | 16        | 64    |
| 4 | 65536     | 256   |
| 5 | 2^65536   | 1024  |

From `k = 4` on, `tower 2 k` overtakes `4^k` (the Erdős–Szekeres graph bound
`R_2(k,k) ≤ 4^k`), and the gap explodes. The formalized statement
`four_pow_lt_tower` proves `4^k < tower 2 k` for all `k ≥ 5`, capturing the
sense in which 3-uniform Ramsey numbers are conjectured to dwarf graph Ramsey
numbers.

## 4. Counterexample hunt

- `RamseyNumber_r_l` was tested against the table in §1 before formalizing; no
  counterexample. The exact boundary formula `R_r(r,l) = l` (r ≤ l) matches all
  known small values.
- The monotonicity lemmas (`mono_left`, `mono_right`, `mono_n`) and color
  symmetry (`symm`) are structural and were sanity-checked on the boundary
  family; all consistent.
- `tower_two_strict_mono` and `four_pow_lt_tower` were checked numerically
  (table §3) before proof.

All numeric claims used in the Lean file (e.g. `4^5 = 1024 < 65536 = tower 2 4`)
are discharged inside Lean by `decide`/`native_decide`, so the evidence above is
backed by machine-checked arithmetic where it enters a proof.
