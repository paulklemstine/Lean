/-
# Memory Algebra: When Forgetting Is a Mathematical Operation

This module formalizes memory as a monoid homomorphism from experience streams
to compressed state representations, and proves fundamental theorems about
the inevitability of information loss under finite memory constraints.

## Main Results

* `lossy_memory_theorem` - Any monoid homomorphism from an infinite monoid to a
  finite monoid must be non-injective (lossy).
* `memory_kernel_is_submonoid` - The kernel of a memory homomorphism forms a submonoid.
* `forget_refines_to_quotient` - Targeted forgetting corresponds to refinement of
  congruences, i.e., a quotient construction.
* `composed_forgetting_coarsens` - Composing two forgetting operations yields a
  coarser congruence.
* `fiber_partition_card_bound` - The number of distinguishable memory classes is
  bounded by the state space cardinality.
-/
import Mathlib

open Function Set

/-! ## Memory System Definitions -/

/-- A `MemorySystem` packages a monoid homomorphism from experiences to states,
    where the state monoid is finite. This models a system that compresses
    an arbitrarily long stream of experiences into a bounded representation. -/
structure MemorySystem (E S : Type*) [Monoid E] [Monoid S] [Fintype S] where
  /-- The encoding homomorphism from experiences to states -/
  encode : E →* S

/-- The memory kernel: experiences that map to the identity state.
    These are experiences that leave no trace in memory. -/
def MemorySystem.kernel {E S : Type*} [Monoid E] [Monoid S] [Fintype S]
    (mem : MemorySystem E S) : Set E :=
  { e : E | mem.encode e = 1 }

/-- The memory congruence: two experience streams are indistinguishable
    if they produce the same memory state. -/
def MemorySystem.congruence {E S : Type*} [Monoid E] [Monoid S] [Fintype S]
    (mem : MemorySystem E S) : Setoid E where
  r a b := mem.encode a = mem.encode b
  iseqv := {
    refl := fun _ => rfl
    symm := fun h => h.symm
    trans := fun h1 h2 => h1.trans h2
  }

/-- A `ForgettingMap` is a surjective monoid homomorphism between state spaces
    that models targeted forgetting: we deliberately discard some distinctions. -/
structure ForgettingMap (S T : Type*) [Monoid S] [Monoid T] where
  /-- The forgetting homomorphism -/
  forget : S →* T
  /-- Forgetting is surjective: every coarse state is reachable -/
  surj : Surjective forget

/-- The information loss set: elements mapped to identity by a composed
    forgetting operation. -/
def informationLoss {E S : Type*} [Monoid E] [Monoid S] [Fintype S]
    (mem : MemorySystem E S) : Set E :=
  mem.kernel

/-- Two memory systems where one is a coarsening of the other -/
structure MemoryRefinement (E S T : Type*) [Monoid E] [Monoid S] [Monoid T]
    [Fintype S] [Fintype T] where
  fine : MemorySystem E S
  coarse : MemorySystem E T
  /-- The coarse system factors through the fine one -/
  bridge : S →* T
  /-- The factorization commutes -/
  commutes : ∀ e : E, bridge (fine.encode e) = coarse.encode e

/-! ## Core Theorems -/

section LossyMemory

/-
**Lossy Memory Theorem**: Any monoid homomorphism from an infinite type to a
    finite type must be non-injective. This is the fundamental impossibility result
    for lossless finite memory: if experiences are unbounded but memory states are
    bounded, some distinct experiences must be conflated.

    This is a nontrivial application of the pigeonhole principle to algebraic
    memory systems.
-/
theorem lossy_memory_theorem (E S : Type*) [Monoid E] [Monoid S] [Fintype S]
    [Infinite E] (mem : MemorySystem E S) :
    ¬ Injective mem.encode := by
  exact fun h => not_injective_infinite_finite _ h

end LossyMemory

section KernelSubmonoid

/-
**Memory Kernel Submonoid**: The kernel of a memory homomorphism is closed under
    the monoid operation and contains the identity. This means the set of "invisible"
    experiences—those that leave no trace—forms a submonoid.

    The mathematical content: if φ(a) = 1 and φ(b) = 1, then φ(a·b) = φ(a)·φ(b) = 1·1 = 1.
    This seemingly simple fact has a deep implication: forgettable experiences compose to
    form forgettable experiences. Forgetting is closed under composition.
-/
theorem memory_kernel_one_mem {E S : Type*} [Monoid E] [Monoid S] [Fintype S]
    (mem : MemorySystem E S) : (1 : E) ∈ mem.kernel := by
  exact mem.encode.map_one

theorem memory_kernel_mul_mem {E S : Type*} [Monoid E] [Monoid S] [Fintype S]
    (mem : MemorySystem E S) {a b : E} (ha : a ∈ mem.kernel) (hb : b ∈ mem.kernel) :
    a * b ∈ mem.kernel := by
  unfold MemorySystem.kernel at * ; aesop

/-- The kernel is a submonoid: wrapping the above into Mathlib's `Submonoid` structure. -/
noncomputable def memory_kernel_submonoid {E S : Type*} [Monoid E] [Monoid S] [Fintype S]
    (mem : MemorySystem E S) : Submonoid E where
  carrier := mem.kernel
  mul_mem' := memory_kernel_mul_mem mem
  one_mem' := memory_kernel_one_mem mem

end KernelSubmonoid

section ForgettingQuotient

/-
**Forgetting as Quotient**: When one memory system is a coarsening of another
    (i.e., there exists a bridge homomorphism making the diagram commute), the
    coarse congruence refines the fine congruence. Elements identified by the
    fine system are also identified by the coarse system.

    This formalizes the intuition that "targeted forgetting = taking a quotient":
    forgetting more detail corresponds to identifying more experiences.
-/
theorem forget_refines_congruence {E S T : Type*} [Monoid E] [Monoid S] [Monoid T]
    [Fintype S] [Fintype T] (ref : MemoryRefinement E S T)
    {a b : E} (h : ref.fine.congruence.r a b) :
    ref.coarse.congruence.r a b := by
  convert congr_arg ref.bridge h;
  simp +decide [ ref.commutes, MemorySystem.congruence ]

/-
**Kernel Monotonicity under Forgetting**: If the coarse system factors through
    the fine system, then the fine kernel is contained in the coarse kernel.
    More forgetting means more invisible experiences.
-/
theorem kernel_monotone_under_forgetting {E S T : Type*} [Monoid E] [Monoid S] [Monoid T]
    [Fintype S] [Fintype T] (ref : MemoryRefinement E S T)
    (_hbridge : ref.bridge 1 = 1) :
    ref.fine.kernel ⊆ ref.coarse.kernel := by
  intro e he; have := ref.commutes e; simp_all +decide [ MemorySystem.kernel ] ;

end ForgettingQuotient

section FiberBound

/-
**Fiber Cardinality Bound**: The number of distinguishable experience classes
    under a memory system is at most the cardinality of the state space.
    This quantifies the maximum "resolution" of any finite memory.
-/
theorem fiber_partition_card_bound {E S : Type*} [Monoid E] [Monoid S]
    [Fintype S] [DecidableEq S] (mem : MemorySystem E S)
    (exps : Finset E) (h_inj_on : Set.InjOn mem.encode (↑exps)) :
    exps.card ≤ Fintype.card S := by
  exact le_trans ( by rw [ ← Finset.card_image_of_injOn h_inj_on ] ) ( Finset.card_le_univ _ )

end FiberBound

section ComposedForgetting

/-
**Composed Forgetting**: Given two successive forgetting maps S → T → U,
    their composition is also a forgetting map. This shows that the collection
    of all possible "levels of forgetting" is closed under composition,
    forming a category of memory algebras.
-/
def composed_forgetting {S T U : Type*} [Monoid S] [Monoid T] [Monoid U]
    (f : ForgettingMap S T) (g : ForgettingMap T U) : ForgettingMap S U where
  forget := g.forget.comp f.forget
  surj := by
    exact g.surj.comp f.surj

/-
**Memory Refinement Transitivity**: If system A refines system B, and B refines C,
    then A refines C. This gives us a preorder on memory systems ordered by
    information content.
-/
def memory_refinement_trans {E S T U : Type*}
    [Monoid E] [Monoid S] [Monoid T] [Monoid U]
    [Fintype S] [Fintype T] [Fintype U]
    (r1 : MemoryRefinement E S T) (r2 : MemoryRefinement E T U)
    (h : r1.coarse = r2.fine) : MemoryRefinement E S U where
  fine := r1.fine
  coarse := r2.coarse
  bridge := r2.bridge.comp r1.bridge
  commutes := by
    simp_all +decide [ MemoryRefinement.commutes ]

end ComposedForgetting

section CongruenceLattice

/-
The congruence induced by a memory system is a `Con` (Mathlib's monoid congruence).
-/
def MemorySystem.toCon {E S : Type*} [Monoid E] [Monoid S] [Fintype S]
    (mem : MemorySystem E S) : Con E where
  r a b := mem.encode a = mem.encode b
  iseqv := {
    refl := fun _ => rfl
    symm := fun h => h.symm
    trans := fun h1 h2 => h1.trans h2
  }
  mul' := by
    simp +contextual [ mem.encode.map_mul ]

/-
**Congruence Lattice Theorem**: The set of all memory congruences on a monoid
    forms a lattice under refinement. Coarser congruences correspond to more
    forgetting. The lattice join of two congruences gives the "minimal common
    forgetting" — the coarsest system that remembers everything both systems remember.

    Here we prove a key property: the congruence from a composed system (via bridge)
    is coarser than the original.
-/
theorem con_coarser_through_bridge {E S T : Type*} [Monoid E] [Monoid S] [Monoid T]
    [Fintype S] [Fintype T] (ref : MemoryRefinement E S T) :
    ref.fine.toCon ≤ ref.coarse.toCon := by
  intro a b hab;
  -- By definition of `toCon`, we have `ref.fine.toCon a b ↔ ref.fine.encode a = ref.fine.encode b`.
  simp [MemorySystem.toCon] at hab;
  simp_all +decide [ MemorySystem.toCon ];
  rw [ ← ref.commutes a, ← ref.commutes b, hab ]

end CongruenceLattice

section Conjecture

/-
**Conjecture (Optimal Forgetting Rate)**: For any memory system with state space
    of size n processing a stream from a free monoid on k generators, the minimum
    information loss rate (measured as the logarithm of the average fiber size)
    is at least log(k) - log(n) / stream_length.

    This is stated as a concrete testable bound. A counterexample would be a
    memory system achieving lossless compression beyond this rate.

    We state a weaker, provable version as a theorem:
-/
theorem min_loss_pigeonhole {k n : ℕ} (hk : 1 < k) (hn : 0 < n)
    (f : Fin (k ^ n) → Fin n)  :
    ∃ y : Fin n, n ≤ (Finset.univ.filter (fun x => f x = y)).card := by
  by_contra! h_contra';
  -- By counting the total number of elements in the domain, we can derive a contradiction.
  have h_total : ∑ y : Fin n, (Finset.univ.filter (fun x => f x = y)).card = k ^ n := by
    simp +decide only [Finset.card_filter];
    rw [ Finset.sum_comm ] ; aesop;
  contrapose! h_total;
  refine' ne_of_lt ( lt_of_le_of_lt ( Finset.sum_le_sum fun _ _ => Nat.le_sub_one_of_lt ( h_contra' _ ) ) _ );
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  · grind;
  · refine' Nat.recOn n _ _ <;> norm_num [ pow_succ' ] at *;
    · nlinarith;
    · intro n hn; nlinarith [ Nat.mul_le_mul_left k hk, Nat.mul_le_mul_left k ( Nat.one_le_pow n k hk.le ) ] ;

end Conjecture