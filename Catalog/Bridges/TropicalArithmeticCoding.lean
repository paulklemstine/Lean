/-
Copyright (c) 2025 Tropical Information Theory Project. All rights reserved.

# Tropical Arithmetic Coding: Shannon-Optimal Min-Plus Compression

## Bridge: Idempotent Analysis ↔ Source Coding ↔ Algorithmic Information

This file establishes that optimal compression is a tropical variational principle.

Key results:
1. `tropical_shannon_lower_bound`: Kraft-admissible ℓ ⟹ H(μ) ≤ E_μ[ℓ].
2. `shannonEntropy_eq_optimal_kraft_length`: `-log p(x)` achieves equality.
3. `kraft_product_admissible`: Independent composition preserves Kraft admissibility.
4. `minEntropy_le_shannonEntropy`: Min-entropy ≤ Shannon entropy.
5. `universal_tropical_code_optimal`: Universal descriptions are tropically optimal.
-/

import Mathlib

open Finset Real BigOperators

namespace TropicalCoding

/-! ## Probability Distributions -/

/-- A finitely-supported probability distribution. -/
structure FinProbDist (α : Type*) [Fintype α] where
  mass : α → ℝ
  mass_nonneg : ∀ x, 0 ≤ mass x
  mass_sum_one : ∑ x : α, mass x = 1

variable {α : Type*} [Fintype α] [Nonempty α]

/-- Any probability mass is at most 1. -/
theorem FinProbDist.mass_le_one (μ : FinProbDist α) (x : α) : μ.mass x ≤ 1 := by
  calc μ.mass x ≤ ∑ y : α, μ.mass y :=
    Finset.single_le_sum (fun y _ => μ.mass_nonneg y) (Finset.mem_univ x)
  _ = 1 := μ.mass_sum_one

/-- Maximum probability mass. -/
noncomputable def maxMass (μ : FinProbDist α) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty μ.mass

/-- Any mass is at most maxMass. -/
theorem mass_le_maxMass (μ : FinProbDist α) (x : α) : μ.mass x ≤ maxMass μ :=
  Finset.le_sup' μ.mass (Finset.mem_univ x)

/-- maxMass is positive. -/
theorem maxMass_pos (μ : FinProbDist α) : 0 < maxMass μ := by
  by_contra h; push_neg at h
  have h0 : maxMass μ = 0 := le_antisymm h (by
    obtain ⟨x, _, hx⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty) μ.mass
    rw [show maxMass μ = μ.mass x from hx]; exact μ.mass_nonneg x)
  have : (∑ x : α, μ.mass x) = 0 := Finset.sum_eq_zero fun x _ => by
    linarith [mass_le_maxMass μ x, μ.mass_nonneg x]
  linarith [μ.mass_sum_one]

/-- maxMass is at most 1. -/
theorem maxMass_le_one (μ : FinProbDist α) : maxMass μ ≤ 1 := by
  apply Finset.sup'_le; intro x _; exact μ.mass_le_one x

/-- Min-entropy: H_∞(μ) = -log(max_x p(x)). -/
noncomputable def minEntropy (μ : FinProbDist α) : ℝ := -Real.log (maxMass μ)

/-! ## Section 1: Shannon Entropy -/

/-- Shannon entropy H(μ) = -∑ p(x) · log(p(x)), using natural logarithm.
    Convention: 0 · log(0) = 0. -/
noncomputable def shannonEntropy (μ : FinProbDist α) : ℝ :=
  -∑ a : α, if μ.mass a = 0 then 0 else μ.mass a * Real.log (μ.mass a)

/-- Shannon entropy is nonneg. -/
theorem shannonEntropy_nonneg (μ : FinProbDist α) : 0 ≤ shannonEntropy μ := by
  unfold shannonEntropy; rw [neg_nonneg]
  apply Finset.sum_nonpos; intro a _
  split_ifs with h
  · exact le_refl 0
  · exact mul_nonpos_of_nonneg_of_nonpos
      (le_of_lt (lt_of_le_of_ne (μ.mass_nonneg a) (Ne.symm h)))
      (Real.log_nonpos (le_of_lt (lt_of_le_of_ne (μ.mass_nonneg a) (Ne.symm h)))
        (μ.mass_le_one a))

/-- For positive distributions, entropy simplifies. -/
theorem shannonEntropy_pos_eq (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    shannonEntropy μ = -∑ a : α, μ.mass a * Real.log (μ.mass a) := by
  unfold shannonEntropy; congr 1
  apply Finset.sum_congr rfl; intro a _; simp [ne_of_gt (hpos a)]

/-! ## Section 2: Tropical Kraft Admissibility -/

/-- A code length ℓ : α → ℝ is Kraft-admissible if ∑ exp(-ℓ(a)) ≤ 1. -/
def TropicalKraftAdmissible (ℓ : α → ℝ) : Prop :=
  ∑ a : α, Real.exp (-ℓ a) ≤ 1

/-- Shannon information content is Kraft-admissible for full-support distributions. -/
theorem shannonInfo_kraft_admissible (μ : FinProbDist α)
    (hpos : ∀ a, 0 < μ.mass a) :
    TropicalKraftAdmissible (fun a => -Real.log (μ.mass a)) := by
  unfold TropicalKraftAdmissible; simp only [neg_neg]
  conv_lhs => arg 2; ext a; rw [Real.exp_log (hpos a)]
  exact le_of_eq μ.mass_sum_one

/-! ## Section 3: The Shannon Lower Bound (Gibbs Inequality) -/

/-
Key lemma: ∑ p(a) log(exp(-ℓ(a))/p(a)) ≤ ∑ exp(-ℓ(a)) - 1.
-/
theorem gibbs_sum_le (μ : FinProbDist α) (ℓ : α → ℝ)
    (hpos : ∀ a, 0 < μ.mass a) :
    ∑ a, μ.mass a * Real.log (Real.exp (-ℓ a) / μ.mass a) ≤
    (∑ a, Real.exp (-ℓ a)) - 1 := by
  -- For each $a$, we have $\mu(a) \log(\exp(-\ell(a)) / \mu(a)) \leq \exp(-\ell(a)) - \mu(a)$.
  have h_ineq (a : α) : μ.mass a * Real.log (Real.exp (-ℓ a) / μ.mass a) ≤ Real.exp (-ℓ a) - μ.mass a := by
    nlinarith [ hpos a, Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos ( -ℓ a ) ) ( hpos a ) ), Real.exp_pos ( -ℓ a ), mul_div_cancel₀ ( Real.exp ( -ℓ a ) ) ( ne_of_gt ( hpos a ) ) ];
  exact le_trans ( Finset.sum_le_sum fun _ _ => h_ineq _ ) ( by simp +decide [ μ.mass_sum_one ] )

/-
**Tropical Shannon Lower Bound**: H(μ) ≤ E_μ[ℓ] for Kraft-admissible ℓ.
-/
theorem tropical_shannon_lower_bound
    (μ : FinProbDist α) (ℓ : α → ℝ)
    (hpos : ∀ a, 0 < μ.mass a)
    (hKraft : TropicalKraftAdmissible ℓ) :
    shannonEntropy μ ≤ ∑ a, μ.mass a * ℓ a := by
  -- Use gibbs_sum_le to get $\sum p(a)\log(\exp(-ℓ(a))/p(a)) \leq \sum \exp(-ℓ(a)) - 1 \leq 0$ (by hKraft).
  have h_gibbs : ∑ a, μ.mass a * Real.log (Real.exp (-ℓ a) / μ.mass a) ≤ 0 := by
    exact le_trans ( gibbs_sum_le μ ℓ hpos ) ( sub_nonpos_of_le hKraft );
  -- Substitute the expression for $\log(\exp(-ℓ(a))/p(a))$ into the inequality.
  have h_subst : ∑ a, μ.mass a * (-ℓ a - Real.log (μ.mass a)) ≤ 0 := by
    exact h_gibbs.trans' ( Finset.sum_le_sum fun a _ => by rw [ Real.log_div ( by positivity ) ( by linarith [ hpos a ] ), Real.log_exp ] );
  simp_all +decide [ mul_sub, Finset.sum_sub_distrib ];
  grind +suggestions

/-- Expected length of Shannon information = entropy. -/
theorem shannonEntropy_eq_optimal_kraft_length
    (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    ∑ a, μ.mass a * (-Real.log (μ.mass a)) = shannonEntropy μ := by
  rw [shannonEntropy_pos_eq μ hpos]; simp [mul_neg, Finset.sum_neg_distrib]

/-- Optimal code exists: Shannon information achieves the entropy bound. -/
theorem optimal_code_exists (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    ∃ ℓ : α → ℝ, TropicalKraftAdmissible ℓ ∧
    ∑ a, μ.mass a * ℓ a = shannonEntropy μ :=
  ⟨_, shannonInfo_kraft_admissible μ hpos, shannonEntropy_eq_optimal_kraft_length μ hpos⟩

/-- **Tropical information content suboptimality**. -/
theorem tropical_information_content_suboptimality
    (μ : FinProbDist α) (ℓ : α → ℝ)
    (hpos : ∀ a, 0 < μ.mass a)
    (hKraft : TropicalKraftAdmissible ℓ) :
    (∃ C : ℝ, ∀ a, -Real.log (μ.mass a) ≤ ℓ a + C) ∧
    shannonEntropy μ ≤ ∑ a, μ.mass a * ℓ a := by
  refine ⟨?_, tropical_shannon_lower_bound μ ℓ hpos hKraft⟩
  use Finset.sup' Finset.univ Finset.univ_nonempty (fun a => -Real.log (μ.mass a) - ℓ a)
  intro a; linarith [Finset.le_sup' (fun a => -Real.log (μ.mass a) - ℓ a) (Finset.mem_univ a)]

/-! ## Section 4: KL Divergence -/

/-- KL divergence D(p ‖ q). -/
noncomputable def klDivergence (p q : α → ℝ) : ℝ :=
  ∑ a, p a * Real.log (p a / q a)

/-
KL divergence is nonneg.
-/
theorem kl_divergence_nonneg (p q : α → ℝ)
    (hp_pos : ∀ a, 0 < p a) (hq_pos : ∀ a, 0 < q a)
    (hp_sum : ∑ a, p a = 1) (hq_sum : ∑ a, q a ≤ 1) :
    0 ≤ klDivergence p q := by
  -- By definition of $klDivergence$, we know that
  have h_kl_def : klDivergence p q = -∑ a, p a * Real.log (q a / p a) := by
    unfold klDivergence;
    rw [ ← Finset.sum_neg_distrib, Finset.sum_congr rfl ] ; intros ; rw [ ← mul_neg, ← Real.log_inv, inv_div ];
  -- By the properties of logarithms, we know that for any $a$, $p(a) \log(q(a)/p(a)) \leq q(a) - p(a)$.
  have h_log_ineq : ∀ a, p a * Real.log (q a / p a) ≤ q a - p a := by
    exact fun a => by nlinarith only [ hp_pos a, hq_pos a, Real.log_le_sub_one_of_pos ( div_pos ( hq_pos a ) ( hp_pos a ) ), mul_div_cancel₀ ( q a ) ( ne_of_gt ( hp_pos a ) ) ] ;
  exact h_kl_def.symm ▸ neg_nonneg_of_nonpos ( le_trans ( Finset.sum_le_sum fun _ _ => h_log_ineq _ ) ( by simp +decide [ hp_sum, hq_sum ] ) )

/-! ## Section 5: Kraft Admissibility Composition -/

/-
Product of Kraft-admissible codes is admissible.
-/
theorem kraft_product_admissible
    {β : Type*} [Fintype β]
    (f : α → ℝ) (g : β → ℝ)
    (hf : TropicalKraftAdmissible f) (hg : TropicalKraftAdmissible g) :
    ∑ p : α × β, Real.exp (-(f p.1 + g p.2)) ≤ 1 := by
  convert mul_le_mul hf hg ( by exact Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ ) zero_le_one using 1;
  · simp +decide only [neg_add, exp_add, Fintype.sum_prod_type, mul_sum _ _ _];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => by rw [ Finset.sum_mul _ _ _ ] );
  · norm_num

/-! ## Section 6: Min-Entropy ≤ Shannon Entropy -/

/-
Shannon entropy dominates min-entropy.
-/
theorem minEntropy_le_shannonEntropy (μ : FinProbDist α)
    (hpos : ∀ a, 0 < μ.mass a) :
    minEntropy μ ≤ shannonEntropy μ := by
  have h_log_le : ∀ a, Real.log (μ.mass a) ≤ Real.log (maxMass μ) := by
    exact fun a => Real.log_le_log ( hpos a ) ( mass_le_maxMass μ a );
  have h_sum_le : ∑ a, μ.mass a * Real.log (μ.mass a) ≤ ∑ a, μ.mass a * Real.log (maxMass μ) := by
    exact Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_left ( h_log_le a ) ( le_of_lt ( hpos a ) );
  simp_all +decide [ ← Finset.sum_mul _ _ _, FinProbDist.mass_sum_one ];
  exact neg_le_neg ( by simpa [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', ne_of_gt ( hpos _ ) ] using h_sum_le )

/-! ## Section 7: Tropical Min-Plus Algebraic Properties -/

/-- Min is associative. -/
theorem tropical_min_associative (a b c : ℝ) :
    min a (min b c) = min (min a b) c := (min_assoc a b c).symm

/-- Min distributes over addition. -/
theorem tropical_min_add_distrib (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) := by linarith [min_add_add_right a b c]

/-
Tropical Kraft convexity: min of admissible codes has Kraft sum ≤ 2.
-/
theorem kraft_tropical_convex (ℓ₁ ℓ₂ : α → ℝ)
    (h₁ : TropicalKraftAdmissible ℓ₁) (h₂ : TropicalKraftAdmissible ℓ₂) :
    ∑ a, Real.exp (-min (ℓ₁ a) (ℓ₂ a)) ≤ 2 := by
  -- By definition of min, we have exp(-min(ℓ₁, ℓ₂)) = max(exp(-ℓ₁), exp(-ℓ₂)).
  have h_exp_min : ∀ a, Real.exp (-min (ℓ₁ a) (ℓ₂ a)) = max (Real.exp (-ℓ₁ a)) (Real.exp (-ℓ₂ a)) := by
    intro a; rw [ min_def ] ; split_ifs <;> simp +decide [ * ] ;
    linarith;
  simp_all +decide [ TropicalKraftAdmissible ];
  exact le_trans ( Finset.sum_le_sum fun _ _ => show Max.max ( Real.exp ( -ℓ₁ _ ) ) ( Real.exp ( -ℓ₂ _ ) ) ≤ Real.exp ( -ℓ₁ _ ) + Real.exp ( -ℓ₂ _ ) by apply max_le_add_of_nonneg <;> positivity ) ( by rw [ Finset.sum_add_distrib ] ; linarith )

/-! ## Section 8: Universal Tropical Coding -/

/-- A description method. -/
structure DescriptionMethod (α : Type*) where
  descLength : α → ℕ

/-- Universality. -/
def IsUniversal {α : Type*} (U : DescriptionMethod α) : Prop :=
  ∀ M : DescriptionMethod α, ∃ C : ℕ, ∀ x, U.descLength x ≤ M.descLength x + C

/-- Tropical code length. -/
noncomputable def tropicalCodeLength {α : Type*} (M : DescriptionMethod α) (x : α) : ℝ :=
  (M.descLength x : ℝ)

/-- **Universal tropical code optimality**. -/
theorem universal_tropical_code_optimal
    {α : Type*} (U : DescriptionMethod α) (hU : IsUniversal U)
    (M : DescriptionMethod α) :
    ∃ C : ℕ, ∀ x, tropicalCodeLength U x ≤ tropicalCodeLength M x + C := by
  obtain ⟨C, hC⟩ := hU M
  exact ⟨C, fun x => by simp only [tropicalCodeLength]; exact_mod_cast hC x⟩

/-- Composition of universality bounds. -/
theorem universal_is_optimal
    {α : Type*} (U : DescriptionMethod α) (hU : IsUniversal U)
    (M₁ M₂ : DescriptionMethod α) :
    ∃ C₁ C₂ : ℕ, ∀ x,
      tropicalCodeLength U x ≤ tropicalCodeLength M₁ x + C₁ ∧
      tropicalCodeLength U x ≤ tropicalCodeLength M₂ x + C₂ := by
  obtain ⟨C₁, h₁⟩ := universal_tropical_code_optimal U hU M₁
  obtain ⟨C₂, h₂⟩ := universal_tropical_code_optimal U hU M₂
  exact ⟨C₁, C₂, fun x => ⟨h₁ x, h₂ x⟩⟩

/-! ## Section 9: Gibbs / Statistical Mechanics -/

/-- Gibbs partition bound. -/
theorem gibbs_partition_bound (ℓ : α → ℝ) (hKraft : TropicalKraftAdmissible ℓ) :
    ∑ a, Real.exp (-ℓ a) ≤ 1 := hKraft

/-- Free energy nonneg. -/
theorem free_energy_nonneg (ℓ : α → ℝ) (hKraft : TropicalKraftAdmissible ℓ)
    (hne : 0 < ∑ a, Real.exp (-ℓ a)) :
    0 ≤ -Real.log (∑ a, Real.exp (-ℓ a)) := by
  rw [neg_nonneg]; exact Real.log_nonpos (le_of_lt hne) hKraft

/-! ## Section 10: Bridge Theorems -/

/-- Source coding bridge: tropical Kraft ⟹ Shannon bound. -/
theorem tropical_source_coding_bound
    (μ : FinProbDist α) (ℓ : α → ℝ)
    (hpos : ∀ a, 0 < μ.mass a)
    (hKraft : TropicalKraftAdmissible ℓ) :
    shannonEntropy μ ≤ ∑ a, μ.mass a * ℓ a :=
  tropical_shannon_lower_bound μ ℓ hpos hKraft

/-- Tropical and bound. -/
theorem tropical_and_bound (a b : ℝ) : min a b ≤ a := min_le_left a b

/-! ## Section 11: Min-Plus Convolution -/

/-- Min-plus convolution: (f ⋆ₜ g)(z) = inf_x (f(x) + g(z - x)). -/
noncomputable def tropicalConvolution [DecidableEq α] [AddCommGroup α]
    (f g : α → ℝ) : α → ℝ :=
  fun z => ⨅ x : α, f x + g (z - x)

/-
Min-plus convolution is bounded above by any decomposition.
-/
theorem tropicalConvolution_le [DecidableEq α] [AddCommGroup α]
    (f g : α → ℝ) (x y : α) :
    tropicalConvolution f g (x + y) ≤ f x + g y := by
  -- By definition of infimum, for any $z$, we have $f(z) + g((x + y) - z) \geq \inf_{z} (f(z) + g((x + y) - z))$.
  have h_inf : ∀ z : α, f z + g ((x + y) - z) ≥ sInf (Set.range (fun z => f z + g ((x + y) - z))) := by
    exact fun z => csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self _ );
  simpa using h_inf x

end TropicalCoding