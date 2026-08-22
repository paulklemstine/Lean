import Physics.GradedTransitivityAnalytic

/-!
# Graded `G`-sets: the transitivity partition function as a meromorphic function of `q ∈ ℂ`

`Physics.GradedTransitivityAnalytic` proved, for **real** `q` with `|q| < 1`,

  `∑ₙ t r Yₙ qⁿ = ∑_{n < N} t r Yₙ qⁿ + q^N / (1 − q)`.

This file carries out the two remaining steps of the programme:

* the passage from `ℝ` to `ℂ` (the series converges on the whole complex unit disc, with the
  same closed form, and the real statement is its restriction), and
* the **residue computation** at the unique singularity `q = 1`.

The structural mechanism is the *exact* partial-fraction splitting

  `∑_{n<N} aₙ qⁿ + c·q^N/(1−q) = ⟨entire polynomial⟩ − c/(q − 1)`   (`q ≠ 1`),

which exhibits the partition function as an entire function plus a single simple pole with
residue `−c`.  For the transitivity partition function `c = 1`, so the residue equals `−1`
*independently* of the graded `G`-set and of the transitivity degree `r`: the polar part is
universal, and only the entire part remembers the finitely many non-transitive grades.

## Main results

* `Physics.GradedTransitivity.zetaConst` — the closed form
  `q ↦ ∑_{n<N} aₙ qⁿ + c q^N/(1−q)` as a function on all of `ℂ`.
* `Physics.GradedTransitivity.zetaConst_eq_poly_sub` — the partial-fraction splitting.
* `Physics.GradedTransitivity.tsum_zetaConst` — on the complex unit disc `zetaConst` is the
  sum of the series (complex version of `tsum_of_eventually_const`).
* `Physics.GradedTransitivity.ofReal_zetaConst`,
  `Physics.GradedTransitivity.ofReal_tsum_eq` — the `ℝ → ℂ` bridge: the real partition
  function of `Physics.GradedTransitivityAnalytic` is the restriction of the complex one.
* `Physics.GradedTransitivity.analyticOnNhd_zetaConst` — analyticity on `ℂ \ {1}`.
* `Physics.GradedTransitivity.tendsto_sub_one_mul_zetaConst` — `(q − 1) Z(q) → −c`.
* `Physics.GradedTransitivity.circleIntegral_zetaConst` — the residue computation:
  `∮_{|q−1|=ρ} Z(q) dq = −c · 2πi` for every `ρ > 0`.
* `Physics.GradedTransitivity.order_zetaConst` — `Z` is meromorphic at `1` of order exactly
  `−1` when `c ≠ 0`: a simple pole and nothing worse.
* `Physics.GradedTransitivity.eqOn_of_analyticOnNhd` — uniqueness of the continuation: any
  function analytic on `ℂ \ {1}` agreeing with the series near `0` *is* `Z`.
* `Physics.GradedTransitivity.tsum_transCount_complex`,
  `Physics.GradedTransitivity.circleIntegral_transCount`, `Physics.GradedTransitivity.order_transCount` — the specialisations to the
  transitivity partition function: the residue is the universal constant `−1`.
-/

namespace Physics.GradedTransitivity

open Finset Complex Filter Topology

variable {G : Type*} [Group G]

/-- The closed form of the partition function of an eventually constant coefficient
sequence, as a function on all of `ℂ` (at `q = 1` the Lean value is junk). -/
noncomputable def zetaConst (a : ℕ → ℤ) (N : ℕ) (c : ℤ) (q : ℂ) : ℂ :=
  (∑ n ∈ range N, (a n : ℂ) * q ^ n) + (c : ℂ) * q ^ N / (1 - q)

/-- The entire part of `zetaConst`: what remains after subtracting the polar part
`−c/(q − 1)`. -/
noncomputable def zetaConstPoly (a : ℕ → ℤ) (N : ℕ) (c : ℤ) (q : ℂ) : ℂ :=
  (∑ n ∈ range N, (a n : ℂ) * q ^ n) - (c : ℂ) * ∑ k ∈ range N, q ^ k

section

variable {a : ℕ → ℤ} {N : ℕ} {c : ℤ}

/-- **Exact partial-fraction splitting.**  Away from `q = 1` the partition function is an
entire polynomial minus the simple pole `c/(q − 1)`. -/
theorem zetaConst_eq_poly_sub {q : ℂ} (hq : q ≠ 1) :
    zetaConst a N c q = zetaConstPoly a N c q - (c : ℂ) * (q - 1)⁻¹ := by
  have h1 : q - 1 ≠ 0 := sub_ne_zero.mpr hq
  have h2 : (1 : ℂ) - q ≠ 0 := fun h => h1 (by linear_combination -h)
  rw [zetaConst, zetaConstPoly, geom_sum_eq hq]
  field_simp
  ring

/-- The entire part really is entire. -/
theorem differentiable_zetaConstPoly : Differentiable ℂ (zetaConstPoly a N c) := by
  unfold zetaConstPoly
  fun_prop

/-- The function `(q − 1)·Z(q)` extends across `q = 1` with value `−c`; here is the
extension, an entire function. -/
theorem differentiable_zetaResidual :
    Differentiable ℂ (fun z : ℂ => (z - 1) * zetaConstPoly a N c z - (c : ℂ)) := by
  have := differentiable_zetaConstPoly (a := a) (N := N) (c := c)
  fun_prop

/-- The identity `(q − 1)² · Z(q) = (q − 1)·((q − 1)·P(q) − c)`, valid at **every** point of
`ℂ` — including `q = 1`, where both sides vanish.  This is what makes `Z` meromorphic at `1`
in the sense of Mathlib (which is sensitive to the junk value at the pole). -/
theorem sq_smul_zetaConst (z : ℂ) :
    (z - 1) ^ 2 • zetaConst a N c z = (z - 1) * ((z - 1) * zetaConstPoly a N c z - (c : ℂ)) := by
  rcases eq_or_ne z 1 with rfl | hz
  · simp
  · have hz' : z - 1 ≠ 0 := sub_ne_zero.mpr hz
    rw [zetaConst_eq_poly_sub hz, smul_eq_mul]
    field_simp

/-- **Complex geometric summation.**  For `‖q‖ < 1` an eventually constant coefficient
sequence sums to the closed form `zetaConst`. -/
theorem tsum_zetaConst (ha : ∀ n, N ≤ n → a n = c) {q : ℂ} (hq : ‖q‖ < 1) :
    ∑' n, (a n : ℂ) * q ^ n = zetaConst a N c q := by
  have htail : ∀ n : ℕ, ((a (n + N) : ℂ) * q ^ (n + N)) = ((c : ℂ) * q ^ N) * q ^ n := by
    intro n
    rw [ha (n + N) (Nat.le_add_left _ _), pow_add]
    ring
  have hgeo : Summable (fun n : ℕ => ((c : ℂ) * q ^ N) * q ^ n) :=
    (summable_geometric_of_norm_lt_one hq).mul_left _
  have hshift : Summable (fun n : ℕ => (a (n + N) : ℂ) * q ^ (n + N)) := by
    simpa [htail] using hgeo
  have hsummable : Summable (fun n : ℕ => (a n : ℂ) * q ^ n) :=
    (summable_nat_add_iff N).mp hshift
  have hsplit := hsummable.sum_add_tsum_nat_add N
  have htailsum : ∑' n : ℕ, (a (n + N) : ℂ) * q ^ (n + N) = (c : ℂ) * q ^ N / (1 - q) := by
    calc ∑' n : ℕ, (a (n + N) : ℂ) * q ^ (n + N)
        = ∑' n : ℕ, ((c : ℂ) * q ^ N) * q ^ n := tsum_congr htail
      _ = ((c : ℂ) * q ^ N) * ∑' n : ℕ, q ^ n := by rw [tsum_mul_left]
      _ = (c : ℂ) * q ^ N / (1 - q) := by
          rw [tsum_geometric_of_norm_lt_one hq]; ring
  rw [← hsplit, htailsum, zetaConst]

/-- **The `ℝ → ℂ` bridge for the closed forms.**  The real rational function appearing in
`Physics.GradedTransitivity.tsum_of_eventually_const` is the restriction of `zetaConst` to
the real line. -/
theorem ofReal_zetaConst (q : ℝ) :
    (((∑ n ∈ range N, (a n : ℝ) * q ^ n) + (c : ℝ) * q ^ N / (1 - q) : ℝ) : ℂ)
      = zetaConst a N c (q : ℂ) := by
  unfold zetaConst
  push_cast
  ring

/-- **The `ℝ → ℂ` bridge for the sums.**  Summing the real series and complexifying gives the
same result as summing the complexified series. -/
theorem ofReal_tsum_eq (a : ℕ → ℤ) (q : ℝ) :
    ((∑' n, (a n : ℝ) * q ^ n : ℝ) : ℂ) = ∑' n, (a n : ℂ) * (q : ℂ) ^ n := by
  rw [Complex.ofReal_tsum]
  exact tsum_congr fun n => by push_cast; ring

/-- The real theorem of `Physics.GradedTransitivityAnalytic` is exactly the restriction of
the complex one to `(−1, 1)`. -/
theorem tsum_complex_ofReal_eq (ha : ∀ n, N ≤ n → a n = c) {q : ℝ} (hq : |q| < 1) :
    ∑' n, (a n : ℂ) * (q : ℂ) ^ n
      = (((∑ n ∈ range N, (a n : ℝ) * q ^ n) + (c : ℝ) * q ^ N / (1 - q) : ℝ) : ℂ) := by
  rw [← ofReal_tsum_eq a q, tsum_of_eventually_const ha hq]

/-- `Z` is differentiable off its single singularity. -/
theorem differentiableOn_zetaConst : DifferentiableOn ℂ (zetaConst a N c) {(1 : ℂ)}ᶜ := by
  intro q hq
  have h2 : (1 : ℂ) - q ≠ 0 := by
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff] at hq
    exact fun h => hq (by linear_combination -h)
  apply DifferentiableAt.differentiableWithinAt
  unfold zetaConst
  fun_prop (disch := assumption)

/-- **Analyticity on the punctured plane.**  `Z` is analytic at every `q ≠ 1`. -/
theorem analyticOnNhd_zetaConst : AnalyticOnNhd ℂ (zetaConst a N c) {(1 : ℂ)}ᶜ :=
  differentiableOn_zetaConst.analyticOnNhd isOpen_compl_singleton

/-- **The pole is simple with residue `−c`**: `(q − 1) · Z(q) → −c` as `q → 1`. -/
theorem tendsto_sub_one_mul_zetaConst :
    Tendsto (fun q => (q - 1) * zetaConst a N c q) (𝓝[≠] (1 : ℂ)) (𝓝 (-(c : ℂ))) := by
  have hcont : Tendsto (fun z : ℂ => (z - 1) * zetaConstPoly a N c z - (c : ℂ)) (𝓝 1)
      (𝓝 ((1 - 1) * zetaConstPoly a N c 1 - (c : ℂ))) :=
    differentiable_zetaResidual.continuous.tendsto 1
  simp only [sub_self, zero_mul, zero_sub] at hcont
  refine (hcont.mono_left nhdsWithin_le_nhds).congr' ?_
  filter_upwards [self_mem_nhdsWithin] with z hz
  have hz' : z - 1 ≠ 0 := sub_ne_zero.mpr hz
  rw [zetaConst_eq_poly_sub hz]
  field_simp

/-- `Z` is meromorphic at its singularity. -/
theorem meromorphicAt_zetaConst : MeromorphicAt (zetaConst a N c) 1 := by
  refine ⟨2, ?_⟩
  have h : (fun z => (z - 1) ^ 2 • zetaConst a N c z)
      = fun z => (z - 1) * ((z - 1) * zetaConstPoly a N c z - (c : ℂ)) := funext sq_smul_zetaConst
  rw [h]
  have hd : Differentiable ℂ
      (fun z : ℂ => (z - 1) * ((z - 1) * zetaConstPoly a N c z - (c : ℂ))) := by
    have := differentiable_zetaResidual (a := a) (N := N) (c := c)
    fun_prop
  exact hd.analyticAt 1

/-- **The order of the pole is exactly `−1`** when `c ≠ 0`: a simple pole, nothing worse and
nothing weaker. -/
theorem order_zetaConst (hc : c ≠ 0) :
    meromorphicOrderAt (zetaConst a N c) 1 = ((-1 : ℤ) : WithTop ℤ) := by
  rw [meromorphicOrderAt_eq_int_iff meromorphicAt_zetaConst]
  refine ⟨fun z => (z - 1) * zetaConstPoly a N c z - (c : ℂ),
    differentiable_zetaResidual.analyticAt 1, ?_, ?_⟩
  · simp only [sub_self, zero_mul, zero_sub, ne_eq, neg_eq_zero, Int.cast_eq_zero]
    exact_mod_cast hc
  · filter_upwards [self_mem_nhdsWithin] with z hz
    have hz' : z - 1 ≠ 0 := sub_ne_zero.mpr hz
    rw [zetaConst_eq_poly_sub hz, smul_eq_mul, zpow_neg_one]
    field_simp

/-- No point of a circle of positive radius around `1` is the singularity. -/
theorem sub_one_ne_zero_of_mem_sphere {ρ : ℝ} (hρ : 0 < ρ) :
    ∀ z ∈ Metric.sphere (1 : ℂ) ρ, z - 1 ≠ 0 := by
  intro z hz h
  have hz1 : z = 1 := by linear_combination h
  simp only [Metric.mem_sphere, hz1, dist_self] at hz
  exact absurd hz.symm (ne_of_gt hρ)

/-- **The residue computation.**  For every circle around `1` the contour integral of the
partition function is `−c · 2πi`; that is, `Res_{q=1} Z = −c`. -/
theorem circleIntegral_zetaConst {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), zetaConst a N c z) = -(c : ℂ) * (2 * (Real.pi : ℂ) * I) := by
  have hsphere := sub_one_ne_zero_of_mem_sphere (ρ := ρ) hρ
  have hEq : Set.EqOn (zetaConst a N c)
      (fun z => zetaConstPoly a N c z + (-(c : ℂ)) * (z - 1)⁻¹) (Metric.sphere (1 : ℂ) ρ) := by
    intro z hz
    have hz1 : z ≠ 1 := sub_ne_zero.mp (hsphere z hz)
    rw [zetaConst_eq_poly_sub hz1]
    ring
  have hint1 : CircleIntegrable (zetaConstPoly a N c) 1 ρ :=
    differentiable_zetaConstPoly.continuous.continuousOn.circleIntegrable hρ.le
  have hint2 : CircleIntegrable (fun z : ℂ => (-(c : ℂ)) * (z - 1)⁻¹) 1 ρ :=
    ContinuousOn.circleIntegrable hρ.le
      (continuousOn_const.mul ((continuousOn_id.sub continuousOn_const).inv₀ hsphere))
  have h1 : (∮ z in C((1 : ℂ), ρ), zetaConstPoly a N c z) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      differentiable_zetaConstPoly.continuous.continuousOn
      (fun z _ => differentiable_zetaConstPoly z)
  have h2 : (∮ z in C((1 : ℂ), ρ), (-(c : ℂ)) * (z - 1)⁻¹)
      = (-(c : ℂ)) * (2 * (Real.pi : ℂ) * I) := by
    have hsmul := circleIntegral.integral_smul (E := ℂ) (-(c : ℂ)) (fun z : ℂ => (z - 1)⁻¹) 1 ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral.integral_sub_inv_of_mem_ball (Metric.mem_ball_self hρ)]
  rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_add hint1 hint2, h1, h2,
    zero_add]

/-- The punctured plane is preconnected — the geometric input to the identity theorem. -/
theorem isPreconnected_compl_one : IsPreconnected ({(1 : ℂ)}ᶜ) := by
  have hrank : (1 : Cardinal) < Module.rank ℝ ℂ := by
    rw [Complex.rank_real_complex]; norm_num
  exact ((isPathConnected_compl_singleton_of_one_lt_rank hrank 1).isConnected).isPreconnected

/-- **Existence of the continuation.**  The closed form `Z` *is* an analytic continuation of the
series to `ℂ \ {1}`, so the hypotheses of the uniqueness and residue theorems are not vacuous. -/
theorem exists_analytic_continuation_of_eventually_const (ha : ∀ n, N ≤ n → a n = c) :
    ∃ F : ℂ → ℂ, AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ ∧
      (∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n, (a n : ℂ) * q ^ n) := by
  refine ⟨zetaConst a N c, analyticOnNhd_zetaConst, ?_⟩
  filter_upwards [Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hball
  exact (tsum_zetaConst ha (by simpa using hball)).symm

/-- **Uniqueness of the meromorphic continuation.**  Any function analytic on `ℂ \ {1}` which
agrees with the power series near the origin coincides with `Z` on all of `ℂ \ {1}`. -/
theorem eqOn_of_analyticOnNhd (ha : ∀ n, N ≤ n → a n = c) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n, (a n : ℂ) * q ^ n) :
    Set.EqOn F (zetaConst a N c) {(1 : ℂ)}ᶜ := by
  have h0 : (0 : ℂ) ∈ ({(1 : ℂ)}ᶜ : Set ℂ) := by
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    exact zero_ne_one
  refine hF.eqOn_of_preconnected_of_eventuallyEq analyticOnNhd_zetaConst isPreconnected_compl_one
    h0 ?_
  filter_upwards [hF0, Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hq hball
  rw [hq, tsum_zetaConst ha (by simpa using hball)]

end

/-! ### Specialisation to the transitivity partition function -/

variable {Y : ℕ → Type*} [∀ n, MulAction G (Y n)] {r N : ℕ}

/-- The transitivity counts of an eventually `r`-transitive graded `G`-set form an eventually
constant integer sequence with constant `1`. -/
theorem transCount_eventually_one (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) :
    ∀ n, N ≤ n → ((transCount G r (Y n) : ℤ)) = 1 := by
  intro n hn
  have := (transCount_eq_one_iff r (Y n)).mpr (h n hn)
  simp [this]

/-- **Analytic form of the main theorem over `ℂ`.**  If the grades of a graded `G`-set are
eventually `r`-transitive then, for every complex `q` in the open unit disc, the transitivity
generating function converges to the explicit rational function whose only singularity is the
simple pole at `q = 1`. -/
theorem tsum_transCount_complex (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) {q : ℂ}
    (hq : ‖q‖ < 1) :
    ∑' n, (transCount G r (Y n) : ℂ) * q ^ n
      = (∑ n ∈ range N, (transCount G r (Y n) : ℂ) * q ^ n) + q ^ N / (1 - q) := by
  have := tsum_zetaConst (a := fun n => (transCount G r (Y n) : ℤ)) (N := N) (c := 1)
    (transCount_eventually_one h) hq
  simpa [zetaConst] using this

/-- **Universality of the polar part.**  Let `F` be *any* function analytic on `ℂ \ {1}` that
represents the transitivity partition function near the origin.  Then for every circle around
`q = 1`,

  `∮ F = −2πi`,

i.e. the residue of the transitivity partition function at its unique singularity is the
universal constant `−1`, independent of the group, of the graded `G`-set and of `r`. -/
theorem circleIntegral_transCount (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n, (transCount G r (Y n) : ℂ) * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), F z) = -(2 * (Real.pi : ℂ) * I) := by
  set a : ℕ → ℤ := fun n => (transCount G r (Y n) : ℤ) with ha_def
  have hF0' : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n, (a n : ℂ) * q ^ n := by
    filter_upwards [hF0] with q hq using by simpa [ha_def] using hq
  have hEqOn : Set.EqOn F (zetaConst a N 1) {(1 : ℂ)}ᶜ :=
    eqOn_of_analyticOnNhd (transCount_eventually_one h) hF hF0'
  have hsub : Metric.sphere (1 : ℂ) ρ ⊆ {(1 : ℂ)}ᶜ := by
    intro z hz
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    exact sub_ne_zero.mp (sub_one_ne_zero_of_mem_sphere hρ z hz)
  rw [circleIntegral.integral_congr hρ.le (hEqOn.mono hsub), circleIntegral_zetaConst hρ]
  push_cast
  ring

/-- **The pole of the transitivity partition function is simple.**  Any analytic continuation
`F` of the transitivity generating function to `ℂ \ {1}` is meromorphic at `q = 1` of order
exactly `−1`. -/
theorem order_transCount (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n, (transCount G r (Y n) : ℂ) * q ^ n) :
    meromorphicOrderAt F 1 = ((-1 : ℤ) : WithTop ℤ) := by
  set a : ℕ → ℤ := fun n => (transCount G r (Y n) : ℤ) with ha_def
  have hF0' : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n, (a n : ℂ) * q ^ n := by
    filter_upwards [hF0] with q hq using by simpa [ha_def] using hq
  have hEqOn : Set.EqOn F (zetaConst a N 1) {(1 : ℂ)}ᶜ :=
    eqOn_of_analyticOnNhd (transCount_eventually_one h) hF hF0'
  have hgerm : F =ᶠ[𝓝[≠] (1 : ℂ)] zetaConst a N 1 := by
    filter_upwards [self_mem_nhdsWithin] with z hz
    exact hEqOn (by simpa using hz)
  rw [meromorphicOrderAt_congr hgerm]
  exact order_zetaConst one_ne_zero

end Physics.GradedTransitivity