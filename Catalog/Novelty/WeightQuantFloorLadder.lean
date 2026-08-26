import Mathlib

/-!
# The weight-quantisation ladder: a geometric law with no bit-width floor (NET-95)

This file formalises the *quantitative* content of the NET-95 measurement
**THE-WEIGHT-FLOOR-COLLAPSED**.  A 7B model was evaluated with `llama-perplexity`
(ctx = 2048, 8 threads, a 250 KB held-out wikitext slice) at seven weight
precisions:

| rung   | bpw  | PPL    |
|--------|------|--------|
| fp16   | 16   | 6.9825 |
| q8_0   | 8.5  | 6.9781 |
| q6_k   | 6.6  | 7.0006 |
| q5_k_m | 5.5  | 7.0427 |
| q4_k_m | 4.8  | 7.1093 |
| q3_k_m | 3.9  | 7.2758 |
| q2_k   | 2.6  | 8.1105 |

The narrative claim attached to this table is that the "sub-6-bit floor" reported
for a toy round-to-nearest quantiser (NET-52) is *not* a law about bit widths:
at scale, with calibration-aware k-quants, the excess perplexity
`E(b) = PPL(b) - PPL(fp16)` is a smooth, convex, purely geometric function of the
bit width, with **no cliff anywhere** between 6.6 and 2.6 bpw.

Everything below is proved from the measured numbers as exact rationals.

## Main results

* `weight_ladder_geometric_band` — the *one-parameter law*.  For **every** pair of
  rungs of the k-quant ladder (not merely adjacent ones), the excess perplexity
  ratio per bit removed lies in the band `[5/2, 3]`:
  `(5/2)^k · E(r)^10 ≤ E(s)^10 ≤ 3^k · E(r)^10`, where `k` is the bit-width gap in
  tenths of a bit.  Ten inequalities, all tight enough that neither endpoint of
  the band can be moved much (the extreme observed per-bit rates are `2.539` and
  `2.982`).
* `weight_ladder_cliff_free` — no pair of rungs exhibits a per-bit degradation
  factor of `4` or more: the ladder is cliff-free in the strong, all-pairs sense.
* `weight_ladder_convex` — `E` is a strictly convex function of the bit width on
  the measured points (all ten triples of secant slopes are increasing), and
  `weight_ladder_strictAnti` — `E` is strictly decreasing in bit width.
* `scorecard_P1`, `scorecard_P2_refuted`, `scorecard_P3_refuted`,
  `q8_0_within_noise` — the pre-registered predictions, adjudicated.
* `geometric_closure` / `excess_le_of_bits_below` — the abstract reason a
  geometric band forbids a floor: a per-bit multiplicative bound propagates to a
  bound `m ^ k` after `k` further bits are removed, so degradation can never blow
  up at a finite bit width.
* `one_bit_below_q2k_stays_under_fifty_percent` — the conditional extrapolation:
  if the fitted upper rate `m = 3` persists below 2.6 bpw, then even at 1.6 bpw
  the relative excess is still under the `+50%` "undeployable" threshold.
-/

namespace Catalog.Novelty.WeightQuantFloor

/-! ## 1. The measured ladder -/

/-- One measured rung of the weight-quantisation ladder.  The bit width is stored
in *tenths of a bit* so that bit-width gaps are natural numbers. -/
structure Rung where
  /-- weight precision, in tenths of a bit per weight -/
  tenthBits : ℕ
  /-- measured perplexity on the held-out slice -/
  ppl : ℚ
deriving DecidableEq

/-- The fp16 control perplexity. -/
def fp16PPL : ℚ := 6.9825

/-- Excess perplexity of a rung over the fp16 control. -/
def excess (r : Rung) : ℚ := r.ppl - fp16PPL

/-- Relative excess perplexity (the `dPPL` column of the table). -/
def relExcess (r : Rung) : ℚ := excess r / fp16PPL

/-- `q8_0`, ≈8.5 bpw. -/
def q8_0 : Rung := ⟨85, 6.9781⟩
/-- `q6_k`, ≈6.6 bpw. -/
def q6_k : Rung := ⟨66, 7.0006⟩
/-- `q5_k_m`, ≈5.5 bpw. -/
def q5_k_m : Rung := ⟨55, 7.0427⟩
/-- `q4_k_m`, ≈4.8 bpw.  Its perplexity reproduced the NET-92 control exactly. -/
def q4_k_m : Rung := ⟨48, 7.1093⟩
/-- `q3_k_m`, ≈3.9 bpw. -/
def q3_k_m : Rung := ⟨39, 7.2758⟩
/-- `q2_k`, ≈2.6 bpw. -/
def q2_k : Rung := ⟨26, 8.1105⟩

/-- The calibration-aware k-quant ladder.  `q8_0` is excluded: its measured
perplexity is *below* the fp16 control, i.e. it is a noise-level rung
(`q8_0_within_noise`), so a multiplicative law cannot be tested against it. -/
def ladder : List Rung := [q6_k, q5_k_m, q4_k_m, q3_k_m, q2_k]

/-- Every rung of the k-quant ladder degrades the model: `E > 0`. -/
theorem ladder_excess_pos {r : Rung} (hr : r ∈ ladder) : 0 < excess r := by
  fin_cases hr <;> norm_num [excess, fp16PPL, q6_k, q5_k_m, q4_k_m, q3_k_m, q2_k]

/-! ## 2. The one-parameter geometric law -/

/-- **The weight law.**  For every ordered pair of rungs of the k-quant ladder,
the excess perplexity is multiplied by a factor between `5/2` and `3` for each
bit of precision removed.  Stated without division: with `k` the gap in tenths of
a bit, `(5/2)^k · E(r)^10 ≤ E(s)^10 ≤ 3^k · E(r)^10`.

This is a genuine one-parameter fit: the same band covers all ten pairs, not just
the four adjacent ones, so `E(b) ≍ C · m^(-b)` with `m ∈ [5/2, 3]` describes the
entire measured range 6.6 → 2.6 bpw. -/
theorem weight_ladder_geometric_band {r s : Rung} (hr : r ∈ ladder) (hs : s ∈ ladder)
    (h : s.tenthBits < r.tenthBits) :
    (5 / 2 : ℚ) ^ (r.tenthBits - s.tenthBits) * excess r ^ 10 ≤ excess s ^ 10 ∧
      excess s ^ 10 ≤ 3 ^ (r.tenthBits - s.tenthBits) * excess r ^ 10 := by
  fin_cases hr <;> fin_cases hs <;>
    simp_all [excess, fp16PPL, q6_k, q5_k_m, q4_k_m, q3_k_m, q2_k] <;> norm_num

/-- **No cliff, anywhere.**  A "cliff" on this axis would be a per-bit
degradation factor of `4` or worse (the quadratic-curvature ceiling; see
`Novelty.QuantCurvatureNoFloor`).  No pair of rungs of the weight ladder reaches
it — in sharp contrast with the cache-key axis, where the degradation factor
between 8-bit and 5-bit keys is unbounded (see
`Novelty.SelectionContentPrecision`). -/
theorem weight_ladder_cliff_free {r s : Rung} (hr : r ∈ ladder) (hs : s ∈ ladder)
    (h : s.tenthBits < r.tenthBits) :
    excess s ^ 10 < 4 ^ (r.tenthBits - s.tenthBits) * excess r ^ 10 := by
  have hband := (weight_ladder_geometric_band hr hs h).2
  have hpos : (0 : ℚ) < excess r ^ 10 := pow_pos (ladder_excess_pos hr) 10
  have hk : 0 < r.tenthBits - s.tenthBits := Nat.sub_pos_of_lt h
  have hlt : (3 : ℚ) ^ (r.tenthBits - s.tenthBits) < 4 ^ (r.tenthBits - s.tenthBits) :=
    pow_lt_pow_left₀ (by norm_num) (by norm_num) hk.ne'
  exact lt_of_le_of_lt hband (mul_lt_mul_of_pos_right hlt hpos)

/-- Excess perplexity is strictly decreasing in the bit width across the ladder. -/
theorem weight_ladder_strictAnti {r s : Rung} (hr : r ∈ ladder) (hs : s ∈ ladder)
    (h : s.tenthBits < r.tenthBits) : excess r < excess s := by
  fin_cases hr <;> fin_cases hs <;>
    simp_all [excess, fp16PPL, q6_k, q5_k_m, q4_k_m, q3_k_m, q2_k] <;> norm_num

/-- **Convexity.**  For every triple of rungs with increasing bit width, the
secant slope of `E` increases: the measured curve is strictly convex, which is
exactly the "gentle convex curve" claim, and is what a geometric law in the bit
width must look like. -/
theorem weight_ladder_convex {a b c : Rung} (ha : a ∈ ladder) (hb : b ∈ ladder)
    (hc : c ∈ ladder) (hab : a.tenthBits < b.tenthBits) (hbc : b.tenthBits < c.tenthBits) :
    (excess b - excess a) * ((c.tenthBits : ℚ) - b.tenthBits) <
      (excess c - excess b) * ((b.tenthBits : ℚ) - a.tenthBits) := by
  fin_cases ha <;> fin_cases hb <;> fin_cases hc <;>
    simp_all [excess, fp16PPL, q6_k, q5_k_m, q4_k_m, q3_k_m, q2_k] <;> norm_num

/-! ## 3. The pre-registered scorecard -/

/-- **P1 confirmed.**  `q6_k` sits inside the ±0.5% band around the fp16 control
(measured: +0.259%). -/
theorem scorecard_P1 : |relExcess q6_k| < 1 / 200 := by
  norm_num [relExcess, excess, fp16PPL, q6_k, abs_lt]

/-- **P2 refuted, by a hair.**  `q3_k_m` was predicted to land in `[+5%, +30%]`;
it landed at `+4.2005…%`, just below the band.  The competing "erased, i.e. under
+2%" reading is refuted too. -/
theorem scorecard_P2_refuted : 1 / 50 < relExcess q3_k_m ∧ relExcess q3_k_m < 1 / 20 := by
  constructor <;> norm_num [relExcess, excess, fp16PPL, q3_k_m]

/-- **P3 refuted decisively.**  2.6 bpw was predicted to be undeployable
(`≥ +50%`); the measured cost is `+16.15…%`, under a fifth of the threshold and
under `+20%`. -/
theorem scorecard_P3_refuted : relExcess q2_k < 1 / 5 := by
  norm_num [relExcess, excess, fp16PPL, q2_k]

/-- `q8_0` is a noise-level rung: its perplexity is *below* fp16, by less than
0.1% in magnitude.  This is why it is excluded from the multiplicative law. -/
theorem q8_0_within_noise : relExcess q8_0 < 0 ∧ |relExcess q8_0| < 1 / 1000 := by
  constructor <;> norm_num [relExcess, excess, fp16PPL, q8_0, abs_lt]

/-- **The deployable stack.**  `q4_k_m` weights (+1.816%) composed with the
K8/V4 cache configuration (+0.14%, NET-92/93) cost under 2% of quality in
aggregate, at roughly one-eighth of the naive memory. -/
theorem deployable_stack_under_two_percent : relExcess q4_k_m + 14 / 10000 < 1 / 50 := by
  norm_num [relExcess, excess, fp16PPL, q4_k_m]

/-! ## 4. Why a geometric band forbids a floor -/

/-- **Geometric closure.**  If removing one bit (ten tenth-bits) can multiply the
degradation `D` by at most `m`, then removing `k` bits multiplies it by at most
`m ^ k`.  This is the structural reason "no cliff between adjacent rungs" upgrades
to "no floor at any finite bit width": the damage is bounded by a geometric
series, never by a divergence. -/
theorem geometric_closure (D : ℕ → ℝ) (m : ℝ) (hm : 0 ≤ m)
    (hstep : ∀ b, D b ≤ m * D (b + 10)) :
    ∀ b k, D b ≤ m ^ k * D (b + 10 * k) := by
  intro b k
  induction k with
  | zero => simp
  | succ k ih =>
      have h1 : D (b + 10 * k) ≤ m * D (b + 10 * (k + 1)) := by
        have := hstep (b + 10 * k)
        have hidx : b + 10 * k + 10 = b + 10 * (k + 1) := by ring
        rwa [hidx] at this
      have h2 : m ^ k * D (b + 10 * k) ≤ m ^ k * (m * D (b + 10 * (k + 1))) :=
        mul_le_mul_of_nonneg_left h1 (pow_nonneg hm k)
      calc D b ≤ m ^ k * D (b + 10 * k) := ih
        _ ≤ m ^ k * (m * D (b + 10 * (k + 1))) := h2
        _ = m ^ (k + 1) * D (b + 10 * (k + 1)) := by ring

/-- Reading `geometric_closure` downwards: the degradation `k` bits *below* an
anchor rung is at most `m ^ k` times the anchor's degradation. -/
theorem excess_le_of_bits_below (D : ℕ → ℝ) (m : ℝ) (hm : 0 ≤ m)
    (hstep : ∀ b, D b ≤ m * D (b + 10)) (anchor k : ℕ) (d₀ : ℝ) (hanchor : D anchor ≤ d₀) :
    D (anchor - 10 * k) ≤ m ^ k * d₀ ∨ anchor < 10 * k := by
  rcases le_or_gt (10 * k) anchor with hle | hlt
  · left
    have hidx : anchor - 10 * k + 10 * k = anchor := Nat.sub_add_cancel hle
    have := geometric_closure D m hm hstep (anchor - 10 * k) k
    rw [hidx] at this
    exact this.trans (mul_le_mul_of_nonneg_left hanchor (pow_nonneg hm k))
  · right; exact hlt

/-- **Conditional extrapolation past the measured range.**  Suppose the fitted
*upper* rate of the ladder (`m = 3` per bit) continues to hold below 2.6 bpw.
Then a 1.6 bpw quantiser — a full bit below the lowest measured rung — still has
relative excess perplexity under the `+50%` "undeployable" threshold
(`3 · 1.128 / 6.9825 = 0.4846…`).  So even a one-bit extrapolation of the
measured law does not produce the predicted floor. -/
theorem one_bit_below_q2k_stays_under_fifty_percent (D : ℕ → ℝ)
    (hstep : ∀ b, D b ≤ 3 * D (b + 10)) (hanchor : D 26 ≤ (excess q2_k : ℝ)) :
    D 16 < (1 / 2 : ℝ) * (fp16PPL : ℝ) := by
  have h1 : D 16 ≤ 3 * D (16 + 10) := hstep 16
  have h2 : (3 : ℝ) * D 26 ≤ 3 * (excess q2_k : ℝ) := by linarith [hanchor]
  have h3 : (excess q2_k : ℝ) = 1128 / 1000 := by
    norm_num [excess, fp16PPL, q2_k]
  have h4 : ((fp16PPL : ℚ) : ℝ) = 69825 / 10000 := by norm_num [fp16PPL]
  have h16 : (16 : ℕ) + 10 = 26 := by norm_num
  rw [h16] at h1
  rw [h4]
  rw [h3] at h2
  linarith

end Catalog.Novelty.WeightQuantFloor