import Mathlib

/-!
# Tropical geometry: valued fields, tropicalization, and the corner locus

This file sets up the basic objects connecting classical algebraic geometry over a
non-Archimedean valued field `K` with tropical geometry.

We use Mathlib's `AddValuation K (WithTop ℝ)`, the additive (`min`-convention) valuation
`v : K → ℝ ∪ {∞}`, with `v 0 = ⊤` and `min (v x) (v y) ≤ v (x + y)` (the non-Archimedean
inequality).  This matches the **min-plus** tropical semiring, in which "addition" is `min`
and "multiplication" is `+`.

## Main definitions

* `tropMonomial v f a w` : the value, at a tropical point `w : Fin n → ℝ`, of the
  tropicalization of the monomial of `f` with exponent `a`, namely
  `v (coeff a f) + ∑ i, a i * w i`.
* `tropPolyValue v f w` : the tropicalization of `f` evaluated at `w`, i.e. the minimum of
  `tropMonomial v f a w` over the support of `f` (the min-plus, piecewise-linear function).
* `IsCornerPoint v f w` : `w` lies in the **corner locus** of `trop f`, i.e. the minimum
  defining `tropPolyValue` is attained at (at least) two distinct monomials.
* `tropicalize v x` : the tropical point `i ↦ v (x i)` associated to a classical point.
* `classicalZeroSet` / `TropV` : the classical zero set in the torus `(K*)ⁿ` and its image
  under the valuation (`Trop(V(f))`).

The headline result of this file is `tropMonomial_eq_valuation_term`, identifying the
valuation of a classical monomial term with its tropicalization, which is the bridge used
in `Kapranov.lean`.
-/

noncomputable section

open scoped BigOperators
open MvPolynomial Finset

namespace TropicalFT

variable {n : ℕ} {K : Type*} [Field K] (v : AddValuation K (WithTop ℝ))

/-- The real-linear form `⟨a, w⟩ = ∑ i, a i * w i` associated to an exponent vector `a`. -/
def linForm (a : Fin n →₀ ℕ) (w : Fin n → ℝ) : ℝ := ∑ i, (a i : ℝ) * w i

/-- The tropicalization of the monomial of `f` with exponent vector `a`, evaluated at the
tropical point `w`.  In min-plus terms this is `v(cₐ) ⊙ wᵃ = v(cₐ) + ⟨a, w⟩`. -/
def tropMonomial (f : MvPolynomial (Fin n) K) (a : Fin n →₀ ℕ) (w : Fin n → ℝ) : WithTop ℝ :=
  v (f.coeff a) + ((linForm a w : ℝ) : WithTop ℝ)

/-- The tropicalization of `f`, evaluated at the tropical point `w`: the minimum over the
support of `f` of the tropicalized monomials.  This is the piecewise-linear (concave,
min-plus) function attached to `f`. -/
def tropPolyValue (f : MvPolynomial (Fin n) K) (w : Fin n → ℝ) : WithTop ℝ :=
  f.support.inf (fun a => tropMonomial v f a w)

/-- `w` lies in the corner locus of `trop f`: the defining minimum is attained at two
distinct exponent vectors.  This is the tropical hypersurface of `f`. -/
def IsCornerPoint (f : MvPolynomial (Fin n) K) (w : Fin n → ℝ) : Prop :=
  ∃ a ∈ f.support, ∃ b ∈ f.support, a ≠ b ∧
    tropMonomial v f a w = tropMonomial v f b w ∧
    (∀ c ∈ f.support, tropMonomial v f a w ≤ tropMonomial v f c w)

/-- The tropical hypersurface (corner locus) of `f` as a set of tropical points. -/
def tropicalHypersurface (f : MvPolynomial (Fin n) K) : Set (Fin n → ℝ) :=
  {w | IsCornerPoint v f w}

/-- A classical point `x : Fin n → K` lies in the torus `(K*)ⁿ` if all its coordinates are
nonzero. -/
def InTorus (x : Fin n → K) : Prop := ∀ i, x i ≠ 0

/-- The valuation (tropicalization) of a torus point: `i ↦ v (x i)` as a real vector.
For a torus point each `v (x i)` is finite, so we may take the real part. -/
def tropicalize (x : Fin n → K) : Fin n → ℝ := fun i => (v (x i)).untopD 0

/-- The classical zero set of `f` inside the torus `(K*)ⁿ`. -/
def classicalZeroSet (f : MvPolynomial (Fin n) K) : Set (Fin n → K) :=
  {x | InTorus x ∧ MvPolynomial.eval x f = 0}

/-- `Trop(V(f))`: the image under the valuation map of the classical zero set in the torus. -/
def TropV (f : MvPolynomial (Fin n) K) : Set (Fin n → ℝ) :=
  (tropicalize v) '' (classicalZeroSet f)

/-! ### Finiteness of the valuation on the torus -/

/-- On a field, the valuation of a nonzero element is finite. -/
lemma valuation_ne_top {x : K} (hx : x ≠ 0) : v x ≠ ⊤ := by
  exact (AddValuation.ne_top_iff v).mpr hx

/-
For a torus point, `v (x i)` coerces back from its real part.
-/
lemma coe_untop_valuation {x : Fin n → K} (hx : InTorus x) (i : Fin n) :
    ((tropicalize v x i : ℝ) : WithTop ℝ) = v (x i) := by
  by_cases h : v ( x i ) = ⊤ <;> simp_all +decide [ tropicalize ];
  · exact hx i h;
  · cases h' : v ( x i ) <;> aesop

/-! ### The bridge: valuation of a monomial term equals its tropicalization -/

/-
The valuation of the classical monomial term `cₐ · xᵃ` at a torus point `x` equals the
tropicalized monomial `tropMonomial v f a (tropicalize v x)`.  This is the compatibility of
tropicalization with the valuation on the coordinate ring.
-/
lemma tropMonomial_eq_valuation_term (f : MvPolynomial (Fin n) K) (a : Fin n →₀ ℕ)
    {x : Fin n → K} (hx : InTorus x) :
    v (f.coeff a * ∏ i, (x i) ^ (a i)) = tropMonomial v f a (tropicalize v x) := by
  by_cases ha : f.coeff a = 0 <;> simp_all +decide;
  · unfold tropMonomial; aesop;
  · -- By definition of tropicalization, we know that $v(x_i) = \text{tropicalize } x_i$ for each $i$.
    have h_trop : ∀ i, v (x i) = (tropicalize v x i : WithTop ℝ) := by
      exact fun i => Eq.symm ( coe_untop_valuation v hx i );
    -- By definition of tropicalization, we know that $v(\prod_{i} x_i^{a_i}) = \sum_{i} a_i v(x_i)$.
    have h_prod : v (∏ i, x i ^ a i) = ∑ i, a i • v (x i) := by
      induction' ( Finset.univ : Finset ( Fin n ) ) using Finset.induction <;> simp_all +decide [ Finset.prod_insert, Finset.sum_insert ];
    simp_all +decide [ tropMonomial, linForm ];
    norm_cast;
    exact Finset.sum_congr rfl fun _ _ => by simp +decide [ Algebra.smul_def ] ;

/-! ### The non-Archimedean / ultrametric core lemma -/

/-
The additive-valuation analogue of `Valuation.map_sum_eq_of_lt`: if the valuation of a
single term `f j` is strictly **smaller** than that of every other term, then the valuation
of the sum equals `v (f j)`.
-/
lemma addval_sum_eq_of_unique_min {ι : Type*} [DecidableEq ι] {s : Finset ι} {g : ι → K}
    {j : ι} (hj : j ∈ s) (hlt : ∀ i ∈ s \ {j}, v (g j) < v (g i)) :
    v (∑ i ∈ s, g i) = v (g j) := by
  induction' s using Finset.strongInduction with s ih generalizing j;
  by_cases h : ∃ i ∈ s, i ≠ j;
  · obtain ⟨ i, hi, hij ⟩ := h;
    rw [ ← Finset.insert_erase ( Finset.mem_coe.2 hi ), Finset.sum_insert ( Finset.notMem_erase _ _ ) ];
    convert AddValuation.map_add_of_distinct_val _ _ using 1;
    · grind +splitImp;
    · grind;
  · rw [ show s = { j } by ext i; aesop ] ; simp +decide

end TropicalFT