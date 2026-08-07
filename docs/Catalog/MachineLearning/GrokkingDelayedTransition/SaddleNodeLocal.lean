import Mathlib

/-!
# Local saddle-node bifurcation theory for the grokking normal form

The catalog file `Catalog/MachineLearning/GrokkingPhaseTransition.lean` pairs a
delayed ReLU transition with the *algebraic* equilibrium structure of the
saddle-node normal form `μ - x²` (no equilibria / one / two).  This file supplies
the missing *analytic* layer, i.e. Future Direction 4 (local dynamical
bifurcation theory), Direction 5 (robustness) and Direction 6 (the connection to
a reduced loss landscape):

* `snField_hasDerivAt_state`, `snField_hasDerivAt_param`, `snField_secondDeriv`:
  the derivatives of the normal form;
* `saddleNode_nondegenerate`: the three classical saddle-node nondegeneracy
  conditions at the critical point `(μ, x) = (0, 0)`;
* `snField_deriv_stable_branch` / `snField_deriv_unstable_branch`: exchange of
  linear stability between the two branches;
* `lyapunov_decreasing_stable_branch` / `lyapunov_increasing_unstable_branch`:
  the *nonlinear* statement — along any solution of `x' = μ - x²` the squared
  distance to `√μ` strictly decreases, and the squared distance to `-√μ`
  strictly increases;
* `perturbed_two_equilibria`, `perturbed_zero_near_branch`,
  `perturbed_no_equilibrium`: the whole bifurcation diagram is robust: any
  continuous field uniformly `ε`-close to `μ - x²` still has two zeros for
  `μ > ε` (each within `O(ε)` of a branch) and none for `μ < -ε`;
* `reducedLoss_negGradient`, `reducedLoss_isLocalMin_stable_branch`,
  `reducedLoss_isLocalMax_unstable_branch`: the normal form is the negative
  gradient of the cubic reduced loss `x³/3 - μ x`, whose local minimum is the
  stable branch and whose local maximum is the unstable branch.
-/

namespace GrokkingBifurcation

open Real Set

/-! ### The normal form and its derivatives -/

/-- The one-dimensional saddle-node vector field `x ↦ μ - x²`. -/
def snField (mu x : ℝ) : ℝ := mu - x ^ 2

/-- Derivative of the normal form in the state variable. -/
theorem snField_hasDerivAt_state (mu x : ℝ) :
    HasDerivAt (snField mu) (-(2 * x)) x := by
  have h : HasDerivAt (fun y : ℝ => mu - y ^ 2) (0 - 2 * x ^ 1) x := by
    simpa using (hasDerivAt_const x mu).sub ((hasDerivAt_id x).pow 2)
  simpa [snField, mul_comm] using h

/-- Derivative of the normal form in the bifurcation parameter. -/
theorem snField_hasDerivAt_param (mu x : ℝ) :
    HasDerivAt (fun m => snField m x) 1 mu := by
  simpa [snField] using (hasDerivAt_id mu).sub_const (x ^ 2)

/-- The state-derivative of the normal form, in closed form. -/
theorem snField_deriv_state (mu x : ℝ) : deriv (snField mu) x = -(2 * x) :=
  (snField_hasDerivAt_state mu x).deriv

/-- The second state-derivative of the normal form is the nonzero constant `-2`. -/
theorem snField_secondDeriv (mu x : ℝ) : deriv (deriv (snField mu)) x = -2 := by
  have h : deriv (snField mu) = fun y : ℝ => -(2 * y) := funext (snField_deriv_state mu)
  rw [h]
  have : HasDerivAt (fun y : ℝ => -(2 * y)) (-(2 * 1)) x := by
    simpa using ((hasDerivAt_id x).const_mul (2 : ℝ)).neg
  simpa using this.deriv

/-- **Saddle-node nondegeneracy.**  At the critical pair `(μ, x) = (0, 0)` the
field vanishes together with its state-derivative, while the second
state-derivative and the parameter-derivative are both nonzero.  These are
exactly the hypotheses of the classical saddle-node bifurcation theorem. -/
theorem saddleNode_nondegenerate :
    snField 0 0 = 0 ∧
      deriv (snField 0) 0 = 0 ∧
      deriv (deriv (snField 0)) 0 ≠ 0 ∧
      HasDerivAt (fun m => snField m 0) 1 0 ∧ (1 : ℝ) ≠ 0 := by
  refine ⟨by norm_num [snField], by simp [snField_deriv_state], ?_, ?_, one_ne_zero⟩
  · rw [snField_secondDeriv]; norm_num
  · simpa using snField_hasDerivAt_param 0 0

/-! ### The two branches and exchange of stability -/

/-- For `μ > 0` the two equilibrium branches are exactly `±√μ`. -/
theorem snField_eq_zero_iff (mu x : ℝ) (hmu : 0 < mu) :
    snField mu x = 0 ↔ x = Real.sqrt mu ∨ x = -Real.sqrt mu := by
  have hsq : Real.sqrt mu ^ 2 = mu := Real.sq_sqrt hmu.le
  constructor
  · intro h
    have hfac : (x - Real.sqrt mu) * (x + Real.sqrt mu) = 0 := by
      simp only [snField] at h; nlinarith
    rcases mul_eq_zero.mp hfac with h₁ | h₂
    · exact Or.inl (by linarith)
    · exact Or.inr (by linarith)
  · rintro (rfl | rfl) <;> simp only [snField] <;> nlinarith

/-- The upper branch is linearly **stable**: the linearization is negative. -/
theorem snField_deriv_stable_branch (mu : ℝ) (hmu : 0 < mu) :
    deriv (snField mu) (Real.sqrt mu) < 0 := by
  rw [snField_deriv_state]
  have : 0 < Real.sqrt mu := Real.sqrt_pos.mpr hmu
  linarith

/-- The lower branch is linearly **unstable**: the linearization is positive. -/
theorem snField_deriv_unstable_branch (mu : ℝ) (hmu : 0 < mu) :
    0 < deriv (snField mu) (-Real.sqrt mu) := by
  rw [snField_deriv_state]
  have : 0 < Real.sqrt mu := Real.sqrt_pos.mpr hmu
  linarith

/-- At the critical parameter the single equilibrium is linearly degenerate:
stability is decided by the nonlinear term, not by the linearization. -/
theorem snField_deriv_critical_degenerate : deriv (snField 0) 0 = 0 := by
  simp [snField_deriv_state]

/-! ### Nonlinear (Lyapunov) stability along solutions -/

/-- Along any solution of `x' = μ - x²`, the squared distance to the upper
branch `√μ` has derivative `2 (x-√μ) (μ - x²)`; when `μ > 0` this equals
`-2 (x-√μ)² (x+√μ)`. -/
theorem lyapunov_stable_hasDerivAt (mu : ℝ) (x : ℝ → ℝ) (t : ℝ)
    (hx : HasDerivAt x (snField mu (x t)) t) :
    HasDerivAt (fun s => (x s - Real.sqrt mu) ^ 2)
      (2 * (x t - Real.sqrt mu) * snField mu (x t)) t := by
  simpa using (hx.sub_const (Real.sqrt mu)).pow 2

/-- **Nonlinear stability of the upper branch.**  For any solution of
`x' = μ - x²` strictly above the unstable branch `-√μ` and not sitting on the
stable branch, the squared distance to `√μ` is strictly decreasing. -/
theorem lyapunov_decreasing_stable_branch (mu : ℝ) (hmu : 0 < mu) (x : ℝ → ℝ) (t : ℝ)
    (hx : HasDerivAt x (snField mu (x t)) t)
    (hgt : -Real.sqrt mu < x t) (hne : x t ≠ Real.sqrt mu) :
    deriv (fun s => (x s - Real.sqrt mu) ^ 2) t < 0 := by
  have hsq : Real.sqrt mu ^ 2 = mu := Real.sq_sqrt hmu.le
  rw [(lyapunov_stable_hasDerivAt mu x t hx).deriv]
  have h1 : 0 < (x t - Real.sqrt mu) ^ 2 := by
    have h : x t - Real.sqrt mu ≠ 0 := sub_ne_zero.mpr hne
    positivity
  have h2 : 0 < x t + Real.sqrt mu := by linarith
  have hkey : 2 * (x t - Real.sqrt mu) * snField mu (x t)
      = -(2 * (x t - Real.sqrt mu) ^ 2 * (x t + Real.sqrt mu)) := by
    simp only [snField]; linear_combination (-(2 * (x t - Real.sqrt mu))) * hsq
  rw [hkey]
  nlinarith

/-- **Nonlinear instability of the lower branch.**  For any solution of
`x' = μ - x²` strictly below the stable branch `√μ` and not sitting on the
unstable branch, the squared distance to `-√μ` is strictly increasing. -/
theorem lyapunov_increasing_unstable_branch (mu : ℝ) (hmu : 0 < mu) (x : ℝ → ℝ) (t : ℝ)
    (hx : HasDerivAt x (snField mu (x t)) t)
    (hlt : x t < Real.sqrt mu) (hne : x t ≠ -Real.sqrt mu) :
    0 < deriv (fun s => (x s + Real.sqrt mu) ^ 2) t := by
  have hsq : Real.sqrt mu ^ 2 = mu := Real.sq_sqrt hmu.le
  have hderiv : HasDerivAt (fun s => (x s + Real.sqrt mu) ^ 2)
      (2 * (x t + Real.sqrt mu) * snField mu (x t)) t := by
    simpa using (hx.add_const (Real.sqrt mu)).pow 2
  rw [hderiv.deriv,
    show 2 * (x t + Real.sqrt mu) * snField mu (x t)
        = -(2 * (x t + Real.sqrt mu) ^ 2 * (x t - Real.sqrt mu)) by
      simp only [snField]; linear_combination (-(2 * (x t + Real.sqrt mu))) * hsq]
  have h1 : 0 < (x t + Real.sqrt mu) ^ 2 := by
    have h : x t + Real.sqrt mu ≠ 0 := by
      intro h; exact hne (by linarith)
    positivity
  nlinarith

/-! ### Robustness of the bifurcation diagram -/

/-- **Persistence of the two branches.**  Any continuous field uniformly
`ε`-close to `μ - x²` with `0 < ε < μ` still has (at least) two equilibria, one
strictly negative and one strictly positive. -/
theorem perturbed_two_equilibria (mu eps : ℝ) (heps : 0 < eps) (hlt : eps < mu)
    (g : ℝ → ℝ) (hg : Continuous g) (hclose : ∀ x, |g x - snField mu x| ≤ eps) :
    ∃ x₁ x₂ : ℝ, x₁ < 0 ∧ 0 < x₂ ∧ g x₁ = 0 ∧ g x₂ = 0 := by
  have hmu : 0 < mu := heps.trans hlt
  set b : ℝ := Real.sqrt (mu + 2 * eps) with hb
  have hbpos : 0 < b := Real.sqrt_pos.mpr (by linarith)
  have hbsq : b ^ 2 = mu + 2 * eps := Real.sq_sqrt (by linarith)
  have hzero : 0 < g 0 := by
    have h := abs_le.mp (hclose 0)
    simp only [snField] at h
    linarith [h.1]
  have hpos : g b < 0 := by
    have h := abs_le.mp (hclose b)
    simp only [snField] at h
    have h2 := h.2
    rw [hbsq] at h2
    linarith
  have hneg : g (-b) < 0 := by
    have h := abs_le.mp (hclose (-b))
    simp only [snField] at h
    have h2 := h.2
    rw [show (-b) ^ 2 = b ^ 2 by ring, hbsq] at h2
    linarith
  obtain ⟨x₂, hx₂mem, hx₂⟩ : (0 : ℝ) ∈ g '' (Ioo 0 b) :=
    intermediate_value_Ioo' (le_of_lt hbpos) hg.continuousOn ⟨hpos, hzero⟩
  obtain ⟨x₁, hx₁mem, hx₁⟩ : (0 : ℝ) ∈ g '' (Ioo (-b) 0) :=
    intermediate_value_Ioo (by linarith : (-b : ℝ) ≤ 0) hg.continuousOn ⟨hneg, hzero⟩
  exact ⟨x₁, x₂, hx₁mem.2, hx₂mem.1, hx₁, hx₂⟩

/-- Every equilibrium of an `ε`-perturbation lies close to one of the two exact
branches: its square differs from `μ` by at most `ε`. -/
theorem perturbed_zero_near_branch (mu eps : ℝ) (g : ℝ → ℝ)
    (hclose : ∀ x, |g x - snField mu x| ≤ eps) {x : ℝ} (hx : g x = 0) :
    |x ^ 2 - mu| ≤ eps := by
  have h := hclose x
  rw [hx] at h
  simpa [snField, abs_sub_comm] using h

/-- **Persistence of the empty (subcritical) phase.**  For `μ < -ε` an
`ε`-perturbation of the normal form still has no equilibrium at all. -/
theorem perturbed_no_equilibrium (mu eps : ℝ) (hmu : mu < -eps) (g : ℝ → ℝ)
    (hclose : ∀ x, |g x - snField mu x| ≤ eps) (x : ℝ) : g x ≠ 0 := by
  intro hx
  have h := abs_le.mp (hclose x)
  rw [hx] at h
  have h2 := h.2
  simp only [snField] at h2
  nlinarith [sq_nonneg x]

/-! ### The reduced loss landscape (connection to an energy) -/

/-- The reduced (cubic) loss landscape whose negative gradient is the
saddle-node normal form. -/
noncomputable def reducedLoss (mu x : ℝ) : ℝ := x ^ 3 / 3 - mu * x

/-- **The normal form is a gradient flow.**  `μ - x²` is the negative gradient
of the reduced loss `x³/3 - μ x`. -/
theorem reducedLoss_negGradient (mu x : ℝ) :
    HasDerivAt (reducedLoss mu) (-(snField mu x)) x := by
  have h : HasDerivAt (fun y : ℝ => y ^ 3 / 3 - mu * y) ((3 * x ^ 2) / 3 - mu * 1) x := by
    have h1 : HasDerivAt (fun y : ℝ => y ^ 3) (3 * x ^ 2) x := by
      simpa using (hasDerivAt_id x).pow 3
    have h2 : HasDerivAt (fun y : ℝ => mu * y) (mu * 1) x := (hasDerivAt_id x).const_mul mu
    exact (h1.div_const 3).sub h2
  have heq : (3 * x ^ 2) / 3 - mu * 1 = -(snField mu x) := by simp only [snField]; ring
  rw [← heq]
  simpa [reducedLoss] using h

/-- Critical points of the reduced loss are exactly the equilibria of the flow. -/
theorem reducedLoss_critical_iff_equilibrium (mu x : ℝ) :
    deriv (reducedLoss mu) x = 0 ↔ snField mu x = 0 := by
  rw [(reducedLoss_negGradient mu x).deriv]
  constructor <;> intro h <;> linarith

/-- Exact cubic factorization of the loss increment around the upper branch. -/
theorem reducedLoss_sub_stable (mu x : ℝ) (hmu : 0 < mu) :
    reducedLoss mu x - reducedLoss mu (Real.sqrt mu)
      = (x - Real.sqrt mu) ^ 2 * (x + 2 * Real.sqrt mu) / 3 := by
  have hsq : Real.sqrt mu ^ 2 = mu := Real.sq_sqrt hmu.le
  simp only [reducedLoss]
  linear_combination (x - Real.sqrt mu) * hsq

/-- **The stable branch is a local minimum of the reduced loss.** -/
theorem reducedLoss_isLocalMin_stable_branch (mu : ℝ) (hmu : 0 < mu) :
    IsLocalMin (reducedLoss mu) (Real.sqrt mu) := by
  have hpos : 0 < Real.sqrt mu := Real.sqrt_pos.mpr hmu
  have hmem : Ioi (-(2 * Real.sqrt mu)) ∈ nhds (Real.sqrt mu) :=
    Ioi_mem_nhds (by linarith)
  filter_upwards [hmem] with x hx
  have hfac := reducedLoss_sub_stable mu x hmu
  have h1 : 0 ≤ (x - Real.sqrt mu) ^ 2 := sq_nonneg _
  have h2 : 0 ≤ x + 2 * Real.sqrt mu := by
    simp only [mem_Ioi] at hx; linarith
  nlinarith

/-- **The unstable branch is a local maximum of the reduced loss.** -/
theorem reducedLoss_isLocalMax_unstable_branch (mu : ℝ) (hmu : 0 < mu) :
    IsLocalMax (reducedLoss mu) (-Real.sqrt mu) := by
  have hpos : 0 < Real.sqrt mu := Real.sqrt_pos.mpr hmu
  have hsq : Real.sqrt mu ^ 2 = mu := Real.sq_sqrt hmu.le
  have hmem : Iio (2 * Real.sqrt mu) ∈ nhds (-Real.sqrt mu) :=
    Iio_mem_nhds (by linarith)
  filter_upwards [hmem] with x hx
  simp only [mem_Iio] at hx
  have hfac : reducedLoss mu x - reducedLoss mu (-Real.sqrt mu)
      = (x + Real.sqrt mu) ^ 2 * (x - 2 * Real.sqrt mu) / 3 := by
    simp only [reducedLoss]; linear_combination (x + Real.sqrt mu) * hsq
  nlinarith [sq_nonneg (x + Real.sqrt mu)]

/-- **Exchange of stability, energetic form.**  For `μ > 0` the two equilibria
are a local minimum and a local maximum of the same reduced loss, with opposite
linear stability, while for `μ < 0` the loss has no critical point at all. -/
theorem exchange_of_stability (mu : ℝ) :
    (0 < mu →
        IsLocalMin (reducedLoss mu) (Real.sqrt mu) ∧
        IsLocalMax (reducedLoss mu) (-Real.sqrt mu) ∧
        deriv (snField mu) (Real.sqrt mu) < 0 ∧
        0 < deriv (snField mu) (-Real.sqrt mu)) ∧
      (mu < 0 → ∀ x : ℝ, deriv (reducedLoss mu) x ≠ 0) := by
  constructor
  · intro hmu
    exact ⟨reducedLoss_isLocalMin_stable_branch mu hmu,
      reducedLoss_isLocalMax_unstable_branch mu hmu,
      snField_deriv_stable_branch mu hmu, snField_deriv_unstable_branch mu hmu⟩
  · intro hmu x hx
    rw [reducedLoss_critical_iff_equilibrium] at hx
    simp only [snField] at hx
    nlinarith [sq_nonneg x]


/-! ### The bottleneck delay: inverse-square-root scaling below the bifurcation

Third research cycle.  Just *below* the saddle-node (`μ < 0`) there is no
equilibrium, but the flow is slowed down dramatically near the ghost of the
vanished pair.  The Riccati equation `x' = μ - x²` has the explicit solution
`x(t) = -k tan(k t)` with `k = √(-μ)`, and the time needed to pass from `+A`
down to `-A` is `2 arctan(A/k)/k ≥ π/(2k) = (π/2)|μ|^{-1/2}`.  So the delay
diverges with exponent `1/2` in the bifurcation parameter — a different law
from the logarithmic divergence produced by weight decay in
`GradientFlowThreshold.lean`.
-/

/-- Explicit solution of `x' = μ - x²` for `μ = -k² < 0`. -/
noncomputable def snBottleneck (k t : ℝ) : ℝ := -k * Real.tan (k * t)

theorem tan_sq_add_one {x : ℝ} (h : Real.cos x ≠ 0) :
    Real.tan x ^ 2 + 1 = 1 / Real.cos x ^ 2 := by
  rw [Real.tan_eq_sin_div_cos]
  field_simp
  nlinarith [Real.sin_sq_add_cos_sq x]

/-- The tangent profile really solves the normal form with negative parameter. -/
theorem snBottleneck_hasDerivAt (k t : ℝ) (hcos : Real.cos (k * t) ≠ 0) :
    HasDerivAt (snBottleneck k) (snField (-(k ^ 2)) (snBottleneck k t)) t := by
  have h1 : HasDerivAt (fun u : ℝ => k * u) k t := by
    simpa using (hasDerivAt_id t).const_mul k
  have htan : HasDerivAt (fun u : ℝ => Real.tan (k * u))
      ((1 / Real.cos (k * t) ^ 2) * k) t := (Real.hasDerivAt_tan hcos).comp t h1
  have h := htan.const_mul (-k)
  convert h using 1
  simp only [snField, snBottleneck]
  rw [← tan_sq_add_one hcos]
  ring

/-- Starting value of the bottleneck passage. -/
theorem snBottleneck_start (k A : ℝ) (hk : 0 < k) :
    snBottleneck k (-(Real.arctan (A / k) / k)) = A := by
  simp only [snBottleneck]
  rw [show k * -(Real.arctan (A / k) / k) = -Real.arctan (A / k) by field_simp]
  rw [Real.tan_neg, Real.tan_arctan]
  field_simp

/-- End value of the bottleneck passage. -/
theorem snBottleneck_end (k A : ℝ) (hk : 0 < k) :
    snBottleneck k (Real.arctan (A / k) / k) = -A := by
  simp only [snBottleneck]
  rw [show k * (Real.arctan (A / k) / k) = Real.arctan (A / k) by field_simp]
  rw [Real.tan_arctan]
  field_simp

/-- The time the solution spends crossing the bottleneck from `+A` to `-A`. -/
noncomputable def passageTime (k A : ℝ) : ℝ := 2 * Real.arctan (A / k) / k

/-- **Inverse-square-root bottleneck bound.**  Whenever the observation level `A`
is at least `k = √(-μ)`, the passage time is at least `π/(2k)`. -/
theorem passageTime_lower_bound (k A : ℝ) (hk : 0 < k) (hkA : k ≤ A) :
    Real.pi / (2 * k) ≤ passageTime k A := by
  have h1 : (1 : ℝ) ≤ A / k := (one_le_div hk).mpr hkA
  have h2 : Real.pi / 4 ≤ Real.arctan (A / k) := by
    have := Real.arctan_mono h1
    rwa [Real.arctan_one] at this
  simp only [passageTime]
  rw [div_le_div_iff₀ (by positivity) hk]
  nlinarith [Real.pi_pos]

/-- **The bottleneck delay diverges as the parameter approaches the
bifurcation.**  For any target time `T` there is a subcritical parameter whose
passage time exceeds `T`. -/
theorem passageTime_diverges (A : ℝ) (hA : 0 < A) (T : ℝ) :
    ∃ k : ℝ, 0 < k ∧ k ≤ A ∧ T < passageTime k A := by
  have hpi := Real.pi_pos
  set k : ℝ := min A (Real.pi / (2 * (|T| + 1))) with hk
  have hTpos : 0 < |T| + 1 := by positivity
  have hkpos : 0 < k := lt_min hA (by positivity)
  have hkA : k ≤ A := min_le_left _ _
  refine ⟨k, hkpos, hkA, lt_of_lt_of_le ?_ (passageTime_lower_bound k A hkpos hkA)⟩
  have hk2 : k ≤ Real.pi / (2 * (|T| + 1)) := min_le_right _ _
  have hle : |T| + 1 ≤ Real.pi / (2 * k) := by
    rw [le_div_iff₀ (by positivity)]
    rw [le_div_iff₀ (by positivity)] at hk2
    nlinarith
  have := le_abs_self T
  linarith

/-- **Bottleneck scaling law in the bifurcation parameter.**  For `μ < 0` the
tangent profile solves `x' = μ - x²`, and the time it needs to fall from `+A`
to `-A` is at least `(π/2)·|μ|^{-1/2}`. -/
theorem bottleneck_delay_inverse_sqrt (mu A : ℝ) (hmu : mu < 0)
    (hA : Real.sqrt (-mu) ≤ A) :
    (∀ t : ℝ, Real.cos (Real.sqrt (-mu) * t) ≠ 0 →
        HasDerivAt (snBottleneck (Real.sqrt (-mu)))
          (snField mu (snBottleneck (Real.sqrt (-mu)) t)) t) ∧
      snBottleneck (Real.sqrt (-mu))
          (-(Real.arctan (A / Real.sqrt (-mu)) / Real.sqrt (-mu))) = A ∧
      snBottleneck (Real.sqrt (-mu))
          (Real.arctan (A / Real.sqrt (-mu)) / Real.sqrt (-mu)) = -A ∧
      Real.pi / (2 * Real.sqrt (-mu)) ≤ passageTime (Real.sqrt (-mu)) A := by
  have hpos : 0 < Real.sqrt (-mu) := Real.sqrt_pos.mpr (by linarith)
  have hsq : -(Real.sqrt (-mu) ^ 2) = mu := by
    rw [Real.sq_sqrt (by linarith : (0 : ℝ) ≤ -mu)]; ring
  refine ⟨fun t hcos => ?_, snBottleneck_start _ A hpos, snBottleneck_end _ A hpos,
    passageTime_lower_bound _ A hpos hA⟩
  have h := snBottleneck_hasDerivAt (Real.sqrt (-mu)) t hcos
  rwa [hsq] at h

end GrokkingBifurcation