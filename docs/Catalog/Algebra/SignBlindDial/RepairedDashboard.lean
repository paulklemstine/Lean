/-
# The repaired dashboard: one extra bit is necessary *and* sufficient

Sixth cycle of the `EXTENDED-DIAL-ABSENT` investigation.  Cycles four and five established
the negative half of the story (`no_sign_blind_predictor`,
`sign_blind_ambiguity_dichotomy`, `masking_amplitude_isGreatest`).  This file supplies the
constructive positive half, and the invariance statements that explain why the sign bit is
*the* right extra datum.

Main results.

* `pgain_share_invariant_rate_rescaling`, `pgain_share_invariant_feature_rescaling` — the
  increment of the variance share is invariant under an affine change of units of the rate
  and of the augmenting feature.  The reported statistic is therefore a function on the
  quotient by the reparametrisation group; the three signed correlations are coordinates on
  that quotient, the three dial readings are the invariants of the residual sign action, and
  the product of the signs is the single coordinate left over.
* `repairedDial`, `signBit` — an explicit four-argument predictor.
* `repaired_dashboard_formula` — `ΔR² = repairedDial (R²(x,y)) (R²(z,y)) (R²(x,z)) s` where
  `s = ±1` is the sign of the correlation triple product.
* `exists_repaired_predictor` — hence a predictor *does* exist once the extra bit is logged;
  contrast `no_sign_blind_predictor`, which says none exists without it.  Together the two
  theorems locate the failure of sign-blind reporting at exactly one bit per augmentation.
-/
import Algebra.SignBlindDial.AmbiguityAmplitude

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

variable {ι : Type*} [Fintype ι]

/-! ## 1. Change of units leaves the increment alone -/

lemma wip_smul_left (p f g : ι → ℝ) (c : ℝ) :
    wip p (fun i => c * f i) g = c * wip p f g := by
  simp only [wip, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **Feature units are irrelevant.**  Rescaling the augmenting feature by `c ≠ 0` rescales
its partialled form by `c` and leaves the increment unchanged. -/
theorem pgain_share_invariant_feature_rescaling {p r zt : ι → ℝ} {c : ℝ} (hc : c ≠ 0) :
    pgain p r (fun i => c * zt i) = pgain p r zt := by
  have h1 : wip p r (fun i => c * zt i) = c * wip p r zt := by
    rw [wip_comm, wip_smul_left, wip_comm]
  have h2 : wip p (fun i => c * zt i) (fun i => c * zt i) = c ^ 2 * wip p zt zt := by
    rw [wip_smul_left, wip_comm, wip_smul_left, wip_comm]
    ring
  rcases eq_or_ne (wip p zt zt) 0 with hz | hz
  · rw [pgain, pgain, h1, h2, hz]
    simp
  · rw [pgain, pgain, h1, h2, mul_pow]
    field_simp

/-- **Rate units are irrelevant.**  Rescaling the rate by `c ≠ 0` rescales its residual by
`c` and its variance by `c²`, leaving the increment of the variance share unchanged. -/
theorem pgain_share_invariant_rate_rescaling {p y r zt : ι → ℝ} {c : ℝ} (hp : ∑ i, p i = 1)
    (hc : c ≠ 0) :
    pgain p (fun i => c * r i) zt / wvar p (fun i => 0 + c * y i)
      = pgain p r zt / wvar p y := by
  have h1 : wip p (fun i => c * r i) zt = c * wip p r zt := wip_smul_left p r zt c
  have h2 : wvar p (fun i => 0 + c * y i) = c ^ 2 * wvar p y := wvar_affine hp 0 c
  have hc2 : (0 : ℝ) < c ^ 2 := by positivity
  rw [pgain, pgain, h1, h2, mul_pow]
  rcases eq_or_ne (wip p zt zt) 0 with hz | hz
  · rw [hz]
    simp
  · field_simp

/-! ## 2. An explicit predictor from the three readings plus one bit -/

/-- The sign bit a reporting protocol must log: `+1` if the product of the three signed
correlations is nonnegative, `-1` otherwise. -/
noncomputable def signBit (t : ℝ) : ℝ := if 0 ≤ t then 1 else -1

lemma signBit_mul_abs (t : ℝ) : signBit t * |t| = t := by
  rw [signBit]
  split_ifs with h
  · rw [abs_of_nonneg h]; ring
  · rw [abs_of_neg (lt_of_not_ge h)]; ring

/-- The **repaired dial**: the explicit function of the three variance shares `a = R²(x,y)`,
`c = R²(z,y)`, `e = R²(x,z)` and the sign bit `s` that returns the augmentation increment. -/
noncomputable def repairedDial (a c e s : ℝ) : ℝ :=
  (c + a * e - 2 * s * Real.sqrt (a * e * c)) / (1 - e)

/-- **The repaired dashboard is correct.**  A protocol that logs the three variance shares
*and* the sign of the correlation triple product can compute the augmentation increment
exactly. -/
theorem repaired_dashboard_formula {p x y r z zt : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (h : IsPartial p x z zt)
    (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x) :
    pgain p r zt / wvar p y
      = repairedDial (R2 p x y) (R2 p z y) (R2 p x z) (signBit (tripleProd p x y z)) := by
  have hPabs : signBit (tripleProd p x y z) * Real.sqrt (R2 p x y * R2 p x z * R2 p z y)
      = tripleProd p x y z := by
    rw [← triple_product_sq_eq_R2_prod hvx hvy hvz, Real.sqrt_sq_eq_abs, signBit_mul_abs]
  rw [pgain_R2_triple_product_formula hp hy hr h hvx hvy hvz hpar, repairedDial]
  congr 1
  rw [show R2 p x y * R2 p x z * R2 p z y = R2 p x y * R2 p x z * R2 p z y from rfl,
    show 2 * signBit (tripleProd p x y z) * Real.sqrt (R2 p x y * R2 p x z * R2 p z y)
      = 2 * (signBit (tripleProd p x y z) * Real.sqrt (R2 p x y * R2 p x z * R2 p z y)) from by
      ring, hPabs]

/-- **Sufficiency of one bit, constructively.**  There *is* a function of the three dial
readings together with one sign bit that returns the increment on every finite population —
in exact opposition to `no_sign_blind_predictor`, which shows no function of the three dial
readings alone can.  The inadmissibility of sign-blind reporting is therefore precisely one
bit deep. -/
theorem exists_repaired_predictor :
    ∃ G : ℝ → ℝ → ℝ → ℝ → ℝ,
      ∀ (p x y r z zt : ι → ℝ) (a b : ℝ),
        (∑ i, p i = 1) → (∀ i, y i = a + b * x i + r i) → IsResidual p x r →
        IsPartial p x z zt → 0 < wvar p x → 0 < wvar p y → 0 < wvar p z →
        0 < wvar p z - (wcov p x z) ^ 2 / wvar p x →
        pgain p r zt / wvar p y
          = G (R2 p x y) (R2 p z y) (R2 p x z) (signBit (tripleProd p x y z)) := by
  refine ⟨repairedDial, ?_⟩
  intro p x y r z zt a b hp hy hr h hvx hvy hvz hpar
  exact repaired_dashboard_formula hp hy hr h hvx hvy hvz hpar

lemma signBit_of_neg {t : ℝ} (h : t < 0) : signBit t = -1 := by
  rw [signBit, if_neg (not_le.mpr h)]

lemma signBit_of_pos {t : ℝ} (h : 0 < t) : signBit t = 1 := by
  rw [signBit, if_pos h.le]

/-- **The repaired dial does the job on the flagship pair.**  The catalog's two populations
feed the repaired predictor *identical* dial readings and *opposite* sign bits, and the
predictor returns each population's true increment: `80/149` for the active one and `0` for
the suppressed one.  The one logged bit is exactly what separates them. -/
theorem repaired_dial_separates_catalog_pair :
    R2 pU foot rateSB = R2 pU foot rateSC ∧ R2 pU pp rateSB = R2 pU pp rateSC ∧
    signBit (tripleProd pU foot rateSB pp) = 1 ∧
    signBit (tripleProd pU foot rateSC pp) = -1 ∧
    pgain pU residSC ztA / wvar pU rateSC
        = repairedDial (R2 pU foot rateSC) (R2 pU pp rateSC) (R2 pU foot pp)
            (signBit (tripleProd pU foot rateSC pp)) ∧
      pgain pU residSB ztA / wvar pU rateSB
        = repairedDial (R2 pU foot rateSB) (R2 pU pp rateSB) (R2 pU foot pp)
            (signBit (tripleProd pU foot rateSB pp)) := by
  have hvx : 0 < wvar pU foot := by rw [wvar_foot]; norm_num
  have hvz : 0 < wvar pU pp := by rw [wvar_pp]; norm_num
  have hpar : 0 < wvar pU pp - (wcov pU foot pp) ^ 2 / wvar pU foot := by
    rw [wvar_pp, wcov_foot_pp, wvar_foot]; norm_num
  have hvB : 0 < wvar pU rateSB := by
    rw [← rateFamB_at_base]; exact wvar_rateFamB_pos (by norm_num)
  have hvC : 0 < wvar pU rateSC := by
    rw [← rateFamC_at_base]; exact wvar_rateFamC_pos (by norm_num)
  have hsign := sign_bit_suffices_on_family (b := 1/10) (u := 1/2) (by norm_num) (by norm_num)
  rw [rateFamB_at_base, rateFamC_at_base] at hsign
  refine ⟨base_dials_agree.1.trans base_dials_agree.2.symm,
    marginal_pp_dials_agree.1.trans marginal_pp_dials_agree.2.symm,
    signBit_of_pos hsign.2, signBit_of_neg hsign.1, ?_, ?_⟩
  · rw [← rateFamC_at_base, ← residFamC_at_base] at *
    exact repaired_dashboard_formula pU_total (rateFamC_decomp (1/10) (1/2))
      (residFamC_isResidual _ _) pp_isPartial hvx hvC hvz hpar
  · rw [← rateFamB_at_base, ← residFamB_at_base] at *
    exact repaired_dashboard_formula pU_total (rateFamB_decomp (1/10) (1/2))
      (residFamB_isResidual _ _) pp_isPartial hvx hvB hvz hpar

end ExtendedDial

end Catalog.UniformDial