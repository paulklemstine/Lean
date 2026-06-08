import Mathlib

/-!
# Anti-Gravity Theorems: Definitions

Define the "gravitational weight" of a theorem in a derivation graph as the number
of vertices reachable from it. "Anti-gravity" theorems are those with high weight
but low proof complexity (in-degree).
-/

namespace AntiGravity

open Finset

/-- A derivation graph: directed graph with decidable adjacency. -/
structure DGraph (V : Type*) [Fintype V] [DecidableEq V] where
  adj : V → V → Prop
  [decAdj : DecidableRel adj]

attribute [instance] DGraph.decAdj

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Out-neighbors of a vertex. -/
def DGraph.outNeighbors (G : DGraph V) (v : V) : Finset V :=
  Finset.univ.filter (G.adj v)

/-- In-neighbors of a vertex (direct predecessors). -/
def DGraph.inNeighbors (G : DGraph V) (v : V) : Finset V :=
  Finset.univ.filter (fun u => G.adj u v)

/-- In-degree: number of direct predecessors. -/
def DGraph.inDegree (G : DGraph V) (v : V) : ℕ :=
  (G.inNeighbors v).card

/-- Out-degree: number of direct successors. -/
def DGraph.outDegree (G : DGraph V) (v : V) : ℕ :=
  (G.outNeighbors v).card

/-- Out-neighborhood of a set. -/
def DGraph.outNeighborSet (G : DGraph V) (S : Finset V) : Finset V :=
  S.biUnion G.outNeighbors

/-- Forward reachability ball of radius k from a set S. -/
def FwdBall (G : DGraph V) (S : Finset V) : ℕ → Finset V
  | 0 => S
  | k + 1 => FwdBall G S k ∪ G.outNeighborSet (FwdBall G S k)

/-- Forward reachability ball from a single vertex. -/
def FwdBallV (G : DGraph V) (v : V) (k : ℕ) : Finset V :=
  FwdBall G {v} k

/-- The descendant set of v: all vertices reachable within |V| steps. -/
noncomputable def DescendantSet (G : DGraph V) (v : V) : Finset V :=
  FwdBallV G v (Fintype.card V)

/-- The gravitational weight of a vertex: size of its descendant set. -/
noncomputable def Weight (G : DGraph V) (v : V) : ℕ :=
  (DescendantSet G v).card

/-- A vertex is a source (axiom) if it has no predecessors. -/
def IsSource (G : DGraph V) (v : V) : Prop :=
  G.inDegree v = 0

/-- A vertex is anti-gravity with threshold τ if its weight exceeds τ times its
    in-degree. -/
def IsAntiGravity (G : DGraph V) (v : V) (τ : ℕ) : Prop :=
  Weight G v > τ * G.inDegree v

/-- The total weight of all vertices. -/
noncomputable def TotalWeight (G : DGraph V) : ℕ :=
  Finset.univ.sum (Weight G)

/-- The total edge count (sum of in-degrees). -/
def EdgeCount (G : DGraph V) : ℕ :=
  Finset.univ.sum (G.inDegree)

/-! ## Basic properties -/


theorem fwdBall_mono_steps (G : DGraph V) (S : Finset V) {k m : ℕ} (hkm : k ≤ m) :
    FwdBall G S k ⊆ FwdBall G S m := by
  induction m with
  | zero =>
    interval_cases k
    exact Finset.Subset.refl _
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hkm with rfl | h
    · exact Finset.Subset.refl _
    · exact Finset.Subset.trans (ih (Nat.lt_succ_iff.mp h)) (fwdBall_subset_succ G S n)

/-- Every vertex is in its own descendant set. -/

theorem high_weight_count_bound (G : DGraph V) (w : ℕ) (_hw : 0 < w) :
    (Finset.univ.filter (fun v => w ≤ Weight G v)).card * w ≤ TotalWeight G := by
  have h_markov : (Finset.card (Finset.filter (fun v => w ≤ Weight G v) Finset.univ)) * w ≤ ∑ v ∈ Finset.univ, Weight G v := by
    have h_sum : ∑ v ∈ Finset.filter (fun v => w ≤ Weight G v) Finset.univ, Weight G v ≤ ∑ v ∈ Finset.univ, Weight G v := by
      exact Finset.sum_le_sum_of_subset ( Finset.filter_subset _ _ )
    exact le_trans ( by simpa using Finset.sum_le_sum fun v ( hv : v ∈ Finset.filter ( fun v => w ≤ Weight G v ) Finset.univ ) => Finset.mem_filter.mp hv |>.2 ) h_sum;
  exact h_markov

/-! ## Theorem 6: Chain Anti-Gravity -/

/-
In a graph where a vertex has in-degree ≤ 1 (as in a proof chain),
having weight > τ implies being anti-gravity at threshold τ.
-/

theorem edge_count_le_sq (G : DGraph V) :
    EdgeCount G ≤ Fintype.card V * Fintype.card V := by
  convert Finset.sum_le_sum fun v _ => G.inDegree v |> fun x => Nat.le_of_lt_succ _;
  rotate_right;
  exacts [ fun _ _ => Fintype.card V, by simp +decide, Nat.lt_succ_of_le ( Finset.card_le_univ _ ) ]

/-! ## Theorem 8: Weight Bounded by Universe -/

/-
Each vertex's weight is at most |V|.
-/