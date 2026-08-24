import Mathlib
import Pythagorean.ZeroFitDialChannelDilution88

/-!
# The quadratic channel pool with a noise floor, and the robustness of the 88-rung prediction

## Research context (FACT round-68 #1, exp 536, `TDIAL-U88`)

Cycle 1 (`ZeroFitDialChannelDilution88`) fitted the recorded ladder with the **inverse-bitlen**
law `ρ² = C/b` and showed it forces the first band miss at bitlen 88.  Cycle 2
(`ZeroFitDialProductLaw88`) rejected the **odds-scale** law `ρ²/(1-ρ²) = K/b²`, which places the
first miss one rung too early, at 84.  Cycle 3
(`ZeroFitDialAlphabetUniversality88`) showed the dilution rate is alphabet-independent and that
`1/ρ² - 1` — the *reciprocal excess*, i.e. the effective channel pool measured in units of the
dial's own channel — is additive for any genuine independent-channel model.

That leaves one obvious two-parameter family untested: a **quadratic** channel pool (pairwise
interaction channels: `Θ(b²)` of them) **plus a constant non-channel noise floor**,

```
1/ρ²(b) - 1  =  κ·b²  +  c.
```

This file fits that law exactly, in `ℚ`, from the two extreme rungs (44 and 88) and shows:

* the floor is **forced to be strictly positive** by the record — the pure quadratic pool
  (`c = 0`) is excluded, and so is the pure pairwise-channel model, which over-erodes;
* the fitted law retrodicts every non-outlier rung of the ladder to within `0.027` in `ρ²`,
  and re-flags the 52-rung as the single outlier (deviation `> 0.08`), independently of cycle 1;
* it places the first band miss **at 88**, agreeing with the structurally different
  inverse-bitlen law of cycle 1 even though the two laws are fitted by different procedures.

The last point is the scientific payload: `first_miss_robust_across_models`.  The 88-rung is not
an artefact of one functional form.

## Main results

* `noise_floor_forced` — any `(κ, c)` fitting the 44- and 88-rungs has `κ > 0` **and** `c > 0`.
* `pairwise_dilution_exact` — the exact dilution of a pairwise-channel pool,
  `ρ² = 2a²/(2a² + b(b-1))`, from `channel_dilution_law` and `Nat.cast_choose_two`.
* `pairwise_pool_overshoots_the_record` — that pure pairwise pool erodes strictly faster between
  bitlen 44 and 88 than the record does.
* `quadratic_retrodiction` — all nine non-outlier rungs are hit to within `27/1000` in `ρ²`.
* `rung52_outlier_confirmed` — the 52-rung is missed by more than `8/100`.
* `quadratic_first_band_miss_at_88` — the fitted law clears the band floor at every bitlen `≤ 84`
  and misses it at every bitlen `≥ 88`.
* `first_miss_robust_across_models` — inverse-bitlen and quadratic-pool-with-floor both bracket
  the crossing bitlen in `(84, 88]`.
-/

namespace Catalog.Pythagorean.ZeroFitDialQuadraticPool88

open Catalog.Pythagorean.ZeroFitDialChannelDilution88

/-! ## 1. The reciprocal excess and the two-point quadratic fit -/

/-- The **reciprocal excess** of a dial reading: `1/ρ² - 1`.  For any independent-channel model
this is the size of the competing channel pool measured in units of the dial's own channel. -/
def exc (r : ℚ) : ℚ := 1 / r ^ 2 - 1

/-- Quadratic pool coefficient, fitted exactly to the two extreme rungs 44 and 88. -/
def kapQ : ℚ := (exc d88 - exc d44) / ((88 : ℚ) ^ 2 - (44 : ℚ) ^ 2)

/-- The constant non-channel noise floor implied by the same two-point fit. -/
def floorQ : ℚ := exc d44 - kapQ * (44 : ℚ) ^ 2

/-- The fitted profile `ρ²(b) = 1/(1 + κ b² + c)`. -/
def predQ (b : ℕ) : ℚ := 1 / (1 + kapQ * (b : ℚ) ^ 2 + floorQ)

lemma kapQ_pos : 0 < kapQ := by
  norm_num [kapQ, exc, d44, d88]

lemma floorQ_pos : 0 < floorQ := by
  norm_num [floorQ, kapQ, exc, d44, d88]

lemma predQ_denom_pos (b : ℕ) : 0 < 1 + kapQ * (b : ℚ) ^ 2 + floorQ := by
  have h1 : (0 : ℚ) ≤ kapQ * (b : ℚ) ^ 2 := by
    have := kapQ_pos
    positivity
  have := floorQ_pos
  linarith

/-- The fit is exact at the lower anchor rung. -/
lemma fit_at_44 : kapQ * (44 : ℚ) ^ 2 + floorQ = exc d44 := by
  unfold floorQ; ring

/-- The fit is exact at the upper anchor rung. -/
lemma fit_at_88 : kapQ * (88 : ℚ) ^ 2 + floorQ = exc d88 := by
  norm_num [floorQ, kapQ, exc, d44, d88]

/-- **The noise floor is forced.**  Any quadratic-pool law `1/ρ² - 1 = κ b² + c` that reproduces
the recorded 44- and 88-rungs must have a strictly positive pool coefficient *and* a strictly
positive constant floor.  The pure quadratic pool `c = 0` is therefore excluded by the data:
the ladder erodes by a factor strictly less than `(88/44)² = 4` between its endpoints. -/
theorem noise_floor_forced (kap c : ℚ)
    (h44 : kap * (44 : ℚ) ^ 2 + c = exc d44)
    (h88 : kap * (88 : ℚ) ^ 2 + c = exc d88) :
    0 < kap ∧ 0 < c := by
  have e44 : exc d44 = 979 / 1521 := by norm_num [exc, d44]
  have e88 : exc d88 = 178711 / 71289 := by norm_num [exc, d88]
  rw [e44] at h44
  rw [e88] at h88
  constructor <;> nlinarith [h44, h88]

/-- The hypotheses of `noise_floor_forced` are satisfiable: `(kapQ, floorQ)` realises them. -/
lemma noise_floor_realised : 0 < kapQ ∧ 0 < floorQ :=
  noise_floor_forced kapQ floorQ fit_at_44 fit_at_88

/-! ## 2. The pure pairwise-channel pool, and why it over-erodes -/

/-- **Exact dilution of a pairwise-channel pool.**  If the competing channels are the
`b.choose 2` unordered pairs of `b` base channels, the squared correlation carried by the dial's
own channel of weight `a` is exactly `2a²/(2a² + b(b-1))`. -/
theorem pairwise_dilution_exact (a : ℚ) (ha : a ≠ 0) (b : ℕ) :
    pearsonSq (channelSample a (b.choose 2)) = 2 * a ^ 2 / (2 * a ^ 2 + (b : ℚ) * ((b : ℚ) - 1)) := by
  rw [channel_dilution_law a _ ha, Nat.cast_choose_two]
  have ha2 : (0 : ℚ) < a ^ 2 := by positivity
  have hb : (0 : ℚ) ≤ (b : ℚ) * ((b : ℚ) - 1) := by
    rcases Nat.eq_zero_or_pos b with h | h
    · simp [h]
    · have : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast h
      nlinarith
  have hd1 : a ^ 2 + (b : ℚ) * ((b : ℚ) - 1) / 2 ≠ 0 := by linarith
  have hd2 : 2 * a ^ 2 + (b : ℚ) * ((b : ℚ) - 1) ≠ 0 := by linarith
  field_simp

/-- **The pure pairwise pool over-erodes.**  A pairwise-channel pool multiplies the reciprocal
excess by `2·87/43 = 174/43 > 4` between bitlen 44 and bitlen 88; the record multiplies it by
strictly less.  So the observed erosion, though super-additive, is *slower* than pure pairwise
interaction — exactly the gap that the positive noise floor of `noise_floor_forced` fills. -/
theorem pairwise_pool_overshoots_the_record :
    exc d88 < exc d44 * (174 / 43) := by
  norm_num [exc, d44, d88]

/-! ## 3. Retrodiction of the recorded ladder -/

/-- **Retrodiction.**  The two-point fit reproduces all nine non-outlier rungs of the recorded
ladder to within `27/1000` on the `ρ²` scale — including the six rungs that were not used to fit
it. -/
theorem quadratic_retrodiction :
    |predQ 44 - d44 ^ 2| < 27 / 1000 ∧
    |predQ 56 - d56 ^ 2| < 27 / 1000 ∧
    |predQ 64 - d64 ^ 2| < 27 / 1000 ∧
    |predQ 68 - d68 ^ 2| < 27 / 1000 ∧
    |predQ 72 - d72 ^ 2| < 27 / 1000 ∧
    |predQ 76 - d76 ^ 2| < 27 / 1000 ∧
    |predQ 80 - d80 ^ 2| < 27 / 1000 ∧
    |predQ 84 - d84 ^ 2| < 27 / 1000 ∧
    |predQ 88 - d88 ^ 2| < 27 / 1000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    · rw [abs_lt]
      constructor <;>
        norm_num [predQ, kapQ, floorQ, exc, d44, d56, d64, d68, d72, d76, d80, d84, d88]

/-- **The 52-rung is an outlier, confirmed by a second model.**  Cycle 1 flagged bitlen 52 as the
one non-monotone rung of the ladder using the invariant `ρ²·b`.  The independent quadratic fit
misses it by more than `8/100` in `ρ²`, three times the worst deviation on any other rung. -/
theorem rung52_outlier_confirmed : 8 / 100 < |predQ 52 - d52 ^ 2| := by
  rw [lt_abs]
  right
  norm_num [predQ, kapQ, floorQ, exc, d44, d52, d88]

/-! ## 4. The first band miss, and its robustness across models -/

/-- **The fitted quadratic-pool law places the first band miss at bitlen 88.**  It clears the
`0.55` floor at every bitlen up to and including 84, and misses it at every bitlen from 88 on. -/
theorem quadratic_first_band_miss_at_88 :
    (∀ b : ℕ, 1 ≤ b → b ≤ 84 → bandFloor ^ 2 < predQ b) ∧
    (∀ b : ℕ, 88 ≤ b → predQ b < bandFloor ^ 2) := by
  have hband : bandFloor ^ 2 = 121 / 400 := by norm_num [bandFloor]
  constructor
  · intro b _ hb
    have hbq : (b : ℚ) ≤ 84 := by exact_mod_cast hb
    have hb0 : (0 : ℚ) ≤ (b : ℚ) := Nat.cast_nonneg b
    have hsq : (b : ℚ) ^ 2 ≤ (84 : ℚ) ^ 2 := by nlinarith
    have hmono : kapQ * (b : ℚ) ^ 2 ≤ kapQ * (84 : ℚ) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq kapQ_pos.le
    have htop : kapQ * (84 : ℚ) ^ 2 + floorQ < 279 / 121 := by
      norm_num [kapQ, floorQ, exc, d44, d88]
    have hpos := predQ_denom_pos b
    rw [predQ, hband, lt_div_iff₀ hpos]
    linarith
  · intro b hb
    have hbq : (88 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
    have hsq : (88 : ℚ) ^ 2 ≤ (b : ℚ) ^ 2 := by nlinarith
    have hmono : kapQ * (88 : ℚ) ^ 2 ≤ kapQ * (b : ℚ) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq kapQ_pos.le
    have hbot : 279 / 121 < kapQ * (88 : ℚ) ^ 2 + floorQ := by
      norm_num [kapQ, floorQ, exc, d44, d88]
    have hpos := predQ_denom_pos b
    rw [predQ, hband, div_lt_iff₀ hpos]
    linarith

/-- **Model robustness of the 88-rung.**  The inverse-bitlen law of cycle 1 (fitted by pooling
the invariant `ρ²·b` over nine rungs) and the quadratic-pool-with-floor law of this cycle (fitted
by interpolating two rungs) are structurally different and fitted by different procedures, yet
both put the band crossing strictly between bitlen 84 and bitlen 88.  The first band miss at 88
is therefore a property of the ladder, not of a chosen functional form. -/
theorem first_miss_robust_across_models :
    bandFloor ^ 2 < pooledC / (84 : ℚ) ∧ pooledC / (88 : ℚ) < bandFloor ^ 2 ∧
    bandFloor ^ 2 < predQ 84 ∧ predQ 88 < bandFloor ^ 2 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact first_band_miss_predicted_at_88.1 84 (by norm_num) (by norm_num)
  · exact first_band_miss_predicted_at_88.2 88 (by norm_num)
  · exact quadratic_first_band_miss_at_88.1 84 (by norm_num) (by norm_num)
  · exact quadratic_first_band_miss_at_88.2 88 (by norm_num)

end Catalog.Pythagorean.ZeroFitDialQuadraticPool88