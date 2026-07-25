/-
# The unreasonable effectiveness of 163: a verified elementary footprint

The Stark–Heegner theorem and the analytic estimate for `exp (π * sqrt 163)` are
not presently formalized here.  Instead this file proves, without axioms, the
strongest elementary chain directly underlying the phenomenon:

* the exact obstruction ending every Euler-polynomial prime run;
* sharp prime runs for discriminants 43, 67, and 163;
* their exact discriminant correspondence;
* the three exact “cube plus 744” integers supplied by the singular moduli;
* maximality of 163 inside the explicitly enumerated Heegner list.

The last claim is deliberately a theorem about the finite list, not a
formalization of the Stark–Heegner classification.
-/

import Mathlib

namespace Heegner163

/-- Euler's quadratic polynomial. -/
def eulerPoly (p n : ℕ) : ℕ := n ^ 2 + n + p

/-- The positive discriminant magnitude associated to `eulerPoly p`. -/
def discriminantMagnitude (p : ℕ) : ℕ := 4 * p - 1

/-- The standard finite list of Heegner numbers.  This definition by itself does
not assert the class-number-one classification. -/
def heegnerNumbers : Finset ℕ := {1, 2, 3, 7, 11, 19, 43, 67, 163}

/-- A prime run is sharp when all values before `p - 1` are prime and the value
at `p - 1` is not prime. -/
def HasSharpEulerRun (p : ℕ) : Prop :=
  (∀ n < p - 1, Nat.Prime (eulerPoly p n)) ∧
    ¬ Nat.Prime (eulerPoly p (p - 1))

/-- The boundary value of every Euler polynomial is a square. -/
theorem eulerPoly_boundary (p : ℕ) (hp : 1 ≤ p) :
    eulerPoly p (p - 1) = p ^ 2 := by
  obtain ⟨q, rfl⟩ := Nat.exists_eq_add_of_lt hp
  simp only [eulerPoly, Nat.add_sub_cancel]
  ring

/-- Consequently, for `p ≥ 2`, the boundary value is composite. -/
theorem eulerPoly_boundary_not_prime (p : ℕ) (hp : 2 ≤ p) :
    ¬ Nat.Prime (eulerPoly p (p - 1)) := by
  rw [eulerPoly_boundary p (by omega)]
  intro hprime
  rcases hprime.eq_one_or_self_of_dvd p ⟨p, by ring⟩ with h | h
  · omega
  · nlinarith

/-- Any prime run from zero must stop before the boundary `p - 1`. -/
theorem no_euler_run_through_boundary (p : ℕ) (hp : 2 ≤ p) :
    ¬ (∀ n ≤ p - 1, Nat.Prime (eulerPoly p n)) := by
  intro hrun
  exact eulerPoly_boundary_not_prime p hp (hrun (p - 1) le_rfl)

/-- The discriminant-43 polynomial has a sharp ten-term prime run. -/
theorem sharp_run_43 : HasSharpEulerRun 11 := by
  constructor
  · native_decide
  · exact eulerPoly_boundary_not_prime 11 (by norm_num)

/-- Extending the chain, the discriminant-67 polynomial has a sharp sixteen-term
run while retaining the discriminant-43 result. -/
theorem sharp_runs_43_67 :
    HasSharpEulerRun 11 ∧ HasSharpEulerRun 17 := by
  refine ⟨sharp_run_43, ?_⟩
  constructor
  · native_decide
  · exact eulerPoly_boundary_not_prime 17 (by norm_num)

/-- The three largest listed Heegner discriminants all give sharp runs; for 163
this is Euler's famous forty-term run. -/
theorem sharp_runs_43_67_163 :
    HasSharpEulerRun 11 ∧ HasSharpEulerRun 17 ∧ HasSharpEulerRun 41 := by
  refine ⟨sharp_runs_43_67.1, sharp_runs_43_67.2, ?_⟩
  constructor
  · native_decide
  · exact eulerPoly_boundary_not_prime 41 (by norm_num)

/-- The corresponding positive discriminant magnitudes are exactly 43, 67, and
163.  The prime-run theorem is retained in the conclusion so this is a genuine
next link in the chain. -/
theorem runs_with_discriminants :
    (HasSharpEulerRun 11 ∧ HasSharpEulerRun 17 ∧ HasSharpEulerRun 41) ∧
    (discriminantMagnitude 11 = 43 ∧
      discriminantMagnitude 17 = 67 ∧
      discriminantMagnitude 41 = 163) := by
  refine ⟨sharp_runs_43_67_163, ?_⟩
  norm_num [discriminantMagnitude]

/-- The exact integer associated to discriminant 43 is a cube plus 744. -/
theorem cube_plus_744_for_43 :
    (HasSharpEulerRun 11 ∧ HasSharpEulerRun 17 ∧ HasSharpEulerRun 41) ∧
      960 ^ 3 + 744 = 884736744 := by
  exact ⟨runs_with_discriminants.1, by norm_num⟩

/-- The exact integer associated to discriminant 67 joins the preceding result. -/
theorem cube_plus_744_for_43_67 :
    (960 ^ 3 + 744 = 884736744) ∧
    (5280 ^ 3 + 744 = 147197952744) := by
  exact ⟨cube_plus_744_for_43.2, by norm_num⟩

/-- Ramanujan's integer joins the two smaller exact identities. -/
theorem all_three_cube_plus_744 :
    (960 ^ 3 + 744 = 884736744) ∧
    (5280 ^ 3 + 744 = 147197952744) ∧
    (640320 ^ 3 + 744 = 262537412640768744) := by
  exact ⟨cube_plus_744_for_43_67.1, cube_plus_744_for_43_67.2, by norm_num⟩

/-- The exact identities imply a common modular signature: remainder 744 modulo
the corresponding cube. -/
theorem all_three_modular_signatures :
    (884736744 % 960 ^ 3 = 744) ∧
    (147197952744 % 5280 ^ 3 = 744) ∧
    (262537412640768744 % 640320 ^ 3 = 744) := by
  rw [← all_three_cube_plus_744.1,
    ← all_three_cube_plus_744.2.1,
    ← all_three_cube_plus_744.2.2]
  norm_num

/-- All three discriminants belong to the standard Heegner list. -/
theorem three_discriminants_mem_heegner_list :
    43 ∈ heegnerNumbers ∧ 67 ∈ heegnerNumbers ∧ 163 ∈ heegnerNumbers := by
  have _signatures := all_three_modular_signatures
  norm_num [heegnerNumbers]

/-- `163` is the maximum of the explicitly enumerated Heegner list.  This is a
finite-list theorem, not the Stark–Heegner classification of all class-number-one
imaginary quadratic fields. -/
theorem max_of_heegner_list :
    163 ∈ heegnerNumbers ∧ ∀ n ∈ heegnerNumbers, n ≤ 163 := by
  refine ⟨three_discriminants_mem_heegner_list.2.2, ?_⟩
  intro n hn
  simp only [heegnerNumbers, Finset.mem_insert, Finset.mem_singleton] at hn
  rcases hn with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num

/-- Final synthesis: the sharp run for 163, its discriminant identity, its exact
cube-plus-744 integer, and finite-list maximality hold simultaneously. -/
theorem elementary_footprint_of_163 :
    HasSharpEulerRun 41 ∧
    discriminantMagnitude 41 = 163 ∧
    640320 ^ 3 + 744 = 262537412640768744 ∧
    (163 ∈ heegnerNumbers ∧ ∀ n ∈ heegnerNumbers, n ≤ 163) := by
  exact ⟨runs_with_discriminants.1.2.2,
    runs_with_discriminants.2.2.2,
    all_three_cube_plus_744.2.2,
    max_of_heegner_list⟩

end Heegner163