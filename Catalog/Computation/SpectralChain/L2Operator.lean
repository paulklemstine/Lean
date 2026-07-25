/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Chain Framework — L²(π) Operator Layer

This file lifts the combinatorial energy/variance algebra of finite reversible
Markov chains into self-adjoint operator theory on the finite weighted Hilbert
space `L²(π)`.

The basic objects (`ReversibleChain`, `mean`, `Var`, `DirichletForm`,
`SpectralGapCert`) are the same as in `Computation.SpectralChain.Core`; they are
restated here so that this operator layer is a single self-contained module.

## Main definitions

* `applyP C f` — the Markov operator action `(Pf)(i) = ∑ⱼ Pᵢⱼ fⱼ`.
* `innerPi C f g` — the weighted inner product `⟨f, g⟩_π = ∑ᵢ πᵢ fᵢ gᵢ`.

## Main results

* `mean_applyP` — `P` preserves the stationary mean: `mean(Pf) = mean(f)`.
* `innerPi_self_adjoint` — reversibility *is* self-adjointness:
  `⟨Pf, g⟩_π = ⟨f, Pg⟩_π`.
* `DirichletForm_eq_innerPi_sub` — the energy is the quadratic form of `I - P`:
  `E(f) = ⟨f, f⟩_π - ⟨Pf, f⟩_π`.
* `Var_eq_innerPi_sub_mean_sq` — `Var(f) = ⟨f, f⟩_π - mean(f)²`.
* `applyP_inner_contraction` — a Poincaré gap forces a one-step contraction on
  mean-zero observables: `⟨Pf, f⟩_π ≤ (1 - γ) ⟨f, f⟩_π`.

The strengthening "Var(Pf) ≤ (1-γ)²·Var(f)" is *disproved* in general
(`Var_applyP_contraction_false`): the two-state bipartite swap chain (`swapChain`)
has eigenvalue `-1`, so the squared one-step contraction fails. An *absolute*
spectral gap (a lower bound on the spectrum of `P`) is genuinely needed.

## Lab Notebook

-- !-- Lab Notebook: L²(π) operator layer -- !--
-- !-- Hypothesis: Detailed balance is exactly self-adjointness of P in L²(π), and the
--     Dirichlet form is the quadratic form of I - P. -- !--
-- !-- Result: All five operator identities compile sorry-free; the squared variance
--     contraction Var(Pf) ≤ (1-γ)²·Var(f) is DISPROVED via the bipartite swap chain. -- !--
-- !-- Insight: Centering f = g + mean f with g mean-zero reduces every operator identity
--     to a sum-swap plus one application of `reversible`. -- !--
-- !-- Failure analysis: Attempting Var(Pf) ≤ (1-γ)² Var(f) directly fails — the missing
--     lower spectral bound is a genuine mathematical obstruction, not a proof-engineering one. -- !--
-- !-- End Lab Notebook -- !--
-/

import Mathlib

open Finset

namespace SpectralChain

/-- A finite reversible Markov chain on a finite state space `V` (see
`Computation.SpectralChain.Core`; restated for a self-contained operator layer). -/
structure ReversibleChain (V : Type*) [Fintype V] where
  /-- Transition kernel: `P i j` is the probability of moving from `i` to `j`. -/
  P : V → V → ℝ
  /-- Stationary distribution (the weight `π`). -/
  weight : V → ℝ
  P_nonneg : ∀ i j, 0 ≤ P i j
  P_stochastic : ∀ i, ∑ j, P i j = 1
  weight_pos : ∀ i, 0 < weight i
  weight_sum : ∑ i, weight i = 1
  reversible : ∀ i j, weight i * P i j = weight j * P j i

variable {V : Type*} [Fintype V] (C : ReversibleChain V)

/-- Stationary expectation `mean f = ∑ᵢ πᵢ fᵢ`. -/
def mean (f : V → ℝ) : ℝ := ∑ i, C.weight i * f i

/-- Stationary variance `Var f = ∑ᵢ πᵢ (fᵢ - mean f)²`. -/
def Var (f : V → ℝ) : ℝ := ∑ i, C.weight i * (f i - mean C f) ^ 2

/-- Dirichlet form (energy) `E(f) = ½ ∑ᵢⱼ πᵢ Pᵢⱼ (fᵢ - fⱼ)²`. -/
noncomputable def DirichletForm (f : V → ℝ) : ℝ :=
  (1 / 2) * ∑ i, ∑ j, C.weight i * C.P i j * (f i - f j) ^ 2

/-- A certified Poincaré / spectral-gap inequality `γ · Var f ≤ E(f)`. -/
structure SpectralGapCert where
  gap : ℝ
  gap_nonneg : 0 ≤ gap
  poincare : ∀ f : V → ℝ, gap * Var C f ≤ DirichletForm C f

/-- The Markov operator action `(Pf)(i) = ∑ⱼ Pᵢⱼ fⱼ`. -/
def applyP (f : V → ℝ) : V → ℝ := fun i => ∑ j, C.P i j * f j

/-- The weighted (`L²(π)`) inner product `⟨f, g⟩_π = ∑ᵢ πᵢ fᵢ gᵢ`. -/
def innerPi (f g : V → ℝ) : ℝ := ∑ i, C.weight i * f i * g i

-- !-- mean(Pf) = mean(f): swap sums, then `∑ᵢ πᵢ Pᵢⱼ = πⱼ` by reversibility + stochasticity. -- !--
theorem mean_applyP (f : V → ℝ) : mean C (applyP C f) = mean C f := by
  have h_sum_eq : ∑ i, C.weight i * ∑ j, C.P i j * f j = ∑ j, f j * ∑ i, C.weight i * C.P i j := by
    simpa only [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] using Finset.sum_comm;
  -- By reversibility, we have ∑ i, C.weight i * C.P i j = C.weight j for all j.
  have h_reversibility : ∀ j, ∑ i, C.weight i * C.P i j = C.weight j := by
    intro j; rw [ Finset.sum_congr rfl fun i _ => C.reversible i j ] ; simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, C.P_stochastic ] ;
  simp_all +decide [ mul_comm, mean, applyP ]

-- !-- ⟨Pf,g⟩ = ⟨f,Pg⟩: expand both as double sums and apply `reversible` term-by-term. -- !--
theorem innerPi_self_adjoint (f g : V → ℝ) :
    innerPi C (applyP C f) g = innerPi C f (applyP C g) := by
  unfold innerPi applyP;
  simp +decide only [Finset.mul_sum _ _ _, mul_left_comm, mul_assoc];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; intros ; rw [ Finset.sum_mul ] ; congr ; ext ; ring_nf
  grind +suggestions

-- !-- E(f) = ⟨f,f⟩ - ⟨Pf,f⟩: expand (fᵢ-fⱼ)², use stochasticity for the diagonal terms
--     and reversibility for the symmetric collapse of the cross term. -- !--
theorem DirichletForm_eq_innerPi_sub (f : V → ℝ) :
    DirichletForm C f = innerPi C f f - innerPi C (applyP C f) f := by
  simp +decide [ DirichletForm, innerPi, applyP ];
  simp +decide only [sub_sq, mul_assoc, mul_add, mul_sub, sum_add_distrib, sum_sub_distrib];
  -- By simplifying the sums and using the properties of the Markov chain, we can show that the left-hand side equals the right-hand side.
  have h_simp : ∑ x, ∑ x_1, C.weight x * (C.P x x_1 * f x_1 ^ 2) = ∑ x, C.weight x * f x ^ 2 := by
    rw [ Finset.sum_comm ];
    -- By the properties of the Markov chain, we know that $\sum_{x} \pi_x P_{xy} = \pi_y$ for all $y$.
    have h_sum : ∀ y, ∑ x, C.weight x * C.P x y = C.weight y := by
      intro y
      have h_reversible : ∑ x, C.weight x * C.P x y = ∑ x, C.weight y * C.P y x := by
        exact Finset.sum_congr rfl fun x _ => C.reversible x y;
      rw [ h_reversible, ← Finset.mul_sum _ _ _, C.P_stochastic, mul_one ];
    simp +decide only [← mul_assoc, ← sum_mul, h_sum];
  simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring_nf
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, C.P_stochastic ] ; ring

-- !-- Var(f) = ⟨f,f⟩ - mean(f)²: expand the square and use `∑ πᵢ = 1`. -- !--
theorem Var_eq_innerPi_sub_mean_sq (f : V → ℝ) :
    Var C f = innerPi C f f - (mean C f) ^ 2 := by
  unfold Var innerPi mean
  have key : ∀ i, C.weight i * (f i - (∑ j, C.weight j * f j)) ^ 2
      = C.weight i * f i * f i - 2 * (∑ j, C.weight j * f j) * (C.weight i * f i)
        + (∑ j, C.weight j * f j) ^ 2 * C.weight i := fun i => by ring
  rw [Finset.sum_congr rfl (fun i _ => key i), Finset.sum_add_distrib,
    Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum, C.weight_sum]
  ring

-- !-- One-step contraction: from `DirichletForm_eq_innerPi_sub`,
--     ⟨Pf,f⟩ = ⟨f,f⟩ - E(f) ≤ ⟨f,f⟩ - γ·Var(f) = (1-γ)⟨f,f⟩ for mean-zero f. -- !--
theorem applyP_inner_contraction (cert : SpectralGapCert C) (f : V → ℝ)
    (hf : mean C f = 0) :
    innerPi C (applyP C f) f ≤ (1 - cert.gap) * innerPi C f f := by
  -- From DirichletForm_eq_innerPi_sub C f we have innerPi C (applyP C f) f = innerPi C f f - DirichletForm C f.
  have h1 : innerPi C (applyP C f) f = innerPi C f f - DirichletForm C f := by
    rw [ DirichletForm_eq_innerPi_sub, sub_sub_cancel ];
  -- From cert.poincare f: cert.gap * Var C f ≤ DirichletForm C f.
  have h2 : cert.gap * Var C f ≤ DirichletForm C f := by
    exact cert.poincare f;
  rw [ h1, Var_eq_innerPi_sub_mean_sq ] at * ; simp_all +decide [ sub_mul ] ; nlinarith [ cert.gap_nonneg ] ;

-- !-- Lab Notebook: Var_applyP_contraction (DISPROVED) -- !--
-- !-- Hypothesis: a Poincaré gap γ gives Var(Pf) ≤ (1-γ)² Var(f). -- !--
-- !-- Result: DISPROVED. The two-state bipartite swap chain has eigenvalue -1, so Pf = -f
--     on the mean-zero line; with the valid certificate γ = 1 the bound demands
--     Var(Pf) ≤ 0 while Var(Pf) = Var(f) > 0. -- !--
-- !-- Insight: the gap controls only the *upper* spectrum; the squared bound additionally
--     needs an absolute lower bound ⟨Pf,f⟩ ≥ -(1-γ)⟨f,f⟩ (a lazy / aperiodic chain). -- !--
-- !-- Failure analysis: the counterexample pins down the exact missing hypothesis for the
--     next cycle's geometric-ergodicity bound. -- !--
-- !-- End Lab Notebook -- !--

/-- The two-state bipartite "swap" chain on `Fin 2`: deterministic swap
`P i j = if i = j then 0 else 1` with uniform stationary distribution `½`.
It is reversible, and its spectrum is `{1, -1}` — the eigenvalue `-1` is what
breaks the squared variance contraction. -/
noncomputable def swapChain : ReversibleChain (Fin 2) where
  P i j := if i = j then 0 else 1
  weight _ := 1 / 2
  P_nonneg i j := by split <;> norm_num
  P_stochastic i := by fin_cases i <;> simp [Fin.sum_univ_two]
  weight_pos i := by norm_num
  weight_sum := by simp
  reversible i j := by
    rcases eq_or_ne i j with h | h
    · subst h; rfl
    · simp only [if_neg h, if_neg (Ne.symm h)]

/-
!-- Poincaré for the swap chain: a direct `Fin 2` computation gives E(f) = 2·Var(f),
so γ = 1 (indeed any γ ≤ 2) is a valid certificate. -- !--

The swap chain satisfies the Poincaré inequality with constant `1`: its Dirichlet
form is twice its variance, so `1 · Var f ≤ E(f)` for every observable `f`.
-/
lemma swap_poincare (f : Fin 2 → ℝ) :
    (1 : ℝ) * Var swapChain f ≤ DirichletForm swapChain f := by
  unfold Var DirichletForm;
  unfold swapChain mean; norm_num [ Fin.sum_univ_two ] ; ring_nf; norm_num;
  linarith [ sq_nonneg ( f 0 - f 1 ) ]

/-- The Poincaré certificate for the swap chain with spectral gap `1`. -/
noncomputable def swapCert : SpectralGapCert swapChain where
  gap := 1
  gap_nonneg := by norm_num
  poincare := swap_poincare

/-
!-- DISPROOF: on f = (1,-1), Pf = -f, so Var(Pf) = Var(f) = 1 > 0 = (1-1)²·Var(f). -- !--

DISPROOF of the squared variance contraction. The bound
`Var(Pf) ≤ (1-γ)²·Var(f)` does NOT follow from a one-sided Poincaré gap alone:
the bipartite swap chain with its gap-`1` certificate violates it on `f = (1, -1)`.
-/
theorem Var_applyP_contraction_false :
    ∃ f : Fin 2 → ℝ,
      ¬ (Var swapChain (applyP swapChain f)
          ≤ (1 - swapCert.gap) ^ 2 * Var swapChain f) := by
  unfold Var applyP swapChain swapCert; norm_num [ Fin.sum_univ_succ, mean ] ; ring_nf
  exact ⟨ fun i => if i = 0 then 1 else 0, by norm_num ⟩

end SpectralChain