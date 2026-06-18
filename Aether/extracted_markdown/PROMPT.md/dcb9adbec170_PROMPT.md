Complete the partially formalized Eulerian-trail parity theorem by turning it into a minimal, self-contained Lean 4 development with no `sorry`s.

Work in a new file for a finite multigraph model where:
- `Multigraph nV nE` stores `ends : Fin nE → Fin nV × Fin nV`
- `degree G v` is the sum over all edges of the two endpoint indicators, so loops contribute `2`
- `EulerianTrail G` consists of:
  - `walk : Fin (nE+1) → Fin nV`
  - `edgeAt : Fin nE → Fin nE`
  - `edge_perm : Function.Bijective edgeAt` (or equivalently a permutation structure if more convenient)
  - a compatibility condition saying the edge `edgeAt i` connects `walk i` and `walk i.succ` in either orientation

Your goal is not to generalize broadly, but to finish the concrete parity theorem cleanly.

Target theorem hierarchy:
1. Prove the needed finite-sum helper lemmas over `Fin` that let you rewrite sums over `Fin (n+1)` into head/tail or cast/succ decompositions.
2. Prove a usable formula for `degree G v` in terms of how many times `v` appears along the trail, with endpoint correction. A direct identity of the form
   `degree G v = ind (walk 0 = v) + ind (walk (last) = v) + 2 * k`
   for some natural `k` is ideal; alternatively prove the parity consequence directly.
3. Prove that every vertex distinct from both trail endpoints has even degree.
4. Prove that if `degree G v` is odd, then `v` equals the start or end vertex of the trail.
5. Conclude that the finset/set of odd-degree vertices has cardinality at most `2`.

Important guidance:
- Follow the existing proof strategy: this is a finite counting/parity proof over trail indices, not a high-level graph library development.
- Prefer simple `Finset.univ` sums and explicit indicator lemmas.
- Keep the multigraph definition ordered-endpoint based; loops and parallel edges are allowed.
- If the original skeleton had unfinished lemmas like `sum_castSucc_eq`, `sum_succ_eq`, `degree_eq_sum`, `degree_visit_identity`, `even_degree_of_internal`, `odd_degree_mem_endpoints`, `odd_degree_vertices_le_two`, either complete them or replace them with cleaner equivalent lemmas that support the same final theorem.
- Avoid introducing speculative material about neural networks, tropical geometry, or Diophantine approximation; the real task is the bridge theorem on Eulerian trails.
- The final file must compile against Mathlib with no placeholders.

If one exact formulation becomes awkward, prefer a slightly simpler but fully proved theorem, such as: for any Eulerian trail, every odd-degree vertex belongs to the two-element set consisting of the trail start and trail end. Then derive the cardinality bound from that inclusion.

Produce only the Lean code content for the completed file.