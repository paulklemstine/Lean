Formalize a clean and self-contained Lean 4 file about the Laplacian quadratic form and Dirichlet energy of a finite simple graph, using Mathlib’s existing `SimpleGraph.lapMatrix` infrastructure rather than a custom Laplacian definition.

Requirements:
1. Start from `G : SimpleGraph V` on a finite vertex type `[Fintype V] [DecidableEq V] [DecidableRel G.Adj]`.
2. Define only the combinatorial Dirichlet energy over `G.edgeFinset` for `f : V → ℝ`:
   `dirichletEnergy G f := ∑ e ∈ G.edgeFinset, Sym2.lift ⟨fun i j => (f i - f j)^2, ...⟩ e`
   and keep this definition simple and well-scoped.
3. Do NOT define a custom Laplacian matrix unless absolutely necessary. Prefer `G.lapMatrix ℝ` everywhere.
4. Prove a small complete package of theorems, with exact statements chosen to match available Mathlib lemmas as closely as possible:
   a. A quadratic-form identity expressing `∑ i, ∑ j, f i * (G.lapMatrix ℝ i j) * f j` as the ordered adjacency sum with factor `1/2`.
   b. A theorem converting that ordered sum into the unordered edge sum `dirichletEnergy G f`.
   c. Deduce `0 ≤ ∑ i, ∑ j, f i * (G.lapMatrix ℝ i j) * f j` and `0 ≤ dirichletEnergy G f`.
   d. Prove monotonicity under edge addition in the form: if `G ≤ G'`, then `dirichletEnergy G f ≤ dirichletEnergy G' f` for every `f`. Use a spanning-subgraph relation, not an ad hoc “add one edge” statement unless it is genuinely easier after the general theorem.
   e. If feasible, prove that constant functions have zero Dirichlet energy, and that zero Dirichlet energy implies `(f u = f v)` for every edge `u ~ v`.
5. Keep the file focused. Remove all unrelated fragments from the previous attempt.
6. Prefer concise proofs by invoking existing lemmas about `SimpleGraph.lapMatrix`, edge sums, and nonnegativity of sums of squares. Avoid leaving theorem headers without proofs.
7. If the exact edgeFinset identity is awkward, it is acceptable to first prove the ordered-pair formula and then separately prove the equivalence with the edgeFinset Dirichlet energy using a counting/double-counting lemma.

Deliverable expectations:
- One coherent Lean file only.
- No placeholders, no truncated declarations, no unrelated experiments.
- Include short module docstrings explaining the main definitions and theorems.

If some ambitious endpoint (such as a full nullspace = constant-on-components theorem) becomes too expensive, stop after the complete core package above rather than adding incomplete stubs.