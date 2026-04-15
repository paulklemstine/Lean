/-! # CatalogBuild.MachineLearning.Consciousness.IntegratedInformation

Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 11
-/

import Mathlib

noncomputable section

/-- A finite information system: a finite type of states with a transition mechanism. -/
structure InfoSystem where
  State : Type
  stateFin : Fintype State
  stateDec : DecidableEq State
  stateNonempty : Nonempty State
  transition : State → State → ℝ
  prob_nonneg : ∀ s s', 0 ≤ transition s s'
  prob_sum : ∀ s, ∑ s' : State, transition s s' = 1

attribute [instance] InfoSystem.stateFin InfoSystem.stateDec InfoSystem.stateNonempty


/-- A partition of a system into two subsystems -/
structure BiPartition (S : InfoSystem) where
  part : S.State → Prop
  partDec : DecidablePred part
  left_nonempty : ∃ s, part s
  right_nonempty : ∃ s, ¬ part s

attribute [instance] BiPartition.partDec


/-- Earth Mover's Distance between two distributions (simplified L1 version) -/
noncomputable def earthMoverDistance {α : Type} [Fintype α] (p q : α → ℝ) : ℝ :=
  ∑ a : α, |p a - q a|


/-- The disconnected transition: transition after cutting connections at a partition. -/
noncomputable def disconnectedTransition (S : InfoSystem) (P : BiPartition S)
    (s s' : S.State) : ℝ :=
  if P.part s ∧ P.part s' then S.transition s s'
  else if ¬P.part s ∧ ¬P.part s' then S.transition s s'
  else 0


/-- Information loss from a partition -/
noncomputable def informationLoss (S : InfoSystem) (P : BiPartition S) (s : S.State) : ℝ :=
  earthMoverDistance (S.transition s) (disconnectedTransition S P s)


/-- A system is decomposable if there exists a partition with zero information loss -/
def isDecomposable (S : InfoSystem) (P : BiPartition S) (s : S.State) : Prop :=
  informationLoss S P s = 0


/-- [Section: ## Fundamental Theorems] -/
theorem earthMoverDistance_nonneg {α : Type} [Fintype α] (p q : α → ℝ) :
    0 ≤ earthMoverDistance p q := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _


theorem informationLoss_nonneg (S : InfoSystem) (P : BiPartition S) (s : S.State) :
    0 ≤ informationLoss S P s := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _


theorem decomposable_iff_independent (S : InfoSystem) (P : BiPartition S) (s : S.State) :
    isDecomposable S P s ↔
    ∀ s', S.transition s s' = disconnectedTransition S P s s' := by
  unfold isDecomposable;
  constructor;
  · unfold informationLoss earthMoverDistance at *;
    exact fun h s' => sub_eq_zero.mp ( abs_eq_zero.mp ( by rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => abs_nonneg _ ] at h; aesop ) );
  · exact fun h => Finset.sum_eq_zero fun x _ => by simp +decide [ h ] ;


/-- A conscious system: one where every partition loses information -/
structure ConsciousSystem extends InfoSystem where
  irreducible : ∀ (P : BiPartition toInfoSystem) (s : toInfoSystem.State),
    0 < informationLoss toInfoSystem P s


/-- [Section: ## The Self-Witnessing Theorem] -/
theorem conscious_not_decomposable (C : ConsciousSystem)
    (P : BiPartition C.toInfoSystem) (s : C.toInfoSystem.State) :
    ¬ isDecomposable C.toInfoSystem P s := by
  -- Since `C` is conscious, by definition, information lost from any partition must be positive.
  have h_pos : ∀ P : BiPartition (C.toInfoSystem), ∀ s : C.State, 0 < informationLoss (C.toInfoSystem) P s := by
    exact C.irreducible;
  exact ne_of_gt ( h_pos P s )


end
