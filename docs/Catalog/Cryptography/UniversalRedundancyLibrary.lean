/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VIII: the price is a submodular set function

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A.

`Cryptography.UniversalRedundancyMarginal` computes the *marginal value of a
model*: adjoining one source `p` to a class raises the Shtarkov sum by exactly
`∑ₓ (p x − maxLik x)⁺`.  Since the positive part `(p x − t)⁺` is antitone in the
incumbent envelope `t`, this immediately says that the Shtarkov sum, viewed as a
function of the *library* of models one is universal for, has **diminishing
returns**.

This file makes that precise.  For a family of candidate models `P : ι → X → ℝ`
we define the envelope `envelope P A x = maxᵢ∈A P i x` (with the convention
`envelope P ∅ = 0`) and the library price functional

`shtarkov P A = ∑ₓ envelope P A x`.

We prove that `shtarkov P` is a monotone, submodular set function vanishing on
the empty library, that it agrees with the Shtarkov sum of the corresponding
source class whenever `A` is nonempty and the `P i` are probability mass
functions, and — the payoff — that **greedy library design is
`(1 − 1/e)`-optimal**: after `n` greedy insertions the library is within a
factor `1 − 1/e` of the best possible library of size `n`.

## Main results

* `Library.envelope`, `Library.shtarkov` — the library price functional;
* `Library.shtarkov_insert_sub` — marginal value in library form;
* `Library.shtarkov_mono`, `Library.shtarkov_submodular` — monotone + submodular
  (`C(A ∪ B) + C(A ∩ B) ≤ C(A) + C(B)`);
* `Library.shtarkov_diminishing` — diminishing returns;
* `Library.shtarkov_union_sub_le_sum` — the submodular covering inequality;
* `Library.exists_greedy_step` — one greedy step recovers a `1/|B|` fraction of
  the remaining gap;
* `Library.greedy_gap_le` — geometric decay of the optimality gap;
* `Library.greedy_one_sub_inv_exp_le` — the `(1 − 1/e)` guarantee;
* `Library.shtarkovSum_libraryClass` — the bridge to
  `UniversalRedundancy.SourceClass.shtarkovSum`.

## Application keywords

universal compression, Shtarkov sum, submodularity, greedy approximation,
model libraries, price of universality
-/

import Cryptography.UniversalRedundancyMarginal

open Finset Real

namespace UniversalRedundancy

namespace Library

variable {X : Type*} {ι : Type*} (P : ι → X → ℝ)

/-! ## The maximum-likelihood envelope of a finite library -/

/-- The maximum-likelihood envelope of the library `A ⊆ ι`, i.e. the pointwise
maximum of the models in `A` (and `0` for the empty library). -/
noncomputable def envelope (A : Finset ι) (x : X) : ℝ := A.fold max 0 fun i => P i x

@[simp] lemma envelope_empty (x : X) : envelope P ∅ x = 0 := rfl

lemma envelope_nonneg (A : Finset ι) (x : X) : 0 ≤ envelope P A x :=
  (Finset.le_fold_max 0).2 (Or.inl le_rfl)

lemma le_envelope {i : ι} {A : Finset ι} (hi : i ∈ A) (x : X) :
    P i x ≤ envelope P A x :=
  (Finset.le_fold_max _).2 (Or.inr ⟨i, hi, le_rfl⟩)

lemma envelope_le {A : Finset ι} {x : X} {c : ℝ} (hc : 0 ≤ c)
    (h : ∀ i ∈ A, P i x ≤ c) : envelope P A x ≤ c :=
  (Finset.fold_max_le c).2 ⟨hc, h⟩

lemma envelope_mono {A B : Finset ι} (hAB : A ⊆ B) (x : X) :
    envelope P A x ≤ envelope P B x :=
  envelope_le P (envelope_nonneg P B x) fun _ hi => le_envelope P (hAB hi) x

section DecEq

variable [DecidableEq ι]

@[simp] lemma envelope_insert (j : ι) (A : Finset ι) (x : X) :
    envelope P (insert j A) x = max (P j x) (envelope P A x) :=
  Finset.fold_insert_idem

lemma envelope_union (A B : Finset ι) (x : X) :
    envelope P (A ∪ B) x = max (envelope P A x) (envelope P B x) := by
  refine le_antisymm (envelope_le P (le_trans (envelope_nonneg P A x) (le_max_left _ _)) ?_)
    (max_le (envelope_mono P Finset.subset_union_left x)
      (envelope_mono P Finset.subset_union_right x))
  intro i hi
  rcases Finset.mem_union.1 hi with h | h
  · exact le_trans (le_envelope P h x) (le_max_left _ _)
  · exact le_trans (le_envelope P h x) (le_max_right _ _)

end DecEq

/-! ## The library price functional -/

variable [Fintype X]

/-- The Shtarkov sum of a finite library of models: the `ℓ¹` norm of the
envelope. -/
noncomputable def shtarkov (A : Finset ι) : ℝ := ∑ x, envelope P A x

@[simp] lemma shtarkov_empty : shtarkov P (∅ : Finset ι) = 0 := by simp [shtarkov]

lemma shtarkov_nonneg (A : Finset ι) : 0 ≤ shtarkov P A :=
  Finset.sum_nonneg fun x _ => envelope_nonneg P A x

/-- **Monotonicity.**  A larger library is at least as expensive. -/
theorem shtarkov_mono {A B : Finset ι} (hAB : A ⊆ B) : shtarkov P A ≤ shtarkov P B :=
  Finset.sum_le_sum fun x _ => envelope_mono P hAB x

variable [DecidableEq ι]

/-- **Marginal value of a model, library form.**  Inserting the model `j` into
the library `A` raises the price by the mass on which `j` beats the envelope. -/
theorem shtarkov_insert_sub (j : ι) (A : Finset ι) :
    shtarkov P (insert j A) - shtarkov P A
      = ∑ x, max (P j x - envelope P A x) 0 := by
  unfold shtarkov
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [envelope_insert, ← SourceClass.max_sub_right (P j x) (envelope P A x)]

/-- **Submodularity.**  `C(A ∪ B) + C(A ∩ B) ≤ C(A) + C(B)`: the price of
universality is a submodular set function on model libraries. -/
theorem shtarkov_submodular (A B : Finset ι) :
    shtarkov P (A ∪ B) + shtarkov P (A ∩ B) ≤ shtarkov P A + shtarkov P B := by
  unfold shtarkov
  rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
  refine Finset.sum_le_sum fun x _ => ?_
  have hu : envelope P (A ∪ B) x = max (envelope P A x) (envelope P B x) :=
    envelope_union P A B x
  have hiA : envelope P (A ∩ B) x ≤ envelope P A x :=
    envelope_mono P Finset.inter_subset_left x
  have hiB : envelope P (A ∩ B) x ≤ envelope P B x :=
    envelope_mono P Finset.inter_subset_right x
  rw [hu]
  rcases le_total (envelope P A x) (envelope P B x) with h | h
  · rw [max_eq_right h]; linarith
  · rw [max_eq_left h]; linarith

/-- **Diminishing returns.**  The marginal value of a model shrinks as the
library grows — the equivalent "economic" form of submodularity. -/
theorem shtarkov_diminishing {A B : Finset ι} (hAB : A ⊆ B) (j : ι) :
    shtarkov P (insert j B) - shtarkov P B
      ≤ shtarkov P (insert j A) - shtarkov P A := by
  rw [shtarkov_insert_sub, shtarkov_insert_sub]
  refine Finset.sum_le_sum fun x _ => ?_
  exact max_le_max_right 0 (by linarith [envelope_mono P hAB x])

/-! ## The submodular covering inequality and the greedy step -/

omit [Fintype X] in
lemma envelope_union_sub_le (A : Finset ι) (x : X) : ∀ B : Finset ι,
    envelope P (A ∪ B) x - envelope P A x
      ≤ ∑ j ∈ B, max (P j x - envelope P A x) 0 := by
  intro B
  induction B using Finset.induction_on with
  | empty => simp
  | insert j B hj ih =>
      have hsum : (0 : ℝ) ≤ ∑ i ∈ B, max (P i x - envelope P A x) 0 :=
        Finset.sum_nonneg fun i _ => le_max_right _ _
      have hins : A ∪ insert j B = insert j (A ∪ B) := by
        ext y; simp [Finset.mem_union, Finset.mem_insert]
      rw [hins, envelope_insert, Finset.sum_insert hj]
      have ht : (0 : ℝ) ≤ max (P j x - envelope P A x) 0 := le_max_right _ _
      have ht' : P j x - envelope P A x ≤ max (P j x - envelope P A x) 0 := le_max_left _ _
      rcases le_total (P j x) (envelope P (A ∪ B) x) with h | h
      · rw [max_eq_right h]; linarith
      · rw [max_eq_left h]; linarith

/-- **Submodular covering inequality.**  The value that the whole library `B`
would add on top of `A` is at most the sum of the individual marginal values. -/
theorem shtarkov_union_sub_le_sum (A B : Finset ι) :
    shtarkov P (A ∪ B) - shtarkov P A
      ≤ ∑ j ∈ B, (shtarkov P (insert j A) - shtarkov P A) := by
  have h1 : shtarkov P (A ∪ B) - shtarkov P A
      ≤ ∑ x, ∑ j ∈ B, max (P j x - envelope P A x) 0 := by
    unfold shtarkov
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_le_sum fun x _ => envelope_union_sub_le P A x B
  calc shtarkov P (A ∪ B) - shtarkov P A
      ≤ ∑ x, ∑ j ∈ B, max (P j x - envelope P A x) 0 := h1
    _ = ∑ j ∈ B, ∑ x, max (P j x - envelope P A x) 0 := Finset.sum_comm
    _ = ∑ j ∈ B, (shtarkov P (insert j A) - shtarkov P A) :=
        Finset.sum_congr rfl fun j _ => (shtarkov_insert_sub P j A).symm

/-- **One greedy step is worth its share of the gap.**  For any target library
`B` there is a single model `j ∈ B` whose marginal value on top of the current
library `A` is at least a `1/|B|` fraction of the gap `C(B) − C(A)`. -/
theorem exists_greedy_step {A B : Finset ι} (hB : B.Nonempty) :
    ∃ j ∈ B, (shtarkov P B - shtarkov P A) / (B.card : ℝ)
      ≤ shtarkov P (insert j A) - shtarkov P A := by
  have hcard : (0 : ℝ) < (B.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hB
  have hmono : shtarkov P B ≤ shtarkov P (A ∪ B) :=
    shtarkov_mono P Finset.subset_union_right
  have hconst : ∑ _j ∈ B, (shtarkov P B - shtarkov P A) / (B.card : ℝ)
      = shtarkov P B - shtarkov P A := by
    rw [Finset.sum_const, nsmul_eq_mul]
    field_simp
  refine Finset.exists_le_of_sum_le hB ?_
  rw [hconst]
  calc shtarkov P B - shtarkov P A ≤ shtarkov P (A ∪ B) - shtarkov P A := by linarith
    _ ≤ ∑ j ∈ B, (shtarkov P (insert j A) - shtarkov P A) :=
        shtarkov_union_sub_le_sum P A B

/-! ## Greedy library design is `(1 − 1/e)`-optimal -/

/-- A greedy run: `A 0 = ∅` and each step inserts a model of maximal marginal
value. -/
structure GreedyRun (A : ℕ → Finset ι) : Prop where
  init : A 0 = ∅
  step : ∀ k, ∃ j, A (k + 1) = insert j (A k)
  optimal : ∀ k, ∀ j : ι, shtarkov P (insert j (A k)) ≤ shtarkov P (A (k + 1))

/-- A greedy run adds at most one model per step, so after `k` steps the
library has at most `k` members: the guarantee below really compares libraries
of the same size. -/
theorem GreedyRun.card_le {A : ℕ → Finset ι} (hrun : GreedyRun P A) :
    ∀ k, (A k).card ≤ k := by
  intro k
  induction k with
  | zero => simp [hrun.init]
  | succ k ih =>
      obtain ⟨j, hj⟩ := hrun.step k
      rw [hj]
      exact le_trans (Finset.card_insert_le j (A k)) (by omega)

/-- **Geometric decay of the optimality gap.**  Against any target library `B`
of size `n ≥ 1`, the gap after `k` greedy steps has shrunk by the factor
`(1 − 1/n)^k`. -/
theorem greedy_gap_le {A : ℕ → Finset ι} (hrun : GreedyRun P A)
    {B : Finset ι} (hB : B.Nonempty) :
    ∀ k : ℕ, shtarkov P B - shtarkov P (A k)
      ≤ (1 - 1 / (B.card : ℝ)) ^ k * shtarkov P B := by
  have hcard : (1 : ℝ) ≤ (B.card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 hB
  have hcpos : (0 : ℝ) < (B.card : ℝ) := by linarith
  have hfac : (0 : ℝ) ≤ 1 - 1 / (B.card : ℝ) := by
    have : 1 / (B.card : ℝ) ≤ 1 := by
      rw [div_le_one hcpos]; exact hcard
    linarith
  intro k
  induction k with
  | zero => simp [hrun.init]
  | succ k ih =>
      obtain ⟨j, hj, hjle⟩ := exists_greedy_step P (A := A k) (B := B) hB
      have hstep : (shtarkov P B - shtarkov P (A k)) / (B.card : ℝ)
          ≤ shtarkov P (A (k + 1)) - shtarkov P (A k) :=
        le_trans hjle (by linarith [hrun.optimal k j])
      have hgap : shtarkov P B - shtarkov P (A (k + 1))
          ≤ (1 - 1 / (B.card : ℝ)) * (shtarkov P B - shtarkov P (A k)) := by
        have hdiv : (shtarkov P B - shtarkov P (A k)) / (B.card : ℝ)
            = (1 / (B.card : ℝ)) * (shtarkov P B - shtarkov P (A k)) := by
          field_simp
        rw [hdiv] at hstep
        nlinarith
      calc shtarkov P B - shtarkov P (A (k + 1))
          ≤ (1 - 1 / (B.card : ℝ)) * (shtarkov P B - shtarkov P (A k)) := hgap
        _ ≤ (1 - 1 / (B.card : ℝ)) * ((1 - 1 / (B.card : ℝ)) ^ k * shtarkov P B) :=
            mul_le_mul_of_nonneg_left ih hfac
        _ = (1 - 1 / (B.card : ℝ)) ^ (k + 1) * shtarkov P B := by ring

/-- `(1 − 1/n)^n ≤ e⁻¹` for `n ≥ 1`. -/
lemma one_sub_inv_pow_le_exp_neg_one {n : ℕ} (hn : 1 ≤ n) :
    (1 - 1 / (n : ℝ)) ^ n ≤ Real.exp (-1) := by
  have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hbase : 1 - 1 / (n : ℝ) ≤ Real.exp (-(1 / (n : ℝ))) := by
    have := Real.add_one_le_exp (-(1 / (n : ℝ)))
    linarith
  have hnonneg : (0 : ℝ) ≤ 1 - 1 / (n : ℝ) := by
    have : 1 / (n : ℝ) ≤ 1 := by
      rw [div_le_one hnpos]; exact_mod_cast hn
    linarith
  calc (1 - 1 / (n : ℝ)) ^ n ≤ (Real.exp (-(1 / (n : ℝ)))) ^ n :=
        pow_le_pow_left₀ hnonneg hbase n
    _ = Real.exp ((n : ℝ) * -(1 / (n : ℝ))) := by
        rw [← Real.exp_nat_mul]
    _ = Real.exp (-1) := by
        congr 1
        field_simp

/-- **Greedy library design is `(1 − 1/e)`-optimal.**  After `n = |B|` greedy
insertions the price collected by the greedy library is at least
`(1 − 1/e)` times that of the *best* library of size `n`; since the price
functional is monotone and submodular, this is the classical greedy guarantee,
now in the setting of universal decompressor design. -/
theorem greedy_one_sub_inv_exp_le {A : ℕ → Finset ι} (hrun : GreedyRun P A)
    {B : Finset ι} (hB : B.Nonempty) :
    (1 - Real.exp (-1)) * shtarkov P B ≤ shtarkov P (A B.card) := by
  have hcard : 1 ≤ B.card := Finset.card_pos.2 hB
  have hgap := greedy_gap_le P hrun hB B.card
  have hpow := one_sub_inv_pow_le_exp_neg_one (n := B.card) hcard
  have hBnn : 0 ≤ shtarkov P B := shtarkov_nonneg P B
  nlinarith

/-! ## Greedy runs exist -/

section Exists

variable [Fintype ι] [Nonempty ι]

/-- The model of maximal marginal value on top of the library `A`. -/
noncomputable def greedyChoice (A : Finset ι) : ι :=
  (Finite.exists_max fun j => shtarkov P (insert j A)).choose

lemma le_greedyChoice (A : Finset ι) (j : ι) :
    shtarkov P (insert j A) ≤ shtarkov P (insert (greedyChoice P A) A) :=
  (Finite.exists_max fun j => shtarkov P (insert j A)).choose_spec j

/-- The canonical greedy library sequence. -/
noncomputable def greedySeq : ℕ → Finset ι
  | 0 => ∅
  | k + 1 => insert (greedyChoice P (greedySeq k)) (greedySeq k)

/-- The canonical greedy sequence really is a greedy run, so the approximation
guarantee below is not vacuous. -/
theorem greedyRun_greedySeq : GreedyRun P (greedySeq P) where
  init := rfl
  step k := ⟨greedyChoice P (greedySeq P k), rfl⟩
  optimal k j := le_greedyChoice P (greedySeq P k) j

/-- **Greedy decompressor-library design.**  The canonical greedy library of
size at most `n` is within a factor `1 − 1/e` of the best library of size `n`,
for every candidate pool of models. -/
theorem greedySeq_one_sub_inv_exp_le {B : Finset ι} (hB : B.Nonempty) :
    (1 - Real.exp (-1)) * shtarkov P B ≤ shtarkov P (greedySeq P B.card) :=
  greedy_one_sub_inv_exp_le P (greedyRun_greedySeq P) hB

end Exists

/-! ## Bridge: the library functional *is* the Shtarkov sum -/

section Bridge

variable {A : Finset ι} (hP0 : ∀ i, ∀ x, 0 ≤ P i x) (hP1 : ∀ i, ∑ x, P i x = 1)

/-- The source class consisting of the models indexed by a library `A`. -/
def libraryClass (A : Finset ι) : SourceClass X {i // i ∈ A} where
  prob i x := P i.1 x
  nonneg i x := hP0 i.1 x
  sum_one i := hP1 i.1

omit [DecidableEq ι] in
/-- The maximum-likelihood envelope of the library class is the library
envelope. -/
theorem maxLik_libraryClass (hA : A.Nonempty) (x : X) :
    haveI : Nonempty {i // i ∈ A} := ⟨⟨hA.choose, hA.choose_spec⟩⟩
    (libraryClass P hP0 hP1 A).maxLik x = envelope P A x := by
  haveI : Nonempty {i // i ∈ A} := ⟨⟨hA.choose, hA.choose_spec⟩⟩
  refine le_antisymm ((libraryClass P hP0 hP1 A).maxLik_le fun i => le_envelope P i.2 x) ?_
  exact envelope_le P ((libraryClass P hP0 hP1 A).maxLik_nonneg x)
    fun i hi => (libraryClass P hP0 hP1 A).le_maxLik ⟨i, hi⟩ x

omit [DecidableEq ι] in
/-- **The library price functional is the Shtarkov sum.**  Hence all the
submodularity results above are statements about the genuine price of
universality `log₂ Cₛ` of the class of models in the library. -/
theorem shtarkovSum_libraryClass (hA : A.Nonempty) :
    haveI : Nonempty {i // i ∈ A} := ⟨⟨hA.choose, hA.choose_spec⟩⟩
    (libraryClass P hP0 hP1 A).shtarkovSum = shtarkov P A := by
  haveI : Nonempty {i // i ∈ A} := ⟨⟨hA.choose, hA.choose_spec⟩⟩
  exact Finset.sum_congr rfl fun x _ => maxLik_libraryClass P hP0 hP1 hA x

end Bridge

end Library

end UniversalRedundancy