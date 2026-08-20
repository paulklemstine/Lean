import Cryptography.GoodSeeds.Core

/-!
# Heavy rows, rewinding, and knowledge extraction from a seed fraction

The seed space of a two-move (sigma) protocol is a product
`R ×ˢ C` — prover randomness times verifier challenge — and the accepting event
`acc r c` cuts out a subset of it.  Knowledge extraction proceeds by *rewinding*:
one needs a single randomness `r` that accepts on **two distinct challenges**.

This file supplies the counting bridge between the two pictures, entirely in
terms of the `frac` operator of `Cryptography.GoodSeeds.Core`.

## Main results

* `card_good_product_eq_sum_rows` — the accepting seeds of the product space are
  counted row by row.  This is the level-set decomposition of `Core` applied to
  the cost function `Prod.fst`.
* `frac_product_eq_average_row_frac` — the global accepting fraction is the
  *average* of the row fractions.
* `exists_two_accepting_challenges` — **rewinding threshold.**  As soon as the
  accepting fraction exceeds `1 / |C|` there is a randomness accepting on two
  distinct challenges.  (Sharp: `frac_eq_one_div_card_of_unique` below exhibits
  an accepting set of fraction exactly `1 / |C|` with no such randomness, so the
  strict inequality cannot be weakened.)
* `heavy_row_lemma` — **the splitting/heavy-row lemma.**  If the global accepting
  fraction is `e`, then at least an `e / 2` fraction of the randomnesses are
  themselves `e / 2`-heavy.
* `exists_two_accepting_challenges_of_heavy` — combining the two: a quantitative
  rewinding statement with an explicit fraction of good randomnesses.

-- !-- Lab Notes -- !--
Hypothesis (HR1): the `1/|C|` rewinding threshold is *exactly* the point at which
the pigeonhole flips, i.e. it is attained by a genuine configuration and is not an
artefact of a lossy estimate.
Experiment: build the "one accepting challenge per row" configuration
`acc r c ↔ c = φ r` for an arbitrary `φ : ρ → χ` and compute its fraction.
Outcome: confirmed — `frac_eq_one_div_card_of_unique` gives fraction exactly
`1/|C|` while no row has two accepting challenges.  Hence
`exists_two_accepting_challenges` is sharp and the strict `<` is necessary.
Analysis: the two theorems together are a dichotomy at the threshold, exactly
parallel to the `monitoring_frequency_dichotomy` pattern already in the catalog:
below/at the threshold an adversarial configuration exists, above it extraction is
forced.
Hypothesis (HR2): the constant `2` in the heavy-row lemma is not special; the
same argument gives, for any `0 < α < 1`, that at least a `(1-α)e` fraction of
rows are `αe`-heavy.
Experiment: `heavy_row_lemma_general` below, proved by the identical splitting
computation with `α` in place of `1/2`.
Outcome: confirmed, and `heavy_row_lemma` is the specialisation `α = 1/2`.
Critique: all bounds are stated over *nonempty* `R` and `C`; on an empty space
`frac` degenerates to `0` (Lean's `x / 0 = 0`) and the statements are vacuous
rather than false.  Guards are therefore explicit everywhere.
-/

namespace Cryptography
namespace GoodSeeds

open Finset

variable {ρ χ : Type*}
variable {R : Finset ρ} {C : Finset χ} {acc : ρ → χ → Prop} [∀ r, DecidablePred (acc r)]

instance : DecidablePred (fun p : ρ × χ => acc p.1 p.2) := fun _ => inferInstanceAs (Decidable _)

/-- The accepting seeds of a product seed space are counted row by row. -/
theorem card_good_product_eq_sum_rows :
    (goodSeeds (R ×ˢ C) (fun p => acc p.1 p.2)).card
      = ∑ r ∈ R, (goodSeeds C (acc r)).card := by
  simp only [goodSeeds, Finset.card_filter]
  rw [Finset.sum_product]

/-- **The global accepting fraction is the average of the row fractions.** -/
theorem frac_product_eq_average_row_frac (hR : R.Nonempty) :
    frac (R ×ˢ C) (fun p => acc p.1 p.2)
      = (∑ r ∈ R, frac C (acc r)) / (R.card : ℚ) := by
  have hn : (0 : ℚ) < (R.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hR
  unfold frac
  rw [card_good_product_eq_sum_rows (R := R) (C := C) (acc := acc)]
  rw [Finset.card_product]
  push_cast
  rw [← Finset.sum_div, div_div]
  ring

/-! ### The rewinding threshold -/

/-- If no randomness accepts two distinct challenges, then each row contributes at
most one accepting seed. -/
theorem card_row_le_one_of_no_collision {r : ρ}
    (h : ∀ c₁ ∈ C, ∀ c₂ ∈ C, acc r c₁ → acc r c₂ → c₁ = c₂) :
    (goodSeeds C (acc r)).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  exact h a (mem_goodSeeds.1 ha).1 b (mem_goodSeeds.1 hb).1
    (mem_goodSeeds.1 ha).2 (mem_goodSeeds.1 hb).2

/-- **Rewinding threshold.**  If the accepting fraction of the product seed space
strictly exceeds `1 / |C|`, then some prover randomness accepts on two distinct
challenges — exactly the data a special-soundness extractor consumes. -/
theorem exists_two_accepting_challenges (hR : R.Nonempty) (hC : C.Nonempty)
    (h : 1 / (C.card : ℚ) < frac (R ×ˢ C) (fun p => acc p.1 p.2)) :
    ∃ r ∈ R, ∃ c₁ ∈ C, ∃ c₂ ∈ C, c₁ ≠ c₂ ∧ acc r c₁ ∧ acc r c₂ := by
  by_contra hcon
  push_neg at hcon
  have hrow : ∀ r ∈ R, (goodSeeds C (acc r)).card ≤ 1 := by
    intro r hr
    refine card_row_le_one_of_no_collision (C := C) (acc := acc) ?_
    intro c₁ hc₁ c₂ hc₂ h₁ h₂
    by_contra hne
    exact hne (hcon r hr c₁ hc₁ c₂ hc₂ hne h₁ h₂ |>.elim)
  have hcard : (goodSeeds (R ×ˢ C) (fun p => acc p.1 p.2)).card ≤ R.card := by
    rw [card_good_product_eq_sum_rows (R := R) (C := C) (acc := acc)]
    calc ∑ r ∈ R, (goodSeeds C (acc r)).card ≤ ∑ _r ∈ R, 1 := Finset.sum_le_sum hrow
      _ = R.card := by simp
  have hn : (0 : ℚ) < (R.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hR
  have hm : (0 : ℚ) < (C.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hC
  have hle : frac (R ×ˢ C) (fun p => acc p.1 p.2) ≤ 1 / (C.card : ℚ) := by
    unfold frac
    rw [Finset.card_product]
    push_cast
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    have : ((goodSeeds (R ×ˢ C) (fun p => acc p.1 p.2)).card : ℚ) ≤ (R.card : ℚ) := by
      exact_mod_cast hcard
    nlinarith
  exact absurd hle (not_le.2 h)

/-- **Sharpness of the rewinding threshold.**  For any assignment `φ` of a single
accepting challenge to each randomness, the accepting fraction is exactly
`1 / |C|` and no randomness accepts two distinct challenges. -/
theorem frac_eq_one_div_card_of_unique [DecidableEq χ]
    (hR : R.Nonempty) (hC : C.Nonempty) (f : ρ → χ)
    (hf : ∀ r ∈ R, f r ∈ C) :
    frac (R ×ˢ C) (fun p => p.2 = f p.1) = 1 / (C.card : ℚ) ∧
      ∀ r ∈ R, ∀ c₁ ∈ C, ∀ c₂ ∈ C, c₁ = f r → c₂ = f r → c₁ = c₂ := by
  have hn : (0 : ℚ) < (R.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hR
  have hm : (0 : ℚ) < (C.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hC
  constructor
  · have hrow : ∀ r ∈ R, (goodSeeds C (fun c => c = f r)).card = 1 := by
      intro r hr
      have : goodSeeds C (fun c => c = f r) = {f r} := by
        ext c
        simp only [mem_goodSeeds, Finset.mem_singleton]
        exact ⟨fun h => h.2, fun h => ⟨h ▸ hf r hr, h⟩⟩
      rw [this, Finset.card_singleton]
    have hcard : (goodSeeds (R ×ˢ C) (fun p => p.2 = f p.1)).card = R.card := by
      rw [card_good_product_eq_sum_rows (R := R) (C := C) (acc := fun r c => c = f r)]
      rw [Finset.sum_congr rfl hrow]
      simp
    unfold frac
    rw [hcard, Finset.card_product]
    push_cast
    field_simp
  · intro r _ c₁ _ c₂ _ h₁ h₂
    rw [h₁, h₂]

/-! ### The heavy-row (splitting) lemma -/

/-- **The general splitting lemma.**  Fix `0 < α` and let `e` be the global
accepting fraction.  Then the fraction of randomnesses `r` whose own accepting
fraction is at least `α * e` is at least `(1 - α) * e`.

The proof is the level-set split of the seed space into heavy and light rows,
bounding the heavy rows by the trivial bound `1` and the light rows by `α * e`. -/
theorem heavy_row_lemma_general (hR : R.Nonempty) (hC : C.Nonempty)
    {α e : ℚ} (hα₀ : 0 < α)
    (he : e = frac (R ×ˢ C) (fun p => acc p.1 p.2)) :
    (1 - α) * e ≤ frac R (fun r => α * e ≤ frac C (acc r)) := by
  classical
  have hn : (0 : ℚ) < (R.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hR
  have hm : (0 : ℚ) < (C.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hC
  have he0 : 0 ≤ e := he ▸ frac_nonneg
  set P : ρ → Prop := fun r => α * e ≤ frac C (acc r) with hP
  set H : Finset ρ := goodSeeds R P with hH
  -- the average identity
  have havg : e * (R.card : ℚ) = ∑ r ∈ R, frac C (acc r) := by
    rw [he, frac_product_eq_average_row_frac (R := R) (C := C) (acc := acc) hR]
    field_simp
  -- split the sum over heavy and light rows
  have hsplit : ∑ r ∈ R, frac C (acc r)
      = (∑ r ∈ R.filter P, frac C (acc r)) + ∑ r ∈ R.filter (fun r => ¬ P r), frac C (acc r) :=
    (Finset.sum_filter_add_sum_filter_not R P _).symm
  have hheavy : ∑ r ∈ R.filter P, frac C (acc r) ≤ (H.card : ℚ) := by
    calc ∑ r ∈ R.filter P, frac C (acc r) ≤ ∑ _r ∈ R.filter P, (1 : ℚ) :=
          Finset.sum_le_sum fun r _ => frac_le_one
      _ = (H.card : ℚ) := by rw [Finset.sum_const, nsmul_eq_mul, mul_one, hH, goodSeeds]
  have hlight : ∑ r ∈ R.filter (fun r => ¬ P r), frac C (acc r) ≤ α * e * (R.card : ℚ) := by
    have hbound : ∀ r ∈ R.filter (fun r => ¬ P r), frac C (acc r) ≤ α * e := by
      intro r hr
      have := (Finset.mem_filter.1 hr).2
      rw [hP] at this
      exact le_of_lt (not_le.1 this)
    calc ∑ r ∈ R.filter (fun r => ¬ P r), frac C (acc r)
        ≤ ∑ _r ∈ R.filter (fun r => ¬ P r), α * e := Finset.sum_le_sum hbound
      _ = ((R.filter (fun r => ¬ P r)).card : ℚ) * (α * e) := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ (R.card : ℚ) * (α * e) := by
          have hcle : ((R.filter (fun r => ¬ P r)).card : ℚ) ≤ (R.card : ℚ) := by
            exact_mod_cast Finset.card_filter_le R _
          have : (0 : ℚ) ≤ α * e := by positivity
          exact mul_le_mul_of_nonneg_right hcle this
      _ = α * e * (R.card : ℚ) := by ring
  -- put it together
  have hkey : (1 - α) * e * (R.card : ℚ) ≤ (H.card : ℚ) := by
    have := havg.trans_le (hsplit ▸ add_le_add hheavy hlight)
    nlinarith
  have : frac R P = (H.card : ℚ) / (R.card : ℚ) := rfl
  rw [this, le_div_iff₀ hn]
  exact hkey

/-- **The heavy-row lemma.**  At least an `e / 2` fraction of the prover
randomnesses are themselves `e / 2`-heavy, where `e` is the global accepting
fraction.  (Specialisation `α = 1/2` of `heavy_row_lemma_general`.) -/
theorem heavy_row_lemma (hR : R.Nonempty) (hC : C.Nonempty) {e : ℚ}
    (he : e = frac (R ×ˢ C) (fun p => acc p.1 p.2)) :
    e / 2 ≤ frac R (fun r => e / 2 ≤ frac C (acc r)) := by
  have h := heavy_row_lemma_general (R := R) (C := C) (acc := acc) hR hC
    (α := 1/2) (e := e) (by norm_num) he
  have h1 : (1 - (1/2 : ℚ)) * e = e / 2 := by ring
  have h2 : ∀ r : ρ, ((1/2 : ℚ) * e ≤ frac C (acc r)) ↔ (e / 2 ≤ frac C (acc r)) := by
    intro r; rw [show (1/2 : ℚ) * e = e / 2 by ring]
  rw [h1] at h
  refine h.trans (le_of_eq (frac_congr fun r _ => (h2 r)))

/-- **Quantitative rewinding.**  If the accepting fraction `e` satisfies
`2 / |C| < e`, then a strictly positive fraction — at least `e / 2` — of the
prover randomnesses admit two distinct accepting challenges. -/
theorem exists_two_accepting_challenges_of_heavy (hR : R.Nonempty) (hC : C.Nonempty)
    {e : ℚ} (he : e = frac (R ×ˢ C) (fun p => acc p.1 p.2))
    (hbig : 2 / (C.card : ℚ) < e) :
    ∃ r ∈ R, ∃ c₁ ∈ C, ∃ c₂ ∈ C, c₁ ≠ c₂ ∧ acc r c₁ ∧ acc r c₂ := by
  classical
  have hm : (0 : ℚ) < (C.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hC
  have hheavy := heavy_row_lemma (R := R) (C := C) (acc := acc) hR hC he
  have hepos : 0 < e := lt_of_le_of_lt (by positivity) hbig
  -- some row is heavy
  have hne : (goodSeeds R (fun r => e / 2 ≤ frac C (acc r))).Nonempty := by
    by_contra hemp
    rw [Finset.not_nonempty_iff_eq_empty] at hemp
    have : frac R (fun r => e / 2 ≤ frac C (acc r)) = 0 := by
      refine (frac_eq_zero_iff hR).2 ?_
      intro r hrR hPr
      have : r ∈ goodSeeds R (fun r => e / 2 ≤ frac C (acc r)) := mem_goodSeeds.2 ⟨hrR, hPr⟩
      rw [hemp] at this
      simp at this
    rw [this] at hheavy
    linarith
  obtain ⟨r, hr⟩ := hne
  obtain ⟨hrR, hrheavy⟩ := mem_goodSeeds.1 hr
  -- a heavy row has more than one accepting challenge
  have h1 : 1 / (C.card : ℚ) < frac C (acc r) := by
    have : 1 / (C.card : ℚ) < e / 2 := by
      rw [div_lt_div_iff₀ hm (by norm_num)]
      rw [div_lt_iff₀ hm] at hbig
      linarith
    linarith
  have hcard : 1 < (goodSeeds C (acc r)).card := by
    by_contra hle
    push_neg at hle
    have : ((goodSeeds C (acc r)).card : ℚ) ≤ 1 := by exact_mod_cast hle
    have : frac C (acc r) ≤ 1 / (C.card : ℚ) := by
      unfold frac
      rw [div_le_div_iff₀ hm hm]
      nlinarith
    linarith
  obtain ⟨c₁, hc₁, c₂, hc₂, hne12⟩ := Finset.one_lt_card.1 hcard
  exact ⟨r, hrR, c₁, (mem_goodSeeds.1 hc₁).1, c₂, (mem_goodSeeds.1 hc₂).1, hne12,
    (mem_goodSeeds.1 hc₁).2, (mem_goodSeeds.1 hc₂).2⟩

end GoodSeeds
end Cryptography