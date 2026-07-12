/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical Product Closure for Weighted Tree Automata

This file proves that the class of tropical-recognizable tree series is closed
under pointwise tropical product (i.e., pointwise addition of costs).

## Main Results

- `productWTA`: Construction of the product automaton with state space `Q₁ × Q₂`.
- `evalState_productWTA`: The stronger state-indexed identity:
  `evalState (productWTA A₁ A₂) t (q₁, q₂) = evalState A₁ t q₁ + evalState A₂ t q₂`
- `eval_productWTA`: The global semantic identity:
  `eval (productWTA A₁ A₂) t = eval A₁ t + eval A₂ t`

## Mathematical Significance

This is the **min-plus Fubini principle** for tree runs: the optimal cost of a joint
run on a product automaton equals the sum of the optimal costs of independent runs.
The proof uses tropical distributivity — the fact that addition distributes over min
in a linearly ordered group — and a combinatorial bijection between product-state
assignments and pairs of state assignments on tree children.
-/

import Novelty.Basic

namespace TropicalTreeAutomata

variable {σ : Type*} {ar : σ → ℕ}
variable {Q₁ : Type*} [Fintype Q₁] [DecidableEq Q₁] [Nonempty Q₁]
variable {Q₂ : Type*} [Fintype Q₂] [DecidableEq Q₂] [Nonempty Q₂]

/-! ## Product Automaton Construction -/

/-- The **product automaton** of two WTAs `A₁` and `A₂`.

The state space is `Q₁ × Q₂`. The transition cost at a product state
is the sum of the individual transition costs, and similarly for final costs.
This realizes tropical multiplication (= real addition) of the two cost functions. -/
def productWTA (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂) : WTA σ ar (Q₁ × Q₂) where
  δ a qs pq := A₁.δ a (fun i => (qs i).1) pq.1 + A₂.δ a (fun i => (qs i).2) pq.2
  f pq := A₁.f pq.1 + A₂.f pq.2

/-! ## Helper Lemmas: Tropical Distributivity -/

/-
`Finset.inf'` distributes addition on the right:
  `min_s f(s) + c = min_s (f(s) + c)`
-/
theorem Finset.inf'_add_right_real {ι : Type*} (S : Finset ι) (hS : S.Nonempty)
    (g : ι → ℝ) (c : ℝ) :
    S.inf' hS g + c = S.inf' hS (fun i => g i + c) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
  · exact Finset.exists_min_image _ _ hS

/-
`Finset.inf'` distributes addition on the left:
  `c + min_s f(s) = min_s (c + f(s))`
-/
theorem Finset.inf'_add_left_real {ι : Type*} (S : Finset ι) (hS : S.Nonempty)
    (g : ι → ℝ) (c : ℝ) :
    c + S.inf' hS g = S.inf' hS (fun i => c + g i) := by
  -- Since the infimum of a set is the greatest lower bound, adding a constant to each element of the set shifts the infimum by that constant.
  have h_inf_shift : ∀ (s : Finset ι) (hs : s.Nonempty) (g : ι → ℝ) (c : ℝ), c + s.inf' hs g = s.inf' hs (fun i => c + g i) := by
    intros s hs g c;
    refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
    · exact Finset.exists_min_image _ _ hs;
  exact h_inf_shift S hS g c

/-
**Min-plus Fubini**: minimum over a product factors as sum of minima.
  `min_{(a,b)} (u(a) + v(b)) = min_a u(a) + min_b v(b)`
-/
theorem Finset.inf'_product_add_real {α β : Type*} [DecidableEq α] [DecidableEq β]
    (A : Finset α) (B : Finset β)
    (hA : A.Nonempty) (hB : B.Nonempty)
    (u : α → ℝ) (v : β → ℝ) :
    (A ×ˢ B).inf' (hA.product hB) (fun p => u p.1 + v p.2) =
    A.inf' hA u + B.inf' hB v := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · obtain ⟨ a, ha ⟩ := Finset.exists_mem_eq_inf' hA u;
    obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_inf' hB v; use a, b; aesop;
  · exact fun a b ha hb => add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ hb )

/-
The bijection between `Fin n → Q₁ × Q₂` and `(Fin n → Q₁) × (Fin n → Q₂)` preserves
the infimum structure. This is the combinatorial heart of the product theorem for trees.
-/
theorem inf'_piProd_eq {n : ℕ}
    (g : (Fin n → Q₁ × Q₂) → ℝ)
    (h : ∀ qs, g qs = g (fun i => ((fun i => (qs i).1) i, (fun i => (qs i).2) i))) :
    Finset.univ.inf' Finset.univ_nonempty g =
    Finset.univ.inf' Finset.univ_nonempty (fun qs₁ : Fin n → Q₁ =>
      Finset.univ.inf' Finset.univ_nonempty (fun qs₂ : Fin n → Q₂ =>
        g (fun i => (qs₁ i, qs₂ i)))) := by
  refine' le_antisymm _ _;
  · simp +decide [ Finset.le_inf'_iff ];
    exact fun _ _ => ⟨ _, le_rfl ⟩;
  · simp +decide [ Finset.inf'_le ];
    exact fun qs => ⟨ fun i => ( qs i ).1, fun i => ( qs i ).2, le_of_eq ( h qs |> Eq.symm ) ⟩

/-! ## Core Theorem A: State-indexed product identity -/

/-
**Tropical product theorem (state-indexed).**

For every tree `t` and product state `(q₁, q₂)`:
  `evalState (productWTA A₁ A₂) t (q₁, q₂) = evalState A₁ t q₁ + evalState A₂ t q₂`

This is the min-plus Fubini principle: independent cost optimization on paired runs
decomposes additively. The proof is by structural induction on the tree.
-/
theorem evalState_productWTA
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RankedTree σ ar) (q₁ : Q₁) (q₂ : Q₂) :
    (productWTA A₁ A₂).evalState t (q₁, q₂) =
    A₁.evalState t q₁ + A₂.evalState t q₂ := by
  induction' t with a children ih generalizing q₁ q₂;
  rw [ WTA.evalState_node, WTA.evalState_node, WTA.evalState_node ];
  simp +decide only [ih];
  rw [ ← Finset.inf'_product_add_real ];
  unfold productWTA; simp +decide [ Finset.sum_add_distrib, add_assoc ] ;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun a b => ⟨ fun i => ( a i, b i ), by simp +decide [ add_comm, add_left_comm, add_assoc ] ⟩;
  · exact fun b => ⟨ fun i => ( b i ).1, fun i => ( b i ).2, by simp +decide [ add_comm, add_left_comm, add_assoc ] ⟩

/-! ## Core Theorem A: Global product identity -/

/-
**Tropical product closure theorem.**

For every tree `t`:
  `eval (productWTA A₁ A₂) t = eval A₁ t + eval A₂ t`

The semantics of the product automaton equals the pointwise sum (tropical product)
of the individual semantics. This follows from the state-indexed theorem
and the min-plus Fubini principle on the final-state costs.
-/
theorem eval_productWTA
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RankedTree σ ar) :
    (productWTA A₁ A₂).eval t = A₁.eval t + A₂.eval t := by
  convert Finset.inf'_product_add_real ( Finset.univ : Finset Q₁ ) ( Finset.univ : Finset Q₂ ) Finset.univ_nonempty Finset.univ_nonempty ( fun q1 => A₁.evalState t q1 + A₁.f q1 ) ( fun q2 => A₂.evalState t q2 + A₂.f q2 ) using 1;
  unfold WTA.eval; congr; ext; simp +decide [ add_assoc ] ;
  rename_i q; rw [ evalState_productWTA ] ; simp +decide [ add_assoc, productWTA ] ;
  ring

/-! ## Stretch: State Complexity -/

/-
The product automaton has exactly `|Q₁| × |Q₂|` states.
-/
theorem card_productWTA_states :
    Fintype.card (Q₁ × Q₂) = Fintype.card Q₁ * Fintype.card Q₂ := by
  convert Fintype.card_prod Q₁ Q₂

/-! ## Stretch: Monotonicity -/

/-
If `A₁` dominates `A₁'` and `A₂` dominates `A₂'` pointwise,
then the product of the dominating automata dominates the product of the dominated.
-/
theorem eval_productWTA_mono
    (A₁ A₁' : WTA σ ar Q₁) (A₂ A₂' : WTA σ ar Q₂)
    (h₁ : ∀ t, A₁.eval t ≤ A₁'.eval t)
    (h₂ : ∀ t, A₂.eval t ≤ A₂'.eval t)
    (t : RankedTree σ ar) :
    (productWTA A₁ A₂).eval t ≤ (productWTA A₁' A₂').eval t := by
  rw [ eval_productWTA, eval_productWTA ];
  exact add_le_add ( h₁ t ) ( h₂ t )

end TropicalTreeAutomata