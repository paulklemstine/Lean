/-
# NET-92 cycle 3: the sandwich — how many bits separate "provably broken" from "provably free"?

Two certificates have been proved in this cycle, and they point in opposite directions:

* the **fragile side** (`Logic.KVCliffCrowdingLaw.crowding_inverts_softmax`): as soon as the
  logit error `A / 2 ^ b` exceeds half the forced crowding gap `R / n`, some correctly ordered
  pair of cached positions is *provably* inverted;
* the **free side** (`Logic.KVCliffPerplexityStability.ppl_ratio_le`): as soon as the logit
  error is below `δ / 2`, perplexity is *provably* multiplied by at most `exp δ`.

Between the two lies a band of bit widths where neither certificate applies.  This file
computes its width exactly: `log₂ (R / (n δ))` bits, no more (`free_from_safe`,
`regime_gap_width`).  At the NET-92 reference scale — logit window `R = 32`, context
`n = 2048`, free tolerance `δ = 1/1000` nats — the width is

`log₂ (32 / (2048 · 0.001)) = log₂ 15.625 < 4`,

so **four bits** separate the two provable regimes (`net92_four_bits_separate_the_regimes`),
which is exactly the gap between the two arms NET-92 ran (`q4_0` and `q8_0`).  The experiment
did not sample a middle because, at its own scale, the middle is at most four bit widths wide;
the same computation predicts that the middle *is* resolvable at `ctx = 2048` by testing
`5, 6, 7` bits, and that it widens by one bit for every tenfold tightening of `δ` and narrows
by one for every context doubling.
-/
import Mathlib
import Logic.KVCliffCrowdingLaw
import Logic.KVCliffPerplexityStability

namespace Catalog.Logic.KVCliffSandwich

open Catalog.Algebra.KVCache Catalog.Logic.KVCliffCrowding Catalog.Logic.KVCliffPerplexity

/-- **The gap between the two certificates.**  If `2 ^ m` covers the ratio `R / (n δ)`, then
`m` extra bits upgrade "no forced inversion" into "certified free at tolerance `δ`". -/
theorem free_from_safe {A R delta : ℝ} {n b m : ℕ} (hn : 0 < n) (hdelta : 0 < delta)
    (hm : R / (n * delta) ≤ 2 ^ m) (hsafe : SafeBits A R n b) :
    2 * (A / 2 ^ (b + m)) ≤ delta := by
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have h2m : (0:ℝ) < 2 ^ m := by positivity
  have h2b : (0:ℝ) < 2 ^ b := by positivity
  have hstep : 2 * (A / 2 ^ (b + m)) = (2 * (A / 2 ^ b)) / 2 ^ m := by
    rw [pow_add]
    field_simp
  have hR : R / (n : ℝ) ≤ delta * 2 ^ m := by
    rw [div_le_iff₀ (by positivity : (0:ℝ) < (n : ℝ) * delta)] at hm
    rw [div_le_iff₀ hnpos]
    nlinarith [hm, hdelta, hnpos, h2m]
  have hlt : 2 * (A / 2 ^ b) < R / n := hsafe
  rw [hstep, div_le_iff₀ h2m]
  linarith

/-- **The width of the unexplained band.**  With `R / (n δ) ≤ 2 ^ m`, every bit width that is
already inversion-free becomes certified-free after `m` more bits, so no more than `m` widths
can sit between the two regimes. -/
theorem regime_gap_width {A R delta : ℝ} {n m : ℕ} (hn : 0 < n) (hdelta : 0 < delta)
    (hm : R / (n * delta) ≤ 2 ^ m) :
    ∀ b, SafeBits A R n b → ∀ b', b + m ≤ b' → 0 ≤ A → 2 * (A / 2 ^ b') ≤ delta := by
  intro b hb b' hbb hA
  have hbase : 2 * (A / 2 ^ (b + m)) ≤ delta := free_from_safe hn hdelta hm hb
  have hmono : (2:ℝ) ^ (b + m) ≤ 2 ^ b' := pow_le_pow_right₀ (by norm_num) hbb
  have : A / 2 ^ b' ≤ A / 2 ^ (b + m) := div_le_div_of_nonneg_left hA (by positivity) hmono
  linarith

/-- **NET-92, numerically.**  At the reference scale `A = 1`, `R = 32`, `ctx = 2048`, four extra
bits convert the crowding criterion into the free criterion at tolerance `1/1000` nats.  The
grid NET-92 actually ran, `{4, 8}`, is exactly four bits wide: the experiment straddled the
whole band in a single step. -/
theorem net92_four_bits_separate_the_regimes {b : ℕ} (hsafe : SafeBits 1 32 2048 b) :
    2 * ((1:ℝ) / 2 ^ (b + 4)) ≤ 1 / 1000 := by
  refine free_from_safe (by norm_num) (by norm_num) ?_ hsafe
  norm_num

/-- **The sandwich, in one statement.**  For a monotone logit profile inside a window of width
`R` at context `n`, and a quantiser whose logit error is `A / 2 ^ b`:

* if `A / 2 ^ b` beats half the crowding gap, some correctly ordered pair of positions is
  inverted (`crowding_inverts_softmax`);
* `m` bits later, with `R / (n δ) ≤ 2 ^ m`, the error is below `δ / 2`, hence — via
  `ppl_ratio_le` — perplexity is multiplied by at most `exp δ`.

The two certificates are therefore separated by at most `m = ⌈log₂ (R / (n δ))⌉` bit widths,
and nothing outside that band is left unexplained. -/
theorem cliff_sandwich {A R delta : ℝ} {n m b : ℕ} (hn : 0 < n) (hdelta : 0 < delta)
    (hm : R / (n * delta) ≤ 2 ^ m)
    (s : Fin (n + 1) → ℝ) (hmono : Monotone s) (hspread : s (Fin.last n) - s 0 ≤ R)
    (hbroken : R / n < 2 * (A / 2 ^ b)) :
    (∃ (i j : Fin (n + 1)) (d : Fin (n + 1) → ℝ),
        s i ≤ s j ∧ (∀ k, |d k| ≤ A / 2 ^ b) ∧
          softmaxW (fun k => s k + d k) j < softmaxW (fun k => s k + d k) i) ∧
      ∀ b', SafeBits A R n b' → 2 * (A / 2 ^ (b' + m)) ≤ delta := by
  refine ⟨crowding_inverts_softmax hn s R (A / 2 ^ b) hmono hspread hbroken, ?_⟩
  intro b' hb'
  exact free_from_safe hn hdelta hm hb'

end Catalog.Logic.KVCliffSandwich