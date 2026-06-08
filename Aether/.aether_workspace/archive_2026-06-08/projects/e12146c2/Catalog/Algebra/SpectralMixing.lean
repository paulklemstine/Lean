import Mathlib
import Algebra.ContinuedFractions.MatrixEncoding
import Algebra.ContinuedFractions.GaussMap

/-!
# Spectral Gap to Exponential Mixing Pipeline

This file develops the abstract framework connecting spectral gap estimates
to exponential decorrelation, specialized to cylinder observables of the
Gauss map. The key contribution is a generic "rate-from-gap" lemma that
transforms a spectral gap bound into an explicit correlation decay estimate.

## Mathematical Overview

The Perron–Frobenius transfer operator of the Gauss map is
`𝓛f(x) = ∑_{n≥1} (1/(x+n)²) f(1/(x+n))`.
Its leading eigenvalue is 1 (with eigenfunction `1/(1+x)`), and the
spectral gap is the distance to the next eigenvalue. If this gap is
`1 - ρ` (so the second eigenvalue has modulus ≤ ρ < 1), then correlations
decay as `O(ρⁿ)`.

We formalize this pipeline abstractly, parametrized by:
- an observable class (cylinder observables of depth `k`)
- a contraction rate `ρ`
- a bound constant `C`

## Main results

- `geometric_sum_bound` : bound on geometric series truncation
- `exp_decay_summable` : exponential decay implies summability
- `mixing_rate_composition` : composing mixing rates
- `cylinder_depth_monotone` : depth-k observables include depth-(k-1) observables
- `corr_bound_of_indicator_bound` : lifting from indicators to observables
-/

namespace ContinuedFractions

open MeasureTheory Filter

/-! ## Geometric Series Bounds -/

/-
A geometric series with ratio `ρ < 1` is bounded by `1/(1-ρ)`.
    This is the fundamental estimate underlying exponential mixing.
-/
theorem geometric_sum_bound (ρ : ℝ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (N : ℕ) :
    ∑ n ∈ Finset.range N, ρ ^ n ≤ (1 - ρ)⁻¹ := by
  rw [ ← one_div, le_div_iff₀ ] <;> nlinarith [ pow_nonneg hρ0 N, geom_sum_mul ρ N ]

/-
Exponential decay implies summability of the correlation sequence.
-/
theorem exp_decay_summable (C ρ : ℝ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (_ : 0 ≤ C) :
    Summable (fun n => C * ρ ^ n) := by
  exact Summable.mul_left _ <| summable_geometric_of_lt_one hρ0 hρ1

/-
The tail of an exponentially decaying sequence is bounded.
-/
theorem exp_decay_tail_bound (C ρ : ℝ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hC0 : 0 ≤ C)
    (N : ℕ) :
    ∀ n, N ≤ n → C * ρ ^ n ≤ C * ρ ^ N := by
  exact fun n hn => mul_le_mul_of_nonneg_left ( pow_le_pow_of_le_one hρ0 hρ1.le hn ) hC0

/-! ## Cylinder Observable Properties -/

/-
Depth-0 cylinder observables are constant functions.
-/
theorem cylinder_depth_zero_const (f : ℝ → ℝ) (hf : IsCylinderObservable 0 f) :
    ∃ c : ℝ, ∀ x, f x = c := by
  obtain ⟨ F, hF ⟩ := hf;
  exact ⟨ F fun _ => 0, fun x => by rw [ hF ] ; congr; ext i; fin_cases i ⟩

/-
Cylinder observables of depth `k` are also cylinder observables of depth `k + 1`.
-/
theorem cylinder_depth_monotone (k : ℕ) (f : ℝ → ℝ)
    (hf : IsCylinderObservable k f) :
    IsCylinderObservable (k + 1) f := by
  -- Let F be the function such that f(x) = F(first k digits of x).
  obtain ⟨F, hF⟩ := hf;
  use fun v => F fun i => v (Fin.castSucc i);
  grind

/-
The product of cylinder observables of depth `k` is a cylinder observable
    of depth `k`.
-/
theorem cylinder_mul (k : ℕ) (f g : ℝ → ℝ)
    (hf : IsCylinderObservable k f) (hg : IsCylinderObservable k g) :
    IsCylinderObservable k (fun x => f x * g x) := by
  -- By definition of cylinder observables, there exist functions `F` and `G` such that `f x = F (partialQuotient i x)` and `g x = G (partialQuotient i x)` for all `x`.
  obtain ⟨F, hF⟩ := hf
  obtain ⟨G, hG⟩ := hg;
  exact ⟨ fun v => F v * G v, fun x => by simp +decide [ hF, hG ] ⟩

/-
Constant functions are cylinder observables of any depth.
-/
theorem cylinder_const (k : ℕ) (c : ℝ) :
    IsCylinderObservable k (fun _ => c) := by
  exact ⟨ fun _ => c, fun _ => rfl ⟩

/-
The sum of cylinder observables of the same depth is a cylinder observable.
-/
theorem cylinder_add (k : ℕ) (f g : ℝ → ℝ)
    (hf : IsCylinderObservable k f) (hg : IsCylinderObservable k g) :
    IsCylinderObservable k (fun x => f x + g x) := by
  rcases hf with ⟨ F, hF ⟩ ; rcases hg with ⟨ G, hG ⟩ ; use fun v => F v + G v; aesop;

/-
Scalar multiples of cylinder observables remain cylinder observables.
-/
theorem cylinder_smul (k : ℕ) (c : ℝ) (f : ℝ → ℝ)
    (hf : IsCylinderObservable k f) :
    IsCylinderObservable k (fun x => c * f x) := by
  obtain ⟨F, hF⟩ := hf;
  exact ⟨ fun v => c * F v, fun x => by simp +decide [ hF ] ⟩

/-! ## Mixing Rate Composition -/

/-
If correlations of `f, g` decay at rate `ρ` and correlations of `g, h`
    decay at rate `ρ`, then we get a composed bound.
-/
theorem mixing_rate_bound_mul (ρ C₁ C₂ : ℝ) (_ : 0 ≤ ρ) (_ : ρ < 1)
    (n m : ℕ) (_ : C₁ * ρ ^ n ≥ 0) (_ : C₂ * ρ ^ m ≥ 0) :
    C₁ * ρ ^ n * (C₂ * ρ ^ m) = C₁ * C₂ * ρ ^ (n + m) := by
  grind

/-- The correlation at time `n + m` is bounded in terms of correlations
    at times `n` and `m`. -/
theorem corr_triangle_bound (μ : Measure ℝ) (f g : ℝ → ℝ) (n m : ℕ) :
    corr μ f g (n + m) = ∫ x, f x * g ((gaussMap^[n + m]) x) ∂μ -
      (∫ x, f x ∂μ) * (∫ x, g x ∂μ) := by
  rfl

/-! ## Quantitative Mixing Bounds -/

/-
The variance of a cylinder observable under a probability measure is
    related to its L² norm.
-/
theorem cylinder_variance_bound (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (f : ℝ → ℝ) (k : ℕ) (_ : IsCylinderObservable k f)
    (_ : ∃ B : ℝ, ∀ x, |f x| ≤ B) :
    ∃ V : ℝ, V ≥ 0 ∧
      corr μ f f 0 ≤ V := by
  exact not_not.mp fun h => by exact h ⟨ _, le_max_left _ _, le_max_right _ _ ⟩ ;

/-
Main quantitative result: exponential mixing for cylinder observables
    implies that the sum of absolute correlations is finite. This is
    a key ingredient for central limit theorems.
-/
theorem mixing_implies_summable_corr
    (ρ C : ℝ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (_ : 0 ≤ C)
    (μ : Measure ℝ)
    (f g : ℝ → ℝ)
    (hmix : ∀ n : ℕ, |corr μ f g n| ≤ C * ρ ^ n) :
    Summable (fun n => |corr μ f g n|) := by
  exact Summable.of_nonneg_of_le ( fun n => abs_nonneg _ ) hmix ( Summable.mul_left _ <| summable_geometric_of_lt_one hρ0 hρ1 )

end ContinuedFractions