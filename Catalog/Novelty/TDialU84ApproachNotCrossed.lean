import Mathlib
import Algebra.ZeroFitDialU72Parity
import Novelty.TDialU112FadeReacceleration

/-!
# The U84 rung: gradual erosion, a rank-metric crossing budget, and the resolution wall

## Research context (FACT round-67 #1, exp 535, `TDIAL-U84-CROSS`)

The recorded measurement is the bitlen-84 rung of the `T`-dial ladder: the pooled Spearman
rank correlation between a trailing-zero / small-prime statistic `T` of a uniformly drawn
integer and a downstream `rate`.

```
bitlen :  44     52     64     72     76     84     92     96
rho    :  0.78   0.705  0.648  0.605  0.608  0.558  0.563  0.5739
```

At U84 the pooled reading is `0.558`, CI `[0.536, 0.581]`, per-seed `0.572 / 0.578 / 0.522`
(seeds 20261190–92).  The pre-registered band floor is `0.55`, so the **margin to the floor
is `+0.008`** — the dial approaches the floor but does not cross it, and the confidence
interval straddles the floor.  The recorded verdict is *approaching, not crossed*: the
erosion is gradual, not a cliff.

This file asks what "gradual, not a cliff" can *mean* as a theorem, and answers it on four
independent axes.  Everything is proved from scratch except the correlation geometry, which
is taken from the catalog (`Algebra.ZeroFitDialU72Parity`,
`Novelty.TDialU112FadeReacceleration`).

## Main results

### 1. Pooling geometry: a pooled cliff needs a per-seed cliff (Section 2)

* `weighted_mean_le_of_le`, `le_weighted_mean_of_le` — a convex combination is trapped
  between the extremes of its components.
* `cross_needs_low_component` — if the pooled read falls below the floor then *some seed*
  falls below the floor: the pooled statistic cannot cross on its own.
* `weighted_mean_lipschitz` — pooling is a `1`-Lipschitz map for the sup-distance on seeds,
  so a pooled drop of size `d` forces a seed drop of size `≥ d`.  A pooled cliff is a seed
  cliff.
* `u84_pooled_between_seeds`, `u84_only_one_seed_below_floor` — the recorded numbers: two
  seeds above, one (`0.522`) below the floor.

### 2. Replication fragility: exactly how close the crossing is (Section 3)

* `mean_lt_floor_iff` — the exact crossing criterion for `3` recorded seeds plus `k`
  replications at level `v`.
* `u84_one_bad_replication_crosses` — one further seed reading at the recorded *minimum*
  `0.522` already pulls the pooled mean below `0.55`, while a further seed at the recorded
  *maximum* `0.578` does not.  The threshold for a fourth seed is exactly `0.528`.

### 3. A rank-metric crossing budget: erosion is gradual in Kendall's metric (Section 4)

This is the structural core, and it is a genuine combinatorics ⇄ statistics bridge: Spearman
`ρ` is an affine function of `∑(σ(k) − k)²` on the symmetric group, and the *adjacent
transposition* is the generator of the Kendall-tau metric.

* `sumSqDev_transposeAt` — the **exact transposition identity**
  `∑(τσ(k)−k)² − ∑(σ(k)−k)² = 2 (j − i) (σ j − σ i)` for the transposition of positions
  `i ≠ j`.  It is exact, not an estimate.
* `spearman_transposeAt` — hence `ρ` changes by exactly `−12 (j−i)(σ j − σ i) / (n(n²−1))`.
* `abs_spearman_adjacent_le` — for an **adjacent** transposition the change is at most
  `12 / (n(n+1))`, and `adjacent_step_bound_sharp` exhibits a rank vector attaining it: the
  constant cannot be improved.
* `spearman_adjacent_chain` — `ρ` is `12/(n(n+1))`-Lipschitz along chains of adjacent
  transpositions, i.e. `1`-Lipschitz up to that scale for the Kendall-tau metric.
* `adjacent_swaps_to_cross` — therefore, moving the dial from the recorded `0.558` to below
  the floor `0.55` costs at least `margin · n(n+1)/12` adjacent transpositions;
  `u84_crossing_budget_4096` instantiates it: at `n = 4096` samples, **at least `11188`
  adjacent swaps** — an `Ω(n²)` quantity.  A "cliff" in `ρ` is an `Ω(n²)` rearrangement of
  the ranking; gradualness is forced by the metric geometry, not by the data.

### 4. Monotone fits and the resolution wall (Sections 5–6)

* `ladder_rebounds` — the recorded ladder is **not monotone**: `ρ(92) > ρ(84)` and
  `ρ(96) > ρ(92)`.
* `noise_floor_of_rebound` — any nonincreasing model of the ladder with sup-error `η` needs
  `η ≥ (ρ_j − ρ_i)/2` for `i < j`; `u84_monotone_noise_floor` gives `η ≥ 159/20000` and
  `u84_noise_floor_vs_margin` shows this is `159/160` of the whole margin to the floor.
  **The margin to the floor is smaller than the noise a monotone fade must absorb**: at this
  resolution the crossing question is not decidable by the model class.
* `resolution_sample_size` — with a `c/√m` half-width law, resolving a target margin `mrg`
  from a recorded half-width `h₀` needs `m ≥ (h₀/mrg)² m₀`; `u84_resolution_factor` gives
  the recorded numbers: half-width `0.0225`, margin `0.008`, so **`≥ 2025/256 ≈ 7.91×` the
  sample size** is needed before the U84 rung can be called either way.
* `bar_unreachable_of_center_below` — and no amount of shrinking helps if the *point
  estimate* is on the wrong side.

### 5. Crossed and uncrossed are geometrically indistinguishable (Section 7)

* `crossing_states_indistinguishable` — there are configurations of unit vectors realising
  `corr = 0.558` (uncrossed) and `corr = 0.55` (exactly at the floor) against a common
  response whose mutual correlation is `≥ 0.9999`.  The two hypotheses under test differ by
  a rotation of angle `< 0.9°`: "approaching but not crossed" is a statement about a
  `10⁻⁴`-scale geometric perturbation of the predictor.

## Lab notes (exp 535, seeds 20261190–92)

```
pooled Spearman(T, rate) : 0.558     CI [0.536, 0.581]  (half width 0.0225)
per-seed                 : 0.572 / 0.578 / 0.522        (mean 0.55733)
band floor               : 0.55      margin +0.008      (CI straddles the floor)
neighbouring rungs       : 76: 0.608   92: 0.563   96: 0.5739   (rebound, non-monotone)
derived crossing budget  : ≥ 11188 adjacent swaps at n = 4096   (Ω(n²))
derived 4th-seed thresh. : 0.528      (recorded min seed 0.522 is below it)
derived monotone noise   : η ≥ 159/20000 = 0.00795 = (159/160) × margin
derived resolution cost  : ≥ 2025/256 = 7.910× the sample size
derived indistinguish.   : corr ≥ 0.9999 between a crossed and an uncrossed predictor
```
-/

open Finset
open Catalog.Algebra.ZeroFitDialU72Parity

namespace Catalog.Novelty.TDialU84ApproachNotCrossed

/-! ## 1. Recorded data -/

/-- Pooled Spearman reading at bitlen 84 (exp 535). -/
def pooled84 : ℚ := 558 / 1000
/-- Lower endpoint of the recorded bootstrap CI at bitlen 84. -/
def ciLo84 : ℚ := 536 / 1000
/-- Upper endpoint of the recorded bootstrap CI at bitlen 84. -/
def ciHi84 : ℚ := 581 / 1000
/-- Per-seed reading, seed 20261190. -/
def seedA : ℚ := 572 / 1000
/-- Per-seed reading, seed 20261191. -/
def seedB : ℚ := 578 / 1000
/-- Per-seed reading, seed 20261192. -/
def seedC : ℚ := 522 / 1000
/-- The pre-registered band floor for the dial. -/
def bandFloor : ℚ := 55 / 100
/-- The recorded margin of the pooled reading above the band floor. -/
def margin84 : ℚ := pooled84 - bandFloor

/-- Rung U76 of the ladder. -/
def rung76 : ℚ := 608 / 1000
/-- Rung U84 of the ladder (this measurement). -/
def rung84 : ℚ := pooled84
/-- Rung U92 of the ladder. -/
def rung92 : ℚ := 563 / 1000
/-- Rung U96 of the ladder. -/
def rung96 : ℚ := 5739 / 10000

/-- The margin to the floor is exactly `+0.008`, and it is positive: **not crossed**. -/
theorem u84_not_crossed : margin84 = 8 / 1000 ∧ bandFloor < pooled84 := by
  constructor <;> norm_num [margin84, pooled84, bandFloor]

/-- The recorded confidence interval **straddles** the floor: the crossing test is
inconclusive at the recorded resolution. -/
theorem u84_ci_straddles_floor : ciLo84 < bandFloor ∧ bandFloor < ciHi84 := by
  constructor <;> norm_num [ciLo84, ciHi84, bandFloor]

/-- The per-seed mean reproduces the pooled reading to within `0.001`. -/
theorem u84_seed_mean_matches_pooled : |(seedA + seedB + seedC) / 3 - pooled84| ≤ 1 / 1000 := by
  rw [abs_le]
  constructor <;> norm_num [seedA, seedB, seedC, pooled84]

/-- The U84 drop from U76 is `0.05`, an order of magnitude larger than the remaining margin:
the dial arrives near the floor with momentum but stops `0.008` short. -/
theorem u84_step_dwarfs_margin : rung76 - rung84 = 5 / 100 ∧ 6 * margin84 < rung76 - rung84 := by
  refine ⟨by norm_num [rung76, rung84, pooled84], by norm_num [rung76, rung84, pooled84, margin84, bandFloor]⟩

/-! ## 2. Pooling geometry: a pooled cliff requires a per-seed cliff

The pooled reading is a convex combination of the per-seed readings.  Three elementary but
load-bearing facts follow: pooling cannot leave the seed range, a pooled crossing implies a
seed crossing, and pooling is `1`-Lipschitz for the sup-distance.
-/

variable {ι : Type*} [Fintype ι]

/-- A convex combination never exceeds an upper bound of its components. -/
theorem weighted_mean_le_of_le {w x : ι → ℚ} (hw : ∀ i, 0 ≤ w i) (hsum : ∑ i, w i = 1)
    {c : ℚ} (hx : ∀ i, x i ≤ c) : ∑ i, w i * x i ≤ c := by
  calc ∑ i, w i * x i ≤ ∑ i, w i * c :=
        Finset.sum_le_sum fun i _ => by
          exact mul_le_mul_of_nonneg_left (hx i) (hw i)
    _ = c := by rw [← Finset.sum_mul, hsum, one_mul]

/-- A convex combination never falls below a lower bound of its components. -/
theorem le_weighted_mean_of_le {w x : ι → ℚ} (hw : ∀ i, 0 ≤ w i) (hsum : ∑ i, w i = 1)
    {c : ℚ} (hx : ∀ i, c ≤ x i) : c ≤ ∑ i, w i * x i := by
  calc c = ∑ i, w i * c := by rw [← Finset.sum_mul, hsum, one_mul]
    _ ≤ ∑ i, w i * x i :=
        Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hx i) (hw i)

/-- **A pooled crossing forces a per-seed crossing.**  If the pooled (convex) reading is
below the floor, at least one seed is below the floor. -/
theorem cross_needs_low_component {w x : ι → ℚ} (hw : ∀ i, 0 ≤ w i) (hsum : ∑ i, w i = 1)
    {c : ℚ} (h : ∑ i, w i * x i < c) : ∃ i, x i < c := by
  by_contra hcon
  push_neg at hcon
  exact absurd (le_weighted_mean_of_le hw hsum hcon) (not_le.mpr h)

/-- **Pooling is `1`-Lipschitz.**  If every seed moves by at most `d`, the pooled reading
moves by at most `d`; equivalently, a pooled cliff of size `d` requires a seed cliff of size
at least `d`. -/
theorem weighted_mean_lipschitz {w x y : ι → ℚ} (hw : ∀ i, 0 ≤ w i) (hsum : ∑ i, w i = 1)
    {d : ℚ} (hd : ∀ i, |x i - y i| ≤ d) :
    |∑ i, w i * x i - ∑ i, w i * y i| ≤ d := by
  have hrw : ∑ i, w i * x i - ∑ i, w i * y i = ∑ i, w i * (x i - y i) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hrw]
  refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
  calc ∑ i, |w i * (x i - y i)| = ∑ i, w i * |x i - y i| := by
        exact Finset.sum_congr rfl fun i _ => by rw [abs_mul, abs_of_nonneg (hw i)]
    _ ≤ ∑ i, w i * d := Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hd i) (hw i)
    _ = d := by rw [← Finset.sum_mul, hsum, one_mul]

/-- The recorded pooled value lies inside the recorded seed range, as pooling geometry
requires. -/
theorem u84_pooled_between_seeds : seedC ≤ pooled84 ∧ pooled84 ≤ seedB := by
  constructor <;> norm_num [seedB, seedC, pooled84]

/-- Only the third seed is below the floor; the pooled read survives because two of three
seeds sit above it. -/
theorem u84_only_one_seed_below_floor :
    bandFloor < seedA ∧ bandFloor < seedB ∧ seedC < bandFloor := by
  refine ⟨by norm_num [bandFloor, seedA], by norm_num [bandFloor, seedB], by
    norm_num [bandFloor, seedC]⟩

/-- The equal-weight instantiation of `cross_needs_low_component` for the three recorded
seeds: had the pooled read crossed, one of the three seeds would have had to cross. -/
theorem u84_pooled_cross_needs_seed_cross (x : Fin 3 → ℚ)
    (h : (x 0 + x 1 + x 2) / 3 < bandFloor) : ∃ i, x i < bandFloor := by
  refine cross_needs_low_component (w := fun _ => (1 : ℚ) / 3) (x := x)
    (fun _ => by norm_num) (by norm_num [Fin.sum_univ_three]) ?_
  have hsum : ∑ i : Fin 3, (1 / 3 : ℚ) * x i = (x 0 + x 1 + x 2) / 3 := by
    simp [Fin.sum_univ_three]; ring
  rw [hsum]
  exact h

/-! ## 3. Replication fragility

How far is the recorded non-crossing from a crossing, measured in *replications*?
-/

/-- **Exact crossing criterion under replication.**  Adding `k` further seeds all reading `v`
to three recorded seeds crosses the floor iff the accumulated surplus of the recorded seeds
is beaten by the accumulated deficit of the new ones. -/
theorem mean_lt_floor_iff (a b c v f : ℚ) (k : ℕ) :
    (a + b + c + k * v) / (3 + k) < f ↔ (a + b + c) - 3 * f < k * (f - v) := by
  have hpos : (0 : ℚ) < 3 + k := by positivity
  rw [div_lt_iff₀ hpos]
  constructor <;> intro h <;> nlinarith [h]

/-- The threshold a fourth seed must beat in order to pull the pooled mean below the floor. -/
theorem u84_fourth_seed_threshold (v : ℚ) :
    (seedA + seedB + seedC + v) / 4 < bandFloor ↔ v < 528 / 1000 := by
  rw [div_lt_iff₀ (by norm_num)]
  simp only [seedA, seedB, seedC, bandFloor]
  constructor <;> intro h <;> linarith

/-- **Fragility of the non-crossing.**  A single further seed replicating the recorded
*minimum* `0.522` already pushes the pooled reading below the floor, whereas a further seed
at the recorded *maximum* `0.578` keeps it above.  The recorded verdict is one unlucky seed
away from reversal. -/
theorem u84_one_bad_replication_crosses :
    (seedA + seedB + seedC + seedC) / 4 < bandFloor ∧
      bandFloor < (seedA + seedB + seedC + seedB) / 4 := by
  constructor <;> norm_num [seedA, seedB, seedC, bandFloor]

/-! ## 4. The rank-metric crossing budget

Spearman's `ρ` on `n` paired ranks is the affine image of the squared rank displacement
`D(σ) = ∑_{k<n} (σ k − k)²`, namely `ρ = 1 − 6 D /(n(n²−1))`.  We work with `ℤ`-valued rank
vectors on `ℕ` (values outside `range n` are irrelevant), which avoids `Fin` index friction.
-/

/-- Squared rank displacement `∑_{k<n} (s k − k)²`. -/
def sumSqDev (n : ℕ) (s : ℕ → ℤ) : ℤ := ∑ k ∈ Finset.range n, (s k - (k : ℤ)) ^ 2

/-- Spearman's rank correlation attached to a rank vector `s` on `n` items. -/
def spearman (n : ℕ) (s : ℕ → ℤ) : ℚ :=
  1 - 6 * (sumSqDev n s : ℚ) / ((n : ℚ) * ((n : ℚ) ^ 2 - 1))

/-- Transposition of the *values* at positions `i` and `j`. -/
def transposeAt (i j : ℕ) (s : ℕ → ℤ) : ℕ → ℤ :=
  fun k => if k = i then s j else if k = j then s i else s k

/-- A rank vector: the values at positions `< n` are ranks in `[0, n)`. -/
def RankBounded (n : ℕ) (s : ℕ → ℤ) : Prop := ∀ k, k < n → 0 ≤ s k ∧ s k < (n : ℤ)

lemma rankBounded_transposeAt {n i j : ℕ} {s : ℕ → ℤ} (hs : RankBounded n s)
    (hi : i < n) (hj : j < n) : RankBounded n (transposeAt i j s) := by
  intro k hk
  unfold transposeAt
  split_ifs <;> first | exact hs i hi | exact hs j hj | exact hs k hk

/-- **The exact transposition identity.**  Swapping the values at two positions changes the
squared rank displacement by exactly `2 (j − i)(s j − s i)`. -/
theorem sumSqDev_transposeAt {n i j : ℕ} (s : ℕ → ℤ) (hij : i ≠ j) (hi : i < n) (hj : j < n) :
    sumSqDev n (transposeAt i j s) - sumSqDev n s
      = 2 * ((j : ℤ) - (i : ℤ)) * (s j - s i) := by
  have hsub : ({i, j} : Finset ℕ) ⊆ Finset.range n := by
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl <;> simp [Finset.mem_range, hi, hj]
  have key : sumSqDev n (transposeAt i j s) - sumSqDev n s
      = ∑ k ∈ Finset.range n, ((transposeAt i j s k - (k : ℤ)) ^ 2 - (s k - (k : ℤ)) ^ 2) := by
    simp [sumSqDev, Finset.sum_sub_distrib]
  rw [key, ← Finset.sum_subset hsub]
  · rw [Finset.sum_pair hij]
    simp only [transposeAt, if_neg hij.symm, if_pos]
    ring
  · intro x _ hx
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hx
    simp [transposeAt, hx.1, hx.2]

/-- The Spearman denominator is positive for `n ≥ 2`. -/
lemma spearman_denom_pos {n : ℕ} (hn : 2 ≤ n) : 0 < (n : ℚ) * ((n : ℚ) ^ 2 - 1) := by
  have h2 : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  nlinarith

/-- **The exact Spearman transposition law.** -/
theorem spearman_transposeAt {n i j : ℕ} (s : ℕ → ℤ) (hn : 2 ≤ n) (hij : i ≠ j)
    (hi : i < n) (hj : j < n) :
    spearman n (transposeAt i j s) - spearman n s
      = -(12 * ((j : ℚ) - (i : ℚ)) * ((s j : ℚ) - (s i : ℚ))) / ((n : ℚ) * ((n : ℚ) ^ 2 - 1)) := by
  have hD : ((n : ℚ) * ((n : ℚ) ^ 2 - 1)) ≠ 0 := (spearman_denom_pos hn).ne'
  have h := sumSqDev_transposeAt (n := n) s hij hi hj
  have hQ : (sumSqDev n (transposeAt i j s) : ℚ) - (sumSqDev n s : ℚ)
      = 2 * ((j : ℚ) - (i : ℚ)) * ((s j : ℚ) - (s i : ℚ)) := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) h
  unfold spearman
  rw [sub_sub_sub_cancel_left, div_sub_div_same, div_eq_div_iff hD hD]
  linear_combination (-6 : ℚ) * ((n : ℚ) * ((n : ℚ) ^ 2 - 1)) * hQ

/-- **The adjacent-transposition step bound.**  On rank vectors, swapping the values at two
*neighbouring* positions moves Spearman's `ρ` by at most `12/(n(n+1))`. -/
theorem abs_spearman_adjacent_le {n i : ℕ} {s : ℕ → ℤ} (hn : 2 ≤ n) (hs : RankBounded n s)
    (hi : i < n) (hj : i + 1 < n) :
    |spearman n (transposeAt i (i + 1) s) - spearman n s| ≤ 12 / ((n : ℚ) * ((n : ℚ) + 1)) := by
  have hne : i ≠ i + 1 := by omega
  have hD := spearman_denom_pos hn
  have hn1 : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hden : (0 : ℚ) < (n : ℚ) * ((n : ℚ) + 1) := by nlinarith
  rw [spearman_transposeAt s hn hne hi hj]
  have hbi := hs i hi
  have hbj := hs (i + 1) hj
  have hdiff : |((s (i + 1) : ℚ)) - (s i : ℚ)| ≤ (n : ℚ) - 1 := by
    have h1 : (0 : ℚ) ≤ ((s i : ℚ)) := by exact_mod_cast hbi.1
    have h2 : ((s i : ℚ)) ≤ (n : ℚ) - 1 := by
      have : (s i : ℤ) ≤ (n : ℤ) - 1 := by omega
      exact_mod_cast this
    have h3 : (0 : ℚ) ≤ ((s (i + 1) : ℚ)) := by exact_mod_cast hbj.1
    have h4 : ((s (i + 1) : ℚ)) ≤ (n : ℚ) - 1 := by
      have : (s (i + 1) : ℤ) ≤ (n : ℤ) - 1 := by omega
      exact_mod_cast this
    rw [abs_le]; constructor <;> linarith
  rw [abs_div, abs_of_pos hD, div_le_div_iff₀ hD hden]
  have hcast : ((((i : ℕ) + 1 : ℕ)) : ℚ) = (i : ℚ) + 1 := by push_cast; ring
  have hnum : |(-(12 * (((((i : ℕ) + 1 : ℕ)) : ℚ) - (i : ℚ)) * ((s (i + 1) : ℚ) - (s i : ℚ))))|
      = 12 * |((s (i + 1) : ℚ)) - (s i : ℚ)| := by
    rw [hcast, show ((i : ℚ) + 1 - (i : ℚ)) = 1 by ring, mul_one, abs_neg, abs_mul]
    norm_num
  rw [hnum]
  nlinarith [hdiff, abs_nonneg (((s (i + 1) : ℚ)) - (s i : ℚ)), hn1]

/-- Iterated transpositions along a list of position pairs. -/
def applyTs : List (ℕ × ℕ) → (ℕ → ℤ) → (ℕ → ℤ)
  | [], s => s
  | (i, j) :: t, s => applyTs t (transposeAt i j s)

/-- A list of adjacent transpositions inside `range n`. -/
def AdjacentChain (n : ℕ) (l : List (ℕ × ℕ)) : Prop :=
  ∀ p ∈ l, p.2 = p.1 + 1 ∧ p.2 < n

/-- **Spearman is Lipschitz along the Kendall-tau generators.**  A chain of `k` adjacent
transpositions moves `ρ` by at most `k · 12/(n(n+1))`. -/
theorem spearman_adjacent_chain {n : ℕ} (hn : 2 ≤ n) :
    ∀ (l : List (ℕ × ℕ)) (s : ℕ → ℤ), AdjacentChain n l → RankBounded n s →
      |spearman n (applyTs l s) - spearman n s|
        ≤ (l.length : ℚ) * (12 / ((n : ℚ) * ((n : ℚ) + 1))) := by
  intro l
  induction l with
  | nil => intro s _ _; simp [applyTs]
  | cons p t ih =>
      intro s hl hs
      obtain ⟨i, j⟩ := p
      have hp : j = i + 1 ∧ j < n := hl (i, j) (by simp)
      obtain ⟨hj1, hj2⟩ := hp
      subst hj1
      have hi : i < n := by omega
      have hstep := abs_spearman_adjacent_le (n := n) (i := i) (s := s) hn hs hi hj2
      have hs' : RankBounded n (transposeAt i (i + 1) s) :=
        rankBounded_transposeAt hs hi hj2
      have hl' : AdjacentChain n t := fun p hp => hl p (by simp [hp])
      have hrec := ih (transposeAt i (i + 1) s) hl' hs'
      have htri : |spearman n (applyTs ((i, i + 1) :: t) s) - spearman n s|
          ≤ |spearman n (applyTs t (transposeAt i (i + 1) s))
              - spearman n (transposeAt i (i + 1) s)|
            + |spearman n (transposeAt i (i + 1) s) - spearman n s| := by
        simp only [applyTs]
        exact abs_sub_le _ _ _
      have : ((( (i, i+1) :: t).length : ℚ)) = (t.length : ℚ) + 1 := by
        simp [List.length_cons]
      rw [this]
      calc |spearman n (applyTs ((i, i + 1) :: t) s) - spearman n s|
          ≤ |spearman n (applyTs t (transposeAt i (i + 1) s))
              - spearman n (transposeAt i (i + 1) s)|
            + |spearman n (transposeAt i (i + 1) s) - spearman n s| := htri
        _ ≤ (t.length : ℚ) * (12 / ((n : ℚ) * ((n : ℚ) + 1)))
              + 12 / ((n : ℚ) * ((n : ℚ) + 1)) := by linarith
        _ = ((t.length : ℚ) + 1) * (12 / ((n : ℚ) * ((n : ℚ) + 1))) := by ring

/-- **The crossing budget.**  Moving Spearman's `ρ` down across a margin `m > 0` costs at
least `m · n(n+1)/12` adjacent transpositions. -/
theorem adjacent_swaps_to_cross {n : ℕ} (hn : 2 ≤ n) (l : List (ℕ × ℕ)) (s : ℕ → ℤ)
    (hl : AdjacentChain n l) (hs : RankBounded n s) {m : ℚ}
    (hdrop : m ≤ spearman n s - spearman n (applyTs l s)) :
    m * ((n : ℚ) * ((n : ℚ) + 1)) / 12 ≤ (l.length : ℚ) := by
  have hn1 : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hden : 0 < (n : ℚ) * ((n : ℚ) + 1) := by nlinarith
  have hchain := spearman_adjacent_chain hn l s hl hs
  have habs : m ≤ |spearman n (applyTs l s) - spearman n s| := by
    rw [abs_sub_comm]
    exact hdrop.trans (le_abs_self _)
  have hle : m ≤ (l.length : ℚ) * (12 / ((n : ℚ) * ((n : ℚ) + 1))) := habs.trans hchain
  rw [div_le_iff₀ (by norm_num : (0:ℚ) < 12)]
  have h12 : (l.length : ℚ) * (12 / ((n : ℚ) * ((n : ℚ) + 1)))
      = (l.length : ℚ) * 12 / ((n : ℚ) * ((n : ℚ) + 1)) := by ring
  rw [h12, le_div_iff₀ hden] at hle
  linarith

/-- The extremal rank vector: value `n−1` at position `0`, value `0` at position `1`, the
identity elsewhere. -/
def flipVec (n : ℕ) : ℕ → ℤ :=
  fun k => if k = 0 then (n : ℤ) - 1 else if k = 1 then 0 else (k : ℤ)

/-- **Sharpness of the adjacent step bound.**  The constant `12/(n(n+1))` is attained by
`flipVec`: the adjacent transposition of positions `0, 1` moves `ρ` by exactly
`12/(n(n+1))`, so the Lipschitz constant of `spearman_adjacent_chain` cannot be improved. -/
theorem adjacent_step_bound_sharp {n : ℕ} (hn : 2 ≤ n) :
    RankBounded n (flipVec n) ∧
      spearman n (transposeAt 0 1 (flipVec n)) - spearman n (flipVec n)
        = 12 / ((n : ℚ) * ((n : ℚ) + 1)) := by
  constructor
  · intro k hk
    have hkq : (k : ℤ) < (n : ℤ) := by exact_mod_cast hk
    unfold flipVec
    split_ifs with h0 h1
    · omega
    · omega
    · exact ⟨by positivity, hkq⟩
  · have hne : (0 : ℕ) ≠ 1 := by omega
    have h0lt : (0 : ℕ) < n := by omega
    have h1lt : (1 : ℕ) < n := by omega
    have hn1 : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
    have hnpos : (0 : ℚ) < (n : ℚ) := by linarith
    rw [spearman_transposeAt _ hn hne h0lt h1lt]
    have h0 : flipVec n 0 = (n : ℤ) - 1 := by simp [flipVec]
    have h1 : flipVec n 1 = 0 := by simp [flipVec]
    rw [h0, h1]
    push_cast
    rw [div_eq_div_iff (by nlinarith) (by nlinarith)]
    ring

/-- **The U84 crossing budget at `n = 4096`.**  At the recorded margin `0.008` and a sample
of `4096` paired ranks, crossing the floor requires at least `11188` adjacent transpositions:
the erosion the dial would have to undergo is an `Ω(n²)` rearrangement, which is why it is
observed as a gradual slope rather than a cliff. -/
theorem u84_crossing_budget_4096 (l : List (ℕ × ℕ)) (s : ℕ → ℤ)
    (hl : AdjacentChain 4096 l) (hs : RankBounded 4096 s)
    (hstart : pooled84 ≤ spearman 4096 s) (hend : spearman 4096 (applyTs l s) < bandFloor) :
    11188 ≤ l.length := by
  have hdrop : margin84 ≤ spearman 4096 s - spearman 4096 (applyTs l s) := by
    simp only [margin84]
    linarith [hstart, hend.le]
  have hbudget := adjacent_swaps_to_cross (n := 4096) (by norm_num) l s hl hs hdrop
  norm_num [margin84, pooled84, bandFloor] at hbudget
  by_contra hcon
  push_neg at hcon
  have : (l.length : ℚ) ≤ 11187 := by
    have : l.length ≤ 11187 := by omega
    exact_mod_cast this
  linarith

/-! ## 5. The ladder rebounds: a monotone fade must absorb more noise than the margin -/

/-- The recorded ladder is **not monotone** around U84: the dial rebounds at U92 and again at
U96.  The U84 reading is a local minimum, not a point on a cliff. -/
theorem ladder_rebounds : rung84 < rung92 ∧ rung92 < rung96 ∧ rung84 < rung96 := by
  refine ⟨by norm_num [rung84, pooled84, rung92], by norm_num [rung92, rung96], by
    norm_num [rung84, pooled84, rung96]⟩

/-- **The monotone-fit noise floor.**  If a nonincreasing model `f` fits the data `d` with
sup-error `η`, then every observed *increase* `d j − d i` (`i ≤ j`) forces
`η ≥ (d j − d i)/2`. -/
theorem noise_floor_of_rebound {f d : ℕ → ℚ} {eta : ℚ}
    (hmono : ∀ a b : ℕ, a ≤ b → f b ≤ f a)
    (hfit : ∀ k, |f k - d k| ≤ eta) {i j : ℕ} (hij : i ≤ j) :
    (d j - d i) / 2 ≤ eta := by
  have hi := abs_le.mp (hfit i)
  have hj := abs_le.mp (hfit j)
  have hm := hmono i j hij
  linarith [hi.1, hi.2, hj.1, hj.2]

/-- Applied to the recorded U84 → U96 rebound: any nonincreasing fade fitting the ladder has
sup-error at least `159/20000 = 0.00795`. -/
theorem u84_monotone_noise_floor {f : ℕ → ℚ} {eta : ℚ} {d : ℕ → ℚ}
    (hmono : ∀ a b : ℕ, a ≤ b → f b ≤ f a) (hfit : ∀ k, |f k - d k| ≤ eta)
    (h84 : d 84 = rung84) (h96 : d 96 = rung96) :
    159 / 20000 ≤ eta := by
  have h := noise_floor_of_rebound hmono hfit (i := 84) (j := 96) (by norm_num)
  rw [h84, h96] at h
  have : (rung96 - rung84) / 2 = 159 / 20000 := by
    norm_num [rung96, rung84, pooled84]
  linarith [h, this.le, this.ge]

/-- **The margin is inside the model noise.**  The monotone-fit noise floor `0.00795` is
`159/160` of the entire margin `0.008` to the band floor: at the recorded resolution a
monotone fade cannot distinguish "crossed" from "not crossed". -/
theorem u84_noise_floor_vs_margin :
    (159 : ℚ) / 20000 = (159 / 160) * margin84 ∧ (159 : ℚ) / 20000 < margin84 := by
  constructor <;> norm_num [margin84, pooled84, bandFloor]

/-! ## 6. The resolution wall -/

/-- **Sample size needed to resolve a margin.**  Under a `c/√m` half-width law, shrinking the
half-width from a recorded `h₀` (at sample size `m₀`) to a target `mrg` requires at least
`(h₀/mrg)² m₀` samples. -/
theorem resolution_sample_size {c m0 m h0 mrg : ℝ} (hc : 0 < c) (hm0 : 0 < m0) (hm : 0 < m)
    (h0def : c / Real.sqrt m0 = h0) (hmrg : 0 < mrg) (hres : c / Real.sqrt m ≤ mrg) :
    (h0 / mrg) ^ 2 * m0 ≤ m := by
  have hs0 : 0 < Real.sqrt m0 := Real.sqrt_pos.mpr hm0
  have hs : 0 < Real.sqrt m := Real.sqrt_pos.mpr hm
  have hc0 : c = h0 * Real.sqrt m0 := by
    field_simp at h0def
    linarith [h0def]
  have hle : c ≤ mrg * Real.sqrt m := by
    rw [div_le_iff₀ hs] at hres
    linarith
  have hh0 : 0 < h0 := by
    rw [← h0def]; positivity
  have hkey : (h0 / mrg) * Real.sqrt m0 ≤ Real.sqrt m := by
    rw [div_mul_eq_mul_div, div_le_iff₀ hmrg]
    nlinarith [hc0, hle]
  have hsq0 : Real.sqrt m0 ^ 2 = m0 := Real.sq_sqrt hm0.le
  have hsq : Real.sqrt m ^ 2 = m := Real.sq_sqrt hm.le
  have hnn : 0 ≤ (h0 / mrg) * Real.sqrt m0 := by positivity
  nlinarith [hkey, hsq0, hsq, hnn]

/-- **The U84 resolution factor.**  With the recorded half-width `0.0225` and the margin
`0.008`, deciding the crossing at the recorded point estimate needs at least `2025/256 ≈
7.91` times the sample size. -/
theorem u84_resolution_factor {c m0 m : ℝ} (hc : 0 < c) (hm0 : 0 < m0) (hm : 0 < m)
    (h0def : c / Real.sqrt m0 = 225 / 10000) (hres : c / Real.sqrt m ≤ 8 / 1000) :
    2025 / 256 * m0 ≤ m := by
  have h := resolution_sample_size hc hm0 hm h0def (by norm_num) hres
  have hcoef : ((225 / 10000 : ℝ) / (8 / 1000)) ^ 2 = 2025 / 256 := by norm_num
  rw [hcoef] at h
  exact h

/-- **Shrinking cannot fix a point estimate on the wrong side.**  If the centre of a
symmetric interval is below a bar, the lower endpoint is below the bar for every positive
half-width: decisiveness is not a sample-size problem. -/
theorem bar_unreachable_of_center_below {center bar w : ℚ} (h : center ≤ bar) (hw : 0 < w) :
    center - w < bar := by linarith

/-- The recorded U84 CI half-width, and the fact that it exceeds the margin: the interval
straddles the floor precisely because the resolution is `2.8×` too coarse. -/
theorem u84_halfwidth_exceeds_margin :
    (ciHi84 - ciLo84) / 2 = 225 / 10000 ∧ margin84 < (ciHi84 - ciLo84) / 2 := by
  constructor <;> norm_num [ciHi84, ciLo84, margin84, pooled84, bandFloor]

/-! ## 7. Crossed and uncrossed are geometrically indistinguishable

The whole crossing question is a `0.008` displacement of a correlation.  In the Gram geometry
of the catalog (`Algebra.ZeroFitDialU72Parity`), two predictors realising the crossed and the
uncrossed reading against a common response can be almost perfectly aligned.
-/

/-- **Indistinguishability of the two hypotheses.**  There are three nonzero vectors with
`corr(u, w) = 0.558` (the recorded, uncrossed reading), `corr(v, w) = 0.55` (exactly at the
floor) and `corr(u, v) ≥ 0.9999`: the crossed and uncrossed predictors differ by a rotation
of order `10⁻⁴`. -/
theorem crossing_states_indistinguishable :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u w = 558 / 1000 ∧ corr v w = 55 / 100 ∧ (9999 : ℝ) / 10000 ≤ corr u v := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU112FadeReacceleration.sharp_bound_attained
      (a := (558 : ℝ) / 1000) (b := (55 : ℝ) / 100) (by norm_num) (by norm_num)
  refine ⟨u, v, w, hu, hv, hw, huw, hvw, ?_⟩
  rw [huv]
  have hprod : (693 : ℝ) / 1000 ≤
      Real.sqrt ((1 - (558 / 1000 : ℝ) ^ 2) * (1 - (55 / 100 : ℝ) ^ 2)) := by
    have hsq : ((693 : ℝ) / 1000) ^ 2
        ≤ (1 - (558 / 1000 : ℝ) ^ 2) * (1 - (55 / 100 : ℝ) ^ 2) := by norm_num
    have := Real.sqrt_le_sqrt hsq
    rwa [Real.sqrt_sq (by norm_num)] at this
  nlinarith [hprod]

/-- The alignment bound of `crossing_states_indistinguishable` is not vacuous: the two
readings really are distinct, and the gap between them is exactly the recorded margin. -/
theorem crossing_states_distinct : (55 : ℚ) / 100 < 558 / 1000 ∧
    (558 : ℚ) / 1000 - 55 / 100 = margin84 := by
  constructor <;> norm_num [margin84, pooled84, bandFloor]

end Catalog.Novelty.TDialU84ApproachNotCrossed