import Geometry.MetaplecticAnomaly

/-!
# Cycle 2: the Borel subgroup acts simply transitively on the chirped Gaussian family

Cycle 1 (`Geometry.MetaplecticGabor`, `Geometry.MetaplecticChirpedGaussian`,
`Geometry.MetaplecticAnomaly`) added the chirp generator to translation and modulation, showed
that `Heis` is normal in `Heis ⋊ ℝ`, identified chirp / dilation / Fourier with the shear /
diagonal / rotation-by-`π/2` subgroups of `SL₂(ℝ)`, and isolated the metaplectic anomaly at the
central element `S² = -1`.

This file runs the loop again on the resulting picture.  The new question: *how much of the
chirped Gaussian family is reachable from the catalog's Gaussian window?*  The answer is
everything — the lower Borel subgroup `B = {shear} · {diagonal}` already acts transitively — and
the two generators of `B` lift to window operators honestly (no anomaly), unlike the Fourier
rotation.

## Main results

* `dilShear_mul`, `gaborAct_dilShear` — **dilation also normalises `Heis`**, by the *unphased*
  automorphism `(a,b,z) ↦ (e^u a, e^{-u} b, z)`; the Weyl cocycle `χ(ba')` is literally invariant
  because the diagonal subgroup preserves the symplectic form.
* `heis_normal_in_dilHeis` — the resulting semidirect product `Heis ⋊ ℝ_dil`, with `Heis` normal.
* `dilOp_chirpOp_dilOp`, `dilMat_shearMat_dilMat` — the **Borel commutation relation**
  `D_u C_c D_u^{-1} = C_{e^{-2u} c}`, proved twice: for window operators and for the
  corresponding matrices of `SL₂(ℝ)`.  The two agree, so the Borel subgroup lifts honestly.
* `gaussChirp_borel_orbit` — **transitivity**: every chirped Gaussian is obtained from the
  standard one `exp(-πt²)` by one dilation and one chirp, with explicit parameters.
* `siegelPt_borel_orbit` — the same statement on the upper half plane: `B · i = ℍ`.
* `chirp_moves_off_imaginary_axis` — **transversality**: the catalog's Gaussian windows are
  exactly the points of the imaginary geodesic (`siegel_gaussC_re`), and a nonzero chirp always
  moves the window off that geodesic.  The chirp direction is a genuinely new dimension of window
  space, not a reparametrisation of the width.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Cycle 1 left open whether the chirp really adds a dimension or
  merely re-coordinatises the width.  Conjecture: the width family is a geodesic, and the chirp
  is transverse to it, with the two together sweeping out all of `ℍ`.
* **Experiment (Experimenter).** Transitivity was found by solving `e^{-2u} = α` and `-2c = β`,
  i.e. `u = -(log α)/2`, `c = -β/2` — the exponential map of the Borel Lie algebra in coordinates.
  The commutation relation `D_u C_c D_u^{-1} = C_{e^{-2u}c}` matched the matrix conjugation
  `diag(e^u,e^{-u}) · shear(c) · diag(e^{-u},e^u) = shear(e^{-2u}c)` on the nose.
* **Analysis (Analyst).** The absence of any phase in `dilShear` (contrast the `χ(ca²)` in
  `chirpShear`) is the statement that the diagonal subgroup preserves the symplectic form
  *pointwise on the cocycle*, whereas the shear only preserves it up to a coboundary.  That is
  the structural reason the catalog's width monotonicity is "free" while the chirp needed a
  cocycle computation.
* **Critique (Critic).** Transitivity is of the *lower* Borel: our chirp is the lower unipotent
  `[[1,0],[-2c,1]]` (it fixes `0`, not `∞`).  Had we used the upper unipotent (a translation of
  the Siegel parameter) the orbit statement would be false for the real-analytic family used
  here, since translation of `z` is not implemented by multiplication by a chirp.
-/

namespace SmoothWindows

open Complex Real MeasureTheory FourierTransform

/-! ## The dilation automorphism of the Heisenberg group -/

/-- The **dilation shear** of the Heisenberg group: `(a,b,z) ↦ (e^u a, e^{-u} b, z)`.  Unlike the
chirp shear it needs no phase correction: the diagonal subgroup preserves the Weyl cocycle. -/
noncomputable def dilShear (u : ℝ) (g : Heis) : Heis :=
  ⟨Real.exp u * g.a, Real.exp (-u) * g.b, g.z⟩

@[simp] theorem dilShear_a (u : ℝ) (g : Heis) : (dilShear u g).a = Real.exp u * g.a := rfl
@[simp] theorem dilShear_b (u : ℝ) (g : Heis) : (dilShear u g).b = Real.exp (-u) * g.b := rfl
@[simp] theorem dilShear_z (u : ℝ) (g : Heis) : (dilShear u g).z = g.z := rfl

theorem dilShear_zero (g : Heis) : dilShear 0 g = g := by
  refine Heis.ext ?_ ?_ rfl <;> simp

theorem dilShear_dilShear (u u' : ℝ) (g : Heis) :
    dilShear u (dilShear u' g) = dilShear (u + u') g := by
  refine Heis.ext ?_ ?_ rfl
  · show Real.exp u * (Real.exp u' * g.a) = Real.exp (u + u') * g.a
    rw [Real.exp_add]; ring
  · show Real.exp (-u) * (Real.exp (-u') * g.b) = Real.exp (-(u + u')) * g.b
    rw [show -(u + u') = -u + -u' by ring, Real.exp_add]; ring

/-- **The dilation shear is a group automorphism of `Heis`.**  The Weyl phase `χ(b a')` is
literally invariant: `(e^{-u}b)(e^{u}a') = b a'`. -/
theorem dilShear_mul (u : ℝ) (g h : Heis) :
    dilShear u (g * h) = dilShear u g * dilShear u h := by
  refine Heis.ext (by simp [mul_add]) (by simp [mul_add]) ?_
  have hinv : Real.exp (-u) * Real.exp u = 1 := by
    rw [← Real.exp_add]; simp
  simp only [dilShear_z, dilShear_a, dilShear_b, Heis.mul_z]
  congr 2
  linear_combination (-(2 * π * (g.b * h.a))) * hinv

/-- The dilation shear packaged as an automorphism of the Heisenberg group. -/
noncomputable def dilAut (u : ℝ) : MulAut Heis where
  toFun := dilShear u
  invFun := dilShear (-u)
  left_inv g := by rw [dilShear_dilShear]; simpa using dilShear_zero g
  right_inv g := by rw [dilShear_dilShear]; simpa using dilShear_zero g
  map_mul' := dilShear_mul u

/-- The one-parameter group of dilation automorphisms. -/
noncomputable def dilAutHom : Multiplicative ℝ →* MulAut Heis where
  toFun u := dilAut (Multiplicative.toAdd u)
  map_one' := by ext g <;> simp [dilAut, dilShear_zero]
  map_mul' u u' := by
    ext g <;> simp [dilAut, ← dilShear_dilShear, add_comm]

/-- The semidirect product of the Heisenberg group with the dilation group. -/
abbrev DilHeis := Heis ⋊[dilAutHom] Multiplicative ℝ

/-- **`Heis` is normal in `Heis ⋊ ℝ_dil` as well.** -/
theorem heis_normal_in_dilHeis :
    (SemidirectProduct.inl : Heis →* DilHeis).range.Normal := by
  rw [SemidirectProduct.range_inl_eq_ker_rightHom]
  infer_instance

/-- **The dilation operator implements the dilation automorphism**: `D_u ρ(g) = ρ(δ_u g) D_u`. -/
theorem gaborAct_dilShear (u : ℝ) (g : Heis) (f : ℝ → ℂ) :
    gaborAct (dilShear u g) (dilOp u f) = dilOp u (gaborAct g f) := by
  funext t
  have hinv : Real.exp (-u) * Real.exp u = 1 := by rw [← Real.exp_add]; simp
  simp only [gaborAct_apply, dilOp, dilShear_a, dilShear_b, dilShear_z]
  congr 2
  · congr 1
    linear_combination (-(g.b * g.a)) * hinv
  · linear_combination (-g.a) * hinv

/-! ## The Borel commutation relation -/

/-- **`D_u C_c D_u^{-1} = C_{e^{-2u} c}`** at the level of window operators. -/
theorem dilOp_chirpOp_dilOp (u c : ℝ) (f : ℝ → ℂ) :
    dilOp u (chirpOp c (dilOp (-u) f)) = chirpOp (Real.exp (-2 * u) * c) f := by
  funext t
  simp only [dilOp, chirpOp, neg_neg]
  have hsq : Real.exp (-u) ^ 2 = Real.exp (-2 * u) := by
    rw [sq, ← Real.exp_add]; congr 1; ring
  have harg : c * (Real.exp (-u) * t) ^ 2 = Real.exp (-2 * u) * c * t ^ 2 := by
    rw [mul_pow, hsq]; ring
  have hf : Real.exp u * (Real.exp (-u) * t) = t := by
    rw [← mul_assoc, ← Real.exp_add]; simp
  rw [harg, hf]

/-- **`diag(e^u,e^{-u}) · shear(c) · diag(e^{-u},e^{u}) = shear(e^{-2u} c)`** at the level of
`SL₂(ℝ)`: the operator relation `dilOp_chirpOp_dilOp` is exactly the matrix relation. -/
theorem dilMat_shearMat_dilMat (u c : ℝ) :
    dilMat u * shearMat c * dilMat (-u) = shearMat (Real.exp (-2 * u) * c) := by
  have hinv : Real.exp u * Real.exp (-u) = 1 := by rw [← Real.exp_add]; simp
  have hsq : Real.exp (-u) ^ 2 = Real.exp (-(u * 2)) := by
    rw [sq, ← Real.exp_add]; congr 1; ring
  have hsq2 : Real.exp (-(u * 2)) = Real.exp (-(2 * u)) := by congr 1; ring
  ext i j
  fin_cases i <;> fin_cases j <;> simp [dilMat, shearMat] <;>
    (first
      | linear_combination hinv
      | linear_combination (2 * c) * hsq + (2 * c) * hsq2)

/-! ## Transitivity of the Borel subgroup on the chirped Gaussian family -/

/-- **Every chirped Gaussian is a chirped dilate of the standard Gaussian.**  One dilation sets
the width, one chirp sets the chirp rate: the lower Borel subgroup acts transitively on the
family. -/
theorem gaussChirp_borel_orbit {α : ℝ} (hα : 0 < α) (β : ℝ) :
    gaussChirp α β
      = chirpOp (-(β / 2)) (dilOp (-(Real.log α) / 2) (gaussChirp 1 0)) := by
  have hdil : dilOp (-(Real.log α) / 2) (gaussChirp 1 0) = gaussChirp α 0 := by
    rw [dilOp_gaussChirp]
    have hexp : Real.exp (-2 * (-(Real.log α) / 2)) = α := by
      rw [show -2 * (-(Real.log α) / 2) = Real.log α by ring, Real.exp_log hα]
    rw [hexp, mul_one, mul_zero]
  rw [hdil, chirpOp_gaussChirp]
  congr 1
  ring

/-- The same statement on the upper half plane: the Borel orbit of the standard point is
everything. -/
theorem siegelPt_borel_orbit {α : ℝ} (hα : 0 < α) (β : ℝ) :
    siegelPt α β hα
      = shearMat (-(β / 2)) • (dilMat (-(Real.log α) / 2) • siegelPt 1 0 one_pos) := by
  have hexp : Real.exp (2 * (-(Real.log α) / 2)) = α⁻¹ := by
    rw [show 2 * (-(Real.log α) / 2) = -Real.log α by ring, Real.exp_neg, Real.exp_log hα]
  have hαc : (α : ℂ) ≠ 0 := by exact_mod_cast hα.ne'
  have hτ : ((α : ℂ) + (β : ℂ) * I) ≠ 0 := width_ne_zero hα β
  apply UpperHalfPlane.ext
  rw [coe_shearMat_smul, coe_dilMat_smul, coe_siegelPt, coe_siegelPt, hexp, siegel, siegel]
  push_cast
  field_simp
  ring

/-! ## Transversality of the chirp direction -/

/-- The catalog's Gaussian windows are exactly the points of the imaginary geodesic. -/
theorem siegel_gaussC_re {s : ℝ} (hs : 0 < s) : (siegel (1 / s ^ 2) 0).re = 0 := by
  rw [siegel_gaussC hs, Complex.mul_re, Complex.I_re, Complex.I_im, Complex.ofReal_re,
    Complex.ofReal_im]
  ring

/-- **The chirp is transverse to the width direction.**  A nonzero chirp always moves the window
off the imaginary geodesic swept out by the width parameter, so no change of width can imitate a
chirp. -/
theorem chirp_moves_off_imaginary_axis {s : ℝ} (hs : 0 < s) {c : ℝ} (hc : c ≠ 0) :
    (siegel (1 / s ^ 2) (0 - 2 * c)).re ≠ 0 := by
  have h1 : (0:ℝ) < 1 / s ^ 2 := by positivity
  have hd : ((1 / s ^ 2) ^ 2 + (0 - 2 * c) ^ 2) ≠ 0 := by positivity
  rw [siegel_eq h1]
  simp only [Complex.add_re, Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re,
    Complex.I_im, mul_zero, zero_mul, sub_zero, add_zero]
  intro hzero
  rcases div_eq_zero_iff.1 hzero with h | h
  · have : c = 0 := by linarith
    exact hc this
  · exact hd h

/-- Consequently a chirped Gaussian window is never equal to any Gaussian window of the catalog,
recovering `chirpOp_gaussC_ne_gaussC` from the geometry of the upper half plane. -/
theorem gaussChirp_chirped_ne_gaussC {s : ℝ} (hs : 0 < s) {c : ℝ} (hc : c ≠ 0) {s' : ℝ}
    (hs' : 0 < s') :
    siegel (1 / s ^ 2) (0 - 2 * c) ≠ siegel (1 / s' ^ 2) 0 := by
  intro h
  have hre := congrArg Complex.re h
  rw [siegel_gaussC_re hs'] at hre
  exact chirp_moves_off_imaginary_axis hs hc hre

end SmoothWindows