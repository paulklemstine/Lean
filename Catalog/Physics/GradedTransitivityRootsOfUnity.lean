import Physics.GradedTransitivityPeriodic

/-!
# Exponential grade counts: a singularity at every twist

The thread so far analysed grade counts that are eventually constant, eventually polynomial,
or eventually two-periodic.  All three are special cases of a *finite exponential sum*

  `aₙ = ∑ᵢ Aᵢ · wᵢⁿ`,

for which the partition function is the finite sum of simple poles

  `Z(q) = ∑ᵢ Aᵢ / (1 - wᵢ q)`,

with one singularity at each `q = wᵢ⁻¹` and residue `-Aᵢ / wᵢ` there.  This file proves that
statement in full, for an arbitrary finite index type and arbitrary nonzero twists `wᵢ` in the
closed unit disc, and derives the eventual (tail-only) version: the finitely many exceptional
grades change nothing.

Specialising to `wᵢ` running over the `m`-th roots of unity turns a grade count that is
periodic mod `m` into its discrete Fourier expansion, and the theorem then reads: *the
partition function has a simple pole at every `m`-th root of unity, whose residue is the
corresponding Fourier coefficient (up to the twist)*.  The `m = 2` instance is proved here
explicitly and is checked against the independently proved results of
`Physics.GradedTransitivityPeriodic`.

## Main results

* `Physics.GradedTransitivity.circleIntegral_twistZeta` — the twisted geometric series
  `∑ₙ c wⁿ qⁿ` has a single simple pole at `q = w⁻¹` with residue `-c/w`.
* `Physics.GradedTransitivity.circleIntegral_multiZeta` — for a finite exponential sum the
  residue at `q = wⱼ⁻¹` is `-Aⱼ/wⱼ`; the other twists are invisible.
* `Physics.GradedTransitivity.circleIntegral_eventually_exponential` — the same for an
  arbitrary analytic continuation of a generating function whose coefficients are eventually
  a finite exponential sum.
* `Physics.GradedTransitivity.periodicCoeff_eq_fourier` — the two-periodic sequence is the
  exponential sum with twists `1, -1`, reconciling this file with the residues
  `-(c₀+c₁)/2` and `(c₀-c₁)/2` proved in `Physics.GradedTransitivityPeriodic`.
-/

namespace Physics.GradedTransitivity

open Finset Complex Filter Topology

/-! ### A single twist -/

/-- The partition function of the twisted constant sequence `n ↦ c · wⁿ`. -/
noncomputable def twistZeta (c w q : ℂ) : ℂ := c / (1 - w * q)

variable {c w : ℂ}

theorem one_sub_mul_ne_zero (hw : w ≠ 0) {q : ℂ} (hq : q ≠ w⁻¹) : 1 - w * q ≠ 0 := by
  intro h
  apply hq
  have hwq : w * q = 1 := by linear_combination -h
  field_simp
  linear_combination hwq

/-- The twisted partition function is *exactly* a simple pole at `q = w⁻¹`: there is no
entire part at all. -/
theorem twistZeta_eq_simple_pole (hw : w ≠ 0) {q : ℂ} (hq : q ≠ w⁻¹) :
    twistZeta c w q = (-c / w) * (q - w⁻¹)⁻¹ := by
  have hden : 1 - w * q ≠ 0 := one_sub_mul_ne_zero hw hq
  have hsub : q - w⁻¹ ≠ 0 := sub_ne_zero.mpr hq
  rw [twistZeta, eq_comm, mul_inv_eq_iff_eq_mul₀ hsub, div_mul_eq_mul_div,
    div_eq_div_iff hw hden]
  field_simp
  ring

/-- **Summation of the twisted geometric series.** -/
theorem hasSum_twistZeta (c w : ℂ) {q : ℂ} (hq : ‖w * q‖ < 1) :
    HasSum (fun n : ℕ => c * w ^ n * q ^ n) (twistZeta c w q) := by
  have hgeo : HasSum (fun n : ℕ => (w * q) ^ n) (1 - w * q)⁻¹ :=
    hasSum_geometric_of_norm_lt_one hq
  have hval : twistZeta c w q = c * (1 - w * q)⁻¹ := by rw [twistZeta, div_eq_mul_inv]
  rw [hval]
  refine (hgeo.mul_left c).congr_fun fun n => ?_
  rw [mul_pow]
  ring

theorem differentiableAt_twistZeta (hw : w ≠ 0) {q : ℂ} (hq : q ≠ w⁻¹) :
    DifferentiableAt ℂ (twistZeta c w) q := by
  have hden : 1 - w * q ≠ 0 := one_sub_mul_ne_zero hw hq
  unfold twistZeta
  fun_prop (disch := assumption)

/-- **The residue of a single twist.**  Every circle around `w⁻¹` sees the residue `-c/w`. -/
theorem circleIntegral_twistZeta (hw : w ≠ 0) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C(w⁻¹, ρ), twistZeta c w z) = (-c / w) * (2 * (Real.pi : ℂ) * I) := by
  have hne : ∀ z ∈ Metric.sphere w⁻¹ ρ, z - w⁻¹ ≠ 0 := by
    intro z hz h
    have hz1 : z = w⁻¹ := by linear_combination h
    simp only [Metric.mem_sphere, hz1, dist_self] at hz
    exact absurd hz.symm (ne_of_gt hρ)
  have hEq : Set.EqOn (twistZeta c w) (fun z => (-c / w) * (z - w⁻¹)⁻¹)
      (Metric.sphere w⁻¹ ρ) := fun z hz =>
    twistZeta_eq_simple_pole hw (sub_ne_zero.mp (hne z hz))
  rw [circleIntegral.integral_congr hρ.le hEq]
  have hsmul := circleIntegral.integral_smul (E := ℂ) (-c / w) (fun z : ℂ => (z - w⁻¹)⁻¹) w⁻¹ ρ
  simp only [smul_eq_mul] at hsmul
  rw [hsmul, circleIntegral.integral_sub_inv_of_mem_ball (Metric.mem_ball_self hρ)]

/-! ### Finite exponential sums -/

variable {ι : Type*} [Fintype ι]

/-- The partition function of a finite exponential sum `aₙ = ∑ᵢ Aᵢ wᵢⁿ`. -/
noncomputable def multiZeta (A w : ι → ℂ) (q : ℂ) : ℂ := ∑ i, twistZeta (A i) (w i) q

/-- The set of singularities: one per twist. -/
def twistPoles (w : ι → ℂ) : Set ℂ := Set.range fun i => (w i)⁻¹

theorem finite_twistPoles (w : ι → ℂ) : (twistPoles w).Finite := Set.finite_range _

omit [Fintype ι] in
theorem ne_of_notMem_twistPoles {w : ι → ℂ} {q : ℂ} (hq : q ∉ twistPoles w) (i : ι) :
    q ≠ (w i)⁻¹ := fun h => hq ⟨i, h.symm⟩

/-- **Summation of a finite exponential sum.** -/
theorem hasSum_multiZeta (A w : ι → ℂ) {q : ℂ} (hq : ‖q‖ < 1) (hw : ∀ i, ‖w i‖ ≤ 1) :
    HasSum (fun n : ℕ => (∑ i, A i * (w i) ^ n) * q ^ n) (multiZeta A w q) := by
  have hterm : ∀ i : ι, HasSum (fun n : ℕ => A i * (w i) ^ n * q ^ n) (twistZeta (A i) (w i) q) := by
    intro i
    refine hasSum_twistZeta (A i) (w i) ?_
    rw [norm_mul]
    calc ‖w i‖ * ‖q‖ ≤ 1 * ‖q‖ := by
          exact mul_le_mul_of_nonneg_right (hw i) (norm_nonneg q)
      _ < 1 := by rw [one_mul]; exact hq
  refine (hasSum_sum fun i _ => hterm i).congr_fun fun n => ?_
  rw [Finset.sum_mul]

theorem differentiableAt_multiZeta {A w : ι → ℂ} (hw : ∀ i, w i ≠ 0) {q : ℂ}
    (hq : q ∉ twistPoles w) : DifferentiableAt ℂ (multiZeta A w) q := by
  unfold multiZeta
  exact DifferentiableAt.fun_sum fun i _ =>
    differentiableAt_twistZeta (hw i) (ne_of_notMem_twistPoles hq i)

theorem analyticOnNhd_multiZeta {A w : ι → ℂ} (hw : ∀ i, w i ≠ 0) :
    AnalyticOnNhd ℂ (multiZeta A w) (twistPoles w)ᶜ := by
  refine DifferentiableOn.analyticOnNhd (fun q hq => ?_)
    (finite_twistPoles w).isClosed.isOpen_compl
  exact (differentiableAt_multiZeta hw hq).differentiableWithinAt

omit [Fintype ι] in
/-- A circle around one pole, of radius smaller than the distance to all the others, avoids
every singularity. -/
theorem sphere_subset_compl_twistPoles {w : ι → ℂ} (j : ι) {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ i, i ≠ j → ρ < dist ((w j)⁻¹) ((w i)⁻¹)) :
    Metric.sphere ((w j)⁻¹) ρ ⊆ (twistPoles w)ᶜ := by
  rintro z hz ⟨i, hi⟩
  simp only [Metric.mem_sphere] at hz
  rw [← hi] at hz
  rcases eq_or_ne i j with rfl | hij
  · rw [dist_self] at hz
    exact absurd hz.symm (ne_of_gt hρ)
  · have hlt := hsep i hij
    rw [dist_comm, hz] at hlt
    exact lt_irrefl ρ hlt

/-- **The residue of a finite exponential sum at one of its poles.**  Only the matching twist
contributes: the residue at `q = wⱼ⁻¹` is `-Aⱼ/wⱼ`. -/
theorem circleIntegral_multiZeta {A w : ι → ℂ} (hw : ∀ i, w i ≠ 0) (j : ι) {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ i, i ≠ j → ρ < dist ((w j)⁻¹) ((w i)⁻¹)) :
    (∮ z in C((w j)⁻¹, ρ), multiZeta A w z) = (-A j / w j) * (2 * (Real.pi : ℂ) * I) := by
  have hsub := sphere_subset_compl_twistPoles j hρ hsep
  -- each summand is integrable on the circle
  have hint : ∀ i ∈ (univ : Finset ι), CircleIntegrable (twistZeta (A i) (w i)) ((w j)⁻¹) ρ := by
    intro i _
    refine ContinuousOn.circleIntegrable hρ.le fun z hz => ?_
    have hz' : z ≠ (w i)⁻¹ := ne_of_notMem_twistPoles (hsub hz) i
    exact (differentiableAt_twistZeta (hw i) hz').continuousAt.continuousWithinAt
  -- the non-matching twists are analytic on the whole closed disc, hence integrate to zero
  have hzero : ∀ i ∈ (univ : Finset ι), i ≠ j →
      (∮ z in C((w j)⁻¹, ρ), twistZeta (A i) (w i) z) = 0 := by
    intro i _ hij
    have hball : ∀ z ∈ Metric.closedBall ((w j)⁻¹) ρ, z ≠ (w i)⁻¹ := by
      intro z hz h
      have hd : dist ((w j)⁻¹) ((w i)⁻¹) ≤ ρ := by
        rw [← h, dist_comm]
        exact hz
      exact absurd hd (not_le.mpr (hsep i hij))
    refine Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le
      Set.countable_empty ?_ ?_
    · exact fun z hz =>
        (differentiableAt_twistZeta (hw i) (hball z hz)).continuousAt.continuousWithinAt
    · exact fun z hz =>
        differentiableAt_twistZeta (hw i) (hball z (Metric.ball_subset_closedBall hz.1))
  simp only [multiZeta]
  rw [circleIntegral.integral_fun_sum hint,
    Finset.sum_eq_single j (fun i hi hij => hzero i hi hij) (fun h => absurd (mem_univ j) h),
    circleIntegral_twistZeta (hw j) hρ]

/-! ### Eventually exponential coefficients -/

/-- The polynomial correction for the finitely many grades on which the coefficients differ
from the exponential sum. -/
noncomputable def expTail (a : ℕ → ℂ) (A w : ι → ℂ) (N : ℕ) (q : ℂ) : ℂ :=
  ∑ n ∈ range N, (a n - ∑ i, A i * (w i) ^ n) * q ^ n

theorem differentiable_expTail (a : ℕ → ℂ) (A w : ι → ℂ) (N : ℕ) :
    Differentiable ℂ (expTail a A w N) := by
  unfold expTail
  exact Differentiable.fun_sum fun n _ => by fun_prop

theorem tsum_eq_expTail_add_multiZeta {a : ℕ → ℂ} {A w : ι → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = ∑ i, A i * (w i) ^ n) (hw : ∀ i, ‖w i‖ ≤ 1) {q : ℂ}
    (hq : ‖q‖ < 1) :
    ∑' n : ℕ, a n * q ^ n = expTail a A w N q + multiZeta A w q := by
  classical
  have hP := hasSum_multiZeta A w hq hw
  have he0 : ∀ n : ℕ, n ∉ range N → (a n - ∑ i, A i * (w i) ^ n) * q ^ n = 0 := by
    intro n hn
    have hn' : N ≤ n := by simpa using hn
    simp [hcoef n hn']
  have hE : HasSum (fun n : ℕ => (a n - ∑ i, A i * (w i) ^ n) * q ^ n) (expTail a A w N q) :=
    hasSum_sum_of_ne_finset_zero he0
  refine HasSum.tsum_eq ((hE.add hP).congr_fun fun n => ?_)
  ring

/-- The twice-punctured-plane argument, in the general finite-pole setting: the complement of
the poles is preconnected, so the continuation is unique. -/
theorem isPreconnected_compl_twistPoles (w : ι → ℂ) : IsPreconnected ((twistPoles w)ᶜ) := by
  have hrank : (1 : Cardinal) < Module.rank ℝ ℂ := by
    rw [Complex.rank_real_complex]; norm_num
  exact (((finite_twistPoles w).countable.isPathConnected_compl_of_one_lt_rank
    hrank).isConnected).isPreconnected

theorem eqOn_expTail_add_multiZeta {a : ℕ → ℂ} {A w : ι → ℂ} {N : ℕ} (hwne : ∀ i, w i ≠ 0)
    (hcoef : ∀ n, N ≤ n → a n = ∑ i, A i * (w i) ^ n) (hw : ∀ i, ‖w i‖ ≤ 1)
    (h0 : (0 : ℂ) ∉ twistPoles w) {F : ℂ → ℂ} (hF : AnalyticOnNhd ℂ F (twistPoles w)ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) :
    Set.EqOn F (fun q => expTail a A w N q + multiZeta A w q) ((twistPoles w)ᶜ) := by
  have hDan : AnalyticOnNhd ℂ (expTail a A w N) ((twistPoles w)ᶜ) :=
    fun z _ => (differentiable_expTail a A w N).analyticAt z
  refine hF.eqOn_of_preconnected_of_eventuallyEq (hDan.add (analyticOnNhd_multiZeta hwne))
    (isPreconnected_compl_twistPoles w) h0 ?_
  filter_upwards [hF0, Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hq hball
  rw [hq, tsum_eq_expTail_add_multiZeta hcoef hw (by simpa using hball)]

/-- **The residue only sees the tail, in the exponential setting.**  If the coefficients are
eventually the exponential sum `∑ᵢ Aᵢ wᵢⁿ`, then every analytic continuation of the generating
function has residue `-Aⱼ/wⱼ` at `q = wⱼ⁻¹`. -/
theorem circleIntegral_eventually_exponential {a : ℕ → ℂ} {A w : ι → ℂ} {N : ℕ}
    (hwne : ∀ i, w i ≠ 0) (hcoef : ∀ n, N ≤ n → a n = ∑ i, A i * (w i) ^ n)
    (hw : ∀ i, ‖w i‖ ≤ 1) (h0 : (0 : ℂ) ∉ twistPoles w) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles w)ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (j : ι) {ρ : ℝ} (hρ : 0 < ρ) (hsep : ∀ i, i ≠ j → ρ < dist ((w j)⁻¹) ((w i)⁻¹)) :
    (∮ z in C((w j)⁻¹, ρ), F z) = (-A j / w j) * (2 * (Real.pi : ℂ) * I) := by
  have hsub := sphere_subset_compl_twistPoles j hρ hsep
  have hEq := eqOn_expTail_add_multiZeta hwne hcoef hw h0 hF hF0
  have hDdiff : Differentiable ℂ (expTail a A w N) := differentiable_expTail a A w N
  have hintD : CircleIntegrable (expTail a A w N) ((w j)⁻¹) ρ :=
    hDdiff.continuous.continuousOn.circleIntegrable hρ.le
  have hintZ : CircleIntegrable (multiZeta A w) ((w j)⁻¹) ρ := by
    refine ContinuousOn.circleIntegrable hρ.le fun z hz => ?_
    exact (differentiableAt_multiZeta hwne (hsub hz)).continuousAt.continuousWithinAt
  have hD0 : (∮ z in C((w j)⁻¹, ρ), expTail a A w N z) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      hDdiff.continuous.continuousOn fun z _ => hDdiff z
  rw [circleIntegral.integral_congr hρ.le (hEq.mono hsub),
    circleIntegral.integral_add hintD hintZ, hD0, zero_add,
    circleIntegral_multiZeta hwne j hρ hsep]

/-! ### Consistency with the two-periodic case -/

/-- **Discrete Fourier expansion at `m = 2`.**  The two-periodic sequence is the exponential
sum with twists `1` and `-1` and amplitudes `(c₀+c₁)/2` and `(c₀-c₁)/2`. -/
theorem periodicCoeff_eq_fourier (c₀ c₁ : ℂ) (n : ℕ) :
    periodicCoeff c₀ c₁ n
      = ∑ i : Fin 2, (![(c₀ + c₁) / 2, (c₀ - c₁) / 2] i) * (![(1 : ℂ), -1] i) ^ n := by
  rcases Nat.even_or_odd n with he | ho
  · obtain ⟨k, hk⟩ := he
    have heven : Even n := ⟨k, hk⟩
    have hpow : ((-1 : ℂ)) ^ n = 1 := by
      rw [show n = 2 * k by omega, pow_mul]
      norm_num
    simp only [periodicCoeff, if_pos heven, Fin.sum_univ_two, Matrix.cons_val_zero,
      Matrix.cons_val_one, one_pow, hpow]
    ring
  · obtain ⟨k, hk⟩ := ho
    have hodd : ¬ Even n := by
      rw [Nat.not_even_iff_odd]
      exact ⟨k, hk⟩
    have hpow : ((-1 : ℂ)) ^ n = -1 := by
      rw [hk, pow_succ, pow_mul]
      norm_num
    simp only [periodicCoeff, if_neg hodd, Fin.sum_univ_two, Matrix.cons_val_zero,
      Matrix.cons_val_one, one_pow, hpow]
    ring

/-- The exponential-sum residue at the twist `-1` reproduces the value `(c₀-c₁)/2` computed
independently in `Physics.GradedTransitivityPeriodic`. -/
theorem residue_fourier_neg_one (c₀ c₁ : ℂ) :
    -(![(c₀ + c₁) / 2, (c₀ - c₁) / 2] 1) / (![(1 : ℂ), -1] 1) = (c₀ - c₁) / 2 := by
  have h1 : (![(c₀ + c₁) / 2, (c₀ - c₁) / 2] 1) = (c₀ - c₁) / 2 := rfl
  have h2 : (![(1 : ℂ), -1] 1) = -1 := rfl
  rw [h1, h2]
  ring

/-- The exponential-sum residue at the twist `1` reproduces the value `-(c₀+c₁)/2`. -/
theorem residue_fourier_one (c₀ c₁ : ℂ) :
    -(![(c₀ + c₁) / 2, (c₀ - c₁) / 2] 0) / (![(1 : ℂ), -1] 0) = -((c₀ + c₁) / 2) := by
  have h1 : (![(c₀ + c₁) / 2, (c₀ - c₁) / 2] 0) = (c₀ + c₁) / 2 := rfl
  have h2 : (![(1 : ℂ), -1] 0) = 1 := rfl
  rw [h1, h2]
  ring

end Physics.GradedTransitivity