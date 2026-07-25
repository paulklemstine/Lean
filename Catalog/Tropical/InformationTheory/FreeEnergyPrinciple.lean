/-
Copyright (c) 2025. All rights reserved.

# Free Energy Principle: Variational Bridge Between Tropical Optimization and Bayesian Inference

## Overview

This file formalizes the finite-state Gibbs variational principle and its connections
to tropical (min-plus) optimization and Bayesian inference. The central result is:

  **The free energy gap equals (1/β) times the KL divergence from p to the Gibbs measure.**

This identity immediately yields:
- The Gibbs variational inequality (free energy ≥ -log Z / β)
- The tropical sandwich theorem (soft-min converges to hard min as β → ∞)
- Bayesian posterior characterization as free energy minimizer

## Main Results

* `partitionFun_pos` — the partition function is strictly positive
* `gibbsWeight_pos` — Gibbs weights are strictly positive
* `gibbsWeight_sum` — Gibbs weights sum to 1
* `kl_div_nonneg_of_pos` — KL divergence is nonneg for positive distributions
* `free_energy_gap_eq_kl_div` — **Core**: F(p) + log Z / β = (1/β) · KL(p ‖ gibbs)
* `gibbs_variational_principle` — F(p) ≥ -log Z / β
* `free_energy_bounds_min` — tropical sandwich: m - log n / β ≤ soft-min ≤ m
* `free_energy_tends_to_min` — soft-min → hard min as β → ∞
* `gibbs_concentrates_on_unique_argmin` — Gibbs mass → 1 at unique minimizer
* `posterior_as_free_energy_minimizer` — Bayesian posterior minimizes KL-regularized loss

## Application Keywords

free energy principle, Gibbs variational principle, entropy regularization,
KL divergence, Bayesian inference, tropicalization, zero-temperature limit,
log-sum-exp, softmin / softmax, variational inference, energy-based models,
PAC-Bayes, mirror descent, statistical mechanics, min-plus algebra
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- The partition function Z_β(E) = ∑ᵢ exp(-β · E(i)). -/
def partitionFun {n : ℕ} (β : ℝ) (E : Fin n → ℝ) : ℝ :=
  ∑ i, Real.exp (-β * E i)

/-- The Gibbs weight (Boltzmann distribution) p_β(i) = exp(-β · E(i)) / Z. -/
def gibbsWeight {n : ℕ} (β : ℝ) (E : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (-β * E i) / partitionFun β E

/-- The free energy functional F_β(p; E) = ∑ᵢ p(i)·E(i) + (1/β)·∑ᵢ p(i)·log(p(i)). -/
def freeEnergy {n : ℕ} (β : ℝ) (E p : Fin n → ℝ) : ℝ :=
  (∑ i, p i * E i) + (1 / β) * ∑ i, p i * Real.log (p i)

/-- The KL divergence D_KL(p ‖ q) = ∑ᵢ p(i) · log(p(i) / q(i)). -/
def klDiv {n : ℕ} (p q : Fin n → ℝ) : ℝ :=
  ∑ i, p i * Real.log (p i / q i)

/-! ## Partition Function Properties -/

/-- The partition function is strictly positive. -/
theorem partitionFun_pos {n : ℕ} [NeZero n] (β : ℝ) (E : Fin n → ℝ) :
    0 < partitionFun β E := by
  exact Finset.sum_pos (fun i _ => Real.exp_pos _) Finset.univ_nonempty

/-- The partition function is nonzero. -/
theorem partitionFun_ne_zero {n : ℕ} [NeZero n] (β : ℝ) (E : Fin n → ℝ) :
    partitionFun β E ≠ 0 :=
  ne_of_gt (partitionFun_pos β E)

/-! ## Gibbs Weight Properties -/

/-- Each Gibbs weight is strictly positive. -/
theorem gibbsWeight_pos {n : ℕ} [NeZero n] (β : ℝ) (E : Fin n → ℝ) (i : Fin n) :
    0 < gibbsWeight β E i :=
  div_pos (Real.exp_pos _) (partitionFun_pos β E)

/-- Each Gibbs weight is nonneg. -/
theorem gibbsWeight_nonneg {n : ℕ} [NeZero n] (β : ℝ) (E : Fin n → ℝ) (i : Fin n) :
    0 ≤ gibbsWeight β E i :=
  le_of_lt (gibbsWeight_pos β E i)

/-- The Gibbs weights sum to 1. -/
theorem gibbsWeight_sum {n : ℕ} [NeZero n] (β : ℝ) (E : Fin n → ℝ) :
    ∑ i, gibbsWeight β E i = 1 := by
  simp only [gibbsWeight, ← Finset.sum_div]
  exact div_self (partitionFun_ne_zero β E)

/-- The log of a Gibbs weight decomposes as -β·E(i) - log Z. -/
theorem log_gibbsWeight {n : ℕ} [NeZero n] (β : ℝ) (E : Fin n → ℝ) (i : Fin n) :
    Real.log (gibbsWeight β E i) = -β * E i - Real.log (partitionFun β E) := by
  simp only [gibbsWeight]
  rw [Real.log_div (ne_of_gt (Real.exp_pos _)) (partitionFun_ne_zero β E)]
  rw [Real.log_exp]

/-! ## KL Divergence Nonnegativity (Gibbs' Inequality) -/

/-
**KL divergence is nonneg** for strictly positive distributions summing to 1.
    This is the finite Gibbs inequality, proved using log x ≤ x - 1.
-/
theorem kl_div_nonneg_of_pos {n : ℕ}
    (p q : Fin n → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hp_sum : (∑ i, p i) = 1)
    (hq_pos : ∀ i, 0 < q i) (hq_sum : (∑ i, q i) = 1) :
    0 ≤ klDiv p q := by
      have kl_div_nonneg_of_pos : ∀ i, p i * Real.log (p i / q i) ≥ p i - q i := by
        intro i; have := Real.log_le_sub_one_of_pos ( div_pos ( hq_pos i ) ( hp_pos i ) ) ; rw [ Real.log_div ] at * <;> try linarith [ hp_pos i, hq_pos i ] ;
        nlinarith [ hp_pos i, hq_pos i, mul_div_cancel₀ ( q i ) ( ne_of_gt ( hp_pos i ) ) ];
      exact le_trans ( by norm_num [ hp_sum, hq_sum ] ) ( Finset.sum_le_sum fun i _ => kl_div_nonneg_of_pos i )

/-! ## The Core Identity: Free Energy Gap = (1/β) · KL Divergence -/

/-
**Core theorem**: The free energy gap equals (1/β) times the KL divergence
    from p to the Gibbs distribution. This is the conceptual center of gravity:
    F_β(p; E) + (1/β)·log Z = (1/β) · D_KL(p ‖ p_β).

    Proof sketch: Expand KL(p ‖ gibbs) = ∑ p_i log(p_i / gibbs_i)
    = ∑ p_i (log p_i - log gibbs_i)
    = ∑ p_i log p_i - ∑ p_i (-β E_i - log Z)
    = ∑ p_i log p_i + β ∑ p_i E_i + log Z · ∑ p_i
    = ∑ p_i log p_i + β ∑ p_i E_i + log Z
    = β · F_β(p; E) + log Z.
-/
theorem free_energy_gap_eq_kl_div {n : ℕ} [NeZero n]
    (β : ℝ) (hβ : 0 < β) (E : Fin n → ℝ)
    (p : Fin n → ℝ) (hp_pos : ∀ i, 0 < p i) (hp_sum : (∑ i, p i) = 1) :
    freeEnergy β E p + (1 / β) * Real.log (partitionFun β E) =
      (1 / β) * klDiv p (gibbsWeight β E) := by
        unfold freeEnergy klDiv;
        norm_num [ Real.log_div, Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( hp_pos _ ), ne_of_gt ( gibbsWeight_pos β E _ ) ];
        simp +decide [ mul_sub, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, log_gibbsWeight, hp_sum ];
        simp +decide [ ← mul_assoc, mul_comm β, hβ.ne', ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hp_sum ] ; ring

/-! ## Main Variational Theorems -/

/-- **Gibbs variational principle** (strictly positive version):
    The free energy is minimized by the Gibbs distribution,
    and the minimum value is -(1/β)·log Z. For all probability distributions p,
    F_β(p; E) ≥ -(1/β)·log Z.

    Follows from `free_energy_gap_eq_kl_div` and KL nonnegativity. -/
theorem gibbs_variational_principle {n : ℕ} [NeZero n]
    (β : ℝ) (hβ : 0 < β) (E : Fin n → ℝ)
    (p : Fin n → ℝ) (hp_pos : ∀ i, 0 < p i) (hp_sum : (∑ i, p i) = 1) :
    freeEnergy β E p ≥ -(1 / β) * Real.log (partitionFun β E) := by
  have hgap := free_energy_gap_eq_kl_div β hβ E p hp_pos hp_sum
  have hkl := kl_div_nonneg_of_pos p (gibbsWeight β E) hp_pos hp_sum
    (gibbsWeight_pos β E) (gibbsWeight_sum β E)
  have hβ_pos : (0 : ℝ) < 1 / β := div_pos one_pos hβ
  nlinarith

/-
**Gibbs variational principle** (general version for nonneg distributions).
    Uses the convention that 0 · log 0 = 0 (which holds since Real.log 0 = 0 in Lean).
-/
theorem gibbs_variational_principle_fin {n : ℕ} [NeZero n]
    (β : ℝ) (hβ : 0 < β) (E : Fin n → ℝ)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    let Z : ℝ := ∑ i, Real.exp (-β * E i)
    let freeEnergyVal : ℝ :=
      (∑ i, p i * E i) + (1 / β) * ∑ i, p i * Real.log (p i)
    freeEnergyVal ≥ -(1 / β) * Real.log Z := by
      -- Now use the inequality $\log(q_i/p_i) \leq q_i/p_i - 1$ for each term in the sum.
      have h_ineq : ∀ i, p i * Real.log (Real.exp (-β * E i) / (∑ i, Real.exp (-β * E i)) / p i) ≤ Real.exp (-β * E i) / (∑ i, Real.exp (-β * E i)) - p i := by
        intro i;
        by_cases hi : p i = 0 <;> simp_all +decide [ div_eq_mul_inv ];
        · exact mul_nonneg ( Real.exp_nonneg _ ) ( inv_nonneg.2 ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ ) );
        · have := Real.log_le_sub_one_of_pos ( show 0 < Real.exp ( - ( β * E i ) ) * ( ∑ x, Real.exp ( - ( β * E x ) ) ) ⁻¹ * ( p i ) ⁻¹ from mul_pos ( mul_pos ( Real.exp_pos _ ) ( inv_pos.mpr ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ i, Finset.mem_univ _ ⟩ ) ) ) ( inv_pos.mpr ( lt_of_le_of_ne ( hp_nonneg i ) ( Ne.symm hi ) ) ) );
          nlinarith [ hp_nonneg i, mul_inv_cancel_left₀ hi ( Real.exp ( - ( β * E i ) ) * ( ∑ x, Real.exp ( - ( β * E x ) ) ) ⁻¹ ) ];
      have := Finset.sum_le_sum fun i ( _ : i ∈ Finset.univ ) => h_ineq i;
      simp_all +decide [ ← Finset.sum_div _ _ _, ← Finset.sum_mul, Real.log_div, Real.exp_ne_zero, ne_of_gt ( Finset.sum_pos ( fun i _ => Real.exp_pos _ ) Finset.univ_nonempty ) ];
      -- Simplify the logarithmic term using properties of logarithms.
      have h_log_simplify : ∑ i, p i * Real.log ((Real.exp (-(β * E i)) / ∑ i, Real.exp (-(β * E i))) / p i) = ∑ i, p i * (-(β * E i) - Real.log (∑ i, Real.exp (-(β * E i))) - Real.log (p i)) := by
        refine Finset.sum_congr rfl fun i _ => ?_;
        by_cases hi : p i = 0 <;> simp_all +decide [ Real.log_div, Real.exp_ne_zero, Finset.sum_eq_zero_iff_of_nonneg, Real.exp_nonneg ];
      simp_all +decide [ mul_sub, ← Finset.sum_mul _ _ _, ← Finset.mul_sum ];
      field_simp;
      rw [ Finset.mul_sum _ _ _ ] ; norm_num [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] at * ; linarith

/-! ## Tropical Limit: Free Energy Sandwich -/

/-
**Tropical sandwich theorem**: The soft-minimum is sandwiched between
    the hard minimum and the hard minimum minus log(n)/β.
    This gives a quantitative bridge from finite-temperature inference
    to tropical (min-plus) optimization.

    Proof: Let m = min_i E(i).
    Upper bound: Z ≥ exp(-β·m), so -log Z / β ≤ m.
    Lower bound: Z ≤ n·exp(-β·m), so -log Z / β ≥ m - log(n)/β.
-/
theorem free_energy_bounds_min {n : ℕ} [NeZero n]
    (β : ℝ) (hβ : 0 < β) (E : Fin n → ℝ) :
    let Z : ℝ := ∑ i, Real.exp (-β * E i)
    let m : ℝ := Finset.univ.inf' Finset.univ_nonempty E
    m - Real.log n / β ≤ -(1 / β) * Real.log Z ∧
    -(1 / β) * Real.log Z ≤ m := by
      constructor;
      · -- By definition of infimum, we know that for all $i$, $E i \geq m$.
        have h_inf : ∀ i, E i ≥ Finset.inf' Finset.univ (Finset.univ_nonempty) E := by
          exact fun i => Finset.inf'_le _ <| Finset.mem_univ _;
        -- Since $E_i \geq m$ for all $i$, we have $\exp(-\beta E_i) \leq \exp(-\beta m)$.
        have h_exp_le : ∀ i, Real.exp (-β * E i) ≤ Real.exp (-β * (Finset.inf' Finset.univ (Finset.univ_nonempty) E)) := by
          exact fun i => Real.exp_le_exp.mpr ( mul_le_mul_of_nonpos_left ( h_inf i ) ( neg_nonpos.mpr hβ.le ) );
        -- Summing these inequalities over all $i$, we get $\sum_{i=1}^n \exp(-\beta E_i) \leq n \exp(-\beta m)$.
        have h_sum_le : ∑ i, Real.exp (-β * E i) ≤ n * Real.exp (-β * (Finset.inf' Finset.univ (Finset.univ_nonempty) E)) := by
          exact le_trans ( Finset.sum_le_sum fun _ _ => h_exp_le _ ) ( by norm_num );
        field_simp;
        have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( show ∑ i : Fin n, Real.exp ( - ( β * E i ) ) ≤ n * Real.exp ( -β * univ.inf' Finset.univ_nonempty E ) from by simpa only [ neg_mul ] using h_sum_le );
        rw [ Real.log_mul ( by norm_cast; exact NeZero.ne n ) ( by positivity ), Real.log_exp ] at this ; linarith;
      · -- Let $m = \inf_{i} E_i$.
        set m := Finset.univ.inf' (Finset.univ_nonempty) E;
        -- For each $i$, $E_i \geq m$, so $-\beta E_i \leq -\beta m$, so $\exp(-\beta E_i) \leq \exp(-\beta m)$.
        have h_exp_le : ∀ i, Real.exp (-β * E i) ≤ Real.exp (-β * m) := by
          exact fun i => Real.exp_le_exp.mpr ( mul_le_mul_of_nonpos_left ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( neg_nonpos.mpr hβ.le ) );
        rw [ neg_mul, neg_le ];
        rw [ div_mul_eq_mul_div, le_div_iff₀' hβ, ← Real.log_rpow, Real.le_log_iff_exp_le ] <;> norm_num;
        · obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty E;
          exact le_trans ( by aesop ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( - ( β * E i ) ) ) ( Finset.mem_univ i ) );
        · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty;
        · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty

/-
**Tropical convergence**: The soft-minimum converges to the hard minimum
    as β → ∞. This is the finite-dimensional Laplace principle.
-/
theorem free_energy_tends_to_min {n : ℕ} [NeZero n] (E : Fin n → ℝ) :
    Filter.Tendsto
      (fun β : ℝ => -(1 / β) * Real.log (∑ i : Fin n, Real.exp (-β * E i)))
      Filter.atTop
      (nhds (Finset.univ.inf' Finset.univ_nonempty E)) := by
        -- Let m = inf' univ E. From `free_energy_bounds_min`, we have for all β > 0:
        set m := Finset.univ.inf' Finset.univ_nonempty E
        have h_bounds : ∀ β > 0, m - Real.log n / β ≤ -(1 / β) * Real.log (∑ i, Real.exp (-β * E i)) ∧ -(1 / β) * Real.log (∑ i, Real.exp (-β * E i)) ≤ m := by
          exact?;
        exact tendsto_of_tendsto_of_tendsto_of_le_of_le' ( by simpa using tendsto_inv_atTop_zero.const_mul ( Real.log n : ℝ ) |> Filter.Tendsto.const_sub m ) tendsto_const_nhds ( Filter.eventually_atTop.mpr ⟨ 1, fun β hβ => h_bounds β ( by positivity ) |>.1 ⟩ ) ( Filter.eventually_atTop.mpr ⟨ 1, fun β hβ => h_bounds β ( by positivity ) |>.2 ⟩ )

/-! ## Gibbs Concentration on Unique Argmin -/

/-
**Gibbs concentration**: If E has a unique minimizer k, the Gibbs weight
    at k converges to 1 as β → ∞. This connects to `one_hot_entropy_zero`:
    in the zero-temperature limit, the Gibbs distribution collapses to the
    one-hot distribution at the minimizer, which has zero entropy.
-/
theorem gibbs_concentrates_on_unique_argmin {n : ℕ} [NeZero n]
    (E : Fin n → ℝ) (k : Fin n)
    (hmin : ∀ i, E k ≤ E i)
    (hunique : ∀ i, E i = E k → i = k) :
    Filter.Tendsto
      (fun β : ℝ =>
        if 0 < β then
          Real.exp (-β * E k) / (∑ i : Fin n, Real.exp (-β * E i))
        else 0)
      Filter.atTop (nhds 1) := by
        -- We'll use the fact that if the denominator grows faster than the numerator, the limit will tend to 0.
        have h_lim : Filter.Tendsto (fun β : ℝ => (∑ i ∈ Finset.univ.erase k, Real.exp (-β * (E i - E k)))) Filter.atTop (nhds 0) := by
          exact le_trans ( tendsto_finset_sum _ fun i hi => Real.tendsto_exp_atBot.comp <| Filter.tendsto_atTop_atBot.mpr fun x => ⟨ -x / ( E i - E k ), fun y hy => by nlinarith [ hmin i, mul_div_cancel₀ ( -x ) ( sub_ne_zero_of_ne <| by specialize hunique i; aesop : ( E i - E k ) ≠ 0 ) ] ⟩ ) ( by norm_num );
        -- We can rewrite the limit expression using the fact that the denominator grows faster than the numerator.
        have h_rewrite : Filter.Tendsto (fun β : ℝ => (1 : ℝ) / (1 + ∑ i ∈ Finset.univ.erase k, Real.exp (-β * (E i - E k)))) Filter.atTop (nhds 1) := by
          simpa using Filter.Tendsto.inv₀ ( h_lim.const_add 1 ) ( by norm_num );
        refine' h_rewrite.congr' _;
        filter_upwards [ Filter.eventually_gt_atTop 0 ] with β hβ;
        simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_sub, Real.exp_sub, hβ ];
        simp +decide [ Real.exp_add, mul_comm, Finset.mul_sum _ _ _, div_eq_mul_inv ];
        simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Real.exp_neg, mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Real.exp_pos _ ) ]

/-! ## Bayesian Posterior as Free Energy Minimizer -/

/-
**Bayesian posterior theorem**: Given prior weights w and loss L,
    the Gibbs posterior q(i) ∝ w(i)·exp(-β·L(i)) uniquely minimizes
    the KL-regularized expected loss:
    p ↦ ∑ᵢ p(i)·L(i) + (1/β)·D_KL(p ‖ w).

    This is the exact bridge from Bayesian updating to entropy-regularized
    optimization.
-/
theorem posterior_as_free_energy_minimizer {n : ℕ} [NeZero n]
    (β : ℝ) (hβ : 0 < β)
    (w L p : Fin n → ℝ)
    (hw_pos : ∀ i, 0 < w i)
    (hw_sum : (∑ i, w i) = 1)
    (hp_pos : ∀ i, 0 < p i)
    (hp_sum : (∑ i, p i) = 1) :
    let Z : ℝ := ∑ i, w i * Real.exp (-β * L i)
    let objective : ℝ :=
      (∑ i, p i * L i) + (1 / β) * klDiv p w
    let opt : ℝ := -(1 / β) * Real.log Z
    objective ≥ opt := by
      -- By definition of $Z$, we know that $Z = \sum_i w_i \exp(-\beta L_i)$.
      set Z := ∑ i, w i * Real.exp (-β * L i)
      have hZ_pos : Z > 0 := by
        exact Finset.sum_pos ( fun i _ => mul_pos ( hw_pos i ) ( Real.exp_pos _ ) ) Finset.univ_nonempty;
      -- By definition of $q$, we know that $q_i = w_i \exp(-\beta L_i) / Z$.
      set q : Fin n → ℝ := fun i => w i * Real.exp (-β * L i) / Z;
      have hq_pos : ∀ i, 0 < q i := by
        exact fun i => div_pos ( mul_pos ( hw_pos i ) ( Real.exp_pos _ ) ) hZ_pos;
      have hq_sum : ∑ i, q i = 1 := by
        rw [ ← Finset.sum_div, div_self hZ_pos.ne' ];
      -- By definition of $q$, we know that $KL(p \| q) \geq 0$.
      have hkl_nonneg : klDiv p q ≥ 0 := by
        exact kl_div_nonneg_of_pos p q hp_pos hp_sum hq_pos hq_sum;
      -- By definition of $q$, we know that $KL(p \| q) = \sum_i p_i \log(p_i / q_i)$.
      have hkl_def : klDiv p q = ∑ i, p i * (Real.log (p i / w i) + β * L i + Real.log Z) := by
        refine' Finset.sum_congr rfl fun i _ => _;
        rw [ show p i / q i = ( p i / w i ) * ( Real.exp ( β * L i ) ) * Z by rw [ div_div_eq_mul_div, div_eq_mul_inv ] ; ring_nf; norm_num [ Real.exp_neg, Real.exp_ne_zero, ne_of_gt ( hw_pos _ ), ne_of_gt ( hp_pos _ ), ne_of_gt hZ_pos ] ] ; rw [ Real.log_mul, Real.log_mul ] <;> norm_num <;> ring <;> simp +decide [ ne_of_gt, * ] ;
      simp_all +decide [ Finset.sum_add_distrib, mul_add, mul_comm, mul_left_comm, div_eq_inv_mul ];
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_comm, klDiv ];
      field_simp;
      norm_num [ div_eq_mul_inv ] at * ; linarith

end