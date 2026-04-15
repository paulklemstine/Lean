/-
# Mathematics of Science Fiction — Chapter 10: Probability and Alien Life

Formalized proofs about probability theory, the infinite monkey theorem,
and the mathematics of extraterrestrial life.
-/
import Mathlib

namespace SciFiMathematics.AlienLife

/-! ## Section 10.1: The Infinite Monkey Theorem -/

/-
The probability of NOT hitting a target in n independent trials decreases
    geometrically. This is the core of the infinite monkey theorem.
-/
theorem miss_probability_decreases (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    StrictAnti (fun n : ℕ => (1 - p) ^ n) := by
  exact fun n m hnm => pow_lt_pow_right_of_lt_one₀ ( by linarith ) ( by linarith ) hnm

/-
The probability of missing n times converges to 0.
-/
theorem miss_probability_vanishes (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    Filter.Tendsto (fun n : ℕ => (1 - p) ^ n) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one ( by linarith ) ( by linarith )

/-
Therefore the probability of hitting at least once converges to 1.
-/
theorem hit_probability_approaches_one (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    Filter.Tendsto (fun n : ℕ => 1 - (1 - p) ^ n) Filter.atTop (nhds 1) := by
  exact le_trans ( tendsto_const_nhds.sub ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by linarith ) ( by linarith ) ) ) ( by norm_num )

/-! ## Section 10.2: Poisson Processes and Nearest Neighbors -/

/-
For a Poisson parameter lam > 0, e^(-lam) < 1.
    This gives the probability that a region of space contains no civilizations.
-/
theorem poisson_void_probability (lam : ℝ) (hlam : 0 < lam) :
    Real.exp (-lam) < 1 := by
  aesop

/-
As the search volume grows (lam → ∞), the probability of finding
    at least one civilization approaches 1.
-/
theorem poisson_detection_limit :
    Filter.Tendsto (fun x : ℝ => 1 - Real.exp (-x)) Filter.atTop (nhds 1) := by
  simpa using tendsto_const_nhds.sub ( Real.tendsto_exp_atBot.comp Filter.tendsto_neg_atTop_atBot )

/-! ## Combinatorics of Molecular Assembly -/

/-
The number of arrangements of k items from n grows with n.
-/
theorem arrangements_grow (k : ℕ) (hk : 0 < k) :
    StrictMono (fun n : ℕ => n ^ k) := by
  exact fun a b h => Nat.pow_lt_pow_left h hk.ne'

/-
Factorial grows faster than exponential: n! > 2^n for large enough n.
-/
theorem factorial_beats_exponential :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 2 ^ n < n.factorial := by
  exact ⟨ 4, fun n hn => by induction hn <;> norm_num [ Nat.factorial_succ, pow_succ' ] at * ; nlinarith ⟩

end SciFiMathematics.AlienLife