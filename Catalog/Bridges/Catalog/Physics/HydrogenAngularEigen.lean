import Mathlib
import Physics.AngularMomentum

/-!
# Hydrogen Atom: Azimuthal Functions as `Lz` Eigenfunctions

The azimuthal factor `e^{imφ}` of the spherical harmonics (`azimuthalExp` in
`Physics.AngularMomentum`) is an eigenfunction of the `z`-component of orbital
angular momentum `Lz = -i ∂/∂φ`, with eigenvalue equal to the magnetic quantum
number `m`:

  `Lz (e^{imφ}) = m · e^{imφ}`.

This is the analytic counterpart of the matrix eigenvalue statement
`Lz_matrix` in `Physics.AngularMomentum`, and it is precisely why `m` is called
the *magnetic quantum number*.

## Lab Notes

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The azimuthal eigenfunctions diagonalize `Lz`; the
eigenvalue is exactly the integer `m`, quantized by the `2π`-periodicity already
proven (`azimuthal_eigenfunction_periodic`).

Experiment (Experimenter): Computed `HasDerivAt (azimuthalExp m)` via the chain
rule on `Complex.exp`, then applied `Lz = -i d/dφ` to read off the eigenvalue.

Analysis (Analyst): The eigenvalue equation is a direct derivative computation;
the subtlety is purely bookkeeping of the `ℝ → ℂ` coercion in the exponent. This
links the differential (`-i ∂φ`) and matrix (`Lz_matrix`) pictures of the same
operator.

Critique (Critic): Eigenvalue read off symbolically (not numerically), valid for
every integer `m`; the derivative lemma is stated independently so it can be
reused.

Synthesis (PI): Completes the "spherical harmonics as angular-momentum
eigenfunctions" deliverable on the azimuthal factor.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Complex

namespace HydrogenAngularEigen

/-- The derivative of the azimuthal eigenfunction `e^{imφ}` with respect to `φ`
is `i·m·e^{imφ}`. -/
theorem azimuthalExp_hasDerivAt (m : ℤ) (φ : ℝ) :
    HasDerivAt (azimuthalExp m)
      ((m : ℂ) * Complex.I * azimuthalExp m φ) φ := by
  unfold azimuthalExp
  have hg : HasDerivAt (fun φ : ℝ => (↑(m * φ) : ℂ) * Complex.I)
      ((m : ℂ) * Complex.I) φ := by
    have : HasDerivAt (fun φ : ℝ => (↑(m * φ) : ℂ)) ((m : ℂ)) φ := by
      have h2 : HasDerivAt (fun φ : ℝ => ((m : ℝ) * φ)) ((m : ℝ)) φ := by
        simpa using (hasDerivAt_id φ).const_mul (m : ℝ)
      have := h2.ofReal_comp
      push_cast at this ⊢
      convert this using 2
    simpa using this.mul_const Complex.I
  have := (Complex.hasDerivAt_exp (↑(m * φ) * Complex.I)).comp φ hg
  convert this using 1
  ring

/-- **`Lz` eigenvalue equation.** Applying `Lz = -i ∂/∂φ` to the azimuthal
eigenfunction returns it scaled by the magnetic quantum number `m`:
`-i · d/dφ (e^{imφ}) = m · e^{imφ}`. -/
theorem Lz_eigenvalue (m : ℤ) (φ : ℝ) :
    -Complex.I * deriv (azimuthalExp m) φ = (m : ℂ) * azimuthalExp m φ := by
  rw [(azimuthalExp_hasDerivAt m φ).deriv]
  ring_nf
  rw [Complex.I_sq]
  ring

end HydrogenAngularEigen