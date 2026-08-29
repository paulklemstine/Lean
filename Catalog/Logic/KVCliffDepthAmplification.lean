/-
# NET-92 cycle: depth amplification cannot make a cliff — the homogeneity obstruction

The NET-92 folklore explanation of the `q4_0` collapse is *error amplification through depth*:
"a small key error is multiplied through every softmax boundary of every layer".  This file
takes that explanation seriously enough to formalise it, and then shows that **it cannot be
the whole story**.

Model the propagation of a per-layer quantisation error `ε` through `L` layers with a linear
amplification factor `κ ≥ 1`:

`layerErr κ ε 0 = 0`,  `layerErr κ ε (L+1) = κ * layerErr κ ε L + ε`.

* `layerErr_closed` — the closed form `ε (κ^L − 1)/(κ − 1)` (geometric series, by induction);
* `layerErr_ge_pow` — the error really is exponential in depth, `ε κ^L ≤ layerErr κ ε (L+1)`;
* `layerErr_smul` — **and it is exactly homogeneous of degree one in `ε`**.

Homogeneity is the obstruction.  Going from `q8_0` to `q4_0` multiplies the raw per-tensor
step by `16`, so *any* degree-one (or sub-degree-one) error model multiplies the certified
damage by at most `16`, no matter how large `κ` or `L` are: `net92_refutes_subhomogeneous`.
NET-92 measured a factor `ln(2714.6042/7.1093) / ln(7.1162/7.1093) ≈ 6128` in excess
log-perplexity.  Hence:

> **The depth-amplification story, calibrated at 8 bits, under-predicts the 4-bit collapse by
> more than two orders of magnitude.  The cliff is a threshold phenomenon, not a gain.**

That is the same conclusion the gap-threshold files of the catalog
(`Algebra.KVCacheArgmaxThreshold`) reach from the mechanism side, obtained here from the
response-function side, and it upgrades `Algebra.KVCacheResponseExponent`'s NET-94 exponent
computation to the NET-92 numbers: the measured pair forces a response exponent `≥ 3`
(`net92_response_exponent_ge_three`), and with exponent `p ≥ 3` the whole free-to-annihilated
transition is confined to at most `4` bit widths (`transition_band_width_le`).
-/
import Mathlib
import Algebra.KVCacheResponseExponent

namespace Catalog.Logic.KVCliffDepth

open Real

/-! ## Linear error propagation through depth -/

/-- Worst-case logit error after `L` layers, when each layer amplifies the incoming error by
`κ` and injects a fresh quantisation error `ε`. -/
noncomputable def layerErr (kappa eps : ℝ) : ℕ → ℝ
  | 0 => 0
  | L + 1 => kappa * layerErr kappa eps L + eps

@[simp] lemma layerErr_zero (kappa eps : ℝ) : layerErr kappa eps 0 = 0 := rfl

@[simp] lemma layerErr_succ (kappa eps : ℝ) (L : ℕ) :
    layerErr kappa eps (L + 1) = kappa * layerErr kappa eps L + eps := rfl

/-- **Closed form.**  The propagated error is the geometric sum `ε (κ^L − 1)/(κ − 1)`. -/
theorem layerErr_closed {kappa : ℝ} (hk : kappa ≠ 1) (eps : ℝ) (L : ℕ) :
    layerErr kappa eps L = eps * (kappa ^ L - 1) / (kappa - 1) := by
  have hne : kappa - 1 ≠ 0 := sub_ne_zero.mpr hk
  induction L with
  | zero => simp
  | succ L ih =>
      rw [layerErr_succ, ih]
      field_simp
      ring

/-- Nonnegativity. -/
theorem layerErr_nonneg {kappa eps : ℝ} (hk : 0 ≤ kappa) (he : 0 ≤ eps) (L : ℕ) :
    0 ≤ layerErr kappa eps L := by
  induction L with
  | zero => simp
  | succ L ih => exact add_nonneg (mul_nonneg hk ih) he

/-- **The amplification is genuinely exponential in depth.** -/
theorem layerErr_ge_pow {kappa eps : ℝ} (hk : 0 ≤ kappa) (he : 0 ≤ eps) (L : ℕ) :
    eps * kappa ^ L ≤ layerErr kappa eps (L + 1) := by
  induction L with
  | zero => simp
  | succ L ih =>
      have hstep : kappa * (eps * kappa ^ L) ≤ kappa * layerErr kappa eps (L + 1) :=
        mul_le_mul_of_nonneg_left ih hk
      have : eps * kappa ^ (L + 1) = kappa * (eps * kappa ^ L) := by ring
      rw [layerErr_succ, this]
      linarith

/-- With `κ ≥ 1` the propagated error is at least `L` copies of the injected error: depth never
helps. -/
theorem layerErr_ge_linear {kappa eps : ℝ} (hk : 1 ≤ kappa) (he : 0 ≤ eps) (L : ℕ) :
    eps * L ≤ layerErr kappa eps L := by
  induction L with
  | zero => simp
  | succ L ih =>
      have h1 : layerErr kappa eps L ≤ kappa * layerErr kappa eps L := by
        nlinarith [layerErr_nonneg (le_trans zero_le_one hk) he L]
      push_cast
      rw [layerErr_succ]
      nlinarith

/-- **Homogeneity — the obstruction.**  Linear propagation is exactly degree one in the
injected error: scaling the quantisation step by `c` scales the propagated error by `c`,
for every amplification factor and every depth. -/
theorem layerErr_smul (kappa eps c : ℝ) (L : ℕ) :
    layerErr kappa (c * eps) L = c * layerErr kappa eps L := by
  induction L with
  | zero => simp
  | succ L ih =>
      rw [layerErr_succ, layerErr_succ, ih]
      ring

/-! ## The NET-92 numbers -/

/-- `e ^ 5 < 149`: the elementary numeric fact behind "the 4-bit arm lost more than five
nats of log-perplexity". -/
lemma exp_five_lt : Real.exp 5 < 149 := by
  have h : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
  have h5 : Real.exp 5 = Real.exp 1 ^ (5 : ℕ) := by
    rw [Real.exp_one_pow]; norm_num
  rw [h5]
  calc Real.exp 1 ^ (5 : ℕ) ≤ 2.7182818286 ^ (5 : ℕ) :=
        pow_le_pow_left₀ (Real.exp_pos 1).le h.le 5
    _ < 149 := by norm_num

/-- The measured NET-92 excess log-perplexity of the `q4_0` arm exceeds `5` nats:
`log (2714.6042 / 7.1093) > 5`. -/
theorem net92_excess_gt_five : 5 < Real.log (2714.6042 / 7.1093) := by
  have hexp : Real.exp 5 < 2714.6042 / 7.1093 := by
    have := exp_five_lt
    have h149 : (149:ℝ) < 2714.6042 / 7.1093 := by norm_num
    linarith
  have hpos : (0:ℝ) < 2714.6042 / 7.1093 := by norm_num
  exact (Real.lt_log_iff_exp_lt hpos).mpr hexp

/-- The measured NET-92 excess log-perplexity of the all-`q8_0` arm is below `1/1000` nats:
`log (7.1162 / 7.1093) < 1/1000`.  (`log x ≤ x − 1`.) -/
theorem net92_q8_excess_lt : Real.log (7.1162 / 7.1093) < 1 / 1000 := by
  have hpos : (0:ℝ) < 7.1162 / 7.1093 := by norm_num
  have hle : Real.log (7.1162 / 7.1093) ≤ 7.1162 / 7.1093 - 1 :=
    Real.log_le_sub_one_of_pos hpos
  have : (7.1162 : ℝ) / 7.1093 - 1 < 1 / 1000 := by norm_num
  linarith

/-- **The homogeneity obstruction, applied to NET-92.**  Let `D` be any damage response as a
function of the quantisation step which is *sub-homogeneous* — `D (c x) ≤ c D x` for `c ≥ 1`,
the behaviour of every linear-propagation model including `layerErr` at any depth and any
amplification factor.  Then `D` cannot simultaneously reproduce the 8-bit arm (excess below
`1/1000` nats) and the 4-bit arm (excess above `5` nats), because the step only grows by the
factor `16`. -/
theorem net92_refutes_subhomogeneous (D : ℝ → ℝ) (eps : ℝ) (heps : 0 ≤ eps)
    (hsub : ∀ c ≥ (1:ℝ), ∀ x ≥ (0:ℝ), D (c * x) ≤ c * D x)
    (h8 : D eps ≤ 1 / 1000) (h4 : 5 ≤ D (16 * eps)) : False := by
  have hkey : D (16 * eps) ≤ 16 * D eps := hsub 16 (by norm_num) eps heps
  linarith

/-- The concrete instance: the depth-amplification model itself, calibrated so that its
certified 8-bit excess matches the measurement, predicts at most `16/1000` nats of excess at
4 bits — three hundred times less than the `> 5` nats measured. -/
theorem depth_model_underpredicts_the_cliff (kappa eps : ℝ) (L : ℕ)
    (hcal : 2 * layerErr kappa eps L ≤ 1 / 1000) :
    2 * layerErr kappa (16 * eps) L ≤ 16 / 1000 ∧ 2 * layerErr kappa (16 * eps) L < 5 := by
  have hhom : layerErr kappa (16 * eps) L = 16 * layerErr kappa eps L := layerErr_smul _ _ _ _
  constructor
  · rw [hhom]; linarith
  · rw [hhom]; linarith

/-! ## What the data do force: a response exponent at least three -/

/-- **The NET-92 exponent.**  If the excess log-perplexity follows a power law
`D(x) = C x ^ p` in the quantisation step `x`, then the two measured arms force `p > 3`:
sixteen times the step must multiply the damage by more than `4096`.  (Compare
`Algebra.KVCacheResponseExponent.net94_forces_quintic_key_response`, the analogous
computation for the NET-94 bracket.) -/
theorem net92_response_exponent_ge_three {C x p : ℝ} (hC : 0 < C) (hx : 0 < x)
    (h8 : C * x ^ p ≤ 1 / 1000) (h4 : 5 ≤ C * (16 * x) ^ p) : 3 < p := by
  have hmul : (16 * x) ^ p = 16 ^ p * x ^ p := Real.mul_rpow (by norm_num) hx.le
  have hxp : (0:ℝ) < x ^ p := Real.rpow_pos_of_pos hx p
  have hCx : (0:ℝ) < C * x ^ p := mul_pos hC hxp
  have hbig : 4096 * (C * x ^ p) < 16 ^ p * (C * x ^ p) := by
    have h1 : 5 ≤ 16 ^ p * (C * x ^ p) := by
      calc (5:ℝ) ≤ C * (16 * x) ^ p := h4
        _ = 16 ^ p * (C * x ^ p) := by rw [hmul]; ring
    have h2 : 4096 * (C * x ^ p) ≤ 4096 * (1 / 1000) := by
      exact mul_le_mul_of_nonneg_left h8 (by norm_num)
    have : (4096 : ℝ) * (1 / 1000) < 5 := by norm_num
    linarith
  have hpow : (4096 : ℝ) < 16 ^ p := lt_of_mul_lt_mul_right (by linarith) hCx.le
  have h16 : (4096 : ℝ) = (16 : ℝ) ^ (3 : ℝ) := by
    rw [show (3:ℝ) = ((3:ℕ):ℝ) by norm_num, Real.rpow_natCast]
    norm_num
  rw [h16] at hpow
  exact (Real.rpow_lt_rpow_left_iff (by norm_num : (1:ℝ) < 16)).mp hpow

/-- **The wall is narrow.**  Call a bit width *intermediate* when the damage it produces is
neither free (`≤ δ`) nor annihilating (`≥ 5000 δ`), the two regimes NET-92 actually observed.
Once the response exponent is at least `3` — as the NET-92 pair forces
(`net92_response_exponent_ge_three`) — any two intermediate widths differ by at most `4`:
five extra bits already shrink the damage by `2 ^ 15 = 32768 > 5000`, more than the whole
free-to-annihilated dynamic range.  This is the precise sense in which the KV precision axis
"has no usable middle": the middle is at most four bit widths wide, and the NET-92 grid
`{4, 8}` straddles it exactly. -/
theorem transition_band_width_le {C A delta p : ℝ} {b b' : ℕ}
    (hC : 0 < C) (hA : 0 < A) (hdelta : 0 < delta) (hp : 3 ≤ p)
    (hb : delta < C * (A / 2 ^ b) ^ p ∧ C * (A / 2 ^ b) ^ p < 5000 * delta)
    (hb' : delta < C * (A / 2 ^ b') ^ p ∧ C * (A / 2 ^ b') ^ p < 5000 * delta) :
    b' ≤ b + 4 := by
  by_contra hcon
  push_neg at hcon
  have hb5 : b + 5 ≤ b' := by omega
  have h2b : (0:ℝ) < 2 ^ b := by positivity
  have h2b' : (0:ℝ) < 2 ^ b' := by positivity
  have hApos : (0:ℝ) < A / 2 ^ b' := by positivity
  have h1 : (2:ℝ) ^ b * 32 ≤ 2 ^ b' := by
    have hmono : (2:ℝ) ^ (b + 5) ≤ 2 ^ b' := pow_le_pow_right₀ (by norm_num) hb5
    calc (2:ℝ) ^ b * 32 = 2 ^ (b + 5) := by rw [pow_add]; norm_num
      _ ≤ 2 ^ b' := hmono
  have hstep : 32 * (A / 2 ^ b') ≤ A / 2 ^ b := by
    rw [mul_div_assoc', div_le_div_iff₀ h2b' h2b]
    nlinarith [hA.le, h1]
  have hposp : (0:ℝ) < (A / 2 ^ b') ^ p := Real.rpow_pos_of_pos hApos p
  have h32 : (32768:ℝ) ≤ (32:ℝ) ^ p := by
    have hmono : (32:ℝ) ^ (3:ℝ) ≤ (32:ℝ) ^ p :=
      (Real.rpow_le_rpow_left_iff (by norm_num : (1:ℝ) < 32)).mpr hp
    have h3 : (32:ℝ) ^ (3:ℝ) = 32768 := by
      rw [show (3:ℝ) = ((3:ℕ):ℝ) by norm_num, Real.rpow_natCast]; norm_num
    linarith [h3 ▸ hmono]
  have hmono : (32 * (A / 2 ^ b')) ^ p ≤ (A / 2 ^ b) ^ p :=
    Real.rpow_le_rpow (by positivity) hstep (by linarith)
  have hsplit : (32 * (A / 2 ^ b')) ^ p = (32:ℝ) ^ p * (A / 2 ^ b') ^ p :=
    Real.mul_rpow (by norm_num) hApos.le
  have hratio : 32768 * (A / 2 ^ b') ^ p ≤ (A / 2 ^ b) ^ p := by
    nlinarith [hsplit ▸ hmono, hposp, h32]
  nlinarith [hb.2, hb'.1, hratio, hC, hdelta]

end Catalog.Logic.KVCliffDepth