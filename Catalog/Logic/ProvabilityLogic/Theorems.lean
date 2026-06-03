/-
  # Provability Logic GL — Main Theorems

  This file contains the core results of provability logic GL:

  1. **Löb's Axiom Validity**: □(□p → p) → □p is valid in all GL frames.
  2. **Gödel's Second Incompleteness Theorem (Semantic)**: A sound world
     cannot internalize its own soundness (for ⊥) without contradiction.
  3. **Tangling Dichotomy**: A sound world either has trivial provability
     (no successors) or fails to internalize its own soundness.
  4. **Reflection Hierarchy**: Each level of reflection is implied by the next.
-/

import Mathlib
import Logic.ProvabilityLogic.Defs

open Classical ProvabilityLogic

namespace ProvabilityLogic

/-! ## Löb's Axiom: □(□p → p) → □p -/

/-- **Löb's Axiom** is valid in every GL frame.
    The proof uses well-founded induction on the converse of R. -/
theorem loeb_axiom_valid (F : GLFrame) {Var : Type} (V : MValuation F.W Var)
    (φ : MFormula Var) (w : F.W)
    (h : Forces F V w (.box (.imp (.box φ) φ))) :
    Forces F V w (.box φ) := by
  intro v hwv
  revert hwv
  apply F.wf.induction (C := fun v => F.R w v → Forces F V v φ) v
  intro u ih hwu
  have hu_imp : Forces F V u (.imp (.box φ) φ) := h u hwu
  have hu_box : Forces F V u (.box φ) := by
    intro t hut
    exact ih t hut (F.trans w u t hwu hut)
  exact hu_imp hu_box

/-! ## Gödel's Second Incompleteness Theorem (Semantic Version) -/

/-- **Semantic Gödel's Second Incompleteness Theorem.**
    If a world w is sound and forces □(□⊥ → ⊥), then w forces ⊥. -/
theorem godel2_semantic (F : GLFrame) {Var : Type} (V : MValuation F.W Var)
    (w : F.W) (hsound : GLSound F V w)
    (h_int : Forces F V w (.box (.imp (.box .bot) .bot))) :
    Forces F V w .bot := by
  have h_box_bot : Forces F V w (.box .bot) := loeb_axiom_valid F V .bot w h_int
  exact hsound .bot h_box_bot

/-- **Corollary**: A sound world cannot force □(□⊥ → ⊥). -/
theorem sound_world_cannot_internalize_con (F : GLFrame) {Var : Type}
    (V : MValuation F.W Var) (w : F.W) (hsound : GLSound F V w) :
    ¬ Forces F V w (.box (.imp (.box .bot) .bot)) := by
  intro h
  exact godel2_semantic F V w hsound h

/-! ## The Tangling Dichotomy -/

/-- **Tangling Dichotomy**: Any sound world in a GL frame either
    (a) has no accessible successors (trivial provability), or
    (b) fails to internalize its own soundness. -/
theorem tangling_dichotomy (F : GLFrame) {Var : Type} (V : MValuation F.W Var)
    (w : F.W) (hsound : GLSound F V w) :
    HasNoSuccessors F w ∨ ¬ InternalizesSoundness F V w := by
  by_contra h_neg
  simp only [not_or] at h_neg
  obtain ⟨h_has_succ, h_int⟩ := h_neg
  simp only [HasNoSuccessors, not_forall, not_not] at h_has_succ
  simp only [InternalizesSoundness, not_not] at h_int
  exact sound_world_cannot_internalize_con F V w hsound (h_int .bot)

/-! ## Soundness Propagation Failure -/

/-- **Soundness is not hereditary along R.**
    If every successor of w is sound, then w has no successors.
    Equivalently: if w has a successor and is sound, some successor is not sound. -/
theorem soundness_not_hereditary (F : GLFrame) {Var : Type}
    (V : MValuation F.W Var) (w : F.W) (hsound : GLSound F V w)
    (hall : ∀ v, F.R w v → GLSound F V v) :
    HasNoSuccessors F w := by
  intro v hv
  have h_int : Forces F V w (.box (.imp (.box .bot) .bot)) := by
    intro u hwu
    exact hall u hwu .bot
  exact sound_world_cannot_internalize_con F V w hsound h_int

/-- **Corollary**: In any GL frame, if w is sound and has a successor v,
    then some successor of w is not sound. -/
theorem exists_unsound_successor (F : GLFrame) {Var : Type}
    (V : MValuation F.W Var) (w : F.W) (hsound : GLSound F V w)
    (v : F.W) (hv : F.R w v) :
    ∃ u, F.R w u ∧ ¬ GLSound F V u := by
  by_contra hall
  push_neg at hall
  exact soundness_not_hereditary F V w hsound hall v hv

/-! ## The Reflection Hierarchy -/

/-- The n-th reflection principle: iterated □(□...→...)→... -/
def reflectionFormula {Var : Type} (φ : MFormula Var) : ℕ → MFormula Var
  | 0 => φ
  | n + 1 => .imp (.box (reflectionFormula φ n)) (reflectionFormula φ n)

/-- The n-th reflection principle, boxed. -/
def boxedReflection {Var : Type} (φ : MFormula Var) (n : ℕ) : MFormula Var :=
  .box (reflectionFormula φ n)

/-- **Reflection Hierarchy**: The boxed (n+1)-th reflection implies the
    boxed n-th reflection. This is a direct consequence of Löb's axiom. -/
theorem reflection_hierarchy (F : GLFrame) {Var : Type}
    (V : MValuation F.W Var) (φ : MFormula Var) (n : ℕ) (w : F.W) :
    Forces F V w (boxedReflection φ (n + 1)) →
    Forces F V w (boxedReflection φ n) := by
  intro h
  exact loeb_axiom_valid F V (reflectionFormula φ n) w h

/-! ## K and 4 axioms -/

/-- **K axiom**: □(φ → ψ) → □φ → □ψ -/
theorem k_axiom_valid (F : GLFrame) {Var : Type} (V : MValuation F.W Var)
    (φ ψ : MFormula Var) (w : F.W)
    (h1 : Forces F V w (.box (.imp φ ψ)))
    (h2 : Forces F V w (.box φ)) :
    Forces F V w (.box ψ) := by
  intro v hwv
  exact h1 v hwv (h2 v hwv)

/-- **4 axiom**: □φ → □□φ (by transitivity of R). -/
theorem four_axiom_valid (F : GLFrame) {Var : Type} (V : MValuation F.W Var)
    (φ : MFormula Var) (w : F.W)
    (h : Forces F V w (.box φ)) :
    Forces F V w (.box (.box φ)) := by
  intro v hwv u hvu
  exact h u (F.trans w v u hwv hvu)

/-! ## Iterated Provability -/

/-- Iterated box: □ⁿφ. -/
def iteratedBox {Var : Type} (φ : MFormula Var) : ℕ → MFormula Var
  | 0 => φ
  | n + 1 => .box (iteratedBox φ n)

/-- □ⁿ⁺¹φ at w implies □ⁿφ at all successors. -/
theorem iterated_box_step (F : GLFrame) {Var : Type}
    (V : MValuation F.W Var) (φ : MFormula Var) (w : F.W) (n : ℕ) :
    Forces F V w (iteratedBox φ (n + 1)) →
    ∀ v, F.R w v → Forces F V v (iteratedBox φ n) := by
  intro h v hwv
  exact h v hwv

/-! ## Graded Tangling Theorem -/

/-
**Graded Tangling**: The n-th iterated Löb axiom.
    □ⁿ⁺¹(□p → p) → □ⁿ⁺¹p, proved by induction on n.
-/
theorem iterated_loeb (F : GLFrame) {Var : Type}
    (V : MValuation F.W Var) (φ : MFormula Var) (w : F.W) (n : ℕ) :
    Forces F V w (iteratedBox (.imp (.box φ) φ) (n + 1)) →
    Forces F V w (iteratedBox φ (n + 1)) := by
      induction' n with n ih generalizing w φ;
      · exact fun h => loeb_axiom_valid F V φ w h;
      · intro h;
        exact fun v hv => ih _ _ ( h v hv )

end ProvabilityLogic