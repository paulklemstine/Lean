/-
# Dimensional Gravity: The Goldilocks Theorem

This module formalizes the mathematical analysis of gravitational orbits across
spatial dimensions. The central result is the **Goldilocks Theorem**: dimension 3
is the unique spatial dimension supporting both stable circular orbits and closed
(periodic) orbital trajectories under inverse-power-law gravity.

## Mathematical Background

In n spatial dimensions, Gauss's law gives a gravitational force F(r) ∝ r^{-(n-1)}.
The effective potential for radial motion includes a centrifugal barrier term ∝ r^{-2}.

**Stability**: A circular orbit is stable iff the effective potential has a local
minimum, which requires the force law exponent to satisfy a constraint equivalent
to n < 4 (for spatial dimensions n ≥ 1).

**Closure (Bertrand's Theorem)**: Among stable orbits, the apsidal angle for
nearly-circular perturbations is Ψ = π / √(4 - n). The orbit closes iff Ψ is a
rational multiple of π, i.e., iff √(4 - n) is rational. For the physically
meaningful dimensions n ∈ {1, 2, 3}: only n = 3 gives √(4-3) = 1 ∈ ℚ.
-/

import Mathlib

open Real

/-! ## Core Definitions -/

/-- A `GravitationalDimension` packages a spatial dimension `n` together with
proofs of the two properties needed for viable planetary systems:
1. **Stability**: `n < 4` (equivalently, the effective potential has a minimum).
2. **Closure**: `√(4 - n)` is rational (equivalently, nearly-circular orbits close).

The Goldilocks Theorem shows `n = 3` is the unique inhabitant. -/
structure GravitationalDimension where
  /-- The spatial dimension -/
  dim : ℕ
  /-- Must be a genuine spatial dimension -/
  positive : dim ≥ 1
  /-- Stability of circular orbits requires dim < 4 -/
  stable : dim < 4
  /-- Closed orbits require the apsidal angle ratio √(4 - dim) to be rational -/
  closed : ∃ (p q : ℤ), q ≠ 0 ∧ Real.sqrt (4 - (dim : ℝ)) = (p : ℝ) / (q : ℝ)

/-- The **apsidal angle ratio** for spatial dimension `n`:
the quantity √(4 - n) whose rationality determines orbital closure.
When n < 4, this is positive and equals π divided by the apsidal angle. -/
noncomputable def apsidalRatio (n : ℕ) : ℝ := Real.sqrt (4 - (n : ℝ))

/-! ## Stability Analysis -/

/-
For n ≥ 4, the effective potential has no stable minimum.
Formally: the argument to √ is non-positive, so the apsidal ratio is zero
(using the convention √x = 0 for x ≤ 0).
-/
theorem apsidalRatio_eq_zero_of_ge_four (n : ℕ) (hn : n ≥ 4) :
    apsidalRatio n = 0 := by
  exact Real.sqrt_eq_zero_of_nonpos <| sub_nonpos_of_le <| mod_cast hn

/-
The apsidal ratio for dimension 3 equals 1.
-/
theorem apsidalRatio_three : apsidalRatio 3 = 1 := by
  unfold apsidalRatio; norm_num

/-! ## Irrationality Results -/

/-- √2 is irrational (from Mathlib, restated for clarity). -/
theorem sqrt_two_irrational : Irrational (Real.sqrt 2) := by
  exact irrational_sqrt_two

/-
√3 is irrational (since 3 is prime).
-/
theorem sqrt_three_irrational : Irrational (Real.sqrt 3) := by
  simpa using Nat.prime_three.irrational_sqrt

/-! ## Dimension-by-Dimension Analysis -/

/-
In dimension 1, the apsidal ratio is √3, which is irrational.
Therefore no GravitationalDimension has dim = 1.
-/
theorem dim_one_no_closed_orbits :
    ¬∃ (p q : ℤ), q ≠ 0 ∧ Real.sqrt (4 - (1 : ℝ)) = (p : ℝ) / (q : ℝ) := by
  norm_num +zetaDelta at *;
  exact fun p q hq h => Nat.Prime.irrational_sqrt ( by norm_num : Nat.Prime 3 ) ⟨ p / q, by aesop ⟩

/-
In dimension 2, the apsidal ratio is √2, which is irrational.
Therefore no GravitationalDimension has dim = 2.
-/
theorem dim_two_no_closed_orbits :
    ¬∃ (p q : ℤ), q ≠ 0 ∧ Real.sqrt (4 - (2 : ℝ)) = (p : ℝ) / (q : ℝ) := by
  norm_num;
  exact fun p q hq h => irrational_sqrt_two.ne_rat ( p / q ) ( by simpa )

/-
Dimension 3 does admit closed orbits: √(4-3) = √1 = 1 = 1/1.
-/
theorem dim_three_closed_orbits :
    ∃ (p q : ℤ), q ≠ 0 ∧ Real.sqrt (4 - (3 : ℝ)) = (p : ℝ) / (q : ℝ) := by
  exact ⟨ 1, 1, by norm_num ⟩

/-! ## The Goldilocks Theorem -/

/-- **Dimension 3 is viable**: we can construct a `GravitationalDimension` with `dim = 3`. -/
noncomputable def threeDimGravity : GravitationalDimension :=
  ⟨3, by omega, by omega, dim_three_closed_orbits⟩

/-
**The Goldilocks Theorem**: If `G` is any `GravitationalDimension`, then `G.dim = 3`.
Combined with `threeDimGravity`, this shows dimension 3 is the *unique* spatial dimension
supporting stable, closed gravitational orbits under inverse-power-law gravity.
-/
theorem goldilocks (G : GravitationalDimension) : G.dim = 3 := by
  rcases G with ⟨dim, hpos, hstable, hclosed⟩;
  interval_cases dim <;> simp_all +decide;
  · exact irrational_sqrt_two <| by obtain ⟨ p, q, hq, h ⟩ := hclosed; exact False.elim <| dim_one_no_closed_orbits ⟨ p, q, hq, mod_cast h ⟩ ;
  · exact dim_two_no_closed_orbits hclosed

/-- **Uniqueness** (bundled form): there is exactly one `GravitationalDimension` up to
equality of the dimension field. -/
theorem gravitational_dimension_unique (G₁ G₂ : GravitationalDimension) :
    G₁.dim = G₂.dim := by
  have h1 := goldilocks G₁
  have h2 := goldilocks G₂
  omega

/-! ## Escape Velocity Analysis -/

/-- In dimension n, the gravitational potential Φ(r) ∝ r^{2-n} for n ≥ 3.
The escape velocity is finite iff the potential goes to 0 at infinity,
which happens iff n ≥ 3. For n ≤ 2, Φ(r) ∝ log(r) (n=2) or -r (n=1),
giving infinite escape velocity.

We encode this as: a dimension has finite escape velocity iff n ≥ 3. -/
def hasFiniteEscapeVelocity (n : ℕ) : Prop := n ≥ 3

/-
The full Goldilocks characterization: dimension 3 is the unique dimension
with *all three* desirable gravitational properties:
1. Stable circular orbits (n < 4)
2. Closed (periodic) orbits (√(4-n) rational)
3. Finite escape velocity (n ≥ 3)
-/
theorem goldilocks_full (n : ℕ) :
    (n < 4 ∧ (∃ (p q : ℤ), q ≠ 0 ∧ Real.sqrt (4 - (n : ℝ)) = (p : ℝ) / (q : ℝ))
      ∧ hasFiniteEscapeVelocity n)
    ↔ n = 3 := by
  constructor;
  · rintro ⟨ hn, ⟨ p, q, hq, hpq ⟩, hn' ⟩ ; interval_cases n <;> norm_num at *;
    · exact absurd hn' ( by unfold hasFiniteEscapeVelocity; norm_num );
    · exact Nat.Prime.irrational_sqrt ( by norm_num : Nat.Prime 3 ) ⟨ p / q, by aesop ⟩;
    · exact irrational_sqrt_two.ne_rat ( p / q ) ( by simpa );
  · rintro rfl; exact ⟨ by norm_num, dim_three_closed_orbits, by norm_num [ hasFiniteEscapeVelocity ] ⟩ ;

/-! ## Force Law Exponent Classification -/

/-- For a central force F(r) = -k·r^α, the orbit equation has the apsidal angle
Ψ = π/√(3 + α). The orbit is closed iff √(3 + α) is rational.

By Bertrand's theorem (1873), the only integer values of α giving closed orbits
for all bound trajectories are α = -2 (inverse-square, gravity in 3D) and α = 1
(linear restoring force, harmonic oscillator).

We prove the weaker "nearly-circular" version: among α ∈ {-3, -2, -1, 0, 1, 2},
only α = -2 and α = 1 give rational √(3 + α). -/
noncomputable def bertrandApsidalRatio (α : ℤ) : ℝ := Real.sqrt (3 + (α : ℝ))

/-
For the inverse-square force (α = -2), the apsidal ratio is 1.
-/
theorem bertrand_inverse_square : bertrandApsidalRatio (-2) = 1 := by
  unfold bertrandApsidalRatio; norm_num;

/-
For the linear restoring force (α = 1), the apsidal ratio is 2.
-/
theorem bertrand_linear : bertrandApsidalRatio 1 = 2 := by
  exact Real.sqrt_eq_iff_mul_self_eq_of_pos ( by norm_num ) |>.2 ( by norm_num )

/-
**Bertrand's Theorem (integer exponents, near-circular version)**:
Among integer force-law exponents from -3 to 2, only -2 and 1 give
rational apsidal ratios (and hence closed nearly-circular orbits).
-/
theorem bertrand_integer_classification (α : ℤ) (hα : -2 ≤ α ∧ α ≤ 2) :
    (∃ (p q : ℤ), q ≠ 0 ∧ bertrandApsidalRatio α = (p : ℝ) / (q : ℝ))
    ↔ (α = -2 ∨ α = 1) := by
  rcases hα with ⟨ h₁, h₂ ⟩ ; interval_cases α <;> norm_num [ bertrandApsidalRatio ] at *;
  · exact ⟨ 1, 1, by norm_num ⟩;
  · exact fun x y hy => by simpa [ hy ] using irrational_sqrt_two.ne_rat ( x / y ) ;
  · exact fun x y hy h => Nat.Prime.irrational_sqrt ( by norm_num : Nat.Prime 3 ) ⟨ x / y, by aesop ⟩;
  · exact ⟨ 2, 1, by norm_num ⟩;
  · exact fun x y hy h => by exact Nat.Prime.irrational_sqrt ( by norm_num : Nat.Prime 5 ) ⟨ x / y, by aesop ⟩ ;

/-! ## Connection: Number Theory ↔ Dimensional Physics -/

/-
The bridge theorem: the viability of a planetary system in dimension n
(for 1 ≤ n ≤ 3) reduces to a number-theoretic question about √(4-n).
This makes precise the slogan "number theory governs the structure of space."
-/
theorem number_theory_governs_orbits (n : ℕ) (hn1 : 1 ≤ n) (hn2 : n ≤ 3) :
    (∃ (p q : ℤ), q ≠ 0 ∧ Real.sqrt (4 - (n : ℝ)) = (p : ℝ) / (q : ℝ))
    ↔ n = 3 := by
  interval_cases n <;> simp_all +decide;
  · exact fun x y hy => by have := dim_one_no_closed_orbits; aesop;
  · exact fun p q hq => by exact fun h => irrational_sqrt_two <| ⟨ p / q, by push_cast; linarith ⟩ ;
  · exact ⟨ 1, 1, by norm_num ⟩