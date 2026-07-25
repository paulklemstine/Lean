/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Log-Sum-Exp Variational Formula (Gibbs Variational Principle)

This file proves the finite-dimensional Gibbs variational principle:

  τ * log (∑ᵢ exp(xᵢ/τ)) = sup { ∑ᵢ pᵢxᵢ + τ * H(p) | p ∈ Δₙ }

where H(p) = -∑ᵢ pᵢ log pᵢ is Shannon entropy and Δₙ is the probability simplex.

The proof proceeds via the KL-divergence route:
1. Show that the free energy objective equals τ log Z minus τ * KL(p ∥ q)
   where q is the softmax/Gibbs distribution.
2. Use log x ≤ x - 1 to establish KL nonnegativity.
3. Conclude the upper bound and attainment at the softmax distribution.

## Main Results

* `partitionFun_pos` — positivity of partition function
* `softmaxProb_isProbVec` — softmax defines a probability vector
* `freeEnergy_le_lse` — upper bound: free energy ≤ τ log Z
* `freeEnergy_eq_lse_at_softmax` — attainment at softmax
* `lse_variational_formula` — the exact supremum identity

## Cross-Domain Significance

This theorem connects:
- **Convex analysis**: log-sum-exp as convex conjugate of negative entropy
- **Information theory**: KL divergence nonnegativity
- **Statistical mechanics**: free energy variational principle
- **Machine learning**: softmax as entropy-regularized optimizer
- **Tropical geometry**: dequantization bridge (τ → 0⁺ limit gives max)
-/

import Mathlib

open Finset BigOperators Real

/-! ## Section 1: Definitions -/

/-- A probability vector: nonneg entries summing to 1. -/
def IsProbVec {n : ℕ} (p : Fin n → ℝ) : Prop :=
  (∀ i, 0 ≤ p i) ∧ (∑ i, p i) = 1

/-- Shannon entropy term: -∑ᵢ pᵢ log pᵢ with 0 log 0 = 0 convention. -/
noncomputable def shannonEntropyTerm {n : ℕ} (p : Fin n → ℝ) : ℝ :=
  -∑ i, if p i = 0 then 0 else p i * Real.log (p i)

/-- Free energy objective: ∑ᵢ pᵢxᵢ + τ * H(p). -/
noncomputable def freeEnergyObj {n : ℕ} (τ : ℝ) (x p : Fin n → ℝ) : ℝ :=
  ∑ i, p i * x i + τ * shannonEntropyTerm p

/-- Partition function: Z = ∑ᵢ exp(xᵢ/τ). -/
noncomputable def partitionFun {n : ℕ} (τ : ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, Real.exp (x i / τ)

/-- Softmax / Gibbs probability: qᵢ = exp(xᵢ/τ) / Z. -/
noncomputable def softmaxProb {n : ℕ} (τ : ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Real.exp (x i / τ) / partitionFun τ x

/-! ## Section 2: Basic Properties of Partition Function and Softmax -/

theorem partitionFun_pos {n : ℕ} (hn : 0 < n) (τ : ℝ) (x : Fin n → ℝ) :
    0 < partitionFun τ x := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩

theorem softmaxProb_pos {n : ℕ} (hn : 0 < n) (τ : ℝ) (x : Fin n → ℝ) (i : Fin n) :
    0 < softmaxProb τ x i := by
  exact div_pos ( Real.exp_pos _ ) ( partitionFun_pos hn τ x )

theorem softmaxProb_nonneg {n : ℕ} (hn : 0 < n) (τ : ℝ) (x : Fin n → ℝ) (i : Fin n) :
    0 ≤ softmaxProb τ x i :=
  le_of_lt (softmaxProb_pos hn τ x i)

theorem softmaxProb_sum {n : ℕ} (hn : 0 < n) (τ : ℝ) (x : Fin n → ℝ) :
    ∑ i : Fin n, softmaxProb τ x i = 1 := by
  unfold softmaxProb;
  unfold partitionFun; rw [ ← Finset.sum_div _ _ _, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ] ;

theorem softmaxProb_isProbVec {n : ℕ} (hn : 0 < n) (τ : ℝ) (x : Fin n → ℝ) :
    IsProbVec (softmaxProb τ x) :=
  ⟨fun i => softmaxProb_nonneg hn τ x i, softmaxProb_sum hn τ x⟩

/-
Log of softmax probability: log(qᵢ) = xᵢ/τ - log Z.
-/
theorem log_softmaxProb {n : ℕ} (hn : 0 < n) (τ : ℝ) (x : Fin n → ℝ) (i : Fin n) :
    Real.log (softmaxProb τ x i) = x i / τ - Real.log (partitionFun τ x) := by
  unfold softmaxProb partitionFun;
  rw [ Real.log_div ( by positivity ) ( by exact ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ i, Finset.mem_univ _ ⟩ ), Real.log_exp ]

/-! ## Section 3: KL Divergence and Gibbs Inequality -/

/-
Scalar KL inequality: for u ≥ 0 and v > 0, u * log(u/v) ≥ u - v.
    This is the key analytic inequality underlying KL nonnegativity.
-/
theorem scalar_kl_ineq (u v : ℝ) (hu : 0 ≤ u) (hv : 0 < v) :
    u - v ≤ (if u = 0 then 0 else u * Real.log (u / v)) := by
  by_cases hu0 : u = 0 <;> simp_all +decide;
  · grind +qlia;
  · have := Real.log_le_sub_one_of_pos ( div_pos hv ( lt_of_le_of_ne hu ( Ne.symm hu0 ) ) );
    rw [ Real.log_div ] at * <;> first | positivity | ring_nf at * ; nlinarith [ mul_inv_cancel₀ hu0 ] ;

/-
Finite Gibbs inequality (KL divergence nonnegativity):
    For probability vectors p and strictly positive q,
    ∑ᵢ pᵢ log(pᵢ/qᵢ) ≥ 0 (with 0 log 0 = 0 convention).
-/
theorem gibbs_inequality_finite {n : ℕ} (p q : Fin n → ℝ)
    (hp : IsProbVec p) (hq_pos : ∀ i, 0 < q i) (hq_sum : (∑ i, q i) = 1) :
    0 ≤ ∑ i, if p i = 0 then 0 else p i * Real.log (p i / q i) := by
  -- Applying the scalar_kl_ineq inequality for each i, we get p i - q i ≤ (if p i = 0 then 0 else p i * log (p i / q i)).
  have h_scalar : ∀ i, p i - q i ≤ (if p i = 0 then 0 else p i * Real.log (p i / q i)) := by
    exact fun i => by simpa [ * ] using scalar_kl_ineq ( p i ) ( q i ) ( hp.1 i ) ( hq_pos i ) ;
  exact le_trans ( by norm_num [ hp.2, hq_sum ] ) ( Finset.sum_le_sum fun i _ => h_scalar i )

/-! ## Section 4: Free Energy Upper Bound -/

/-
The free energy of any probability vector is at most τ * log Z.
    This is the upper bound half of the variational principle.
-/
theorem freeEnergy_le_lse {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ) (x p : Fin n → ℝ)
    (hp : IsProbVec p) :
    freeEnergyObj τ x p ≤ τ * Real.log (partitionFun τ x) := by
  -- By definition of $freeEnergyObj$, we have
  have h_free_energy : freeEnergyObj τ x p = ∑ i, p i * x i - τ * (∑ i, if p i = 0 then 0 else p i * Real.log (p i)) := by
    unfold freeEnergyObj shannonEntropyTerm; ring;
  -- By definition of $softmaxProb$, we have
  have h_softmax : ∑ i, p i * (x i / τ - Real.log (partitionFun τ x)) = (∑ i, p i * x i) / τ - (∑ i, p i) * Real.log (partitionFun τ x) := by
    simp +decide only [mul_sub, sum_sub_distrib, sum_div, mul_div_assoc, sum_mul];
  have h_gibbs : ∑ i, (if p i = 0 then 0 else p i * Real.log (p i / softmaxProb τ x i)) ≥ 0 := by
    apply gibbs_inequality_finite p (softmaxProb τ x) hp (fun i => softmaxProb_pos hn τ x i) (softmaxProb_sum hn τ x);
  -- By definition of $softmaxProb$, we have $\log(p_i / softmaxProb τ x i) = \log(p_i) - \log(softmaxProb τ x i)$.
  have h_log_softmax : ∀ i, (if p i = 0 then 0 else p i * Real.log (p i / softmaxProb τ x i)) = (if p i = 0 then 0 else p i * Real.log (p i)) - p i * (x i / τ - Real.log (partitionFun τ x)) := by
    intro i; split_ifs <;> simp_all +decide [ Real.log_div, ne_of_gt, Real.exp_pos ] ;
    rw [ Real.log_div ( by positivity ) ( by exact ne_of_gt ( softmaxProb_pos hn τ x i ) ), log_softmaxProb hn τ x i ] ; ring;
  simp_all +decide [ Finset.sum_ite ];
  rw [ div_le_iff₀' hτ ] at h_gibbs ; rw [ hp.2 ] at h_gibbs ; linarith

/-! ## Section 5: Attainment at Softmax -/

/-
The free energy objective evaluated at the softmax distribution
    equals τ * log Z exactly.
-/
theorem freeEnergy_eq_lse_at_softmax {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ)
    (x : Fin n → ℝ) :
    freeEnergyObj τ x (softmaxProb τ x) = τ * Real.log (partitionFun τ x) := by
  unfold freeEnergyObj shannonEntropyTerm;
  simp +decide [ Finset.sum_ite, Finset.filter_ne', ne_of_gt ( softmaxProb_pos hn τ x _ ) ];
  -- Substitute log_softmaxProb into the sum.
  have h_subst : ∑ i, softmaxProb τ x i * Real.log (softmaxProb τ x i) = ∑ i, softmaxProb τ x i * (x i / τ - Real.log (partitionFun τ x)) := by
    exact Finset.sum_congr rfl fun i _ => by rw [ log_softmaxProb hn τ x i ] ;
  simp_all +decide [ mul_sub, ← mul_div_assoc, ← Finset.sum_div _ _ _ ];
  simp +decide [ mul_div_cancel_left₀ _ hτ.ne', ← Finset.sum_mul _ _ _, softmaxProb_sum hn τ x ]

/-- Combined attainment theorem: the softmax distribution is a valid probability
    vector that achieves the supremum of free energy. -/
theorem lse_variational_formula_attained {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ)
    (x : Fin n → ℝ) :
    IsProbVec (softmaxProb τ x) ∧
    freeEnergyObj τ x (softmaxProb τ x) = τ * Real.log (∑ i : Fin n, Real.exp (x i / τ)) :=
  ⟨softmaxProb_isProbVec hn τ x, freeEnergy_eq_lse_at_softmax hn τ hτ x⟩

/-! ## Section 6: Supremum Formulation -/

/-
**Gibbs Variational Principle / Log-Sum-Exp Duality**:

    τ * log(∑ᵢ exp(xᵢ/τ)) = sup { ∑ᵢ pᵢxᵢ + τ H(p) | p is a probability vector }

    This is the finite-dimensional Legendre–Fenchel duality between log-sum-exp
    and negative Shannon entropy on the probability simplex.
-/
theorem lse_variational_formula {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ)
    (x : Fin n → ℝ) :
    τ * Real.log (∑ i : Fin n, Real.exp (x i / τ)) =
      sSup {r : ℝ | ∃ p : Fin n → ℝ, IsProbVec p ∧ r = freeEnergyObj τ x p} := by
  rw [ @csSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · exact ⟨ _, ⟨ fun i => 1 / n, ⟨ fun i => by positivity, by norm_num [ hn.ne' ] ⟩, rfl ⟩ ⟩;
  · rintro _ ⟨ p, hp, rfl ⟩ ; exact freeEnergy_le_lse hn τ hτ x p hp;
  · exact fun w hw => ⟨ _, ⟨ softmaxProb τ x, softmaxProb_isProbVec hn τ x, rfl ⟩, hw.trans_le <| freeEnergy_eq_lse_at_softmax hn τ hτ x ▸ le_rfl ⟩

/-- Equivalent optimizer form: there exists a probability vector achieving the
    supremum, and all probability vectors have free energy at most this value. -/
theorem lse_variational_optimizer {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ)
    (x : Fin n → ℝ) :
    ∃ p, IsProbVec p ∧
      freeEnergyObj τ x p = τ * Real.log (partitionFun τ x) ∧
      ∀ q, IsProbVec q → freeEnergyObj τ x q ≤ freeEnergyObj τ x p := by
  exact ⟨softmaxProb τ x, softmaxProb_isProbVec hn τ x,
    freeEnergy_eq_lse_at_softmax hn τ hτ x,
    fun q hq => freeEnergy_eq_lse_at_softmax hn τ hτ x ▸ freeEnergy_le_lse hn τ hτ x q hq⟩