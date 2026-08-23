import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialPerturbation

/-!
# The parity threshold `1/√2`: what count parity costs a rank dial

## Research context (FACT round-63 #1, exp 532, `U72-DIAL-HOLDS-COUNT-PARITY`)

The recorded measurement is a Spearman rank correlation between the zero-count
statistic `T` (the number of trailing binary zeros of a uniformly drawn integer) and a
downstream `rate`, on uniform draws at bitlen 72:

* seeds 20261160/61/62 give `0.605 / 0.606 / 0.603`;
* pooled `0.605`, CI `[0.586, 0.625]`, all inside the validation band `[0.55, 0.85]`;
* **count parity**: the advantage of `T` over the plain count (popcount) baseline has
  fallen below `+0.05`, whereas at bitlen 44–52 it was `≈ +0.07`;
* the dial declines gently from `≈ 0.78` at bitlen 44 to `≈ 0.605` at bitlen 72.

The earlier catalog files analyse *one* statistic at a time: `Novelty.ZeroFitDialU64`
proves the tie-attenuation law `ρ² = 1 - 12·Σⱼ(mⱼ³-mⱼ)/(n³-n)` and the dyadic ceiling
`6/7`; `MachineLearning.ZeroFitDialUnif52` computes the count baseline's own ceiling;
`Novelty.ZeroFitDialPerturbation` bounds how much re-ranking a dial move costs.  None of
them can say anything about *parity*, because parity is a statement about **two**
statistics read against **one** shared response.  That is a three-variable question, and
three-variable rank data is constrained by Gram positivity, not by tie geometry.

This file supplies that missing geometry and extracts a sharp, falsifiable threshold.

## Main results

* `gram_det_nonneg` — the three-vector Gram determinant inequality in raw (homogeneous)
  form, proved from Cauchy–Schwarz applied to the residuals `‖u‖²v - ⟪u,v⟫u`.
* `corr_gram` — its correlation form `a² + b² + c² ≤ 1 + 2abc` for the three pairwise
  correlations of any three nonzero vectors.
* `parity_ceiling` — the **parity ceiling law**: if two statistics both read at least `ρ`
  against a shared response and their mutual correlation is `c < 1`, then
  `ρ² ≤ (1 + c)/2`.  In particular (`decorrelated_parity_ceiling`) two *uncorrelated*
  statistics can never both read above `1/√2 ≈ 0.70711`.
* `parity_realizable` — sharpness: for **every** `|t| ≤ √2/2` there are explicit vectors
  with `corr u v = 0` and `corr u w = corr v w = t`.  So `1/√2` is exactly the parity
  threshold, attained and not improvable.
* `advantage_forces_correlation` — the contrapositive at the other end of the dial: a pair
  of readings `(0.78, 0.71)` (the bitlen-44 regime) forces the two statistics to be
  correlated at level `≥ 0.11`.
* `count_advantage_lower_bound`, `count_advantage_positive_above_threshold` — the
  **advantage law**: a decorrelated baseline against a dial reading `rho` must lose by at
  least `rho - √(1-rho²)`, which is strictly positive above the threshold.  Count parity is
  therefore itself evidence that the dial has fallen below `√2/2`.
* `u72_parity_free`, `dial44_above_parity_threshold`, `parity_crossing_dichotomy` — the
  **dichotomy**: the bitlen-72 reading `0.605` lies below the threshold and is therefore
  realisable by two decorrelated statistics (count parity is *free* there), while the
  bitlen-44 reading `0.78` lies above it and is not.  The reported disappearance of the
  count advantage is exactly what a monotone decline through `1/√2` predicts.
* `corr_centered_eq_spearman`, `rhoRank_eq_corr` — the bridge that makes the above about
  *rank* data: for two rank vectors with equal mean and equal centred norm, the geometric
  correlation equals Spearman's `1 - 6Σd²/(n³-n)`, i.e. the `rhoRank` of
  `Novelty.ZeroFitDialPerturbation`.
* `rank_centered_normSq`, `centered_normSq_perm` — the rank vector `(1,…,n)` has centred
  norm `(n³-n)/12`, invariantly under permutation, so the bridge hypotheses hold for
  genuine tie-free rankings.
* Recorded-data theorems `u72_inside_band`, `u72_pooled_near_seed_mean`, `u72_in_ci`,
  `u72_below_tie_ceiling`, `u72_count_parity_keeps_band`.

## The scientific payload

Tie geometry (all earlier cycles) caps the dial at `6/7 ≈ 0.857` and is *flat* in the
bitlen; it cannot explain either the decline or the parity.  Gram geometry caps a
*parity* reading at `1/√2 ≈ 0.707` and is not flat at all in the recorded data: the dial
crosses this exact value somewhere between bitlen 44 (`0.78`, above) and bitlen 72
(`0.605`, below), which is precisely the range over which the count advantage decays from
`+0.07` to below `+0.05`.  The prediction is falsifiable: any future bitlen at which the
dial reads above `0.708` must show a *positive* count advantage, or else the zero-count
and count statistics must be measurably correlated at level `≥ 2ρ² - 1`.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU72Parity

/-! ## 1. Euclidean scaffolding on `Fin n → ℝ` -/

variable {n : ℕ}

/-- The Euclidean inner product of two coordinate vectors. -/
def dot (u v : Fin n → ℝ) : ℝ := ∑ i, u i * v i

lemma dot_comm (u v : Fin n → ℝ) : dot u v = dot v u := by
  simp [dot, mul_comm]

lemma dot_self_nonneg (u : Fin n → ℝ) : 0 ≤ dot u u :=
  Finset.sum_nonneg fun i _ => mul_self_nonneg (u i)

lemma dot_smul_left (s : ℝ) (u v : Fin n → ℝ) :
    dot (fun i => s * u i) v = s * dot u v := by
  simp [dot, Finset.mul_sum, mul_assoc]

lemma dot_sub_left (u v w : Fin n → ℝ) :
    dot (fun i => u i - v i) w = dot u w - dot v w := by
  simp [dot, sub_mul, Finset.sum_sub_distrib]

lemma dot_smul_right (s : ℝ) (u v : Fin n → ℝ) :
    dot u (fun i => s * v i) = s * dot u v := by
  rw [dot_comm, dot_smul_left, dot_comm]

lemma dot_sub_right (u v w : Fin n → ℝ) :
    dot u (fun i => v i - w i) = dot u v - dot u w := by
  rw [dot_comm, dot_sub_left, dot_comm w u, dot_comm v u]

/-- Cauchy–Schwarz for `dot`. -/
lemma dot_sq_le (u v : Fin n → ℝ) : dot u v ^ 2 ≤ dot u u * dot v v := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq univ u v
  have hu : ∑ i, u i ^ 2 = dot u u := by simp [dot, pow_two]
  have hv : ∑ i, v i ^ 2 = dot v v := by simp [dot, pow_two]
  rw [hu, hv] at h
  exact h

lemma eq_zero_of_dot_self_eq_zero {u : Fin n → ℝ} (h : dot u u = 0) (i : Fin n) :
    u i = 0 := by
  have hnn : ∀ j ∈ (univ : Finset (Fin n)), 0 ≤ u j * u j := fun j _ => mul_self_nonneg _
  have := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h i (mem_univ i)
  exact mul_self_eq_zero.mp this

/-! ## 2. The Gram determinant inequality -/

/-- **Three-vector Gram positivity, homogeneous form.**  For any three coordinate vectors
the `3 × 3` Gram determinant is nonnegative.  The proof projects `v` and `w` onto the
orthogonal complement of `u` (scaled by `‖u‖²` to stay polynomial) and applies
Cauchy–Schwarz to the residuals. -/
theorem gram_det_nonneg (u v w : Fin n → ℝ) :
    0 ≤ dot u u * dot v v * dot w w + 2 * (dot u v * dot u w * dot v w)
        - dot u u * dot v w ^ 2 - dot v v * dot u w ^ 2 - dot w w * dot u v ^ 2 := by
  set p := dot u u with hp
  set q := dot v v with hq
  set r := dot w w with hr
  set A := dot u w with hA
  set B := dot v w with hB
  set C := dot u v with hC
  rcases eq_or_lt_of_le (dot_self_nonneg u) with hp0 | hppos
  · -- `u = 0`, so `A = C = 0`
    have hu0 : ∀ i, u i = 0 := eq_zero_of_dot_self_eq_zero hp0.symm
    have hA0 : A = 0 := by simp [hA, dot, hu0]
    have hC0 : C = 0 := by simp [hC, dot, hu0]
    have hpz : p = 0 := hp0.symm
    rw [hpz, hA0, hC0]
    norm_num
  · -- residuals `v' = p·v - C·u`, `w' = p·w - A·u`
    set v' : Fin n → ℝ := fun i => p * v i - C * u i with hv'
    set w' : Fin n → ℝ := fun i => p * w i - A * u i with hw'
    have hvw' : dot v' w' = p * (p * B - A * C) := by
      have h1 : dot v' w' = p * dot v w' - C * dot u w' := by
        rw [hv']
        rw [show (fun i => p * v i - C * u i) =
              (fun i => (fun j => p * v j) i - (fun j => C * u j) i) from rfl]
        rw [dot_sub_left, dot_smul_left, dot_smul_left]
      have h2 : dot v w' = p * B - A * C := by
        rw [hw']
        rw [show (fun i => p * w i - A * u i) =
              (fun i => (fun j => p * w j) i - (fun j => A * u j) i) from rfl]
        rw [dot_sub_right, dot_smul_right, dot_smul_right, ← hB, dot_comm v u, ← hC]
      have h3 : dot u w' = p * A - A * p := by
        rw [hw']
        rw [show (fun i => p * w i - A * u i) =
              (fun i => (fun j => p * w j) i - (fun j => A * u j) i) from rfl]
        rw [dot_sub_right, dot_smul_right, dot_smul_right, ← hA, ← hp]
      rw [h1, h2, h3]; ring
    have hvv' : dot v' v' = p * (p * q - C ^ 2) := by
      have h1 : dot v' v' = p * dot v v' - C * dot u v' := by
        rw [hv']
        rw [show (fun i => p * v i - C * u i) =
              (fun i => (fun j => p * v j) i - (fun j => C * u j) i) from rfl]
        rw [dot_sub_left, dot_smul_left, dot_smul_left]
      have h2 : dot v v' = p * q - C * C := by
        rw [hv']
        rw [show (fun i => p * v i - C * u i) =
              (fun i => (fun j => p * v j) i - (fun j => C * u j) i) from rfl]
        rw [dot_sub_right, dot_smul_right, dot_smul_right, ← hq, dot_comm v u, ← hC]
      have h3 : dot u v' = p * C - C * p := by
        rw [hv']
        rw [show (fun i => p * v i - C * u i) =
              (fun i => (fun j => p * v j) i - (fun j => C * u j) i) from rfl]
        rw [dot_sub_right, dot_smul_right, dot_smul_right, ← hC, ← hp]
      rw [h1, h2, h3]; ring
    have hww' : dot w' w' = p * (p * r - A ^ 2) := by
      have h1 : dot w' w' = p * dot w w' - A * dot u w' := by
        rw [hw']
        rw [show (fun i => p * w i - A * u i) =
              (fun i => (fun j => p * w j) i - (fun j => A * u j) i) from rfl]
        rw [dot_sub_left, dot_smul_left, dot_smul_left]
      have h2 : dot w w' = p * r - A * A := by
        rw [hw']
        rw [show (fun i => p * w i - A * u i) =
              (fun i => (fun j => p * w j) i - (fun j => A * u j) i) from rfl]
        rw [dot_sub_right, dot_smul_right, dot_smul_right, ← hr, dot_comm w u, ← hA]
      have h3 : dot u w' = p * A - A * p := by
        rw [hw']
        rw [show (fun i => p * w i - A * u i) =
              (fun i => (fun j => p * w j) i - (fun j => A * u j) i) from rfl]
        rw [dot_sub_right, dot_smul_right, dot_smul_right, ← hA, ← hp]
      rw [h1, h2, h3]; ring
    have hcs := dot_sq_le v' w'
    rw [hvw', hvv', hww'] at hcs
    -- `p²(pB - AC)² ≤ p²(pq - C²)(pr - A²)`
    have hkey : (p * B - A * C) ^ 2 ≤ (p * q - C ^ 2) * (p * r - A ^ 2) := by
      have hpp : (0 : ℝ) < p * p := mul_pos hppos hppos
      nlinarith [hcs, hpp]
    have hmul : 0 ≤ p * (p * q * r + 2 * (C * A * B) - p * B ^ 2 - q * A ^ 2 - r * C ^ 2) := by
      nlinarith [hkey]
    have := (mul_nonneg_iff_of_pos_left hppos).mp hmul
    nlinarith [this]

/-! ## 3. Correlations -/

/-- Euclidean norm of a coordinate vector. -/
noncomputable def nrm (u : Fin n → ℝ) : ℝ := Real.sqrt (dot u u)

lemma nrm_sq (u : Fin n → ℝ) : nrm u ^ 2 = dot u u :=
  Real.sq_sqrt (dot_self_nonneg u)

lemma nrm_pos {u : Fin n → ℝ} (h : dot u u ≠ 0) : 0 < nrm u :=
  Real.sqrt_pos.mpr (lt_of_le_of_ne (dot_self_nonneg u) (Ne.symm h))

/-- The (Pearson) correlation of two coordinate vectors; applied to *centred rank*
vectors this is Spearman's coefficient (see `corr_centered_eq_spearman`). -/
noncomputable def corr (u v : Fin n → ℝ) : ℝ := dot u v / (nrm u * nrm v)

lemma corr_comm (u v : Fin n → ℝ) : corr u v = corr v u := by
  rw [corr, corr, dot_comm, mul_comm (nrm v) (nrm u)]

lemma corr_sq (u v : Fin n → ℝ) :
    corr u v ^ 2 = dot u v ^ 2 / (dot u u * dot v v) := by
  rw [corr, div_pow, mul_pow, nrm_sq, nrm_sq]

/-- **Gram positivity in correlation form.**  The three pairwise correlations of any three
nonzero vectors satisfy `a² + b² + c² ≤ 1 + 2abc`. -/
theorem corr_gram (u v w : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (hw : dot w w ≠ 0) :
    corr u v ^ 2 + corr u w ^ 2 + corr v w ^ 2
      ≤ 1 + 2 * (corr u v * corr u w * corr v w) := by
  have hp : 0 < dot u u := lt_of_le_of_ne (dot_self_nonneg u) (Ne.symm hu)
  have hq : 0 < dot v v := lt_of_le_of_ne (dot_self_nonneg v) (Ne.symm hv)
  have hr : 0 < dot w w := lt_of_le_of_ne (dot_self_nonneg w) (Ne.symm hw)
  have hprod : corr u v * corr u w * corr v w
      = dot u v * dot u w * dot v w / (dot u u * dot v v * dot w w) := by
    rw [corr, corr, corr]
    rw [div_mul_div_comm, div_mul_div_comm]
    congr 1
    have : nrm u * nrm v * (nrm u * nrm w) * (nrm v * nrm w)
        = nrm u ^ 2 * nrm v ^ 2 * nrm w ^ 2 := by ring
    rw [this, nrm_sq, nrm_sq, nrm_sq]
  rw [corr_sq u v, corr_sq u w, corr_sq v w, hprod]
  rw [← sub_nonneg]
  have hkey : 1 + 2 * (dot u v * dot u w * dot v w / (dot u u * dot v v * dot w w))
      - (dot u v ^ 2 / (dot u u * dot v v) + dot u w ^ 2 / (dot u u * dot w w)
         + dot v w ^ 2 / (dot v v * dot w w))
      = (dot u u * dot v v * dot w w + 2 * (dot u v * dot u w * dot v w)
          - dot u u * dot v w ^ 2 - dot v v * dot u w ^ 2 - dot w w * dot u v ^ 2)
        / (dot u u * dot v v * dot w w) := by
    field_simp
    ring
  rw [hkey]
  exact div_nonneg (gram_det_nonneg u v w) (by positivity)

lemma abs_corr_le_one (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) :
    |corr u v| ≤ 1 := by
  have hp : 0 < dot u u := lt_of_le_of_ne (dot_self_nonneg u) (Ne.symm hu)
  have hq : 0 < dot v v := lt_of_le_of_ne (dot_self_nonneg v) (Ne.symm hv)
  have hsq : corr u v ^ 2 ≤ 1 := by
    rw [corr_sq u v, div_le_one (by positivity)]
    exact dot_sq_le u v
  nlinarith [abs_nonneg (corr u v), sq_abs (corr u v), hsq]

/-! ## 4. The parity ceiling law -/

/-- **Parity ceiling law.**  If two statistics both correlate at level at least `rho ≥ 0`
with a shared response, and their mutual correlation is `c < 1`, then
`rho² ≤ (1 + c)/2`.  Only Gram positivity `a² + b² + c² ≤ 1 + 2abc` is used, so the law
holds for any three-variable correlation structure. -/
theorem parity_ceiling {a b c rho : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c))
    (hc : c < 1) (hrho : 0 ≤ rho) (ha : rho ≤ a) (hb : rho ≤ b) :
    rho ^ 2 ≤ (1 + c) / 2 := by
  have hab : rho ^ 2 ≤ a * b := by nlinarith
  have h1 : 2 * (a * b) * (1 - c) ≤ 1 - c ^ 2 := by nlinarith [sq_nonneg (a - b)]
  have h2 : 2 * rho ^ 2 * (1 - c) ≤ 1 - c ^ 2 := by nlinarith [sub_pos.mpr hc]
  have hc1 : 0 < 1 - c := sub_pos.mpr hc
  have h3 : 2 * rho ^ 2 * (1 - c) ≤ (1 + c) * (1 - c) := by nlinarith
  nlinarith [h3, hc1]

/-- **The parity threshold.**  Two *uncorrelated* statistics cannot both read above
`√2/2 ≈ 0.70711` against a shared response. -/
theorem decorrelated_parity_ceiling {a b c rho : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c))
    (hc : c ≤ 0) (hrho : 0 ≤ rho) (ha : rho ≤ a) (hb : rho ≤ b) :
    rho ≤ Real.sqrt 2 / 2 := by
  have hlt : c < 1 := lt_of_le_of_lt hc (by norm_num)
  have h := parity_ceiling hg hlt hrho ha hb
  have h2 : rho ^ 2 ≤ 1 / 2 := by linarith
  nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2, h2, hrho]

/-- The parity ceiling is attained: for every level `t` with `2t² ≤ 1` (i.e. `|t| ≤ √2/2`)
there are three explicit vectors realising `corr u v = 0` and `corr u w = corr v w = t`. -/
theorem parity_realizable {t : ℝ} (ht2 : 2 * t ^ 2 ≤ 1) :
    ∃ u v w : Fin 3 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u v = 0 ∧ corr u w = t ∧ corr v w = t := by
  refine ⟨![1, 0, 0], ![0, 1, 0], ![t, t, Real.sqrt (1 - 2 * t ^ 2)], ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [dot, Fin.sum_univ_three]
  · simp [dot, Fin.sum_univ_three]
  · have hs : Real.sqrt (1 - 2 * t ^ 2) ^ 2 = 1 - 2 * t ^ 2 :=
      Real.sq_sqrt (by linarith)
    have : dot (![t, t, Real.sqrt (1 - 2 * t ^ 2)] : Fin 3 → ℝ) ![t, t, Real.sqrt (1 - 2 * t ^ 2)]
        = 1 := by
      simp [dot, Fin.sum_univ_three, ← pow_two, hs]; ring
    rw [this]; norm_num
  · simp [corr, dot, Fin.sum_univ_three]
  · have hs : Real.sqrt (1 - 2 * t ^ 2) ^ 2 = 1 - 2 * t ^ 2 :=
      Real.sq_sqrt (by linarith)
    have hd : dot (![t, t, Real.sqrt (1 - 2 * t ^ 2)] : Fin 3 → ℝ)
        ![t, t, Real.sqrt (1 - 2 * t ^ 2)] = 1 := by
      simp [dot, Fin.sum_univ_three, ← pow_two, hs]; ring
    have hu : dot (![1, 0, 0] : Fin 3 → ℝ) ![1, 0, 0] = 1 := by
      simp [dot, Fin.sum_univ_three]
    have huw : dot (![1, 0, 0] : Fin 3 → ℝ) ![t, t, Real.sqrt (1 - 2 * t ^ 2)] = t := by
      simp [dot, Fin.sum_univ_three]
    rw [corr, huw, nrm, nrm, hu, hd, Real.sqrt_one]
    norm_num
  · have hs : Real.sqrt (1 - 2 * t ^ 2) ^ 2 = 1 - 2 * t ^ 2 :=
      Real.sq_sqrt (by linarith)
    have hd : dot (![t, t, Real.sqrt (1 - 2 * t ^ 2)] : Fin 3 → ℝ)
        ![t, t, Real.sqrt (1 - 2 * t ^ 2)] = 1 := by
      simp [dot, Fin.sum_univ_three, ← pow_two, hs]; ring
    have hv : dot (![0, 1, 0] : Fin 3 → ℝ) ![0, 1, 0] = 1 := by
      simp [dot, Fin.sum_univ_three]
    have hvw : dot (![0, 1, 0] : Fin 3 → ℝ) ![t, t, Real.sqrt (1 - 2 * t ^ 2)] = t := by
      simp [dot, Fin.sum_univ_three]
    rw [corr, hvw, nrm, nrm, hv, hd, Real.sqrt_one]
    norm_num

/-- **The forcing law.**  Gram positivity pins the mutual correlation of the two
statistics into an interval around `ab`; the lower endpoint is what a *high* pair of
readings forces. -/
theorem corr_lower_bound {a b c : ℝ} (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) :
    a * b - Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) ≤ c := by
  have hsq : (c - a * b) ^ 2 ≤ (1 - a ^ 2) * (1 - b ^ 2) := by nlinarith
  have habs : |c - a * b| ≤ Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) := by
    have h1 : Real.sqrt ((c - a * b) ^ 2) ≤ Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) :=
      Real.sqrt_le_sqrt hsq
    rwa [Real.sqrt_sq_eq_abs] at h1
  have := abs_le.mp habs
  linarith [this.1]

/-- Applied at the bitlen-44 end of the dial: readings `(≥ 0.78, ≥ 0.71)` against the same
response force the two statistics themselves to be correlated at level `≥ 0.11`. -/
theorem advantage_forces_correlation {a b c : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c))
    (ha : 78 / 100 ≤ a) (ha1 : a ≤ 1) (hb : 71 / 100 ≤ b) (hb1 : b ≤ 1) :
    11 / 100 ≤ c := by
  nlinarith [hg, sq_nonneg (a - b), sq_nonneg (c - a * b), sq_nonneg (1 - a), sq_nonneg (1 - b),
    mul_nonneg (sub_nonneg.mpr ha1) (sub_nonneg.mpr hb1)]

/-- Under decorrelation the two readings obey the circle bound `a² + b² ≤ 1`. -/
theorem decorrelated_sum_sq_le_one {a b c : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c))
    (hc : c ≤ 0) (ha : 0 ≤ a) (hb : 0 ≤ b) : a ^ 2 + b ^ 2 ≤ 1 := by
  nlinarith [sq_nonneg c, mul_nonneg ha hb]

/-- **The advantage law.**  If the dial reads `rho` and the baseline reads `rho - alpha`
against the same response, and the two statistics are decorrelated, then the advantage is
at least `rho - √(1 - rho²)`. -/
theorem count_advantage_lower_bound {rho alpha c : ℝ}
    (hg : rho ^ 2 + (rho - alpha) ^ 2 + c ^ 2
        ≤ 1 + 2 * (rho * (rho - alpha) * c))
    (hc : c ≤ 0) (hrho : 0 ≤ rho) (hb : 0 ≤ rho - alpha) :
    rho - Real.sqrt (1 - rho ^ 2) ≤ alpha := by
  have h1 : rho ^ 2 + (rho - alpha) ^ 2 ≤ 1 := decorrelated_sum_sq_le_one hg hc hrho hb
  have h2 : (rho - alpha) ^ 2 ≤ 1 - rho ^ 2 := by linarith
  have h3 : rho - alpha ≤ Real.sqrt (1 - rho ^ 2) := by
    have hsq := Real.sqrt_le_sqrt h2
    rwa [Real.sqrt_sq hb] at hsq
  linarith

/-- **Above the parity threshold the advantage cannot vanish.**  A decorrelated baseline
against a dial reading above `√2/2` must be beaten strictly: `alpha > 0`.  Count parity is
therefore evidence that the dial has dropped below the threshold. -/
theorem count_advantage_positive_above_threshold {rho alpha c : ℝ}
    (hg : rho ^ 2 + (rho - alpha) ^ 2 + c ^ 2
        ≤ 1 + 2 * (rho * (rho - alpha) * c))
    (hc : c ≤ 0) (hb : 0 ≤ rho - alpha) (hthr : Real.sqrt 2 / 2 < rho) : 0 < alpha := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hspos : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  have hrho : 0 ≤ rho := by nlinarith
  have h1 : rho ^ 2 + (rho - alpha) ^ 2 ≤ 1 := decorrelated_sum_sq_le_one hg hc hrho hb
  have hhalf : 1 / 2 < rho ^ 2 := by nlinarith
  nlinarith [h1, hhalf, hb, sq_nonneg (rho - alpha)]

/-! ## 5. Bridge: geometric correlation of centred rank vectors is Spearman's `ρ` -/

/-- The mean of a coordinate vector. -/
noncomputable def avg (u : Fin n → ℝ) : ℝ := (∑ i, u i) / n

/-- The centring of a coordinate vector. -/
noncomputable def cen (u : Fin n → ℝ) : Fin n → ℝ := fun i => u i - avg u

lemma dot_expand_sub (u v : Fin n → ℝ) :
    ∑ i, (u i - v i) ^ 2 = dot u u - 2 * dot u v + dot v v := by
  simp only [dot, sub_sq]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.mul_sum]
  simp [pow_two, mul_assoc]

/-- **The Spearman bridge.**  For two vectors with the same mean and the same centred norm
`(n³-n)/12` — the situation of two tie-free rankings of the same `n` items — the geometric
correlation of the centred vectors is exactly Spearman's `1 - 6Σd²/(n³-n)`. -/
theorem corr_centered_eq_spearman (u v : Fin n → ℝ) (hn : 2 ≤ n) (hm : avg u = avg v)
    (hu : dot (cen u) (cen u) = ((n : ℝ) ^ 3 - n) / 12)
    (hv : dot (cen v) (cen v) = ((n : ℝ) ^ 3 - n) / 12) :
    corr (cen u) (cen v) = 1 - 6 * (∑ i, (u i - v i) ^ 2) / ((n : ℝ) ^ 3 - n) := by
  have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hcube : (0 : ℝ) < (n : ℝ) ^ 3 - (n : ℝ) := by
    have hfac : (n : ℝ) ^ 3 - (n : ℝ) = (n : ℝ) * ((n : ℝ) - 1) * ((n : ℝ) + 1) := by ring
    rw [hfac]
    exact mul_pos (mul_pos (by linarith) (by linarith)) (by linarith)
  set K : ℝ := (n : ℝ) ^ 3 - (n : ℝ) with hKdef
  have hne : K ≠ 0 := ne_of_gt hcube
  have hV : (0 : ℝ) < K / 12 := by linarith
  have hd : ∀ i, cen u i - cen v i = u i - v i := by
    intro i; simp [cen, hm]
  have hsum : ∑ i, (u i - v i) ^ 2
      = dot (cen u) (cen u) - 2 * dot (cen u) (cen v) + dot (cen v) (cen v) := by
    rw [← dot_expand_sub (cen u) (cen v)]
    exact (Finset.sum_congr rfl fun i _ => by rw [hd i]).symm
  have hnu : dot (cen u) (cen u) ≠ 0 := by rw [hu]; exact ne_of_gt hV
  have hnv : dot (cen v) (cen v) ≠ 0 := by rw [hv]; exact ne_of_gt hV
  have hnrm : nrm (cen u) * nrm (cen v) = K / 12 := by
    rw [nrm, nrm, hu, hv]
    exact Real.mul_self_sqrt (le_of_lt hV)
  have hcross : dot (cen u) (cen v)
      = K / 12 - (∑ i, (u i - v i) ^ 2) / 2 := by
    rw [hsum, hu, hv]; ring
  rw [corr, hnrm, hcross]
  field_simp
  ring

/-- The catalog's `rhoRank` (Spearman in `d²` form, over `ℚ`) is the geometric correlation
of the centred rank vectors. -/
theorem rhoRank_eq_corr (R S : Fin n → ℚ) (hn : 2 ≤ n)
    (hm : avg (fun i => (R i : ℝ)) = avg (fun i => (S i : ℝ)))
    (hu : dot (cen fun i => (R i : ℝ)) (cen fun i => (R i : ℝ)) = ((n : ℝ) ^ 3 - n) / 12)
    (hv : dot (cen fun i => (S i : ℝ)) (cen fun i => (S i : ℝ)) = ((n : ℝ) ^ 3 - n) / 12) :
    ((Catalog.Novelty.ZeroFitDialPerturbation.rhoRank R S : ℚ) : ℝ)
      = corr (cen fun i => (R i : ℝ)) (cen fun i => (S i : ℝ)) := by
  rw [corr_centered_eq_spearman _ _ hn hm hu hv,
    Catalog.Novelty.ZeroFitDialPerturbation.rhoRank,
    Catalog.Novelty.ZeroFitDialPerturbation.sumSqD]
  push_cast
  ring

/-! ### The centred norm of a genuine ranking -/

lemma sum_range_succ_cast (m : ℕ) : ∑ i ∈ range m, ((i : ℝ) + 1) = (m : ℝ) * (m + 1) / 2 := by
  induction m with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, ih]; push_cast; ring

lemma sum_range_succ_sq_cast (m : ℕ) :
    ∑ i ∈ range m, ((i : ℝ) + 1) ^ 2 = (m : ℝ) * (m + 1) * (2 * m + 1) / 6 := by
  induction m with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, ih]; push_cast; ring

/-- **The rank vector has centred norm `(n³-n)/12`.**  This is the classical Spearman
normalisation, and it is what makes the bridge above non-vacuous. -/
theorem rank_centered_normSq (n : ℕ) :
    dot (cen fun i : Fin n => ((i : ℕ) : ℝ) + 1) (cen fun i : Fin n => ((i : ℕ) : ℝ) + 1)
      = ((n : ℝ) ^ 3 - n) / 12 := by
  rcases Nat.eq_zero_or_pos n with h0 | hpos
  · subst h0; simp [dot]
  have hn : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hpos
  set u : Fin n → ℝ := fun i => ((i : ℕ) : ℝ) + 1 with hu
  have hsum : ∑ i, u i = (n : ℝ) * (n + 1) / 2 := by
    rw [hu, Fin.sum_univ_eq_sum_range (fun i => ((i : ℕ) : ℝ) + 1) n]
    exact sum_range_succ_cast n
  have hsq : ∑ i, u i ^ 2 = (n : ℝ) * (n + 1) * (2 * n + 1) / 6 := by
    rw [hu, Fin.sum_univ_eq_sum_range (fun i => (((i : ℕ) : ℝ) + 1) ^ 2) n]
    exact sum_range_succ_sq_cast n
  have havg : avg u = ((n : ℝ) + 1) / 2 := by
    rw [avg, hsum]
    field_simp
  have hpoint : ∀ i : Fin n, cen u i * cen u i
      = u i ^ 2 - 2 * avg u * u i + avg u ^ 2 := by
    intro i; simp only [cen]; ring
  have hexp : dot (cen u) (cen u) = (∑ i, u i ^ 2) - 2 * avg u * (∑ i, u i)
      + (n : ℝ) * avg u ^ 2 := by
    rw [dot, Finset.sum_congr rfl (fun i _ => hpoint i)]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [hexp, hsq, hsum, havg]
  field_simp
  ring

/-- Centred norms are permutation invariant, so *every* tie-free ranking of `n` items has
centred norm `(n³-n)/12`. -/
theorem centered_normSq_perm (u : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    dot (cen (u ∘ σ)) (cen (u ∘ σ)) = dot (cen u) (cen u) := by
  have havg : avg (u ∘ σ) = avg u := by
    rw [avg, avg]
    congr 1
    exact Fintype.sum_equiv σ _ _ (fun i => rfl)
  rw [dot, dot]
  simp only [cen, havg]
  exact Fintype.sum_equiv σ _ _ (fun i => rfl)

/-! ## 6. The recorded bitlen-72 measurement -/

/-- Seed 20261160. -/
def seed60 : ℚ := 605 / 1000
/-- Seed 20261161. -/
def seed61 : ℚ := 606 / 1000
/-- Seed 20261162. -/
def seed62 : ℚ := 603 / 1000
/-- Pooled reading at bitlen 72. -/
def pooled72 : ℚ := 605 / 1000
/-- Lower CI endpoint. -/
def ci72Low : ℚ := 586 / 1000
/-- Upper CI endpoint. -/
def ci72High : ℚ := 625 / 1000
/-- Reported reading at bitlen 44. -/
def dial44 : ℚ := 78 / 100
/-- Reported cap on the count advantage at bitlen 72 ("count parity"). -/
def parityGap : ℚ := 5 / 100

/-- All three seeds and the pooled reading lie inside the validation band `[0.55, 0.85]`. -/
theorem u72_inside_band :
    55 / 100 ≤ seed60 ∧ seed60 ≤ 85 / 100 ∧
    55 / 100 ≤ seed61 ∧ seed61 ≤ 85 / 100 ∧
    55 / 100 ≤ seed62 ∧ seed62 ≤ 85 / 100 ∧
    55 / 100 ≤ pooled72 ∧ pooled72 ≤ 85 / 100 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [seed60, seed61, seed62, pooled72]

/-- The pooled value agrees with the seed mean to within the reporting precision. -/
theorem u72_pooled_near_seed_mean :
    |pooled72 - (seed60 + seed61 + seed62) / 3| ≤ 1 / 1000 := by
  norm_num [pooled72, seed60, seed61, seed62, abs_le]

/-- The pooled reading lies inside its own confidence interval, which lies inside the band. -/
theorem u72_in_ci :
    ci72Low ≤ pooled72 ∧ pooled72 ≤ ci72High ∧ 55 / 100 ≤ ci72Low ∧ ci72High ≤ 85 / 100 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num [pooled72, ci72Low, ci72High]

open Catalog.Novelty.ZeroFitDialU64 in
/-- The reading squared is far below the 2-adic tie ceiling at bitlen 72, so tie geometry
does not constrain the measurement (as in every earlier bitlen). -/
theorem u72_below_tie_ceiling : pooled72 ^ 2 < spearmanSq (dyadicBlocks 72) := by
  have h := dyadic_ceiling_gt 72 (by norm_num)
  have : pooled72 ^ 2 < 6 / 7 := by norm_num [pooled72]
  linarith

/-- Count parity (advantage `≤ 0.05`) still leaves the count baseline inside the band. -/
theorem u72_count_parity_keeps_band {countRead : ℚ} (h : pooled72 - countRead ≤ parityGap)
    (hle : countRead ≤ pooled72) :
    55 / 100 ≤ countRead ∧ countRead ≤ 85 / 100 := by
  constructor
  · norm_num [pooled72, parityGap] at h ⊢; linarith
  · norm_num [pooled72] at hle ⊢; linarith

/-! ### The parity dichotomy -/

/-- The bitlen-72 reading lies **below** the parity threshold `√2/2`: two decorrelated
statistics may both read `0.605`, and indeed do so in an explicit configuration. -/
theorem u72_parity_free :
    (pooled72 : ℝ) ≤ Real.sqrt 2 / 2 ∧
    ∃ u v w : Fin 3 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u v = 0 ∧ corr u w = (pooled72 : ℝ) ∧ corr v w = (pooled72 : ℝ) := by
  have h2 : (1 : ℝ) ≤ Real.sqrt 2 := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  have hsq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hle : (pooled72 : ℝ) ≤ Real.sqrt 2 / 2 := by
    have : (pooled72 : ℝ) = 605 / 1000 := by norm_num [pooled72]
    rw [this]
    nlinarith [hsq, Real.sqrt_nonneg 2]
  refine ⟨hle, ?_⟩
  have ht2 : 2 * (pooled72 : ℝ) ^ 2 ≤ 1 := by norm_num [pooled72]
  exact parity_realizable ht2

/-- The bitlen-44 reading lies **above** the parity threshold: it is impossible for two
decorrelated statistics to both read `0.78`. -/
theorem dial44_above_parity_threshold :
    Real.sqrt 2 / 2 < (dial44 : ℝ) ∧
    ∀ a b c : ℝ, a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c) →
      c ≤ 0 → (dial44 : ℝ) ≤ a → (dial44 : ℝ) ≤ b → False := by
  have hsq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hd : (dial44 : ℝ) = 78 / 100 := by norm_num [dial44]
  have hgt : Real.sqrt 2 / 2 < (dial44 : ℝ) := by
    rw [hd]; nlinarith [hsq, Real.sqrt_nonneg 2]
  refine ⟨hgt, ?_⟩
  intro a b c hg hc ha hb
  have h0 : (0 : ℝ) ≤ (dial44 : ℝ) := by rw [hd]; norm_num
  have := decorrelated_parity_ceiling hg hc h0 ha hb
  linarith

/-- **The parity crossing dichotomy.**  A reading `rho` obtained by two decorrelated
statistics against a shared response is possible exactly when `rho ≤ √2/2`; the bitlen-72
value sits on the possible side and the bitlen-44 value on the impossible side. -/
theorem parity_crossing_dichotomy :
    (pooled72 : ℝ) ≤ Real.sqrt 2 / 2 ∧ Real.sqrt 2 / 2 < (dial44 : ℝ) ∧
    ∀ rho : ℝ, 0 ≤ rho → rho ≤ Real.sqrt 2 / 2 →
      ∃ u v w : Fin 3 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
        corr u v = 0 ∧ corr u w = rho ∧ corr v w = rho := by
  refine ⟨u72_parity_free.1, dial44_above_parity_threshold.1, ?_⟩
  intro rho h0 hle
  have hsq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have h2 : 2 * rho ^ 2 ≤ 1 := by
    nlinarith [hsq, Real.sqrt_nonneg 2, hle, h0]
  exact parity_realizable h2

end Catalog.Algebra.ZeroFitDialU72Parity