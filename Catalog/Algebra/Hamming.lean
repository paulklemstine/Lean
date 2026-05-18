/-
  # Hamming Weight and Distance for Coding Theory

  Foundational definitions for linear codes over finite fields:
  Hamming weight, Hamming distance, and minimum distance of codes.
-/

import Mathlib

open Finset

noncomputable section

namespace CodingTheory

/-- Hamming weight: number of nonzero entries. -/
def hammingWt {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (v : Fin n → K) : ℕ :=
  (Finset.univ.filter fun i => v i ≠ 0).card

/-- Hamming distance: number of positions where two vectors differ. -/
def hammingD {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (u v : Fin n → K) : ℕ :=
  (Finset.univ.filter fun i => u i ≠ v i).card

/-- The support of a vector as a Finset. -/
def support' {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (v : Fin n → K) : Finset (Fin n) :=
  Finset.univ.filter fun i => v i ≠ 0

theorem hammingWt_le {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (v : Fin n → K) : hammingWt v ≤ n := by
  unfold hammingWt
  calc (univ.filter fun i => v i ≠ 0).card ≤ univ.card := card_filter_le _ _
    _ = n := Finset.card_fin n

theorem hammingWt_zero {n : ℕ} {K : Type*} [Zero K] [DecidableEq K] :
    hammingWt (0 : Fin n → K) = 0 := by
  simp [hammingWt]

theorem hammingWt_eq_zero_iff {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (v : Fin n → K) : hammingWt v = 0 ↔ v = 0 := by
  -- By definition of Hamming weight, if the support of v is empty, then v must be the zero vector.
  simp [hammingWt, support'];
  -- By definition of function equality, if v is the zero vector, then for all x, v x = 0.
  simp [funext_iff]

/-- Hamming distance equals weight of difference. -/
theorem hammingD_eq_hammingWt_sub {n : ℕ} {K : Type*}
    [AddGroup K] [DecidableEq K]
    (u v : Fin n → K) :
    hammingD u v = hammingWt (u - v) := by
  simp [hammingD, hammingWt]; congr 1; ext i; simp [sub_ne_zero]

theorem hammingD_self {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (v : Fin n → K) : hammingD v v = 0 := by
  simp [hammingD]

theorem hammingD_comm {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (u v : Fin n → K) : hammingD u v = hammingD v u := by
  -- The set of indices where u and v differ is the same as the set where v and u differ.
  have h_symm : Finset.univ.filter (fun i => u i ≠ v i) = Finset.univ.filter (fun i => v i ≠ u i) := by
    grind +splitImp;
  grind +locals

/-
Complement counting: weight + zero-count = n.
-/
theorem hammingWt_add_zeros {n : ℕ} {K : Type*} [Zero K] [DecidableEq K]
    (v : Fin n → K) :
    hammingWt v + (Finset.univ.filter fun i => v i = 0).card = n := by
  -- The sum of the weights of the two sets is equal to the cardinality of the entire set.
  have h_sum : (Finset.univ.filter fun i => v i ≠ 0).card + (Finset.univ.filter fun i => v i = 0).card = n := by
    rw [ add_comm, Finset.card_filter_add_card_filter_not, Finset.card_fin ];
  convert h_sum using 1

end CodingTheory

end