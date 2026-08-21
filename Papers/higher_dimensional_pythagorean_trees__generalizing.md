# Computational Evidence — Higher-Dimensional Pythagorean Trees

All computations below were exploratory (Python, exact integer arithmetic). Every claim that
is *asserted* in this project is separately proved in Lean 4 (`Catalog/Shared/HigherPythagorean/`);
the data here only motivated the theorem statements.

## 1. The setting

For the Lorentz form `q(x₁,…,xₙ, y) = x₁² + … + xₙ² − y²` let `r = (1,…,1;1)`, so `q(r) = n − 1`.
The reflection in `r` is

    s_r(v) = v − (2·B(v,r)/(n−1))·r,     B(v,r) = x₁+…+xₙ − y.

* `n = 2` : `q(r) = 1`, `s_r(a,b,c) = (a−2k, b−2k, c−2k)` with `k = a+b−c` — composed with the four
  sign changes these are exactly Berggren's three moves.
* `n = 3` : `q(r) = 2`, `s_r(a,b,c,d) = (a−k, b−k, c−k, d−k)` with `k = a+b+c−d`. Still integral.
* `n ≥ 4` : `2/(n−1) ∉ ℤ`, so `s_r` is **not** an integral map. (Proved: `refl_not_integral_of_four_le`.)

A *descent* from a node is a sign pattern `ε ∈ {±1}ⁿ` such that the move applied to
`(ε₁x₁,…,εₙxₙ, y)` strictly decreases the height `y` (and keeps it positive).

## 2. Triples (n = 2): exactly one descent — a genuine tree

All 71 primitive triples with legs < 400 were enumerated. Distribution of the number of
distinct decreasing neighbours:

| #descents | 0 | 1 | 2 |
|---|---|---|---|
| count | 0 | **71** | 0 |

Unique parent for every node ⇒ the Berggren graph is a tree. Proved in Lean:
`triple_unique_descent_sign` (only `ε = (+,+)` can decrease) and `triple_plus_descent_pos`.

## 3. Quadruples (n = 3): up to two descents — **not** a tree

All 348 primitive reduced quadruples `0 ≤ a ≤ b ≤ c`, `d ≤ 80`, `gcd = 1` were enumerated.
Distribution of the number of distinct decreasing neighbours:

| #descents | 0 | 1 | 2 | ≥3 |
|---|---|---|---|---|
| count | 1 (the root `(0,0,1,1)`) | 151 | **196** | 0 |

So the majority of nodes have **two** parents: the height-descent structure on Pythagorean
quadruples is a connected graph with many cycles, not a tree. Both facts were then proved:

* never more than two descents: `quad_at_most_two_descents` (a two-minus pattern can never
  descend, and two distinct one-minus patterns cannot both descend);
* two descents occur infinitely often: `quad_two_parents_family`, the family
  `(1, 2m, 2m², 2m²+1)`, `m ≥ 2`.

First members of the family and their two parents (heights in brackets):

| node | parent A | parent B |
|---|---|---|
| (1,4,8,9)   | (3,0,4,5)     [5]  | (3,2,6,7)      [7]  |
| (1,6,18,19) | (5,0,12,13)   [13] | (5,2,14,15)    [15] |
| (1,8,32,33) | (7,0,24,25)   [25] | (7,2,26,27)    [27] |
| (1,10,50,51)| (9,0,40,41)   [41] | (9,2,42,43)    [43] |

(The heights of the two parents differ by exactly 2 for the whole family; the general formulas
are `2m²−2m+1` and `2m²−2m+3`.)

## 4. Connectivity / completeness

For every one of the 348 enumerated primitive quadruples, iterating the all-plus move
terminates at `(0,0,1,1)` (max 200 iterations allowed; all terminated). This is the
computational shadow of the Lean theorem `reach_of_prim`: *every* primitive Pythagorean
quadruple with non-negative entries lies in the orbit of `(1,0,0,1)` under the group generated
by the reflection `s_r`, the coordinate sign changes and the coordinate permutations.

## 5. Growth constants

Maximal one-step expansion factor of the height over the real null cone
(`ε = (−1,…,−1)`, `xᵢ = d/√n`):

| n | expansion factor | value | remark |
|---|---|---|---|
| 2 | `(√2+1)/(√2−1) = 3+2√2` | 5.828… | `= (1+√2)²`, silver-ratio square; fundamental norm-1 unit of ℤ[√2] |
| 3 | `(√3+1)/(√3−1) = 2+√3`  | 3.732… | fundamental norm-1 unit of ℤ[√3] |
| n | `(√n+1)/(√n−1)`          | → 1    | proved in general (`lorentz_move_height_bound`) |

The general bound and its sharpness at `n = 3` are theorems
(`lorentz_move_height_bound`, `quad_growth_bound_sharp`).

## 6. Sequence lookup

The counts of primitive quadruples by height are the well-studied sequence of primitive
Pythagorean quadruples; no new OEIS entry is claimed here, and no numerical claim in this
project rests on an OEIS identification.
