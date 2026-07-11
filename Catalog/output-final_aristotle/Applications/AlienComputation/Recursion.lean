import Mathlib

/-!
# The positive face of diagonalization: self-reference, recursion, and quines

**Research theme: Computational Complexity of Alien Civilizations.**

Lawvere's fixed-point theorem has two faces.  Its *contrapositive* is the
negative diagonal argument (Cantor, halting, incompleteness — see
`Lawvere.lean`, `Uncomputability.lean`).  Its *direct* form is a **positive**
existence statement: in any sufficiently expressive programming system, every
program transformation has a fixed program.  This is exactly **Kleene's second
recursion theorem** — the abstract source of self-reproducing programs (quines),
compilers that know their own code, and self-optimizing systems.

The striking structural fact, forced on any civilization, is a **duality within
a single system**:

* a programming system can be *complete for its own program transformations*
  (`recursion_theorem`), yielding self-reference and quines; yet
* it can *never* be *complete for its own Boolean decision behaviours*
  (`no_complete_semantics`), yielding uncomputability.

Both facts are instances of the same Lawvere theorem, differing only in the
choice of answer type (`Pgm` vs. `Bool`).

## Main results

* `AlienComputation.lawvere` : point-surjective indexing ⇒ every endofunction has
  a fixed point.
* `AlienComputation.ProgrammingSystem.recursion_theorem` : every program
  transformation of a complete system has a fixed program.
* `AlienComputation.ProgrammingSystem.exists_quine` : self-reproducing programs
  exist in every complete system.
* `AlienComputation.ProgrammingSystem.no_complete_semantics` : no complete
  system has a complete Boolean semantics of itself.
-/

namespace AlienComputation

universe u v

/-- An indexing `φ : A → (A → B)` is **point-surjective** when every function
`g : A → B` equals `φ a` for some code `a`. -/
def PointSurjective {A : Type u} {B : Type v} (φ : A → (A → B)) : Prop :=
  ∀ g : A → B, ∃ a : A, φ a = g

/-- Boolean negation has no fixed point. -/
theorem bool_ne_not (b : Bool) : b ≠ !b := by cases b <;> decide

/-- **Lawvere's fixed-point theorem (direct form).**  A point-surjective indexing
of a type's `B`-valued functions forces every `f : B → B` to have a fixed
point. -/
theorem lawvere {A : Type u} {B : Type v} (φ : A → (A → B))
    (hφ : PointSurjective φ) (f : B → B) : ∃ b : B, f b = b := by
  obtain ⟨a, ha⟩ := hφ (fun x => f (φ x x))
  exact ⟨φ a a, (congrFun ha a).symm⟩

/-- A **programming system** whose program-transformations are all internally
represented: `build` indexes transformations `Pgm → Pgm` by programs, and
`complete` says every transformation is so indexed.  This is the abstract content
of an *acceptable programming system* (closure under the `s-m-n` theorem). -/
structure ProgrammingSystem where
  /-- The type of programs. -/
  Pgm : Type u
  /-- `build a` is the program-transformation named by program `a`. -/
  build : Pgm → (Pgm → Pgm)
  /-- Every program-transformation is named by some program. -/
  complete : PointSurjective build

namespace ProgrammingSystem

variable (S : ProgrammingSystem)

/-- **Kleene's second recursion theorem (abstract form).**  In a complete
programming system, every program transformation `f : Pgm → Pgm` has a fixed
program `e` with `f e = e`.  Concretely: for any effective way of modifying
programs, there is a program unaffected (semantically) by the modification —
the root of all self-reference. -/
theorem recursion_theorem (f : S.Pgm → S.Pgm) : ∃ e : S.Pgm, f e = e :=
  lawvere S.build S.complete f

/-- **Existence of quines.**  Reading `printer : Pgm → Pgm` as "the transformation
a program undergoes when asked to describe itself", the recursion theorem yields
a program that is its own description: a self-reproducing program.  Every
complete programming system — hence every sufficiently advanced civilization —
possesses quines. -/
theorem exists_quine (printer : S.Pgm → S.Pgm) : ∃ e : S.Pgm, printer e = e :=
  S.recursion_theorem printer

/-- **The duality: no complete self-semantics.**  Although a system may be
complete for its own program transformations (`recursion_theorem`), it can never
be complete for its own Boolean decision behaviours: for any assignment
`sem : Pgm → (Pgm → Bool)` of behaviours to programs there is a behaviour no
program realizes.  Completeness for transformations and incompleteness for
decisions coexist — both are Lawvere's theorem with different answer types. -/
theorem no_complete_semantics (sem : S.Pgm → (S.Pgm → Bool)) :
    ∃ g : S.Pgm → Bool, ∀ p : S.Pgm, sem p ≠ g := by
  refine ⟨fun q => !(sem q q), fun p hp => ?_⟩
  exact (bool_ne_not _) (congrFun hp p)

end ProgrammingSystem

/-- Non-vacuity witness.  A complete programming system genuinely exists: the
one-program system.  (In full `Set`, Cantor forces every model complete for *all*
its transformations `Pgm → Pgm` to have a subsingleton `Pgm` — itself a shadow of
the diagonal.  The non-degenerate instances of `recursion_theorem` live in the
*computable* category, where acceptable programming systems satisfy the
hypothesis via the `s-m-n` theorem; that is the classical Kleene setting.) -/
def unitSystem : ProgrammingSystem where
  Pgm := PUnit
  build := fun _ _ => PUnit.unit
  complete := fun _g => ⟨PUnit.unit, funext fun _ => Subsingleton.elim _ _⟩

/-- The hypotheses of the recursion theorem are satisfiable, so the theorem is
not vacuous. -/
example (f : unitSystem.Pgm → unitSystem.Pgm) : ∃ e, f e = e :=
  unitSystem.recursion_theorem f

end AlienComputation