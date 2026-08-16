/-
# Identifiability of a knee law from a doubling chain (NET-44, cycle 3)

Cycle 1 (`Logic.KneeFluctuationTwoSeed`) formalised the measurement, cycle 2
(`Logic.KneeSeedEnsembleBracket`) the epistemics of seed ensembles.  This cycle attacks
the remaining structural claim of the round: NET-37 reported that the product law
`k* = d·ctx/32` held *exactly along a chain of four context doublings*
(`16, 32, 64, 128` at `ctx = 128, 256, 512, 1024`, `d = 4`), and NET-44 then broke the
last link at a second seed.  What, exactly, does a doubling chain determine?

* `KneeLaw.doubling_chain_law` : a law obeying the exact context-doubling relation
  `f (2·n) = 2·f n` with the anchor `f 128 = 16` is *rigid* along the chain — by
  induction `f (128·2^m) = 16·2^m`, i.e. `f ctx = ctx/8 = d·ctx/32` at `d = 4`.
  `KneeLaw.chain_predicts_128` is the pre-registered NET-44 prediction, derived rather
  than fitted.
* `KneeLaw.chain_extension_underdetermined` : but the *measured* chain is only three
  points plus monotonicity, and every value in `(64, 128]` extends it.  So the doubling
  relation, not the data, is what produced the prediction — and it is the doubling
  relation that NET-44 falsifies.
* `KneeLaw.true_knee_mem_Ioc` and `KneeLaw.same_gridKnee_imp_close` : a grid sweep of
  step `s` identifies the true knee only inside a half-open window of width `s`.  Two
  laws consistent with the same measured grid knees differ by less than one step
  everywhere.
* `KneeLaw.net44_true_knee_windows` : consequently seed 1's reported `128` means a true
  knee in `(96, 128]` and seed 2's reported `96` means `(64, 96]`; the union is exactly
  the announced bracket `(64, 128]`, and the two windows are *disjoint* — the seeds
  really do disagree, the disagreement is not a quantisation artefact of a single true
  value.
* `KneeLaw.no_single_valued_law_fits_both_seeds` : hence no single-valued exact knee law
  can fit both seeds at this cell.  The correct object is the interval-valued law, and
  `KneeLaw.bracketLaw_sound` shows the bracket `(64, 128]` is sound for both seeds while
  `KneeLaw.bracketLaw_sharp` shows no narrower bracket with grid endpoints is.
-/

import Mathlib
import Logic.KneeFluctuationTwoSeed

namespace KneeLaw

open KneeFluctuation

/-! ## 1.  A doubling chain is rigid — given the doubling relation -/

/-- **Rigidity along the chain.**  Exact context doubling plus the anchor `f 128 = 16`
forces `f (128·2^m) = 16·2^m`: the product law `d·ctx/32` at `d = 4`. -/
theorem doubling_chain_law {f : ℕ → ℝ} (hdouble : ∀ n, f (2 * n) = 2 * f n)
    (hbase : f 128 = 16) (m : ℕ) : f (128 * 2 ^ m) = 16 * 2 ^ m := by
  induction m with
  | zero => simpa using hbase
  | succ n ih =>
      have hidx : 128 * 2 ^ (n + 1) = 2 * (128 * 2 ^ n) := by ring
      rw [hidx, hdouble, ih]
      ring

/-- The chain's prediction at the last cell: `f 1024 = 128 = 4·1024/32`, the value
NET-44 pre-registered and then refuted at seed 2. -/
theorem chain_predicts_128 {f : ℕ → ℝ} (hdouble : ∀ n, f (2 * n) = 2 * f n)
    (hbase : f 128 = 16) : f 1024 = 128 := by
  have h := doubling_chain_law hdouble hbase 3
  norm_num at h
  exact h

/-- **But the measured chain determines nothing at the next cell.**  For *every* value
`v > 64` — in particular every value of the two-seed bracket `(64, 128]` — there is a
monotone law reproducing the measured `16, 32, 64` at `ctx = 128, 256, 512` and taking
the value `v` at `ctx = 1024`.  The prediction came from the doubling *relation*, not
from the data. -/
theorem chain_extension_underdetermined (v : ℝ) (hlo : 64 < v) :
    ∃ f : ℕ → ℝ, Monotone f ∧ f 128 = 16 ∧ f 256 = 32 ∧ f 512 = 64 ∧ f 1024 = v := by
  refine ⟨fun n => if n ≤ 128 then 16 else if n ≤ 256 then 32 else if n ≤ 512 then 64
    else v, ?_, by norm_num, by norm_num, by norm_num, by norm_num⟩
  intro a b hab
  dsimp only
  split_ifs <;> first | rfl | (exfalso; omega) | linarith

/-! ## 2.  A grid sweep identifies the knee only up to one step -/

/-- **Quantisation window.**  If a sweep of step `s` reports the grid knee `q`, the true
knee lies in the half-open window `(q - s, q]`. -/
theorem true_knee_mem_Ioc {s κ q : ℝ} (hs : 0 < s) (hκ : 0 ≤ κ) (h : gridKnee s κ = q) :
    q - s < κ ∧ κ ≤ q := by
  have h1 : κ ≤ gridKnee s κ := le_gridKnee hs
  have h2 : gridKnee s κ - κ < s := gridKnee_overshoot_lt_step hs hκ
  rw [h] at h1 h2
  exact ⟨by linarith, h1⟩

/-- Two true knees reported identically by the same sweep differ by less than a step:
a grid sweep identifies a knee law only up to one grid step. -/
theorem same_gridKnee_imp_close {s κ₁ κ₂ : ℝ} (hs : 0 < s) (h₁ : 0 ≤ κ₁) (h₂ : 0 ≤ κ₂)
    (h : gridKnee s κ₁ = gridKnee s κ₂) : |κ₁ - κ₂| < s := by
  obtain ⟨hlo₁, hhi₁⟩ := true_knee_mem_Ioc hs h₁ rfl
  obtain ⟨hlo₂, hhi₂⟩ := true_knee_mem_Ioc (s := s) (κ := κ₂) (q := gridKnee s κ₁) hs h₂
    h.symm
  rw [abs_lt]
  constructor <;> linarith

/-- **The two seeds genuinely disagree.**  Seed 1's reported `128` places its true knee in
`(96, 128]`, seed 2's reported `96` places its true knee in `(64, 96]`; the windows are
disjoint, so the one-step difference cannot be explained away as two quantisations of a
single true value.  Their union is the announced bracket `(64, 128]`. -/
theorem net44_true_knee_windows {κ₁ κ₂ : ℝ} (h₁ : 0 ≤ κ₁) (h₂ : 0 ≤ κ₂)
    (hs₁ : gridKnee 32 κ₁ = 128) (hs₂ : gridKnee 32 κ₂ = 96) :
    (96 < κ₁ ∧ κ₁ ≤ 128) ∧ (64 < κ₂ ∧ κ₂ ≤ 96) ∧ κ₂ < κ₁ := by
  obtain ⟨a₁, b₁⟩ := true_knee_mem_Ioc (by norm_num) h₁ hs₁
  obtain ⟨a₂, b₂⟩ := true_knee_mem_Ioc (by norm_num) h₂ hs₂
  norm_num at a₁ a₂
  exact ⟨⟨a₁, b₁⟩, ⟨a₂, b₂⟩, by linarith⟩

/-! ## 3.  From an exact law to an interval-valued law -/

/-- **No single-valued exact law fits both seeds.**  The measured cell `(d = 4,
ctx = 1024)` admits no common knee, so "the" knee law must be interval valued. -/
theorem no_single_valued_law_fits_both_seeds {c₁ c₂ : ℕ → ℝ}
    (h₁ : Seed1Data c₁) (h₂ : Seed2Data c₂) :
    ¬ ∃ L : ℕ, IsKnee gridS1 bar c₁ L ∧ IsKnee gridS2 bar c₂ L := by
  rintro ⟨L, hL₁, hL₂⟩
  have e₁ : L = 128 := hL₁.unique (net44_seed1_knee h₁)
  have e₂ : L = 96 := hL₂.unique (net44_seed2_knee h₂)
  omega

/-- **Soundness of the bracket.**  Every measured knee at this cell lies in `(64, 128]`. -/
theorem bracketLaw_sound {c₁ c₂ : ℕ → ℝ} {k₁ k₂ : ℕ} (h₁ : Seed1Data c₁)
    (h₂ : Seed2Data c₂) (hk₁ : IsKnee gridS1 bar c₁ k₁) (hk₂ : IsKnee gridS2 bar c₂ k₂) :
    64 < k₁ ∧ k₁ ≤ 128 ∧ 64 < k₂ ∧ k₂ ≤ 128 := by
  obtain ⟨⟨a, b⟩, ⟨c, d⟩⟩ := net44_two_seed_bracket h₁ h₂ hk₁ hk₂
  exact ⟨a, b, c, d⟩

/-- **Sharpness of the bracket.**  No narrower bracket with endpoints on the sweep grid
contains both measured knees: raising the lower end past `64` excludes the seed-2 knee
`96` only if the new lower end is at least `96`, in which case the seed-2 knee is
excluded; lowering the upper end below `128` excludes the seed-1 knee. -/
theorem bracketLaw_sharp {c₁ c₂ : ℕ → ℝ} {k₁ k₂ lo hi : ℕ} (h₁ : Seed1Data c₁)
    (h₂ : Seed2Data c₂) (hk₁ : IsKnee gridS1 bar c₁ k₁) (hk₂ : IsKnee gridS2 bar c₂ k₂)
    (hcontain : ∀ k, (k = k₁ ∨ k = k₂) → lo < k ∧ k ≤ hi) : lo < 96 ∧ 128 ≤ hi := by
  have e₁ : k₁ = 128 := hk₁.unique (net44_seed1_knee h₁)
  have e₂ : k₂ = 96 := hk₂.unique (net44_seed2_knee h₂)
  have c₁' := hcontain k₁ (Or.inl rfl)
  have c₂' := hcontain k₂ (Or.inr rfl)
  subst e₁; subst e₂
  omega

end KneeLaw