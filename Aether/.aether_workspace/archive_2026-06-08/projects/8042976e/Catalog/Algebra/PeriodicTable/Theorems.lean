import Mathlib

/-!
# The Periodic Table of Finite Groups: Chemistry Meets Algebra

We introduce a chemical analogy for classifying finite groups, defining "chemical series"
that organize groups by structural properties, analogous to how Mendeleev's periodic table
organizes elements by chemical behavior.

## Main Definitions

* `GroupChemicalSeries` — An inductive type classifying finite groups into chemical families.
* `derivedLength` — The derived length (solvability degree) of a finite group.
* `groupAtomicNumber` — The "atomic number" of a group: its order.
* `GroupIsotope` — Two groups are "isotopes" if they share the same derived length.

## Chemical Series Classification

| Chemical Series   | Group Family                    | Key Property           |
|-------------------|---------------------------------|------------------------|
| Noble Gas         | Cyclic groups                   | Abelian, simple gen.   |
| Alkaline Earth    | Abelian non-cyclic              | Commutative, decomp.   |
| Compound          | Solvable, non-abelian           | Extensions             |
| Radioactive       | Non-solvable groups             | Complex structure      |

## Main Results

* `nobleGas_is_solvable` — Cyclic groups (noble gases) are solvable.
* `derivedSeries_one_eq_bot_of_comm` — Abelian groups have trivial derived series at step 1.
* `simple_solvable_iff_commutative` — A simple group is solvable iff commutative.
* `nonabelian_simple_not_solvable` — Non-abelian simple groups are not solvable.
* `abelian_derivedSeries_stabilizes` — The derived series of abelian groups stabilizes at step 1.
* `atomic_number_product` — Order is multiplicative under products.
* `euler_totient_units_order` — Euler's totient counts units in ℤ/nℤ (cross-domain bridge).
* `burnside_pq_conjecture` — Conjecture: groups of order p^a q^b are solvable.
-/

open scoped Classical
open Fintype Subgroup

/-! ## Part I: Definitions — The Chemical Taxonomy -/

/-- Chemical series classification for finite groups, analogous to Mendeleev's
    periodic table columns. Each series captures a structural archetype. -/
inductive GroupChemicalSeries where
  /-- Cyclic groups: stable, simple structure (like noble gases) -/
  | nobleGas
  /-- Abelian non-cyclic groups: decomposable, moderate reactivity -/
  | alkalineEarth
  /-- Solvable non-abelian groups: compound structure, extensions -/
  | compound
  /-- Non-solvable groups: complex, "radioactive" behavior -/
  | radioactive
  deriving DecidableEq, Repr

/-- The derived length of a solvable group G is the smallest n such that
    the n-th derived subgroup is trivial. -/
noncomputable def derivedLength (G : Type*) [Group G] [IsSolvable G] : ℕ :=
  Nat.find (IsSolvable.solvable (G := G))

/-- The atomic number of a finite group is its cardinality (order). -/
noncomputable def groupAtomicNumber (G : Type*) [Fintype G] : ℕ := Fintype.card G

/-- Two groups are `GroupIsotopes` if they have the same derived length. -/
def GroupIsotope (G H : Type*) [Group G] [Group H] [IsSolvable G] [IsSolvable H] : Prop :=
  derivedLength G = derivedLength H

/-- A group has "noble gas configuration" if it is cyclic. -/
def hasNobleGasConfig (G : Type*) [Group G] : Prop := IsCyclic G

/-- A group is "chemically inert" if it is both abelian and simple. -/
def isChemicallyInert (G : Type*) [Group G] : Prop :=
  (∀ a b : G, a * b = b * a) ∧ IsSimpleGroup G

/-- The "reactivity" of a solvable group is its derived length. -/
noncomputable def groupReactivity (G : Type*) [Group G] [IsSolvable G] : ℕ :=
  derivedLength G

/-! ## Part II: Noble Gas Stability — Cyclic Groups are Solvable -/

/-
**Noble Gas Theorem**: Every cyclic group is solvable. Cyclic groups are abelian,
    hence their commutator subgroups are trivial, making the derived series terminate.
-/
theorem nobleGas_is_solvable (G : Type*) [Group G] [IsCyclic G] : IsSolvable G := by
  grind +suggestions

/-! ## Part III: Abelian Derived Series -/

/-
**Abelian Derived Length Bound**: For any commutative group, the first derived
    subgroup is already trivial. The commutator [a,b] = a*b*a⁻¹*b⁻¹ = 1 for all a,b.
-/
theorem derivedSeries_one_eq_bot_of_comm (G : Type*) [Group G]
    (hcomm : ∀ a b : G, a * b = b * a) : derivedSeries G 1 = ⊥ := by
  simp +decide [derivedSeries];
  simp +decide [Subgroup.commutator_eq_bot_iff_le_centralizer];
  exact eq_top_iff.mpr fun x _ => Subgroup.mem_center_iff.mpr fun y => hcomm y x

/-- **Transition Metal Theorem**: A simple group is solvable if and only if it is
    commutative. Non-abelian simple groups are the "transition metals" — never solvable. -/
theorem simple_solvable_iff_commutative (G : Type*) [Group G] [IsSimpleGroup G] :
    (∀ a b : G, a * b = b * a) ↔ IsSolvable G :=
  IsSimpleGroup.comm_iff_isSolvable

/-! ## Part IV: Chemical Compound Stability -/

/-- **Chemical Compound Theorem**: Products of solvable groups are solvable. -/
theorem solvability_preserved_by_product (G H : Type*) [Group G] [Group H]
    [IsSolvable G] [IsSolvable H] : IsSolvable (G × H) :=
  solvable_prod

/-- **Prime Element Theorem**: Every group of prime order is cyclic. -/
theorem prime_order_is_nobleGas (G : Type*) [Group G] {p : ℕ} [Fact (Nat.Prime p)]
    (hcard : Nat.card G = p) : IsCyclic G :=
  isCyclic_of_prime_card hcard

/-- **Solvability is Hereditary**: Subgroups of solvable groups are solvable. -/
theorem solvability_hereditary (G : Type*) [Group G] [IsSolvable G]
    (H : Subgroup G) : IsSolvable H := inferInstance

/-! ## Part V: Atomic Number Arithmetic -/

/-
**Conservation of Mass**: The order of a product group equals the product of orders.
-/
theorem atomic_number_product (G H : Type*) [Fintype G] [Fintype H] :
    groupAtomicNumber (G × H) = groupAtomicNumber G * groupAtomicNumber H := by
  convert Fintype.card_prod G H

/-! ## Part VI: Derived Length Theory -/

/-
The derived length of the trivial group is 0.
-/
theorem derivedLength_trivial : derivedLength Unit = 0 := by
  refine' le_antisymm ( Nat.find_le _ ) ( Nat.zero_le _ );
  simp +decide [ eq_iff_true_of_subsingleton ]

/-- **Isotope Reflexivity**: Every solvable group is an isotope of itself. -/
theorem groupIsotope_refl (G : Type*) [Group G] [IsSolvable G] :
    GroupIsotope G G := rfl

/-- **Isotope Symmetry**: The isotope relation is symmetric. -/
theorem groupIsotope_symm {G H : Type*} [Group G] [Group H]
    [IsSolvable G] [IsSolvable H] (h : GroupIsotope G H) : GroupIsotope H G :=
  h.symm

/-- **Isotope Transitivity**: The isotope relation is transitive. -/
theorem groupIsotope_trans {G H K : Type*} [Group G] [Group H] [Group K]
    [IsSolvable G] [IsSolvable H] [IsSolvable K]
    (h1 : GroupIsotope G H) (h2 : GroupIsotope H K) : GroupIsotope G K :=
  h1.trans h2

/-! ## Part VII: Cross-Domain Bridge — Number Theory meets Group Theory -/

/-
**Euler-Group Bridge**: The order of the unit group (ℤ/nℤ)ˣ equals Euler's totient φ(n).
    This connects number theory (counting coprime residues) to algebra (unit groups).
-/
theorem euler_totient_units_order (n : ℕ) [NeZero n] :
    Fintype.card (ZMod n)ˣ = Nat.totient n := by
  aesop

/-- **Solvability Quotient Theorem**: Quotients of solvable groups are solvable. -/
theorem solvability_preserved_quotient (G : Type*) [Group G] [IsSolvable G]
    (N : Subgroup G) [N.Normal] : IsSolvable (G ⧸ N) :=
  solvable_quotient_of_solvable N

/-! ## Part VIII: Derived Series Monotonicity -/

/-- **Derived Series Decay**: The derived series is antitone. -/
theorem derived_series_decay (G : Type*) [Group G] (m n : ℕ) (h : m ≤ n) :
    derivedSeries G n ≤ derivedSeries G m :=
  derivedSeries_antitone G h

/-
**Radioactive Instability**: A non-abelian simple group is not solvable.
-/
theorem nonabelian_simple_not_solvable (G : Type*) [Group G] [IsSimpleGroup G]
    (hnonab : ∃ a b : G, a * b ≠ b * a) : ¬ IsSolvable G := by
  obtain ⟨ a, b, h ⟩ := hnonab;
  contrapose! h;
  convert simple_solvable_iff_commutative G |>.2 h a b using 1

/-
The derived series of a commutative group stabilizes at step 1.
-/
theorem abelian_derivedSeries_stabilizes (G : Type*) [Group G]
    (hcomm : ∀ a b : G, a * b = b * a) (n : ℕ) (hn : 1 ≤ n) :
    derivedSeries G n = ⊥ := by
  induction hn <;> simp_all +decide [ derivedSeries ];
  simp +decide [Subgroup.commutator_eq_bot_iff_le_centralizer];
  exact eq_top_iff.mpr fun x _ => Subgroup.mem_center_iff.mpr fun y => by simp +decide [hcomm];

/-! ## Part IX: Conjecture — Burnside's pᵃqᵇ Theorem -/

/-- **Conjecture (Burnside's pᵃqᵇ Theorem)**: Every group whose order is p^a * q^b
    (for primes p, q) is solvable. This is a deep theorem (Burnside 1904) whose
    formal proof requires character theory not yet fully available in Mathlib.

    **Testable prediction**: All groups of order 12, 36, 200, etc. are solvable.
    This can be verified computationally for small orders. -/
theorem burnside_pq_conjecture (G : Type*) [Group G] [Fintype G]
    {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    {a b : ℕ} (hord : Fintype.card G = p ^ a * q ^ b) : IsSolvable G := by
  sorry