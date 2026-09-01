import Mathlib
import MachineLearning.ZeroFitDialFade104
import MachineLearning.ZeroFitDialFadeDichotomy

/-!
# Contraction is what identifies a floor — and the recorded ladder has none

## Research context (FACT round-68 #2, exp 541, `TDIAL-U104`; third cycle)

`MachineLearning.ZeroFitDialFadeDichotomy` proved that no finite ladder distinguishes a positive
floor from finite extinction: two explicit continuations reproduce all seven recorded rungs, one
floored at `0.218`, one dead at bitlen 160.  Identifiability must therefore come from a *rate*
hypothesis, and the thread has one on the record: `Physics.TDialU108BandLoss` localises a plateau
assuming the decrements contract by a factor `r ≤ 1/2`, and
`Probability.TDialU116ReboundFloor` recovers a floor by Aitken extrapolation, which is exact
exactly for geometrically contracting steps.

This file proves both halves of the resulting picture.

## Main results

* `dstep`, `dstep_geometric` — the decrements of a `q`-contractive ladder satisfy
  `|d_{n+j}| ≤ qʲ |dₙ|`.
* `contractive_tail_bound` — hence the **tail bound** `|ρ_{n+m} − ρₙ| ≤ |dₙ|/(1−q)` for every
  `m`: one measured step controls the entire remaining fade.
* `contractive_has_floor`, `contractive_no_extinction` — a contractive ladder therefore has the
  explicit floor `ρₙ − |dₙ|/(1−q)`, and cannot be extinguished once that floor is positive.  This
  is the precise sense in which contraction, and only contraction, licenses the plateau reading.
* `recStep`, `recStep_values` — the six recorded four-bit decrements
  `0.0303, 0.0431, 0.0125, 0.0259, −0.0226, 0.0483`.
* `contraction_factor_ge_two` — **the recorded ladder is not contractive**: any `q` bounding all
  six consecutive step ratios satisfies `q ≥ 2`, since the rebound step is retraced with a step
  more than twice its size.
* `no_uniform_contraction` — hence no `q < 1` works, and in particular the `r ≤ 1/2` hypothesis
  of the plateau forecast is not satisfied by the ladder it was applied to.
* `identifiability_needs_contraction` — the two halves combined: contraction implies a floor,
  and the data admit no contraction factor below `2`.  The plateau reading is a hypothesis about
  future rungs, not a consequence of the recorded ones.
-/

open Finset

open Catalog.MachineLearning.ZeroFitDialFade104

open Catalog.MachineLearning.ZeroFitDialFadeDichotomy

namespace Catalog.MachineLearning.ZeroFitDialContraction

/-! ## 1. Contractive ladders -/

/-- The four-bit decrement of a ladder at rung `k`. -/
def dstep (rho : ℕ → ℚ) (k : ℕ) : ℚ := rho k - rho (k + 1)

/-- In a `q`-contractive ladder the decrements decay geometrically from any starting rung. -/
theorem dstep_geometric {rho : ℕ → ℚ} {q : ℚ} (hq : 0 ≤ q)
    (hc : ∀ k, |dstep rho (k + 1)| ≤ q * |dstep rho k|) (n j : ℕ) :
    |dstep rho (n + j)| ≤ q ^ j * |dstep rho n| := by
  induction j with
  | zero => simp
  | succ j ih =>
      have hstep := hc (n + j)
      have hnj : n + (j + 1) = (n + j) + 1 := by omega
      rw [hnj]
      calc |dstep rho ((n + j) + 1)| ≤ q * |dstep rho (n + j)| := hstep
        _ ≤ q * (q ^ j * |dstep rho n|) := by
            exact mul_le_mul_of_nonneg_left ih hq
        _ = q ^ (j + 1) * |dstep rho n| := by ring

/-- Partial geometric sums are bounded by `1/(1−q)` for `0 ≤ q < 1`. -/
lemma geom_partial_le {q : ℚ} (hq0 : 0 ≤ q) (hq1 : q < 1) (m : ℕ) :
    ∑ j ∈ range m, q ^ j ≤ 1 / (1 - q) := by
  have hne : q ≠ 1 := ne_of_lt hq1
  have hd1 : q - 1 ≠ 0 := sub_ne_zero.2 hne
  have hd2 : (1 : ℚ) - q ≠ 0 := by intro h; apply hd1; linarith
  have hsum : ∑ j ∈ range m, q ^ j = (1 - q ^ m) / (1 - q) := by
    rw [geom_sum_eq hne]
    field_simp
    ring
  rw [hsum, div_le_div_iff₀ (by linarith) (by linarith)]
  have hpow : 0 ≤ q ^ m := pow_nonneg hq0 m
  nlinarith

/-- **Tail bound.**  In a `q`-contractive ladder with `q < 1`, the whole remaining fade after
rung `n` is at most `|dₙ|/(1−q)`: a single measured step controls the future. -/
theorem contractive_tail_bound {rho : ℕ → ℚ} {q : ℚ} (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hc : ∀ k, |dstep rho (k + 1)| ≤ q * |dstep rho k|) (n m : ℕ) :
    |rho (n + m) - rho n| ≤ |dstep rho n| / (1 - q) := by
  have hpart : ∀ m : ℕ, |rho (n + m) - rho n| ≤ |dstep rho n| * ∑ j ∈ range m, q ^ j := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
        have hgeo := dstep_geometric hq0 hc n m
        have hnm : n + (m + 1) = (n + m) + 1 := by omega
        have hdiff : rho ((n + m) + 1) - rho (n + m) = -dstep rho (n + m) := by
          simp [dstep]
        have htri : |rho ((n + m) + 1) - rho n|
            ≤ |rho ((n + m) + 1) - rho (n + m)| + |rho (n + m) - rho n| :=
          abs_sub_le _ _ _
        rw [hnm]
        have habs : |rho ((n + m) + 1) - rho (n + m)| = |dstep rho (n + m)| := by
          rw [hdiff, abs_neg]
        rw [Finset.sum_range_succ, mul_add]
        rw [habs] at htri
        linarith
  have h1 := hpart m
  have h2 : |dstep rho n| * ∑ j ∈ range m, q ^ j ≤ |dstep rho n| * (1 / (1 - q)) :=
    mul_le_mul_of_nonneg_left (geom_partial_le hq0 hq1 m) (abs_nonneg _)
  calc |rho (n + m) - rho n| ≤ |dstep rho n| * ∑ j ∈ range m, q ^ j := h1
    _ ≤ |dstep rho n| * (1 / (1 - q)) := h2
    _ = |dstep rho n| / (1 - q) := by ring

/-- **Contraction gives a floor.**  Every rung after `n` stays above `ρₙ − |dₙ|/(1−q)`. -/
theorem contractive_has_floor {rho : ℕ → ℚ} {q : ℚ} (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hc : ∀ k, |dstep rho (k + 1)| ≤ q * |dstep rho k|) (n m : ℕ) :
    rho n - |dstep rho n| / (1 - q) ≤ rho (n + m) := by
  have h := contractive_tail_bound hq0 hq1 hc n m
  have hle : -(|dstep rho n| / (1 - q)) ≤ rho (n + m) - rho n := (abs_le.1 h).1
  linarith

/-- …hence a contractive ladder whose current step is small compared with its current reading is
never extinguished: the plateau reading is exactly the contraction hypothesis. -/
theorem contractive_no_extinction {rho : ℕ → ℚ} {q : ℚ} (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hc : ∀ k, |dstep rho (k + 1)| ≤ q * |dstep rho k|) (n : ℕ)
    (hsmall : |dstep rho n| / (1 - q) < rho n) : ∀ m, 0 < rho (n + m) := by
  intro m
  have h := contractive_has_floor hq0 hq1 hc n m
  linarith

/-! ## 2. The recorded ladder is not contractive -/

/-- The recorded four-bit decrements, indexed from bitlen 96. -/
def recStep (k : ℕ) : ℚ := recRung k - recRung (k + 1)

theorem recStep_values :
    recStep 0 = 303 / 10000 ∧ recStep 1 = 431 / 10000 ∧ recStep 2 = 125 / 10000 ∧
      recStep 3 = 259 / 10000 ∧ recStep 4 = -226 / 10000 ∧ recStep 5 = 4834 / 100000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [recStep, recRung, rung96, rung100, rung104, rung108, rung112, rung116, rung120] <;>
    norm_num

/-- **No contraction below two.**  Any factor `q` bounding all six consecutive recorded step
ratios satisfies `q ≥ 2`: the bitlen-116 rebound of `−0.0226` is retraced at bitlen 120 by a step
of `0.0483`, more than twice its size.  The geometric-deceleration hypothesis used to localise a
plateau is therefore not satisfied by the ladder it was applied to. -/
theorem contraction_factor_ge_two (q : ℚ)
    (hc : ∀ k < 6, |recStep (k + 1)| ≤ q * |recStep k|) : 2 ≤ q := by
  have h := hc 4 (by norm_num)
  have h4 : recStep 4 = -226 / 10000 := recStep_values.2.2.2.2.1
  have h5 : recStep 5 = 4834 / 100000 := recStep_values.2.2.2.2.2
  rw [h4, h5] at h
  rw [show |(-226 : ℚ) / 10000| = 226 / 10000 by rw [abs_div]; norm_num,
    show |(4834 : ℚ) / 100000| = 4834 / 100000 by rw [abs_div]; norm_num] at h
  linarith

/-- Hence no *contraction* factor exists at all. -/
theorem no_uniform_contraction :
    ¬ ∃ q : ℚ, q < 1 ∧ ∀ k < 6, |recStep (k + 1)| ≤ q * |recStep k| := by
  rintro ⟨q, hq1, hc⟩
  have := contraction_factor_ge_two q hc
  linarith

/-- Even the very first pair already fails: the second recorded step is larger than the first. -/
theorem first_pair_not_contractive : |recStep 0| < |recStep 1| := by
  rw [recStep_values.1, recStep_values.2.1]
  rw [show |(303 : ℚ) / 10000| = 303 / 10000 by rw [abs_div]; norm_num,
    show |(431 : ℚ) / 10000| = 431 / 10000 by rw [abs_div]; norm_num]
  norm_num

/-- **What identification would take.**  Contraction implies an explicit floor for every later
rung; the recorded ladder admits no contraction factor below `2`.  The plateau reading is
therefore a hypothesis about the rungs not yet measured, not a consequence of the rungs that
have been. -/
theorem identifiability_needs_contraction :
    (∀ (rho : ℕ → ℚ) (q : ℚ), 0 ≤ q → q < 1 →
        (∀ k, |dstep rho (k + 1)| ≤ q * |dstep rho k|) →
        ∀ n m, rho n - |dstep rho n| / (1 - q) ≤ rho (n + m)) ∧
      (∀ q : ℚ, (∀ k < 6, |recStep (k + 1)| ≤ q * |recStep k|) → 2 ≤ q) :=
  ⟨fun _ _ hq0 hq1 hc n m => contractive_has_floor hq0 hq1 hc n m, contraction_factor_ge_two⟩

end Catalog.MachineLearning.ZeroFitDialContraction