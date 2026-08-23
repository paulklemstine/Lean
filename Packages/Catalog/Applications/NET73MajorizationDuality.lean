/-
# NET-73, cycle 3: knee dominance is exactly majorization, and mixtures are sandwiched

Cycles 1–2 refuted tokens-per-word as the mechanism and identified concentration
statistics as the controlling quantities.  This cycle asks: *how much* of a
domain does the knee curve `τ ↦ k*(τ)` remember, and what happens to a corpus
that mixes domains?

* `Catalog.NET73.kneeDominates_iff_majorizes` — **duality.**  One domain needs
  no more keys than another at *every* tolerance iff its capture curve dominates
  pointwise, i.e. iff its attention mass vector majorizes the other's.  So the
  knee curve is a faithful order-isomorphic shadow of the majorization order on
  attention profiles — the "relational structure" NET-73 points at is exactly a
  majorization order.
* `Catalog.NET73.knee_curve_determines_capture` — the knee curve determines the
  capture curve: two domains with the same knees at all tolerances have the same
  attention concentration (though possibly wildly different tokenizers).
* `Catalog.NET73.kneeAt_mix_sandwich` — **mixtures interleave.**  A corpus that
  mixes two domains with weights `λ, 1-λ` has a knee between the two component
  knees: `min ≤ k*_mix(τ) ≤ max`.  Consequence
  (`mixed_corpus_knee_between`): mixing a code-like domain (small knee) with a
  French-like domain (large knee) can never push the knee outside the observed
  range, so the NET-73 spread is not a mixing artefact.
-/
import Mathlib
import Applications.NET73KneeDecoupling

namespace Catalog.NET73

open AttentionProfile

/-! ## 1. Two orders on domains -/

/-- `P` needs no more keys than `Q`, at every admissible tolerance. -/
def KneeDominates (P Q : AttentionProfile) : Prop :=
  ∀ τ : ℚ, 0 < τ → τ < 1 → P.kneeAt τ ≤ Q.kneeAt τ

/-- `P`'s attention is at least as concentrated as `Q`'s: its top-`k` keys
capture at least as much mass, for every `k`.  For mass vectors of equal total
this is exactly the majorization order. -/
def CaptureMajorizes (P Q : AttentionProfile) : Prop := ∀ k, Q.cum k ≤ P.cum k

/-- Majorization implies knee dominance (the easy direction). -/
theorem kneeDominates_of_majorizes {P Q : AttentionProfile}
    (h : CaptureMajorizes P Q) : KneeDominates P Q :=
  fun _ _ hτ1 => AttentionProfile.kneeAt_mono_profile Q P hτ1 h

/-- Knee dominance implies majorization: if `P` ever captured strictly less at
some `k`, a tolerance placed in the gap would make `P` need more keys. -/
theorem majorizes_of_kneeDominates {P Q : AttentionProfile}
    (h : KneeDominates P Q) : CaptureMajorizes P Q := by
  intro k
  by_contra hlt
  push_neg at hlt
  have hP0 : 0 ≤ P.cum k := by
    have := P.cum_mono (Nat.zero_le k)
    rwa [P.cum_zero] at this
  have hQ1 : Q.cum k ≤ 1 := Q.cum_le_one k
  set τ := (P.cum k + Q.cum k) / 2 with hτdef
  have hτ0 : 0 < τ := by rw [hτdef]; linarith
  have hτ1 : τ < 1 := by rw [hτdef]; linarith
  have hPτ : P.cum k < τ := by rw [hτdef]; linarith
  have hτQ : τ ≤ Q.cum k := by rw [hτdef]; linarith
  have hQle : Q.kneeAt τ ≤ k := Q.kneeAt_le hτQ
  have hPgt : k < P.kneeAt τ := by
    by_contra hle
    push_neg at hle
    have hmono := P.cum_mono hle
    have hspec := P.kneeAt_spec hτ1
    linarith
  have hdom := h τ hτ0 hτ1
  omega

/-- **Duality.**  Knee dominance at every tolerance is *equivalent* to
majorization of the capture curves. -/
theorem kneeDominates_iff_majorizes {P Q : AttentionProfile} :
    KneeDominates P Q ↔ CaptureMajorizes P Q :=
  ⟨majorizes_of_kneeDominates, kneeDominates_of_majorizes⟩

/-- **The knee curve is a complete invariant of concentration.**  Two domains
whose knees agree at every tolerance have identical capture curves — even though
their tokenizer densities are unconstrained. -/
theorem knee_curve_determines_capture {P Q : AttentionProfile}
    (h : ∀ τ : ℚ, 0 < τ → τ < 1 → P.kneeAt τ = Q.kneeAt τ) : P.cum = Q.cum := by
  have h1 : CaptureMajorizes P Q :=
    majorizes_of_kneeDominates fun τ hτ0 hτ1 => le_of_eq (h τ hτ0 hτ1)
  have h2 : CaptureMajorizes Q P :=
    majorizes_of_kneeDominates fun τ hτ0 hτ1 => le_of_eq (h τ hτ0 hτ1).symm
  funext k
  exact le_antisymm (h2 k) (h1 k)

/-! ## 2. Mixed corpora -/

/-- A corpus mixing two domains with weights `lam` and `1 - lam`. -/
noncomputable def mixProfile (lam : ℚ) (h0 : 0 ≤ lam) (h1 : lam ≤ 1)
    (P Q : AttentionProfile) : AttentionProfile where
  tpw := lam * P.tpw + (1 - lam) * Q.tpw
  cum := fun k => lam * P.cum k + (1 - lam) * Q.cum k
  cum_zero := by simp [P.cum_zero, Q.cum_zero]
  cum_mono := by
    intro a b hab
    have hP := P.cum_mono hab
    have hQ := Q.cum_mono hab
    have : (0 : ℚ) ≤ 1 - lam := by linarith
    nlinarith
  cum_le_one := by
    intro k
    have hP := P.cum_le_one k
    have hQ := Q.cum_le_one k
    nlinarith
  approaches_one := by
    intro τ hτ
    obtain ⟨kP, hkP⟩ := P.approaches_one τ hτ
    obtain ⟨kQ, hkQ⟩ := Q.approaches_one τ hτ
    refine ⟨max kP kQ, ?_⟩
    have hP : τ ≤ P.cum (max kP kQ) := le_trans hkP (P.cum_mono (le_max_left _ _))
    have hQ : τ ≤ Q.cum (max kP kQ) := le_trans hkQ (Q.cum_mono (le_max_right _ _))
    nlinarith

@[simp] lemma mixProfile_cum (lam : ℚ) (h0 : 0 ≤ lam) (h1 : lam ≤ 1)
    (P Q : AttentionProfile) (k : ℕ) :
    (mixProfile lam h0 h1 P Q).cum k = lam * P.cum k + (1 - lam) * Q.cum k := rfl

/-- **Mixtures interleave.**  The knee of a mixed corpus lies between the knees
of its components: mixing can never create a domain that is harder (or easier)
than both of its ingredients. -/
theorem kneeAt_mix_sandwich {lam τ : ℚ} (h0 : 0 ≤ lam) (h1 : lam ≤ 1)
    (P Q : AttentionProfile) (hτ1 : τ < 1) :
    min (P.kneeAt τ) (Q.kneeAt τ) ≤ (mixProfile lam h0 h1 P Q).kneeAt τ ∧
      (mixProfile lam h0 h1 P Q).kneeAt τ ≤ max (P.kneeAt τ) (Q.kneeAt τ) := by
  constructor
  · by_contra hlt
    push_neg at hlt
    have hP : (mixProfile lam h0 h1 P Q).kneeAt τ < P.kneeAt τ :=
      lt_of_lt_of_le hlt (min_le_left _ _)
    have hQ : (mixProfile lam h0 h1 P Q).kneeAt τ < Q.kneeAt τ :=
      lt_of_lt_of_le hlt (min_le_right _ _)
    have hPc := P.lt_of_lt_kneeAt hP
    have hQc := Q.lt_of_lt_kneeAt hQ
    have hspec := (mixProfile lam h0 h1 P Q).kneeAt_spec hτ1
    rw [mixProfile_cum] at hspec
    have hA : lam * P.cum ((mixProfile lam h0 h1 P Q).kneeAt τ) ≤ lam * τ :=
      mul_le_mul_of_nonneg_left hPc.le h0
    rcases lt_or_ge lam 1 with hl | hl
    · have hB : (1 - lam) * Q.cum ((mixProfile lam h0 h1 P Q).kneeAt τ) < (1 - lam) * τ :=
        mul_lt_mul_of_pos_left hQc (by linarith)
      linarith
    · have hpos : (0 : ℚ) < lam := lt_of_lt_of_le zero_lt_one hl
      have hA' : lam * P.cum ((mixProfile lam h0 h1 P Q).kneeAt τ) < lam * τ :=
        mul_lt_mul_of_pos_left hPc hpos
      have h1l : (1 : ℚ) - lam = 0 := by linarith
      have hB : (1 - lam) * Q.cum ((mixProfile lam h0 h1 P Q).kneeAt τ) = 0 := by
        rw [h1l]; ring
      have hlamτ : lam * τ = τ := by
        have : lam = 1 := le_antisymm h1 hl
        rw [this]; ring
      linarith
  · refine (mixProfile lam h0 h1 P Q).kneeAt_le ?_
    rw [mixProfile_cum]
    have hP : τ ≤ P.cum (max (P.kneeAt τ) (Q.kneeAt τ)) :=
      le_trans (P.kneeAt_spec hτ1) (P.cum_mono (le_max_left _ _))
    have hQ : τ ≤ Q.cum (max (P.kneeAt τ) (Q.kneeAt τ)) :=
      le_trans (Q.kneeAt_spec hτ1) (Q.cum_mono (le_max_right _ _))
    nlinarith

/-- **The NET-73 spread is not a mixing artefact.**  Take a strongly
concentrated domain (knee `2`, code-like) and a weakly concentrated one
(knee `14`, French-like) at tolerance `3/4`; every mixture of them has a knee in
`[2, 14]`, so no blend of domains can leave the observed band. -/
theorem mixed_corpus_knee_between {lam : ℚ} (h0 : 0 ≤ lam) (h1 : lam ≤ 1)
    (P Q : AttentionProfile) (hP : P.kneeAt (3/4) = 2) (hQ : Q.kneeAt (3/4) = 14) :
    2 ≤ (mixProfile lam h0 h1 P Q).kneeAt (3/4) ∧
      (mixProfile lam h0 h1 P Q).kneeAt (3/4) ≤ 14 := by
  obtain ⟨hlo, hhi⟩ :=
    kneeAt_mix_sandwich h0 h1 P Q (τ := 3/4) (by norm_num)
  rw [hP, hQ] at hlo hhi
  constructor
  · simpa using hlo
  · simpa using hhi

/-- **Cycle-3 synthesis.**  The knee curve is exactly the majorization order in
disguise, it is a complete invariant of the capture curve, and it is stable
under mixing.  Nothing in this structure refers to the tokenizer. -/
theorem knee_order_is_majorization_order :
    (∀ P Q : AttentionProfile, KneeDominates P Q ↔ CaptureMajorizes P Q) ∧
    (∀ P Q : AttentionProfile,
        (∀ τ : ℚ, 0 < τ → τ < 1 → P.kneeAt τ = Q.kneeAt τ) → P.cum = Q.cum) ∧
    (∀ (lam τ : ℚ) (h0 : 0 ≤ lam) (h1 : lam ≤ 1) (P Q : AttentionProfile), τ < 1 →
        min (P.kneeAt τ) (Q.kneeAt τ) ≤ (mixProfile lam h0 h1 P Q).kneeAt τ ∧
          (mixProfile lam h0 h1 P Q).kneeAt τ ≤ max (P.kneeAt τ) (Q.kneeAt τ)) :=
  ⟨fun _ _ => kneeDominates_iff_majorizes,
    fun _ _ h => knee_curve_determines_capture h,
    fun _ _ h0 h1 P Q hτ1 => kneeAt_mix_sandwich h0 h1 P Q hτ1⟩

end Catalog.NET73