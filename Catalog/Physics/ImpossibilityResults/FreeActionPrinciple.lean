/-
# Free actions and symmetry-breaking impossibility

This file extracts a precise theorem from the proposed unification.  A
"symmetric distinguishing task" asks for an injective observable which is
invariant under a group action.  The chain below proves that such a task is
solvable exactly for a trivial action.  Consequently every free action of a
nontrivial group makes the task impossible.

This also records the necessary correction to the proposed biconditional:
freeness is sufficient, but not necessary, for this particular obstruction.
The exact condition is that the action moves at least one point.
-/
import Mathlib

namespace FreeActionPrinciple

universe u v w

variable {G : Type u} {X : Type v} [Group G] [MulAction G X]

/-- An observable respects the symmetry when it is constant on every orbit. -/
def IsInvariant {Y : Type w} (f : X → Y) : Prop :=
  ∀ (g : G) (x : X), f (g • x) = f x

/-- The symmetry-breaking distinguishing task is solvable when some invariant
observable nevertheless distinguishes all points. -/
def DistinguishingTaskSolvable : Prop :=
  ∃ (Y : Type (max u v)) (f : X → Y),
    IsInvariant (G := G) (X := X) f ∧ Function.Injective f

/-- The standard pointwise formulation of a free action. -/
def IsFreeAction : Prop :=
  ∀ (g : G) (x : X), g • x = x → g = 1

/-
First link: if an invariant observable is injective, every orbit is a
singleton.  This is the basic collision obstruction: invariance identifies a
point with every translate, while injectivity forces those points to coincide.
-/
theorem invariant_injective_forces_fixed {Y : Type w} {f : X → Y}
    (hf : IsInvariant (G := G) (X := X) f)
    (hinj : Function.Injective f) (g : G) (x : X) :
    g • x = x := by
  exact hinj (hf g x)

/-
Third link: the distinguishing task is solvable exactly when the action is
trivial.  This identifies the sharp obstruction; it is weaker than freeness.
-/
theorem distinguishingTaskSolvable_iff_trivialAction :
    DistinguishingTaskSolvable (G := G) (X := X) ↔
      ∀ (g : G) (x : X), g • x = x := by
  constructor
  · rintro ⟨Y, f, hf, hinj⟩ g x
    exact invariant_injective_forces_fixed hf hinj g x
  · intro h
    refine ⟨ULift X, fun x => ⟨x⟩, ?_, ?_⟩
    · intro g x
      simp only [h]
    · intro x y hxy
      simpa using hxy

/-
Fourth link: one genuinely moved point already makes symmetric
point-distinguishing impossible.
-/
theorem moved_point_makes_task_impossible
    (hmove : ∃ (g : G) (x : X), g • x ≠ x) :
    ¬ DistinguishingTaskSolvable (G := G) (X := X) := by
  intro hsolvable
  obtain ⟨g, x, hne⟩ := hmove
  exact hne (distinguishingTaskSolvable_iff_trivialAction.mp hsolvable g x)

/-
Fifth link: this is the exact obstruction theorem.  Impossibility of the
symmetric distinguishing task is equivalent to the existence of a moved
point, not to freeness of the action.
-/
theorem distinguishingTask_impossible_iff_movedPoint :
    (¬ DistinguishingTaskSolvable (G := G) (X := X)) ↔
      ∃ (g : G) (x : X), g • x ≠ x := by
  grind +suggestions

/-
Sixth link (the requested converse direction in a precise task model): a
free action by a nontrivial group supplies a moved point, hence supplies an
impossible equivariant/invariant distinguishing task.
-/
theorem free_nontrivial_action_makes_task_impossible
    [Nonempty X] [Nontrivial G]
    (hfree : IsFreeAction (G := G) (X := X)) :
    ¬ DistinguishingTaskSolvable (G := G) (X := X) := by
  apply moved_point_makes_task_impossible
  obtain ⟨g, hg⟩ := exists_ne (1 : G)
  let x : X := Classical.choice inferInstance
  exact ⟨g, x, fun hfix => hg (hfree g x hfix)⟩

/-
Seventh link: the regular action is free, so every nontrivial group carries a
canonical instance of the obstruction on its underlying set.
-/
theorem regular_action_makes_task_impossible
    {H : Type u} [Group H] [Nontrivial H] :
    ¬ DistinguishingTaskSolvable (G := H) (X := H) := by
  apply free_nontrivial_action_makes_task_impossible
  intro g x hfix
  rw [smul_eq_mul] at hfix
  exact mul_right_cancel (hfix.trans (one_mul x).symm)

/-
Eighth link: the symmetric group on five letters gives a concrete finite
instance.  This is only the symmetry-breaking kernel, not a formalization of
Abel--Ruffini.
-/
theorem perm_five_regular_task_impossible :
    ¬ DistinguishingTaskSolvable
      (G := Equiv.Perm (Fin 5)) (X := Equiv.Perm (Fin 5)) := by
  exact regular_action_makes_task_impossible

/-
Ninth link: the natural action of the symmetric group on three letters has a
moved point.  This starts a concrete test of the proposed necessity of
freeness, rather than merely asserting in prose that necessity fails.
-/
theorem perm_three_natural_action_has_moved_point :
    ∃ (g : Equiv.Perm (Fin 3)) (x : Fin 3), g • x ≠ x := by
  refine ⟨Equiv.swap 0 1, 0, ?_⟩
  simp

/-
Tenth link: nevertheless, this action is not free.  The transposition of zero
and one fixes the third letter, despite not being the identity permutation.
-/
theorem perm_three_natural_action_not_free :
    ¬ IsFreeAction (G := Equiv.Perm (Fin 3)) (X := Fin 3) := by
  intro hfree
  have hfix :
      (Equiv.swap (0 : Fin 3) 1 : Equiv.Perm (Fin 3)) • (2 : Fin 3) = 2 := by
    apply Equiv.swap_apply_of_ne_of_ne
    · decide
    · decide
  have hid := hfree (Equiv.swap 0 1) 2 hfix
  have hpoint := DFunLike.congr_fun hid (0 : Fin 3)
  simp at hpoint

/-
Final link: combining the moved point with the exact obstruction theorem gives
an explicit nonfree action whose distinguishing task is impossible.  Hence
freeness is not necessary for this impossibility result.
-/
theorem perm_three_nonfree_task_impossible :
    ¬ DistinguishingTaskSolvable
      (G := Equiv.Perm (Fin 3)) (X := Fin 3) := by
  exact moved_point_makes_task_impossible
    perm_three_natural_action_has_moved_point

end FreeActionPrinciple