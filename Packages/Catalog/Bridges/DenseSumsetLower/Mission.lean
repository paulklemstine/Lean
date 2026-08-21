/-
# The mission statement in `min {|A|, |B|}` form, with the optimal constant `1`

`Bridges.DenseSumsetLower.Optimal` proves that for every `0 < δ < 1` and `ε > 0` there are,
for all large `n`, `δ`-dense sets `S ⊆ [n]` containing no sumset `apF a d₁ K + apF b d₂ K`
of two arithmetic progressions of the *same* length `K ≥ (1 + ε) log n / log (1/δ)`.

This file packages that result in the shape in which the problem is usually stated, and
strengthens it in two directions which cost nothing beyond monotonicity of `apF`:

* the two progressions may have **different** lengths, only
  `min {|A|, |B|} ≥ (1 + ε) log n / log (1/δ)` being assumed
  (`DenseSumsetLower.eventually_avoiding_ap_sumsets_min`);
* `A` and `B` need not be progressions at all: it suffices that each of them **contains**
  an arithmetic progression of that length
  (`DenseSumsetLower.eventually_avoiding_ap_rich_sumsets`).  Since a `T`-term progression
  is the extremal structured example, this is the strongest form the present counting
  argument yields for unstructured `A, B`.

Finally `DenseSumsetLower.mission_threshold_min` records the two-sided statement: with the
lower bound `DenseSumsetLower.eventually_exists_sumset_sharp` the extremal constant for
progression-rich sumsets in `δ`-dense subsets of `[n]` is exactly `1`, i.e. the threshold is
`(1 + o(1)) log n / log (1/δ)` — an improvement of the constant `3` of
`Bridges.DeltaDenseSumsetAvoidance`.
-/
import Bridges.DenseSumsetLower.Optimal

namespace DenseSumsetLower

open Finset Pointwise Filter DeltaDense

/-! ## Progression-rich sets -/

/-- `HasAPOfLength A T` says that `A` contains a `T`-term arithmetic progression with
positive common difference. -/
def HasAPOfLength (A : Finset ℕ) (T : ℕ) : Prop := ∃ a d : ℕ, 0 < d ∧ apF a d T ⊆ A

lemma hasAPOfLength_apF {a d T : ℕ} (hd : 0 < d) : HasAPOfLength (apF a d T) T :=
  ⟨a, d, hd, Finset.Subset.refl _⟩

/-- Containing a long progression is stronger than containing a short one. -/
lemma HasAPOfLength.mono {A : Finset ℕ} {T T' : ℕ} (h : HasAPOfLength A T) (hT : T' ≤ T) :
    HasAPOfLength A T' := by
  obtain ⟨a, d, hd, hsub⟩ := h
  exact ⟨a, d, hd, (apF_mono a d hT).trans hsub⟩

/-- A set containing a `T`-term progression with positive difference has at least `T`
elements. -/
lemma card_ge_of_hasAPOfLength {A : Finset ℕ} {T : ℕ} (h : HasAPOfLength A T) : T ≤ A.card := by
  obtain ⟨a, d, hd, hsub⟩ := h
  calc T = (apF a d T).card := (card_apF a hd T).symm
    _ ≤ A.card := Finset.card_le_card hsub

/-! ## The avoidance theorem for progression-rich pairs -/

/-- **Avoidance of progression-rich sumsets at the optimal exponent.**  For `0 < δ < 1` and
`ε > 0`, for all large `n` there is a `δ`-dense `S ⊆ [n]` such that no sumset `A + B` is
contained in `S` as soon as *each* of `A` and `B` contains an arithmetic progression of
length `T ≥ (1 + ε) log n / log (1/δ)`.

This contains `DenseSumsetLower.eventually_avoiding_ap_sumsets_one` as the special case
`A = apF a d₁ T`, `B = apF b d₂ T`. -/
theorem eventually_avoiding_ap_rich_sumsets (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {ε : ℝ}
    (hε : 0 < ε) :
    ∀ᶠ n : ℕ in atTop, ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (A B : Finset ℕ) (T : ℕ), (1 + ε) * (Real.log n / Real.log (1 / δ)) ≤ T →
        HasAPOfLength A T → HasAPOfLength B T → ¬ (A + B ⊆ S) := by
  filter_upwards [eventually_avoiding_ap_sumsets_one δ h0 h1 hε] with n hn
  obtain ⟨S, hSsub, hSdense, hSno⟩ := hn
  refine ⟨S, hSsub, hSdense, ?_⟩
  rintro A B T hT ⟨a, d₁, hd₁, hA⟩ ⟨b, d₂, hd₂, hB⟩ hsub
  exact hSno a b d₁ d₂ T hd₁ hd₂ hT
    ((Finset.add_subset_add hA hB).trans hsub)

/-- **The mission statement for progressions, with unequal lengths.**  For `0 < δ < 1` and
`ε > 0`, for all large `n` some `δ`-dense `S ⊆ [n]` contains no sumset `A + B` of two
arithmetic progressions (of arbitrary, possibly different, lengths and common differences)
with `min {|A|, |B|} ≥ (1 + ε) log n / log (1/δ)`.

This is the mission statement with the constant `3` replaced by the optimal `1`. -/
theorem eventually_avoiding_ap_sumsets_min (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {ε : ℝ}
    (hε : 0 < ε) :
    ∀ᶠ n : ℕ in atTop, ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ a b d₁ d₂ K₁ K₂ : ℕ, 0 < d₁ → 0 < d₂ →
        (1 + ε) * (Real.log n / Real.log (1 / δ)) ≤
            min (apF a d₁ K₁).card (apF b d₂ K₂).card →
          ¬ (apF a d₁ K₁ + apF b d₂ K₂ ⊆ S) := by
  filter_upwards [eventually_avoiding_ap_rich_sumsets δ h0 h1 hε] with n hn
  obtain ⟨S, hSsub, hSdense, hSno⟩ := hn
  refine ⟨S, hSsub, hSdense, ?_⟩
  intro a b d₁ d₂ K₁ K₂ hd₁ hd₂ hmin
  rw [card_apF a hd₁, card_apF b hd₂] at hmin
  refine hSno _ _ (min K₁ K₂) ?_ ?_ ?_
  · simpa using hmin
  · exact (hasAPOfLength_apF (T := K₁) hd₁).mono (min_le_left _ _)
  · exact (hasAPOfLength_apF (T := K₂) hd₂).mono (min_le_right _ _)

/-! ## The two-sided threshold -/

/-- **The threshold is `(1 + o(1)) log n / log (1/δ)`, in `min {|A|,|B|}` form.**
Fix `0 < δ < 1`, `ε > 0` and `c > 0` with `c log (1/δ) < 1`.  Then for all large `n`:

* *(every dense set contains a sumset)* every `S ⊆ [n]` with `|S| ≥ δ n` contains `A + B`
  with `|A| = |B| = ⌊c log n⌋`, and `c` may be taken arbitrarily close to `1/log(1/δ)`;
* *(some dense set avoids all longer progression-rich sumsets)* some `S ⊆ [n]` with
  `|S| ≥ δ n` contains no `A + B` with `A` and `B` both containing an arithmetic
  progression of length `T ≥ (1 + ε) log n / log (1/δ)`; in particular no sumset of two
  arithmetic progressions with `min {|A|, |B|} ≥ (1 + ε) log n / log (1/δ)`. -/
theorem mission_threshold_min (δ c : ℝ) (h0 : 0 < δ) (h1 : δ < 1) (hc0 : 0 < c)
    (hc : c * Real.log (1 / δ) < 1) {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ n : ℕ in atTop,
      (∀ S : Finset ℕ, S ⊆ range n → δ * (n : ℝ) ≤ S.card →
        ∃ A B : Finset ℕ, A.card = ⌊c * Real.log n⌋₊ ∧ B.card = ⌊c * Real.log n⌋₊ ∧
          A + B ⊆ S) ∧
      (∃ S ⊆ range n, δ * n ≤ S.card ∧
        (∀ (A B : Finset ℕ) (T : ℕ), (1 + ε) * (Real.log n / Real.log (1 / δ)) ≤ T →
          HasAPOfLength A T → HasAPOfLength B T → ¬ (A + B ⊆ S)) ∧
        (∀ a b d₁ d₂ K₁ K₂ : ℕ, 0 < d₁ → 0 < d₂ →
          (1 + ε) * (Real.log n / Real.log (1 / δ)) ≤
              min (apF a d₁ K₁).card (apF b d₂ K₂).card →
            ¬ (apF a d₁ K₁ + apF b d₂ K₂ ⊆ S))) := by
  filter_upwards [eventually_exists_sumset_sharp h0 h1 hc0 hc,
    eventually_avoiding_ap_rich_sumsets δ h0 h1 hε] with n hlow hup
  refine ⟨hlow, ?_⟩
  obtain ⟨S, hSsub, hSdense, hSno⟩ := hup
  refine ⟨S, hSsub, hSdense, hSno, ?_⟩
  intro a b d₁ d₂ K₁ K₂ hd₁ hd₂ hmin
  rw [card_apF a hd₁, card_apF b hd₂] at hmin
  refine hSno _ _ (min K₁ K₂) (by simpa using hmin)
    ((hasAPOfLength_apF (T := K₁) hd₁).mono (min_le_left _ _))
    ((hasAPOfLength_apF (T := K₂) hd₂).mono (min_le_right _ _))

end DenseSumsetLower