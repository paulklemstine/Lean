# Computational Evidence: clique-face property of Birkhoff polytopes

We test the conjecture **"`B_n` satisfies the clique-face property iff `n ≤ 2`"** in the
combinatorial model used in `Skeleton.lean` / `CliqueFace.lean`.

Recall the model:
* Vertices of `B_n` = permutations of `Fin n` (there are `n!` of them; these are the extreme
  points of the doubly stochastic matrices, Mathlib `extremePoints_doublyStochastic`).
* 1-skeleton (Brualdi–Gibson): `σ ~ τ` iff `σ⁻¹ τ` is a single cycle.
* Face vertex sets (Billera–Sarangarajan): `S` is a face vertex set iff every permutation
  whose graph lies in the union of the graphs of `S` already belongs to `S`.

## 1. Small cases

### n = 1
* 1 vertex (`id`). Skeleton: no edges. Cliques: `∅, {id}`.
* `cellUnion {id} = {(0,0)}`; the only permutation supported there is `id`. Both cliques are
  face vertex sets. **Property holds.**

### n = 2
* 2 vertices: `id`, `(0 1)`. Their graphs `{(0,0),(1,1)}` and `{(0,1),(1,0)}` are **disjoint**.
* Skeleton = `K_2` (one edge, since `(0 1)` is a single cycle).
* Every subset is a face vertex set, because disjoint graphs force any permutation supported
  on `cellUnion S` to coincide with a member of `S`. **Property holds.**

### n = 3
* 6 vertices. Every non-identity element of `S_3` is a transposition or a 3-cycle — all single
  cycles — so the skeleton is the **complete graph `K_6`**: every subset is a clique.
* Counterexample clique: the three transpositions `(0 1), (0 2), (1 2)`.
  * support union (`cellUnion`):
    | from\to | 0 | 1 | 2 |
    |---|---|---|---|
    | 0 | • | • | • |
    | 1 | • | • | • |
    | 2 | • | • | • |

    All 9 cells are occupied (each diagonal cell `(i,i)` is fixed by one of the transpositions;
    each off-diagonal cell is realised by the transposition swapping those coordinates).
  * Hence **every** permutation of `Fin 3` is supported on the union; in particular the 3-cycle
    `(0 1 2)` is supported there but is **not** one of the three transpositions.
  * So this size-3 clique is not a face vertex set (its smallest enclosing face is the whole
    polytope, with all 6 vertices). **Property fails.**

## 2. The structural phase transition

Distinct permutations of `Fin n` have pairwise-disjoint graphs **iff** `n ≤ 2`:
* `n ≤ 2`: a permutation of a ≤2-element set fixing one point is the identity, so distinct
  permutations disagree everywhere (verified by `decide` in `disjointGraphs_fin`).
* `n ≥ 3`: the transpositions `(0 1)` and `(0 2)` both fix every coordinate `≥ 3` and agree
  there (e.g. both fix `1`? no — but both fix coordinate `j ≥ 3`), so their graphs share cells.
  More simply, `(0 1)` and `id` agree at coordinate `2`.

This disjointness is precisely what makes "support closure" collapse to "membership", which is
why the clique-face property is equivalent to `n ≤ 2`.

## 3. Counterexample hunt for `n ≥ 3`

The three-transposition clique generalises verbatim to every `n ≥ 3`: with points `0,1,2`,
the transpositions `(0 1),(0 2),(1 2)` (fixing all coordinates `≥ 3`) are pairwise adjacent
(their products are 3-cycles), their support union contains the 3-cycle `(0 1 2)`, and that
3-cycle is not among them. This is formalised as `not_cliqueFace_fin_of_three`.

## 4. Conclusion

Computation matches the conjecture exactly: the property holds for `n ∈ {1,2}` and fails for
every `n ≥ 3`. This is fully proved (0 `sorry`, axioms `propext/Classical.choice/Quot.sound`)
as `birkhoff_cliqueFace_iff`.
