/-
# The Topology of Knotted Light: Winding Number of Orbital-Angular-Momentum Beams

A laser beam carrying orbital angular momentum (OAM) — "knotted light" — has an
azimuthal phase factor `exp(i ℓ θ)`, where the integer `ℓ` is the *topological
charge* of the phase singularity on the beam axis. Physically, `ℓ` counts how many
times the wavefront twists around per wavelength, and it is a robust topological
invariant of the field.

This file gives a self-contained formalization of the topological charge of an OAM
phase field as a genuine **winding number**, defined through the classical contour
integral

        w(φ) = (1 / 2πi) ∮ φ'(θ)/φ(θ) dθ .

## Main results

* `winding_oamPhase`     : the winding number of `exp(i ℓ θ)` is exactly `ℓ`
                           (the deep theorem — charge is the contour integral).
* `winding_quantized`    : the topological charge is always an integer (quantization).
* `oamPhase_mul`         : superposing (multiplying) beams adds their charges.
* `oamPhase_prod`        : conservation of total charge over a family of beams.
* `winding_additive`     : the winding number is additive under charge addition.
* `oamPhase_periodic`    : the phase field is single-valued (2π-periodic).
* `beamAmp_vanishes` /
  `beamAmp_nonzero`      : the amplitude vanishes exactly on the axis (phase
                           singularity) iff the charge is nonzero.

## Contrarian conjectures (v26)

* `winding_can_be_negative` — DISPROOF of "topological charge is always
  nonnegative": vortices of both handedness exist (`ℓ = -1`).
* `oam_annihilation` — DISPROOF of "a product of two vortex beams is again a
  vortex beam": beams of opposite charge `±ℓ` multiply to a nonvanishing constant
  field of winding `0` (the singularities annihilate).
-/
import Mathlib

open Complex

namespace KnottedLight

/-- The azimuthal phase field of an OAM beam of topological charge `ℓ`:
`θ ↦ exp(i ℓ θ)`. -/
noncomputable def oamPhase (ℓ : ℤ) (θ : ℝ) : ℂ := Complex.exp ((ℓ : ℂ) * θ * Complex.I)

/-- The physical (Laguerre–Gauss–like) amplitude profile, radial factor `r^{|ℓ|}`
times the phase. It vanishes on the axis `r = 0` when `ℓ ≠ 0`, giving the phase
singularity of knotted light. -/
noncomputable def beamAmp (ℓ : ℤ) (r θ : ℝ) : ℂ := (r ^ (ℓ.natAbs) : ℝ) * oamPhase ℓ θ

/-- The winding number of a loop `φ : ℝ → ℂ` computed over one full turn
`θ ∈ [0, 2π]` via the logarithmic-derivative contour integral. -/
noncomputable def winding (φ : ℝ → ℂ) : ℂ :=
  (1 / (2 * Real.pi * Complex.I)) * ∫ θ in (0:ℝ)..(2 * Real.pi), deriv φ θ / φ θ

/-! ## Basic algebra of OAM phases -/

@[simp] theorem oamPhase_zero (θ : ℝ) : oamPhase 0 θ = 1 := by simp [oamPhase]

/-- Superposition of beams by multiplication adds their topological charges. -/
theorem oamPhase_mul (ℓ m : ℤ) (θ : ℝ) :
    oamPhase ℓ θ * oamPhase m θ = oamPhase (ℓ + m) θ := by
  unfold oamPhase
  rw [← Complex.exp_add]; push_cast; ring_nf

/-- Beams of opposite charge multiply to the trivial (constant, singularity-free)
field. -/
theorem oamPhase_opposite (ℓ : ℤ) (θ : ℝ) : oamPhase ℓ θ * oamPhase (-ℓ) θ = 1 := by
  rw [oamPhase_mul]; simp

/-- Total-charge conservation: multiplying a whole family of OAM beams produces a
beam whose charge is the sum of the individual charges. -/
theorem oamPhase_prod {ι : Type*} [DecidableEq ι] (s : Finset ι) (f : ι → ℤ) (θ : ℝ) :
    (∏ i ∈ s, oamPhase (f i) θ) = oamPhase (∑ i ∈ s, f i) θ := by
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
    rw [Finset.prod_insert ha, Finset.sum_insert ha, ih, oamPhase_mul]

/-- The OAM phase field is single-valued: it is invariant under a full `2π` turn.
This is exactly why the charge `ℓ` must be an integer. -/
theorem oamPhase_periodic (ℓ : ℤ) (θ : ℝ) :
    oamPhase ℓ (θ + 2 * Real.pi) = oamPhase ℓ θ := by
  unfold oamPhase
  have h : ((ℓ : ℂ) * ((θ + 2 * Real.pi : ℝ) : ℂ) * Complex.I)
      = ((ℓ : ℂ) * θ * Complex.I) + (ℓ : ℂ) * (2 * Real.pi * Complex.I) := by
    push_cast; ring
  rw [h, Complex.exp_add, Complex.exp_int_mul_two_pi_mul_I, mul_one]

/-! ## The amplitude vanishes exactly on the vortex axis -/

/-- A beam with nonzero charge has an amplitude zero on the axis: the phase
singularity of knotted light. -/
theorem beamAmp_vanishes (ℓ : ℤ) (hℓ : ℓ ≠ 0) (θ : ℝ) : beamAmp ℓ 0 θ = 0 := by
  unfold beamAmp
  have : ℓ.natAbs ≠ 0 := by simpa [Int.natAbs_eq_zero] using hℓ
  simp [zero_pow this]

/-- Off the axis the amplitude never vanishes. -/
theorem beamAmp_nonzero (ℓ : ℤ) (r θ : ℝ) (hr : 0 < r) : beamAmp ℓ r θ ≠ 0 := by
  unfold beamAmp oamPhase
  exact mul_ne_zero (by exact_mod_cast (pow_pos hr _).ne') (Complex.exp_ne_zero _)

/-! ## The winding number of an OAM beam is its charge -/

/-- The phase field is differentiable, with derivative `i ℓ · exp(i ℓ θ)`. -/
theorem oamPhase_hasDerivAt (ℓ : ℤ) (θ : ℝ) :
    HasDerivAt (oamPhase ℓ) ((ℓ : ℂ) * Complex.I * oamPhase ℓ θ) θ := by
  unfold oamPhase
  have h1 : HasDerivAt (fun t : ℝ => (ℓ : ℂ) * t * Complex.I) ((ℓ : ℂ) * Complex.I) θ := by
    have hid : HasDerivAt (fun t : ℝ => (t : ℂ)) (1 : ℂ) θ := by
      simpa using Complex.ofRealCLM.hasDerivAt
    have h := ((hasDerivAt_const θ (ℓ : ℂ)).mul hid).mul_const Complex.I
    simpa using h
  have h2 := (Complex.hasDerivAt_exp ((ℓ : ℂ) * θ * Complex.I)).comp θ h1
  simpa [mul_comm, mul_left_comm, mul_assoc] using h2

theorem oamPhase_deriv (ℓ : ℤ) (θ : ℝ) :
    deriv (oamPhase ℓ) θ = (ℓ : ℂ) * Complex.I * oamPhase ℓ θ :=
  (oamPhase_hasDerivAt ℓ θ).deriv

/-- **Topological charge = winding number.** The contour-integral winding number of
`exp(i ℓ θ)` is exactly the integer charge `ℓ`. -/
theorem winding_oamPhase (ℓ : ℤ) : winding (oamPhase ℓ) = (ℓ : ℂ) := by
  unfold winding
  have hint : ∀ θ ∈ Set.uIcc (0 : ℝ) (2 * Real.pi),
      deriv (oamPhase ℓ) θ / oamPhase ℓ θ = (ℓ : ℂ) * Complex.I := by
    intro θ _
    rw [oamPhase_deriv, mul_div_assoc,
      div_self (by unfold oamPhase; exact Complex.exp_ne_zero _)]
    ring
  rw [intervalIntegral.integral_congr hint, intervalIntegral.integral_const,
    Complex.real_smul]
  have hpi : (Real.pi : ℂ) ≠ 0 := by exact_mod_cast Real.pi_ne_zero
  have hI : Complex.I ≠ 0 := Complex.I_ne_zero
  push_cast
  field_simp
  ring

/-- **Charge quantization.** The topological charge is always an integer. -/
theorem winding_quantized (ℓ : ℤ) : ∃ n : ℤ, winding (oamPhase ℓ) = (n : ℂ) :=
  ⟨ℓ, winding_oamPhase ℓ⟩

/-- **Additivity of the winding number** under superposition of charges. -/
theorem winding_additive (ℓ m : ℤ) :
    winding (oamPhase (ℓ + m)) = winding (oamPhase ℓ) + winding (oamPhase m) := by
  rw [winding_oamPhase, winding_oamPhase, winding_oamPhase]; push_cast; ring

/-- The winding number of a constant loop is `0`. -/
theorem winding_const (c : ℂ) : winding (fun _ => c) = 0 := by
  unfold winding; simp

/-! ## Contrarian conjectures (v26) -/

/-- **DISPROOF** of the bold conjecture *"the topological charge of light is always
nonnegative."* Optical vortices come in both handednesses: the charge `ℓ = -1`
beam has winding number `-1`. -/
theorem winding_can_be_negative : ¬ ∀ ℓ : ℤ, 0 ≤ (winding (oamPhase ℓ)).re := by
  intro h
  have := h (-1)
  rw [winding_oamPhase] at this
  norm_num at this

/-- **DISPROOF** of the bold conjecture *"a product of two vortex beams is again a
vortex beam."* Two beams of opposite charge `±ℓ` combine into a nonvanishing
constant field whose winding number is `0`: the singularities annihilate. -/
theorem oam_annihilation (ℓ : ℤ) :
    winding (fun θ => oamPhase ℓ θ * oamPhase (-ℓ) θ) = 0 := by
  have hfun : (fun θ => oamPhase ℓ θ * oamPhase (-ℓ) θ) = fun _ => (1 : ℂ) :=
    funext (oamPhase_opposite ℓ)
  rw [hfun]; exact winding_const 1

/-- The annihilated field is genuinely singularity-free: its amplitude never
vanishes, unlike either factor when `ℓ ≠ 0`. -/
theorem oam_annihilation_nonvanishing (ℓ : ℤ) (θ : ℝ) :
    oamPhase ℓ θ * oamPhase (-ℓ) θ ≠ 0 := by
  rw [oamPhase_opposite]; exact one_ne_zero

end KnottedLight