# Computational Evidence — C5-decomposition divisibility & the 5/8 threshold

All computations below were run in Lean 4 with Mathlib (`#eval`) and are reproduced by the
formal theorems in `C5Decomposition.lean` and `C5Threshold.lean`.

## 1. Small-case divisibility checks

C5-divisibility = (every vertex has even degree) ∧ (5 ∣ #edges). The necessity theorem
`c5_decomposition_divisible` says any graph with a C5-decomposition must satisfy both.

| Graph              | #edges | degree multiset | even degrees? | 5 ∣ #edges? | C5-divisible? | decomposes? |
|--------------------|:------:|:---------------:|:-------------:|:-----------:|:-------------:|:-----------:|
| `cycleGraph 5` (C₅)|   5    | {2,2,2,2,2}     | yes           | yes (5)     | **yes**       | yes (1 cycle) |
| `K₅`               |  10    | {4,4,4,4,4}     | yes           | yes (10)    | **yes**       | yes (2 cycles, classical) |
| `K₄`               |   6    | {3,3,3,3}       | no            | no (6≡1)    | **no**        | no (both obstructions fire) |

`#eval` outputs (verbatim):
- `(cycleGraph 5).edgeFinset.card = 5`, degrees image `{2}`.
- `(completeGraph (Fin 5)).edgeFinset.card = 10`, degrees image `{4}`.
- `(completeGraph (Fin 4)).edgeFinset.card = 6`, degrees image `{3}`.

The pentagon row is fully formalized: `cycleGraph5_hasDecomposition` and
`cycleGraph5_isC5Divisible`. `K₄` is the smallest complete-graph obstruction (odd degrees AND
non-divisible edge count), confirming that the necessity theorem is not vacuous on natural
inputs.

## 2. The threshold sequence δ_{C_ℓ} = ℓ/(2ℓ−2)

Computed as rationals (`(l : ℚ)/(2*l-2)`):

| ℓ |  2  |   3  |   4  |   5   |   6   |   7    |   8    | → ∞  |
|---|:---:|:----:|:----:|:-----:|:-----:|:------:|:------:|:----:|
| δ |  1  | 3/4  | 2/3  | **5/8** | 3/5 | 7/12 | 4/7 | → 1/2 |

Decimal: `1, 0.75, 0.6667, 0.625, 0.6, 0.5833, 0.5714, … → 0.5`. Strictly decreasing,
bounded below by 1/2 — exactly the content of `nwThreshold_strictAnti`, `nwThreshold_gt_half`,
and `nwThreshold_lt_one`. The headline value `δ_{C_5} = 5/8` (`nwThreshold_five`) is the
third interior term and is strictly sandwiched: `1/2 < 5/8 < 2/3` (`nwThreshold_five_between`).

## 3. Counterexample hunt (necessity direction)

We searched for a graph admitting a C5-decomposition yet failing C5-divisibility — none can
exist by `c5_decomposition_divisible`, and the search confirms it: every decomposable example
(C₅, K₅, disjoint unions thereof) is C5-divisible. Conversely `K₄` (and any graph with an
odd-degree vertex) is correctly rejected by `no_decomposition_of_not_divisible`.

No counterexample to the *necessity* direction exists (it is a theorem). The *sufficiency*
direction at min-degree `(5/8 + ε)n` is the open conjecture left for `FUTURE_DIRECTIONS.md`.

## 4. OEIS note

The denominators/numerators of the reduced threshold sequence `1, 3/4, 2/3, 5/8, 3/5, 7/12, …`
do not correspond to a single notable OEIS entry once reduced; in unreduced form
`δ_{C_ℓ} = ℓ/(2ℓ−2)` it is simply the rational function tabulated above, so no sequence lookup
is needed.
