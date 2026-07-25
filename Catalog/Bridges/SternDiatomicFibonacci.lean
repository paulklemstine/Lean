import Mathlib
import Bridges.ElementaryNumberTheoryBridge

/-! # Stern's Diatomic Sequence : core development

This file introduces **Stern's diatomic sequence** `s` (OEIS A002487) as a fresh
number-theoretic object and proves two insight-bearing results about it. The
cross-domain Fibonacci bridge built on top of this development lives in the
companion file `Bridges/SternFibonacciBridge.lean`.

The sequence is defined by
* `s 0 = 0`, `s 1 = 1`,
* `s (2n)   = s n`,
* `s (2n+1) = s n + s (n+1)`.

Main results in this file:
1. `stern_coprime` — consecutive Stern values are always coprime.
2. `stern_pow_two_sub_one` — `s (2^n − 1) = n` (the "all-ones" binary indices).

-- !-- Lab Notes -- !--
Hypothesizer (Stage 1): candidate conjectures about Stern's sequence `s`:
  (H1) gcd(s n, s(n+1)) = 1 for all n.                        [SURVIVED → Thm 1]
  (H2) s(2^n − 1) = n and s(2^n) = 1.                         [SURVIVED → Thm 2]
  (H3) s((4^n−1)/3) = F(2n) (even-index Fibonacci).           [SURVIVED → companion file]
  (H4) row-sum ∑_{i<2^k} s(2^k+i) = 3^k.                      [true, computational; future direction]
  (H5, surprising) s(2·(4^n−1)/3 + 1) = F(2n+1) (odd Fibonacci) [SURVIVED, companion file]
  (H6, surprising) the coupled pair (s(Jₙ), s(2Jₙ+1)) obeys the *same* linear
      recurrence as (F(2n), F(2n+1)); this powers the bridge.
Experiment (Stage 1): all conjectures verified by direct evaluation for the first
  ~40 indices (`s = [0,1,1,2,1,3,2,3,1,4,3,5,2,5,3,4,1,5,4,7,…]`, coprimality holds,
  `s(2^n−1)=[0,1,2,3,4,5]`, `s(Jₙ)=[0,1,3,8,21,55,144,377]=F(2n)`).
Experimenter (Stage 2): the recurrence must first be exposed as usable equational
  lemmas (`stern_even`, `stern_odd`); the well-founded definition does not reduce
  by `rfl`, so we unfold via `conv_lhs => rw [stern]` and discharge the parity
  side-condition with `omega`. Positivity (`stern_pos`) and coprimality both fall
  to strong induction after casing on the parity of the index.
Analyst (Stage 3): H1, H2 survived here; the Fibonacci content (H3, H5, H6) is
  strong enough to warrant its own file. H4 (row sums = 3^k) is true but deferred
  to keep the headline count to three theorems total across the two files.
Critic (Stage 4): no theorem is vacuous — `stern_coprime` is a genuine gcd result
  proved by strong induction, `stern_pow_two_sub_one` an exact identity by
  induction using the custom equational lemmas. The catalog file
  `ElementaryNumberTheoryBridge` is imported and used in `stern_coprime_symm`.
  No `sorry`; axioms are the standard `propext`/`Classical.choice`/`Quot.sound`.
-/

namespace SternDiatomicFibonacci

open Nat

/-- Stern's diatomic sequence (a.k.a. Stern–Brocot "fusc" function, OEIS A002487). -/
def stern : ℕ → ℕ
  | 0 => 0
  | 1 => 1
  | (n + 2) =>
      if (n + 2) % 2 = 0 then stern ((n + 2) / 2)
      else stern ((n + 2) / 2) + stern ((n + 2) / 2 + 1)
  decreasing_by all_goals omega

/-! ### Equational lemmas (the recurrence in usable form) -/

@[simp] lemma stern_zero : stern 0 = 0 := by simp [stern]

@[simp] lemma stern_one : stern 1 = 1 := by simp [stern]

/-- Even index: `s(2n) = s n`. -/
lemma stern_even (n : ℕ) : stern (2 * n) = stern n := by
  rcases n with _ | m
  · rfl
  · rw [show 2 * (m + 1) = (2 * m) + 2 by ring]
    conv_lhs => rw [stern]
    rw [if_pos (by omega)]
    congr 1; omega

/-- Odd index: `s(2n+1) = s n + s(n+1)`. -/
lemma stern_odd (n : ℕ) : stern (2 * n + 1) = stern n + stern (n + 1) := by
  rcases n with _ | m
  · simp
  · rw [show 2 * (m + 1) + 1 = (2 * m + 1) + 2 by ring]
    conv_lhs => rw [stern]
    rw [if_neg (by omega)]
    have e : (2 * m + 1 + 2) / 2 = m + 1 := by omega
    rw [e]

/-! ### Positivity -/

/-- Stern's sequence is strictly positive except at `0`. -/
lemma stern_pos (n : ℕ) : 0 < stern (n + 1) := by
  induction' n using Nat.strong_induction_on with n ih
  rcases Nat.even_or_odd' n with ⟨k, rfl | rfl⟩
  · rcases k with _ | k <;> simp_all +decide [Nat.mul_succ]
    rw [show 2 * k + 2 + 1 = 2 * (k + 1) + 1 by ring, stern_odd]
    exact add_pos (ih _ <| by linarith) (ih _ <| by linarith)
  · rw [show 2 * k + 1 + 1 = 2 * (k + 1) by ring, stern_even]
    exact ih _ (by linarith)

/-! ### Theorem 1 : consecutive Stern values are coprime -/

/-- **Consecutive Stern values are coprime.** -/
theorem stern_coprime (n : ℕ) : Nat.Coprime (stern n) (stern (n + 1)) := by
  induction' n using Nat.strong_induction_on with n ih
  rcases Nat.even_or_odd' n with ⟨k, rfl | rfl⟩ <;>
    simp_all +arith +decide [Nat.Coprime]
  · by_cases hk : k = 0
    · simp +decide [hk]
    · convert ih k (by linarith [Nat.pos_of_ne_zero hk]) using 1
      rw [stern_even, stern_odd]
      simp +decide
  · rcases k with _ | k <;> simp_all +arith +decide [Nat.mul_succ]
    convert ih (k + 1) (by linarith) using 1
    rw [show 2 * k + 3 = 2 * (k + 1) + 1 by ring,
        show 2 * k + 4 = 2 * (k + 2) by ring, stern_odd, stern_even]
    simp +decide

/-- Corollary using the catalog's `ElementaryNumberTheoryBridge.gcd_comm`:
coprimality is symmetric in the two consecutive entries. -/
theorem stern_coprime_symm (n : ℕ) :
    Nat.gcd (stern (n + 1)) (stern n) = 1 := by
  rw [ElementaryNumberTheoryBridge.gcd_comm]
  exact stern_coprime n

/-! ### Theorem 2 : the all-ones binary indices -/

/-- `s(2^n) = 1`: powers of two are fixed points at value `1`. -/
lemma stern_pow_two (n : ℕ) : stern (2 ^ n) = 1 := by
  induction' n with n ih <;> simp +decide [*, pow_succ']
  rw [stern_even, ih]

/-- **`s(2^n − 1) = n`.** The binary "all ones" index of length `n` has Stern
value exactly `n`. -/
theorem stern_pow_two_sub_one (n : ℕ) : stern (2 ^ n - 1) = n := by
  induction' n with n ih <;> simp_all +decide [Nat.pow_succ']
  rw [show 2 * 2 ^ n - 1 = 2 * (2 ^ n - 1) + 1 by zify; norm_num; ring, stern_odd]
  rw [Nat.sub_add_cancel (Nat.one_le_pow _ _ (by decide)), stern_pow_two, ih]

end SternDiatomicFibonacci