# Computational evidence

Object: the **central graph** `C(G)` of a finite simple graph `G` on `n = |V(G)|`
vertices, and its **AVD total chromatic number** `χ''ₐ(C(G))`.

All numeric claims below are backed by the machine-checked theorems in
`Basic.lean` (no `sorry`, only the standard axioms `propext`, `Classical.choice`,
`Quot.sound`).

## 1. Degree structure of `C(G)` (proved)

`C(G)` has vertex set `V(G) ⊕ E(G)`.

| vertex type            | degree in `C(G)`   | Lean theorem            |
|------------------------|--------------------|-------------------------|
| subdivision vertex `e` | `2`                | `central_degree_inr`    |
| original vertex `v`    | `n − 1`            | `central_degree_inl`    |

Consequently `Δ(C(G)) = n − 1` for `n ≥ 3`, and the maximum-degree vertices are
exactly the original vertices.

## 2. The controlling parameter is `n`, not `d`

Two original vertices `u, v` are adjacent in `C(G)` **iff** they are non-adjacent
in `G` (`central_inl_inl_iff`). Hence:

* If `G` is **not** complete, there exist two adjacent vertices of `C(G)`, both of
  maximum degree `n − 1`. The adjacent-equal-degree obstruction
  (`not_isAVD_of_adjacent_eqdeg`) then forces
  `χ''ₐ(C(G)) ≥ (n − 1) + 2 = n + 1` (`central_no_avd_of_not_complete`).
* If `G = Kₙ` is complete, the original vertices are **pairwise non-adjacent** in
  `C(G)` (`central_complete_inl_indep`): the maximum-degree vertices form an
  independent set, so the obstruction does not apply. This is the structural
  reason the complete case behaves differently.

## 3. Small cases vs. the mission conjecture

The mission conjectures `χ''ₐ(C(G)) = d + 3` for every `d`-regular non-complete
`G`. Comparing with the proved lower bound `χ''ₐ(C(G)) ≥ n + 1`:

| `G`                    | `d` | `n` | conjectured `d+3` | proved lower bound `n+1` |
|------------------------|-----|-----|-------------------|--------------------------|
| `K₄ − perfect matching`| 2   | 4   | 5                 | 5      (consistent)      |
| cycle `C₅`             | 2   | 5   | 5                 | **6**  (contradiction)   |
| cycle `C₆`             | 2   | 6   | 5                 | **7**  (contradiction)   |
| cycle `Cₙ`, `n ≥ 5`    | 2   | n   | 5                 | **n+1 > 5**              |
| `d`-reg., `n = d+2`    | d   | d+2 | d+3               | d+3    (consistent)      |
| `d`-reg., `n > d+2`    | d   | n   | d+3               | **n+1 > d+3**            |

So `d + 3` is correct **only** in the boundary case `n = d + 2` (a `d`-regular
graph on `d + 2` vertices, i.e. the complement of a perfect matching). Whenever
`n > d + 2` the conjecture is false.

## 4. Machine-checked counterexample

`cycle5_no_avd_five_colors` proves that `C(C₅)` has **no** AVD total colouring with
`5` colours. Since `C₅` is `2`-regular (`d = 2`) and not complete, the conjecture
predicts `d + 3 = 5`, but the proof shows `χ''ₐ(C(C₅)) ≥ 6`. This is a fully
verified refutation of the literal conjecture.

## 5. OEIS

The proved lower bound `χ''ₐ(C(G)) ≥ n + 1` for non-complete `G` is a linear
function of `n`; no interesting integer sequence arises, so no OEIS entry is
relevant.
