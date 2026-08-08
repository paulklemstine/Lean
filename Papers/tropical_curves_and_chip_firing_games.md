# Computational Evidence — Chip-Firing on Graphs and Tropical Riemann–Roch

All numbers below were produced by `evidence/chipfiring_evidence.py`, a from-scratch
implementation of Dhar's burning algorithm (`q`-reduced divisors) together with a brute-force
Baker–Norine rank computation
`r(D) = max { k : D - E is winnable for every effective E of degree k }`.

This file is *exploratory* evidence only. Every claim asserted as a theorem has an
independent, `sorry`-free Lean proof in `Catalog/Combinatorics/TropicalRiemannRoch/`; nothing
here is used as a substitute for a proof.

Conventions: `g = |E| - |V| + 1`, `K(v) = deg(v) - 2`, base vertex `q = 0`.
`Θ_3` is two hubs joined by three length-2 paths (`|V| = 5`, `|E| = 6`, `g = 2`).

## Raw output

```
== Table 1: genus, canonical degree, and rank of K ==
graph      |V| |E|   g  degK  r(K)  g-1
K_2          2   1   0    -2    -1   -1
K_3          3   3   1     0     0    0
K_4          4   6   3     4     2    2
K_5          5  10   6    10     5    5
K_6          6  15  10    18     9    9
C_3          3   3   1     0     0    0
C_4          4   4   1     0     0    0
C_5          5   5   1     0     0    0
C_6          6   6   1     0     0    0
P_2          2   1   0    -2    -1   -1
P_3          3   2   0    -2    -1   -1
P_4          4   3   0    -2    -1   -1
P_5          5   4   0    -2    -1   -1
Star_5       5   4   0    -2    -1   -1
Theta_3      5   6   2     2     1    1
Petersen    10  15   6    10     -    5

== Table 2: exhaustive Riemann-Roch check  r(D)-r(K-D) = deg D - g + 1 ==
  K_3       divisors tested    216   RR violations = 0
  K_4       divisors tested   1296   RR violations = 0
  C_3       divisors tested    216   RR violations = 0
  C_4       divisors tested   1296   RR violations = 0
  P_3       divisors tested    216   RR violations = 0
  P_4       divisors tested   1296   RR violations = 0
  Theta_3   divisors tested   7776   RR violations = 0

== Table 3: nu_t on K_n for the standard ordering t(i)=i  (nu(i)=i-1) ==
  K_2: nu = [-1, 0]              deg(nu) =  -1  g-1 =  -1  rank =  -1  winnable = False
  K_3: nu = [-1, 0, 1]           deg(nu) =   0  g-1 =   0  rank =  -1  winnable = False
  K_4: nu = [-1, 0, 1, 2]        deg(nu) =   2  g-1 =   2  rank =  -1  winnable = False
  K_5: nu = [-1, 0, 1, 2, 3]     deg(nu) =   5  g-1 =   5  rank =  -1  winnable = False
  K_6: nu = [-1, 0, 1, 2, 3, 4]  deg(nu) =   9  g-1 =   9  rank =  -1  winnable = False

== Table 4: Clifford  2 r(D) <= deg D  on special divisors ==
  K_4       violations = 0, extremal 2r-deg = 0 at D=[-1, -1, -1, 3] (r=0, deg=0)
  C_5       violations = 0, extremal 2r-deg = 0 at D=[-1, -1, 0, 2, 0] (r=0, deg=0)
  Theta_3   violations = 0, extremal 2r-deg = 0 at D=[-1, -1, 0, 0, 2] (r=0, deg=0)

== Table 5: number of degree-(g-1) non-winnable classes vs spanning trees ==
  K_3       g =  1, spanning trees =    3, non-winnable 0-reduced deg-(g-1) reps = 2
  K_4       g =  3, spanning trees =   16, non-winnable 0-reduced deg-(g-1) reps = 6
  K_5       g =  6, spanning trees =  125, non-winnable 0-reduced deg-(g-1) reps = 24
  K_6       g = 10, spanning trees = 1296, non-winnable 0-reduced deg-(g-1) reps = 120
  C_4       g =  1, spanning trees =    4, non-winnable 0-reduced deg-(g-1) reps = 3
  C_5       g =  1, spanning trees =    5, non-winnable 0-reduced deg-(g-1) reps = 4
  Theta_3   g =  2, spanning trees =   12, non-winnable 0-reduced deg-(g-1) reps = 7

== Table 6 (control): Riemann-Roch FAILS on a disconnected graph ==
  2K_2 (disconnected): |V|=4 |E|=2 g=-1; divisors tested 625, RR violations = 557
```

## Reading of the data

**Table 1 — `r(K) = g - 1`.** Holds on every graph tested (`K_n`, `C_n`, paths, a star, `Θ_3`).
This is Riemann–Roch at `D = K`; proved in Lean as `TropicalRR.rank_canonical`.
Trees give `g = 0`, `deg K = -2`, `r(K) = -1`; cycles give `g = 1`, `deg K = 0`, `r(K) = 0`.

**Table 2 — exhaustive Riemann–Roch check.** `r(D) - r(K - D) = deg D - g + 1` over the box
`D(v) ∈ [-2, 3]`: 216 divisors on `K_3` and `C_3`, 1296 on `K_4`, `C_4`, `P_4`, and 7776 on
`Θ_3`. **0 violations out of 12 246 divisors.** Proved in Lean as `TropicalRR.riemann_roch`.

**Table 3 — the explicit divisor class on `K_n`.** For the standard ordering `t(i) = i`,
`ν_t(i) = i - 1`, with `deg ν_t = g - 1` and rank exactly `-1` for `n = 2,…,6`. Proved in Lean
as `TropicalRR.degD_nu_finRank` and `TropicalRR.rank_nu_finRank`.

**Table 4 — Clifford.** `2 r(D) ≤ deg D` for special `D`: no violations on `K_4`, `C_5`, `Θ_3`,
and the bound is attained (`2r - deg = 0`). Proved in Lean as `TropicalRR.clifford`.

**Table 5 — the sharpest observation.** Counting `0`-reduced representatives of degree `g - 1`
that are *not* winnable (the "winnable" column is the complement inside the Jacobian, whose
order is the number of spanning trees):

| graph   | g  | spanning trees | non-winnable deg-(g-1) classes | winnable deg-(g-1) classes |
|---------|----|----------------|--------------------------------|----------------------------|
| `K_3`   | 1  | 3              | 2                              | 1                          |
| `K_4`   | 3  | 16             | 6                              | 10                         |
| `K_5`   | 6  | 125            | 24                             | 101                        |
| `K_6`   | 10 | 1296           | 120                            | 1176                       |
| `C_4`   | 1  | 4              | 3                              | 1                          |
| `C_5`   | 1  | 5              | 4                              | 1                          |
| `Θ_3`   | 2  | 12             | 7                              | 5                          |

For complete graphs the non-winnable counts are `2, 6, 24, 120`, i.e. `(n-1)!`
(OEIS A000142, factorial numbers). For cycles they are `n - 1`.

This is the count of acyclic orientations of `K_n` with a *fixed* unique source, which is the
combinatorial content of the Baker–Norine dichotomy. This observation was then **proved**:
`TropicalRR.ncard_maximal_nonwinnable_completeGraph` shows that `K_{n+1}` has exactly `n!`
maximal non-winnable divisors in `0`-reduced form, so exactly `n!` classes of degree `g - 1`
and rank `-1`. The Lean proof is *not* a computation. The lower bound
(`TropicalRR.card_maximal_nonwinnable_completeGraph`) comes from `ν_σ` being the unique
`0`-reduced representative of its class (`TropicalRR.nu_top_qreduced` plus uniqueness of
`q`-reduced divisors); the matching upper bound comes from a *top-degree rigidity* theorem
proved for arbitrary connected graphs, `TropicalRR.eq_nu_of_qreduced_of_degD`: a `q`-reduced
non-winnable divisor of degree `g - 1` *equals* some `ν_t`, because `exists_nu_dominating`
gives `D ≤ ν_t` pointwise and the two degrees agree.

**Table 6 — control experiment.** On the disconnected graph `2K_2` (`g = -1`), Riemann–Roch is
violated by 557 of the 625 divisors tested. Connectivity is therefore genuinely load-bearing,
and it appears as an explicit hypothesis `G.Connected` in every Lean statement that needs it.
`TropicalRR.genus_nonneg` records the companion fact that connectivity forces `g ≥ 0`.

## Counterexample hunt — summary

* No violation of Riemann–Roch, of Clifford's bound, of `r(K) = g - 1`, or of
  `rank(ν_t) = -1` was found on any connected graph tested.
* Clifford's bound needs both specialty hypotheses: once `deg D > 2g` one has
  `r(D) = deg D - g > deg D / 2`, so dropping `0 ≤ r(K - D)` makes the statement false.
* `ν_t` has rank `-1` even for non-injective `t`; injectivity is needed only for the degree
  formula `deg ν_t = g - 1`. The Lean statements reflect exactly this split
  (`TropicalRR.nu_not_winnable` has no injectivity hypothesis, `TropicalRR.degD_nu` does).


## Table 7 — Gonality (added in the gonality cycle)

`gon(G) = min { deg D : r(D) ≥ 1 }`, computed by brute force over effective divisors using the
same Dhar-burning rank routine (`evidence/chipfiring_evidence.py`, Table 7).

| graph | \|V\| | g | gon | g+1 | ⌊(g+3)/2⌋ |
|---|---|---|---|---|---|
| K_2 | 2 | 0 | 1 | 1 | 1 |
| K_3 | 3 | 1 | 2 | 2 | 2 |
| K_4 | 4 | 3 | 3 | 4 | 3 |
| K_5 | 5 | 6 | 4 | 7 | 4 |
| C_3 | 3 | 1 | 2 | 2 | 2 |
| C_4 | 4 | 1 | 2 | 2 | 2 |
| C_5 | 5 | 1 | 2 | 2 | 2 |
| C_6 | 6 | 1 | 2 | 2 | 2 |
| P_2 | 2 | 0 | 1 | 1 | 1 |
| P_3 | 3 | 0 | 1 | 1 | 1 |
| P_4 | 4 | 0 | 1 | 1 | 1 |
| P_5 | 5 | 0 | 1 | 1 | 1 |
| Star_5 | 5 | 0 | 1 | 1 | 1 |
| Θ_3 | 5 | 2 | 2 | 3 | 2 |

Observations that became theorems in `Gonality.lean`: `gon(K_n) = n - 1`
(`TropicalRR.gonality_top`), `gon = 1` exactly for the trees in the table
(`TropicalRR.gonality_eq_one_of_isTree`, plus `TropicalRR.one_le_gonality`), `gon = 2` for every
genus-`1` graph in the table (`TropicalRR.gonality_eq_two_of_genus_one`), and `gon ≤ g + 1`
throughout (`TropicalRR.gonality_le_genus_add_one`). The last column is the sharp bound of
Conjecture 3 in `FUTURE_DIRECTIONS.md`, still open; no row violates it, and the complete graphs
attain it for `n ≤ 5`. These computations are exploratory only — each theorem has an independent
Lean proof.


## Table 8 — Jacobian orders and hyperellipticity (added in the Jacobian/hyperelliptic cycle)

`|Jac(G)|` is computed by enumerating the `0`-reduced divisors of degree `0` (Dhar reduction,
`evidence/chipfiring_evidence.py`, Table 8), `τ(G)` by the Matrix–Tree determinant, and
`∏_{v ≠ q} deg v` is the bound proved in `TropicalRR.card_jac_le_prod_degree`. The last column
records whether the graph is hyperelliptic, i.e. `g ≥ 1` and `gon(G) = 2`.

| graph | \|V\| | g | \|Jac\| | τ(G) | ∏_{v≠q} deg v | hyperelliptic |
|---|---|---|---|---|---|---|
| K_2 | 2 | 0 | 1 | 1 | 1 | no |
| K_3 | 3 | 1 | 3 | 3 | 4 | yes |
| K_4 | 4 | 3 | 16 | 16 | 27 | no |
| K_5 | 5 | 6 | 125 | 125 | 256 | no |
| C_3 | 3 | 1 | 3 | 3 | 4 | yes |
| C_4 | 4 | 1 | 4 | 4 | 8 | yes |
| C_5 | 5 | 1 | 5 | 5 | 16 | yes |
| C_6 | 6 | 1 | 6 | 6 | 32 | yes |
| P_3 | 3 | 0 | 1 | 1 | 2 | no |
| P_4 | 4 | 0 | 1 | 1 | 4 | no |
| Star_5 | 5 | 0 | 1 | 1 | 1 | no |
| Θ_3 | 5 | 2 | 12 | 12 | 24 | yes |

Observations that became theorems in `Jacobian.lean` and `Hyperelliptic.lean`: `|Jac|` is
finite and bounded by `∏_{v ≠ q} deg v` (`TropicalRR.finite_jac`,
`TropicalRR.card_jac_le_prod_degree`), `|Jac| = 1` exactly for the trees in the table
(`TropicalRR.card_jac_eq_one_iff_isTree`), `|Jac| ≥ 2` once `g ≥ 1`
(`TropicalRR.two_le_card_jac_of_genus_pos`), every genus-one row is hyperelliptic
(`TropicalRR.hyperelliptic_of_genus_one`), and `K_4`, `K_5` are not
(`TropicalRR.not_hyperelliptic_top`). The column `|Jac| = τ(G)`, matching in every row, is the
still-open Conjecture 2 of `FUTURE_DIRECTIONS.md`; note the proved bound is strictly weaker
than `τ` for `n ≥ 4`. These computations are exploratory only — each theorem has an independent
Lean proof.
