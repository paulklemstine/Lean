# Computational evidence

All computations below were run in Lean (`#eval`) on the same definitions later
formalized in `Catalog/Applications/SurveillanceNetworks/PrivacyThreshold.lean`
(Hamming distance `hdist` on `Fin N → Bool`, exhaustive enumeration of the
`2^N` binary tensors).

## 1. Exact Hamming ball volume

Claim: `|{s : hdist c s ≤ D}| = ∑_{i ≤ D} C(N, i)` for every centre `c`.

| N | D | enumerated ball size | `∑_{i≤D} C(N,i)` |
|---|---|---|---|
| 3 | 0 | 1 | 1 |
| 3 | 1 | 4 | 4 |
| 3 | 2 | 7 | 7 |
| 3 | 3 | 8 | 8 |
| 4 | 2 | 11 | 11 |
| 5 | 2 | 16 | 16 |

Agreement in all tested cases (the rows are the partial-sum rows of Pascal's
triangle, OEIS A008949).

## 2. Covering radius of the one-codeword code

Claim: `coveringRadius (hdist) = N` on `Fin N → Bool`, i.e. `min_c max_s d(c,s) = N`.

Enumerated `min_c max_s hdist c s` for `N = 0,1,2,3,4`: `0, 1, 2, 3, 4`.

This matches the theorem `hamming_coveringRadius` (the maximum is attained at the
bitwise complement of the centre, so no centre does better than the trivial one).

## 3. Counterexample hunt for the privacy threshold

For `N ≤ 4` every perfectly private deterministic channel was checked to be a
constant map, hence to have a single reconstruction centre; worst-case distortion
of the best centre equals the covering radius `N` computed above. No `D < N` is
privately achievable in any enumerated case, in agreement with
`hamming_privatelyAchievable_iff`. The randomized statement is proved in full
generality (a private randomized channel has a configuration-independent support,
so any record in that support yields a single valid centre), so no separate
numerical search was made there.

## 4. Rate lower bound

With `2^N` histories and radius-`D` balls of volume `∑_{i≤D} C(N,i)`, the
covering converse gives `rate ≥ 2^N / ∑_{i≤D} C(N,i)`. For `D = 1`:

| N | `2^N` | ball volume `N+1` | forced rate ≥ |
|---|---|---|---|
| 2 | 4 | 3 | 2 |
| 3 | 8 | 4 | 2 |
| 4 | 16 | 5 | 4 |

so the bound is nontrivial as soon as `N ≥ 2`.
