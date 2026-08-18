/-
# The Price of Universality VIII: model selection — serving many specialised classes at once

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The research question asks whether it pays to specialise the decompressor to a
class of data.  The previous files quantify the price *inside* one class.  This
file quantifies the price of *choosing between* classes, which is the operative
question for a real system: if a shared decompressor must serve `m` different
specialised models, how much worse is it than the best specialised model?

The answer is the cleanest possible one: at most `log₂ m` bits.  The Shtarkov
sum of a union of classes is at most the sum of the Shtarkov sums, so

`log₂ Cₛ(⋃ᵢ Sᵢ) ≤ log₂ m + maxᵢ log₂ Cₛ(Sᵢ)`,

while the union is at least as expensive as each member.  This is the exact
"two-part code" / model-selection overhead, and it is what makes specialised
decompressors worth pursuing: model identity is `log₂ m` bits of *shared*
description, not a per-message cost.

## Main results

* `SourceClass.union`, `SourceClass.sigmaClass` — union of two / of a finite
  family of source classes
* `shtarkovSum_union_le`, `shtarkovSum_sigmaClass_le` — subadditivity of the
  Shtarkov sum
* `shtarkovSum_le_union_left/right`, `shtarkovSum_le_sigmaClass` — the union is
  never cheaper than any member
* `price_union_le` — `log₂ Cₛ(S ∪ T) ≤ 1 + max (log₂ Cₛ S) (log₂ Cₛ T)`
* `price_sigmaClass_le` — `log₂ Cₛ ≤ log₂ m + log₂ B` for `m` models each of
  price at most `log₂ B`
* `twice_universal_iid_markov` — one decompressor for *both* the memoryless and
  the first-order Markov class of length-`(n+1)` messages costs at most
  `1 + log₂ #A + #A² log₂ (n+1)` bits: the model bit is essentially free

## Application keywords

model selection, two-part codes, twice-universal coding, minimax redundancy,
Shtarkov sum, MDL
-/

import Logic.PriceOfUniversality.MultiAlphabet
import MachineLearning.UniversalRedundancy.Markov

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ Ψ : Type*}

/-- The union of two source classes: the shared decompressor must serve both. -/
def union (S : SourceClass X Θ) (T : SourceClass X Ψ) : SourceClass X (Θ ⊕ Ψ) where
  prob := Sum.elim S.prob T.prob
  nonneg := by rintro (θ | ψ) x <;> simp [S.nonneg, T.nonneg]
  sum_one := by rintro (θ | ψ) <;> simp [S.sum_one, T.sum_one]

variable (S : SourceClass X Θ) (T : SourceClass X Ψ)

/-- The maximum likelihood of a union is at most the sum of the two maximum
likelihoods. -/
lemma maxLik_union_le [Nonempty Θ] [Nonempty Ψ] (x : X) :
    (S.union T).maxLik x ≤ S.maxLik x + T.maxLik x := by
  refine (S.union T).maxLik_le ?_
  rintro (θ | ψ)
  · have h1 : S.prob θ x ≤ S.maxLik x := S.le_maxLik θ x
    have h2 : 0 ≤ T.maxLik x := T.maxLik_nonneg x
    simpa [union] using by linarith
  · have h1 : T.prob ψ x ≤ T.maxLik x := T.le_maxLik ψ x
    have h2 : 0 ≤ S.maxLik x := S.maxLik_nonneg x
    simpa [union] using by linarith

/-- **Subadditivity.**  The price of serving two classes is at most the price of
serving them separately, added multiplicatively. -/
theorem shtarkovSum_union_le [Nonempty Θ] [Nonempty Ψ] :
    (S.union T).shtarkovSum ≤ S.shtarkovSum + T.shtarkovSum := by
  calc (S.union T).shtarkovSum ≤ ∑ x, (S.maxLik x + T.maxLik x) :=
        Finset.sum_le_sum fun x _ => maxLik_union_le S T x
    _ = S.shtarkovSum + T.shtarkovSum := by
        rw [Finset.sum_add_distrib]; rfl

/-- The union is never cheaper than its first member. -/
theorem shtarkovSum_le_union_left [Nonempty Θ] [Nonempty Ψ] :
    S.shtarkovSum ≤ (S.union T).shtarkovSum :=
  (S.union T).shtarkovSum_mono_of_dominated S fun θ _ => ⟨Sum.inl θ, le_of_eq rfl⟩

/-- The union is never cheaper than its second member. -/
theorem shtarkovSum_le_union_right [Nonempty Θ] [Nonempty Ψ] :
    T.shtarkovSum ≤ (S.union T).shtarkovSum :=
  (S.union T).shtarkovSum_mono_of_dominated T fun ψ _ => ⟨Sum.inr ψ, le_of_eq rfl⟩

/-- **One model bit.**  Serving two classes with a single universal code costs
at most one bit more than serving the more expensive of the two. -/
theorem price_union_le [Nonempty Θ] [Nonempty Ψ] :
    logb 2 (S.union T).shtarkovSum
      ≤ 1 + max (logb 2 S.shtarkovSum) (logb 2 T.shtarkovSum) := by
  set M : ℝ := max S.shtarkovSum T.shtarkovSum with hM
  have hMpos : 0 < M := lt_of_lt_of_le S.shtarkovSum_pos (le_max_left _ _)
  have hsum : (S.union T).shtarkovSum ≤ 2 * M := by
    have := shtarkovSum_union_le S T
    have h1 : S.shtarkovSum ≤ M := le_max_left _ _
    have h2 : T.shtarkovSum ≤ M := le_max_right _ _
    linarith
  have hlog : logb 2 (S.union T).shtarkovSum ≤ logb 2 (2 * M) :=
    Real.logb_le_logb_of_le (by norm_num) (S.union T).shtarkovSum_pos hsum
  have hsplit : logb 2 (2 * M) = 1 + logb 2 M := by
    rw [Real.logb_mul (by norm_num) hMpos.ne', Real.logb_self_eq_one (by norm_num)]
  have hmax : logb 2 M = max (logb 2 S.shtarkovSum) (logb 2 T.shtarkovSum) := by
    rcases max_cases S.shtarkovSum T.shtarkovSum with ⟨he, hle⟩ | ⟨he, hlt⟩
    · rw [hM, he, max_eq_left (Real.logb_le_logb_of_le (by norm_num)
        T.shtarkovSum_pos hle)]
    · rw [hM, he, max_eq_right (Real.logb_le_logb_of_le (by norm_num)
        S.shtarkovSum_pos hlt.le)]
  rw [hsplit, hmax] at hlog
  exact hlog

/-! ## Finitely many models -/

variable {ι : Type*} {Θ' : ι → Type*}

/-- The union of a finite family of source classes. -/
def sigmaClass [Fintype ι] (S : ∀ i, SourceClass X (Θ' i)) :
    SourceClass X (Σ i, Θ' i) where
  prob p x := (S p.1).prob p.2 x
  nonneg p x := (S p.1).nonneg p.2 x
  sum_one p := (S p.1).sum_one p.2

/-- **Subadditivity for a family.** -/
theorem shtarkovSum_sigmaClass_le [Fintype ι] [Nonempty ι] [∀ i, Nonempty (Θ' i)]
    (S : ∀ i, SourceClass X (Θ' i)) :
    (sigmaClass S).shtarkovSum ≤ ∑ i, (S i).shtarkovSum := by
  haveI : Nonempty (Σ i, Θ' i) :=
    ⟨⟨Classical.arbitrary ι, Classical.arbitrary (Θ' (Classical.arbitrary ι))⟩⟩
  have hpt : ∀ x : X, (sigmaClass S).maxLik x ≤ ∑ i, (S i).maxLik x := by
    intro x
    refine (sigmaClass S).maxLik_le ?_
    rintro ⟨i, θ⟩
    calc (sigmaClass S).prob ⟨i, θ⟩ x = (S i).prob θ x := rfl
      _ ≤ (S i).maxLik x := (S i).le_maxLik θ x
      _ ≤ ∑ j, (S j).maxLik x :=
          Finset.single_le_sum (f := fun j => (S j).maxLik x)
            (fun j _ => (S j).maxLik_nonneg x) (Finset.mem_univ i)
  calc (sigmaClass S).shtarkovSum ≤ ∑ x, ∑ i, (S i).maxLik x :=
        Finset.sum_le_sum fun x _ => hpt x
    _ = ∑ i, ∑ x, (S i).maxLik x := Finset.sum_comm
    _ = ∑ i, (S i).shtarkovSum := rfl

/-- Every member of the family is at most as expensive as the union. -/
theorem shtarkovSum_le_sigmaClass [Fintype ι] [Nonempty ι] [∀ i, Nonempty (Θ' i)]
    (S : ∀ i, SourceClass X (Θ' i)) (i : ι) :
    (S i).shtarkovSum ≤ (sigmaClass S).shtarkovSum := by
  haveI : Nonempty (Σ i, Θ' i) :=
    ⟨⟨Classical.arbitrary ι, Classical.arbitrary (Θ' (Classical.arbitrary ι))⟩⟩
  exact (sigmaClass S).shtarkovSum_mono_of_dominated (S i)
    fun θ _ => ⟨⟨i, θ⟩, le_of_eq rfl⟩

/-- **The model-selection theorem.**  If each of `m` specialised classes has
price of universality at most `log₂ B`, a single decompressor serving all of
them has price at most `log₂ m + log₂ B`: the identity of the model is a
one-off `log₂ m` bits of shared description. -/
theorem price_sigmaClass_le [Fintype ι] [Nonempty ι] [∀ i, Nonempty (Θ' i)]
    (S : ∀ i, SourceClass X (Θ' i)) {B : ℝ} (hB : ∀ i, (S i).shtarkovSum ≤ B) :
    logb 2 (sigmaClass S).shtarkovSum
      ≤ logb 2 (Fintype.card ι : ℝ) + logb 2 B := by
  haveI : Nonempty (Σ i, Θ' i) :=
    ⟨⟨Classical.arbitrary ι, Classical.arbitrary (Θ' (Classical.arbitrary ι))⟩⟩
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have hB1 : 1 ≤ B := le_trans (S (Classical.arbitrary ι)).one_le_shtarkovSum
    (hB (Classical.arbitrary ι))
  have hle : (sigmaClass S).shtarkovSum ≤ (Fintype.card ι : ℝ) * B := by
    calc (sigmaClass S).shtarkovSum ≤ ∑ i, (S i).shtarkovSum :=
          shtarkovSum_sigmaClass_le S
      _ ≤ ∑ _i : ι, B := Finset.sum_le_sum fun i _ => hB i
      _ = (Fintype.card ι : ℝ) * B := by simp [mul_comm]
  have hlog : logb 2 (sigmaClass S).shtarkovSum
      ≤ logb 2 ((Fintype.card ι : ℝ) * B) :=
    Real.logb_le_logb_of_le (by norm_num) (sigmaClass S).shtarkovSum_pos hle
  rwa [Real.logb_mul hcard.ne' (by linarith)] at hlog

/-- **The model-selection bound is tight for mutually singular models.**  If the
models live on disjoint sets of messages, the Shtarkov sums add exactly, so the
`log₂ m` overhead of `price_sigmaClass_le` is really paid: the shared
decompressor must name the model. -/
theorem shtarkovSum_sigmaClass_eq_sum_of_disjoint [Fintype ι] [Nonempty ι]
    [∀ i, Nonempty (Θ' i)] (S : ∀ i, SourceClass X (Θ' i)) (supp : ι → Finset X)
    (hdisj : ∀ i j, i ≠ j → Disjoint (supp i) (supp j))
    (hzero : ∀ i θ x, x ∉ supp i → (S i).prob θ x = 0) :
    (sigmaClass S).shtarkovSum = ∑ i, (S i).shtarkovSum := by
  classical
  haveI : Nonempty (Σ i, Θ' i) :=
    ⟨⟨Classical.arbitrary ι, Classical.arbitrary (Θ' (Classical.arbitrary ι))⟩⟩
  have hmax0 : ∀ i x, x ∉ supp i → (S i).maxLik x = 0 := fun i x hx =>
    le_antisymm ((S i).maxLik_le fun θ => le_of_eq (hzero i θ x hx))
      ((S i).maxLik_nonneg x)
  have hsum_i : ∀ i, (S i).shtarkovSum = ∑ x ∈ supp i, (S i).maxLik x := fun i =>
    (Finset.sum_subset (Finset.subset_univ _) fun x _ hx => hmax0 i x hx).symm
  have hmax_sig : ∀ i, ∀ x ∈ supp i, (sigmaClass S).maxLik x = (S i).maxLik x := by
    intro i x hx
    refine le_antisymm ?_ ((S i).maxLik_le fun θ => (sigmaClass S).le_maxLik ⟨i, θ⟩ x)
    refine (sigmaClass S).maxLik_le ?_
    rintro ⟨j, θ⟩
    by_cases hji : j = i
    · subst hji
      exact (S j).le_maxLik θ x
    · have hxj : x ∉ supp j := fun hxj =>
        (Finset.disjoint_left.mp (hdisj j i hji) hxj) hx
      show (S j).prob θ x ≤ (S i).maxLik x
      rw [hzero j θ x hxj]
      exact (S i).maxLik_nonneg x
  have hcover : ∀ x ∉ (univ : Finset ι).biUnion supp, (sigmaClass S).maxLik x = 0 := by
    intro x hx
    refine le_antisymm ?_ ((sigmaClass S).maxLik_nonneg x)
    refine (sigmaClass S).maxLik_le ?_
    rintro ⟨j, θ⟩
    have hxj : x ∉ supp j := fun hmem =>
      hx (Finset.mem_biUnion.mpr ⟨j, Finset.mem_univ j, hmem⟩)
    exact le_of_eq (hzero j θ x hxj)
  have hdisj' : ∀ i ∈ (univ : Finset ι), ∀ j ∈ (univ : Finset ι), i ≠ j →
      Disjoint (supp i) (supp j) := fun i _ j _ h => hdisj i j h
  calc (sigmaClass S).shtarkovSum
      = ∑ x ∈ (univ : Finset ι).biUnion supp, (sigmaClass S).maxLik x :=
        (Finset.sum_subset (Finset.subset_univ _) fun x _ hx => hcover x hx).symm
    _ = ∑ i, ∑ x ∈ supp i, (sigmaClass S).maxLik x := Finset.sum_biUnion hdisj'
    _ = ∑ i, ∑ x ∈ supp i, (S i).maxLik x :=
        Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun x hx => hmax_sig i x hx
    _ = ∑ i, (S i).shtarkovSum := Finset.sum_congr rfl fun i _ => (hsum_i i).symm

/-- **Exactly `log₂ m` extra bits.**  For `m` mutually singular models of equal
price `log₂ C`, the price of the shared decompressor is exactly
`log₂ m + log₂ C`: the model-selection overhead of `price_sigmaClass_le` is
attained. -/
theorem price_sigmaClass_eq_of_disjoint [Fintype ι] [Nonempty ι]
    [∀ i, Nonempty (Θ' i)] (S : ∀ i, SourceClass X (Θ' i)) (supp : ι → Finset X)
    (hdisj : ∀ i j, i ≠ j → Disjoint (supp i) (supp j))
    (hzero : ∀ i θ x, x ∉ supp i → (S i).prob θ x = 0)
    {C : ℝ} (hC : ∀ i, (S i).shtarkovSum = C) :
    logb 2 (sigmaClass S).shtarkovSum
      = logb 2 (Fintype.card ι : ℝ) + logb 2 C := by
  have hCpos : 0 < C := by
    rw [← hC (Classical.arbitrary ι)]
    exact (S (Classical.arbitrary ι)).shtarkovSum_pos
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have heq := shtarkovSum_sigmaClass_eq_sum_of_disjoint S supp hdisj hzero
  have hsum : ∑ i, (S i).shtarkovSum = (Fintype.card ι : ℝ) * C := by
    rw [Finset.sum_congr rfl fun i _ => hC i]
    simp [mul_comm]
  rw [heq, hsum, Real.logb_mul hcard.ne' hCpos.ne']

end SourceClass

/-! ## Twice-universal coding: memoryless *and* Markov -/

variable {A : Type*} [Fintype A] [DecidableEq A] [Nonempty A]

/-- **Twice-universal coding.**  A single decompressor that must serve both the
memoryless class and the first-order Markov class on messages of length `n + 1`
pays at most `1 + log₂ #A + #A² log₂ (n+2)` bits over the code tailored to the
true source — one bit more than the Markov class alone.  Specialisation is
therefore cheap to *combine*: the price of keeping several specialised models in
one shared decompressor is the logarithm of the number of models. -/
theorem twice_universal_iid_markov (n : ℕ) :
    logb 2 ((iidClass A (n + 1)).union (markovClass A n)).shtarkovSum
      ≤ 1 + (logb 2 (Fintype.card A : ℝ)
          + (Fintype.card A : ℝ) * (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 2)) := by
  have hcard : (0 : ℝ) < (Fintype.card A : ℝ) := by exact_mod_cast Fintype.card_pos
  have hcard1 : (1 : ℝ) ≤ (Fintype.card A : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hn2 : (1 : ℝ) ≤ (n : ℝ) + 2 := by
    have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  set m : ℕ := Fintype.card A with hm
  set Bexp : ℝ := (m : ℝ) * ((n : ℝ) + 2) ^ (m * m) with hBexp
  have hexp : m - 1 ≤ m * m := le_trans (Nat.sub_le m 1)
    (Nat.le_mul_of_pos_left m Fintype.card_pos)
  -- both classes have Shtarkov sum at most `Bexp`
  have hiid : (iidClass A (n + 1)).shtarkovSum ≤ Bexp := by
    have h := shtarkovSum_iidClass_le_dim (A := A) (n + 1)
    have hcast : (((n + 1 : ℕ) : ℝ) + 1) = (n : ℝ) + 2 := by push_cast; ring
    rw [hcast] at h
    have hmono : ((n : ℝ) + 2) ^ (m - 1) ≤ ((n : ℝ) + 2) ^ (m * m) :=
      pow_le_pow_right₀ hn2 hexp
    have hpos : (0 : ℝ) ≤ ((n : ℝ) + 2) ^ (m * m) := by positivity
    calc (iidClass A (n + 1)).shtarkovSum ≤ ((n : ℝ) + 2) ^ (m - 1) := h
      _ ≤ ((n : ℝ) + 2) ^ (m * m) := hmono
      _ ≤ Bexp := by rw [hBexp]; nlinarith
  have hmarkov : (markovClass A n).shtarkovSum ≤ Bexp := by
    have h := shtarkovSum_markovClass_le (A := A) n
    have hcast : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
    rw [hcast] at h
    have hstep : ((n : ℝ) + 1) ^ (m * m) ≤ ((n : ℝ) + 2) ^ (m * m) :=
      pow_le_pow_left₀ (by positivity) (by linarith) _
    calc (markovClass A n).shtarkovSum
        ≤ (m : ℝ) * ((n : ℝ) + 1) ^ (m * m) := h
      _ ≤ (m : ℝ) * ((n : ℝ) + 2) ^ (m * m) := by nlinarith
      _ = Bexp := rfl
  have hunion := (iidClass A (n + 1)).shtarkovSum_union_le (markovClass A n)
  have hle : ((iidClass A (n + 1)).union (markovClass A n)).shtarkovSum ≤ 2 * Bexp := by
    linarith
  have hBpos : 0 < Bexp := by
    rw [hBexp]; positivity
  have hlog : logb 2 ((iidClass A (n + 1)).union (markovClass A n)).shtarkovSum
      ≤ logb 2 (2 * Bexp) :=
    Real.logb_le_logb_of_le (by norm_num)
      ((iidClass A (n + 1)).union (markovClass A n)).shtarkovSum_pos hle
  have hsplit : logb 2 (2 * Bexp)
      = 1 + (logb 2 (Fintype.card A : ℝ)
        + (Fintype.card A : ℝ) * (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 2)) := by
    rw [hBexp, Real.logb_mul (by norm_num) (by positivity),
      Real.logb_self_eq_one (by norm_num), Real.logb_mul (by positivity) (by positivity),
      Real.logb_pow]
    push_cast
    ring
  linarith [hsplit ▸ hlog]

end UniversalRedundancy