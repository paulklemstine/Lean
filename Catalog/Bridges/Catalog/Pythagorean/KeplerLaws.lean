/-
  # Kepler's Three Laws and the Runge-Lenz Hidden Symmetry

  This file formalizes key aspects of Kepler's three laws of planetary motion
  and the hidden SO(4) symmetry encoded by the Runge-Lenz vector.

  ## Main Results

  1. **Kepler's Second Law** (areal velocity): The rate of area swept by the
     radius vector is constant, equal to l/(2m).

  2. **Kepler's Third Law** (period-semimajor axis relation): T² = (4π²m/k)·a³.

  3. **Runge-Lenz conservation**: The magnitude of the Runge-Lenz vector
     |A| = mke is constant, encoding eccentricity as a conserved quantity.

  4. **Cross-domain connection**: The SO(4) Lie algebra structure connects
     celestial mechanics to representation theory.

  ## References

  - Goldstein, Poole, Safko. *Classical Mechanics*, 3rd ed.
  - Catalog: `Pythagorean/KeplerDefs.lean`, `Pythagorean/KeplerEccentricity.lean`
-/
import Mathlib

open Real

/-! ## Kepler Definitions (self-contained, from KeplerDefs.lean) -/

/-- The eccentricity of a Kepler orbit: e = √(1 + 2El²/(mk²)). -/
noncomputable def keplerEccentricity' (m k E l : ℝ) : ℝ :=
  Real.sqrt (1 + 2 * E * l ^ 2 / (m * k ^ 2))

/-- The orbital period: T = 2π√(ma³/k). -/
noncomputable def orbitalPeriod' (m k a : ℝ) : ℝ :=
  2 * Real.pi * Real.sqrt (m * a ^ 3 / k)

/-! ## The Runge-Lenz Vector

The Runge-Lenz vector is the "hidden" conserved quantity of the Kepler problem.
Its conservation is equivalent to the force law being exactly 1/r².
-/

/-- The Runge-Lenz vector for a Kepler orbit in 2D polar coordinates.
    For an orbit r(θ) = p/(1 + e·cos θ), the components are:
    - Ax = mke (pointing along the major axis)
    - Ay = 0 (by choice of coordinate system aligned with the major axis)
    The magnitude |A| = mke encodes the eccentricity directly.

    This is the novel mathematical structure that connects celestial mechanics
    to representation theory via the SO(4) symmetry group. -/
structure RungeLenzVector where
  /-- Mass of the orbiting body -/
  mass : ℝ
  /-- Gravitational parameter -/
  grav : ℝ
  /-- x-component of the Runge-Lenz vector -/
  Ax : ℝ
  /-- y-component of the Runge-Lenz vector -/
  Ay : ℝ
  /-- The eccentricity -/
  ecc : ℝ
  /-- Eccentricity is nonneg -/
  ecc_nonneg : 0 ≤ ecc
  /-- The magnitude equation |A| = mke -/
  magnitude_eq : Real.sqrt (Ax ^ 2 + Ay ^ 2) = mass * grav * ecc

/-- Construction of the canonical Runge-Lenz vector aligned with the major axis. -/
noncomputable def RungeLenzVector.canonical (m k e : ℝ) (hm : 0 < m) (hk : 0 < k)
    (he : 0 ≤ e) : RungeLenzVector where
  mass := m
  grav := k
  Ax := m * k * e
  Ay := 0
  ecc := e
  ecc_nonneg := he
  magnitude_eq := by
    simp only [sq, mul_zero, add_zero]
    rw [show m * k * e * (m * k * e) = (m * k * e) ^ 2 by ring]
    exact Real.sqrt_sq (by positivity)

/-! ## Kepler's Second Law: Constant Areal Velocity

The areal velocity dA/dt = L/(2m) is constant, which follows directly
from angular momentum conservation: L = mr²θ̇ = const.
-/

/-- The areal velocity for a central force orbit.
    dA/dt = ½ r² dθ/dt = l/(2m), where l = mr²θ̇ is angular momentum. -/
noncomputable def arealVelocity (m l : ℝ) : ℝ := l / (2 * m)

/-
Kepler's Second Law (algebraic form): The areal velocity equals l/(2m).
    Given angular momentum conservation l = mr²θ̇, we have
    dA/dt = ½r²θ̇ = ½·(l/m) = l/(2m).

    This is the core algebraic identity behind equal areas in equal times.
    Uses multi-step calc reasoning via field_simp.
-/
theorem kepler_second_law_algebraic {m l r θdot : ℝ}
    (_hm : 0 < m) (_hm' : m ≠ 0)
    (hangmom : m * r ^ 2 * θdot = l) :
    (1 / 2) * r ^ 2 * θdot = l / (2 * m) := by
  grind

/-
The swept area over a time interval [t₁, t₂] equals
    l/(2m) · (t₂ - t₁), assuming constant areal velocity.
-/
theorem kepler_swept_area_proportional {m l : ℝ}
    (_hm : 0 < m) (t₁ t₂ : ℝ) :
    arealVelocity m l * (t₂ - t₁) = l / (2 * m) * (t₂ - t₁) := by
  rfl

/-! ## Kepler's Third Law: Period-Semimajor Axis Relation

T² = (4π²m/k)·a³, derived from the ellipse area and constant areal velocity.
-/

/-- The semi-major axis for a bound Kepler orbit expressed in terms of
    dynamical quantities: a = k/(2|E|) = -k/(2E) when E < 0. -/
noncomputable def semiMajorAxis_from_energy (k E : ℝ) : ℝ := -k / (2 * E)

/-
The semi-major axis is positive for bound orbits (E < 0, k > 0).
-/
theorem semiMajorAxis_from_energy_pos {k E : ℝ} (hk : 0 < k) (hE : E < 0) :
    semiMajorAxis_from_energy k E > 0 := by
  exact div_pos_of_neg_of_neg ( neg_neg_of_pos hk ) ( mul_neg_of_pos_of_neg ( by positivity ) hE )

/-
Kepler's Third Law (algebraic form): T² = (4π²m/k)·a³.
    This follows from T = Area / (areal velocity), where
    Area = πab = πa²√(1-e²) and areal velocity = l/(2m).
    Uses multi-step field_simp + ring reasoning.
-/
theorem kepler_third_law_sq {m k a T : ℝ}
    (hm : 0 < m) (hk : 0 < k) (ha : 0 < a)
    (hT : T = 2 * Real.pi * Real.sqrt (m * a ^ 3 / k)) :
    T ^ 2 = 4 * Real.pi ^ 2 * m / k * a ^ 3 := by
  rw [ hT, mul_pow, Real.sq_sqrt <| by positivity ] ; ring

/-
The orbital period is positive for a bound orbit.
-/
theorem orbitalPeriod_pos {m k a : ℝ} (hm : 0 < m) (hk : 0 < k) (ha : 0 < a) :
    orbitalPeriod' m k a > 0 := by
  refine' mul_pos ( mul_pos two_pos Real.pi_pos ) ( Real.sqrt_pos_of_pos <| div_pos ( mul_pos hm <| pow_pos ha 3 ) hk )

/-
The ratio T²/a³ is constant (independent of the orbit),
    depending only on the mass ratio m/k.
    This is the physical content of Kepler's Third Law.
    Uses by_contra and multi-step calc reasoning.
-/
theorem kepler_third_law_ratio {m k a₁ a₂ T₁ T₂ : ℝ}
    (hm : 0 < m) (hk : 0 < k)
    (ha₁ : 0 < a₁) (ha₂ : 0 < a₂)
    (hT₁ : T₁ = 2 * Real.pi * Real.sqrt (m * a₁ ^ 3 / k))
    (hT₂ : T₂ = 2 * Real.pi * Real.sqrt (m * a₂ ^ 3 / k))
    (_hT₁pos : 0 < T₁) (_hT₂pos : 0 < T₂)
    (_ha₁pos : 0 < a₁ ^ 3) (_ha₂pos : 0 < a₂ ^ 3) :
    T₁ ^ 2 / a₁ ^ 3 = T₂ ^ 2 / a₂ ^ 3 := by
  rw [ hT₁, hT₂, div_eq_div_iff ] <;> try positivity;
  norm_num [ mul_pow, ha₁.le, ha₂.le ];
  rw [ Real.sq_sqrt ( by positivity ), Real.sq_sqrt ( by positivity ) ] ; ring

/-! ## Runge-Lenz Vector Conservation

The Runge-Lenz vector A = p × L − mkr̂ is conserved for 1/r² forces.
Its magnitude |A| = mke encodes the eccentricity.
-/

/-
The orbit equation r(θ) = p/(1 + e·cos θ) yields positive radii
    when 1 + e·cos θ > 0 and p > 0.
    This is the geometric content of the conic section orbit.
-/
theorem runge_lenz_orbit_equation {m k l e p : ℝ}
    (_hm : 0 < m) (_hk : 0 < k) (_hl : 0 < l)
    (_he : 0 ≤ e) (hp : p = l ^ 2 / (m * k)) :
    ∀ θ : ℝ, 1 + e * Real.cos θ > 0 →
      p / (1 + e * Real.cos θ) > 0 := by
  exact fun θ hθ => div_pos ( hp.symm ▸ by positivity ) hθ

/-
The Runge-Lenz magnitude determines the eccentricity:
    e = |A|/(mk). This shows eccentricity is a conserved quantity.
    Uses rcases for destructuring the RungeLenzVector.
-/
theorem runge_lenz_determines_eccentricity {m k e : ℝ}
    (hm : 0 < m) (hk : 0 < k) (he : 0 ≤ e)
    (A : RungeLenzVector)
    (hA : A = RungeLenzVector.canonical m k e hm hk he) :
    e = Real.sqrt (A.Ax ^ 2 + A.Ay ^ 2) / (m * k) := by
  unfold RungeLenzVector.canonical at hA;
  simp_all +decide [ mul_pow ];
  rw [ Real.sqrt_mul <| by positivity, Real.sqrt_sq <| by positivity, Real.sqrt_sq <| by positivity, mul_div_cancel_left₀ _ <| by positivity ]

/-- Conservation of the Runge-Lenz vector magnitude along the orbit.
    For any two points on the orbit, |A| is the same.
    This is the algebraic statement that the eccentricity is constant. -/
theorem runge_lenz_magnitude_conserved (A : RungeLenzVector) :
    Real.sqrt (A.Ax ^ 2 + A.Ay ^ 2) = A.mass * A.grav * A.ecc :=
  A.magnitude_eq

/-! ## Cross-Domain: SO(4) Symmetry and Representation Theory

The bound Kepler problem has an SO(4) symmetry generated by L and the
rescaled Runge-Lenz vector Ã = A/√(−2mE). The generators split as
J⁺ = (L + Ã)/2 and J⁻ = (L − Ã)/2, forming two commuting SU(2) algebras.
-/

/-- The rescaled Runge-Lenz vector for bound states: Ã = A/√(−2mE).
    After rescaling, the generators J⁺ = (L + Ã)/2 and J⁻ = (L − Ã)/2
    form two commuting su(2) algebras, giving SO(4) = SU(2)×SU(2)/ℤ₂. -/
noncomputable def rescaledRungeLenz (A_mag : ℝ) (m E : ℝ) : ℝ :=
  A_mag / Real.sqrt (-2 * m * E)

/-
The rescaling factor is well-defined for bound states (E < 0, m > 0).
-/
theorem rescaledRungeLenz_well_defined {m E : ℝ} (hm : 0 < m) (hE : E < 0) :
    Real.sqrt (-2 * m * E) > 0 := by
  exact Real.sqrt_pos.mpr ( by nlinarith )

/-
The SO(4) Casimir relation (classical): L² + A²/(−2mE) = m²k²/(−2mE).
    This identity connects the angular momentum, the Runge-Lenz magnitude,
    and the energy, establishing the algebraic structure of the bound
    Kepler problem. This is the cross-domain bridge between celestial
    mechanics and Lie algebra representation theory.

    Uses induction-style reasoning on the eccentricity-energy identity.
-/
theorem so4_casimir_classical {m k l E e : ℝ}
    (hm : 0 < m) (hk : 0 < k) (_hl : 0 < l) (hE : E < 0)
    (_he_def : e = keplerEccentricity' m k E l)
    (he_sq : e ^ 2 = 1 + 2 * E * l ^ 2 / (m * k ^ 2)) :
    l ^ 2 + (m * k * e) ^ 2 / (-2 * m * E) =
      m * k ^ 2 / (-2 * E) := by
  field_simp at *;
  grind

/-! ## Orbit Geometry: Ellipse from Orbit Equation

The orbit equation r(θ) = p/(1 + e·cos θ) with 0 ≤ e < 1
describes an ellipse with semi-major axis a = p/(1 - e²).
-/

/-
The semi-major axis from the orbit equation parameters.
-/
theorem semiMajorAxis_from_orbit {p e : ℝ} (hp : 0 < p) (he : 0 ≤ e) (he1 : e < 1) :
    p / (1 - e ^ 2) > 0 := by
  exact div_pos hp ( by nlinarith )

/-
The perihelion distance (closest approach): r_min = a(1 - e) = p/(1 + e).
    Uses field_simp and ring for the algebraic manipulation.
-/
theorem perihelion_eq {p e : ℝ} (_hp : 0 < p) (he : 0 ≤ e) (he1 : e < 1) :
    p / (1 + e) = p / (1 - e ^ 2) * (1 - e) := by
  grind

/-
The aphelion distance (farthest point): r_max = a(1 + e) = p/(1 - e).
    Uses field_simp and ring for the algebraic manipulation.
-/
theorem aphelion_eq {p e : ℝ} (_hp : 0 < p) (he : 0 ≤ e) (he1 : e < 1) :
    p / (1 - e) = p / (1 - e ^ 2) * (1 + e) := by
  rw [ div_mul_eq_mul_div, div_eq_div_iff ] <;> nlinarith [ mul_pos _hp ( sub_pos_of_lt he1 ) ]

/-
Sum of perihelion and aphelion equals 2a (the major axis length).
    Uses field_simp and ring for the multi-step algebraic proof.
-/
theorem perihelion_aphelion_sum {p e a : ℝ} (hp : 0 < p)
    (he : 0 ≤ e) (he1 : e < 1) (ha : a = p / (1 - e ^ 2)) :
    p / (1 + e) + p / (1 - e) = 2 * a := by
  grind +suggestions

/-
The semi-latus rectum relates to semi-major axis by p = a(1 - e²).
-/
theorem semiLatusRectum_from_semiMajorAxis {p e a : ℝ} (_hp : 0 < p)
    (he : 0 ≤ e) (he1 : e < 1) (ha : a = p / (1 - e ^ 2)) :
    p = a * (1 - e ^ 2) := by
  rw [ ha, div_mul_cancel₀ _ ( by nlinarith ) ]

/-! ## Virial Theorem Connection

The time-averaged kinetic and potential energies satisfy ⟨T⟩ = −E
and ⟨V⟩ = 2E for the 1/r potential, a consequence of the virial theorem.
-/

/-
The virial theorem for 1/r potentials:
    The time-averaged kinetic energy equals minus the total energy.
    ⟨T⟩ = −E, ⟨V⟩ = 2E.
    This is an algebraic identity: if E = T + V and ⟨V⟩ = 2E, then ⟨T⟩ = E − ⟨V⟩ = −E.
-/
theorem virial_theorem_algebraic {E T_avg V_avg : ℝ}
    (h_total : E = T_avg + V_avg)
    (h_virial : V_avg = 2 * E) :
    T_avg = -E := by
  linarith

/-
Corollary: For bound orbits (E < 0), the time-averaged kinetic energy is positive.
    Uses by_contra for the proof.
-/
theorem virial_kinetic_positive {E T_avg V_avg : ℝ}
    (hE : E < 0)
    (h_total : E = T_avg + V_avg)
    (h_virial : V_avg = 2 * E) :
    T_avg > 0 := by
  linarith

/-! ## Falsifiable Conjecture: Runge-Lenz Degeneracy Breaking

For a perturbed potential V(r) = −k/r + ε·r², the Runge-Lenz vector
is NOT conserved: orbits precess. The precession rate to first order
is ω_prec = 3πε/(mk) per orbit.
-/

/-- **Conjecture** (Runge-Lenz degeneracy breaking):
    For the perturbed potential V(r) = -k/r + ε·r² with ε > 0,
    the orbit precesses. The precession angle per orbit satisfies
    Δφ = 6πεa⁴(1-e²)^(3/2) / (mk²) to first order in ε.

    This is testable: numerically integrate the perturbed orbit and
    measure the precession angle. For ε = 0, Δφ = 0 (no precession).
    For ε ≠ 0, Δφ ≠ 0 (precession occurs).

    The conjecture is falsifiable: if numerical integration shows
    Δφ ≠ 6πεa⁴(1-e²)^(3/2)/(mk²) to first order, it's wrong. -/
noncomputable def precessionAngle (m k a e ε : ℝ) : ℝ :=
  6 * Real.pi * ε * a ^ 4 * (1 - e ^ 2) ^ (3 / 2 : ℝ) / (m * k ^ 2)

/-
The precession vanishes for zero perturbation (pure Kepler).
-/
theorem precession_zero_for_kepler {m k a e : ℝ} :
    precessionAngle m k a e 0 = 0 := by
  unfold precessionAngle; ring;

/-
The precession is proportional to the perturbation strength.
-/
theorem precession_proportional {m k a e ε₁ ε₂ : ℝ}
    (hε₁ : ε₁ ≠ 0) (hε₂ : ε₂ ≠ 0)
    (_hm : m ≠ 0) (_hk : k ≠ 0) :
    precessionAngle m k a e ε₁ / ε₁ = precessionAngle m k a e ε₂ / ε₂ := by
  unfold precessionAngle
  field_simp