/-
  # Extremal Graph Theory: Core Definitions

  This module defines the fundamental structures and concepts for
  extremal graph theory in Lean 4, building on Mathlib's `SimpleGraph` API.

  Key definitions:
  - `degreeEnergy`: the sum of squared degrees, a combinatorial energy functional
  - `edgeEditDistance`: symmetric difference distance between graphs
  - `triangleCount`: count of triangles (3-cliques) in a graph
  - `TuranGraph`: the balanced complete multipartite graph T(n, r-1)
  - `lowerShadow`: the shadow operator on set families
-/
import Mathlib

open Finset BigOperators SimpleGraph

namespace ExtremalGraph

/-! ## Degree Energy

The degree energy (or degree square sum) of a graph is ∑ᵥ deg(v)².
This is a combinatorial analogue of variance/energy that appears naturally
in extremal arguments via Cauchy-Schwarz and convexity. -/

/-- The degree energy of a simple graph: the sum of squared degrees over all vertices. -/
noncomputable def degreeEnergy {V : Type*} [Fintype V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  ∑ v : V, (G.degree v) ^ 2

/-! ## Edge Edit Distance

The edge edit distance between two graphs on the same vertex set
is the cardinality of the symmetric difference of their edge sets.
This is the minimum number of edge additions/deletions to transform one into the other. -/

/-- Edge edit distance between two simple graphs on the same vertex type. -/
noncomputable def edgeEditDistance {V : Type*} [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel H.Adj]
    [Fintype (↥G.edgeSet)] [Fintype (↥H.edgeSet)] : ℕ :=
  (G.edgeFinset \ H.edgeFinset).card + (H.edgeFinset \ G.edgeFinset).card

/-! ## Triangle Count

A triangle in a graph G is an unordered triple {a, b, c} of distinct vertices
that are pairwise adjacent. We count triangles as the number of such triples. -/

/-- Ordered triangle triples (a, b, c) with a < b < c that form a triangle. -/
noncomputable def orderedTriangleFinset {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : Finset (Fin n × Fin n × Fin n) :=
  Finset.univ.filter fun ⟨a, b, c⟩ =>
    a < b ∧ b < c ∧ G.Adj a b ∧ G.Adj b c ∧ G.Adj a c

/-- The number of triangles (3-cliques) in a simple graph on `Fin n`. -/
noncomputable def triangleCount {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : ℕ :=
  (orderedTriangleFinset G).card

/-! ## Turán Graph

The Turán graph T(n, p) is the complete p-partite graph on n vertices
with part sizes as equal as possible. Vertex i is in part (i % p). -/

/-- The Turán graph T(n, p): the complete p-partite graph on Fin n
    where vertex i is in part (i % p). Two vertices are adjacent iff
    they are in different parts. -/
def TuranGraph (n p : ℕ) (_hp : 1 ≤ p) : SimpleGraph (Fin n) where
  Adj u v := u ≠ v ∧ (u.val % p ≠ v.val % p)
  symm u v := by intro ⟨hne, hmod⟩; exact ⟨hne.symm, hmod.symm⟩
  loopless := ⟨fun v h => h.1 rfl⟩

instance TuranGraph.instDecidableAdj (n p : ℕ) (hp : 1 ≤ p) :
    DecidableRel (TuranGraph n p hp).Adj := by
  intro u v
  unfold TuranGraph
  exact instDecidableAnd

/-! ## Lower Shadow

The lower shadow (or shade) of a family 𝒜 of sets is the collection
of all sets obtainable by removing one element from some member of 𝒜. -/

/-- The lower shadow of a family of finsets: all sets obtained by
    deleting one element from some member of the family. -/
def lowerShadow {α : Type*} [DecidableEq α]
    (𝒜 : Finset (Finset α)) : Finset (Finset α) :=
  𝒜.biUnion (fun s => s.image (fun a => s.erase a))

/-- A family is uniform of rank k if every member has cardinality k. -/
def uniformFamily {α : Type*} (𝒜 : Finset (Finset α)) (k : ℕ) : Prop :=
  ∀ s ∈ 𝒜, s.card = k

/-! ## Additive Pattern Graph

For encoding 3-term arithmetic progressions as graph triangles,
we use a tripartite construction on `Fin N × Fin 3`. -/

/-- A 3-AP in Fin N: three elements a, b, c with a + c = 2 * b (mod N). -/
def isThreeAP (N : ℕ) (a b c : Fin N) : Prop :=
  a.val + c.val ≡ 2 * b.val [MOD N]

instance isThreeAP.instDecidable (N : ℕ) (a b c : Fin N) :
    Decidable (isThreeAP N a b c) := by
  unfold isThreeAP Nat.ModEq
  exact inferInstance

/-- Count of 3-term arithmetic progressions in a subset A ⊆ Fin N. -/
noncomputable def threeAPCount (N : ℕ) (A : Finset (Fin N)) : ℕ :=
  ((A ×ˢ A ×ˢ A).filter (fun ⟨a, b, c⟩ =>
    a ≠ b ∧ b ≠ c ∧ a ≠ c ∧ isThreeAP N a b c)).card

/-! ## Extremal Witness -/

/-- An extremal witness certifies that a particular graph achieves the
    maximum edge count among all K_r-free graphs on n vertices. -/
structure ExtremalWitness (n r : ℕ) where
  G : SimpleGraph (Fin n)
  instDec : DecidableRel G.Adj
  cliqueFree : G.CliqueFree r
  edgeMaximal :
    ∀ (H : SimpleGraph (Fin n)) [DecidableRel H.Adj],
      H.CliqueFree r → H.edgeFinset.card ≤ G.edgeFinset.card

end ExtremalGraph