/-
# The certified positional-stratum value law, its baseline, and the paper-219 erratum

The *simultaneous-commitment* (block) cost model of the positional-stratum framework:
`M` slots are split into a retained stratum `R` of relative size `μ` and its complement.
The algorithm commits to one block before probing, so it pays for the *whole* block it
scans: `μ·M` probes when the target is captured (probability `P`) and `(1-μ)·M` otherwise.
By the r̄-identity of `Applications.PositionalStratumMeasure` (block cost kernel,
`r̄_R = μM`, `r̄_C = (1-μ)M`) the expected cost is

  `EC(μ,P) = M · (μ·P + (1-μ)·(1-P))`,

and the certified value against the **full-scan-`M`** baseline is

  `S(μ,P) = 1 / (μ·P + (1-μ)·(1-P))`.

Results proved here.

* `certifiedValue_of_blockEC` — the law *is* the block-model speedup (derived, not
  posited); `blockEC_eq_rbar_combination` exhibits it as an instance of the r̄-identity.
* `certifiedValue_baseline_conditional`, `baseline_ratio` — **F3 is baseline-conditional**:
  against T1a's own `C₀ = (M+1)/2` baseline the same algorithm is worth strictly less, by
  the exact factor `(M+1)/(2M)`, i.e. asymptotically **half** the certified number.
* `descending_adversary_undercuts` — a same-prior adversary at a neighbouring admissible
  locus realises `5.3648… < 5.4054…`: the certified number is not a locus-free guarantee.
* `feasibility_mu_le_inv_certifiedValue` — the feasibility test `μ ≤ 1/S` holds on the whole
  admissible half-box `μ ≤ 1/2`, so it cannot be flipped by re-reading `P̂`.
* `erratum_row_value`, `erratum_rounded_value`, `erratum_gap` — the recorded row
  `(μ, P̂) = (0.02, 0.9853)` evaluates to `29.3152…`, whereas the printed `29.0698…` is the
  value at the **rounded** `P = 0.985`; `erratum_feasibility_unaffected` shows the
  feasibility verdict is nevertheless identical.
* `certifiedValue_symmetry`, `certifiedValue_swap`, `certifiedValue_gt_one`,
  `certifiedValue_strictMono_in_P` — structure of the law.
-/
import Applications.PositionalStratumMeasure

namespace PositionalStratum

noncomputable section

/-! ## The block (simultaneous-commitment) model -/

/-- Expected cost of the simultaneous-commitment algorithm on `M` slots with retained
fraction `μ` and capture probability `P`. -/
def blockEC (M : ℝ) (mu P : ℝ) : ℝ := M * (mu * P + (1 - mu) * (1 - P))

/-- The certified value law, stated against the full-scan-`M` baseline. -/
def certifiedValue (mu P : ℝ) : ℝ := 1 / (mu * P + (1 - mu) * (1 - P))

/-- The value of the same algorithm against T1a's own baseline `C₀ = (M+1)/2`. -/
def descValue (M : ℝ) (mu P : ℝ) : ℝ := ((M + 1) / 2) / blockEC M mu P

/-- The denominator of the certified law is positive on the admissible box. -/
lemma denom_pos {mu P : ℝ} (hmu : 0 < mu) (hmu1 : mu < 1) (hP : 0 < P) (hP1 : P < 1) :
    0 < mu * P + (1 - mu) * (1 - P) := by
  have h1 : 0 < mu * P := mul_pos hmu hP
  have h2 : 0 < (1 - mu) * (1 - P) := mul_pos (by linarith) (by linarith)
  linarith

lemma certifiedValue_pos {mu P : ℝ} (hmu : 0 < mu) (hmu1 : mu < 1) (hP : 0 < P)
    (hP1 : P < 1) : 0 < certifiedValue mu P := by
  rw [certifiedValue]
  exact one_div_pos.mpr (denom_pos hmu hmu1 hP hP1)

/-- **The certified law is the block-model speedup**, derived from the cost model. -/
theorem certifiedValue_of_blockEC {M mu P : ℝ} (hM : 0 < M)
    (hmu : 0 < mu) (hmu1 : mu < 1) (hP : 0 < P) (hP1 : P < 1) :
    M / blockEC M mu P = certifiedValue mu P := by
  have hd := denom_pos hmu hmu1 hP hP1
  rw [blockEC, certifiedValue]
  field_simp

/-- **The certified law is an instance of the r̄-identity**: with the block cost kernel the
conditional mean costs are the two block sizes, and `EC = P·r̄_R + (1-P)·r̄_C`. -/
theorem blockEC_eq_rbar_combination (M mu P : ℝ) :
    blockEC M mu P = P * (mu * M) + (1 - P) * ((1 - mu) * M) := by
  rw [blockEC]; ring

/-! ## F3 : the value is baseline-conditional -/

/-- The exact ratio between the two baselines: the certified value overstates the
`C₀ = (M+1)/2`-relative value by the factor `2M/(M+1)`, which tends to `2`. -/
theorem baseline_ratio {M mu P : ℝ} (hM : 0 < M)
    (hmu : 0 < mu) (hmu1 : mu < 1) (hP : 0 < P) (hP1 : P < 1) :
    descValue M mu P = certifiedValue mu P * ((M + 1) / (2 * M)) := by
  have hd := denom_pos hmu hmu1 hP hP1
  have hMne : M ≠ 0 := ne_of_gt hM
  rw [descValue, certifiedValue, blockEC]
  field_simp

/-- **Baseline-conditionality of F3.**  Against T1a's own `C₀ = (M+1)/2` baseline the very
same algorithm is worth strictly less than the certified number, and strictly more than
half of it: `S/2 < S_{C₀} < S`.  A value claim is meaningless without naming its
baseline. -/
theorem certifiedValue_baseline_conditional {M mu P : ℝ} (hM : 1 < M)
    (hmu : 0 < mu) (hmu1 : mu < 1) (hP : 0 < P) (hP1 : P < 1) :
    certifiedValue mu P / 2 < descValue M mu P ∧ descValue M mu P < certifiedValue mu P := by
  have hMpos : (0 : ℝ) < M := by linarith
  have hv : 0 < certifiedValue mu P := certifiedValue_pos hmu hmu1 hP hP1
  have hratio := baseline_ratio hMpos hmu hmu1 hP hP1
  have hlt1 : (M + 1) / (2 * M) < 1 := by
    rw [div_lt_one (by positivity)]
    linarith
  have hgt : (1 : ℝ) / 2 < (M + 1) / (2 * M) := by
    rw [div_lt_div_iff₀ (by norm_num) (by positivity)]
    linarith
  constructor
  · rw [hratio, div_eq_mul_one_div, mul_comm (certifiedValue mu P) (1 / 2)]
    calc 1 / 2 * certifiedValue mu P
        < ((M + 1) / (2 * M)) * certifiedValue mu P := by
          exact mul_lt_mul_of_pos_right hgt hv
      _ = certifiedValue mu P * ((M + 1) / (2 * M)) := by ring
  · rw [hratio]
    calc certifiedValue mu P * ((M + 1) / (2 * M))
        < certifiedValue mu P * 1 := by exact mul_lt_mul_of_pos_left hlt1 hv
      _ = certifiedValue mu P := by ring

/-! ## A same-prior adversary undercuts the certified number -/

/-- **The certified number is not a locus-free guarantee.**  At the certified anchor
`(μ, P) = (0.05, 0.85)` the law reads `S = 200/37 = 5.4054…`; a same-prior adversary that
re-books the locus slightly (to `μ = 0.052`, still admissible) realises only `5.3648…`,
strictly less.  Any guarantee must therefore pin the locus as well as the baseline. -/
theorem descending_adversary_undercuts :
    certifiedValue (1 / 20) (17 / 20) = 200 / 37 ∧
    certifiedValue (52 / 1000) (17 / 20) < certifiedValue (1 / 20) (17 / 20) ∧
    (5.3647 : ℝ) < certifiedValue (52 / 1000) (17 / 20) ∧
    certifiedValue (52 / 1000) (17 / 20) < 5.3649 := by
  refine ⟨by norm_num [certifiedValue], ?_, ?_, ?_⟩ <;>
    simp only [certifiedValue] <;> norm_num

/-! ## Feasibility is insensitive to the rounding of `P̂` -/

/-- **Feasibility test.**  On the whole admissible half-box `μ ≤ 1/2`, `P < 1`, the retained
fraction never exceeds the reciprocal of the certified value.  In particular the verdict
`μ ≤ 1/S` cannot be flipped by re-reading `P̂` at a different precision — this is why the
erratum below leaves all anchors' feasibility conclusions untouched. -/
theorem feasibility_mu_le_inv_certifiedValue {mu P : ℝ}
    (hmu : 0 < mu) (hmu2 : mu ≤ 1 / 2) (hP : 0 < P) (hP1 : P < 1) :
    mu ≤ 1 / certifiedValue mu P := by
  have hmu1 : mu < 1 := by linarith
  have hd := denom_pos hmu hmu1 hP hP1
  rw [certifiedValue, one_div_one_div]
  nlinarith [hd, hP1, hmu2]

/-! ## The paper-219 witness-table erratum -/

/-- The recorded row `(μ, P̂) = (0.02, 0.9853)` evaluates to `29.3152…` under the certified
law. -/
theorem erratum_row_value :
    certifiedValue (2 / 100) (9853 / 10000) = 10000000 / 341120 := by
  rw [certifiedValue]
  norm_num

/-- The printed value `29.0698…` is the certified law at the *rounded* `P = 0.985`. -/
theorem erratum_rounded_value :
    certifiedValue (2 / 100) (985 / 1000) = 1000000 / 34400 := by
  rw [certifiedValue]
  norm_num

/-- The two differ: the printed table entry understates the stored-`P̂` value, and the
two decimal readings `29.0698…` and `29.3152…` are pinned. -/
theorem erratum_gap :
    certifiedValue (2 / 100) (985 / 1000) < certifiedValue (2 / 100) (9853 / 10000) ∧
    (29.0697 : ℝ) < certifiedValue (2 / 100) (985 / 1000) ∧
    certifiedValue (2 / 100) (985 / 1000) < 29.0698 ∧
    (29.3151 : ℝ) < certifiedValue (2 / 100) (9853 / 10000) ∧
    certifiedValue (2 / 100) (9853 / 10000) < 29.3152 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> simp only [certifiedValue] <;> norm_num

/-- **The erratum does not touch feasibility.**  At both the stored and the rounded `P`,
the anchor `μ = 0.02` passes the feasibility test `μ ≤ 1/S`. -/
theorem erratum_feasibility_unaffected :
    (2 / 100 : ℝ) ≤ 1 / certifiedValue (2 / 100) (9853 / 10000) ∧
    (2 / 100 : ℝ) ≤ 1 / certifiedValue (2 / 100) (985 / 1000) :=
  ⟨feasibility_mu_le_inv_certifiedValue (by norm_num) (by norm_num) (by norm_num) (by norm_num),
   feasibility_mu_le_inv_certifiedValue (by norm_num) (by norm_num) (by norm_num) (by norm_num)⟩

/-- The stale prose locus `(0.115, 0.87)` gives `4.649…`, a different number from the
certified anchors — confirming that it belongs to a superseded locus. -/
theorem stale_locus_value :
    (4.6489 : ℝ) < certifiedValue (115 / 1000) (87 / 100) ∧
    certifiedValue (115 / 1000) (87 / 100) < 4.6491 := by
  constructor <;> simp only [certifiedValue] <;> norm_num

/-! ## Structure of the certified law -/

/-- The law is invariant under simultaneously complementing the retained fraction and the
capture probability. -/
theorem certifiedValue_symmetry (mu P : ℝ) :
    certifiedValue mu P = certifiedValue (1 - mu) (1 - P) := by
  rw [certifiedValue, certifiedValue]
  ring_nf

/-- The law is symmetric in its two bookings: "balance is position". -/
theorem certifiedValue_swap (mu P : ℝ) : certifiedValue mu P = certifiedValue P mu := by
  rw [certifiedValue, certifiedValue]
  ring_nf

/-- **Commitment never hurts, and strictly helps in the interior.**  On the open box the
certified value is strictly greater than `1`; equality is only approached at the degenerate
corners. -/
theorem certifiedValue_gt_one {mu P : ℝ} (hmu : 0 < mu) (hmu1 : mu < 1)
    (hP : 0 < P) (hP1 : P < 1) : 1 < certifiedValue mu P := by
  have hd := denom_pos hmu hmu1 hP hP1
  rw [certifiedValue, lt_one_div (by norm_num) hd]
  nlinarith [mul_pos hmu (sub_pos.mpr hP1), mul_pos hP (sub_pos.mpr hmu1)]

/-- **Monotonicity in the capture probability.**  Below the balance line `μ < 1/2` the
certified value is strictly increasing in `P`: better capture is always worth more. -/
theorem certifiedValue_strictMono_in_P {mu P Q : ℝ} (hmu : 0 < mu) (hmu2 : mu < 1 / 2)
    (hP : 0 < P) (hQ1 : Q < 1) (hPQ : P < Q) :
    certifiedValue mu P < certifiedValue mu Q := by
  have hP1 : P < 1 := lt_trans hPQ hQ1
  have hQ0 : 0 < Q := lt_trans hP hPQ
  have hmu1 : mu < 1 := by linarith
  have hdP := denom_pos hmu hmu1 hP hP1
  have hdQ := denom_pos hmu hmu1 hQ0 hQ1
  rw [certifiedValue, certifiedValue, div_lt_div_iff₀ hdP hdQ]
  nlinarith [hPQ, hmu2, hmu]

end

end PositionalStratum