# Computational Evidence — Factoring Frontier cycle

Script: `scripts/factoring_frontier_evidence.py` (plain Python, no dependencies).
These are exploratory checks; the claims themselves are proved in Lean in
`Catalog/Applications/FactoringFrontier/`. Small instances are also
kernel-checked inside the Lean files ("Lab notes" sections).

## 1. MPQS column set = single-polynomial split set
For each odd prime `p < 2000` not dividing `N`, a random MPQS polynomial
`(a x + b)^2 − N` with `p ∤ a` was tested over one full period, and the hit
set was compared with the Euler criterion `N^{(p−1)/2} ≡ 1 (mod p)`.

| N | primes tested | agreement | split density |
|---|---|---|---|
| 10403 = 101·103 | 300 | 300/300 | 0.493 |
| 1000036000099 = 1000003·1000033 | 302 | 302/302 | 0.513 |
| 2147483645 | 300 | 300/300 | 0.507 |

No counterexample. Density about 1/2 matches `mpqs_column_density`
(exactly `(p−1)/2` residues per prime). The record's earlier "~1/4" value is not
reproduced.

## 2. Pythagorean triples with leg N
All triples `N^2 + b^2 = c^2` with `b > 0`, listed as `(c−b, b, c, gcd(c−b, N))`:

* `N = 15`: (1,112,113,**1**), (3,36,39,3), (5,20,25,5), (9,8,17,3)
* `N = 77`: (1,2964,2965,**1**), (7,420,427,7), (11,264,275,11), (49,36,85,7)
* `N = 9`: (1,40,41,**1**), (3,12,15,3)
* `N = 105`: 13 triples; every one with `c−b ≠ 1` has gcd in {3,5,7,15,21,35}.

Every triple with `c − b ≠ 1` gives a nontrivial gcd, and `c − b = 1` always gives
gcd 1. This matches `leg_triple_gcd_nontrivial` exactly, with no counterexample.
The triple count equals `(τ(N^2) − 1)/2`: 4 for `pq`, 13 for `105`. This count
is observed only, not proved.

## 3. Which-factor wall
Primes below 60 give 17 primes and 272 ordered pairs. The `minFac` decoder is
correct on 136 = 272/2 of them. This matches `minFac_attains_wall` (exactly
half) and `semiprime_which_factor_wall` (no decoder does better).

## 4. Rank-2 local obstruction
`A = {0,6}`, `B = {−5,−11}`: the differences are 5, 11, 11 and 17, all prime.
Mod 2 and mod 3 the residues of `A` and `B` are disjoint, and the cover is not
injective. This instance is kernel-checked in `RankTwoLocalObstruction.lean`.

## OEIS
The leg-triple count `(τ(N²)−1)/2` for odd `N` is the number of ways to write `N` as
a leg (OEIS A046079, "number of Pythagorean triangles with leg n"). This
identification comes from memory and was not re-checked online.
