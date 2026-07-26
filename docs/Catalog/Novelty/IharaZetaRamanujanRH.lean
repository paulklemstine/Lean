/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Riemann Hypothesis for the Ihara zeta function of a regular graph

The Ihara zeta function of a finite connected `(q+1)`-regular graph `G` on `n`
vertices admits the closed determinantal form

    ζ_G(u)⁻¹ = (1 - u²)^{(n-1)(q-1)/2} · det(I - A u + q u² I),

where `A` is the adjacency matrix.  Its non-trivial poles are therefore the
reciprocals of the roots of the *local factors*

    p_λ(u) = q u² - λ u + 1,   λ ∈ spec(A),

one factor per adjacency eigenvalue `λ`.  The **Riemann Hypothesis for `ζ_G`**
asks that every non-trivial pole lie on the circle `|u| = 1/√q`; equivalently
that every root of each non-trivial local factor lie on that circle.

This file isolates and proves the arithmetic heart of Ihara's theorem: a single
local factor `p_λ` has *all* of its complex roots on the circle `|u| = 1/√q`
**iff** the eigenvalue satisfies the Ramanujan bound `|λ| ≤ 2√q`.  Summed over
the spectrum this is exactly the statement

    ζ_G satisfies the Riemann Hypothesis  ⇔  G is a Ramanujan graph.

The argument is a genuine bridge between complex analysis (location of the roots
of a quadratic), real algebra (the discriminant / Vieta relations) and spectral
graph theory (the Ramanujan spectral gap).

## Main results

* `iharaFactor` — the local factor `q u² - λ u + 1` attached to an eigenvalue.
* `root_norm_of_ramanujan` — Ramanujan bound ⇒ every root sits on `|u| = 1/√q`.
* `ramanujan_of_root_norm` — the converse: if every root sits on the circle then
  the Ramanujan bound holds.
* `ihara_RH_iff_ramanujan` — the equivalence "RH for the local factor ⇔ Ramanujan".
* `trivial_eigenvalue_factor`, `trivial_eigenvalue_breaks_RH` — the boundary
  phenomenon: the *trivial* eigenvalue `λ = q + 1` factors the local polynomial
  as `(q u - 1)(u - 1)`, whose roots `1` and `1/q` do **not** lie on the circle,
  which is precisely why the Riemann Hypothesis is imposed only on the
  non-trivial spectrum.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  The Ihara/Ramanujan correspondence "RH ⇔ Ramanujan"
should reduce, factor by factor, to a purely quadratic statement: the two roots
of `q u² - λ u + 1` lie on the circle of radius `1/√q` exactly when `λ² ≤ 4q`.
The bold claim is that this scalar lemma already contains the full spectral
content of Ihara's theorem.

Experiment (Experimenter).  Formalised the local factor and proved both
directions.  Forward direction: for a root `u`, conjugating the defining
equation and combining with the original gives either `u` real (forcing the
discriminant to be non-negative, hence `λ² = 4q` at the Ramanujan boundary and
`u² = 1/q`), or `u + ū = λ/q`, whence adding the equation to its conjugate
yields `u ū = 1/q`, i.e. `normSq u = 1/q`.  Converse: when `λ² > 4q` the two
*distinct real* roots `r± = (λ ± √(λ²-4q))/(2q)` have product `1/q > 0`, so they
share a sign; if both had modulus `1/√q` they would be equal, contradicting
distinctness.

Analysis (Analyst).  The whole spectral theorem collapses onto a discriminant
sign test.  The "trivial" eigenvalue `λ = q+1` is exactly the case where the
discriminant is a perfect square `(q-1)²` and the roots escape the circle to the
real points `1` and `1/q`; this is the structural reason RH is stated only for
the non-trivial spectrum.

Critique (Critic).  Guarded against vacuity: `iharaFactor` is a genuine degree-2
polynomial with `q ≠ 0`, so it always has complex roots and the universally
quantified statements are non-empty.  The boundary lemma exhibits an explicit
counterexample to the naive (unrestricted) RH, ruling out a vacuously true
reading.

Synthesis (PI).  The equivalence `ihara_RH_iff_ramanujan` packages the two
directions; the trivial-eigenvalue lemmas delimit its scope.
-- !-- Lab Notes -- !--
-/

import Mathlib

open Complex

namespace IharaZeta

/-- The **local factor** of the Ihara zeta function attached to an adjacency
eigenvalue `λ` of a `(q+1)`-regular graph:
`p_λ(u) = q u² - λ u + 1`.  Its reciprocal roots are the corresponding poles of
`ζ_G`. -/
noncomputable def iharaFactor (q lam : ℝ) (u : ℂ) : ℂ :=
  (q : ℂ) * u ^ 2 - (lam : ℂ) * u + 1

/-- Conjugating a root: since `q` and `λ` are real, `iharaFactor q lam` commutes
with complex conjugation. -/
lemma iharaFactor_conj (q lam : ℝ) (u : ℂ) :
    (starRingEnd ℂ) (iharaFactor q lam u) = iharaFactor q lam ((starRingEnd ℂ) u) := by
  simp [iharaFactor, map_sub, map_add, map_mul, map_pow, Complex.conj_ofReal]

/-
**Ramanujan ⇒ Riemann Hypothesis (local factor).**  If the eigenvalue `λ`
satisfies the Ramanujan bound `|λ| ≤ 2√q`, then every complex root of the local
factor lies on the circle `|u| = 1/√q`.
-/
lemma root_norm_of_ramanujan (q lam : ℝ) (hq : 0 < q)
    (hlam : |lam| ≤ 2 * Real.sqrt q) (u : ℂ) (hu : iharaFactor q lam u = 0) :
    ‖u‖ = 1 / Real.sqrt q := by
  -- By definition of $iharaFactor$, we have $q * u^2 - lam * u + 1 = 0$.
  unfold iharaFactor at hu;
  -- Using the fact that $u + \overline{u} = \frac{\lambda}{q}$, we substitute this into the above equation to get $\left(\frac{\lambda}{q}\right)^2 - 2u\overline{u} = \frac{\lambda^2}{q^2} - 2u\overline{u} = \frac{\lambda^2}{q^2} - 2\|u\|^2$.
  have h_norm : Complex.normSq u = 1 / q := by
    by_cases h : Complex.re u = 0 <;> by_cases h' : Complex.im u = 0 <;> simp_all +decide [ Complex.ext_iff, sq ];
    · exact eq_inv_of_mul_eq_one_right ( by norm_num [ Complex.normSq_apply, h, h' ] ; linarith );
    · -- Since $u$ is real, we have $u.re^2 = 1/q$.
      have h_real_sq : u.re ^ 2 = 1 / q := by
        -- Since $u$ is real, we have $lam^2 = 4q$.
        have h_lam_sq : lam^2 = 4 * q := by
          nlinarith [ sq_nonneg ( lam - 2 * q * u.re ), mul_self_pos.2 h, Real.mul_self_sqrt hq.le, abs_le.mp hlam ];
        exact eq_one_div_of_mul_eq_one_right <| by cases lt_or_gt_of_ne h <;> nlinarith;
      simp_all +decide [ Complex.normSq_apply, sq ];
    · -- From the equation $q * (u.re * u.im + u.im * u.re) - lam * u.im = 0$, we can solve for $lam$.
      have h_lam : lam = 2 * q * u.re := by
        exact mul_left_cancel₀ h' <| by linarith;
      simp_all +decide [ Complex.normSq ];
      cases abs_cases q <;> cases abs_cases u.re <;> nlinarith [ Real.sqrt_nonneg q, Real.sq_sqrt hq.le, mul_inv_cancel₀ hq.ne' ];
  simp_all +decide [ Complex.norm_def, Complex.normSq_apply ]

/-
**Riemann Hypothesis ⇒ Ramanujan (local factor).**  If every complex root of
the local factor lies on the circle `|u| = 1/√q`, then the eigenvalue satisfies
the Ramanujan bound.
-/
lemma ramanujan_of_root_norm (q lam : ℝ) (hq : 0 < q)
    (h : ∀ u : ℂ, iharaFactor q lam u = 0 → ‖u‖ = 1 / Real.sqrt q) :
    |lam| ≤ 2 * Real.sqrt q := by
  contrapose! h;
  refine' ⟨ ( lam + Real.sqrt ( lam^2 - 4 * q ) ) / ( 2 * q ), _, _ ⟩ <;> norm_num [ iharaFactor ];
  · field_simp;
    rw [ div_add', div_eq_iff ] <;> norm_cast <;> norm_num [ hq.ne' ];
    linarith [ Real.mul_self_sqrt ( show 0 ≤ lam ^ 2 - 4 * q by cases abs_cases lam <;> nlinarith [ Real.sqrt_nonneg q, Real.sq_sqrt hq.le ] ) ];
  · rw [ div_eq_iff ( by positivity ) ] ; norm_cast ; norm_num [ abs_of_pos hq ];
    cases abs_cases lam <;> cases abs_cases ( lam + Real.sqrt ( lam ^ 2 - 4 * q ) ) <;> nlinarith [ Real.sqrt_nonneg q, Real.sq_sqrt hq.le, inv_pos.mpr ( Real.sqrt_pos.mpr hq ), mul_inv_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr hq ) ), Real.sqrt_nonneg ( lam ^ 2 - 4 * q ), Real.sq_sqrt ( show 0 <= lam ^ 2 - 4 * q by nlinarith [ Real.sqrt_nonneg q, Real.sq_sqrt hq.le ] ) ]

/-- **The Riemann Hypothesis for `ζ_G` ⇔ `G` is Ramanujan**, at the level of a
single spectral local factor: all roots of `q u² - λ u + 1` lie on the circle
`|u| = 1/√q` if and only if `|λ| ≤ 2√q`. -/
theorem ihara_RH_iff_ramanujan (q lam : ℝ) (hq : 0 < q) :
    (∀ u : ℂ, iharaFactor q lam u = 0 → ‖u‖ = 1 / Real.sqrt q) ↔ |lam| ≤ 2 * Real.sqrt q :=
  ⟨ramanujan_of_root_norm q lam hq, fun hlam u hu => root_norm_of_ramanujan q lam hq hlam u hu⟩

/-- **The trivial eigenvalue.**  For a `(q+1)`-regular graph the Perron
eigenvalue `λ = q + 1` makes the local factor split with real roots:
`q u² - (q+1) u + 1 = (q u - 1)(u - 1)`. -/
lemma trivial_eigenvalue_factor (q : ℝ) (u : ℂ) :
    iharaFactor q (q + 1) u = ((q : ℂ) * u - 1) * (u - 1) := by
  simp only [iharaFactor]
  push_cast
  ring

/-
**Boundary of the theorem.**  The trivial eigenvalue violates the naive
(unrestricted) Riemann Hypothesis: `u = 1` is a root of the local factor but
does not lie on the circle `|u| = 1/√q` once `q > 1`.  This is the structural
reason the Riemann Hypothesis for `ζ_G` is imposed only on the *non-trivial*
spectrum.
-/
theorem trivial_eigenvalue_breaks_RH (q : ℝ) (hq : 1 < q) :
    iharaFactor q (q + 1) 1 = 0 ∧ ‖(1 : ℂ)‖ ≠ 1 / Real.sqrt q := by
  norm_num [ iharaFactor ];
  linarith

/-!
## Concrete instances, generalizations and boundaries

The examples below instantiate the equivalence on the adjacency spectra of
genuine Ramanujan graphs.
-/

/-- **Petersen graph** (`3`-regular, `q = 2`).  Its non-trivial adjacency
eigenvalues are `1` and `-2`, both within the Ramanujan window `|λ| ≤ 2√2`, so
every root of the corresponding local factor lies on the critical circle
`|u| = 1/√2`.  Here we record the extremal eigenvalue `λ = -2`. -/
example : ∀ u : ℂ, iharaFactor 2 (-2) u = 0 → ‖u‖ = 1 / Real.sqrt 2 := by
  rw [ihara_RH_iff_ramanujan 2 (-2) (by norm_num)]
  have h : (1 : ℝ) ≤ Real.sqrt 2 := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt (by norm_num)
  rw [abs_of_nonpos (by norm_num)]; linarith

/-- **Complete graph `K₅`** (`4`-regular, `q = 3`).  Its non-trivial adjacency
eigenvalue is `-1` (with multiplicity `4`), comfortably inside `|λ| ≤ 2√3`, so
the Riemann Hypothesis holds for the associated local factor: every root lies on
`|u| = 1/√3`.  More generally every complete graph is a Ramanujan graph. -/
example : ∀ u : ℂ, iharaFactor 3 (-1) u = 0 → ‖u‖ = 1 / Real.sqrt 3 := by
  rw [ihara_RH_iff_ramanujan 3 (-1) (by norm_num)]
  have h : (1 : ℝ) ≤ Real.sqrt 3 := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt (by norm_num)
  rw [abs_of_nonpos (by norm_num)]; linarith

/-- **Boundary / limit case.**  For the cycle graph `Cₙ` (`2`-regular, `q = 1`)
the Ramanujan window is `|λ| ≤ 2`, saturated by the Perron eigenvalue `λ = 2`.
The local factor degenerates to `(u - 1)²`, whose unique root `u = 1` still lies
on the (unit) circle `|u| = 1/√1 = 1`, so the equivalence holds at the boundary. -/
example : ∀ u : ℂ, iharaFactor 1 2 u = 0 → ‖u‖ = 1 / Real.sqrt 1 := by
  rw [ihara_RH_iff_ramanujan 1 2 (by norm_num)]
  simp

#check @ihara_RH_iff_ramanujan
#check @root_norm_of_ramanujan
#check @ramanujan_of_root_norm
#check @trivial_eigenvalue_breaks_RH

end IharaZeta