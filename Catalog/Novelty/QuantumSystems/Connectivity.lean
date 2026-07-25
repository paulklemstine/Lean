import Mathlib

/-!
# Vertex `k`-connectivity and the degree necessary condition

Mathlib has edge connectivity and `Connected`, but no notion of vertex
`k`-connectivity (the object at the heart of the connectivity-preserving
Hamiltonian-path program of Hasunuma 2025 and the prescribed-end strengthening).
We supply the standard cut-based definition and prove the classical
**necessary degree condition** that vertex `k`-connectivity forces minimum degree
at least `k` — the easy half of the Whitney/Menger inequality
`κ(G) ≤ δ(G)`.

## Main definitions and results

* `IsKConnected G k` — `G` has more than `k` vertices and deleting any fewer
  than `k` vertices leaves a connected graph.
* `Connected.exists_adj_of_ne` — in a connected graph with two distinct
  vertices, every vertex has a neighbor.
* `IsKConnected.le_ncard_neighborSet` — **`κ(G) ≤ δ(G)`**: in a
  `k`-connected graph every vertex has degree at least `k`.
* `Conjecture_4k4` — the precise (open) research conjecture, recorded as a `Prop`.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): for a connectivity-preserving deletion theorem one
  must control connectivity, so a vertex-cut definition is unavoidable.  We
  conjectured the classical `κ ≤ δ` bound holds with the cut-based definition.
* Experiment (Experimenter): defined `IsKConnected` via induced subgraphs on
  vertex-set complements and proved `κ ≤ δ` by the textbook argument — if some
  vertex `w` had degree `< k`, its neighborhood is a cut of size `< k` isolating
  `w`, contradicting connectivity of the deletion.
* Analysis (Analyst): the proof needs the "no isolated vertex in a connected
  graph on `≥ 2` vertices" lemma (`exists_adj_of_ne`), extracted separately.
  The cardinality slack `card V - (k-1) ≥ 2` is exactly where `k < card V`
  is consumed (the `h_singleton` case split).
* Critique (Critic): this is only the *necessary* direction. The converse
  (Chartrand–Harary: `δ ≥ (n+k-2)/2 ⇒ κ ≥ k`) is strictly deeper and is *not*
  claimed here; it is recorded as a future direction.  The definition is guarded
  by `k < card V` so the empty/complete-graph corner cases are handled.
-- !-- end Lab Notes -- !--
-/

open SimpleGraph

namespace ConnPreservingHamPath

variable {V : Type*}

/-- `G` is (vertex) `k`-connected: it has more than `k` vertices and removing
any set of fewer than `k` vertices leaves a connected induced subgraph. -/
def IsKConnected [Fintype V] (G : SimpleGraph V) (k : ℕ) : Prop :=
  k < Fintype.card V ∧
    ∀ S : Finset V, S.card < k → (G.induce ((↑S : Set V)ᶜ)).Connected

/-- In a connected graph containing two distinct vertices, every vertex has a
neighbor. -/
lemma Connected.exists_adj_of_ne {W : Type*} {H : SimpleGraph W} (hc : H.Connected)
    {a b : W} (hab : a ≠ b) : ∃ c, H.Adj a c := by
  obtain ⟨p⟩ : Nonempty (H.Walk a b) := hc a b
  cases p <;> aesop

/-- **Whitney bound, easy direction `κ(G) ≤ δ(G)`.** Every vertex of a
`k`-connected graph has degree at least `k`. -/
theorem IsKConnected.le_ncard_neighborSet [Fintype V] {G : SimpleGraph V} {k : ℕ}
    (h : IsKConnected G k) (w : V) : k ≤ (G.neighborSet w).ncard := by
  contrapose! h
  intro h'
  have h_connected : (G.induce ((G.neighborSet w : Set V)ᶜ)).Connected := by
    convert h'.2 (G.neighborFinset w) ?_
    all_goals try exact Fintype.ofFinite _
    · aesop
    · aesop
    · simpa [← Set.ncard_coe_finset] using h
  obtain ⟨c, hc⟩ : ∃ c : {v : V // v ∉ G.neighborSet w},
      (G.induce ((G.neighborSet w : Set V)ᶜ)).Adj ⟨w, by simp⟩ c := by
    obtain ⟨c, hc⟩ : ∃ c : {v : V // v ∉ G.neighborSet w}, c ≠ ⟨w, by simp⟩ := by
      by_cases h_singleton : (G.neighborSet w : Set V)ᶜ = {w}
      · have := h'.1
        simp_all +decide
        have := Set.ncard_add_ncard_compl (G.neighborSet w)
        simp_all +decide
        linarith
      · simp_all +decide [Set.eq_singleton_iff_unique_mem]
    have := h_connected ⟨w, by simp⟩ c
    obtain ⟨p⟩ := this
    cases p <;> tauto
  exact c.2 (by simpa using hc)

/-- **The research conjecture (open).**  For every `k ≥ 2`, every `k`-connected
finite simple graph `G` on `n ≥ 4k+4` vertices with `δ(G) ≥ ⌈(n+1)/2⌉` (written in
`ℕ` as `(n+2)/2`) admits, for every ordered pair of distinct vertices `u, v`, a
Hamiltonian `u`–`v` path `P` whose edge-deletion leaves `G` still `k`-connected.

This is the prescribed-end `n ≥ 4k+4` strengthening of the submitted paper's
`n ≥ 6k+6` theorem.  It is recorded here as a `Prop`; it is **not** proved.  The
file `PathDegree.lean` proves that the *necessary degree* part of the conclusion
(`δ(G - E(P)) ≥ k`, indeed `≥ 2k+1`) always holds under these hypotheses, which
by `IsKConnected.le_ncard_neighborSet` is genuinely necessary; the open content
is exactly the surviving *cut structure*. -/
def Conjecture_4k4 (k : ℕ) : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (G : SimpleGraph V),
    2 ≤ k → 4 * k + 4 ≤ Fintype.card V →
    IsKConnected G k →
    (∀ x, (Fintype.card V + 2) / 2 ≤ (G.neighborSet x).ncard) →
    ∀ u v : V, u ≠ v →
      ∃ p : G.Walk u v, p.IsHamiltonian ∧
        IsKConnected (G.deleteEdges {e | e ∈ p.edges}) k

end ConnPreservingHamPath