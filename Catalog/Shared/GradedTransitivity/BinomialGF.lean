import Shared.GradedTransitivity.PolynomialGrowth

/-!
# The binomial generating function and sharpness of the exponent `r+1`

The sequence `n ↦ C(n, r)` is the universal example of polynomial growth of
degree exactly `r`.  Here we compute its generating function *exactly*,

`∑_{n} C(n,r) qⁿ = q^r / (1-q)^{r+1}`,

purely from the Pascal recurrence, and we deduce that the exponent `r+1` in
`Shared.GradedTransitivity.PolynomialGrowth` cannot be lowered: for this
sequence `(1-q)^r ∑ C(n,r) qⁿ` is *not* a polynomial.

## Main results

* `sdiff_choose` : Pascal's rule as a statement about forward differences.
* `binomial_generating_function` : `(1-X)^{r+1} ∑ C(n,r) Xⁿ = X^r`.
* `binomial_denominator_sharp` : the exponent `r+1` is optimal.
-/

namespace GradedTransitivity

open Polynomial

/-- The sequence `n ↦ C(n, r)` viewed with rational values. -/
def chooseSeq (r : ℕ) : ℕ → ℚ := fun n => (n.choose r : ℚ)

@[simp] lemma chooseSeq_zero_index (r : ℕ) : chooseSeq (r + 1) 0 = 0 := by
  simp [chooseSeq]

@[simp] lemma chooseSeq_zero : chooseSeq 0 = fun _ => (1 : ℚ) := by
  funext n; simp [chooseSeq]

/-- **Pascal's rule as a difference equation**: `Δ C(·, r+1) = C(·, r)`. -/
theorem sdiff_choose (r : ℕ) : sdiff (chooseSeq (r + 1)) = chooseSeq r := by
  funext n
  simp only [sdiff, chooseSeq]
  rw [Nat.choose_succ_succ n r]
  push_cast
  ring

/-- Iterating Pascal's rule: `Δ^k C(·, r+k) = C(·, r)`. -/
theorem sdiff_iter_choose (k : ℕ) : ∀ r : ℕ, sdiff^[k] (chooseSeq (r + k)) = chooseSeq r := by
  induction k with
  | zero => intro r; simp
  | succ k ih =>
      intro r
      rw [Function.iterate_succ_apply]
      have : r + (k + 1) = (r + k) + 1 := by omega
      rw [this, sdiff_choose (r + k), ih r]

/-- **The binomial generating function.**  In `PowerSeries ℚ`,
`(1 - X)^{r+1} · ∑_n C(n,r) Xⁿ = X^r`, i.e. `∑_n C(n,r) qⁿ = q^r/(1-q)^{r+1}`. -/
theorem binomial_generating_function (r : ℕ) :
    (1 - PowerSeries.X) ^ (r + 1) * gen (chooseSeq r) = (PowerSeries.X : PowerSeries ℚ) ^ r := by
  induction r with
  | zero =>
      rw [pow_one, one_sub_X_mul_gen]
      have h1 : sdiff (chooseSeq 0) = fun _ => (0 : ℚ) := by
        funext n; simp [sdiff]
      have h2 : gen (fun _ : ℕ => (0 : ℚ)) = 0 := by
        ext n; simp
      rw [h1, h2]
      simp [chooseSeq]
  | succ r ih =>
      have hsplit : (1 - PowerSeries.X) ^ (r + 1 + 1) * gen (chooseSeq (r + 1))
          = (1 - PowerSeries.X) ^ (r + 1) * ((1 - PowerSeries.X) * gen (chooseSeq (r + 1))) := by
        ring
      rw [hsplit, one_sub_X_mul_gen, sdiff_choose r, chooseSeq_zero_index]
      rw [map_zero, add_zero, ← mul_assoc, mul_comm ((1 - PowerSeries.X) ^ (r + 1)) PowerSeries.X,
        mul_assoc, ih, pow_succ, mul_comm]

/-- The same statement with a genuine polynomial numerator. -/
theorem binomial_generating_function_poly (r : ℕ) :
    (1 - PowerSeries.X) ^ (r + 1) * gen (chooseSeq r) = ((X ^ r : ℚ[X]) : PowerSeries ℚ) := by
  rw [binomial_generating_function r]
  push_cast
  ring

/-- Consequently `∑_n C(n,r) qⁿ` is literally the quotient `q^r/(1-q)^{r+1}`
inside `PowerSeries ℚ`. -/
theorem binomial_gen_eq_div (r : ℕ) :
    gen (chooseSeq r)
      = ((X ^ r : ℚ[X]) : PowerSeries ℚ) * (((1 - PowerSeries.X) ^ (r + 1))⁻¹) :=
  eq_poly_div_of_pow_mul (binomial_generating_function_poly r)

/-- **Sharpness.**  For the sequence `n ↦ C(n,r)` the exponent `r+1` cannot be
replaced by `r`: `(1-q)^r ∑ C(n,r) qⁿ` is not a polynomial. -/
theorem binomial_denominator_sharp (r : ℕ) :
    ¬ ∃ p : ℚ[X], (1 - PowerSeries.X) ^ r * gen (chooseSeq r) = (p : PowerSeries ℚ) := by
  intro h
  have hz : EventuallyZero (sdiff^[r] (chooseSeq r)) :=
    (sdiff_iter_eventuallyZero_iff r (chooseSeq r)).1 h
  rw [show chooseSeq r = chooseSeq (0 + r) by rw [Nat.zero_add], sdiff_iter_choose r 0] at hz
  obtain ⟨N, hN⟩ := hz
  have := hN N le_rfl
  simp [chooseSeq] at this

end GradedTransitivity