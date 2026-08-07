import Physics.Chaos.LyapunovCore

/-!
# A strictly positive Lyapunov exponent for the gravitational three-body problem

The Lagrange (equilateral) homographic solutions are exact solutions of the Newtonian
three-body problem: the three bodies sit at the vertices of an equilateral triangle of
side `a` which rotates rigidly with the Kepler mean motion `ω`, `ω² = G M / a³`, where
`M = m₁ + m₂ + m₃`.

Routh's classical reduction of the variational (linearised) equation about this solution
shows that, in rotating coordinates, each planar perturbation mode `x` obeys the constant
coefficient fourth-order equation

  `x⁗ + ω² x'' + (27/4) K ω⁴ x = 0`,   with `K = (m₁m₂ + m₂m₃ + m₃m₁) / M²`

whose characteristic polynomial is `z⁴ + ω² z² + (27/4) K ω⁴`. This file analyses that
polynomial completely and extracts explicit Lyapunov data:

* `lagrange_char_root` — an *explicit* root `σ + iν` with
  `σ = ½√(√(27K) − 1)`, `ν = ½√(√(27K) + 1)`, valid whenever `K ≥ 1/27`.
* `lagrangeExponent_pos` — `σ > 0` exactly in the Routh-unstable regime `K > 1/27`.
* `routh_stable_roots_pure_imaginary` — for `0 ≤ K ≤ 1/27` *every* root is purely
  imaginary, so the Routh threshold `K = 1/27` is sharp.
* `routhParam_equal_mass` and `routhParam_le_third` — the equal-mass system has
  `K = 1/3`, and `K ≤ 1/3` always: **equal masses maximise the instability**.
* `equalMass_lagrangeExponent` — for equal masses the dimensionless growth rate is
  exactly `√2/2 = 1/√2`, and `lagrangeExponent_le_equalMass` shows this is the largest
  possible value over all mass distributions.
* `lyapExp_expMode`, `lagrange_unstable_mode` and `equalMass_maximal_lyapunov_pos` — the
  corresponding solution curve of the variational equation has Lyapunov exponent exactly
  `ω σ = √(GM/a³)/√2 > 0`; hence the maximal Lyapunov exponent of the three-body flow
  is strictly positive: the system is (linearly) chaotic, with an explicit rate.
-/

noncomputable section

open Filter Topology Chaos

namespace ThreeBody

/-! ### The Routh mass parameter -/

/-- The dimensionless mass parameter controlling Lagrange-point stability,
`K = (m₁m₂ + m₂m₃ + m₃m₁)/(m₁+m₂+m₃)²`. -/
def routhParam (m₁ m₂ m₃ : ℝ) : ℝ := (m₁ * m₂ + m₂ * m₃ + m₃ * m₁) / (m₁ + m₂ + m₃) ^ 2

/-- For equal masses the Routh parameter equals `1/3`. -/
theorem routhParam_equal_mass {m : ℝ} (hm : 0 < m) : routhParam m m m = 1 / 3 := by
  unfold routhParam
  rw [show m * m + m * m + m * m = 3 * m ^ 2 by ring, show m + m + m = 3 * m by ring]
  field_simp

/-- **The equal-mass system maximises the Routh parameter**: `K ≤ 1/3`, with equality at
`m₁ = m₂ = m₃`. This is the sum-of-squares inequality
`m₁m₂ + m₂m₃ + m₃m₁ ≤ m₁² + m₂² + m₃²`. -/
theorem routhParam_le_third {m₁ m₂ m₃ : ℝ} (hsum : 0 < m₁ + m₂ + m₃) :
    routhParam m₁ m₂ m₃ ≤ 1 / 3 := by
  unfold routhParam
  rw [div_le_iff₀ (by positivity : (0:ℝ) < (m₁ + m₂ + m₃) ^ 2)]
  nlinarith [sq_nonneg (m₁ - m₂), sq_nonneg (m₂ - m₃), sq_nonneg (m₃ - m₁)]

/-- The Routh parameter is nonnegative for nonnegative masses. -/
theorem routhParam_nonneg {m₁ m₂ m₃ : ℝ} (h₁ : 0 ≤ m₁) (h₂ : 0 ≤ m₂) (h₃ : 0 ≤ m₃) :
    0 ≤ routhParam m₁ m₂ m₃ := by
  unfold routhParam; positivity

/-! ### The Routh characteristic polynomial -/

/-- The characteristic polynomial of the linearised Lagrange configuration, in units of
the mean motion: `z ↦ z⁴ + z² + (27/4) K`. -/
def lagrangeChar (K : ℝ) (z : ℂ) : ℂ := z ^ 4 + z ^ 2 + (27 / 4 : ℂ) * (K : ℂ)

/-- The characteristic polynomial with the physical mean motion `ω` restored. -/
def lagrangeCharScaled (ω K : ℝ) (z : ℂ) : ℂ :=
  z ^ 4 + (ω : ℂ) ^ 2 * z ^ 2 + (27 / 4 : ℂ) * (K : ℂ) * (ω : ℂ) ^ 4

/-- Scaling law: the physical polynomial is the dimensionless one, rescaled. -/
theorem lagrangeCharScaled_eq (ω K : ℝ) (w : ℂ) :
    lagrangeCharScaled ω K ((ω : ℂ) * w) = (ω : ℂ) ^ 4 * lagrangeChar K w := by
  unfold lagrangeCharScaled lagrangeChar; ring

/-- The **Lagrange growth rate** (real part of the unstable characteristic root, in units
of the mean motion): `σ(K) = ½ √(√(27K) − 1)`. -/
def lagrangeExponent (K : ℝ) : ℝ := Real.sqrt (Real.sqrt (27 * K) - 1) / 2

/-- The imaginary part of the same characteristic root: `ν(K) = ½ √(√(27K) + 1)`. -/
def lagrangeFrequency (K : ℝ) : ℝ := Real.sqrt (Real.sqrt (27 * K) + 1) / 2

/-- **Explicit unstable root of the Routh quartic.** For `K ≥ 1/27` the complex number
`σ(K) + i ν(K)` is a root of `z⁴ + z² + (27/4)K`. -/
theorem lagrange_char_root {K : ℝ} (hK : 1 / 27 ≤ K) :
    lagrangeChar K ⟨lagrangeExponent K, lagrangeFrequency K⟩ = 0 := by
  have hK0 : (0:ℝ) ≤ 27 * K := by linarith
  set s := Real.sqrt (27 * K) with hs
  have hs2 : s ^ 2 = 27 * K := Real.sq_sqrt hK0
  have hs1 : 1 ≤ s := by
    rw [hs, show (1:ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt (by linarith)
  set a := lagrangeExponent K with ha
  set b := lagrangeFrequency K with hb
  have ha2 : a ^ 2 = (s - 1) / 4 := by
    rw [ha, lagrangeExponent, div_pow, Real.sq_sqrt (by linarith)]; ring
  have hb2 : b ^ 2 = (s + 1) / 4 := by
    rw [hb, lagrangeFrequency, div_pow, Real.sq_sqrt (by linarith)]; ring
  have hab : a ^ 2 - b ^ 2 = -(1 / 2) := by rw [ha2, hb2]; ring
  simp only [lagrangeChar, Complex.ext_iff, Complex.add_re, Complex.add_im, Complex.mul_re,
    Complex.mul_im, Complex.zero_re, Complex.zero_im]
  norm_num [pow_succ, Complex.ext_iff]
  constructor
  · nlinarith [ha2, hb2, hs2]
  · linear_combination (4 * a * b) * hab

/-- The physical (frequency-restored) unstable root. -/
theorem lagrangeCharScaled_root {K ω : ℝ} (hK : 1 / 27 ≤ K) :
    lagrangeCharScaled ω K ((ω : ℂ) * ⟨lagrangeExponent K, lagrangeFrequency K⟩) = 0 := by
  rw [lagrangeCharScaled_eq, lagrange_char_root hK, mul_zero]

/-- **Routh instability.** Above the threshold `K > 1/27` the growth rate is strictly
positive. -/
theorem lagrangeExponent_pos {K : ℝ} (hK : 1 / 27 < K) : 0 < lagrangeExponent K := by
  have h1 : (1:ℝ) < Real.sqrt (27 * K) := by
    rw [show (1:ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_lt_sqrt (by norm_num) (by linarith)
  unfold lagrangeExponent
  have : 0 < Real.sqrt (Real.sqrt (27 * K) - 1) := Real.sqrt_pos.mpr (by linarith)
  linarith

/-- At the Routh threshold the growth rate vanishes. -/
theorem lagrangeExponent_threshold : lagrangeExponent (1 / 27) = 0 := by
  unfold lagrangeExponent
  norm_num

/-- **Equal masses: the exponent is exactly `1/√2`.** -/
theorem equalMass_lagrangeExponent : lagrangeExponent (1 / 3) = Real.sqrt 2 / 2 := by
  unfold lagrangeExponent
  rw [show (27:ℝ) * (1 / 3) = 3 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  norm_num

/-- The growth rate is monotone in the Routh parameter. -/
theorem lagrangeExponent_mono {K L : ℝ} (h : K ≤ L) :
    lagrangeExponent K ≤ lagrangeExponent L := by
  unfold lagrangeExponent
  have : Real.sqrt (27 * K) ≤ Real.sqrt (27 * L) := Real.sqrt_le_sqrt (by linarith)
  gcongr

/-- **Sharp equal-mass bound.** Over all mass distributions the Lagrange growth rate is
maximised by the equal-mass system, where it equals `√2/2`. -/
theorem lagrangeExponent_le_equalMass {m₁ m₂ m₃ : ℝ} (hsum : 0 < m₁ + m₂ + m₃) :
    lagrangeExponent (routhParam m₁ m₂ m₃) ≤ Real.sqrt 2 / 2 := by
  rw [← equalMass_lagrangeExponent]
  exact lagrangeExponent_mono (routhParam_le_third hsum)

/-! ### Sharpness: below the Routh threshold there is no instability -/

/-- **Routh stability below the threshold.** If `0 ≤ K ≤ 1/27` then every root of the
characteristic polynomial is purely imaginary, so no exponential growth occurs. Together
with `lagrangeExponent_pos` this shows the threshold `K = 1/27` is exactly sharp. -/
theorem routh_stable_roots_pure_imaginary {K : ℝ} (hK0 : 0 ≤ K) (hK : K ≤ 1 / 27) {z : ℂ}
    (hz : lagrangeChar K z = 0) : z.re = 0 := by
  set w : ℂ := z ^ 2 with hw
  set u : ℂ := w + 1 / 2 with hu
  have hquad : w ^ 2 + w + (27 / 4 : ℂ) * (K : ℂ) = 0 := by
    rw [hw]; rw [lagrangeChar] at hz; linear_combination hz
  have hu2 : u ^ 2 = (((1 - 27 * K) / 4 : ℝ) : ℂ) := by
    rw [hu]; push_cast; linear_combination hquad
  have hre : u.re ^ 2 - u.im ^ 2 = (1 - 27 * K) / 4 := by
    have := congrArg Complex.re hu2
    simpa [pow_two, Complex.mul_re] using this
  have him : 2 * (u.re * u.im) = 0 := by
    have := congrArg Complex.im hu2
    simp [pow_two, Complex.mul_im] at this
    linarith
  have huim : u.im = 0 := by
    rcases mul_eq_zero.mp (by linarith : u.re * u.im = 0) with h | h
    · nlinarith [hre, sq_nonneg u.im]
    · exact h
  have hwim : w.im = 0 := by
    have : u.im = w.im := by rw [hu]; simp
    linarith
  have hwre : w.re ≤ 0 := by
    have hueq : u.re = w.re + 1 / 2 := by rw [hu]; simp
    nlinarith [hre, huim, hK0]
  have h2 : 2 * (z.re * z.im) = 0 := by
    have : w.im = 2 * (z.re * z.im) := by rw [hw]; simp [pow_two, Complex.mul_im]; ring
    linarith
  have h3 : z.re ^ 2 - z.im ^ 2 = w.re := by
    rw [hw]; simp [pow_two, Complex.mul_re]
  rcases mul_eq_zero.mp (by linarith : z.re * z.im = 0) with h | h
  · exact h
  · nlinarith [h3, hwre]

/-! ### The exact Lyapunov spectrum: `Re z = ±σ` for every characteristic root -/

/-- If the square of a complex number is a nonpositive real, the number is purely
imaginary. -/
theorem re_eq_zero_of_sq_eq_nonpos {w : ℂ} {c : ℝ} (hc : c ≤ 0) (h : w ^ 2 = (c : ℂ)) :
    w.re = 0 := by
  have h1 : w.re ^ 2 - w.im ^ 2 = c := by
    have := congrArg Complex.re h
    simpa [pow_two, Complex.mul_re] using this
  have h2 : 2 * (w.re * w.im) = 0 := by
    have := congrArg Complex.im h
    simp [pow_two, Complex.mul_im] at this
    linarith
  rcases mul_eq_zero.mp (by linarith : w.re * w.im = 0) with h | h
  · exact h
  · nlinarith [h1, sq_nonneg w.re]

/-- **Complete factorisation of the Routh quartic** over the reals-with-`√`:
`z⁴ + z² + (27/4)K = (z² − 2σz + √(27K)/2)(z² + 2σz + √(27K)/2)`. -/
theorem lagrangeChar_factorization {K : ℝ} (hK : 1 / 27 ≤ K) (z : ℂ) :
    lagrangeChar K z =
      (z ^ 2 - 2 * (lagrangeExponent K : ℂ) * z + ((Real.sqrt (27 * K) : ℝ) : ℂ) / 2) *
        (z ^ 2 + 2 * (lagrangeExponent K : ℂ) * z + ((Real.sqrt (27 * K) : ℝ) : ℂ) / 2) := by
  have hK0 : (0:ℝ) ≤ 27 * K := by linarith
  set s := Real.sqrt (27 * K) with hs
  have hs2 : s ^ 2 = 27 * K := Real.sq_sqrt hK0
  have hs1 : 1 ≤ s := by
    rw [hs, show (1:ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt (by linarith)
  have ha2 : lagrangeExponent K ^ 2 = (s - 1) / 4 := by
    rw [lagrangeExponent, div_pow, Real.sq_sqrt (by linarith)]; ring
  have hA : ((lagrangeExponent K : ℂ)) ^ 2 = ((s : ℂ) - 1) / 4 := by
    have := congrArg (fun x : ℝ => (x : ℂ)) ha2
    push_cast at this ⊢
    linear_combination this
  have hS : ((s : ℂ)) ^ 2 = 27 * (K : ℂ) := by
    have := congrArg (fun x : ℝ => (x : ℂ)) hs2
    push_cast at this ⊢
    linear_combination this
  unfold lagrangeChar
  linear_combination (4 * z ^ 2) * hA - (1 / 4) * hS

/-- **The Lyapunov spectrum is exactly `{±σ}`.** Every characteristic root of the Routh
quartic has real part `+σ(K)` or `−σ(K)`; there is no faster growing mode. -/
theorem lagrange_root_re_eq {K : ℝ} (hK : 1 / 27 ≤ K) {z : ℂ} (hz : lagrangeChar K z = 0) :
    z.re = lagrangeExponent K ∨ z.re = -lagrangeExponent K := by
  have hK0 : (0:ℝ) ≤ 27 * K := by linarith
  set s := Real.sqrt (27 * K) with hs
  have hs1 : 1 ≤ s := by
    rw [hs, show (1:ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt (by linarith)
  set a := lagrangeExponent K with ha
  have ha2 : a ^ 2 = (s - 1) / 4 := by
    rw [ha, lagrangeExponent, div_pow, Real.sq_sqrt (by linarith)]; ring
  have hA : ((a : ℂ)) ^ 2 = ((s : ℂ) - 1) / 4 := by
    have := congrArg (fun x : ℝ => (x : ℂ)) ha2
    push_cast at this ⊢
    linear_combination this
  have hc : (-s - 1) / 4 ≤ 0 := by linarith
  rw [lagrangeChar_factorization hK] at hz
  rcases mul_eq_zero.mp hz with h | h
  · left
    have hsq : (z - (a : ℂ)) ^ 2 = (((-s - 1) / 4 : ℝ) : ℂ) := by
      push_cast
      linear_combination h + hA
    have := re_eq_zero_of_sq_eq_nonpos hc hsq
    simp only [Complex.sub_re, Complex.ofReal_re] at this
    linarith
  · right
    have hsq : (z + (a : ℂ)) ^ 2 = (((-s - 1) / 4 : ℝ) : ℂ) := by
      push_cast
      linear_combination h + hA
    have := re_eq_zero_of_sq_eq_nonpos hc hsq
    simp only [Complex.add_re, Complex.ofReal_re] at this
    linarith

/-- No characteristic root grows faster than `σ(K)`: the maximal Lyapunov exponent of the
linearised Lagrange flow is *exactly* `σ(K)`. -/
theorem lagrange_root_re_le {K : ℝ} (hK : 1 / 27 ≤ K) {z : ℂ} (hz : lagrangeChar K z = 0) :
    z.re ≤ lagrangeExponent K := by
  have hpos : 0 ≤ lagrangeExponent K := by
    unfold lagrangeExponent; positivity
  rcases lagrange_root_re_eq hK hz with h | h <;> linarith

/-- The same statement for the physical (frequency-restored) polynomial. -/
theorem lagrangeCharScaled_root_re_eq {K ω : ℝ} (hK : 1 / 27 ≤ K) (hω : 0 < ω) {z : ℂ}
    (hz : lagrangeCharScaled ω K z = 0) :
    z.re = ω * lagrangeExponent K ∨ z.re = -(ω * lagrangeExponent K) := by
  have hω' : ((ω : ℂ)) ≠ 0 := by
    simpa using ne_of_gt hω
  have hzw : ((ω : ℂ)) * (z / (ω : ℂ)) = z := by field_simp
  have h0 : ((ω : ℂ)) ^ 4 * lagrangeChar K (z / (ω : ℂ)) = 0 := by
    rw [← lagrangeCharScaled_eq, hzw]; exact hz
  have hroot : lagrangeChar K (z / (ω : ℂ)) = 0 := by
    rcases mul_eq_zero.mp h0 with h | h
    · exact absurd (pow_eq_zero_iff (n := 4) (by norm_num) |>.mp h) hω'
    · exact h
  have hre : (z / (ω : ℂ)).re = z.re / ω := by
    rw [Complex.div_re]
    simp [Complex.normSq_apply]
    field_simp
  rcases lagrange_root_re_eq hK hroot with h | h <;> rw [hre] at h
  · left; field_simp at h; linarith
  · right; field_simp at h; linarith

/-- **Sharp Routh criterion.** For nonnegative Routh parameter, an exponentially growing
mode exists *if and only if* `K > 1/27`. -/
theorem routh_instability_iff {K : ℝ} (hK0 : 0 ≤ K) :
    (∃ z : ℂ, lagrangeChar K z = 0 ∧ 0 < z.re) ↔ 1 / 27 < K := by
  constructor
  · rintro ⟨z, hz, hzre⟩
    by_contra hcon
    push_neg at hcon
    have := routh_stable_roots_pure_imaginary hK0 hcon hz
    linarith
  · intro hK
    exact ⟨⟨lagrangeExponent K, lagrangeFrequency K⟩, lagrange_char_root hK.le,
      lagrangeExponent_pos hK⟩

/-- **Hamiltonian (symplectic) pairing.** The characteristic polynomial is even, so the
spectrum is invariant under `z ↦ -z`: exponents come in pairs `±λ` and the spectrum sums
to zero, as Liouville's theorem requires. -/
theorem lagrangeChar_neg_root {K : ℝ} {z : ℂ} (hz : lagrangeChar K z = 0) :
    lagrangeChar K (-z) = 0 := by
  unfold lagrangeChar at *
  linear_combination hz

/-- The spectrum is also invariant under complex conjugation (real coefficients). -/
theorem lagrangeChar_conj_root {K : ℝ} {z : ℂ} (hz : lagrangeChar K z = 0) :
    lagrangeChar K ((starRingEnd ℂ) z) = 0 := by
  have h := congrArg (starRingEnd ℂ) hz
  simp only [lagrangeChar, map_add, map_mul, map_pow, map_div₀, map_zero, Complex.conj_ofReal,
    map_ofNat] at h
  exact h

/-! ### The variational equation and its Lyapunov exponent -/

/-- `x : ℝ → ℂ` is a **Lagrange perturbation mode** with mean motion `ω` and Routh
parameter `K` if it satisfies Routh's reduced variational equation
`x⁗ + ω² x'' + (27/4) K ω⁴ x = 0`. -/
def IsLagrangeMode (ω K : ℝ) (x : ℝ → ℂ) : Prop :=
  ∀ t : ℝ, deriv (deriv (deriv (deriv x))) t + (ω : ℂ) ^ 2 * deriv (deriv x) t
    + (27 / 4 : ℂ) * (K : ℂ) * (ω : ℂ) ^ 4 * x t = 0

/-- Derivative of a complex exponential mode. -/
theorem deriv_expMode (z : ℂ) :
    deriv (fun t : ℝ => Complex.exp (z * t)) = fun t : ℝ => z * Complex.exp (z * t) := by
  funext t
  have h1 : HasDerivAt (fun t : ℝ => (t : ℂ)) 1 t := by
    simpa using (Complex.ofRealCLM.hasDerivAt (x := t))
  have h2 : HasDerivAt (fun t : ℝ => z * (t : ℂ)) z t := by simpa using h1.const_mul z
  exact (h2.cexp).deriv.trans (by ring)

/-- Derivative of a scalar multiple of an exponential mode. -/
theorem deriv_const_mul_expMode (z c : ℂ) :
    deriv (fun t : ℝ => c * Complex.exp (z * t))
      = fun t : ℝ => (c * z) * Complex.exp (z * t) := by
  funext s
  rw [deriv_const_mul_field, deriv_expMode]
  ring

/-- Exponential curves built from characteristic roots really solve the variational
equation. -/
theorem isLagrangeMode_expMode {ω K : ℝ} {z : ℂ} (hz : lagrangeCharScaled ω K z = 0) :
    IsLagrangeMode ω K (fun t : ℝ => Complex.exp (z * t)) := by
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
  unfold lagrangeCharScaled at hz
  linear_combination Complex.exp (z * (t : ℂ)) * hz

/-- The norm of an exponential mode grows exactly like `e^{(Re z) t}`. -/
theorem norm_expMode (z : ℂ) (t : ℝ) : ‖Complex.exp (z * t)‖ = 1 * Real.exp (z.re * t) := by
  rw [Complex.norm_exp, one_mul]
  simp [Complex.mul_re]

/-- The Lyapunov exponent of an exponential mode is the real part of its characteristic
root. -/
theorem lyapExp_expMode (z : ℂ) : lyapExp (fun t : ℝ => Complex.exp (z * t)) = z.re :=
  lyapExp_of_exp_growth _ 1 z.re one_pos (fun t => norm_expMode z t)

/-- **Main theorem (dimensionless form).** For any Routh-unstable mass distribution
(`K > 1/27`) and any mean motion `ω > 0`, the variational equation of the Lagrange
three-body solution has a genuine solution whose Lyapunov exponent equals
`ω σ(K) > 0`. -/
theorem lagrange_unstable_mode {K ω : ℝ} (hK : 1 / 27 < K) (hω : 0 < ω) :
    ∃ x : ℝ → ℂ, IsLagrangeMode ω K x ∧ lyapExp x = ω * lagrangeExponent K
      ∧ 0 < lyapExp x := by
  set z : ℂ := (ω : ℂ) * ⟨lagrangeExponent K, lagrangeFrequency K⟩ with hzdef
  have hroot : lagrangeCharScaled ω K z = 0 := by
    rw [hzdef]; exact lagrangeCharScaled_root hK.le
  refine ⟨fun t => Complex.exp (z * t), isLagrangeMode_expMode hroot, ?_, ?_⟩
  · rw [lyapExp_expMode, hzdef]
    simp [Complex.mul_re]
  · rw [lyapExp_expMode, hzdef]
    simp only [Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, zero_mul, sub_zero]
    exact mul_pos hω (lagrangeExponent_pos hK)

/-- **Below the Routh threshold every mode is neutrally stable**: its Lyapunov exponent
vanishes and its amplitude is constant in time. -/
theorem lagrange_stable_mode_lyapExp_zero {K : ℝ} (hK0 : 0 ≤ K) (hK : K ≤ 1 / 27) {z : ℂ}
    (hz : lagrangeChar K z = 0) : lyapExp (fun t : ℝ => Complex.exp (z * t)) = 0 := by
  rw [lyapExp_expMode]
  exact routh_stable_roots_pure_imaginary hK0 hK hz

/-- **Routh dichotomy.** For a Lagrange configuration with `0 ≤ K` there are exactly two
regimes: for `K ≤ 1/27` every characteristic mode has Lyapunov exponent `0` (neutral,
quasi-periodic motion), while for `K > 1/27` there is a mode with Lyapunov exponent
`ωσ(K) > 0` (exponential divergence). Chaos switches on precisely at `K = 1/27`. -/
theorem routh_dichotomy {K ω : ℝ} (hK0 : 0 ≤ K) (hω : 0 < ω) :
    (K ≤ 1 / 27 → ∀ z : ℂ, lagrangeChar K z = 0 →
        lyapExp (fun t : ℝ => Complex.exp (z * t)) = 0) ∧
      (1 / 27 < K → ∃ x : ℝ → ℂ, IsLagrangeMode ω K x ∧ 0 < lyapExp x) := by
  refine ⟨fun hK z hz => lagrange_stable_mode_lyapExp_zero hK0 hK hz, fun hK => ?_⟩
  obtain ⟨x, hx, _, hpos⟩ := lagrange_unstable_mode hK hω
  exact ⟨x, hx, hpos⟩

/-! ### Explicit bounds for the equal-mass three-body problem -/

/-- The Kepler mean motion of an equilateral three-body configuration of side `a` and
total mass `M`: `ω = √(G M / a³)`. -/
def keplerFrequency (G M a : ℝ) : ℝ := Real.sqrt (G * M / a ^ 3)

theorem keplerFrequency_pos {G M a : ℝ} (hG : 0 < G) (hM : 0 < M) (ha : 0 < a) :
    0 < keplerFrequency G M a := Real.sqrt_pos.mpr (by positivity)

/-- **The explicit equal-mass Lyapunov rate**: `λ = √(GM/a³)·(√2/2) = ω/√2`. -/
def equalMassLyapunovRate (G M a : ℝ) : ℝ := keplerFrequency G M a * (Real.sqrt 2 / 2)

theorem equalMassLyapunovRate_pos {G M a : ℝ} (hG : 0 < G) (hM : 0 < M) (ha : 0 < a) :
    0 < equalMassLyapunovRate G M a :=
  mul_pos (keplerFrequency_pos hG hM ha) (by positivity)

/-- **Main theorem (equal masses, explicit constants).**
Three equal masses `m > 0` at the vertices of an equilateral triangle of side `a`,
rotating with the Kepler frequency `ω = √(3Gm/a³)`, possess a solution of the linearised
equations of motion whose Lyapunov exponent is *exactly*

  `λ = ω/√2 = √(3Gm/a³)/√2 > 0`,

so the maximal Lyapunov exponent of the three-body flow is strictly positive:
the equal-mass three-body problem is linearly chaotic with an explicit rate. -/
theorem equalMass_maximal_lyapunov_pos {G m a : ℝ} (hG : 0 < G) (hm : 0 < m) (ha : 0 < a) :
    ∃ x : ℝ → ℂ,
      IsLagrangeMode (keplerFrequency G (3 * m) a) (routhParam m m m) x ∧
      lyapExp x = equalMassLyapunovRate G (3 * m) a ∧ 0 < lyapExp x := by
  have hK : routhParam m m m = 1 / 3 := routhParam_equal_mass hm
  have hK' : 1 / 27 < routhParam m m m := by rw [hK]; norm_num
  have hω : 0 < keplerFrequency G (3 * m) a := keplerFrequency_pos hG (by linarith) ha
  obtain ⟨x, hx, hval, hpos⟩ := lagrange_unstable_mode hK' hω
  refine ⟨x, hx, ?_, hpos⟩
  rw [hval, hK, equalMass_lagrangeExponent]
  rfl

/-- **Sharpness of the equal-mass rate.** No characteristic mode of the equal-mass
linearised system grows faster than `ω/√2`, so `equalMassLyapunovRate` really is the
*maximal* Lyapunov exponent of the linearised flow, not merely a lower bound. -/
theorem equalMass_rate_is_maximal {G m a : ℝ} (hG : 0 < G) (hm : 0 < m) (ha : 0 < a) {z : ℂ}
    (hz : lagrangeCharScaled (keplerFrequency G (3 * m) a) (routhParam m m m) z = 0) :
    z.re ≤ equalMassLyapunovRate G (3 * m) a := by
  have hK : routhParam m m m = 1 / 3 := routhParam_equal_mass hm
  have hω : 0 < keplerFrequency G (3 * m) a := keplerFrequency_pos hG (by linarith) ha
  have hσ : lagrangeExponent (routhParam m m m) = Real.sqrt 2 / 2 := by
    rw [hK]; exact equalMass_lagrangeExponent
  have hrate : equalMassLyapunovRate G (3 * m) a
      = keplerFrequency G (3 * m) a * (Real.sqrt 2 / 2) := rfl
  have hnn : 0 ≤ equalMassLyapunovRate G (3 * m) a :=
    (equalMassLyapunovRate_pos hG (by linarith) ha).le
  rcases lagrangeCharScaled_root_re_eq (by rw [hK]; norm_num) hω hz with h | h
  · rw [h, hσ, ← hrate]
  · rw [h, hσ, ← hrate]; linarith

/-- **Chaos in the strict sense**: the maximal Lyapunov exponent of any family of
trajectories of the equal-mass Lagrange variational flow containing the unstable mode is
strictly positive. -/
theorem equalMass_maxLyapExp_pos {G m a : ℝ} (hG : 0 < G) (hm : 0 < m) (ha : 0 < a)
    {S : Set (ℝ → ℂ)} (hbdd : BddAbove (lyapExp '' S))
    (hmem : ∀ x : ℝ → ℂ, IsLagrangeMode (keplerFrequency G (3 * m) a) (routhParam m m m) x →
      lyapExp x = equalMassLyapunovRate G (3 * m) a → x ∈ S) :
    0 < maxLyapExp S := by
  obtain ⟨x, hx, hval, hpos⟩ := equalMass_maximal_lyapunov_pos hG hm ha
  exact maxLyapExp_pos (hmem x hx hval) hbdd hpos

/-- A concrete witness that the hypotheses of `equalMass_maxLyapExp_pos` are satisfiable:
the family of Lagrange modes with exponent at most the equal-mass rate has bounded
exponents and strictly positive maximal Lyapunov exponent. -/
theorem equalMass_maxLyapExp_pos_concrete {G m a : ℝ} (hG : 0 < G) (hm : 0 < m)
    (ha : 0 < a) :
    0 < maxLyapExp {x : ℝ → ℂ |
      IsLagrangeMode (keplerFrequency G (3 * m) a) (routhParam m m m) x ∧
        lyapExp x ≤ equalMassLyapunovRate G (3 * m) a} := by
  refine equalMass_maxLyapExp_pos hG hm ha ?_ ?_
  · refine ⟨equalMassLyapunovRate G (3 * m) a, ?_⟩
    rintro y ⟨x, ⟨-, hx⟩, rfl⟩
    exact hx
  · exact fun x hx hval => ⟨hx, le_of_eq hval⟩

/-- **Predictability horizon for the equal-mass three-body problem.** An initial
uncertainty `δ₀` amplified by the unstable Lagrange mode reaches the macroscopic scale
`Δ` after the explicit Lyapunov time `log(Δ/δ₀)/λ`. -/
theorem equalMass_lyapunov_time {G m a δ₀ Δ : ℝ} (hG : 0 < G) (hm : 0 < m) (ha : 0 < a)
    (hδ₀ : 0 < δ₀) (hΔ : 0 < Δ) (δ : ℝ → ℝ)
    (hgrow : ∀ t, δ₀ * Real.exp (equalMassLyapunovRate G (3 * m) a * t) ≤ δ t)
    {t : ℝ} (ht : lyapunovTime (equalMassLyapunovRate G (3 * m) a) δ₀ Δ ≤ t) : Δ ≤ δ t :=
  separation_reaches_scale δ _ δ₀ Δ
    (equalMassLyapunovRate_pos hG (by linarith) ha) hδ₀ hΔ hgrow ht

end ThreeBody