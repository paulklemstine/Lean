/-
# NET-71 — the four-domain deployment table, and its collapse to one degree of freedom

Round 24 completes the domain axis of the limited-memory programme with four measured
corpora:

| domain            | base (`ctx = 512`) | increment / doubling |
|-------------------|--------------------|----------------------|
| code (NET-68)     | 12                 | 4                    |
| prose EN (NET-67) | 16                 | 4                    |
| math (NET-70)     | 16                 | 4                    |
| prose DE (NET-71) | **20**             | 4                    |

`Logic.NET71GermanKneeShift` established the German leg and its fitted law
`deLaw = ⟨20, 4⟩`.  This file is the deployment-facing half of the round.

## What this file proves

*§1 The table.*  `Domain`, `domainLaw`, `net71_table` (all eight measured cells),
`increment_universal` (every domain has increment `4` — the NET-67 scale law is
domain-independent).

*§2 One degree of freedom.*  `eval_eq_rank_add`: the whole table is the single affine
function `12 + 4·(rank D + d)`.  Domain and scale are not two knobs but one:
`iso_budget_iff_rank_sum_eq` says two workload cells need *exactly* the same cache iff
their (domain rank + doublings) agree, and `domain_step_eq_context_doubling` is the
exchange law — moving one rung up the domain ladder costs precisely one doubling of
context.  This is the structural form of the verdict *the tokenizer tax is four keys*.

*§3 Deployment.*  `envelope_eq_deLaw` (the mixed-workload envelope over any nonempty set
of domains is again a budget law, with base the largest base present),
`cache24_covers_all_to_1024`, `cache24_tight` (24 keys is the *least* cache covering all
four domains to `ctx = 1024` — the headline deployment number, with its optimality),
`cache24_fails_at_2048` (and exactly which domain breaks it),
`sizing_by_english_underprovisions` (an English-sized cache is short by one fine step on
a multilingual workload, at every context).

*§4 The domain axis as a torsor, four-domain form.*  `shift_cocycle_ladder`,
`shift_translation_invariant`, and the identifiability theorem
`shifts_eq_iff_global_translation`: a family of bases is recoverable from its pairwise
shifts exactly up to one global translation, so the experiment measures three numbers,
not four, and the origin of the domain axis is convention.

*§5 Falsifiable predictions.*  `net71_prediction_4096` and `cache32_least_at_4096`.
-/
import Mathlib
import Applications.NET68BudgetTorsor
import Logic.NET71GermanKneeShift

namespace Catalog.NET71

open Catalog.NET68 Catalog.NET68.BudgetLaw

/-! ## 1. The four measured domains -/

/-- The four corpora of the completed domain axis. -/
inductive Domain
  | code
  | proseEN
  | math
  | proseDE
  deriving DecidableEq, Fintype, Repr

/-- `k*(math, ctx) = 16 + 4 · doublings` (NET-70: math shares English prose's base). -/
def mathLaw : BudgetLaw := ⟨16, 4⟩

/-- The measured budget law of each domain. -/
def domainLaw : Domain → BudgetLaw
  | .code => codeLaw
  | .proseEN => proseLaw
  | .math => mathLaw
  | .proseDE => deLaw

/-- The base of a domain, i.e. its knee at the reference context `512`. -/
def baseOf (D : Domain) : ℤ := (domainLaw D).base

/-- **The increment is universal.**  Every domain pays the same `4` extra keys per
context doubling: the scale law of NET-67 does not see the corpus. -/
theorem increment_universal (D : Domain) : (domainLaw D).inc = (fineStep : ℤ) := by
  cases D <;> norm_num [domainLaw, codeLaw, proseLaw, mathLaw, deLaw, fineStep]

/-- All four laws lie in one fibre of the budget torsor. -/
theorem increments_agree (D E : Domain) : (domainLaw D).inc = (domainLaw E).inc := by
  rw [increment_universal, increment_universal]

/-- **The eight measured cells.**  Bases at `ctx = 512` and knees at `ctx = 1024`. -/
theorem net71_table :
    ((domainLaw .code).eval 0 = 12 ∧ (domainLaw .code).eval 1 = 16) ∧
    ((domainLaw .proseEN).eval 0 = 16 ∧ (domainLaw .proseEN).eval 1 = 20) ∧
    ((domainLaw .math).eval 0 = 16 ∧ (domainLaw .math).eval 1 = 20) ∧
    ((domainLaw .proseDE).eval 0 = 20 ∧ (domainLaw .proseDE).eval 1 = 24) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ?_, ?_⟩ <;>
    norm_num [domainLaw, codeLaw, proseLaw, mathLaw, deLaw, BudgetLaw.eval]

/-- The domain axis has exactly three rungs: math and English prose collide. -/
theorem three_rungs :
    baseOf .code < baseOf .proseEN ∧ baseOf .proseEN = baseOf .math ∧
    baseOf .math < baseOf .proseDE ∧
    ∀ D, baseOf D = 12 ∨ baseOf D = 16 ∨ baseOf D = 20 := by
  refine ⟨by norm_num [baseOf, domainLaw, codeLaw, proseLaw], rfl,
    by norm_num [baseOf, domainLaw, mathLaw, deLaw], fun D => ?_⟩
  cases D <;> simp [baseOf, domainLaw, codeLaw, proseLaw, mathLaw, deLaw]

/-- Every base is an exact multiple of the sweep step: the domain axis lives on the
same grid as the budget axis. -/
theorem bases_on_grid (D : Domain) : (fineStep : ℤ) ∣ baseOf D := by
  have h : baseOf D = 12 ∨ baseOf D = 16 ∨ baseOf D = 20 := three_rungs.2.2.2 D
  simp only [fineStep, Nat.cast_ofNat]
  rcases h with h | h | h <;> rw [h] <;> decide

/-! ## 2. The table has one degree of freedom -/

/-- The rung of a domain on the ladder `code → {prose EN, math} → prose DE`. -/
def rank : Domain → ℕ
  | .code => 0
  | .proseEN => 1
  | .math => 1
  | .proseDE => 2

/-- **The whole four-domain table is one affine function.**  Domain and scale are a
single coordinate: the budget depends only on `rank D + d`. -/
theorem eval_eq_rank_add (D : Domain) (d : ℕ) :
    (domainLaw D).eval d = 12 + (fineStep : ℤ) * (rank D + d : ℕ) := by
  cases D <;>
    · simp only [domainLaw, rank, codeLaw, proseLaw, mathLaw, deLaw, BudgetLaw.eval,
        fineStep, Nat.cast_add, Nat.cast_ofNat, Nat.cast_zero, Nat.cast_one]
      ring

/-- **Iso-budget cells.**  Two workload cells `(domain, doublings)` need exactly the same
cache iff their rank sums agree.  The deployment table is therefore a family of parallel
diagonals, not a two-dimensional grid of independent numbers. -/
theorem iso_budget_iff_rank_sum_eq (D E : Domain) (d e : ℕ) :
    (domainLaw D).eval d = (domainLaw E).eval e ↔ rank D + d = rank E + e := by
  rw [eval_eq_rank_add, eval_eq_rank_add]
  constructor
  · intro h
    have : ((rank D + d : ℕ) : ℤ) = ((rank E + e : ℕ) : ℤ) := by
      simp only [fineStep] at h; omega
    exact_mod_cast this
  · intro h; rw [h]

/-- **The exchange law.**  One rung up the domain ladder costs exactly one doubling of
context: reading German at `ctx` costs what English costs at `2·ctx`, and what code
costs at `4·ctx`. -/
theorem domain_step_eq_context_doubling (d : ℕ) :
    (domainLaw .proseDE).eval d = (domainLaw .proseEN).eval (d + 1) ∧
    (domainLaw .proseEN).eval d = (domainLaw .code).eval (d + 1) ∧
    (domainLaw .proseDE).eval d = (domainLaw .code).eval (d + 2) := by
  refine ⟨(iso_budget_iff_rank_sum_eq _ _ _ _).2 ?_, (iso_budget_iff_rank_sum_eq _ _ _ _).2 ?_,
    (iso_budget_iff_rank_sum_eq _ _ _ _).2 ?_⟩ <;> simp [rank] <;> omega

/-- The budget is strictly monotone along the diagonal: each further rung, whether of
domain or of scale, costs one more fine step. -/
theorem eval_strictMono_rank_sum {D E : Domain} {d e : ℕ} (h : rank D + d < rank E + e) :
    (domainLaw D).eval d < (domainLaw E).eval e := by
  rw [eval_eq_rank_add, eval_eq_rank_add]
  have : ((rank D + d : ℕ) : ℤ) < ((rank E + e : ℕ) : ℤ) := by exact_mod_cast h
  simp only [fineStep]
  omega

/-! ## 3. Deployment: the least cache that covers everything -/

/-- German prose dominates every domain at every context. -/
theorem deLaw_dominates (D : Domain) (d : ℕ) : (domainLaw D).eval d ≤ deLaw.eval d := by
  have h : (domainLaw .proseDE).eval d = deLaw.eval d := rfl
  rw [← h, eval_eq_rank_add, eval_eq_rank_add]
  have hr : rank D ≤ rank Domain.proseDE := by cases D <;> simp [rank]
  have : ((rank D + d : ℕ) : ℤ) ≤ ((rank Domain.proseDE + d : ℕ) : ℤ) := by
    exact_mod_cast Nat.add_le_add_right hr d
  simp only [fineStep]
  omega

/-- **The mixed-workload envelope is again a budget law**, with the largest base present:
sizing rule for a heterogeneous deployment. -/
theorem envelope_eq_deLaw (s : Finset Domain) (hs : s.Nonempty) (hDE : Domain.proseDE ∈ s)
    (d : ℕ) : (s.sup' hs fun D => (domainLaw D).eval d) = deLaw.eval d := by
  refine le_antisymm (Finset.sup'_le _ _ fun D _ => deLaw_dominates D d) ?_
  exact Finset.le_sup' (f := fun D => (domainLaw D).eval d) hDE

/-- **The headline deployment number.**  A `24`-key cache covers all four domains up to
`ctx = 1024`. -/
theorem cache24_covers_all_to_1024 (D : Domain) (d : ℕ) (hd : d ≤ 1) :
    (domainLaw D).eval d ≤ 24 := by
  have h1 : (domainLaw D).eval d ≤ deLaw.eval d := deLaw_dominates D d
  have h2 : deLaw.eval d ≤ deLaw.eval 1 := (BudgetLaw.eval_mono deLaw (by norm_num [deLaw])) hd
  have h3 : deLaw.eval 1 = 24 := net71_de_fit.2
  omega

/-- **…and `24` is the least such cache.**  Any bound covering all four domains to
`ctx = 1024` is at least `24` keys, because German at `1024` attains it. -/
theorem cache24_tight (b : ℤ) (hb : ∀ D : Domain, ∀ d ≤ 1, (domainLaw D).eval d ≤ b) :
    24 ≤ b := by
  have := hb .proseDE 1 le_rfl
  have h : (domainLaw Domain.proseDE).eval 1 = 24 := net71_table.2.2.2.2
  omega

/-- **The prediction that breaks it.**  At `ctx = 2048` the `24`-key cache fails, and it
fails for German alone: code, English prose and math still fit. -/
theorem cache24_fails_at_2048 :
    24 < (domainLaw .proseDE).eval 2 ∧
    (domainLaw .code).eval 2 ≤ 24 ∧ (domainLaw .proseEN).eval 2 ≤ 24 ∧
    (domainLaw .math).eval 2 ≤ 24 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    norm_num [domainLaw, codeLaw, proseLaw, mathLaw, deLaw, BudgetLaw.eval]

/-- **The multilingual premium.**  Sizing a cache by English prose under-provisions a
workload that also contains German by exactly one fine step, at every context. -/
theorem sizing_by_english_underprovisions (d : ℕ) :
    max ((domainLaw .proseEN).eval d) ((domainLaw .proseDE).eval d)
        - (domainLaw .proseEN).eval d = (fineStep : ℤ) := by
  have h : (domainLaw Domain.proseDE).eval d - (domainLaw Domain.proseEN).eval d = 4 :=
    net71_shift d
  have hmax : max ((domainLaw Domain.proseEN).eval d) ((domainLaw Domain.proseDE).eval d)
      = (domainLaw Domain.proseDE).eval d := by omega
  rw [hmax]
  simp only [fineStep]
  omega

/-- Sizing by code — the cheapest domain — is short by *two* fine steps on a multilingual
workload. -/
theorem sizing_by_code_underprovisions_multilingual (d : ℕ) :
    (domainLaw .proseDE).eval d - (domainLaw .code).eval d = 2 * (fineStep : ℤ) :=
  (net71_no_crossover d).2.2

/-! ## 4. The domain axis is a torsor: three numbers, not four -/

/-- Shifts compose along the four-domain ladder, and the two extreme domains are two fine
steps apart. -/
theorem shift_cocycle_ladder :
    shift (domainLaw .code) (domainLaw .proseEN)
        + shift (domainLaw .proseEN) (domainLaw .proseDE)
      = shift (domainLaw .code) (domainLaw .proseDE) ∧
    shift (domainLaw .code) (domainLaw .proseDE) = 2 * (fineStep : ℤ) := by
  refine ⟨BudgetLaw.shift_add _ _ _, ?_⟩
  norm_num [shift, domainLaw, codeLaw, deLaw, fineStep]

/-- Re-basing the whole domain axis by a common translation changes no observable shift:
the origin of the axis is pure convention. -/
theorem shift_translation_invariant (t : ℤ) (D E : Domain) :
    shift (tr t (domainLaw D)) (tr t (domainLaw E)) = shift (domainLaw D) (domainLaw E) :=
  BudgetLaw.only_base_differences_are_observable t _ _

/-- **Identifiability, exactly.**  Two base assignments have the same pairwise shifts iff
they differ by one global translation.  The four-domain experiment therefore measures
three independent numbers; the fourth coordinate is a gauge choice. -/
theorem shifts_eq_iff_global_translation (f g : Domain → ℤ) :
    (∀ A B, f B - f A = g B - g A) ↔ ∃ t : ℤ, ∀ D, g D = f D + t := by
  constructor
  · intro h
    refine ⟨g .code - f .code, fun D => ?_⟩
    have := h .code D
    omega
  · rintro ⟨t, ht⟩ A B
    rw [ht A, ht B]; ring

/-- The measured shift vector of round 24, in fine-grid units: `(0, 1, 1, 2)`. -/
theorem measured_shift_vector (D : Domain) :
    baseOf D - baseOf .code = (fineStep : ℤ) * rank D := by
  cases D <;> norm_num [baseOf, domainLaw, codeLaw, proseLaw, mathLaw, deLaw, rank, fineStep]

/-! ## 5. Falsifiable predictions for the next cell -/

/-- **Pre-registered extrapolation to `ctx = 4096`** (three doublings): code `24`,
English prose `28`, math `28`, German prose `32`. -/
theorem net71_prediction_4096 :
    (domainLaw .code).eval 3 = 24 ∧ (domainLaw .proseEN).eval 3 = 28 ∧
    (domainLaw .math).eval 3 = 28 ∧ (domainLaw .proseDE).eval 3 = 32 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    norm_num [domainLaw, codeLaw, proseLaw, mathLaw, deLaw, BudgetLaw.eval]

/-- And the corresponding deployment number: `32` keys is the least cache covering all
four domains to `ctx = 4096`. -/
theorem cache32_least_at_4096 :
    (∀ D : Domain, ∀ d ≤ 3, (domainLaw D).eval d ≤ 32) ∧
    (∀ b : ℤ, (∀ D : Domain, ∀ d ≤ 3, (domainLaw D).eval d ≤ b) → 32 ≤ b) := by
  constructor
  · intro D d hd
    have h1 : (domainLaw D).eval d ≤ deLaw.eval d := deLaw_dominates D d
    have h2 : deLaw.eval d ≤ deLaw.eval 3 := (BudgetLaw.eval_mono deLaw (by norm_num [deLaw])) hd
    have h3 : deLaw.eval 3 = 32 := by norm_num [deLaw, BudgetLaw.eval]
    omega
  · intro b hb
    have := hb .proseDE 3 le_rfl
    have h : (domainLaw Domain.proseDE).eval 3 = 32 := net71_prediction_4096.2.2.2
    omega

end Catalog.NET71