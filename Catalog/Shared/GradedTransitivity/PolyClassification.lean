import Shared.GradedTransitivity.Profile

/-!
# Denominator `(1-q)^{r+1}` ⟺ eventually polynomial of degree `≤ r`

`PolynomialGrowth` shows one implication and `Newton` produces, from the
vanishing of `Δ^{r+1}`, an explicit binomial expansion.  Here we convert that
binomial expansion into an honest polynomial, using the falling factorial
`descPochhammer`, and obtain the exact classification

`(1-q)^{r+1} · ∑ a n qⁿ` is a polynomial ⟺ `a` is eventually given by a
polynomial of degree `≤ r`.

## Main results

* `binomPoly_eval` : `C(n-N, j)` is a polynomial function of `n` of degree `j`.
* `exists_polynomial_of_sdiff_iter_eventuallyZero` : vanishing of `Δ^{r+1}`
  produces the polynomial.
* `gen_poly_iff_eventually_polynomial` : the classification.
-/

namespace GradedTransitivity

open Polynomial

/-- The polynomial of degree `j` interpolating `n ↦ C(n-N, j)`. -/
noncomputable def binomPoly (N j : ℕ) : ℚ[X] :=
  C (1 / (j.factorial : ℚ)) * (descPochhammer ℚ j).comp (X - C (N : ℚ))

theorem binomPoly_natDegree_le (N j : ℕ) : (binomPoly N j).natDegree ≤ j := by
  refine le_trans (Polynomial.natDegree_C_mul_le _ _) ?_
  rw [Polynomial.natDegree_comp, descPochhammer_natDegree, Polynomial.natDegree_X_sub_C, mul_one]

/-- Past the shift, `binomPoly N j` computes the binomial coefficient. -/
theorem binomPoly_eval (N j : ℕ) : ∀ n ≥ N, (binomPoly N j).eval (n : ℚ) = binomShift N j n := by
  intro n hn
  have hcast : (n : ℚ) - (N : ℚ) = ((n - N : ℕ) : ℚ) := by
    push_cast [Nat.cast_sub hn]
    ring
  have hfac : (j.factorial : ℚ) ≠ 0 := by
    exact_mod_cast Nat.factorial_ne_zero j
  simp only [binomPoly, Polynomial.eval_mul, Polynomial.eval_C, Polynomial.eval_comp,
    Polynomial.eval_sub, Polynomial.eval_X, hcast]
  rw [descPochhammer_eval_eq_descFactorial ℚ (n - N) j,
    Nat.descFactorial_eq_factorial_mul_choose]
  simp only [binomShift, Nat.cast_mul]
  field_simp

/-- **From vanishing differences to a polynomial.**  If `Δ^{r+1} a` vanishes
eventually then `a` eventually agrees with a polynomial of degree `≤ r`. -/
theorem exists_polynomial_of_sdiff_iter_eventuallyZero {r : ℕ} {a : ℕ → ℚ}
    (h : EventuallyZero (sdiff^[r + 1] a)) :
    ∃ (N : ℕ) (p : ℚ[X]), p.natDegree ≤ r ∧ ∀ n ≥ N, a n = p.eval (n : ℚ) := by
  obtain ⟨N, hN⟩ := h
  refine ⟨N, ∑ j ∈ Finset.range (r + 1), C (sdiff^[j] a N) * binomPoly N j, ?_, ?_⟩
  · refine Polynomial.natDegree_sum_le_of_forall_le _ _ (fun j hj => ?_)
    refine le_trans (Polynomial.natDegree_C_mul_le _ _) ?_
    exact le_trans (binomPoly_natDegree_le N j) (by have := Finset.mem_range.1 hj; omega)
  · intro n hn
    rw [newton_forward hN n hn]
    simp only [Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_C]
    refine Finset.sum_congr rfl (fun j _ => ?_)
    rw [binomPoly_eval N j n hn]
    rfl

/-- **Classification.**  The generating function of `a` is `P(q)/(1-q)^{r+1}`
with `P` a polynomial exactly when `a` is eventually given by a polynomial of
degree at most `r`. -/
theorem gen_poly_iff_eventually_polynomial (r : ℕ) (a : ℕ → ℚ) :
    (∃ P : ℚ[X], (1 - PowerSeries.X) ^ (r + 1) * gen a = (P : PowerSeries ℚ)) ↔
      ∃ (N : ℕ) (p : ℚ[X]), p.natDegree ≤ r ∧ ∀ n ≥ N, a n = p.eval (n : ℚ) := by
  constructor
  · intro h
    exact exists_polynomial_of_sdiff_iter_eventuallyZero
      ((sdiff_iter_eventuallyZero_iff (r + 1) a).1 h)
  · rintro ⟨N, p, hdeg, hev⟩
    exact exists_poly_of_eventually_polynomial hdeg hev

end GradedTransitivity