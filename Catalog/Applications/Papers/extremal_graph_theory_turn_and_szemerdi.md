# Computational Evidence — Kruskal–Katona graph bridge & triangle removal

Concise evidence for the two claims formalized this cycle.

## 1. Bridge: "many triangles ⇒ many edges" (`card_edgeFinset_ge_of_triangles`)

Claim: a graph on `Fin n` with `≥ C(k,3)` triangles has `≥ C(k,2)` edges (for `3 ≤ k ≤ n`).

The extremal witness is the complete graph `K_k`, which has **exactly** `C(k,3)` triangles and
`C(k,2)` edges, so the bound is tight. Table of `(k, C(k,3), C(k,2))` computed in Lean
(`#eval (List.range 9).map (fun k => (k, k.choose 3, k.choose 2))`):

| k | triangles C(k,3) | edges C(k,2) |
|---|------------------|--------------|
| 2 | 0  | 1  |
| 3 | 1  | 3  |
| 4 | 4  | 6  |
| 5 | 10 | 10 |
| 6 | 20 | 15 |
| 7 | 35 | 21 |
| 8 | 56 | 28 |

Sanity checks of the *threshold logic* (the contrapositive: few edges ⇒ few triangles):
- A graph with `< C(k,2)` edges has `< C(k,3)` triangles. E.g. with `4` triangles one needs
  `≥ C(4,2)=6` edges; indeed `K_4` (the only graph with exactly `4` triangles up to isolated
  vertices) has `6` edges.
- The shadow inclusion `∂(triangles) ⊆ edges` is checked structurally (deleting any vertex of a
  triangle yields an edge), so the inequality is not merely numerical: it is a genuine set
  inclusion, then quantified by Kruskal–Katona.

Counterexample hunt: none expected, and none found — Kruskal–Katona is a theorem and the witness
`K_k` matches both binomials simultaneously (row `k=5`: `10 = 10`), confirming tightness rather
than slack.

## 2. Triangle removal dichotomy (`triangle_count_dichotomy`)

Claim: for any `ε`, every finite graph either has `≥ triangleRemovalBound ε · n³` triangles, or can
be made triangle-free by deleting `< ε · n²` edges.

`triangleRemovalBound ε > 0` for `ε > 0` (`triangleRemovalBound_pos`), so the threshold is a
genuine positive cubic. The dichotomy is exhaustive by construction (`by_cases` on the threshold),
so no counterexample is possible; the content is that the "few triangles" branch yields an explicit
sparse triangle-free subgraph via `triangle_removal`.

## Why no heavier computation

The two results are sharp consequences of theorems already in Mathlib (`kruskal_katona_lovasz_form`,
`triangle_removal`); the decisive content is the *structural* shadow inclusion and the *cast-aligned*
contradiction, both of which are verified by the Lean proofs themselves rather than by enumeration.
Small-case binomial data above suffices to confirm tightness of the bridge.
