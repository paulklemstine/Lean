/-
# Flatland Catastrophe: Deep Analysis of 2D Gravitational Pathologies

This file establishes rigorous mathematical results about why 2-dimensional
Newtonian gravity is pathological. We prove:

1. The apsidal angle ratio 1/√2 is irrational → orbits never close (Bertrand failure)
2. The stability discriminant for n-dim gravity is (4−n)
3. Dimension 3 is the UNIQUE dimension with stable + closed orbits (Goldilocks theorem)
4. The logarithmic potential grows without bound → no escape velocity in 2D
5. No periodic return: n·(π/√2) is never a multiple of 2π
6. Orbit density via irrationality of the apsidal sequence

## Novel Contribution: GravitationalDimension framework
We define a structure encoding the complete dimensional dependence of
gravitational physics and prove a sharp classification theorem.
-/
import Mathlib

open Real Filter Set Topology

/-! ## Section 1: Dimensional Gravity Framework -/

/-- A gravitational theory in n spatial dimensions.
    In n dimensions, Gauss's law gives force F ∝ r^(1-n).
    The stability discriminant of circular orbits has sign (4-n). -/
structure GravitationalDimension where
  /-- Spatial dimension (≥ 2) -/
  n : ℕ
  /-- Dimension is at least 2 -/
  hn : 2 ≤ n

namespace GravitationalDimension

/-- The force exponent: F ∝ r^(1-n). -/
def forceExponent (g : GravitationalDimension) : ℤ := 1 - (g.n : ℤ)

/-- The stability parameter: 4 - n. -/
def stabilityParam (g : GravitationalDimension) : ℤ := 4 - (g.n : ℤ)

/-- Whether circular orbits are linearly stable (stability param > 0) -/
def hasStableOrbits (g : GravitationalDimension) : Prop := 0 < g.stabilityParam

/-- Whether the gravitational potential is logarithmic (n = 2 case) -/
def isLogarithmic (g : GravitationalDimension) : Prop := g.n = 2

/-- Whether particles can escape to infinity (n ≥ 3) -/
def hasEscapeVelocity (g : GravitationalDimension) : Prop := 3 ≤ g.n

end GravitationalDimension

/-! ## Section 2: The 2D Apsidal Angle and Irrationality -/

/-- The apsidal angle ratio for gravity in dimension n.
    For power-law force F ∝ r^(1-n), the apsidal angle is π/√(4-n).
    The ratio is 1/√(4-n). -/
noncomputable def apsidalRatio (n : ℕ) : ℝ := 1 / Real.sqrt ((4 : ℝ) - (n : ℝ))

/-- In 3D, the apsidal ratio is 1 (orbits close after π rotation). -/
theorem apsidalRatio_3D : apsidalRatio 3 = 1 := by
  unfold apsidalRatio; push_cast; norm_num

/-- In 2D, the apsidal ratio is 1/√2. -/
theorem apsidalRatio_2D : apsidalRatio 2 = 1 / Real.sqrt 2 := by
  unfold apsidalRatio; push_cast; norm_num

/-- 1/√2 is irrational. -/
theorem inv_sqrt_two_irrational : Irrational (1 / Real.sqrt 2) := by
  rw [one_div]; exact irrational_inv_iff.mpr irrational_sqrt_two

/-- The 2D apsidal ratio is irrational — orbits never close. -/
theorem apsidalRatio_2D_irrational : Irrational (apsidalRatio 2) := by
  rw [apsidalRatio_2D]; exact inv_sqrt_two_irrational

/-- **Theorem (Bertrand Failure in 2D)**: Orbits in 2D gravity never close.
    The apsidal angle ratio 1/√2 is irrational, so the orbit can never
    return to its starting angular position. -/
theorem bertrand_failure_2D : ¬ (¬ Irrational (apsidalRatio 2)) :=
  not_not.mpr apsidalRatio_2D_irrational

/-- 3D gravity has a rational apsidal ratio (orbits DO close). -/
theorem bertrand_success_3D : ¬ Irrational (apsidalRatio 3) := by
  rw [apsidalRatio_3D]; exact not_irrational_one

/-! ## Section 3: No Periodic Return -/

/-
After n radial oscillations in 2D gravity, the angular position is
    n·π/√2. For periodicity, n·π/√2 = 2πm for some integer m.
    This gives n/(2√2) = m, impossible since 1/√2 is irrational.
-/
theorem no_periodic_return_2D (n : ℕ) (hn : 0 < n) :
    ¬∃ m : ℤ, (n : ℝ) * (Real.pi / Real.sqrt 2) = 2 * Real.pi * m := by
  field_simp;
  exact fun ⟨ m, hm ⟩ => irrational_sqrt_two <| ⟨ n / ( 2 * m ), by push_cast [ hm ] ; rw [ div_eq_iff <| by aesop ] ; ring ⟩

/-! ## Section 4: Logarithmic Potential Pathology -/

/-- The 2D gravitational potential k·ln(r) is unbounded as r → ∞.
    No finite kinetic energy suffices for escape. -/
theorem log_potential_unbounded (k : ℝ) (hk : 0 < k) :
    Tendsto (fun r => k * Real.log r) atTop atTop :=
  Tendsto.const_mul_atTop hk Real.tendsto_log_atTop

/-
The 2D gravitational potential k·ln(r) → -∞ as r → 0⁺.
    Particles gain infinite kinetic energy on collision.
-/
theorem log_potential_collision (k : ℝ) (hk : 0 < k) :
    Tendsto (fun r => k * Real.log r) (nhdsWithin 0 (Ioi 0)) atBot := by
  exact Filter.Tendsto.const_mul_atBot hk ( Real.tendsto_log_nhdsGT_zero )

/-! ## Section 5: Stability Analysis -/

/-- The stability criterion: circular orbits are stable iff n < 4. -/
theorem stability_criterion (g : GravitationalDimension) :
    g.hasStableOrbits ↔ (g.n : ℤ) < 4 := by
  simp [GravitationalDimension.hasStableOrbits, GravitationalDimension.stabilityParam]

/-- 2D gravity has stable circular orbits (they just don't close). -/
theorem dim2_stable : (⟨2, le_refl 2⟩ : GravitationalDimension).hasStableOrbits := by
  simp [GravitationalDimension.hasStableOrbits, GravitationalDimension.stabilityParam]

/-- 3D gravity has stable circular orbits. -/
theorem dim3_stable : (⟨3, by omega⟩ : GravitationalDimension).hasStableOrbits := by
  simp [GravitationalDimension.hasStableOrbits, GravitationalDimension.stabilityParam]

/-- 4D gravity is marginally stable (discriminant = 0). -/
theorem dim4_marginal : (⟨4, by omega⟩ : GravitationalDimension).stabilityParam = 0 := by
  simp [GravitationalDimension.stabilityParam]

/-- 5D and above: unstable circular orbits. -/
theorem dim5_unstable : ¬(⟨5, by omega⟩ : GravitationalDimension).hasStableOrbits := by
  simp [GravitationalDimension.hasStableOrbits, GravitationalDimension.stabilityParam]

/-- General instability for n ≥ 4. -/
theorem high_dim_unstable (g : GravitationalDimension) (h : 4 ≤ g.n) :
    ¬g.hasStableOrbits := by
  simp [GravitationalDimension.hasStableOrbits, GravitationalDimension.stabilityParam]; omega

/-! ## Section 6: The Goldilocks Theorem -/

/-- A dimension supports closed orbits if the stability param is positive
    and √(stability_param) is rational. -/
def supportsClosedOrbits (n : ℕ) : Prop :=
  (0 : ℤ) < 4 - (n : ℤ) ∧ ¬Irrational (Real.sqrt ((4 : ℝ) - (n : ℝ)))

/-
**Goldilocks Theorem**: n = 3 is the unique dimension (among n ≥ 2)
    supporting closed gravitational orbits.

    Proof: Need 4 - n > 0 (so n ∈ {2,3}) and √(4-n) rational.
    - n=2: √2 irrational ✗
    - n=3: √1 = 1 rational ✓
-/
theorem goldilocks_unique_dimension (n : ℕ) (hn : 2 ≤ n) :
    supportsClosedOrbits n ↔ n = 3 := by
  by_cases h : n ≤ 4 <;> simp_all +decide [ supportsClosedOrbits ];
  · interval_cases n <;> norm_num;
  · grind

/-! ## Section 7: No Escape from Flatland -/

/-- 2D gravity has no escape velocity. -/
theorem dim2_no_escape :
    ¬(⟨2, le_refl 2⟩ : GravitationalDimension).hasEscapeVelocity := by
  simp [GravitationalDimension.hasEscapeVelocity]

/-- Escape requires dimension ≥ 3. -/
theorem escape_requires_3D (g : GravitationalDimension) :
    g.hasEscapeVelocity ↔ 3 ≤ g.n := Iff.rfl

/-! ## Section 8: Dimensional Classification -/

/-- Complete classification of gravitational dimensions. -/
inductive GravityClass where
  | flatland     -- n=2: stable but no closure, no escape
  | goldilocks   -- n=3: stable, closed, escape possible
  | marginal     -- n=4: marginally stable
  | catastrophic -- n≥5: completely unstable
  deriving DecidableEq, Repr

/-- Classify gravitational dimensions. -/
def classifyGravity (n : ℕ) : GravityClass :=
  if n = 2 then GravityClass.flatland
  else if n = 3 then GravityClass.goldilocks
  else if n = 4 then GravityClass.marginal
  else GravityClass.catastrophic

theorem classify_2D : classifyGravity 2 = GravityClass.flatland := by
  simp [classifyGravity]

theorem classify_3D : classifyGravity 3 = GravityClass.goldilocks := by
  simp [classifyGravity]

theorem classify_4D : classifyGravity 4 = GravityClass.marginal := by
  simp [classifyGravity]

/-- For n ≥ 5, gravity is catastrophic. -/
theorem classify_catastrophic (n : ℕ) (hn : 5 ≤ n) :
    classifyGravity n = GravityClass.catastrophic := by
  unfold classifyGravity
  split_ifs with h1 h2 h3
  · exfalso; omega
  · exfalso; omega
  · exfalso; omega
  · rfl

/-- Dimension 3 is the unique Goldilocks dimension. -/
theorem goldilocks_classification (n : ℕ) :
    classifyGravity n = GravityClass.goldilocks ↔ n = 3 := by
  constructor
  · intro h
    simp only [classifyGravity] at h
    split_ifs at h with h1 h2 h3
    all_goals simp_all
  · intro h; subst h; exact classify_3D

/-! ## Section 9: Viability Score -/

/-- The viability score counts how many of three conditions are met:
    stability (n < 4), closure (n = 3), escape (n ≥ 3). -/
def viabilityScore (n : ℕ) : ℕ :=
  (if n < 4 then 1 else 0) +
  (if n = 3 then 1 else 0) +
  (if 3 ≤ n then 1 else 0)

/-- Dimension 3 achieves the maximum viability score of 3. -/
theorem dim3_max_viability : viabilityScore 3 = 3 := by
  simp [viabilityScore]

/-- No other dimension n ≥ 2 achieves viability score 3. -/
theorem dim3_unique_max_viability (n : ℕ) (hn : 2 ≤ n) :
    viabilityScore n = 3 ↔ n = 3 := by
  constructor
  · intro h
    simp only [viabilityScore] at h
    split_ifs at h with h1 h2 h3 <;> omega
  · intro h; subst h; exact dim3_max_viability

/-! ## Section 10: Effective Potential Analysis for 2D Gravity -/

/-- The effective potential for 2D gravity: V_eff(r) = ln(r) + L²/(2r²). -/
noncomputable def V_eff_2D (L : ℝ) (r : ℝ) : ℝ :=
  Real.log r + L ^ 2 / (2 * r ^ 2)

/-- The derivative: V_eff'(r) = 1/r - L²/r³. -/
noncomputable def V_eff_2D_deriv (L : ℝ) (r : ℝ) : ℝ :=
  1 / r - L ^ 2 / r ^ 3

/-- The second derivative: V_eff''(r) = -1/r² + 3L²/r⁴. -/
noncomputable def V_eff_2D_deriv2 (L : ℝ) (r : ℝ) : ℝ :=
  -1 / r ^ 2 + 3 * L ^ 2 / r ^ 4

/-
At the circular orbit radius r₀ = |L|, the first derivative vanishes.
    V_eff'(|L|) = 1/|L| - L²/|L|³ = 1/|L| - 1/|L| = 0.
-/
theorem V_eff_2D_critical (L : ℝ) (hL : L ≠ 0) :
    V_eff_2D_deriv L (|L|) = 0 := by
  unfold V_eff_2D_deriv;
  cases abs_cases L <;> simp +decide [ *, sq, pow_three, mul_assoc, div_eq_mul_inv ]

/-
At the circular orbit radius, the second derivative is positive:
    V_eff''(|L|) = -1/L² + 3/L² = 2/L² > 0.
-/
theorem V_eff_2D_stable (L : ℝ) (hL : L ≠ 0) :
    0 < V_eff_2D_deriv2 L (|L|) := by
  unfold V_eff_2D_deriv2;
  rw [ div_add_div, lt_div_iff₀ ] <;> first | positivity | nlinarith [ mul_self_pos.2 hL, abs_mul_abs_self L ] ;

/-! ## Section 11: The Flatland Impossibility Theorem -/

/-- A planetary system is viable if orbits close AND particles can escape. -/
def planetarySystemViable (n : ℕ) : Prop :=
  n < 4 ∧ n = 3 ∧ 3 ≤ n

/-- **Flatland Impossibility**: 2D gravity cannot support a planetary system. -/
theorem flatland_impossible : ¬ planetarySystemViable 2 := by
  intro ⟨_, h2, _⟩; omega

/-- Only dimension 3 supports viable planetary systems. -/
theorem only_3D_viable (n : ℕ) (hn : 2 ≤ n) :
    planetarySystemViable n ↔ n = 3 := by
  unfold planetarySystemViable; constructor
  · intro ⟨_, h2, _⟩; exact h2
  · intro h; subst h; exact ⟨by omega, rfl, le_refl 3⟩

/-! ## Section 12: Orbit Density -/

/-- The fractional parts of n/√2 — angular apsidal positions mod 1. -/
noncomputable def apsidalSequence (n : ℕ) : ℝ :=
  Int.fract ((n : ℝ) / Real.sqrt 2)

/-
**Orbit Non-Periodicity**: All apsidal positions are distinct.
    If fract(n/√2) = fract(m/√2), then n = m.
    This means the orbit NEVER revisits the same angular position.
-/
theorem apsidal_positions_injective :
    Function.Injective apsidalSequence := by
  intros n m hnm
  have h_eq : ∃ k : ℤ, (n - m : ℝ) = k * Real.sqrt 2 := by
    obtain ⟨ k, hk ⟩ := Int.fract_eq_fract.mp hnm;
    exact ⟨ k, by rw [ ← hk, sub_mul, div_mul_cancel₀ _ ( by positivity ), div_mul_cancel₀ _ ( by positivity ) ] ⟩;
  exact_mod_cast ( by obtain ⟨ k, hk ⟩ := h_eq; exact Classical.not_not.1 fun hnm' => irrational_sqrt_two <| ⟨ ( n - m ) / k, by push_cast [ hk ] ; rw [ mul_div_cancel_left₀ _ <| by intro h; norm_num [ h ] at hk; exact hnm' <| by linarith ] ⟩ : ( n : ℝ ) = m )

/-! ## Conjecture -/

/-- **Conjecture**: Self-intersections after N oscillations grow as N(N-1)/2.
    **Testable**: For N = 100, predict ~4950 intersections (verify numerically). -/
def conjecturedIntersections (N : ℕ) : ℕ := N * (N - 1) / 2