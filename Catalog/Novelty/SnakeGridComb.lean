/-
# The product theorem and an exponential lower bound

`Novelty/SnakeConcat.lean` proves the *additive* product statement
`Snake m L → Snake n M → Snake (m+n) (L+M)`, and `Novelty/SnakeQuadratic.lean`
squeezes a quadratic bound out of the rectangle construction.  Direction 4 of
the research programme asks for a genuinely **multiplicative** statement.  This
file proves it, and the consequence is a jump from polynomial to exponential.

## The grid

If `s` is a snake of `Q m` and `t` a snake of `Q n`, the set
`{ cappend (s.v a) (t.v b) | a ≤ L, b ≤ M }` is a grid inside `Q (m+n)`.  By
`hammingDist_cappend` the Hamming distance splits as `d(a,a') + d(b,b')`, and
because `s` and `t` are chordless the distance between two grid points is

* `0` iff `a = a'` and `b = b'`,
* `1` iff exactly one coordinate moves by one step,
* `≥ 2` otherwise.

So the grid is an **induced subgraph** of `Q (m+n)` isomorphic to the
`(L+1) × (M+1)` grid graph, and a snake of `Q (m+n)` supported on it is exactly
an induced path of the grid graph.

## The comb

The longest induced path of a grid graph is the *comb*: traverse row `0`
completely, step down to row `1` at the right-hand end, step down again to row
`2`, traverse row `2` completely in the opposite direction, and so on.  Only
every second row is traversed, and the connecting vertices alternate between the
two ends, which is exactly what keeps the path chordless.  With `L = 2q` this
visits `q (M+2) + M + 1` vertices — a *product* of the two lengths, not a sum.

`combRow` and `combCol` encode the comb by block division: index `k` lies in
block `b = k / (M+2)` at offset `r = k % (M+2)`; offsets `r ≤ M` sweep row `2b`
(left to right if `b` is even, right to left if `b` is odd) and offset `r = M+1`
is the connector in row `2b+1`.

## Consequences

> `Snake.comb`   : `Snake m (2*q) → Snake n M → Snake (m+n) (q*(M+2)+M)`
> `maxLen_mul_le`: `maxLen m * maxLen n ≤ 2 * maxLen (m + n)`

The second is the product theorem.  Iterating it from the kernel-verified
`47`-edge snake of `Q 7` gives `2 · 23 ^ a ≤ maxLen (7a)` and hence

> `maxLen_exponential` : `7 ≤ n → 23 ^ (n / 7) ≤ maxLen n`,

an **exponential** lower bound, `maxLen n ≥ 23 ^ (n/7) ≈ 1.56 ⁿ`.  This
supersedes every linear and quadratic bound of the development and puts the
lower bound in the same regime as the conjectured `c · 2ⁿ` (the ceiling
`maxLen n + 1 < 3 · 2 ^ (n-2)` remains the matching upper bound).
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.SnakeConcat
import Novelty.SnakeSeedSeven

namespace SnakeInTheBox

open Finset

variable {m n M q : ℕ}

/-! ## Step 1: block arithmetic -/

/-- Cancellation of the (positive) block size. -/
theorem lt_of_block_lt {b c M : ℕ} (h : b * (M + 2) < c * (M + 2)) : b < c :=
  lt_of_mul_lt_mul_right h (Nat.zero_le _)

theorem block_div (M b r : ℕ) (hr : r < M + 2) : (b * (M + 2) + r) / (M + 2) = b := by
  have h : b * (M + 2) + r = r + (M + 2) * b := by ring
  rw [h, Nat.add_mul_div_left _ _ (by omega), Nat.div_eq_of_lt hr, Nat.zero_add]

theorem block_mod (M b r : ℕ) (hr : r < M + 2) : (b * (M + 2) + r) % (M + 2) = r := by
  have h : b * (M + 2) + r = r + (M + 2) * b := by ring
  rw [h, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hr]

theorem block_decomp (M k : ℕ) : ∃ b r, k = b * (M + 2) + r ∧ r < M + 2 :=
  ⟨k / (M + 2), k % (M + 2), (Nat.div_add_mod' k (M + 2)).symm, Nat.mod_lt _ (by omega)⟩

/-! ## Step 2: the comb -/

/-- Row of the `k`-th vertex of the comb with rows of width `M + 1`. -/
def combRow (M k : ℕ) : ℕ :=
  2 * (k / (M + 2)) + (if k % (M + 2) ≤ M then 0 else 1)

/-- Column of the `k`-th vertex of the comb with rows of width `M + 1`. -/
def combCol (M k : ℕ) : ℕ :=
  if k % (M + 2) ≤ M then
    (if (k / (M + 2)) % 2 = 0 then k % (M + 2) else M - k % (M + 2))
  else
    (if (k / (M + 2)) % 2 = 0 then M else 0)

theorem combRow_full (M b r : ℕ) (hr : r ≤ M) : combRow M (b * (M + 2) + r) = 2 * b := by
  unfold combRow
  rw [block_div M b r (by omega), block_mod M b r (by omega), if_pos hr]
  omega

theorem combCol_full (M b r : ℕ) (hr : r ≤ M) :
    combCol M (b * (M + 2) + r) = if b % 2 = 0 then r else M - r := by
  unfold combCol
  rw [block_div M b r (by omega), block_mod M b r (by omega), if_pos hr]

theorem combRow_conn (M b : ℕ) : combRow M (b * (M + 2) + (M + 1)) = 2 * b + 1 := by
  unfold combRow
  rw [block_div M b (M + 1) (by omega), block_mod M b (M + 1) (by omega), if_neg (by omega)]

theorem combCol_conn (M b : ℕ) :
    combCol M (b * (M + 2) + (M + 1)) = if b % 2 = 0 then M else 0 := by
  unfold combCol
  rw [block_div M b (M + 1) (by omega), block_mod M b (M + 1) (by omega), if_neg (by omega)]

theorem combCol_le (M k : ℕ) : combCol M k ≤ M := by
  obtain ⟨b, r, rfl, hr⟩ := block_decomp M k
  rcases Nat.lt_or_ge r (M + 1) with h | h
  · rw [combCol_full M b r (by omega)]
    split <;> omega
  · have hrr : r = M + 1 := by omega
    subst hrr
    rw [combCol_conn M b]
    split <;> omega

theorem combRow_le (M q : ℕ) {k : ℕ} (hk : k ≤ q * (M + 2) + M) : combRow M k ≤ 2 * q := by
  obtain ⟨b, r, rfl, hr⟩ := block_decomp M k
  have hexp : (q + 1) * (M + 2) = q * (M + 2) + (M + 2) := by ring
  rcases Nat.lt_or_ge r (M + 1) with h | h
  · rw [combRow_full M b r (by omega)]
    have : b < q + 1 := lt_of_block_lt (M := M) (by omega)
    omega
  · have hrr : r = M + 1 := by omega
    subst hrr
    rw [combRow_conn M b]
    have : b < q := lt_of_block_lt (M := M) (by omega)
    omega

/-! ## Step 3: the two geometric lemmas -/

/-- Two comb vertices in the same row and at index distance at least two are in columns
at distance at least two. -/
theorem comb_col_sep (M : ℕ) {i j : ℕ} (hij : i + 2 ≤ j) (hrow : combRow M i = combRow M j) :
    combCol M i + 2 ≤ combCol M j ∨ combCol M j + 2 ≤ combCol M i := by
  obtain ⟨b, r, rfl, hr⟩ := block_decomp M i
  obtain ⟨c, u, rfl, hu⟩ := block_decomp M j
  rcases Nat.lt_or_ge r (M + 1) with hrM | hrM
  · rcases Nat.lt_or_ge u (M + 1) with huM | huM
    · rw [combRow_full M b r (by omega), combRow_full M c u (by omega)] at hrow
      have hbc : b = c := by omega
      subst hbc
      rw [combCol_full M b r (by omega), combCol_full M b u (by omega)]
      by_cases hb : b % 2 = 0
      · rw [if_pos hb, if_pos hb]; omega
      · rw [if_neg hb, if_neg hb]; omega
    · have huu : u = M + 1 := by omega
      subst huu
      rw [combRow_full M b r (by omega), combRow_conn M c] at hrow
      omega
  · have hrr : r = M + 1 := by omega
    subst hrr
    rcases Nat.lt_or_ge u (M + 1) with huM | huM
    · rw [combRow_conn M b, combRow_full M c u (by omega)] at hrow
      omega
    · have huu : u = M + 1 := by omega
      subst huu
      rw [combRow_conn M b, combRow_conn M c] at hrow
      have hbc : b = c := by omega
      subst hbc
      omega

/-- Two comb vertices in adjacent rows and at index distance at least two are in
different columns. -/
theorem comb_col_ne (M : ℕ) {i j : ℕ} (hij : i + 2 ≤ j)
    (hrow : combRow M i + 1 = combRow M j ∨ combRow M j + 1 = combRow M i) :
    combCol M i ≠ combCol M j := by
  obtain ⟨b, r, rfl, hr⟩ := block_decomp M i
  obtain ⟨c, u, rfl, hu⟩ := block_decomp M j
  have hexp : (c + 1) * (M + 2) = c * (M + 2) + (M + 2) := by ring
  have hexp' : (b + 1) * (M + 2) = b * (M + 2) + (M + 2) := by ring
  rcases Nat.lt_or_ge r (M + 1) with hrM | hrM
  · rcases Nat.lt_or_ge u (M + 1) with huM | huM
    · -- both in full rows: rows have the same parity, so they cannot be adjacent
      rw [combRow_full M b r (by omega), combRow_full M c u (by omega)] at hrow
      omega
    · -- `i` in a full row, `j` a connector
      have huu : u = M + 1 := by omega
      subst huu
      rw [combRow_full M b r (by omega), combRow_conn M c] at hrow
      have hbc : b = c := by
        rcases hrow with h | h
        · omega
        · -- `b = c + 1` would put `i` after `j`
          exfalso
          have hb : b = c + 1 := by omega
          subst hb
          omega
      subst hbc
      rw [combCol_full M b r (by omega), combCol_conn M b]
      by_cases hb : b % 2 = 0
      · rw [if_pos hb, if_pos hb]; omega
      · rw [if_neg hb, if_neg hb]; omega
  · -- `i` is a connector
    have hrr : r = M + 1 := by omega
    subst hrr
    rcases Nat.lt_or_ge u (M + 1) with huM | huM
    · have hcb : c = b + 1 := by
        rw [combRow_conn M b, combRow_full M c u (by omega)] at hrow
        rcases hrow with h | h
        · omega
        · exfalso
          have hc : c = b := by omega
          subst hc
          omega
      subst hcb
      rw [combCol_conn M b, combCol_full M (b + 1) u (by omega)]
      by_cases hb : b % 2 = 0
      · rw [if_pos hb, if_neg (by omega : ¬ (b + 1) % 2 = 0)]; omega
      · rw [if_neg hb, if_pos (by omega : (b + 1) % 2 = 0)]; omega
    · -- both connectors: rows have the same parity
      have huu : u = M + 1 := by omega
      subst huu
      rw [combRow_conn M b, combRow_conn M c] at hrow
      omega

/-! ## Step 4: the comb snake -/

/-- The vertex sequence of the comb spanned by two snakes. -/
def combV (s : Snake m (2 * q)) (t : Snake n M) : ℕ → Cube (m + n) := fun k =>
  cappend (s.v (combRow M k)) (t.v (combCol M k))

/-- A convenient two-sided distance lemma for the chord condition. -/
theorem two_le_dist_of_sep {N : ℕ} (s : Snake m N) {a b : ℕ} (hb : b ≤ N) (ha : a ≤ N)
    (h : a + 2 ≤ b ∨ b + 2 ≤ a) : 2 ≤ hammingDist (s.v a) (s.v b) := by
  rcases h with h | h
  · exact s.chord a b hb h
  · rw [hammingDist_comm]; exact s.chord b a ha h

/-- **The product (comb) construction.**  A snake of even length `2q` in `Q m` and a
snake of length `M` in `Q n` produce a snake of length `q(M+2) + M` in `Q (m+n)`:
the comb through the grid they span. -/
def Snake.comb (s : Snake m (2 * q)) (t : Snake n M) : Snake (m + n) (q * (M + 2) + M) where
  v := combV s t
  step k hk := by
    obtain ⟨b, r, rfl, hr⟩ := block_decomp M k
    simp only [combV]
    rcases Nat.lt_or_ge r M with hrm | hrm
    · -- inside a full row
      have hsucc : b * (M + 2) + r + 1 = b * (M + 2) + (r + 1) := by ring
      rw [hsucc, combRow_full M b r (by omega), combRow_full M b (r + 1) (by omega),
        combCol_full M b r (by omega), combCol_full M b (r + 1) (by omega)]
      refine adj_cappend_right _ ?_
      by_cases hb : b % 2 = 0
      · rw [if_pos hb, if_pos hb]
        exact t.step r hrm
      · rw [if_neg hb, if_neg hb]
        have hstep : M - (r + 1) + 1 = M - r := by omega
        exact adj_symm (by rw [← hstep] at *; exact t.step (M - (r + 1)) (by omega))
    rcases Nat.eq_or_lt_of_le hrm with hrM | hrM
    · -- the step from a full row to its connector
      have hrM' : r = M := hrM.symm
      have hsucc : b * (M + 2) + r + 1 = b * (M + 2) + (M + 1) := by omega
      rw [hsucc, combRow_full M b r (by omega), combRow_conn M b,
        combCol_full M b r (by omega), combCol_conn M b]
      have hbq : b < q := lt_of_block_lt (M := M) (by omega)
      have hcol : (if b % 2 = 0 then r else M - r) = if b % 2 = 0 then M else 0 := by
        split <;> omega
      rw [hcol]
      exact adj_cappend_left _ (s.step (2 * b) (by omega))
    · -- the step from a connector to the next full row
      have hrr : r = M + 1 := by omega
      subst hrr
      have hsucc : b * (M + 2) + (M + 1) + 1 = (b + 1) * (M + 2) + 0 := by ring
      rw [hsucc, combRow_conn M b, combRow_full M (b + 1) 0 (by omega),
        combCol_conn M b, combCol_full M (b + 1) 0 (by omega)]
      have hbq : b < q := lt_of_block_lt (M := M) (by omega)
      have hcol : (if b % 2 = 0 then M else 0) = if (b + 1) % 2 = 0 then 0 else M - 0 := by
        by_cases hb : b % 2 = 0
        · rw [if_pos hb, if_neg (by omega : ¬ (b + 1) % 2 = 0)]; omega
        · rw [if_neg hb, if_pos (by omega : (b + 1) % 2 = 0)]
      rw [hcol]
      have hr2 : 2 * (b + 1) = 2 * b + 1 + 1 := by ring
      rw [hr2]
      exact adj_cappend_left _ (s.step (2 * b + 1) (by omega))
  chord i j hj hij := by
    simp only [combV]
    rw [hammingDist_cappend]
    have hjr : combRow M j ≤ 2 * q := combRow_le M q hj
    have hir : combRow M i ≤ 2 * q := combRow_le M q (by omega)
    have hjc : combCol M j ≤ M := combCol_le M j
    have hic : combCol M i ≤ M := combCol_le M i
    rcases (show combRow M i + 2 ≤ combRow M j ∨ combRow M j + 2 ≤ combRow M i ∨
        combRow M i = combRow M j ∨ combRow M i + 1 = combRow M j ∨
        combRow M j + 1 = combRow M i from by omega) with h | h | h | h | h
    · have := two_le_dist_of_sep s hjr hir (Or.inl h); omega
    · have := two_le_dist_of_sep s hjr hir (Or.inr h); omega
    · rw [h, hammingDist_self]
      have := two_le_dist_of_sep t hjc hic (comb_col_sep M hij h)
      omega
    · have h1 : 1 ≤ hammingDist (s.v (combRow M i)) (s.v (combRow M j)) :=
        s.one_le_hammingDist hir hjr (by omega)
      have h2 : 1 ≤ hammingDist (t.v (combCol M i)) (t.v (combCol M j)) :=
        t.one_le_hammingDist hic hjc (comb_col_ne M hij (Or.inl h))
      omega
    · have h1 : 1 ≤ hammingDist (s.v (combRow M i)) (s.v (combRow M j)) :=
        s.one_le_hammingDist hir hjr (by omega)
      have h2 : 1 ≤ hammingDist (t.v (combCol M i)) (t.v (combCol M j)) :=
        t.one_le_hammingDist hic hjc (comb_col_ne M hij (Or.inr h))
      omega

/-! ## Step 5: the product theorem -/

/-- **Product theorem for the snake-in-the-box number.**  Two independent blocks of
coordinates multiply, not merely add:
`maxLen m · maxLen n ≤ 2 · maxLen (m + n)`. -/
theorem maxLen_mul_le (m n : ℕ) : maxLen m * maxLen n ≤ 2 * maxLen (m + n) := by
  obtain ⟨s⟩ := exists_snake_maxLen m
  obtain ⟨t⟩ := exists_snake_maxLen n
  set F := maxLen m with hF
  set G := maxLen n with hG
  have hq : 2 * (F / 2) ≤ F := by omega
  have s' : Snake m (2 * (F / 2)) := s.truncate hq
  have hc := le_maxLen (s'.comb t)
  have hlow : F ≤ 2 * (F / 2) + 1 := by omega
  nlinarith [hc, hlow, Nat.zero_le (F / 2), Nat.zero_le G]

/-- The self-product: squaring the length costs one factor two. -/
theorem maxLen_sq_le (n : ℕ) : maxLen n ^ 2 ≤ 2 * maxLen (2 * n) := by
  have h := maxLen_mul_le n n
  have h2 : n + n = 2 * n := by omega
  rw [h2] at h
  nlinarith [h]

/-! ## Step 6: the exponential lower bound -/

/-- Iterating the product theorem from the kernel-verified `47`-edge snake of `Q 7`. -/
theorem maxLen_seven_mul : ∀ a : ℕ, 1 ≤ a → 2 * 23 ^ a ≤ maxLen (7 * a) := by
  intro a
  induction a with
  | zero => intro h; omega
  | succ p ih =>
      intro _
      rcases Nat.eq_zero_or_pos p with hp | hp
      · subst hp
        have h7 : 47 ≤ maxLen 7 := maxLen_seven_ge
        have hg : 2 * 23 ^ (0 + 1) = 46 := by norm_num
        have hd : 7 * (0 + 1) = 7 := by norm_num
        rw [hg, hd]
        omega
      · have ihp := ih hp
        have hmul := maxLen_mul_le (7 * p) 7
        have h7 : 47 ≤ maxLen 7 := maxLen_seven_ge
        have hdim : 7 * p + 7 = 7 * (p + 1) := by ring
        rw [hdim] at hmul
        have hprod : (2 * 23 ^ p) * 47 ≤ maxLen (7 * p) * maxLen 7 :=
          Nat.mul_le_mul ihp h7
        have hpow : (23 : ℕ) ^ (p + 1) = 23 ^ p * 23 := by ring
        rw [hpow]
        nlinarith [hprod, hmul, Nat.zero_le ((23 : ℕ) ^ p)]

/-- **Exponential lower bound for the snake-in-the-box number.**  For every dimension
`n ≥ 7` the cube `Q n` contains a chordless induced path with at least `23 ^ (n / 7)`
edges, i.e. `maxLen n` grows at least like `1.56 ⁿ`. -/
theorem maxLen_exponential (hn : 7 ≤ n) : 23 ^ (n / 7) ≤ maxLen n := by
  have ha : 1 ≤ n / 7 := by omega
  have hle : 7 * (n / 7) ≤ n := by omega
  have h1 := maxLen_seven_mul (n / 7) ha
  have h2 : maxLen (7 * (n / 7)) ≤ maxLen n := maxLen_mono hle
  omega

/-- Base-two form of the exponential bound: `2 ^ (4 · ⌊n/7⌋) ≤ maxLen n`. -/
theorem maxLen_exponential_two (hn : 7 ≤ n) : 2 ^ (4 * (n / 7)) ≤ maxLen n := by
  have h1 := maxLen_exponential hn
  have h2 : (2 : ℕ) ^ (4 * (n / 7)) ≤ 23 ^ (n / 7) := by
    rw [pow_mul]
    exact Nat.pow_le_pow_left (by norm_num) _
  omega

/-- **The final two-sided picture.**  For `n ≥ 7` the maximal snake length lies between
an exponential lower bound and the strict counting ceiling: both bounds are now
exponential in the dimension, with bases `23 ^ (1/7) ≈ 1.56` and `2`. -/
theorem maxLen_exponential_picture (hn : 7 ≤ n) :
    23 ^ (n / 7) ≤ maxLen n ∧ maxLen n + 1 < 3 * 2 ^ (n - 2) :=
  ⟨maxLen_exponential hn, maxLen_upper (by omega)⟩

end SnakeInTheBox