import Mathlib

/-!
# Erdős–Rényi Random Graphs: Definitions

This file introduces the core definitions for a formal theory of threshold phenomena
in Erdős–Rényi random graphs. We define graph-theoretic notions (isolated vertices,
giant components, subgraph counts, walks) in a way that is reusable for random
graph analysis, and introduce threshold window predicates for phase-transition reasoning.

## Main definitions

- `isolatedVertexCount` — number of degree-zero vertices
- `hasGiantComponent` — existence of a component of linear size
- `componentOf` — the connected component containing a vertex
- `SubgraphCount` — number of labeled injective embeddings of a pattern graph
- `walkCountInGraph` — number of walks of given length between vertex pairs
- `susceptibility` — the sum of squared component sizes, normalized by n
- `ThresholdWindow` — predicate for one-sided threshold behavior
- `MonotoneGraphProperty` — a graph property closed under edge addition
-/

open Finset BigOperators SimpleGraph

noncomputable section

/-! ## Isolated vertices -/

/-- The set of isolated (degree-zero) vertices in a simple graph on `Fin n`. -/
def isolatedVertexSet {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] : Finset (Fin n) :=
  Finset.univ.filter (fun v => ∀ w, ¬G.Adj v w)

/-- The number of isolated vertices in a simple graph on `Fin n`. -/
def isolatedVertexCount {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] : ℕ :=
  (isolatedVertexSet G).card

/-! ## Connected components and giant components -/

/-- The connected component of a vertex `v` in graph `G`, as a `Finset`. -/
def componentOf {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableEq (Fin n)]
    [DecidableRel G.Adj] (v : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun w => G.Reachable v w)

/-- The multiset of component sizes in a graph. -/
def componentOrderProfile {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableEq (Fin n)] [DecidableRel G.Adj] : Multiset ℕ :=
  (Finset.univ.image (fun v => (componentOf G v).card)).val

/-- A graph has a giant component of relative size at least `α` if some
connected component contains at least `⌈α * n⌉` vertices. -/
def hasGiantComponent {n : ℕ} (α : ℝ) (G : SimpleGraph (Fin n)) : Prop :=
  ∃ v : Fin n, ∃ S : Finset (Fin n),
    (∀ w ∈ S, G.Reachable v w) ∧ ⌈α * n⌉₊ ≤ S.card

/-- The largest component size in a finite graph. -/
def largestComponentSize {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableEq (Fin n)] [DecidableRel G.Adj] : ℕ :=
  Finset.univ.sup (fun v => (componentOf G v).card)

/-! ## Subgraph counts -/

/-- A labeled embedding of pattern `H` on `Fin m` into graph `G` on `Fin n` is
an injective function `φ : Fin m → Fin n` that maps edges to edges. -/
def IsLabeledEmbedding {m n : ℕ} (H : SimpleGraph (Fin m)) (G : SimpleGraph (Fin n))
    (φ : Fin m → Fin n) : Prop :=
  Function.Injective φ ∧ ∀ i j, H.Adj i j → G.Adj (φ i) (φ j)

/-- The number of labeled injective embeddings of pattern `H` into graph `G`. -/
def SubgraphCount {m n : ℕ} [DecidableEq (Fin n)]
    (H : SimpleGraph (Fin m)) [DecidableRel H.Adj]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] : ℕ :=
  (Finset.univ.filter (fun φ : Fin m → Fin n =>
    Function.Injective φ ∧ ∀ i j, H.Adj i j → G.Adj (φ i) (φ j))).card

/-! ## Walk counts -/

/-- Number of walks of length `L` from vertex `u` to vertex `v` in a graph,
defined via the adjacency matrix power. For our finite graph on `Fin n`,
this counts paths with possible revisits. -/
def walkCount {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (L : ℕ) (u v : Fin n) : ℕ :=
  ((Matrix.of (fun i j : Fin n => if G.Adj i j then (1 : ℕ) else 0)) ^ L) u v

/-- Total number of walks of length `L` in the graph. -/
def totalWalkCount {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (L : ℕ) : ℕ :=
  ∑ u : Fin n, ∑ v : Fin n, walkCount G L u v

/-! ## Susceptibility -/

/-- The susceptibility of a finite graph, defined as the sum of squared
component sizes divided by `n`. This is the key order parameter for the
giant-component phase transition. -/
def susceptibility {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableEq (Fin n)] [DecidableRel G.Adj] : ℝ :=
  if _ : 0 < n then
    (∑ v : Fin n, ((componentOf G v).card : ℝ)) / n
  else 0

/-! ## Monotone graph properties -/

/-- A graph property is monotone increasing if adding edges preserves the property. -/
def MonotoneGraphProperty (n : ℕ) (P : SimpleGraph (Fin n) → Prop) : Prop :=
  ∀ G₁ G₂ : SimpleGraph (Fin n), (∀ u v, G₁.Adj u v → G₂.Adj u v) → P G₁ → P G₂

/-! ## Threshold windows -/

/-- A threshold window for a monotone graph property `P` at parameter `p₀(n)`:
below `p₀(n) - δ(n)` the property fails with high probability,
above `p₀(n) + δ(n)` it holds with high probability.
This is a structural predicate for phase-transition reasoning. -/
structure ThresholdWindow where
  /-- The critical parameter as a function of `n`. -/
  p₀ : ℕ → ℝ
  /-- The window width as a function of `n`. -/
  δ : ℕ → ℝ
  /-- The window width is positive. -/
  hδ_pos : ∀ n, 0 < δ n
  /-- The critical parameter is in [0,1] for large n. -/
  hp₀_range : ∀ᶠ n in Filter.atTop, 0 ≤ p₀ n ∧ p₀ n ≤ 1

/-! ## Edge set size -/

/-- The number of edges in a finite simple graph. -/
def edgeCount {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] : ℕ :=
  G.edgeFinset.card

end