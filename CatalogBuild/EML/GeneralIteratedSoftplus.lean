/-! # CatalogBuild.EML.GeneralIteratedSoftplus

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 8
-/

import EML.Lean.AdvancedTheorems
import EML.Lean.SoftplusBasic
import Mathlib

noncomputable section

/-- Key lemma: σ(log(n + eˣ)) = log(n + 1 + eˣ) for natural n.
This is the recurrence underlying the general iterated identity. -/
theorem softplus_log_add_exp (n : ℕ) (x : ℝ) :
    softplus (Real.log (↑n + Real.exp x)) = Real.log (↑n + 1 + Real.exp x) := by
  unfold softplus
  rw [Real.exp_log (by positivity)]
  congr 1
  push_cast
  ring


/-- **General Iterated Softplus Identity**: σⁿ(x) = log(n + eˣ) for all n ∈ ℕ, x ∈ ℝ.
This vastly generalizes σⁿ(0) = log(n+1) to arbitrary starting points.
The formula reveals that iterated softplus interpolates between:
- x (for n = 0, since log(0 + eˣ) = x)
- log(n) (for large n, since log(n + eˣ) ≈ log(n) for fixed x) -/
theorem softplus_iter_general (n : ℕ) (x : ℝ) :
    softplus_iter n x = Real.log (↑n + Real.exp x) := by
  induction n with
  | zero => simp [softplus_iter, Real.log_exp]
  | succ k ih =>
    simp only [softplus_iter, Function.comp]
    rw [ih, softplus_log_add_exp]
    congr 1
    push_cast
    ring


/-- Special case: recovering σⁿ(0) = log(n+1) from the general formula. -/
theorem softplus_iter_zero_eq' (n : ℕ) :
    softplus_iter n 0 = Real.log (↑n + 1) := by
  rw [softplus_iter_general]
  simp [Real.exp_zero]


/-- The difference between iterates from different starting points contracts:
σⁿ(x) - σⁿ(y) = log((n + eˣ)/(n + eʸ)) → 0 as n → ∞.
This means all orbits of the softplus dynamical system merge. -/
theorem softplus_iter_diff (n : ℕ) (x y : ℝ) :
    softplus_iter n x - softplus_iter n y =
    Real.log ((↑n + Real.exp x) / (↑n + Real.exp y)) := by
  rw [softplus_iter_general, softplus_iter_general, ← Real.log_div (by positivity) (by positivity)]


/-- Iterated softplus is monotone in the starting point for each n. -/
theorem softplus_iter_mono_start (n : ℕ) {x y : ℝ} (hxy : x ≤ y) :
    softplus_iter n x ≤ softplus_iter n y := by
  exact (softplus_iter_strictMono n).monotone hxy


/-- σⁿ(x) ≥ log(n + 1) for all x ≥ 0 and n ≥ 0. -/
theorem softplus_iter_lower_general (n : ℕ) (x : ℝ) (hx : x ≥ 0) :
    softplus_iter n x ≥ Real.log (↑n + 1) := by
  rw [softplus_iter_general]
  apply Real.log_le_log (by positivity)
  have : Real.exp x ≥ 1 := Real.one_le_exp hx
  linarith


/-- σⁿ(x) ≤ log(n + eˣ) is just the identity restated. -/
theorem softplus_iter_exact (n : ℕ) (x : ℝ) :
    softplus_iter n x = Real.log (↑n + Real.exp x) :=
  softplus_iter_general n x


/-- For the dynamical system xₙ₊₁ = σ(xₙ), the orbit from x grows as:
σⁿ(x) = log(n) + log(1 + eˣ/n), showing logarithmic growth
with a correction term that vanishes. -/
theorem softplus_iter_growth (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    softplus_iter n x = Real.log ↑n + Real.log (1 + Real.exp x / ↑n) := by
  rw [softplus_iter_general]
  rw [show (↑n : ℝ) + Real.exp x = ↑n * (1 + Real.exp x / ↑n) from by
    field_simp]
  rw [Real.log_mul (by positivity) (by positivity)]


end
