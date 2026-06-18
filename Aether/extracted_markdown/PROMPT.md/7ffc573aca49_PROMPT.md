Produce a single self-contained Lean 4 file formalizing a minimal finite multigraph parity theorem for Eulerian trails, with no placeholders, no unrelated declarations, and no dependency on a general graph library beyond Mathlib basics.

Target file: `Catalog/Bridges/EulerianTrailParity.lean`

Required setup:
1. Define `Multigraph (nV nE : ℕ)` with `ends : Fin nE → Fin nV × Fin nV`.
2. Define `degree (G : Multigraph nV nE) (v : Fin nV) : ℕ` as the sum over edges of the two endpoint indicators, so loops contribute `2`.
3. Define `EulerianTrail (G : Multigraph nV nE)` with:
   - `walk : Fin (nE + 1) → Fin nV`
   - `edgeAt : Equiv.Perm (Fin nE)`
   - compatibility: for each `i : Fin nE`, if `e := edgeAt i`, then `G.ends e = (walk i, walk i.succ)` or `G.ends e = (walk i.succ, walk i)`.

Then prove the following concrete results, and stop there:
A. A degree/incidence identity for a fixed vertex `v`, expressing `degree G v` as the sum over steps of contributions from consecutive walk pairs. It is acceptable to phrase this directly as a rewritten finite sum over `Fin nE` using the permutation `edgeAt`.
B. `even_degree_of_internal`: if `v` is neither the start vertex `walk 0` nor the end vertex `walk (last)` then `Even (degree G v)`.
C. `odd_degree_mem_endpoints`: if `Odd (degree G v)` then `v = walk 0 ∨ v = walk (Fin.last nE)`.
D. `odd_degree_vertices_le_two`: the finite set `{v | Odd (degree G v)}` has cardinality at most `2`.

Implementation guidance:
- Keep the proof elementary and finite-combinatorial. Do not introduce unused abstractions.
- Use ordered endpoint pairs and explicit indicator sums; this matches the current partial skeleton.
- A good strategy is to define counts of appearances of `v` among walk positions and prove a telescoping/endpoint-correction identity: each internal occurrence contributes two incidences, while start/end contribute one each unless they coincide.
- If a fully general set-cardinality statement is cumbersome, define the odd-vertex finset explicitly and prove it is contained in `{start, finish}`; then derive cardinality ≤ 2.
- Prefer proving a containment theorem `odd_vertices ⊆ {start, finish}` and then deducing the cardinality bound.
- Avoid any theorem headers without proofs. If a helper lemma becomes awkward, simplify the statement rather than leaving gaps.
- Do not include entropy, coding, tropical, or neural-network material; those were irrelevant spillover.

Deliverable requirements:
- The file must compile with full proofs.
- Include brief module docs explaining the theorem.
- Name the main namespace something like `EulerianTrailParity`.
- Favor robustness over maximal generality.

If necessary, slightly simplify theorem statements to what is provable cleanly in Lean, but preserve the mathematical core: an Eulerian trail implies at most two odd-degree vertices.