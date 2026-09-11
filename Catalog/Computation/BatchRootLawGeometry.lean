import Computation.BatchSubquadraticRootLaw

/-!
# Geometry of the batching cost curve: collapse, flatness, and multiplicative convexity

Second research cycle on the root law of
`Catalog/Computation/BatchSubquadraticRootLaw.lean`.  There we proved that the
per-candidate cost `blockCostM A c q μ k = A/k + c + q(k^(μ-1) - 1)` has the unique
minimiser `k* = (A/((μ-1)q))^(1/μ)`.  Here we ask *why* the law is a root law, and
how much it costs to get the batch size wrong.

Three structural findings, all proved:

1. **Universal collapse.**  After rescaling `k = θ k*`, the whole cost curve
   depends on `(θ, μ)` only — the parameters `A`, `q` enter solely through the
   overall scale (`blockCostM_rescaled`).  The shape function is
   `costShape μ θ = (μ-1)/θ + θ^(μ-1)`, with minimum `μ` at `θ = 1`.
2. **Quadratic flatness.**  `costShape μ θ - μ ≤ (μ-1)(θ-1)²/θ`
   (`costShape_le_quadratic`).  So mis-sizing the batch by a bounded factor costs
   only second-order overhead; combined with `optBatch_antitone_mu` this explains
   why measured crossovers are broad plateaus rather than sharp spikes.
3. **Multiplicative, not additive, convexity.**  The cost is *geometrically*
   convex: it is convex along geometric interpolations of the batch size
   (`blockCostM_geom_convex`), for every exponent `μ`.  It is **not** convex in
   the batch size itself once `μ < 2` (`blockCostM_not_convex_of_subquadratic`, a
   fully explicit witness).  Multiplicative convexity is the structural reason the
   optimum is a root of `A/q` rather than a ratio of them.

We also prove the qualitative form of the "sub-quadratic pushes the batch up"
phenomenon: for a fixed setup/penalty pair with `k* ≥ 1`, the optimal batch is
antitone in the multiplication exponent (`optBatch_antitone_mu`), of which
`optBatch_karatsuba_gt_schoolbook` was a single numerical instance.
-/

namespace BatchRootLaw

open Real

/-! ## The universal shape function -/

/-- Shape of the batching cost curve in units of the optimal batch: with
`k = θ k*` the whole curve is `q (k*)^(μ-1) · costShape μ θ`. -/
noncomputable def costShape (mu theta : ℝ) : ℝ := (mu - 1) / theta + theta ^ (mu - 1)

/-- The shape function has value `μ` at the optimum `θ = 1`. -/
@[simp] theorem costShape_one (mu : ℝ) : costShape mu 1 = mu := by
  unfold costShape
  rw [Real.one_rpow]
  ring

/-- **Universal collapse.**  Measured in units of `k*`, the cost curve is
`(c - q) + q (k*)^(μ-1) · costShape μ θ`: the setup `A` and penalty `q` affect only
the vertical scale, never the shape. -/
theorem blockCostM_rescaled {A c q mu theta : ℝ} (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu)
    (htheta : 0 < theta) :
    blockCostM A c q mu (theta * optBatch A q mu)
      = (c - q) + q * (optBatch A q mu) ^ (mu - 1) * costShape mu theta := by
  have ht : 0 < optBatch A q mu := optBatch_pos hA hq hmu
  have hbal := optBatch_balanced hA hq hmu
  have hk : 0 < theta * optBatch A q mu := by positivity
  have hratio : (theta * optBatch A q mu) / optBatch A q mu = theta := by
    field_simp
  have hfac := cost_factor (q := q) (mu := mu) ht hk
  rw [hratio] at hfac
  set t := optBatch A q mu with hdef
  unfold blockCostM costShape
  rw [hbal]
  linarith [hfac]

/-- The optimal cost in the same units: `optCost = (c - q) + q (k*)^(μ-1) · μ`. -/
theorem optCost_eq_scale {A c q mu : ℝ} (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    optCost A c q mu = (c - q) + q * (optBatch A q mu) ^ (mu - 1) * mu := by
  have h := blockCostM_rescaled (A := A) (c := c) hA hq hmu (theta := 1) one_pos
  rw [costShape_one, one_mul] at h
  rw [← h, blockCostM_at_optBatch hA hq hmu]

/-! ## Flatness of the optimum -/

/-- Lower bound: the shape function never dips below `μ` (restatement of the
weighted AM–GM bound in shape coordinates). -/
theorem costShape_ge {mu theta : ℝ} (hmu : 1 ≤ mu) (htheta : 0 < theta) :
    mu ≤ costShape mu theta :=
  weighted_amgm_le htheta hmu

/-- **Quadratic flatness.**  For `1 < μ ≤ 2` the excess of the shape function over
its minimum is at most `(μ-1)(θ-1)²/θ`: mis-sizing the batch is a second-order
error, and the penalty is proportional to `μ - 1`, so it vanishes in the flat
model. -/
theorem costShape_le_quadratic {mu theta : ℝ} (hmu : 1 < mu) (hmu2 : mu ≤ 2)
    (htheta : 0 < theta) :
    costShape mu theta ≤ mu + (mu - 1) * (theta - 1) ^ 2 / theta := by
  have hrev : theta ^ (mu - 1) ≤ 1 + (mu - 1) * (theta - 1) := by
    have h := rpow_one_add_le_one_add_mul_self (s := theta - 1) (p := mu - 1)
      (by linarith) (by linarith) (by linarith)
    rwa [show (1 : ℝ) + (theta - 1) = theta by ring] at h
  unfold costShape
  rw [div_add' _ _ _ htheta.ne', div_le_iff₀ htheta]
  have h2 : (mu + (mu - 1) * (theta - 1) ^ 2 / theta) * theta
      = mu * theta + (mu - 1) * (theta - 1) ^ 2 := by
    field_simp
  rw [h2]
  nlinarith [hrev, htheta]

/-- **The optimum is a plateau, not a spike.**  Using a batch of `θ k*` instead of
`k*` costs at most `q (k*)^(μ-1) (μ-1)(θ-1)²/θ` more than optimal. -/
theorem blockCostM_near_opt {A c q mu theta : ℝ} (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu)
    (hmu2 : mu ≤ 2) (htheta : 0 < theta) :
    blockCostM A c q mu (theta * optBatch A q mu)
      ≤ optCost A c q mu + q * (optBatch A q mu) ^ (mu - 1) * ((mu - 1) * (theta - 1) ^ 2 / theta) := by
  have hscale : (0:ℝ) < q * (optBatch A q mu) ^ (mu - 1) := by
    have := optBatch_pos hA hq hmu
    positivity
  rw [blockCostM_rescaled hA hq hmu htheta, optCost_eq_scale hA hq hmu]
  have h := costShape_le_quadratic hmu hmu2 htheta
  nlinarith [h, hscale]

/-! ## Monotonicity in the multiplication exponent -/

/-- **Sub-quadratic arithmetic pushes the optimal batch up.**  Whenever the
schoolbook-side optimum is at least one batch (`(μ₁-1) q ≤ A`), lowering the
multiplication exponent from `μ₂` to `μ₁` never decreases the optimal batch size.
This is the general form of `optBatch_karatsuba_gt_schoolbook`. -/
theorem optBatch_antitone_mu {A q mu₁ mu₂ : ℝ} (hA : 0 < A) (hq : 0 < q)
    (hmu₁ : 1 < mu₁) (hle : mu₁ ≤ mu₂) (hbig : (mu₁ - 1) * q ≤ A) :
    optBatch A q mu₂ ≤ optBatch A q mu₁ := by
  have hmu₂ : 1 < mu₂ := lt_of_lt_of_le hmu₁ hle
  have hm1 : (0:ℝ) < mu₁ - 1 := by linarith
  have hm2 : (0:ℝ) < mu₂ - 1 := by linarith
  have hb1 : (1:ℝ) ≤ A / ((mu₁ - 1) * q) := by
    rw [le_div_iff₀ (by positivity)]
    linarith
  have hb2 : A / ((mu₂ - 1) * q) ≤ A / ((mu₁ - 1) * q) := by
    gcongr
  have hb2pos : (0:ℝ) ≤ A / ((mu₂ - 1) * q) := by positivity
  unfold optBatch
  calc (A / ((mu₂ - 1) * q)) ^ (1 / mu₂)
      ≤ (A / ((mu₁ - 1) * q)) ^ (1 / mu₂) :=
        Real.rpow_le_rpow hb2pos hb2 (by positivity)
    _ ≤ (A / ((mu₁ - 1) * q)) ^ (1 / mu₁) := by
        apply Real.rpow_le_rpow_of_exponent_le hb1
        apply one_div_le_one_div_of_le (by linarith) hle

/-! ## Homogeneity: constants relocate the optimum, never remove it -/

/-- The excess cost `optCost - (c - q)` is homogeneous of degree one in the pair
`(A, q)`: doubling both the setup and the multiplication penalty doubles the
optimal cost, while (by `optBatch_scale_setup`/`optBatch_scale_penalty`) the
optimal batch is unchanged.  This is the precise sense in which GMP-level constant
factors relocate but never remove the optimum. -/
theorem optCost_homogeneous {A c q mu lam : ℝ} (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu)
    (hlam : 0 < lam) :
    optCost (lam * A) c (lam * q) mu - (c - lam * q)
      = lam * (optCost A c q mu - (c - q)) := by
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hmu0 : mu ≠ 0 := by linarith
  have hlamsum : lam ^ ((mu - 1) / mu) * lam ^ (1 / mu) = lam := by
    rw [← Real.rpow_add hlam, show (mu - 1) / mu + 1 / mu = 1 by field_simp; ring,
      Real.rpow_one]
  unfold optCost
  rw [Real.mul_rpow hlam.le hA.le, Real.mul_rpow hlam.le hq.le]
  linear_combination (mu * (mu - 1) ^ ((1 - mu) / mu) * A ^ ((mu - 1) / mu)
    * q ^ (1 / mu)) * hlamsum

/-- The optimal batch size is invariant under scaling setup and penalty together. -/
theorem optBatch_scale_invariant {A q mu lam : ℝ} (hlam : 0 < lam) :
    optBatch (lam * A) (lam * q) mu = optBatch A q mu := by
  unfold optBatch
  rw [show lam * A / ((mu - 1) * (lam * q)) = A / ((mu - 1) * q) by
    field_simp]

/-! ## Multiplicative convexity, and failure of ordinary convexity -/

/-- **Geometric (multiplicative) convexity.**  Along geometric interpolation of
batch sizes, `k = k₁ ^ w · k₂ ^ (1-w)`, the cost is convex — for *every*
multiplication exponent `μ`, sub- or super-quadratic.  This is the structural
reason the optimum is a root of the setup/penalty ratio: the natural coordinate on
batch sizes is logarithmic. -/
theorem blockCostM_geom_convex {A c q mu k₁ k₂ w : ℝ} (hA : 0 ≤ A) (hq : 0 ≤ q)
    (hk₁ : 0 < k₁) (hk₂ : 0 < k₂) (hw : 0 ≤ w) (hw1 : w ≤ 1) :
    blockCostM A c q mu (k₁ ^ w * k₂ ^ (1 - w))
      ≤ w * blockCostM A c q mu k₁ + (1 - w) * blockCostM A c q mu k₂ := by
  have hw' : 0 ≤ 1 - w := by linarith
  have hsum : w + (1 - w) = 1 := by ring
  -- the setup term
  have hsetup : A / (k₁ ^ w * k₂ ^ (1 - w)) ≤ w * (A / k₁) + (1 - w) * (A / k₂) := by
    have h1 : A / (k₁ ^ w * k₂ ^ (1 - w)) = (A / k₁) ^ w * (A / k₂) ^ (1 - w) := by
      rw [Real.div_rpow hA hk₁.le, Real.div_rpow hA hk₂.le, div_mul_div_comm,
        ← Real.rpow_add' (by linarith) (by rw [hsum]; norm_num), hsum, Real.rpow_one]
    rw [h1]
    exact Real.geom_mean_le_arith_mean2_weighted hw hw' (by positivity) (by positivity) hsum
  -- the penalty term
  have hpen : (k₁ ^ w * k₂ ^ (1 - w)) ^ (mu - 1)
      ≤ w * k₁ ^ (mu - 1) + (1 - w) * k₂ ^ (mu - 1) := by
    have h2 : (k₁ ^ w * k₂ ^ (1 - w)) ^ (mu - 1)
        = (k₁ ^ (mu - 1)) ^ w * (k₂ ^ (mu - 1)) ^ (1 - w) := by
      rw [Real.mul_rpow (by positivity) (by positivity), ← Real.rpow_mul hk₁.le,
        ← Real.rpow_mul hk₂.le, ← Real.rpow_mul hk₁.le, ← Real.rpow_mul hk₂.le]
      ring_nf
    rw [h2]
    exact Real.geom_mean_le_arith_mean2_weighted hw hw' (by positivity) (by positivity) hsum
  unfold blockCostM
  have hpen' : q * ((k₁ ^ w * k₂ ^ (1 - w)) ^ (mu - 1) - 1)
      ≤ w * (q * (k₁ ^ (mu - 1) - 1)) + (1 - w) * (q * (k₂ ^ (mu - 1) - 1)) := by
    nlinarith [mul_le_mul_of_nonneg_left hpen hq]
  nlinarith [hsetup, hpen']

/-- **Ordinary convexity fails below the quadratic model.**  Explicit witness:
`μ = 3/2`, `A = q = 1`, `c = 0`, batch sizes `4` and `100`.  The cost at the
arithmetic midpoint `52` strictly exceeds the average of the costs, so the cost
function is *not* convex in the batch size — only in its logarithm.  (For the
schoolbook model `μ = 2` the cost *is* convex, so this is a genuine sub-quadratic
phenomenon.) -/
theorem blockCostM_not_convex_of_subquadratic :
    (blockCostM 1 0 1 (3/2) 4 + blockCostM 1 0 1 (3/2) 100) / 2
      < blockCostM 1 0 1 (3/2) 52 := by
  have e4 : (4:ℝ) ^ ((3:ℝ)/2 - 1) = 2 := by
    rw [show (3:ℝ)/2 - 1 = 1/2 by norm_num, ← Real.sqrt_eq_rpow,
      show (4:ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  have e100 : (100:ℝ) ^ ((3:ℝ)/2 - 1) = 10 := by
    rw [show (3:ℝ)/2 - 1 = 1/2 by norm_num, ← Real.sqrt_eq_rpow,
      show (100:ℝ) = 10 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  have e52 : (7.2:ℝ) < (52:ℝ) ^ ((3:ℝ)/2 - 1) := by
    rw [show (3:ℝ)/2 - 1 = 1/2 by norm_num, ← Real.sqrt_eq_rpow]
    have : Real.sqrt (7.2 ^ 2) < Real.sqrt 52 := by
      apply Real.sqrt_lt_sqrt (by positivity)
      norm_num
    rwa [Real.sqrt_sq (by norm_num)] at this
  unfold blockCostM
  rw [e4, e100]
  norm_num
  nlinarith [e52]

end BatchRootLaw