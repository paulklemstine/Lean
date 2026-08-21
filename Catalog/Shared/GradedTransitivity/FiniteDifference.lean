import Mathlib

/-!
# Finite differences and rationality of generating functions

This file develops the analytic engine behind the main result of the
`Shared.GradedTransitivity` cluster:

> a sequence `a : ℕ → ℚ` has generating function `∑ a n qⁿ` equal to
> `P(q) / (1-q)^k` for a *polynomial* `P` **iff** the `k`-th forward
> difference of `a` vanishes eventually.

Everything is done inside `PowerSeries ℚ`, so no convergence issues arise; the
statement "`(1-q)^k` is a denominator" is formalised as
`(1 - X)^k * (∑ a n Xⁿ) = ↑P` for a polynomial `P`, which — since `1 - X` is a
unit of `PowerSeries ℚ` — is equivalent to `∑ a n Xⁿ = ↑P * ((1-X)^k)⁻¹`
(see `PowerSeries.eq_poly_div_of_pow_mul`).

## Main results

* `sdiff_iter_eventuallyZero_iff` : the iff above.
* `exists_poly_of_eventually_polynomial` : if `a` agrees eventually with a
  polynomial of degree `≤ r`, the denominator `(1-q)^{r+1}` suffices.
-/

namespace GradedTransitivity

open Polynomial

/-- The forward difference operator on `ℚ`-valued sequences,
`(Δa)(n) = a (n+1) - a n`. -/
def sdiff (a : ℕ → ℚ) : ℕ → ℚ := fun n => a (n + 1) - a n

/-- A sequence is *eventually zero* if it vanishes from some index on. -/
def EventuallyZero (a : ℕ → ℚ) : Prop := ∃ N, ∀ n ≥ N, a n = 0

/-- The generating power series `∑ a n Xⁿ` of a sequence. -/
noncomputable def gen (a : ℕ → ℚ) : PowerSeries ℚ := PowerSeries.mk a

@[simp] lemma coeff_gen (a : ℕ → ℚ) (n : ℕ) :
    (PowerSeries.coeff n) (gen a) = a n := PowerSeries.coeff_mk n a

@[simp] lemma constantCoeff_gen (a : ℕ → ℚ) :
    (PowerSeries.constantCoeff) (gen a) = a 0 := by
  rw [← PowerSeries.coeff_zero_eq_constantCoeff_apply, coeff_gen]

/-! ### Eventually zero sequences are exactly the polynomials -/

/-- A sequence which vanishes eventually has a polynomial generating series. -/
theorem exists_poly_of_eventuallyZero {a : ℕ → ℚ} (h : EventuallyZero a) :
    ∃ p : ℚ[X], (p : PowerSeries ℚ) = gen a := by
  obtain ⟨N, hN⟩ := h
  refine ⟨∑ i ∈ Finset.range N, C (a i) * X ^ i, ?_⟩
  ext n
  rw [Polynomial.coeff_coe, coeff_gen]
  simp only [Polynomial.finset_sum_coeff, Polynomial.coeff_C_mul,
    Polynomial.coeff_X_pow, mul_ite, mul_one, mul_zero, Finset.sum_ite_eq (Finset.range N) n]
  by_cases hn : n < N
  · simp [Finset.mem_range.2 hn]
  · simp only [Finset.mem_range, hn, if_false]
    exact (hN n (not_lt.1 hn)).symm

/-- Conversely, a polynomial generating series forces the sequence to vanish
eventually. -/
theorem eventuallyZero_of_poly {a : ℕ → ℚ} {p : ℚ[X]}
    (h : (p : PowerSeries ℚ) = gen a) : EventuallyZero a := by
  refine ⟨p.natDegree + 1, fun n hn => ?_⟩
  have := congrArg (fun φ => (PowerSeries.coeff n) φ) h
  simp only [Polynomial.coeff_coe, coeff_gen] at this
  rw [← this]
  exact Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)

/-! ### The key power series identity -/

/-- The fundamental identity relating multiplication by `1 - X` on generating
series with the forward difference operator on coefficients. -/
theorem one_sub_X_mul_gen (a : ℕ → ℚ) :
    (1 - PowerSeries.X) * gen a
      = PowerSeries.X * gen (sdiff a) + PowerSeries.C (a 0) := by
  ext n
  cases n with
  | zero => simp
  | succ m =>
      simp [PowerSeries.coeff_succ_X_mul, sdiff, sub_mul, PowerSeries.coeff_succ_X_mul]

/-! ### Rationality: the forward direction -/

/-- If the `k`-th forward difference of `a` vanishes eventually, then
`(1-X)^k * ∑ a n Xⁿ` is a polynomial. -/
theorem exists_poly_pow_mul_gen :
    ∀ (k : ℕ) (a : ℕ → ℚ), EventuallyZero (sdiff^[k] a) →
      ∃ p : ℚ[X], (1 - PowerSeries.X) ^ k * gen a = (p : PowerSeries ℚ) := by
  intro k
  induction k with
  | zero =>
      intro a h
      simp only [Function.iterate_zero, id_eq] at h
      obtain ⟨p, hp⟩ := exists_poly_of_eventuallyZero h
      exact ⟨p, by simpa using hp.symm⟩
  | succ k ih =>
      intro a h
      rw [Function.iterate_succ_apply] at h
      obtain ⟨q, hq⟩ := ih (sdiff a) h
      refine ⟨X * q + (1 - X) ^ k * C (a 0), ?_⟩
      have : (1 - PowerSeries.X) ^ (k + 1) * gen a
          = (1 - PowerSeries.X) ^ k * ((1 - PowerSeries.X) * gen a) := by ring
      rw [this, one_sub_X_mul_gen, mul_add, ← mul_assoc, mul_comm ((1 - PowerSeries.X) ^ k)
        PowerSeries.X, mul_assoc, hq]
      push_cast
      ring

/-! ### Rationality: the converse -/

/-- If `X * φ` is a polynomial then so is `φ`. -/
theorem exists_poly_of_X_mul {φ : PowerSeries ℚ} {p : ℚ[X]}
    (h : PowerSeries.X * φ = (p : PowerSeries ℚ)) :
    ∃ q : ℚ[X], φ = (q : PowerSeries ℚ) := by
  have hz : EventuallyZero (fun n => (PowerSeries.coeff n) φ) := by
    refine ⟨p.natDegree + 1, fun n hn => ?_⟩
    have := congrArg (fun ψ => (PowerSeries.coeff (n + 1)) ψ) h
    simp only [PowerSeries.coeff_succ_X_mul, Polynomial.coeff_coe] at this
    show (PowerSeries.coeff n) φ = 0
    rw [this]
    exact Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)
  obtain ⟨q, hq⟩ := exists_poly_of_eventuallyZero hz
  exact ⟨q, by rw [hq]; ext n; simp⟩

/-- If `(1-X)^k * ∑ a n Xⁿ` is a polynomial then the `k`-th forward difference
of `a` vanishes eventually. -/
theorem eventuallyZero_sdiff_iter_of_poly :
    ∀ (k : ℕ) (a : ℕ → ℚ) (p : ℚ[X]),
      (1 - PowerSeries.X) ^ k * gen a = (p : PowerSeries ℚ) →
        EventuallyZero (sdiff^[k] a) := by
  intro k
  induction k with
  | zero =>
      intro a p h
      simp only [pow_zero, one_mul] at h
      simpa using eventuallyZero_of_poly h.symm
  | succ k ih =>
      intro a p h
      rw [Function.iterate_succ_apply]
      have h1 : (1 - PowerSeries.X) ^ k * ((1 - PowerSeries.X) * gen a)
          = (p : PowerSeries ℚ) := by
        rw [← h]; ring
      rw [one_sub_X_mul_gen, mul_add] at h1
      have h2 : PowerSeries.X * ((1 - PowerSeries.X) ^ k * gen (sdiff a))
          = ((p - (1 - X) ^ k * C (a 0) : ℚ[X]) : PowerSeries ℚ) := by
        push_cast
        rw [← h1]
        ring
      obtain ⟨q, hq⟩ := exists_poly_of_X_mul h2
      exact ih (sdiff a) q hq

/-- **Rationality criterion.** The generating series of `a` has `(1-q)^k` as a
denominator (with polynomial numerator) precisely when the `k`-th forward
difference of `a` vanishes eventually. -/
theorem sdiff_iter_eventuallyZero_iff (k : ℕ) (a : ℕ → ℚ) :
    (∃ p : ℚ[X], (1 - PowerSeries.X) ^ k * gen a = (p : PowerSeries ℚ)) ↔
      EventuallyZero (sdiff^[k] a) :=
  ⟨fun ⟨p, hp⟩ => eventuallyZero_sdiff_iter_of_poly k a p hp,
    exists_poly_pow_mul_gen k a⟩

/-! ### Reformulation as an honest quotient of power series -/

/-- `1 - X` is invertible in `PowerSeries ℚ`, so a polynomial identity
`(1-X)^k * f = P` really does exhibit `f` as the quotient `P / (1-X)^k`. -/
theorem eq_poly_div_of_pow_mul {k : ℕ} {a : ℕ → ℚ} {p : ℚ[X]}
    (h : (1 - PowerSeries.X) ^ k * gen a = (p : PowerSeries ℚ)) :
    gen a = (p : PowerSeries ℚ) * (((1 - PowerSeries.X) ^ k)⁻¹ : PowerSeries ℚ) := by
  have hc : (PowerSeries.constantCoeff) ((1 - PowerSeries.X : PowerSeries ℚ) ^ k) ≠ 0 := by
    simp
  have hmul : ((1 - PowerSeries.X : PowerSeries ℚ) ^ k)
      * (((1 - PowerSeries.X : PowerSeries ℚ) ^ k)⁻¹) = 1 :=
    PowerSeries.mul_inv_cancel _ hc
  calc gen a = 1 * gen a := (one_mul _).symm
    _ = (((1 - PowerSeries.X : PowerSeries ℚ) ^ k)
          * (((1 - PowerSeries.X : PowerSeries ℚ) ^ k)⁻¹)) * gen a := by rw [hmul]
    _ = ((1 - PowerSeries.X : PowerSeries ℚ) ^ k * gen a)
          * (((1 - PowerSeries.X : PowerSeries ℚ) ^ k)⁻¹) := by ring
    _ = (p : PowerSeries ℚ) * (((1 - PowerSeries.X) ^ k)⁻¹ : PowerSeries ℚ) := by rw [h]

end GradedTransitivity