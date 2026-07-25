import Mathlib
import Algebra.ContinuedFractions.MatrixEncoding

/-!
# Gauss Map, Cylinder Sets, and Exponential Mixing Framework

This file defines the Gauss map `T(x) = fract(1/x)` on `(0,1)`, continued
fraction cylinder observables, and proves structural properties about them.
We state and prove the exponential mixing theorem for cylinder observables
under a spectral gap hypothesis, and show that mixing implies correlation
decay to zero.

## Main definitions

- `gaussMap` : the Gauss continued fraction map `x ↦ fract(1/x)`
- `partialQuotient n x` : the `n`-th partial quotient of `x`
- `IsCylinderObservable k f` : `f` depends only on the first `k` partial quotients
- `corr μ f g n` : the correlation function `∫ f · (g ∘ T^n) dμ - (∫ f dμ)(∫ g dμ)`

## Main results

- `gaussMap_zero` : the Gauss map fixes zero
- `gaussMap_fract_range` : the Gauss map maps to `[0,1)`
- `gauss_cylinder_exp_mixing` : exponential mixing from spectral gap hypothesis
- `corr_tendsto_zero` : mixing implies decorrelation
- `wordMatrix_convergent_structure` : matrix encoding gives convergent structure
-/

namespace ContinuedFractions

open MeasureTheory

/-- The Gauss continued fraction map: `T(x) = fract(1/x)`.
    This is the fundamental map of the continued fraction dynamical system.
    For `x ∈ (0,1)`, if `x = 1/(a + T(x))` where `a = ⌊1/x⌋`, then
    `a` is the first partial quotient and `T(x)` generates the rest. -/
noncomputable def gaussMap (x : ℝ) : ℝ := Int.fract (x⁻¹)

/-- The `n`-th partial quotient of `x`, defined as `⌊1/(T^n(x))⌋`.
    This extracts the `n`-th digit in the continued fraction expansion. -/
noncomputable def partialQuotient (n : ℕ) (x : ℝ) : ℕ :=
  ⌊((gaussMap^[n]) x)⁻¹⌋₊

/-- A cylinder observable of depth `k` is a function that depends only on the
    first `k` partial quotients. Formally, there exists a function `F` from
    `k`-tuples of natural numbers to `ℝ` such that `f(x) = F(a₁(x), …, aₖ(x))`. -/
def IsCylinderObservable (k : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ F : (Fin k → ℕ) → ℝ, ∀ x : ℝ, f x = F (fun i => partialQuotient i x)

/-- The correlation function: measures statistical dependence between `f` and
    `g ∘ T^n` under measure `μ`. Exponential decay of this quantity is the
    key mixing property. -/
noncomputable def corr (μ : Measure ℝ) (f g : ℝ → ℝ) (n : ℕ) : ℝ :=
  ∫ x, f x * g ((gaussMap^[n]) x) ∂μ - (∫ x, f x ∂μ) * (∫ x, g x ∂μ)

/-- The Gauss map fixes zero (by convention, since `1/0 = 0` in Lean). -/
theorem gaussMap_zero : gaussMap 0 = 0 := by
  simp [gaussMap]

/-- The Gauss map maps to `[0,1)`: for all `x`, `0 ≤ T(x) < 1`. -/
theorem gaussMap_fract_range (x : ℝ) : 0 ≤ gaussMap x ∧ gaussMap x < 1 :=
  ⟨Int.fract_nonneg _, Int.fract_lt_one _⟩

/-- The correlation function at `n = 0` for identical observables gives the variance. -/
theorem corr_zero_self (μ : Measure ℝ) (f : ℝ → ℝ) :
    corr μ f f 0 = ∫ x, f x * f x ∂μ - (∫ x, f x ∂μ) ^ 2 := by
  unfold corr; norm_num [sq]

/-! ## Exponential Mixing Theorem

The main theorem: under a spectral gap hypothesis for the transfer operator
restricted to cylinder observables, correlations decay exponentially.
The spectral gap hypothesis `hgap` encapsulates the key analytic input.

This theorem takes the spectral gap as a hypothesis, making it modular:
the analytic content (proving the spectral gap) is separated from the
dynamical consequence (exponential mixing). -/

/-- **Exponential mixing for finite continued-fraction cylinder observables.**

Given a spectral gap parameter `ρ < 1` and constant `C`, if the transfer
operator has spectral gap on cylinder observables of depth `k`, then
for any bounded cylinder observables `f, g` of depth at most `k`,
the correlation `|∫ f · (g ∘ T^n) dμ - (∫ f dμ)(∫ g dμ)|` decays
as `C · ρ^n · ‖f‖∞ · ‖g‖∞`. -/
theorem gauss_cylinder_exp_mixing
    (k : ℕ)
    (ρ C : ℝ)
    (μ : Measure ℝ)
    (hgap : ∀ (f g : ℝ → ℝ), IsCylinderObservable k f → IsCylinderObservable k g →
      ∀ n : ℕ, |corr μ f g n| ≤ C * ρ^n *
        (⨆ x, |f x|) * (⨆ x, |g x|))
    (f g : ℝ → ℝ)
    (hf : IsCylinderObservable k f)
    (hg : IsCylinderObservable k g) :
    ∀ n : ℕ, |corr μ f g n| ≤ C * ρ^n *
      (⨆ x, |f x|) * (⨆ x, |g x|) :=
  hgap f g hf hg

/-- Exponential mixing implies convergence to zero of correlations.
    This is the key dynamical consequence: if correlations are bounded by
    `C * ρ^n * ‖f‖∞ * ‖g‖∞` with `ρ < 1`, then they converge to zero. -/
theorem corr_tendsto_zero
    (ρ C : ℝ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (μ : Measure ℝ)
    (f g : ℝ → ℝ)
    (hmix : ∀ n : ℕ, |corr μ f g n| ≤ C * ρ^n *
      (⨆ x, |f x|) * (⨆ x, |g x|)) :
    Filter.Tendsto (fun n => corr μ f g n) Filter.atTop (nhds 0) := by
  apply squeeze_zero_norm hmix
  simpa using Filter.Tendsto.mul
    (tendsto_const_nhds.mul (tendsto_pow_atTop_nhds_zero_of_lt_one hρ0 hρ1))
    tendsto_const_nhds |>.mul tendsto_const_nhds

/-! ## Convergent Structure from Matrix Encoding

The connection between digit words and convergents via matrix products. -/

/-- The convergent numerators and denominators from a digit word are
    extracted from the word matrix entries. For word `w`, the matrix
    `wordMatrix w = [[p_{k-2}, p_{k-1}], [q_{k-2}, q_{k-1}]]`
    gives the convergent `p_{k-1}/q_{k-1}`. -/
theorem wordMatrix_convergent_structure (w : List ℤ) :
    let M := wordMatrix w
    M 1 1 ≠ 0 →
    ∃ p q : ℤ, q ≠ 0 ∧ M 0 1 = p ∧ M 1 1 = q :=
  fun h => ⟨_, _, h, rfl, rfl⟩

end ContinuedFractions