/-
# Proof Architecture Complexity: Category-Theoretic Invariants for Proof Search

This module develops a formal theory of **proof architectures** modeled as finite
directed graphs (digraphs). Objects are proof states/goals, morphisms are admissible
proof transformations, and composable paths encode proof strategies.

## Main results

1. `finite_digraph_walk_count_le`: The number of length-`n` walks in a finite digraph
   is bounded above by `|V|^(n+1)`, establishing a universal exponential upper bound
   on proof search space size.

2. `local_branching_gives_two_distinct_walks`: Any vertex with two distinct successors
   produces at least two distinct one-step walks, giving a lower bound on search
   multiplicity from local branching.

3. `obstruction_implies_nontrivial_search_space`: A finite digraph with a branching
   obstruction has a nontrivially large walk space.

4. `product_architecture_walk_bound`: Walk counts in product architectures are bounded
   by the product of individual architecture walk counts, establishing compositionality
   of proof complexity.

These results formalize the fundamental insight that **branching in proof architectures
produces irreducible search complexity** — a bridge between category theory, automated
theorem proving, and combinatorial complexity.
-/

import Mathlib

open Fintype Finset

/-! ## Walk types and basic definitions -/

/-- A walk of length `n+1` in a digraph `E` on vertex set `V` is a function
    `Fin (n+1) → V` such that consecutive vertices are connected by edges. -/
def DigraphWalk {V : Type*} (E : V → V → Prop) (n : ℕ) : Type _ :=
  {p : Fin (n + 1) → V // ∀ i : Fin n, E (p i.castSucc) (p i.succ)}

/-- A proof architecture has a **branching obstruction** if some vertex has
    at least two distinct successors. This is the minimal local condition
    guaranteeing nontrivial proof search complexity. -/
def HasBranchingObstruction {V : Type*} (E : V → V → Prop) : Prop :=
  ∃ v w₁ w₂, w₁ ≠ w₂ ∧ E v w₁ ∧ E v w₂

/-! ## Universal upper bound on walk counts -/

noncomputable instance digraphWalkFintype {V : Type*} [Fintype V] [DecidableEq V]
    (E : V → V → Prop) [DecidableRel E] (n : ℕ) : Fintype (DigraphWalk E n) := by
  unfold DigraphWalk
  exact Subtype.fintype _

/-
**Universal upper bound**: The number of walks of length `n+1` in a finite
    digraph is at most `|V|^(n+1)`. This follows because every walk is a function
    `Fin (n+1) → V`, and the walks form a subset of all such functions.

    In the context of proof architectures, this bounds the size of the search space
    for any proof strategy of bounded length.
-/
theorem finite_digraph_walk_count_le
    {V : Type*} [Fintype V] [DecidableEq V]
    (E : V → V → Prop) [DecidableRel E] :
    ∀ n : ℕ,
      Fintype.card (DigraphWalk E n) ≤ (Fintype.card V) ^ (n + 1) := by
  -- Every walk is a function Fin (n+1) → V satisfying a predicate, so it's a subtype of Fin (n+1) → V.
  intro n
  have h_subtype : Fintype.card (DigraphWalk E n) ≤ Fintype.card (Fin (n + 1) → V) := by
    convert Fintype.card_subtype_le _;
    infer_instance;
  rwa [ Fintype.card_pi, Finset.prod_const, Finset.card_fin ] at h_subtype

/-! ## Branching lower bounds -/

/-
**Branching produces distinct walks**: If vertex `v` has two distinct successors
    `w₁` and `w₂`, then there are at least two distinct one-step walks starting at `v`.
    This is the fundamental mechanism by which local branching creates search complexity.
-/
theorem local_branching_gives_two_distinct_walks
    {V : Type*} [Fintype V] [DecidableEq V]
    (E : V → V → Prop) [DecidableRel E]
    (v w₁ w₂ : V)
    (h₁ : E v w₁) (h₂ : E v w₂) (hne : w₁ ≠ w₂) :
    2 ≤ Fintype.card {p : Fin 2 → V // p 0 = v ∧ E (p 0) (p 1)} := by
  refine' Fintype.one_lt_card_iff.mpr _;
  exact ⟨ ⟨ fun i => if i = 0 then v else w₁, rfl, h₁ ⟩, ⟨ fun i => if i = 0 then v else w₂, rfl, h₂ ⟩, fun h => hne <| by simpa using congr_fun ( Subtype.ext_iff.mp h ) 1 ⟩

/-
**Branching obstruction implies nontrivial search**: Any finite digraph with a
    branching obstruction has at least 2 walks of length 2. This packages the
    local branching result into a global architectural statement.
-/
theorem obstruction_implies_nontrivial_search_space
    {V : Type*} [Fintype V] [DecidableEq V]
    (E : V → V → Prop) [DecidableRel E]
    (hobs : HasBranchingObstruction E) :
    2 ≤ Fintype.card (DigraphWalk E 1) := by
  -- Let's obtain the two distinct vertices and their edges from the hypothesis.
  obtain ⟨v, w₁, w₂, hw₁w₂, hvw₁, hvw₂⟩ := hobs;
  refine' Fintype.one_lt_card_iff.mpr _;
  refine' ⟨ ⟨ fun i => if i = 0 then v else w₁, _ ⟩, ⟨ fun i => if i = 0 then v else w₂, _ ⟩, _ ⟩ <;> simp +decide;
  grind +locals;
  exact hvw₂;
  exact ne_of_apply_ne ( fun f => f.val 1 ) ( by simp +decide [ hw₁w₂ ] )

/-! ## Product architectures and compositional complexity -/

/-- The **product digraph** of two digraphs, where edges exist componentwise.
    This models running two proof architectures in parallel. -/
def ProductEdge {V W : Type*} (E₁ : V → V → Prop) (E₂ : W → W → Prop) :
    V × W → V × W → Prop :=
  fun p q => E₁ p.1 q.1 ∧ E₂ p.2 q.2

instance {V W : Type*} (E₁ : V → V → Prop) (E₂ : W → W → Prop)
    [DecidableRel E₁] [DecidableRel E₂] : DecidableRel (ProductEdge E₁ E₂) :=
  fun _ _ => instDecidableAnd

/-
**Compositionality of walk bounds**: The walk count in a product architecture
    is bounded by the product of individual walk counts.
-/
theorem product_architecture_walk_bound
    {V W : Type*} [Fintype V] [Fintype W] [DecidableEq V] [DecidableEq W]
    (E₁ : V → V → Prop) (E₂ : W → W → Prop)
    [DecidableRel E₁] [DecidableRel E₂] (n : ℕ) :
    Fintype.card (DigraphWalk (ProductEdge E₁ E₂) n) ≤
      Fintype.card (DigraphWalk E₁ n) * Fintype.card (DigraphWalk E₂ n) := by
  rw [ ← Fintype.card_prod ];
  refine' Fintype.card_le_of_injective ( fun x => ⟨ ⟨ fun i => x.val i |>.1, _ ⟩, ⟨ fun i => x.val i |>.2, _ ⟩ ⟩ ) fun x y h => _;
  all_goals simp_all +decide [ funext_iff, DigraphWalk ];
  · exact fun i => x.2 i |>.1;
  · exact fun i => x.2 i |>.2;
  · exact Subtype.ext ( funext fun i => Prod.ext ( h.1 i ) ( h.2 i ) )

/-! ## Entropy seed: branching degree as complexity measure -/

/-- The **branching degree** of a vertex is the number of its successors. -/
noncomputable def branchingDegree {V : Type*} [Fintype V] [DecidableEq V]
    (E : V → V → Prop) [DecidableRel E] (v : V) : ℕ :=
  Fintype.card {w : V // E v w}

/-
A vertex with branching degree ≥ 2 constitutes a branching obstruction.
-/
theorem branching_degree_ge_two_gives_obstruction
    {V : Type*} [Fintype V] [DecidableEq V]
    (E : V → V → Prop) [DecidableRel E]
    (v : V) (h : 2 ≤ branchingDegree E v) :
    HasBranchingObstruction E := by
  unfold branchingDegree at h;
  -- Since $2 \leq \text{Fintype.card} \{ w // E v w \}$, there exist two distinct elements $w₁$ and $w₂$ in $\{ w // E v w \}$.
  obtain ⟨w₁, w₂, hw₁w₂⟩ : ∃ w₁ w₂ : { w // E v w }, w₁ ≠ w₂ := by
    exact Fintype.one_lt_card_iff.1 h;
  exact ⟨ v, w₁.1, w₂.1, by aesop ⟩

/-
The walk count for one step from a fixed start vertex equals the branching degree.
-/
theorem walk_count_one_step_eq_branching_degree
    {V : Type*} [Fintype V] [DecidableEq V]
    (E : V → V → Prop) [DecidableRel E] (v : V) :
    Fintype.card {p : Fin 2 → V // p 0 = v ∧ E (p 0) (p 1)} =
      branchingDegree E v := by
  refine' Fintype.card_congr _;
  refine' Equiv.ofBijective ( fun p => ⟨ p.1 1, by simpa [ p.2.1 ] using p.2.2 ⟩ ) ⟨ fun p q h => _, fun q => _ ⟩;
  · ext i; fin_cases i <;> aesop;
  · refine' ⟨ ⟨ fun i => if i = 0 then v else q.val, _ ⟩, _ ⟩ <;> aesop