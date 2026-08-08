/-
# The rectangle construction: two snakes make a coil

`Novelty.SnakeConcat` glued two snakes into a longer snake.  Here the same block
decomposition `Cube (m+n) ≃ Cube m × Cube n` is used to close a *cycle*:

> **Rectangle.**  `Snake m L → Snake n M → Coil (m+n) (2L + 2M)` (for `L, M ≥ 2`).

Run the first snake `a₀ … a_L` in the first block with the second block frozen
at `b₀`; then the second snake `b₀ … b_M` with the first block frozen at `a_L`;
then the first snake *backwards* with the second block frozen at `b_M`; then the
second snake backwards with the first block frozen at `a₀`.  The four corners
`(a₀,b₀), (a_L,b₀), (a_L,b_M), (a₀,b_M)` are visited once each, and the closing
chords of the rectangle are exactly the two "long diagonals"
`hammingDist a₀ a_L ≥ 2` and `hammingDist b₀ b_M ≥ 2`, which are the chord
conditions of the two snakes at their endpoints.

Consequently the maximal coil length dominates twice the maximal snake length:

> `maxCoil_ge : 2 ≤ maxLen m → 2 ≤ maxLen n → 2 * (maxLen m + maxLen n) ≤ maxCoil (m + n)`

and with the verified seed of `Novelty.SnakeSeedSeven` this gives induced cycles
of length at least `12n - 28` in `Q n` for `n ≥ 14`, against the counting
ceiling `3 · 2 ^ (n-2)`.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.HypercubeCoil
import Novelty.SnakeConcat
import Novelty.SnakeSeedSeven

namespace SnakeInTheBox

open Finset

variable {m n L M : ℕ}

/-! ## The index maps of the rectangle -/

/-- The index into the first snake at position `k` of the rectangle. -/
def rectF (L M k : ℕ) : ℕ :=
  if k ≤ L then k else if k ≤ L + M then L else if k ≤ 2 * L + M then 2 * L + M - k else 0

/-- The index into the second snake at position `k` of the rectangle. -/
def rectG (L M k : ℕ) : ℕ :=
  if k ≤ L then 0 else if k ≤ L + M then k - L else if k ≤ 2 * L + M then M
  else 2 * L + 2 * M - k

theorem rectF_le (L M k : ℕ) : rectF L M k ≤ L := by
  unfold rectF; split_ifs <;> omega

theorem rectG_le (L M k : ℕ) : rectG L M k ≤ M := by
  unfold rectG; split_ifs <;> omega

theorem rectF_one {k : ℕ} (h : k ≤ L) : rectF L M k = k := by
  unfold rectF; rw [if_pos h]

theorem rectG_one {k : ℕ} (h : k ≤ L) : rectG L M k = 0 := by
  unfold rectG; rw [if_pos h]

theorem rectF_two {k : ℕ} (h1 : L < k) (h2 : k ≤ L + M) : rectF L M k = L := by
  unfold rectF; rw [if_neg (by omega), if_pos h2]

theorem rectG_two {k : ℕ} (h1 : L < k) (h2 : k ≤ L + M) : rectG L M k = k - L := by
  unfold rectG; rw [if_neg (by omega), if_pos h2]

theorem rectF_three {k : ℕ} (h1 : L + M < k) (h2 : k ≤ 2 * L + M) :
    rectF L M k = 2 * L + M - k := by
  unfold rectF; rw [if_neg (by omega), if_neg (by omega), if_pos h2]

theorem rectG_three {k : ℕ} (h1 : L + M < k) (h2 : k ≤ 2 * L + M) : rectG L M k = M := by
  unfold rectG; rw [if_neg (by omega), if_neg (by omega), if_pos h2]

theorem rectF_four {k : ℕ} (h : 2 * L + M < k) : rectF L M k = 0 := by
  unfold rectF; rw [if_neg (by omega), if_neg (by omega), if_neg (by omega)]

theorem rectG_four {k : ℕ} (h : 2 * L + M < k) : rectG L M k = 2 * L + 2 * M - k := by
  unfold rectG; rw [if_neg (by omega), if_neg (by omega), if_neg (by omega)]

/-- The vertex sequence of the rectangle. -/
def rectV (s : Snake m L) (t : Snake n M) : ℕ → Cube (m + n) := fun k =>
  cappend (s.v (rectF L M k)) (t.v (rectG L M k))

/-! ## Distance estimates for the rectangle -/

theorem rect_dist_of_ne (s : Snake m L) (t : Snake n M) {i j : ℕ}
    (ha : rectF L M i ≠ rectF L M j) (hb : rectG L M i ≠ rectG L M j) :
    2 ≤ hammingDist (rectV s t i) (rectV s t j) := by
  have h1 : 1 ≤ hammingDist (s.v (rectF L M i)) (s.v (rectF L M j)) :=
    s.one_le_hammingDist (rectF_le L M i) (rectF_le L M j) ha
  have h2 : 1 ≤ hammingDist (t.v (rectG L M i)) (t.v (rectG L M j)) :=
    t.one_le_hammingDist (rectG_le L M i) (rectG_le L M j) hb
  rw [rectV, rectV, hammingDist_cappend]
  omega

theorem rect_dist_of_chordA (s : Snake m L) (t : Snake n M) {i j : ℕ}
    (h : rectF L M i + 2 ≤ rectF L M j) :
    2 ≤ hammingDist (rectV s t i) (rectV s t j) := by
  have h1 := s.chord (rectF L M i) (rectF L M j) (rectF_le L M j) h
  rw [rectV, rectV, hammingDist_cappend]
  omega

theorem rect_dist_of_chordA' (s : Snake m L) (t : Snake n M) {i j : ℕ}
    (h : rectF L M j + 2 ≤ rectF L M i) :
    2 ≤ hammingDist (rectV s t i) (rectV s t j) := by
  have h1 := s.chord (rectF L M j) (rectF L M i) (rectF_le L M i) h
  rw [hammingDist_comm] at h1
  rw [rectV, rectV, hammingDist_cappend]
  omega

theorem rect_dist_of_chordB (s : Snake m L) (t : Snake n M) {i j : ℕ}
    (h : rectG L M i + 2 ≤ rectG L M j) :
    2 ≤ hammingDist (rectV s t i) (rectV s t j) := by
  have h1 := t.chord (rectG L M i) (rectG L M j) (rectG_le L M j) h
  rw [rectV, rectV, hammingDist_cappend]
  omega

theorem rect_dist_of_chordB' (s : Snake m L) (t : Snake n M) {i j : ℕ}
    (h : rectG L M j + 2 ≤ rectG L M i) :
    2 ≤ hammingDist (rectV s t i) (rectV s t j) := by
  have h1 := t.chord (rectG L M j) (rectG L M i) (rectG_le L M i) h
  rw [hammingDist_comm] at h1
  rw [rectV, rectV, hammingDist_cappend]
  omega

/-! ## The rectangle is an induced cycle -/

/-- **Rectangle construction.**  Two snakes, of lengths `L ≥ 2` in `Q m` and `M ≥ 2` in
`Q n`, span an induced cycle with `2L + 2M` vertices in `Q (m + n)`. -/
def Snake.rectangle (s : Snake m L) (t : Snake n M) (hL : 2 ≤ L) (hM : 2 ≤ M) :
    Coil (m + n) (2 * L + 2 * M) where
  v := rectV s t
  hL := by omega
  step k hk := by
    rcases Nat.lt_or_ge k L with h1 | h1
    · -- along the bottom edge
      rw [rectV, rectV, rectF_one (by omega), rectG_one (by omega), rectF_one (by omega),
        rectG_one (by omega)]
      exact adj_cappend_left _ (s.step k h1)
    rcases Nat.eq_or_lt_of_le h1 with h2 | h2
    · -- the bottom-right corner
      rw [rectV, rectV, rectF_one (by omega), rectG_one (by omega), rectF_two (by omega)
        (by omega), rectG_two (by omega) (by omega)]
      have hk1 : k + 1 - L = 0 + 1 := by omega
      rw [hk1, ← h2]
      exact adj_cappend_right _ (t.step 0 (by omega))
    rcases Nat.lt_or_ge k (L + M) with h3 | h3
    · -- along the right edge
      rw [rectV, rectV, rectF_two (by omega) (by omega), rectG_two (by omega) (by omega),
        rectF_two (by omega) (by omega), rectG_two (by omega) (by omega)]
      have hk1 : k + 1 - L = (k - L) + 1 := by omega
      rw [hk1]
      exact adj_cappend_right _ (t.step (k - L) (by omega))
    rcases Nat.eq_or_lt_of_le h3 with h4 | h4
    · -- the top-right corner
      rw [rectV, rectV, rectF_two (by omega) (by omega), rectG_two (by omega) (by omega),
        rectF_three (by omega) (by omega), rectG_three (by omega) (by omega)]
      have hk1 : 2 * L + M - (k + 1) = L - 1 := by omega
      have hk2 : k - L = M := by omega
      rw [hk1, hk2]
      refine adj_cappend_left _ (adj_symm ?_)
      have hs := s.step (L - 1) (by omega)
      have : L - 1 + 1 = L := by omega
      rwa [this] at hs
    rcases Nat.lt_or_ge k (2 * L + M) with h5 | h5
    · -- along the top edge, travelling backwards
      rw [rectV, rectV, rectF_three (by omega) (by omega), rectG_three (by omega) (by omega),
        rectF_three (by omega) (by omega), rectG_three (by omega) (by omega)]
      refine adj_cappend_left _ (adj_symm ?_)
      have hs := s.step (2 * L + M - (k + 1)) (by omega)
      have : 2 * L + M - (k + 1) + 1 = 2 * L + M - k := by omega
      rwa [this] at hs
    rcases Nat.eq_or_lt_of_le h5 with h6 | h6
    · -- the top-left corner
      rw [rectV, rectV, rectF_three (by omega) (by omega), rectG_three (by omega) (by omega),
        rectF_four (by omega), rectG_four (by omega)]
      have hk1 : 2 * L + M - k = 0 := by omega
      have hk2 : 2 * L + 2 * M - (k + 1) = M - 1 := by omega
      rw [hk1, hk2]
      refine adj_cappend_right _ (adj_symm ?_)
      have ht := t.step (M - 1) (by omega)
      have : M - 1 + 1 = M := by omega
      rwa [this] at ht
    · -- along the left edge, travelling backwards
      rw [rectV, rectV, rectF_four (by omega), rectG_four (by omega), rectF_four (by omega),
        rectG_four (by omega)]
      refine adj_cappend_right _ (adj_symm ?_)
      have ht := t.step (2 * L + 2 * M - (k + 1)) (by omega)
      have : 2 * L + 2 * M - (k + 1) + 1 = 2 * L + 2 * M - k := by omega
      rwa [this] at ht
  close := by
    rw [rectV, rectV, rectF_four (by omega), rectG_four (by omega), rectF_one (by omega),
      rectG_one (by omega)]
    have hk : 2 * L + 2 * M - (2 * L + 2 * M - 1) = 1 := by omega
    rw [hk]
    exact adj_cappend_right _ (adj_symm (t.step 0 (by omega)))
  chord i j hij hjlt hcyc := by
    -- `i` and `j` are placed in one of the four sides of the rectangle
    rcases Nat.lt_or_ge j (L + 1) with hj1 | hj1
    · -- both on the bottom edge
      refine rect_dist_of_chordA s t ?_
      rw [rectF_one (k := i) (by omega), rectF_one (k := j) (by omega)]
      omega
    rcases Nat.lt_or_ge j (L + M + 1) with hj2 | hj2
    · -- `j` on the right edge
      rcases Nat.lt_or_ge i L with hi | hi
      · refine rect_dist_of_ne s t ?_ ?_
        · rw [rectF_one (k := i) (by omega), rectF_two (k := j) (by omega) (by omega)]; omega
        · rw [rectG_one (k := i) (by omega), rectG_two (k := j) (by omega) (by omega)]; omega
      rcases Nat.eq_or_lt_of_le hi with hiL | hiL
      · refine rect_dist_of_chordB s t ?_
        rw [rectG_one (k := i) (by omega), rectG_two (k := j) (by omega) (by omega)]
        omega
      · refine rect_dist_of_chordB s t ?_
        rw [rectG_two (k := i) (by omega) (by omega), rectG_two (k := j) (by omega) (by omega)]
        omega
    rcases Nat.lt_or_ge j (2 * L + M + 1) with hj3 | hj3
    · -- `j` on the top edge
      rcases Nat.lt_or_ge i (L + 1) with hi | hi
      · refine rect_dist_of_chordB s t ?_
        rw [rectG_one (k := i) (by omega), rectG_three (k := j) (by omega) (by omega)]
        omega
      rcases Nat.lt_or_ge i (L + M) with hi2 | hi2
      · refine rect_dist_of_ne s t ?_ ?_
        · rw [rectF_two (k := i) (by omega) (by omega),
            rectF_three (k := j) (by omega) (by omega)]
          omega
        · rw [rectG_two (k := i) (by omega) (by omega),
            rectG_three (k := j) (by omega) (by omega)]
          omega
      rcases Nat.eq_or_lt_of_le hi2 with hi3 | hi3
      · refine rect_dist_of_chordA' s t ?_
        rw [rectF_two (k := i) (by omega) (by omega), rectF_three (k := j) (by omega) (by omega)]
        omega
      · refine rect_dist_of_chordA' s t ?_
        rw [rectF_three (k := i) (by omega) (by omega), rectF_three (k := j) (by omega) (by omega)]
        omega
    · -- `j` on the left edge
      rcases Nat.lt_or_ge i (L + 1) with hi | hi
      · rcases Nat.eq_or_lt_of_le (Nat.zero_le i) with hi0 | hi0
        · refine rect_dist_of_chordB s t ?_
          rw [rectG_one (k := i) (by omega), rectG_four (k := j) (by omega)]
          omega
        · refine rect_dist_of_ne s t ?_ ?_
          · rw [rectF_one (k := i) (by omega), rectF_four (k := j) (by omega)]; omega
          · rw [rectG_one (k := i) (by omega), rectG_four (k := j) (by omega)]; omega
      rcases Nat.lt_or_ge i (L + M + 1) with hi2 | hi2
      · refine rect_dist_of_chordA' s t ?_
        rw [rectF_two (k := i) (by omega) (by omega), rectF_four (k := j) (by omega)]
        omega
      rcases Nat.lt_or_ge i (2 * L + M) with hi3 | hi3
      · refine rect_dist_of_ne s t ?_ ?_
        · rw [rectF_three (k := i) (by omega) (by omega), rectF_four (k := j) (by omega)]; omega
        · rw [rectG_three (k := i) (by omega) (by omega), rectG_four (k := j) (by omega)]; omega
      rcases Nat.eq_or_lt_of_le hi3 with hi4 | hi4
      · refine rect_dist_of_chordB' s t ?_
        rw [rectG_three (k := i) (by omega) (by omega), rectG_four (k := j) (by omega)]
        omega
      · refine rect_dist_of_chordB' s t ?_
        rw [rectG_four (k := i) (by omega), rectG_four (k := j) (by omega)]
        omega

/-! ## Consequences for the maximal coil length -/

/-- **Coils from snakes.**  The maximal induced cycle length dominates twice the sum of the
maximal snake lengths of a splitting of the dimension. -/
theorem maxCoil_ge_two_mul (hm : 2 ≤ maxLen m) (hn : 2 ≤ maxLen n) :
    2 * (maxLen m + maxLen n) ≤ maxCoil (m + n) := by
  obtain ⟨s⟩ := exists_snake_maxLen m
  obtain ⟨t⟩ := exists_snake_maxLen n
  have h := le_maxCoil (s.rectangle t hm hn)
  omega

/-- **Linear lower bound for coils, slope twelve.**  For `n ≥ 14` the cube `Q n` contains
an induced cycle with at least `12n - 28` vertices. -/
theorem maxCoil_lower_twelve (hn : 14 ≤ n) : 12 * n ≤ maxCoil n + 28 := by
  obtain ⟨k, rfl⟩ : ∃ k, n = 7 + k := ⟨n - 7, by omega⟩
  have hk : 7 ≤ k := by omega
  have h7 : 47 ≤ maxLen 7 := maxLen_seven_ge
  have hkk : 6 * k ≤ maxLen k + 19 := maxLen_lower_six_slope hk
  have h := maxCoil_ge_two_mul (m := 7) (n := k) (by omega) (by omega)
  omega

/-- The two-sided picture for induced cycles: a linear lower bound of slope twelve
against the counting ceiling. -/
theorem maxCoil_final_picture (hn : 14 ≤ n) :
    12 * n ≤ maxCoil n + 28 ∧ maxCoil n ≤ 3 * 2 ^ (n - 2) :=
  ⟨maxCoil_lower_twelve hn, maxCoil_upper (by omega)⟩

end SnakeInTheBox