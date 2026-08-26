import MachineLearning.QRResidual.BlockCeiling
import MachineLearning.QRResidual.FootprintWeight

/-!
# What a feature can *ever* explain: the exact nonlinear ceiling

`ResidualLift` and `BlockCeiling` bound what a feature can explain *linearly*.  The
experiment's map claim is stronger — "every tested `N`-property class fails on the ~40%
residual" — and a linear bound cannot support it: a null linear increment is compatible
with a strong nonlinear dependence.

This file closes that gap.  For an arbitrary feature `f : ι → α` we compute the residual
sum of squares of the *entire* class of predictors that are functions of `f`, with no
linearity, monotonicity or smoothness assumption at all.  The answer is the classical
within-cell sum of squares, and the resulting `R²` is the correlation ratio `η²`.

Main results.

* `sum_sub_sq_split` — the cell identity `Σ(yᵢ−c)² = Σ(yᵢ−m)² + |S|(c−m)²`.
* `rss_measurableClass` — **the exact nonlinear fit**: `RSS` over all functions of `f`
  equals `withinSS y f`.
* `rsq_measurableClass` — hence `R²` over that class is exactly `1 − withinSS/TSS`.
* `residual_floor_of_within` — **the residual floor**: if the within-cell energy is at
  least a fraction `θ` of the total, then *no* function of `f` — linear or not — can
  explain more than `1 − θ` of the variance.  This is the shape of the "~40% residual is
  genuinely open" claim.
* `withinSS_mono_of_refines`, `residual_floor_of_refinement` — refinement monotonicity:
  appending covariates (e.g. the neighbourhood layer to the dial) can only lower the
  within-cell energy, and the floor transfers to the refined feature.
* `dial_measurable_floor` — the instance for the QR footprint dial: a floor on the residual
  of every predictor built from the dial, however nonlinear.
-/

namespace QRResidual

open Finset

variable {ι : Type*} [Fintype ι] {α : Type*} [DecidableEq α]

/-! ## Cells of a feature -/

/-- The cell (fiber) of the feature `f` over the value `a`. -/
def cell (f : ι → α) (a : α) : Finset ι := Finset.univ.filter (fun i => f i = a)

/-- The mean of the response on a cell. -/
noncomputable def cellMean (y : ι → ℝ) (f : ι → α) (a : α) : ℝ :=
  (∑ i ∈ cell f a, y i) / (cell f a).card

/-- The within-cell sum of squares of the response, over the cells of `f`. -/
noncomputable def withinSS (y : ι → ℝ) (f : ι → α) : ℝ :=
  ∑ a ∈ Finset.univ.image f, ∑ i ∈ cell f a, (y i - cellMean y f a) ^ 2

/-- The class of *all* predictors that are functions of the feature `f`: no linearity or
regularity assumption. -/
def measurableClass (f : ι → α) : Set (ι → ℝ) :=
  {h : ι → ℝ | ∃ φ : α → ℝ, h = fun i => φ (f i)}

theorem withinSS_nonneg (y : ι → ℝ) (f : ι → α) : 0 ≤ withinSS y f :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- Cells of values actually taken are nonempty. -/
theorem cell_card_ne_zero {f : ι → α} {a : α} (ha : a ∈ Finset.univ.image f) :
    ((cell f a).card : ℝ) ≠ 0 := by
  obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 ha
  have hi : i ∈ cell f (f i) := by simp [cell]
  have : 0 < (cell f (f i)).card := Finset.card_pos.2 ⟨i, hi⟩
  exact_mod_cast this.ne'

omit [Fintype ι] [DecidableEq α] in
/-- **Cell identity.**  On any cell, the squared deviation from a constant splits into the
within-cell energy plus the squared offset from the cell mean. -/
theorem sum_sub_sq_split (S : Finset ι) (y : ι → ℝ) (c : ℝ) (hcard : (S.card : ℝ) ≠ 0) :
    ∑ i ∈ S, (y i - c) ^ 2
      = ∑ i ∈ S, (y i - (∑ j ∈ S, y j) / S.card) ^ 2
        + S.card * (c - (∑ j ∈ S, y j) / S.card) ^ 2 := by
  set m : ℝ := (∑ j ∈ S, y j) / S.card with hm
  have key : ∀ d : ℝ, ∑ i ∈ S, (y i - d) ^ 2
      = (∑ i ∈ S, (y i) ^ 2) - 2 * d * (∑ i ∈ S, y i) + S.card * d ^ 2 := by
    intro d
    have h : ∀ i, (y i - d) ^ 2 = (y i) ^ 2 - 2 * d * (y i) + d ^ 2 := fun i => by ring
    rw [Finset.sum_congr rfl fun i _ => h i, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul]
  rw [key c, key m, hm]
  field_simp
  ring

/-- Decomposition of the residual energy of a `f`-measurable predictor over the cells. -/
theorem sqNorm_sub_comp (y : ι → ℝ) (f : ι → α) (φ : α → ℝ) :
    sqNorm (y - fun i => φ (f i))
      = ∑ a ∈ Finset.univ.image f, ∑ i ∈ cell f a, (y i - φ a) ^ 2 := by
  classical
  have hmaps : ∀ i ∈ (Finset.univ : Finset ι), f i ∈ Finset.univ.image f :=
    fun i _ => Finset.mem_image_of_mem f (Finset.mem_univ i)
  have hpart := Finset.sum_fiberwise_of_maps_to hmaps (fun i => (y i - φ (f i)) ^ 2)
  rw [sqNorm]
  simp only [Pi.sub_apply]
  rw [← hpart]
  refine Finset.sum_congr rfl fun a _ => ?_
  refine Finset.sum_congr rfl fun i hi => ?_
  have : f i = a := (Finset.mem_filter.1 hi).2
  rw [this]

/-- **The exact nonlinear fit.**  The best possible fit by *any* function of the feature `f`
leaves exactly the within-cell sum of squares. -/
theorem rss_measurableClass (y : ι → ℝ) (f : ι → α) :
    rss y (measurableClass f) = withinSS y f := by
  classical
  refine le_antisymm ?_ ?_
  · -- the cell-mean predictor attains it
    have hmem : (fun i => cellMean y f (f i)) ∈ measurableClass f := ⟨cellMean y f, rfl⟩
    have hle := rss_le_of_mem (y := y) hmem
    rw [sqNorm_sub_comp y f (cellMean y f)] at hle
    exact hle
  · -- and no predictor beats it
    refine le_rss ⟨fun _ => 0, ⟨fun _ => 0, rfl⟩⟩ ?_
    rintro h ⟨φ, rfl⟩
    rw [sqNorm_sub_comp y f φ]
    refine Finset.sum_le_sum fun a ha => ?_
    have hcard := cell_card_ne_zero (f := f) (a := a) ha
    rw [sum_sub_sq_split (cell f a) y (φ a) hcard]
    have hsq : 0 ≤ ((cell f a).card : ℝ) * (φ a - (∑ j ∈ cell f a, y j) / (cell f a).card) ^ 2 := by
      positivity
    simp only [cellMean]
    linarith

/-- **The correlation ratio.**  `R²` over all functions of `f` is exactly
`1 − withinSS/TSS`, the classical `η²`. -/
theorem rsq_measurableClass (y : ι → ℝ) (f : ι → α) :
    rsq y (measurableClass f) = 1 - withinSS y f / tss y := by
  rw [rsq, rss_measurableClass]

/-- **The residual floor.**  If the within-cell energy of the feature is at least a fraction
`θ` of the total variation, then no predictor built from that feature — linear, nonlinear,
or arbitrary — explains more than `1 − θ` of the variance. -/
theorem residual_floor_of_within {y : ι → ℝ} {f : ι → α} {θ : ℝ} (htss : 0 < tss y)
    (h : θ * tss y ≤ withinSS y f) : rsq y (measurableClass f) ≤ 1 - θ := by
  rw [rsq_measurableClass]
  have : θ ≤ withinSS y f / tss y := by
    rw [le_div_iff₀ htss]; exact h
  linarith

/-! ## Refinement: adding covariates to a feature -/

omit [Fintype ι] [DecidableEq α] in
/-- If `f` factors through `f'`, then every `f`-measurable predictor is `f'`-measurable. -/
theorem measurableClass_mono {β : Type*} [DecidableEq β] {f : ι → α} {f' : ι → β}
    {ψ : β → α} (hfac : ∀ i, f i = ψ (f' i)) :
    measurableClass f ⊆ measurableClass f' := by
  rintro h ⟨φ, rfl⟩
  exact ⟨fun b => φ (ψ b), by funext i; simp [hfac i]⟩

/-- **Refinement monotonicity.**  A finer feature has no larger within-cell energy: adding
covariates can only help, and by an exactly computable amount. -/
theorem withinSS_mono_of_refines {β : Type*} [DecidableEq β] {f : ι → α} {f' : ι → β}
    {ψ : β → α} (hfac : ∀ i, f i = ψ (f' i)) (y : ι → ℝ) :
    withinSS y f' ≤ withinSS y f := by
  have h := rss_mono (y := y) (measurableClass_mono hfac) ⟨fun _ => 0, ⟨fun _ => 0, rfl⟩⟩
  rwa [rss_measurableClass, rss_measurableClass] at h

/-- **Transfer of the floor to a refinement.**  If even the refined feature `f'` retains a
within-cell energy of at least a fraction `θ`, then the whole refined layer — the original
feature together with the appended covariates — still cannot explain more than `1 − θ`. -/
theorem residual_floor_of_refinement {β : Type*} [DecidableEq β] {y : ι → ℝ} {f' : ι → β}
    {θ : ℝ} (htss : 0 < tss y) (h : θ * tss y ≤ withinSS y f') :
    rsq y (measurableClass f') ≤ 1 - θ :=
  residual_floor_of_within htss h

/-! ## The instance for the QR footprint dial -/

/-- The dial feature of a finite sample of moduli, as a map into `ℚ`. -/
def dialFeature (B : ℕ) (Nsam : ι → ℤ) : ι → ℚ := fun i => qrWeight (Nsam i) B

/-- **The nonlinear dial ceiling.**  If the response varies by at least a fraction `θ` of
its total variation *within* the dial's level sets, then no predictor that is a function of
the dial — of any functional form — explains more than `1 − θ` of the variance.  With
`θ = 0.4` this is the theorem-level version of the "~40% residual is not a dial effect"
claim. -/
theorem dial_measurable_floor {y : ι → ℝ} {B : ℕ} {Nsam : ι → ℤ} {θ : ℝ} (htss : 0 < tss y)
    (h : θ * tss y ≤ withinSS y (dialFeature B Nsam)) :
    rsq y (measurableClass (dialFeature B Nsam)) ≤ 1 - θ :=
  residual_floor_of_within htss h

/-- **Coverage, in final form.**  Refining the dial by the neighbourhood layer (or by any
further covariates) does not escape the floor, as long as the refined feature still has the
within-cell energy: the residual stays open against the *joint* feature, not merely against
each layer separately. -/
theorem dial_neighborhood_joint_floor {β : Type*} [DecidableEq β] {y : ι → ℝ} {B : ℕ}
    {Nsam : ι → ℤ} {nb : ι → β} {θ : ℝ} (htss : 0 < tss y)
    (h : θ * tss y ≤ withinSS y (fun i => (dialFeature B Nsam i, nb i))) :
    rsq y (measurableClass (fun i => (dialFeature B Nsam i, nb i))) ≤ 1 - θ ∧
      withinSS y (fun i => (dialFeature B Nsam i, nb i)) ≤ withinSS y (dialFeature B Nsam) := by
  refine ⟨residual_floor_of_within htss h, ?_⟩
  exact withinSS_mono_of_refines (ψ := Prod.fst) (fun _ => rfl) y

end QRResidual