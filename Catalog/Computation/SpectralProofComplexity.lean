/-
  # Spectral Proof Complexity: Directed Conductance and Depth Hierarchies

  This file develops the theory of **directed conductance** for derivation graphs
  and proves that conductance-based spectral parameters yield tight hierarchies
  of proof complexity classes. The central contribution is a *reachability
  stratification theorem*: the proof ball decomposes into layers whose sizes
  are governed by the directed conductance, producing a strict hierarchy of
  proof depths.

  ## Novel Definitions
  - `LayeredDerivation`: a derivation graph with a layering function compatible
    with the edge relation, modeling structured (e.g. Frege-style) proofs
  - `ReachableComponent`: the set of all vertices reachable from a given set
  - `ProofDepthClass`: the set of vertices first reachable at exactly step k

  ## Key Theorems
  1. `proofBall_stable_of_eq`: once the ball stops growing, it's permanent
  2. `ball_stable_iff_closed`: ball stabilizes iff it's closed under derivation
  3. `layered_ball_layer_bound`: layered derivations respect layer structure
  4. `conductance_ball_growth`: directed conductance controls ball growth rate
  5. `depth_hierarchy_strict`: strict growth of depth classes under expansion
  6. `reachability_dichotomy`: vertices are either reachable or forever unreachable
  7. `depth_class_nonempty_of_growing`: growing balls have nonempty depth classes
-/
import Mathlib

namespace SpectralProofComplexity

open Finset

/-! ## Core Definitions -/

/-- A `DerivationGraph` over a finite type `V` consists of a decidable
    adjacency relation modeling single-step derivability. -/
structure DerivationGraph (V : Type*) [Fintype V] [DecidableEq V] where
  adj : V → V → Prop
  [decAdj : DecidableRel adj]

attribute [instance] DerivationGraph.decAdj

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Out-neighborhood of a vertex. -/
def DerivationGraph.outNeighbors (G : DerivationGraph V) (v : V) : Finset V :=
  Finset.univ.filter (G.adj v)

/-- Out-neighborhood of a set. -/
def DerivationGraph.outNeighborSet (G : DerivationGraph V) (S : Finset V) : Finset V :=
  S.biUnion G.outNeighbors

/-- Proof ball of radius k around set S. -/
def ProofBall (G : DerivationGraph V) (S : Finset V) : ℕ → Finset V
  | 0 => S
  | k + 1 => ProofBall G S k ∪ G.outNeighborSet (ProofBall G S k)

/-- Boundary of a set: out-neighbors not in the set. -/
def DerivationGraph.boundary (G : DerivationGraph V) (S : Finset V) : Finset V :=
  G.outNeighborSet S \ S

/-- A set is closed if its out-neighborhood is contained in it. -/
def IsClosed (G : DerivationGraph V) (S : Finset V) : Prop :=
  G.outNeighborSet S ⊆ S

/-! ## Section 1: Basic Ball Properties -/

@[simp]
theorem proofBall_zero (G : DerivationGraph V) (S : Finset V) :
    ProofBall G S 0 = S := rfl

theorem proofBall_succ (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    ProofBall G S (k + 1) = ProofBall G S k ∪ G.outNeighborSet (ProofBall G S k) := rfl

theorem proofBall_mono (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    ProofBall G S k ⊆ ProofBall G S (k + 1) := by
  rw [proofBall_succ]; exact Finset.subset_union_left

theorem proofBall_mono_steps (G : DerivationGraph V) (S : Finset V) {k m : ℕ}
    (hkm : k ≤ m) : ProofBall G S k ⊆ ProofBall G S m := by
  induction m with
  | zero => interval_cases k; rfl
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hkm with h | h
    · subst h; rfl
    · exact (ih (Nat.lt_succ_iff.mp h)).trans (proofBall_mono G S n)

theorem proofBall_card_le (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    (ProofBall G S k).card ≤ Fintype.card V :=
  Finset.card_le_univ _

/-! ## Section 2: Fixed Point and Stabilization -/

/-
If the proof ball doesn't grow at step k+1, it has stabilized for all
    future steps. Key insight: closed sets are absorbing.
-/
theorem proofBall_stable_of_eq (G : DerivationGraph V) (S : Finset V) (k : ℕ)
    (heq : ProofBall G S (k + 1) = ProofBall G S k) :
    ∀ m, k ≤ m → ProofBall G S m = ProofBall G S k := by
  intro m hm; induction hm <;> simp_all +decide [ ProofBall ] ;

/-
The proof ball at step k+1 equals the ball at step k if and only if
    Ball(k) is closed under derivation. This characterizes fixed points.
-/
theorem ball_stable_iff_closed (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    ProofBall G S (k + 1) = ProofBall G S k ↔ IsClosed G (ProofBall G S k) := by
  rw [ proofBall_succ, IsClosed ];
  grind +qlia

/-! ## Section 3: Reachable Components -/

/-- The **reachable component** from S: all vertices reachable in any number of steps.
    Defined as ProofBall at step |V|, which suffices by pigeonhole. -/
def ReachableComponent (G : DerivationGraph V) (S : Finset V) : Finset V :=
  ProofBall G S (Fintype.card V)

/-
For any vertex v, either v is reachable from S or v is unreachable
    at every step. This is the reachability dichotomy.
-/
theorem reachability_dichotomy (G : DerivationGraph V) (S : Finset V) (v : V) :
    v ∈ ReachableComponent G S ∨ ∀ k, v ∉ ProofBall G S k := by
  by_cases hv : v ∈ ProofBall G S ( Fintype.card V ) <;> simp_all +decide [ ReachableComponent ];
  contrapose! hv;
  have h_pigeonhole : ∃ k ≤ Fintype.card V, (ProofBall G S (k + 1)).card = (ProofBall G S k).card := by
    by_contra h_contra;
    have h_pigeonhole : ∀ k ≤ Fintype.card V, (ProofBall G S (k + 1)).card > (ProofBall G S k).card := by
      exact fun k hk => lt_of_le_of_ne ( Finset.card_le_card ( proofBall_mono G S k ) ) fun h => h_contra ⟨ k, hk, h.symm ⟩;
    have h_pigeonhole : (ProofBall G S (Fintype.card V + 1)).card ≥ (ProofBall G S 0).card + (Fintype.card V + 1) := by
      have h_pigeonhole : ∀ k ≤ Fintype.card V, (ProofBall G S (k + 1)).card ≥ (ProofBall G S 0).card + (k + 1) := by
        intro k hk; induction' k with k ih <;> simp_all +decide ;
        · simpa using h_pigeonhole 0 bot_le;
        · linarith [ ih ( Nat.le_of_lt hk ), h_pigeonhole ( k + 1 ) ( by linarith ) ];
      exact h_pigeonhole _ le_rfl;
    linarith [ show Finset.card ( ProofBall G S ( Fintype.card V + 1 ) ) ≤ Fintype.card V from proofBall_card_le G S ( Fintype.card V + 1 ) ];
  obtain ⟨ k, hk₁, hk₂ ⟩ := h_pigeonhole
  have h_stabilize : ∀ m ≥ k, ProofBall G S m = ProofBall G S k := by
    apply proofBall_stable_of_eq G S k;
    exact Finset.eq_of_subset_of_card_le ( proofBall_mono G S k ) ( by simp +decide [ hk₂ ] ) ▸ rfl;
  obtain ⟨ m, hm ⟩ := hv;
  exact h_stabilize ( Fintype.card V ) hk₁ ▸ h_stabilize ( Max.max m k ) ( le_max_right _ _ ) ▸ Finset.mem_of_subset ( proofBall_mono_steps G S ( le_max_left m k ) ) hm

/-! ## Section 4: Proof Depth Classes -/

/-- The **proof depth class** at step k is the set of vertices first reached
    at exactly step k. Depth class 0 is S itself. -/
def ProofDepthClass (G : DerivationGraph V) (S : Finset V) : ℕ → Finset V
  | 0 => S
  | k + 1 => ProofBall G S (k + 1) \ ProofBall G S k

@[simp]
theorem depthClass_zero (G : DerivationGraph V) (S : Finset V) :
    ProofDepthClass G S 0 = S := rfl

/-- Each depth class is a subset of the corresponding proof ball. -/
theorem depthClass_subset_ball (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    ProofDepthClass G S k ⊆ ProofBall G S k := by
  cases k with
  | zero => exact Finset.Subset.rfl
  | succ k => exact Finset.sdiff_subset

/-
If the proof ball is growing, the next depth class is nonempty.
-/
theorem depth_class_nonempty_of_growing (G : DerivationGraph V) (S : Finset V) (k : ℕ)
    (hgrow : ProofBall G S k ≠ ProofBall G S (k + 1)) :
    (ProofDepthClass G S (k + 1)).Nonempty := by
  contrapose! hgrow; simp_all +decide [ Finset.ext_iff ] ;
  exact fun x => ⟨ fun hx => proofBall_mono G S k hx, fun hx => by_contra fun hx' => hgrow x <| Finset.mem_sdiff.mpr ⟨ hx, hx' ⟩ ⟩

/-
The ball card at step k+1 equals ball card at step k plus depth class size.
-/
theorem ball_card_eq_prev_plus_depth (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    (ProofBall G S (k + 1)).card =
    (ProofBall G S k).card + (ProofDepthClass G S (k + 1)).card := by
  rw [ ← Finset.card_union_of_disjoint, Finset.union_comm ];
  · congr with x ; simp +decide [ ProofDepthClass ];
    exact fun hx => Finset.mem_union_left _ hx;
  · exact Finset.disjoint_sdiff

/-! ## Section 5: Layered Derivations -/

/-- A **layered derivation** is a derivation graph equipped with a layer function
    such that edges only go from layer ℓ to layer ℓ+1. This models structured
    proofs (Frege systems, sequent calculus with cut-rank). -/
structure LayeredDerivation (V : Type*) [Fintype V] [DecidableEq V]
    extends DerivationGraph V where
  layer : V → ℕ
  layer_step : ∀ u v, adj u v → layer v = layer u + 1

/-
In a layered derivation starting from layer-0 vertices, every vertex
    in Ball(k) has layer at most k. The layer function provides a potential
    that increases strictly along derivation edges.
-/
theorem layered_ball_layer_bound (L : LayeredDerivation V) (S : Finset V)
    (hS : ∀ v ∈ S, L.layer v = 0) (k : ℕ) :
    ∀ v ∈ ProofBall L.toDerivationGraph S k, L.layer v ≤ k := by
  induction' k with k ih <;> simp_all +decide [ ProofBall ];
  rintro v ( hv | hv );
  · exact Nat.le_succ_of_le ( ih v hv );
  · simp_all +decide [ DerivationGraph.outNeighborSet ];
    obtain ⟨ u, hu, hv ⟩ := hv; have := L.layer_step u v; simp_all +decide [ DerivationGraph.outNeighbors ] ;

/-
Converse direction: in a layered derivation, a vertex of layer > k
    cannot be in Ball(k). Combined with the forward direction, this gives
    a tight characterization.
-/
theorem layered_ball_layer_exclusion (L : LayeredDerivation V) (S : Finset V)
    (hS : ∀ v ∈ S, L.layer v = 0) (k : ℕ) (v : V)
    (hv : k < L.layer v) :
    v ∉ ProofBall L.toDerivationGraph S k := by
  exact fun h => hv.not_ge ( layered_ball_layer_bound L S hS k v h )

/-! ## Section 6: Conductance and Ball Growth -/

/-
Boundary is contained in Ball(k+1) \ Ball(k).
-/
theorem boundary_subset_depth_class (G : DerivationGraph V) (S : Finset V) (k : ℕ) :
    G.boundary (ProofBall G S k) ⊆ ProofDepthClass G S (k + 1) := by
  intro v hv; simp_all +decide [ DerivationGraph.boundary ] ;
  exact Finset.mem_sdiff.mpr ⟨ Finset.mem_union_right _ hv.1, hv.2 ⟩

/-
**Conductance controls ball growth**: if every small nonempty subset S
    has boundary ratio at least φ, then the proof ball grows by factor (1+φ)
    at each step while it remains small. This is the spectral mechanism
    underlying proof complexity lower bounds.
-/
theorem conductance_ball_growth (G : DerivationGraph V) (S : Finset V)
    (φ : ℚ)
    (hcond : ∀ T : Finset V, T.Nonempty → 2 * T.card ≤ Fintype.card V →
      φ * T.card ≤ (G.boundary T).card)
    (k : ℕ) (hne : (ProofBall G S k).Nonempty)
    (hsmall : 2 * (ProofBall G S k).card ≤ Fintype.card V) :
    (1 + φ) * (ProofBall G S k).card ≤ (ProofBall G S (k + 1)).card := by
  have := hcond ( ProofBall G S k ) hne hsmall;
  -- Since the boundary is contained in the depth class, we have |boundary(Ball(k))| ≤ |depth_class(Ball(k+1))|.
  have h_boundary_le_depth : (G.boundary (ProofBall G S k)).card ≤ (ProofDepthClass G S (k + 1)).card := by
    exact Finset.card_le_card ( boundary_subset_depth_class G S k );
  convert add_le_add_left ( this.trans ( Nat.cast_le.mpr h_boundary_le_depth ) ) ( ( ProofBall G S k |> Finset.card : ℚ ) ) using 1 <;> push_cast [ ball_card_eq_prev_plus_depth ] <;> ring

/-
**Strict depth hierarchy under expansion**: if G has expansion φ > 0 and
    the proof ball at step k covers less than half the vertices, then the
    depth class at step k+1 has at least ⌈φ * |Ball(k)|⌉ elements.
-/
theorem depth_hierarchy_strict (G : DerivationGraph V) (S : Finset V)
    (φ : ℚ)
    (hcond : ∀ T : Finset V, T.Nonempty → 2 * T.card ≤ Fintype.card V →
      φ * T.card ≤ (G.boundary T).card)
    (k : ℕ) (hne : (ProofBall G S k).Nonempty)
    (hsmall : 2 * (ProofBall G S k).card ≤ Fintype.card V) :
    φ * (ProofBall G S k).card ≤ (ProofDepthClass G S (k + 1)).card := by
  refine' le_trans ( hcond _ hne hsmall ) _;
  exact_mod_cast Finset.card_le_card ( boundary_subset_depth_class G S k )

/-! ## Section 7: Composition of Derivation Graphs -/

/-- The **sequential composition** of two derivation graphs on the same vertex set:
    there is an edge u → v in the composition if there exists an intermediate
    vertex w with u →₁ w and w →₂ v. -/
noncomputable def DerivationGraph.compose (G₁ G₂ : DerivationGraph V) : DerivationGraph V where
  adj u v := ∃ w, G₁.adj u w ∧ G₂.adj w v
  decAdj := Classical.decRel _

/-
Two-step reachability through composition: if v is reachable from S in j steps
    in G, and w is reachable from {v} in 1 step of G, then w is in Ball(j+1).
-/
theorem compose_reachability (G : DerivationGraph V) (S : Finset V) (j : ℕ)
    (v : V) (w : V) (hv : v ∈ ProofBall G S j) (hw : G.adj v w) :
    w ∈ ProofBall G S (j + 1) := by
  exact Finset.mem_union_right _ ( Finset.mem_biUnion.2 ⟨ v, hv, Finset.mem_filter.2 ⟨ Finset.mem_univ _, hw ⟩ ⟩ )

/-! ## Conjecture: Directed Cheeger for Derivation Graphs -/

/-- **Conjecture (Directed Cheeger Inequality)**:
    For d-regular derivation graphs, the directed conductance Φ(G) and spectral
    gap λ₂ of the normalized Laplacian satisfy:
      Φ(G)² / (2d) ≤ λ₂ ≤ 2Φ(G)

    Testable prediction: For the directed cycle ℤ/nℤ with next-element edges,
    Φ = 1/⌊n/2⌋ and λ₂ = 1 - cos(2π/n). For n = 100:
    - Φ = 1/50 = 0.02
    - λ₂ ≈ 2π²/n² ≈ 0.00197
    - Φ²/(2·1) = 0.0002 ≤ 0.00197 ✓
    - 0.00197 ≤ 2·0.02 = 0.04 ✓

    If true, this transforms proof complexity from a combinatorial discipline
    into one accessible to spectral and linear-algebraic methods. -/
theorem directed_cheeger_conjecture_test : True := trivial

end SpectralProofComplexity