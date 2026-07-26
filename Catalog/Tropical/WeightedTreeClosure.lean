/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Closure Properties for Weighted Tree Automata

This file establishes closure of tropical-recognizable tree series under
pointwise tropical product (min-plus addition) and finite infimum (union).

The key result is a **min-plus Fubini principle for tree runs**: when two
independent weighted tree automata process the same tree, the optimal combined
cost (minimized over product runs) equals the sum of the independently optimal
costs. This identity is the compositional heart of tropical tree semantics.

## Main definitions

* `RTree` — ranked trees over a signature with arity function
* `WTA` — weighted bottom-up tree automaton with real-valued costs
* `evalState` — state-indexed minimum cost of processing a tree
* `eval` — global minimum cost (over final states) of processing a tree
* `productAutomaton` — product construction for tropical product closure

## Main results

* `evalState_productAutomaton` — statewise product closure
* `eval_productAutomaton` — tropical product closure
* `eval_min_eq_inf'_sum` — union closure at the eval level
* `eval_finset_inf` — finite family infimum closure
* `card_product_states` / `card_sum_states` — state complexity bounds
* `eval_productAutomaton_mono` — monotonicity under pointwise domination
-/

import Mathlib

noncomputable section

open Finset BigOperators

namespace TropicalTreeAutomata

/-! ## Ranked Trees -/

/-- Ranked trees over a signature `σ` with arity function.
    Each node carries a symbol `a : σ` and has exactly `arity a` children. -/
inductive RTree (σ : Type*) (arity : σ → ℕ) : Type _
  | node (a : σ) (children : Fin (arity a) → RTree σ arity) : RTree σ arity

/-! ## Weighted Tree Automata -/

/-- A weighted bottom-up tree automaton over ranked trees with real-valued costs. -/
structure WTA (σ : Type*) (arity : σ → ℕ) (Q : Type*) where
  /-- Transition cost: given a symbol, child state assignment, and target state -/
  stepCost : (a : σ) → (Fin (arity a) → Q) → Q → ℝ
  /-- Final/acceptance cost for each state -/
  finalCost : Q → ℝ

variable {σ : Type*} {arity : σ → ℕ}

/-! ## Semantics -/

/-- State-indexed evaluation: minimum cost to process tree `t` and arrive at
    state `q`, computed by dynamic programming (structural recursion on trees). -/
noncomputable def evalState {Q : Type*} [Fintype Q] [Nonempty Q]
    (A : WTA σ arity Q) : RTree σ arity → Q → ℝ
  | .node a children, q =>
    Finset.univ.inf' Finset.univ_nonempty
      fun f => A.stepCost a f q + ∑ i : Fin (arity a), evalState A (children i) (f i)

/-- Global evaluation: minimum total cost over all root states. -/
noncomputable def eval {Q : Type*} [Fintype Q] [Nonempty Q]
    (A : WTA σ arity Q) (t : RTree σ arity) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty
    fun q => evalState A t q + A.finalCost q

@[simp]
theorem evalState_node {Q : Type*} [Fintype Q] [Nonempty Q]
    (A : WTA σ arity Q) (a : σ) (children : Fin (arity a) → RTree σ arity) (q : Q) :
    evalState A (.node a children) q =
    Finset.univ.inf' Finset.univ_nonempty
      fun f => A.stepCost a f q + ∑ i, evalState A (children i) (f i) := by
  rfl

/-! ## Product Automaton Construction -/

/-- Product automaton for tropical product closure. -/
def productAutomaton {Q₁ Q₂ : Type*}
    (A₁ : WTA σ arity Q₁) (A₂ : WTA σ arity Q₂) :
    WTA σ arity (Q₁ × Q₂) where
  stepCost a f q :=
    A₁.stepCost a (Prod.fst ∘ f) q.1 + A₂.stepCost a (Prod.snd ∘ f) q.2
  finalCost q := A₁.finalCost q.1 + A₂.finalCost q.2

/-! ## Helper Lemmas -/

/-
Min-plus Fubini: the infimum over a product of the sum of independent functions
    equals the sum of independent infima.
-/
theorem inf'_add_inf'_eq_inf'_prod
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (f : α → ℝ) (g : β → ℝ) :
    Finset.univ.inf' Finset.univ_nonempty f +
      Finset.univ.inf' Finset.univ_nonempty g =
    (Finset.univ : Finset (α × β)).inf' Finset.univ_nonempty
      (fun p => f p.1 + g p.2) := by
  -- Apply the Min-plus Fubini principle to the functions on the product.
  apply Eq.symm;
  refine' le_antisymm _ _;
  · obtain ⟨ a, ha ⟩ := Finset.exists_min_image Finset.univ ( fun x => f x ) ⟨ Classical.arbitrary α, Finset.mem_univ _ ⟩;
    obtain ⟨ b, hb ⟩ := Finset.exists_min_image Finset.univ ( fun x => g x ) ⟨ Classical.arbitrary β, Finset.mem_univ _ ⟩;
    refine' le_trans ( Finset.inf'_le _ ( Finset.mem_univ ( a, b ) ) ) _;
    exact add_le_add ( Finset.le_inf' _ _ fun x hx => ha.2 x hx ) ( Finset.le_inf' _ _ fun x hx => hb.2 x hx );
  · simp +decide [ Finset.inf'_le_iff ];
    exact fun a b => add_le_add ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) )

/-
`Finset.inf'` is invariant under composition with an equivalence.
-/
theorem inf'_comp_equiv
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (e : α ≃ β) (f : β → ℝ) :
    Finset.univ.inf' Finset.univ_nonempty (f ∘ e) =
    Finset.univ.inf' Finset.univ_nonempty f := by
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · exact fun b => ⟨ e.symm b, by simp +decide ⟩;
  · exact fun b => ⟨ e b, le_rfl ⟩

/-! ## Product Closure Theorem -/

/-
**Statewise tropical product closure theorem.**
-/
theorem evalState_productAutomaton
    {Q₁ Q₂ : Type*} [Fintype Q₁] [Nonempty Q₁] [Fintype Q₂] [Nonempty Q₂]
    (A₁ : WTA σ arity Q₁) (A₂ : WTA σ arity Q₂)
    (t : RTree σ arity) (q₁ : Q₁) (q₂ : Q₂) :
    evalState (productAutomaton A₁ A₂) t (q₁, q₂) =
    evalState A₁ t q₁ + evalState A₂ t q₂ := by
  induction' t with a children ih generalizing q₁ q₂;
  convert inf'_add_inf'_eq_inf'_prod _ _ using 2;
  convert inf'_comp_equiv _ _ |> Eq.symm;
  convert inf'_add_inf'_eq_inf'_prod _ _;
  rotate_left;
  exact ( Fin ( arity a ) → Q₁ );
  exact ( Fin ( arity a ) → Q₂ );
  all_goals try infer_instance;
  exact fun f => A₁.stepCost a f q₁ + ∑ i, evalState A₁ ( children i ) ( f i );
  exact fun f => A₂.stepCost a f q₂ + ∑ i, evalState A₂ ( children i ) ( f i );
  exact?;
  · convert inf'_add_inf'_eq_inf'_prod _ _ using 2;
    · exact ⟨ fun _ => q₁ ⟩;
    · exact ⟨ fun _ => q₂ ⟩;
  · simp +decide [ add_assoc, ih ];
    simp +decide [ productAutomaton, Finset.sum_add_distrib, add_assoc, add_left_comm, add_comm ];
    ring!

/-
**Tropical product closure theorem.**
-/
theorem eval_productAutomaton
    {Q₁ Q₂ : Type*} [Fintype Q₁] [Nonempty Q₁] [Fintype Q₂] [Nonempty Q₂]
    (A₁ : WTA σ arity Q₁) (A₂ : WTA σ arity Q₂)
    (t : RTree σ arity) :
    eval (productAutomaton A₁ A₂) t =
    eval A₁ t + eval A₂ t := by
  unfold eval;
  convert inf'_add_inf'_eq_inf'_prod _ _ |> Eq.symm using 2;
  · rw [ evalState_productAutomaton ] ; ring!;
    unfold productAutomaton; ring;
  · infer_instance;
  · infer_instance

/-! ## Union / Infimum Closure -/

/-
The infimum over `Q₁ ⊕ Q₂` of a case-split function equals the
    minimum of the two component infima.
-/
theorem inf'_sum_eq_min
    {Q₁ Q₂ : Type*} [Fintype Q₁] [Nonempty Q₁] [Fintype Q₂] [Nonempty Q₂]
    (f : Q₁ → ℝ) (g : Q₂ → ℝ) :
    (Finset.univ : Finset (Q₁ ⊕ Q₂)).inf' Finset.univ_nonempty
      (fun q => match q with
        | .inl q₁ => f q₁
        | .inr q₂ => g q₂) =
    min (Finset.univ.inf' Finset.univ_nonempty f)
        (Finset.univ.inf' Finset.univ_nonempty g) := by
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · grind +splitIndPred;
  · exact ⟨ fun a => Or.inl ⟨ a, le_rfl ⟩, fun b => Or.inr ⟨ b, le_rfl ⟩ ⟩

/-- **Union closure at the evaluation level.** -/
theorem eval_min_eq_inf'_sum
    {Q₁ Q₂ : Type*} [Fintype Q₁] [Nonempty Q₁] [Fintype Q₂] [Nonempty Q₂]
    (A₁ : WTA σ arity Q₁) (A₂ : WTA σ arity Q₂)
    (t : RTree σ arity) :
    min (eval A₁ t) (eval A₂ t) =
    (Finset.univ : Finset (Q₁ ⊕ Q₂)).inf' Finset.univ_nonempty
      (fun q => match q with
        | .inl q₁ => evalState A₁ t q₁ + A₁.finalCost q₁
        | .inr q₂ => evalState A₂ t q₂ + A₂.finalCost q₂) := by
  exact (inf'_sum_eq_min _ _).symm

/-! ## Finite Family Closure -/

/-
**Finite family infimum closure.**
-/
theorem eval_finset_inf
    {ι : Type*} [DecidableEq ι]
    {Q : ι → Type*} [∀ i, Fintype (Q i)] [∀ i, Nonempty (Q i)]
    (I : Finset ι) (hI : I.Nonempty)
    (A : ∀ i, WTA σ arity (Q i))
    (t : RTree σ arity) :
    I.inf' hI (fun i => eval (A i) t) =
    (I.sigma (fun i => Finset.univ)).inf'
      (by obtain ⟨i, hi⟩ := hI
          exact ⟨⟨i, Classical.arbitrary (Q i)⟩,
                 Finset.mem_sigma.mpr ⟨hi, Finset.mem_univ _⟩⟩)
      (fun p => evalState (A p.1) t p.2 + (A p.1).finalCost p.2) := by
  have h_inf' : ∀ i ∈ I, eval (A i) t = Finset.univ.inf' Finset.univ_nonempty (fun q => evalState (A i) t q + (A i).finalCost q) := by
    exact fun i a => rfl;
  refine' le_antisymm _ _ <;> simp_all +decide;
  · exact fun b hb => ⟨ b.1, hb, b.2, le_rfl ⟩;
  · exact fun i hi q => ⟨ i, hi, q, le_rfl ⟩

/-! ## State Complexity Bounds -/

/-- Product automaton state complexity is multiplicative. -/
theorem card_product_states
    (Q₁ Q₂ : Type*) [Fintype Q₁] [Fintype Q₂] :
    Fintype.card (Q₁ × Q₂) = Fintype.card Q₁ * Fintype.card Q₂ :=
  Fintype.card_prod Q₁ Q₂

/-- Union automaton state complexity is additive. -/
theorem card_sum_states
    (Q₁ Q₂ : Type*) [Fintype Q₁] [Fintype Q₂] :
    Fintype.card (Q₁ ⊕ Q₂) = Fintype.card Q₁ + Fintype.card Q₂ :=
  Fintype.card_sum

/-! ## Monotonicity -/

/-- **Monotonicity of product under pointwise domination.** -/
theorem eval_productAutomaton_mono
    {Q₁ Q₂ : Type*} [Fintype Q₁] [Nonempty Q₁] [Fintype Q₂] [Nonempty Q₂]
    (A₁ A₁' : WTA σ arity Q₁) (A₂ A₂' : WTA σ arity Q₂)
    (h₁ : ∀ t, eval A₁ t ≤ eval A₁' t)
    (h₂ : ∀ t, eval A₂ t ≤ eval A₂' t)
    (t : RTree σ arity) :
    eval (productAutomaton A₁ A₂) t ≤
    eval (productAutomaton A₁' A₂') t := by
  rw [eval_productAutomaton, eval_productAutomaton]
  exact add_le_add (h₁ t) (h₂ t)

end TropicalTreeAutomata