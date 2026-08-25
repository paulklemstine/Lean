import Mathlib
import Algebra.ZeroFitDialU120Floor
import Algebra.ZeroFitDialU64MedianCapacity

/-!
# The sharp seed-imbalance law and the capacity expansion of a fading dial

## Research context (FACT round-72 #4, exp 554, second cycle)

`Algebra.ZeroFitDialU120Floor` established the pooling layer of the `T`-dial thread:
pooling never inflates a reading, balanced pooling is an energy-weighted average, and a
crude imbalance bound `(1-δ)/(1+δ)`.  Two questions were left open by that state of the
thread, and the record's own numbers make both of them pressing.

* **Q1 (sharp seed-imbalance).**  Exp 554 reports the seed spread widening to `0.082`
  while the pooled reading falls by `0.0483`.  The cycle-1 bound `(1-δ)/(1+δ)` is not
  sharp, so it cannot say how much of a fall imbalance is *allowed* to explain.  What is
  the exact worst-case attenuation of a pooled reading when the per-seed response/statistic
  norm ratio ranges over `[α, β]`?
* **Q2 (what the fade buys).**  A falling dial is usually read as a loss.  Against the
  capacity law of `Algebra.ZeroFitDialU64MedianCapacity`
  (`k·ρ² ≤ 1 + (k-1)γ`) a falling `ρ` is instead a *gain*: it enlarges the number of
  mutually decorrelated statistics that can all read at the dial level.

## Main results

### 1. The sharp seed-imbalance law (answers Q1)

* `weighted_kantorovich` — the weighted Kantorovich inequality in the exact form the
  pooling problem needs: for weights `wₖ ≥ 0` and ratios `λₖ ∈ [α, β]` with `α > 0`,
  `4αβ (∑w)(∑wλ²) ≤ (α+β)² (∑wλ)²`.  The proof is the two-line "endpoint" argument:
  `(λ-α)(β-λ) ≥ 0` gives `λ² ≤ (α+β)λ - αβ` pointwise, and the resulting quadratic in
  `∑wλ` is a perfect square `((α+β)M - 2αβS)² ≥ 0`.
* `pooled_kantorovich_bound` — hence the **sharp seed-imbalance law**: a family whose
  per-seed readings are all at least `ρ ≥ 0` and whose per-seed norm ratios lie in
  `[α, β]` pools to at least `ρ · 2√(αβ)/(α+β)`.
* `kantorovich_pooling_sharp` — the bound is attained: an explicit two-block family with
  ratios in `[1, 4]`, per-seed readings `1`, and pooled reading exactly
  `2√(1·4)/(1+4) = 4/5`.
* `kantorovich_beats_cycle_one` — the new constant strictly dominates the cycle-1 bound
  `(1-δ)/(1+δ)` on the symmetric window `[L(1-δ), L(1+δ)]` whenever `0 < δ < 1`, since
  `√(1-δ²) > (1-δ)/(1+δ)` there.

### 2. Same-weight ladders: a pooled rebound is a seed rebound

* `rebound_certifies_seed_rebound` — if two levels are pooled with the *same* seed weights
  and the pooled reading rises, then some individual seed reading rose.  A pooled rebound
  can therefore never be manufactured by pooling alone.
* `pooled_monotone_of_seedwise` — the converse direction: seedwise decline forces pooled
  decline, so the observed ladder is consistent with a genuinely seedwise fade.

### 3. The capacity expansion of a fading dial (answers Q2)

* `decorrelated_family_card_bound` — the `γ = 0` face of
  `Catalog.Algebra.ZeroFitDialU64MedianCapacity.correlated_family_capacity`:
  `k·ρ² ≤ 1` for `k` orthonormal statistics all reading at least `ρ`.
* `dial_capacity_at_5739` — at the top of the ladder (`0.5739`) at most **three** mutually
  decorrelated statistics can all read at the dial level.
* `u120_decorrelated_family_at_most_five` — at the U120 reading (`0.43636`) the bound is
  **five**, and `dial_capacity_expansion` records that the fade has strictly enlarged the
  admissible decorrelated family: the fade is a capacity expansion, not only a loss.

## Lab notes (exp 554 numbers entering the theorems)

```
pooled reading        : 0.43636      ladder top reading : 0.5739
seed spread           : 0.082        retrace step       : -0.0483
imbalance window used : [α, β] = [1, 4] in the sharpness example (κ = 4/5)
capacity bound ⌊1/ρ²⌋ : 3 at 0.5739, 5 at 0.43636
```
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU120Kantorovich

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU64MedianCapacity
open Catalog.Algebra.ZeroFitDialU120Floor

/-! ## 1. The sharp seed-imbalance law -/

variable {m n : ℕ}

/-- **Weighted Kantorovich inequality.**  For nonnegative weights and ratios confined to
`[α, β]` with `α > 0`, the weighted second moment is controlled by the square of the
weighted first moment with the sharp constant `4αβ/(α+β)²`. -/
theorem weighted_kantorovich {r : ℕ} {w lam : Fin r → ℝ} {alpha beta : ℝ}
    (halpha : 0 < alpha) (hab : alpha ≤ beta) (hw : ∀ k, 0 ≤ w k)
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta) :
    4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2))
      ≤ (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2 := by
  have hbeta : 0 < beta := lt_of_lt_of_le halpha hab
  have hpt : ∑ k, w k * lam k ^ 2
      ≤ (alpha + beta) * (∑ k, w k * lam k) - alpha * beta * (∑ k, w k) := by
    have hstep : ∑ k, w k * lam k ^ 2
        ≤ ∑ k, ((alpha + beta) * (w k * lam k) - alpha * beta * w k) := by
      refine Finset.sum_le_sum fun k _ => ?_
      have hsq : lam k ^ 2 ≤ (alpha + beta) * lam k - alpha * beta := by
        nlinarith [mul_nonneg (sub_nonneg.mpr (hlo k)) (sub_nonneg.mpr (hhi k))]
      nlinarith [hw k]
    calc ∑ k, w k * lam k ^ 2
        ≤ ∑ k, ((alpha + beta) * (w k * lam k) - alpha * beta * w k) := hstep
      _ = (alpha + beta) * (∑ k, w k * lam k) - alpha * beta * (∑ k, w k) := by
          rw [Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  have hS : 0 ≤ ∑ k, w k := Finset.sum_nonneg fun k _ => hw k
  have hprod : 0 ≤ 4 * (alpha * beta) * (∑ k, w k) := by positivity
  nlinarith [sq_nonneg ((alpha + beta) * (∑ k, w k * lam k)
      - 2 * (alpha * beta) * (∑ k, w k)), mul_le_mul_of_nonneg_left hpt hprod]

/-- **The sharp seed-imbalance law.**  If every per-seed reading is at least `ρ ≥ 0` and
the per-seed response/statistic norm ratios lie in `[α, β]` with `α > 0`, the pooled
reading is at least `ρ · 2√(αβ)/(α+β)`. -/
theorem pooled_kantorovich_bound {u v : Fin m → (Fin n → ℝ)} {lam : Fin m → ℝ}
    {alpha beta rho : ℝ} (halpha : 0 < alpha) (hab : alpha ≤ beta) (hrho : 0 ≤ rho)
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u)
    (hbal : ∀ k, nrm (v k) = lam k * nrm (u k))
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    (hcorr : ∀ k, rho ≤ corr (u k) (v k)) :
    rho * (2 * Real.sqrt (alpha * beta) / (alpha + beta)) ≤ pooledCorr u v := by
  have hbeta : 0 < beta := lt_of_lt_of_le halpha hab
  have hsum : 0 < alpha + beta := by linarith
  have hlampos : ∀ k, 0 < lam k := fun k => lt_of_lt_of_le halpha (hlo k)
  set A : ℝ := blockNormSq u with hA
  set M : ℝ := ∑ k, lam k * dot (u k) (u k) with hM
  -- the pooled numerator dominates `rho * M`
  have hnum : rho * M ≤ blockDot u v := by
    rw [hM, Finset.mul_sum, blockDot]
    refine Finset.sum_le_sum fun k _ => ?_
    have h := corr_mul_nrm (hu0 k) (hv0 k)
    have hdot : dot (u k) (v k) = corr (u k) (v k) * lam k * dot (u k) (u k) := by
      rw [← h, hbal k, ← nrm_sq (u k)]; ring
    rw [hdot]
    have hfac : rho * lam k ≤ corr (u k) (v k) * lam k :=
      mul_le_mul_of_nonneg_right (hcorr k) (hlampos k).le
    calc rho * (lam k * dot (u k) (u k)) = rho * lam k * dot (u k) (u k) := by ring
      _ ≤ corr (u k) (v k) * lam k * dot (u k) (u k) :=
        mul_le_mul_of_nonneg_right hfac (dot_self_nonneg _)
  -- the block energies of `v` are the second moments of the ratios
  have hBv : blockNormSq v = ∑ k, lam k ^ 2 * dot (u k) (u k) := by
    rw [blockNormSq]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [← nrm_sq (v k), ← nrm_sq (u k), hbal k]; ring
  have hMpos : 0 < M := by
    have hle : alpha * A ≤ M := by
      rw [hM, hA, blockNormSq, Finset.mul_sum]
      refine Finset.sum_le_sum fun k _ => ?_
      exact mul_le_mul_of_nonneg_right (hlo k) (dot_self_nonneg _)
    have hpos : 0 < alpha * A := mul_pos halpha hu
    linarith
  have hBvpos : 0 < blockNormSq v := by
    have hle : alpha ^ 2 * A ≤ blockNormSq v := by
      rw [hBv, hA, blockNormSq, Finset.mul_sum]
      refine Finset.sum_le_sum fun k _ => ?_
      have : alpha ^ 2 ≤ lam k ^ 2 := by nlinarith [hlo k]
      exact mul_le_mul_of_nonneg_right this (dot_self_nonneg _)
    have hpos : 0 < alpha ^ 2 * A := mul_pos (pow_pos halpha 2) hu
    linarith
  have hDpos : 0 < Real.sqrt A * Real.sqrt (blockNormSq v) :=
    mul_pos (Real.sqrt_pos.mpr hu) (Real.sqrt_pos.mpr hBvpos)
  -- Kantorovich applied with weights the block energies
  have hkant : 4 * (alpha * beta) * (A * blockNormSq v) ≤ ((alpha + beta) * M) ^ 2 := by
    have h := weighted_kantorovich (w := fun k => dot (u k) (u k)) (lam := lam)
      halpha hab (fun k => dot_self_nonneg _) hlo hhi
    have hM' : ∑ k, dot (u k) (u k) * lam k = M := by
      rw [hM]; exact Finset.sum_congr rfl fun k _ => mul_comm _ _
    have hBv' : ∑ k, dot (u k) (u k) * lam k ^ 2 = blockNormSq v := by
      rw [hBv]; exact Finset.sum_congr rfl fun k _ => mul_comm _ _
    rw [hM', hBv'] at h
    calc 4 * (alpha * beta) * (A * blockNormSq v)
        = 4 * (alpha * beta) * ((∑ k, dot (u k) (u k)) * blockNormSq v) := by
          rw [hA, blockNormSq]
      _ ≤ (alpha + beta) ^ 2 * M ^ 2 := h
      _ = ((alpha + beta) * M) ^ 2 := by ring
  -- turn it into a statement about the pooled denominator
  have hsqrtprod : Real.sqrt A * Real.sqrt (blockNormSq v) = Real.sqrt (A * blockNormSq v) :=
    (Real.sqrt_mul hu.le _).symm
  have hkey : 2 * Real.sqrt (alpha * beta) * (Real.sqrt A * Real.sqrt (blockNormSq v))
      ≤ (alpha + beta) * M := by
    have h1 : Real.sqrt (4 * (alpha * beta) * (A * blockNormSq v))
        = 2 * Real.sqrt (alpha * beta) * (Real.sqrt A * Real.sqrt (blockNormSq v)) := by
      rw [show (4:ℝ) * (alpha * beta) * (A * blockNormSq v)
            = (2:ℝ) ^ 2 * ((alpha * beta) * (A * blockNormSq v)) by ring,
        Real.sqrt_mul (by positivity), Real.sqrt_sq (by norm_num),
        Real.sqrt_mul (mul_pos halpha hbeta).le, Real.sqrt_mul hu.le]
      ring
    rw [← h1]
    have h2 : Real.sqrt (4 * (alpha * beta) * (A * blockNormSq v))
        ≤ Real.sqrt (((alpha + beta) * M) ^ 2) := Real.sqrt_le_sqrt hkant
    rwa [Real.sqrt_sq (by positivity)] at h2
  -- assemble
  have hstep1 : rho * (2 * Real.sqrt (alpha * beta) / (alpha + beta))
      ≤ rho * M / (Real.sqrt A * Real.sqrt (blockNormSq v)) := by
    have hratio : 2 * Real.sqrt (alpha * beta) / (alpha + beta)
        ≤ M / (Real.sqrt A * Real.sqrt (blockNormSq v)) := by
      rw [div_le_div_iff₀ hsum hDpos]
      calc 2 * Real.sqrt (alpha * beta) * (Real.sqrt A * Real.sqrt (blockNormSq v))
          ≤ (alpha + beta) * M := hkey
        _ = M * (alpha + beta) := by ring
    calc rho * (2 * Real.sqrt (alpha * beta) / (alpha + beta))
        ≤ rho * (M / (Real.sqrt A * Real.sqrt (blockNormSq v))) :=
          mul_le_mul_of_nonneg_left hratio hrho
      _ = rho * M / (Real.sqrt A * Real.sqrt (blockNormSq v)) := by ring
  have hstep2 : rho * M / (Real.sqrt A * Real.sqrt (blockNormSq v))
      ≤ blockDot u v / (Real.sqrt A * Real.sqrt (blockNormSq v)) := by
    gcongr
  rw [pooledCorr]
  exact le_trans hstep1 hstep2

/-- **Sharpness of the seed-imbalance law.**  A two-block family with ratios in `[1, 4]`
and both per-seed readings equal to `1` pools to exactly `2√(1·4)/(1+4) = 4/5`. -/
theorem kantorovich_pooling_sharp :
    ∃ (u v : Fin 2 → (Fin 1 → ℝ)) (lam : Fin 2 → ℝ),
      (∀ k, corr (u k) (v k) = 1) ∧ (∀ k, nrm (v k) = lam k * nrm (u k)) ∧
      (∀ k, 1 ≤ lam k ∧ lam k ≤ 4) ∧
      pooledCorr u v = 2 * Real.sqrt (1 * 4) / (1 + 4) := by
  have h4 : Real.sqrt 4 = 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  have h16 : Real.sqrt 16 = 4 := by
    rw [show (16 : ℝ) = 4 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  have h100 : Real.sqrt 100 = 10 := by
    rw [show (100 : ℝ) = 10 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  refine ⟨![fun _ => 2, fun _ => 1], ![fun _ => 2, fun _ => 4], ![1, 4], ?_, ?_, ?_, ?_⟩
  · intro k; fin_cases k <;> simp [corr, nrm, dot]
  · intro k; fin_cases k <;> simp [nrm, dot]
  · intro k; fin_cases k <;> norm_num
  · have hden : Real.sqrt (blockNormSq (![fun _ => 2, fun _ => 1] : Fin 2 → (Fin 1 → ℝ))) *
        Real.sqrt (blockNormSq (![fun _ => 2, fun _ => 4] : Fin 2 → (Fin 1 → ℝ)))
        = 10 := by
      rw [← Real.sqrt_mul (by norm_num [blockNormSq, dot, Fin.sum_univ_two])]
      norm_num [blockNormSq, dot, Fin.sum_univ_two, h100]
    rw [pooledCorr, hden]
    norm_num [blockDot, dot, Fin.sum_univ_two, h4]

/-- The Kantorovich constant strictly dominates the cycle-1 constant `(1-δ)/(1+δ)` on the
symmetric imbalance window `[L(1-δ), L(1+δ)]`. -/
theorem kantorovich_beats_cycle_one {L delta : ℝ} (hL : 0 < L) (hd0 : 0 < delta)
    (hd1 : delta < 1) :
    (1 - delta) / (1 + delta)
      < 2 * Real.sqrt (L * (1 - delta) * (L * (1 + delta))) / (L * (1 - delta) + L * (1 + delta)) := by
  have hpos : (0:ℝ) < 1 + delta := by linarith
  have hfac : L * (1 - delta) * (L * (1 + delta)) = (L * L) * (1 - delta ^ 2) := by ring
  have hden : L * (1 - delta) + L * (1 + delta) = 2 * L := by ring
  have hsqrt : Real.sqrt (L * (1 - delta) * (L * (1 + delta))) = L * Real.sqrt (1 - delta ^ 2) := by
    rw [hfac, Real.sqrt_mul (by positivity), show L * L = L ^ 2 by ring,
      Real.sqrt_sq hL.le]
  rw [hsqrt, hden]
  have hcancel : 2 * (L * Real.sqrt (1 - delta ^ 2)) / (2 * L) = Real.sqrt (1 - delta ^ 2) := by
    field_simp
  rw [hcancel]
  -- `(1-δ)/(1+δ) < √(1-δ²)` because the square of the left side is smaller
  have hlt : ((1 - delta) / (1 + delta)) ^ 2 < 1 - delta ^ 2 := by
    rw [div_pow, div_lt_iff₀ (by positivity)]
    have hid : (1 - delta ^ 2) * (1 + delta) ^ 2 - (1 - delta) ^ 2
        = (1 - delta) * ((1 + delta) ^ 3 - (1 - delta)) := by ring
    nlinarith [hid, mul_pos hd0 hd0, mul_pos (mul_pos hd0 hd0) hd0]
  have hnn : (0:ℝ) ≤ (1 - delta) / (1 + delta) :=
    div_nonneg (by linarith) (by linarith)
  nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 1 - delta ^ 2 by nlinarith),
    Real.sqrt_nonneg (1 - delta ^ 2)]

/-! ## 2. Same-weight ladders -/

/-- **A pooled rebound is a seed rebound.**  With the seed weights held fixed, a rise in
the pooled reading forces a rise in some individual seed reading. -/
theorem rebound_certifies_seed_rebound {r : ℕ} {w rho sigma : Fin r → ℝ}
    (hw : ∀ k, 0 ≤ w k)
    (hgap : ∑ k, w k * rho k < ∑ k, w k * sigma k) :
    ∃ k, rho k < sigma k := by
  by_contra hcon
  push_neg at hcon
  have : ∑ k, w k * sigma k ≤ ∑ k, w k * rho k :=
    Finset.sum_le_sum fun k _ => mul_le_mul_of_nonneg_left (hcon k) (hw k)
  linarith

/-- Conversely, a seedwise decline forces a pooled decline. -/
theorem pooled_monotone_of_seedwise {r : ℕ} {w rho sigma : Fin r → ℝ}
    (hw : ∀ k, 0 ≤ w k) (hmono : ∀ k, sigma k ≤ rho k) :
    ∑ k, w k * sigma k ≤ ∑ k, w k * rho k :=
  Finset.sum_le_sum fun k _ => mul_le_mul_of_nonneg_left (hmono k) (hw k)

/-! ## 3. The capacity expansion of a fading dial -/

variable {k : ℕ}

/-- The `γ = 0` face of the capacity law: `k` orthonormal statistics all reading at least
`ρ` against a unit response force `k·ρ² ≤ 1`. -/
theorem decorrelated_family_card_bound {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ} {rho : ℝ}
    (hu : IsGammaFamily u 0) (hw : dot w w = 1) (hrho : 0 ≤ rho) (hk : 1 ≤ k)
    (hread : ∀ i, rho ≤ dot (u i) w) :
    (k : ℝ) * rho ^ 2 ≤ 1 := by
  have h := correlated_family_capacity hu hw hrho hk hread
  simpa using h

/-- At the top of the recorded ladder (`0.5739`) at most three mutually decorrelated
statistics can all read at the dial level. -/
theorem dial_capacity_at_5739 {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    (hu : IsGammaFamily u 0) (hw : dot w w = 1) (hk : 1 ≤ k)
    (hread : ∀ i, (0.5739 : ℝ) ≤ dot (u i) w) :
    k ≤ 3 := by
  have h := decorrelated_family_card_bound hu hw (by norm_num) hk hread
  by_contra hcon
  push_neg at hcon
  have hkR : (4 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hcon
  nlinarith

/-- At the U120 reading (`0.43636`) the same bound allows five: the fade has enlarged the
admissible decorrelated family. -/
theorem u120_decorrelated_family_at_most_five {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    (hu : IsGammaFamily u 0) (hw : dot w w = 1) (hk : 1 ≤ k)
    (hread : ∀ i, (0.43636 : ℝ) ≤ dot (u i) w) :
    k ≤ 5 := by
  have h := decorrelated_family_card_bound hu hw (by norm_num) hk hread
  by_contra hcon
  push_neg at hcon
  have hkR : (6 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hcon
  nlinarith

/-- **Capacity expansion.**  A family of four decorrelated statistics reading at the U120
level is admissible by the capacity law, while at the ladder-top level it is not: the fade
strictly enlarges the decorrelated capacity. -/
theorem dial_capacity_expansion :
    (4 : ℝ) * (0.43636 : ℝ) ^ 2 ≤ 1 ∧ ¬ ((4 : ℝ) * (0.5739 : ℝ) ^ 2 ≤ 1) := by
  constructor
  · norm_num
  · norm_num

end Catalog.Algebra.ZeroFitDialU120Kantorovich