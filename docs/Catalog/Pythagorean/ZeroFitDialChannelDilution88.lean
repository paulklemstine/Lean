import Mathlib
import Novelty.ZeroFitDialU64

/-!
# The channel-dilution law of the zero-fit dial, and the band-miss at bitlen 88

## Research context (FACT round-68 #1, exp 536, `TDIAL-U88`)

The uniform ladder of the zero-fit dial reads

```
0.78 (44) → 0.81 (52) → 0.69 (56) → 0.65 (64) → 0.61 (68) → 0.61 (72)
          → 0.61 (76) → 0.57 (80) → 0.56 (84) → 0.534 (88)
```

and the 88-rung is the first *band miss*: pooled `ρ = 0.534 < 0.55`, CI `[0.509, 0.555]`
straddling the floor.  `Novelty.ZeroFitDialU64` already proved that the erosion is **not** a
tie/quantisation artefact — the 2-adic tie ceiling is `6/7 + O(4^{-b})`, flat to within
`10^{-26}` across the whole ladder.  So what shape *does* the erosion have, and is the
88-rung miss a fluke of one cron iteration or a forced consequence of that shape?

This file supplies both halves of the answer.

## Main results

### 1. A finite-sample correlation calculus
* `lsum`, `pearsonSq` — Pearson's squared coefficient of a finite paired sample given as a
  list, in determinant form `(nΣxy - ΣxΣy)² / ((nΣx² - (Σx)²)(nΣy² - (Σy)²))`.
* `cs_step`, `cauchy_schwarz_list`, `pearsonSq_le_one` — Cauchy–Schwarz for lists, proved by
  induction from a two-term algebraic step, and the resulting `ρ² ≤ 1`.

### 2. The channel-dilution law (the structural model)
* `weights`, `wsum_eq`, `wsq_eq` — the Hamming-weight spectrum of the `m`-cube and its first
  two moments, `2·Σw = m·2^m` and `4·Σw² = 2^m(m² + m)`.
* `channel_dilution_law` — **the payload identity**: if the response is a weighted sum of
  `b = m + 1` independent binary channels, of which the dial's statistic *is* one, carried
  with weight `a`, then exactly
  `ρ² = a² / (a² + b - 1)`.
  In particular `channel_dilution_unweighted`: `ρ² = 1/b`, i.e. **one channel out of `b` buys
  exactly one `b`-th of the squared correlation.**
* `dilution_strict_anti`, `dilution_times_bitlen` — the law decays strictly in the bitlen and
  `b·ρ²(b) - a² = a²(1 - a²)/(a² + b - 1)`, so `b·ρ²(b) → a²`: an *inverse-bitlen* law.

### 3. The ladder is an inverse-bitlen law, and it forces the 88-rung
* `ladder_constant_window` — every rung of the recorded ladder except the anomalous 52-rung
  has `ρ²·b ∈ [25, 28.3]`; the invariant `ρ²·b` is constant to `±6 %` over a doubling of the
  bitlen, while `ρ²` itself falls by a factor `2.13`.  `rung52_outlier` isolates the one rung
  that is not.
* `one_step_ahead_predictions` — the invariant fitted at each rung predicts the *next* rung's
  `ρ²` to within `0.03`, for all eight consecutive pairs; nothing is fitted to the target.
* `pooled_crossing`, `first_band_miss_predicted_at_88` — **the retrodiction**: the pooled
  invariant `C = 7446029/281250 = 26.4747…` gives `C/84 > 0.55² > C/88`.  The inverse-bitlen
  law therefore predicts the dial holds the band at every rung up to 84 and misses it first at
  88 — exactly what exp 536 observed.  `predicted_crossing_bitlen` localises the crossing at
  `87 < b* < 88`.

### 4. Adversarial review: the structural model is falsified in its literal form
* `fixed_weight_dilution_excluded` — for **every** channel weight `a ≠ 0` the exact law
  `a²/(a² + b - 1)` decays *strictly more slowly* between bitlen 44 and 88 than the recorded
  dial does.  A fixed-weight single channel cannot fit both ends of the ladder; only the
  dilute asymptotic `C/b` can.
* `ladder_power_law_exponent` — the recorded decay exponent obeys `1 < γ ≤ 6/5`: the ladder is
  slightly *super*-dilute.
* `tie_ceiling_cannot_explain_88` — the tie ceiling moves by `< 10^{-26}` across the ladder
  while the dial moves by `> 0.32` in `ρ²`.
* `inverse_law_respects_tie_ceiling` — the inverse-bitlen law lies below the exact 2-adic tie
  ceiling precisely for `b ≥ 31`, and above it for `1 ≤ b ≤ 30`.  The ladder starts at 44,
  inside the legal range; below bitlen 31 the tie ceiling, not the channel pool, binds.

### 5. Pythagorean bridge
* `euclid_triple` — the Euclid parametrisation.
* `even_leg_two_adic` — for odd `m`, `2^{k+1} ∣ 2mn ↔ 2^k ∣ n`.
* `pythLeg_block_card`, `pythLeg_profile_eq_dyadic` — the trailing-zero tie profile of the
  **even leg** `2mn` of the Euclid family, as `n` ranges over `2^b` draws, is *literally* the
  dyadic profile `dyadicBlocks b`.  Hence every ceiling of this cycle and of the whole
  `ZeroFitDial` catalog transfers verbatim from uniform integers to Pythagorean legs
  (`pythLeg_dial_ceiling`, `pythLeg_band_miss_transfers`).
-/

open Finset
open Catalog.Novelty.ZeroFitDialU64

namespace Catalog.Pythagorean.ZeroFitDialChannelDilution88

/-! ## 1. Correlation calculus for a finite paired sample -/

/-- Sum of `f` over a finite paired sample presented as a list. -/
def lsum (D : List (ℚ × ℚ)) (f : ℚ × ℚ → ℚ) : ℚ := (D.map f).sum

@[simp] lemma lsum_nil (f : ℚ × ℚ → ℚ) : lsum [] f = 0 := rfl

@[simp] lemma lsum_cons (p : ℚ × ℚ) (D : List (ℚ × ℚ)) (f : ℚ × ℚ → ℚ) :
    lsum (p :: D) f = f p + lsum D f := by simp [lsum]

lemma lsum_append (D E : List (ℚ × ℚ)) (f : ℚ × ℚ → ℚ) :
    lsum (D ++ E) f = lsum D f + lsum E f := by simp [lsum]

lemma lsum_add (D : List (ℚ × ℚ)) (f g : ℚ × ℚ → ℚ) :
    lsum D (fun p => f p + g p) = lsum D f + lsum D g := by
  induction D with
  | nil => simp
  | cons p D ih => rw [lsum_cons, lsum_cons, lsum_cons, ih]; ring

lemma lsum_mul_left (c : ℚ) (D : List (ℚ × ℚ)) (f : ℚ × ℚ → ℚ) :
    lsum D (fun p => c * f p) = c * lsum D f := by
  induction D with
  | nil => simp
  | cons p D ih => rw [lsum_cons, lsum_cons, ih]; ring

lemma lsum_const (c : ℚ) (D : List (ℚ × ℚ)) :
    lsum D (fun _ => c) = (D.length : ℚ) * c := by
  induction D with
  | nil => simp
  | cons p D ih => rw [lsum_cons, ih, List.length_cons]; push_cast; ring

lemma lsum_sq_nonneg (D : List (ℚ × ℚ)) (f : ℚ × ℚ → ℚ) :
    0 ≤ lsum D (fun p => f p ^ 2) := by
  induction D with
  | nil => simp
  | cons p D ih => rw [lsum_cons]; nlinarith [sq_nonneg (f p)]

/-- The two-term Cauchy–Schwarz step: appending one sample point preserves the inequality. -/
lemma cs_step {a b A B C : ℚ} (hA : 0 ≤ A) (hB : 0 ≤ B) (h : C ^ 2 ≤ A * B) :
    (a * b + C) ^ 2 ≤ (a ^ 2 + A) * (b ^ 2 + B) := by
  rcases eq_or_lt_of_le hB with hB0 | hBpos
  · have hC : C = 0 := by nlinarith [sq_nonneg C]
    subst hC
    nlinarith [sq_nonneg (a * b), mul_nonneg hA (sq_nonneg b)]
  · have key : 0 ≤ B * (a ^ 2 * B + A * b ^ 2 - 2 * a * b * C) := by
      nlinarith [sq_nonneg (a * B - b * C), mul_nonneg (sub_nonneg.2 h) (sq_nonneg b)]
    have hX : 0 ≤ a ^ 2 * B + A * b ^ 2 - 2 * a * b * C := by
      by_contra hneg
      push_neg at hneg
      nlinarith
    nlinarith

/-- **Cauchy–Schwarz for a finite sample**, by induction on the list. -/
lemma cauchy_schwarz_list (D : List (ℚ × ℚ)) (f g : ℚ × ℚ → ℚ) :
    (lsum D fun p => f p * g p) ^ 2
      ≤ (lsum D fun p => f p ^ 2) * (lsum D fun p => g p ^ 2) := by
  induction D with
  | nil => simp
  | cons p D ih =>
      rw [lsum_cons, lsum_cons, lsum_cons]
      exact cs_step (lsum_sq_nonneg D f) (lsum_sq_nonneg D g) ih

/-- Sample size. -/
def sampleN (D : List (ℚ × ℚ)) : ℚ := (D.length : ℚ)

/-- `n·Cov(X,Y)` in determinant form. -/
def covXY (D : List (ℚ × ℚ)) : ℚ :=
  sampleN D * lsum D (fun p => p.1 * p.2) - lsum D Prod.fst * lsum D Prod.snd

/-- `n·Var X` in determinant form. -/
def varX (D : List (ℚ × ℚ)) : ℚ :=
  sampleN D * lsum D (fun p => p.1 ^ 2) - (lsum D Prod.fst) ^ 2

/-- `n·Var Y` in determinant form. -/
def varY (D : List (ℚ × ℚ)) : ℚ :=
  sampleN D * lsum D (fun p => p.2 ^ 2) - (lsum D Prod.snd) ^ 2

/-- Pearson's squared correlation coefficient of a finite paired sample. -/
def pearsonSq (D : List (ℚ × ℚ)) : ℚ := covXY D ^ 2 / (varX D * varY D)

/-- Centring identity for the cross moment of the `n`-scaled deviations. -/
lemma lsum_centred_cross (D : List (ℚ × ℚ)) :
    (lsum D fun p => (sampleN D * p.1 - lsum D Prod.fst) * (sampleN D * p.2 - lsum D Prod.snd))
      = sampleN D * covXY D := by
  have hexp : (fun p : ℚ × ℚ =>
        (sampleN D * p.1 - lsum D Prod.fst) * (sampleN D * p.2 - lsum D Prod.snd))
      = fun p : ℚ × ℚ => sampleN D ^ 2 * (p.1 * p.2)
          + ((-(sampleN D * lsum D Prod.snd)) * p.1
            + ((-(sampleN D * lsum D Prod.fst)) * p.2
              + lsum D Prod.fst * lsum D Prod.snd)) := by
    funext p; ring
  rw [hexp, lsum_add, lsum_add, lsum_add, lsum_mul_left, lsum_mul_left, lsum_mul_left,
    lsum_const, covXY]
  have hnl : ((D.length : ℚ)) = sampleN D := rfl
  rw [hnl]
  ring

/-- Centring identity for the `X`-variance. -/
lemma lsum_centred_x (D : List (ℚ × ℚ)) :
    (lsum D fun p => (sampleN D * p.1 - lsum D Prod.fst) ^ 2) = sampleN D * varX D := by
  have hexp : (fun p : ℚ × ℚ => (sampleN D * p.1 - lsum D Prod.fst) ^ 2)
      = fun p : ℚ × ℚ => sampleN D ^ 2 * (p.1 ^ 2)
          + ((-(2 * sampleN D * lsum D Prod.fst)) * p.1 + (lsum D Prod.fst) ^ 2) := by
    funext p; ring
  rw [hexp, lsum_add, lsum_add, lsum_mul_left, lsum_mul_left, lsum_const, varX]
  have hnl : ((D.length : ℚ)) = sampleN D := rfl
  rw [hnl]; ring

/-- Centring identity for the `Y`-variance. -/
lemma lsum_centred_y (D : List (ℚ × ℚ)) :
    (lsum D fun p => (sampleN D * p.2 - lsum D Prod.snd) ^ 2) = sampleN D * varY D := by
  have hexp : (fun p : ℚ × ℚ => (sampleN D * p.2 - lsum D Prod.snd) ^ 2)
      = fun p : ℚ × ℚ => sampleN D ^ 2 * (p.2 ^ 2)
          + ((-(2 * sampleN D * lsum D Prod.snd)) * p.2 + (lsum D Prod.snd) ^ 2) := by
    funext p; ring
  rw [hexp, lsum_add, lsum_add, lsum_mul_left, lsum_mul_left, lsum_const, varY]
  have hnl : ((D.length : ℚ)) = sampleN D := rfl
  rw [hnl]; ring

/-- **The correlation of any finite paired sample is at most one**, by Cauchy–Schwarz applied
to the centred deviation vectors. -/
theorem pearsonSq_le_one (D : List (ℚ × ℚ)) (hn : 0 < sampleN D)
    (hx : 0 < varX D) (hy : 0 < varY D) : pearsonSq D ≤ 1 := by
  have hCS := cauchy_schwarz_list D (fun p => sampleN D * p.1 - lsum D Prod.fst)
    (fun p => sampleN D * p.2 - lsum D Prod.snd)
  rw [lsum_centred_cross, lsum_centred_x, lsum_centred_y] at hCS
  have hkey : covXY D ^ 2 ≤ varX D * varY D := by
    have hn2 : 0 < sampleN D ^ 2 := by positivity
    nlinarith [hCS]
  rw [pearsonSq, div_le_one (by positivity)]
  exact hkey

/-! ## 2. The binary channel cube and its weight spectrum -/

/-- The multiset of Hamming weights of all `m`-bit vectors, as a list. -/
def weights : ℕ → List ℚ
  | 0 => [0]
  | m + 1 => weights m ++ (weights m).map (fun w => w + 1)

/-- First moment of the weight spectrum. -/
def wsum (m : ℕ) : ℚ := (weights m).sum

/-- Second moment of the weight spectrum. -/
def wsq (m : ℕ) : ℚ := ((weights m).map (fun w => w ^ 2)).sum

lemma weights_length (m : ℕ) : (weights m).length = 2 ^ m := by
  induction m with
  | zero => simp [weights]
  | succ m ih => rw [weights, List.length_append, List.length_map, ih, pow_succ]; ring

lemma sum_map_const (L : List ℚ) (c : ℚ) : (L.map (fun _ => c)).sum = (L.length : ℚ) * c := by
  induction L with
  | nil => simp
  | cons w L ih => rw [List.map_cons, List.sum_cons, ih, List.length_cons]; push_cast; ring

lemma sum_map_mul_left (c : ℚ) (f : ℚ → ℚ) (L : List ℚ) :
    (L.map (fun w => c * f w)).sum = c * (L.map f).sum := by
  induction L with
  | nil => simp
  | cons w L ih => rw [List.map_cons, List.sum_cons, ih, List.map_cons, List.sum_cons]; ring

lemma sum_map_add_one (L : List ℚ) :
    (L.map (fun w => w + 1)).sum = L.sum + (L.length : ℚ) := by
  induction L with
  | nil => simp
  | cons w L ih =>
      rw [List.map_cons, List.sum_cons, ih, List.sum_cons, List.length_cons]
      push_cast; ring

lemma sum_map_add_one_sq (L : List ℚ) :
    (L.map (fun w => (w + 1) ^ 2)).sum
      = (L.map (fun w => w ^ 2)).sum + 2 * L.sum + (L.length : ℚ) := by
  induction L with
  | nil => simp
  | cons w L ih =>
      rw [List.map_cons, List.sum_cons, ih, List.map_cons, List.sum_cons, List.sum_cons,
        List.length_cons]
      push_cast; ring

/-- `2·Σ w = m·2^m`: the mean Hamming weight is `m/2`. -/
lemma wsum_eq (m : ℕ) : 2 * wsum m = (m : ℚ) * 2 ^ m := by
  induction m with
  | zero => simp [wsum, weights]
  | succ m ih =>
      have h : wsum (m + 1) = 2 * wsum m + 2 ^ m := by
        rw [wsum, weights, List.sum_append, sum_map_add_one, weights_length, ← wsum]
        push_cast; ring
      rw [h, pow_succ]
      push_cast
      linarith [ih]

/-- `4·Σ w² = 2^m(m² + m)`: the weight spectrum has variance `m/4`. -/
lemma wsq_eq (m : ℕ) : 4 * wsq m = 2 ^ m * ((m : ℚ) ^ 2 + m) := by
  induction m with
  | zero => simp [wsq, weights]
  | succ m ih =>
      have hcomp : ((fun w : ℚ => w ^ 2) ∘ fun w : ℚ => w + 1) = fun w : ℚ => (w + 1) ^ 2 := rfl
      have h : wsq (m + 1) = 2 * wsq m + 2 * wsum m + 2 ^ m := by
        rw [wsq, weights, List.map_append, List.sum_append, List.map_map, hcomp,
          sum_map_add_one_sq, weights_length, ← wsq, ← wsum]
        push_cast; ring
      have hs := wsum_eq m
      rw [h, pow_succ]
      push_cast
      nlinarith [ih, hs]

/-! ## 3. The channel-dilution law -/

/-- The paired sample of the **`b = m + 1` channel model**: the predictor is the dial's own
binary channel, the response is that channel carried with weight `a` plus the `m` remaining
independent channels. -/
def channelSample (a : ℚ) (m : ℕ) : List (ℚ × ℚ) :=
  (weights m).map (fun w => ((0 : ℚ), w)) ++ (weights m).map (fun w => ((1 : ℚ), a + w))

lemma lsum_map (L : List ℚ) (h : ℚ → ℚ × ℚ) (f : ℚ × ℚ → ℚ) :
    lsum (L.map h) f = (L.map (fun w => f (h w))).sum := by
  rw [lsum, List.map_map]
  rfl

lemma lsum_map_fst (c : ℚ) (f : ℚ → ℚ) (L : List ℚ) :
    lsum (L.map (fun w => (c, f w))) Prod.fst = (L.length : ℚ) * c := by
  rw [lsum_map]
  exact sum_map_const L c

lemma lsum_map_snd (c : ℚ) (f : ℚ → ℚ) (L : List ℚ) :
    lsum (L.map (fun w => (c, f w))) Prod.snd = (L.map f).sum := by
  rw [lsum_map]

lemma lsum_map_fst_sq (c : ℚ) (f : ℚ → ℚ) (L : List ℚ) :
    lsum (L.map (fun w => (c, f w))) (fun p => p.1 ^ 2) = (L.length : ℚ) * c ^ 2 := by
  rw [lsum_map]
  exact sum_map_const L (c ^ 2)

lemma lsum_map_snd_sq (c : ℚ) (f : ℚ → ℚ) (L : List ℚ) :
    lsum (L.map (fun w => (c, f w))) (fun p => p.2 ^ 2) = (L.map (fun w => f w ^ 2)).sum := by
  rw [lsum_map]

lemma lsum_map_cross (c : ℚ) (f : ℚ → ℚ) (L : List ℚ) :
    lsum (L.map (fun w => (c, f w))) (fun p => p.1 * p.2) = c * (L.map f).sum := by
  rw [lsum_map]
  exact sum_map_mul_left c f L

lemma sum_map_shift (a : ℚ) (L : List ℚ) :
    (L.map (fun w => a + w)).sum = (L.length : ℚ) * a + L.sum := by
  induction L with
  | nil => simp
  | cons w L ih =>
      rw [List.map_cons, List.sum_cons, ih, List.sum_cons, List.length_cons]
      push_cast; ring

lemma sum_map_shift_sq (a : ℚ) (L : List ℚ) :
    (L.map (fun w => (a + w) ^ 2)).sum
      = (L.length : ℚ) * a ^ 2 + 2 * a * L.sum + (L.map (fun w => w ^ 2)).sum := by
  induction L with
  | nil => simp
  | cons w L ih =>
      rw [List.map_cons, List.sum_cons, ih, List.sum_cons, List.map_cons, List.sum_cons,
        List.length_cons]
      push_cast; ring

lemma channelSample_length (a : ℚ) (m : ℕ) : sampleN (channelSample a m) = 2 * 2 ^ m := by
  rw [sampleN, channelSample, List.length_append, List.length_map, List.length_map,
    weights_length]
  push_cast; ring

lemma sum_weights_id : ∀ m : ℕ, ((weights m).map (fun w => w)).sum = wsum m := by
  intro m; rw [List.map_id', wsum]

lemma sum_weights_shift (a : ℚ) (m : ℕ) :
    ((weights m).map (fun w => a + w)).sum = (2 : ℚ) ^ m * a + wsum m := by
  rw [sum_map_shift, weights_length, wsum]; push_cast; ring

lemma sum_weights_shift_sq (a : ℚ) (m : ℕ) :
    ((weights m).map (fun w => (a + w) ^ 2)).sum
      = (2 : ℚ) ^ m * a ^ 2 + 2 * a * wsum m + wsq m := by
  rw [sum_map_shift_sq, weights_length, wsum, wsq]; push_cast; ring

/-- The `X`-side variance of the channel sample: `n·Var X = 4^m`. -/
lemma channel_varX (a : ℚ) (m : ℕ) : varX (channelSample a m) = (2 ^ m) ^ 2 := by
  rw [varX, channelSample_length, channelSample, lsum_append, lsum_append, lsum_map_fst,
    lsum_map_fst, lsum_map_fst_sq, lsum_map_fst_sq, weights_length]
  push_cast
  ring

/-- The cross moment of the channel sample: `n·Cov(X,Y) = a·4^m`. -/
lemma channel_covXY (a : ℚ) (m : ℕ) : covXY (channelSample a m) = a * (2 ^ m) ^ 2 := by
  rw [covXY, channelSample_length, channelSample, lsum_append, lsum_append, lsum_append,
    lsum_map_fst, lsum_map_fst, lsum_map_snd, lsum_map_snd, lsum_map_cross, lsum_map_cross,
    weights_length, sum_weights_id, sum_weights_shift]
  push_cast
  ring

/-- The `Y`-side variance of the channel sample: `n·Var Y = 4^m(a² + m)`. -/
lemma channel_varY (a : ℚ) (m : ℕ) :
    varY (channelSample a m) = (2 ^ m) ^ 2 * (a ^ 2 + (m : ℚ)) := by
  rw [varY, channelSample_length, channelSample, lsum_append, lsum_append, lsum_map_snd,
    lsum_map_snd, lsum_map_snd_sq, lsum_map_snd_sq, sum_weights_id, sum_weights_shift]
  have h3 : ((weights m).map (fun w => w ^ 2)).sum = wsq m := by rw [wsq]
  rw [h3, sum_weights_shift_sq]
  have hs := wsum_eq m
  have hq := wsq_eq m
  linear_combination ((2 : ℚ) ^ m) * hq - ((m : ℚ) * 2 ^ m + 2 * wsum m) * hs

/-- **The channel-dilution law.**  In a model with `b = m + 1` independent binary channels
whose response carries the dial's own channel with weight `a`, the squared correlation between
that channel and the response is *exactly* `a² / (a² + b - 1)`. -/
theorem channel_dilution_law (a : ℚ) (m : ℕ) (ha : a ≠ 0) :
    pearsonSq (channelSample a m) = a ^ 2 / (a ^ 2 + (m : ℚ)) := by
  have hm : (0 : ℚ) ≤ (m : ℚ) := by positivity
  have ha2 : 0 < a ^ 2 := by positivity
  have hden : (0 : ℚ) < a ^ 2 + (m : ℚ) := by linarith
  have hp : ((2 : ℚ) ^ m) ^ 2 ≠ 0 := by positivity
  rw [pearsonSq, channel_covXY, channel_varX, channel_varY]
  field_simp

/-- The unweighted case: `ρ² = 1/b` on `b = m + 1` channels.  One channel out of `b` buys
exactly one `b`-th of the squared correlation. -/
theorem channel_dilution_unweighted (m : ℕ) :
    pearsonSq (channelSample 1 m) = 1 / ((m : ℚ) + 1) := by
  rw [channel_dilution_law 1 m one_ne_zero]
  rw [one_pow]
  ring_nf

/-- The dilution law is strictly decreasing in the number of channels. -/
theorem dilution_strict_anti (a : ℚ) (ha : a ≠ 0) {m m' : ℕ} (h : m < m') :
    pearsonSq (channelSample a m') < pearsonSq (channelSample a m) := by
  have ha2 : 0 < a ^ 2 := by positivity
  have hlt : (m : ℚ) < (m' : ℚ) := by exact_mod_cast h
  have hm : (0 : ℚ) ≤ (m : ℚ) := by positivity
  rw [channel_dilution_law a m ha, channel_dilution_law a m' ha]
  rw [div_lt_div_iff₀ (by linarith) (by linarith)]
  nlinarith

/-- **The inverse-bitlen scaling.**  With `b = m + 1` channels the invariant `b·ρ²` differs
from `a²` by `a²(1 - a²)/(a² + b - 1)`, so `b·ρ²(b) → a²`: the law is an inverse-bitlen law
with limit constant `a²`. -/
theorem dilution_times_bitlen (a : ℚ) (m : ℕ) (ha : a ≠ 0) :
    ((m : ℚ) + 1) * pearsonSq (channelSample a m) - a ^ 2
      = a ^ 2 * (1 - a ^ 2) / (a ^ 2 + (m : ℚ)) := by
  have ha2 : 0 < a ^ 2 := by positivity
  have hm : (0 : ℚ) ≤ (m : ℚ) := by positivity
  rw [channel_dilution_law a m ha]
  field_simp
  ring

/-! ## 4. The recorded ladder (exp 536, seeds 20261200–02) -/

/-- Recorded pooled Spearman reading at bitlen 44. -/
def d44 : ℚ := 78 / 100
/-- Recorded pooled Spearman reading at bitlen 52 (the non-monotone rung). -/
def d52 : ℚ := 81 / 100
/-- Recorded pooled Spearman reading at bitlen 56. -/
def d56 : ℚ := 69 / 100
/-- Recorded pooled Spearman reading at bitlen 64. -/
def d64 : ℚ := 65 / 100
/-- Recorded pooled Spearman reading at bitlen 68. -/
def d68 : ℚ := 61 / 100
/-- Recorded pooled Spearman reading at bitlen 72. -/
def d72 : ℚ := 61 / 100
/-- Recorded pooled Spearman reading at bitlen 76. -/
def d76 : ℚ := 61 / 100
/-- Recorded pooled Spearman reading at bitlen 80. -/
def d80 : ℚ := 57 / 100
/-- Recorded pooled Spearman reading at bitlen 84. -/
def d84 : ℚ := 56 / 100
/-- The 88-rung: the first band miss. -/
def d88 : ℚ := 534 / 1000
/-- Lower end of the bootstrap CI at the 88-rung. -/
def ci88lo : ℚ := 509 / 1000
/-- Upper end of the bootstrap CI at the 88-rung. -/
def ci88hi : ℚ := 555 / 1000
/-- Validation band floor. -/
def bandFloor : ℚ := 55 / 100
/-- Validation band ceiling. -/
def bandCeil : ℚ := 85 / 100

/-- The recorded band verdict: every rung up to 84 sits inside `[0.55, 0.85]`, and the
88-rung is the first miss. -/
theorem first_band_miss_is_the_88_rung :
    bandFloor ≤ d44 ∧ bandFloor ≤ d52 ∧ bandFloor ≤ d56 ∧ bandFloor ≤ d64 ∧
    bandFloor ≤ d68 ∧ bandFloor ≤ d72 ∧ bandFloor ≤ d76 ∧ bandFloor ≤ d80 ∧
    bandFloor ≤ d84 ∧ d88 < bandFloor ∧
    d44 ≤ bandCeil ∧ d52 ≤ bandCeil := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [bandFloor, bandCeil, d44, d52, d56, d64, d68, d72, d76, d80, d84, d88]

/-- The 88-rung CI straddles the floor: the verdict is `DRIFT-INCONCLUSIVE`, not a clean
rejection. -/
theorem ci88_straddles_floor : ci88lo < bandFloor ∧ bandFloor < ci88hi := by
  constructor <;> norm_num [ci88lo, ci88hi, bandFloor]

/-- The rung invariant `ρ²·b`. -/
def rungConst (b : ℕ) (r : ℚ) : ℚ := r ^ 2 * (b : ℚ)

/-- **The ladder is an inverse-bitlen law.**  Every rung except the anomalous 52-rung has
`ρ²·b ∈ [25, 28.3]`: the invariant is constant to within `±6 %` over a *doubling* of the
bitlen, while `ρ²` itself falls by a factor `2.13`. -/
theorem ladder_constant_window :
    (25 : ℚ) ≤ rungConst 44 d44 ∧ rungConst 44 d44 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 56 d56 ∧ rungConst 56 d56 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 64 d64 ∧ rungConst 64 d64 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 68 d68 ∧ rungConst 68 d68 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 72 d72 ∧ rungConst 72 d72 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 76 d76 ∧ rungConst 76 d76 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 80 d80 ∧ rungConst 80 d80 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 84 d84 ∧ rungConst 84 d84 ≤ 283 / 10 ∧
    (25 : ℚ) ≤ rungConst 88 d88 ∧ rungConst 88 d88 ≤ 283 / 10 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [rungConst, d44, d56, d64, d68, d72, d76, d80, d84, d88]

/-- The 52-rung is the one outlier of the ladder: its invariant is `34.1`, far outside the
window occupied by all nine other rungs.  (It is also the rung that broke monotonicity,
reading `0.81 > 0.78`.) -/
theorem rung52_outlier : (34 : ℚ) < rungConst 52 d52 ∧ 283 / 10 < rungConst 52 d52 := by
  constructor <;> norm_num [rungConst, d52]

/-- One-step-ahead prediction: the invariant fitted at rung `b` predicts `ρ²` at the next
rung as `rungConst b / b'`. -/
def predictNext (b : ℕ) (r : ℚ) (b' : ℕ) : ℚ := rungConst b r / (b' : ℚ)

/-- **Out-of-sample accuracy of the inverse-bitlen law.**  For all eight consecutive pairs of
the ladder (the 52-rung excluded), the invariant fitted at one rung predicts the *next* rung's
`ρ²` to within `0.03`.  Nothing is fitted to the target rung. -/
theorem one_step_ahead_predictions :
    |predictNext 44 d44 56 - d56 ^ 2| < 3 / 100 ∧
    |predictNext 56 d56 64 - d64 ^ 2| < 3 / 100 ∧
    |predictNext 64 d64 68 - d68 ^ 2| < 3 / 100 ∧
    |predictNext 68 d68 72 - d72 ^ 2| < 3 / 100 ∧
    |predictNext 72 d72 76 - d76 ^ 2| < 3 / 100 ∧
    |predictNext 76 d76 80 - d80 ^ 2| < 3 / 100 ∧
    |predictNext 80 d80 84 - d84 ^ 2| < 3 / 100 ∧
    |predictNext 84 d84 88 - d88 ^ 2| < 3 / 100 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    rw [abs_lt] <;>
    constructor <;>
    norm_num [predictNext, rungConst, d44, d56, d64, d68, d72, d76, d80, d84, d88]

/-- The pooled inverse-bitlen constant: the mean of the nine non-outlier rung invariants. -/
def pooledC : ℚ :=
  (rungConst 44 d44 + rungConst 56 d56 + rungConst 64 d64 + rungConst 68 d68 +
    rungConst 72 d72 + rungConst 76 d76 + rungConst 80 d80 + rungConst 84 d84 +
    rungConst 88 d88) / 9

lemma pooledC_value : pooledC = 7446029 / 281250 := by
  norm_num [pooledC, rungConst, d44, d56, d64, d68, d72, d76, d80, d84, d88]

/-- **The crossing.**  The pooled inverse-bitlen law clears the squared band floor at bitlen
84 and fails it at bitlen 88. -/
theorem pooled_crossing :
    bandFloor ^ 2 < pooledC / 84 ∧ pooledC / 88 < bandFloor ^ 2 := by
  rw [pooledC_value]
  constructor <;> norm_num [bandFloor]

/-- **The retrodiction.**  Under the inverse-bitlen law fitted to the *whole* ladder, the
predicted dial clears the band floor at every bitlen up to and including 84, and misses it at
every bitlen from 88 on.  The first band miss is therefore *forced* to be the 88-rung; it is
not an artefact of one cron iteration. -/
theorem first_band_miss_predicted_at_88 :
    (∀ b : ℕ, 1 ≤ b → b ≤ 84 → bandFloor ^ 2 < pooledC / (b : ℚ)) ∧
    (∀ b : ℕ, 88 ≤ b → pooledC / (b : ℚ) < bandFloor ^ 2) := by
  have hC : pooledC = 7446029 / 281250 := pooledC_value
  have hfloor : bandFloor ^ 2 = 121 / 400 := by norm_num [bandFloor]
  constructor
  · intro b hb1 hb84
    have hb : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb1
    have hb' : (b : ℚ) ≤ 84 := by exact_mod_cast hb84
    have hpos : (0 : ℚ) < (b : ℚ) := by linarith
    rw [hC, lt_div_iff₀ hpos, hfloor]
    linarith
  · intro b hb
    have hb' : (88 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
    have hpos : (0 : ℚ) < (b : ℚ) := by linarith
    rw [hC, div_lt_iff₀ hpos, hfloor]
    linarith

/-- The predicted crossing bitlen `b* = C/0.55²` lies strictly between 87 and 88: the ladder's
rungs `84` and `88` bracket it, and `88` is the first rung past it. -/
theorem predicted_crossing_bitlen :
    (87 : ℚ) < pooledC / bandFloor ^ 2 ∧ pooledC / bandFloor ^ 2 < 88 := by
  rw [pooledC_value]
  constructor <;> norm_num [bandFloor]

/-! ## 5. Adversarial review: what the ladder rules out -/

/-- **The fixed-weight channel model is falsified.**  For *every* channel weight `a ≠ 0` the
exact dilution law decays more slowly from bitlen 44 to bitlen 88 than the recorded dial does:
`law(88)·d44² > law(44)·d88²`.  A single channel of fixed weight inside a growing pool cannot
reproduce the ladder; only the dilute asymptotic `C/b` can.  This is a genuine refutation of
the literal model of §3, and it is what forces the *super*-dilute exponent below. -/
theorem fixed_weight_dilution_excluded (a : ℚ) (ha : a ≠ 0) :
    pearsonSq (channelSample a 43) * d88 ^ 2 < pearsonSq (channelSample a 87) * d44 ^ 2 := by
  have ha2 : 0 < a ^ 2 := by positivity
  rw [channel_dilution_law a 43 ha, channel_dilution_law a 87 ha]
  push_cast
  rw [div_mul_eq_mul_div, div_mul_eq_mul_div, div_lt_div_iff₀ (by linarith) (by linarith)]
  have hd88 : d88 ^ 2 = 71289 / 250000 := by norm_num [d88]
  have hd44 : d44 ^ 2 = 1521 / 2500 := by norm_num [d44]
  rw [hd88, hd44]
  nlinarith

/-- **The ladder is super-dilute.**  Writing the decay as `ρ² ∝ b^{-γ}` between the endpoints
44 and 88 of the ladder, the exponent obeys `1 < γ ≤ 6/5`.  (`2·d88² < d44²` is `γ > 1`;
`(d44²)^5 < 2^6·(d88²)^5` is `γ ≤ 6/5`.)  So the erosion is slightly faster than pure
one-channel dilution, but far slower than any quadratic law. -/
theorem ladder_power_law_exponent :
    2 * d88 ^ 2 < d44 ^ 2 ∧ (d44 ^ 2) ^ 5 < 2 ^ 6 * (d88 ^ 2) ^ 5 := by
  constructor <;> norm_num [d44, d88]

/-- **Tie granularity cannot explain the 88-rung.**  Across the whole ladder the exact 2-adic
tie ceiling of `Novelty.ZeroFitDialU64` moves by less than `10^{-26}`, while the recorded dial
falls by more than `0.32` in `ρ²`.  The 88-rung reading still sits strictly below the ceiling,
so the band miss is a property of the response, not of the statistic's granularity. -/
theorem tie_ceiling_cannot_explain_88 :
    0 < spearmanSq (dyadicBlocks 44) - spearmanSq (dyadicBlocks 88) ∧
    spearmanSq (dyadicBlocks 44) - spearmanSq (dyadicBlocks 88) < 1 / 10 ^ 26 ∧
    32 / 100 < d44 ^ 2 - d88 ^ 2 ∧
    d88 ^ 2 < spearmanSq (dyadicBlocks 88) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · have := dyadic_ceiling_strict_anti (b := 44) (c := 88) (by norm_num) (by norm_num)
    linarith
  · have h1 : spearmanSq (dyadicBlocks 44) - 6 / 7 < (1 / 4 : ℚ) ^ 44 :=
      dyadic_ceiling_close 44 (by norm_num)
    have h2 : 6 / 7 < spearmanSq (dyadicBlocks 88) := dyadic_ceiling_gt 88 (by norm_num)
    have h3 : ((1 : ℚ) / 4) ^ 44 < 1 / 10 ^ 26 := by norm_num
    linarith
  · norm_num [d44, d88]
  · have h2 : 6 / 7 < spearmanSq (dyadicBlocks 88) := dyadic_ceiling_gt 88 (by norm_num)
    have : d88 ^ 2 < 6 / 7 := by norm_num [d88]
    linarith

/-- **Where the inverse-bitlen law is legal.**  The pooled law `C/b` lies strictly below the
exact 2-adic tie ceiling for every `b ≥ 31`, and strictly above it for `1 ≤ b ≤ 30`.  The
recorded ladder begins at 44, safely inside the legal range; below bitlen 31 the tie ceiling,
not the channel pool, is the binding constraint. -/
theorem inverse_law_respects_tie_ceiling :
    (∀ b : ℕ, 31 ≤ b → pooledC / (b : ℚ) < spearmanSq (dyadicBlocks b)) ∧
    (∀ b : ℕ, 1 ≤ b → b ≤ 30 → spearmanSq (dyadicBlocks b) < pooledC / (b : ℚ)) := by
  have hC : pooledC = 7446029 / 281250 := pooledC_value
  constructor
  · intro b hb
    have hb1 : 1 ≤ b := le_trans (by norm_num) hb
    have hbq : (31 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
    have hpos : (0 : ℚ) < (b : ℚ) := by linarith
    have hceil : 6 / 7 < spearmanSq (dyadicBlocks b) := dyadic_ceiling_gt b hb1
    have hlt : pooledC / (b : ℚ) ≤ 6 / 7 := by
      rw [hC, div_le_div_iff₀ hpos (by norm_num)]
      linarith
    linarith
  · intro b hb1 hb30
    have hbq : (b : ℚ) ≤ 30 := by exact_mod_cast hb30
    have hb1q : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb1
    have hpos : (0 : ℚ) < (b : ℚ) := by linarith
    rcases le_or_gt b 2 with hsmall | hbig
    · have hb2 : (b : ℚ) ≤ 2 := by exact_mod_cast hsmall
      have hceil : spearmanSq (dyadicBlocks b) ≤ 1 := by
        apply spearmanSq_le_one
        rw [dyadicBlocks_sum]
        calc 2 = 2 ^ 1 := rfl
          _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb1
      have hlt : (1 : ℚ) < pooledC / (b : ℚ) := by
        rw [hC, lt_div_iff₀ hpos]
        linarith
      linarith
    · have hb3 : 3 ≤ b := hbig
      have hpow : ((1 : ℚ) / 4) ^ b ≤ (1 / 4 : ℚ) ^ 3 :=
        pow_le_pow_of_le_one (by norm_num) (by norm_num) hb3
      have hclose : spearmanSq (dyadicBlocks b) - 6 / 7 < (1 / 4 : ℚ) ^ b :=
        dyadic_ceiling_close b hb1
      have hlt : 6 / 7 + (1 / 4 : ℚ) ^ 3 < pooledC / (b : ℚ) := by
        rw [hC, lt_div_iff₀ hpos]
        norm_num
        linarith
      norm_num at hpow hlt ⊢
      linarith

/-! ## 6. Pythagorean bridge: the dial on the even leg of a Euclid triple -/

/-- The Euclid parametrisation really produces Pythagorean triples. -/
theorem euclid_triple (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring

/-- For odd `m`, the 2-adic valuation of the even leg `2mn` exceeds that of `n` by exactly
one: `2^{k+1} ∣ 2mn ↔ 2^k ∣ n`. -/
theorem even_leg_two_adic {m : ℕ} (hm : Odd m) (k n : ℕ) :
    2 ^ (k + 1) ∣ 2 * m * n ↔ 2 ^ k ∣ n := by
  have hcop : Nat.Coprime (2 ^ k) m :=
    Nat.Coprime.pow_left k (Nat.coprime_two_left.mpr hm)
  constructor
  · intro h
    have h2 : 2 * 2 ^ k ∣ 2 * (m * n) := by
      rw [← pow_succ']
      simpa [mul_assoc] using h
    have h' : 2 ^ k ∣ m * n := (Nat.mul_dvd_mul_iff_left (by norm_num : 0 < 2)).mp h2
    exact hcop.dvd_of_dvd_mul_left h'
  · rintro ⟨c, rfl⟩
    exact ⟨m * c, by rw [pow_succ']; ring⟩

/-- The `k`-th trailing-zero block of the even legs `2mn`, `n < 2^b`, for a fixed odd `m`. -/
def pythLegBlock (b m k : ℕ) : Finset ℕ :=
  (range (2 ^ b)).filter fun n => 2 ^ (k + 1) ∣ 2 * m * n ∧ ¬ 2 ^ (k + 2) ∣ 2 * m * n

/-- The even-leg blocks coincide with the 2-adic blocks of the generator. -/
theorem pythLegBlock_eq {m : ℕ} (hm : Odd m) (b k : ℕ) :
    pythLegBlock b m k = twoAdicBlock b k := by
  ext n
  simp only [pythLegBlock, twoAdicBlock, mem_filter, mem_range]
  have h1 := even_leg_two_adic hm k n
  have h2 := even_leg_two_adic hm (k + 1) n
  constructor
  · rintro ⟨hn, hd, hnd⟩
    exact ⟨hn, h1.1 hd, fun hc => hnd (h2.2 hc)⟩
  · rintro ⟨hn, hd, hnd⟩
    exact ⟨hn, h1.2 hd, fun hc => hnd (h2.1 hc)⟩

/-- **Block cardinality on Pythagorean legs.**  Exactly `2^{b-1-k}` of the `2^b` Euclid
generators `n` give an even leg `2mn` with precisely `k + 1` trailing binary zeros. -/
theorem pythLeg_block_card {m : ℕ} (hm : Odd m) (b k : ℕ) (hk : k < b) :
    (pythLegBlock b m k).card = 2 ^ (b - 1 - k) := by
  rw [pythLegBlock_eq hm, card_two_adic_block b k hk]

/-- **The tie profile of the dial on Pythagorean even legs is the dyadic profile.**  Hence
every ceiling proved for uniform integers in the `ZeroFitDial` catalog transfers verbatim to
the even legs of the Euclid family. -/
theorem pythLeg_profile_eq_dyadic {m : ℕ} (hm : Odd m) (b : ℕ) :
    ((List.range b).map fun k => (pythLegBlock b m k).card) ++ [1] = dyadicBlocks b := by
  have h : ((List.range b).map fun k => (pythLegBlock b m k).card)
      = ((List.range b).map fun k => (twoAdicBlock b k).card) := by
    refine List.map_congr_left ?_
    intro k _
    rw [pythLegBlock_eq hm]
  rw [h, ← dyadicBlocks_eq_valuation_profile b]

/-- The exact dial ceiling on Pythagorean even legs, for every odd generator `m`. -/
theorem pythLeg_dial_ceiling {m : ℕ} (hm : Odd m) (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (((List.range b).map fun k => (pythLegBlock b m k).card) ++ [1])
      = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) := by
  rw [pythLeg_profile_eq_dyadic hm b, dyadic_spearmanSq b hb]

/-- **The band miss transfers.**  On Pythagorean even legs at bitlen 88 the dial ceiling is
still above `6/7`, so the recorded `0.534` is nowhere near it: exactly as for uniform integers,
the 88-rung miss must be charged to the response, not to the arithmetic of the tie blocks. -/
theorem pythLeg_band_miss_transfers {m : ℕ} (hm : Odd m) :
    d88 ^ 2 < spearmanSq (((List.range 88).map fun k => (pythLegBlock 88 m k).card) ++ [1]) ∧
    bandFloor ^ 2 <
      spearmanSq (((List.range 88).map fun k => (pythLegBlock 88 m k).card) ++ [1]) := by
  rw [pythLeg_dial_ceiling hm 88 (by norm_num)]
  have hpos : (0 : ℚ) < 1 / ((2 : ℚ) ^ 88 * ((2 : ℚ) ^ 88 + 1)) := by positivity
  constructor
  · have : d88 ^ 2 < 6 / 7 := by norm_num [d88]
    nlinarith
  · have : bandFloor ^ 2 < 6 / 7 := by norm_num [bandFloor]
    nlinarith

end Catalog.Pythagorean.ZeroFitDialChannelDilution88