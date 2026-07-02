import Algebra.«2ff65a6a_retry1_aristotle».Tropical.FundamentalTheorem.Basic

/-!
# Tropical polynomials via the tropical semiring, and their piecewise-linear structure

This file realises the tropicalization of a polynomial `f` as a genuine element-wise
computation in Mathlib's tropical semiring `Tropical (WithTop ℝ)`, whose addition is `min`
and whose multiplication is `+` (the **min-plus** semiring), and records the resulting
**piecewise-linear** structure of the tropical polynomial function `w ↦ tropPolyValue v f w`.

* `tropMonomialT` / `tropPolyT` express `tropMonomial` and `tropPolyValue` inside
  `Tropical (WithTop ℝ)`: a tropical polynomial is literally a *tropical sum* of tropical
  monomials, and `untrop_tropPolyT` shows this agrees with the `min`-of-affine-forms
  definition `tropPolyValue`.
* `linForm_add`, `linForm_smul` record that each exponent form `⟨a, ·⟩` is `ℝ`-linear, so
  each tropical monomial is an affine function of `w`.
* `tropPolyValue_le` and `exists_eq_tropMonomial` show `tropPolyValue v f w` is the pointwise
  minimum of these finitely many affine functions — i.e. it is concave and piecewise-linear
  (the min-plus convention; the max-plus convention gives the convex/`max` mirror image with
  the same corner locus).
-/

noncomputable section

open scoped BigOperators
open MvPolynomial Finset

namespace TropicalFT

variable {n : ℕ} {K : Type*} [Field K] (v : AddValuation K (WithTop ℝ))

/-- A tropical monomial as an element of the tropical semiring `Tropical (WithTop ℝ)`. -/
def tropMonomialT (f : MvPolynomial (Fin n) K) (a : Fin n →₀ ℕ) (w : Fin n → ℝ) :
    Tropical (WithTop ℝ) :=
  Tropical.trop (tropMonomial v f a w)

/-- The tropical polynomial as a genuine *tropical sum* (= min) of its tropical monomials,
living in `Tropical (WithTop ℝ)`. -/
def tropPolyT (f : MvPolynomial (Fin n) K) (w : Fin n → ℝ) : Tropical (WithTop ℝ) :=
  ∑ a ∈ f.support, tropMonomialT v f a w

/-- The tropical-semiring formulation agrees with the `min`-of-affine-forms definition:
the tropical polynomial's value is the tropicalization of `tropPolyValue`. -/
lemma untrop_tropPolyT (f : MvPolynomial (Fin n) K) (w : Fin n → ℝ) :
    (tropPolyT v f w).untrop = tropPolyValue v f w := by
  unfold tropPolyT tropMonomialT tropPolyValue
  rw [← Finset.trop_inf, Tropical.untrop_trop]

/-! ### Linearity of the exponent forms (each tropical monomial is affine in `w`) -/

/-- The exponent form is additive in the point. -/
lemma linForm_add (a : Fin n →₀ ℕ) (w w' : Fin n → ℝ) :
    linForm a (w + w') = linForm a w + linForm a w' := by
  simp only [linForm, Pi.add_apply, mul_add, Finset.sum_add_distrib]

/-- The exponent form is homogeneous in the point. -/
lemma linForm_smul (a : Fin n →₀ ℕ) (c : ℝ) (w : Fin n → ℝ) :
    linForm a (c • w) = c * linForm a w := by
  simp only [linForm, Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
  exact Finset.sum_congr rfl (fun i _ => by ring)

/-! ### Piecewise-linear (min-of-affine) structure -/

/-- `tropPolyValue` is `≤` each of its affine pieces over the support. -/
lemma tropPolyValue_le {f : MvPolynomial (Fin n) K} {a : Fin n →₀ ℕ} (ha : a ∈ f.support)
    (w : Fin n → ℝ) : tropPolyValue v f w ≤ tropMonomial v f a w :=
  Finset.inf_le ha

/-- At every point the minimum defining `tropPolyValue` is attained: `tropPolyValue v f w`
equals one of the affine pieces `tropMonomial v f a w` with `a ∈ f.support`.  Together with
`tropPolyValue_le` this exhibits `w ↦ tropPolyValue v f w` as the pointwise minimum of the
finite family of affine functions `tropMonomial v f · w`, i.e. as a concave
piecewise-linear function. -/
lemma exists_eq_tropMonomial {f : MvPolynomial (Fin n) K} (hne : f.support.Nonempty)
    (w : Fin n → ℝ) : ∃ a ∈ f.support, tropPolyValue v f w = tropMonomial v f a w := by
  obtain ⟨a, ha, h⟩ := Finset.exists_mem_eq_inf f.support hne (fun a => tropMonomial v f a w)
  exact ⟨a, ha, h⟩

end TropicalFT