import Mathlib
import Catalog.Algebra.ErdosRenyi.Cliques

/-! # Turán's theorem, Mantel's theorem, and a first-moment bridge

This file develops clean, ready-to-use consequences of **Turán's theorem**
(`SimpleGraph.CliqueFree.card_edgeFinset_le` and the edge count of the Turán
graph in Mathlib) for extremal graph theory:

* `turan_edge_bound`: every `K_{r+1}`-free graph satisfies the closed-form
  bound `2 r · e(G) ≤ (r-1) · n²`, i.e. `e(G) ≤ (1 - 1/r) · n²/2`.
* `mantel`: **Mantel's theorem**, the `r = 2` special case: a triangle-free
  graph on `n` vertices has at most `n²/4` edges (`4 e(G) ≤ n²`).
* `mantel_sharp`: the Mantel bound is *attained* — for every `k`, the Turán
  graph `turanGraph (2k) 2` is triangle-free and satisfies `4 e = n²` exactly.
* `complete_graph_expected_clique_count` / `mantel_extremal_kills_triangles`:
  a bridge to the catalog's Erdős–Rényi first-moment development
  (`Algebra/ErdosRenyi/Cliques.lean`), contrasting the `C(n,3)` *potential*
  triangles of the complete graph with the `0` triangles of the extremal graph.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Mathlib states Turán's theorem only via the exact
  arithmetic formula `(n² - (n%r)²)(r-1)/(2r) + C(n%r,2)`, which is awkward to
  apply. We conjecture the clean dimensionless form `2 r·e ≤ (r-1) n²` is a
  direct corollary, and that its `r = 2` instance recovers Mantel's `e ≤ n²/4`
  with sharpness witnessed by a balanced complete bipartite graph.
Experiment (Experimenter): We combined `CliqueFree.card_edgeFinset_le` (edges of
  a clique-free graph are bounded by the exact Turán formula) with
  `mul_card_edgeFinset_turanGraph_le` (the simple `(r-1)n²` bound on the Turán
  graph) by `Nat.mul_le_mul_left`. For sharpness we evaluated
  `card_edgeFinset_turanGraph` at `n = 2k`, `r = 2`, where `n % 2 = 0` collapses
  the formula to `n²/4`.
Analysis (Analyst): The bound is "true and clean"; the only subtlety is `ℕ`
  truncating division, handled by multiplying through by `2r`. Sharpness shows
  the inequality is best possible, so no constant can be improved.
Critique (Critic): `mantel` is not vacuous (triangle-free graphs are abundant)
  and not `simp`-only (it uses the structural Turán bound). `mantel_sharp`
  guarantees the constant `1/4` cannot be lowered. The bridge theorem genuinely
  invokes the catalog's `ErdosRenyiClique.expected_cliques`.
Synthesis (PI): Turán ⇒ Mantel ⇒ sharpness ⇒ contrast with random model.
-/

open SimpleGraph Finset

variable {V : Type*} [Fintype V] {G : SimpleGraph V} [DecidableRel G.Adj] {r : ℕ}

/-- **Turán's theorem, clean form.** A `K_{r+1}`-free graph on `n` vertices has
`2 r · e(G) ≤ (r-1) · n²`, equivalently `e(G) ≤ (1 - 1/r) · n²/2`. -/
theorem turan_edge_bound (cf : G.CliqueFree (r + 1)) :
    2 * r * #G.edgeFinset ≤ (r - 1) * (Fintype.card V) ^ 2 := by
  have h1 := cf.card_edgeFinset_le
  simp only at h1
  have h2 := mul_card_edgeFinset_turanGraph_le (n := Fintype.card V) (r := r)
  rw [card_edgeFinset_turanGraph] at h2
  calc
    2 * r * #G.edgeFinset
        ≤ 2 * r * ((Fintype.card V ^ 2 - (Fintype.card V % r) ^ 2) * (r - 1) / (2 * r)
            + (Fintype.card V % r).choose 2) := Nat.mul_le_mul_left _ h1
    _ ≤ (r - 1) * (Fintype.card V) ^ 2 := h2

/-- **Mantel's theorem.** A triangle-free (`K_3`-free) graph on `n` vertices has
at most `n²/4` edges, in the integer form `4 · e(G) ≤ n²`. -/
theorem mantel (cf : G.CliqueFree 3) :
    4 * #G.edgeFinset ≤ (Fintype.card V) ^ 2 := by
  have := turan_edge_bound (r := 2) cf
  simpa using this

/-- **Sharpness of Mantel's theorem.** For every `k`, the balanced Turán graph
`turanGraph (2k) 2` (the complete bipartite graph `K_{k,k}`) is triangle-free and
attains equality `4 · e = (2k)²`, so the constant `1/4` cannot be improved. -/
theorem mantel_sharp (k : ℕ) :
    (turanGraph (2 * k) 2).CliqueFree 3 ∧
      4 * #(turanGraph (2 * k) 2).edgeFinset = (2 * k) ^ 2 := by
  refine ⟨turanGraph_cliqueFree (by norm_num), ?_⟩
  rw [card_edgeFinset_turanGraph]
  have h : (2 * k) % 2 = 0 := by omega
  rw [h]
  simp
  ring_nf
  omega

/-- **Bridge to the first-moment method (catalog `ErdosRenyiClique`).** In the
Erdős–Rényi development, the expected number of `K_r` cliques at full density
`p = 1` is exactly the number `C(n, r)` of vertex `r`-subsets. -/
theorem complete_graph_expected_clique_count (n r : ℕ) :
    ErdosRenyiClique.expectedCount (ErdosRenyiClique.edgeSet n)
        (Finset.univ.powersetCard r) ErdosRenyiClique.cliqueEdges 1
      = (n.choose r : ℝ) := by
  rw [ErdosRenyiClique.expected_cliques]
  simp

/-- **Extremal vs. random contrast.** The balanced Turán graph realizing Mantel's
bound is triangle-free, whereas the complete graph on the same vertex set has
`C(2k, 3)` *potential* triangles — the full-density first-moment count from the
catalog's Erdős–Rényi file. -/
theorem mantel_extremal_kills_triangles (k : ℕ) :
    (turanGraph (2 * k) 2).CliqueFree 3 ∧
      ErdosRenyiClique.expectedCount (ErdosRenyiClique.edgeSet (2 * k))
          (Finset.univ.powersetCard 3) ErdosRenyiClique.cliqueEdges 1
        = ((2 * k).choose 3 : ℝ) := by
  exact ⟨turanGraph_cliqueFree (by norm_num), complete_graph_expected_clique_count (2 * k) 3⟩