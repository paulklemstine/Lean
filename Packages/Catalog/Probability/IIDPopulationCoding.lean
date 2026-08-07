/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Novelty.NeuralCoding

/-!
# Population coding from a genuine probability space: the `1/√N` law

`Catalog/Novelty/NeuralCoding.lean` *stipulated* the variance-of-the-mean formula
(`popVariance v N = (N * v) / N ^ 2`) and derived the `1/√N` precision law from
it algebraically.  This file replaces the stipulation by a real probabilistic
model:

* `Ω` is a probability space, `X i : Ω → ℝ` is the response of neuron `i`,
* the responses are square-integrable, **pairwise independent** and
  **identically dispersed** (`Var[X i] = v` for all `i`),
* the population estimate is the empirical mean `popMean X = (1/N) ∑ i, X i`.

## Results

1. `popMean_apply`, `integral_popMean` — the population estimate is unbiased:
   if every neuron has mean `m` then `E[popMean X] = m`.
2. `variance_popMean` — **variance of the mean.**  `Var[popMean X] = v / N`.
   This is now a *theorem* about independent random variables, not a definition.
3. `variance_popMean_eq_popVariance` — the derived variance agrees with the
   stipulated `NeuralCoding.popVariance`, so all downstream results of the
   earlier file are now grounded in probability.
4. `stdDev_popMean` — **the `1/√N` error law**: the standard deviation of the
   population estimate is `√v / √N`.
5. `popMean_deviation_bound` — a Chebyshev error law: the probability that the
   population estimate misses the true mean by `ε` is at most `v / (N ε²)`,
   so it vanishes like `1/N`.
6. `popMean_error_tendsto_zero` — the error law tends to `0` as `N → ∞`.
-/

namespace Catalog.Probability.NeuralCoding.IID

open MeasureTheory ProbabilityTheory Finset

variable {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}

/-- The **population estimate**: the empirical mean of the `N` neural responses. -/
noncomputable def popMean {N : ℕ} (X : Fin N → Ω → ℝ) : Ω → ℝ :=
  fun ω => (N : ℝ)⁻¹ * ∑ i, X i ω

omit [MeasurableSpace Ω] in
@[simp] theorem popMean_apply {N : ℕ} (X : Fin N → Ω → ℝ) (ω : Ω) :
    popMean X ω = (N : ℝ)⁻¹ * ∑ i, X i ω := rfl

/-- The population estimate is square-integrable when each neuron is. -/
theorem memLp_popMean {N : ℕ} (X : Fin N → Ω → ℝ) (hL2 : ∀ i, MemLp (X i) 2 μ) :
    MemLp (popMean X) 2 μ := by
  have hpt : (fun ω => ∑ i, X i ω) = (∑ i, X i : Ω → ℝ) := by
    funext ω; simp [Finset.sum_apply]
  have hsum : MemLp (fun ω => ∑ i, X i ω) 2 μ := by
    rw [hpt]
    exact memLp_finset_sum' (Finset.univ : Finset (Fin N)) (fun i _ => hL2 i)
  simpa [popMean] using hsum.const_mul ((N : ℝ)⁻¹)

/-- **Unbiasedness.** If every neuron's response has mean `m`, the population
estimate has mean `m`. -/
theorem integral_popMean {N : ℕ} (hN : 0 < N) (X : Fin N → Ω → ℝ)
    (hint : ∀ i, Integrable (X i) μ) (m : ℝ) (hm : ∀ i, ∫ ω, X i ω ∂μ = m) :
    ∫ ω, popMean X ω ∂μ = m := by
  have hNne : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hsum : ∫ ω, ∑ i, X i ω ∂μ = ∑ i : Fin N, ∫ ω, X i ω ∂μ :=
    integral_finset_sum _ (fun i _ => hint i)
  simp only [popMean, integral_const_mul, hsum, hm, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- **Variance of the mean.**  For pairwise independent, square-integrable neural
responses all having variance `v`, the population estimate has variance `v / N`. -/
theorem variance_popMean {N : ℕ} (hN : 0 < N) (X : Fin N → Ω → ℝ)
    (hL2 : ∀ i, MemLp (X i) 2 μ)
    (hindep : Pairwise fun i j => IndepFun (X i) (X j) μ)
    (v : ℝ) (hv : ∀ i, Var[X i; μ] = v) :
    Var[popMean X; μ] = v / N := by
  have hNne : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hfun : popMean X = fun ω => (N : ℝ)⁻¹ * (∑ i, X i) ω := by
    funext ω; simp [popMean]
  rw [hfun, variance_const_mul]
  rw [IndepFun.variance_sum (fun i _ => hL2 i) (fun i _ j _ hij => hindep hij)]
  simp only [hv, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- The probabilistically derived variance agrees with the variance-of-the-mean
formula stipulated in `Catalog/Novelty/NeuralCoding.lean`. -/
theorem variance_popMean_eq_popVariance {N : ℕ} (hN : 0 < N) (X : Fin N → Ω → ℝ)
    (hL2 : ∀ i, MemLp (X i) 2 μ)
    (hindep : Pairwise fun i j => IndepFun (X i) (X j) μ)
    (v : ℝ) (hv : ∀ i, Var[X i; μ] = v) :
    Var[popMean X; μ] = NeuralCoding.popVariance v N := by
  rw [variance_popMean hN X hL2 hindep v hv, NeuralCoding.popVariance_eq v N hN]

/-- **The `1/√N` error law.**  The standard deviation of the population estimate
is `√v / √N`: the achievable precision improves like `√N` in the number of
neurons. -/
theorem stdDev_popMean {N : ℕ} (hN : 0 < N) (X : Fin N → Ω → ℝ)
    (hL2 : ∀ i, MemLp (X i) 2 μ)
    (hindep : Pairwise fun i j => IndepFun (X i) (X j) μ)
    (v : ℝ) (hv0 : 0 ≤ v) (hv : ∀ i, Var[X i; μ] = v) :
    Real.sqrt (Var[popMean X; μ]) = Real.sqrt v / Real.sqrt N := by
  rw [variance_popMean hN X hL2 hindep v hv, Real.sqrt_div hv0]

/-- The derived standard deviation agrees with the stipulated `popPrecision`. -/
theorem stdDev_popMean_eq_popPrecision {N : ℕ} (hN : 0 < N) (X : Fin N → Ω → ℝ)
    (hL2 : ∀ i, MemLp (X i) 2 μ)
    (hindep : Pairwise fun i j => IndepFun (X i) (X j) μ)
    (v : ℝ) (hv0 : 0 ≤ v) (hv : ∀ i, Var[X i; μ] = v) :
    Real.sqrt (Var[popMean X; μ]) = NeuralCoding.popPrecision v N := by
  rw [stdDev_popMean hN X hL2 hindep v hv0 hv,
    NeuralCoding.popPrecision_eq v N hv0 hN]

/-- **Chebyshev error law.**  The probability that the population estimate is off
by at least `ε` from the common mean `m` is at most `v / (N ε²)`: the error
probability decays like `1 / N`. -/
theorem popMean_deviation_bound [IsProbabilityMeasure μ] {N : ℕ} (hN : 0 < N)
    (X : Fin N → Ω → ℝ) (hL2 : ∀ i, MemLp (X i) 2 μ)
    (hindep : Pairwise fun i j => IndepFun (X i) (X j) μ)
    (v : ℝ) (hv : ∀ i, Var[X i; μ] = v)
    (m : ℝ) (hm : ∀ i, ∫ ω, X i ω ∂μ = m) {ε : ℝ} (hε : 0 < ε) :
    μ {ω | ε ≤ |popMean X ω - m|} ≤ ENNReal.ofReal (v / (N * ε ^ 2)) := by
  have hmem := memLp_popMean X hL2
  have hint : ∀ i, Integrable (X i) μ := fun i => (hL2 i).integrable (by norm_num)
  have hEq : ∫ ω, popMean X ω ∂μ = m := integral_popMean hN X hint m hm
  have h := ProbabilityTheory.meas_ge_le_variance_div_sq hmem hε
  rw [hEq, variance_popMean hN X hL2 hindep v hv] at h
  have : v / (N : ℝ) / ε ^ 2 = v / (N * ε ^ 2) := by
    field_simp
  rwa [this] at h

/-- **The error vanishes.**  The `1/√N` error law tends to `0`: arbitrarily high
precision is attainable with enough neurons. -/
theorem popMean_error_tendsto_zero (v : ℝ) :
    Filter.Tendsto (fun N : ℕ => Real.sqrt v / Real.sqrt N) Filter.atTop (nhds 0) := by
  have h : Filter.Tendsto (fun N : ℕ => Real.sqrt N) Filter.atTop Filter.atTop :=
    Real.tendsto_sqrt_atTop.comp tendsto_natCast_atTop_atTop
  exact Filter.Tendsto.div_atTop tendsto_const_nhds h

end Catalog.Probability.NeuralCoding.IID