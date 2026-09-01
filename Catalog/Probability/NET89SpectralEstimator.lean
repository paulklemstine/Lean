import Probability.NET89RatioPhaseBoundary

/-!
# NET-89, cycle 10: a mixing measurement is a spectral measurement

Cycle 3's fair-comparison dichotomy says that a mixed-versus-pure budget excess which grows
with context can only happen for *gapless* profiles.  That is a qualitative statement, and
direction **D2/D5** asked for the quantitative version: can an observed budget be turned
into a certified bound on the decay ratio of the attention spectrum?

It can, and the argument is short once the uniform mass guarantee of the shared knee file
is made explicit in `r` and `τ`.

* `kstar_le_of_geometric_explicit` — the explicit universal budget: if
  `r ^ K ≤ (1 − τ)(1 − r)` then `k*(n) ≤ K` for **every** context length.  This is the
  effective form of `kstar_uniformly_bounded_of_geometric_decay`, with the existential
  budget replaced by a checkable inequality.
* `geometric_decay_mono` — a profile decaying at rate `r` also decays at every larger rate,
  so the criterion is monotone in the candidate ratio.
* `decay_ratio_gt_of_knee_exceeds` — **the estimator.**  A single measurement `k*(n) > K`
  *refutes* every candidate decay ratio `r₀` passing the criterion at `K`: the true ratio
  must exceed `r₀`.  Observed budgets therefore certify lower bounds on the decay ratio.
* `pool_geometric_decay` and `net89_mixed_measurement_bounds_decay_ratio` — the same
  conclusion straight from the NET-89 protocol: a mixed knee exceeding `2K` at context `2n`
  certifies `r₀ < r`.  The interleaved measurement is a measurement of the *model's*
  spectrum, not of the corpus — which is exactly the reinterpretation cycle 3 asked for.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 10):
 (H1) The existential universal budget can be made explicit and checkable.
 (H2) Its contrapositive is an estimator: a large observed knee excludes an interval of
      decay ratios.                                                          [BOLD]
 (H3) The estimator survives pooling and interleaving, with the mixed threshold at
      exactly twice the pure one — the same key-unit doubling as cycle 1.    [BOLD]

Experimenter: H1–H3 formalised below, zero sorries.  The mixed version uses only the
upper half of the cycle-1 bracket, so the parity slack of cycle 4 does not weaken it.

Analyst: the estimator explains why the NET-89 numbers are informative at all.  A knee of
20 at context 1024 with gate `τ` excludes every decay ratio `r₀` with
`r₀ ^ 20 ≤ (1 − τ)(1 − r₀)`; the *mixed* protocol needs a knee of `2K` to exclude the same
ratios, so mixing costs exactly one doubling of the measurement threshold and buys nothing
spectrally — a fair-comparison correction that the reported table does not make.

Critic: the estimator is one-sided by construction.  A *small* observed knee certifies
nothing about `r`, because a profile can have a small knee for reasons unrelated to
geometric decay; the theorem is stated in the direction that is actually justified.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v w : ℕ → ℝ} {r r₀ τ : ℝ} {n K : ℕ}

/-! ## 1. The explicit universal budget -/

/-- **The universal budget, made explicit.**  A checkable inequality between the decay
ratio, the gate and a candidate budget guarantees that the budget clears the gate at every
context length. -/
theorem kstar_le_of_geometric_explicit (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (hK : 1 ≤ K) (hcrit : r ^ K ≤ (1 - τ) * (1 - r))
    (hn : 1 ≤ n) : kstar w n τ ≤ K := by
  have hr1' : (0 : ℝ) < 1 - r := by linarith
  have hgate : τ ≤ 1 - r ^ K / (1 - r) := by
    have hdiv : r ^ K / (1 - r) ≤ 1 - τ := by
      rw [div_le_iff₀ hr1']
      nlinarith
    linarith
  exact kstar_le_of_pass
    (hgate.trans (retained_ge_of_geometric_decay hw hr0 hr1 hdec hK hn))

/-- Decay at rate `r` implies decay at every larger rate. -/
lemma geometric_decay_mono (hw : ∀ i, 0 < w i) (hdec : ∀ i, w (i + 1) ≤ r * w i)
    (hrr : r ≤ r₀) : ∀ i, w (i + 1) ≤ r₀ * w i := fun i =>
  le_trans (hdec i) (mul_le_mul_of_nonneg_right hrr (hw i).le)

/-! ## 2. The estimator -/

/-- **A large knee certifies a large decay ratio.**  If a measurement at any single context
length exceeds the budget `K`, then every candidate decay ratio `r₀` satisfying the explicit
criterion at `K` is *refuted*: the profile's true ratio must be strictly larger.  Observed
key budgets are therefore lower bounds on the attention spectrum's decay ratio. -/
theorem decay_ratio_gt_of_knee_exceeds (hw : ∀ i, 0 < w i)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (hr₀0 : 0 < r₀) (hr₀1 : r₀ < 1) (hK : 1 ≤ K)
    (hcrit : r₀ ^ K ≤ (1 - τ) * (1 - r₀)) (hn : 1 ≤ n) (hmeas : K < kstar w n τ) :
    r₀ < r := by
  by_contra hcon
  push_neg at hcon
  have hdec₀ : ∀ i, w (i + 1) ≤ r₀ * w i := geometric_decay_mono hw hdec hcon
  have := kstar_le_of_geometric_explicit hw hr₀0 hr₀1 hdec₀ hK hcrit hn
  omega

/-! ## 3. The NET-89 protocol as a spectral measurement -/

/-- A pooled mixture of two profiles with decay ratio `r` again has decay ratio `r`. -/
lemma pool_geometric_decay {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hdu : ∀ i, u (i + 1) ≤ r * u i) (hdv : ∀ i, v (i + 1) ≤ r * v i) :
    ∀ i, pool a b u v (i + 1) ≤ r * pool a b u v i := by
  intro i
  have h1 : a * u (i + 1) ≤ a * (r * u i) := mul_le_mul_of_nonneg_left (hdu i) ha
  have h2 : b * v (i + 1) ≤ b * (r * v i) := mul_le_mul_of_nonneg_left (hdv i) hb
  simp only [pool]
  nlinarith

/-- **The mixed protocol estimates the spectrum.**  A mixed knee exceeding `2K` at the
doubled context refutes every candidate decay ratio passing the criterion at `K`.  The
interleaved measurement therefore reports on the model's attention spectrum, and its
threshold is exactly twice the pure one — the same key-unit doubling that produces the
reported `+8` versus `+4`, and nothing more. -/
theorem net89_mixed_measurement_bounds_decay_ratio (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hdu : ∀ i, u (i + 1) ≤ r * u i)
    (hdv : ∀ i, v (i + 1) ≤ r * v i) (hr₀0 : 0 < r₀) (hr₀1 : r₀ < 1) (hK : 1 ≤ K)
    (hcrit : r₀ ^ K ≤ (1 - τ) * (1 - r₀)) (hn : 0 < n) (hτ : τ ≤ 1)
    (hmeas : 2 * K < kstar (mix u v) (2 * n) τ) :
    r₀ < r := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hpd : ∀ i, pool 1 1 u v (i + 1) ≤ r * pool 1 1 u v i :=
    pool_geometric_decay zero_le_one zero_le_one hdu hdv
  have hbr := (kstar_mix_bracket hu hv hn hτ).2
  have hpool : K < kstar (pool 1 1 u v) n τ := by omega
  exact decay_ratio_gt_of_knee_exceeds hpp hpd hr₀0 hr₀1 hK hcrit hn hpool

/-- **The reported number, read spectrally.**  The NET-89 table reports a mixed knee of
`20` at context `1024`.  At gate `0.99` that measurement alone excludes every attention
profile whose sorted weights decay at rate `1/2` or faster: the model's decay ratio must
exceed `1/2`.  This is the reported number's actual information content about the model,
as opposed to about the corpus. -/
theorem net89_reported_mixed_knee_excludes_half (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hdu : ∀ i, u (i + 1) ≤ r * u i) (hdv : ∀ i, v (i + 1) ≤ r * v i) (hn : 0 < n)
    (hmeas : kstar (mix u v) (2 * n) (99 / 100) = 20) :
    1 / 2 < r := by
  refine net89_mixed_measurement_bounds_decay_ratio (K := 9) (r₀ := 1 / 2) (τ := 99 / 100)
    hu hv hdu hdv
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) hn (by norm_num) ?_
  rw [hmeas]
  norm_num

end Catalog.Probability.NET89MixedDomainKnee