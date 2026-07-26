import Mathlib

/-! # The Space of Conscious States: Knaster–Tarski for Self-Models

`LawvereFixedPoint.lean` shows, via the diagonal argument, that a sufficiently
rich self-model *forces a fixed point to exist*.  This file studies the
**structure of the space of all such fixed points** from the order-theoretic
side, complementing the categorical one.

We model a self-referential system as a **complete lattice** `α` of *self-states*
(partially ordered by "refinement / information content") together with a
**monotone self-modeling operator** `refine : α →o α`: given a current picture of
itself, the system produces a (no less refined) updated self-picture.  A state is
**conscious / self-consistent** exactly when it is a fixed point: modeling itself
returns itself — a stable strange loop.

The Knaster–Tarski theorem then yields a remarkably rich structure:

* fixed points always exist (`exists_conscious_state`);
* there is a canonical **minimal** conscious state `lfp refine` and a canonical
  **maximal** one `gfp refine` (`isLeast_minimal`, `isGreatest_maximal`), and
  every conscious state lies between them (`conscious_mem_interval`);
* the conscious states themselves form a **complete lattice**
  (`consciousStates_completeLattice`) — the space of consciousness is closed
  under arbitrary joins and meets of consistent pictures;
* the loop is **sharp** (a unique conscious state) exactly when the minimal and
  maximal states coincide (`unique_conscious_iff`);
* inflationary self-models saturate to the top state (`gfp_eq_top_of_inflationary`)
  and refinement of the operator monotonically refines the minimal conscious
  state (`minimal_mono`).
-/

namespace Consciousness.Lattice

open OrderHom Function

variable {α : Type*} [CompleteLattice α]

/-- A **self-modeling system**: a complete lattice of self-states together with a
monotone self-modeling operator.  Monotonicity encodes that refining the input
self-picture never coarsens the output. -/
structure SelfModel (α : Type*) [CompleteLattice α] where
  /-- Update the self-picture given the current one. -/
  refine : α →o α

namespace SelfModel

variable (M : SelfModel α)

/-- A state is **conscious** (self-consistent) when self-modeling fixes it: the
system's picture of itself equals itself, a closed strange loop. -/
def Conscious (s : α) : Prop := M.refine s = s

/-- The set of all conscious states. -/
def consciousStates : Set α := fixedPoints M.refine

@[simp] theorem mem_consciousStates {s : α} :
    s ∈ M.consciousStates ↔ M.refine s = s := Iff.rfl

/-- The **minimal conscious state**: the least fixed point of the self-model. -/
def minimal : α := lfp M.refine

/-- The **maximal conscious state**: the greatest fixed point of the self-model. -/
def maximal : α := gfp M.refine

/-- The minimal state is conscious. -/
@[simp] theorem refine_minimal : M.refine M.minimal = M.minimal := map_lfp M.refine

/-- The maximal state is conscious. -/
@[simp] theorem refine_maximal : M.refine M.maximal = M.maximal := map_gfp M.refine

/-- **Existence of consciousness.**  Every monotone self-model has at least one
conscious state. -/
theorem exists_conscious_state : ∃ s, M.Conscious s :=
  ⟨M.minimal, M.refine_minimal⟩

/-- The minimal conscious state is the least element of the space of conscious
states. -/
theorem isLeast_minimal : IsLeast M.consciousStates M.minimal :=
  isLeast_lfp M.refine

/-- The maximal conscious state is the greatest element of the space of conscious
states. -/
theorem isGreatest_maximal : IsGreatest M.consciousStates M.maximal :=
  isGreatest_gfp M.refine

/-- **Every conscious state lies between the minimal and maximal ones.**  The
strange loop is confined to a canonical interval. -/
theorem conscious_mem_interval {s : α} (hs : M.Conscious s) :
    M.minimal ≤ s ∧ s ≤ M.maximal :=
  ⟨M.isLeast_minimal.2 hs, M.isGreatest_maximal.2 hs⟩

/-- **Knaster–Tarski.**  The conscious states form a *complete lattice*: any
family of consistent self-pictures has a canonical consistent join and meet.  The
space of consciousness is itself richly structured, not merely nonempty. -/
noncomputable instance consciousStates_completeLattice :
    CompleteLattice M.consciousStates :=
  fixedPoints.completeLattice M.refine

/-- **Post-fixed points are sub-maximal.**  Any "self-augmenting" state (one that
its own self-model only refines further, `s ≤ refine s`) is bounded above by the
maximal conscious state — it can be completed to full consciousness. -/
theorem le_maximal_of_le_refine {s : α} (hs : s ≤ M.refine s) : s ≤ M.maximal :=
  le_gfp M.refine hs

/-- **Pre-fixed points are super-minimal.**  Any "self-diminishing" state
(`refine s ≤ s`) dominates the minimal conscious state. -/
theorem minimal_le_of_refine_le {s : α} (hs : M.refine s ≤ s) : M.minimal ≤ s :=
  lfp_le M.refine hs

/-- **Sharpness of the loop.**  The self-model has a *unique* conscious state
precisely when the minimal and maximal conscious states coincide. -/
theorem unique_conscious_iff :
    M.minimal = M.maximal ↔ ∀ s, M.Conscious s → s = M.minimal := by
  constructor
  · intro h s hs
    exact le_antisymm (h ▸ (M.conscious_mem_interval hs).2) (M.isLeast_minimal.2 hs)
  · intro h
    exact (h M.maximal M.refine_maximal).symm

/-- An **inflationary** self-model — one that never discards information
(`s ≤ refine s` for all `s`) — saturates: the top state `⊤` is conscious and is
the maximal conscious state. -/
theorem gfp_eq_top_of_inflationary (h : ∀ s, s ≤ M.refine s) : M.maximal = ⊤ :=
  top_le_iff.mp (M.le_maximal_of_le_refine (h ⊤))

/-- A **deflationary** self-model (`refine s ≤ s` for all `s`) collapses: the
bottom state `⊥` is the minimal conscious state. -/
theorem lfp_eq_bot_of_deflationary (h : ∀ s, M.refine s ≤ s) : M.minimal = ⊥ :=
  le_bot_iff.mp (M.minimal_le_of_refine_le (h ⊥))

end SelfModel

/-- **Monotonicity of minimal consciousness.**  Refining the self-modeling
operator (making it pointwise more refining) can only refine the minimal
conscious state. -/
theorem minimal_mono {M N : SelfModel α} (h : (M.refine : α → α) ≤ N.refine) :
    M.minimal ≤ N.minimal :=
  OrderHom.lfp.monotone h

end Consciousness.Lattice