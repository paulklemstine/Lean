import Mathlib

open Set Topology

namespace GaloisTopologyBridge

/-- The upper Alexandrov topology of a preorder: open sets are upward closed. -/
def upperAlexandrov (α : Type*) [Preorder α] : TopologicalSpace α where
  IsOpen s := ∀ ⦃a b : α⦄, a ≤ b → a ∈ s → b ∈ s
  isOpen_univ := by simp
  isOpen_inter s t hs ht := by
    intro a b hab hst
    exact ⟨hs hab hst.1, ht hab hst.2⟩
  isOpen_sUnion S hS := by
    intro a b hab ha
    rcases ha with ⟨s, hsS, has⟩
    exact ⟨s, hsS, hS s hsS hab has⟩

/-- A map between preorders is continuous for their upper Alexandrov topologies
exactly when it is monotone. -/
theorem continuous_upperAlexandrov_iff_monotone
    {α β : Type*} [Preorder α] [Preorder β] (f : α → β) :
    @Continuous α β (upperAlexandrov α) (upperAlexandrov β) f ↔ Monotone f := by
  constructor
  · intro hf a b hab
    rw [continuous_def] at hf
    have hopen := hf {y | f a ≤ y} (fun x y hxy hx => le_trans hx hxy)
    have ha_mem : a ∈ f ⁻¹' {y | f a ≤ y} := by simp
    have hb_mem := hopen hab ha_mem
    simpa using hb_mem
  · intro hf
    rw [continuous_def]
    intro s hs x y hxy hfx
    exact hs (hf hxy) hfx

/-- Both adjoints in a Galois connection are continuous for the upper
Alexandrov topologies. -/
theorem galoisConnection_continuous
    {α β : Type*} [Preorder α] [Preorder β]
    {l : α → β} {u : β → α} (gc : GaloisConnection l u) :
    @Continuous α β (upperAlexandrov α) (upperAlexandrov β) l ∧
      @Continuous β α (upperAlexandrov β) (upperAlexandrov α) u := by
  rw [continuous_upperAlexandrov_iff_monotone, continuous_upperAlexandrov_iff_monotone]
  exact ⟨gc.monotone_l, gc.monotone_u⟩

/-- The closure-fixed elements induced by a Galois connection form a complete
lattice. This is the closure-system form of Knaster--Tarski. -/
theorem galois_closed_elements_completeLattice
    {α β : Type*} [CompleteLattice α] [Preorder β]
    {l : α → β} {u : β → α} (gc : GaloisConnection l u) :
    Nonempty (CompleteLattice gc.closureOperator.Closeds) := by
  exact ⟨gc.closureOperator.gi.liftCompleteLattice⟩

/-- Knaster--Tarski directly: the fixed points of the monotone composite
`u ∘ l` form a complete lattice. -/
theorem galois_composite_fixedPoints_completeLattice
    {α β : Type*} [CompleteLattice α] [Preorder β]
    {l : α → β} {u : β → α} (gc : GaloisConnection l u) :
    Nonempty (CompleteLattice (Function.fixedPoints (u ∘ l))) := by
  have h := galois_closed_elements_completeLattice gc
  exact h

section Zariski

variable {R : Type*} [CommRing R]

/-- Ideal containment and zero-locus containment are adjoint after reversing
one order: this is the vanishing/zero-set Galois connection underlying Spec. -/
theorem ideal_vanishing_zeroLocus_galois
    (I : Ideal R) (Z : Set (PrimeSpectrum R)) :
    I ≤ PrimeSpectrum.vanishingIdeal Z ↔
      Z ⊆ PrimeSpectrum.zeroLocus (I : Set R) := by
  exact (PrimeSpectrum.subset_zeroLocus_iff_le_vanishingIdeal Z I).symm

/-- Zariski closed sets are exactly the zero sets supplied by the preceding
Galois connection. -/
theorem zariski_closed_iff_galois_zeroLocus (Z : Set (PrimeSpectrum R)) :
    IsClosed Z ↔ ∃ I : Ideal R, Z = PrimeSpectrum.zeroLocus (I : Set R) := by
  rw [PrimeSpectrum.isClosed_iff_zeroLocus Z]
  constructor
  · rintro ⟨s, hs⟩
    exact ⟨Ideal.span s, by rw [hs]; exact (PrimeSpectrum.zeroLocus_span s).symm⟩
  · rintro ⟨I, hI⟩
    exact ⟨I, hI⟩

/-- The Galois closure of an ideal is its radical. Thus radical ideals are
precisely the ideal-side fixed points. -/
theorem galois_ideal_closure_eq_radical (I : Ideal R) :
    PrimeSpectrum.vanishingIdeal (PrimeSpectrum.zeroLocus (I : Set R)) = I.radical := by
  exact PrimeSpectrum.vanishingIdeal_zeroLocus_eq_radical I

end Zariski

section Counterexample

open Classical

/-- A three-point closure operation that closes a set to the universe exactly
when it contains both `0` and `1`. -/
def badClosureFun (S : Set (Fin 3)) : Set (Fin 3) :=
  if (0 : Fin 3) ∈ S ∧ (1 : Fin 3) ∈ S then Set.univ else S

/-- The preceding operation is a genuine order-theoretic closure operator. -/
def badClosure : ClosureOperator (Set (Fin 3)) :=
  ClosureOperator.mk' badClosureFun (by
    intro S T hST
    simp only [badClosureFun]
    split_ifs with hS hT
    · exact le_rfl
    · exact (hT ⟨hST hS.1, hST hS.2⟩).elim
    · exact Set.subset_univ _
    · exact hST)
    (by intro S; simp only [badClosureFun]; split_ifs <;> simp_all)
    (by intro S; simp only [badClosureFun]; split_ifs <;> simp_all)

/-- Contrarian disproof: not every order-theoretic closure is topological.
This closure fails the finite-union law, so fixed points of a general Galois
connection cannot automatically be declared the closed sets of a topology. -/
theorem orderClosure_need_not_preserve_union :
    ∃ (c : ClosureOperator (Set (Fin 3))) (A B : Set (Fin 3)),
      c (A ∪ B) ≠ c A ∪ c B := by
  use badClosure, {0}, {1}
  simp [badClosure, badClosureFun]
  intro h
  have hmem : (2 : Fin 3) ∈ ({1, 0} : Set (Fin 3)) := h ▸ Set.mem_univ 2
  simp at hmem

end Counterexample

end GaloisTopologyBridge