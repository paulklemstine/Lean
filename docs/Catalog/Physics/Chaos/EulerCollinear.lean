import Physics.Chaos.ChaosExtensions

/-!
# The Euler (collinear) three-body configuration: a complete stability trichotomy

The companion file `Physics.Chaos.ThreeBodyLagrange` analyses the *equilateral* (Lagrange)
homographic solution, whose variational quartic is `z⁴ + z² + (27/4)K` and whose stability
is governed by the sharp Routh threshold `K = 1/27`.

This file carries out the analogous — and qualitatively different — analysis for the
*collinear* (Euler) homographic solutions. Their reduced variational equation is the
biquadratic

  `x⁗ + (2 − A) ω² x'' + (1 + A − 2A²) ω⁴ x = 0`,

with characteristic polynomial `eulerChar A z = z⁴ + (2 − A) z² + (1 + A − 2A²)`
(in units of the mean motion `ω`), where `A` is the dimensionless *Euler parameter* built
from the masses and the collinear geometry.

## Main results

* `eulerChar_factorization` — exact factorisation `(z² − u₊)(z² − u₋)` whenever the
  discriminant `A(9A − 8)` is nonnegative, with the explicit roots
  `u± = ((A − 2) ± √(A(9A − 8)))/2`.
* `euler_stable_window` — for `8/9 ≤ A ≤ 1` *every* characteristic root is purely
  imaginary, so every mode has Lyapunov exponent `0`.
* `euler_unstable_above_one` — for `A > 1` there is a **real** positive characteristic
  root `σ_E(A) = √u₊ > 0`: the instability is a genuine hyperbolic (non-oscillatory)
  one, in contrast with the complex quadruplet of the equilateral case.
* `euler_unstable_below` — for `0 < A < 8/9` the discriminant is negative and the four
  roots form a complex quadruplet, again producing a root with positive real part.
* `euler_instability_iff` — putting these together: for `A > 0` the collinear
  configuration has a growing mode **iff** `A ∉ [8/9, 1]`. There is a *window* of
  stability, not a single threshold.
* `euler_unstable_mode`, `euler_maxLyapExp_pos` — the exponential curve built from the
  unstable root really solves the variational equation and its Lyapunov exponent is
  exactly `ω σ_E(A) > 0`.
* `eulerExponent_strictMonoOn`, `eulerExponent_eq_zero_of_mem_window` — monotonicity of
  the growth rate above the window and its vanishing inside it.
* `euler_entropy_le`, `euler_entropy_div_two_le_maxExp` — the Ruelle/entropy consequences,
  via the symplectic Ruelle interface of `Physics.Chaos.ChaosExtensions`.

All statements are about the linearised (variational) flow, exactly as in the equilateral
case; the parameter `A` is kept abstract, so the results apply to every collinear
homographic solution once its Euler parameter is known.
-/

noncomputable section

open Filter Topology Chaos

namespace ThreeBody

/-! ### The Euler characteristic quartic -/

/-- The characteristic polynomial of the linearised collinear (Euler) configuration, in
units of the mean motion: `z ↦ z⁴ + (2 − A) z² + (1 + A − 2A²)`. -/
def eulerChar (A : ℝ) (z : ℂ) : ℂ :=
  z ^ 4 + ((2 - A : ℝ) : ℂ) * z ^ 2 + ((1 + A - 2 * A ^ 2 : ℝ) : ℂ)

/-- The characteristic polynomial with the physical mean motion `ω` restored. -/
def eulerCharScaled (ω A : ℝ) (z : ℂ) : ℂ :=
  z ^ 4 + ((2 - A : ℝ) : ℂ) * (ω : ℂ) ^ 2 * z ^ 2
    + ((1 + A - 2 * A ^ 2 : ℝ) : ℂ) * (ω : ℂ) ^ 4

/-- Scaling law: the physical polynomial is the dimensionless one, rescaled. -/
theorem eulerCharScaled_eq (ω A : ℝ) (w : ℂ) :
    eulerCharScaled ω A ((ω : ℂ) * w) = (ω : ℂ) ^ 4 * eulerChar A w := by
  unfold eulerCharScaled eulerChar; ring

/-- The polynomial is even, so roots come in pairs `±z` (the symplectic pairing). -/
theorem eulerChar_neg (A : ℝ) (z : ℂ) : eulerChar A (-z) = eulerChar A z := by
  unfold eulerChar; ring

/-- Discriminant of the quadratic in `z²`: `A(9A − 8)`. -/
def eulerDisc (A : ℝ) : ℝ := A * (9 * A - 8)

/-- The larger root of the quadratic `u² + (2 − A)u + (1 + A − 2A²)` in `u = z²`. -/
def eulerRootPlus (A : ℝ) : ℝ := ((A - 2) + Real.sqrt (eulerDisc A)) / 2

/-- The smaller root of the quadratic `u² + (2 − A)u + (1 + A − 2A²)` in `u = z²`. -/
def eulerRootMinus (A : ℝ) : ℝ := ((A - 2) - Real.sqrt (eulerDisc A)) / 2

/-- The **Euler growth rate**: the real part of the unstable characteristic root, in units
of the mean motion, `σ_E(A) = √u₊`. -/
def eulerExponent (A : ℝ) : ℝ := Real.sqrt (eulerRootPlus A)

theorem eulerRoot_sum (A : ℝ) : eulerRootPlus A + eulerRootMinus A = A - 2 := by
  unfold eulerRootPlus eulerRootMinus; ring

theorem eulerRootMinus_le_plus {A : ℝ} : eulerRootMinus A ≤ eulerRootPlus A := by
  unfold eulerRootPlus eulerRootMinus
  have := Real.sqrt_nonneg (eulerDisc A)
  linarith

theorem eulerRoot_prod {A : ℝ} (hA : 8 / 9 ≤ A) :
    eulerRootPlus A * eulerRootMinus A = 1 + A - 2 * A ^ 2 := by
  have hd : 0 ≤ eulerDisc A := by unfold eulerDisc; nlinarith
  have hs : Real.sqrt (eulerDisc A) ^ 2 = eulerDisc A := Real.sq_sqrt hd
  unfold eulerRootPlus eulerRootMinus eulerDisc at *
  nlinarith [hs]

/-- **Exact factorisation of the Euler quartic** when the discriminant is nonnegative. -/
theorem eulerChar_factorization {A : ℝ} (hA : 8 / 9 ≤ A) (z : ℂ) :
    eulerChar A z = (z ^ 2 - ((eulerRootPlus A : ℝ) : ℂ)) *
      (z ^ 2 - ((eulerRootMinus A : ℝ) : ℂ)) := by
  have h1 : ((eulerRootPlus A : ℝ) : ℂ) + ((eulerRootMinus A : ℝ) : ℂ) = ((A - 2 : ℝ) : ℂ) := by
    rw [← Complex.ofReal_add, eulerRoot_sum]
  have h2 : ((eulerRootPlus A : ℝ) : ℂ) * ((eulerRootMinus A : ℝ) : ℂ)
      = ((1 + A - 2 * A ^ 2 : ℝ) : ℂ) := by
    rw [← Complex.ofReal_mul, eulerRoot_prod hA]
  unfold eulerChar
  push_cast at h1 h2 ⊢
  linear_combination (z ^ 2) * h1 - h2

/-! ### The stability window `8/9 ≤ A ≤ 1` -/

theorem eulerRootPlus_nonpos {A : ℝ} (h1 : 8 / 9 ≤ A) (h2 : A ≤ 1) : eulerRootPlus A ≤ 0 := by
  have hd : 0 ≤ eulerDisc A := by unfold eulerDisc; nlinarith
  have hle : Real.sqrt (eulerDisc A) ≤ 2 - A := by
    have hsq : eulerDisc A ≤ (2 - A) ^ 2 := by unfold eulerDisc; nlinarith
    have := Real.sqrt_le_sqrt hsq
    rwa [Real.sqrt_sq (by linarith)] at this
  unfold eulerRootPlus
  linarith

theorem eulerRootMinus_nonpos {A : ℝ} (h1 : 8 / 9 ≤ A) (h2 : A ≤ 1) :
    eulerRootMinus A ≤ 0 :=
  le_trans eulerRootMinus_le_plus (eulerRootPlus_nonpos h1 h2)

/-- **Inside the window every characteristic root is purely imaginary.** For
`8/9 ≤ A ≤ 1` the collinear configuration is linearly (spectrally) stable. -/
theorem euler_stable_window {A : ℝ} (h1 : 8 / 9 ≤ A) (h2 : A ≤ 1) {z : ℂ}
    (hz : eulerChar A z = 0) : z.re = 0 := by
  rw [eulerChar_factorization h1 z] at hz
  rcases mul_eq_zero.mp hz with h | h
  · exact re_eq_zero_of_sq_eq_nonpos (eulerRootPlus_nonpos h1 h2) (sub_eq_zero.mp h)
  · exact re_eq_zero_of_sq_eq_nonpos (eulerRootMinus_nonpos h1 h2) (sub_eq_zero.mp h)

/-- Inside the window every exponential mode is neutrally stable. -/
theorem euler_stable_mode_lyapExp_zero {A : ℝ} (h1 : 8 / 9 ≤ A) (h2 : A ≤ 1) {z : ℂ}
    (hz : eulerChar A z = 0) : lyapExp (fun t : ℝ => Complex.exp (z * t)) = 0 := by
  rw [lyapExp_expMode]; exact euler_stable_window h1 h2 hz

/-- Inside the window the growth rate vanishes. -/
theorem eulerExponent_eq_zero_of_mem_window {A : ℝ} (h1 : 8 / 9 ≤ A) (h2 : A ≤ 1) :
    eulerExponent A = 0 := by
  unfold eulerExponent
  exact Real.sqrt_eq_zero_of_nonpos (eulerRootPlus_nonpos h1 h2)

/-! ### Above the window: a real hyperbolic exponent -/

theorem eulerRootPlus_pos {A : ℝ} (hA : 1 < A) : 0 < eulerRootPlus A := by
  have hd : 0 ≤ eulerDisc A := by unfold eulerDisc; nlinarith
  have hgt : 2 - A < Real.sqrt (eulerDisc A) := by
    rcases le_or_gt (2 - A) 0 with h | h
    · have : 0 < Real.sqrt (eulerDisc A) := by
        apply Real.sqrt_pos.mpr
        unfold eulerDisc; nlinarith
      linarith
    · have hsq : (2 - A) ^ 2 < eulerDisc A := by unfold eulerDisc; nlinarith
      have := Real.sqrt_lt_sqrt (by positivity) hsq
      rwa [Real.sqrt_sq h.le] at this
  unfold eulerRootPlus
  linarith

/-- **Strict positivity of the Euler growth rate above the window.** -/
theorem eulerExponent_pos {A : ℝ} (hA : 1 < A) : 0 < eulerExponent A :=
  Real.sqrt_pos.mpr (eulerRootPlus_pos hA)

theorem eulerExponent_sq {A : ℝ} (hA : 1 < A) : eulerExponent A ^ 2 = eulerRootPlus A :=
  Real.sq_sqrt (eulerRootPlus_pos hA).le

/-- **The unstable Euler root is real.** For `A > 1` the positive real number `σ_E(A)` is
a root of the Euler quartic: the instability is a pure exponential (saddle) one, with no
oscillation, unlike the complex quadruplet of the equilateral configuration. -/
theorem euler_char_root {A : ℝ} (hA : 1 < A) : eulerChar A ((eulerExponent A : ℝ) : ℂ) = 0 := by
  have hd : 0 ≤ eulerDisc A := by unfold eulerDisc; nlinarith
  have hs : Real.sqrt (eulerDisc A) ^ 2 = eulerDisc A := Real.sq_sqrt hd
  have hu : eulerExponent A ^ 2 = eulerRootPlus A := eulerExponent_sq hA
  have hreal : eulerExponent A ^ 4 + (2 - A) * eulerExponent A ^ 2 + (1 + A - 2 * A ^ 2) = 0 := by
    have h4 : eulerExponent A ^ 4 = eulerRootPlus A ^ 2 := by
      rw [show (4 : ℕ) = 2 * 2 by norm_num, pow_mul, hu]
    rw [h4, hu]
    unfold eulerRootPlus eulerDisc at *
    nlinarith [hs]
  unfold eulerChar
  have : ((eulerExponent A ^ 4 + (2 - A) * eulerExponent A ^ 2 + (1 + A - 2 * A ^ 2) : ℝ) : ℂ)
      = 0 := by rw [hreal]; simp
  push_cast at this ⊢
  linear_combination this

/-- **No upper threshold.** For *every* `A > 1` the collinear configuration has a growing
mode. Unlike the equilateral case (stable for `K ≤ 1/27`), instability above the window is
unconditional. -/
theorem euler_unstable_above_one {A : ℝ} (hA : 1 < A) :
    ∃ z : ℂ, eulerChar A z = 0 ∧ 0 < z.re ∧ z.im = 0 :=
  ⟨((eulerExponent A : ℝ) : ℂ), euler_char_root hA, by simpa using eulerExponent_pos hA, by simp⟩

/-! ### Below the window: a complex quadruplet -/

/-- For `0 < A < 8/9` the quadratic in `z²` has a genuinely complex root. -/
theorem euler_complex_root_of_disc_neg {A : ℝ} (h0 : 0 < A) (hA : A < 8 / 9) :
    ∃ u : ℂ, u ^ 2 + ((2 - A : ℝ) : ℂ) * u + ((1 + A - 2 * A ^ 2 : ℝ) : ℂ) = 0 ∧ u.im ≠ 0 := by
  set c : ℝ := Real.sqrt (8 * A - 9 * A ^ 2) with hc
  have hcpos : 0 < c := Real.sqrt_pos.mpr (by nlinarith)
  have hc2 : c ^ 2 = 8 * A - 9 * A ^ 2 := Real.sq_sqrt (by nlinarith)
  refine ⟨⟨(A - 2) / 2, c / 2⟩, ?_, by simpa using ne_of_gt hcpos⟩
  simp only [Complex.ext_iff, Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im,
    Complex.zero_re, Complex.zero_im, pow_two, Complex.ofReal_re, Complex.ofReal_im]
  constructor <;> · simp; nlinarith [hc2]

/-- **Below the window the configuration is unstable too.** For `0 < A < 8/9` the four
characteristic roots form a complex quadruplet `±a ± ib` with `a ≠ 0`, so there is a root
with positive real part. -/
theorem euler_unstable_below {A : ℝ} (h0 : 0 < A) (hA : A < 8 / 9) :
    ∃ z : ℂ, eulerChar A z = 0 ∧ 0 < z.re := by
  obtain ⟨u, hu, hui⟩ := euler_complex_root_of_disc_neg h0 hA
  obtain ⟨w, hw⟩ : ∃ w : ℂ, w ^ 2 = u := by
    obtain ⟨w, hw⟩ := IsAlgClosed.exists_pow_nat_eq u (n := 2) (by norm_num)
    exact ⟨w, hw⟩
  have hroot : eulerChar A w = 0 := by
    unfold eulerChar
    have h4 : w ^ 4 = u ^ 2 := by rw [show (4 : ℕ) = 2 * 2 by norm_num, pow_mul, hw]
    rw [h4, hw]; exact hu
  have hre : w.re ≠ 0 := by
    intro h
    have : (w ^ 2).im = 2 * w.re * w.im := by
      simp [pow_two, Complex.mul_im]; ring
    rw [hw, h] at this
    simp at this
    exact hui this
  rcases lt_or_gt_of_ne hre with h | h
  · refine ⟨-w, ?_, by simpa using h⟩
    rw [eulerChar_neg]; exact hroot
  · exact ⟨w, hroot, h⟩

/-- **Complete stability trichotomy for the collinear (Euler) configuration.** For a
positive Euler parameter, a growing mode exists exactly when `A` lies outside the closed
window `[8/9, 1]`. -/
theorem euler_instability_iff {A : ℝ} (h0 : 0 < A) :
    (∃ z : ℂ, eulerChar A z = 0 ∧ 0 < z.re) ↔ ¬(8 / 9 ≤ A ∧ A ≤ 1) := by
  constructor
  · rintro ⟨z, hz, hpos⟩ ⟨h1, h2⟩
    rw [euler_stable_window h1 h2 hz] at hpos
    exact lt_irrefl 0 hpos
  · intro h
    rcases not_and_or.mp h with h | h
    · obtain ⟨z, hz, hpos⟩ := euler_unstable_below h0 (lt_of_not_ge h)
      exact ⟨z, hz, hpos⟩
    · obtain ⟨z, hz, hpos, _⟩ := euler_unstable_above_one (lt_of_not_ge h)
      exact ⟨z, hz, hpos⟩

/-! ### Monotonicity of the growth rate -/

theorem eulerRootPlus_strictMonoOn : StrictMonoOn eulerRootPlus (Set.Ici (1 : ℝ)) := by
  intro A hA B hB hAB
  have hA1 : (1 : ℝ) ≤ A := hA
  have hdA : 0 ≤ eulerDisc A := by unfold eulerDisc; nlinarith
  have hlt : eulerDisc A < eulerDisc B := by unfold eulerDisc; nlinarith
  have hs : Real.sqrt (eulerDisc A) < Real.sqrt (eulerDisc B) := Real.sqrt_lt_sqrt hdA hlt
  unfold eulerRootPlus
  linarith

/-- **The Euler growth rate increases strictly with the Euler parameter** above the
stability window. -/
theorem eulerExponent_strictMonoOn : StrictMonoOn eulerExponent (Set.Ici (1 : ℝ)) := by
  intro A hA B hB hAB
  have hA1 : (1 : ℝ) ≤ A := hA
  have hnn : 0 ≤ eulerRootPlus A := by
    rcases eq_or_lt_of_le hA1 with h | h
    · have : eulerRootPlus A ≤ 0 := eulerRootPlus_nonpos (by linarith) (by linarith)
      have hpos : 0 ≤ eulerRootPlus A := by
        unfold eulerRootPlus eulerDisc
        rw [← h]
        norm_num
      exact hpos
    · exact (eulerRootPlus_pos h).le
  exact Real.sqrt_lt_sqrt hnn (eulerRootPlus_strictMonoOn hA hB hAB)

/-! ### The variational equation and its Lyapunov exponent -/

/-- `x : ℝ → ℂ` is an **Euler perturbation mode** with mean motion `ω` and Euler parameter
`A` if `x⁗ + (2 − A) ω² x'' + (1 + A − 2A²) ω⁴ x = 0`. -/
def IsEulerMode (ω A : ℝ) (x : ℝ → ℂ) : Prop :=
  ∀ t : ℝ, deriv (deriv (deriv (deriv x))) t
    + ((2 - A : ℝ) : ℂ) * (ω : ℂ) ^ 2 * deriv (deriv x) t
    + ((1 + A - 2 * A ^ 2 : ℝ) : ℂ) * (ω : ℂ) ^ 4 * x t = 0

/-- Exponential curves built from characteristic roots solve the Euler variational
equation. -/
theorem isEulerMode_expMode {ω A : ℝ} {z : ℂ} (hz : eulerCharScaled ω A z = 0) :
    IsEulerMode ω A (fun t : ℝ => Complex.exp (z * t)) := by
  intro t
  have h1 := deriv_expMode z
  have e1 : deriv (deriv (fun t : ℝ => Complex.exp (z * t)))
      = fun t : ℝ => (z * z) * Complex.exp (z * t) := by
    rw [h1]; simpa using deriv_const_mul_expMode z z
  have e2 : deriv (deriv (deriv (fun t : ℝ => Complex.exp (z * t))))
      = fun t : ℝ => (z * z * z) * Complex.exp (z * t) := by
    rw [e1, deriv_const_mul_expMode z (z * z)]
  have e3 : deriv (deriv (deriv (deriv (fun t : ℝ => Complex.exp (z * t)))))
      = fun t : ℝ => (z * z * z * z) * Complex.exp (z * t) := by
    rw [e2, deriv_const_mul_expMode z (z * z * z)]
  rw [e3, e1]
  unfold eulerCharScaled at hz
  linear_combination Complex.exp (z * (t : ℂ)) * hz

/-- **Main theorem for the collinear configuration.** For every Euler parameter `A > 1`
and mean motion `ω > 0` the variational equation has a genuine solution whose Lyapunov
exponent equals `ω σ_E(A) > 0`, and whose norm grows monotonically (the root is real). -/
theorem euler_unstable_mode {A ω : ℝ} (hA : 1 < A) (hω : 0 < ω) :
    ∃ x : ℝ → ℂ, IsEulerMode ω A x ∧ lyapExp x = ω * eulerExponent A ∧ 0 < lyapExp x := by
  set z : ℂ := (ω : ℂ) * ((eulerExponent A : ℝ) : ℂ) with hzdef
  have hroot : eulerCharScaled ω A z = 0 := by
    rw [hzdef, eulerCharScaled_eq, euler_char_root hA, mul_zero]
  refine ⟨fun t => Complex.exp (z * t), isEulerMode_expMode hroot, ?_, ?_⟩
  · rw [lyapExp_expMode, hzdef]; simp [Complex.mul_re]
  · rw [lyapExp_expMode, hzdef]
    simp only [Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, sub_zero, mul_zero]
    exact mul_pos hω (eulerExponent_pos hA)

/-- The maximal Lyapunov exponent over any family containing the unstable Euler mode is
strictly positive: the collinear three-body configuration is chaotic at linear order. -/
theorem euler_maxLyapExp_pos {A ω : ℝ} (hA : 1 < A) (hω : 0 < ω)
    {S : Set (ℝ → ℂ)} (hbdd : BddAbove (lyapExp '' S))
    (hS : ∀ x : ℝ → ℂ, IsEulerMode ω A x → x ∈ S) : 0 < maxLyapExp S := by
  obtain ⟨x, hx, _, hpos⟩ := euler_unstable_mode hA hω
  exact maxLyapExp_pos (hS x hx) hbdd hpos

/-- **Sharpness.** No characteristic mode grows faster than `ω σ_E(A)`: above the window
the spectrum is `{±ω σ_E(A), ±i ω √(−u₋)}`, so `ω σ_E(A)` really is the maximal Lyapunov
exponent of the linearised collinear flow. -/
theorem euler_root_re_le {A : ℝ} (hA : 1 < A) {z : ℂ} (hz : eulerChar A z = 0) :
    z.re ≤ eulerExponent A := by
  have h89 : 8 / 9 ≤ A := by linarith
  have hm : eulerRootMinus A ≤ 0 := by
    have hd : 0 ≤ eulerDisc A := by unfold eulerDisc; nlinarith
    have hprod : eulerRootPlus A * eulerRootMinus A = 1 + A - 2 * A ^ 2 := eulerRoot_prod h89
    have hp : 0 < eulerRootPlus A := eulerRootPlus_pos hA
    nlinarith
  rw [eulerChar_factorization h89 z] at hz
  rcases mul_eq_zero.mp hz with h | h
  · have hz2 : z ^ 2 = ((eulerRootPlus A : ℝ) : ℂ) := sub_eq_zero.mp h
    -- `z² = σ²` forces `z = ±σ`
    have hsq : (z - ((eulerExponent A : ℝ) : ℂ)) * (z + ((eulerExponent A : ℝ) : ℂ)) = 0 := by
      have : ((eulerExponent A : ℝ) : ℂ) ^ 2 = ((eulerRootPlus A : ℝ) : ℂ) := by
        rw [← Complex.ofReal_pow, eulerExponent_sq hA]
      linear_combination hz2 - this
    rcases mul_eq_zero.mp hsq with h' | h'
    · have : z = ((eulerExponent A : ℝ) : ℂ) := sub_eq_zero.mp h'
      rw [this]; simp
    · have : z = -((eulerExponent A : ℝ) : ℂ) := by
        have := add_eq_zero_iff_eq_neg.mp h'
        exact this
      rw [this]
      simp
      linarith [(eulerExponent_pos hA).le, (eulerExponent_pos hA)]
  · have hz2 : z ^ 2 = ((eulerRootMinus A : ℝ) : ℂ) := sub_eq_zero.mp h
    have : z.re = 0 := re_eq_zero_of_sq_eq_nonpos hm hz2
    rw [this]
    exact (eulerExponent_pos hA).le

/-! ### Entropy consequences -/

/-- The Lyapunov spectrum of the linearised collinear configuration above the window:
`{ωσ_E, −ωσ_E, 0, 0}` (one hyperbolic pair plus one neutral oscillatory pair). -/
def eulerSpectrum (ω A : ℝ) : Fin 4 → ℝ :=
  ![ω * eulerExponent A, -(ω * eulerExponent A), 0, 0]

theorem sum_posPart_eulerSpectrum {ω A : ℝ} (hω : 0 < ω) (hA : 1 < A) :
    ∑ i, max (eulerSpectrum ω A i) 0 = ω * eulerExponent A := by
  have hσ : 0 < ω * eulerExponent A := mul_pos hω (eulerExponent_pos hA)
  simp only [eulerSpectrum, Fin.sum_univ_four, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.cons_val, max_eq_left hσ.le, max_eq_right (neg_nonpos.mpr hσ.le), max_self]
  ring

/-- The collinear configuration packaged as symplectic Ruelle data. -/
def eulerSymplecticData (ω A h : ℝ) (hω : 0 < ω) (hA : 1 < A)
    (hh : h ≤ ω * eulerExponent A) : SymplecticRuelleData 4 where
  dim_pos := by norm_num
  exps := eulerSpectrum ω A
  entropy := h
  ruelle := by rw [sum_posPart_eulerSpectrum hω hA]; exact hh
  pair := ![1, 0, 2, 3]
  pair_involutive := by intro i; fin_cases i <;> rfl
  exps_pair := by intro i; fin_cases i <;> simp [eulerSpectrum]

/-- **Entropy cap for the collinear configuration.** Ruelle's inequality caps the
Kolmogorov–Sinai entropy of the linearised collinear flow by the single hyperbolic rate
`ω σ_E(A)` — half the equilateral cap, because only one exponent is positive. -/
theorem euler_entropy_le {ω A : ℝ} (hω : 0 < ω) (hA : 1 < A) (R : Chaos.RuelleData 4)
    (hR : R.exps = eulerSpectrum ω A) : R.entropy ≤ ω * eulerExponent A := by
  have hru := R.ruelle
  rw [hR, sum_posPart_eulerSpectrum hω hA] at hru
  exact hru

/-- The symplectic Ruelle bound applied to the collinear spectrum: `λ_max ≥ h_KS/2`. -/
theorem euler_entropy_div_two_le_maxExp (ω A h : ℝ) (hω : 0 < ω) (hA : 1 < A)
    (hh : h ≤ ω * eulerExponent A) (hpos : 0 < h) :
    h / 2 ≤ (eulerSymplecticData ω A h hω hA hh).maxExp := by
  have := (eulerSymplecticData ω A h hω hA hh).two_mul_entropy_div_dim_le_maxExp
    (by simpa [eulerSymplecticData] using hpos)
  have hrw : 2 * (eulerSymplecticData ω A h hω hA hh).entropy / ((4 : ℕ) : ℝ) = h / 2 := by
    simp [eulerSymplecticData]
    ring
  rwa [hrw] at this

end ThreeBody