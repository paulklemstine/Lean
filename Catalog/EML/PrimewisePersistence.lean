/-
  # Primewise Persistent Homology for Arithmetic Manifold Separation

  This module formalizes the mathematical framework for using prime-indexed
  persistence barcodes to distinguish isospectral but nonisometric arithmetic
  manifolds.
-/

import Mathlib

open Finset Nat BigOperators

/-! ## Part 1: Persistence Barcodes -/

/-- A barcode interval [birth, death) in a persistence diagram. -/
structure BarcodeInterval where
  birth : ℕ
  death : ℕ
  birth_lt_death : birth < death

/-- A persistence barcode is a finite multiset of intervals. -/
structure PersistenceBarcode where
  intervals : List BarcodeInterval

/-- Total persistence (sum of lifetimes) of a barcode. -/
def PersistenceBarcode.totalPersistence (B : PersistenceBarcode) : ℕ :=
  (B.intervals.map (fun iv => iv.death - iv.birth)).sum

/-- Number of intervals in a barcode. -/
def PersistenceBarcode.size (B : PersistenceBarcode) : ℕ :=
  B.intervals.length

/-- The Betti number at filtration index t: count of intervals alive at t. -/
def PersistenceBarcode.bettiAt (B : PersistenceBarcode) (t : ℕ) : ℕ :=
  (B.intervals.filter (fun iv => iv.birth ≤ t ∧ t < iv.death)).length

/-! ## Part 2: Primewise Invariant System -/

/-- A primewise invariant assigns a persistence barcode to each prime.
    This is the novel mathematical structure: a functor from the category
    of primes to persistence data. -/
structure PrimewiseInvariant where
  /-- The barcode assigned at each prime p -/
  barcode : ∀ (p : ℕ), Nat.Prime p → PersistenceBarcode

/-- Two primewise invariants agree at prime p if their barcodes have
    equal total persistence. -/
def PrimewiseInvariant.agreeAt (I₁ I₂ : PrimewiseInvariant) (p : ℕ) (hp : Nat.Prime p) : Prop :=
  (I₁.barcode p hp).totalPersistence = (I₂.barcode p hp).totalPersistence

/-- The set of primes where two primewise invariants disagree. -/
def separatingPrimeSet (I₁ I₂ : PrimewiseInvariant) : Set ℕ :=
  {p | ∃ (hp : Nat.Prime p), ¬ I₁.agreeAt I₂ p hp}

/-- The set of all primes. -/
def primeSet : Set ℕ := {p | Nat.Prime p}

/-! ## Part 3: Sunada Triples

A Sunada triple (G, H₁, H₂) consists of a finite group G with subgroups
H₁, H₂ that are "almost conjugate" — for each conjugacy class C of G,
|C ∩ H₁| = |C ∩ H₂|. This produces isospectral manifolds. -/

/-- A Sunada triple: two subsets of a finite group with matching
    conjugacy class intersection counts. -/
structure SunadaTriple (G : Type*) [DecidableEq G] [Fintype G] [Group G] where
  H₁ : Finset G
  H₂ : Finset G
  H₁_nonempty : H₁.Nonempty
  H₂_nonempty : H₂.Nonempty
  same_card : H₁.card = H₂.card
  /-- Almost conjugacy condition -/
  almost_conjugate : ∀ g : G, (H₁.filter (fun h => ∃ x : G, x * h * x⁻¹ = g)).card =
                               (H₂.filter (fun h => ∃ x : G, x * h * x⁻¹ = g)).card

/-! ## Part 4: Prime counting -/

/-- Count of primes up to n in a given set S. -/
noncomputable def primeCountIn (S : Set ℕ) [DecidablePred (· ∈ S)] (n : ℕ) : ℕ :=
  (Finset.range (n + 1)).card.min (
    (Finset.filter (fun p => p ∈ S ∧ Nat.Prime p) (Finset.range (n + 1))).card
  )

/-- Count of all primes up to n. -/
noncomputable def primeCount (n : ℕ) : ℕ :=
  (Finset.filter (fun p => Nat.Prime p) (Finset.range (n + 1))).card

/-! ## Part 5: Core Theorems -/

/-- The total persistence of an empty barcode is zero. -/
theorem empty_barcode_zero_persistence :
    PersistenceBarcode.totalPersistence ⟨[]⟩ = 0 := by
  simp [PersistenceBarcode.totalPersistence]

/-- The Betti number of an empty barcode is zero everywhere. -/
theorem empty_barcode_zero_betti (t : ℕ) :
    PersistenceBarcode.bettiAt ⟨[]⟩ t = 0 := by
  simp [PersistenceBarcode.bettiAt]

/-
For a single-interval barcode, the Betti number at the birth index is 1.
-/
theorem single_interval_betti_at_birth (iv : BarcodeInterval) :
    PersistenceBarcode.bettiAt ⟨[iv]⟩ iv.birth = 1 := by
  unfold PersistenceBarcode.bettiAt;
  simp +decide [iv.birth_lt_death]

/-
The Betti number at any index ≥ death is 0 for a single-interval barcode.
-/
theorem single_interval_betti_after_death (iv : BarcodeInterval) (t : ℕ)
    (ht : iv.death ≤ t) :
    PersistenceBarcode.bettiAt ⟨[iv]⟩ t = 0 := by
  unfold PersistenceBarcode.bettiAt; aesop;

/-
The Betti number before birth is 0 for a single-interval barcode.
-/
theorem single_interval_betti_before_birth (iv : BarcodeInterval) (t : ℕ)
    (ht : t < iv.birth) :
    PersistenceBarcode.bettiAt ⟨[iv]⟩ t = 0 := by
  -- By definition of bettiAt, we need to show that the length of the filtered list is zero.
  simp [PersistenceBarcode.bettiAt, ht]

/-
**Stability bound**: For any barcode, the Betti number is bounded
    by the number of intervals: β_t(B) ≤ |B| for all t.
-/
theorem betti_le_size (B : PersistenceBarcode) (t : ℕ) :
    B.bettiAt t ≤ B.size := by
  exact List.length_filter_le _ _

/-- **Sunada equal sizes**: Sunada triples have equal subgroup sizes. -/
theorem sunada_equal_sizes {G : Type*} [DecidableEq G] [Fintype G] [Group G]
    (S : SunadaTriple G) : S.H₁.card = S.H₂.card :=
  S.same_card

/-
**Sunada identity (Deep)**: In a Sunada triple, the identity element
    has equal multiplicity in both subgroups. The almost-conjugacy
    condition for g = 1 gives: elements h with xhx⁻¹ = 1 are exactly
    h = 1, so the filter counts agree.
-/
theorem sunada_identity_count {G : Type*} [DecidableEq G] [Fintype G] [Group G]
    (S : SunadaTriple G) :
    (S.H₁.filter (fun h => h = 1)).card = (S.H₂.filter (fun h => h = 1)).card := by
  convert S.almost_conjugate 1 using 1;
  · congr 1 with x ; aesop;
  · simp +decide [ Finset.filter_eq', mul_inv_eq_one ]

/-
**Agreement implies empty separation**: If two primewise invariants
    agree at all primes, then their separating prime set is empty.
-/
theorem agree_everywhere_empty_separation (I₁ I₂ : PrimewiseInvariant)
    (h : ∀ (p : ℕ) (hp : Nat.Prime p), I₁.agreeAt I₂ p hp) :
    separatingPrimeSet I₁ I₂ = ∅ := by
  exact Set.eq_empty_of_forall_notMem fun p hp => hp.choose_spec <| h p hp.choose

/-
The separating prime set is a subset of the primes.
-/
theorem separation_subset_primes (I₁ I₂ : PrimewiseInvariant) :
    separatingPrimeSet I₁ I₂ ⊆ primeSet := by
  intro p hp
  obtain ⟨hp_prime, hp_disagree⟩ := hp
  exact hp_prime

/-
**Betti additivity (Deep)**: Betti numbers are additive under
    barcode concatenation. Proved by induction on the interval list.
-/
theorem betti_append (B₁ B₂ : PersistenceBarcode) (t : ℕ) :
    PersistenceBarcode.bettiAt ⟨B₁.intervals ++ B₂.intervals⟩ t =
    B₁.bettiAt t + B₂.bettiAt t := by
  unfold PersistenceBarcode.bettiAt; aesop;

/-
**Total persistence additivity (Deep)**: Total persistence is additive
    under barcode concatenation.
-/
theorem totalPersistence_append (B₁ B₂ : PersistenceBarcode) :
    PersistenceBarcode.totalPersistence ⟨B₁.intervals ++ B₂.intervals⟩ =
    B₁.totalPersistence + B₂.totalPersistence := by
  unfold PersistenceBarcode.totalPersistence; simp +decide

/-
**Nonempty barcodes have positive Betti (Deep)**: For any barcode with
    at least one interval, there exists a filtration index where the Betti
    number is positive. Uses the birth of the first interval.
-/
theorem nonempty_barcode_has_positive_betti (B : PersistenceBarcode)
    (hne : B.intervals ≠ []) :
    ∃ t, 0 < B.bettiAt t := by
  induction' h : B.intervals with x xs ih;
  · contradiction;
  · use x.birth; simp_all +decide [ PersistenceBarcode.bettiAt ] ;
    exact Or.inl x.birth_lt_death

/-
**Prime count monotonicity (Deep)**: The number of primes up to n
    is monotone in n.
-/
theorem primeCount_mono : Monotone primeCount := by
  exact fun a b hab => Finset.card_le_card ( Finset.filter_subset_filter _ <| Finset.range_mono <| by linarith )

/-
**Single interval total persistence**: The total persistence of a
    single-interval barcode equals death - birth.
-/
theorem single_interval_persistence (iv : BarcodeInterval) :
    PersistenceBarcode.totalPersistence ⟨[iv]⟩ = iv.death - iv.birth := by
  -- By definition of total persistence, we have:
  simp [PersistenceBarcode.totalPersistence]

/-- **Size of singleton barcode** -/
theorem single_interval_size (iv : BarcodeInterval) :
    PersistenceBarcode.size ⟨[iv]⟩ = 1 := by
  simp [PersistenceBarcode.size]

/-! ## Part 6: Conjecture with Testable Prediction -/

/-- **Conjecture (Primewise Persistence Separation)**:
    For any two distinct primewise invariants (i.e., disagreeing on at least
    one prime), the separating prime set is infinite.

    Testable prediction: For the Sunada pair from S₈ (the smallest known
    example), compute mod-p persistence for p ∈ {2,3,5,7,11,13}. If all
    six agree, the conjecture is refuted for that construction.

    This is falsifiable: a single pair of distinct invariants with only
    finitely many separating primes would disprove it. -/
def primewise_separation_conjecture : Prop :=
  ∀ (I₁ I₂ : PrimewiseInvariant),
    (∃ (p : ℕ) (hp : Nat.Prime p), ¬ I₁.agreeAt I₂ p hp) →
    Set.Infinite (separatingPrimeSet I₁ I₂)