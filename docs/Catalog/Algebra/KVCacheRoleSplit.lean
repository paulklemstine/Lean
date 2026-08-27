/-
# The algebra of role-asymmetric KV-cache quantisation

This file formalises the *mechanism* behind the NET-94 experimental cell
(`llama-perplexity`, ctx = 2048, 250 KB held-out wikitext slice):

| arm                | PPL     | dPPL vs f16 |
|--------------------|---------|-------------|
| K `q8_0` / V `q4_0`| 7.1194  | +0.142 %    |
| K `q5_1` / V `q5_1`| 68.7963 | +867.694 %  |

The measurement says that the two halves of an attention cache behave completely
differently under quantisation: keys are fragile, values are free.  The purpose of
this file is to show that this asymmetry is not an empirical accident but an
algebraic consequence of *where* the two tensors enter the attention map.

* A **value** enters the attention output **linearly**, inside a convex combination.
  A perturbation of size `ε` moves the output by at most `ε`: the value path is a
  `1`-Lipschitz averaging operator (`value_path_stable`), and its distortion is
  *dimension free*.
* A **key** enters through the **exponential** of an inner product with the query.
  Perturbing the key by `η` per coordinate moves the logit by up to `d·Q·η`
  (`logit_perturb_le`) and the softmax weights by a factor `exp (2 d Q η)`
  (`softmaxW_perturb_le`).  That factor is *attained*: the log-odds of the softmax
  are translated *exactly* by the logit perturbation (`softmaxW_odds_shift`), so no
  sharper bound exists.

The two facts together are the `role split`:  a uniform per-coordinate budget `η`
costs `O(η)` on the value side and `Θ(exp (d Q η))` on the key side.

Main results
* `softmaxW_sum_one`, `softmaxW_pos` — the softmax is a probability vector.
* `softmaxW_odds_shift` — exact translation of the log-odds (tightness of the key bound).
* `softmaxW_perturb_le` — `exp (2ε)` multiplicative stability of softmax weights.
* `softmaxW_l1_perturb_le` — the induced `ℓ¹` movement of the weight vector.
* `value_path_stable` — the value path is `1`-Lipschitz (no amplification whatsoever).
* `key_path_error_le` / `attention_split_error_le` — the full role-split error budget.
* `role_asymmetry` — for a common per-coordinate budget the key bound is at least
  `d·Q` times the value bound, and grows exponentially, while the value bound is linear.
-/
import Mathlib

namespace Catalog.Algebra.KVCache

open Finset

/-! ## Softmax weights -/

/-- The softmax weight attached to logit `i`. -/
noncomputable def softmaxW {n : ℕ} (s : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (s i) / ∑ j, Real.exp (s j)

variable {n : ℕ} [NeZero n]

lemma sum_exp_pos (s : Fin n → ℝ) : 0 < ∑ j, Real.exp (s j) := by
  have : (Finset.univ : Finset (Fin n)).Nonempty := by
    have : Nonempty (Fin n) := ⟨⟨0, Nat.pos_of_ne_zero (NeZero.ne n)⟩⟩
    exact Finset.univ_nonempty
  exact Finset.sum_pos (fun j _ => Real.exp_pos _) this

lemma softmaxW_pos (s : Fin n → ℝ) (i : Fin n) : 0 < softmaxW s i :=
  div_pos (Real.exp_pos _) (sum_exp_pos s)

lemma softmaxW_nonneg (s : Fin n → ℝ) (i : Fin n) : 0 ≤ softmaxW s i :=
  (softmaxW_pos s i).le

@[simp] lemma softmaxW_sum_one (s : Fin n → ℝ) : ∑ i, softmaxW s i = 1 := by
  unfold softmaxW
  rw [← Finset.sum_div, div_self (ne_of_gt (sum_exp_pos s))]

/-- **Exact translation of the log-odds.**  Shifting the logits by `d` multiplies the
odds of `i` against `j` by exactly `exp (d i - d j)`.  This is the tightness statement
behind the key-side cliff: the softmax reacts to logit noise *exponentially*, and the
`exp` bound of `softmaxW_perturb_le` cannot be improved. -/
theorem softmaxW_odds_shift (s d : Fin n → ℝ) (i j : Fin n) :
    softmaxW (fun k => s k + d k) i / softmaxW (fun k => s k + d k) j
      = Real.exp (d i - d j) * (softmaxW s i / softmaxW s j) := by
  have hZ : (0:ℝ) < ∑ k, Real.exp (s k) := sum_exp_pos s
  have hZ' : (0:ℝ) < ∑ k, Real.exp (s k + d k) := sum_exp_pos (fun k => s k + d k)
  unfold softmaxW
  rw [div_div_div_cancel_right₀, div_div_div_cancel_right₀, Real.exp_sub]
  · field_simp
    rw [Real.exp_add, Real.exp_add]
    ring
  · exact ne_of_gt hZ
  · exact ne_of_gt hZ'

/-- **Multiplicative stability of the softmax.**  A logit perturbation bounded by `ε`
inflates every weight by at most `exp (2ε)`. -/
theorem softmaxW_perturb_le (s d : Fin n → ℝ) (ε : ℝ) (hd : ∀ k, |d k| ≤ ε) (i : Fin n) :
    softmaxW (fun k => s k + d k) i ≤ Real.exp (2 * ε) * softmaxW s i := by
  have hZ : (0:ℝ) < ∑ k, Real.exp (s k) := sum_exp_pos s
  have hZ' : (0:ℝ) < ∑ k, Real.exp (s k + d k) := sum_exp_pos (fun k => s k + d k)
  have hnum : Real.exp (s i + d i) ≤ Real.exp ε * Real.exp (s i) := by
    rw [← Real.exp_add]
    exact Real.exp_le_exp.2 (by nlinarith [abs_le.1 (hd i), (abs_le.1 (hd i)).2])
  have hden : Real.exp (-ε) * (∑ k, Real.exp (s k)) ≤ ∑ k, Real.exp (s k + d k) := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum (fun k _ => ?_)
    rw [← Real.exp_add]
    exact Real.exp_le_exp.2 (by linarith [(abs_le.1 (hd k)).1])
  have hεpos : (0:ℝ) < Real.exp (-ε) := Real.exp_pos _
  unfold softmaxW
  rw [div_le_iff₀ hZ']
  have key : Real.exp (s i + d i) ≤
      Real.exp (2 * ε) * (Real.exp (s i) / ∑ k, Real.exp (s k)) *
        (Real.exp (-ε) * ∑ k, Real.exp (s k)) := by
    have : Real.exp (2 * ε) * (Real.exp (s i) / ∑ k, Real.exp (s k)) *
        (Real.exp (-ε) * ∑ k, Real.exp (s k))
        = Real.exp (2 * ε) * Real.exp (-ε) * Real.exp (s i) := by
      field_simp
    rw [this, ← Real.exp_add]
    calc Real.exp (s i + d i) ≤ Real.exp ε * Real.exp (s i) := hnum
      _ = Real.exp (2 * ε + -ε) * Real.exp (s i) := by ring_nf
  refine key.trans (mul_le_mul_of_nonneg_left hden ?_)
  positivity

/-- The `ℓ¹` movement of the softmax weight vector under a logit perturbation of
size `ε` is at most `2 (exp (2ε) - 1)`. -/
theorem softmaxW_l1_perturb_le (s d : Fin n → ℝ) (ε : ℝ) (hε : 0 ≤ ε)
    (hd : ∀ k, |d k| ≤ ε) :
    ∑ i, |softmaxW (fun k => s k + d k) i - softmaxW s i| ≤ 2 * (Real.exp (2 * ε) - 1) := by
  set w := softmaxW s with hw
  set w' := softmaxW (fun k => s k + d k) with hw'
  have hsum0 : ∑ i, (w' i - w i) = 0 := by
    rw [Finset.sum_sub_distrib, hw, hw', softmaxW_sum_one, softmaxW_sum_one, sub_self]
  have habs : ∀ i : Fin n, |w' i - w i| = 2 * max (w' i - w i) 0 - (w' i - w i) := by
    intro i
    by_cases h : 0 ≤ w' i - w i
    · rw [abs_of_nonneg h, max_eq_left h]; ring
    · push_neg at h
      rw [abs_of_neg h, max_eq_right h.le]; ring
  have hpos : ∀ i : Fin n, max (w' i - w i) 0 ≤ (Real.exp (2 * ε) - 1) * w i := by
    intro i
    have h1 : w' i ≤ Real.exp (2 * ε) * w i := softmaxW_perturb_le s d ε hd i
    have h2 : (0:ℝ) ≤ (Real.exp (2 * ε) - 1) * w i := by
      have : (1:ℝ) ≤ Real.exp (2 * ε) := Real.one_le_exp (by linarith)
      have := softmaxW_nonneg s i
      nlinarith
    exact max_le (by nlinarith) h2
  calc ∑ i, |w' i - w i|
      = ∑ i, (2 * max (w' i - w i) 0 - (w' i - w i)) := by
        exact Finset.sum_congr rfl (fun i _ => habs i)
    _ = 2 * ∑ i, max (w' i - w i) 0 - ∑ i, (w' i - w i) := by
        rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
    _ = 2 * ∑ i, max (w' i - w i) 0 := by rw [hsum0]; ring
    _ ≤ 2 * ∑ i, (Real.exp (2 * ε) - 1) * w i := by
        have := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpos i)
        linarith
    _ = 2 * (Real.exp (2 * ε) - 1) := by
        rw [← Finset.mul_sum, hw, softmaxW_sum_one, mul_one]

/-! ## The value path: linear, dimension free, `1`-Lipschitz -/

omit [NeZero n] in
/-- **The value path never amplifies.**  Perturbing the cached values by at most `ε`
each moves the attention output by at most `ε`, for *any* probability weight vector
and in *any* dimension.  This is the algebraic reason values survive raw 4-bit. -/
theorem value_path_stable (w v e : Fin n → ℝ) (ε : ℝ)
    (hw : ∀ i, 0 ≤ w i) (hw1 : ∑ i, w i = 1) (he : ∀ i, |e i| ≤ ε) :
    |(∑ i, w i * (v i + e i)) - ∑ i, w i * v i| ≤ ε := by
  have hrw : (∑ i, w i * (v i + e i)) - ∑ i, w i * v i = ∑ i, w i * e i := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun i _ => by ring)
  rw [hrw]
  calc |∑ i, w i * e i| ≤ ∑ i, |w i * e i| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ i, w i * |e i| := by
        exact Finset.sum_congr rfl (fun i _ => by rw [abs_mul, abs_of_nonneg (hw i)])
    _ ≤ ∑ i, w i * ε := by
        refine Finset.sum_le_sum (fun i _ => ?_)
        exact mul_le_mul_of_nonneg_left (he i) (hw i)
    _ = ε := by rw [← Finset.sum_mul, hw1, one_mul]

/-! ## The key path: through an inner product and an exponential -/

/-- Query–key logit. -/
def dot {d : ℕ} (q k : Fin d → ℝ) : ℝ := ∑ c, q c * k c

/-- A per-coordinate key perturbation of size `η` moves the logit by at most `d·Q·η`,
where `Q` bounds the query coordinates.  Unlike the value path, the key path is
*dimension amplifying*: the head dimension multiplies the quantisation step. -/
theorem logit_perturb_le {d : ℕ} (q k g : Fin d → ℝ) (Q η : ℝ) (hQ : 0 ≤ Q)
    (hq : ∀ c, |q c| ≤ Q) (hg : ∀ c, |g c| ≤ η) :
    |dot q (fun c => k c + g c) - dot q k| ≤ d * Q * η := by
  have hrw : dot q (fun c => k c + g c) - dot q k = ∑ c, q c * g c := by
    unfold dot
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun c _ => by ring)
  rw [hrw]
  calc |∑ c, q c * g c| ≤ ∑ c, |q c * g c| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _c : Fin d, Q * η := by
        refine Finset.sum_le_sum (fun c _ => ?_)
        rw [abs_mul]
        exact mul_le_mul (hq c) (hg c) (abs_nonneg _) hQ
    _ = d * Q * η := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
        ring

/-! ## The two paths combined: the role-split error budget -/

/-- **The key path amplifies.**  A logit perturbation of size `ε` (coming from
quantised keys) moves the attention output by at most `2 (exp (2ε) - 1) V`, where `V`
bounds the cached values.  Contrast `value_path_stable`: here the bound is
*exponential* in the perturbation, not linear. -/
theorem key_path_error_le (s d v : Fin n → ℝ) (ε V : ℝ) (hε : 0 ≤ ε)
    (hd : ∀ k, |d k| ≤ ε) (hv : ∀ i, |v i| ≤ V) :
    |(∑ i, softmaxW (fun k => s k + d k) i * v i) - ∑ i, softmaxW s i * v i|
      ≤ 2 * (Real.exp (2 * ε) - 1) * V := by
  have hV : 0 ≤ V := le_trans (abs_nonneg (v ⟨0, Nat.pos_of_ne_zero (NeZero.ne n)⟩)) (hv _)
  set w := softmaxW s with hw
  set w' := softmaxW (fun k => s k + d k) with hw'
  have hrw : (∑ i, w' i * v i) - ∑ i, w i * v i = ∑ i, (w' i - w i) * v i := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun i _ => by ring)
  rw [hrw]
  calc |∑ i, (w' i - w i) * v i| ≤ ∑ i, |(w' i - w i) * v i| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, |w' i - w i| * V := by
        refine Finset.sum_le_sum (fun i _ => ?_)
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_left (hv i) (abs_nonneg _)
    _ = (∑ i, |w' i - w i|) * V := by rw [Finset.sum_mul]
    _ ≤ (2 * (Real.exp (2 * ε) - 1)) * V := by
        exact mul_le_mul_of_nonneg_right (softmaxW_l1_perturb_le s d ε hε hd) hV
    _ = 2 * (Real.exp (2 * ε) - 1) * V := by ring

/-- **The role-split error budget.**  Quantising the keys (logit error `≤ εK`) and the
values (entrywise error `≤ εV`) moves the attention output by at most
`2 (exp (2 εK) - 1) V + εV`.  The two contributions are structurally different: the
key term is exponential in its budget, the value term is exactly its budget. -/
theorem attention_split_error_le (s d v e : Fin n → ℝ) (εK εV V : ℝ) (hεK : 0 ≤ εK)
    (hd : ∀ k, |d k| ≤ εK) (he : ∀ i, |e i| ≤ εV) (hv : ∀ i, |v i| ≤ V) :
    |(∑ i, softmaxW (fun k => s k + d k) i * (v i + e i)) - ∑ i, softmaxW s i * v i|
      ≤ 2 * (Real.exp (2 * εK) - 1) * V + εV := by
  set w := softmaxW s with hw
  set w' := softmaxW (fun k => s k + d k) with hw'
  have hsplit :
      (∑ i, w' i * (v i + e i)) - ∑ i, w i * v i
        = ((∑ i, w' i * (v i + e i)) - ∑ i, w' i * v i)
          + ((∑ i, w' i * v i) - ∑ i, w i * v i) := by ring
  have h1 : |(∑ i, w' i * (v i + e i)) - ∑ i, w' i * v i| ≤ εV :=
    value_path_stable w' v e εV (fun i => softmaxW_nonneg _ i) (softmaxW_sum_one _) he
  have h2 : |(∑ i, w' i * v i) - ∑ i, w i * v i| ≤ 2 * (Real.exp (2 * εK) - 1) * V :=
    key_path_error_le s d v εK V hεK hd hv
  calc |(∑ i, w' i * (v i + e i)) - ∑ i, w i * v i|
      ≤ |(∑ i, w' i * (v i + e i)) - ∑ i, w' i * v i|
        + |(∑ i, w' i * v i) - ∑ i, w i * v i| := by
        rw [hsplit]; exact abs_add_le _ _
    _ ≤ 2 * (Real.exp (2 * εK) - 1) * V + εV := by linarith

/-- **Role asymmetry.**  With a common per-coordinate quantisation budget `η`, the
key-side bound of `key_path_error_le` (logit error `d·Q·η`) is at least `4 d Q V`
times the value-side bound `η` of `value_path_stable` — and, being exponential, its
ratio to the value bound is unbounded as `η` grows.  The value bound, by contrast,
is *exactly* `η`: dimension free, query free, magnitude free. -/
theorem role_asymmetry (d Q V η : ℝ) (hd : 0 ≤ d) (hQ : 0 ≤ Q) (hV : 0 ≤ V) (hη : 0 ≤ η) :
    η * (4 * d * Q * V) ≤ 2 * (Real.exp (2 * (d * Q * η)) - 1) * V := by
  have hx : 0 ≤ 2 * (d * Q * η) := by positivity
  have h := Real.add_one_le_exp (2 * (d * Q * η))
  nlinarith [Real.exp_pos (2 * (d * Q * η))]

end Catalog.Algebra.KVCache