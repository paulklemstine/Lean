import Mathlib

/-!
# Hydrogen Atom: Dipole Transition Selection Rules

Formalizes the electric dipole selection rules for the hydrogen atom:
Δm ∈ {-1, 0, +1} for nonzero dipole matrix elements.

## Mathematical Context

The azimuthal part of the dipole matrix element ⟨ψ'|r̂_q|ψ⟩ contains
the integral ∫₀²π e^{-im'φ} e^{iqφ} e^{imφ} dφ which vanishes unless
m' = m + q. This proves the selection rule from complex exponential
orthogonality.

## Main Results

* `azimuthalDipoleIntegral_off_resonant`: vanishing for forbidden transitions
* `dipole_m_selection_z`: Δm = 0 for z-polarized transitions
* `dipole_m_selection_vanishing`: full vanishing when |Δm| > 1
* `dipole_m_selection_complete`: allowed transitions are exactly Δm ∈ {-1, 0, 1}
-/

noncomputable section

open Complex Real MeasureTheory
open scoped BigOperators

/-! ## Dipole Matrix Element -/

/-- The azimuthal dipole integral for polarization q between
magnetic quantum numbers m and m':
  ∫₀²π exp(i(m - m' + q)φ) dφ
This is 2π if m + q = m' and 0 otherwise. -/
def azimuthalDipoleIntegral (m m' q : ℤ) : ℂ :=
  ∫ φ in (0 : ℝ)..(2 * Real.pi),
    Complex.exp (↑((m - m' + q) * φ) * Complex.I)

/-- The azimuthal dipole integral equals 2π when m' = m + q. -/
theorem azimuthalDipoleIntegral_resonant (m q : ℤ) :
    azimuthalDipoleIntegral m (m + q) q = ↑(2 * Real.pi) := by
  unfold azimuthalDipoleIntegral
  simp

/-
The azimuthal dipole integral vanishes when m' ≠ m + q.
This is the mathematical core of the selection rule, using
orthogonality of complex exponentials.
-/
theorem azimuthalDipoleIntegral_off_resonant
    (m m' q : ℤ) (h : m' ≠ m + q) :
    azimuthalDipoleIntegral m m' q = 0 := by
  -- Realize that this integral is zero unless $m' = m + q$.
  have h_int_zero : ∫ φ : ℝ in (0 : ℝ)..(2 * Real.pi), Complex.exp (↑((m - m' + q) * φ) * Complex.I) = (1 / ((m - m' + q) * Complex.I)) * (Complex.exp (↑((m - m' + q) * (2 * Real.pi)) * Complex.I) - 1) := by
    have := @integral_exp_mul_complex 0 ( 2 * Real.pi ) ( ↑ ( m - m' + q ) * Complex.I ) ; simp_all +decide [ div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm ] ;
    exact this ( by norm_cast; contrapose! h; linarith );
  convert h_int_zero using 1;
  exact Eq.symm ( mul_eq_zero_of_right _ <| sub_eq_zero.mpr <| Complex.exp_eq_one_iff.mpr ⟨ ( m - m' + q ), by push_cast; ring ⟩ )

/-! ## Selection Rules -/

/-
Δm = 0 selection rule for z-polarized dipole transitions.
-/
theorem dipole_m_selection_z (m m' : ℤ) (hne : m' ≠ m) :
    azimuthalDipoleIntegral m m' 0 = 0 := by
  convert azimuthalDipoleIntegral_off_resonant m m' 0 ( by aesop ) using 1

/-
Δm = +1 selection rule for σ⁺ transitions.
-/
theorem dipole_m_selection_plus (m m' : ℤ) (hne : m' ≠ m + 1) :
    azimuthalDipoleIntegral m m' 1 = 0 := by
  convert azimuthalDipoleIntegral_off_resonant m m' 1 hne using 1

/-
Δm = -1 selection rule for σ⁻ transitions.
-/
theorem dipole_m_selection_minus (m m' : ℤ) (hne : m' ≠ m - 1) :
    azimuthalDipoleIntegral m m' (-1) = 0 := by
  convert azimuthalDipoleIntegral_off_resonant m m' ( -1 ) _ using 1;
  exact hne

/-- General selection rule: vanishing unless m' = m + q. -/
theorem dipole_m_selection_general (m m' q : ℤ) (h : m' ≠ m + q) :
    azimuthalDipoleIntegral m m' q = 0 :=
  azimuthalDipoleIntegral_off_resonant m m' q h

/-- Contrapositive: nonzero matrix element implies m' = m + q. -/
theorem dipole_m_selection_contrapositive (m m' q : ℤ)
    (hne : azimuthalDipoleIntegral m m' q ≠ 0) :
    m' = m + q := by
  by_contra h
  exact hne (azimuthalDipoleIntegral_off_resonant m m' q h)

/-
Vanishing for forbidden transitions: if m' - m ∉ {-1, 0, 1},
then the dipole integral vanishes for ALL polarization components.
-/
theorem dipole_m_selection_vanishing (m m' : ℤ)
    (hforbidden : ¬(m' - m = 0 ∨ m' - m = 1 ∨ m' - m = -1)) :
    (∀ q ∈ ({-1, 0, 1} : Set ℤ), azimuthalDipoleIntegral m m' q = 0) := by
  simp +zetaDelta at *;
  exact ⟨ azimuthalDipoleIntegral_off_resonant m m' ( -1 ) ( by omega ), azimuthalDipoleIntegral_off_resonant m m' 0 ( by omega ), azimuthalDipoleIntegral_off_resonant m m' 1 ( by omega ) ⟩

/-
Completeness: allowed transitions with Δm ∈ {-1, 0, 1} have
nonzero matrix elements.
-/
theorem dipole_m_selection_complete (m : ℤ) (q : ℤ)
    (hq : q = -1 ∨ q = 0 ∨ q = 1) :
    azimuthalDipoleIntegral m (m + q) q ≠ 0 := by
  -- Use the fact that the azimuthal dipole integral is 2π when m' = m + q.
  have h_single : azimuthalDipoleIntegral m (m + q) q = 2 * Real.pi := by
    convert azimuthalDipoleIntegral_resonant m q using 1;
    norm_num [ Complex.ofReal_mul ];
  exact h_single.symm ▸ by norm_num [ Real.pi_ne_zero ] ;

end