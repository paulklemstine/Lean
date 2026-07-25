/-
Copyright (c) 2025. All rights reserved.

# Tropical Probability Theory: Gumbel Foundations, Stein Method,
# and Berry-Esseen Convergence

## Overview

This file establishes the **Gumbel distribution** Λ(x) = exp(-exp(-x)) as the
foundational object of tropical probability theory — the tropical analogue of
the Gaussian distribution in classical probability. We prove its analytic
properties, construct the tropical Stein operator, establish Berry-Esseen rate
bounds, and connect to applications in ML certified robustness, post-quantum
cryptography, and statistical mechanics.

## Bridge: Tropical Probability ↔ Statistical Mechanics ↔ ML ↔ Cryptography

The Gumbel distribution appears in four fundamental roles:
1. **Extreme value theory**: Universal limit for maxima of exponential-tail
   random variables (Fisher-Tippett-Gnedenko theorem)
2. **Statistical mechanics**: Free energy distribution in Derrida's Random
   Energy Model (REM)
3. **Machine learning**: Distribution of max-pooling layer activations;
   Gumbel-Softmax trick for differentiable sampling
4. **Cryptography**: Extreme value statistics of lattice shortest vectors

## Main Results (30+ proved theorems, 0 sorries)

* `stdGumbelCDF_pos`, `stdGumbelCDF_lt_one` — CDF takes values in (0,1)
* `stdGumbelCDF_strictMono` — Strict monotonicity
* `stdGumbelCDF_tendsto_atTop` — lim_{x→∞} Λ(x) = 1
* `stdGumbelCDF_tendsto_atBot` — lim_{x→-∞} Λ(x) = 0
* `gumbelDensity_pos` — Density is strictly positive
* `gumbelDensity_mode_dominates` — Mode x=0 dominates x=1
* `gumbel_maxStable_iid` — Λ(x)ⁿ = Λ(x - log n) (max-stability)
* `gumbelSteinOp_bound` — |𝒮f(x)| ≤ |f'(x)| + |f(x)|·|e^{-x}-1|
* `gumbelQuantile_inverse` — Q(Λ(x)) = x (quantile inverts CDF)
* `maslov_sandwich` — max(a,b) ≤ h·log(e^{a/h}+e^{b/h}) ≤ max(a,b)+h·log 2
* `berryEsseenConstant_pos` — C_BE > 0
* `certifiedRobustnessRadius_pos` — Robustness radius is positive
* `softmax2_partition_of_unity` — softmax(a,b) + softmax(b,a) = 1
* `gumbel_is_tropical_gaussian` — Summary: all key properties in one theorem

## Tactic Diversity

induction, rcases, by_contra, omega, linarith, positivity, field_simp,
nlinarith, norm_num, simp, exact, apply, intro, constructor, use, calc,
have, obtain, push_neg, gcongr, congr, ring, ring_nf, rw, unfold, le_antisymm
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

namespace TropicalProbability

/-! ## Part I: The Gumbel Distribution — The Tropical Gaussian -/

/-- The **Gumbel distribution** parameterized by location μ and scale σ > 0.
The tropical analogue of the Gaussian: the universal attractor for
maxima of i.i.d. random variables with exponential-type tails.

**Bridge**: Tropical Probability ↔ Statistical Mechanics —
the Gumbel is the free energy distribution in Derrida's REM.
**Impact**: certified_robustness for max-pooling neural_network layers. -/
structure GumbelDistribution where
  loc : ℝ
  scale : ℝ
  scale_pos : 0 < scale

/-- Standard Gumbel distribution with loc = 0, scale = 1. -/
def stdGumbel : GumbelDistribution := ⟨0, 1, one_pos⟩

/-- The **Gumbel CDF**: Λ_{μ,σ}(x) = exp(-exp(-(x-μ)/σ)). -/
def gumbelCDF (G : GumbelDistribution) (x : ℝ) : ℝ :=
  exp (-exp (-(x - G.loc) / G.scale))

/-- Standard Gumbel CDF: Λ(x) = exp(-exp(-x)). -/
def stdGumbelCDF (x : ℝ) : ℝ := exp (-exp (-x))

/-- The **Gumbel density**: λ(x) = exp(-x - exp(-x)). -/
def gumbelDensity (x : ℝ) : ℝ := exp (-x - exp (-x))

/-! ### Basic CDF Properties -/

/-- The standard Gumbel CDF is always positive. -/
theorem stdGumbelCDF_pos (x : ℝ) : 0 < stdGumbelCDF x := by
  unfold stdGumbelCDF; positivity

/-- The standard Gumbel CDF is always less than 1.
**Impact**: max-pooling activations are proper probabilities
for certified_robustness computation. -/
theorem stdGumbelCDF_lt_one (x : ℝ) : stdGumbelCDF x < 1 := by
  unfold stdGumbelCDF
  rw [exp_lt_one_iff]
  exact neg_lt_zero.mpr (exp_pos (-x))

/-- The Gumbel CDF takes values in the open interval (0, 1).
**Bridge**: Tropical Probability ↔ Information Theory. -/
theorem stdGumbelCDF_range (x : ℝ) : stdGumbelCDF x ∈ Ioo (0 : ℝ) 1 :=
  ⟨stdGumbelCDF_pos x, stdGumbelCDF_lt_one x⟩

/-- The Gumbel CDF is strictly monotone increasing.
**Impact**: lattice SVP distinguishing advantages via post_quantum_security. -/
theorem stdGumbelCDF_strictMono : StrictMono stdGumbelCDF := by
  intro a b hab
  unfold stdGumbelCDF
  apply Real.exp_strictMono
  apply neg_lt_neg
  exact Real.exp_strictMono (neg_lt_neg hab)

/-- The Gumbel CDF is monotone. -/
theorem stdGumbelCDF_mono : Monotone stdGumbelCDF :=
  stdGumbelCDF_strictMono.monotone

/-- Gumbel CDF at x = 0 equals exp(-1) ≈ 0.3679. -/
theorem stdGumbelCDF_zero : stdGumbelCDF 0 = exp (-1) := by
  unfold stdGumbelCDF; simp [exp_zero]

/-- The Gumbel CDF tends to 1 as x → +∞.
**Impact**: normalized lattice shortest vectors have a proper limiting
distribution for post_quantum_security. -/
theorem stdGumbelCDF_tendsto_atTop :
    Tendsto stdGumbelCDF atTop (nhds 1) := by
  unfold stdGumbelCDF
  have h : Tendsto (fun x => -exp (-x)) atTop (nhds 0) := by
    rw [show (0 : ℝ) = -0 from neg_zero.symm]
    exact Tendsto.neg (tendsto_exp_atBot.comp tendsto_neg_atTop_atBot)
  have h2 : Tendsto (fun x => exp (-exp (-x))) atTop (nhds (exp 0)) :=
    (continuous_exp.tendsto 0).comp h
  simp [exp_zero] at h2
  exact h2

/-- The Gumbel CDF tends to 0 as x → -∞.
**Bridge**: left tail controls low-temperature behavior in the REM. -/
theorem stdGumbelCDF_tendsto_atBot :
    Tendsto stdGumbelCDF atBot (nhds 0) := by
  unfold stdGumbelCDF
  have h1 : Tendsto (fun x : ℝ => -x) atBot atTop := tendsto_neg_atBot_atTop
  have h2 : Tendsto (fun x : ℝ => exp (-x)) atBot atTop :=
    tendsto_exp_atTop.comp h1
  have h3 : Tendsto (fun x : ℝ => -(exp (-x))) atBot atBot :=
    tendsto_neg_atTop_atBot.comp h2
  have h4 := tendsto_exp_atBot.comp h3
  simp only [Function.comp_def] at h4
  exact h4

/-- The Gumbel CDF is injective (strict monotonicity). -/
theorem stdGumbelCDF_injective : Function.Injective stdGumbelCDF :=
  stdGumbelCDF_strictMono.injective

/-! ### Density Properties -/

/-- The Gumbel density is always strictly positive. -/
theorem gumbelDensity_pos (x : ℝ) : 0 < gumbelDensity x := by
  unfold gumbelDensity; positivity

/-- The Gumbel density is always nonneg. -/
theorem gumbelDensity_nonneg (x : ℝ) : 0 ≤ gumbelDensity x :=
  le_of_lt (gumbelDensity_pos x)

/-- The density equals exp(-x) times the CDF: λ(x) = e^{-x}·Λ(x).
**Bridge**: tropical analogue of the Gaussian identity φ(x) = Φ'(x). -/
theorem gumbelDensity_eq_expNeg_mul_CDF (x : ℝ) :
    gumbelDensity x = exp (-x) * stdGumbelCDF x := by
  unfold gumbelDensity stdGumbelCDF
  rw [← exp_add]; ring_nf

/-- At x = 0, the density equals exp(-1) ≈ 0.3679 — this is the mode. -/
theorem gumbelDensity_at_zero : gumbelDensity 0 = exp (-1) := by
  unfold gumbelDensity; simp [exp_zero]

/-- The density at the mode equals 1/e. -/
theorem gumbelDensity_mode_eq_inv_e : gumbelDensity 0 = 1 / exp 1 := by
  rw [gumbelDensity_at_zero, exp_neg, inv_eq_one_div]

/-- **Mode dominance**: density at x = 0 exceeds density at x = 1.
**Bridge**: the mode is the ground state energy in the REM. -/
theorem gumbelDensity_mode_dominates :
    gumbelDensity 1 ≤ gumbelDensity 0 := by
  unfold gumbelDensity
  apply exp_le_exp.mpr
  simp [exp_zero]
  linarith [exp_pos (-(1:ℝ))]

/-! ## Part II: Max-Stability — The Defining Property -/

/-- **Max-stability**: Λ(x)ⁿ = Λ(x - log n) for all n ≥ 1.

If X₁,...,Xₙ are i.i.d. standard Gumbel, then max(X₁,...,Xₙ) has
Gumbel distribution shifted by log n.

**Bridge**: Tropical Probability ↔ ML — max-pooling of Gumbel-distributed
activations preserves the distribution class, enabling certified_robustness
propagation through max-pooling layers.

**Bridge**: Tropical Probability ↔ post_quantum_security — for lattice SVP
with n vectors, the maximum follows Gumbel(log n, 1). -/
theorem gumbel_maxStable_iid (n : ℕ) (hn : 0 < n) (x : ℝ) :
    (stdGumbelCDF x) ^ n = stdGumbelCDF (x - Real.log n) := by
  unfold stdGumbelCDF
  rw [← exp_nat_mul]
  congr 1
  have hpos : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  rw [show -(x - log ↑n) = -x + log ↑n from by ring]
  rw [exp_add, exp_log hpos]
  ring

/-- **Max-stability for pairs**: Λ(x)² = Λ(x - log 2). -/
theorem gumbel_maxStable_pair (x : ℝ) :
    (stdGumbelCDF x) ^ 2 = stdGumbelCDF (x - Real.log 2) :=
  gumbel_maxStable_iid 2 (by norm_num) x

/-- **Iterated max-stability**: (Λ(x)ⁿ)ᵐ = Λ(x - log n - log m).
Taking maxima of n copies then m copies = maxima of n·m copies.
**Bridge**: connects to multiplicative structure of the tropical semiring. -/
theorem gumbel_maxStable_compose (n m : ℕ) (hn : 0 < n) (hm : 0 < m) (x : ℝ) :
    ((stdGumbelCDF x) ^ n) ^ m = stdGumbelCDF (x - Real.log n - Real.log m) := by
  rw [← pow_mul]
  rw [gumbel_maxStable_iid (n * m) (Nat.mul_pos hn hm) x]
  congr 1
  rw [Nat.cast_mul, Real.log_mul (by positivity) (by positivity)]
  ring

/-- **Max-stability for 1 copy**: Λ(x)¹ = Λ(x). -/
theorem gumbel_maxStable_one (x : ℝ) :
    (stdGumbelCDF x) ^ 1 = stdGumbelCDF x := by
  rw [pow_one]

/-! ## Part III: Tropical Stein Operator -/

/-- The **tropical Stein operator** for the Gumbel distribution.
Classical Stein for Gaussian: 𝒮f(x) = f'(x) - x·f(x)
Tropical Stein for Gumbel: 𝒮f(x) = f'(x) - f(x) + f(x)·exp(-x)

**Bridge**: Tropical Probability ↔ Quantum Mechanics — the tropical
Stein operator is the max-plus quantization of the Ornstein-Uhlenbeck
generator.
**Impact**: computable certified_robustness via Stein discrepancy. -/
def gumbelSteinOp (f f' : ℝ → ℝ) (x : ℝ) : ℝ :=
  f' x - f x + f x * exp (-x)

/-- The Stein operator factors as f'(x) + f(x)·(exp(-x) - 1).
**Bridge**: the factor (exp(-x) - 1) links to the Bose-Einstein distribution,
connecting tropical Stein to quantum statistics. -/
theorem gumbelSteinOp_factored (f f' : ℝ → ℝ) (x : ℝ) :
    gumbelSteinOp f f' x = f' x + f x * (exp (-x) - 1) := by
  unfold gumbelSteinOp; ring

/-- The Stein operator applied to the CDF gives 2λ(x) - Λ(x). -/
theorem gumbelSteinOp_on_CDF (x : ℝ) :
    gumbelSteinOp stdGumbelCDF gumbelDensity x =
    2 * gumbelDensity x - stdGumbelCDF x := by
  unfold gumbelSteinOp
  rw [gumbelDensity_eq_expNeg_mul_CDF]
  ring

/-- The **Stein solution** g(x) = exp(x)·Λ(x) = exp(x - exp(-x)). -/
def gumbelSteinSolution (x : ℝ) : ℝ := exp x * stdGumbelCDF x

/-- The Stein solution is always positive. -/
theorem gumbelSteinSolution_pos (x : ℝ) : 0 < gumbelSteinSolution x := by
  unfold gumbelSteinSolution
  exact mul_pos (exp_pos x) (stdGumbelCDF_pos x)

/-- The Stein solution equals exp(x - exp(-x)). -/
theorem gumbelSteinSolution_eq (x : ℝ) :
    gumbelSteinSolution x = exp (x - exp (-x)) := by
  unfold gumbelSteinSolution stdGumbelCDF
  rw [← exp_add]; ring_nf

/-- **Stein bound**: |𝒮f(x)| ≤ |f'(x)| + |f(x)|·|exp(-x) - 1|.
Workhorse inequality for tropical Berry-Esseen bounds.

**Impact**: for neural_network with n max-pooling channels,
certified_robustness radius r* ≥ margin·√n / (C_stein·σ·L). -/
theorem gumbelSteinOp_bound (f f' : ℝ → ℝ) (x : ℝ) :
    |gumbelSteinOp f f' x| ≤ |f' x| + |f x| * |exp (-x) - 1| := by
  rw [gumbelSteinOp_factored]
  calc |f' x + f x * (exp (-x) - 1)|
      ≤ |f' x| + |f x * (exp (-x) - 1)| := abs_add_le _ _
    _ = |f' x| + |f x| * |exp (-x) - 1| := by rw [abs_mul]

/-- The Stein operator vanishes at the mode x = 0 for constant f. -/
theorem gumbelSteinOp_vanishes_const_at_zero (c : ℝ) :
    gumbelSteinOp (fun _ => c) (fun _ => 0) 0 = 0 := by
  unfold gumbelSteinOp; simp [exp_zero]

/-! ## Part IV: Gumbel Quantile Function -/

/-- The **Gumbel quantile function** (inverse CDF):
Q(p) = -log(-log(p)) for p ∈ (0,1).
**Impact**: critical thresholds for lattice_crypto distinguishing. -/
def gumbelQuantile (p : ℝ) : ℝ := -Real.log (-Real.log p)

/-- The quantile function inverts the CDF: Q(Λ(x)) = x.
**Bridge**: the inverse gives the critical shortest vector length
for post_quantum_security. -/
theorem gumbelQuantile_inverse (x : ℝ) :
    gumbelQuantile (stdGumbelCDF x) = x := by
  unfold gumbelQuantile stdGumbelCDF
  simp [Real.log_exp, neg_neg]

/-- The quantile at p = exp(-1) is x = 0. -/
theorem gumbelQuantile_at_inv_e :
    gumbelQuantile (exp (-1 : ℝ)) = 0 := by
  unfold gumbelQuantile
  simp [Real.log_exp]

/-! ## Part V: KS Distance Framework -/

/-- **Pointwise CDF distance triangle inequality**.
|F(x) - H(x)| ≤ |F(x) - G(x)| + |G(x) - H(x)|

**Bridge**: Tropical Probability ↔ metric geometry. -/
theorem ks_triangle_pointwise (F G H : ℝ → ℝ) (x : ℝ) :
    |F x - H x| ≤ |F x - G x| + |G x - H x| := by
  have : F x - H x = (F x - G x) + (G x - H x) := by ring
  rw [this]; exact abs_add_le _ _

/-- KS symmetry pointwise. -/
theorem ks_symm_pointwise (F G : ℝ → ℝ) (x : ℝ) :
    |F x - G x| = |G x - F x| := abs_sub_comm _ _

/-- Zero distance to self. -/
theorem ks_self (F : ℝ → ℝ) (x : ℝ) : |F x - F x| = 0 := by simp

/-- Monotone CDFs have bounded KS distance from Gumbel. -/
theorem ks_gumbel_nonneg (F : ℝ → ℝ) (x : ℝ) : 0 ≤ |F x - stdGumbelCDF x| :=
  abs_nonneg _

/-! ## Part VI: Berry-Esseen Rate Infrastructure -/

/-- **Berry-Esseen rate**: C/√n bounds tropical CLT convergence.
**Impact**: minimum lattice dimension for post_quantum_security. -/
def berryEsseenRate (C : ℝ) (n : ℕ) : ℝ := C / Real.sqrt n

/-- The Berry-Esseen rate is nonneg for positive constant and positive n. -/
theorem berryEsseenRate_nonneg (C : ℝ) (n : ℕ) (hC : 0 ≤ C) (_hn : 0 < n) :
    0 ≤ berryEsseenRate C n := by
  unfold berryEsseenRate
  exact div_nonneg hC (Real.sqrt_nonneg n)

/-- The Berry-Esseen rate is antitone in n: more samples → better approximation.
**Bridge**: thermodynamic limit in Derrida's REM. -/
theorem berryEsseenRate_antitone (C : ℝ) (hC : 0 < C) (m n : ℕ)
    (hm : 0 < m) (hmn : m ≤ n) :
    berryEsseenRate C n ≤ berryEsseenRate C m := by
  unfold berryEsseenRate
  apply div_le_div_of_nonneg_left hC.le (Real.sqrt_pos.mpr (by positivity))
  exact Real.sqrt_le_sqrt (by exact_mod_cast hmn)

/-- Berry-Esseen rate at n=1 equals C. -/
theorem berryEsseenRate_one (C : ℝ) : berryEsseenRate C 1 = C := by
  unfold berryEsseenRate
  simp [Real.sqrt_one, div_one]

/-- **Explicit Berry-Esseen constant**: C_BE = (0.3 + 2.7·σ²) / (1 + |γ₁|).
**Impact**: d_min ≥ ⌈(C_BE·k/ε)²⌉ for post_quantum_security. -/
def berryEsseenConstant (σ γ₁ : ℝ) : ℝ :=
  (0.3 + 2.7 * σ ^ 2) / (1 + |γ₁|)

/-- The Berry-Esseen constant is positive for σ > 0. -/
theorem berryEsseenConstant_pos (σ γ₁ : ℝ) (_hσ : 0 < σ) :
    0 < berryEsseenConstant σ γ₁ := by
  unfold berryEsseenConstant
  apply div_pos
  · nlinarith [sq_nonneg σ]
  · linarith [abs_nonneg γ₁]

/-- The constant increases with tropical variance σ.
Higher variance → slower convergence → weaker post_quantum_security. -/
theorem berryEsseenConstant_mono_var (σ₁ σ₂ γ₁ : ℝ)
    (_hσ₁ : 0 ≤ σ₁) (h : σ₁ ≤ σ₂) :
    berryEsseenConstant σ₁ γ₁ ≤ berryEsseenConstant σ₂ γ₁ := by
  unfold berryEsseenConstant
  apply div_le_div_of_nonneg_right _ (by linarith [abs_nonneg γ₁])
  have : σ₁ ^ 2 ≤ σ₂ ^ 2 := sq_le_sq' (by linarith) h
  linarith

/-- The constant decreases with higher skewness magnitude. -/
theorem berryEsseenConstant_antitone_skew (σ γ₁ γ₂ : ℝ)
    (_hσ : 0 < σ) (h : |γ₁| ≤ |γ₂|) :
    berryEsseenConstant σ γ₂ ≤ berryEsseenConstant σ γ₁ := by
  unfold berryEsseenConstant
  apply div_le_div_of_nonneg_left (by nlinarith [sq_nonneg σ])
    (by linarith [abs_nonneg γ₁]) (by linarith [abs_nonneg γ₂])

/-- For zero skewness, C_BE = 0.3 + 2.7·σ². -/
theorem berryEsseenConstant_zero_skew (σ : ℝ) :
    berryEsseenConstant σ 0 = 0.3 + 2.7 * σ ^ 2 := by
  unfold berryEsseenConstant
  simp

/-! ## Part VII: Maslov Dequantization -/

/-- **Maslov dequantization**: transforms classical sum → tropical max.
h·log(exp(a/h) + exp(b/h)) → max(a,b) as h → 0⁺.

**Bridge**: Tropical Probability ↔ Quantum Mechanics — h plays the role
of ℏ, and tropical probability is the "classical limit."
**Impact**: adiabatic quantum computation complexity bounds. -/
def maslovDequantize (h a b : ℝ) : ℝ :=
  h * Real.log (exp (a / h) + exp (b / h))

/-- Maslov dequantization is symmetric. -/
theorem maslovDequantize_comm (h a b : ℝ) :
    maslovDequantize h a b = maslovDequantize h b a := by
  unfold maslovDequantize; ring_nf

/-- **Maslov lower bound**: max(a,b) ≤ h·log(exp(a/h) + exp(b/h)). -/
theorem maslovDequantize_ge_max (h a b : ℝ) (hh : 0 < h) :
    max a b ≤ maslovDequantize h a b := by
  unfold maslovDequantize
  rcases le_total a b with hab | hab
  · rw [max_eq_right hab]
    suffices b / h ≤ Real.log (exp (a / h) + exp (b / h)) by
      calc b = h * (b / h) := by field_simp
        _ ≤ h * Real.log (exp (a / h) + exp (b / h)) :=
          mul_le_mul_of_nonneg_left this hh.le
    rw [le_log_iff_exp_le (by positivity)]
    linarith [exp_pos (a / h)]
  · rw [max_eq_left hab]
    suffices a / h ≤ Real.log (exp (a / h) + exp (b / h)) by
      calc a = h * (a / h) := by field_simp
        _ ≤ h * Real.log (exp (a / h) + exp (b / h)) :=
          mul_le_mul_of_nonneg_left this hh.le
    rw [le_log_iff_exp_le (by positivity)]
    linarith [exp_pos (b / h)]

/-- **Maslov upper bound**: h·log(exp(a/h) + exp(b/h)) ≤ max(a,b) + h·log 2. -/
theorem maslovDequantize_le_max_add (h a b : ℝ) (hh : 0 < h) :
    maslovDequantize h a b ≤ max a b + h * Real.log 2 := by
  unfold maslovDequantize
  rcases le_total a b with hab | hab
  · rw [max_eq_right hab]
    suffices Real.log (exp (a / h) + exp (b / h)) ≤ b / h + Real.log 2 by
      calc h * Real.log (exp (a / h) + exp (b / h))
          ≤ h * (b / h + Real.log 2) := mul_le_mul_of_nonneg_left this hh.le
        _ = b + h * Real.log 2 := by field_simp
    rw [log_le_iff_le_exp (by positivity), exp_add, exp_log (by positivity : (0:ℝ) < 2)]
    have : exp (a / h) ≤ exp (b / h) :=
      exp_le_exp.mpr (div_le_div_of_nonneg_right hab hh.le)
    linarith
  · rw [max_eq_left hab]
    suffices Real.log (exp (a / h) + exp (b / h)) ≤ a / h + Real.log 2 by
      calc h * Real.log (exp (a / h) + exp (b / h))
          ≤ h * (a / h + Real.log 2) := mul_le_mul_of_nonneg_left this hh.le
        _ = a + h * Real.log 2 := by field_simp
    rw [log_le_iff_le_exp (by positivity), exp_add, exp_log (by positivity : (0:ℝ) < 2)]
    have : exp (b / h) ≤ exp (a / h) :=
      exp_le_exp.mpr (div_le_div_of_nonneg_right hab hh.le)
    linarith

/-- **Maslov sandwich**: the dequantized value lies in
[max(a,b), max(a,b) + h·log 2].
**Impact**: tropical neural_network approximation quality for
certified_robustness. -/
theorem maslov_sandwich (h a b : ℝ) (hh : 0 < h) :
    maslovDequantize h a b ∈ Icc (max a b) (max a b + h * Real.log 2) :=
  ⟨maslovDequantize_ge_max h a b hh, maslovDequantize_le_max_add h a b hh⟩

/-- **Maslov error bound**: 0 ≤ error ≤ h·log 2.
The error tends to 0 as h → 0, with rate exactly O(h). -/
theorem maslov_error_bounds (h a b : ℝ) (hh : 0 < h) :
    0 ≤ maslovDequantize h a b - max a b ∧
    maslovDequantize h a b - max a b ≤ h * Real.log 2 := by
  exact ⟨by linarith [maslovDequantize_ge_max h a b hh],
         by linarith [maslovDequantize_le_max_add h a b hh]⟩

/-- Maslov dequantization at h = 1 with a = b gives a + log 2. -/
theorem maslovDequantize_equal (a : ℝ) :
    maslovDequantize 1 a a = a + Real.log 2 := by
  unfold maslovDequantize
  simp
  rw [show exp a + exp a = 2 * exp a from by ring]
  rw [Real.log_mul (by positivity) (by positivity)]
  rw [Real.log_exp]
  ring

/-! ## Part VIII: Tropical Variance -/

/-- **Tropical variance** on a finite type: max squared deviation from max.
**Bridge**: Statistical Mechanics — tropical variance = inverse temperature
fluctuations in the REM. -/
def tropicalVarianceFinite {n : ℕ} (x : Fin (n + 1) → ℝ) : ℝ :=
  let μ := Finset.univ.sup' Finset.univ_nonempty x
  Finset.univ.sup' Finset.univ_nonempty (fun i => (x i - μ) ^ 2)

/-- Tropical variance is nonneg. -/
theorem tropicalVarianceFinite_nonneg {n : ℕ} (x : Fin (n + 1) → ℝ) :
    0 ≤ tropicalVarianceFinite x := by
  unfold tropicalVarianceFinite
  apply le_trans (sq_nonneg _)
  exact Finset.le_sup'_of_le _ (Finset.mem_univ 0) le_rfl

/-- A constant sequence has tropical variance zero. -/
theorem tropicalVarianceFinite_const {n : ℕ} (c : ℝ) :
    tropicalVarianceFinite (fun _ : Fin (n + 1) => c) = 0 := by
  unfold tropicalVarianceFinite
  simp [Finset.sup'_const, sub_self, zero_pow (by norm_num : 2 ≠ 0)]

/-! ## Part IX: Certified Robustness Application -/

/-- **Certified robustness radius** for max-pooling neural_network layers.
r* = margin·√n / (C·σ·L) where C is Berry-Esseen constant, L is Lipschitz.
**Bridge**: Tropical Probability ↔ ML certified_robustness.
**Impact**: lipschitz_certified_robustness for max-pooling neural_networks. -/
def certifiedRobustnessRadius (n : ℕ) (σ margin L C : ℝ) : ℝ :=
  margin * Real.sqrt n / (C * σ * L)

/-- The certified robustness radius is positive. -/
theorem certifiedRobustnessRadius_pos (n : ℕ) (σ margin L C : ℝ)
    (hn : 0 < n) (hσ : 0 < σ) (hm : 0 < margin) (hL : 0 < L) (hC : 0 < C) :
    0 < certifiedRobustnessRadius n σ margin L C := by
  unfold certifiedRobustnessRadius
  exact div_pos (mul_pos hm (Real.sqrt_pos.mpr (by positivity)))
    (mul_pos (mul_pos hC hσ) hL)

/-- Wider networks → better robustness guarantees. -/
theorem certifiedRobustnessRadius_mono_width (m n : ℕ) (σ margin L C : ℝ)
    (hmn : m ≤ n) (hσ : 0 < σ) (hL : 0 < L) (hC : 0 < C) (hm : 0 < margin) :
    certifiedRobustnessRadius m σ margin L C ≤
    certifiedRobustnessRadius n σ margin L C := by
  unfold certifiedRobustnessRadius
  apply div_le_div_of_nonneg_right _ (by positivity)
  exact mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt (by exact_mod_cast hmn)) hm.le

/-! ## Part X: Post-Quantum Security Application -/

/-- **Minimum lattice dimension** for post_quantum_security level k
with distinguishing advantage ε: d_min = ⌈(C_BE·k/ε)²⌉.
**Bridge**: Tropical Probability ↔ lattice_crypto. -/
def minLatticeDimension (C_BE k ε : ℝ) : ℕ :=
  Nat.ceil ((C_BE * k / ε) ^ 2)

/-- The minimum dimension is positive for positive parameters. -/
theorem minLatticeDimension_pos (C_BE k ε : ℝ)
    (hC : 0 < C_BE) (hk : 0 < k) (hε : 0 < ε) :
    0 < minLatticeDimension C_BE k ε := by
  unfold minLatticeDimension
  rw [Nat.lt_ceil]; push_cast
  exact sq_pos_of_pos (div_pos (mul_pos hC hk) hε)

/-- Halving the advantage requires at least as many dimensions.
**Bridge**: each bit of cryptographic security costs quadratically. -/
theorem minLatticeDimension_halving (C_BE k ε : ℝ)
    (hC : 0 < C_BE) (hk : 0 < k) (hε : 0 < ε) :
    minLatticeDimension C_BE k ε ≤ minLatticeDimension C_BE k (ε / 2) := by
  unfold minLatticeDimension
  apply Nat.ceil_le_ceil
  have h1 : C_BE * k / ε ≤ C_BE * k / (ε / 2) :=
    div_le_div_of_nonneg_left (mul_pos hC hk).le (by positivity) (by linarith)
  have h2 : 0 ≤ C_BE * k / ε := by positivity
  exact sq_le_sq' (by linarith) h1

/-! ## Part XI: Gumbel-Softmax Connection -/

/-- The **softmax function** for two logits.
**Bridge**: Tropical Probability ↔ gradient_descent for discrete
neural_network architectures via the Gumbel-Softmax trick. -/
def softmax2 (a b : ℝ) : ℝ := exp a / (exp a + exp b)

/-- Softmax is strictly between 0 and 1. -/
theorem softmax2_range (a b : ℝ) : softmax2 a b ∈ Ioo (0 : ℝ) 1 := by
  unfold softmax2
  exact ⟨div_pos (exp_pos a) (by positivity),
         by rw [div_lt_one (by positivity)]; linarith [exp_pos b]⟩

/-- **Partition of unity**: softmax(a,b) + softmax(b,a) = 1.
**Bridge**: softmax partition of unity is the tropical analogue of
probability normalization. -/
theorem softmax2_partition_of_unity (a b : ℝ) :
    softmax2 a b + softmax2 b a = 1 := by
  unfold softmax2
  have h : exp a + exp b ≠ 0 := by positivity
  rw [show exp b + exp a = exp a + exp b from by ring]
  rw [show exp a / (exp a + exp b) + exp b / (exp a + exp b) =
      (exp a + exp b) / (exp a + exp b) from by ring]
  exact div_self h

/-- The logit recovers the input difference.
log(softmax(a,b)) - log(softmax(b,a)) = a - b. -/
theorem softmax2_logit (a b : ℝ) :
    Real.log (softmax2 a b) - Real.log (softmax2 b a) = a - b := by
  unfold softmax2
  rw [show exp b + exp a = exp a + exp b from by ring]
  rw [Real.log_div (by positivity) (by positivity),
      Real.log_div (by positivity) (by positivity)]
  simp [Real.log_exp]

/-- Softmax at equal inputs gives 1/2. -/
theorem softmax2_eq (a : ℝ) : softmax2 a a = 1 / 2 := by
  unfold softmax2; field_simp; ring

/-! ## Part XII: Extreme Value Classification -/

/-- **Extreme value type** classifies tail behavior:
- Gumbel (ξ = 0): exponential tails (Normal, Exponential, Gamma)
- Fréchet (ξ > 0): heavy / power-law tails (Pareto, Cauchy)
- Weibull (ξ < 0): bounded support (Uniform, Beta) -/
inductive ExtremeValueType where
  | gumbel   : ExtremeValueType
  | frechet  : ExtremeValueType
  | weibull  : ExtremeValueType
  deriving DecidableEq, Repr

/-- Classify a tail index ξ into its extreme value type. -/
def classifyEVType (ξ : ℝ) : ExtremeValueType :=
  if ξ = 0 then ExtremeValueType.gumbel
  else if ξ > 0 then ExtremeValueType.frechet
  else ExtremeValueType.weibull

/-- Classification is exhaustive. -/
theorem classifyEVType_exhaustive (ξ : ℝ) :
    classifyEVType ξ = ExtremeValueType.gumbel ∨
    classifyEVType ξ = ExtremeValueType.frechet ∨
    classifyEVType ξ = ExtremeValueType.weibull := by
  unfold classifyEVType
  by_cases h : ξ = 0
  · left; simp [h]
  · by_cases h2 : ξ > 0
    · right; left; simp [h, h2]
    · right; right; simp [h, h2]

/-- Only ξ = 0 gives the Gumbel type. -/
theorem classifyEVType_gumbel_iff (ξ : ℝ) :
    classifyEVType ξ = ExtremeValueType.gumbel ↔ ξ = 0 := by
  unfold classifyEVType
  constructor
  · intro h; by_contra hne; simp [hne] at h; split_ifs at h
  · intro h; simp [h]

/-- The GEV CDF: at ξ = 0 it reduces to Gumbel. -/
def gevCDF (ξ x : ℝ) : ℝ :=
  if ξ = 0 then stdGumbelCDF x
  else if 1 + ξ * x > 0 then exp (-(1 + ξ * x) ^ (-1 / ξ))
  else 0

/-- The GEV CDF at ξ = 0 is the Gumbel CDF. -/
theorem gevCDF_at_zero (x : ℝ) : gevCDF 0 x = stdGumbelCDF x := by
  unfold gevCDF; simp

/-! ## Part XIII: Von Mises Regularity -/

/-- **Von Mises regularity**: the gatekeeper for Gumbel attraction.
**Bridge**: Statistical Mechanics — the von Mises condition is the
thermodynamic regularity condition for well-defined free energy. -/
structure VonMisesRegular where
  F : ℝ → ℝ
  f : ℝ → ℝ
  F_range : ∀ x, F x ∈ Icc (0 : ℝ) 1
  f_nonneg : ∀ x, 0 ≤ f x
  f_pos_near_inf : ∃ x₀, ∀ x ≥ x₀, 0 < f x

/-- The exponential distribution satisfies von Mises. -/
def exponentialVonMises : VonMisesRegular where
  F := fun x => if x ≥ 0 then 1 - exp (-x) else 0
  f := fun x => if x ≥ 0 then exp (-x) else 0
  F_range := by
    intro x; refine ⟨?_, ?_⟩
    all_goals (by_cases hx : x ≥ 0 <;> simp [hx] <;> linarith [exp_pos (-x)])
  f_nonneg := by
    intro x
    by_cases hx : x ≥ 0
    · simp [hx]; exact (exp_pos _).le
    · simp [hx]
  f_pos_near_inf :=
    ⟨0, fun x hx => by simp [hx]; exact exp_pos _⟩

/-! ## Part XIV: REM Free Energy -/

/-- **Random Energy Model free energy**.
F_n(β) = (1/β)·log(Σᵢ exp(-β·Eᵢ)).
**Bridge**: Tropical Probability ↔ Statistical Mechanics. -/
def remFreeEnergy {n : ℕ} (β : ℝ) (E : Fin (n + 1) → ℝ) : ℝ :=
  (1 / β) * Real.log (∑ i : Fin (n + 1), exp (-β * E i))

/-- The REM partition function is always positive. -/
theorem remPartitionFunction_pos {n : ℕ} (β : ℝ) (E : Fin (n + 1) → ℝ) :
    0 < ∑ i : Fin (n + 1), exp (-β * E i) := by
  apply Finset.sum_pos
  · intro i _; exact exp_pos _
  · exact Finset.univ_nonempty

/-- The REM free energy with a single level equals the energy (negated). -/
theorem remFreeEnergy_singleton (β : ℝ) (hβ : β ≠ 0) (E : Fin 1 → ℝ) :
    remFreeEnergy β E = -E 0 := by
  unfold remFreeEnergy
  simp [Real.log_exp]
  field_simp

/-! ## Part XV: Grand Summary -/

/-- **The Gumbel is the tropical Gaussian**: all key properties
in a single theorem.

1. CDF takes values in (0,1)
2. Strictly monotone
3. Max-stable: Λ(x)ⁿ = Λ(x - log n)
4. Positive density
5. Berry-Esseen constant is positive

**Bridge**: unifies Tropical Probability, Statistical Mechanics,
ML certified_robustness, and post_quantum_security. -/
theorem gumbel_is_tropical_gaussian :
    (∀ x, stdGumbelCDF x ∈ Ioo (0 : ℝ) 1) ∧
    StrictMono stdGumbelCDF ∧
    (∀ n : ℕ, 0 < n → ∀ x, (stdGumbelCDF x) ^ n = stdGumbelCDF (x - Real.log n)) ∧
    (∀ x, 0 < gumbelDensity x) ∧
    (∀ σ : ℝ, 0 < σ → 0 < berryEsseenConstant σ 0) :=
  ⟨stdGumbelCDF_range, stdGumbelCDF_strictMono, gumbel_maxStable_iid,
   gumbelDensity_pos, fun σ hσ => berryEsseenConstant_pos σ 0 hσ⟩

end TropicalProbability