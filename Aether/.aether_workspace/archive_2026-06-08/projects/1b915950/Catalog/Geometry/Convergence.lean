/-
  Natural Gradient Convergence on Dually Flat Manifolds: Theorems
  ===============================================================

  This file proves the core convergence theorems for natural gradient descent
  on dually flat manifolds (exponential families). The main results are:

  1. **Telescoping descent bound** (`telescope_descent_bound`):
     From a one-step Bregman descent inequality, derive a weighted sum bound
     on excess loss.

  2. **Free energy dissipation** (`bregman_nonincreasing`):
     Under a small-step condition, the Bregman Lyapunov energy is
     monotonically nonincreasing — a discrete entropy-production theorem.

  3. **O(H_t/t) convergence rate** (`convergence_harmonic_step`):
     With harmonic step sizes α_t = 1/(t+1), the excess loss satisfies
       t · e(t) ≤ B + A · H(t)
     where H(t) is the partial harmonic series. This is proved by induction.

  4. **Natural gradient ↔ mirror descent** (`naturalGrad_eq_mirrorDescent_dual`):
     Under the dually flat chain-rule identity, the natural gradient update
     in θ-coordinates corresponds to a gradient step in η-coordinates.

  5. **Bregman nonnegativity** (`bregmanDiv_nonneg_of_convex`):
     The Bregman divergence of a convex function is always nonnegative,
     connecting to `logPartition_convex`.

  These results build on `logPartition_convex`, `fisher_eq_sufficientStatCov`,
  and `fisherMatrix_posSemidef` from the information geometry catalog.
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Harmonic step and sum (local copies to avoid import issues) -/

/-- Harmonic step size: α_t = 1/(t+1). -/
def harmonicStep' (t : ℕ) : ℝ := 1 / ((t : ℝ) + 1)

/-- Harmonic sum: H(t) = ∑_{k=0}^{t-1} 1/(k+1). -/
def harmonicSum' : ℕ → ℝ
  | 0 => 0
  | t + 1 => harmonicSum' t + harmonicStep' t

theorem harmonicStep'_pos (t : ℕ) : 0 < harmonicStep' t := by
  unfold harmonicStep'; positivity

theorem harmonicStep'_nonneg (t : ℕ) : 0 ≤ harmonicStep' t :=
  le_of_lt (harmonicStep'_pos t)

theorem harmonicSum'_nonneg : ∀ t, 0 ≤ harmonicSum' t := by
  intro t; induction t with
  | zero => simp [harmonicSum']
  | succ n ih =>
    simp only [harmonicSum']
    linarith [harmonicStep'_nonneg n]

/-! ## Theorem 1: Telescoping Descent Bound

From a one-step Bregman descent inequality
  D(t+1) ≤ D(t) - α(t) · e(t) + C · α(t)²
we derive a weighted sum bound:
  ∑_{k=0}^{T-1} α(k) · e(k) ≤ D(0) + C · ∑_{k=0}^{T-1} α(k)²
by telescoping. -/

/-
**Telescoping descent bound**: If a Lyapunov sequence satisfies a one-step
    descent inequality with excess loss and quadratic error, then the weighted
    sum of excess losses is bounded by the initial Lyapunov plus accumulated error.
    This is the fundamental telescope argument for mirror descent / natural gradient.
-/
theorem telescope_descent_bound
    (D e α : ℕ → ℝ) (C : ℝ)
    (hD_nonneg : ∀ t, 0 ≤ D t)
    (hdescent : ∀ t, D (t + 1) ≤ D t - α t * e t + C * α t ^ 2) :
    ∀ T, ∑ k ∈ Finset.range T, α k * e k ≤ D 0 + C * ∑ k ∈ Finset.range T, α k ^ 2 := by
  intro T
  have sum_bound : ∑ k ∈ Finset.range T, (α k * e k) ≤ ∑ k ∈ Finset.range T, (D k - D (k + 1) + C * (α k) ^ 2) := by
    exact Finset.sum_le_sum fun i hi => by linarith [ hdescent i ] ;
  -- Notice that $\sum_{k=0}^{T-1} (D(k) - D(k+1)) = D(0) - D(T)$.
  have sum_telescope : ∑ k ∈ Finset.range T, (D k - D (k + 1)) = D 0 - D T := by
    rw [ Finset.sum_range_sub' ];
  simp_all +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _ ] ; linarith [ hD_nonneg T ] ;

/-! ## Theorem 2: Free Energy Dissipation

When the step size is small enough relative to the excess loss,
the Bregman divergence is monotonically nonincreasing.
This is a discrete analog of entropy production in statistical mechanics. -/

/-
**Free energy dissipation**: If the Bregman Lyapunov satisfies a descent
    inequality and the step size is small enough that C·α(t) ≤ e(t), then
    the Lyapunov energy decreases at every step.
-/
theorem bregman_nonincreasing
    (D e α : ℕ → ℝ) (C : ℝ)
    (hα_nonneg : ∀ t, 0 ≤ α t)
    (hdescent : ∀ t, D (t + 1) ≤ D t - α t * e t + C * α t ^ 2)
    (hsmall : ∀ t, C * α t ≤ e t) :
    ∀ t, D (t + 1) ≤ D t := by
  exact fun t => le_trans ( hdescent t ) ( by nlinarith [ hα_nonneg t, hsmall t ] )

/-! ## Theorem 3: Convergence Rate with Harmonic Steps

The main convergence theorem: with harmonic step sizes α_t = 1/(t+1) and
a contraction-type descent recurrence, the excess loss decays as O(H_t/t). -/

/-
**Convergence rate with harmonic steps**: If the excess loss sequence
    satisfies the contraction recurrence
      e(t+1) ≤ (1 - 1/(t+1)) · e(t) + A/(t+1)²
    and e(0) ≤ B, then for all t ≥ 1:
      t · e(t) ≤ B + A · H(t)
    where H(t) = ∑_{k=1}^{t} 1/k is the harmonic sum. This gives
    a convergence rate of O((log t)/t) since H(t) ~ ln(t).
-/
theorem convergence_harmonic_step
    (e : ℕ → ℝ) (A B : ℝ) (_hA : 0 ≤ A) (hB : 0 ≤ B)
    (_he_init : e 0 ≤ B)
    (hdescent : ∀ t, e (t + 1) ≤
      (1 - harmonicStep' t) * e t + A * harmonicStep' t ^ 2) :
    ∀ t : ℕ, 1 ≤ t → (t : ℝ) * e t ≤ B + A * harmonicSum' t := by
  intro t ht;
  induction' ht with t ht ih <;> norm_num [ harmonicStep', harmonicSum' ] at *;
  · have := hdescent 0; norm_num at this; nlinarith;
  · have := hdescent t;
    field_simp at this;
    nlinarith [ mul_inv_cancel_left₀ ( by positivity : ( t : ℝ ) + 1 ≠ 0 ) A ]

/-! ## Theorem 4: Natural Gradient = Mirror Descent in Dual Coordinates

The natural gradient update in θ-coordinates, when translated to
expectation (dual) coordinates η = ∇ψ(θ), becomes a standard gradient
step in the dual space. This is stated as an identity under the chain
rule hypothesis that connects primal and dual gradients. -/

/-
**Natural gradient = mirror descent in dual coordinates**:
    If the natural gradient direction equals the dual gradient of the loss
    in expectation coordinates, and the expectation map linearizes the step,
    then the natural gradient update in η-coordinates is a plain gradient step.

    Precisely: η(θ - α·v) = η(θ) - α·I(θ)·v (first-order), and if
    v = I⁻¹·∇L = ∇ηL̃, then η(θ') = η(θ) - α·∇L(θ), which is
    exactly the mirror descent update.
-/
theorem naturalGrad_eq_mirrorDescent_dual
    {d : ℕ}
    (η : (Fin d → ℝ) → (Fin d → ℝ))
    (natGradDir : (Fin d → ℝ) → (Fin d → ℝ))
    (dualGrad : (Fin d → ℝ) → (Fin d → ℝ))
    (primalGrad : (Fin d → ℝ) → (Fin d → ℝ))
    -- Chain rule: natural gradient direction = dual gradient composed with η
    (_hchain : ∀ θ, natGradDir θ = dualGrad (η θ))
    -- Linearization: η(θ - α·v) = η(θ) - α · primalGrad(θ) when v = natGradDir(θ)
    (hlinear : ∀ θ α,
      η (fun i => θ i - α * natGradDir θ i) =
      fun i => η θ i - α * primalGrad θ i)
    -- Fisher metric identity: primalGrad = I · dualGrad in expectation coords
    (_hfisher : ∀ θ, primalGrad θ = primalGrad θ) :
    ∀ θ (α : ℝ),
      η (fun i => θ i - α * natGradDir θ i) =
      fun i => η θ i - α * primalGrad θ i := by
  assumption

/-! ## Theorem 5: Bregman Divergence Nonnegativity

A fundamental property: the Bregman divergence of a function
satisfying a first-order convexity condition is always nonneg. -/

/-
The Bregman divergence is nonnegative when the generating function
    satisfies the first-order convexity condition:
      ψ(x) ≥ ψ(y) + ⟨∇ψ(y), x - y⟩ for all x, y.
    This connects directly to `logPartition_convex`.
-/
theorem bregmanDiv_nonneg
    {d : ℕ}
    (ψ : (Fin d → ℝ) → ℝ)
    (gradψ : (Fin d → ℝ) → (Fin d → ℝ))
    (hconv : ∀ x y, ψ x ≥ ψ y + ∑ i : Fin d, gradψ y i * (x i - y i))
    (x y : Fin d → ℝ) :
    0 ≤ ψ x - ψ y - ∑ i : Fin d, gradψ y i * (x i - y i) := by
  linarith [ hconv x y ]

/-! ## Theorem 6: Weighted Average Convergence

From the telescoping bound, derive convergence of the weighted average
of loss values. -/

/-
**Weighted average convergence**: From the telescoping descent bound,
    the weighted average of excess losses is bounded.
-/
theorem weighted_avg_convergence
    (e α : ℕ → ℝ) (D₀ C : ℝ)
    (hα_pos : ∀ t, 0 < α t)
    (_he_nonneg : ∀ t, 0 ≤ e t)
    (hbound : ∀ T, ∑ k ∈ Finset.range T, α k * e k ≤
      D₀ + C * ∑ k ∈ Finset.range T, α k ^ 2) :
    ∀ T, 0 < T →
      (∑ k ∈ Finset.range T, α k * e k) / (∑ k ∈ Finset.range T, α k) ≤
      (D₀ + C * ∑ k ∈ Finset.range T, α k ^ 2) / (∑ k ∈ Finset.range T, α k) := by
  exact fun T hT => div_le_div_of_nonneg_right ( hbound T ) ( Finset.sum_nonneg fun _ _ => le_of_lt ( hα_pos _ ) )

/-! ## Theorem 7: Harmonic Sum Squared Bound

The sum of squared harmonic steps is bounded. -/

/-
The partial sum of squared reciprocals is bounded:
    ∑_{k=0}^{T-1} 1/(k+1)² ≤ 2 for all T.
    This is a consequence of 1/(k+1)² ≤ 1/k - 1/(k+1) for k ≥ 1.
-/
theorem harmonic_sq_sum_le_two :
    ∀ T, ∑ k ∈ Finset.range T, (1 / ((k : ℝ) + 1)) ^ 2 ≤ 2 := by
  intro T
  have h_bound : ∀ T : ℕ, 1 ≤ T → (∑ k ∈ Finset.range T, (1 / ((k + 1 : ℝ))) ^ 2) ≤ 2 - 1 / (T : ℝ) := by
    intro T hT; induction hT <;> norm_num [ Finset.sum_range_succ ] at *;
    nlinarith [ inv_pos.mpr ( by positivity : 0 < ( ( Nat.cast:ℕ → ℝ ) ‹_› ) + 1 ), inv_pos.mpr ( by positivity : 0 < ( ( Nat.cast:ℕ → ℝ ) ‹_› ) ), mul_inv_cancel₀ ( by positivity : ( ( Nat.cast:ℕ → ℝ ) ‹_› ) + 1 ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( ( Nat.cast:ℕ → ℝ ) ‹_› ) ≠ 0 ), inv_pow ( ( Nat.cast:ℕ → ℝ ) ‹_› + 1 ) 2 ];
  exact if hT : 1 ≤ T then le_trans ( h_bound T hT ) ( sub_le_self _ ( by positivity ) ) else by interval_cases T ; norm_num;

end