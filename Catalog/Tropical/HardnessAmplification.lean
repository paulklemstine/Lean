/-
Copyright (c) 2025. All rights reserved.

# Hardness Amplification for Tropical Semigroup Actions

## Overview

This file establishes a direct-product hardness amplification theorem for
tropical semigroup actions. The core result is that independent repetition
of tropical action instances compounds hardness multiplicatively at the
level of collision probability and additively at the level of min-entropy.

## Main Results

* `collisionProb_prod` — collision probability is multiplicative for product distributions
* `collisionProb_pi` — collision probability is multiplicative for Fin-indexed products
* `maxProb_prod` — max probability is multiplicative for product distributions
* `maxProb_pi` — max probability is multiplicative for Fin-indexed products
* `minEntropy_prod` — min-entropy is additive for product distributions
* `minEntropy_pi_bound` — min-entropy scales linearly with independent repetitions
* `guessProb_pi_bound` — guessing probability decays exponentially with repetitions
* `tropicalHardnessAmplification` — the headline hardness amplification theorem

## Significance

This is the tropical analogue of direct-product hardness amplification from
complexity theory. It shows that:
1. Algebraic hardness compounds under parallel repetition of tropical actions.
2. A single hard tropical action becomes exponentially harder when repeated.
3. Entropy accumulation enables key derivation from weak tropical sources.

## Cross-Domain Connections

- **Complexity theory**: tropical direct-product theorem / Yao-style amplification
- **Cryptography**: parallel composition of tropical primitives
- **Information theory**: entropy accumulation in nonclassical algebraic settings
- **Statistical mechanics**: entropy extensivity for noninteracting tropical subsystems
-/
import Mathlib

open Finset Real BigOperators Classical

noncomputable section

namespace TropicalHardness

/-! ## Probability Distributions -/

/-- A strictly positive probability distribution on a finite type. -/
structure StrictProbDist (α : Type*) [Fintype α] where
  pmf : α → ℝ
  nonneg : ∀ x, 0 ≤ pmf x
  sum_one : ∑ x : α, pmf x = 1
  pos : ∀ x, 0 < pmf x

/-! ## Maximum Probability (Guessing Probability) -/

/-- The maximum probability (guessing probability) of a distribution.
    This is the probability of the most likely outcome, i.e., the
    optimal single-guess success probability. -/
def maxProb {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : ℝ :=
  Finset.max' (Finset.univ.image p.pmf) (by simp [Finset.image_nonempty])

theorem maxProb_pos {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : 0 < maxProb p := by
  unfold maxProb
  exact lt_of_lt_of_le (p.pos (Classical.arbitrary α))
    (Finset.le_max' _ _ (Finset.mem_image_of_mem _ (Finset.mem_univ _)))

theorem pmf_le_one {α : Type*} [Fintype α]
    (p : StrictProbDist α) (x : α) : p.pmf x ≤ 1 := by
  have : p.pmf x ≤ ∑ y : α, p.pmf y :=
    Finset.single_le_sum (fun y _ => p.nonneg y) (Finset.mem_univ x)
  linarith [p.sum_one]

theorem maxProb_le_one {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : maxProb p ≤ 1 := by
  unfold maxProb
  apply Finset.max'_le
  intro x hx
  simp at hx
  obtain ⟨a, _, rfl⟩ := hx
  exact pmf_le_one p a

theorem pmf_le_maxProb {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) (x : α) : p.pmf x ≤ maxProb p := by
  exact Finset.le_max' _ _ (Finset.mem_image_of_mem _ (Finset.mem_univ _))

theorem exists_eq_maxProb {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : ∃ x : α, p.pmf x = maxProb p := by
  unfold maxProb
  have := Finset.max'_mem (Finset.univ.image p.pmf) (by simp [Finset.image_nonempty])
  simp at this
  exact this

/-! ## Collision Probability -/

/-- **Collision probability** (Rényi collision probability):
    Cp(X) = Σ_x p(x)², the probability that two independent samples collide.
    This is the core quantity for direct-product hardness amplification. -/
def collisionProb {α : Type*} [Fintype α]
    (p : StrictProbDist α) : ℝ :=
  ∑ x : α, p.pmf x ^ 2

theorem collisionProb_pos {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : 0 < collisionProb p := by
  unfold collisionProb
  apply Finset.sum_pos
  · intro x _; exact sq_pos_of_pos (p.pos x)
  · exact Finset.univ_nonempty

/-! ## Min-Entropy -/

/-- **Min-entropy** (Rényi entropy of order ∞):
    H_∞(X) = -log(max_x p(x)) / log(2).
    Measures the worst-case unpredictability of a source. -/
def minEntropy {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : ℝ :=
  -Real.log (maxProb p) / Real.log 2

theorem minEntropy_nonneg {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : 0 ≤ minEntropy p := by
  unfold minEntropy
  apply div_nonneg
  · exact neg_nonneg.mpr (Real.log_nonpos (le_of_lt (maxProb_pos p)) (maxProb_le_one p))
  · exact le_of_lt (Real.log_pos (by norm_num : (1 : ℝ) < 2))

/-! ## Product Distributions -/

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

/-! ## Theorem A: Collision Probability Multiplicativity -/

/-
**Collision probability is multiplicative for product distributions.**
    Cp(X × Y) = Cp(X) · Cp(Y).
    This is the engine behind direct-product hardness amplification.
-/
theorem collisionProb_prod {α β : Type*} [Fintype α] [Fintype β]
    [Nonempty α] [Nonempty β]
    (p : StrictProbDist α) (q : StrictProbDist β) :
    collisionProb (p.prod q) = collisionProb p * collisionProb q := by
  convert Fintype.sum_prod_type ( fun x : α × β => ( p.pmf x.1 * q.pmf x.2 ) ^ 2 ) using 1 ; ring;
  simp +decide only [collisionProb, ← Finset.mul_sum _ _ _, ← sum_mul]

/-! ## Theorem B: Max Probability Multiplicativity -/

/-
The maximum probability of a product distribution is the product
    of the individual maximum probabilities.
-/
theorem maxProb_prod {α β : Type*} [Fintype α] [Fintype β]
    [Nonempty α] [Nonempty β]
    (p : StrictProbDist α) (q : StrictProbDist β) :
    maxProb (p.prod q) = maxProb p * maxProb q := by
  refine' le_antisymm _ _;
  · unfold maxProb;
    simp +decide [ Finset.max' ];
    exact fun a b => mul_le_mul ( Finset.le_sup' ( fun x => p.pmf x ) ( Finset.mem_univ a ) ) ( Finset.le_sup' ( fun x => q.pmf x ) ( Finset.mem_univ b ) ) ( by linarith [ p.nonneg a, q.nonneg b ] ) ( by linarith [ p.nonneg a, q.nonneg b, Finset.le_sup' ( fun x => p.pmf x ) ( Finset.mem_univ a ), Finset.le_sup' ( fun x => q.pmf x ) ( Finset.mem_univ b ) ] );
  · obtain ⟨ a, ha ⟩ := exists_eq_maxProb p
    obtain ⟨ b, hb ⟩ := exists_eq_maxProb q;
    exact Finset.le_max' ( Finset.image ( fun x : α × β => p.pmf x.1 * q.pmf x.2 ) Finset.univ ) _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ ( a, b ) ) ) |> le_trans ( by aesop )

/-! ## Theorem C: Min-Entropy Additivity -/

/-- **Min-entropy is additive for product distributions.**
    H_∞(X × Y) = H_∞(X) + H_∞(Y).
    Independence means worst cases factor independently. -/
theorem minEntropy_prod {α β : Type*} [Fintype α] [Fintype β]
    [Nonempty α] [Nonempty β]
    (p : StrictProbDist α) (q : StrictProbDist β) :
    minEntropy (p.prod q) = minEntropy p + minEntropy q := by
  unfold minEntropy
  rw [maxProb_prod]
  rw [Real.log_mul (ne_of_gt (maxProb_pos p)) (ne_of_gt (maxProb_pos q))]
  ring

/-! ## Fin-indexed Product Distributions -/

/-
Fin-indexed product of strict probability distributions.
    The pmf of the product is the product of the individual pmfs.
-/
def StrictProbDist.pi {α : Type*} [Fintype α]
    (m : ℕ) (X : Fin m → StrictProbDist α) : StrictProbDist (Fin m → α) where
  pmf := fun f => ∏ i : Fin m, (X i).pmf (f i)
  nonneg := fun f => Finset.prod_nonneg (fun i _ => (X i).nonneg (f i))
  sum_one := by
    induction m with
    | zero => simp [Finset.univ_unique]
    | succ n ih =>
    rw [ show ( ∑ x : Fin ( n + 1 ) → α, ∏ i : Fin ( n + 1 ), ( X i ).pmf ( x i ) ) = ∑ x : α × ( Fin n → α ), ( X 0 ).pmf x.1 * ∏ i : Fin n, ( X ( Fin.succ i ) ).pmf ( x.2 i ) from ?_ ];
    · erw [ Finset.sum_product ] ; simp +decide [ ← Finset.mul_sum _ _ _, - Finset.sum_mul, ih ] ;
      exact X 0 |>.sum_one;
    · refine' Finset.sum_bij ( fun x _ => ( x 0, fun i => x i.succ ) ) _ _ _ _ <;> simp +decide [ Fin.prod_univ_succ ];
      · exact fun a₁ a₂ h₁ h₂ => funext fun i => by induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
      · exact fun a b => ⟨ Fin.cons a b, rfl, rfl ⟩
  pos := fun f => Finset.prod_pos (fun i _ => (X i).pos (f i))

/-
Max probability of a Fin-indexed product is the product of max probabilities.
-/
theorem maxProb_pi {α : Type*} [Fintype α] [Nonempty α]
    (m : ℕ) (X : Fin m → StrictProbDist α) :
    maxProb (StrictProbDist.pi m X) = ∏ i : Fin m, maxProb (X i) := by
  refine' le_antisymm ( _ : _ ≤ _ ) ( _ : _ ≥ _ );
  · simp +decide [ StrictProbDist.pi ];
    simp +decide [ maxProb ];
    exact fun a => Finset.prod_le_prod ( fun _ _ => ( X _ ).nonneg _ ) fun i _ => Finset.le_max' ( Finset.image ( X i |> StrictProbDist.pmf ) Finset.univ ) _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) );
  · -- By definition of maxProb, we know that for any $f : Fin m → α$, we have $p(pmf (f)) ≤ maxProb(p)$.
    have h_le_maxProb : ∀ (f : Fin m → α), (∏ i : Fin m, (X i).pmf (f i)) ≤ maxProb (StrictProbDist.pi m X) := by
      intro f;
      exact Finset.le_max' ( Finset.univ.image fun f : Fin m → α => ∏ i, ( X i ).pmf ( f i ) ) _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) );
    choose f hf using fun i => exists_eq_maxProb ( X i );
    simpa only [ ← hf ] using h_le_maxProb f

/-
**Collision probability is multiplicative for Fin-indexed products.**
    Cp(X_1 × ... × X_m) = ∏ᵢ Cp(X_i).
-/
theorem collisionProb_pi {α : Type*} [Fintype α] [Nonempty α]
    (m : ℕ) (X : Fin m → StrictProbDist α) :
    collisionProb (StrictProbDist.pi m X) = ∏ i : Fin m, collisionProb (X i) := by
  induction' m with m ih <;> simp_all +decide [ collisionProb ];
  · left; rfl;
  · convert congr_arg₂ ( · * · ) ( Finset.sum_congr rfl fun _ _ => rfl ) ( ih ( fun i => X i.succ ) ) using 1;
    rotate_left;
    rotate_left;
    exact α;
    exact fun a => ( X 0 |> StrictProbDist.pmf ) a ^ 2;
    exact Finset.univ;
    · simp +decide [ StrictProbDist.pi, Fin.prod_univ_succ, Finset.sum_mul _ _ _ ];
      simp +decide only [mul_pow, Finset.mul_sum _ _ _];
      rw [ ← Finset.sum_product' ];
      refine' Finset.sum_bij ( fun x _ => ( x 0, fun i => x i.succ ) ) _ _ _ _ <;> simp +decide;
      · exact fun a₁ a₂ h₁ h₂ => funext fun i => by induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
      · exact fun a b => ⟨ Fin.cons a b, rfl, rfl ⟩;
    · exact Fin.prod_univ_succ _

/-! ## Hardness Amplification: Guessing Probability Bound -/

/-- **Exponential decay of adversarial success probability.**
    If each instance has guessing probability at most δ,
    then the m-fold product has guessing probability at most δ^m.
    This is the core hardness amplification inequality. -/
theorem guessProb_pi_bound {α : Type*} [Fintype α] [Nonempty α]
    (m : ℕ) (X : Fin m → StrictProbDist α) (δ : ℝ)
    (_hδ_pos : 0 < δ)
    (hguess : ∀ i, maxProb (X i) ≤ δ) :
    maxProb (StrictProbDist.pi m X) ≤ δ ^ m := by
  rw [maxProb_pi]
  calc ∏ i : Fin m, maxProb (X i)
      ≤ ∏ i : Fin m, δ := Finset.prod_le_prod
        (fun i _ => le_of_lt (maxProb_pos (X i))) (fun i _ => hguess i)
    _ = δ ^ m := by simp [Finset.prod_const]

/-
**Min-entropy scales linearly with the number of independent instances.**
    If each instance has min-entropy at least k, then the m-fold product
    has min-entropy at least m · k.
    This is the tropical direct-product hardness amplification theorem.
-/
theorem minEntropy_pi_bound {α : Type*} [Fintype α] [Nonempty α]
    (m : ℕ) (X : Fin m → StrictProbDist α) (k : ℝ)
    (hmin : ∀ i, k ≤ minEntropy (X i)) :
    (m : ℝ) * k ≤ minEntropy (StrictProbDist.pi m X) := by
  have h_exp_decay : minEntropy (StrictProbDist.pi m X) = ∑ i : Fin m, minEntropy (X i) := by
    unfold minEntropy;
    rw [ maxProb_pi, Real.log_prod ];
    · rw [ ← Finset.sum_div _ _ _, Finset.sum_neg_distrib ];
    · exact fun i _ => ne_of_gt ( maxProb_pos _ );
  exact h_exp_decay.symm ▸ le_trans ( by simp +decide ) ( Finset.sum_le_sum fun i _ => hmin i )

/-! ## Tropical Semigroup Action Corollary -/

/-- A **tropical semigroup action instance** is a finitely supported
    probability distribution arising from a tropical matrix power or
    similar algebraic operation. We model this abstractly as a
    StrictProbDist equipped with entropy guarantees. -/
structure TropicalActionInstance (α : Type*) [Fintype α] [Nonempty α] where
  /-- The output distribution of the tropical action instance -/
  dist : StrictProbDist α
  /-- Lower bound on the min-entropy of this instance -/
  entropyBound : ℝ
  /-- Certificate that the entropy bound holds -/
  h_entropy : entropyBound ≤ minEntropy dist

/-- **Tropical Semigroup Hardness Amplification.**
    Given m independent tropical action instances each with min-entropy
    at least k, the joint source has min-entropy at least m · k,
    and the adversary's guessing probability decays exponentially. -/
theorem tropicalHardnessAmplification
    {α : Type*} [Fintype α] [Nonempty α]
    (m : ℕ) (instances : Fin m → TropicalActionInstance α)
    (k : ℝ) (hk : ∀ i, k ≤ (instances i).entropyBound) :
    (m : ℝ) * k ≤
      minEntropy (StrictProbDist.pi m (fun i => (instances i).dist)) := by
  apply minEntropy_pi_bound
  intro i
  exact le_trans (hk i) ((instances i).h_entropy)

end TropicalHardness

end