/-
# Memory Algebra: When Forgetting Is a Mathematical Operation

This module formalizes memory as a monoid homomorphism from experience streams
(free monoids) to compressed state representations (finite monoids). We prove:

1. Any such homomorphism with finite codomain must be lossy (non-injective)
   when the experience alphabet has ≥ 2 symbols.
2. The information loss forms a congruence on the experience monoid, and
   the preimage of the identity (the "oblivion kernel") is a submonoid.
3. Targeted forgetting corresponds to a quotient construction: if one memory
   system forgets strictly more than another, the additional forgetting factors
   through a canonical quotient map.
4. Memory composition can only increase information loss (monotonicity).

## Mathematical Framework

An **experience stream** over alphabet α is an element of FreeMonoid α (= List α).
A **memory system** is a monoid homomorphism φ : FreeMonoid α →* M where M is finite.
The **information loss congruence** of φ is Con.ker φ.
The **oblivion kernel** is MonoidHom.mker φ = {x | φ(x) = 1}.
**Targeted forgetting** from memory system φ₁ to φ₂ exists when Con.ker φ₁ ≤ Con.ker φ₂,
and is realized by the quotient lift Con.lift.
-/
import Mathlib

open FreeMonoid

/-- A `MemorySystem` over alphabet `α` with state space `S` is a monoid homomorphism
    from the free monoid on `α` (experience streams) to `S` (compressed states).
    We require `S` to be a finite monoid, modeling bounded memory. -/
structure MemorySystem (α : Type*) (S : Type*) [Monoid S] [Fintype S] where
  /-- The encoding function, a monoid homomorphism from experiences to states -/
  encode : FreeMonoid α →* S

namespace MemorySystem

variable {α : Type*} {S T U : Type*}
         [Monoid S] [Fintype S] [Monoid T] [Fintype T] [Monoid U] [Fintype U]

/-- The **information loss congruence** of a memory system: two experience streams
    are identified iff they map to the same memory state. -/
def infoLossCon (mem : MemorySystem α S) : Con (FreeMonoid α) :=
  Con.ker mem.encode

/-- The **oblivion kernel** of a memory system: the submonoid of experience streams
    that are mapped to the identity (completely forgotten). -/
def oblivionKernel (mem : MemorySystem α S) : Submonoid (FreeMonoid α) :=
  MonoidHom.mker mem.encode

/-- A memory system is **lossless** if its encoding is injective. -/
def IsLossless (mem : MemorySystem α S) : Prop :=
  Function.Injective mem.encode

/-- A memory system is **lossy** if its encoding is not injective. -/
def IsLossy (mem : MemorySystem α S) : Prop :=
  ¬ Function.Injective mem.encode

/-- Memory system `mem₂` **forgets more** than `mem₁` if whenever `mem₁` identifies
    two streams, so does `mem₂`. Equivalently, the information loss congruence of
    `mem₁` is contained in that of `mem₂`. -/
def ForgetsMoreThan (mem₁ mem₂ : MemorySystem α S) : Prop :=
  mem₁.infoLossCon ≤ mem₂.infoLossCon

/-- A **forgetting map** from memory system `mem₁` to `mem₂` is a monoid homomorphism
    from the quotient by `mem₁`'s congruence to `mem₂`'s state space, witnessing that
    the additional forgetting factors through the quotient. -/
noncomputable def forgettingMap (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α S)
    (h : mem₁.infoLossCon ≤ mem₂.infoLossCon) :
    mem₁.infoLossCon.Quotient →* S :=
  Con.lift mem₁.infoLossCon mem₂.encode h

end MemorySystem

/-! ## Core Theorems -/

section LossinessTheorem

/-
**Memory Compression Theorem**: Any memory system over an alphabet with ≥ 2 symbols
    must be lossy. The free monoid on ≥ 2 generators is infinite, while the state space
    is finite, so by pigeonhole the encoding cannot be injective.
-/
theorem memory_compression_lossy (α : Type*) [Fintype α] (hα : 2 ≤ Fintype.card α)
    (S : Type*) [Monoid S] [Fintype S] [DecidableEq S]
    (mem : MemorySystem α S) : mem.IsLossy := by
  have h_infinite : Infinite (FreeMonoid α) := by
    obtain ⟨ a, b, h ⟩ := Fintype.one_lt_card_iff.mp hα;
    exact Infinite.of_injective ( fun n => List.replicate n a ) fun m n hmn => by simpa using congr_arg List.length hmn;
  exact fun h => h_infinite.not_finite <| Finite.of_injective _ h

/-
The information loss congruence is nontrivial when the system is lossy:
    there exist distinct streams mapped to the same state.
-/
theorem lossy_implies_nontrivial_congruence (α : Type*) [Fintype α] (hα : 2 ≤ Fintype.card α)
    (S : Type*) [Monoid S] [Fintype S] [DecidableEq S]
    (mem : MemorySystem α S) :
    ∃ x y : FreeMonoid α, x ≠ y ∧ mem.encode x = mem.encode y := by
  by_contra! h;
  -- Since FreeMonoid α is infinite, for any n we can find a Finset of size n in it. In particular, take n = Fintype.card S + 1.
  have h_inf : Infinite (FreeMonoid α) := by
    exact Infinite.of_injective ( fun n => List.replicate n ( Classical.choose ( Finset.card_pos.mp ( pos_of_gt hα ) ) ) ) fun a b hab => by simpa using congr_arg List.length hab;
  exact not_injective_infinite_finite mem.encode fun x y hxy => Classical.not_not.1 fun hxy' => h x y hxy' hxy

end LossinessTheorem

section OblivionKernel

/-
The oblivion kernel is nontrivial (contains a non-identity element) when the
    memory system is lossy AND the state monoid is a group. In general monoids,
    the oblivion kernel can be trivial even when the system is lossy.

    Proof idea: By pigeonhole, ∃ x ≠ y with φ(x) = φ(y). Then φ(x * y⁻¹) = 1 in
    a group, and x * y⁻¹ ≠ 1 since x ≠ y in the free monoid. But FreeMonoid is NOT
    a group, so we need a different approach. We use the fact that if φ(x) = φ(y) with
    x ≠ y, then φ(x * y⁻¹) = 1... but we can't invert in FreeMonoid.

    Actually, the correct statement for groups: since G is finite and FreeMonoid α is
    infinite (for |α| ≥ 2), by pigeonhole there exist distinct x, y with φ(x) = φ(y).
    Consider the words x and y. Since φ is a monoid hom and G is a group,
    φ(x) * φ(y)⁻¹ = 1, i.e., φ(x * y⁻¹_in_G) = 1. But we need x * y⁻¹ to be
    expressible in FreeMonoid... This doesn't work directly.

    Better: among the infinitely many words {aⁿ : n ∈ ℕ} (where a ∈ α), two must
    collide: φ(aⁿ) = φ(aᵐ) for n > m. Then φ(aⁿ⁻ᵐ) = 1 in a group... but again
    we can't subtract exponents in a free monoid.

    Actually in a group: φ(aⁿ) = φ(aᵐ) means φ(a)ⁿ = φ(a)ᵐ, so φ(a)ⁿ⁻ᵐ = 1
    (in the group), and thus φ(aⁿ⁻ᵐ) = φ(a)ⁿ⁻ᵐ = 1. And aⁿ⁻ᵐ ≠ 1 since n > m ≥ 0.
    This works! The key is that {aⁿ}ₙ maps to {φ(a)ⁿ}ₙ and in a finite group
    φ(a) has finite order d, so φ(aᵈ) = 1 and aᵈ ≠ 1 (for d ≥ 1 and a ≠ ε).
-/
theorem oblivion_kernel_nontrivial_of_group
    (α : Type*) [Fintype α] (hα : 2 ≤ Fintype.card α)
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (mem : MemorySystem α G) :
    ∃ x : FreeMonoid α, x ≠ 1 ∧ x ∈ mem.oblivionKernel := by
  obtain ⟨a, ha⟩ : ∃ a : α, True := by
    exact ⟨ Classical.choose ( Finset.card_pos.mp ( pos_of_gt hα ) ), trivial ⟩;
  obtain ⟨d, hd⟩ : ∃ d : ℕ, 0 < d ∧ mem.encode (FreeMonoid.of a ^ d) = 1 := by
    exact ⟨ orderOf ( mem.encode ( of a ) ), orderOf_pos _, by simp +decide [ pow_orderOf_eq_one ] ⟩;
  refine' ⟨ of a ^ d, _, hd.2 ⟩;
  induction hd.1 <;> simp_all +decide [ pow_succ' ]

end OblivionKernel

section ForgettingComposition

/-
**Forgetting Composition Theorem**: If memory system `mem₂` forgets more than `mem₁`
    (i.e., `Con.ker mem₁.encode ≤ Con.ker mem₂.encode`), then `mem₂.encode` factors
    through the quotient by `mem₁`'s congruence. The factoring map is the "forgetting map".
-/
theorem forgetting_factors_through_quotient
    {α S : Type*} [Monoid S] [Fintype S]
    (mem₁ mem₂ : MemorySystem α S)
    (h : mem₁.infoLossCon ≤ mem₂.infoLossCon) :
    ∀ x : FreeMonoid α,
      (mem₁.forgettingMap mem₂ h) (Con.mk' mem₁.infoLossCon x) = mem₂.encode x := by
  unfold MemorySystem.forgettingMap; aesop;

/-
**Monotonicity of Information Loss**: Composing a memory system with a further
    monoid homomorphism can only increase the information loss congruence.
-/
theorem info_loss_monotone_of_compose
    {α S T : Type*} [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    (mem : MemorySystem α S) (f : S →* T) :
    mem.infoLossCon ≤ (MemorySystem.mk (f.comp mem.encode) : MemorySystem α T).infoLossCon := by
  unfold MemorySystem.infoLossCon;
  intro x y; aesop;

end ForgettingComposition

section MemoryCapacity

/-
**Memory Capacity Bound**: The number of distinguishable experience classes
    is bounded by the cardinality of the state space.
-/
theorem memory_capacity_bound
    {α S : Type*} [Monoid S] [Fintype S] [DecidableEq S]
    (mem : MemorySystem α S) (xs : Finset (FreeMonoid α))
    (h_distinct : ∀ x ∈ xs, ∀ y ∈ xs, mem.encode x = mem.encode y → x = y) :
    xs.card ≤ Fintype.card S := by
  exact Finset.card_le_univ _ |> le_trans ( Finset.card_le_card ( show xs.image mem.encode ⊆ Finset.univ from Finset.subset_univ _ ) ) |> le_trans ( by rw [ Finset.card_image_of_injOn h_distinct ] ) |> le_trans <| by simp +decide ;

end MemoryCapacity

section CongruenceLattice

/-
**Minimum Forgetting**: The trivial congruence (equality) corresponds to
    perfect memory (no forgetting).
-/
theorem bot_con_is_perfect_memory (α : Type*) :
    ∀ x y : FreeMonoid α, (⊥ : Con (FreeMonoid α)) x y ↔ x = y := by
  aesop

/-
**Maximum Forgetting**: The total congruence (everything identified) corresponds to
    complete amnesia.
-/
theorem top_con_is_total_amnesia (α : Type*) (x y : FreeMonoid α) :
    (⊤ : Con (FreeMonoid α)) x y := by
  trivial

end CongruenceLattice

section ForgettingFunctor

/-- A **memory morphism** from (α, S, mem₁) to (α, T, mem₂) is a monoid hom f : S →* T
    such that f ∘ mem₁.encode = mem₂.encode. This witnesses that mem₂ is obtained from
    mem₁ by further processing (potentially losing information). -/
structure MemoryMorphism {α : Type*}
    {S : Type*} [Monoid S] [Fintype S]
    {T : Type*} [Monoid T] [Fintype T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T) where
  map : S →* T
  commutes : map.comp mem₁.encode = mem₂.encode

namespace MemoryMorphism

/-
A memory morphism implies the target forgets at least as much as the source.
-/
theorem morphism_implies_more_forgetting {α S T : Type*}
    [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    {mem₁ : MemorySystem α S} {mem₂ : MemorySystem α T}
    (f : MemoryMorphism mem₁ mem₂) :
    ∀ x y : FreeMonoid α, mem₁.encode x = mem₁.encode y → mem₂.encode x = mem₂.encode y := by
  intro x y hxy;
  rw [ ← f.commutes, MonoidHom.comp_apply, MonoidHom.comp_apply, hxy ]

/-- Identity memory morphism. -/
def id_ {α S : Type*} [Monoid S] [Fintype S] (mem : MemorySystem α S) :
    MemoryMorphism mem mem where
  map := MonoidHom.id S
  commutes := by ext; simp

end MemoryMorphism

end ForgettingFunctor

/-! ## Conjecture: Optimal Memory Bound

**Conjecture**: For any memory system with state space of size m over alphabet of size k ≥ 2,
the minimum congruence class has size at least ⌈k^n / m⌉ for streams of length n.
This would give a sharp lower bound on information loss.

**Test**: Verify computationally for k=2, m=4, n=3: minimum class size ≥ ⌈8/4⌉ = 2.
-/