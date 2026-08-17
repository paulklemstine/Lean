import Cryptography.LatticePointEnumerator

/-!
# Recovering the Fourier transform of an indicator from lattice sums

This file develops the *weighted* form of the Gauss–Weyl counting theorem of
`Cryptography.LatticePointEnumerator`: for a bounded Jordan measurable set `P ⊆ ℝ^d` and a
bounded continuous weight `g`,

`t^{-d} · Σ_{k ∈ tP ∩ ℤ^d} g(k/t) → ∫ 1_P · g`  as `t → ∞`.

Specialising `g` to a character `x ↦ exp(-2πi⟨ξ, x⟩)` shows that the *Fourier transform of the
indicator function* of `P` is recovered, at every frequency `ξ`, as a limit of exponential sums
over the counted lattice points.  This is the analytic content of the "periodic point-counting
function whose Fourier coefficients recover the Fourier transform of the indicator function"
used in the paper.

## Main results

* `LatticeEnumerator.integral_stepFun` : the exact identity
  `∫ 1_{A_t}(x) g(⌊tx⌋/t) dx = t^{-d} Σ_{k ∈ tP ∩ ℤ^d} g(k/t)`.
* `LatticeEnumerator.tendsto_weightedSum` : the weighted counting theorem.
* `LatticeEnumerator.tendsto_fourierSum` : recovery of `∫ 1_P(x) e^{-2πi⟨ξ,x⟩} dx` from the
  lattice exponential sums.
* `LatticeEnumerator.weightedSum_one_eq_dilCount` : consistency check — for `g = 1` the weighted
  theorem specialises to `L_P(t)/t^d → vol P`.
-/

noncomputable section

open MeasureTheory Metric Set Filter Topology Complex

namespace LatticeEnumerator

variable {d : ℕ}

/-- The lattice sum `Σ_{k ∈ tP ∩ ℤ^d} g(k/t)` of a weight `g` over the counted lattice
points. -/
def weightedSum (P : Set (Fin d → ℝ)) (t : ℝ) (g : (Fin d → ℝ) → ℂ) : ℂ :=
  ∑ᶠ k ∈ dilLattice P t, g (fun i => (k i : ℝ) / t)

lemma weightedSum_eq_finsetSum {P : Set (Fin d → ℝ)} {t : ℝ} (hfin : (dilLattice P t).Finite)
    (g : (Fin d → ℝ) → ℂ) :
    weightedSum P t g = ∑ k ∈ hfin.toFinset, g (fun i => (k i : ℝ) / t) := by
  rw [weightedSum, ← finsum_mem_coe_finset]
  simp [hfin.coe_toFinset]

/-- The step function `x ↦ 1_{A_t}(x) g(⌊tx⌋/t)` is the finite sum of the constant weights on
the cubes attached to the counted lattice points. -/
lemma stepFun_eq_sum {P : Set (Fin d → ℝ)} {t : ℝ} (ht : 0 < t)
    (hfin : (dilLattice P t).Finite) (g : (Fin d → ℝ) → ℂ) (x : Fin d → ℝ) :
    (approxSet P t).indicator (fun x => g (floorMap t x)) x
      = ∑ k ∈ hfin.toFinset, (cube t k).indicator (fun _ => g (fun i => (k i : ℝ) / t)) x := by
  by_cases hx : x ∈ approxSet P t
  · set k₀ : Fin d → ℤ := fun i => ⌊t * x i⌋ with hk₀
    have hxk₀ : x ∈ cube t k₀ := (mem_cube ht).2 fun i => rfl
    have hk₀mem : k₀ ∈ hfin.toFinset := by
      rw [hfin.mem_toFinset, mem_dilLattice]
      exact hx
    have hfl : floorMap t x = fun i => (k₀ i : ℝ) / t := rfl
    rw [Set.indicator_of_mem hx, hfl]
    rw [Finset.sum_eq_single k₀]
    · rw [Set.indicator_of_mem hxk₀]
    · intro k _ hne
      refine Set.indicator_of_notMem (fun hmem => hne ?_) _
      exact funext fun i => ((mem_cube ht).1 hmem i).symm
    · intro hnot
      exact absurd hk₀mem hnot
  · rw [Set.indicator_of_notMem hx, Finset.sum_eq_zero]
    intro k hk
    refine Set.indicator_of_notMem (fun hmem => hx ?_) _
    have hfl : floorMap t x = fun i => (k i : ℝ) / t := by
      funext i; simp [floorMap, (mem_cube ht).1 hmem i]
    rw [approxSet, Set.mem_setOf_eq, hfl]
    rw [hfin.mem_toFinset, mem_dilLattice] at hk
    exact hk

/-- **Exact identity for the weighted step integral.** -/
lemma integral_stepFun {P : Set (Fin d → ℝ)} (hb : Bornology.IsBounded P) {t : ℝ} (ht : 0 < t)
    (g : (Fin d → ℝ) → ℂ) :
    ∫ x, (approxSet P t).indicator (fun x => g (floorMap t x)) x
      = ((t ^ d)⁻¹ : ℝ) • weightedSum P t g := by
  have hfin := dilLattice_finite hb ht
  have hcube : ∀ k : Fin d → ℤ, (volume (cube t k)).toReal = (t ^ d)⁻¹ := by
    intro k
    rw [volume_cube ht, ENNReal.toReal_pow, ENNReal.toReal_ofReal (by positivity), div_pow,
      one_pow]
    ring
  have hint : ∀ k : Fin d → ℤ,
      Integrable ((cube t k).indicator (fun _ => g (fun i => (k i : ℝ) / t))) volume := by
    intro k
    rw [integrable_indicator_iff (measurableSet_cube t k)]
    refine integrableOn_const ?_
    rw [volume_cube ht]
    exact (ENNReal.pow_lt_top ENNReal.ofReal_lt_top).ne
  calc ∫ x, (approxSet P t).indicator (fun x => g (floorMap t x)) x
      = ∫ x, ∑ k ∈ hfin.toFinset,
          (cube t k).indicator (fun _ => g (fun i => (k i : ℝ) / t)) x := by
        exact integral_congr_ae (Filter.Eventually.of_forall (stepFun_eq_sum ht hfin g))
    _ = ∑ k ∈ hfin.toFinset,
          ∫ x, (cube t k).indicator (fun _ => g (fun i => (k i : ℝ) / t)) x :=
        integral_finset_sum _ fun k _ => hint k
    _ = ∑ k ∈ hfin.toFinset, ((t ^ d)⁻¹ : ℝ) • g (fun i => (k i : ℝ) / t) := by
        refine Finset.sum_congr rfl fun k _ => ?_
        rw [integral_indicator_const _ (measurableSet_cube t k), measureReal_def, hcube k]
    _ = ((t ^ d)⁻¹ : ℝ) • weightedSum P t g := by
        rw [weightedSum_eq_finsetSum hfin, Finset.smul_sum]

/-- The rounding maps converge pointwise to the identity as `t → ∞`. -/
lemma tendsto_floorMap (x : Fin d → ℝ) :
    Tendsto (fun t : ℝ => floorMap t x) atTop (𝓝 x) := by
  rw [tendsto_iff_dist_tendsto_zero]
  refine squeeze_zero' (Filter.Eventually.of_forall fun t => dist_nonneg)
    (g := fun t : ℝ => 1 / t) ?_ ?_
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht using dist_floorMap_le ht x
  · simpa [one_div] using tendsto_inv_atTop_zero

/-- **Weighted Gauss–Weyl theorem.**  For a bounded Jordan measurable set `P` and a bounded
continuous weight `g`, the normalised lattice sums converge to `∫ 1_P g`. -/
theorem tendsto_weightedSum {P : Set (Fin d → ℝ)} (hb : Bornology.IsBounded P)
    (hfr : volume (frontier P) = 0) {g : (Fin d → ℝ) → ℂ} (hg : Continuous g) {C : ℝ}
    (hC : ∀ x, ‖g x‖ ≤ C) :
    Tendsto (fun t : ℝ => ((t ^ d)⁻¹ : ℝ) • weightedSum P t g) atTop
      (𝓝 (∫ x, P.indicator g x)) := by
  obtain ⟨R, hR⟩ := (Metric.isBounded_iff_subset_closedBall 0).1 hb
  have hC0 : 0 ≤ C := le_trans (norm_nonneg _) (hC 0)
  set bound : (Fin d → ℝ) → ℝ := (closedBall (0 : Fin d → ℝ) (R + 1)).indicator fun _ => C
    with hbound
  have key : Tendsto (fun t : ℝ => ∫ x, (approxSet P t).indicator (fun x => g (floorMap t x)) x)
      atTop (𝓝 (∫ x, P.indicator g x)) := by
    refine tendsto_integral_filter_of_dominated_convergence bound ?_ ?_ ?_ ?_
    · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
      have hmeas : Measurable fun x : Fin d → ℝ => g (floorMap t x) := by
        refine hg.measurable.comp ?_
        refine measurable_pi_lambda _ fun i => ?_
        show Measurable fun x : Fin d → ℝ => ((⌊t * x i⌋ : ℤ) : ℝ) / t
        fun_prop
      exact (hmeas.indicator (measurableSet_approxSet hb ht)).aestronglyMeasurable
    · filter_upwards [eventually_ge_atTop (1 : ℝ)] with t ht
      filter_upwards with x
      have hsub := approxSet_subset_closedBall hR ht
      by_cases hx : x ∈ approxSet P t
      · rw [Set.indicator_of_mem hx, hbound, Set.indicator_of_mem (hsub hx)]
        exact hC _
      · rw [Set.indicator_of_notMem hx, hbound, norm_zero]
        exact Set.indicator_nonneg (fun _ _ => hC0) x
    · rw [hbound, integrable_indicator_iff measurableSet_closedBall]
      exact integrableOn_const measure_closedBall_lt_top.ne
    · have hae : ∀ᵐ x : (Fin d → ℝ), x ∉ frontier P := measure_eq_zero_iff_ae_notMem.1 hfr
      filter_upwards [hae] with x hx
      have hev := eventually_mem_approxSet_iff (P := P) hx
      by_cases hxP : x ∈ P
      · rw [Set.indicator_of_mem hxP]
        have hlim : Tendsto (fun t : ℝ => g (floorMap t x)) atTop (𝓝 (g x)) :=
          (hg.tendsto x).comp (tendsto_floorMap x)
        refine hlim.congr' ?_
        filter_upwards [hev] with t ht
        rw [Set.indicator_of_mem (ht.2 hxP)]
      · rw [Set.indicator_of_notMem hxP]
        refine tendsto_const_nhds.congr' ?_
        filter_upwards [hev] with t ht
        rw [Set.indicator_of_notMem (fun hmem => hxP (ht.1 hmem))]
  refine key.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
  exact integral_stepFun hb ht g

/-- The character `x ↦ exp(-2πi⟨ξ, x⟩)` on `ℝ^d`. -/
def latticeChar (ξ : Fin d → ℝ) (x : Fin d → ℝ) : ℂ :=
  Complex.exp (-(2 * Real.pi * Complex.I) * (∑ i, ξ i * x i : ℝ))

lemma continuous_latticeChar (ξ : Fin d → ℝ) : Continuous (latticeChar ξ) := by
  refine Complex.continuous_exp.comp ?_
  refine continuous_const.mul ?_
  exact Complex.continuous_ofReal.comp (continuous_finset_sum _ fun i _ =>
    continuous_const.mul (continuous_apply i))

lemma norm_latticeChar (ξ x : Fin d → ℝ) : ‖latticeChar ξ x‖ = 1 := by
  rw [latticeChar, Complex.norm_exp]
  norm_num

/-- **Fourier recovery.**  For a bounded Jordan measurable set `P`, the Fourier transform of
the indicator function of `P` at any frequency `ξ` is the limit of the normalised exponential
sums over the lattice points counted by the enumerator. -/
theorem tendsto_fourierSum {P : Set (Fin d → ℝ)} (hb : Bornology.IsBounded P)
    (hfr : volume (frontier P) = 0) (ξ : Fin d → ℝ) :
    Tendsto (fun t : ℝ => ((t ^ d)⁻¹ : ℝ) • weightedSum P t (latticeChar ξ)) atTop
      (𝓝 (∫ x, P.indicator (latticeChar ξ) x)) :=
  tendsto_weightedSum hb hfr (continuous_latticeChar ξ)
    (C := 1) fun x => le_of_eq (norm_latticeChar ξ x)

/-- Consistency: at the trivial weight the weighted sum is the enumerator itself, so the
weighted theorem contains the Gauss–Weyl counting theorem. -/
theorem weightedSum_one_eq_dilCount {P : Set (Fin d → ℝ)} (hb : Bornology.IsBounded P)
    {t : ℝ} (htp : 0 < t) :
    weightedSum P t (fun _ => (1 : ℂ)) = (dilCount P t : ℂ) := by
  have hfin := dilLattice_finite hb htp
  rw [weightedSum_eq_finsetSum hfin, Finset.sum_const, dilCount,
    Set.ncard_eq_toFinset_card _ hfin]
  simp

end LatticeEnumerator