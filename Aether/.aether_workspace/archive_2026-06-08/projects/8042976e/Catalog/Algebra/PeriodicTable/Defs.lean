import Mathlib

/-!
# The Periodic Table of Finite Groups — Definitions and Core Framework

We formalize a chemical-algebraic classification of finite groups, defining
structural invariants ("valence", "reactivity", "chemical fingerprint") that
organize groups into families analogous to Mendeleev's periodic table.

## Main Definitions

* `GroupChemicalSeries` — Classification of finite groups into chemical families
* `groupValence` — The "valence" of a group: number of atoms in its center
* `nilpotentReactivityIndex` — For nilpotent groups, measures distance from abelianity
* `SolvabilitySpectrum` — Captures the full derived series structure as a fingerprint
* `GroupPeriodicRow` — A row in the periodic table, indexed by order

## Key Insight

The periodic table of elements works because atomic structure (protons, electrons,
shells) determines chemical properties. For finite groups, the analogous structural
decomposition is:
- **Atomic number** = group order
- **Electron shells** = derived series / lower central series
- **Valence electrons** = elements of the center (determine "bonding" = extensions)
- **Noble gas configuration** = cyclic (completely "filled shells")
- **Isotopes** = groups with same composition factor multiset but different extensions

The Jordan-Hölder theorem is the group-theoretic analogue of the law of definite
proportions: the "atoms" (composition factors) of a group are uniquely determined.
-/

open scoped Classical
open Fintype Subgroup

/-! ## Chemical Series Classification -/

/-- Chemical series for finite groups. Each series captures a structural archetype,
    classified by the group's position in the solvability/nilpotency hierarchy. -/
inductive GroupChemSeries where
  /-- Trivial group: the "vacuum" — no structure at all -/
  | vacuum
  /-- Cyclic groups of prime order: fundamental "elements" -/
  | primeElement
  /-- Cyclic groups of composite order: "noble gases" — stable, fully determined -/
  | nobleGas
  /-- Abelian non-cyclic: "alkaline earth" — decomposable into prime elements -/
  | alkalineEarth
  /-- Nilpotent non-abelian: "alkali metals" — reactive, p-group decomposable -/
  | alkaliMetal
  /-- Solvable non-nilpotent: "compounds" — built from extensions -/
  | compound
  /-- Non-solvable: "radioactive" — complex internal dynamics -/
  | radioactive
  deriving DecidableEq, Repr

/-- The center-valence of a finite group: the cardinality of its center.
    Analogous to valence electrons — the center determines how a group
    can participate in extensions (semi-direct products, central extensions). -/
noncomputable def centerValence (G : Type*) [Group G] [Fintype G] : ℕ :=
  Fintype.card (Subgroup.center G)

/-- The defect of abelianity: ratio of group order to center size.
    For abelian groups this is 1. Measures how "non-commutative" a group is.
    Analogous to electronegativity — tendency to "react" in extensions. -/
noncomputable def abelianDefect (G : Type*) [Group G] [Fintype G] : ℕ :=
  Fintype.card G / centerValence G

/-- The reactivity index for nilpotent groups: the nilpotency class.
    Class 0 = trivial (vacuum), class 1 = abelian (noble gas/alkaline earth),
    class k > 1 = increasingly "reactive" (alkali metals). -/
noncomputable def nilpotentReactivity (G : Type*) [Group G] [Group.IsNilpotent G] : ℕ :=
  Group.nilpotencyClass G

/-- A solvability spectrum captures the full derived series structure.
    Each entry records the index [G^(i) : G^(i+1)] of consecutive derived subgroups.
    This is the "electron configuration" of the group. -/
noncomputable def solvabilitySpectrum (G : Type*) [Group G] [Fintype G] (n : ℕ) : ℕ :=
  Fintype.card (derivedSeries G n)

/-- The commutator width: how many commutators are needed to generate [G,G].
    Analogous to bond order in chemistry. -/
noncomputable def commutatorSubgroupOrder (G : Type*) [Group G] [Fintype G] : ℕ :=
  Fintype.card (⁅(⊤ : Subgroup G), (⊤ : Subgroup G)⁆ : Subgroup G)

/-- The abelianization order: |G/[G,G]|.
    For abelian groups this equals |G|. Measures the "stable core" after
    stripping away non-commutativity. -/
noncomputable def abelianizationOrder (G : Type*) [Group G] [Fintype G] : ℕ :=
  Fintype.card G / commutatorSubgroupOrder G

/-! ## Periodic Table Structure -/

/-- A row in the periodic table is indexed by a natural number (the group order).
    We record key structural invariants for classification. -/
structure GroupPeriodicEntry (G : Type*) [Group G] [Fintype G] where
  /-- The atomic number: group order -/
  atomicNumber : ℕ := Fintype.card G
  /-- Center valence -/
  valence : ℕ := centerValence G
  /-- Abelian defect -/
  defect : ℕ := abelianDefect G
  /-- Whether the group is solvable -/
  isSolvable : Prop := IsSolvable G
  /-- Whether the group is nilpotent -/
  isNilpotent : Prop := Group.IsNilpotent G

/-- Two groups are in the same "column" of the periodic table if they have
    the same center valence and solvability status. This is a coarser
    invariant than composition factors but computationally tractable. -/
def sameColumn (G H : Type*) [Group G] [Group H] [Fintype G] [Fintype H] : Prop :=
  centerValence G = centerValence H ∧
  (IsSolvable G ↔ IsSolvable H) ∧
  (Group.IsNilpotent G ↔ Group.IsNilpotent H)

/-- Two groups are "isotopes" if they share the same solvability spectrum
    up to a given depth. -/
def areIsotopes (G H : Type*) [Group G] [Group H] [Fintype G] [Fintype H] (depth : ℕ) : Prop :=
  ∀ i ≤ depth, solvabilitySpectrum G i = solvabilitySpectrum H i