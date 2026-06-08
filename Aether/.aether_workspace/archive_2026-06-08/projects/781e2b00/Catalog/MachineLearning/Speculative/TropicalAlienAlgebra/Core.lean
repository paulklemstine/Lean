import Mathlib

/-!
# Tropical Alien Algebra: Non-Archimedean Life Forms in Idempotent Semirings

This file formalizes the core theorems connecting idempotent dynamics, tropical
computation, and artificial chemistry. The key insight is that "self-replication"
in tropical media can be characterized algebraically: fixed points of idempotent
endomorphisms serve as "organisms," monotone inflationary iteration models
"emergence," and Lipschitz bounds control "mutation."

## Main results

- `image_eq_fixedPoints_of_idempotent`: The image of an idempotent function
  equals its set of fixed points.
- `iterate_stabilizes_in_one_step`: Idempotent maps stabilize orbits in one step.
- `exists_iterate_fixedPoint_of_finite_monotone_inflationary`: Monotone
  inflationary maps on finite partial orders reach fixed points uniformly.
- `attractor_mutation_bound`: Lipschitz idempotent maps preserve mutation bounds
  and attract to fixed points.
- `comp_idempotent_of_commuting`: Commuting idempotent maps compose to
  idempotent maps.
- Tropical cellular automata definitions with monotonicity proofs.
-/

open Function Set

/-- A function is idempotent if applying it twice gives the same result as once. -/
def IsIdempotentFn {α : Type*} (F : α → α) : Prop := ∀ x, F (F x) = F x

/-! ## Theorem A: Idempotent dynamics and canonical attractors -/

/-- Every orbit of an idempotent function stabilizes in exactly one step.
This is the algebraic core of "self-replication as attractor formation":
applying the replication law twice is the same as applying it once. -/
theorem iterate_stabilizes_in_one_step
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hidem : IsIdempotentFn F)
    (x : Fin n → ℕ) :
    F (F x) = F x :=
  hidem x

/-- The image of an idempotent function is exactly the set of its fixed points.
This identifies "self-replicating organisms" (fixed points) with "projection
images" (the range of the replication map). -/
theorem image_eq_fixedPoints_of_idempotent
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hidem : IsIdempotentFn F) :
    Set.range F = {x | F x = x} := by
  ext x; simp only [Set.mem_range, Set.mem_setOf_eq]
  exact ⟨by rintro ⟨y, rfl⟩; exact hidem y, by rintro h; exact ⟨x, h⟩⟩

/-- General version: the image of any idempotent function equals its fixed point set. -/
theorem image_eq_fixedPoints_of_idempotent_general
    {α : Type*}
    (F : α → α)
    (hidem : IsIdempotentFn F) :
    Set.range F = {x | F x = x} := by
  ext x; simp only [Set.mem_range, Set.mem_setOf_eq]
  exact ⟨by rintro ⟨y, rfl⟩; exact hidem y, by rintro h; exact ⟨x, h⟩⟩

/-! ## Theorem B: Monotone inflationary dynamics on finite types -/

/-- A monotone inflationary function produces ascending iterates. -/
lemma iterate_monotone_of_inflationary
    {α : Type*} [Preorder α]
    (F : α → α)
    (_hmono : Monotone F)
    (hinfl : ∀ x, x ≤ F x)
    (x : α) :
    ∀ n : ℕ, F^[n] x ≤ F^[n + 1] x := by
  intro n
  induction' n with n _ih
  · simpa using hinfl x
  · simpa only [Function.iterate_succ_apply'] using hinfl _

/-- Once an inflationary monotone iteration stabilizes at step k,
it stays there forever. -/
lemma iterate_stable_after_fixpoint
    {α : Type*} [Preorder α]
    (F : α → α)
    (_hmono : Monotone F)
    (_hinfl : ∀ x, x ≤ F x)
    (x : α) (k : ℕ)
    (hk : F^[k] x = F^[k + 1] x) :
    ∀ m, k ≤ m → F^[m] x = F^[k] x := by
  intro m hm
  induction hm <;> simp_all +singlePass [Function.iterate_succ_apply']

/-- Ascending chains in a finite partial order must stabilize:
there exists k such that f(k) = f(k+1). -/
lemma finite_ascending_chain_stabilizes
    {α : Type*} [Finite α] [PartialOrder α]
    (f : ℕ → α) (hf : ∀ n, f n ≤ f (n + 1)) :
    ∃ k : ℕ, f k = f (k + 1) := by
  by_contra! h
  exact Set.infinite_range_of_injective
    (StrictMono.injective (strictMono_nat_of_lt_succ fun n =>
      lt_of_le_of_ne (hf n) (h n)))
    (Set.toFinite _)

/-- In a finite partial order, a monotone inflationary function has a uniform
stabilization bound: there exists k such that F^[k] x is a fixed point for all x.
This is the "emergence theorem": seeds evolve into stable organisms in finite time.

Note: `PartialOrder` (not just `Preorder`) is needed here, since antisymmetry
is required to deduce that an ascending chain that revisits a value must be constant. -/
theorem exists_iterate_fixedPoint_of_finite_monotone_inflationary
    {α : Type*} [Finite α] [PartialOrder α]
    (F : α → α)
    (hmono : Monotone F)
    (hinfl : ∀ x, x ≤ F x) :
    ∃ k : ℕ, ∀ x, F^[k] x = F^[k + 1] x := by
  have h_each (x : α) : ∃ k, F^[k] x = F^[k + 1] x :=
    finite_ascending_chain_stabilizes (fun n => F^[n] x)
      (iterate_monotone_of_inflationary F hmono hinfl x)
  choose k hk using h_each
  obtain ⟨k_max, hk_max⟩ : ∃ k_max : ℕ, ∀ x : α, k x ≤ k_max :=
    Finite.exists_le k
  use k_max
  intro x
  have h_stabilize : ∀ m, k x ≤ m → F^[m] x = F^[k x] x :=
    iterate_stable_after_fixpoint F hmono hinfl x (k x) (hk x)
  rw [h_stabilize k_max (hk_max x),
      h_stabilize (k_max + 1) (Nat.le_succ_of_le (hk_max x)), hk]

/-! ## Theorem C: Mutation-bounded stability -/

/-- Coordinatewise distance bound between two states. This avoids
importing full metric space machinery while expressing "mutation size." -/
def coordwiseDistLE {n : ℕ} (ε : ℕ) (x y : Fin n → ℕ) : Prop :=
  ∀ i, Nat.dist (x i) (y i) ≤ ε

/-- A function that is Lipschitz-1 in the coordinatewise sup metric
does not amplify mutations. -/
theorem mutation_nonamplification
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hLip : ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y)) :
    ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y) :=
  hLip

/-- Combined attractor-mutation theorem: an idempotent Lipschitz-1 map preserves
mutation bounds AND guarantees both images are fixed points. This is the key
"robust replication" theorem: replication in tropical media is stable without
requiring ring-linear structure, probability, or classical smoothness. -/
theorem attractor_mutation_bound
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hidem : IsIdempotentFn F)
    (hLip : ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y)) :
    ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y) ∧
      F (F x) = F x ∧ F (F y) = F y := by
  intro x y ε h
  exact ⟨hLip x y ε h, hidem x, hidem y⟩

/-! ## Stretch goal: Composition of commuting idempotent replicators -/

/-- Commuting idempotent endomorphisms compose to an idempotent endomorphism.
This means "alien organisms can be modularly assembled from simpler replicators":
the composition of two compatible replication laws is itself a replication law. -/
theorem comp_idempotent_of_commuting
    {α : Type*}
    {F G : α → α}
    (hF : IsIdempotentFn F)
    (hG : IsIdempotentFn G)
    (hcomm : ∀ x, F (G x) = G (F x)) :
    IsIdempotentFn (F ∘ G) := by
  intro x; show F (G (F (G x))) = F (G x)
  rw [hcomm (F (G x)), hF (G x), ← hcomm (G x), hG x]

/-! ## Structure for tropical replicators -/

/-- A tropical replicator is a monotone, idempotent, inflationary endomorphism
on a preordered type. It models "self-replication laws" in tropical media. -/
structure TropicalReplicator (α : Type*) [Preorder α] where
  step : α → α
  mono : Monotone step
  idem : IsIdempotentFn step
  infl : ∀ x, x ≤ step x

/-- The image of a tropical replicator equals its fixed point set. -/
theorem TropicalReplicator.fixed_iff_in_range
    {α : Type*} [Preorder α]
    (R : TropicalReplicator α) :
    Set.range R.step = {x | R.step x = x} :=
  image_eq_fixedPoints_of_idempotent_general R.step R.idem

/-! ## Theorem D: Tropical cellular automata -/

/-- Pointwise minimum over a cell and its neighbors on a 1D torus.
This is the simplest nontrivial tropical local rule. -/
noncomputable def tropCA1D (N : ℕ) [NeZero N] (x : Fin N → ℕ) (i : Fin N) : ℕ :=
  min (x i) (min (x (i + 1)) (x (i - 1)))

/-- The global tropical CA update on a 1D torus. -/
noncomputable def tropCA1DUpdate (N : ℕ) [NeZero N] (x : Fin N → ℕ) : Fin N → ℕ :=
  fun i => tropCA1D N x i

/-- Pointwise max tropical CA rule on a 1D torus. -/
noncomputable def tropMaxCA1D (N : ℕ) [NeZero N] (x : Fin N → ℕ) (i : Fin N) : ℕ :=
  max (x i) (max (x (i + 1)) (x (i - 1)))

/-- The global max tropical CA update. -/
noncomputable def tropMaxCA1DUpdate (N : ℕ) [NeZero N] (x : Fin N → ℕ) : Fin N → ℕ :=
  fun i => tropMaxCA1D N x i

/-- The min-based tropical CA is monotone: if x ≤ y pointwise, then
the CA update of x is ≤ the CA update of y. -/
theorem tropCA1DUpdate_monotone (N : ℕ) [NeZero N] :
    Monotone (tropCA1DUpdate N) :=
  fun _x _y hxy _i => min_le_min (hxy _) (min_le_min (hxy _) (hxy _))

/-- The max-based tropical CA is monotone. -/
theorem tropMaxCA1DUpdate_monotone (N : ℕ) [NeZero N] :
    Monotone (tropMaxCA1DUpdate N) :=
  fun _x _y hxy _i => max_le_max (hxy _) (max_le_max (hxy _) (hxy _))

/-- The max-based tropical CA is inflationary: x ≤ tropMaxCA1DUpdate x
because max includes the cell's own value. -/
theorem tropMaxCA1DUpdate_inflationary (N : ℕ) [NeZero N] :
    ∀ x : Fin N → ℕ, x ≤ tropMaxCA1DUpdate N x :=
  fun _x _i => le_max_left _ _