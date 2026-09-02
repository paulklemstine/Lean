import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52
import Pythagorean.ZeroFitDialBalanced60
import Pythagorean.ZeroFitDialWeightEnvelope60
import Pythagorean.ZeroFitDialBalancedClosure60

/-!
# The half-weight phase boundary of the zero-fit dial

## Research context (FACT round-51 #3, exp 521, `CELL-CLOSED-DIAL-HOLDS-60`)

`Pythagorean.ZeroFitDialBalancedClosure60` shows that the *balanced* fixed-weight law sits
strictly below the universal tie-attenuation constant `6/7` at every bitlen.  Exact-rational
sweeps over the whole two-parameter family of fixed-weight laws (weight `w = v+1`, bitlen
`b = v+1+r`) show something sharper: the sign of `ρ² - 6/7` is decided by the *weight
fraction alone*, and it flips exactly at half weight.

| `v` | `r = v` | `r = v+1` (balanced) | `r = v+2` |
|-----|---------|----------------------|-----------|
| 3 | 0.78922 | 0.84874 | 0.88630 |
| 5 | 0.81556 | 0.85195 | 0.87857 |
| 10 | 0.83622 | 0.85453 | 0.86995 |
| 20 | 0.84666 | 0.85583 | 0.86421 |

`6/7 = 0.857142…` separates the columns `r ≤ v+1` from the column `r ≥ v+2`.  In terms of
the draw law: `r ≤ v+1` is exactly `2w ≥ b`, weight at least half.

## Main results

* `dense_ceiling_lt` — for every `1 ≤ r ≤ v` (weight *strictly above* half) the ceiling is
  strictly below `6/7`.  The proof combines the accumulated-deficit invariant
  `loss_invariant` with the exact head-to-total ratio `n(v+1) = m₀(v+r+1)`: the surplus
  polynomial `N = 420DP² + 144P² - 294PD² + 49D³` (with `P = v+1`, `D = v-r+1`) is positive
  because `10P ≥ 7D`, and it dominates the linear terms as soon as `m₀ ≥ 3`.
* `half_weight_boundary` — **the phase boundary**: every fixed-weight law with weight at
  least half the bitlen has ceiling at most `6/7`, with equality exactly at the bitlen-4
  balanced law.  This unifies `dense_ceiling_lt` (above half) with
  `balanced_ceiling_lt_all` (exactly half).
* `boundary_is_sharp` — the boundary really is a boundary: at `v = 1, r = 3` (weight `2`,
  bitlen `5`, just below half) the ceiling is `10/11 > 6/7`.
* `sparse_ceiling_gt` — the far side: whenever the weight fraction drops to one third or
  below (`r ≥ 2v+2`) the ceiling is strictly *above* `6/7`.  Together with
  `half_weight_boundary` this traps the entire phase transition of the dial in the narrow
  window `1/3 < w/b < 1/2` of weight fractions.

## The scientific payload

`weight_ceiling_ge` (cycle 2) showed the *lower* guard — the ceiling never drops below
`0.73` in the band `θ ∈ [1/2, 3/5]`.  This file supplies the matching *upper* guard on the
whole dense half of the weight axis: `θ ≥ 1/2` forces `ρ² ≤ 6/7`.  So over every draw law
the deployment envelope actually validates against, the admissible reading band is pinned
between two universal constants, `0.73 < ρ² ≤ 6/7`, and the recorded `0.669` sits strictly
inside it.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialUnif52
open Catalog.Pythagorean.ZeroFitDialBalanced60
open Catalog.Pythagorean.ZeroFitDialWeightEnvelope60
open Catalog.Pythagorean.ZeroFitDialBalancedClosure60

namespace Catalog.Pythagorean.ZeroFitDialHalfWeightBoundary60

/-! ## 1. The head-to-total ratio -/

/-- The exact ratio between the total `n = C(v+1+r, v+1)` and the head `m₀ = C(v+r, v)` of a
fixed-weight profile: `n(v+1) = m₀(v+r+1)`. -/
lemma sum_head_ratio (v r : ℕ) :
    ((v + 1 + r).choose (v + 1)) * (v + 1) = ((v + r).choose v) * (v + r + 1) := by
  have h := Nat.add_one_mul_choose_eq (v + r) v
  have e : v + r + 1 = v + 1 + r := by omega
  rw [e] at h
  linarith

/-! ## 2. Pure algebra: the surplus polynomial -/

/-- Algebraic core of the dense-weight bound.  `P = v+1`, `D = v-r+1`, `M = m₀`, `S = n`,
`C = Σ mⱼ³`; the hypothesis `hinv` is the accumulated-deficit invariant and `hS` the exact
head-to-total ratio.  The conclusion `S³ + 6S < 7C` is exactly `ρ² < 6/7`. -/
lemma dense_algebra (P D M C S : ℚ) (hD : 1 ≤ D) (hDP : D ≤ P) (hPM : P ≤ M) (hM3 : 3 ≤ M)
    (hS : S * P = M * (2 * P - D))
    (hinv : 49 * P * (8 * M ^ 3) ≤ 49 * P * (7 * C + 1) + 24 * (1 + 7 * (D - 1)) * M ^ 3) :
    S ^ 3 + 6 * S < 7 * C := by
  have hP1 : (1 : ℚ) ≤ P := le_trans hD hDP
  have hP0 : (0 : ℚ) < P := by linarith
  have hM0 : (0 : ℚ) < M := by linarith
  -- the surplus polynomial is positive and at least `270 P²`
  have hN : 270 * P ^ 2 ≤ P ^ 2 * (392 * P - 168 * D + 144) - 49 * (2 * P - D) ^ 3 := by
    have hfac : 126 * D * P ^ 2 ≤ 420 * D * P ^ 2 - 294 * P * D ^ 2 := by
      nlinarith [mul_nonneg (mul_nonneg (by linarith : (0 : ℚ) ≤ 42 * D) (le_of_lt hP0))
        (by linarith : (0 : ℚ) ≤ 10 * P - 7 * D)]
    nlinarith [hfac, hD, hP0, pow_pos hP0 2, pow_pos (by linarith : (0 : ℚ) < D) 3]
  -- the cube of the head-to-total ratio
  have hS3 : S ^ 3 * P ^ 3 = M ^ 3 * (2 * P - D) ^ 3 := by
    have h3 : (S * P) ^ 3 = (M * (2 * P - D)) ^ 3 := by rw [hS]
    linear_combination h3
  -- the deficit invariant, scaled by `P²`
  have hinvP : (49 * P * (8 * M ^ 3)) * P ^ 2
      ≤ (49 * P * (7 * C + 1) + 24 * (1 + 7 * (D - 1)) * M ^ 3) * P ^ 2 :=
    mul_le_mul_of_nonneg_right hinv (by positivity)
  -- the dominance estimate
  have hdom : 294 * P ^ 2 * M * (2 * P - D) + 49 * P ^ 3
      < M ^ 3 * (P ^ 2 * (392 * P - 168 * D + 144) - 49 * (2 * P - D) ^ 3) := by
    have hup : 294 * P ^ 2 * M * (2 * P - D) + 49 * P ^ 3 ≤ 588 * P ^ 3 * M + 49 * P ^ 3 := by
      have hnn : (0 : ℚ) ≤ 294 * P ^ 2 * M * D :=
        mul_nonneg (mul_nonneg (by positivity) (le_of_lt hM0)) (by linarith)
      nlinarith [hnn]
    have hlow : 588 * P ^ 3 * M + 49 * P ^ 3 < 270 * P ^ 2 * M ^ 3 := by
      have hkey : 588 * P * M + 49 * P < 270 * M ^ 3 := by
        nlinarith [hPM, hM3, hP1, sq_nonneg (M - 3)]
      nlinarith [hkey, pow_pos hP0 2]
    nlinarith [hup, hlow, hN, pow_pos hM0 3]
  -- assemble
  have hP3 : (0 : ℚ) < 49 * P ^ 3 := by positivity
  have hgoal : (S ^ 3 + 6 * S) * (49 * P ^ 3) < (7 * C) * (49 * P ^ 3) := by
    have e1 : (S ^ 3 + 6 * S) * (49 * P ^ 3)
        = 49 * (S ^ 3 * P ^ 3) + 294 * P ^ 2 * (S * P) := by ring
    rw [e1, hS3, hS]
    nlinarith [hdom, hinvP]
  exact lt_of_mul_lt_mul_right hgoal (le_of_lt hP3)

/-! ## 3. Above half weight -/

/-- **Strictly above half weight.**  For `1 ≤ r ≤ v` — i.e. a fixed-weight draw law of
weight `v+1` on `v+1+r ≤ 2v+1` bits, so more than half the bits are set — the trailing-zero
Spearman ceiling is strictly below `6/7`.  The excluded corner `v = r = 1` (the two-bit
words of weight two on three bits) is handled separately in `half_weight_boundary`. -/
theorem dense_ceiling_lt (v r : ℕ) (h1 : 1 ≤ r) (hrv : r ≤ v) (hM3 : 3 ≤ (v + r).choose v) :
    spearmanSq (balancedBlocks v r) < 6 / 7 := by
  have hsum : (balancedBlocks v r).sum = (v + 1 + r).choose (v + 1) := balancedBlocks_sum v r
  have hsum2 : 2 ≤ (balancedBlocks v r).sum := by
    rw [hsum]
    have h := Nat.choose_le_choose (v + 1) (by omega : v + 1 + 1 ≤ v + 1 + r)
    have e : (v + 1 + 1).choose (v + 1) = v + 2 := by
      rw [Nat.choose_succ_self_right]
    omega
  have hSratio : (((v + 1 + r).choose (v + 1) : ℕ) : ℚ) * ((v : ℚ) + 1)
      = (((v + r).choose v : ℕ) : ℚ) * (2 * ((v : ℚ) + 1) - ((v : ℚ) - r + 1)) := by
    have hc := (Nat.cast_inj (R := ℚ)).2 (sum_head_ratio v r)
    push_cast at hc
    linear_combination hc
  have hinv := loss_invariant v r (by omega)
  have hinv' : 49 * ((v : ℚ) + 1) * (8 * (((v + r).choose v : ℕ) : ℚ) ^ 3)
      ≤ 49 * ((v : ℚ) + 1) * (7 * cubeSum (balancedBlocks v r) + 1)
        + 24 * (1 + 7 * (((v : ℚ) - r + 1) - 1)) * (((v + r).choose v : ℕ) : ℚ) ^ 3 := by
    have e : (1 : ℚ) + 7 * (((v : ℚ) - r + 1) - 1) = 1 + 7 * ((v : ℚ) - r) := by ring
    rw [e]
    exact hinv
  have hD : (1 : ℚ) ≤ (v : ℚ) - r + 1 := by
    have : (r : ℚ) ≤ (v : ℚ) := by exact_mod_cast hrv
    linarith
  have hDP : (v : ℚ) - r + 1 ≤ (v : ℚ) + 1 := by
    have : (0 : ℚ) ≤ (r : ℚ) := Nat.cast_nonneg r
    linarith
  have hPM : (v : ℚ) + 1 ≤ (((v + r).choose v : ℕ) : ℚ) := by
    have hnat : v + 1 ≤ (v + r).choose v := by
      have h := Nat.choose_le_choose v (by omega : v + 1 ≤ v + r)
      have e : (v + 1).choose v = v + 1 := by
        rw [Nat.choose_succ_self_right]
      omega
    have hc := (Nat.cast_le (α := ℚ)).2 hnat
    push_cast at hc
    linarith
  have hM3Q : (3 : ℚ) ≤ (((v + r).choose v : ℕ) : ℚ) := by exact_mod_cast hM3
  have hkey := dense_algebra ((v : ℚ) + 1) ((v : ℚ) - r + 1) (((v + r).choose v : ℕ) : ℚ)
    (cubeSum (balancedBlocks v r)) ((((v + 1 + r).choose (v + 1) : ℕ)) : ℚ)
    hD hDP hPM hM3Q hSratio hinv'
  rw [spearmanSq_lt_iff _ hsum2, hsum]
  push_cast at hkey
  linarith [hkey]

/-! ## 4. The boundary -/

/-- The one degenerate corner: weight `2` on `3` bits has profile `[2, 1]` and ceiling
`3/4`. -/
lemma ceiling_at_corner : spearmanSq (balancedBlocks 1 1) = 3 / 4 := by
  have h : balancedBlocks 1 1 = [2, 1] := by
    rw [balancedBlocks, balancedBlocks]
    norm_num
  rw [h, spearmanSq_eq _ (by norm_num)]
  norm_num [tieCorr]

/-- **The half-weight phase boundary.**  Every fixed-weight draw law whose weight is at
least half the bitlen has trailing-zero Spearman ceiling at most `6/7`, and the bound is
strict except at the balanced law of bitlen `4`.  In the parametrisation `weight = v+1`,
`bitlen = v+1+r`, "at least half" is `r ≤ v+1`. -/
theorem half_weight_boundary (v r : ℕ) (hv1 : 1 ≤ v) (h1 : 1 ≤ r) (hr : r ≤ v + 1) :
    spearmanSq (balancedBlocks v r) ≤ 6 / 7 := by
  rcases Nat.lt_or_ge r (v + 1) with hlt | hge
  · -- strictly above half weight
    have hrv : r ≤ v := by omega
    rcases Nat.lt_or_ge ((v + r).choose v) 3 with hsmall | hM3
    · -- the only small head is the corner `v = r = 1`
      have hv1 : v = 1 ∧ r = 1 := by
        by_contra hne
        have h2 : 2 ≤ v ∨ 2 ≤ r := by omega
        have : 3 ≤ (v + r).choose v := by
          rcases h2 with hv | hrr
          · have h := Nat.choose_le_choose v (by omega : v + 1 ≤ v + r)
            have e : (v + 1).choose v = v + 1 := by rw [Nat.choose_succ_self_right]
            omega
          · have h := Nat.choose_le_choose v (by omega : v + 2 ≤ v + r)
            have e : (v + 2).choose v = (v + 2) * (v + 1) / 2 := by
              have hs : (v + 2).choose v = (v + 2).choose 2 := by
                have := Nat.choose_symm (n := v + 2) (k := 2) (by omega)
                have e2 : v + 2 - 2 = v := by omega
                rw [e2] at this
                exact this
              have e5 : v + 2 - 1 = v + 1 := by omega
              rw [hs, Nat.choose_two_right, e5]
            have h3 : 3 ≤ (v + 2).choose v := by
              rw [e]
              have : 6 ≤ (v + 2) * (v + 1) := by nlinarith [Nat.zero_le v]
              omega
            omega
        omega
      obtain ⟨rfl, rfl⟩ := hv1
      rw [ceiling_at_corner]
      norm_num
    · exact le_of_lt (dense_ceiling_lt v r h1 hrv hM3)
  · -- exactly half weight: the balanced law
    have hre : r = v + 1 := by omega
    subst hre
    rcases Nat.lt_or_ge v 2 with hv | hv
    · -- `v = 1`: the bitlen-4 balanced law, where the ceiling equals `6/7`
      have hveq : v = 1 := by omega
      subst hveq
      have h : balancedBlocks 1 2 = centralProfile 1 := rfl
      rw [h, balanced_ceiling_eq_six_sevenths_at_bitlen_four]
    · have h : balancedBlocks v (v + 1) = centralProfile v := rfl
      rw [h]
      exact le_of_lt (balanced_ceiling_lt_all v hv)

/-- **The boundary is sharp.**  One step below half weight — weight `2` on bitlen `5`,
i.e. `v = 1`, `r = 3` — the ceiling is `10/11 > 6/7`.  So `half_weight_boundary` cannot be
extended to `r = v + 2`. -/
theorem boundary_is_sharp :
    6 / 7 < spearmanSq (balancedBlocks 1 3) ∧ spearmanSq (balancedBlocks 1 3) = 10 / 11 := by
  have h : balancedBlocks 1 3 = [4, 3, 2, 1] := by
    rw [balancedBlocks, balancedBlocks, balancedBlocks, balancedBlocks]
    norm_num
  rw [h, spearmanSq_eq _ (by norm_num)]
  norm_num [tieCorr]

/-- The bitlen-60 reading, placed inside the two universal guards.  Under every fixed-weight
law with weight fraction in `[1/2, 3/5]` the ceiling lies in `(0.73, 6/7]`, and the recorded
`0.669` — indeed the whole validation band `[0.55, 0.85]` — sits strictly below it. -/
theorem envelope_between_guards (v r : ℕ) (h1 : 1 ≤ r) (hrv : r ≤ v) (hdense : 2 * (v + 1) ≤ 3 * r)
    (rho : ℚ) (hlo : 55 / 100 ≤ rho) (hhi : rho ≤ 85 / 100) :
    rho ^ 2 < spearmanSq (balancedBlocks v r) ∧ spearmanSq (balancedBlocks v r) ≤ 6 / 7 := by
  have hlow := weight_ceiling_ge v r hrv hdense
  refine ⟨?_, half_weight_boundary v r (by omega) h1 (by omega)⟩
  nlinarith [hlow, hlo, hhi]

/-! ## 5. The sparse side: weight fraction at most one third -/

/-- Every block of a fixed-weight profile is bounded by its head, so the cube sum is at most
`m₀²·n`. -/
lemma cubeSum_le_head_sq_mul_sum (v r : ℕ) :
    cubeSum (balancedBlocks v r)
      ≤ (((v + r).choose v : ℕ) : ℚ) ^ 2 * (((balancedBlocks v r).sum : ℕ) : ℚ) := by
  induction r with
  | zero => simp [balancedBlocks, cubeSum]
  | succ r ih =>
      have hmono : ((v + r).choose v : ℕ) ≤ ((v + (r + 1)).choose v : ℕ) :=
        Nat.choose_le_choose v (by omega)
      have hmonoQ : (((v + r).choose v : ℕ) : ℚ) ≤ (((v + (r + 1)).choose v : ℕ) : ℚ) := by
        exact_mod_cast hmono
      have hnn : (0 : ℚ) ≤ (((v + r).choose v : ℕ) : ℚ) := by positivity
      have hsum : (0 : ℚ) ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) := by positivity
      have hsq : (((v + r).choose v : ℕ) : ℚ) ^ 2 * (((balancedBlocks v r).sum : ℕ) : ℚ)
          ≤ (((v + (r + 1)).choose v : ℕ) : ℚ) ^ 2 * (((balancedBlocks v r).sum : ℕ) : ℚ) :=
        mul_le_mul_of_nonneg_right (pow_le_pow_left₀ hnn hmonoQ 2) hsum
      rw [balancedBlocks, cubeSum_cons, List.sum_cons, Nat.cast_add]
      nlinarith [ih, hsq]

/-- **The sparse side.**  If the weight fraction is at most one third — weight `v+1` on
`v+1+r` bits with `r ≥ 2v+2` — then the trailing-zero ceiling is strictly *above* `6/7`.
Together with `half_weight_boundary` this confines the phase transition of the dial to the
narrow window `1/3 < w/b < 1/2` of weight fractions. -/
theorem sparse_ceiling_gt (v r : ℕ) (hr : 2 * v + 2 ≤ r) :
    6 / 7 < spearmanSq (balancedBlocks v r) := by
  have hsum : (balancedBlocks v r).sum = (v + 1 + r).choose (v + 1) := balancedBlocks_sum v r
  have hsum2 : 2 ≤ (balancedBlocks v r).sum := by
    rw [hsum]
    have h := Nat.choose_le_choose (v + 1) (by omega : v + 1 + 1 ≤ v + 1 + r)
    have e : (v + 1 + 1).choose (v + 1) = v + 2 := by rw [Nat.choose_succ_self_right]
    omega
  have hnQ : (2 : ℚ) ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) := by exact_mod_cast hsum2
  have hratio : (((balancedBlocks v r).sum : ℕ) : ℚ) * ((v : ℚ) + 1)
      = (((v + r).choose v : ℕ) : ℚ) * ((v : ℚ) + r + 1) := by
    rw [hsum]
    have hc := (Nat.cast_inj (R := ℚ)).2 (sum_head_ratio v r)
    push_cast at hc
    linear_combination hc
  have hM0 : (0 : ℚ) < (((v + r).choose v : ℕ) : ℚ) := by
    exact_mod_cast Nat.choose_pos (Nat.le_add_right v r)
  have hrQ : 2 * (v : ℚ) + 2 ≤ (r : ℚ) := by exact_mod_cast hr
  have hvQ : (0 : ℚ) ≤ (v : ℚ) := Nat.cast_nonneg v
  -- `n ≥ 3 m₀`, hence `n² > 7 m₀²`
  have hbig : 3 * (((v + r).choose v : ℕ) : ℚ) ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) := by
    have hP : (0 : ℚ) < (v : ℚ) + 1 := by linarith
    have h3 : 3 * ((v : ℚ) + 1) ≤ (v : ℚ) + r + 1 := by linarith
    nlinarith [hratio, hM0, hP, h3]
  have hcube := cubeSum_le_head_sq_mul_sum v r
  have hc2 : cubeSum (balancedBlocks v r) ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) ^ 3 / 9 := by
    have h9 : 9 * (((v + r).choose v : ℕ) : ℚ) ^ 2 ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) ^ 2 := by
      nlinarith [hbig, hM0]
    have h10 : (9 * (((v + r).choose v : ℕ) : ℚ) ^ 2) * (((balancedBlocks v r).sum : ℕ) : ℚ)
        ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) ^ 2 * (((balancedBlocks v r).sum : ℕ) : ℚ) :=
      mul_le_mul_of_nonneg_right h9 (by linarith)
    linarith [hcube, h10]
  have hn3 : (0 : ℚ) ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) ^ 3 := by positivity
  rw [lt_spearmanSq_iff _ hsum2]
  linarith [hc2, hnQ, hn3]

/-!
## Lab Notes (cycles 4–5)

Exact ceilings `ρ²(balancedBlocks v r)` across the weight axis (weight `w = v+1`, bitlen
`b = v+1+r`, weight fraction `θ = w/b`).  The column `r = v+1` is the balanced law
(`θ = 1/2`); `−` marks `ρ² < 6/7` and `+` marks `ρ² > 6/7`.

| `v` | `r=1` | `r=2` | `r=v` | `r=v+1` | `r=v+2` | `r=2v` | `r=10v` |
|-----|-------|-------|-------|---------|---------|--------|---------|
| 1 | 0.75 − | 6/7 = | 0.75 − | 6/7 = | 0.90909 + | 6/7 = | 0.98507 + |
| 2 | 0.6 − | 0.76364 − | 0.76364 − | 0.84662 − | 0.89300 + | 0.89300 + | 0.99203 + |
| 3 | 0.5 − | 0.6875 − | 0.78922 − | 0.84874 − | 0.88630 + | 0.91145 + | 0.99394 + |
| 5 | 0.375 − | 0.56897 − | 0.81556 − | 0.85195 − | 0.87857 + | 0.92629 + | 0.99528 + |
| 10 | 0.23077 − | 0.39143 − | 0.83622 − | 0.85453 − | 0.86995 + | 0.93705 + | 0.99618 + |
| 20 | 0.13043 − | 0.23827 − | 0.84666 − | 0.85583 − | 0.86421 + | 0.94227 + | 0.99659 + |

Every `−` in the columns `r ≤ v+1` is a instance of `half_weight_boundary`; the first `+`
always appears at `r = v+2`, i.e. as soon as the weight drops below half, and
`boundary_is_sharp` formalises the smallest such case (`v = 1`, `r = 3`, ceiling `10/11`).

Surplus polynomial driving `dense_ceiling_lt`, with `P = v+1`, `D = v-r+1`:

```
N(P, D) = 420 D P² + 144 P² − 294 P D² + 49 D³ ≥ 126 D P² + 144 P² ≥ 270 P²   (1 ≤ D ≤ P)
```

so the head cube `m₀³ N` beats the linear terms `294 P²m₀(2P−D) + 49P³` as soon as
`m₀ ≥ 3`; the single profile with `m₀ < 3` in range is `[2, 1]` (`ceiling_at_corner`,
`ρ² = 3/4`).

On the sparse side the estimate is far cruder and still sufficient: every block is at most
the head, so `Σmⱼ³ ≤ m₀²n`, and the exact head-to-total ratio gives `n ≥ 3m₀` as soon as
`r ≥ 2v+2`, whence `Σmⱼ³ ≤ n³/9 < (n³ + 6n)/7`.  The remaining undecided window is
`1/3 < w/b < 1/2`, where the sweep in `ComputationalEvidence.md` shows the flip happens at
the single lattice step `r = v+1 → r = v+2`.
-/

end Catalog.Pythagorean.ZeroFitDialHalfWeightBoundary60