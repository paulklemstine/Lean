# Global Label Min-Cut (GLMC): formalization status and analysis

This note accompanies `Speculative/GLMC.lean`.

## What was formalized and proved (no `sorry`, standard axioms only)

A faithful combinatorial model of the GLMC problem and its true core theory:

- `cutLabels` / `cutValue` — the labels crossing a cut `(A, Aᶜ)` and their count.
- `properCuts` — the nontrivial partitions (both sides nonempty).
- `glmcOpt` — the minimum number of distinct crossing labels over all proper
  cuts (a finite computation = an explicit exponential-time brute-force solver).
- `cutValue_le_numLabels`, `glmcOpt_le_numLabels` — the objective is `≤ p = |L|`.
- `properCuts_nonempty`, `mem_properCuts` — basic structure of proper cuts.
- `glmcOpt_le_of_proper` + `glmcOpt_attained` — **correctness**: `glmcOpt` is the
  genuine minimum and is attained by an optimal proper cut.
- `glmcOpt_eq_zero_of_separated` — a disconnecting cut forces optimum `0`.

## Why the runtime conjecture was *not* proved

The conjectured `2^{O(g)}·n^{O(1)}·p^{O(1)}` algorithm via the grid-minor /
tree-decomposition route cannot be established as stated:

1. **Missing foundations.** The Mathlib used here contains no treewidth, tree
   decompositions, graph-minor relation, grid-minor theorem, or genus /
   surface-embedding theory. The cited "recent advances ... in Mathlib" do not
   exist, so steps (1)–(3) have nothing to build on.

2. **Internal inconsistency.** The proposed strategy yields, at best,
   `2^{O(√(g·n))}·p^{O(√(g·n))}·n^{O(1)}` — *quasi-polynomial* in `n` for fixed
   `g`. This does not match the conjectured bound, which is *polynomial* in `n`
   for fixed `g`. The request's own step (3) derives only the weaker bound.

3. **Incorrect treewidth bound.** A genus-`g` graph on `n` vertices has treewidth
   `O(√((g+1)·n))`, not `O(√(g·n))`. The `+1` is essential: at `g = 0` the
   stated bound gives `0`, but the planar `√n × √n` grid has treewidth `Θ(√n)`.

4. **Plausibility caution.** Minimum-label cut problems are generally NP-hard.
   If GLMC is NP-hard on planar graphs, a poly`(n, p)` algorithm for fixed `g`
   (the conjecture at `g = 0`) would imply `P = NP`. (Caution, not a proof.)

The verified content above is the rigorous, foundation-independent core of the
problem: the objective is well-defined, bounded by `p`, and exactly computed by
exhaustive search.
