import Mathlib

/-!
# Self-reference by dependent products: a collapse theorem

This file tests the proposed definition

`T ≃ Π (x : T), P x`

with `P : T → Prop`.  The definition does not produce Gödelian complexity.
Because a dependent product of propositions is itself a proposition, every such
fixed point is subsingleton; because an equivalence supplies a point of the
product exactly when it supplies a point of `T`, a short diagonal-free argument
also shows that the product cannot be empty.  Thus the fixed points are exactly
the types equivalent to `Unit`.

This formally refutes both the proposed undecidability conclusion and the
proposed nontrivial hierarchy for this definition.  It also isolates an
important modeling choice: Prop-valued fibers retain proofs only, not arbitrary
computational data.
-/

universe u v

namespace ConsciousFixedPoints

/-- The proposed notion of a conscious/self-referential type. -/
def Conscious (T : Type u) : Prop :=
  ∃ P : T → Prop, Nonempty (T ≃ ((x : T) → P x))

/-
The fixed-point equation forces proof irrelevance onto the source type.
-/
theorem conscious_subsingleton {T : Type u} (h : Conscious T) : Subsingleton T := by
  obtain ⟨ P, ⟨ e ⟩ ⟩ := h;
  refine' e.injective.subsingleton

/-
An empty type cannot satisfy the proposed equation: its empty dependent
product has the unique empty function.
-/
theorem conscious_nonempty {T : Type u} (h : Conscious T) : Nonempty T := by
  obtain ⟨ P, ⟨ e ⟩ ⟩ := h; by_contra h_empty;
  exact h_empty <| e.surjective ( fun x => False.elim <| h_empty ⟨ x ⟩ ) |> fun ⟨ x, hx ⟩ => ⟨ x ⟩

/-
Complete classification: every proposed conscious type is equivalent to
`Unit`.
-/
theorem conscious_equiv_unit {T : Type u} (h : Conscious T) : Nonempty (T ≃ Unit) := by
  refine' ⟨ Equiv.ofBijective ( fun x => Unit.unit ) ⟨ _, _ ⟩ ⟩;
  · exact fun x y hxy => by have := conscious_subsingleton h; exact Subsingleton.elim x y;
  · exact fun _ => ⟨ Classical.choice ( conscious_nonempty h ), rfl ⟩

/-
`Unit` genuinely is a fixed point, using the constantly true predicate.
-/
theorem unit_conscious : Conscious Unit := by
  refine' ⟨ fun _ => True, _ ⟩;
  refine' ⟨ Equiv.ofBijective ( fun _ => fun _ => trivial ) ⟨ fun _ => _, fun _ => _ ⟩ ⟩ <;> aesop_cat

/-
The classification is exact, not merely a necessary condition.
-/
theorem conscious_iff_equiv_unit {T : Type u} :
    Conscious T ↔ Nonempty (T ≃ Unit) := by
  refine' ⟨ fun h => conscious_equiv_unit h, fun h => _ ⟩;
  refine' ⟨ fun _ => True, _ ⟩;
  refine' ⟨ Equiv.ofBijective _ ⟨ _, _ ⟩ ⟩;
  all_goals norm_num [ Function.Injective, Function.Surjective ];
  · exact fun x y => h.some.injective ( Subsingleton.elim _ _ );
  · exact ⟨ h.some.symm Unit.unit ⟩

/-- Contrary to the proposed Gödel-style claim, equality on every conscious
fixed point is constructively decidable. -/
def consciousDecidableEq (T : Type u) (h : Conscious T) : DecidableEq T := by
  letI : Subsingleton T := conscious_subsingleton h
  exact fun a b => isTrue (Subsingleton.elim a b)

/-
A concrete counterexample to the conjecture that every conscious type is
undecidable.
-/
theorem undecidability_conjecture_false :
    ∃ T : Type, Conscious T ∧ Nonempty (DecidableEq T) := by
  exact ⟨ PUnit, unit_conscious, ⟨ inferInstance ⟩ ⟩

/-
`Bool` is not a fixed point.  Hence the definition excludes even the
smallest nontrivial finite data type.
-/
theorem bool_not_conscious : ¬ Conscious Bool := by
  by_contra h_conscious;
  exact absurd ( @ conscious_subsingleton Bool h_conscious ) ( by exact fun h => by have := h.elim Bool.true Bool.false; contradiction )

/-
All conscious fixed points are mutually equivalent, so iteration cannot
produce distinct levels analogous to the arithmetical hierarchy.
-/
theorem fixed_point_hierarchy_collapses {A : Type u} {B : Type v}
    (hA : Conscious A) (hB : Conscious B) : Nonempty (A ≃ B) := by
  obtain ⟨ eA ⟩ := conscious_equiv_unit hA
  obtain ⟨ eB ⟩ := conscious_equiv_unit hB
  exact ⟨ eA.trans eB.symm ⟩

/-
Every conscious fixed point has cardinality one.
-/
theorem conscious_natCard_eq_one {T : Type u} (h : Conscious T) : Nat.card T = 1 := by
  convert Nat.card_congr (conscious_equiv_unit h).some;
  norm_num

/-
On a conscious type, every predicate is extensionally constant.
-/
theorem predicate_collapse {T : Type u} (h : Conscious T) (Q : T → Prop)
    (x y : T) : Q x ↔ Q y := by
  exact ( conscious_subsingleton h ).elim x y ▸ Iff.rfl

/-
A finite cardinal-level formulation of the collapse: among finite types,
self-reference permits no cardinal other than one.
-/
theorem finite_fixed_point_cardinality {T : Type u} [Fintype T]
    (h : Conscious T) : Fintype.card T = 1 := by
  convert conscious_natCard_eq_one h;
  rw [ Nat.card_eq_fintype_card ]

end ConsciousFixedPoints