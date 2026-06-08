/-
Copyright (c) 2025. All rights reserved.

# The Fano Matroid Counterexample: Dr(3,7) ≠ Trop(Gr(3,7))

## Main results

* `fanoWeight_in_dressian` — the Fano weight satisfies all tropical Plücker relations
* `fano_not_representable_over_ℝ` — the Fano matroid is not representable over ℝ
* `fanoWeight_not_in_tropicalGrassmannian3` — not tropically realizable
* `dressian_ne_tropicalGrassmannian_rank3` — Dr(3,7) ≠ Trop(Gr(3,7))
-/

import Tropical.Grassmannian.Defs
import Tropical.Grassmannian.FanoAlgebra

open Finset Matrix

/-! ### The Fano matroid on Fin 7 -/

def fanoLines : List (Finset (Fin 7)) :=
  [{0, 1, 3}, {0, 2, 4}, {1, 2, 5}, {0, 5, 6}, {1, 4, 6}, {2, 3, 6}, {3, 4, 5}]

def IsFanoLine (I : Finset (Fin 7)) : Bool := I ∈ fanoLines

/-! ### Decidable Dressian verification -/

def fanoWeightZ (I : Finset (Fin 7)) : ℤ := if IsFanoLine I then 1 else 0

def minAttainedTwice3_dec (a b c : ℤ) : Bool :=
  (a == b && decide (a ≤ c)) || (a == c && decide (a ≤ b)) || (b == c && decide (b ≤ a))

lemma minAttainedTwice3_dec_to_real {a b c : ℤ}
    (h : minAttainedTwice3_dec a b c = true) :
    MinAttainedTwice3 (a : ℝ) (b : ℝ) (c : ℝ) := by
  simp only [minAttainedTwice3_dec, Bool.or_eq_true, Bool.and_eq_true,
    beq_iff_eq, decide_eq_true_eq] at h
  unfold MinAttainedTwice3
  rcases h with (⟨h1, h2⟩ | ⟨h1, h2⟩) | ⟨h1, h2⟩
  · exact Or.inl ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩
  · exact Or.inr (Or.inl ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩)
  · exact Or.inr (Or.inr ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩)

def checkDressianFano : Bool :=
  List.all (List.finRange 7) fun s =>
    List.all (List.finRange 7) fun a =>
      List.all (List.finRange 7) fun b =>
        List.all (List.finRange 7) fun c =>
          List.all (List.finRange 7) fun d =>
            if a = s || b = s || c = s || d = s then true
            else if a = b || a = c || a = d || b = c || b = d || c = d then true
            else
              minAttainedTwice3_dec
                (fanoWeightZ ({s} ∪ {a, b}) + fanoWeightZ ({s} ∪ {c, d}))
                (fanoWeightZ ({s} ∪ {a, c}) + fanoWeightZ ({s} ∪ {b, d}))
                (fanoWeightZ ({s} ∪ {a, d}) + fanoWeightZ ({s} ∪ {b, c}))

theorem checkDressianFano_true : checkDressianFano = true := by native_decide

noncomputable def fanoWeight : PluckerVec 3 7 :=
  fun I => if IsFanoLine I then 1 else 0

lemma fanoWeight_eq_cast (I : Finset (Fin 7)) :
    fanoWeight I = (fanoWeightZ I : ℝ) := by
  simp only [fanoWeight, fanoWeightZ]; split <;> simp

/-! ### Dressian membership -/

theorem fanoWeight_in_dressian : InDressian 3 7 fanoWeight := by
  intro S hS a b c d haS hbS hcS hdS hab hac had hbc hbd hcd
  have hS1 : S.card = 1 := by omega
  obtain ⟨s, rfl⟩ := Finset.card_eq_one.mp hS1
  simp only [Finset.mem_singleton] at haS hbS hcS hdS
  simp only [fanoWeight_eq_cast, ← Int.cast_add]
  apply minAttainedTwice3_dec_to_real
  have h := checkDressianFano_true
  simp only [checkDressianFano, List.all_eq_true, List.mem_finRange, forall_true_left,
    Bool.ite_eq_true_distrib] at h
  specialize h s a b c d
  simp only [haS, hbS, hcS, hdS, hab, hac, had, hbc, hbd, hcd,
    decide_false, Bool.false_or] at h
  exact h

/-! ### Non-representability of the Fano matroid over ℝ -/

/-- A matrix represents the Fano matroid if its dependent triples are the Fano lines. -/
def RepresentsFanoMatroid (A : Matrix (Fin 3) (Fin 7) ℝ) : Prop :=
  ∀ (i j k : Fin 7), i < j → j < k →
    (detCols3 A i j k = 0 ↔ IsFanoLine {i, j, k} = true)

/-- Helper to extract det ≠ 0 from non-Fano line. -/
private lemma det_ne_zero_of_not_fano {A : Matrix (Fin 3) (Fin 7) ℝ}
    (hA : RepresentsFanoMatroid A) {i j k : Fin 7}
    (hij : i < j) (hjk : j < k)
    (hF : IsFanoLine {i, j, k} = false) :
    detCols3 A i j k ≠ 0 := by
  intro h
  have := (hA i j k hij hjk).mp h
  rw [hF] at this; exact absurd this (by decide)

/-- Helper to extract det = 0 from Fano line. -/
private lemma det_eq_zero_of_fano {A : Matrix (Fin 3) (Fin 7) ℝ}
    (hA : RepresentsFanoMatroid A) {i j k : Fin 7}
    (hij : i < j) (hjk : j < k)
    (hF : IsFanoLine {i, j, k} = true) :
    detCols3 A i j k = 0 :=
  (hA i j k hij hjk).mpr hF

/-- **The Fano matroid is not representable over ℝ.** -/
theorem fano_not_representable_over_ℝ :
    ¬ ∃ (A : Matrix (Fin 3) (Fin 7) ℝ), RepresentsFanoMatroid A := by
  intro ⟨A, hA⟩
  -- detCols = detCols3 by definition
  have hd : ∀ i j k, detCols A i j k = detCols3 A i j k := fun _ _ _ => rfl
  apply fano_algebraic_contradiction
  refine ⟨A, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  -- {0,1,2} independent
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  -- 7 Fano lines
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  -- Non-Fano triples
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)

/-! ### Non-realizability in the tropical Grassmannian -/

lemma fanoWeight_fanoLine_gt_min (I : Finset (Fin 7))
    (hfano : IsFanoLine I = true) :
    ∃ J : Finset (Fin 7), J.card = 3 ∧ fanoWeight J < fanoWeight I := by
  refine ⟨{0, 2, 3}, by native_decide, ?_⟩
  simp [fanoWeight, hfano, show IsFanoLine ({0, 2, 3} : Finset (Fin 7)) = false from by native_decide]

lemma fanoWeight_nonFano_is_min (I : Finset (Fin 7))
    (hnotfano : IsFanoLine I = false) (J : Finset (Fin 7)) (_ : J.card = 3) :
    fanoWeight I ≤ fanoWeight J := by
  unfold fanoWeight; simp only [hnotfano, Bool.false_eq_true, ↓reduceIte]
  split_ifs <;> norm_num

/-- **The Fano weight is NOT in the tropical Grassmannian.** -/
theorem fanoWeight_not_in_tropicalGrassmannian3 :
    ¬ InTropicalGrassmannian3 7 fanoWeight := by
  intro ⟨A, hmin, hnonmin⟩
  apply fano_not_representable_over_ℝ
  exact ⟨A, fun i j k hij hjk => by
    have hI_card : ({i, j, k} : Finset (Fin 7)).card = 3 :=
      Finset.card_eq_three.mpr ⟨i, j, k, by omega, by omega, by omega, rfl⟩
    constructor
    · intro hdet
      by_contra hnotfano
      simp only [Bool.not_eq_true] at hnotfano
      have hI_min := fanoWeight_nonFano_is_min {i, j, k} hnotfano
      exact (hmin i j k hij hjk hI_min) hdet
    · intro hfano
      exact hnonmin i j k hij hjk (fanoWeight_fanoLine_gt_min {i, j, k} hfano)⟩

/-! ### The separation theorem -/

/-- **The Dressian strictly contains the tropical Grassmannian in rank 3.** -/
theorem dressian_ne_tropicalGrassmannian_rank3 :
    ∃ w : PluckerVec 3 7, InDressian 3 7 w ∧ ¬ InTropicalGrassmannian3 7 w :=
  ⟨fanoWeight, fanoWeight_in_dressian, fanoWeight_not_in_tropicalGrassmannian3⟩