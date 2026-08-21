import Novelty.BerggrenTreeSilverGrowth

/-!
# A provable critical line: the silver Ihara zeta of the Berggren tree

The Berggren tree is a regular ternary tree whose extremal (Pell) branch grows at the rate
`ε² = 3 + 2√2`, where `ε = 1 + √2` is the fundamental unit of `ℤ[√2]` and the eigenvalue of
the hyperbolic Berggren generator (`Novelty.BerggrenTreeSilverGrowth`).  Weighting each of
the `3^k` nodes at depth `k` by the *silver length* `ε^{2k}` instead of by its actual
hypotenuse gives the **silver Ihara-type zeta function** of the tree,

`Z_ε(s) = ∑_{k ≥ 0} 3^k ε^{-2ks} = (1 - 3 ε^{-2s})⁻¹`.

Unlike the true tree zeta (whose abscissa is `1`, see `Novelty.BerggrenTreeZetaAbscissa`),
this object is *exactly solvable*: it is a rational function of `ε^{-2s}`, hence
meromorphic on all of `ℂ`, and its poles can be computed in closed form.  The result is a
rigorous analogue of the Riemann Hypothesis for the Berggren tree:

> **All poles of `Z_ε` lie on the single vertical line `Re s = σ₀`, where
> `σ₀ = log 3 / (2 log(1+√2))`, and on that line they form the arithmetic progression
> `s = σ₀ + i k π / log(1+√2)`, `k ∈ ℤ`.**

The "critical line" is therefore determined by exactly two pieces of tree geometry: the
branching number `3` and the silver growth exponent `2 log ε`; the spacing of the poles is
the reciprocal silver length `π / log ε`, the analogue of the Ihara/Selberg spectral gap.

## Main results

* `silverZeta_eq_tsum` — the Dirichlet series `∑ 3^k ε^{-2ks}` converges exactly on the
  half-plane `Re s > σ₀` and sums to `Z_ε`;
* `silver_denom_eq_zero_iff` — **the critical line theorem**: the pole set of `Z_ε` is
  `{s : Re s = σ₀, Im s ∈ (π / log ε) ℤ}`;
* `silverZeta_analyticAt` and `silverZeta_meromorphicOn` — meromorphic continuation to `ℂ`;
* `silverAbscissa_lt_one` — the silver critical abscissa is strictly smaller than the true
  abscissa `1` of the tree zeta function: the silver model *underestimates* the density of
  small hypotenuses, which is the precise reason the moonshot conjecture fails.
-/

namespace BerggrenZeta

open Real Complex

/-- The silver ratio `ε = 1 + √2`, the fundamental unit of `ℤ[√2]`; its square
`ε² = 3 + 2√2` is the eigenvalue of the hyperbolic Berggren generator. -/
noncomputable def silverUnit : ℝ := 1 + Real.sqrt 2

/-- The silver critical abscissa `σ₀ = log 3 / (2 log ε)`: branching entropy divided by the
silver growth exponent. -/
noncomputable def silverAbscissa : ℝ := Real.log 3 / (2 * Real.log silverUnit)

/-- The silver Ihara-type zeta function of the Berggren tree. -/
noncomputable def silverZeta (s : ℂ) : ℂ := (1 - 3 * (silverUnit : ℂ) ^ (-2 * s))⁻¹

theorem one_lt_silverUnit : (1 : ℝ) < silverUnit := by
  have := one_le_sqrt_two
  simp only [silverUnit]
  linarith

theorem silverUnit_pos : (0 : ℝ) < silverUnit := by linarith [one_lt_silverUnit]

theorem log_silverUnit_pos : 0 < Real.log silverUnit := Real.log_pos one_lt_silverUnit

/-- `ε² = 3 + 2√2`: the silver unit squares to the Berggren eigenvalue. -/
theorem silverUnit_sq : silverUnit ^ 2 = 3 + 2 * Real.sqrt 2 := by
  have := sqrt_two_sq
  simp only [silverUnit]
  nlinarith

/-! ## Part A. The half-plane of convergence -/

theorem norm_silver_ratio (s : ℂ) :
    ‖3 * (silverUnit : ℂ) ^ (-2 * s)‖ = 3 * Real.exp (Real.log silverUnit * (-2 * s.re)) := by
  rw [norm_mul, norm_cpow_eq_rpow_re_of_pos silverUnit_pos,
    Real.rpow_def_of_pos silverUnit_pos]
  norm_num

/-- The geometric ratio of the silver zeta has modulus `< 1` exactly on the half-plane
`Re s > σ₀`. -/
theorem norm_silver_ratio_lt_one_iff (s : ℂ) :
    ‖3 * (silverUnit : ℂ) ^ (-2 * s)‖ < 1 ↔ silverAbscissa < s.re := by
  rw [norm_silver_ratio]
  have hL : 0 < Real.log silverUnit := log_silverUnit_pos
  have hthree : Real.exp (-Real.log 3) = 1 / 3 := by
    rw [Real.exp_neg, Real.exp_log (by norm_num : (0:ℝ) < 3)]
    norm_num
  constructor
  · intro h
    have h1 : Real.exp (Real.log silverUnit * (-2 * s.re)) < Real.exp (-Real.log 3) := by
      rw [hthree]
      linarith
    have h2 := Real.exp_lt_exp.mp h1
    rw [silverAbscissa, div_lt_iff₀ (by positivity)]
    linarith
  · intro h
    rw [silverAbscissa, div_lt_iff₀ (by positivity)] at h
    have h2 : Real.log silverUnit * (-2 * s.re) < -Real.log 3 := by linarith
    have h3 := Real.exp_lt_exp.mpr h2
    rw [hthree] at h3
    linarith

/-- **The silver Ihara zeta as a Dirichlet series.**  On the half-plane `Re s > σ₀` the
series `∑_k 3^k ε^{-2ks}` — one term for each of the `3^k` nodes at depth `k`, weighted by
the silver length `ε^{2k}` — converges to `Z_ε(s)`. -/
theorem silverZeta_eq_tsum {s : ℂ} (hs : silverAbscissa < s.re) :
    ∑' k : ℕ, (3 : ℂ) ^ k * (silverUnit : ℂ) ^ (-2 * s * k) = silverZeta s := by
  have hnorm : ‖3 * (silverUnit : ℂ) ^ (-2 * s)‖ < 1 :=
    (norm_silver_ratio_lt_one_iff s).mpr hs
  have hterm : ∀ k : ℕ, (3 : ℂ) ^ k * (silverUnit : ℂ) ^ (-2 * s * k)
      = (3 * (silverUnit : ℂ) ^ (-2 * s)) ^ k := by
    intro k
    rw [mul_pow, Complex.cpow_mul_nat]
  simp_rw [hterm]
  rw [tsum_geometric_of_norm_lt_one hnorm, silverZeta]

/-! ## Part B. The critical line -/

theorem silver_cpow_eq_exp (w : ℂ) :
    (silverUnit : ℂ) ^ w = Complex.exp (w * Real.log silverUnit) := by
  rw [Complex.cpow_def_of_ne_zero (by exact_mod_cast silverUnit_pos.ne'),
    ← Complex.ofReal_log silverUnit_pos.le, mul_comm]

/-- **The critical line theorem.**  The poles of the silver Ihara zeta of the Berggren tree
are exactly the points whose real part is the silver abscissa
`σ₀ = log 3 / (2 log(1+√2))` and whose imaginary part is an integer multiple of
`π / log(1+√2)`.  In particular *every* pole lies on the single vertical line `Re s = σ₀`:
an exactly solvable analogue of the Riemann Hypothesis for the Berggren tree. -/
theorem silver_denom_eq_zero_iff (s : ℂ) :
    1 - 3 * (silverUnit : ℂ) ^ (-2 * s) = 0 ↔
      s.re = silverAbscissa ∧ ∃ k : ℤ, s.im = k * Real.pi / Real.log silverUnit := by
  have hL : 0 < Real.log silverUnit := log_silverUnit_pos
  have hLC : (Real.log silverUnit : ℂ) ≠ 0 := by exact_mod_cast hL.ne'
  have h3 : Complex.exp (-(Real.log 3 : ℂ)) = 1 / 3 := by
    rw [← Complex.ofReal_neg, ← Complex.ofReal_exp, Real.exp_neg,
      Real.exp_log (by norm_num : (0:ℝ) < 3)]
    norm_num
  have hiff : (1 - 3 * (silverUnit : ℂ) ^ (-2 * s) = 0) ↔
      Complex.exp (-2 * s * (Real.log silverUnit : ℂ))
        = Complex.exp (-(Real.log 3 : ℂ)) := by
    rw [silver_cpow_eq_exp, h3]
    constructor
    · intro h
      linear_combination (-1 / 3 : ℂ) * h
    · intro h
      linear_combination (-3 : ℂ) * h
  rw [hiff, Complex.exp_eq_exp_iff_exists_int]
  constructor
  · rintro ⟨n, hn⟩
    have hs_eq : s = ((Real.log 3 / (2 * Real.log silverUnit) : ℝ) : ℂ)
        + ((-(n : ℝ) * Real.pi / Real.log silverUnit : ℝ) : ℂ) * I := by
      push_cast
      field_simp
      linear_combination -hn
    refine ⟨?_, ⟨-n, ?_⟩⟩
    · rw [hs_eq, silverAbscissa]
      simp only [Complex.add_re, Complex.ofReal_re, Complex.mul_re, Complex.ofReal_im,
        Complex.I_re, Complex.I_im, mul_zero, zero_mul, sub_zero, add_zero]
    · rw [hs_eq]
      simp only [Complex.add_im, Complex.ofReal_im, Complex.mul_im, Complex.ofReal_re,
        Complex.I_re, Complex.I_im, mul_zero, mul_one, zero_add, add_zero]
      push_cast
      ring
  · rintro ⟨hre, k, him⟩
    refine ⟨-k, ?_⟩
    have hs : s = (s.re : ℂ) + (s.im : ℂ) * I := (Complex.re_add_im s).symm
    rw [hs, hre, him, silverAbscissa]
    push_cast
    field_simp
    ring

/-- Every pole of the silver zeta lies on the critical line `Re s = σ₀`. -/
theorem silver_pole_re_eq {s : ℂ} (h : 1 - 3 * (silverUnit : ℂ) ^ (-2 * s) = 0) :
    s.re = silverAbscissa := ((silver_denom_eq_zero_iff s).mp h).1

/-- The poles are equally spaced along the critical line, with gap `π / log(1+√2)`
(the reciprocal of the silver length): if `s` is a pole, so is `s + i π / log ε`. -/
theorem silver_pole_shift {s : ℂ} (h : 1 - 3 * (silverUnit : ℂ) ^ (-2 * s) = 0) :
    1 - 3 * (silverUnit : ℂ) ^
      (-2 * (s + Complex.I * ((Real.pi / Real.log silverUnit : ℝ) : ℂ))) = 0 := by
  obtain ⟨hre, k, him⟩ := (silver_denom_eq_zero_iff s).mp h
  have hL : 0 < Real.log silverUnit := log_silverUnit_pos
  refine (silver_denom_eq_zero_iff _).mpr ⟨?_, ⟨k + 1, ?_⟩⟩
  · simpa using hre
  · simp only [Complex.add_im, Complex.mul_im, Complex.I_re, Complex.I_im, Complex.ofReal_re,
      Complex.ofReal_im, one_mul, zero_add, mul_zero]
    rw [him]
    push_cast
    field_simp

/-! ## Part C. Meromorphic continuation -/

theorem silver_denom_analytic (s : ℂ) :
    AnalyticAt ℂ (fun z : ℂ => 1 - 3 * (silverUnit : ℂ) ^ (-2 * z)) s := by
  have h2 : (fun z : ℂ => 1 - 3 * (silverUnit : ℂ) ^ (-2 * z))
      = fun z : ℂ => 1 - 3 * Complex.exp ((-2 * z) * (Real.log silverUnit : ℂ)) := by
    funext z
    rw [silver_cpow_eq_exp]
  rw [h2]
  apply Differentiable.analyticAt
  fun_prop

/-- **Meromorphic continuation.**  Away from its poles the silver Ihara zeta is analytic;
together with `silver_denom_eq_zero_iff` this exhibits `Z_ε` as a meromorphic function on
all of `ℂ` whose polar divisor is supported on the critical line. -/
theorem silverZeta_analyticAt {s : ℂ} (hs : 1 - 3 * (silverUnit : ℂ) ^ (-2 * s) ≠ 0) :
    AnalyticAt ℂ silverZeta s :=
  (silver_denom_analytic s).inv hs

theorem silverZeta_meromorphicOn : MeromorphicOn silverZeta Set.univ := by
  intro s _
  exact ((silver_denom_analytic s).meromorphicAt).inv

/-! ## Part D. The silver abscissa is strictly below the true abscissa -/

/-- `σ₀ = log 3 / (2 log(1+√2)) < 1`: the silver model of the tree predicts an abscissa of
convergence strictly smaller than the true one (`= 1`).  Equivalently `3 < ε² = 3 + 2√2`:
the branching number of the tree is smaller than its silver growth rate, so a purely
exponential model of the tree's hypotenuses misses the polynomial branches which actually
dominate the counting function. -/
theorem silverAbscissa_lt_one : silverAbscissa < 1 := by
  have hL : 0 < Real.log silverUnit := log_silverUnit_pos
  have hs2 : (1 : ℝ) < Real.sqrt 2 := by
    have h := sqrt_two_sq
    nlinarith [Real.sqrt_nonneg 2]
  have hlt : Real.log 3 < 2 * Real.log silverUnit := by
    have hpow : Real.log (silverUnit ^ 2) = 2 * Real.log silverUnit := by
      rw [Real.log_pow]
      norm_num
    rw [← hpow, silverUnit_sq]
    exact Real.log_lt_log (by norm_num) (by linarith)
  rw [silverAbscissa, div_lt_one (by positivity)]
  exact hlt

/-- The two-sided placement of the silver critical line: `0 < σ₀ < 1`. -/
theorem silverAbscissa_pos : 0 < silverAbscissa := by
  have hL : 0 < Real.log silverUnit := log_silverUnit_pos
  rw [silverAbscissa]
  apply div_pos (Real.log_pos (by norm_num))
  positivity

end BerggrenZeta