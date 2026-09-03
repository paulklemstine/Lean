/-
# EXTENDED-DIAL-ABSENT: incremental explanatory power is population-specific

Companion to `Combinatorics.UniformDialDrawInvariance` (the *sign* of the footprint dial is
draw-regime invariant) and `Combinatorics.UniformDialYieldRegression` (the *variance share*
`R²` of the dial, and the exact gain formula for an augmented fit).

The experiment under test augments the validated footprint dial `w` by a **prime-power
feature** `pp` and asks whether the extra variance share `ΔR²(pp)` replicates across fresh
populations.  It does not: `ΔR²(pp) ≈ 0` on all five fresh populations, while an earlier
population reported `+0.089`.  This file isolates the exact structural reason why an
*incremental* statistic may fail to replicate even when every *marginal* statistic in sight
is stable, and gives fully explicit finite populations realising each phenomenon.

Main results.

* `wip_sq_le` — weighted Cauchy–Schwarz for the residual inner product.
* `gain_eq_zero_iff`, `gain_eq_residual_drop` — the augmentation gain is the drop in
  residual error, and it vanishes exactly at residual orthogonality.
* `mse_ge_of_isResidual` — the normal equations certify a global least-squares optimum;
  this is what makes "the residual" a well-defined object below.
* `wip_residual_affine_invariant`, `gain_zero_of_collinear` — a feature that is an affine
  function of the footprint contributes **exactly zero**: perfect collinearity kills the gain.
* `gain_le_collinearity_defect` — the quantitative form: the gain is bounded by the residual
  energy times the *relative collinearity defect* of the new feature.  Near-collinear
  features are provably near-useless, so the observed `ΔR² ≈ 0` needs no noise story.
* `sequential_gain` — the combined (two-extra-feature) model's error decomposes as a
  *sequential* sum of gains; the gains are not additive marginally.
* `extended_dial_nonreplication` — two explicit four-key populations with the **same**
  footprint, the **same** prime-power feature, the **same** draw regime and the **same**
  base variance share `R² = 5/9`, on which `ΔR²(pp) = 2/49 > 0.04` and `ΔR²(pp) = 0`
  respectively.  Non-replication is therefore not a power problem: it is a genuine
  population-level degree of freedom.
* `marginal_present_incremental_absent` — the sharpest form: an explicit population where
  the prime-power feature has a **strictly positive marginal dial in every full-support
  draw regime** (it is comonotone with the rate) and yet its incremental contribution over
  the footprint is **exactly zero**.  Marginal signal is not incremental signal.
* `replication_tail_bound` — a falsification bound: if the per-population success
  probability were at least `4/5`, seeing at most one success in five populations has
  probability at most `21/3125 < 0.007`.  With the recorded readings
  (`observed_exactly_one_above_target`, `observed_mean_below_target`) the `0.55` target is
  rejected at that level.
* `slope_attenuation`, `slope_band` — the transfer slope of a noise-contaminated footprint
  is `Var x / (Var x + Var u) ∈ (0,1)`: a slope strictly below one is forced, and lands in
  an explicit band once the noise-to-signal ratio is bounded.
-/
import Combinatorics.UniformDialYieldRegression

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

variable {ι : Type*} [Fintype ι]

/-! ## 1. The gain functional and its exact algebra -/

/-- Weighted (draw-regime) inner product of two population features. -/
noncomputable def wip (p f g : ι → ℝ) : ℝ := ∑ i, p i * f i * g i

lemma wip_comm (p f g : ι → ℝ) : wip p f g = wip p g f :=
  Finset.sum_congr rfl fun i _ => by ring

lemma wip_self_nonneg {p : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (f : ι → ℝ) : 0 ≤ wip p f f :=
  Finset.sum_nonneg fun i _ => by
    have := hp0 i; nlinarith [sq_nonneg (f i)]

lemma wip_sub_right (p f g h : ι → ℝ) :
    wip p f (fun i => g i - h i) = wip p f g - wip p f h := by
  simp only [wip, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **Weighted Cauchy–Schwarz** for the residual inner product. -/
theorem wip_sq_le {p : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (f g : ι → ℝ) :
    (wip p f g) ^ 2 ≤ wip p f f * wip p g g := by
  have key := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul (Finset.univ : Finset ι)
    (r := fun i => p i * f i * g i) (f := fun i => p i * f i ^ 2) (g := fun i => p i * g i ^ 2)
    (fun i _ => by have := hp0 i; positivity)
    (fun i _ => by have := hp0 i; positivity)
    (fun i _ => by ring)
  have e1 : ∑ i, p i * f i ^ 2 = wip p f f := Finset.sum_congr rfl fun i _ => by ring
  have e2 : ∑ i, p i * g i ^ 2 = wip p g g := Finset.sum_congr rfl fun i _ => by ring
  rw [e1, e2] at key
  exact key

/-- The **augmentation gain**: the variance the new feature `z` removes from the residual `r`. -/
noncomputable def gain (p r z : ι → ℝ) : ℝ := (wip p r z) ^ 2 / wip p z z

lemma gain_nonneg {p : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (r z : ι → ℝ) : 0 ≤ gain p r z :=
  div_nonneg (sq_nonneg _) (wip_self_nonneg hp0 z)

/-- The gain vanishes **exactly** at residual orthogonality. -/
theorem gain_eq_zero_iff {p r z : ι → ℝ} (hz : 0 < wip p z z) :
    gain p r z = 0 ↔ wip p r z = 0 := by
  unfold gain
  rw [div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h
    · exact absurd h hz.ne'
  · intro h; left; rw [h]; ring

/-- The gain is exactly the drop in weighted residual error achieved by the augmented fit. -/
theorem gain_eq_residual_drop {p r z : ι → ℝ} (hz : 0 < wip p z z) :
    ∑ i, p i * (r i - ((∑ j, p j * r j * z j) / (∑ j, p j * z j ^ 2)) * z i) ^ 2
      = wip p r r - gain p r z := by
  have hz' : 0 < ∑ i, p i * z i ^ 2 := by
    simpa [wip, sq, mul_assoc] using hz
  have h := augment_gain_eq (p := p) (r := r) (z := z) hz'
  rw [h]
  have e1 : (∑ i, p i * r i ^ 2) = wip p r r :=
    Finset.sum_congr rfl fun i _ => by ring
  have e2 : (∑ i, p i * z i ^ 2) = wip p z z :=
    Finset.sum_congr rfl fun i _ => by ring
  rw [e1, e2]
  rfl

/-! ## 2. Residuals: the normal equations as an optimality certificate -/

/-- `r` satisfies the **normal equations** for the footprint `x`: it is centred and
orthogonal to the footprint under the draw regime `p`. -/
def IsResidual (p x r : ι → ℝ) : Prop := (∑ i, p i * r i = 0) ∧ wip p r x = 0

/-- **Optimality certificate.**  If `y = a + b·x + r` with `r` satisfying the normal
equations, then `(a, b)` is a *global* least-squares optimum: no affine predictor does
better in any draw regime.  Hence "the residual" below is unambiguous. -/
theorem mse_ge_of_isResidual {p x y r : ι → ℝ} {a b : ℝ} (hp0 : ∀ i, 0 ≤ p i)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (a' b' : ℝ) :
    mse p x y a b ≤ mse p x y a' b' := by
  obtain ⟨hr1, hr2⟩ := hr
  have hbase : mse p x y a b = wip p r r := by
    simp only [mse, wip]
    exact Finset.sum_congr rfl fun i _ => by rw [hy i]; ring
  have hexp : mse p x y a' b'
      = wip p r r + (2 * (a - a') * (∑ i, p i * r i) + 2 * (b - b') * wip p r x)
        + ∑ i, p i * ((a - a') + (b - b') * x i) ^ 2 := by
    simp only [mse, wip]
    rw [show (2 * (a - a') * ∑ i, p i * r i + 2 * (b - b') * ∑ i, p i * r i * x i)
        = ∑ i, (2 * (a - a') * (p i * r i) + 2 * (b - b') * (p i * r i * x i)) by
      rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]]
    rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by rw [hy i]; ring
  have hsq : 0 ≤ ∑ i, p i * ((a - a') + (b - b') * x i) ^ 2 :=
    Finset.sum_nonneg fun i _ => mul_nonneg (hp0 i) (sq_nonneg _)
  rw [hbase, hexp, hr1, hr2]
  linarith

/-! ## 3. Collinearity: why an extra feature can contribute exactly nothing -/

/-- A residual sees only the part of a new feature that the base model cannot express:
adding any affine function of the footprint to `z` does not change `⟨r, z⟩`. -/
theorem wip_residual_affine_invariant {p x r : ι → ℝ} (hr : IsResidual p x r) (a b : ℝ)
    (w : ι → ℝ) : wip p r (fun i => a + b * x i + w i) = wip p r w := by
  obtain ⟨hr1, hr2⟩ := hr
  have : wip p r (fun i => a + b * x i + w i)
      = a * (∑ i, p i * r i) + b * wip p r x + wip p r w := by
    simp only [wip]
    rw [show (a * ∑ i, p i * r i + b * ∑ i, p i * r i * x i + ∑ i, p i * r i * w i)
        = ∑ i, (a * (p i * r i) + b * (p i * r i * x i) + p i * r i * w i) by
      rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [this, hr1, hr2]; ring

/-- **Perfect collinearity kills the gain.**  A prime-power feature that happens to be an
affine function of the footprint contributes exactly zero extra variance share. -/
theorem gain_zero_of_collinear {p x r z : ι → ℝ} (hr : IsResidual p x r) {a b : ℝ}
    (hz : ∀ i, z i = a + b * x i) : gain p r z = 0 := by
  have h0 : wip p r z = 0 := by
    have := wip_residual_affine_invariant hr a b (fun _ => (0 : ℝ))
    simp only [wip] at this ⊢
    rw [show (∑ i, p i * r i * z i) = ∑ i, p i * r i * (a + b * x i + (fun _ => (0:ℝ)) i) from
      Finset.sum_congr rfl fun i _ => by rw [hz i]; ring]
    simpa using this
  simp [gain, h0]

/-- **Quantitative collinearity bound.**  For every affine reference `a + b·x`, the gain of
`z` is at most the residual energy times the relative *collinearity defect* of `z`.  A
feature that is nearly an affine function of the footprint is provably nearly useless,
whatever the population — this is the mechanism behind `ΔR²(pp) ≈ 0`. -/
theorem gain_le_collinearity_defect {p x r z : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i)
    (hr : IsResidual p x r) (a b : ℝ) (hz : 0 < wip p z z) :
    gain p r z ≤ wip p r r * (wip p (fun i => z i - (a + b * x i)) (fun i => z i - (a + b * x i))
      / wip p z z) := by
  set d : ι → ℝ := fun i => z i - (a + b * x i) with hd
  have hrz : wip p r z = wip p r d := by
    have := wip_residual_affine_invariant hr a b d
    have hzeq : (fun i => a + b * x i + d i) = z := by
      funext i; simp [hd]
    rwa [hzeq] at this
  have hcs : (wip p r d) ^ 2 ≤ wip p r r * wip p d d := wip_sq_le hp0 r d
  rw [gain, hrz]
  rw [div_le_iff₀ hz] at *
  calc (wip p r d) ^ 2 ≤ wip p r r * wip p d d := hcs
    _ = wip p r r * (wip p d d / wip p z z) * wip p z z := by field_simp
  

/-- **Sequential decomposition of the combined model.**  Fitting `z` and then `w` removes
exactly `gain r z + gain (r − ĉz) w`; the two contributions are sequential, not additive,
which is why a feature validated in isolation may vanish inside a combined model. -/
theorem sequential_gain {p r z w : ι → ℝ} (hz : 0 < wip p z z) (hw : 0 < wip p w w) :
    let c := (∑ j, p j * r j * z j) / (∑ j, p j * z j ^ 2)
    let r' := fun i => r i - c * z i
    let d := (∑ j, p j * r' j * w j) / (∑ j, p j * w j ^ 2)
    ∑ i, p i * (r' i - d * w i) ^ 2 = wip p r r - gain p r z - gain p r' w := by
  intro c r' d
  have hz' : 0 < ∑ i, p i * z i ^ 2 := by simpa [wip, sq, mul_assoc] using hz
  have hstep1 : ∑ i, p i * (r' i - d * w i) ^ 2 = wip p r' r' - gain p r' w :=
    gain_eq_residual_drop (p := p) (r := r') (z := w) hw
  have hstep2 : wip p r' r' = wip p r r - gain p r z := by
    have := gain_eq_residual_drop (p := p) (r := r) (z := z) hz
    simpa [r', c, wip, sq, mul_assoc] using this
  rw [hstep1, hstep2]

/-! ## 4. Non-replication: two populations, same everything, different `ΔR²`

Four keys, uniform draw regime `pU`, footprint `foot = (1,2,3,4)` and prime-power indicator
`pp = (1,1,0,0)`.  Population `A` has rate `rateA`, population `B` has rate `rateB`.  Both
have residual energy `1`, hence *identical* base variance share `R² = 5/9`; but the
prime-power feature buys `2/49 ≈ 0.041` of variance share in `A` and exactly `0` in `B`. -/

/-- The footprint feature `w` of the four-key population. -/
def foot : Fin 4 → ℝ := ![1, 2, 3, 4]

/-- The prime-power indicator feature. -/
def pp : Fin 4 → ℝ := ![1, 1, 0, 0]

/-- Rate profile of population `A` (the population where the prime-power feature "worked"). -/
noncomputable def rateA : Fin 4 → ℝ := ![12/7, 3/7, 4, 27/7]

/-- Rate profile of population `B` (a fresh population). -/
def rateB : Fin 4 → ℝ := ![2, 1, 2, 5]

/-- Least-squares residual of `rateA` on `foot`. -/
noncomputable def residA : Fin 4 → ℝ := ![5/7, -11/7, 1, -1/7]

/-- Least-squares residual of `rateB` on `foot`. -/
def residB : Fin 4 → ℝ := ![1, -1, -1, 1]

lemma rateA_decomp (i : Fin 4) : rateA i = 0 + 1 * foot i + residA i := by
  fin_cases i <;> norm_num [rateA, foot, residA]

lemma rateB_decomp (i : Fin 4) : rateB i = 0 + 1 * foot i + residB i := by
  fin_cases i <;> norm_num [rateB, foot, residB]

lemma residA_isResidual : IsResidual pU foot residA := by
  refine ⟨?_, ?_⟩ <;>
    norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, foot, residA]

lemma residB_isResidual : IsResidual pU foot residB := by
  refine ⟨?_, ?_⟩ <;>
    norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, foot, residB]

/-- Population `A`'s fit is a genuine least-squares optimum. -/
theorem rateA_fit_optimal (a' b' : ℝ) : mse pU foot rateA 0 1 ≤ mse pU foot rateA a' b' :=
  mse_ge_of_isResidual pU_nonneg rateA_decomp residA_isResidual a' b'

/-- Population `B`'s fit is a genuine least-squares optimum. -/
theorem rateB_fit_optimal (a' b' : ℝ) : mse pU foot rateB 0 1 ≤ mse pU foot rateB a' b' :=
  mse_ge_of_isResidual pU_nonneg rateB_decomp residB_isResidual a' b'

theorem baseR2_A : R2 pU foot rateA = 5/9 := by
  norm_num [R2, wcov, wvar, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, foot, rateA]

theorem baseR2_B : R2 pU foot rateB = 5/9 := by
  norm_num [R2, wcov, wvar, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, foot, rateB]

theorem wvar_rateA : wvar pU rateA = 9/4 := by
  norm_num [wvar, wcov, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, rateA]

theorem wvar_rateB : wvar pU rateB = 9/4 := by
  norm_num [wvar, wcov, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, rateB]

theorem gain_A : gain pU residA pp = 9/98 := by
  norm_num [gain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, residA, pp]

theorem gain_B : gain pU residB pp = 0 := by
  norm_num [gain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, residB, pp]

/-- **EXTENDED-DIAL-ABSENT.**  Two four-key populations with the *same* footprint feature,
the *same* prime-power feature, the *same* (uniform) draw regime and the *same* base
variance share `5/9`.  In population `A` the prime-power feature adds `2/49 > 0.04` of
variance share; in the fresh population `B` it adds exactly `0`.  The incremental statistic
`ΔR²(pp)` is therefore a population-level degree of freedom, not a transferable constant:
no amount of extra sampling within `B` can recover the contribution seen in `A`. -/
theorem extended_dial_nonreplication :
    R2 pU foot rateA = R2 pU foot rateB ∧
    gain pU residA pp / wvar pU rateA = 2/49 ∧
    gain pU residB pp / wvar pU rateB = 0 ∧
    (1 : ℝ)/25 < gain pU residA pp / wvar pU rateA := by
  refine ⟨by rw [baseR2_A, baseR2_B], ?_, ?_, ?_⟩
  · rw [gain_A, wvar_rateA]; norm_num
  · rw [gain_B, wvar_rateB]; norm_num
  · rw [gain_A, wvar_rateA]; norm_num

/-! ## 5. Marginal signal is not incremental signal

A second four-key population.  Here the prime-power feature is *comonotone* with the rate,
so by `wcov_pos_of_comonotone` its **marginal** dial is strictly positive in *every*
full-support draw regime — the strongest form of stability available in the catalog.  Yet
its **incremental** contribution over the footprint is exactly zero. -/

/-- Footprint of the second population. -/
noncomputable def foot2 : Fin 4 → ℝ := ![7/2, 7/2, 1, 0]

/-- Rate profile of the second population. -/
def rate2 : Fin 4 → ℝ := ![4, 3, 1, 0]

/-- Least-squares residual of `rate2` on `foot2`. -/
noncomputable def resid2 : Fin 4 → ℝ := ![1/2, -1/2, 0, 0]

lemma rate2_decomp (i : Fin 4) : rate2 i = 0 + 1 * foot2 i + resid2 i := by
  fin_cases i <;> norm_num [rate2, foot2, resid2]

lemma resid2_isResidual : IsResidual pU foot2 resid2 := by
  refine ⟨?_, ?_⟩ <;>
    norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, foot2, resid2]

theorem rate2_fit_optimal (a' b' : ℝ) : mse pU foot2 rate2 0 1 ≤ mse pU foot2 rate2 a' b' :=
  mse_ge_of_isResidual pU_nonneg rate2_decomp resid2_isResidual a' b'

/-- The prime-power feature is comonotone with the rate in this population. -/
theorem pp_comonotone_rate2 : Comonotone pp rate2 := by
  intro i j
  fin_cases i <;> fin_cases j <;> norm_num [pp, rate2]

/-- Hence its **marginal** dial is strictly positive in every full-support draw regime. -/
theorem pp_marginal_positive (R : DrawRegime (Fin 4)) (hR : ∀ i, 0 < R.p i) :
    0 < wcov R.p pp rate2 :=
  wcov_pos_of_comonotone R pp_comonotone_rate2 (a := 0) (b := 2) (hR 0) (hR 2)
    (by norm_num [pp, rate2, Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons])

/-- And yet, over the footprint, its **incremental** contribution is exactly zero. -/
theorem pp_incremental_absent : gain pU resid2 pp = 0 := by
  norm_num [gain, wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, resid2, pp]

/-- The base fit is not already perfect, so the zero gain is not an artefact of a saturated
model: the footprint leaves a strictly positive residual energy which the prime-power
feature simply cannot touch. -/
theorem base_fit_not_saturated : R2 pU foot2 rate2 = 19/20 ∧ 0 < wip pU resid2 resid2 := by
  constructor
  · norm_num [R2, wcov, wvar, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, foot2, rate2]
  · norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons, pU, resid2]

/-- **Marginal present, incremental absent.**  A single population on which the prime-power
feature (i) has a strictly positive marginal dial in *every* full-support draw regime, and
(ii) contributes exactly zero once the footprint dial is in the model, while (iii) the
footprint model is not saturated.  Marginal replication therefore carries no information
whatsoever about incremental replication: reporting `ΔR²(pp) ≈ 0` is fully consistent with
the prime-power feature being genuinely associated with the yield. -/
theorem marginal_present_incremental_absent :
    (∀ R : DrawRegime (Fin 4), (∀ i, 0 < R.p i) → 0 < wcov R.p pp rate2) ∧
    gain pU resid2 pp = 0 ∧ 0 < wip pU resid2 resid2 :=
  ⟨pp_marginal_positive, pp_incremental_absent, base_fit_not_saturated.2⟩

/-! ## 6. The recorded readings, and a falsification bound -/

/-- The five recorded augmented-dial readings `R²` at `u = 3.5`, seeds `20261060–64`. -/
noncomputable def obsR2 : Fin 5 → ℝ := ![49/100, 111/200, 107/250, 133/250, 127/250]

theorem observed_mean : (∑ i, obsR2 i) / 5 = 2513/5000 := by
  norm_num [Fin.sum_univ_five, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.cons_val_four, Matrix.head_cons, Matrix.tail_cons, obsR2]

theorem observed_mean_below_target : (∑ i, obsR2 i) / 5 < 55/100 := by
  rw [observed_mean]; norm_num

/-- Exactly one of the five populations clears the `0.55` target. -/
theorem observed_exactly_one_above_target (i : Fin 5) : 55/100 ≤ obsR2 i ↔ i = 1 := by
  fin_cases i <;> norm_num [obsR2]

/-- **Falsification bound.**  If each fresh population cleared the target independently with
probability at least `4/5`, then observing at most one success out of five would have
probability at most `21/3125 < 0.007`.  Together with
`observed_exactly_one_above_target` this rejects the `80%`-replication hypothesis. -/
theorem replication_tail_bound (q : ℝ) (hq : 4/5 ≤ q) (hq1 : q ≤ 1) :
    (1 - q) ^ 5 + 5 * q * (1 - q) ^ 4 ≤ 21/3125 := by
  have h0 : 0 ≤ 1 - q := by linarith
  have h1 : 1 - q ≤ 1/5 := by linarith
  have key : (1 - q) ^ 5 + 5 * q * (1 - q) ^ 4 = 5 * (1 - q) ^ 4 - 4 * (1 - q) ^ 5 := by ring
  rw [key]
  nlinarith [sq_nonneg (1 - q), sq_nonneg (1 - q - 1/5), mul_nonneg h0 h0, pow_nonneg h0 3,
    pow_nonneg h0 4, mul_nonneg (mul_nonneg h0 h0) h0, sq_nonneg ((1 - q) ^ 2 - 1/25),
    sq_nonneg ((1 - q) ^ 2 + (1 - q)/5)]

/-! ## 7. Transfer slope: attenuation is forced -/

lemma wmean_add (p x u : ι → ℝ) :
    wmean p (fun i => x i + u i) = wmean p x + wmean p u := by
  simp only [wmean, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

lemma wcov_add_left (p x u y : ι → ℝ) :
    wcov p (fun i => x i + u i) y = wcov p x y + wcov p u y := by
  simp only [wcov, wmean_add, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => by simp only [wmean]; ring

lemma wvar_add (p x u : ι → ℝ) :
    wvar p (fun i => x i + u i) = wvar p x + 2 * wcov p x u + wvar p u := by
  simp only [wvar, wcov, wmean_add]
  have expand : ∀ i, p i * (x i + u i - (wmean p x + wmean p u))
        * (x i + u i - (wmean p x + wmean p u))
      = p i * (x i - wmean p x) * (x i - wmean p x)
        + 2 * (p i * (x i - wmean p x) * (u i - wmean p u))
        + p i * (u i - wmean p u) * (u i - wmean p u) := fun i => by ring
  rw [Finset.sum_congr rfl fun i _ => expand i, Finset.sum_add_distrib, Finset.sum_add_distrib,
    ← Finset.mul_sum]

/-- **Attenuation of the transfer slope.**  If the measured footprint is `x + u` with a
noise term `u` uncorrelated with both the true footprint and the rate, and the rate is
calibrated on the true footprint (`Cov(x, y) = Var x`), then the fitted transfer slope is
`Var x / (Var x + Var u)`: strictly below one whenever the noise is nondegenerate. -/
theorem slope_attenuation {p x u y : ι → ℝ} (hux : wcov p x u = 0) (huy : wcov p u y = 0)
    (hxy : wcov p x y = wvar p x) :
    wcov p (fun i => x i + u i) y / wvar p (fun i => x i + u i)
      = wvar p x / (wvar p x + wvar p u) := by
  rw [wcov_add_left, wvar_add, hux, huy, hxy]
  ring_nf

/-- The slope lies strictly inside `(0, 1)` as soon as the noise is nondegenerate, and inside
an explicit band once the noise-to-signal ratio is bounded: a bounded-noise footprint
transfers with slope in `[5/6, 1)`, matching a reading of `0.898` in band. -/
theorem slope_band {p x u y : ι → ℝ} (hux : wcov p x u = 0) (huy : wcov p u y = 0)
    (hxy : wcov p x y = wvar p x) (hu : 0 < wvar p u) (hratio : wvar p u ≤ wvar p x / 5) :
    5/6 ≤ wcov p (fun i => x i + u i) y / wvar p (fun i => x i + u i) ∧
    wcov p (fun i => x i + u i) y / wvar p (fun i => x i + u i) < 1 := by
  rw [slope_attenuation hux huy hxy]
  have hden : 0 < wvar p x + wvar p u := by linarith
  constructor
  · rw [le_div_iff₀ hden]; linarith
  · rw [div_lt_one hden]; linarith

end ExtendedDial

end Catalog.UniformDial