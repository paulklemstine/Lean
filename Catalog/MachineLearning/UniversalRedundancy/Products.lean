/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VII: structural laws (calibration, monotonicity,
# multiplicativity)

Second research cycle on the thread.  Having computed the price of universality
for concrete classes, we isolate the *structural laws* the price obeys, which
explain the numbers of Parts II–VI and give a calculus for new classes.

## Central Idea

Three laws for the Shtarkov sum `Cₛ`:

* **Calibration.**  A class with a single source has `Cₛ = 1`: the price of
  universality is exactly `0` bits, so the theory is not measuring an artefact.
* **Monotonicity.**  Enlarging the class can only increase `Cₛ`; a reindexing
  (in particular a subclass) never costs more.  Price is a monotone functional
  of class complexity.
* **Multiplicativity.**  For a product class — two independent blocks with
  *independently chosen* parameters — `Cₛ = Cₛ¹ · Cₛ²`, i.e. the price in bits
  is *additive* across independent blocks.

Additivity is the structural reason why an unrestricted per-symbol class costs
`Θ(n)` bits (Part VI) while a class with a single shared parameter costs only
`Θ(log n)` (Parts II and V): sharing a parameter across blocks, rather than
re-choosing it, is exactly what turns a linear price into a logarithmic one.

## Main Results

* `shtarkovSum_of_subsingleton` — `Cₛ = 1` for a one-source class
* `shtarkovSum_reindex_le` — monotonicity under reindexing/subclasses
* `prodClass`, `shtarkovSum_prodClass` — `Cₛ = Cₛ¹ · Cₛ²` for product classes
* `price_prodClass_add` — the price in bits is additive over independent blocks
* `shtarkovSum_le_of_relabel` — transport of the price along relabellings
* `tiedProdClass`, `shtarkovSum_tiedProdClass_le` — with a *shared* parameter
  the price is only *sub*additive: sharing is what buys the savings
* `shtarkovSum_iidClass_submultiplicative`, `iid_price_subadditive` —
  `Cₛ(n₁+n₂) ≤ Cₛ(n₁)·Cₛ(n₂)` for the memoryless class

## Application Keywords

universal coding, Shtarkov sum, product source class, additivity of redundancy,
class complexity
-/

import MachineLearning.UniversalRedundancy.Core
import MachineLearning.UniversalRedundancy.Types

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*}

/-- **Calibration.**  If the class contains only one source (up to equality of
laws) then the price of universality is zero: `Cₛ = 1`. -/
theorem shtarkovSum_of_subsingleton [Nonempty Θ] (S : SourceClass X Θ)
    (hone : ∀ θ θ' x, S.prob θ x = S.prob θ' x) : S.shtarkovSum = 1 := by
  have hmax : ∀ x, S.maxLik x = S.prob (Classical.arbitrary Θ) x := by
    intro x
    refine le_antisymm (S.maxLik_le fun θ => le_of_eq (hone θ _ x))
      (S.le_maxLik _ x)
  unfold SourceClass.shtarkovSum
  rw [Finset.sum_congr rfl fun x _ => hmax x]
  exact S.sum_one _

/-- **Monotonicity.**  Reindexing a class along any map (in particular passing
to a subclass) cannot increase the Shtarkov sum: a smaller class is never more
expensive to serve universally. -/
theorem shtarkovSum_reindex_le {Θ' : Type*} [Nonempty Θ] [Nonempty Θ']
    (S : SourceClass X Θ) (ι : Θ' → Θ) :
    (SourceClass.mk (fun θ' x => S.prob (ι θ') x) (fun θ' x => S.nonneg (ι θ') x)
      (fun θ' => S.sum_one (ι θ'))).shtarkovSum ≤ S.shtarkovSum := by
  refine Finset.sum_le_sum fun x _ => ?_
  refine SourceClass.maxLik_le _ fun θ' => ?_
  exact S.le_maxLik (ι θ') x

end SourceClass

/-- The product of two source classes: two independent blocks whose parameters
are chosen independently. -/
noncomputable def prodClass {X₁ X₂ : Type*} [Fintype X₁] [Fintype X₂]
    {Θ₁ Θ₂ : Type*} (S₁ : SourceClass X₁ Θ₁) (S₂ : SourceClass X₂ Θ₂) :
    SourceClass (X₁ × X₂) (Θ₁ × Θ₂) where
  prob θ x := S₁.prob θ.1 x.1 * S₂.prob θ.2 x.2
  nonneg θ x := mul_nonneg (S₁.nonneg _ _) (S₂.nonneg _ _)
  sum_one θ := by
    rw [Fintype.sum_prod_type]
    calc ∑ x₁ : X₁, ∑ x₂ : X₂, S₁.prob θ.1 x₁ * S₂.prob θ.2 x₂
        = ∑ x₁ : X₁, S₁.prob θ.1 x₁ * ∑ x₂ : X₂, S₂.prob θ.2 x₂ :=
          Finset.sum_congr rfl fun x₁ _ => by rw [Finset.mul_sum]
      _ = ∑ x₁ : X₁, S₁.prob θ.1 x₁ := by rw [S₂.sum_one]; simp
      _ = 1 := S₁.sum_one _

variable {X₁ X₂ : Type*} [Fintype X₁] [Fintype X₂] {Θ₁ Θ₂ : Type*}
  [Fintype Θ₁] [Fintype Θ₂] [Nonempty Θ₁] [Nonempty Θ₂]

lemma maxLik_prodClass (S₁ : SourceClass X₁ Θ₁) (S₂ : SourceClass X₂ Θ₂)
    (x : X₁ × X₂) :
    (prodClass S₁ S₂).maxLik x = S₁.maxLik x.1 * S₂.maxLik x.2 := by
  refine le_antisymm ?_ ?_
  · refine SourceClass.maxLik_le _ fun θ => ?_
    exact mul_le_mul (S₁.le_maxLik θ.1 x.1) (S₂.le_maxLik θ.2 x.2) (S₂.nonneg _ _)
      (S₁.maxLik_nonneg x.1)
  · obtain ⟨θ₁, hθ₁⟩ := Finite.exists_max fun θ : Θ₁ => S₁.prob θ x.1
    obtain ⟨θ₂, hθ₂⟩ := Finite.exists_max fun θ : Θ₂ => S₂.prob θ x.2
    have h₁ : S₁.maxLik x.1 = S₁.prob θ₁ x.1 :=
      le_antisymm (S₁.maxLik_le fun θ => hθ₁ θ) (S₁.le_maxLik θ₁ x.1)
    have h₂ : S₂.maxLik x.2 = S₂.prob θ₂ x.2 :=
      le_antisymm (S₂.maxLik_le fun θ => hθ₂ θ) (S₂.le_maxLik θ₂ x.2)
    rw [h₁, h₂]
    exact (prodClass S₁ S₂).le_maxLik (θ₁, θ₂) x

/-- **Multiplicativity.**  The Shtarkov sum of a product class is the product of
the Shtarkov sums: the price of universality in bits is additive over
independent blocks. -/
theorem shtarkovSum_prodClass (S₁ : SourceClass X₁ Θ₁) (S₂ : SourceClass X₂ Θ₂) :
    (prodClass S₁ S₂).shtarkovSum = S₁.shtarkovSum * S₂.shtarkovSum := by
  unfold SourceClass.shtarkovSum
  rw [Fintype.sum_prod_type]
  calc ∑ x₁ : X₁, ∑ x₂ : X₂, (prodClass S₁ S₂).maxLik (x₁, x₂)
      = ∑ x₁ : X₁, ∑ x₂ : X₂, S₁.maxLik x₁ * S₂.maxLik x₂ :=
        Finset.sum_congr rfl fun x₁ _ =>
          Finset.sum_congr rfl fun x₂ _ => maxLik_prodClass S₁ S₂ (x₁, x₂)
    _ = ∑ x₁ : X₁, S₁.maxLik x₁ * ∑ x₂ : X₂, S₂.maxLik x₂ :=
        Finset.sum_congr rfl fun x₁ _ => by rw [Finset.mul_sum]
    _ = (∑ x₁ : X₁, S₁.maxLik x₁) * ∑ x₂ : X₂, S₂.maxLik x₂ := by rw [Finset.sum_mul]

/-- The price of universality in bits is additive over independent blocks. -/
theorem price_prodClass_add (S₁ : SourceClass X₁ Θ₁) (S₂ : SourceClass X₂ Θ₂) :
    logb 2 (prodClass S₁ S₂).shtarkovSum
      = logb 2 S₁.shtarkovSum + logb 2 S₂.shtarkovSum := by
  rw [shtarkovSum_prodClass, Real.logb_mul (ne_of_gt S₁.shtarkovSum_pos)
    (ne_of_gt S₂.shtarkovSum_pos)]

/-! ## Tied blocks: sharing a parameter is never more expensive -/

/-- Transporting a class along a relabelling of messages together with a
relabelling of parameters can only *decrease* the Shtarkov sum. -/
theorem shtarkovSum_le_of_relabel {X Y Θ Ξ : Type*} [Fintype X] [Fintype Y]
    [Nonempty Θ] [Nonempty Ξ] (S : SourceClass X Θ) (T : SourceClass Y Ξ)
    (e : X ≃ Y) (ι : Θ → Ξ) (hcomp : ∀ θ x, S.prob θ x = T.prob (ι θ) (e x)) :
    S.shtarkovSum ≤ T.shtarkovSum := by
  have hpt : ∀ x : X, S.maxLik x ≤ T.maxLik (e x) := fun x =>
    S.maxLik_le fun θ => (hcomp θ x) ▸ T.le_maxLik (ι θ) (e x)
  calc S.shtarkovSum ≤ ∑ x : X, T.maxLik (e x) :=
        Finset.sum_le_sum fun x _ => hpt x
    _ = T.shtarkovSum := Equiv.sum_comp e T.maxLik

/-- Two blocks driven by *one shared* parameter. -/
noncomputable def tiedProdClass {X₁ X₂ : Type*} [Fintype X₁] [Fintype X₂]
    {Θ : Type*} (S₁ : SourceClass X₁ Θ) (S₂ : SourceClass X₂ Θ) :
    SourceClass (X₁ × X₂) Θ where
  prob θ x := S₁.prob θ x.1 * S₂.prob θ x.2
  nonneg θ x := mul_nonneg (S₁.nonneg _ _) (S₂.nonneg _ _)
  sum_one θ := by
    rw [Fintype.sum_prod_type]
    calc ∑ x₁ : X₁, ∑ x₂ : X₂, S₁.prob θ x₁ * S₂.prob θ x₂
        = ∑ x₁ : X₁, S₁.prob θ x₁ * ∑ x₂ : X₂, S₂.prob θ x₂ :=
          Finset.sum_congr rfl fun x₁ _ => by rw [Finset.mul_sum]
      _ = ∑ x₁ : X₁, S₁.prob θ x₁ := by rw [S₂.sum_one]; simp
      _ = 1 := S₁.sum_one _

/-- **Sharing a parameter is never more expensive than choosing two.**  The
Shtarkov sum of the tied product is at most the product of the Shtarkov sums,
so the price in bits is *sub*additive when the two blocks share a parameter,
whereas it is exactly additive when they do not (`price_prodClass_add`). -/
theorem shtarkovSum_tiedProdClass_le {Θ : Type*} [Nonempty Θ]
    (S₁ : SourceClass X₁ Θ) (S₂ : SourceClass X₂ Θ) :
    (tiedProdClass S₁ S₂).shtarkovSum ≤ S₁.shtarkovSum * S₂.shtarkovSum := by
  have hpt : ∀ x : X₁ × X₂,
      (tiedProdClass S₁ S₂).maxLik x ≤ S₁.maxLik x.1 * S₂.maxLik x.2 := fun x =>
    SourceClass.maxLik_le _ fun θ =>
      mul_le_mul (S₁.le_maxLik θ x.1) (S₂.le_maxLik θ x.2) (S₂.nonneg _ _)
        (S₁.maxLik_nonneg x.1)
  calc (tiedProdClass S₁ S₂).shtarkovSum
      ≤ ∑ x : X₁ × X₂, S₁.maxLik x.1 * S₂.maxLik x.2 :=
        Finset.sum_le_sum fun x _ => hpt x
    _ = ∑ x₁ : X₁, S₁.maxLik x₁ * ∑ x₂ : X₂, S₂.maxLik x₂ := by
        rw [Fintype.sum_prod_type]
        exact Finset.sum_congr rfl fun x₁ _ => by rw [Finset.mul_sum]
    _ = S₁.shtarkovSum * S₂.shtarkovSum := by
        rw [← Finset.sum_mul]; rfl

/-! ## Consequence: the i.i.d. price is subadditive in the block length -/

variable {A : Type*} [Fintype A] [DecidableEq A] [Nonempty A]

omit [Nonempty A] in
/-- Splitting a message of length `n₁ + n₂` into its two blocks turns the
memoryless class into a tied product of the two shorter memoryless classes. -/
lemma prob_iidClass_split (n₁ n₂ : ℕ) (θ : Simplex A) (x : Fin (n₁ + n₂) → A) :
    (iidClass A (n₁ + n₂)).prob θ x
      = (tiedProdClass (iidClass A n₁) (iidClass A n₂)).prob θ
          ((Equiv.arrowCongr finSumFinEquiv.symm (Equiv.refl A)).trans
            (Equiv.sumArrowEquivProdArrow (Fin n₁) (Fin n₂) A) x) := by
  show (∏ k : Fin (n₁ + n₂), θ.1 (x k))
      = (∏ i : Fin n₁, θ.1 (x (finSumFinEquiv (Sum.inl i))))
        * ∏ j : Fin n₂, θ.1 (x (finSumFinEquiv (Sum.inr j)))
  rw [← Fintype.prod_equiv finSumFinEquiv (fun s => θ.1 (x (finSumFinEquiv s)))
    (fun k => θ.1 (x k)) (fun _ => rfl), Fintype.prod_sum_type]

/-- **Subadditivity of the memoryless price.**  `Cₛ(n₁ + n₂) ≤ Cₛ(n₁) · Cₛ(n₂)`:
the price of universality of the i.i.d. class is a subadditive function of the
message length (hence `log₂ Cₛ(n)/n` converges by Fekete's lemma). -/
theorem shtarkovSum_iidClass_submultiplicative (n₁ n₂ : ℕ) :
    (iidClass A (n₁ + n₂)).shtarkovSum
      ≤ (iidClass A n₁).shtarkovSum * (iidClass A n₂).shtarkovSum := by
  classical
  have h := shtarkovSum_le_of_relabel (iidClass A (n₁ + n₂))
    (tiedProdClass (iidClass A n₁) (iidClass A n₂))
    ((Equiv.arrowCongr finSumFinEquiv.symm (Equiv.refl A)).trans
      (Equiv.sumArrowEquivProdArrow (Fin n₁) (Fin n₂) A)) id
    (fun θ x => prob_iidClass_split n₁ n₂ θ x)
  refine h.trans ?_
  exact shtarkovSum_tiedProdClass_le (Θ := Simplex A) _ _

/-- The memoryless price in bits is subadditive in the message length. -/
theorem iid_price_subadditive (n₁ n₂ : ℕ) :
    logb 2 (iidClass A (n₁ + n₂)).shtarkovSum
      ≤ logb 2 (iidClass A n₁).shtarkovSum + logb 2 (iidClass A n₂).shtarkovSum := by
  rw [← Real.logb_mul (ne_of_gt (iidClass A n₁).shtarkovSum_pos)
    (ne_of_gt (iidClass A n₂).shtarkovSum_pos)]
  exact Real.logb_le_logb_of_le (by norm_num) (iidClass A (n₁ + n₂)).shtarkovSum_pos
    (shtarkovSum_iidClass_submultiplicative n₁ n₂)

end UniversalRedundancy