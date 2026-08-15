import Mathlib
import Tropical.NeuralNetworks.EOSWidthTropicalSeparation

/-!
# EOS-WIDTH-DISTRIBUTION-SHIFT: the boundary-width "threshold" is a one-sided
distribution shift, not a sharp boundary

This file formalises the statistical content of round NET-26 and joins it to the
tropical separation theory of `EOSWidthTropicalSeparation`.

## Lab notes (experimental data formalised below)

Thirty-two arms of the plain `n = 5` carry task, `GRUCell(384 → 192)`, learned
`E`-dimensional EOS embedding zero-padded to 384, only `E` varying.  Final
accuracies (in basis points, i.e. units of `10⁻⁴`):

* `E = 20`, twelve arms (sweep ∪ construction-order verify ∪ endpoint sweep):
  `9990, 9990, 9990, 7440, 1240, 580, 310, 260, 170, 110, 60, 50`.
* `E ∈ {28, 64, 96, 128, 192, 256, 384}` × 2 seeds (14 arms) together with
  `E = 384`, seeds 2–7 (6 arms): all `10000`.

## Main results

* `no_sharp_boundary` — no width threshold `E₀` can reproduce the observed
  outcomes: two `E = 20` arms disagree, so the outcome is *not* a function of
  the width.  This is the formal refutation of the "sharp 28–384 threshold"
  reading of NET-25.
* `tail_dominance` / `tail_dominance_strict` — the `E ≥ 28` accuracy sample
  stochastically dominates the `E = 20` sample, strictly at the cure threshold:
  the shift is one-sided.
* `cure_rate_E20`, `cure_rate_robust` — the empirical cure rates `1/4` and `1`.
* `robust_regime_confidence` — a `20/20` clean sweep rules out any cure
  probability `p ≤ 0.86` at the 5% level.
* `homogeneous_null_rejected` — the *maximised* likelihood of the null
  hypothesis "one common cure probability governs both regimes" is smaller than
  `10⁻⁵` times the maximised likelihood of the two-regime alternative, uniformly
  in `p`.  Proved from scratch through the exponential bound
  `pow_le_scaled_exp` (a weighted AM–GM in disguise).
* `net26_regimes_are_tropical` — the bridge to the tropical model (via
  `eosVec_inDigitSpan_iff`): the `E = 20` arms are exactly the tropically
  indistinguishable ones, while every `E ≥ 28` arm owns exclusive dimensions.
-/

namespace EOSWidth

open Finset

/-! ## Part 0: the data -/

/-- One experimental arm: the EOS width used, and the final accuracy measured in
basis points (units of `10⁻⁴`). -/
structure Arm where
  width : ℕ
  accBp : ℕ
deriving DecidableEq, Repr

/-- Accuracies of the twelve `E = 20` arms. -/
def e20Bp : List ℕ := [9990, 9990, 9990, 7440, 1240, 580, 310, 260, 170, 110, 60, 50]

/-- Accuracies of the twenty `E ≥ 28` arms. -/
def robustBp : List ℕ := List.replicate 20 10000

/-- The `E = 20` arms. -/
def e20Arms : List Arm := e20Bp.map (fun a => ⟨20, a⟩)

/-- The `E ≥ 28` arms, with their widths. -/
def robustArms : List Arm :=
  [28, 28, 64, 64, 96, 96, 128, 128, 192, 192, 256, 256, 384, 384,
   384, 384, 384, 384, 384, 384].map (fun E => ⟨E, 10000⟩)

/-- All thirty-two NET-26 arms. -/
def net26Arms : List Arm := e20Arms ++ robustArms

/-- An arm counts as a clean cure when its accuracy is at least `0.9`. -/
def Cured (a : Arm) : Prop := 9000 ≤ a.accBp

instance : DecidablePred Cured := fun a => by unfold Cured; infer_instance

/-- Number of entries of an accuracy sample lying in the upper tail `[t, ∞)`. -/
def tailCount (l : List ℕ) (t : ℕ) : ℕ := (l.filter (fun a => t ≤ a)).length

lemma e20Bp_length : e20Bp.length = 12 := by decide

lemma robustBp_length : robustBp.length = 20 := by decide

lemma e20_tail_cure : tailCount e20Bp 9000 = 3 := by decide

lemma robust_tail_cure : tailCount robustBp 9000 = 20 := by decide

/-- Empirical clean-cure rate at `E = 20`: three of twelve. -/
theorem cure_rate_E20 : (tailCount e20Bp 9000 : ℚ) / e20Bp.length = 1 / 4 := by
  rw [e20_tail_cure, e20Bp_length]; norm_num

/-- Empirical clean-cure rate at `E ≥ 28`: twenty of twenty. -/
theorem cure_rate_robust : (tailCount robustBp 9000 : ℚ) / robustBp.length = 1 := by
  rw [robust_tail_cure, robustBp_length]; norm_num

/-! ## Part 1: there is no sharp width boundary -/

/-- A *sharp boundary* model claims the cure outcome is a function of the EOS
width alone: some `E₀` with "cured ↔ width ≥ E₀" across all arms. -/
def SharpBoundary (data : List Arm) : Prop :=
  ∃ E₀ : ℕ, ∀ a ∈ data, (Cured a ↔ E₀ ≤ a.width)

/-- **No sharp boundary.**  The NET-26 data set contains two arms of the *same*
EOS width with opposite outcomes, so no width threshold whatsoever reproduces
it.  (This is a deterministic refutation: it needs no probabilistic modelling.)
-/
theorem no_sharp_boundary : ¬ SharpBoundary net26Arms := by
  rintro ⟨E₀, h⟩
  have hmem1 : (⟨20, 9990⟩ : Arm) ∈ net26Arms := by decide
  have hmem2 : (⟨20, 170⟩ : Arm) ∈ net26Arms := by decide
  have h1 := (h _ hmem1).mp (by unfold Cured; norm_num)
  have h2 := (h _ hmem2).mpr h1
  unfold Cured at h2
  simp at h2

/-- The obstruction in a reusable form: any data set containing two equal-width
arms with different outcomes refutes every sharp-boundary model. -/
theorem no_sharp_boundary_of_split {data : List Arm} {a b : Arm}
    (ha : a ∈ data) (hb : b ∈ data) (hw : a.width = b.width)
    (hca : Cured a) (hcb : ¬ Cured b) : ¬ SharpBoundary data := by
  rintro ⟨E₀, h⟩
  exact hcb ((h b hb).mpr (hw ▸ (h a ha).mp hca))

/-! ## Part 2: the shift is one-sided (stochastic dominance) -/

lemma e20_tail_of_gt (t : ℕ) (ht : 9990 < t) : tailCount e20Bp t = 0 := by
  have : e20Bp.filter (fun a => t ≤ a) = [] := by
    rw [List.filter_eq_nil_iff]
    intro a ha
    have : a ≤ 9990 := by
      simp only [e20Bp, List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with h|h|h|h|h|h|h|h|h|h|h|h <;> omega
    simp only [decide_eq_true_eq]
    omega
  simp [tailCount, this]

lemma robust_tail_of_le (t : ℕ) (ht : t ≤ 10000) : tailCount robustBp t = 20 := by
  have : robustBp.filter (fun a => t ≤ a) = robustBp := by
    rw [List.filter_eq_self]
    intro a ha
    have : a = 10000 := List.eq_of_mem_replicate ha
    simp only [decide_eq_true_eq]
    omega
  rw [tailCount, this, robustBp_length]

lemma tailCount_le_length (l : List ℕ) (t : ℕ) : tailCount l t ≤ l.length :=
  List.length_filter_le _ _

/-- **One-sided distribution shift.**  For every accuracy level `t`, the tail
fraction of the `E ≥ 28` sample is at least that of the `E = 20` sample: the
robust regime's accuracy distribution stochastically dominates the fragile
one's. -/
theorem tail_dominance (t : ℕ) :
    (tailCount e20Bp t : ℚ) / 12 ≤ (tailCount robustBp t : ℚ) / 20 := by
  by_cases ht : t ≤ 10000
  · have h1 : tailCount e20Bp t ≤ 12 := by
      have := tailCount_le_length e20Bp t
      rwa [e20Bp_length] at this
    have h1' : (tailCount e20Bp t : ℚ) ≤ 12 := by exact_mod_cast h1
    have h20 : ((20 : ℕ) : ℚ) / 20 = 1 := by norm_num
    rw [robust_tail_of_le t ht, h20, div_le_one (by norm_num)]
    linarith
  · have hnn : (0 : ℚ) ≤ (tailCount robustBp t : ℚ) / 20 := by positivity
    rw [e20_tail_of_gt t (by omega)]
    simpa using hnn

/-- The dominance is **strict** at the clean-cure level: `3/12 < 20/20`. -/
theorem tail_dominance_strict :
    (tailCount e20Bp 9000 : ℚ) / 12 < (tailCount robustBp 9000 : ℚ) / 20 := by
  rw [e20_tail_cure, robust_tail_cure]; norm_num

/-- The median of the `E = 20` sample (mean of the two middle order statistics
of the sorted twelve-element sample) is `0.0445`, far below a cure. -/
theorem e20_median : ((e20Bp[5]! : ℚ) + (e20Bp[6]! : ℚ)) / 2 / 10000 = 445 / 10000 := by
  norm_num [e20Bp]

/-! ## Part 3: how strong is the `20/20` evidence? -/

/-- Under an i.i.d. Bernoulli model with per-arm cure probability `p ≤ 0.86`,
observing twenty clean cures in twenty arms has probability below `5%`: the
robust regime's cure probability is at least `0.86` at the usual one-sided
confidence level. -/
theorem robust_regime_confidence (p : ℝ) (hp0 : 0 ≤ p) (hp : p ≤ 86 / 100) :
    p ^ 20 < 5 / 100 := by
  calc p ^ 20 ≤ (86 / 100 : ℝ) ^ 20 := pow_le_pow_left₀ hp0 hp 20
    _ < 5 / 100 := by norm_num

/-- The exponential form of weighted AM–GM: `a ≤ c·exp(a/c − 1)` raised to the
`n`-th power.  This is the engine behind the likelihood bound. -/
lemma pow_le_scaled_exp (a : ℝ) (ha : 0 ≤ a) (c : ℝ) (hc : 0 < c) (n : ℕ) :
    a ^ n ≤ c ^ n * Real.exp (n * (a / c) - n) := by
  have h1 : a ≤ c * Real.exp (a / c - 1) := by
    have h0 := Real.add_one_le_exp (a / c - 1)
    have h2 : a / c ≤ Real.exp (a / c - 1) := by linarith
    calc a = c * (a / c) := by field_simp
      _ ≤ c * Real.exp (a / c - 1) := by nlinarith [hc.le]
  calc a ^ n ≤ (c * Real.exp (a / c - 1)) ^ n := pow_le_pow_left₀ ha h1 n
    _ = c ^ n * Real.exp (a / c - 1) ^ n := by rw [mul_pow]
    _ = c ^ n * Real.exp (n * (a / c) - n) := by rw [← Real.exp_nat_mul]; ring_nf

/-- The binomial kernel `p²³(1−p)⁹` — the shape of the pooled likelihood for
`3 + 20` successes and `9` failures — is maximised at `p = 23/32`. -/
theorem binomial_kernel_max (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    p ^ 23 * (1 - p) ^ 9 ≤ (23 / 32 : ℝ) ^ 23 * (9 / 32 : ℝ) ^ 9 := by
  have h1 := pow_le_scaled_exp p hp0 (23 / 32) (by norm_num) 23
  have h2 := pow_le_scaled_exp (1 - p) (by linarith) (9 / 32) (by norm_num) 9
  have e1 : ((23 : ℕ) : ℝ) * (p / (23 / 32)) - (23 : ℕ) = 32 * p - 23 := by push_cast; ring
  have e2 : ((9 : ℕ) : ℝ) * ((1 - p) / (9 / 32)) - (9 : ℕ) = 32 * (1 - p) - 9 := by
    push_cast; ring
  rw [e1] at h1
  rw [e2] at h2
  have hpos1 : (0 : ℝ) ≤ (23 / 32 : ℝ) ^ 23 * Real.exp (32 * p - 23) := by positivity
  have hstep : p ^ 23 * (1 - p) ^ 9 ≤
      ((23 / 32 : ℝ) ^ 23 * Real.exp (32 * p - 23)) *
        ((9 / 32 : ℝ) ^ 9 * Real.exp (32 * (1 - p) - 9)) :=
    mul_le_mul h1 h2 (pow_nonneg (by linarith) 9) hpos1
  have hexp : Real.exp (32 * p - 23) * Real.exp (32 * (1 - p) - 9) = 1 := by
    rw [← Real.exp_add, show 32 * p - 23 + (32 * (1 - p) - 9) = 0 by ring, Real.exp_zero]
  calc p ^ 23 * (1 - p) ^ 9 ≤ _ := hstep
    _ = ((23 / 32 : ℝ) ^ 23 * (9 / 32 : ℝ) ^ 9) *
          (Real.exp (32 * p - 23) * Real.exp (32 * (1 - p) - 9)) := by ring
    _ = (23 / 32 : ℝ) ^ 23 * (9 / 32 : ℝ) ^ 9 := by rw [hexp, mul_one]

/-- **The homogeneous-probability null is rejected.**  Suppose a single cure
probability `p` governed both regimes.  Its likelihood for the observed data
(3 cures out of 12 at `E = 20`, 20 out of 20 at `E ≥ 28`) is
`C(12,3)·p²³(1−p)⁹`, while the two-regime alternative attains
`C(12,3)·(1/4)³(3/4)⁹·1²⁰`.  Uniformly in `p`, the null likelihood is below
`10⁻⁵` times the alternative: the width regimes are genuinely different
distributions, but neither is deterministic. -/
theorem homogeneous_null_rejected (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    100000 * (p ^ 23 * (1 - p) ^ 9) ≤ (1 / 4 : ℝ) ^ 3 * (3 / 4 : ℝ) ^ 9 * 1 ^ 20 := by
  have h := binomial_kernel_max p hp0 hp1
  have hnum : 100000 * ((23 / 32 : ℝ) ^ 23 * (9 / 32 : ℝ) ^ 9)
      ≤ (1 / 4 : ℝ) ^ 3 * (3 / 4 : ℝ) ^ 9 * 1 ^ 20 := by norm_num
  linarith

/-! ## Part 4: bridge to the tropical mechanism -/

/-- The fragile arms of NET-26 (`E = 20`, digit width `D = 20`) are exactly the
tropically indistinguishable ones, and the robust arms (`E ≥ 28`) all own
exclusive dimensions. -/
theorem net26_regimes_are_tropical :
    InDigitSpan 384 20 (eosVec 384 20) ∧
      ∀ E : ℕ, 28 ≤ E → ¬ InDigitSpan 384 20 (eosVec 384 E) := by
  refine ⟨(eosVec_inDigitSpan_iff (by norm_num)).mpr le_rfl, ?_⟩
  intro E hE
  rw [eosVec_inDigitSpan_iff (by norm_num)]
  omega

end EOSWidth