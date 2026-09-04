import Mathlib
import Novelty.U35SubfloorCap
import Novelty.U35USensitivityForecast

/-!
# U35 localization V: the depth–count trade-off, and why the deep-breach seed cannot recur

## Research context (FACT round-45 #1, exp 500, assessment v276)

The exp-500 verdict includes a specific historical claim: paper 166's deep-breach seed "has no
analogue at `5×` N".  Files I–IV proved statements about *how many* seeds can breach and about
the paired column.  This file proves statements about *how deep* a breach can be, and turns the
historical claim into a theorem about the recorded dispersion.

* `sqDev_single_le` — the elementary but decisive inequality: a single seed's squared deviation
  is at most the whole dispersion budget.  (A one-term sum bound; it beats the counting bound
  whenever only one seed is in question.)
* `u35_no_deep_breach` — **no analogue of the deep-breach seed.**  At the recorded mean and
  sample sd, *every* one of the 14 seeds satisfies `spᵢ > 0.5723`.  A seed at, say, `0.55`
  — the sort of reading paper 166's `240`-Ns column produced — is arithmetically impossible in
  the exp-500 population, whatever the other 13 seeds do.  The claim needs no seed-level data:
  it follows from the two published summary numbers.
* `u35_depth_count_tradeoff` — the general trade-off `k · δ² ≤ 13 s²` between breach depth `δ`
  and breach count `k`: the recorded dispersion is a budget, and depth is quadratically
  expensive.
* `u35_depth_ladder_shallow` / `u35_depth_ladder_medium` / `u35_depth_ladder_deep` — the
  resulting ladder at the recorded numbers:

```
depth below the mean      max seeds at that depth       status
0.0282 (the band floor)   3                             attained (file I witness)
0.0400                    1                             attained (witnessDepth below)
0.0559                    0                             impossible
```

* `witnessDepth`, `u35_depth_ladder_medium_sharp` — the middle rung is attained: an explicit
  population with the recorded mean, dispersion well inside budget, and one seed a full `0.04`
  below the mean (i.e. `0.0118` below the band floor).
* `u35_drop_band` — the paired analogue: every seed's `u`-drop lies in the band
  `(0.066, 0.1454)`, so the `u`-sensitivity loss is uniform *from both sides* — there is no
  insensitive seed and no hypersensitive one either.  Together with file III this is the
  strongest available formal reading of "degrades everywhere, by about the same amount".

The methodological point: the whole "localization" question — is the breach a centre effect, a
tail effect, or a single bad seed? — is decided at the level of two published numbers plus
finite-dimensional geometry.  What the ledger's seed-level column adds is exactly the residual
freedom quantified in file I, and nothing more.

## Lab notes (derived quantities, all verified below)

```
dispersion budget            13 * 0.0155^2  = 0.00312325
single-seed depth bound      sqrt(budget)   = 0.0558861...   -> every seed > 0.5723
depth 0.04 count bound       0.00312325/0.0016 = 1.952       -> at most 1 seed
depth-0.04 witness           1 x 0.5882, 13 x 41033/65000 = 0.63127692...,  SS = 0.00172307
paired budget                13 * 0.0110^2  = 0.0015730
paired single-seed bound     sqrt(budget)   = 0.0396611...   -> drops in (0.0660, 0.1454)
```
-/

namespace Catalog.Novelty.U35BreachDepthProfile

open Finset
open Catalog.Novelty.U35SubfloorCap
open Catalog.Novelty.U35USensitivityForecast

variable {α : Type*} [Field α] [LinearOrder α] [IsStrictOrderedRing α]

/-! ## 1. One seed cannot exceed the dispersion budget -/

/-- A single seed's squared deviation is at most the total dispersion. -/
theorem sqDev_single_le {n : ℕ} (x : Fin n → α) (m : α) (i : Fin n) :
    (x i - m) ^ 2 ≤ sqDev x m := by
  classical
  refine Finset.single_le_sum (f := fun j => (x j - m) ^ 2) ?_ (Finset.mem_univ i)
  intro j _
  exact sq_nonneg _

/-! ## 2. No deep breach -/

/-- **No analogue of paper 166's deep-breach seed.**  With the recorded mean `0.6282` and
sample sd at most `0.0155`, every one of the 14 seeds exceeds `0.5723`.  A reading anywhere
near `0.55` is arithmetically impossible in the exp-500 population. -/
theorem u35_no_deep_breach (x : Fin 14 → ℚ)
    (hvar : sqDev x u35Mean ≤ 13 * u35Sd ^ 2) (i : Fin 14) :
    5723 / 10000 < x i := by
  by_contra hle
  push_neg at hle
  have hdev : (u35Mean - x i) ≥ 559 / 10000 := by
    simp only [u35Mean] at hle ⊢
    linarith
  have hsq : (559 / 10000 : ℚ) ^ 2 ≤ (x i - u35Mean) ^ 2 := by nlinarith
  have hbudget : (x i - u35Mean) ^ 2 ≤ 13 * u35Sd ^ 2 :=
    le_trans (sqDev_single_le x u35Mean i) hvar
  rw [show (13 : ℚ) * u35Sd ^ 2 = 312325 / 100000000 by norm_num [u35Sd]] at hbudget
  have : (559 / 10000 : ℚ) ^ 2 ≤ 312325 / 100000000 := le_trans hsq hbudget
  norm_num at this

/-! ## 3. The depth–count trade-off -/

/-- **The depth–count trade-off.**  Depth is quadratically expensive: `k` seeds sitting at
depth `δ` below the recorded mean cost `k δ²` of the dispersion budget. -/
theorem u35_depth_count_tradeoff (x : Fin 14 → ℚ) (δ : ℚ) (hδ : 0 < δ)
    (hvar : sqDev x u35Mean ≤ 13 * u35Sd ^ 2) :
    (belowCard x (u35Mean - δ) : ℚ) * δ ^ 2 ≤ 312325 / 100000000 := by
  have hlt : u35Mean - δ < u35Mean := by linarith
  have hkey := belowCard_mul_sq_margin_le x u35Mean (u35Mean - δ) hlt
  have hsimp : (u35Mean - (u35Mean - δ)) = δ := by ring
  rw [hsimp] at hkey
  calc (belowCard x (u35Mean - δ) : ℚ) * δ ^ 2 ≤ sqDev x u35Mean := hkey
    _ ≤ 13 * u35Sd ^ 2 := hvar
    _ = 312325 / 100000000 := by norm_num [u35Sd]

/-- Rung 1 of the ladder: at the band floor (depth `0.0282`) at most three seeds. -/
theorem u35_depth_ladder_shallow (x : Fin 14 → ℚ)
    (hvar : sqDev x u35Mean ≤ 13 * u35Sd ^ 2) :
    belowCard x bandFloor ≤ 3 :=
  u35_subfloor_cap_three x hvar

/-- Rung 2 of the ladder: at depth `0.04` at most one seed. -/
theorem u35_depth_ladder_medium (x : Fin 14 → ℚ)
    (hvar : sqDev x u35Mean ≤ 13 * u35Sd ^ 2) :
    belowCard x (u35Mean - 4 / 100) ≤ 1 := by
  have h := u35_depth_count_tradeoff x (4 / 100) (by norm_num) hvar
  set k : ℕ := belowCard x (u35Mean - 4 / 100) with hk
  have h' : (k : ℚ) * (16 / 10000) ≤ 312325 / 100000000 := by
    have hsq : ((4 : ℚ) / 100) ^ 2 = 16 / 10000 := by norm_num
    rwa [hsq] at h
  have h3 : (k : ℚ) < 2 := by linarith
  exact Nat.lt_succ_iff.mp (by exact_mod_cast h3)

/-- Rung 3 of the ladder: at depth `0.0559` no seed at all. -/
theorem u35_depth_ladder_deep (x : Fin 14 → ℚ)
    (hvar : sqDev x u35Mean ≤ 13 * u35Sd ^ 2) :
    belowCard x (u35Mean - 559 / 10000) = 0 := by
  have h := u35_depth_count_tradeoff x (559 / 10000) (by norm_num) hvar
  set k : ℕ := belowCard x (u35Mean - 559 / 10000) with hk
  by_contra hne
  have hk1 : (1 : ℚ) ≤ (k : ℚ) := by
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr hne
  nlinarith

/-! ## 4. The middle rung is attained -/

/-- One seed a full `0.04` below the recorded mean (i.e. `0.0118` below the band floor), the
other thirteen at `41033/65000`. -/
def witnessDepth : Fin 14 → ℚ := fun i => if (i : ℕ) < 1 then 5882 / 10000 else 41033 / 65000

theorem witnessDepth_sum : ∑ i, witnessDepth i = 14 * u35Mean := by
  simp [witnessDepth, u35Mean, Fin.sum_univ_succ]
  norm_num

theorem witnessDepth_mean : mean witnessDepth = u35Mean := by
  have h := witnessDepth_sum
  simp only [mean, h]
  norm_num

theorem witnessDepth_sqDev : sqDev witnessDepth u35Mean = 14 / 8125 := by
  simp [sqDev, witnessDepth, u35Mean, Fin.sum_univ_succ]
  norm_num

theorem witnessDepth_var_lt : sqDev witnessDepth u35Mean < 13 * u35Sd ^ 2 := by
  rw [witnessDepth_sqDev]
  norm_num [u35Sd]

theorem witnessDepth_belowCard : belowCard witnessDepth (u35Mean - 4 / 100) = 1 := by
  have hthr : u35Mean - 4 / 100 = 5882 / 10000 := by norm_num [u35Mean]
  have h : ({i | witnessDepth i ≤ (5882 : ℚ) / 10000} : Finset (Fin 14)) = {0} := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton, witnessDepth]
    constructor
    · intro hi
      by_contra hne
      have hnot : ¬ ((i : ℕ) < 1) := fun hlt => hne (Fin.ext (by omega))
      rw [if_neg hnot] at hi
      norm_num at hi
    · rintro rfl
      norm_num
  rw [belowCard, hthr, h]
  rfl

/-- **The middle rung is sharp.**  There is a population with the recorded mean, dispersion
strictly inside the recorded budget, and exactly one seed a full `0.04` below the mean; and no
population inside the budget has two. -/
theorem u35_depth_ladder_medium_sharp :
    (∃ x : Fin 14 → ℚ, mean x = u35Mean ∧ sqDev x u35Mean < 13 * u35Sd ^ 2 ∧
        belowCard x (u35Mean - 4 / 100) = 1) ∧
      (∀ x : Fin 14 → ℚ, sqDev x u35Mean ≤ 13 * u35Sd ^ 2 →
        belowCard x (u35Mean - 4 / 100) ≤ 1) :=
  ⟨⟨witnessDepth, witnessDepth_mean, witnessDepth_var_lt, witnessDepth_belowCard⟩,
    fun x hx => u35_depth_ladder_medium x hx⟩

/-! ## 5. The paired band: no insensitive seed, and no hypersensitive one -/

/-- **The two-sided uniformity band.**  Every seed's `u`-drop lies strictly between `0.066` and
`0.1454`: the `u`-sensitivity loss is uniform from both sides.  The lower half strengthens
file III's "degrades everywhere"; the upper half rules out the complementary explanation that a
few hypersensitive seeds carry the mean drop. -/
theorem u35_drop_band (d : Fin 14 → ℚ)
    (hvar : sqDev d dropMean ≤ 13 * dropSd ^ 2) (i : Fin 14) :
    66 / 1000 < d i ∧ d i < 1454 / 10000 := by
  have hbudget : (d i - dropMean) ^ 2 ≤ 13 * dropSd ^ 2 :=
    le_trans (sqDev_single_le d dropMean i) hvar
  rw [show (13 : ℚ) * dropSd ^ 2 = 157300 / 100000000 by norm_num [dropSd]] at hbudget
  constructor
  · by_contra hle
    push_neg at hle
    have hdev : (dropMean - d i) ≥ 397 / 10000 := by
      simp only [dropMean] at hle ⊢
      linarith
    nlinarith
  · by_contra hge
    push_neg at hge
    have hdev : (d i - dropMean) ≥ 397 / 10000 := by
      simp only [dropMean] at hge ⊢
      linarith
    nlinarith

end Catalog.Novelty.U35BreachDepthProfile