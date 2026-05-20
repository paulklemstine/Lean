/-
# Erdős–Straus: Parametric Families

This module proves that infinite families of integers satisfy the
Erdős–Straus conjecture via explicit symbolic constructions.

## Main results

* `erdos_straus_even` — Every even n ≥ 2 has a decomposition:
    4/(2m) = 1/m + 1/(2m) + 1/(2m)

* `erdos_straus_mod4_eq3` — Every n ≡ 3 (mod 4) has a decomposition:
    4/(4k+3) = 1/(k+2) + 1/((k+1)(k+2)) + 1/((k+1)(4k+3))

Together these cover 3/4 of all positive integers ≥ 2.
-/

import Mathlib
import Speculative.ErdosStraus.Defs

/-! ## Even family: 4/(2m) = 1/m + 1/(2m) + 1/(2m) -/

/-
Every even number 2m (m ≥ 1) satisfies the Erdős–Straus equation.
    The identity: 4/(2m) = 2/(2m) + 1/(2m) + 1/(2m) = 1/m + 1/(2m) + 1/(2m).
-/
noncomputable def erdos_straus_even
    (m : ℕ) (hm : 1 ≤ m) :
    ESDecomposition (2 * m) where
  x := m
  y := 2 * m
  z := 2 * m
  hx := hm
  hy := by linarith
  hz := by linarith
  eqn := by
    push_cast; ring

/-
Every even n ≥ 2 admits a decomposition.
-/
theorem erdos_straus_of_even
    (n : ℕ) (hn : 2 ≤ n) (he : Even n) :
    ∃ d : ESDecomposition n, True := by
  obtain ⟨ m, rfl ⟩ := he;
  use ⟨ m, 2 * m, 2 * m, by linarith, by linarith, by linarith, by push_cast; ring ⟩

/-! ## Residue class n ≡ 3 (mod 4)

The identity used is:
  4/(4k+3) = 1/(k+2) + 1/((k+1)(k+2)) + 1/((k+1)(4k+3))

Derivation: Start from the 2-term decomposition
  4/(4k+3) = 1/(k+1) + 1/((k+1)(4k+3))
since 4(k+1) - (4k+3) = 1, so 4/(4k+3) - 1/(k+1) = 1/((k+1)(4k+3)).

Then split 1/(k+1) using partial fractions:
  1/(k+1) = 1/(k+2) + 1/((k+1)(k+2))

Combining: 4/(4k+3) = 1/(k+2) + 1/((k+1)(k+2)) + 1/((k+1)(4k+3)).
-/

/-
Every n ≡ 3 (mod 4) satisfies the Erdős–Straus equation.
    Uses the parametric family with n = 4k+3.
-/
noncomputable def erdos_straus_mod4_eq3
    (k : ℕ) :
    ESDecomposition (4 * k + 3) where
  x := k + 2
  y := (k + 1) * (k + 2)
  z := (k + 1) * (4 * k + 3)
  hx := by omega
  hy := by nlinarith
  hz := by nlinarith
  eqn := by
    grind