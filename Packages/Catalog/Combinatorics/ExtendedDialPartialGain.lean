/-
# The partialled prime-power dial: duality, the exact `ΔR²` identity, and a codimension count

Second cycle of the `EXTENDED-DIAL-ABSENT` investigation, building on
`Combinatorics.ExtendedDialNonReplication`.

The first cycle measured the augmentation gain of a *raw* extra feature `z` against the
current residual.  The statistic the experiment actually reports is the increment of the
*multiple* `R²`, i.e. the gain of the **partialled** feature `z̃` — what is left of `z`
after the footprint model has had its say.  This file develops that statistic and shows
that every conclusion of the first cycle survives — indeed sharpens — when the honest
partialled quantity is used.

Main results.

* `wip_pythagoras` — the weighted Pythagoras identity for the split `z = (a + b·x) + z̃`.
* `partial_duality` — **partialling is symmetric**: `⟨r_y, z⟩ = ⟨r_y, z̃⟩ = ⟨y, z̃⟩`.  The
  partial covariance can be read off either by residualising the rate or by residualising
  the feature; this is the structural fact behind everything below.
* `pgain_ge_gain` — the partialled gain dominates the raw augmentation gain, so the
  first-cycle numbers are valid lower bounds for the honest statistic.
* `pgain_eq_zero_iff_gain_eq_zero` — but the two vanish *together*: "absent" is unambiguous.
* `one_sub_R2_eq_residual_share`, `partial_gain_identity` — the classical exact identity
  `ΔR² = (1 − R²_base) · ρ_partial²`, proved here in the weighted finite-population setting.
  Consequently `ΔR²` is a product of a base-fit factor and a partial-correlation factor,
  and *either* factor can differ between populations: two mechanisms for non-replication.
* `extended_dial_nonreplication_partial` — the first-cycle non-replication pair, restated
  for the honest partialled statistic: `ΔR²(pp) = 20/49 > 0.4` on population `A` and
  exactly `0` on population `B`, with identical base `R² = 5/9`.
* `pp_partial_incremental_absent` — likewise for the marginal-present/incremental-absent
  population: the prime-power feature is comonotone with the rate (hence its marginal dial
  is positive in *every* draw regime) but its partialled increment is exactly `0`.
* `wip_stability_tv`, `gain_le_of_nearby_zero_regime` — **regime drift cannot explain the
  absence**: if the partial covariance vanishes at one regime, the gain at any ℓ¹-nearby
  regime is at most quadratically small in the regime distance.  Non-replication across
  populations is therefore not a re-weighting artefact.
* `zero_gain_locus_codim_one` — the set of rate profiles on which a nondegenerate feature
  has zero increment is the kernel of a surjective linear functional, i.e. a hyperplane of
  codimension exactly one in the `#keys`-dimensional profile space.  Zero increment is a
  codimension-one coincidence for one population; observing it repeatedly is evidence of
  structure, not of chance.
-/
import Combinatorics.ExtendedDialNonReplication

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

variable {ι : Type*} [Fintype ι]

/-! ## 1. Partialling out the footprint -/

/-- `zt` is the *partialled* form of the feature `z` relative to the footprint `x` under the
draw regime `p`: `z` splits as an affine function of the footprint plus a part `zt` that the
footprint model cannot express. -/
def IsPartial (p x z zt : ι → ℝ) : Prop :=
  IsResidual p x zt ∧ ∃ a b : ℝ, ∀ i, z i = a + b * x i + zt i

lemma wcov_affine_left {p : ι → ℝ} (hp : ∑ i, p i = 1) (a b : ℝ) (x r : ι → ℝ) :
    wcov p (fun i => a + b * x i) r = b * wcov p x r := by
  simp only [wcov, wmean_affine hp]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by simp only [wmean]; ring

/-- **Weighted Pythagoras.**  The explainable part and the partialled part of a feature are
orthogonal, so the partialled part never carries more energy than the feature itself. -/
theorem wip_partial_le {p x z zt : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (h : IsPartial p x z zt) :
    wip p zt zt ≤ wip p z z := by
  obtain ⟨⟨h1, h2⟩, a, b, hdec⟩ := h
  have hcross : wip p (fun i => a + b * x i) zt = 0 := by
    have hsplit : wip p (fun i => a + b * x i) zt
        = a * (∑ i, p i * zt i) + b * wip p zt x := by
      simp only [wip]
      rw [show (a * ∑ i, p i * zt i + b * ∑ i, p i * zt i * x i)
          = ∑ i, (a * (p i * zt i) + b * (p i * zt i * x i)) by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]]
      exact Finset.sum_congr rfl fun i _ => by ring
    rw [hsplit, h1, h2]; ring
  have expand : wip p z z
      = wip p (fun i => a + b * x i) (fun i => a + b * x i)
        + 2 * wip p (fun i => a + b * x i) zt + wip p zt zt := by
    simp only [wip]
    rw [show (∑ i, p i * (a + b * x i) * (a + b * x i)
        + 2 * ∑ i, p i * (a + b * x i) * zt i + ∑ i, p i * zt i * zt i)
        = ∑ i, (p i * (a + b * x i) * (a + b * x i)
          + 2 * (p i * (a + b * x i) * zt i) + p i * zt i * zt i) by
      rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum]]
    exact Finset.sum_congr rfl fun i _ => by rw [hdec i]; ring
  have hnn : 0 ≤ wip p (fun i => a + b * x i) (fun i => a + b * x i) :=
    wip_self_nonneg hp0 _
  rw [expand, hcross]; linarith

/-- **Partialling is symmetric.**  The partial covariance of the rate and the new feature can
be computed by residualising either side: `⟨r, z⟩ = ⟨r, z̃⟩`. -/
theorem partial_duality {p x r z zt : ι → ℝ} (hr : IsResidual p x r) (h : IsPartial p x z zt) :
    wip p r z = wip p r zt := by
  obtain ⟨_, a, b, hdec⟩ := h
  have hz : (fun i => a + b * x i + zt i) = z := funext fun i => (hdec i).symm
  have hkey := wip_residual_affine_invariant hr a b zt
  rwa [hz] at hkey

/-- The same partial covariance is also `⟨y, z̃⟩`, a functional of the *raw* rate profile. -/
theorem partial_duality_rate {p x y r z zt : ι → ℝ} {a' b' : ℝ}
    (hy : ∀ i, y i = a' + b' * x i + r i) (hr : IsResidual p x r) (h : IsPartial p x z zt) :
    wip p r z = wip p y zt := by
  have hyeq : y = fun i => a' + b' * x i + r i := funext hy
  have h1 : wip p zt (fun i => a' + b' * x i + r i) = wip p zt r :=
    wip_residual_affine_invariant h.1 a' b' r
  calc wip p r z = wip p r zt := partial_duality hr h
    _ = wip p zt r := wip_comm p r zt
    _ = wip p zt y := by rw [hyeq]; exact h1.symm
    _ = wip p y zt := wip_comm p zt y

/-- The **partialled gain**: the increment of the multiple `R²` (times the rate variance)
obtained by adding the feature `z` to a model that already contains the footprint. -/
noncomputable def pgain (p r zt : ι → ℝ) : ℝ := (wip p r zt) ^ 2 / wip p zt zt

/-- The honest (partialled) increment dominates the raw augmentation gain. -/
theorem pgain_ge_gain {p x r z zt : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (hr : IsResidual p x r)
    (h : IsPartial p x z zt) (hzt : 0 < wip p zt zt) :
    gain p r z ≤ pgain p r zt := by
  have hle : wip p zt zt ≤ wip p z z := wip_partial_le hp0 h
  rw [gain, pgain, partial_duality hr h]
  exact div_le_div_of_nonneg_left (sq_nonneg _) hzt hle

/-- Raw and partialled increments vanish together: "the feature contributes nothing" is an
unambiguous statement. -/
theorem pgain_eq_zero_iff_gain_eq_zero {p x r z zt : ι → ℝ} (hr : IsResidual p x r)
    (h : IsPartial p x z zt) (hzt : 0 < wip p zt zt) (hzz : 0 < wip p z z) :
    pgain p r zt = 0 ↔ gain p r z = 0 := by
  rw [gain_eq_zero_iff hzz, pgain, div_eq_zero_iff, partial_duality hr h]
  constructor
  · rintro (hc | hc)
    · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hc
    · exact absurd hc hzt.ne'
  · intro hc; left; rw [hc]; ring

/-! ## 2. The exact `ΔR² = (1 − R²) · ρ_partial²` identity -/

lemma wvar_eq_wip_of_centred {p r : ι → ℝ} (h1 : ∑ i, p i * r i = 0) :
    wvar p r = wip p r r := by
  have hm : wmean p r = 0 := h1
  simp only [wvar, wcov, wip, hm]
  exact Finset.sum_congr rfl fun i _ => by ring

lemma wcov_x_resid_zero {p x r : ι → ℝ} (hp : ∑ i, p i = 1) (hr : IsResidual p x r) :
    wcov p x r = 0 := by
  obtain ⟨h1, h2⟩ := hr
  rw [wcov_eq_raw hp, h1, mul_zero, sub_zero]
  rw [show (∑ i, p i * x i * r i) = wip p r x from Finset.sum_congr rfl fun i _ => by ring, h2]

/-- Variance decomposition of the rate into explained and residual parts. -/
lemma wvar_rate_decomp {p x y r : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) :
    wvar p y = b ^ 2 * wvar p x + wip p r r := by
  have hyeq : y = fun i => (a + b * x i) + r i := funext fun i => hy i
  have hxr : wcov p x r = 0 := wcov_x_resid_zero hp hr
  rw [hyeq, wvar_add, wvar_affine hp, wcov_affine_left hp a b x r, hxr,
    wvar_eq_wip_of_centred hr.1]
  ring

/-- Covariance of footprint and rate in the decomposed model. -/
lemma wcov_x_rate {p x y r : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) :
    wcov p x y = b * wvar p x := by
  have hyeq : y = fun i => (a + b * x i) + r i := funext fun i => hy i
  rw [hyeq, wcov_comm, wcov_add_left, wcov_comm, wcov_affine hp, wcov_comm,
    wcov_x_resid_zero hp hr, add_zero]

/-- **Unexplained share.**  `1 − R²` is exactly the residual energy as a fraction of the rate
variance — the quantity the extra feature has left to bite on. -/
theorem one_sub_R2_eq_residual_share {p x y r : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (hvx : 0 < wvar p x)
    (hvy : 0 < wvar p y) :
    1 - R2 p x y = wip p r r / wvar p y := by
  have hcov := wcov_x_rate hp hy hr
  have hvar := wvar_rate_decomp hp hy hr
  have hsimp : (b * wvar p x) ^ 2 / (wvar p x * wvar p y) = b ^ 2 * wvar p x / wvar p y := by
    field_simp
  rw [R2, hcov, hsimp]
  field_simp
  linarith [hvar]

/-- **The exact increment identity.**  The increment of the variance share contributed by the
new feature factors as `(unexplained share) × (squared partial correlation)`.  Both factors
are population statistics, and either one can differ between populations: this is the precise
sense in which a replicated base dial gives no guarantee whatsoever about `ΔR²`. -/
theorem partial_gain_identity {p x y r zt : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (hvx : 0 < wvar p x)
    (hvy : 0 < wvar p y) (hrr : 0 < wip p r r) (hzt : 0 < wip p zt zt) :
    pgain p r zt / wvar p y
      = (1 - R2 p x y) * ((wip p r zt) ^ 2 / (wip p r r * wip p zt zt)) := by
  rw [one_sub_R2_eq_residual_share hp hy hr hvx hvy, pgain]
  field_simp

/-! ## 3. The non-replication pair, restated for the honest statistic

`ztA` is the prime-power feature `pp` partialled against the footprint under the uniform
regime: `pp = 3/2 − (2/5)·foot + ztA`. -/

/-- The partialled prime-power feature for the first four-key population. -/
noncomputable def ztA : Fin 4 → ℝ := ![-1/10, 3/10, -3/10, 1/10]

lemma ztA_isResidual : IsResidual pU foot ztA := by
  refine ⟨?_, ?_⟩ <;>
    norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
      Matrix.head_cons, Matrix.tail_cons, pU, foot, ztA]

lemma pp_isPartial : IsPartial pU foot pp ztA :=
  ⟨ztA_isResidual, 3/2, -2/5, by intro i; fin_cases i <;> norm_num [pp, foot, ztA]⟩

lemma wip_ztA_pos : 0 < wip pU ztA ztA := by
  norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, ztA]

theorem pgain_A : pgain pU residA ztA = 45/49 := by
  norm_num [pgain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, residA, ztA]

theorem pgain_B : pgain pU residB ztA = 0 := by
  norm_num [pgain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, residB, ztA]

/-- **EXTENDED-DIAL-ABSENT, honest statistic.**  For the *partialled* prime-power feature —
the increment of the multiple `R²` that the experiment actually reports — the two
populations of `extended_dial_nonreplication` give `ΔR² = 20/49 > 0.4` and `ΔR² = 0`, while
sharing the same footprint, the same feature, the same draw regime and the same base
variance share `5/9`.  The first-cycle conclusion is therefore not an artefact of measuring
the raw augmentation gain. -/
theorem extended_dial_nonreplication_partial :
    R2 pU foot rateA = R2 pU foot rateB ∧
    pgain pU residA ztA / wvar pU rateA = 20/49 ∧
    pgain pU residB ztA / wvar pU rateB = 0 ∧
    (2 : ℝ)/5 < pgain pU residA ztA / wvar pU rateA := by
  refine ⟨by rw [baseR2_A, baseR2_B], ?_, ?_, ?_⟩
  · rw [pgain_A, wvar_rateA]; norm_num
  · rw [pgain_B, wvar_rateB]; norm_num
  · rw [pgain_A, wvar_rateA]; norm_num

/-- The partialled prime-power feature for the second (comonotone) four-key population. -/
noncomputable def zt2 : Fin 4 → ℝ := ![1/38, 1/38, -7/38, 5/38]

lemma zt2_isResidual : IsResidual pU foot2 zt2 := by
  refine ⟨?_, ?_⟩ <;>
    norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
      Matrix.head_cons, Matrix.tail_cons, pU, foot2, zt2]

lemma pp_isPartial2 : IsPartial pU foot2 pp zt2 :=
  ⟨zt2_isResidual, -5/38, 6/19, by intro i; fin_cases i <;> norm_num [pp, foot2, zt2]⟩

lemma wip_zt2_pos : 0 < wip pU zt2 zt2 := by
  norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, zt2]

/-- **Marginal present, incremental absent — honest statistic.**  On the comonotone
population the prime-power feature has a strictly positive marginal dial in every
full-support draw regime, and yet its partialled increment is exactly zero, even though the
footprint model leaves genuine residual energy. -/
theorem pp_partial_incremental_absent :
    (∀ R : DrawRegime (Fin 4), (∀ i, 0 < R.p i) → 0 < wcov R.p pp rate2) ∧
    pgain pU resid2 zt2 = 0 ∧ 0 < wip pU resid2 resid2 := by
  refine ⟨pp_marginal_positive, ?_, base_fit_not_saturated.2⟩
  norm_num [pgain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, resid2, zt2]

/-! ## 4. Regime drift cannot manufacture (or destroy) the increment -/

/-- The partial covariance is `ℓ¹`-Lipschitz in the draw regime. -/
theorem wip_stability_tv {p q r z : ι → ℝ} {M : ℝ} (hM : ∀ i, |r i * z i| ≤ M) :
    |wip p r z - wip q r z| ≤ M * ∑ i, |p i - q i| := by
  have hdiff : wip p r z - wip q r z = ∑ i, (p i - q i) * (r i * z i) := by
    simp only [wip, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hdiff, Finset.mul_sum]
  refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun i _ => ?_)
  rw [abs_mul]
  nlinarith [hM i, abs_nonneg (p i - q i), abs_nonneg (r i * z i)]

/-- **Regime drift is not the explanation.**  If the feature has exactly zero partial
covariance under some regime `q`, then under any regime `p` the augmentation gain is at most
quadratically small in the `ℓ¹` distance between the regimes.  Re-weighting a population
cannot resurrect an absent feature; only changing the population can. -/
theorem gain_le_of_nearby_zero_regime {p q r z : ι → ℝ} {M : ℝ} (hM : ∀ i, |r i * z i| ≤ M)
    (hq : wip q r z = 0) (hz : 0 < wip p z z) :
    gain p r z ≤ (M * ∑ i, |p i - q i|) ^ 2 / wip p z z := by
  have hb : |wip p r z| ≤ M * ∑ i, |p i - q i| := by
    have hst := wip_stability_tv (p := p) (q := q) (r := r) (z := z) hM
    rwa [hq, sub_zero] at hst
  have hsq : (wip p r z) ^ 2 ≤ (M * ∑ i, |p i - q i|) ^ 2 := by
    have hpw := pow_le_pow_left₀ (abs_nonneg (wip p r z)) hb 2
    rwa [sq_abs] at hpw
  rw [gain]
  gcongr

/-! ## 5. Zero increment is a codimension-one coincidence -/

/-- The rate profile `y` enters the increment only through the linear functional
`y ↦ ⟨y, z̃⟩`.  This is the "zero-gain functional" of the population. -/
noncomputable def zeroGainFunctional (p zt : ι → ℝ) : (ι → ℝ) →ₗ[ℝ] ℝ where
  toFun := fun y => wip p y zt
  map_add' := by
    intro u v
    simp only [wip, ← Finset.sum_add_distrib, Pi.add_apply]
    exact Finset.sum_congr rfl fun i _ => by ring
  map_smul' := by
    intro c u
    simp only [wip, RingHom.id_apply, Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring

/-- A rate profile lies in the kernel of the zero-gain functional exactly when the feature's
increment vanishes for it. -/
theorem mem_ker_iff_pgain_zero {p x y r z zt : ι → ℝ} {a' b' : ℝ}
    (hy : ∀ i, y i = a' + b' * x i + r i) (hr : IsResidual p x r) (h : IsPartial p x z zt)
    (hzt : 0 < wip p zt zt) :
    y ∈ LinearMap.ker (zeroGainFunctional p zt) ↔ pgain p r zt = 0 := by
  have hdual : wip p r zt = wip p y zt := by
    rw [← partial_duality hr h, partial_duality_rate hy hr h]
  have hmem : y ∈ LinearMap.ker (zeroGainFunctional p zt) ↔ wip p y zt = 0 := Iff.rfl
  rw [hmem, pgain, div_eq_zero_iff, ← hdual]
  constructor
  · intro h0; left; rw [h0]; ring
  · rintro (hc | hc)
    · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hc
    · exact absurd hc hzt.ne'

/-- **Codimension one.**  For a nondegenerate partialled feature the set of rate profiles on
which the feature contributes nothing is a hyperplane: a linear subspace of codimension
exactly one inside the `#keys`-dimensional space of rate profiles.  Within a single
population, "absent" is a knife-edge condition; the experiment observing it on five fresh
populations is therefore a structural statement about the feature, not a sampling accident. -/
theorem zero_gain_locus_codim_one {p zt : ι → ℝ} (h : wip p zt zt ≠ 0) :
    Module.finrank ℝ (LinearMap.ker (zeroGainFunctional p zt)) + 1 = Fintype.card ι := by
  have hsurj : Function.Surjective (zeroGainFunctional p zt) := by
    intro t
    refine ⟨(t / wip p zt zt) • zt, ?_⟩
    have hval : zeroGainFunctional p zt ((t / wip p zt zt) • zt)
        = (t / wip p zt zt) * wip p zt zt := by
      simp [zeroGainFunctional, wip, Finset.mul_sum]
    rw [hval]; field_simp
  have hr : LinearMap.range (zeroGainFunctional p zt) = ⊤ := LinearMap.range_eq_top.mpr hsurj
  have key := LinearMap.finrank_range_add_finrank_ker (zeroGainFunctional p zt)
  rw [hr] at key
  simp [Module.finrank_fintype_fun_eq_card] at key
  omega

end ExtendedDial

end Catalog.UniformDial