/-
# q-Vandermonde convolution and the q-binomial (Rothe) theorem

This file develops the theory of **Gaussian binomial coefficients** `⟦n, k⟧_q`
over an arbitrary commutative (semi)ring, *without* any division, and proves the
two central identities of the theory:

* `qBinom_rothe` — the **q-binomial theorem** of Rothe,
  `∏_{i<n} (1 + q^i x) = ∑_{k ≤ n} q^{k(k-1)/2} ⟦n,k⟧_q x^k`;
* `qBinom_vandermonde` — the **q-Vandermonde convolution**,
  `⟦m+n, k⟧_q = ∑_{j ≤ k} q^{(m-j)(k-j)} ⟦m,j⟧_q ⟦n,k-j⟧_q`.

The route to the second identity is a genuine generating-function argument:
Rothe's theorem is upgraded to a *coefficient* statement in the polynomial ring
`R[X]`, the factorisation `∏_{i<m+n} = (∏_{i<m}) * (∏_{i<n} shifted)` is fed
through `Polynomial.coeff_mul`, and the resulting identity carries a spurious
common factor `q^{k(k-1)/2}`.  That factor is cancelled in the *universal* ring
`ℤ[X]` (an integral domain, where `X ≠ 0`), and the cancelled identity is then
transported back to an arbitrary commutative ring by the specialisation
homomorphism `Polynomial.aeval q`, using that `qBinom` commutes with ring maps.

The `q = 1` specialisations recover the classical binomial theorem and the
classical Vandermonde convolution for `Nat.choose`.
-/

import Mathlib

namespace Catalog.Applications.QBinomial

open Finset Polynomial

variable {R : Type*} [CommSemiring R]

/-! ## Arithmetic of the exponent `k(k-1)/2 = C(k,2)` -/

lemma choose_two_succ (j : ℕ) : (j + 1).choose 2 = j.choose 2 + j := by
  rw [Nat.choose_succ_succ, Nat.choose_one_right, Nat.add_comm]

/-- The quadratic exponent is "additive up to the cross term": this is the
numerical shadow of the q-Vandermonde convolution. -/
lemma choose_two_add (a b : ℕ) : (a + b).choose 2 = a.choose 2 + b.choose 2 + a * b := by
  induction b with
  | zero => simp
  | succ b ih =>
      rw [← Nat.add_assoc, choose_two_succ, choose_two_succ, ih]
      ring

/-! ## Definition and basic theory -/

/-- The Gaussian binomial coefficient `⟦n, k⟧_q`, defined by the `q`-Pascal
recurrence `⟦n+1,k+1⟧ = ⟦n,k⟧ + q^{k+1} ⟦n,k+1⟧`.  This is division-free, so it
makes sense over an arbitrary commutative semiring. -/
def qBinom (q : R) : ℕ → ℕ → R
  | _, 0 => 1
  | 0, _ + 1 => 0
  | n + 1, k + 1 => qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1)

@[simp] lemma qBinom_zero_right (q : R) (n : ℕ) : qBinom q n 0 = 1 := by
  cases n <;> rfl

@[simp] lemma qBinom_zero_succ (q : R) (k : ℕ) : qBinom q 0 (k + 1) = 0 := rfl

/-- The `q`-Pascal recurrence, first form. -/
lemma qBinom_succ_succ (q : R) (n k : ℕ) :
    qBinom q (n + 1) (k + 1) = qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1) := rfl

lemma qBinom_eq_zero_of_lt (q : R) : ∀ {n k : ℕ}, n < k → qBinom q n k = 0 := by
  intro n
  induction n with
  | zero => intro k hk; obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hk.ne'; simp
  | succ n ih =>
      intro k hk
      obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : k ≠ 0)
      rw [qBinom_succ_succ, ih (by omega), ih (by omega), mul_zero, add_zero]

@[simp] lemma qBinom_self (q : R) (n : ℕ) : qBinom q n n = 1 := by
  induction n with
  | zero => rfl
  | succ n ih => rw [qBinom_succ_succ, ih, qBinom_eq_zero_of_lt q (by omega), mul_zero, add_zero]

/-- `⟦n,1⟧_q = 1 + q + ⋯ + q^{n-1}`, the `q`-analogue of the integer `n`. -/
lemma qBinom_one (q : R) (n : ℕ) : qBinom q n 1 = ∑ i ∈ range n, q ^ i := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [show (1 : ℕ) = 0 + 1 from rfl, qBinom_succ_succ, ih]
      simp [geom_sum_succ, add_comm]

/-- The `q`-Pascal recurrence, second form.  Here `n - k` is truncated
subtraction; the statement is nevertheless valid for all `k`, because both
`⟦n,k⟧` and `⟦n,k+1⟧` vanish once `k > n`. -/
lemma qBinom_succ_succ' (q : R) (n k : ℕ) :
    qBinom q (n + 1) (k + 1) = q ^ (n - k) * qBinom q n k + qBinom q n (k + 1) := by
  induction n generalizing k with
  | zero =>
      match k with
      | 0 => simp
      | (k + 1) => simp [qBinom_succ_succ]
  | succ n ih =>
      match k with
      | 0 =>
          rw [qBinom_succ_succ, qBinom_one, qBinom_zero_right, Nat.sub_zero, pow_one, mul_one]
          have h1 : ∑ i ∈ range (n + 1 + 1), q ^ i = q * ∑ i ∈ range (n + 1), q ^ i + 1 :=
            geom_sum_succ
          have h2 : ∑ i ∈ range (n + 1 + 1), q ^ i = q ^ (n + 1) + ∑ i ∈ range (n + 1), q ^ i :=
            geom_sum_succ'
          rw [add_comm (1 : R)]
          exact h1.symm.trans h2
      | (k + 1) =>
          calc qBinom q (n + 1 + 1) (k + 1 + 1)
              = qBinom q (n + 1) (k + 1) + q ^ (k + 1 + 1) * qBinom q (n + 1) (k + 1 + 1) := rfl
            _ = (q ^ (n - k) * qBinom q n k + qBinom q n (k + 1))
                  + q ^ (k + 1 + 1) * (q ^ (n - (k + 1)) * qBinom q n (k + 1)
                      + qBinom q n (k + 1 + 1)) := by rw [ih k, ih (k + 1)]
            _ = q ^ (n - k) * (qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1))
                  + (qBinom q n (k + 1) + q ^ (k + 1 + 1) * qBinom q n (k + 1 + 1)) := by
                  rcases Nat.lt_or_ge n (k + 1) with h | h
                  · rw [qBinom_eq_zero_of_lt q h]; ring
                  · have hP : q ^ (k + 1 + 1) * q ^ (n - (k + 1)) = q ^ (n - k) * q ^ (k + 1) := by
                      rw [← pow_add, ← pow_add]; congr 1; omega
                    rw [mul_add, mul_add, ← mul_assoc, hP]
                    ring
            _ = q ^ (n + 1 - (k + 1)) * qBinom q (n + 1) (k + 1) + qBinom q (n + 1) (k + 1 + 1) := by
                  rw [Nat.succ_sub_succ]; rfl

/-! ## Compatibility with ring homomorphisms -/

/-- Gaussian binomial coefficients are *universal* polynomial expressions in `q`:
they commute with every ring homomorphism. -/
lemma map_qBinom {S : Type*} [CommSemiring S] (f : R →+* S) (q : R) (n k : ℕ) :
    f (qBinom q n k) = qBinom (f q) n k := by
  induction n generalizing k with
  | zero => match k with
            | 0 => simp
            | (k + 1) => simp
  | succ n ih =>
      match k with
      | 0 => simp
      | (k + 1) => simp [qBinom_succ_succ, ih, map_add, map_mul, map_pow]

/-- Specialising the universal Gaussian binomial coefficient `⟦n,k⟧_X ∈ ℤ[X]` at an
element `q` of a commutative ring returns `⟦n,k⟧_q`. -/
lemma aeval_qBinom {S : Type*} [CommRing S] (q : S) (n k : ℕ) :
    Polynomial.aeval q (qBinom (X : ℤ[X]) n k) = qBinom q n k := by
  have := map_qBinom (Polynomial.aeval q : ℤ[X] →ₐ[ℤ] S).toRingHom (X : ℤ[X]) n k
  simpa using this

/-! ## The q-binomial theorem (Rothe) -/

/-- The coefficient recurrence behind Rothe's theorem: multiplying by `1 + q^n x`
sends `q^{C(k,2)} ⟦n,k⟧` to `q^{C(k,2)} ⟦n+1,k⟧`. -/
lemma qBinom_rothe_step (q x : R) (n j : ℕ) :
    q ^ ((j + 1).choose 2) * qBinom q (n + 1) (j + 1) * x ^ (j + 1)
      = q ^ ((j + 1).choose 2) * qBinom q n (j + 1) * x ^ (j + 1)
        + q ^ (j.choose 2) * qBinom q n j * x ^ j * (q ^ n * x) := by
  rw [qBinom_succ_succ' q n j, choose_two_succ]
  rcases Nat.lt_or_ge n j with h | h
  · rw [qBinom_eq_zero_of_lt q h]; ring
  · have h1 : q ^ (j.choose 2 + j) * q ^ (n - j) = q ^ n * q ^ (j.choose 2) := by
      rw [← pow_add, ← pow_add]; congr 1; omega
    calc q ^ (j.choose 2 + j) * (q ^ (n - j) * qBinom q n j + qBinom q n (j + 1)) * x ^ (j + 1)
        = (q ^ (j.choose 2 + j) * q ^ (n - j)) * (qBinom q n j * x ^ (j + 1))
            + q ^ (j.choose 2 + j) * qBinom q n (j + 1) * x ^ (j + 1) := by ring
      _ = (q ^ n * q ^ (j.choose 2)) * (qBinom q n j * x ^ (j + 1))
            + q ^ (j.choose 2 + j) * qBinom q n (j + 1) * x ^ (j + 1) := by rw [h1]
      _ = q ^ (j.choose 2 + j) * qBinom q n (j + 1) * x ^ (j + 1)
            + q ^ (j.choose 2) * qBinom q n j * x ^ j * (q ^ n * x) := by rw [pow_succ]; ring

/-- **Rothe's q-binomial theorem**:
`∏_{i<n} (1 + q^i x) = ∑_{k ≤ n} q^{k(k-1)/2} ⟦n,k⟧_q x^k`,
with the exponent written as the binomial coefficient `k.choose 2 = k(k-1)/2`. -/
theorem qBinom_rothe (q x : R) (n : ℕ) :
    ∏ i ∈ range n, (1 + q ^ i * x) =
      ∑ k ∈ range (n + 1), q ^ (k.choose 2) * qBinom q n k * x ^ k := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hext : (∑ j ∈ range (n + 1), q ^ ((j + 1).choose 2) * qBinom q n (j + 1) * x ^ (j + 1))
            + q ^ ((0 : ℕ).choose 2) * qBinom q n 0 * x ^ 0
          = ∑ k ∈ range (n + 1), q ^ (k.choose 2) * qBinom q n k * x ^ k := by
        rw [← Finset.sum_range_succ' (fun k => q ^ (k.choose 2) * qBinom q n k * x ^ k) (n + 1),
          Finset.sum_range_succ (fun k => q ^ (k.choose 2) * qBinom q n k * x ^ k) (n + 1),
          qBinom_eq_zero_of_lt q (by omega : n < n + 1)]
        ring
      rw [prod_range_succ, ih, mul_add, mul_one, Finset.sum_mul,
        Finset.sum_range_succ' (fun k => q ^ (k.choose 2) * qBinom q (n + 1) k * x ^ k) (n + 1),
        ← hext, add_right_comm, ← Finset.sum_add_distrib]
      congr 1
      · exact Finset.sum_congr rfl fun j _ => (qBinom_rothe_step q x n j).symm
      · simp

/-- Rothe's theorem, with the exponent literally written `k*(k-1)/2`. -/
theorem qBinom_rothe' (q x : R) (n : ℕ) :
    ∏ i ∈ range n, (1 + q ^ i * x) =
      ∑ k ∈ range (n + 1), q ^ (k * (k - 1) / 2) * qBinom q n k * x ^ k := by
  rw [qBinom_rothe]
  exact Finset.sum_congr rfl fun k _ => by rw [Nat.choose_two_right]

/-! ## Coefficient form of Rothe's theorem -/

/-- The polynomial `∏_{i<n} (1 + q^i X) ∈ R[X]` has `k`-th coefficient
`q^{k(k-1)/2} ⟦n,k⟧_q`, for **every** `k` (both sides vanish for `k > n`). -/
theorem coeff_prod_qBinom (q : R) (n k : ℕ) :
    (∏ i ∈ range n, (1 + C (q ^ i) * X) : R[X]).coeff k = q ^ (k.choose 2) * qBinom q n k := by
  have h := qBinom_rothe (C q : R[X]) X n
  have hq : ∀ j : ℕ, (C q : R[X]) ^ j = C (q ^ j) := fun j => (map_pow C q j).symm
  have hb : ∀ j : ℕ, qBinom (C q : R[X]) n j = C (qBinom q n j) := fun j =>
    (map_qBinom (C : R →+* R[X]) q n j).symm
  simp only [hq, hb] at h
  rw [h, finset_sum_coeff]
  rcases Nat.lt_or_ge k (n + 1) with hk | hk
  · rw [Finset.sum_eq_single k]
    · rw [← C_mul, coeff_C_mul, coeff_X_pow, if_pos rfl, mul_one]
    · intro j _ hjk
      rw [← C_mul, coeff_C_mul, coeff_X_pow, if_neg (Ne.symm hjk), mul_zero]
    · intro hk'
      exact absurd (Finset.mem_range.mpr hk) hk'
  · rw [qBinom_eq_zero_of_lt q (by omega), mul_zero]
    refine Finset.sum_eq_zero fun j hj => ?_
    simp only [Finset.mem_range] at hj
    rw [← C_mul, coeff_C_mul, coeff_X_pow, if_neg (by omega), mul_zero]

/-- The shifted product `∏_{i<n}(1 + q^{m+i} X)` has `j`-th coefficient
`q^{C(j,2) + m j} ⟦n,j⟧_q`. -/
theorem coeff_prod_qBinom_shift (q : R) (m n j : ℕ) :
    (∏ i ∈ range n, (1 + C (q ^ (m + i)) * X) : R[X]).coeff j
      = q ^ (j.choose 2 + m * j) * qBinom q n j := by
  have hprod : (∏ i ∈ range n, (1 + C (q ^ (m + i)) * X) : R[X])
      = ∏ i ∈ range n, (1 + C (q ^ i) * (C (q ^ m) * X)) := by
    refine Finset.prod_congr rfl fun i _ => ?_
    rw [← mul_assoc, ← C_mul, ← pow_add, add_comm i m]
  have h := qBinom_rothe (C q : R[X]) (C (q ^ m) * X) n
  have hq : ∀ t : ℕ, (C q : R[X]) ^ t = C (q ^ t) := fun t => (map_pow C q t).symm
  have hb : ∀ t : ℕ, qBinom (C q : R[X]) n t = C (qBinom q n t) := fun t =>
    (map_qBinom (C : R →+* R[X]) q n t).symm
  simp only [hq, hb] at h
  have hterm : ∀ t : ℕ,
      (C (q ^ (t.choose 2)) * C (qBinom q n t) * (C (q ^ m) * X) ^ t : R[X])
        = C (q ^ (t.choose 2 + m * t) * qBinom q n t) * X ^ t := by
    intro t
    rw [mul_pow, ← C_pow, ← mul_assoc, ← C_mul, ← C_mul]
    congr 2
    rw [← pow_mul, pow_add]
    ring
  rw [hprod, h, finset_sum_coeff]
  simp only [hterm]
  rcases Nat.lt_or_ge j (n + 1) with hj | hj
  · rw [Finset.sum_eq_single j]
    · rw [coeff_C_mul, coeff_X_pow, if_pos rfl, mul_one]
    · intro t _ htj
      rw [coeff_C_mul, coeff_X_pow, if_neg (Ne.symm htj), mul_zero]
    · intro hj'
      exact absurd (Finset.mem_range.mpr hj) hj'
  · rw [qBinom_eq_zero_of_lt q (by omega), mul_zero]
    refine Finset.sum_eq_zero fun t ht => ?_
    simp only [Finset.mem_range] at ht
    rw [coeff_C_mul, coeff_X_pow, if_neg (by omega), mul_zero]

/-! ## q-Vandermonde convolution -/

/-- The generating-function identity underlying q-Vandermonde: the two sides
agree up to the common factor `q^{k(k-1)/2}`.  Valid over any commutative
semiring. -/
theorem qBinom_vandermonde_scaled (q : R) (m n k : ℕ) :
    q ^ (k.choose 2) * qBinom q (m + n) k =
      ∑ j ∈ range (k + 1),
        q ^ (j.choose 2 + (k - j).choose 2 + m * (k - j)) * qBinom q m j * qBinom q n (k - j) := by
  have hsplit : (∏ i ∈ range (m + n), (1 + C (q ^ i) * X) : R[X])
      = (∏ i ∈ range m, (1 + C (q ^ i) * X)) * ∏ i ∈ range n, (1 + C (q ^ (m + i)) * X) :=
    Finset.prod_range_add _ m n
  have hc := coeff_prod_qBinom q (m + n) k
  rw [hsplit, Polynomial.coeff_mul] at hc
  rw [← hc, Finset.Nat.sum_antidiagonal_eq_sum_range_succ
    (fun i j => (∏ t ∈ range m, (1 + C (q ^ t) * X) : R[X]).coeff i *
      (∏ t ∈ range n, (1 + C (q ^ (m + t)) * X) : R[X]).coeff j)]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [coeff_prod_qBinom, coeff_prod_qBinom_shift, pow_add]
  ring

/-- The q-Vandermonde convolution in the universal ring `ℤ[X]` (with `q = X`),
obtained from `qBinom_vandermonde_scaled` by cancelling `X^{k(k-1)/2}`, which is
legitimate because `ℤ[X]` is an integral domain. -/
theorem qBinom_vandermonde_int (m n k : ℕ) :
    qBinom (X : ℤ[X]) (m + n) k =
      ∑ j ∈ range (k + 1),
        (X : ℤ[X]) ^ ((m - j) * (k - j)) * qBinom (X : ℤ[X]) m j * qBinom (X : ℤ[X]) n (k - j) := by
  have hX : ((X : ℤ[X]) ^ (k.choose 2)) ≠ 0 := pow_ne_zero _ Polynomial.X_ne_zero
  refine mul_left_cancel₀ hX ?_
  rw [qBinom_vandermonde_scaled (X : ℤ[X]) m n k, Finset.mul_sum]
  refine Finset.sum_congr rfl fun j hj => ?_
  simp only [Finset.mem_range] at hj
  rcases Nat.lt_or_ge j (m + 1) with hjm | hjm
  · have hexp : j.choose 2 + (k - j).choose 2 + m * (k - j)
        = k.choose 2 + (m - j) * (k - j) := by
      have h1 : k.choose 2 = j.choose 2 + (k - j).choose 2 + j * (k - j) := by
        have : j + (k - j) = k := by omega
        rw [← this, choose_two_add]
        simp
      have h2 : m * (k - j) = j * (k - j) + (m - j) * (k - j) := by
        rw [← Nat.add_mul]
        congr 1
        omega
      omega
    rw [hexp, pow_add]
    ring
  · rw [qBinom_eq_zero_of_lt (X : ℤ[X]) hjm]
    ring

/-- **The q-Vandermonde convolution**, over an arbitrary commutative ring:
`⟦m+n, k⟧_q = ∑_{j ≤ k} q^{(m-j)(k-j)} ⟦m,j⟧_q ⟦n,k-j⟧_q`. -/
theorem qBinom_vandermonde {R : Type*} [CommRing R] (q : R) (m n k : ℕ) :
    qBinom q (m + n) k =
      ∑ j ∈ range (k + 1), q ^ ((m - j) * (k - j)) * qBinom q m j * qBinom q n (k - j) := by
  have hmap := congrArg (fun p : ℤ[X] => Polynomial.aeval q p) (qBinom_vandermonde_int m n k)
  simp only [map_sum, map_mul, map_pow, Polynomial.aeval_X] at hmap
  simp only [aeval_qBinom] at hmap
  exact hmap

/-! ## Classical specialisations at `q = 1` -/

lemma qBinom_one_eq_choose (n k : ℕ) : qBinom (1 : ℤ) n k = (n.choose k : ℤ) := by
  induction n generalizing k with
  | zero => match k with
            | 0 => simp
            | (k + 1) => simp
  | succ n ih =>
      match k with
      | 0 => simp
      | (k + 1) => rw [qBinom_succ_succ, ih, ih]; push_cast [Nat.choose_succ_succ]; ring

/-- Specialising q-Vandermonde at `q = 1` recovers the classical Vandermonde
convolution `C(m+n,k) = ∑_{j≤k} C(m,j) C(n,k-j)`. -/
theorem choose_vandermonde_of_qVandermonde (m n k : ℕ) :
    ((m + n).choose k : ℤ) = ∑ j ∈ range (k + 1), (m.choose j : ℤ) * (n.choose (k - j) : ℤ) := by
  have h := qBinom_vandermonde (1 : ℤ) m n k
  simp only [qBinom_one_eq_choose, one_pow, one_mul] at h
  exact h

/-- Specialising Rothe's theorem at `q = 1` recovers `(1+x)^n = ∑_k C(n,k) x^k`. -/
theorem add_pow_of_qBinom_rothe (x : ℤ) (n : ℕ) :
    (1 + x) ^ n = ∑ k ∈ range (n + 1), (n.choose k : ℤ) * x ^ k := by
  have h := qBinom_rothe (1 : ℤ) x n
  simp only [one_pow, one_mul, qBinom_one_eq_choose, Finset.prod_const, Finset.card_range] at h
  exact h

end Catalog.Applications.QBinomial

/-
## Lab notes (experimental data behind this file)

Recorded with `#eval` on the definition above, over `ℤ`:

* `⟦n,k⟧_2` for `n = 0..5`:
  `[1] [1,1] [1,3,1] [1,7,7,1] [1,15,35,15,1] [1,31,155,155,31,1]`  (OEIS A022166).
* q-Vandermonde `⟦m+n,k⟧ = ∑_j q^{(m-j)(k-j)} ⟦m,j⟧⟦n,k-j⟧` was checked with no
  counterexample for `q ∈ {-2,0,1,2,5}`, `m,n ≤ 6`, `k ≤ 8`; the natural-subtraction
  exponent is safe precisely because `⟦m,j⟧ = 0` for `j > m`.
* Rothe `∏_{i<n}(1+q^i x) = ∑_k q^{k(k-1)/2}⟦n,k⟧x^k` was checked for
  `q ∈ {-2,0,1,3}`, `x ∈ {-1,2,7}`, `n ≤ 7`, again with no counterexample.
* A variant of the reflected convolution with the exponent `j*(n-k+j)` written in
  truncated `ℕ`-arithmetic *fails* at `q = 2, m = n = 1, k = 2` (`1 ≠ 2`); the correct
  exponent is `j*(n-(k-j))`, proved as `qBinom_vandermonde'`.

See `ComputationalEvidence.md` for the full tables.
-/