import Mathlib

/-!
# Closure-Compression Duality

This file formalizes the mathematical theory of **idempotent closure operators as
canonical compression schemes**. The central insight is that an idempotent,
length-nonincreasing map on a finite type acts as a lossless compressor whose fixed
points are exactly the irreducible (incompressible) elements.

## Main results

### Fiber and fixed-point structure
- `fiber_nonempty_iff_fixedPoint`: The preimage fiber `{y | c y = x}` is nonempty
  iff `x` is a fixed point of `c`.
- `fixedPoints_eq_range`: Fixed points of an idempotent map = its range.

### Optimality theorems
- `fixedPoints_optimal_in_fiber`: Fixed points are length-minimal in their fiber.
- `fixedPoints_iff_optimal_in_nonempty_fiber`: Fixed points are characterized as the
  length-optimal elements with nonempty fiber.
- `compression_ratio_optimal_on_fibers`: `ℓ(c x)` achieves the minimum description
  length in the fiber class of `x`.

### Tropical closure cost
- `closureCost`: The infimum description length over an equivalence class.
- `closureCost_idempotent`: Closure cost is invariant under recompression.
- `closureCost_realized_by_fixed_point`: Under optimality, closure cost = `ℓ(c x)`.

### Incompressibility
- `StrictAdmissibleCompressor`: A compressor that strictly reduces length on non-fixed
  points.
- `incompressible_iff_fixed_by_all_strict_admissible`: Elements are incompressible
  (length-preserved by all strict compressors) iff they are fixed by all strict
  compressors.

### MDL bridge
- `closure_operator_gives_mdl_upper_bound`: Length-nonincreasing maps preserving semantic
  invariants give computable MDL upper bounds.

## Mathematical significance

This formalization provides a rigorous surrogate for Kolmogorov complexity theory
that avoids uncomputability barriers. Instead of universal machines, we work with
concrete idempotent operators on finite types, proving that:

1. **Idempotent closure = canonical compression**: The fixed points of an idempotent
   map are the unique canonical representatives of each equivalence class, and they
   achieve minimum description length.

2. **Tropical interpretation**: The closure cost function satisfies idempotent
   (tropical) aggregation laws, connecting compression to min-plus algebra.

3. **Incompressibility as rigidity**: Elements that resist all strict admissible
   compressors are exactly the fixed points — the "Kolmogorov-random" strings
   in this closure-theoretic framework.
-/

open Set Function Finset

noncomputable section

namespace ClosureCompression

variable {α : Type*}

/-- A function is **idempotent** if applying it twice equals applying it once. -/
def IsIdempotent (c : α → α) : Prop := ∀ x, c (c x) = c x

/-- An **admissible compressor** is an idempotent, length-nonincreasing map. -/
def AdmissibleCompressor (ℓ : α → ℕ) (c : α → α) : Prop :=
  IsIdempotent c ∧ ∀ x, ℓ (c x) ≤ ℓ x

/-- A **strict admissible compressor** is idempotent and strictly reduces length
    on every non-fixed-point. This models compressors that always make progress
    when they compress at all. -/
def StrictAdmissibleCompressor (ℓ : α → ℕ) (c : α → α) : Prop :=
  IsIdempotent c ∧ ∀ x, c x ≠ x → ℓ (c x) < ℓ x

/-- Closure cost: the infimum description length over the equivalence class of `x`
    under the partition induced by `c`. This is the tropical/min-plus aggregation
    of description lengths. -/
def closureCost (c : α → α) (ℓ : α → ℕ) (x : α) : ℕ :=
  sInf {n | ∃ y, c y = c x ∧ ℓ y = n}

-- ============================================================================
-- Section 2: Fiber and Fixed-Point Structure
-- ============================================================================

/-- For an idempotent function, the preimage fiber over `x` is nonempty
    if and only if `x` is a fixed point.

    **Proof**: If `c y = x` then `c x = c (c y) = c y = x` by idempotence.
    Conversely if `c x = x`, take `y = x`. -/
theorem fiber_nonempty_iff_fixedPoint (c : α → α) (hidem : IsIdempotent c) (x : α) :
    (∃ y, c y = x) ↔ c x = x := by
  constructor
  · rintro ⟨y, rfl⟩; exact hidem y
  · exact fun h => ⟨x, h⟩

/-- Fixed points of an idempotent map are exactly its range.
    This is a fundamental structural fact about idempotent endomorphisms
    (retractions). -/
theorem fixedPoints_eq_range (c : α → α) (hidem : IsIdempotent c) :
    {x | c x = x} = Set.range c := by
  exact Set.ext fun x =>
    ⟨fun hx => ⟨x, hx⟩, fun hx => by cases' hx with y hy; have := hidem y; aesop⟩

/-- Every strict admissible compressor is admissible: strict length reduction
    on non-fixed-points implies length-nonincreasing everywhere. -/
theorem StrictAdmissibleCompressor.toAdmissible {ℓ : α → ℕ} {c : α → α}
    (h : StrictAdmissibleCompressor ℓ c) : AdmissibleCompressor ℓ c := by
  refine ⟨h.1, fun x => ?_⟩
  by_cases hx : c x = x
  · rw [hx]
  · exact (h.2 x hx).le

-- ============================================================================
-- Section 3: Optimality Theorems
-- ============================================================================

/-- The fiber-optimality hypothesis `hopt` implies length-nonincreasing.
    Setting `y = x` in `hopt` gives `ℓ(c x) ≤ ℓ(x)`. -/
theorem hopt_implies_hlen (ℓ : α → ℕ) (c : α → α)
    (hopt : ∀ x y, c y = c x → ℓ (c x) ≤ ℓ y) :
    ∀ x, ℓ (c x) ≤ ℓ x :=
  fun x => hopt x x rfl

/-- Fixed points are length-optimal among all elements in their fiber. -/
theorem fixedPoints_optimal_in_fiber (ℓ : α → ℕ) (c : α → α)
    (hopt : ∀ x y, c y = c x → ℓ (c x) ≤ ℓ y) :
    ∀ x, c x = x → ∀ y, c y = x → ℓ x ≤ ℓ y := by
  intro x hx y hy
  have : c y = c x := by rw [hy, hx]
  have := hopt x y this
  rwa [hx] at this

/-- **Fixed-point characterization**: `x` is a fixed point of `c` if and only if
    `x` is in the range of `c` and is length-optimal in its fiber.

    Note: The condition `∃ y, c y = x` is essential — without it, non-fixed-points
    would vacuously satisfy the optimality condition (having empty fiber). -/
theorem fixedPoints_iff_optimal_in_nonempty_fiber (ℓ : α → ℕ) (c : α → α)
    (hidem : IsIdempotent c)
    (hopt : ∀ x y, c y = c x → ℓ (c x) ≤ ℓ y) :
    ∀ x, c x = x ↔ (∃ y, c y = x) ∧ (∀ y, c y = x → ℓ x ≤ ℓ y) := by
  intro x
  constructor
  · intro hx
    exact ⟨⟨x, hx⟩,
      fun y hy => by simpa [hx] using hopt x y (by simpa [hx] using hy)⟩
  · intro ⟨hy, _⟩
    obtain ⟨y, rfl⟩ := hy
    exact hidem y

/-- **Compression optimality**: `ℓ(c x)` achieves the minimum description length
    in the fiber class `{y | c y = c x}`. This is the precise formal statement
    that "idempotent closure yields optimal lossless compression ratios." -/
theorem compression_ratio_optimal_on_fibers (ℓ : α → ℕ) (c : α → α)
    (hidem : IsIdempotent c)
    (hopt : ∀ x y, c y = c x → ℓ (c x) ≤ ℓ y) :
    ∀ x, IsLeast {n : ℕ | ∃ y, c y = c x ∧ ℓ y = n} (ℓ (c x)) :=
  fun x => ⟨⟨c x, by simp +decide [hidem x], rfl⟩,
    fun n hn => hn.choose_spec.2 ▸ hopt _ _ hn.choose_spec.1⟩

-- ============================================================================
-- Section 4: Tropical Closure Cost
-- ============================================================================

/-- Closure cost is idempotent: recompressing doesn't change the cost.
    This is the tropical/min-plus idempotent property. -/
theorem closureCost_idempotent (c : α → α) (ℓ : α → ℕ)
    (hidem : IsIdempotent c) :
    ∀ x, closureCost c ℓ (c x) = closureCost c ℓ x := by
  grind +locals

/-- Under the optimality hypothesis, closure cost equals the length of the
    compressed representative. This is the **tropical compression theorem**:
    the idempotent projection computes the tropical minimum description
    length on each equivalence class. -/
theorem closureCost_realized_by_fixed_point (c : α → α) (ℓ : α → ℕ)
    (hidem : IsIdempotent c)
    (hopt : ∀ x y, c y = c x → ℓ (c x) ≤ ℓ y) :
    ∀ x, closureCost c ℓ x = ℓ (c x) := by
  intro x
  exact le_antisymm
    (Nat.sInf_le ⟨c x, by simp +decide [hidem x], rfl⟩)
    (le_csInf ⟨_, ⟨c x, by simp +decide [hidem x], rfl⟩⟩ fun n hn => by aesop)

-- ============================================================================
-- Section 5: Incompressibility
-- ============================================================================

/-- **Incompressibility characterization**: An element is length-preserved by all
    strict admissible compressors if and only if it is fixed by all of them.
    This is the closure-theoretic analogue of "Kolmogorov-random strings resist
    all compressors." -/
theorem incompressible_iff_fixed_by_all_strict_admissible
    (ℓ : α → ℕ) (x : α) :
    (∀ c : α → α, StrictAdmissibleCompressor ℓ c → ℓ (c x) = ℓ x) ↔
    (∀ c : α → α, StrictAdmissibleCompressor ℓ c → c x = x) := by
  constructor
  · intro h c hc
    exact Classical.not_not.1 fun hx => ne_of_lt (hc.2 x hx) (h c hc)
  · aesop

/-- If a compressor strictly reduces the length of `x`, then `x` is not
    a fixed point. Contrapositive: fixed points have stable length. -/
theorem length_reduced_implies_not_fixed
    (ℓ : α → ℕ) (c : α → α) (x : α)
    (hlt : ℓ (c x) < ℓ x) :
    c x ≠ x := by
  grind

/-- If `x` is fixed by all admissible compressors, then all admissible
    compressors preserve its length. -/
theorem admissible_fixed_implies_length_preserved
    (ℓ : α → ℕ) (x : α) :
    (∀ c : α → α, AdmissibleCompressor ℓ c → c x = x) →
    (∀ c : α → α, AdmissibleCompressor ℓ c → ℓ (c x) = ℓ x) := by
  aesop

-- ============================================================================
-- Section 6: MDL Bridge
-- ============================================================================

/-- **MDL upper bound bridge**: Any length-nonincreasing map that preserves a semantic
    invariant `U` gives computable description-length upper bounds while maintaining
    semantic equivalence. -/
theorem closure_operator_gives_mdl_upper_bound
    (K U : α → ℕ) (c : α → α)
    (hU : ∀ x, U x = U (c x))
    (hK : ∀ x, K (c x) ≤ K x) :
    ∀ x, K (c x) ≤ K x ∧ U (c x) = U x :=
  fun x => ⟨hK x, hU x ▸ rfl⟩

-- ============================================================================
-- Section 7: Counting / Cardinality
-- ============================================================================

/-- For an idempotent map, the number of fixed points equals the cardinality
    of its range. This quantifies the "compression ratio" of the operator. -/
theorem card_fixedPoints_eq_card_range [Fintype α] [DecidableEq α]
    (c : α → α) (hidem : IsIdempotent c) :
    Fintype.card {x // c x = x} = Fintype.card (Set.range c) := by
  fapply Fintype.card_congr
  refine' Equiv.ofBijective (fun x => ⟨x.val, _⟩) ⟨fun x y h => _, fun x => _⟩
  exact ⟨_, x.2⟩
  · grind
  · obtain ⟨y, hy⟩ := x.2
    exact ⟨⟨c y, by aesop⟩, by aesop⟩

/-- The number of compressed (non-fixed) elements plus the number of fixed
    points equals the total cardinality. -/
theorem card_compressed_add_fixed [Fintype α] [DecidableEq α] (c : α → α) :
    Fintype.card {x : α // c x ≠ x} + Fintype.card {x : α // c x = x} = Fintype.card α := by
  rw [add_comm, Fintype.card_subtype, Fintype.card_subtype]
  rw [Finset.card_filter_add_card_filter_not, Finset.card_univ]

end ClosureCompression

end