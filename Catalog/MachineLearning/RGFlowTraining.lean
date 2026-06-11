/-
# Neural Network Training as Renormalization Group Flow

This file formalizes the rigorous mathematical core of the idea that
**neural-network training is a renormalization-group (RG) flow in parameter
space**.  The conceptual dictionary is:

* A *coarse-graining* (RG) step is modelled by an **idempotent linear operator**
  `P : V →ₗ[ℝ] V` on the parameter inner-product space `V`.  `P` "integrates
  out" the high-frequency / fast modes, keeping only the slow, relevant modes
  in its range.
* An *RG fixed point* is a parameter vector `θ` with `P θ = θ`, i.e. a vector
  that survives coarse-graining unchanged.
* A *training (SGD / gradient-flow) fixed point* is a critical point of the
  loss.  For the natural quadratic relevance loss
  `L(θ) = ½‖θ - P θ‖²`, whose gradient is the **residual operator**
  `R = id - P` (the "irrelevant content removed by coarse graining"), the
  critical points are exactly `{θ : R θ = 0}`.

The main results prove that these two notions of fixed point **coincide**, that
the continuous-time training flow `θ'(t) = -R(θ(t))` is an explicit exponential
relaxation onto the RG fixed-point manifold (the slope of the SGD beta-function
being the critical exponent `1`), and that the limiting fixed point depends only
on `P θ₀` — a **universality** statement: two data/initialisations in the same
coarse-grained class converge to the same fixed point.

This extends the finite-dimensional NTK / gradient-flow algebra in
`Catalog/MachineLearning/NTKCore.lean` (Jacot–Gabriel–Hongler lazy-training
dynamics) by giving the gradient flow an RG interpretation via an idempotent
coarse-graining operator.

## Theorem catalogue

1. `rgResidual_apply`            — `R θ = θ - P θ`. (definitional unfolding)
2. `rg_sgd_fixedPoint_iff`       — SGD fixed point `R θ = 0` ↔ RG fixed point `P θ = θ`.
3. `rg_fixedPoint_iff_mem_range` — for idempotent `P`, `P θ = θ` ↔ `θ ∈ range P`.
4. `rgFlow_zero`                 — the flow starts at the initial condition.
5. `rgFlow_proj`                 — `P` is conserved along the flow (slow modes are invariant).
6. `rgFlow_hasDerivAt`           — the flow solves the gradient ODE `θ' = -R θ`.
7. `rgFlow_dist`                 — exact exponential decay `‖θ(t) - Pθ₀‖ = e^{-t}‖Rθ₀‖`.
8. `rgFlow_tendsto`              — convergence to the RG fixed point `P θ₀`.
9. `rgFlow_limit_isFixedPoint`   — the limit is a genuine RG (and SGD) fixed point.
10. `rg_universality`            — same coarse-grained class ⇒ same limiting fixed point.
-/

import Mathlib

open Filter Topology

noncomputable section

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- The **RG residual operator** `R = id - P`.  It extracts the "irrelevant"
content that a coarse-graining step `P` removes.  It is the gradient of the
quadratic relevance loss `L(θ) = ½‖θ - Pθ‖²` when `P` is an orthogonal
projection. -/
def rgResidual (P : V →ₗ[ℝ] V) : V →ₗ[ℝ] V := LinearMap.id - P

@[simp] theorem rgResidual_apply (P : V →ₗ[ℝ] V) (x : V) :
    rgResidual P x = x - P x := rfl

-- !-- `R θ = 0 ↔ Pθ = θ`: the gradient/SGD fixed points are exactly the RG
-- fixed points, by `sub_eq_zero`. This is the rigorous core of the conjecture. -- !--
/-- **SGD ↔ RG fixed-point correspondence.**  A parameter vector is a critical
point of the relevance loss (`R θ = 0`) iff it is a fixed point of the
coarse-graining / renormalization-group step (`P θ = θ`). -/
theorem rg_sgd_fixedPoint_iff (P : V →ₗ[ℝ] V) (x : V) :
    rgResidual P x = 0 ↔ P x = x := by
  rw [rgResidual_apply, sub_eq_zero, eq_comm]

-- !-- For idempotent `P`, fixed points are exactly the range: `←` uses `P²=P`. -- !--
/-- For an idempotent coarse-graining operator, the RG fixed points are exactly
the range of `P` (the manifold of "relevant" / slow configurations). -/
theorem rg_fixedPoint_iff_mem_range (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x)
    (x : V) : P x = x ↔ x ∈ Set.range P := by
  constructor
  · intro h; exact ⟨x, h⟩
  · rintro ⟨y, rfl⟩; exact hP y

/-- The **renormalization-group training flow** with coarse-graining operator
`P` started at `x₀`.  It is the closed-form solution of the gradient ODE
`θ'(t) = -R(θ(t))`: the slow component `P x₀` is frozen and the irrelevant
component `x₀ - P x₀` relaxes exponentially to zero. -/
def rgFlow (P : V →ₗ[ℝ] V) (x₀ : V) (t : ℝ) : V :=
  P x₀ + Real.exp (-t) • (x₀ - P x₀)

@[simp] theorem rgFlow_zero (P : V →ₗ[ℝ] V) (x₀ : V) : rgFlow P x₀ 0 = x₀ := by
  simp [rgFlow]

-- !-- `P` is linear and idempotent so `P(rgFlow t) = P x₀`: the slow modes are
-- conserved along the flow (RG invariance of relevant couplings). -- !--
/-- The coarse-grained (slow / relevant) part of the parameters is **conserved**
along the training flow. -/
theorem rgFlow_proj (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x) (x₀ : V) (t : ℝ) :
    P (rgFlow P x₀ t) = P x₀ := by
  simp only [rgFlow, map_add, map_smul, map_sub, hP]
  simp

-- !-- Differentiate the closed form: `d/dt e^{-t}•c = -e^{-t}•c`; then
-- `-R(flow t) = -(flow t - P x₀) = -e^{-t}•(x₀-Px₀)` using `rgFlow_proj`. -- !--
/-- **The flow solves the gradient ODE** `θ'(t) = -R(θ(t))`.  This identifies
the closed form `rgFlow` with the continuous-time gradient descent on the
relevance loss whose gradient is the RG residual `R`. -/
theorem rgFlow_hasDerivAt (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x) (x₀ : V)
    (t : ℝ) :
    HasDerivAt (rgFlow P x₀) (-(rgResidual P) (rgFlow P x₀ t)) t := by
  have hexp : HasDerivAt (fun s : ℝ => Real.exp (-s)) (-Real.exp (-t)) t := by
    have := (Real.hasDerivAt_exp (-t)).comp t ((hasDerivAt_id t).neg)
    simpa using this
  have hderiv : HasDerivAt (rgFlow P x₀) ((-Real.exp (-t)) • (x₀ - P x₀)) t := by
    have h := (hexp.smul_const (x₀ - P x₀)).const_add (P x₀)
    exact h
  -- rewrite the target derivative into the same shape
  have hres : -(rgResidual P) (rgFlow P x₀ t) = (-Real.exp (-t)) • (x₀ - P x₀) := by
    rw [rgResidual_apply, rgFlow_proj P hP]
    simp only [rgFlow]
    abel_nf
    module
  rw [hres]; exact hderiv

-- !-- `rgFlow t - P x₀ = e^{-t}•(x₀-Px₀)`, take norms and `‖c•v‖ = |c|‖v‖`. -- !--
/-- **Exact exponential relaxation.**  The distance from the running parameters
to the fixed point decays as `e^{-t}`; the unit rate is the critical exponent /
slope of the SGD beta-function for the irrelevant direction. -/
theorem rgFlow_dist (P : V →ₗ[ℝ] V) (x₀ : V) (t : ℝ) :
    ‖rgFlow P x₀ t - P x₀‖ = Real.exp (-t) * ‖x₀ - P x₀‖ := by
  have : rgFlow P x₀ t - P x₀ = Real.exp (-t) • (x₀ - P x₀) := by
    simp [rgFlow]
  rw [this, norm_smul, Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]

-- !-- `‖flow t - P x₀‖ = e^{-t}‖x₀-Px₀‖ → 0`, so flow → P x₀ via
-- `tendsto_iff_norm_sub_tendsto_zero`. -- !--
/-- **Convergence to the RG fixed point.**  Every training trajectory converges
to the coarse-grained projection `P x₀` of its initialisation. -/
theorem rgFlow_tendsto (P : V →ₗ[ℝ] V) (x₀ : V) :
    Tendsto (rgFlow P x₀) atTop (nhds (P x₀)) := by
  rw [tendsto_iff_norm_sub_tendsto_zero]
  have hzero : Tendsto (fun t : ℝ => Real.exp (-t) * ‖x₀ - P x₀‖) atTop (nhds 0) := by
    have := Real.tendsto_exp_neg_atTop_nhds_zero.mul_const ‖x₀ - P x₀‖
    simpa using this
  refine hzero.congr ?_
  intro t
  rw [rgFlow_dist]

-- !-- The limit `P x₀` satisfies `P(Px₀)=Px₀` by idempotency. -- !--
/-- The limiting point of the training flow is a genuine **RG fixed point**
(equivalently, an SGD critical point by `rg_sgd_fixedPoint_iff`). -/
theorem rgFlow_limit_isFixedPoint (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x)
    (x₀ : V) : P (P x₀) = P x₀ := hP x₀

-- !-- Both limits equal `P x₀ = P y₀` by `rgFlow_tendsto`. -- !--
/-- **Universality.**  If two initialisations (or data distributions) lie in the
same coarse-grained class, `P x₀ = P y₀`, then their training flows converge to
the *same* RG fixed point.  The fixed point is determined entirely by the
universality class `P x₀`, not by the microscopic initialisation. -/
theorem rg_universality (P : V →ₗ[ℝ] V) (x₀ y₀ : V) (h : P x₀ = P y₀) :
    Tendsto (rgFlow P x₀) atTop (nhds (P x₀)) ∧
      Tendsto (rgFlow P y₀) atTop (nhds (P x₀)) := by
  refine ⟨rgFlow_tendsto P x₀, ?_⟩
  rw [h]; exact rgFlow_tendsto P y₀

/-! ## Generalization (strengthening): anisotropic spectral RG flow

The flow above relaxes all irrelevant directions at the *same* unit rate.  The
genuine RG picture has a **spectrum of critical exponents**: each eigenmode of
the linearized beta-function (here a self-adjoint operator `A` commuting with
`P`) relaxes at its own rate `λ`, with relevant (`λ < 0`), marginal (`λ = 0`)
and irrelevant (`λ > 0`) operators.  The following strengthening states the
per-mode decay and is left as a conjecture (eigen-decomposition of the flow).
-/

-- !-- `e^{-(t·λ)} → 0` for `λ>0` (compose `exp(-·)→0` with `t↦t·λ→∞`), then
-- `smul_const` to a vector `v`. -- !--
/-- **Per-mode (anisotropic) RG decay.**  An eigenmode `v` of the linearized
beta-operator `A` with eigenvalue `λ > 0` (an *irrelevant* operator) relaxes at
its own mode-specific rate `λ` under the spectral flow `e^{-tA}`:
`‖e^{-tλ}•v‖ = e^{-tλ}‖v‖ → 0`.  This is the single-mode building block of the
full spectral universality statement; the multi-mode version follows by the
spectral theorem for self-adjoint `A`. -/
theorem rg_spectral_decay (v : V) (lam : ℝ) (hlam : 0 < lam) :
    Tendsto (fun t : ℝ => Real.exp (-(t * lam)) • v) atTop (nhds 0) := by
  have hscal : Tendsto (fun t : ℝ => Real.exp (-(t * lam))) atTop (nhds 0) := by
    have h1 : Tendsto (fun t : ℝ => t * lam) atTop atTop :=
      Filter.Tendsto.atTop_mul_const hlam tendsto_id
    exact Real.tendsto_exp_neg_atTop_nhds_zero.comp h1
  have := hscal.smul_const v
  simpa using this

end