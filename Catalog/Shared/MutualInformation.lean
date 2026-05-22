/-
Copyright (c) 2025. All rights reserved.

# Tropical Mutual Information and Data-Processing Inequalities

## Overview

This file establishes tropical mutual information as a bona fide information
monotone for tropical-algebraic protocols, founding the theory of tropical
information flow.

## Main definitions

* `condVulnerability` — V(X|Y) = ∑_y max_x p(x,y), the conditional guessing probability
* `tropCondMinEntropy` — H_∞(X|Y) = -log V(X|Y)
* `tropMutualInfo` — I_trop(X;Y) = H_∞(X) - H_∞(X|Y)
* `pushforwardSnd` — deterministic post-processing on the Y coordinate

## Main results

* `vulnerability_le_condVulnerability` — V(X) ≤ V(X|Y)
* `condVulnerability_pushforwardSnd_le` — V(X|f(Y)) ≤ V(X|Y)
* `tropMutualInfo_nonneg` — 0 ≤ I_trop(X;Y)
* `tropMutualInfo_data_processing_det` — I_trop(X;f(Y)) ≤ I_trop(X;Y)
* `tropCondMinEntropy_monotone_det` — H_∞(X|Y) ≤ H_∞(X|f(Y))
* `tropJointMinEntropy_ge_tropCondMinEntropy` — H_∞(X,Y) ≥ H_∞(X|Y)
-/
import Mathlib
import Shared.TropicalEntropy.Theorems

open Finset Real BigOperators Classical

noncomputable section

namespace TropicalEntropyAlgebra

variable {α β : Type*} [Fintype α] [Fintype β]

/-! ## Marginal Distributions -/

/-- The marginal distribution on the first component: p_X(a) = ∑_b p(a,b). -/
def marginalFst (p : PMF (α × β)) : PMF α where
  val a := ∑ b : β, p.val (a, b)
  nonneg a := Finset.sum_nonneg fun b _ => p.nonneg (a, b)
  sum_one := by
    have h := p.sum_one; rw [Fintype.sum_prod_type] at h; exact h

/-- The marginal distribution on the second component: p_Y(b) = ∑_a p(a,b). -/
def marginalSnd (p : PMF (α × β)) : PMF β where
  val b := ∑ a : α, p.val (a, b)
  nonneg b := Finset.sum_nonneg fun a _ => p.nonneg (a, b)
  sum_one := by
    have h := p.sum_one; rw [Fintype.sum_prod_type] at h
    simp only [Finset.sum_comm (f := fun a b => p.val (a, b))] at h; exact h

/-! ## Conditional Vulnerability -/

/-- **Conditional vulnerability**: V(X|Y) = ∑_y max_x p(x,y).
    The optimal guessing probability of X given side information Y. -/
def condVulnerability [Nonempty α] (p : PMF (α × β)) : ℝ :=
  ∑ b : β, Finset.sup' Finset.univ Finset.univ_nonempty (fun a => p.val (a, b))

/-! ## Pushforward on Second Coordinate -/

/-- Pushforward on the second coordinate under a deterministic map f.
    p'(a, c) = ∑_{b : f(b) = c} p(a, b). -/
def pushforwardSnd {γ : Type*} [Fintype γ] [DecidableEq γ]
    (p : PMF (α × β)) (f : β → γ) : PMF (α × γ) where
  val := fun ⟨a, c⟩ => ∑ b ∈ Finset.univ.filter (fun b => f b = c), p.val (a, b)
  nonneg := fun ⟨a, _⟩ => Finset.sum_nonneg fun b _ => p.nonneg (a, b)
  sum_one := by
    rw [Fintype.sum_prod_type]; simp only
    simp_rw [Finset.sum_fiberwise_of_maps_to
      (fun b (_ : b ∈ Finset.univ) => Finset.mem_univ (f b))]
    have h := p.sum_one; rw [Fintype.sum_prod_type] at h; exact h

/-! ## Core Vulnerability Inequalities -/

/-- Conditional vulnerability is nonneg: 0 ≤ V(X|Y). -/
theorem condVulnerability_nonneg [Nonempty α]
    (p : PMF (α × β)) : 0 ≤ condVulnerability p :=
  Finset.sum_nonneg fun b _ =>
    le_trans (p.nonneg (Classical.arbitrary α, b))
      (Finset.le_sup' (fun a => p.val (a, b)) (Finset.mem_univ _))

/-- Conditional vulnerability is at most 1: V(X|Y) ≤ 1. -/
theorem condVulnerability_le_one [Nonempty α]
    (p : PMF (α × β)) : condVulnerability p ≤ 1 := by
  unfold condVulnerability
  calc ∑ b : β, Finset.sup' Finset.univ Finset.univ_nonempty (fun a => p.val (a, b))
      ≤ ∑ b : β, ∑ a : α, p.val (a, b) := by
        apply Finset.sum_le_sum; intro b _
        rw [Finset.sup'_le_iff]; intro a _
        exact Finset.single_le_sum (fun a' _ => p.nonneg (a', b)) (Finset.mem_univ a)
    _ = 1 := (marginalSnd p).sum_one

/-- **Vulnerability ≤ Conditional Vulnerability**: max_x ∑_y p(x,y) ≤ ∑_y max_x p(x,y).
    Engine for nonnegativity of tropical mutual information. -/
theorem vulnerability_le_condVulnerability [Nonempty α]
    (p : PMF (α × β)) : (marginalFst p).maxProb ≤ condVulnerability p := by
  unfold condVulnerability marginalFst PMF.maxProb
  rw [Finset.sup'_le_iff]
  intro a _
  exact Finset.sum_le_sum fun b _ =>
    Finset.le_sup' (fun a => p.val (a, b)) (Finset.mem_univ a)

/-- **Joint vulnerability ≤ conditional vulnerability**:
    max_{x,y} p(x,y) ≤ V(X|Y). Equivalently H_∞(X,Y) ≥ H_∞(X|Y). -/
theorem jointVulnerability_le_condVulnerability [Nonempty α] [Nonempty β]
    (p : PMF (α × β)) : p.maxProb ≤ condVulnerability p := by
  unfold PMF.maxProb condVulnerability
  rw [Finset.sup'_le_iff]
  intro ⟨a, b⟩ _
  calc p.val (a, b)
      ≤ Finset.sup' Finset.univ Finset.univ_nonempty (fun a' => p.val (a', b)) :=
        Finset.le_sup' (fun a' => p.val (a', b)) (Finset.mem_univ a)
    _ ≤ ∑ b' : β, Finset.sup' Finset.univ Finset.univ_nonempty
          (fun a' => p.val (a', b')) := by
        let F := fun b' => Finset.sup' Finset.univ Finset.univ_nonempty
          (fun a' => p.val (a', b'))
        show F b ≤ ∑ b' : β, F b'
        exact Finset.single_le_sum
          (fun b' _ => le_trans (p.nonneg (Classical.arbitrary α, b'))
            (Finset.le_sup' (fun a' => p.val (a', b')) (Finset.mem_univ _)))
          (Finset.mem_univ b)

/-- **DPI ENGINE**: V(X|f(Y)) ≤ V(X|Y) for any deterministic f. -/
theorem condVulnerability_pushforwardSnd_le {γ : Type*}
    [Fintype γ] [DecidableEq γ] [Nonempty α]
    (p : PMF (α × β)) (f : β → γ) :
    condVulnerability (pushforwardSnd p f) ≤ condVulnerability p := by
  unfold condVulnerability pushforwardSnd
  simp only
  rw [show ∑ b : β, Finset.sup' Finset.univ Finset.univ_nonempty (fun a => p.val (a, b)) =
    ∑ c : γ, ∑ b ∈ Finset.univ.filter (fun b => f b = c),
      Finset.sup' Finset.univ Finset.univ_nonempty (fun a => p.val (a, b))
    from (Finset.sum_fiberwise_of_maps_to
      (fun b _ => Finset.mem_univ (f b)) _).symm]
  apply Finset.sum_le_sum
  intro c _
  rw [Finset.sup'_le_iff]
  intro a _
  exact Finset.sum_le_sum fun b _ =>
    Finset.le_sup' (fun a => p.val (a, b)) (Finset.mem_univ a)

/-- The first marginal values are preserved under pushforwardSnd. -/
theorem marginalFst_pushforwardSnd_val {γ : Type*}
    [Fintype γ] [DecidableEq γ]
    (p : PMF (α × β)) (f : β → γ) (a : α) :
    (marginalFst (pushforwardSnd p f)).val a = (marginalFst p).val a := by
  simp only [marginalFst, pushforwardSnd]
  rw [show (∑ c : γ, ∑ b ∈ Finset.univ.filter (fun b => f b = c), p.val (a, b)) =
    ∑ b : β, p.val (a, b) from
    Finset.sum_fiberwise_of_maps_to (fun b _ => Finset.mem_univ (f b)) _]

/-- maxProb of first marginal is preserved under pushforwardSnd. -/
theorem maxProb_marginalFst_pushforwardSnd {γ : Type*}
    [Fintype γ] [DecidableEq γ] [Nonempty α]
    (p : PMF (α × β)) (f : β → γ) :
    (marginalFst (pushforwardSnd p f)).maxProb = (marginalFst p).maxProb := by
  unfold PMF.maxProb; congr 1; ext a
  exact marginalFst_pushforwardSnd_val p f a

/-! ## Tropical Entropy Definitions -/

/-- **Tropical conditional min-entropy**: H_∞(X|Y) = -log V(X|Y). -/
def tropCondMinEntropy [Nonempty α] (p : PMF (α × β)) : ℝ :=
  -Real.log (condVulnerability p)

/-- **Tropical mutual information**:
    I_trop(X;Y) = H_∞(X) - H_∞(X|Y) = log(V(X|Y)/V(X)). -/
def tropMutualInfo [Nonempty α] (p : PMF (α × β)) : ℝ :=
  minEntropy (marginalFst p) - tropCondMinEntropy p

/-! ## Main Theorems -/

/-- **NONNEGATIVITY**: 0 ≤ I_trop(X;Y). -/
theorem tropMutualInfo_nonneg [Nonempty α]
    (p : PMF (α × β)) : 0 ≤ tropMutualInfo p := by
  unfold tropMutualInfo minEntropy tropCondMinEntropy
  linarith [Real.log_le_log (maxProb_pos (marginalFst p))
    (vulnerability_le_condVulnerability p)]

/-- **CONDITIONAL MIN-ENTROPY MONOTONICITY**:
    H_∞(X|Y) ≤ H_∞(X|f(Y)) for any deterministic f. -/
theorem tropCondMinEntropy_monotone_det {γ : Type*}
    [Fintype γ] [DecidableEq γ] [Nonempty α]
    (p : PMF (α × β)) (f : β → γ) :
    tropCondMinEntropy p ≤ tropCondMinEntropy (pushforwardSnd p f) := by
  unfold tropCondMinEntropy
  simp only [neg_le_neg_iff]
  apply Real.log_le_log
  · calc (0 : ℝ) < (marginalFst (pushforwardSnd p f)).maxProb := by
            rw [maxProb_marginalFst_pushforwardSnd]
            exact maxProb_pos (marginalFst p)
      _ ≤ condVulnerability (pushforwardSnd p f) :=
            vulnerability_le_condVulnerability _
  · exact condVulnerability_pushforwardSnd_le p f

/-- **DATA-PROCESSING INEQUALITY**:
    I_trop(X; f(Y)) ≤ I_trop(X; Y) for any deterministic f.

    The foundational monotonicity result for tropical information flow. -/
theorem tropMutualInfo_data_processing_det {γ : Type*}
    [Fintype γ] [DecidableEq γ] [Nonempty α]
    (p : PMF (α × β)) (f : β → γ) :
    tropMutualInfo (pushforwardSnd p f) ≤ tropMutualInfo p := by
  unfold tropMutualInfo
  have hmarg : minEntropy (marginalFst (pushforwardSnd p f)) =
      minEntropy (marginalFst p) := by
    unfold minEntropy
    rw [maxProb_marginalFst_pushforwardSnd]
  rw [hmarg]
  linarith [tropCondMinEntropy_monotone_det p f]

/-- **CHAIN RULE INEQUALITY**: H_∞(X,Y) ≥ H_∞(X|Y).

    Note: The full chain rule H_∞(X,Y) = H_∞(Y) + H_∞(X|Y) does NOT hold
    for min-entropy in general. This one-sided inequality is the correct
    statement, and is sufficient for most cryptographic applications. -/
theorem tropJointMinEntropy_ge_tropCondMinEntropy
    [Nonempty α] [Nonempty β]
    (p : PMF (α × β)) :
    minEntropy p ≥ tropCondMinEntropy p := by
  unfold tropCondMinEntropy minEntropy
  simp only [ge_iff_le, neg_le_neg_iff]
  exact Real.log_le_log (maxProb_pos p) (jointVulnerability_le_condVulnerability p)

/-! ## Security Corollaries -/

/-- **SECURE POST-PROCESSING**: A leakage bound δ for (X,Y) implies
    the same leakage bound for (X, f(Y)). -/
theorem secure_post_processing {γ : Type*}
    [Fintype γ] [DecidableEq γ] [Nonempty α]
    (p : PMF (α × β)) (f : β → γ)
    (δ : ℝ) (hleakage : tropMutualInfo p ≤ δ) :
    tropMutualInfo (pushforwardSnd p f) ≤ δ :=
  le_trans (tropMutualInfo_data_processing_det p f) hleakage

/-- **LEAKAGE COMPOSITION**: Composing two deterministic post-processings
    preserves the leakage bound. -/
theorem leakage_composition {γ₁ γ₂ : Type*}
    [Fintype γ₁] [Fintype γ₂]
    [DecidableEq γ₁] [DecidableEq γ₂]
    [Nonempty α]
    (p : PMF (α × β)) (f : β → γ₁) (g : γ₁ → γ₂) :
    tropMutualInfo (pushforwardSnd (pushforwardSnd p f) g) ≤ tropMutualInfo p :=
  le_trans (tropMutualInfo_data_processing_det (pushforwardSnd p f) g)
    (tropMutualInfo_data_processing_det p f)

end TropicalEntropyAlgebra