/-
# Continuous-Time Tropical Comparison Principle

This file establishes a continuous-time exponential decay theorem for tropical
barrier functionals, creating a bridge between:

- **Tropical barrier certificates** (max-plus geometry)
- **Grönwall-type differential inequalities** (ODE/PDE theory)
- **Nonlinear semigroup dissipation** (Hamilton–Jacobi theory)

## Mathematical overview

Given a trajectory `ω : ℝ → (ι → ℝ)` evolving under a differential inequality
dominated by a tropical operator `T` of the form `T - Id`, and given a barrier
vector `K : ι → ℝ` such that `T x i ≤ K i` for all `x, i`, the "excess"
coordinates `u_i(t) = ω(t)(i) - K(i)` each satisfy `u_i'(t) ≤ -u_i(t)`.

By a scalar comparison principle (integrating-factor argument), each `u_i`
decays exponentially: `u_i(t) ≤ exp(-t) · u_i(0)`. Taking the maximum over
the finite index set yields the tropical barrier decay:

  `max_i (ω(t)(i) - K(i)) ≤ exp(-t) · max_i (ω(0)(i) - K(i))`

This is the continuous-time analogue of discrete tropical barrier contraction,
and the natural starting point for tropical viscosity solutions and tropical
control Lyapunov theory.

## Main results

* `scalar_exp_decay` — If `φ' ≤ -φ` everywhere, then `φ(t) ≤ exp(-t) · φ(0)`.
* `tropical_coordinate_decay` — Each excess coordinate decays exponentially.
* `finite_sup'_le_of_forall_le` — Max of pointwise-bounded quantities is bounded.
* `tropical_fmax_exponential_decay` — The tropical barrier decays exponentially.

## Relation to discrete tropical barriers

The discrete barrier theorem says that if `T` is a monotone tropical operator
with `fmax(T x) ≤ fmax(x)`, then iterating `T` contracts the barrier. Our
continuous-time theorem shows that the infinitesimal generator `T - Id` produces
exponential decay `exp(-t)`, which is the continuous limit of `(1 - h)^{t/h}`
from Euler discretization with step `h → 0`.
-/

import Mathlib

open Real Finset

/-! ## Stage A: Scalar Exponential Decay (Grönwall-type) -/

/-
**Scalar exponential decay via integrating factor.**

If a differentiable function `φ` satisfies `φ'(t) ≤ -φ(t)` for all `t`,
then `φ(t) ≤ exp(-t) · φ(0)` for `t ≥ 0`.

The proof uses the integrating-factor trick: define `g(t) = exp(t) · φ(t)`.
Then `g'(t) = exp(t) · (φ(t) + φ'(t)) ≤ 0`, so `g` is monotone decreasing.
Hence `g(t) ≤ g(0) = φ(0)`, giving `φ(t) ≤ exp(-t) · φ(0)`.
-/
theorem scalar_exp_decay
    (φ : ℝ → ℝ)
    (hφ_diff : Differentiable ℝ φ)
    (hφ_ineq : ∀ t, deriv φ t ≤ -φ t)
    {t : ℝ} (ht : 0 ≤ t) :
    φ t ≤ Real.exp (-t) * φ 0 := by
  -- We apply the technique of integrating factors, specifically the function `g(t) = exp(t) * φ(t)`, to analyze the growth of `φ(t)`.
  set g : ℝ → ℝ := fun t => Real.exp t * φ t;
  -- We will show that $g(t)$ is monotone decreasing on $[0, \infty)$.
  have hg_mono : ∀ t ≥ 0, deriv g t ≤ 0 := by
    intro t ht; erw [ deriv_mul ] <;> norm_num [ Real.differentiableAt_exp, hφ_diff.differentiableAt ] ; nlinarith [ hφ_ineq t, Real.exp_pos t ] ;
  -- Since $g$ is monotone decreasing on $[0, \infty)$, we have $g(t) \leq g(0)$ for all $t \geq 0$.
  have hg_le : ∀ t ≥ 0, g t ≤ g 0 := by
    -- Apply the Mean Value Theorem to the interval [0, t] for any t ≥ 0.
    intros t ht
    by_contra h_contra;
    have := exists_deriv_eq_slope g ( show t > 0 from ht.lt_of_ne ( by rintro rfl; norm_num at h_contra ) );
    exact absurd ( this ( ContinuousOn.mul ( Real.continuousOn_exp ) hφ_diff.continuous.continuousOn ) ( DifferentiableOn.mul ( Real.differentiable_exp.differentiableOn ) hφ_diff.differentiableOn ) ) ( by rintro ⟨ c, ⟨ hc1, hc2 ⟩, hc3 ⟩ ; rw [ eq_div_iff ] at hc3 <;> nlinarith [ hg_mono c ( by linarith ) ] );
  simp +zetaDelta at *;
  simpa [ Real.exp_neg, mul_comm, mul_assoc, mul_left_comm, ne_of_gt ( Real.exp_pos _ ) ] using mul_le_mul_of_nonneg_left ( hg_le t ht ) ( inv_nonneg.mpr ( Real.exp_nonneg t ) )

/-! ## Stage B: Coordinatewise Tropical Decay -/

/-
**Coordinatewise tropical decay.**

Given a trajectory `ω` with `deriv (ω · i) t ≤ T(ω t) i - ω t i + c t`,
a barrier `K` with `T x i ≤ K i`, and `c t ≤ 0`, each excess coordinate
`u_i(t) = ω(t)(i) - K(i)` satisfies `u_i'(t) ≤ -u_i(t)` and therefore
decays exponentially.
-/
theorem tropical_coordinate_decay
    {ι : Type*} [Fintype ι]
    (K : ι → ℝ)
    (T : (ι → ℝ) → (ι → ℝ))
    (ω : ℝ → (ι → ℝ))
    (c : ℝ → ℝ)
    (hω_diff : ∀ i, Differentiable ℝ (fun t => ω t i))
    (hc_nonpos : ∀ t, c t ≤ 0)
    (hT_sub_barrier : ∀ x i, T x i ≤ K i)
    (hderiv : ∀ t i, deriv (fun s => ω s i) t ≤ T (ω t) i - ω t i + c t)
    (i : ι) {t : ℝ} (ht : 0 ≤ t) :
    (ω t i - K i) ≤ Real.exp (-t) * (ω 0 i - K i) := by
  convert scalar_exp_decay ( fun t => ω t i - K i ) ( hω_diff i |> Differentiable.sub <| differentiable_const _ ) _ ht using 1;
  intro t; have := hderiv t i; rw [ deriv_sub_const ] ; linarith [ hT_sub_barrier ( ω t ) i, hc_nonpos t ] ;

/-! ## Stage C: Finite Maximum Decay -/

/-
If `a i ≤ c * b i` for all `i` and `c ≥ 0`, then the sup' of `a`
is bounded by `c` times the sup' of `b`.
-/
theorem finite_sup'_mono_mul {ι : Type*} [Fintype ι] [Nonempty ι]
    (a b : ι → ℝ)
    (c : ℝ) (hc : 0 ≤ c)
    (h : ∀ i, a i ≤ c * b i) :
    Finset.univ.sup' Finset.univ_nonempty a ≤
      c * Finset.univ.sup' Finset.univ_nonempty b := by
  exact Finset.sup'_le _ _ fun i _ => le_trans ( h i ) ( mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun i => b i ) ( Finset.mem_univ i ) ) hc )

/-! ## Main Theorem: Tropical Barrier Exponential Decay -/

/-- **Continuous-Time Tropical Comparison Principle.**

If a trajectory `ω : ℝ → (ι → ℝ)` evolves under the differential inequality
`(ω · i)'(t) ≤ T(ω t) i - ω t i + c(t)` where `T x i ≤ K i` and `c(t) ≤ 0`,
then the tropical barrier functional `max_i (ω(t)(i) - K(i))` decays
exponentially:

  `max_i (ω(t)(i) - K(i)) ≤ exp(-t) · max_i (ω(0)(i) - K(i))`

This is the continuous-time analogue of discrete tropical barrier contraction
and constitutes a tropical comparison principle linking max-plus geometry
to dissipative ODE theory. -/
theorem tropical_fmax_exponential_decay
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (K : ι → ℝ)
    (T : (ι → ℝ) → (ι → ℝ))
    (ω : ℝ → (ι → ℝ))
    (c : ℝ → ℝ)
    (hω_diff : ∀ i, Differentiable ℝ (fun t => ω t i))
    (hc_nonpos : ∀ t, c t ≤ 0)
    (hT_sub_barrier : ∀ x i, T x i ≤ K i)
    (hderiv : ∀ t i, deriv (fun s => ω s i) t ≤ T (ω t) i - ω t i + c t)
    {t : ℝ} (ht : 0 ≤ t) :
    Finset.univ.sup' Finset.univ_nonempty (fun i => ω t i - K i) ≤
      Real.exp (-t) * Finset.univ.sup' Finset.univ_nonempty (fun i => ω 0 i - K i) := by
  exact finite_sup'_mono_mul _ _ (Real.exp (-t)) (le_of_lt (Real.exp_pos _))
    (fun i => tropical_coordinate_decay K T ω c hω_diff hc_nonpos hT_sub_barrier hderiv i ht)

/-! ## Abstract Tropical Comparison (general barrier functional) -/

/-- **Abstract continuous-time tropical comparison.**

For any continuous differentiable function `φ` (representing a barrier functional
composed with a trajectory) satisfying `φ'(t) ≤ -φ(t)`, we get exponential decay.
This abstracts the tropical structure and can be applied to general barrier
functionals beyond the coordinatewise max. -/
theorem tropical_continuous_comparison
    (φ : ℝ → ℝ)
    (hφ_diff : Differentiable ℝ φ)
    (hφ_decay : ∀ t, deriv φ t ≤ -φ t)
    {t : ℝ} (ht : 0 ≤ t) :
    φ t ≤ Real.exp (-t) * φ 0 :=
  scalar_exp_decay φ hφ_diff hφ_decay ht