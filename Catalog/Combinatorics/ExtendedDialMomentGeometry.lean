/-
# Moment geometry of the increment: what `ΔR²` is a function of, and what it is blind to

Third cycle of the `EXTENDED-DIAL-ABSENT` investigation, after
`Combinatorics.ExtendedDialNonReplication` (raw gain, non-replication pair) and
`Combinatorics.ExtendedDialPartialGain` (partialled gain, exact identity, codimension count).

Cycle two showed that `ΔR²` is a knife-edge functional of the rate profile.  This cycle
identifies exactly which population data it depends on, and uses that to explain the
experimental pattern: five fresh populations reproduce every *marginal* reading of the
augmented model and still report `ΔR²(pp) ≈ 0`.

Main results.

* `partial_cov_formula` — the partial covariance in closed moment form:
  `⟨r, z⟩ = σ_zy − σ_xy·σ_xz / σ_xx`.
* `partial_var_formula` — `‖z̃‖² = σ_zz − σ_xz² / σ_xx`.
* `pgain_moment_formula` — hence `ΔR²·σ_yy = (σ_zy − σ_xy σ_xz/σ_xx)² / (σ_zz − σ_xz²/σ_xx)`:
  the increment is a *rational function of five second moments and nothing else*.
* `increment_determined_by_moments` — consequently two populations, on entirely different
  key sets and under different draw regimes, that agree on those five moments report the
  same increment.  Non-replication is therefore always attributable to a second-moment
  difference; no higher-order or seed-specific effect can be responsible.
* `increment_zero_iff_moment_identity` — the increment vanishes **exactly** on the quadric
  `σ_zy·σ_xx = σ_xy·σ_xz`, and this is a nontrivial algebraic condition.
* `sign_masking_nonreplication` — the flagship construction: two four-key populations that
  agree on the footprint dial reading `R²(w, y) = 5/149`, on the prime-power marginal dial
  reading `R²(pp, y) = 4/149`, on the footprint–feature collinearity `σ_xz`, and on the rate
  variance — differing *only in the sign* of `σ_zy` — yet report `ΔR²(pp) = 80/149 ≈ 0.537`
  and `ΔR²(pp) = 0`.  **Every marginal diagnostic the experiment reports is identical; the
  increment is not.**  Suppression, not noise, is the mechanism of non-replication.
-/
import Combinatorics.ExtendedDialPartialGain

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

variable {ι : Type*} [Fintype ι]

/-! ## 1. Closed moment forms -/

lemma wip_eq_wcov_of_centred {p r z : ι → ℝ} (h1 : ∑ i, p i * r i = 0) :
    wip p r z = wcov p r z := by
  have hm : wmean p r = 0 := h1
  simp only [wip, wcov, hm]
  have hz : ∑ i, p i * (r i - 0) * (z i - wmean p z)
      = (∑ i, p i * r i * z i) - wmean p z * (∑ i, p i * r i) := by
    rw [show ((∑ i, p i * r i * z i) - wmean p z * ∑ i, p i * r i)
        = ∑ i, (p i * r i * z i - wmean p z * (p i * r i)) by
      rw [Finset.sum_sub_distrib, ← Finset.mul_sum]]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hz, h1]; ring

/-- **Partial covariance in closed moment form.**  The numerator of the increment is the
covariance of feature and rate, *corrected* by the part of that covariance the footprint
already accounts for. -/
theorem partial_cov_formula {p x y r z : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (hvx : 0 < wvar p x) :
    wip p r z = wcov p z y - wcov p x y * wcov p x z / wvar p x := by
  have hb : wcov p x y = b * wvar p x := wcov_x_rate hp hy hr
  have hyeq : y = fun i => (a + b * x i) + r i := funext fun i => hy i
  have hzy : wcov p z y = b * wcov p x z + wcov p r z := by
    have h1 : wcov p y z = b * wcov p x z + wcov p r z := by
      rw [hyeq, wcov_add_left, wcov_affine_left hp a b x z]
    rw [wcov_comm p z y, h1]
  rw [wip_eq_wcov_of_centred hr.1, hzy, hb]
  field_simp
  ring

/-- **Partialled energy in closed moment form.** -/
theorem partial_var_formula {p x z zt : ι → ℝ} (hp : ∑ i, p i = 1) (h : IsPartial p x z zt) :
    wip p zt zt = wvar p z - (wcov p x z) ^ 2 / wvar p x := by
  obtain ⟨hres, a, b, hdec⟩ := h
  have hzeq : z = fun i => (a + b * x i) + zt i := funext fun i => hdec i
  have hxzt : wcov p x zt = 0 := wcov_x_resid_zero hp hres
  have hxz : wcov p x z = b * wvar p x := by
    rw [hzeq, wcov_comm, wcov_add_left, wcov_comm, wcov_affine hp, wcov_comm, hxzt, add_zero]
  have hvz : wvar p z = b ^ 2 * wvar p x + wip p zt zt := by
    rw [hzeq, wvar_add, wvar_affine hp, wcov_affine_left hp a b x zt, hxzt,
      wvar_eq_wip_of_centred hres.1]
    ring
  rw [hvz, hxz]
  field_simp
  ring

/-- **The increment is a rational function of five second moments.** -/
theorem pgain_moment_formula {p x y r z zt : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (h : IsPartial p x z zt)
    (hvx : 0 < wvar p x) :
    pgain p r zt
      = (wcov p z y - wcov p x y * wcov p x z / wvar p x) ^ 2
        / (wvar p z - (wcov p x z) ^ 2 / wvar p x) := by
  rw [pgain, partial_var_formula hp h, ← partial_duality hr h,
    partial_cov_formula hp hy hr hvx]

/-- **Moment sufficiency.**  Two populations — different key sets, different draw regimes —
that agree on the five second moments `σ_xx, σ_xy, σ_xz, σ_zy, σ_zz` report the *same*
increment.  Whatever makes `ΔR²` fail to replicate must therefore be visible in the second
moments of the fresh population; nothing seed-specific or higher-order can be responsible. -/
theorem increment_determined_by_moments {κ : Type*} [Fintype κ]
    {p x y r z zt : ι → ℝ} {a b : ℝ} {q x' y' r' z' zt' : κ → ℝ} {a' b' : ℝ}
    (hp : ∑ i, p i = 1) (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r)
    (h : IsPartial p x z zt) (hvx : 0 < wvar p x)
    (hq : ∑ i, q i = 1) (hy' : ∀ i, y' i = a' + b' * x' i + r' i) (hr' : IsResidual q x' r')
    (h' : IsPartial q x' z' zt') (hvx' : 0 < wvar q x')
    (m1 : wvar p x = wvar q x') (m2 : wcov p x y = wcov q x' y')
    (m3 : wcov p x z = wcov q x' z') (m4 : wcov p z y = wcov q z' y')
    (m5 : wvar p z = wvar q z') :
    pgain p r zt = pgain q r' zt' := by
  rw [pgain_moment_formula hp hy hr h hvx, pgain_moment_formula hq hy' hr' h' hvx',
    m1, m2, m3, m4, m5]

/-- **The absence locus is a quadric.**  The increment vanishes exactly when the feature's
covariance with the rate is *entirely* accounted for by the footprint. -/
theorem increment_zero_iff_moment_identity {p x y r z zt : ι → ℝ} {a b : ℝ}
    (hp : ∑ i, p i = 1) (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r)
    (h : IsPartial p x z zt) (hvx : 0 < wvar p x) (hzt : 0 < wip p zt zt) :
    pgain p r zt = 0 ↔ wcov p z y * wvar p x = wcov p x y * wcov p x z := by
  rw [pgain, div_eq_zero_iff]
  constructor
  · rintro (hc | hc)
    · have h0 : wip p r zt = 0 := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hc
      rw [← partial_duality hr h, partial_cov_formula hp hy hr hvx] at h0
      field_simp at h0
      linarith
    · exact absurd hc hzt.ne'
  · intro hm
    left
    have h0 : wip p r zt = 0 := by
      rw [← partial_duality hr h, partial_cov_formula hp hy hr hvx]
      field_simp
      linarith
    rw [h0]; ring

/-! ## 2. Suppression: identical marginal dials, opposite increments

Four keys, uniform regime, the same footprint `foot` and prime-power feature `pp` as in the
previous cycles (so the partialled feature is again `ztA`).  Two rate profiles are built with
*identical* moments except for the sign of `σ_zy`. -/

/-- Rate profile of the suppressed population: the prime-power covariance is exactly what the
footprint already predicts. -/
noncomputable def rateSB : Fin 4 → ℝ := ![7/10, -2/5, -3/10, 1]

/-- Rate profile of the active population: the same moments with `σ_zy` sign-flipped. -/
noncomputable def rateSC : Fin 4 → ℝ := ![3/10, 2/5, -7/10, 1]

/-- Least-squares residual of `rateSB` on `foot`. -/
noncomputable def residSB : Fin 4 → ℝ := ![3/5, -3/5, -3/5, 3/5]

/-- Least-squares residual of `rateSC` on `foot`. -/
noncomputable def residSC : Fin 4 → ℝ := ![1/5, 1/5, -1, 3/5]

lemma rateSB_decomp (i : Fin 4) : rateSB i = 0 + (1/10) * foot i + residSB i := by
  fin_cases i <;> norm_num [rateSB, foot, residSB]

lemma rateSC_decomp (i : Fin 4) : rateSC i = 0 + (1/10) * foot i + residSC i := by
  fin_cases i <;> norm_num [rateSC, foot, residSC]

lemma residSB_isResidual : IsResidual pU foot residSB := by
  refine ⟨?_, ?_⟩ <;>
    norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
      Matrix.head_cons, Matrix.tail_cons, pU, foot, residSB]

lemma residSC_isResidual : IsResidual pU foot residSC := by
  refine ⟨?_, ?_⟩ <;>
    norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
      Matrix.head_cons, Matrix.tail_cons, pU, foot, residSC]

/-- Both fits are genuine least-squares optima. -/
theorem rateSB_fit_optimal (a' b' : ℝ) :
    mse pU foot rateSB 0 (1/10) ≤ mse pU foot rateSB a' b' :=
  mse_ge_of_isResidual pU_nonneg rateSB_decomp residSB_isResidual a' b'

theorem rateSC_fit_optimal (a' b' : ℝ) :
    mse pU foot rateSC 0 (1/10) ≤ mse pU foot rateSC a' b' :=
  mse_ge_of_isResidual pU_nonneg rateSC_decomp residSC_isResidual a' b'

/-- The two populations agree on the footprint dial reading. -/
theorem base_dials_agree : R2 pU foot rateSB = 5/149 ∧ R2 pU foot rateSC = 5/149 := by
  constructor <;>
    norm_num [R2, wcov, wvar, wmean, Fin.sum_univ_four, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.head_cons, Matrix.tail_cons, pU, foot, rateSB, rateSC]

/-- They also agree on the *marginal* prime-power dial reading. -/
theorem marginal_pp_dials_agree : R2 pU pp rateSB = 4/149 ∧ R2 pU pp rateSC = 4/149 := by
  constructor <;>
    norm_num [R2, wcov, wvar, wmean, Fin.sum_univ_four, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.head_cons, Matrix.tail_cons, pU, pp, rateSB, rateSC]

/-- And on the rate variance — but the prime-power covariance has opposite signs. -/
theorem moments_agree_except_sign :
    wvar pU rateSB = 149/400 ∧ wvar pU rateSC = 149/400 ∧
    wcov pU pp rateSB = -1/20 ∧ wcov pU pp rateSC = 1/20 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    norm_num [wcov, wvar, wmean, Fin.sum_univ_four, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.head_cons, Matrix.tail_cons, pU, pp, rateSB, rateSC]

theorem pgain_SB : pgain pU residSB ztA = 0 := by
  norm_num [pgain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, residSB, ztA]

theorem pgain_SC : pgain pU residSC ztA = 1/5 := by
  norm_num [pgain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, residSC, ztA]

/-- **Suppression, not noise.**  Two four-key populations that agree on *every* marginal
reading the experiment records — the footprint dial `R²(w, y) = 5/149`, the prime-power
marginal dial `R²(pp, y) = 4/149`, the footprint–feature collinearity, and the rate variance
— and differ only in the sign of the prime-power/rate covariance.  Their augmented dials are
`ΔR²(pp) = 80/149 ≈ 0.537` and `ΔR²(pp) = 0`.  No marginal diagnostic can distinguish the
population where the prime-power feature contributes half the variance from the population
where it contributes nothing: reporting a stable base dial is no evidence at all for a
replicable increment. -/
theorem sign_masking_nonreplication :
    R2 pU foot rateSB = R2 pU foot rateSC ∧
    R2 pU pp rateSB = R2 pU pp rateSC ∧
    wvar pU rateSB = wvar pU rateSC ∧
    wcov pU pp rateSB = -wcov pU pp rateSC ∧
    pgain pU residSC ztA / wvar pU rateSC = 80/149 ∧
    pgain pU residSB ztA / wvar pU rateSB = 0 := by
  obtain ⟨hb, hc⟩ := base_dials_agree
  obtain ⟨hpb, hpc⟩ := marginal_pp_dials_agree
  obtain ⟨hvb, hvc, hcb, hcc⟩ := moments_agree_except_sign
  refine ⟨by rw [hb, hc], by rw [hpb, hpc], by rw [hvb, hvc], by rw [hcb, hcc]; norm_num, ?_, ?_⟩
  · rw [pgain_SC, hvc]; norm_num
  · rw [pgain_SB, hvb]; norm_num

/-- The suppressed population sits exactly on the absence quadric
`σ_zy · σ_xx = σ_xy · σ_xz`, while the active one does not. -/
theorem suppression_quadric :
    wcov pU pp rateSB * wvar pU foot = wcov pU foot rateSB * wcov pU foot pp ∧
    wcov pU pp rateSC * wvar pU foot ≠ wcov pU foot rateSC * wcov pU foot pp := by
  constructor <;>
    norm_num [wcov, wvar, wmean, Fin.sum_univ_four, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.head_cons, Matrix.tail_cons, pU, foot, pp, rateSB, rateSC]


/-! ## 3. A hard ceiling for sparse indicator features

The prime-power indicator is a *sparse* 0/1 feature: on the key range `{1, …, N}` the prime
powers thin out.  The following bound says that a sparse indicator can never buy much: its
augmentation gain is at most `(sup‖residual‖)² × (density)`.  This is a mechanism for
`ΔR²(pp) ≈ 0` that needs no cancellation and no coincidence — only sparsity. -/

/-- **Sparse-feature ceiling.**  For a `0/1` feature of draw-regime density `δ` and a
residual bounded by `B` in supremum norm, the augmentation gain is at most `B² · δ`. -/
theorem gain_le_sup_sq_density {p r z : ι → ℝ} {B : ℝ} (hp0 : ∀ i, 0 ≤ p i)
    (hz01 : ∀ i, z i = 0 ∨ z i = 1) (hB : ∀ i, |r i| ≤ B) (hd : 0 < ∑ i, p i * z i) :
    gain p r z ≤ B ^ 2 * (∑ i, p i * z i) := by
  set d := ∑ i, p i * z i with hddef
  have hzz : wip p z z = d := by
    simp only [wip, hddef]
    exact Finset.sum_congr rfl fun i _ => by rcases hz01 i with h | h <;> rw [h] <;> ring
  have hB0 : 0 ≤ B := by
    by_contra hc
    push_neg at hc
    have : ∀ i, p i * z i ≤ 0 := by
      intro i
      have := (hB i).trans hc.le
      have habs : |r i| < 0 := lt_of_le_of_lt (hB i) hc
      exact absurd habs (not_lt.mpr (abs_nonneg _))
    exact absurd hd (not_lt.mpr (Finset.sum_nonpos fun i _ => this i))
  have hnum : |wip p r z| ≤ B * d := by
    have hstep : |wip p r z| ≤ ∑ i, p i * B * z i := by
      refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun i _ => ?_)
      rcases hz01 i with h | h
      · rw [h]; simp
      · rw [h]
        have := hB i
        rw [abs_mul, abs_mul, abs_of_nonneg (hp0 i)]
        simp only [mul_one, abs_one]
        nlinarith [hp0 i, abs_nonneg (r i)]
    have hsum : ∑ i, p i * B * z i = B * d := by
      rw [hddef, Finset.mul_sum]
      exact Finset.sum_congr rfl fun i _ => by ring
    rwa [hsum] at hstep
  have hsq : (wip p r z) ^ 2 ≤ (B * d) ^ 2 := by
    have hpw := pow_le_pow_left₀ (abs_nonneg (wip p r z)) hnum 2
    rwa [sq_abs] at hpw
  rw [gain, hzz, div_le_iff₀ hd]
  nlinarith [hsq, hd.le]

/-- **Vanishing density forces a vanishing dial.**  Fix a bound `B` on the residual.  Any
`0/1` feature whose density is below `ε / B²` contributes less than `ε` of raw gain — no
matter how it is correlated with the rate.  A feature supported on a set of vanishing
density (prime powers among the first `N` keys, for instance) therefore has an increment
tending to zero, uniformly over bounded residuals. -/
theorem gain_lt_of_density_small {p r z : ι → ℝ} {B eps : ℝ} (hp0 : ∀ i, 0 ≤ p i)
    (hz01 : ∀ i, z i = 0 ∨ z i = 1) (hB : ∀ i, |r i| ≤ B) (hBpos : 0 < B)
    (hd : 0 < ∑ i, p i * z i) (hsmall : ∑ i, p i * z i < eps / B ^ 2) :
    gain p r z < eps := by
  have hceil := gain_le_sup_sq_density hp0 hz01 hB hd
  have hB2 : 0 < B ^ 2 := by positivity
  have hmul : B ^ 2 * (∑ i, p i * z i) < B ^ 2 * (eps / B ^ 2) :=
    mul_lt_mul_of_pos_left hsmall hB2
  have heq : B ^ 2 * (eps / B ^ 2) = eps := by field_simp
  linarith [hceil, hmul, heq.le, heq.ge]

end ExtendedDial

end Catalog.UniformDial