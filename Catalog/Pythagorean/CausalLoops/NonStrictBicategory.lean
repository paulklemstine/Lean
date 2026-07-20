import Mathlib

/-!
# A genuinely non-strict bicategory from a nonassociative unital magma

This file constructs an explicit one-object bicategory.  Its 1-cells are natural numbers,
with `0` as identity and a deliberately nonassociative composition.  Between every pair of
1-cells there is exactly one 2-cell.  Consequently all coherence diagrams commute, while the
associator can connect composites that are provably unequal.
-/

namespace CausalLoops

open CategoryTheory
open CategoryTheory.Bicategory

/-- The 1-cells in the example. -/
abbrev OneCell := Nat

/-- A unital but nonassociative multiplication.  Away from the identity, `a ⋆ b = a + 2b`. -/
def twistedComp (a b : OneCell) : OneCell :=
  if a = 0 then b else if b = 0 then a else a + 2 * b

@[simp] theorem twistedComp_zero_left (a : OneCell) : twistedComp 0 a = a := by
  simp [twistedComp]

@[simp] theorem twistedComp_zero_right (a : OneCell) : twistedComp a 0 = a := by
  by_cases h : a = 0
  · subst a; rfl
  · simp [twistedComp, h]

/-- The chosen multiplication really fails associativity. -/
theorem twistedComp_not_associative :
    twistedComp (twistedComp 1 1) 1 ≠ twistedComp 1 (twistedComp 1 1) := by
  norm_num [twistedComp]

/-- There is a unique 2-cell between every pair of 1-cells. -/
instance : Quiver OneCell where
  Hom _ _ := PUnit

instance oneCellCategory : Category OneCell where
  id _ := PUnit.unit
  comp _ _ := PUnit.unit
  id_comp _ := rfl
  comp_id _ := rfl
  assoc _ _ _ := rfl

/-- The sole object of the example bicategory. -/
inductive LoopObject
  | star
  deriving DecidableEq

open LoopObject

instance loopCategoryStruct : CategoryStruct LoopObject where
  Hom _ _ := OneCell
  id _ := 0
  comp := twistedComp

/-- The unique isomorphism in a codiscrete hom-category. -/
def uniqueTwoIso (f g : OneCell) : f ≅ g where
  hom := PUnit.unit
  inv := PUnit.unit

/-- The explicit bicategory whose composition is weakly, but not strictly, associative. -/
instance loopBicategory : Bicategory LoopObject where
  homCategory _ _ := oneCellCategory
  whiskerLeft := fun {_ _ _} _ {_ _} _ => PUnit.unit
  whiskerRight := fun {_ _ _} {_ _} _ _ => PUnit.unit
  associator f g h := uniqueTwoIso _ _
  leftUnitor f := uniqueTwoIso _ _
  rightUnitor f := uniqueTwoIso _ _
  whiskerLeft_id := by intros; rfl
  whiskerLeft_comp := by intros; rfl
  id_whiskerLeft := by intros; rfl
  comp_whiskerLeft := by intros; rfl
  id_whiskerRight := by intros; rfl
  comp_whiskerRight := by intros; rfl
  whiskerRight_id := by intros; rfl
  whiskerRight_comp := by intros; rfl
  whisker_assoc := by intros; rfl
  whisker_exchange := by intros; rfl
  pentagon := by intros; rfl
  triangle := by intros; rfl

/-- The distinguished nonidentity 1-cell used to witness nonassociativity. -/
def loopOne : star ⟶ star := (1 : OneCell)

/-- In the example, the two bracketings of three particular 1-cells are not equal. -/
theorem left_bracketing_value : (loopOne ≫ loopOne) ≫ loopOne = (5 : OneCell) := by
  change twistedComp (twistedComp 1 1) 1 = 5
  norm_num [twistedComp]

/-- The right-associated composite evaluates to seven. -/
theorem right_bracketing_value : loopOne ≫ (loopOne ≫ loopOne) = (7 : OneCell) := by
  change twistedComp 1 (twistedComp 1 1) = 7
  norm_num [twistedComp]

/-- Thus the two bracketings of three particular 1-cells are not equal. -/
theorem composition_loop_is_genuinely_nonstrict :
    (loopOne ≫ loopOne) ≫ loopOne ≠ loopOne ≫ (loopOne ≫ loopOne) := by
  exact twistedComp_not_associative

/-- Nevertheless, the associator supplies an invertible 2-cell between those unequal composites. -/
theorem unequal_composites_are_isomorphic :
    Nonempty
      (((loopOne ≫ loopOne) ≫ loopOne) ≅
        (loopOne ≫ (loopOne ≫ loopOne))) := by
  exact ⟨α_ loopOne loopOne loopOne⟩

/-- More generally, every triple of composable 1-cells has an associator isomorphism. -/
theorem all_composition_loops_are_controlled (f g h : star ⟶ star) :
    Nonempty ((f ≫ g) ≫ h ≅ f ≫ (g ≫ h)) := by
  exact ⟨α_ f g h⟩

/-- The example cannot carry the standard strict-bicategory structure: strictness would force
associativity of its specified 1-cell composition. -/
theorem no_strict_structure : ¬ Nonempty (Bicategory.Strict LoopObject) := by
  intro h
  rcases h with ⟨s⟩
  have hassoc := s.assoc loopOne loopOne loopOne
  exact composition_loop_is_genuinely_nonstrict hassoc

/-- A codiscrete hom-category makes coherence automatic: any parallel 2-cells agree. -/
theorem coherence_of_parallel_two_cells {f g : OneCell} (η θ : f ⟶ g) : η = θ := by
  rfl

/-- The pentagon equation in the explicit example, exposed as a standalone theorem. -/
theorem explicit_pentagon (f g h i : star ⟶ star) :
    (α_ f g h).hom ▷ i ≫ (α_ f (g ≫ h) i).hom ≫ f ◁ (α_ g h i).hom =
      (α_ (f ≫ g) h i).hom ≫ (α_ f g (h ≫ i)).hom := by
  exact Bicategory.pentagon f g h i

/-- The triangle equation in the explicit example, exposed as a standalone theorem. -/
theorem explicit_triangle (f g : star ⟶ star) :
    (α_ f (𝟙 star) g).hom ≫ f ◁ (λ_ g).hom = (ρ_ f).hom ▷ g := by
  exact Bicategory.triangle f g

end CausalLoops