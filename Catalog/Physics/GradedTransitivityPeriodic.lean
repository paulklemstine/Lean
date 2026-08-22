import Physics.GradedTransitivityComplex

/-!
# The second singularity: two-periodic grade counts and the residue at `q = -1`

The previous files in this thread analysed the singularity of a graded partition function at
`q = 1` under the hypothesis that the grade counts are *eventually constant* or *eventually
polynomial*.  In both cases `q = 1` is the only singularity.

This file is the first genuinely *quasi-polynomial* case: the grade counts are eventually
**two-periodic**, `aₙ = c₀` for even `n` and `aₙ = c₁` for odd `n`.  Now the partition
function

  `Z(q) = (c₀ + c₁ q) / (1 - q²)`

has **two** singularities, at `q = 1` and at `q = -1`, with residues

  `Res_{q=1} Z = -(c₀ + c₁)/2`,   `Res_{q=-1} Z = (c₀ - c₁)/2`.

This confirms, at `m = 2`, the conjectured root-of-unity formula
`Res_{q=ζ} = -(ζ/m) · ∑_{j<m} ζ^{-j} P_j(-1)`: for `m = 2`, `ζ = -1`, `P_j = c_j` it reads
`(1/2)(c₀ - c₁)`, exactly the value proved here.

The group-theoretic pay-off is a *sharp dichotomy*: for a graded `G`-set whose transitivity
counts are eventually two-periodic, the second singularity **disappears** precisely when the
two periodic values agree.  In particular an eventually `r`-transitive graded `G`-set has no
singularity at `q = -1` at all, while its residue at `q = 1` is the universal constant `-1`.

## Main results

* `Physics.GradedTransitivity.hasSum_periodicCoeff` — the closed form of the two-periodic
  partition function on the open unit disc.
* `Physics.GradedTransitivity.circleIntegral_periodicGF_one`,
  `Physics.GradedTransitivity.circleIntegral_periodicGF_neg_one` — the two residues.
* `Physics.GradedTransitivity.circleIntegral_eventually_periodic_one`,
  `Physics.GradedTransitivity.circleIntegral_eventually_periodic_neg_one` — the same for an
  arbitrary analytic continuation of an eventually two-periodic generating function.
* `Physics.GradedTransitivity.circleIntegral_neg_one_eq_zero_iff` — the dichotomy: the second
  singularity is invisible iff the two periodic values coincide.
* `Physics.GradedTransitivity.circleIntegral_transitive_neg_one` — an eventually
  `r`-transitive graded `G`-set has no residue at `q = -1`.
-/

namespace Physics.GradedTransitivity

open Finset Complex Filter Topology

/-! ### The two-periodic coefficient sequence and its closed form -/

/-- The two-periodic coefficient sequence with values `c₀` on even grades and `c₁` on odd
grades. -/
noncomputable def periodicCoeff (c₀ c₁ : ℂ) (n : ℕ) : ℂ := if Even n then c₀ else c₁

/-- The closed form of the two-periodic partition function, as a function on all of `ℂ`
(at `q = ±1` the Lean value is junk). -/
noncomputable def periodicGF (c₀ c₁ : ℂ) (q : ℂ) : ℂ := (c₀ + c₁ * q) / (1 - q ^ 2)

variable {c₀ c₁ : ℂ}

/-- **Summation of the two-periodic series.**  On the open unit disc the two-periodic
generating function converges to `(c₀ + c₁ q)/(1 - q²)`. -/
theorem hasSum_periodicCoeff (c₀ c₁ : ℂ) {q : ℂ} (hq : ‖q‖ < 1) :
    HasSum (fun n : ℕ => periodicCoeff c₀ c₁ n * q ^ n) (periodicGF c₀ c₁ q) := by
  have hq2 : ‖q ^ 2‖ < 1 := by
    rw [norm_pow]
    exact pow_lt_one₀ (norm_nonneg q) hq two_ne_zero
  have hgeo : HasSum (fun k : ℕ => (q ^ 2) ^ k) (1 - q ^ 2)⁻¹ := hasSum_geometric_of_norm_lt_one hq2
  have heven : HasSum (fun k : ℕ => periodicCoeff c₀ c₁ (2 * k) * q ^ (2 * k))
      (c₀ * (1 - q ^ 2)⁻¹) := by
    refine (hgeo.mul_left c₀).congr_fun fun k => ?_
    have hcoef : periodicCoeff c₀ c₁ (2 * k) = c₀ := by
      simp [periodicCoeff]
    rw [hcoef, pow_mul]
  have hodd : HasSum (fun k : ℕ => periodicCoeff c₀ c₁ (2 * k + 1) * q ^ (2 * k + 1))
      (c₁ * q * (1 - q ^ 2)⁻¹) := by
    refine (hgeo.mul_left (c₁ * q)).congr_fun fun k => ?_
    have hcoef : periodicCoeff c₀ c₁ (2 * k + 1) = c₁ := by
      have : ¬ Even (2 * k + 1) := by simp
      simp [periodicCoeff, this]
    rw [hcoef, pow_succ, pow_mul]
    ring
  have hsum : HasSum (fun n : ℕ => periodicCoeff c₀ c₁ n * q ^ n)
      (c₀ * (1 - q ^ 2)⁻¹ + c₁ * q * (1 - q ^ 2)⁻¹) :=
    HasSum.even_add_odd (f := fun n : ℕ => periodicCoeff c₀ c₁ n * q ^ n) heven hodd
  have hval : periodicGF c₀ c₁ q = c₀ * (1 - q ^ 2)⁻¹ + c₁ * q * (1 - q ^ 2)⁻¹ := by
    rw [periodicGF, div_eq_mul_inv]
    ring
  rw [hval]
  exact hsum

theorem tsum_periodicCoeff (c₀ c₁ : ℂ) {q : ℂ} (hq : ‖q‖ < 1) :
    ∑' n : ℕ, periodicCoeff c₀ c₁ n * q ^ n = periodicGF c₀ c₁ q :=
  (hasSum_periodicCoeff c₀ c₁ hq).tsum_eq

/-! ### Partial fractions and analyticity off `{1, -1}` -/

/-- **Partial-fraction splitting.**  Away from the two singularities the two-periodic
partition function is a sum of two simple poles with the conjectured residues. -/
theorem periodicGF_eq_partialFractions {q : ℂ} (h1 : q ≠ 1) (h2 : q ≠ -1) :
    periodicGF c₀ c₁ q = ((c₀ + c₁) / 2) * (1 - q)⁻¹ + ((c₀ - c₁) / 2) * (1 + q)⁻¹ := by
  have hA : (1 : ℂ) - q ≠ 0 := fun h => h1 (by linear_combination -h)
  have hB : (1 : ℂ) + q ≠ 0 := fun h => h2 (by linear_combination h)
  have hden : (1 : ℂ) - q ^ 2 ≠ 0 := by
    have : (1 : ℂ) - q ^ 2 = (1 - q) * (1 + q) := by ring
    rw [this]
    exact mul_ne_zero hA hB
  rw [periodicGF]
  field_simp
  ring

/-- The complement of `{1, -1}` is where the two-periodic partition function is analytic. -/
theorem differentiableOn_periodicGF :
    DifferentiableOn ℂ (periodicGF c₀ c₁) ({(1 : ℂ), -1}ᶜ) := by
  intro q hq
  simp only [Set.mem_compl_iff, Set.mem_insert_iff, Set.mem_singleton_iff, not_or] at hq
  have hden : (1 : ℂ) - q ^ 2 ≠ 0 := by
    have hfac : (1 : ℂ) - q ^ 2 = (1 - q) * (1 + q) := by ring
    rw [hfac]
    exact mul_ne_zero (fun h => hq.1 (by linear_combination -h))
      (fun h => hq.2 (by linear_combination h))
  apply DifferentiableAt.differentiableWithinAt
  unfold periodicGF
  fun_prop (disch := assumption)

theorem analyticOnNhd_periodicGF :
    AnalyticOnNhd ℂ (periodicGF c₀ c₁) ({(1 : ℂ), -1}ᶜ) := by
  refine differentiableOn_periodicGF.analyticOnNhd ?_
  exact (Set.toFinite ({(1 : ℂ), -1} : Set ℂ)).isClosed.isOpen_compl

/-- The complement of the two singularities is preconnected — the geometric input to the
identity theorem. -/
theorem isPreconnected_compl_pair : IsPreconnected (({(1 : ℂ), -1})ᶜ) := by
  have hrank : (1 : Cardinal) < Module.rank ℝ ℂ := by
    rw [Complex.rank_real_complex]; norm_num
  have hcount : (({(1 : ℂ), -1}) : Set ℂ).Countable :=
    (Set.toFinite ({(1 : ℂ), -1} : Set ℂ)).countable
  exact ((hcount.isPathConnected_compl_of_one_lt_rank hrank).isConnected).isPreconnected

/-- **Uniqueness of the continuation** to the twice-punctured plane. -/
theorem eqOn_compl_pair_of_eventuallyEq {F H : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ)) (hH : AnalyticOnNhd ℂ H ({(1 : ℂ), -1}ᶜ))
    (h : F =ᶠ[𝓝 (0 : ℂ)] H) : Set.EqOn F H ({(1 : ℂ), -1}ᶜ) := by
  have h0 : (0 : ℂ) ∈ (({(1 : ℂ), -1})ᶜ : Set ℂ) := by
    simp only [Set.mem_compl_iff, Set.mem_insert_iff, Set.mem_singleton_iff, not_or]
    constructor
    · exact zero_ne_one
    · intro hc
      exact one_ne_zero (show (1 : ℂ) = 0 by linear_combination hc)
  exact hF.eqOn_of_preconnected_of_eventuallyEq hH isPreconnected_compl_pair h0 h

/-! ### The two residues -/

/-- A circle of radius `0 < ρ < 2` around one singularity avoids both of them. -/
theorem sphere_subset_compl_pair {w : ℂ} (hw : w = 1 ∨ w = -1) {ρ : ℝ} (hρ : 0 < ρ)
    (hρ2 : ρ < 2) : Metric.sphere w ρ ⊆ ({(1 : ℂ), -1}ᶜ) := by
  intro z hz
  simp only [Metric.mem_sphere] at hz
  have hdist : dist (1 : ℂ) (-1 : ℂ) = 2 := by
    rw [Complex.dist_eq]
    norm_num
  simp only [Set.mem_compl_iff, Set.mem_insert_iff, Set.mem_singleton_iff, not_or]
  rcases hw with rfl | rfl
  · refine ⟨fun h => ?_, fun h => ?_⟩
    · rw [h, dist_self] at hz
      exact absurd hz.symm (ne_of_gt hρ)
    · rw [h] at hz
      rw [dist_comm] at hdist
      rw [hz] at hdist
      linarith
  · refine ⟨fun h => ?_, fun h => ?_⟩
    · rw [h] at hz
      rw [hz] at hdist
      linarith
    · rw [h, dist_self] at hz
      exact absurd hz.symm (ne_of_gt hρ)

/-- **The residue at `q = 1` is `-(c₀ + c₁)/2`.** -/
theorem circleIntegral_periodicGF_one {ρ : ℝ} (hρ : 0 < ρ) (hρ2 : ρ < 2) :
    (∮ z in C((1 : ℂ), ρ), periodicGF c₀ c₁ z)
      = -((c₀ + c₁) / 2) * (2 * (Real.pi : ℂ) * I) := by
  have hsub := sphere_subset_compl_pair (w := (1 : ℂ)) (Or.inl rfl) hρ hρ2
  have hne : ∀ z ∈ Metric.sphere (1 : ℂ) ρ, z - 1 ≠ 0 ∧ z ≠ -1 := by
    intro z hz
    have := hsub hz
    simp only [Set.mem_compl_iff, Set.mem_insert_iff, Set.mem_singleton_iff, not_or] at this
    exact ⟨sub_ne_zero.mpr this.1, this.2⟩
  have hclosed : ∀ z ∈ Metric.closedBall (1 : ℂ) ρ, (1 : ℂ) + z ≠ 0 := by
    intro z hz h
    have hz1 : z = -1 := by linear_combination h
    rw [hz1] at hz
    simp only [Metric.mem_closedBall, Complex.dist_eq] at hz
    have hnorm : ‖(-1 : ℂ) - 1‖ = 2 := by norm_num
    rw [hnorm] at hz
    linarith
  have hBdiff : ∀ z ∈ Metric.closedBall (1 : ℂ) ρ,
      DifferentiableAt ℂ (fun w : ℂ => ((c₀ - c₁) / 2) * (1 + w)⁻¹) z := by
    intro z hz
    have h := hclosed z hz
    fun_prop (disch := assumption)
  have hBcont : ContinuousOn (fun w : ℂ => ((c₀ - c₁) / 2) * (1 + w)⁻¹)
      (Metric.closedBall (1 : ℂ) ρ) :=
    fun z hz => (hBdiff z hz).continuousAt.continuousWithinAt
  have hEq : Set.EqOn (periodicGF c₀ c₁)
      (fun z => (-((c₀ + c₁) / 2)) * (z - 1)⁻¹ + ((c₀ - c₁) / 2) * (1 + z)⁻¹)
      (Metric.sphere (1 : ℂ) ρ) := by
    intro z hz
    obtain ⟨hz1, hz2⟩ := hne z hz
    have hinv : (1 - z)⁻¹ = -(z - 1)⁻¹ := by
      rw [show (1 : ℂ) - z = -(z - 1) by ring, inv_neg]
    simp only
    rw [periodicGF_eq_partialFractions (sub_ne_zero.mp hz1) hz2, hinv]
    ring
  have hint1 : CircleIntegrable (fun z : ℂ => (-((c₀ + c₁) / 2)) * (z - 1)⁻¹) 1 ρ :=
    ContinuousOn.circleIntegrable hρ.le
      (continuousOn_const.mul ((continuousOn_id.sub continuousOn_const).inv₀
        (fun z hz => (hne z hz).1)))
  have hint2 : CircleIntegrable (fun w : ℂ => ((c₀ - c₁) / 2) * (1 + w)⁻¹) 1 ρ :=
    ContinuousOn.circleIntegrable hρ.le (hBcont.mono Metric.sphere_subset_closedBall)
  have hB0 : (∮ z in C((1 : ℂ), ρ), ((c₀ - c₁) / 2) * (1 + z)⁻¹) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      hBcont (fun z hz => hBdiff z (Metric.ball_subset_closedBall hz.1))
  have h1 : (∮ z in C((1 : ℂ), ρ), (-((c₀ + c₁) / 2)) * (z - 1)⁻¹)
      = (-((c₀ + c₁) / 2)) * (2 * (Real.pi : ℂ) * I) := by
    have hsmul := circleIntegral.integral_smul (E := ℂ) (-((c₀ + c₁) / 2))
      (fun z : ℂ => (z - 1)⁻¹) 1 ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral.integral_sub_inv_of_mem_ball (Metric.mem_ball_self hρ)]
  rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_add hint1 hint2, h1, hB0,
    add_zero]

/-- **The residue at `q = -1` is `(c₀ - c₁)/2`.**  This is the second singularity, invisible in
the eventually polynomial theory. -/
theorem circleIntegral_periodicGF_neg_one {ρ : ℝ} (hρ : 0 < ρ) (hρ2 : ρ < 2) :
    (∮ z in C((-1 : ℂ), ρ), periodicGF c₀ c₁ z)
      = ((c₀ - c₁) / 2) * (2 * (Real.pi : ℂ) * I) := by
  have hsub := sphere_subset_compl_pair (w := (-1 : ℂ)) (Or.inr rfl) hρ hρ2
  have hne : ∀ z ∈ Metric.sphere (-1 : ℂ) ρ, z ≠ 1 ∧ z - (-1) ≠ 0 := by
    intro z hz
    have := hsub hz
    simp only [Set.mem_compl_iff, Set.mem_insert_iff, Set.mem_singleton_iff, not_or] at this
    exact ⟨this.1, sub_ne_zero.mpr this.2⟩
  have hclosed : ∀ z ∈ Metric.closedBall (-1 : ℂ) ρ, (1 : ℂ) - z ≠ 0 := by
    intro z hz h
    have hz1 : z = 1 := by linear_combination -h
    rw [hz1] at hz
    simp only [Metric.mem_closedBall, Complex.dist_eq] at hz
    have hnorm : ‖(1 : ℂ) - (-1)‖ = 2 := by norm_num
    rw [hnorm] at hz
    linarith
  have hAdiff : ∀ z ∈ Metric.closedBall (-1 : ℂ) ρ,
      DifferentiableAt ℂ (fun w : ℂ => ((c₀ + c₁) / 2) * (1 - w)⁻¹) z := by
    intro z hz
    have h := hclosed z hz
    fun_prop (disch := assumption)
  have hAcont : ContinuousOn (fun w : ℂ => ((c₀ + c₁) / 2) * (1 - w)⁻¹)
      (Metric.closedBall (-1 : ℂ) ρ) :=
    fun z hz => (hAdiff z hz).continuousAt.continuousWithinAt
  have hEq : Set.EqOn (periodicGF c₀ c₁)
      (fun z => ((c₀ - c₁) / 2) * (z - (-1))⁻¹ + ((c₀ + c₁) / 2) * (1 - z)⁻¹)
      (Metric.sphere (-1 : ℂ) ρ) := by
    intro z hz
    obtain ⟨hz1, hz2⟩ := hne z hz
    have hinv : (1 + z)⁻¹ = (z - (-1))⁻¹ := by
      rw [show (1 : ℂ) + z = z - (-1) by ring]
    simp only
    rw [periodicGF_eq_partialFractions hz1 (fun h => hz2 (by rw [h]; ring)), hinv]
    ring
  have hint1 : CircleIntegrable (fun z : ℂ => ((c₀ - c₁) / 2) * (z - (-1))⁻¹) (-1) ρ :=
    ContinuousOn.circleIntegrable hρ.le
      (continuousOn_const.mul ((continuousOn_id.sub continuousOn_const).inv₀
        (fun z hz => (hne z hz).2)))
  have hint2 : CircleIntegrable (fun w : ℂ => ((c₀ + c₁) / 2) * (1 - w)⁻¹) (-1) ρ :=
    ContinuousOn.circleIntegrable hρ.le (hAcont.mono Metric.sphere_subset_closedBall)
  have hA0 : (∮ z in C((-1 : ℂ), ρ), ((c₀ + c₁) / 2) * (1 - z)⁻¹) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      hAcont (fun z hz => hAdiff z (Metric.ball_subset_closedBall hz.1))
  have h1 : (∮ z in C((-1 : ℂ), ρ), ((c₀ - c₁) / 2) * (z - (-1))⁻¹)
      = ((c₀ - c₁) / 2) * (2 * (Real.pi : ℂ) * I) := by
    have hsmul := circleIntegral.integral_smul (E := ℂ) ((c₀ - c₁) / 2)
      (fun z : ℂ => (z - (-1))⁻¹) (-1) ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral.integral_sub_inv_of_mem_ball (Metric.mem_ball_self hρ)]
  rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_add hint1 hint2, h1, hA0,
    add_zero]

/-! ### Eventually two-periodic coefficients -/

/-- The polynomial correction accounting for the finitely many grades on which a coefficient
sequence differs from the two-periodic pattern. -/
noncomputable def periodicTail (a : ℕ → ℂ) (c₀ c₁ : ℂ) (N : ℕ) (q : ℂ) : ℂ :=
  ∑ n ∈ range N, (a n - periodicCoeff c₀ c₁ n) * q ^ n

theorem differentiable_periodicTail (a : ℕ → ℂ) (c₀ c₁ : ℂ) (N : ℕ) :
    Differentiable ℂ (periodicTail a c₀ c₁ N) := by
  unfold periodicTail
  exact Differentiable.fun_sum fun n _ => by fun_prop

/-- **Splitting off the exceptional grades.** -/
theorem tsum_eq_periodicTail_add_periodicGF {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = periodicCoeff c₀ c₁ n) {q : ℂ} (hq : ‖q‖ < 1) :
    ∑' n : ℕ, a n * q ^ n = periodicTail a c₀ c₁ N q + periodicGF c₀ c₁ q := by
  classical
  have hP := hasSum_periodicCoeff c₀ c₁ hq
  have he0 : ∀ n : ℕ, n ∉ range N → (a n - periodicCoeff c₀ c₁ n) * q ^ n = 0 := by
    intro n hn
    have hn' : N ≤ n := by simpa using hn
    simp [hcoef n hn']
  have hE : HasSum (fun n : ℕ => (a n - periodicCoeff c₀ c₁ n) * q ^ n)
      (periodicTail a c₀ c₁ N q) := hasSum_sum_of_ne_finset_zero he0
  refine HasSum.tsum_eq ((hE.add hP).congr_fun fun n => ?_)
  ring

/-- **Existence of the continuation** for eventually two-periodic coefficients. -/
theorem exists_analytic_continuation_periodic {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = periodicCoeff c₀ c₁ n) :
    ∃ F : ℂ → ℂ, AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ) ∧
      (∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) := by
  have hDan : AnalyticOnNhd ℂ (periodicTail a c₀ c₁ N) ({(1 : ℂ), -1}ᶜ) :=
    fun z _ => (differentiable_periodicTail a c₀ c₁ N).analyticAt z
  refine ⟨fun q => periodicTail a c₀ c₁ N q + periodicGF c₀ c₁ q, ?_, ?_⟩
  · exact hDan.add analyticOnNhd_periodicGF
  · filter_upwards [Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hball
    rw [tsum_eq_periodicTail_add_periodicGF hcoef (by simpa using hball)]

/-- Every analytic continuation to `ℂ \ {1, -1}` agrees off the singularities with the
canonical one. -/
theorem eqOn_periodicTail_add_periodicGF {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = periodicCoeff c₀ c₁ n) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ))
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) :
    Set.EqOn F (fun q => periodicTail a c₀ c₁ N q + periodicGF c₀ c₁ q) ({(1 : ℂ), -1}ᶜ) := by
  have hDan : AnalyticOnNhd ℂ (periodicTail a c₀ c₁ N) ({(1 : ℂ), -1}ᶜ) :=
    fun z _ => (differentiable_periodicTail a c₀ c₁ N).analyticAt z
  refine eqOn_compl_pair_of_eventuallyEq hF (hDan.add analyticOnNhd_periodicGF) ?_
  filter_upwards [hF0, Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hq hball
  rw [hq, tsum_eq_periodicTail_add_periodicGF hcoef (by simpa using hball)]

/-- Auxiliary: for an eventually two-periodic sequence the contour integral of any
continuation around either singularity is that of the closed form. -/
theorem circleIntegral_eq_of_eventually_periodic {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = periodicCoeff c₀ c₁ n) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ))
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    {w : ℂ} (hw : w = 1 ∨ w = -1) {ρ : ℝ} (hρ : 0 < ρ) (hρ2 : ρ < 2) :
    (∮ z in C(w, ρ), F z) = (∮ z in C(w, ρ), periodicGF c₀ c₁ z) := by
  have hsub := sphere_subset_compl_pair hw hρ hρ2
  have hEq := eqOn_periodicTail_add_periodicGF hcoef hF hF0
  have hDdiff : Differentiable ℂ (periodicTail a c₀ c₁ N) := differentiable_periodicTail a c₀ c₁ N
  have hintD : CircleIntegrable (periodicTail a c₀ c₁ N) w ρ :=
    hDdiff.continuous.continuousOn.circleIntegrable hρ.le
  have hintZ : CircleIntegrable (periodicGF c₀ c₁) w ρ := by
    refine ContinuousOn.circleIntegrable hρ.le fun z hz => ?_
    have hzan : AnalyticAt ℂ (periodicGF c₀ c₁) z :=
      analyticOnNhd_periodicGF z (hsub hz)
    exact hzan.continuousAt.continuousWithinAt
  have hD0 : (∮ z in C(w, ρ), periodicTail a c₀ c₁ N z) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      hDdiff.continuous.continuousOn fun z _ => hDdiff z
  rw [circleIntegral.integral_congr hρ.le (hEq.mono hsub),
    circleIntegral.integral_add hintD hintZ, hD0, zero_add]

/-- **The residue at `q = 1` only sees the tail.** -/
theorem circleIntegral_eventually_periodic_one {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = periodicCoeff c₀ c₁ n) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ))
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) (hρ2 : ρ < 2) :
    (∮ z in C((1 : ℂ), ρ), F z) = -((c₀ + c₁) / 2) * (2 * (Real.pi : ℂ) * I) := by
  rw [circleIntegral_eq_of_eventually_periodic hcoef hF hF0 (Or.inl rfl) hρ hρ2,
    circleIntegral_periodicGF_one hρ hρ2]

/-- **The residue at the second singularity `q = -1` only sees the tail.** -/
theorem circleIntegral_eventually_periodic_neg_one {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = periodicCoeff c₀ c₁ n) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ))
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) (hρ2 : ρ < 2) :
    (∮ z in C((-1 : ℂ), ρ), F z) = ((c₀ - c₁) / 2) * (2 * (Real.pi : ℂ) * I) := by
  rw [circleIntegral_eq_of_eventually_periodic hcoef hF hF0 (Or.inr rfl) hρ hρ2,
    circleIntegral_periodicGF_neg_one hρ hρ2]

/-! ### The dichotomy for graded `G`-sets -/

variable {G : Type*} [Group G] {Y : ℕ → Type*} [∀ n, MulAction G (Y n)] {r N : ℕ}

/-- **The second singularity is a periodicity detector.**  For a graded `G`-set whose
transitivity counts are eventually two-periodic with values `k₀` and `k₁`, the contour
integral around `q = -1` vanishes if and only if `k₀ = k₁`. -/
theorem circleIntegral_neg_one_eq_zero_iff {k₀ k₁ : ℕ}
    (hper : ∀ n, N ≤ n → transCount G r (Y n) = if Even n then k₀ else k₁) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ))
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) (hρ2 : ρ < 2) :
    (∮ z in C((-1 : ℂ), ρ), F z) = 0 ↔ k₀ = k₁ := by
  have hcoef : ∀ n, N ≤ n → ((transCount G r (Y n) : ℂ))
      = periodicCoeff (k₀ : ℂ) (k₁ : ℂ) n := by
    intro n hn
    rw [hper n hn, periodicCoeff]
    split_ifs <;> simp
  rw [circleIntegral_eventually_periodic_neg_one hcoef hF hF0 hρ hρ2]
  have hpi : (2 * (Real.pi : ℂ) * I) ≠ 0 := by
    simp [Real.pi_ne_zero, Complex.I_ne_zero, Complex.ofReal_eq_zero]
  constructor
  · intro h
    have h2 : ((k₀ : ℂ) - (k₁ : ℂ)) / 2 = 0 := by
      rcases mul_eq_zero.mp h with h' | h'
      · exact h'
      · exact absurd h' hpi
    have : (k₀ : ℂ) = (k₁ : ℂ) := by
      field_simp at h2
      linear_combination h2
    exact_mod_cast this
  · intro h
    subst h
    simp

/-- **An eventually `r`-transitive graded `G`-set has no second singularity.**  Its transitivity
counts are eventually the constant `1`, so the residue at `q = -1` vanishes while the residue
at `q = 1` is the universal constant `-1`. -/
theorem circleIntegral_transitive_neg_one (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n))
    {F : ℂ → ℂ} (hF : AnalyticOnNhd ℂ F ({(1 : ℂ), -1}ᶜ))
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) (hρ2 : ρ < 2) :
    (∮ z in C((-1 : ℂ), ρ), F z) = 0 ∧
      (∮ z in C((1 : ℂ), ρ), F z) = -(2 * (Real.pi : ℂ) * I) := by
  have hcoef : ∀ n, N ≤ n → ((transCount G r (Y n) : ℂ)) = periodicCoeff (1 : ℂ) 1 n := by
    intro n hn
    have h1 : transCount G r (Y n) = 1 := (transCount_eq_one_iff r (Y n)).mpr (h n hn)
    rw [h1, periodicCoeff]
    split_ifs <;> simp
  refine ⟨?_, ?_⟩
  · rw [circleIntegral_eventually_periodic_neg_one hcoef hF hF0 hρ hρ2]
    simp
  · rw [circleIntegral_eventually_periodic_one hcoef hF hF0 hρ hρ2]
    norm_num

end Physics.GradedTransitivity