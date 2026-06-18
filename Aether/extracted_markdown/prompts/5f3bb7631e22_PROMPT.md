Formalize a single coherent theorem package in Lean 4, with no sorries and no placeholder declarations, entirely within the existing `Bridges.Multigraph` framework. Do not mix this with the previous Rips/tropical threshold idea, and do not introduce an `EulerianTrail` structure unless it becomes absolutely necessary; the goal of this cycle is to complete a smaller prerequisite that is mathematically meaningful and realistically finishable.

Target problem:
1. In `Bridges.Multigraph`, define the degree of a vertex as the number of incidences of edges to that vertex, counting a loop twice if the multigraph representation permits loops. If the current `Multigraph` file already has endpoint fields `endpt₁` and `endpt₂`, use those directly and define degree by summing edge incidences over `Fin nE`.
2. Define the finite set of odd-degree vertices.
3. Prove the handshake-sum identity: the sum of all vertex degrees equals twice the number of edges.
4. Deduce the parity theorem: the number of odd-degree vertices is even.
5. If convenient, add a corollary tailored for future Eulerian work, e.g. that a graph cannot have exactly one odd-degree vertex, and that if the odd-degree set has cardinality 2 then those two vertices are precisely the odd vertices.

Proof strategy:
- Work directly with finite sums over `Fin nE` and `Fin nV`.
- First prove a local incidence-count lemma for a fixed edge: its contribution to the total degree sum is 2 (or still 2 in the loop case, if loops are counted twice).
- Then sum over all edges to obtain the handshake identity.
- Use a standard finite parity argument to show the odd-degree vertex count is even.
- Keep all definitions executable and finitary; avoid abstract graph classes unless they are already in the catalog.

Implementation constraints:
- The final file must compile with only Mathlib and the relevant Bridges imports.
- No truncated statements, no `admit`, no `sorry`, no unfinished helper lemmas.
- The theorem names and module docstring must match the actual content.
- Prefer a new file name reflecting the real result, such as `Catalog/Bridges/MultigraphHandshake.lean` or similar.

Why this direction now:
The previous attempt failed because it combined two unrelated programs and got stuck on a large custom walk formalization. The key insight is that the odd-degree parity theorem is the minimal nontrivial finite graph invariant needed before any Eulerian-trail theorem, and it can be proved entirely from the already-available endpoint data of `Multigraph` without developing trail combinatorics. Completing this gives a verified foundation for a later, better-scoped Eulerian existence or parity project.

Expected output:
- One Lean file containing definitions, the handshake lemma, and the odd-degree parity theorem.
- Short module documentation explaining the result and its future use for Eulerian graph theory.