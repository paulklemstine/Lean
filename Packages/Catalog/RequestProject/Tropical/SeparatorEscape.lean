import Mathlib

/-!
# Separator-coordinate escape theorem for snake products

A *snake* (snake-in-the-box) of length `L` in a hypercube `ι → Bool` is a sequence of
vertices `p 0, …, p L` such that consecutive vertices are at Hamming distance `1`
and non-consecutive vertices are at Hamming distance at least `2` (an induced path).

Main results:

* `SnakeEscape.separator_escape` : two extra coordinates suffice.  From snakes of lengths
  `L` in `Q_m` and `K` in `Q_n` we build a snake of length `K * (L + 2) + L`
  `= (L+1)(K+1) + K - 1` in `Q_{m+n+2}`.  In particular the multiplicative main term
  `(L+1)(K+1)` is recovered exactly, with no `o(LK)` loss (`separator_escape_main_term`).

* `SnakeEscape.cell_separator_no_gain` : a no-go result.  If the separator bits are a
  function `b (i, j)` of the product cell only, then they are constant along any snake,
  and the projection to `Q_{m+n}` is already a snake of the same length.  So a pure
  per-cell separator pattern can never beat the unseparated product; the escape
  construction necessarily visits some cells twice with different separator values.
-/

namespace SnakeEscape

open Finset

/-- A snake of length `L` in the hypercube `ι → Bool`: an induced path `p 0, …, p L`. -/
def IsSnake {ι : Type*} [Fintype ι] (p : ℕ → ι → Bool) (L : ℕ) : Prop :=
  ∀ i j, i < j → j ≤ L →
    (j = i + 1 → hammingDist (p i) (p j) = 1) ∧ (i + 1 < j → 2 ≤ hammingDist (p i) (p j))

/-- Hamming distance is additive over a disjoint union of coordinate blocks. -/
theorem hammingDist_sumElim {ι κ : Type*} [Fintype ι] [Fintype κ]
    (x x' : ι → Bool) (y y' : κ → Bool) :
    hammingDist (Sum.elim x y) (Sum.elim x' y') = hammingDist x x' + hammingDist y y' := by
  simp only [hammingDist, Finset.card_filter, Fintype.sum_sum_type, Sum.elim_inl,
    Sum.elim_inr]
  rfl

/-- Hamming distance is invariant under relabelling the coordinates. -/
theorem hammingDist_comp_equiv {ι κ : Type*} [Fintype ι] [Fintype κ] (e : κ ≃ ι)
    (x x' : ι → Bool) : hammingDist (x ∘ e) (x' ∘ e) = hammingDist x x' := by
  simp only [hammingDist, Finset.card_filter, Function.comp]
  exact Equiv.sum_comp e (fun i => if x i ≠ x' i then 1 else 0)

theorem IsSnake.comp_equiv {ι κ : Type*} [Fintype ι] [Fintype κ] (e : κ ≃ ι)
    {p : ℕ → ι → Bool} {L : ℕ} (hp : IsSnake p L) : IsSnake (fun k => p k ∘ e) L := by
  intro i j hij hj
  simp only [hammingDist_comp_equiv]
  exact hp i j hij hj

section snakeFacts

variable {ι : Type*} [Fintype ι] {p : ℕ → ι → Bool} {L : ℕ}

theorem IsSnake.dist_one (hp : IsSnake p L) {i : ℕ} (hi : i + 1 ≤ L) :
    hammingDist (p i) (p (i + 1)) = 1 :=
  (hp i (i + 1) (by omega) hi).1 rfl

theorem IsSnake.dist_pos (hp : IsSnake p L) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L)
    (hne : i ≠ j) : 1 ≤ hammingDist (p i) (p j) := by
  rcases lt_or_gt_of_ne hne with h | h
  · by_cases h1 : j = i + 1
    · exact ((hp i j h hj).1 h1).ge
    · exact le_trans (by norm_num) ((hp i j h hj).2 (by omega))
  · rw [hammingDist_comm]
    by_cases h1 : i = j + 1
    · exact ((hp j i h hi).1 h1).ge
    · exact le_trans (by norm_num) ((hp j i h hi).2 (by omega))

theorem IsSnake.dist_two (hp : IsSnake p L) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L)
    (h : i + 2 ≤ j ∨ j + 2 ≤ i) : 2 ≤ hammingDist (p i) (p j) := by
  rcases h with h | h
  · exact (hp i j (by omega) hj).2 (by omega)
  · rw [hammingDist_comm]; exact (hp j i (by omega) hi).2 (by omega)

theorem IsSnake.injOn (hp : IsSnake p L) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L)
    (h : p i = p j) : i = j := by
  by_contra hne
  have := hp.dist_pos hi hj hne
  rw [h, hammingDist_self] at this
  omega

end snakeFacts

/-! ### The two separator coordinates: a cyclic Gray code on `Q_2` -/

/-- The cyclic Gray code `00, 10, 11, 01, 00, …` on the 2-cube, indexed by `ℕ`. -/
def gray (a : ℕ) : Fin 2 → Bool :=
  ![decide (a % 4 = 1 ∨ a % 4 = 2), decide (2 ≤ a % 4)]

theorem gray_dist_succ (a : ℕ) : hammingDist (gray a) (gray (a + 1)) = 1 := by
  have h : (a + 1) % 4 = (a % 4 + 1) % 4 := by omega
  unfold gray
  rw [h]
  have ht : a % 4 < 4 := Nat.mod_lt _ (by norm_num)
  generalize a % 4 = t at ht ⊢
  interval_cases t <;> decide

theorem gray_dist_two (a : ℕ) : hammingDist (gray a) (gray (a + 2)) = 2 := by
  have h : (a + 2) % 4 = (a % 4 + 2) % 4 := by omega
  unfold gray
  rw [h]
  have ht : a % 4 < 4 := Nat.mod_lt _ (by norm_num)
  generalize a % 4 = t at ht ⊢
  interval_cases t <;> decide

/-! ### The escape construction -/

/-- Column visited at position `r` of row `j` (boustrophedon order; position `L+1` is the
connector, which sits above the last column of the row). -/
def colOf (L j r : ℕ) : ℕ := if j % 2 = 0 then min r L else L - min r L

/-- Gray-code layer used at position `r` of row `j`: rows use layer `j`, the connector
already uses the layer `j + 1` of the next row. -/
def layerOf (L j r : ℕ) : ℕ := if r ≤ L then j else j + 1

/-- The vertex at position `r` of row `j`, in `(ι ⊕ κ) ⊕ Fin 2 → Bool`. -/
def gridV {ι κ : Type*} (p : ℕ → ι → Bool) (q : ℕ → κ → Bool) (L j r : ℕ) :
    (ι ⊕ κ) ⊕ Fin 2 → Bool :=
  Sum.elim (Sum.elim (p (colOf L j r)) (q j)) (gray (layerOf L j r))

/-- The escape snake: row `j` occupies indices `j*(L+2), …, j*(L+2) + L + 1`. -/
def escapeSnake {ι κ : Type*} (p : ℕ → ι → Bool) (q : ℕ → κ → Bool) (L k : ℕ) :
    (ι ⊕ κ) ⊕ Fin 2 → Bool :=
  gridV p q L (k / (L + 2)) (k % (L + 2))

section construction

variable {ι κ : Type*} [Fintype ι] [Fintype κ] {p : ℕ → ι → Bool} {q : ℕ → κ → Bool}
  {L K : ℕ}

theorem gridV_dist (j r j' r' : ℕ) :
    hammingDist (gridV p q L j r) (gridV p q L j' r') =
      hammingDist (p (colOf L j r)) (p (colOf L j' r')) + hammingDist (q j) (q j') +
        hammingDist (gray (layerOf L j r)) (gray (layerOf L j' r')) := by
  unfold gridV
  rw [hammingDist_sumElim, hammingDist_sumElim]

theorem colOf_le (j r : ℕ) : colOf L j r ≤ L := by
  unfold colOf; split_ifs <;> omega

/-- Step inside a row. -/
theorem step_row (hp : IsSnake p L) (j r : ℕ) (hr : r ≤ L) :
    hammingDist (gridV p q L j r) (gridV p q L j (r + 1)) = 1 := by
  rw [gridV_dist, hammingDist_self]
  rcases Nat.lt_or_ge r L with h | h
  · have hl1 : layerOf L j r = j := by simp [layerOf]; omega
    have hl2 : layerOf L j (r + 1) = j := by simp [layerOf]; omega
    rw [hl1, hl2, hammingDist_self]
    unfold colOf
    split_ifs
    · rw [show min r L = r by omega, show min (r + 1) L = r + 1 by omega, hp.dist_one (by omega)]
    · rw [show L - min r L = (L - min (r + 1) L) + 1 by omega, hammingDist_comm,
        hp.dist_one (by omega)]
  · have hr' : r = L := by omega
    subst hr'
    have hl1 : layerOf r j r = j := by simp [layerOf]
    have hl2 : layerOf r j (r + 1) = j + 1 := by simp [layerOf]
    have hc : colOf r j (r + 1) = colOf r j r := by simp [colOf]
    rw [hl1, hl2, hc, hammingDist_self, gray_dist_succ]

/-- Step from the connector of row `j` into row `j + 1`. -/
theorem step_conn (hq : IsSnake q K) (j : ℕ) (hj : j + 1 ≤ K) :
    hammingDist (gridV p q L j (L + 1)) (gridV p q L (j + 1) 0) = 1 := by
  rw [gridV_dist, hq.dist_one hj]
  have hl1 : layerOf L j (L + 1) = j + 1 := by simp [layerOf]
  have hl2 : layerOf L (j + 1) 0 = j + 1 := by simp [layerOf]
  have hc : colOf L j (L + 1) = colOf L (j + 1) 0 := by
    simp only [colOf]; split_ifs <;> omega
  rw [hl1, hl2, hc, hammingDist_self, hammingDist_self]

/-- Chord condition for rows at distance at least two. -/
theorem chord_far (hq : IsSnake q K) {j j' : ℕ} (r r' : ℕ) (hj' : j' ≤ K) (h : j + 2 ≤ j') :
    2 ≤ hammingDist (gridV p q L j r) (gridV p q L j' r') := by
  rw [gridV_dist]
  have := hq.dist_two (i := j) (j := j') (by omega) hj' (Or.inl h)
  omega

/-- Chord condition inside one row. -/
theorem chord_same (hp : IsSnake p L) (j : ℕ) {r r' : ℕ} (hr' : r' ≤ L + 1)
    (h : r + 2 ≤ r') : 2 ≤ hammingDist (gridV p q L j r) (gridV p q L j r') := by
  rw [gridV_dist, hammingDist_self]
  rcases Nat.lt_or_ge r' (L + 1) with h1 | h1
  · have hl1 : layerOf L j r = j := by simp [layerOf]; omega
    have hl2 : layerOf L j r' = j := by simp [layerOf]; omega
    rw [hl1, hl2, hammingDist_self]
    have : 2 ≤ hammingDist (p (colOf L j r)) (p (colOf L j r')) := by
      apply hp.dist_two (colOf_le _ _) (colOf_le _ _)
      unfold colOf; split_ifs <;> omega
    omega
  · have hl1 : layerOf L j r = j := by simp [layerOf]; omega
    have hl2 : layerOf L j r' = j + 1 := by simp [layerOf]; omega
    rw [hl1, hl2, gray_dist_succ]
    have : 1 ≤ hammingDist (p (colOf L j r)) (p (colOf L j r')) := by
      apply hp.dist_pos (colOf_le _ _) (colOf_le _ _)
      unfold colOf; split_ifs <;> omega
    omega

/-- Chord condition between consecutive rows (excluding the connector step). -/
theorem chord_next (hp : IsSnake p L) (hq : IsSnake q K) {j r r' : ℕ} (hj : j + 1 ≤ K)
    (hr : r ≤ L + 1) (hr' : r' ≤ L + 1) (h : ¬ (r = L + 1 ∧ r' = 0)) :
    2 ≤ hammingDist (gridV p q L j r) (gridV p q L (j + 1) r') := by
  rw [gridV_dist, hq.dist_one hj]
  by_cases h1 : r ≤ L
  · have hl1 : layerOf L j r = j := by simp [layerOf]; omega
    rw [hl1]
    by_cases h2 : r' ≤ L
    · have hl2 : layerOf L (j + 1) r' = j + 1 := by simp [layerOf]; omega
      rw [hl2, gray_dist_succ]; omega
    · have hl2 : layerOf L (j + 1) r' = j + 2 := by simp [layerOf]; omega
      rw [hl2, gray_dist_two]; omega
  · have hl1 : layerOf L j r = j + 1 := by simp [layerOf]; omega
    rw [hl1]
    by_cases h2 : r' ≤ L
    · have hl2 : layerOf L (j + 1) r' = j + 1 := by simp [layerOf]; omega
      rw [hl2, hammingDist_self]
      have : 1 ≤ hammingDist (p (colOf L j r)) (p (colOf L (j + 1) r')) := by
        apply hp.dist_pos (colOf_le _ _) (colOf_le _ _)
        unfold colOf
        have : (j + 1) % 2 = 0 ↔ ¬ j % 2 = 0 := by omega
        split_ifs <;> omega
      omega
    · have hl2 : layerOf L (j + 1) r' = j + 2 := by simp [layerOf]; omega
      rw [hl2, show j + 2 = (j + 1) + 1 by ring, gray_dist_succ]; omega

/-- The escape snake is a snake of length `K * (L + 2) + L`. -/
theorem isSnake_escape (hp : IsSnake p L) (hq : IsSnake q K) :
    IsSnake (escapeSnake p q L) (K * (L + 2) + L) := by
  intro k k' hkk' hk'
  unfold escapeSnake
  set D := L + 2 with hD
  have hDpos : 0 < D := by omega
  have ek := Nat.div_add_mod k D
  have ek' := Nat.div_add_mod k' D
  have rk := Nat.mod_lt k hDpos
  have rk' := Nat.mod_lt k' hDpos
  set j := k / D
  set j' := k' / D
  set r := k % D
  set r' := k' % D
  have hjle : j ≤ j' := Nat.div_le_div_right hkk'.le
  have hj'K : j' ≤ K := by
    by_contra hc
    have : D * (K + 1) ≤ D * j' := Nat.mul_le_mul_left _ (by omega)
    nlinarith
  rcases Nat.lt_or_ge j' (j + 2) with hj2 | hj2
  · rcases Nat.lt_or_ge j j' with hj1 | hj1
    · -- j' = j + 1
      have hj1' : j' = j + 1 := by omega
      have hmul : D * j' = D * j + D := by rw [hj1']; ring
      rw [hj1']
      constructor
      · intro hk1
        have hrr : r = L + 1 ∧ r' = 0 := by omega
        rw [hrr.1, hrr.2]
        exact step_conn hq j (by omega)
      · intro hk2
        apply chord_next hp hq (by omega) (by omega) (by omega)
        omega
    · -- j' = j
      have hjj : j' = j := by omega
      rw [hjj] at ek' ⊢
      constructor
      · intro hk1
        have hrr : r' = r + 1 := by omega
        rw [hrr]
        exact step_row hp j r (by omega)
      · intro hk2
        exact chord_same hp j (by omega) (by omega)
  · constructor
    · intro hk1
      exfalso
      have : D * (j + 2) ≤ D * j' := Nat.mul_le_mul_left _ hj2
      nlinarith
    · intro _
      exact chord_far hq r r' hj'K hj2

end construction

/-- **Separator-coordinate escape theorem.**  Given snakes of lengths `L` in `Q_m` and
`K` in `Q_n`, there is a snake of length `K * (L + 2) + L = (L+1)(K+1) + K - 1` in
`Q_{m+n+2}`: two fresh coordinates suffice to recover the full multiplicative main term. -/
theorem separator_escape {m n : ℕ} (p : ℕ → Fin m → Bool) (q : ℕ → Fin n → Bool) (L K : ℕ)
    (hp : IsSnake p L) (hq : IsSnake q K) :
    ∃ s : ℕ → Fin (m + n + 2) → Bool, IsSnake s (K * (L + 2) + L) := by
  let e : Fin (m + n + 2) ≃ (Fin m ⊕ Fin n) ⊕ Fin 2 :=
    finSumFinEquiv.symm.trans (Equiv.sumCongr finSumFinEquiv.symm (Equiv.refl _))
  exact ⟨fun k => escapeSnake p q L k ∘ e, (isSnake_escape hp hq).comp_equiv e⟩

/-- A snake of length `N` restricts to a snake of any length `N' ≤ N`. -/
theorem IsSnake.mono {ι : Type*} [Fintype ι] {p : ℕ → ι → Bool} {N N' : ℕ}
    (hp : IsSnake p N) (h : N' ≤ N) : IsSnake p N' :=
  fun i j hij hj => hp i j hij (le_trans hj h)

/-- The conjecture's form with `c = 2` and no `o(1)` loss: a snake of length
`(L+1)(K+1) - 1`, i.e. with `(L+1)(K+1)` vertices, in `Q_{m+n+2}`. -/
theorem separator_escape_main_term {m n : ℕ} (p : ℕ → Fin m → Bool) (q : ℕ → Fin n → Bool)
    (L K : ℕ) (hp : IsSnake p L) (hq : IsSnake q K) :
    ∃ s : ℕ → Fin (m + n + 2) → Bool, IsSnake s ((L + 1) * (K + 1) - 1) := by
  obtain ⟨s, hs⟩ := separator_escape p q L K hp hq
  refine ⟨s, hs.mono ?_⟩
  have h1 : (L + 1) * (K + 1) = L * K + L + K + 1 := by ring
  have h2 : K * (L + 2) = L * K + 2 * K := by ring
  omega

/-! ### No-go: per-cell separator patterns give nothing -/

/-- **Cell-separator no-go.**  Suppose a snake in `Q_{m+n+c}` visits only vertices of the form
`(p (f k), q (g k), b (f k) (g k))`, i.e. the separator bits are a function of the product
cell.  Then the separator bits are constant along the snake, and the projection
`(p (f k), q (g k))` is already a snake of the same length in `Q_{m+n}`. -/
theorem cell_separator_no_gain {ι κ σ : Type*} [Fintype ι] [Fintype κ] [Fintype σ]
    {p : ℕ → ι → Bool} {q : ℕ → κ → Bool} {L K N : ℕ} (hp : IsSnake p L) (hq : IsSnake q K)
    (f g : ℕ → ℕ) (b : ℕ → ℕ → σ → Bool) (hf : ∀ k ≤ N, f k ≤ L) (hg : ∀ k ≤ N, g k ≤ K)
    (hs : IsSnake (fun k => Sum.elim (Sum.elim (p (f k)) (q (g k))) (b (f k) (g k))) N) :
    (∀ k ≤ N, b (f k) (g k) = b (f 0) (g 0)) ∧
      IsSnake (fun k => Sum.elim (p (f k)) (q (g k))) N := by
  -- consecutive vertices carry the same separator bits
  have hstep : ∀ k, k + 1 ≤ N → b (f (k + 1)) (g (k + 1)) = b (f k) (g k) ∧
      hammingDist (Sum.elim (p (f k)) (q (g k))) (Sum.elim (p (f (k + 1))) (q (g (k + 1))))
        = 1 := by
    intro k hk
    have h1 := (hs k (k + 1) (by omega) hk).1 rfl
    simp only [hammingDist_sumElim] at h1
    by_cases h0 : hammingDist (p (f k)) (p (f (k + 1))) + hammingDist (q (g k)) (q (g (k + 1)))
        = 0
    · exfalso
      have hpe : p (f k) = p (f (k + 1)) := hammingDist_eq_zero.mp (by omega)
      have hqe : q (g k) = q (g (k + 1)) := hammingDist_eq_zero.mp (by omega)
      have e1 := hp.injOn (hf k (by omega)) (hf (k + 1) hk) hpe
      have e2 := hq.injOn (hg k (by omega)) (hg (k + 1) hk) hqe
      rw [e1, e2] at h1
      simp only [hammingDist_self] at h1
      omega
    · have hb : hammingDist (b (f k) (g k)) (b (f (k + 1)) (g (k + 1))) = 0 := by omega
      refine ⟨(hammingDist_eq_zero.mp hb).symm, ?_⟩
      rw [hammingDist_sumElim]; omega
  have hconst : ∀ k ≤ N, b (f k) (g k) = b (f 0) (g 0) := by
    intro k hk
    induction k with
    | zero => rfl
    | succ k ih => rw [(hstep k hk).1, ih (by omega)]
  refine ⟨hconst, ?_⟩
  intro i j hij hj
  refine ⟨fun h => by subst h; exact (hstep i hj).2, fun h => ?_⟩
  have h2 := (hs i j hij hj).2 h
  simp only [hammingDist_sumElim] at h2
  rw [hconst i (by omega), hconst j hj, hammingDist_self] at h2
  rw [hammingDist_sumElim]; omega

end SnakeEscape