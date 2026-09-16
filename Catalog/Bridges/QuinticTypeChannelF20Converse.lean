/-
# The converse of the merged-coset law: when is a type channel dial-pinned?

`Bridges.QuinticTypeChannelF20` proved the **merged-coset law** in the direction that
evaluates the channel: if the dial `D` is uniform inside every fibre of the type `T`, then

  `H(D) - I(T ; D) = ∑_t P(t) · log₂ (|T⁻¹(t)| / c t)`,

`c t` being the common size of the dial classes inside the fibre of `t`, so that
`|T⁻¹(t)| / c t = k t` is the **number of cosets merged by the type value `t`**.

This file proves the converse half — the "barrier-4 converse" of the program.  The three
results are:

* `merge_count_le_fiber`, `merge_count_pos` — the structural inequalities `1 ≤ c t ≤ |T⁻¹(t)|`
  that make every term of the merge sum meaningful;
* `dial_gap_nonneg` — the loss is always non-negative (no type can beat its dial);
* `dial_pinned_iff_no_merging` — **the converse**: the channel attains the full dial
  `I(T ; D) = H(D)` *if and only if* no type value merges two cosets.  Loss is therefore not
  an accident of the group but exactly the failure of the type to separate the
  abelianization classes;
* `dial_loss_of_single_merged_type` — the one-merged-type formula `loss = P(t₀) · log₂ k`,
  the shape in which the law is read off in practice;
* `quintic_merging_type`, `quintic_not_dial_pinned`, `quintic_loss_is_structural` — the
  `F₂₀` instance: the unique merging type is `[1,4]`, it merges exactly the two order-4
  cosets, and the resulting loss `1/2` is forced by the converse rather than computed.
-/
import Bridges.QuinticTypeChannelF20

namespace QuinticF20

open Finset CyclicTypeChannel

set_option maxRecDepth 100000

section Converse

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]
variable {s : Finset α} {T : α → β} {D : α → γ} {c : β → ℕ}

/-- The uniformity hypothesis of the merged-coset law: inside the fibre of every type value
`t`, all the dial classes that occur have the same size `c t`. -/
def UniformDial (s : Finset α) (T : α → β) (D : α → γ) (c : β → ℕ) : Prop :=
  ∀ t ∈ s.image T, ∀ a ∈ ({x ∈ s | T x = t} : Finset α),
    #{x ∈ ({y ∈ s | T y = t} : Finset α) | D x = D a} = c t

/-- Each dial class inside a type fibre is at most the whole fibre. -/
theorem merge_count_le_fiber (h : UniformDial s T D c) {t : β} (ht : t ∈ s.image T) :
    c t ≤ #{x ∈ s | T x = t} := by
  obtain ⟨a₀, ha₀, rfl⟩ := mem_image.1 ht
  have hmem : a₀ ∈ ({x ∈ s | T x = T a₀} : Finset α) := by simp [ha₀]
  rw [← h _ ht a₀ hmem]
  exact card_filter_le _ _

/-- A dial class inside a nonempty type fibre is nonempty. -/
theorem merge_count_pos (h : UniformDial s T D c) {t : β} (ht : t ∈ s.image T) : 0 < c t := by
  obtain ⟨a₀, ha₀, rfl⟩ := mem_image.1 ht
  have hmem : a₀ ∈ ({x ∈ s | T x = T a₀} : Finset α) := by simp [ha₀]
  rw [← h _ ht a₀ hmem]
  exact card_pos.2 ⟨a₀, by simp [hmem]⟩

/-- Every term of the merge sum is non-negative: a type value can only merge cosets, never
create them. -/
theorem merge_term_nonneg (h : UniformDial s T D c) {t : β} (ht : t ∈ s.image T) :
    0 ≤ ((#{x ∈ s | T x = t} : ℝ) / s.card) *
      (Real.logb 2 (#{x ∈ s | T x = t} : ℝ) - Real.logb 2 (c t : ℝ)) := by
  have hcpos : (0 : ℝ) < (c t : ℝ) := by exact_mod_cast merge_count_pos h ht
  have hle : (c t : ℝ) ≤ (#{x ∈ s | T x = t} : ℝ) := by
    exact_mod_cast merge_count_le_fiber h ht
  have hlog : Real.logb 2 (c t : ℝ) ≤ Real.logb 2 (#{x ∈ s | T x = t} : ℝ) :=
    Real.logb_le_logb_of_le (by norm_num) hcpos hle
  have hp : (0 : ℝ) ≤ (#{x ∈ s | T x = t} : ℝ) / s.card := by positivity
  exact mul_nonneg hp (by linarith)

/-- **No type beats its dial.**  The merged-coset loss is always non-negative. -/
theorem dial_gap_nonneg (hs : s.Nonempty) (h : UniformDial s T D c) :
    0 ≤ uEnt s D - mutInfo s T D := by
  rw [dial_gap_eq_merge_entropy hs T D c h]
  exact Finset.sum_nonneg fun t ht => merge_term_nonneg h ht

/-- **THE CONVERSE OF THE ABELIANIZATION LAW.**  The splitting type transmits the *entire*
dial — `I(T ; D) = H(D)` — precisely when no type value merges two cosets, i.e. when every
type fibre lies inside a single dial class.  Every bit of loss is a merged coset, and every
merged coset is a bit of loss. -/
theorem dial_pinned_iff_no_merging (hs : s.Nonempty) (h : UniformDial s T D c) :
    mutInfo s T D = uEnt s D ↔ ∀ t ∈ s.image T, #{x ∈ s | T x = t} = c t := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hgap := dial_gap_eq_merge_entropy hs T D c h
  constructor
  · intro hpin t ht
    have hzero : ∑ t ∈ s.image T,
        ((#{x ∈ s | T x = t} : ℝ) / s.card) *
          (Real.logb 2 (#{x ∈ s | T x = t} : ℝ) - Real.logb 2 (c t : ℝ)) = 0 := by
      rw [← hgap, hpin]; ring
    have hterm := (Finset.sum_eq_zero_iff_of_nonneg
      (fun t ht => merge_term_nonneg h ht)).1 hzero t ht
    have hcpos : (0 : ℝ) < (c t : ℝ) := by exact_mod_cast merge_count_pos h ht
    have hfpos : (0 : ℝ) < (#{x ∈ s | T x = t} : ℝ) := by
      have : 0 < #{x ∈ s | T x = t} := by
        obtain ⟨a₀, ha₀, rfl⟩ := mem_image.1 ht
        exact card_pos.2 ⟨a₀, by simp [ha₀]⟩
      exact_mod_cast this
    have hne : (#{x ∈ s | T x = t} : ℝ) / s.card ≠ 0 := by positivity
    have hlogeq : Real.logb 2 (#{x ∈ s | T x = t} : ℝ) = Real.logb 2 (c t : ℝ) := by
      rcases mul_eq_zero.1 hterm with h0 | h0
      · exact absurd h0 hne
      · linarith
    by_contra hcon
    have hlt : (c t : ℝ) < (#{x ∈ s | T x = t} : ℝ) := by
      have hle : (c t : ℝ) ≤ (#{x ∈ s | T x = t} : ℝ) := by
        exact_mod_cast merge_count_le_fiber h ht
      rcases lt_or_eq_of_le hle with hlt | heq
      · exact hlt
      · exact absurd (by exact_mod_cast heq.symm) hcon
    have := Real.logb_lt_logb (b := 2) (by norm_num) hcpos hlt
    linarith
  · intro hno
    have hzero : ∑ t ∈ s.image T,
        ((#{x ∈ s | T x = t} : ℝ) / s.card) *
          (Real.logb 2 (#{x ∈ s | T x = t} : ℝ) - Real.logb 2 (c t : ℝ)) = 0 := by
      refine Finset.sum_eq_zero fun t ht => ?_
      rw [hno t ht]
      ring
    rw [hzero] at hgap
    linarith

/-- **The one-merged-type formula.**  If a single type value `t₀` merges cosets and all the
others are pinned to one coset each, the loss is exactly `P(t₀) · log₂ k`, `k` the number of
cosets merged by `t₀`. -/
theorem dial_loss_of_single_merged_type (hs : s.Nonempty) (h : UniformDial s T D c)
    {t₀ : β} (ht₀ : t₀ ∈ s.image T) {k : ℕ}
    (hk : (#{x ∈ s | T x = t₀} : ℝ) = k * c t₀)
    (hrest : ∀ t ∈ s.image T, t ≠ t₀ → #{x ∈ s | T x = t} = c t) :
    uEnt s D - mutInfo s T D
      = ((#{x ∈ s | T x = t₀} : ℝ) / s.card) * Real.logb 2 (k : ℝ) := by
  have hcpos : (0 : ℝ) < (c t₀ : ℝ) := by exact_mod_cast merge_count_pos h ht₀
  have hfpos : (0 : ℝ) < (#{x ∈ s | T x = t₀} : ℝ) := by
    have hpos : 0 < #{x ∈ s | T x = t₀} := by
      obtain ⟨a₀, ha₀, heq⟩ := mem_image.1 ht₀
      exact card_pos.2 ⟨a₀, by simp [ha₀, heq]⟩
    exact_mod_cast hpos
  have hkpos : (0 : ℝ) < (k : ℝ) := by nlinarith [hk, hfpos, hcpos]
  rw [dial_gap_eq_merge_entropy hs T D c h]
  rw [← Finset.sum_subset (Finset.singleton_subset_iff.2 ht₀) ?_]
  · rw [Finset.sum_singleton, hk, Real.logb_mul (ne_of_gt hkpos) (ne_of_gt hcpos)]
    ring
  · intro t ht hnot
    have hne : t ≠ t₀ := by simpa using hnot
    rw [hrest t ht hne]
    ring

end Converse

/-! ## The merge-pattern invariance theorem

The evaluation law and its converse together say that the single-prime channel sees only the
*merge pattern*: the list of pairs (density of a type, number of cosets it merges).  The
next theorem makes that a statement about two arbitrary channels — possibly on different
groups — and is the formal reason why a relabelling of cosets that preserves the pattern is
undetectable at the prime level. -/

section Invariance

variable {α α' β β' γ γ' : Type*} [DecidableEq β] [DecidableEq β'] [DecidableEq γ]
  [DecidableEq γ']

/-- **Merge-pattern invariance.**  Two type/dial channels with the same dial entropy whose
merge patterns correspond under a bijection of type values — same density, same number of
merged cosets — transmit exactly the same information.  Neither the ambient group nor which
cosets are merged plays any role. -/
theorem mutInfo_eq_of_merge_pattern_bij
    {s : Finset α} {s' : Finset α'} {T : α → β} {T' : α' → β'} {D : α → γ} {D' : α' → γ'}
    {c : β → ℕ} {c' : β' → ℕ} (hs : s.Nonempty) (hs' : s'.Nonempty)
    (h : UniformDial s T D c) (h' : UniformDial s' T' D' c')
    (hdial : uEnt s D = uEnt s' D') (σ : β → β')
    (hmaps : ∀ t ∈ s.image T, σ t ∈ s'.image T')
    (hinj : ∀ t₁ ∈ s.image T, ∀ t₂ ∈ s.image T, σ t₁ = σ t₂ → t₁ = t₂)
    (hsurj : ∀ t' ∈ s'.image T', ∃ t ∈ s.image T, σ t = t')
    (hP : ∀ t ∈ s.image T,
      (#{x ∈ s | T x = t} : ℝ) / s.card = (#{x ∈ s' | T' x = σ t} : ℝ) / s'.card)
    (hk : ∀ t ∈ s.image T,
      (#{x ∈ s | T x = t} : ℝ) / (c t : ℝ) = (#{x ∈ s' | T' x = σ t} : ℝ) / (c' (σ t) : ℝ)) :
    mutInfo s T D = mutInfo s' T' D' := by
  have hg := dial_gap_eq_merge_entropy hs T D c h
  have hg' := dial_gap_eq_merge_entropy hs' T' D' c' h'
  have hsum : ∑ t ∈ s.image T,
      ((#{x ∈ s | T x = t} : ℝ) / s.card) *
        (Real.logb 2 (#{x ∈ s | T x = t} : ℝ) - Real.logb 2 (c t : ℝ))
      = ∑ t' ∈ s'.image T',
      ((#{x ∈ s' | T' x = t'} : ℝ) / s'.card) *
        (Real.logb 2 (#{x ∈ s' | T' x = t'} : ℝ) - Real.logb 2 (c' t' : ℝ)) := by
    refine Finset.sum_bij (fun t _ => σ t) hmaps hinj ?_ ?_
    · intro t' ht'
      obtain ⟨t, ht, rfl⟩ := hsurj t' ht'
      exact ⟨t, ht, rfl⟩
    · intro t ht
      have hcpos : (0 : ℝ) < (c t : ℝ) := by exact_mod_cast merge_count_pos h ht
      have hc'pos : (0 : ℝ) < (c' (σ t) : ℝ) := by
        exact_mod_cast merge_count_pos h' (hmaps t ht)
      have hfpos : (0 : ℝ) < (#{x ∈ s | T x = t} : ℝ) := by
        obtain ⟨a₀, ha₀, heq⟩ := mem_image.1 ht
        have : 0 < #{x ∈ s | T x = t} := card_pos.2 ⟨a₀, by simp [ha₀, heq]⟩
        exact_mod_cast this
      have hf'pos : (0 : ℝ) < (#{x ∈ s' | T' x = σ t} : ℝ) := by
        obtain ⟨a₀, ha₀, heq⟩ := mem_image.1 (hmaps t ht)
        have : 0 < #{x ∈ s' | T' x = σ t} := card_pos.2 ⟨a₀, by simp [ha₀, heq]⟩
        exact_mod_cast this
      have h1 : Real.logb 2 (#{x ∈ s | T x = t} : ℝ) - Real.logb 2 (c t : ℝ)
          = Real.logb 2 ((#{x ∈ s | T x = t} : ℝ) / (c t : ℝ)) := by
        rw [Real.logb_div (ne_of_gt hfpos) (ne_of_gt hcpos)]
      have h2 : Real.logb 2 (#{x ∈ s' | T' x = σ t} : ℝ) - Real.logb 2 (c' (σ t) : ℝ)
          = Real.logb 2 ((#{x ∈ s' | T' x = σ t} : ℝ) / (c' (σ t) : ℝ)) := by
        rw [Real.logb_div (ne_of_gt hf'pos) (ne_of_gt hc'pos)]
      rw [h1, h2, hP t ht, hk t ht]
  linarith [hg, hg', hsum, hdial]

end Invariance

/-! ## The `F₂₀` instance: the loss is structural

The half bit lost by the quintic type channel is not a numerical coincidence: by the
converse it is forced by the single fact that the type `[1,4]` fails to separate the two
order-4 cosets `{2, 3}`. -/

/-- The type `[1,4]` is a *merging* type: its fibre (10 Frobenius classes) is strictly larger
than the dial class inside it (5 classes) — it merges exactly `k = 2` cosets. -/
theorem quintic_merging_type : #{x ∈ qFrob | qType x = 14} = 2 * qMergeSize 14 := by decide

/-- Every other quintic type is pinned to a single coset. -/
theorem quintic_other_types_pinned :
    ∀ t ∈ qFrob.image qType, t ≠ 14 → #{x ∈ qFrob | qType x = t} = qMergeSize t := by decide

/-- **The quintic channel is not dial-pinned**, and by the converse this is *equivalent* to
the existence of the merging type `[1,4]`. -/
theorem quintic_not_dial_pinned : mutInfo qFrob qType qDial ≠ uEnt qFrob qDial := by
  intro hpin
  have hall := (dial_pinned_iff_no_merging (c := qMergeSize) qFrob_nonempty
    qDial_uniform_in_type_fibers).1 hpin
  have h14 := hall 14 (by decide)
  rw [quintic_merging_type] at h14
  simp [qMergeSize] at h14

/-- **The half bit, structurally.**  Feeding the single merging type `[1,4]` with `k = 2`
into the one-merged-type formula reproduces the loss `1/2` of the law table without any
entropy computation: it is `P([1,4]) · log₂ 2 = (1/2) · 1`. -/
theorem quintic_loss_is_structural :
    uEnt qFrob qDial - mutInfo qFrob qType qDial = 1 / 2 := by
  have hk : (#{x ∈ qFrob | qType x = 14} : ℝ) = 2 * (qMergeSize 14 : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) quintic_merging_type
  rw [dial_loss_of_single_merged_type (c := qMergeSize) qFrob_nonempty
    qDial_uniform_in_type_fibers (t₀ := 14) (by decide) (k := 2) hk
    quintic_other_types_pinned, qType_fiber_14, qFrob_card]
  rw [show ((2 : ℕ) : ℝ) = 2 from by norm_num,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
  norm_num

end QuinticF20