import Mathlib
import Computation.NeuralCoding.LandauerLowerBound

/-!
# Dyson-Swarm Energy Collection and Thermodynamic Computation

This development separates the geometric, energetic, thermal, and informational
parts of an idealized Dyson swarm model.  A star is treated as an isotropic source.
Collectors at a common orbital radius intercept power in proportion to their area.
Thermal management is represented by a convex quadratic load: splitting a fixed
collecting area evenly among independent radiators minimizes total load.

The computation model assigns an energy cost to each irreversible operation.  It
therefore supports both general Landauer-style bounds and conservative numerical
certificates, without identifying a nominal engineering budget with a fundamental
physical constant.
-/

noncomputable section

open scoped BigOperators
open Finset

namespace DysonSphere

/-- Surface area of a sphere of radius `R`. -/
def sphereArea (R : ℝ) : ℝ := 4 * Real.pi * R ^ 2

/-- Isotropic radiant flux at radius `R`, with the geometric denominator exposed
as a parameter so that the singular case `R = 0` is excluded in theorems. -/
def radiantFlux (luminosity R : ℝ) : ℝ := luminosity / sphereArea R

/-- Power intercepted by collectors of total projected area `A`. -/
def capturedPower (luminosity R A : ℝ) : ℝ := radiantFlux luminosity R * A

/-- Quadratic proxy for thermal concentration in a finite swarm. -/
def thermalLoad {ι : Type*} [Fintype ι] (area : ι → ℝ) : ℝ :=
  ∑ i, (area i) ^ 2

/-- Number of operations affordable from an energy budget at a given positive
energy cost per operation. -/
def operationCapacity (energy costPerOperation : ℝ) : ℝ :=
  energy / costPerOperation

/-- Number of stored bits affordable from an energy budget at a given positive
energy cost per bit. -/
def bitCapacity (energy costPerBit : ℝ) : ℝ :=
  energy / costPerBit

/-- A swarm with collecting area equal to the enclosing sphere captures the full
luminosity of an isotropic source. -/
theorem full_area_captures_luminosity (luminosity R : ℝ)
    (harea : sphereArea R ≠ 0) :
    capturedPower luminosity R (sphereArea R) = luminosity := by
  unfold capturedPower radiantFlux
  exact div_mul_cancel₀ luminosity harea

/-- No partial swarm can intercept more than the stellar luminosity in the
isotropic projected-area model. -/
theorem capturedPower_le_luminosity (luminosity R A : ℝ)
    (hL : 0 ≤ luminosity) (hR : 0 < R)
    (hcover : A ≤ sphereArea R) :
    capturedPower luminosity R A ≤ luminosity := by
  have hpi : 0 < Real.pi := Real.pi_pos
  have hsphere : 0 < sphereArea R := by
    unfold sphereArea
    positivity
  unfold capturedPower radiantFlux
  have hflux : 0 ≤ luminosity / sphereArea R := div_nonneg hL hsphere.le
  calc
    luminosity / sphereArea R * A ≤ luminosity / sphereArea R * sphereArea R :=
      mul_le_mul_of_nonneg_left hcover hflux
    _ = luminosity := div_mul_cancel₀ luminosity hsphere.ne'

/-- For a fixed amount of material, the sum of the collectors' areas is independent
of how the material is partitioned.  Thus a swarm can match the collecting area of
a shell without requiring a mechanically connected shell. -/
theorem swarm_area_matches_shell {ι : Type*} [Fintype ι]
    (area : ι → ℝ) (R : ℝ) (harea : ∑ i, area i = sphereArea R) :
    capturedPower 1 R (∑ i, area i) = capturedPower 1 R (sphereArea R) := by
  rw [harea]

/-- Finite Cauchy inequality in the form governing quadratic thermal load:
`(total area)^2 ≤ n · (sum of squared panel areas)`. -/
theorem total_area_sq_le_card_mul_thermalLoad {ι : Type*} [Fintype ι]
    (area : ι → ℝ) :
    (∑ i, area i) ^ 2 ≤ (Fintype.card ι : ℝ) * thermalLoad area := by
  simpa [thermalLoad] using
    (sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset ι)) (f := area))

/-- Equal-area collectors attain the optimal quadratic thermal load. -/
theorem uniform_swarm_thermalLoad {ι : Type*} [Fintype ι]
    (A : ℝ) (hcard : Fintype.card ι ≠ 0) :
    thermalLoad (fun _ : ι => A / (Fintype.card ι : ℝ)) =
      A ^ 2 / (Fintype.card ι : ℝ) := by
  have hn : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast hcard
  unfold thermalLoad
  simp only [sum_const, nsmul_eq_mul, card_univ]
  field_simp [hn]

/-- Among all swarms with fixed total area, the uniform swarm minimizes the
quadratic thermal load.  This is the precise thermal-management advantage in the
model: increasing the number of independently radiating equal panels divides the
minimum load by the panel count. -/
theorem uniform_swarm_is_thermal_optimum {ι : Type*} [Fintype ι]
    (area : ι → ℝ) (A : ℝ) (hcard : Fintype.card ι ≠ 0)
    (htotal : ∑ i, area i = A) :
    thermalLoad (fun _ : ι => A / (Fintype.card ι : ℝ)) ≤ thermalLoad area := by
  rw [uniform_swarm_thermalLoad A hcard]
  have hmain := total_area_sq_le_card_mul_thermalLoad area
  rw [htotal] at hmain
  have hnpos : 0 < (Fintype.card ι : ℝ) := by
    exact_mod_cast (Nat.pos_of_ne_zero hcard)
  apply (div_le_iff₀ hnpos).2
  nlinarith

/-- Splitting a positive collecting area equally between two independent radiators
strictly improves the quadratic thermal metric over one monolithic collector. -/
theorem two_panel_strict_thermal_improvement (A : ℝ) (hA : 0 < A) :
    thermalLoad (fun _ : Fin 2 => A / 2) < thermalLoad (fun _ : Fin 1 => A) := by
  simp [thermalLoad]
  nlinarith [sq_pos_of_pos hA]

/-- General energy-accounting bound: if each operation costs at least `c`, then an
energy budget `E` cannot support a claimed operation count `N` unless `N*c ≤ E`. -/
theorem operation_budget_bound (E c N : ℝ) (hc : 0 < c) (hbudget : N * c ≤ E) :
    N ≤ operationCapacity E c := by
  unfold operationCapacity
  exact (le_div_iff₀ hc).2 hbudget

/-- The analogous capacity bound for stored bits. -/
theorem bit_budget_bound (E c B : ℝ) (hc : 0 < c) (hbudget : B * c ≤ E) :
    B ≤ bitCapacity E c := by
  unfold bitCapacity
  exact (le_div_iff₀ hc).2 hbudget

/-- A conservative Type-II certificate: `10^26` joules per second supports
`10^40` operations per second whenever the charged energy is at most `10^-14`
joules per operation.  This is an engineering threshold, not an assertion that
`10^-14` joules is the Landauer limit. -/
theorem typeII_supports_ten_pow_40
    (costPerOperation : ℝ) (hcost : 0 < costPerOperation)
    (hupper : costPerOperation ≤ 10 ^ (-14 : ℤ)) :
    (10 : ℝ) ^ (40 : ℕ) ≤ operationCapacity ((10 : ℝ) ^ (26 : ℕ)) costPerOperation := by
  apply operation_budget_bound _ _ _ hcost
  calc
    (10 : ℝ) ^ (40 : ℕ) * costPerOperation
        ≤ (10 : ℝ) ^ (40 : ℕ) * 10 ^ (-14 : ℤ) :=
      mul_le_mul_of_nonneg_left hupper (by positivity)
    _ = (10 : ℝ) ^ (26 : ℕ) := by norm_num [zpow_neg]

/-- A calibrated `10^50`-bit certificate: an available energy `E` supports at
least `10^50` bits whenever the charged energy per bit is positive and no more
than `E / 10^50`.  The theorem makes explicit the temperature- and timescale-
dependent premise hidden by an unqualified information-capacity estimate. -/
theorem ten_pow_50_bit_certificate (E costPerBit : ℝ)
    (hcost : 0 < costPerBit)
    (hupper : costPerBit ≤ E / (10 : ℝ) ^ (50 : ℕ)) :
    (10 : ℝ) ^ (50 : ℕ) ≤ bitCapacity E costPerBit := by
  apply bit_budget_bound _ _ _ hcost
  calc
    (10 : ℝ) ^ (50 : ℕ) * costPerBit
        ≤ (10 : ℝ) ^ (50 : ℕ) * (E / (10 : ℝ) ^ (50 : ℕ)) :=
      mul_le_mul_of_nonneg_left hupper (by positivity)
    _ = E := by field_simp

/-- The general deterministic Landauer inequality from the computation catalog
applies unchanged to a Dyson-scale computer: multiplying entropy loss by
nonnegative temperature and Boltzmann factors gives nonnegative dissipated heat. -/
theorem dyson_computation_heat_nonnegative
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x)
    (boltzmann temperature : ℝ) (hb : 0 ≤ boltzmann) (hT : 0 ≤ temperature) :
    0 ≤ boltzmann * temperature *
      (shannonEntropy p - shannonEntropy (LandauerLowerBound.pushforwardFun f p)) := by
  exact LandauerLowerBound.landauer_lower_bound f p hp boltzmann temperature hb hT

/-! ## Concrete examples -/

example : sphereArea 1 = 4 * Real.pi := by
  unfold sphereArea
  ring

example : thermalLoad (fun _ : Fin 4 => (3 : ℝ)) = 36 := by
  norm_num [thermalLoad, Fin.sum_univ_succ]

example : operationCapacity ((10 : ℝ) ^ (26 : ℕ)) (10 ^ (-14 : ℤ)) =
    (10 : ℝ) ^ (40 : ℕ) := by
  norm_num [operationCapacity, zpow_neg]

-- !-- Lab Notes -- !--
-- Hypothesis: (1) projected area, rather than mechanical connectivity, determines
-- captured luminosity; (2) equal partition minimizes a convex thermal-load proxy;
-- (3) panel count gives an inverse linear improvement; (4) operation throughput is
-- bounded by energy divided by per-operation cost; (5) a `10^40` throughput follows
-- conservatively from a `10^26` W budget; (6) an absolute `10^50`-bit claim requires
-- an explicit energy-per-bit and available-energy premise.  The second, third, and
-- sixth hypotheses were treated as the bold cross-domain targets.
--
-- Experiment: The geometric model was combined with finite-sum variance and with
-- deterministic Shannon-entropy loss.  Two- and four-panel examples were checked,
-- and the decimal exponents in the Type-II certificate were reduced exactly.
-- No external sequence or database signal in the mission supplied a relevant
-- numerical sequence; consequently no OEIS or LMFDB identifier influenced a target.
--
-- Analysis: Area equivalence survives exactly.  The thermal claim survives only
-- after “better” is assigned the convex quadratic concentration metric.  The
-- `10^40` claim survives as a conservative conditional theorem.  The raw `10^50`
-- statement needs a different definition: Landauer's principle bounds erasure
-- energy per bit, but does not by itself bound passive storage capacity from radius.
-- The common structure is resource division: geometric area adds linearly while
-- convex thermal cost and energetic operation budgets impose inequalities.
--
-- Critique: Radius zero is a boundary case because radiant flux is singular, so
-- capture theorems require positive radius or a nonzero sphere area.  Negative area,
-- luminosity, temperature, or energy cost is unphysical and is excluded where order
-- arguments need positivity.  A swarm does not automatically have superior thermal
-- behavior under every engineering metric; the proved advantage is specifically for
-- independent equal radiators under quadratic load.  At one panel there is no strict
-- advantage.  None of the principal results is a definition-only equality.
--
-- Synthesis: The results form a hierarchy from sphere geometry, through optimal
-- finite partitioning, to computation and entropy.  A broader generalization can
-- replace the quadratic load by any strictly convex radiator cost; an extension can
-- incorporate unequal temperatures, view factors, orbital occlusion, and finite-time
-- energy accumulation.  The present boundaries identify exactly which additional
-- physical assumptions those generalizations must state.
-- !-- end Lab Notes -- !--

end DysonSphere