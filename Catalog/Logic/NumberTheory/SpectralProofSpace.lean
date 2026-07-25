import Mathlib

/-!
# Spectral Renormalization of Proof Spaces

We formalize **derivation graphs** — directed graphs where nodes represent statements
in a formal theory and edges represent one-step derivability — and develop the
combinatorial foundations for analyzing proof complexity through graph-theoretic
invariants.

## Main Definitions

* `DiGraph` — A directed graph on a finite vertex set with `Bool`-valued adjacency
* `DiGraph.ball` — The k-step forward reachable set from a source set
* `DiGraph.quotientGraph` — The coarse-grained graph induced by a surjection
* `proofSpaceEntropy` — Information-theoretic measure of derivation complexity

## Main Results

* `ball_mono` — Forward balls grow monotonically with the step count
* `ball_card_bound` — Ball size is bounded by `|S| * (d + 1) ^ k`
* `quotientGraph_edge_of_edge` — Edges project through quotients
* `quotient_ball_subset` — Original balls project into quotient balls
* `expansion_proof_length_bound` — Vertex expansion yields proof length lower bounds
-/

open Finset Function

/-- A directed graph on a finite vertex type.
In the derivation graph interpretation, vertices are formal statements and
`edge v w = true` means `w` is derivable from `v` in one step. -/
structure DiGraph (V : Type*) [Fintype V] [DecidableEq V] where
  /-- Adjacency function. `edge v w = true` iff there is a directed edge v → w. -/
  edge : V → V → Bool

namespace DiGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The set of out-neighbors of vertex `v`. -/
def outNeighbors (G : DiGraph V) (v : V) : Finset V :=
  Finset.univ.filter (fun w => G.edge v w)

/-- The out-degree of vertex `v`. -/
def outDeg (G : DiGraph V) (v : V) : ℕ :=
  (G.outNeighbors v).card

/-- Forward ball: the set of vertices reachable from source set `S` in at most `k` steps. -/
def ball (G : DiGraph V) (S : Finset V) : ℕ → Finset V
  | 0 => S
  | n + 1 => G.ball S n ∪ (G.ball S n).biUnion G.outNeighbors

/-- The one-step expansion of a set: out-neighbors not already in the set. -/
def expansion (G : DiGraph V) (S : Finset V) : Finset V :=
  S.biUnion G.outNeighbors \ S

/-! ### Ball Monotonicity -/

/-
Forward balls grow monotonically: `ball S k ⊆ ball S (k + 1)`.
-/
theorem ball_mono (G : DiGraph V) (S : Finset V) (k : ℕ) :
    G.ball S k ⊆ G.ball S (k + 1) := by
  exact Finset.subset_union_left

/-- Ball at step 0 is just the source set. -/
@[simp] theorem ball_zero (G : DiGraph V) (S : Finset V) :
    G.ball S 0 = S := rfl

/-- Characterization of ball at step k + 1. -/
theorem ball_succ (G : DiGraph V) (S : Finset V) (k : ℕ) :
    G.ball S (k + 1) = G.ball S k ∪ (G.ball S k).biUnion G.outNeighbors := rfl

/-! ### Ball Growth Bound

The key combinatorial result: forward-reachable sets grow at most by a factor
of `(d + 1)` per step, where `d` is the maximum out-degree. This yields the
fundamental logarithmic lower bound on proof length.
-/

/-
The biUnion of out-neighborhoods of a set S has card ≤ |S| * d
when all out-degrees are bounded by d.
-/
theorem biUnion_outNeighbors_card_le (G : DiGraph V) (S : Finset V) (d : ℕ)
    (hd : ∀ v, G.outDeg v ≤ d) :
    (S.biUnion G.outNeighbors).card ≤ S.card * d := by
  refine' le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_card_nsmul _ _ _ fun x hx => hd x )

/-
**Ball Growth Bound**: The k-step forward ball from `S` has cardinality
at most `|S| * (d + 1)^k`, where `d` bounds the maximum out-degree.
This is the foundational estimate that yields logarithmic proof-length lower bounds.
-/
theorem ball_card_bound (G : DiGraph V) (S : Finset V) (d : ℕ)
    (hd : ∀ v, G.outDeg v ≤ d) (k : ℕ) :
    (G.ball S k).card ≤ S.card * (d + 1) ^ k := by
  induction' k with k ih;
  · simp +decide;
  · rw [ pow_succ' ];
    refine' le_trans ( Finset.card_union_le _ _ ) _;
    refine' le_trans ( add_le_add ih ( biUnion_outNeighbors_card_le G _ _ hd ) ) _;
    nlinarith [ pow_pos ( Nat.succ_pos d ) k ]

/-! ### Quotient (Renormalized) Graphs

Coarse-graining a derivation graph by merging groups of statements into
single nodes. This models the "renormalization" operation: forgetting fine-grained
distinctions while preserving derivability structure.
-/

/-- The quotient graph induced by a map `f : V → W`. An edge exists from
`w₁` to `w₂` in the quotient iff some pre-image of `w₁` has an edge to
some pre-image of `w₂` in the original graph. -/
def quotientGraph {W : Type*} [Fintype W] [DecidableEq W]
    (G : DiGraph V) (f : V → W) : DiGraph W where
  edge w₁ w₂ := decide (∃ v₁ v₂, f v₁ = w₁ ∧ f v₂ = w₂ ∧ G.edge v₁ v₂ = true)

/-
If `v₁ → v₂` is an edge in `G`, then `f v₁ → f v₂` is an edge in the
quotient graph. This is the key "projection" property of renormalization.
-/
theorem quotientGraph_edge_of_edge {W : Type*} [Fintype W] [DecidableEq W]
    (G : DiGraph V) (f : V → W)
    (v₁ v₂ : V) (h : G.edge v₁ v₂ = true) :
    (G.quotientGraph f).edge (f v₁) (f v₂) = true := by
  unfold DiGraph.quotientGraph;
  grind

/-
The image of a ball under `f` is contained in the corresponding ball
of the quotient graph. Renormalization cannot increase reachability distance.
-/
theorem quotient_ball_subset {W : Type*} [Fintype W] [DecidableEq W]
    (G : DiGraph V) (f : V → W) (S : Finset V) (k : ℕ) :
    (G.ball S k).image f ⊆ (G.quotientGraph f).ball (S.image f) k := by
  induction' k with k ih;
  · aesop;
  · simp +decide [ Finset.subset_iff, DiGraph.ball ];
    rintro a ( ha | ⟨ b, hb, hab ⟩ );
    · exact Or.inl ( ih ( Finset.mem_image_of_mem _ ha ) );
    · refine' Or.inr ⟨ f b, ih ( Finset.mem_image_of_mem f hb ), _ ⟩;
      simp_all +decide [ DiGraph.outNeighbors, DiGraph.quotientGraph ];
      exact ⟨ b, rfl, a, rfl, hab ⟩

/-- **Renormalization Monotonicity**: The quotient ball's image is no larger than the
original ball. Coarse-graining can only lose information. -/
theorem quotient_ball_card_le {W : Type*} [DecidableEq W]
    (G : DiGraph V) (f : V → W) (S : Finset V) (k : ℕ) :
    ((G.ball S k).image f).card ≤ (G.ball S k).card :=
  Finset.card_image_le

/-! ### Vertex Expansion and Proof Length Lower Bounds

If the derivation graph has good expansion — meaning every small set has many
new neighbors — then proofs must be long because the ball cannot grow slowly
enough to reach a distant target.
-/

/-
**Expansion implies ball growth lower bound**: If every subset of size ≤ n/2
in the derivation graph has at least `h * |S|` new neighbors, then the ball
from a single vertex grows at least as fast as `(1 + h)^k`.

This is the core bridge theorem connecting expansion properties (the combinatorial
shadow of the spectral gap) to proof complexity.
-/
theorem expansion_proof_length_bound (G : DiGraph V) (v : V) (k : ℕ)
    (h : ℝ) (hh : 0 < h)
    (hexp : ∀ S : Finset V, S.Nonempty → 2 * S.card ≤ Fintype.card V →
      h * S.card ≤ (G.expansion S).card)
    (hball : ∀ j, j ≤ k → 2 * (G.ball {v} j).card ≤ Fintype.card V) :
    (1 + h) ^ k ≤ (G.ball {v} k).card := by
  -- By the expansion hypothesis, we have |ball S (j+1)| ≥ |ball S j| + h * |ball S j|.
  have h_step : ∀ j < k, (1 + h) * (G.ball {v} j).card ≤ (G.ball {v} (j + 1)).card := by
    intro j hj
    have h_step : (G.ball {v} (j + 1)).card ≥ (G.ball {v} j).card + (G.expansion (G.ball {v} j)).card := by
      simp +decide [ DiGraph.ball, DiGraph.expansion ];
      grind;
    by_cases h_nonempty : (G.ball {v} j).Nonempty;
    · linarith [ hexp ( G.ball { v } j ) h_nonempty ( hball j ( Nat.le_of_lt hj ) ), show ( # ( G.ball { v } ( j + 1 ) ) : ℝ ) ≥ # ( G.ball { v } j ) + # ( G.expansion ( G.ball { v } j ) ) by exact_mod_cast h_step ];
    · simp_all +decide [ Finset.not_nonempty_iff_eq_empty ];
  induction' k with k ih;
  · simp +decide [ DiGraph.ball ];
  · simpa only [ pow_succ' ] using le_trans ( mul_le_mul_of_nonneg_left ( ih ( fun j hj => hball j ( Nat.le_succ_of_le hj ) ) ( fun j hj => h_step j ( Nat.lt_succ_of_lt hj ) ) ) ( by positivity ) ) ( h_step k ( Nat.lt_succ_self k ) )

end DiGraph

/-! ## Proof Space Entropy

A novel information-theoretic measure of derivation complexity that captures
the "surprise" of discovering new consequences at each step.
-/

/-- **Proof Space Entropy** at step `k`: the logarithm of the ball growth ratio.
When the ball doubles in size, the entropy is log 2 nats. When it stops growing,
entropy is 0. This measures the information content of each additional derivation step. -/
noncomputable def proofSpaceEntropy {V : Type*} [Fintype V] [DecidableEq V]
    (G : DiGraph V) (v : V) (k : ℕ) : ℝ :=
  let bk := ((G.ball {v} k).card : ℝ)
  let bk1 := ((G.ball {v} (k + 1)).card : ℝ)
  if bk = 0 then 0
  else Real.log (bk1 / bk)

/-- The total proof entropy: sum of step entropies up to `n` steps.
This is an information-theoretic measure of the total "computational work"
needed to explore consequences of a statement. -/
noncomputable def totalProofEntropy {V : Type*} [Fintype V] [DecidableEq V]
    (G : DiGraph V) (v : V) (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.range n, proofSpaceEntropy G v k

/-
**Entropy Telescoping**: The total proof entropy telescopes to the log of
the final ball size, since it is a sum of log(b_{k+1}/b_k).

The key insight: proof space entropy is not an arbitrary definition but equals
the natural logarithm of total reachability — the fundamental quantity in
proof complexity.
-/
theorem total_entropy_telescopes {V : Type*} [Fintype V] [DecidableEq V]
    (G : DiGraph V) (v : V) (n : ℕ)
    (hpos : ∀ k, k ≤ n → 0 < ((G.ball {v} k).card : ℝ)) :
    totalProofEntropy G v n = Real.log ((G.ball {v} n).card) := by
  convert Finset.sum_range_sub ( fun k => Real.log ( ( G.ball { v } k |> Finset.card : ℝ ) ) ) n using 1;
  · exact Finset.sum_congr rfl fun k hk => by rw [ proofSpaceEntropy, if_neg ( ne_of_gt ( hpos k ( Finset.mem_range_le hk ) ) ), Real.log_div ( ne_of_gt ( hpos ( k + 1 ) ( by linarith [ Finset.mem_range.mp hk ] ) ) ) ( ne_of_gt ( hpos k ( Finset.mem_range_le hk ) ) ) ] ;
  · simp +decide [ DiGraph.ball ]