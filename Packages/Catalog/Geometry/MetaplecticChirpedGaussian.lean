import Geometry.MetaplecticGabor

/-!
# Chirped Gaussians as an SL₂(ℝ)-equivariant family

This is the geometric half of the metaplectic extension of the Gabor window action begun in
`Geometry.MetaplecticGabor`.  There the chirp operator `C_c` was shown to normalise the
Heisenberg group `Heis` of `Algebra.SmoothWindows.GaborOperators`, producing the semidirect
product `Heis ⋊ ℝ`.  Here we identify the *geometry* behind that algebra: the chirped Gaussians

  `G_{α,β}(t) = exp(-π(α + iβ)t²)`,  `α > 0`,

form a family parametrised by the upper half plane through the **Siegel parameter**
`z = i/(α+iβ)`, and the three basic window operations act on this parameter by Möbius
transformations coming from the three standard one-parameter subgroups of `SL₂(ℝ)`:

| window operation | matrix | action on `z` |
| --- | --- | --- |
| chirp `C_c` | shear `[[1,0],[-2c,1]]` | `z ↦ z/(1-2cz)` |
| dilation `D_u` | diagonal `diag(e^u, e^{-u})` | `z ↦ e^{2u} z` |
| Fourier transform `𝓕` | rotation by `π/2`, `[[0,-1],[1,0]]` | `z ↦ -1/z` |

## Main results

* `gaussChirp_eq_gaussC` — the catalog's Gaussian window `g_s` is the unchirped member
  `G_{1/s², 0}` of the family, so the family really extends `s ↦ gaussC s`.
* `chirpOp_gaussChirp`, `dilOp_gaussChirp` — the chirp and dilation operators act on the family
  by `β ↦ β - 2c` and `(α,β) ↦ e^{-2u}(α,β)`.
* `fourier_gaussChirp` — **the Fourier transform inverts the width parameter**, `τ ↦ 1/τ`, for
  every complex width with positive real part.  Specialising to `β = 0` reproduces the catalog's
  `fourier_gaussC` (`fourier_gaussChirp_unchirped`).
* `siegelPt_chirp`, `siegelPt_dilate`, `siegelPt_fourier` — **equivariance**: on Siegel
  parameters the three operations are exactly the shear, the diagonal and the rotation by `π/2`
  in `SL₂(ℝ)`, acting by Möbius transformations on the upper half plane.
* `shearMat_mul`, `dilMat_mul`, `fourierMat_sq`, `fourierMat_pow_four` — the corresponding
  subgroup structure: two one-parameter subgroups and an order-four element `S² = -1`.
* `gaussSpectral_dilate_monotone`, `gaussSpectral_dilate_strictMono` — **monotonicity of the
  scale space is the diagonal one-parameter subgroup acting**: `u ↦ gaussSpectral S (e^u s)` is
  monotone (strictly, if the family has a nonzero ordinate) because `u ↦ dilMat u` moves the
  Siegel parameter up the imaginary axis.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The one-parameter width family of the catalog should be the
  restriction to the imaginary axis of a *two*-parameter family carrying a transitive action of
  `SL₂(ℝ)`; monotonicity in the width should then be the statement that a one-parameter subgroup
  moves points monotonically along a geodesic.
* **Experiment (Experimenter).** The equivariance statements reduce, after
  `UpperHalfPlane.specialLinearGroup_apply`, to identities between complex fractions; the only
  analytic input is Mathlib's `fourier_gaussian_pi` for a complex width, whose hypothesis
  `0 < b.re` is exactly `α > 0`, i.e. exactly the condition defining the Siegel upper half plane.
* **Analysis (Analyst).** The width parameter `s` is the coordinate `z = i s²` on the imaginary
  geodesic; the diagonal subgroup translates along it, which is why `gaussSpectral` is monotone —
  a structural statement, not a computation with exponentials.
* **Critique (Critic).** Every statement about the family carries `α > 0`: for `α ≤ 0` the
  "Gaussian" is not integrable and the Siegel parameter leaves the upper half plane, so the
  hypothesis is not cosmetic.  It is kept explicit in `siegelPt`.
-/

namespace SmoothWindows

open Complex Real MeasureTheory FourierTransform

/-! ## The chirped Gaussian family -/

/-- The **chirped Gaussian** `G_{α,β}(t) = exp(-π(α + iβ)t²)`. -/
noncomputable def gaussChirp (α β : ℝ) : ℝ → ℂ :=
  fun t => Complex.exp (-(π : ℂ) * ((α : ℂ) + (β : ℂ) * I) * (t : ℂ) ^ 2)

/-- The complex width `τ = α + iβ` of a chirped Gaussian is nonzero as soon as `α > 0`. -/
theorem width_ne_zero {α : ℝ} (hα : 0 < α) (β : ℝ) : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := by
  intro h
  have hre : ((α : ℂ) + (β : ℂ) * I).re = 0 := by rw [h]; simp
  simp at hre
  exact absurd hre hα.ne'

/-- The catalog's Gaussian window is the unchirped member of the family. -/
theorem gaussChirp_eq_gaussC {s : ℝ} (hs : s ≠ 0) : gaussChirp (1 / s ^ 2) 0 = gaussC s := by
  funext t
  rw [gaussChirp, gaussC, gaussWin, Complex.ofReal_exp]
  congr 1
  have hs' : (s : ℂ) ≠ 0 := by exact_mod_cast hs
  push_cast
  simp only [zero_mul, add_zero]
  field_simp

/-- **The chirp operator moves inside the chirped Gaussian family**, shifting the imaginary part
of the width: `C_c G_{α,β} = G_{α, β-2c}`. -/
theorem chirpOp_gaussChirp (c α β : ℝ) :
    chirpOp c (gaussChirp α β) = gaussChirp α (β - 2 * c) := by
  funext t
  rw [chirpOp, gaussChirp, gaussChirp, chi, ← Complex.exp_add]
  congr 1
  push_cast
  ring

theorem gaussChirp_ne_zero (α β t : ℝ) : gaussChirp α β t ≠ 0 := Complex.exp_ne_zero _

/-- The modulus of a chirped Gaussian only sees the real part of the width: the chirp is a pure
phase, invisible to the window's envelope. -/
theorem norm_gaussChirp (α β t : ℝ) : ‖gaussChirp α β t‖ = Real.exp (-π * α * t ^ 2) := by
  rw [gaussChirp, Complex.norm_exp]
  congr 1
  have ht : ((t : ℂ)) ^ 2 = ((t ^ 2 : ℝ) : ℂ) := by push_cast; ring
  rw [ht]
  simp only [Complex.mul_re, Complex.mul_im, Complex.add_re, Complex.add_im, Complex.neg_re,
    Complex.neg_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
  ring

/-- The **dilation operator** `(D_u f)(t) = f(e^{-u} t)`, the window operation implementing the
diagonal subgroup of `SL₂(ℝ)`. -/
noncomputable def dilOp (u : ℝ) (f : ℝ → ℂ) : ℝ → ℂ := fun t => f (Real.exp (-u) * t)

@[simp] theorem dilOp_zero (f : ℝ → ℂ) : dilOp 0 f = f := by
  funext t; simp [dilOp]

theorem dilOp_dilOp (u u' : ℝ) (f : ℝ → ℂ) : dilOp u (dilOp u' f) = dilOp (u + u') f := by
  funext t
  simp only [dilOp, ← mul_assoc, ← Real.exp_add]
  ring_nf

/-- **Dilation acts on the chirped Gaussian family** by scaling the whole width parameter. -/
theorem dilOp_gaussChirp (u α β : ℝ) :
    dilOp u (gaussChirp α β) = gaussChirp (Real.exp (-2 * u) * α) (Real.exp (-2 * u) * β) := by
  funext t
  simp only [dilOp, gaussChirp]
  congr 1
  have h2 : (Real.exp (-u) : ℝ) ^ 2 = Real.exp (-2 * u) := by
    rw [← Real.exp_nat_mul]
    congr 1
    ring
  push_cast [← h2]
  ring

/-- Dilation on the catalog's Gaussian window is exactly the change of width `s ↦ e^u s`. -/
theorem dilOp_gaussC {s : ℝ} (hs : s ≠ 0) (u : ℝ) :
    dilOp u (gaussC s) = gaussC (Real.exp u * s) := by
  funext t
  simp only [dilOp, gaussC, gaussWin]
  congr 2
  have hexp : Real.exp u ≠ 0 := (Real.exp_pos u).ne'
  rw [mul_pow, Real.exp_neg]
  field_simp

/-! ## Fourier transform of a chirped Gaussian -/

/-- The reciprocal of the width, written in real coordinates. -/
theorem width_inv {α β : ℝ} (hd : (α ^ 2 + β ^ 2) ≠ 0) :
    ((α / (α ^ 2 + β ^ 2) : ℝ) : ℂ) + ((-β / (α ^ 2 + β ^ 2) : ℝ) : ℂ) * I
      = 1 / ((α : ℂ) + (β : ℂ) * I) := by
  have hdc : ((α : ℂ) ^ 2 + (β : ℂ) ^ 2) ≠ 0 := by exact_mod_cast hd
  have hne : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := by
    intro h
    apply hdc
    have hfac : ((α : ℂ) + (β : ℂ) * I) * ((α : ℂ) - (β : ℂ) * I) = (α : ℂ) ^ 2 + (β : ℂ) ^ 2 := by
      linear_combination (-(β : ℂ) ^ 2) * Complex.I_sq
    rw [← hfac, h, zero_mul]
  push_cast
  rw [eq_div_iff hne]
  field_simp
  linear_combination (-(β : ℂ) ^ 2) * Complex.I_sq

/-- **Fourier transform of a chirped Gaussian**: the width parameter `τ = α + iβ` is inverted,
`τ ↦ 1/τ`.  This is the analytic content of "the Fourier transform is the rotation by `π/2`". -/
theorem fourier_gaussChirp {α β : ℝ} (hα : 0 < α) :
    𝓕 (gaussChirp α β) = fun ξ : ℝ =>
      1 / ((α : ℂ) + (β : ℂ) * I) ^ (1 / 2 : ℂ) *
        gaussChirp (α / (α ^ 2 + β ^ 2)) (-β / (α ^ 2 + β ^ 2)) ξ := by
  have hd : (α ^ 2 + β ^ 2) ≠ 0 := by positivity
  have hb : (0 : ℝ) < ((α : ℂ) + (β : ℂ) * I).re := by simpa using hα
  have hne : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := width_ne_zero hα β
  have hrw : gaussChirp α β
      = fun x : ℝ => Complex.exp (-(π : ℂ) * ((α : ℂ) + (β : ℂ) * I) * (x : ℂ) ^ 2) := rfl
  rw [hrw, fourier_gaussian_pi hb]
  funext ξ
  congr 1
  rw [gaussChirp, width_inv hd]
  congr 1
  field_simp

/-- Consistency with the catalog's Gaussian self-duality `𝓕 g_s = s g_{1/s}`. -/
theorem fourier_gaussChirp_unchirped {s : ℝ} (hs : 0 < s) :
    𝓕 (gaussChirp (1 / s ^ 2) 0) = fun ξ : ℝ => (s : ℂ) * gaussC (1 / s) ξ := by
  rw [gaussChirp_eq_gaussC hs.ne', fourier_gaussC hs]

/-! ## The Siegel parameter -/

/-- The **Siegel parameter** `z = i/(α+iβ)` of a chirped Gaussian: the point of the upper half
plane classifying the Gaussian up to normalisation. -/
noncomputable def siegel (α β : ℝ) : ℂ := I / ((α : ℂ) + (β : ℂ) * I)

theorem siegel_eq {α β : ℝ} (hα : 0 < α) :
    siegel α β = ((β / (α ^ 2 + β ^ 2) : ℝ) : ℂ) + ((α / (α ^ 2 + β ^ 2) : ℝ) : ℂ) * I := by
  have hd : (α ^ 2 + β ^ 2) ≠ 0 := by positivity
  rw [siegel, div_eq_mul_one_div, ← width_inv hd]
  push_cast
  linear_combination (-(β : ℂ) / ((α : ℂ) ^ 2 + (β : ℂ) ^ 2)) * Complex.I_sq

theorem siegel_im_pos {α β : ℝ} (hα : 0 < α) : 0 < (siegel α β).im := by
  rw [siegel_eq hα]
  simp only [Complex.add_im, Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re,
    Complex.I_im]
  have h : 0 < α / (α ^ 2 + β ^ 2) := by positivity
  linarith

theorem siegel_ne_zero {α β : ℝ} (hα : 0 < α) : siegel α β ≠ 0 := by
  intro h
  have := siegel_im_pos (α := α) (β := β) hα
  rw [h] at this
  simp at this

/-- The chirped Gaussian `G_{α,β}` with `α > 0`, viewed as a point of the upper half plane. -/
noncomputable def siegelPt (α β : ℝ) (hα : 0 < α) : UpperHalfPlane :=
  ⟨siegel α β, siegel_im_pos hα⟩

@[simp] theorem coe_siegelPt (α β : ℝ) (hα : 0 < α) :
    ((siegelPt α β hα : UpperHalfPlane) : ℂ) = siegel α β := rfl

/-- The Siegel parameter is a faithful coordinate: distinct chirped Gaussians sit at distinct
points of the upper half plane. -/
theorem siegel_injective {α β α' β' : ℝ} (hα : 0 < α) (hα' : 0 < α')
    (h : siegel α β = siegel α' β') : α = α' ∧ β = β' := by
  have hne : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := width_ne_zero hα β
  have hne' : ((α' : ℂ) + (β' : ℂ) * I) ≠ 0 := width_ne_zero hα' β'
  rw [siegel, siegel, div_eq_div_iff hne hne'] at h
  have h' : ((α : ℂ) + (β : ℂ) * I) = ((α' : ℂ) + (β' : ℂ) * I) :=
    (mul_left_cancel₀ Complex.I_ne_zero h).symm
  exact ⟨by simpa using congrArg Complex.re h', by simpa using congrArg Complex.im h'⟩

/-! ## The three generators of SL₂(ℝ) -/

/-- The **shear** (chirp) matrix `[[1,0],[-2c,1]]`. -/
def shearMat (c : ℝ) : Matrix.SpecialLinearGroup (Fin 2) ℝ :=
  ⟨!![1, 0; -2 * c, 1], by simp [Matrix.det_fin_two_of]⟩

/-- The **rotation by π/2** matrix `[[0,-1],[1,0]]`, the phase-space avatar of the Fourier
transform. -/
def fourierMat : Matrix.SpecialLinearGroup (Fin 2) ℝ :=
  ⟨!![0, -1; 1, 0], by simp [Matrix.det_fin_two_of]⟩

/-- The **diagonal (dilation)** one-parameter subgroup `diag(e^u, e^{-u})`. -/
noncomputable def dilMat (u : ℝ) : Matrix.SpecialLinearGroup (Fin 2) ℝ :=
  ⟨!![Real.exp u, 0; 0, Real.exp (-u)], by simp [Matrix.det_fin_two_of, ← Real.exp_add]⟩

/-- `fourierMat` really is the rotation of phase space by the angle `π/2`. -/
theorem fourierMat_eq_rotation :
    (fourierMat : Matrix (Fin 2) (Fin 2) ℝ)
      = !![Real.cos (π / 2), -Real.sin (π / 2); Real.sin (π / 2), Real.cos (π / 2)] := by
  simp [fourierMat]

/-- The chirps form a one-parameter subgroup of `SL₂(ℝ)`. -/
theorem shearMat_mul (c c' : ℝ) : shearMat c * shearMat c' = shearMat (c + c') := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [shearMat]; ring

/-- The dilations form a one-parameter subgroup of `SL₂(ℝ)`. -/
theorem dilMat_mul (u u' : ℝ) : dilMat u * dilMat u' = dilMat (u + u') := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [dilMat, ← Real.exp_add]; ring_nf

/-- **`S² = -1`**: the Fourier rotation squares to the central element `-1` of `SL₂(ℝ)`.  This is
the seed of the metaplectic double cover: `-1` acts trivially on phase space but `𝓕²` is the
parity operator, not the identity (see `Geometry.MetaplecticAnomaly`). -/
theorem fourierMat_sq : fourierMat * fourierMat = -1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [fourierMat, Matrix.one_fin_two]

theorem fourierMat_pow_four : fourierMat ^ 4 = 1 := by
  have h2 : fourierMat ^ 2 = -1 := by rw [pow_two]; exact fourierMat_sq
  calc fourierMat ^ 4 = (fourierMat ^ 2) ^ 2 := by rw [← pow_mul]
    _ = 1 := by rw [h2, neg_one_sq]

/-! ## Möbius action of the three generators -/

theorem coe_shearMat_smul (c : ℝ) (z : UpperHalfPlane) :
    ((shearMat c • z : UpperHalfPlane) : ℂ) = (z : ℂ) / (((-2 * c : ℝ) : ℂ) * (z : ℂ) + 1) := by
  rw [UpperHalfPlane.specialLinearGroup_apply]
  simp [shearMat]

theorem coe_fourierMat_smul (z : UpperHalfPlane) :
    ((fourierMat • z : UpperHalfPlane) : ℂ) = -1 / (z : ℂ) := by
  rw [UpperHalfPlane.specialLinearGroup_apply]
  simp [fourierMat]

theorem coe_dilMat_smul (u : ℝ) (z : UpperHalfPlane) :
    ((dilMat u • z : UpperHalfPlane) : ℂ) = ((Real.exp (2 * u) : ℝ) : ℂ) * (z : ℂ) := by
  rw [UpperHalfPlane.specialLinearGroup_apply]
  simp [dilMat, Real.exp_neg]
  field_simp
  rw [two_mul, Complex.exp_add]
  ring

/-! ## Equivariance of the chirped Gaussian family -/

/-- The chirp shifts the Siegel parameter by the Möbius map of the shear matrix. -/
theorem siegel_chirp (c : ℝ) {α β : ℝ} (hα : 0 < α) :
    siegel α (β - 2 * c) = siegel α β / (((-2 * c : ℝ) : ℂ) * siegel α β + 1) := by
  have hτ : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := width_ne_zero hα β
  have hτ' : ((α : ℂ) + ((β - 2 * c : ℝ) : ℂ) * I) ≠ 0 := width_ne_zero hα _
  have hstep : ((-2 * c : ℝ) : ℂ) * siegel α β + 1
      = ((α : ℂ) + ((β - 2 * c : ℝ) : ℂ) * I) / ((α : ℂ) + (β : ℂ) * I) := by
    rw [siegel, eq_div_iff hτ, add_mul, one_mul, mul_assoc, div_mul_cancel₀ _ hτ]
    push_cast
    ring
  rw [hstep, siegel, siegel, div_div_div_cancel_right₀]
  exact hτ

/-- Dilation scales the Siegel parameter, the Möbius map of the diagonal matrix. -/
theorem siegel_dilate (u : ℝ) {α β : ℝ} (hα : 0 < α) :
    siegel (Real.exp (-2 * u) * α) (Real.exp (-2 * u) * β)
      = ((Real.exp (2 * u) : ℝ) : ℂ) * siegel α β := by
  have hτ : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := width_ne_zero hα β
  have hE : ((Real.exp (-2 * u) : ℝ) : ℂ) ≠ 0 := by
    exact_mod_cast (Real.exp_pos (-2 * u)).ne'
  have hEinv : ((Real.exp (2 * u) : ℝ) : ℂ) = (((Real.exp (-2 * u) : ℝ) : ℂ))⁻¹ := by
    rw [← Complex.ofReal_inv, ← Real.exp_neg]
    norm_num
  rw [siegel, siegel, hEinv]
  simp only [Complex.ofReal_mul]
  rw [show ((Real.exp (-2 * u) : ℝ) : ℂ) * (α : ℂ) + ((Real.exp (-2 * u) : ℝ) : ℂ) * (β : ℂ) * I
      = ((Real.exp (-2 * u) : ℝ) : ℂ) * ((α : ℂ) + (β : ℂ) * I) by ring]
  field_simp

/-- Inverting the width is the Möbius map `z ↦ -1/z` of the rotation by `π/2`. -/
theorem siegel_fourier {α β : ℝ} (hα : 0 < α) :
    siegel (α / (α ^ 2 + β ^ 2)) (-β / (α ^ 2 + β ^ 2)) = -1 / siegel α β := by
  have hd : (α ^ 2 + β ^ 2) ≠ 0 := by positivity
  have hτ : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := width_ne_zero hα β
  rw [siegel, siegel, width_inv hd]
  field_simp
  linear_combination ((α : ℂ) + (β : ℂ) * I) * Complex.I_sq

/-- **The chirp is the shear.**  Applying `C_c` to a chirped Gaussian moves its Siegel parameter
by the shear matrix `[[1,0],[-2c,1]]` of `SL₂(ℝ)`. -/
theorem siegelPt_chirp (c : ℝ) {α β : ℝ} (hα : 0 < α) :
    siegelPt α (β - 2 * c) hα = shearMat c • siegelPt α β hα := by
  apply UpperHalfPlane.ext
  rw [coe_shearMat_smul, coe_siegelPt, coe_siegelPt]
  exact siegel_chirp c hα

/-- **The dilation is the diagonal subgroup.**  Applying `D_u` scales the width parameter, which
on Siegel parameters is the Möbius action of `diag(e^u, e^{-u})`. -/
theorem siegelPt_dilate (u : ℝ) {α β : ℝ} (hα : 0 < α) (hα' : 0 < Real.exp (-2 * u) * α) :
    siegelPt (Real.exp (-2 * u) * α) (Real.exp (-2 * u) * β) hα'
      = dilMat u • siegelPt α β hα := by
  apply UpperHalfPlane.ext
  rw [coe_dilMat_smul, coe_siegelPt, coe_siegelPt]
  exact siegel_dilate u hα

/-- **The Fourier transform is the rotation by π/2.**  The Siegel parameter of the transformed
chirped Gaussian, as computed by `fourier_gaussChirp`, is the image of the original one under
`S = [[0,-1],[1,0]]`. -/
theorem siegelPt_fourier {α β : ℝ} (hα : 0 < α) (hα' : 0 < α / (α ^ 2 + β ^ 2)) :
    siegelPt (α / (α ^ 2 + β ^ 2)) (-β / (α ^ 2 + β ^ 2)) hα'
      = fourierMat • siegelPt α β hα := by
  apply UpperHalfPlane.ext
  rw [coe_fourierMat_smul, coe_siegelPt, coe_siegelPt]
  exact siegel_fourier hα


/-! ## The width geodesic and the scale space -/

/-- The catalog's Gaussian window `g_s` sits at the Siegel parameter `i s²` on the imaginary
geodesic of the upper half plane. -/
theorem siegel_gaussC {s : ℝ} (hs : 0 < s) : siegel (1 / s ^ 2) 0 = ((s ^ 2 : ℝ) : ℂ) * I := by
  have hs2 : ((s : ℂ)) ^ 2 ≠ 0 := by
    have : (s : ℂ) ≠ 0 := by exact_mod_cast hs.ne'
    exact pow_ne_zero _ this
  rw [siegel]
  push_cast
  simp only [add_zero, zero_mul]
  field_simp

/-- **Widening the window is the diagonal flow.**  Changing the width `s ↦ e^u s` is exactly the
action of the diagonal one-parameter subgroup `dilMat u` on the Siegel parameter. -/
theorem siegelPt_width_dilate {s : ℝ} (hs : 0 < s) (u : ℝ) :
    siegelPt (1 / (Real.exp u * s) ^ 2) 0 (by positivity)
      = dilMat u • siegelPt (1 / s ^ 2) 0 (by positivity) := by
  apply UpperHalfPlane.ext
  rw [coe_dilMat_smul, coe_siegelPt, coe_siegelPt, siegel_gaussC hs,
    siegel_gaussC (by positivity : (0:ℝ) < Real.exp u * s)]
  push_cast
  rw [mul_pow, two_mul, Complex.exp_add]
  ring

/-- **Monotonicity of the Gaussian scale space is the diagonal action.**  Flowing the window
along the diagonal one-parameter subgroup can only increase the detected spectral mass. -/
theorem gaussSpectral_dilate_monotone (S : Multiset ℝ) {s : ℝ} (hs : 0 < s) :
    Monotone fun u : ℝ => gaussSpectral S (Real.exp u * s) := by
  intro u v huv
  refine gaussSpectral_mono S (by positivity) ?_
  have := Real.exp_le_exp.2 huv
  nlinarith [Real.exp_pos u, Real.exp_pos v]

/-- Strict version: as soon as the zero family contains a nonzero ordinate, the diagonal flow is
strictly increasing.  This is the structural explanation of `gaussSpectral_strictMono`. -/
theorem gaussSpectral_dilate_strictMono {S : Multiset ℝ} {t : ℝ} (ht : t ∈ S) (ht0 : t ≠ 0)
    {s : ℝ} (hs : 0 < s) :
    StrictMono fun u : ℝ => gaussSpectral S (Real.exp u * s) := by
  intro u v huv
  refine gaussSpectral_strictMono ht ht0 (by positivity) ?_
  have hlt := Real.exp_lt_exp.2 huv
  nlinarith [Real.exp_pos u, Real.exp_pos v]

end SmoothWindows