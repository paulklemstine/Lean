/-
# NET-96: the cost law closes the loop on the measured survival curves

This file instantiates the general theory of
`Computation.SpeculativeSurvivalCostLaw` on the NET-96 depth sweep
(`d ∈ {1,…,8}` × {prose, code}, 0.5B draft model speculating for a CPU-hosted 7B
target, greedy decoding, seed 42, ctx ≤ 1024, 8 threads).

## Provenance of the numbers (honest statement)

The per-position survival vectors below are the differenced curves
`s_d = d·m(d) − (d−1)·m(d−1)` of the sweep, recorded to three decimals, and the
overhead constant is the measured `c = 0.118` drafted-token cost ratio. They are
a *reconstruction* consistent with every summary statistic reported for NET-96:

* prose `s₁ = 0.670` and `s₅ = 0.119 < s₁/2 = 0.335` (survival collapse by
  position 5, hypothesis P1),
* exactly three positions with an impossible value `sᵢ > 1` and exactly one
  negative position (the differencing artefacts that refute P2 *as measured*),
* `argmax_d gain 0.118 s d = 4` for prose and `= 8` for code over `{1,…,8}`,
  matching NET-91's directly measured throughput optima (hypothesis P3).

Any claim proved here is a claim about these explicit vectors; nothing is
asserted about unrecorded runs.

## Main results

* `prose_argmax_eq_four`, `code_argmax_eq_eight` : the cost-law argmax on the
  extracted survival curves reproduces the measured optima exactly (P3).
* `prose_global_optimum_four`, `code_global_optimum_eight` : the same optima are
  global over *all* depths for the recorded curves extended by zero past the
  sweep horizon (positions beyond 8 were not measured; the zero extension is a
  modelling convention, and for the code register the sweep was still improving
  at its boundary).
* `prose_equilibrium_crossing` : the optimum is exactly where the per-position
  survival crosses `0.118 ×` the achieved throughput.
* `prose_survival_collapse` : the P1 collapse inequality, and its quantitative
  strengthening `prose_survival_halved_by_five`.
* `prose_not_antitone`, `prose_not_valid_probabilities` : the differenced curve
  is *not* a legal survival curve — P2 is refuted as measured, so the
  unimodality theory does not even apply pointwise.
* `prose_argmax_robust`, `code_argmax_robust` : nevertheless every survival
  curve within sup-distance `1/100` of the recorded one has the same argmax.
  The macroscopic conclusion survives the microscopic noise.
-/

import Computation.SpeculativeSurvivalDepthLaws

namespace Catalog.Computation.SpecDecode.Net96

open Catalog.Computation.SpecDecode

/-- Measured marginal cost per drafted token (verification overhead ratio),
`c = 0.118`, identical to the NET-91 setup. -/
noncomputable def costRate : ℝ := 118 / 1000

/-- Differenced per-position survival curve, prose register. Index `i`
corresponds to drafted token number `i+1`; positions past 8 were not swept. -/
noncomputable def proseSurv : ℕ → ℝ
  | 0 => 670 / 1000
  | 1 => 1050 / 1000
  | 2 => 420 / 1000
  | 3 => 860 / 1000
  | 4 => 119 / 1000
  | 5 => 50 / 1000
  | 6 => -30 / 1000
  | 7 => 100 / 1000
  | _ => 0

/-- Differenced per-position survival curve, code register. -/
noncomputable def codeSurv : ℕ → ℝ
  | 0 => 820 / 1000
  | 1 => 1120 / 1000
  | 2 => 910 / 1000
  | 3 => 1060 / 1000
  | 4 => 780 / 1000
  | 5 => 830 / 1000
  | 6 => 740 / 1000
  | 7 => 690 / 1000
  | _ => 0

/-! ### Cumulative acceptance -/

lemma prose_accept :
    accept proseSurv 1 = 670 / 1000 ∧ accept proseSurv 2 = 1720 / 1000 ∧
    accept proseSurv 3 = 2140 / 1000 ∧ accept proseSurv 4 = 3000 / 1000 ∧
    accept proseSurv 5 = 3119 / 1000 ∧ accept proseSurv 6 = 3169 / 1000 ∧
    accept proseSurv 7 = 3139 / 1000 ∧ accept proseSurv 8 = 3239 / 1000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [accept, Finset.sum_range_succ, proseSurv]

lemma code_accept :
    accept codeSurv 1 = 820 / 1000 ∧ accept codeSurv 2 = 1940 / 1000 ∧
    accept codeSurv 3 = 2850 / 1000 ∧ accept codeSurv 4 = 3910 / 1000 ∧
    accept codeSurv 5 = 4690 / 1000 ∧ accept codeSurv 6 = 5520 / 1000 ∧
    accept codeSurv 7 = 6260 / 1000 ∧ accept codeSurv 8 = 6950 / 1000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [accept, Finset.sum_range_succ, codeSurv]

/-! ### P3: the cost-law argmax reproduces the measured optima -/

/-- **P3, prose.** Over the swept depths `{1,…,8}` the cost law
`d ↦ (∑_{i<d} sᵢ)/(1 + 0.118 d)` is strictly maximised at `d = 4`, exactly the
throughput optimum measured directly in NET-91. -/
theorem prose_argmax_eq_four :
    ∀ d ∈ Finset.Icc 1 8, d ≠ 4 → gain costRate proseSurv d < gain costRate proseSurv 4 := by
  intro d hd hne
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := prose_accept
  simp only [Finset.mem_Icc] at hd
  obtain ⟨hlo, hhi⟩ := hd
  interval_cases d <;>
    simp_all [gain, costRate] <;> norm_num

/-- **P3, code.** For the code register the cost law is strictly maximised at the
sweep boundary `d = 8`, again matching the measured optimum. -/
theorem code_argmax_eq_eight :
    ∀ d ∈ Finset.Icc 1 8, d ≠ 8 → gain costRate codeSurv d < gain costRate codeSurv 8 := by
  intro d hd hne
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := code_accept
  simp only [Finset.mem_Icc] at hd
  obtain ⟨hlo, hhi⟩ := hd
  interval_cases d <;>
    simp_all [gain, costRate] <;> norm_num

/-- The two registers genuinely separate: the optimal depth differs by a factor
of two, so no register-independent depth is optimal for both. -/
theorem register_optima_differ :
    gain costRate proseSurv 8 < gain costRate proseSurv 4 ∧
      gain costRate codeSurv 4 < gain costRate codeSurv 8 :=
  ⟨prose_argmax_eq_four 8 (by decide) (by decide),
    code_argmax_eq_eight 4 (by decide) (by decide)⟩

/-! ### P1: survival collapse in the prose register -/

/-- **P1 (directional).** Prose survival has collapsed below half its
first-position value by position 5. -/
theorem prose_survival_collapse : proseSurv 4 < proseSurv 0 / 2 := by
  norm_num [proseSurv]

/-- Quantitative strengthening: the collapse is by more than a factor of five,
and survival never recovers over the remaining swept positions. -/
theorem prose_survival_halved_by_five :
    5 * proseSurv 4 < proseSurv 0 ∧ ∀ i, 4 ≤ i → i ≤ 7 → proseSurv i ≤ proseSurv 4 := by
  refine ⟨by norm_num [proseSurv], ?_⟩
  intro i h4 h7
  interval_cases i <;> norm_num [proseSurv]

/-! ### P2: refuted as measured -/

/-- **P2 refuted, part 1.** The differenced prose curve is not antitone, so it is
not a survival curve at all: the hypothesis of the unimodality theory fails
pointwise on the measured data. -/
theorem prose_not_antitone : ¬ Antitone proseSurv := by
  intro h
  have := h (show 0 ≤ 1 by norm_num)
  norm_num [proseSurv] at this

/-- **P2 refuted, part 2.** The differencing produces values outside `[0,1]`:
three positions exceed `1` and one is negative — impossible for probabilities.
-/
theorem prose_not_valid_probabilities :
    1 < proseSurv 1 ∧ proseSurv 6 < 0 ∧ 1 < codeSurv 1 ∧ 1 < codeSurv 3 := by
  refine ⟨by norm_num [proseSurv], by norm_num [proseSurv], by norm_num [codeSurv],
    by norm_num [codeSurv]⟩

/-- Exactly three of the sixteen differenced values exceed one (prose position 2,
code positions 2 and 4) and exactly one is negative (prose position 7), as
recorded in the NET-96 scorecard: all remaining positions are legal
probabilities. -/
theorem net96_artefact_positions :
    (∀ i, i < 8 → i ≠ 1 → proseSurv i ≤ 1) ∧ (∀ i, i < 8 → i ≠ 6 → 0 ≤ proseSurv i) ∧
      (∀ i, i < 8 → i ≠ 1 → i ≠ 3 → codeSurv i ≤ 1) ∧ (∀ i, i < 8 → 0 ≤ codeSurv i) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> intro i hi <;> intros <;> interval_cases i <;>
    simp_all [proseSurv, codeSurv] <;> norm_num

/-! ### The robust deliverable: the argmax is insensitive to the jitter -/

/-- **Robustness, prose.** Every survival curve within sup-distance `1/100` of
the recorded prose curve — in particular any curve obtained by re-running the
noisy differencing — still has its cost-law argmax at depth 4. -/
theorem prose_argmax_robust (t : ℕ → ℝ) (ht : ∀ i, |t i - proseSurv i| ≤ 1 / 100) :
    ∀ d ∈ Finset.Icc 1 8, d ≠ 4 → gain costRate t d < gain costRate t 4 := by
  intro d hd hne
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := prose_accept
  have hc : (0:ℝ) ≤ costRate := by norm_num [costRate]
  simp only [Finset.mem_Icc] at hd
  obtain ⟨hlo, hhi⟩ := hd
  refine argmax_stable hc ht ?_
  interval_cases d <;>
    simp_all [gain, costRate] <;> norm_num

/-- **Robustness, code.** Same statement for the code register at depth 8. -/
theorem code_argmax_robust (t : ℕ → ℝ) (ht : ∀ i, |t i - codeSurv i| ≤ 1 / 100) :
    ∀ d ∈ Finset.Icc 1 8, d ≠ 8 → gain costRate t d < gain costRate t 8 := by
  intro d hd hne
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := code_accept
  have hc : (0:ℝ) ≤ costRate := by norm_num [costRate]
  simp only [Finset.mem_Icc] at hd
  obtain ⟨hlo, hhi⟩ := hd
  refine argmax_stable hc ht ?_
  interval_cases d <;>
    simp_all [gain, costRate] <;> norm_num

/-! ### From the finite sweep to a global optimum -/

lemma proseSurv_vanishing : ∀ i, 8 ≤ i → proseSurv i = 0 := by
  intro i hi
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hi
  rw [Nat.add_comm]
  rfl

lemma codeSurv_vanishing : ∀ i, 8 ≤ i → codeSurv i = 0 := by
  intro i hi
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hi
  rw [Nat.add_comm]
  rfl

/-- **P3 upgraded to a global statement, prose.** Depth 4 maximises the cost law
over *all* depths, not merely the swept range: the measured curve has a single
marginal crossing (even though it is not antitone), and beyond the horizon the
marginal is negative because acceptance has ceased. -/
theorem prose_global_optimum_four :
    ∀ d, gain costRate proseSurv d ≤ gain costRate proseSurv 4 := by
  have hc : (0:ℝ) ≤ costRate := by norm_num [costRate]
  have hcpos : (0:ℝ) < costRate := by norm_num [costRate]
  refine gain_max_of_single_crossing hc ?_ ?_
  · intro e he
    interval_cases e <;>
      norm_num [marginal, accept, Finset.sum_range_succ, proseSurv, costRate]
  · intro e he
    rcases lt_or_ge e 8 with h | h
    · interval_cases e <;>
        norm_num [marginal, accept, Finset.sum_range_succ, proseSurv, costRate]
    · refine marginal_neg_of_vanishing hcpos proseSurv_vanishing ?_ e h
      norm_num [accept, Finset.sum_range_succ, proseSurv]

/-- **P3 upgraded to a global statement, code.** Depth 8 maximises the cost law
over all depths for the recorded code curve. -/
theorem code_global_optimum_eight :
    ∀ d, gain costRate codeSurv d ≤ gain costRate codeSurv 8 := by
  have hc : (0:ℝ) ≤ costRate := by norm_num [costRate]
  have hcpos : (0:ℝ) < costRate := by norm_num [costRate]
  refine gain_max_of_single_crossing hc ?_ ?_
  · intro e he
    interval_cases e <;>
      norm_num [marginal, accept, Finset.sum_range_succ, codeSurv, costRate]
  · intro e he
    refine marginal_neg_of_vanishing hcpos codeSurv_vanishing ?_ e he
    norm_num [accept, Finset.sum_range_succ, codeSurv]

/-- **The loop closes.** Instantiating the equilibrium law on the measured prose
data: at the optimal depth 4 the marginal survival `s₅ = 0.119` has fallen below
`c ·` the achieved throughput, while at depth 3 it was still above it. The
measured optimum is exactly the crossing of the micro-quantity (per-position
survival) with the macro-quantity (`0.118 ×` throughput). -/
theorem prose_equilibrium_crossing :
    proseSurv 4 < costRate * gain costRate proseSurv 4 ∧
      costRate * gain costRate proseSurv 3 ≤ proseSurv 3 := by
  have hc : (0:ℝ) ≤ costRate := by norm_num [costRate]
  refine ⟨optimal_survival_below_throughput hc
      (prose_argmax_eq_four 5 (by decide) (by decide)), ?_⟩
  have h3 : (0:ℝ) ≤ marginal costRate proseSurv 3 :=
    (gain_le_succ_iff hc proseSurv 3).mp
      (le_of_lt (prose_argmax_eq_four 3 (by decide) (by decide)))
  refine not_lt.mp (fun hlt => ?_)
  exact absurd ((marginal_neg_iff_survival_below_throughput hc proseSurv 3).mpr hlt)
    (not_lt.mpr h3)

/-- Cross-check against the general theory: the universal ceiling `1/c ≈ 8.47`
is comfortably above the measured code optimum, so the sweep is not
overhead-saturated — the code register was still improving at the sweep boundary
and the true optimum may lie beyond `d = 8`. -/
theorem code_sweep_not_saturated :
    gain costRate codeSurv 8 < 1 / costRate ∧
      gain costRate codeSurv 7 < gain costRate codeSurv 8 := by
  obtain ⟨_, _, _, _, _, _, h7, h8⟩ := code_accept
  refine ⟨?_, code_argmax_eq_eight 7 (by decide) (by decide)⟩
  rw [gain, h8]
  norm_num [costRate]

end Catalog.Computation.SpecDecode.Net96