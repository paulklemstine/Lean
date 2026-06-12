import Mathlib

/-! # Tropical Convexity of Tropical Polynomials

This file establishes the bridge between the **tropical (max-plus) semiring** and
**convex analysis**: every tropical polynomial, being a finite maximum of affine
("tropical monomial") functions, is a *convex* function on `ℝ`.

This extends the catalog's `Catalog/Tropical/Core/TropicalPolynomials.lean`
(`tropicalLinear`, `tropicalQuadratic`, `tropical_linear_mono`,
`tropical_quadratic_mono`) from the degree-1 and degree-2 special cases to a
**general degree-`n` tropical polynomial**, and upgrades the monotonicity
statements there with the structural notion of *convexity* (`ConvexOn`).  It
connects the tropical domain (`Catalog/Tropical`) to the convexity bridges
(`Catalog/Bridges/ConvexTropicalBridge`).

Main results:
* `tropMonomial_convexOn`  : a single tropical monomial `a + c·x` is convex.
* `tropMonomial_concaveOn` : ... and also concave (affine functions are both).
* `convexOn_finset_sup'`   : the pointwise `sup'` of convex functions is convex.
* `tropPoly_convexOn`      : every tropical polynomial is convex  (MAIN RESULT).
* `tropPoly_monotone_of_slopes_nonneg` : nonneg slopes ⇒ monotone increasing.
* `tropPoly_midpoint_le`   : the tropical Jensen midpoint inequality.
* `tropical_freshmans_dream` : the max-plus Frobenius / power rule.
* `tropPoly_convexOn_general` : the multivariate generalization (Step 7).
-/

namespace TropicalConvexity

open Set

/-- A **tropical monomial**: the affine function `x ↦ a + c·x`.
In max-plus notation this is the monomial `a ⊙ x^{⊙c}`. -/
def tropMonomial (a c : ℝ) : ℝ → ℝ := fun x => a + c * x

/-- A **tropical polynomial** of degree `n`: the pointwise maximum over the
`n+1` tropical monomials `coeffs i + slopes i · x`.  In max-plus notation this is
`⨁ᵢ coeffs i ⊙ x^{⊙ slopes i}`. -/
def tropPoly {n : ℕ} (coeffs slopes : Fin (n + 1) → ℝ) : ℝ → ℝ :=
  fun x => Finset.univ.sup' Finset.univ_nonempty (fun i => coeffs i + slopes i * x)

-- !-- Lab Notebook: tropMonomial_convexOn -- !--
-- !-- Hypothesis: A tropical monomial is an affine function of x, hence convex. -- !--
-- !-- Result: Proved directly from the definition of ConvexOn; equality holds so the inequality is automatic once a·s + a·t = a is substituted. -- !--
-- !-- Insight: Affine functions are simultaneously convex AND concave; the tropical sign-of-slope distinction (cf. tropical_linear_mono) is irrelevant for convexity. -- !--
-- !-- Failure analysis: nlinarith needed the explicit hint a·s + a·t = a (from s + t = 1) since it cannot factor a·(s+t) on its own. -- !--
-- !-- End Lab Notebook -- !--

-- !-- A tropical monomial `a + c·x` is convex on all of ℝ. -- !--
theorem tropMonomial_convexOn (a c : ℝ) :
    ConvexOn ℝ (univ : Set ℝ) (tropMonomial a c) := by
  refine ⟨convex_univ, ?_⟩
  unfold tropMonomial
  intros
  norm_num
  rw [← eq_sub_iff_add_eq'] at *
  subst_vars
  nlinarith

-- !-- A tropical monomial is also concave (affine maps are both convex and concave). -- !--
theorem tropMonomial_concaveOn (a c : ℝ) :
    ConcaveOn ℝ (univ : Set ℝ) (tropMonomial a c) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ s t _ _ hst
  simp +decide [tropMonomial]
  ring_nf
  rw [← eq_sub_iff_add_eq'] at hst
  subst_vars
  nlinarith

-- !-- Lab Notebook: convexOn_finset_sup' -- !--
-- !-- Hypothesis: The pointwise supremum of finitely many convex functions over a nonempty index set is convex. -- !--
-- !-- Result: Proved by unfolding ConvexOn over the underlying multiset and bounding each member of the sup by the convex-combination bound, then closing with gcongr. -- !--
-- !-- Insight: This is the structural engine behind "tropical polynomials are convex": tropicalization turns ⊕ (max) into pointwise sup, and sup preserves convexity. -- !--
-- !-- Failure analysis: Direct exact? found nothing in Mathlib; the result is not packaged for sup', so an explicit argument was required. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Pointwise `sup'` of convex functions over a nonempty Finset is convex. -- !--
theorem convexOn_finset_sup' {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (f : ι → ℝ → ℝ) (hf : ∀ i ∈ s, ConvexOn ℝ (univ : Set ℝ) (f i)) :
    ConvexOn ℝ (univ : Set ℝ) (fun x => s.sup' hs (fun i => f i x)) := by
  rcases s with ⟨⟨l⟩⟩
  simp_all +decide [ConvexOn]
  refine ⟨convex_univ, fun x y a b ha hb hab i hi => le_trans (hf i hi |>.2 ha hb hab) ?_⟩
  gcongr <;> aesop

-- !-- Lab Notebook: tropPoly_convexOn -- !--
-- !-- Hypothesis: Every tropical polynomial (finite max of affine monomials) is convex. -- !--
-- !-- Result: Immediate from convexOn_finset_sup' applied to the affine monomials, each convex by tropMonomial_convexOn. -- !--
-- !-- Insight: This GENERALIZES tropical_linear_mono / tropical_quadratic_mono from the catalog (degrees 1,2, monotone) to arbitrary degree with the stronger conclusion of convexity. -- !--
-- !-- Failure analysis: The only subtlety is matching `coeffs i + slopes i * x` with `tropMonomial (coeffs i) (slopes i) x` definitionally, handled by `convert`. -- !--
-- !-- End Lab Notebook -- !--

-- !-- MAIN RESULT: every degree-n tropical polynomial is a convex function. -- !--
theorem tropPoly_convexOn {n : ℕ} (coeffs slopes : Fin (n + 1) → ℝ) :
    ConvexOn ℝ (univ : Set ℝ) (tropPoly coeffs slopes) := by
  convert convexOn_finset_sup' _ _ _ _
  exact fun i _ => tropMonomial_convexOn _ _

-- !-- Lab Notebook: tropPoly_monotone_of_slopes_nonneg -- !--
-- !-- Hypothesis: If all slopes are ≥ 0 the tropical polynomial is monotone increasing. -- !--
-- !-- Result: Proved via Finset.sup'_le / Finset.le_sup' monotonicity of sup'. -- !--
-- !-- Insight: Generalizes tropical_linear_mono and tropical_quadratic_mono to all degrees in one statement. -- !--
-- !-- Failure analysis: none of note; monotonicity of each monomial transfers through sup'. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Nonnegative slopes ⇒ the tropical polynomial is monotone increasing. -- !--
theorem tropPoly_monotone_of_slopes_nonneg {n : ℕ} (coeffs slopes : Fin (n + 1) → ℝ)
    (hs : ∀ i, 0 ≤ slopes i) : Monotone (tropPoly coeffs slopes) := by
  intro x y hxy
  exact Finset.sup'_le _ _ fun i _ =>
    le_trans (by nlinarith [hs i])
      (Finset.le_sup' (fun i => coeffs i + slopes i * y) (Finset.mem_univ i))

-- !-- Lab Notebook: tropPoly_midpoint_le -- !--
-- !-- Hypothesis: Convexity yields the tropical Jensen midpoint inequality. -- !--
-- !-- Result: Specialize the convex-combination inequality of tropPoly_convexOn with weights 1/2,1/2. -- !--
-- !-- Insight: Tropical polynomials never "bulge upward" at midpoints — a quantitative consequence of convexity. -- !--
-- !-- Failure analysis: only bookkeeping to rewrite (1/2)•x+(1/2)•y as (x+y)/2 via norm_num/ring. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Tropical Jensen: convexity gives the midpoint inequality. -- !--
theorem tropPoly_midpoint_le {n : ℕ} (coeffs slopes : Fin (n + 1) → ℝ) (x y : ℝ) :
    tropPoly coeffs slopes ((x + y) / 2)
      ≤ (tropPoly coeffs slopes x + tropPoly coeffs slopes y) / 2 := by
  have h_troppy := tropPoly_convexOn coeffs slopes
  convert h_troppy.2 (Set.mem_univ x) (Set.mem_univ y)
    (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num) using 1 <;>
    norm_num <;> ring

-- !-- Lab Notebook: tropical_freshmans_dream -- !--
-- !-- Hypothesis: In the max-plus semiring the "freshman's dream" / Frobenius rule holds exactly: raising a tropical sum to a (nonneg) power distributes, i.e. k·max(a,b) = max(k·a, k·b) for k ≥ 0. -- !--
-- !-- Result: Proved via mul_max_of_nonneg (monotonicity of scaling by a nonnegative real). -- !--
-- !-- Insight: This is the tropical shadow of (a+b)^p = a^p + b^p failing classically but holding tropically — the algebraic heart of why tropicalization linearizes degeneration. -- !--
-- !-- Failure analysis: requires k ≥ 0; for k < 0 the max flips to min (see the boundary conjecture in FUTURE_DIRECTIONS.md). -- !--
-- !-- End Lab Notebook -- !--

-- !-- Max-plus Frobenius / freshman's dream: `k·max(a,b) = max(k·a, k·b)` for `k ≥ 0`. -- !--
theorem tropical_freshmans_dream (k a b : ℝ) (hk : 0 ≤ k) :
    k * max a b = max (k * a) (k * b) := by
  rw [← mul_max_of_nonneg _ _ hk]

/-! ## Generalization (Step 7)

The natural generalization of `tropPoly_convexOn` replaces the one-dimensional
domain `ℝ` by an arbitrary real vector space and the affine monomials by genuine
convex functions; the conclusion (convexity of the finite pointwise maximum)
persists.  We were able to prove this generalization outright. -/

-- !-- Lab Notebook: tropPoly_convexOn_general -- !--
-- !-- Hypothesis: Convexity of the finite pointwise max survives in any real vector space domain. -- !--
-- !-- Result: Proved with the same convex-combination bound as the 1-D case, now over E. -- !--
-- !-- Insight: Nothing in the argument used dimension 1; tropical polytopes / tropical hypersurfaces in any dimension are convex max-of-affine functions. -- !--
-- !-- Failure analysis: The boundary lies in dropping convexity of the pieces (a max of non-convex functions need not be convex) — that is the genuine limit, not the dimension. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Multivariate generalization: finite pointwise sup' of convex functions on a vector space is convex. -- !--
theorem tropPoly_convexOn_general {E : Type*} [AddCommMonoid E] [Module ℝ E]
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (g : ι → E → ℝ)
    (hg : ∀ i ∈ s, ConvexOn ℝ (univ : Set E) (g i)) :
    ConvexOn ℝ (univ : Set E) (fun x => s.sup' hs (fun i => g i x)) := by
  refine ⟨convex_univ, fun x _ y _ a b ha hb hab => ?_⟩
  simp_all +decide [ConvexOn]
  exact fun i hi => le_trans (hg i hi |>.2 ha hb hab)
    (add_le_add (mul_le_mul_of_nonneg_left (Finset.le_sup' (fun i => g i x) hi) ha)
      (mul_le_mul_of_nonneg_left (Finset.le_sup' (fun i => g i y) hi) hb))

end TropicalConvexity


-- !-- Merged from Convexity.lean (auto-dedup) -- !--

  # Tropical Convexity Lemmas
  Proves that tropical halfspaces are tropically convex, intersections
  preserve tropical convexity, and tropical polyhedra are tropically convex.
import Tropical.Defs
open Finset TropicalConvexity
noncomputable section
/-! ## Tropical halfspaces are tropically convex -/
The key algebraic fact: `tropMin` distributes over tropical combinations.
    More precisely, for any `a, c₁, c₂ : ℝ` and `x, y : Fin n → ℝ`,
    `tropMin a (tropAdd (tropScale c₁ x) (tropScale c₂ y))` is at most
    `min (c₁ + tropMin a x) (c₂ + tropMin a y)`.
theorem tropMin_tropAdd_tropScale_le {n : ℕ} [NeZero n]
    (a : Fin n → ℝ) (x y : Fin n → ℝ) (c₁ c₂ : ℝ) :
    tropMin a (tropAdd (tropScale c₁ x) (tropScale c₂ y)) ≤
      min (c₁ + tropMin a x) (c₂ + tropMin a y) := by
  -- By definition of $tropMin$, we know that
  have h_tropMin_def : tropMin a (tropAdd (tropScale c₁ x) (tropScale c₂ y)) = Finset.univ.inf' (Finset.univ_nonempty) (fun i => a i + min (c₁ + x i) (c₂ + y i)) := by
    rfl;
  -- By definition of $tropMin$, we know that for any $i$, $a i + min (c₁ + x i) (c₂ + y i) ≤ min (c₁ + (a i + x i)) (c₂ + (a i + y i))$.
  have h_ineq : ∀ i, a i + min (c₁ + x i) (c₂ + y i) ≤ min (c₁ + (a i + x i)) (c₂ + (a i + y i)) := by
    exact fun i => by cases min_cases ( c₁ + x i ) ( c₂ + y i ) <;> cases min_cases ( c₁ + ( a i + x i ) ) ( c₂ + ( a i + y i ) ) <;> linarith;
  -- Applying the inequality $a i + min (c₁ + x i) (c₂ + y i) ≤ min (c₁ + (a i + x i)) (c₂ + (a i + y i))$ to the infimum, we get:
  have h_inf_ineq : Finset.univ.inf' (Finset.univ_nonempty) (fun i => a i + min (c₁ + x i) (c₂ + y i)) ≤ Finset.univ.inf' (Finset.univ_nonempty) (fun i => min (c₁ + (a i + x i)) (c₂ + (a i + y i))) := by
    grind +qlia;
  -- Applying the inequality $min (c₁ + (a i + x i)) (c₂ + (a i + y i)) ≤ min (c₁ + tropMin a x) (c₂ + tropMin a y)$ to the infimum, we get:
  have h_inf_ineq' : Finset.univ.inf' (Finset.univ_nonempty) (fun i => min (c₁ + (a i + x i)) (c₂ + (a i + y i))) ≤ min (c₁ + tropMin a x) (c₂ + tropMin a y) := by
    obtain ⟨ i, hi ⟩ := exists_tropMin_eq a x; obtain ⟨ j, hj ⟩ := exists_tropMin_eq a y; simp_all +decide [ Finset.inf'_le ] ;
    exact ⟨ ⟨ i, Or.inl le_rfl ⟩, ⟨ j, Or.inr le_rfl ⟩ ⟩;
Tropical halfspaces are tropically convex: for any coefficient vectors `a b`,
    the set `{x | tropMin a x ≤ tropMin b x}` is closed under tropical combinations.
theorem isTropicallyConvex_tropicalHalfspace {n : ℕ} [NeZero n]
    (a b : Fin n → ℝ) : IsTropicallyConvex (tropicalHalfspace a b) := by
  intro x y hy c₁ c₂;
  intro c₃;
  have hz_le : tropMin a (tropAdd (tropScale c₂ x) (tropScale c₃ y)) ≤ min (c₂ + tropMin a x) (c₃ + tropMin a y) := by
    exact?;
  have hz_ge : tropMin b (tropAdd (tropScale c₂ x) (tropScale c₃ y)) ≥ min (c₂ + tropMin b x) (c₃ + tropMin b y) := by
    simp +decide [ tropMin, tropAdd, tropScale ];
    intro i; cases le_total ( c₂ + x i ) ( c₃ + y i ) <;> simp +decide [ * ] ;
    · exact Or.inl ( by linarith [ Finset.inf'_le ( fun i => b i + x i ) ( Finset.mem_univ i ) ] );
    · exact Or.inr ( by linarith [ Finset.inf'_le ( fun i => b i + y i ) ( Finset.mem_univ i ) ] );
  exact le_trans hz_le ( by cases min_cases ( c₂ + tropMin a x ) ( c₃ + tropMin a y ) <;> cases min_cases ( c₂ + tropMin b x ) ( c₃ + tropMin b y ) <;> linarith [ hy.out, c₁.out ] ) |> le_trans <| hz_ge
/-! ## Finite intersections preserve tropical convexity -/
The intersection of any family of tropically convex sets is tropically convex.
theorem isTropicallyConvex_iInter {n : ℕ} {ι : Type*} {S : ι → Set (Fin n → ℝ)}
    (hS : ∀ i, IsTropicallyConvex (S i)) :
    IsTropicallyConvex (⋂ i, S i) := by
  intro x y hx hy a b;
Finite intersection version using `Finset`.
theorem isTropicallyConvex_biInter_finset {n : ℕ} {F : Finset (Set (Fin n → ℝ))}
    (hF : ∀ s ∈ F, IsTropicallyConvex s) :
    IsTropicallyConvex (⋂ s ∈ F, s) := by
  convert isTropicallyConvex_iInter _;
  intro s; by_cases hs : s ∈ F <;> simp +decide [ *, IsTropicallyConvex ] ;
  exact hF s hs
/-! ## Tropical polyhedra are tropically convex -/
Every tropical polyhedron (finite intersection of tropical halfspaces)
    is tropically convex.
theorem isTropicallyConvex_of_isTropicalPolyhedron {n : ℕ} [NeZero n]
    {S : Set (Fin n → ℝ)} (h : IsTropicalPolyhedron S) :
    IsTropicallyConvex S := by
  -- By definition of $S$, we know that $S$ is a finite intersection of sets of the form $tropicalHalfspace.
  obtain ⟨halfspaces, hS⟩ := h;
  convert isTropicallyConvex_iInter _;
  intro h; by_cases hi : h ∈ halfspaces <;> simp +decide [ hi, isTropicallyConvex_tropicalHalfspace ] ;
  · exact isTropicallyConvex_tropicalHalfspace _ _;
  · exact fun x y _ _ a b => Set.mem_univ _