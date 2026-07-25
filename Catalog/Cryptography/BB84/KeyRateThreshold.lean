import Mathlib

/-!
# BB84 Secret-Key Rate and the ~11% QBER Threshold

This file formalizes the information-theoretic core of the security of the BB84
quantum-key-distribution protocol: the *secret-key rate* and the famous
**quantum bit error rate (QBER) threshold of approximately 11%**.

For one-way post-processing the asymptotic secret-key fraction (the Shor–Preskill
/ CSS rate) is
`r(Q) = 1 - 2 H₂(Q)` (in bits),
where `H₂` is the binary entropy in **bits**.  Positivity of `r(Q)` is exactly the
condition under which secure key can be distilled.  Mathlib's `Real.binEntropy`
is measured in **nats** (`binEntropy 2⁻¹ = log 2`), so working in nats the secure
condition `1 - 2 H₂(Q) > 0` becomes
`log 2 - 2 · binEntropy Q > 0`,  i.e.  `binEntropy Q < (log 2)/2`.

We define `secureKeyRate Q := log 2 - 2 * Real.binEntropy Q` and prove:

* `secureKeyRate_pos_iff` — the secure condition is `binEntropy Q < (log 2)/2`.
* `secureKeyRate_strictAntiOn` — the key rate is strictly decreasing in the QBER on `[0, 1/2]`.
* `binEntropy_one_eighth_gt`, `binEntropy_one_sixteenth_lt` — tight numeric brackets
  that reduce to the *integer* facts `7^7 < 2^20` and `2^56 < 15^15`.
* `exists_threshold` — there is a critical QBER `p* ∈ (1/16, 1/8)`
  (i.e. between 6.25% and 12.5%, bracketing the textbook ≈ 11%) with `secureKeyRate p* = 0`.
* `threshold_unique` — that critical value is unique on `[0, 1/2]`.
* `secureKeyRate_one_quarter_neg` — at `Q = 1/4` (the intercept–resend QBER) the rate
  is negative, so no key can be distilled.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The BB84 one-way secret-key rate `1 - 2 H₂(Q)` changes
  sign at a QBER ≈ 0.11, and this transcendental threshold is pinned between two
  *rational* points whose comparison collapses to elementary integer inequalities.
EXPERIMENT (Experimenter): Float evaluation gives `binEntropy(1/16) - (log2)/2 ≈ -0.113`
  and `binEntropy(1/8) - (log2)/2 ≈ +0.030`, so the root lies in `(1/16, 1/8)`.
  Symbolically, `binEntropy(1/8) > (log2)/2 ⟺ 7·log 7 < 20·log 2 ⟺ 7^7 < 2^20`
  (823543 < 1048576) and `binEntropy(1/16) < (log2)/2 ⟺ 56·log 2 < 15·log 15 ⟺
  2^56 < 15^15`.  Existence then follows from continuity (IVT), uniqueness from
  strict monotonicity of `binEntropy` on `[0,1/2]`.
ANALYSIS (Analyst): The surprising payoff is that a transcendental QKD threshold is
  *certified* by two integer comparisons — no floating point or interval arithmetic
  on `log` is needed.  The true root ≈ 0.1100 sits comfortably inside `(1/16,1/8)`.
CRITIQUE (Critic): The bracket is honest (not vacuous): both endpoints are checked,
  and `secureKeyRate` is shown strictly monotone so the zero is unique. The
  intercept–resend value `1/4` is verified to be *strictly above* threshold.
SYNTHESIS (PI): `secureKeyRate` + monotonicity + IVT existence + uniqueness +
  integer-certified bracket + the intercept–resend corollary.
-/

open Real Set

noncomputable section

namespace BB84

/-- The asymptotic BB84 secret-key fraction, expressed in **nats**.
`secureKeyRate Q = log 2 - 2 · binEntropy Q`; it is positive iff the protocol
can distill secret key at quantum bit error rate `Q`. (Dividing by `log 2`
recovers the textbook `1 - 2 H₂(Q)` in bits.) -/
def secureKeyRate (Q : ℝ) : ℝ := Real.log 2 - 2 * Real.binEntropy Q

/-
The secure condition `secureKeyRate Q > 0` is exactly `binEntropy Q < (log 2)/2`.
-/
theorem secureKeyRate_pos_iff (Q : ℝ) :
    0 < secureKeyRate Q ↔ Real.binEntropy Q < Real.log 2 / 2 := by
  unfold secureKeyRate; constructor <;> intro h <;> linarith;

/-
The secret-key rate is strictly decreasing in the QBER on `[0, 1/2]`:
more eavesdropping-induced error means strictly less extractable key.
-/
theorem secureKeyRate_strictAntiOn :
    StrictAntiOn secureKeyRate (Set.Icc (0 : ℝ) 2⁻¹) := by
  -- By definition of $secureKeyRate$, we know that it is strictly decreasing on $[0, 1/2]$.
  intro x hx y hy hxy
  simp [secureKeyRate];
  convert Real.binEntropy_strictMonoOn hx hy hxy using 1

/-
Upper bracket: `binEntropy (1/8) > (log 2)/2`.
Reduces to the integer inequality `7^7 < 2^20`.
-/
theorem binEntropy_one_eighth_gt : Real.log 2 / 2 < Real.binEntropy (1 / 8) := by
  unfold binEntropy;
  field_simp;
  norm_num [ mul_comm, ← Real.log_rpow, ← Real.log_mul, Real.log_lt_log ]

/-
Lower bracket: `binEntropy (1/16) < (log 2)/2`.
Reduces to the integer inequality `2^56 < 15^15`.
-/
theorem binEntropy_one_sixteenth_lt : Real.binEntropy (1 / 16) < Real.log 2 / 2 := by
  -- Calculate the binEntropy at Q=1/16 and show it is less than (log 2)/2.
  have h_binEntropy_1_16 : Real.binEntropy (1 / 16) = (1 / 16) * Real.log 16 + (15 / 16) * Real.log (16 / 15) := by
    unfold binEntropy;
    norm_num;
  rw [ h_binEntropy_1_16, show ( 16 : ℝ ) = 2 ^ 4 by norm_num, Real.log_pow ] ; ring_nf ; norm_num;
  rw [ mul_div, mul_div, mul_div, div_add_div, div_lt_div_iff₀ ] <;> norm_num [ ← Real.log_rpow, mul_comm, ← Real.log_mul, Real.log_lt_log ]

/-
At `Q = 1/4`, `binEntropy (1/4) > (log 2)/2`. Reduces to `3 < 4`.
-/
theorem binEntropy_one_quarter_gt : Real.log 2 / 2 < Real.binEntropy (1 / 4) := by
  unfold binEntropy; norm_num; ring_nf; norm_num [ Real.log_pos ] ;
  rw [ show ( 4 : ℝ ) = 2 ^ 2 by norm_num, Real.log_pow ] ; ring_nf ; norm_num [ Real.log_pos ] ;

/-
**Threshold existence.** There is a critical QBER `p* ∈ (1/16, 1/8)`
(between 6.25% and 12.5%, bracketing the textbook ≈ 11%) at which the BB84
secret-key rate vanishes.
-/
theorem exists_threshold :
    ∃ p : ℝ, p ∈ Set.Ioo (1 / 16 : ℝ) (1 / 8) ∧ secureKeyRate p = 0 := by
  have h_ivt : ∃ p ∈ Set.Ioo (1 / 16 : ℝ) (1 / 8), Real.binEntropy p = Real.log 2 / 2 := by
    apply_rules [ intermediate_value_Ioo ] <;> norm_num;
    · exact Continuous.continuousOn ( by exact Real.binEntropy_continuous );
    · exact ⟨ binEntropy_one_sixteenth_lt, binEntropy_one_eighth_gt ⟩;
  exact h_ivt.imp fun x hx => ⟨ hx.1, by unfold secureKeyRate; linarith ⟩

/-
**Threshold uniqueness.** The critical QBER is unique on `[0, 1/2]`.
-/
theorem threshold_unique {p q : ℝ}
    (hp : p ∈ Set.Icc (0 : ℝ) 2⁻¹) (hq : q ∈ Set.Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) (hqz : secureKeyRate q = 0) : p = q := by
  exact StrictAntiOn.injOn ( secureKeyRate_strictAntiOn ) hp hq ( by linarith )

/-
**Above threshold ⇒ insecure.** At the intercept–resend QBER `Q = 1/4` the
secret-key rate is strictly negative, so no secret key can be distilled.
-/
theorem secureKeyRate_one_quarter_neg : secureKeyRate (1 / 4) < 0 := by
  convert sub_neg_of_lt ( mul_lt_mul_of_pos_left ( show Real.binEntropy ( 1 / 4 ) > Real.log 2 / 2 from binEntropy_one_quarter_gt ) zero_lt_two ) using 1;
  unfold secureKeyRate; ring;

end BB84