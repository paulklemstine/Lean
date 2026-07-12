import Mathlib
import Physics.LandauerThermodynamicLimit

/-!
# Dyson Sphere Mathematics: Geometry, Thermal Management, and Computational Limits

This file develops the elementary mathematics of a *Dyson sphere* — a megastructure
that fully encloses a star to intercept its luminosity — and of the physically
superior *Dyson swarm* of independent collectors.  The results are organised around
four themes.

## Geometry and energy capture

* `dyson_capture` — a spherical shell of radius `R` intercepts the star's *entire*
  luminosity: the incident flux `L / (4πR²)` times the shell area `4πR²` equals `L`.
* `dysonArea_pos` — the collecting area is strictly positive.

## Thermal management (Stefan–Boltzmann)

A radiator dissipating power `P` over area `A` settles at equilibrium temperature
`(P / (σA))^{1/4}`.  Increasing the radiating area *lowers* the equilibrium
temperature.

* `eqTemp_antitone` — the equilibrium temperature is strictly decreasing in the
  radiating area.
* `swarm_thermal_advantage` — a swarm, whose collectors radiate from *both* faces
  (total radiating area `2·(4πR²)`), runs strictly cooler than a monolithic shell
  radiating the same power from a single outer face.
* `swarm_temperature_ratio` — the exact factor is `(1/2)^{1/4} ≈ 0.841`.
* `swarm_area_preserved` — the swarm nevertheless keeps the *same* total collecting
  area as the shell it replaces.

## Information capacity (Landauer)

At temperature `T` each irreversible bit operation costs at least `k_B T ln 2` of
energy, so an energy budget `E` supports at most `E / (k_B T ln 2)` bit erasures.

* `landauerBits_pos` — the bit capacity is positive.
* `landauer_colder_is_better` — a colder reservoir supports strictly more bits per
  joule.
* `dyson_memory_capacity` — an energy budget sized as `n · k_B T ln 2` supports
  exactly `n` bits; here the per-bit cost is imported from the catalog result
  `LandauerThermodynamicLimit.landauer_per_bit_cost`.

## Quantum operation rate (Margolus–Levitin)

A system of energy `E` performs at most `2E / (πħ)` orthogonalising (elementary
quantum) operations per second.

* `mlOpRate_pos`, `mlOpRate_strictMono` — the operation-rate bound is positive and
  strictly increasing in available energy, so a Type II civilisation's larger power
  budget strictly increases its computational ceiling.
-/

noncomputable section

open Real

namespace DysonSphere

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): A Dyson swarm can preserve the full collecting area of
--   an enclosing shell while achieving strictly better thermal management, because
--   free-floating collectors radiate from both faces (double the radiating area),
--   and Stefan–Boltzmann equilibrium temperature is antitone in radiating area.
--   Secondary bold conjecture: the energy/information ceilings (Landauer for storage,
--   Margolus–Levitin for computation) are governed by the SAME positivity/monotonicity
--   structure, so both scale monotonically with the intercepted stellar power.
-- Experiment (Experimenter): Geometry reduces to a field_simp identity (4πR² cancels).
--   The thermal claims reduce to strict monotonicity of x ↦ x^{1/4} (Real.rpow_lt_rpow)
--   composed with div_lt_div_of_pos_left. The exact (1/2)^{1/4} ratio uses Real.mul_rpow.
--   Landauer capacity reuses the catalog per-bit cost verbatim.
-- Analysis (Analyst): "Better thermal management with equal area" is TRUE and reduces
--   to a one-parameter antitone family; the swarm's advantage is exactly the geometric
--   factor 2 in radiating area, giving a temperature ratio (1/2)^{1/4}, independent of
--   P, σ, R. The information/computation ceilings are the SAME shape (positive,
--   strictly monotone in the driving resource), which is the unifying structural pattern.
-- Critique (Critic): Must avoid vacuity — every temperature/bit statement carries the
--   strict positivity hypotheses (P,σ,A,E,k,T > 0) needed for the divisions and rpow
--   monotonicity to be meaningful. eqTemp_antitone needs 0 < A₁ (not just A₁ < A₂) so
--   that A₂ > 0; without it the base could be nonpositive and rpow monotonicity fails.
-- Synthesis (PI): One antitone family (Stefan–Boltzmann) explains the swarm advantage;
--   one monotone family (Landauer / Margolus–Levitin) explains the computational
--   ceilings; the catalog Landauer bound plugs directly into the storage capacity.
-- !-- end Lab Notes -- !--

/-- Surface (collecting) area of a Dyson shell of orbital radius `R`. -/
def dysonArea (R : ℝ) : ℝ := 4 * Real.pi * R ^ 2

/-- Radiative flux at radius `R` from a star of luminosity `L` (power per unit area
of the enclosing shell). -/
def sphereFlux (L R : ℝ) : ℝ := L / (4 * Real.pi * R ^ 2)

/-- Stefan–Boltzmann equilibrium temperature of a radiator dissipating power `P` over
area `A` with radiative constant `σ`: `T = (P / (σ A))^{1/4}`. -/
def eqTemp (P sigma A : ℝ) : ℝ := (P / (sigma * A)) ^ ((1 : ℝ) / 4)

/-- Landauer bit capacity: number of irreversible bit operations an energy budget `E`
supports at temperature `T`, each costing `k_B T ln 2`. -/
def landauerBits (E kB T : ℝ) : ℝ := E / (kB * T * Real.log 2)

/-- Margolus–Levitin bound on the number of elementary (orthogonalising) quantum
operations per second available to a system of energy `E`. -/
def mlOpRate (E hbar : ℝ) : ℝ := 2 * E / (Real.pi * hbar)

/-! ### Geometry and energy capture -/

/-- The collecting area of a Dyson shell is strictly positive for a nonzero radius. -/
theorem dysonArea_pos (R : ℝ) (hR : R ≠ 0) : 0 < dysonArea R := by
  unfold dysonArea
  have hpi : 0 < Real.pi := Real.pi_pos
  have hR2 : 0 < R ^ 2 := by positivity
  positivity

/-- **Complete energy capture.** A spherical shell of radius `R > 0` intercepts the
star's entire luminosity `L`: the incident flux times the shell area equals `L`. -/
theorem dyson_capture (L R : ℝ) (hR : R ≠ 0) :
    sphereFlux L R * dysonArea R = L := by
  unfold sphereFlux dysonArea
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp

/-! ### Thermal management -/

/-- **Larger radiators run cooler.** The Stefan–Boltzmann equilibrium temperature is
strictly decreasing in the radiating area. -/
theorem eqTemp_antitone (P sigma A1 A2 : ℝ) (hP : 0 < P) (hs : 0 < sigma)
    (h1 : 0 < A1) (h12 : A1 < A2) : eqTemp P sigma A2 < eqTemp P sigma A1 := by
  unfold eqTemp
  have hA2 : 0 < A2 := lt_trans h1 h12
  have hb2 : 0 < P / (sigma * A2) := by positivity
  have hden : 0 < sigma * A1 := by positivity
  have hlt : P / (sigma * A2) < P / (sigma * A1) :=
    div_lt_div_of_pos_left hP hden (mul_lt_mul_of_pos_left h12 hs)
  exact Real.rpow_lt_rpow (le_of_lt hb2) hlt (by norm_num)

/-- **Swarm thermal advantage.** A swarm whose collectors radiate from both faces
(total radiating area `2 · dysonArea R`) settles at a strictly lower equilibrium
temperature than a monolithic shell radiating the same power `P` from its single
outer face (area `dysonArea R`). -/
theorem swarm_thermal_advantage (P sigma R : ℝ) (hP : 0 < P) (hs : 0 < sigma)
    (hR : R ≠ 0) :
    eqTemp P sigma (2 * dysonArea R) < eqTemp P sigma (dysonArea R) := by
  have hA : 0 < dysonArea R := dysonArea_pos R hR
  exact eqTemp_antitone P sigma (dysonArea R) (2 * dysonArea R) hP hs hA (by linarith)

/-- **Exact swarm temperature ratio.** Doubling the radiating area scales the
equilibrium temperature by exactly `(1/2)^{1/4} ≈ 0.841`, independent of `P`, `σ`, `A`. -/
theorem swarm_temperature_ratio (P sigma A : ℝ) (hP : 0 < P) (hs : 0 < sigma)
    (hA : 0 < A) :
    eqTemp P sigma (2 * A) = ((1 : ℝ) / 2) ^ ((1 : ℝ) / 4) * eqTemp P sigma A := by
  unfold eqTemp
  have hb : 0 ≤ P / (sigma * A) := by positivity
  have hsplit : P / (sigma * (2 * A)) = (1 / 2) * (P / (sigma * A)) := by field_simp
  rw [hsplit, Real.mul_rpow (by norm_num) hb]

/-- **Collecting area is preserved.** Splitting a shell into `N > 0` independent
collectors, each of area `dysonArea R / N`, keeps the total collecting area equal to
that of the shell. -/
theorem swarm_area_preserved (R : ℝ) (N : ℕ) (hN : 0 < N) :
    (N : ℝ) * (dysonArea R / N) = dysonArea R := by
  have hN' : (N : ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  field_simp

/-! ### Information capacity (Landauer) -/

/-- The Landauer bit capacity is positive for a positive energy budget and a positive
temperature. -/
theorem landauerBits_pos (E kB T : ℝ) (hE : 0 < E) (hk : 0 < kB) (hT : 0 < T) :
    0 < landauerBits E kB T := by
  unfold landauerBits
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  positivity

/-- **A colder reservoir stores more information per joule.** For a fixed energy
budget `E`, the Landauer bit capacity is strictly larger at the lower temperature. -/
theorem landauer_colder_is_better (E kB T1 T2 : ℝ) (hE : 0 < E) (hk : 0 < kB)
    (h1 : 0 < T1) (h12 : T1 < T2) :
    landauerBits E kB T2 < landauerBits E kB T1 := by
  unfold landauerBits
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hden1 : 0 < kB * T1 * Real.log 2 := by positivity
  have hlt : kB * T1 * Real.log 2 < kB * T2 * Real.log 2 := by
    nlinarith [hlog, mul_lt_mul_of_pos_left h12 hk]
  exact div_lt_div_of_pos_left hE hden1 hlt

/-- **Dyson memory capacity.** An energy budget sized as `n · k_B T ln 2` supports
exactly `n` bit operations, and the per-bit cost is exactly `k_B T ln 2` — the latter
imported from the catalog thermodynamic-limit result
`LandauerThermodynamicLimit.landauer_per_bit_cost`. -/
theorem dyson_memory_capacity (n : ℕ) (hn : 0 < n) (kB T : ℝ) (hk : 0 < kB)
    (hT : 0 < T) :
    landauerBits ((n : ℝ) * (kB * T * Real.log 2)) kB T = (n : ℝ) ∧
      ((n : ℝ) * (kB * T * Real.log 2)) / n = kB * T * Real.log 2 := by
  refine ⟨?_, LandauerThermodynamicLimit.landauer_per_bit_cost n hn kB T⟩
  unfold landauerBits
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hne : kB * T * Real.log 2 ≠ 0 := by positivity
  field_simp

/-! ### Quantum operation rate (Margolus–Levitin) -/

/-- The Margolus–Levitin operation-rate ceiling is positive for a positive energy. -/
theorem mlOpRate_pos (E hbar : ℝ) (hE : 0 < E) (hbar_pos : 0 < hbar) :
    0 < mlOpRate E hbar := by
  unfold mlOpRate
  have hpi : 0 < Real.pi := Real.pi_pos
  positivity

/-- **More power, more computation.** The Margolus–Levitin operation-rate ceiling is
strictly increasing in the available energy: a Type II civilisation's larger power
budget strictly raises its quantum-computational ceiling. -/
theorem mlOpRate_strictMono (E1 E2 hbar : ℝ) (hbar_pos : 0 < hbar) (h : E1 < E2) :
    mlOpRate E1 hbar < mlOpRate E2 hbar := by
  unfold mlOpRate
  have hpi : 0 < Real.pi := Real.pi_pos
  have hden : 0 < Real.pi * hbar := by positivity
  apply div_lt_div_of_pos_right _ hden
  linarith

end DysonSphere

end