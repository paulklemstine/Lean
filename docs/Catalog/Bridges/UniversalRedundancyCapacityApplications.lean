/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality V: additivity, symmetry, and a strict average/worst gap

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

`Bridges.UniversalRedundancyCapacity` proves the exact redundancy–capacity
theorem: the minimax **average** price of universality of a finite class of
sources is its capacity `C`.  This file harvests that saddle point.

## Main results

* `klDiv_prod` — divergence is additive on product distributions
* `capacity_tensor` — **the capacity is additive**:
  `C(S ⊗ T) = C(S) + C(T)`.  Independent blocks pay the *sum* of their prices;
  no universality discount is possible across independent data.  The hard
  inequality `≤` is an immediate consequence of the saddle point, which is why
  it appears here rather than in the classical (minimax-theorem) treatment.
* `shiftClass` and `shiftClass_capacity` — a **closed form** for the price of
  universality of an *unknown-offset* class over a finite abelian group `A`:
  `C = log₂ #A − H(p₀)`.  Symmetry computes the capacity exactly.
* `shiftClass_shtarkovSum`, `shiftClass_price_gap` — the corresponding worst-case
  price is `log₂ #A − H_∞(p₀)`, so
  `worst-case − average = H(p₀) − H_∞(p₀) ≥ 0`:
  the gap between the two prices of universality is exactly the gap between
  Shannon entropy and min-entropy of the base distribution.
* `bias34Class_average_lt_worst` — a fully explicit class (two shifted
  Bernoulli(3/4) sources) where the average price `¾ log₂ 3 − 1 ≈ 0.189` bits is
  *strictly* below the worst-case price `log₂ 3 − 1 ≈ 0.585` bits.  The two
  pillars of the thread are genuinely different quantities.

## Application keywords

universal compression, channel capacity additivity, minimax redundancy, group
symmetry, min-entropy, Shtarkov sum, price of universality
-/

import Bridges.UniversalRedundancyCapacity
import Logic.PriceOfUniversality.Tensor

open Finset Real

namespace UniversalRedundancy

variable {X Y : Type*} [Fintype X] [Fintype Y]

/-! ## Divergence on product distributions -/

/-- The Kullback–Leibler divergence of a product from a product is the sum of
the divergences. -/
theorem klDiv_prod {p : X → ℝ} {q : Y → ℝ} {a : X → ℝ} {b : Y → ℝ}
    (hp : ∀ x, 0 < p x) (hq : ∀ y, 0 < q y) (ha : ∀ x, 0 < a x) (hb : ∀ y, 0 < b y)
    (hp1 : ∑ x, p x = 1) (hq1 : ∑ y, q y = 1) :
    klDiv (fun z : X × Y => p z.1 * q z.2) (fun z : X × Y => a z.1 * b z.2)
      = klDiv p a + klDiv q b := by
  have hterm : ∀ (x : X) (y : Y), p x * q y * logb 2 (p x * q y / (a x * b y))
      = (p x * logb 2 (p x / a x)) * q y + p x * (q y * logb 2 (q y / b y)) := by
    intro x y
    have hax := ha x
    have hby := hb y
    have hpx := hp x
    have hqy := hq y
    have hsplit : p x * q y / (a x * b y) = (p x / a x) * (q y / b y) := by
      field_simp
    rw [hsplit, Real.logb_mul (by positivity) (by positivity)]
    ring
  unfold klDiv
  rw [Fintype.sum_prod_type]
  calc ∑ x, ∑ y, p x * q y * logb 2 (p x * q y / (a x * b y))
      = ∑ x, ((p x * logb 2 (p x / a x)) * (∑ y, q y)
          + p x * (∑ y, q y * logb 2 (q y / b y))) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [Finset.sum_congr rfl fun y _ => hterm x y, Finset.sum_add_distrib,
          ← Finset.mul_sum, ← Finset.mul_sum]
    _ = (∑ x, p x * logb 2 (p x / a x)) * (∑ y, q y)
          + (∑ x, p x) * (∑ y, q y * logb 2 (q y / b y)) := by
        rw [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.sum_mul]
    _ = (∑ x, p x * logb 2 (p x / a x)) + (∑ y, q y * logb 2 (q y / b y)) := by
        rw [hp1, hq1]
        ring

namespace SourceClass

variable {Θ Ψ : Type*} [Fintype Θ] [Fintype Ψ]

/-! ## Additivity of the capacity -/

/-- The Bayes mixture of a tensor product under a product prior is the product
of the Bayes mixtures. -/
lemma mix_tensor_prod (S : SourceClass X Θ) (T : SourceClass Y Ψ)
    (w : Θ → ℝ) (v : Ψ → ℝ) (z : X × Y) :
    (S.tensor T).mix (fun c : Θ × Ψ => w c.1 * v c.2) z
      = S.mix w z.1 * T.mix v z.2 := by
  unfold mix
  show ∑ c : Θ × Ψ, (w c.1 * v c.2) * (S.prob c.1 z.1 * T.prob c.2 z.2)
      = (∑ θ, w θ * S.prob θ z.1) * ∑ ψ, v ψ * T.prob ψ z.2
  rw [Fintype.sum_prod_type, Finset.sum_mul]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun ψ _ => by ring

/-- **Capacity is additive under tensor products.**  Two independent data
streams, each from its own source class, cost exactly the sum of the two prices
of universality: nothing is saved (and nothing is lost) by coding them together.
The upper bound is where the saddle point is used. -/
theorem capacity_tensor [Nonempty Θ] [Nonempty Ψ] (S : SourceClass X Θ)
    (T : SourceClass Y Ψ) (hS : ∀ θ x, 0 < S.prob θ x) (hT : ∀ ψ y, 0 < T.prob ψ y) :
    (S.tensor T).capacity = S.capacity + T.capacity := by
  have hST : ∀ (c : Θ × Ψ) (z : X × Y), 0 < (S.tensor T).prob c z := by
    intro c z
    exact mul_pos (hS c.1 z.1) (hT c.2 z.2)
  refine le_antisymm ?_ ?_
  · -- achievability of `C(S) + C(T)` by a product code, via the saddle point
    obtain ⟨qS, hqS, hqS1, hqSle⟩ := S.exists_universal_code_capacity hS
    obtain ⟨qT, hqT, hqT1, hqTle⟩ := T.exists_universal_code_capacity hT
    refine (S.tensor T).capacity_le_of_forall_klDiv_le hST
      (q := fun z : X × Y => qS z.1 * qT z.2) (fun z => mul_pos (hqS z.1) (hqT z.2)) ?_ ?_
    · refine le_of_eq ?_
      rw [Fintype.sum_prod_type]
      calc ∑ x, ∑ y, qS x * qT y = ∑ x, qS x * ∑ y, qT y :=
            Finset.sum_congr rfl fun x _ => (Finset.mul_sum _ _ _).symm
        _ = 1 := by rw [hqT1]; simpa using hqS1
    · intro c
      have hsplit : klDiv ((S.tensor T).prob c) (fun z : X × Y => qS z.1 * qT z.2)
          = klDiv (S.prob c.1) qS + klDiv (T.prob c.2) qT :=
        klDiv_prod (hS c.1) (hT c.2) hqS hqT (S.sum_one c.1) (T.sum_one c.2)
      rw [hsplit]
      exact add_le_add (hqSle c.1) (hqTle c.2)
  · -- the product prior already achieves `C(S) + C(T)`
    obtain ⟨w, hw, hweq, -⟩ := S.exists_capacity_prior hS
    obtain ⟨v, hv, hveq, -⟩ := T.exists_capacity_prior hT
    have hmem : (fun c : Θ × Ψ => w c.1 * v c.2) ∈ stdSimplex ℝ (Θ × Ψ) := by
      refine ⟨fun c => mul_nonneg (hw.1 c.1) (hv.1 c.2), ?_⟩
      rw [Fintype.sum_prod_type]
      calc ∑ θ, ∑ ψ, w θ * v ψ = ∑ θ, w θ * ∑ ψ, v ψ :=
            Finset.sum_congr rfl fun θ _ => (Finset.mul_sum _ _ _).symm
        _ = 1 := by rw [hv.2]; simpa using hw.2
    have hmixS : ∀ x, 0 < S.mix w x := S.mix_pos_of_mem_stdSimplex hS hw
    have hmixT : ∀ y, 0 < T.mix v y := T.mix_pos_of_mem_stdSimplex hT hv
    have hI : (S.tensor T).mutualInfo (fun c : Θ × Ψ => w c.1 * v c.2)
        = S.mutualInfo w + T.mutualInfo v := by
      unfold mutualInfo
      have hterm : ∀ c : Θ × Ψ,
          (w c.1 * v c.2) * klDiv ((S.tensor T).prob c)
              ((S.tensor T).mix (fun c : Θ × Ψ => w c.1 * v c.2))
            = (w c.1 * v c.2) * klDiv (S.prob c.1) (S.mix w)
              + (w c.1 * v c.2) * klDiv (T.prob c.2) (T.mix v) := by
        intro c
        have hmixeq : (S.tensor T).mix (fun c : Θ × Ψ => w c.1 * v c.2)
            = fun z : X × Y => S.mix w z.1 * T.mix v z.2 :=
          funext fun z => S.mix_tensor_prod T w v z
        have hprobeq : (S.tensor T).prob c
            = fun z : X × Y => S.prob c.1 z.1 * T.prob c.2 z.2 := rfl
        rw [hmixeq, hprobeq,
          klDiv_prod (hS c.1) (hT c.2) hmixS hmixT (S.sum_one c.1) (T.sum_one c.2)]
        ring
      rw [Finset.sum_congr rfl fun c _ => hterm c, Finset.sum_add_distrib,
        Fintype.sum_prod_type, Fintype.sum_prod_type]
      congr 1
      · calc ∑ θ, ∑ ψ, (w θ * v ψ) * klDiv (S.prob θ) (S.mix w)
            = ∑ θ, (w θ * klDiv (S.prob θ) (S.mix w)) * ∑ ψ, v ψ := by
              refine Finset.sum_congr rfl fun θ _ => ?_
              rw [Finset.mul_sum]
              exact Finset.sum_congr rfl fun ψ _ => by ring
          _ = ∑ θ, w θ * klDiv (S.prob θ) (S.mix w) := by rw [hv.2]; simp
      · calc ∑ θ, ∑ ψ, (w θ * v ψ) * klDiv (T.prob ψ) (T.mix v)
            = ∑ θ, w θ * ∑ ψ, v ψ * klDiv (T.prob ψ) (T.mix v) := by
              refine Finset.sum_congr rfl fun θ _ => ?_
              rw [Finset.mul_sum]
              exact Finset.sum_congr rfl fun ψ _ => by ring
          _ = ∑ ψ, v ψ * klDiv (T.prob ψ) (T.mix v) := by
              rw [← Finset.sum_mul, hw.2, one_mul]
    calc S.capacity + T.capacity = (S.tensor T).mutualInfo
          (fun c : Θ × Ψ => w c.1 * v c.2) := by rw [hI, hweq, hveq]
      _ ≤ (S.tensor T).capacity := (S.tensor T).mutualInfo_le_capacity hST hmem

end SourceClass

/-! ## Unknown-offset classes over a finite abelian group

A base distribution `p₀` on a finite abelian group `A`, observed after an
unknown translation.  This is the smallest genuinely "parametric" class with a
transitive symmetry, and the symmetry computes its capacity exactly. -/

section Shift

variable {A : Type*} [Fintype A] [AddCommGroup A]

/-- The **unknown-offset class**: the base law `p₀` translated by an unknown
group element. -/
def shiftClass (p₀ : A → ℝ) (h0 : ∀ a, 0 ≤ p₀ a) (h1 : ∑ a, p₀ a = 1) :
    SourceClass A A where
  prob θ x := p₀ (x - θ)
  nonneg _ _ := h0 _
  sum_one θ := by
    have h := Equiv.sum_comp (Equiv.subRight θ) p₀
    simpa [h1] using h

variable {p₀ : A → ℝ} (h0 : ∀ a, 0 ≤ p₀ a) (h1 : ∑ a, p₀ a = 1)

/-- The uniform mixture of an unknown-offset class is the uniform distribution:
translation invariance destroys all information about the message. -/
lemma mix_uniformPrior_shiftClass [Nonempty A] (x : A) :
    (shiftClass p₀ h0 h1).mix (uniformPrior A) x = (Fintype.card A : ℝ)⁻¹ := by
  unfold SourceClass.mix uniformPrior
  show ∑ θ : A, (Fintype.card A : ℝ)⁻¹ * p₀ (x - θ) = (Fintype.card A : ℝ)⁻¹
  rw [← Finset.mul_sum]
  have h : ∑ i, p₀ (x - i) = ∑ i, p₀ i := Equiv.sum_comp (Equiv.subLeft x) p₀
  rw [h, h1, mul_one]

/-- **Closed form for the price of universality of an unknown-offset class.**
The capacity is `log₂ #A − H(p₀)`: a universal code pays the full cost of naming
the offset, *minus* the entropy the base law already provides. -/
theorem shiftClass_capacity [Nonempty A] (hpos : ∀ a, 0 < p₀ a) :
    (shiftClass p₀ (fun a => (hpos a).le) h1).capacity
      = logb 2 (Fintype.card A) - entropyBits p₀ := by
  set S := shiftClass p₀ (fun a => (hpos a).le) h1 with hS
  have hcardpos : (0 : ℝ) < (Fintype.card A : ℝ) := by exact_mod_cast Fintype.card_pos
  have hSpos : ∀ θ x, 0 < S.prob θ x := fun θ x => hpos _
  have hsym : S.capacity = klDiv (S.prob 0) (S.mix (uniformPrior A)) := by
    refine S.capacity_eq_klDiv_uniformMix_of_symmetric hSpos
      (G := A) (fun g => Equiv.addRight g) (fun g => Equiv.addRight g) ?_ ?_ 0
    · intro g θ x
      show p₀ (x + g - (θ + g)) = p₀ (x - θ)
      congr 1
      abel
    · intro θ θ'
      exact ⟨θ' - θ, by show θ + (θ' - θ) = θ'; abel⟩
  rw [hsym]
  have hmix : ∀ x, S.mix (uniformPrior A) x = (Fintype.card A : ℝ)⁻¹ :=
    fun x => mix_uniformPrior_shiftClass (fun a => (hpos a).le) h1 x
  have hprob : ∀ x, S.prob 0 x = p₀ x := by
    intro x
    show p₀ (x - 0) = p₀ x
    rw [sub_zero]
  unfold klDiv entropyBits
  have hterm : ∀ x : A, S.prob 0 x * logb 2 (S.prob 0 x / S.mix (uniformPrior A) x)
      = p₀ x * logb 2 (Fintype.card A) + p₀ x * logb 2 (p₀ x) := by
    intro x
    rw [hprob x, hmix x, Real.logb_div (hpos x).ne' (by positivity),
      Real.logb_inv]
    ring
  rw [Finset.sum_congr rfl fun x _ => hterm x, Finset.sum_add_distrib, ← Finset.sum_mul, h1]
  ring

/-! ### The worst-case price of the same class -/

/-- The maximum-likelihood envelope of an unknown-offset class is the maximum of
the base law. -/
lemma maxLik_shiftClass [Nonempty A] (x : A) :
    (shiftClass p₀ h0 h1).maxLik x = ⨆ a, p₀ a := by
  have hbdd : BddAbove (Set.range p₀) := Set.Finite.bddAbove (Set.finite_range _)
  have hbdd' : BddAbove (Set.range fun θ : A => p₀ (x - θ)) :=
    Set.Finite.bddAbove (Set.finite_range _)
  refine le_antisymm (ciSup_le fun θ => le_ciSup hbdd (x - θ)) (ciSup_le fun a => ?_)
  have hxa : p₀ a = p₀ (x - (x - a)) := by congr 1; abel
  rw [hxa]
  exact le_ciSup hbdd' (x - a)

/-- The Shtarkov sum of an unknown-offset class is `#A · max p₀`, so the
worst-case price is `log₂ #A − H_∞(p₀)`. -/
theorem shiftClass_shtarkovSum [Nonempty A] :
    (shiftClass p₀ h0 h1).shtarkovSum = (Fintype.card A : ℝ) * ⨆ a, p₀ a := by
  unfold SourceClass.shtarkovSum
  rw [Finset.sum_congr rfl fun x _ => maxLik_shiftClass h0 h1 x]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **Worst case minus average, in closed form.**  For an unknown-offset class
the gap between the two prices of universality is exactly the gap between the
Shannon entropy and the min-entropy of the base law. -/
theorem shiftClass_price_gap [Nonempty A] (hpos : ∀ a, 0 < p₀ a) :
    logb 2 (shiftClass p₀ (fun a => (hpos a).le) h1).shtarkovSum
        - (shiftClass p₀ (fun a => (hpos a).le) h1).capacity
      = entropyBits p₀ + logb 2 (⨆ a, p₀ a) := by
  have hcardpos : (0 : ℝ) < (Fintype.card A : ℝ) := by exact_mod_cast Fintype.card_pos
  have hbdd : BddAbove (Set.range p₀) := Set.Finite.bddAbove (Set.finite_range _)
  have hmaxpos : 0 < ⨆ a, p₀ a :=
    lt_of_lt_of_le (hpos (Classical.arbitrary A)) (le_ciSup hbdd (Classical.arbitrary A))
  rw [shiftClass_shtarkovSum (fun a => (hpos a).le) h1,
    shiftClass_capacity h1 hpos, Real.logb_mul hcardpos.ne' hmaxpos.ne']
  ring

omit [AddCommGroup A] in
include h1 in
/-- The gap is nonnegative: Shannon entropy dominates min-entropy. -/
theorem entropy_add_logb_ciSup_nonneg [Nonempty A] (hpos : ∀ a, 0 < p₀ a) :
    0 ≤ entropyBits p₀ + logb 2 (⨆ a, p₀ a) := by
  have hbdd : BddAbove (Set.range p₀) := Set.Finite.bddAbove (Set.finite_range _)
  have hmaxpos : 0 < ⨆ a, p₀ a :=
    lt_of_lt_of_le (hpos (Classical.arbitrary A)) (le_ciSup hbdd (Classical.arbitrary A))
  have hstep : ∀ a : A, p₀ a * logb 2 (p₀ a) ≤ p₀ a * logb 2 (⨆ b, p₀ b) :=
    fun a => mul_le_mul_of_nonneg_left
      (Real.logb_le_logb_of_le (by norm_num) (hpos a) (le_ciSup hbdd a)) (hpos a).le
  have hsum : ∑ a, p₀ a * logb 2 (p₀ a) ≤ logb 2 (⨆ a, p₀ a) := by
    calc ∑ a, p₀ a * logb 2 (p₀ a) ≤ ∑ a, p₀ a * logb 2 (⨆ b, p₀ b) :=
          Finset.sum_le_sum fun a _ => hstep a
      _ = logb 2 (⨆ a, p₀ a) := by rw [← Finset.sum_mul, h1, one_mul]
  unfold entropyBits
  linarith

end Shift

/-! ## An explicit class where average and worst case differ

Two shifted copies of a Bernoulli(3/4) law on `ZMod 2`. -/

section Explicit

/-- The base law: `3/4` on `0`, `1/4` on `1`. -/
noncomputable def bias34 : ZMod 2 → ℝ := fun a => if a = 0 then 3 / 4 else 1 / 4

lemma bias34_pos : ∀ a, 0 < bias34 a := by
  intro a
  unfold bias34
  split <;> norm_num

lemma bias34_sum : ∑ a : ZMod 2, bias34 a = 1 := by
  have huniv : (Finset.univ : Finset (ZMod 2)) = {0, 1} := by decide
  rw [huniv, Finset.sum_insert (by decide), Finset.sum_singleton]
  unfold bias34
  norm_num

lemma logb_two_four : logb 2 (4 : ℝ) = 2 := by
  rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow,
    Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
  norm_num

lemma entropyBits_bias34 : entropyBits bias34 = 2 - (3 / 4) * logb 2 3 := by
  have huniv : (Finset.univ : Finset (ZMod 2)) = {0, 1} := by decide
  unfold entropyBits
  rw [huniv, Finset.sum_insert (by decide), Finset.sum_singleton]
  have h34 : logb 2 (3 / 4 : ℝ) = logb 2 3 - 2 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_two_four]
  have h14 : logb 2 (1 / 4 : ℝ) = -2 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_two_four, Real.logb_one]
    ring
  unfold bias34
  norm_num [h34, h14]
  ring

lemma ciSup_bias34 : (⨆ a, bias34 a) = 3 / 4 := by
  have hbdd : BddAbove (Set.range bias34) := Set.Finite.bddAbove (Set.finite_range _)
  refine le_antisymm (ciSup_le fun a => ?_) ?_
  · unfold bias34
    split <;> norm_num
  · have h : bias34 0 = 3 / 4 := by unfold bias34; norm_num
    rw [← h]
    exact le_ciSup hbdd 0

/-- The two-source class of shifted Bernoulli(3/4) laws. -/
noncomputable def bias34Class : SourceClass (ZMod 2) (ZMod 2) :=
  shiftClass bias34 (fun a => (bias34_pos a).le) bias34_sum

/-- Its average price of universality is `¾ log₂ 3 − 1 ≈ 0.189` bits. -/
theorem bias34Class_capacity : bias34Class.capacity = (3 / 4) * logb 2 3 - 1 := by
  have hcard : (Fintype.card (ZMod 2) : ℝ) = 2 := by simp
  unfold bias34Class
  rw [shiftClass_capacity bias34_sum bias34_pos, hcard, entropyBits_bias34,
    Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
  ring

/-- Its worst-case price of universality is `log₂ 3 − 1 ≈ 0.585` bits. -/
theorem bias34Class_worst : logb 2 bias34Class.shtarkovSum = logb 2 3 - 1 := by
  have hcard : (Fintype.card (ZMod 2) : ℝ) = 2 := by simp
  unfold bias34Class
  rw [shiftClass_shtarkovSum (fun a => (bias34_pos a).le) bias34_sum, hcard, ciSup_bias34]
  rw [show (2 : ℝ) * (3 / 4) = 3 / 2 by norm_num,
    Real.logb_div (by norm_num) (by norm_num),
    Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]

/-- **The average price is strictly below the worst-case price.**  For this
explicit class the two prices of universality differ by exactly `¼ log₂ 3`
bits, so the worst-case (Shtarkov) theory strictly overcharges a code that is
only required to be good *on average*. -/
theorem bias34Class_average_lt_worst :
    bias34Class.capacity < logb 2 bias34Class.shtarkovSum := by
  rw [bias34Class_capacity, bias34Class_worst]
  have h3 : 0 < logb 2 3 := Real.logb_pos (by norm_num) (by norm_num)
  linarith

/-- The exact gap: `¼ log₂ 3` bits, i.e. `H(p₀) − H_∞(p₀)`. -/
theorem bias34Class_gap :
    logb 2 bias34Class.shtarkovSum - bias34Class.capacity = (1 / 4) * logb 2 3 := by
  rw [bias34Class_capacity, bias34Class_worst]
  ring

end Explicit

end UniversalRedundancy