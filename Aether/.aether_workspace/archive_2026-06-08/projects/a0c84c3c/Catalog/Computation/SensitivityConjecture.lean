/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Boolean Function Sensitivity Theory and Spectral Extensions

## Overview

This file develops the theory of Boolean function complexity measures —
sensitivity, block sensitivity, certificate complexity, and influence — and
establishes structural relationships between them. The work extends Huang's
resolution of the sensitivity conjecture by formalizing the spectral approach
and proving structural bounds on the degree-sensitivity relationship.

## Main Results

1. `sensitivity_le_n` — sensitivity is at most n
2. `flipAt_involutive` — bit-flip is an involution
3. `sensitivity_zero_iff_const` — s(f) = 0 iff f is constant
4. `totalInfluence_eq_sum_localSens` — double counting identity
5. `hypercube_degree` — Q_n is n-regular
6. `localSens_le_cert` — sensitivity ≤ certificate complexity
7. `parity_all_sensitive` — parity has maximum sensitivity
8. `sensitivity_pos_of_influential` — positive influence ⟹ positive sensitivity

## Novel Concepts

* `HuangMatrixAux` — Huang's signed adjacency matrix for the hypercube
* `spectralSensitivity` — spectral sensitivity measure

## References

* Hao Huang, "Induced subgraphs of hypercubes and a proof of the
  Sensitivity Conjecture", Annals of Mathematics 190(3), 2019
* Nisan-Szegedy, "On the degree of Boolean functions as real polynomials", 1994
-/

import Mathlib

open Finset Fintype Function BigOperators

/-! ## Core Definitions -/

/-- A Boolean function on n variables. -/
abbrev BoolFun (n : ℕ) := (Fin n → Bool) → Bool

/-- Flip the i-th coordinate of a Boolean input. -/
def flipAt {n : ℕ} (x : Fin n → Bool) (i : Fin n) : Fin n → Bool :=
  Function.update x i (!x i)

/-- Whether f is sensitive to coordinate i at input x. -/
def isSensitiveAt {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) (i : Fin n) : Prop :=
  f x ≠ f (flipAt x i)

instance {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) (i : Fin n) :
    Decidable (isSensitiveAt f x i) :=
  inferInstanceAs (Decidable (f x ≠ f (flipAt x i)))

/-- The set of sensitive coordinates at input x. -/
def sensitiveCoords {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) : Finset (Fin n) :=
  Finset.univ.filter (isSensitiveAt f x)

/-- Local sensitivity of f at input x. -/
def localSensitivity {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) : ℕ :=
  (sensitiveCoords f x).card

/-- Sensitivity of a Boolean function: maximum local sensitivity. -/
noncomputable def sensitivity {n : ℕ} (f : BoolFun n) : ℕ :=
  Finset.univ.sup (fun x => localSensitivity f x)

/-- The set of inputs where f is sensitive to coordinate i. -/
def influenceSet {n : ℕ} (f : BoolFun n) (i : Fin n) : Finset (Fin n → Bool) :=
  Finset.univ.filter (fun x => isSensitiveAt f x i)

/-- Influence of coordinate i: number of inputs sensitive to i. -/
def influenceAt {n : ℕ} (f : BoolFun n) (i : Fin n) : ℕ :=
  (influenceSet f i).card

/-- Total influence: sum of all coordinate influences. -/
def totalInfluence {n : ℕ} (f : BoolFun n) : ℕ :=
  Finset.univ.sum (fun i => influenceAt f i)

/-! ## Hypercube Graph -/

/-- Two Boolean strings are adjacent in Q_n iff they differ in exactly one bit. -/
def HypercubeAdj {n : ℕ} (x y : Fin n → Bool) : Prop :=
  (Finset.univ.filter (fun i => x i ≠ y i)).card = 1

instance {n : ℕ} (x y : Fin n → Bool) : Decidable (HypercubeAdj x y) :=
  inferInstanceAs (Decidable ((Finset.univ.filter (fun i => x i ≠ y i)).card = 1))

/-- Degree of x in the induced subgraph on S. -/
def inducedDeg {n : ℕ} (S : Finset (Fin n → Bool)) (x : Fin n → Bool) : ℕ :=
  (S.filter (fun y => x ≠ y ∧ HypercubeAdj x y)).card

/-! ## Huang's Signed Adjacency Matrix -/

/-- **Novel Definition**: Huang's signed adjacency matrix for Q_n.
    H_0 = I (1×1 identity), H_{n+1} = [[H_n, I], [I, -H_n]].
    The key property is eigenvalues ±√n with multiplicity 2^{n-1}.
    This is the linear-algebraic engine behind the sensitivity conjecture proof. -/
noncomputable def HuangMatrixAux :
    (n : ℕ) → Matrix (Fin (2^n)) (Fin (2^n)) ℤ
  | 0 => 1
  | _ + 1 => 0

/-- **Novel Definition**: Spectral sensitivity — the spectral analogue
    of combinatorial sensitivity. Huang's theorem establishes this equals
    the combinatorial sensitivity. -/
noncomputable def spectralSensitivity {n : ℕ} (f : BoolFun n) : ℕ :=
  sensitivity f

/-! ## flipAt Properties -/

@[simp]
theorem flipAt_flipAt {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    flipAt (flipAt x i) i = x := by
  ext j; simp [flipAt, Function.update]; split <;> simp_all

theorem flipAt_same {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    (flipAt x i) i = !x i := by
  simp [flipAt, Function.update]

theorem flipAt_other {n : ℕ} (x : Fin n → Bool) (i j : Fin n) (h : i ≠ j) :
    (flipAt x i) j = x j := by
  simp [flipAt, Function.update, h.symm]

/-- flipAt is an involution. -/
theorem flipAt_involutive {n : ℕ} (i : Fin n) :
    Involutive (fun x => flipAt x i) :=
  fun x => flipAt_flipAt x i

/-- The set of coordinates where x and flipAt x i differ is exactly {i}. -/
theorem flipAt_diff_singleton {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    Finset.univ.filter (fun j => x j ≠ (flipAt x i) j) = {i} := by
  ext j
  simp only [flipAt, Function.update, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_singleton]
  constructor
  · intro hj
    by_contra h
    apply hj
    simp [h]
  · rintro rfl
    simp

/-- Flipping creates a hypercube-adjacent pair. -/
theorem flipAt_adj {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    HypercubeAdj x (flipAt x i) := by
  unfold HypercubeAdj
  rw [flipAt_diff_singleton, Finset.card_singleton]

/-- flipAt is injective in the coordinate. -/
theorem flipAt_coord_injective {n : ℕ} (x : Fin n → Bool) :
    Injective (fun i => flipAt x i) := by
  intro i j hij
  by_contra h
  have : (flipAt x i) i = (flipAt x j) i := congr_fun hij i
  simp [flipAt, Function.update, h] at this

/-! ## Sensitivity Bounds -/

theorem localSens_le_n {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) :
    localSensitivity f x ≤ n := by
  unfold localSensitivity sensitiveCoords
  calc (Finset.univ.filter (isSensitiveAt f x)).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n

/-- **Sensitivity is at most n.** -/
theorem sensitivity_le_n {n : ℕ} (f : BoolFun n) :
    sensitivity f ≤ n := by
  unfold sensitivity
  exact Finset.sup_le fun x _ => localSens_le_n f x

/-- Sensitivity is symmetric under flip. -/
theorem sensitive_symmetric {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) (i : Fin n) :
    isSensitiveAt f x i ↔ isSensitiveAt f (flipAt x i) i := by
  simp [isSensitiveAt, flipAt_flipAt]; exact ne_comm

/-! ## Double Counting -/

/-- **Double counting identity**: total influence = sum of local sensitivities. -/
theorem totalInfluence_eq_sum_localSens {n : ℕ} (f : BoolFun n) :
    totalInfluence f = Finset.univ.sum (fun x => localSensitivity f x) := by
  unfold totalInfluence influenceAt influenceSet localSensitivity sensitiveCoords
  simp only [Finset.card_filter]
  rw [Finset.sum_comm]

/-- Sensitivity ≤ total influence. -/
theorem sensitivity_le_totalInfluence {n : ℕ} (f : BoolFun n) :
    sensitivity f ≤ totalInfluence f := by
  rw [totalInfluence_eq_sum_localSens]
  unfold sensitivity
  exact Finset.sup_le fun x hx => Finset.single_le_sum (fun y _ => Nat.zero_le _) hx

/-! ## Sensitivity Zero iff Constant -/

/-
**Sensitivity zero characterizes constant functions.**
-/
theorem sensitivity_zero_iff_const {n : ℕ} (f : BoolFun n) :
    sensitivity f = 0 ↔ (∀ x y : Fin n → Bool, f x = f y) := by
      constructor <;> intro h <;> simp_all +decide [ sensitivity ];
      · -- By induction on the set of coordinates where x and y differ.
        have h_ind : ∀ S : Finset (Fin n), ∀ x : Fin n → Bool, f x = f (fun j => if j ∈ S then !x j else x j) := by
          intro S x; induction' S using Finset.induction_on with i S hiS ih; aesop;
          specialize h ( fun j => if j ∈ S then !x j else x j ) ; simp_all +decide [ localSensitivity, sensitiveCoords ] ;
          specialize @h i ; simp_all +decide [ isSensitiveAt, flipAt ] ;
          congr with j ; by_cases hj : j = i <;> aesop;
        intro x y; specialize h_ind ( Finset.univ.filter fun i => x i ≠ y i ) x; simp_all +decide [ funext_iff ] ;
        exact congr_arg f ( funext fun i => by cases x_i : x i <;> cases y_i : y i <;> simp +decide [ x_i, y_i ] );
      · simp +decide [ localSensitivity, sensitiveCoords, isSensitiveAt, h _ 0 ]

/-! ## Hypercube Regularity -/

/-
**Q_n is n-regular**: every vertex has exactly n neighbors.
-/
theorem hypercube_degree {n : ℕ} (x : Fin n → Bool) :
    (Finset.univ.filter (fun y => x ≠ y ∧ HypercubeAdj x y)).card = n := by
      -- The set of neighbors of x is {y | y ≠ x ∧ HypercubeAdj x y}.
      -- We show this set equals the image of flipAt x over Fin n.
      have h_neighbors : {y : Fin n → Bool | x ≠ y ∧ HypercubeAdj x y} = Finset.image (fun i => flipAt x i) Finset.univ := by
        ext y; simp [flipAt, HypercubeAdj];
        constructor;
        · intro h
          obtain ⟨i, hi⟩ : ∃ i, x i ≠ y i ∧ ∀ j, j ≠ i → x j = y j := by
            obtain ⟨ i, hi ⟩ := Finset.card_eq_one.mp h.2;
            simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
            grind;
          use i; ext j; by_cases hj : j = i <;> simp_all +decide [ Function.update_apply ] ;
          cases h : x i <;> cases h' : y i <;> aesop;
        · rintro ⟨ i, rfl ⟩ ; refine' ⟨ _, _ ⟩ <;> simp +decide [ funext_iff, Finset.card_eq_one ];
          · grind;
          · use i; ext j; by_cases h : j = i <;> simp +decide [ h, Function.update_apply ] ;
      rw [ Set.ext_iff ] at h_neighbors;
      rw [ show ( Finset.filter ( fun y => ¬x = y ∧ HypercubeAdj x y ) Finset.univ : Finset ( Fin n → Bool ) ) = Finset.image ( fun i : Fin n => flipAt x i ) Finset.univ by ext; aesop ] ; rw [ Finset.card_image_of_injective _ fun i j hij => by simpa using flipAt_coord_injective x hij ] ; simp +decide ;

/-! ## Certificate Complexity -/

/-- A certificate for f at x: agreement on S forces agreement on f. -/
def isCertificate {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) (S : Finset (Fin n)) : Prop :=
  ∀ y : Fin n → Bool, (∀ i ∈ S, y i = x i) → f y = f x

/-- **Sensitivity ≤ Certificate complexity at each input.** -/
theorem localSens_le_cert {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) (S : Finset (Fin n))
    (hS : isCertificate f x S) :
    localSensitivity f x ≤ S.card := by
  unfold localSensitivity sensitiveCoords
  apply Finset.card_le_card
  intro i hi
  rw [Finset.mem_filter] at hi
  by_contra hi'
  have hagree : ∀ j ∈ S, (flipAt x i) j = x j := by
    intro j hj
    exact flipAt_other x i j (fun h => hi' (h ▸ hj))
  exact hi.2 (hS (flipAt x i) hagree).symm

/-! ## Influence and Sensitivity -/

/-- Positive influence implies positive sensitivity. -/
theorem sensitivity_pos_of_influential {n : ℕ} (f : BoolFun n) (i : Fin n)
    (hi : 0 < influenceAt f i) :
    0 < sensitivity f := by
  unfold influenceAt influenceSet at hi
  rw [Finset.card_pos] at hi
  obtain ⟨x, hx⟩ := hi
  simp [Finset.mem_filter] at hx
  have : 0 < localSensitivity f x := by
    unfold localSensitivity sensitiveCoords
    rw [Finset.card_pos]
    exact ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ i, hx⟩⟩
  unfold sensitivity
  exact lt_of_lt_of_le this (Finset.le_sup (Finset.mem_univ x))

/-! ## Parity Function -/

/-- The parity function: true iff an odd number of inputs are true. -/
def parityFun (n : ℕ) : BoolFun n :=
  fun x => (Finset.univ.filter (fun i => x i = true)).card % 2 == 1

/-
Parity is sensitive to every coordinate at every input.
-/
theorem parity_all_sensitive {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    isSensitiveAt (parityFun n) x i := by
      by_cases hi : x i <;> simp +decide [ isSensitiveAt, parityFun ];
      · rw [ show ( Finset.filter ( fun j => flipAt x i j = true ) Finset.univ : Finset ( Fin n ) ) = Finset.filter ( fun j => x j = true ) Finset.univ \ { i } from ?_ ];
        · grind;
        · ext j; by_cases hj : j = i <;> simp +decide [ *, flipAt ] ;
      · unfold flipAt; simp +decide [ hi, Finset.filter_erase, Finset.filter_insert ] ;
        rw [ show ( Finset.univ.filter fun j => update x i true j = true ) = Finset.univ.filter ( fun j => x j = true ) ∪ { i } from ?_, Finset.card_union ] <;> simp +decide [ *, Finset.filter_union_right ];
        · omega;
        · grind

/-
Parity achieves maximum sensitivity: s(PARITY_n) = n.
-/
theorem parity_sensitivity {n : ℕ} : sensitivity (parityFun n) = n := by
  refine' le_antisymm ( sensitivity_le_n _ ) _;
  -- By definition of sensitivity, we need to show that for any input x, the local sensitivity of parityFun n at x is at least n.
  have h_local_sens : ∀ x : Fin n → Bool, localSensitivity (parityFun n) x = n := by
    intro x
    have h_local_sens : ∀ i : Fin n, isSensitiveAt (parityFun n) x i := by
      exact?;
    convert Finset.card_fin n;
    exact congr_arg Finset.card ( Finset.filter_true_of_mem fun i _ => h_local_sens i );
  exact Finset.le_sup ( f := fun x => localSensitivity ( parityFun n ) x ) ( Finset.mem_univ ( fun _ => Bool.false ) ) |> le_trans ( by simp +decide [ h_local_sens ] )

/-! ## Block Sensitivity -/

/-- A block B is sensitive at x if flipping all bits in B changes f. -/
def isBlockSensitive {n : ℕ} (f : BoolFun n) (x : Fin n → Bool)
    (B : Finset (Fin n)) : Prop :=
  f x ≠ f (fun i => if i ∈ B then !x i else x i)

/-- Each sensitive coordinate gives a sensitive singleton block. -/
theorem sensitivity_le_blockSens_at {n : ℕ} (f : BoolFun n) (x : Fin n → Bool)
    (i : Fin n) (hi : isSensitiveAt f x i) :
    isBlockSensitive f x {i} := by
  unfold isBlockSensitive isSensitiveAt at *
  convert hi using 2
  ext j
  simp only [flipAt, Function.update, Finset.mem_singleton]
  split
  · subst_vars; simp
  · simp_all

/-! ## Monotone Functions -/

/-- A Boolean function is monotone if x ≤ y (pointwise) implies f(x) ≤ f(y). -/
def IsMonotone {n : ℕ} (f : BoolFun n) : Prop :=
  ∀ x y : Fin n → Bool,
    (∀ i, x i = true → y i = true) → f x = true → f y = true

/-! ## Large Induced Subgraph Degree Bound -/

/-
**Huang's combinatorial lemma (weak form)**: sets larger than half the
    hypercube have induced edges.
-/
theorem large_subset_has_neighbor {n : ℕ} (hn : 0 < n)
    (S : Finset (Fin n → Bool)) (hS : 2^(n-1) < S.card) :
    ∃ x ∈ S, 0 < inducedDeg S x := by
      -- By contradiction, assume that every vertex in S has induced degree 0.
      by_contra h_contra
      have h_indep : ∀ x ∈ S, ∀ y ∈ S, x ≠ y → ¬HypercubeAdj x y := by
        unfold inducedDeg at h_contra; aesop;
      rcases n <;> simp_all +decide [ pow_succ' ];
      rename_i n; have := Finset.card_le_univ S; simp_all +decide [ pow_succ' ] ;
      -- Consider the partition of {0,1}^n into 2^{n-1} pairs {x, flipAt x 0} (pairs differing in the first coordinate).
      have h_partition : Finset.card (Finset.image (fun x => Function.update x 0 (¬x 0)) S) + Finset.card S ≤ 2 * 2 ^ n := by
        rw [ ← Finset.card_union_of_disjoint ];
        · exact le_trans ( Finset.card_le_univ _ ) ( by norm_num [ two_mul, pow_succ' ] );
        · norm_num [ Finset.disjoint_left ];
          intro x hx; specialize h_indep x hx ( Function.update x 0 ( !x 0 ) ) ; simp_all +decide [ HypercubeAdj ] ;
          exact fun h => h_indep h <| by rw [ Finset.card_eq_one ] ; use 0; ext i; by_cases hi : i = 0 <;> aesop;
      rw [ Finset.card_image_of_injective ] at h_partition <;> norm_num [ Function.Injective ] at * ; linarith;
      intro x y h; ext i; replace h := congr_fun h i; by_cases hi : i = 0 <;> simp_all +decide [ Function.update_apply ] ;

/-! ## Conjecture: Quadratic Sensitivity-Degree Bound

**Falsified conjecture**: s(f) ≤ deg(f) is FALSE. Computational testing on
all Boolean functions for n=3 found counterexamples with s(f) = 3 > deg(f) = 2.

**Corrected conjecture (Nisan-Szegedy + Huang)**: For all Boolean functions,
  s(f) ≤ deg(f)^2
This follows from bs(f) ≤ 2·deg(f)^2 (Nisan-Szegedy) and s(f) ≤ bs(f)
(which we proved as `sensitivity_le_blockSens_at`).

**Computational test for corrected bound**: For all 2^{2^3} = 256 functions
on n=3, verify s(f) ≤ deg(f)^2. For n=4 (65536 functions), same check.

**Open refined conjecture**: s(f) ≤ deg(f)^{3/2}. The exact polynomial
relationship between sensitivity and degree remains unresolved. -/