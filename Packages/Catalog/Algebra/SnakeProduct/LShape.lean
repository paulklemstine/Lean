import Algebra.SnakeProduct.Comb

/-!
# The L-shape: superadditivity of snake lengths

The comb of `Algebra.SnakeProduct.Comb` is the multiplicative construction; here we record
the (much simpler, but complementary) *additive* one.  Traverse the whole of the first
snake inside the slice `{q 0}`, then turn the corner and traverse the whole of the second
snake inside the slice `{p L}`.  In grid coordinates this is the boundary "L" of the
rectangle, an induced path of length `L + K`.

This construction beats the comb exactly in the degenerate regimes (`K = 0`, or `L` odd
and small), and yields superadditivity of the snake-in-the-box number.

## Main results

* `SnakeProduct.isSnake_lshape` : the L-shape is a snake of length `L + K`.
-/

namespace SnakeProduct

open Finset

variable {α β : Type*} [Fintype α] [Fintype β] {L K : ℕ}
  {p : ℕ → α → Bool} {q : ℕ → β → Bool}

/-- Row index of the `s`-th vertex of the L-shape. -/
def lshapeRow (L s : ℕ) : ℕ := min s L

/-- Column index of the `s`-th vertex of the L-shape. -/
def lshapeCol (L s : ℕ) : ℕ := s - L

/-- The `s`-th vertex of the L-shape in `Q_{α ⊕ β}`. -/
def lshapeVertex (L : ℕ) (p : ℕ → α → Bool) (q : ℕ → β → Bool) (s : ℕ) : α ⊕ β → Bool :=
  Sum.elim (p (lshapeRow L s)) (q (lshapeCol L s))

/-- **The L-shape is a snake** of length `L + K`: hence snake lengths are superadditive
under products of cubes. -/
theorem isSnake_lshape (hp : IsSnake α L p) (hq : IsSnake β K q) :
    IsSnake (α ⊕ β) (L + K) (lshapeVertex L p q) := by
  constructor
  · intro s hs
    unfold lshapeVertex
    rcases Nat.lt_or_ge s L with h | h
    · -- still travelling along the first snake
      have hcol : lshapeCol L (s + 1) = lshapeCol L s := by simp only [lshapeCol]; omega
      rw [hcol]
      exact hdist_prod_col hp (by simp only [lshapeRow]; omega) (by simp only [lshapeRow]; omega)
        (by simp only [lshapeRow]; omega)
    · -- travelling along the second snake
      have hrow : lshapeRow L (s + 1) = lshapeRow L s := by simp only [lshapeRow]; omega
      rw [hrow]
      exact hdist_prod_row hq (by simp only [lshapeCol]; omega) (by simp only [lshapeCol]; omega)
        (by simp only [lshapeCol]; omega)
  · intro s s' hs hs' hss
    unfold lshapeVertex
    refine hdist_prod_ge_two hp hq (by simp only [lshapeRow]; omega)
      (by simp only [lshapeRow]; omega) (by simp only [lshapeCol]; omega)
      (by simp only [lshapeCol]; omega) ?_
    simp only [nd, lshapeRow, lshapeCol]
    omega

end SnakeProduct