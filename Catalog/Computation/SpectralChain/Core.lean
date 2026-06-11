/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Chain Framework — Core

This file develops the combinatorial / energy-variance foundations of finite
reversible Markov chains on a finite state space `V`.

## Main definitions

* `ReversibleChain V` — a finite reversible Markov chain: a stochastic kernel `P`
  with a stationary distribution `weight` (`π`) satisfying detailed balance.
* `mean C f` — the stationary expectation `∑ᵢ πᵢ fᵢ`.
* `Var C f` — the stationary variance `∑ᵢ πᵢ (fᵢ - mean f)²`.
* `DirichletForm C f` — the energy `½ ∑ᵢⱼ πᵢ Pᵢⱼ (fᵢ - fⱼ)²`.
* `SpectralGapCert C` — a certified Poincaré (spectral-gap) inequality
  `γ · Var f ≤ E(f)`.
* `indicator S` — the `{0,1}` observable of a set `S`.

## Main results

* `Var_nonneg`, `DirichletForm_nonneg` — both functionals are nonnegative.
* `mean_const`, `Var_const` — constants have zero variance.
* `Var_indicator` — `Var(1_S) = π(S)·(1 - π(S))`.
* `cheeger_easy_inequality` — the cross-domain bridge: a spectral gap forces a
  cut/conductance lower bound `γ · π(S)·(1 - π(S)) ≤ E(1_S)`.

## Lab Notebook

-- !-- Lab Notebook: ReversibleChain framework -- !--
-- !-- Hypothesis: The energy/variance algebra of reversible chains can be packaged
--     so that a single Poincaré certificate mechanically yields conductance bounds. -- !--
-- !-- Result: All four structural lemmas + the Cheeger easy bridge compile sorry-free. -- !--
-- !-- Insight: Var(1_S) = π(S)(1-π(S)) reduces the indicator's variance to a pure
--     measure computation, so the spectral gap transfers to cuts with no extra analysis. -- !--
-- !-- Failure analysis: Defining the indicator via `Finset` membership (decidable) avoided
--     the `Set.indicator` measurability overhead that derailed the first attempt. -- !--
-- !-- End Lab Notebook -- !--
-/

import Mathlib

open Finset

namespace SpectralChain

/-- A finite reversible Markov chain on a finite state space `V`:
a row-stochastic kernel `P` together with a positive stationary distribution
`weight` (`π`) satisfying detailed balance `πᵢ Pᵢⱼ = πⱼ Pⱼᵢ`. -/
structure ReversibleChain (V : Type*) [Fintype V] where
  /-- Transition kernel: `P i j` is the probability of moving from `i` to `j`. -/
  P : V → V → ℝ
  /-- Stationary distribution (the weight `π`). -/
  weight : V → ℝ
  P_nonneg : ∀ i j, 0 ≤ P i j
  P_stochastic : ∀ i, ∑ j, P i j = 1
  weight_pos : ∀ i, 0 < weight i
  weight_sum : ∑ i, weight i = 1
  /-- Detailed balance (reversibility). -/
  reversible : ∀ i j, weight i * P i j = weight j * P j i

variable {V : Type*} [Fintype V] (C : ReversibleChain V)

/-- Stationary expectation `mean f = ∑ᵢ πᵢ fᵢ`. -/
def mean (f : V → ℝ) : ℝ := ∑ i, C.weight i * f i

/-- Stationary variance `Var f = ∑ᵢ πᵢ (fᵢ - mean f)²`. -/
def Var (f : V → ℝ) : ℝ := ∑ i, C.weight i * (f i - mean C f) ^ 2

/-- Dirichlet form (energy) `E(f) = ½ ∑ᵢⱼ πᵢ Pᵢⱼ (fᵢ - fⱼ)²`. -/
noncomputable def DirichletForm (f : V → ℝ) : ℝ :=
  (1 / 2) * ∑ i, ∑ j, C.weight i * C.P i j * (f i - f j) ^ 2

open Classical in
/-- The `{0,1}` observable of a finite set `S`. -/
noncomputable def indicator (S : Finset V) : V → ℝ := fun i => if i ∈ S then 1 else 0

/-- A certified Poincaré / spectral-gap inequality `γ · Var f ≤ E(f)`. -/
structure SpectralGapCert where
  gap : ℝ
  gap_nonneg : 0 ≤ gap
  poincare : ∀ f : V → ℝ, gap * Var C f ≤ DirichletForm C f

-- !-- Variance is nonnegative: a sum of nonneg weights times squares. -- !--
theorem Var_nonneg (f : V → ℝ) : 0 ≤ Var C f := by
  exact Finset.sum_nonneg fun i _ => mul_nonneg ( le_of_lt ( C.weight_pos i ) ) ( sq_nonneg _ )

-- !-- The energy is nonnegative: every summand `½ πᵢ Pᵢⱼ (fᵢ-fⱼ)²` is ≥ 0. -- !--
theorem DirichletForm_nonneg (f : V → ℝ) : 0 ≤ DirichletForm C f := by
  exact mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg ( mul_nonneg ( le_of_lt ( C.weight_pos i ) ) ( C.P_nonneg i j ) ) ( sq_nonneg _ ) )

-- !-- The mean of a constant `c` is `c`, since `∑ᵢ πᵢ = 1`. -- !--
theorem mean_const (c : ℝ) : mean C (fun _ => c) = c := by
  unfold mean;
  simp +decide [ ← Finset.sum_mul, C.weight_sum ]

-- !-- A constant observable has zero variance. -- !--
theorem Var_const (c : ℝ) : Var C (fun _ => c) = 0 := by
  unfold Var; simp +decide [ mean_const ] ;

-- !-- Var(1_S) = π(S)(1-π(S)): expand using `mean(1_S)=π(S)` and `(1_S)²=1_S`. -- !--
theorem Var_indicator (S : Finset V) :
    Var C (indicator S) = (∑ i ∈ S, C.weight i) * (1 - ∑ i ∈ S, C.weight i) := by
  unfold Var indicator;
  unfold mean;
  simp +decide [ sub_sq, mul_sub ];
  simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib ] ; ring_nf
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, C.weight_sum ] ; ring

-- !-- Cheeger easy bridge: apply the Poincaré certificate to `1_S` and rewrite
--     `Var(1_S)` via `Var_indicator`. -- !--
theorem cheeger_easy_inequality (cert : SpectralGapCert C) (S : Finset V) :
    cert.gap * ((∑ i ∈ S, C.weight i) * (1 - ∑ i ∈ S, C.weight i))
      ≤ DirichletForm C (indicator S) := by
  convert cert.poincare ( indicator S ) using 1
  generalize_proofs at *; (
  rw [ Var_indicator ])

end SpectralChain