/-
# Cycle 10: an `O(1)`-coefficient readout of `(a,b)` from `Δ_{a,b}`

Cycle 3 (`Completeness.lean`) recovered `(a,b)` from `Δ_{a,b}` through its *divisor spectrum*,
which requires factoring the polynomial. The semigroup description of Cycle 9 gives a much
cheaper readout: only **two** numbers extracted from the coefficient list are needed.

* `torusAlexander_coeff_one`        : `coeff_1 Δ_{a,b} = -1` (the number `1` is always a gap);
* `torusAlexander_coeff_min`        : `coeff_{min(a,b)} Δ_{a,b} = 1`;
* `torusAlexander_coeff_ne_one_of_lt_min` : no earlier coefficient equals `1`;
* `torusAlexander_min_readout`      : hence `min(a,b)` is *the* least index carrying the
  coefficient `+1`;
* `torusAlexander_cheap_readout`    : with `m = min(a,b)` read off that way and
  `d = deg Δ_{a,b}`, one has `d / (m - 1) + 1 = max(a,b)`, so the pair `(a,b)` is determined
  by `(m, d)` alone.

**The catch, one more time.** The readout costs `O(1)` *coefficient queries*, but the
coefficient at index `min(a,b)` sits inside a vector of length `(a-1)(b-1)+1`: producing
`Δ_{a,b}` at all already costs `Θ(ab)`. Cheap readout of an expensive object is not a cheap
algorithm — and for the catalog's pencil `T(2,N)` the readout returns `m = 2` and
`d/(m-1) + 1 = N`, i.e. exactly the input, never a nontrivial factor of `N`.
-/
import Computation.AlexanderTorusKnot.SemigroupGaps

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-- Nothing strictly between `0` and `min(a,b)` lies in the semigroup `⟨a,b⟩`. -/
theorem not_isRep_of_lt_min {a b n : ℕ} (hn : 0 < n) (hlt : n < min a b) : ¬ IsRep a b n := by
  rintro ⟨i, j, hij⟩
  have ha : a ≥ min a b := Nat.min_le_left a b
  have hb : b ≥ min a b := Nat.min_le_right a b
  rcases Nat.eq_zero_or_pos i with hi | hi
  · rcases Nat.eq_zero_or_pos j with hj | hj
    · rw [hi, hj] at hij; simp at hij; omega
    · have : b ≤ b * j := Nat.le_mul_of_pos_right b hj
      rw [hi] at hij
      simp only [Nat.mul_zero, Nat.zero_add] at hij
      omega
  · have : a ≤ a * i := Nat.le_mul_of_pos_right a hi
    omega

/-- The coefficient of `X` in `Δ_{a,b}` is `-1`: the number `1` is a gap of every
numerical semigroup `⟨a,b⟩` with `a, b > 1`. -/
theorem torusAlexander_coeff_one {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (torusAlexander a b).coeff 1 = -1 := by
  have h0 : IsRep a b (1 - 1) := by simpa using isRep_zero a b
  rw [torusAlexander_coeff_semigroup hab ha hb 1,
    if_neg (not_isRep_of_lt_min one_pos (by omega)), if_pos ⟨le_refl 1, h0⟩]
  norm_num

/-- `min(a,b)` carries the coefficient `+1`. -/
theorem torusAlexander_coeff_min {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (torusAlexander a b).coeff (min a b) = 1 := by
  have hmin : 1 < min a b := by omega
  have hrep : IsRep a b (min a b) := by
    rcases Nat.le_total a b with h | h
    · exact ⟨1, 0, by simp [Nat.min_eq_left h]⟩
    · exact ⟨0, 1, by simp [Nat.min_eq_right h]⟩
  rw [torusAlexander_coeff_semigroup hab ha hb (min a b), if_pos hrep,
    if_neg (fun hc => not_isRep_of_lt_min (n := min a b - 1) (by omega) (by omega) hc.2)]
  norm_num

/-- No index below `min(a,b)` carries the coefficient `+1`. -/
theorem torusAlexander_coeff_ne_one_of_lt_min {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a)
    (hb : 1 < b) {n : ℕ} (hn : 1 ≤ n) (hlt : n < min a b) :
    (torusAlexander a b).coeff n ≠ 1 := by
  rw [torusAlexander_coeff_semigroup hab ha hb n,
    if_neg (not_isRep_of_lt_min (by omega) hlt)]
  by_cases h : 1 ≤ n ∧ IsRep a b (n - 1) <;> simp [h]

/-- **`min(a,b)` is the least positive index at which `Δ_{a,b}` has coefficient `+1`.** -/
theorem torusAlexander_min_readout {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (torusAlexander a b).coeff (min a b) = 1 ∧
      ∀ n, 1 ≤ n → n < min a b → (torusAlexander a b).coeff n ≠ 1 :=
  ⟨torusAlexander_coeff_min hab ha hb,
    fun _ hn hlt => torusAlexander_coeff_ne_one_of_lt_min hab ha hb hn hlt⟩

/-- The degree and the minimum determine the maximum. -/
theorem torusAlexander_max_of_degree {a b : ℕ} (ha : 1 < a) (hb : 1 < b) :
    (a - 1) * (b - 1) / (min a b - 1) + 1 = max a b := by
  rcases Nat.le_total a b with h | h
  · rw [Nat.min_eq_left h, Nat.max_eq_right h,
      Nat.mul_div_cancel_left _ (show 0 < a - 1 by omega)]
    omega
  · rw [Nat.min_eq_right h, Nat.max_eq_left h, mul_comm,
      Nat.mul_div_cancel_left _ (show 0 < b - 1 by omega)]
    omega

/-- **The two-number readout.** Reading the least index `m` with coefficient `+1` and the
degree `d` of `Δ_{a,b}` recovers the unordered pair `{a, b}` as `{m, d/(m-1) + 1}`. -/
theorem torusAlexander_cheap_readout {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a)
    (hb : 1 < b) :
    ((torusAlexander a b).coeff (min a b) = 1 ∧
        ∀ n, 1 ≤ n → n < min a b → (torusAlexander a b).coeff n ≠ 1) ∧
      (torusAlexander a b).natDegree / (min a b - 1) + 1 = max a b := by
  refine ⟨torusAlexander_min_readout hab ha hb, ?_⟩
  rw [torusAlexander_natDegree hab (by omega) (by omega)]
  exact torusAlexander_max_of_degree ha hb

/-- Specialisation to the catalog pencil: for odd `N > 1` the readout of `Δ_{2,N}` returns
`m = 2` and `d/(m-1) + 1 = N`, i.e. the input parameters and nothing more. -/
theorem torus_two_readout {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    (Bridges.AlexanderTorus.alexander N).coeff 2 = 1 ∧
      (Bridges.AlexanderTorus.alexander N).natDegree / (2 - 1) + 1 = N := by
  have hcop : Nat.Coprime 2 N := by simpa using hN
  have heq := torusAlexander_two_eq_alexander hN h1
  have hmin : min 2 N = 2 := by omega
  have hmax : max 2 N = N := by omega
  have hread := torusAlexander_cheap_readout hcop (by omega) h1
  rw [heq, hmin, hmax] at hread
  exact ⟨hread.1.1, hread.2⟩

end Computation.AlexanderTorusKnot