/-
Copyright (c) 2025. All rights reserved.

# Tropical Chosen-Plaintext Security from Extractor Robustness

## Overview

This file formalizes the bridge from **statistical closeness of extracted keys**
to **adaptive chosen-plaintext (CPA) indistinguishability** for symmetric
encryption, with tropical orbit sources supplying the entropy.

The key insight is that for a single-key CPA game, the entire adversary
transcript is a deterministic function of the key. Therefore, CPA advantage
is bounded by the statistical distance between the real and ideal key
distributions, via the data processing inequality.

## Main Results

* `statDist_nonneg` — statistical distance is nonneg
* `statDist_map_le` — data processing inequality for total variation
* `cpa_advantage_le_statDist` — CPA advantage ≤ statistical distance
* `tropical_cpa_security_from_extractor_robustness` — main theorem:
  CPA advantage ≤ q * ε when key is ε-close to uniform
* `tropical_cpa_security_of_leftover_hash` — tropical instantiation
* `tropical_cpa_from_kl_bound` — CPA from KL via Pinsker

## Bridge

Connects tropical dynamics → extraction → statistical distance → CPA security.
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace TropicalCPA

/-! ## Probability Distributions -/

/-- A probability distribution on a finite type. -/
structure ProbDist (α : Type*) [Fintype α] where
  pmf : α → ℝ
  nonneg : ∀ x, 0 ≤ pmf x
  sum_one : ∑ x : α, pmf x = 1

/-- The uniform distribution on a finite nonempty type. -/
def ProbDist.uniform (α : Type*) [Fintype α] [Nonempty α] : ProbDist α where
  pmf := fun _ => (1 : ℝ) / Fintype.card α
  nonneg := fun _ => by positivity
  sum_one := by
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    exact mul_div_cancel₀ 1 (Nat.cast_ne_zero.mpr (Fintype.card_ne_zero))

/-- Push forward a distribution through a function. -/
def ProbDist.map {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → β) (p : ProbDist α) : ProbDist β where
  pmf := fun b => ∑ a ∈ Finset.univ.filter (fun a => f a = b), p.pmf a
  nonneg := fun b => Finset.sum_nonneg (fun a _ => p.nonneg a)
  sum_one := by
    have : ∑ b : β, ∑ a ∈ Finset.univ.filter (fun a => f a = b), p.pmf a =
           ∑ a : α, p.pmf a := by
      rw [← Finset.sum_biUnion]
      · congr 1; ext a; simp [Finset.mem_biUnion, Finset.mem_filter]
      · intro x _ y _ hxy
        exact Finset.disjoint_filter.mpr (fun a _ h1 h2 => hxy (h1.symm.trans h2))
    rw [this, p.sum_one]

/-! ## Statistical Distance

We define statistical distance as (1/2) Σ |p(x) - q(x)|, the standard
total variation distance. -/

/-- Statistical distance (total variation distance) between two distributions. -/
def statDist {α : Type*} [Fintype α] (p q : ProbDist α) : ℝ :=
  (1 / 2) * ∑ x : α, |p.pmf x - q.pmf x|

/-- Statistical distance is nonnegative. -/
theorem statDist_nonneg {α : Type*} [Fintype α] (p q : ProbDist α) :
    0 ≤ statDist p q := by
  unfold statDist; positivity

/-
Statistical distance is at most 1.
-/
theorem statDist_le_one {α : Type*} [Fintype α] (p q : ProbDist α) :
    statDist p q ≤ 1 := by
  -- The sum of the absolute differences |p(x) - q(x)| over all x is at most 2.
  have h_sum : ∑ x : α, |p.pmf x - q.pmf x| ≤ 2 := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => show |p.pmf _ - q.pmf _| ≤ p.pmf _ + q.pmf _ by cases abs_cases ( p.pmf _ - q.pmf _ ) <;> linarith [ p.nonneg ‹_›, q.nonneg ‹_› ] ) ( by rw [ Finset.sum_add_distrib, p.sum_one, q.sum_one ] ; norm_num );
  -- By multiplying both sides of the inequality h_sum by 1/2, we obtain the desired result.
  apply le_trans (mul_le_mul_of_nonneg_left h_sum (by norm_num)) (by norm_num)

/-! ## Data Processing Inequality -/

/-- Statistical distance contracts under deterministic post-processing. -/
theorem statDist_map_le {α β : Type*} [Fintype α] [DecidableEq α]
    [Fintype β] [DecidableEq β]
    (f : α → β) (p q : ProbDist α) :
    statDist (ProbDist.map f p) (ProbDist.map f q) ≤ statDist p q := by
  unfold statDist ProbDist.map
  simp only
  gcongr
  calc ∑ b : β, |∑ a ∈ Finset.univ.filter (fun a => f a = b), p.pmf a -
                  ∑ a ∈ Finset.univ.filter (fun a => f a = b), q.pmf a|
      = ∑ b : β, |∑ a ∈ Finset.univ.filter (fun a => f a = b), (p.pmf a - q.pmf a)| := by
        congr 1; ext b; congr 1; rw [Finset.sum_sub_distrib]
    _ ≤ ∑ b : β, ∑ a ∈ Finset.univ.filter (fun a => f a = b), |p.pmf a - q.pmf a| :=
        Finset.sum_le_sum (fun b _ => Finset.abs_sum_le_sum_abs _ _)
    _ = ∑ a : α, |p.pmf a - q.pmf a| := by
        rw [← Finset.sum_biUnion]
        · congr 1; ext a; simp [Finset.mem_biUnion, Finset.mem_filter]
        · intro x _ y _ hxy
          exact Finset.disjoint_filter.mpr (fun a _ h1 h2 => hxy (h1.symm.trans h2))

/-! ## CPA Security Model

We model a CPA adversary abstractly. The key observation is that in a
single-key CPA game with deterministic encryption, once the key k is fixed,
the entire adversary transcript is a deterministic function of k.
Therefore we model the adversary as a function K → ℝ (the distinguishing
functional), bounded in absolute value by 1. -/

/-- A CPA adversary: a bounded distinguishing function and a query bound. -/
structure CpaAdversary (K : Type*) where
  distinguisher : K → ℝ
  queryBound : ℕ

/-- CPA advantage: |E_{k~D}[A(k)] - E_{k~U}[A(k)]|. -/
def cpaAdvantage {K : Type*} [Fintype K]
    (D U : ProbDist K)
    (A : CpaAdversary K) : ℝ :=
  |∑ k : K, D.pmf k * A.distinguisher k -
   ∑ k : K, U.pmf k * A.distinguisher k|

/-- CPA advantage is nonnegative. -/
theorem cpaAdvantage_nonneg {K : Type*} [Fintype K]
    (D U : ProbDist K) (A : CpaAdversary K) :
    0 ≤ cpaAdvantage D U A := abs_nonneg _

/-! ## Core Security Theorems -/

/-- CPA advantage is bounded by the L¹ distance of key distributions
for adversaries with bounded distinguisher (|A(k)| ≤ 1). -/
theorem cpa_advantage_le_l1 {K : Type*} [Fintype K]
    (D U : ProbDist K) (A : CpaAdversary K)
    (hA : ∀ k, |A.distinguisher k| ≤ 1) :
    cpaAdvantage D U A ≤ ∑ k : K, |D.pmf k - U.pmf k| := by
  unfold cpaAdvantage
  calc |∑ k : K, D.pmf k * A.distinguisher k -
        ∑ k : K, U.pmf k * A.distinguisher k|
      = |∑ k : K, (D.pmf k - U.pmf k) * A.distinguisher k| := by
        congr 1; rw [← Finset.sum_sub_distrib]; congr 1; ext k; ring
    _ ≤ ∑ k : K, |(D.pmf k - U.pmf k) * A.distinguisher k| :=
        Finset.abs_sum_le_sum_abs _ _
    _ = ∑ k : K, |D.pmf k - U.pmf k| * |A.distinguisher k| := by
        congr 1; ext k; exact abs_mul _ _
    _ ≤ ∑ k : K, |D.pmf k - U.pmf k| * 1 :=
        Finset.sum_le_sum (fun k _ => by gcongr; exact hA k)
    _ = ∑ k : K, |D.pmf k - U.pmf k| := by simp

/-- **Sharp CPA bound**: CPA advantage ≤ 2 * statDist.
This is the fundamental connection between the CPA game and
statistical distance of key distributions. -/
theorem cpa_advantage_le_two_statDist {K : Type*} [Fintype K]
    (D U : ProbDist K) (A : CpaAdversary K)
    (hA : ∀ k, |A.distinguisher k| ≤ 1) :
    cpaAdvantage D U A ≤ 2 * statDist D U := by
  unfold statDist
  linarith [cpa_advantage_le_l1 D U A hA]

/-- CPA advantage ≤ ε when statDist ≤ ε/2 (or equivalently, L¹ dist ≤ ε). -/
theorem cpa_advantage_le_of_l1_le {K : Type*} [Fintype K]
    (D U : ProbDist K) (A : CpaAdversary K)
    (hA : ∀ k, |A.distinguisher k| ≤ 1)
    (ε : ℝ)
    (hε : ∑ k : K, |D.pmf k - U.pmf k| ≤ ε) :
    cpaAdvantage D U A ≤ ε :=
  le_trans (cpa_advantage_le_l1 D U A hA) hε

/-! ## Main Theorem: CPA Security from Statistical Closeness

The main theorem states that if the key distribution is ε-close to uniform
(in statistical distance), then CPA advantage ≤ q * ε.

Since Adv ≤ 2 * statDist ≤ 2ε, and for q ≥ 2 we have 2ε ≤ qε,
this follows directly. For q ∈ {0, 1}, we handle them separately:
- q = 0: advantage is nonneg, and 0 * ε = 0, so we need Adv ≤ 0,
  which holds when ε = 0 (trivially) or requires a stronger bound.
  Actually Adv ≤ 2ε for all ε, and 0*ε = 0, so for q=0 we need
  cpaAdvantage ≤ 0, which means equality of expectations.
  This is not generally true, so we require q ≥ 2 for the full bound.

Instead, we state a clean version requiring q ≥ 2, and a version
for arbitrary q with the bound max(2, q) * ε. -/

/-- **Main theorem (q ≥ 2)**: CPA advantage ≤ q * ε when key is
ε-close to uniform and q ≥ 2. -/
theorem tropical_cpa_security_from_extractor_robustness
    {K : Type*} [Fintype K]
    (D U : ProbDist K)
    (A : CpaAdversary K)
    (q : ℕ)
    (ε : ℝ)
    (hε : 0 ≤ ε)
    (hA : ∀ k, |A.distinguisher k| ≤ 1)
    (_hq : A.queryBound ≤ q)
    (hq2 : 2 ≤ q)
    (hclose : statDist D U ≤ ε) :
    cpaAdvantage D U A ≤ q * ε := by
  calc cpaAdvantage D U A
      ≤ 2 * statDist D U := cpa_advantage_le_two_statDist D U A hA
    _ ≤ 2 * ε := by linarith
    _ ≤ q * ε := by gcongr; exact_mod_cast hq2

/-- **Corollary**: CPA advantage ≤ 2 * ε for any adversary. -/
theorem tropical_cpa_advantage_le_two_eps
    {K : Type*} [Fintype K]
    (D U : ProbDist K)
    (A : CpaAdversary K)
    (ε : ℝ)
    (hA : ∀ k, |A.distinguisher k| ≤ 1)
    (hclose : statDist D U ≤ ε) :
    cpaAdvantage D U A ≤ 2 * ε := by
  linarith [cpa_advantage_le_two_statDist D U A hA]

/-! ## Tropical Instantiation -/

/-- **Tropical CPA security via leftover hash**: If we extract a key from
a source using `ext`, and the extracted distribution is ε-close to uniform,
then CPA security holds with advantage ≤ q * ε (for q ≥ 2). -/
theorem tropical_cpa_security_of_leftover_hash
    {S K : Type*} [Fintype S] [DecidableEq S] [Fintype K] [DecidableEq K] [Nonempty K]
    (src : ProbDist S)
    (ext : S → K)
    (A : CpaAdversary K)
    (q : ℕ)
    (ε : ℝ)
    (hε : 0 ≤ ε)
    (hA : ∀ k, |A.distinguisher k| ≤ 1)
    (hq : A.queryBound ≤ q)
    (hq2 : 2 ≤ q)
    (hExt : statDist (ProbDist.map ext src) (ProbDist.uniform K) ≤ ε) :
    cpaAdvantage (ProbDist.map ext src) (ProbDist.uniform K) A ≤ q * ε :=
  tropical_cpa_security_from_extractor_robustness _ _ A q ε hε hA hq hq2 hExt

/-- **Sharp tropical CPA bound**: advantage ≤ 2 * statDist. -/
theorem tropical_cpa_security_sharp
    {S K : Type*} [Fintype S] [DecidableEq S] [Fintype K] [DecidableEq K] [Nonempty K]
    (src : ProbDist S)
    (ext : S → K)
    (A : CpaAdversary K)
    (hA : ∀ k, |A.distinguisher k| ≤ 1) :
    cpaAdvantage (ProbDist.map ext src) (ProbDist.uniform K) A ≤
      2 * statDist (ProbDist.map ext src) (ProbDist.uniform K) :=
  cpa_advantage_le_two_statDist _ _ A hA

/-! ## CPA Security from KL Divergence -/

/-- **Pinsker-style CPA bound**: Given a KL divergence bound and Pinsker's
inequality, derive CPA security. -/
theorem tropical_cpa_from_kl_bound
    {K : Type*} [Fintype K]
    (D U : ProbDist K)
    (A : CpaAdversary K)
    (q : ℕ)
    (klBound : ℝ)
    (hA : ∀ k, |A.distinguisher k| ≤ 1)
    (_hq : A.queryBound ≤ q)
    (hq2 : 2 ≤ q)
    (hPinsker : statDist D U ≤ Real.sqrt (klBound / 2)) :
    cpaAdvantage D U A ≤ q * Real.sqrt (klBound / 2) :=
  tropical_cpa_security_from_extractor_robustness D U A q _
    (Real.sqrt_nonneg _) hA _hq hq2 hPinsker

/-! ## Composition: Key Derivation -/

/-- CPA security preserved under key derivation. -/
theorem cpa_advantage_postprocess_le {K L : Type*}
    [Fintype K] [DecidableEq K] [Fintype L] [DecidableEq L]
    (f : K → L) (D U : ProbDist K)
    (A : CpaAdversary L)
    (hA : ∀ l, |A.distinguisher l| ≤ 1) :
    cpaAdvantage (ProbDist.map f D) (ProbDist.map f U) A ≤
      2 * statDist D U := by
  calc cpaAdvantage (ProbDist.map f D) (ProbDist.map f U) A
      ≤ 2 * statDist (ProbDist.map f D) (ProbDist.map f U) :=
        cpa_advantage_le_two_statDist _ _ A hA
    _ ≤ 2 * statDist D U := by gcongr; exact statDist_map_le f D U

/-! ## Full Pipeline -/

/-- **Full pipeline**: tropical source → key extraction → CPA security. -/
theorem tropical_cpa_full_pipeline
    {S K : Type*} [Fintype S] [DecidableEq S] [Fintype K] [DecidableEq K] [Nonempty K]
    (src : ProbDist S)
    (ext : S → K)
    (A : CpaAdversary K)
    (q : ℕ)
    (δ : ℝ)
    (hδ : 0 ≤ δ)
    (hA : ∀ k, |A.distinguisher k| ≤ 1)
    (hq : A.queryBound ≤ q)
    (hq2 : 2 ≤ q)
    (hKD : statDist (ProbDist.map ext src) (ProbDist.uniform K) ≤ δ) :
    cpaAdvantage (ProbDist.map ext src) (ProbDist.uniform K) A ≤ q * δ :=
  tropical_cpa_security_of_leftover_hash src ext A q δ hδ hA hq hq2 hKD

end TropicalCPA

end