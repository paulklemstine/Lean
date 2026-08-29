import Bridges.Ma1EffectivityMultiCell

/-!
# The power curve of the additive control, and sharpness of the contrast ceiling at every
cell count

This file closes the two items that `Bridges.Ma1EffectivityMultiCell` left open, namely
directions **D** (*power curve of the additive perturbation control*) and **E**
(*deficiency of the contrast ceiling for three or more cells*) of `FUTURE_DIRECTIONS.md`.

## 1. No deficiency at any cell count (direction E)

`multicell_contrast_le_of_rsq` bounds every weighted contrast of cell means by a
Cauchy–Schwarz expression in the recorded ceiling `ρ`.  It was known to be sharp for a
*two*-valued feature (`two_cell_gap_eq_of_measurable`).  Here the equality case is settled
for an arbitrary number of cells: for a response that is a function of the feature, the
weights `w_c = n_c (m_c − m)` — which form a genuine contrast, `Σ_c w_c = 0`
(`sum_cell_weights_eq_zero`) — turn the inequality into an *equality* with
`ρ = R² = 1` (`multicell_contrast_eq_of_measurable`, `multicell_ceiling_sharp`).  So the
constant has deficiency zero at every cell count `k`, and the conjectured extra room for a
multi-cell criterion inside a null `R²` does not exist: the pairwise constant was already
optimal.

## 2. The power curve of the additive control (direction D)

`perturbation_control_nonvacuous` gave a threshold amplitude past which the perturbed
readouts exceed the observed one.  The finer object is the behaviour of the readout as a
*function of the amplitude*:

* for `χ²` it is the exact quadratic of `chiSq_perturb`, whence the symmetric identity
  `chiSq_symmetric_sum` and the fact that a two-point symmetric perturbation `c ± t·w`
  rejects at *every* nonzero amplitude (`chiSq_symmetric_reject`), not just past a
  threshold;
* for `maxDev` it is a convex function of the amplitude
  (`maxDev_perturb_convexOn`), so the acceptance region is an interval
  (`maxDev_acceptance_convex`) and the symmetric two-point family again dominates the
  observed readout (`maxDev_symmetric_ge`).

Quantitatively, the two-point p-value of the `χ²` readout is *exactly* `1/2` for every
amplitude below `2|B|/A` (`chiSq_twoPoint_pvalue_eq_half`), in exact contrast with the
relabelling control whose p-value is identically `1`
(`additive_control_strictly_better_than_permutation`).
-/

namespace Ma1Effectivity

open Finset QRResidual

open scoped Classical

variable {ι : Type*} [Fintype ι] {α : Type*}

/-! ## Part 1 — sharpness of the multi-cell contrast ceiling at every cell count -/

/-- For a response that is a function of the feature, the between-cell energy exhausts the
total energy. -/
theorem betweenSS_eq_tss_of_measurable (y : ι → ℝ) (P : ι → α) (g : α → ℝ)
    (hy : ∀ i, y i = g (P i)) : betweenSS y P = tss y := by
  have hsplit := tss_eq_withinSS_add_betweenSS y P
  rw [withinSS_eq_zero_of_measurable y P g hy, zero_add] at hsplit
  exact hsplit.symm

/-- A response that is a function of the feature is explained perfectly: `R² = 1`. -/
theorem rsq_measurableClass_eq_one_of_measurable {y : ι → ℝ} {P : ι → α} (htss : 0 < tss y)
    (g : α → ℝ) (hy : ∀ i, y i = g (P i)) : rsq y (measurableClass P) = 1 := by
  have h := rsq_measurableClass_mul_tss y P htss
  rw [betweenSS_eq_tss_of_measurable y P g hy] at h
  have h1 : rsq y (measurableClass P) * tss y = 1 * tss y := by rw [h, one_mul]
  exact mul_right_cancel₀ htss.ne' h1

/-- The cell sizes sum to the sample size. -/
theorem sum_cell_card_eq_card (P : ι → α) :
    ∑ c ∈ univ.image P, ((cell P c).card : ℝ) = (Fintype.card ι : ℝ) := by
  classical
  have hmaps : ∀ i ∈ (univ : Finset ι), P i ∈ univ.image P :=
    fun i _ => Finset.mem_image_of_mem P (Finset.mem_univ i)
  have h := Finset.sum_fiberwise_of_maps_to hmaps (fun _ : ι => (1 : ℝ))
  calc ∑ c ∈ univ.image P, ((cell P c).card : ℝ)
      = ∑ c ∈ univ.image P, ∑ _i ∈ cell P c, (1 : ℝ) := by
        refine Finset.sum_congr rfl fun c _ => ?_
        simp
    _ = ∑ _i : ι, (1 : ℝ) := h
    _ = (Fintype.card ι : ℝ) := by simp

/-- The weighted cell sums recover the total response sum. -/
theorem sum_cell_card_mul_cellMean (y : ι → ℝ) (P : ι → α) :
    ∑ c ∈ univ.image P, ((cell P c).card : ℝ) * cellMean y P c = ∑ i, y i := by
  classical
  have hmaps : ∀ i ∈ (univ : Finset ι), P i ∈ univ.image P :=
    fun i _ => Finset.mem_image_of_mem P (Finset.mem_univ i)
  have h := Finset.sum_fiberwise_of_maps_to hmaps y
  have hcell : ∀ c ∈ univ.image P,
      ((cell P c).card : ℝ) * cellMean y P c = ∑ i ∈ cell P c, y i := by
    intro c hc
    have hpos : (0 : ℝ) < ((cell P c).card : ℝ) := cell_card_pos hc
    rw [cellMean]
    field_simp
  rw [Finset.sum_congr rfl hcell]
  exact h

/-- **The optimal weights form a genuine contrast.**  The weights `w_c = n_c (m_c − m)`
which attain the multi-cell ceiling sum to zero, so the left-hand side of the ceiling really
is a contrast: it is unchanged by shifting the response by a constant. -/
theorem sum_cell_weights_eq_zero (y : ι → ℝ) (P : ι → α) :
    ∑ c ∈ univ.image P, ((cell P c).card : ℝ) * (cellMean y P c - mean y) = 0 := by
  classical
  have hexp : ∀ c ∈ univ.image P, ((cell P c).card : ℝ) * (cellMean y P c - mean y)
      = ((cell P c).card : ℝ) * cellMean y P c - ((cell P c).card : ℝ) * mean y := by
    intro c _; ring
  rw [Finset.sum_congr rfl hexp, Finset.sum_sub_distrib, ← Finset.sum_mul,
    sum_cell_card_mul_cellMean y P, sum_cell_card_eq_card P]
  by_cases hcard : (Fintype.card ι : ℝ) = 0
  · have hzero : (univ : Finset ι) = ∅ := by
      have : Fintype.card ι = 0 := by exact_mod_cast hcard
      exact Finset.card_eq_zero.1 (by simpa [Finset.card_univ] using this)
    simp [hzero, hcard]
  · rw [mean]
    field_simp
    ring

/-- **Sharpness of the multi-cell contrast ceiling, at every cell count.**  For a response
that is a function of the feature, the weights `w_c = n_c (m_c − m)` turn the Cauchy–Schwarz
ceiling of `multicell_contrast_le_of_rsq` into an exact equality, with `ρ = 1`.  The number
of cells is arbitrary: the constant has no deficiency for `k ≥ 3`. -/
theorem multicell_contrast_eq_of_measurable {y : ι → ℝ} {P : ι → α} (g : α → ℝ)
    (hy : ∀ i, y i = g (P i)) :
    (∑ c ∈ univ.image P,
        (((cell P c).card : ℝ) * (cellMean y P c - mean y)) * (cellMean y P c - mean y)) ^ 2
      = 1 * tss y * ∑ c ∈ univ.image P,
          (((cell P c).card : ℝ) * (cellMean y P c - mean y)) ^ 2 / ((cell P c).card : ℝ) := by
  classical
  set En : ℝ := ∑ c ∈ univ.image P, ((cell P c).card : ℝ) * (cellMean y P c - mean y) ^ 2
    with hEn
  have hleft : ∑ c ∈ univ.image P,
      (((cell P c).card : ℝ) * (cellMean y P c - mean y)) * (cellMean y P c - mean y) = En := by
    rw [hEn]
    exact Finset.sum_congr rfl fun c _ => by ring
  have hright : ∑ c ∈ univ.image P,
      (((cell P c).card : ℝ) * (cellMean y P c - mean y)) ^ 2 / ((cell P c).card : ℝ) = En := by
    rw [hEn]
    refine Finset.sum_congr rfl fun c hc => ?_
    have hpos : (0 : ℝ) < ((cell P c).card : ℝ) := cell_card_pos hc
    field_simp
  have htss : tss y = En := by
    rw [← betweenSS_eq_tss_of_measurable y P g hy, betweenSS, hEn]
  rw [hleft, hright, htss]
  ring

/-- The equality case, phrased against the recorded `R²` itself: there is a contrast whose
value equals the ceiling `rsq · TSS · Σ w²/n`, for any number of cells. -/
theorem multicell_ceiling_sharp {y : ι → ℝ} {P : ι → α} (htss : 0 < tss y) (g : α → ℝ)
    (hy : ∀ i, y i = g (P i)) :
    ∃ w : α → ℝ, (∑ c ∈ univ.image P, w c = 0) ∧
      (∑ c ∈ univ.image P, w c * (cellMean y P c - mean y)) ^ 2
        = rsq y (measurableClass P) * tss y
            * ∑ c ∈ univ.image P, (w c) ^ 2 / ((cell P c).card : ℝ) := by
  refine ⟨fun c => ((cell P c).card : ℝ) * (cellMean y P c - mean y),
    sum_cell_weights_eq_zero y P, ?_⟩
  rw [rsq_measurableClass_eq_one_of_measurable htss g hy]
  exact multicell_contrast_eq_of_measurable g hy

/-! ## Part 2 — the power curve of the additive perturbation control -/

variable [Nonempty ι]

omit [Nonempty ι] in
/-- The symmetric two-point identity for the `χ²` readout: the average of the two perturbed
readouts exceeds the observed one by exactly `t²·Σ w²/E`. -/
theorem chiSq_symmetric_sum (c w : ι → ℝ) (E t : ℝ) :
    chiSq (fun a => c a + t * w a) E + chiSq (fun a => c a - t * w a) E
      = 2 * chiSq c E + 2 * t ^ 2 * (∑ a, (w a) ^ 2) / E := by
  have hneg : (fun a => c a - t * w a) = fun a => c a + (-t) * w a := by
    funext a; ring
  rw [hneg, chiSq_perturb c w E t, chiSq_perturb c w E (-t)]
  ring

omit [Nonempty ι] in
/-- **The symmetric additive control rejects at every amplitude.**  Unlike the one-sided
statement `chiSq_perturb_gt`, which needs a large amplitude, the two-point family `c ± t·w`
beats the observed `χ²` readout for *every* nonzero amplitude. -/
theorem chiSq_symmetric_reject {c w : ι → ℝ} {E : ℝ} (hE : 0 < E) {a₀ : ι} (hw : w a₀ ≠ 0)
    {t : ℝ} (ht : t ≠ 0) :
    chiSq c E
      < max (chiSq (fun a => c a + t * w a) E) (chiSq (fun a => c a - t * w a) E) := by
  classical
  have hApos : (0 : ℝ) < ∑ a, (w a) ^ 2 := by
    have hterm : (0 : ℝ) < (w a₀) ^ 2 := by positivity
    have hle : (w a₀) ^ 2 ≤ ∑ a, (w a) ^ 2 :=
      Finset.single_le_sum (f := fun a => (w a) ^ 2) (fun a _ => by positivity) (mem_univ a₀)
    linarith
  have hsum := chiSq_symmetric_sum c w E t
  have hpos : 0 < 2 * t ^ 2 * (∑ a, (w a) ^ 2) / E := by
    have ht2 : 0 < t ^ 2 := by positivity
    positivity
  have hmax₁ : chiSq (fun a => c a + t * w a) E
      ≤ max (chiSq (fun a => c a + t * w a) E) (chiSq (fun a => c a - t * w a) E) :=
    le_max_left _ _
  have hmax₂ : chiSq (fun a => c a - t * w a) E
      ≤ max (chiSq (fun a => c a + t * w a) E) (chiSq (fun a => c a - t * w a) E) :=
    le_max_right _ _
  linarith

/-- The maximal-deviation readout is a **convex** function of the perturbation amplitude:
it is a finite supremum of absolute values of affine functions of the amplitude. -/
theorem maxDev_perturb_convexOn (c w : ι → ℝ) {E : ℝ} (hE : 0 < E) :
    ConvexOn ℝ (Set.univ : Set ℝ) fun t : ℝ => maxDev (fun a => c a + t * w a) E := by
  classical
  have hsqrt : 0 < Real.sqrt E := Real.sqrt_pos.2 hE
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ p q hp hq hpq
  have hkey : (univ.sup' univ_nonempty fun a => |c a + (p * x + q * y) * w a - E|)
      ≤ p * (univ.sup' univ_nonempty fun a => |c a + x * w a - E|)
        + q * (univ.sup' univ_nonempty fun a => |c a + y * w a - E|) := by
    refine Finset.sup'_le _ _ fun a _ => ?_
    have hsplit : c a + (p * x + q * y) * w a - E
        = p * (c a + x * w a - E) + q * (c a + y * w a - E) := by
      have hq' : q = 1 - p := by linarith
      subst hq'; ring
    have hx : |c a + x * w a - E|
        ≤ univ.sup' univ_nonempty fun a => |c a + x * w a - E| :=
      Finset.le_sup' (fun a => |c a + x * w a - E|) (mem_univ a)
    have hy' : |c a + y * w a - E|
        ≤ univ.sup' univ_nonempty fun a => |c a + y * w a - E| :=
      Finset.le_sup' (fun a => |c a + y * w a - E|) (mem_univ a)
    calc |c a + (p * x + q * y) * w a - E|
        = |p * (c a + x * w a - E) + q * (c a + y * w a - E)| := by rw [hsplit]
      _ ≤ |p * (c a + x * w a - E)| + |q * (c a + y * w a - E)| := abs_add_le _ _
      _ = p * |c a + x * w a - E| + q * |c a + y * w a - E| := by
          rw [abs_mul, abs_mul, abs_of_nonneg hp, abs_of_nonneg hq]
      _ ≤ p * (univ.sup' univ_nonempty fun a => |c a + x * w a - E|)
            + q * (univ.sup' univ_nonempty fun a => |c a + y * w a - E|) := by gcongr
  simp only [maxDev, smul_eq_mul]
  have hcomb : p * ((univ.sup' univ_nonempty fun a => |c a + x * w a - E|) / Real.sqrt E)
        + q * ((univ.sup' univ_nonempty fun a => |c a + y * w a - E|) / Real.sqrt E)
      = (p * (univ.sup' univ_nonempty fun a => |c a + x * w a - E|)
          + q * (univ.sup' univ_nonempty fun a => |c a + y * w a - E|)) / Real.sqrt E := by
    ring
  rw [hcomb]
  gcongr

/-- **The acceptance region of the additive control is an interval.**  Convexity of the
amplitude profile means that the set of amplitudes at which the perturbed primary readout
falls below the observed one is convex; the control therefore rejects outside an interval,
with no gaps. -/
theorem maxDev_acceptance_convex {c w : ι → ℝ} {E : ℝ} (hE : 0 < E) :
    Convex ℝ {t : ℝ | maxDev (fun a => c a + t * w a) E < maxDev c E} := by
  have hconv := (maxDev_perturb_convexOn c w hE).convex_lt (maxDev c E)
  have hset : {x ∈ (Set.univ : Set ℝ) |
      (fun t : ℝ => maxDev (fun a => c a + t * w a) E) x < maxDev c E}
      = {t : ℝ | maxDev (fun a => c a + t * w a) E < maxDev c E} := by
    ext t; simp
  rwa [hset] at hconv

/-- **The symmetric two-point family dominates the observed primary readout**, at every
amplitude: convexity forces the average of the two perturbed readouts to be at least the
unperturbed one. -/
theorem maxDev_symmetric_ge {c w : ι → ℝ} {E : ℝ} (hE : 0 < E) (t : ℝ) :
    maxDev c E
      ≤ max (maxDev (fun a => c a + t * w a) E) (maxDev (fun a => c a - t * w a) E) := by
  have hconv := (maxDev_perturb_convexOn c w hE).2 (Set.mem_univ t) (Set.mem_univ (-t))
    (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num)
  simp only [smul_eq_mul] at hconv
  have hmid : (1/2 : ℝ) * t + (1/2 : ℝ) * (-t) = 0 := by ring
  rw [hmid] at hconv
  have hzero : (fun a => c a + (0 : ℝ) * w a) = c := by funext a; ring
  rw [hzero] at hconv
  have hneg : (fun a => c a + (-t) * w a) = fun a => c a - t * w a := by funext a; ring
  rw [hneg] at hconv
  have h₁ : maxDev (fun a => c a + t * w a) E
      ≤ max (maxDev (fun a => c a + t * w a) E) (maxDev (fun a => c a - t * w a) E) :=
    le_max_left _ _
  have h₂ : maxDev (fun a => c a - t * w a) E
      ≤ max (maxDev (fun a => c a + t * w a) E) (maxDev (fun a => c a - t * w a) E) :=
    le_max_right _ _
  linarith

/-! ### The exact two-point p-value -/

/-- The one-sided p-value of a statistic `T` under the symmetric two-point additive
randomisation `c ↦ c ± t·w`. -/
noncomputable def twoPointPValue (T : (ι → ℝ) → ℝ) (c w : ι → ℝ) (t : ℝ) : ℝ :=
  ((if T c ≤ T (fun a => c a + t * w a) then (1 : ℝ) else 0)
    + (if T c ≤ T (fun a => c a - t * w a) then (1 : ℝ) else 0)) / 2

omit [Nonempty ι] in
/-- **The two-point p-value of the `χ²` readout is exactly `1/2`** for every amplitude below
`2|B|/A`, where `B = Σ_a (c a − E) w a` is the overlap of the deviation field with the
perturbation direction and `A = Σ_a w a ²`.  Exactly one of the two symmetric perturbations
raises the readout and the other lowers it — the control is strictly informative, in exact
contrast with the relabelling control of `permutation_control_vacuous`, whose p-value is
identically `1`. -/
theorem chiSq_twoPoint_pvalue_eq_half {c w : ι → ℝ} {E : ℝ} (hE : 0 < E) {a₀ : ι}
    (hw : w a₀ ≠ 0) {t : ℝ} (ht : 0 < t)
    (hB : ∑ a, (c a - E) * w a ≠ 0)
    (hsmall : t * (∑ a, (w a) ^ 2) < 2 * |∑ a, (c a - E) * w a|) :
    twoPointPValue (fun c => chiSq c E) c w t = 1 / 2 := by
  classical
  set A : ℝ := ∑ a, (w a) ^ 2 with hA
  set B : ℝ := ∑ a, (c a - E) * w a with hBdef
  have hApos : 0 < A := by
    have hterm : (0 : ℝ) < (w a₀) ^ 2 := by positivity
    have hle : (w a₀) ^ 2 ≤ A :=
      Finset.single_le_sum (f := fun a => (w a) ^ 2) (fun a _ => by positivity) (mem_univ a₀)
    linarith
  have hneg : (fun a => c a - t * w a) = fun a => c a + (-t) * w a := by funext a; ring
  have hplus : chiSq (fun a => c a + t * w a) E
      = chiSq c E + (2 * t * B + t ^ 2 * A) / E := by
    rw [chiSq_perturb c w E t, ← hA, ← hBdef]
  have hminus : chiSq (fun a => c a - t * w a) E
      = chiSq c E + (2 * (-t) * B + (-t) ^ 2 * A) / E := by
    rw [hneg, chiSq_perturb c w E (-t), ← hA, ← hBdef]
  rcases lt_or_gt_of_ne hB with hBneg | hBpos
  · -- `B < 0`: the `+t` branch lowers the readout, the `−t` branch raises it
    have habs : |B| = -B := abs_of_neg hBneg
    rw [habs] at hsmall
    have hdown : 2 * t * B + t ^ 2 * A < 0 := by nlinarith
    have hup : 0 < 2 * (-t) * B + (-t) ^ 2 * A := by nlinarith
    have h₁ : chiSq (fun a => c a + t * w a) E < chiSq c E := by
      rw [hplus]
      have : (2 * t * B + t ^ 2 * A) / E < 0 := div_neg_of_neg_of_pos hdown hE
      linarith
    have h₂ : chiSq c E ≤ chiSq (fun a => c a - t * w a) E := by
      rw [hminus]
      have : 0 < (2 * (-t) * B + (-t) ^ 2 * A) / E := div_pos hup hE
      linarith
    rw [twoPointPValue, if_neg (not_le.2 h₁), if_pos h₂]
    norm_num
  · -- `B > 0`: the `+t` branch raises the readout, the `−t` branch lowers it
    have habs : |B| = B := abs_of_pos hBpos
    rw [habs] at hsmall
    have hup : 0 < 2 * t * B + t ^ 2 * A := by nlinarith
    have hdown : 2 * (-t) * B + (-t) ^ 2 * A < 0 := by nlinarith
    have h₁ : chiSq c E ≤ chiSq (fun a => c a + t * w a) E := by
      rw [hplus]
      have : 0 < (2 * t * B + t ^ 2 * A) / E := div_pos hup hE
      linarith
    have h₂ : chiSq (fun a => c a - t * w a) E < chiSq c E := by
      rw [hminus]
      have : (2 * (-t) * B + (-t) ^ 2 * A) / E < 0 := div_neg_of_neg_of_pos hdown hE
      linarith
    rw [twoPointPValue, if_pos h₁, if_neg (not_le.2 h₂)]
    norm_num

omit [Nonempty ι] in
/-- **The repaired control is strictly better than the registered one.**  On the same data,
the relabelling p-value of the `χ²` readout is exactly `1` (power zero) while the additive
two-point p-value is exactly `1/2`. -/
theorem additive_control_strictly_better_than_permutation {c w : ι → ℝ} {E : ℝ} (hE : 0 < E)
    {a₀ : ι} (hw : w a₀ ≠ 0) {t : ℝ} (ht : 0 < t)
    (hB : ∑ a, (c a - E) * w a ≠ 0)
    (hsmall : t * (∑ a, (w a) ^ 2) < 2 * |∑ a, (c a - E) * w a|) :
    permPValue (fun c => chiSq c E) c = 1 ∧
      twoPointPValue (fun c => chiSq c E) c w t = 1 / 2 :=
  ⟨permPValue_eq_one_of_invariant (fun c σ => chiSq_comp_perm c E σ) c,
   chiSq_twoPoint_pvalue_eq_half hE hw ht hB hsmall⟩

end Ma1Effectivity