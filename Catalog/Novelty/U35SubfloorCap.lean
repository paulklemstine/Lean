import Mathlib

/-!
# U35 localization I: how many sub-floor seeds can hide behind a summary line?

## Research context (FACT round-45 #1, exp 500, assessment v276)

Paper 166 reported a `u = 3.5` breach of the `0.60` band floor for the smooth-rate dial.  The
queued 14-seed localization (exp 500, seeds `20260950–63`) came back **NEITHER — DECISIVE**:

```
sp(3.5) mean   = 0.6282  (s.e. 0.0041)
bootstrap CI   = [0.6204, 0.6363]          (excludes the 0.60 floor)
sub-floor seeds= 0 / 14
sample sd      = 0.0155
```

Both hypotheses under test — H1 "the centre is below the floor" and H2 "the centre is fine but
the tail is wide" — were refuted.  This file asks the *inferential* question that the verdict
raises: **is the `0/14` count implied by the reported centre and spread, or is it independent
information?**

The answer is a sharp two-sided localization.

* Section 1 proves a finite, one-sided Chebyshev bound valid in any ordered field:
  `#{i | x i ≤ c} · (m − c)^2 ≤ ∑ (x i − m)^2` whenever `m` is the recorded centre and `c < m`.
  No probabilistic hypothesis is used; it is a statement about a list of 14 numbers.
* Section 2 instantiates it at the recorded numbers: with mean `0.6282`, sample sd `≤ 0.0155`
  and `n = 14`, **at most 3** of the 14 seeds can sit at or below the `0.60` floor
  (`u35_subfloor_cap_three`).  So the reported summary already excludes H1-style
  "most seeds below" and it already excludes a *majority* tail.
* Section 3 shows the cap is **attained**: `witness` is an explicit 14-seed population with
  the recorded mean `0.6282` exactly, sample sd `0.015337 < 0.0155`, and three seeds at
  `0.5999`, strictly below the floor (`witness_subfloor_card`, `witness_var_lt`).
* Section 4 combines the two into the epistemic statement
  `u35_summary_does_not_determine_subfloor_count`: the pair (mean, sd) recorded in the ledger
  is consistent with `0`, `1`, `2` or `3` sub-floor seeds and with nothing else.  Hence the
  observed `0/14` is **strictly more informative than the summary line** — the refutation of
  H2 is a seed-level fact that cannot be recovered from the published two numbers, while any
  claim of `≥ 4` sub-floor seeds is refuted by the summary line alone.

This is the exact quantitative sense in which paper 166's "sub-floor column" was sampling
noise: at `5×` the per-population sample size the spread collapses to a regime where the floor
breach can involve at most a fifth of the seeds, and the seed-level ledger reports none.

## Lab notes (derived quantities, all verified below)

```
margin to floor        m - c            = 0.6282 - 0.6000 = 0.0282
squared margin         (m - c)^2        = 0.00079524
sample dispersion      13 * 0.0155^2    = 0.00312325
Chebyshev ratio        0.00312325/0.00079524 = 3.9275...   -> cap = 3
witness (k = 3)        3 x 0.5999, 11 x 69951/110000 = 0.63591818...
witness dispersion     sum of squares   = 0.003057943...   < 0.00312325   (so sd < 0.0155)
witness mean           exactly 0.6282
k = 4 attempt          sample sd 0.018574 > 0.0155        (excluded, matching the cap)
```
-/

namespace Catalog.Novelty.U35SubfloorCap

open Finset

variable {α : Type*} [Field α] [LinearOrder α] [IsStrictOrderedRing α]

/-! ## 1. A finite one-sided Chebyshev bound -/

/-- Total squared deviation of the sample `x` from the centre `m`. -/
def sqDev {n : ℕ} (x : Fin n → α) (m : α) : α := ∑ i, (x i - m) ^ 2

/-- The sample mean. -/
def mean {n : ℕ} (x : Fin n → α) : α := (∑ i, x i) / n

/-- The number of sample points at or below the level `c`. -/
def belowCard {n : ℕ} (x : Fin n → α) (c : α) : ℕ :=
  ({i | x i ≤ c} : Finset (Fin n)).card

/-- **Finite one-sided Chebyshev bound.**  Every sample point at or below `c` contributes at
least `(m - c)^2` to the total squared deviation from `m`, so the number of such points is
capped by the dispersion divided by the squared margin.  No probability is involved: this is a
statement about a finite list of field elements. -/
theorem belowCard_mul_sq_margin_le {n : ℕ} (x : Fin n → α) (m c : α) (hc : c < m) :
    (belowCard x c : α) * (m - c) ^ 2 ≤ sqDev x m := by
  classical
  set S : Finset (Fin n) := {i | x i ≤ c} with hS
  have hterm : ∀ i ∈ S, (m - c) ^ 2 ≤ (x i - m) ^ 2 := by
    intro i hi
    have hxi : x i ≤ c := by
      simpa [hS] using hi
    have h1 : 0 < m - c := sub_pos.mpr hc
    have h2 : m - c ≤ m - x i := by linarith
    nlinarith
  have hsum : ∑ _i ∈ S, (m - c) ^ 2 ≤ ∑ i ∈ S, (x i - m) ^ 2 :=
    Finset.sum_le_sum hterm
  have hsub : ∑ i ∈ S, (x i - m) ^ 2 ≤ ∑ i, (x i - m) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
      (fun i _ _ => sq_nonneg _)
  have hconst : ∑ _i ∈ S, (m - c) ^ 2 = (S.card : α) * (m - c) ^ 2 := by
    simp [Finset.sum_const, nsmul_eq_mul]
  calc (belowCard x c : α) * (m - c) ^ 2 = ∑ _i ∈ S, (m - c) ^ 2 := by
        rw [hconst]; rfl
    _ ≤ ∑ i ∈ S, (x i - m) ^ 2 := hsum
    _ ≤ sqDev x m := hsub

/-! ## 2. The recorded numbers: at most three sub-floor seeds -/

/-- The recorded `sp(3.5)` centre. -/
def u35Mean : ℚ := 6282 / 10000

/-- The band floor. -/
def bandFloor : ℚ := 6 / 10

/-- The recorded sample standard deviation of the 14 seeds. -/
def u35Sd : ℚ := 155 / 10000

theorem u35Mean_gt_bandFloor : bandFloor < u35Mean := by norm_num [bandFloor, u35Mean]

/-- **The sub-floor cap.**  Any 14-seed population whose mean is the recorded `0.6282` and
whose total squared deviation is at most the recorded one (`13 · 0.0155²`, i.e. sample sd at
most `0.0155`) has at most three seeds at or below the `0.60` floor. -/
theorem u35_subfloor_cap_three (x : Fin 14 → ℚ)
    (hvar : sqDev x u35Mean ≤ 13 * u35Sd ^ 2) :
    belowCard x bandFloor ≤ 3 := by
  have hkey := belowCard_mul_sq_margin_le x u35Mean bandFloor u35Mean_gt_bandFloor
  set k : ℕ := belowCard x bandFloor with hk
  have h1 : (k : ℚ) * (u35Mean - bandFloor) ^ 2 ≤ 13 * u35Sd ^ 2 := le_trans hkey hvar
  have h2 : (k : ℚ) * (282 / 10000) ^ 2 ≤ 312325 / 100000000 := by
    have hm : (u35Mean - bandFloor) = 282 / 10000 := by norm_num [u35Mean, bandFloor]
    rw [hm] at h1
    calc (k : ℚ) * (282 / 10000) ^ 2 ≤ 13 * u35Sd ^ 2 := h1
      _ = 312325 / 100000000 := by norm_num [u35Sd]
  have h3 : (k : ℚ) ≤ 3928 / 1000 := by nlinarith [h2]
  have h4 : (k : ℚ) < 4 := by linarith
  exact_mod_cast Nat.lt_succ_iff.mp (by exact_mod_cast h4)

/-! ## 3. Sharpness: a compliant population with three sub-floor seeds -/

/-- An explicit 14-seed population: three seeds just below the floor at `0.5999`, eleven seeds
at `69951/110000 = 0.635918…`.  Its mean is exactly the recorded `0.6282`. -/
def witness : Fin 14 → ℚ := fun i => if (i : ℕ) < 3 then 5999 / 10000 else 69951 / 110000

theorem witness_sum : ∑ i, witness i = 14 * u35Mean := by
  simp [witness, u35Mean, Fin.sum_univ_succ]
  norm_num

theorem witness_mean : mean witness = u35Mean := by
  have h := witness_sum
  simp only [mean, h]
  norm_num

theorem witness_sqDev : sqDev witness u35Mean = 1681869 / 550000000 := by
  simp [sqDev, witness, u35Mean, Fin.sum_univ_succ]
  norm_num

/-- The witness population is *inside* the recorded dispersion: its sample sd is
`0.015337… < 0.0155`. -/
theorem witness_var_lt : sqDev witness u35Mean < 13 * u35Sd ^ 2 := by
  rw [witness_sqDev]
  norm_num [u35Sd]

/-- The witness population really has three seeds at or below the floor. -/
theorem witness_subfloor_card : belowCard witness bandFloor = 3 := by
  have h : ({i | witness i ≤ bandFloor} : Finset (Fin 14)) = {0, 1, 2} := by
    ext i
    fin_cases i <;> norm_num [witness, bandFloor, Fin.ext_iff]
  simp [belowCard, h]

/-! ## 4. What the summary line does and does not decide -/

/-- **The recorded summary does not determine the sub-floor count.**  There is a 14-seed
population with exactly the recorded mean and strictly smaller dispersion than recorded, which
nevertheless breaches the floor three times; and the recorded summary caps the breach count at
three.  Hence the ledger's `0/14` is genuinely new information relative to the published
`(mean, sd)` pair, while any claim of four or more sub-floor seeds is already refuted by that
pair. -/
theorem u35_summary_does_not_determine_subfloor_count :
    (∃ x : Fin 14 → ℚ,
        mean x = u35Mean ∧ sqDev x u35Mean < 13 * u35Sd ^ 2 ∧ belowCard x bandFloor = 3) ∧
      (∀ x : Fin 14 → ℚ, sqDev x u35Mean ≤ 13 * u35Sd ^ 2 → belowCard x bandFloor ≤ 3) := by
  refine ⟨⟨witness, witness_mean, witness_var_lt, witness_subfloor_card⟩, ?_⟩
  intro x hx
  exact u35_subfloor_cap_three x hx

/-- The cap is sharp in the strong sense: `3` is the largest sub-floor count achievable
inside the recorded dispersion. -/
theorem u35_subfloor_cap_sharp :
    IsGreatest {k : ℕ | ∃ x : Fin 14 → ℚ,
        mean x = u35Mean ∧ sqDev x u35Mean ≤ 13 * u35Sd ^ 2 ∧ belowCard x bandFloor = k} 3 := by
  constructor
  · exact ⟨witness, witness_mean, le_of_lt witness_var_lt, witness_subfloor_card⟩
  · rintro k ⟨x, -, hvar, rfl⟩
    exact u35_subfloor_cap_three x hvar

end Catalog.Novelty.U35SubfloorCap