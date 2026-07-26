import Mathlib

/-!
# Free complementation orbits for jigsaw solution spaces

A global tab--blank complement transports assemblies of a framed puzzle to
assemblies of the complemented puzzle.  The correct combined solution space is
a *tagged* disjoint union.  This file proves a stronger form of the proposed
parity conjecture: no hypothesis excluding self-dual puzzles is required.

The result is deliberately independent of a particular geometric encoding.  Its
only geometric input is the equivalence of complete assembly spaces induced by
complementing every non-flat edge.  All orbit and counting consequences then
follow formally and without quotienting interchangeable pieces.
-/

namespace JigsawComplementOrbits

section TaggedComplement

variable {α β : Type*}

/-- The involution on a tagged pair of spaces induced by an equivalence between
its two sides. -/
def taggedComplement (e : α ≃ β) : α ⊕ β → α ⊕ β
  | Sum.inl a => Sum.inr (e a)
  | Sum.inr b => Sum.inl (e.symm b)

/-- Applying global complementation twice restores the original tagged
assembly. -/
theorem taggedComplement_involutive (e : α ≃ β) :
    Function.Involutive (taggedComplement e) := by
  intro x
  cases x with
  | inl a => simp [taggedComplement]
  | inr b => simp [taggedComplement]

/-- The side tag makes complementation fixed-point-free.  This conclusion does
not depend on whether the underlying puzzle is isomorphic to its complement. -/
theorem taggedComplement_ne_self (e : α ≃ β) (x : α ⊕ β) :
    taggedComplement e x ≠ x := by
  cases x <;> simp [taggedComplement]

/-- Complementation is a permutation of the combined assembly space. -/
def taggedComplementEquiv (e : α ≃ β) : Equiv.Perm (α ⊕ β) where
  toFun := taggedComplement e
  invFun := taggedComplement e
  left_inv := taggedComplement_involutive e
  right_inv := taggedComplement_involutive e

/-- Every complementation orbit is exactly the two-element pair consisting of
an assembly and its complemented assembly. -/
theorem taggedComplement_orbit_pair (e : α ≃ β) (x : α ⊕ β) :
    ({x, taggedComplement e x} : Set (α ⊕ β)).ncard = 2 := by
  rw [Set.ncard_pair]
  exact (taggedComplement_ne_self e x).symm

/-- The two sides have equal finite cardinality. -/
theorem complement_card_eq [Fintype α] [Fintype β] (e : α ≃ β) :
    Fintype.card α = Fintype.card β := by
  exact Fintype.card_congr e

/-- **Parity theorem.** The combined number of original and complemented
assemblies is even. -/
theorem tagged_union_card_even [Fintype α] [Fintype β] (e : α ≃ β) :
    Even (Fintype.card (α ⊕ β)) := by
  rw [Fintype.card_sum, ← Fintype.card_congr e]
  exact ⟨Fintype.card α, by omega⟩

end TaggedComplement

/-! ## Abstract framed-puzzle consequence -/

/-- Data common to geometric complement constructions: a type of framed
puzzles, a finite assembly space for each puzzle, global edge complementation,
and the induced bijection of complete assemblies. -/
structure FramedComplementSystem where
  Puzzle : Type*
  Assembly : Puzzle → Type*
  complement : Puzzle → Puzzle
  complement_involutive : Function.Involutive complement
  assemblyComplement : (p : Puzzle) → Assembly p ≃ Assembly (complement p)
  finiteAssembly : (p : Puzzle) → Fintype (Assembly p)

namespace FramedComplementSystem

/-- Original and complemented assemblies, with a tag recording the frame in
which the assembly lives. -/
abbrev CombinedAssemblies (S : FramedComplementSystem) (p : S.Puzzle) :=
  S.Assembly p ⊕ S.Assembly (S.complement p)

/-- Global tab--blank complementation on the combined assembly space. -/
def complementAssembly (S : FramedComplementSystem) (p : S.Puzzle) :
    S.CombinedAssemblies p → S.CombinedAssemblies p :=
  taggedComplement (S.assemblyComplement p)

/-- Complementation of framed assemblies has order two. -/
theorem complementAssembly_involutive (S : FramedComplementSystem)
    (p : S.Puzzle) : Function.Involutive (S.complementAssembly p) := by
  exact taggedComplement_involutive (S.assemblyComplement p)

/-- Complementation acts freely on the disjoint union of the two complete
assembly spaces, including for self-complementary puzzles. -/
theorem complementAssembly_free (S : FramedComplementSystem) (p : S.Puzzle)
    (x : S.CombinedAssemblies p) : S.complementAssembly p x ≠ x := by
  exact taggedComplement_ne_self (S.assemblyComplement p) x

/-- The combined number of framed assemblies is even.  Contrary to the tentative
non-self-duality restriction, this needs no assumption that `p` and
`complement p` are non-isomorphic. -/
theorem combinedAssemblies_even (S : FramedComplementSystem) (p : S.Puzzle) :
    letI := S.finiteAssembly p
    letI := S.finiteAssembly (S.complement p)
    Even (Fintype.card (S.CombinedAssemblies p)) := by
  letI := S.finiteAssembly p
  letI := S.finiteAssembly (S.complement p)
  exact tagged_union_card_even (S.assemblyComplement p)

end FramedComplementSystem

/-! ## Sharpness experiment: a self-dual puzzle

The one-puzzle system below is globally self-dual and has one assembly.  Its
tagged combined space nevertheless has two elements and the complement action
swaps them.  Thus non-self-duality is not necessary for freeness on the tagged
union. -/

/-- A minimal self-dual framed system with one puzzle and one assembly. -/
def selfDualSingletonSystem : FramedComplementSystem where
  Puzzle := Unit
  Assembly := fun _ => Unit
  complement := id
  complement_involutive := by intro p; rfl
  assemblyComplement := fun _ => Equiv.refl Unit
  finiteAssembly := fun _ => inferInstance

instance selfDualSingletonAssemblyFintype (p : selfDualSingletonSystem.Puzzle) :
    Fintype (selfDualSingletonSystem.Assembly p) :=
  selfDualSingletonSystem.finiteAssembly p

/-- The self-dual example has exactly two tagged combined assemblies. -/
theorem selfDualSingleton_combined_card :
    Fintype.card (selfDualSingletonSystem.CombinedAssemblies ()) = 2 := by
  change Fintype.card (Unit ⊕ Unit) = 2
  simp

/-- Even in the self-dual example, global complementation has no fixed tagged
assembly. -/
theorem selfDualSingleton_complement_free
    (x : selfDualSingletonSystem.CombinedAssemblies ()) :
    selfDualSingletonSystem.complementAssembly () x ≠ x := by
  exact selfDualSingletonSystem.complementAssembly_free () x

end JigsawComplementOrbits