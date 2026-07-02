import Algebra.«2ff65a6a_retry1_aristotle».Tropical.FundamentalTheorem.Basic

/-!
# The Fundamental Theorem of Tropical Geometry for a hypersurface (Kapranov's theorem)

For a single Laurent polynomial `f` over a non-Archimedean valued field `K`, the *Fundamental
Theorem of Tropical Algebraic Geometry* (Kapranov's theorem) states that

> `Trop(V(f))` (the valuations of the points of the classical hypersurface `V(f)` inside the
> torus `(K*)ⁿ`) is exactly the **corner locus** of the tropicalization of `f`.

This file proves the substantive forward inclusion unconditionally:

* `mem_tropicalHypersurface_of_zero` / `TropV_subset_tropicalHypersurface` :
  every valuation of a classical zero is a corner point.  The proof is the non-Archimedean
  argument: if the tropicalized minimum were attained at a *unique* monomial, then by
  `addval_sum_eq_of_unique_min` the valuation of `f(x)` would equal that finite minimum, so
  `f(x) ≠ 0`.

The opposite inclusion (every corner point lifts to a classical zero) is the deep part of
Kapranov's theorem; it requires `K` to be algebraically closed (or at least that the value
group be divisible and the residue field large enough) and is genuine "lifting" input.  We
package exactly that content as the explicit hypothesis `LiftingProperty` and deduce the
full equality `kapranov_fundamental_theorem` from it together with the forward inclusion.
This keeps the statement faithful: the forward direction is proved, and the equality is a
theorem whose only extra hypothesis is the precise classical lifting statement.
-/

noncomputable section

open scoped BigOperators
open MvPolynomial Finset

namespace TropicalFT

variable {n : ℕ} {K : Type*} [Field K] (v : AddValuation K (WithTop ℝ))

/-- The tropicalized monomial at a torus point is finite (`≠ ⊤`) whenever the coefficient is
nonzero. -/
lemma tropMonomial_ne_top {f : MvPolynomial (Fin n) K} {a : Fin n →₀ ℕ}
    (ha : f.coeff a ≠ 0) (w : Fin n → ℝ) : tropMonomial v f a w ≠ ⊤ := by
  unfold tropMonomial
  have h1 : v (f.coeff a) ≠ ⊤ := valuation_ne_top v ha
  generalize v (f.coeff a) = y at *
  cases y with
  | top => exact absurd rfl h1
  | coe r => simp [← WithTop.coe_add]

/-
**Forward direction of Kapranov's theorem.**  If `x` is a torus point with `f(x) = 0` and
`f ≠ 0`, then its valuation `tropicalize v x` lies in the corner locus of `trop f`.
-/
theorem mem_tropicalHypersurface_of_zero {f : MvPolynomial (Fin n) K} (hf : f ≠ 0)
    {x : Fin n → K} (hx : InTorus x) (hfx : MvPolynomial.eval x f = 0) :
    IsCornerPoint v f (tropicalize v x) := by
  by_contra h_not_corner;
  -- By `Finset.exists_min_image S (fun a => tropMonomial v f a w)`, pick a₀ ∈ S with tropMonomial v f a₀ w ≤ tropMonomial v f a w for all a ∈ S (a₀ is a minimizer).
  obtain ⟨a₀, ha₀⟩ : ∃ a₀ ∈ f.support, ∀ a ∈ f.support, tropMonomial v f a₀ (tropicalize v x) ≤ tropMonomial v f a (tropicalize v x) := by
    exact Finset.exists_min_image _ _ ( Finset.nonempty_of_ne_empty ( by aesop ) );
  -- Apply `addval_sum_eq_of_unique_min v (j := a₀)` (note a₀ ∈ S) to conclude
  have h_val_sum : v (∑ a ∈ f.support, f.coeff a * ∏ i, (x i)^(a i)) = tropMonomial v f a₀ (tropicalize v x) := by
    convert addval_sum_eq_of_unique_min v ha₀.1 _ using 1;
    · exact (tropMonomial_eq_valuation_term v f a₀ hx).symm;
    · intro a ha;
      rw [ tropMonomial_eq_valuation_term, tropMonomial_eq_valuation_term ];
      · refine' lt_of_le_of_ne ( ha₀.2 a ( Finset.mem_sdiff.mp ha |>.1 ) ) _;
        exact fun h => h_not_corner ⟨ a₀, ha₀.1, a, Finset.mem_sdiff.mp ha |>.1, by aesop ⟩;
      · exact hx;
      · exact hx;
  simp_all +decide [ MvPolynomial.eval_eq' ];
  exact tropMonomial_ne_top v ha₀.1 ( tropicalize v x ) h_val_sum.symm

/-- `Trop(V(f)) ⊆ corner locus of `trop f`. -/
theorem TropV_subset_tropicalHypersurface {f : MvPolynomial (Fin n) K} (hf : f ≠ 0) :
    TropV v f ⊆ tropicalHypersurface v f := by
  rintro w ⟨x, ⟨hx, hfx⟩, rfl⟩
  exact mem_tropicalHypersurface_of_zero v hf hx hfx

/-- The **lifting property** for `f`: every corner point of `trop f` is the valuation of an
actual classical zero of `f` in the torus.  This is exactly the deep (surjective) direction
of Kapranov's theorem, which holds when `K` is algebraically closed with a nontrivial
valuation.  We take it as an explicit hypothesis rather than asserting it. -/
def LiftingProperty (f : MvPolynomial (Fin n) K) : Prop :=
  ∀ w ∈ tropicalHypersurface v f, ∃ x, InTorus x ∧ MvPolynomial.eval x f = 0 ∧
    tropicalize v x = w

/-- **The Fundamental Theorem of Tropical Geometry for a hypersurface (Kapranov).**  Assuming
the lifting property (the deep classical-existence input), `Trop(V(f))` equals the corner
locus of the tropicalization of `f`. -/
theorem kapranov_fundamental_theorem {f : MvPolynomial (Fin n) K} (hf : f ≠ 0)
    (hlift : LiftingProperty v f) :
    TropV v f = tropicalHypersurface v f := by
  apply Set.Subset.antisymm (TropV_subset_tropicalHypersurface v hf)
  intro w hw
  obtain ⟨x, hx, hfx, rfl⟩ := hlift w hw
  exact ⟨x, ⟨hx, hfx⟩, rfl⟩

end TropicalFT