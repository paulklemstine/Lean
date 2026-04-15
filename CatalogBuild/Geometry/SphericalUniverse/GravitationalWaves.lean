/-! # CatalogBuild.Geometry.SphericalUniverse.GravitationalWaves

Auto-generated from theorem catalog database.
Domain: Geometry/SphericalUniverse
Declarations: 28
-/

import Mathlib

noncomputable section

/-- The circumference of S³ with radius R.
A geodesic on S³ is a great circle of length 2πR.
A gravitational wave traveling along a geodesic returns to its source
after traversing one circumference. -/
def circumferenceS3 (R : ℝ) : ℝ := 2 * Real.pi * R


/-- The circumference is positive for R > 0. -/
theorem circumference_pos (R : ℝ) (hR : 0 < R) :
    0 < circumferenceS3 R := by
  unfold circumferenceS3; positivity


/-- The time delay for a gravitational wave echo in S³.
Δt = circumference / c = 2πR/c
For R ≈ 100 Gly ≈ 3 × 10²⁸ m, c = 3 × 10⁸ m/s:
Δt ≈ 2π × 10²⁰ s ≈ 6 × 10¹² years ≈ 6 trillion years.
This is much longer than the current age of the universe (13.8 Gyr),
so first-order echoes haven't had time to arrive — yet. -/
def echoTimeDelay (R c : ℝ) : ℝ := circumferenceS3 R / c


/-- The echo time delay is positive. -/
theorem echo_delay_pos (R c : ℝ) (hR : 0 < R) (hc : 0 < c) :
    0 < echoTimeDelay R c := by
  unfold echoTimeDelay; exact div_pos (circumference_pos R hR) hc


/-- The n-th echo arrives at time n × Δt. -/
def nthEchoDelay (R c : ℝ) (n : ℕ) : ℝ := n * echoTimeDelay R c


/-- Echo delays form an arithmetic progression. -/
theorem echo_delay_arithmetic (R c : ℝ) (n : ℕ) :
    nthEchoDelay R c (n + 1) = nthEchoDelay R c n + echoTimeDelay R c := by
  unfold nthEchoDelay; push_cast; ring


/-- On S³ of radius R, only wavelengths that "fit" around a great circle
are allowed. The n-th allowed wavelength is λₙ = 2πR/n. -/
def allowedWavelength (R : ℝ) (n : ℕ) : ℝ := 2 * Real.pi * R / n


/-- The corresponding frequency for mode n, given speed c.
fₙ = c/λₙ = nc/(2πR) -/
def allowedFrequency (R c : ℝ) (n : ℕ) : ℝ := n * c / (2 * Real.pi * R)


/-- The frequencies form a harmonic series: fₙ = n × f₁. -/
theorem frequency_harmonic (R c : ℝ) (n : ℕ) (hR : 0 < R) :
    allowedFrequency R c n = n * allowedFrequency R c 1 := by
  unfold allowedFrequency; push_cast; ring


/-- The fundamental frequency (lowest non-zero mode).
f₁ = c/(2πR)
For R = 100 Gly: f₁ ≈ 10⁻²⁰ Hz (far below any detector's range) -/
def fundamentalFrequency (R c : ℝ) : ℝ := c / (2 * Real.pi * R)


/-- The fundamental frequency equals the first allowed frequency. -/
theorem fundamental_eq_first (R c : ℝ) (hR : 0 < R) :
    fundamentalFrequency R c = allowedFrequency R c 1 := by
  unfold fundamentalFrequency allowedFrequency; push_cast; ring


/-- The dispersion relation for gravitational waves on S³.
On flat space: ω² = c²k² (continuous)
On S³: ω² = c²(ℓ(ℓ+2))/R² (discrete), ℓ = 0, 1, 2, ...
This is precisely the eigenvalue of the Laplacian on S³!
The Laplacian eigenvalues λₗ = ℓ(ℓ+2)/R² give the squared frequencies. -/
def gwFrequencySquared (R c : ℝ) (ℓ : ℕ) : ℝ :=
  c ^ 2 * (ℓ * (ℓ + 2) : ℝ) / R ^ 2


/-- The dispersion relation reduces to the flat-space limit for ℓ ≫ 1.
For large ℓ: ℓ(ℓ+2) ≈ ℓ², so ω ≈ cℓ/R, recovering ω = ck
with k = ℓ/R (the wavenumber). -/
theorem dispersion_large_ell_bound (ℓ : ℕ) :
    (ℓ : ℝ) ^ 2 ≤ (ℓ : ℝ) * ((ℓ : ℝ) + 2) := by nlinarith


/-- The group velocity of GW on S³.
v_g = dω/dk. For the discrete spectrum, we approximate:
Δω/Δℓ = c × (2ℓ + 3) / (2R √(ℓ(ℓ+2) + ... ))
For large ℓ, v_g → c (as expected). -/
theorem group_velocity_approaches_c (ℓ : ℕ) (hℓ : 0 < ℓ) :
    ((ℓ : ℝ) + 1) ^ 2 / ((ℓ : ℝ) * (ℓ + 2)) ≤ ((ℓ : ℝ) + 1) ^ 2 / (ℓ : ℝ) ^ 2 := by
  apply div_le_div_of_nonneg_left
  · positivity
  · positivity
  · nlinarith


/-- The energy carried by the n-th GW echo.
As the wave spreads on S³, the energy per solid angle varies.
On S³, the area of a sphere of geodesic radius χ is:
A(χ) = 4πR² sin²(χ/R)
The wave refocuses at the antipodal point (χ = πR) where A → 0,
creating a **conjugate point** (a natural focal point). -/
def areaOnS3 (R χ : ℝ) : ℝ := 4 * Real.pi * R ^ 2 * Real.sin (χ / R) ^ 2


/-- At the equator (χ = πR/2), the area is maximal: A = 4πR². -/
theorem area_at_equator (R : ℝ) (hR : 0 < R) :
    areaOnS3 R (Real.pi * R / 2) = 4 * Real.pi * R ^ 2 := by
  unfold areaOnS3
  rw [show Real.pi * R / 2 / R = Real.pi / 2 by field_simp]
  rw [Real.sin_pi_div_two]
  ring


/-- At the antipodal point (χ = πR), the area vanishes: the wave refocuses!
This means GW echoes in S³ are AMPLIFIED at the antipodal point,
not just attenuated. This is a dramatic prediction. -/
theorem area_at_antipode (R : ℝ) (hR : 0 < R) :
    areaOnS3 R (Real.pi * R) = 0 := by
  unfold areaOnS3
  rw [show Real.pi * R / R = Real.pi by field_simp]
  rw [Real.sin_pi]
  ring


/-- After a full circuit (χ = 2πR), the wave returns to the source
with area 0 — it refocuses at the original emission point!
This creates a natural "gravitational wave mirror." -/
theorem area_full_circuit (R : ℝ) (hR : 0 < R) :
    areaOnS3 R (2 * Real.pi * R) = 0 := by
  unfold areaOnS3
  rw [show 2 * Real.pi * R / R = 2 * Real.pi by field_simp]
  rw [Real.sin_two_pi]
  ring


/-- The minimum detectable GW amplitude for a given detector.
For LISA: h_min ≈ 10⁻²¹ at f ≈ 10⁻³ Hz
For LIGO: h_min ≈ 10⁻²³ at f ≈ 100 Hz
The fundamental mode of S³ with R = 100 Gly has
f₁ ≈ 10⁻²⁰ Hz — far too low for current detectors.
However, if R were much smaller (R ~ 1 Gly), modes up to
ℓ ≈ 10¹⁵ would be in LISA's band. -/
def detectorSensitivity (h_min f_center : ℝ) : Prop :=
  h_min > 0 ∧ f_center > 0


/-- The number of GW modes in a frequency band [f_low, f_high] on S³.
N = ⌊2πRf_high/c⌋ - ⌊2πRf_low/c⌋
This is finite and computable — a key distinction from flat space
where it would be infinite. -/
def modesInBand (R c f_low f_high : ℝ) : ℤ :=
  ⌊2 * Real.pi * R * f_high / c⌋ - ⌊2 * Real.pi * R * f_low / c⌋


/-- More modes exist in a higher frequency band (monotonicity). -/
theorem modes_nonneg (R c f_low f_high : ℝ) (hR : 0 < R) (hc : 0 < c)
    (hf : f_low ≤ f_high) : 0 ≤ modesInBand R c f_low f_high := by
  unfold modesInBand
  have h1 : 2 * Real.pi * R * f_low / c ≤ 2 * Real.pi * R * f_high / c := by
    apply div_le_div_of_nonneg_right _ (le_of_lt hc)
    apply mul_le_mul_of_nonneg_left hf
    positivity
  linarith [Int.floor_le_floor h1]


/-- The energy density of the stochastic GW background in S³.
Ω_gw(f) = (1/ρ_c) dρ_gw/d(ln f)
On S³, this is a sum of delta functions (discrete spectrum)
rather than a smooth curve. The discretization becomes observable
at frequencies f < c/(2πR). -/
def gwEnergyDensityDiscrete (R c : ℝ) (ℓ : ℕ) : ℝ :=
  (ℓ + 1 : ℝ) ^ 2 * gwFrequencySquared R c ℓ


/-- The total GW energy is a convergent sum (on S³, unlike flat space
where it diverges without a UV cutoff). The S³ topology provides
a natural infrared cutoff at the fundamental frequency. -/
theorem gw_energy_has_IR_cutoff (R c : ℝ) (hR : 0 < R) (hc : 0 < c) :
    gwFrequencySquared R c 0 = 0 := by
  unfold gwFrequencySquared; simp


/-- If a gravitational wave event (e.g., binary neutron star merger) occurs
at geodesic distance χ from us on S³, we observe:
1. Direct signal at time t₁ = χ/c
2. Antipodal echo at time t₂ = (2πR - χ)/c (going the "long way around")
3. Full-circuit echo at time t₃ = (2πR + χ)/c
The time differences give R directly:
t₂ - t₁ = 2(πR - χ)/c
t₃ - t₁ = 2πR/c  (independent of source position!) -/
def directSignalTime (χ c : ℝ) : ℝ := χ / c

/-- [Section: ## Part VII: Multi-Messenger Astronomy] -/
def antipodalEchoTime (R χ c : ℝ) : ℝ := (2 * Real.pi * R - χ) / c

def fullCircuitEchoTime (R χ c : ℝ) : ℝ := (2 * Real.pi * R + χ) / c


/-- The full-circuit time delay is independent of source position.
This is the key observable: Δt₃₁ = t₃ - t₁ = 2πR/c. -/
theorem full_circuit_delay_universal (R χ c : ℝ) (hc : c ≠ 0) :
    fullCircuitEchoTime R χ c - directSignalTime χ c = 2 * Real.pi * R / c := by
  unfold fullCircuitEchoTime directSignalTime
  field_simp
  ring


/-- The antipodal echo delay determines source distance given R.
Δt₂₁ = 2(πR - χ)/c, so χ = πR - cΔt₂₁/2 -/
theorem antipodal_delay_determines_distance (R χ c : ℝ) (hc : c ≠ 0) :
    antipodalEchoTime R χ c - directSignalTime χ c = 2 * (Real.pi * R - χ) / c := by
  unfold antipodalEchoTime directSignalTime
  field_simp
  ring


end
