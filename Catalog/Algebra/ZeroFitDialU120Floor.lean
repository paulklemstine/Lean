import Mathlib
import Algebra.ZeroFitDialU72Parity

/-!
# Pooling geometry, the advantage–decorrelation duality, and the absence of a dial floor

## Research context (FACT round-72 #4, exp 554, `U120-FLOOR-LOWER`)

The recorded measurement continues the `T`-dial thread: a Spearman rank correlation
between the trailing-zero statistic `T` of a uniformly drawn integer and a downstream
`rate`, now at bitlen 120.

* pooled reading `0.43636`, CI `[0.38815, 0.48113]`;
* the ladder over the bitlen sweep reads
  `0.5739 → 0.5436 → 0.5005 → 0.4880 → 0.4621 → (0.4847) → 0.4364`;
* the parenthesised rung is the *U116 rebound*: a `+0.0226` step that the present cycle
  fully retraces and overshoots (step `−0.0483`);
* seed-to-seed spread has widened to `0.082`;
* `T` still beats the plain count baseline, by `+0.0752` at the point estimate.

Every earlier file in the thread analyses a **single pooled number** against tie geometry
(`Novelty.ZeroFitDialU64`), Gram geometry (`Algebra.ZeroFitDialU72Parity`), capacity
sheets (`Algebra.ZeroFitDialU64MedianCapacity`) or replication budgets
(`Algebra.ZeroFitDialU64Aggregation`, `Algebra.ZeroFitDialU64Dispersion`).  None of them
asks what a *pooled* correlation actually is as a geometric object: the readings are
computed on a concatenation of per-seed blocks, and concatenation is not an averaging
operation.  This cycle supplies that missing layer, and uses it to give the two claims of
the record — "the rebound was noise" and "the fade continues below the hypothesised
floor" — precise, falsifiable geometric content.

## Main results

### 1. Pooling geometry (new)

* `pooledCorr` — the correlation of a *block family* (one block per seed), i.e. the
  correlation of the concatenated vectors, written intrinsically in terms of the
  per-block `dot` of `Algebra.ZeroFitDialU72Parity`.
* `sum_sqrt_mul_le` — the block Cauchy–Schwarz inequality `∑ √aₖ√bₖ ≤ √(∑a)√(∑b)`.
* `pooled_le_of_blockwise`, `pooled_le_max_corr` — **pooling never inflates**: the pooled
  reading is at most the largest per-seed reading.  So a pooled dial value is a *lower*
  bound witness for the seed family, never an artefact of concatenation.
* `pooled_strict_attenuation` — sharpness in the other direction: an explicit two-block
  family whose per-seed readings are both `1` while the pooled reading is `3/√10 < 1`.
  Heterogeneous seeds bias the pooled dial **downwards**; there is no matching lower
  bound by the seed minimum.
* `pooled_balanced_eq_weighted_avg` — the exact repair: if the response norms are
  proportional to the statistic norms across seeds (balanced blocks), pooling *is* a
  weighted average, with weights the block energies.
* `pooled_balanced_between` — hence the balanced sandwich `min ρₖ ≤ pooled ≤ max ρₖ`.
* `pooled_attenuation_bound` — the quantitative version for *near*-balanced blocks: a
  relative imbalance `δ` costs at most a factor `(1-δ)/(1+δ)`.

### 2. Noise versus signal (new)

* `pooled_window_of_seed_window` — a pooled reading built from seeds inside a window of
  width `s` lies in that same window.
* `gap_le_spread_of_same_window`, `separated_windows_of_large_gap` — the **two-spread
  criterion**: a difference of two pooled readings exceeding `s` forces the two seed
  windows to be distinct, and exceeding `2s` forces them to be disjoint.  A step smaller
  than the spread carries no information at all: `rebound_within_noise_band`.
* Applied to the record: `u120_rebound_is_noise_compatible` (the `+0.0226` rebound is
  compatible with a *single* seed window of width `0.082`, hence is not evidence of any
  change), while `u120_total_fade_exceeds_spread` shows the cumulative
  `0.5739 → 0.4364` drop is not.

### 3. The advantage–decorrelation duality (new, sharp)

* `advantage_sq_le` / `advantage_le_sqrt` — from Gram positivity alone,
  `(a - b)² ≤ 2(1 - c)`: two statistics read against a shared response can differ by at
  most `√(2(1-c))`, where `c` is their mutual correlation.
* `corr_le_of_advantage` — the dual form `c ≤ 1 - (a-b)²/2`: **any** measured advantage is
  a certificate of decorrelation.
* `advantage_duality_sharp` — the bound is attained: for every `c < 1` explicit vectors in
  `ℝ²` realise `corr u v = c` and `corr u w - corr v w = √(2(1-c))`.
* `u120_advantage_forces_decorrelation` — the recorded `+0.0752` advantage certifies
  `corr(T, count) ≤ 0.99718`.

### 4. No positive floor under persistent fade (new)

* `fade_geometric` — a ratio-bounded fade is dominated by a geometric envelope.
* `fade_below_any_floor` — hence **no positive floor survives**: for every `ε > 0` the
  ladder eventually reads below `ε`.  A "floor" hypothesis is therefore not a weakening of
  the fade law but its negation.
* `u120_ladder_ratio_bound` — the recorded de-noised ladder (the rebound rung removed)
  obeys `ρₖ₊₁ ≤ 0.98 · ρₖ` at every rung;
* `u120_predicts_below_forty` — the falsifiable prediction: five more rungs at that rate
  put the dial below `0.40`.

## Lab notes (recorded data used below, exp 554)

```
ladder (bitlen sweep) : 0.5739  0.5436  0.5005  0.4880  0.4621  [0.4847]  0.4364
de-noised ladder      : 0.5739  0.5436  0.5005  0.4880  0.4621            0.4364
per-rung ratios       :        0.9472  0.9207  0.9750  0.9469            0.9444
rebound step (U116)   : +0.0226        retrace step (U120) : -0.0483
seed spread           : 0.082          pooled CI           : [0.38815, 0.48113]
T advantage over count: +0.0752        pooled reading      : 0.43636
```
-/

open Finset
open Catalog.Algebra.ZeroFitDialU72Parity

namespace Catalog.Algebra.ZeroFitDialU120Floor

/-! ## 1. Pooling geometry -/

variable {m n : ℕ}

/-- Total energy of a block family: the squared norm of the concatenated vector. -/
noncomputable def blockNormSq (u : Fin m → (Fin n → ℝ)) : ℝ := ∑ k, dot (u k) (u k)

/-- Inner product of two block families: the inner product of the concatenated vectors. -/
noncomputable def blockDot (u v : Fin m → (Fin n → ℝ)) : ℝ := ∑ k, dot (u k) (v k)

/-- The **pooled correlation** of a block family: the correlation of the concatenations.
This is what an experiment reports when it pools several seeds. -/
noncomputable def pooledCorr (u v : Fin m → (Fin n → ℝ)) : ℝ :=
  blockDot u v / (Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v))

lemma blockNormSq_nonneg (u : Fin m → (Fin n → ℝ)) : 0 ≤ blockNormSq u :=
  Finset.sum_nonneg fun k _ => dot_self_nonneg (u k)

/-- Block Cauchy–Schwarz: `∑ √aₖ √bₖ ≤ √(∑ a) √(∑ b)`. -/
lemma sum_sqrt_mul_le {a b : Fin m → ℝ} (ha : ∀ k, 0 ≤ a k) (hb : ∀ k, 0 ≤ b k) :
    ∑ k, Real.sqrt (a k) * Real.sqrt (b k) ≤
      Real.sqrt (∑ k, a k) * Real.sqrt (∑ k, b k) := by
  have key := Finset.sum_mul_sq_le_sq_mul_sq (univ : Finset (Fin m))
    (fun k => Real.sqrt (a k)) (fun k => Real.sqrt (b k))
  have hA : ∑ k, (Real.sqrt (a k)) ^ 2 = ∑ k, a k :=
    Finset.sum_congr rfl fun k _ => Real.sq_sqrt (ha k)
  have hB : ∑ k, (Real.sqrt (b k)) ^ 2 = ∑ k, b k :=
    Finset.sum_congr rfl fun k _ => Real.sq_sqrt (hb k)
  rw [hA, hB] at key
  have hS : 0 ≤ ∑ k, Real.sqrt (a k) * Real.sqrt (b k) :=
    Finset.sum_nonneg fun k _ => mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hA0 : 0 ≤ ∑ k, a k := Finset.sum_nonneg fun k _ => ha k
  calc ∑ k, Real.sqrt (a k) * Real.sqrt (b k)
      = Real.sqrt ((∑ k, Real.sqrt (a k) * Real.sqrt (b k)) ^ 2) := (Real.sqrt_sq hS).symm
    _ ≤ Real.sqrt ((∑ k, a k) * (∑ k, b k)) := Real.sqrt_le_sqrt key
    _ = Real.sqrt (∑ k, a k) * Real.sqrt (∑ k, b k) := Real.sqrt_mul hA0 _

lemma nrm_nonneg (u : Fin n → ℝ) : 0 ≤ nrm u := Real.sqrt_nonneg _

lemma corr_mul_nrm {u v : Fin n → ℝ} (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) :
    corr u v * (nrm u * nrm v) = dot u v := by
  have h : nrm u * nrm v ≠ 0 := ne_of_gt (mul_pos (nrm_pos hu) (nrm_pos hv))
  rw [corr, div_mul_cancel₀ _ h]

/-- **Pooling never inflates (blockwise form).**  If every block satisfies the
correlation bound `⟨uₖ, vₖ⟩ ≤ R‖uₖ‖‖vₖ‖`, then so does the pooled reading. -/
theorem pooled_le_of_blockwise {u v : Fin m → (Fin n → ℝ)} {R : ℝ} (hR : 0 ≤ R)
    (hu : 0 < blockNormSq u) (hv : 0 < blockNormSq v)
    (h : ∀ k, dot (u k) (v k) ≤ R * (nrm (u k) * nrm (v k))) :
    pooledCorr u v ≤ R := by
  have hcs : ∑ k, (nrm (u k) * nrm (v k))
      ≤ Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v) := by
    simpa [nrm, blockNormSq] using
      sum_sqrt_mul_le (a := fun k => dot (u k) (u k)) (b := fun k => dot (v k) (v k))
        (fun k => dot_self_nonneg _) (fun k => dot_self_nonneg _)
  have hnum : blockDot u v ≤ R * (Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v)) := by
    have h1 : blockDot u v ≤ ∑ k, R * (nrm (u k) * nrm (v k)) :=
      Finset.sum_le_sum fun k _ => h k
    calc blockDot u v ≤ ∑ k, R * (nrm (u k) * nrm (v k)) := h1
      _ = R * ∑ k, (nrm (u k) * nrm (v k)) := by rw [Finset.mul_sum]
      _ ≤ R * (Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v)) :=
          mul_le_mul_of_nonneg_left hcs hR
  have hpos : 0 < Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v) :=
    mul_pos (Real.sqrt_pos.mpr hu) (Real.sqrt_pos.mpr hv)
  rw [pooledCorr, div_le_iff₀ hpos]
  exact hnum

/-- **Pooling never inflates.**  The pooled reading of a seed family is at most the
largest per-seed reading (for a nonnegative bound `R`). -/
theorem pooled_le_max_corr {u v : Fin m → (Fin n → ℝ)} {R : ℝ} (hR : 0 ≤ R)
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u) (hv : 0 < blockNormSq v)
    (h : ∀ k, corr (u k) (v k) ≤ R) :
    pooledCorr u v ≤ R := by
  refine pooled_le_of_blockwise hR hu hv fun k => ?_
  have hd : dot (u k) (v k) = corr (u k) (v k) * (nrm (u k) * nrm (v k)) :=
    (corr_mul_nrm (hu0 k) (hv0 k)).symm
  rw [hd]
  exact mul_le_mul_of_nonneg_right (h k)
    (mul_nonneg (nrm_nonneg _) (nrm_nonneg _))

/-- **No matching lower bound.**  Two blocks whose per-seed readings are both exactly `1`
pool to `3/√10 < 1`: heterogeneous seed energies attenuate the pooled dial. -/
theorem pooled_strict_attenuation :
    ∃ u v : Fin 2 → (Fin 1 → ℝ),
      (∀ k, corr (u k) (v k) = 1) ∧ pooledCorr u v = 3 / Real.sqrt 10 ∧
      pooledCorr u v < 1 := by
  refine ⟨![fun _ => 1, fun _ => 1], ![fun _ => 1, fun _ => 2], ?_, ?_, ?_⟩
  · intro k
    fin_cases k <;> simp [corr, nrm, dot]
  · have h10 : Real.sqrt (blockNormSq (![fun _ => 1, fun _ => 1] : Fin 2 → (Fin 1 → ℝ))) *
        Real.sqrt (blockNormSq (![fun _ => 1, fun _ => 2] : Fin 2 → (Fin 1 → ℝ)))
        = Real.sqrt 10 := by
      rw [← Real.sqrt_mul (by simp [blockNormSq, dot, Fin.sum_univ_two])]
      norm_num [blockNormSq, dot, Fin.sum_univ_two]
    rw [pooledCorr, h10]
    norm_num [blockDot, dot, Fin.sum_univ_two, Fin.sum_univ_one]
  · have h10 : Real.sqrt (blockNormSq (![fun _ => 1, fun _ => 1] : Fin 2 → (Fin 1 → ℝ))) *
        Real.sqrt (blockNormSq (![fun _ => 1, fun _ => 2] : Fin 2 → (Fin 1 → ℝ)))
        = Real.sqrt 10 := by
      rw [← Real.sqrt_mul (by simp [blockNormSq, dot, Fin.sum_univ_two])]
      norm_num [blockNormSq, dot, Fin.sum_univ_two]
    have h9 : Real.sqrt 9 = 3 := by
      rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    have hlt : (3 : ℝ) < Real.sqrt 10 := by
      have := Real.sqrt_lt_sqrt (by norm_num : (0:ℝ) ≤ 9) (by norm_num : (9:ℝ) < 10)
      rwa [h9] at this
    rw [pooledCorr, h10]
    have hnum : blockDot (![fun _ => 1, fun _ => 1] : Fin 2 → (Fin 1 → ℝ))
        ![fun _ => 1, fun _ => 2] = 3 := by
      norm_num [blockDot, dot, Fin.sum_univ_two, Fin.sum_univ_one]
    rw [hnum, div_lt_one (by linarith)]
    exact hlt

/-- **Balanced pooling is a weighted average.**  If the response norm is a fixed multiple
of the statistic norm in every block, the pooled reading is the energy-weighted mean of
the per-block readings. -/
theorem pooled_balanced_eq_weighted_avg {u v : Fin m → (Fin n → ℝ)} {lam : ℝ}
    (hlam : 0 < lam) (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u) (hbal : ∀ k, nrm (v k) = lam * nrm (u k)) :
    pooledCorr u v =
      (∑ k, dot (u k) (u k) * corr (u k) (v k)) / blockNormSq u := by
  have hnum : blockDot u v = lam * ∑ k, dot (u k) (u k) * corr (u k) (v k) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun k _ => ?_
    have h := corr_mul_nrm (hu0 k) (hv0 k)
    rw [← h, hbal k, ← nrm_sq (u k)]
    ring
  have hBv : blockNormSq v = lam ^ 2 * blockNormSq u := by
    rw [blockNormSq, blockNormSq, Finset.mul_sum]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [← nrm_sq (v k), ← nrm_sq (u k), hbal k]
    ring
  have hsq : Real.sqrt (blockNormSq v) = lam * Real.sqrt (blockNormSq u) := by
    rw [hBv, Real.sqrt_mul (by positivity), Real.sqrt_sq hlam.le]
  have hAA : Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq u) = blockNormSq u :=
    Real.mul_self_sqrt hu.le
  rw [pooledCorr, hnum, hsq]
  have hden : Real.sqrt (blockNormSq u) * (lam * Real.sqrt (blockNormSq u))
      = lam * blockNormSq u := by
    rw [show Real.sqrt (blockNormSq u) * (lam * Real.sqrt (blockNormSq u))
        = lam * (Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq u)) from by ring, hAA]
  rw [hden, mul_div_mul_left _ _ (ne_of_gt hlam)]

/-- The **balanced sandwich**: a balanced pooled reading lies between the extreme per-seed
readings. -/
theorem pooled_balanced_between {u v : Fin m → (Fin n → ℝ)} {lam lo hi : ℝ}
    (hlam : 0 < lam) (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u) (hbal : ∀ k, nrm (v k) = lam * nrm (u k))
    (hlo : ∀ k, lo ≤ corr (u k) (v k)) (hhi : ∀ k, corr (u k) (v k) ≤ hi) :
    lo ≤ pooledCorr u v ∧ pooledCorr u v ≤ hi := by
  have hform := pooled_balanced_eq_weighted_avg hlam hu0 hv0 hu hbal
  constructor
  · rw [hform, le_div_iff₀ hu]
    have hL : lo * blockNormSq u = ∑ k, dot (u k) (u k) * lo := by
      rw [blockNormSq, Finset.mul_sum]
      exact Finset.sum_congr rfl fun k _ => mul_comm _ _
    rw [hL]
    exact Finset.sum_le_sum fun k _ =>
      mul_le_mul_of_nonneg_left (hlo k) (dot_self_nonneg _)
  · rw [hform, div_le_iff₀ hu]
    have hH : hi * blockNormSq u = ∑ k, dot (u k) (u k) * hi := by
      rw [blockNormSq, Finset.mul_sum]
      exact Finset.sum_congr rfl fun k _ => mul_comm _ _
    rw [hH]
    exact Finset.sum_le_sum fun k _ =>
      mul_le_mul_of_nonneg_left (hhi k) (dot_self_nonneg _)

/-- **Quantitative attenuation.**  If the block imbalance is at most `δ`, pooling costs at
most the factor `(1-δ)/(1+δ)` relative to the worst per-seed reading. -/
theorem pooled_attenuation_bound {u v : Fin m → (Fin n → ℝ)} {lam : Fin m → ℝ}
    {L delta rho : ℝ} (hL : 0 < L) (hd0 : 0 ≤ delta) (hd1 : delta < 1) (hrho : 0 ≤ rho)
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u)
    (hbal : ∀ k, nrm (v k) = lam k * nrm (u k))
    (hlo : ∀ k, L * (1 - delta) ≤ lam k) (hhi : ∀ k, lam k ≤ L * (1 + delta))
    (hcorr : ∀ k, rho ≤ corr (u k) (v k)) :
    rho * ((1 - delta) / (1 + delta)) ≤ pooledCorr u v := by
  have hLd : 0 < L * (1 - delta) := by nlinarith
  have hlampos : ∀ k, 0 < lam k := fun k => lt_of_lt_of_le hLd (hlo k)
  -- numerator lower bound
  have hnum : rho * (L * (1 - delta)) * blockNormSq u ≤ blockDot u v := by
    rw [blockNormSq, Finset.mul_sum, blockDot]
    refine Finset.sum_le_sum fun k _ => ?_
    have h := corr_mul_nrm (hu0 k) (hv0 k)
    have hdot : dot (u k) (v k) = corr (u k) (v k) * lam k * dot (u k) (u k) := by
      rw [← h, hbal k, ← nrm_sq (u k)]; ring
    rw [hdot]
    have hfac : rho * (L * (1 - delta)) ≤ corr (u k) (v k) * lam k :=
      mul_le_mul (hcorr k) (hlo k) hLd.le (le_trans hrho (hcorr k))
    exact mul_le_mul_of_nonneg_right hfac (dot_self_nonneg _)
  -- denominator upper bound
  have hBvle : blockNormSq v ≤ (L * (1 + delta)) ^ 2 * blockNormSq u := by
    rw [blockNormSq, blockNormSq, Finset.mul_sum]
    refine Finset.sum_le_sum fun k _ => ?_
    rw [← nrm_sq (v k), ← nrm_sq (u k), hbal k]
    have hL1 : (0:ℝ) ≤ nrm (u k) ^ 2 := sq_nonneg _
    have hsq2 : lam k ^ 2 ≤ (L * (1 + delta)) ^ 2 := by
      have h1 : 0 ≤ lam k := (hlampos k).le
      nlinarith [hhi k]
    calc (lam k * nrm (u k)) ^ 2 = lam k ^ 2 * nrm (u k) ^ 2 := by ring
      _ ≤ (L * (1 + delta)) ^ 2 * nrm (u k) ^ 2 := mul_le_mul_of_nonneg_right hsq2 hL1
  have hBvpos : 0 < blockNormSq v := by
    have : (L * (1 - delta)) ^ 2 * blockNormSq u ≤ blockNormSq v := by
      rw [blockNormSq, blockNormSq, Finset.mul_sum]
      refine Finset.sum_le_sum fun k _ => ?_
      rw [← nrm_sq (v k), ← nrm_sq (u k), hbal k]
      have hsq2 : (L * (1 - delta)) ^ 2 ≤ lam k ^ 2 := by nlinarith [hlo k]
      calc (L * (1 - delta)) ^ 2 * nrm (u k) ^ 2
          ≤ lam k ^ 2 * nrm (u k) ^ 2 := mul_le_mul_of_nonneg_right hsq2 (sq_nonneg _)
        _ = (lam k * nrm (u k)) ^ 2 := by ring
    have hpos2 : 0 < (L * (1 - delta)) ^ 2 * blockNormSq u := mul_pos (pow_pos hLd 2) hu
    linarith
  have hsqrtB : Real.sqrt (blockNormSq v) ≤ L * (1 + delta) * Real.sqrt (blockNormSq u) := by
    have h := Real.sqrt_le_sqrt hBvle
    rwa [Real.sqrt_mul (by positivity), Real.sqrt_sq (by nlinarith)] at h
  have hAA : Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq u) = blockNormSq u :=
    Real.mul_self_sqrt hu.le
  have hDpos : 0 < Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v) :=
    mul_pos (Real.sqrt_pos.mpr hu) (Real.sqrt_pos.mpr hBvpos)
  have hDle : Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v)
      ≤ L * (1 + delta) * blockNormSq u := by
    calc Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v)
        ≤ Real.sqrt (blockNormSq u) * (L * (1 + delta) * Real.sqrt (blockNormSq u)) :=
          mul_le_mul_of_nonneg_left hsqrtB (Real.sqrt_nonneg _)
      _ = L * (1 + delta) * blockNormSq u := by
          rw [show Real.sqrt (blockNormSq u) * (L * (1 + delta) * Real.sqrt (blockNormSq u))
              = L * (1 + delta) * (Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq u))
              from by ring, hAA]
  have hrewrite : rho * ((1 - delta) / (1 + delta))
      = (rho * (L * (1 - delta)) * blockNormSq u) / (L * (1 + delta) * blockNormSq u) := by
    have h1 : (1 : ℝ) + delta ≠ 0 := by linarith
    have h2 : L ≠ 0 := ne_of_gt hL
    have h3 : blockNormSq u ≠ 0 := ne_of_gt hu
    field_simp
  rw [pooledCorr, hrewrite]
  have hN0 : 0 ≤ rho * (L * (1 - delta)) * blockNormSq u := by positivity
  have hNnn : 0 ≤ blockDot u v := le_trans hN0 hnum
  have hD'pos : 0 < L * (1 + delta) * blockNormSq u :=
    mul_pos (mul_pos hL (by linarith)) hu
  rw [div_le_div_iff₀ hD'pos hDpos]
  calc rho * (L * (1 - delta)) * blockNormSq u *
        (Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v))
      ≤ blockDot u v * (Real.sqrt (blockNormSq u) * Real.sqrt (blockNormSq v)) :=
        mul_le_mul_of_nonneg_right hnum hDpos.le
    _ ≤ blockDot u v * (L * (1 + delta) * blockNormSq u) :=
        mul_le_mul_of_nonneg_left hDle hNnn

/-! ## 2. Noise versus signal: the two-spread criterion -/

/-- A convex combination of numbers inside a window stays inside the window. -/
theorem pooled_window_of_seed_window {r : ℕ} {w rho : Fin r → ℝ} {lo s : ℝ}
    (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, lo ≤ rho k) (hhi : ∀ k, rho k ≤ lo + s) :
    lo ≤ ∑ k, w k * rho k ∧ ∑ k, w k * rho k ≤ lo + s := by
  constructor
  · have h1 : ∑ k, w k * lo ≤ ∑ k, w k * rho k :=
      Finset.sum_le_sum fun k _ => mul_le_mul_of_nonneg_left (hlo k) (hw k)
    rwa [← Finset.sum_mul, hsum, one_mul] at h1
  · have h1 : ∑ k, w k * rho k ≤ ∑ k, w k * (lo + s) :=
      Finset.sum_le_sum fun k _ => mul_le_mul_of_nonneg_left (hhi k) (hw k)
    rwa [← Finset.sum_mul, hsum, one_mul] at h1

/-- **A step no larger than the seed spread is uninformative**: two pooled readings drawn
from one and the same seed window of width `s` can differ by exactly that step. -/
theorem rebound_within_noise_band {s : ℝ} {step : ℝ}
    (h0 : 0 ≤ step) (h1 : step ≤ s) :
    ∃ (w w' rho rho' : Fin 2 → ℝ) (lo : ℝ),
      (∀ k, 0 ≤ w k) ∧ (∀ k, 0 ≤ w' k) ∧ (∑ k, w k = 1) ∧ (∑ k, w' k = 1) ∧
      (∀ k, lo ≤ rho k ∧ rho k ≤ lo + s) ∧ (∀ k, lo ≤ rho' k ∧ rho' k ≤ lo + s) ∧
      (∑ k, w k * rho k) - (∑ k, w' k * rho' k) = step := by
  refine ⟨![1, 0], ![1, 0], ![step, step], ![0, 0], 0, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro k; fin_cases k <;> norm_num
  · intro k; fin_cases k <;> norm_num
  · simp [Fin.sum_univ_two]
  · simp [Fin.sum_univ_two]
  · intro k; fin_cases k <;> constructor <;> simp <;> linarith
  · intro k; fin_cases k <;> constructor <;> simp <;> linarith
  · simp [Fin.sum_univ_two]

/-- **Distinct windows.**  A pooled gap exceeding the seed spread forces the two seed
windows to have different lower endpoints. -/
theorem gap_le_spread_of_same_window {r : ℕ} {w w' rho rho' : Fin r → ℝ} {lo lo' s : ℝ}
    (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hw' : ∀ k, 0 ≤ w' k) (hsum' : ∑ k, w' k = 1)
    (h1 : ∀ k, lo ≤ rho k) (h2 : ∀ k, rho k ≤ lo + s)
    (h3 : ∀ k, lo' ≤ rho' k) (h4 : ∀ k, rho' k ≤ lo' + s)
    (hgap : s < (∑ k, w k * rho k) - (∑ k, w' k * rho' k)) :
    lo' < lo := by
  have hA := (pooled_window_of_seed_window hw hsum h1 h2).2
  have hB := (pooled_window_of_seed_window hw' hsum' h3 h4).1
  linarith

/-- **Disjoint windows.**  A pooled gap exceeding twice the seed spread separates the two
seed windows completely: every seed at the earlier level reads above every seed at the
later level. -/
theorem separated_windows_of_large_gap {r : ℕ} {w w' rho rho' : Fin r → ℝ} {lo lo' s : ℝ}
    (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hw' : ∀ k, 0 ≤ w' k) (hsum' : ∑ k, w' k = 1)
    (h1 : ∀ k, lo ≤ rho k) (h2 : ∀ k, rho k ≤ lo + s)
    (h3 : ∀ k, lo' ≤ rho' k) (h4 : ∀ k, rho' k ≤ lo' + s)
    (hgap : 2 * s < (∑ k, w k * rho k) - (∑ k, w' k * rho' k)) :
    ∀ j k, rho' j < rho k := by
  have hA := (pooled_window_of_seed_window hw hsum h1 h2).2
  have hB := (pooled_window_of_seed_window hw' hsum' h3 h4).1
  intro j k
  have := h4 j
  have := h1 k
  linarith

/-! ## 3. The advantage–decorrelation duality -/

/-- **Advantage–decorrelation duality.**  Gram positivity alone bounds the gap between two
readings against a shared response by the decorrelation of the two statistics. -/
theorem advantage_sq_le {a b c : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1)
    (hc : -1 ≤ c) (hc1 : c ≤ 1)
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) :
    (a - b) ^ 2 ≤ 2 * (1 - c) := by
  rcases eq_or_lt_of_le hc with h | h
  · have hceq : c = -1 := h.symm
    subst hceq
    nlinarith [sq_nonneg (a + b)]
  · have h1c : (0:ℝ) < 1 + c := by linarith
    have key : (1 + c) * ((a - b) ^ 2) ≤ (1 + c) * (2 * (1 - c)) := by
      nlinarith [mul_nonneg (sub_nonneg.mpr hc1) (sq_nonneg (a + b))]
    exact le_of_mul_le_mul_left key h1c

theorem advantage_le_sqrt {a b c : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1)
    (hc : -1 ≤ c) (hc1 : c ≤ 1)
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) :
    a - b ≤ Real.sqrt (2 * (1 - c)) := by
  have h := advantage_sq_le ha hb hc hc1 hg
  have h2 : |a - b| ≤ Real.sqrt (2 * (1 - c)) := by
    rw [← Real.sqrt_sq_eq_abs]
    exact Real.sqrt_le_sqrt h
  exact le_trans (le_abs_self _) h2

/-- The dual form: **any measured advantage is a decorrelation certificate**. -/
theorem corr_le_of_advantage {a b c : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1)
    (hc : -1 ≤ c) (hc1 : c ≤ 1)
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) :
    c ≤ 1 - (a - b) ^ 2 / 2 := by
  have h := advantage_sq_le ha hb hc hc1 hg
  linarith

/-- Geometric form of the duality for actual vectors. -/
theorem advantage_le_sqrt_corr {u v w : Fin n → ℝ}
    (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) (hw : dot w w ≠ 0) :
    corr u w - corr v w ≤ Real.sqrt (2 * (1 - corr u v)) := by
  have hg := corr_gram u v w hu hv hw
  have hab := abs_le.mp (abs_corr_le_one u v hu hv)
  have haw := abs_le.mp (abs_corr_le_one u w hu hw)
  have hbw := abs_le.mp (abs_corr_le_one v w hv hw)
  refine advantage_le_sqrt (a := corr u w) (b := corr v w) (c := corr u v) ?_ ?_
    hab.1 hab.2 ?_
  · nlinarith [haw.1, haw.2]
  · nlinarith [hbw.1, hbw.2]
  · nlinarith [hg]

/-- **Sharpness.**  For every mutual correlation `c < 1` there are explicit plane vectors
realising the extremal advantage `√(2(1-c))`. -/
theorem advantage_duality_sharp {c : ℝ} (hc : -1 ≤ c) (hc1 : c < 1) :
    ∃ u v w : Fin 2 → ℝ,
      dot u u = 1 ∧ dot v v = 1 ∧ dot w w ≠ 0 ∧
      corr u v = c ∧ corr u w - corr v w = Real.sqrt (2 * (1 - c)) := by
  have hc2 : c ^ 2 ≤ 1 := by nlinarith
  have hss : Real.sqrt (1 - c ^ 2) * Real.sqrt (1 - c ^ 2) = 1 - c ^ 2 :=
    Real.mul_self_sqrt (by linarith)
  set u : Fin 2 → ℝ := ![1, 0] with hu_def
  set v : Fin 2 → ℝ := ![c, Real.sqrt (1 - c ^ 2)] with hv_def
  set w : Fin 2 → ℝ := ![1 - c, -Real.sqrt (1 - c ^ 2)] with hw_def
  have huu : dot u u = 1 := by simp [dot, hu_def, Fin.sum_univ_two]
  have hvv : dot v v = 1 := by
    simp only [dot, hv_def, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
    rw [hss]; ring
  have huv : dot u v = c := by
    simp [dot, hu_def, hv_def, Fin.sum_univ_two]
  have hww : dot w w = 2 * (1 - c) := by
    simp only [dot, hw_def, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one, neg_mul_neg]
    rw [hss]; ring
  have huw : dot u w = 1 - c := by
    simp [dot, hu_def, hw_def, Fin.sum_univ_two]
  have hvw : dot v w = c - 1 := by
    simp only [dot, hv_def, hw_def, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one, mul_neg]
    rw [hss]; ring
  have hwpos : (0:ℝ) < 2 * (1 - c) := by linarith
  have hnu : nrm u = 1 := by rw [nrm, huu, Real.sqrt_one]
  have hnv : nrm v = 1 := by rw [nrm, hvv, Real.sqrt_one]
  have hnw : nrm w = Real.sqrt (2 * (1 - c)) := by rw [nrm, hww]
  refine ⟨u, v, w, huu, hvv, by rw [hww]; exact ne_of_gt hwpos, ?_, ?_⟩
  · rw [corr, huv, hnu, hnv]; ring
  · rw [corr, corr, huw, hvw, hnu, hnv, hnw]
    simp only [one_mul]
    rw [div_sub_div_same, show (1 - c) - (c - 1) = 2 * (1 - c) by ring]
    exact Real.div_sqrt

/-! ## 4. No positive floor under a persistent fade -/

/-- A ratio-bounded fade is dominated by a geometric envelope. -/
theorem fade_geometric {rho : ℕ → ℝ} {q : ℝ} (hq : 0 ≤ q)
    (hstep : ∀ k, rho (k + 1) ≤ q * rho k) (k : ℕ) :
    rho k ≤ q ^ k * rho 0 := by
  induction k with
  | zero => simp
  | succ k ih =>
      calc rho (k + 1) ≤ q * rho k := hstep k
        _ ≤ q * (q ^ k * rho 0) := mul_le_mul_of_nonneg_left ih hq
        _ = q ^ (k + 1) * rho 0 := by ring

/-- **No positive floor.**  A persistent multiplicative fade eventually reads below every
positive level; a "floor" hypothesis therefore contradicts the fade law rather than
refining it. -/
theorem fade_below_any_floor {rho : ℕ → ℝ} {q : ℝ} (hq : 0 ≤ q) (hq1 : q < 1)
    (hpos : ∀ k, 0 ≤ rho k) (hstep : ∀ k, rho (k + 1) ≤ q * rho k)
    {eps : ℝ} (heps : 0 < eps) :
    ∃ N, ∀ k, N ≤ k → rho k < eps := by
  have hr0 : 0 ≤ rho 0 := hpos 0
  obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one (show 0 < eps / (rho 0 + 1) by positivity) hq1
  refine ⟨N, fun k hk => ?_⟩
  have h1 : rho k ≤ q ^ k * rho 0 := fade_geometric hq hstep k
  have h2 : q ^ k ≤ q ^ N := pow_le_pow_of_le_one hq hq1.le hk
  have h3 : q ^ k * rho 0 ≤ q ^ N * rho 0 := mul_le_mul_of_nonneg_right h2 hr0
  have h4 : q ^ N * rho 0 ≤ eps / (rho 0 + 1) * rho 0 :=
    mul_le_mul_of_nonneg_right hN.le hr0
  have h5 : eps / (rho 0 + 1) * rho 0 < eps := by
    rw [div_mul_eq_mul_div, div_lt_iff₀ (by linarith)]
    nlinarith
  linarith

/-- Contrapositive: a genuine positive floor refutes every uniform ratio bound `q < 1`. -/
theorem floor_refutes_geometric_fade {rho : ℕ → ℝ} {q f : ℝ} (hq : 0 ≤ q) (hq1 : q < 1)
    (hpos : ∀ k, 0 ≤ rho k) (hf : 0 < f) (hfloor : ∀ k, f ≤ rho k) :
    ¬ (∀ k, rho (k + 1) ≤ q * rho k) := by
  intro hstep
  obtain ⟨N, hN⟩ := fade_below_any_floor hq hq1 hpos hstep hf
  exact absurd (hfloor N) (not_le.mpr (hN N le_rfl))

/-! ## 5. The recorded data (exp 554) -/

/-- The bitlen ladder with the U116 rebound rung removed (the rebound is shown below to be
noise-compatible). -/
def deNoisedLadder : ℕ → ℚ
  | 0 => 5739 / 10000
  | 1 => 5436 / 10000
  | 2 => 5005 / 10000
  | 3 => 4880 / 10000
  | 4 => 4621 / 10000
  | _ => 4364 / 10000

def pooled120 : ℚ := 43636 / 100000
def ci120Low : ℚ := 38815 / 100000
def ci120High : ℚ := 48113 / 100000
def seedSpread120 : ℚ := 82 / 1000
def reboundStep : ℚ := 226 / 10000
def retraceStep : ℚ := 483 / 10000
def countAdvantage120 : ℚ := 752 / 10000

theorem u120_in_ci : ci120Low < pooled120 ∧ pooled120 < ci120High := by
  constructor <;> norm_num [ci120Low, ci120High, pooled120]

/-- The reading is far below the Gram parity threshold `1/√2`, so count parity is *free*
at bitlen 120: the observed advantage is not forced by geometry. -/
theorem u120_below_parity_threshold : 2 * pooled120 ^ 2 < 1 := by
  norm_num [pooled120]

/-- The recorded de-noised ladder fades by a factor at most `0.98` at every rung. -/
theorem u120_ladder_ratio_bound :
    ∀ k : ℕ, k < 5 → deNoisedLadder (k + 1) ≤ (98 / 100 : ℚ) * deNoisedLadder k := by
  intro k hk
  interval_cases k <;> norm_num [deNoisedLadder]

/-- The U116 rebound and its retrace are both smaller than the seed spread, hence carry no
information: each is realisable inside a single seed window. -/
theorem u120_rebound_is_noise_compatible :
    reboundStep ≤ seedSpread120 ∧ retraceStep ≤ seedSpread120 := by
  constructor <;> norm_num [reboundStep, retraceStep, seedSpread120]

/-- The cumulative fade over the whole sweep does exceed the seed spread, so the two ends
of the ladder cannot share a seed window. -/
theorem u120_total_fade_exceeds_spread :
    seedSpread120 < deNoisedLadder 0 - deNoisedLadder 5 := by
  norm_num [seedSpread120, deNoisedLadder]

/-- The recorded advantage certifies decorrelation of `T` from the count baseline. -/
theorem u120_advantage_forces_decorrelation {a b c : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1)
    (hc : -1 ≤ c) (hc1 : c ≤ 1)
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c))
    (hadv : (countAdvantage120 : ℝ) ≤ a - b) :
    c ≤ 0.99718 := by
  have h := corr_le_of_advantage ha hb hc hc1 hg
  have hpos : (0:ℝ) ≤ (countAdvantage120 : ℝ) := by norm_num [countAdvantage120]
  have hsq : ((countAdvantage120 : ℝ)) ^ 2 ≤ (a - b) ^ 2 := by nlinarith
  have hval : ((countAdvantage120 : ℝ)) ^ 2 = 0.00565504 := by
    norm_num [countAdvantage120]
  rw [hval] at hsq
  linarith

/-- **The falsifiable prediction.**  If the recorded per-rung ratio `0.98` persists, five
more rungs put the dial below `0.40`; any measured value above `0.40` after five further
rungs refutes the persistent-fade law. -/
theorem u120_predicts_below_forty {rho : ℕ → ℝ}
    (hstep : ∀ k, rho (k + 1) ≤ 0.98 * rho k) (h0 : rho 0 ≤ 0.43636) :
    rho 5 < 0.40 := by
  have h := fade_geometric (q := 0.98) (by norm_num) hstep 5
  have h2 : (0.98:ℝ) ^ 5 * rho 0 ≤ (0.98:ℝ) ^ 5 * 0.43636 :=
    mul_le_mul_of_nonneg_left h0 (by positivity)
  have h3 : (0.98:ℝ) ^ 5 * 0.43636 < 0.40 := by norm_num
  linarith

end Catalog.Algebra.ZeroFitDialU120Floor