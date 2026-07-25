import Mathlib
import Bridges.PolynomialBridge
import Geometry.GenusFormula

/-!
# Algebraic Surrogates for Turing Pattern Nodal Sets

Finite-mode reaction–diffusion ansätze need not themselves be polynomial: trigonometric
Laplacian eigenmodes already show that unrestricted nodal sets are not automatically
algebraic. This chapter isolates a precise algebraic surrogate. An affine spatial mode
is represented by a linear polynomial, and multiplicative threshold coupling turns two
such modes into a quadratic whose zero set is exactly the union of their nodal lines.
Radial and bilinear quadratics supply rigorous spot and hyperbolic models.

The results also identify a boundary of the motivating degree heuristic: the sum of all
pairwise interactions among three affine modes still has degree at most two, not six.
Thus mode count alone cannot determine algebraic degree; the interaction law matters.
-/

namespace TuringAlgebraicPatterns

open Polynomial

/-- A one-dimensional affine concentration mode with slope `a` and offset `b`. -/
noncomputable def affineMode (a b : ℝ) : Polynomial ℝ := C a * X + C b

/-- Multiplicative threshold coupling of two affine modes. -/
noncomputable def twoModePattern (a b c d : ℝ) : Polynomial ℝ :=
  affineMode a b * affineMode c d

/-- The pairwise-interaction closure of three affine modes. -/
noncomputable def threeModePairwise (p q r : Polynomial ℝ) : Polynomial ℝ :=
  p * q + q * r + r * p

/-- The radial quadratic used as an idealized spot boundary. -/
def spotEquation (radius x y : ℝ) : ℝ := x ^ 2 + y ^ 2 - radius ^ 2

/-- The bilinear quadratic used as an idealized hyperbolic or labyrinth branch. -/
def hyperbolaEquation (level x y : ℝ) : ℝ := x * y - level

/-
-- !-- Lab Notes -- !--
Hypothesis (cross-domain bridge target): polynomial interaction laws provide an exact
algebraic-geometric description of selected finite-mode nodal sets. Seven falsifiable
candidates were ranked by impact: (1) arbitrary Turing nodal sets are algebraic;
(2) mode count determines degree; (3) two affine modes coupled multiplicatively give
a conic; (4) three affine modes force sextics; (5) a radial quadratic has bounded
nodal coordinates; (6) positive bilinear levels split by sign; (7) smooth conics have
genus zero. Candidates (1), (2), and (4) are deliberately bold; the experiments below
retain guarded forms of (3), (5), (6), and (7), and refute the proposed inference in
(4) for pairwise affine coupling.
-/

/-- Evaluation of an affine mode is the expected affine function. -/
lemma eval_affineMode (a b x : ℝ) :
    eval x (affineMode a b) = a * x + b := by
  unfold affineMode
  simp

/-- A nonconstant affine mode has polynomial degree one. -/
lemma degree_affineMode (a b : ℝ) (ha : a ≠ 0) :
    (affineMode a b).degree = 1 := by
  exact Polynomial.degree_linear ha

/-- Two genuinely spatial affine modes produce a quadratic polynomial. -/
theorem twoModePattern_degree (a b c d : ℝ) (ha : a ≠ 0) (hc : c ≠ 0) :
    (twoModePattern a b c d).degree = 2 := by
  unfold twoModePattern
  rw [Polynomial.degree_mul, degree_affineMode, degree_affineMode] <;> aesop

/-- The quadratic nodal set is exactly the union of the two affine nodal lines. -/
theorem twoModePattern_zero_iff (a b c d x : ℝ) :
    eval x (twoModePattern a b c d) = 0 ↔
      a * x + b = 0 ∨ c * x + d = 0 := by
  unfold twoModePattern affineMode
  aesop

/-
-- !-- Lab Notes -- !--
Experiment: exact evaluation and degree calculations were performed symbolically.
Multiplication is the decisive operation: it both adds degrees and changes a logical
factorization into a geometric union of zero sets. No PDE-to-polynomial identification
is assumed.
-/

/-- Every point of a nonnegative-radius spot conic lies in its coordinate bounding box. -/
theorem spot_zero_bounded {radius x y : ℝ} (hr : 0 ≤ radius)
    (hzero : spotEquation radius x y = 0) :
    |x| ≤ radius ∧ |y| ≤ radius := by
  constructor <;> rw [abs_le] <;> constructor <;>
    nlinarith [hzero, (show spotEquation radius x y =
      x ^ 2 + y ^ 2 - radius ^ 2 by rfl)]

/-- Every real radius parameter has explicit points on the radial quadratic. -/
theorem spot_zero_nonempty (radius : ℝ) :
    spotEquation radius radius 0 = 0 ∧ spotEquation radius (-radius) 0 = 0 := by
  unfold spotEquation
  norm_num

/-- A positive hyperbolic level forces the two coordinates to have the same strict sign. -/
theorem hyperbola_positive_sign_branches {level x y : ℝ} (hl : 0 < level)
    (hzero : hyperbolaEquation level x y = 0) :
    (0 < x ∧ 0 < y) ∨ (x < 0 ∧ y < 0) := by
  cases lt_trichotomy x 0 <;> cases lt_trichotomy y 0 <;>
    simp_all [hyperbolaEquation]
  · cases ‹_› <;> nlinarith
  · cases ‹x = 0 ∨ 0 < x› <;> nlinarith
  · grind

/-- Pairwise interactions among three affine modes have degree at most two. -/
theorem threeModePairwise_degree_le_two (a b c d e f : ℝ) :
    (threeModePairwise (affineMode a b) (affineMode c d) (affineMode e f)).degree ≤ 2 := by
  refine le_trans (Polynomial.degree_add_le _ _) (max_le ?_ ?_)
  · refine le_trans (Polynomial.degree_add_le _ _) ?_
    unfold affineMode
    norm_num
    exact ⟨
      le_trans (add_le_add Polynomial.degree_linear_le Polynomial.degree_linear_le) (by norm_num),
      le_trans (add_le_add Polynomial.degree_linear_le Polynomial.degree_linear_le) (by norm_num)⟩
  · refine le_trans (Polynomial.degree_mul_le _ _) ?_
    refine le_trans (add_le_add Polynomial.degree_linear_le Polynomial.degree_linear_le) ?_
    norm_num

/-- A quadratic smooth-plane-curve model has arithmetic genus zero. -/
theorem quadratic_model_genus_zero : Hilbert16.planeCurveGenus 2 = 0 := by
  exact Hilbert16.planeCurveGenus_two

/-- The complete guarded two-mode conclusion: exact quadratic degree, exact nodal
factorization, and genus zero for the corresponding smooth projective conic model. -/
theorem guarded_two_mode_conic_model (a b c d : ℝ) (ha : a ≠ 0) (hc : c ≠ 0) :
    (twoModePattern a b c d).degree = 2 ∧
    (∀ x, eval x (twoModePattern a b c d) = 0 ↔
      a * x + b = 0 ∨ c * x + d = 0) ∧
    Hilbert16.planeCurveGenus 2 = 0 := by
  exact ⟨twoModePattern_degree a b c d ha hc,
    fun x => twoModePattern_zero_iff a b c d x, quadratic_model_genus_zero⟩

/-
-- !-- Lab Notes -- !--
Analysis: the two-factor theorem survives exactly, as do bounded radial spots and the
two sign branches of a positive hyperbola. The universal biological claim needs a
different definition: generic PDE eigenfunctions are analytic rather than polynomial.
The degree-equals-mode-count slogan also fails without an explicit coupling law.
-/

/-
-- !-- Lab Notes -- !--
Critique: none of the main conclusions follows merely by unfolding a definition. The
exact-degree result requires both nonzero slopes; dropping either permits degree loss.
The spot bound requires nonnegative radius, and the hyperbola sign theorem requires a
positive, not zero, level. Arithmetic genus is asserted only for the smooth projective
conic model, not for the reducible pair of lines itself.
-/

/-
-- !-- Lab Notes -- !--
Synthesis: finite affine modes plus polynomial coupling form a clean bridge from
reaction–diffusion surrogates to algebraic geometry. The verified invariant is not
"number of modes" but the degree of the chosen interaction polynomial. This suggests
studying interaction hypergraphs and singularities before drawing topological or
biological conclusions.
-/

end TuringAlgebraicPatterns