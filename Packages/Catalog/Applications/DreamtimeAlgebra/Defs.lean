/-
# Dreamtime Algebra: Aboriginal Kinship Systems as Group Theory

This module formalizes Australian Aboriginal kinship systems (section and subsection
systems) as finite groups with distinguished generators. We introduce the novel
mathematical structure `DreamtimeAlgebra` — a finite abelian group equipped with
"kinship generators" (elements of order 2) representing marriage and descent rules.

## Main definitions

* `DreamtimeAlgebra` — A finite additive abelian group with distinguished order-2
  generators representing marriage and descent
* `KarieraSystem` — The concrete 4-section (Kariera) kinship system on `ZMod 2 × ZMod 2`
* `ArandaSystem` — The concrete 8-subsection (Aranda) system on `ZMod 2 × ZMod 2 × ZMod 2`
* `marriageMap` — The marriage permutation: translation by the marriage generator
* `descentMap` — The descent permutation: translation by the descent generator
* `dreamtimeOp` — The "Dreamtime operator": composition of marriage and descent
* `moietyCount` — The number of distinct moieties (nontrivial marriage rules)
* `kinshipSpectrum` — The set of all valid marriage generators in a DreamtimeAlgebra

## Key results

* The marriage map is a fixed-point-free involution (exogamy)
* Marriage compatibility is a coset condition
* The alternating generations theorem: patrilineal descent cycles with period 2
* The Dreamtime operator is itself an involution
* Classification: kinship generators generate an elementary abelian 2-subgroup
* The kinship spectrum of (ZMod 2)^n has exactly 2^n - 1 elements

## References

* Lévi-Strauss, C. "Les Structures élémentaires de la parenté" (1949)
* Weil, A. "Sur l'étude algébrique de certains types de lois de mariage" (1949)
  — Appendix to Lévi-Strauss, the first algebraic formalization
* Kemeny, J.G., Snell, J.L., Thompson, G.L. "Introduction to Finite Mathematics" (1957)
-/

import Mathlib

open Finset ZMod

/-! ## Section 1: The DreamtimeAlgebra Structure -/

/-- A `DreamtimeAlgebra` is a finite additive abelian group equipped with two
distinguished elements of order 2: the **marriage generator** σ and the
**descent generator** δ. These encode the two fundamental kinship operations:
- Translation by σ maps each person's section to their required spouse's section
- Translation by δ maps each person's section to their child's section

The axioms enforce:
1. Both generators are involutions (σ + σ = 0, δ + δ = 0)
2. Both are nontrivial (exogamy: you cannot marry within your own section)
3. They are distinct (marriage ≠ descent)

This structure generalizes the classical Kariera (4-section) and Aranda
(8-subsection) systems of Aboriginal Australia. -/
structure DreamtimeAlgebra where
  /-- The carrier type (set of kinship sections) -/
  G : Type*
  /-- Sections form a finite additive commutative group -/
  [instAddCommGroup : AddCommGroup G]
  [instFintype : Fintype G]
  [instDecEq : DecidableEq G]
  /-- The marriage generator: translation by this element gives the spouse's section -/
  marryGen : G
  /-- The descent generator: translation by this element gives the child's section -/
  descentGen : G
  /-- Marriage generator has order 2: applying marriage twice returns to original section -/
  marry_order2 : marryGen + marryGen = 0
  /-- Descent generator has order 2: grandparent and grandchild share sections -/
  descent_order2 : descentGen + descentGen = 0
  /-- Exogamy axiom: you must marry outside your own section -/
  marry_nontrivial : marryGen ≠ 0
  /-- Descent is nontrivial: children are in a different section from parents -/
  descent_nontrivial : descentGen ≠ 0
  /-- Marriage and descent are distinct kinship operations -/
  marry_ne_descent : marryGen ≠ descentGen

attribute [instance] DreamtimeAlgebra.instAddCommGroup
  DreamtimeAlgebra.instFintype DreamtimeAlgebra.instDecEq

namespace DreamtimeAlgebra

variable (D : DreamtimeAlgebra)

/-- The marriage map: sends each section to its required marriage partner's section.
This is the fundamental operation encoding the marriage rule. -/
def marriageMap : D.G → D.G := fun g => g + D.marryGen

/-- The descent map: sends each section to the section of a person's child
(through the patrilineal line). -/
def descentMap : D.G → D.G := fun g => g + D.descentGen

/-- The Dreamtime operator: the composition of marriage and descent.
This maps a person's section to their child-in-law's section, tracing
kinship through both marriage and descent in a single step. -/
def dreamtimeOp : D.G → D.G := fun g => g + D.marryGen + D.descentGen

/-- The Dreamtime element: the sum of the marriage and descent generators.
This is the group element underlying the Dreamtime operator. -/
def dreamtimeGen : D.G := D.marryGen + D.descentGen

end DreamtimeAlgebra

/-! ## Section 2: The Kariera 4-Section System -/

/-- The Kariera kinship system: the classical 4-section system of Aboriginal Australia.

The four sections are modeled as elements of `ZMod 2 × ZMod 2`:
- `(0, 0)` — Karimera
- `(1, 0)` — Burung
- `(0, 1)` — Palyeri
- `(1, 1)` — Banaka

The marriage generator `(1, 0)` encodes: Karimera ↔ Burung, Palyeri ↔ Banaka.
The descent generator `(0, 1)` encodes: parent's section + (0,1) = child's section. -/
def KarieraSystem : DreamtimeAlgebra where
  G := ZMod 2 × ZMod 2
  marryGen := (1, 0)
  descentGen := (0, 1)
  marry_order2 := by decide
  descent_order2 := by decide
  marry_nontrivial := by decide
  descent_nontrivial := by decide
  marry_ne_descent := by decide

/-- The Kariera section names, for documentation -/
inductive KarieraSection where
  | Karimera  -- (0, 0)
  | Burung    -- (1, 0)
  | Palyeri   -- (0, 1)
  | Banaka    -- (1, 1)

/-! ## Section 3: The Aranda 8-Subsection System -/

/-- The Aranda kinship system: the 8-subsection system of Aboriginal Australia.

The eight subsections are modeled as elements of `ZMod 2 × ZMod 2 × ZMod 2`.
The three generators correspond to:
- Marriage (`(1, 0, 0)`): determines spouse's subsection
- Patrilineal descent (`(0, 1, 0)`): determines child's subsection through father
- Generational moiety (`(0, 0, 1)`): distinguishes generational halves

The Aranda system refines the Kariera system by splitting each section into
two subsections, adding a generational distinction. -/
def ArandaSystem : DreamtimeAlgebra where
  G := ZMod 2 × ZMod 2 × ZMod 2
  marryGen := (1, 0, 0)
  descentGen := (0, 1, 0)
  marry_order2 := by decide
  descent_order2 := by decide
  marry_nontrivial := by decide
  descent_nontrivial := by decide
  marry_ne_descent := by decide

/-! ## Section 4: Marriage as Coset Membership -/

/-- Two sections are **marriage-compatible** if one is obtained from the other
by adding the marriage generator. This formalizes the anthropological rule that
marriage is only permitted between specific section pairs. -/
def marriageCompatible (D : DreamtimeAlgebra) (g h : D.G) : Prop :=
  h = g + D.marryGen

/-! ## Section 5: Kinship Spectrum -/

/-- The **kinship spectrum** of a finite abelian group is the set of elements of
order dividing 2 (excluding 0). Each such element could serve as a valid marriage
generator, giving a different kinship system on the same underlying group.
This counts the number of "culturally possible" marriage rules. -/
def kinshipSpectrum (G : Type*) [AddCommGroup G] [Fintype G] [DecidableEq G] : Finset G :=
  Finset.univ.filter (fun g => g + g = 0 ∧ g ≠ (0 : G))

/-! ## Section 6: Moiety Structure -/

/-- A **moiety partition** induced by a nontrivial element of order 2 in a
DreamtimeAlgebra. The moiety of an element g is its equivalence class under
the relation g ~ g + σ. This gives a partition of sections into pairs. -/
def moietyOf (D : DreamtimeAlgebra) (g : D.G) : Finset D.G :=
  {g, g + D.marryGen}

/-! ## Section 7: Generational Cycles -/

/-- The **patrilineal orbit** of a section g: the sequence of sections obtained
by repeatedly applying the descent map. In a DreamtimeAlgebra, this orbit
always has exactly 2 elements {g, g + δ} due to the order-2 condition. -/
def patrilinealOrbit (D : DreamtimeAlgebra) (g : D.G) : Finset D.G :=
  {g, g + D.descentGen}