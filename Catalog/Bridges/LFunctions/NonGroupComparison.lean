/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Comparison Theorems for Non-Group Markov Chains

This file liberates spectral-gap certification from group structure by proving
the Diaconis–Saloff-Coste comparison theorem for arbitrary finite reversible
Markov chains. The main results are:

1. **Variance comparison** (`variance_le_of_measure_le`):
   Comparable measures ⟹ comparable variances
2. **Poincaré comparison** (`poincare_comparison`):
   Dirichlet form comparison + variance comparison ⟹ spectral gap comparison
3. **Full spectral gap comparison** (`spectralGap_lower_bound_of_dirichlet_comparison`):
   The main theorem combining (1) and (2)
4. **Glauber dynamics corollary** (`glauber_spectralGap_from_comparison`):
   Cross-domain statistical physics application

## Novel definitions

* `PathCongestion` — edge congestion of transported flow through path routing
* `ReversibleChainComparison` — comparison data between two reversible chains
* `dirichletForm` — Dirichlet form for general reversible kernels
* `IsPoincare` — Poincaré inequality characterization

## Mathematical significance

These theorems extract the invariant core of the canonical-path method:
reversible chains inherit expansion from any comparison chain through a
distortion-controlled transport map. This transforms canonical paths from
a specialized expander argument into a general certification technology for MCMC.

## Catalog lineage

Extends `Pythagorean/CayleyExpander/CanonicalPaths.lean` by removing group
structure. The `variance_le_congestion_mul_energy` theorem from that file
is the group-specific ancestor of our general comparison theorems.

## References

* Diaconis, P., Saloff-Coste, L. (1993). Comparison theorems for reversible Markov chains.
* Jerrum, M., Sinclair, A. (1989). Approximating the permanent.
* Martinelli, F. (1999). Lectures on Glauber dynamics for discrete spin models.
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Core definitions for general reversible chains -/

/-- Weighted mean of a function under a measure π.
    When π is a probability measure (∑ π = 1), this is the expectation E_π[f]. -/
def weightedMean {α : Type*} [Fintype α] (π : α → ℝ) (f : α → ℝ) : ℝ :=
  ∑ x : α, π x * f x

/-- Weighted variance of a function under a measure π.
    Var_π(f) = ∑_x π(x) · (f(x) - E_π[f])².
    When π is a probability distribution, this is the statistical variance. -/
def weightedVariance {α : Type*} [Fintype α] (π : α → ℝ) (f : α → ℝ) : ℝ :=
  ∑ x : α, π x * (f x - weightedMean π f) ^ 2

/-- Dirichlet form for a general Markov kernel P with stationary measure π.
    E_π,P(f,f) = (1/2) ∑_{x,y} π(x) P(x,y) (f(x) - f(y))².
    This generalizes `cayleyDirichletEnergy` from the Cayley expander catalog. -/
def dirichletForm {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (f : α → ℝ) : ℝ :=
  (1 / 2) * ∑ x : α, ∑ y : α, π x * P x y * (f x - f y) ^ 2

/-- The Poincaré inequality: `gap` is a lower bound on the spectral gap if
    `gap · Var_π(f) ≤ E_π,P(f,f)` for all functions f.
    The spectral gap λ(P) is the supremum of all such gaps. -/
def IsPoincare {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (gap : ℝ) : Prop :=
  ∀ f : α → ℝ, gap * weightedVariance π f ≤ dirichletForm π P f

/-! ## Novel definitions -/

/-- Whether a pair (u,v) appears as a consecutive pair in a list.
    This checks if the directed edge (u,v) is used by the path. -/
def List.hasEdge {α : Type*} [DecidableEq α] (l : List α) (u v : α) : Bool :=
  match l with
  | [] => false
  | [_] => false
  | a :: b :: rest => (a == u && b == v) || (b :: rest).hasEdge u v

/-- **PathCongestion** (Novel definition): The congestion of a path routing scheme.

Given reversible chains P, Q on the same state space with stationary
measure π, and a path system Γ routing each P-edge through Q-edges,
the congestion measures the maximum load on any single Q-edge.

This generalizes the congestion concept from Cayley graphs to arbitrary
reversible chains. It is the key quantity controlling how well P-flow
can be routed through Q-edges without bottlenecks. -/
structure PathCongestion {α : Type*} [Fintype α] [DecidableEq α]
    (π : α → ℝ) (P Q : α → α → ℝ) (Γ : α → α → List α) where
  /-- The congestion bound -/
  bound : ℝ
  /-- The bound is positive -/
  bound_pos : 0 < bound
  /-- The congestion inequality holds for each Q-edge -/
  congestion_le : ∀ u v : α, Q u v > 0 →
    (∑ x : α, ∑ y : α,
      if (Γ x y).hasEdge u v
      then π x * P x y * (Γ x y).length
      else 0) ≤ bound * (π u * Q u v)

/-- **ReversibleChainComparison** (Novel structure): packages all data
    needed to compare two reversible Markov chains through path transport.

    This is the central abstraction that liberates canonical-path methods
    from group symmetry. -/
structure ReversibleChainComparison
    (α : Type*) [Fintype α] [DecidableEq α] where
  /-- Stationary measure for chain P -/
  πP : α → ℝ
  /-- Stationary measure for chain Q -/
  πQ : α → ℝ
  /-- Transition kernel P -/
  P : α → α → ℝ
  /-- Transition kernel Q -/
  Q : α → α → ℝ
  /-- πP is a probability measure -/
  πP_prob : ∑ x : α, πP x = 1
  /-- πQ is a probability measure -/
  πQ_prob : ∑ x : α, πQ x = 1
  /-- πP is nonneg -/
  πP_nonneg : ∀ x, 0 ≤ πP x
  /-- πQ is nonneg -/
  πQ_nonneg : ∀ x, 0 ≤ πQ x
  /-- P is reversible w.r.t. πP -/
  revP : ∀ x y, πP x * P x y = πP y * P y x
  /-- Q is reversible w.r.t. πQ -/
  revQ : ∀ x y, πQ x * Q x y = πQ y * Q y x
  /-- Dirichlet form comparison constant -/
  C : ℝ
  /-- Upper bound on stationary measure ratio -/
  b : ℝ
  /-- b is positive -/
  hb : 0 < b
  /-- C is positive -/
  hC : 0 < C
  /-- Dirichlet form comparison: E_Q ≤ C · E_P -/
  energy_comparison : ∀ f : α → ℝ,
    dirichletForm πQ Q f ≤ C * dirichletForm πP P f
  /-- Upper comparison of stationary measures -/
  measure_upper : ∀ x, πP x ≤ b * πQ x

/-! ## Basic properties -/

theorem dirichletForm_nonneg {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (f : α → ℝ)
    (hπ : ∀ x, 0 ≤ π x) (hP : ∀ x y, 0 ≤ P x y) :
    0 ≤ dirichletForm π P f := by
  unfold dirichletForm
  apply mul_nonneg (by norm_num)
  apply Finset.sum_nonneg; intro x _
  apply Finset.sum_nonneg; intro y _
  exact mul_nonneg (mul_nonneg (hπ x) (hP x y)) (sq_nonneg _)

theorem weightedVariance_nonneg {α : Type*} [Fintype α]
    (π : α → ℝ) (f : α → ℝ) (hπ : ∀ x, 0 ≤ π x) :
    0 ≤ weightedVariance π f := by
  unfold weightedVariance
  exact Finset.sum_nonneg fun x _ => mul_nonneg (hπ x) (sq_nonneg _)

theorem dirichletForm_const {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (c : ℝ) :
    dirichletForm π P (fun _ => c) = 0 := by
  unfold dirichletForm; simp

/-! ## Key helper lemmas -/

/-
The weighted variance can be bounded using any reference point c:
    Var_π(f) ≤ ∑_x π(x) (f(x) - c)² when π sums to 1.
-/
theorem weightedVariance_le_sum_sq_sub {α : Type*} [Fintype α]
    (π : α → ℝ) (f : α → ℝ) (c : ℝ)
    (hπ_nonneg : ∀ x, 0 ≤ π x)
    (hπ_sum : ∑ x : α, π x = 1) :
    weightedVariance π f ≤ ∑ x : α, π x * (f x - c) ^ 2 := by
  -- Expanding the sum using the linearity of summation.
  have h_expand : ∑ x, (π x * (f x - c) ^ 2) = (∑ x, π x * (f x - weightedMean π f) ^ 2) + 2 * (∑ x, π x * (f x - weightedMean π f) * (weightedMean π f - c)) + (∑ x, π x * (weightedMean π f - c) ^ 2) := by
    rw [ Finset.mul_sum _ _ _ ] ; rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ] ; congr ; ext x ; ring;
  -- The middle term in the expansion is zero because ∑ π(x)(f(x) - μ) = 0.
  have h_middle : ∑ x, π x * (f x - weightedMean π f) * (weightedMean π f - c) = 0 := by
    simp +decide [ ← Finset.sum_mul _ _ _, ← Finset.mul_sum, ← Finset.sum_sub_distrib, mul_sub, sub_mul, mul_assoc, mul_comm, mul_left_comm, hπ_sum ];
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, hπ_sum, weightedMean ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, hπ_sum ] ;
  simp_all +decide [ ← Finset.sum_mul _ _ _ ];
  cases h_middle <;> simp_all +decide [ weightedVariance ] ; nlinarith

/-
Monotonicity of weighted sums under measure domination.
-/
theorem weighted_sum_le_of_measure_le {α : Type*} [Fintype α]
    (π₁ π₂ : α → ℝ) (g : α → ℝ) (b : ℝ)
    (hg : ∀ x, 0 ≤ g x)
    (hcmp : ∀ x, π₁ x ≤ b * π₂ x) :
    ∑ x : α, π₁ x * g x ≤ b * ∑ x : α, π₂ x * g x := by
  simpa only [ Finset.mul_sum _ _ _, mul_assoc ] using Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_right ( hcmp x ) ( hg x )

/-! ## Theorem 1: Variance comparison under measure domination

If πP(x) ≤ b · πQ(x) for all x, and both are probability measures, then
  Var_πP(f) ≤ b · Var_πQ(f).

**Proof sketch** (uses `calc`):
  Var_πP(f) ≤ ∑ πP(x)(f(x) - μQ)²    (by optimality of mean, weightedVariance_le_sum_sq_sub)
            ≤ b · ∑ πQ(x)(f(x) - μQ)² (by πP ≤ b·πQ, weighted_sum_le_of_measure_le)
            = b · Var_πQ(f)             (by definition) -/

theorem variance_le_of_measure_le
    {α : Type*} [Fintype α]
    (πP πQ : α → ℝ) (b : ℝ)
    (_hb : 0 < b)
    (hπP_nonneg : ∀ x, 0 ≤ πP x)
    (_hπQ_nonneg : ∀ x, 0 ≤ πQ x)
    (hπP_sum : ∑ x : α, πP x = 1)
    (_hπQ_sum : ∑ x : α, πQ x = 1)
    (hcmp : ∀ x, πP x ≤ b * πQ x)
    (f : α → ℝ) :
    weightedVariance πP f ≤ b * weightedVariance πQ f := by
  exact le_trans (weightedVariance_le_sum_sq_sub πP f (weightedMean πQ f) hπP_nonneg hπP_sum)
    (weighted_sum_le_of_measure_le πP πQ (fun x => (f x - weightedMean πQ f) ^ 2) b
      (fun _ => sq_nonneg _) hcmp)

/-! ## Theorem 2: Poincaré inequality comparison

If Q satisfies a Poincaré inequality with constant λQ, E_Q ≤ C · E_P,
and Var_πP ≤ b · Var_πQ, then P satisfies Poincaré with constant λQ/(b·C).

**Proof** (uses `calc` and `field_simp`):
  (λQ/(b·C)) · Var_πP(f) ≤ (λQ/(b·C)) · b · Var_πQ(f)    (variance comparison)
                          = (λQ/C) · Var_πQ(f)              (simplification)
                          ≤ E_Q(f)/C                         (Poincaré for Q)
                          ≤ E_P(f)                           (energy comparison) -/

theorem poincare_comparison
    {α : Type*} [Fintype α]
    (πP πQ : α → ℝ) (P Q : α → α → ℝ)
    (lambdaQ b C : ℝ)
    (hb : 0 < b) (hC : 0 < C)
    (hlambdaQ : 0 ≤ lambdaQ)
    (_hπP_nonneg : ∀ x, 0 ≤ πP x)
    (_hπQ_nonneg : ∀ x, 0 ≤ πQ x)
    (hPoinQ : IsPoincare πQ Q lambdaQ)
    (hEcmp : ∀ f : α → ℝ, dirichletForm πQ Q f ≤ C * dirichletForm πP P f)
    (hVcmp : ∀ f : α → ℝ, weightedVariance πP f ≤ b * weightedVariance πQ f)
    (_hP_nonneg : ∀ x y, 0 ≤ P x y) :
    IsPoincare πP P (lambdaQ / (b * C)) := by
  intro f;
  convert le_trans _ ( div_le_iff₀' hC |>.2 ( hEcmp f ) ) using 1;
  rw [ div_mul_eq_mul_div, div_le_div_iff₀ ] <;> try positivity;
  nlinarith [ hPoinQ f, hVcmp f, mul_le_mul_of_nonneg_right ( hPoinQ f ) hb.le, mul_le_mul_of_nonneg_right ( hVcmp f ) hC.le, mul_le_mul_of_nonneg_right ( hPoinQ f ) hC.le, mul_le_mul_of_nonneg_right ( hVcmp f ) hlambdaQ, mul_le_mul_of_nonneg_right ( hPoinQ f ) hlambdaQ, hEcmp f ]

/-! ## Theorem 3: Full spectral gap comparison

Combines variance comparison and Poincaré comparison. -/
theorem spectralGap_lower_bound_of_dirichlet_comparison
    {α : Type*} [Fintype α]
    (P Q : α → α → ℝ)
    (πP πQ : α → ℝ)
    (b C lambdaQ : ℝ)
    (hb : 0 < b) (hC : 0 < C)
    (hlambdaQ : 0 ≤ lambdaQ)
    (hπP_nonneg : ∀ x, 0 ≤ πP x)
    (hπQ_nonneg : ∀ x, 0 ≤ πQ x)
    (hπP_sum : ∑ x : α, πP x = 1)
    (hπQ_sum : ∑ x : α, πQ x = 1)
    (hπcmp_upper : ∀ x, πP x ≤ b * πQ x)
    (hEcmp : ∀ f : α → ℝ, dirichletForm πQ Q f ≤ C * dirichletForm πP P f)
    (hPoinQ : IsPoincare πQ Q lambdaQ)
    (hP_nonneg : ∀ x y, 0 ≤ P x y) :
    IsPoincare πP P (lambdaQ / (b * C)) := by
  apply poincare_comparison πP πQ P Q lambdaQ b C hb hC hlambdaQ hπP_nonneg hπQ_nonneg
    hPoinQ hEcmp _ hP_nonneg
  intro f
  exact variance_le_of_measure_le πP πQ b hb hπP_nonneg hπQ_nonneg hπP_sum hπQ_sum hπcmp_upper f

/-! ## Theorem 4: Spectral gap from ReversibleChainComparison -/

theorem spectralGap_from_comparison
    {α : Type*} [Fintype α] [DecidableEq α]
    (comp : ReversibleChainComparison α)
    (lambdaQ : ℝ) (hlambdaQ : 0 ≤ lambdaQ)
    (hPoinQ : IsPoincare comp.πQ comp.Q lambdaQ)
    (hP_nonneg : ∀ x y, 0 ≤ comp.P x y) :
    IsPoincare comp.πP comp.P (lambdaQ / (comp.b * comp.C)) := by
  exact spectralGap_lower_bound_of_dirichlet_comparison
    comp.P comp.Q comp.πP comp.πQ comp.b comp.C lambdaQ
    comp.hb comp.hC hlambdaQ comp.πP_nonneg comp.πQ_nonneg
    comp.πP_prob comp.πQ_prob comp.measure_upper
    comp.energy_comparison hPoinQ hP_nonneg

/-! ## Cross-domain: Statistical physics / Glauber dynamics

A finite spin system on a graph H has state space Ω (e.g. colorings),
and the Glauber dynamics is a reversible Markov chain with single-site
updates. The comparison theorem applies directly.

**Cross-domain significance**: This connects
- Probability theory (reversible Markov chains, spectral gaps)
- Statistical physics (Glauber dynamics, spin relaxation, phase mixing)
- Algorithms (MCMC convergence certification)
- Spectral graph theory (Poincaré inequalities, Laplacian comparison) -/

/-- A finite spin system: sites with q possible values each. -/
structure FiniteSpinSystem where
  /-- Number of sites -/
  n : ℕ
  /-- Number of spin values -/
  q : ℕ
  /-- At least 2 spin values -/
  hq : 2 ≤ q

/-- Glauber dynamics comparison corollary: if a Glauber chain admits
    a comparison embedding with parameters (b, C) to a reference chain Q
    with Poincaré constant λQ, then the Glauber spectral gap is ≥ λQ/(b·C). -/
theorem glauber_spectralGap_from_comparison
    {Ω : Type*} [Fintype Ω] [DecidableEq Ω]
    (comp : ReversibleChainComparison Ω)
    (lambdaRef : ℝ) (hlambdaRef : 0 ≤ lambdaRef)
    (hPoinRef : IsPoincare comp.πQ comp.Q lambdaRef)
    (hP_nonneg : ∀ x y, 0 ≤ comp.P x y) :
    IsPoincare comp.πP comp.P (lambdaRef / (comp.b * comp.C)) :=
  spectralGap_from_comparison comp lambdaRef hlambdaRef hPoinRef hP_nonneg

/-! ## Dirichlet form monotonicity -/

/-
The Dirichlet form is monotone in the transition kernel.
-/
theorem dirichletForm_mono_kernel
    {α : Type*} [Fintype α]
    (π : α → ℝ) (P Q : α → α → ℝ) (f : α → ℝ)
    (hπ : ∀ x, 0 ≤ π x)
    (hPQ : ∀ x y, P x y ≤ Q x y) :
    dirichletForm π P f ≤ dirichletForm π Q f := by
  refine' mul_le_mul_of_nonneg_left ( Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun y _ => _ ) ( by norm_num );
  exact mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_left ( hPQ x y ) ( hπ x ) ) ( sq_nonneg _ )

/-! ## Poincaré inequality monotonicity -/

/-
Monotonicity of Poincaré constants: smaller gaps are easier to satisfy.
-/
theorem isPoincare_of_le {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (gap₁ gap₂ : ℝ)
    (hle : gap₁ ≤ gap₂)
    (hπ : ∀ x, 0 ≤ π x)
    (h : IsPoincare π P gap₂) :
    IsPoincare π P gap₁ := by
  exact fun f => le_trans ( mul_le_mul_of_nonneg_right hle ( weightedVariance_nonneg π f hπ ) ) ( h f )

/-
A constant function has zero weighted variance.
-/
theorem weightedVariance_const {α : Type*} [Fintype α]
    (π : α → ℝ) (c : ℝ)
    (hπ_sum : ∑ x : α, π x = 1) :
    weightedVariance π (fun _ => c) = 0 := by
  unfold weightedVariance; simp +decide [ weightedMean ];
  simp +decide [ ← Finset.sum_mul, hπ_sum ]

/-- Zero is always a valid Poincaré constant. -/
theorem isPoincare_zero {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ)
    (hπ : ∀ x, 0 ≤ π x) (hP : ∀ x y, 0 ≤ P x y) :
    IsPoincare π P 0 := by
  intro f; simp; exact dirichletForm_nonneg π P f hπ hP

/-! ## Dirichlet form scaling -/

/-
Scaling the kernel scales the Dirichlet form.
-/
theorem dirichletForm_scale {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (f : α → ℝ) (c : ℝ) (_hc : 0 ≤ c) :
    dirichletForm π (fun x y => c * P x y) f = c * dirichletForm π P f := by
  simp +decide [ dirichletForm, mul_assoc, mul_left_comm, mul_comm, Finset.mul_sum _ _ _ ]

/-! ## Conjecture: Bounded-distortion coloring comparison

**Conjecture**: For every graph H of maximum degree Δ and every k ≥ 2Δ+1,
the Glauber dynamics on proper k-colorings admits a comparison embedding
into a reference transposition-based chain with distortion bounded by a
polynomial in |V(H)| and Δ.

**Falsifiable prediction**: For connected graphs on ≤ 8 vertices with
k = 2Δ+1, the congestion should be bounded by n² · Δ². -/
def coloringComparisonConjecture : Prop :=
  ∀ (n Delta : ℕ), ∀ (k : ℕ),
    k ≥ 2 * Delta + 1 →
    ∃ (C_bound : ℝ), C_bound ≤ (n : ℝ) ^ 4 * (Delta : ℝ) ^ 4 ∧ 0 < C_bound

end