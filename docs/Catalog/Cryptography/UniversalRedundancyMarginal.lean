/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VII: the marginal value of a model

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A.

Previous instalments identified the price of universality of a source class with
`log₂ Cₛ`, where `Cₛ = ∑ₓ sup_θ p_θ x` is the Shtarkov sum, and settled the
*qualitative* half of the picture:

* `shtarkovSum_eq_one_iff` — the price vanishes iff the class is degenerate;
* `price_reindex_le` — the price is monotone in the class.

This file supplies the *quantitative* half.  Enlarging a class `S` by a single
new source `p` changes the Shtarkov sum by exactly the mass on which the new
model strictly beats the old maximum-likelihood envelope:

`C_{S ∪ {p}} − C_S = ∑ₓ (p x − maxLik_S x)⁺`.

The proof is the observation that the Shtarkov sum is the `ℓ¹`-norm of a
pointwise supremum, so adjoining one function to the family replaces the
envelope `maxLik_S` by `max p maxLik_S`, and `max a b − b = (a − b)⁺`.

Consequences proved here:

* the marginal value is nonnegative, and *strictly* positive exactly when the
  new model beats the envelope somewhere (`shtarkovSum_addSource_lt_iff`);
* adding a model that is pointwise dominated by the envelope is free
  (`shtarkovSum_addSource_eq_iff`) — in particular adding any mixture of
  members of the class costs nothing (`shtarkovSum_addSource_convex_eq`);
* a crude but sharp bound `C' − C ≤ ‖p − maxLik‖₁` and the bit-level form
  of the increment.

## Main results

* `SourceClass.addSource` — the class enlarged by one source;
* `SourceClass.maxLik_addSource` — `maxLik' = max p maxLik`;
* `SourceClass.shtarkovSum_addSource` — the **marginal value formula**;
* `SourceClass.shtarkovSum_addSource_eq_iff`,
  `SourceClass.shtarkovSum_addSource_lt_iff` — the dichotomy;
* `SourceClass.price_addSource_lt_iff` — the same statement in bits;
* `SourceClass.shtarkovSum_addSource_convex_eq` — mixtures are free.

## Application keywords

universal compression, Shtarkov sum, normalized maximum likelihood,
marginal value of a model, model libraries, price of universality
-/

import NumberTheory.UniversalRedundancyDiversity

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} (S : SourceClass X Θ)

/-! ## Adjoining one source to a class -/

/-- The class `S` enlarged by one extra source `p`.  The new parameter set is
`Option Θ`: `none` selects the new model, `some θ` the old ones. -/
def addSource (p : X → ℝ) (hp0 : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1) :
    SourceClass X (Option Θ) where
  prob o x := o.elim (p x) fun θ => S.prob θ x
  nonneg := by rintro (_ | θ) x <;> simp [hp0, S.nonneg]
  sum_one := by rintro (_ | θ) <;> simp [hp1, S.sum_one]

variable {p : X → ℝ} {hp0 : ∀ x, 0 ≤ p x} {hp1 : ∑ x, p x = 1}

@[simp] lemma addSource_prob_none (x : X) :
    (S.addSource p hp0 hp1).prob none x = p x := rfl

@[simp] lemma addSource_prob_some (θ : Θ) (x : X) :
    (S.addSource p hp0 hp1).prob (some θ) x = S.prob θ x := rfl

/-- **The envelope of an enlarged class is the pointwise maximum.**  This is the
analytic content of the marginal value formula; it holds for an arbitrary
(possibly infinite) parameter set, where the supremum need not be attained. -/
theorem maxLik_addSource [Nonempty Θ] (x : X) :
    (S.addSource p hp0 hp1).maxLik x = max (p x) (S.maxLik x) := by
  refine le_antisymm ((S.addSource p hp0 hp1).maxLik_le ?_) (max_le ?_ ?_)
  · rintro (_ | θ)
    · exact le_max_left _ _
    · exact le_trans (S.le_maxLik θ x) (le_max_right _ _)
  · exact (S.addSource p hp0 hp1).le_maxLik none x
  · exact S.maxLik_le fun θ => (S.addSource p hp0 hp1).le_maxLik (some θ) x

/-- Elementary identity behind the increment formula: `max a b − b = (a − b)⁺`. -/
lemma max_sub_right (a b : ℝ) : max a b - b = max (a - b) 0 := by
  rcases le_total a b with h | h
  · rw [max_eq_right h, max_eq_right (by linarith), sub_self]
  · rw [max_eq_left h, max_eq_left (by linarith : (0:ℝ) ≤ a - b)]

/-! ## The marginal value formula -/

/-- **Marginal value of a model.**  Adjoining a source `p` to the class `S`
increases the Shtarkov sum by exactly the mass on which `p` strictly beats the
maximum-likelihood envelope of `S`:

`C' = C + ∑ₓ (p x − maxLik_S x)⁺`. -/
theorem shtarkovSum_addSource [Nonempty Θ] :
    (S.addSource p hp0 hp1).shtarkovSum
      = S.shtarkovSum + ∑ x, max (p x - S.maxLik x) 0 := by
  unfold shtarkovSum
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [S.maxLik_addSource x, ← max_sub_right (p x) (S.maxLik x)]
  ring

/-- The increment form: `C' − C = ∑ₓ (p x − maxLik_S x)⁺`. -/
theorem shtarkovSum_addSource_sub [Nonempty Θ] :
    (S.addSource p hp0 hp1).shtarkovSum - S.shtarkovSum
      = ∑ x, max (p x - S.maxLik x) 0 := by
  rw [S.shtarkovSum_addSource (hp0 := hp0) (hp1 := hp1)]; ring

/-- The marginal value of a model is never negative: enlarging a class can only
raise the price of universality. -/
theorem le_shtarkovSum_addSource [Nonempty Θ] :
    S.shtarkovSum ≤ (S.addSource p hp0 hp1).shtarkovSum := by
  rw [S.shtarkovSum_addSource (hp0 := hp0) (hp1 := hp1)]
  have : (0 : ℝ) ≤ ∑ x, max (p x - S.maxLik x) 0 :=
    Finset.sum_nonneg fun x _ => le_max_right _ _
  linarith

/-! ## The dichotomy: free models versus genuinely new models -/

/-- **A model is free exactly when it is dominated by the envelope.**  Adding
`p` leaves the price of universality unchanged iff `p ≤ maxLik_S` pointwise. -/
theorem shtarkovSum_addSource_eq_iff [Nonempty Θ] :
    (S.addSource p hp0 hp1).shtarkovSum = S.shtarkovSum ↔ ∀ x, p x ≤ S.maxLik x := by
  rw [← sub_eq_zero, S.shtarkovSum_addSource_sub (hp0 := hp0) (hp1 := hp1)]
  constructor
  · intro h x
    have hx := (Finset.sum_eq_zero_iff_of_nonneg
      (fun y (_ : y ∈ univ) => le_max_right (p y - S.maxLik y) (0:ℝ))).1 h x (Finset.mem_univ x)
    have : p x - S.maxLik x ≤ 0 := by
      have := le_max_left (p x - S.maxLik x) (0:ℝ)
      linarith [hx ▸ this]
    linarith
  · intro h
    refine Finset.sum_eq_zero fun x _ => ?_
    exact max_eq_right (by linarith [h x])

/-- **A genuinely new model strictly raises the price.**  The Shtarkov sum
increases iff the new source beats the old envelope on at least one message. -/
theorem shtarkovSum_addSource_lt_iff [Nonempty Θ] :
    S.shtarkovSum < (S.addSource p hp0 hp1).shtarkovSum ↔ ∃ x, S.maxLik x < p x := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    exact absurd ((S.shtarkovSum_addSource_eq_iff (hp0 := hp0) (hp1 := hp1)).2 hcon)
      (ne_of_gt h)
  · rintro ⟨x₀, hx₀⟩
    have hpos : 0 < ∑ x, max (p x - S.maxLik x) 0 := by
      refine Finset.sum_pos' (fun x _ => le_max_right _ _) ⟨x₀, Finset.mem_univ x₀, ?_⟩
      exact lt_of_lt_of_le (by linarith) (le_max_left (p x₀ - S.maxLik x₀) 0)
    have := S.shtarkovSum_addSource_sub (hp0 := hp0) (hp1 := hp1)
    linarith

/-- **The bit-level dichotomy.**  The price of universality of the enlarged
class strictly exceeds that of `S` precisely when the new model is not already
dominated by the maximum-likelihood envelope. -/
theorem price_addSource_lt_iff [Nonempty Θ] :
    logb 2 S.shtarkovSum < logb 2 (S.addSource p hp0 hp1).shtarkovSum
      ↔ ∃ x, S.maxLik x < p x := by
  rw [← S.shtarkovSum_addSource_lt_iff (hp0 := hp0) (hp1 := hp1)]
  constructor
  · intro h
    rcases lt_or_ge S.shtarkovSum (S.addSource p hp0 hp1).shtarkovSum with h' | h'
    · exact h'
    · exact absurd (Real.logb_le_logb_of_le (by norm_num)
        (S.addSource p hp0 hp1).shtarkovSum_pos h') (not_le_of_gt h)
  · intro h
    exact Real.logb_lt_logb (by norm_num) S.shtarkovSum_pos h

/-! ## Quantitative envelopes for the increment -/

/-- The marginal value never exceeds the `ℓ¹` distance from the envelope. -/
theorem shtarkovSum_addSource_sub_le_l1 [Nonempty Θ] :
    (S.addSource p hp0 hp1).shtarkovSum - S.shtarkovSum
      ≤ ∑ x, |p x - S.maxLik x| := by
  rw [S.shtarkovSum_addSource_sub (hp0 := hp0) (hp1 := hp1)]
  refine Finset.sum_le_sum fun x _ => ?_
  exact max_le (le_abs_self _) (abs_nonneg _)

/-- The marginal value of a model is at most `1`: a single model adds at most
one unit to the Shtarkov sum, since the positive part of `p − maxLik` is
dominated by `p`, whose total mass is `1`. -/
theorem shtarkovSum_addSource_sub_le_one [Nonempty Θ] :
    (S.addSource p hp0 hp1).shtarkovSum - S.shtarkovSum ≤ 1 := by
  rw [S.shtarkovSum_addSource_sub (hp0 := hp0) (hp1 := hp1), ← hp1]
  refine Finset.sum_le_sum fun x _ => max_le ?_ (hp0 x)
  linarith [S.maxLik_nonneg x]

/-- **Mixtures are free.**  A convex combination of members of the class is
pointwise dominated by the envelope, hence adjoining it costs nothing: the price
of universality only sees the *extreme points* of the model library. -/
theorem shtarkovSum_addSource_convex_eq [Nonempty Θ] [Fintype Θ]
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (hmix : ∀ x, p x = ∑ θ, w θ * S.prob θ x) :
    (S.addSource p hp0 hp1).shtarkovSum = S.shtarkovSum := by
  refine (S.shtarkovSum_addSource_eq_iff (hp0 := hp0) (hp1 := hp1)).2 fun x => ?_
  calc p x = ∑ θ, w θ * S.prob θ x := hmix x
    _ ≤ ∑ θ, w θ * S.maxLik x :=
        Finset.sum_le_sum fun θ _ =>
          mul_le_mul_of_nonneg_left (S.le_maxLik θ x) (hw0 θ)
    _ = S.maxLik x := by rw [← Finset.sum_mul, hw1, one_mul]

/-! ## Adjoining a whole class

Everything above works verbatim when the single new model `p` is replaced by an
entire new class `T`, with `p` replaced by the envelope `maxLik_T`.  This is the
form in which the increment formula applies to *libraries of classes* with
arbitrary — possibly infinite — parameter sets, where the suprema need not be
attained. -/

variable {Θ' : Type*}

/-- The union of two source classes: the parameter set is the disjoint sum. -/
def sumClass (T : SourceClass X Θ') : SourceClass X (Θ ⊕ Θ') where
  prob := Sum.elim S.prob T.prob
  nonneg := by rintro (θ | θ) x <;> simp [S.nonneg, T.nonneg]
  sum_one := by rintro (θ | θ) <;> simp [S.sum_one, T.sum_one]

/-- The envelope of a union of classes is the pointwise maximum of the
envelopes. -/
theorem maxLik_sumClass [Nonempty Θ] [Nonempty Θ'] (T : SourceClass X Θ') (x : X) :
    (S.sumClass T).maxLik x = max (S.maxLik x) (T.maxLik x) := by
  refine le_antisymm ((S.sumClass T).maxLik_le ?_) (max_le ?_ ?_)
  · rintro (θ | θ)
    · exact le_trans (S.le_maxLik θ x) (le_max_left _ _)
    · exact le_trans (T.le_maxLik θ x) (le_max_right _ _)
  · exact S.maxLik_le fun θ => (S.sumClass T).le_maxLik (Sum.inl θ) x
  · exact T.maxLik_le fun θ => (S.sumClass T).le_maxLik (Sum.inr θ) x

/-- **Marginal value of a whole class.**  Merging a class `T` into `S` raises
the Shtarkov sum by exactly the mass on which the envelope of `T` beats the
envelope of `S`. -/
theorem shtarkovSum_sumClass [Nonempty Θ] [Nonempty Θ'] (T : SourceClass X Θ') :
    (S.sumClass T).shtarkovSum
      = S.shtarkovSum + ∑ x, max (T.maxLik x - S.maxLik x) 0 := by
  unfold shtarkovSum
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [S.maxLik_sumClass T x, max_comm, ← max_sub_right (T.maxLik x) (S.maxLik x)]
  ring

/-- Merging `T` into `S` is free precisely when `S` already dominates `T`
everywhere. -/
theorem shtarkovSum_sumClass_eq_iff [Nonempty Θ] [Nonempty Θ'] (T : SourceClass X Θ') :
    (S.sumClass T).shtarkovSum = S.shtarkovSum ↔ ∀ x, T.maxLik x ≤ S.maxLik x := by
  rw [S.shtarkovSum_sumClass T, add_eq_left]
  constructor
  · intro h x
    have hx := (Finset.sum_eq_zero_iff_of_nonneg
      (fun y (_ : y ∈ univ) => le_max_right (T.maxLik y - S.maxLik y) (0:ℝ))).1 h x
      (Finset.mem_univ x)
    have := le_max_left (T.maxLik x - S.maxLik x) (0:ℝ)
    linarith [hx ▸ this]
  · intro h
    exact Finset.sum_eq_zero fun x _ => max_eq_right (by linarith [h x])

/-- **Diminishing returns for arbitrary classes.**  The marginal value of a new
class `T` shrinks when the incumbent envelope grows; together with
`shtarkovSum_sumClass` this is submodularity of the Shtarkov sum in full
generality, without any finiteness assumption on the parameter sets. -/
theorem marginal_antitone [Nonempty Θ] {Θ'' : Type*} [Nonempty Θ'']
    (S' : SourceClass X Θ'') (T : SourceClass X Θ')
    (hle : ∀ x, S.maxLik x ≤ S'.maxLik x) :
    ∑ x, max (T.maxLik x - S'.maxLik x) 0 ≤ ∑ x, max (T.maxLik x - S.maxLik x) 0 :=
  Finset.sum_le_sum fun x _ => max_le_max_right 0 (by linarith [hle x])

end SourceClass

end UniversalRedundancy