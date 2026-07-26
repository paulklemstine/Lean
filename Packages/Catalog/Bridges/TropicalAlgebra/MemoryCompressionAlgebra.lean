/-
# Memory Compression Algebra

A rigorous algebraic framework for memory-as-compression, connecting:
- Finite semigroup theory (idempotent stabilization)
- Tropical valuations (compression rank as tropical capacity)
- Information-theoretic bounds on composition

The central insight: information loss through memory has precise algebraic structure.
Every finite memory system eventually reaches an idempotent "steady state," and the
amount of information retained is governed by submultiplicative tropical inequalities.
-/

import Mathlib

open Finset Function

/-! ## Part 1: Compression Rank and Submultiplicativity

The compression rank of a function f : α → β is |image(f)|.
For composed functions g ∘ f, we have |image(g ∘ f)| ≤ |image(f)|,
which captures that composition cannot increase information beyond
what the first stage passes through.
-/

noncomputable section

/-- The compression rank of a function on a finite type is the cardinality of its range. -/
def compressionRank (f : α → β) [Fintype α] [DecidableEq β] : ℕ :=
  (Finset.univ.image f).card

/-
**Image Monotonicity Under Composition**: composing with any function
cannot increase the compression rank beyond the inner function's rank.
This is the fundamental "information bottleneck" inequality.
-/
theorem compressionRank_comp_le_left
    [Fintype α] [DecidableEq β] [DecidableEq γ] [Fintype β]
    (f : α → β) (g : β → γ) :
    compressionRank (g ∘ f) ≤ compressionRank f := by
  exact Finset.card_le_card ( show Finset.image ( g ∘ f ) Finset.univ ⊆ Finset.image g ( Finset.image f Finset.univ ) from Finset.image_subset_iff.2 fun x _ => Finset.mem_image.2 ⟨ f x, Finset.mem_image_of_mem f ( Finset.mem_univ _ ), rfl ⟩ ) |> le_trans <| Finset.card_image_le

/-
Composition also cannot exceed the outer function's rank restricted to the image.
-/
theorem compressionRank_comp_le_right
    [Fintype α] [DecidableEq β] [DecidableEq γ] [Fintype β]
    (f : α → β) (g : β → γ) :
    compressionRank (g ∘ f) ≤ compressionRank g := by
  exact Finset.card_le_card ( Finset.image_subset_iff.2 fun x _ => Finset.mem_image.2 ⟨ _, Finset.mem_univ _, rfl ⟩ )

/-
The compression rank of the identity function equals the cardinality of the type.
-/
theorem compressionRank_id [Fintype α] [DecidableEq α] :
    compressionRank (id : α → α) = Fintype.card α := by
  unfold compressionRank; aesop;

/-! ## Part 2: Idempotent Stabilization in Finite Semigroups

Every element of a finite semigroup has an idempotent power: there exists n > 0
such that a^(2n) = a^n. This is the algebraic foundation of the "memory reaches
steady state" phenomenon.
-/

/-
In a finite monoid, every element has a power that is idempotent:
∃ n > 0, a^(2*n) = a^n. This captures that repeated application of any
memory transition eventually reaches a fixed point of the transition's effect.
-/
theorem finite_monoid_idempotent_power [Monoid M] [Finite M]
    (a : M) : ∃ n : ℕ, 0 < n ∧ a ^ (2 * n) = a ^ n := by
  -- By the pigeonhole principle, since $M$ is finite, there exist $m$ and $k$ such that $a^{m+k} = a^m$ for $m \geq 0$ and $k \geq 1$.
  obtain ⟨m, k, hm, hk⟩ : ∃ m k : ℕ, 1 ≤ k ∧ a ^ m = a ^ (m + k) := by
    -- By the pigeonhole principle, since $M$ is finite, there exist $m$ and $k$ such that $a^{m+k} = a^m$ for $m \geq 0$ and $k \geq 1$. This follows from the fact that the sequence $a^0, a^1, a^2, \ldots$ must eventually repeat.
    have h_pigeonhole : ∃ m n : ℕ, m < n ∧ a^m = a^n := by
      by_contra! h' ; exact absurd ( Set.infinite_range_of_injective ( fun m n hmn => le_antisymm ( not_lt.mp fun contra => h' _ _ contra hmn.symm ) ( not_lt.mp fun contra => h' _ _ contra hmn ) ) ) ( Set.not_infinite.mpr ( Set.toFinite _ ) ) ;
    obtain ⟨ m, n, hmn, h ⟩ := h_pigeonhole; exact ⟨ m, n - m, Nat.sub_pos_of_lt hmn, by rwa [ add_tsub_cancel_of_le hmn.le ] ⟩ ;
  -- From this point onwards, the sequence $a^m, a^{m+1}, a^{m+2}, ...$ is periodic with period $k$.
  have h_periodic : ∀ n ≥ m, a ^ n = a ^ (n + k) := by
    intro n hn; induction hn <;> simp_all +decide [ Nat.succ_add, pow_succ' ] ;
  -- Let $n = mk$. Then $a^n = a^{mk}$ and $a^{2n} = a^{2mk}$.
  use m * k + k^2;
  -- By the periodicity, we have $a^{m*k + k^2} = a^{m*k + k^2 + k} = a^{m*k + k^2 + 2k} = \cdots = a^{2*(m*k + k^2)}$.
  have h_eq : ∀ t : ℕ, a ^ (m * k + k ^ 2 + t * k) = a ^ (m * k + k ^ 2) := by
    intro t; induction' t with t ih <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ] ;
    rw [ ← h_periodic _ ( by nlinarith ), ih ];
  exact ⟨ by positivity, by convert h_eq ( m + k ) using 1 ; ring ⟩

/-! ## Part 3: Tropical Capacity Valuation

The tropical capacity of a function is log(compressionRank(f)).
This valuation satisfies a tropical subadditivity law under composition:
  v(g ∘ f) ≤ min(v(f), v(g))
which is the max-plus dual of the bottleneck inequality.
-/

/-- Tropical capacity: the log of the compression rank.
Measures information capacity in nats. -/
def tropicalCapacity (f : α → β) [Fintype α] [DecidableEq β] : ℝ :=
  Real.log (compressionRank f : ℝ)

/-
**Tropical Bottleneck Inequality**: the tropical capacity of a composition
is at most the tropical capacity of the inner function.
In tropical terms: v(g ∘ f) ≤ v(f).
-/
theorem tropicalCapacity_comp_le
    [Fintype α] [DecidableEq β] [DecidableEq γ] [Fintype β]
    (f : α → β) (g : β → γ) :
    tropicalCapacity (g ∘ f) ≤ tropicalCapacity f := by
  by_cases h : Finset.card ( Finset.image ( g ∘ f ) Finset.univ ) = 0;
  · unfold tropicalCapacity;
    unfold compressionRank; aesop;
  · exact Real.log_le_log ( mod_cast Nat.pos_of_ne_zero h ) ( mod_cast compressionRank_comp_le_left f g )

/-! ## Part 4: Kernel Congruence and Information Ordering

The kernel of a function f : α → β defines an equivalence relation on α.
Coarser kernels mean more information loss.
We prove that if ker(f) refines ker(g), then the compression rank of g
is at most that of f — finer distinctions mean more information retained.
-/

/-- The kernel relation of a function: x ~ y iff f(x) = f(y). -/
def kernelSetoid (f : α → β) : Setoid α where
  r x y := f x = f y
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- A function g factors through f if ker(f) refines ker(g):
whenever f(x) = f(y), also g(x) = g(y). -/
def KernelRefines (f : α → β) (g : α → γ) : Prop :=
  ∀ x y : α, f x = f y → g x = g y

/-
**Information Ordering Theorem**: If the kernel of f refines the kernel of g
(f makes finer distinctions), then g's compression rank is at most f's.
This formalizes "more information retained ⟹ at least as many distinct outputs."
-/
theorem compressionRank_le_of_kernel_refines
    [Fintype α] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : α → γ) (h : KernelRefines f g) :
    compressionRank g ≤ compressionRank f := by
  -- For each element y in image(g,univ), pick a ∈ univ with g(a) = y, and send y to f(a).
  have h_map : ∃ map : Finset.image g Finset.univ → Finset.image f Finset.univ, Function.Injective map := by
    have h_map : ∀ y ∈ Finset.image g Finset.univ, ∃ x ∈ Finset.univ, g x = y := by
      grind;
    choose! x hx₁ hx₂ using h_map;
    refine' ⟨ fun y => ⟨ f ( x y y.2 ), Finset.mem_image_of_mem f ( hx₁ _ _ ) ⟩, _ ⟩;
    intro y₁ y₂ h_eq;
    grind +locals;
  obtain ⟨ map, hmap ⟩ := h_map;
  simpa using Fintype.card_le_of_injective map hmap

/-! ## Part 5: Memory System Structure -/

/-- A memory system consists of a finite state space with a
monoid action by an input alphabet via a monoid homomorphism. -/
structure MemorySystem (α : Type*) (S : Type*) [Monoid S] where
  /-- The transition function mapping input sequences to state transformations -/
  transition : FreeMonoid α →* S

/-- The reachable set of a memory system is the image of its transition map. -/
def MemorySystem.reachableSet [Monoid S] (M : MemorySystem α S) : Set S :=
  Set.range M.transition

/-- The cascade product of two memory systems creates a joint system
whose state space is the product S × T. -/
def cascadeProduct [Monoid S] [Monoid T]
    (M₁ : MemorySystem α S) (M₂ : MemorySystem α T) :
    MemorySystem α (S × T) where
  transition := MonoidHom.prod M₁.transition M₂.transition

/-
**Cascade Product Rank Bound**: The compression rank of a cascade product
is at most the product of the individual compression ranks.
-/
theorem cascadeProduct_rank_le_mul
    [Monoid S] [Monoid T] [Fintype (FreeMonoid α)] [DecidableEq S] [DecidableEq T]
    [DecidableEq (S × T)] [Fintype S] [Fintype T]
    (M₁ : MemorySystem α S) (M₂ : MemorySystem α T) :
    (Finset.univ.image (cascadeProduct M₁ M₂).transition).card ≤
    (Finset.univ.image M₁.transition).card * (Finset.univ.image M₂.transition).card := by
  rw [ ← Finset.card_product ] ; exact Finset.card_le_card ( Finset.image_subset_iff.mpr fun x _ => by aesop ) ;

/-! ## Part 6: Fixed Point Theorem for Memory Compression

The composition of compressionRank with iteration satisfies a monotone
convergence property: for any endofunction f on a finite type,
the sequence compressionRank(f^n) is non-increasing and eventually constant.
-/

/-
The compression rank sequence of iterates is non-increasing.
-/
theorem compressionRank_iterate_nonincreasing
    [Fintype α] [DecidableEq α] (f : α → α) (n : ℕ) :
    compressionRank (f^[n + 1]) ≤ compressionRank (f^[n]) := by
  convert compressionRank_comp_le_left ( f^[n] ) f using 1;
  rw [ Function.iterate_succ' ]

/-
**Stabilization Theorem**: For any endofunction on a finite type,
the compression rank sequence eventually stabilizes.
-/
theorem compressionRank_eventually_stabilizes
    [Fintype α] [DecidableEq α] (f : α → α) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      compressionRank (f^[n]) = compressionRank (f^[N]) := by
  -- Apply the well-ordering principle to the range of the sequence.
  obtain ⟨k, hk_mem⟩ : ∃ k ∈ Set.range (fun n => compressionRank (f^[n])), ∀ m ∈ Set.range (fun n => compressionRank (f^[n])), k ≤ m := by
    apply Set.exists_min_image;
    · exact Set.finite_iff_bddAbove.mpr ⟨ Fintype.card α, Set.forall_mem_range.mpr fun n => Finset.card_le_univ _ ⟩;
    · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
  obtain ⟨ ⟨ N, rfl ⟩, hk ⟩ := hk_mem;
  exact ⟨ N, fun n hn => le_antisymm ( by induction hn <;> [ tauto; linarith! [ compressionRank_iterate_nonincreasing f ‹_› ] ] ) ( hk _ ⟨ n, rfl ⟩ ) ⟩

/-! ## Part 7: Surjection-Injection Factorization and Rank -/

/-
The compression rank of a surjective function equals the cardinality of the codomain.
-/
theorem compressionRank_of_surjective [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (hf : Surjective f) :
    compressionRank f = Fintype.card β := by
  convert Finset.card_image_of_injective _ ( show Function.Injective ( fun x : Fin ( Fintype.card β ) ↦ f ( hf ( Fintype.equivFin β |>.symm x ) |> Classical.choose ) ) from ?_ ) using 2;
  any_goals exact Finset.univ;
  · refine' congr_arg Finset.card ( Finset.ext fun x => _ );
    simp +decide;
    exact ⟨ fun ⟨ a, ha ⟩ => ⟨ Fintype.equivFin β x, by simpa [ ha ] using Classical.choose_spec ( hf x ) ⟩, fun ⟨ a, ha ⟩ => ⟨ _, ha ⟩ ⟩;
  · simp +decide;
  · intro x y hxy; have := Classical.choose_spec ( hf ( Fintype.equivFin β |>.symm x ) ) ; have := Classical.choose_spec ( hf ( Fintype.equivFin β |>.symm y ) ) ; aesop;

/-
The compression rank of an injective function equals the cardinality of the domain.
-/
theorem compressionRank_of_injective [Fintype α] [DecidableEq β]
    (f : α → β) (hf : Injective f) :
    compressionRank f = Fintype.card α := by
  convert Finset.card_image_of_injective Finset.univ hf

end