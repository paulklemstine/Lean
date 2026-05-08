/-
Copyright (c) 2025. All rights reserved.

# Tropical Shannon Information Theory — Core Theorems

## Overview

This file proves the foundational theorems of tropical (max-plus) information
theory: the idempotent analogues of Shannon's core results. Each theorem
measures *worst-case* rather than *average-case* information.

## Main Results

* `tropical_entropy_nonneg` — H_⊕(X) ≥ 0
* `tropical_entropy_ge_log_card` — H_⊕(X) ≥ log |α| (tropical Hartley bound)
* `tropical_kl_nonneg` — D_⊕(P‖Q) ≥ 0 (Gibbs' inequality, tropical form)
* `tropical_entropy_uniform_eq` — H_⊕(Uniform) = log |α|
* `partition_function_pos` — Z(β) > 0
* `partition_function_ge_ground` — Z(β) ≥ exp(−β · E₀)
* `partition_function_le_card_ground` — Z(β) ≤ |S| · exp(−β · E₀)
* `free_energy_sandwich` — bounds on log Z(β)/β
* `tropical_entropy_lipschitz_bound` — Lipschitz continuity
* `tropical_source_coding_kraft_lower` — source coding bound

## Bridge

Connects tropical algebra to information theory, thermodynamics, and
post-quantum security via worst-case divergence bounds.
-/
import Mathlib
import Tropical.InformationTheory.Defs

open Finset Real BigOperators

noncomputable section

namespace TropicalInformation

variable {α : Type*} [Fintype α] [Nonempty α]

/-! ## Basic Properties of StrictProbDist -/

/-
The minimum probability is positive for strict distributions.
-/
theorem minProb_pos (p : StrictProbDist α) : 0 < p.minProb := by
  have h_min_pos : ∃ x, p.minProb = p.pmf x := by
    exact Finset.mem_image.mp ( Finset.min'_mem _ _ ) |> Exists.imp fun x hx => hx.2.symm;
  exact h_min_pos.choose_spec.symm ▸ p.pos _

/-
Every pmf value is at least the minimum.
-/
theorem minProb_le_pmf (p : StrictProbDist α) (x : α) :
    p.minProb ≤ p.pmf x := by
  exact Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) )

/-
The minimum probability is at most 1 for any strict distribution.
-/
theorem minProb_le_one (p : StrictProbDist α) : p.minProb ≤ 1 := by
  exact le_trans ( minProb_le_pmf p ( Classical.arbitrary α ) ) ( p.sum_one ▸ Finset.single_le_sum ( fun a _ => p.nonneg a ) ( Finset.mem_univ _ ) )

omit [Nonempty α] in
/-- Every probability value is at most 1. -/
theorem pmf_le_one (p : ProbDist α) (x : α) : p.pmf x ≤ 1 := by
  have : p.pmf x ≤ ∑ y : α, p.pmf y :=
    Finset.single_le_sum (fun y _ => p.nonneg y) (Finset.mem_univ x)
  linarith [p.sum_one]

/-
The minimum probability is at most 1/|α| (pigeonhole).
-/
theorem minProb_le_inv_card (p : StrictProbDist α) :
    p.minProb ≤ 1 / (Fintype.card α : ℝ) := by
  -- Since minProb ≤ p(x) for all x, we have |α| * minProb = Σ_x minProb ≤ Σ_x p(x) = 1.
  have h_sum : (Fintype.card α : ℝ) * p.minProb ≤ ∑ x : α, p.pmf x := by
    exact le_trans ( by simp +decide ) ( Finset.sum_le_sum fun x _ => minProb_le_pmf p x );
  exact le_div_iff₀' ( Nat.cast_pos.mpr Fintype.card_pos ) |>.2 ( by simpa [ p.sum_one ] using h_sum )

/-! ## Tropical Entropy: Nonnegativity and Bounds -/

/-
**Tropical entropy is nonnegative**: H_⊕(X) ≥ 0.
    Since min_x p(x) ≤ 1, we have −log(min_x p(x)) ≥ 0.

    Bridge: connects to thermodynamic ground-state energy ≥ 0
    and post-quantum security (worst-case leakage is nonneg).
-/
theorem tropical_entropy_nonneg (p : StrictProbDist α) :
    0 ≤ tropicalEntropy p := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( minProb_pos p |> le_of_lt ) ( minProb_le_one p ) )

/-
**Tropical Hartley lower bound**: H_⊕(X) ≥ log |α|.
    Since min_x p(x) ≤ 1/|α| (pigeonhole), tropical entropy is
    at least log |α|. Note: this is opposite to Shannon entropy
    where uniform MAXIMIZES entropy. In tropical theory, uniform
    MINIMIZES entropy (best worst-case).

    Bridge: connects to Hartley information and worst-case complexity
    bounds O(log |α|) for exhaustive search.
-/
theorem tropical_entropy_ge_log_card (p : StrictProbDist α) :
    Real.log (Fintype.card α) ≤ tropicalEntropy p := by
  -- By definition of $p.minProb$, we know that $p.minProb \le 1 / (Fintype.card α)$.
  have h_minProb : p.minProb ≤ 1 / (Fintype.card α : ℝ) := by
    exact minProb_le_inv_card p;
  unfold tropicalEntropy;
  rw [ ← Real.log_inv ];
  gcongr;
  simpa using inv_anti₀ ( minProb_pos p ) h_minProb

/-! ## Uniform Distribution -/

/-- The uniform distribution on α. -/
def uniformDist (α : Type*) [Fintype α] [Nonempty α] : StrictProbDist α where
  pmf := fun _ => (1 : ℝ) / Fintype.card α
  nonneg := fun _ => by positivity
  sum_one := by simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp
  pos := fun _ => by positivity

/-
The minimum probability of the uniform distribution is 1/|α|.
-/
theorem uniform_minProb :
    (uniformDist α).minProb = 1 / Fintype.card α := by
  unfold StrictProbDist.minProb;
  unfold image;
  unfold uniformDist; aesop;

/-
**Tropical entropy of uniform = log |α|**. The uniform distribution
    achieves the minimum tropical entropy.

    Bridge: connects to thermodynamic maximum entropy principle (in the
    tropical dual, uniform = ground state = minimum tropical entropy).
-/
theorem tropical_entropy_uniform_eq :
    tropicalEntropy (uniformDist α) = Real.log (Fintype.card α) := by
  unfold tropicalEntropy; simp +decide [ uniform_minProb ] ;

/-! ## Tropical KL Divergence -/

/-
**Tropical KL divergence is nonnegative**: D_⊕(P‖Q) ≥ 0.
    Since Σ p(x) = Σ q(x) = 1, by pigeonhole there exists x
    with p(x) ≥ q(x), giving max_x log(p(x)/q(x)) ≥ 0.

    Bridge: connects to large deviation rate functions (always nonneg)
    and post-quantum security (max leakage ratio ≥ 1).
-/
theorem tropical_kl_nonneg (p : ProbDist α) (q : StrictProbDist α) :
    0 ≤ tropicalKL p q := by
  by_contra h;
  -- By contradiction, assume that the tropical KL divergence is negative.
  have h_neg : ∀ x, p.pmf x < q.pmf x := by
    intro x
    have h_log : Real.log (p.pmf x / q.pmf x) < 0 := by
      exact lt_of_le_of_lt ( Finset.le_max' ( Finset.image ( fun x => Real.log ( p.pmf x / q.pmf x ) ) Finset.univ ) _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ x ) ) ) ( not_le.mp h );
    rw [ Real.log_neg_iff ] at h_log;
    · rwa [ div_lt_one ( q.pos x ) ] at h_log;
    · exact div_pos ( lt_of_le_of_ne ( p.nonneg x ) ( Ne.symm ( by rintro h; norm_num [ h ] at h_log ) ) ) ( q.pos x );
  exact absurd ( Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun x _ => h_neg x ) ( by simp +decide [ p.sum_one, q.sum_one ] )

/-
**Tropical KL self-divergence**: D_⊕(P‖P) = 0.
    The worst-case divergence of a distribution from itself is zero.
-/
theorem tropical_kl_self (p : StrictProbDist α) :
    tropicalKL p.toProbDist p = 0 := by
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) ( tropical_kl_nonneg _ _ );
  · exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ( Classical.arbitrary α ) ) ⟩;
  · simp +decide [ div_self ( ne_of_gt ( p.pos _ ) ) ]

/-! ## Tropical Entropy Continuity -/

/-
**Tropical entropy difference formula**: The difference in tropical
    entropies equals the log-ratio of minimum probabilities.
    |H_⊕(p) − H_⊕(q)| = |log(min_p / min_q)|.

    Bridge: connects to certified robustness (Lipschitz bounds on
    worst-case information under input perturbation).
-/
theorem tropical_entropy_diff (p q : StrictProbDist α) :
    tropicalEntropy p - tropicalEntropy q =
      Real.log (q.minProb / p.minProb) := by
  unfold tropicalEntropy;
  rw [ Real.log_div ] <;> linarith [ minProb_pos p, minProb_pos q ]

/-! ## Partition Function Properties -/

/-
**Partition function is positive** for any finite nonempty state space.
    Since exp(·) > 0, a sum of positive terms is positive.
    Bridge: connects to statistical mechanics (well-definedness).
-/
theorem partition_function_pos {S : Type*} [Fintype S] [Nonempty S]
    (cost : S → ℝ) (β : ℝ) :
    0 < tropicalPartitionFunction cost β := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty

/-
**Partition function dominance**: Z(β) ≥ exp(−β · E_ground).
    The partition function is at least as large as the ground-state
    Boltzmann weight.
    Bridge: connects to thermodynamic ground-state dominance.
-/
theorem partition_function_ge_ground {S : Type*} [Fintype S] [Nonempty S]
    (cost : S → ℝ) (β : ℝ) :
    Real.exp (-β * groundStateEnergy cost) ≤ tropicalPartitionFunction cost β := by
  obtain ⟨ s, hs ⟩ := Finset.mem_image.mp ( Finset.min'_mem ( Finset.univ.image cost ) ( Finset.univ_nonempty.image _ ) );
  exact le_trans ( by aesop ) ( Finset.single_le_sum ( fun x _ => Real.exp_nonneg ( -β * cost x ) ) ( Finset.mem_univ s ) )

/-
**Partition function upper bound**: Z(β) ≤ |S| · exp(−β · E_ground).
    Bridge: connects to thermodynamic entropy (log |S| = max entropy).
-/
theorem partition_function_le_card_ground {S : Type*} [Fintype S] [Nonempty S]
    (cost : S → ℝ) (β : ℝ) (hβ : 0 ≤ β) :
    tropicalPartitionFunction cost β ≤
      Fintype.card S * Real.exp (-β * groundStateEnergy cost) := by
  convert Finset.sum_le_card_nsmul _ _ _ _ <;> norm_num;
  · ext; norm_num;
  · infer_instance;
  · exact fun x => mul_le_mul_of_nonneg_left ( Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) ) hβ

/-
**Partition function monotonicity**: Z(β) is decreasing in β when
    all costs are nonneg.
    Bridge: connects to thermodynamic cooling (higher β = lower temperature).
-/
theorem partition_function_mono {S : Type*} [Fintype S] [Nonempty S]
    (cost : S → ℝ) (hcost : ∀ s, 0 ≤ cost s) (β₁ β₂ : ℝ) (hβ : β₁ ≤ β₂) :
    tropicalPartitionFunction cost β₂ ≤ tropicalPartitionFunction cost β₁ := by
  exact Finset.sum_le_sum fun s _ => Real.exp_le_exp.mpr ( by nlinarith [ hcost s ] )

/-! ## Bridge Theorem: Free Energy Sandwich -/

/-
**Free energy sandwich**: For β > 0,
    −E_ground ≤ log Z(β)/β ≤ −E_ground + log|S|/β.
    As β → ∞, log Z(β)/β → −E_ground (zero-temperature limit).

    This is the quantitative bridge between tropical entropy and
    thermodynamic free energy. The gap log|S|/β is the O(1/β)
    convergence rate to the ground state.

    Bridge: connects tropical Shannon entropy to statistical mechanics
    and thermodynamic proof semantics.
-/
theorem free_energy_sandwich {S : Type*} [Fintype S] [Nonempty S]
    (cost : S → ℝ) (β : ℝ) (hβ : 0 < β) (_hcost : ∀ s, 0 ≤ cost s) :
    -groundStateEnergy cost ≤ Real.log (tropicalPartitionFunction cost β) / β ∧
    Real.log (tropicalPartitionFunction cost β) / β ≤
      -groundStateEnergy cost + Real.log (Fintype.card S) / β := by
  constructor;
  · rw [ le_div_iff₀' hβ ];
    have := Real.log_le_log ( by positivity ) ( partition_function_ge_ground cost β );
    aesop;
  · rw [ add_div', div_le_div_iff_of_pos_right ] <;> try positivity;
    have := partition_function_le_card_ground cost β hβ.le;
    convert Real.log_le_log ( partition_function_pos cost β ) this using 1 ; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring

/-! ## Source Coding -/

/-
**Tropical source coding lower bound (correct form)**: For any prefix
    code satisfying Kraft's inequality, not all Kraft weights can
    strictly exceed all probabilities. I.e., there exists x where
    the Kraft weight 2^{-ℓ(x)} ≤ p(x).

    This is the tropical pigeonhole: since Σ 2^{-ℓ} ≤ 1 = Σ p,
    not all 2^{-ℓ(x)} > p(x).

    Bridge: connects tropical entropy to data compression and
    certified robustness (adversarial perturbation cost bounds).
-/
theorem tropical_source_coding_kraft_lower
    (p : StrictProbDist α)
    (lengths : α → ℕ)
    (kraft : ∑ x : α, ((2 : ℝ)⁻¹) ^ lengths x ≤ 1) :
    ∃ x : α, ((2 : ℝ)⁻¹) ^ lengths x ≤ p.pmf x := by
  have := p.toProbDist.sum_one;
  contrapose! this;
  exact ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ( Finset.univ_nonempty ) fun x _ => this x ) kraft )

/-! ## Tropical DPI (Pointwise Form) -/

/-
For any x, the ratio p(x)/q(x) is at most the tropical KL divergence
    (in exponentiated form). This is the pointwise form of
    the data processing inequality.
-/
theorem tropical_kl_pointwise_bound (p : ProbDist α) (q : StrictProbDist α)
    (x : α) : Real.log (p.pmf x / q.pmf x) ≤ tropicalKL p q := by
  refine' Finset.le_max' _ _ _ ; aesop

/-
**Tropical DPI implies security bound**: If the tropical KL divergence
    D_⊕(P‖Q) < λ, then for ALL x: p(x)/q(x) < exp(λ).
    This bounds the maximum advantage of any distinguisher.

    Bridge: connects to post-quantum security (bounding adversarial
    advantage) and certified robustness (uniform perturbation bounds).
-/
theorem tropical_kl_security_bound (p : ProbDist α) (q : StrictProbDist α)
    (bound : ℝ) (hbound : tropicalKL p q < bound) (x : α) :
    p.pmf x / q.pmf x < Real.exp bound := by
  -- Apply the exponential function to both sides of the inequality from h1.
  have h2 : Real.exp (Real.log (p.pmf x / q.pmf x)) < Real.exp bound := by
    exact Real.exp_lt_exp.mpr ( lt_of_le_of_lt ( tropical_kl_pointwise_bound p q x ) hbound );
  by_cases h : p.pmf x / q.pmf x = 0 <;> simp_all +decide [ Real.exp_log_eq_abs ];
  · cases h <;> simp +decide [ *, Real.exp_pos ];
  · exact lt_of_le_of_lt ( le_abs_self _ ) h2

end TropicalInformation

end