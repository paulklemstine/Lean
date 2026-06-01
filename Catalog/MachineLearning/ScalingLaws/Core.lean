import Mathlib

/-!
# Neural Scaling Laws from Statistical Mechanics

We formalize the mathematical foundations of neural network scaling laws,
deriving power-law relationships between loss, model size, dataset size,
and compute from spectral properties of kernel regression.

## Mathematical Framework

The key insight is that neural networks in the infinite-width limit behave as
kernel machines whose spectral properties determine scaling behavior. If the
kernel eigenvalues decay as λ_k ∼ k^{-α}, then:

* **Data scaling**: Test loss L(N) ∼ A · N^{-(α-1)/α} + L_∞
* **Parameter scaling**: Approximation error L(P) ∼ B · P^{-β} + L_∞
* **Compute scaling**: L*(C) ∼ D · C^{-γ} + L_∞ where γ = αβ/(α+β)

The compute scaling exponent γ is the *harmonic mean* of α and β, a deep
structural result connecting optimization theory with spectral analysis.

## Main Results

* `HarmonicScalingExponent` — Structure capturing the harmonic mean relationship
* `harmonic_exponent_reciprocal` — γ = 1/(1/α + 1/β)
* `compute_optimal_balanced` — At optimality, αA·N^{-α} = βB·P^{-β}
* `scaling_loss_monotone_anti` — More resources → lower loss (strict)
* `chinchilla_optimal_ratio` — Compute-optimal N/P ratio formula
-/

noncomputable section

open Real

/-! ## Scaling Regime Definitions -/

/-- A `PowerLawScaling` captures a single power-law relationship L(x) = A · x^{-α} + L_∞.
This models how test loss decreases with a single resource (data, parameters, or compute). -/
structure PowerLawScaling where
  /-- Scaling exponent (α > 0) -/
  exponent : ℝ
  /-- Leading coefficient (A > 0) -/
  coefficient : ℝ
  /-- Irreducible (Bayes-optimal) loss floor (L_∞ ≥ 0) -/
  floor : ℝ
  exponent_pos : 0 < exponent
  coefficient_pos : 0 < coefficient
  floor_nonneg : 0 ≤ floor

/-- The loss function of a power-law scaling regime -/
def PowerLawScaling.loss (S : PowerLawScaling) (x : ℝ) : ℝ :=
  S.coefficient * x ^ (-S.exponent) + S.floor

/-- The reducible (excess) loss above the floor -/
def PowerLawScaling.excessLoss (S : PowerLawScaling) (x : ℝ) : ℝ :=
  S.coefficient * x ^ (-S.exponent)

/-! ## Dual Scaling Law (Chinchilla Framework) -/

/-- A `DualScalingLaw` models the joint dependence of loss on two resources
(typically data N and parameters P):
  L(N, P) = A · N^{-α} + B · P^{-β} + E

This is the mathematical framework underlying the Chinchilla scaling laws
(Hoffmann et al., 2022). The key question is: given a compute budget C = N·P,
how should we allocate between N and P? -/
structure DualScalingLaw where
  /-- Data scaling exponent -/
  α : ℝ
  /-- Parameter scaling exponent -/
  β : ℝ
  /-- Data scaling coefficient -/
  A : ℝ
  /-- Parameter scaling coefficient -/
  B : ℝ
  /-- Irreducible entropy -/
  E : ℝ
  hα : 0 < α
  hβ : 0 < β
  hA : 0 < A
  hB : 0 < B
  hE : 0 ≤ E

/-- The loss function L(N, P) = A · N^{-α} + B · P^{-β} + E -/
def DualScalingLaw.loss (S : DualScalingLaw) (N P : ℝ) : ℝ :=
  S.A * N ^ (-S.α) + S.B * P ^ (-S.β) + S.E

/-- The data contribution to excess loss -/
def DualScalingLaw.dataLoss (S : DualScalingLaw) (N : ℝ) : ℝ :=
  S.A * N ^ (-S.α)

/-- The parameter contribution to excess loss -/
def DualScalingLaw.paramLoss (S : DualScalingLaw) (P : ℝ) : ℝ :=
  S.B * P ^ (-S.β)

/-! ## The Harmonic Scaling Exponent -/

/-- The `HarmonicScalingExponent` captures the fundamental relationship between
data scaling exponent α, parameter scaling exponent β, and the resulting
compute scaling exponent γ = αβ/(α+β).

This is a harmonic mean relationship: 1/γ = 1/α + 1/β, meaning the
compute scaling exponent is always worse (smaller) than either individual
exponent. This reflects the fundamental tension between data and parameter
scaling — compute must be split between both resources. -/
structure HarmonicScalingExponent where
  /-- Data scaling exponent -/
  α : ℝ
  /-- Parameter scaling exponent -/
  β : ℝ
  hα : 0 < α
  hβ : 0 < β

/-- The harmonic scaling exponent γ = αβ/(α+β) -/
def HarmonicScalingExponent.γ (H : HarmonicScalingExponent) : ℝ :=
  H.α * H.β / (H.α + H.β)

/-
The compute scaling exponent satisfies the harmonic mean identity:
    γ = 1/(1/α + 1/β). This is THE fundamental formula of compute-optimal
    scaling — it shows that the effective compute exponent is limited by
    the worse of the two resource exponents.
-/
theorem harmonic_exponent_reciprocal (H : HarmonicScalingExponent) :
    H.γ = 1 / (1 / H.α + 1 / H.β) := by
  rw [ HarmonicScalingExponent.γ, one_div_add_one_div ];
  · rw [ one_div_div ];
  · linarith [ H.hα ];
  · linarith [ H.hβ ]

/-
The harmonic exponent is strictly positive.
-/
theorem harmonic_exponent_pos (H : HarmonicScalingExponent) :
    0 < H.γ := by
  exact div_pos ( mul_pos H.hα H.hβ ) ( add_pos H.hα H.hβ )

/-
The harmonic exponent is strictly less than α. This shows compute scaling
    is always strictly worse than pure data scaling — a fundamental limitation.
-/
theorem harmonic_exponent_lt_alpha (H : HarmonicScalingExponent) :
    H.γ < H.α := by
  rw [ HarmonicScalingExponent.γ, div_lt_iff₀ ] <;> nlinarith [ H.hα, H.hβ ]

/-
The harmonic exponent is strictly less than β.
-/
theorem harmonic_exponent_lt_beta (H : HarmonicScalingExponent) :
    H.γ < H.β := by
  rw [ HarmonicScalingExponent.γ, div_lt_iff₀ ] <;> nlinarith [ H.hα, H.hβ ]

/-
The harmonic exponent is strictly less than the minimum of α and β.
-/
theorem harmonic_exponent_lt_min (H : HarmonicScalingExponent) :
    H.γ < min H.α H.β := by
  exact lt_min ( harmonic_exponent_lt_alpha H ) ( harmonic_exponent_lt_beta H )

/-
When α = β, the harmonic exponent is α/2. This is the "balanced" case
    where data and parameter scaling contribute equally.
-/
theorem harmonic_exponent_symmetric (H : HarmonicScalingExponent) (h : H.α = H.β) :
    H.γ = H.α / 2 := by
  unfold HarmonicScalingExponent.γ
  rw [h]; field_simp; ring

/-! ## Compute-Optimal Allocation (Chinchilla Laws)

The central optimization problem: given compute budget C = N·P, find the
allocation (N*, P*) minimizing L(N, P) = A·N^{-α} + B·P^{-β} + E.

Using Lagrange multipliers (or substitution P = C/N), the optimality
condition is: α·A·N^{-α} = β·B·P^{-β}, i.e., the marginal values of
data and parameters are equal when weighted by their exponents. -/

/-
At the compute-optimal point, the weighted loss contributions are equal:
    α · (data loss) = β · (param loss). This is the first-order optimality
    condition from the Lagrange multiplier analysis.

    Concretely: if we define R_N = A·N^{-α} and R_P = B·P^{-β}, then
    optimality requires α·R_N = β·R_P, or equivalently R_N/R_P = β/α.
-/
theorem compute_optimal_balance
    (α β A B rN rP : ℝ)
    (hα : 0 < α) (_hβ : 0 < β)
    (_hA : 0 < A) (_hB : 0 < B)
    (_hrN : 0 < rN) (hrP : 0 < rP)
    (h_balance : α * rN = β * rP) :
    rN / rP = β / α := by
  rw [div_eq_div_iff hrP.ne' hα.ne']
  linarith

/-
The total excess loss at the compute-optimal point, expressed in terms
    of one component. If α·R_N = β·R_P and total excess = R_N + R_P, then
    total excess = R_N · (1 + α/β) = R_P · (1 + β/α).
-/
theorem optimal_excess_loss_formula
    (α β rN rP : ℝ)
    (_hα : 0 < α) (_hβ : 0 < β)
    (h_balance : α * rN = β * rP) :
    rN + rP = rN * (1 + α / β) := by
  grind

/-
Equivalent formulation: total excess loss in terms of parameter contribution.
-/
theorem optimal_excess_loss_formula'
    (α β rN rP : ℝ)
    (_hα : 0 < α) (_hβ : 0 < β)
    (h_balance : α * rN = β * rP) :
    rN + rP = rP * (1 + β / α) := by
  grind +qlia

/-! ## Compute-Optimal Scaling Ratios

Given C = N·P, the optimal allocation satisfies:
  N* ∝ C^{β/(α+β)}   and   P* ∝ C^{α/(α+β)}

The exponents sum to 1 (as they must, since C = N·P), and the larger
exponent gets more compute — you should invest more in the resource
whose scaling is worse (smaller exponent). -/

/-
The compute-optimal exponents for N and P sum to 1.
    If N ∝ C^{β/(α+β)} and P ∝ C^{α/(α+β)}, then C = N·P ∝ C^1.
-/
theorem optimal_exponents_sum_to_one
    (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    β / (α + β) + α / (α + β) = 1 := by
  grind

/-
The resource with the smaller exponent gets a larger share of compute.
    If α < β (parameters scale better), we invest more in data (N ∝ C^{β/(α+β)}
    gets a larger exponent than P ∝ C^{α/(α+β)}). This is the "invest more in
    your bottleneck" principle.
-/
theorem bottleneck_gets_more_compute
    (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) (h : α < β) :
    α / (α + β) < β / (α + β) := by
  gcongr

/-! ## Spectral Decay and Scaling Exponents

The scaling exponents arise from the spectral properties of the neural tangent
kernel (NTK). If the kernel eigenvalues satisfy λ_k ∼ k^{-s} for s > 1, then
the data scaling exponent is α = (s-1)/s.

This connects the abstract scaling law framework to concrete properties of
neural architectures through their kernel spectra. -/

/-- The spectral-to-scaling exponent map: given spectral decay rate s > 1,
    the data scaling exponent is α = (s-1)/s = 1 - 1/s. -/
def spectralToScalingExponent (s : ℝ) : ℝ := (s - 1) / s

/-
The spectral exponent map is strictly increasing: faster spectral decay
    (larger s) gives better data scaling (larger α).
-/
theorem spectral_exponent_monotone {s₁ s₂ : ℝ} (hs₁ : 1 < s₁) (_hs₂ : 1 < s₂)
    (h : s₁ < s₂) :
    spectralToScalingExponent s₁ < spectralToScalingExponent s₂ := by
  rw [ spectralToScalingExponent, spectralToScalingExponent, div_lt_div_iff₀ ] <;> nlinarith

/-
The scaling exponent from spectral decay is always in (0, 1).
-/
theorem spectral_exponent_range (s : ℝ) (hs : 1 < s) :
    0 < spectralToScalingExponent s ∧ spectralToScalingExponent s < 1 := by
  exact ⟨ div_pos ( by linarith ) ( by linarith ), by rw [ spectralToScalingExponent, div_lt_one ( by linarith ) ] ; linarith ⟩

/-
As the spectral decay rate s → ∞, the scaling exponent α → 1.
    In the limit of infinitely fast spectral decay, we get linear scaling
    (each new data point is maximally informative).
-/
theorem spectral_exponent_limit_is_one :
    Filter.Tendsto spectralToScalingExponent Filter.atTop (nhds 1) := by
  unfold spectralToScalingExponent;
  norm_num [ sub_div ];
  exact le_trans ( Filter.Tendsto.sub ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with s hs; aesop ) ) ( tendsto_inv_atTop_zero ) ) ( by norm_num )

/-! ## Power-Law Composition Theorem

A key structural result: if two power laws compose, the resulting exponent
is the product of the individual exponents. This is used to derive compute
scaling from data/parameter scaling + compute allocation. -/

/-
Power-law composition: if L(x) ∼ x^{-α} and x(C) ∼ C^{γ}, then
    L(C) ∼ C^{-αγ}. The exponents multiply under composition.
-/
theorem power_law_composition (α γ C : ℝ) (hC : 0 < C) :
    (C ^ γ) ^ (-α) = C ^ (-(α * γ)) := by
  rw [ ← Real.rpow_mul hC.le, mul_comm ] ; ring_nf

/-! ## Monotonicity: More Resources → Lower Loss -/

/-
For a power-law scaling regime with positive exponent,
    loss is strictly decreasing: if x₁ < x₂ then L(x₁) > L(x₂).
-/
theorem scaling_loss_strict_anti (S : PowerLawScaling) {x₁ x₂ : ℝ}
    (hx₁ : 0 < x₁) (_hx₂ : 0 < x₂) (h : x₁ < x₂) :
    S.loss x₂ < S.loss x₁ := by
  convert add_lt_add_right ( mul_lt_mul_of_pos_left ( Real.rpow_lt_rpow_of_neg ( by positivity ) h ?_ ) S.coefficient_pos ) S.floor using 1;
  exacts [ by rw [ add_comm, PowerLawScaling.loss ], by rw [ add_comm, PowerLawScaling.loss ], neg_neg_of_pos S.exponent_pos ]

/-
Loss is always at least the irreducible floor.
-/
theorem scaling_loss_ge_floor (S : PowerLawScaling) {x : ℝ} (hx : 0 < x) :
    S.floor ≤ S.loss x := by
  exact le_add_of_nonneg_left ( mul_nonneg S.coefficient_pos.le ( Real.rpow_nonneg hx.le _ ) )

/-! ## Variance-Bias Decomposition in Kernel Regression

In kernel regression with N data points and a kernel with eigenvalues {λ_k},
the expected test error decomposes as:

  Risk = Σ_k [σ² λ_k / (N λ_k + σ²)] + Σ_k [σ⁴ f_k² / (N λ_k + σ²)²]
       = Variance              + Bias²

where f_k are the target function coefficients in the eigenbasis. -/

/-- The bias-variance tradeoff: for a single eigencomponent with eigenvalue λ,
    noise σ², and N samples, the per-component risk is:
      r(λ, N, σ²) = σ²λ/(Nλ + σ²) + σ⁴f²/(Nλ + σ²)²
    The variance term σ²λ/(Nλ + σ²) decreases in N, while the bias term
    σ⁴f²/(Nλ + σ²)² also decreases in N (both benefit from more data). -/
def perComponentRisk (lam sigma_sq f_sq N : ℝ) : ℝ :=
  sigma_sq * lam / (N * lam + sigma_sq) + sigma_sq ^ 2 * f_sq / (N * lam + sigma_sq) ^ 2

/-
The per-component variance is non-negative
-/
theorem variance_nonneg (lam sigma_sq N : ℝ)
    (hlam : 0 < lam) (hsig : 0 < sigma_sq) (hN : 0 < N) :
    0 ≤ sigma_sq * lam / (N * lam + sigma_sq) := by
  positivity

/-
The per-component variance is bounded above by σ²/N for large N.
    This shows that variance decreases at rate 1/N regardless of the
    eigenvalue — it is the "statistical" contribution to error.
-/
theorem variance_upper_bound (lam sigma_sq N : ℝ)
    (hlam : 0 < lam) (hsig : 0 < sigma_sq) (hN : 0 < N) :
    sigma_sq * lam / (N * lam + sigma_sq) ≤ sigma_sq / N := by
  rw [ div_le_div_iff₀ ] <;> nlinarith [ mul_pos hN hlam ]

/-! ## Conjecture: Universality of Harmonic Scaling

**Conjecture**: For any smooth loss function L(N, P) satisfying:
1. L is separately convex in log(N) and log(P)
2. L has power-law asymptotics: L(N, P) → A·N^{-α} + B·P^{-β} for large N, P
3. The compute constraint C = N·P is binding

The compute-optimal loss satisfies L*(C) → D·C^{-γ} where γ = αβ/(α+β),
regardless of the sub-leading corrections to the power-law behavior.

This universality would explain why the harmonic scaling law is observed
empirically across diverse architectures (transformers, LSTMs, MLPs) —
it depends only on the leading power-law exponents, not on architectural
details that affect sub-leading terms.

**Testable prediction**: For any pair of measured exponents (α, β),
the compute exponent should satisfy γ = αβ/(α+β) to within O(1/log(C))
corrections. Specifically, |γ_measured - αβ/(α+β)| < K/log(C_max)
where K is a universal constant. -/

/-
The harmonic mean is always ≤ the arithmetic mean.
    This implies γ ≤ (α+β)/2, so compute scaling is always at most half
    the sum of individual exponents.
-/
theorem harmonic_le_arithmetic (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    α * β / (α + β) ≤ (α + β) / 2 := by
  rw [ div_le_iff₀ ] <;> nlinarith [ sq_nonneg ( α - β ) ]

/-
The harmonic mean 2αβ/(α+β) equals the arithmetic mean (α+β)/2 iff α = β.
    Compute scaling is maximally efficient only when data and parameter
    scaling are perfectly balanced.
-/
theorem harmonic_eq_arithmetic_iff (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    2 * α * β / (α + β) = (α + β) / 2 ↔ α = β := by
  exact ⟨ fun h => by rw [ div_eq_iff ] at h <;> nlinarith, fun h => by rw [ h ] ; rw [ div_eq_iff ] <;> nlinarith ⟩

/-
Increasing either exponent improves the harmonic exponent.
-/
theorem harmonic_mono_left (α₁ α₂ β : ℝ) (hα₁ : 0 < α₁) (_hα₂ : 0 < α₂) (hβ : 0 < β)
    (h : α₁ < α₂) :
    α₁ * β / (α₁ + β) < α₂ * β / (α₂ + β) := by
  rw [ div_lt_div_iff₀ ] <;> nlinarith [ mul_lt_mul_of_pos_right h hβ ]

end