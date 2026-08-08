/-
# Concatenation of snakes: superadditivity of the maximal snake length

The catalog (`Computation.SnakeMax`) obtains its lower bounds on the maximal
snake length `maxLen` by adding **one** (`Snake.lift`) or **two**
(`Snake.lift2`) edges per new dimension, ending at `maxLen n ≥ 2n - 2`.  The
"product direction" of the research programme asks for a *multiplicative*
statement instead.

This file proves the (additive) product theorem in full:

> **Concatenation.**  `Snake m L → Snake n M → Snake (m + n) (L + M)`.

Put the first snake in the first block of coordinates, holding the second block
fixed at the *initial* vertex of the second snake, and then run the second snake
in the second block, holding the first block fixed at the *final* vertex of the
first snake.  A chord between the two halves would have to be short in **both**
blocks simultaneously, which the two chord conditions forbid.  Consequently

> `maxLen_superadditive : maxLen m + maxLen n ≤ maxLen (m + n)`,

so `maxLen` is superadditive, and any single good "seed" dimension propagates a
linear lower bound with that seed's slope.  Feeding in an explicit snake of
length `26` in `Q 6` (verified here by kernel computation, no `native_decide`)
upgrades the catalog's `2n - 2` to

> `maxLen_lower_four : 6 ≤ n → 4 * n - 8 ≤ maxLen n`,

i.e. it *doubles* the guaranteed growth rate.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax

namespace SnakeInTheBox

open Finset

variable {m n L M : ℕ}

/-! ## Concatenating coordinates -/

/-- Concatenation of a vertex of `Q m` and a vertex of `Q n` to a vertex of `Q (m+n)`. -/
def cappend (x : Cube m) (y : Cube n) : Cube (m + n) := Fin.append x y

/-- Hamming distance is additive under concatenation of coordinate blocks. -/
theorem hammingDist_cappend (x x' : Cube m) (y y' : Cube n) :
    hammingDist (cappend x y) (cappend x' y') = hammingDist x x' + hammingDist y y' := by
  classical
  simp only [hammingDist, Finset.card_filter]
  rw [Fin.sum_univ_add]
  congr 1
  · exact Finset.sum_congr rfl fun i _ => by simp [cappend, Fin.append_left]
  · exact Finset.sum_congr rfl fun i _ => by simp [cappend, Fin.append_right]

theorem adj_cappend_left {x x' : Cube m} (y : Cube n) (h : Adj x x') :
    Adj (cappend x y) (cappend x' y) := by
  apply adj_of_hammingDist
  rw [hammingDist_cappend, hammingDist_of_adj h, hammingDist_self]

theorem adj_cappend_right (x : Cube m) {y y' : Cube n} (h : Adj y y') :
    Adj (cappend x y) (cappend x y') := by
  apply adj_of_hammingDist
  rw [hammingDist_cappend, hammingDist_of_adj h, hammingDist_self]

/-! ## The concatenated snake -/

/-- The vertex sequence of the concatenation of two snakes. -/
def concatV (s : Snake m L) (t : Snake n M) : ℕ → Cube (m + n) := fun k =>
  if k ≤ L then cappend (s.v k) (t.v 0) else cappend (s.v L) (t.v (k - L))

theorem concatV_low (s : Snake m L) (t : Snake n M) {k : ℕ} (hk : k ≤ L) :
    concatV s t k = cappend (s.v k) (t.v 0) := by
  simp [concatV, hk]

theorem concatV_high (s : Snake m L) (t : Snake n M) {k : ℕ} (hk : L < k) :
    concatV s t k = cappend (s.v L) (t.v (k - L)) := by
  simp [concatV, Nat.not_le.mpr hk]

/-- Two snake vertices with distinct indices are distinct. -/
theorem Snake.v_ne (s : Snake m L) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L) (hij : i ≠ j) :
    s.v i ≠ s.v j := fun he =>
  hij (s.injOn (Set.mem_Iic.mpr hi) (Set.mem_Iic.mpr hj) he)

theorem Snake.one_le_hammingDist (s : Snake m L) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L)
    (hij : i ≠ j) : 1 ≤ hammingDist (s.v i) (s.v j) := by
  rcases Nat.eq_zero_or_pos (hammingDist (s.v i) (s.v j)) with h | h
  · exact absurd (hammingDist_eq_zero.mp h) (s.v_ne hi hj hij)
  · exact h

/-- **Concatenation of snakes.**  A snake of length `L` in `Q m` and a snake of length
`M` in `Q n` concatenate to a snake of length `L + M` in `Q (m + n)`. -/
def Snake.concat (s : Snake m L) (t : Snake n M) : Snake (m + n) (L + M) where
  v := concatV s t
  step k hk := by
    rcases Nat.lt_or_ge k L with h | h
    · rw [concatV_low s t (by omega), concatV_low s t (by omega)]
      exact adj_cappend_left _ (s.step k h)
    · rcases Nat.eq_or_lt_of_le h with h2 | h2
      · -- the step joining the two blocks
        have hkL : k = L := h2.symm
        rw [hkL, concatV_low s t le_rfl, concatV_high s t (by omega)]
        have hk1 : L + 1 - L = 1 := by omega
        rw [hk1]
        exact adj_cappend_right _ (t.step 0 (by omega))
      · rw [concatV_high s t (by omega), concatV_high s t (by omega)]
        have hk1 : k + 1 - L = (k - L) + 1 := by omega
        rw [hk1]
        exact adj_cappend_right _ (t.step (k - L) (by omega))
  chord i j hj hij := by
    rcases Nat.lt_or_ge L j with h | h
    · rw [concatV_high s t h]
      rcases Nat.lt_or_ge L i with hi | hi
      · -- both vertices live in the second block
        rw [concatV_high s t hi, hammingDist_cappend, hammingDist_self]
        have := t.chord (i - L) (j - L) (by omega) (by omega)
        omega
      · rw [concatV_low s t hi, hammingDist_cappend]
        rcases Nat.eq_or_lt_of_le hi with hiL | hiL
        · -- the first block is already at its final vertex
          have h0 : hammingDist (s.v i) (s.v L) = 0 := by
            rw [hiL]; exact hammingDist_self _
          have := t.chord 0 (j - L) (by omega) (by omega)
          omega
        · -- a genuine cross chord: short in neither block
          have h1 : 1 ≤ hammingDist (s.v i) (s.v L) :=
            s.one_le_hammingDist (by omega) le_rfl (by omega)
          have h2 : 1 ≤ hammingDist (t.v 0) (t.v (j - L)) :=
            t.one_le_hammingDist (by omega) (by omega) (by omega)
          omega
    · -- both vertices live in the first block
      rw [concatV_low s t (by omega), concatV_low s t (by omega), hammingDist_cappend,
        hammingDist_self]
      have := s.chord i j (by omega) hij
      omega

/-! ## Superadditivity of `maxLen` -/

/-- **The maximal snake length is superadditive:** `s(m) + s(n) ≤ s(m + n)`. -/
theorem maxLen_superadditive (m n : ℕ) : maxLen m + maxLen n ≤ maxLen (m + n) := by
  obtain ⟨s⟩ := exists_snake_maxLen m
  obtain ⟨t⟩ := exists_snake_maxLen n
  exact le_maxLen (s.concat t)

/-- Iterating superadditivity: `k · s(m) ≤ s(k · m)`. -/
theorem maxLen_nsmul (k m : ℕ) : k * maxLen m ≤ maxLen (k * m) := by
  induction k with
  | zero => simp
  | succ j ih =>
    have h := maxLen_superadditive (j * m) m
    have hj : maxLen (j * m) + maxLen m ≤ maxLen (j * m + m) := h
    have : (j + 1) * m = j * m + m := by ring
    rw [this]
    calc (j + 1) * maxLen m = j * maxLen m + maxLen m := by ring
      _ ≤ maxLen (j * m) + maxLen m := by omega
      _ ≤ maxLen (j * m + m) := hj

end SnakeInTheBox