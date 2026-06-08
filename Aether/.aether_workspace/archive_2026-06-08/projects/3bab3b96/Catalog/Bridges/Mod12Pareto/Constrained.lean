/-
  Mod-12 Pareto Rigidity: Constrained Voice Leading
  ===================================================

  The musically meaningful version of Pareto optimality: given source and
  target chords (as multisets of pitch classes), optimize the voice assignment
  — i.e., which voice sings which target note.

  A voice assignment σ : Fin n → Fin n assigns voice i in the source to
  sing target note σ(i). The cost is ∑ i, cycDist(source_i, target_{σ(i)}).

  A permutation σ Pareto-dominates τ if every voice moves at most as far
  under σ as under τ, and at least one voice moves strictly less.

  Key theorem: Pareto-optimal assignments are invariant under transposition.
-/
import Mathlib
import Bridges.Mod12Pareto.Defs
import Bridges.Mod12Pareto.MetricLemmas

open Finset BigOperators Equiv

/-- Cost of a voice assignment given by permutation σ: voice i moves from
    source(i) to target(σ(i)). -/
def assignmentCost (n : ℕ) (source target : Fin n → pc) (σ : Equiv.Perm (Fin n)) : ℕ :=
  ∑ i, cycDist (source i) (target (σ i))

/-- Permutation σ Pareto-dominates τ for the voice leading source → target:
    every voice is weakly closer under σ, and at least one is strictly closer. -/
def AssignmentDominates (n : ℕ) (source target : Fin n → pc)
    (σ τ : Equiv.Perm (Fin n)) : Prop :=
  (∀ i, cycDist (source i) (target (σ i)) ≤ cycDist (source i) (target (τ i))) ∧
  (∃ j, cycDist (source j) (target (σ j)) < cycDist (source j) (target (τ j)))

/-- A voice assignment τ is Pareto-optimal if no other assignment dominates it. -/
def AssignmentParetoOptimal (n : ℕ) (source target : Fin n → pc)
    (τ : Equiv.Perm (Fin n)) : Prop :=
  ¬ ∃ σ : Equiv.Perm (Fin n), AssignmentDominates n source target σ τ

/-
Assignment cost is invariant under transposition of both source and target.
-/
theorem assignmentCost_transposition_invariant
    (n : ℕ) (t : pc) (source target : Fin n → pc) (σ : Equiv.Perm (Fin n)) :
    assignmentCost n (fun i => source i + t) (fun i => target i + t) σ =
    assignmentCost n source target σ := by
  exact Finset.sum_congr rfl fun i _ => cycDist_add_right_invariant _ _ _;

/-
Assignment dominance is invariant under transposition.
-/
theorem assignmentDominates_transposition_invariant
    (n : ℕ) (t : pc) (source target : Fin n → pc) (σ τ : Equiv.Perm (Fin n)) :
    AssignmentDominates n source target σ τ ↔
    AssignmentDominates n (fun i => source i + t) (fun i => target i + t) σ τ := by
  unfold AssignmentDominates;
  simp +decide only [cycDist_add_right_invariant]

/-
**Constrained Pareto Rigidity:** Pareto-optimal voice assignments are invariant
    under transposition of both source and target chords. This is the musically
    meaningful version: the optimal way to connect voices between two chords
    depends only on the interval structure, not on absolute pitch.
-/
theorem assignmentParetoOptimal_transposition_invariant
    (n : ℕ) (t : pc) (source target : Fin n → pc) (τ : Equiv.Perm (Fin n)) :
    AssignmentParetoOptimal n source target τ ↔
    AssignmentParetoOptimal n (fun i => source i + t) (fun i => target i + t) τ := by
  unfold AssignmentParetoOptimal;
  simp +decide only [AssignmentDominates];
  simp +decide only [cycDist_add_right_invariant]

/-- The minimum voice-leading cost over all assignments is transposition-invariant. -/
theorem minAssignmentCost_transposition_invariant
    (n : ℕ) (t : pc) (source target : Fin n → pc) (σ : Equiv.Perm (Fin n)) :
    assignmentCost n (fun i => source i + t) (fun i => target i + t) σ =
    assignmentCost n source target σ :=
  assignmentCost_transposition_invariant n t source target σ

/-
Normal-form reduction for constrained voice leading: we can always normalize
    the source so that voice 0 is at pitch class 0.
-/
theorem assignmentParetoOptimal_normalize
    (source target : Fin 3 → pc) (τ : Equiv.Perm (Fin 3)) :
    AssignmentParetoOptimal 3 source target τ ↔
    AssignmentParetoOptimal 3 (fun i => source i - source 0)
      (fun i => target i - source 0) τ := by
  convert assignmentParetoOptimal_transposition_invariant 3 ( -source 0 ) source target τ using 1;
  simp +decide [ sub_eq_add_neg ]