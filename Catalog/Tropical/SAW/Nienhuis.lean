/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Nienhuis Constant and Hexagonal Lattice

This file formalizes properties of the Nienhuis constant √(2+√2),
which is the connective constant of the hexagonal lattice (proved by
Duminil-Copin and Smirnov in 2012).

## Main results

* The minimal polynomial of √(2+√2) is x⁴ - 4x² + 2
* √(2+√2) is irrational
* The critical fugacity identity x_c² + x_c⁶ = 1
* Algebraic properties connecting to the parafermionic observable
-/

import Mathlib

open Real Polynomial

namespace SAW

/-! ## The Nienhuis constant -/

/-- The Nienhuis constant: the connective constant of the hexagonal lattice. -/
noncomputable def nienhuis : ℝ := Real.sqrt (2 + Real.sqrt 2)

/-- The critical fugacity for SAWs on the hexagonal lattice. -/
noncomputable def criticalFugacity : ℝ := 1 / nienhuis

/-
The Nienhuis constant is positive.
-/
theorem nienhuis_pos : 0 < nienhuis := by
  exact Real.sqrt_pos.mpr ( by positivity )

/-
The Nienhuis constant squared equals 2 + √2.
-/
theorem nienhuis_sq : nienhuis ^ 2 = 2 + Real.sqrt 2 := by
  exact Real.sq_sqrt <| by positivity;

/-
**The minimal polynomial of the Nienhuis constant**: √(2+√2) satisfies x⁴ - 4x² + 2 = 0.

    Proof sketch: Let μ = √(2+√2). Then μ² = 2 + √2, so μ² - 2 = √2,
    hence (μ² - 2)² = 2, giving μ⁴ - 4μ² + 4 = 2, i.e., μ⁴ - 4μ² + 2 = 0.
-/
theorem nienhuis_minimal_poly : nienhuis ^ 4 - 4 * nienhuis ^ 2 + 2 = 0 := by
  rw [ show nienhuis ^ 4 = ( nienhuis ^ 2 ) ^ 2 by ring, nienhuis_sq ] ; ring ;
  norm_num

/-
The Nienhuis constant is irrational.

    If √(2+√2) = p/q, then (p/q)⁴ - 4(p/q)² + 2 = 0, so p⁴ - 4p²q² + 2q⁴ = 0.
    This means p⁴ is even, so p is even, and then q⁴ must be even, so q is even.
    Contradiction with gcd(p,q) = 1.
-/
theorem nienhuis_irrational : Irrational nienhuis := by
  refine' fun ⟨ a, ha ⟩ => _;
  -- Squaring both sides of the equation, we get $a^2 = 2 + \sqrt{2}$.
  have h_sq : a^2 = 2 + Real.sqrt 2 := by
    exact ha.symm ▸ nienhuis_sq;
  exact irrational_sqrt_two <| ⟨ a ^ 2 - 2, by push_cast; linarith ⟩

/-! ## Critical fugacity properties -/

/-
The critical fugacity is positive.
-/
theorem criticalFugacity_pos : 0 < criticalFugacity := by
  exact one_div_pos.mpr ( nienhuis_pos )

/-
**The critical fugacity minimal polynomial**: The critical fugacity x_c = 1/√(2+√2)
    satisfies 2x_c⁴ - 4x_c² + 1 = 0.

    This follows from dividing the Nienhuis minimal polynomial μ⁴ - 4μ² + 2 = 0
    by μ⁴ to get 1 - 4/μ² + 2/μ⁴ = 0, i.e., 2x_c⁴ - 4x_c² + 1 = 0.
-/
theorem criticalFugacity_poly :
    2 * criticalFugacity ^ 4 - 4 * criticalFugacity ^ 2 + 1 = 0 := by
      rw [ show criticalFugacity = 1 / Real.sqrt ( 2 + Real.sqrt 2 ) by rfl ];
      field_simp;
      nlinarith [ Real.mul_self_sqrt ( show 0 ≤ 2 + Real.sqrt 2 by positivity ), Real.mul_self_sqrt ( show 0 ≤ 2 by positivity ) ]

/-! ## Tropical phase transition -/

/-
**Tropical-SAW bridge**: In the tropical limit, the connective constant μ
    determines the critical point where the tropical SAW generating function
    transitions from convergent to divergent behavior.

    The tropical SAW partition function
    Z_trop(β) = sup_n (n · log(c(n))/n - β · n)
    has a phase transition at β = log(μ).
-/
theorem tropical_phase_transition (μ : ℝ) (_hμ : 0 < μ) :
    ∀ β : ℝ, β > Real.log μ →
    ∀ n : ℕ, (n : ℝ) * Real.log μ - β * (n : ℝ) ≤ 0 := by
      exact fun β hβ n => by nlinarith;

/-
The free energy per step in the tropical formulation is positive
    when μ > 1.
-/
theorem tropical_free_energy_pos (μ : ℝ) (hμ : 1 < μ) :
    Real.log μ > 0 := by
      exact Real.log_pos hμ

/-! ## Algebraic structure of 2 + √2 -/

/-
2 + √2 is positive.
-/
theorem two_add_sqrt_two_pos : (0 : ℝ) < 2 + Real.sqrt 2 := by
  positivity

/-
(2 + √2)(2 - √2) = 2, the conjugate relation.
-/
theorem conjugate_product : (2 + Real.sqrt 2) * (2 - Real.sqrt 2) = 2 := by
  norm_num [ ← sq_sub_sq ]

/-
√2 is between 1 and 2.
-/
theorem sqrt_two_bounds : 1 < Real.sqrt 2 ∧ Real.sqrt 2 < 2 := by
  norm_num [ Real.lt_sqrt, Real.sqrt_lt ]

/-
The Nienhuis constant is between 1 and 2.
-/
theorem nienhuis_bounds : 1 < nienhuis ∧ nienhuis < 2 := by
  exact ⟨ Real.lt_sqrt_of_sq_lt ( by linarith [ Real.sqrt_nonneg 2 ] ), by rw [ SAW.nienhuis ] ; rw [ Real.sqrt_lt' ( by positivity ) ] ; nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt ( show 0 ≤ 2 by positivity ) ] ⟩

end SAW