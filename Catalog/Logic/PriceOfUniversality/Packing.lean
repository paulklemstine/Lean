/-
# The Price of Universality IV: packing lower bounds and subclass monotonicity

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The catalog already contains the exact minimax identification of the price of
universality with the Shtarkov sum `Cₛ = ∑ₓ supθ p_θ x`
(`MachineLearning.UniversalRedundancy.Core`), upper bounds by the method of
types (`.Types`, `.Markov`) and the binary Rissanen lower bound
`Cₛ(Bernoulli, n) ≥ √n / 4` (`.Bernoulli`).

This file supplies the two general-purpose *lower bound* tools that were
missing, and applies them.

## Main results

* `SourceClass.shtarkovSum_ge_packing` — **packing bound**: for every injective
  family of messages `f : ι → X` and every assignment of sources `θ : ι → Θ`,
  `∑ᵢ p_{θ i} (f i) ≤ Cₛ`.  Every "well separated" finite subfamily of the class
  is a lower bound certificate for the price of universality.
* `SourceClass.shtarkovSum_mono_of_dominated` — **subclass monotonicity**:
  enlarging a class can only increase its Shtarkov sum, hence its price.
* `shtarkovSum_iidClass_ge_card` — the memoryless class over an alphabet `A`
  costs at least `log₂ #A` bits of universality for every message length
  `n ≥ 1`, by packing the `#A` deterministic sources.
* `iid_price_two_sided` — a clean two-sided statement combining the packing
  bound with the method-of-types upper bound.

## Application keywords

minimax redundancy, Shtarkov sum, packing bound, deterministic sources,
universal compression
-/

import MachineLearning.UniversalRedundancy.Types

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} (S : SourceClass X Θ)

/-- **Packing bound.**  Given an injective family of messages `f : ι → X` and
for each index a source `θ i`, the total mass that the chosen sources put on
their own messages is a lower bound for the Shtarkov sum.  Thus any family of
sources that can be told apart by a family of distinct "signature" messages
certifies a price of universality of `log₂` of that total mass. -/
theorem shtarkovSum_ge_packing [Nonempty Θ] {ι : Type*} [Fintype ι] (f : ι → X)
    (hf : Function.Injective f) (θ : ι → Θ) :
    ∑ i, S.prob (θ i) (f i) ≤ S.shtarkovSum := by
  classical
  have h1 : ∑ i, S.prob (θ i) (f i) ≤ ∑ i, S.maxLik (f i) :=
    Finset.sum_le_sum fun i _ => S.le_maxLik (θ i) (f i)
  have h2 : ∑ i, S.maxLik (f i) = ∑ x ∈ (univ : Finset ι).image f, S.maxLik x :=
    (Finset.sum_image fun a _ b _ h => hf h).symm
  have h3 : ∑ x ∈ (univ : Finset ι).image f, S.maxLik x ≤ S.shtarkovSum :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun x _ _ => S.maxLik_nonneg x
  linarith [h2 ▸ h3]

/-- **Subclass monotonicity.**  If every source of `S'` is pointwise dominated by
some source of `S`, then `Cₛ' ≤ Cₛ`: a richer class is never cheaper to code
universally.  Combined with `shtarkovSum_ge_packing` this lets one transfer a
lower bound from any convenient subfamily to the whole class. -/
theorem shtarkovSum_mono_of_dominated [Nonempty Θ] {Θ' : Type*} [Nonempty Θ']
    (S' : SourceClass X Θ') (h : ∀ θ' x, ∃ θ, S'.prob θ' x ≤ S.prob θ x) :
    S'.shtarkovSum ≤ S.shtarkovSum := by
  refine Finset.sum_le_sum fun x _ => ?_
  refine S'.maxLik_le fun θ' => ?_
  obtain ⟨θ, hθ⟩ := h θ' x
  exact hθ.trans (S.le_maxLik θ x)

end SourceClass

/-! ## Deterministic sources inside the memoryless class -/

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- The deterministic (point mass) memoryless parameter concentrated on the
letter `a`. -/
noncomputable def deltaParam (a : A) : Simplex A :=
  ⟨fun b => if b = a then 1 else 0, fun b => by dsimp; split <;> norm_num, by simp⟩

/-- The constant message `aⁿ` has probability one under the deterministic
source `deltaParam a`. -/
lemma prob_deltaParam_const (n : ℕ) (a : A) :
    (iidClass A n).prob (deltaParam a) (fun _ => a) = 1 := by
  simp [iidClass, deltaParam]

/-- **The memoryless class costs at least `log₂ #A`.**  The `#A` deterministic
sources are mutually singular on the constant messages, so the Shtarkov sum of
the i.i.d. class is at least the alphabet size, for every `n ≥ 1`. -/
theorem shtarkovSum_iidClass_ge_card [Nonempty A] (n : ℕ) (hn : 1 ≤ n) :
    (Fintype.card A : ℝ) ≤ (iidClass A n).shtarkovSum := by
  classical
  have hinj : Function.Injective (fun a : A => (fun _ : Fin n => a)) := by
    intro a b hab
    have := congrFun hab ⟨0, by omega⟩
    exact this
  have hpack := (iidClass A n).shtarkovSum_ge_packing
    (f := fun a : A => (fun _ : Fin n => a)) hinj (θ := fun a => deltaParam a)
  have hval : ∑ a : A, (iidClass A n).prob (deltaParam a) (fun _ : Fin n => a)
      = (Fintype.card A : ℝ) := by
    rw [Finset.sum_congr rfl fun a _ => prob_deltaParam_const n a]
    simp
  linarith [hval ▸ hpack]

/-- **Two-sided price of universality for memoryless sources.**  For every
alphabet and every message length `n ≥ 1`, the minimax pointwise redundancy
`log₂ Cₛ` of the i.i.d. class lies between `log₂ #A` and `#A · log₂ (n+1)`.
The lower bound is *independent of `n`*: no matter how long the message, a
universal decompressor must still spend the bits needed to name the alphabet
letter that a deterministic source uses. -/
theorem iid_price_two_sided [Nonempty A] (n : ℕ) (hn : 1 ≤ n) :
    logb 2 (Fintype.card A : ℝ) ≤ logb 2 (iidClass A n).shtarkovSum ∧
      logb 2 (iidClass A n).shtarkovSum
        ≤ (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) := by
  constructor
  · have hcard : (0 : ℝ) < (Fintype.card A : ℝ) := by
      exact_mod_cast Fintype.card_pos
    exact Real.logb_le_logb_of_le (by norm_num) hcard
      (shtarkovSum_iidClass_ge_card n hn)
  · have hC := shtarkovSum_iidClass_le (A := A) n
    have hbase : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
    rw [hbase] at hC
    have hle : logb 2 (iidClass A n).shtarkovSum
        ≤ logb 2 (((n : ℝ) + 1) ^ (Fintype.card A)) :=
      Real.logb_le_logb_of_le (by norm_num) (iidClass A n).shtarkovSum_pos hC
    rwa [Real.logb_pow] at hle

end UniversalRedundancy