import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52
import Pythagorean.ZeroFitDialBalanced60

/-!
# The weight envelope of the zero-fit dial: imbalance robustness and the collapse of the
count baseline

## Research context (FACT round-51 #3, exp 521, `CELL-CLOSED-DIAL-HOLDS-60`)

`Pythagorean.ZeroFitDialBalanced60` establishes the *balanced* half of the bitlen-60
deployment envelope: the trailing-zero statistic `T` has a hockey-stick tie profile under a
balanced draw, and its Spearman ceiling brackets `6/7` from below while the uniform ceiling
brackets it from above.  This file pushes that analysis in three directions, all of which
were left open by the first cycle.

## Main results

* `balanced_ceiling_gt_sharp` — a **fifteen-fold sharpening** of the convergence rate:
  the balanced ceiling at bitlen `2v+2` exceeds `6/7 - 1/(15(v+1))`.  The true deficit is
  `≈ 0.0263/v`, so the constant `1/15 = 0.0667` is within a factor `2.5` of optimal, and
  the sharpened bound pins the two draw laws to within `1/(15(v+1)) + 4^{-b}` of each
  other (`draw_law_gap_sharp`).
* `weight_ceiling_ge` — **imbalance robustness**.  The balanced law is only one point of a
  one-parameter family of fixed-weight draw laws.  For *every* weight fraction
  `θ = w/b ∈ [1/2, 3/5]` the trailing-zero ceiling stays above `0.73`; the entire
  validation band `[0.55, 0.85]` therefore remains admissible under a draw law that is
  mis-balanced by up to ten percentage points (`weight_envelope_60`).
* `count_dial_collapse` — **the structural reason the dial beats count on balanced
  draws**.  Under a fixed-weight law the popcount statistic is *constant*: its tie profile
  is the single block `[C(b,w)]`, so its Spearman ceiling is exactly `0`.  The recorded
  advantage of `T` over the count baseline is therefore not merely unexplained by tie
  geometry (as `advantage_not_headroom_artefact` shows for uniform draws at bitlen 60) —
  on the balanced half of the envelope it is *forced*: the count baseline is
  informationless while `T` retains a ceiling of `≈ 6/7`.
* `dial_beats_count_on_balanced` — the two statements combined at bitlen 60.

## The scientific payload

The envelope claim "balanced *and* uniform draws through bitlen 60" is now supported by a
continuum, not by two isolated points: `weight_ceiling_ge` covers every draw law with
weight fraction between `1/2` and `3/5`, and `count_dial_collapse` explains why the
`T`-versus-count comparison degenerates in `T`'s favour as soon as the draw law fixes the
popcount.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialUnif52
open Catalog.Pythagorean.ZeroFitDialBalanced60

namespace Catalog.Pythagorean.ZeroFitDialWeightEnvelope60

/-! ## 1. A sharper convergence rate for the balanced ceiling -/

/-- Pure-algebra core of the sharpened lower bound. -/
lemma ceiling_gt_sharp_algebra (V x y : ℚ) (hV : 1 ≤ V) (hx : 1 ≤ x)
    (hr : (V + 1) * x = (2 * V + 1) * y) :
    x ^ 3 + (8 / 7) * y ^ 3 - 2 * x
      < ((2 * x) ^ 3 - 2 * x) * (1 - (6 / 7 - 1 / (15 * (V + 1)))) := by
  have hV0 : (0 : ℚ) ≤ V := by linarith
  have hVp : (0 : ℚ) < V + 1 := by linarith
  have h2V : (0 : ℚ) < 2 * V + 1 := by linarith
  have hx3 : (1 : ℚ) ≤ x ^ 3 := by nlinarith [sq_nonneg x, sq_nonneg (x - 1)]
  have hxle : x ≤ x ^ 3 := by
    nlinarith [mul_nonneg (mul_nonneg (by linarith : (0:ℚ) ≤ x) (by linarith : (0:ℚ) ≤ x - 1))
      (by linarith : (0:ℚ) ≤ x + 1)]
  have hy3 : (2 * V + 1) ^ 3 * y ^ 3 = (V + 1) ^ 3 * x ^ 3 := by
    have h := congrArg (fun t : ℚ => t ^ 3) hr
    simp only at h
    nlinarith [h]
  -- `40 (V+1)⁴ < (5V + 19)(2V+1)³` for `V ≥ 1`: this is the exact place where the
  -- constant `1/15` is decided.
  have hquart : 40 * (V + 1) ^ 4 < (5 * V + 19) * (2 * V + 1) ^ 3 := by
    nlinarith [sq_nonneg V, sq_nonneg (V - 1), pow_nonneg hV0 3, pow_nonneg hV0 4,
      mul_nonneg (mul_nonneg hV0 hV0) hV0]
  have hxx : (0 : ℚ) < x ^ 3 := by linarith
  have hstep : (8 / 7) * y ^ 3 * ((V + 1) * (2 * V + 1) ^ 3)
      < ((1 / 7) * x ^ 3 + (2 / 5) * x ^ 3 / (V + 1)) * ((V + 1) * (2 * V + 1) ^ 3) := by
    have e1 : (8 / 7) * y ^ 3 * ((V + 1) * (2 * V + 1) ^ 3) = (8 / 7) * (V + 1) ^ 4 * x ^ 3 := by
      have h1 : y ^ 3 * (2 * V + 1) ^ 3 = (V + 1) ^ 3 * x ^ 3 := by linarith [hy3]
      nlinarith [h1]
    have e2 : ((1 / 7) * x ^ 3 + (2 / 5) * x ^ 3 / (V + 1)) * ((V + 1) * (2 * V + 1) ^ 3)
        = ((1 / 7) * (V + 1) + 2 / 5) * (2 * V + 1) ^ 3 * x ^ 3 := by field_simp
    rw [e1, e2]
    nlinarith [hquart, hxx]
  have hpos : (0 : ℚ) < (V + 1) * (2 * V + 1) ^ 3 := by positivity
  have hstep' : (8 / 7) * y ^ 3 < (1 / 7) * x ^ 3 + (2 / 5) * x ^ 3 / (V + 1) :=
    lt_of_mul_lt_mul_right (by linarith [hstep]) (le_of_lt hpos)
  have hlast : (2 / 5) * x ^ 3 / (V + 1) ≤ (8 * x ^ 3 - 2 * x) / (15 * (V + 1)) := by
    rw [div_le_div_iff₀ hVp (by linarith)]
    nlinarith
  have expand : ((2 * x) ^ 3 - 2 * x) * (1 - (6 / 7 - 1 / (15 * (V + 1))))
      = (1 / 7) * (8 * x ^ 3 - 2 * x) + (8 * x ^ 3 - 2 * x) / (15 * (V + 1)) := by
    field_simp; ring
  rw [expand]
  linarith [hstep', hlast]

/-- **Sharpened balanced ceiling.**  At bitlen `2v+2` the balanced tie ceiling exceeds
`6/7 - 1/(15(v+1))`, a fifteen-fold improvement on
`ZeroFitDialBalanced60.balanced_ceiling_gt`.  (The exact deficit decays like `0.0263/v`,
so this constant is within a factor `2.5` of optimal.) -/
theorem balanced_ceiling_gt_sharp (v : ℕ) (hv : 1 ≤ v) :
    6 / 7 - 1 / (15 * ((v : ℚ) + 1)) < spearmanSq (centralProfile v) := by
  have hsum : (centralProfile v).sum = 2 * ((2 * v + 1).choose v) := by
    rw [centralProfile_sum, sum_eq_two_mul_head]
  set x : ℚ := (((2 * v + 1).choose v : ℕ) : ℚ) with hx
  set y : ℚ := (((2 * v).choose v : ℕ) : ℚ) with hy
  have hx1 : (1 : ℚ) ≤ x := by
    rw [hx]
    exact_mod_cast Nat.choose_pos (n := 2 * v + 1) (k := v) (by omega)
  have hsumQ : (((centralProfile v).sum : ℕ) : ℚ) = 2 * x := by rw [hsum]; push_cast; ring
  have hcube : cubeSum (centralProfile v) ≤ x ^ 3 + (8 / 7) * y ^ 3 := by
    have hunfold : centralProfile v = (v + (v + 1)).choose v :: balancedBlocks v v := by
      rw [centralProfile, balancedBlocks]
    have htail := cubeSum_balanced_le v v (le_refl v)
    have e2 : v + v = 2 * v := by omega
    rw [e2] at htail
    have e1 : v + (v + 1) = 2 * v + 1 := by omega
    rw [hunfold, cubeSum_cons, e1]
    linarith
  have hratio : ((v : ℚ) + 1) * x = (2 * (v : ℚ) + 1) * y := by
    have h := head_ratio v
    have hc := (Nat.cast_inj (R := ℚ)).2 h
    push_cast at hc
    rw [hx, hy]
    linarith [hc]
  have hv1 : (1 : ℚ) ≤ (v : ℚ) := by exact_mod_cast hv
  rw [lt_spearmanSq_iff _ (centralProfile_sum_ge v), hsumQ]
  have halg := ceiling_gt_sharp_algebra (v : ℚ) x y hv1 hx1 hratio
  linarith [hcube, halg]

/-- With the sharpened rate, the two draw laws at bitlen `2v+2` are pinned to within
`1/(15(v+1)) + 4^{-(2v+2)}` of each other. -/
theorem draw_law_gap_sharp (v : ℕ) (h2 : 2 ≤ v) (h94 : v ≤ 94) :
    spearmanSq (dyadicBlocks (2 * v + 2)) - spearmanSq (centralProfile v)
      < 1 / (15 * ((v : ℚ) + 1)) + (1 / 4 : ℚ) ^ (2 * v + 2) := by
  have hlow := balanced_ceiling_gt_sharp v (by omega)
  have hup := dyadic_ceiling_close (2 * v + 2) (by omega)
  linarith

/-! ## 2. Imbalance robustness: the whole fixed-weight family -/

/-- Number of fixed-weight words: `balancedBlocks v r` is the trailing-zero profile of the
words of bitlen `b = v + 1 + r` with weight `w = v + 1`, and it sums to `C(b, w)`. -/
lemma weight_sum (v r : ℕ) : (balancedBlocks v r).sum = (v + 1 + r).choose (v + 1) :=
  balancedBlocks_sum v r

/-- Every block of the profile is nonempty, so the sample size is at least `r + 1`. -/
lemma weight_sum_ge (v r : ℕ) : r + 1 ≤ (balancedBlocks v r).sum := by
  induction r with
  | zero => simp [balancedBlocks]
  | succ r ih =>
      rw [balancedBlocks, List.sum_cons]
      have hpos : 1 ≤ (v + (r + 1)).choose v := Nat.choose_pos (by omega)
      omega

/-- **Weight-fraction identity.**  `w · C(b,w) = b · C(b-1, w-1)`: the top block is the
`w/b` fraction of the sample. -/
lemma weight_head_ratio (v r : ℕ) :
    (v + 1) * ((v + 1 + r).choose (v + 1)) = (v + 1 + r) * ((v + r).choose v) := by
  have h := Nat.add_one_mul_choose_eq (v + r) v
  have e : v + r + 1 = v + 1 + r := by omega
  rw [e] at h
  linarith [h]

/-- **Imbalance robustness.**  For every fixed-weight draw law whose weight fraction
`θ = w/b` lies in `[1/2, 3/5]` — the hypotheses `r ≤ v` and `2(v+1) ≤ 3r` say exactly
`1/2 ≤ θ ≤ 3/5` — the trailing-zero tie ceiling stays above `0.73`.  The dial's tie
geometry therefore survives a weight imbalance of up to ten percentage points. -/
theorem weight_ceiling_ge (v r : ℕ) (hr : r ≤ v) (hdense : 2 * (v + 1) ≤ 3 * r) :
    73 / 100 < spearmanSq (balancedBlocks v r) := by
  have hr1 : 1 ≤ r := by omega
  have hn2 : 2 ≤ (balancedBlocks v r).sum := by
    have := weight_sum_ge v r; omega
  set n : ℚ := (((balancedBlocks v r).sum : ℕ) : ℚ) with hn
  set m : ℚ := (((v + r).choose v : ℕ) : ℚ) with hm
  have hn2Q : (2 : ℚ) ≤ n := by rw [hn]; exact_mod_cast hn2
  have hm0 : (0 : ℚ) ≤ m := by positivity
  -- the top block is at most `3/5` of the sample
  have hratio : ((v : ℚ) + 1) * n = ((v : ℚ) + 1 + r) * m := by
    have h := weight_head_ratio v r
    have hs : (balancedBlocks v r).sum = (v + 1 + r).choose (v + 1) := weight_sum v r
    rw [hn, hm, hs]
    have hc := (Nat.cast_inj (R := ℚ)).2 h
    push_cast at hc
    linarith [hc]
  have hdenseQ : 5 * ((v : ℚ) + 1) ≤ 3 * ((v : ℚ) + 1 + r) := by
    have : (2 : ℚ) * ((v : ℚ) + 1) ≤ 3 * (r : ℚ) := by exact_mod_cast hdense
    linarith
  have hbpos : (0 : ℚ) < (v : ℚ) + 1 + r := by positivity
  have h35 : 5 * m ≤ 3 * n := by
    have h1 : 5 * (((v : ℚ) + 1 + r) * m) = 5 * (((v : ℚ) + 1) * n) := by rw [hratio]
    have h2 : 5 * ((v : ℚ) + 1) * n ≤ 3 * ((v : ℚ) + 1 + r) * n := by nlinarith
    nlinarith [h1, h2]
  -- geometric bound on the cube sum
  have hcube : cubeSum (balancedBlocks v r) ≤ (8 / 7) * m ^ 3 := cubeSum_balanced_le v r hr
  have hA : cubeSum (balancedBlocks v r) ≤ (216 / 875) * n ^ 3 := by
    have hcubes : (5 * m) ^ 3 ≤ (3 * n) ^ 3 :=
      pow_le_pow_left₀ (by linarith) h35 3
    have hm3 : m ^ 3 ≤ (27 / 125) * n ^ 3 := by nlinarith [hcubes]
    linarith
  rw [lt_spearmanSq_iff _ hn2, ← hn]
  have hcubepos : (0 : ℚ) < n ^ 3 - n := cube_sub_self_pos hn2Q
  have h1 : (216 / 875 : ℚ) * n ^ 3 - n ≤ (216 / 875) * (n ^ 3 - n) := by linarith
  have h2 : (216 / 875 : ℚ) * (n ^ 3 - n) < (27 / 100) * (n ^ 3 - n) := by linarith
  linarith

/-- **Weight envelope at bitlen 60.**  A `55 %`-ones draw at bitlen 60 (weight 33) still
admits the whole validation band `[0.55, 0.85]`: its trailing-zero ceiling exceeds
`0.73 > 0.85²`. -/
theorem weight_envelope_60 (rho : ℚ) (hlo : 55 / 100 ≤ rho) (hhi : rho ≤ 85 / 100) :
    rho ^ 2 < spearmanSq (balancedBlocks 32 27) := by
  have h := weight_ceiling_ge 32 27 (by norm_num) (by norm_num)
  have hsq : rho ^ 2 ≤ (85 / 100 : ℚ) ^ 2 := by nlinarith
  have : (85 / 100 : ℚ) ^ 2 < 73 / 100 := by norm_num
  linarith

/-! ## 3. Collapse of the count baseline under a fixed-weight law -/

/-- Every balanced word has the prescribed weight: the popcount statistic is constant. -/
lemma balancedWords_constant_weight (b w : ℕ) (S : Finset ℕ) (hS : S ∈ balancedWords b w) :
    S.card = w := (Finset.mem_powersetCard.1 hS).2

/-- The number of fixed-weight words. -/
lemma card_balancedWords (b w : ℕ) : (balancedWords b w).card = b.choose w := by
  rw [balancedWords, Finset.card_powersetCard, Finset.card_range]

/-- A statistic with a single tie block has Spearman ceiling exactly `0`. -/
theorem spearmanSq_singleton (m : ℕ) : spearmanSq [m] = 0 := by
  simp [spearmanSq, ssR, gmean]

/-- **Collapse of the count baseline.**  Under a fixed-weight draw law the popcount
statistic takes a single value, so its tie profile is the one-block profile
`[C(b,w)]` and its Spearman ceiling is exactly `0` — the count baseline carries no
information at all, while the trailing-zero dial keeps a ceiling of nearly `6/7`. -/
theorem count_dial_collapse (b w : ℕ) :
    (∀ S ∈ balancedWords b w, S.card = w) ∧
    spearmanSq [(balancedWords b w).card] = 0 ∧ (balancedWords b w).card = b.choose w :=
  ⟨fun S hS => balancedWords_constant_weight b w S hS,
   spearmanSq_singleton _, card_balancedWords b w⟩

/-- **The advantage is structural on the balanced half of the envelope.**  At bitlen 60,
under the balanced draw law the count baseline's ceiling is `0` while the trailing-zero
dial's ceiling exceeds `0.85` — the recorded positive advantage of `T` over count is
forced by the geometry of the draw law, not merely unexplained by it. -/
theorem dial_beats_count_on_balanced :
    spearmanSq [(balancedWords 60 30).card] = 0 ∧
    (85 / 100 : ℚ) < spearmanSq (centralProfile 29) ∧
    spearmanSq (centralProfile 29) < 6 / 7 := by
  have hlow := balanced_ceiling_gt_sharp 29 (by norm_num)
  have hup := balanced_ceiling_lt 29 (by norm_num) (by norm_num)
  refine ⟨spearmanSq_singleton _, ?_, hup⟩
  have hnum : (85 / 100 : ℚ) < 6 / 7 - 1 / (15 * ((29 : ℚ) + 1)) := by norm_num
  push_cast at hlow
  linarith

/-!
## Lab notes (cycle 2, exp 521 continued)

Exact-rational cross-checks of the two new bounds (exact `ℚ`):

| `v` | balanced ceiling | `6/7 - 1/(15(v+1))` | `6/7 - 1/(v+1)` |
|---|---|---|---|
| 2  | `0.8466165…` | `0.8349206…` | `0.5238095…` |
| 10 | `0.8545280…` | `0.8510822…` | `0.7662337…` |
| 29 | `0.8562388…` | `0.8549206…` | `0.8238095…` |
| 94 | `0.8568637…` | `0.8564411…` | `0.8466217…` |

Deficit `6/7 - ρ²` fitted over `v ∈ [10, 1000]`: `0.0263/v`, so the sharpened constant
`1/15 = 0.0667` is within a factor `2.54` of the truth and the cruder constant `1` is
`38×` loose.

Fixed-weight sweep (`θ = w/b` between `1/2` and `3/5`, all `v ≤ 60`): the minimum ceiling
observed is `0.7636…` at `(v, r) = (2, 2)`, i.e. bitlen 5 with weight 3 — comfortably
above the proved bound `0.73` and above `0.85² = 0.7225`, which is what
`weight_envelope_60` needs.
-/

end Catalog.Pythagorean.ZeroFitDialWeightEnvelope60