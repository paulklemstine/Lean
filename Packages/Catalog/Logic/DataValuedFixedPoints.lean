import Computation.Computation.ConsciousFixedPoints

/-!
# Data-valued dependent-product fixed points

This file takes the first non-collapsing replacement suggested by the
classification of `ConsciousFixedPoints.Conscious`: the fibers now live in
`Type`, rather than `Prop`.

Unlike the proposition-valued equation, the data-valued equation already has a
non-singleton finite solution.  The solution is genuinely dependent: over
`false` its fiber is `Bool`, while over `true` its fiber is `Unit`.  Thus its
product stores exactly one Boolean datum.  We also record the finite cardinal
equation satisfied by every such fixed point.
-/

universe u v

namespace ConsciousFixedPoints

/-- A data-valued version of the dependent-product fixed-point equation. -/
def DataConscious (T : Type u) : Prop :=
  ∃ F : T → Type u, Nonempty (T ≃ ((x : T) → F x))

/-- The dependent family carrying one Boolean datum over `false` and no data
over `true`. -/
def BoolFiber : Bool → Type
  | false => Bool
  | true => Unit

/-- A Boolean is equivalent to a section of `BoolFiber`: store it at `false`
and use the unique value at `true`. -/
def boolSectionEquiv : Bool ≃ ((b : Bool) → BoolFiber b) where
  toFun a
    | false => a
    | true => Unit.unit
  invFun f := f false
  left_inv _ := rfl
  right_inv f := by
    funext b
    cases b
    · rfl
    · change f true = Unit.unit
      exact Unit.ext _ _

/-- `Bool` is a concrete non-singleton data-valued fixed point. -/
theorem bool_dataConscious : DataConscious Bool := by
  exact ⟨BoolFiber, ⟨boolSectionEquiv⟩⟩

/-- The two fibers in the Boolean example are not equivalent, so the example
is genuinely dependent rather than a constant function-space fixed point. -/
theorem boolFiber_not_equiv : ¬ Nonempty (BoolFiber false ≃ BoolFiber true) := by
  rintro ⟨e⟩
  have h := e.injective (show e false = e true from Unit.ext _ _)
  cases h

/-- The section type in the Boolean example does not collapse to a
subsingleton.  This pinpoints exactly where replacing `Prop` by `Type` defeats
the proof-irrelevance argument. -/
theorem bool_sections_not_subsingleton :
    ¬ Subsingleton ((b : Bool) → BoolFiber b) := by
  intro h
  have heq : boolSectionEquiv false = boolSectionEquiv true := h.elim _ _
  have : false = true := boolSectionEquiv.injective heq
  cases this

/-- Every finite data-valued fixed point obeys the expected product cardinal
equation. -/
theorem dataConscious_fintype_cardinality
    {T : Type u} [Fintype T] (F : T → Type v) [∀ x, Fintype (F x)]
    (e : T ≃ ((x : T) → F x)) :
    Fintype.card T = ∏ x, Fintype.card (F x) := by
  classical
  exact (Fintype.card_congr e).trans Fintype.card_pi

/-- In the Boolean example the fiber-cardinality product is exactly two. -/
theorem boolFiber_cardinality_product :
    (∏ b : Bool, Nat.card (BoolFiber b)) = 2 := by
  simp [BoolFiber]

/-- Therefore the proposition-valued collapse theorem does not extend to
`DataConscious`: there exists a data-valued fixed point that is not a
subsingleton. -/
theorem dataConscious_does_not_force_subsingleton :
    ∃ T : Type, DataConscious T ∧ ¬ Subsingleton T := by
  refine ⟨Bool, bool_dataConscious, ?_⟩
  intro h
  have : false = true := h.elim _ _
  cases this

end ConsciousFixedPoints