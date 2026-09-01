import Mathlib
import Novelty.TDialU84ApproachNotCrossed
import Novelty.TDialU84ErosionMetrics

/-!
# U84, cycle 3: a quadratic Kendall bound and the crossing dichotomy

## Research context

Cycles 1–2 (`Novelty.TDialU84ApproachNotCrossed`, `Novelty.TDialU84ErosionMetrics`) recorded
the U84 measurement (pooled Spearman `0.558`, CI `[0.536, 0.581]`, band floor `0.55`, margin
`+0.008`), proved a *linear* rank-metric crossing budget `margin · n(n+1)/12`, pinned the two
ends of the Spearman scale, and showed that the post-U84 trend points away from the floor.
Two questions survive.

1. The linear budget is driven by the *worst-case* adjacent transposition, one that moves a
   rank by `n − 1` positions.  Such steps cannot be sustained.  Is there a second,
   qualitatively different bound that exploits the accumulation constraint?
2. "Approaching but not crossed" presupposes that a floor exists and can be located.  Is the
   *eventual* crossing decidable from the recorded rungs at the recorded resolution?

## Main results

### A. A quadratic (`ℓ¹`) crossing budget (Section 1)

* `sumAbsDev_transposeAt_le` — an adjacent transposition changes the `ℓ¹` rank displacement
  `∑|s k − k|` by at most `2`.
* `sumAbsDev_chain_le` — hence a chain of `K` adjacent transpositions started at the identity
  produces `∑|s k − k| ≤ 2K`.
* `sumSqDev_le_sq_sumAbsDev` — and `∑(s k − k)² ≤ (∑|s k − k|)²`.
* `spearman_ge_of_chain_from_id` — **the quadratic budget**: any ranking reachable from the
  identity by `K` adjacent transpositions has
  `ρ ≥ 1 − 24 K² / (n(n²−1))`.
  This is a genuinely different mechanism from cycle 1: it is driven by displacement
  accumulation rather than by the size of a single step, and its `Ω(n^{3/2})` scaling is the
  better bound for small margins.
* `u84_kendall_quadratic_budget` — at `n = 4096`, producing the recorded reading `0.558`
  from a perfectly aligned ranking needs `≥ 35576` adjacent transpositions.
* `u84_kendall_linear_budget` / `u84_linear_dominates_quadratic` — the cycle-1 bound gives
  `≥ 618112` at the same `n`, which dominates.  So the recorded U84 reading is at Kendall
  distance at least `618112` from perfect alignment, and the *margin* to the floor is worth a
  further `11188` swaps (cycle 1): the dial is `1.8 %` of its own erosion distance away from
  the floor.

### B. The crossing dichotomy, and its undecidability at the recorded resolution (Section 2)

* `fadeSeq` — the one-parameter fade model `ρ_j = L + a λ^j`.
* `fade_never_below_of_floor_le` — if the model floor `L` is at or above the band floor, the
  trajectory never crosses (any `a, λ ≥ 0`).
* `fade_eventually_below_of_floor_lt` — if `L` is below the band floor and `λ < 1`, the
  trajectory eventually crosses.
* `fade_crossing_dichotomy` — hence for a contractive fade, *eventual crossing is exactly the
  statement `L < bandFloor`*: the crossing test is a test about `L`, not about any rung.
* `modelA_fits`, `modelB_fits` — two explicit fades both reproducing the recorded rungs
  `(84, 0.558)`, `(92, 0.563)`, `(96, 0.5739)` to within the margin `0.008` itself.
* `crossing_undecidable_at_margin_resolution` — **the main theorem of this cycle**: one of
  those two models never crosses and the other eventually does.  At the resolution of the
  recorded margin the two are indistinguishable, so the recorded verdict "approaching, not
  crossed" cannot be upgraded to any prediction about crossing: the data does not locate `L`
  to within the margin.  This is the exact sense in which the erosion is "gradual, not a
  cliff": a cliff would separate the models, a gradual slope does not.

## Lab notes (derived quantities)

```
quadratic budget (n=4096, from identity to 0.558) : K >= 35576
linear budget    (n=4096, from identity to 0.558) : K >= 618112     (dominant)
margin budget    (n=4096, 0.558 -> below 0.55)    : K >= 11188      (cycle 1)
margin / erosion distance                          : 11188/618112 = 1.81 %
model A: L = 0.5659  a = 1e-6    lam = 1/2     -> never crosses      (L > 0.55)
model B: L = 0.549   a = 0.017   lam = 0.998   -> crosses eventually (L < 0.55)
both fit rungs 84/92/96 within eta = 0.008 = the recorded margin
```
-/

open Finset
open Catalog.Novelty.TDialU84ApproachNotCrossed
open Catalog.Novelty.TDialU84ErosionMetrics

namespace Catalog.Novelty.TDialU84CrossingDichotomy

/-! ## 1. The quadratic (`ℓ¹`) crossing budget -/

/-- The `ℓ¹` rank displacement `∑_{k<n} |s k − k|`. -/
def sumAbsDev (n : ℕ) (s : ℕ → ℤ) : ℤ := ∑ k ∈ Finset.range n, |s k - (k : ℤ)|

/-- An adjacent transposition changes the `ℓ¹` displacement by at most `2`. -/
theorem sumAbsDev_transposeAt_le {n i : ℕ} (s : ℕ → ℤ) (hi : i < n) (hj : i + 1 < n) :
    sumAbsDev n (transposeAt i (i + 1) s) ≤ sumAbsDev n s + 2 := by
  have hij : i ≠ i + 1 := by omega
  have hsub : ({i, i + 1} : Finset ℕ) ⊆ Finset.range n := by
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl <;> simp [Finset.mem_range, hi, hj]
  have key : sumAbsDev n (transposeAt i (i + 1) s) - sumAbsDev n s
      = ∑ k ∈ Finset.range n, (|transposeAt i (i + 1) s k - (k : ℤ)| - |s k - (k : ℤ)|) := by
    simp [sumAbsDev, Finset.sum_sub_distrib]
  have h2 : sumAbsDev n (transposeAt i (i + 1) s) - sumAbsDev n s ≤ 2 := by
    rw [key, ← Finset.sum_subset hsub]
    · rw [Finset.sum_pair hij]
      simp only [transposeAt, if_neg hij.symm, if_pos]
      have e1 : |s (i + 1) - (i : ℤ)| ≤ |s (i + 1) - ((i : ℤ) + 1)| + 1 := by
        have h := abs_sub_abs_le_abs_sub (s (i + 1) - (i : ℤ)) (s (i + 1) - ((i : ℤ) + 1))
        have h' : |(s (i + 1) - (i : ℤ)) - (s (i + 1) - ((i : ℤ) + 1))| = 1 := by simp
        omega
      have e2 : |s i - ((i : ℤ) + 1)| ≤ |s i - (i : ℤ)| + 1 := by
        have h := abs_sub_abs_le_abs_sub (s i - ((i : ℤ) + 1)) (s i - (i : ℤ))
        have h' : |(s i - ((i : ℤ) + 1)) - (s i - (i : ℤ))| = 1 := by simp
        omega
      push_cast
      omega
    · intro x _ hx
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hx
      simp [transposeAt, hx.1, hx.2]
  omega

/-- Cauchy–Schwarz in its crudest useful form: `∑ d² ≤ (∑ |d|)²`. -/
theorem sumSqDev_le_sq_sumAbsDev (n : ℕ) (s : ℕ → ℤ) :
    sumSqDev n s ≤ (sumAbsDev n s) ^ 2 := by
  have h1 : sumSqDev n s = ∑ k ∈ Finset.range n, |s k - (k : ℤ)| ^ 2 := by
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [sq_abs]
  rw [h1, sumAbsDev]
  exact Finset.sum_sq_le_sq_sum_of_nonneg fun i _ => abs_nonneg _

/-- The identity ranking has zero `ℓ¹` displacement. -/
theorem sumAbsDev_idVec (n : ℕ) : sumAbsDev n idVec = 0 := by
  simp [sumAbsDev, idVec]

/-- **Displacement accumulates at rate `2` per adjacent transposition.** -/
theorem sumAbsDev_chain_le {n : ℕ} :
    ∀ (l : List (ℕ × ℕ)) (s : ℕ → ℤ), AdjacentChain n l →
      sumAbsDev n (applyTs l s) ≤ sumAbsDev n s + 2 * (l.length : ℤ) := by
  intro l
  induction l with
  | nil => intro s _; simp [applyTs]
  | cons p t ih =>
      intro s hl
      obtain ⟨i, j⟩ := p
      obtain ⟨hj1, hj2⟩ : j = i + 1 ∧ j < n := hl (i, j) (by simp)
      subst hj1
      have hi : i < n := by omega
      have hstep := sumAbsDev_transposeAt_le (n := n) (i := i) s hi hj2
      have hl' : AdjacentChain n t := fun p hp => hl p (by simp [hp])
      have hrec := ih (transposeAt i (i + 1) s) hl'
      have hlen : (((i, i + 1) :: t).length : ℤ) = (t.length : ℤ) + 1 := by
        simp [List.length_cons]
      simp only [applyTs, hlen]
      omega

/-- **The quadratic crossing budget.**  Any ranking reachable from the identity by `K`
adjacent transpositions has Spearman correlation at least `1 − 24 K²/(n(n²−1))`. -/
theorem spearman_ge_of_chain_from_id {n : ℕ} (hn : 2 ≤ n) (l : List (ℕ × ℕ))
    (hl : AdjacentChain n l) :
    1 - 24 * (l.length : ℚ) ^ 2 / ((n : ℚ) * ((n : ℚ) ^ 2 - 1))
      ≤ spearman n (applyTs l idVec) := by
  have hD := spearman_denom_pos hn
  have hL : sumAbsDev n (applyTs l idVec) ≤ 2 * (l.length : ℤ) := by
    have := sumAbsDev_chain_le l idVec hl
    rw [sumAbsDev_idVec] at this
    omega
  have hL0 : 0 ≤ sumAbsDev n (applyTs l idVec) :=
    Finset.sum_nonneg fun k _ => abs_nonneg _
  have hsq : sumSqDev n (applyTs l idVec) ≤ 4 * (l.length : ℤ) ^ 2 := by
    have h1 := sumSqDev_le_sq_sumAbsDev n (applyTs l idVec)
    nlinarith [hL, hL0]
  have hsqQ : (sumSqDev n (applyTs l idVec) : ℚ) ≤ 4 * (l.length : ℚ) ^ 2 := by
    exact_mod_cast hsq
  unfold spearman
  rw [sub_le_sub_iff_left, div_le_div_iff₀ hD hD]
  nlinarith [hsqQ, hD]

/-- **The U84 reading as a Kendall distance, quadratic bound.**  At `n = 4096`, producing the
recorded pooled reading `0.558` from a perfectly aligned ranking takes at least `35576`
adjacent transpositions. -/
theorem u84_kendall_quadratic_budget (l : List (ℕ × ℕ)) (hl : AdjacentChain 4096 l)
    (hend : spearman 4096 (applyTs l idVec) ≤ pooled84) :
    35576 ≤ l.length := by
  have hb := spearman_ge_of_chain_from_id (n := 4096) (by norm_num) l hl
  have hkey : (442 : ℚ) / 1000 ≤ 24 * (l.length : ℚ) ^ 2 / ((4096 : ℚ) * ((4096 : ℚ) ^ 2 - 1)) := by
    have : ((4096 : ℕ) : ℚ) = (4096 : ℚ) := by norm_num
    rw [this] at hb
    have hp : pooled84 = 558 / 1000 := rfl
    rw [hp] at hend
    linarith [hb, hend]
  rw [le_div_iff₀ (by norm_num)] at hkey
  by_contra hcon
  push_neg at hcon
  have hq : (l.length : ℚ) ≤ 35575 := by
    have : l.length ≤ 35575 := by omega
    exact_mod_cast this
  have hnn : (0 : ℚ) ≤ (l.length : ℚ) := by positivity
  nlinarith [hkey, hq, hnn]

/-- **The U84 reading as a Kendall distance, linear bound.**  The cycle-1 bound gives
`≥ 618112` adjacent transpositions at `n = 4096` — an order of magnitude stronger than the
quadratic one at this sample size. -/
theorem u84_kendall_linear_budget (l : List (ℕ × ℕ)) (hl : AdjacentChain 4096 l)
    (hend : spearman 4096 (applyTs l idVec) ≤ pooled84) :
    618112 ≤ l.length := by
  have hdrop : (442 : ℚ) / 1000 ≤ spearman 4096 idVec - spearman 4096 (applyTs l idVec) := by
    rw [spearman_idVec (by norm_num)]
    have hp : pooled84 = 558 / 1000 := rfl
    rw [hp] at hend
    linarith
  have hbudget :=
    adjacent_swaps_to_cross (n := 4096) (by norm_num) l idVec hl (rankBounded_idVec 4096) hdrop
  norm_num at hbudget
  by_contra hcon
  push_neg at hcon
  have hq : (l.length : ℚ) ≤ 618111 := by
    have : l.length ≤ 618111 := by omega
    exact_mod_cast this
  linarith

/-- The linear budget dominates the quadratic one at the recorded sample size, and the margin
to the floor is `1.8 %` of the erosion distance already travelled. -/
theorem u84_linear_dominates_quadratic :
    (35576 : ℚ) < 618112 ∧ 11188 * 55 < (618112 : ℚ) := by
  constructor <;> norm_num

/-! ## 2. The crossing dichotomy -/

/-- The one-parameter fade model `ρ_j = L + a λ^j`. -/
def fadeSeq (L a lam : ℚ) (j : ℕ) : ℚ := L + a * lam ^ j

/-- **No crossing above the floor.**  If the model floor is at or above the band floor, the
trajectory stays in the band forever. -/
theorem fade_never_below_of_floor_le {L a lam : ℚ} (hL : bandFloor ≤ L) (ha : 0 ≤ a)
    (hlam : 0 ≤ lam) : ∀ j, bandFloor ≤ fadeSeq L a lam j := by
  intro j
  have : 0 ≤ a * lam ^ j := mul_nonneg ha (pow_nonneg hlam j)
  simp only [fadeSeq]
  linarith

/-- **Crossing below the floor.**  If the model floor is below the band floor and the fade is
contractive (`λ < 1`; nonnegativity of `λ` is not needed), the trajectory eventually leaves
the band. -/
theorem fade_eventually_below_of_floor_lt {L a lam : ℚ} (hL : L < bandFloor) (ha : 0 < a)
    (hlam1 : lam < 1) : ∃ j, fadeSeq L a lam j < bandFloor := by
  obtain ⟨j, hj⟩ := exists_pow_lt_of_lt_one (x := (bandFloor - L) / a) (y := lam)
    (div_pos (by linarith) ha) hlam1
  refine ⟨j, ?_⟩
  have hmul : a * lam ^ j < bandFloor - L := by
    rw [lt_div_iff₀ ha] at hj
    linarith [hj]
  simp only [fadeSeq]
  linarith

/-- **The crossing dichotomy.**  For a contractive fade with positive amplitude, eventual
crossing of the band floor is *equivalent* to the model floor lying below it.  The crossing
test is therefore a test about `L`, not about any individual rung. -/
theorem fade_crossing_dichotomy {L a lam : ℚ} (ha : 0 < a) (hlam0 : 0 ≤ lam) (hlam1 : lam < 1) :
    (∃ j, fadeSeq L a lam j < bandFloor) ↔ L < bandFloor := by
  constructor
  · intro ⟨j, hj⟩
    by_contra hcon
    push_neg at hcon
    exact absurd (fade_never_below_of_floor_le hcon ha.le hlam0 j) (not_le.mpr hj)
  · intro hL
    exact fade_eventually_below_of_floor_lt hL ha hlam1

/-- Model A: floor `0.5659`, above the band floor. -/
def modelA : ℚ × ℚ × ℚ := (5659 / 10000, 1 / 1000000, 1 / 2)
/-- Model B: floor `0.549`, below the band floor. -/
def modelB : ℚ × ℚ × ℚ := (549 / 1000, 17 / 1000, 499 / 500)

/-- Model A reproduces the recorded rungs `84, 92, 96` to within the recorded margin. -/
theorem modelA_fits :
    |fadeSeq modelA.1 modelA.2.1 modelA.2.2 0 - rung84| ≤ margin84 ∧
    |fadeSeq modelA.1 modelA.2.1 modelA.2.2 1 - rung92| ≤ margin84 ∧
    |fadeSeq modelA.1 modelA.2.1 modelA.2.2 2 - rung96| ≤ margin84 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    · rw [abs_le]
      constructor <;>
        norm_num [fadeSeq, modelA, rung84, rung92, rung96, pooled84, margin84, bandFloor]

/-- Model B reproduces the same rungs to within the same margin. -/
theorem modelB_fits :
    |fadeSeq modelB.1 modelB.2.1 modelB.2.2 0 - rung84| ≤ margin84 ∧
    |fadeSeq modelB.1 modelB.2.1 modelB.2.2 1 - rung92| ≤ margin84 ∧
    |fadeSeq modelB.1 modelB.2.1 modelB.2.2 2 - rung96| ≤ margin84 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    · rw [abs_le]
      constructor <;>
        norm_num [fadeSeq, modelB, rung84, rung92, rung96, pooled84, margin84, bandFloor]

/-- **Crossing is undecidable at the recorded resolution.**  Two contractive fades reproduce
the recorded rungs `84, 92, 96` to within the recorded margin `0.008`; one of them never
leaves the band, the other eventually does.  Hence no prediction about the crossing can be
extracted from the recorded ladder at its own resolution — which is precisely the content of
"the erosion is gradual, not a cliff". -/
theorem crossing_undecidable_at_margin_resolution :
    (∀ j, bandFloor ≤ fadeSeq modelA.1 modelA.2.1 modelA.2.2 j) ∧
    (∃ j, fadeSeq modelB.1 modelB.2.1 modelB.2.2 j < bandFloor) ∧
    (|fadeSeq modelA.1 modelA.2.1 modelA.2.2 0 - rung84| ≤ margin84 ∧
      |fadeSeq modelA.1 modelA.2.1 modelA.2.2 1 - rung92| ≤ margin84 ∧
      |fadeSeq modelA.1 modelA.2.1 modelA.2.2 2 - rung96| ≤ margin84) ∧
    (|fadeSeq modelB.1 modelB.2.1 modelB.2.2 0 - rung84| ≤ margin84 ∧
      |fadeSeq modelB.1 modelB.2.1 modelB.2.2 1 - rung92| ≤ margin84 ∧
      |fadeSeq modelB.1 modelB.2.1 modelB.2.2 2 - rung96| ≤ margin84) := by
  refine ⟨?_, ?_, modelA_fits, modelB_fits⟩
  · exact fade_never_below_of_floor_le (by norm_num [modelA, bandFloor]) (by norm_num [modelA])
      (by norm_num [modelA])
  · exact fade_eventually_below_of_floor_lt (by norm_num [modelB, bandFloor])
      (by norm_num [modelB]) (by norm_num [modelB])

end Catalog.Novelty.TDialU84CrossingDichotomy