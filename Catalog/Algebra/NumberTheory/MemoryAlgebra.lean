/-
# Memory Algebra: Forgetting as a Mathematical Operation

We formalize memory as a monoid homomorphism from experience streams (free monoid
over an alphabet) to compressed memory states. We prove:

1. Any such homomorphism to a finite codomain must be lossy (non-injective)
   when the alphabet has at least 2 elements.
2. The "confusion set" (kernel) of a memory map forms a monoid congruence.
3. Composing two forgetting operations yields another forgetting operation.
4. Targeted forgetting is equivalent to a quotient construction: refining
   the kernel congruence corresponds to remembering more.

This connects to the broader theme of bounded computation: any finite-state
processing of an infinite stream must lose information, and the structure
of that loss is itself algebraically rich.
-/

import Mathlib

open Function

/-! ## Core Definitions -/

/-- A `MemorySystem` packages a monoid homomorphism from the free monoid `FreeMonoid α`
    (sequences of experiences with concatenation) to a memory monoid `M`. -/
structure MemorySystem (α : Type*) (M : Type*) [Monoid M] where
  /-- The memory encoding function -/
  encode : FreeMonoid α →* M

/-- A memory system is *lossy* if its encoding is not injective. -/
def MemorySystem.IsLossy {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M) : Prop :=
  ¬Injective ms.encode

/-- The *confusion set* of a memory system: the set of pairs of experience
    streams that map to the same memory state. -/
def MemorySystem.confusionSet {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M) : Set (FreeMonoid α × FreeMonoid α) :=
  {p | ms.encode p.1 = ms.encode p.2}

/-- A `ForgettingMap` between two memory systems over the same alphabet is a
    monoid homomorphism between memory monoids making the triangle commute. -/
structure ForgettingMap {α : Type*} {M N : Type*} [Monoid M] [Monoid N]
    (ms₁ : MemorySystem α M) (ms₂ : MemorySystem α N) where
  /-- The forgetting homomorphism -/
  forget : M →* N
  /-- Commutativity: forget ∘ encode₁ = encode₂ -/
  comm : ∀ x : FreeMonoid α, forget (ms₁.encode x) = ms₂.encode x

/-! ## The Kernel Congruence -/

/-- The kernel of a memory homomorphism is a monoid congruence on `FreeMonoid α`.
    Two streams are related iff they encode to the same memory state. -/
def MemorySystem.kernelCon {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M) : Con (FreeMonoid α) :=
  Con.ker ms.encode

/-! ## Main Theorems -/

/-- **Pigeonhole Lossiness Theorem**: Any memory system with finite memory and
    an alphabet of at least 2 symbols must be lossy.

    The free monoid on ≥2 generators is infinite (it contains all finite words).
    A map from an infinite set to a finite set cannot be injective. -/
theorem finite_memory_is_lossy {α : Type*} {M : Type*} [Monoid M]
    [Fintype M]
    (ms : MemorySystem α M)
    (a b : α) (_ : a ≠ b) :
    ms.IsLossy := by
  by_contra! h_inj
  have h_infinite : Infinite (FreeMonoid α) :=
    Infinite.of_injective (fun n => List.replicate n a) fun m n hmn => by
      simpa using congr_arg List.length hmn
  exact h_infinite.not_finite <| Finite.of_injective _ <| Classical.not_not.1 h_inj

/-- The confusion set contains the identity pair and is closed under the
    monoid operation — it has the structure of a submonoid. -/
theorem confusion_set_submonoid_props {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M) :
    ((1 : FreeMonoid α), (1 : FreeMonoid α)) ∈ ms.confusionSet ∧
    (∀ p q : FreeMonoid α × FreeMonoid α,
      p ∈ ms.confusionSet → q ∈ ms.confusionSet →
      (p.1 * q.1, p.2 * q.2) ∈ ms.confusionSet) := by
  simp +decide [MemorySystem.confusionSet]
  aesop

/-- A forgetting map expands the confusion set: confusion in the finer
    system implies confusion in the coarser system. -/
theorem forgetting_expands_confusion {α : Type*} {M N : Type*} [Monoid M] [Monoid N]
    (ms₁ : MemorySystem α M) (ms₂ : MemorySystem α N)
    (f : ForgettingMap ms₁ ms₂) :
    ms₁.confusionSet ⊆ ms₂.confusionSet := by
  intro p hp
  have h_forget : f.forget (ms₁.encode p.1) = f.forget (ms₁.encode p.2) :=
    congr_arg _ hp
  rw [f.comm, f.comm] at h_forget; exact h_forget

/-- **Forgetting Composition**: Composing two forgetting maps yields a forgetting map.
    This establishes that memory systems and forgetting maps form a category. -/
def forgettingMap_comp {α : Type*} {M N P : Type*} [Monoid M] [Monoid N] [Monoid P]
    {ms₁ : MemorySystem α M} {ms₂ : MemorySystem α N} {ms₃ : MemorySystem α P}
    (f : ForgettingMap ms₁ ms₂) (g : ForgettingMap ms₂ ms₃) :
    ForgettingMap ms₁ ms₃ where
  forget := g.forget.comp f.forget
  comm x := by simp [MonoidHom.comp_apply, f.comm, g.comm]

/-- The identity forgetting map. -/
def forgettingMap_id {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M) :
    ForgettingMap ms ms where
  forget := MonoidHom.id M
  comm _ := rfl

/-- **Quotient Memory Construction**: Given a congruence on `FreeMonoid α` coarser
    than the kernel of the memory map, we get a quotient memory system.
    This is the formal version of "targeted forgetting". -/
noncomputable def quotientMemorySystem {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M) (c : Con (FreeMonoid α))
    (_hc : ∀ x y, ms.kernelCon.toSetoid.r x y → c.toSetoid.r x y) :
    MemorySystem α c.Quotient :=
  ⟨c.mk'⟩

/-- **Finer Congruence = Less Confusion**: If c₁ is finer than c₂,
    the c₁-quotient memory confuses fewer streams than the c₂-quotient. -/
theorem finer_congruence_less_confusion {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M)
    (c₁ c₂ : Con (FreeMonoid α))
    (hc₁ : ∀ x y, ms.kernelCon.toSetoid.r x y → c₁.toSetoid.r x y)
    (hc₂ : ∀ x y, ms.kernelCon.toSetoid.r x y → c₂.toSetoid.r x y)
    (h_fine : ∀ x y : FreeMonoid α, c₁.toSetoid.r x y → c₂.toSetoid.r x y) :
    (quotientMemorySystem ms c₁ hc₁).confusionSet ⊆
    (quotientMemorySystem ms c₂ hc₂).confusionSet := by
  unfold quotientMemorySystem
  simp_all +decide [MemorySystem.confusionSet]

/-- **Memory Capacity Bound**: If all length-k sequences over alphabet α map to
    distinct memory states, then |α|^k ≤ |M|. This quantifies the pigeonhole
    lossiness result: a finite memory can distinguish at most |M| streams. -/
theorem memory_capacity_bound {α : Type*} {M : Type*} [Monoid M]
    [Fintype α] [Fintype M] [DecidableEq M]
    (ms : MemorySystem α M) (k : ℕ)
    (h_inj : Injective (fun s : Fin k → α => ms.encode (List.ofFn s))) :
    Fintype.card α ^ k ≤ Fintype.card M := by
  simpa [Fintype.card_pi] using Fintype.card_le_of_injective _ h_inj

/-- **Kernel Quotient Injectivity** (First Isomorphism Theorem direction):
    The quotient by the kernel congruence injects into M.
    FreeMonoid α / ker(encode) ↪ M. -/
theorem kernel_quotient_injective {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M) :
    Injective (Con.lift ms.kernelCon ms.encode (fun _ _ h => h)) := by
  convert Con.kerLift_injective ms.encode using 1

/-- **Selective Forgetting**: Given a set of "forgotten" symbols, we construct
    a congruence identifying streams that differ only in those symbols.
    This models targeted forgetting of specific experience types. -/
def selectiveForgettingCon {α : Type*} [DecidableEq α]
    (S : Finset α) : Con (FreeMonoid α) where
  r x y := (x : List α).filter (· ∉ S) = (y : List α).filter (· ∉ S)
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩
  mul' {a b c d} (h₁ : (a : List α).filter (· ∉ S) = (b : List α).filter (· ∉ S))
       (h₂ : (c : List α).filter (· ∉ S) = (d : List α).filter (· ∉ S)) := by
    change (FreeMonoid.toList (a * c)).filter (· ∉ S) =
           (FreeMonoid.toList (b * d)).filter (· ∉ S)
    rw [FreeMonoid.toList_mul, FreeMonoid.toList_mul,
        List.filter_append, List.filter_append]
    exact congrArg₂ _ h₁ h₂

/-- Selective forgetting of a larger set identifies more streams:
    forgetting S ⊆ T means every S-confusion is a T-confusion. -/
theorem selective_forgetting_monotone {α : Type*} [DecidableEq α]
    (S T : Finset α) (hST : S ⊆ T) :
    ∀ x y : FreeMonoid α,
      (selectiveForgettingCon S).toSetoid.r x y →
      (selectiveForgettingCon T).toSetoid.r x y := by
  intros x y hxy
  simp [selectiveForgettingCon] at hxy ⊢
  convert congr_arg (fun l => List.filter (fun x => !decide (x ∈ T)) l) hxy using 1 <;>
    simp +decide
  · grind
  · exact List.filter_congr fun x _ => by
      by_cases h : x ∈ S <;> simp_all +decide [Finset.subset_iff]

/-- **Forgetting Lattice Closure**: The meet (infimum) of two valid forgetting
    congruences is again a valid forgetting congruence. This shows the set of
    valid forgetting operations forms a lattice. -/
theorem forgetting_congruences_closed_under_inf {α : Type*} {M : Type*} [Monoid M]
    (ms : MemorySystem α M)
    (c₁ c₂ : Con (FreeMonoid α))
    (h₁ : ∀ x y, ms.kernelCon.toSetoid.r x y → c₁.toSetoid.r x y)
    (h₂ : ∀ x y, ms.kernelCon.toSetoid.r x y → c₂.toSetoid.r x y) :
    ∀ x y, ms.kernelCon.toSetoid.r x y → (c₁ ⊓ c₂).toSetoid.r x y := by
  exact fun x y h => ⟨h₁ x y h, h₂ x y h⟩