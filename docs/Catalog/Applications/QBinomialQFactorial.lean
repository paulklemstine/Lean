/-
# The q-factorial and the division-free product formula for Gaussian binomials

Built on `Applications.QVandermondeQBinomial` (the recursive `qBinom`) and
`Applications.QBinomialGaussProduct` (the `q`-Pochhammer symbol `qPoch`).

* `qInt q n = [n]_q = 1 + q + ⋯ + q^{n-1}` and `qFactorial q n = [n]_q! = ∏_{i=1}^n [i]_q`.
* `qFactorial_product` — **the q-factorial product formula**
  `[k]_q! · [n-k]_q! · ⟦n,k⟧_q = [n]_q!` for `k ≤ n`, over every commutative
  *semiring* (so in particular in `ℤ[q]`, see `qFactorial_product_int`).
  This is the `q`-analogue of `k! (n-k)! C(n,k) = n!`, which is recovered at
  `q = 1` (`choose_mul_factorial_of_qFactorial`).
* `qBinom_int_unique` — in `ℤ[q]` the product formula *characterises* `qBinom`.
* `qPoch_eq_qFactorial` — `(q;q)_n = (1-q)^n [n]_q!`.
* `qFactorial_int_monic`, `qFactorial_int_natDegree` — `[n]_q!` is monic of degree `C(n,2)`.
* **Cyclotomic bridge.**  `qFactorial_cyclotomic`:
  `[n]_q! = ∏_{d=2}^{n} Φ_d(q)^{⌊n/d⌋}`, and as a consequence
  `qBinom_cyclotomic`: for `k ≤ n`,
  `⟦n,k⟧_q = ∏_{2 ≤ d ≤ n,\ d ≤ (k mod d) + ((n-k) mod d)} Φ_d(q)`,
  i.e. every Gaussian binomial coefficient is a *squarefree* product of distinct
  cyclotomic polynomials, `Φ_d` appearing exactly when adding `k` and `n-k` in
  "base `d`" produces a carry in the last digit (`qBinom_cyclotomic_exponent_le_one`).
-/

import Applications.QBinomialPolynomiality

namespace Catalog.Applications.QBinomial

open Finset Polynomial

section Semiring

variable {R : Type*} [CommSemiring R]

/-- The `q`-integer `[n]_q = ∑_{i<n} q^i`. -/
def qInt (q : R) (n : ℕ) : R := ∑ i ∈ range n, q ^ i

/-- The `q`-factorial `[n]_q! = ∏_{i=1}^{n} [i]_q`. -/
def qFactorial (q : R) (n : ℕ) : R := ∏ i ∈ range n, qInt q (i + 1)

@[simp] lemma qInt_zero (q : R) : qInt q 0 = 0 := by simp [qInt]

@[simp] lemma qFactorial_zero (q : R) : qFactorial q 0 = 1 := by simp [qFactorial]

lemma qFactorial_succ (q : R) (n : ℕ) :
    qFactorial q (n + 1) = qFactorial q n * qInt q (n + 1) := by
  rw [qFactorial, qFactorial, prod_range_succ]

/-- `q`-integers are additive up to a shift: `[a+b]_q = [a]_q + q^a [b]_q`. -/
lemma qInt_add (q : R) (a b : ℕ) : qInt q (a + b) = qInt q a + q ^ a * qInt q b := by
  rw [qInt, qInt, qInt, sum_range_add, mul_sum]
  simp [pow_add]

/-- `qBinom q n 1 = [n]_q`. -/
lemma qBinom_one_eq_qInt (q : R) (n : ℕ) : qBinom q n 1 = qInt q n := qBinom_one q n

/-- **The q-factorial product formula** (division free):
`[k]_q! · [n-k]_q! · ⟦n,k⟧_q = [n]_q!` for `k ≤ n`, in any commutative semiring. -/
theorem qFactorial_product (q : R) : ∀ {n k : ℕ}, k ≤ n →
    qFactorial q k * qFactorial q (n - k) * qBinom q n k = qFactorial q n := by
  intro n
  induction n with
  | zero =>
      intro k hk
      obtain rfl : k = 0 := by omega
      simp
  | succ n ih =>
      intro k hk
      match k with
      | 0 => simp
      | (k + 1) =>
          rcases Nat.lt_or_ge n (k + 1) with h | h
          · obtain rfl : k = n := by omega
            simp
          · have h1 := ih (show k ≤ n by omega)
            have h2 := ih (show k + 1 ≤ n by omega)
            have e2 : qFactorial q (n - k) = qFactorial q (n - (k + 1)) * qInt q (n - k) := by
              rw [show n - k = (n - (k + 1)) + 1 by omega, qFactorial_succ]
            have e3 : qInt q (n + 1) = qInt q (k + 1) + q ^ (k + 1) * qInt q (n - k) := by
              rw [← qInt_add]; congr 1; omega
            rw [show n + 1 - (k + 1) = n - k by omega, qBinom_succ_succ, qFactorial_succ q n, e3]
            calc qFactorial q (k + 1) * qFactorial q (n - k) *
                  (qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1))
                = qFactorial q k * qFactorial q (n - k) * qBinom q n k * qInt q (k + 1) +
                    q ^ (k + 1) * qInt q (n - k) *
                      (qFactorial q (k + 1) * qFactorial q (n - (k + 1)) * qBinom q n (k + 1)) := by
                  rw [qFactorial_succ q k, e2]; ring
              _ = qFactorial q n * qInt q (k + 1) + q ^ (k + 1) * qInt q (n - k) * qFactorial q n := by
                  rw [h1, h2]
              _ = _ := by ring

/-- `[n]_1 = n`. -/
lemma qInt_one (n : ℕ) : qInt (1 : R) n = n := by simp [qInt]

/-- `[n]_1! = n!`. -/
lemma qFactorial_one (n : ℕ) : qFactorial (1 : R) n = n.factorial := by
  induction n with
  | zero => simp
  | succ n ih => rw [qFactorial_succ, ih, qInt_one, Nat.factorial_succ]; push_cast; ring

end Semiring

/-- The product formula in the universal ring `ℤ[q]`. -/
theorem qFactorial_product_int {n k : ℕ} (h : k ≤ n) :
    qFactorial (X : ℤ[X]) k * qFactorial X (n - k) * qBinom X n k = qFactorial X n :=
  qFactorial_product X h

/-- At `q = 1` the product formula specialises to `k! (n-k)! C(n,k) = n!`. -/
theorem choose_mul_factorial_of_qFactorial {n k : ℕ} (h : k ≤ n) :
    k.factorial * (n - k).factorial * n.choose k = n.factorial := by
  have := qFactorial_product (1 : ℤ) h
  rw [qFactorial_one, qFactorial_one, qFactorial_one, qBinom_one_eq_choose] at this
  exact_mod_cast this

section Ring

variable {R : Type*} [CommRing R]

/-- `(1-q) [n]_q = 1 - q^n`. -/
lemma one_sub_mul_qInt (q : R) (n : ℕ) : (1 - q) * qInt q n = 1 - q ^ n := by
  rw [qInt, mul_comm, geom_sum_mul_neg]

/-- The `q`-Pochhammer symbol is `(1-q)^n` times the `q`-factorial. -/
theorem qPoch_eq_qFactorial (q : R) (n : ℕ) : qPoch q n = (1 - q) ^ n * qFactorial q n := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [qPoch_succ, ih, qFactorial_succ, ← one_sub_mul_qInt]
      ring

end Ring

/-! ## Uniqueness, degree and monicity in `ℤ[q]` -/

lemma qInt_int_monic (n : ℕ) : (qInt (X : ℤ[X]) (n + 1)).Monic := by
  rw [qInt, sum_range_succ, add_comm]
  apply monic_X_pow_add
  refine (degree_sum_le _ _).trans_lt ?_
  refine (Finset.sup_lt_iff (WithBot.bot_lt_coe n)).2 fun i hi => ?_
  rw [degree_X_pow]
  exact WithBot.coe_lt_coe.2 (mem_range.1 hi)

lemma qInt_int_natDegree (n : ℕ) : (qInt (X : ℤ[X]) (n + 1)).natDegree = n := by
  rw [qInt, sum_range_succ, add_comm, natDegree_add_eq_left_of_degree_lt]
  · simp
  · refine (degree_sum_le _ _).trans_lt ?_
    rw [degree_X_pow]
    refine (Finset.sup_lt_iff (WithBot.bot_lt_coe n)).2 fun i hi => ?_
    rw [degree_X_pow]
    exact WithBot.coe_lt_coe.2 (mem_range.1 hi)

theorem qFactorial_int_monic (n : ℕ) : (qFactorial (X : ℤ[X]) n).Monic :=
  monic_prod_of_monic _ _ fun i _ => qInt_int_monic i

/-- `[n]_q!` has degree `C(n,2) = n(n-1)/2`. -/
theorem qFactorial_int_natDegree (n : ℕ) : (qFactorial (X : ℤ[X]) n).natDegree = n.choose 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [qFactorial_succ, (qFactorial_int_monic n).natDegree_mul (qInt_int_monic n), ih,
        qInt_int_natDegree, choose_two_succ]

lemma qFactorial_int_ne_zero (n : ℕ) : qFactorial (X : ℤ[X]) n ≠ 0 :=
  (qFactorial_int_monic n).ne_zero

/-- In `ℤ[q]` the product formula characterises the Gaussian binomial coefficient. -/
theorem qBinom_int_unique {n k : ℕ} (h : k ≤ n) (P : ℤ[X])
    (hP : qFactorial (X : ℤ[X]) k * qFactorial X (n - k) * P = qFactorial X n) :
    P = qBinom X n k := by
  refine mul_left_cancel₀ (mul_ne_zero (qFactorial_int_ne_zero k)
    (qFactorial_int_ne_zero (n - k))) ?_
  rw [hP, qFactorial_product_int h]

/-! ## The cyclotomic factorisation -/

lemma qInt_int_eq_prod_cyclotomic (n : ℕ) :
    qInt (X : ℤ[X]) (n + 1) = ∏ d ∈ (Icc 2 (n + 1)).filter (· ∣ n + 1), cyclotomic d ℤ := by
  rw [qInt, ← prod_cyclotomic_eq_geom_sum (Nat.succ_pos n)]
  congr 1
  ext d
  simp only [mem_filter, mem_Icc, mem_erase, Nat.mem_divisors]
  constructor
  · rintro ⟨h1, h2, -⟩
    have : d ≠ 0 := by rintro rfl; simp at h2
    exact ⟨⟨by omega, Nat.le_of_dvd (Nat.succ_pos n) h2⟩, h2⟩
  · rintro ⟨⟨h1, -⟩, h2⟩
    exact ⟨by omega, h2, by omega⟩

/-- **Cyclotomic factorisation of the q-factorial**: `[n]_q! = ∏_{d=2}^{n} Φ_d(q)^{⌊n/d⌋}`. -/
theorem qFactorial_cyclotomic (n : ℕ) :
    qFactorial (X : ℤ[X]) n = ∏ d ∈ Icc 2 n, cyclotomic d ℤ ^ (n / d) := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hsplit : ∀ d ∈ Icc 2 (n + 1), cyclotomic d ℤ ^ ((n + 1) / d) =
          cyclotomic d ℤ ^ (n / d) * (if d ∣ n + 1 then cyclotomic d ℤ else 1) := by
        intro d hd
        rw [Nat.succ_div]
        split_ifs <;> simp [pow_succ]
      rw [qFactorial_succ, ih, qInt_int_eq_prod_cyclotomic, prod_congr rfl hsplit, prod_mul_distrib,
        ← prod_filter]
      congr 1
      rcases Nat.lt_or_ge n 1 with hn | hn
      · obtain rfl : n = 0 := by omega
        simp
      · rw [← Finset.insert_Icc_right_eq_Icc_add_one (by omega : 2 ≤ n + 1), prod_insert (by simp)]
        rw [Nat.div_eq_of_lt (by omega : n < n + 1), pow_zero, one_mul]

/-- Variant of `qFactorial_cyclotomic` with an enlarged index range. -/
lemma qFactorial_cyclotomic_le {k N : ℕ} (h : k ≤ N) :
    qFactorial (X : ℤ[X]) k = ∏ d ∈ Icc 2 N, cyclotomic d ℤ ^ (k / d) := by
  rw [qFactorial_cyclotomic]
  refine prod_subset (Icc_subset_Icc_right h) fun d hd hdk => ?_
  simp only [mem_Icc, not_and, not_le] at hd hdk
  rw [Nat.div_eq_of_lt (hdk hd.1), pow_zero]

/-- **Cyclotomic factorisation of Gaussian binomials** (exponent form). -/
theorem qBinom_cyclotomic_pow {n k : ℕ} (h : k ≤ n) :
    qBinom (X : ℤ[X]) n k = ∏ d ∈ Icc 2 n, cyclotomic d ℤ ^ (n / d - k / d - (n - k) / d) := by
  symm
  apply qBinom_int_unique h
  rw [qFactorial_cyclotomic_le h, qFactorial_cyclotomic_le (Nat.sub_le n k),
    qFactorial_cyclotomic n, ← prod_mul_distrib, ← prod_mul_distrib]
  refine prod_congr rfl fun d _ => ?_
  rw [← pow_add, ← pow_add]
  congr 1
  have := Nat.add_div_le_add_div k (n - k) d
  rw [Nat.add_sub_cancel' h] at this
  omega

/-- The cyclotomic exponent in `⟦n,k⟧_q` is the carry digit `[d ≤ k mod d + (n-k) mod d]`. -/
lemma qBinom_cyclotomic_exponent {n k d : ℕ} (h : k ≤ n) (hd : 0 < d) :
    n / d - k / d - (n - k) / d = if d ≤ k % d + (n - k) % d then 1 else 0 := by
  have := Nat.add_div (a := k) (b := n - k) hd
  rw [Nat.add_sub_cancel' h] at this
  split_ifs at this ⊢ <;> omega

/-- Each cyclotomic polynomial occurs in `⟦n,k⟧_q` with multiplicity at most one. -/
theorem qBinom_cyclotomic_exponent_le_one {n k d : ℕ} (h : k ≤ n) (hd : 0 < d) :
    n / d - k / d - (n - k) / d ≤ 1 := by
  rw [qBinom_cyclotomic_exponent h hd]; split_ifs <;> omega

/-- **Gaussian binomials are squarefree products of distinct cyclotomic polynomials**:
`⟦n,k⟧_q = ∏ Φ_d(q)` over those `2 ≤ d ≤ n` for which `k mod d + (n-k) mod d ≥ d`. -/
theorem qBinom_cyclotomic {n k : ℕ} (h : k ≤ n) :
    qBinom (X : ℤ[X]) n k =
      ∏ d ∈ (Icc 2 n).filter (fun d => d ≤ k % d + (n - k) % d), cyclotomic d ℤ := by
  rw [qBinom_cyclotomic_pow h, prod_filter]
  refine prod_congr rfl fun d hd => ?_
  rw [qBinom_cyclotomic_exponent h (by simp at hd; omega)]
  split_ifs <;> simp

/-- `Φ_n(q)` divides every interior Gaussian binomial `⟦n,k⟧_q`, `0 < k < n`. -/
theorem cyclotomic_dvd_qBinom {n k : ℕ} (hk : 0 < k) (hkn : k < n) :
    cyclotomic n ℤ ∣ qBinom (X : ℤ[X]) n k := by
  rw [qBinom_cyclotomic hkn.le]
  apply dvd_prod_of_mem
  simp only [mem_filter, mem_Icc]
  refine ⟨⟨by omega, le_rfl⟩, ?_⟩
  rw [Nat.mod_eq_of_lt hkn, Nat.mod_eq_of_lt (by omega : n - k < n)]
  omega

/-! ## Specialisation at `q = 1`: Legendre/Kummer shadows -/

/-- `[n]_q!` evaluated at `q = 1` is `n!`. -/
lemma qFactorial_int_eval_one (n : ℕ) : (qFactorial (X : ℤ[X]) n).eval 1 = (n.factorial : ℤ) := by
  rw [qFactorial, eval_prod, ← qFactorial_one (R := ℤ) n, qFactorial]
  refine prod_congr rfl fun i _ => ?_
  simp [qInt, eval_finset_sum]

/-- Evaluating the cyclotomic factorisation of `[n]_q!` at `q = 1`:
`n! = ∏_{d=2}^{n} Φ_d(1)^{⌊n/d⌋}` (since `Φ_{p^a}(1) = p` this is Legendre's formula). -/
theorem factorial_eq_prod_cyclotomic_eval_one (n : ℕ) :
    (n.factorial : ℤ) = ∏ d ∈ Icc 2 n, (cyclotomic d ℤ).eval 1 ^ (n / d) := by
  have h := congrArg (Polynomial.eval (1 : ℤ)) (qFactorial_cyclotomic n)
  rw [eval_prod] at h
  simp only [eval_pow] at h
  rw [← h, qFactorial_int_eval_one]

/-- **Kummer-type formula**: `C(n,k) = ∏ Φ_d(1)` over the "carry" moduli `d`, i.e. those
`2 ≤ d ≤ n` with `k mod d + (n-k) mod d ≥ d`.  As `Φ_d(1)` is `p` for `d = p^a` and `1`
otherwise, this is Kummer's theorem on the `p`-adic valuation of binomial coefficients. -/
theorem choose_eq_prod_cyclotomic_eval_one {n k : ℕ} (h : k ≤ n) :
    (n.choose k : ℤ) =
      ∏ d ∈ (Icc 2 n).filter (fun d => d ≤ k % d + (n - k) % d), (cyclotomic d ℤ).eval 1 := by
  rw [← qBinom_int_eval_one, qBinom_cyclotomic h, eval_prod]

end Catalog.Applications.QBinomial