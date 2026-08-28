import Mathlib
import Novelty.KeysOwnTheCliff

/-!
# The cliff exponent: `e^{2η} − 1` for keys versus `δ` for values (NET-93, cycle 2)

`Novelty.KeysOwnTheCliff` shows that key quantisation admits **no** Lipschitz
constant at all, while value quantisation is `1`-Lipschitz.  That is a statement
about worst cases over queries.  This file supplies the matching *upper* bound,
which exhibits the functional form of the cliff:

> With a logit error `η` on the key side and a value error `δ`, the attention
> read-out moves by at most
> `(exp (2η) − 1) · B + δ`,  where `B = ‖v‖_∞`.

The key contribution is **exponential** in the perturbation, the value
contribution is **linear** — and since the logit error is itself `η = ‖q‖₁ · δ_K`
(`score_error_le_of_key_error`), the key term is exponential in the product of
the query norm with the key resolution.  Halving the key resolution *squares*
the tolerance; halving the value resolution merely halves the error.  That is
the four-order-of-magnitude asymmetry of NET-93, as a formula.

Main results:

* `softmax_le_exp_mul` / `exp_mul_le_softmax` — a two-sided multiplicative
  (Radon–Nikodym style) bound: an `η`-logit perturbation multiplies every
  attention weight by a factor in `[e^{-2η}, e^{2η}]`.
* `softmax_l1_perturbation_le` — hence the total-variation bound
  `∑ᵢ |softmax s' i − softmax s i| ≤ e^{2η} − 1`.
* `attn_key_perturbation_le` — the key half of the budget.
* `attn_kv_perturbation_le` — **the combined KV bound**
  `(e^{2η} − 1)·B + δ`, exponential in keys and linear in values.
* `attn_kv_from_cache_resolution` — the deployment form, with `η` expanded as
  `‖q‖₁ · δ_K`.
* `key_term_dominates_eventually` — for every value budget `δ` and every bound
  `B > 0`, once the logit error passes an explicit threshold the key term
  exceeds the value term; conversely `value_term_never_exceeds_delta`.
-/

namespace Catalog.Novelty.KVCliffExponent

open Finset Catalog.Novelty.KeysOwnTheCliff

variable {n : ℕ}

/-! ### 1. Multiplicative stability of the softmax under logit perturbation -/

/-- An `η`-perturbation of the logits multiplies each attention weight by at
most `e^{2η}`. -/
theorem softmax_le_exp_mul (s s' : Fin (n + 1) → ℝ) (eta : ℝ)
    (h : ∀ j, |s j - s' j| ≤ eta) (i : Fin (n + 1)) :
    softmax s' i ≤ Real.exp (2 * eta) * softmax s i := by
  have hZ : 0 < ∑ j, Real.exp (s j) := sum_exp_pos s
  have hZ' : 0 < ∑ j, Real.exp (s' j) := sum_exp_pos s'
  have hnum : Real.exp (s' i) ≤ Real.exp eta * Real.exp (s i) := by
    rw [← Real.exp_add]
    exact Real.exp_le_exp.2 (by linarith [(abs_le.1 (h i)).1, (abs_le.1 (h i)).2])
  have hden : Real.exp (-eta) * ∑ j, Real.exp (s j) ≤ ∑ j, Real.exp (s' j) := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun j _ => ?_
    rw [← Real.exp_add]
    exact Real.exp_le_exp.2 (by linarith [(abs_le.1 (h j)).1, (abs_le.1 (h j)).2])
  have hetapos : 0 < Real.exp (-eta) := Real.exp_pos _
  rw [softmax, softmax, div_le_iff₀ hZ']
  have hstep : Real.exp (2 * eta) * (Real.exp (s i) / ∑ j, Real.exp (s j))
      * (Real.exp (-eta) * ∑ j, Real.exp (s j))
      = Real.exp eta * Real.exp (s i) := by
    field_simp
    rw [← Real.exp_add]
    ring_nf
  calc Real.exp (s' i) ≤ Real.exp eta * Real.exp (s i) := hnum
    _ = Real.exp (2 * eta) * (Real.exp (s i) / ∑ j, Real.exp (s j))
          * (Real.exp (-eta) * ∑ j, Real.exp (s j)) := hstep.symm
    _ ≤ Real.exp (2 * eta) * (Real.exp (s i) / ∑ j, Real.exp (s j))
          * ∑ j, Real.exp (s' j) := by
        refine mul_le_mul_of_nonneg_left hden ?_
        positivity

/-- The matching lower bound: weights shrink by at most `e^{-2η}`. -/
theorem exp_mul_le_softmax (s s' : Fin (n + 1) → ℝ) (eta : ℝ)
    (h : ∀ j, |s j - s' j| ≤ eta) (i : Fin (n + 1)) :
    Real.exp (-(2 * eta)) * softmax s i ≤ softmax s' i := by
  have hsym : ∀ j, |s' j - s j| ≤ eta := by
    intro j
    rw [abs_sub_comm]
    exact h j
  have hup := softmax_le_exp_mul s' s eta hsym i
  have hpos : 0 < Real.exp (2 * eta) := Real.exp_pos _
  rw [Real.exp_neg, inv_mul_eq_div, div_le_iff₀ hpos, mul_comm]
  exact hup

/-- **Total-variation bound.**  An `η`-perturbation of the logits moves the
attention distribution by at most `e^{2η} − 1` in `ℓ¹`.  The bound is
*exponential* in `η`: this is the cliff. -/
theorem softmax_l1_perturbation_le (s s' : Fin (n + 1) → ℝ) (eta : ℝ)
    (h : ∀ j, |s j - s' j| ≤ eta) :
    ∑ i, |softmax s' i - softmax s i| ≤ Real.exp (2 * eta) - 1 := by
  have hb : ∀ i, |softmax s' i - softmax s i| ≤ (Real.exp (2 * eta) - 1) * softmax s i := by
    intro i
    have hup := softmax_le_exp_mul s s' eta h i
    have hlo := exp_mul_le_softmax s s' eta h i
    have hpi : 0 < softmax s i := softmax_pos s i
    have hxpos : 0 < Real.exp (2 * eta) := Real.exp_pos _
    have hinv : 2 - Real.exp (2 * eta) ≤ Real.exp (-(2 * eta)) := by
      rw [Real.exp_neg, ← one_div, le_div_iff₀ hxpos]
      nlinarith [sq_nonneg (Real.exp (2 * eta) - 1)]
    have hlow : (2 - Real.exp (2 * eta)) * softmax s i ≤ softmax s' i :=
      le_trans (mul_le_mul_of_nonneg_right hinv hpi.le) hlo
    rw [abs_le]
    constructor <;> nlinarith
  calc ∑ i, |softmax s' i - softmax s i|
      ≤ ∑ i, (Real.exp (2 * eta) - 1) * softmax s i := Finset.sum_le_sum fun i _ => hb i
    _ = Real.exp (2 * eta) - 1 := by
        rw [← Finset.mul_sum, softmax_sum_one, mul_one]

/-! ### 2. The key half and the combined budget -/

/-- **Key half of the budget.**  A logit error `η` costs at most
`(e^{2η} − 1) · ‖v‖_∞` in the read-out. -/
theorem attn_key_perturbation_le (s s' v : Fin (n + 1) → ℝ) (eta B : ℝ)
    (h : ∀ j, |s j - s' j| ≤ eta) (hv : ∀ i, |v i| ≤ B) :
    |attnOut s' v - attnOut s v| ≤ (Real.exp (2 * eta) - 1) * B := by
  have hB : 0 ≤ B := le_trans (abs_nonneg _) (hv 0)
  have hrw : attnOut s' v - attnOut s v = ∑ i, (softmax s' i - softmax s i) * v i := by
    simp only [attnOut]
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hrw]
  calc |∑ i, (softmax s' i - softmax s i) * v i|
      ≤ ∑ i, |(softmax s' i - softmax s i) * v i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, |softmax s' i - softmax s i| * B := by
        refine Finset.sum_le_sum fun i _ => ?_
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_left (hv i) (abs_nonneg _)
    _ = (∑ i, |softmax s' i - softmax s i|) * B := by rw [Finset.sum_mul]
    _ ≤ (Real.exp (2 * eta) - 1) * B :=
        mul_le_mul_of_nonneg_right (softmax_l1_perturbation_le s s' eta h) hB

/-- **The combined KV bound.**  Quantising both halves of the cache costs at
most `(e^{2η} − 1)·B + δ`: exponential in the key-induced logit error `η`,
linear in the value resolution `δ`.  Every asymmetry measured in NET-93 is
visible in the shape of these two terms. -/
theorem attn_kv_perturbation_le (s s' v v' : Fin (n + 1) → ℝ) (eta B delta : ℝ)
    (hs : ∀ j, |s j - s' j| ≤ eta) (hv : ∀ i, |v i| ≤ B)
    (hvv : ∀ i, |v i - v' i| ≤ delta) :
    |attnOut s' v' - attnOut s v| ≤ (Real.exp (2 * eta) - 1) * B + delta := by
  have h1 : |attnOut s' v' - attnOut s' v| ≤ delta := by
    rw [abs_sub_comm]
    exact attn_value_perturbation_le s' v v' delta hvv
  have h2 : |attnOut s' v - attnOut s v| ≤ (Real.exp (2 * eta) - 1) * B :=
    attn_key_perturbation_le s s' v eta B hs hv
  calc |attnOut s' v' - attnOut s v|
      ≤ |attnOut s' v' - attnOut s' v| + |attnOut s' v - attnOut s v| := by
        simpa using abs_sub_le (attnOut s' v') (attnOut s' v) (attnOut s v)
    _ ≤ (Real.exp (2 * eta) - 1) * B + delta := by linarith

/-- **Deployment form.**  In terms of the raw cache resolutions `δ_K` (keys) and
`δ_V` (values), the read-out error is at most
`(e^{2‖q‖₁ δ_K} − 1)·B + δ_V`.  The key resolution is amplified by the query
norm and then exponentiated; the value resolution passes through untouched. -/
theorem attn_kv_from_cache_resolution {d : ℕ} (q : Fin d → ℝ)
    (k k' : Fin (n + 1) → Fin d → ℝ) (v v' : Fin (n + 1) → ℝ) (deltaK deltaV B : ℝ)
    (hk : ∀ i t, |k i t - k' i t| ≤ deltaK)
    (hv : ∀ i, |v i| ≤ B) (hvv : ∀ i, |v i - v' i| ≤ deltaV) :
    |attnOut (scores q k') v' - attnOut (scores q k) v|
      ≤ (Real.exp (2 * ((∑ t, |q t|) * deltaK)) - 1) * B + deltaV := by
  exact attn_kv_perturbation_le _ _ _ _ _ _ _
    (fun j => score_error_le_of_key_error q k k' deltaK hk j) hv hvv

/-! ### 3. Which term owns the damage -/

/-- The value term is bounded by the value resolution, always. -/
theorem value_term_never_exceeds_delta (s v v' : Fin (n + 1) → ℝ) (delta : ℝ)
    (h : ∀ i, |v i - v' i| ≤ delta) : |attnOut s v - attnOut s v'| ≤ delta :=
  attn_value_perturbation_le s v v' delta h

/-- **The key term eventually dominates by any margin.**  For every value budget
`δ`, every `B > 0` and every factor `M`, there is a logit error `η` — explicitly
`η = ½ log (1 + (M·δ + 1)/B)` — at which the guaranteed key term exceeds `M`
times the value term.  Since `η = ‖q‖₁ δ_K`, an arbitrarily *fine* key grid
still reaches this regime once the query norm is large enough: the key side has
no safe resolution. -/
theorem key_term_dominates_eventually (delta B M : ℝ) (hB : 0 < B) (hd : 0 ≤ delta)
    (hM : 0 ≤ M) :
    ∃ eta : ℝ, 0 ≤ eta ∧ M * delta < (Real.exp (2 * eta) - 1) * B := by
  set c : ℝ := 1 + (M * delta + 1) / B with hc
  have hcpos : 1 < c := by
    have : 0 < (M * delta + 1) / B := by positivity
    simp only [hc]
    linarith
  refine ⟨Real.log c / 2, ?_, ?_⟩
  · have : 0 ≤ Real.log c := Real.log_nonneg hcpos.le
    linarith
  · have hcp : 0 < c := lt_trans zero_lt_one hcpos
    have hexp : Real.exp (2 * (Real.log c / 2)) = c := by
      rw [show 2 * (Real.log c / 2) = Real.log c by ring, Real.exp_log hcp]
    rw [hexp, hc]
    have : (1 + (M * delta + 1) / B - 1) * B = M * delta + 1 := by
      field_simp
      ring
    rw [this]
    linarith

end Catalog.Novelty.KVCliffExponent