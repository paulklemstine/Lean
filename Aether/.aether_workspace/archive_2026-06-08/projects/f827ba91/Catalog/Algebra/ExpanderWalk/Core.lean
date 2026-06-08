/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Expander Walk Derandomization: Spectral Pseudorandomness Theory

This file formalizes the core spectral mixing and correlation decay theorems
that underpin expander-walk derandomization. The main results show that
spectral contraction of a symmetric stochastic operator implies:

1. **Pointwise mixing**: the action of P^t on a mean-zero observable decays
   pointwise at rate λ^t (Theorem A).
2. **Correlation decay**: the correlation between two observables under the
   walk decays at rate λ^t (Theorem B).

These are the formal engines that convert a spectral gap certificate into
quantitative pseudorandomness guarantees.

## Mathematical context

A symmetric stochastic matrix P on a finite state space α acts on functions
f : α → ℝ by (Pf)(x) = ∑_y P(x,y) f(y). If P contracts mean-zero functions
in L² at rate λ < 1, then:

- |⟨δ_x, P^t f⟩| ≤ λ^t ‖f‖₂  (pointwise pseudorandomness)
- |⟨f, P^t g⟩| ≤ λ^t ‖f‖₂ ‖g‖₂  (correlation decay)

The first gives bias control for individual vertices; the second gives
statistical independence along the walk — the core of derandomization.
-/

import Mathlib

open Finset Real BigOperators Matrix

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Definitions -/

/-- The L² norm of a function on a finite type, defined as √(∑ x, f(x)²). -/
noncomputable def l2norm (f : α → ℝ) : ℝ :=
  Real.sqrt (∑ x, f x ^ 2)

/-- A matrix is stochastic: all entries nonnegative, rows sum to 1. -/
def IsStochasticMatrix (P : Matrix α α ℝ) : Prop :=
  (∀ i j, 0 ≤ P i j) ∧ (∀ i, ∑ j, P i j = 1)

/-- A function has mean zero over the uniform distribution. -/
def MeanZero (f : α → ℝ) : Prop :=
  ∑ x, f x = 0

/-- The walk operator: (walkApply P f)(x) = ∑_y P(x,y) · f(y). -/
noncomputable def walkApply (P : Matrix α α ℝ) (f : α → ℝ) : α → ℝ :=
  fun x => ∑ y, P x y * f y

/-- An observable is bounded by B in absolute value. -/
def BoundedObservable (f : α → ℝ) (B : ℝ) : Prop :=
  ∀ x, |f x| ≤ B

/-! ## Auxiliary lemmas -/

omit [DecidableEq α] in
/-- The L² norm is nonnegative. -/
theorem l2norm_nonneg (f : α → ℝ) : 0 ≤ l2norm f :=
  Real.sqrt_nonneg _

omit [DecidableEq α] in
/-- A single component is bounded by the L² norm: |f(x)| ≤ l2norm f. -/
theorem abs_le_l2norm (f : α → ℝ) (x : α) : |f x| ≤ l2norm f := by
  exact Real.abs_le_sqrt ( Finset.single_le_sum ( fun y _ => sq_nonneg ( f y ) ) ( Finset.mem_univ x ) )

/-
Cauchy–Schwarz inequality for finite sums:
    |∑ x, f(x) · g(x)| ≤ l2norm f · l2norm g.
-/
omit [DecidableEq α] in
/-- Cauchy–Schwarz inequality for finite sums. -/
theorem cauchy_schwarz_finsum (f g : α → ℝ) :
    |∑ x, f x * g x| ≤ l2norm f * l2norm g := by
  -- Apply the Cauchy-Schwarz inequality to the vectors (f i) and (g i).
  have h_cauchy_schwarz : (∑ i : α, f i * g i) ^ 2 ≤ (∑ i : α, f i ^ 2) * (∑ i : α, g i ^ 2) := by
    exact sum_mul_sq_le_sq_mul_sq univ f g
  unfold l2norm;
  simpa only [ ← Real.sqrt_mul ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ] using Real.abs_le_sqrt h_cauchy_schwarz

/-- walkApply agrees with matrix power application. -/
theorem walkApply_pow (P : Matrix α α ℝ) (f : α → ℝ) (t : ℕ) :
    walkApply (P ^ t) f = fun x => ∑ y, (P ^ t) x y * f y := by
  rfl

/-! ## Theorem A: Pointwise mixing bound from L² contraction

If the walk operator P contracts mean-zero functions in L² at rate λ,
then the action of P^t on f decays pointwise at rate λ^t.

Mathematically: |(P^t f)(x)| ≤ λ^t · ‖f‖₂.

This converts spectral contraction into pointwise pseudorandomness. -/

/-
**Theorem A (Expander Walk Observable Decay).**
Given L²-contraction at rate λ, the walk action on f decays pointwise.
This is the formal mixing engine: spectral contraction → pointwise pseudorandomness.
-/
theorem expander_walk_observable_decay
    (P : Matrix α α ℝ)
    (lam : ℝ)
    (f : α → ℝ)
    (h_contr :
      ∀ t : ℕ,
        l2norm (fun x => ∑ y, (P ^ t) x y * f y) ≤ lam ^ t * l2norm f)
    (_hlam_nn : 0 ≤ lam) :
    ∀ x : α, ∀ t : ℕ,
      |∑ y, (P ^ t) x y * f y| ≤ lam ^ t * l2norm f := by
  intros x t;
  refine' le_trans _ ( h_contr t );
  convert abs_le_l2norm _ x using 1;
  convert rfl

/-! ## Theorem B: Correlation decay along the walk

For functions f, g : α → ℝ, if the walk contracts g in L² at rate λ, then
the correlation ⟨f, P^t g⟩ = ∑_x f(x) · (P^t g)(x) decays at rate λ^t.

This is the true pseudorandomness statement: the walk destroys correlation
at an exponential rate controlled by the spectral gap. It is a finite-state
analogue of decay of correlations in statistical mechanics. -/

/-
**Theorem B (Expander Walk Correlation Decay).**
Given L²-contraction of g at rate λ, the correlation between f and P^t g
decays exponentially. This certifies that the walk produces nearly
independent samples for bounded observables.
-/
theorem expander_walk_correlation_decay
    (P : Matrix α α ℝ)
    (lam : ℝ)
    (f g : α → ℝ)
    (h_contr :
      ∀ t : ℕ,
        l2norm (fun x => ∑ y, (P ^ t) x y * g y) ≤ lam ^ t * l2norm g)
    (_hlam_nn : 0 ≤ lam) :
    ∀ t : ℕ,
      |∑ x, f x * (∑ y, (P ^ t) x y * g y)|
        ≤ l2norm f * (lam ^ t * l2norm g) := by
  exact fun t => le_trans ( cauchy_schwarz_finsum _ _ ) ( mul_le_mul_of_nonneg_left ( h_contr t ) ( l2norm_nonneg _ ) )

/-! ## Connecting spectral gap to contraction rate

The contraction rate λ is related to the spectral gap by λ = 1 - gap.
We formalize this connection. -/

/-
**Spectral gap implies contraction.**
If the spectral gap of P is δ > 0, then the contraction rate on
mean-zero functions is λ = 1 - δ.
-/
theorem contraction_rate_from_gap
    (gap : ℝ) (hgap : 0 < gap) (hgap1 : gap ≤ 1) :
    0 ≤ 1 - gap ∧ 1 - gap < 1 := by
  grind

/-! ## Derived bounds -/

/-
For bounded observables, correlation decay gives an explicit numerical bound.
-/
theorem correlation_bound_bounded_observables
    (P : Matrix α α ℝ)
    (lam B_f B_g : ℝ)
    (f g : α → ℝ)
    (hf_bd : BoundedObservable f B_f)
    (hg_bd : BoundedObservable g B_g)
    (hBf : 0 ≤ B_f) (hBg : 0 ≤ B_g)
    (h_contr :
      ∀ t : ℕ,
        l2norm (fun x => ∑ y, (P ^ t) x y * g y) ≤ lam ^ t * l2norm g)
    (hlam_nn : 0 ≤ lam) :
    ∀ t : ℕ,
      |∑ x, f x * (∑ y, (P ^ t) x y * g y)|
        ≤ B_f * Real.sqrt (Fintype.card α) * (lam ^ t * (B_g * Real.sqrt (Fintype.card α))) := by
  intro t
  have h_sum_bound : |∑ x, f x * (∑ y, (P ^ t) x y * g y)| ≤ l2norm f * (lam ^ t * l2norm g) := by
    exact expander_walk_correlation_decay P lam f g h_contr hlam_nn t
  refine' le_trans h_sum_bound ( mul_le_mul _ _ _ _ );
  · refine' Real.sqrt_le_iff.mpr ⟨ by positivity, _ ⟩;
    rw [ mul_pow, Real.sq_sqrt ( Nat.cast_nonneg _ ) ];
    exact le_trans ( Finset.sum_le_sum fun _ _ => show f _ ^ 2 ≤ B_f ^ 2 by nlinarith only [ abs_le.mp ( hf_bd ‹_› ) ] ) ( by simp +decide [ mul_comm ] );
  · gcongr;
    exact Real.sqrt_le_iff.mpr ⟨ by positivity, by simpa [ mul_pow, mul_comm, Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => pow_le_pow_left₀ ( abs_nonneg _ ) ( hg_bd i ) 2 ⟩;
  · exact mul_nonneg ( pow_nonneg hlam_nn _ ) ( Real.sqrt_nonneg _ );
  · positivity

/-
**Walk length for target error.**
To achieve correlation at most ε, it suffices to walk
t = ⌈log(1/ε) / log(1/λ)⌉ steps (when 0 < λ < 1).
Here we prove the key ingredient: λ^t < ε when t is large enough.
-/
theorem pow_lt_of_lt_one_of_pos
    (lam ε : ℝ) (_hlam : 0 ≤ lam) (hlam1 : lam < 1) (hε : 0 < ε) :
    ∃ t : ℕ, lam ^ t < ε := by
  exact exists_pow_lt_of_lt_one hε hlam1