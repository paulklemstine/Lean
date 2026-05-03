/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Tropical.GL3TropicalSatake.Basic

/-!
# GL₃ Tropical Satake Finite Determinacy

This file proves the main finite-determinacy theorem for the GL₃ tropical Satake
correspondence: functions on dominant coweights with bounded support are uniquely
determined by finitely many tropical Satake observables.

## Proof strategy

The key mechanism is the **determinant convolution** (`edgeMoment`), which
acts as a shift operator `f ↦ f(· - (1,1,1))` and perfectly reconstructs function
values. For each `(a,b,c) ∈ BoxDom(B)`, the edge moment at `(a+1,b+1,c+1)` equals
`f(a,b,c)`. Outside the box, the support condition forces vanishing.
-/

open Finset

/-! ### The core reconstruction lemma -/

/-- Equality of edge moments on the finite range implies pointwise equality
    within the box. -/
lemma pointwise_eq_of_edge_moments_eq {B : ℕ} {f g : ℕ → ℕ → ℕ → ℤ}
    (hedge : ∀ a b c : ℕ, (a, b, c) ∈ finiteEdgeMomentRange B →
      edgeMoment f a b c = edgeMoment g a b c)
    (a b c : ℕ) (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
    f a b c = g a b c := by
  have hmem : (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B :=
    shifted_mem_finiteEdgeMomentRange haB hab hbc
  have h := hedge (a + 1) (b + 1) (c + 1) hmem
  simp [edgeMoment_succ] at h
  exact h

/-! ### Main finite-determinacy theorems -/

/-- **GL₃ Tropical Satake Finite Determinacy (Separated Levi Form)**.

On a fixed dominant box, equality of rank-1 profiles, rank-2 profiles, and edge
moments on finite test sets forces equality of the underlying functions. -/
theorem gl3_tropical_satake_finite_determinacy_bounded_support'
    {B : ℕ}
    {f g : ℕ → ℕ → ℕ → ℤ}
    (hf : FiniteSupportWithin B f)
    (hg : FiniteSupportWithin B g)
    (_hL1 : ∀ a b c : ℕ, (a, b, c) ∈ finiteRank1Range B →
      rank1Profile f a b c = rank1Profile g a b c)
    (_hL2 : ∀ a b c : ℕ, (a, b, c) ∈ finiteRank2Range B →
      rank2Profile f a b c = rank2Profile g a b c)
    (hedge : ∀ a b c : ℕ, (a, b, c) ∈ finiteEdgeMomentRange B →
      edgeMoment f a b c = edgeMoment g a b c) :
    f = g := by
  funext a b c
  by_cases h : a ≤ B ∧ b ≤ a ∧ c ≤ b
  · exact pointwise_eq_of_edge_moments_eq hedge a b c h.1 h.2.1 h.2.2
  · push_neg at h
    have hf' : f a b c = 0 := hf a b c (by omega)
    have hg' : g a b c = 0 := hg a b c (by omega)
    rw [hf', hg']

/-- **GL₃ Tropical Satake Finite Determinacy (Combined Observable Form)**. -/
theorem gl3_tropical_satake_finite_determinacy_bounded_support
    {B : ℕ}
    {f g : ℕ → ℕ → ℕ → ℤ}
    (hf : FiniteSupportWithin B f)
    (hg : FiniteSupportWithin B g)
    (_hconv : ∀ t s : ℕ × ℕ × ℕ,
      t ∈ finiteRank1Range B →
      s ∈ finiteRank2Range B →
      tripleConvObservable f t s = tripleConvObservable g t s)
    (hedge : ∀ a b c : ℕ, (a, b, c) ∈ finiteEdgeMomentRange B →
      edgeMoment f a b c = edgeMoment g a b c) :
    f = g := by
  funext a b c
  by_cases h : a ≤ B ∧ b ≤ a ∧ c ≤ b
  · exact pointwise_eq_of_edge_moments_eq hedge a b c h.1 h.2.1 h.2.2
  · push_neg at h
    have hf' : f a b c = 0 := hf a b c (by omega)
    have hg' : g a b c = 0 := hg a b c (by omega)
    rw [hf', hg']

/-! ### The zero / vanishing version -/

/-- The zero function has finite support within any box. -/
lemma finiteSupportWithin_zero (B : ℕ) :
    FiniteSupportWithin B (fun _ _ _ => (0 : ℤ)) :=
  fun _ _ _ _ => rfl

/-- The edge moment of the zero function is zero. -/
@[simp]
lemma edgeMoment_zero (a b c : ℕ) :
    edgeMoment (fun _ _ _ => (0 : ℤ)) a b c = 0 := by
  unfold edgeMoment; split_ifs <;> rfl

/-- **GL₃ Tropical Satake Zero Detection**.

If all tropical Satake observables vanish on the finite test set for a
bounded-support function, then the function is identically zero. -/
theorem gl3_tropical_satake_zero_of_vanishing_finite_tests
    {B : ℕ}
    {h : ℕ → ℕ → ℕ → ℤ}
    (hh : FiniteSupportWithin B h)
    (_hconv : ∀ t s : ℕ × ℕ × ℕ,
      t ∈ finiteRank1Range B →
      s ∈ finiteRank2Range B →
      tripleConvObservable h t s = 0)
    (hedge : ∀ a b c : ℕ, (a, b, c) ∈ finiteEdgeMomentRange B →
      edgeMoment h a b c = 0) :
    h = fun _ _ _ => 0 := by
  funext a b c
  by_cases hbox : a ≤ B ∧ b ≤ a ∧ c ≤ b
  · have hmem := shifted_mem_finiteEdgeMomentRange hbox.1 hbox.2.1 hbox.2.2
    have := hedge (a + 1) (b + 1) (c + 1) hmem
    simp [edgeMoment_succ] at this
    exact this
  · push_neg at hbox
    exact hh a b c (by omega)

/-! ### Supporting structural lemmas -/

/-- The edge moment range specification: characterizes membership. -/
lemma finiteEdgeMomentRange_spec {B : ℕ} (a b c : ℕ) :
    (a, b, c) ∈ finiteEdgeMomentRange B ↔ 1 ≤ c ∧ c ≤ b ∧ b ≤ a ∧ a ≤ B + 1 := by
  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  omega

/-- The rank-1 range specification: characterizes membership. -/
lemma finiteRank1Range_spec {B : ℕ} (a b c : ℕ) :
    (a, b, c) ∈ finiteRank1Range B ↔ c ≤ b ∧ b ≤ a ∧ a ≤ B + 1 := by
  simp [finiteRank1Range, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  omega

/-- The rank-2 range specification: characterizes membership. -/
lemma finiteRank2Range_spec {B : ℕ} (a b c : ℕ) :
    (a, b, c) ∈ finiteRank2Range B ↔ c ≤ b ∧ b ≤ a ∧ a ≤ B + 1 := by
  simp [finiteRank2Range, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  omega

/-- Edge recursion from finite initial data: if two bounded-support functions
    agree on edge moments in the finite range, they agree on ALL edge moments. -/
lemma edge_recursion_from_finite_initial_data
    {B : ℕ} {f g : ℕ → ℕ → ℕ → ℤ}
    (hf : FiniteSupportWithin B f)
    (hg : FiniteSupportWithin B g)
    (hinit : ∀ a b c : ℕ, (a, b, c) ∈ finiteEdgeMomentRange B →
      edgeMoment f a b c = edgeMoment g a b c) :
    ∀ a b c : ℕ, edgeMoment f a b c = edgeMoment g a b c := by
  intro a b c
  simp only [edgeMoment]
  split_ifs with h
  · -- h : 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c
    -- Need f (a-1) (b-1) (c-1) = g (a-1) (b-1) (c-1)
    by_cases hbox : a - 1 ≤ B ∧ b - 1 ≤ a - 1 ∧ c - 1 ≤ b - 1
    · exact pointwise_eq_of_edge_moments_eq hinit _ _ _ hbox.1 hbox.2.1 hbox.2.2
    · push_neg at hbox
      have hf' : f (a - 1) (b - 1) (c - 1) = 0 := hf _ _ _ (by omega)
      have hg' : g (a - 1) (b - 1) (c - 1) = 0 := hg _ _ _ (by omega)
      rw [hf', hg']
  · rfl

/-- Bounded support implies nonzero values lie in the box. -/
lemma boxDomFinset_supports {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
    (hf : FiniteSupportWithin B f) {a b c : ℕ} (hne : f a b c ≠ 0) :
    (a, b, c) ∈ boxDomFinset B := by
  rw [mem_boxDomFinset]
  by_contra h
  push_neg at h
  exact hne (hf a b c (by omega))

/-- The number of edge moment tests is bounded by the box volume. -/
lemma finiteEdgeMomentRange_card_bound (B : ℕ) :
    (finiteEdgeMomentRange B).card ≤ (B + 2) * (B + 2) * (B + 2) := by
  calc (finiteEdgeMomentRange B).card
      ≤ (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).card :=
        Finset.card_filter_le _ _
    _ = _ := by simp [Finset.card_product, Finset.card_range]; ring