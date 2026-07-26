/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Non-Archimedean Information Theory: Min-Entropy Foundations

## Bridge: Tropical Algebra ↔ Cryptographic Entropy ↔ Idempotent Analysis

Min-entropy H_∞(X) = -log(max_x p(x)) is simultaneously:
- The natural entropy of the tropical (min-plus) semifield (ℝ ∪ {∞}, min, +)
- The fundamental resource for cryptographic randomness extraction
- The worst-case measure for post-quantum security analysis

## Impact: post_quantum_security, certified_robustness, tropical_hash_collision
-/

import Mathlib

open Finset Real BigOperators

namespace NonArchInfoTheory

/-- A finitely-supported probability distribution over a finite type α.
    Bridge: connects measure theory to discrete combinatorial probability.
    Impact: foundation for certified_robustness bounds and post_quantum_security. -/
structure FinProbDist (α : Type*) [Fintype α] where
  mass : α → ℝ
  mass_nonneg : ∀ x, 0 ≤ mass x
  mass_sum_one : ∑ x : α, mass x = 1

variable {α : Type*} [Fintype α]

@[ext]
theorem FinProbDist.ext {μ ν : FinProbDist α} (h : ∀ x, μ.mass x = ν.mass x) : μ = ν := by
  cases μ; cases ν; congr; exact funext h

/-- Any probability mass is at most 1. -/
theorem FinProbDist.mass_le_one (μ : FinProbDist α) (x : α) :
    μ.mass x ≤ 1 := by
  calc μ.mass x ≤ ∑ y : α, μ.mass y :=
    Finset.single_le_sum (fun y _ => μ.mass_nonneg y) (Finset.mem_univ x)
  _ = 1 := μ.mass_sum_one

/-! ## Total Variation Distance

These results don't require `Nonempty α`, so we prove them before
introducing that variable. -/

section TotalVariation

variable {α : Type*} [Fintype α]

/-- Total variation distance between two distributions.
    Bridge: connects metric probability theory to information-theoretic stability.
    Impact: lipschitz_certified_robustness — TV distance controls entropy perturbation. -/
noncomputable def totalVariation (μ ν : FinProbDist α) : ℝ :=
  (1 / 2) * ∑ x : α, |μ.mass x - ν.mass x|

/-- Total variation distance is nonnegative. -/
theorem totalVariation_nonneg (μ ν : FinProbDist α) : 0 ≤ totalVariation μ ν := by
  apply mul_nonneg (by norm_num)
  exact Finset.sum_nonneg (fun x _ => abs_nonneg _)

/-- Total variation distance is symmetric. -/
theorem totalVariation_symm (μ ν : FinProbDist α) :
    totalVariation μ ν = totalVariation ν μ := by
  unfold totalVariation; congr 1
  exact Finset.sum_congr rfl (fun x _ => abs_sub_comm _ _)

/-- The self-distance is zero. -/
theorem totalVariation_self (μ : FinProbDist α) : totalVariation μ μ = 0 := by
  unfold totalVariation; simp

/-- Total variation distance is zero iff distributions are equal. -/
theorem totalVariation_eq_zero_iff (μ ν : FinProbDist α) :
    totalVariation μ ν = 0 ↔ μ = ν := by
  unfold totalVariation
  constructor
  · intro h
    have h1 : ∑ x : α, |μ.mass x - ν.mass x| = 0 := by
      rcases mul_eq_zero.mp h with h2 | h2
      · norm_num at h2
      · exact h2
    have h2 := (Finset.sum_eq_zero_iff_of_nonneg (fun x _ => abs_nonneg
      (μ.mass x - ν.mass x))).mp h1
    ext x; have := h2 x (Finset.mem_univ x)
    rwa [abs_eq_zero, sub_eq_zero] at this
  · intro h; subst h; simp

/-- Total variation distance is at most 1.
    Impact: certified_robustness — universal bound on distribution distance. -/
theorem totalVariation_le_one (μ ν : FinProbDist α) : totalVariation μ ν ≤ 1 := by
  unfold totalVariation
  have h : ∀ x : α, |μ.mass x - ν.mass x| ≤ μ.mass x + ν.mass x :=
    fun x => by rw [abs_le]; constructor <;> linarith [μ.mass_nonneg x, ν.mass_nonneg x]
  calc (1 / 2 : ℝ) * ∑ x, |μ.mass x - ν.mass x|
      ≤ (1 / 2 : ℝ) * ∑ x, (μ.mass x + ν.mass x) := by
        apply mul_le_mul_of_nonneg_left
          (Finset.sum_le_sum (fun x _ => h x)) (by norm_num)
    _ = (1 / 2 : ℝ) * (∑ x, μ.mass x + ∑ x, ν.mass x) := by
        rw [Finset.sum_add_distrib]
    _ = 1 := by rw [μ.mass_sum_one, ν.mass_sum_one]; ring

end TotalVariation

/-! ## Uniform Distribution -/

/-- The uniform distribution on a nonempty finite type.
    Bridge: connects combinatorics to maximum-entropy principle.
    Impact: post_quantum_security — uniform is the ideal for randomness extraction. -/
noncomputable def uniformDist (α : Type*) [Fintype α] [Nonempty α] : FinProbDist α where
  mass := fun _ => (1 : ℝ) / (Fintype.card α : ℝ)
  mass_nonneg := fun _ => by positivity
  mass_sum_one := by
    simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- Predicate: a distribution is uniform (all masses equal). -/
def isUniform (μ : FinProbDist α) : Prop :=
  ∀ x y : α, μ.mass x = μ.mass y

/-- The uniform distribution is indeed uniform. -/
theorem uniformDist_isUniform [Nonempty α] : isUniform (uniformDist α) :=
  fun _ _ => rfl

/-! ## Maximum Mass -/

variable [Nonempty α]

/-- The maximum probability mass: max_x p(x).
    In the tropical semifield, this is the idempotent sum ⊕ of probabilities.
    Bridge: tropical algebra (⊕ = max) ↔ probability theory. -/
noncomputable def maxMass (μ : FinProbDist α) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty μ.mass

/-- The maximum mass is achieved by some element. -/
theorem maxMass_exists_witness (μ : FinProbDist α) :
    ∃ x : α, μ.mass x = maxMass μ := by
  obtain ⟨x, _, hx⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty μ.mass
  exact ⟨x, hx.symm⟩

/-- Any mass is at most the maximum mass. -/
theorem mass_le_maxMass (μ : FinProbDist α) (x : α) :
    μ.mass x ≤ maxMass μ :=
  Finset.le_sup' μ.mass (Finset.mem_univ x)

/-- The maximum mass is strictly positive. -/
theorem maxMass_pos (μ : FinProbDist α) : 0 < maxMass μ := by
  by_contra h; push_neg at h
  have h0 : maxMass μ = 0 := le_antisymm h (by
    obtain ⟨x, hx⟩ := maxMass_exists_witness μ; rw [← hx]; exact μ.mass_nonneg x)
  have : (∑ x : α, μ.mass x) = 0 := Finset.sum_eq_zero fun x _ => by
    linarith [mass_le_maxMass μ x, μ.mass_nonneg x]
  linarith [μ.mass_sum_one]

/-- The maximum mass is at most 1. -/
theorem maxMass_le_one (μ : FinProbDist α) : maxMass μ ≤ 1 := by
  obtain ⟨x, hx⟩ := maxMass_exists_witness μ; rw [← hx]; exact μ.mass_le_one x

/-- Lower bound: max mass ≥ 1/|α| (pigeonhole / averaging argument).
    Impact: certified_robustness — worst-case probability lower bound. -/
theorem one_div_card_le_maxMass (μ : FinProbDist α) :
    1 / (Fintype.card α : ℝ) ≤ maxMass μ := by
  have hcard : (0 : ℝ) < Fintype.card α := Nat.cast_pos.mpr Fintype.card_pos
  suffices h : 1 ≤ (Fintype.card α : ℝ) * maxMass μ by rwa [div_le_iff₀' hcard]
  calc (1 : ℝ) = ∑ x : α, μ.mass x := μ.mass_sum_one.symm
    _ ≤ ∑ _ : α, maxMass μ := Finset.sum_le_sum (fun x _ => mass_le_maxMass μ x)
    _ = (Fintype.card α : ℝ) * maxMass μ := by
        simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-! ## Min-Entropy Definition and Properties -/

/-- Min-entropy H_∞(X) = -log(max_x p(x)).
    The fundamental entropy of tropical information theory.
    Bridge: cryptography (min-entropy extractors) ↔ idempotent analysis (Maslov).
    Impact: post_quantum_security — min-entropy quantifies extractable randomness. -/
noncomputable def minEntropy (μ : FinProbDist α) : ℝ :=
  -Real.log (maxMass μ)

/-- Min-entropy is nonnegative for all distributions.
    Impact: post_quantum_security — security parameter is always nonneg. -/
theorem minEntropy_nonneg (μ : FinProbDist α) : 0 ≤ minEntropy μ := by
  unfold minEntropy
  linarith [Real.log_nonpos (le_of_lt (maxMass_pos μ)) (maxMass_le_one μ)]

/-- Min-entropy is bounded by log|α|.
    Bridge: maximum-entropy principle ↔ tropical optimization.
    Impact: certified_robustness — entropy budget is log of alphabet size. -/
theorem minEntropy_le_log_card (μ : FinProbDist α) :
    minEntropy μ ≤ Real.log (Fintype.card α : ℝ) := by
  unfold minEntropy
  have hcard : (0 : ℝ) < Fintype.card α := Nat.cast_pos.mpr Fintype.card_pos
  have h1 := one_div_card_le_maxMass μ
  have h2 : 0 < 1 / (Fintype.card α : ℝ) := by positivity
  have h3 := Real.log_le_log h2 h1
  rw [Real.log_div (by linarith) (by linarith), Real.log_one] at h3; linarith

/-! ## Deterministic Distribution -/

/-- A deterministic distribution concentrated on one point. -/
noncomputable def deterministicDist [DecidableEq α] (a : α) : FinProbDist α where
  mass := fun x => if x = a then 1 else 0
  mass_nonneg := fun x => by split_ifs <;> linarith
  mass_sum_one := by simp [Finset.sum_ite_eq', Finset.mem_univ]

/-- The max mass of a deterministic distribution is 1. -/
theorem deterministicDist_maxMass [DecidableEq α] (a : α) :
    maxMass (deterministicDist a) = 1 := by
  unfold maxMass deterministicDist; simp only
  apply le_antisymm
  · exact Finset.sup'_le _ _ (fun x _ => by split_ifs <;> linarith)
  · calc (1 : ℝ) = (fun (x : α) => if x = a then (1 : ℝ) else 0) a := by simp
      _ ≤ _ := Finset.le_sup' (fun (x : α) => if x = a then (1 : ℝ) else 0)
                  (Finset.mem_univ a)

/-- Min-entropy of a deterministic distribution is zero.
    Impact: deterministic sources provide zero extractable randomness. -/
theorem minEntropy_deterministic_eq_zero [DecidableEq α] (a : α) :
    minEntropy (deterministicDist a) = 0 := by
  unfold minEntropy; rw [deterministicDist_maxMass, Real.log_one, neg_zero]

/-! ## Uniform Distribution Entropy -/

/-- Max mass of the uniform distribution is 1/|α|. -/
theorem uniformDist_maxMass :
    maxMass (uniformDist α) = 1 / (Fintype.card α : ℝ) := by
  unfold maxMass uniformDist; simp only
  exact Finset.sup'_eq_of_forall _ _ (fun _ _ => rfl)

/-- Min-entropy of uniform = log|α|.
    Bridge: maximum-entropy principle ↔ tropical optimization.
    Impact: post_quantum_security — maximum extractable randomness = log|α|. -/
theorem minEntropy_uniform_eq_log_card :
    minEntropy (uniformDist α) = Real.log (Fintype.card α : ℝ) := by
  unfold minEntropy; rw [uniformDist_maxMass]
  have hcard : (0 : ℝ) < Fintype.card α := Nat.cast_pos.mpr Fintype.card_pos
  rw [Real.log_div (by linarith) (by linarith), Real.log_one]; ring

/-! ## Product Distribution -/

variable {β : Type*} [Fintype β] [Nonempty β]

/-- Product distribution of two independent distributions.
    Bridge: independent probability ↔ tensor products in tropical algebra.
    Impact: post_quantum_security — independent components contribute additively. -/
noncomputable def productDist (μ : FinProbDist α) (ν : FinProbDist β) :
    FinProbDist (α × β) where
  mass := fun p => μ.mass p.1 * ν.mass p.2
  mass_nonneg := fun ⟨a, b⟩ => mul_nonneg (μ.mass_nonneg a) (ν.mass_nonneg b)
  mass_sum_one := by
    rw [Fintype.sum_prod_type]
    simp_rw [← Finset.mul_sum, ν.mass_sum_one, mul_one, μ.mass_sum_one]

/-
Key lemma: max of product of nonneg functions = product of maxes.
    Bridge: tropical ⊗ distributes over product spaces.
-/
theorem sup'_product_eq_mul_sup'
    (f : α → ℝ) (g : β → ℝ) (hf : ∀ x, 0 ≤ f x) (hg : ∀ y, 0 ≤ g y) :
    Finset.sup' Finset.univ Finset.univ_nonempty (fun p : α × β => f p.1 * g p.2) =
    Finset.sup' Finset.univ Finset.univ_nonempty f *
    Finset.sup' Finset.univ Finset.univ_nonempty g := by
  refine' le_antisymm _ _;
  · simp +decide [ Finset.sup'_le_iff ];
    exact fun a b => mul_le_mul ( Finset.le_sup' ( fun x => f x ) ( Finset.mem_univ a ) ) ( Finset.le_sup' ( fun x => g x ) ( Finset.mem_univ b ) ) ( hg b ) ( by exact le_trans ( hf a ) ( Finset.le_sup' ( fun x => f x ) ( Finset.mem_univ a ) ) );
  · simp +decide [ Finset.sup'_le_iff ];
    rcases Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) f with ⟨ a, ha ⟩ ; rcases Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) g with ⟨ b, hb ⟩ ; use a, b ; aesop;

/-- Max mass of product = product of max masses.
    Impact: post_quantum_security — joint security decomposes multiplicatively. -/
theorem productDist_maxMass (μ : FinProbDist α) (ν : FinProbDist β) :
    maxMass (productDist μ ν) = maxMass μ * maxMass ν := by
  unfold maxMass productDist; simp only
  exact sup'_product_eq_mul_sup' μ.mass ν.mass μ.mass_nonneg ν.mass_nonneg

/-- H_∞(X×Y) = H_∞(X) + H_∞(Y) for independent distributions.
    Bridge: tropical ⊗ (= +) ↔ entropy additivity under independence.
    Impact: post_quantum_security — independent key material has additive min-entropy. -/
theorem minEntropy_product_eq_add (μ : FinProbDist α) (ν : FinProbDist β) :
    minEntropy (productDist μ ν) = minEntropy μ + minEntropy ν := by
  unfold minEntropy; rw [productDist_maxMass]
  rw [Real.log_mul (ne_of_gt (maxMass_pos μ)) (ne_of_gt (maxMass_pos ν))]; ring

/-! ## Exp-Entropy Identity -/

/-- exp(-H_∞(X)) = max_x p(x): the collision bound.
    Impact: tropical_hash_collision — collision probability is exp(-H_∞). -/
theorem exp_neg_minEntropy_eq_maxMass (μ : FinProbDist α) :
    Real.exp (-minEntropy μ) = maxMass μ := by
  unfold minEntropy; simp only [neg_neg]; exact Real.exp_log (maxMass_pos μ)

/-- The collision probability is at most 1. -/
theorem exp_neg_minEntropy_le_one (μ : FinProbDist α) :
    Real.exp (-minEntropy μ) ≤ 1 := by
  rw [exp_neg_minEntropy_eq_maxMass]; exact maxMass_le_one μ

/-! ## Min-Entropy Characterization -/

/-- Min-entropy = 0 iff max mass = 1.
    Impact: post_quantum_security — zero min-entropy = no extractable randomness. -/
theorem minEntropy_eq_zero_iff (μ : FinProbDist α) :
    minEntropy μ = 0 ↔ maxMass μ = 1 := by
  unfold minEntropy
  constructor
  · intro h
    have hlog : Real.log (maxMass μ) = 0 := by linarith
    rcases Real.log_eq_zero.mp hlog with h3 | h3 | h3
    · linarith [maxMass_pos μ]
    · exact h3
    · linarith [maxMass_pos μ]
  · intro h; rw [h, Real.log_one, neg_zero]

/-- Min-entropy is antitone in max mass. -/
theorem minEntropy_antitone_maxMass (μ ν : FinProbDist α)
    (h : maxMass μ ≤ maxMass ν) :
    minEntropy ν ≤ minEntropy μ := by
  unfold minEntropy; linarith [Real.log_le_log (maxMass_pos μ) h]

/-! ## Tropical Valuation -/

/-- The tropical valuation: v(x) = -log p(x).
    Bridge: probability theory ↔ tropical semifield (ℝ ∪ {∞}, min, +).
    Impact: connects post_quantum_security to tropical geometry. -/
structure TropicalValuation (α : Type*) [Fintype α] where
  val : α → ℝ
  val_nonneg : ∀ x, 0 ≤ val x

/-- Convert a FinProbDist to its tropical valuation. -/
noncomputable def FinProbDist.toTropicalVal (μ : FinProbDist α) :
    TropicalValuation α where
  val := fun x => if μ.mass x = 0 then 0 else -Real.log (μ.mass x)
  val_nonneg := fun x => by
    split_ifs with h
    · exact le_refl 0
    · have h1 : 0 < μ.mass x := lt_of_le_of_ne (μ.mass_nonneg x) (Ne.symm h)
      linarith [Real.log_nonpos (le_of_lt h1) (μ.mass_le_one x)]

/-! ## Idempotent Entropy Axioms -/

/-- Idempotent Shannon-Khinchin axioms for entropy.
    Bridge: axiomatic information theory ↔ Maslov's idempotent probability.
    Impact: post_quantum_security — justifies min-entropy as THE cryptographic entropy. -/
class IdempotentEntropyAxioms (H : ∀ (n : ℕ), (Fin n → ℝ) → ℝ) where
  nonneg : ∀ (n : ℕ) (p : Fin n → ℝ),
    (∀ i, 0 ≤ p i) → (∑ i, p i = 1) → 0 ≤ H n p
  maximality : ∀ (n : ℕ) (p : Fin n → ℝ),
    (∀ i, 0 ≤ p i) → (∑ i, p i = 1) → H n p ≤ Real.log n
  uniform_value : ∀ (n : ℕ), 0 < n →
    H n (fun _ => (1 : ℝ) / n) = Real.log n
  deterministic_zero : ∀ (n : ℕ), 0 < n → ∀ (i : Fin n),
    H n (fun j => if j = i then 1 else 0) = 0

/-! ## Marginal Distributions -/

/-- First marginal of a joint distribution on α × β. -/
noncomputable def marginalFst {β : Type*} [Fintype β]
    (joint : FinProbDist (α × β)) : FinProbDist α where
  mass := fun a => ∑ b : β, joint.mass (a, b)
  mass_nonneg := fun a => Finset.sum_nonneg (fun b _ => joint.mass_nonneg (a, b))
  mass_sum_one := by
    have : ∑ a : α, ∑ b : β, joint.mass (a, b) = ∑ p : α × β, joint.mass p := by
      rw [Fintype.sum_prod_type]
    rw [this, joint.mass_sum_one]

/-- Second marginal of a joint distribution on α × β. -/
noncomputable def marginalSnd {β : Type*} [Fintype β]
    (joint : FinProbDist (α × β)) : FinProbDist β where
  mass := fun b => ∑ a : α, joint.mass (a, b)
  mass_nonneg := fun b => Finset.sum_nonneg (fun a _ => joint.mass_nonneg (a, b))
  mass_sum_one := by
    rw [show ∑ b : β, ∑ a : α, joint.mass (a, b) =
        ∑ a : α, ∑ b : β, joint.mass (a, b) from Finset.sum_comm]
    have : ∑ a : α, ∑ b : β, joint.mass (a, b) = ∑ p : α × β, joint.mass p := by
      rw [Fintype.sum_prod_type]
    rw [this, joint.mass_sum_one]

/-! ## Bernoulli Distribution -/

/-- A Bernoulli distribution with parameter p ∈ [0,1]. -/
noncomputable def bernoulliDist (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    FinProbDist (Fin 2) where
  mass := fun i => if i = 0 then p else 1 - p
  mass_nonneg := fun i => by fin_cases i <;> simp <;> linarith
  mass_sum_one := by rw [Fin.sum_univ_two]; simp

/-
Min-entropy of Bernoulli(p) = -log(max(p, 1-p)).
    Bridge: binary entropy ↔ tropical max operation.
    Impact: post_quantum_security — binary source entropy for bit extraction.
-/
theorem minEntropy_bernoulli (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    minEntropy (bernoulliDist p hp0 hp1) = -Real.log (max p (1 - p)) := by
  congr

/-! ## Counting Lemma -/

/-
|{x : p(x) ≥ t}| ≤ 1/t for t > 0 (Markov-like bound).
    Bridge: counting arguments ↔ tropical probability bounds.
    Impact: certified_robustness — bounds support size above threshold.
-/
theorem count_ge_mass_le_inv (μ : FinProbDist α) (t : ℝ) (ht : 0 < t) :
    ((Finset.univ.filter fun x => t ≤ μ.mass x).card : ℝ) ≤ 1 / t := by
  -- Let S be the set of elements where p(x) ≥ t. Then |S| * t ≤ ∑_{x ∈ S} p(x) ≤ ∑_x p(x) = 1.
  have h_sum : (∑ x ∈ Finset.univ.filter (fun x => t ≤ μ.mass x), μ.mass x) ≤ 1 := by
    exact le_trans ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.filter_subset _ _ ) fun _ _ _ => μ.mass_nonneg _ ) μ.mass_sum_one.le;
  rw [ le_div_iff₀ ht ] ; exact le_trans ( by simpa using Finset.sum_le_sum fun x ( hx : x ∈ Finset.filter ( fun x => t ≤ μ.mass x ) Finset.univ ) => Finset.mem_filter.mp hx |>.2 ) h_sum

/-! ## Rényi Entropy -/

/-- Rényi entropy of order q > 1. Min-entropy is the limit as q → ∞.
    Bridge: Rényi entropy family ↔ tropical deformation.
    Impact: connects post_quantum_security to statistical divergences. -/
noncomputable def renyiEntropy (μ : FinProbDist α) (q : ℝ) (_ : 1 < q) : ℝ :=
  (1 / (1 - q)) * Real.log (∑ x : α, μ.mass x ^ q)

end NonArchInfoTheory