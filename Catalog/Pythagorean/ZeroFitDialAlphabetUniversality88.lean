import Mathlib
import Pythagorean.ZeroFitDialChannelDilution88

/-!
# Alphabet universality of the channel-dilution law (FACT round-68 #1, exp 536)

## Research context

`Pythagorean.ZeroFitDialChannelDilution88` established the *channel-dilution law* for the
zero-fit dial: if the response is a weighted sum of `b = m+1` independent **binary** channels,
one of which is the dial's own statistic carried with weight `a`, then exactly

```
ρ² = a² / (a² + m).
```

That model was binary because the recorded ladder is indexed by *bitlen*.  A natural objection
to the whole "channel" reading of the ladder is that the alphabet is an arbitrary modelling
choice: maybe widening the per-coordinate alphabet (bytes, limbs, residues mod `q`) changes the
dilution rate and thereby explains the excess erosion that
`fixed_weight_dilution_excluded` found at the 88-rung.

This file kills that objection.  We build the exact `q`-ary channel sample — the full
`q^{m+1}`-point product of one dial digit with `m` independent uniform digits from
`{0, …, q-1}` — compute its first two moments in closed form, and prove that its squared
Pearson correlation is *the same rational number* `a²/(a²+m)` **for every alphabet size
`q ≥ 2`**.  Dilution counts channels, not symbols.

## Main results

* `csum_val`, `csq_val` — closed forms for the first two moments of the sum of `m` i.i.d.
  uniform `q`-ary digits, `Σw = q^m·m·(q-1)/2` and
  `12·Σw² = q^m·(m(q²-1) + 3m²(q-1)²)`, both by induction on `m` from a `flatMap` recursion.
* `qary_varX`, `qary_covXY`, `qary_varY` — the three determinant-form moments of the `q`-ary
  channel sample collapse to `V`, `a·V`, `(a²+m)·V` for the single scale
  `V = q^{2m}·q²(q²-1)/12`.
* `qary_dilution_law` — **the payload**: `ρ²(q-ary sample) = a²/(a²+m)` for all `q ≥ 2`.
* `alphabet_universality` — the correlation is literally independent of the alphabet size.
* `qary_agrees_with_binary` — the `q`-ary law restricts to the binary law of the previous file.
* `qary_dilution_excluded` — consequently **no** alphabet size rescues the fixed-weight channel
  model: for every `q ≥ 2` and every weight `a ≠ 0` the model decays too slowly between
  bitlen 44 and 88 to reproduce the recorded ladder.
* `dilution_reciprocal_additive`, `dilution_unique` — the structural characterisation:
  `1/ρ² - 1` is additive in the channel count, and that additivity plus the one-channel value
  *forces* the dilution law.  So the law is not a fitted curve, it is the unique solution of a
  functional equation.
* `channel_budget_superadditive` — the recorded ladder violates that additivity: the measured
  reciprocal excess at bitlen 88 is more than `87/43` times the one at bitlen 44.  This is the
  reciprocal-scale statement of the 88-rung anomaly.
-/

namespace Catalog.Pythagorean.ZeroFitDialAlphabetUniversality88

open Catalog.Pythagorean.ZeroFitDialChannelDilution88

/-! ## 1. The `q`-ary digit alphabet and the `m`-fold channel sum -/

/-- The alphabet `{0, 1, …, q-1}` as a list of rationals. -/
def digitsQ (q : ℕ) : List ℚ := (List.range q).map (fun t : ℕ => (t : ℚ))

/-- The multiset (as a list) of values of a sum of `m` i.i.d. uniform `q`-ary digits, listed
with multiplicity: `q^m` entries. -/
def chan (q : ℕ) : ℕ → List ℚ
  | 0 => [0]
  | (m + 1) => (chan q m).flatMap (fun w => (digitsQ q).map (fun d => w + d))

lemma digitsQ_succ (q : ℕ) : digitsQ (q + 1) = digitsQ q ++ [(q : ℚ)] := by
  simp [digitsQ, List.range_succ]

@[simp] lemma digitsQ_length (q : ℕ) : (digitsQ q).length = q := by simp [digitsQ]

@[simp] lemma chan_length (q m : ℕ) : (chan q m).length = q ^ m := by
  induction m with
  | zero => simp [chan]
  | succ m ih => simp [chan, List.length_flatMap, ih, pow_succ]

/-! ## 2. Summation calculus for the `flatMap` recursion -/

lemma sum_flatMap_map (L D : List ℚ) (f : ℚ → ℚ) :
    ((L.flatMap (fun w => D.map (fun d => w + d))).map f).sum
      = (L.map (fun w => (D.map (fun d => f (w + d))).sum)).sum := by
  induction L with
  | nil => simp
  | cons x xs ih => simp [List.flatMap_cons, ih, List.map_map, Function.comp_def]

lemma sum_map_const_val (L : List ℚ) (c : ℚ) :
    (L.map (fun _ => c)).sum = (L.length : ℚ) * c := by
  induction L with
  | nil => simp
  | cons x xs ih => simp only [List.map_cons, List.sum_cons, ih, List.length_cons]; push_cast; ring

lemma sum_map_add_const (L : List ℚ) (c : ℚ) :
    (L.map (fun d => c + d)).sum = (L.length : ℚ) * c + L.sum := by
  induction L with
  | nil => simp
  | cons x xs ih => simp only [List.map_cons, List.sum_cons, ih, List.length_cons]; push_cast; ring

lemma sum_map_add_const_sq (L : List ℚ) (c : ℚ) :
    (L.map (fun d => (c + d) ^ 2)).sum
      = (L.length : ℚ) * c ^ 2 + 2 * c * L.sum + (L.map (fun d => d ^ 2)).sum := by
  induction L with
  | nil => simp
  | cons x xs ih => simp only [List.map_cons, List.sum_cons, ih, List.length_cons]; push_cast; ring

lemma sum_map_lin (L : List ℚ) (be ga : ℚ) :
    (L.map (fun w => be * w + ga)).sum = be * L.sum + (L.length : ℚ) * ga := by
  induction L with
  | nil => simp
  | cons x xs ih => simp only [List.map_cons, List.sum_cons, ih, List.length_cons]; push_cast; ring

lemma sum_map_quad (L : List ℚ) (al be ga : ℚ) :
    (L.map (fun d => al * d ^ 2 + be * d + ga)).sum
      = al * (L.map (fun d => d ^ 2)).sum + be * L.sum + (L.length : ℚ) * ga := by
  induction L with
  | nil => simp
  | cons x xs ih => simp only [List.map_cons, List.sum_cons, ih, List.length_cons]; push_cast; ring

/-! ## 3. Moments of the alphabet and of the `m`-fold channel sum -/

/-- `Σ d` over the alphabet. -/
def dsum (q : ℕ) : ℚ := (digitsQ q).sum

/-- `Σ d²` over the alphabet. -/
def dsq (q : ℕ) : ℚ := ((digitsQ q).map (fun d => d ^ 2)).sum

/-- `Σ w` over the `m`-fold channel sum. -/
def csum (q m : ℕ) : ℚ := (chan q m).sum

/-- `Σ w²` over the `m`-fold channel sum. -/
def csq (q m : ℕ) : ℚ := ((chan q m).map (fun w => w ^ 2)).sum

lemma dsum_val (q : ℕ) : dsum q = (q : ℚ) * ((q : ℚ) - 1) / 2 := by
  have h : 2 * dsum q = (q : ℚ) * ((q : ℚ) - 1) := by
    induction q with
    | zero => simp [dsum, digitsQ]
    | succ q ih =>
        simp only [dsum, digitsQ_succ, List.sum_append, List.sum_cons, List.sum_nil] at *
        push_cast
        linarith
  linarith

lemma dsq_val (q : ℕ) : dsq q = (q : ℚ) * ((q : ℚ) - 1) * (2 * (q : ℚ) - 1) / 6 := by
  have h : 6 * dsq q = (q : ℚ) * ((q : ℚ) - 1) * (2 * (q : ℚ) - 1) := by
    induction q with
    | zero => simp [dsq, digitsQ]
    | succ q ih =>
        simp only [dsq, digitsQ_succ, List.map_append, List.sum_append, List.map_cons,
          List.sum_cons, List.map_nil, List.sum_nil] at *
        push_cast
        nlinarith [ih]
  linarith

lemma csum_succ (q m : ℕ) : csum q (m + 1) = (q : ℚ) * csum q m + ((q : ℚ) ^ m) * dsum q := by
  have h : csum q (m + 1)
      = ((chan q m).map (fun w => ((digitsQ q).map (fun d => w + d)).sum)).sum := by
    have := sum_flatMap_map (chan q m) (digitsQ q) (fun x => x)
    simpa [csum, chan] using this
  have h2 : ∀ w : ℚ, ((digitsQ q).map (fun d => w + d)).sum = (q : ℚ) * w + dsum q := by
    intro w
    rw [sum_map_add_const, digitsQ_length, dsum]
  rw [h]
  simp only [h2]
  rw [sum_map_lin, chan_length, csum]
  push_cast
  ring

lemma csq_succ (q m : ℕ) :
    csq q (m + 1) = (q : ℚ) * csq q m + 2 * dsum q * csum q m + ((q : ℚ) ^ m) * dsq q := by
  have h : csq q (m + 1)
      = ((chan q m).map (fun w => ((digitsQ q).map (fun d => (w + d) ^ 2)).sum)).sum := by
    have := sum_flatMap_map (chan q m) (digitsQ q) (fun x => x ^ 2)
    simpa [csq, chan] using this
  have h2 : ∀ w : ℚ, ((digitsQ q).map (fun d => (w + d) ^ 2)).sum
      = (q : ℚ) * w ^ 2 + (2 * dsum q) * w + dsq q := by
    intro w
    rw [sum_map_add_const_sq, digitsQ_length, dsum, dsq]; ring
  rw [h]
  simp only [h2]
  rw [sum_map_quad, chan_length, csq, csum]
  push_cast
  ring

/-- First moment of a sum of `m` i.i.d. uniform `q`-ary digits. -/
lemma csum_val (q m : ℕ) : csum q m = ((q : ℚ) ^ m) * (m : ℚ) * ((q : ℚ) - 1) / 2 := by
  induction m with
  | zero => simp [csum, chan]
  | succ m ih =>
      rw [csum_succ, ih, dsum_val]
      push_cast
      ring

/-- Second moment of a sum of `m` i.i.d. uniform `q`-ary digits. -/
lemma csq_val (q m : ℕ) :
    csq q m = ((q : ℚ) ^ m) * ((m : ℚ) * ((q : ℚ) ^ 2 - 1) + 3 * (m : ℚ) ^ 2 * ((q : ℚ) - 1) ^ 2)
      / 12 := by
  induction m with
  | zero => simp [csq, chan]
  | succ m ih =>
      rw [csq_succ, ih, csum_val, dsum_val, dsq_val]
      push_cast
      ring

/-! ## 4. The `q`-ary channel sample and its determinant-form moments -/

/-- The `q`-ary channel sample: the predictor is the dial's own `q`-ary digit, the response is
that digit carried with weight `a` plus the sum of `m` further independent uniform `q`-ary
channels.  All `q^{m+1}` equally likely configurations are listed. -/
def qSample (q : ℕ) (a : ℚ) (m : ℕ) : List (ℚ × ℚ) :=
  (digitsQ q).flatMap (fun d => (chan q m).map (fun w => (d, a * d + w)))

lemma lsum_qSample (q : ℕ) (a : ℚ) (m : ℕ) (f : ℚ × ℚ → ℚ) :
    lsum (qSample q a m) f
      = ((digitsQ q).map (fun d => ((chan q m).map (fun w => f (d, a * d + w))).sum)).sum := by
  unfold lsum qSample
  induction (digitsQ q) with
  | nil => simp
  | cons x xs ih => simp [List.flatMap_cons, ih, List.map_map, Function.comp_def]

@[simp] lemma qSample_length (q : ℕ) (a : ℚ) (m : ℕ) :
    sampleN (qSample q a m) = (q : ℚ) ^ (m + 1) := by
  unfold sampleN qSample
  simp [List.length_flatMap, pow_succ]
  ring

lemma qs_x (q : ℕ) (a : ℚ) (m : ℕ) :
    lsum (qSample q a m) Prod.fst = ((q : ℚ) ^ m) * dsum q := by
  rw [lsum_qSample]
  have h : ∀ d : ℚ, ((chan q m).map (fun w => (d, a * d + w).1)).sum = ((q : ℚ) ^ m) * d := by
    intro d; rw [show (fun w : ℚ => (d, a * d + w).1) = (fun _ : ℚ => d) from rfl,
      sum_map_const_val, chan_length]; push_cast; ring
  simp only [h]
  rw [show (fun d : ℚ => ((q : ℚ) ^ m) * d) = (fun d : ℚ => 0 * d ^ 2 + ((q : ℚ) ^ m) * d + 0) by
    funext d; ring, sum_map_quad, dsum]
  ring

lemma qs_x2 (q : ℕ) (a : ℚ) (m : ℕ) :
    lsum (qSample q a m) (fun p => p.1 ^ 2) = ((q : ℚ) ^ m) * dsq q := by
  rw [lsum_qSample]
  have h : ∀ d : ℚ, ((chan q m).map (fun w => (d, a * d + w).1 ^ 2)).sum
      = ((q : ℚ) ^ m) * d ^ 2 := by
    intro d; rw [show (fun w : ℚ => (d, a * d + w).1 ^ 2) = (fun _ : ℚ => d ^ 2) from rfl,
      sum_map_const_val, chan_length]; push_cast; ring
  simp only [h]
  rw [show (fun d : ℚ => ((q : ℚ) ^ m) * d ^ 2)
      = (fun d : ℚ => ((q : ℚ) ^ m) * d ^ 2 + 0 * d + 0) by funext d; ring,
    sum_map_quad, dsq]
  ring

lemma qs_y (q : ℕ) (a : ℚ) (m : ℕ) :
    lsum (qSample q a m) Prod.snd = ((q : ℚ) ^ m) * a * dsum q + (q : ℚ) * csum q m := by
  rw [lsum_qSample]
  have h : ∀ d : ℚ, ((chan q m).map (fun w => (d, a * d + w).2)).sum
      = ((q : ℚ) ^ m * a) * d + csum q m := by
    intro d
    rw [show (fun w : ℚ => (d, a * d + w).2) = (fun w : ℚ => a * d + w) from rfl,
      sum_map_add_const, chan_length, csum]
    push_cast; ring
  simp only [h]
  rw [show (fun d : ℚ => ((q : ℚ) ^ m * a) * d + csum q m)
      = (fun d : ℚ => 0 * d ^ 2 + ((q : ℚ) ^ m * a) * d + csum q m) by funext d; ring,
    sum_map_quad, dsum, digitsQ_length]
  ring

lemma qs_xy (q : ℕ) (a : ℚ) (m : ℕ) :
    lsum (qSample q a m) (fun p => p.1 * p.2)
      = ((q : ℚ) ^ m) * a * dsq q + dsum q * csum q m := by
  rw [lsum_qSample]
  have h : ∀ d : ℚ, ((chan q m).map (fun w => (d, a * d + w).1 * (d, a * d + w).2)).sum
      = ((q : ℚ) ^ m * a) * d ^ 2 + (csum q m) * d := by
    intro d
    rw [show (fun w : ℚ => (d, a * d + w).1 * (d, a * d + w).2)
        = (fun w : ℚ => d * w + a * d ^ 2) by funext w; simp; ring,
      sum_map_lin, chan_length, csum]
    push_cast; ring
  simp only [h]
  rw [show (fun d : ℚ => ((q : ℚ) ^ m * a) * d ^ 2 + (csum q m) * d)
      = (fun d : ℚ => ((q : ℚ) ^ m * a) * d ^ 2 + (csum q m) * d + 0) by funext d; ring,
    sum_map_quad, dsq, dsum]
  ring

lemma qs_y2 (q : ℕ) (a : ℚ) (m : ℕ) :
    lsum (qSample q a m) (fun p => p.2 ^ 2)
      = ((q : ℚ) ^ m) * a ^ 2 * dsq q + 2 * a * dsum q * csum q m + (q : ℚ) * csq q m := by
  rw [lsum_qSample]
  have h : ∀ d : ℚ, ((chan q m).map (fun w => (d, a * d + w).2 ^ 2)).sum
      = ((q : ℚ) ^ m * a ^ 2) * d ^ 2 + (2 * a * csum q m) * d + csq q m := by
    intro d
    rw [show (fun w : ℚ => (d, a * d + w).2 ^ 2) = (fun w : ℚ => (a * d + w) ^ 2) from rfl,
      sum_map_add_const_sq, chan_length, csum, csq]
    push_cast; ring
  simp only [h]
  rw [sum_map_quad, dsq, dsum, digitsQ_length]
  ring

/-- The common scale of all three moments of the `q`-ary channel sample. -/
def Vscale (q m : ℕ) : ℚ := ((q : ℚ) ^ m) ^ 2 * (q : ℚ) ^ 2 * ((q : ℚ) ^ 2 - 1) / 12

lemma Vscale_pos {q : ℕ} (hq : 2 ≤ q) (m : ℕ) : 0 < Vscale q m := by
  have hq2 : (2 : ℚ) ≤ (q : ℚ) := by exact_mod_cast hq
  have h1 : (0 : ℚ) < (q : ℚ) ^ 2 - 1 := by nlinarith
  have h2 : (0 : ℚ) < ((q : ℚ) ^ m) ^ 2 := by positivity
  have h3 : (0 : ℚ) < (q : ℚ) ^ 2 := by nlinarith
  unfold Vscale
  positivity

lemma qary_varX (q : ℕ) (a : ℚ) (m : ℕ) : varX (qSample q a m) = Vscale q m := by
  unfold varX Vscale
  rw [qSample_length, qs_x2, qs_x, dsq_val, dsum_val, pow_succ]
  ring

lemma qary_covXY (q : ℕ) (a : ℚ) (m : ℕ) : covXY (qSample q a m) = a * Vscale q m := by
  unfold covXY Vscale
  rw [qSample_length, qs_xy, qs_x, qs_y, dsq_val, dsum_val, csum_val, pow_succ]
  ring

lemma qary_varY (q : ℕ) (a : ℚ) (m : ℕ) :
    varY (qSample q a m) = (a ^ 2 + (m : ℚ)) * Vscale q m := by
  unfold varY Vscale
  rw [qSample_length, qs_y2, qs_y, dsq_val, dsum_val, csum_val, csq_val, pow_succ]
  ring

/-! ## 5. The universality theorem -/

/-- **Alphabet-universal channel-dilution law.**  For every alphabet size `q ≥ 2`, every channel
weight `a ≠ 0` and every number `m` of competing channels, the squared Pearson correlation
between the dial's digit and the pooled response is exactly `a²/(a²+m)`.  The alphabet size has
cancelled completely. -/
theorem qary_dilution_law (q : ℕ) (hq : 2 ≤ q) (a : ℚ) (m : ℕ) (ha : a ≠ 0) :
    pearsonSq (qSample q a m) = a ^ 2 / (a ^ 2 + (m : ℚ)) := by
  have hV : (0 : ℚ) < Vscale q m := Vscale_pos hq m
  have hVne : Vscale q m ≠ 0 := ne_of_gt hV
  have ha2 : (0 : ℚ) < a ^ 2 := by positivity
  have hden : a ^ 2 + (m : ℚ) ≠ 0 := by positivity
  unfold pearsonSq
  rw [qary_varX, qary_covXY, qary_varY]
  field_simp

/-- The dilution rate does not depend on the alphabet: bytes, bits and residues mod `q` all give
the same squared correlation. -/
theorem alphabet_universality (q q' : ℕ) (hq : 2 ≤ q) (hq' : 2 ≤ q') (a : ℚ) (m : ℕ)
    (ha : a ≠ 0) : pearsonSq (qSample q a m) = pearsonSq (qSample q' a m) := by
  rw [qary_dilution_law q hq a m ha, qary_dilution_law q' hq' a m ha]

/-- The `q`-ary law restricts to the binary channel-dilution law of the previous file. -/
theorem qary_agrees_with_binary (a : ℚ) (m : ℕ) (ha : a ≠ 0) :
    pearsonSq (qSample 2 a m) = pearsonSq (channelSample a m) := by
  rw [qary_dilution_law 2 le_rfl a m ha, channel_dilution_law a m ha]

/-! ## 6. Consequence for the recorded ladder: no alphabet rescues the fixed-weight model -/

/-- **No alphabet size rescues the fixed-weight channel model.**  For every `q ≥ 2` and every
weight `a ≠ 0`, the exact `q`-ary dilution model decays strictly more slowly between bitlen 44
and bitlen 88 than the recorded dial does.  The 88-rung erosion is therefore not a
quantisation-width effect. -/
theorem qary_dilution_excluded (q : ℕ) (hq : 2 ≤ q) (a : ℚ) (ha : a ≠ 0) :
    pearsonSq (qSample q a 43) * d88 ^ 2 < pearsonSq (qSample q a 87) * d44 ^ 2 := by
  have h := fixed_weight_dilution_excluded a ha
  rw [channel_dilution_law a 43 ha, channel_dilution_law a 87 ha] at h
  rw [qary_dilution_law q hq a 43 ha, qary_dilution_law q hq a 87 ha]
  exact h

/-! ## 7. The functional equation that forces the dilution law -/

/-- The dilution profile as a function of the number of competing channels. -/
def dil (a : ℚ) (m : ℕ) : ℚ := a ^ 2 / (a ^ 2 + (m : ℚ))

lemma dil_pos {a : ℚ} (ha : a ≠ 0) (m : ℕ) : 0 < dil a m := by
  have ha2 : (0 : ℚ) < a ^ 2 := by positivity
  have : (0 : ℚ) < a ^ 2 + (m : ℚ) := by positivity
  unfold dil
  exact div_pos ha2 this

/-- **Additivity of the reciprocal excess.**  `1/ρ² - 1` is additive in the channel count: two
independent channel blocks contribute independent, additive amounts of dilution. -/
theorem dilution_reciprocal_additive (a : ℚ) (ha : a ≠ 0) (m n : ℕ) :
    1 / dil a (m + n) - 1 = (1 / dil a m - 1) + (1 / dil a n - 1) := by
  have ha2 : (a : ℚ) ^ 2 ≠ 0 := by positivity
  unfold dil
  rw [one_div_div, one_div_div, one_div_div]
  push_cast
  field_simp
  ring

/-- **Uniqueness.**  Any profile `f` that starts at `1` for zero channels, agrees with the
dilution law for one channel, and has additive reciprocal excess, *is* the dilution law.  The
inverse-channel-count shape is therefore forced, not fitted. -/
theorem dilution_unique (f : ℕ → ℚ) (a : ℚ) (ha : a ≠ 0)
    (h0 : f 0 = 1) (h1 : f 1 = a ^ 2 / (a ^ 2 + 1))
    (hadd : ∀ m n : ℕ, 1 / f (m + n) - 1 = (1 / f m - 1) + (1 / f n - 1)) :
    ∀ m : ℕ, f m = dil a m := by
  have ha2 : (0 : ℚ) < a ^ 2 := by positivity
  have h1' : 1 / f 1 = 1 + 1 / a ^ 2 := by
    rw [h1, one_div_div]
    field_simp
  have key : ∀ m : ℕ, 1 / f m = 1 + (m : ℚ) / a ^ 2 := by
    intro m
    induction m with
    | zero => simp [h0]
    | succ m ih =>
        have := hadd m 1
        rw [ih, h1'] at this
        have hsplit : ((m : ℚ) + 1) / a ^ 2 = (m : ℚ) / a ^ 2 + 1 / a ^ 2 := by
          field_simp
        push_cast
        linarith
  intro m
  have hfm : 1 / f m ≠ 0 := by
    rw [key m]
    have : (0 : ℚ) ≤ (m : ℚ) / a ^ 2 := by positivity
    linarith
  have hne : f m ≠ 0 := by
    intro h
    rw [h] at hfm
    simp at hfm
  have : f m = 1 / (1 + (m : ℚ) / a ^ 2) := by
    rw [← key m, one_div_one_div]
  rw [this]
  unfold dil
  field_simp

/-- **The recorded ladder is super-additive in channel budget.**  If the dial obeyed *any*
fixed-weight independent-channel model, the reciprocal excess `1/ρ² - 1` would grow exactly in
proportion to the number of competing channels, i.e. `e(88)·43 = e(44)·87`.  The measured values
give `e(88)·43 > e(44)·87` strictly: the effective channel pool grows faster than the bitlen. -/
theorem channel_budget_superadditive :
    (1 / d44 ^ 2 - 1) * 87 < (1 / d88 ^ 2 - 1) * 43 := by
  norm_num [d44, d88]

end Catalog.Pythagorean.ZeroFitDialAlphabetUniversality88