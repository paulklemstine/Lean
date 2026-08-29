import Bridges.Ma1EffectivityAnova
import Bridges.Ma1EffectivitySignBlind

/-!
# Multi-cell null calculus, sharpness, and a control with nonzero power

This file closes two of the open items left by `Bridges.Ma1EffectivityAnova` and
`Bridges.Ma1EffectivitySignBlind`.

## 1. Beyond pairwise gaps (direction *Multi-Cell Null-Result Calculus*)

`cell_mean_gap_le_of_rsq` bounds the response-mean gap between *two* level sets of the
L-mass feature.  A decision rule need not look at two cells: it aggregates many.  The
general statement proved here is a **contrast inequality**: for any weights `w` on any
finite family `S` of feature levels,

  `(Σ_{c∈S} w c ·(m_c − m))² ≤ ρ·TSS·Σ_{c∈S} (w c)²/n_c`,

where `ρ` is any recorded ceiling for the whole class of functions of the feature
(`multicell_contrast_le_of_rsq`).  Taking `w = (+1, −1)` on a pair recovers the pairwise
ceiling; taking `w_c = ±n_c/N` on two *groups* of cells gives the group form
`group_mean_gap_le_of_rsq`, which is the bound relevant to an actual criterion: any rule
that reads the L-mass and sorts the moduli into an "MA-1 effective" group and its
complement separates the deviation means by at most `ρ·TSS·(1/N_A + 1/N_B)` in square.
`exp566_group_gap_ceiling` is the recorded stage-B instance `ρ = 0.0785`.

**Sharpness.**  `two_cell_gap_eq_of_measurable` shows the constant is exact: for a
two-valued feature on which the response is constant on each cell, the pairwise (hence the
group) inequality is an *equality* with `ρ = R² = 1`.  So the calculus cannot be improved
without extra hypotheses.

## 2. A control with nonzero power (direction *Permutation Controls for Symmetric
Readouts*)

`permutation_control_vacuous` shows the registered within-modulus relabeling control has
p-value identically `1`.  The natural repair is to randomise by *adding* a signed
perturbation instead of permuting classes.  `perturbation_control_nonvacuous` proves this
repair works: for any perturbation direction `w` that is nonzero somewhere, both registered
readouts of `c + t·w` eventually strictly exceed the observed readout of `c`.  The
perturbation family is therefore a control that *can* reject — its power is not zero —
in exact contrast with the relabeling family.
-/

namespace Ma1Effectivity

open Finset QRResidual

open scoped Classical

variable {ι : Type*} [Fintype ι] {α : Type*}

/-! ## The multi-cell contrast calculus -/

/-- A recorded `R²` ceiling for the class of all functions of a feature is a ceiling on the
between-cell energy. -/
theorem betweenSS_le_of_rsq {y : ι → ℝ} {P : ι → α} {ρ : ℝ} (htss : 0 < tss y)
    (hrsq : rsq y (measurableClass P) ≤ ρ) : betweenSS y P ≤ ρ * tss y := by
  rw [← rsq_measurableClass_mul_tss y P htss]
  exact mul_le_mul_of_nonneg_right hrsq htss.le

/-- The between-cell energy carried by any subfamily of levels is at most the total. -/
theorem subset_between_energy_le (y : ι → ℝ) (P : ι → α) {S : Finset α}
    (hS : S ⊆ univ.image P) :
    ∑ c ∈ S, ((cell P c).card : ℝ) * (cellMean y P c - mean y) ^ 2 ≤ betweenSS y P :=
  Finset.sum_le_sum_of_subset_of_nonneg hS (fun c _ _ => by positivity)

theorem cell_card_pos {P : ι → α} {c : α} (hc : c ∈ univ.image P) :
    (0 : ℝ) < ((cell P c).card : ℝ) := by
  have hne := cell_card_ne_zero (f := P) (a := c) hc
  have hpos : 0 < (cell P c).card := Nat.pos_of_ne_zero (by exact_mod_cast hne)
  exact_mod_cast hpos

/-- **The multi-cell contrast ceiling.**  If the class of *all* functions of the feature `P`
explains at most a fraction `ρ` of the variance, then every weighted contrast of cell means
obeys a Cauchy–Schwarz ceiling driven by `ρ`.  With `Σ w = 0` the left side is a genuine
contrast (invariant under shifting the response by a constant). -/
theorem multicell_contrast_le_of_rsq {y : ι → ℝ} {P : ι → α} {ρ : ℝ} {S : Finset α}
    {w : α → ℝ} (hS : S ⊆ univ.image P) (htss : 0 < tss y)
    (hrsq : rsq y (measurableClass P) ≤ ρ) :
    (∑ c ∈ S, w c * (cellMean y P c - mean y)) ^ 2
      ≤ ρ * tss y * ∑ c ∈ S, (w c) ^ 2 / ((cell P c).card : ℝ) := by
  classical
  set d : α → ℝ := fun c => cellMean y P c - mean y with hd
  set r : α → ℝ := fun c => Real.sqrt ((cell P c).card : ℝ) with hr
  have hrpos : ∀ c ∈ S, 0 < r c := fun c hc => Real.sqrt_pos.2 (cell_card_pos (hS hc))
  have hrsq' : ∀ c ∈ S, r c ^ 2 = ((cell P c).card : ℝ) := by
    intro c hc
    rw [hr]
    exact Real.sq_sqrt (cell_card_pos (hS hc)).le
  -- Cauchy–Schwarz with the splitting `w = (w/r)·r`
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq S (fun c => w c / r c) (fun c => r c * d c)
  have hprod : ∑ c ∈ S, (w c / r c) * (r c * d c) = ∑ c ∈ S, w c * d c := by
    refine Finset.sum_congr rfl fun c hc => ?_
    have hne : r c ≠ 0 := (hrpos c hc).ne'
    field_simp
  have hleft : ∑ c ∈ S, (w c / r c) ^ 2 = ∑ c ∈ S, (w c) ^ 2 / ((cell P c).card : ℝ) := by
    refine Finset.sum_congr rfl fun c hc => ?_
    rw [div_pow, hrsq' c hc]
  have hright : ∑ c ∈ S, (r c * d c) ^ 2
      = ∑ c ∈ S, ((cell P c).card : ℝ) * (cellMean y P c - mean y) ^ 2 := by
    refine Finset.sum_congr rfl fun c hc => ?_
    rw [mul_pow, hrsq' c hc]
  rw [hprod, hleft, hright] at hCS
  have hnn : 0 ≤ ∑ c ∈ S, (w c) ^ 2 / ((cell P c).card : ℝ) :=
    Finset.sum_nonneg fun c hc => by positivity
  have henergy : ∑ c ∈ S, ((cell P c).card : ℝ) * (cellMean y P c - mean y) ^ 2 ≤ ρ * tss y :=
    le_trans (subset_between_energy_le y P hS) (betweenSS_le_of_rsq htss hrsq)
  calc (∑ c ∈ S, w c * d c) ^ 2
      ≤ (∑ c ∈ S, (w c) ^ 2 / ((cell P c).card : ℝ))
          * ∑ c ∈ S, ((cell P c).card : ℝ) * (cellMean y P c - mean y) ^ 2 := hCS
    _ ≤ (∑ c ∈ S, (w c) ^ 2 / ((cell P c).card : ℝ)) * (ρ * tss y) :=
        mul_le_mul_of_nonneg_left henergy hnn
    _ = ρ * tss y * ∑ c ∈ S, (w c) ^ 2 / ((cell P c).card : ℝ) := by ring

/-! ## Groups of cells: the form a criterion actually takes -/

/-- The number of sample points in a group of feature levels. -/
noncomputable def groupSize (P : ι → α) (A : Finset α) : ℝ :=
  ∑ c ∈ A, ((cell P c).card : ℝ)

/-- The response mean over a group of feature levels. -/
noncomputable def groupMean (y : ι → ℝ) (P : ι → α) (A : Finset α) : ℝ :=
  (∑ c ∈ A, ((cell P c).card : ℝ) * cellMean y P c) / groupSize P A

/-- **The group-gap ceiling.**  Any decision rule that reads the feature `P` sorts the
sample into a union of cells `A` and a disjoint union of cells `B`.  A recorded ceiling `ρ`
for the whole class of functions of `P` caps the separation the rule achieves:
`(M_A − M_B)² ≤ ρ·TSS·(1/N_A + 1/N_B)`. -/
theorem group_mean_gap_le_of_rsq {y : ι → ℝ} {P : ι → α} {ρ : ℝ} {A B : Finset α}
    (hA : A ⊆ univ.image P) (hB : B ⊆ univ.image P) (hAB : Disjoint A B)
    (hApos : 0 < groupSize P A) (hBpos : 0 < groupSize P B)
    (htss : 0 < tss y) (hrsq : rsq y (measurableClass P) ≤ ρ) :
    (groupMean y P A - groupMean y P B) ^ 2
      ≤ ρ * tss y * (1 / groupSize P A + 1 / groupSize P B) := by
  classical
  set NA : ℝ := groupSize P A with hNA
  set NB : ℝ := groupSize P B with hNB
  set w : α → ℝ := fun c =>
    if c ∈ A then ((cell P c).card : ℝ) / NA else -(((cell P c).card : ℝ) / NB) with hw
  have hSsub : A ∪ B ⊆ univ.image P := Finset.union_subset hA hB
  have hkey := multicell_contrast_le_of_rsq (y := y) (P := P) (ρ := ρ) (S := A ∪ B) (w := w)
    hSsub htss hrsq
  -- the contrast is exactly the group-mean gap
  have hBmem : ∀ c ∈ B, c ∉ A := fun c hc hcA => (Finset.disjoint_left.1 hAB hcA) hc
  have hNA0 : NA ≠ 0 := hApos.ne'
  have hNB0 : NB ≠ 0 := hBpos.ne'
  have hAsize : ∑ c ∈ A, ((cell P c).card : ℝ) = NA := by rw [hNA, groupSize]
  have hBsize : ∑ c ∈ B, ((cell P c).card : ℝ) = NB := by rw [hNB, groupSize]
  have hcontrast : ∑ c ∈ A ∪ B, w c * (cellMean y P c - mean y)
      = groupMean y P A - groupMean y P B := by
    rw [Finset.sum_union hAB]
    have hA' : ∑ c ∈ A, w c * (cellMean y P c - mean y)
        = (∑ c ∈ A, ((cell P c).card : ℝ) * cellMean y P c) / NA - mean y := by
      have hexp : ∑ c ∈ A, w c * (cellMean y P c - mean y)
          = (∑ c ∈ A, (((cell P c).card : ℝ) * cellMean y P c
              - ((cell P c).card : ℝ) * mean y)) / NA := by
        rw [Finset.sum_div]
        refine Finset.sum_congr rfl fun c hc => ?_
        simp only [hw, if_pos hc]
        ring
      have hcancel : NA * mean y / NA = mean y := by field_simp
      rw [hexp, Finset.sum_sub_distrib, ← Finset.sum_mul, hAsize, sub_div, hcancel]
    have hB' : ∑ c ∈ B, w c * (cellMean y P c - mean y)
        = -((∑ c ∈ B, ((cell P c).card : ℝ) * cellMean y P c) / NB - mean y) := by
      have hexp : ∑ c ∈ B, w c * (cellMean y P c - mean y)
          = -((∑ c ∈ B, (((cell P c).card : ℝ) * cellMean y P c
              - ((cell P c).card : ℝ) * mean y)) / NB) := by
        rw [Finset.sum_div, ← Finset.sum_neg_distrib]
        refine Finset.sum_congr rfl fun c hc => ?_
        simp only [hw, if_neg (hBmem c hc)]
        ring
      have hcancel : NB * mean y / NB = mean y := by field_simp
      rw [hexp, Finset.sum_sub_distrib, ← Finset.sum_mul, hBsize, sub_div, hcancel]
    rw [hA', hB', groupMean, groupMean, ← hNA, ← hNB]
    ring
  -- and the Cauchy–Schwarz weight budget is exactly `1/N_A + 1/N_B`
  have hbudget : ∑ c ∈ A ∪ B, (w c) ^ 2 / ((cell P c).card : ℝ) = 1 / NA + 1 / NB := by
    rw [Finset.sum_union hAB]
    have hA' : ∑ c ∈ A, (w c) ^ 2 / ((cell P c).card : ℝ) = 1 / NA := by
      have hexp : ∀ c ∈ A, (w c) ^ 2 / ((cell P c).card : ℝ)
          = ((cell P c).card : ℝ) / NA ^ 2 := by
        intro c hc
        have hpos := cell_card_pos (hA hc)
        simp only [hw, if_pos hc]
        field_simp
      rw [Finset.sum_congr rfl hexp, ← Finset.sum_div, hAsize,
        div_eq_div_iff (by positivity) hNA0]
      ring
    have hB' : ∑ c ∈ B, (w c) ^ 2 / ((cell P c).card : ℝ) = 1 / NB := by
      have hexp : ∀ c ∈ B, (w c) ^ 2 / ((cell P c).card : ℝ)
          = ((cell P c).card : ℝ) / NB ^ 2 := by
        intro c hc
        have hpos := cell_card_pos (hB hc)
        simp only [hw, if_neg (hBmem c hc)]
        field_simp
      rw [Finset.sum_congr rfl hexp, ← Finset.sum_div, hBsize,
        div_eq_div_iff (by positivity) hNB0]
      ring
    rw [hA', hB']
  rw [hcontrast, hbudget] at hkey
  exact hkey

/-- **Experiment 566, stage B: the group-gap certificate.**  With the recorded ceiling
`R² ≤ 0.0785` for every function of the L-mass, no rule that reads the L-mass can split the
moduli into two groups whose mean deviations differ by more than
`0.0785·TSS·(1/N_A + 1/N_B)` in square. -/
theorem exp566_group_gap_ceiling {y : ι → ℝ} {P : ι → α} {A B : Finset α}
    (hA : A ⊆ univ.image P) (hB : B ⊆ univ.image P) (hAB : Disjoint A B)
    (hApos : 0 < groupSize P A) (hBpos : 0 < groupSize P B)
    (htss : 0 < tss y) (hrsq : rsq y (measurableClass P) ≤ 0.0785) :
    (groupMean y P A - groupMean y P B) ^ 2
      ≤ 0.0785 * tss y * (1 / groupSize P A + 1 / groupSize P B) :=
  group_mean_gap_le_of_rsq hA hB hAB hApos hBpos htss hrsq

/-! ## Sharpness of the cell-gap constant -/

/-- The two-cell energy identity at the pooled mean: the inequality `two_cell_energy_le`
becomes an equality precisely at the pooled mean. -/
theorem two_cell_energy_eq_pooled {na nb ma mb : ℝ} (hna : 0 < na) (hnb : 0 < nb) :
    na * (ma - (na * ma + nb * mb) / (na + nb)) ^ 2
        + nb * (mb - (na * ma + nb * mb) / (na + nb)) ^ 2
      = (na * nb / (na + nb)) * (ma - mb) ^ 2 := by
  have hsum : (0 : ℝ) < na + nb := by linarith
  field_simp
  ring

/-- Summing fiberwise over the two cells of a two-valued feature. -/
theorem sum_two_cells (F : ι → ℝ) (P : ι → α) {a b : α} (hab : a ≠ b)
    (himg : univ.image P = {a, b}) :
    ∑ i, F i = ∑ i ∈ cell P a, F i + ∑ i ∈ cell P b, F i := by
  classical
  have hmaps : ∀ i ∈ (univ : Finset ι), P i ∈ univ.image P :=
    fun i _ => Finset.mem_image_of_mem P (Finset.mem_univ i)
  have hpart := Finset.sum_fiberwise_of_maps_to hmaps F
  rw [← hpart, himg, Finset.sum_pair hab]
  rfl

/-- A response that is a function of the feature has zero within-cell energy. -/
theorem withinSS_eq_zero_of_measurable (y : ι → ℝ) (P : ι → α) (g : α → ℝ)
    (hy : ∀ i, y i = g (P i)) : withinSS y P = 0 := by
  classical
  have hmem : (fun i => g (P i)) ∈ measurableClass P := ⟨g, rfl⟩
  have hle := rss_le_of_mem (y := y) hmem
  have hzero : sqNorm (y - fun i => g (P i)) = 0 := by
    simp [sqNorm, hy]
  rw [hzero, rss_measurableClass] at hle
  exact le_antisymm hle (withinSS_nonneg y P)

/-- **Sharpness of the cell-gap ceiling.**  For a two-valued feature on which the response
is constant along cells, the pairwise ceiling of `cell_mean_gap_le_of_rsq` is attained
exactly, with `ρ = R² = 1`.  Hence the constant in the ceiling cannot be improved. -/
theorem two_cell_gap_eq_of_measurable {y : ι → ℝ} {P : ι → α} {a b : α} (hab : a ≠ b)
    (himg : univ.image P = {a, b}) (g : α → ℝ) (hy : ∀ i, y i = g (P i)) :
    (cellMean y P a - cellMean y P b) ^ 2
      = tss y * (1 / ((cell P a).card : ℝ) + 1 / ((cell P b).card : ℝ)) := by
  classical
  have hamem : a ∈ univ.image P := by rw [himg]; simp
  have hbmem : b ∈ univ.image P := by rw [himg]; simp
  set na : ℝ := ((cell P a).card : ℝ) with hna'
  set nb : ℝ := ((cell P b).card : ℝ) with hnb'
  have hna : 0 < na := cell_card_pos hamem
  have hnb : 0 < nb := cell_card_pos hbmem
  have hna0 : na ≠ 0 := hna.ne'
  have hnb0 : nb ≠ 0 := hnb.ne'
  set ma : ℝ := cellMean y P a with hma
  set mb : ℝ := cellMean y P b with hmb
  -- the two cells exhaust the sample
  have hcard : (Fintype.card ι : ℝ) = na + nb := by
    have := sum_two_cells (fun _ => (1 : ℝ)) P hab himg
    simpa [Finset.sum_const, Finset.card_univ, hna', hnb'] using this
  have hsum : ∑ i, y i = na * ma + nb * mb := by
    have h := sum_two_cells y P hab himg
    have hAsum : ∑ i ∈ cell P a, y i = na * ma := by
      rw [hma, cellMean, ← hna']
      field_simp
    have hBsum : ∑ i ∈ cell P b, y i = nb * mb := by
      rw [hmb, cellMean, ← hnb']
      field_simp
    rw [h, hAsum, hBsum]
  have hmean : mean y = (na * ma + nb * mb) / (na + nb) := by
    rw [mean, hsum, hcard]
  -- with no within-cell energy, the total energy is the between-cell energy
  have hwithin : withinSS y P = 0 := withinSS_eq_zero_of_measurable y P g hy
  have hbetween : betweenSS y P = na * (ma - mean y) ^ 2 + nb * (mb - mean y) ^ 2 := by
    rw [betweenSS, himg, Finset.sum_pair hab, ← hna', ← hnb', ← hma, ← hmb]
  have htss : tss y = na * (ma - mean y) ^ 2 + nb * (mb - mean y) ^ 2 := by
    rw [tss_eq_withinSS_add_betweenSS y P, hwithin, hbetween, zero_add]
  rw [htss, hmean, two_cell_energy_eq_pooled hna hnb]
  field_simp
  ring

/-! ## A perturbation control with nonzero power -/

variable [Nonempty ι]

/-- Every single class contributes a lower bound to the primary readout. -/
theorem le_maxDev (c : ι → ℝ) {E : ℝ} (hE : 0 < E) (a₀ : ι) :
    |c a₀ - E| / Real.sqrt E ≤ maxDev c E := by
  have hsqrt : 0 < Real.sqrt E := Real.sqrt_pos.2 hE
  have hle : |c a₀ - E| ≤ univ.sup' univ_nonempty fun a => |c a - E| :=
    Finset.le_sup' (fun a => |c a - E|) (mem_univ a₀)
  rw [maxDev]
  gcongr

/-- **The additive control can reject: primary readout.**  If the perturbation direction is
nonzero at some class, then for all large enough amplitudes the perturbed maximal deviation
strictly exceeds the observed one. -/
theorem maxDev_perturb_gt {c w : ι → ℝ} {E : ℝ} (hE : 0 < E) {a₀ : ι} (hw : w a₀ ≠ 0) :
    ∃ t₀ > 0, ∀ t ≥ t₀, maxDev c E < maxDev (fun a => c a + t * w a) E := by
  classical
  have hsqrt : 0 < Real.sqrt E := Real.sqrt_pos.2 hE
  set M : ℝ := univ.sup' univ_nonempty fun a => |c a - E| with hM
  have hM0 : 0 ≤ M := le_trans (abs_nonneg _) (Finset.le_sup' (fun a => |c a - E|) (mem_univ a₀))
  have hwpos : 0 < |w a₀| := abs_pos.2 hw
  refine ⟨(2 * M + 1) / |w a₀|, by positivity, fun t ht => ?_⟩
  have ht0 : 0 < t := lt_of_lt_of_le (by positivity) ht
  have htw : 2 * M + 1 ≤ t * |w a₀| := by
    rw [ge_iff_le, div_le_iff₀ hwpos] at ht
    exact ht
  -- the perturbed field is far from `E` at the class `a₀`
  have htri : |t * w a₀| ≤ |c a₀ + t * w a₀ - E| + |c a₀ - E| :=
    calc |t * w a₀| = |(c a₀ + t * w a₀ - E) + -(c a₀ - E)| := by congr 1; ring
      _ ≤ |c a₀ + t * w a₀ - E| + |-(c a₀ - E)| := abs_add_le _ _
      _ = |c a₀ + t * w a₀ - E| + |c a₀ - E| := by rw [abs_neg]
  have habs : |t * w a₀| = t * |w a₀| := by
    rw [abs_mul, abs_of_pos ht0]
  have hca : |c a₀ - E| ≤ M := Finset.le_sup' (fun a => |c a - E|) (mem_univ a₀)
  have hbig : M + 1 ≤ |c a₀ + t * w a₀ - E| := by
    rw [habs] at htri
    linarith
  have hlow : |c a₀ + t * w a₀ - E| / Real.sqrt E ≤ maxDev (fun a => c a + t * w a) E :=
    le_maxDev (fun a => c a + t * w a) hE a₀
  have hstrict : M / Real.sqrt E < |c a₀ + t * w a₀ - E| / Real.sqrt E := by
    have hlt : M < |c a₀ + t * w a₀ - E| := by linarith
    gcongr
  calc maxDev c E = M / Real.sqrt E := by rw [maxDev, hM]
    _ < |c a₀ + t * w a₀ - E| / Real.sqrt E := hstrict
    _ ≤ maxDev (fun a => c a + t * w a) E := hlow

omit [Nonempty ι] in
/-- The `χ²` readout of a perturbed field is an explicit quadratic in the amplitude. -/
theorem chiSq_perturb (c w : ι → ℝ) (E t : ℝ) :
    chiSq (fun a => c a + t * w a) E
      = chiSq c E + (2 * t * (∑ a, (c a - E) * w a) + t ^ 2 * ∑ a, (w a) ^ 2) / E := by
  have hexp : ∀ a : ι, (c a + t * w a - E) ^ 2
      = (c a - E) ^ 2 + (2 * t * ((c a - E) * w a) + t ^ 2 * (w a) ^ 2) := fun a => by ring
  have hsum : ∑ a, (c a + t * w a - E) ^ 2
      = (∑ a, (c a - E) ^ 2)
        + (2 * t * (∑ a, (c a - E) * w a) + t ^ 2 * ∑ a, (w a) ^ 2) := by
    simp only [hexp, Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [chiSq, chiSq, hsum, add_div]

omit [Nonempty ι] in
/-- **The additive control can reject: secondary readout.** -/
theorem chiSq_perturb_gt {c w : ι → ℝ} {E : ℝ} (hE : 0 < E) {a₀ : ι} (hw : w a₀ ≠ 0) :
    ∃ t₀ > 0, ∀ t ≥ t₀, chiSq c E < chiSq (fun a => c a + t * w a) E := by
  classical
  set A : ℝ := ∑ a, (w a) ^ 2 with hA
  set B : ℝ := ∑ a, (c a - E) * w a with hB
  have hApos : 0 < A := by
    have hterm : (0 : ℝ) < (w a₀) ^ 2 := by positivity
    have hle : (w a₀) ^ 2 ≤ A :=
      Finset.single_le_sum (f := fun a => (w a) ^ 2) (fun a _ => by positivity) (mem_univ a₀)
    linarith
  refine ⟨(2 * |B| + 1) / A, by positivity, fun t ht => ?_⟩
  have ht0 : 0 < t := lt_of_lt_of_le (by positivity) ht
  have htA : 2 * |B| + 1 ≤ t * A := by
    rw [ge_iff_le, div_le_iff₀ hApos] at ht
    exact ht
  have hBle : -B ≤ |B| := neg_le_abs B
  have hquad : 0 < 2 * t * B + t ^ 2 * A := by
    have hfac : 2 * t * B + t ^ 2 * A = t * (2 * B + t * A) := by ring
    rw [hfac]
    have : 0 < 2 * B + t * A := by linarith
    positivity
  have hpos : 0 < (2 * t * B + t ^ 2 * A) / E := div_pos hquad hE
  rw [chiSq_perturb c w E t, ← hA, ← hB]
  linarith

/-- **The repaired control is not vacuous.**  In exact contrast with
`permutation_control_vacuous` — where the p-value is identically `1` and the power is zero —
the additive perturbation family strictly increases *both* registered readouts once its
amplitude is large enough, in any direction `w` that is nonzero somewhere.  A control built
from this family can therefore reject. -/
theorem perturbation_control_nonvacuous {c w : ι → ℝ} {E : ℝ} (hE : 0 < E) {a₀ : ι}
    (hw : w a₀ ≠ 0) :
    ∃ t₀ > 0, ∀ t ≥ t₀,
      maxDev c E < maxDev (fun a => c a + t * w a) E ∧
        chiSq c E < chiSq (fun a => c a + t * w a) E := by
  obtain ⟨t₁, ht₁, h₁⟩ := maxDev_perturb_gt (c := c) (w := w) hE hw
  obtain ⟨t₂, ht₂, h₂⟩ := chiSq_perturb_gt (c := c) (w := w) hE hw
  refine ⟨max t₁ t₂, lt_of_lt_of_le ht₁ (le_max_left _ _), fun t ht => ?_⟩
  exact ⟨h₁ t (le_trans (le_max_left _ _) ht), h₂ t (le_trans (le_max_right _ _) ht)⟩

end Ma1Effectivity