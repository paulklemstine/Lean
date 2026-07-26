/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.SemicubeHelly

/-!
# The opposite-semicube matching (Helly) property of Cartesian products of partial cubes

A **partial cube** is an isometric subgraph of a hypercube.  By the
Djoković–Winkler theory, the edges of a partial cube split into *Θ-classes*, and
each Θ-class `i` cuts the vertex set into two **opposite semicubes**
`W_i^+` and `W_i^-` (the vertices lying on the two sides of the cut).  In the
coordinate model used here a vertex of a hypercube on coordinate set `α` is a
sign vector `α → Bool`, a partial cube is a distinguished finite set of such
vectors `V : Finset (α → Bool)`, and the semicube of coordinate `i` with sign
`b` is `Semicube V i b = { v ∈ V | v i = b }`.

We isolate two structural notions:

* **Harmonic-evenness** (`HarmonicEven`): every Θ-class splits the vertex set
  into two *equal-sized* opposite semicubes.  This is the exact discrete analogue
  of a harmonic (mean-value) symmetry: each cut is perfectly balanced.

* **The opposite-semicube Helly property** (`OppositeSemicubeHelly`): for every
  Θ-class the two opposite semicubes can be matched by a bijection.  This is a
  transversal/Helly-type condition in the spirit of Hall's theorem: the two
  opposite pieces of every cut admit a common system of representatives.

The main results are:

* `osh_iff_harmonicEven` — the opposite-semicube Helly property holds exactly
  when the partial cube is harmonic-even (a matching of a cut exists iff the two
  sides are equinumerous).

* `harmonicEven_prodCube` — harmonic-evenness factors through the Cartesian
  product: `P □ R` is harmonic-even iff both `P` and `R` are.

* `oppositeSemicubeHelly_prodCube` — **main theorem**: a Cartesian product of two
  partial cubes satisfies the opposite-semicube Helly property if and only if
  both factors are harmonic-even.

* `product_hypercube_semicube_helly2` — the classical Helly-number-2 property for
  semicubes (from `Bridges.SemicubeHelly`) transfers verbatim to a Cartesian
  product of hypercubes, since a product of hypercubes is again a hypercube on the
  disjoint union of coordinates.

## References (catalog)

* `Djoković-Winkler theorem` — Θ-classes and semicubes of partial cubes.
* `Polat's theorem` — Helly properties in partial cubes.
* `Bridges.SemicubeHelly` — the Helly-number-2 property for semicubes of a hypercube.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For Cartesian products of partial cubes, a global
"opposite-semicube Helly" symmetry should be forced coordinate-by-coordinate, and
since the Θ-classes of `P □ R` are exactly the disjoint union of those of `P` and
`R`, the property should factor as a conjunction over the two factors.  Bold form:
the Helly-type property is equivalent to a purely metric balance condition
(harmonic-evenness) of each factor.

Experiment (Experimenter): Model vertices as `α → Bool`.  A matching between the
two opposite semicubes of a cut is a bijection of subtypes; by finiteness this
exists iff the two semicubes have equal cardinality (`Fintype.equivOfCardEq` and
its converse `Fintype.card_congr`).  For the product `P □ R = { Sum.elim a b }`
the semicube of an `α`-coordinate is `(Semicube P i c) ×ˢ R` (up to the injective
merge map), so its cardinality is `|Semicube P i c| · |R|`; cancelling the
positive factor `|R|` recovers balance of `P`.

Analysis (Analyst): Harmonic-evenness is coordinate-local and multiplicative
across a product, exactly because the merge map `(a,b) ↦ Sum.elim a b` is a
bijection onto the product cube.  The nonemptiness of each factor is *load
bearing*: if `R = ∅` then `P □ R = ∅` is vacuously balanced while `P` need not be.

Critique (Critic): The equivalence `osh_iff_harmonicEven` is not definitional —
one direction needs the existence of a bijection from equal cardinalities, the
other the cardinality equality from a bijection.  The product theorem needs
genuine cancellation of a positive natural-number factor, not `rfl`/`simp`.  The
catalog transfer `product_hypercube_semicube_helly2` is a real specialization of a
proved theorem at the sum index type, not a restatement.

Synthesis (PI): The Helly-type symmetry of a product partial cube is completely
governed by the balance of its factors; see `FUTURE_DIRECTIONS.md`.
-/

open Finset

namespace OppositeSemicube

variable {α β : Type*}

/-- The merge map sending a pair of sign vectors to a sign vector on the disjoint
union of coordinates is injective. -/
lemma merge_injective :
    Function.Injective (fun p : (α → Bool) × (β → Bool) => Sum.elim p.1 p.2) := by
  rintro ⟨a, b⟩ ⟨a', b'⟩ h
  have hl : a = a' := funext fun i => congrFun h (Sum.inl i)
  have hr : b = b' := funext fun j => congrFun h (Sum.inr j)
  simp [hl, hr]

variable [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- The **semicube** of coordinate `i` with sign `b`: the vertices of `V` whose
`i`-th coordinate equals `b`. -/
def Semicube (V : Finset (α → Bool)) (i : α) (b : Bool) : Finset (α → Bool) :=
  V.filter (fun v => v i = b)

/-- A coordinate `i` is **balanced** in `V` if its two opposite semicubes are
equinumerous. -/
def Balanced (V : Finset (α → Bool)) (i : α) : Prop :=
  (Semicube V i true).card = (Semicube V i false).card

/-- `V` is **harmonic-even** if every coordinate (Θ-class) splits `V` into two
equal-sized opposite semicubes. -/
def HarmonicEven (V : Finset (α → Bool)) : Prop := ∀ i, Balanced V i

/-- The **opposite-semicube Helly property**: for every coordinate the two
opposite semicubes admit a matching (a bijection between them). -/
def OppositeSemicubeHelly (V : Finset (α → Bool)) : Prop :=
  ∀ i, Nonempty (↥(Semicube V i true) ≃ ↥(Semicube V i false))

/-- The **Cartesian product** `P □ R` of two partial cubes, realised on the
disjoint-union coordinate set `α ⊕ β`.  A vertex `(a, b)` becomes the sign vector
`Sum.elim a b`. -/
def prodCube (P : Finset (α → Bool)) (R : Finset (β → Bool)) :
    Finset (α ⊕ β → Bool) :=
  (P ×ˢ R).image (fun p => Sum.elim p.1 p.2)

omit [DecidableEq α] [DecidableEq β] in
/-- The `α`-coordinate semicube of a product is the merge image of a product of a
factor semicube with the other factor. -/
lemma semicube_prodCube_inl (P : Finset (α → Bool)) (R : Finset (β → Bool))
    (i : α) (c : Bool) :
    Semicube (prodCube P R) (Sum.inl i) c
      = ((Semicube P i c) ×ˢ R).image (fun p => Sum.elim p.1 p.2) := by
  unfold Semicube prodCube;
  aesop

omit [DecidableEq α] [DecidableEq β] in
/-- The `β`-coordinate semicube of a product is the merge image of a product of
the first factor with a factor semicube. -/
lemma semicube_prodCube_inr (P : Finset (α → Bool)) (R : Finset (β → Bool))
    (j : β) (c : Bool) :
    Semicube (prodCube P R) (Sum.inr j) c
      = (P ×ˢ (Semicube R j c)).image (fun p => Sum.elim p.1 p.2) := by
  unfold Semicube prodCube;
  aesop

omit [DecidableEq α] [DecidableEq β] in
/-- Cardinality of an `α`-coordinate semicube of the product. -/
lemma card_semicube_prodCube_inl (P : Finset (α → Bool)) (R : Finset (β → Bool))
    (i : α) (c : Bool) :
    (Semicube (prodCube P R) (Sum.inl i) c).card
      = (Semicube P i c).card * R.card := by
  rw [semicube_prodCube_inl, Finset.card_image_of_injective _ merge_injective,
    Finset.card_product]

omit [DecidableEq α] [DecidableEq β] in
/-- Cardinality of a `β`-coordinate semicube of the product. -/
lemma card_semicube_prodCube_inr (P : Finset (α → Bool)) (R : Finset (β → Bool))
    (j : β) (c : Bool) :
    (Semicube (prodCube P R) (Sum.inr j) c).card
      = P.card * (Semicube R j c).card := by
  rw [semicube_prodCube_inr, Finset.card_image_of_injective _ merge_injective,
    Finset.card_product]

/-- **Characterization of the opposite-semicube Helly property.** A partial cube
satisfies the opposite-semicube Helly property exactly when it is harmonic-even:
each cut can be matched iff its two sides are equinumerous. -/
theorem osh_iff_harmonicEven (V : Finset (α → Bool)) :
    OppositeSemicubeHelly V ↔ HarmonicEven V := by
  constructor;
  · intro h i; obtain ⟨ e ⟩ := h i; exact (by
    convert Fintype.card_congr e using 1 ; simp +decide [ Fintype.card_subtype ];
    rfl);
  · intro h i; exact ⟨Fintype.equivOfCardEq (by
    simpa [ Fintype.card_subtype ] using h i)⟩;

omit [DecidableEq α] [DecidableEq β] in
/-- **Harmonic-evenness factors through Cartesian products.** For nonempty factors,
the product `P □ R` is harmonic-even iff both `P` and `R` are. -/
theorem harmonicEven_prodCube (P : Finset (α → Bool)) (R : Finset (β → Bool))
    (hP : P.Nonempty) (hR : R.Nonempty) :
    HarmonicEven (prodCube P R) ↔ HarmonicEven P ∧ HarmonicEven R := by
  unfold HarmonicEven;
  simp +decide [ Balanced ];
  simp +decide only [card_semicube_prodCube_inl, card_semicube_prodCube_inr];
  simp +decide [ hP.card_pos.ne', hR.card_pos.ne' ]

/-- **Main theorem.** A Cartesian product of two partial cubes satisfies the
opposite-semicube Helly property if and only if both factors are harmonic-even. -/
theorem oppositeSemicubeHelly_prodCube (P : Finset (α → Bool)) (R : Finset (β → Bool))
    (hP : P.Nonempty) (hR : R.Nonempty) :
    OppositeSemicubeHelly (prodCube P R) ↔ HarmonicEven P ∧ HarmonicEven R := by
  rw [osh_iff_harmonicEven]
  exact harmonicEven_prodCube P R hP hR

/-- The opposite-semicube Helly property of a product, phrased symmetrically in
terms of the same property of its factors. -/
theorem oppositeSemicubeHelly_prodCube_factors (P : Finset (α → Bool))
    (R : Finset (β → Bool)) (hP : P.Nonempty) (hR : R.Nonempty) :
    OppositeSemicubeHelly (prodCube P R)
      ↔ OppositeSemicubeHelly P ∧ OppositeSemicubeHelly R := by
  rw [oppositeSemicubeHelly_prodCube P R hP hR, osh_iff_harmonicEven,
    osh_iff_harmonicEven]

/-- **Catalog transfer.** The classical Helly-number-2 property for semicubes of a
hypercube (`Bridges.SemicubeHelly.semicube_helly2`) holds verbatim on a Cartesian
product of two hypercubes, because a product of hypercubes is again a hypercube on
the disjoint union of coordinate sets `α ⊕ β`. -/
theorem product_hypercube_semicube_helly2
    (F : Finset ((α ⊕ β) × Bool))
    (hpair : ∀ p ∈ F, ∀ q ∈ F, p ≠ q →
      (semicube (α ⊕ β) p.1 p.2 ∩ semicube (α ⊕ β) q.1 q.2).Nonempty) :
    (⋂ p ∈ F, (semicube (α ⊕ β) p.1 p.2 : Set (Finset (α ⊕ β)))).Nonempty :=
  semicube_helly2 F hpair

end OppositeSemicube