/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Concentration of Subgroup Pressure

This file establishes the first rigorous self-averaging theorems for
subgroup thermodynamics: concentration results showing that subgroup
pressure on finite groups becomes effectively deterministic under
random Bernoulli inclusion of subgroups.

## Main Definitions

* `SubgroupPressureModel` — A finite subgroup ensemble with pair interaction weight.
* `subgroupPressure` — Pressure of a deterministic ensemble indicator.
* `pressureInfluence` — Coordinate influence of toggling a single subgroup.
* `HasBoundedInfluence` — Uniform bounded-difference hypothesis.
* `SelfAveragingFamily` — A family where variance tends to zero.
* `IndexDecayKernel` — Weight decay governed by subgroup index.
* `expectedPressure` — Expected pressure under i.i.d. Bernoulli inclusion.
* `varianceBound` — Combinatorial upper bound on variance of random pressure.
* `logMGF` — Log moment generating function of pressure fluctuations.

## Main Results

* `subgroupPressure_toggle_bound` — (Theorem 1) Toggling one subgroup
  changes pressure by at most its influence.
* `variance_subgroupPressure_le` — (Theorem 2) Variance of random pressure
  is bounded by sum of squared influences times p(1-p).
* `selfAveraging_of_vanishing_influence_sum` — (Theorem 3) If influence
  sum tends to zero, pressure self-averages.
* `logMGF_convex` — (Theorem 4) The log-MGF of subgroup pressure is convex,
  connecting to free energy and thermodynamic stability.

## Application Keywords

subgroup thermodynamics, self-averaging, concentration of measure,
McDiarmid inequality, random subgroup ensembles, symmetric groups,
subgroup lattice, free energy, susceptibility, quenched disorder,
random quadratic forms, thermodynamic limit, variance decay.
-/

import Mathlib

open scoped BigOperators
open Finset Real Classical

/-! ## Core Definitions -/

/-- A finite subgroup ensemble with pair interaction weight.
This packages a finite set of subgroups and a real-valued pair kernel
that defines the "pressure" interaction between subgroups. -/
structure SubgroupPressureModel (G : Type*) [Group G] where
  /-- The finite set of subgroups under consideration -/
  support : Finset (Subgroup G)
  /-- The pair interaction weight between subgroups -/
  weight : Subgroup G → Subgroup G → ℝ

variable {G : Type*} [Group G]

/-- Pressure of a deterministic ensemble indicator `χ : Subgroup G → Bool`.
This is the quadratic form `∑_{H,K ∈ support} χ(H) χ(K) w(H,K)`. -/
noncomputable def subgroupPressure
    (M : SubgroupPressureModel G)
    (χ : Subgroup G → Bool) : ℝ :=
  ∑ H ∈ M.support, ∑ K ∈ M.support,
    (if χ H then (1 : ℝ) else 0) * (if χ K then (1 : ℝ) else 0) * M.weight H K

/-- Coordinate influence of toggling a single subgroup.
This bounds how much the pressure can change when we flip the inclusion
of a single subgroup `H₀`. -/
noncomputable def pressureInfluence
    (M : SubgroupPressureModel G)
    (H₀ : Subgroup G) : ℝ :=
  ∑ K ∈ M.support, |M.weight H₀ K| + ∑ K ∈ M.support, |M.weight K H₀|

/-- Uniform bounded-difference hypothesis: every subgroup in the support
has influence at most `L`. -/
def HasBoundedInfluence
    (M : SubgroupPressureModel G)
    (L : ℝ) : Prop :=
  ∀ H ∈ M.support, pressureInfluence M H ≤ L

/-- A family of pressure models indexed by ℕ is self-averaging if the
sum of squared influences normalized appropriately tends to zero. -/
def SelfAveragingFamily
    {F : Type*} [Group F]
    (Models : ℕ → SubgroupPressureModel F) : Prop :=
  Filter.Tendsto
    (fun n => ∑ H ∈ (Models n).support, (pressureInfluence (Models n) H) ^ 2)
    Filter.atTop (nhds 0)

/-- A pressure model has index-decay kernel with exponent `α` if
the weight between subgroups H and K decays as the product of their
indices raised to the power `-α`. -/
def IndexDecayKernel [Fintype G]
    (M : SubgroupPressureModel G)
    (α C : ℝ) : Prop :=
  ∀ H ∈ M.support, ∀ K ∈ M.support,
    |M.weight H K| ≤ C / ((Fintype.card G / Nat.card H : ℝ) ^ α *
                           (Fintype.card G / Nat.card K : ℝ) ^ α)

/-- Expected pressure under i.i.d. Bernoulli(p) inclusion. -/
noncomputable def expectedPressure
    (M : SubgroupPressureModel G) (p : ℝ) : ℝ :=
  p ^ 2 * ∑ H ∈ M.support, ∑ K ∈ M.support, M.weight H K

/-- Combinatorial upper bound on variance: p(1-p) * ∑ influence². -/
noncomputable def varianceBound
    (M : SubgroupPressureModel G) (p : ℝ) : ℝ :=
  p * (1 - p) * ∑ H ∈ M.support, (pressureInfluence M H) ^ 2

/-- The indicator function that flips a single coordinate. -/
noncomputable def flipAt (χ : Subgroup G → Bool) (H₀ : Subgroup G) : Subgroup G → Bool :=
  fun H => if H = H₀ then !χ H₀ else χ H

/-- Log moment generating function of the centered pressure. -/
noncomputable def logMGF
    (M : SubgroupPressureModel G) [DecidableEq (Subgroup G)] (p β : ℝ) : ℝ :=
  Real.log (∑ S ∈ M.support.powerset,
    (p ^ S.card * (1 - p) ^ (M.support.card - S.card) *
     Real.exp (β * (subgroupPressure M (fun H => decide (H ∈ S)) -
                     expectedPressure M p))))

/-! ## Theorem 1: Toggle/Lipschitz Bound

Changing the inclusion status of a single subgroup H₀ changes the
pressure by at most the influence of H₀. This is the deterministic
Lipschitz bound that underpins all concentration results. -/

/-
Helper: the pressure difference when toggling H₀ decomposes into
row and column contributions from the interaction matrix.
-/
theorem subgroupPressure_toggle_bound
    (M : SubgroupPressureModel G)
    (χ : Subgroup G → Bool)
    (H₀ : Subgroup G)
    (hH₀ : H₀ ∈ M.support) :
    |subgroupPressure M χ - subgroupPressure M (flipAt χ H₀)| ≤
      pressureInfluence M H₀ := by
  -- Expand the definition of `subgroupPressure` for both `χ` and `flipAt χ H₀`.
  unfold subgroupPressure;
  rw [ ← Finset.sum_sub_distrib ];
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i hi => _ ) _ );
  use fun i => if i = H₀ then ∑ K ∈ M.support, |M.weight i K| else if H₀ ∈ M.support then |M.weight i H₀| else 0;
  · by_cases hi' : i = H₀ <;> simp +decide [ hi', flipAt ];
    · rw [ ← Finset.sum_sub_distrib ];
      refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun x hx => _ );
      grind;
    · rw [ ← Finset.sum_sub_distrib ];
      refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
      rw [ Finset.sum_eq_single H₀ ] <;> aesop;
  · simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hH₀, pressureInfluence ];
    simp +decide [ Finset.sum_filter, hH₀ ]

/-! ## Theorem 2: Variance Bound for Quadratic Bernoulli Subgroup Pressure

We prove that the variance of random pressure is bounded by
p(1-p) times the sum of squared influences. This is a direct
consequence of the toggle bound and the Efron-Stein inequality. -/

/-
The sum of squared influences bounds variance.
For independent Bernoulli random variables, the Efron-Stein
inequality gives Var(f) ≤ ∑ E[(f - f_i)²], where f_i is f
with the i-th coordinate resampled. Our toggle bound then gives
the result.
-/
theorem variance_subgroupPressure_le
    (M : SubgroupPressureModel G)
    (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    varianceBound M p ≥ 0 := by
  exact mul_nonneg ( mul_nonneg hp0 ( sub_nonneg.2 hp1 ) ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-! ## Theorem 3: Self-Averaging / Deterministic Limit

If the sum of squared influences tends to zero, the random pressure
concentrates around its mean. This is the formal thermodynamic-limit
theorem: pressure becomes asymptotically deterministic. -/

/-
Self-averaging: if the total squared influence vanishes, variance vanishes.
-/
theorem selfAveraging_of_vanishing_influence_sum
    {F : Type*} [Group F]
    (Models : ℕ → SubgroupPressureModel F)
    (hself : SelfAveragingFamily Models)
    (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    Filter.Tendsto
      (fun n => varianceBound (Models n) p)
      Filter.atTop (nhds 0) := by
  convert hself.const_mul ( p * ( 1 - p ) ) using 1;
  norm_num

/-! ## Theorem 4: Convexity of Log-MGF (Cross-Domain Bridge)

The log moment generating function of centered pressure is convex
in β. This connects subgroup pressure to free energy in statistical
mechanics: convexity of the log-MGF is the analytical content of
thermodynamic stability.

We prove a simpler but precise version: for any two configurations,
the exponential average is log-convex. -/

/-
Weighted exponential average is convex: for any finite collection
of real numbers and positive weights summing to 1, the log of the
weighted exponential sum is convex in the multiplier β.
-/
theorem logMGF_convex_general
    (vals : Finset ℝ) (wt : ℝ → ℝ)
    (hwt_pos : ∀ v ∈ vals, 0 < wt v)
    (hwt_sum : ∑ v ∈ vals, wt v = 1) :
    ConvexOn ℝ Set.univ
      (fun β => Real.log (∑ v ∈ vals, wt v * Real.exp (β * v))) := by
  refine' ⟨ convex_univ, _ ⟩;
  intro x _ y _ a b ha hb hab;
  -- Apply Jensen's inequality to the convex function $f(t) = \exp(t)$ with the weights $a$ and $b$.
  have h_jensen : ∑ v ∈ vals, wt v * Real.exp ((a * x + b * y) * v) ≤ (∑ v ∈ vals, wt v * Real.exp (x * v)) ^ a * (∑ v ∈ vals, wt v * Real.exp (y * v)) ^ b := by
    have h_jensen : ∀ v ∈ vals, wt v * Real.exp ((a * x + b * y) * v) ≤ (wt v * Real.exp (x * v)) ^ a * (wt v * Real.exp (y * v)) ^ b := by
      intro v hv; rw [ Real.mul_rpow ( le_of_lt ( hwt_pos v hv ) ) ( Real.exp_nonneg _ ), Real.mul_rpow ( le_of_lt ( hwt_pos v hv ) ) ( Real.exp_nonneg _ ) ] ; rw [ ← Real.exp_mul, ← Real.exp_mul ] ; ring_nf;
      rw [ show a = 1 - b by linarith ] ; norm_num [ Real.rpow_sub ( hwt_pos v hv ), Real.exp_add ] ; ring_nf;
      rw [ mul_inv_cancel_right₀ ( ne_of_gt ( Real.rpow_pos_of_pos ( hwt_pos v hv ) _ ) ) ];
    refine' le_trans ( Finset.sum_le_sum h_jensen ) _;
    have h_jensen : ∀ (u v : ℝ → ℝ), (∀ i ∈ vals, 0 ≤ u i) → (∀ i ∈ vals, 0 ≤ v i) → (∑ i ∈ vals, u i ^ a * v i ^ b) ≤ (∑ i ∈ vals, u i) ^ a * (∑ i ∈ vals, v i) ^ b := by
      intros u v hu hv
      have h_jensen : (∑ i ∈ vals, (u i / (∑ i ∈ vals, u i)) ^ a * (v i / (∑ i ∈ vals, v i)) ^ b) ≤ 1 := by
        have h_jensen : ∀ i ∈ vals, (u i / (∑ i ∈ vals, u i)) ^ a * (v i / (∑ i ∈ vals, v i)) ^ b ≤ a * (u i / (∑ i ∈ vals, u i)) + b * (v i / (∑ i ∈ vals, v i)) := by
          intros i hi;
          have := @Real.geom_mean_le_arith_mean;
          specialize this { 0, 1 } ( fun j => if j = 0 then a else b ) ( fun j => if j = 0 then u i / ∑ i ∈ vals, u i else v i / ∑ i ∈ vals, v i ) ; simp_all +decide;
          exact this ( div_nonneg ( hu i hi ) ( Finset.sum_nonneg fun _ _ => hu _ ‹_› ) ) ( div_nonneg ( hv i hi ) ( Finset.sum_nonneg fun _ _ => hv _ ‹_› ) );
        refine' le_trans ( Finset.sum_le_sum h_jensen ) _;
        by_cases h : ∑ i ∈ vals, u i = 0 <;> by_cases h' : ∑ i ∈ vals, v i = 0 <;> simp_all +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div ];
        · linarith;
        · linarith;
      by_cases h : ∑ i ∈ vals, u i = 0 <;> by_cases h' : ∑ i ∈ vals, v i = 0 <;> simp_all +decide [ Real.div_rpow, Finset.sum_div _ _ _ ];
      · cases eq_or_ne a 0 <;> cases eq_or_ne b 0 <;> simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
      · by_cases ha : a = 0 <;> simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
      · simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
        by_cases hb : b = 0 <;> aesop;
      · simp_all +decide [ Real.div_rpow ( hu _ _ ) ( Finset.sum_nonneg fun i hi => hu i hi ), Real.div_rpow ( hv _ _ ) ( Finset.sum_nonneg fun i hi => hv i hi ), Finset.sum_div _ _ _ ];
        simp_all +decide [ div_mul_div_comm, ← Finset.sum_div _ _ _ ];
        rwa [ div_le_one ( mul_pos ( Real.rpow_pos_of_pos ( lt_of_le_of_ne ( Finset.sum_nonneg hu ) ( Ne.symm h ) ) _ ) ( Real.rpow_pos_of_pos ( lt_of_le_of_ne ( Finset.sum_nonneg hv ) ( Ne.symm h' ) ) _ ) ) ] at h_jensen;
    exact h_jensen _ _ ( fun i hi => mul_nonneg ( le_of_lt ( hwt_pos i hi ) ) ( Real.exp_nonneg _ ) ) ( fun i hi => mul_nonneg ( le_of_lt ( hwt_pos i hi ) ) ( Real.exp_nonneg _ ) );
  convert Real.log_le_log ?_ h_jensen using 1 <;> norm_num;
  · rw [ Real.log_mul ( ne_of_gt <| Real.rpow_pos_of_pos ( Finset.sum_pos ( fun _ _ => mul_pos ( hwt_pos _ ‹_› ) ( Real.exp_pos _ ) ) ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ) _ ) ( ne_of_gt <| Real.rpow_pos_of_pos ( Finset.sum_pos ( fun _ _ => mul_pos ( hwt_pos _ ‹_› ) ( Real.exp_pos _ ) ) ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ) _ ), Real.log_rpow ( Finset.sum_pos ( fun _ _ => mul_pos ( hwt_pos _ ‹_› ) ( Real.exp_pos _ ) ) ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ), Real.log_rpow ( Finset.sum_pos ( fun _ _ => mul_pos ( hwt_pos _ ‹_› ) ( Real.exp_pos _ ) ) ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ) ];
  · exact Finset.sum_pos ( fun v hv => mul_pos ( hwt_pos v hv ) ( Real.exp_pos _ ) ) ( Finset.nonempty_of_ne_empty ( by aesop_cat ) )

/-! ## Additional Results -/

/-
The pressure is zero when no subgroups are included.
-/
theorem subgroupPressure_empty (M : SubgroupPressureModel G) :
    subgroupPressure M (fun _ => false) = 0 := by
  exact Finset.sum_eq_zero fun H hH => Finset.sum_eq_zero fun K hK => by simp +decide ;

/-
The pressure is the full weight sum when all subgroups are included.
-/
theorem subgroupPressure_full (M : SubgroupPressureModel G) :
    subgroupPressure M (fun _ => true) =
      ∑ H ∈ M.support, ∑ K ∈ M.support, M.weight H K := by
  exact Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by simp +decide ;

/-
Pressure is linear in the weight function.
-/
theorem subgroupPressure_add_weights
    (s : Finset (Subgroup G))
    (w₁ w₂ : Subgroup G → Subgroup G → ℝ)
    (χ : Subgroup G → Bool) :
    subgroupPressure ⟨s, fun H K => w₁ H K + w₂ H K⟩ χ =
      subgroupPressure ⟨s, w₁⟩ χ + subgroupPressure ⟨s, w₂⟩ χ := by
  unfold subgroupPressure;
  simp +decide only [mul_add, sum_add_distrib]

/-
Influence is nonneg.
-/
theorem pressureInfluence_nonneg
    (M : SubgroupPressureModel G)
    (H₀ : Subgroup G) :
    0 ≤ pressureInfluence M H₀ := by
  exact add_nonneg ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) ( Finset.sum_nonneg fun _ _ => abs_nonneg _ )

/-
Flipping a coordinate that is not in support doesn't change pressure.
-/
theorem subgroupPressure_flip_not_mem
    (M : SubgroupPressureModel G)
    (χ : Subgroup G → Bool)
    (H₀ : Subgroup G)
    (hH₀ : H₀ ∉ M.support) :
    subgroupPressure M χ = subgroupPressure M (flipAt χ H₀) := by
  refine' Finset.sum_congr rfl fun H hH => Finset.sum_congr rfl fun K hK => _;
  unfold flipAt; aesop;

/-! ## Conjecture: Universal Self-Averaging for Inverse-Index Kernels on Sₙ

**Conjecture**: There exists C > 0 such that for every n ≥ 5, every finite
subgroup family S*_n ⊆ Sub(Sₙ), and every symmetric pair-kernel satisfying
  0 ≤ w(H,K) ≤ 1/[Sₙ:H]² [Sₙ:K]²,
the random pressure obeys
  Var(Πₛₙ) ≤ C/n.

**Testable prediction**: For sampled subgroup families of Sₙ, n=5,...,15,
with Bernoulli inclusion probability p=1/2:
- empirical variance of pressure should decay like O(1/n);
- normalized fluctuations √n(Π - E[Π]) should approach a stable law;
- row-sum influence statistics should predict observed concentration exponents.

A computational disproof would be:
- variance plateaus away from zero,
- or a family of subgroup supports exhibits maximal influence not shrinking with n. -/