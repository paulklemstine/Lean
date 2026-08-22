import Physics.GradedTransitivityFourier
import Physics.GradedTransitivityResidue

/-!
# Quasi-polynomial grade counts: a residue at every root of unity

This file closes the main open direction of the thread: the residue computation for grade
counts that are **quasi-polynomial**, i.e. eventually given by

  `aₙ = P_{n mod m}(n)`

for polynomials `P₀, …, P_{m-1}`.  Previous files handled the two degenerate cases — a single
polynomial (`Physics.GradedTransitivityResidue`, pole only at `q = 1`) and a periodic sequence
of *constants* (`Physics.GradedTransitivityFourier`, simple poles at all `m`-th roots of
unity).  The quasi-polynomial case combines them: the partition function continues
analytically to the complement of the `m`-th roots of unity and has, at the root `ζ^{-k}`, the
residue

  `−(1/(m ζᵏ)) ∑_{j<m} ζ^{−kj} P_j(−1)`,

exactly the value conjectured in the previous cycle.  The mechanism is the twisted
zeta-regularisation

  `∑ₙ P(n) wⁿ qⁿ = polyZeta P (w q)`,  residue at `q = w⁻¹` equal to `−P(−1)/w`,

proved here for a single twist and then summed over the discrete Fourier decomposition of the
grade count, whose `k`-th amplitude is itself a *polynomial* — the section polynomial
`sectionPoly`.

## Main results

* `Physics.GradedTransitivity.twistPolyZeta`, `hasSum_twistPolyZeta` — the closed form of
  `∑ₙ P(n) wⁿ qⁿ` and its convergence.
* `Physics.GradedTransitivity.circleIntegral_twistPolyZeta` — the residue `−P(−1)/w` of a
  single twisted polynomial grade count at `q = w⁻¹`.
* `Physics.GradedTransitivity.multiPolyZeta`, `circleIntegral_multiPolyZeta` — the finite sum
  of twists and its residue at each pole.
* `Physics.GradedTransitivity.circleIntegral_eventually_twistedPolynomial` — tail-only version:
  the residue of any analytic continuation.
* `Physics.GradedTransitivity.sectionPoly`, `quasiPolynomial_eq_section_sum` — the discrete
  Fourier decomposition of a quasi-polynomial grade count into twisted polynomial pieces.
* `Physics.GradedTransitivity.circleIntegral_eventually_quasiPolynomial` — **the residue of a
  quasi-polynomial grade count at every `m`-th root of unity**.
-/

namespace Physics.GradedTransitivity

open Finset Polynomial Complex Filter Topology

/-! ### One twisted polynomial -/

/-- The partition function of a twisted polynomial grade count `n ↦ P(n) wⁿ`. -/
noncomputable def twistPolyZeta (P : Polynomial ℂ) (w q : ℂ) : ℂ := polyZeta P (w * q)

/-- `∑ₙ P(n) qⁿ` converges to `polyZeta P q` on the unit disc. -/
theorem hasSum_polyZeta (P : Polynomial ℂ) {q : ℂ} (hq : ‖q‖ < 1) :
    HasSum (fun n : ℕ => P.eval (n : ℂ) * q ^ n) (polyZeta P q) := by
  have hsum : HasSum (fun n : ℕ => ∑ k ∈ range (P.natDegree + 1),
      newtonCoeff P k * ((n.choose k : ℂ) * q ^ n)) (polyZeta P q) :=
    hasSum_sum fun k _ => (hasSum_choose_pow k hq).mul_left (newtonCoeff P k)
  refine hsum.congr_fun fun n => ?_
  rw [newton_eval_natCast P n, Finset.sum_mul]
  exact Finset.sum_congr rfl fun k _ => by ring

/-- **Summation of a twisted polynomial grade count.** -/
theorem hasSum_twistPolyZeta (P : Polynomial ℂ) (w : ℂ) {q : ℂ} (hq : ‖w * q‖ < 1) :
    HasSum (fun n : ℕ => P.eval (n : ℂ) * w ^ n * q ^ n) (twistPolyZeta P w q) := by
  refine (hasSum_polyZeta P hq).congr_fun fun n => ?_
  rw [mul_pow]
  ring

theorem differentiableAt_twistPolyZeta {P : Polynomial ℂ} {w : ℂ} (hw : w ≠ 0) {q : ℂ}
    (hq : q ≠ w⁻¹) : DifferentiableAt ℂ (twistPolyZeta P w) q := by
  have hmem : w * q ∈ ({(1 : ℂ)}ᶜ : Set ℂ) := by
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    intro h
    apply hq
    field_simp
    linear_combination h
  have houter : DifferentiableAt ℂ (polyZeta P) (w * q) :=
    (analyticOnNhd_polyZeta P _ hmem).differentiableAt
  exact houter.comp q (by fun_prop)

/-- **The residue of a twisted binomial basis element.**  Around `q = w⁻¹`,
`(wq)ᵏ/(1−wq)^{k+1}` integrates to `((−1)^{k+1}/w)·2πi`. -/
theorem circleIntegral_twist_choose_term {w : ℂ} (hw : w ≠ 0) (k : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C(w⁻¹, ρ), (w * z) ^ k / (1 - w * z) ^ (k + 1))
      = ((-1) ^ (k + 1) / w) * (2 * (Real.pi : ℂ) * I) := by
  have hne : ∀ z ∈ Metric.sphere w⁻¹ ρ, z - w⁻¹ ≠ 0 := by
    intro z hz h
    have hz1 : z = w⁻¹ := by linear_combination h
    simp only [Metric.mem_sphere, hz1, dist_self] at hz
    exact absurd hz.symm (ne_of_gt hρ)
  have hEq : Set.EqOn (fun z : ℂ => (w * z) ^ k / (1 - w * z) ^ (k + 1))
      (fun z : ℂ => ∑ i ∈ range (k + 1),
        ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ) * w ^ i / w ^ (k + 1))
          * (z - w⁻¹) ^ ((i : ℤ) - (k + 1)))
      (Metric.sphere w⁻¹ ρ) := by
    intro z hz
    have hx : z - w⁻¹ ≠ 0 := hne z hz
    have hwz : w * z = w * (z - w⁻¹) + 1 := by
      field_simp
      ring
    have hnum : (w * z) ^ k
        = ∑ i ∈ range (k + 1), (w * (z - w⁻¹)) ^ i * (k.choose i : ℂ) := by
      rw [hwz]
      simpa using add_pow (w * (z - w⁻¹)) (1 : ℂ) k
    have hden : (1 - w * z) ^ (k + 1)
        = (-1 : ℂ) ^ (k + 1) * (w * (z - w⁻¹)) ^ (k + 1) := by
      rw [show (1 : ℂ) - w * z = -(w * (z - w⁻¹)) by rw [hwz]; ring, neg_pow]
    have hsq : ((-1 : ℂ) ^ (k + 1)) * ((-1 : ℂ) ^ (k + 1)) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    have hinv : ((-1 : ℂ) ^ (k + 1))⁻¹ = (-1 : ℂ) ^ (k + 1) := inv_eq_of_mul_eq_one_right hsq
    simp only [hnum, hden, Finset.sum_div]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hzp : (z - w⁻¹) ^ ((i : ℤ) - (k + 1))
        = (z - w⁻¹) ^ i / (z - w⁻¹) ^ (k + 1) := by
      rw [show ((i : ℤ) - (k + 1)) = (i : ℤ) - ((k : ℤ) + 1) by ring, zpow_sub₀ hx]
      norm_cast
    rw [hzp, mul_pow, mul_pow, div_eq_mul_inv, div_eq_mul_inv, div_eq_mul_inv, mul_inv, mul_inv,
      hinv]
    ring
  have hint : ∀ i ∈ range (k + 1), CircleIntegrable
      (fun z : ℂ => ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ) * w ^ i / w ^ (k + 1))
        * (z - w⁻¹) ^ ((i : ℤ) - (k + 1))) w⁻¹ ρ := by
    intro i _
    refine ContinuousOn.circleIntegrable hρ.le ?_
    exact continuousOn_const.mul
      ((continuousOn_id.sub continuousOn_const).zpow₀ _ fun z hz => Or.inl (hne z hz))
  rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_fun_sum hint,
    Finset.sum_eq_single k]
  · have h1 : ((k : ℤ) - (k + 1)) = -1 := by ring
    have hsmul := circleIntegral.integral_smul (E := ℂ)
      ((-1 : ℂ) ^ (k + 1) * (k.choose k : ℂ) * w ^ k / w ^ (k + 1))
      (fun z : ℂ => (z - w⁻¹) ^ ((k : ℤ) - (k + 1))) w⁻¹ ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, h1]
    simp only [zpow_neg, zpow_one]
    rw [circleIntegral.integral_sub_inv_of_mem_ball (Metric.mem_ball_self hρ), Nat.choose_self]
    have hwk : w ^ (k + 1) = w ^ k * w := by rw [pow_succ]
    rw [hwk]
    field_simp
    norm_num
  · intro i _ hik
    have hne' : ((i : ℤ) - (k + 1)) ≠ -1 := by intro h; exact hik (by omega)
    have hsmul := circleIntegral.integral_smul (E := ℂ)
      ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ) * w ^ i / w ^ (k + 1))
      (fun z : ℂ => (z - w⁻¹) ^ ((i : ℤ) - (k + 1))) w⁻¹ ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral.integral_sub_zpow_of_ne hne']
    simp
  · intro h
    exact absurd (Finset.self_mem_range_succ k) h

/-- **The residue of a twisted polynomial grade count.**  At its unique singularity `q = w⁻¹`
the partition function of `n ↦ P(n) wⁿ` has residue `−P(−1)/w`. -/
theorem circleIntegral_twistPolyZeta {w : ℂ} (hw : w ≠ 0) (P : Polynomial ℂ) {ρ : ℝ}
    (hρ : 0 < ρ) :
    (∮ z in C(w⁻¹, ρ), twistPolyZeta P w z) = (-P.eval (-1) / w) * (2 * (Real.pi : ℂ) * I) := by
  have hne : ∀ z ∈ Metric.sphere w⁻¹ ρ, z - w⁻¹ ≠ 0 := by
    intro z hz h
    have hz1 : z = w⁻¹ := by linear_combination h
    simp only [Metric.mem_sphere, hz1, dist_self] at hz
    exact absurd hz.symm (ne_of_gt hρ)
  have hden : ∀ z ∈ Metric.sphere w⁻¹ ρ, (1 : ℂ) - w * z ≠ 0 := by
    intro z hz h
    refine hne z hz ?_
    have hwz : w * z = 1 := by linear_combination -h
    field_simp
    linear_combination hwz
  have hEq : Set.EqOn (twistPolyZeta P w)
      (fun z : ℂ => ∑ k ∈ range (P.natDegree + 1),
        newtonCoeff P k * ((w * z) ^ k / (1 - w * z) ^ (k + 1)))
      (Metric.sphere w⁻¹ ρ) := fun z _ => rfl
  have hint : ∀ k ∈ range (P.natDegree + 1), CircleIntegrable
      (fun z : ℂ => newtonCoeff P k * ((w * z) ^ k / (1 - w * z) ^ (k + 1))) w⁻¹ ρ := by
    intro k _
    refine ContinuousOn.circleIntegrable hρ.le (continuousOn_const.mul ?_)
    refine ContinuousOn.div ((continuousOn_const.mul continuousOn_id).pow k)
      ((continuousOn_const.sub (continuousOn_const.mul continuousOn_id)).pow (k + 1))
      fun z hz => pow_ne_zero _ (hden z hz)
  have hterm : ∀ k ∈ range (P.natDegree + 1),
      (∮ z in C(w⁻¹, ρ), newtonCoeff P k * ((w * z) ^ k / (1 - w * z) ^ (k + 1)))
        = newtonCoeff P k * (((-1) ^ (k + 1) / w) * (2 * (Real.pi : ℂ) * I)) := by
    intro k _
    have hsmul := circleIntegral.integral_smul (E := ℂ) (newtonCoeff P k)
      (fun z : ℂ => (w * z) ^ k / (1 - w * z) ^ (k + 1)) w⁻¹ ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral_twist_choose_term hw k hρ]
  calc (∮ z in C(w⁻¹, ρ), twistPolyZeta P w z)
      = ∑ k ∈ range (P.natDegree + 1),
          ∮ z in C(w⁻¹, ρ), newtonCoeff P k * ((w * z) ^ k / (1 - w * z) ^ (k + 1)) := by
        rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_fun_sum hint]
    _ = ∑ k ∈ range (P.natDegree + 1),
          newtonCoeff P k * (((-1) ^ (k + 1) / w) * (2 * (Real.pi : ℂ) * I)) :=
        Finset.sum_congr rfl hterm
    _ = (-(∑ k ∈ range (P.natDegree + 1), (-1 : ℂ) ^ k * newtonCoeff P k) / w)
          * (2 * (Real.pi : ℂ) * I) := by
        rw [neg_div, neg_mul, Finset.sum_div, Finset.sum_mul, ← Finset.sum_neg_distrib]
        exact Finset.sum_congr rfl fun k _ => by rw [pow_succ]; field_simp
    _ = (-P.eval (-1) / w) * (2 * (Real.pi : ℂ) * I) := by rw [← eval_neg_one_eq_alternating P]

/-! ### Finite sums of twisted polynomials -/

section Multi

variable {ι : Type*} [Fintype ι]

/-- The partition function of a finite sum of twisted polynomial grade counts
`aₙ = ∑ᵢ Pᵢ(n) wᵢⁿ`. -/
noncomputable def multiPolyZeta (Ps : ι → Polynomial ℂ) (w : ι → ℂ) (q : ℂ) : ℂ :=
  ∑ i, twistPolyZeta (Ps i) (w i) q

theorem hasSum_multiPolyZeta (Ps : ι → Polynomial ℂ) (w : ι → ℂ) {q : ℂ} (hq : ‖q‖ < 1)
    (hw : ∀ i, ‖w i‖ ≤ 1) :
    HasSum (fun n : ℕ => (∑ i, (Ps i).eval (n : ℂ) * (w i) ^ n) * q ^ n)
      (multiPolyZeta Ps w q) := by
  have hterm : ∀ i : ι, HasSum (fun n : ℕ => (Ps i).eval (n : ℂ) * (w i) ^ n * q ^ n)
      (twistPolyZeta (Ps i) (w i) q) := by
    intro i
    refine hasSum_twistPolyZeta (Ps i) (w i) ?_
    rw [norm_mul]
    calc ‖w i‖ * ‖q‖ ≤ 1 * ‖q‖ := mul_le_mul_of_nonneg_right (hw i) (norm_nonneg q)
      _ < 1 := by rw [one_mul]; exact hq
  refine (hasSum_sum fun i _ => hterm i).congr_fun fun n => ?_
  rw [Finset.sum_mul]

theorem differentiableAt_multiPolyZeta {Ps : ι → Polynomial ℂ} {w : ι → ℂ} (hw : ∀ i, w i ≠ 0)
    {q : ℂ} (hq : q ∉ twistPoles w) : DifferentiableAt ℂ (multiPolyZeta Ps w) q := by
  unfold multiPolyZeta
  exact DifferentiableAt.fun_sum fun i _ =>
    differentiableAt_twistPolyZeta (hw i) (ne_of_notMem_twistPoles hq i)

theorem analyticOnNhd_multiPolyZeta {Ps : ι → Polynomial ℂ} {w : ι → ℂ} (hw : ∀ i, w i ≠ 0) :
    AnalyticOnNhd ℂ (multiPolyZeta Ps w) (twistPoles w)ᶜ := by
  refine DifferentiableOn.analyticOnNhd (fun q hq => ?_)
    (finite_twistPoles w).isClosed.isOpen_compl
  exact (differentiableAt_multiPolyZeta hw hq).differentiableWithinAt

/-- **The residue at one pole of a finite sum of twisted polynomials.**  Only the matching
twist contributes: the residue at `q = wⱼ⁻¹` is `−Pⱼ(−1)/wⱼ`. -/
theorem circleIntegral_multiPolyZeta {Ps : ι → Polynomial ℂ} {w : ι → ℂ} (hw : ∀ i, w i ≠ 0)
    (j : ι) {ρ : ℝ} (hρ : 0 < ρ) (hsep : ∀ i, i ≠ j → ρ < dist ((w j)⁻¹) ((w i)⁻¹)) :
    (∮ z in C((w j)⁻¹, ρ), multiPolyZeta Ps w z)
      = (-(Ps j).eval (-1) / w j) * (2 * (Real.pi : ℂ) * I) := by
  have hsub := sphere_subset_compl_twistPoles j hρ hsep
  have hint : ∀ i ∈ (univ : Finset ι),
      CircleIntegrable (twistPolyZeta (Ps i) (w i)) ((w j)⁻¹) ρ := by
    intro i _
    refine ContinuousOn.circleIntegrable hρ.le fun z hz => ?_
    have hz' : z ≠ (w i)⁻¹ := ne_of_notMem_twistPoles (hsub hz) i
    exact (differentiableAt_twistPolyZeta (hw i) hz').continuousAt.continuousWithinAt
  have hzero : ∀ i ∈ (univ : Finset ι), i ≠ j →
      (∮ z in C((w j)⁻¹, ρ), twistPolyZeta (Ps i) (w i) z) = 0 := by
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
        (differentiableAt_twistPolyZeta (hw i) (hball z hz)).continuousAt.continuousWithinAt
    · exact fun z hz =>
        differentiableAt_twistPolyZeta (hw i) (hball z (Metric.ball_subset_closedBall hz.1))
  simp only [multiPolyZeta]
  rw [circleIntegral.integral_fun_sum hint,
    Finset.sum_eq_single j (fun i hi hij => hzero i hi hij) (fun h => absurd (mem_univ j) h),
    circleIntegral_twistPolyZeta (hw j) (Ps j) hρ]

/-! ### Eventually twisted-polynomial coefficients -/

/-- The correction accounting for the finitely many grades where the grade count differs from
the twisted polynomial sum. -/
noncomputable def quasiTail (a : ℕ → ℂ) (Ps : ι → Polynomial ℂ) (w : ι → ℂ) (N : ℕ) (q : ℂ) : ℂ :=
  ∑ n ∈ range N, (a n - ∑ i, (Ps i).eval (n : ℂ) * (w i) ^ n) * q ^ n

theorem differentiable_quasiTail (a : ℕ → ℂ) (Ps : ι → Polynomial ℂ) (w : ι → ℂ) (N : ℕ) :
    Differentiable ℂ (quasiTail a Ps w N) := by
  unfold quasiTail
  exact Differentiable.fun_sum fun n _ => by fun_prop

theorem tsum_eq_quasiTail_add_multiPolyZeta {a : ℕ → ℂ} {Ps : ι → Polynomial ℂ} {w : ι → ℂ}
    {N : ℕ} (hcoef : ∀ n, N ≤ n → a n = ∑ i, (Ps i).eval (n : ℂ) * (w i) ^ n)
    (hw : ∀ i, ‖w i‖ ≤ 1) {q : ℂ} (hq : ‖q‖ < 1) :
    ∑' n : ℕ, a n * q ^ n = quasiTail a Ps w N q + multiPolyZeta Ps w q := by
  classical
  have hP := hasSum_multiPolyZeta Ps w hq hw
  have he0 : ∀ n : ℕ, n ∉ range N →
      (a n - ∑ i, (Ps i).eval (n : ℂ) * (w i) ^ n) * q ^ n = 0 := by
    intro n hn
    have hn' : N ≤ n := by simpa using hn
    simp [hcoef n hn']
  have hE : HasSum (fun n : ℕ => (a n - ∑ i, (Ps i).eval (n : ℂ) * (w i) ^ n) * q ^ n)
      (quasiTail a Ps w N q) := hasSum_sum_of_ne_finset_zero he0
  refine HasSum.tsum_eq ((hE.add hP).congr_fun fun n => ?_)
  ring

theorem eqOn_quasiTail_add_multiPolyZeta {a : ℕ → ℂ} {Ps : ι → Polynomial ℂ} {w : ι → ℂ} {N : ℕ}
    (hwne : ∀ i, w i ≠ 0) (hcoef : ∀ n, N ≤ n → a n = ∑ i, (Ps i).eval (n : ℂ) * (w i) ^ n)
    (hw : ∀ i, ‖w i‖ ≤ 1) (h0 : (0 : ℂ) ∉ twistPoles w) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles w)ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) :
    Set.EqOn F (fun q => quasiTail a Ps w N q + multiPolyZeta Ps w q) ((twistPoles w)ᶜ) := by
  have hDan : AnalyticOnNhd ℂ (quasiTail a Ps w N) ((twistPoles w)ᶜ) :=
    fun z _ => (differentiable_quasiTail a Ps w N).analyticAt z
  refine hF.eqOn_of_preconnected_of_eventuallyEq (hDan.add (analyticOnNhd_multiPolyZeta hwne))
    (isPreconnected_compl_twistPoles w) h0 ?_
  filter_upwards [hF0, Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hq hball
  rw [hq, tsum_eq_quasiTail_add_multiPolyZeta hcoef hw (by simpa using hball)]

/-- **The residue only sees the tail, in the twisted polynomial setting.** -/
theorem circleIntegral_eventually_twistedPolynomial {a : ℕ → ℂ} {Ps : ι → Polynomial ℂ}
    {w : ι → ℂ} {N : ℕ} (hwne : ∀ i, w i ≠ 0)
    (hcoef : ∀ n, N ≤ n → a n = ∑ i, (Ps i).eval (n : ℂ) * (w i) ^ n)
    (hw : ∀ i, ‖w i‖ ≤ 1) (h0 : (0 : ℂ) ∉ twistPoles w) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles w)ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (j : ι) {ρ : ℝ} (hρ : 0 < ρ) (hsep : ∀ i, i ≠ j → ρ < dist ((w j)⁻¹) ((w i)⁻¹)) :
    (∮ z in C((w j)⁻¹, ρ), F z)
      = (-(Ps j).eval (-1) / w j) * (2 * (Real.pi : ℂ) * I) := by
  have hsub := sphere_subset_compl_twistPoles j hρ hsep
  have hEq := eqOn_quasiTail_add_multiPolyZeta hwne hcoef hw h0 hF hF0
  have hDdiff : Differentiable ℂ (quasiTail a Ps w N) := differentiable_quasiTail a Ps w N
  have hintD : CircleIntegrable (quasiTail a Ps w N) ((w j)⁻¹) ρ :=
    hDdiff.continuous.continuousOn.circleIntegrable hρ.le
  have hintZ : CircleIntegrable (multiPolyZeta Ps w) ((w j)⁻¹) ρ := by
    refine ContinuousOn.circleIntegrable hρ.le fun z hz => ?_
    exact (differentiableAt_multiPolyZeta hwne (hsub hz)).continuousAt.continuousWithinAt
  have hD0 : (∮ z in C((w j)⁻¹, ρ), quasiTail a Ps w N z) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      hDdiff.continuous.continuousOn fun z _ => hDdiff z
  rw [circleIntegral.integral_congr hρ.le (hEq.mono hsub),
    circleIntegral.integral_add hintD hintZ, hD0, zero_add,
    circleIntegral_multiPolyZeta hwne j hρ hsep]

end Multi

/-! ### Quasi-polynomial grade counts -/

section Quasi

variable {m : ℕ} {zeta : ℂ}

/-- The `k`-th **section polynomial** of a quasi-polynomial grade count: the discrete Fourier
amplitude of the period `P₀, …, P_{m-1}`, itself a polynomial. -/
noncomputable def sectionPoly (zeta : ℂ) (Ps : ℕ → Polynomial ℂ) (m k : ℕ) : Polynomial ℂ :=
  Polynomial.C ((m : ℂ)⁻¹) * ∑ j ∈ range m, Polynomial.C ((zeta ^ (k * j))⁻¹) * Ps j

theorem eval_sectionPoly (zeta : ℂ) (Ps : ℕ → Polynomial ℂ) (m k : ℕ) (x : ℂ) :
    (sectionPoly zeta Ps m k).eval x
      = fourierAmp zeta (fun j => (Ps j).eval x) m k := by
  simp only [sectionPoly, fourierAmp, eval_mul, eval_C, eval_finset_sum]

/-- **Discrete Fourier decomposition of a quasi-polynomial grade count.**  A grade count of the
form `aₙ = P_{n mod m}(n)` is a sum of `m` twisted polynomial grade counts, with twists the
`m`-th roots of unity and coefficient polynomials the section polynomials. -/
theorem quasiPolynomial_eq_section_sum (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    (Ps : ℕ → Polynomial ℂ) (n : ℕ) :
    (Ps (n % m)).eval (n : ℂ)
      = ∑ k : Fin m, (sectionPoly zeta Ps m (k : ℕ)).eval (n : ℂ) * (zeta ^ (k : ℕ)) ^ n := by
  have h := periodic_eq_fourier_sum hm hz (fun j => (Ps j).eval (n : ℂ)) n
  rw [h]
  exact Finset.sum_congr rfl fun k _ => by rw [eval_sectionPoly]

/-- **The residue of a quasi-polynomial grade count at every `m`-th root of unity.**  If the
grade counts satisfy `aₙ = P_{n mod m}(n)` for all large `n`, then every analytic continuation
of the partition function off the `m`-th roots of unity has, at the pole `ζ^{-k}`, the residue

  `−(1/(m ζᵏ)) ∑_{j<m} ζ^{−kj} P_j(−1)`. -/
theorem circleIntegral_eventually_quasiPolynomial (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {Ps : ℕ → Polynomial ℂ} {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = (Ps (n % m)).eval (n : ℂ)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (k : Fin m) {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ i : Fin m, i ≠ k → ρ < dist ((zeta ^ (k : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹)) :
    (∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), F z)
      = (-(sectionPoly zeta Ps m (k : ℕ)).eval (-1) / zeta ^ (k : ℕ))
          * (2 * (Real.pi : ℂ) * I) := by
  have hcoef' : ∀ n, N ≤ n → a n = ∑ i : Fin m,
      ((fun i : Fin m => sectionPoly zeta Ps m (i : ℕ)) i).eval (n : ℂ)
        * ((fun i : Fin m => zeta ^ (i : ℕ)) i) ^ n := by
    intro n hn
    rw [hcoef n hn]
    exact quasiPolynomial_eq_section_sum hm hz Ps n
  exact circleIntegral_eventually_twistedPolynomial (ι := Fin m)
    (Ps := fun i : Fin m => sectionPoly zeta Ps m (i : ℕ))
    (w := fun i : Fin m => zeta ^ (i : ℕ))
    (fun i => root_pow_ne_zero hm hz (i : ℕ)) hcoef'
    (fun i => le_of_eq (norm_root_pow_eq_one hm hz (i : ℕ)))
    (zero_notMem_twistPoles_root hm hz) hF hF0 k hρ hsep

/-- **The conjectured closed form of the residue.**  Written out, the residue at `ζ^{-k}` is
`−(1/(m ζᵏ)) ∑_{j<m} ζ^{−kj} P_j(−1)`. -/
theorem circleIntegral_eventually_quasiPolynomial_formula (hm : 0 < m)
    (hz : IsPrimitiveRoot zeta m) {Ps : ℕ → Polynomial ℂ} {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = (Ps (n % m)).eval (n : ℂ)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (k : Fin m) {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ i : Fin m, i ≠ k → ρ < dist ((zeta ^ (k : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹)) :
    (∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), F z)
      = -((m : ℂ)⁻¹ * ∑ j ∈ range m, (zeta ^ ((k : ℕ) * j))⁻¹ * (Ps j).eval (-1))
          / zeta ^ (k : ℕ) * (2 * (Real.pi : ℂ) * I) := by
  rw [circleIntegral_eventually_quasiPolynomial hm hz hcoef hF hF0 k hρ hsep,
    eval_sectionPoly, fourierAmp]

/-- **Consistency with the constant-section case.**  For grade counts that are eventually
periodic mod `m` with constant sections, the quasi-polynomial residue reduces to the residue
`−Âₖ/ζᵏ` of `circleIntegral_eventually_periodic_mod`. -/
theorem sectionPoly_const (zeta : ℂ) (c : ℕ → ℂ) (m k : ℕ) :
    (sectionPoly zeta (fun j => Polynomial.C (c j)) m k).eval (-1) = fourierAmp zeta c m k := by
  rw [eval_sectionPoly]
  simp

end Quasi

end Physics.GradedTransitivity