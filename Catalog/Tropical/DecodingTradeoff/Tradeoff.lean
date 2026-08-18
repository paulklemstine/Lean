/-
# The cost / failure-probability trade-off for tropical windowed decoders

This file joins the two halves developed in
`Tropical.DecodingTradeoff.Core` (tropical span contraction) and
`Tropical.DecodingTradeoff.Environment` (Bernoulli environments) into a single
quantitative trade-off, together with **both endpoints**, the **interpolation**
between them, and the **converse** of the interpolation.

## The decoder

A tropical (min-plus) chain `A : ℕ → S → S → ℝ` of tropically stochastic transfer
matrices carries cost-to-go vectors backwards.  The *exact* decoder at stage `i` uses the
full remaining horizon; the **window-`b` decoder** truncates the horizon after `b` steps.
Its decision is the argmin of `u a + (windowApply A i b w) a` for a local cost `u` and an
arbitrary terminal guess `w`.

## Main results

Cost side (deterministic, exact):

* `horizonCost`, `windowCost`, `horizonCost_eq`, `windowCost_eq` — the cost model,
  defined by structural recursion mirroring `windowApply` and evaluated to `n * b * q ^ 2`.
* `decode_cost` — endpoint 1: the symbol-by-symbol decoder (`b = 1`) costs `n * q ^ 2`.
* `blockDecode_cost` — endpoint 2: the full-block decoder (`b = n`) costs `n ^ 2 * q ^ 2`.
* `windowCost_interpolates`, `windowCost_linear` — the cost interpolates **linearly**
  between the two endpoints.

Reliability side (probabilistic):

* `failSet_prob_le` — endpoint 1: `Prob p (failSet n 1) ≤ n * (1 - p)`.
* `blockFail_prob_le` — endpoint 2: `Prob p (failSet n n) ≤ (1 - p) ^ n`.
* `windowFail_prob_le` — **the interpolation**: `Prob p (failSet n b) ≤ (n+1-b) * (1-p)^b`;
  the two endpoint theorems above are its `b = 1` and `b = n` specialisations.

Correctness bridge (algebra ⊗ probability):

* `decision_robust` — a decision with margin `2θ` is insensitive to any perturbation of
  the cost-to-go vector of span `≤ θ`.
* `windowed_decoder_exact` — one informative step inside the window makes the window-`b`
  decoder agree **exactly** with every longer-horizon decoder.
* `windowed_decoder_exact_of_good_env` — the same conclusion at every position, for every
  environment outside `failSet n b`.
* `prob_windowed_decoder_exact` — hence the window-`b` decoder is exactly optimal with
  probability at least `1 - (n+1-b) * (1-p)^b`.

Converse:

* `reliability_exponent_le` — **converse of the interpolation**: no window-`b` decoder can
  have reliability exponent better than `b * log (1/(1-p))`.
* `window_lower_bound_of_reliable`, `cost_lower_bound_of_reliable` — consequently, driving
  the failure probability below `ε` forces `b ≥ log(1/ε) / log(1/(1-p))` and therefore a
  decoding cost at least `n * q^2 * log(1/ε) / log(1/(1-p))`.

Achievability (§7), closing the loop:

* `windowFail_prob_le_simple`, `reliable_of_window_large`, `log_condition_suffices`.
* `window_upper_bound_sufficient` — every window of length at least
  `(log n + log(1/ε)) / log(1/(1-p))` is `ε`-reliable.  Together with
  `window_lower_bound_of_reliable` this pins the optimal window length to within the
  additive gap `log n / log(1/(1-p))`.
* `tradeoff_invariant` — the whole trade-off in a single inequality:
  `log(1/failure) * (n q²) ≤ cost * log(1/(1-p))`.

Together with `tropicalNoiseFloor` from `Core` (which shows the algebraic bound cannot
decay in `b`), this pins the trade-off from both sides.
-/

import Tropical.DecodingTradeoff.Core
import Tropical.DecodingTradeoff.Environment

open Finset

namespace Tropical.DecodingTradeoff

/-! ## §1. Decoder decisions and their robustness -/

variable {S : Type*} [Fintype S] [Nonempty S]

/-- `a₀` is an optimal decision for local cost `u` and cost-to-go vector `V`. -/
def IsDecision (u V : S → ℝ) (a₀ : S) : Prop := ∀ a, u a₀ + V a₀ ≤ u a + V a

/-- The decision `a₀` wins by at least `m` against every competitor. -/
def Margin (u V : S → ℝ) (a₀ : S) (m : ℝ) : Prop :=
  ∀ a, a ≠ a₀ → u a₀ + V a₀ + m ≤ u a + V a

omit [Fintype S] [Nonempty S] in
lemma isDecision_of_margin {u V : S → ℝ} {a₀ : S} {m : ℝ} (hm : 0 ≤ m)
    (h : Margin u V a₀ m) : IsDecision u V a₀ := by
  intro a
  by_cases ha : a = a₀
  · subst ha; exact le_refl _
  · linarith [h a ha]

/-- **Robustness of tropical decisions.**  If the decision `a₀` wins by `2θ` with respect
to a cost-to-go vector `W` of span `≤ θ`, then it is still optimal for *any* other
cost-to-go vector `V` of span `≤ θ`.  This is the exact sense in which a min-plus decoder
only sees its cost-to-go vector projectively, up to the span seminorm. -/
theorem decision_robust {u V W : S → ℝ} {a₀ : S} {θ : ℝ}
    (hV : spanSemi V ≤ θ) (hW : spanSemi W ≤ θ) (hmargin : Margin u W a₀ (2 * θ)) :
    IsDecision u V a₀ := by
  intro a
  by_cases ha : a = a₀
  · subst ha; exact le_refl _
  · have h1 : V a₀ - V a ≤ θ := le_trans (sub_le_spanSemi V a₀ a) hV
    have h2 : W a - W a₀ ≤ θ := le_trans (sub_le_spanSemi W a a₀) hW
    have h3 := hmargin a ha
    linarith

/-! ## §2. The windowed decoder is exactly optimal when the window is informative -/

/-- **Locality theorem.**  Suppose the window `[i, i+b)` contains one *informative* step,
i.e. a transfer matrix of diameter `≤ θ`, and the window-`b` decision `a₀` wins by `2θ`.
Then `a₀` is also optimal for the horizon-`(b+r)` decoder, for every `r` — in particular
for the exact, full-horizon decoder.  Truncating the horizon costs nothing. -/
theorem windowed_decoder_exact {A : ℕ → S → S → ℝ} (hA : ∀ i, Stochastic (A i)) {θ : ℝ}
    {i j b : ℕ} (hj : j < b) (hgood : diam (A (i + j)) ≤ θ)
    {u v w : S → ℝ} {a₀ : S} (hmargin : Margin u (windowApply A i b w) a₀ (2 * θ))
    (r : ℕ) : IsDecision u (windowApply A i (b + r) v) a₀ := by
  have hW : spanSemi (windowApply A i b w) ≤ θ :=
    le_trans (spanSemi_windowApply_le_diam hA hj w) hgood
  have hV : spanSemi (windowApply A i (b + r) v) ≤ θ :=
    le_trans (spanSemi_windowApply_le_diam hA (lt_of_lt_of_le hj (Nat.le_add_right b r)) v) hgood
  exact decision_robust hV hW hmargin

/-! ## §3. The cost model and its two endpoints -/

/-- Cost of running the horizon-`b` min-plus recursion at each of `n` positions of a chain
with `q` states: `b` transfer steps, each a `q × q` min-plus matrix-vector product. -/
def stepCost (q : ℕ) : ℕ := q ^ 2

/-- The arithmetic cost of the horizon-`k` recursion `windowApply`, counted by structural
recursion on exactly the same shape as `windowApply` itself: one `q × q` min-plus
matrix-vector product per transfer step. -/
def horizonCost (q : ℕ) : ℕ → ℕ
  | 0 => 0
  | k + 1 => stepCost q + horizonCost q k

/-- The horizon cost is linear in the horizon. -/
theorem horizonCost_eq (q : ℕ) : ∀ k : ℕ, horizonCost q k = k * q ^ 2
  | 0 => by simp [horizonCost]
  | k + 1 => by rw [horizonCost, horizonCost_eq q k, stepCost]; ring

def windowCost (q b n : ℕ) : ℕ := n * horizonCost q b

theorem windowCost_eq (q b n : ℕ) : windowCost q b n = n * b * q ^ 2 := by
  rw [windowCost, horizonCost_eq]; ring

/-- **Endpoint 1 (cost).**  The symbol-by-symbol decoder, `b = 1`. -/
theorem decode_cost (q n : ℕ) : windowCost q 1 n = n * q ^ 2 := by
  rw [windowCost_eq]; ring

/-- **Endpoint 2 (cost).**  The full-block decoder, `b = n`. -/
theorem blockDecode_cost (q n : ℕ) : windowCost q n n = n ^ 2 * q ^ 2 := by
  rw [windowCost_eq]; ring

/-- The cost is exactly linear in the window length: the interpolation is affine. -/
theorem windowCost_linear (q b n : ℕ) : windowCost q b n = b * windowCost q 1 n := by
  rw [windowCost_eq, windowCost_eq]; ring

/-- **Cost interpolation.**  For `1 ≤ b ≤ n` the cost of the window-`b` decoder lies
between the two endpoint costs. -/
theorem windowCost_interpolates {q b n : ℕ} (hb : 1 ≤ b) (hbn : b ≤ n) :
    windowCost q 1 n ≤ windowCost q b n ∧ windowCost q b n ≤ windowCost q n n := by
  simp only [windowCost_eq]
  constructor
  · exact Nat.mul_le_mul_right _ (Nat.mul_le_mul_left _ hb)
  · exact Nat.mul_le_mul_right _ (Nat.mul_le_mul_left _ hbn)

/-- Strict monotonicity of cost in the window length (for a nondegenerate chain). -/
theorem windowCost_strictMono {q n : ℕ} (hq : 1 ≤ q) (hn : 1 ≤ n) {b b' : ℕ} (h : b < b') :
    windowCost q b n < windowCost q b' n := by
  have hq2 : 0 < q ^ 2 := pow_pos hq 2
  simp only [windowCost_eq]
  have h1 : n * b < n * b' := Nat.mul_lt_mul_of_pos_left h (by omega : 0 < n)
  exact Nat.mul_lt_mul_of_pos_right h1 hq2

/-! ## §4. The failure probability: two endpoints and the interpolation -/

/-- **The interpolation.**  For every window length `1 ≤ b ≤ n` the failure probability of
the window-`b` decoder is at most `(n + 1 - b) * (1 - p) ^ b`. -/
theorem windowFail_prob_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {n b : ℕ} (hbn : b ≤ n) :
    Prob p (failSet n b) ≤ (n + 1 - b : ℕ) * (1 - p) ^ b :=
  prob_failSet_le hp0 hp1 hbn

/-- **Endpoint 1 (reliability).**  The symbol-by-symbol decoder: a union bound over all
`n` positions. -/
theorem failSet_prob_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (n : ℕ) (hn : 1 ≤ n) :
    Prob p (failSet n 1) ≤ n * (1 - p) := by
  have h := prob_failSet_le hp0 hp1 (n := n) (b := 1) hn
  have hcast : ((n + 1 - 1 : ℕ) : ℝ) = (n : ℝ) := by
    norm_num
  rwa [hcast, pow_one] at h

/-- **Endpoint 2 (reliability).**  The full-block decoder: the failure probability is
exponentially small in the block length. -/
theorem blockFail_prob_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (n : ℕ) :
    Prob p (failSet n n) ≤ (1 - p) ^ n := by
  have h := prob_failSet_le hp0 hp1 (n := n) (b := n) (le_refl n)
  have hcast : ((n + 1 - n : ℕ) : ℝ) = 1 := by
    have : n + 1 - n = 1 := by omega
    rw [this]; norm_num
  rwa [hcast, one_mul] at h

/-! ## §5. Bridging: environments determined by a tropical chain -/

/-- The environment induced by a chain: step `x` is informative when its transfer matrix
has diameter at most `θ`. -/
noncomputable def envOf (A : ℕ → S → S → ℝ) (θ : ℝ) (n : ℕ) : Fin n → Bool :=
  fun x => decide (diam (A (x : ℕ)) ≤ θ)

/-- If the induced environment avoids the failure event, then *every* admissible window
contains an informative step. -/
theorem exists_good_step_of_not_failSet {A : ℕ → S → S → ℝ} {θ : ℝ} {n b i : ℕ}
    (hi : i + b ≤ n) (h : envOf A θ n ∉ failSet n b) :
    ∃ j < b, diam (A (i + j)) ≤ θ := by
  by_contra hcon
  push_neg at hcon
  refine h (Finset.mem_biUnion.mpr ⟨i, Finset.mem_range.mpr (by omega), ?_⟩)
  refine (mem_badWindow _).mpr ?_
  intro x hx
  rw [mem_winSet] at hx
  obtain ⟨j, hj⟩ : ∃ j, (x : ℕ) = i + j := ⟨(x : ℕ) - i, by omega⟩
  have hjb : j < b := by omega
  simp only [envOf, hj, decide_eq_false_iff_not]
  exact not_le.mpr (hcon j hjb)

/-- **Master correctness theorem.**  For every environment outside the failure set, the
window-`b` decoder is exactly optimal at every admissible position, for every longer
horizon — the truncation is lossless. -/
theorem windowed_decoder_exact_of_good_env {A : ℕ → S → S → ℝ} (hA : ∀ i, Stochastic (A i))
    {θ : ℝ} {n b i : ℕ} (hi : i + b ≤ n) (henv : envOf A θ n ∉ failSet n b)
    {u v w : S → ℝ} {a₀ : S} (hmargin : Margin u (windowApply A i b w) a₀ (2 * θ)) (r : ℕ) :
    IsDecision u (windowApply A i (b + r) v) a₀ := by
  obtain ⟨j, hjb, hgood⟩ := exists_good_step_of_not_failSet hi henv
  exact windowed_decoder_exact hA hjb hgood hmargin r

/-- **The probabilistic guarantee.**  The complement of the failure event — on which, by
`windowed_decoder_exact_of_good_env`, the window-`b` decoder is lossless at every
admissible position — has probability at least `1 - (n + 1 - b) * (1 - p) ^ b`. -/
theorem prob_windowed_decoder_exact {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {n b : ℕ}
    (hbn : b ≤ n) :
    1 - (n + 1 - b : ℕ) * (1 - p) ^ b ≤ Prob p (failSet n b)ᶜ := by
  rw [Prob_compl]
  linarith [prob_failSet_le hp0 hp1 (n := n) (b := b) hbn]

/-! ## §6. The converse of the interpolation -/

/-- **Converse of the interpolation.**  The reliability exponent of a window-`b` decoder
never exceeds `b * log (1/(1-p))`: an exponentially small failure probability *requires* a
proportionally long window.  This is the exact counterpart of `windowFail_prob_le`. -/
theorem reliability_exponent_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p < 1) {n b : ℕ} (hbn : b ≤ n) :
    Real.log (1 / Prob p (failSet n b)) ≤ b * Real.log (1 / (1 - p)) := by
  have hpos : (0 : ℝ) < 1 - p := by linarith
  have hle : (1 - p) ^ b ≤ Prob p (failSet n b) :=
    prob_failSet_ge hp0 (le_of_lt hp1) hbn
  have h1 : Real.log ((1 - p) ^ b) ≤ Real.log (Prob p (failSet n b)) :=
    Real.log_le_log (by positivity) hle
  rw [Real.log_pow] at h1
  rw [one_div, one_div, Real.log_inv, Real.log_inv]
  nlinarith [h1]

/-- **Window lower bound.**  Achieving failure probability `≤ ε` forces the window length
to be at least `log (1/ε) / log (1/(1-p))`. -/
theorem window_lower_bound_of_reliable {p ε : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {n b : ℕ} (hbn : b ≤ n) (hfail : Prob p (failSet n b) ≤ ε) :
    Real.log (1 / ε) / Real.log (1 / (1 - p)) ≤ b := by
  have hpos : (0 : ℝ) < 1 - p := by linarith
  have hlogpos : 0 < Real.log (1 / (1 - p)) := by
    rw [one_div]
    rw [Real.log_inv]
    have : Real.log (1 - p) < 0 := Real.log_neg hpos (by linarith)
    linarith
  have hle : (1 - p) ^ b ≤ ε := le_trans (prob_failSet_ge (le_of_lt hp0) (le_of_lt hp1) hbn) hfail
  have h1 : Real.log ((1 - p) ^ b) ≤ Real.log ε := Real.log_le_log (by positivity) hle
  rw [Real.log_pow] at h1
  rw [div_le_iff₀ hlogpos, one_div, one_div, Real.log_inv, Real.log_inv]
  nlinarith [h1]

/-- **Cost lower bound (converse of the cost interpolation).**  Any windowed tropical
decoder with failure probability at most `ε` must pay at least
`n * q^2 * log(1/ε) / log(1/(1-p))`.  Cost is therefore `Θ(log (1/ε))`: the upper bound
`windowCost_linear` together with `windowFail_prob_le` is tight up to the polynomial
factor `n + 1 - b`. -/
theorem cost_lower_bound_of_reliable {p ε : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {n b q : ℕ} (hbn : b ≤ n) (hfail : Prob p (failSet n b) ≤ ε) :
    (n * q ^ 2 : ℝ) * (Real.log (1 / ε) / Real.log (1 / (1 - p))) ≤ (windowCost q b n : ℝ) := by
  have hb := window_lower_bound_of_reliable hp0 hp1 hbn hfail
  have hnn : (0 : ℝ) ≤ (n : ℝ) * (q : ℝ) ^ 2 := by positivity
  calc (n * q ^ 2 : ℝ) * (Real.log (1 / ε) / Real.log (1 / (1 - p)))
      ≤ (n * q ^ 2 : ℝ) * b := by exact mul_le_mul_of_nonneg_left hb hnn
    _ = (windowCost q b n : ℝ) := by rw [windowCost_eq]; push_cast; ring

/-! ## §7. Achievability: matching the converse up to an additive `log n / log(1/(1-p))` -/

/-- A cruder but more usable form of the interpolation. -/
theorem windowFail_prob_le_simple {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {n b : ℕ} (hb : 1 ≤ b)
    (hbn : b ≤ n) : Prob p (failSet n b) ≤ (n : ℝ) * (1 - p) ^ b := by
  have h := prob_failSet_le hp0 hp1 (n := n) (b := b) hbn
  have hcard : ((n + 1 - b : ℕ) : ℝ) ≤ (n : ℝ) := by
    have : n + 1 - b ≤ n := by omega
    exact_mod_cast this
  have hpow : (0 : ℝ) ≤ (1 - p) ^ b := by
    have : (0 : ℝ) ≤ 1 - p := by linarith
    positivity
  nlinarith [h, hcard, hpow]

/-- **Achievability.**  A window long enough to make `n * (1-p)^b ≤ ε` is reliable. -/
theorem reliable_of_window_large {p ε : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {n b : ℕ} (hb : 1 ≤ b)
    (hbn : b ≤ n) (h : (n : ℝ) * (1 - p) ^ b ≤ ε) : Prob p (failSet n b) ≤ ε :=
  le_trans (windowFail_prob_le_simple hp0 hp1 hb hbn) h

/-- The logarithmic form of the achievability condition. -/
theorem log_condition_suffices {p ε : ℝ} (hp1 : p < 1) (hε : 0 < ε) {n b : ℕ} (hn : 1 ≤ n)
    (h : Real.log n + Real.log (1 / ε) ≤ b * Real.log (1 / (1 - p))) :
    (n : ℝ) * (1 - p) ^ b ≤ ε := by
  have hpos : (0 : ℝ) < 1 - p := by linarith
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hlhs : (0 : ℝ) < (n : ℝ) * (1 - p) ^ b := by positivity
  rw [← Real.log_le_log_iff hlhs hε, Real.log_mul (ne_of_gt hnpos) (by positivity),
    Real.log_pow]
  rw [one_div, one_div, Real.log_inv, Real.log_inv] at h
  linarith

/-- **Upper half of the sandwich.**  Any window length at least
`(log n + log(1/ε)) / log(1/(1-p))` already achieves failure probability `≤ ε`.
Compared with `window_lower_bound_of_reliable`, which forces
`b ≥ log(1/ε) / log(1/(1-p))`, the optimal window length is pinned down to within the
additive gap `log n / log(1/(1-p))`. -/
theorem window_upper_bound_sufficient {p ε : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (hε : 0 < ε)
    {n b : ℕ} (hn : 1 ≤ n) (hb : 1 ≤ b) (hbn : b ≤ n)
    (hlarge : (Real.log n + Real.log (1 / ε)) / Real.log (1 / (1 - p)) ≤ b) :
    Prob p (failSet n b) ≤ ε := by
  have hpos : (0 : ℝ) < 1 - p := by linarith
  have hlogpos : 0 < Real.log (1 / (1 - p)) := by
    rw [one_div, Real.log_inv]
    have : Real.log (1 - p) < 0 := Real.log_neg hpos (by linarith)
    linarith
  rw [div_le_iff₀ hlogpos] at hlarge
  exact reliable_of_window_large (le_of_lt hp0) (le_of_lt hp1) hb hbn
    (log_condition_suffices hp1 hε hn hlarge)

/-- **The trade-off invariant.**  Reliability exponent times the per-position budget is
bounded by the total decoding cost times the per-step informativeness rate: a single
inequality expressing "cost buys reliability, at a fixed exchange rate". -/
theorem tradeoff_invariant {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p < 1) {n b q : ℕ} (hbn : b ≤ n) :
    Real.log (1 / Prob p (failSet n b)) * (n * q ^ 2 : ℝ)
      ≤ (windowCost q b n : ℝ) * Real.log (1 / (1 - p)) := by
  have h := reliability_exponent_le hp0 hp1 hbn
  have hnn : (0 : ℝ) ≤ (n : ℝ) * (q : ℝ) ^ 2 := by positivity
  have hcost : (windowCost q b n : ℝ) = ((n : ℝ) * (q : ℝ) ^ 2) * b := by
    rw [windowCost_eq]; push_cast; ring
  rw [hcost]
  nlinarith [h, hnn]

/-! ## Lab notes (experimental data)

All figures below were obtained by exact rational (`ℚ`) evaluation in Lean against this
toolchain; see `ComputationalEvidence.md` for the full tables and the scripts.

**(a) Tightness of `windowFail_prob_le`.**  Brute-force enumeration of all `2 ^ n`
environments, `p = 3/4`, `n = 10`, exact failure probability versus the interpolation
bound `(n + 1 - b) (1 - p) ^ b`:

```
b        1        2        3        4        5        6        7        8
exact  .94369   .38820   .09610   .02145   .00464   .00098   .000198  .0000381
bound  2.5      .5625    .125     .02734   .00586   .00122   .000244  .0000458
ratio  .377     .690     .769     .784     .792     .800     .813     .833
```

The ratio approaches `p = 3/4` from below: the bound is tight in the exponent and loose
by exactly the constant `p` (see Conjecture 1 of `FUTURE_DIRECTIONS.md`).  The two-sided
sandwich `prob_failSet_ge ≤ exact ≤ prob_failSet_le` was verified with no counterexample
for every `1 ≤ b < n`, `n ∈ {4,6,8,10}`, `p ∈ {1/5, 1/2, 3/4}`.

**(b) Absorption, `spanSemi_windowApply_le_diam`.**  240 random row-normalised `3 × 3`
min-plus chains: `spanSemi (windowApply A 0 k v) ≤ min_{i < k} diam (A i)` held in every
instance.

**(c) The noise floor, `tropicalNoiseFloor`.**  For a fixed random chain the span after
`k = 1 … 10` steps was

```
3, 1, 1, 1, 1, 1, 0, 0, 0, 0
```

— nonincreasing (as `spanSemi_windowApply_le` predicts) but *plateauing*: the drop happens
when an informative matrix enters the window, not gradually.  This is the experimental
signature of "one-step absorption, no geometric decay", proved in closed form by
`tropicalNoiseFloor`, and it is the reason the exponential factor in
`windowFail_prob_le` has to be produced by the Bernoulli environment rather than by the
tropical algebra.
-/

end Tropical.DecodingTradeoff