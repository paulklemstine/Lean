/-
Copyright (c) 2025. All rights reserved.

# Tropical Mutual Information and Min-Plus Data Processing Inequality

## Overview

This file develops tropical mutual information based on Rényi min-entropy,
and proves the Data Processing Inequality for deterministic channels.

## Main Results

* `maxMass_pos`, `maxMass_le_one` — basic max mass bounds
* `minEntropy_nonneg` — H_∞(X) ≥ 0
* `minEntropy_le_log_card` — H_∞(X) ≤ log |α|
* `minEntropy_product_eq_add` — H_∞(X⊗Y) = H_∞(X) + H_∞(Y)
* `maxMass_joint_le_marginalFst` — max p(x,y) ≤ max p_X(x)
* `condMinEntropy_le_minEntropy_fst` — H_∞(X|Y) ≤ H_∞(X)
* `tropicalMI_nonneg` — I_∞(X;Y) ≥ 0
* `tropicalMI_independent_eq_zero` — I_∞ = 0 for independence
* `tropicalMI_deterministic_DPI` — I_∞(X;f(Y)) ≤ I_∞(X;Y)

## Bridge

Connects tropical algebra to differential privacy, post-quantum
security, and certified adversarial robustness via min-entropy bounds.
-/
import Mathlib

open Finset Real BigOperators Classical

noncomputable section

namespace TropicalMI

variable {α : Type*} [Fintype α] [Nonempty α]

/-! ## Probability Distributions -/

/-- A finite probability distribution: nonneg pmf summing to 1. -/
structure FDist (α : Type*) [Fintype α] where
  pmf : α → ℝ
  pmf_nonneg : ∀ x, 0 ≤ pmf x
  pmf_sum : ∑ x : α, pmf x = 1

/-! ## Max Mass -/

/-- **Max mass**: the maximum probability assigned to any outcome.
    This is the adversary's optimal one-shot guessing probability.
    Bridge: connects to differential privacy and Grover search. -/
def FDist.maxMass (p : FDist α) : ℝ :=
  Finset.max' (Finset.univ.image p.pmf) (Finset.univ_nonempty.image _)

theorem FDist.pmf_le_maxMass (p : FDist α) (x : α) : p.pmf x ≤ p.maxMass :=
  Finset.le_max' _ _ (Finset.mem_image_of_mem _ (Finset.mem_univ _))

theorem FDist.exists_maxMass_witness (p : FDist α) : ∃ x, p.pmf x = p.maxMass := by
  have h := Finset.max'_mem _ (Finset.univ_nonempty.image p.pmf)
  rw [Finset.mem_image] at h; obtain ⟨x, _, hx⟩ := h; exact ⟨x, hx⟩

theorem FDist.maxMass_pos (p : FDist α) : 0 < p.maxMass := by
  -- Since the pmf is nonnegative, its maximum is also nonnegative.
  have h_nonneg : 0 ≤ p.maxMass := by
    exact le_trans ( p.pmf_nonneg ( Classical.arbitrary α ) ) ( p.pmf_le_maxMass _ );
  refine' h_nonneg.lt_of_ne' fun h => _;
  exact absurd ( p.pmf_sum ▸ Finset.sum_nonpos fun x _ => le_trans ( p.pmf_le_maxMass x ) h.le ) ( by norm_num )

theorem FDist.maxMass_le_one (p : FDist α) : p.maxMass ≤ 1 := by
  obtain ⟨ x, hx ⟩ := p.exists_maxMass_witness; linarith [ p.pmf_le_maxMass x, show p.pmf x ≤ 1 from p.pmf_sum ▸ Finset.single_le_sum ( fun a _ => p.pmf_nonneg a ) ( Finset.mem_univ x ) ] ;

theorem FDist.pmf_le_one (p : FDist α) (x : α) : p.pmf x ≤ 1 := by
  exact p.pmf_le_maxMass x |> le_trans <| p.maxMass_le_one

theorem FDist.maxMass_ge_inv_card (p : FDist α) :
    1 / (Fintype.card α : ℝ) ≤ p.maxMass := by
  rw [ div_le_iff₀' ];
  · have := Finset.sum_le_sum fun x ( hx : x ∈ Finset.univ ) => p.pmf_le_maxMass x;
    convert this using 1 <;> simp +decide [ p.pmf_sum ];
  · exact Nat.cast_pos.mpr Fintype.card_pos

/-! ## Min-Entropy -/

/-- **Min-entropy** (Rényi ∞-entropy): H_∞(X) = -log(max_x p(x)).
    The fundamental measure of worst-case unpredictability.
    Bridge: connects to differential privacy and post-quantum search. -/
def FDist.minEntropy (p : FDist α) : ℝ := -Real.log p.maxMass

/-
**H_∞(X) ≥ 0**: min-entropy is nonneg since maxMass ≤ 1.
    Bridge: thermodynamic ground-state energy ≥ 0.
-/
theorem FDist.minEntropy_nonneg (p : FDist α) : 0 ≤ p.minEntropy := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( FDist.maxMass_pos p |> le_of_lt ) ( FDist.maxMass_le_one p ) )

/-
**H_∞(X) ≤ log |α|**: uniform maximizes min-entropy.
    Bridge: post-quantum search needs O(2^{H_∞}) queries.
-/
theorem FDist.minEntropy_le_log_card (p : FDist α) :
    p.minEntropy ≤ Real.log (Fintype.card α) := by
  -- By definition of minEntropy, we have p.minEntropy = -Real.log p.maxMass.
  unfold FDist.minEntropy;
  rw [ ← Real.log_inv, Real.log_le_log_iff ] <;> norm_num <;> try linarith [ p.maxMass_pos ] ;
  · exact inv_le_of_inv_le₀ ( Nat.cast_pos.mpr Fintype.card_pos ) ( by simpa using p.maxMass_ge_inv_card );
  · exact Fintype.card_pos

/-
**Guessing probability**: exp(-H_∞) = maxMass.
    Bridge: certified adversarial robustness.
-/
theorem FDist.guessing_probability (p : FDist α) :
    Real.exp (-p.minEntropy) = p.maxMass := by
  rw [ FDist.minEntropy, neg_neg, Real.exp_log ( FDist.maxMass_pos p ) ]

/-
**Search complexity**: exp(H_∞) = 1/maxMass.
    Bridge: Grover search lower bound.
-/
theorem FDist.search_complexity (p : FDist α) :
    Real.exp p.minEntropy = 1 / p.maxMass := by
  rw [ FDist.minEntropy, Real.exp_neg, Real.exp_log ( FDist.maxMass_pos p ), one_div ]

/-! ## Marginal Distributions -/

/-- **First marginal**: p_X(x) = Σ_y p(x,y).
    Bridge: partial trace in quantum information. -/
def FDist.marginalFst {β : Type*} [Fintype β]
    (p : FDist (α × β)) : FDist α where
  pmf := fun x => ∑ y : β, p.pmf (x, y)
  pmf_nonneg := fun x => Finset.sum_nonneg (fun y _ => p.pmf_nonneg (x, y))
  pmf_sum := by
    simp only [← Fintype.sum_prod_type']; exact p.pmf_sum

/-- **Second marginal**: p_Y(y) = Σ_x p(x,y).
    Bridge: partial trace in quantum information. -/
def FDist.marginalSnd {β : Type*} [Fintype β]
    (p : FDist (α × β)) : FDist β where
  pmf := fun y => ∑ x : α, p.pmf (x, y)
  pmf_nonneg := fun y => Finset.sum_nonneg (fun x _ => p.pmf_nonneg (x, y))
  pmf_sum := by
    rw [← p.pmf_sum, show ∑ y : β, ∑ x : α, p.pmf (x, y) =
        ∑ p_1 : α × β, p.pmf p_1 from by
      rw [Fintype.sum_prod_type]; apply Finset.sum_comm]

/-- Joint probability ≤ first marginal. -/
theorem FDist.joint_le_marginalFst {β : Type*} [Fintype β]
    (p : FDist (α × β)) (x : α) (y : β) :
    p.pmf (x, y) ≤ p.marginalFst.pmf x :=
  Finset.single_le_sum (fun y' _ => p.pmf_nonneg (x, y')) (Finset.mem_univ y)

/-- Joint probability ≤ second marginal. -/
theorem FDist.joint_le_marginalSnd {β : Type*} [Fintype β]
    (p : FDist (α × β)) (x : α) (y : β) :
    p.pmf (x, y) ≤ p.marginalSnd.pmf y :=
  Finset.single_le_sum (fun x' _ => p.pmf_nonneg (x', y)) (Finset.mem_univ x)

/-
**Max mass marginalization (first)**: max p(x,y) ≤ max p_X(x).
    Bridge: information-theoretic data processing.
-/
theorem FDist.maxMass_joint_le_marginalFst {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.maxMass ≤ p.marginalFst.maxMass := by
  obtain ⟨ x, hx ⟩ := FDist.exists_maxMass_witness p;
  exact hx ▸ p.joint_le_marginalFst x.1 x.2 |> le_trans <| p.marginalFst.pmf_le_maxMass _

/-
**Max mass marginalization (second)**: max p(x,y) ≤ max p_Y(y).
-/
theorem FDist.maxMass_joint_le_marginalSnd {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.maxMass ≤ p.marginalSnd.maxMass := by
  obtain ⟨ x, hx ⟩ := FDist.exists_maxMass_witness p;
  exact hx ▸ le_trans ( FDist.joint_le_marginalSnd _ _ _ ) ( FDist.pmf_le_maxMass _ _ )

/-
**H_∞(X) ≤ H_∞(X,Y)**: joint entropy ≥ marginal entropy.
    Bridge: quantum strong subadditivity (tropical analog).
-/
theorem FDist.minEntropy_joint_ge_fst {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.marginalFst.minEntropy ≤ p.minEntropy := by
  exact neg_le_neg ( Real.log_le_log ( by exact p.maxMass_pos ) ( by exact p.maxMass_joint_le_marginalFst ) )

/-
H_∞(Y) ≤ H_∞(X,Y).
-/
theorem FDist.minEntropy_joint_ge_snd {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.marginalSnd.minEntropy ≤ p.minEntropy := by
  simp +decide [ FDist.minEntropy ];
  exact Real.log_le_log ( FDist.maxMass_pos _ ) ( FDist.maxMass_joint_le_marginalSnd _ )

/-! ## Product Distributions -/

/-- **Product distribution** (independence): p⊗q. -/
def FDist.prod {β : Type*} [Fintype β]
    (p : FDist α) (q : FDist β) : FDist (α × β) where
  pmf := fun ⟨a, b⟩ => p.pmf a * q.pmf b
  pmf_nonneg := fun ⟨a, b⟩ => mul_nonneg (p.pmf_nonneg a) (q.pmf_nonneg b)
  pmf_sum := by
    change ∑ x : α × β, p.pmf x.1 * q.pmf x.2 = 1
    rw [Fintype.sum_prod_type]
    simp_rw [← Finset.mul_sum, q.pmf_sum, mul_one, p.pmf_sum]

/-
maxMass(p⊗q) = maxMass(p) · maxMass(q).
    Bridge: tensor product, thermodynamic extensivity.
-/
theorem FDist.maxMass_prod_eq {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist α) (q : FDist β) :
    (p.prod q).maxMass = p.maxMass * q.maxMass := by
  unfold FDist.maxMass;
  refine' le_antisymm _ _;
  · simp +decide [ Finset.max', FDist.prod ];
    exact fun a b => mul_le_mul ( Finset.le_sup' ( fun x => p.pmf x ) ( Finset.mem_univ a ) ) ( Finset.le_sup' ( fun x => q.pmf x ) ( Finset.mem_univ b ) ) ( q.pmf_nonneg b ) ( Finset.le_sup'_of_le ( fun x => p.pmf x ) ( Finset.mem_univ a ) ( p.pmf_nonneg a ) );
  · obtain ⟨ a, ha ⟩ := FDist.exists_maxMass_witness p;
    obtain ⟨ b, hb ⟩ := FDist.exists_maxMass_witness q;
    refine' le_trans _ ( Finset.le_max' _ _ <| Finset.mem_image_of_mem _ <| Finset.mem_univ ( a, b ) );
    unfold FDist.prod; aesop;

/-
**H_∞(X⊗Y) = H_∞(X) + H_∞(Y)**: min-entropy is additive for independence.
    Bridge: thermodynamic extensivity, quantum tensor products.
-/
theorem FDist.minEntropy_product_eq_add {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist α) (q : FDist β) :
    (p.prod q).minEntropy = p.minEntropy + q.minEntropy := by
  unfold FDist.minEntropy;
  rw [ FDist.maxMass_prod_eq, Real.log_mul ( ne_of_gt ( FDist.maxMass_pos p ) ) ( ne_of_gt ( FDist.maxMass_pos q ) ), neg_add ]

/-- The first marginal of a product is the first factor. -/
theorem FDist.marginalFst_prod {β : Type*} [Fintype β]
    (p : FDist α) (q : FDist β) (x : α) :
    (p.prod q).marginalFst.pmf x = p.pmf x := by
  simp [FDist.marginalFst, FDist.prod, ← Finset.mul_sum, q.pmf_sum]

/-! ## Conditional Min-Entropy -/

/-- **Adversarial guess mass**: Σ_y max_x p(x,y).
    The adversary's total success probability observing Y.
    Bridge: Bayesian MAP estimation, differential privacy. -/
def FDist.adversarialGuessMass {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : ℝ :=
  ∑ y : β, Finset.max' (Finset.univ.image (fun x => p.pmf (x, y)))
    (Finset.univ_nonempty.image _)

/-
Adversarial guess mass ≤ 1.
-/
theorem FDist.adversarialGuessMass_le_one {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : p.adversarialGuessMass ≤ 1 := by
  refine' le_trans _ ( show 1 ≥ ∑ y, ∑ x, p.pmf ( x, y ) from _ );
  · refine' Finset.sum_le_sum fun y _ => _;
    simp +decide [ Finset.max' ];
    exact fun x => Finset.single_le_sum ( fun a _ => p.pmf_nonneg ( a, y ) ) ( Finset.mem_univ x );
  · rw [ ← Finset.sum_comm ];
    rw [ ← p.pmf_sum, Fintype.sum_prod_type ]

/-
maxMass ≤ adversarialGuessMass.
-/
theorem FDist.maxMass_le_adversarialGuessMass {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : p.maxMass ≤ p.adversarialGuessMass := by
  obtain ⟨ x, hx ⟩ := FDist.exists_maxMass_witness p;
  refine' hx ▸ le_trans _ ( Finset.single_le_sum ( fun y _ => _ ) ( Finset.mem_univ x.2 ) );
  · exact Finset.le_max' ( image ( fun x_1 => p.pmf ( x_1, x.2 ) ) univ ) _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) );
  · simp +decide [ Finset.max' ];
    exact ⟨ Classical.arbitrary α, p.pmf_nonneg _ ⟩

/-- Adversarial guess mass is positive. -/
theorem FDist.adversarialGuessMass_pos {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : 0 < p.adversarialGuessMass := by
  exact lt_of_lt_of_le (FDist.maxMass_pos p) (FDist.maxMass_le_adversarialGuessMass p)

/-
maxMass of first marginal ≤ adversarial guess mass.
    Key inequality for MI non-negativity.
-/
theorem FDist.adversarialGuessMass_ge_maxMass_fst {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.marginalFst.maxMass ≤ p.adversarialGuessMass := by
  -- By definition of maxMass, we know that for any x, marginalFst.pmf x ≤ adversarialGuessMass.
  have h_le : ∀ x : α, p.marginalFst.pmf x ≤ p.adversarialGuessMass := by
    intro x
    have h_le : ∀ y : β, p.pmf (x, y) ≤ (Finset.univ.image (fun x => p.pmf (x, y))).max' (by
    exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ x ) ⟩) := by
      exact fun y => Finset.le_max' ( image ( fun x => p.pmf ( x, y ) ) univ ) _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) )
    generalize_proofs at *;
    exact Finset.sum_le_sum fun y _ => h_le y;
  have := Classical.choose_spec ( FDist.exists_maxMass_witness p.marginalFst );
  exact this ▸ h_le _

/-- **Conditional min-entropy**: H_∞(X|Y) = -log(Σ_y max_x p(x,y)).
    The operationally correct definition for adversarial settings.
    Bridge: differential privacy, quantum conditional min-entropy. -/
def FDist.condMinEntropy {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : ℝ :=
  -Real.log p.adversarialGuessMass

/-
**H_∞(X|Y) ≤ H_∞(X)**: conditioning helps the adversary.
    Bridge: information-theoretic security, quantum uncertainty.
-/
theorem FDist.condMinEntropy_le_minEntropy_fst {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.condMinEntropy ≤ p.marginalFst.minEntropy := by
  apply neg_le_neg;
  exact Real.log_le_log ( FDist.maxMass_pos _ ) ( FDist.adversarialGuessMass_ge_maxMass_fst _ )

/-
H_∞(X|Y) ≥ 0.
-/
theorem FDist.condMinEntropy_nonneg {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : 0 ≤ p.condMinEntropy := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( FDist.adversarialGuessMass_pos p |> le_of_lt ) ( FDist.adversarialGuessMass_le_one p ) )

/-! ## Tropical Mutual Information -/

/-- **Tropical mutual information**: I_∞(X;Y) = H_∞(X) - H_∞(X|Y).
    Measures worst-case information that Y reveals about X.
    Bridge: differential privacy, certified robustness, post-quantum security. -/
def FDist.tropicalMI {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : ℝ :=
  p.marginalFst.minEntropy - p.condMinEntropy

/-- **Tropical MI non-negativity**: I_∞(X;Y) ≥ 0.
    The adversary's information leakage is always nonneg.
    Bridge: non-negativity of information leakage. -/
theorem FDist.tropicalMI_nonneg {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) : 0 ≤ p.tropicalMI := by
  unfold FDist.tropicalMI
  linarith [p.condMinEntropy_le_minEntropy_fst]

/-
**I_∞ = 0 for independent distributions**.
    Bridge: quantum product states have zero entanglement.
-/
theorem FDist.tropicalMI_independent_eq_zero {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist α) (q : FDist β) :
    (p.prod q).tropicalMI = 0 := by
  unfold FDist.tropicalMI;
  unfold FDist.condMinEntropy FDist.minEntropy;
  rw [ show ( p.prod q ).marginalFst = p from ?_, show ( p.prod q ).adversarialGuessMass = p.maxMass from ?_ ];
  · ring;
  · unfold FDist.adversarialGuessMass FDist.prod;
    -- By definition of maxMass, we know that for each y, the maximum of p(x) * q(y) over x is p.maxMass * q(y).
    have h_max : ∀ y, (Finset.univ.image (fun x => p.pmf x * q.pmf y)).max' (by simp) = p.maxMass * q.pmf y := by
      intro y;
      refine' le_antisymm _ _ <;> simp +decide [ Finset.max' ];
      · exact fun x => mul_le_mul_of_nonneg_right ( p.pmf_le_maxMass x ) ( q.pmf_nonneg y );
      · exact Exists.elim ( p.exists_maxMass_witness ) fun x hx => ⟨ x, by rw [ hx ] ⟩;
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
    rw [ q.pmf_sum, mul_one ];
  · unfold FDist.prod FDist.marginalFst;
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, p.pmf_sum, q.pmf_sum ]

/-- **I_∞(X;Y) ≤ H_∞(X)**: MI bounded by entropy.
    Bridge: channel capacity bounds, Holevo bound. -/
theorem FDist.tropicalMI_le_minEntropy {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.tropicalMI ≤ p.marginalFst.minEntropy := by
  unfold FDist.tropicalMI
  linarith [p.condMinEntropy_nonneg]

/-! ## Pushforward and Data Processing Inequality -/

/-- **Pushforward** through a function f : α → β. -/
def FDist.pushforward {β : Type*} [Fintype β]
    (p : FDist α) (f : α → β) : FDist β where
  pmf := fun y => ∑ x ∈ Finset.univ.filter (fun a => f a = y), p.pmf x
  pmf_nonneg := fun y => Finset.sum_nonneg (fun x _ => p.pmf_nonneg x)
  pmf_sum := by
    rw [← p.pmf_sum, ← Finset.sum_biUnion]
    · congr 1; ext x; simp [Finset.mem_biUnion, Finset.mem_filter]
    · intro y _ z _ hyz
      exact Finset.disjoint_filter.mpr (fun x _ h1 h2 => hyz (h1 ▸ h2))

/-
**maxMass increases under pushforward**: coarsening increases max probability.
    Bridge: hash collision probability, birthday attack.
-/
theorem FDist.maxMass_pushforward_ge {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist α) (f : α → β) :
    p.maxMass ≤ (p.pushforward f).maxMass := by
  obtain ⟨ x, hx ⟩ := p.exists_maxMass_witness;
  have h_pushforward : p.pmf x ≤ (p.pushforward f).pmf (f x) := by
    exact Finset.single_le_sum ( fun a _ => p.pmf_nonneg a ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rfl ⟩ );
  exact hx ▸ h_pushforward.trans ( FDist.pmf_le_maxMass _ _ )

/-
**H_∞ decreases under pushforward**: min-entropy decreases under processing.
    Bridge: neural network information bottleneck, hash security.
-/
theorem FDist.minEntropy_pushforward_le {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist α) (f : α → β) :
    (p.pushforward f).minEntropy ≤ p.minEntropy := by
  exact neg_le_neg ( Real.log_le_log ( FDist.maxMass_pos _ ) ( FDist.maxMass_pushforward_ge _ _ ) )

/-
**Pushforward on second coordinate** of a joint distribution.
-/
def FDist.pushforwardSnd {β γ : Type*} [Fintype β] [Fintype γ]
    (p : FDist (α × β)) (f : β → γ) : FDist (α × γ) where
  pmf := fun ⟨x, z⟩ => ∑ y ∈ Finset.univ.filter (fun y => f y = z), p.pmf (x, y)
  pmf_nonneg := fun ⟨_, _⟩ => Finset.sum_nonneg (fun y _ => p.pmf_nonneg _)
  pmf_sum := by
    convert p.pmf_sum using 1;
    rw [ Finset.sum_sigma' ];
    refine' Finset.sum_bij ( fun x _ => ( x.fst.1, x.snd ) ) _ _ _ _ <;> simp +decide;
    grind

/-
First marginal preserved under pushforwardSnd.
-/
theorem FDist.marginalFst_pushforwardSnd_eq {β γ : Type*}
    [Fintype β] [Fintype γ]
    (p : FDist (α × β)) (f : β → γ) (x : α) :
    (p.pushforwardSnd f).marginalFst.pmf x = p.marginalFst.pmf x := by
  -- By definition of marginalFst, we can expand the right-hand side.
  simp [FDist.marginalFst, FDist.pushforwardSnd];
  rw [ Finset.sum_sigma' ];
  refine' Finset.sum_bij ( fun y hy => y.snd ) _ _ _ _ <;> aesop

/-
**Adversarial guess mass DPI**: Σ_z max_x p(x,z) ≤ Σ_y max_x p(x,y).
    The key lemma for the tropical DPI.
    Bridge: certified privacy amplification.
-/
theorem FDist.adversarialGuessMass_pushforwardSnd_le {β γ : Type*}
    [Fintype β] [Fintype γ] [Nonempty β] [Nonempty γ]
    (p : FDist (α × β)) (f : β → γ) :
    (p.pushforwardSnd f).adversarialGuessMass ≤ p.adversarialGuessMass := by
  unfold FDist.adversarialGuessMass;
  refine' le_trans ( Finset.sum_le_sum fun y _ => _ ) _;
  use fun y => ∑ z ∈ Finset.univ.filter ( fun z => f z = y ), Finset.max' ( Finset.univ.image ( fun x => p.pmf ( x, z ) ) ) ( Finset.univ_nonempty.image _ );
  · simp +decide [ Finset.max', FDist.pushforwardSnd ];
    exact fun a => Finset.sum_le_sum fun b _ => Finset.le_sup' ( fun x => p.pmf ( x, b ) ) ( Finset.mem_univ a );
  · rw [ ← Finset.sum_biUnion ];
    · rw [ show ( Finset.univ.biUnion fun i => { z | f z = i } ) = Finset.univ from Finset.eq_univ_of_forall fun x => Finset.mem_biUnion.mpr ⟨ f x, Finset.mem_univ _, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rfl ⟩ ⟩ ];
    · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;

/-
**H_∞(X|f(Y)) ≥ H_∞(X|Y)**: coarsening increases conditional entropy.
    Bridge: privacy amplification via post-processing.
-/
theorem FDist.condMinEntropy_pushforwardSnd_ge {β γ : Type*}
    [Fintype β] [Fintype γ] [Nonempty β] [Nonempty γ]
    (p : FDist (α × β)) (f : β → γ) :
    p.condMinEntropy ≤ (p.pushforwardSnd f).condMinEntropy := by
  apply neg_le_neg;
  exact Real.log_le_log ( FDist.adversarialGuessMass_pos _ ) ( FDist.adversarialGuessMass_pushforwardSnd_le _ _ )

/-
**Tropical Data Processing Inequality**: I_∞(X;f(Y)) ≤ I_∞(X;Y).
    Post-processing Y cannot increase information about X.
    The central theorem of tropical information theory.

    Bridge: differential privacy post-processing guarantee,
    neural network layerwise information bounds,
    post-quantum security channel processing.
-/
theorem FDist.tropicalMI_deterministic_DPI {β γ : Type*}
    [Fintype β] [Fintype γ] [Nonempty β] [Nonempty γ]
    (p : FDist (α × β)) (f : β → γ) :
    (p.pushforwardSnd f).tropicalMI ≤ p.tropicalMI := by
  unfold FDist.tropicalMI;
  rw [ show ( p.pushforwardSnd f ).marginalFst.minEntropy = p.marginalFst.minEntropy from ?_ ];
  · exact sub_le_sub_left ( FDist.condMinEntropy_pushforwardSnd_ge p f ) _;
  · unfold FDist.minEntropy;
    unfold FDist.maxMass;
    simp +decide [ Finset.max', FDist.marginalFst_pushforwardSnd_eq ]

/-! ## Chain Rule -/

/-
**Chain rule for max mass**: max_{x,y} f(x,y) = max_x (max_y f(x,y)).
    Bridge: dynamic programming (Bellman optimality),
    tropical matrix multiplication.
-/
theorem FDist.maxMass_chain_rule {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) :
    p.maxMass = Finset.max' (Finset.univ.image (fun x =>
      Finset.max' (Finset.univ.image (fun y => p.pmf (x, y)))
        (Finset.univ_nonempty.image _)))
      (Finset.univ_nonempty.image _) := by
  refine' le_antisymm _ _;
  · unfold FDist.maxMass;
    simp +decide [ Finset.max' ];
    have := Finset.exists_max_image Finset.univ ( fun x => p.pmf x ) ⟨ ( Classical.arbitrary α, Classical.arbitrary β ), Finset.mem_univ _ ⟩ ; aesop;
  · simp +decide [ Finset.le_max', FDist.maxMass ]

/-! ## Privacy Applications -/

/-
**Privacy bound**: if H_∞(X|Y) ≥ k, adversary success ≤ exp(-k).
    Bridge: differential privacy, certified robustness.
-/
theorem FDist.tropical_privacy_bound {β : Type*} [Fintype β] [Nonempty β]
    (p : FDist (α × β)) (k : ℝ) (hk : k ≤ p.condMinEntropy) :
    p.adversarialGuessMass ≤ Real.exp (-k) := by
  rw [ ← Real.log_le_log_iff ( FDist.adversarialGuessMass_pos p ) ( Real.exp_pos _ ) ];
  simp_all +decide [ Real.log_exp, FDist.condMinEntropy ];
  linarith

/-- **Privacy amplification via processing**: post-processing preserves privacy.
    Bridge: composition theorems in differential privacy. -/
theorem FDist.privacy_amplification {β γ : Type*}
    [Fintype β] [Fintype γ] [Nonempty β] [Nonempty γ]
    (p : FDist (α × β)) (f : β → γ) (δ : ℝ)
    (hδ : p.adversarialGuessMass ≤ δ) :
    (p.pushforwardSnd f).adversarialGuessMass ≤ δ :=
  le_trans (FDist.adversarialGuessMass_pushforwardSnd_le p f) hδ

end TropicalMI

end