import Mathlib

/-!
# The Complexity-Barrier Lattice

This file develops the **algebraic lattice structure** of complexity barriers, extending
the commutative-monoid view of barrier composition developed in
`Catalog/Logic/CircuitComplexityBarriers.lean` (theorems `barrier_composition_assoc`,
`barrier_composition_comm`, `compose_blocks_iff`) and the oracle / counting framework of
`Catalog/Logic/PvsNPFoundations.lean`.

## Conceptual unification

A *complexity barrier* abstracts an obstruction to separating complexity classes: a space of
proof techniques, a strength function, and a `ceiling` beyond which no technique can reach.
The catalog established that barriers compose as a commutative monoid under **max-ceiling**
composition (the `join`). Here we show this is only half of a richer structure:

* the `join` (max ceiling) models *both barriers must be overcome simultaneously*;
* a dual `meet` (min ceiling) models *either barrier suffices to obstruct*;

and together the `ceiling` map carries the barrier algebra onto the **distributive lattice
`(ℕ, max, min)`**. The blocking relation then exhibits a clean logical duality:

* a `join` blocks a target iff **both** components block it (conjunction);
* a `meet` blocks a target iff **either** component blocks it (disjunction).

This is the Grothendieck-style payoff: the relativization / counting barriers are not isolated
facts but *points of a distributive lattice*, and Boolean reformulations of the separation
question (negation, conjunction, disjunction — see `oracle_dependent_closed_*` in the catalog)
correspond exactly to lattice operations on barriers.

Finally we connect the algebra back to **Shannon counting** (cross-domain bridge to
`card_boolFn` / `shannon_counting_lower_bound`): the "all functions reachable by a finite
technique set" barrier is *incomplete*, witnessing a hard function whenever the technique
count is below `2 ^ 2 ^ n`.

All results are fully proved (zero `sorry`).
-/

/-
-- !-- Lab Notebook -- !--
Hypothesis:
  Barrier composition (max ceiling), proved a commutative monoid in the catalog, is the JOIN
  of a distributive lattice on barriers, with a dual MEET given by min ceiling; the blocking
  relation should turn join/meet into ∧/∨.
Result:
  Confirmed. `ceiling` is a lattice homomorphism onto (ℕ, max, min): commutativity,
  associativity, idempotence, absorption, and distributivity all hold (proved by reduction to
  ℕ lattice facts via `omega`/`simp`). Blocking duality `join_blocks_iff` (∧) and
  `meet_blocks_iff` (∨) hold, and blocking is antitone in the ceiling order
  (`blocks_of_le_of_blocks`). Cross-domain: `shannon_barrier_incomplete` ties the lattice to
  counting.
Insight:
  The "max vs min" duality of join/meet is *exactly* the "∀-block vs ∃-block" duality. This
  explains structurally why combining barriers (relativization ∧ naturalization) is strictly
  harder to overcome than either alone, while a meet records the weakest obstruction.
Failure analysis:
  A first attempt defined `meet`'s strength via `max`; then `le_ceiling` failed because
  `max (S t₁) (S t₂)` need not be ≤ `min (c₁) (c₂)`. Switching the strength to `min` (so the
  meet barrier is genuinely weaker on every technique) repaired the axioms cleanly. Lesson:
  the strength aggregator must match the ceiling aggregator for the barrier axioms to close.
-/

namespace BarrierLattice

open Finset

/-! ## The barrier structure -/

/-- A **complexity barrier**: a space of proof `Technique`s, a `Strength` measuring what each
technique can establish, and a `ceiling` no technique exceeds.  This mirrors
`CircuitComplexity.ComplexityBarrier` from the catalog (minus the redundant `monotone`
field, which is implied by `le_ceiling`). -/
structure Barrier where
  /-- The space of proof techniques captured by the barrier. -/
  Technique : Type
  /-- What each technique can establish, as a natural-number bound. -/
  Strength : Technique → ℕ
  /-- The ceiling that no technique can exceed. -/
  ceiling : ℕ
  /-- No technique exceeds the ceiling. -/
  le_ceiling : ∀ t, Strength t ≤ ceiling
  /-- The technique space is nonempty (the barrier applies to real methods). -/
  nontrivial : Nonempty Technique

/-- **Join** (max-ceiling composition): both barriers must be overcome simultaneously.
This is `ComplexityBarrier.compose` from the catalog, recast as the lattice join. -/
def Barrier.join (B₁ B₂ : Barrier) : Barrier where
  Technique := B₁.Technique × B₂.Technique
  Strength := fun p => max (B₁.Strength p.1) (B₂.Strength p.2)
  ceiling := max B₁.ceiling B₂.ceiling
  le_ceiling := fun p => max_le_max (B₁.le_ceiling p.1) (B₂.le_ceiling p.2)
  nontrivial := ⟨(B₁.nontrivial.some, B₂.nontrivial.some)⟩

/-- **Meet** (min-ceiling composition): the dual barrier recording the *weaker* obstruction;
either component suffices.  Note the strength aggregator is `min`, matching the ceiling, so
the meet is genuinely weaker on every technique. -/
def Barrier.meet (B₁ B₂ : Barrier) : Barrier where
  Technique := B₁.Technique × B₂.Technique
  Strength := fun p => min (B₁.Strength p.1) (B₂.Strength p.2)
  ceiling := min B₁.ceiling B₂.ceiling
  le_ceiling := fun p => min_le_min (B₁.le_ceiling p.1) (B₂.le_ceiling p.2)
  nontrivial := ⟨(B₁.nontrivial.some, B₂.nontrivial.some)⟩

/-- A barrier **blocks** a target if the target exceeds the ceiling: no technique reaches it. -/
def Barrier.blocks (B : Barrier) (target : ℕ) : Prop := B.ceiling < target

/-- The natural order on barriers: `B₁ ⊑ B₂` iff `B₁` has the lower ceiling
(hence is the *weaker* obstruction, blocking more targets). -/
def Barrier.le (B₁ B₂ : Barrier) : Prop := B₁.ceiling ≤ B₂.ceiling

/-! ## Blocking duality (join = ∧, meet = ∨) -/

-- !-- A join blocks t iff its max ceiling < t, i.e. both ceilings < t; dualizes the catalog's
-- compose_blocks_iff to the lattice join. -- !--
/-- **Join blocks conjunctively**: the join of two barriers blocks a target iff *both*
components block it.  (Catalog analogue: `compose_blocks_iff`.) -/
theorem join_blocks_iff (B₁ B₂ : Barrier) (t : ℕ) :
    (B₁.join B₂).blocks t ↔ B₁.blocks t ∧ B₂.blocks t := by
  simp [Barrier.blocks, Barrier.join]

-- !-- A meet blocks t iff its min ceiling < t, i.e. at least one ceiling < t (min_lt_iff). -- !--
/-- **Meet blocks disjunctively**: the meet of two barriers blocks a target iff *either*
component blocks it.  This is the dual of `join_blocks_iff` and the structural reason a meet
records the weakest obstruction. -/
theorem meet_blocks_iff (B₁ B₂ : Barrier) (t : ℕ) :
    (B₁.meet B₂).blocks t ↔ B₁.blocks t ∨ B₂.blocks t := by
  simp [Barrier.blocks, Barrier.meet]

-- !-- Lower ceiling blocks more: if B₁ ⊑ B₂ and B₂ already blocks t, then so does B₁. -- !--
/-- **Blocking is antitone in the ceiling order**: a weaker barrier (lower ceiling) blocks at
least every target a stronger one blocks.  This makes `blocks` compatible with the lattice
order `Barrier.le`. -/
theorem blocks_of_le_of_blocks {B₁ B₂ : Barrier} {t : ℕ}
    (hle : B₁.le B₂) (hb : B₂.blocks t) : B₁.blocks t :=
  lt_of_le_of_lt hle hb

/-! ## The distributive lattice laws on ceilings

The `ceiling` map is a homomorphism from the barrier algebra onto `(ℕ, max, min)`.  We record
the full distributive-lattice signature on ceilings. -/

-- !-- max is commutative on ℕ. -- !--
/-- Join is commutative on ceilings. -/
theorem join_comm_ceiling (B₁ B₂ : Barrier) :
    (B₁.join B₂).ceiling = (B₂.join B₁).ceiling := by
  simp [Barrier.join, max_comm]

-- !-- min is commutative on ℕ. -- !--
/-- Meet is commutative on ceilings. -/
theorem meet_comm_ceiling (B₁ B₂ : Barrier) :
    (B₁.meet B₂).ceiling = (B₂.meet B₁).ceiling := by
  simp [Barrier.meet, min_comm]

-- !-- max is associative on ℕ. -- !--
/-- Join is associative on ceilings (extends the catalog monoid law to the lattice). -/
theorem join_assoc_ceiling (B₁ B₂ B₃ : Barrier) :
    ((B₁.join B₂).join B₃).ceiling = (B₁.join (B₂.join B₃)).ceiling := by
  simp [Barrier.join, max_assoc]

-- !-- min is associative on ℕ. -- !--
/-- Meet is associative on ceilings. -/
theorem meet_assoc_ceiling (B₁ B₂ B₃ : Barrier) :
    ((B₁.meet B₂).meet B₃).ceiling = (B₁.meet (B₂.meet B₃)).ceiling := by
  simp [Barrier.meet, min_assoc]

-- !-- max a a = a and min a a = a on ℕ. -- !--
/-- Join is idempotent on ceilings. -/
theorem join_idem_ceiling (B : Barrier) : (B.join B).ceiling = B.ceiling := by
  simp [Barrier.join]

/-- Meet is idempotent on ceilings. -/
theorem meet_idem_ceiling (B : Barrier) : (B.meet B).ceiling = B.ceiling := by
  simp [Barrier.meet]

-- !-- Absorption: max c₁ (min c₁ c₂) = c₁ and min c₁ (max c₁ c₂) = c₁ on ℕ. -- !--
/-- Absorption law (join absorbs meet) on ceilings. -/
theorem join_meet_absorb (B₁ B₂ : Barrier) :
    (B₁.join (B₁.meet B₂)).ceiling = B₁.ceiling := by
  simp [Barrier.join, Barrier.meet]

/-- Absorption law (meet absorbs join) on ceilings. -/
theorem meet_join_absorb (B₁ B₂ : Barrier) :
    (B₁.meet (B₁.join B₂)).ceiling = B₁.ceiling := by
  simp [Barrier.meet, Barrier.join]

-- !-- Distributivity of max over min on ℕ (a distributive lattice); discharged by omega
-- after unfolding the ceilings. -- !--
/-- **Distributivity**: join distributes over meet on ceilings, completing the proof that
barriers form a *distributive* lattice (not merely a lattice).  This is the structural fact
that lets one reason compositionally about which combinations of barriers block a target. -/
theorem join_distrib_meet_ceiling (B₁ B₂ B₃ : Barrier) :
    (B₁.join (B₂.meet B₃)).ceiling
      = ((B₁.join B₂).meet (B₁.join B₃)).ceiling := by
  simp only [Barrier.join, Barrier.meet]
  omega

/-! ## Cross-domain bridge: the lattice meets Shannon counting

We connect the barrier algebra to the counting world of the catalog (`card_boolFn`,
`shannon_counting_lower_bound`).  A finite set `S` of "reachable" Boolean functions is a
*technique inventory*; if it is smaller than the function space it cannot be complete, so a
hard function exists.  This is the counting engine that *populates* targets the barrier lattice
then reasons about. -/

/-- A Boolean function on `n` variables (catalog `BoolFn`). -/
def BoolFn (n : ℕ) := (Fin n → Bool) → Bool

noncomputable instance (n : ℕ) : Fintype (BoolFn n) := by unfold BoolFn; infer_instance

-- !-- The function space has 2^(2^n) points: 2 outputs over the 2^n input assignments. -- !--
/-- The cardinality of the Boolean-function space is `2 ^ 2 ^ n` (catalog `card_boolFn`). -/
theorem card_boolFn (n : ℕ) : Fintype.card (BoolFn n) = 2 ^ 2 ^ n := by
  unfold BoolFn
  simp [Fintype.card_bool]

-- !-- Pigeonhole: if |S| < |BoolFn n| then S ≠ univ, so some f ∉ S. -- !--
/-- **Shannon incompleteness of a technique inventory** (cross-domain bridge): any finite set
of reachable Boolean functions smaller than `2 ^ 2 ^ n` omits some function — a hard function
the inventory cannot reach.  Combined with the lattice, this furnishes the *targets* that
barriers block. (Catalog analogue: `shannon_counting_lower_bound`.) -/
theorem shannon_barrier_incomplete {n : ℕ} (S : Finset (BoolFn n))
    (hS : S.card < 2 ^ 2 ^ n) : ∃ f : BoolFn n, f ∉ S := by
  by_contra h
  push_neg at h
  have hle : Fintype.card (BoolFn n) ≤ S.card := by
    rw [← card_univ]
    exact card_le_card (fun x _ => h x)
  rw [card_boolFn] at hle
  omega

end BarrierLattice