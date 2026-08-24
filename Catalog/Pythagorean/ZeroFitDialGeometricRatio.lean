import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialRelationRate48
import Pythagorean.ZeroFitDialResolutionLadder48

/-!
# The geometric-ratio ceiling law: where the constant `7/2` comes from

## Research context (FACT round-56 #1, exp 526, `CELL-CLOSED-DIAL-HOLDS-UNIF-48`)

`Pythagorean.ZeroFitDialRelationRate48` computes the coarse (relation-rate) ceiling of the
zero-fit dial on the 2-adic tie profile of uniform draws at exact bitlen 48 and finds the
rate parabola `ρ²_max(p) = (7/2)·p(1-p)·n³/(n³-1)`.  Nothing in that derivation is visibly
2-adic, which raises the obvious question: **is `7/2` an arithmetic constant or a shape
constant?**

This file answers it.  The tie profile of the trailing-`(q-1)`-digit statistic in base `q`
is the geometric profile with ratio `1/q`, and the whole computation goes through with

```
ssR = q·(n³ - 1) / (4(q² + q + 1)) ,        ρ²_max(p) = ((q² + q + 1)/q)·p(1-p)·n³/(n³-1) .
```

At `q = 2` this is `ssR = (n³-1)/14` and the constant `7/2`, recovering the recorded cell
exactly.  So `7/2` is a *shape* constant: it measures the geometric ratio of the tie
spectrum, not the prime 2.  Since `C(q) = q + 1 + 1/q` is strictly increasing, coarser
digit bases make the dial *easier* to saturate, and the dyadic regime of the recorded
experiment is the hardest of the whole family.

## Main results

* `geomBlocks`, `geomBlocks_sum`, `geomBlocks_zero` — the ratio-`1/q` tie profile
  (`q = s + 2`), summing to `q^b`, and agreeing with `dyadicBlocks` at `q = 2`.
* `ssR_geom` — **the geometric-ratio sum of squares**, by induction with the
  parallel-axis identity: the cross terms telescope to `q^{3b}·q(q-1)/4` per level.
* `geom_binary_ceiling` — the ceiling `((q²+q+1)/q)·p(1-p)·n³/(n³-1)` at relation rate `p`.
* `geom_constant_strict_mono` — `C(q) = (q²+q+1)/q` is strictly increasing in `q`.
* `ssR_geom_recovers_dyadic` — the recorded dyadic cell is the `q = 2` member of the family.
* `dyadic_is_hardest_regime` — at every relation rate the dyadic ceiling is the smallest in
  the family, so the exclusions proved for the recorded cell are the strongest possible
  among geometric tie spectra.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialRelationRate48
open Catalog.Pythagorean.ZeroFitDialResolutionLadder48

namespace Catalog.Pythagorean.ZeroFitDialGeometricRatio

/-! ## 1. The ratio-`1/q` tie profile -/

/-- Tie profile of the trailing-digit statistic in base `q = s + 2` on `{0, …, q^b - 1}`:
blocks of sizes `(q-1)q^{b-1}, …, (q-1)q, (q-1)` followed by the singleton `{0}`.
At `s = 0` this is the 2-adic profile of the recorded experiment. -/
def geomBlocks (s : ℕ) : ℕ → List ℕ
  | 0 => [1]
  | b + 1 => (s + 1) * (s + 2) ^ b :: geomBlocks s b

lemma geomBlocks_sum (s b : ℕ) : (geomBlocks s b).sum = (s + 2) ^ b := by
  induction b with
  | zero => simp [geomBlocks]
  | succ b ih =>
      rw [geomBlocks, List.sum_cons, ih, pow_succ]
      ring

/-- At `q = 2` the geometric profile is exactly the 2-adic profile of the recorded cell. -/
lemma geomBlocks_zero (b : ℕ) : geomBlocks 0 b = dyadicBlocks b := by
  induction b with
  | zero => rfl
  | succ b ih => rw [geomBlocks, dyadicBlocks, ih]; norm_num

lemma geomBlocks_sum_cast (s b : ℕ) :
    (((geomBlocks s b).sum : ℕ) : ℚ) = ((s : ℚ) + 2) ^ b := by
  rw [geomBlocks_sum]; push_cast; ring

lemma gmean_geomBlocks (s b : ℕ) :
    gmean (geomBlocks s b) = (((s : ℚ) + 2) ^ b + 1) / 2 := by
  rw [gmean, geomBlocks_sum_cast]

/-! ## 2. The geometric-ratio sum of squares -/

/-- **The between-block sum of squares of a ratio-`1/q` tie spectrum.**  With `q = s+2` and
`n = q^b`, `ssR = q(n³ - 1)/(4(q² + q + 1))`.  Each level contributes `q^{3k}·q(q-1)/4`: the
parallel-axis cross term of the new block cancels against the recentring of the old ones. -/
theorem ssR_geom (s b : ℕ) :
    ssR (gmean (geomBlocks s b)) (geomBlocks s b) 0
      = ((s : ℚ) + 2) * (((((s : ℚ) + 2) ^ b) ^ 3) - 1)
          / (4 * (((s : ℚ) + 2) ^ 2 + ((s : ℚ) + 2) + 1)) := by
  set Q : ℚ := (s : ℚ) + 2 with hQ
  have hQ2 : (2 : ℚ) ≤ Q := by
    rw [hQ]; have : (0 : ℚ) ≤ (s : ℚ) := by positivity
    linarith
  have hden : (0 : ℚ) < 4 * (Q ^ 2 + Q + 1) := by nlinarith
  induction b with
  | zero => simp [geomBlocks, gmean, ssR]
  | succ b ih =>
      have hMcast : (((s + 1) * (s + 2) ^ b : ℕ) : ℚ) = (Q - 1) * Q ^ b := by
        rw [hQ]; push_cast; ring
      have hgm : gmean (geomBlocks s (b + 1)) = (Q ^ (b + 1) + 1) / 2 := by
        rw [gmean_geomBlocks]
      have hgm' : gmean (geomBlocks s b) = (Q ^ b + 1) / 2 := by
        rw [gmean_geomBlocks]
      have hsum' : (((geomBlocks s b).sum : ℕ) : ℚ) = Q ^ b := geomBlocks_sum_cast s b
      have hshift := ssR_shift_parallel (gmean (geomBlocks s (b + 1))) (geomBlocks s b)
        (0 + (((s + 1) * (s + 2) ^ b : ℕ) : ℚ))
      nth_rewrite 2 [geomBlocks]
      rw [ssR, hshift, ih, hgm, hgm', hsum', hMcast, pow_succ]
      field_simp
      ring

/-! ## 3. The ceiling law and its monotonicity -/

/-- **The geometric-ratio ceiling.**  For a two-valued response at relation rate `p` on a
ratio-`1/q` tie spectrum with `n = q^b`, the coarse ceiling is
`((q² + q + 1)/q)·p(1-p)·n³/(n³ - 1)`. -/
theorem geom_binary_ceiling (s b : ℕ) (hb : 1 ≤ b) (p : ℚ) :
    (((s : ℚ) + 2) ^ b) * (p * (((s : ℚ) + 2) ^ b)) * ((((s : ℚ) + 2) ^ b) - p * (((s : ℚ) + 2) ^ b))
        / (4 * ssR (gmean (geomBlocks s b)) (geomBlocks s b) 0)
      = ((((s : ℚ) + 2) ^ 2 + ((s : ℚ) + 2) + 1) / ((s : ℚ) + 2)) * p * (1 - p)
          * ((((s : ℚ) + 2) ^ b) ^ 3 / ((((s : ℚ) + 2) ^ b) ^ 3 - 1)) := by
  have hs0 : (0 : ℚ) ≤ (s : ℚ) := by positivity
  have hQ2 : (2 : ℚ) ≤ (s : ℚ) + 2 := by linarith
  have hn : (2 : ℚ) ≤ ((s : ℚ) + 2) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := by norm_num
      _ ≤ ((s : ℚ) + 2) ^ 1 := by gcongr
      _ ≤ ((s : ℚ) + 2) ^ b := pow_le_pow_right₀ (by linarith) hb
  have hcube : (8 : ℚ) ≤ (((s : ℚ) + 2) ^ b) ^ 3 := by
    nlinarith [mul_nonneg (sub_nonneg.2 hn)
      (by positivity : (0 : ℚ) ≤ (((s : ℚ) + 2) ^ b) ^ 2 + 2 * (((s : ℚ) + 2) ^ b) + 4)]
  have h1 : ((s : ℚ) + 2) ≠ 0 := by positivity
  have h2 : ((s : ℚ) + 2) ^ 2 + ((s : ℚ) + 2) + 1 ≠ 0 := by positivity
  have h3 : (((s : ℚ) + 2) ^ b) ^ 3 - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  rw [ssR_geom]
  field_simp

/-- `C(q) = (q² + q + 1)/q = q + 1 + 1/q` is strictly increasing for `q ≥ 1`: coarser digit
bases give a higher attainable dial at the same relation rate. -/
theorem geom_constant_strict_mono {x y : ℚ} (hx : 1 ≤ x) (hxy : x < y) :
    (x ^ 2 + x + 1) / x < (y ^ 2 + y + 1) / y := by
  have hx0 : (0 : ℚ) < x := by linarith
  have hy0 : (0 : ℚ) < y := by linarith
  have hxy1 : (1 : ℚ) < x * y := by nlinarith
  rw [div_lt_div_iff₀ hx0 hy0]
  nlinarith [mul_pos (sub_pos.2 hxy) (sub_pos.2 hxy1)]

/-- `ssR_geom` recovers `ssR_dyadic`: at `q = 2` the geometric law is the `(n³ - 1)/14` of the
recorded experiment. -/
theorem ssR_geom_recovers_dyadic (b : ℕ) :
    ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0 = (((2 : ℚ) ^ b) ^ 3 - 1) / 14 := by
  have h := ssR_geom 0 b
  rw [geomBlocks_zero] at h
  rw [h]
  push_cast
  ring_nf

/-- **The recorded regime is the hardest one.**  At every relation rate `p ∈ [0,1]` and every
base `q > 2`, the dyadic ceiling is strictly below the ratio-`1/q` ceiling.  Hence the
exclusions proved for the recorded cell (no binary response at rate `1/8`, no bulk-blind
response) are the strongest statements available in the whole geometric family. -/
theorem dyadic_is_hardest_regime (s : ℕ) (hs : 1 ≤ s) (p : ℚ) (hp0 : 0 < p) (hp1 : p < 1) :
    (7 / 2 : ℚ) * p * (1 - p)
      < ((((s : ℚ) + 2) ^ 2 + ((s : ℚ) + 2) + 1) / ((s : ℚ) + 2)) * p * (1 - p) := by
  have hs1 : (1 : ℚ) ≤ (s : ℚ) := by exact_mod_cast hs
  have hlt : (2 : ℚ) < (s : ℚ) + 2 := by linarith
  have hC := geom_constant_strict_mono (by norm_num : (1 : ℚ) ≤ 2) hlt
  have h72 : ((2 : ℚ) ^ 2 + 2 + 1) / 2 = 7 / 2 := by norm_num
  rw [h72] at hC
  have hpp : 0 < p * (1 - p) := by nlinarith
  nlinarith

end Catalog.Pythagorean.ZeroFitDialGeometricRatio