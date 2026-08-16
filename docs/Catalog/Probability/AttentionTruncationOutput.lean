/-
# Why the accuracy knee is cheaper than the mass knee

`AttentionConcentration.lean` proves an assumption-free obstruction: at the
measured effective support `N_eff = 152.11`, retaining `98 %` of the attention
*mass* costs `k ≥ 146`, yet the measured accuracy knee is `k* = 64`.  The two
numbers are not contradictory, but they force a mechanism: the retained *accuracy*
must be robust to a mass deficit that is far from negligible.

This file supplies that mechanism at the level of the attention read-out.  A
truncated-and-renormalised attention row moves the layer's output by at most
`2(1-ρ)·B` where `ρ` is the retained mass and `B` bounds the value vectors, and a
prediction survives any perturbation smaller than half its logit margin.  Together
they give a retention threshold `ρ > 1 - m/(4·L·B)` for preserving the arg-max —
a threshold governed by the *logit margin* `m`, not by the `0.98` mass level.  So
the accuracy knee is allowed to sit strictly below the mass knee, exactly as
measured, and the gap is predicted to close as the margin shrinks.

Main results.

* `AttentionTruncation.norm_weighted_sum_le` : `‖∑_{i∈U} p i • v i‖ ≤ (∑_{i∈U} p i)·B`.
* `AttentionTruncation.truncOut_sub_attnOut_norm_le` : the top-`k` read-out error
  `‖trunc − full‖ ≤ 2(1-ρ)B`; the factor `2` is the sum of the renormalisation
  inflation `(1-ρ)B` and the dropped tail `(1-ρ)B`.
* `AttentionTruncation.argmax_stable` : an arg-max survives any score perturbation
  below half its margin.
* `AttentionTruncation.topk_preserves_prediction` : the composite — prediction is
  preserved whenever `4·L·(1-ρ)·B` is below the logit margin.
* `AttentionTruncation.retention_threshold` : the resulting sufficient retention
  level `ρ > 1 - m/(4LB)`, which for a healthy margin is far below `0.98`.
-/

import Mathlib
import Probability.AttentionConcentration

namespace AttentionTruncation

open Finset

variable {ι : Type*} {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]

/-- The exact attention read-out `∑ p i • v i`. -/
def attnOut (s : Finset ι) (p : ι → ℝ) (v : ι → V) : V := ∑ i ∈ s, p i • v i

/-- The top-`k` read-out: restrict the row to `T` and renormalise. -/
noncomputable def truncOut (T : Finset ι) (p : ι → ℝ) (v : ι → V) : V :=
  (∑ i ∈ T, p i)⁻¹ • ∑ i ∈ T, p i • v i

/-- A weighted sum of bounded vectors is bounded by (weight mass) × (value bound). -/
theorem norm_weighted_sum_le (U : Finset ι) (p : ι → ℝ) (v : ι → V) {B : ℝ}
    (hp : ∀ i ∈ U, 0 ≤ p i) (hB : ∀ i ∈ U, ‖v i‖ ≤ B) :
    ‖∑ i ∈ U, p i • v i‖ ≤ (∑ i ∈ U, p i) * B := by
  have h1 : ‖∑ i ∈ U, p i • v i‖ ≤ ∑ i ∈ U, ‖p i • v i‖ := norm_sum_le _ _
  have h2 : ∀ i ∈ U, ‖p i • v i‖ ≤ p i * B := by
    intro i hi
    rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hp i hi)]
    exact mul_le_mul_of_nonneg_left (hB i hi) (hp i hi)
  calc ‖∑ i ∈ U, p i • v i‖ ≤ ∑ i ∈ U, ‖p i • v i‖ := h1
    _ ≤ ∑ i ∈ U, p i * B := Finset.sum_le_sum h2
    _ = (∑ i ∈ U, p i) * B := by rw [Finset.sum_mul]

/-- **Read-out error of top-`k` truncation.**  Renormalised truncation to a set
`T` carrying mass `ρ` moves the attention output by at most `2(1-ρ)·B`, where `B`
bounds the value vectors.  Renormalisation contributes `(1-ρ)B` and the dropped
tail contributes `(1-ρ)B`. -/
theorem truncOut_sub_attnOut_norm_le (s T : Finset ι) (hT : T ⊆ s) (p : ι → ℝ)
    (v : ι → V) (hp : ∀ i ∈ s, 0 ≤ p i) (hsum : ∑ i ∈ s, p i = 1) {B : ℝ}
    (hB : ∀ i ∈ s, ‖v i‖ ≤ B) (hρ : 0 < ∑ i ∈ T, p i) :
    ‖truncOut T p v - attnOut s p v‖ ≤ 2 * (1 - ∑ i ∈ T, p i) * B := by
  classical
  set ρ : ℝ := ∑ i ∈ T, p i with hρdef
  have hsplit : ∑ i ∈ s \ T, p i + ρ = 1 := by
    rw [hρdef, Finset.sum_sdiff hT, hsum]
  have hrest : ∑ i ∈ s \ T, p i = 1 - ρ := by linarith
  have hρle : ρ ≤ 1 := by
    have : 0 ≤ ∑ i ∈ s \ T, p i :=
      Finset.sum_nonneg fun i hi => hp i (Finset.mem_sdiff.mp hi).1
    linarith
  -- the value bound is nonnegative
  have hBnn : 0 ≤ B := by
    have hne : T.Nonempty := by
      by_contra h
      rw [Finset.not_nonempty_iff_eq_empty] at h
      rw [hρdef, h, Finset.sum_empty] at hρ
      exact lt_irrefl _ hρ
    obtain ⟨i, hi⟩ := hne
    exact le_trans (norm_nonneg (v i)) (hB i (hT hi))
  -- decomposition of the exact output
  set ST : V := ∑ i ∈ T, p i • v i with hST
  set SR : V := ∑ i ∈ s \ T, p i • v i with hSR
  have hdecomp : attnOut s p v = SR + ST := by
    rw [attnOut, hST, hSR, Finset.sum_sdiff hT]
  have hSTbound : ‖ST‖ ≤ ρ * B :=
    norm_weighted_sum_le T p v (fun i hi => hp i (hT hi)) (fun i hi => hB i (hT hi))
  have hSRbound : ‖SR‖ ≤ (1 - ρ) * B := by
    have := norm_weighted_sum_le (s \ T) p v
      (fun i hi => hp i (Finset.mem_sdiff.mp hi).1)
      (fun i hi => hB i (Finset.mem_sdiff.mp hi).1)
    rwa [hrest] at this
  -- rewrite the difference
  have hkey : truncOut T p v - attnOut s p v = (ρ⁻¹ - 1) • ST - SR := by
    rw [truncOut, hdecomp, ← hρdef, ← hST, sub_smul, one_smul]
    abel
  rw [hkey]
  have h1 : ‖(ρ⁻¹ - 1) • ST - SR‖ ≤ ‖(ρ⁻¹ - 1) • ST‖ + ‖SR‖ := norm_sub_le _ _
  have hinv : ρ⁻¹ - 1 = (1 - ρ) / ρ := by field_simp
  have hnn : 0 ≤ ρ⁻¹ - 1 := by
    rw [hinv]
    have : 0 ≤ 1 - ρ := by linarith
    positivity
  have h2 : ‖(ρ⁻¹ - 1) • ST‖ = (ρ⁻¹ - 1) * ‖ST‖ := by
    rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg hnn]
  have h3 : (ρ⁻¹ - 1) * ‖ST‖ ≤ (ρ⁻¹ - 1) * (ρ * B) :=
    mul_le_mul_of_nonneg_left hSTbound hnn
  have h4 : (ρ⁻¹ - 1) * (ρ * B) = (1 - ρ) * B := by
    rw [hinv]
    field_simp
  linarith [h1, h2.le, h2.ge, h3, h4.le, h4.ge, hSRbound]

/-- **Arg-max stability.**  A prediction survives any score perturbation smaller
than half of its margin over the runner-up. -/
theorem argmax_stable {C : Type*} (f g : C → ℝ) (e : ℝ) (h : ∀ j, |g j - f j| ≤ e)
    (c : C) (hm : ∀ j, j ≠ c → f j + 2 * e < f c) :
    ∀ j, j ≠ c → g j < g c := by
  intro j hj
  have h1 := abs_le.mp (h j)
  have h2 := abs_le.mp (h c)
  have := hm j hj
  linarith [h1.2, h2.1]

/-- **Top-`k` truncation preserves the prediction.**  If the read-out map is
`L`-Lipschitz in the attention output and the exact logit margin at the predicted
class exceeds `4·L·(1-ρ)·B`, then the truncated model predicts the same class.
The requirement involves the retained mass only through `1-ρ`, scaled by the
margin — not through the `0.98` mass threshold. -/
theorem topk_preserves_prediction {C : Type*} (s T : Finset ι) (hT : T ⊆ s)
    (p : ι → ℝ) (v : ι → V) (hp : ∀ i ∈ s, 0 ≤ p i) (hsum : ∑ i ∈ s, p i = 1)
    {B : ℝ} (hB : ∀ i ∈ s, ‖v i‖ ≤ B) (hρ : 0 < ∑ i ∈ T, p i)
    (score : V → C → ℝ) {L : ℝ} (hL : 0 ≤ L)
    (hLip : ∀ y y' j, |score y j - score y' j| ≤ L * ‖y - y'‖)
    (c : C)
    (hmargin : ∀ j, j ≠ c →
      score (attnOut s p v) j + 4 * L * (1 - ∑ i ∈ T, p i) * B
        < score (attnOut s p v) c) :
    ∀ j, j ≠ c → score (truncOut T p v) j < score (truncOut T p v) c := by
  set ρ : ℝ := ∑ i ∈ T, p i with hρdef
  have hout := truncOut_sub_attnOut_norm_le s T hT p v hp hsum hB hρ
  refine argmax_stable (score (attnOut s p v)) (score (truncOut T p v))
    (L * (2 * (1 - ρ) * B)) ?_ c ?_
  · intro j
    refine le_trans (hLip _ _ j) ?_
    exact mul_le_mul_of_nonneg_left hout hL
  · intro j hj
    have := hmargin j hj
    have heq : 2 * (L * (2 * (1 - ρ) * B)) = 4 * L * (1 - ρ) * B := by ring
    linarith [heq.le, heq.ge]

/-- **The retention threshold for accuracy, in closed form.**  With logit margin
`m` and read-out constant `L·B`, keeping the prediction only requires retained
mass `ρ > 1 - m/(4LB)`.  For a healthy margin this is far below the `0.98` mass
level that `AttentionConcentration.card_ge_of_retained` charges `ρ²·N_eff`
positions for — which is why the measured accuracy knee `k* = 64` can, and does,
undercut the mass knee `≥ 146` at `N_eff = 152.11`. -/
theorem retention_threshold {C : Type*} (s T : Finset ι) (hT : T ⊆ s)
    (p : ι → ℝ) (v : ι → V) (hp : ∀ i ∈ s, 0 ≤ p i) (hsum : ∑ i ∈ s, p i = 1)
    {B : ℝ} (hB : ∀ i ∈ s, ‖v i‖ ≤ B) (hρ : 0 < ∑ i ∈ T, p i)
    (score : V → C → ℝ) {L m : ℝ} (hL : 0 < L) (hBpos : 0 < B)
    (hLip : ∀ y y' j, |score y j - score y' j| ≤ L * ‖y - y'‖)
    (c : C)
    (hmargin : ∀ j, j ≠ c → score (attnOut s p v) j + m ≤ score (attnOut s p v) c)
    (hthr : 1 - m / (4 * L * B) < ∑ i ∈ T, p i) :
    ∀ j, j ≠ c → score (truncOut T p v) j < score (truncOut T p v) c := by
  set ρ : ℝ := ∑ i ∈ T, p i with hρdef
  have h4LB : 0 < 4 * L * B := by positivity
  have hlt : 4 * L * (1 - ρ) * B < m := by
    have h := (sub_lt_iff_lt_add.mp hthr)
    have h' : 1 - ρ < m / (4 * L * B) := by linarith
    have := (mul_lt_mul_of_pos_left h' h4LB)
    rw [mul_div_cancel₀ _ h4LB.ne'] at this
    linarith [this]
  refine topk_preserves_prediction s T hT p v hp hsum hB hρ score hL.le hLip c ?_
  intro j hj
  have := hmargin j hj
  linarith [hlt]

end AttentionTruncation