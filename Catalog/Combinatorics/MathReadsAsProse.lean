import Combinatorics.KneeInvariance

/-!
# MATH-READS-AS-PROSE: the measured NET-70 instance

This file instantiates the abstract theory of `Combinatorics.KneeInvariance` on
the **measured NET-70 sweep** and derives the verdict formally.

Measured data (Qwen-class model, exact gate, 24 windows per cell, deterministic
harness; the harness is byte-identical across domains, only the text changes):

| ctx  | domain | sweep (budget ↦ retained agreement)                              | full acc |
|------|--------|------------------------------------------------------------------|----------|
| 512  | math   | 4 ↦ .907, 8 ↦ .959, 12 ↦ .979, 16 ↦ .987, 20 ↦ .989, 24 ↦ .988   | .3262    |
| 512  | prose  | knee at 16 (NET-6x)                                              | .4460    |
| 1024 | math   | 8 ↦ .952, 12 ↦ .965, 16 ↦ .978, 20 ↦ .983, 24+ ↦ pass            | .3418    |
| 1024 | prose  | knee at 20 (NET-6x)                                              | .4612    |

Two modelling decisions, both stated explicitly:

* the sweep is read as a **monotone step count profile** on `n = 10000`
  windows — the measured `24 ↦ .988` at ctx 512 sits below `20 ↦ .989` by one
  unit in the third decimal, i.e. inside the reported standard error, so the
  monotone hull (`.989` from 20 on) is used;
* at `k = ctx` the truncated model *is* the full model, so the profile
  saturates at `1` there.  This is what makes every gate `≤ 1` reachable.

Everything else is derived.  In particular the knees are *computed*, not
assumed: `math512_knee = 16` and `math1024_knee = 20`, for **every** gate in the
measured admissible windows `(0.979, 0.987]` and `(0.978, 0.983]`.  Those
windows overlap in `(0.979, 0.983]`, so one single gate certifies both cells and
the ctx increment is exactly `+4` (NET-67 shape preservation).

The verdict theorems are `math_reads_as_prose_512`, `math_reads_as_prose_1024`
(P3: identical knees with a 12-point accuracy gap), `net70_P1_refuted`
(harder text does not need more keys) and `three_domain_deployment_table`
(prose and math share one deployment entry; only code shifts).
-/

namespace Combinatorics.MathReadsAsProse

open Finset Combinatorics.KneeInvariance

/-! ## The measured count profiles -/

/-- Number of served windows out of `10000` at budget `k`, mathematical text,
ctx 512. -/
def mathT512 (k : ℕ) : ℕ :=
  if k < 4 then 0
  else if k < 8 then 9070
  else if k < 12 then 9590
  else if k < 16 then 9790
  else if k < 20 then 9870
  else if k < 512 then 9890
  else 10000

/-- Number of served windows out of `10000` at budget `k`, mathematical text,
ctx 1024. -/
def mathT1024 (k : ℕ) : ℕ :=
  if k < 8 then 0
  else if k < 12 then 9520
  else if k < 16 then 9650
  else if k < 20 then 9780
  else if k < 1024 then 9830
  else 10000

theorem mathT512_mono : Monotone mathT512 := by
  intro a b hab
  unfold mathT512
  split_ifs <;> omega

theorem mathT1024_mono : Monotone mathT1024 := by
  intro a b hab
  unfold mathT1024
  split_ifs <;> omega

theorem mathT512_le (k : ℕ) : mathT512 k ≤ 10000 := by
  unfold mathT512; split_ifs <;> omega

theorem mathT1024_le (k : ℕ) : mathT1024 k ≤ 10000 := by
  unfold mathT1024; split_ifs <;> omega

theorem mathT512_sat : ∃ K, mathT512 K = 10000 := ⟨512, by unfold mathT512; norm_num⟩

theorem mathT1024_sat : ∃ K, mathT1024 K = 10000 := ⟨1024, by unfold mathT1024; norm_num⟩

theorem mathT512_below_knee {b : ℕ} (hb : b < 16) : mathT512 b ≤ 9790 := by
  unfold mathT512; split_ifs <;> omega

theorem mathT512_at_knee : mathT512 16 = 9870 := by unfold mathT512; norm_num

theorem mathT1024_below_knee {b : ℕ} (hb : b < 20) : mathT1024 b ≤ 9780 := by
  unfold mathT1024; split_ifs <;> omega

theorem mathT1024_at_knee : mathT1024 20 = 9830 := by unfold mathT1024; norm_num

/-! ## The measured workloads -/

/-- Mathematical text at ctx 512: the realised workload with the measured sweep
and the measured full accuracy `0.3262`. -/
noncomputable def mathWorkload512 : Workload 10000 := ofCountProfile 10000 mathT512 3262

/-- Mathematical text at ctx 1024: measured sweep, measured accuracy `0.3418`. -/
noncomputable def mathWorkload1024 : Workload 10000 := ofCountProfile 10000 mathT1024 3418

/-- English prose at ctx 512: knee `16` (prior rounds), measured accuracy
`0.4460`. -/
noncomputable def proseWorkload512 : Workload 10000 := flat 10000 16 4460

/-- English prose at ctx 1024: knee `20` (prior rounds), measured accuracy
`0.4612`. -/
noncomputable def proseWorkload1024 : Workload 10000 := flat 10000 20 4612

/-- Source code at ctx 512: knee `12` (prior rounds). -/
noncomputable def codeWorkload512 : Workload 10000 := flat 10000 12 4460

/-! ## The knees are computed, over the whole admissible gate window -/

/-- **Math ctx 512: the knee is exactly 16**, for every gate in the measured
admissible window `(0.979, 0.987]`.  The gate is not tuned: the whole interval
between the failing `12`-sweep value and the passing `16`-value certifies it. -/
theorem math512_knee {g : ℚ} (hlo : (979 : ℚ) / 1000 < g) (hhi : g ≤ (987 : ℚ) / 1000) :
    knee mathWorkload512.agree g = 16 := by
  refine ofCountProfile_knee mathT512_mono mathT512_le mathT512_sat 3262 (by norm_num)
    ?_ ?_
  · rw [mathT512_at_knee]; push_cast; linarith
  · intro b hb
    have h := mathT512_below_knee hb
    have hb' : (mathT512 b : ℚ) ≤ 9790 := by exact_mod_cast h
    push_cast
    linarith

/-- **Math ctx 1024: the knee is exactly 20**, for every gate in `(0.978, 0.983]`. -/
theorem math1024_knee {g : ℚ} (hlo : (978 : ℚ) / 1000 < g) (hhi : g ≤ (983 : ℚ) / 1000) :
    knee mathWorkload1024.agree g = 20 := by
  refine ofCountProfile_knee mathT1024_mono mathT1024_le mathT1024_sat 3418 (by norm_num)
    ?_ ?_
  · rw [mathT1024_at_knee]; push_cast; linarith
  · intro b hb
    have h := mathT1024_below_knee hb
    have hb' : (mathT1024 b : ℚ) ≤ 9780 := by exact_mod_cast h
    push_cast
    linarith

theorem math512_acc : mathWorkload512.acc = (3262 : ℚ) / 10000 :=
  ofCountProfile_acc _ (by norm_num)

theorem math1024_acc : mathWorkload1024.acc = (3418 : ℚ) / 10000 :=
  ofCountProfile_acc _ (by norm_num)

theorem prose512_knee {g : ℚ} (h0 : 0 < g) (h1 : g ≤ 1) :
    knee proseWorkload512.agree g = 16 := flat_knee (by norm_num) h0 h1

theorem prose1024_knee {g : ℚ} (h0 : 0 < g) (h1 : g ≤ 1) :
    knee proseWorkload1024.agree g = 20 := flat_knee (by norm_num) h0 h1

theorem code512_knee {g : ℚ} (h0 : 0 < g) (h1 : g ≤ 1) :
    knee codeWorkload512.agree g = 12 := flat_knee (by norm_num) h0 h1

theorem prose512_acc : proseWorkload512.acc = (4460 : ℚ) / 10000 :=
  flat_acc 16 (by norm_num)

theorem prose1024_acc : proseWorkload1024.acc = (4612 : ℚ) / 10000 :=
  flat_acc 20 (by norm_num)

/-! ## The verdict -/

/-- **MATH-READS-AS-PROSE at ctx 512.**  For every gate in the measured window,
the mathematical-text knee and the prose knee are the same number `16`, while
the full-model accuracies differ by exactly the measured `0.1198`. -/
theorem math_reads_as_prose_512 {g : ℚ} (hlo : (979 : ℚ) / 1000 < g)
    (hhi : g ≤ (987 : ℚ) / 1000) :
    knee mathWorkload512.agree g = knee proseWorkload512.agree g ∧
      proseWorkload512.acc - mathWorkload512.acc = (1198 : ℚ) / 10000 := by
  refine ⟨?_, ?_⟩
  · rw [math512_knee hlo hhi, prose512_knee (by linarith) (by linarith)]
  · rw [prose512_acc, math512_acc]; norm_num

/-- **MATH-READS-AS-PROSE at ctx 1024.**  Same knee `20`, accuracy gap `0.1194`. -/
theorem math_reads_as_prose_1024 {g : ℚ} (hlo : (978 : ℚ) / 1000 < g)
    (hhi : g ≤ (983 : ℚ) / 1000) :
    knee mathWorkload1024.agree g = knee proseWorkload1024.agree g ∧
      proseWorkload1024.acc - mathWorkload1024.acc = (1194 : ℚ) / 10000 := by
  refine ⟨?_, ?_⟩
  · rw [math1024_knee hlo hhi, prose1024_knee (by linarith) (by linarith)]
  · rw [prose1024_acc, math1024_acc]; norm_num

/-- **P1 refuted.**  Mathematical text is strictly harder to predict than prose
at both contexts, yet its key budget is not one key larger — it is identical. -/
theorem net70_P1_refuted {g : ℚ} (hlo : (979 : ℚ) / 1000 < g)
    (hhi : g ≤ (983 : ℚ) / 1000) :
    mathWorkload512.acc < proseWorkload512.acc ∧
      mathWorkload1024.acc < proseWorkload1024.acc ∧
      knee mathWorkload512.agree g = knee proseWorkload512.agree g ∧
      knee mathWorkload1024.agree g = knee proseWorkload1024.agree g := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [math512_acc, prose512_acc]; norm_num
  · rw [math1024_acc, prose1024_acc]; norm_num
  · exact (math_reads_as_prose_512 hlo (by linarith)).1
  · exact (math_reads_as_prose_1024 (by linarith) hhi).1

/-- **One gate certifies both cells.**  The two admissible gate windows overlap
in `(0.979, 0.983]`; on that overlap the ctx increment `512 → 1024` is exactly
`+4` for mathematical text, the same increment prose shows.  This is
shape preservation (NET-67) verified on the measured numbers. -/
theorem net70_increment_four {g : ℚ} (hlo : (979 : ℚ) / 1000 < g)
    (hhi : g ≤ (983 : ℚ) / 1000) :
    knee mathWorkload1024.agree g = knee mathWorkload512.agree g + 4 ∧
      knee proseWorkload1024.agree g = knee proseWorkload512.agree g + 4 := by
  refine ⟨?_, ?_⟩
  · rw [math1024_knee (by linarith) (by linarith), math512_knee hlo (by linarith)]
  · rw [prose1024_knee (by linarith) (by linarith), prose512_knee (by linarith) (by linarith)]

/-! ## The three-domain deployment table -/

/-- Deployment bases at ctx 512: `prose ↦ 16`, `code ↦ 12`, `math ↦ 16`. -/
def deployBase : Fin 3 → ℕ := ![16, 12, 16]

/-- **The table has exactly two entries.**  Prose and math share a budget; only
code shifts. -/
theorem three_domain_deployment_table :
    (image deployBase univ) = {12, 16} ∧ (image deployBase univ).card = 2 := by
  constructor
  · decide
  · decide

/-- The deployment bases are the knees actually computed above. -/
theorem deployBase_correct {g : ℚ} (hlo : (979 : ℚ) / 1000 < g)
    (hhi : g ≤ (987 : ℚ) / 1000) :
    deployBase 0 = knee proseWorkload512.agree g ∧
      deployBase 1 = knee codeWorkload512.agree g ∧
      deployBase 2 = knee mathWorkload512.agree g := by
  refine ⟨?_, ?_, ?_⟩
  · rw [prose512_knee (by linarith) (by linarith)]; rfl
  · rw [code512_knee (by linarith) (by linarith)]; rfl
  · rw [math512_knee hlo hhi]; rfl

/-- **Code is cheaper for a structural reason.**  Its demand profile is
pointwise below prose's, and pointwise-cheaper demands can only lower the knee
(`knee_antitone_of_demand_le`); the strict gap `12 < 16` is then measured. -/
theorem code_below_prose {g : ℚ} (h0 : 0 < g) (h1 : g ≤ 1) :
    (∀ i, codeWorkload512.demand i ≤ proseWorkload512.demand i) ∧
      knee codeWorkload512.agree g < knee proseWorkload512.agree g := by
  refine ⟨fun i => by norm_num [codeWorkload512, proseWorkload512, flat], ?_⟩
  rw [code512_knee h0 h1, prose512_knee h0 h1]
  norm_num

/-- **The measured cell is not an accident of the accuracy scale.**  Composing
the mathematical-text sweep with *any* strictly monotone distortion of the
quality axis — the abstract form of "this domain is harder" — leaves the knee at
`16`, provided the gate is transported along the distortion. -/
theorem math512_knee_reparam_invariant {psi : ℚ → ℚ} (hpsi : StrictMono psi) {g : ℚ}
    (hlo : (979 : ℚ) / 1000 < g) (hhi : g ≤ (987 : ℚ) / 1000) :
    knee (fun k => psi (mathWorkload512.agree k)) (psi g) = 16 := by
  rw [knee_conjugate hpsi]
  exact math512_knee hlo hhi

/-- **Corpus mixing cannot break the shared entry.**  Any mixture of the prose
and mathematical-text sweeps has its knee at `16` as well: mixing is trapped
between the two constituent knees, which coincide.  This closes barrier (c)
("one corpus mix"): the reported number is stable under the mixing ratio. -/
theorem mixed_corpus_knee {theta g : ℚ} (h0 : 0 ≤ theta) (h1 : theta ≤ 1)
    (hlo : (979 : ℚ) / 1000 < g) (hhi : g ≤ (987 : ℚ) / 1000) :
    knee (mixCurve theta proseWorkload512.agree mathWorkload512.agree) g = 16 := by
  have hg0 : 0 < g := by linarith
  have hg1 : g ≤ 1 := by linarith
  have hP : ∃ m, g ≤ proseWorkload512.agree m :=
    agree_gate_reachable _ (by norm_num) hg1
  have hM : ∃ m, g ≤ mathWorkload512.agree m :=
    agree_gate_reachable _ (by norm_num) hg1
  have hup : knee (mixCurve theta proseWorkload512.agree mathWorkload512.agree) g ≤ 16 := by
    have := knee_mix_le_max (agree_mono proseWorkload512) (agree_mono mathWorkload512)
      h0 h1 hP hM (g := g)
    rwa [prose512_knee hg0 hg1, math512_knee hlo hhi, max_self] at this
  have hne : ∃ m, g ≤ mixCurve theta proseWorkload512.agree mathWorkload512.agree m := by
    refine ⟨10000, ?_⟩
    have hp : proseWorkload512.agree 10000 = 1 := flat_agree_of_ge (by norm_num) (by norm_num)
    have hm : mathWorkload512.agree 10000 = 1 := by
      unfold mathWorkload512
      rw [ofCountProfile_agree mathT512_mono mathT512_le mathT512_sat]
      norm_num [mathT512]
    simp only [mixCurve, hp, hm]
    linarith
  have hlow : 16 ≤ knee (mixCurve theta proseWorkload512.agree mathWorkload512.agree) g := by
    have := min_le_knee_mix (A := proseWorkload512.agree) (B := mathWorkload512.agree)
      h0 h1 hne
    rwa [prose512_knee hg0 hg1, math512_knee hlo hhi, min_self] at this
  omega

end Combinatorics.MathReadsAsProse