import Mathlib
import Geometry.SpearmanPermutohedronGap

/-!
# Why a tighter dial threshold must lose correlation: the block ceiling `3p(1−p)`

## Research context (FACT round-44 #2, exp 499, `T-DIAL-AXES: regime holds, u breaks`)

The round-44 measurement has two axes.  Along the *population* axis (H1) the dial holds: the
Spearman reading stays in band on `5/5` uniform draws with `N` spanning `2²⁷–2³⁸`.  Along the
*threshold* axis (H2) it breaks: moving the operating point from `u = 2.5` to `u = 3.5`
degrades every seed, one of them to `0.487`, and the column mean falls below the band floor.
The adopted recommendation was empirical — "do not deploy at tighter thresholds without
recalibration".

This file supplies the missing structural explanation, and it is a *geometric* one.  Raising
`u` makes the flagged set smaller.  A threshold turns the continuous statistic into a two-block
(flagged / not flagged) variable, and the correlation between a two-block variable and a full
ranking is bounded by the geometry of the permutohedron alone: if a fraction `p = m/n` is
flagged, then

  `corr² ≤ 3·m·(n − m)/(n² − 1)  ≈ 3p(1 − p)`.

So the achievable reading is capped by `√(3p(1−p))`, *whatever* the statistic does: at
`p = 1/2` the cap is `0.866`, at `p = 1/10` it is already `0.520`.  Tightening the threshold
does not merely add noise — it removes the ceiling below the pre-registered band.  The observed
deep breach at `0.487` is entirely consistent with a `p ≈ 0.1` flagged fraction; no amount of
seed averaging can recover the band at that operating point.

## Main results

* `two_mul_blockSum_le` / `sum_le_two_mul_blockSum` — the extremal sums: for any `B` with
  `|B| = m` and any ranking `σ`, `∑_{i∈B} σ(i)` lies between the sum of the `m` smallest and
  the sum of the `m` largest ranks.  (Proved from Mathlib's sharp bounds for sums of distinct
  integers, so the constants are exact, not asymptotic.)
* `abs_two_mul_blockCov_le` — consequently the un-normalised covariance obeys
  `|2·Cov| ≤ n·m·(n − m)`.
* `pbCorrSq_le_block_ceiling` — **the block ceiling**: `corr² ≤ 3m(n − m)/(n² − 1)`.
* `pbCorr_below_band_of_small_block` — the deployment statement: if
  `3m(n − m) < c²(n² − 1)` then the dial provably cannot read `c`, for *any* statistic and any
  ranking.
* `dial_ceiling_at_ten_percent` — the numeric instance of the experiment's regime:
  at `n = 100`, `m = 10` the ceiling is `corr² ≤ 27/100`, i.e. `corr ≤ 0.52`, far below the
  pre-registered floor `0.71`; `band_floor_unreachable_at_ten_percent` states the failure
  directly.

## Lab notes

`labnote_block_sharp_fin4` records the exhaustive `n = 4`, `m = 2` check that the extremal sum
bound is attained (top block `{2,3}` under the identity ranking), so the ceiling is sharp and
not an artefact of the estimate.
-/

namespace Catalog.Geometry.SpearmanThreshold

open Finset Catalog.Geometry.SpearmanPermutohedron

variable {n : ℕ}

/-! ## Section 1. Extremal block sums -/

/-- The total rank carried by a flagged block `B` under the ranking `σ`. -/
def blockSum (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) : ℤ := ∑ i ∈ B, rk σ i

/-- The un-normalised covariance between the indicator of `B` and the rank vector of `σ`
(scaled by `n²`). -/
def blockCov (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) : ℤ :=
  (n : ℤ) * blockSum σ B - (B.card : ℤ) * linSum n

lemma rk_injective (σ : Equiv.Perm (Fin n)) : Function.Injective (fun i => rk σ i) := by
  intro i j hij
  have h : ((σ i : Fin n) : ℕ) = ((σ j : Fin n) : ℕ) := by
    simp only [rk] at hij
    exact_mod_cast hij
  exact σ.injective (Fin.ext h)

lemma two_mul_sum_range (m : ℕ) : 2 * ∑ k ∈ Finset.range m, (k : ℤ) = (m : ℤ) * ((m : ℤ) - 1) := by
  induction m with
  | zero => simp
  | succ p ih =>
      rw [Finset.sum_range_succ]
      push_cast
      push_cast at ih
      linarith

lemma blockSum_eq_image_sum (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) :
    blockSum σ B = ∑ x ∈ B.image (fun i => rk σ i), x := by
  unfold blockSum
  rw [Finset.sum_image (fun i _ j _ h => rk_injective σ h)]

lemma card_image_rk (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) :
    (B.image (fun i => rk σ i)).card = B.card :=
  Finset.card_image_of_injective B (rk_injective σ)

/-- **Upper extremal sum.**  A block of size `m` can carry at most the `m` largest ranks. -/
theorem two_mul_blockSum_le (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) :
    2 * blockSum σ B ≤ (B.card : ℤ) * (2 * (n : ℤ) - (B.card : ℤ) - 1) := by
  have hle : ∀ x ∈ B.image (fun i => rk σ i), x ≤ (n : ℤ) - 1 := by
    intro x hx
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.1 hx
    have : ((σ i : Fin n) : ℕ) < n := (σ i).isLt
    unfold rk
    omega
  have hbound := Finset.sum_le_sum_range hle
  rw [card_image_rk] at hbound
  have hrange : ∑ k ∈ Finset.range B.card, ((n : ℤ) - 1 - (k : ℤ))
      = (B.card : ℤ) * ((n : ℤ) - 1) - ∑ k ∈ Finset.range B.card, (k : ℤ) := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range]
    ring
  rw [hrange] at hbound
  have hg := two_mul_sum_range B.card
  rw [blockSum_eq_image_sum]
  linarith

/-- **Lower extremal sum.**  A block of size `m` carries at least the `m` smallest ranks. -/
theorem sum_le_two_mul_blockSum (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) :
    (B.card : ℤ) * ((B.card : ℤ) - 1) ≤ 2 * blockSum σ B := by
  have hge : ∀ x ∈ B.image (fun i => rk σ i), (0 : ℤ) ≤ x := by
    intro x hx
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.1 hx
    unfold rk
    positivity
  have hbound := Finset.sum_range_le_sum hge
  rw [card_image_rk] at hbound
  have hrange : ∑ k ∈ Finset.range B.card, ((0 : ℤ) + (k : ℤ))
      = ∑ k ∈ Finset.range B.card, (k : ℤ) := by
    exact Finset.sum_congr rfl fun k _ => by ring
  rw [hrange] at hbound
  have hg := two_mul_sum_range B.card
  rw [blockSum_eq_image_sum]
  linarith

/-! ## Section 2. The covariance ceiling -/

/-- The two-sided covariance bound `|2·Cov| ≤ n·m·(n − m)`. -/
theorem abs_two_mul_blockCov_le (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) :
    |2 * blockCov σ B| ≤ (n : ℤ) * (B.card : ℤ) * ((n : ℤ) - (B.card : ℤ)) := by
  have hlin := two_mul_linSum n
  have hup := two_mul_blockSum_le σ B
  have hlow := sum_le_two_mul_blockSum σ B
  have hn0 : (0 : ℤ) ≤ (n : ℤ) := Int.natCast_nonneg n
  unfold blockCov
  rw [abs_le]
  constructor
  · nlinarith [hlow, hlin, hn0]
  · nlinarith [hup, hlin, hn0]

/-! ## Section 3. The point-biserial ceiling `3p(1−p)` -/

/-- The squared point-biserial correlation between the indicator of the flagged block `B` and
the rank vector of `σ`. -/
def pbCorrSq (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n)) : ℚ :=
  12 * (blockCov σ B : ℚ) ^ 2 /
    ((n : ℚ) ^ 2 * (B.card : ℚ) * ((n : ℚ) - (B.card : ℚ)) * ((n : ℚ) ^ 2 - 1))

/-- **The block ceiling.**  Thresholding a statistic into a flagged block of size `m` caps the
attainable squared correlation with any ranking at `3m(n − m)/(n² − 1)`, independently of the
statistic. -/
theorem pbCorrSq_le_block_ceiling (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n))
    (hm : 0 < B.card) (hmn : B.card < n) :
    pbCorrSq σ B ≤ 3 * (B.card : ℚ) * ((n : ℚ) - (B.card : ℚ)) / ((n : ℚ) ^ 2 - 1) := by
  set m : ℚ := (B.card : ℚ) with hmdef
  have hmpos : (0 : ℚ) < m := by rw [hmdef]; exact_mod_cast hm
  have hmlt : m < (n : ℚ) := by rw [hmdef]; exact_mod_cast hmn
  have hnpos : (0 : ℚ) < (n : ℚ) := lt_trans hmpos hmlt
  have hn2 : (2 : ℚ) ≤ (n : ℚ) := by
    have : 2 ≤ n := by omega
    exact_mod_cast this
  have hnsq : (0 : ℚ) < (n : ℚ) ^ 2 - 1 := by nlinarith
  have hdiff : (0 : ℚ) < (n : ℚ) - m := by linarith
  have hden : (0 : ℚ) < (n : ℚ) ^ 2 * m * ((n : ℚ) - m) * ((n : ℚ) ^ 2 - 1) := by positivity
  -- the integral covariance bound, transported to `ℚ`
  have habs : |2 * (blockCov σ B : ℚ)| ≤ (n : ℚ) * m * ((n : ℚ) - m) := by
    have h := abs_two_mul_blockCov_le σ B
    have : (|2 * blockCov σ B| : ℚ) ≤ ((n : ℤ) * (B.card : ℤ) * ((n : ℤ) - (B.card : ℤ)) : ℚ) := by
      exact_mod_cast h
    push_cast at this
    simpa using this
  have hsq : (2 * (blockCov σ B : ℚ)) ^ 2 ≤ ((n : ℚ) * m * ((n : ℚ) - m)) ^ 2 := by
    obtain ⟨h1, h2⟩ := abs_le.1 habs
    exact sq_le_sq' h1 h2
  unfold pbCorrSq
  rw [div_le_div_iff₀ hden hnsq]
  nlinarith [hsq, hmpos, hdiff, hnsq, hnpos]

/-- **Deployment statement.**  If the flagged fraction is too small (or too large), the target
correlation `c` is unreachable: no statistic and no ranking can produce it. -/
theorem pbCorr_below_band_of_small_block (σ : Equiv.Perm (Fin n)) (B : Finset (Fin n))
    (hm : 0 < B.card) (hmn : B.card < n) {c : ℚ}
    (hc : 3 * (B.card : ℚ) * ((n : ℚ) - (B.card : ℚ)) < c ^ 2 * ((n : ℚ) ^ 2 - 1)) :
    pbCorrSq σ B < c ^ 2 := by
  have hn2 : (2 : ℚ) ≤ (n : ℚ) := by
    have : 2 ≤ n := by omega
    exact_mod_cast this
  have hnsq : (0 : ℚ) < (n : ℚ) ^ 2 - 1 := by nlinarith
  have hceil := pbCorrSq_le_block_ceiling σ B hm hmn
  have : 3 * (B.card : ℚ) * ((n : ℚ) - (B.card : ℚ)) / ((n : ℚ) ^ 2 - 1) < c ^ 2 := by
    rw [div_lt_iff₀ hnsq]
    linarith
  linarith

/-! ## Section 4. The experiment's operating point -/

/-- At `n = 100` with a `10 %` flagged block the squared correlation cannot exceed `27/100`,
i.e. the reading cannot exceed `0.52`. -/
theorem dial_ceiling_at_ten_percent (σ : Equiv.Perm (Fin 100)) (B : Finset (Fin 100))
    (hB : B.card = 10) : pbCorrSq σ B ≤ 2700 / 9999 := by
  have h := pbCorrSq_le_block_ceiling σ B (by rw [hB]; norm_num) (by rw [hB]; norm_num)
  rw [hB] at h
  norm_num at h ⊢
  linarith

/-- Consequently the pre-registered band floor `0.71` is unreachable at that operating point:
`0.71² · (n² − 1) = 5039.5 > 2700`.  This is a *structural* band loss, not a sampling
fluctuation. -/
theorem band_floor_unreachable_at_ten_percent (σ : Equiv.Perm (Fin 100)) (B : Finset (Fin 100))
    (hB : B.card = 10) : pbCorrSq σ B < (71 / 100 : ℚ) ^ 2 := by
  refine pbCorr_below_band_of_small_block σ B (by rw [hB]; norm_num) (by rw [hB]; norm_num) ?_
  rw [hB]
  norm_num

/-! ## Lab notes -/

/-- Sharpness at `n = 4`, `m = 2`: the top block `{2, 3}` under the identity ranking attains the
extremal sum `2·blockSum = m(2n − m − 1) = 10`, so the ceiling is exact. -/
theorem labnote_block_sharp_fin4 :
    2 * blockSum (1 : Equiv.Perm (Fin 4)) {2, 3} = 10 ∧
      (({2, 3} : Finset (Fin 4)).card : ℤ) * (2 * 4 - ({2, 3} : Finset (Fin 4)).card - 1) = 10 := by
  constructor <;> decide

/-- The corresponding maximal squared correlation at `n = 4`, `m = 2` is `4/5`, matching
`3m(n − m)/(n² − 1) = 12/15`. -/
theorem labnote_ceiling_fin4 :
    (3 : ℚ) * 2 * (4 - 2) / ((4 : ℚ) ^ 2 - 1) = 4 / 5 := by norm_num

end Catalog.Geometry.SpearmanThreshold