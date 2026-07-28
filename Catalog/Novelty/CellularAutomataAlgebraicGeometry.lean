import Mathlib

/-!
# Elementary cellular automata as polynomial maps

This file formalizes elementary cellular automata on bi-infinite Boolean
configurations.  It identifies the algebraic normal form of Rule 110 and proves
that Rule 0 has one fixed configuration, whereas Rule 204 fixes every
configuration.  An explicit configuration shows that Rule 110 does not have
all states as fixed points.
-/

namespace CellularAutomataAlgebraicGeometry

/-- The Wolfram truth-table index of a three-cell Boolean neighborhood. -/
def neighborhoodIndex (left center right : Bool) : Nat :=
  4 * left.toNat + 2 * center.toNat + right.toNat

/-- The local Boolean function encoded by a Wolfram elementary rule number. -/
def localRule (rule : Nat) (left center right : Bool) : Bool :=
  (rule.testBit (neighborhoodIndex left center right))

/-- The synchronous global update on a bi-infinite Boolean configuration. -/
def globalUpdate (rule : Nat) (state : Int → Bool) : Int → Bool :=
  fun i => localRule rule (state (i - 1)) (state i) (state (i + 1))

/-- Rule 110 is the cubic polynomial `r + c + cr + lcr` over `𝔽₂`. -/
theorem rule110_algebraic_normal_form (left center right : Bool) :
    ((localRule 110 left center right).toNat : ZMod 2) =
      (right.toNat : ZMod 2) + center.toNat + center.toNat * right.toNat +
        left.toNat * center.toNat * right.toNat := by
  cases left <;> cases center <;> cases right <;>
    decide

/-- A configuration is fixed by Rule 0 exactly when it is identically zero. -/
theorem rule0_fixed_iff (state : Int → Bool) :
    globalUpdate 0 state = state ↔ state = fun _ => false := by
  constructor
  · intro h
    funext i
    have hi := congrFun h i
    simpa [globalUpdate, localRule] using hi.symm
  · intro h
    subst state
    funext i
    simp [globalUpdate, localRule]

/-- Rule 0 therefore has a unique fixed configuration. -/
theorem rule0_unique_fixed :
    ∃! state : Int → Bool, globalUpdate 0 state = state := by
  refine ⟨fun _ => false, ?_, ?_⟩
  · exact (rule0_fixed_iff _).2 rfl
  · intro state hstate
    exact (rule0_fixed_iff state).1 hstate

/-- Rule 204 is the center projection and hence fixes every configuration. -/
theorem rule204_fixes_every_state (state : Int → Bool) :
    globalUpdate 204 state = state := by
  funext i
  simp only [globalUpdate, localRule, neighborhoodIndex]
  cases state (i - 1) <;> cases state i <;> cases state (i + 1) <;> decide

/-- The constant-one configuration is not fixed by Rule 110. -/
theorem rule110_constant_one_not_fixed :
    globalUpdate 110 (fun _ : Int => true) ≠ (fun _ => true) := by
  intro h
  have h0 := congrFun h 0
  change false = true at h0
  exact Bool.noConfusion h0

/-- Consequently Rule 110 does not have a maximal fixed-point locus in the
finite-state sense that every configuration is fixed. -/
theorem rule110_not_every_state_fixed :
    ¬ ∀ state : Int → Bool, globalUpdate 110 state = state := by
  intro h
  exact rule110_constant_one_not_fixed (h (fun _ => true))

/-- Rule 110 fixes the constant-zero configuration. -/
theorem rule110_constant_zero_fixed :
    globalUpdate 110 (fun _ : Int => false) = (fun _ => false) := by
  funext i
  norm_num [globalUpdate, localRule, neighborhoodIndex]

end CellularAutomataAlgebraicGeometry