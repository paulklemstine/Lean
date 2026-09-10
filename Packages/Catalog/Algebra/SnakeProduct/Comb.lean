import Algebra.SnakeProduct.Basic

/-!
# The comb construction: a multiplicative lower bound for snakes in products

Let `p` be a snake of length `L` in the cube `Q_α` and `q` a snake of length `K` in the
cube `Q_β`.  The set of vertices `{(p i, q j)}` spans, inside `Q_{α ⊕ β}`, an **induced
grid** `P_{L+1} □ P_{K+1}` (Lemma `hdist_sum_elim` plus the distance dichotomy along a
snake).  Every induced path in that grid therefore *is* a snake in `Q_{α ⊕ β}`.

We implement the **boustrophedon comb**: traverse row `0` of the grid from left to right,
drop down two rows through a single connector cell, traverse row `2` from right to left,
and so on.  It uses `⌊L/2⌋` connector rows and `⌊L/2⌋ + 1` full rows, giving a snake of
length

  `combLen L K = ⌊L/2⌋ * (K + 2) + K ≥ L * K / 2`.

This is the main *positive* result of the development: snake lengths are (up to a factor
of `2` in the main term) supermultiplicative under products of cubes.

## Main definitions

* `SnakeProduct.combRow`, `SnakeProduct.combCol` : the grid coordinates of the `s`-th
  vertex of the comb.
* `SnakeProduct.combVertex` : the `s`-th vertex of the comb inside `Q_{α ⊕ β}`.
* `SnakeProduct.combLen L K = ⌊L/2⌋ * (K + 2) + K` : its length.

## Main results

* `SnakeProduct.isSnake_comb` : the comb is a snake of length `combLen L K`.
* `SnakeProduct.two_mul_combLen_ge` : `L * K ≤ 2 * combLen L K`.
* `SnakeProduct.combLen_ge_half_main_term` : `(L+1) * (K+1) ≤ 2 * combLen L K + K + 2`,
  i.e. the comb realises half of the conjectured main term `(L+1)(K+1)`.
-/

namespace SnakeProduct

open Finset

variable {α β : Type*} [Fintype α] [Fintype β] {L K : ℕ}
  {p : ℕ → α → Bool} {q : ℕ → β → Bool}

/-- The (truncated, symmetric) distance between two natural numbers. -/
def nd (i j : ℕ) : ℕ := (i - j) + (j - i)

lemma nd_comm (i j : ℕ) : nd i j = nd j i := by simp [nd]; omega

/-- The distance dichotomy along a snake, packaged for arithmetic: the Hamming distance
between `p i` and `p j` is at least `min (nd i j) 2`. -/
lemma IsSnake.hdist_ge_min (h : IsSnake α L p) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L) :
    min (nd i j) 2 ≤ hdist (p i) (p j) := by
  rcases lt_trichotomy i j with h1 | h1 | h1
  · rcases Nat.lt_or_ge (i + 1) j with h2 | h2
    · have := h.dist_ge_two hi hj (Or.inl h2)
      simp only [nd]; omega
    · have h3 : i + 1 = j := by omega
      have := h.dist_eq_one hi hj (Or.inl h3)
      simp only [nd]; omega
  · subst h1; simp [nd]
  · rcases Nat.lt_or_ge (j + 1) i with h2 | h2
    · have := h.dist_ge_two hi hj (Or.inr h2)
      simp only [nd]; omega
    · have h3 : j + 1 = i := by omega
      have := h.dist_eq_one hi hj (Or.inr h3)
      simp only [nd]; omega

/-- Two vertices of the product grid whose grid coordinates are at `ℓ¹`-distance `≥ 2`
are at Hamming distance `≥ 2` in the product cube. -/
lemma hdist_prod_ge_two (hp : IsSnake α L p) (hq : IsSnake β K q) {i i' j j' : ℕ}
    (hi : i ≤ L) (hi' : i' ≤ L) (hj : j ≤ K) (hj' : j' ≤ K)
    (h : 2 ≤ nd i i' + nd j j') :
    2 ≤ hdist (Sum.elim (p i) (q j)) (Sum.elim (p i') (q j')) := by
  rw [hdist_sum_elim]
  have h1 := hp.hdist_ge_min hi hi'
  have h2 := hq.hdist_ge_min hj hj'
  simp only [nd] at *
  omega

/-- A horizontal step in the product grid is a cube edge. -/
lemma hdist_prod_row (hq : IsSnake β K q) {i j j' : ℕ} (hj : j ≤ K) (hj' : j' ≤ K)
    (h : j + 1 = j' ∨ j' + 1 = j) :
    hdist (Sum.elim (p i) (q j)) (Sum.elim (p i) (q j')) = 1 := by
  rw [hdist_sum_elim, hdist_self, hq.dist_eq_one hj hj' h]

/-- A vertical step in the product grid is a cube edge. -/
lemma hdist_prod_col (hp : IsSnake α L p) {i i' j : ℕ} (hi : i ≤ L) (hi' : i' ≤ L)
    (h : i + 1 = i' ∨ i' + 1 = i) :
    hdist (Sum.elim (p i) (q j)) (Sum.elim (p i') (q j)) = 1 := by
  rw [hdist_sum_elim, hdist_self, hp.dist_eq_one hi hi' h]

/-! ### The comb -/

/-- Row index (position along the first snake) of the `s`-th vertex of the comb. -/
def combRow (K s : ℕ) : ℕ := 2 * (s / (K + 2)) + (if s % (K + 2) ≤ K then 0 else 1)

/-- Column index (position along the second snake) of the `s`-th vertex of the comb.
Even blocks are traversed left to right, odd blocks right to left. -/
def combCol (K s : ℕ) : ℕ :=
  if (s / (K + 2)) % 2 = 0 then min (s % (K + 2)) K else K - min (s % (K + 2)) K

/-- The `s`-th vertex of the comb inside the cube `Q_{α ⊕ β}`. -/
def combVertex (K : ℕ) (p : ℕ → α → Bool) (q : ℕ → β → Bool) (s : ℕ) : α ⊕ β → Bool :=
  Sum.elim (p (combRow K s)) (q (combCol K s))

/-- The length of the comb built from snakes of lengths `L` and `K`. -/
def combLen (L K : ℕ) : ℕ := (L / 2) * (K + 2) + K

lemma comb_decompose (K s : ℕ) : ∃ t r, r < K + 2 ∧ s = r + t * (K + 2) :=
  ⟨s / (K + 2), s % (K + 2), Nat.mod_lt _ (by omega), (Nat.mod_add_div' s (K + 2)).symm⟩

lemma comb_div (K t r : ℕ) (hr : r < K + 2) : (r + t * (K + 2)) / (K + 2) = t := by
  rw [Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hr, Nat.zero_add]

lemma comb_mod (K t r : ℕ) (hr : r < K + 2) : (r + t * (K + 2)) % (K + 2) = r := by
  rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hr]

lemma combRow_idx (K t r : ℕ) (hr : r < K + 2) :
    combRow K (r + t * (K + 2)) = 2 * t + (if r ≤ K then 0 else 1) := by
  unfold combRow; rw [comb_div K t r hr, comb_mod K t r hr]

lemma combCol_idx (K t r : ℕ) (hr : r < K + 2) :
    combCol K (r + t * (K + 2)) = if t % 2 = 0 then min r K else K - min r K := by
  unfold combCol; rw [comb_div K t r hr, comb_mod K t r hr]

lemma combCol_le (K s : ℕ) : combCol K s ≤ K := by
  unfold combCol; split <;> omega

/-- Consecutive comb vertices are grid-neighbours: either the row is unchanged and the
column moves by one, or the column is unchanged and the row increases by one. -/
lemma comb_step (K s : ℕ) :
    (combRow K (s + 1) = combRow K s ∧ nd (combCol K (s + 1)) (combCol K s) = 1) ∨
    (combCol K (s + 1) = combCol K s ∧ combRow K (s + 1) = combRow K s + 1) := by
  obtain ⟨t, r, hr, rfl⟩ := comb_decompose K s
  have hcases : r < K ∨ r = K ∨ r = K + 1 := by omega
  rcases hcases with hrK | hrK | hrK
  · -- inside a full row: the column advances by one
    left
    have h1 : r + t * (K + 2) + 1 = (r + 1) + t * (K + 2) := by omega
    rw [h1, combRow_idx K t (r + 1) (by omega), combRow_idx K t r (by omega),
      combCol_idx K t (r + 1) (by omega), combCol_idx K t r (by omega)]
    constructor
    · split_ifs <;> omega
    · simp only [nd]; split_ifs <;> omega
  · -- last cell of a full row: step down into the connector cell
    right
    rw [hrK]
    have h1 : K + t * (K + 2) + 1 = (K + 1) + t * (K + 2) := by omega
    rw [h1, combRow_idx K t (K + 1) (by omega), combRow_idx K t K (by omega),
      combCol_idx K t (K + 1) (by omega), combCol_idx K t K (by omega)]
    constructor
    · split_ifs <;> omega
    · split_ifs <;> omega
  · -- connector cell: step down into the first cell of the next block
    right
    rw [hrK]
    have h1 : (K + 1) + t * (K + 2) + 1 = 0 + (t + 1) * (K + 2) := by ring
    rw [h1, combRow_idx K (t + 1) 0 (by omega), combRow_idx K t (K + 1) (by omega),
      combCol_idx K (t + 1) 0 (by omega), combCol_idx K t (K + 1) (by omega)]
    constructor
    · split_ifs <;> omega
    · split_ifs <;> omega

/-- Comb vertices whose indices differ by at least `2` are at `ℓ¹`-distance at least `2`
in the grid: the comb has no chords. -/
lemma comb_chord (K s s' : ℕ) (h : s + 1 < s') :
    2 ≤ nd (combRow K s) (combRow K s') + nd (combCol K s) (combCol K s') := by
  obtain ⟨t, r, hr, rfl⟩ := comb_decompose K s
  obtain ⟨t', r', hr', rfl⟩ := comb_decompose K s'
  rw [combRow_idx K t r hr, combRow_idx K t' r' hr', combCol_idx K t r hr,
    combCol_idx K t' r' hr']
  -- compare the two blocks
  have hcmp : t < t' ∨ (t = t' ∧ r + 1 < r') := by
    rcases lt_trichotomy t t' with h1 | h1 | h1
    · exact Or.inl h1
    · subst h1; right; exact ⟨rfl, by omega⟩
    · exfalso
      have h2 : (t' + 1) * (K + 2) ≤ t * (K + 2) := Nat.mul_le_mul_right _ (by omega)
      have h3 : (t' + 1) * (K + 2) = t' * (K + 2) + (K + 2) := by ring
      omega
  rcases hcmp with hlt | ⟨rfl, hrr⟩
  · have hstep : t' = t + 1 ∨ t + 2 ≤ t' := by omega
    rcases hstep with rfl | hfar
    · -- adjacent blocks: the rows differ by one or two, and if by one then the earlier
      -- vertex is a connector and the columns differ
      have h3 : (t + 1) * (K + 2) = t * (K + 2) + (K + 2) := by ring
      simp only [nd]; split_ifs <;> omega
    · -- distant blocks: the rows already differ by at least two
      simp only [nd]; split_ifs <;> omega
  · -- same block: the columns differ by at least two, or the rows differ and the
    -- columns differ
    simp only [nd]; split_ifs <;> omega

lemma combRow_le (L K s : ℕ) (hs : s ≤ combLen L K) : combRow K s ≤ L := by
  obtain ⟨t, r, hr, rfl⟩ := comb_decompose K s
  rw [combRow_idx K t r hr]
  unfold combLen at hs
  have hT : 2 * (L / 2) ≤ L := by omega
  have ht : t ≤ L / 2 := by
    by_contra hc
    push_neg at hc
    have h2 : (L / 2 + 1) * (K + 2) ≤ t * (K + 2) := Nat.mul_le_mul_right _ (by omega)
    have h3 : (L / 2 + 1) * (K + 2) = (L / 2) * (K + 2) + (K + 2) := by ring
    omega
  rcases Nat.lt_or_ge t (L / 2) with h1 | h1
  · have h2 : t * (K + 2) + (K + 2) ≤ (L / 2) * (K + 2) := by
      have := Nat.mul_le_mul_right (K + 2) (show t + 1 ≤ L / 2 by omega)
      have h3 : (t + 1) * (K + 2) = t * (K + 2) + (K + 2) := by ring
      omega
    split <;> omega
  · have ht2 : t = L / 2 := by omega
    subst ht2
    have : r ≤ K := by omega
    simp only [if_pos this]
    omega

/-- **The comb is a snake.**  From a snake of length `L` in `Q_α` and a snake of length
`K` in `Q_β` we obtain a snake of length `⌊L/2⌋ * (K + 2) + K` in `Q_{α ⊕ β}`. -/
theorem isSnake_comb (hp : IsSnake α L p) (hq : IsSnake β K q) :
    IsSnake (α ⊕ β) (combLen L K) (combVertex K p q) := by
  constructor
  · intro s hs
    unfold combVertex
    rcases comb_step K s with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · rw [h1]
      exact hdist_prod_row hq (combCol_le K s) (combCol_le K (s + 1))
        (by simp only [nd] at h2; omega)
    · rw [h1]
      exact hdist_prod_col hp (combRow_le L K s (by omega))
        (combRow_le L K (s + 1) (by omega)) (by omega)
  · intro s s' hs hs' hss
    unfold combVertex
    exact hdist_prod_ge_two hp hq (combRow_le L K s hs) (combRow_le L K s' hs')
      (combCol_le K s) (combCol_le K s') (comb_chord K s s' hss)

/-- The comb realises at least half of the product `L * K`. -/
theorem two_mul_combLen_ge (L K : ℕ) (hL : 1 ≤ L) : L * K ≤ 2 * combLen L K := by
  unfold combLen
  have h : L = 2 * (L / 2) + L % 2 := (Nat.div_add_mod L 2).symm ▸ by omega
  have h2 : L % 2 = 0 ∨ L % 2 = 1 := by omega
  rcases h2 with h2 | h2 <;> · rw [h2] at h; nlinarith [Nat.div_le_self L 2]

/-- The comb realises half of the conjectured multiplicative main term `(L+1)(K+1)`. -/
theorem combLen_ge_half_main_term (L K : ℕ) (hL : 1 ≤ L) :
    (L + 1) * (K + 1) ≤ 2 * combLen L K + K + 2 := by
  unfold combLen
  have h : L = 2 * (L / 2) + L % 2 := (Nat.div_add_mod L 2).symm ▸ by omega
  have h2 : L % 2 = 0 ∨ L % 2 = 1 := by omega
  rcases h2 with h2 | h2 <;> · rw [h2] at h; nlinarith [Nat.div_le_self L 2]

/-- **Density of the comb.**  The comb uses a fraction `(K+2) / (2(K+1))` of the
`(L+1)(K+1)` cells of the product grid: `(L+1)(K+2) ≤ 2 (combLen L K + 1) + 2`.  For
`K = 1` this is `3/4`, matching the obstruction `product_support_card_bound` up to an
additive constant; as `K → ∞` it degrades to `1/2`. -/
theorem combLen_density (L K : ℕ) : (L + 1) * (K + 2) ≤ 2 * (combLen L K + 1) + 2 := by
  unfold combLen
  have h : L = 2 * (L / 2) + L % 2 := (Nat.div_add_mod L 2).symm ▸ by omega
  have h2 : L % 2 = 0 ∨ L % 2 = 1 := by omega
  rcases h2 with h2 | h2 <;> · rw [h2] at h; nlinarith [Nat.div_le_self L 2]

end SnakeProduct