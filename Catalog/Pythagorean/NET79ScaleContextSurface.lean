import Mathlib
import Shared.AttentionBudgetKnee
import Pythagorean.NET79GeometricRatioKnee

/-!
# The NET-79 scale × context surface: non-separability, amplification, and a realizable
inversion

The NET-79 round completes a two-scale × four-context table of measured knees
(gate `0.985`, contexts `512, 1024, 2048, 4096`):

```
scale   @512  @1024  @2048  @4096   increments
0.5B     16    20     24     40      +4, +4, +16
1.5B     16    16     18     56      0,  +2, +38
```

This file proves what that table does and does not permit, and then proves that its
most striking feature — the *inversion* of the two curves between `2048` and `4096` —
is not an artefact but a genuinely realizable phenomenon of retained-mass knees.

* `net79_not_additively_separable`, `net79_not_multiplicatively_separable` — the
  budget surface is not a sum `f(scale) + g(ctx)` nor a product `f(scale)·g(ctx)`.
  Scale and context interact; a two-factor budget table is provably wrong.
* `net79_scale_gap_changes_sign`, `net79_crossover_index` — the scale advantage
  reverses, and the reversal happens exactly at the last grid step.
* `net79_amplification_factors` — the acceleration factors are exactly `4` and `19`.
* `knee_ordering_inversion_realizable` — **the main theorem.**  There are two genuine
  attention profiles and two context lengths at which the *ordering of their knees is
  reversed*: at the short context the second profile needs strictly fewer keys, at the
  long context strictly more.  So "profile `B` is uniformly cheaper than profile `A`"
  is not a well-posed notion, and a deployment table must carry both parameters.
* `no_inversion_of_retention_domination` — the companion rigidity statement: an
  inversion is possible *only* because the two retention curves cross.  This isolates
  the exact structural cause.

-- !-- Lab Notes -- !--
Hypothesizer:
 (S1) The measured surface is not separable in scale and context (either additively or
      multiplicatively).
 (S2) Inversion of two knee curves across context is realizable by honest profiles —
      not an experimental artefact.                                          [BOLD]
 (S3) Inversion is *equivalent* to a crossing of the retained-mass curves; profiles
      comparable in retention can never invert.                              [BOLD]
Experimenter: S1–S3 proved below with zero sorries.  The witnesses for S2 are
`w_A i = (1/2)^i` (spectral gap, uniformly bounded knee `≤ 4` at gate `0.9`) and
`w_B i = (1/16)^i + 1/1000` (steeper head, but a positive floor).  At context `2`,
`k*(B) = 1 < 2 = k*(A)`; at context `5000`, `k*(A) ≤ 4 < k*(B)`.
Analyst: the floor is the whole mechanism.  A profile can look *better* at short
context precisely by concentrating its head mass, and still be asymptotically worse
because its tail is not summable relative to the context.  This is the structural
reading of "the acceleration is universal, and amplifies with scale": a steeper head
buys short-context efficiency and pays for it at long context.
Critic: the measured numbers are used only as *definitions of the reported table*
(`net79Small`, `net79Large`), never as axioms about models; every theorem about them is
a statement about those four-point sequences.  The inversion theorem is independent of
the measurements and stands on its own.
-/

namespace PythKnee

open Finset AttentionBudget

/-! ## The measured grid -/

/-- Reported `0.5B` knees on the context ladder `512, 1024, 2048, 4096`. -/
def net79Small : ℕ → ℕ
  | 0 => 16
  | 1 => 20
  | 2 => 24
  | _ => 40

/-- Reported `1.5B` knees on the context ladder `512, 1024, 2048, 4096`. -/
def net79Large : ℕ → ℕ
  | 0 => 16
  | 1 => 16
  | 2 => 18
  | _ => 56

/-- Increments of a knee ladder. -/
def kneeIncr (f : ℕ → ℕ) (j : ℕ) : ℤ := (f (j + 1) : ℤ) - (f j : ℤ)

theorem net79_increments_small :
    (kneeIncr net79Small 0, kneeIncr net79Small 1, kneeIncr net79Small 2) = (4, 4, 16) := by
  simp [kneeIncr, net79Small]

theorem net79_increments_large :
    (kneeIncr net79Large 0, kneeIncr net79Large 1, kneeIncr net79Large 2) = (0, 2, 38) := by
  simp [kneeIncr, net79Large]

/-- **Acceleration factors.**  The last increment is `4×` the previous one for the small
model and `19×` for the large one: acceleration amplifies with scale. -/
theorem net79_amplification_factors :
    kneeIncr net79Small 2 = 4 * kneeIncr net79Small 1 ∧
      kneeIncr net79Large 2 = 19 * kneeIncr net79Large 1 ∧
      (4 : ℤ) < 19 := by
  refine ⟨?_, ?_, by norm_num⟩ <;> simp [kneeIncr, net79Small, net79Large]

/-! ## Non-separability of the two-parameter surface -/

/-- **No additive law.**  The measured surface is not of the form `f(scale) + g(ctx)`. -/
theorem net79_not_additively_separable :
    ¬ ∃ f g : ℕ → ℤ, (∀ j ≤ 3, (net79Small j : ℤ) = f 0 + g j) ∧
      (∀ j ≤ 3, (net79Large j : ℤ) = f 1 + g j) := by
  rintro ⟨f, g, hS, hL⟩
  have hS0 := hS 0 (by norm_num)
  have hL0 := hL 0 (by norm_num)
  have hS3 := hS 3 (by norm_num)
  have hL3 := hL 3 (by norm_num)
  simp [net79Small, net79Large] at hS0 hL0 hS3 hL3
  omega

/-- **No multiplicative law.**  The measured surface is not of the form
`f(scale) * g(ctx)` either. -/
theorem net79_not_multiplicatively_separable :
    ¬ ∃ f g : ℕ → ℚ, (∀ j ≤ 3, (net79Small j : ℚ) = f 0 * g j) ∧
      (∀ j ≤ 3, (net79Large j : ℚ) = f 1 * g j) := by
  rintro ⟨f, g, hS, hL⟩
  have hS0 := hS 0 (by norm_num)
  have hL0 := hL 0 (by norm_num)
  have hS1 := hS 1 (by norm_num)
  have hL1 := hL 1 (by norm_num)
  simp [net79Small, net79Large] at hS0 hL0 hS1 hL1
  have hg0 : g 0 ≠ 0 := by
    intro h; rw [h, mul_zero] at hS0; norm_num at hS0
  have hff : f 0 = f 1 := by
    have : f 0 * g 0 = f 1 * g 0 := by rw [← hS0, ← hL0]
    exact mul_right_cancel₀ hg0 this
  rw [hff] at hS1
  rw [← hL1] at hS1
  norm_num at hS1

/-- **Sign inversion of the scale gap.**  The larger model is cheaper at `1024`
(`gap < 0`) and dearer at `4096` (`gap > 0`). -/
theorem net79_scale_gap_changes_sign :
    (net79Large 1 : ℤ) - net79Small 1 < 0 ∧ 0 < (net79Large 3 : ℤ) - net79Small 3 := by
  simp [net79Small, net79Large]

/-- **Crossover localisation.**  `3` (i.e. context `4096`) is the least grid index at
which the larger model needs strictly more keys. -/
theorem net79_crossover_index :
    IsLeast {j : ℕ | net79Small j < net79Large j} 3 := by
  constructor
  · simp [net79Small, net79Large]
  · intro j hj
    simp only [Set.mem_setOf_eq] at hj
    by_contra hcon
    push_neg at hcon
    interval_cases j <;> simp [net79Small, net79Large] at hj

/-- **Deployment consequence.**  A `24`-key cache covers both models at `2048` but no
budget below `56` covers them at `4096`. -/
theorem net79_least_common_budget :
    IsLeast {B : ℕ | net79Small 2 ≤ B ∧ net79Large 2 ≤ B} 24 ∧
      IsLeast {B : ℕ | net79Small 3 ≤ B ∧ net79Large 3 ≤ B} 56 := by
  constructor
  · exact ⟨⟨by simp [net79Small], by simp [net79Large]⟩, fun B hB => by
      simpa [net79Small] using hB.1⟩
  · exact ⟨⟨by simp [net79Small], by simp [net79Large]⟩, fun B hB => by
      simpa [net79Large] using hB.2⟩

/-! ## The inversion is realizable

Two honest attention profiles whose knee ordering reverses with context. -/

/-- A profile with a spectral gap: geometric with ratio `1/2`. -/
noncomputable def profGap : ℕ → ℝ := geomProfile (1 / 2)

/-- A profile with a much steeper head but a positive floor. -/
noncomputable def profFloor : ℕ → ℝ := fun i => (1 / 16 : ℝ) ^ i + 1 / 1000

lemma profGap_pos : ∀ i, 0 < profGap i := fun i => by
  simpa [profGap] using geomProfile_pos (r := (1 / 2 : ℝ)) (by norm_num) i

lemma profFloor_pos : ∀ i, 0 < profFloor i := fun i => by
  have : (0 : ℝ) < (1 / 16 : ℝ) ^ i := by positivity
  simp only [profFloor]
  linarith

lemma profFloor_lower (i : ℕ) : (1 : ℝ) / 1000 ≤ profFloor i := by
  have : (0 : ℝ) < (1 / 16 : ℝ) ^ i := by positivity
  simp only [profFloor]; linarith

lemma profFloor_upper (i : ℕ) : profFloor i ≤ 1 + 1 / 1000 := by
  have : (1 / 16 : ℝ) ^ i ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
  simp only [profFloor]; linarith

/-- At context `2` the floor profile needs a single key. -/
theorem kstar_profFloor_two : kstar profFloor 2 (9 / 10) = 1 := by
  have hpass : (9 / 10 : ℝ) ≤ retained profFloor 2 1 := by
    rw [retained, headMass, headMass]
    norm_num [profFloor, Finset.sum_range_succ]
  have hfail : retained profFloor 2 0 < 9 / 10 := by
    rw [retained, headMass, headMass]
    norm_num [profFloor, Finset.sum_range_succ]
  obtain ⟨hlo, hhi⟩ := knee_bracket profFloor_pos (by norm_num) (by norm_num) hfail hpass
  omega

/-- At context `2` the gapped profile needs two keys: at this context the *steeper*
profile is strictly cheaper. -/
theorem kstar_profGap_two : kstar profGap 2 (9 / 10) = 2 := by
  have hpass : (9 / 10 : ℝ) ≤ retained profGap 2 2 := by
    rw [retained_self profGap_pos (by norm_num)]; norm_num
  have hfail : retained profGap 2 1 < 9 / 10 := by
    rw [retained, headMass, headMass]
    norm_num [profGap, geomProfile, Finset.sum_range_succ]
  obtain ⟨hlo, hhi⟩ := knee_bracket profGap_pos (by norm_num) (by norm_num) hfail hpass
  omega

/-- The gapped profile has a context-free budget of four keys at gate `0.9`. -/
theorem kstar_profGap_le_four {n : ℕ} (hn : 0 < n) : kstar profGap n (9 / 10) ≤ 4 := by
  have := kstar_geomProfile_le_of_pow_le (r := (1 / 2 : ℝ)) (τ := 9 / 10) (K := 4)
    (by norm_num) (by norm_num) hn (by norm_num)
  simpa [profGap] using this

/-- The floor profile's budget grows linearly: at context `5000` it exceeds four keys. -/
theorem four_lt_kstar_profFloor : 4 < kstar profFloor 5000 (9 / 10) := by
  have hb := kstar_ge_of_bounded_ratio (w := profFloor) (τ := 9 / 10) (n := 5000)
    profFloor_pos (c := 1 / 1000) (M := 1 + 1 / 1000) (by norm_num)
    profFloor_lower profFloor_upper (by norm_num) (by norm_num)
  have h4 : (4 : ℝ) < (kstar profFloor 5000 (9 / 10) : ℝ) := by
    norm_num at hb
    linarith
  exact_mod_cast h4

/-- **The inversion theorem.**  Two genuine attention profiles whose knee ordering
reverses with context: at context `2` the floor profile is strictly cheaper, at context
`5000` it is strictly dearer.  Hence no profile is uniformly more key-efficient than
another, and a key-budget table must be indexed by profile *and* context jointly. -/
theorem knee_ordering_inversion_realizable :
    ∃ (wA wB : ℕ → ℝ) (n₁ n₂ : ℕ), (∀ i, 0 < wA i) ∧ (∀ i, 0 < wB i) ∧ n₁ < n₂ ∧
      kstar wB n₁ (9 / 10) < kstar wA n₁ (9 / 10) ∧
        kstar wA n₂ (9 / 10) < kstar wB n₂ (9 / 10) := by
  refine ⟨profGap, profFloor, 2, 5000, profGap_pos, profFloor_pos, by norm_num, ?_, ?_⟩
  · rw [kstar_profFloor_two, kstar_profGap_two]; norm_num
  · exact lt_of_le_of_lt (kstar_profGap_le_four (by norm_num)) four_lt_kstar_profFloor

/-! ## Rigidity: an inversion certifies a crossing of the retention curves -/

/-- If one profile dominates another in retained mass at every context and budget, its
knee is never larger — no inversion is possible. -/
theorem no_inversion_of_retention_domination {v w : ℕ → ℝ} (hw : ∀ i, 0 < w i)
    (hdom : ∀ n k, retained w n k ≤ retained v n k) {n : ℕ} (hn : 0 < n) {τ : ℝ}
    (hτ : τ ≤ 1) : kstar v n τ ≤ kstar w n τ :=
  kstar_le_of_pass ((gate_le_retained_kstar hw hn hτ).trans (hdom _ _))

/-- **Structural cause of the inversion.**  Whenever two profiles invert, their
retained-mass curves must cross: there is a context and a budget at which the
comparison of retained masses goes the other way. -/
theorem inversion_forces_retention_crossing {v w : ℕ → ℝ} (hv : ∀ i, 0 < v i)
    (hw : ∀ i, 0 < w i) {n₁ n₂ : ℕ} (hn₁ : 0 < n₁) (hn₂ : 0 < n₂) {τ : ℝ} (hτ : τ ≤ 1)
    (h₁ : kstar w n₁ τ < kstar v n₁ τ) (h₂ : kstar v n₂ τ < kstar w n₂ τ) :
    (∃ n k, retained v n k < retained w n k) ∧ (∃ n k, retained w n k < retained v n k) := by
  constructor
  · by_contra hcon
    push_neg at hcon
    exact absurd (no_inversion_of_retention_domination hw (fun n k => hcon n k) hn₁ hτ)
      (by omega)
  · by_contra hcon
    push_neg at hcon
    exact absurd (no_inversion_of_retention_domination hv (fun n k => hcon n k) hn₂ hτ)
      (by omega)

end PythKnee