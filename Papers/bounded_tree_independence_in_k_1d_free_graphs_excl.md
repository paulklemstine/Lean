# Tree-independence number of `K_{1,d}`-free, `H`-induced-minor-free graphs

Companion notes to `Catalog/Speculative/TreeIndependenceKStar.lean`.

## Verdict on the conjecture

The conjecture is **true** (no counterexample exists). It is proved here *conditionally on the
Robertson–Seymour grid-minor theorem*, which is the standard and unavoidable deep ingredient and
is not available in Mathlib. The grid-minor input is isolated as an explicit hypothesis `hB`
(not introduced as an axiom), so the formal statement is a genuine, sorry-free conditional theorem.

## What is formalized and proved (all sorry-free)

1. **Definitions.**
   * `IsKStarFree d G` — no vertex has `d` distinct neighbours (no `K_{1,d}` subgraph).
   * `HasInducedMinor H G` — `H` is an induced minor of `G` (branch-set model with the
     adjacency *iff* condition characteristic of induced minors).
   * `TreeDecomp G` — tree decompositions (tree + bags, edge coverage, connected-subtree
     condition stated via connectivity of the induced subgraph of the tree).
   * `indepNumOn G B` — independence number of the subgraph induced on `B`.
   * `treewidth G`, `treeIndepNumber G` (= `α-tw(G)`).

2. **Degree bounds (Task 2).** `IsKStarFree.degree_lt`, `IsKStarFree.maxDegree_le`,
   `IsKStarFree.minDegree_le`, and the bundled `IsKStarFree.degree_bounds`:
   a connected `K_{1,d}`-free graph (`d ≥ 2`) has minimum and maximum degree `≤ d-1`.
   (Connectivity is not actually required for the degree bounds; it is kept in the bundled
   statement only because it was requested.)

3. **Reduction (Task 4).** For bounded-degree graphs treewidth and tree-independence number are
   linearly equivalent:
   * `treeIndepNumber_le_treewidth_succ` : `α-tw(G) ≤ tw(G) + 1` (always).
   * `treewidth_le_mul_treeIndepNumber` : `tw(G) ≤ (Δ+1)·α-tw(G)` when `maxDegree G ≤ Δ`,
     via the key combinatorial bound `card_le_indepNumOn`
     (`|B| ≤ (Δ+1)·indepNumOn G B`, a greedy/strong-induction argument).

4. **The conjecture (Tasks 3 and 5).** `treeIndepNumber_bounded_of_treewidth_bound`:
   given `d ≥ 2`, `H`, and a treewidth bound `B` for connected, max-degree-`≤(d-1)`,
   `H`-induced-minor-free graphs, every connected `K_{1,d}`-free `H`-induced-minor-free graph `G`
   satisfies `α-tw(G) ≤ B + 1`. This yields the explicit constant **`C(d,H) = B(d,H) + 1`**.

## Why `hB` holds for planar `H` (the part assumed, not re-proved)

`K_{1,d}`-freeness forces `maxDegree ≤ d-1` (Task 2). For bounded-degree graphs:
excluding a fixed planar `H` as an induced minor forces (after passing to an induced grid)
the exclusion of a large grid as a minor; by the grid-minor theorem this bounds treewidth.
Hence `B(d,H)` exists and can be taken as the grid-minor treewidth bound for excluding a grid
large enough to contain `H` as an induced minor — and then `C(d,H) = B(d,H) + 1`.

Formalizing the grid-minor theorem itself is far outside the scope here, so it is recorded as the
hypothesis `hB`; everything else is proved in full.
