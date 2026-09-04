/-
# Riemann convergence of Bhattacharyya angle sums to the Fisher–Rao length

Let `t ↦ p t` be a `C¹` curve of strictly positive probability vectors.  The
catalog file `Algebra.FisherRaoLength.Core` proves the *discrete* bound
`‖p_b − p_a‖₁ ≤ ∑ₖ 2 arccos BC(p_{t_k}, p_{t_{k+1}})` and the *smooth* bound
`‖p_b − p_a‖₁ ≤ fisherRaoLength`.  This file calibrates the two: the discrete
Bhattacharyya angle sums converge to the Fisher–Rao length as the mesh of the
partition tends to `0`.

The proof is a two-sided squeeze, both sides coming from the geometry of the
square-root (sphere) embedding developed in `Pythagorean.BhattacharyyaSphere`:

* **upper bound** (valid for *every* partition): `2 arccos BC(p_s, p_t)` is at
  most the Fisher–Rao length of the curve on `[s,t]` — the geodesic bound.  It
  is obtained by subdividing `[s,t]` into `N` equal parts, applying the
  Euclidean chord bound of the catalog on each part, converting chords into
  angles with the sharp inequality `θ √(1−(m/2)²) ≤ m`, and letting `N → ∞`.
* **lower bound** (for fine partitions): `2 arccos BC ≥ 2 · chord`, and the sum
  of the chords is within `4 ε (b−a)` of the length once the mesh is small
  enough for the velocity of the square-root curve to vary by less than `ε`.

## Main results

* `FisherRao.two_arccos_bhattacharyya_le_fisherRaoLength` — the geodesic lower
  bound: `2 arccos BC(p_a, p_b) ≤ fisherRaoLength p v a b`.
* `FisherRao.sum_two_arccos_bhattacharyya_le_fisherRaoLength` — every partition
  sum underestimates the length.
* `FisherRao.fisherRaoLength_le_sum_two_arccos_add` — the quantitative reverse
  bound for fine partitions.
* `FisherRao.riemann_convergence_sum_two_arccos_bhattacharyya` — the calibration
  theorem: the sums converge to `fisherRaoLength` as the mesh tends to `0`.

Consequently `fisherRaoLength` *is* the induced length of the Bhattacharyya
angle metric — no renormalisation of the definition is needed — and the
Fisher–Rao length dominates the spherical (geodesic) distance of the endpoints.
-/
import Pythagorean.BhattacharyyaSphere

open Finset Real InnerProductGeometry MeasureTheory intervalIntegral

namespace FisherRao

variable {ι : Type*} [Fintype ι]

/-! ## The velocity of the square-root curve as a Euclidean vector -/

/-- The velocity of the square-root curve, viewed in `EuclideanSpace ℝ ι`. -/
noncomputable def sqrtVelVec (p v : ℝ → ι → ℝ) (t : ℝ) : EuclideanSpace ℝ ι :=
  WithLp.toLp 2 (sqrtVel p v t)

omit [Fintype ι] in
@[simp] theorem sqrtVelVec_ofLp (p v : ℝ → ι → ℝ) (t : ℝ) (i : ι) :
    (sqrtVelVec p v t).ofLp i = sqrtVel p v t i := rfl

/-- The Euclidean norm of the square-root velocity is half the Fisher–Rao
speed. -/
theorem norm_sqrtVelVec {p v : ℝ → ι → ℝ} (hpos : ∀ t i, 0 < p t i) (t : ℝ) :
    ‖sqrtVelVec p v t‖ = (1 / 2) * fisherRaoSpeed (p t) (v t) := by
  rw [EuclideanSpace.norm_eq, ← sqrtVel_norm_eq hpos t]
  exact congrArg Real.sqrt (Finset.sum_congr rfl fun i _ => by
    rw [sqrtVelVec_ofLp, Real.norm_eq_abs, sq_abs])

/-- The Euclidean norm of the square-root velocity, in coordinates. -/
theorem norm_sqrtVelVec_eq_sqrt (p v : ℝ → ι → ℝ) (t : ℝ) :
    ‖sqrtVelVec p v t‖ = √(∑ i, (sqrtVel p v t i) ^ 2) := by
  rw [EuclideanSpace.norm_eq]
  exact congrArg Real.sqrt (Finset.sum_congr rfl fun i _ => by
    rw [sqrtVelVec_ofLp, Real.norm_eq_abs, sq_abs])

/-- The difference of two square-root velocities, in coordinates. -/
theorem norm_sqrtVelVec_sub {p v : ℝ → ι → ℝ} (r s : ℝ) :
    ‖sqrtVelVec p v r - sqrtVelVec p v s‖
      = √(∑ i, (sqrtVel p v r i - sqrtVel p v s i) ^ 2) := by
  rw [EuclideanSpace.norm_eq]
  exact congrArg Real.sqrt (Finset.sum_congr rfl fun i _ => by
    simp [Real.norm_eq_abs, sq_abs])

omit [Fintype ι] in
theorem continuous_sqrtVelVec {p v : ℝ → ι → ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i) :
    Continuous (sqrtVelVec p v) := by
  have h : Continuous fun t => (sqrtVel p v t : ι → ℝ) :=
    continuous_pi fun i => continuous_sqrtVel hderiv hv hpos i
  exact (EuclideanSpace.equiv ι ℝ).symm.continuous.comp h

/-! ## Elementary facts about the length functional -/

/-- Additivity of the Fisher–Rao length along a finite chain of parameters. -/
theorem fisherRaoLength_sum_partition {p v : ℝ → ι → ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    (T : ℕ → ℝ) (N : ℕ) :
    ∑ k ∈ Finset.range N, fisherRaoLength p v (T k) (T (k + 1))
      = fisherRaoLength p v (T 0) (T N) := by
  induction N with
  | zero => simp [fisherRaoLength]
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      exact fisherRaoLength_add hderiv hv hpos

/-- A speed bound integrates to a length bound. -/
theorem fisherRaoLength_le_of_speed_le {p v : ℝ → ι → ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    {s t M : ℝ} (hst : s ≤ t) (hM : ∀ r ∈ Set.Icc s t, fisherRaoSpeed (p r) (v r) ≤ M) :
    fisherRaoLength p v s t ≤ M * (t - s) := by
  have hcont := continuous_fisherRaoSpeed hderiv hv hpos
  have hconst : IntervalIntegrable (fun _ : ℝ => M) volume s t := _root_.intervalIntegrable_const
  have := intervalIntegral.integral_mono_on hst (hcont.intervalIntegrable s t) hconst hM
  simpa [fisherRaoLength, mul_comm] using this

/-! ## The geodesic bound -/

/-- **Geodesic bound.**  Twice the Bhattacharyya angle between the endpoints of
a `C¹` curve of positive probability vectors is at most its Fisher–Rao length:
the Fisher–Rao length dominates the spherical distance of the square-root
embeddings. -/
theorem two_arccos_bhattacharyya_le_fisherRaoLength {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    (hp1 : ∀ t, ∑ i, p t i = 1) :
    2 * arccos (bhattacharyya (p a) (p b)) ≤ fisherRaoLength p v a b := by
  set θ : ℝ := arccos (bhattacharyya (p a) (p b)) with hθdef
  have hθ0 : 0 ≤ θ := Real.arccos_nonneg _
  have hL0 : 0 ≤ fisherRaoLength p v a b := fisherRaoLength_nonneg p v hab
  -- a uniform speed bound on `[a,b]`
  obtain ⟨M, hM0, hM⟩ : ∃ M : ℝ, 0 ≤ M ∧ ∀ r ∈ Set.Icc a b, fisherRaoSpeed (p r) (v r) ≤ M := by
    obtain ⟨x, _, hmax⟩ := (isCompact_Icc (a := a) (b := b)).exists_isMaxOn
      ⟨a, Set.left_mem_Icc.mpr hab⟩
      (continuous_fisherRaoSpeed hderiv hv hpos).continuousOn
    exact ⟨fisherRaoSpeed (p x) (v x), fisherRaoSpeed_nonneg _ _, fun r hr => hmax hr⟩
  -- the key estimate for the uniform partition of `[a,b]` into `N` pieces
  have key : ∀ N : ℕ, 1 ≤ N → θ * √(1 - (M * ((b - a) / N) / 4) ^ 2)
      ≤ fisherRaoLength p v a b / 2 := by
    intro N hN
    have hNpos : (0:ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN
    set h : ℝ := (b - a) / N with hhdef
    have hh0 : 0 ≤ h := div_nonneg (by linarith) hNpos.le
    have hNh : (N : ℝ) * h = b - a := by rw [hhdef]; field_simp
    set T : ℕ → ℝ := fun k => a + k * h with hTdef
    have hT0 : T 0 = a := by simp [hTdef]
    have hTN : T N = b := by simp only [hTdef]; linarith
    have hstep : ∀ k : ℕ, T (k + 1) - T k = h := by
      intro k
      simp only [hTdef]
      push_cast
      ring
    have hmono : ∀ k : ℕ, T k ≤ T (k + 1) := fun k => by linarith [hstep k]
    have hmem : ∀ k : ℕ, k ≤ N → T k ∈ Set.Icc a b := by
      intro k hk
      have hkN : (k : ℝ) ≤ N := by exact_mod_cast hk
      have h1 : 0 ≤ (k : ℝ) * h := by positivity
      have h2 : (k : ℝ) * h ≤ (N : ℝ) * h := by nlinarith
      exact ⟨by simp only [hTdef]; linarith, by simp only [hTdef]; linarith⟩
    -- each piece of the subdivision is short
    have hLk : ∀ k : ℕ, k < N → fisherRaoLength p v (T k) (T (k + 1)) ≤ M * h := by
      intro k hk
      have hsub : ∀ r ∈ Set.Icc (T k) (T (k + 1)), fisherRaoSpeed (p r) (v r) ≤ M := fun r hr =>
        hM r ⟨le_trans (hmem k hk.le).1 hr.1, le_trans hr.2 (hmem (k + 1) hk).2⟩
      have hlen := fisherRaoLength_le_of_speed_le hderiv hv hpos (hmono k) hsub
      rwa [hstep k] at hlen
    have hLk0 : ∀ k : ℕ, 0 ≤ fisherRaoLength p v (T k) (T (k + 1)) := fun k =>
      fisherRaoLength_nonneg p v (hmono k)
    -- convert the chord bound on each piece into an angle bound, with a uniform factor
    set c : ℝ := √(1 - (M * h / 4) ^ 2) with hcdef
    have hc0 : 0 ≤ c := Real.sqrt_nonneg _
    have hpiece : ∀ k : ℕ, k < N →
        arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) * c
          ≤ fisherRaoLength p v (T k) (T (k + 1)) / 2 := by
      intro k hk
      set Lk : ℝ := fisherRaoLength p v (T k) (T (k + 1)) with hLkdef
      have hchord := sqrt_chord_le_half_fisherRao_length (hmono k) hderiv hv hpos
      have hangle := arccos_bhattacharyya_mul_sqrt_le (p (T (k + 1))) (p (T k))
        (fun i => (hpos _ i).le) (fun i => (hpos _ i).le) (hp1 _) (hp1 _)
        (m := Lk / 2) (by linarith [hLk0 k]) (by linarith [hchord])
      rw [bhattacharyya_comm] at hangle
      have hle : c ≤ √(1 - (Lk / 2 / 2) ^ 2) := by
        refine Real.sqrt_le_sqrt ?_
        have h1 : Lk ≤ M * h := hLk k hk
        have h2 : 0 ≤ Lk := hLk0 k
        nlinarith
      have hθk : 0 ≤ arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) := Real.arccos_nonneg _
      calc arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) * c
          ≤ arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) * √(1 - (Lk / 2 / 2) ^ 2) :=
            mul_le_mul_of_nonneg_left hle hθk
        _ ≤ Lk / 2 := hangle
    -- the spherical triangle inequality along the subdivision
    have htri : θ ≤ ∑ k ∈ Finset.range N, arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) := by
      have hsum := arccos_bhattacharyya_le_sum (fun k => p (T k))
        (fun k i => (hpos _ i).le) (fun k => hp1 _) N
      rwa [hT0, hTN] at hsum
    have hsum : (∑ k ∈ Finset.range N, arccos (bhattacharyya (p (T k)) (p (T (k + 1))))) * c
        ≤ fisherRaoLength p v a b / 2 := by
      rw [Finset.sum_mul]
      have h1 : ∑ k ∈ Finset.range N, arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) * c
          ≤ ∑ k ∈ Finset.range N, fisherRaoLength p v (T k) (T (k + 1)) / 2 :=
        Finset.sum_le_sum fun k hk => hpiece k (Finset.mem_range.mp hk)
      have h2 : ∑ k ∈ Finset.range N, fisherRaoLength p v (T k) (T (k + 1)) / 2
          = fisherRaoLength p v a b / 2 := by
        rw [← Finset.sum_div, fisherRaoLength_sum_partition hderiv hv hpos T N, hT0, hTN]
      linarith
    have hmul := mul_le_mul_of_nonneg_right htri hc0
    linarith
  -- let the mesh tend to zero
  have hlim : Filter.Tendsto
      (fun N : ℕ => θ * √(1 - (M * ((b - a) / N) / 4) ^ 2)) Filter.atTop (nhds (θ * 1)) := by
    have h0 : Filter.Tendsto (fun N : ℕ => (b - a) / N) Filter.atTop (nhds 0) :=
      tendsto_const_div_atTop_nhds_zero_nat (b - a)
    have hg : Filter.Tendsto (fun N : ℕ => (M * ((b - a) / N) / 4) ^ 2) Filter.atTop (nhds 0) := by
      have h3 : Filter.Tendsto (fun N : ℕ => M * ((b - a) / N) / 4) Filter.atTop (nhds 0) := by
        simpa using (h0.const_mul M).div_const 4
      simpa using h3.pow 2
    have h1 : Filter.Tendsto (fun N : ℕ => 1 - (M * ((b - a) / N) / 4) ^ 2)
        Filter.atTop (nhds 1) := by simpa using Filter.Tendsto.const_sub 1 hg
    have h2 := h1.sqrt
    rw [Real.sqrt_one] at h2
    exact h2.const_mul θ
  have hfinal : θ * 1 ≤ fisherRaoLength p v a b / 2 := by
    refine le_of_tendsto hlim ?_
    filter_upwards [Filter.eventually_ge_atTop 1] with N hN using key N hN
  linarith

/-! ## The partition sums never exceed the length -/

/-- Every Bhattacharyya angle sum along an increasing chain of parameters is at
most the Fisher–Rao length of the corresponding piece of the curve. -/
theorem sum_two_arccos_bhattacharyya_le_fisherRaoLength {p v : ℝ → ι → ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    (hp1 : ∀ t, ∑ i, p t i = 1) (T : ℕ → ℝ) (N : ℕ) (hmono : ∀ k < N, T k ≤ T (k + 1)) :
    ∑ k ∈ Finset.range N, 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1))))
      ≤ fisherRaoLength p v (T 0) (T N) := by
  rw [← fisherRaoLength_sum_partition hderiv hv hpos T N]
  refine Finset.sum_le_sum fun k hk => ?_
  exact two_arccos_bhattacharyya_le_fisherRaoLength (hmono k (Finset.mem_range.mp hk))
    hderiv hv hpos hp1

/-! ## The reverse bound for fine partitions -/

/-- **One step of the lower bound.**  If the square-root velocity varies by at
most `e` on `[s,t]`, then the Euclidean chord between the endpoints of the
square-root curve is at least half the Fisher–Rao length minus `2 e (t−s)`. -/
theorem chord_ge_half_fisherRaoLength_sub {p v : ℝ → ι → ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    {s t e : ℝ} (hst : s ≤ t) (he : 0 ≤ e)
    (hunif : ∀ r ∈ Set.Icc s t, ‖sqrtVelVec p v r - sqrtVelVec p v s‖ ≤ e) :
    (1 / 2) * fisherRaoLength p v s t - 2 * e * (t - s)
      ≤ √(∑ i, (√(p t i) - √(p s i)) ^ 2) := by
  set W : ℝ → ι → ℝ := sqrtVel p v with hW
  set n : ℝ := √(∑ i, (W s i) ^ 2) with hn
  have hn0 : 0 ≤ n := Real.sqrt_nonneg _
  have hnsq : n ^ 2 = ∑ i, (W s i) ^ 2 :=
    Real.sq_sqrt (Finset.sum_nonneg fun i _ => sq_nonneg _)
  have hnorm : ‖sqrtVelVec p v s‖ = n := norm_sqrtVelVec_eq_sqrt p v s
  -- the Fisher–Rao speed is bounded by `2 (n + e)` on `[s,t]`
  have hspeed : ∀ r ∈ Set.Icc s t, fisherRaoSpeed (p r) (v r) ≤ 2 * (n + e) := by
    intro r hr
    have h1 : ‖sqrtVelVec p v r‖ ≤ n + e := by
      have h2 : ‖sqrtVelVec p v r‖ ≤ ‖sqrtVelVec p v s‖ + ‖sqrtVelVec p v r - sqrtVelVec p v s‖ := by
        simpa using norm_le_norm_add_norm_sub' (sqrtVelVec p v r) (sqrtVelVec p v s)
      have h3 := hunif r hr
      rw [hnorm] at h2
      linarith
    rw [norm_sqrtVelVec hpos r] at h1
    linarith
  have hL : fisherRaoLength p v s t ≤ 2 * (n + e) * (t - s) :=
    fisherRaoLength_le_of_speed_le hderiv hv hpos hst hspeed
  -- the chord dominates `(n - e)(t - s)`
  have hchord : (n - e) * (t - s) ≤ √(∑ i, (√(p t i) - √(p s i)) ^ 2) := by
    rcases eq_or_lt_of_le hn0 with hn0' | hnpos
    · have : (n - e) * (t - s) ≤ 0 := by
        apply mul_nonpos_of_nonpos_of_nonneg <;> [linarith; linarith]
      exact this.trans (Real.sqrt_nonneg _)
    -- the unit test vector in the direction of the initial velocity
    set u : ι → ℝ := fun i => W s i / n with hu
    have husq : ∑ i, (u i) ^ 2 = 1 := by
      have : ∑ i, (u i) ^ 2 = (∑ i, (W s i) ^ 2) / n ^ 2 := by
        rw [Finset.sum_div]
        exact Finset.sum_congr rfl fun i _ => by rw [hu]; field_simp
      rw [this, ← hnsq]
      field_simp
    -- Cauchy–Schwarz against the unit vector `u`
    have hCSgen : ∀ d : ι → ℝ, ∑ i, u i * d i ≤ √(∑ i, (d i) ^ 2) := by
      intro d
      have hCS := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ u d
      rw [husq, one_mul] at hCS
      calc ∑ i, u i * d i ≤ |∑ i, u i * d i| := le_abs_self _
        _ = √((∑ i, u i * d i) ^ 2) := (Real.sqrt_sq_eq_abs _).symm
        _ ≤ √(∑ i, (d i) ^ 2) := Real.sqrt_le_sqrt hCS
    -- the scalar test function and its derivative
    have hsqrtDeriv : ∀ r i, HasDerivAt (fun x => √(p x i)) (W r i) r :=
      fun r i => hasDerivAt_sqrt_coord (hderiv r i) (hpos r i)
    have hg : ∀ r : ℝ, HasDerivAt (fun x => ∑ i, u i * √(p x i)) (∑ i, u i * W r i) r :=
      fun r => HasDerivAt.fun_sum fun i _ => (hsqrtDeriv r i).const_mul (u i)
    have hgcont : Continuous fun r => ∑ i, u i * W r i :=
      continuous_finset_sum _ fun i _ =>
        continuous_const.mul (continuous_sqrtVel hderiv hv hpos i)
    have hFTC : (∫ r in s..t, ∑ i, u i * W r i)
        = (∑ i, u i * √(p t i)) - ∑ i, u i * √(p s i) :=
      integral_eq_sub_of_hasDerivAt (fun r _ => hg r) (hgcont.intervalIntegrable s t)
    -- pointwise lower bound for the integrand
    have hpt : ∀ r ∈ Set.Icc s t, n - e ≤ ∑ i, u i * W r i := by
      intro r hr
      have hsplit : ∑ i, u i * W r i
          = (∑ i, u i * W s i) + ∑ i, u i * (W r i - W s i) := by
        rw [← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun i _ => by ring
      have hfirst : ∑ i, u i * W s i = n := by
        have : ∑ i, u i * W s i = (∑ i, (W s i) ^ 2) / n := by
          rw [Finset.sum_div]
          exact Finset.sum_congr rfl fun i _ => by rw [hu]; ring
        rw [this, ← hnsq]
        field_simp
      have hsecond : -e ≤ ∑ i, u i * (W r i - W s i) := by
        have hbd := hCSgen (fun i => W s i - W r i)
        have heq : √(∑ i, (W s i - W r i) ^ 2) ≤ e := by
          have h1 : ‖sqrtVelVec p v r - sqrtVelVec p v s‖
              = √(∑ i, (W r i - W s i) ^ 2) := norm_sqrtVelVec_sub r s
          have h2 : ∑ i, (W s i - W r i) ^ 2 = ∑ i, (W r i - W s i) ^ 2 :=
            Finset.sum_congr rfl fun i _ => by ring
          rw [h2, ← h1]
          exact hunif r hr
        have h3 : ∑ i, u i * (W s i - W r i) ≤ e := le_trans hbd heq
        have h4 : ∑ i, u i * (W s i - W r i) = -∑ i, u i * (W r i - W s i) := by
          rw [← Finset.sum_neg_distrib]
          exact Finset.sum_congr rfl fun i _ => by ring
        rw [h4] at h3
        linarith
      rw [hsplit, hfirst]
      linarith
    have hconst : IntervalIntegrable (fun _ : ℝ => n - e) volume s t :=
      _root_.intervalIntegrable_const
    have hint : (n - e) * (t - s) ≤ ∫ r in s..t, ∑ i, u i * W r i := by
      have h := intervalIntegral.integral_mono_on hst hconst (hgcont.intervalIntegrable s t) hpt
      rw [intervalIntegral.integral_const, smul_eq_mul, mul_comm (t - s) (n - e)] at h
      exact h
    -- Cauchy–Schwarz turns the increment of the test function into the chord
    have hdiff : (∑ i, u i * √(p t i)) - (∑ i, u i * √(p s i))
        ≤ √(∑ i, (√(p t i) - √(p s i)) ^ 2) := by
      have := hCSgen (fun i => √(p t i) - √(p s i))
      calc (∑ i, u i * √(p t i)) - (∑ i, u i * √(p s i))
          = ∑ i, u i * (√(p t i) - √(p s i)) := by
            rw [← Finset.sum_sub_distrib]
            exact Finset.sum_congr rfl fun i _ => by ring
        _ ≤ √(∑ i, (√(p t i) - √(p s i)) ^ 2) := this
    rw [hFTC] at hint
    linarith
  have hts : 0 ≤ t - s := by linarith
  nlinarith [hchord, hL, hts]

/-- **Reverse partition bound.**  For a partition whose steps are fine enough
that the square-root velocity varies by at most `e` on each of them, the
Bhattacharyya angle sum is within `4 e (b − a)` of the Fisher–Rao length. -/
theorem fisherRaoLength_le_sum_two_arccos_add {p v : ℝ → ι → ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    (hp1 : ∀ t, ∑ i, p t i = 1) (T : ℕ → ℝ) (N : ℕ) (hmono : ∀ k < N, T k ≤ T (k + 1))
    {e : ℝ} (he : 0 ≤ e)
    (hunif : ∀ k < N, ∀ r ∈ Set.Icc (T k) (T (k + 1)),
      ‖sqrtVelVec p v r - sqrtVelVec p v (T k)‖ ≤ e) :
    fisherRaoLength p v (T 0) (T N)
      ≤ (∑ k ∈ Finset.range N, 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1)))))
        + 4 * e * (T N - T 0) := by
  have hstep : ∀ k ∈ Finset.range N, fisherRaoLength p v (T k) (T (k + 1))
      ≤ 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) + 4 * e * (T (k + 1) - T k) := by
    intro k hk
    have hk' := Finset.mem_range.mp hk
    have hmk := hmono k hk'
    have hchord := chord_ge_half_fisherRaoLength_sub hderiv hv hpos hmk he (hunif k hk')
    have hangle : √(∑ i, (√(p (T (k + 1)) i) - √(p (T k) i)) ^ 2)
        ≤ arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) := by
      have h := chord_le_arccos_bhattacharyya (p (T (k + 1))) (p (T k))
        (fun i => (hpos _ i).le) (fun i => (hpos _ i).le) (hp1 _) (hp1 _)
      rwa [bhattacharyya_comm] at h
    linarith
  calc fisherRaoLength p v (T 0) (T N)
      = ∑ k ∈ Finset.range N, fisherRaoLength p v (T k) (T (k + 1)) :=
        (fisherRaoLength_sum_partition hderiv hv hpos T N).symm
    _ ≤ ∑ k ∈ Finset.range N,
          (2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1)))) + 4 * e * (T (k + 1) - T k)) :=
        Finset.sum_le_sum hstep
    _ = (∑ k ∈ Finset.range N, 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1)))))
          + 4 * e * (T N - T 0) := by
        rw [Finset.sum_add_distrib]
        congr 1
        rw [← Finset.mul_sum, Finset.sum_range_sub]

/-! ## The calibration theorem -/

/-- **Riemann convergence of the Bhattacharyya angle sums.**  For a `C¹` curve
of strictly positive probability vectors on `[a,b]`, the sums
`∑ₖ 2 arccos BC(p_{t_k}, p_{t_{k+1}})` converge to `fisherRaoLength p v a b` as
the mesh of the partition tends to `0`.  Hence the Fisher–Rao length functional
*is* the length structure induced by the Bhattacharyya angle metric. -/
theorem riemann_convergence_sum_two_arccos_bhattacharyya {p v : ℝ → ι → ℝ} {a b : ℝ}
    (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    (hp1 : ∀ t, ∑ i, p t i = 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ δ > 0, ∀ (N : ℕ) (T : ℕ → ℝ), T 0 = a → T N = b → (∀ k < N, T k ≤ T (k + 1)) →
      (∀ k < N, T (k + 1) - T k < δ) →
      |(∑ k ∈ Finset.range N, 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1)))))
        - fisherRaoLength p v a b| ≤ ε := by
  have hba : 0 ≤ b - a := by linarith
  have hden : (0:ℝ) < 4 * (b - a) + 1 := by linarith
  set e : ℝ := ε / (4 * (b - a) + 1) with hedef
  have he0 : 0 < e := div_pos hε hden
  -- uniform continuity of the square-root velocity on the compact interval
  have hunifc : UniformContinuousOn (sqrtVelVec p v) (Set.Icc a b) :=
    isCompact_Icc.uniformContinuousOn_of_continuous
      (continuous_sqrtVelVec hderiv hv hpos).continuousOn
  obtain ⟨δ, hδ0, hδ⟩ := Metric.uniformContinuousOn_iff.mp hunifc e he0
  refine ⟨δ, hδ0, ?_⟩
  intro N T hT0 hTN hmono hmesh
  -- the partition is increasing, hence contained in `[a,b]`
  have hchain : ∀ k, k ≤ N → ∀ j, j ≤ k → T j ≤ T k := by
    intro k
    induction k with
    | zero => intro _ j hj; rw [Nat.le_zero.mp hj]
    | succ n ih =>
        intro hn j hj
        rcases eq_or_lt_of_le hj with rfl | hlt
        · exact le_rfl
        · exact le_trans (ih (Nat.le_of_succ_le hn) j (Nat.lt_succ_iff.mp hlt))
            (hmono n (Nat.lt_of_succ_le hn))
  have hmem : ∀ k, k ≤ N → T k ∈ Set.Icc a b := by
    intro k hk
    refine ⟨?_, ?_⟩
    · rw [← hT0]; exact hchain k hk 0 (Nat.zero_le k)
    · rw [← hTN]; exact hchain N le_rfl k hk
  -- the upper bound holds for every partition
  have hupper : (∑ k ∈ Finset.range N, 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1)))))
      ≤ fisherRaoLength p v a b := by
    have h := sum_two_arccos_bhattacharyya_le_fisherRaoLength hderiv hv hpos hp1 T N hmono
    rwa [hT0, hTN] at h
  -- fineness gives the reverse bound
  have hunif : ∀ k < N, ∀ r ∈ Set.Icc (T k) (T (k + 1)),
      ‖sqrtVelVec p v r - sqrtVelVec p v (T k)‖ ≤ e := by
    intro k hk r hr
    have hkmem : T k ∈ Set.Icc a b := hmem k hk.le
    have hrmem : r ∈ Set.Icc a b :=
      ⟨le_trans hkmem.1 hr.1, le_trans hr.2 (hmem (k + 1) hk).2⟩
    have hdist : dist r (T k) < δ := by
      rw [Real.dist_eq, abs_of_nonneg (by linarith [hr.1])]
      linarith [hmesh k hk, hr.2]
    have hlt := hδ r hrmem (T k) hkmem hdist
    rw [dist_eq_norm] at hlt
    exact hlt.le
  have hlower := fisherRaoLength_le_sum_two_arccos_add hderiv hv hpos hp1 T N hmono he0.le hunif
  rw [hT0, hTN] at hlower
  -- the error term is at most `ε`
  have h4e : 4 * e * (b - a) ≤ ε := by
    rw [hedef,
      show 4 * (ε / (4 * (b - a) + 1)) * (b - a) = ε * (4 * (b - a)) / (4 * (b - a) + 1) by
        field_simp,
      div_le_iff₀ hden]
    nlinarith [hε.le, hba]
  rw [abs_le]
  constructor <;> linarith

/-! ## The Fisher–Rao length is the induced length of the Bhattacharyya metric -/

/-- The set of Bhattacharyya angle sums of increasing partitions of `[a,b]`, i.e. the
approximating lengths of the curve `p` in the Bhattacharyya angle metric. -/
def partitionAngleSums (p : ℝ → ι → ℝ) (a b : ℝ) : Set ℝ :=
  {S | ∃ (N : ℕ) (T : ℕ → ℝ), T 0 = a ∧ T N = b ∧ (∀ k < N, T k ≤ T (k + 1)) ∧
    S = ∑ k ∈ Finset.range N, 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1))))}

/-- **The Fisher–Rao length is an induced length.**  The Fisher–Rao length of a
`C¹` curve of strictly positive probability vectors is the least upper bound of
its Bhattacharyya angle sums, exactly as in the definition of the length of a
curve in a metric space.  No renormalisation of `fisherRaoLength` is required:
the normalisation `2 arccos BC` is the correct one. -/
theorem fisherRaoLength_isLUB_partitionAngleSums {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i)
    (hp1 : ∀ t, ∑ i, p t i = 1) :
    IsLUB (partitionAngleSums p a b) (fisherRaoLength p v a b) := by
  constructor
  · rintro S ⟨N, T, hT0, hTN, hmono, rfl⟩
    have h := sum_two_arccos_bhattacharyya_le_fisherRaoLength hderiv hv hpos hp1 T N hmono
    rwa [hT0, hTN] at h
  · intro c hc
    by_contra hlt
    push_neg at hlt
    have hεpos : 0 < (fisherRaoLength p v a b - c) / 2 := by linarith
    obtain ⟨δ, hδ0, hconv⟩ :=
      riemann_convergence_sum_two_arccos_bhattacharyya hab hderiv hv hpos hp1 hεpos
    obtain ⟨N, hN⟩ := exists_nat_gt (max ((b - a) / δ) 1)
    have hN1 : (1:ℝ) < N := lt_of_le_of_lt (le_max_right _ _) hN
    have hNpos : (0:ℝ) < N := by linarith
    set h : ℝ := (b - a) / N with hhdef
    have hh0 : 0 ≤ h := div_nonneg (by linarith) hNpos.le
    have hmesh : h < δ := by
      have hlt' := lt_of_le_of_lt (le_max_left ((b - a) / δ) 1) hN
      rw [div_lt_iff₀ hδ0] at hlt'
      rw [hhdef, div_lt_iff₀ hNpos]
      linarith
    have hNh : (N : ℝ) * h = b - a := by rw [hhdef]; field_simp
    set T : ℕ → ℝ := fun k => a + k * h with hTdef
    have hT0 : T 0 = a := by simp [hTdef]
    have hTN : T N = b := by simp only [hTdef]; linarith
    have hstep : ∀ k : ℕ, T (k + 1) - T k = h := by
      intro k
      simp only [hTdef]
      push_cast
      ring
    have hmonoT : ∀ k, k < N → T k ≤ T (k + 1) := fun k _ => by linarith [hstep k]
    have hmemS : (∑ k ∈ Finset.range N, 2 * arccos (bhattacharyya (p (T k)) (p (T (k + 1)))))
        ∈ partitionAngleSums p a b := ⟨N, T, hT0, hTN, hmonoT, rfl⟩
    have hSle := hc hmemS
    have habs := hconv N T hT0 hTN hmonoT fun k _ => by rw [hstep k]; exact hmesh
    have := (abs_le.mp habs).1
    linarith

end FisherRao