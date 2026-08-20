import Catalog.NumberTheory.RLHFLogConvexity

/-!
# Curvature of the RLHF value curve is the reward variance

The previous cycle proved *midpoint* log-convexity of the RLHF partition function
(`RLHF.expSum_sq_le`, `RLHF.expSum_sq_lt`) by Cauchy–Schwarz, and listed the differential
identity behind it as the first open sub-conjecture: the second derivative of `log Z` should
be the reward variance under the tilted (Gibbs) policy.  This file proves that identity and
harvests it.

Writing `t = 1/β` for the inverse KL temperature and

```
M_k(t) = ∑_y p y · (r y)^k · exp (r y · t)
```

for the exponential moments of the reward model, the main results are:

* `RLHF.hasDerivAt_expMoment` — `M_k' = M_{k+1}`: differentiating the partition function
  raises the moment index.  (Induction-free but genuinely analytic: a finite sum of
  `HasDerivAt`s.)
* `RLHF.hasDerivAt_logExpMoment` — `(log M_0)' = M_1 / M_0 = 𝔼_{π_t}[r]`, the aligned
  expected reward.
* `RLHF.hasDerivAt_tiltMean` and `RLHF.deriv2_logExpMoment_eq_tiltVar` — **the curvature
  identity** `(log M_0)'' = Var_{π_t}(r)`, with `RLHF.tiltVar_eq_sum` exhibiting the
  curvature as an honest sum of squares.
* `RLHF.convexOn_logExpMoment` and `RLHF.strictConvexOn_logExpMoment` — consequently
  `t ↦ log Z(t)` is convex on all of `ℝ`, and *strictly* convex as soon as the reward model
  is non-constant.  This upgrades the midpoint statements of `RLHFLogConvexity` to full
  convexity, and `RLHF.freeEnergy_convex_comb` transports it to the temperature variable:
  the normalized alignment value obeys the annealing inequality for *every* convex
  combination of inverse temperatures, not only the harmonic midpoint.
* `RLHF.tiltMean_monotone`, `RLHF.tiltVar_le_range_sq` and `RLHF.tiltMean_drift_le` — a
  **speed limit for alignment**: the aligned expected reward is monotone in the inverse
  temperature, its rate of increase is the variance, and Popoviciu's inequality caps that
  variance by `(M − m)²/4` for a reward model confined to `[m, M]`, uniformly in the size of
  the response space.
* `RLHF.integral_tiltVar` — the **variance-flow identity**
  `∫_{t₁}^{t₂} Var_{π_t}(r) dt = 𝔼_{π_{t₂}}[r] − 𝔼_{π_{t₁}}[r]`, the exact form of the speed
  limit above.
* `RLHF.convexOn_truncZetaLog` and `RLHF.strictConvexOn_truncZetaLog` — the arithmetic
  shadow: `s ↦ log (∑_{n=1}^{N} n^{-s})` is strictly convex on `ℝ` for `N ≥ 2`, i.e. the
  truncated Riemann zeta function is strictly log-convex in the exponent, and its curvature
  is the variance of `log n` under the truncated zeta distribution
  (`RLHF.truncZeta_curvature_eq_variance`).
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Exponential moments of the reward model -/

/-- The `k`-th exponential moment `M_k(t) = ∑_y p y (r y)^k exp (r y t)`.  `M_0` is the
partition function of the RLHF problem at inverse temperature `t`. -/
noncomputable def expMoment (k : ℕ) (r p : Ω → ℝ) (t : ℝ) : ℝ :=
  ∑ y, p y * r y ^ k * Real.exp (r y * t)

omit [Nonempty Ω] in
/-- The partition function at KL coefficient `β` is the zeroth moment at inverse
temperature `β⁻¹`. -/
theorem partition_eq_expMoment (β : ℝ) (r p : Ω → ℝ) :
    partition β r p = expMoment 0 r p β⁻¹ := by
  unfold partition expMoment
  exact Finset.sum_congr rfl (fun y _ => by rw [div_eq_mul_inv]; ring)

theorem expMoment_zero_pos {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t : ℝ) :
    0 < expMoment 0 r p t :=
  Finset.sum_pos (fun y _ => by have := hp y; positivity) univ_nonempty

omit [Nonempty Ω] in
/-- **Differentiating raises the moment index**: `M_k' = M_{k+1}`. -/
theorem hasDerivAt_expMoment (k : ℕ) (r p : Ω → ℝ) (t : ℝ) :
    HasDerivAt (expMoment k r p) (expMoment (k + 1) r p t) t := by
  have h : ∀ y ∈ (univ : Finset Ω),
      HasDerivAt (fun t => p y * r y ^ k * Real.exp (r y * t))
        (p y * r y ^ (k + 1) * Real.exp (r y * t)) t := by
    intro y _
    have h1 : HasDerivAt (fun t : ℝ => r y * t) (r y) t := by
      simpa using (hasDerivAt_id t).const_mul (r y)
    have h2 : HasDerivAt (fun t : ℝ => Real.exp (r y * t)) (Real.exp (r y * t) * r y) t := h1.exp
    have h3 := h2.const_mul (p y * r y ^ k)
    convert h3 using 1
    ring
  have hs := HasDerivAt.sum h
  have hfun : (∑ y ∈ (univ : Finset Ω), fun t => p y * r y ^ k * Real.exp (r y * t))
      = expMoment k r p := by
    funext s
    simp [expMoment, Finset.sum_apply]
  rw [hfun] at hs
  exact hs

omit [Nonempty Ω] in
theorem differentiable_expMoment (k : ℕ) (r p : Ω → ℝ) :
    Differentiable ℝ (expMoment k r p) :=
  fun t => (hasDerivAt_expMoment k r p t).differentiableAt

/-! ## 2. The tilted policy, its mean reward and its reward variance -/

/-- The Gibbs weights at inverse temperature `t`, i.e. the aligned policy `π_{1/t}`. -/
noncomputable def tiltWeight (r p : Ω → ℝ) (t : ℝ) : Ω → ℝ :=
  fun y => p y * Real.exp (r y * t) / expMoment 0 r p t

/-- The mean reward under the aligned policy, `𝔼_{π_t}[r] = M_1 / M_0`. -/
noncomputable def tiltMean (r p : Ω → ℝ) (t : ℝ) : ℝ := expMoment 1 r p t / expMoment 0 r p t

/-- The reward variance under the aligned policy, `Var_{π_t}(r) = M_2/M_0 − (M_1/M_0)²`. -/
noncomputable def tiltVar (r p : Ω → ℝ) (t : ℝ) : ℝ :=
  expMoment 2 r p t / expMoment 0 r p t - (tiltMean r p t) ^ 2

omit [Nonempty Ω] in
theorem tiltWeight_moment (k : ℕ) (r p : Ω → ℝ) (t : ℝ) :
    ∑ y, tiltWeight r p t y * r y ^ k = expMoment k r p t / expMoment 0 r p t := by
  have h : ∀ y, tiltWeight r p t y * r y ^ k
      = (p y * r y ^ k * Real.exp (r y * t)) / expMoment 0 r p t := by
    intro y; unfold tiltWeight; ring
  rw [Finset.sum_congr rfl (fun y _ => h y), ← Finset.sum_div]
  rfl

theorem tiltWeight_sum {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t : ℝ) :
    ∑ y, tiltWeight r p t y = 1 := by
  have h0 := expMoment_zero_pos (r := r) hp t
  have h := tiltWeight_moment 0 r p t
  simpa [div_self (ne_of_gt h0)] using h

/-- **The curvature is a sum of squares.**  `Var_{π_t}(r) = ∑_y π_t(y) (r y − 𝔼_{π_t} r)²`. -/
theorem tiltVar_eq_sum {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t : ℝ) :
    tiltVar r p t = ∑ y, tiltWeight r p t y * (r y - tiltMean r p t) ^ 2 := by
  set m := tiltMean r p t with hm
  have h1 : ∀ y, tiltWeight r p t y * (r y - m) ^ 2
      = tiltWeight r p t y * r y ^ 2 - 2 * m * (tiltWeight r p t y * r y ^ 1)
        + m ^ 2 * tiltWeight r p t y := by
    intro y; ring
  rw [Finset.sum_congr rfl (fun y _ => h1 y), Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, tiltWeight_moment 2 r p t, tiltWeight_moment 1 r p t,
    tiltWeight_sum hp t]
  have hmm : m = expMoment 1 r p t / expMoment 0 r p t := rfl
  unfold tiltVar
  rw [← hm, hmm]
  ring

theorem tiltVar_nonneg {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t : ℝ) : 0 ≤ tiltVar r p t := by
  rw [tiltVar_eq_sum hp t]
  refine Finset.sum_nonneg (fun y _ => ?_)
  have h0 := expMoment_zero_pos (r := r) hp t
  have hw : 0 < tiltWeight r p t y := by
    unfold tiltWeight; have := hp y; positivity
  positivity

/-- The curvature is *strictly* positive exactly in the non-degenerate case: a reward model
taking two different values. -/
theorem tiltVar_pos {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) {y₀ z₀ : Ω} (hr : r y₀ ≠ r z₀) (t : ℝ) :
    0 < tiltVar r p t := by
  have h0 := expMoment_zero_pos (r := r) hp t
  have hw : ∀ y, 0 < tiltWeight r p t y := by
    intro y; unfold tiltWeight; have := hp y; positivity
  rw [tiltVar_eq_sum hp t]
  have hne : r y₀ ≠ tiltMean r p t ∨ r z₀ ≠ tiltMean r p t := by
    by_contra hc
    push_neg at hc
    exact hr (hc.1.trans hc.2.symm)
  refine Finset.sum_pos' (fun y _ => ?_) ?_
  · have := hw y; positivity
  · rcases hne with h | h
    · refine ⟨y₀, Finset.mem_univ _, ?_⟩
      have hs : r y₀ - tiltMean r p t ≠ 0 := sub_ne_zero.mpr h
      exact mul_pos (hw y₀) (by positivity)
    · refine ⟨z₀, Finset.mem_univ _, ?_⟩
      have hs : r z₀ - tiltMean r p t ≠ 0 := sub_ne_zero.mpr h
      exact mul_pos (hw z₀) (by positivity)

/-! ## 3. First and second derivatives of the log-partition function -/

/-- `(log Z)'(t) = 𝔼_{π_t}[r]`: the slope of the value curve is the aligned expected
reward. -/
theorem hasDerivAt_logExpMoment {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t : ℝ) :
    HasDerivAt (fun t => Real.log (expMoment 0 r p t)) (tiltMean r p t) t :=
  (hasDerivAt_expMoment 0 r p t).log (ne_of_gt (expMoment_zero_pos hp t))

/-- `(𝔼_{π_t}[r])' = Var_{π_t}(r)`: the aligned expected reward increases at exactly the rate
given by the reward variance. -/
theorem hasDerivAt_tiltMean {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t : ℝ) :
    HasDerivAt (tiltMean r p) (tiltVar r p t) t := by
  have h0 := expMoment_zero_pos (r := r) hp t
  have hd := (hasDerivAt_expMoment 1 r p t).div (hasDerivAt_expMoment 0 r p t) (ne_of_gt h0)
  have heq : (expMoment 2 r p t * expMoment 0 r p t - expMoment 1 r p t * expMoment 1 r p t)
      / (expMoment 0 r p t) ^ 2 = tiltVar r p t := by
    unfold tiltVar tiltMean
    field_simp
  rw [heq] at hd
  exact hd

theorem deriv_logExpMoment {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) :
    deriv (fun t => Real.log (expMoment 0 r p t)) = tiltMean r p := by
  funext t
  exact (hasDerivAt_logExpMoment hp t).deriv

theorem deriv_tiltMean {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) :
    deriv (tiltMean r p) = tiltVar r p := by
  funext t
  exact (hasDerivAt_tiltMean hp t).deriv

/-- **The curvature identity.**  `d²/dt² log Z(t) = Var_{π_t}(r)`. -/
theorem deriv2_logExpMoment_eq_tiltVar {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) :
    deriv^[2] (fun t => Real.log (expMoment 0 r p t)) = tiltVar r p := by
  have h : deriv^[2] (fun t => Real.log (expMoment 0 r p t))
      = deriv (deriv (fun t => Real.log (expMoment 0 r p t))) := by
    simp [Function.iterate_succ]
  rw [h, deriv_logExpMoment hp, deriv_tiltMean hp]

/-! ## 4. Full convexity of the value curve -/

theorem differentiable_logExpMoment {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) :
    Differentiable ℝ (fun t => Real.log (expMoment 0 r p t)) :=
  fun t => (hasDerivAt_logExpMoment hp t).differentiableAt

theorem continuous_logExpMoment {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) :
    Continuous (fun t => Real.log (expMoment 0 r p t)) :=
  (differentiable_logExpMoment hp).continuous

/-- **Log-convexity of the partition function, in full.**  `t ↦ log Z(t)` is convex on all
of `ℝ`; the midpoint inequality `RLHF.expSum_sq_le` is the special case `θ = 1/2`. -/
theorem convexOn_logExpMoment {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) :
    ConvexOn ℝ Set.univ (fun t => Real.log (expMoment 0 r p t)) := by
  refine convexOn_univ_of_deriv2_nonneg (differentiable_logExpMoment hp) ?_ ?_
  · rw [deriv_logExpMoment hp]
    exact fun t => (hasDerivAt_tiltMean hp t).differentiableAt
  · intro t
    rw [deriv2_logExpMoment_eq_tiltVar hp]
    exact tiltVar_nonneg hp t

/-- **Strict log-convexity of the partition function, in full.**  For a non-constant reward
model the value curve is strictly convex in the inverse temperature. -/
theorem strictConvexOn_logExpMoment {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) {y₀ z₀ : Ω}
    (hr : r y₀ ≠ r z₀) :
    StrictConvexOn ℝ Set.univ (fun t => Real.log (expMoment 0 r p t)) := by
  refine strictConvexOn_univ_of_deriv2_pos (continuous_logExpMoment hp) ?_
  intro t
  rw [deriv2_logExpMoment_eq_tiltVar hp]
  exact tiltVar_pos hp hr t

/-- **The annealing inequality for arbitrary mixtures.**  If the inverse KL coefficient
`β⁻¹` is any convex combination of `β₁⁻¹` and `β₂⁻¹`, then the normalized alignment value
`V(β)/β` is dominated by the corresponding combination of endpoint values.  This generalizes
`RLHF.freeEnergy_harmonic_le`, which is the case `θ = 1/2`. -/
theorem freeEnergy_convex_comb {β β₁ β₂ θ : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hβ₁ : 0 < β₁)
    (hβ₂ : 0 < β₂) (hp : IsPosDist p) (hθ₀ : 0 ≤ θ) (hθ₁ : θ ≤ 1)
    (hmean : β⁻¹ = θ * β₁⁻¹ + (1 - θ) * β₂⁻¹) :
    freeEnergy β r p / β ≤ θ * (freeEnergy β₁ r p / β₁) + (1 - θ) * (freeEnergy β₂ r p / β₂) := by
  have hconv := convexOn_logExpMoment (r := r) hp.1
  have hb : (0 : ℝ) ≤ 1 - θ := by linarith
  have hab : θ + (1 - θ) = 1 := by ring
  have hkey := hconv.2 (Set.mem_univ β₁⁻¹) (Set.mem_univ β₂⁻¹) hθ₀ hb hab
  have hnorm : ∀ γ : ℝ, 0 < γ → freeEnergy γ r p / γ = Real.log (expMoment 0 r p γ⁻¹) := by
    intro γ hγ
    unfold freeEnergy
    rw [partition_eq_expMoment, mul_comm, mul_div_assoc, div_self (ne_of_gt hγ), mul_one]
  rw [hnorm β hβ, hnorm β₁ hβ₁, hnorm β₂ hβ₂, hmean]
  simpa [smul_eq_mul] using hkey

/-! ## 5. Monotone alignment and the Popoviciu ceiling on alignment speed -/

theorem tiltWeight_pos {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t : ℝ) (y : Ω) :
    0 < tiltWeight r p t y := by
  have h0 := expMoment_zero_pos (r := r) hp t
  unfold tiltWeight
  have := hp y
  positivity

theorem differentiable_tiltMean {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) :
    Differentiable ℝ (tiltMean r p) :=
  fun t => (hasDerivAt_tiltMean hp t).differentiableAt

/-- **Monotone alignment.**  The expected reward under the aligned policy is monotone in the
inverse KL temperature: lowering the KL coefficient never decreases the achieved reward. -/
theorem tiltMean_monotone {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) : Monotone (tiltMean r p) := by
  refine monotone_of_deriv_nonneg (differentiable_tiltMean hp) (fun t => ?_)
  rw [deriv_tiltMean hp]
  exact tiltVar_nonneg hp t

/-- **Popoviciu ceiling.**  A reward model confined to `[m, M]` has variance at most
`(M − m)²/4` under *every* tilt, uniformly in the temperature and in the size of the
response space. -/
theorem tiltVar_le_range_sq {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) {m M : ℝ}
    (hm : ∀ y, m ≤ r y) (hM : ∀ y, r y ≤ M) (t : ℝ) :
    tiltVar r p t ≤ (M - m) ^ 2 / 4 := by
  set a := (m + M) / 2 with ha
  set mu := tiltMean r p t with hmu
  have hkey : tiltVar r p t = (∑ y, tiltWeight r p t y * (r y - a) ^ 2) - (mu - a) ^ 2 := by
    have h1 : ∀ y, tiltWeight r p t y * (r y - a) ^ 2
        = tiltWeight r p t y * r y ^ 2 - 2 * a * (tiltWeight r p t y * r y ^ 1)
          + a ^ 2 * tiltWeight r p t y := by
      intro y; ring
    rw [Finset.sum_congr rfl (fun y _ => h1 y), Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, tiltWeight_moment 2 r p t, tiltWeight_moment 1 r p t,
      tiltWeight_sum hp t]
    have hmm : mu = expMoment 1 r p t / expMoment 0 r p t := rfl
    unfold tiltVar
    rw [← hmu, hmm]
    ring
  have hbound : ∑ y, tiltWeight r p t y * (r y - a) ^ 2 ≤ (M - m) ^ 2 / 4 := by
    have hle : ∀ y ∈ (univ : Finset Ω),
        tiltWeight r p t y * (r y - a) ^ 2 ≤ tiltWeight r p t y * ((M - m) ^ 2 / 4) := by
      intro y _
      have hsq : (r y - a) ^ 2 ≤ (M - m) ^ 2 / 4 := by
        have h1 := hm y
        have h2 := hM y
        rw [ha]
        nlinarith [sq_nonneg (r y - a)]
      exact mul_le_mul_of_nonneg_left hsq (tiltWeight_pos hp t y).le
    have hsum := Finset.sum_le_sum hle
    rwa [← Finset.sum_mul, tiltWeight_sum hp t, one_mul] at hsum
  nlinarith [sq_nonneg (mu - a)]

/-- **A speed limit for alignment.**  Combining monotonicity with the Popoviciu ceiling: over
an interval of inverse temperatures the aligned expected reward can rise by at most
`(t₂ − t₁)(M − m)²/4`, no matter how large the response space is. -/
theorem tiltMean_drift_le {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) {m M : ℝ}
    (hm : ∀ y, m ≤ r y) (hM : ∀ y, r y ≤ M) {t₁ t₂ : ℝ} (ht : t₁ ≤ t₂) :
    tiltMean r p t₂ - tiltMean r p t₁ ≤ (t₂ - t₁) * ((M - m) ^ 2 / 4) := by
  set C := (M - m) ^ 2 / 4 with hC
  have hderiv : ∀ t : ℝ, HasDerivAt (fun t => C * t - tiltMean r p t)
      (C - tiltVar r p t) t := by
    intro t
    have h1 : HasDerivAt (fun t : ℝ => C * t) C t := by
      simpa using (hasDerivAt_id t).const_mul C
    simpa using h1.sub (hasDerivAt_tiltMean hp t)
  have hmono : Monotone (fun t => C * t - tiltMean r p t) := by
    refine monotone_of_deriv_nonneg (fun t => (hderiv t).differentiableAt) (fun t => ?_)
    rw [(hderiv t).deriv]
    have := tiltVar_le_range_sq hp hm hM t
    linarith
  have := hmono ht
  simp only at this
  nlinarith [this]

omit [Nonempty Ω] in
theorem continuous_expMoment (k : ℕ) (r p : Ω → ℝ) : Continuous (expMoment k r p) := by
  unfold expMoment
  exact continuous_finset_sum _ (fun y _ => by fun_prop)

theorem continuous_tiltVar {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) : Continuous (tiltVar r p) := by
  have h0 : Continuous (expMoment 0 r p) := continuous_expMoment 0 r p
  have hne : ∀ t, expMoment 0 r p t ≠ 0 := fun t => ne_of_gt (expMoment_zero_pos hp t)
  unfold tiltVar tiltMean
  exact ((continuous_expMoment 2 r p).div h0 hne).sub
    (((continuous_expMoment 1 r p).div h0 hne).pow 2)

/-- **The variance-flow identity.**  The alignment gain over a window of inverse temperatures
is exactly the integral of the reward variance: the drift of the aligned expected reward is a
variance budget.  Together with `RLHF.tiltVar_le_range_sq` this refines
`RLHF.tiltMean_drift_le` to an equality. -/
theorem integral_tiltVar {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (t₁ t₂ : ℝ) :
    ∫ t in t₁..t₂, tiltVar r p t = tiltMean r p t₂ - tiltMean r p t₁ :=
  intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hasDerivAt_tiltMean hp x)
    ((continuous_tiltVar hp).intervalIntegrable t₁ t₂)

/-! ## 6. Arithmetic shadow: strict log-convexity of the truncated zeta function -/

/-- `log (∑_{n=1}^{N} n^{-s})`, the logarithm of the truncated Riemann zeta function. -/
noncomputable def truncZetaLog (N : ℕ) (s : ℝ) : ℝ :=
  Real.log (∑ n ∈ Finset.range N, ((n : ℝ) + 1) ^ (-s))

/-- The reward model `n ↦ −log n` on `{1, …, N}`. -/
noncomputable def logReward (N : ℕ) : Fin N → ℝ := fun i => -Real.log ((i : ℕ) + 1)

/-- The uniform reference policy on `{1, …, N}`. -/
noncomputable def unifWeight (N : ℕ) : Fin N → ℝ := fun _ => (N : ℝ)⁻¹

theorem unifWeight_pos {N : ℕ} (hN : 0 < N) : ∀ i : Fin N, 0 < unifWeight N i := by
  intro _
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  unfold unifWeight
  positivity

/-- The uniform reference policy together with the reward `n ↦ −log n` turns the RLHF
partition function into the truncated zeta function. -/
theorem expMoment_zero_logReward (N : ℕ) (s : ℝ) :
    expMoment 0 (logReward N) (unifWeight N) s
      = (N : ℝ)⁻¹ * ∑ n ∈ Finset.range N, ((n : ℝ) + 1) ^ (-s) := by
  unfold expMoment logReward unifWeight
  rw [Finset.mul_sum, Fin.sum_univ_eq_sum_range
    (fun i => (N : ℝ)⁻¹ * (-Real.log ((i : ℕ) + 1)) ^ 0 * Real.exp (-Real.log ((i : ℕ) + 1) * s))]
  refine Finset.sum_congr rfl (fun n _ => ?_)
  have hn : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  rw [Real.rpow_def_of_pos hn]
  ring_nf

/-- Up to the additive constant `log N`, the log-partition function of the uniform
`−log n` model *is* the logarithm of the truncated zeta function. -/
theorem logExpMoment_logReward {N : ℕ} (hN : 0 < N) :
    (fun s => Real.log (expMoment 0 (logReward N) (unifWeight N) s))
      = fun s => truncZetaLog N s + (-Real.log (N : ℝ)) := by
  funext s
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hSpos : (0 : ℝ) < ∑ n ∈ Finset.range N, ((n : ℝ) + 1) ^ (-s) := by
    refine Finset.sum_pos (fun n _ => ?_) ⟨0, Finset.mem_range.mpr hN⟩
    have : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    exact Real.rpow_pos_of_pos this _
  rw [expMoment_zero_logReward, Real.log_mul (by positivity) (ne_of_gt hSpos), Real.log_inv]
  unfold truncZetaLog
  ring

private theorem shift_back (N : ℕ) :
    ((fun s => truncZetaLog N s + (-Real.log (N : ℝ))) + fun _ => Real.log (N : ℝ))
      = truncZetaLog N := by
  funext s
  simp

/-- **The truncated zeta function is log-convex in the exponent.** -/
theorem convexOn_truncZetaLog {N : ℕ} (hN : 0 < N) :
    ConvexOn ℝ Set.univ (truncZetaLog N) := by
  haveI : Nonempty (Fin N) := ⟨⟨0, hN⟩⟩
  have hconv := convexOn_logExpMoment (r := logReward N) (unifWeight_pos hN)
  rw [logExpMoment_logReward hN] at hconv
  rw [← shift_back N]
  exact hconv.add_const _

/-- The reward `n ↦ −log n` is non-constant as soon as `N ≥ 2`. -/
theorem logReward_nonconstant {N : ℕ} (hN : 2 ≤ N) :
    logReward N ⟨0, by omega⟩ ≠ logReward N ⟨1, by omega⟩ := by
  have h0 : logReward N ⟨0, by omega⟩ = 0 := by
    unfold logReward
    norm_num
  have h1 : logReward N ⟨1, by omega⟩ = -Real.log 2 := by
    unfold logReward
    norm_num
  rw [h0, h1]
  have hpos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  intro h
  linarith

/-- **Strict log-convexity of the truncated zeta function** for `N ≥ 2`. -/
theorem strictConvexOn_truncZetaLog {N : ℕ} (hN : 2 ≤ N) :
    StrictConvexOn ℝ Set.univ (truncZetaLog N) := by
  have hN0 : 0 < N := by omega
  haveI : Nonempty (Fin N) := ⟨⟨0, hN0⟩⟩
  have hconv := strictConvexOn_logExpMoment (r := logReward N) (unifWeight_pos hN0)
    (logReward_nonconstant hN)
  rw [logExpMoment_logReward hN0] at hconv
  rw [← shift_back N]
  exact hconv.add_const _

/-- **The curvature of the truncated zeta curve is a variance.**  `d²/ds² log ζ_N(s)` equals
the variance of `log n` under the truncated zeta distribution on `{1, …, N}`. -/
theorem truncZeta_curvature_eq_variance {N : ℕ} (hN : 0 < N) :
    deriv^[2] (fun s => truncZetaLog N s + (-Real.log (N : ℝ)))
      = tiltVar (logReward N) (unifWeight N) := by
  haveI : Nonempty (Fin N) := ⟨⟨0, hN⟩⟩
  rw [← logExpMoment_logReward hN]
  exact deriv2_logExpMoment_eq_tiltVar (unifWeight_pos hN)

end RLHF