import Mathlib

/-! # CatalogBuild.Physics.AlgebraicPhysics.MirrorFixedPoints

Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 15
-/

noncomputable section

/-- A **mirror map** on a partially ordered set: monotone and idempotent. -/
structure MirrorMap (α : Type*) [PartialOrder α] where
  toFun : α → α
  monotone' : Monotone toFun
  idempotent : ∀ a, toFun (toFun a) = toFun a

namespace MirrorMap

variable {α : Type*} [PartialOrder α] (M : MirrorMap α)

/-- The fixed point set of a mirror map. -/
def fixedPoints : Set α := {a | M a = a}

/-- The image of a mirror map equals its fixed point set. -/
theorem image_eq_fixedPoints : range M.toFun = M.fixedPoints := by
  ext x
  simp only [mem_range, fixedPoints, mem_setOf_eq]
  constructor
  · rintro ⟨y, rfl⟩; exact M.idempotent y
  · intro h; exact ⟨x, h⟩

/-- Every element in the image is a fixed point. -/
theorem image_subset_fixedPoints (a : α) : M a ∈ M.fixedPoints :=
  M.idempotent a

/-- A mirror map is a retraction: it's the identity on its image. -/
theorem retraction (a : α) : M (M a) = M a := M.idempotent a

/-- Fixed points are exactly the elements that equal their reflection. -/
theorem mem_fixedPoints_iff (a : α) : a ∈ M.fixedPoints ↔ M a = a := Iff.rfl

/-- The max-with-zero mirror on ℝ (the ReLU mirror). -/
def tropicalMaxMirror : MirrorMap ℝ where
  toFun := fun x => max x 0
  monotone' := fun _ _ h => max_le_max_right 0 h
  idempotent := fun x => by simp

/-- Fixed points of the tropical max mirror are exactly non-negative reals. -/
theorem tropicalMaxMirror_fixedPoints :
    tropicalMaxMirror.fixedPoints = {x : ℝ | 0 ≤ x} := by
  ext x
  simp only [MirrorMap.fixedPoints, tropicalMaxMirror, mem_setOf_eq]
  constructor
  · intro h
    have : 0 ≤ max x 0 := le_max_right x 0
    rw [h] at this; exact this
  · intro h; exact max_eq_left h

/-- On a complete lattice, a mirror map has at least one fixed point. -/
theorem MirrorMap.has_least_fixedPoint {α : Type*} [CompleteLattice α]
    (M : MirrorMap α) :
    M.fixedPoints.Nonempty := by
  exact ⟨M ⊥, M.image_subset_fixedPoints ⊥⟩

/-- The identity is a mirror map. -/
def MirrorMap.idMirror (α : Type*) [PartialOrder α] : MirrorMap α where
  toFun := _root_.id
  monotone' := monotone_id
  idempotent := fun _ => rfl

/-- Every element is a fixed point of the identity mirror. -/
theorem MirrorMap.id_fixedPoints_eq_univ {α : Type*} [PartialOrder α] :
    (MirrorMap.idMirror α).fixedPoints = univ := by
  ext x; simp [MirrorMap.fixedPoints, MirrorMap.idMirror]

/-- The **mirror depth** of an element: how far it is from being self-aware.
For an idempotent mirror, depth is always 0 or 1. -/
def MirrorMap.depth {α : Type*} [PartialOrder α] [DecidableEq α]
    (M : MirrorMap α) (a : α) : ℕ :=
  if M a = a then 0 else 1

/-- Self-aware elements have depth 0. -/
theorem MirrorMap.depth_zero_iff {α : Type*} [PartialOrder α] [DecidableEq α]
    (M : MirrorMap α) (a : α) :
    M.depth a = 0 ↔ a ∈ M.fixedPoints := by
  simp [depth, fixedPoints]

/-- All elements have depth at most 1 (because the mirror is idempotent). -/
theorem MirrorMap.depth_le_one {α : Type*} [PartialOrder α] [DecidableEq α]
    (M : MirrorMap α) (a : α) :
    M.depth a ≤ 1 := by
  unfold depth; split <;> omega

/-- After one reflection, depth is always 0 (the element becomes self-aware). -/
theorem MirrorMap.depth_after_reflect {α : Type*} [PartialOrder α] [DecidableEq α]
    (M : MirrorMap α) (a : α) :
    M.depth (M a) = 0 := by
  simp [depth, M.idempotent a]

end