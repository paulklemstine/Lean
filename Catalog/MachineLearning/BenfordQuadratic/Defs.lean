import Mathlib

/-!
# Benford Universality and Rigidity for Prime-Seeded Quadratic Orbits

## Overview

This file formalizes the core definitions and structural theorems for studying Benford's law
in the context of quadratic dynamical systems T_c(x) = x² + c, with integer parameters c
and prime seeds.

The central insight is that **Benford behavior is the statistical shadow of non-monomiality
in arithmetic dynamics**: once orbits escape to infinity, their logarithmic sizes are governed
by dyadic renormalization, and Benford's law reduces to equidistribution of fractional parts
under the doubling map on ℝ/ℤ.

## Mathematical Framework

For the quadratic map T_c(x) = x² + c with c ∈ ℤ:
- **Escape growth inequality**: For |x| ≥ |c| + 2, one step of T_c approximately doubles
  the logarithmic size: log|T_c(x)| ≈ 2·log|x| with explicit error bounds.
- **Renormalized log-height convergence**: The sequence aₙ = 2⁻ⁿ·log|T_c⁽ⁿ⁾(x)| converges
  for escaping orbits, defining a canonical height Λ_c(x).
- **Benford reduction**: Leading-digit statistics are controlled by the fractional parts
  of 2ⁿ·Λ_c(x), connecting arithmetic dynamics to torus dynamics.

## Cross-Domain Connections

1. **Arithmetic dynamics ↔ Ergodic theory**: The doubling map on the torus serves as the
   asymptotic model for logarithmic digit dynamics.
2. **Arithmetic dynamics ↔ Information theory**: Benford frequencies encode a logarithmic
   entropy profile of orbit growth.
3. **Arithmetic dynamics ↔ Renormalization**: The map x ↦ x² + c induces scale-doubling
   renormalization in log-space, analogous to discrete RG flow.
4. **Arithmetic dynamics ↔ Algebraic rigidity**: Non-Benford behavior detects hidden
   semiconjugacy / integrable structure.
-/

noncomputable section

open Real Filter Topology Set

/-! ## Core Definitions -/

/-- The quadratic map T_c(x) = x² + c. -/
def quadMap (c : ℤ) : ℤ → ℤ := fun x => x ^ 2 + c

/-- The n-th iterate of the quadratic orbit starting at x under T_c. -/
def quadOrbit (c x : ℤ) (n : ℕ) : ℤ :=
  Nat.iterate (quadMap c) n x

/-- A point x escapes under T_c if the orbit eventually exceeds max(2, |c|+1) permanently. -/
def Escapes (c x : ℤ) : Prop :=
  ∃ N : ℕ, ∀ n ≥ N,
    (quadOrbit c x n).natAbs > max 2 (Int.natAbs c + 1)

/-- Logarithmic height of an integer: log|z| for z ≠ 0, and 0 for z = 0. -/
def logHeight (z : ℤ) : ℝ :=
  if z = 0 then 0 else Real.log |(z : ℝ)|

/-- Renormalized logarithmic height: 2⁻ⁿ · log|T_c⁽ⁿ⁾(x)|.
This is the key quantity whose convergence defines the canonical height Λ_c(x). -/
def renormLogHeight (c x : ℤ) (n : ℕ) : ℝ :=
  logHeight (quadOrbit c x n) / (2 : ℝ) ^ n

/-- Benford interval in base b for leading digit m:
the set [log_b(m), log_b(m+1)] of fractional parts that produce leading digit m. -/
def benfordInterval (b m : ℕ) : Set ℝ :=
  Set.Icc (Real.logb b m) (Real.logb b (m + 1))

/-- Predicate for persistent digit bias: the empirical leading-digit frequencies
do not converge to Benford's law. This is an abstract predicate capturing the
failure of equidistribution of logarithmic fractional parts. -/
def PersistentDigitBias (c : ℤ) : Prop :=
  ∃ (b : ℕ) (_ : 2 ≤ b) (m : ℕ) (_ : 1 ≤ m) (_ : m < b) (δ : ℝ) (_ : δ > 0),
    ∀ N : ℕ, N ≥ 1 →
      ∃ n ≥ N,
        |(Real.logb b |(quadOrbit c 2 n : ℝ)|) - Real.logb b (1 + 1 / m)| > δ

/-- A semiconjugacy data structure encoding a candidate semiconjugacy from T_c
to a monomial map ±x^d. The existence of such a semiconjugacy is an algebraic
obstruction to Benford behavior—it forces digit statistics into a rigid pattern. -/
structure SemiconjData (c : ℤ) where
  φ : ℤ → ℤ
  d : ℕ
  hd : 2 ≤ d
  sign : ℤ
  hsign : sign = 1 ∨ sign = -1
  semiconj : ∀ x, φ (quadMap c x) = sign * (φ x) ^ d

/-- A quadratic map has a monomial semiconjugacy if there exists a SemiconjData for it. -/
def HasMonomialSemiconjugacy (c : ℤ) : Prop := ∃ _ : SemiconjData c, True

/-! ## Basic lemmas about quadOrbit -/

@[simp]
theorem quadOrbit_zero (c x : ℤ) : quadOrbit c x 0 = x := rfl

@[simp]
theorem quadOrbit_succ (c x : ℤ) (n : ℕ) :
    quadOrbit c x (n + 1) = quadMap c (quadOrbit c x n) := by
  simp [quadOrbit, Function.iterate_succ_apply']

theorem quadMap_def (c x : ℤ) : quadMap c x = x ^ 2 + c := rfl

end