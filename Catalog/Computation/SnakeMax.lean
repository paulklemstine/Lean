/-
# Snake-in-the-Box: the maximal snake length function

This file continues the chain of results of `Computation.SnakeInTheBox`.
There the *upper* half of the picture was established (a snake in `Q n` has at
most `3 * 2 ^ (n - 2)` vertices, and in fact strictly fewer).  Here we

* record the trivial cardinality ceiling `L + 1 ≤ 2 ^ n` (Step 11),
* build the **new-coordinate extension** turning a snake of length `L` in `Q n`
  into a snake of length `L + 1` in `Q (n + 1)` (Step 12), which gives the
  linear lower bound `s(n) ≥ n + 1` for `n ≥ 3` (Step 13),
* and package both halves into the maximal snake length function
  `maxLen n = sSup {L | Nonempty (Snake n L)}`, showing that it is well defined,
  strictly increasing, that `n + 1 ≤ maxLen n < 3 * 2 ^ (n - 2) - 1` for
  `n ≥ 3`, and that `maxLen 2 = 2`, `maxLen 3 = 4` (Step 14).
-/
import Mathlib
import Computation.SnakeInTheBox

namespace SnakeInTheBox

open Finset

variable {n L : ℕ}

/-! ## Step 11: the trivial cardinality ceiling -/

/-- Two disagreeing coordinates force Hamming distance at least two. -/
theorem two_le_hammingDist_of_two_ne {x y : Cube n} {i j : Fin n} (hij : i ≠ j)
    (hi : x i ≠ y i) (hj : x j ≠ y j) : 2 ≤ hammingDist x y := by
  classical
  have hsub : ({i, j} : Finset (Fin n)) ⊆ univ.filter fun k => x k ≠ y k := by
    intro k hk
    simp only [Finset.mem_insert, Finset.mem_singleton] at hk
    rcases hk with rfl | rfl <;> simp [hi, hj]
  have hcard : ({i, j} : Finset (Fin n)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simpa using hij), Finset.card_singleton]
  have := Finset.card_le_card hsub
  rw [hcard] at this
  simpa [hammingDist] using this

/-- A snake in `Q n` has at most `2 ^ n` vertices: its vertices are distinct. -/
theorem Snake.card_le_pow (s : Snake n L) : L + 1 ≤ 2 ^ n := by
  have h1 : s.vset.card = L + 1 := s.card_vset
  have h2 : s.vset.card ≤ Fintype.card (Cube n) := by
    simpa using Finset.card_le_univ s.vset
  have h3 : Fintype.card (Cube n) = 2 ^ n := by simp
  omega

/-! ## Step 12: extension by a fresh coordinate

Embedding a snake of `Q n` into `Q (n+1)` leaves the last coordinate constantly
`false`; flipping it at the final vertex adds one more edge without creating a
chord, because the new vertex differs from every earlier vertex both in the
fresh coordinate and in some old coordinate. -/

/-- The vertex sequence of the extended snake. -/
def liftV (s : Snake n L) : ℕ → Cube (n + 1) := fun i =>
  if i ≤ L then extend n (n + 1) (s.v i)
  else flipAt (extend n (n + 1) (s.v L)) (Fin.last n)

theorem liftV_of_le (s : Snake n L) {i : ℕ} (hi : i ≤ L) :
    liftV s i = extend n (n + 1) (s.v i) := by
  simp [liftV, hi]

theorem liftV_succ (s : Snake n L) :
    liftV s (L + 1) = flipAt (extend n (n + 1) (s.v L)) (Fin.last n) := by
  simp [liftV]

/-- A snake of length `L` in `Q n` yields a snake of length `L + 1` in `Q (n+1)`. -/
def Snake.lift (s : Snake n L) : Snake (n + 1) (L + 1) where
  v := liftV s
  step i hi := by
    rcases Nat.lt_or_ge i L with h | h
    · rw [liftV_of_le s (le_of_lt h), liftV_of_le s (by omega)]
      exact adj_extend (by omega) (s.step i h)
    · have hiL : i = L := by omega
      subst hiL
      rw [liftV_of_le s le_rfl, liftV_succ]
      exact ⟨Fin.last n, rfl⟩
  chord i j hj hij := by
    rcases Nat.lt_or_ge j (L + 1) with h | h
    · rw [liftV_of_le s (by omega), liftV_of_le s (by omega),
        hammingDist_extend (by omega)]
      exact s.chord i j (by omega) hij
    · have hjL : j = L + 1 := by omega
      subst hjL
      have hiL : i ≤ L := by omega
      have hine : i ≠ L := by omega
      rw [liftV_of_le s hiL, liftV_succ]
      -- the two vertices differ in the fresh coordinate and in an old one
      have hne : s.v i ≠ s.v L := by
        intro hcontra
        exact hine (s.injOn (Set.mem_Iic.mpr hiL) (Set.mem_Iic.mpr le_rfl) hcontra)
      obtain ⟨k, hk⟩ : ∃ k : Fin n, s.v i k ≠ s.v L k := by
        by_contra hc
        push_neg at hc
        exact hne (funext hc)
      refine two_le_hammingDist_of_two_ne (i := ⟨k, by omega⟩) (j := Fin.last n) ?_ ?_ ?_
      · simp [Fin.ext_iff, Fin.last]
        omega
      · have h1 : extend n (n + 1) (s.v i) ⟨k, by omega⟩ = s.v i k := by
          simp [extend, k.isLt]
        have h2 : extend n (n + 1) (s.v L) ⟨k, by omega⟩ = s.v L k := by
          simp [extend, k.isLt]
        have h3 : flipAt (extend n (n + 1) (s.v L)) (Fin.last n) ⟨k, by omega⟩
            = extend n (n + 1) (s.v L) ⟨k, by omega⟩ := by
          refine flipAt_apply_of_ne _ ?_
          simp [Fin.ext_iff, Fin.last]
          omega
        rw [h1, h3, h2]
        exact hk
      · have h1 : extend n (n + 1) (s.v i) (Fin.last n) = false := by
          simp [extend, Fin.last]
        have h2 : extend n (n + 1) (s.v L) (Fin.last n) = false := by
          simp [extend, Fin.last]
        rw [h1, flipAt_apply_self, h2]
        simp

/-! ## Step 13: a linear lower bound on the maximal snake length -/

/-- Snakes of length `n + 1` exist in `Q n` for every `n ≥ 3`. -/
theorem exists_snake_dim : ∀ n, 3 ≤ n → Nonempty (Snake n (n + 1)) := by
  intro n
  induction n with
  | zero => intro h; omega
  | succ m ih =>
    intro _
    rcases Nat.lt_or_ge m 3 with hm | hm
    · have hm3 : m = 2 := by omega
      subst hm3
      exact ⟨snake3⟩
    · obtain ⟨s⟩ := ih hm
      exact ⟨s.lift⟩

/-! ## Step 14: the maximal snake length function -/

/-- The set of achievable snake lengths in `Q n`. -/
def snakeLengths (n : ℕ) : Set ℕ := {L | Nonempty (Snake n L)}

/-- The trivial snake with a single vertex and no edges. -/
def snakeZero (n : ℕ) : Snake n 0 where
  v _ := fun _ => false
  step i hi := absurd hi (by omega)
  chord i j hj hij := absurd hij (by omega)

theorem snakeLengths_nonempty (n : ℕ) : (snakeLengths n).Nonempty :=
  ⟨0, ⟨snakeZero n⟩⟩

theorem snakeLengths_bddAbove (n : ℕ) : BddAbove (snakeLengths n) := by
  refine ⟨2 ^ n, ?_⟩
  rintro L ⟨s⟩
  have := s.card_le_pow
  omega

/-- The maximal length of a snake in `Q n`. -/
noncomputable def maxLen (n : ℕ) : ℕ := sSup (snakeLengths n)

theorem le_maxLen (s : Snake n L) : L ≤ maxLen n :=
  le_csSup (snakeLengths_bddAbove n) ⟨s⟩

/-- The supremum is attained: there is a snake of length `maxLen n`. -/
theorem exists_snake_maxLen (n : ℕ) : Nonempty (Snake n (maxLen n)) :=
  Nat.sSup_mem (snakeLengths_nonempty n) (snakeLengths_bddAbove n)

/-- `maxLen n` is the maximum of the achievable lengths: it is achieved, and every
achievable length is at most `maxLen n`. -/
theorem maxLen_spec (n : ℕ) :
    Nonempty (Snake n (maxLen n)) ∧ ∀ L, Nonempty (Snake n L) → L ≤ maxLen n :=
  ⟨exists_snake_maxLen n, fun _ ⟨s⟩ => le_maxLen s⟩

/-- **Lower bound**: the maximal snake length grows at least linearly. -/
theorem maxLen_lower (hn : 3 ≤ n) : n + 1 ≤ maxLen n := by
  obtain ⟨s⟩ := exists_snake_dim n hn
  exact le_maxLen s

/-- **Upper bound**, from the sharpened double count of `Computation.SnakeInTheBox`. -/
theorem maxLen_upper (hn : 3 ≤ n) : maxLen n + 1 < 3 * 2 ^ (n - 2) := by
  obtain ⟨s⟩ := exists_snake_maxLen n
  exact s.card_lt hn

/-- The maximal snake length is strictly increasing in the dimension. -/
theorem maxLen_succ_ge (n : ℕ) : maxLen n + 1 ≤ maxLen (n + 1) := by
  obtain ⟨s⟩ := exists_snake_maxLen n
  exact le_maxLen s.lift

/-- `s(2) = 2`. -/
theorem maxLen_two : maxLen 2 = 2 := by
  refine le_antisymm ?_ (le_maxLen snake2)
  obtain ⟨s⟩ := exists_snake_maxLen 2
  exact s.length_le_dim_two

/-- `s(3) = 4`. -/
theorem maxLen_three : maxLen 3 = 4 := by
  refine le_antisymm ?_ (le_maxLen snake3)
  obtain ⟨s⟩ := exists_snake_maxLen 3
  exact s.length_le_dim_three

/-- Adding `k` dimensions adds at least `k` edges: a weak additive form of the product
conjecture. -/
theorem maxLen_add_le (n k : ℕ) : maxLen n + k ≤ maxLen (n + k) := by
  induction k with
  | zero => simp
  | succ m ih =>
    have h := maxLen_succ_ge (n + m)
    have : n + (m + 1) = (n + m) + 1 := by omega
    rw [this]
    omega

/-- The maximal snake length is monotone in the dimension. -/
theorem maxLen_mono : Monotone maxLen := by
  intro a b hab
  have h := maxLen_add_le a (b - a)
  have hb : a + (b - a) = b := by omega
  rw [hb] at h
  omega

/-- **Summary**: for every `n ≥ 3` the maximal snake length in `Q n` satisfies
`n + 1 ≤ maxLen n` and `maxLen n + 2 ≤ 3 * 2 ^ (n - 2)`, and it grows by at least one
with each new dimension. -/
theorem maxLen_bounds (hn : 3 ≤ n) :
    n + 1 ≤ maxLen n ∧ maxLen n + 2 ≤ 3 * 2 ^ (n - 2) ∧ maxLen n + 1 ≤ maxLen (n + 1) :=
  ⟨maxLen_lower hn, by have := maxLen_upper hn; omega, maxLen_succ_ge n⟩

/-! ## Step 15: flipping the fresh coordinate at *both* ends

One extra dimension in fact buys two extra edges, not one: prepend the vertex
obtained from `v 0` by flipping the fresh coordinate, and append the one
obtained from `v L`.  The two new vertices agree in the fresh coordinate, so
they are non-adjacent as soon as `v 0` and `v L` are, which holds whenever
`L ≥ 2`. -/

theorem flipAt_flipAt (x : Cube n) (i : Fin n) : flipAt (flipAt x i) i = x := by
  funext j
  by_cases h : j = i <;> simp [flipAt, h]

theorem hammingDist_flipAt_flipAt (x y : Cube n) (i : Fin n) :
    hammingDist (flipAt x i) (flipAt y i) = hammingDist x y := by
  unfold hammingDist
  congr 1
  ext k
  by_cases h : k = i <;> simp [flipAt, h]

/-- Flipping a fresh coordinate at one of two embedded vertices keeps them at distance
at least two, provided they were distinct. -/
theorem two_le_dist_extend_flip {x y : Cube n} (hxy : x ≠ y) :
    2 ≤ hammingDist (extend n (n + 1) x) (flipAt (extend n (n + 1) y) (Fin.last n)) := by
  obtain ⟨k, hk⟩ : ∃ k : Fin n, x k ≠ y k := by
    by_contra hc
    push_neg at hc
    exact hxy (funext hc)
  refine two_le_hammingDist_of_two_ne (i := ⟨k, by omega⟩) (j := Fin.last n) ?_ ?_ ?_
  · simp [Fin.ext_iff, Fin.last]
    omega
  · have h1 : extend n (n + 1) x ⟨k, by omega⟩ = x k := by simp [extend, k.isLt]
    have h2 : extend n (n + 1) y ⟨k, by omega⟩ = y k := by simp [extend, k.isLt]
    have h3 : flipAt (extend n (n + 1) y) (Fin.last n) ⟨k, by omega⟩
        = extend n (n + 1) y ⟨k, by omega⟩ := by
      refine flipAt_apply_of_ne _ ?_
      simp [Fin.ext_iff, Fin.last]
      omega
    rw [h1, h3, h2]; exact hk
  · have h1 : extend n (n + 1) x (Fin.last n) = false := by simp [extend, Fin.last]
    have h2 : extend n (n + 1) y (Fin.last n) = false := by simp [extend, Fin.last]
    rw [h1, flipAt_apply_self, h2]
    simp

/-- The vertex sequence of the doubly extended snake. -/
def lift2V (s : Snake n L) : ℕ → Cube (n + 1) := fun i =>
  if i = 0 then flipAt (extend n (n + 1) (s.v 0)) (Fin.last n)
  else if i ≤ L + 1 then extend n (n + 1) (s.v (i - 1))
  else flipAt (extend n (n + 1) (s.v L)) (Fin.last n)

theorem lift2V_zero (s : Snake n L) :
    lift2V s 0 = flipAt (extend n (n + 1) (s.v 0)) (Fin.last n) := by
  simp [lift2V]

theorem lift2V_mid (s : Snake n L) {i : ℕ} (h0 : i ≠ 0) (hi : i ≤ L + 1) :
    lift2V s i = extend n (n + 1) (s.v (i - 1)) := by
  simp [lift2V, h0, hi]

theorem lift2V_last (s : Snake n L) :
    lift2V s (L + 2) = flipAt (extend n (n + 1) (s.v L)) (Fin.last n) := by
  simp [lift2V]

/-- A snake of length `L ≥ 2` in `Q n` yields a snake of length `L + 2` in `Q (n+1)`. -/
def Snake.lift2 (s : Snake n L) (hL : 2 ≤ L) : Snake (n + 1) (L + 2) where
  v := lift2V s
  step i hi := by
    rcases Nat.eq_zero_or_pos i with rfl | hpos
    · rw [lift2V_zero, lift2V_mid s (by omega) (by omega)]
      exact ⟨Fin.last n, (flipAt_flipAt _ _).symm⟩
    · rcases Nat.lt_or_ge i (L + 1) with h | h
      · rw [lift2V_mid s (by omega) (by omega), lift2V_mid s (by omega) (by omega)]
        have : i + 1 - 1 = (i - 1) + 1 := by omega
        rw [this]
        exact adj_extend (by omega) (s.step (i - 1) (by omega))
      · have hiL : i = L + 1 := by omega
        subst hiL
        rw [lift2V_mid s (by omega) (by omega), lift2V_last]
        exact ⟨Fin.last n, rfl⟩
  chord i j hj hij := by
    rcases Nat.eq_zero_or_pos i with rfl | hpos
    · -- the prepended vertex versus the rest
      rcases Nat.lt_or_ge j (L + 2) with h | h
      · rw [lift2V_zero, lift2V_mid s (by omega) (by omega)]
        have hne : s.v (j - 1) ≠ s.v 0 := by
          intro hc
          have := s.injOn (Set.mem_Iic.mpr (by omega : j - 1 ≤ L))
            (Set.mem_Iic.mpr (by omega : (0 : ℕ) ≤ L)) hc
          omega
        have := two_le_dist_extend_flip (n := n) hne
        rw [hammingDist_comm] at this
        exact this
      · have hjL : j = L + 2 := by omega
        subst hjL
        rw [lift2V_zero, lift2V_last, hammingDist_flipAt_flipAt,
          hammingDist_extend (by omega)]
        exact s.chord 0 L le_rfl (by omega)
    · rcases Nat.lt_or_ge j (L + 2) with h | h
      · rw [lift2V_mid s (by omega) (by omega), lift2V_mid s (by omega) (by omega),
          hammingDist_extend (by omega)]
        exact s.chord (i - 1) (j - 1) (by omega) (by omega)
      · have hjL : j = L + 2 := by omega
        subst hjL
        rw [lift2V_mid s (by omega) (by omega), lift2V_last]
        refine two_le_dist_extend_flip ?_
        intro hc
        have := s.injOn (Set.mem_Iic.mpr (by omega : i - 1 ≤ L))
          (Set.mem_Iic.mpr (le_refl L)) hc
        omega

/-- Each new dimension buys at least two extra edges, once the snake is long enough. -/
theorem maxLen_succ_ge_two (hn : 3 ≤ n) : maxLen n + 2 ≤ maxLen (n + 1) := by
  obtain ⟨s⟩ := exists_snake_maxLen n
  have h2 : 2 ≤ maxLen n := le_trans (by omega) (maxLen_lower hn)
  exact le_maxLen (s.lift2 h2)

/-- **Improved lower bound**: `s(n) ≥ 2n − 2` for `n ≥ 3`. -/
theorem maxLen_lower_strong : ∀ n, 3 ≤ n → 2 * n - 2 ≤ maxLen n := by
  intro n
  induction n with
  | zero => intro h; omega
  | succ m ih =>
    intro _
    rcases Nat.lt_or_ge m 3 with hm | hm
    · have hm3 : m = 2 := by omega
      subst hm3
      simp [maxLen_three]
    · have h1 := ih hm
      have h2 := maxLen_succ_ge_two hm
      omega

/-- **Final summary**: for every `n ≥ 3`,
`2n − 2 ≤ maxLen n` and `maxLen n + 2 ≤ 3 · 2 ^ (n − 2)`. -/
theorem maxLen_final_bounds (hn : 3 ≤ n) :
    2 * n - 2 ≤ maxLen n ∧ maxLen n + 2 ≤ 3 * 2 ^ (n - 2) :=
  ⟨maxLen_lower_strong n hn, (maxLen_bounds hn).2.1⟩

end SnakeInTheBox