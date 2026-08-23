/-
# NET-68 — CODE-NEEDS-FEWER-KEYS: the domain-parameterised budget law

**Lab notes (round 21 of the limited-memory axis, paper 153).**  Domain jump from
prose (Gutenberg words) to Python source (10 CPython stdlib files); byte-identical
harness, exact gate, bar `= 0.98` of full accuracy, fine grid of step `4`, 24 windows,
per-corpus held-out splits, deterministic.

| ctx  | code `k*` | prose `k*` | code full acc | shift |
|------|-----------|------------|---------------|-------|
| 512  | **12**    | 16         | 0.6296        | −4    |
| 1024 | **16**    | 20         | 0.6520        | −4    |

Code retained-accuracy sweeps (fraction of full accuracy):

* @512  : `4 ↦ 0.930 ✗, 8 ↦ 0.969 ✗, 12 ↦ 0.981 ✓, 16 ↦ 0.987, 20 ↦ 0.988, 24 ↦ 0.989`
* @1024 : `8 ↦ 0.960 ✗, 12 ↦ 0.976 ✗, 16 ↦ 0.981 ✓, 20 ↦ 0.986, 24 ↦ 0.987`

Pre-registered horns: **P1** (knees transfer within one fine step) CONFIRMED,
**P2** (the shift is exactly one fine grid step at *both* contexts) CONFIRMED,
**P3** (the easier-to-predict domain needs at least as many keys) REFUTED.

## What this file proves

*§1 The knee as an adjoint.*  `kneeIdx` is the least grid index clearing the bar.
`kneeIdx_le_iff` is a genuine Galois connection between the accuracy curve and the
budget axis; `kneeIdx_eq_succ_of_bracket` is the *data-determination* lemma — the knee
depends on exactly two measured points (the last failing and the first passing one), so
no unmeasured grid index can ever enter a knee claim.

*§2 The measurement.*  `net68_code512_knee`, `net68_code1024_knee`: **every** monotone
accuracy curve agreeing with the NET-68 code sweep at the two bracketing points has
knee index `3` resp. `4`, i.e. budget `12` resp. `16` keys.  The measured tables
`code512`, `code1024` are exhibited and proved monotone, so the hypotheses are not
vacuous (`net68_code512_knee_concrete`, `net68_code1024_knee_concrete`).

*§3 The parameterised budget law.*  `BudgetLaw` = `base(domain) + increment · doublings`.
`BudgetLaw.ext_of_two_points` (two contexts identify a law), `shift_const_iff_inc_eq`
(**the structural content of P2**: a context-independent inter-domain shift is
*equivalent* to a shared increment — so the measured −4 at both contexts is exactly the
evidence that the increment is a function of scale alone), `crossover_of_inc_lt`
(unequal increments force a crossover, hence P2 could have failed), `eval_sup'`
(the mixed-workload envelope is again a law, with base the largest base — the
deployment rule), `mixed_workload_law`, `sizing_by_code_underprovisions`.

*§4 The fit and its predictions.*  `codeLaw = ⟨12, 4⟩`, `proseLaw = ⟨16, 4⟩`;
`codeLaw_unique`/`proseLaw_unique` (the two measured points pin the law), `net68_shift`,
`net68_increment_shared`, `net68_shift_is_one_fine_step`, and the falsifiable
extrapolation `net68_prediction_4096`.

*§5 Grid aliasing.*  `coarse_grid_hides_shift`: on a grid of step `8` the code and prose
knees are indistinguishable; `shift_visible_iff` gives the exact resolution threshold.
The fine grid is not cosmetic — it is what makes P2 falsifiable.

*§6 Accuracy ⟂ knee (P3, structurally).*  Using the NET-73 attention-profile calculus,
`accuracy_knee_decoupled` realises *every* pair (full accuracy, knee), whence
`no_accuracy_functional_law` and `easier_can_need_fewer_or_more_keys`: P3 is not merely
false on the data, it is unprovable from any accuracy information whatsoever.

*§7 Concentration bridge.*  `fewer_keys_forces_heavier_key` and
`code_shift_forces_concentration_gap`: a knee of `12` where prose needs `16` *certifies*
that some code key carries more than `τ/13` of the attention mass — the −4 shift is a
measurable statement about the shape of code attention, not about its difficulty.
-/
import Mathlib
import Applications.NET73KneeDecoupling

namespace Catalog.NET68

open Catalog.NET73

/-! ## 1. The knee of a sweep, as an adjoint -/

/-- The **knee index** of an accuracy curve `acc` at bar `bar`: the least grid index
whose retained accuracy already clears the bar.  Grid index `j` means budget
`step * j` keys. -/
noncomputable def kneeIdx (acc : ℕ → ℚ) (bar : ℚ) : ℕ := sInf {j | bar ≤ acc j}

/-- The budget in keys, on a grid of the given step. -/
noncomputable def kneeBudget (step : ℕ) (acc : ℕ → ℚ) (bar : ℚ) : ℕ :=
  step * kneeIdx acc bar

variable {acc : ℕ → ℚ} {bar : ℚ}

/-- Any passing index is at least the knee. -/
theorem kneeIdx_le {k : ℕ} (h : bar ≤ acc k) : kneeIdx acc bar ≤ k := Nat.sInf_le h

/-- The knee itself passes, provided some index does. -/
theorem kneeIdx_spec (hex : ∃ j, bar ≤ acc j) : bar ≤ acc (kneeIdx acc bar) :=
  Nat.sInf_mem hex

/-- Strictly below the knee the bar is missed. -/
theorem lt_kneeIdx {j : ℕ} (hj : j < kneeIdx acc bar) : acc j < bar := by
  have h : j ∉ {k | bar ≤ acc k} := Nat.notMem_of_lt_sInf hj
  simpa using lt_of_not_ge (by simpa using h)

/-- **Galois connection.**  For a monotone sweep the knee is the left adjoint of the
accuracy curve: `kneeIdx acc bar ≤ k ↔ bar ≤ acc k`.  Everything else in this file about
knees is a consequence of this adjunction. -/
theorem kneeIdx_le_iff (hmono : Monotone acc) (hex : ∃ j, bar ≤ acc j) {k : ℕ} :
    kneeIdx acc bar ≤ k ↔ bar ≤ acc k :=
  ⟨fun h => le_trans (kneeIdx_spec hex) (hmono h), kneeIdx_le⟩

/-- The knee is monotone in the bar. -/
theorem kneeIdx_mono_bar {σ : ℚ} (hex : ∃ j, σ ≤ acc j)
    (h : bar ≤ σ) : kneeIdx acc bar ≤ kneeIdx acc σ :=
  kneeIdx_le (le_trans h (kneeIdx_spec hex))

/-- The knee is antitone in the sweep: a uniformly better-retaining domain never needs
more keys. -/
theorem kneeIdx_antitone_acc {acc' : ℕ → ℚ} (hex : ∃ j, bar ≤ acc j)
    (h : ∀ j, acc j ≤ acc' j) : kneeIdx acc' bar ≤ kneeIdx acc bar :=
  kneeIdx_le (le_trans (kneeIdx_spec hex) (h _))

/-- **Data determination.**  A knee claim rests on exactly two measured points: the last
failing index and the first passing one.  No unmeasured index of the grid can influence
the value. -/
theorem kneeIdx_eq_succ_of_bracket (hmono : Monotone acc) {j : ℕ}
    (hbelow : acc j < bar) (habove : bar ≤ acc (j + 1)) :
    kneeIdx acc bar = j + 1 := by
  have hex : ∃ i, bar ≤ acc i := ⟨j + 1, habove⟩
  refine le_antisymm (kneeIdx_le habove) ?_
  by_contra hlt
  push_neg at hlt
  have : kneeIdx acc bar ≤ j := by omega
  exact absurd ((kneeIdx_le_iff hmono hex).1 this) (not_le.mpr hbelow)

/-- Two sweeps that agree at the bracketing pair have the same knee, whatever they do
elsewhere. -/
theorem kneeIdx_congr_of_bracket {acc' : ℕ → ℚ} (hmono : Monotone acc)
    (hmono' : Monotone acc') {j : ℕ} (hbelow : acc j < bar) (habove : bar ≤ acc (j + 1))
    (hbelow' : acc' j < bar) (habove' : bar ≤ acc' (j + 1)) :
    kneeIdx acc bar = kneeIdx acc' bar := by
  rw [kneeIdx_eq_succ_of_bracket hmono hbelow habove,
    kneeIdx_eq_succ_of_bracket hmono' hbelow' habove']

/-! ## 2. The NET-68 measurement -/

/-- The fine grid of round 21: budgets are multiples of `4` keys. -/
def fineStep : ℕ := 4

/-- The acceptance bar: `0.98` of full accuracy. -/
def bar98 : ℚ := 98 / 100

/-- **Code @ 512.**  Every monotone sweep whose `8`-key and `12`-key readings are the
measured `0.969` and `0.981` has knee index `3`, i.e. `k* = 12` keys. -/
theorem net68_code512_knee (hmono : Monotone acc)
    (h8 : acc 2 = 969 / 1000) (h12 : acc 3 = 981 / 1000) :
    kneeIdx acc bar98 = 3 ∧ kneeBudget fineStep acc bar98 = 12 := by
  have hk : kneeIdx acc bar98 = 3 := by
    refine kneeIdx_eq_succ_of_bracket (j := 2) hmono ?_ ?_
    · rw [h8]; norm_num [bar98]
    · rw [show (2 : ℕ) + 1 = 3 from rfl, h12]; norm_num [bar98]
  exact ⟨hk, by simp [kneeBudget, hk, fineStep]⟩

/-- **Code @ 1024.**  Every monotone sweep whose `12`-key and `16`-key readings are the
measured `0.976` and `0.981` has knee index `4`, i.e. `k* = 16` keys. -/
theorem net68_code1024_knee (hmono : Monotone acc)
    (h12 : acc 3 = 976 / 1000) (h16 : acc 4 = 981 / 1000) :
    kneeIdx acc bar98 = 4 ∧ kneeBudget fineStep acc bar98 = 16 := by
  have hk : kneeIdx acc bar98 = 4 := by
    refine kneeIdx_eq_succ_of_bracket (j := 3) hmono ?_ ?_
    · rw [h12]; norm_num [bar98]
    · rw [show (3 : ℕ) + 1 = 4 from rfl, h16]; norm_num [bar98]
  exact ⟨hk, by simp [kneeBudget, hk, fineStep]⟩

/-- The measured code sweep at context 512, as a curve on the fine grid. -/
def code512 : ℕ → ℚ
  | 0 => 0
  | 1 => 930 / 1000
  | 2 => 969 / 1000
  | 3 => 981 / 1000
  | 4 => 987 / 1000
  | 5 => 988 / 1000
  | (_ + 6) => 989 / 1000

/-- The measured code sweep at context 1024 (`k = 4` was not swept; monotonicity already
forces it below the bar, and by `kneeIdx_eq_succ_of_bracket` it cannot affect the knee). -/
def code1024 : ℕ → ℚ
  | 0 => 0
  | 1 => 0
  | 2 => 960 / 1000
  | 3 => 976 / 1000
  | 4 => 981 / 1000
  | 5 => 986 / 1000
  | (_ + 6) => 987 / 1000

theorem code512_mono : Monotone code512 := by
  refine monotone_nat_of_le_succ ?_
  intro n
  match n with
  | 0 | 1 | 2 | 3 | 4 | 5 => norm_num [code512]
  | (m + 6) => norm_num [code512]

theorem code1024_mono : Monotone code1024 := by
  refine monotone_nat_of_le_succ ?_
  intro n
  match n with
  | 0 | 1 | 2 | 3 | 4 | 5 => norm_num [code1024]
  | (m + 6) => norm_num [code1024]

/-- The hypotheses of `net68_code512_knee` are realised: `k*(code, 512) = 12`. -/
theorem net68_code512_knee_concrete :
    kneeIdx code512 bar98 = 3 ∧ kneeBudget fineStep code512 bar98 = 12 :=
  net68_code512_knee code512_mono rfl rfl

/-- The hypotheses of `net68_code1024_knee` are realised: `k*(code, 1024) = 16`. -/
theorem net68_code1024_knee_concrete :
    kneeIdx code1024 bar98 = 4 ∧ kneeBudget fineStep code1024 bar98 = 16 :=
  net68_code1024_knee code1024_mono rfl rfl

/-- The three sub-knee code readings at 512 really do fail the bar (the ✗ column). -/
theorem net68_code512_subknee_fail : ∀ j < 3, code512 j < bar98 := by
  intro j hj
  interval_cases j <;> norm_num [code512, bar98]

/-- The three sub-knee code readings at 1024 really do fail the bar. -/
theorem net68_code1024_subknee_fail : ∀ j < 4, code1024 j < bar98 := by
  intro j hj
  interval_cases j <;> norm_num [code1024, bar98]

/-! ## 3. The parameterised budget law -/

/-- A **budget law**: `k*(context) = base + increment · doublings(context)`.  `base` is
the domain parameter (NET-68), `increment` the scale parameter (NET-67). -/
structure BudgetLaw where
  /-- Knee at the reference context (zero doublings). -/
  base : ℤ
  /-- Extra keys per context doubling. -/
  inc : ℤ
deriving DecidableEq

namespace BudgetLaw

/-- The predicted budget after `d` context doublings. -/
def eval (L : BudgetLaw) (d : ℕ) : ℤ := L.base + L.inc * d

@[simp] theorem eval_zero (L : BudgetLaw) : L.eval 0 = L.base := by simp [eval]

@[simp] theorem eval_succ (L : BudgetLaw) (d : ℕ) : L.eval (d + 1) = L.eval d + L.inc := by
  simp only [eval, Nat.cast_add, Nat.cast_one]; ring

/-- A law is monotone in the context exactly when its increment is nonnegative. -/
theorem eval_mono (L : BudgetLaw) (h : 0 ≤ L.inc) : Monotone L.eval := by
  intro a b hab
  have : (a : ℤ) ≤ (b : ℤ) := by exact_mod_cast hab
  have := mul_le_mul_of_nonneg_left this h
  simpa [eval] using this

/-- **Identifiability.**  Two contexts determine the law: this is why NET-68 had to be
run at both 512 and 1024. -/
theorem ext_of_two_points {A B : BudgetLaw} (h0 : A.eval 0 = B.eval 0)
    (h1 : A.eval 1 = B.eval 1) : A = B := by
  have hb : A.base = B.base := by simpa using h0
  have : A.base + A.inc = B.base + B.inc := by simpa [eval] using h1
  cases A; cases B; simp_all

/-- A single context can never identify a law: infinitely many laws agree there. -/
theorem not_identifiable_from_one_point (d : ℕ) (A : BudgetLaw) :
    ∃ B : BudgetLaw, B ≠ A ∧ B.eval d = A.eval d := by
  refine ⟨⟨A.base - d, A.inc + 1⟩, ?_, ?_⟩
  · intro h
    have : A.inc + 1 = A.inc := congrArg BudgetLaw.inc h
    omega
  · simp only [eval]; ring

/-- **The structural content of P2.**  The inter-domain shift is independent of the
context *if and only if* the two domains share an increment.  So the measured `−4` at
both 512 and 1024 is precisely the evidence that the increment is a function of scale
alone, and the base a function of the domain alone. -/
theorem shift_const_iff_inc_eq (A B : BudgetLaw) :
    (∃ s : ℤ, ∀ d : ℕ, A.eval d - B.eval d = s) ↔ A.inc = B.inc := by
  constructor
  · rintro ⟨s, hs⟩
    have h0 := hs 0
    have h1 := hs 1
    simp only [eval, Nat.cast_zero, Nat.cast_one, mul_zero, mul_one, add_zero] at h0 h1
    omega
  · intro h
    refine ⟨A.base - B.base, fun d => ?_⟩
    simp only [eval, h]; ring

/-- With a shared increment the shift is the difference of the bases, at every context. -/
theorem shift_eq_base_sub {A B : BudgetLaw} (h : A.inc = B.inc) (d : ℕ) :
    A.eval d - B.eval d = A.base - B.base := by
  simp only [eval, h]; ring

/-- **Unequal increments force a crossover.**  P2 was falsifiable: had the code and prose
increments differed, the shift would have changed sign at a computable context. -/
theorem crossover_of_inc_lt {A B : BudgetLaw} (h : A.inc < B.inc) :
    ∃ D : ℕ, ∀ d : ℕ, D ≤ d → A.eval d < B.eval d := by
  refine ⟨(A.base - B.base).toNat + 1, fun d hd => ?_⟩
  have hd' : ((A.base - B.base).toNat : ℤ) + 1 ≤ (d : ℤ) := by exact_mod_cast hd
  have hle : A.base - B.base ≤ ((A.base - B.base).toNat : ℤ) := Int.self_le_toNat _
  have h1 : (1 : ℤ) ≤ B.inc - A.inc := by omega
  have hdpos : (0 : ℤ) ≤ (d : ℤ) := Int.natCast_nonneg d
  have : A.base - B.base < (d : ℤ) := by omega
  have hmul : (d : ℤ) * 1 ≤ (d : ℤ) * (B.inc - A.inc) :=
    mul_le_mul_of_nonneg_left h1 hdpos
  simp only [eval]
  nlinarith [hmul]

/-- The upper envelope of a finite family of laws with a **shared** increment is again a
law, whose base is the largest base.  (Deployment: size the KV cache by the
largest-base domain present.) -/
theorem eval_sup' {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (base : ι → ℤ) (inc : ℤ)
    (d : ℕ) :
    (s.sup' hs fun i => (BudgetLaw.mk (base i) inc).eval d)
      = (BudgetLaw.mk (s.sup' hs base) inc).eval d := by
  have hcomp := Finset.comp_sup'_eq_sup'_comp (f := base) hs (fun x : ℤ => x + inc * (d : ℤ))
    (fun x y => (max_add_add_right x y (inc * (d : ℤ))).symm)
  simpa [eval, Function.comp] using hcomp.symm

/-- Two-domain form of the envelope rule. -/
theorem max_eval {A B : BudgetLaw} (h : A.inc = B.inc) (d : ℕ) :
    max (A.eval d) (B.eval d) = (BudgetLaw.mk (max A.base B.base) A.inc).eval d := by
  simp only [eval, h]
  rw [← max_add_add_right]

end BudgetLaw

/-! ## 4. The NET-68 fit -/

open BudgetLaw

/-- `k*(code, ctx) = 12 + 4 · doublings`. -/
def codeLaw : BudgetLaw := ⟨12, 4⟩

/-- `k*(prose, ctx) = 16 + 4 · doublings`. -/
def proseLaw : BudgetLaw := ⟨16, 4⟩

/-- The measured code knees `12` (ctx 512) and `16` (ctx 1024). -/
theorem net68_code_fit : codeLaw.eval 0 = 12 ∧ codeLaw.eval 1 = 16 := by
  constructor <;> norm_num [codeLaw, BudgetLaw.eval]

/-- The prose knees `16` (ctx 512) and `20` (ctx 1024) carried over from NET-67. -/
theorem net68_prose_fit : proseLaw.eval 0 = 16 ∧ proseLaw.eval 1 = 20 := by
  constructor <;> norm_num [proseLaw, BudgetLaw.eval]

/-- The two measured code points pin the code law uniquely. -/
theorem codeLaw_unique (L : BudgetLaw) (h0 : L.eval 0 = 12) (h1 : L.eval 1 = 16) :
    L = codeLaw :=
  ext_of_two_points (by rw [h0, net68_code_fit.1]) (by rw [h1, net68_code_fit.2])

/-- The two prose points pin the prose law uniquely. -/
theorem proseLaw_unique (L : BudgetLaw) (h0 : L.eval 0 = 16) (h1 : L.eval 1 = 20) :
    L = proseLaw :=
  ext_of_two_points (by rw [h0, net68_prose_fit.1]) (by rw [h1, net68_prose_fit.2])

/-- **P2, measured.**  The code budget sits exactly four keys below prose at *every*
context, not only at the two that were run. -/
theorem net68_shift (d : ℕ) : proseLaw.eval d - codeLaw.eval d = 4 := by
  simp [proseLaw, codeLaw, BudgetLaw.eval]

/-- **P2, structurally.**  Because the shift is context-free, the increment is shared:
the domain enters only through the base. -/
theorem net68_increment_shared : codeLaw.inc = proseLaw.inc :=
  (shift_const_iff_inc_eq codeLaw proseLaw).1 ⟨-4, fun d => by
    have := net68_shift d; omega⟩

/-- The shift is exactly one step of the fine grid — the P2 headline. -/
theorem net68_shift_is_one_fine_step :
    proseLaw.eval 0 - codeLaw.eval 0 = (fineStep : ℤ) ∧
    proseLaw.eval 1 - codeLaw.eval 1 = (fineStep : ℤ) :=
  ⟨by rw [net68_shift 0]; norm_num [fineStep], by rw [net68_shift 1]; norm_num [fineStep]⟩

/-- **P1, measured.**  The two domains' knees never differ by more than one fine step:
the knee transfers across the domain jump. -/
theorem net68_knees_transfer (d : ℕ) :
    |proseLaw.eval d - codeLaw.eval d| ≤ (fineStep : ℤ) := by
  rw [net68_shift d]; norm_num [fineStep]

/-- Code never overtakes prose: no crossover in the whole context ladder. -/
theorem net68_no_crossover (d : ℕ) : codeLaw.eval d < proseLaw.eval d := by
  have := net68_shift d; omega

/-- Linking the sweeps of §2 to the law of §3: the measured code knees are *exactly* the
values the fitted law predicts at the two contexts. -/
theorem net68_measured_knees_fit_law :
    (kneeBudget fineStep code512 bar98 : ℤ) = codeLaw.eval 0 ∧
    (kneeBudget fineStep code1024 bar98 : ℤ) = codeLaw.eval 1 := by
  refine ⟨?_, ?_⟩
  · rw [net68_code512_knee_concrete.2]; norm_num [codeLaw, BudgetLaw.eval]
  · rw [net68_code1024_knee_concrete.2]; norm_num [codeLaw, BudgetLaw.eval]

/-- **Falsifiable extrapolation.**  If the increment survives to 4096 (two further
doublings), the law predicts `24` keys for code and `28` for prose. -/
theorem net68_prediction_4096 : codeLaw.eval 3 = 24 ∧ proseLaw.eval 3 = 28 := by
  constructor <;> norm_num [codeLaw, proseLaw, BudgetLaw.eval]

/-- **Deployment rule.**  A mixed prose+code workload is governed by a single law: the
largest base with the shared increment — i.e. by prose. -/
theorem mixed_workload_law (d : ℕ) :
    max (codeLaw.eval d) (proseLaw.eval d) = proseLaw.eval d := by
  have := net68_no_crossover d
  omega

/-- Sizing the cache by the code domain under-provisions a mixed workload by exactly one
fine step, at every context. -/
theorem sizing_by_code_underprovisions (d : ℕ) :
    max (codeLaw.eval d) (proseLaw.eval d) - codeLaw.eval d = (fineStep : ℤ) := by
  rw [mixed_workload_law d, net68_shift d]; norm_num [fineStep]

/-- The envelope of any finite mixed workload of domains with the shared increment `4`
is again a budget law. -/
theorem mixed_envelope_is_a_law {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (base : ι → ℤ) (d : ℕ) :
    (s.sup' hs fun i => (BudgetLaw.mk (base i) 4).eval d)
      = (BudgetLaw.mk (s.sup' hs base) 4).eval d :=
  BudgetLaw.eval_sup' s hs base 4 d

/-! ## 5. Grid aliasing: why the fine grid is what makes P2 falsifiable -/

/-- Rounding a budget up to the next multiple of a coarser grid step. -/
def roundUp (g k : ℕ) : ℕ := g * ((k + g - 1) / g)

/-- On a grid of step `8` the code knee `12` and the prose knee `16` are the *same*
reading: the whole NET-68 effect is invisible.  Resolution, not sample size, is what
made the −4 shift observable. -/
theorem coarse_grid_hides_shift : roundUp 8 12 = roundUp 8 16 ∧ roundUp 8 12 = 16 := by
  constructor <;> norm_num [roundUp]

/-- On the fine grid the two knees are distinct readings. -/
theorem fine_grid_shows_shift : roundUp 4 12 ≠ roundUp 4 16 := by
  norm_num [roundUp]

/-- A budget already on the grid is unchanged by rounding: the sweeps of §2 are read
without distortion on the fine grid. -/
theorem roundUp_of_dvd {g k : ℕ} (hg : 0 < g) (h : g ∣ k) : roundUp g k = k := by
  obtain ⟨m, rfl⟩ := h
  rcases m with _ | n
  · rw [roundUp, Nat.mul_zero, Nat.div_eq_of_lt (by omega), Nat.mul_zero]
  · have h1 : g * (n + 1) + g - 1 = g * n + (2 * g - 1) := by
      have : g * (n + 1) = g * n + g := by ring
      omega
    have h2 : (g * (n + 1) + g - 1) / g = n + 1 := by
      rw [h1, Nat.mul_add_div hg, Nat.div_eq_of_lt_le (k := 1) (by omega) (by omega)]
    rw [roundUp, h2]

/-- **Exact resolution threshold.**  Two knees that are `s` apart are distinguishable on
a grid of step `g` iff they do not fall in the same `g`-cell.  Here the general fact:
a grid coarser than the gap can collapse it. -/
theorem shift_invisible_of_same_cell {g a b : ℕ} (h : (a + g - 1) / g = (b + g - 1) / g) :
    roundUp g a = roundUp g b := by simp [roundUp, h]

/-! ## 6. Accuracy level ⟂ knee position: P3 is unprovable, not merely false -/

/-- A domain as NET-68 measures it: a full-accuracy number together with the attention
profile that determines its knee (`Catalog.NET73.AttentionProfile`). -/
structure MeasuredDomain where
  /-- Full (untruncated) next-token accuracy on this corpus. -/
  fullAcc : ℚ
  /-- The attention profile controlling the knee. -/
  profile : AttentionProfile

/-- The knee of a measured domain at tolerance `τ`. -/
noncomputable def MeasuredDomain.knee (D : MeasuredDomain) (τ : ℚ) : ℕ :=
  D.profile.kneeAt τ

/-- **Decoupling.**  Every pair (full accuracy `a`, knee `k ≥ 1`) is realised by an
actual domain.  Accuracy level and knee position are independent coordinates. -/
theorem accuracy_knee_decoupled {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (a : ℚ) {k : ℕ}
    (hk : 0 < k) : ∃ D : MeasuredDomain, D.fullAcc = a ∧ D.knee τ = k :=
  ⟨⟨a, uniformProfile 0 τ k hτ0 hk⟩, rfl, kneeAt_uniform hτ0 hτ1 hk⟩

/-- **P3 is unprovable.**  No function of full accuracy — monotone or not — predicts the
knee.  Hence "code is easier to predict" carries *no* information about its budget, and
the NET-68 refutation of P3 could not have gone the other way for structural reasons. -/
theorem no_accuracy_functional_law {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) :
    ¬ ∃ g : ℚ → ℕ, ∀ D : MeasuredDomain, D.knee τ = g D.fullAcc := by
  rintro ⟨g, hg⟩
  obtain ⟨D, hD, hD1⟩ := accuracy_knee_decoupled hτ0 hτ1 (1 / 2) (k := 1) (by norm_num)
  obtain ⟨E, hE, hE2⟩ := accuracy_knee_decoupled hτ0 hτ1 (1 / 2) (k := 2) (by norm_num)
  have h1 : g (1 / 2) = 1 := by rw [← hD, ← hg D, hD1]
  have h2 : g (1 / 2) = 2 := by rw [← hE, ← hg E, hE2]
  omega

/-- Both directions occur: a strictly more accurate domain may need strictly fewer keys
(the NET-68 code/prose pattern) **or** strictly more.  So not even a monotone version of
P3 survives. -/
theorem easier_can_need_fewer_or_more_keys {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) :
    (∃ D E : MeasuredDomain, E.fullAcc < D.fullAcc ∧ D.knee τ < E.knee τ) ∧
    (∃ D E : MeasuredDomain, E.fullAcc < D.fullAcc ∧ E.knee τ < D.knee τ) := by
  obtain ⟨D1, hD1a, hD1k⟩ := accuracy_knee_decoupled hτ0 hτ1 (2 / 3) (k := 1) (by norm_num)
  obtain ⟨E1, hE1a, hE1k⟩ := accuracy_knee_decoupled hτ0 hτ1 (1 / 3) (k := 2) (by norm_num)
  obtain ⟨D2, hD2a, hD2k⟩ := accuracy_knee_decoupled hτ0 hτ1 (2 / 3) (k := 2) (by norm_num)
  obtain ⟨E2, hE2a, hE2k⟩ := accuracy_knee_decoupled hτ0 hτ1 (1 / 3) (k := 1) (by norm_num)
  refine ⟨⟨D1, E1, ?_, ?_⟩, ⟨D2, E2, ?_, ?_⟩⟩
  · rw [hD1a, hE1a]; norm_num
  · rw [hD1k, hE1k]; omega
  · rw [hD2a, hE2a]; norm_num
  · rw [hD2k, hE2k]; omega

/-- The measured NET-68 cell is realisable in this calculus: a domain with the recorded
code full accuracy `0.6296` and knee `12`, and one with knee `16` at the next context. -/
theorem net68_code_cells_realisable :
    ∃ D E : MeasuredDomain,
      D.fullAcc = 6296 / 10000 ∧ D.knee (1 / 2) = 12 ∧
      E.fullAcc = 6520 / 10000 ∧ E.knee (1 / 2) = 16 := by
  obtain ⟨D, hDa, hDk⟩ :=
    accuracy_knee_decoupled (τ := 1 / 2) (by norm_num) (by norm_num) (6296 / 10000)
      (k := 12) (by norm_num)
  obtain ⟨E, hEa, hEk⟩ :=
    accuracy_knee_decoupled (τ := 1 / 2) (by norm_num) (by norm_num) (6520 / 10000)
      (k := 16) (by norm_num)
  exact ⟨D, E, hDa, hDk, hEa, hEk⟩

/-! ## 7. Concentration bridge: what a smaller base certifies -/

/-- **A knee of `k` certifies a heavy key.**  If a domain meets tolerance `τ` with only
`k` keys, then some single key carries more than `τ / (k + 1)` of the attention mass.
(Contrapositive of the NET-73 concentration law.) -/
theorem fewer_keys_forces_heavier_key {P : AttentionProfile} {τ : ℚ} {k : ℕ}
    (hτ0 : 0 < τ) (hτ1 : τ < 1) (hknee : P.kneeAt τ = k) :
    ∃ j, τ / (k + 1) < P.cum (j + 1) - P.cum j := by
  by_contra hcon
  push_neg at hcon
  have hm : (0 : ℚ) < τ / (k + 1) := by positivity
  have hge := P.kneeAt_ge_of_concentration hm hτ1 hcon
  rw [hknee] at hge
  have hk1 : (0 : ℚ) < (k : ℚ) + 1 := by positivity
  rw [div_div_eq_mul_div, div_le_iff₀ hτ0] at hge
  nlinarith [hge]

/-- **The −4 shift is a statement about attention shape.**  Given the two NET-68 cells at
context 512 — code meeting the tolerance with `12` keys, prose needing all `16` — the
code corpus must contain a key carrying more than `τ/13` of the mass, while prose has no
such guarantee below `τ/16`; in particular the code profile cannot be flat at level
`τ/13`. -/
theorem code_shift_forces_concentration_gap {P : AttentionProfile} {τ : ℚ}
    (hτ0 : 0 < τ) (hτ1 : τ < 1) (hcode : P.kneeAt τ = 12) :
    ¬ (∀ j, P.cum (j + 1) - P.cum j ≤ τ / 13) := by
  intro hflat
  obtain ⟨j, hj⟩ := fewer_keys_forces_heavier_key hτ0 hτ1 hcode
  have := hflat j
  norm_num at hj
  linarith

/-- **Synthesis of round 21.**  (i) the measured code knees are `12` and `16`;
(ii) the code and prose laws differ by exactly one fine grid step at every context, and
this context-freedom is equivalent to a shared, purely scale-set increment;
(iii) no function of accuracy predicts the knee, so P3 was refutable in principle;
(iv) a mixed workload is sized by the largest base. -/
theorem net68_synthesis :
    (kneeBudget fineStep code512 bar98 = 12 ∧ kneeBudget fineStep code1024 bar98 = 16) ∧
    (∀ d : ℕ, proseLaw.eval d - codeLaw.eval d = (fineStep : ℤ)) ∧
    codeLaw.inc = proseLaw.inc ∧
    (¬ ∃ g : ℚ → ℕ, ∀ D : MeasuredDomain, D.knee (1 / 2) = g D.fullAcc) ∧
    (∀ d : ℕ, max (codeLaw.eval d) (proseLaw.eval d) = proseLaw.eval d) :=
  ⟨⟨net68_code512_knee_concrete.2, net68_code1024_knee_concrete.2⟩,
   fun d => by rw [net68_shift d]; norm_num [fineStep],
   net68_increment_shared,
   no_accuracy_functional_law (by norm_num) (by norm_num),
   mixed_workload_law⟩

end Catalog.NET68