/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VI: diversity lower bounds via total variation

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The previous files compute the price of universality `log₂ Cₛ` exactly in a
number of structured situations (mutually singular classes, constant-composition
classes, products, libraries).  This file supplies the missing *general* lower
bound: a quantitative statement saying that a class pays for universality
exactly in proportion to how *spread out* its members are, measured by total
variation distance.

The key inequality is the elementary identity
`∑ₓ max (p x) (q x) = 1 + ‖p − q‖_TV`, which turns the Shtarkov sum — a
supremum-of-likelihoods object — into a statistical distance.  Consequences:

* the price of universality is **strictly positive** as soon as the class
  contains two distinct sources (`price_pos_of_ne`): no nontrivial class of
  sources admits a free universal decompressor;
* the price is **monotone** under enlarging the class (`shtarkovSum_reindex_le`,
  `price_reindex_le`), so specialising a decompressor can never hurt;
* combined with the additivity of the price over independent blocks
  (`price_prod_eq`) the total-variation bound *tensorises*: `k` blocks of a
  class containing two sources at total-variation distance `δ` cost at least
  `k · log₂ (1 + δ)` bits (`price_prod_self_ge`, `price_pow_ge`).

This is the sharp qualitative answer to the falsifiability gate of the mission:
bits *do* move from the message to the shared decompressor, and the amount that
moves is bounded below by a statistical-distance functional of the class.

## Main results

* `totalVariation`, `sum_max_eq_one_add_totalVariation`;
* `one_add_totalVariation_le_shtarkovSum` — `1 + ‖p_θ − p_θ'‖_TV ≤ Cₛ`;
* `logb_one_add_totalVariation_le_price` — the same in bits;
* `shtarkovSum_eq_one_iff` — `Cₛ = 1` **iff** all members of the class coincide;
* `price_pos_of_ne` — strict positivity of the price for a nondegenerate class;
* `shtarkovSum_reindex_le`, `price_reindex_le` — monotonicity in the class;
* `price_prod_self_ge`, `price_pow_ge` — tensorised diversity lower bound.

## Application keywords

universal compression, minimax redundancy, Shtarkov sum, total variation,
price of universality, tensorisation
-/

import NumberTheory.UniversalRedundancyAlgebra

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X]

/-- Total variation distance between two mass functions on a finite space,
`‖p − q‖_TV = ½ ∑ₓ |p x − q x|`. -/
noncomputable def totalVariation (p q : X → ℝ) : ℝ := (∑ x, |p x - q x|) / 2

lemma totalVariation_nonneg (p q : X → ℝ) : 0 ≤ totalVariation p q := by
  refine div_nonneg (Finset.sum_nonneg fun x _ => abs_nonneg _) (by norm_num)

lemma totalVariation_eq_zero_iff {p q : X → ℝ} :
    totalVariation p q = 0 ↔ ∀ x, p x = q x := by
  unfold totalVariation
  rw [div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · intro x
      have := (Finset.sum_eq_zero_iff_of_nonneg
        (fun x _ => abs_nonneg (p x - q x))).1 h x (Finset.mem_univ x)
      have : p x - q x = 0 := by simpa [abs_eq_zero] using this
      linarith
    · exact absurd h (by norm_num)
  · intro h
    left
    exact Finset.sum_eq_zero fun x _ => by simp [h x]

/-- The elementary identity turning a pointwise maximum of two mass functions
into a statistical distance: `∑ₓ max (p x) (q x) = 1 + ‖p − q‖_TV`. -/
lemma sum_max_eq_one_add_totalVariation {p q : X → ℝ}
    (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∑ x, max (p x) (q x) = 1 + totalVariation p q := by
  have hpt : ∀ x : X, max (p x) (q x) = (p x + q x + |p x - q x|) / 2 := by
    intro x
    rcases le_total (p x) (q x) with h | h
    · rw [max_eq_right h, abs_of_nonpos (by linarith)]; ring
    · rw [max_eq_left h, abs_of_nonneg (by linarith)]; ring
  calc ∑ x, max (p x) (q x)
      = ∑ x, ((p x + q x + |p x - q x|) / 2) := Finset.sum_congr rfl fun x _ => hpt x
    _ = ((∑ x, p x) + (∑ x, q x) + ∑ x, |p x - q x|) / 2 := by
        rw [← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_add_distrib]
    _ = 1 + totalVariation p q := by rw [hp, hq]; unfold totalVariation; ring

namespace SourceClass

variable {Θ : Type*} (S : SourceClass X Θ)

/-- **Diversity lower bound.**  Any two members of the class force the Shtarkov
sum up by their total variation distance: `1 + ‖p_θ − p_θ'‖_TV ≤ Cₛ`. -/
theorem one_add_totalVariation_le_shtarkovSum [Nonempty Θ] (θ θ' : Θ) :
    1 + totalVariation (S.prob θ) (S.prob θ') ≤ S.shtarkovSum := by
  have hmax : ∀ x : X, max (S.prob θ x) (S.prob θ' x) ≤ S.maxLik x :=
    fun x => max_le (S.le_maxLik θ x) (S.le_maxLik θ' x)
  calc 1 + totalVariation (S.prob θ) (S.prob θ')
      = ∑ x, max (S.prob θ x) (S.prob θ' x) :=
        (sum_max_eq_one_add_totalVariation (S.sum_one θ) (S.sum_one θ')).symm
    _ ≤ ∑ x, S.maxLik x := Finset.sum_le_sum fun x _ => hmax x
    _ = S.shtarkovSum := rfl

/-- The bit form of the diversity bound: the price of universality of the class
is at least `log₂ (1 + ‖p_θ − p_θ'‖_TV)` for every pair of members. -/
theorem logb_one_add_totalVariation_le_price [Nonempty Θ] (θ θ' : Θ) :
    logb 2 (1 + totalVariation (S.prob θ) (S.prob θ')) ≤ logb 2 S.shtarkovSum := by
  refine Real.logb_le_logb_of_le (by norm_num) ?_
    (S.one_add_totalVariation_le_shtarkovSum θ θ')
  have := totalVariation_nonneg (S.prob θ) (S.prob θ')
  linarith

/-- **Degeneracy criterion.**  The Shtarkov sum equals `1` — i.e. universality is
free — precisely when the class is a single source in disguise. -/
theorem shtarkovSum_eq_one_iff [Nonempty Θ] :
    S.shtarkovSum = 1 ↔ ∀ θ θ' : Θ, ∀ x, S.prob θ x = S.prob θ' x := by
  constructor
  · intro h θ θ'
    have hle := S.one_add_totalVariation_le_shtarkovSum θ θ'
    have hnn := totalVariation_nonneg (S.prob θ) (S.prob θ')
    have : totalVariation (S.prob θ) (S.prob θ') = 0 := by rw [h] at hle; linarith
    exact totalVariation_eq_zero_iff.1 this
  · intro h
    have hθ₀ : ∀ x, S.maxLik x = S.prob (Classical.arbitrary Θ) x := by
      intro x
      refine le_antisymm (S.maxLik_le fun θ => le_of_eq (h θ _ x)) (S.le_maxLik _ x)
    calc S.shtarkovSum = ∑ x, S.prob (Classical.arbitrary Θ) x :=
          Finset.sum_congr rfl fun x _ => hθ₀ x
      _ = 1 := S.sum_one _

/-- **No free universality.**  As soon as the class contains two genuinely
different sources, the price of universality is strictly positive: some message
must be lengthened by a positive number of bits. -/
theorem price_pos_of_ne [Nonempty Θ] {θ θ' : Θ} {x₀ : X}
    (hne : S.prob θ x₀ ≠ S.prob θ' x₀) : 0 < logb 2 S.shtarkovSum := by
  have hgt : 1 < S.shtarkovSum := by
    rcases lt_or_eq_of_le S.one_le_shtarkovSum with h | h
    · exact h
    · exact absurd (S.shtarkovSum_eq_one_iff.1 h.symm θ θ' x₀) hne
  exact Real.logb_pos (by norm_num) hgt

/-! ## Monotonicity: specialising a decompressor never hurts -/

/-- Reindexing a class along `f : Θ' → Θ`; its image is the subclass
`{p_{f θ'}}`. -/
def reindex {Θ' : Type*} (f : Θ' → Θ) : SourceClass X Θ' where
  prob θ' x := S.prob (f θ') x
  nonneg _ _ := S.nonneg _ _
  sum_one _ := S.sum_one _

/-- **Monotonicity of the Shtarkov sum.**  A subclass never has a larger
Shtarkov sum than the class containing it. -/
theorem shtarkovSum_reindex_le {Θ' : Type*} [Nonempty Θ'] [Nonempty Θ]
    (f : Θ' → Θ) : (S.reindex f).shtarkovSum ≤ S.shtarkovSum := by
  refine Finset.sum_le_sum fun x _ => ?_
  exact (S.reindex f).maxLik_le fun θ' => S.le_maxLik (f θ') x

/-- **Specialisation never hurts.**  Restricting a universal decompressor to a
subclass of sources can only lower the price of universality. -/
theorem price_reindex_le {Θ' : Type*} [Nonempty Θ'] [Nonempty Θ] (f : Θ' → Θ) :
    logb 2 (S.reindex f).shtarkovSum ≤ logb 2 S.shtarkovSum :=
  Real.logb_le_logb_of_le (by norm_num) (S.reindex f).shtarkovSum_pos
    (S.shtarkovSum_reindex_le f)

/-! ## Tensorisation: the diversity bound accumulates over blocks -/

/-- Two independent blocks drawn from the same diverse class already cost twice
the total-variation floor. -/
theorem price_prod_self_ge [Nonempty Θ] (θ θ' : Θ) :
    2 * logb 2 (1 + totalVariation (S.prob θ) (S.prob θ')) ≤
      logb 2 (S.prod S).shtarkovSum := by
  rw [S.price_prod_eq S]
  have := S.logb_one_add_totalVariation_le_price θ θ'
  linarith

/-- **Tensorised diversity bound.**  If a class contains two sources at total
variation distance `δ`, then `k` independent blocks of that class cost at least
`k · log₂ (1 + δ)` bits of universality.  Since the bound grows linearly in the
number of blocks while a per-source code pays nothing, the price of universality
is genuinely extensive: it cannot be amortised away by coding longer messages. -/
theorem price_pow_ge [Nonempty Θ] (θ θ' : Θ) :
    ∀ k : ℕ, (k : ℝ) * logb 2 (1 + totalVariation (S.prob θ) (S.prob θ')) ≤
      logb 2 (S.shtarkovSum ^ k) := by
  intro k
  rw [Real.logb_pow]
  have := S.logb_one_add_totalVariation_le_price θ θ'
  have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  exact mul_le_mul_of_nonneg_left this hk

end SourceClass

end UniversalRedundancy