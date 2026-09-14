# Computational Evidence — Collatz ↔ Berggren

All numerical observations below were subsequently encoded and machine-checked in the
Lean files `Catalog/Probability/CollatzBerggren*.lean`; the tables here only record
how the theorems were found.

## 1. Branching of the inverse Syracuse tree

Predecessors of an odd `n` are the odd `m` with `3m + 1 = 2^k n`, `k ≥ 1`.
Enumerating `k = 1 … 13`:

| n  | first predecessors (k, m)                        | branching |
|----|--------------------------------------------------|-----------|
| 1  | (2,1), (4,5), (6,21), (8,85), (10,341)           | infinite  |
| 3  | —                                                | 0         |
| 5  | (1,3), (3,13), (5,53), (7,213), (9,853)          | infinite  |
| 7  | (2,9), (4,37), (6,149), (8,597), (10,2389)       | infinite  |
| 9  | —                                                | 0         |
| 11 | (1,7), (3,29), (5,117), (7,469), (9,1877)        | infinite  |
| 13 | (2,17), (4,69), (6,277), (8,1109), (10,4437)     | infinite  |
| 15 | —                                                | 0         |
| 17 | (1,11), (3,45), (5,181), (7,725), (9,2901)       | infinite  |
| 19 | (2,25), (4,101), (6,405), (8,1621), (10,6485)    | infinite  |
| 21 | —                                                | 0         |

Two patterns are immediate and both became theorems:

* branching is `0` exactly on multiples of `3` (`predSet_eq_empty_of_three_dvd`)
  and otherwise infinite (`predSet_infinite`) — so the inverse Collatz tree is
  **never ternary**;
* inside every fibre the successive predecessors obey `m ↦ 4m + 1`
  (`1, 5, 21, 85, …`; `3, 13, 53, 213, …`; `9, 37, 149, 597, …`).  This became the
  fibre structure theorem `predSet_eq_range_predFam`, i.e. each fibre is the orbit of
  a *single* affine letter.  (The fibre over `1`, `1, 5, 21, 85, 341, …`, is the
  "Jacobsthal-type" sequence `(4^j·4 − 1)/3`; the fibre over `5` is `3, 13, 53, 213`.)

## 2. Counterexample hunt for a conserved quadratic form

Because `1`, `5` and `21` are all predecessors of `1`, any edge-invariant function `f`
must satisfy `f(1) = f(5) = f(21)`.  For `f(x) = αx² + βx + γ` this forces
`24α + 4β = 0` and `440α + 20β = 0`, hence `α = β = 0`.  The same three points
already destroy every candidate Lorentz analogue; the general statement (all degrees)
is `no_nonconstant_polynomial_invariant`, proved from the infinitude of the fibre
over `1`.

## 3. Residue clock inside a fibre

`m ↦ 4m + 1` acts on residues mod 3 by `r ↦ r + 1`, so exactly one predecessor in three
is a dead node (a multiple of 3).  Sample fibre over `1`: `1, 5, 21, 85, 341, 1365`
with residues `1, 2, 0, 1, 2, 0`.  This is `predFam_mod_three`, and it is what makes
the *positive* result possible: every live node has at least three live predecessors,
so the ternary Berggren tree embeds (`berggren_ternary_subtree_of_collatz`), e.g.
root `1 ↦ 1`, children `5, 85, 341`.

## 4. Berggren spine growth

Pell hypotenuses `c₀ = 5, c₁ = 29, c₂ = 169, c₃ = 985, c₄ = 5741` with ratios
`5.8, 5.827…, 5.828…` converging to the silver ratio squared `(1+√2)² = 3 + 2√2 ≈ 5.8284`.
The proved window is `29/5 ≤ ratio ≤ 6` (`bHyp_silver_window`), and
`silver_sq_mem_window` verifies `29/5 < (1+√2)² < 6`.

## 5. Cycle words

The only cycle found in the small range is the self-loop `1 → 1` with word `[2]`,
weight `1` and cycle equation `1·(2² − 3¹) = 1`.  Words of all-ones length `L` would
need `3^L < 2^L`, impossible — hence `syr_cycle_has_big_step`.

## 6. Two-sided behaviour of the weight cocycle (second cycle of the loop)

Enumerating `syrWeight` on short admissible words and comparing with the candidate
bound `2^L · w ≤ 3^L · 2^S` (`L` = length, `S` = sum):

| word        | `w`  | `2^L · w` | `3^L · 2^S` | slack |
|-------------|------|-----------|-------------|-------|
| `[2]`       | 1    | 2         | 12          | 6×    |
| `[1,1]`     | 5    | 20        | 36          | 1.8×  |
| `[1,2]`     | 5    | 20        | 72          | 3.6×  |
| `[2,1]`     | 7    | 28        | 72          | 2.6×  |
| `[1,1,2]`   | 19   | 152       | 432         | 2.8×  |
| `[3,1,1]`   | 49   | 392       | 864         | 2.2×  |
| `[2,2,2]`   | 37   | 296       | 1728        | 5.8×  |
| `[1,2,1,3]` | 85   | 1360      | 10368       | 7.6×  |

The inequality holds in every sample and the worst case is the all-ones word, where
the slack shrinks towards `2`; this is exactly the induction step
`2^{L+1} ≤ 2^{k+S'}` used in `syrWeight_upper`.  The lower bound `3^{L-1} ≤ w` is
visible in the same table (`19 ≥ 9`, `49 ≥ 9`, `85 ≥ 27`) and is immediate from the
leading term of `syrWeight_cons`.  Feeding both into the cycle equation gives the
two-sided pin `syr_cycle_min_upper` / `syr_cycle_min_lower`, and in the regime
`2·3^L ≤ 2^S` the sharp bound `2^L·m ≤ 2·3^L` (`syr_cycle_two_heavy_bound`).  The
trivial cycle `[2]` has `2·3 = 6 > 4 = 2^S`, i.e. it sits on the critical side of that
dichotomy, so the theorem is not vacuous for the wrong reason.

## 7. A refuted guess about fibre residues

A natural guess while generalising the residue clock was that the fibre over `1`
is residue-constant mod `3`.  It is false: `1, 5, 21, 85, 341 ↦ 1, 2, 0, 1, 2`.  The
correct statement, now proved, is the period-`3` clock
`predFam 1 j % 3 = (j+1) % 3` (`predFam_one_mod_three`), whose general form is the
eventual periodicity of any rank-one fibre modulo any `m`
(`affOrbit_eventually_periodic_mod`).
