# Computational Evidence

The formalization targets the *vertex splitting* operation studied in
"Hardness of Vertex Splitting: Cographs, Chordal Graphs, and Beyond".
Below is the small-case evidence that guided the statements we proved.

## 1. The universal "split into a perfect matching" construction

Splitting every vertex `v` into `deg(v)` copies, one per incident edge, turns any graph `G`
without isolated vertices into a disjoint union of `|E|` edges (a perfect matching on the
`2|E|` darts of `G`).  The number of splits used is `2|E| - |V|`.

| graph        | n = \|V\| | m = \|E\| | darts 2m | splits 2m − n |
|--------------|----------|----------|----------|----------------|
| `K_3`        | 3        | 3        | 6        | 3              |
| `P_4`        | 4        | 3        | 6        | 2              |
| `C_4`        | 4        | 4        | 8        | 4              |
| `K_4`        | 4        | 6        | 12       | 8              |
| `Petersen`   | 10       | 15       | 30       | 20             |
| `K_{3,3}`    | 6        | 9        | 18       | 12             |

A disjoint union of edges has maximum degree 1, hence contains no induced `P_3`; therefore it
is simultaneously a cograph, `P_t`-free for every `t ≥ 3`, chordal, and a unit interval graph
(place the two darts of the `i`-th edge at `3i` and `3i+1` on the real line).  All of these
statements are proved in `Catalog/Bridges/VertexSplitting.lean`.

## 2. Counterexample hunt: is the bound `2|E| − |V|` ever beatable for matching targets?

No.  A double-counting argument (formalized as
`two_mul_card_edgeFinset_le_of_split_matching`) shows that any splitting whose result has
maximum degree at most one has at least `2|E|` vertices, because splitting never decreases the
number of edges and a maximum-degree-1 graph on `N` vertices has at most `N/2` edges.  So on
the table above the "splits" column is exactly optimal for matching targets.  (For the target
classes themselves — cographs, chordal graphs, unit interval graphs — the bound is only an
upper bound: e.g. `K_3` and `C_4` need `0` and `1` splits respectively, far fewer.)

## 3. Non-vacuity checks (machine-checked with `decide`)

* `not_isCograph_pathP4` : the path `P_4` on `Fin 4` really contains an induced `P_4`, so the
  predicate `IsCograph` is not vacuously true.
* `not_isChordal_cycleC4` : the cycle `C_4` on `ZMod 4` really contains an induced cycle of
  length ≥ 4, so `IsChordal` is not vacuously true.

Both are verified in Lean by `decide` on the explicit finite graphs.

## 3b. Further machine-checked checks (added in the follow-up pass)

* `hasInducedClaw_starK13` : the star `K_{1,3}` on `Fin 4` contains an induced claw (`decide`),
  hence (via the proved claw-freeness of unit interval graphs) it is not a unit interval graph
  and needs at least one split to become one (`card_lt_of_split_unitInterval_starK13`).
* The step count of the shallow factorization: a splitting map `f : W → V` is decomposed into
  exactly `|W| − |V|` single splits by `SplitChain.of_isSplit`, matching the table above
  (e.g. `K_4`: `12 − 4 = 8` single splits to reach the perfect matching on its darts).

## 4. Sequences

No new integer sequence arises; the split counts are the classical quantity
`2m − n = Σ_v (deg(v) − 1)`, i.e. the number of "extra" darts, and no OEIS lookup was needed.

## 3c. Exact small-case splitting numbers (added in the completion pass)

All entries below are machine-checked in `Catalog/Bridges/VertexSplittingExact.lean`; the
membership statements about the finite witness graphs are discharged by `decide` and the unit
interval representations by explicit rational placements.

| graph `G` | target class | splits needed | witness |
|---|---|---|---|
| `P₄` | cograph | 1 | `splitP4` (an edge plus a `P₃`) |
| `C₄` | chordal | 1 | `pathP5` (unfold the cycle) |
| `K_{1,3}` | unit interval | 1 | `splitK13` (`P₃` plus an edge) |
| `K_{1,4}` | unit interval | 1 | `splitK14` (two `P₃`s) |
| `K_{1,n}`, `n ≥ 1` | unit interval | `⌈n/2⌉ − 1` | `starSplitGraph n ⌈n/2⌉` |

Each witness split is exclusive.  The last row refutes the earlier guess `n − 2`: pairing the
leaves two by two is optimal, and the matching lower bound is the counting argument
`card_ge_of_split_clawFree_star` (a claw-free graph lets each copy of the centre keep at most two
leaves).

Unit interval representations used (positions on the real line):
`splitK13`: `1 ↦ 0, 0 ↦ 1, 2 ↦ 2, 4 ↦ 10, 3 ↦ 11`;
`splitK14`: `1 ↦ 0, 0 ↦ 1, 2 ↦ 2, 3 ↦ 10, 5 ↦ 11, 4 ↦ 12`;
`starSplitGraph n m`: leaf `i ↦ 2i`, centre copy `j ↦ 4j + 1`.
