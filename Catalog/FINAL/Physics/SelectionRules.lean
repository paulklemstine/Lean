import Mathlib

/-!
# Hydrogen Atom: Dipole Transition Selection Rules

This file formalizes the electric dipole selection rules for the hydrogen atom:

- **Δm rule**: The magnetic quantum number must change by at most ±1
  for a nonzero dipole matrix element.

## Mathematical Context

The electric dipole operator for electromagnetic transitions has three
Cartesian components `x, y, z`. In spherical coordinates:
- `z = r cos θ` → involves `Y₁⁰(θ,φ)` ∝ `cos θ`
- `x = r sin θ cos φ` → involves `e^{iφ}` and `e^{-iφ}`
- `y = r sin θ sin φ` → involves `e^{iφ}` and `e^{-iφ}`

The azimuthal part of the matrix element `⟨ψ'|r̂_q|ψ⟩` contains
the integral `∫₀²π e^{-im'φ} f(φ) e^{imφ} dφ` where `f` is one of
`{1, e^{iφ}, e^{-iφ}}`. This integral vanishes unless `m' - m ∈ {0, ±1}`.

This file proves the selection rule from the orthogonality of complex
exponentials, which is the mathematical core of the selection rule.

## Key Results

* `dipole_m_selection_z`: Δm = 0 for z-polarized transitions
* `dipole_m_selection_plus`: Δm = +1 for σ⁺ transitions
* `dipole_m_selection_minus`: Δm = -1 for σ⁻ transitions
* `dipole_m_selection_vanishing`: matrix element vanishes when |Δm| > 1
-/

noncomputable section

open Complex Real MeasureTheory
open scoped BigOperators

/-! ## Dipole Matrix Element (Azimuthal Part)

The azimuthal part of the dipole matrix element for the three
polarization components `q ∈ {-1, 0, +1}` is:

  I_q(m', m) = ∫₀²π e^{-im'φ} e^{iqφ} e^{imφ} dφ
             = ∫₀²π e^{i(m - m' + q)φ} dφ

This equals `2π` if `m' = m + q` and `0` otherwise.
-/

/-- The azimuthal dipole integral for polarization `q` between
magnetic quantum numbers `m` and `m'`:
  `∫₀²π exp(i(m - m' + q)φ) dφ`
This is `2π` if `m + q = m'` and `0` otherwise. -/
def azimuthalDipoleIntegral (m m' q : ℤ) : ℂ :=
  ∫ φ in (0 : ℝ)..(2 * Real.pi),
    Complex.exp (↑((m - m' + q) * φ) * Complex.I)

/-
The azimuthal dipole integral equals `2π` when `m' = m + q`.
-/
theorem azimuthalDipoleIntegral_resonant (m q : ℤ) :
    azimuthalDipoleIntegral m (m + q) q = ↑(2 * Real.pi) := by
  unfold azimuthalDipoleIntegral;
  simp

/-
The azimuthal dipole integral vanishes when `m' ≠ m + q`.
-/
theorem azimuthalDipoleIntegral_off_resonant
    (m m' q : ℤ) (h : m' ≠ m + q) :
    azimuthalDipoleIntegral m m' q = 0 := by
  convert integral_exp_mul_complex ?_ using 1;
  convert intervalIntegral.integral_congr fun x _ => ?_ using 3;
  rotate_left;
  rotate_left;
  exact ↑ ( m - m' + q ) * Complex.I;
  · exact mul_ne_zero ( Int.cast_ne_zero.mpr ( by contrapose! h; linarith ) ) Complex.I_ne_zero;
  · push_cast; ring;
  · rw [ Complex.exp_eq_one_iff.mpr ⟨ m - m' + q, by push_cast; ring ⟩ ] ; norm_num

/-! ## Selection Rule for the z-Component (q = 0)

For z-polarized light, the azimuthal integral requires `m' = m`,
i.e., Δm = 0. -/

/-
**Δm = 0 selection rule**: For z-polarized dipole transitions,
the azimuthal integral vanishes unless `m' = m`.
-/
theorem dipole_m_selection_z (m m' : ℤ) (hne : m' ≠ m) :
    azimuthalDipoleIntegral m m' 0 = 0 := by
  grind +suggestions

/-! ## Selection Rule for Circular Polarizations (q = ±1)

For right/left circularly polarized light, the azimuthal integral
requires `m' = m ± 1`, i.e., Δm = ±1. -/

/-
**Δm = +1 selection rule**: For σ⁺ transitions,
the azimuthal integral vanishes unless `m' = m + 1`.
-/
theorem dipole_m_selection_plus (m m' : ℤ) (hne : m' ≠ m + 1) :
    azimuthalDipoleIntegral m m' 1 = 0 := by
  exact?

/-
**Δm = -1 selection rule**: For σ⁻ transitions,
the azimuthal integral vanishes unless `m' = m - 1`.
-/
theorem dipole_m_selection_minus (m m' : ℤ) (hne : m' ≠ m - 1) :
    azimuthalDipoleIntegral m m' (-1) = 0 := by
  convert azimuthalDipoleIntegral_off_resonant m m' ( -1 ) _ using 1;
  exact hne

/-! ## Combined Selection Rule -/

/-- **Full Δm selection rule**: The azimuthal dipole integral for
any spherical polarization component `q ∈ {-1, 0, 1}` vanishes
unless `m' = m + q`. This is the fundamental selection rule for
the magnetic quantum number. -/
theorem dipole_m_selection_general (m m' q : ℤ) (h : m' ≠ m + q) :
    azimuthalDipoleIntegral m m' q = 0 :=
  azimuthalDipoleIntegral_off_resonant m m' q h

/-- **Contrapositive form of the selection rule**: If the azimuthal
dipole matrix element is nonzero, then the change in `m` must be
exactly `q`, i.e., `Δm = q ∈ {-1, 0, +1}`. -/
theorem dipole_m_selection_contrapositive (m m' q : ℤ)
    (hne : azimuthalDipoleIntegral m m' q ≠ 0) :
    m' = m + q := by
  by_contra h
  exact hne (azimuthalDipoleIntegral_off_resonant m m' q h)

/-
**Vanishing for forbidden transitions**: If `m' - m ∉ {-1, 0, 1}`,
then the azimuthal dipole integral vanishes for ALL polarization
components. This is the strong form of the selection rule.
-/
theorem dipole_m_selection_vanishing (m m' : ℤ)
    (hforbidden : ¬(m' - m = 0 ∨ m' - m = 1 ∨ m' - m = -1)) :
    (∀ q ∈ ({-1, 0, 1} : Set ℤ), azimuthalDipoleIntegral m m' q = 0) := by
  -- Apply the off_resonant theorem to each case.
  intro q hq
  apply azimuthalDipoleIntegral_off_resonant;
  grind

/-! ## Selection Rule Completeness -/

/-
The allowed transitions are exactly those with `Δm ∈ {-1, 0, 1}`:
for each such value there exists a nonzero matrix element.
-/
theorem dipole_m_selection_complete (m : ℤ) (q : ℤ) (hq : q = -1 ∨ q = 0 ∨ q = 1) :
    azimuthalDipoleIntegral m (m + q) q ≠ 0 := by
  exact azimuthalDipoleIntegral_resonant m q ▸ by norm_num [ Real.pi_ne_zero ] ;

end