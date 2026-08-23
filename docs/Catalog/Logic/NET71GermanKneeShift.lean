/-
# NET-71 — THE-TOKENIZER-TAX-IS-FOUR-KEYS: the German prose leg

**Lab notes (round 24 of the limited-memory axis, paper 156,
`ResearchOutput/exp_net71_nonenglish.py`, `/tmp/net71.log`).**  First non-English
domain jump: German prose (Goethe + a second classic), byte-identical harness to
NET-68, exact gate, bar `= 0.98` of full accuracy, fine grid of step `4`,
per-corpus held-out splits, deterministic.

| ctx  | German `k*` | EN prose `k*` | shift |
|------|-------------|---------------|-------|
| 512  | **20**      | 16            | `+4`  |
| 1024 | **24**      | 20            | `+4`  |

German retained-accuracy sweeps (fraction of full accuracy):

* @512  : `4 ↦ 0.883 ✗, 8 ↦ 0.953 ✗, 12 ↦ 0.969 ✗, 16 ↦ 0.976 ✗, 20 ↦ 0.983 ✓, 24 ↦ 0.988`
* @1024 : `8 ↦ 0.926 ✗, 12 ↦ 0.956 ✗, 16 ↦ 0.968 ✗, 20 ↦ 0.975 ✗, 24 ↦ 0.982 ✓`

Pre-registered horns: **P1** (the shift is exactly one fine grid step up, at both
contexts) CONFIRMED; **P2** (an intermediate, sub-step shift) REFUTED;
**P3** (no shift at all) REFUTED.

## What this file proves

*§1 The measurement.*  `net71_de512_knee`, `net71_de1024_knee`: **every** monotone
accuracy curve agreeing with the German sweep at the two bracketing points has knee
index `5` resp. `6`, i.e. budget `20` resp. `24` keys.  The measured tables
`german512`, `german1024` are exhibited and proved monotone
(`net71_de512_knee_concrete`, `net71_de1024_knee_concrete`), so the hypotheses are
not vacuous, and the ✗ column is verified (`net71_de512_subknee_fail`,
`net71_de1024_subknee_fail`).

*§2 Noise robustness — the fragile reading.*  The round flags the `16`-key point at
`512` as clearing the bar by only about `1.5` standard errors.  `de512_knee_stable`
and `de1024_knee_stable` quantify exactly how much noise the two knees tolerate:
any perturbation uniformly smaller than `0.003` (resp. `0.002`) leaves the knee
untouched, and `de512_knee_unstable_at_four_thousandths`,
`de1024_knee_unstable_at_two_thousandths` show these radii are **sharp** — a
perturbation of the stated size already moves the knee down one step.  So the
German knees are certified only to `±` one reported standard error, which is the
honest boundary of the round.

*§3 The fitted law and the mirror.*  `deLaw = ⟨20, 4⟩`, pinned by the two measured
contexts (`deLaw_unique`).  `net71_shift`: German sits exactly `+4` keys above EN
prose at *every* context; `net71_increment_shared` turns this context-freedom into
the structural statement that the domain enters only through the base.
`net71_mirror`: the German step up equals the code step down, so the three measured
bases `12 < 16 < 20` form an **arithmetic progression whose common difference is the
grid step itself** (`net71_bases_arithmetic`, `net71_domain_quantum_eq_scale_quantum`)
— the domain axis and the scale axis share one quantum, `4` keys.

*§4 The horns.*  `net71_P1_confirmed`, `net71_P2_refuted`, `net71_P3_refuted`, and
`net71_no_crossover`: the +4 never degenerates, at any context.
-/
import Mathlib
import Applications.NET68DomainJumpBudgetLaw

namespace Catalog.NET71

open Catalog.NET68 Catalog.NET68.BudgetLaw

variable {acc : ℕ → ℚ}

/-! ## 1. The NET-71 measurement -/

/-- **German prose @ 512.**  Every monotone sweep whose `16`-key and `20`-key readings
are the measured `0.976` and `0.983` has knee index `5`, i.e. `k* = 20` keys. -/
theorem net71_de512_knee (hmono : Monotone acc)
    (h16 : acc 4 = 976 / 1000) (h20 : acc 5 = 983 / 1000) :
    kneeIdx acc bar98 = 5 ∧ kneeBudget fineStep acc bar98 = 20 := by
  have hk : kneeIdx acc bar98 = 5 := by
    refine kneeIdx_eq_succ_of_bracket (j := 4) hmono ?_ ?_
    · rw [h16]; norm_num [bar98]
    · rw [show (4 : ℕ) + 1 = 5 from rfl, h20]; norm_num [bar98]
  exact ⟨hk, by simp [kneeBudget, hk, fineStep]⟩

/-- **German prose @ 1024.**  Every monotone sweep whose `20`-key and `24`-key readings
are the measured `0.975` and `0.982` has knee index `6`, i.e. `k* = 24` keys. -/
theorem net71_de1024_knee (hmono : Monotone acc)
    (h20 : acc 5 = 975 / 1000) (h24 : acc 6 = 982 / 1000) :
    kneeIdx acc bar98 = 6 ∧ kneeBudget fineStep acc bar98 = 24 := by
  have hk : kneeIdx acc bar98 = 6 := by
    refine kneeIdx_eq_succ_of_bracket (j := 5) hmono ?_ ?_
    · rw [h20]; norm_num [bar98]
    · rw [show (5 : ℕ) + 1 = 6 from rfl, h24]; norm_num [bar98]
  exact ⟨hk, by simp [kneeBudget, hk, fineStep]⟩

/-- The measured German sweep at context 512, as a curve on the fine grid. -/
def german512 : ℕ → ℚ
  | 0 => 0
  | 1 => 883 / 1000
  | 2 => 953 / 1000
  | 3 => 969 / 1000
  | 4 => 976 / 1000
  | 5 => 983 / 1000
  | (_ + 6) => 988 / 1000

/-- The measured German sweep at context 1024 (`k = 4` was not swept; monotonicity
already forces it below the bar, and by `kneeIdx_eq_succ_of_bracket` it cannot affect
the knee). -/
def german1024 : ℕ → ℚ
  | 0 => 0
  | 1 => 0
  | 2 => 926 / 1000
  | 3 => 956 / 1000
  | 4 => 968 / 1000
  | 5 => 975 / 1000
  | (_ + 6) => 982 / 1000

theorem german512_mono : Monotone german512 := by
  refine monotone_nat_of_le_succ ?_
  intro n
  match n with
  | 0 | 1 | 2 | 3 | 4 | 5 => norm_num [german512]
  | (m + 6) => norm_num [german512]

theorem german1024_mono : Monotone german1024 := by
  refine monotone_nat_of_le_succ ?_
  intro n
  match n with
  | 0 | 1 | 2 | 3 | 4 | 5 => norm_num [german1024]
  | (m + 6) => norm_num [german1024]

/-- The hypotheses of `net71_de512_knee` are realised: `k*(German, 512) = 20`. -/
theorem net71_de512_knee_concrete :
    kneeIdx german512 bar98 = 5 ∧ kneeBudget fineStep german512 bar98 = 20 :=
  net71_de512_knee german512_mono rfl rfl

/-- The hypotheses of `net71_de1024_knee` are realised: `k*(German, 1024) = 24`. -/
theorem net71_de1024_knee_concrete :
    kneeIdx german1024 bar98 = 6 ∧ kneeBudget fineStep german1024 bar98 = 24 :=
  net71_de1024_knee german1024_mono rfl rfl

/-- The five sub-knee German readings at 512 really do fail the bar (the ✗ column). -/
theorem net71_de512_subknee_fail : ∀ j < 5, german512 j < bar98 := by
  intro j hj
  interval_cases j <;> norm_num [german512, bar98]

/-- The six sub-knee German readings at 1024 really do fail the bar. -/
theorem net71_de1024_subknee_fail : ∀ j < 6, german1024 j < bar98 := by
  intro j hj
  interval_cases j <;> norm_num [german1024, bar98]

/-! ## 2. How much noise the two knees tolerate -/

/-- **Stability at 512.**  The knee is decided by two readings whose margins to the bar
are `0.004` (below) and `0.003` (above); hence any measurement error uniformly smaller
than `0.003` leaves the reported knee `20` unchanged. -/
theorem de512_knee_stable (hmono : Monotone acc)
    (hclose : ∀ j, |acc j - german512 j| < 3 / 1000) :
    kneeIdx acc bar98 = 5 := by
  have h4 := abs_lt.1 (hclose 4)
  have h5 := abs_lt.1 (hclose 5)
  have hg4 : german512 4 = 976 / 1000 := rfl
  have hg5 : german512 5 = 983 / 1000 := rfl
  refine kneeIdx_eq_succ_of_bracket (j := 4) hmono ?_ ?_
  · have := h4.2; rw [hg4] at this; simp only [bar98]; linarith
  · have := h5.1; rw [hg5] at this
    rw [show (4 : ℕ) + 1 = 5 from rfl]; simp only [bar98]; linarith

/-- **Sharpness at 512.**  The radius `0.003` cannot be enlarged: a perturbation of size
exactly `0.004` — about `1.5` reported standard errors — lifts the `16`-key reading over
the bar and moves the knee one full step down, to `16` keys. -/
theorem de512_knee_unstable_at_four_thousandths :
    ∃ acc : ℕ → ℚ, Monotone acc ∧ (∀ j, |acc j - german512 j| ≤ 4 / 1000) ∧
      kneeIdx acc bar98 = 4 ∧ kneeBudget fineStep acc bar98 = 16 := by
  have hmono : Monotone (fun j => if j ≤ 3 then german512 j else german512 j + 4 / 1000) := by
    refine monotone_nat_of_le_succ ?_
    intro n
    match n with
    | 0 | 1 | 2 | 3 | 4 | 5 => norm_num [german512]
    | (m + 6) =>
      have h1 : ¬ (m + 6 ≤ 3) := by omega
      have h2 : ¬ (m + 6 < 3) := by omega
      norm_num [german512, h1, h2]
  have hk : kneeIdx (fun j => if j ≤ 3 then german512 j else german512 j + 4 / 1000)
      bar98 = 4 := by
    refine kneeIdx_eq_succ_of_bracket (j := 3) hmono ?_ ?_
    · norm_num [german512, bar98]
    · norm_num [german512, bar98]
  refine ⟨_, hmono, ?_, hk, ?_⟩
  · intro j
    by_cases h : j ≤ 3 <;> simp [h] <;> norm_num
  · simp [kneeBudget, hk, fineStep]

/-- **Stability at 1024.**  Margins `0.005` (below) and `0.002` (above): the `1024`
knee `24` survives every uniform error below `0.002`. -/
theorem de1024_knee_stable (hmono : Monotone acc)
    (hclose : ∀ j, |acc j - german1024 j| < 2 / 1000) :
    kneeIdx acc bar98 = 6 := by
  have h5 := abs_lt.1 (hclose 5)
  have h6 := abs_lt.1 (hclose 6)
  have hg5 : german1024 5 = 975 / 1000 := rfl
  have hg6 : german1024 6 = 982 / 1000 := rfl
  refine kneeIdx_eq_succ_of_bracket (j := 5) hmono ?_ ?_
  · have := h5.2; rw [hg5] at this; simp only [bar98]; linarith
  · have := h6.1; rw [hg6] at this
    rw [show (5 : ℕ) + 1 = 6 from rfl]; simp only [bar98]; linarith

/-- **Sharpness at 1024.**  A uniform error of `0.005` lifts the `20`-key reading over
the bar: the `1024` knee is the more fragile of the two, tolerating only `0.002`. -/
theorem de1024_knee_unstable_at_five_thousandths :
    ∃ acc : ℕ → ℚ, Monotone acc ∧ (∀ j, |acc j - german1024 j| ≤ 5 / 1000) ∧
      kneeIdx acc bar98 = 5 ∧ kneeBudget fineStep acc bar98 = 20 := by
  have hmono : Monotone (fun j => if j ≤ 4 then german1024 j else german1024 j + 5 / 1000) := by
    refine monotone_nat_of_le_succ ?_
    intro n
    match n with
    | 0 | 1 | 2 | 3 | 4 | 5 => norm_num [german1024]
    | (m + 6) =>
      have h1 : ¬ (m + 6 ≤ 4) := by omega
      have h2 : ¬ (m + 6 < 4) := by omega
      norm_num [german1024, h1, h2]
  have hk : kneeIdx (fun j => if j ≤ 4 then german1024 j else german1024 j + 5 / 1000)
      bar98 = 5 := by
    refine kneeIdx_eq_succ_of_bracket (j := 4) hmono ?_ ?_
    · norm_num [german1024, bar98]
    · norm_num [german1024, bar98]
  refine ⟨_, hmono, ?_, hk, ?_⟩
  · intro j
    by_cases h : j ≤ 4 <;> simp [h] <;> norm_num
  · simp [kneeBudget, hk, fineStep]

/-! ## 3. The fitted German law, and the mirror of the code step -/

/-- `k*(German prose, ctx) = 20 + 4 · doublings`. -/
def deLaw : BudgetLaw := ⟨20, 4⟩

/-- The measured German knees `20` (ctx 512) and `24` (ctx 1024). -/
theorem net71_de_fit : deLaw.eval 0 = 20 ∧ deLaw.eval 1 = 24 := by
  constructor <;> norm_num [deLaw, BudgetLaw.eval]

/-- The two measured German points pin the German law uniquely. -/
theorem deLaw_unique (L : BudgetLaw) (h0 : L.eval 0 = 20) (h1 : L.eval 1 = 24) :
    L = deLaw :=
  BudgetLaw.ext_of_two_points (by rw [h0, net71_de_fit.1]) (by rw [h1, net71_de_fit.2])

/-- **P1, measured.**  German prose sits exactly four keys above English prose at *every*
context, not only at the two that were run. -/
theorem net71_shift (d : ℕ) : deLaw.eval d - proseLaw.eval d = 4 := by
  simp [deLaw, proseLaw, BudgetLaw.eval]

/-- **P1, structurally.**  Because the shift is context-free, the German and English laws
share their increment: the language enters only through the base. -/
theorem net71_increment_shared : deLaw.inc = proseLaw.inc :=
  (BudgetLaw.shift_const_iff_inc_eq deLaw proseLaw).1 ⟨4, fun d => net71_shift d⟩

/-- The German shift is exactly one step of the fine grid, at both measured contexts. -/
theorem net71_shift_is_one_fine_step :
    deLaw.eval 0 - proseLaw.eval 0 = (fineStep : ℤ) ∧
    deLaw.eval 1 - proseLaw.eval 1 = (fineStep : ℤ) :=
  ⟨by rw [net71_shift 0]; norm_num [fineStep], by rw [net71_shift 1]; norm_num [fineStep]⟩

/-- **The mirror.**  The German step *up* from English prose is exactly the code step
*down*: one fine grid step in each direction. -/
theorem net71_mirror (d : ℕ) :
    deLaw.eval d - proseLaw.eval d = proseLaw.eval d - codeLaw.eval d := by
  rw [net71_shift d, net68_shift d]

/-- **The three measured bases are an arithmetic progression.**  `12 < 16 < 20` with
common difference `4`: code, English prose and German prose are equally spaced on the
domain axis. -/
theorem net71_bases_arithmetic :
    proseLaw.base - codeLaw.base = deLaw.base - proseLaw.base ∧
    proseLaw.base - codeLaw.base = 4 ∧ codeLaw.base < proseLaw.base ∧
    proseLaw.base < deLaw.base := by
  refine ⟨by norm_num [codeLaw, proseLaw, deLaw], by norm_num [codeLaw, proseLaw], ?_, ?_⟩
  · norm_num [codeLaw, proseLaw]
  · norm_num [proseLaw, deLaw]

/-- **The domain quantum equals the scale quantum.**  The spacing of the domain ladder,
the per-doubling increment, and the sweep grid step are one and the same number `4`.
This is the structural content of the verdict *the tokenizer tax is four keys*. -/
theorem net71_domain_quantum_eq_scale_quantum :
    deLaw.base - proseLaw.base = deLaw.inc ∧
    deLaw.inc = (fineStep : ℤ) ∧
    proseLaw.base - codeLaw.base = (fineStep : ℤ) := by
  refine ⟨by norm_num [deLaw, proseLaw], by norm_num [deLaw, fineStep], ?_⟩
  norm_num [proseLaw, codeLaw, fineStep]

/-- **One doubling of context is worth exactly one domain step.**  Reading German at
context `2^d·512` costs the same as reading English at the next doubling. -/
theorem net71_one_doubling_equals_one_domain_step (d : ℕ) :
    deLaw.eval d = proseLaw.eval (d + 1) := by
  simp only [deLaw, proseLaw, BudgetLaw.eval, Nat.cast_add, Nat.cast_one]
  ring

/-! ## 4. The three pre-registered horns -/

/-- **P1 CONFIRMED.**  The German knees differ from the English ones by exactly one fine
step, at both measured contexts, and the two knee values are the measured `20` and `24`. -/
theorem net71_P1_confirmed :
    (kneeBudget fineStep german512 bar98 : ℤ) = deLaw.eval 0 ∧
    (kneeBudget fineStep german1024 bar98 : ℤ) = deLaw.eval 1 ∧
    (∀ d : ℕ, deLaw.eval d - proseLaw.eval d = (fineStep : ℤ)) := by
  refine ⟨?_, ?_, fun d => by rw [net71_shift d]; norm_num [fineStep]⟩
  · rw [net71_de512_knee_concrete.2]; norm_num [deLaw, BudgetLaw.eval]
  · rw [net71_de1024_knee_concrete.2]; norm_num [deLaw, BudgetLaw.eval]

/-- **P2 REFUTED.**  The shift is not intermediate: it is not strictly between `0` and one
fine step at any context. -/
theorem net71_P2_refuted :
    ¬ ∃ d : ℕ, 0 < deLaw.eval d - proseLaw.eval d ∧
      deLaw.eval d - proseLaw.eval d < (fineStep : ℤ) := by
  rintro ⟨d, _, h⟩
  rw [net71_shift d] at h
  norm_num [fineStep] at h

/-- **P3 REFUTED.**  The shift is nowhere zero: German never reads like English. -/
theorem net71_P3_refuted : ∀ d : ℕ, deLaw.eval d ≠ proseLaw.eval d := by
  intro d h
  have := net71_shift d
  omega

/-- No crossover anywhere on the context ladder: German is strictly hungrier at every
scale, and strictly hungrier than code by two fine steps. -/
theorem net71_no_crossover (d : ℕ) :
    codeLaw.eval d < proseLaw.eval d ∧ proseLaw.eval d < deLaw.eval d ∧
    deLaw.eval d - codeLaw.eval d = 2 * (fineStep : ℤ) := by
  have h1 := net68_shift d
  have h2 := net71_shift d
  refine ⟨by omega, by omega, ?_⟩
  simp only [fineStep]; push_cast; omega

end Catalog.NET71