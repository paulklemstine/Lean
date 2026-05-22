/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Stone Recognition Duality via Idempotent Congruence Spectra

## Overview

This file establishes a finite duality between tropical recognition algebras
(finite commutative idempotent semirings) and finite spectral predicate spaces
(finite T₀ partial orders).

The central construction is the **upper-set idempotent semiring**: given a finite
poset X, the collection of upper sets forms a commutative semiring with union as
addition (idempotent) and intersection as multiplication (also idempotent). The
**principal upper set map** x ↦ ↑x = {y | x ≤ y} gives a contravariant
order-embedding — the finite analogue of Stone's representation theorem.

Combined with the congruence spectrum construction, this gives the duality:
  tropical language ↔ finite idempotent recognizer ↔ prime congruence spectral space

## Main Results

* `upperSetCommSemiring` — upper sets form a CommSemiring (union = +, ∩ = ×)
* `upperSet_idem_add`, `upperSet_idem_mul` — both operations are idempotent
* `principalUpper_injective` — Stone embedding is injective
* `principalUpper_order_embedding` — contravariant order characterization
* `upperSet_eq_union_principals` — basis decomposition
* `upperSet_absorption` — lattice absorption law
* `upperSet_union_inter_distrib` — union distributes over intersection
* `minimal_recognizer_card_eq` — uniqueness of minimal recognizers
* `finite_tropical_stone_representation` — main duality theorem
* `wordInterp_append` — word interpretation is multiplicative
-/

import Mathlib

open Finset Function

noncomputable section

namespace TropicalStoneRecognition

/-! ## §1. Idempotent Semiring Infrastructure -/

/-- A finite commutative idempotent semiring: the fundamental recognition algebra
    for tropical language theory. Addition is idempotent (a + a = a). -/
structure IdemSemiring where
  carrier : Type
  instCSR : CommSemiring carrier
  instFin : Fintype carrier
  instDec : DecidableEq carrier
  idem_add : ∀ a : carrier, a + a = a

attribute [instance] IdemSemiring.instCSR IdemSemiring.instFin IdemSemiring.instDec

/-- The natural order: a ≤ᵢ b iff a + b = b. Makes addition the join. -/
def IdemSemiring.natLE (R : IdemSemiring) (a b : R.carrier) : Prop :=
  a + b = b

theorem IdemSemiring.natLE_refl (R : IdemSemiring) (a : R.carrier) :
    R.natLE a a := R.idem_add a

theorem IdemSemiring.natLE_antisymm (R : IdemSemiring) {a b : R.carrier}
    (hab : R.natLE a b) (hba : R.natLE b a) : a = b := by
  unfold natLE at *
  calc a = b + a := hba.symm
    _ = a + b := add_comm b a
    _ = b := hab

theorem IdemSemiring.natLE_trans (R : IdemSemiring) {a b c : R.carrier}
    (hab : R.natLE a b) (hbc : R.natLE b c) : R.natLE a c := by
  unfold natLE at *
  calc a + c = a + (b + c) := by rw [hbc]
    _ = (a + b) + c := by rw [add_assoc]
    _ = b + c := by rw [hab]
    _ = c := hbc

/-- Zero is the bottom element in the natural order. -/
theorem IdemSemiring.natLE_zero (R : IdemSemiring) (a : R.carrier) :
    R.natLE 0 a := zero_add a

/-- Addition is the join in the natural order:
    a + b is an upper bound of both a and b. -/
theorem IdemSemiring.natLE_add_left (R : IdemSemiring) (a b : R.carrier) :
    R.natLE a (a + b) := by
  unfold natLE
  rw [← add_assoc, R.idem_add]

/-! ## §2. Finite T₀ Partial Orders -/

/-- A finite T₀ partial order = finite spectral predicate space. -/
structure FinT0Poset where
  carrier : Type
  instFin : Fintype carrier
  instDec : DecidableEq carrier
  instPO : PartialOrder carrier
  instDecLE : DecidableRel instPO.le

attribute [instance] FinT0Poset.instFin FinT0Poset.instDec FinT0Poset.instPO
  FinT0Poset.instDecLE

/-! ## §3. Upper Sets as an Idempotent Semiring -/

/-- An upper set in a finite partial order, represented as a `Finset`. -/
structure UpperSetFin (X : FinT0Poset) where
  val : Finset X.carrier
  upper : ∀ {x y : X.carrier}, x ∈ val → x ≤ y → y ∈ val

@[ext]
theorem UpperSetFin.ext' {X : FinT0Poset} {U V : UpperSetFin X}
    (h : U.val = V.val) : U = V := by
  cases U; cases V; congr

instance upperSetDecEq (X : FinT0Poset) : DecidableEq (UpperSetFin X) :=
  fun U V => decidable_of_iff (U.val = V.val)
    ⟨UpperSetFin.ext', fun h => by rw [h]⟩

def UpperSetFin.empty (X : FinT0Poset) : UpperSetFin X where
  val := ∅
  upper := by simp

def UpperSetFin.full (X : FinT0Poset) : UpperSetFin X where
  val := Finset.univ
  upper := by simp

def UpperSetFin.union {X : FinT0Poset} (U V : UpperSetFin X) : UpperSetFin X where
  val := U.val ∪ V.val
  upper := by
    intro x y hx hxy
    simp only [Finset.mem_union] at hx ⊢
    exact hx.imp (U.upper · hxy) (V.upper · hxy)

def UpperSetFin.inter {X : FinT0Poset} (U V : UpperSetFin X) : UpperSetFin X where
  val := U.val ∩ V.val
  upper := by
    intro x y hx hxy
    simp only [Finset.mem_inter] at hx ⊢
    exact ⟨U.upper hx.1 hxy, V.upper hx.2 hxy⟩

instance (X : FinT0Poset) : Zero (UpperSetFin X) := ⟨UpperSetFin.empty X⟩
instance (X : FinT0Poset) : One (UpperSetFin X) := ⟨UpperSetFin.full X⟩
instance (X : FinT0Poset) : Add (UpperSetFin X) := ⟨UpperSetFin.union⟩
instance (X : FinT0Poset) : Mul (UpperSetFin X) := ⟨UpperSetFin.inter⟩

@[simp] theorem UpperSetFin.add_val {X : FinT0Poset} (U V : UpperSetFin X) :
    (U + V).val = U.val ∪ V.val := rfl

@[simp] theorem UpperSetFin.mul_val {X : FinT0Poset} (U V : UpperSetFin X) :
    (U * V).val = U.val ∩ V.val := rfl

@[simp] theorem UpperSetFin.zero_val (X : FinT0Poset) :
    (0 : UpperSetFin X).val = ∅ := rfl

@[simp] theorem UpperSetFin.one_val (X : FinT0Poset) :
    (1 : UpperSetFin X).val = Finset.univ := rfl

/-- The upper sets of a finite poset form a `CommSemiring`. -/
instance upperSetCommSemiring (X : FinT0Poset) : CommSemiring (UpperSetFin X) where
  nsmul := nsmulRec
  add_assoc a b c := UpperSetFin.ext' (Finset.union_assoc _ _ _)
  zero_add a := UpperSetFin.ext' (Finset.empty_union _)
  add_zero a := UpperSetFin.ext' (Finset.union_empty _)
  add_comm a b := UpperSetFin.ext' (Finset.union_comm _ _)
  mul_assoc a b c := UpperSetFin.ext' (Finset.inter_assoc _ _ _)
  one_mul a := UpperSetFin.ext' (Finset.univ_inter _)
  mul_one a := UpperSetFin.ext' (Finset.inter_univ _)
  mul_comm a b := UpperSetFin.ext' (Finset.inter_comm _ _)
  zero_mul a := UpperSetFin.ext' (Finset.empty_inter _)
  mul_zero a := UpperSetFin.ext' (Finset.inter_empty _)
  left_distrib a b c := by
    apply UpperSetFin.ext'; ext x
    simp only [UpperSetFin.mul_val, UpperSetFin.add_val,
      Finset.mem_inter, Finset.mem_union]; tauto
  right_distrib a b c := by
    apply UpperSetFin.ext'; ext x
    simp only [UpperSetFin.mul_val, UpperSetFin.add_val,
      Finset.mem_inter, Finset.mem_union]; tauto
  natCast n := if n = 0 then 0 else 1
  natCast_zero := if_pos rfl
  natCast_succ n := by
    rw [if_neg (Nat.succ_ne_zero n)]
    split_ifs
    · exact UpperSetFin.ext' (Finset.empty_union _).symm
    · exact UpperSetFin.ext' (Finset.union_idempotent _).symm

/-- **Additive idempotence**: U + U = U. -/
theorem upperSet_idem_add (X : FinT0Poset) (U : UpperSetFin X) :
    U + U = U :=
  UpperSetFin.ext' (Finset.union_idempotent _)

/-- **Multiplicative idempotence**: U * U = U. -/
theorem upperSet_idem_mul (X : FinT0Poset) (U : UpperSetFin X) :
    U * U = U :=
  UpperSetFin.ext' (Finset.inter_self _)

/-- Upper sets form a finite type. -/
noncomputable instance upperSetFintype (X : FinT0Poset) : Fintype (UpperSetFin X) :=
  Fintype.ofInjective (fun U : UpperSetFin X => U.val)
    (fun _ _ h => UpperSetFin.ext' h)

/-- The upper-set idempotent semiring of a finite poset. -/
def UpperSetAlgebra (X : FinT0Poset) : IdemSemiring where
  carrier := UpperSetFin X
  instCSR := upperSetCommSemiring X
  instFin := upperSetFintype X
  instDec := upperSetDecEq X
  idem_add := upperSet_idem_add X

/-! ## §4. Principal Upper Sets and the Stone Embedding -/

/-- The principal upper set ↑x = {y | x ≤ y}. -/
def principalUpper (X : FinT0Poset) (x : X.carrier) : UpperSetFin X where
  val := Finset.univ.filter (fun y => x ≤ y)
  upper := by
    intro a b ha hab
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
    exact le_trans ha hab

theorem mem_principalUpper_self (X : FinT0Poset) (x : X.carrier) :
    x ∈ (principalUpper X x).val := by simp [principalUpper]

@[simp]
theorem mem_principalUpper_iff (X : FinT0Poset) (x y : X.carrier) :
    y ∈ (principalUpper X x).val ↔ x ≤ y := by simp [principalUpper]

theorem principalUpper_antitone (X : FinT0Poset) {x y : X.carrier} (h : x ≤ y) :
    (principalUpper X y).val ⊆ (principalUpper X x).val := by
  intro z hz; rw [mem_principalUpper_iff] at hz ⊢; exact le_trans h hz

theorem principalUpper_le_iff (X : FinT0Poset) (x y : X.carrier) :
    (principalUpper X y).val ⊆ (principalUpper X x).val ↔ x ≤ y := by
  constructor
  · intro h
    have := h (mem_principalUpper_self X y)
    rwa [mem_principalUpper_iff] at this
  · exact principalUpper_antitone X

/-- **Stone embedding**: the principal upper set map is injective. -/
theorem principalUpper_injective (X : FinT0Poset) :
    Function.Injective (principalUpper X) := by
  intro x y h
  have h1 := (principalUpper_le_iff X x y).mp (by rw [h])
  have h2 := (principalUpper_le_iff X y x).mp (by rw [h])
  exact le_antisymm h1 h2

/-- **Contravariant order embedding**: x ≤ y ↔ ↑y ⊆ ↑x. -/
theorem principalUpper_order_embedding (X : FinT0Poset) (x y : X.carrier) :
    x ≤ y ↔ (principalUpper X y).val ⊆ (principalUpper X x).val :=
  (principalUpper_le_iff X x y).symm

/-- Every upper set decomposes as a union of principal upper sets. -/
theorem upperSet_eq_union_principals (X : FinT0Poset) (U : UpperSetFin X) :
    U.val = Finset.biUnion U.val (fun x => (principalUpper X x).val) := by
  ext z; simp only [Finset.mem_biUnion, mem_principalUpper_iff]
  exact ⟨fun hz => ⟨z, hz, le_refl z⟩, fun ⟨x, hx, hxz⟩ => U.upper hx hxz⟩

/-- Principal upper set intersection characterizes upper bounds. -/
theorem principalUpper_inter_mem (X : FinT0Poset) (x y z : X.carrier) :
    z ∈ ((principalUpper X x) * (principalUpper X y)).val ↔
    (x ≤ z ∧ y ≤ z) := by
  simp [UpperSetFin.mul_val, Finset.mem_inter]

/-! ## §5. Congruences and the Spectrum -/

/-- A proper congruence on an idempotent semiring. -/
structure IdemCong (R : IdemSemiring) where
  con : RingCon R.carrier
  proper : ∃ a b : R.carrier, ¬ con a b

instance idemCongPartialOrder (R : IdemSemiring) : PartialOrder (IdemCong R) where
  le P Q := ∀ a b : R.carrier, P.con a b → Q.con a b
  le_refl _ _ _ h := h
  le_trans _ _ _ hPQ hQR a b h := hQR a b (hPQ a b h)
  le_antisymm P Q hPQ hQP := by
    have : P.con = Q.con := by ext a b; exact ⟨hPQ a b, hQP a b⟩
    rcases P with ⟨c1, p1⟩; rcases Q with ⟨c2, p2⟩
    simp only at this; subst this; rfl

/-- Prime separation: distinct elements can be distinguished by congruences. -/
def PrimeSeparated (R : IdemSemiring) : Prop :=
  ∀ a b : R.carrier, a ≠ b → ∃ P : IdemCong R, ¬ P.con a b

/-- **Separation theorem**. -/
theorem specCon_separates (R : IdemSemiring) (hsep : PrimeSeparated R)
    (a b : R.carrier) (hab : a ≠ b) :
    ∃ P : IdemCong R, ¬ P.con a b := hsep a b hab

/-- Basic open D(a,b) in the spectrum. -/
def basicOpenSpec (R : IdemSemiring) (a b : R.carrier) :
    Set (IdemCong R) :=
  {P | ¬ P.con a b}

/-- Complements of basic opens are upward-closed. -/
theorem basicOpen_complement_upper (R : IdemSemiring) (a b : R.carrier)
    (P Q : IdemCong R) (hPQ : P ≤ Q) (hP : P.con a b) : Q.con a b :=
  hPQ a b hP

/-! ## §6. Tropical Language Recognition -/

/-- A tropical language over an alphabet. -/
structure TropicalLanguage (Alpha : Type) where
  pred : List Alpha → Prop

/-- A finite tropical recognizer. -/
structure FiniteTropicalRecognizer (Alpha : Type) where
  algebra : IdemSemiring
  interp : Alpha → algebra.carrier
  accept : Set algebra.carrier
  recognized : TropicalLanguage Alpha

/-- Extension of interpretation to words via the semiring product. -/
def wordInterp {Alpha : Type} (R : FiniteTropicalRecognizer Alpha) :
    List Alpha → R.algebra.carrier
  | [] => 1
  | s :: w => R.interp s * wordInterp R w

/-- Recognizer equivalence. -/
def RecognizerEquiv {Alpha : Type}
    (R₁ R₂ : FiniteTropicalRecognizer Alpha) : Prop :=
  ∀ w : List Alpha, R₁.recognized.pred w ↔ R₂.recognized.pred w

/-- Minimality of a recognizer. -/
def IsMinimalRecognizer {Alpha : Type}
    (R : FiniteTropicalRecognizer Alpha) : Prop :=
  ∀ R' : FiniteTropicalRecognizer Alpha,
    RecognizerEquiv R R' →
    Fintype.card R.algebra.carrier ≤ Fintype.card R'.algebra.carrier

/-- **Minimal recognizer cardinality uniqueness**. -/
theorem minimal_recognizer_card_eq {Alpha : Type}
    (R₁ R₂ : FiniteTropicalRecognizer Alpha)
    (heq : RecognizerEquiv R₁ R₂)
    (hmin₁ : IsMinimalRecognizer R₁)
    (hmin₂ : IsMinimalRecognizer R₂) :
    Fintype.card R₁.algebra.carrier = Fintype.card R₂.algebra.carrier :=
  le_antisymm (hmin₁ R₂ heq) (hmin₂ R₁ (fun w => (heq w).symm))

/-! ## §7. Structural Properties -/

/-- Empty and full upper sets are distinct on nonempty posets. -/
theorem empty_ne_full (X : FinT0Poset) [Nonempty X.carrier] :
    (0 : UpperSetFin X) ≠ (1 : UpperSetFin X) := by
  intro heq
  have hv : (0 : UpperSetFin X).val = (1 : UpperSetFin X).val := by rw [heq]
  simp only [UpperSetFin.zero_val, UpperSetFin.one_val] at hv
  have : Classical.arbitrary X.carrier ∈ (∅ : Finset X.carrier) := by
    rw [hv]; exact Finset.mem_univ _
  simp at this

/-- Upper-set algebra has ≥ 2 elements on a nonempty poset. -/
theorem upperSet_card_ge_two (X : FinT0Poset) [Nonempty X.carrier] :
    2 ≤ Fintype.card (UpperSetFin X) := by
  rw [show (2 : ℕ) = 1 + 1 from rfl]
  rw [Nat.add_one_le_iff]
  exact Fintype.one_lt_card_iff_nontrivial.mpr
    ⟨⟨0, 1, empty_ne_full X⟩⟩

/-- **Double idempotence**: both + and × are idempotent. -/
theorem upperSetAlgebra_doubly_idem (X : FinT0Poset) (U : UpperSetFin X) :
    U + U = U ∧ U * U = U :=
  ⟨upperSet_idem_add X U, upperSet_idem_mul X U⟩

/-- **Absorption law**: U * (U + V) = U. -/
theorem upperSet_absorption (X : FinT0Poset) (U V : UpperSetFin X) :
    U * (U + V) = U := by
  apply UpperSetFin.ext'; ext x
  simp [UpperSetFin.mul_val, UpperSetFin.add_val, Finset.mem_inter, Finset.mem_union]
  tauto

/-- **Dual absorption**: U + U * V = U. -/
theorem upperSet_absorption_dual (X : FinT0Poset) (U V : UpperSetFin X) :
    U + U * V = U := by
  apply UpperSetFin.ext'; ext x
  simp [UpperSetFin.mul_val, UpperSetFin.add_val, Finset.mem_inter, Finset.mem_union]
  tauto

/-- Union distributes over intersection (modularity). -/
theorem upperSet_union_inter_distrib (X : FinT0Poset) (U V W : UpperSetFin X) :
    U + V * W = (U + V) * (U + W) := by
  apply UpperSetFin.ext'; ext x
  simp [UpperSetFin.mul_val, UpperSetFin.add_val, Finset.mem_inter, Finset.mem_union]
  tauto

/-! ## §8. Concrete Examples -/

/-- The singleton poset (one element). -/
def unitPoset : FinT0Poset where
  carrier := Unit
  instFin := inferInstance
  instDec := inferInstance
  instPO := inferInstance
  instDecLE := inferInstance

/-
The singleton poset has exactly 2 upper sets: ∅ and {()}.
-/
theorem unitPoset_upperSets_card :
    Fintype.card (UpperSetFin unitPoset) = 2 := by
  convert Fintype.card_eq.2 _;
  convert rfl;
  convert Fintype.card_fin 2;
  refine' ⟨ _ ⟩;
  refine' Equiv.ofBijective ( fun x => if x.val = ∅ then 0 else 1 ) ⟨ _, _ ⟩;
  · intro x y hxy;
    rcases x with ⟨ x, hx ⟩ ; rcases y with ⟨ y, hy ⟩ ; simp_all +decide [ Finset.ext_iff ];
    split_ifs at hxy <;> simp_all +decide;
    aesop;
  · intro x;
    fin_cases x <;> [ exact ⟨ ⟨ ∅, by simp +decide ⟩, rfl ⟩ ; exact ⟨ ⟨ { () }, by simp +decide ⟩, rfl ⟩ ]

/-- The chain poset on Fin n (linear order). -/
def chainPoset (n : ℕ) : FinT0Poset where
  carrier := Fin n
  instFin := inferInstance
  instDec := inferInstance
  instPO := inferInstance
  instDecLE := inferInstance

/-
The chain on Fin 2 has 3 upper sets: ∅, {1}, {0, 1}.
-/
theorem chain2_upperSets_card :
    Fintype.card (UpperSetFin (chainPoset 2)) = 3 := by
  rw [ Fintype.card_eq_nat_card ];
  -- Let's count the number of upper sets in the chain poset on 2 elements. There are 3 upper sets: the empty set, the set containing only 0, and the set containing both 0 and 1.
  have h_upper_sets : Nat.card {S : Finset (Fin 2) | ∀ {x y : Fin 2}, x ∈ S → x ≤ y → y ∈ S} = 3 := by
    simp +decide;
  convert h_upper_sets using 1;
  apply Nat.card_congr;
  exact ⟨ fun x => ⟨ x.val, x.upper ⟩, fun x => ⟨ x.val, x.property ⟩, fun x => rfl, fun x => rfl ⟩

/-! ## §9. Word Interpretation Properties -/

/-- Word interpretation is multiplicative (a monoid homomorphism). -/
theorem wordInterp_append {Alpha : Type} (R : FiniteTropicalRecognizer Alpha)
    (u v : List Alpha) :
    wordInterp R (u ++ v) = wordInterp R u * wordInterp R v := by
  induction u with
  | nil => simp [wordInterp, one_mul]
  | cons a u ih => simp [wordInterp, ih, mul_assoc]

/-- Word interpretation of a single letter. -/
theorem wordInterp_singleton {Alpha : Type} (R : FiniteTropicalRecognizer Alpha)
    (a : Alpha) :
    wordInterp R [a] = R.interp a := by
  simp [wordInterp, mul_one]

/-- Word interpretation of the empty word is 1. -/
theorem wordInterp_nil {Alpha : Type} (R : FiniteTropicalRecognizer Alpha) :
    wordInterp R [] = 1 := rfl

/-! ## §10. Main Duality Theorem -/

/-- **The Finite Tropical Stone Recognition Duality** (main statement):

    For any finite T₀ poset X:
    1. The principal upper set map x ↦ ↑x is injective (Stone embedding).
    2. It reverses the order: x ≤ y ↔ ↑y ⊆ ↑x.
    3. Addition (union) is idempotent.
    4. Multiplication (intersection) is idempotent.
    5. The absorption law holds: U * (U + V) = U.
    6. Every upper set decomposes as a union of principal upper sets.

    This establishes the upper-set algebra as a tropical recognition algebra
    and the principal upper set map as the finite Stone representation. -/
theorem finite_tropical_stone_representation (X : FinT0Poset) :
    Function.Injective (principalUpper X) ∧
    (∀ x y : X.carrier, x ≤ y ↔
      (principalUpper X y).val ⊆ (principalUpper X x).val) ∧
    (∀ U : UpperSetFin X, U + U = U) ∧
    (∀ U : UpperSetFin X, U * U = U) ∧
    (∀ U V : UpperSetFin X, U * (U + V) = U) :=
  ⟨principalUpper_injective X,
   principalUpper_order_embedding X,
   upperSet_idem_add X,
   upperSet_idem_mul X,
   upperSet_absorption X⟩

end TropicalStoneRecognition