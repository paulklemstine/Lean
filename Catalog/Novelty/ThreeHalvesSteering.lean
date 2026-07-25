import Mathlib
import Cryptography.KMerAvoidance

/-!
# Arithmetic and symbolic structure of the three-halves steering word

Write `2 m_{n+1} = 3 m_n + t_n`.  The integer word `t` records exactly the
rounding correction in a nearest-integer orbit for multiplication by `3/2`.
This development isolates the finite-block identities behind complexity
arguments: a block determines its endpoint by a weighted base-`3/2` sum, equal
blocks force a precise Diophantine scaling relation, and bounded rounding error
restricts the word to five symbols.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer). Seven claims were tested, ranked by impact: (H1) the
steering word has superlinear factor complexity; (H2) every repeated block
forces an exponentially rigid relation between its starting rounded values;
(H3) the weighted block sum reconstructs every endpoint; (H4) bounded nearest-
integer errors force a five-letter alphabet; (H5) zero steering on a block is
possible only when a power of two divides the initial rounded value; (H6) the
finite factor count is bounded by the fifth power alphabet bound; (H7) an
infinite zero tail is impossible away from the zero orbit.

EXPERIMENT (Experimenter). Initial rounded values are
`1, 2, 2, 3, 5, 8, 11, 17`, producing corrections
`1, -2, 0, 1, 1, -2, 1`. This rejects the tempting three-letter alphabet
`{-1,0,1}` and supports the sharp five-letter guard. The reconstruction and
repeated-block identities survived symbolic expansion and induction.

ANALYSIS (Analyst). The common structure is the integer recurrence
`2m_{n+1}=3m_n+t_n`. Iteration gives a weighted sum whose coefficients are
coprime powers of two and three. Thus symbolic coincidence becomes an exact
arithmetic relation, providing the bridge required by Diophantine
anti-repetition results.

CRITIQUE (Critic). Superlinearity itself needs the deep anti-stammering input
from the Subspace Theorem and is not claimed unconditionally here. No finite
calculation is promoted to an asymptotic conclusion. The five-symbol result
retains both endpoint possibilities allowed by the stated half-open error
bounds. All headline statements are general and use induction or arithmetic
reasoning rather than definitional simplification.

SYNTHESIS (Principal Investigator). The verified core consists of endpoint
reconstruction, repeated-block rigidity, divisibility forced by zero blocks,
exclusion of a nonzero infinite zero tail, the five-symbol rounding bound, and
a catalog-anchored finite complexity bound.
These results expose a reusable arithmetic-to-symbolic interface for a later
Subspace-Theorem layer.
-- !-- Lab Notes -- !--
-/

namespace ThreeHalvesSteering

/-- The steering correction associated with an integer approximation sequence. -/
def steering (m : ℕ → ℤ) (n : ℕ) : ℤ := 2 * m (n + 1) - 3 * m n

/-- The weighted contribution of a length-`k` steering block beginning at `n`. -/
def blockWeight (t : ℕ → ℤ) (n : ℕ) : ℕ → ℤ
  | 0 => 0
  | k + 1 => 3 * blockWeight t n k + 2 ^ k * t (n + k)

/-
Iterating the steering recurrence reconstructs the endpoint of every block.
-/
theorem endpoint_reconstruction (m : ℕ → ℤ) (n k : ℕ) :
    2 ^ k * m (n + k) = 3 ^ k * m n + blockWeight (steering m) n k := by
  induction' k with k ih generalizing n <;> simp_all +decide [ pow_succ', mul_assoc, blockWeight ];
  have := ih n; have := ih ( n + 1 ) ; simp_all +decide [ ← add_assoc, steering ] ; ring;
  grind

/-
Equal steering blocks have equal weighted corrections.
-/
theorem blockWeight_eq_of_blocks (t : ℕ → ℤ) {a b k : ℕ}
    (h : ∀ j < k, t (a + j) = t (b + j)) :
    blockWeight t a k = blockWeight t b k := by
  induction' k with k ih;
  · rfl;
  · rw [ blockWeight, blockWeight, ih fun j hj => h j ( Nat.lt_succ_of_lt hj ), h k ( Nat.lt_succ_self k ) ]

/-
A repeated block forces an exact scaling relation between endpoint differences.
-/
theorem repeated_block_rigidity (m : ℕ → ℤ) {a b k : ℕ}
    (h : ∀ j < k, steering m (a + j) = steering m (b + j)) :
    2 ^ k * (m (a + k) - m (b + k)) = 3 ^ k * (m a - m b) := by
  -- Apply endpoint_reconstruction at a,k and b,k.
  have h1 := endpoint_reconstruction m a k
  have h2 := endpoint_reconstruction m b k;
  linarith [ blockWeight_eq_of_blocks ( steering m ) h ]

/-
A zero steering block forces a large power of two to divide its initial value.
-/
theorem zero_block_forces_two_power_dvd (m : ℕ → ℤ) {n k : ℕ}
    (h : ∀ j < k, steering m (n + j) = 0) :
    (2 : ℤ) ^ k ∣ m n := by
  -- By endpoint_reconstruction, we have $2^k * m(n+k) = 3^k * m(n)$.
  have h_eq : 2 ^ k * m (n + k) = 3 ^ k * m n := by
    rw [ endpoint_reconstruction ];
    induction' k with k ih <;> simp_all +decide [ blockWeight ];
    exact ih fun j hj => h j hj.le;
  exact Int.dvd_of_dvd_mul_right_of_gcd_one ( Dvd.intro _ h_eq ) ( by cases k <;> norm_num [ Int.gcd, Int.natAbs_pow ] )

/-
An infinite zero tail can occur only when its initial rounded value is zero.
-/
theorem infinite_zero_tail_forces_zero (m : ℕ → ℤ) {n : ℕ}
    (h : ∀ j, steering m (n + j) = 0) :
    m n = 0 := by
  -- Since $2^k \mid m n$ for all $k$, this implies $m n = 0$.
  have h_div_all : ∀ k : ℕ, (2 : ℤ) ^ k ∣ m n := by
    exact fun k => zero_block_forces_two_power_dvd m fun j hj => h j;
  by_contra h_nonzero;
  -- Choose $k$ such that $2^k > |m n|$.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, 2 ^ k > Int.natAbs (m n) := by
    exact pow_unbounded_of_one_lt _ one_lt_two;
  exact hk.not_ge ( Nat.le_of_dvd ( Int.natAbs_pos.mpr h_nonzero ) ( by simpa [ ← Int.natCast_dvd_natCast ] using h_div_all k ) )

/-
Nearest-integer error bounds constrain every correction to five integers.
-/
theorem steering_five_symbol_alphabet (m : ℕ → ℤ) (eps : ℕ → ℝ)
    (horbit : ∀ n, (m n : ℝ) + eps n = (3 / 2 : ℝ) ^ n)
    (hlower : ∀ n, -(1 / 2 : ℝ) ≤ eps n)
    (hupper : ∀ n, eps n < 1 / 2) (n : ℕ) :
    steering m n ∈ ({-2, -1, 0, 1, 2} : Set ℤ) := by
  -- From orbit equations at n and n+1 and (3/2)^(n+1)=(3/2)*(3/2)^n derive (steering m n : ℝ) = 3*eps n - 2*eps(n+1).
  have h_steering_eq : ∀ n, (steering m n : ℝ) = 3 * eps n - 2 * eps (n + 1) := by
    intro n; rw [ show ( steering m n : ℝ ) = 2 * m ( n + 1 ) - 3 * m n by norm_cast ] ; have := horbit n; have := horbit ( n + 1 ) ; norm_num [ pow_succ' ] at * ; linarith;
  -- Since `steering m n` is an integer, we can conclude that it must be one of the integers in the range [-2, 2].
  have h_int_range : ∀ n, -2 ≤ steering m n ∧ steering m n ≤ 2 := by
    exact fun n => ⟨ Int.le_of_lt_add_one <| by rw [ ← @Int.cast_lt ℝ ] ; push_cast; linarith [ h_steering_eq n, hlower n, hupper n, hlower ( n + 1 ), hupper ( n + 1 ) ], Int.le_of_lt_add_one <| by rw [ ← @Int.cast_lt ℝ ] ; push_cast; linarith [ h_steering_eq n, hlower n, hupper n, hlower ( n + 1 ), hupper ( n + 1 ) ] ⟩;
  cases h_int_range n ; interval_cases steering m n <;> simp +decide

/-
Catalog-anchored bound: a finite steering prefix over five symbols has at
most `5^k` distinct windows of length `k`.
-/
theorem finite_steering_complexity_bound {n k : ℕ} (hkn : k ≤ n)
    (s : Fin n → Fin 5) : subwordComplexity hkn s ≤ 5 ^ k := by
  convert subword_complexity_le hkn s using 1

end ThreeHalvesSteering