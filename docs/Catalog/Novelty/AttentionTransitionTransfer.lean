import Novelty.AttentionFeasibilityBand

/-!
# Where does the transition sit for the *other* model? (NET-78, cycle 3)

Cycles 1 and 2 established, for the 0.5B model, that the measured chain
`16, 20, 24, 40` breaks the affine law at the fourth doubling, that the minimal
convex fit is the two-term tropical polynomial `max (16 + 4j) (16j - 8)` whose
corner sits at `j = 2` (`ctx = 2048`), and that feasibility kills the geometric
continuation.  The obvious next experiment is the 1.5B cell at `ctx = 4096`,
and this file makes the two rival predictions *formal and separated*, so that a
single measurement decides between them.

The two hypotheses are:

* **CTX** — the transition is a property of the **context length**: attention
  becomes sharply more expensive past ~2000 tokens, for every model.  Then the
  1.5B curve kinks at `j = 2` as well, and (by the cycle-1 scale law, which
  halves every increment for the larger model) its post-corner increment is `8`.
  Prediction: `kneeLargeCTX 3 = 28`.
* **BUD** — the transition is a property of the **key budget**: a curve kinks
  when its knee crosses the critical budget of `24` keys.  `crossIdx` is that
  crossing index, and `crossIdx_kneeSmall` shows the hypothesis is *not*
  vacuous: for the 0.5B model the critical budget is crossed exactly at
  `j = 2`, which is where the measured corner is.  For the 1.5B model
  `crossIdx_kneeLarge` puts the crossing at `j = 5`, i.e. at `ctx = 16384`.
  Prediction: `kneeLargeBUD 3 = 20`, no kink yet at `4096`.

`transfer_experiment_discriminates` proves that the two laws agree on every
measured 1.5B point (`16, 16, 18` at `j ≤ 2`) and disagree by `8` keys at
`j = 3`.  `bud_delays_transition` records the delay in context terms:
`2048` versus `16384`, a factor of eight.  Finally `ctx_hypothesis_is_convex`
and `bud_hypothesis_is_convex` check that both rivals are legitimate convex
budget laws, so the experiment is a genuine test and not a comparison with a
malformed alternative.
-/

namespace Catalog.Novelty.AttentionTransitionTransfer

open Catalog.Novelty.AttentionBudgetIncrement Catalog.Novelty.AttentionPhaseTransition
open Catalog.Novelty.AttentionFeasibilityBand

/-! ### 1. The crossing index of a budget law -/

/-- The first context doubling at which a budget law demands at least `K` keys. -/
noncomputable def crossIdx (f : ℕ → ℕ) (K : ℕ) : ℕ := sInf {j | K ≤ f j}

theorem crossIdx_le {f : ℕ → ℕ} {K j : ℕ} (hj : K ≤ f j) : crossIdx f K ≤ j :=
  Nat.sInf_le hj

theorem crossIdx_spec {f : ℕ → ℕ} {K : ℕ} (h : ∃ j, K ≤ f j) : K ≤ f (crossIdx f K) :=
  Nat.sInf_mem h

/-- **The critical budget explains the observed corner.**  The 0.5B knee crosses
`24` keys exactly at `j = 2` — the doubling at which its measured curve kinks.
This is what makes the budget hypothesis testable rather than post hoc. -/
theorem crossIdx_kneeSmall : crossIdx kneeSmall 24 = 2 := by
  have h2 : (2 : ℕ) ∈ {j | 24 ≤ kneeSmall j} := by simp [kneeSmall]
  refine le_antisymm (Nat.sInf_le h2) ?_
  by_contra hlt
  push_neg at hlt
  have hmem : 24 ≤ kneeSmall (crossIdx kneeSmall 24) :=
    Nat.sInf_mem (⟨2, h2⟩ : {j | 24 ≤ kneeSmall j}.Nonempty)
  simp only [kneeSmall] at hmem
  omega

/-- The 1.5B knee only crosses the same critical budget at `j = 5`, i.e. at
`ctx = 16384`: under the budget hypothesis its transition is delayed by three
octaves. -/
theorem crossIdx_kneeLarge : crossIdx kneeLarge 24 = 5 := by
  have h5 : (5 : ℕ) ∈ {j | 24 ≤ kneeLarge j} := by simp [kneeLarge]
  refine le_antisymm (Nat.sInf_le h5) ?_
  by_contra hlt
  push_neg at hlt
  have hmem : 24 ≤ kneeLarge (crossIdx kneeLarge 24) :=
    Nat.sInf_mem (⟨5, h5⟩ : {j | 24 ≤ kneeLarge j}.Nonempty)
  simp only [kneeLarge] at hmem
  omega

/-! ### 2. The two rival transfer laws for the 1.5B model -/

/-- **CTX hypothesis.**  The kink is at `j = 2` for every model; the larger
model's post-kink increment is half of the smaller model's `16`. -/
def kneeLargeCTX (j : ℕ) : ℕ := kneeLarge j + 8 * (j - 2)

/-- **BUD hypothesis.**  The kink happens where the knee crosses `24` keys,
which for the 1.5B model is `j = 5`. -/
def kneeLargeBUD (j : ℕ) : ℕ := kneeLarge j + 8 * (j - 5)

/-- Both laws reproduce the measured 1.5B triple `16, 16, 18`. -/
theorem transfer_laws_fit_measured :
    (kneeLargeCTX 0, kneeLargeCTX 1, kneeLargeCTX 2) = (16, 16, 18) ∧
    (kneeLargeBUD 0, kneeLargeBUD 1, kneeLargeBUD 2) = (16, 16, 18) := by
  constructor <;> decide

/-- **The discriminating experiment.**  The two hypotheses are indistinguishable
on all existing 1.5B data and differ by exactly `8` keys at `ctx = 4096`:
`28` under CTX, `20` under BUD.  One 1.5B cell at `4096` decides. -/
theorem transfer_experiment_discriminates :
    (∀ j ≤ 2, kneeLargeCTX j = kneeLargeBUD j) ∧
      kneeLargeCTX 3 = 28 ∧ kneeLargeBUD 3 = 20 ∧
      kneeLargeCTX 3 = kneeLargeBUD 3 + 8 := by
  refine ⟨fun j hj => ?_, by decide, by decide, by decide⟩
  interval_cases j <;> decide

/-- Under the budget hypothesis the transition context is `16384` rather than
`2048`: an eightfold delay for the threefold larger model. -/
theorem bud_delays_transition :
    (512 : ℕ) * 2 ^ crossIdx kneeSmall 24 = 2048 ∧
      (512 : ℕ) * 2 ^ crossIdx kneeLarge 24 = 16384 ∧
      512 * 2 ^ crossIdx kneeLarge 24 = 8 * (512 * 2 ^ crossIdx kneeSmall 24) := by
  rw [crossIdx_kneeSmall, crossIdx_kneeLarge]
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-! ### 3. Both rivals are legitimate budget laws -/

theorem ctx_hypothesis_is_convex : ConvexLaw kneeLargeCTX := by
  intro j; simp only [kneeLargeCTX, kneeLarge]; omega

theorem bud_hypothesis_is_convex : ConvexLaw kneeLargeBUD := by
  intro j; simp only [kneeLargeBUD, kneeLarge]; omega

theorem ctx_hypothesis_monotone : Monotone kneeLargeCTX := by
  intro a b hab; simp only [kneeLargeCTX, kneeLarge]; omega

theorem bud_hypothesis_monotone : Monotone kneeLargeBUD := by
  intro a b hab; simp only [kneeLargeBUD, kneeLarge]; omega

/-- Both rivals are feasible, so neither is excluded by the cycle-2 ceiling. -/
theorem transfer_laws_feasible : Feasible kneeLargeCTX ∧ Feasible kneeLargeBUD := by
  constructor <;> intro j <;>
    · have h : j + 1 ≤ 2 ^ j := Nat.lt_two_pow_self
      have h2 : 16 * (j + 1) ≤ 16 * 2 ^ j := Nat.mul_le_mul_left 16 h
      have h3 : (16 : ℕ) * 2 ^ j ≤ 512 * 2 ^ j := Nat.mul_le_mul_right _ (by norm_num)
      simp only [kneeLargeCTX, kneeLargeBUD, kneeLarge]
      omega

/-- **The larger model still needs fewer keys, whichever hypothesis holds.**
Even the pessimistic CTX transfer keeps the 1.5B budget strictly below the
measured 0.5B budget at `ctx = 4096`, so the scale advantage of cycle 1 survives
the phase transition. -/
theorem scale_advantage_survives :
    kneeLargeCTX 3 < 40 ∧ kneeLargeBUD 3 < 40 := by
  constructor <;> decide

end Catalog.Novelty.AttentionTransitionTransfer