/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Hamming Distance and Error-Correcting Code Combinatorics

This file establishes the combinatorial foundation for ECOC (Error-Correcting Output Code)
robustness: Hamming distance on binary codewords, minimum distance of codes, triangle
inequality, and the nearest-codeword uniqueness theorem.

## Main results

- `ECOC.hammingDist_triangle`: Triangle inequality for Hamming distance on `Fin m → Bool`.
- `ECOC.nearest_codeword_unique_of_lt_half_minDist`: If a word is within Hamming distance
  less than half the minimum code distance from codeword `c`, then `c` is the unique
  nearest codeword.
-/
import Mathlib

open Finset

namespace ECOC

/-! ## Hamming distance -/

/-- Hamming distance between two binary words of length `m`. -/
def hammingDist {m : ℕ} (u v : Fin m → Bool) : ℕ :=
  (Finset.univ.filter fun j => u j ≠ v j).card

/-- The Hamming distance is symmetric. -/
theorem hammingDist_comm {m : ℕ} (u v : Fin m → Bool) :
    hammingDist u v = hammingDist v u := by
  unfold hammingDist
  congr 1; ext j; simp [ne_comm]

/-- Hamming distance to self is zero. -/
theorem hammingDist_self {m : ℕ} (u : Fin m → Bool) :
    hammingDist u u = 0 := by
  unfold hammingDist; simp

/-- Triangle inequality for Hamming distance. -/
theorem hammingDist_triangle {m : ℕ} (u v w : Fin m → Bool) :
    hammingDist u w ≤ hammingDist u v + hammingDist v w := by
  unfold hammingDist
  calc (univ.filter fun j => u j ≠ w j).card
      ≤ ((univ.filter fun j => u j ≠ v j) ∪ (univ.filter fun j => v j ≠ w j)).card := by
        apply Finset.card_le_card
        intro j
        simp only [mem_filter, mem_union, mem_univ, true_and]
        intro huw
        by_cases huv : u j = v j
        · right; rw [← huv]; exact huw
        · left; exact huv
    _ ≤ (univ.filter fun j => u j ≠ v j).card +
        (univ.filter fun j => v j ≠ w j).card :=
        Finset.card_union_le _ _

/-! ## Code distance and nearest codeword -/

/-- Minimum distance property: all distinct codewords are at least `δ` apart. -/
def MinDistAtLeast {n m : ℕ} (code : Fin n → Fin m → Bool) (δ : ℕ) : Prop :=
  ∀ c c' : Fin n, c ≠ c' → δ ≤ hammingDist (code c) (code c')

/-- A codeword `c` is the unique nearest to word `y`. -/
def nearestUnique {n m : ℕ} (code : Fin n → Fin m → Bool)
    (y : Fin m → Bool) (c : Fin n) : Prop :=
  ∀ c' : Fin n, c' ≠ c → hammingDist y (code c) < hammingDist y (code c')

/-- **Nearest codeword uniqueness**: if `y` is within half the minimum distance
of codeword `c`, then `c` is the unique nearest codeword. Uses the
formulation `2 * d < δ` to avoid `Nat.div` awkwardness. -/
theorem nearest_codeword_unique_of_lt_half_minDist
    {n m δ : ℕ} {code : Fin n → Fin m → Bool}
    (hδ : MinDistAtLeast code δ)
    {c : Fin n} {y : Fin m → Bool}
    (hy : 2 * hammingDist y (code c) < δ) :
    nearestUnique code y c := by
  intro c' hc'
  have hmin := hδ c c' (Ne.symm hc')
  have htri := hammingDist_triangle (code c) y (code c')
  rw [hammingDist_comm (code c) y] at htri
  omega

/-- The disagreement set between two codewords. -/
def disagreeSet {n m : ℕ} (code : Fin n → Fin m → Bool) (c c' : Fin n) : Finset (Fin m) :=
  Finset.univ.filter fun j => code c j ≠ code c' j

theorem disagreeSet_card_eq_hammingDist {n m : ℕ} (code : Fin n → Fin m → Bool)
    (c c' : Fin n) :
    (disagreeSet code c c').card = hammingDist (code c) (code c') := by
  rfl

end ECOC