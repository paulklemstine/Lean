/-
# A quadratic lower bound for the snake-in-the-box number

All lower bounds obtained so far in this development are **linear** in the
dimension: `maxLen n ≥ 2n - 2` from `Snake.lift2`, `maxLen n ≥ 6n - 19` from the
explicit `47`-edge seed in `Q 7`, and `maxCoil n ≥ 12n - 28` from the rectangle
construction.  Every one of them adds only a bounded number of edges per new
dimension.

This file changes the growth regime by *iterating* the rectangle construction
instead of using it once.  The two ingredients are already proved:

* `maxCoil_ge_two_mul` — the boundary of the rectangle spanned by a longest
  snake of `Q m` and a longest snake of `Q n` is an induced cycle with
  `2 (maxLen m + maxLen n)` vertices in `Q (m+n)`;
* `maxCoil_le_maxLen_add_two` — deleting a vertex from an induced cycle leaves
  an induced path.

Composing them gives the **doubling recursion**

> `maxLen_doubling` : `2 · maxLen m + 2 · maxLen n ≤ maxLen (m + n) + 2`,

in particular `maxLen (2n) ≥ 4 · maxLen n - 2` (`maxLen_double_dim`).  A linear
bound adds a constant per dimension; this recursion *quadruples* the length when
the dimension doubles, and the fixed point of that growth law is `n ↦ n²`.

Iterating along a dyadic scale (`maxLen_dyadic_iterate`, `dyadic_window`) and
seeding with the kernel-verified `47`-edge snake of `Q 7` gives

> `maxLen_quadratic` : `3 ≤ n → n ^ 2 ≤ 5 · maxLen n`,

i.e. `maxLen n ≥ n² / 5` for every `n ≥ 3`, and the same for induced cycles,

> `maxCoil_quadratic` : `6 ≤ n → n ^ 2 ≤ 5 · maxCoil n`.

This is the first superlinear lower bound of the development: no linear bound
can imply it.  It is superseded numerically by `Novelty/SnakeGridComb.lean`,
which gets an exponential bound out of a different construction (the comb
through the grid spanned by two snakes); the argument here is kept because it is
independent of that one — it uses only induced *cycles* — and because the
doubling recursion `maxLen_doubling` is of interest on its own.  It is of course still very far from the conjectured `c · 2ⁿ`; see
`FUTURE_DIRECTIONS.md`.  The exponent `2` here is `log₂ 4`, the `4` coming from
the two-snake rectangle; a construction turning `k` snakes into one long snake
would raise the exponent to `log₂ (2k)`.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.HypercubeCoil
import Novelty.CoilRectangle
import Novelty.SnakeSeedSeven
import Novelty.SnakeGridComb

namespace SnakeInTheBox

open Finset

variable {m n : ℕ}

/-! ## Step 1: the doubling recursion -/

/-- **Doubling recursion.**  The rectangle spanned by a longest snake of `Q m` and a
longest snake of `Q n` is an induced cycle of `Q (m+n)` with `2(maxLen m + maxLen n)`
vertices; deleting one of its vertices leaves an induced path.  Hence the maximal snake
length is *super-doubling*, not merely superadditive. -/
theorem maxLen_doubling (hm : 2 ≤ maxLen m) (hn : 2 ≤ maxLen n) :
    2 * maxLen m + 2 * maxLen n ≤ maxLen (m + n) + 2 := by
  have h1 := maxCoil_ge_two_mul hm hn
  have h2 := maxCoil_le_maxLen_add_two (m + n)
  omega

/-- The self-doubling special case: doubling the dimension quadruples the length,
up to the additive constant `2`. -/
theorem maxLen_double_dim (hn : 2 ≤ maxLen n) : 4 * maxLen n ≤ maxLen (2 * n) + 2 := by
  have h := maxLen_doubling (m := n) (n := n) hn hn
  have h2 : n + n = 2 * n := by omega
  rw [h2] at h
  omega

/-! ## Step 2: iteration along a dyadic scale -/

/-- **Dyadic iteration of the doubling recursion**, from an arbitrary seed dimension `b`.
Writing `a k = maxLen (b · 2 ^ k)`, the recursion `a (k+1) ≥ 4 a k - 2` integrates to
`3 · a k - 2 ≥ (3 · a 0 - 2) · 4 ^ k`; the statement below is that inequality with the
truncated subtractions cleared. -/
theorem maxLen_dyadic_iterate (b : ℕ) (hb : 2 ≤ maxLen b) :
    ∀ k : ℕ, 3 * maxLen b * 4 ^ k + 2 ≤ 3 * maxLen (b * 2 ^ k) + 2 * 4 ^ k := by
  intro k
  induction k with
  | zero => simp
  | succ j ih =>
      have h4 : (1 : ℕ) ≤ 4 ^ j := Nat.one_le_pow _ _ (by norm_num)
      have hstep : 2 ≤ maxLen (b * 2 ^ j) := by
        have h6 : 6 * 4 ^ j ≤ 3 * maxLen b * 4 ^ j :=
          Nat.mul_le_mul_right _ (by omega)
        linarith
      have hd := maxLen_double_dim (n := b * 2 ^ j) hstep
      have hdim : 2 * (b * 2 ^ j) = b * 2 ^ (j + 1) := by ring
      rw [hdim] at hd
      have hp : (4 : ℕ) ^ (j + 1) = 4 * 4 ^ j := by ring
      rw [hp]
      linarith

/-- Every `n ≥ b` (with `b ≥ 1`) lies in exactly one dyadic window `[b·2ᵏ, b·2ᵏ⁺¹)`. -/
theorem dyadic_window (b : ℕ) (hb : 1 ≤ b) :
    ∀ n : ℕ, b ≤ n → ∃ k, b * 2 ^ k ≤ n ∧ n < b * 2 ^ (k + 1) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn
    by_cases hsmall : n < 2 * b
    · exact ⟨0, by simpa using hn, by simpa [pow_one] using (by omega : n < b * 2)⟩
    · have hhalf : b ≤ n / 2 := by omega
      have hlt : n / 2 < n := by omega
      obtain ⟨k, hk1, hk2⟩ := ih (n / 2) hlt hhalf
      refine ⟨k + 1, ?_, ?_⟩
      · have he : b * 2 ^ (k + 1) = 2 * (b * 2 ^ k) := by ring
        omega
      · have he : b * 2 ^ (k + 1 + 1) = 2 * (b * 2 ^ (k + 1)) := by ring
        omega

/-! ## Step 3: the quadratic bound -/

/-- **Quadratic lower bound for the snake-in-the-box number.**  For every dimension
`n ≥ 3` the cube `Q n` contains a chordless induced path with at least `n² / 5`
edges.  The seed is the kernel-verified `47`-edge snake of `Q 7`. -/
theorem maxLen_quadratic (hn : 3 ≤ n) : n ^ 2 ≤ 5 * maxLen n := by
  rcases Nat.lt_or_ge n 7 with hsmall | hbig
  · -- the four small dimensions, from the linear bound `maxLen n ≥ 2n - 2`
    have hlin := maxLen_lower_strong n hn
    interval_cases n <;> omega
  -- the dyadic argument
  have h7 : 47 ≤ maxLen 7 := maxLen_seven_ge
  have hseed : 2 ≤ maxLen 7 := by omega
  obtain ⟨k, hk1, hk2⟩ := dyadic_window 7 (by norm_num) n hbig
  have hdy := maxLen_dyadic_iterate 7 hseed k
  have hmono : maxLen (7 * 2 ^ k) ≤ maxLen n := maxLen_mono hk1
  -- `14 · 2 ^ k ≥ n + 1`, hence `196 · 4 ^ k ≥ n ^ 2`
  have hwin : n + 1 ≤ 14 * 2 ^ k := by
    have he : 7 * 2 ^ (k + 1) = 14 * 2 ^ k := by ring
    omega
  have hsq : n ^ 2 ≤ 196 * 4 ^ k := by
    have h4 : (4 : ℕ) ^ k = 2 ^ k * 2 ^ k := by
      rw [show (4 : ℕ) = 2 * 2 by norm_num, mul_pow]
    calc n ^ 2 = n * n := by ring
      _ ≤ (14 * 2 ^ k) * (14 * 2 ^ k) := Nat.mul_le_mul (by omega) (by omega)
      _ = 196 * (2 ^ k * 2 ^ k) := by ring
      _ = 196 * 4 ^ k := by rw [h4]
  -- `3 · maxLen n ≥ 139 · 4 ^ k + 2`, and `139 · 196 ≥ 3 · 5 · ...` closes the loop
  have hlow : 139 * 4 ^ k + 2 ≤ 3 * maxLen n := by
    have hmul : 141 * 4 ^ k ≤ 3 * maxLen 7 * 4 ^ k := Nat.mul_le_mul_right _ (by omega)
    linarith
  linarith

/-- The same quadratic bound for induced cycles: for `n ≥ 6` the cube `Q n` contains an
induced cycle with at least `n² / 5` vertices.  The rectangle construction is applied to a
*balanced* split `n = ⌊n/2⌋ + ⌈n/2⌉`, and the convexity inequality `2(m² + p²) ≥ (m + p)²`
absorbs the factor two. -/
theorem maxCoil_quadratic (hn : 6 ≤ n) : n ^ 2 ≤ 5 * maxCoil n := by
  obtain ⟨m, p, hsum, hmp⟩ : ∃ m p, n = m + p ∧ (p = m ∨ p = m + 1) := by
    rcases Nat.even_or_odd n with h | h
    · obtain ⟨t, ht⟩ := h; exact ⟨t, t, by omega, Or.inl rfl⟩
    · obtain ⟨t, ht⟩ := h; exact ⟨t, t + 1, by omega, Or.inr rfl⟩
  have hm3 : 3 ≤ m := by rcases hmp with h | h <;> omega
  have hp3 : 3 ≤ p := by omega
  have h1 := maxLen_quadratic (n := m) hm3
  have h2 := maxLen_quadratic (n := p) hp3
  have hml : 2 ≤ maxLen m := by have := maxLen_lower hm3; omega
  have hpl : 2 ≤ maxLen p := by have := maxLen_lower hp3; omega
  have hc := maxCoil_ge_two_mul (m := m) (n := p) hml hpl
  rw [← hsum] at hc
  have hconv : n ^ 2 ≤ 2 * (m ^ 2 + p ^ 2) := by
    subst hsum
    rcases hmp with rfl | rfl <;> nlinarith
  linarith

/-- **Two-sided picture, quadratic version.**  For `n ≥ 3`,
`n² / 5 ≤ maxLen n` and `maxLen n + 1 < 3 · 2 ^ (n-2)`: the maximal snake length is
squeezed between a quadratic lower bound and the strict counting ceiling. -/
theorem maxLen_quadratic_picture (hn : 3 ≤ n) :
    n ^ 2 ≤ 5 * maxLen n ∧ maxLen n + 1 < 3 * 2 ^ (n - 2) :=
  ⟨maxLen_quadratic hn, maxLen_upper hn⟩

/-- The quadratic bound is genuinely superlinear: `maxLen n / n → ∞`.  Concretely,
for every slope `c` there is a dimension beyond which `maxLen n ≥ c · n`. -/
theorem maxLen_superlinear (c : ℕ) : ∀ n, 5 * c + 3 ≤ n → c * n ≤ maxLen n := by
  intro n hn
  have hq := maxLen_quadratic (n := n) (by omega)
  have hnn : n ^ 2 = n * n := sq n
  have h2 : (5 * c + 3) * n ≤ n * n := Nat.mul_le_mul_right n hn
  nlinarith [hq, h2, hnn]

/-- **Exponential lower bound for induced cycles.**  Splitting off three coordinates and
applying the rectangle construction to the exponentially long snake of the remaining
`n - 3` coordinates upgrades `maxCoil_quadratic` to an exponential bound. -/
theorem maxCoil_exponential (hn : 10 ≤ n) : 23 ^ ((n - 3) / 7) ≤ maxCoil n := by
  have hm7 : 7 ≤ n - 3 := by omega
  have hexp := maxLen_exponential (n := n - 3) hm7
  have hpow : 1 ≤ (23 : ℕ) ^ ((n - 3) / 7) := Nat.one_le_pow _ _ (by norm_num)
  have hml : 2 ≤ maxLen (n - 3) := by have := maxLen_lower (n := n - 3) (by omega); omega
  have hm3 : 2 ≤ maxLen 3 := by rw [maxLen_three]; omega
  have hc := maxCoil_ge_two_mul (m := n - 3) (n := 3) hml hm3
  have hdim : n - 3 + 3 = n := by omega
  rw [hdim] at hc
  omega

end SnakeInTheBox