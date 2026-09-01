import Probability.NET89UnequalRates

/-!
# NET-89, cycle 12: the two-sided spectral bracket

Cycle 10 turned a *large* observed knee into a certified **lower** bound on the decay ratio
of the attention spectrum (`decay_ratio_gt_of_knee_exceeds`), and its Critic paragraph
flagged the obvious weakness: the estimator was one-sided, because a small knee was not
assumed to say anything.  Direction **D3** asked for the missing half.

This cycle supplies it.  The extra structural input is exactly what a *sorted* attention
profile always has and what the cycle-10 hypotheses never used: the weights are
non-increasing, and they do not fall off a cliff — there is a floor rate `q` with
`q · w i ≤ w (i+1)`.  Under that floor a *small* knee is genuinely informative: the head
cannot dominate a context that is at least twice as long as the budget, so a passing gate
forces `q` to be small.

* `weight_ge_geometric`, `weight_le_head`, `headMass_le_budget_mul_head` — the two
  elementary envelopes of a floored, sorted profile.
* `block_tail_ge_geometric` — the key estimate: the *second* block of `K` keys of a
  context of length `2K` carries at least `K · q ^ (2K) · w 0` of mass.
* `retained_le_of_ratio_floor` — **the dual of `retained_ge_of_geometric_decay`**: with a
  floor rate `q` and a context at least twice the budget, the retained mass at budget `K`
  is at most `1 / (1 + q ^ (2K))`, *independently of the context length*.
* `decay_floor_pow_le_of_knee_le` — **the second estimator.**  A knee measurement
  `k*(n) ≤ K` certifies `q ^ (2K) ≤ (1 − τ)/τ`: an *upper* bound on the floor rate.
* `net89_two_sided_spectral_bracket` — both halves at once.  A single exact knee value
  `k*(n) = K₀` brackets the profile's spectrum from both sides: `r₀ < r` and
  `q ^ (2K₀) ≤ (1 − τ)/τ`.
* `net89_reported_mixed_knee_bounds_floor` — the reported number, read in the new
  direction: a mixed knee of `20` at gate `0.99` forces the pooled profile's floor rate
  below `4/5`.  Together with cycle 10 (`r > 1/2`) the NET-89 table pins the model's
  per-key ratio into the window `(1/2, 4/5)` — a genuine two-sided spectral measurement
  extracted from two integers.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 12):
 (H1) A floor rate makes a small knee informative; the bound should be uniform in the
      context length once `n ≥ 2k`.                                            [BOLD]
 (H2) The resulting inequality is the exact mirror of the geometric-decay bound, with
      `(1 − τ)(1 − r)` replaced by `(1 − τ)/τ`.
 (H3) The two estimators combine into a nonempty window for the true ratio on the
      reported NET-89 numbers, i.e. the experiment measures a spectrum, not a corpus.
                                                                               [BOLD]

Experimenter: H1–H3 formalised below, zero sorries.  The `2K` in the exponent is not
cosmetic: the estimate spends `K` keys on the head envelope and `K` keys on the tail block,
and the floor has to survive to key `2K − 1`.

Analyst: the two bounds are genuinely dual.  Cycle 10 needs an upper envelope
(`w (i+1) ≤ r · w i`) and pays `(1 − τ)(1 − r)`; cycle 12 needs a lower envelope and pays
`(1 − τ)/τ`.  Neither implies the other, and the intersection of the two conclusions is a
window, not a point — the resolution of the estimator is set by the gate, matching the
staircase resolution of cycle 5.

Critic: the floor hypothesis is a real restriction — a profile with a hard cut-off (some
`w i = 0`) has no floor, and the theorem correctly says nothing about it.  The requirement
`n ≥ 2 k*` is also load-bearing: at `n = k*` the retained mass is `1` and no gate is
informative.  Both are stated as explicit hypotheses rather than hidden in the setup.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v w : ℕ → ℝ} {q r r₀ τ : ℝ} {n K : ℕ}

/-! ## 1. Envelopes of a floored, sorted profile -/

/-- A floor rate `q` propagates: the profile never falls below the geometric sequence
`q ^ i · w 0`. -/
lemma weight_ge_geometric (hq0 : 0 ≤ q) (hlow : ∀ i, q * w i ≤ w (i + 1)) :
    ∀ i, q ^ i * w 0 ≤ w i := by
  intro i
  induction i with
  | zero => simp
  | succ i ih =>
      calc q ^ (i + 1) * w 0 = q * (q ^ i * w 0) := by ring
        _ ≤ q * w i := mul_le_mul_of_nonneg_left ih hq0
        _ ≤ w (i + 1) := hlow i

/-- A sorted (non-increasing) profile is dominated by its first weight. -/
lemma weight_le_head (hanti : ∀ i, w (i + 1) ≤ w i) : ∀ i, w i ≤ w 0 := by
  intro i
  induction i with
  | zero => exact le_rfl
  | succ i ih => exact (hanti i).trans ih

/-- The head-mass envelope of a sorted profile. -/
lemma headMass_le_budget_mul_head (hanti : ∀ i, w (i + 1) ≤ w i) (k : ℕ) :
    headMass w k ≤ k * w 0 := by
  have h : ∑ _i ∈ range k, w 0 = k * w 0 := by
    rw [Finset.sum_const, card_range, nsmul_eq_mul]
  calc headMass w k ≤ ∑ _i ∈ range k, w 0 :=
        Finset.sum_le_sum fun i _ => weight_le_head hanti i
    _ = k * w 0 := h

/-- **The block estimate.**  Under a floor rate, the second block of `K` keys of a context
of length `2K` still carries at least `K · q ^ (2K) · w 0`. -/
lemma block_tail_ge_geometric (hw : ∀ i, 0 < w i) (hq0 : 0 ≤ q) (hq1 : q ≤ 1)
    (hlow : ∀ i, q * w i ≤ w (i + 1)) (K : ℕ) :
    (K : ℝ) * (q ^ (2 * K) * w 0) ≤ ∑ i ∈ Ico K (2 * K), w i := by
  have hterm : ∀ i ∈ Ico K (2 * K), q ^ (2 * K) * w 0 ≤ w i := by
    intro i hi
    rw [mem_Ico] at hi
    have h1 : q ^ (2 * K) ≤ q ^ i := pow_le_pow_of_le_one hq0 hq1 (by omega)
    have h2 : q ^ i * w 0 ≤ w i := weight_ge_geometric hq0 hlow i
    have h3 : q ^ (2 * K) * w 0 ≤ q ^ i * w 0 :=
      mul_le_mul_of_nonneg_right h1 (hw 0).le
    linarith
  have hcard : (Ico K (2 * K)).card = K := by
    rw [Nat.card_Ico]; omega
  have := Finset.card_nsmul_le_sum (Ico K (2 * K)) w (q ^ (2 * K) * w 0) hterm
  rwa [hcard, nsmul_eq_mul] at this

/-! ## 2. The dual retained-mass bound -/

/-- **The dual of the geometric-decay bound.**  A floored, sorted profile cannot
concentrate: at budget `K` in a context of length at least `2K` the retained mass is at
most `1 / (1 + q ^ (2K))`, uniformly in the context length. -/
theorem retained_le_of_ratio_floor (hw : ∀ i, 0 < w i) (hq0 : 0 < q) (hq1 : q ≤ 1)
    (hanti : ∀ i, w (i + 1) ≤ w i) (hlow : ∀ i, q * w i ≤ w (i + 1))
    (hK : 1 ≤ K) (hn : 2 * K ≤ n) :
    retained w n K ≤ 1 / (1 + q ^ (2 * K)) := by
  have hnpos : 0 < n := by omega
  have hMpos : 0 < headMass w n := headMass_pos hw hnpos
  have hsplit : headMass w (2 * K) = headMass w K + ∑ i ∈ Ico K (2 * K), w i := by
    rw [headMass, headMass, range_eq_Ico]
    exact (Finset.sum_Ico_consecutive w (Nat.zero_le K) (by omega : K ≤ 2 * K)).symm
  have hstep : headMass w (2 * K) ≤ headMass w n := headMass_mono hw hn
  have htail := block_tail_ge_geometric hw hq0.le hq1 hlow K
  have hhead := headMass_le_budget_mul_head (w := w) hanti K
  have hpowpos : (0 : ℝ) < q ^ (2 * K) := pow_pos hq0 _
  have hkey : headMass w K * (1 + q ^ (2 * K)) ≤ headMass w n := by
    have h1 : headMass w K * q ^ (2 * K) ≤ (K : ℝ) * (q ^ (2 * K) * w 0) := by
      have := mul_le_mul_of_nonneg_right hhead hpowpos.le
      nlinarith
    nlinarith
  rw [retained, min_eq_left (by omega : K ≤ n), div_le_div_iff₀ hMpos (by positivity)]
  linarith

/-! ## 3. The second estimator: a small knee bounds the floor rate -/

/-- **A small knee certifies a small floor rate.**  If the measured budget at context `n`
is at most `K` and the context is at least twice that budget, then the profile's floor rate
obeys `q ^ (2K) ≤ (1 − τ)/τ`.  This is the missing upper half of the cycle-10 estimator. -/
theorem decay_floor_pow_le_of_knee_le (hw : ∀ i, 0 < w i) (hq0 : 0 < q) (hq1 : q ≤ 1)
    (hanti : ∀ i, w (i + 1) ≤ w i) (hlow : ∀ i, q * w i ≤ w (i + 1))
    (hK : 1 ≤ K) (hn : 2 * K ≤ n) (hτ0 : 0 < τ) (hτ : τ ≤ 1)
    (hmeas : kstar w n τ ≤ K) :
    q ^ (2 * K) ≤ (1 - τ) / τ := by
  have hnpos : 0 < n := by omega
  have hpass : τ ≤ retained w n (kstar w n τ) := gate_le_retained_kstar hw hnpos hτ
  have hmono : retained w n (kstar w n τ) ≤ retained w n K := retained_mono hw n hmeas
  have hupper : retained w n K ≤ 1 / (1 + q ^ (2 * K)) :=
    retained_le_of_ratio_floor hw hq0 hq1 hanti hlow hK hn
  have hpowpos : (0 : ℝ) < q ^ (2 * K) := pow_pos hq0 _
  have hchain : τ ≤ 1 / (1 + q ^ (2 * K)) := le_trans hpass (le_trans hmono hupper)
  rw [le_div_iff₀ (by positivity)] at hchain
  rw [le_div_iff₀ hτ0]
  linarith

/-- The floor rate itself is bounded whenever a candidate rate fails the certificate. -/
theorem decay_floor_lt_of_knee_le (hw : ∀ i, 0 < w i) (hq0 : 0 < q) (hq1 : q ≤ 1)
    (hanti : ∀ i, w (i + 1) ≤ w i) (hlow : ∀ i, q * w i ≤ w (i + 1))
    (hK : 1 ≤ K) (hn : 2 * K ≤ n) (hτ0 : 0 < τ) (hτ : τ ≤ 1)
    (hmeas : kstar w n τ ≤ K) {q₀ : ℝ} (hq₀0 : 0 ≤ q₀)
    (hq₀ : (1 - τ) / τ < q₀ ^ (2 * K)) :
    q < q₀ := by
  by_contra hcon
  push_neg at hcon
  have hmono : q₀ ^ (2 * K) ≤ q ^ (2 * K) := pow_le_pow_left₀ hq₀0 hcon _
  have := decay_floor_pow_le_of_knee_le hw hq0 hq1 hanti hlow hK hn hτ0 hτ hmeas
  linarith

/-! ## 4. Both sides at once -/

/-- **The two-sided spectral bracket.**  A single exact knee measurement constrains the
attention spectrum from both directions: the per-key decay ratio must exceed every
candidate `r₀` passing the cycle-10 criterion one step below the measurement, and the
floor rate must satisfy the cycle-12 certificate at the measurement itself. -/
theorem net89_two_sided_spectral_bracket (hw : ∀ i, 0 < w i)
    (hanti : ∀ i, w (i + 1) ≤ w i)
    (hup : ∀ i, w (i + 1) ≤ r * w i) (hlow : ∀ i, q * w i ≤ w (i + 1))
    (hq0 : 0 < q) (hq1 : q ≤ 1) (hr₀0 : 0 < r₀) (hr₀1 : r₀ < 1)
    (hτ0 : 0 < τ) (hτ : τ ≤ 1) {K₀ : ℕ} (hK₀ : 2 ≤ K₀) (hn : 2 * K₀ ≤ n)
    (hcrit : r₀ ^ (K₀ - 1) ≤ (1 - τ) * (1 - r₀))
    (hmeas : kstar w n τ = K₀) :
    r₀ < r ∧ q ^ (2 * K₀) ≤ (1 - τ) / τ := by
  constructor
  · have hgt : K₀ - 1 < kstar w n τ := by omega
    exact decay_ratio_gt_of_knee_exceeds (K := K₀ - 1) hw hup hr₀0 hr₀1 (by omega) hcrit
      (by omega) hgt
  · exact decay_floor_pow_le_of_knee_le hw hq0 hq1 hanti hlow (by omega) hn hτ0 hτ
      (le_of_eq hmeas)

/-! ## 5. The reported NET-89 number, read from below -/

/-- Pooling preserves the sorted (non-increasing) shape. -/
lemma pool_antitone {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hu : ∀ i, u (i + 1) ≤ u i) (hv : ∀ i, v (i + 1) ≤ v i) :
    ∀ i, pool a b u v (i + 1) ≤ pool a b u v i := by
  intro i
  have h1 : a * u (i + 1) ≤ a * u i := mul_le_mul_of_nonneg_left (hu i) ha
  have h2 : b * v (i + 1) ≤ b * v i := mul_le_mul_of_nonneg_left (hv i) hb
  simp only [pool]
  linarith

/-- Pooling preserves a common floor rate. -/
lemma pool_ratio_floor {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hu : ∀ i, q * u i ≤ u (i + 1)) (hv : ∀ i, q * v i ≤ v (i + 1)) :
    ∀ i, q * pool a b u v i ≤ pool a b u v (i + 1) := by
  intro i
  have h1 : a * (q * u i) ≤ a * u (i + 1) := mul_le_mul_of_nonneg_left (hu i) ha
  have h2 : b * (q * v i) ≤ b * v (i + 1) := mul_le_mul_of_nonneg_left (hv i) hb
  simp only [pool]
  nlinarith

/-- **The reported mixed knee bounds the floor rate.**  The NET-89 table reports a mixed
knee of `20` at context `1024` with gate `0.99`.  Via the halving reduction that is a
pooled knee of at most `10`, and the cycle-12 estimator then forces the pooled profile's
floor rate below `4/5`.  Combined with `net89_reported_mixed_knee_excludes_half`
(`r > 1/2`), the two reported integers pin the model's per-key ratio into `(1/2, 4/5)`. -/
theorem net89_reported_mixed_knee_bounds_floor (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hau : ∀ i, u (i + 1) ≤ u i) (hav : ∀ i, v (i + 1) ≤ v i)
    (hlu : ∀ i, q * u i ≤ u (i + 1)) (hlv : ∀ i, q * v i ≤ v (i + 1))
    (hq0 : 0 < q) (hq1 : q ≤ 1) (hn : 20 ≤ n)
    (hmeas : kstar (mix u v) (2 * n) (99 / 100) = 20) :
    q < 4 / 5 := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hpa : ∀ i, pool 1 1 u v (i + 1) ≤ pool 1 1 u v i :=
    pool_antitone zero_le_one zero_le_one hau hav
  have hpl : ∀ i, q * pool 1 1 u v i ≤ pool 1 1 u v (i + 1) :=
    pool_ratio_floor zero_le_one zero_le_one hlu hlv
  have hτ : (99 : ℝ) / 100 ≤ 1 := by norm_num
  have hbr := (kstar_mix_bracket hu hv (n := n) (τ := 99 / 100) (by omega) hτ).1
  have hpool : kstar (pool 1 1 u v) n (99 / 100) ≤ 10 := by
    rw [hmeas] at hbr; omega
  refine decay_floor_lt_of_knee_le (K := 10) (q₀ := 4 / 5) hpp hq0 hq1 hpa hpl
    (by norm_num) (by omega) (by norm_num) hτ hpool (by norm_num) ?_
  norm_num

end Catalog.Probability.NET89MixedDomainKnee