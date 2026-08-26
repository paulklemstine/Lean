/-
  # Recovering the mixture weight from a single head window

  `Probability.HarmonicBulkSteeperEdge` shows that the head mass of a bulk × edge kernel is
  a strict mediant of the two pure head masses, and
  `Probability.HarmonicBulkSteeperEdgeStrict` shows that the window-implied *exponent* is
  strictly antitone in the window width.  Both leave open how much of the mixture is
  recoverable from recorded statistics.  This file settles the weight coordinate.

  * `headSum_cross_pos` — the MLR cross-product `H_b(m) H_a(n) - H_a(m) H_b(n)` is strictly
    positive when `a < b`; this is the determinant driving everything below.
  * `mixHeadMass_strictMono_weight` — the head mass of the mixture is *strictly increasing*
    in the mixture weight `w` on `[0,1]`.
  * `mixHeadMass_injective_weight` — hence two weights giving the same head mass on one
    window are equal: the weight is identifiable from a single window.
  * `exists_unique_weight_of_headMass_between` — well-posedness of the inverse problem:
    every achievable value between the two pure head masses is attained by exactly one
    weight (continuity plus the intermediate value theorem plus strict monotonicity).

  Together with `mix_implied_exponent_mem_Ioo` this makes the recorded head statistics a
  genuine estimator: with the two component exponents fixed by the bulk and edge, a single
  window determines the mixture weight uniquely, and the strict window law then predicts
  every other window.  (The remaining coordinate — monotonicity in the edge exponent `b` —
  is *not* covered here: raising `b` steepens the edge kernel but simultaneously lowers the
  mass the edge component carries, so the two effects compete.  That is recorded as an open
  direction rather than claimed.)
-/
import Mathlib
import Probability.HarmonicBulkSteeperEdge

namespace HarmonicBulkSteeperEdge

/-- **The MLR determinant.**  For `a < b` the cross-product of head sums is strictly
positive; equivalently, the steeper kernel puts strictly more relative mass on the head. -/
lemma headSum_cross_pos {a b : ℝ} (hab : a < b) {m n : ℕ} (hm : 1 ≤ m) (hmn : m < n) :
    0 < headSum b m * headSum a n - headSum a m * headSum b n := by
  have han : 0 < headSum a n := headSum_pos (by omega)
  have hbn : 0 < headSum b n := headSum_pos (by omega)
  have hlt : headMass a n m < headMass b n m := headMass_lt_of_exponent_lt hab hm hmn
  rw [headMass, headMass, div_lt_div_iff₀ han hbn] at hlt
  linarith

/-- The mixture head sum is positive for every weight in `[0,1]`. -/
lemma mixHeadSum_pos_of_mem_Icc {w a b : ℝ} (hw0 : 0 ≤ w) (hw1 : w ≤ 1) {n : ℕ} (hn : 1 ≤ n) :
    0 < mixHeadSum w a b n := by
  have han : 0 < headSum a n := headSum_pos hn
  have hbn : 0 < headSum b n := headSum_pos hn
  rw [mixHeadSum_eq]
  rcases lt_or_eq_of_le hw1 with h | h
  · nlinarith
  · subst h; nlinarith

/-- **The head mass is strictly increasing in the mixture weight.**  Adding edge component
strictly increases the head-window mass. -/
theorem mixHeadMass_strictMono_weight {a b w₁ w₂ : ℝ} (hab : a < b) (hw₁ : 0 ≤ w₁)
    (hw : w₁ < w₂) (hw₂ : w₂ ≤ 1) {m n : ℕ} (hm : 1 ≤ m) (hmn : m < n) :
    mixHeadMass w₁ a b n m < mixHeadMass w₂ a b n m := by
  have hD₁ : 0 < mixHeadSum w₁ a b n :=
    mixHeadSum_pos_of_mem_Icc hw₁ (le_trans hw.le hw₂) (by omega)
  have hD₂ : 0 < mixHeadSum w₂ a b n :=
    mixHeadSum_pos_of_mem_Icc (le_trans hw₁ hw.le) hw₂ (by omega)
  have hcross := headSum_cross_pos hab hm hmn
  rw [mixHeadMass, mixHeadMass, div_lt_div_iff₀ hD₁ hD₂,
    mixHeadSum_eq, mixHeadSum_eq, mixHeadSum_eq, mixHeadSum_eq]
  nlinarith [mul_pos (by linarith : (0:ℝ) < w₂ - w₁) hcross]

/-- **Identifiability of the mixture weight from one window.** -/
theorem mixHeadMass_injective_weight {a b w₁ w₂ : ℝ} (hab : a < b) (hw₁ : w₁ ∈ Set.Icc (0:ℝ) 1)
    (hw₂ : w₂ ∈ Set.Icc (0:ℝ) 1) {m n : ℕ} (hm : 1 ≤ m) (hmn : m < n)
    (heq : mixHeadMass w₁ a b n m = mixHeadMass w₂ a b n m) : w₁ = w₂ := by
  obtain ⟨h₁0, h₁1⟩ := hw₁
  obtain ⟨h₂0, h₂1⟩ := hw₂
  rcases lt_trichotomy w₁ w₂ with h | h | h
  · exact absurd heq (ne_of_lt (mixHeadMass_strictMono_weight hab h₁0 h h₂1 hm hmn))
  · exact h
  · exact absurd heq.symm (ne_of_lt (mixHeadMass_strictMono_weight hab h₂0 h h₁1 hm hmn))

lemma mixHeadMass_zero (a b : ℝ) {m n : ℕ} :
    mixHeadMass 0 a b n m = headMass a n m := by
  rw [mixHeadMass, mixHeadSum_eq, mixHeadSum_eq, headMass]
  simp

lemma mixHeadMass_one (a b : ℝ) {m n : ℕ} :
    mixHeadMass 1 a b n m = headMass b n m := by
  rw [mixHeadMass, mixHeadSum_eq, mixHeadSum_eq, headMass]
  simp

lemma continuousOn_mixHeadMass (a b : ℝ) {m n : ℕ} (hn : 1 ≤ n) :
    ContinuousOn (fun w : ℝ => mixHeadMass w a b n m) (Set.Icc 0 1) := by
  have hfun : (fun w : ℝ => mixHeadMass w a b n m)
      = fun w : ℝ => ((1 - w) * headSum a m + w * headSum b m)
          / ((1 - w) * headSum a n + w * headSum b n) := by
    funext w
    rw [mixHeadMass, mixHeadSum_eq, mixHeadSum_eq]
  rw [hfun]
  apply ContinuousOn.div
  · fun_prop
  · fun_prop
  · intro w hw
    obtain ⟨hw0, hw1⟩ := hw
    have := mixHeadSum_pos_of_mem_Icc (w := w) (a := a) (b := b) hw0 hw1 hn
    rw [mixHeadSum_eq] at this
    exact ne_of_gt this

/-- **Well-posedness of the weight inversion.**  Every head mass between the two pure
values is realised by exactly one mixture weight in `[0,1]`. -/
theorem exists_unique_weight_of_headMass_between {a b v : ℝ} (hab : a < b) {m n : ℕ}
    (hm : 1 ≤ m) (hmn : m < n) (hv : v ∈ Set.Icc (headMass a n m) (headMass b n m)) :
    ∃! w : ℝ, w ∈ Set.Icc (0:ℝ) 1 ∧ mixHeadMass w a b n m = v := by
  have hn : 1 ≤ n := by omega
  have hcont := continuousOn_mixHeadMass (m := m) a b hn
  have hsub := intermediate_value_Icc (le_of_lt zero_lt_one) hcont
  rw [mixHeadMass_zero (m := m) (n := n) a b, mixHeadMass_one (m := m) (n := n) a b] at hsub
  obtain ⟨w, hwmem, hwval⟩ := hsub hv
  simp only at hwval
  refine ⟨w, ⟨hwmem, hwval⟩, ?_⟩
  rintro w' ⟨hw'mem, hw'val⟩
  exact mixHeadMass_injective_weight hab hw'mem hwmem hm hmn (hw'val.trans hwval.symm)

end HarmonicBulkSteeperEdge