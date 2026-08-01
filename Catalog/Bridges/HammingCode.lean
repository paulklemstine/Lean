import Mathlib

open Finset

namespace ECOC

/-- The Hamming distance between two Boolean words. -/
def hammingDist {m : ℕ} (x y : Fin m → Bool) : ℕ :=
  (Finset.univ.filter fun j => x j ≠ y j).card

/-- The coordinates on which two codewords disagree. -/
def disagreeSet {n m : ℕ} (code : Fin n → Fin m → Bool) (c c' : Fin n) :
    Finset (Fin m) :=
  Finset.univ.filter fun j => code c j ≠ code c' j

/-- Every pair of distinct codewords has Hamming distance at least `δ`. -/
def MinDistAtLeast {n m : ℕ} (code : Fin n → Fin m → Bool) (δ : ℕ) : Prop :=
  ∀ ⦃c c'⦄, c ≠ c' → δ ≤ hammingDist (code c) (code c')

/-- The codeword indexed by `c` is the unique nearest codeword to `y`. -/
def nearestUnique {n m : ℕ} (code : Fin n → Fin m → Bool)
    (y : Fin m → Bool) (c : Fin n) : Prop :=
  ∀ c', c' ≠ c → hammingDist y (code c) < hammingDist y (code c')

/-- A word at distance strictly less than half the minimum distance has a unique
nearest codeword. -/
theorem nearest_codeword_unique_of_lt_half_minDist
    {n m δ : ℕ} {code : Fin n → Fin m → Bool} {y : Fin m → Bool} {c : Fin n}
    (hδ : MinDistAtLeast code δ)
    (hy : 2 * hammingDist y (code c) < δ) :
    nearestUnique code y c := by
  intro c' hc'
  have hmin : δ ≤ hammingDist (code c) (code c') := hδ hc'.symm
  have htri : hammingDist (code c) (code c') ≤
      hammingDist y (code c) + hammingDist y (code c') := by
    simpa [hammingDist, hammingDist_comm] using
      (hammingDist_triangle_left (code c) (code c') y)
  omega

end ECOC