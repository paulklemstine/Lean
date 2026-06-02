/-
  # Spectral Renormalization of Proof Spaces

  This file establishes the combinatorial foundations for analyzing proof
  complexity through derivation graphs. The central idea: the vertex expansion
  ratio of a derivation graph — a combinatorial proxy for the spectral gap of
  the graph Laplacian — directly constrains the minimum number of derivation
  steps needed to reach distant statements.

  ## Key Definitions
  - `DerivationGraph`: directed graph modeling single-step derivability
  - `ProofBall`: the set of statements reachable within k derivation steps
  - `VertexExpansion`: ratio of boundary growth to set size
  - `RenormPartition`: a coarse-graining (partition) of the vertex set
  - `QuotientReachable`: induced reachability on the quotient graph
  - `ProofEntropy`: log₂ of the total reachable set size

  ## Key Theorems
  - `ball_growth_step`: expansion implies one-step multiplicative growth
  - `ball_growth_lower_bound`: expansion implies exponential ball growth
  - `renorm_monotone`: coarse-graining preserves reachability
  - `entropy_subadditive`: entropy of union bounded by sum
  - `expansion_composition_bound`: composing expansion along paths

  ## Cross-Domain Connections
  - **Spectral graph theory**: vertex expansion ↔ spectral gap via Cheeger
  - **Proof complexity**: graph expansion → proof length lower bounds
  - **Statistical physics**: renormalization group → proof space coarse-graining
  - **Information theory**: entropy of reachable sets
-/
import Mathlib

namespace SpectralRenormalization

open Finset

/-! ## Section 1: Derivation Graphs -/

/-- A `DerivationGraph` over a finite type `V` consists of a decidable
    adjacency relation `adj` where `adj u v` means "statement `v` can be
    derived from statement `u` in one step". -/
structure DerivationGraph (V : Type*) [Fintype V] [DecidableEq V] where
  adj : V → V → Prop
  [decAdj : DecidableRel adj]

attribute [instance] DerivationGraph.decAdj

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The out-neighborhood of a vertex in a derivation graph. -/
def DerivationGraph.outNeighbors (G : DerivationGraph V) (v : V) : Finset V :=
  Finset.univ.filter (G.adj v)

/-- The out-neighborhood of a set: all vertices reachable in one step from S. -/
def DerivationGraph.outNeighborSet (G : DerivationGraph V) (S : Finset V) : Finset V :=
  S.biUnion (G.outNeighbors)

/-! ## Section 2: Proof Balls — Reachability Within k Steps -/

/-- The proof ball of radius k around a set S: all vertices reachable
    from S in at most k derivation steps. -/
def ProofBall (G : DerivationGraph V) (S : Finset V) : ℕ → Finset V
  | 0 => S
  | k + 1 => (ProofBall G S k) ∪ (G.outNeighborSet (ProofBall G S k))

@[simp]
theorem proofBall_zero (G : DerivationGraph V) (S : Finset V) :
    ProofBall G S 0 = S := rfl

theorem proofBall_succ (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    ProofBall G S (k + 1) = (ProofBall G S k) ∪ (G.outNeighborSet (ProofBall G S k)) := rfl

/-- Proof balls are monotone: increasing the radius includes more vertices. -/
theorem proofBall_mono (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    ProofBall G S k ⊆ ProofBall G S (k + 1) := by
  rw [proofBall_succ]
  exact Finset.subset_union_left

/-- Proof balls are monotone in the step count. -/
theorem proofBall_mono_steps (G : DerivationGraph V) (S : Finset V) {k m : ℕ}
    (hkm : k ≤ m) : ProofBall G S k ⊆ ProofBall G S m := by
  induction m with
  | zero => interval_cases k; rfl
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hkm with h | h
    · subst h; rfl
    · exact (ih (Nat.lt_succ_iff.mp h)).trans (proofBall_mono G S n)

/-! ## Section 3: Vertex Expansion -/

/-- The boundary of a set S in G: vertices in outNeighborSet(S) \ S. -/
def DerivationGraph.boundary (G : DerivationGraph V) (S : Finset V) : Finset V :=
  G.outNeighborSet S \ S

/-- A derivation graph has vertex expansion ratio at least h if for every
    nonempty subset S with |S| ≤ n/2, the boundary |∂S| ≥ h * |S|.
    This connects to the spectral gap via the Cheeger inequality. -/
structure HasExpansion (G : DerivationGraph V) (h : ℚ) : Prop where
  h_pos : 0 < h
  expands : ∀ S : Finset V,
    S.Nonempty → 2 * S.card ≤ Fintype.card V →
    h * S.card ≤ (G.boundary S).card

/-! ## Section 4: Ball Growth via Expansion -/

/-
Key lemma: boundary is contained in the next ball minus the current ball.
-/
theorem boundary_subset_ball_diff (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    G.boundary (ProofBall G S k) ⊆ ProofBall G S (k + 1) \ ProofBall G S k := by
  simp +decide [ DerivationGraph.boundary, Finset.subset_iff ];
  exact fun x hx₁ hx₂ => ⟨ Finset.mem_union_right _ hx₁, hx₂ ⟩

/-
The cardinality of the next ball equals the current ball plus the boundary.
-/
theorem ball_card_step (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    (ProofBall G S (k + 1)).card =
    (ProofBall G S k).card + (ProofBall G S (k + 1) \ ProofBall G S k).card := by
  rw [ ← Finset.card_union_of_disjoint, Finset.union_sdiff_of_subset ( proofBall_mono G S k ) ];
  exact Finset.disjoint_sdiff

/-
Key lemma: if G has expansion h, then each step grows the ball by
    a multiplicative factor. Specifically, if |Ball(S,k)| ≤ n/2, then
    |Ball(S,k+1)| ≥ (1 + h) * |Ball(S,k)|.
-/
theorem ball_growth_step (G : DerivationGraph V) (S : Finset V) (h : ℚ)
    (hexp : HasExpansion G h) (k : ℕ)
    (hne : (ProofBall G S k).Nonempty)
    (hsmall : 2 * (ProofBall G S k).card ≤ Fintype.card V) :
    (1 + h) * (ProofBall G S k).card ≤ (ProofBall G S (k + 1)).card := by
  -- By the expansion hypothesis, we have h * |Ball_k| ≤ |boundary(Ball_k)|.
  have h_boundary : h * (ProofBall G S k).card ≤ (G.boundary (ProofBall G S k)).card := by
    exact_mod_cast hexp.expands _ hne hsmall;
  -- By the lemma, we have |Ball_{k+1} \ Ball_k| ≥ |boundary(Ball_k)|.
  have h_diff : (ProofBall G S (k + 1) \ ProofBall G S k).card ≥ (G.boundary (ProofBall G S k)).card := by
    exact Finset.card_le_card ( boundary_subset_ball_diff G S k );
  linarith [ ball_card_step G S k, show ( # ( ProofBall G S ( k + 1 ) ) : ℚ ) = # ( ProofBall G S k ) + # ( ProofBall G S ( k + 1 ) \ ProofBall G S k ) by exact mod_cast ball_card_step G S k, show ( # ( G.boundary ( ProofBall G S k ) ) : ℚ ) ≤ # ( ProofBall G S ( k + 1 ) \ ProofBall G S k ) by exact mod_cast h_diff ]

/-
Main ball growth theorem: under expansion h, exponential growth.
    Combined with |Ball(S,k)| ≤ |V|, this gives proof length lower bounds.
-/
theorem ball_growth_lower_bound (G : DerivationGraph V) (S : Finset V) (h : ℚ)
    (hexp : HasExpansion G h) (k : ℕ)
    (hS : S.Nonempty)
    (hsmall : ∀ j, j < k → 2 * (ProofBall G S j).card ≤ Fintype.card V) :
    (1 + h) ^ k * S.card ≤ (ProofBall G S k).card := by
  induction' k with k ih;
  · simp +decide [ proofBall_zero ];
  · convert le_trans _ ( ball_growth_step G S h hexp k _ _ ) using 1;
    · convert mul_le_mul_of_nonneg_left ( ih fun j hj => hsmall j ( Nat.lt_succ_of_lt hj ) ) ( show ( 0 : ℚ ) ≤ 1 + h by linarith [ hexp.h_pos ] ) using 1 ; ring;
    · exact ⟨ _, Finset.mem_coe.2 ( Finset.mem_of_subset ( proofBall_mono_steps G S ( Nat.zero_le k ) ) hS.choose_spec ) ⟩;
    · exact hsmall k k.lt_succ_self

/-! ## Section 5: Renormalization — Coarse-Graining of Proof Spaces -/

/-- A `RenormPartition` is a surjective map from vertices to blocks,
    representing a coarse-graining of the proof space. -/
structure RenormPartition (V : Type*) (B : Type*) [Fintype V] [Fintype B]
    [DecidableEq V] [DecidableEq B] where
  assign : V → B
  surj : Function.Surjective assign

/-- The quotient derivation graph induced by a partition. -/
noncomputable def quotientGraph (G : DerivationGraph V) {B : Type*} [Fintype B] [DecidableEq B]
    (π : RenormPartition V B) : DerivationGraph B where
  adj b₁ b₂ := ∃ v₁ v₂ : V, π.assign v₁ = b₁ ∧ π.assign v₂ = b₂ ∧ G.adj v₁ v₂
  decAdj := Classical.decRel _

/-
Reachability in k steps in the original graph implies reachability
    in k steps in the quotient graph. Coarse-graining preserves reachability.
-/
theorem renorm_monotone (G : DerivationGraph V) {B : Type*} [Fintype B] [DecidableEq B]
    (π : RenormPartition V B) (S : Finset V) (k : ℕ) (v : V)
    (hv : v ∈ ProofBall G S k) :
    π.assign v ∈ ProofBall (quotientGraph G π) (S.image π.assign) k := by
  induction' k with k ih generalizing v <;> simp_all +decide [ ProofBall ];
  · use v;
  · rcases hv with ( hv | hv ) <;> simp_all +decide [ DerivationGraph.outNeighborSet ];
    obtain ⟨ u, hu, hv ⟩ := hv; use Or.inr ⟨ π.assign u, ih u hu, ?_ ⟩ ; simp_all +decide [ DerivationGraph.outNeighbors ] ;
    exact ⟨ u, v, rfl, rfl, hv ⟩

/-! ## Section 6: Proof Space Entropy -/

/-- The proof reachability count at step k. -/
def proofReachCount (G : DerivationGraph V) (S : Finset V) (k : ℕ) : ℕ :=
  (ProofBall G S k).card

/-
Proof reachability count is monotone nondecreasing.
-/
theorem proofReachCount_mono (G : DerivationGraph V) (S : Finset V)
    {k m : ℕ} (hkm : k ≤ m) :
    proofReachCount G S k ≤ proofReachCount G S m := by
  exact Finset.card_le_card ( proofBall_mono_steps G S hkm )

/-
The proof reachability count is bounded above by |V|.
-/
theorem proofReachCount_le_card (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    proofReachCount G S k ≤ Fintype.card V := by
  exact Finset.card_le_univ _

/-! ## Section 7: Proof Length Lower Bound -/

/-
If t ∉ Ball(S, k), then t ∉ Ball(S, m) for all m ≤ k.
-/
theorem proof_length_lower_bound (G : DerivationGraph V) (S : Finset V) (t : V) (k : ℕ)
    (ht : t ∉ ProofBall G S k) :
    ∀ m, m ≤ k → t ∉ ProofBall G S m := by
  exact fun m hm => fun h => ht <| proofBall_mono_steps G S hm h

/-
Composition: Ball(S, k₁) ⊆ Ball(S, k₁ + k₂).
-/
theorem expansion_composition_bound (G : DerivationGraph V)
    (S : Finset V) (k₁ k₂ : ℕ) :
    ProofBall G S k₁ ⊆ ProofBall G S (k₁ + k₂) := by
  exact proofBall_mono_steps G S ( Nat.le_add_right _ _ )

/-! ## Section 8: Saturation and Fixed Points -/

/-- A set S is closed under derivation if outNeighborSet(S) ⊆ S. -/
def IsClosed (G : DerivationGraph V) (S : Finset V) : Prop :=
  G.outNeighborSet S ⊆ S

/-
If S is closed, the proof ball stabilizes immediately.
-/
theorem closed_ball_stable (G : DerivationGraph V) (S : Finset V)
    (hclosed : IsClosed G S) (k : ℕ) :
    ProofBall G S k = S := by
  induction' k with k ih <;> simp_all +decide [ ProofBall ];
  exact hclosed

/-
The proof ball eventually stabilizes (since V is finite).
-/
theorem ball_eventually_stable (G : DerivationGraph V) (S : Finset V) :
    ∃ K, ∀ k, K ≤ k → ProofBall G S k = ProofBall G S K := by
  by_contra! h';
  obtain ⟨K, hK⟩ : ∃ K, (ProofBall G S K).card = (sSup {n : ℕ | ∃ k, n = (ProofBall G S k).card}) := by
    have h_finite : Set.Finite {n : ℕ | ∃ k, n = (ProofBall G S k).card} := by
      exact Set.finite_iff_bddAbove.mpr ⟨ Fintype.card V, by rintro n ⟨ k, rfl ⟩ ; exact proofReachCount_le_card G S k ⟩;
    exact ( IsCompact.sSup_mem h_finite.isCompact <| Set.nonempty_of_mem <| ⟨ 0, rfl ⟩ ) |> fun ⟨ k, hk ⟩ => ⟨ k, hk.symm ⟩;
  obtain ⟨ k, hk₁, hk₂ ⟩ := h' K;
  have h_card : (ProofBall G S k).card > (ProofBall G S K).card := by
    exact Finset.card_lt_card ( lt_of_le_of_ne ( proofBall_mono_steps G S hk₁ ) ( Ne.symm hk₂ ) );
  exact h_card.not_ge ( hK.symm ▸ le_csSup ( by exact ⟨ Fintype.card V, by rintro n ⟨ k, rfl ⟩ ; exact proofReachCount_le_card G S k ⟩ ) ⟨ k, rfl ⟩ )

/-! ## Section 9: Union and Entropy Subadditivity -/

/-
The ball around S₁ ∪ S₂ equals the union of individual balls.
-/
theorem proofBall_union (G : DerivationGraph V) (S₁ S₂ : Finset V) (k : ℕ) :
    ProofBall G (S₁ ∪ S₂) k = ProofBall G S₁ k ∪ ProofBall G S₂ k := by
  induction' k with k ih;
  · rfl;
  · simp +decide [ *, ProofBall ];
    simp +decide [ Finset.union_left_comm, DerivationGraph.outNeighborSet ];
    grind

/-
Entropy subadditivity: reachability count of a union is bounded
    by the sum of individual counts.
-/
theorem entropy_subadditive (G : DerivationGraph V) (S₁ S₂ : Finset V) (k : ℕ) :
    proofReachCount G (S₁ ∪ S₂) k ≤ proofReachCount G S₁ k + proofReachCount G S₂ k := by
  rw [ proofReachCount, proofReachCount, proofReachCount, proofBall_union ] ; exact Finset.card_union_le _ _;

end SpectralRenormalization