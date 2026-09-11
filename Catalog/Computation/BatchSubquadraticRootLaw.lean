import Mathlib
import Applications.BatchSmoothnessYield

/-!
# The root law for optimal batch size under sub-quadratic multiplication

`Catalog/Applications/BatchSmoothnessYield.lean` established, for the *schoolbook*
(quadratic) big-integer model, that the per-candidate cost of streaming a batch of
size `k`,

`blockCost A c q k = A / k + c + q * (k - 1)`,

has a unique minimiser `k* = √(A/q)` with optimal value `c - q + 2√(Aq)`.

Real multiplication is not quadratic: Karatsuba, Toom–Cook and FFT-based products
have a multiplication exponent `μ` with `1 < μ ≤ 2` (and, in the idealised flat
op model, `μ = 1`).  The per-candidate cost then becomes

`blockCostM A c q μ k = A / k + c + q * (k ^ (μ - 1) - 1)`  (`^` = `Real.rpow`),

which specialises to `blockCost` at `μ = 2` (`blockCostM_two`).

## Main results

* `rpow_bernoulli_le` / `rpow_bernoulli_lt` — Bernoulli's inequality
  `μ u ≤ u ^ μ + (μ - 1)`, strict for `u ≠ 1`; the analytic engine of the file.
* `weighted_amgm_le` / `weighted_amgm_lt` — the weighted AM–GM shape
  `μ ≤ (μ-1)/u + u ^ (μ-1)`, equality exactly at `u = 1`.
* `balanced_cost_ge`, `balanced_cost_lt`, `balanced_cost_at` — a *balance
  principle*: whenever `t > 0` satisfies `A = q (μ-1) t ^ μ` (amortised setup =
  `(μ-1)` × marginal penalty), `t` is the strict global minimiser on `(0, ∞)`.
* `blockCostM_ge_optCost`, `blockCostM_at_optBatch`, `blockCostM_eq_optCost_iff` —
  **the root law**: the unique minimiser is `k* = (A / ((μ-1) q)) ^ (1/μ)` and the
  minimum is `c - q + μ (μ-1) ^ ((1-μ)/μ) A ^ ((μ-1)/μ) q ^ (1/μ)`.
* `isLeast_blockCostM_range`, `existsUnique_minimiser` — packaged as `IsLeast`
  and as a genuine `∃!`, so the alternative hypothesis "the optimum is not unique
  or not of root type" is *refuted*, not merely left untested.
* `blockCostM_two`, `optBatch_two`, `optCost_two`,
  `blockCost_eq_opt_iff_of_rootLaw` — consistency with the already-proved `μ = 2`
  case `BatchYield.blockCost_eq_opt_iff`, which is re-derived as a corollary.
* `blockCostM_one`, `blockCostM_one_strictAnti`, `no_optimum_of_mu_one` — the
  degeneration at `μ = 1`: bigger is always better, no interior optimum.
* `optBatch_scale_setup`, `optBatch_scale_penalty`, `optBatch_strictMono_setup` —
  the crossover is a `μ`-th root of the setup/penalty ratio: constant factors
  (GMP tuning) *relocate* the optimum but never remove it.
* `optBatch_ge_of_mu_close_to_one` — quantitatively, as `μ ↓ 1` the optimal batch
  diverges, so the flat model is the continuous limit of the root law.
* `optBatch_karatsuba_gt_schoolbook` — a numerical instance: sub-quadratic
  arithmetic pushes the optimal batch strictly above the schoolbook crossover.
-/

namespace BatchRootLaw

open Real

/-! ## Bernoulli and weighted AM–GM -/

/-- `x * x ^ (p - 1) = x ^ p` for `x > 0` (real exponents). -/
lemma rpow_sub_one_mul {x p : ℝ} (hx : 0 < x) : x * x ^ (p - 1) = x ^ p := by
  rw [Real.rpow_sub hx, Real.rpow_one]
  field_simp

/-- **Bernoulli's inequality**, in the shape used for the cost bound:
for `u ≥ 0` and `μ ≥ 1`, `μ u ≤ u ^ μ + (μ - 1)`. -/
lemma rpow_bernoulli_le {u mu : ℝ} (hu : 0 ≤ u) (hmu : 1 ≤ mu) :
    mu * u ≤ u ^ mu + (mu - 1) := by
  have h := one_add_mul_self_le_rpow_one_add (s := u - 1) (by linarith) hmu
  rw [show (1 : ℝ) + (u - 1) = u by ring] at h
  linarith

/-- **Strict Bernoulli.**  For `u ≥ 0`, `u ≠ 1` and `μ > 1`,
`μ u < u ^ μ + (μ - 1)`.  This strictness is exactly what makes the optimal batch
size unique. -/
lemma rpow_bernoulli_lt {u mu : ℝ} (hu : 0 ≤ u) (hu1 : u ≠ 1) (hmu : 1 < mu) :
    mu * u < u ^ mu + (mu - 1) := by
  have h := one_add_mul_self_lt_rpow_one_add (s := u - 1) (by linarith)
    (sub_ne_zero.mpr hu1) hmu
  rw [show (1 : ℝ) + (u - 1) = u by ring] at h
  linarith

/-- **Weighted AM–GM, normalised form.**  For `u > 0` and `μ ≥ 1`,
`μ ≤ (μ-1)/u + u ^ (μ-1)`.  The left side is the cost at the balanced point and
the right side the cost at the point `u` times the same scale. -/
lemma weighted_amgm_le {u mu : ℝ} (hu : 0 < u) (hmu : 1 ≤ mu) :
    mu ≤ (mu - 1) / u + u ^ (mu - 1) := by
  have hUu : u * u ^ (mu - 1) = u ^ mu := rpow_sub_one_mul hu
  have hbern := rpow_bernoulli_le hu.le hmu
  rw [← sub_nonneg]
  have key : (mu - 1) / u + u ^ (mu - 1) - mu = (u ^ mu + (mu - 1) - mu * u) / u := by
    rw [← hUu]; field_simp; ring
  rw [key]
  apply div_nonneg _ hu.le
  linarith

/-- **Weighted AM–GM, strict away from the balance point.** -/
lemma weighted_amgm_lt {u mu : ℝ} (hu : 0 < u) (hu1 : u ≠ 1) (hmu : 1 < mu) :
    mu < (mu - 1) / u + u ^ (mu - 1) := by
  have hUu : u * u ^ (mu - 1) = u ^ mu := rpow_sub_one_mul hu
  have hbern := rpow_bernoulli_lt hu.le hu1 hmu
  rw [← sub_pos]
  have key : (mu - 1) / u + u ^ (mu - 1) - mu = (u ^ mu + (mu - 1) - mu * u) / u := by
    rw [← hUu]; field_simp; ring
  rw [key]
  apply div_pos _ hu
  linarith

/-! ## The cost function -/

/-- Per-candidate cost of streaming in blocks of `k` candidates when big-integer
multiplication has exponent `μ`: a setup `A` amortised over the block, a
per-candidate cost `c`, and a product-tree penalty `q (k ^ (μ-1) - 1)`. -/
noncomputable def blockCostM (A c q mu k : ℝ) : ℝ := A / k + c + q * (k ^ (mu - 1) - 1)

/-- The conjectured optimal batch size `k* = (A / ((μ-1) q)) ^ (1/μ)`. -/
noncomputable def optBatch (A q mu : ℝ) : ℝ := (A / ((mu - 1) * q)) ^ (1 / mu)

/-- The conjectured optimal cost
`c - q + μ (μ-1) ^ ((1-μ)/μ) A ^ ((μ-1)/μ) q ^ (1/μ)`. -/
noncomputable def optCost (A c q mu : ℝ) : ℝ :=
  c - q + mu * (mu - 1) ^ ((1 - mu) / mu) * A ^ ((mu - 1) / mu) * q ^ (1 / mu)

/-! ## The balance principle -/

/-- Factorisation of the variable part of the cost around a balanced point `t`. -/
lemma cost_factor {q mu t k : ℝ} (ht : 0 < t) (hk : 0 < k) :
    q * (mu - 1) * t ^ mu / k + q * k ^ (mu - 1)
      = q * t ^ (mu - 1) * ((mu - 1) / (k / t) + (k / t) ^ (mu - 1)) := by
  have hTt : t * t ^ (mu - 1) = t ^ mu := rpow_sub_one_mul ht
  have hkr : k ^ (mu - 1) = (k / t) ^ (mu - 1) * t ^ (mu - 1) := by
    conv_lhs => rw [show k = (k / t) * t by field_simp]
    rw [Real.mul_rpow (by positivity) ht.le]
  rw [hkr, ← hTt]
  field_simp

/-- **Balance principle (lower bound).**  If `t > 0` balances the two nonconstant
terms in the sense `A = q (μ-1) t ^ μ`, then no block size beats `t`. -/
theorem balanced_cost_ge {A q mu t k : ℝ} (hq : 0 < q) (hmu : 1 < mu) (ht : 0 < t)
    (hbal : A = q * (mu - 1) * t ^ mu) (hk : 0 < k) :
    q * mu * t ^ (mu - 1) ≤ A / k + q * k ^ (mu - 1) := by
  subst hbal
  rw [cost_factor ht hk]
  have h := weighted_amgm_le (u := k / t) (div_pos hk ht) hmu.le
  have hscale := mul_le_mul_of_nonneg_left h
    (by positivity : (0:ℝ) ≤ q * t ^ (mu - 1))
  linarith

/-- **Balance principle (strictness).**  Any block size other than the balanced
point `t` is strictly worse. -/
theorem balanced_cost_lt {A q mu t k : ℝ} (hq : 0 < q) (hmu : 1 < mu) (ht : 0 < t)
    (hbal : A = q * (mu - 1) * t ^ mu) (hk : 0 < k) (hne : k ≠ t) :
    q * mu * t ^ (mu - 1) < A / k + q * k ^ (mu - 1) := by
  subst hbal
  rw [cost_factor ht hk]
  have hu1 : k / t ≠ 1 := by
    intro h
    rw [div_eq_one_iff_eq ht.ne'] at h
    exact hne h
  have h := weighted_amgm_lt (u := k / t) (div_pos hk ht) hu1 hmu
  have hscale := mul_lt_mul_of_pos_left h
    (by positivity : (0:ℝ) < q * t ^ (mu - 1))
  linarith

/-- The balanced point attains the bound. -/
theorem balanced_cost_at {A q mu t : ℝ} (ht : 0 < t)
    (hbal : A = q * (mu - 1) * t ^ mu) :
    A / t + q * t ^ (mu - 1) = q * mu * t ^ (mu - 1) := by
  subst hbal
  have hTt : t * t ^ (mu - 1) = t ^ mu := rpow_sub_one_mul ht
  rw [← hTt]
  field_simp
  ring

/-! ## The root law -/

section RootLaw

variable {A c q mu k : ℝ}

lemma optBatch_pos (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) : 0 < optBatch A q mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  exact Real.rpow_pos_of_pos (by positivity) _

/-- The conjectured optimum really is the balanced point: `A = q (μ-1) (k*) ^ μ`. -/
theorem optBatch_balanced (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    A = q * (mu - 1) * (optBatch A q mu) ^ mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hm1' : mu - 1 ≠ 0 := by linarith
  have hB : (0:ℝ) < A / ((mu - 1) * q) := by positivity
  have hmu0 : mu ≠ 0 := by linarith
  unfold optBatch
  rw [← Real.rpow_mul hB.le, one_div, inv_mul_cancel₀ hmu0, Real.rpow_one]
  field_simp

/-- **Equipartition at the optimum.**  The amortised setup cost is exactly `(μ-1)`
times the marginal multiplication penalty.  For `μ = 2` this is the classical
"setup = penalty" balance behind `√(A/q)`; for `μ → 1` the setup share collapses,
which is why the optimum escapes to infinity. -/
theorem optBatch_equipartition (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    A / optBatch A q mu = (mu - 1) * (q * (optBatch A q mu) ^ (mu - 1)) := by
  have hbal := optBatch_balanced hA hq hmu
  set t := optBatch A q mu with hdef
  have ht : 0 < t := hdef ▸ optBatch_pos hA hq hmu
  have hTt : t * t ^ (mu - 1) = t ^ mu := rpow_sub_one_mul ht
  rw [div_eq_iff ht.ne', hbal, ← hTt]
  ring

/-- The closed form of the optimal value: `q μ (k*) ^ (μ-1)` is exactly the
conjectured `μ (μ-1) ^ ((1-μ)/μ) A ^ ((μ-1)/μ) q ^ (1/μ)`. -/
theorem optBatch_value (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    q * mu * (optBatch A q mu) ^ (mu - 1)
      = mu * (mu - 1) ^ ((1 - mu) / mu) * A ^ ((mu - 1) / mu) * q ^ (1 / mu) := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hmu0 : mu ≠ 0 := by linarith
  have hB : (0:ℝ) < A / ((mu - 1) * q) := by positivity
  have hs : (1 / mu) * (mu - 1) = (mu - 1) / mu := by field_simp
  have h1 : (optBatch A q mu) ^ (mu - 1) = (A / ((mu - 1) * q)) ^ ((mu - 1) / mu) := by
    unfold optBatch
    rw [← Real.rpow_mul hB.le, hs]
  have hq1 : q / q ^ ((mu - 1) / mu) = q ^ (1 / mu) := by
    rw [show (1:ℝ) / mu = 1 - (mu - 1) / mu by field_simp; ring, Real.rpow_sub hq,
      Real.rpow_one]
  have hneg : ((mu - 1) : ℝ) ^ ((1 - mu) / mu) = ((mu - 1) ^ ((mu - 1) / mu))⁻¹ := by
    rw [show (1 - mu) / mu = -((mu - 1) / mu) by ring, Real.rpow_neg hm1.le]
  have hne1 : ((mu - 1) : ℝ) ^ ((mu - 1) / mu) ≠ 0 := by positivity
  have hne2 : q ^ ((mu - 1) / mu) ≠ 0 := by positivity
  rw [h1, Real.div_rpow hA.le (by positivity), Real.mul_rpow hm1.le hq.le, hneg, ← hq1]
  field_simp

/-- **Root law, lower bound.**  No block size beats `optCost`. -/
theorem blockCostM_ge_optCost (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) (hk : 0 < k) :
    optCost A c q mu ≤ blockCostM A c q mu k := by
  have h := balanced_cost_ge (t := optBatch A q mu) hq hmu (optBatch_pos hA hq hmu)
    (optBatch_balanced hA hq hmu) hk
  rw [optBatch_value hA hq hmu] at h
  unfold optCost blockCostM
  linarith

/-- **Root law, attainment.**  `k* = (A/((μ-1)q)) ^ (1/μ)` achieves `optCost`. -/
theorem blockCostM_at_optBatch (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    blockCostM A c q mu (optBatch A q mu) = optCost A c q mu := by
  have h := balanced_cost_at (q := q) (optBatch_pos hA hq hmu) (optBatch_balanced hA hq hmu)
  rw [optBatch_value hA hq hmu] at h
  unfold optCost blockCostM
  linarith

/-- **Root law, strict suboptimality elsewhere.** -/
theorem blockCostM_gt_optCost_of_ne (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) (hk : 0 < k)
    (hne : k ≠ optBatch A q mu) :
    optCost A c q mu < blockCostM A c q mu k := by
  have h := balanced_cost_lt (t := optBatch A q mu) hq hmu (optBatch_pos hA hq hmu)
    (optBatch_balanced hA hq hmu) hk hne
  rw [optBatch_value hA hq hmu] at h
  unfold optCost blockCostM
  linarith

/-- **Uniqueness of the optimal batch size.**  For `A, q > 0` and `1 < μ`, the
per-candidate cost equals its infimum exactly at `k* = (A/((μ-1)q)) ^ (1/μ)`. -/
theorem blockCostM_eq_optCost_iff (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) (hk : 0 < k) :
    blockCostM A c q mu k = optCost A c q mu ↔ k = optBatch A q mu := by
  constructor
  · intro h
    by_contra hne
    exact absurd h (blockCostM_gt_optCost_of_ne hA hq hmu hk hne).ne'
  · rintro rfl
    exact blockCostM_at_optBatch hA hq hmu

/-- The infimum of the cost over all positive block sizes is attained and equals
`optCost`. -/
theorem isLeast_blockCostM_range (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    IsLeast {y : ℝ | ∃ k : ℝ, 0 < k ∧ blockCostM A c q mu k = y} (optCost A c q mu) := by
  constructor
  · exact ⟨optBatch A q mu, optBatch_pos hA hq hmu, blockCostM_at_optBatch hA hq hmu⟩
  · rintro y ⟨k, hk, rfl⟩
    exact blockCostM_ge_optCost hA hq hmu hk

/-- **The optimum exists and is unique** — the conjecture in its sharpest form.
This refutes the alternative hypothesis that the minimiser might fail to be
unique. -/
theorem existsUnique_minimiser (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    ∃! t : ℝ, 0 < t ∧ ∀ k : ℝ, 0 < k → blockCostM A c q mu t ≤ blockCostM A c q mu k := by
  refine ⟨optBatch A q mu, ⟨optBatch_pos hA hq hmu, ?_⟩, ?_⟩
  · intro k hk
    rw [blockCostM_at_optBatch hA hq hmu]
    exact blockCostM_ge_optCost hA hq hmu hk
  · rintro t ⟨ht, hmin⟩
    by_contra hne
    have h1 : blockCostM A c q mu t ≤ blockCostM A c q mu (optBatch A q mu) :=
      hmin _ (optBatch_pos hA hq hmu)
    rw [blockCostM_at_optBatch hA hq hmu] at h1
    exact absurd h1 (not_le.mpr (blockCostM_gt_optCost_of_ne hA hq hmu ht hne))

end RootLaw

/-! ## Consistency with the quadratic (`μ = 2`) case -/

/-- At `μ = 2` the model is literally the schoolbook model of
`BatchYield.blockCost`. -/
theorem blockCostM_two (A c q k : ℝ) : blockCostM A c q 2 k = BatchYield.blockCost A c q k := by
  unfold blockCostM BatchYield.blockCost
  norm_num

/-- At `μ = 2` the root law returns the square-root law `k* = √(A/q)`. -/
theorem optBatch_two {A q : ℝ} : optBatch A q 2 = Real.sqrt (A / q) := by
  unfold optBatch
  rw [Real.sqrt_eq_rpow]
  norm_num

/-- At `μ = 2` the optimal value is `c - q + 2√(Aq)`, matching
`BatchYield.blockCost_at_sqrt`. -/
theorem optCost_two {A c q : ℝ} (hA : 0 ≤ A) (hq : 0 ≤ q) :
    optCost A c q 2 = c - q + 2 * Real.sqrt (A * q) := by
  unfold optCost
  rw [Real.sqrt_eq_rpow, Real.mul_rpow hA hq]
  norm_num
  ring

/-- The generalisation is faithful: it re-derives the already-established `μ = 2`
characterisation `BatchYield.blockCost_eq_opt_iff`. -/
theorem blockCost_eq_opt_iff_of_rootLaw {A c q k : ℝ} (hA : 0 < A) (hq : 0 < q) (hk : 0 < k) :
    BatchYield.blockCost A c q k = c - q + 2 * Real.sqrt (A * q) ↔ k = Real.sqrt (A / q) := by
  rw [← blockCostM_two, ← optCost_two hA.le hq.le, ← optBatch_two]
  exact blockCostM_eq_optCost_iff hA hq (by norm_num) hk

/-! ## Degeneration at `μ = 1`: bigger is always better -/

/-- At `μ = 1` the penalty term vanishes identically. -/
theorem blockCostM_one (A c q k : ℝ) : blockCostM A c q 1 k = A / k + c := by
  unfold blockCostM
  norm_num

/-- With `μ = 1` the per-candidate cost is strictly decreasing: no optimum. -/
theorem blockCostM_one_strictAnti {A c q k₁ k₂ : ℝ} (hA : 0 < A) (hk₁ : 0 < k₁)
    (h : k₁ < k₂) : blockCostM A c q 1 k₂ < blockCostM A c q 1 k₁ := by
  rw [blockCostM_one, blockCostM_one]
  have : A / k₂ < A / k₁ := div_lt_div_of_pos_left hA hk₁ h
  linarith

/-- **No interior optimum in the flat model.**  For `μ = 1` every block size is
beaten by a larger one — the measured "batch keeps winning" regime. -/
theorem no_optimum_of_mu_one {A c q : ℝ} (hA : 0 < A) :
    ∀ k : ℝ, 0 < k → ∃ k' : ℝ, 0 < k' ∧ blockCostM A c q 1 k' < blockCostM A c q 1 k :=
  fun k hk => ⟨k + 1, by linarith, blockCostM_one_strictAnti hA hk (by linarith)⟩

/-! ## Scaling: constant factors relocate but never remove the optimum -/

section Scaling

variable {A q mu lam : ℝ}

/-- Scaling the setup cost by `lam` scales the optimal batch by `lam ^ (1/μ)`:
the crossover is a `μ`-th root of the setup/penalty ratio. -/
theorem optBatch_scale_setup (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) (hlam : 0 < lam) :
    optBatch (lam * A) q mu = lam ^ (1 / mu) * optBatch A q mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  unfold optBatch
  rw [show lam * A / ((mu - 1) * q) = lam * (A / ((mu - 1) * q)) by ring,
    Real.mul_rpow hlam.le (by positivity)]

/-- Scaling the multiplication penalty by `lam` scales the optimal batch by
`lam ^ (-1/μ)`: GMP-level constant factors move the crossover, never abolish it. -/
theorem optBatch_scale_penalty (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) (hlam : 0 < lam) :
    optBatch A (lam * q) mu = lam ^ (-(1 / mu)) * optBatch A q mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hinv : (lam⁻¹ : ℝ) ^ (1 / mu) = lam ^ (-(1 / mu)) := by
    rw [Real.inv_rpow hlam.le, ← Real.rpow_neg hlam.le]
  unfold optBatch
  rw [show A / ((mu - 1) * (lam * q)) = lam⁻¹ * (A / ((mu - 1) * q)) by field_simp,
    Real.mul_rpow (by positivity) (by positivity), hinv]

/-- The optimal batch is strictly increasing in the setup cost. -/
theorem optBatch_strictMono_setup {A₁ A₂ : ℝ} (hA : 0 < A₁) (hq : 0 < q) (hmu : 1 < mu)
    (h : A₁ < A₂) : optBatch A₁ q mu < optBatch A₂ q mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hden : (0:ℝ) < (mu - 1) * q := by positivity
  have hbase : A₁ / ((mu - 1) * q) < A₂ / ((mu - 1) * q) := by
    gcongr
  unfold optBatch
  exact Real.rpow_lt_rpow (by positivity) hbase (by positivity)

/-- **Divergence as `μ ↓ 1`.**  If the exponent is within `A / (q M²)` of `1`
(with `μ ≤ 2` and `M ≥ 1`), the optimal batch already exceeds `M`.  So the flat
model's "no optimum" is the continuous limit of the root law, not a separate
phenomenon. -/
theorem optBatch_ge_of_mu_close_to_one {M : ℝ} (hq : 0 < q) (hmu : 1 < mu)
    (hmu2 : mu ≤ 2) (hM : 1 ≤ M) (hclose : mu - 1 ≤ A / (q * M ^ 2)) :
    M ≤ optBatch A q mu := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hM0 : (0:ℝ) < M := by linarith
  have hbase : M ^ 2 ≤ A / ((mu - 1) * q) := by
    rw [le_div_iff₀ (by positivity)]
    have h1 : (mu - 1) * (q * M ^ 2) ≤ A := by
      have h2 := mul_le_mul_of_nonneg_right hclose (le_of_lt (by positivity : (0:ℝ) < q * M ^ 2))
      rw [div_mul_cancel₀] at h2
      · linarith
      · positivity
    nlinarith
  have hMmu : M ^ mu ≤ M ^ (2:ℝ) := Real.rpow_le_rpow_of_exponent_le hM hmu2
  have hM2 : M ^ (2:ℝ) = M ^ 2 := by
    rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num, Real.rpow_natCast]
  have hstep : M ^ mu ≤ A / ((mu - 1) * q) := by rw [hM2] at hMmu; linarith
  have hmu0 : (0:ℝ) < mu := by linarith
  calc M = (M ^ mu) ^ (1 / mu) := by
        rw [← Real.rpow_mul hM0.le, mul_one_div, div_self hmu0.ne', Real.rpow_one]
    _ ≤ optBatch A q mu := by
        unfold optBatch
        exact Real.rpow_le_rpow (by positivity) hstep (by positivity)

end Scaling

/-! ## A numerical instance -/

/-- Setup `A = 1000`, penalty `q = 1/1000`.  The schoolbook (`μ = 2`) crossover is
`√(A/q) = 1000`; at `μ = 3/2` (between Karatsuba and schoolbook) the optimal batch
is strictly larger.  Sub-quadratic arithmetic pushes the optimal batch *up*, which
is exactly the measured word-model reversal being an artefact of schoolbook
arithmetic. -/
theorem optBatch_karatsuba_gt_schoolbook :
    optBatch 1000 (1/1000) 2 < optBatch 1000 (1/1000) (3/2) := by
  have h2 : optBatch (1000:ℝ) (1/1000) 2 = 1000 := by
    rw [optBatch_two, show (1000:ℝ) / (1/1000) = 1000 ^ 2 by norm_num]
    exact Real.sqrt_sq (by norm_num)
  rw [h2]
  unfold optBatch
  rw [show (1000:ℝ) / ((3/2 - 1) * (1/1000)) = 2000000 by norm_num,
    show (1:ℝ)/(3/2) = 2/3 by norm_num]
  have hpow : (1000:ℝ) = (1000000000 : ℝ) ^ ((1:ℝ)/3) := by
    rw [show (1000000000:ℝ) = (1000:ℝ) ^ (3:ℕ) by norm_num,
      ← Real.rpow_natCast (1000:ℝ) 3, ← Real.rpow_mul (by norm_num)]
    norm_num
  have h1 : (2000000:ℝ) ^ ((2:ℝ)/3) = (4000000000000 : ℝ) ^ ((1:ℝ)/3) := by
    rw [show (2:ℝ)/3 = 2 * (1/3) by ring, Real.rpow_mul (by norm_num),
      show ((2000000:ℝ)) ^ (2:ℝ) = 4000000000000 by
        rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num, Real.rpow_natCast]; norm_num]
  rw [h1]
  conv_lhs => rw [hpow]
  exact Real.rpow_lt_rpow (by norm_num) (by norm_num) (by norm_num)

end BatchRootLaw