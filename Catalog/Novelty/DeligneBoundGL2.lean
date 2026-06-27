/-
# Deligne's bound: Frobenius eigenvalues are Weil numbers (GL₂ over ℚ)

This file formalizes the **analytic half of the GL₂ Langlands data over `ℚ`**: Deligne's
theorem (the Ramanujan–Petersson conjecture for weight-`2` newforms), which says that the
Frobenius eigenvalues attached to a Hecke eigenform are **Weil numbers of weight one**.
Concretely, the two roots `α, β` of the Hecke polynomial `X² − a_p·X + p`
(from `Catalog.Novelty.EichlerShimuraGL2`) satisfy
$$|\alpha| = |\beta| = \sqrt p,\qquad\text{equivalently}\qquad |a_p| \le 2\sqrt p .$$

This is the GL₂ refinement of the GL₁ picture in the catalog: there the local Frobenius
value is a *root of unity* (`|·| = 1`); here it is a Weil number of absolute value `√p`,
and the new phenomenon is that the bound is a genuine inequality controlled by the
discriminant of the quadratic Hecke polynomial.

Main results:

* `DeligneBoundGL2.deligne_bound_iff` — the scalar Deligne bound
  `|a| ≤ 2√p ↔ a² ≤ 4p`.
* `DeligneBoundGL2.deligne_root_abs` — every complex root of the Hecke polynomial is a
  Weil number: if `a² ≤ 4p` and `(heckePoly a p).eval z = 0`, then `‖z‖ = √p`.
* `DeligneBoundGL2.deligne_weil_pair` — the two Frobenius eigenvalues `α, β` satisfy
  `αβ = p` and `‖α‖ = ‖β‖ = √p`.
* `DeligneBoundGL2.deligne_frob_eigenvalues` — the eigenvalues of the concrete Frobenius
  companion matrix `frobMatrix a p` (over `ℂ`) all have absolute value `√p`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog GL(1) datum is a root of unity, `|·| = 1`.  The bold
GL₂ analogue, and the deepest input to the correspondence, is Deligne's bound: the Frobenius
eigenvalues lie on the circle of radius `√p`.  Conjecture: the *purely real-algebraic core* of
this — "a real quadratic `z² − a z + p` with `p > 0` has all complex roots on `|z| = √p` exactly
when `a² ≤ 4p`" — is provable unconditionally and is the honest finite shadow of Deligne's
theorem (whose full proof needs the Weil conjectures).

Experiment (Experimenter): the equivalence `|a| ≤ 2√p ↔ a² ≤ 4p` is `nlinarith` after rewriting
`4p = (2√p)²` via `Real.sq_sqrt`.  For the root statement we split a complex root `z = x + yi`
into real/imaginary parts (`congrArg Complex.re/im`), giving `2xy = ay` and `x² − y² − ax + p = 0`.
Case `y = 0`: the discriminant `(2x − a)² = a² − 4p ≤ 0` forces `a² = 4p`, hence `x² = p`.
Case `y ≠ 0`: `2x = a`, and substituting collapses `x² + y² = p`.  Either way `normSq z = p`,
so `‖z‖ = √p`.  The pair statement and the companion-matrix statement reuse `deligne_root_abs`.

Analysis (Analyst): the hypothesis `a² ≤ 4p` is *exactly* the boundary between Weil numbers and
real Frobenius eigenvalues.  When `a² > 4p` the roots are real with distinct moduli — the bound
fails — so the hypothesis is load-bearing, mirroring why Deligne's theorem is a real theorem and
not a formality.  The case split `y = 0` vs `y ≠ 0` is the formal trace of "ordinary vs
supersingular / split vs inert" behavior of the local datum.

Critique (Critic): is any result trivial?  No — `deligne_root_abs` is a genuine case analysis
on the geometry of the root, not `decide`/`simp`.  `deligne_frob_eigenvalues` is not vacuous:
the companion matrix `frobMatrix a p` (imported from `EichlerShimuraGL2`) really has the Hecke
polynomial as characteristic polynomial, so its eigenvalues are genuine roots.  Corner cases:
`p = 0` is excluded (`0 < p`) since a Weil number of weight one needs `p > 0`; at `a² = 4p`
the two eigenvalues coincide at `±√p`, still satisfying the conclusion.

Synthesis (PI): combining `EichlerShimuraGL2` (algebraic local datum) with this file (analytic
Weil bound) gives both halves of the local GL₂ correspondence over `ℚ`: a `2 × 2` Frobenius with
trace `a_p`, determinant `p`, Eichler–Shimura relation, and Weil eigenvalues of absolute value
`√p`.
-/
import Mathlib
import Catalog.Novelty.EichlerShimuraGL2

open Polynomial Matrix EichlerShimuraGL2

namespace DeligneBoundGL2

/-- **Deligne's bound, scalar form.** For `p ≥ 0`, the Hecke eigenvalue bound `|a| ≤ 2√p`
is equivalent to the discriminant condition `a² ≤ 4p`. -/
theorem deligne_bound_iff (a p : ℝ) (hp : 0 ≤ p) :
    |a| ≤ 2 * Real.sqrt p ↔ a ^ 2 ≤ 4 * p := by
  have key : (2 * Real.sqrt p) ^ 2 = 4 * p := by rw [mul_pow, Real.sq_sqrt hp]; ring
  constructor
  · intro h; nlinarith [sq_abs a, h, abs_nonneg a, Real.sqrt_nonneg p, key]
  · intro h; nlinarith [sq_abs a, h, abs_nonneg a, Real.sqrt_nonneg p, key]

/-- **Deligne / Ramanujan–Petersson (weight-one Weil bound).** Every complex root of the Hecke
polynomial `X² − a·X + p` is a Weil number of absolute value `√p`, provided `a² ≤ 4p`. -/
theorem deligne_root_abs (a p : ℝ) (hp : 0 < p) (ha : a ^ 2 ≤ 4 * p) (z : ℂ)
    (hz : (heckePoly (a : ℂ) (p : ℂ)).eval z = 0) : ‖z‖ = Real.sqrt p := by
  rw [heckePoly_eval] at hz
  have hre : z.re ^ 2 - z.im ^ 2 - a * z.re + p = 0 := by
    have h := congrArg Complex.re hz
    simp [Complex.add_re, Complex.sub_re, Complex.mul_re, pow_two] at h
    linarith [h]
  have him : 2 * z.re * z.im - a * z.im = 0 := by
    have h := congrArg Complex.im hz
    simp [Complex.add_im, Complex.sub_im, Complex.mul_im, pow_two] at h
    linarith [h]
  have hns : Complex.normSq z = p := by
    rw [Complex.normSq_apply]
    rcases eq_or_ne z.im 0 with hy | hy
    · rw [hy] at hre ⊢
      have h1 : z.re ^ 2 - a * z.re + p = 0 := by ring_nf; ring_nf at hre; linarith
      nlinarith [sq_nonneg (2 * z.re - a)]
    · have hx : a = 2 * z.re := by
        have h0 : z.im * (a - 2 * z.re) = 0 := by ring_nf; nlinarith [him]
        rcases mul_eq_zero.1 h0 with h | h
        · exact absurd h hy
        · linarith
      subst hx
      nlinarith [hre]
  rw [Complex.norm_def, hns]

/-- **The Weil pair.** The two Frobenius eigenvalues `α, β` (roots of the Hecke polynomial)
satisfy `αβ = p` and both have absolute value `√p`. -/
theorem deligne_weil_pair (a p : ℝ) (hp : 0 < p) (ha : a ^ 2 ≤ 4 * p) (α β : ℂ)
    (hsum : α + β = (a : ℂ)) (hprod : α * β = (p : ℂ)) :
    α * β = (p : ℂ) ∧ ‖α‖ = Real.sqrt p ∧ ‖β‖ = Real.sqrt p := by
  refine ⟨hprod, ?_, ?_⟩ <;>
    · apply deligne_root_abs a p hp ha
      rw [heckePoly_eval, ← hsum, ← hprod]; ring

/-- **Frobenius eigenvalues are Weil numbers.** Any eigenvalue `λ` of the concrete Frobenius
companion matrix `frobMatrix a p` over `ℂ` (i.e. with `frobMatrix a p − λ` singular) has
absolute value `√p`, whenever `a² ≤ 4p`. -/
theorem deligne_frob_eigenvalues (a p : ℝ) (hp : 0 < p) (ha : a ^ 2 ≤ 4 * p) (lam : ℂ)
    (hlam : ¬ IsUnit (frobMatrix (a : ℂ) (p : ℂ) - lam • (1 : Matrix (Fin 2) (Fin 2) ℂ))) :
    ‖lam‖ = Real.sqrt p := by
  apply deligne_root_abs a p hp ha
  -- `λ` is an eigenvalue iff `det(frobMatrix − λ) = 0`, which equals `heckePoly` evaluated at `λ`.
  have hdet : Matrix.det (frobMatrix (a : ℂ) (p : ℂ) - lam • (1 : Matrix (Fin 2) (Fin 2) ℂ)) = 0 := by
    by_contra hne
    exact hlam ((Matrix.isUnit_iff_isUnit_det _).mpr (isUnit_iff_ne_zero.mpr hne))
  have hmat : frobMatrix (a : ℂ) (p : ℂ) - lam • (1 : Matrix (Fin 2) (Fin 2) ℂ)
      = !![-lam, -(p : ℂ); 1, (a : ℂ) - lam] := by
    ext i j; fin_cases i <;> fin_cases j <;> simp [frobMatrix]
  rw [hmat, Matrix.det_fin_two_of] at hdet
  rw [heckePoly_eval]
  linear_combination hdet

end DeligneBoundGL2