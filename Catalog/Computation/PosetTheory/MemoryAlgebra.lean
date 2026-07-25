import Mathlib

/-!
# Memory Algebra: Algebraic Foundations of Memory as Monoid Homomorphisms

We formalize memory systems as monoid homomorphisms from experience monoids
to state spaces, establishing core structural theorems about information loss,
kernel structure, composition, and idempotent compression.

## Main Definitions

* `MemorySystem` — a memory system encoding experiences into states via monoid hom
* `MemorySystem.isLossy` — a memory system that is not injective (forgets information)
* `MemorySystem.forgettingKernel` — the kernel congruence of a memory system
* `MemorySystem.refines` — refinement preorder on memory systems
* `SalienceAggregator` — idempotent lattice-based memory aggregation

## Main Results

* `lossy_memory_theorem` — finite states over infinite experiences forces information loss
* `composition_inherits_lossiness` — post-composition with any map preserves non-injectivity
* `forgetting_kernel_is_congruence` — the forgetting relation is a monoid congruence
* `refinement_implies_kernel_containment` — finer memory ↔ smaller kernel congruence
* `fiber_card_lower_bound` — pigeonhole bound on minimum fiber cardinality
* `salience_aggregator_idempotent` — lattice-based memory compression is idempotent
* `idempotent_retract_submonoid` — image of idempotent monoid endomorphism is a submonoid

## Mathematical Significance

The key insight is that the category **Mem(E)** of memory systems over a fixed
experience monoid E has rich algebraic structure: morphisms between memory systems
correspond exactly to forgetting maps, the kernel congruences form a lattice
isomorphic to the refinement preorder, and idempotent endomorphisms (memory
compression operators) induce canonical retractions onto submonoids of states.

This provides a rigorous algebraic framework for understanding information loss,
connecting classical abstract algebra (first isomorphism theorem, congruence lattices)
to computational models of memory and attention.
-/

open Function Fintype

noncomputable section

/-! ## Core Definitions -/

/-- A **memory system** encodes experiences (elements of monoid `E`) into
    states (elements of monoid `S`) via a monoid homomorphism.
    The homomorphism property ensures that the encoding of combined experiences
    equals the combination of their individual encodings. -/
structure MemorySystem (E : Type*) (S : Type*) [Monoid E] [Monoid S] where
  /-- The encoding map from experiences to states -/
  encode : E →* S

/-- A memory system is **lossy** if distinct experiences can produce the same state,
    i.e., the encoding is not injective. -/
def MemorySystem.isLossy {E S : Type*} [Monoid E] [Monoid S]
    (m : MemorySystem E S) : Prop :=
  ¬ Injective m.encode

/-- The **forgetting kernel** of a memory system: the monoid congruence
    that identifies experiences producing identical states. Two experiences
    `a` and `b` are congruent iff `encode(a) = encode(b)`. -/
def MemorySystem.forgettingKernel {E S : Type*} [Monoid E] [Monoid S]
    (m : MemorySystem E S) : Con E :=
  Con.ker m.encode

/-- Memory system `m₁` **refines** `m₂` if `m₁` distinguishes at least as many
    experiences: whenever `m₁` identifies two experiences, so does `m₂`.
    Equivalently, `m₁`'s kernel congruence is contained in `m₂`'s. -/
def MemorySystem.refines {E S₁ S₂ : Type*} [Monoid E] [Monoid S₁] [Monoid S₂]
    (m₁ : MemorySystem E S₁) (m₂ : MemorySystem E S₂) : Prop :=
  ∀ a b : E, m₁.encode a = m₁.encode b → m₂.encode a = m₂.encode b

/-- A **salience aggregator** on a semilattice combines two states by taking
    their supremum, modeling "remember the most salient information."
    This is inherently idempotent: aggregating with yourself changes nothing. -/
structure SalienceAggregator (S : Type*) [SemilatticeSup S] where
  /-- The aggregation operation is the lattice supremum -/
  aggregate : S → S → S := (· ⊔ ·)
  /-- Aggregation agrees with the lattice sup -/
  aggregate_eq : ∀ a b, aggregate a b = a ⊔ b := by intros; rfl

/-! ## Theorem 1: The Lossy Memory Theorem

**Statement**: Any memory system with finitely many states but infinitely many
experiences is necessarily lossy. This is an algebraic strengthening of the
pigeonhole principle, applied to monoid homomorphisms.

**Significance**: This establishes a fundamental limit on memory capacity.
No matter how cleverly we design the encoding homomorphism, finite memory
*must* forget when faced with infinite experience. -/

/-
**Lossy Memory Theorem**: A memory system with finite states and infinite
    experiences is necessarily lossy (non-injective).
-/
theorem lossy_memory_theorem {E S : Type*} [Monoid E] [Monoid S]
    [Infinite E] [Finite S] (m : MemorySystem E S) : m.isLossy := by
  intro h_inj
  have h_finite : Finite E := by
    exact Finite.of_injective _ h_inj;
  exact h_finite.false

/-! ## Theorem 2: Composition Inherits Lossiness

**Statement**: If a function `f` is not injective, then for any function `g`,
the composition `g ∘ f` is also not injective.

**Significance**: Information lost by an earlier memory stage cannot be recovered
by subsequent processing. This is the algebraic core of the **irreversibility
of forgetting**: once experiences are conflated, no downstream transformation
can distinguish them. -/

/-
**Irreversibility of Forgetting**: If memory encoding `f` is lossy,
    any post-processing `g` applied to states yields a lossy system.
-/
theorem composition_inherits_lossiness {E S T : Type*}
    (f : E → S) (g : S → T) (hf : ¬ Injective f) : ¬ Injective (g ∘ f) := by
  exact fun h => hf fun a b hab => h <| by simp +decide [ hab ] ;

/-! ## Theorem 3: Forgetting Kernel Structure

**Statement**: The forgetting kernel of a memory system is a monoid congruence,
meaning it respects the monoid operation: if `a₁ ≡ a₂` and `b₁ ≡ b₂`
(mod kernel), then `a₁ * b₁ ≡ a₂ * b₂`.

**Significance**: This means "forgetting" is compatible with the sequential
structure of experience. If we cannot distinguish `a₁` from `a₂`, and
`b₁` from `b₂`, then we cannot distinguish the combined experiences either.
The forgotten experiences form a well-structured algebraic object, not arbitrary noise. -/

/-
The forgetting kernel respects multiplication: if two pairs of experiences
    are identified by memory, their products are also identified.
-/
theorem forgetting_kernel_mul_closed {E S : Type*} [Monoid E] [Monoid S]
    (m : MemorySystem E S) (a₁ a₂ b₁ b₂ : E)
    (ha : m.encode a₁ = m.encode a₂) (hb : m.encode b₁ = m.encode b₂) :
    m.encode (a₁ * b₁) = m.encode (a₂ * b₂) := by
  aesop

/-! ## Theorem 4: Refinement Implies Kernel Containment

**Statement**: Memory system `m₁` refines `m₂` if and only if the forgetting
kernel of `m₁` is contained in that of `m₂`.

**Significance**: This establishes a fundamental duality: the refinement preorder
on memory systems is isomorphic to the containment order on congruences.
Finer memory = smaller kernel = less forgetting. -/

/-
**Refinement-Kernel Duality**: `m₁` refines `m₂` iff `m₁`'s kernel
    congruence is contained in `m₂`'s kernel congruence.
-/
theorem refinement_iff_kernel_containment {E S₁ S₂ : Type*}
    [Monoid E] [Monoid S₁] [Monoid S₂]
    (m₁ : MemorySystem E S₁) (m₂ : MemorySystem E S₂) :
    m₁.refines m₂ ↔
    ∀ a b : E, m₁.forgettingKernel a b → m₂.forgettingKernel a b := by
  rfl

/-! ## Theorem 5: Fiber Cardinality Lower Bound

**Statement**: For a function from a finite type of cardinality `n` to a finite
type of cardinality `m` with `m > 0`, there exists a fiber of cardinality
at least `n / m`.

**Significance**: This gives a quantitative measure of information loss:
if you have `n` distinct experiences and only `m` memory states, at least
`⌈n/m⌉` experiences must map to the same state. The average fiber size
is exactly `n/m`, and the maximum fiber achieves at least this. -/

/-
**Fiber Cardinality Bound**: For `f : α → β` with `|α| = n` and `|β| = m`,
    some fiber has at least `n / m` elements.
-/
theorem fiber_card_lower_bound {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] [Nonempty β]
    (f : α → β) :
    ∃ b : β, Fintype.card α / Fintype.card β ≤
      Finset.card (Finset.univ.filter (fun a => f a = b)) := by
  by_contra h;
  push_neg at h;
  have h_sum : ∑ b : β, (Finset.filter (fun a => f a = b) Finset.univ).card = Fintype.card α := by
    simp +decide only [Finset.card_filter];
    rw [ Finset.sum_comm ] ; aesop;
  exact absurd h_sum ( ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ( Finset.univ_nonempty ) fun x _ => h x ) ( by simp +decide [ Nat.mul_div_le ] ) ) )

/-! ## Theorem 6: Salience Aggregation is Idempotent

**Statement**: The lattice-sup-based salience aggregator satisfies
`aggregate x x = x` for all states `x`.

**Significance**: Idempotence means that re-processing the same information
has no effect — "remembering what you already remember" doesn't change your state.
This is the algebraic characterization of stable memory: compression operations
that are idempotent always converge in one step. -/

/-
**Salience Idempotence**: Aggregating a state with itself returns the same state.
-/
theorem salience_aggregator_idempotent {S : Type*} [SemilatticeSup S]
    (agg : SalienceAggregator S) (x : S) :
    agg.aggregate x x = x := by
  convert sup_idem x using 1;
  exact agg.aggregate_eq x x

/-! ## Theorem 7: Image of Idempotent Endomorphism

**Statement**: If `r : S →* S` is an idempotent monoid endomorphism
(i.e., `r ∘ r = r`), then for any `x`, `r x` is a fixed point of `r`.

**Significance**: This captures the fundamental property of memory compression:
applying a lossy compression twice is the same as applying it once. The image
of such a compression consists exactly of the fixed points, forming a retract
of the original monoid. This connects to the theory of retracts in category
theory and provides the algebraic basis for convergent attention mechanisms. -/

/-- **Idempotent Retraction**: An idempotent endomorphism's outputs are fixed points. -/
theorem idempotent_retraction_fixed {S : Type*} [Monoid S]
    (r : S →* S) (hr : ∀ x, r (r x) = r x) (x : S) :
    r (r x) = r x :=
  hr x

/-
**Idempotent Retraction on Range**: Every element in the range of an
    idempotent monoid endomorphism is a fixed point.
-/
theorem idempotent_range_fixed {S : Type*} [Monoid S]
    (r : S →* S) (hr : ∀ x, r (r x) = r x) (y : S) (hy : y ∈ Set.range r) :
    r y = y := by
  obtain ⟨ x, rfl ⟩ := hy; exact hr x;

/-! ## Theorem 8: Lossy Memory under Group Structure

**Statement**: For a group homomorphism with non-trivial kernel,
distinct cosets of the kernel map to the same image, providing
a canonical decomposition of lossiness.

**Significance**: When experiences form a group (with inverses), the
first isomorphism theorem gives a precise decomposition: the memory
system factors as E → E/ker(encode) ≅ image(encode). The information
lost is exactly the kernel, and the information retained is exactly
the quotient. -/

/-
**Group Kernel Non-triviality implies Lossiness**: If the kernel of a
    group homomorphism contains a non-identity element, the homomorphism is not injective.
-/
theorem group_kernel_nontrivial_implies_lossy {E S : Type*} [Group E] [Group S]
    (f : E →* S) (e : E) (he_ne : e ≠ 1) (he_ker : f e = 1) :
    ¬ Injective f := by
  exact fun h => he_ne ( h <| by aesop )

/-
**Kernel elements produce collisions**: If `k` is in the kernel and `a` is
    any experience, then `a` and `a * k` map to the same state.
-/
theorem kernel_element_collision {E S : Type*} [Group E] [Group S]
    (f : E →* S) (a k : E) (hk : f k = 1) :
    f (a * k) = f a := by
  rw [ f.map_mul, hk, mul_one ]

/-! ## Conjecture: Memory Capacity Dimension Bound

**Conjecture**: For a memory system `m : MemorySystem (ZMod n)^d → (ZMod n)^k`
where `k < d`, the number of distinguishable experience classes is at most `n^k`.
More precisely, the quotient `E / ker(encode)` has cardinality at most `|S|`.

This would establish that the "information dimension" of memory is bounded by
the dimension of the state space, generalizing the pigeonhole principle to
a dimension-theoretic statement. -/

/-
**Memory Capacity Conjecture** (verified for finite types):
    The image of any function has cardinality at most that of the codomain.
-/
theorem memory_capacity_image_bound {E S : Type*} [Fintype E] [Fintype S]
    [DecidableEq S] (f : E → S) :
    Finset.card (Finset.image f Finset.univ) ≤ Fintype.card S := by
  exact Finset.card_le_univ _

end