/-
# The Fermi Paradox as a Pigeonhole Principle

## Mathematical Framework

We formalize the Fermi paradox using combinatorial and probabilistic arguments.
The key insight: the pigeonhole principle, applied "in reverse," tells us that
when there are far more slots (habitable planets) than items (civilizations),
the vast majority of slots must be empty. Combined with Poisson-type bounds,
this gives rigorous meaning to "we are alone."

## Definitions

- `DrakeParams`: The parameters of the Drake equation
- `expectedCivilizations`: The expected number of civilizations from Drake params
- `CivilizationAssignment`: A function assigning civilizations to planets
- `GreatFilter`: The probability bottleneck that makes intelligent life rare
-/

import Mathlib

open Finset BigOperators

/-! ## Drake Equation Parameters -/

/-- Parameters of the Drake equation, modeling the probability of
technological civilizations arising on habitable planets.

The Drake equation: N = R* × f_p × n_e × f_l × f_i × f_c × L

We work with dimensionless probabilities on a per-planet basis,
combining several factors into a single `perPlanetProb`. -/
structure DrakeParams where
  /-- Number of habitable planets in the observable universe -/
  numPlanets : ℕ
  /-- Probability that a given habitable planet develops a technological civilization
      (combines f_l × f_i × f_c from the Drake equation) -/
  perPlanetProb : ℝ
  /-- The per-planet probability is nonneg -/
  prob_nonneg : 0 ≤ perPlanetProb
  /-- The per-planet probability is at most 1 -/
  prob_le_one : perPlanetProb ≤ 1


/-- The expected number of civilizations in the observable universe,
    given Drake parameters. This is simply n × p. -/
noncomputable def DrakeParams.expectedCiv (d : DrakeParams) : ℝ :=
  d.numPlanets * d.perPlanetProb

/-- Conservative Drake parameters: 10^10 habitable planets,
    probability 10^{-11} per planet. -/
noncomputable def conservativeDrake : DrakeParams where
  numPlanets := 10^10
  perPlanetProb := (10 : ℝ)⁻¹ ^ 11
  prob_nonneg := by positivity
  prob_le_one := by
    simp only [inv_pow]
    norm_num

/-! ## Civilization Assignment (Pigeonhole Framework) -/

/-- A civilization assignment maps each civilization (indexed by `Fin k`)
    to a planet (indexed by `Fin n`). This is the "pigeons into holes" model. -/
def CivilizationAssignment (k n : ℕ) := Fin k → Fin n

/-- The number of civilizations assigned to planet `j`. -/
def civCount {k n : ℕ} (f : CivilizationAssignment k n) (j : Fin n) : ℕ :=
  (Finset.univ.filter (fun i => f i = j)).card

/-- A planet is empty (has no civilization) under assignment `f`. -/
def planetEmpty {k n : ℕ} (f : CivilizationAssignment k n) (j : Fin n) : Prop :=
  civCount f j = 0

/-- The number of empty planets under a given assignment. -/
def numEmptyPlanets {k n : ℕ} (f : CivilizationAssignment k n) : ℕ :=
  (Finset.univ.filter (fun j => civCount f j = 0)).card

/-! ## Great Filter -/

/-- The "Great Filter" strength: the negative log of per-planet probability.
    A higher filter strength means civilization is rarer.
    If perPlanetProb = 10^{-k}, then filterStrength ≈ k × ln(10). -/
noncomputable def filterStrength (d : DrakeParams) : ℝ :=
  -Real.log d.perPlanetProb

/-! ## Tropical Drake Optimization

The tropical semiring (max-plus algebra) provides a natural framework for
optimizing the Drake equation: which parameter dominates the "filter"?
In the tropical semiring, multiplication becomes addition and addition
becomes max, so the product of Drake factors becomes a tropical sum,
and the dominant factor is the tropical maximum. -/

/-- A tropical Drake parameter vector: each entry is the negative log
    of the corresponding probability factor. The "bottleneck" (Great Filter)
    is the factor with the largest negative log (= smallest probability). -/
def TropicalDrakeVector (n : ℕ) := Fin n → ℝ

/-- The tropical "sum" (= max) identifies the dominant filter. -/
noncomputable def tropicalBottleneck {n : ℕ} (v : TropicalDrakeVector n) [NeZero n] : ℝ :=
  Finset.univ.sup' (by exact Finset.univ_nonempty) v

/-- The total filter strength is the ordinary sum of all log-factors,
    which corresponds to multiplication of probabilities. -/
noncomputable def totalFilterStrength {n : ℕ} (v : TropicalDrakeVector n) : ℝ :=
  ∑ i, v i