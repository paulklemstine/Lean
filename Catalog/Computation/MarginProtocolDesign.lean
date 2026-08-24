/-
# E3, cycle three: why the margin channel has that form, and how to run the test

Cycles one and two established the E3 band and its measurement-theoretic limits.
Two objections remain, and this file answers both, then turns the answer into a
protocol.

* **§1 "You assumed the margin-channel formula."**  Not really: the formula is
  forced.  A knee law `K(d, m)` that (i) is inversely homogeneous in the margin —
  scaling the margin by `c` scales the required budget by `1/c`, the only
  dimensionally consistent behaviour for a threshold criterion — and (ii) has a
  linear depth leg, must be `K(d, m) = d·K(1,1)/m`
  (`margin_channel_form_forced`).  With the one calibration `K(1,1) = 4·L·B·A·ctx`
  this *is* `MarginDepthRigidity.kneeOfMargin`
  (`margin_channel_is_kneeOfMargin`).  No functional freedom is left, so the E3
  prediction is not an artefact of a chosen parametrisation.

* **§2 "You assumed the tail exponent."**  Also forced, quantitatively.  Under a
  scale-free tail `A·ctx/k^β` the knee ratio between depths `4` and `16` is
  `4^(1/β)`.  A measured ratio within `±η` of the value `4` pins the exponent:
  `|1/β - 1| ≤ log(1/(1-η))/log 4` (`tail_exponent_from_knee_ratio`), exactly
  `β = 1` at `η = 0` (`tail_exponent_one_of_exact`), and `β ≠ 2` for any
  `η < 1/2` (`tail_exponent_ne_two`).  This is the quantitative form of
  `AttentionCostLaw.zipf_profile_forced`, whose hypothesis was an exact
  depth-linear knee at every depth.

* **§3 The protocol.**  The E3 measurement is a median over seeds, and the
  breakdown theory says how many seeds it needs: with `n` runs per depth and at
  most `k` of them corrupted, the reported median is certified exactly when
  `2k < n` (`seeds_certify_band`).  Two seeds per depth — the configuration the
  thread currently has — is *not* enough: a single crashed run can install any
  value whatsoever as the reported median (`two_seeds_break_on_one_bad_run`),
  while three seeds tolerate one (`three_seeds_tolerate_one_bad_run`).

* **§4 The bridge to E1.**  A margin measured at one cell fixes the tail
  amplitude, `A = m/(128·L·B)` (`amplitude_from_margin`), and hence the whole
  deficit window `[m/(8·L·B), m/(4·L·B)]` at every depth and context
  (`deficit_window_from_measured_margin`).  E1 and E3 really do share the single
  forward pass: E1 reads the constant off it, E3 reads the depth scaling.
-/

import Mathlib
import Computation.MarginDepthRigidity

namespace MarginProtocolDesign

open AttentionCostLaw AttentionMarginLaw MarginDepthInvariance MarginDepthRigidity

/-!
## 1.  The margin-channel form is forced
-/

/-- **Rigidity of the margin channel.**  Let `K(d, m)` be the budget a truncation
criterion demands at depth `d` for a model of held-out margin `m`.  Assume

* *inverse homogeneity in the margin*: `K(d, c·m) = K(d, m)/c` for `c > 0` — a
  model whose logits are `c` times better tolerates `c` times more truncation;
* *a linear depth leg*: `K(d, m) = d·K(1, m)` — the content of
  `AttentionCostLaw.layerComp_dist_le`.

Then `K(d, m) = d·K(1,1)/m`: the entire functional form is determined, and only
the single number `K(1,1)` is empirical. -/
theorem margin_channel_form_forced (K : ℕ → ℝ → ℝ)
    (hscale : ∀ (d : ℕ) (m c : ℝ), 0 < d → 0 < m → 0 < c → K d (c * m) = K d m / c)
    (hdepth : ∀ (d : ℕ) (m : ℝ), 0 < d → 0 < m → K d m = d * K 1 m) :
    ∀ (d : ℕ) (m : ℝ), 0 < d → 0 < m → K d m = d * K 1 1 / m := by
  intro d m hd hm
  have h1 : K 1 (m * 1) = K 1 1 / m := hscale 1 1 m one_pos one_pos hm
  rw [mul_one] at h1
  rw [hdepth d m hd hm, h1]
  ring

/-- With the single calibration `K(1,1) = 4·L·B·A·ctx`, the forced form is
exactly the knee used throughout the thread. -/
theorem margin_channel_is_kneeOfMargin (K : ℕ → ℝ → ℝ) {L B A ctx : ℝ}
    (hscale : ∀ (d : ℕ) (m c : ℝ), 0 < d → 0 < m → 0 < c → K d (c * m) = K d m / c)
    (hdepth : ∀ (d : ℕ) (m : ℝ), 0 < d → 0 < m → K d m = d * K 1 m)
    (hcal : K 1 1 = 4 * L * B * A * ctx) :
    ∀ (d : ℕ) (m : ℝ), 0 < d → 0 < m → K d m = kneeOfMargin L B A ctx d m := by
  intro d m hd hm
  rw [margin_channel_form_forced K hscale hdepth d m hd hm, hcal]
  unfold kneeOfMargin
  ring

/-!
## 2.  The tail exponent is forced, quantitatively
-/

/-- **Exponent rigidity from the knee ratio.**  Under a scale-free tail
`A·ctx/k^β` the least sufficient budget scales like `(A·d·ctx/δ)^(1/β)`, so the
knee ratio between depths `4` and `16` is `4^(1/β)`.  If that ratio is measured
within a relative tolerance `η < 1` of the value `4` predicted by the depth-linear
law, then `|1/β - 1| ≤ log(1/(1-η))/log 4`.  (Positivity of `β` is not needed:
the hypotheses already exclude the degenerate values.) -/
theorem tail_exponent_from_knee_ratio {β η : ℝ} (hη : 0 ≤ η) (hη1 : η < 1)
    (hlo : (1 - η) * 4 ≤ (4 : ℝ) ^ (1 / β))
    (hhi : (4 : ℝ) ^ (1 / β) ≤ (1 + η) * 4) :
    |1 / β - 1| ≤ Real.log (1 / (1 - η)) / Real.log 4 := by
  have hlog4 : 0 < Real.log 4 := Real.log_pos (by norm_num)
  have hpos2 : (0 : ℝ) < 1 - η := by linarith
  have hrp : (0 : ℝ) < (4 : ℝ) ^ (1 / β) := Real.rpow_pos_of_pos (by norm_num) _
  have hlogeq : Real.log ((4 : ℝ) ^ (1 / β)) = (1 / β) * Real.log 4 :=
    Real.log_rpow (by norm_num) _
  have hupper : (1 / β) * Real.log 4 ≤ Real.log ((1 + η) * 4) := by
    rw [← hlogeq]; exact Real.log_le_log hrp hhi
  have hlower : Real.log ((1 - η) * 4) ≤ (1 / β) * Real.log 4 := by
    rw [← hlogeq]; exact Real.log_le_log (by positivity) hlo
  have hsplitPlus : Real.log ((1 + η) * 4) = Real.log (1 + η) + Real.log 4 :=
    Real.log_mul (by positivity) (by norm_num)
  have hsplitMinus : Real.log ((1 - η) * 4) = Real.log (1 - η) + Real.log 4 :=
    Real.log_mul (by positivity) (by norm_num)
  have hinv : Real.log (1 / (1 - η)) = -Real.log (1 - η) := by
    rw [one_div, Real.log_inv]
  -- `log (1+η) ≤ -log (1-η)` because `(1+η)(1-η) ≤ 1`
  have hcross : Real.log (1 + η) ≤ -Real.log (1 - η) := by
    have hmul : Real.log ((1 + η) * (1 - η)) ≤ Real.log 1 :=
      Real.log_le_log (by positivity) (by nlinarith)
    rw [Real.log_mul (by positivity) (by positivity), Real.log_one] at hmul
    linarith
  have hbound : |((1 / β) - 1) * Real.log 4| ≤ Real.log (1 / (1 - η)) := by
    rw [abs_le, hinv]
    constructor
    · nlinarith [hlower, hsplitMinus.le, hsplitMinus.ge]
    · nlinarith [hupper, hsplitPlus.le, hsplitPlus.ge, hcross]
  have heq : |((1 / β) - 1) * Real.log 4| = |1 / β - 1| * Real.log 4 := by
    rw [abs_mul, abs_of_pos hlog4]
  rw [heq] at hbound
  rw [le_div_iff₀ hlog4]
  exact hbound

/-- **Exact case: the Zipf exponent.**  A knee ratio measured at exactly `4`
forces `β = 1`, the scale-free profile of `AttentionCostLaw.zipfTail`. -/
theorem tail_exponent_one_of_exact {β : ℝ} (hβ : 0 < β)
    (h : (4 : ℝ) ^ (1 / β) = 4) : β = 1 := by
  have hlog4 : 0 < Real.log 4 := Real.log_pos (by norm_num)
  have hlogeq : Real.log ((4 : ℝ) ^ (1 / β)) = (1 / β) * Real.log 4 :=
    Real.log_rpow (by norm_num) _
  rw [h] at hlogeq
  have h1 : (1 / β) * Real.log 4 = Real.log 4 := hlogeq.symm
  have hβ1 : 1 / β = 1 := by
    have := mul_right_cancel₀ hlog4.ne' (by linarith [h1] :
      (1 / β) * Real.log 4 = 1 * Real.log 4)
    exact this
  field_simp at hβ1
  linarith

/-- **A quadratic tail is excluded.**  If the knee ratio is measured within `±η`
of `4` for any `η < 1/2`, the tail exponent cannot be `2`: a `1/k²` attention
tail would have produced a knee ratio of `2`, not `4`. -/
theorem tail_exponent_ne_two {β η : ℝ} (hη : 0 ≤ η) (hη2 : η < 1 / 2)
    (hlo : (1 - η) * 4 ≤ (4 : ℝ) ^ (1 / β))
    (hhi : (4 : ℝ) ^ (1 / β) ≤ (1 + η) * 4) :
    β ≠ 2 := by
  intro hβ2
  have hη1 : η < 1 := by linarith
  have hb := tail_exponent_from_knee_ratio hη hη1 hlo hhi
  rw [hβ2] at hb
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow]
    push_cast
    ring
  have hlt : Real.log (1 / (1 - η)) < Real.log 2 := by
    apply Real.log_lt_log (by
      have : (0:ℝ) < 1 - η := by linarith
      positivity)
    rw [div_lt_iff₀ (by linarith : (0:ℝ) < 1 - η)]
    linarith
  rw [hlog4, le_div_iff₀ (by linarith : (0:ℝ) < 2 * Real.log 2)] at hb
  have habs : |1 / (2 : ℝ) - 1| = 1 / 2 := by
    rw [show (1 : ℝ) / 2 - 1 = -(1/2) by norm_num, abs_neg, abs_of_pos (by norm_num)]
  rw [habs] at hb
  linarith

/-!
## 3.  The protocol: how many seeds the median needs
-/

/-- **Seed budget for the E3 test.**  If every genuine per-run margin ratio lies
in the acceptance band, `ys` is the reported log of the same length, at most `k`
runs are corrupted and `2k < n`, then every median of the reported log passes
E3.  This is the design rule: *strictly more than twice as many runs as possible
failures*. -/
theorem seeds_certify_band {xs ys : List ℚ} {m : ℚ} {k : ℕ}
    (hband : ∀ x ∈ xs, 9 / 10 ≤ x ∧ x ≤ 11 / 10)
    (hlen : ys.length = xs.length)
    (hk : MedianBreakdown.diffCount xs ys ≤ k) (hhalf : 2 * k < xs.length)
    (hm : MedianBreakdown.IsMedian ys m) :
    PassesE3 m :=
  median_ratio_in_band hlen.symm (by omega) hm hband

/-- **Two seeds per depth are not enough.**  With a two-run log, a single crashed
run lets an adversary — or a hardware fault — install *any* value `t` as the
reported median.  The current two-seed configuration therefore cannot support the
E3 claim, however the margins come out. -/
theorem two_seeds_break_on_one_bad_run (t : ℚ) :
    ∃ ys : List ℚ, ys.length = 2 ∧
      MedianBreakdown.diffCount [1, 1] ys ≤ 1 ∧ MedianBreakdown.IsMedian ys t := by
  refine ⟨MedianBreakdown.contaminate [1, 1] 1 t, ?_, ?_, ?_⟩
  · rw [MedianBreakdown.length_contaminate (by norm_num) t]
    norm_num
  · exact MedianBreakdown.diffCount_contaminate (by norm_num) t
  · exact MedianBreakdown.isMedian_contaminate (by norm_num) (by norm_num) t

/-- **Three seeds per depth are enough for one bad run.**  Any three-run log whose
genuine values lie in the band, with at most one run corrupted, reports a median
that passes E3. -/
theorem three_seeds_tolerate_one_bad_run {xs ys : List ℚ} {m : ℚ}
    (hxs : xs.length = 3) (hband : ∀ x ∈ xs, 9 / 10 ≤ x ∧ x ≤ 11 / 10)
    (hlen : ys.length = 3) (hk : MedianBreakdown.diffCount xs ys ≤ 1)
    (hm : MedianBreakdown.IsMedian ys m) :
    PassesE3 m :=
  seeds_certify_band hband (by rw [hlen, hxs]) hk (by omega) hm

/-!
## 4.  The bridge to E1: one forward pass, two readings
-/

/-- **E1's reading.**  A margin measured at one cell fixes the tail amplitude:
`A = m/(128·L·B)`. -/
theorem amplitude_from_margin {L B A m : ℝ} (hL : 0 < L) (hB : 0 < B)
    (hm : m = 128 * L * B * A) : A = m / (128 * L * B) := by
  rw [hm]
  field_simp

/-- **E3's reading of the same number.**  With the margin measured at one cell,
the attention deficit at the selected budget is confined to
`[m/(8·L·B), m/(4·L·B)]` — at every depth and every context `≥ 32`.  One forward
pass, two predictions. -/
theorem deficit_window_from_measured_margin {L B A ctx m : ℝ} (hL : 0 < L)
    (hB : 0 < B) (hA : 0 < A) (hctx : (32 : ℝ) ≤ ctx) (hm : m = 128 * L * B * A) :
    m / (8 * L * B) ≤ zipfTail A ctx (marginKnee A ctx L B m) ∧
      zipfTail A ctx (marginKnee A ctx L B m) ≤ m / (4 * L * B) := by
  subst hm
  obtain ⟨hlo, hhi⟩ := deficit_window_depth_and_context_free hA hL hB hctx
  have e1 : (128 * L * B * A) / (8 * L * B) = 16 * A := by field_simp; ring
  have e2 : (128 * L * B * A) / (4 * L * B) = 32 * A := by field_simp; ring
  rw [e1, e2]
  exact ⟨hlo, hhi⟩

end MarginProtocolDesign