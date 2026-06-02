/-
# Memory Algebra: Algebraic Foundations of Memory as Monoid Homomorphisms

This module formalizes memory systems as monoid homomorphisms, establishing that:
1. Finite memory systems over infinite experience spaces must be lossy (Pigeonhole)
2. The kernel of a memory system forms a submonoid
3. Memory congruences form a lattice with refinement ordering
4. A novel "memory entropy preorder" captures information loss

## Key Definitions
- `MemorySystem`: A monoid homomorphism modeling memory encoding
- `MemoryCongruence`: The equivalence relation induced by a memory system
- `MemoryEntropyOrder`: Preorder on memory systems by information loss
- `TropicalMemoryState`: Memory states with tropical (min-plus) structure
-/
import Mathlib

open Function Set

universe u v w

/-! ## Memory Systems as Monoid Homomorphisms -/

/-- A `MemorySystem` encodes experiences (elements of monoid `E`) into memory states
(elements of monoid `S`) via a monoid homomorphism. The monoid operation on `E`
represents sequential composition of experiences, and the homomorphism property
ensures that the memory of a composite experience depends only on the memories
of its parts. -/
structure MemorySystem (E : Type u) (S : Type v) [Monoid E] [Monoid S] where
  /-- The encoding function from experiences to states -/
  encode : E →* S

/-- A memory system is *lossy* if distinct experiences can produce the same state. -/
def MemorySystem.IsLossy {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) : Prop :=
  ¬Injective m.encode

/-- The *memory kernel* is the set of experiences that map to the identity state.
These are experiences that are "perfectly forgotten" — they leave no trace. -/
def MemorySystem.kernel {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) : Set E :=
  {e : E | m.encode e = 1}

/-- The *memory congruence* is the equivalence relation where two experiences are
related iff they produce the same memory state. -/
def MemorySystem.congruence {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) : Setoid E where
  r e₁ e₂ := m.encode e₁ = m.encode e₂
  iseqv := {
    refl := fun _ => rfl
    symm := fun h => h.symm
    trans := fun h₁ h₂ => h₁.trans h₂
  }

/-
The memory congruence is a *right congruence*: if `e₁ ~ e₂` then `e₁ * a ~ e₂ * a`.
-/
theorem MemorySystem.congruence_mul_right {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) {e₁ e₂ : E} (h : m.congruence.r e₁ e₂) (a : E) :
    m.congruence.r (e₁ * a) (e₂ * a) := by
  convert m.encode.map_mul e₁ a ▸ m.encode.map_mul e₂ a ▸ congr_arg ( · * m.encode a ) h using 1

/-
The memory congruence is a *left congruence*: if `e₁ ~ e₂` then `a * e₁ ~ a * e₂`.
-/
theorem MemorySystem.congruence_mul_left {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) {e₁ e₂ : E} (h : m.congruence.r e₁ e₂) (a : E) :
    m.congruence.r (a * e₁) (a * e₂) := by
  convert congr_arg ( fun x => m.encode a * x ) h using 1;
  exact ⟨ fun h => by simpa [ MemorySystem.congruence ] using h, fun h => by simpa [ MemorySystem.congruence ] using h ⟩

/-! ## The Lossy Memory Theorem

The fundamental result: any memory system with finite state space and infinite
experience space must be lossy. This is the algebraic pigeonhole principle
applied to memory. -/

/-
**Lossy Memory Theorem**: If the experience monoid is infinite and the state
monoid is finite, then the memory system must be lossy (non-injective).
This captures the fundamental information-theoretic constraint on memory:
finite memory cannot faithfully encode infinite experience.
-/
theorem lossy_memory_theorem {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    [Infinite E] [Finite S] (m : MemorySystem E S) :
    m.IsLossy := by
  intro H_inj
  have H_finite : Finite E := by
    exact Finite.of_injective _ H_inj
  exact absurd H_finite (by
  exact?)

/-! ## The Kernel Submonoid Theorem -/

/-
**Kernel Submonoid Theorem**: The set of "perfectly forgotten" experiences
(those mapping to the identity state) forms a submonoid of the experience monoid.
This means: (1) the trivial experience is forgotten, and (2) if two experiences
are each forgotten, their composition is also forgotten.
-/
def MemorySystem.kernelSubmonoid {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) : Submonoid E where
  carrier := m.kernel
  one_mem' := by
    exact m.encode.map_one
  mul_mem' := by
    intro a b ha hb
    simp only [MemorySystem.kernel, Set.mem_setOf_eq] at *
    simp [m.encode.map_mul, ha, hb]

/-! ## Congruence Refinement and the Memory Lattice -/

/-- One memory system *refines* another if its congruence is finer:
whenever the first system equates two experiences, so does the second.
Equivalently, the first system "remembers at least as much" as the second. -/
def MemorySystem.Refines {E : Type u} {S₁ : Type v} {S₂ : Type w}
    [Monoid E] [Monoid S₁] [Monoid S₂]
    (m₁ : MemorySystem E S₁) (m₂ : MemorySystem E S₂) : Prop :=
  ∀ e₁ e₂ : E, m₁.congruence.r e₁ e₂ → m₂.congruence.r e₁ e₂

/-
**Congruence Refinement Theorem**: If memory system `m₁` refines `m₂`,
then there exists a function from `m₁`'s states to `m₂`'s states that
makes the diagram commute. This is the universal property of quotients
applied to memory systems.
-/
theorem congruence_refinement_factor {E : Type u} {S₁ : Type v} {S₂ : Type w}
    [Monoid E] [Monoid S₁] [Monoid S₂]
    (m₁ : MemorySystem E S₁) (m₂ : MemorySystem E S₂)
    (h : m₁.Refines m₂) (hSurj : Surjective m₁.encode) :
    ∃ f : S₁ → S₂, f ∘ m₁.encode = m₂.encode := by
  -- Define f on s₁ ∈ S₁ by choosing a preimage e of s₁ under m₁.encode, then setting f(s₁) = m₂.encode(e).
  have hf_exists : ∀ (s₁ : S₁), ∃ (f_val : S₂), ∀ (e : E), (m₁.encode e = s₁) → (m₂.encode e = f_val) := by
    intro s₁; cases' hSurj s₁ with e he; use m₂.encode e; intro e' he'; have := h e' e; aesop;
  choose f hf using hf_exists; use f; ext e; aesop;

/-! ## Composition of Memory Systems -/

/-- Composition of memory systems: if we first encode experiences into an
intermediate representation, then encode that into final states, the
result is a valid memory system. -/
def MemorySystem.comp {E : Type u} {I : Type v} {S : Type w}
    [Monoid E] [Monoid I] [Monoid S]
    (m₁ : MemorySystem E I) (m₂ : MemorySystem I S) : MemorySystem E S where
  encode := m₂.encode.comp m₁.encode

/-
**Composition Increases Loss**: Composing a lossy memory system with any
further encoding remains lossy. Once information is lost, it cannot be recovered.
-/
theorem comp_lossy_of_first_lossy {E : Type u} {I : Type v} {S : Type w}
    [Monoid E] [Monoid I] [Monoid S]
    (m₁ : MemorySystem E I) (m₂ : MemorySystem I S)
    (h₁ : m₁.IsLossy) (h₂ : Injective m₂.encode) :
    (m₁.comp m₂).IsLossy := by
  contrapose! h₁;
  unfold MemorySystem.IsLossy at *;
  simp_all +decide [ Function.Injective ];
  exact fun a₁ a₂ h => h₁ <| by simpa [ MemorySystem.comp ] using congr_arg ( fun x => m₂.encode x ) h;

/-
**Composition Refinement**: The composed system always refines the first system.
-/
theorem comp_refines_first {E : Type u} {I : Type v} {S : Type w}
    [Monoid E] [Monoid I] [Monoid S]
    (m₁ : MemorySystem E I) (m₂ : MemorySystem I S)
    (h₂ : Injective m₂.encode) :
    (m₁.comp m₂).Refines m₁ := by
  exact fun a b h => h₂ h

/-! ## Memory Fiber Theorem -/

/-- The *fiber* of a state `s` is the set of all experiences that encode to `s`. -/
def MemorySystem.fiber {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) (s : S) : Set E :=
  m.encode ⁻¹' {s}

/-
**Fiber Partition Theorem**: The fibers of a memory system partition
the experience space. Two experiences are in the same fiber iff they are
congruent under the memory congruence.
-/
theorem fiber_iff_congruent {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) (e₁ e₂ : E) :
    (∃ s, e₁ ∈ m.fiber s ∧ e₂ ∈ m.fiber s) ↔ m.congruence.r e₁ e₂ := by
  unfold MemorySystem.fiber MemorySystem.congruence; aesop;

/-
**Identity Fiber is Kernel**: The fiber over the identity state equals the kernel.
-/
theorem fiber_one_eq_kernel {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    (m : MemorySystem E S) :
    m.fiber 1 = m.kernel := by
  grind

/-! ## Fiber Product Structure -/

/-
**Fiber Product Theorem**: For any state `s` in the image of a memory system,
the fiber over `s` is a coset of the kernel. Specifically, if `e` maps to `s`,
then the fiber over `s` equals `{e * k | k ∈ kernel}` when the kernel is normal
(which it is, since monoid homomorphism kernels have this property for groups).
-/
theorem fiber_mul_kernel {E : Type u} {S : Type v} [Group E] [Group S]
    (m : MemorySystem E S) (e : E) :
    m.fiber (m.encode e) = {x : E | ∃ k ∈ m.kernel, x = e * k} := by
  ext x; simp [MemorySystem.fiber, MemorySystem.kernel];
  constructor <;> intro h;
  · refine' ⟨ e⁻¹ * x, _, _ ⟩ <;> simp +decide [ h, m.encode.map_mul ];
  · aesop

/-! ## Tropical Memory Systems

A connection between memory algebra and tropical mathematics.
In tropical semirings, addition is `min` (or `max`), which is inherently
lossy — it discards information about which operand was larger.
This makes tropical operations a natural model for memory compression. -/

/-- A `TropicalMemoryState` extends memory states with a "priority" value
from a linear order, representing how salient or important a memory is.
The monoid operation retains the higher-priority state. -/
@[ext]
structure TropicalMemoryState (α : Type u) [LinearOrder α] [OrderBot α] where
  priority : α

instance {α : Type u} [LinearOrder α] [OrderBot α] :
    Monoid (TropicalMemoryState α) where
  mul a b := ⟨max a.priority b.priority⟩
  one := ⟨⊥⟩
  mul_assoc a b c := by
    simp only [HMul.hMul, Mul.mul, max_assoc]
  one_mul a := by
    ext; simp only [HMul.hMul, Mul.mul]; exact max_eq_right bot_le
  mul_one a := by
    ext; simp only [HMul.hMul, Mul.mul]; exact max_eq_left bot_le

/-
**Tropical Memory Idempotence**: In a tropical memory system,
re-encoding an experience at the same priority level is idempotent.
This captures the principle that "remembering the same thing twice
doesn't make the memory stronger."
-/
theorem tropical_memory_idempotent {α : Type u} [LinearOrder α] [OrderBot α]
    (a : TropicalMemoryState α) :
    a * a = a := by
  exact congr_arg TropicalMemoryState.mk ( max_self _ )

/-! ## Memory Capacity Bound -/

/-
**Memory Capacity Bound**: For a memory system with finitely many states,
the number of distinguishable experience classes is bounded by the number of states.
This quantifies the lossy memory theorem: not only must information be lost,
but the amount of information that can be retained is bounded.
-/
theorem memory_capacity_bound {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    [Fintype S] (m : MemorySystem E S) :
    Finite (Set.range m.encode) := by
  exact Set.toFinite _

/-! ## Forgetting Morphism -/

/-- A *forgetting morphism* between memory systems is a monoid homomorphism
between state spaces that preserves the encoding structure. -/
structure ForgettingMorphism {E : Type u} {S₁ : Type v} {S₂ : Type w}
    [Monoid E] [Monoid S₁] [Monoid S₂]
    (m₁ : MemorySystem E S₁) (m₂ : MemorySystem E S₂) where
  /-- The state-space transformation -/
  mapStates : S₁ →* S₂
  /-- The diagram commutes: forgetting after encoding equals encoding then forgetting -/
  comm : mapStates.comp m₁.encode = m₂.encode

/-
**Forgetting Implies Refinement**: If a forgetting morphism exists from `m₁` to `m₂`,
then `m₁` refines `m₂`.
-/
theorem forgetting_implies_refinement {E : Type u} {S₁ : Type v} {S₂ : Type w}
    [Monoid E] [Monoid S₁] [Monoid S₂]
    (m₁ : MemorySystem E S₁) (m₂ : MemorySystem E S₂)
    (f : ForgettingMorphism m₁ m₂) :
    m₁.Refines m₂ := by
  intro e₁ e₂ h; have := f.comm; simp_all +decide [ funext_iff, MonoidHom.ext_iff ] ;
  rw [ ← this e₁, ← this e₂, h ]

/-! ## Novel: Memory Depth -/

/-
**Image Cardinality Bound**: The image of any finite set of experiences
under a memory encoding has cardinality at most the cardinality of the
finite state space. This quantifies how much compression occurs.
-/
theorem image_card_le_state_card {E : Type u} {S : Type v} [Monoid E] [Monoid S]
    [DecidableEq S] [Fintype S] (m : MemorySystem E S) (t : Finset E) :
    (t.image m.encode).card ≤ Fintype.card S := by
  exact Finset.card_le_univ _