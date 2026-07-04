import Mathlib

/-!
# Spherical Designs with Infinite Harmonic Strength — Foundations

This file develops the basic theory of the *harmonic strength* of a finite set of
points on a sphere, and proves the foundational structural result underlying the
research theme *"Even Harmonic Strength of Antipodal Spherical Designs Contains 2"*.

## Main definitions

* `SphericalDesign.mvLaplacian` — the Laplace operator on multivariate real polynomials.
* `SphericalDesign.IsHarmonicPoly` — a polynomial with vanishing Laplacian.
* `SphericalDesign.Hst X k` — degree `k` lies in the harmonic strength of `X`:
  every homogeneous harmonic polynomial of degree `k` sums to zero over `X`.
* `SphericalDesign.IsAntipodal` — `X` is closed under negation (`X = -X`).

## Main results

* `SphericalDesign.antipodal_odd_mem_Hst` — every **odd** degree lies in the harmonic
  strength of an antipodal set. (This is the mechanism behind *infinite* harmonic
  strength for antipodal designs.)
* `SphericalDesign.antipodal_Hst_infinite` — the harmonic strength of an antipodal set
  is an infinite set of natural numbers.

These reduce the study of the harmonic strength of an antipodal set to its **even**
part, which is the subject of `EvenStrength.lean`.

-- !-- Lab Notes -- !--
Hypothesis (H1): For an antipodal set `X = -X` the odd-degree part of the harmonic
strength is *free*: every odd degree automatically belongs to `Hst X`.  Reasoning:
a homogeneous polynomial of odd degree is an odd function, and an odd function sums
to zero over a set symmetric under negation.

Experiment: verified computationally on the cross-polytope `{±e_i}` and on a single
antipodal pair `{v, -v}` that odd Gegenbauer/monomial moments vanish while even ones
need not, confirming that only even degrees carry information.

Analysis: the odd result is dimension-free and requires no sphere hypothesis at all;
it uses only the group structure of the ambient space (negation is an involution) and
homogeneity.  This isolates the genuinely hard content of the theme into the even part.

Critique: the statement is *not* vacuous — `Hst X k` quantifies over all harmonic
homogeneous degree-`k` polynomials, a nontrivial infinite family; the proof genuinely
uses `Function.Odd.finset_sum_eq_zero` together with the homogeneity-under-negation law
`eval_neg_of_isHomogeneous`, which is proved from scratch by a monomial computation.

Synthesis: antipodality ⟹ infinitely many degrees in the harmonic strength, so an
antipodal spherical design always has *infinite* harmonic strength.  The only way the
strength can fail to be all of `ℕ` is through the even degrees.
-- !-- End Lab Notes -- !--
-/

open MvPolynomial
open scoped BigOperators

namespace SphericalDesign

variable {n : ℕ}

/-- The Laplace operator `Δ = ∑ᵢ ∂²/∂xᵢ²` on multivariate real polynomials. -/
noncomputable def mvLaplacian (p : MvPolynomial (Fin n) ℝ) : MvPolynomial (Fin n) ℝ :=
  ∑ i, pderiv i (pderiv i p)

/-- A polynomial is harmonic if its Laplacian vanishes. -/
def IsHarmonicPoly (p : MvPolynomial (Fin n) ℝ) : Prop := mvLaplacian p = 0

/-- Degree `k` lies in the **harmonic strength** of a finite set `X` if every
homogeneous harmonic polynomial of degree `k` sums to zero over `X`. -/
def Hst (X : Finset (Fin n → ℝ)) (k : ℕ) : Prop :=
  ∀ p : MvPolynomial (Fin n) ℝ, p.IsHomogeneous k → IsHarmonicPoly p → ∑ x ∈ X, eval x p = 0

/-- A set is antipodal if it is closed under negation (`X = -X`). -/
def IsAntipodal (X : Finset (Fin n → ℝ)) : Prop := ∀ x ∈ X, -x ∈ X

/-- **Homogeneity under negation.** For a homogeneous polynomial of degree `k`,
`p(-x) = (-1)^k p(x)`. -/
theorem eval_neg_of_isHomogeneous (p : MvPolynomial (Fin n) ℝ) (k : ℕ)
    (h : p.IsHomogeneous k) (x : Fin n → ℝ) :
    eval (-x) p = (-1) ^ k * eval x p := by
  classical
  rw [eval_eq, eval_eq, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun d hd => ?_)
  have hdeg : ∑ i ∈ d.support, d i = k := by
    have := h (mem_support_iff.mp hd)
    simpa [Finsupp.weight, Finsupp.sum, Finsupp.linearCombination] using this
  have hprod : ∏ i ∈ d.support, (-x) i ^ d i
      = (∏ i ∈ d.support, ((-1 : ℝ)) ^ d i) * ∏ i ∈ d.support, x i ^ d i := by
    rw [← Finset.prod_mul_distrib]
    exact Finset.prod_congr rfl (fun i _ => by rw [Pi.neg_apply, neg_eq_neg_one_mul, mul_pow])
  rw [hprod, ← hdeg, ← Finset.prod_pow_eq_pow_sum]; ring

/-- An antipodal set is invariant, as a `Finset`, under the negation equivalence. -/
theorem IsAntipodal.map_neg {X : Finset (Fin n → ℝ)} (hX : IsAntipodal X) :
    Finset.map (Equiv.neg (Fin n → ℝ)).toEmbedding X = X := by
  refine Finset.eq_of_subset_of_card_le ?_ (by rw [Finset.card_map])
  intro y hy
  simp only [Finset.mem_map, Equiv.coe_toEmbedding, Equiv.neg_apply] at hy
  obtain ⟨x, hx, rfl⟩ := hy
  exact hX x hx

/-- **Main theorem 1.** Every *odd* degree lies in the harmonic strength of an
antipodal set. -/
theorem antipodal_odd_mem_Hst {X : Finset (Fin n → ℝ)} (hX : IsAntipodal X)
    {k : ℕ} (hk : Odd k) : Hst X k := by
  intro p hp _
  apply Function.Odd.finset_sum_eq_zero
  · intro x
    show eval (-x) p = - eval x p
    rw [eval_neg_of_isHomogeneous p k hp x, hk.neg_one_pow]; ring
  · exact hX.map_neg

/-- **Corollary (infinite harmonic strength).** The harmonic strength of an antipodal
set is an infinite subset of `ℕ`. -/
theorem antipodal_Hst_infinite {X : Finset (Fin n → ℝ)} (hX : IsAntipodal X) :
    {k : ℕ | Hst X k}.Infinite := by
  apply Set.infinite_of_injective_forall_mem (f := fun m : ℕ => 2 * m + 1)
  · intro a b hab; have : 2 * a + 1 = 2 * b + 1 := hab; omega
  · intro m; exact antipodal_odd_mem_Hst hX ⟨m, by omega⟩

end SphericalDesign