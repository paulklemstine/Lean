/-! # CatalogBuild.Speculative.Consciousness.StrangeLoopAlgebra

Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 14
-/

import Mathlib

noncomputable section

/-- Non-trivial: at least 2 distinct levels. -/
def StrangeLoop.isNontrivial (L : StrangeLoop) : Prop :=
  ∃ a b : L.Level, a ≠ b




/-- The orbit of a level under next. -/
def StrangeLoop.orbit (L : StrangeLoop) (l : L.Level) : Set L.Level :=
  { l' | ∃ k : ℕ, L.next^[k] l = l' }




/-- [Section: # CatalogBuild.Speculative.Consciousness.StrangeLoopAlgebra
Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 14] -/
theorem StrangeLoop.self_in_orbit (L : StrangeLoop) (l : L.Level) :
    l ∈ L.orbit l := ⟨0, rfl⟩




/-- [Section: # CatalogBuild.Speculative.Consciousness.StrangeLoopAlgebra
Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 14] -/
theorem StrangeLoop.orbit_closed (L : StrangeLoop) (l l' : L.Level)
    (h : l' ∈ L.orbit l) : L.next l' ∈ L.orbit l := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k + 1, by rw [iterate_succ_apply', hk]⟩




def strangeLoopPerm (L : StrangeLoop) [Fintype L.Level] [DecidableEq L.Level]
    (hinj : Injective L.next) : Equiv.Perm L.Level :=
  Equiv.ofBijective L.next ⟨hinj, Finite.surjective_of_injective hinj⟩




def TangledHierarchy.entangled (T : TangledHierarchy) (i j : ℕ) : Prop :=
  ∃ k, ∀ l, (T.loops i ∘ T.loops j)^[k] l = l




def addLayer {α : Type*} (s : SelfRef α) (f : α → α) : SelfRef α :=
  ⟨f s.val, s.depth + 1⟩




theorem addLayer_depth_increases {α : Type*} (s : SelfRef α) (f : α → α) :
    (addLayer s f).depth = s.depth + 1 := rfl




theorem strange_loop_composition_fixed_point
    {α : Type*} (f g : α → α)
    (hf_fp : ∃ a, f a = a)
    (hg_preserves : ∀ a, f a = a → f (g a) = g a) :
    ∃ a, f a = a ∧ f (g a) = g a := by
  obtain ⟨a, ha⟩ := hf_fp
  exact ⟨a, ha, hg_preserves a ha⟩




structure GodelHofstadterLoop where
  Statement : Type*
  isTheorem : Statement → Prop
  encode : Statement → ℕ
  diagonal : (ℕ → Prop) → Statement
  diag_spec : ∀ P, isTheorem (diagonal P) ↔ P (encode (diagonal P))




/-- The Gödel sentence. -/
def GodelHofstadterLoop.godelSentence (G : GodelHofstadterLoop) : G.Statement :=
  G.diagonal (fun _ => False)




/-- The Gödel sentence is unprovable. -/
theorem godel_unprovable (G : GodelHofstadterLoop) :
    ¬ G.isTheorem G.godelSentence := by
  intro hT
  rw [GodelHofstadterLoop.godelSentence, G.diag_spec] at hT
  exact hT




structure CategoricalConsciousness where
  Ob : Type*
  Mor : Ob → Ob → Type*
  reflect : Ob → Ob
  awareness : (a : Ob) → Mor (reflect a) a
  coherence : (a : Ob) → Mor (reflect (reflect a)) (reflect a)




structure CategoricalStrangeLoop (C : CategoricalConsciousness) where
  start : C.Ob
  steps : ℕ
  step_pos : 0 < steps
  path : Fin steps → C.Ob
  path_start : path ⟨0, step_pos⟩ = start

end


end


end


end
