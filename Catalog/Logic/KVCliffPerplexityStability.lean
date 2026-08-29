/-
# NET-92 cycle: from softmax stability to perplexity — the certificate and its inverse

NET-92 is a *perplexity* experiment, but the catalog's KV-cache files
(`Algebra.KVCacheRoleSplit`, `Algebra.KVCacheArgmaxThreshold`, `Novelty.KVCliffExponent`)
stop at the attention weights.  This file closes the gap between the two: it lifts the
multiplicative softmax bound to the *cross-entropy* and hence to perplexity, which is the
quantity the experiment reports.

* `logLoss_perturb_le` — a logit perturbation of size `ε` costs at most `2 ε` nats of
  token-level log-loss.  (Both directions of the softmax bound are needed; the missing
  direction, `softmaxW_perturb_ge`, is derived here from `softmaxW_perturb_le`.)
* `ppl_ratio_le` — therefore perplexity is multiplied by at most `exp (2 ε)`:
  **the KV cache damages perplexity at most exponentially in the logit error, and no worse**.
* `eight_bit_is_free` — with `ε ≤ 1/2000` nats of logit error the certified worst case is
  `+0.11 %`, which brackets the measured `q8_0` arms (`−0.24 %`, `+0.09 %`, `+0.10 %`).
* `net92_four_bit_effective_error_ge` — read backwards, the same inequality turns the measured
  `380 ×` collapse into a **lower bound** on the effective logit error of the `q4_0` cache:
  at least `2.5` nats.  Upper bounds are usually inert as explanations; this one is not,
  because the measured damage forces the perturbation to be enormous.
* `four_bit_window_lower_bound` — and `2.5` nats at four bits means the key-logit dynamic
  range that a raw per-tensor `q4_0` grid has to cover is at least `40` nats.  That is a
  falsifiable prediction about the model, not about the quantiser: measure the per-head logit
  range of Qwen2.5-7B; if it is far below `40`, the uniform-grid account of the NET-92 cliff
  is wrong and the collapse must come from outliers rather than from average resolution.
-/
import Mathlib
import Algebra.KVCacheRoleSplit

namespace Catalog.Logic.KVCliffPerplexity

open Finset Catalog.Algebra.KVCache

variable {n : ℕ} [NeZero n]

/-! ## The missing direction of the softmax bound -/

/-- **Lower multiplicative bound.**  A logit perturbation bounded by `ε` deflates every softmax
weight by at most `exp (−2 ε)`.  This is the mirror image of
`Catalog.Algebra.KVCache.softmaxW_perturb_le`, obtained by perturbing back. -/
theorem softmaxW_perturb_ge (s d : Fin n → ℝ) (ε : ℝ) (hd : ∀ k, |d k| ≤ ε) (i : Fin n) :
    Real.exp (-(2 * ε)) * softmaxW s i ≤ softmaxW (fun k => s k + d k) i := by
  have hback : ∀ k, |(-d k)| ≤ ε := by
    intro k; rw [abs_neg]; exact hd k
  have h := softmaxW_perturb_le (fun k => s k + d k) (fun k => -d k) ε hback i
  have hfun : (fun k => (s k + d k) + -d k) = s := by
    funext k; ring
  rw [hfun] at h
  have hpos : (0:ℝ) < Real.exp (2 * ε) := Real.exp_pos _
  rw [Real.exp_neg]
  rw [inv_mul_le_iff₀ hpos]
  linarith [h]

/-! ## Token log-loss and perplexity -/

/-- The log-loss (in nats) that the model incurs on the true token `i`. -/
noncomputable def logLoss (s : Fin n → ℝ) (i : Fin n) : ℝ := -Real.log (softmaxW s i)

/-- **Log-loss stability.**  A logit perturbation of size `ε` costs at most `2 ε` nats. -/
theorem logLoss_perturb_le (s d : Fin n → ℝ) (ε : ℝ) (hd : ∀ k, |d k| ≤ ε) (i : Fin n) :
    logLoss (fun k => s k + d k) i ≤ logLoss s i + 2 * ε := by
  have hp : 0 < softmaxW s i := softmaxW_pos s i
  have hq : 0 < softmaxW (fun k => s k + d k) i := softmaxW_pos _ i
  have hge := softmaxW_perturb_ge s d ε hd i
  have hlog : Real.log (Real.exp (-(2 * ε)) * softmaxW s i)
      ≤ Real.log (softmaxW (fun k => s k + d k) i) :=
    Real.log_le_log (by positivity) hge
  rw [Real.log_mul (by positivity) (ne_of_gt hp), Real.log_exp] at hlog
  unfold logLoss
  linarith

/-- Mean cross-entropy over a held-out slice of `m` tokens: position `a` has logits `z a` and
true token `t a`. -/
noncomputable def xent {m : ℕ} (z : Fin m → Fin n → ℝ) (t : Fin m → Fin n) : ℝ :=
  (∑ a, logLoss (z a) (t a)) / m

/-- Perplexity is the exponential of the mean cross-entropy — the quantity NET-92 reports. -/
noncomputable def ppl {m : ℕ} (z : Fin m → Fin n → ℝ) (t : Fin m → Fin n) : ℝ :=
  Real.exp (xent z t)

/-- **Cross-entropy stability on a whole slice.**  If every logit of every position moves by at
most `ε`, the mean cross-entropy rises by at most `2 ε` nats. -/
theorem xent_perturb_le {m : ℕ} (hm : 0 < m) (z : Fin m → Fin n → ℝ) (e : Fin m → Fin n → ℝ)
    (t : Fin m → Fin n) (ε : ℝ) (hd : ∀ a k, |e a k| ≤ ε) :
    xent (fun a k => z a k + e a k) t ≤ xent z t + 2 * ε := by
  have hmpos : (0:ℝ) < m := by exact_mod_cast hm
  have hsum : ∑ a, logLoss (fun k => z a k + e a k) (t a)
      ≤ ∑ a, (logLoss (z a) (t a) + 2 * ε) :=
    Finset.sum_le_sum (fun a _ => logLoss_perturb_le (z a) (e a) ε (hd a) (t a))
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul] at hsum
  unfold xent
  rw [div_le_iff₀ hmpos]
  have : (∑ a, logLoss (z a) (t a)) / m * m = ∑ a, logLoss (z a) (t a) := by
    field_simp
  nlinarith [hsum, this]

/-- **The perplexity certificate.**  Quantising the KV cache multiplies perplexity by at most
`exp (2 ε)`, where `ε` bounds the induced logit error.  This is the exact form of the NET-92
law "8-bit cache is free": the trade is memory versus speed, never memory versus quality,
*provided* `ε` stays small. -/
theorem ppl_ratio_le {m : ℕ} (hm : 0 < m) (z : Fin m → Fin n → ℝ) (e : Fin m → Fin n → ℝ)
    (t : Fin m → Fin n) (ε : ℝ) (hd : ∀ a k, |e a k| ≤ ε) :
    ppl (fun a k => z a k + e a k) t ≤ Real.exp (2 * ε) * ppl z t := by
  unfold ppl
  rw [← Real.exp_add]
  exact Real.exp_le_exp.mpr (by linarith [xent_perturb_le hm z e t ε hd])

/-! ## Numerics: the free side and the annihilated side -/

/-- `exp x ≤ (1 − x)⁻¹` for `x < 1`, from `1 + x ≤ exp x` applied at `−x`. -/
lemma exp_le_inv_one_sub {x : ℝ} (hx : x < 1) : Real.exp x ≤ (1 - x)⁻¹ := by
  have h1 : 1 + -x ≤ Real.exp (-x) := by
    linarith [Real.add_one_le_exp (-x)]
  have h1' : 0 < 1 - x := by linarith
  have h2 : (0:ℝ) < Real.exp (-x) := Real.exp_pos _
  have h3 : Real.exp x * Real.exp (-x) = 1 := by
    rw [← Real.exp_add]; simp
  rw [le_inv_comm₀ (Real.exp_pos x) h1']
  calc (1 - x) ≤ Real.exp (-x) := by linarith
    _ = (Real.exp x)⁻¹ := by
        field_simp at h3 ⊢
        linarith [h3]

/-- **8-bit is free, certified.**  Half a milli-nat of logit error per position — the scale a
full-width `q8_0` cache produces — certifies a perplexity increase of at most `0.11 %`.  The
NET-92 `q8_0` arms measured `−0.24 %`, `+0.09 %`, `+0.10 %`: inside the certificate. -/
theorem eight_bit_is_free {m : ℕ} (hm : 0 < m) (z : Fin m → Fin n → ℝ) (e : Fin m → Fin n → ℝ)
    (t : Fin m → Fin n) (hd : ∀ a k, |e a k| ≤ 1 / 2000) :
    ppl (fun a k => z a k + e a k) t ≤ 1.0011 * ppl z t := by
  have hcert := ppl_ratio_le hm z e t (1 / 2000) hd
  have hexp : Real.exp (2 * (1 / 2000)) ≤ 1.0011 := by
    have h := exp_le_inv_one_sub (show (2 : ℝ) * (1 / 2000) < 1 by norm_num)
    have : ((1:ℝ) - 2 * (1 / 2000))⁻¹ ≤ 1.0011 := by norm_num
    linarith
  have hppl : 0 < ppl z t := Real.exp_pos _
  nlinarith [hcert, hexp, hppl]

/-- `e ^ 5 < 149 < 380`: the elementary numeric input to the inverse bound. -/
lemma exp_five_lt_380 : Real.exp 5 < 380 := by
  have h : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
  have h5 : Real.exp 5 = Real.exp 1 ^ (5 : ℕ) := by
    rw [Real.exp_one_pow]; norm_num
  rw [h5]
  calc Real.exp 1 ^ (5 : ℕ) ≤ 2.7182818286 ^ (5 : ℕ) :=
        pow_le_pow_left₀ (Real.exp_pos 1).le h.le 5
    _ < 380 := by norm_num

/-- **The inverse reading of the certificate.**  NET-92 measured `PPL 7.1093 → 2714.6042`, a
factor above `380`.  Since the certificate says the factor is at most `exp (2 ε)`, the `q4_0`
cache must be injecting **at least `2.5` nats** of logit error per position.  A softmax whose
logits are wrong by two and a half nats is not a degraded ranking, it is a different
ranking — which is why the cliff is a wall and not a slope. -/
theorem net92_four_bit_effective_error_ge {m : ℕ} (hm : 0 < m) (z : Fin m → Fin n → ℝ)
    (e : Fin m → Fin n → ℝ) (t : Fin m → Fin n) (ε : ℝ) (hd : ∀ a k, |e a k| ≤ ε)
    (hmeas : 380 * ppl z t ≤ ppl (fun a k => z a k + e a k) t) : 2.5 ≤ ε := by
  have hcert := ppl_ratio_le hm z e t ε hd
  have hppl : 0 < ppl z t := Real.exp_pos _
  have h380 : (380 : ℝ) ≤ Real.exp (2 * ε) := by
    nlinarith [hcert, hmeas, hppl]
  have hlt : Real.exp 5 < Real.exp (2 * ε) := lt_of_lt_of_le exp_five_lt_380 h380
  have : (5:ℝ) < 2 * ε := Real.exp_lt_exp.mp hlt
  linarith

/-- **A prediction about the model, not the quantiser.**  If the `q4_0` logit error really is
the resolution `A / 2 ^ 4` of a uniform 4-bit grid over a logit dynamic range `A`, then the
`2.5` nats forced by `net92_four_bit_effective_error_ge` require `A ≥ 40` nats.  Measure the
per-head logit range: below `40`, the uniform-resolution story fails and the collapse must be
driven by outlier keys instead. -/
theorem four_bit_window_lower_bound {A : ℝ} (h : 2.5 ≤ A / 2 ^ 4) : 40 ≤ A := by
  rw [le_div_iff₀ (by norm_num : (0:ℝ) < 2 ^ 4)] at h
  norm_num at h
  linarith


/-! ## The cliff needs no depth: one softmax already contains it -/

/-- Log-loss of the second class in a two-position softmax: `log (1 + exp (a − b))`. -/
lemma logLoss_two (a b : ℝ) : logLoss ![a, b] 1 = Real.log (1 + Real.exp (a - b)) := by
  unfold logLoss softmaxW
  rw [Fin.sum_univ_two]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
  rw [← Real.log_inv, inv_div]
  congr 1
  rw [Real.exp_sub]
  field_simp
  ring

/-- `1000 ≤ e ^ 7`. -/
lemma thousand_le_exp_seven : (1000:ℝ) ≤ Real.exp 7 := by
  have h : (2.7182818283:ℝ) < Real.exp 1 := Real.exp_one_gt_d9
  have h7 : Real.exp 7 = Real.exp 1 ^ (7:ℕ) := by rw [Real.exp_one_pow]; norm_num
  rw [h7]
  calc (1000:ℝ) ≤ 2.7182818283 ^ (7:ℕ) := by norm_num
    _ ≤ Real.exp 1 ^ (7:ℕ) := pow_le_pow_left₀ (by norm_num) h.le 7

/-- **The cliff is realizable inside a single softmax.**  Take a two-position head with a logit
gap of `12` nats and the adversarial (for a quantiser, typical) perturbation `(+ε, −ε)`.  At
`ε = 13` the log-loss of the correct token jumps by more than `5` nats — a perplexity factor
above `148`; at one sixteenth of that error, `ε/16 = 0.8125`, the same head loses less than
`1/1000` of a nat — a perplexity factor below `1.001`.

So the `16 ×` step ratio between `q4_0` and `q8_0` can, on its own, separate "free" from
"annihilated": **no depth amplification and no layer count are needed to manufacture the KV
cliff.**  This is the constructive counterpart of
`Logic.KVCliffDepthAmplification.net92_refutes_subhomogeneous`, which shows that depth-linear
propagation *cannot* manufacture it. -/
theorem cliff_realizable_in_one_softmax :
    ∃ G ε : ℝ, 0 < G ∧ 0 < ε ∧
      logLoss ![ε / 16, G - ε / 16] 1 ≤ logLoss ![(0:ℝ), G] 1 + 1 / 1000 ∧
      logLoss ![(0:ℝ), G] 1 + 5 ≤ logLoss ![ε, G - ε] 1 := by
  refine ⟨12, 13, by norm_num, by norm_num, ?_, ?_⟩
  · -- the free side: `log (1 + e ^ (−83/8)) ≤ 1/1000`
    rw [logLoss_two, logLoss_two]
    have harg : (13:ℝ) / 16 - (12 - 13 / 16) = -(83 / 8) := by norm_num
    have harg0 : (0:ℝ) - 12 = -12 := by norm_num
    rw [harg, harg0]
    have hsmall : Real.exp (-(83 / 8 : ℝ)) ≤ 1 / 1000 := by
      have h1 : Real.exp (7:ℝ) ≤ Real.exp (83 / 8 : ℝ) := Real.exp_le_exp.mpr (by norm_num)
      have h2 : (1000:ℝ) ≤ Real.exp (83 / 8 : ℝ) := le_trans thousand_le_exp_seven h1
      rw [Real.exp_neg]
      rw [inv_le_comm₀ (Real.exp_pos _) (by norm_num)]
      linarith
    have hlog : Real.log (1 + Real.exp (-(83 / 8 : ℝ))) ≤ Real.exp (-(83 / 8 : ℝ)) := by
      have := Real.log_le_sub_one_of_pos
        (show (0:ℝ) < 1 + Real.exp (-(83 / 8 : ℝ)) by positivity)
      linarith
    have hnonneg : 0 ≤ Real.log (1 + Real.exp (-12 : ℝ)) := by
      apply Real.log_nonneg
      have := Real.exp_pos (-12 : ℝ)
      linarith
    linarith
  · -- the annihilated side: `log (1 + e ^ 14) ≥ 14`
    rw [logLoss_two, logLoss_two]
    have harg : (13:ℝ) - (12 - 13) = 14 := by norm_num
    have harg0 : (0:ℝ) - 12 = -12 := by norm_num
    rw [harg, harg0]
    have hbig : (14:ℝ) ≤ Real.log (1 + Real.exp (14:ℝ)) := by
      have h1 : Real.exp (14:ℝ) ≤ 1 + Real.exp (14:ℝ) := by linarith
      have h2 : Real.log (Real.exp (14:ℝ)) ≤ Real.log (1 + Real.exp (14:ℝ)) :=
        Real.log_le_log (Real.exp_pos _) h1
      rwa [Real.log_exp] at h2
    have hsmall : Real.log (1 + Real.exp (-12 : ℝ)) ≤ Real.exp (-12 : ℝ) := by
      have := Real.log_le_sub_one_of_pos
        (show (0:ℝ) < 1 + Real.exp (-12 : ℝ) by positivity)
      linarith
    have hexp12 : Real.exp (-12 : ℝ) ≤ 1 := by
      rw [Real.exp_le_one_iff]; norm_num
    linarith

end Catalog.Logic.KVCliffPerplexity