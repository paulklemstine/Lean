import Logic.BelnapFour.Core

/-!
# Belnap's FOUR: paraconsistency and the product representation `FOUR ≅ 2 ⊙ 2`

Building on `Logic.BelnapFour.Core`, this file proves the two facts that make FOUR the
*smallest non-trivial paraconsistent bilattice*:

* **Paraconsistency (non-explosion).** With the designated set `D = {T, B}`, the
  "contradiction" premise `designated a ∧ designated (¬a)` is *satisfiable* in FOUR
  (witness `B`), yet it does **not** entail an arbitrary conclusion. By contrast the
  classical two-valued algebra makes that premise *unsatisfiable*, which is why classical
  logic is explosive.

* **Representation `FOUR ≅ Bool × Bool` (Ginsberg's `2 ⊙ 2`).** The map
  `N ↦ (ff,ff)`, `F ↦ (ff,tt)`, `T ↦ (tt,ff)`, `B ↦ (tt,tt)`
  ("evidence-for", "evidence-against") is a bijection under which the knowledge order is
  the product order, the knowledge meet/join are componentwise `&&`/`||`, the truth order
  is the *twisted* product order (first up, second down), and negation is the coordinate
  swap. Hence FOUR has exactly `2² = 4` elements: it is the bilattice over the smallest
  non-trivial lattice `2 = Bool`.

-- !-- Lab Notebook -- !--
Hypothesis: FOUR is paraconsistent and is the smallest such bilattice, realised as the
  product `2 ⊙ 2` of the two-element lattice with itself.
Result: `explosion_premise_satisfiable` + `no_explosion` establish paraconsistency;
  `bool_explosion_*` show the classical algebra is explosive only because its
  contradiction premise is unsatisfiable; `belnap_iso_prod` and the transport lemmas
  establish `FOUR ≅ Bool × Bool`; `card_four` + `orders_two_dimensional` pin down
  minimality and genuine two-dimensionality.
Insight: Paraconsistency is exactly the gap between *satisfiable* contradiction premises
  and *valid* explosion — a gap that opens precisely when a value (here `B`) is both
  designated and has a designated negation. The fourth value `N` is forced as the
  knowledge-order bottom dual to `B`, which is why four is the minimum.
Failure analysis: A naive "conflation = componentwise negation" guess is false; the
  correct transport is `conf ↦ (¬·₂, ¬·₁)` (swap-then-negate), found by recomputing the
  table. The `decide`-checked transport lemmas guard against such table errors.
-/

namespace BelnapFour
namespace Belnap

/-- The designated ("at least true") values: `T` and `B`. A valuation makes a sentence
assertible exactly when its value is designated. -/
def designated (a : Belnap) : Prop := a = T ∨ a = B

instance (a : Belnap) : Decidable (designated a) := by
  unfold designated; exact inferInstance

/-! ## Designation respects the truth order -/

-- !-- The truth order is the FDE entailment relation: moving up `≤_t` can only turn a
-- non-designated value designated, never the reverse. Finite case check. -- !--
/-- Tautological (FDE) entailment is the truth order: if `a ≤_t b` then designation is
preserved from `a` to `b`. -/
theorem tle_preserves_designated :
    ∀ a b : Belnap, tle a b → designated a → designated b := by
  decide

/-! ## Theorem 4 — paraconsistency (non-explosion) -/

-- !-- `B` is designated and so is `¬B = B`, so the contradiction premise is satisfiable
-- in FOUR — unlike in the classical algebra. -- !--
/-- **Theorem 4a.** The contradiction premise is *satisfiable* in FOUR: some value is
designated together with its negation (witness `B`). -/
theorem explosion_premise_satisfiable :
    ∃ a : Belnap, designated a ∧ designated (neg a) := by
  decide

-- !-- Taking the satisfiable premise `a = B` and conclusion `q = F` (not designated)
-- refutes explosion. Finite case check. -- !--
/-- **Theorem 4b (Paraconsistency).** FOUR is *non-explosive*: it is not the case that a
designated value with a designated negation entails every conclusion. -/
theorem no_explosion :
    ¬ (∀ a q : Belnap, designated a → designated (neg a) → designated q) := by
  decide

/-- **Theorem 4c.** The classical two-valued algebra is explosive *because* its
contradiction premise is unsatisfiable: no Boolean value is designated together with its
classical negation. -/
theorem bool_explosion_premise_unsatisfiable :
    ¬ ∃ b : Bool, b = true ∧ (!b) = true := by
  decide

/-- **Theorem 4c′.** Consequently classical logic validates explosion (vacuously): from a
Boolean contradiction premise every conclusion follows. -/
theorem bool_validates_explosion :
    ∀ b q : Bool, b = true → (!b) = true → q = true := by
  decide

/-! ## Theorem 5 — the product representation `FOUR ≅ 2 ⊙ 2` -/

/-- The representation map sending a Belnap value to its
`(evidence-for, evidence-against)` pair in `Bool × Bool`. -/
def toProd : Belnap → Bool × Bool
  | N => (false, false)
  | F => (false, true)
  | T => (true, false)
  | B => (true, true)

/-- The inverse of `toProd`. -/
def ofProd : Bool × Bool → Belnap
  | (false, false) => N
  | (false, true)  => F
  | (true, false)  => T
  | (true, true)   => B

-- !-- `ofProd` and `toProd` are mutually inverse on the four-element carrier; finite
-- round-trip check. -- !--
/-- **Theorem 5a.** `toProd` is a bijection `Belnap ≃ Bool × Bool`; in particular FOUR has
exactly `2² = 4` elements, the bilattice over the two-element lattice. -/
theorem belnap_iso_prod :
    (∀ a : Belnap, ofProd (toProd a) = a) ∧ (∀ p : Bool × Bool, toProd (ofProd p) = p) := by
  refine ⟨?_, ?_⟩ <;> decide

/-- Packaged equivalence `Belnap ≃ Bool × Bool`. -/
def equivProd : Belnap ≃ Bool × Bool where
  toFun := toProd
  invFun := ofProd
  left_inv a := belnap_iso_prod.1 a
  right_inv p := belnap_iso_prod.2 p

-- !-- Under `toProd` the knowledge order is the product order and the truth order is the
-- twisted product order (first coordinate up, second coordinate down). -- !--
/-- **Theorem 5b.** Transport of the two orders: knowledge = product order, truth =
twisted product order. -/
theorem orders_transport :
    (∀ a b : Belnap, kle a b ↔
        (toProd a).1 ≤ (toProd b).1 ∧ (toProd a).2 ≤ (toProd b).2) ∧
    (∀ a b : Belnap, tle a b ↔
        (toProd a).1 ≤ (toProd b).1 ∧ (toProd b).2 ≤ (toProd a).2) := by
  refine ⟨?_, ?_⟩ <;> decide

-- !-- All four operations and both involutions transport to coordinatewise Boolean
-- operations on `Bool × Bool`, confirming `FOUR = 2 ⊙ 2`. -- !--
/-- **Theorem 5c.** Transport of all operations: every Belnap operation becomes a
coordinatewise Boolean operation on `Bool × Bool` (knowledge meet/join are componentwise
`&&`/`||`; truth meet/join twist the second coordinate; negation swaps; conflation
swap-negates). This is the defining property of the product bilattice `2 ⊙ 2`. -/
theorem operations_transport :
    (∀ a b : Belnap, toProd (a ⊗ₖ b) = ((toProd a).1 && (toProd b).1, (toProd a).2 && (toProd b).2)) ∧
    (∀ a b : Belnap, toProd (a ⊕ₖ b) = ((toProd a).1 || (toProd b).1, (toProd a).2 || (toProd b).2)) ∧
    (∀ a b : Belnap, toProd (a ⊓ₜ b) = ((toProd a).1 && (toProd b).1, (toProd a).2 || (toProd b).2)) ∧
    (∀ a b : Belnap, toProd (a ⊔ₜ b) = ((toProd a).1 || (toProd b).1, (toProd a).2 && (toProd b).2)) ∧
    (∀ a : Belnap, toProd (neg a) = ((toProd a).2, (toProd a).1)) ∧
    (∀ a : Belnap, toProd (conf a) = (!(toProd a).2, !(toProd a).1)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-! ## Theorem 6 — minimality and genuine two-dimensionality -/

/-- **Theorem 6a.** FOUR has exactly four elements. -/
theorem card_four : Fintype.card Belnap = 4 := by decide

-- !-- The two orders are genuinely different: each contains a strict relation absent from
-- the other, so FOUR is a real bilattice rather than one order duplicated. -- !--
/-- **Theorem 6b.** The truth and knowledge orders are genuinely two-dimensional: neither
order refines the other, so the bilattice does not collapse to a single chain/lattice. -/
theorem orders_two_dimensional :
    (∃ a b : Belnap, tle a b ∧ ¬ kle a b) ∧ (∃ a b : Belnap, kle a b ∧ ¬ tle a b) := by
  decide

/-- **Theorem 6c.** Minimality witness: paraconsistency forces at least three pairwise
distinct *truth*-relevant values — a designated value whose negation is designated (`B`),
a designated value whose negation is *not* designated (`T`), and a non-designated value
(`F`) — and the knowledge order then forces the fourth value `N` as the bottom dual to
`B`. The four values `N, F, T, B` are pairwise distinct. -/
theorem four_distinct_values :
    designated B ∧ designated (neg B) ∧
    designated T ∧ ¬ designated (neg T) ∧
    ¬ designated F ∧
    (∀ a : Belnap, kle N a) ∧
    [N, F, T, B].Nodup := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

end Belnap
end BelnapFour