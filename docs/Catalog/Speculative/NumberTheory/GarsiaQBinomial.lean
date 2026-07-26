import Mathlib

/-!
# Gaussian binomial coefficients (q-binomials)

A memorial-tribute companion file for *Adriano Garsia (1928–2024)*.  Garsia's
mathematical life was devoted to **q-analogs** and their combinatorics: the
theory of Macdonald polynomials, the `(q,t)`-Catalan numbers, the
Garsia–Haiman modules, and the shuffle theory of the diagonal harmonics.  At the
heart of every one of these subjects sit the **Gaussian binomial coefficients**
`⟦ n choose k ⟧_q`, the q-analog of the ordinary binomial coefficients.

This file develops a small, self-contained theory of these polynomials over
`ℤ[q]` (here `q = Polynomial.X`), defined through the **q-Pascal recurrence**

  `⟦ n+1 , k+1 ⟧ = ⟦ n , k ⟧ + q^(k+1) · ⟦ n , k+1 ⟧`.

We prove:

* `qBinom_eq_zero_of_lt`     : the coefficient vanishes for `k > n`;
* `qBinom_self`              : `⟦ n , n ⟧ = 1`;
* `qBinom_one_right`         : `⟦ n , 1 ⟧ = [n]_q = 1 + q + ⋯ + q^{n-1}`;
* `qBinom_pascal'`           : the *dual* q-Pascal recurrence
                               `⟦ n+1 , k+1 ⟧ = q^{n-k}·⟦ n , k ⟧ + ⟦ n , k+1 ⟧`;
* `qBinom_symm`              : the symmetry `⟦ n , k ⟧ = ⟦ n , n-k ⟧`;
* `qBinom_eval_one`          : the specialization `q = 1` recovers the ordinary
                               binomial coefficient `Nat.choose n k`;
* `qNat_eval_one`            : `[n]_q` specializes to `n` at `q = 1`;
* `qNat_add`                 : additivity of q-integers `[a+b]_q = [a]_q + q^a·[b]_q`;
* `qFactorial_product`       : the **q-factorial product formula**
                               `⟦n,k⟧_q · [k]_q! · [n-k]_q! = [n]_q!`, the
                               division-free q-analog of `C(n,k)·k!·(n-k)! = n!`;
* `qFactorial_eval_one`      : `[n]_q!` specializes to `n!` at `q = 1`;
* `choose_mul_factorial_from_q` : the classical `C(n,k)·k!·(n-k)! = n!` as a
                               `q = 1` corollary of the product formula.

All results are proved from scratch; nothing here relies on a pre-existing
Gaussian-binomial theory.
-/

namespace GarsiaQBinom

open Polynomial

open scoped BigOperators

/-- The q-integer `[n]_q = 1 + q + q² + ⋯ + q^{n-1}` as an element of `ℤ[q]`. -/
noncomputable def qNat (n : ℕ) : Polynomial ℤ := ∑ i ∈ Finset.range n, X ^ i

/-- The Gaussian binomial coefficient `⟦ n choose k ⟧_q ∈ ℤ[q]`, defined via the
q-Pascal recurrence. -/
noncomputable def qBinom : ℕ → ℕ → Polynomial ℤ
  | _, 0 => 1
  | 0, (_ + 1) => 0
  | (n + 1), (k + 1) => qBinom n k + X ^ (k + 1) * qBinom n (k + 1)

@[simp] theorem qBinom_zero_right (n : ℕ) : qBinom n 0 = 1 := by
  cases n <;> rfl

@[simp] theorem qBinom_zero_succ (k : ℕ) : qBinom 0 (k + 1) = 0 := rfl

theorem qBinom_succ_succ (n k : ℕ) :
    qBinom (n + 1) (k + 1) = qBinom n k + X ^ (k + 1) * qBinom n (k + 1) := rfl

/-- The Gaussian binomial coefficient vanishes when `k > n`. -/
theorem qBinom_eq_zero_of_lt {n k : ℕ} (h : n < k) : qBinom n k = 0 := by
  induction n generalizing k with
  | zero => cases k with
    | zero => omega
    | succ k => rfl
  | succ n ih => cases k with
    | zero => omega
    | succ k => rw [qBinom_succ_succ, ih (by omega), ih (by omega), mul_zero, add_zero]

/-- `⟦ n , n ⟧_q = 1`. -/
@[simp] theorem qBinom_self (n : ℕ) : qBinom n n = 1 := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [qBinom_succ_succ, ih, qBinom_eq_zero_of_lt (Nat.lt_succ_self n), mul_zero, add_zero]

/-- The `q`-integer recurrence `[n+1]_q = 1 + q·[n]_q`. -/
theorem qNat_succ (n : ℕ) : qNat (n + 1) = 1 + X * qNat n := by
  rw [qNat, qNat, geom_sum_succ]
  ring

/-- The `q`-integer recurrence `[n+1]_q = [n]_q + q^n`. -/
theorem qNat_succ' (n : ℕ) : qNat (n + 1) = qNat n + X ^ n := by
  rw [qNat, qNat, Finset.sum_range_succ]

/-- `⟦ n , 1 ⟧_q = [n]_q`. -/
theorem qBinom_one_right (n : ℕ) : qBinom n 1 = qNat n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [show (1 : ℕ) = 0 + 1 from rfl, qBinom_succ_succ, qBinom_zero_right, ih,
      qNat_succ]
    ring

/-- The dual q-Pascal recurrence, valid for `k ≤ n`. -/
theorem qBinom_pascal' : ∀ {n k : ℕ}, k ≤ n →
    qBinom (n + 1) (k + 1) = X ^ (n - k) * qBinom n k + qBinom n (k + 1) := by
  intro n
  induction n with
  | zero =>
    intro k hk
    interval_cases k
    simp [qBinom]
  | succ n ih =>
    intro k hk
    cases k with
    | zero =>
      have hL : qBinom (n + 1 + 1) (0 + 1) = 1 + X * qNat (n + 1) := by
        rw [qBinom_succ_succ, qBinom_zero_right, qBinom_one_right, pow_one]
      have hR : X ^ (n + 1 - 0) * qBinom (n + 1) 0 + qBinom (n + 1) (0 + 1)
              = X ^ (n + 1) + qNat (n + 1) := by
        rw [qBinom_zero_right, mul_one, qBinom_one_right, Nat.sub_zero]
      rw [hL, hR, ← qNat_succ (n + 1), qNat_succ' (n + 1)]
      ring
    | succ m =>
      have hm : m ≤ n := Nat.succ_le_succ_iff.mp hk
      rcases lt_or_eq_of_le hm with hlt | heq
      · -- `m < n`: expand both sides down to level `n`
        have e1 : (X : Polynomial ℤ) ^ (m + 1 + 1) * X ^ (n - (m + 1)) = X ^ (n + 1) := by
          rw [← pow_add]; congr 1; omega
        have e2 : (X : Polynomial ℤ) ^ (n - m) * X ^ (m + 1) = X ^ (n + 1) := by
          rw [← pow_add]; congr 1; omega
        have hL : qBinom (n + 1 + 1) (m + 1 + 1)
            = X ^ (n - m) * qBinom n m + qBinom n (m + 1)
              + X ^ (n + 1) * qBinom n (m + 1) + X ^ (m + 1 + 1) * qBinom n (m + 1 + 1) := by
          rw [qBinom_succ_succ (n + 1) (m + 1), ih hm, ih hlt]
          rw [mul_add, ← mul_assoc, e1]
          ring
        have hR : X ^ (n + 1 - (m + 1)) * qBinom (n + 1) (m + 1) + qBinom (n + 1) (m + 1 + 1)
            = X ^ (n - m) * qBinom n m + X ^ (n + 1) * qBinom n (m + 1)
              + qBinom n (m + 1) + X ^ (m + 1 + 1) * qBinom n (m + 1 + 1) := by
          have e0 : n + 1 - (m + 1) = n - m := by omega
          rw [e0, qBinom_succ_succ n m, qBinom_succ_succ n (m + 1)]
          rw [mul_add, ← mul_assoc, e2]
          ring
        rw [hL, hR]; ring
      · -- `m = n`: both sides collapse to `1`
        subst heq
        rw [qBinom_succ_succ (m + 1) (m + 1), qBinom_self,
            qBinom_eq_zero_of_lt (by omega : m + 1 < m + 1 + 1)]
        simp

/-- **Symmetry of the Gaussian binomial coefficients**: `⟦ n , k ⟧ = ⟦ n , n-k ⟧`. -/
theorem qBinom_symm : ∀ {n k : ℕ}, k ≤ n → qBinom n k = qBinom n (n - k) := by
  intro n
  induction n with
  | zero =>
    intro k hk
    interval_cases k
    rfl
  | succ n ih =>
    intro k hk
    cases k with
    | zero =>
      rw [Nat.sub_zero, qBinom_zero_right, qBinom_self]
    | succ j =>
      have hj : j ≤ n := Nat.succ_le_succ_iff.mp hk
      rcases lt_or_eq_of_le hj with hlt | heq
      · -- `j < n`
        have hsub : n + 1 - (j + 1) = (n - j - 1) + 1 := by omega
        rw [hsub, qBinom_succ_succ, qBinom_pascal' (show n - j - 1 ≤ n by omega),
            ih (show n - j - 1 ≤ n by omega)]
        have hs2 : (n - j - 1) + 1 = n - j := by omega
        rw [hs2, ih (show n - j ≤ n by omega)]
        have hp1 : n - (n - j - 1) = j + 1 := by omega
        have hp3 : n - (n - j) = j := by omega
        rw [hp1, hp3]
        ring
      · -- `j = n`
        subst heq
        rw [qBinom_self]
        simp

/-- The q-integer specializes to `n` at `q = 1`. -/
@[simp] theorem qNat_eval_one (n : ℕ) : (qNat n).eval 1 = (n : ℤ) := by
  simp [qNat, eval_finset_sum]

/-- **Specialization at `q = 1`.**  Evaluating a Gaussian binomial coefficient at
`q = 1` recovers the ordinary binomial coefficient `Nat.choose n k`. -/
theorem qBinom_eval_one (n k : ℕ) :
    (qBinom n k).eval 1 = (Nat.choose n k : ℤ) := by
  induction n generalizing k with
  | zero => cases k <;> simp [qBinom]
  | succ n ih => cases k with
    | zero => simp
    | succ k =>
      rw [qBinom_succ_succ]
      simp only [eval_add, eval_mul, eval_pow, eval_X, one_pow, one_mul, ih]
      rw [Nat.choose_succ_succ]
      push_cast
      ring

/-- **A downstream consequence.**  Specializing the q-symmetry
`qBinom_symm` at `q = 1` (via `qBinom_eval_one`) recovers the classical
symmetry of the ordinary binomial coefficients `Nat.choose n k = Nat.choose n (n-k)`.
This identity is of course also available directly in Mathlib; the point here is
that it drops out of the q-analog developed above. -/
theorem choose_symm_from_q {n k : ℕ} (h : k ≤ n) :
    Nat.choose n k = Nat.choose n (n - k) := by
  have hq := congrArg (fun p => Polynomial.eval (1 : ℤ) p) (qBinom_symm h)
  simp only [qBinom_eval_one] at hq
  exact_mod_cast hq

/-- The q-Pascal recurrence and its dual agree on their overlap: combining
`qBinom_succ_succ` with `qBinom_pascal'` gives, for `k ≤ n`, the identity
`⟦n,k⟧ + q^{k+1}⟦n,k+1⟧ = q^{n-k}⟦n,k⟧ + ⟦n,k+1⟧`. -/
theorem qPascal_compat {n k : ℕ} (h : k ≤ n) :
    qBinom n k + X ^ (k + 1) * qBinom n (k + 1)
      = X ^ (n - k) * qBinom n k + qBinom n (k + 1) := by
  rw [← qBinom_succ_succ, qBinom_pascal' h]

/-- **Additivity of the q-integers**: `[a+b]_q = [a]_q + q^a · [b]_q`. -/
theorem qNat_add (a b : ℕ) : qNat (a + b) = qNat a + X ^ a * qNat b := by
  simp only [qNat, Finset.sum_range_add, pow_add, Finset.mul_sum]

/-- The q-factorial `[n]_q! = [1]_q · [2]_q ⋯ [n]_q ∈ ℤ[q]`. -/
noncomputable def qFactorial : ℕ → Polynomial ℤ
  | 0 => 1
  | (n + 1) => qFactorial n * qNat (n + 1)

@[simp] theorem qFactorial_zero : qFactorial 0 = 1 := rfl

theorem qFactorial_succ (n : ℕ) : qFactorial (n + 1) = qFactorial n * qNat (n + 1) := rfl

/-- **The q-factorial product formula.**  The q-analog of
`k! · (n-k)! · C(n,k) = n!`, stated as an identity in `ℤ[q]` (so it needs no
division): for `k ≤ n`,
`⟦n,k⟧_q · [k]_q! · [n-k]_q! = [n]_q!`. -/
theorem qFactorial_product : ∀ {n k : ℕ}, k ≤ n →
    qBinom n k * qFactorial k * qFactorial (n - k) = qFactorial n := by
  intro n
  induction n with
  | zero =>
    intro k hk
    interval_cases k
    simp [qFactorial]
  | succ n ih =>
    intro k hk
    cases k with
    | zero => simp [qFactorial]
    | succ j =>
      rcases Nat.lt_or_ge (j + 1) (n + 1) with hlt | hge
      · -- `j + 1 < n + 1`: the genuine inductive step
        have hjn : j ≤ n := by omega
        have hj1n : j + 1 ≤ n := by omega
        have hsub : n + 1 - (j + 1) = n - j := by omega
        have hnj : n - j = (n - j - 1) + 1 := by omega
        have IH1 := ih hjn
        have IH2 := ih hj1n
        -- expand the q-factorials in both inductive hypotheses
        rw [hnj, qFactorial_succ, show (n - j - 1) + 1 = n - j from by omega] at IH1
        rw [show n - (j + 1) = n - j - 1 from by omega, qFactorial_succ j] at IH2
        -- q-integer additivity gives `[n+1]_q = [j+1]_q + q^{j+1}·[n-j]_q`
        have hqadd : qNat (n + 1) = qNat (j + 1) + X ^ (j + 1) * qNat (n - j) := by
          have h := qNat_add (j + 1) (n - j)
          rw [show (j + 1) + (n - j) = n + 1 from by omega] at h
          exact h
        -- expand the goal and finish by a linear combination of the two IHs
        rw [hsub, qBinom_succ_succ, qFactorial_succ j, qFactorial_succ n,
            show qFactorial (n - j) = qFactorial (n - j - 1) * qNat (n - j) from by
              conv_lhs => rw [hnj, qFactorial_succ, show (n - j - 1) + 1 = n - j from by omega]]
        linear_combination (qNat (j + 1)) * IH1
          + (X ^ (j + 1) * qNat (n - j)) * IH2 - (qFactorial n) * hqadd
      · -- `j + 1 = n + 1`: both sides collapse
        have hje : j = n := by omega
        subst hje
        simp [qBinom_self]

/-- The q-factorial specializes to the ordinary factorial at `q = 1`. -/
@[simp] theorem qFactorial_eval_one (n : ℕ) :
    (qFactorial n).eval 1 = (n.factorial : ℤ) := by
  induction n with
  | zero => simp [qFactorial]
  | succ n ih =>
    rw [qFactorial_succ, eval_mul, ih]
    have hq : (qNat (n + 1)).eval 1 = ((n : ℤ) + 1) := by
      simp [qNat, eval_finset_sum]
    rw [hq, Nat.factorial_succ]
    push_cast
    ring

/-- **A downstream consequence.**  Specializing the q-factorial product formula
at `q = 1` recovers the classical identity `C(n,k) · k! · (n-k)! = n!`. -/
theorem choose_mul_factorial_from_q {n k : ℕ} (h : k ≤ n) :
    (Nat.choose n k) * (Nat.factorial k) * (Nat.factorial (n - k)) = Nat.factorial n := by
  have hq := congrArg (fun p => Polynomial.eval (1 : ℤ) p) (qFactorial_product h)
  simp only [eval_mul, qBinom_eval_one, qFactorial_eval_one] at hq
  exact_mod_cast hq

end GarsiaQBinom