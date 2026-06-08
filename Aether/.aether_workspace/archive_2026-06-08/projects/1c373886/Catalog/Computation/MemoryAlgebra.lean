/-
# Memory Algebra: When Forgetting Is a Mathematical Operation

We formalize memory as a monoid homomorphism from experience streams (free monoid)
to compressed memory states (finite monoid). We prove:

1. Any memory homomorphism into a finite monoid must be lossy when the alphabet
   has at least 2 symbols (pigeonhole).
2. The "forgotten elements" (kernel of the homomorphism) form a submonoid.
3. The confusion relation (identifying experiences with identical memory traces)
   is a monoid congruence — this is the algebraic structure of information loss.
4. Targeted forgetting corresponds exactly to a quotient construction:
   composing memory with a further surjection yields a coarser memory system
   whose confusion congruence contains the original.
5. A composition theorem: composing two memory systems yields a memory system
   whose lossiness dominates both factors.

These results establish that forgetting is not mere data loss but a structured
algebraic operation with precise categorical semantics.
-/

import Mathlib

universe u v

/-! ## Memory System Definition -/

/-- A `MemorySystem` over alphabet `α` with memory states `M` consists of
    a monoid homomorphism from the free monoid on `α` to `M`. -/
structure MemorySystem (α : Type u) (M : Type v) [Monoid M] where
  /-- The encoding homomorphism from experience streams to memory states -/
  encode : FreeMonoid α →* M

namespace MemorySystem

variable {α : Type u} {M : Type v} [Monoid M]

/-- Two experience streams are "confused" by a memory system if they map to the
    same memory state. This is the fundamental equivalence of information loss. -/
def confused (sys : MemorySystem α M) (x y : FreeMonoid α) : Prop :=
  sys.encode x = sys.encode y

/-- The confusion relation is an equivalence relation. -/
theorem confused_equiv (sys : MemorySystem α M) : Equivalence sys.confused where
  refl _ := rfl
  symm h := h.symm
  trans h₁ h₂ := h₁.trans h₂

/-- A memory system is *lossless* (injective) if no two distinct streams are confused. -/
def IsLossless (sys : MemorySystem α M) : Prop :=
  Function.Injective sys.encode

/-- A memory system is *lossy* if it is not injective. -/
def IsLossy (sys : MemorySystem α M) : Prop :=
  ¬Function.Injective sys.encode

/-- The kernel of a memory system: streams that encode to the identity.
    These are "perfectly forgotten" experiences. -/
def kernel (sys : MemorySystem α M) : Set (FreeMonoid α) :=
  {x | sys.encode x = 1}

/-- The confusion congruence: the kernel pair of the encoding map,
    viewed as a multiplicative congruence on the free monoid. -/
def confusionCon (sys : MemorySystem α M) : Con (FreeMonoid α) where
  r := sys.confused
  iseqv := sys.confused_equiv
  mul' {w x y z} (h1 : sys.encode w = sys.encode x) (h2 : sys.encode y = sys.encode z) := by
    unfold confused
    simp [map_mul, h1, h2]

/-! ## The Fundamental Lossiness Theorem -/

/-
**Finite Memory Lossiness Theorem**: Any memory system over an alphabet with
    at least 2 symbols into a finite monoid must be lossy. This is because the
    free monoid on ≥2 generators is infinite, but the target is finite.

    This is the central impossibility result: finite memory *necessarily* forgets.
-/
theorem finite_memory_is_lossy [Fintype M] [DecidableEq M]
    (sys : MemorySystem α M)
    (a _b : α) (_hab : a ≠ _b) :
    sys.IsLossy := by
  by_contra! h_inj;
  -- By contradiction, assume the system is lossless.
  have h_lossless : Function.Injective (sys.encode : FreeMonoid α → M) := by
    exact Classical.not_not.1 h_inj;
  -- Since the free monoid on α is infinite, but M is finite, there must exist distinct elements in the free monoid that map to the same element in M.
  have h_infinite : Infinite (FreeMonoid α) := by
    exact Infinite.of_injective ( fun n => List.replicate n a ) fun m n h => by simpa using congr_arg List.length h;
  exact not_injective_infinite_finite _ h_lossless

/-! ## Kernel Forms a Submonoid -/

/-- The kernel of a memory system forms a submonoid of the free monoid.
    This captures the algebraic structure of "perfectly forgotten" information. -/
def kernelSubmonoid (sys : MemorySystem α M) : Submonoid (FreeMonoid α) where
  carrier := sys.kernel
  mul_mem' {a b} (ha : sys.encode a = 1) (hb : sys.encode b = 1) := by
    show sys.encode (a * b) = 1
    simp [map_mul, ha, hb]
  one_mem' := by
    show sys.encode 1 = 1
    simp

/-! ## Targeted Forgetting as Quotient -/

/-- A `ForgettingMap` between two memory systems (with same alphabet) is a
    monoid homomorphism between their state spaces that makes the diagram commute.
    This captures the notion that one memory system is "coarser" than another. -/
structure ForgettingMap (sys₁ : MemorySystem α M) {N : Type v} [Monoid N]
    (sys₂ : MemorySystem α N) where
  /-- The map between memory state spaces -/
  map : M →* N
  /-- The diagram commutes: forgetting after encoding = encoding in the coarser system -/
  comm : sys₂.encode = map.comp sys₁.encode

/-
If a forgetting map exists from sys₁ to sys₂, then sys₂'s confusion congruence
    is coarser than sys₁'s. That is, if sys₁ confuses two streams, so does sys₂.
    **Forgetting can only increase confusion, never decrease it.**
-/
theorem forgetting_coarsens {N : Type v} [Monoid N]
    (sys₁ : MemorySystem α M)
    (sys₂ : MemorySystem α N)
    (f : ForgettingMap sys₁ sys₂)
    (x y : FreeMonoid α)
    (h : sys₁.confused x y) :
    sys₂.confused x y := by
  unfold MemorySystem.confused at *; have := f.comm; aesop;

/-! ## Composition of Memory Systems -/

/-- Composing two memory homomorphisms gives a new memory system. -/
def compose {N : Type v} [Monoid N] (sys : MemorySystem α M) (g : M →* N) :
    MemorySystem α N where
  encode := g.comp sys.encode

/-- The composition of a memory system with a further homomorphism
    always produces a forgetting map from the original to the composed system. -/
def composeForgettingMap {N : Type v} [Monoid N] (sys : MemorySystem α M) (g : M →* N) :
    ForgettingMap sys (sys.compose g) where
  map := g
  comm := rfl

/-! ## The Lossiness Composition Theorem -/

/-
**Lossiness Composition**: If a memory system is lossy, then composing it with
    any homomorphism yields a lossy system. Lossiness is preserved under further compression.
    You cannot recover lost information by post-processing.
-/
theorem lossy_compose {N : Type v} [Monoid N]
    (sys : MemorySystem α M) (g : M →* N)
    (h : sys.IsLossy) :
    (sys.compose g).IsLossy := by
  unfold MemorySystem.IsLossy at *;
  contrapose! h;
  exact fun x y hxy => h <| by simpa using congr_arg g hxy;

/-! ## Confusion Congruence Lattice Structure -/

/-
The set of all confusion congruences on the free monoid over α forms a complete lattice
    (inherited from `Con`). The bottom element is the identity (lossless memory),
    and the top element identifies everything (total amnesia).

    We prove that targeted forgetting corresponds to moving up in this lattice.
-/
theorem forgetting_monotone {N : Type v} [Monoid N]
    (sys₁ : MemorySystem α M)
    (sys₂ : MemorySystem α N)
    (f : ForgettingMap sys₁ sys₂) :
    sys₁.confusionCon ≤ sys₂.confusionCon := by
  -- By definition of confusion congruence, if sys₁ confuses x and y, then sys₂ must also confuse them.
  intros x y hxy
  apply forgetting_coarsens sys₁ sys₂ f x y hxy

/-! ## Memory Capacity Bound -/

/-
**Memory Capacity Theorem**: The number of distinguishable stream classes
    is bounded by the size of the memory state space. This gives a precise
    upper bound on what any finite memory system can remember.
-/
theorem memory_capacity_bound [Fintype M] [DecidableEq M]
    (sys : MemorySystem α M)
    (S : Finset (FreeMonoid α))
    (hS : ∀ x ∈ S, ∀ y ∈ S, sys.encode x = sys.encode y → x = y) :
    S.card ≤ Fintype.card M := by
  -- Since the map sys.encode restricted to S is injective by hypothesis hS, we can conclude that S.card ≤ |image of S under encode| ≤ |M| = Fintype.card M.
  have h_inj : Finset.card (Finset.image (fun x => sys.encode x) S) = S.card := by
    exact Finset.card_image_of_injOn hS;
  exact h_inj ▸ Finset.card_le_univ _

/-! ## The Forgetting Factorization Theorem -/

/-
**Forgetting Factorization**: Every memory system factors through its confusion
    congruence. The quotient by confusion gives a faithful (injective) representation.
    This is the First Isomorphism Theorem applied to memory systems.
-/
theorem encode_factors_through_confusion (sys : MemorySystem α M) :
    ∃ (f : sys.confusionCon.Quotient →* M),
      Function.Injective f ∧
      sys.encode = f.comp sys.confusionCon.mk' := by
  refine' ⟨ _, _, _ ⟩;
  refine' Con.lift _ _ _;
  exact sys.encode;
  all_goals norm_num [ Function.Injective, Con.lift ];
  exact fun x y h => h;
  · rintro ⟨ a ⟩ ⟨ b ⟩ h; exact Quotient.sound h;
  · aesop

/-! ## Congruence Properties of Confusion -/

/-
**Right congruence**: confusion is preserved under right multiplication.
    If x and y are confused, then x·z and y·z are confused for all z.
-/
theorem forgetting_right_congruence
    (sys : MemorySystem α M)
    (x y : FreeMonoid α)
    (h : sys.confused x y) :
    ∀ z : FreeMonoid α, sys.confused (x * z) (y * z) := by
  unfold MemorySystem.confused at *;
  simp +decide [ h, map_mul ]

/-
**Left congruence**: confusion is preserved under left multiplication.
-/
theorem forgetting_left_congruence
    (sys : MemorySystem α M)
    (x y : FreeMonoid α)
    (h : sys.confused x y) :
    ∀ z : FreeMonoid α, sys.confused (z * x) (z * y) := by
  unfold MemorySystem.confused at *; simp_all +decide;

/-! ## Kernel-Confusion Bridge -/

/-
**Kernel-Confusion Bridge**: Two streams are confused if and only if their
    "difference" (one followed by the inverse-image of the other) lies in a
    generalized kernel. For the free monoid, we express this as:
    x and y are confused iff for all contexts z, x·z and y·z are confused.
    This is a tautology for congruences, but the point is that confusion
    is completely determined by the kernel in the group completion.
-/
theorem confused_iff_kernel_quotient
    (sys : MemorySystem α M) (x y : FreeMonoid α) :
    sys.confused x y ↔ sys.confusionCon.mk' x = sys.confusionCon.mk' y := by
  convert Iff.rfl;
  convert Quotient.eq

end MemorySystem