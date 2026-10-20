# Computational evidence — NFS columns governed by the field `d`, not by `N`

All numbers below were first computed with a short scratch script (unverified), then the ones
listed as **kernel-checked** were re-established in Lean by `decide +kernel` in
`Catalog/Logic/NFSFieldGovernedColumns.lean` (`lab_one_field_two_moduli`, `lab_qs_spread`).
Columns are taken over the **odd** primes `r ≤ 200` (44 odd primes in total).

## Small-case table (`B = 200`)

| object | parameter | count | status |
|---|---|---|---|
| NFS columns, `ℚ(√−7)` | `d = −7` | 21 (22 counting `r = 2`) | 21: kernel-checked |
| QS columns | `N = 11` (field `−7` valid: `2²+7 = 11`) | 20 | kernel-checked |
| QS columns | `N = 23` (field `−7` valid: `4²+7 = 23`) | 19 | kernel-checked |
| QS columns | `N = 15` | 21 | kernel-checked |
| QS columns | `N = 47` | 25 | kernel-checked |
| QS columns | `N = 21, 35, 77, 91, 143, 187, 221, 323` | 20, 21, 22, 18, 22, 23, 22, 26 | scratch only |

`qsColumns 11 200 ≠ qsColumns 23 200` is kernel-checked, while the NFS column set for
`d = −7` is a single object serving both moduli.

The brief's "22 elements" for `d = −7` counts `r = 2` (which splits in `ℚ(√−7)` since
`−7 ≡ 1 (mod 8)`); the formal file uses odd primes and gets 21.  The brief's "25 vs 21"
pair is reproduced by `N = 47` vs `N = 15` (the brief did not name its `N`s), but `−7` is
*not* a valid field for either of those, so the formal lab uses `N = 11, 23` instead.

## Degree-one prime counts (`1 + (d/r)`)
For `d = −7`: `r = 11, 23, 29, 37, 43, 53` (split, 2 ideals each); `r = 3, 5, 13, 17, 19, 31,
41, 47, 59` (inert, 0); `r = 7` (ramified, 1).  This matches `card_ringHom_zsqrtd`
(proved for every odd prime `r`).

## Counterexample hunt
- *"The NFS column pattern is forced by `N`"* — refuted for every `N`: `attainable_nfs_patterns`
  proves all `2^|S|` patterns occur.
- *"Validity of `d` imposes no condition at all"* — false: `valid_field_splits_at_factors`
  shows `(d/p) = +1` is forced at the prime factors `p ∣ N`.  E.g. `d = −7` is invalid for
  `N = 15` because `−7` is not a square mod `3`.

## OEIS
The primes splitting in `ℚ(√−7)` (`r ≡ 1, 2, 4 mod 7`): 2, 11, 23, 29, 37, 43, 53, …
(OEIS A045373, given from memory and not re-checked here).
