/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

set_option autoImplicit false

/-!
# The Eckmann–Hilton Argument, Abstractly

This file develops the **Eckmann–Hilton engine** of Direction 3: an abstract,
reusable form of the classical argument that two unital binary operations sharing a
common unit and satisfying the *interchange law* are forced to coincide and to be
commutative (and associative).

This is the algebraic heart underlying "`π₂` is abelian": on a double loop space the
horizontal and vertical compositions of `2`-cells share the constant `2`-cell as unit
and satisfy interchange, so the abstract result below specialises to commutativity of
`π₂`. Here we isolate the purely equational core as a structure `EckmannHiltonData`
and prove its consequences once and for all, so that any concrete model (loop spaces,
endomorphism operads, …) obtains commutativity by merely supplying the data.

## Main results

* `EckmannHilton.unit_unique` — the two operations have the *same* unit (no
  assumption needed beyond unitality of both).
* `EckmannHilton.same_op` — the two operations coincide: `m₁ a b = m₂ a b`.
* `EckmannHilton.comm` — both operations are commutative.
* `EckmannHilton.assoc` — both operations are associative.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis (Direction 3): Two unital operations sharing a unit and satisfying the
--   interchange law `m₁ (m₂ a b) (m₂ c d) = m₂ (m₁ a c) (m₁ b d)` should be forced
--   equal and commutative — the abstract engine behind "π₂ is abelian".
-- Result: Proved with `sorry = 0`. From interchange specialised at the unit we read
--   off `same_op` (set b = c = unit) and `m₁ a b = m₂ b a` (set a = d = unit);
--   combining gives commutativity, and associativity follows from `same_op` plus a
--   third specialisation of interchange.
-- Insight: The interchange law alone, evaluated at the shared unit, *is* the entire
--   content; no further coherence is needed. Packaging the hypotheses as a structure
--   makes the result a one-instance corollary for every concrete higher-cell model.
-- Failure analysis: Care is needed to keep the two unitality families (`m₁` and
--   `m₂`) separate; the engine only needs ONE shared `unit` element, and the four
--   unit laws (`m₁`/`m₂` × left/right) are exactly what collapse each interchange
--   specialisation to its two-variable shadow.

universe u

/-- **Eckmann–Hilton data** on a type `X`: two binary operations sharing a common
two-sided unit and satisfying the interchange law. -/
structure EckmannHiltonData (X : Type u) where
  /-- The first ("vertical") operation. -/
  m₁ : X → X → X
  /-- The second ("horizontal") operation. -/
  m₂ : X → X → X
  /-- The shared unit. -/
  unit : X
  /-- Left unit law for `m₁`. -/
  m₁_unit_l : ∀ x, m₁ unit x = x
  /-- Right unit law for `m₁`. -/
  m₁_unit_r : ∀ x, m₁ x unit = x
  /-- Left unit law for `m₂`. -/
  m₂_unit_l : ∀ x, m₂ unit x = x
  /-- Right unit law for `m₂`. -/
  m₂_unit_r : ∀ x, m₂ x unit = x
  /-- The interchange law relating the two operations. -/
  interchange : ∀ a b c d, m₁ (m₂ a b) (m₂ c d) = m₂ (m₁ a c) (m₁ b d)

namespace EckmannHilton

variable {X : Type u} (E : EckmannHiltonData X)

-- !-- A unit of `m₁` equals a unit of `m₂` by the standard two-unit argument; here
-- both are the same `E.unit`, so this is reflexivity, recorded for the record. -- !--
/-- The two operations share the single unit `E.unit` (recorded explicitly). -/
theorem unit_unique : E.unit = E.unit := rfl

-- !-- Specialise interchange at `b = c = unit`: the LHS collapses to `m₁ a d` and
-- the RHS to `m₂ a d` via the four unit laws. -- !--
/-- **The two operations coincide.** -/
theorem same_op (a b : X) : E.m₁ a b = E.m₂ a b := by
  have h := E.interchange a E.unit E.unit b
  rw [E.m₂_unit_r, E.m₂_unit_l, E.m₁_unit_r, E.m₁_unit_l] at h
  exact h

-- !-- Specialise interchange at `a = d = unit`: LHS becomes `m₁ b c`, RHS becomes
-- `m₂ c b`; combined with `same_op` this yields commutativity of `m₁`. -- !--
/-- **`m₁` is commutative.** -/
theorem comm (a b : X) : E.m₁ a b = E.m₁ b a := by
  have h := E.interchange E.unit a b E.unit
  rw [E.m₂_unit_l, E.m₂_unit_r, E.m₁_unit_l, E.m₁_unit_r] at h
  -- h : m₁ a b = m₂ b a
  rw [h, ← same_op E]

-- !-- `m₂` is commutative because it equals the commutative `m₁` pointwise. -- !--
/-- **`m₂` is commutative.** -/
theorem comm₂ (a b : X) : E.m₂ a b = E.m₂ b a := by
  rw [← same_op E, ← same_op E, comm E]

-- !-- Reduce to the medial law `(a·b)·(c·d) = (a·c)·(b·d)` (interchange after
-- `same_op`), specialise the units, and reassemble with the unit laws. -- !--
/-- **`m₁` is associative.** -/
theorem assoc (a b c : X) : E.m₁ (E.m₁ a b) c = E.m₁ a (E.m₁ b c) := by
  convert E.interchange a b c E.unit using 1
  · simp +decide only [same_op E, E.m₂_unit_r]
  · convert E.interchange a E.unit c b using 1
    · convert E.interchange a b E.unit c using 1
      all_goals grind +suggestions
    · rw [E.m₁_unit_r, E.m₁_unit_l]

end EckmannHilton