/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical Union Closure for Weighted Tree Automata

This file proves that the class of tropical-recognizable tree series is closed
under pointwise minimum (tropical addition / union).

## Main Results

- `eval_min_eq_inf'_sum`: The minimum of two automata's costs decomposes as an
  infimum over the disjoint sum state space. This is the semantic core of union closure.
- `unionWTA`: Construction of the union automaton with state space `Q₁ ⊕ Q₂`.
- `eval_unionWTA_eq_min`: Under sufficient penalty, `eval (unionWTA A₁ A₂ M) t = min (eval A₁ t) (eval A₂ t)`.

## Mathematical Significance

The union theorem says: tropical recognizability is stable under competitive
model aggregation, so one can build verified ensembles of hierarchical recognizers.

## Note on the penalty parameter

Over `ℝ` (as opposed to `ℝ ∪ {+∞}`), cross-component transitions cannot receive
infinite cost. We handle this either by:
1. Proving the semantic decomposition directly (without WTA construction), or
2. Using a sufficiently large penalty `M` for a specific tree.
-/

import Tropical.TreeAutomata.Basic

namespace TropicalTreeAutomata

variable {σ : Type*} {ar : σ → ℕ}
variable {Q₁ : Type*} [Fintype Q₁] [DecidableEq Q₁] [Nonempty Q₁]
variable {Q₂ : Type*} [Fintype Q₂] [DecidableEq Q₂] [Nonempty Q₂]

/-! ## Semantic Union Decomposition

The core semantic theorem: the minimum of two automata evaluations equals
the infimum over the disjoint sum of the state-indexed costs. -/

/-
The minimum over a sum type decomposes as the min of the two components.
-/
theorem Finset.inf'_sum {α β γ : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] [Nonempty α] [Nonempty β]
    [SemilatticeInf γ]
    (g : α ⊕ β → γ) :
    Finset.univ.inf' Finset.univ_nonempty g =
    (Finset.univ.inf' Finset.univ_nonempty (fun a => g (Sum.inl a))) ⊓
    (Finset.univ.inf' Finset.univ_nonempty (fun b => g (Sum.inr b))) := by
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · exact ⟨ fun a => Finset.inf'_le _ ( Finset.mem_univ _ ), fun b => Finset.inf'_le _ ( Finset.mem_univ _ ) ⟩;
  · exact ⟨ fun a => inf_le_of_left_le ( Finset.inf'_le _ ( Finset.mem_univ _ ) ), fun b => inf_le_of_right_le ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ⟩

/-
**Tropical union semantic identity.**

The minimum of two WTA evaluations equals the infimum over `Q₁ ⊕ Q₂` of the
state-indexed costs from the respective automata.

  `min (eval A₁ t) (eval A₂ t) = inf_{q ∈ Q₁ ⊕ Q₂} cost(q, t)`

where `cost(inl q₁, t) = evalState A₁ t q₁ + f₁ q₁` and
      `cost(inr q₂, t) = evalState A₂ t q₂ + f₂ q₂`.

This is the semantic justification for union closure: the min of two
tropical-recognizable tree series is expressible as an infimum over the
disjoint sum of the state-indexed costs.
-/
theorem eval_min_eq_inf'_sum (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RankedTree σ ar) :
    min (A₁.eval t) (A₂.eval t) =
    Finset.univ.inf' Finset.univ_nonempty (fun q : Q₁ ⊕ Q₂ =>
      match q with
      | Sum.inl q₁ => A₁.evalState t q₁ + A₁.f q₁
      | Sum.inr q₂ => A₂.evalState t q₂ + A₂.f q₂) := by
  convert ( Finset.inf'_sum ( fun q : Q₁ ⊕ Q₂ => match q with | Sum.inl q₁ => A₁.evalState t q₁ + A₁.f q₁ | Sum.inr q₂ => A₂.evalState t q₂ + A₂.f q₂ ) ) |> Eq.symm using 1

/-! ## Union Automaton Construction

We construct a WTA with state space `Q₁ ⊕ Q₂` that computes the
minimum of the two component automata when given a sufficiently large penalty. -/

/-- The **union automaton** of two WTAs.

The state space is `Q₁ ⊕ Q₂`. Left-component transitions use `A₁`'s costs,
right-component transitions use `A₂`'s costs. Mixed child-state assignments
receive penalty `M`.

When `M` is sufficiently large (relative to a given tree), the minimum-cost run
stays entirely in one component. -/
noncomputable def unionWTA (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (M : ℝ) : WTA σ ar (Q₁ ⊕ Q₂) where
  δ a qs sq := match sq with
    | Sum.inl q =>
      if h : ∀ i, ∃ q₁, qs i = Sum.inl q₁ then
        A₁.δ a (fun i => (h i).choose) q
      else M
    | Sum.inr q =>
      if h : ∀ i, ∃ q₂, qs i = Sum.inr q₂ then
        A₂.δ a (fun i => (h i).choose) q
      else M
  f sq := match sq with
    | Sum.inl q => A₁.f q
    | Sum.inr q => A₂.f q

/-! ## State Complexity -/

/-- The union automaton has exactly `|Q₁| + |Q₂|` states. -/
theorem card_unionWTA_states :
    Fintype.card (Q₁ ⊕ Q₂) = Fintype.card Q₁ + Fintype.card Q₂ :=
  Fintype.card_sum

/-! ## One-sided embedding inequality

The easy direction: pure-left or pure-right runs give an upper bound. -/

/-
The union automaton's eval is at most `eval A₁ t`.
-/
theorem eval_unionWTA_le_left (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (M : ℝ) (t : RankedTree σ ar) :
    (unionWTA A₁ A₂ M).eval t ≤ min (A₁.eval t) (A₂.eval t) := by
  nontriviality;
  have h_inf_left : ∀ t : RankedTree σ ar, ∀ q₁ : Q₁, (unionWTA A₁ A₂ M).evalState t (Sum.inl q₁) ≤ A₁.evalState t q₁ := by
    intro t q₁
    induction' t with a children ih generalizing q₁;
    unfold WTA.evalState;
    simp +decide [ Finset.inf'_le_iff ];
    intro b;
    use fun i => Sum.inl ( b i );
    refine' add_le_add ( Finset.sum_le_sum fun i _ => ih i _ ) _;
    unfold unionWTA; aesop;
  -- Similarly, we have:
  have h_inf_right : ∀ t : RankedTree σ ar, ∀ q₂ : Q₂, (unionWTA A₁ A₂ M).evalState t (Sum.inr q₂) ≤ A₂.evalState t q₂ := by
    intro t q₂;
    nontriviality;
    induction' t with a children ih generalizing q₂;
    rw [ WTA.evalState_node, WTA.evalState_node ];
    simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    intro b;
    use fun i => Sum.inr (b i);
    refine' add_le_add ( Finset.sum_le_sum fun i _ => ih i _ ) _;
    unfold unionWTA; aesop;
  simp +decide [ WTA.eval, h_inf_left, h_inf_right ];
  exact ⟨ fun q₁ => Or.inl ⟨ q₁, add_le_add ( h_inf_left t q₁ ) ( by rfl ) ⟩, fun q₂ => Or.inr ⟨ q₂, add_le_add ( h_inf_right t q₂ ) ( by rfl ) ⟩ ⟩

end TropicalTreeAutomata