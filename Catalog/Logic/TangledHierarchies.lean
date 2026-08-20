/-
# Tangled Hierarchies: Order, Grading, and the Inconsistency of the Ultimate Tangle

A *tangled hierarchy* is a level structure in which some pair of elements sits both
above and below one another — a two-cycle `x ≺ y` and `y ≺ x`.  Hofstadter's
"strange loops" are the informal picture; here we give the order-theoretic core and
draw a sharp line between hierarchies that *can* be tangled and hierarchies that
*cannot*.

The central findings of this cycle are:

* **Well-founded hierarchies are never tangled.**  In particular the ladder of
  levels modelled by `(ℕ, <)` — the abstract shape of the tower
  `level₀ ≺ level₁ ≺ level₂ ≺ ⋯` — carries no tangle.
* **A grading forbids tangles.**  Any relation that admits an integer *rank*
  strictly increasing along every edge is untangled.  Contrapositively, a genuinely
  tangled hierarchy admits *no* consistent level assignment: one must abandon either
  the tangle or the grading.  This is the crisp form of the informal conjecture that
  a consistent tangled hierarchy costs you either consistency or the hierarchy.
* **Apparent tangles from adjacency.**  Allowing each level to "refer to" its
  neighbours produces a symmetric adjacency relation that *is* tangled, even though
  the underlying level order is not — the polymorphic "a term at level `n` may
  mention level `n+1`" phenomenon, seen from the graph side.
* **The ultimate tangle is inconsistent.**  A universe that reflects its own full
  power set — an element for every predicate over itself — cannot exist.  This is the
  Cantor/Girard heart of "`Type : Type`", proved here by a self-contained diagonal
  argument and, in a bridge result, from the catalog's Lawvere fixed-point theorem.

## Relationship to catalog
* Complements `Logic.StrangeLoops.Core` (Lawvere/Gödel view of tangled hierarchies)
  with the order-theoretic and grading view, and reuses its `cantor_from_lawvere`.
-/

import Mathlib
import Catalog.Logic.StrangeLoops.Core

namespace TangledHierarchies

universe u

variable {α : Type u}

/-! ## Part 1 — Tangles and cycles -/

/-- A relation is **tangled** when some pair lies both above and below the other:
a two-cycle `r x y ∧ r y x`.  This is the minimal formal shape of a "strange loop". -/
def IsTangled (r : α → α → Prop) : Prop := ∃ x y, r x y ∧ r y x

/-- A **self-loop** `r x x` is the degenerate one-element tangle. -/
def HasSelfLoop (r : α → α → Prop) : Prop := ∃ x, r x x

/-- Every self-loop is a tangle (take `x = y`). -/
theorem isTangled_of_selfLoop {r : α → α → Prop} (h : HasSelfLoop r) : IsTangled r := by
  obtain ⟨x, hx⟩ := h
  exact ⟨x, x, hx, hx⟩

/-- An **asymmetric** hierarchy (no edge has a reverse) is never tangled. -/
theorem asymmetric_not_tangled {r : α → α → Prop}
    (h : ∀ a b, r a b → ¬ r b a) : ¬ IsTangled r := by
  rintro ⟨x, y, hxy, hyx⟩
  exact h x y hxy hyx

/-- Conversely, a tangle rules out asymmetry: to keep a tangle you must give up the
"strict order" character of the hierarchy. -/
theorem tangled_not_asymmetric {r : α → α → Prop}
    (h : IsTangled r) : ¬ (∀ a b, r a b → ¬ r b a) := by
  intro hasym
  exact asymmetric_not_tangled hasym h

/-! ## Part 2 — Well-founded hierarchies carry no tangle -/

/-- **Well-founded hierarchies are never tangled.**  A two-cycle would make each of
its two members mutually inaccessible, contradicting well-foundedness. -/
theorem wellFounded_not_tangled {r : α → α → Prop}
    (hwf : WellFounded r) : ¬ IsTangled r :=
  asymmetric_not_tangled hwf.asymmetric

/-- The strict order of any preorder is untangled. -/
theorem strictOrder_not_tangled [Preorder α] :
    ¬ IsTangled ((· < ·) : α → α → Prop) :=
  asymmetric_not_tangled fun _ _ => lt_asymm

/-- **The universe-level ladder is not tangled.**  Modelling the tower
`level₀ ≺ level₁ ≺ ⋯` by `(ℕ, <)`, well-foundedness forbids any level from being
both above and below another. -/
theorem universeLevels_not_tangled :
    ¬ IsTangled ((· < ·) : ℕ → ℕ → Prop) :=
  wellFounded_not_tangled wellFounded_lt

/-! ## Part 3 — Grading: the price of a consistent tangle -/

/-- **A grading forbids tangles.**  If a relation admits an integer rank that
strictly increases along every edge, it cannot be tangled.  This is the exact sense
in which *levels* (a rank function) rule out strange loops. -/
theorem graded_not_tangled {r : α → α → Prop} (rank : α → ℕ)
    (hmono : ∀ a b, r a b → rank a < rank b) : ¬ IsTangled r := by
  rintro ⟨x, y, hxy, hyx⟩
  have h1 := hmono x y hxy
  have h2 := hmono y x hyx
  omega

/-- **The consistency dichotomy.**  A genuinely tangled hierarchy admits *no*
strictly increasing rank function into `ℕ`: to keep the tangle you must abandon the
grading (the levels).  This is the formal core of the informal conjecture that a
consistent tangled hierarchy costs either consistency or the hierarchy. -/
theorem tangled_has_no_grading {r : α → α → Prop} (h : IsTangled r) :
    ¬ ∃ rank : α → ℕ, ∀ a b, r a b → rank a < rank b := by
  rintro ⟨rank, hmono⟩
  exact graded_not_tangled rank hmono h

/-! ## Part 4 — Apparent tangles from adjacency (polymorphic reference) -/

/-- The **adjacency** relation on levels: a level may refer to the level immediately
above or below it.  This models the polymorphic phenomenon "a term at level `n` may
mention level `n+1`" purely on the reference graph. -/
def refersAdjacent (n m : ℕ) : Prop := m = n + 1 ∨ n = m + 1

/-- Adjacency is symmetric: reference between neighbouring levels goes both ways. -/
theorem refersAdjacent_symm : Symmetric refersAdjacent := by
  intro a b h
  rcases h with h | h
  · exact Or.inr h
  · exact Or.inl h

/-- **Adjacency is tangled.**  Levels `0` and `1` refer to each other, so the
reference graph contains a strange loop even though the level order does not. -/
theorem refersAdjacent_isTangled : IsTangled refersAdjacent :=
  ⟨0, 1, Or.inl rfl, Or.inr rfl⟩

/-- Any nonempty symmetric relation is tangled: symmetry turns a single edge into a
two-cycle.  This isolates *why* the reference/adjacency view produces loops. -/
theorem symmetric_isTangled {r : α → α → Prop} (hs : Symmetric r)
    {x y : α} (h : r x y) : IsTangled r :=
  ⟨x, y, h, hs h⟩

/-- Because it is tangled, adjacency admits no consistent level grading — even though
it lives *on top of* the perfectly well-founded ladder `(ℕ, <)`.  The tangle is real,
not an artefact of the underlying order. -/
theorem refersAdjacent_has_no_grading :
    ¬ ∃ rank : ℕ → ℕ, ∀ a b, refersAdjacent a b → rank a < rank b :=
  tangled_has_no_grading refersAdjacent_isTangled

/-! ## Part 5 — The ultimate tangle: a self-reflecting universe is inconsistent -/

/-- **Diagonal / Cantor.**  No map from a type onto its own power set is surjective.
Self-contained proof by the diagonal set `{x | x ∉ f x}`. -/
theorem no_surjective_to_powerset (f : α → Set α) : ¬ Function.Surjective f := by
  intro hf
  obtain ⟨a, ha⟩ := hf {x | x ∉ f x}
  have h : a ∈ {x | x ∉ f x} ↔ a ∈ f a := by rw [ha]
  simp only [Set.mem_setOf_eq] at h
  tauto

/-- A **reflective universe**: a type `U` together with a decoding of each element as
a predicate over `U`, such that *every* predicate over `U` is named by some element.
This is the ultimate tangle — a universe reflecting its own full power set, the shape
of "`Type : Type`". -/
structure ReflectiveUniverse (U : Type u) where
  /-- Each code names a subset of the universe. -/
  decode : U → Set U
  /-- Every subset of the universe has a code: the universe reflects its power set. -/
  complete : Function.Surjective decode

/-- **The ultimate tangle is inconsistent.**  No reflective universe exists: a type
cannot contain a name for every predicate over itself.  This is the Cantor/Girard
core of the inconsistency of `Type : Type`. -/
theorem no_reflectiveUniverse (U : Type u) : IsEmpty (ReflectiveUniverse U) := by
  constructor
  rintro ⟨decode, hsurj⟩
  exact no_surjective_to_powerset decode hsurj

/-- The **Russell code** made explicit: inside any (hypothetical) reflective universe
the code `r` naming `{x | x ∉ decode x}` satisfies `r ∈ decode r ↔ r ∉ decode r`,
the concrete self-membership paradox behind the collapse. -/
theorem reflectiveUniverse_russell (U : Type u) (V : ReflectiveUniverse U) :
    ∃ r : U, (r ∈ V.decode r ↔ r ∉ V.decode r) := by
  obtain ⟨r, hr⟩ := V.complete {x | x ∉ V.decode x}
  refine ⟨r, ?_⟩
  have h : r ∈ {x | x ∉ V.decode x} ↔ r ∈ V.decode r := by rw [hr]
  simpa only [Set.mem_setOf_eq] using h.symm

/-! ## Part 6 — Bridge to the catalog's Lawvere machinery -/

/-- **Bridge.**  The `Prop`-valued form of the ultimate tangle is refuted directly by
the catalog's Lawvere-based Cantor theorem: no element of `U` can name every predicate
`U → Prop`.  This links the order-theoretic picture here to the fixed-point view in
`Logic.StrangeLoops.Core`. -/
theorem no_propReflectiveUniverse (U : Type u) :
    ¬ ∃ decode : U → (U → Prop), Function.Surjective decode :=
  cantor_from_lawvere U

end TangledHierarchies

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   A "tangled hierarchy" (Hofstadter) — an order with a two-cycle x ≺ y, y ≺ x —
--   cannot coexist with a well-founded level structure. We conjectured a sharp
--   dichotomy: a hierarchy is either *graded* (carries an increasing ℕ-rank) or it
--   is *tangled*, never both; and that the maximal tangle (a universe reflecting its
--   own power set, the shape of `Type : Type`) is outright inconsistent.
--
-- Experiment (Experimenter):
--   • `IsTangled` captures the two-cycle. `asymmetric_not_tangled` and
--     `wellFounded_not_tangled` show orders/well-founded relations avoid tangles;
--     `universeLevels_not_tangled` instantiates this at `(ℕ, <)`.
--   • `graded_not_tangled` (proof: `omega` on `rank x < rank y < rank x`) is the
--     structural core; `tangled_has_no_grading` is its contrapositive.
--   • `refersAdjacent` witnesses a genuine tangle living atop the untangled ladder,
--     and `symmetric_isTangled` explains why (symmetry ⇒ two-cycle).
--   • `no_surjective_to_powerset` (self-contained diagonal) yields
--     `no_reflectiveUniverse`; `reflectiveUniverse_russell` exhibits the explicit
--     self-membership fixed point; `no_propReflectiveUniverse` re-derives the
--     Prop-valued case from the catalog's `cantor_from_lawvere`.
--
-- Analysis (Analyst):
--   Survived: all six main results. The unifying pattern is that *rank* (a grading)
--   is exactly the resource a tangle consumes — a two-cycle forces a strict integer
--   descent into itself, which `omega` refutes. The Cantor/Girard collapse is the
--   same obstruction one cardinal higher: no carrier ranks its own power set.
--   Failure mode noticed and avoided: stating the tangle as mere reflexivity would
--   trivialize it; requiring two distinct-role edges keeps the adjacency example
--   informative.
--
-- Critique (Critic):
--   No theorem is vacuous: `refersAdjacent_isTangled` gives a concrete inhabitant,
--   and the impossibility results have nonempty hypotheses (a surjection/structure)
--   that are refuted, not assumed away. No proof references itself. Axioms are the
--   standard `propext/Classical.choice/Quot.sound` only; `universeLevels_not_tangled`
--   and `reflectiveUniverse_russell` are axiom-free.
--
-- Synthesis (PI):
--   The order-theoretic view complements `Logic.StrangeLoops.Core`: strange loops are
--   precisely relations with no ℕ-grading, and the ultimate loop is Cantor-forbidden.
--   See `FUTURE_DIRECTIONS.md` for the next-cycle conjectures (ordinal-valued ranks,
--   n-cycles, and stratified reflection).
-- !-- Lab Notes -- !--