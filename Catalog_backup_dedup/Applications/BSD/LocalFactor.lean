/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# BSD Research Cycle — The Local L-Factor and Frobenius Eigenvalues

The Birch and Swinnerton-Dyer L-function of an elliptic curve `E / ℚ` is an Euler
product `L(E, s) = ∏_p L_p(p^{-s})⁻¹`, whose local factor at a prime `p` of good
reduction is the degree-two polynomial

  `L_p(T) = 1 - a_p T + p T²`,

where `a_p = p + 1 - #E(𝔽_p)` is the trace of Frobenius.  The *reciprocal* roots
`α, β` of `L_p` (equivalently, the roots of the characteristic polynomial of
Frobenius `X² - a_p X + p`) are the **Frobenius eigenvalues**.

The single most important analytic input to BSD is the **Riemann Hypothesis for
elliptic curves over finite fields** (Hasse's theorem): the Frobenius eigenvalues
lie on the circle of radius `√p`, equivalently `|a_p| ≤ 2√p`.  This file gives a
self-contained algebraic formalization of that equivalence together with the
functional equation of the local factor and the point-count expansion that drives
the Euler product.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the "circle of radius √p" condition on a Frobenius
  eigenvalue `z` (a root of `X² - a X + p`) is *equivalent* to the Hasse bound
  `a² ≤ 4p`, and this is a purely algebraic fact independent of the geometry.
Experiment (Experimenter): formalize `z` as an arbitrary complex root and compute
  `normSq z`.  Numerical probes: `(a,p) = (2,2)` gives roots `1 ± i`, `normSq = 2 = p`,
  and `a² = 4 ≤ 8`; `(a,p) = (3,2)` gives real roots `1, 2`, `normSq ∈ {1,4} ≠ 2`,
  and `a² = 9 > 8`.  Both match the conjectured iff.
Analysis (Analyst): the forward direction splits on the sign of the discriminant.
  Non-real roots are Galois-conjugate so `normSq z = z · conj z = αβ = p` by Vieta;
  real roots force `normSq z = z²`, which equals `p` only at the double root, i.e.
  exactly when `a² = 4p`.
Critique (Critic): guard against the degenerate `p = 0`.  We require `0 < p`
  (every prime is positive), so the eigenvalues never collapse to `0`.
Synthesis (PI): the equivalence, the Hasse bound `|a_p| ≤ 2√p`, the local
  functional equation `L_p(T) = p T² L_p(1/(pT))`, and the Frobenius point-count
  identity together package the local theory underlying the BSD Euler product.
-/
import Mathlib

namespace BSD.LocalFactor

open Complex

/-- The local L-factor of an elliptic curve at a prime `p` of good reduction,
`L_p(T) = 1 - a_p T + p T²`, as a polynomial function of `T`. -/
noncomputable def localFactor (a p T : ℂ) : ℂ := 1 - a * T + p * T ^ 2

/-- The characteristic polynomial of Frobenius `X² - a_p X + p`, whose roots are the
Frobenius eigenvalues (the reciprocals of the roots of `localFactor`). -/
noncomputable def frobeniusPoly (a p X : ℂ) : ℂ := X ^ 2 - a * X + p

/-
**Riemann Hypothesis for elliptic curves over finite fields (Hasse).**
A Frobenius eigenvalue `z` — any root of `X² - a X + p` with `a, p` real and
`0 < p` — has squared absolute value exactly `p` (i.e. lies on the circle of
radius `√p`) **iff** the Hasse bound `a² ≤ 4 p` holds.
-/
theorem frobenius_normSq_eq_iff (a p : ℝ) (hp : 0 < p) (z : ℂ)
    (hz : frobeniusPoly (a : ℂ) (p : ℂ) z = 0) :
    Complex.normSq z = p ↔ a ^ 2 ≤ 4 * p := by
  constructor <;> intro h <;> simp_all +decide [ Complex.ext_iff, frobeniusPoly ];
  · norm_num [ sq, Complex.normSq_apply ] at *;
    cases le_or_gt a 0 <;> nlinarith [ sq_nonneg ( z.re - a / 2 ) ];
  · by_cases h_im : z.im = 0 <;> simp_all +decide [ sq, Complex.normSq_apply ];
    · nlinarith [ sq_nonneg ( a - 2 * z.re ) ];
    · cases lt_or_gt_of_ne h_im <;> cases le_or_gt 0 z.re <;> nlinarith [ mul_self_pos.mpr h_im ]

/-
The two Frobenius eigenvalues multiply to `p` (Vieta): `α β = p`.
-/
theorem frobenius_root_prod (a p z w : ℂ) (hz : frobeniusPoly a p z = 0)
    (hw : frobeniusPoly a p w = 0) (hzw : z ≠ w) : z * w = p := by
  unfold frobeniusPoly at *;
  grind

/-
The two Frobenius eigenvalues sum to `a_p` (Vieta): `α + β = a`.
-/
theorem frobenius_root_sum (a p z w : ℂ) (hz : frobeniusPoly a p z = 0)
    (hw : frobeniusPoly a p w = 0) (hzw : z ≠ w) : z + w = a := by
  exact mul_left_cancel₀ ( sub_ne_zero_of_ne hzw ) ( by unfold frobeniusPoly at *; linear_combination hz - hw )

/-- **Hasse bound on the trace of Frobenius.**  The bound `a² ≤ 4p` is exactly the
statement `|a_p| ≤ 2 √p`, which controls `#E(𝔽_p) = p + 1 - a_p`. -/
theorem hasse_bound (a p : ℝ) (hp : 0 ≤ p) (h : a ^ 2 ≤ 4 * p) :
    |a| ≤ 2 * Real.sqrt p := by
  have h2 : (2 * Real.sqrt p) ^ 2 = 4 * p := by
    rw [mul_pow, Real.sq_sqrt hp]; ring
  have hle : a ^ 2 ≤ (2 * Real.sqrt p) ^ 2 := by rw [h2]; exact h
  have hnn : 0 ≤ 2 * Real.sqrt p := by positivity
  exact abs_le_of_sq_le_sq hle hnn

/-- **Local functional equation** of the BSD L-factor:
`L_p(T) = p T² · L_p(1/(pT))`.  This is the local incarnation of the functional
equation `s ↔ 2 - s` satisfied by the completed L-function. -/
theorem localFactor_functional_equation (a p T : ℂ) (hT : T ≠ 0) (hp : p ≠ 0) :
    localFactor a p T = p * T ^ 2 * localFactor a p (1 / (p * T)) := by
  unfold localFactor
  field_simp
  ring

/-- The number of `𝔽_{p^n}`-points expressed through the Frobenius eigenvalues:
`N_n = p^n + 1 - (αⁿ + βⁿ)`.  This is the Lefschetz/Weil point-count formula whose
generating series is the local zeta function. -/
noncomputable def pointCount (p alpha beta : ℂ) (n : ℕ) : ℂ :=
  p ^ n + 1 - (alpha ^ n + beta ^ n)

/-- At `n = 0` there is the single point at infinity contributing the normalization
`N_0` consistent with the eigenvalue formula. -/
theorem pointCount_zero (p alpha beta : ℂ) : pointCount p alpha beta 0 = 0 := by
  simp [pointCount]

/-- For `n = 1` the point count is `p + 1 - a_p`, where `a_p = α + β` is the trace
of Frobenius — the defining relation `a_p = p + 1 - #E(𝔽_p)`. -/
theorem pointCount_one (a p alpha beta : ℂ) (hsum : alpha + beta = a) :
    pointCount p alpha beta 1 = p + 1 - a := by
  simp [pointCount, hsum]

/-- **Hasse's theorem for the point count.**  If the eigenvalues satisfy the RH
bound, then `#E(𝔽_p)` deviates from `p + 1` by at most `2 √p`:
`|N_1 - (p + 1)| ≤ 2 √p`. -/
theorem pointCount_one_hasse (a p : ℝ) (hp : 0 ≤ p) (h : a ^ 2 ≤ 4 * p)
    (alpha beta : ℂ) (hsum : alpha + beta = (a : ℂ)) :
    ‖pointCount (p : ℂ) alpha beta 1 - ((p : ℂ) + 1)‖ ≤ 2 * Real.sqrt p := by
  have hrw : pointCount (p : ℂ) alpha beta 1 - ((p : ℂ) + 1) = -(a : ℂ) := by
    rw [pointCount_one a p alpha beta hsum]; ring
  rw [hrw, norm_neg, Complex.norm_real, Real.norm_eq_abs]
  exact hasse_bound a p hp h

end BSD.LocalFactor