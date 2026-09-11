import Computation.BatchRootLawDiscrete
import Applications.BatchSmoothnessCost

/-!
# The batch-versus-solo crossover is a root of the setup/penalty ratio

Fourth research cycle.  `Catalog/Applications/BatchSmoothnessCost.lean` proves, in
the *schoolbook* word model, that batching a smoothness test beats testing
candidates one at a time exactly up to the crossover pool size
`M* = 1 + (s₁ - c₁)/q` (`BatchCost.word_crossover`), calibrated to the
measured `M* ≈ 1715`.

That formula is linear in the ratio `(s₁ - c₁)/q`.  Here we show that the linearity
is an artefact of `μ = 2`: with multiplication exponent `μ`, batch beats solo
exactly up to

`crossover q c₁ s₁ μ = (1 + (s₁ - c₁)/q) ^ (1/(μ-1))`,

a `1/(μ-1)`-th **root** of the same ratio (`batchWordM_le_iff_le_crossover`).  Three
consequences, all proved:

* `crossover_two` — at `μ = 2` the root law returns the catalog's linear formula,
  and `word_crossover_agrees` transports the ℚ-valued catalog statement onto it;
* `crossover_ge_of_mu_le_two` — for `μ ≤ 2` the crossover is *never smaller* than
  the schoolbook one: sub-quadratic arithmetic only ever pushes the reversal
  further out;
* `crossover_ge_of_mu_close_to_one` — quantitatively, the crossover diverges as
  `μ ↓ 1`, so in the flat op model there is no reversal at all, matching the
  measurements up to `k = 512`.

Together with `BatchRootLaw.optBatch_antitone_mu` this pins the measured
reversal on schoolbook arithmetic rather than on batching.
-/

namespace BatchRootLaw

open Real

/-! ## The per-candidate word model at exponent `μ` -/

/-- Per-candidate batch cost in the word model with multiplication exponent `μ`:
a product-tree penalty `q (k^(μ-1) - 1)` plus the per-candidate cost `c₁`.  At
`μ = 2` this is `BatchCost.batchWord q c₁ k / k`. -/
noncomputable def batchWordM (q c1 mu k : ℝ) : ℝ := q * (k ^ (mu - 1) - 1) + c1

/-- The crossover pool size: the largest batch for which batching still beats
testing candidates one at a time. -/
noncomputable def crossover (q c1 s1 mu : ℝ) : ℝ := (1 + (s1 - c1) / q) ^ (1 / (mu - 1))

/-- **Root form of the crossover.**  Batch is at most as expensive as solo exactly
for pools up to `(1 + (s₁-c₁)/q) ^ (1/(μ-1))`. -/
theorem batchWordM_le_iff_le_crossover {q c1 s1 mu k : ℝ} (hq : 0 < q) (hmu : 1 < mu)
    (hk : 0 < k) (hratio : 0 ≤ 1 + (s1 - c1) / q) :
    batchWordM q c1 mu k ≤ s1 ↔ k ≤ crossover q c1 s1 mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hstep : batchWordM q c1 mu k ≤ s1 ↔ k ^ (mu - 1) ≤ 1 + (s1 - c1) / q := by
    unfold batchWordM
    rw [show (1:ℝ) + (s1 - c1) / q = (q + s1 - c1) / q by field_simp; ring, le_div_iff₀ hq]
    constructor
    · intro h; nlinarith
    · intro h; nlinarith
  rw [hstep]
  unfold crossover
  have hpow : ((1 + (s1 - c1) / q) ^ (1 / (mu - 1))) ^ (mu - 1) = 1 + (s1 - c1) / q := by
    rw [← Real.rpow_mul hratio, one_div, inv_mul_cancel₀ hm1.ne', Real.rpow_one]
  constructor
  · intro h
    have h' : k ^ (mu - 1) ≤ ((1 + (s1 - c1) / q) ^ (1 / (mu - 1))) ^ (mu - 1) := by
      rw [hpow]; exact h
    exact (Real.rpow_le_rpow_iff hk.le (by positivity) hm1).mp h'
  · intro h
    have h' := Real.rpow_le_rpow hk.le h hm1.le
    rwa [hpow] at h'

/-- At `μ = 2` the root collapses to the catalog's linear crossover
`M* = 1 + (s₁ - c₁)/q`. -/
theorem crossover_two {q c1 s1 : ℝ} : crossover q c1 s1 2 = 1 + (s1 - c1) / q := by
  unfold crossover
  norm_num

/-- **Bridge to the catalog.**  The ℚ-valued schoolbook crossover theorem
`BatchCost.word_crossover` is exactly the `μ = 2` instance of the root
law. -/
theorem word_crossover_agrees {q c1 s1 k : ℚ} (hq : 0 < q) (hk : 0 < k) :
    BatchCost.batchWord q c1 k ≤ BatchCost.soloWord s1 k
      ↔ (k : ℝ) ≤ crossover (q : ℝ) (c1 : ℝ) (s1 : ℝ) 2 := by
  rw [BatchCost.word_crossover q c1 s1 hq hk, crossover_two]
  constructor
  · intro h; exact_mod_cast h
  · intro h; exact_mod_cast h

/-- **Sub-quadratic arithmetic only delays the reversal.**  If the schoolbook ratio
is at least one (`c₁ ≤ s₁`, the interesting regime) then lowering the exponent
from `2` to `μ` never lowers the crossover. -/
theorem crossover_ge_of_mu_le_two {q c1 s1 mu : ℝ} (hq : 0 < q) (hmu : 1 < mu) (hmu2 : mu ≤ 2)
    (hle : c1 ≤ s1) :
    crossover q c1 s1 2 ≤ crossover q c1 s1 mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hbase : (1:ℝ) ≤ 1 + (s1 - c1) / q := by
    have : 0 ≤ (s1 - c1) / q := div_nonneg (by linarith) hq.le
    linarith
  rw [crossover_two]
  unfold crossover
  have hexp : (1:ℝ) ≤ 1 / (mu - 1) := by
    rw [le_div_iff₀ hm1]; linarith
  calc 1 + (s1 - c1) / q = (1 + (s1 - c1) / q) ^ (1:ℝ) := (Real.rpow_one _).symm
    _ ≤ (1 + (s1 - c1) / q) ^ (1 / (mu - 1)) := Real.rpow_le_rpow_of_exponent_le hbase hexp

/-- **Divergence of the crossover as `μ ↓ 1`.**  If the exponent is close enough to
`1` — precisely, `(μ - 1) * Real.log M ≤ Real.log (1 + (s₁-c₁)/q)` with the ratio at
least one — then the crossover exceeds `M`.  In the flat model there is no
reversal at any pool size. -/
theorem crossover_ge_of_mu_close_to_one {q c1 s1 mu M : ℝ} (hq : 0 < q) (hmu : 1 < mu)
    (hle : c1 ≤ s1) (hM : 1 ≤ M)
    (hclose : (mu - 1) * Real.log M ≤ Real.log (1 + (s1 - c1) / q)) :
    M ≤ crossover q c1 s1 mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hM0 : (0:ℝ) < M := by linarith
  have hbase : (1:ℝ) ≤ 1 + (s1 - c1) / q := by
    have : 0 ≤ (s1 - c1) / q := div_nonneg (by linarith) hq.le
    linarith
  have hbase0 : (0:ℝ) < 1 + (s1 - c1) / q := by linarith
  have hlog : Real.log M ≤ (1 / (mu - 1)) * Real.log (1 + (s1 - c1) / q) := by
    rw [one_div, inv_mul_eq_div, le_div_iff₀ hm1]
    linarith
  exact (Real.le_rpow_iff_log_le hM0 hbase0).mpr hlog

/-- Numerical instance calibrated to the measured schoolbook crossover
`M* = 1715`: at exponent `μ = 3/2` the crossover is the *square* of the schoolbook
one, i.e. beyond `2.9 · 10⁶` candidates. -/
theorem crossover_karatsuba_calibrated {q c1 s1 : ℝ} (hq : 0 < q) (hcal : s1 - c1 = 1714 * q) :
    crossover q c1 s1 (3/2) = 1715 ^ (2:ℝ) := by
  have hratio : 1 + (s1 - c1) / q = 1715 := by
    rw [hcal, mul_div_assoc, div_self hq.ne']
    norm_num
  unfold crossover
  rw [hratio]
  norm_num

end BatchRootLaw