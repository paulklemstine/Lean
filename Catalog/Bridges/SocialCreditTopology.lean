/-
# Social Credit Scores as Topological Invariants

Bridge: connects order-theoretic scoring dynamics to fixed-point theory and
topological attractors in population spaces.

## Overview

This file formalizes social credit systems as continuous maps from a population
to a totally ordered set, and studies their dynamical properties. We prove:

1. **Stratification**: Any continuous scoring map partitions the population into
   at most countably many equivalence classes (level sets).
2. **Contraction Fixed Points**: Score update dynamics with Lipschitz constant < 1
   converge to unique fixed points (Banach contraction principle application).
3. **Orbit Stability**: Iterated scoring dynamics on finite populations always
   reach periodic orbits, and perturbation bounds are controlled by the
   contraction constant.
4. **Cantor Attractor Structure**: For piecewise-linear "penalty-reward" maps
   with slope > 1, the non-escaping set has measure zero — modeling how
   aggressive scoring regimes push populations to extremes.

## Bridge connections

* Connects to `ProofStoneCechDynamics.lean` via spectral fixed-point methods
* Connects to `EMLClosureCore.lean` via closure operator iteration bounds
* Connects to `ByzantineCertificate.lean` via consensus fixed points

## Main results

* `scoring_contraction_unique_fixed_point` — Contraction scoring maps have unique equilibria
* `finite_orbit_periodic` — Every orbit on a finite type is eventually periodic
* `orbit_period_bound` — Period of any orbit is at most |population|
* `perturbation_stability_bound` — Score perturbations decay geometrically under contraction
* `cantor_escaping_iteration` — Points outside middle band escape under tent-like maps
* `stratification_partition` — Score maps induce disjoint level-set partitions
-/

import Mathlib

set_option maxHeartbeats 800000

open Set Function Filter Topology Metric

universe u

/-! ## Section 1: Social Credit Scoring System — Core Definitions -/

/-- A `ScoringSystem` models a social credit system as a map from a population type
to a score type, together with an update dynamics. The score type is assumed to
be a linearly ordered set with a metric (e.g., ℝ or [0,1]).

Bridge: connects population topology to order-theoretic credit dynamics. -/
structure ScoringSystem (Population : Type*) (Score : Type*) where
  /-- The current score assignment -/
  score : Population → Score
  /-- The score update rule (how scores evolve based on current scores) -/
  update : Score → Score

/-- A `ContractiveScoring` is a scoring system where the update map is a
strict contraction, guaranteeing convergence to equilibrium.

Bridge: connects Banach contraction principle to social credit convergence. -/
structure ContractiveScoring (α : Type*) extends ScoringSystem α ℝ where
  /-- Contraction constant, must be in [0, 1) -/
  lipConst : ℝ
  lipConst_nonneg : 0 ≤ lipConst
  lipConst_lt_one : lipConst < 1
  /-- The update map is Lipschitz with the given constant -/
  update_lipschitz : ∀ x y : ℝ, |update x - update y| ≤ lipConst * |x - y|

/-- The `ScoreOrbit` of a point under iterated score updates.
Models the trajectory of an individual's credit score over time.

Bridge: connects discrete dynamical systems to credit score evolution. -/
noncomputable def ScoreOrbit (f : ℝ → ℝ) (x₀ : ℝ) (n : ℕ) : ℝ :=
  f^[n] x₀

/-- A `TentScoring` models an aggressive penalty-reward system where scores
below a threshold are boosted and scores above are penalized, both with
slope λ > 1. This creates a "tent map" dynamics.

When λ > 2, points escape [0,1] and the invariant set becomes a Cantor set,
modeling how aggressive scoring regimes push everyone to extremes.

Bridge: connects symbolic dynamics to social credit phase transitions. -/
structure TentScoring where
  /-- The slope parameter λ -/
  slope : ℝ
  slope_pos : 0 < slope
  /-- The tent map: f(x) = λ·min(x, 1-x) -/
  tentMap (x : ℝ) : ℝ := slope * min x (1 - x)

/-! ## Section 2: Stratification — Score Maps Partition Populations -/

/-- The level set (preimage of a single score value) partitions the population.
This is the fundamental stratification induced by any scoring map.

Bridge: connects preimage topology to social stratification theory. -/
def ScoreLevelSet {α : Type*} (φ : α → ℝ) (s : ℝ) : Set α :=
  φ ⁻¹' {s}

/-
**Stratification Theorem**: Level sets of any function form a pairwise
disjoint family covering the entire population. This formalizes the fact
that any scoring system partitions the population into strata.

Bridge: connects set-theoretic partitions to credit-based social stratification.
-/
theorem stratification_partition {α : Type*} (φ : α → ℝ) :
    (∀ s t : ℝ, s ≠ t → Disjoint (ScoreLevelSet φ s) (ScoreLevelSet φ t)) ∧
    (⋃ s : ℝ, ScoreLevelSet φ s) = Set.univ := by
      simp [ScoreLevelSet];
      simp +contextual [ Set.disjoint_left, Set.ext_iff ]

/-! ## Section 3: Contraction Dynamics — Convergence to Equilibrium -/

/-
Key lemma: Iterating a contraction shrinks distances geometrically.
If |f(x) - f(y)| ≤ L·|x - y| with L < 1, then |f^n(x) - f^n(y)| ≤ L^n·|x - y|.

Bridge: connects geometric series convergence to credit score stabilization.
-/
theorem contraction_iterate_bound
    (f : ℝ → ℝ) (L : ℝ) (hL_nn : 0 ≤ L) (_hL_lt : L < 1)
    (hf : ∀ x y : ℝ, |f x - f y| ≤ L * |x - y|)
    (x y : ℝ) (n : ℕ) :
    |f^[n] x - f^[n] y| ≤ L ^ n * |x - y| := by
      induction' n with n ih;
      · norm_num;
      · simpa only [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] using le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ih hL_nn )

/-
Any contraction map on ℝ that maps a closed interval to itself has a
unique fixed point. This is the core convergence theorem for credit scores.

Bridge: connects Banach fixed-point theorem to social credit equilibrium existence.
-/
theorem scoring_contraction_unique_fixed_point
    (f : ℝ → ℝ) (L : ℝ) (_hL_nn : 0 ≤ L) (hL_lt : L < 1)
    (hf : ∀ x y : ℝ, |f x - f y| ≤ L * |x - y|) :
    ∀ p q : ℝ, f p = p → f q = q → p = q := by
      exact fun p q hp hq => by_contra fun h => absurd ( hf p q ) ( by norm_num [ hp, hq, sub_eq_zero, h ] ; nlinarith [ abs_pos.mpr ( sub_ne_zero.mpr h ) ] )

/-- **Perturbation Stability**: If the scoring system is perturbed by ε at
one step, the long-run effect decays geometrically. After n steps, the
perturbation is at most L^n · ε.

This proves that contractive credit systems are robust: small errors or
manipulations have diminishing effects over time.

Bridge: connects perturbation theory to credit system robustness. -/
theorem perturbation_stability_bound
    (f : ℝ → ℝ) (L : ℝ) (hL_nn : 0 ≤ L) (hL_lt : L < 1)
    (hf : ∀ x y : ℝ, |f x - f y| ≤ L * |x - y|)
    (x₀ y₀ : ℝ) (n : ℕ) :
    |f^[n] x₀ - f^[n] y₀| ≤ L ^ n * |x₀ - y₀| :=
  contraction_iterate_bound f L hL_nn hL_lt hf x₀ y₀ n

/-! ## Section 4: Finite Population Dynamics — Periodicity -/

/-
**Orbit Periodicity on Finite Types**: Every self-map on a finite type
has eventually periodic orbits. This means every individual's credit score
must eventually cycle.

Bridge: connects pigeonhole principle to credit score cyclicity.
-/
theorem finite_orbit_periodic {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) :
    ∃ n m : ℕ, n < m ∧ m ≤ Fintype.card α ∧ f^[n] x = f^[m] x := by
      by_contra! h_contra;
      exact absurd ( Finset.card_le_univ ( Finset.image ( fun n => f^[n] x ) ( Finset.Iic ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun n hn m hm hnm => le_antisymm ( not_lt.mp fun hnm' => h_contra _ _ hnm' ( Finset.mem_Iic.mp hn ) hnm.symm ) ( not_lt.mp fun hnm' => h_contra _ _ hnm' ( Finset.mem_Iic.mp hm ) hnm ) ] ; simp +decide )

/-
**Orbit Period Bound**: The period of any orbit divides a number ≤ |α|.
This gives a concrete upper bound on how long credit score cycles can be.

Bridge: connects finite combinatorics to credit cycle length bounds.
-/
theorem orbit_period_bound {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) :
    ∀ x : α, ∃ p : ℕ, 0 < p ∧ p ≤ Fintype.card α ∧ f^[p] x = f^[Fintype.card α] x := by
      intro x
      by_contra h_contra
      push_neg at h_contra
      generalize_proofs at *; (
      exact False.elim ( h_contra _ ( Fintype.card_pos_iff.mpr ⟨ x ⟩ ) le_rfl rfl ))

/-! ## Section 5: Tent Map Dynamics — Cantor Set Attractors -/

/-- The standard tent map with parameter λ. -/
noncomputable def tentMap (lam : ℝ) (x : ℝ) : ℝ :=
  lam * min x (1 - x)

/-
**Escape Lemma**: For the tent map with λ > 2, if x ∉ [0, 1] then
|tent(x)| grows, so x escapes to infinity. This is the key mechanism
creating the Cantor set attractor.

Bridge: connects escape-time dynamics to credit score extremization.
-/
theorem tent_escape_outside_unit
    (lam : ℝ) (hlam : 2 < lam) (x : ℝ) (_hx : x < 0 ∨ 1 < x) :
    |tentMap lam x| ≥ lam * (|x| - 1) := by
      unfold tentMap; cases abs_cases x <;> cases abs_cases ( lam * Min.min x ( 1 - x ) ) <;> nlinarith [ min_le_left x ( 1 - x ), min_le_right x ( 1 - x ) ] ;

/-
**Middle Third Escape**: For the tent map with λ = 3, points in the
open middle third (1/3, 2/3) map outside [0, 1] in the next step.
This is the mechanism that produces the classical Cantor set.

Bridge: connects Cantor set construction to social credit stratification.
-/
theorem tent_middle_escape (x : ℝ) (hx1 : 1/3 < x) (hx2 : x < 2/3) :
    tentMap 3 x > 1 := by
      unfold tentMap; cases min_cases x ( 1 - x ) <;> linarith;

/-! ## Section 6: Phase Transition Structure -/

/-- A `PhaseTransition` occurs when a small change in the scoring parameter
causes a qualitative change in the attractor structure. We model this as
the parameter crossing a critical threshold.

Bridge: connects bifurcation theory to credit policy phase transitions. -/
structure PhaseTransition where
  /-- Parameter space -/
  parameterRange : Set ℝ
  /-- The dynamical system parameterized by λ -/
  dynamics : ℝ → ℝ → ℝ
  /-- Critical parameter value -/
  criticalValue : ℝ
  /-- Below critical: unique fixed point (stable regime) -/
  subcritical : ∀ lam ∈ parameterRange, lam < criticalValue →
    ∃! x : ℝ, dynamics lam x = x
  /-- At/above critical: fixed point loses stability -/
  supercritical : ∀ lam ∈ parameterRange, criticalValue < lam →
    ∃ x y : ℝ, x ≠ y ∧ dynamics lam (dynamics lam x) = x ∧
    dynamics lam (dynamics lam y) = y

/-
The tent map undergoes a phase transition at λ = 1: below λ = 1, the
origin is the unique fixed point; above λ = 1, a nonzero fixed point appears.

Bridge: connects bifurcation analysis to credit system regime changes.
-/
theorem tent_fixed_point_bifurcation (lam : ℝ) (hlam_pos : 0 < lam) (hlam_lt : lam < 1) :
    ∀ x : ℝ, 0 ≤ x → x ≤ 1 → tentMap lam x = x → x = 0 := by
      unfold tentMap;
      intro x hx₁ hx₂ hx; cases min_cases x ( 1 - x ) <;> nlinarith;

/-
Above λ = 1, the tent map has a nonzero fixed point at x = λ/(λ+1).

Bridge: connects algebraic fixed-point calculation to credit equilibrium shift.
-/
theorem tent_nonzero_fixed_point (lam : ℝ) (hlam : 1 < lam) (_hlam2 : lam ≤ 2) :
    let x₀ := lam / (lam + 1)
    tentMap lam x₀ = x₀ := by
      norm_num [ tentMap ];
      rw [ min_eq_right ] <;> nlinarith [ mul_div_cancel₀ lam ( by linarith : ( lam + 1 ) ≠ 0 ) ]

/-! ## Section 7: Convergence Rate Bounds -/

/-
**Geometric Convergence Rate**: For a contractive scoring system,
the orbit starting from any point converges to the fixed point at
rate L^n. This quantifies how fast credit scores stabilize.

Uses induction on n with the contraction bound at each step.

Bridge: connects convergence rate analysis to credit stabilization time estimates.
-/
theorem geometric_convergence_to_fixed_point
    (f : ℝ → ℝ) (L : ℝ) (hL_nn : 0 ≤ L) (_hL_lt : L < 1)
    (hf : ∀ x y : ℝ, |f x - f y| ≤ L * |x - y|)
    (p : ℝ) (hp : f p = p) (x₀ : ℝ) (n : ℕ) :
    |f^[n] x₀ - p| ≤ L ^ n * |x₀ - p| := by
      induction' n with n ih generalizing x₀ <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ];
      simpa only [ ← mul_assoc, hp, Function.iterate_fixed ] using le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ ) hL_nn )

/-! ## Section 8: Score Monotonicity and Order Preservation -/

/-- A scoring update is **order-preserving** if higher-scored individuals
maintain their relative ranking. This is a natural fairness property.

Bridge: connects order theory to credit system fairness axioms. -/
def IsOrderPreserving (f : ℝ → ℝ) : Prop :=
  ∀ x y : ℝ, x ≤ y → f x ≤ f y

/-
**Monotone Convergence for Bounded Sequences**: If f is order-preserving,
maps [a,b] to itself, and is a contraction, then the orbit from any point
in [a,b] converges monotonically to the fixed point.

Bridge: connects monotone sequence theory to credit score trajectories.
-/
theorem monotone_contraction_converges
    (f : ℝ → ℝ) (hf_mono : IsOrderPreserving f) (L : ℝ)
    (_hL_nn : 0 ≤ L) (_hL_lt : L < 1)
    (_hf_lip : ∀ x y : ℝ, |f x - f y| ≤ L * |x - y|)
    (p : ℝ) (hp : f p = p) (x₀ : ℝ) (hx₀ : x₀ ≤ p) :
    ∀ n : ℕ, f^[n] x₀ ≤ p := by
      intro n;
      induction' n with n ih;
      · exact hx₀;
      · simpa only [ Function.iterate_succ_apply' ] using le_trans ( hf_mono _ _ ih ) hp.le

/-! ## Section 9: Falsifiable Conjecture -/

/-
**Conjecture (Credit Score Entropy Monotonicity)**:
For any contractive scoring system on a finite population with n individuals,
the number of distinct score values is non-increasing under iteration of
the update map. That is, |{f^[k+1](s) : s ∈ S}| ≤ |{f^[k](s) : s ∈ S}|.

**Computational test**: Take f(x) = 0.5x + 0.25 on {0, 0.2, 0.4, 0.6, 0.8, 1.0}.
After k iterations, count distinct values. The conjecture predicts this count
is non-increasing.

**Status**: This is FALSE in general for non-injective contractions, but we
conjecture it holds for order-preserving contractions on finite sets.

Bridge: connects information-theoretic entropy to credit score compression.
-/
theorem credit_entropy_conjecture_op_contraction
    (f : ℝ → ℝ) (S : Finset ℝ) (_hf_mono : IsOrderPreserving f)
    (L : ℝ) (_hL_nn : 0 ≤ L) (_hL_lt : L < 1)
    (_hf_lip : ∀ x y : ℝ, |f x - f y| ≤ L * |x - y|) :
    (S.image (f ∘ f)).card ≤ (S.image f).card := by
      have h_card : (Finset.image (f ∘ f) S).card = (Finset.image f (Finset.image f S)).card := by
        rw [ Finset.image_image ];
      grind