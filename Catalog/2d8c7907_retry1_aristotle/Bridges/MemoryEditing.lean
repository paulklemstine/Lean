import Mathlib

/-!
# Memory editing as algebraic quotienting

An experience stream is a word in the free monoid on an alphabet `α`.  A memory is a
monoid homomorphism from streams to a representation monoid.  Thus concatenating
experiences and then remembering is the same as combining their memories.

The main connector theorem joins a finite-state pigeonhole principle (information
theory / automata) to the first isomorphism theorem for monoids (universal algebra):
a finite memory necessarily identifies streams, while its observable memory algebra
is exactly the quotient by that indistinguishability congruence.
-/

namespace MemoryEditing

/-- Finite streams of experiences, with concatenation as multiplication. -/
abbrev ExperienceStream (α : Type*) := FreeMonoid α

/-- A compositional memory map. -/
abbrev MemoryMap (α R : Type*) [Monoid R] := ExperienceStream α →* R

/-- Streams erased all the way to the neutral memory. This is the algebraic
"information-loss language" associated with a memory map. -/
def erasedStreams {α R : Type*} [Monoid R] (mem : MemoryMap α R) :
    Submonoid (ExperienceStream α) :=
  MonoidHom.mker mem

/-- Two streams are observationally indistinguishable when memory assigns them the
same representation. This is a multiplicative congruence, not merely an arbitrary
relation. -/
def indistinguishability {α R : Type*} [Monoid R] (mem : MemoryMap α R) :
    Con (ExperienceStream α) :=
  Con.ker mem

/-
Any memory whose representation type is finite is lossy as soon as at least one
experience symbol exists: arbitrarily long streams already form an infinite domain.
-/
theorem finite_memory_is_lossy {α R : Type*} [Nonempty α] [Monoid R] [Finite R]
    (mem : MemoryMap α R) :
    ∃ x y : ExperienceStream α, x ≠ y ∧ mem x = mem y := by
  by_contra! h_contra;
  exact not_injective_infinite_finite _ ( fun x y hxy => Classical.not_not.1 fun h => h_contra _ _ h hxy )

/-
Finite memory therefore induces a genuinely nontrivial congruence class: two
distinct streams become equal in the observational quotient.
-/
theorem finite_memory_indistinguishability_nontrivial
    {α R : Type*} [Nonempty α] [Monoid R] [Finite R]
    (mem : MemoryMap α R) :
    ∃ x y : ExperienceStream α,
      x ≠ y ∧ indistinguishability mem x y := by
  simpa [indistinguishability] using finite_memory_is_lossy mem

/-
Information erased to the neutral representation is closed under both the empty
stream and concatenation. The result is exposed elementwise for applications.
-/
theorem erased_streams_form_submonoid {α R : Type*} [Monoid R]
    (mem : MemoryMap α R) :
    (1 : ExperienceStream α) ∈ erasedStreams mem ∧
      ∀ x y, x ∈ erasedStreams mem → y ∈ erasedStreams mem →
        x * y ∈ erasedStreams mem := by
  exact ⟨ Submonoid.one_mem _, fun x y hx hy => Submonoid.mul_mem _ hx hy ⟩

/-- The observable algebra of a memory is exactly the stream algebra quotiented by
observational indistinguishability (the monoid first isomorphism theorem). -/
noncomputable def quotientByForgettingEquivObservable {α R : Type*} [Monoid R]
    (mem : MemoryMap α R) :
    (indistinguishability mem).Quotient ≃* MonoidHom.mrange mem :=
  Con.quotientKerEquivRange mem

/-- Forget selected experience symbols. `true` means retain and `false` means erase. -/
def targetedForgetting {α : Type*} (retain : α → Bool) :
    MemoryMap α (ExperienceStream α) :=
  FreeMonoid.lift (fun a => if retain a then FreeMonoid.of a else 1)

/-
A symbol marked for forgetting belongs to the erased-stream submonoid.
-/
theorem forgotten_symbol_is_erased {α : Type*} (retain : α → Bool) (a : α)
    (ha : retain a = false) :
    FreeMonoid.of a ∈ erasedStreams (targetedForgetting retain) := by
  -- By definition of `erasedStreams`, we need to show that `targetedForgetting retain (FreeMonoid.of a) = 1`.
  unfold erasedStreams
  simp [targetedForgetting, ha]

/-
The categorical universal property of targeted forgetting: every memory map that
identifies at least the streams identified by targeted forgetting factors uniquely
through its quotient algebra.
-/
theorem targetedForgetting_universal {α S : Type*} [Monoid S]
    (retain : α → Bool) (g : MemoryMap α S)
    (h : indistinguishability (targetedForgetting retain) ≤ Con.ker g) :
    ∃! gbar : (indistinguishability (targetedForgetting retain)).Quotient →* S,
      gbar.comp (indistinguishability (targetedForgetting retain)).mk' = g := by
  obtain ⟨gbar, hgbar⟩ : ∃ gbar : (indistinguishability (targetedForgetting retain)).Quotient →* S, gbar.comp (indistinguishability (targetedForgetting retain)).mk' = g := by
    exact ⟨ _, Con.lift_comp_mk' h ⟩;
  refine' ⟨ gbar, hgbar, fun gbar' hgbar' => _ ⟩;
  exact DFunLike.ext _ _ fun x => by obtain ⟨ y, rfl ⟩ := Quotient.mk_surjective x; simpa using congr_arg ( fun f => f y ) ( hgbar'.trans hgbar.symm ) ;

/-- Targeted forgetting is literally a quotient construction: its quotient memory
algebra is isomorphic to the submonoid of streams containing only observable output. -/
noncomputable def targetedForgettingQuotientEquiv {α : Type*} (retain : α → Bool) :
    (indistinguishability (targetedForgetting retain)).Quotient ≃*
      MonoidHom.mrange (targetedForgetting retain) :=
  quotientByForgettingEquivObservable (targetedForgetting retain)

/-
**Connector theorem.** On streams over any inhabited alphabet, finite-state
compression forces a nontrivial
indistinguishability class, the completely erased inputs form a submonoid, and the
resulting observable memory is precisely the quotient by indistinguishability.
This packages the bridge between finite information theory and monoid quotients.
-/
theorem finite_memory_loss_and_quotient {α R : Type*} [Nonempty α] [Monoid R]
    [Finite R] (mem : MemoryMap α R) :
    (∃ x y : ExperienceStream α, x ≠ y ∧ mem x = mem y) ∧
    ((1 : ExperienceStream α) ∈ erasedStreams mem ∧
      ∀ x y, x ∈ erasedStreams mem → y ∈ erasedStreams mem →
        x * y ∈ erasedStreams mem) ∧
    Nonempty ((indistinguishability mem).Quotient ≃* MonoidHom.mrange mem) := by
  refine' ⟨ finite_memory_is_lossy mem, erased_streams_form_submonoid mem, ?_ ⟩;
  exact ⟨ Con.quotientKerEquivRange mem ⟩

end MemoryEditing