/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Path-Minimality of the Squared Adjacency Energy for Connected Graphs

The companion files study the positive p-energy of the *closed-form* path spectrum
`pathEig n k = 2 cos((k+1)π/(n+1))`.  Here we work with the **genuine adjacency spectrum** of a
finite simple graph `G`: the eigenvalues `hA.eigenvalues` of the (real, Hermitian) adjacency
matrix `A = adjMatrix ℝ G`.

The key spectral–combinatorial identity is that the **squared spectral energy** equals twice the
number of edges:
`∑_i λ_i(G)² = trace(A²) = ∑_v deg(v) = 2 |E(G)|`.
Combined with the elementary tree bound `|E(G)| ≥ n - 1` for connected `G`
(`connected_card_edgeFinset_ge`, companion file), this yields **path-minimality of the squared
adjacency energy**: every connected graph on `n` vertices has squared spectral energy at least
`2(n-1)`, which is exactly the squared spectral energy of the path `P_n`
(`sum_pathEig_sq`, companion file).

## Main statements
* `sum_eigenvalues_sq_eq_two_card_edges` — `∑_i λ_i(G)² = 2 |E(G)|` for any finite simple graph.
* `connected_squaredEnergy_ge_path` — for connected `G` on `n = |V|` vertices,
  `∑_k pathEig n k ² ≤ ∑_i λ_i(G)²`; the path minimises the squared adjacency energy.

For a **bipartite** `G` the spectrum is symmetric about `0`, so
`∑_i λ_i² = 2 ∑_{λ>0} λ²` and this becomes exactly `E_2^+(G) ≥ E_2^+(P_n)` — the requested
positive-2-energy path-minimality (see `absEnergy_eq_two_posEnergy_of_antisymm`).

-- !-- Lab Notes -- !--
Cycle 4 Hypothesis (Hypothesizer): the `p = 2` energy statements proved so far only touch the
*closed-form* path spectrum; the real content is a statement about the honest adjacency eigenvalues
of an arbitrary graph.  Conjecture: for any simple graph `∑ λ_i² = 2|E|`, hence connectivity forces
`∑ λ_i² ≥ 2(n-1)`, tight at the path.
Experiment (Experimenter): reduced `∑ λ_i²` to `trace(A²)` via the spectral theorem (unitary
conjugation preserves the trace and squares the diagonal), then `trace(A²) = ∑_v deg v` through
`adjMatrix_mul_self_apply_self`, and `∑_v deg v = 2|E|` through `sum_degrees_eq_twice_card_edges`.
The path bound follows from `sum_pathEig_sq` and `connected_card_edgeFinset_ge`.
Analysis (Analyst): this upgrades the earlier "path spectrum" computation to a theorem about real
graph spectra, and identifies `∑λ² = 2|E|` as the exact bridge between spectral and combinatorial
energy.  For bipartite graphs the Schatten identity (companion file) halves it to positive energy.
Critique (Critic): not vacuous — connectivity is essential (the empty graph on `n ≥ 2` vertices has
`∑λ² = 0 < 2(n-1)`), and `∑λ² = 2|E|` uses genuine spectral theory, not a definitional rewrite.
Synthesis (PI): squared adjacency energy IS twice the edge count; path-minimality at `p = 2` is the
spanning-tree bound transported through the spectral theorem.
-/
import Mathlib
import Catalog.Probability.PositivePEnergyPathMinimal

open scoped Matrix
open Matrix Finset

namespace PositivePEnergy

variable {V : Type*} [Fintype V] [DecidableEq V]

omit [Fintype V] [DecidableEq V] in
/-- The real adjacency matrix of a simple graph is Hermitian (it is symmetric). -/
lemma adjMatrix_isHermitian (G : SimpleGraph V) [DecidableRel G.Adj] :
    (G.adjMatrix ℝ).IsHermitian := by
  unfold Matrix.IsHermitian
  ext i j
  simp [Matrix.conjTranspose, SimpleGraph.adjMatrix_apply]

omit [DecidableEq V] in
/-- `trace(A²) = 2 |E(G)|`: the trace of the square of the adjacency matrix counts each edge twice
(it equals the sum of the vertex degrees). -/
lemma trace_adjMatrix_sq_eq (G : SimpleGraph V) [DecidableRel G.Adj] :
    (G.adjMatrix ℝ * G.adjMatrix ℝ).trace = 2 * (G.edgeFinset.card : ℝ) := by
  rw [Matrix.trace]
  simp only [Matrix.diag_apply, SimpleGraph.adjMatrix_mul_self_apply_self]
  rw [← Nat.cast_sum, G.sum_degrees_eq_twice_card_edges]
  push_cast
  ring

/-
**Spectral identity for the squared energy.**  The sum of the squares of the adjacency
eigenvalues equals `trace(A²)`.  (Spectral theorem: unitary conjugation preserves the trace and
squares the eigenvalues.)
-/
lemma sum_eigenvalues_sq_eq_trace_sq (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ i, (adjMatrix_isHermitian G).eigenvalues i ^ 2
      = (G.adjMatrix ℝ * G.adjMatrix ℝ).trace := by
  have := Matrix.IsHermitian.spectral_theorem (adjMatrix_isHermitian G)
  conv_rhs => rw [this, ← Matrix.diagonal_transpose]
  simp [Matrix.trace_mul_comm, Matrix.mul_assoc, Matrix.diagonal_mul_diagonal, sq]

/-- **Squared adjacency energy equals twice the edge count.**  For any finite simple graph,
`∑_i λ_i(G)² = 2 |E(G)|`. -/
theorem sum_eigenvalues_sq_eq_two_card_edges (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ i, (adjMatrix_isHermitian G).eigenvalues i ^ 2 = 2 * (G.edgeFinset.card : ℝ) := by
  rw [sum_eigenvalues_sq_eq_trace_sq G, trace_adjMatrix_sq_eq G]

/-- **Path-minimality of the squared adjacency energy.**  For a connected simple graph `G` on
`n = |V| ≥ 1` vertices, the squared adjacency energy is at least that of the path `P_n`:
`∑_k pathEig n k ² ≤ ∑_i λ_i(G)²`. -/
theorem connected_squaredEnergy_ge_path (G : SimpleGraph V) [DecidableRel G.Adj]
    (h : G.Connected) (hn : 1 ≤ Fintype.card V) :
    ∑ k ∈ Finset.range (Fintype.card V), (pathEig (Fintype.card V) k) ^ 2
      ≤ ∑ i, (adjMatrix_isHermitian G).eigenvalues i ^ 2 := by
  rw [sum_pathEig_sq _ hn, sum_eigenvalues_sq_eq_two_card_edges G]
  have hedges := connected_card_edgeFinset_ge G h
  have : (Fintype.card V : ℝ) ≤ (G.edgeFinset.card : ℝ) + 1 := by exact_mod_cast hedges
  linarith

end PositivePEnergy