import Mathlib

/-!
# Resolution floors for cluster-structured two-sample count experiments

This file is the *analysis-side* core of the U9-DRIFT-GATE round (paper 222).  The
experiment behind it compares a candidate hit count against a control hit count over a
family of `m` disjoint *clusters* (the "Ns" of the run), reports the pooled ratio
`r = (∑ cand)/(∑ ctrl)`, and attaches a cluster bootstrap confidence interval.  The
round's verdict — *the deviation is not resolvable by a single run* — rests on three
purely mathematical facts, which are proved here with no statistics hand-waving.

* `sum_div_sum_le_of_ratio_le` / `le_sum_div_sum_of_le_ratio` and the packaged
  `sum_div_sum_mem_ratio_range` (**mediant envelope**): the pooled ratio always lies
  between the smallest and the largest per-cluster ratio.  Consequently a pooled ratio
  can never "escape" the per-cluster spread, and a single dominant cluster can drag the
  pooled ratio to its own value.
* `share_sub_inv_card_le_relClusterSD` (**resolution floor**): the relative
  cluster-bootstrap standard deviation of the resampled total is at least
  `(share of the largest cluster) − 1/m`.  This is the quantitative form of "no single
  run can resolve a few-percent deviation in the presence of per-cluster
  overdispersion".
* `pooledVar_le`, `pooledVar_const` (**inverse-variance pooling**): pooling `k` seeds
  each of variance `σ²` gives exactly `σ²/k`, and pooling never hurts.  This certifies
  the round's named follow-up condition (`≥ 3` truly distinct seeds).
* `two_le_of_disjoint_coverage` (**sign-flip audit**): two confidence intervals that are
  *disjoint* cannot both cover the same estimand with probability `≥ 1 − α` unless
  `α ≥ 1/2`.  Formally: a sign flip between seed families falsifies at least one nominal
  coverage claim (or the two runs are not estimating the same quantity).

Everything is stated for arbitrary finite index types and proved from first principles.
-/

namespace Catalog.Pythagorean.DriftGate

open Finset

/-! ## 1. The mediant envelope for pooled ratios -/

/-- **Mediant upper bound.**  If every cluster ratio `x i / y i` is at most `M`, then the
pooled ratio `(∑ x)/(∑ y)` is at most `M`. -/
theorem sum_div_sum_le_of_ratio_le {ι : Type*} (s : Finset ι) (x y : ι → ℝ) (M : ℝ)
    (hy : ∀ i ∈ s, 0 < y i) (hs : s.Nonempty) (hM : ∀ i ∈ s, x i / y i ≤ M) :
    (∑ i ∈ s, x i) / (∑ i ∈ s, y i) ≤ M := by
  have hpos : 0 < ∑ i ∈ s, y i := Finset.sum_pos hy hs
  rw [div_le_iff₀ hpos]
  have hstep : ∀ i ∈ s, x i ≤ M * y i := by
    intro i hi
    have := (div_le_iff₀ (hy i hi)).1 (hM i hi)
    linarith
  have hsum : ∑ i ∈ s, x i ≤ ∑ i ∈ s, M * y i := Finset.sum_le_sum hstep
  rw [← Finset.mul_sum] at hsum
  linarith

/-- **Mediant lower bound.**  If every cluster ratio `x i / y i` is at least `m`, then the
pooled ratio `(∑ x)/(∑ y)` is at least `m`. -/
theorem le_sum_div_sum_of_le_ratio {ι : Type*} (s : Finset ι) (x y : ι → ℝ) (m : ℝ)
    (hy : ∀ i ∈ s, 0 < y i) (hs : s.Nonempty) (hm : ∀ i ∈ s, m ≤ x i / y i) :
    m ≤ (∑ i ∈ s, x i) / (∑ i ∈ s, y i) := by
  have hpos : 0 < ∑ i ∈ s, y i := Finset.sum_pos hy hs
  rw [le_div_iff₀ hpos]
  have hstep : ∀ i ∈ s, m * y i ≤ x i := by
    intro i hi
    have := (le_div_iff₀ (hy i hi)).1 (hm i hi)
    linarith
  have hsum : ∑ i ∈ s, m * y i ≤ ∑ i ∈ s, x i := Finset.sum_le_sum hstep
  rw [← Finset.mul_sum] at hsum
  linarith

/-- **Mediant envelope.**  The pooled candidate/control ratio of a clustered experiment is
sandwiched between two actually attained per-cluster ratios.  In particular a pooled
surplus (`r > 1`) forces at least one cluster with a surplus. -/
theorem sum_div_sum_mem_ratio_range {ι : Type*} (s : Finset ι) (x y : ι → ℝ)
    (hy : ∀ i ∈ s, 0 < y i) (hs : s.Nonempty) :
    ∃ lo ∈ s, ∃ hi ∈ s,
      x lo / y lo ≤ (∑ i ∈ s, x i) / (∑ i ∈ s, y i) ∧
        (∑ i ∈ s, x i) / (∑ i ∈ s, y i) ≤ x hi / y hi := by
  obtain ⟨lo, hlo, hlomin⟩ := s.exists_min_image (fun i => x i / y i) hs
  obtain ⟨hi, hhi, himax⟩ := s.exists_max_image (fun i => x i / y i) hs
  exact ⟨lo, hlo, hi, hhi,
    le_sum_div_sum_of_le_ratio s x y _ hy hs hlomin,
    sum_div_sum_le_of_ratio_le s x y _ hy hs himax⟩

/-- If the pooled ratio exceeds `1`, some individual cluster has a candidate surplus.
This is the "cluster structure is honest" audit statement: a pooled surplus is never a
pure aggregation artefact. -/
theorem exists_cluster_surplus {ι : Type*} (s : Finset ι) (x y : ι → ℝ)
    (hy : ∀ i ∈ s, 0 < y i) (hs : s.Nonempty)
    (hr : 1 < (∑ i ∈ s, x i) / (∑ i ∈ s, y i)) :
    ∃ i ∈ s, y i < x i := by
  by_contra hcon
  push_neg at hcon
  have : (∑ i ∈ s, x i) / (∑ i ∈ s, y i) ≤ 1 := by
    refine sum_div_sum_le_of_ratio_le s x y 1 hy hs ?_
    intro i hi
    exact div_le_one_of_le₀ (hcon i hi) (le_of_lt (hy i hi))
  linarith

/-! ## 2. The cluster-bootstrap resolution floor -/

/-- The relative dispersion of a cluster count vector: the square root of the total squared
deviation from the cluster mean, divided by the grand total.

Under the nonparametric cluster bootstrap (resample the `m = s.card` clusters i.i.d.
uniformly with replacement and re-add their counts), the resampled total `T*` has
`Var(T*) = m · (population variance) = ∑ (xᵢ − x̄)²`, so `relClusterSD` is exactly the
*relative* standard deviation of the bootstrap total.  The identity `Var(T*) = ∑ (xᵢ−x̄)²`
is proved separately in `DriftGateBootstrapVariance.lean`. -/
noncomputable def relClusterSD {ι : Type*} (s : Finset ι) (x : ι → ℝ) : ℝ :=
  Real.sqrt (∑ i ∈ s, (x i - (∑ j ∈ s, x j) / s.card) ^ 2) / (∑ i ∈ s, x i)

/-- **Resolution floor.**  With `m` clusters and grand total `S`, the relative bootstrap
standard deviation of the total is at least `xⱼ/S − 1/m` for every cluster `j`.  A single
cluster carrying a share `f` of the hits therefore pins the achievable one-run resolution
at `f − 1/m`: no amount of *within*-cluster sampling can beat it. -/
theorem share_sub_inv_card_le_relClusterSD {ι : Type*} (s : Finset ι) (x : ι → ℝ)
    (hS : 0 < ∑ i ∈ s, x i) {j : ι} (hj : j ∈ s) :
    x j / (∑ i ∈ s, x i) - 1 / (s.card : ℝ) ≤ relClusterSD s x := by
  set S := ∑ i ∈ s, x i with hSdef
  have hm : (0 : ℝ) < (s.card : ℝ) := by
    have : s.Nonempty := ⟨j, hj⟩
    exact_mod_cast Finset.card_pos.2 this
  -- the deviation of cluster `j`
  have hdev : (x j - S / s.card) ^ 2 ≤ ∑ i ∈ s, (x i - S / s.card) ^ 2 :=
    Finset.single_le_sum (f := fun i => (x i - S / (s.card : ℝ)) ^ 2)
      (fun i _ => sq_nonneg _) hj
  have hsqrt : x j - S / s.card ≤ Real.sqrt (∑ i ∈ s, (x i - S / s.card) ^ 2) := by
    have h1 : Real.sqrt ((x j - S / s.card) ^ 2) ≤
        Real.sqrt (∑ i ∈ s, (x i - S / s.card) ^ 2) := Real.sqrt_le_sqrt hdev
    rw [Real.sqrt_sq_eq_abs] at h1
    exact le_trans (le_abs_self _) h1
  have hdiv : (x j - S / s.card) / S ≤
      Real.sqrt (∑ i ∈ s, (x i - S / s.card) ^ 2) / S := by
    gcongr
  have hrw : (x j - S / s.card) / S = x j / S - 1 / (s.card : ℝ) := by
    field_simp
  rw [hrw] at hdiv
  simpa [relClusterSD, hSdef] using hdiv

/-- **Dominant-cluster corollary.**  If one cluster carries at least a `1 − δ` share of the
hits, the one-run relative resolution cannot be better than `1 − δ − 1/m`. -/
theorem relClusterSD_ge_of_dominant {ι : Type*} (s : Finset ι) (x : ι → ℝ) (δ : ℝ)
    (hS : 0 < ∑ i ∈ s, x i) {j : ι} (hj : j ∈ s)
    (hdom : (1 - δ) * (∑ i ∈ s, x i) ≤ x j) :
    1 - δ - 1 / (s.card : ℝ) ≤ relClusterSD s x := by
  have h1 : 1 - δ ≤ x j / (∑ i ∈ s, x i) := (le_div_iff₀ hS).2 hdom
  have h2 := share_sub_inv_card_le_relClusterSD s x hS hj
  linarith

/-! ## 3. Inverse-variance pooling across seeds -/

/-- Inverse-variance (precision-weighted) pooled variance of independent runs. -/
noncomputable def pooledVar {ι : Type*} (s : Finset ι) (v : ι → ℝ) : ℝ :=
  (∑ i ∈ s, (v i)⁻¹)⁻¹

/-- Pooling never hurts: the pooled variance is at most the variance of any single run. -/
theorem pooledVar_le {ι : Type*} (s : Finset ι) (v : ι → ℝ) (hv : ∀ i ∈ s, 0 < v i)
    {j : ι} (hj : j ∈ s) : pooledVar s v ≤ v j := by
  have hsum : (v j)⁻¹ ≤ ∑ i ∈ s, (v i)⁻¹ :=
    Finset.single_le_sum (f := fun i => (v i)⁻¹) (fun i hi => le_of_lt (inv_pos.2 (hv i hi))) hj
  have hjpos : (0 : ℝ) < (v j)⁻¹ := inv_pos.2 (hv j hj)
  have hinv := inv_anti₀ hjpos hsum
  simpa [pooledVar] using hinv

/-- `k` independent runs of common variance `σ²` pool to variance exactly `σ²/k`. -/
theorem pooledVar_const {ι : Type*} (s : Finset ι) (σ : ℝ) (hσ : 0 < σ) (hs : s.Nonempty) :
    pooledVar s (fun _ => σ ^ 2) = σ ^ 2 / s.card := by
  have hcard : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hs
  have hσ2 : (σ : ℝ) ^ 2 ≠ 0 := by positivity
  simp only [pooledVar, Finset.sum_const, nsmul_eq_mul]
  rw [mul_inv, inv_inv, mul_comm, ← div_eq_mul_inv]

/-- **Named follow-up condition of paper 222, certified.**  Three independent seeds whose
individual one-run standard errors are `0.025` (the recorded `cut_1e6` half-width divided
by `1.96`) pool to a joint standard error below `0.02`, which is the resolution the round
declared necessary to revisit the gate. -/
theorem three_seed_pooling_reaches_target :
    Real.sqrt (pooledVar (Finset.univ : Finset (Fin 3)) (fun _ => (0.025 : ℝ) ^ 2)) < 0.02 := by
  rw [pooledVar_const _ _ (by norm_num) Finset.univ_nonempty]
  have hcard : ((Finset.univ : Finset (Fin 3)).card : ℝ) = 3 := by simp
  rw [hcard]
  have h : ((0.025 : ℝ) ^ 2) / 3 < (0.02 : ℝ) ^ 2 := by norm_num
  calc Real.sqrt ((0.025 : ℝ) ^ 2 / 3) < Real.sqrt ((0.02 : ℝ) ^ 2) := by
        exact Real.sqrt_lt_sqrt (by positivity) h
    _ = 0.02 := by rw [Real.sqrt_sq (by norm_num)]

/-! ## 4. The sign-flip audit: disjoint intervals cannot both cover -/

open MeasureTheory

/-- **Sign-flip audit.**  Let `A` be the event "run 1's interval covers the estimand" and
`B` the event "run 2's interval covers the estimand".  If the two intervals are disjoint
(as they are when one lies strictly below `1` and the other strictly above), then `A` and
`B` are disjoint events, and they cannot both have probability `≥ 1 − α` unless
`1 ≤ 2α`.  For nominal `95%` intervals (`α = 0.05`) this is impossible: a sign flip
between seed families falsifies at least one coverage claim, or the two runs do not share
an estimand. -/
theorem two_le_of_disjoint_coverage {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] {A B : Set Ω} (hB : MeasurableSet B) (hdisj : Disjoint A B)
    (α : ℝ) (hA' : 1 - α ≤ μ.real A) (hB' : 1 - α ≤ μ.real B) : 1 ≤ 2 * α := by
  have hunion : μ.real (A ∪ B) = μ.real A + μ.real B :=
    measureReal_union hdisj hB
  have hle : μ.real (A ∪ B) ≤ 1 := by
    have := measureReal_mono (μ := μ) (Set.subset_univ (A ∪ B))
    simpa using this
  rw [hunion] at hle
  linarith

/-- **Multi-run sign-partition bound.**  If `s` runs report pairwise disjoint coverage
events, each with nominal coverage `1 − α`, then `|s| · (1 − α) ≤ 1`.  With `p` mutually
sign-incompatible runs this forces `α ≥ 1 − 1/p`: the more seed families disagree, the
more badly the nominal coverage is falsified.  This is the multi-seed form of the audit
that rejected the gate, and the shape the round's `≥ 3` seed follow-up will need. -/
theorem card_mul_coverage_le_one {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] {ι : Type*} (s : Finset ι) (A : ι → Set Ω)
    (hmeas : ∀ i ∈ s, MeasurableSet (A i)) (hdisj : (s : Set ι).PairwiseDisjoint A)
    (α : ℝ) (hcov : ∀ i ∈ s, 1 - α ≤ μ.real (A i)) :
    (s.card : ℝ) * (1 - α) ≤ 1 := by
  have hsum : μ.real (⋃ i ∈ s, A i) = ∑ i ∈ s, μ.real (A i) :=
    measureReal_biUnion_finset hdisj hmeas
  have hle : μ.real (⋃ i ∈ s, A i) ≤ 1 := by
    have := measureReal_mono (μ := μ) (Set.subset_univ (⋃ i ∈ s, A i))
    simpa using this
  have hlow : (s.card : ℝ) * (1 - α) ≤ ∑ i ∈ s, μ.real (A i) := by
    calc (s.card : ℝ) * (1 - α) = ∑ _i ∈ s, (1 - α) := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ∑ i ∈ s, μ.real (A i) := Finset.sum_le_sum hcov
  linarith [hsum ▸ hle]

/-- Concrete form: two nominal `95%` intervals from two seed families cannot be disjoint
while both cover.  This is exactly what the `20260824` deficit family and the `20260825`
surplus family assert jointly — hence the gate rejection. -/
theorem no_disjoint_95_coverage {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] {A B : Set Ω} (hB : MeasurableSet B) (hdisj : Disjoint A B)
    (hA' : 0.95 ≤ μ.real A) (hB' : 0.95 ≤ μ.real B) : False := by
  have := two_le_of_disjoint_coverage μ hB hdisj 0.05 (by linarith) (by linarith)
  norm_num at this

end Catalog.Pythagorean.DriftGate