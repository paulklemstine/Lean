/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality IX: memoryless classes pay only for the type

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The sufficiency theorem of the previous file is applied to the source class the
research plan actually cares about: **memoryless (i.i.d.) sources**.

For a product law the vector of symbol counts is a sufficient statistic
(`prod_eq_prod_pow_countStat` in the catalog), so `capacity_iidSubClass_typeMap`
gives `C(f_*S) = C(S)` for `f x = ` the type (count vector) of `x`: **an
`n`-symbol message costs exactly what its type costs.**  Since the type lives in
a space of at most `(n+1)^{|A|}` points, the price of universality of *any*
finite family of memoryless sources on `n`-symbol messages obeys

  `C ≤ |A| · log₂ (n + 1)`   (`capacity_iidSubClass_le`)

*uniformly in the number of sources in the family* — a Rissanen-style `O(log n)`
rate obtained with no analysis at all, purely from sufficiency plus the counting
bound `capacity_le_logb_card_message`.  For the binary alphabet the sharper
statistic `typeStat` gives `C ≤ log₂ (n+1)` (`capacity_bernoulliFamily_le`),
which the smoothed constant-composition lower bound `(1−ε) log₂(n+1) − 4` of the
previous file matches to within a constant: **`log₂ n` is the exact order of the
average-case price of universality of a rich binary class of `n`-bit
messages.**

## Main results

* `shtarkovSum_le_card_message`, `capacity_le_logb_card_message` — counting bound
  in terms of the *message* space
* `iidSubClass` — a finite family of memoryless sources
* `TypeSpace`, `typeMap` — the (surjective) type statistic
* `capacity_iidSubClass_typeMap` — types are sufficient: capacity is unchanged
* `capacity_iidSubClass_le` — `C ≤ |A| log₂ (n+1)` for every finite i.i.d. family
* `capacity_bernoulliFamily_typeStat`, `capacity_bernoulliFamily_le` — the binary
  case, `C ≤ log₂ (n+1)`

## Application keywords

universal compression, minimax redundancy, capacity, memoryless sources, method
of types, sufficient statistic, Rissanen rate
-/

import Bridges.UniversalRedundancyCapacitySufficiency
import NumberTheory.UniversalRedundancyTypeClass

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} [Fintype Θ] (S : SourceClass X Θ)

omit [Fintype Θ] in
/-- The Shtarkov sum is at most the size of the **message** space. -/
theorem shtarkovSum_le_card_message [Nonempty Θ] :
    S.shtarkovSum ≤ (Fintype.card X : ℝ) := by
  calc S.shtarkovSum ≤ ∑ _x : X, (1 : ℝ) :=
        Finset.sum_le_sum fun x _ => S.maxLik_le_one x
    _ = (Fintype.card X : ℝ) := by simp

/-- **Counting bound in terms of the message space.**  No class on a message
space of `M` points can have a price of universality above `log₂ M`. -/
theorem capacity_le_logb_card_message [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    S.capacity ≤ logb 2 (Fintype.card X) :=
  le_trans (S.capacity_le_logb_shtarkovSum hpos)
    (Real.logb_le_logb_of_le (by norm_num) S.shtarkovSum_pos
      S.shtarkovSum_le_card_message)

end SourceClass

/-! ## Finite families of memoryless sources -/

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- A **finite family of memoryless sources**: the source `θ` emits `n` symbols
i.i.d. from the law `q θ`.  (The catalog's `iidClass` is indexed by the whole
simplex, which is not finite; the capacity theory needs a finite index.) -/
noncomputable def iidSubClass (A : Type*) [Fintype A] [DecidableEq A] (n : ℕ)
    {Θ : Type*} [Fintype Θ] (q : Θ → Simplex A) : SourceClass (Fin n → A) Θ where
  prob θ x := ∏ i, (q θ).1 (x i)
  nonneg θ x := Finset.prod_nonneg fun i _ => (q θ).2.1 (x i)
  sum_one θ := (iidClass A n).sum_one (q θ)

variable {Θ : Type*} [Fintype Θ]

lemma iidSubClass_prob (n : ℕ) (q : Θ → Simplex A) (θ : Θ) (x : Fin n → A) :
    (iidSubClass A n q).prob θ x = ∏ i, (q θ).1 (x i) := rfl

lemma iidSubClass_pos (n : ℕ) (q : Θ → Simplex A) (hq : ∀ θ a, 0 < (q θ).1 a)
    (θ : Θ) (x : Fin n → A) : 0 < (iidSubClass A n q).prob θ x := by
  show 0 < ∏ i, (q θ).1 (x i)
  exact Finset.prod_pos fun i _ => hq θ (x i)

/-- The **type space**: the count vectors that `n`-symbol messages can realise. -/
def TypeSpace (A : Type*) [Fintype A] [DecidableEq A] (n : ℕ) : Type _ :=
  {v : A → Fin (n + 1) // ∃ x : Fin n → A, (fun a => countStat x a) = v}

instance : DecidableEq (TypeSpace A n) := fun _ _ =>
  decidable_of_iff _ Subtype.ext_iff.symm

instance : Finite (TypeSpace A n) := Subtype.finite

noncomputable instance : Fintype (TypeSpace A n) := Fintype.ofFinite _

/-- The type (count vector) of a message, as an element of the type space. -/
def typeMap (n : ℕ) (x : Fin n → A) : TypeSpace A n :=
  ⟨fun a => countStat x a, ⟨x, rfl⟩⟩

lemma typeMap_surjective (n : ℕ) : Function.Surjective (typeMap (A := A) n) := by
  rintro ⟨v, x, rfl⟩
  exact ⟨x, rfl⟩

lemma card_typeSpace_le (n : ℕ) :
    (Fintype.card (TypeSpace A n) : ℝ) ≤ ((n : ℝ) + 1) ^ (Fintype.card A) := by
  have hinj : Fintype.card (TypeSpace A n) ≤ Fintype.card (A → Fin (n + 1)) :=
    Fintype.card_le_of_injective Subtype.val Subtype.val_injective
  have hcard : (Fintype.card (A → Fin (n + 1)) : ℝ) = ((n : ℝ) + 1) ^ (Fintype.card A) := by
    simp
  calc (Fintype.card (TypeSpace A n) : ℝ) ≤ (Fintype.card (A → Fin (n + 1)) : ℝ) := by
        exact_mod_cast hinj
    _ = ((n : ℝ) + 1) ^ (Fintype.card A) := hcard

/-- **The type is a sufficient statistic for a memoryless family**, so the price
of universality of the family is exactly the price of universality of the types:
nothing is lost by a front end that only records the type. -/
theorem capacity_iidSubClass_typeMap (n : ℕ) (q : Θ → Simplex A) :
    ((iidSubClass A n q).pushforward (typeMap (A := A) n)).capacity
      = (iidSubClass A n q).capacity := by
  refine (iidSubClass A n q).capacity_pushforward_eq_of_factorizes (typeMap (A := A) n)
    (g := fun (θ : Θ) (v : TypeSpace A n) => ∏ a, (q θ).1 a ^ ((v.1 a : Fin (n + 1)) : ℕ))
    (h := fun _ => 1) (fun _ => zero_le_one) ?_
  intro θ x
  rw [iidSubClass_prob, mul_one]
  exact prod_eq_prod_pow_countStat (fun a => (q θ).1 a) x

/-- **A Rissanen-style `O(log n)` rate for every finite memoryless family.**
Whatever the family — however many sources it contains — the average-case price
of universality of `n`-symbol messages is at most `|A| · log₂ (n+1)` bits: the
shared decompressor can never absorb more than the description of a type. -/
theorem capacity_iidSubClass_le [Nonempty Θ] (n : ℕ) (q : Θ → Simplex A)
    (hq : ∀ θ a, 0 < (q θ).1 a) :
    (iidSubClass A n q).capacity ≤ (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) := by
  have hpos : ∀ θ (v : TypeSpace A n),
      0 < ((iidSubClass A n q).pushforward (typeMap (A := A) n)).prob θ v :=
    fun θ v => (iidSubClass A n q).pushforward_pos (typeMap_surjective n)
      (iidSubClass_pos n q hq) θ v
  have hle := SourceClass.capacity_le_logb_card_message _ hpos
  rw [capacity_iidSubClass_typeMap] at hle
  refine le_trans hle ?_
  obtain ⟨x, -⟩ := (iidSubClass A n q).univ_nonempty
  have hcardpos : (0 : ℝ) < (Fintype.card (TypeSpace A n) : ℝ) := by
    have : 0 < Fintype.card (TypeSpace A n) :=
      Fintype.card_pos_iff.mpr ⟨typeMap n x⟩
    exact_mod_cast this
  calc logb 2 (Fintype.card (TypeSpace A n))
      ≤ logb 2 (((n : ℝ) + 1) ^ (Fintype.card A)) :=
        Real.logb_le_logb_of_le (by norm_num) hcardpos (card_typeSpace_le n)
    _ = (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) := by
        rw [Real.logb_pow]

/-! ## The binary case -/

/-- For a binary alphabet the number of ones is already a sufficient statistic:
the price of universality of a finite Bernoulli family is the price of
universality of the `n+1` composition classes. -/
theorem capacity_bernoulliFamily_typeStat (n : ℕ) (q : Θ → Simplex Bool) :
    ((iidSubClass Bool n q).pushforward (typeStat n)).capacity
      = (iidSubClass Bool n q).capacity := by
  refine (iidSubClass Bool n q).capacity_pushforward_eq_of_factorizes (typeStat n)
    (g := fun (θ : Θ) (c : Fin (n + 1)) =>
      (q θ).1 true ^ (c : ℕ) * (q θ).1 false ^ (n - (c : ℕ)))
    (h := fun _ => 1) (fun _ => zero_le_one) ?_
  intro θ x
  rw [iidSubClass_prob, mul_one]
  rw [prod_eq_prod_pow_countStat (fun b => (q θ).1 b) x, Fintype.prod_bool]
  have hct : ((countStat x true : Fin (n + 1)) : ℕ) = ones x := rfl
  have hcf : ((countStat x false : Fin (n + 1)) : ℕ) = n - ones x := card_zeros x
  have htype : ((typeStat n x : Fin (n + 1)) : ℕ) = ones x := rfl
  rw [hct, hcf]
  simp only [htype]

/-- **The price of universality of a binary memoryless family is at most
`log₂ (n+1)`.**  Together with the `(1−ε) log₂ (n+1) − 4` lower bound for the
smoothed constant-composition class, this pins the order of the average-case
price of universality of a rich binary class at `log₂ n`. -/
theorem capacity_bernoulliFamily_le [Nonempty Θ] (n : ℕ) (q : Θ → Simplex Bool)
    (hq : ∀ θ b, 0 < (q θ).1 b) :
    (iidSubClass Bool n q).capacity ≤ logb 2 ((n : ℝ) + 1) := by
  have hsurj : Function.Surjective (typeStat n) := by
    intro c
    obtain ⟨x, hx⟩ := typeStat_fiber_nonempty n c
    exact ⟨x, (Finset.mem_filter.mp hx).2⟩
  have hpos : ∀ θ (c : Fin (n + 1)),
      0 < ((iidSubClass Bool n q).pushforward (typeStat n)).prob θ c :=
    fun θ c => (iidSubClass Bool n q).pushforward_pos hsurj
      (iidSubClass_pos n q hq) θ c
  have hle := SourceClass.capacity_le_logb_card_message _ hpos
  rw [capacity_bernoulliFamily_typeStat] at hle
  simpa using hle

end UniversalRedundancy