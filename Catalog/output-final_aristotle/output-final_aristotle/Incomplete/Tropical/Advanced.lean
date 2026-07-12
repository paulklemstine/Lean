/-
Copyright (c) 2025. All rights reserved.

# Tropical Shannon Information Theory — Advanced Theorems

## Overview

This file extends the core tropical information theory with advanced results:
Boltzmann distribution properties, the bridge to thermodynamic free energy,
quantitative convergence rates, and tropical DPI for deterministic maps.

## Main Results

* `boltzmann_sum_one` — Boltzmann distribution sums to 1
* `boltzmann_pos` — Boltzmann probabilities are positive
* `boltzmann_minProb_eq` — MinProb of Boltzmann = exp(-β·max_cost)/Z
* `tropical_entropy_boltzmann` — H_⊕ of Boltzmann = β·E_max + log Z
* `free_energy_convergence_rate` — O(log|S|/β) convergence rate
* `tropical_kl_symmetrized_nonneg` — Symmetrized divergence ≥ 0
* `tropical_kl_antisymmetric_bound` — D_⊕(P‖Q) ≥ −D_⊕(Q‖P)
* `tropical_entropy_search_bound` — 1/minProb = exp(H_⊕)
* `tropical_kl_exp_eq_max_ratio` — exp(D_⊕) = max ratio
* `pushforward_tropicalKL_le` — DPI for deterministic channels
* `tropical_entropy_product` — H_⊕(p⊗q) = H_⊕(p) + H_⊕(q)

## Bridge

Connects tropical algebra, thermodynamics, information theory, and
post-quantum security via worst-case divergence bounds.
-/
import Mathlib
import Logic.Defs
import Novelty.Core

open Finset Real BigOperators Classical

noncomputable section

namespace TropicalInformation

/-! ## Boltzmann Distribution Properties -/

variable {S : Type*} [Fintype S] [Nonempty S]

/-
The Boltzmann distribution sums to 1.
-/
theorem boltzmann_sum_one (cost : S → ℝ) (β : ℝ) :
    ∑ s : S, boltzmannDist cost β (partition_function_pos cost β) s = 1 := by
  unfold boltzmannDist;
  rw [ ← Finset.sum_div _ _ _, tropicalPartitionFunction, div_self ];
  exact ne_of_gt ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty )

/-
Each Boltzmann probability is positive.
-/
theorem boltzmann_pos (cost : S → ℝ) (β : ℝ) (s : S) :
    0 < boltzmannDist cost β (partition_function_pos cost β) s := by
  exact div_pos ( Real.exp_pos _ ) ( partition_function_pos cost β )

/-- The Boltzmann distribution as a StrictProbDist.
    Bridge: connects statistical mechanics to information theory. -/
def boltzmannStrictProbDist (cost : S → ℝ) (β : ℝ) : StrictProbDist S where
  pmf := boltzmannDist cost β (partition_function_pos cost β)
  nonneg := fun s => le_of_lt (boltzmann_pos cost β s)
  sum_one := boltzmann_sum_one cost β
  pos := boltzmann_pos cost β

/-! ## Tropical Entropy of Boltzmann -/

/-
**Tropical entropy of Boltzmann**: H_⊕(p_β) = β · E_max + log Z(β)
    where E_max is the maximum cost. This quantifies how tropical entropy
    scales linearly with inverse temperature.

    Bridge: connects tropical information theory to statistical mechanics
    and thermodynamic proof semantics (entropy = β·E + log Z).
-/
theorem tropical_entropy_boltzmann (cost : S → ℝ) (β : ℝ) (hβ : 0 ≤ β) :
    tropicalEntropy (boltzmannStrictProbDist cost β) =
      β * Finset.max' (Finset.univ.image cost)
        (by simp [Finset.image_nonempty]) +
      Real.log (tropicalPartitionFunction cost β) := by
  unfold tropicalEntropy boltzmannStrictProbDist;
  unfold boltzmannDist;
  have h_minProb : (Finset.min' (Finset.univ.image (fun s => Real.exp (-β * cost s) / tropicalPartitionFunction cost β)) (by
  exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ( Classical.arbitrary S ) ) ⟩)) = Real.exp (-β * (Finset.max' (Finset.univ.image cost) (by
  exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ( Classical.arbitrary S ) ) ⟩))) / tropicalPartitionFunction cost β := by
    refine' le_antisymm _ _ <;> simp +decide [ Finset.min', Finset.max' ];
    · obtain ⟨ s, hs ⟩ := Finset.exists_max_image Finset.univ ( fun x => cost x ) ⟨ Classical.arbitrary S, Finset.mem_univ _ ⟩;
      exact ⟨ s, by rw [ show ( Finset.univ.sup' ( Finset.univ_nonempty ) fun x => cost x ) = cost s from le_antisymm ( Finset.sup'_le _ _ fun x _ => hs.2 x ‹_› ) ( Finset.le_sup' ( fun x => cost x ) hs.1 ) ] ⟩;
    · exact fun s => div_le_div_of_nonneg_right ( Real.exp_le_exp.mpr ( neg_le_neg ( mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun x => cost x ) ( Finset.mem_univ s ) ) hβ ) ) ) ( le_of_lt ( partition_function_pos cost β ) );
  unfold StrictProbDist.minProb;
  rw [ h_minProb, Real.log_div ( by positivity ) ( by exact ne_of_gt ( partition_function_pos cost β ) ), Real.log_exp ] ; ring

/-! ## Free Energy Convergence Rate -/

/-
**Free energy convergence rate**: The error in approximating the
    ground-state energy by −log Z(β)/β is at most log|S|/β.
    This is an O(1/β) convergence rate to the ground state energy.

    Bridge: connects to computational complexity of thermodynamic
    sampling and tropical optimization bounds.
-/
theorem free_energy_convergence_rate
    (cost : S → ℝ) (β : ℝ) (hβ : 0 < β) (hcost : ∀ s, 0 ≤ cost s) :
    |Real.log (tropicalPartitionFunction cost β) / β -
      (-groundStateEnergy cost)| ≤ Real.log (Fintype.card S) / β := by
  have := free_energy_sandwich cost β hβ hcost;
  grind

/-! ## Tropical KL Advanced Properties -/

variable {α : Type*} [Fintype α] [Nonempty α]

/-
**Tropical KL symmetrized bound**: D_⊕(P‖Q) + D_⊕(Q‖P) ≥ 0.
    Bridge: connects to lattice-based crypto distance metrics.
-/
theorem tropical_kl_symmetrized_nonneg
    (p q : StrictProbDist α) :
    0 ≤ tropicalKL p.toProbDist q + tropicalKL q.toProbDist p := by
  exact add_nonneg ( TropicalInformation.tropical_kl_nonneg _ _ ) ( TropicalInformation.tropical_kl_nonneg _ _ )

/-
**Tropical KL antisymmetry**: D_⊕(P‖Q) ≥ −D_⊕(Q‖P).
-/
theorem tropical_kl_antisymmetric_bound
    (p q : StrictProbDist α) :
    -tropicalKL q.toProbDist p ≤ tropicalKL p.toProbDist q := by
  linarith [ TropicalInformation.tropical_kl_symmetrized_nonneg p q ]

/-! ## Quantitative Bounds -/

/-
**Tropical entropy determines search complexity**: 1/min_p = exp(H_⊕).
    Bridge: connects to post-quantum security (Grover's worst case).
-/
theorem tropical_entropy_search_bound (p : StrictProbDist α) :
    (1 : ℝ) / p.minProb = Real.exp (tropicalEntropy p) := by
  unfold tropicalEntropy; rw [ one_div, Real.exp_neg, Real.exp_log ( minProb_pos p ) ] ;

/-
**Tropical KL exp equals max ratio**: exp(D_⊕(P‖Q)) = max_x p(x)/q(x).
    Bridge: connects to Neyman-Pearson testing and post-quantum advantage.
-/
theorem tropical_kl_exp_eq_max_ratio (p : ProbDist α) (q : StrictProbDist α) :
    Real.exp (tropicalKL p q) =
      Finset.max' (Finset.univ.image (fun x => p.pmf x / q.pmf x))
        (by simp [Finset.image_nonempty]) := by
  unfold tropicalKL;
  simp +decide [ Real.exp_log, Finset.max' ];
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff, Finset.le_sup'_iff ];
  · obtain ⟨ x, hx ⟩ := Finset.exists_max_image Finset.univ ( fun x => Real.log ( p.pmf x / q.pmf x ) ) ⟨ Classical.arbitrary α, Finset.mem_univ _ ⟩;
    rw [ show ( Finset.univ.sup' _ fun x => Real.log ( p.pmf x / q.pmf x ) ) = Real.log ( p.pmf x / q.pmf x ) from le_antisymm ( Finset.sup'_le _ _ fun y hy => hx.2 y hy ) ( Finset.le_sup' ( fun x => Real.log ( p.pmf x / q.pmf x ) ) hx.1 ) ];
    exact ⟨ x, by rw [ Real.exp_log ( div_pos ( lt_of_le_of_ne ( p.nonneg x ) ( Ne.symm ( by
      intro h; have := p.sum_one; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ] ;
      have h_contra : ∑ x, p.pmf x < ∑ x, q.pmf x := by
        apply Finset.sum_lt_sum;
        · intro i hi; specialize hx i; contrapose! hx; exact Real.log_pos ( by rw [ lt_div_iff₀ ( q.pos i ) ] ; linarith ) ;
        · exact ⟨ x, Finset.mem_univ _, by linarith [ q.pos x ] ⟩;
      linarith [ q.sum_one ] ) ) ) ( q.pos x ) ) ] ⟩;
  · intro x;
    by_cases h : p.pmf x / q.pmf x = 0;
    · exact h.symm ▸ Real.exp_nonneg _;
    · rw [ ← Real.log_le_iff_le_exp ( lt_of_le_of_ne ( div_nonneg ( p.nonneg x ) ( q.nonneg x ) ) ( Ne.symm h ) ) ];
      exact Finset.le_sup' ( fun x => Real.log ( p.pmf x / q.pmf x ) ) ( Finset.mem_univ x )

/-! ## Pushforward and DPI -/

/-- Pushforward probability distribution through a function f : α → β.
    The probability of y in β is the sum of probabilities of all
    preimages of y under f. -/
def ProbDist.pushforward {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (p : ProbDist α) (f : α → β) : ProbDist β where
  pmf := fun y => ∑ x ∈ Finset.univ.filter (fun a => f a = y), p.pmf x
  nonneg := fun y => Finset.sum_nonneg (fun x _ => p.nonneg x)
  sum_one := by
    trans (∑ x : α, p.pmf x)
    · rw [← Finset.sum_biUnion (hs := by
        intro y _ z _ hyz
        exact Finset.disjoint_filter.mpr (fun x _ h1 h2 => hyz (h1 ▸ h2)))]
      congr 1
      ext x
      simp [Finset.mem_biUnion, Finset.mem_filter]
    · exact p.sum_one

/-- Pushforward of a strict probability distribution, when the pushforward
    is also strictly positive. -/
def StrictProbDist.pushforward {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (q : StrictProbDist α) (f : α → β)
    (hpos : ∀ y : β, 0 < ∑ x ∈ Finset.univ.filter (fun a => f a = y), q.pmf x) :
    StrictProbDist β where
  toProbDist := q.toProbDist.pushforward f
  pos := hpos

/-
**Tropical Data Processing Inequality (deterministic channels)**:
    For any function f : α → β, D_⊕(f#P ‖ f#Q) ≤ D_⊕(P ‖ Q).
    Post-processing cannot increase worst-case divergence.

    This is the central inequality of tropical information theory.

    Bridge: connects to certified robustness (any post-processing of a
    neural network cannot increase worst-case information leakage) and
    post-quantum security (channel processing cannot amplify advantage).
-/
theorem pushforward_tropicalKL_le {β : Type*} [Fintype β] [Nonempty β]
    [DecidableEq β]
    (p : ProbDist α) (q : StrictProbDist α) (f : α → β)
    (hq : ∀ y : β, 0 < ∑ x ∈ Finset.univ.filter (fun a => f a = y), q.pmf x) :
    tropicalKL (p.pushforward f) (q.pushforward f hq) ≤ tropicalKL p q := by
  refine' Finset.sup'_le _ _ _;
  · exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ( Classical.arbitrary β ) ) ⟩;
  · simp +decide [ ProbDist.pushforward, StrictProbDist.pushforward ];
    intro y
    have h_ratio : (∑ x ∈ Finset.univ.filter (fun a => f a = y), p.pmf x) / (∑ x ∈ Finset.univ.filter (fun a => f a = y), q.pmf x) ≤ Real.exp (tropicalKL p q) := by
      have h_ratio : ∀ x ∈ Finset.univ.filter (fun a => f a = y), p.pmf x / q.pmf x ≤ Real.exp (tropicalKL p q) := by
        intro x hx;
        have := tropical_kl_pointwise_bound p q x;
        contrapose! this;
        simpa using Real.log_lt_log ( by positivity ) this;
      rw [ div_le_iff₀ ( hq y ) ];
      rw [ Finset.mul_sum _ _ _ ];
      exact Finset.sum_le_sum fun x hx => by have := h_ratio x hx; rwa [ div_le_iff₀ ( q.pos x ) ] at this;
    by_cases h : ( ∑ x with f x = y, p.pmf x ) / ∑ x with f x = y, q.pmf x = 0 <;> simp_all +decide [ Real.log_le_iff_le_exp ];
    · cases h <;> simp_all +decide [ ne_of_gt ];
      exact tropical_kl_nonneg p q;
    · simpa using Real.log_le_log ( div_pos ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => p.nonneg _ ) ( Ne.symm h.1 ) ) ( hq y ) ) h_ratio

/-
**Tropical DPI chain rule**: Composing functions cannot increase
    divergence. D_⊕((g∘f)#P ‖ (g∘f)#Q) ≤ D_⊕(P ‖ Q).

    Bridge: connects to neural network layerwise information bounds
    and certified robustness (each layer can only decrease leakage).
-/
theorem pushforward_tropicalKL_le_comp
    {β γ : Type*} [Fintype β] [Fintype γ] [Nonempty β] [Nonempty γ]
    [DecidableEq β] [DecidableEq γ]
    (p : ProbDist α) (q : StrictProbDist α) (f : α → β) (g : β → γ)
    (hqgf : ∀ z : γ, 0 < ∑ x ∈ Finset.univ.filter (fun a => g (f a) = z), q.pmf x) :
    tropicalKL (p.pushforward (g ∘ f)) (q.pushforward (g ∘ f) hqgf) ≤
      tropicalKL p q := by
  apply pushforward_tropicalKL_le p q (g ∘ f) hqgf

/-! ## Product Distribution Entropy -/

/-- Product of two strict probability distributions. -/
def StrictProbDist.prod {α β : Type*} [Fintype α] [Fintype β]
    (p : StrictProbDist α) (q : StrictProbDist β) : StrictProbDist (α × β) where
  pmf := fun ⟨a, b⟩ => p.pmf a * q.pmf b
  nonneg := fun ⟨a, b⟩ => mul_nonneg (p.nonneg a) (q.nonneg b)
  sum_one := by
    change ∑ x : α × β, p.pmf x.1 * q.pmf x.2 = 1
    rw [Fintype.sum_prod_type]
    simp_rw [← Finset.mul_sum, q.sum_one, mul_one, p.sum_one]
  pos := fun ⟨a, b⟩ => mul_pos (p.pos a) (q.pos b)

/-
**Tropical entropy is additive for products**: H_⊕(p ⊗ q) = H_⊕(p) + H_⊕(q).
    Independence means worst cases are independent.

    Bridge: connects to tensor products in quantum information
    and thermodynamic extensivity (entropy is extensive).
-/
theorem tropical_entropy_product {β : Type*} [Fintype β] [Nonempty β]
    (p : StrictProbDist α) (q : StrictProbDist β) :
    tropicalEntropy (p.prod q) = tropicalEntropy p + tropicalEntropy q := by
  unfold tropicalEntropy;
  rw [ show ( p.prod q ).minProb = p.minProb * q.minProb from ?_ ];
  · rw [ Real.log_mul ( ne_of_gt ( minProb_pos p ) ) ( ne_of_gt ( minProb_pos q ) ), neg_add ];
  · refine' le_antisymm _ _;
    · unfold StrictProbDist.minProb;
      simp +decide [ Finset.min', Finset.mem_image ];
      obtain ⟨ a, ha ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun x => p.pmf x ) ; obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun x => q.pmf x ) ; use a, b; aesop;
    · have h_min_prod : ∀ x : α × β, p.pmf x.1 * q.pmf x.2 ≥ p.minProb * q.minProb := by
        exact fun x => mul_le_mul ( minProb_le_pmf p x.1 ) ( minProb_le_pmf q x.2 ) ( by exact le_of_lt ( minProb_pos q ) ) ( by exact le_of_lt ( p.pos x.1 ) );
      exact Finset.le_min' _ _ _ fun x hx => by aesop;

end TropicalInformation

end