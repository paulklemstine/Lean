/-
# The systolic functional is a proper exhaustion of the moduli space

`Geometry.Teichmuller.SystoleFunctional` proves one half of the comparison between the systolic
functional `sys` and the distance to the hexagonal point `ρ` in the moduli space of tori:

    log (sys ρ / sys τ)  ≤  2 · moduliDist ρ τ     (`log_sys_div_le_moduliDist`),

i.e. `(1/2) · log (1 / sys τ) ≤ moduliDist ρ τ`.  This file proves the **reverse comparison**,
with an explicit additive constant, and deduces that `−log sys` is a proper exhaustion function
of the moduli space.  Main results:

* `Teichmuller.sys_eq_one_div_im_of_fd` : on the *whole* standard fundamental domain the
  shortest lattice vector is the horizontal one, so `sys w = 1 / Im w` there.  (This strictly
  extends `sys_eq_one_div_im`, which needs `Im w ≥ 1`.)
* `Teichmuller.dist_rho_le_log_of_fd` : the hyperbolic distance from `ρ` to a point `w` of the
  fundamental domain satisfies `dist ρ w ≤ log (5 · Im w)`.
* `Teichmuller.moduliDist_rho_le_log_sys` : `moduliDist ρ τ ≤ (1/2) · log (5 / sys τ)` for
  **every** marked torus `τ`.
* `Teichmuller.log_sys_le_moduliDist_rho` : the matching lower bound
  `(1/2) · log (1 / sys τ) ≤ moduliDist ρ τ`.
* `Teichmuller.abs_moduliDist_rho_sub_half_log_le` : consequently
  `|moduliDist ρ τ − (1/2) · log (1 / sys τ)| ≤ (1/2) · log 5` — the distance to the orbifold
  point `ρ` and the logarithmic systole agree up to a universal additive constant.
* `Teichmuller.sys_ge_of_moduliDist_le`, `Teichmuller.moduliDist_le_of_sys_ge`,
  `Teichmuller.sys_proper_exhaustion` : the sublevel sets of `moduliDist ρ ·` and the
  superlevel sets of `sys` are cofinal in each other, which is exactly properness of the
  exhaustion; `Teichmuller.moduliDist_rho_tendsto_atTop_of_sys` records the resulting
  divergence at the cusp.

-- !-- Lab Notes -- !--
Hypothesizer (D4): `−log sys` should be comparable to the distance to the thick part with
universal multiplicative constant `1` and only an additive error.
Experimenter: the fundamental domain makes both sides computable at once.  For `w = x + i y`
with `|x| ≤ 1/2` and `|w| ≥ 1`, the lattice value at `(m, n)` is
`m² + 2 m n x + n² |w|² ≥ m² − |m n| + n²`, an integer which is positive, hence `≥ 1`; so
`sys w = 1 / y` on all of `𝒟`, not just in the cusp.  On the other side
`cosh dist(ρ, w) = 1 + ((x + 1/2)² + (y − √3/2)²) / (√3 y) ≤ (5/2) y` for `y ≥ √3/2`, and
`exp d ≤ 2 cosh d` converts this into `dist(ρ, w) ≤ log (5 y)`.
Analyst: the two estimates have the *same* leading term `log y = log (1 / sys)`, so the gap
between the upper and the lower bound is the constant `log 5 / 2 ≈ 0.805` — independent of `τ`.
The multiplicative constant in D4 is therefore `1`, not merely `O(1)`.
Critic: the upper bound must hold for *all* `τ`, including the thick part where `sys τ > 1`;
this is why the fundamental-domain systole identity is proved for the whole of `𝒟` (where
`Im w ≥ √3/2`) rather than only for `Im w ≥ 1`, and why the constant is `5` rather than `4`
(at `y = √3/2` one needs `2 cosh d ≤ 5 y`, and `4` is too small).
-/
import Mathlib
import Geometry.Teichmuller.SystoleFunctional

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

/-! ### The systole on the standard fundamental domain -/

/-- **On the standard fundamental domain the systole is exactly `1 / Im w`.**  If
`|Re w| ≤ 1/2` and `|w| ≥ 1` then the shortest nonzero lattice vector of the marked torus `w`
is the horizontal vector `1`.  This extends `Teichmuller.sys_eq_one_div_im`, which assumes the
stronger condition `Im w ≥ 1`. -/
theorem sys_eq_one_div_im_of_fd (w : ℍ) (hre : |w.re| ≤ 1 / 2)
    (hns : 1 ≤ Complex.normSq (w : ℂ)) : sys w = 1 / w.im := by
  refine le_antisymm (sys_le_one_div_im w) ?_
  obtain ⟨m, n, hmn, hr⟩ := exists_sys_eq w
  rw [hr, latticeValue, le_div_iff₀ w.im_pos, div_mul_eq_mul_div, one_mul,
    div_self (ne_of_gt w.im_pos)]
  have hnsw : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
    rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
  have hexp : Complex.normSq ((m : ℂ) + (n : ℂ) * (w : ℂ))
      = (m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ) * w.re
        + (n : ℝ) ^ 2 * (w.re ^ 2 + w.im ^ 2) := by
    simp [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]
    ring
  rw [hexp]
  -- the integral lower bound `m² − |m n| + n² ≥ 1`
  have hhex : (1 : ℤ) ≤ |m| ^ 2 - |m| * |n| + |n| ^ 2 := by
    refine one_le_hexagonal_form |m| |n| ?_
    rcases hmn with h | h
    · exact Or.inl (by simpa using h)
    · exact Or.inr (by simpa using h)
  have hhexR : (1 : ℝ) ≤ (m : ℝ) ^ 2 - |(m : ℝ)| * |(n : ℝ)| + (n : ℝ) ^ 2 := by
    have := (Int.cast_le (R := ℝ)).mpr hhex
    push_cast at this
    rwa [sq_abs, sq_abs] at this
  -- the cross term is controlled by `|Re w| ≤ 1/2`
  have hcross : -(|(m : ℝ)| * |(n : ℝ)|) ≤ 2 * (m : ℝ) * (n : ℝ) * w.re := by
    have habs : |2 * (m : ℝ) * (n : ℝ) * w.re| ≤ |(m : ℝ)| * |(n : ℝ)| := by
      have h1 : |2 * (m : ℝ) * (n : ℝ) * w.re|
          = 2 * (|(m : ℝ)| * |(n : ℝ)|) * |w.re| := by
        rw [abs_mul, abs_mul, abs_mul, abs_two]
        ring
      have h2 : 2 * (|(m : ℝ)| * |(n : ℝ)|) * |w.re|
          ≤ 2 * (|(m : ℝ)| * |(n : ℝ)|) * (1 / 2) :=
        mul_le_mul_of_nonneg_left hre (by positivity)
      rw [h1]
      linarith
    linarith [neg_abs_le (2 * (m : ℝ) * (n : ℝ) * w.re)]
  -- and the `|w| ≥ 1` term
  have hlen : (n : ℝ) ^ 2 ≤ (n : ℝ) ^ 2 * (w.re ^ 2 + w.im ^ 2) := by
    have h1 : (1 : ℝ) ≤ w.re ^ 2 + w.im ^ 2 := by rw [← hnsw]; exact hns
    nlinarith [sq_nonneg ((n : ℝ))]
  linarith

/-! ### Distance to the hexagonal point inside the fundamental domain -/

theorem rho_re : rho.re = -1 / 2 := rfl

theorem rho_im : rho.im = Real.sqrt 3 / 2 := rfl

/-- Points of the standard fundamental domain have imaginary part at least `√3 / 2`. -/
theorem sqrt_three_div_two_le_im_of_fd (w : ℍ) (hre : |w.re| ≤ 1 / 2)
    (hns : 1 ≤ Complex.normSq (w : ℂ)) : Real.sqrt 3 / 2 ≤ w.im := by
  have hnsw : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
    rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
  rw [hnsw] at hns
  have hsq : w.re ^ 2 ≤ 1 / 4 := by nlinarith [abs_nonneg w.re, sq_abs w.re]
  nlinarith [w.im_pos, Real.sq_sqrt (show (0:ℝ) ≤ 3 by norm_num), Real.sqrt_nonneg 3]

/-- `exp t ≤ 2 cosh t`: the elementary inequality turning a bound on `cosh` of a distance into a
bound on the distance itself. -/
theorem exp_le_two_cosh (t : ℝ) : Real.exp t ≤ 2 * Real.cosh t := by
  have h := Real.cosh_add_sinh t
  have h2 : Real.sinh t ≤ Real.cosh t := by
    rw [Real.sinh_eq, Real.cosh_eq]
    have := Real.exp_pos (-t)
    linarith
  linarith

/-- **The fundamental domain is logarithmically close to the hexagonal point.**  For every point
`w` of the standard fundamental domain, `dist ρ w ≤ log (5 · Im w)`. -/
theorem dist_rho_le_log_of_fd (w : ℍ) (hre : |w.re| ≤ 1 / 2)
    (hns : 1 ≤ Complex.normSq (w : ℂ)) : dist rho w ≤ Real.log (5 * w.im) := by
  have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs3pos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have hs3lt : Real.sqrt 3 < 2 := by nlinarith
  have him : Real.sqrt 3 / 2 ≤ w.im := sqrt_three_div_two_le_im_of_fd w hre hns
  have hy : 0 < w.im := w.im_pos
  have hnsw : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
    rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
  rw [hnsw] at hns
  -- the hyperbolic cosine of the distance
  have hcosh : Real.cosh (dist rho w)
      = 1 + Complex.normSq ((rho : ℂ) - (w : ℂ)) / (2 * rho.im * w.im) := by
    rw [UpperHalfPlane.cosh_dist, Complex.dist_eq, Complex.sq_norm]
  have hnum : Complex.normSq ((rho : ℂ) - (w : ℂ))
      = (-1 / 2 - w.re) ^ 2 + (Real.sqrt 3 / 2 - w.im) ^ 2 := by
    rw [Complex.normSq_apply]
    simp [rho, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im, Complex.sub_re, Complex.sub_im]
    ring
  have hden : 2 * rho.im * w.im = Real.sqrt 3 * w.im := by
    rw [rho_im]; ring
  -- the key numerical estimate `2 cosh d ≤ 5 y`
  have hkey : 2 * Real.cosh (dist rho w) ≤ 5 * w.im := by
    rw [hcosh, hden, hnum]
    have hd : (0:ℝ) < Real.sqrt 3 * w.im := by positivity
    have hxle : w.re ≤ 1 / 2 := le_trans (le_abs_self _) hre
    have hxge : -(1 / 2 : ℝ) ≤ w.re := neg_le_of_abs_le hre
    have hs3gt : (1.7 : ℝ) < Real.sqrt 3 := by nlinarith
    have hy2 : 3 / 4 ≤ w.im ^ 2 := by nlinarith
    have hx1 : (w.re + 1 / 2) ^ 2 ≤ 1 := by nlinarith
    have key : ((-1 / 2 - w.re) ^ 2 + (Real.sqrt 3 / 2 - w.im) ^ 2) / (Real.sqrt 3 * w.im)
        ≤ (5 * w.im - 2) / 2 := by
      rw [div_le_div_iff₀ hd (by norm_num : (0:ℝ) < 2)]
      nlinarith [hs3, hs3gt, hy2, hx1, hy]
    linarith
  have hpos : (0:ℝ) < 5 * w.im := by positivity
  rw [Real.le_log_iff_exp_le hpos]
  exact le_trans (exp_le_two_cosh _) hkey

/-! ### The two-sided comparison -/

/-- **Upper bound (the reverse systolic comparison).**  Every marked torus lies within
`(1/2) · log (5 / sys τ)` of the hexagonal point in the moduli space. -/
theorem moduliDist_rho_le_log_sys (tau : ℍ) :
    moduliDist rho tau ≤ 1 / 2 * Real.log (5 / sys tau) := by
  obtain ⟨g, hg⟩ := ModularGroup.exists_smul_mem_fd tau
  simp only [ModularGroup.fd, Set.mem_setOf_eq] at hg
  set w := g • tau with hw
  have hns : 1 ≤ Complex.normSq (w : ℂ) := hg.1
  have hre : |w.re| ≤ 1 / 2 := by simpa using hg.2
  have hsysw : sys w = 1 / w.im := sys_eq_one_div_im_of_fd w hre hns
  have hsys : sys tau = 1 / w.im := by rw [← hsysw, hw, sys_smul]
  have himeq : w.im = 1 / sys tau := by
    rw [hsys, one_div_one_div]
  have h1 : moduliDist rho tau = moduliDist rho w := by rw [hw, moduliDist_smul_right]
  have h2 : moduliDist rho w ≤ teichDist rho w := moduliDist_le_teichDist rho w
  have h3 : teichDist rho w = dist rho w / 2 := teichDist_eq_half_dist rho w
  have h4 : dist rho w ≤ Real.log (5 * w.im) := dist_rho_le_log_of_fd w hre hns
  have h5 : 5 * w.im = 5 / sys tau := by rw [himeq]; ring
  rw [h1]
  rw [h3] at h2
  rw [h5] at h4
  linarith

/-- **Lower bound.**  Restatement of `log_sys_div_le_moduliDist` at the hexagonal point:
`(1/2) · log (1 / sys τ) ≤ moduliDist ρ τ`. -/
theorem log_sys_le_moduliDist_rho (tau : ℍ) :
    1 / 2 * Real.log (1 / sys tau) ≤ moduliDist rho tau := by
  have hsysle : sys tau ≤ sys rho := by
    rw [sys_rho]; exact sys_le_hermite tau
  have hkey := log_sys_div_le_moduliDist rho tau hsysle
  have hmono : Real.log (1 / sys tau) ≤ Real.log (sys rho / sys tau) := by
    refine Real.log_le_log (div_pos one_pos (sys_pos tau)) ?_
    have h1 : (1:ℝ) ≤ sys rho := by
      rw [sys_rho]; exact le_of_lt one_lt_hermite
    gcongr
    exact (sys_pos tau).le
  linarith

/-- **D4, quantitative form.**  The distance to the hexagonal point of the moduli space and the
logarithmic systole differ by at most the universal constant `(1/2) · log 5`:

    | moduliDist ρ τ − (1/2) · log (1 / sys τ) | ≤ (1/2) · log 5 .

In particular the comparison holds with multiplicative constant exactly `1`. -/
theorem abs_moduliDist_rho_sub_half_log_le (tau : ℍ) :
    |moduliDist rho tau - 1 / 2 * Real.log (1 / sys tau)| ≤ 1 / 2 * Real.log 5 := by
  have hsplit : Real.log (5 / sys tau) = Real.log 5 + Real.log (1 / sys tau) := by
    rw [Real.log_div (by norm_num) (ne_of_gt (sys_pos tau)),
      Real.log_div one_ne_zero (ne_of_gt (sys_pos tau)), Real.log_one]
    ring
  have hup := moduliDist_rho_le_log_sys tau
  have hlow := log_sys_le_moduliDist_rho tau
  rw [hsplit] at hup
  rw [abs_le]
  constructor
  · have hlog5 : 0 ≤ Real.log 5 := Real.log_nonneg (by norm_num)
    linarith
  · linarith

/-! ### Properness of the exhaustion -/

/-- Points at bounded distance from `ρ` in the moduli space have systole bounded below. -/
theorem sys_ge_of_moduliDist_le {tau : ℍ} {R : ℝ} (h : moduliDist rho tau ≤ R) :
    Real.exp (-(2 * R)) ≤ sys tau := by
  have hlow := log_sys_le_moduliDist_rho tau
  have hlog : Real.log (1 / sys tau) ≤ 2 * R := by linarith
  have hpos : 0 < sys tau := sys_pos tau
  have h1 : 1 / sys tau ≤ Real.exp (2 * R) := by
    have := Real.exp_le_exp.mpr hlog
    rwa [Real.exp_log (by positivity)] at this
  have hexp : 0 < Real.exp (2 * R) := Real.exp_pos _
  rw [Real.exp_neg]
  rw [div_le_iff₀ hpos] at h1
  rw [inv_le_iff_one_le_mul₀ hexp]
  linarith [h1]

/-- Conversely, points with systole bounded below lie at bounded distance from `ρ`. -/
theorem moduliDist_le_of_sys_ge {tau : ℍ} {eps : ℝ} (heps : 0 < eps) (h : eps ≤ sys tau) :
    moduliDist rho tau ≤ 1 / 2 * Real.log (5 / eps) := by
  have hup := moduliDist_rho_le_log_sys tau
  have hmono : Real.log (5 / sys tau) ≤ Real.log (5 / eps) := by
    refine Real.log_le_log (div_pos (by norm_num) (sys_pos tau)) ?_
    gcongr
  linarith

/-- **`sys` is a proper exhaustion function of the moduli space.**  The bounded sets for
`moduliDist ρ ·` and the sets on which `sys` is bounded below are cofinal in one another. -/
theorem sys_proper_exhaustion :
    (∀ R : ℝ, ∃ eps : ℝ, 0 < eps ∧ ∀ tau : ℍ, moduliDist rho tau ≤ R → eps ≤ sys tau) ∧
    (∀ eps : ℝ, 0 < eps → ∃ R : ℝ, ∀ tau : ℍ, eps ≤ sys tau → moduliDist rho tau ≤ R) := by
  constructor
  · intro R
    exact ⟨Real.exp (-(2 * R)), Real.exp_pos _, fun tau h => sys_ge_of_moduliDist_le h⟩
  · intro eps heps
    exact ⟨1 / 2 * Real.log (5 / eps), fun tau h => moduliDist_le_of_sys_ge heps h⟩

/-- **Divergence at the cusp.**  A sequence of marked tori whose systoles tend to `0` leaves
every bounded set of the moduli space; quantitatively, `sys τ < 5 · exp (−2 M)` forces
`moduliDist ρ τ > M`. -/
theorem moduliDist_rho_tendsto_atTop_of_sys {tau : ℍ} {M : ℝ}
    (h : sys tau < Real.exp (-(2 * M))) : M < moduliDist rho tau := by
  have hpos : 0 < sys tau := sys_pos tau
  have hlow := log_sys_le_moduliDist_rho tau
  have h1 : Real.exp (2 * M) < 1 / sys tau := by
    rw [lt_div_iff₀ hpos]
    calc Real.exp (2 * M) * sys tau < Real.exp (2 * M) * Real.exp (-(2 * M)) :=
          mul_lt_mul_of_pos_left h (Real.exp_pos _)
      _ = 1 := by rw [← Real.exp_add]; simp
  have h2 : 2 * M < Real.log (1 / sys tau) := by
    have := Real.log_lt_log (Real.exp_pos (2 * M)) h1
    rwa [Real.log_exp] at this
  linarith

end Teichmuller