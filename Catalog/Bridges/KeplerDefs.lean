/-
  # Kepler Problem — Core Definitions

  Fundamental definitions for the Kepler/two-body problem:
  eccentricity, semi-latus rectum, semi-major axis,
  effective potential, and circular orbit radius.
-/
import Mathlib

open Real

/-- The eccentricity of a Kepler orbit: e = √(1 + 2El²/(mk²)). -/
noncomputable def keplerEccentricity (m k E l : ℝ) : ℝ :=
  Real.sqrt (1 + 2 * E * l ^ 2 / (m * k ^ 2))

/-- The semi-latus rectum: p = l²/(mk). -/
noncomputable def semiLatusRectum (m k l : ℝ) : ℝ :=
  l ^ 2 / (m * k)

/-- The semi-major axis: a = p/(1 - e²) = -k/(2E) for bound orbits. -/
noncomputable def semiMajorAxis (m k E l : ℝ) : ℝ :=
  semiLatusRectum m k l / (1 - (keplerEccentricity m k E l) ^ 2)

/-- The circular orbit radius: r* = l²/(mk) = p. -/
noncomputable def circularOrbitRadius (m k l : ℝ) : ℝ :=
  l ^ 2 / (m * k)

/-- The effective potential: V_eff(r) = l²/(2mr²) - k/r. -/
noncomputable def effectivePotential (m k l r : ℝ) : ℝ :=
  l ^ 2 / (2 * m * r ^ 2) - k / r

/-- The minimum of the effective potential: V_min = -mk²/(2l²). -/
noncomputable def effectivePotentialMin (m k l : ℝ) : ℝ :=
  -(m * k ^ 2) / (2 * l ^ 2)

/-- The orbital period: T = 2π√(ma³/k). -/
noncomputable def orbitalPeriod (m k a : ℝ) : ℝ :=
  2 * Real.pi * Real.sqrt (m * a ^ 3 / k)

/-- Semi-latus rectum is positive when m, k, l are positive. -/
theorem semiLatusRectum_pos {m k l : ℝ} (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    semiLatusRectum m k l > 0 := by
  unfold semiLatusRectum
  positivity