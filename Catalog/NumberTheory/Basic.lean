/-
# `q`-analogues: `q`-integers, `q`-factorials and Gaussian binomial coefficients

This file sets up the elementary algebra of the Gaussian ("`q`-") binomial coefficients
over `ℕ`, for an integer parameter `q`.

* `QKummer.qNat q m = 1 + q + ⋯ + q^(m-1)` is the `q`-integer `[m]_q`.
* `QKummer.qFact q n = [1]_q [2]_q ⋯ [n]_q` is the `q`-factorial `[n]_q!`.
* `QKummer.qBinom q n k` is the Gaussian binomial coefficient, defined by the
  `q`-Pascal recursion so that it is *manifestly* a natural number.

The main structural result is `QKummer.qFact_mul_qBinom`:
`[k]_q! * [n-k]_q! * binom(n,k)_q = [n]_q!` for `k ≤ n`, i.e. the Gaussian binomial
coefficient is the *exact* quotient of `q`-factorials.  This is the identity that turns
`ℓ`-adic valuation questions about `binom(n,k)_q` into counting questions about
`q`-integers, and is the input to the `q`-analogue of Kummer's theorem proved in
`Catalog/NumberTheory/QKummer/Valuation.lean`.
-/
import Mathlib

namespace QKummer

/-- The `q`-integer `[m]_q = 1 + q + ⋯ + q^(m-1)`. -/
def qNat (q m : ℕ) : ℕ := ∑ i ∈ Finset.range m, q ^ i

/-- The `q`-factorial `[n]_q! = [1]_q [2]_q ⋯ [n]_q`. -/
def qFact (q : ℕ) : ℕ → ℕ
  | 0 => 1
  | (n + 1) => qNat q (n + 1) * qFact q n

/-- The Gaussian binomial coefficient `binom(n,k)_q`, defined by the `q`-Pascal recursion. -/
def qBinom (q : ℕ) : ℕ → ℕ → ℕ
  | _, 0 => 1
  | 0, (_ + 1) => 0
  | (n + 1), (k + 1) => qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1)

@[simp] theorem qNat_zero (q : ℕ) : qNat q 0 = 0 := rfl

@[simp] theorem qNat_one (q : ℕ) : qNat q 1 = 1 := by simp [qNat]

theorem qNat_succ (q m : ℕ) : qNat q (m + 1) = qNat q m + q ^ m := by
  simp [qNat, Finset.sum_range_succ]

/-- The fundamental additivity of `q`-integers: `[a+b]_q = [a]_q + q^a [b]_q`. -/
theorem qNat_add (q a b : ℕ) : qNat q (a + b) = qNat q a + q ^ a * qNat q b := by
  induction b with
  | zero => simp
  | succ b ih =>
      rw [← Nat.add_assoc, qNat_succ, ih, qNat_succ q b, Nat.mul_add, pow_add]
      ring

theorem one_le_qNat {m : ℕ} (q : ℕ) (hm : 0 < m) : 1 ≤ qNat q m := by
  induction m with
  | zero => omega
  | succ j ih =>
      rw [qNat_succ]
      rcases Nat.eq_zero_or_pos j with hj | hj
      · subst hj; simp
      · have := ih hj; omega

theorem qNat_pos {m : ℕ} (q : ℕ) (hm : 0 < m) : 0 < qNat q m := one_le_qNat q hm

/-- `[m]_q * (q - 1) + 1 = q ^ m`: the `q`-integer is the exact quotient `(q^m-1)/(q-1)`. -/
theorem qNat_mul_sub_one_add_one {q : ℕ} (hq : 1 ≤ q) (m : ℕ) :
    qNat q m * (q - 1) + 1 = q ^ m := by
  obtain ⟨p, rfl⟩ : ∃ p, q = p + 1 := ⟨q - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  induction m with
  | zero => simp
  | succ m ih =>
      rw [qNat_succ, Nat.add_mul, pow_succ]
      nlinarith [ih]

/-- `(q - 1) * [m]_q = q ^ m - 1`. -/
theorem sub_one_mul_qNat {q : ℕ} (hq : 1 ≤ q) (m : ℕ) : (q - 1) * qNat q m = q ^ m - 1 := by
  have h := qNat_mul_sub_one_add_one hq m
  rw [Nat.mul_comm] at h
  omega

@[simp] theorem qFact_zero (q : ℕ) : qFact q 0 = 1 := rfl

theorem qFact_succ (q n : ℕ) : qFact q (n + 1) = qNat q (n + 1) * qFact q n := rfl

theorem qFact_pos (q n : ℕ) : 0 < qFact q n := by
  induction n with
  | zero => simp
  | succ n ih => exact Nat.mul_pos (qNat_pos q (Nat.succ_pos n)) ih

@[simp] theorem qBinom_zero_right (q n : ℕ) : qBinom q n 0 = 1 := by
  cases n <;> rfl

theorem qBinom_succ_succ (q n k : ℕ) :
    qBinom q (n + 1) (k + 1) = qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1) := rfl

theorem qBinom_eq_zero_of_lt {q n k : ℕ} (h : n < k) : qBinom q n k = 0 := by
  induction n generalizing k with
  | zero =>
      obtain ⟨k, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
      rfl
  | succ n ih =>
      obtain ⟨k, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
      rw [qBinom_succ_succ, ih (by omega), ih (by omega)]
      simp

@[simp] theorem qBinom_self (q n : ℕ) : qBinom q n n = 1 := by
  induction n with
  | zero => rfl
  | succ n ih => rw [qBinom_succ_succ, ih, qBinom_eq_zero_of_lt (Nat.lt_succ_self n)]; simp

/-- **Exactness of the Gaussian binomial coefficient.**
`[k]_q! * [n-k]_q! * binom(n,k)_q = [n]_q!` for `k ≤ n`. -/
theorem qFact_mul_qBinom (q : ℕ) : ∀ n k : ℕ, k ≤ n →
    qFact q k * qFact q (n - k) * qBinom q n k = qFact q n := by
  intro n
  induction n with
  | zero => intro k hk; interval_cases k; simp
  | succ n ih =>
      intro k hk
      match k with
      | 0 => simp
      | (k + 1) =>
        by_cases hkn : k = n
        · subst hkn
          simp
        · have hk1 : k + 1 ≤ n := by omega
          have h1 : qFact q k * qFact q (n - k) * qBinom q n k = qFact q n := ih k (by omega)
          have h2 : qFact q (k + 1) * qFact q (n - (k + 1)) * qBinom q n (k + 1) = qFact q n :=
            ih (k + 1) hk1
          have hnk : n - k = (n - (k + 1)) + 1 := by omega
          have hsum : qNat q (k + 1) + q ^ (k + 1) * qNat q (n - k) = qNat q (n + 1) := by
            have h : (k + 1) + (n - k) = n + 1 := by omega
            conv_rhs => rw [← h, qNat_add]
          calc qFact q (k + 1) * qFact q (n + 1 - (k + 1)) * qBinom q (n + 1) (k + 1)
              = qFact q (k + 1) * qFact q (n - k) *
                  (qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1)) := by
                have he : n + 1 - (k + 1) = n - k := by omega
                rw [he, qBinom_succ_succ]
            _ = qNat q (k + 1) * (qFact q k * qFact q (n - k) * qBinom q n k)
                  + q ^ (k + 1) * qNat q (n - k) *
                    (qFact q (k + 1) * qFact q (n - (k + 1)) * qBinom q n (k + 1)) := by
                rw [qFact_succ, hnk, qFact_succ q (n - (k + 1))]
                have h : n - (k + 1) + 1 = n - k := by omega
                rw [h]
                ring
            _ = qNat q (n + 1) * qFact q n := by rw [h1, h2, ← hsum]; ring
            _ = qFact q (n + 1) := (qFact_succ q n).symm

/-- The `q`-factorials divide, as they must: `[k]_q! [n-k]_q! ∣ [n]_q!`. -/
theorem qFact_mul_dvd_qFact {q n k : ℕ} (hk : k ≤ n) :
    qFact q k * qFact q (n - k) ∣ qFact q n :=
  ⟨qBinom q n k, (qFact_mul_qBinom q n k hk).symm⟩

/-- The Gaussian binomial coefficient is the honest quotient of `q`-factorials. -/
theorem qBinom_eq_qFact_div {q n k : ℕ} (hk : k ≤ n) :
    qBinom q n k = qFact q n / (qFact q k * qFact q (n - k)) := by
  rw [← qFact_mul_qBinom q n k hk,
    Nat.mul_div_cancel_left _ (Nat.mul_pos (qFact_pos q k) (qFact_pos q (n - k)))]

/-- **Symmetry of the Gaussian binomial coefficient**: `binom(n,k)_q = binom(n,n-k)_q`. -/
theorem qBinom_symm {q n k : ℕ} (hk : k ≤ n) : qBinom q n k = qBinom q n (n - k) := by
  have h1 := qFact_mul_qBinom q n k hk
  have h2 := qFact_mul_qBinom q n (n - k) (Nat.sub_le n k)
  rw [Nat.sub_sub_self hk] at h2
  refine Nat.eq_of_mul_eq_mul_left
    (Nat.mul_pos (qFact_pos q k) (qFact_pos q (n - k))) ?_
  calc qFact q k * qFact q (n - k) * qBinom q n k = qFact q n := h1
    _ = qFact q (n - k) * qFact q k * qBinom q n (n - k) := h2.symm
    _ = qFact q k * qFact q (n - k) * qBinom q n (n - k) := by ring

theorem qBinom_pos {q n k : ℕ} (hk : k ≤ n) : 0 < qBinom q n k := by
  rcases Nat.eq_zero_or_pos (qBinom q n k) with h | h
  · exfalso
    have h2 := qFact_mul_qBinom q n k hk
    rw [h, Nat.mul_zero] at h2
    exact absurd h2.symm (Nat.ne_of_gt (qFact_pos q n))
  · exact h

end QKummer