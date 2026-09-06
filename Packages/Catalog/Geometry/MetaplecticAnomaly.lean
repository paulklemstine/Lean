import Geometry.MetaplecticChirpedGaussian

/-!
# The metaplectic anomaly of the Gabor window action

`Geometry.MetaplecticGabor` built the semidirect product `Heis ⋊ ℝ` in which the Heisenberg group
of `Algebra.SmoothWindows.GaborOperators` is normal, and `Geometry.MetaplecticChirpedGaussian`
identified the geometry: chirp, dilation and Fourier transform act on chirped Gaussians through
the shear, the diagonal and the rotation by `π/2` in `SL₂(ℝ)`.

This file is the adversarial part of the programme: it isolates the *obstructions*.

## Main results

* `fourier_fourier_gaborAtom` — `𝓕² (T_a M_b g_s) = T_{-a} M_{-b} g_s`: two Fourier transforms
  give the **parity operator**, not the identity.
* `metaplectic_anomaly` — **the anomaly**: the matrix `S² = -1` acts *trivially* on phase space
  (every point of the upper half plane is fixed), yet the corresponding window operator `𝓕²` is
  *not* the identity on Gabor atoms off the origin of phase space.  So the `SL₂(ℝ)` action on
  phase space does not lift to an action on windows: the honest symmetry group is the double
  cover (the metaplectic group), and the discrepancy is a genuine order-two cocycle class.
* `metaplectic_anomaly_projective` — the anomaly is **projective**: rescaling `𝓕²` by *any*
  complex constant still fails to reproduce the atom, so no normalisation of the lift removes the
  obstruction.
* `chirpShear_not_inner` — the chirp automorphism of `Heis` is **outer** for `c ≠ 0`: the shear
  direction is not absorbed by conjugation inside the Heisenberg group, so `Heis ⋊ ℝ` is not a
  direct product.
* `chirpShear_mapsTo_heisLattice_iff` — **the discrete anomaly**: the shear preserves the integer
  Heisenberg lattice (the one supporting a discrete, multiset-indexed Gabor transform) *iff*
  `2c ∈ ℤ`.  The continuous theory has a full `ℝ`-worth of chirps; the discrete one only a
  lattice of them.
* `chirpOp_gaussC_ne_gaussC` — a chirped window is never a real Gaussian window: the family of
  `Algebra.SmoothWindows.GaussianWindow` is not closed under the metaplectic action, which is
  precisely why the chirped family of `Geometry.MetaplecticChirpedGaussian` is needed.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** If the phase-space action of `SL₂(ℝ)` lifted honestly to
  windows, then `S² = -1`, acting trivially on the upper half plane, would have to act trivially
  on windows too.  Conjecture: it acts by parity, so the lift is only projective.
* **Experiment (Experimenter).** `𝓕²` on a Gabor atom was computed by composing the catalog's
  `fourier_gaborAtom` with `fourier_transOp`, `fourier_modOp` and `fourier_gaussC`; the constants
  `s` and `1/s` cancel exactly, leaving the parity image with *no* extra phase.  The separation
  of the two atoms needed two different invariants: the modulus (when `a ≠ 0`) and the quarter
  period of `χ` (when `a = 0`, `b ≠ 0`).
* **Analysis (Analyst).** The obstruction is of order two: `𝓕⁴ = id` on atoms, matching
  `S⁴ = 1`, and `𝓕² ≠ id` matches `S² = -1 ≠ 1`.  The chirp subgroup, being simply connected,
  lifts honestly — which is exactly why `metaRep` of `Geometry.MetaplecticGabor` is an honest
  homomorphism while the full `SL₂(ℝ)` action cannot be.
* **Critique (Critic).** The anomaly statement is guarded by `a ≠ 0 ∨ b ≠ 0`: on the
  origin-centred Gaussian itself, parity *is* the identity (the Gaussian is even), so the
  anomaly is invisible there.  This is a genuine boundary of the phenomenon, not an artefact.
-/

namespace SmoothWindows

open Complex Real MeasureTheory FourierTransform

/-! ## Auxiliary facts about the character `χ` -/

theorem chi_half_ne_one : chi (1 / 2 : ℝ) ≠ 1 := by
  intro h
  obtain ⟨n, hn⟩ := (chi_eq_one_iff _).1 h
  have h2 : (2 : ℝ) * (n : ℝ) = 1 := by rw [← hn]; norm_num
  have : (2 : ℤ) * n = 1 := by exact_mod_cast h2
  omega

theorem chi_im (x : ℝ) : (chi x).im = Real.sin (2 * π * x) := by
  rw [chi]
  exact Complex.exp_ofReal_mul_I_im _

theorem chi_quarter_im : (chi (1 / 4 : ℝ)).im = 1 := by
  rw [chi_im, show 2 * π * (1 / 4 : ℝ) = π / 2 by ring, Real.sin_pi_div_two]

theorem chi_neg_quarter_im : (chi (-(1 / 4) : ℝ)).im = -1 := by
  rw [chi_im, show 2 * π * (-(1 / 4) : ℝ) = -(π / 2) by ring, Real.sin_neg,
    Real.sin_pi_div_two]

/-! ## The square of the Fourier transform on Gabor atoms -/

/-- The Fourier transform is homogeneous: constants factor out. -/
theorem fourier_const_mul (c : ℂ) (f : ℝ → ℂ) (w : ℝ) :
    𝓕 (fun t => c * f t) w = c * 𝓕 f w := by
  simp only [Real.fourier_real_eq_integral_exp_smul, smul_eq_mul]
  rw [← MeasureTheory.integral_const_mul]
  refine MeasureTheory.integral_congr_ae (Filter.Eventually.of_forall fun v => ?_)
  ring

/-- **Two Fourier transforms give parity, not the identity.**  `𝓕²(T_a M_b g_s) = T_{-a}M_{-b}g_s`
— the Gabor atom at the phase-space point `(a,b)` is sent to the atom at `(-a,-b)`. -/
theorem fourier_fourier_gaborAtom {s : ℝ} (hs : 0 < s) (a b : ℝ) :
    𝓕 (𝓕 (gaborAtom s a b)) = gaborAtom s (-a) (-b) := by
  have hs' : (0 : ℝ) < 1 / s := by positivity
  have hsc : (s : ℂ) ≠ 0 := by exact_mod_cast hs.ne'
  have hfa : 𝓕 (gaborAtom s a b)
      = fun ξ : ℝ => (s : ℂ) * modOp (-a) (transOp b (gaussC (1 / s))) ξ := by
    funext ξ
    rw [fourier_gaborAtom hs]
    simp only [modOp, transOp]
    rw [show -(a * ξ) = -a * ξ by ring]
    ring
  funext ξ
  rw [hfa, fourier_const_mul, fourier_modOp, transOp, fourier_transOp, fourier_gaussC hs',
    one_div_one_div, gaborAtom_apply]
  rw [show ξ - -a = ξ + a by ring, show -b * (ξ + a) = -(b * (ξ + a)) by ring,
    show ((1 / s : ℝ) : ℂ) = 1 / (s : ℂ) by push_cast; ring]
  field_simp

/-- The Fourier transform has order four on Gabor atoms, matching `S⁴ = 1` in `SL₂(ℝ)`. -/
theorem fourier_pow_four_gaborAtom {s : ℝ} (hs : 0 < s) (a b : ℝ) :
    𝓕 (𝓕 (𝓕 (𝓕 (gaborAtom s a b)))) = gaborAtom s a b := by
  rw [fourier_fourier_gaborAtom hs, fourier_fourier_gaborAtom hs, neg_neg, neg_neg]

/-- Two Gabor atoms at opposite phase-space points are genuinely different windows. -/
theorem gaborAtom_ne_neg {s : ℝ} (hs : 0 < s) {a b : ℝ} (hab : a ≠ 0 ∨ b ≠ 0) :
    gaborAtom s (-a) (-b) ≠ gaborAtom s a b := by
  intro h
  by_cases ha : a = 0
  · -- same centre, opposite modulations: the phases differ by a half period
    have hb : b ≠ 0 := by
      rcases hab with h' | h'
      · exact absurd ha h'
      · exact h'
    subst ha
    simp only [neg_zero] at h
    have hb4 : b * (1 / (4 * b)) = 1 / 4 := by field_simp
    have hval := congrFun h (1 / (4 * b))
    rw [gaborAtom_apply, gaborAtom_apply, sub_zero] at hval
    have hne : gaussC s (1 / (4 * b)) ≠ 0 := gaussC_ne_zero _ _
    have hchi : chi (-b * (1 / (4 * b))) = chi (b * (1 / (4 * b))) :=
      mul_right_cancel₀ hne hval
    have hhalf : chi (1 / 2 : ℝ) = 1 := by
      have hsum : chi (-b * (1 / (4 * b))) * chi (b * (1 / (4 * b)))
          = chi (-b * (1 / (4 * b)) + b * (1 / (4 * b))) := (chi_add _ _).symm
      rw [show -b * (1 / (4 * b)) + b * (1 / (4 * b)) = 0 by ring, chi_zero, hchi] at hsum
      rw [show (1 / 2 : ℝ) = b * (1 / (4 * b)) + b * (1 / (4 * b)) by rw [hb4]; norm_num,
        chi_add, ← hsum]
    exact chi_half_ne_one hhalf
  · -- the moduli differ: the atoms are centred at `-a` and `a`
    have hval := congrFun h a
    rw [gaborAtom_apply, gaborAtom_apply] at hval
    have hnorm := congrArg (‖·‖) hval
    simp only [norm_mul, norm_chi, one_mul, norm_gaussC, sub_self, gaussWin_zero] at hnorm
    rw [show a - -a = 2 * a by ring] at hnorm
    have hlt : gaussWin s (2 * a) < 1 :=
      gaussWin_lt_one hs.ne' (by simpa using ha)
    rw [hnorm] at hlt
    exact absurd rfl (ne_of_lt hlt)

/-- **No scalar can repair the parity.**  Not only is the atom at `(-a,-b)` different from the
atom at `(a,b)`: the two are not even proportional.  For `a ≠ 0` the moduli of the two windows
are two distinct Gaussian bumps, and rescaling by `‖κ‖` can match them at one point only at the
cost of mismatching them at the mirror point; for `a = 0` the scalar is forced to be `1` and the
previous separation applies. -/
theorem gaborAtom_ne_const_smul_neg {s : ℝ} (hs : 0 < s) {a b : ℝ} (hab : a ≠ 0 ∨ b ≠ 0)
    (kap : ℂ) : (fun t => kap * gaborAtom s (-a) (-b) t) ≠ gaborAtom s a b := by
  intro h
  by_cases ha : a = 0
  · subst ha
    have h0 := congrFun h 0
    rw [gaborAtom_apply, gaborAtom_apply] at h0
    simp only [neg_zero, sub_zero, mul_zero, chi_zero, gaussC, gaussWin_zero,
      Complex.ofReal_one, mul_one] at h0
    refine gaborAtom_ne_neg hs hab (funext fun t => ?_)
    have ht := congrFun h t
    rw [h0, one_mul] at ht
    exact ht
  · have hn : ∀ t : ℝ, ‖kap‖ * gaussWin s (t + a) = gaussWin s (t - a) := by
      intro t
      have ht := congrArg (‖·‖) (congrFun h t)
      simp only [gaborAtom_apply, norm_mul, norm_chi, one_mul, norm_gaussC] at ht
      rw [show t - -a = t + a by ring] at ht
      exact ht
    have h1 := hn (-a)
    have h2 := hn a
    rw [neg_add_cancel, gaussWin_zero, mul_one] at h1
    rw [show a - a = 0 by ring, gaussWin_zero] at h2
    have hsym : gaussWin s (-a - a) = gaussWin s (a + a) := by
      simp only [gaussWin]
      ring_nf
    rw [hsym] at h1
    have hlt : gaussWin s (a + a) < 1 := gaussWin_lt_one hs.ne' (by intro hc; apply ha; linarith)
    have hpos : 0 < gaussWin s (a + a) := Real.exp_pos _
    rw [h1] at h2
    nlinarith

/-! ## The anomaly -/

/-- The central element `-1` of `SL₂(ℝ)` acts trivially on the upper half plane. -/
theorem neg_one_smul_upperHalfPlane (z : UpperHalfPlane) :
    (-1 : Matrix.SpecialLinearGroup (Fin 2) ℝ) • z = z := by
  apply UpperHalfPlane.ext
  rw [UpperHalfPlane.specialLinearGroup_apply]
  simp [Matrix.one_fin_two]

/-- `S²` acts trivially on phase space. -/
theorem fourierMat_sq_smul (z : UpperHalfPlane) : (fourierMat * fourierMat) • z = z := by
  rw [fourierMat_sq]
  exact neg_one_smul_upperHalfPlane z

/-- **The metaplectic anomaly.**  The phase-space transformation `S² = -1` is the identity on the
upper half plane, but the corresponding window operator `𝓕²` is the parity operator and moves
every Gabor atom that is not centred at the origin of phase space.  Hence the `SL₂(ℝ)` action on
phase space admits no lift to an honest action on windows: only the double cover acts. -/
theorem metaplectic_anomaly {s : ℝ} (hs : 0 < s) {a b : ℝ} (hab : a ≠ 0 ∨ b ≠ 0) :
    (∀ z : UpperHalfPlane, (fourierMat * fourierMat) • z = z) ∧
      𝓕 (𝓕 (gaborAtom s a b)) ≠ gaborAtom s a b := by
  refine ⟨fourierMat_sq_smul, ?_⟩
  rw [fourier_fourier_gaborAtom hs]
  exact gaborAtom_ne_neg hs hab

/-- **The anomaly is not a normalisation artefact.**  Even after rescaling `𝓕²` by an arbitrary
complex constant, the operator implementing `S² = -1` fails to be the identity on Gabor atoms off
the origin of phase space.  So the obstruction is a genuine *projective* one: no choice of
scalars along the lift can turn the phase-space action into an action on windows. -/
theorem metaplectic_anomaly_projective {s : ℝ} (hs : 0 < s) {a b : ℝ} (hab : a ≠ 0 ∨ b ≠ 0)
    (kap : ℂ) : (fun t => kap * 𝓕 (𝓕 (gaborAtom s a b)) t) ≠ gaborAtom s a b := by
  rw [fourier_fourier_gaborAtom hs]
  exact gaborAtom_ne_const_smul_neg hs hab kap

/-! ## The chirp automorphism is outer -/

/-- **The chirp automorphism is not inner.**  Conjugation inside `Heis` never changes the
modulation parameter, while the shear does; hence `Heis ⋊ ℝ` is not a direct product and the
chirp is a genuinely new generator. -/
theorem chirpShear_not_inner {c : ℝ} (hc : c ≠ 0) :
    ¬ ∃ h : Heis, ∀ g : Heis, chirpShear c g = h * g * h⁻¹ := by
  rintro ⟨h, hh⟩
  have hg := hh ⟨1, 0, 1⟩
  have hb := congrArg Heis.b hg
  simp only [chirpShear_b, Heis.mul_b, Heis.inv_b] at hb
  norm_num at hb
  exact hc hb

/-! ## The discrete (lattice) anomaly -/

/-- The integer Heisenberg lattice: the phase-space points supporting a discrete,
multiset-indexed Gabor transform. -/
def heisLattice : Set Heis := {g | (∃ m : ℤ, g.a = m) ∧ ∃ n : ℤ, g.b = n}

/-- **The discrete metaplectic anomaly.**  The chirp shear preserves the integer Heisenberg
lattice exactly when `2c` is an integer: the continuous theory has a full one-parameter group of
chirps, the discrete one only a lattice of them. -/
theorem chirpShear_mapsTo_heisLattice_iff (c : ℝ) :
    (∀ g ∈ heisLattice, chirpShear c g ∈ heisLattice) ↔ ∃ n : ℤ, 2 * c = n := by
  constructor
  · intro h
    have hg : (⟨1, 0, 1⟩ : Heis) ∈ heisLattice := ⟨⟨1, by norm_num⟩, ⟨0, by norm_num⟩⟩
    obtain ⟨-, n, hn⟩ := h _ hg
    exact ⟨n, by simpa using hn⟩
  · rintro ⟨n, hn⟩ g ⟨⟨m, hm⟩, ⟨k, hk⟩⟩
    refine ⟨⟨m, hm⟩, ⟨k + n * m, ?_⟩⟩
    rw [chirpShear_b, hk, hm, show 2 * c * (m : ℝ) = (2 * c) * (m : ℝ) by ring, hn]
    push_cast
    ring

/-! ## The chirped family is genuinely larger -/

/-- **A chirped Gaussian window is never a real Gaussian window.**  The catalog's family
`s ↦ gaussC s` is not stable under the metaplectic action, which is exactly why the chirped
family `gaussChirp` is needed to carry an `SL₂(ℝ)`-equivariant structure. -/
theorem chirpOp_gaussC_ne_gaussC {c : ℝ} (hc : c ≠ 0) (s s' : ℝ) :
    chirpOp c (gaussC s) ≠ gaussC s' := by
  intro h
  set t : ℝ := Real.sqrt (1 / (4 * |c|)) with ht
  have hcpos : 0 < |c| := abs_pos.mpr hc
  have ht2 : t ^ 2 = 1 / (4 * |c|) := Real.sq_sqrt (by positivity)
  have hval := congrFun h t
  rw [chirpOp] at hval
  have him := congrArg Complex.im hval
  rw [gaussC, gaussC, Complex.ofReal_im] at him
  have hgauss : (0 : ℝ) < gaussWin s t := gaussWin_pos s t
  simp only [Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, mul_zero] at him
  rcases lt_or_gt_of_ne hc with hneg | hpos
  · have habs : |c| = -c := abs_of_neg hneg
    have harg : c * t ^ 2 = -(1 / 4) := by
      rw [ht2, habs]
      field_simp
    rw [harg, chi_neg_quarter_im] at him
    nlinarith [hgauss]
  · have habs : |c| = c := abs_of_pos hpos
    have harg : c * t ^ 2 = 1 / 4 := by
      rw [ht2, habs]
      field_simp
    rw [harg, chi_quarter_im] at him
    nlinarith [hgauss]

end SmoothWindows