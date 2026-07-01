# Computational Evidence: Projective-Plane Coupon Slowness

All exact rationals below are produced and machine-checked in the two Lean files
`ProjectivePlaneCouponSlowness.lean` and `CouponBaselineDichotomy.lean`.

## The two mechanisms

On the `n = q²+q+1` points of the projective plane of order `q`:

- **Line mechanism** `L_q`: draw a uniformly random *line* (there are `n` lines, each a
  `(q+1)`-subset).
- **Uniform mechanism** `U_q`: draw a uniformly random `(q+1)`-subset (all `C(n, q+1)` of them).

Cover time is the inclusion–exclusion functional
`expCoverTime B = ∑_{∅≠S} (-1)^{|S|+1} |B| / coverCount(B,S)`.

The claim under test: `E[cover time | L_q] > E[cover time | U_q]` for every prime power `q ≥ 2`.

## Small-case calculations (exact, machine-verified)

| q | n  | k=q+1 | E[L_q] (line)                       | E[U_q] (uniform subset)                       | L_q − U_q | L_q > U_q ? |
|---|----|-------|-------------------------------------|-----------------------------------------------|-----------|-------------|
| 2 | 7  | 3     | `163/30 ≈ 5.43333`                  | `85691/15810 ≈ 5.41999`                       | `7/527 > 0` | **yes**   |
| 3 | 13 | 4     | `43633/4620 ≈ 9.44437`             | `1746879067753/185252315340 ≈ 9.42973`        | `> 0`     | **yes**     |

- `q = 2` uses the Fano plane `{{0,1,2},{0,3,4},{0,5,6},{1,3,5},{1,4,6},{2,3,6},{2,4,5}}`.
- `q = 3` uses `PG(2,3)` realised on `ZMod 13` as the translates of the planar difference set
  `{0,1,3,9}` (a perfect `(13,4,1)`-difference set). Both line families are verified to be genuine
  `2-(n, q+1, 1)` designs (`fano_is_design`, `pg3_is_design`).

The uniform-side values are **not** obtained by enumerating all `C(n, q+1)` subsets; they follow
from the proved closed form
`E[U_q] = ∑_{s=0}^{n} C(n,s) · (-1)^{s+1} · C(n,k) / (C(n,k) − C(n−s, k))`
(`expCoverTime_uniform`), finished with `norm_num`.

## The three-way sandwich (q = 2)

Adding the classical *singleton* mechanism (one point per draw), the exact ordering is

`E[U_2] = 85691/15810  <  E[L_2] = 163/30  <  E[singletons] = 363/20 = 7·H₇`.

So the Fano plane is **slower** than uniform 3-subsets but **faster** than singletons. This is the
key to reconciling the two literatures: comparisons against singletons see a fast plane;
comparisons against uniform subsets (the Grünbaum–Yaakobi baseline) see a slow plane.

## OEIS search

The denominators/numerators of `E[U_q]` and `E[L_q]` are `q`-specific composite rationals; no
clean integer subsequence was identified as an OEIS match, so no OEIS ID is claimed. The singleton
values `n·Hₙ` are the classical coupon-collector expectations (`H₇ = 363/140`).

## Counterexample hunt

The universal claim `E[L_q] > E[U_q]` was tested on all realisable small prime powers we could
verify exactly (`q = 2, 3`). No counterexample was found; both give a strict positive gap. Larger
`q` (`q = 4`, `n = 21`; `q = 5`, `n = 31`) require summing over `2^n` subsets on the line side and
were **not** verified here — they are reported as supporting in the source literature but are left
as unverified in this project (see `FUTURE_DIRECTIONS.md`).

## Why the gap is positive (heuristic)

For a fixed subset `S`, `coverCount(U_q, S) = C(n,k) − C(n−|S|,k)` is the *largest possible*
per-step new-coverage count among all families of `k`-subsets. The projective lines are a highly
structured measure-zero sub-family, so `coverCount(L_q, S) ≤ coverCount(U_q, S)` for every `S`,
which pushes each reciprocal `|B|/coverCount` up and — after the alternating sum stabilises —
raises the total. Making this term-by-term domination rigorous is the proposed route to general `q`.
