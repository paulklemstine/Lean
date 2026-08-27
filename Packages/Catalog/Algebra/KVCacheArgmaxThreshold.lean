/-
# Cycle 3: the argmax-gap threshold law, and a genuine key-side lower bound

Cycles 1–2 bounded the damage caused by cache quantisation *from above* on both roles
(`Algebra.KVCacheRoleSplit`), and showed that no smooth `2⁻ᵇ` law can produce a 3-bit
collapse (`Algebra.KVCacheCliffGeometry`, `Algebra.KVCacheResponseExponent`).  A critic
is entitled to object that upper bounds alone never prove fragility: they only fail to
prove robustness.  This file supplies the missing half.

The mechanism is the **top-two logit gap** `g`.  Softmax is order preserving
(`softmaxW_lt_iff`), so the attended position is the arg-max of the logits, and a key
perturbation inverts it precisely when it exceeds the gap:

* `softmaxW_rank_inversion` — if the logit perturbation beats the gap, the ranking of the
  two positions is *reversed*: the model now attends to the wrong token.
* `attention_output_inversion_lower_bound` — the resulting output error is bounded
  **below** by `1/2 - 1/(1 + exp (2h))`, where `h` measures how far past the gap the noise
  went.  This is a lower bound of order `1`, not an upper bound.

The threshold is what the data want.  Because the noise halves per bit, the widths at
which the noise sits inside the critical band `[g/2, g)` form a set with **at most one**
element (`critical_band_subsingleton`); one bit below the band the argmax inverts, one bit
above it the noise is already below half the gap.  So a threshold law produces a 1–2-bit
transition, whereas `KVCacheCliffGeometry.cliff_width_lower_bound` shows the smooth law
needs `≥ 10` bits to move from `+0.142 %` to `+867.694 %`.  The NET-94 bracketing `(5,8]`
is therefore evidence for a gap-threshold mechanism, and the file ends with
`threshold_window_beats_smooth_window`, which contrasts the two window widths in a single
statement.
-/
import Mathlib
import Algebra.KVCacheRoleSplit
import Algebra.KVCacheCliffGeometry

namespace Catalog.Algebra.KVCache

open Finset

variable {n : ℕ} [NeZero n]

/-- **Softmax is order preserving.**  The attended position is exactly the arg-max of the
logits, so damage to the ranking is damage to the logits and nothing else. -/
theorem softmaxW_lt_iff (s : Fin n → ℝ) (i j : Fin n) :
    softmaxW s i < softmaxW s j ↔ s i < s j := by
  have hZ : (0:ℝ) < ∑ k, Real.exp (s k) := sum_exp_pos s
  unfold softmaxW
  rw [div_lt_div_iff_of_pos_right hZ, Real.exp_lt_exp]

/-- **Rank inversion.**  Position `j` genuinely dominates position `i` by the gap
`g = s j - s i > 0`, but a key perturbation whose differential `d i - d j` exceeds `g`
reverses the verdict: after quantisation the model attends more strongly to `i`.
No Lipschitz constant can undo this — the attended token is simply the wrong one. -/
theorem softmaxW_rank_inversion (s d : Fin n → ℝ) (i j : Fin n)
    (hgap : s i < s j) (hnoise : s j - s i < d i - d j) :
    softmaxW s i < softmaxW s j ∧
      softmaxW (fun k => s k + d k) j < softmaxW (fun k => s k + d k) i := by
  refine ⟨(softmaxW_lt_iff s i j).2 hgap, ?_⟩
  refine (softmaxW_lt_iff (fun k => s k + d k) j i).2 ?_
  show s j + d j < s i + d i
  linarith

/-! ## A lower bound on the damage: the two-position model -/

/-- The two-position logit vector `(0, g)`: one distractor and one attended token
separated by the gap `g`. -/
def twoLogits (g : ℝ) : Fin 2 → ℝ := ![0, g]

/-- The adversarial (and, for a quantiser, entirely typical) perturbation `(ε, -ε)`:
the distractor's logit is overestimated and the attended token's is underestimated. -/
def twoNoise (ε : ℝ) : Fin 2 → ℝ := ![ε, -ε]

lemma softmaxW_two_snd (a b : ℝ) :
    softmaxW ![a, b] 1 = Real.exp b / (Real.exp a + Real.exp b) := by
  simp [softmaxW, Fin.sum_univ_two]

/-- The attended token keeps at least half the mass before quantisation. -/
lemma half_le_softmaxW_two (g : ℝ) (hg : 0 ≤ g) : (1:ℝ)/2 ≤ softmaxW (twoLogits g) 1 := by
  have hpos : (0:ℝ) < Real.exp 0 + Real.exp g := by positivity
  rw [twoLogits, softmaxW_two_snd, le_div_iff₀ hpos]
  have : Real.exp 0 ≤ Real.exp g := Real.exp_le_exp.2 hg
  linarith

/-- After a perturbation that overshoots the gap by `2h`, the attended token retains at
most `1/(1 + exp (2h))` of the mass. -/
lemma softmaxW_two_perturbed_le (g h ε : ℝ) (hnoise : g + 2 * h ≤ 2 * ε) :
    softmaxW (fun k => twoLogits g k + twoNoise ε k) 1 ≤ 1 / (1 + Real.exp (2 * h)) := by
  have hrw : (fun k => twoLogits g k + twoNoise ε k) = ![0 + ε, g + -ε] := by
    funext k
    fin_cases k <;> simp [twoLogits, twoNoise]
  rw [hrw, softmaxW_two_snd]
  have hpos : (0:ℝ) < Real.exp (0 + ε) + Real.exp (g + -ε) := by positivity
  have hden : (0:ℝ) < 1 + Real.exp (2 * h) := by positivity
  rw [div_le_div_iff₀ hpos hden]
  have hmono : Real.exp (2 * h) * Real.exp (g + -ε) ≤ Real.exp (0 + ε) := by
    rw [← Real.exp_add]
    exact Real.exp_le_exp.2 (by linarith)
  nlinarith [Real.exp_pos (g + -ε), Real.exp_pos (0 + ε)]

/-- **A lower bound on the key-side damage.**  Read out the value `1` at the attended
position and `0` at the distractor.  If the key perturbation overshoots the top-two logit
gap by `2h`, the attention output is wrong by at least `1/2 - 1/(1 + exp (2h))`, a
quantity that tends to `1/2` as the overshoot grows.

This is the converse of `value_path_stable`: the value path can never move the output by
more than its own budget, whereas the key path moves it by an amount that depends only on
*whether* the noise beat the gap, not on how small the noise is. -/
theorem attention_output_inversion_lower_bound (g h ε : ℝ) (hg : 0 ≤ g) (hh : 0 ≤ h)
    (hnoise : g + 2 * h ≤ 2 * ε) :
    (1:ℝ)/2 - 1 / (1 + Real.exp (2 * h))
      ≤ |(∑ i, softmaxW (fun k => twoLogits g k + twoNoise ε k) i * (![0, 1] : Fin 2 → ℝ) i)
          - ∑ i, softmaxW (twoLogits g) i * (![0, 1] : Fin 2 → ℝ) i| := by
  have hlow := half_le_softmaxW_two g hg
  have hhigh := softmaxW_two_perturbed_le g h ε hnoise
  have hsum1 : ∑ i, softmaxW (fun k => twoLogits g k + twoNoise ε k) i
      * (![0, 1] : Fin 2 → ℝ) i
      = softmaxW (fun k => twoLogits g k + twoNoise ε k) 1 := by
    simp [Fin.sum_univ_two]
  have hsum2 : ∑ i, softmaxW (twoLogits g) i * (![0, 1] : Fin 2 → ℝ) i
      = softmaxW (twoLogits g) 1 := by
    simp [Fin.sum_univ_two]
  have hE : (1:ℝ) ≤ Real.exp (2 * h) := Real.one_le_exp (by linarith)
  have hhalf : 1 / (1 + Real.exp (2 * h)) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    linarith
  rw [hsum1, hsum2, abs_sub_comm, abs_of_nonneg (by linarith)]
  linarith

/-! ## Why a threshold law is sharp in bit width -/

/-- **The critical band holds at most one bit width.**  With noise `A/2ᵇ` halving per bit,
there is at most one `b` for which the noise sits in `[g/2, g)`: one bit less and the
noise beats the gap (arg-max inversion, `softmaxW_rank_inversion`), one bit more and it is
below half the gap.  A gap-threshold mechanism therefore has a transition window of one
to two bit widths — exactly the resolution at which NET-94 brackets the key floor.
(Positivity of the gap is not assumed: the band hypotheses already force `g > 0`.) -/
theorem critical_band_subsingleton {A g : ℝ} {b b' : ℕ}
    (hb : g / 2 ≤ A / 2 ^ b ∧ A / 2 ^ b < g)
    (hb' : g / 2 ≤ A / 2 ^ b' ∧ A / 2 ^ b' < g) : b = b' := by
  have key : ∀ p q : ℕ, p < q → g / 2 ≤ A / 2 ^ p → A / 2 ^ p < g → A / 2 ^ q < g / 2 := by
    intro p q hpq h1 h2
    have hstep : A / 2 ^ q ≤ A / 2 ^ (p + 1) := by
      have hp : (0:ℝ) < 2 ^ p := by positivity
      have h0 : 0 < A / 2 ^ p := lt_of_lt_of_le (by linarith) h1
      have hA : 0 < A := by
        rw [lt_div_iff₀ hp] at h0
        simpa using h0
      have hmono : (2:ℝ) ^ (p + 1) ≤ 2 ^ q :=
        pow_le_pow_right₀ (by norm_num) (by omega)
      exact div_le_div_of_nonneg_left hA.le (by positivity) hmono
    have hhalf : A / 2 ^ (p + 1) = (A / 2 ^ p) / 2 := by
      rw [pow_succ]
      field_simp
    linarith [hhalf ▸ hstep]
  by_contra hne
  rcases Nat.lt_or_ge b b' with h | h
  · have := key b b' h hb.1 hb.2
    linarith [hb'.1]
  · have hlt : b' < b := by omega
    have := key b' b hlt hb'.1 hb'.2
    linarith [hb.1]

/-- **Threshold beats smooth.**  Side by side: a gap-threshold key model confines the
free-to-broken transition to at most one bit width in the critical band, while any smooth
model `exp (c/2ᵇ) - 1` matching the NET-94 endpoints would need
`log (1+P) ≤ 2^(b₁-b₀) log (1+ρ)`, i.e. `≥ log₂ (log 9.67694 / log 1.00142) > 10` bit
widths.  The measured 3-bit bracket `(5,8]` is thus evidence *for* the threshold
mechanism and *against* the smooth one. -/
theorem threshold_window_beats_smooth_window {A g : ℝ} {b b' : ℕ}
    (hb : g / 2 ≤ A / 2 ^ b ∧ A / 2 ^ b < g)
    (hb' : g / 2 ≤ A / 2 ^ b' ∧ A / 2 ^ b' < g) :
    b = b' ∧ ¬ ∃ c : ℝ, 0 < c ∧ Real.exp (c / 2 ^ 8) ≤ 1 + 0.00142 ∧
      1 + 8.67694 ≤ Real.exp (c / 2 ^ 5) :=
  ⟨critical_band_subsingleton hb hb', net94_refutes_uniform_lipschitz_model⟩

end Catalog.Algebra.KVCache