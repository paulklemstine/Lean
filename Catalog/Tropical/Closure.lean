/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Closure Properties of Tropical Definability and Recognizability

This file proves that weighted MSO-definable and tropically recognizable
cost functions are closed under the key operations of the tropical semiring.
-/

import Mathlib
import Tropical.WeightedMSO.Defs
import Tropical.WeightedMSO.Algebra

namespace TropicalMSO

open Classical

variable {α : Type} [Fintype α] [DecidableEq α]

/-! ## Closure of WMSODefinable -/

/-- `evalWith` unfolds for `and`: tropical conjunction is additive. -/
@[simp]
theorem WMSOFormula.evalWith_and (φ ψ : WMSOFormula α) (w : List α) (σ τ) :
    (WMSOFormula.and φ ψ).evalWith w σ τ = φ.evalWith w σ τ + ψ.evalWith w σ τ := by
  rfl

/-- `evalWith` unfolds for `or`: tropical disjunction is minimization. -/
@[simp]
theorem WMSOFormula.evalWith_or (φ ψ : WMSOFormula α) (w : List α) (σ τ) :
    (WMSOFormula.or φ ψ).evalWith w σ τ = φ.evalWith w σ τ ⊓ ψ.evalWith w σ τ := by
  rfl

/-- `eval` unfolds for `and`. -/
theorem WMSOFormula.eval_and (φ ψ : WMSOFormula α) (w : List α) :
    (WMSOFormula.and φ ψ).eval w = φ.eval w + ψ.eval w := by
  simp [WMSOFormula.eval]

/-- `eval` unfolds for `or`. -/
theorem WMSOFormula.eval_or (φ ψ : WMSOFormula α) (w : List α) :
    (WMSOFormula.or φ ψ).eval w = φ.eval w ⊓ ψ.eval w := by
  simp [WMSOFormula.eval]

/-
Weighted MSO-definable cost functions are closed under tropical addition.
    If `f` and `g` are definable, so is `fun w => f w + g w`.
-/
theorem wmso_closed_under_tropical_add
    (f g : List α → Weight)
    (hf : WMSODefinable f) (hg : WMSODefinable g) :
    WMSODefinable (fun w => f w + g w) := by
  obtain ⟨ φ, hφ ⟩ := hf
  obtain ⟨ ψ, hψ ⟩ := hg;
  exact ⟨ WMSOFormula.and φ ψ, funext fun w => by rw [ WMSOFormula.eval_and, hφ, hψ ] ⟩

/-
Weighted MSO-definable cost functions are closed under tropical minimum.
    If `f` and `g` are definable, so is `fun w => f w ⊓ g w`.
-/
theorem wmso_closed_under_min
    (f g : List α → Weight)
    (hf : WMSODefinable f) (hg : WMSODefinable g) :
    WMSODefinable (fun w => f w ⊓ g w) := by
  -- By definition of $WMSODefinable$, we know that there exist formulas $\varphi$ and $\psi$ such that $f = \varphi.eval$ and $g = \psi.eval$.
  obtain ⟨φ, hφ⟩ := hf
  obtain ⟨ψ, hψ⟩ := hg;
  exact ⟨ WMSOFormula.or φ ψ, by aesop ⟩

/-
The constant-zero function (always true) is weighted MSO-definable.
-/
theorem wmso_definable_zero : WMSODefinable (fun _ : List α => (0 : Weight)) := by
  exact ⟨ WMSOFormula.top, rfl ⟩

/-
The constant-⊤ function (always false) is weighted MSO-definable.
-/
theorem wmso_definable_top : WMSODefinable (fun _ : List α => (⊤ : Weight)) := by
  exact ⟨ WMSOFormula.bot, rfl ⟩

/-! ## Closure of TropicallyRecognizable -/

/-
The constant-zero function is tropically recognizable
    (a single accepting state with zero cost).
-/
theorem recognizable_zero :
    TropicallyRecognizable (fun _ : List α => (0 : Weight)) := by
  use ⟨Unit, fun _ => 0, fun _ _ _ => 0, fun _ => 0⟩;
  unfold MinPlusAutomaton.eval;
  simp +decide [ MinPlusAutomaton.runCost ]

/-
The constant-⊤ function is tropically recognizable
    (an automaton with no accepting runs).
-/
theorem recognizable_top :
    TropicallyRecognizable (fun _ : List α => (⊤ : Weight)) := by
  refine' ⟨ _, _ ⟩;
  exact { Q := PUnit, init := fun _ => ⊤, step := fun _ _ _ => ⊤, final := fun _ => ⊤ };
  unfold MinPlusAutomaton.eval;
  unfold MinPlusAutomaton.runCost; aesop;

/-
Tropically recognizable cost functions are closed under minimum.
    Uses the union automaton construction.
-/
theorem recognizable_closed_under_min
    (f g : List α → Weight)
    (hf : TropicallyRecognizable f) (hg : TropicallyRecognizable g) :
    TropicallyRecognizable (fun w => f w ⊓ g w) := by
  obtain ⟨A, hA⟩ := hf
  obtain ⟨B, hB⟩ := hg;
  use MinPlusAutomaton.union A B;
  intro w;
  refine' le_antisymm _ _;
  · simp +decide [ ← hA, ← hB, MinPlusAutomaton.eval ];
    constructor <;> intro i <;> refine' ciInf_le_of_le _ _ _ <;> norm_num [ MinPlusAutomaton.union ];
    exact fun x => Sum.inl ( i x );
    rotate_left;
    exact fun x => Sum.inr ( i x );
    · unfold MinPlusAutomaton.union; aesop;
    · unfold MinPlusAutomaton.runCost MinPlusAutomaton.union; aesop;
  · refine' le_iInf fun run => _;
    -- Consider two cases: either the run stays entirely in A or entirely in B, or it has at least one cross-transition.
    by_cases h_cross : ∃ i : Fin w.length, (run ⟨i.val, by omega⟩).isLeft ∧ (run ⟨i.val + 1, by omega⟩).isRight ∨ (run ⟨i.val, by omega⟩).isRight ∧ (run ⟨i.val + 1, by omega⟩).isLeft;
    · obtain ⟨ i, hi ⟩ := h_cross;
      unfold MinPlusAutomaton.runCost;
      rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ];
      cases h : run ⟨ i, by linarith [ Fin.is_lt i ] ⟩ <;> cases h' : run ⟨ i + 1, by linarith [ Fin.is_lt i ] ⟩ <;> simp_all +decide [ MinPlusAutomaton.union ];
    · -- Since there are no cross-transitions, the run must be entirely in A or entirely in B.
      by_cases h_left : (run ⟨0, by omega⟩).isLeft = true;
      · -- Since the run is entirely in A, we can map it to a run in A.
        obtain ⟨run_A, h_run_A⟩ : ∃ run_A : Fin (w.length + 1) → A.Q, ∀ i : Fin (w.length + 1), run i = Sum.inl (run_A i) := by
          have h_run_A : ∀ i : Fin (w.length + 1), (run i).isLeft = true := by
            intro i; induction' i using Fin.inductionOn with i IH; aesop;
            grind +suggestions;
          exact ⟨ fun i => Classical.choose ( Sum.isLeft_iff.mp ( h_run_A i ) ), fun i => Classical.choose_spec ( Sum.isLeft_iff.mp ( h_run_A i ) ) ⟩;
        simp_all +decide [ MinPlusAutomaton.runCost ];
        exact Or.inl ( hA w ▸ iInf_le _ run_A );
      · -- Since there are no cross-transitions and the run starts in B, the entire run must be in B.
        have h_run_B : ∀ i : Fin (w.length + 1), (run i).isRight = true := by
          intro i; induction i using Fin.inductionOn <;> simp_all +decide ;
          exact h_cross _ |>.2 ‹_›;
        -- Since the run is entirely in B, we can map it to a run in B.
        obtain ⟨run_B, h_run_B⟩ : ∃ run_B : Fin (w.length + 1) → B.Q, ∀ i : Fin (w.length + 1), run i = Sum.inr (run_B i) := by
          have h_run_B : ∀ i : Fin (w.length + 1), ∃ b : B.Q, run i = Sum.inr b := by
            intro i; specialize h_run_B i; cases h : run i <;> aesop;
          exact ⟨ fun i => Classical.choose ( h_run_B i ), fun i => Classical.choose_spec ( h_run_B i ) ⟩;
        simp_all +decide [ MinPlusAutomaton.runCost ];
        refine' Or.inr _;
        exact hB w ▸ iInf_le _ run_B

end TropicalMSO