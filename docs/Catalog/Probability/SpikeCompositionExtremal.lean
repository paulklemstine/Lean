import Mathlib
import Probability.SpikeBandComposition

/-!
# Extremal composition: how large a spike can pure band composition produce?

`Catalog/Probability/SpikeBandComposition.lean` proves the exact identity
`flatExcess = bandExcess + composition` and factorises the pooled rate ratio as
`(matched ratio) × (composition factor)`.  This file closes future direction 2
of `FUTURE_DIRECTIONS.md`: the *extremal* behaviour of the composition factor
over the exposure simplex.

Main results (`Spike.Band.Extremal`):

* `compositionFactor_le` / `compositionFactor_ge` : with band rates confined to
  `[pmin, pmax]`, the composition factor lies in `[pmin / p0, pmax / p0]`
  whatever the exposure allocation — the composition artifact is bounded by the
  *rate spread*, never by the sample size;
* `compositionFactor_eq_max_iff_concentrated` : the upper bound is attained
  exactly when all exposure sits on maximal-rate bands (a rigidity statement:
  any band carrying positive exposure must have `p i = pmax`);
* `exists_extremal_allocation` : the bound is attained, so it is sharp;
* `pooled_rateRatio_le_extremal` : the resulting universal ceiling
  `pooled ratio ≤ R * pmax / p0` on any size-matched analysis;
* `composition_le_spread` : the composition term itself is at most
  `(pmax - p0) * (total exposure)`;
* `round85_ceiling` : the reported numbers instantiated — with a flat null rate
  `p0 = 0.1`, band rates capped at `0.14924` and a matched within-band ratio
  capped at `1.097`, the pooled rate ratio cannot exceed `1.638`, which already
  covers the observed `1.637`.  No positional component is needed, and none can
  be inferred from the pooled ratio.

Interpretation: a "spike" of *any* size is reachable by composition alone once
the bands differ, but only in proportion to the rate spread — which the window
geometry (`Spike.size_residue_lt_96`) makes maximal, since the `bitlen ≥ 96`
band has mechanically zero first-decile rate.
-/

namespace Spike.Band.Extremal

open Spike.Band

variable {ι : Type*} (S : Finset ι) (n p : ι → ℝ) (p0 : ℝ)

/-- The composition factor: the band-referenced expectation divided by the flat
expectation.  This is the multiplicative form of `Spike.Band.composition`. -/
noncomputable def compositionFactor : ℝ := (∑ i ∈ S, p i * n i) / (p0 * ∑ i ∈ S, n i)

variable {S n p p0}

/-- **Upper extremal bound.**  If every band rate is at most `pmax` then the
composition factor is at most `pmax / p0`, for every exposure allocation. -/
theorem compositionFactor_le {pmax : ℝ} (hp0 : 0 < p0) (hn : ∀ i ∈ S, 0 ≤ n i)
    (hpmax : ∀ i ∈ S, p i ≤ pmax) (hpos : 0 < ∑ i ∈ S, n i) :
    compositionFactor S n p p0 ≤ pmax / p0 := by
  have hnum : ∑ i ∈ S, p i * n i ≤ pmax * ∑ i ∈ S, n i := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun i hi => mul_le_mul_of_nonneg_right (hpmax i hi) (hn i hi)
  have h1 : (∑ i ∈ S, p i * n i) / (p0 * ∑ i ∈ S, n i)
      ≤ (pmax * ∑ i ∈ S, n i) / (p0 * ∑ i ∈ S, n i) := by gcongr
  calc compositionFactor S n p p0
      ≤ (pmax * ∑ i ∈ S, n i) / (p0 * ∑ i ∈ S, n i) := h1
    _ = pmax / p0 := by
        rw [mul_comm p0, mul_comm pmax, mul_div_mul_left _ _ (ne_of_gt hpos)]

/-- **Lower extremal bound.**  Symmetrically, band rates bounded below by `pmin`
force the composition factor to be at least `pmin / p0`. -/
theorem compositionFactor_ge {pmin : ℝ} (hp0 : 0 < p0) (hn : ∀ i ∈ S, 0 ≤ n i)
    (hpmin : ∀ i ∈ S, pmin ≤ p i) (hpos : 0 < ∑ i ∈ S, n i) :
    pmin / p0 ≤ compositionFactor S n p p0 := by
  have hnum : pmin * ∑ i ∈ S, n i ≤ ∑ i ∈ S, p i * n i := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun i hi => mul_le_mul_of_nonneg_right (hpmin i hi) (hn i hi)
  have h1 : (pmin * ∑ i ∈ S, n i) / (p0 * ∑ i ∈ S, n i)
      ≤ (∑ i ∈ S, p i * n i) / (p0 * ∑ i ∈ S, n i) := by gcongr
  calc pmin / p0 = (pmin * ∑ i ∈ S, n i) / (p0 * ∑ i ∈ S, n i) := by
        rw [mul_comm p0, mul_comm pmin, mul_div_mul_left _ _ (ne_of_gt hpos)]
    _ ≤ compositionFactor S n p p0 := h1

/-- **Rigidity of the extremal allocation.**  The upper bound `pmax / p0` is
attained only if every band carrying positive exposure has the maximal rate:
an extremal composition spike is necessarily concentrated. -/
theorem compositionFactor_eq_max_iff_concentrated {pmax : ℝ} (hp0 : 0 < p0)
    (hn : ∀ i ∈ S, 0 ≤ n i) (hpmax : ∀ i ∈ S, p i ≤ pmax) (hpos : 0 < ∑ i ∈ S, n i)
    (heq : compositionFactor S n p p0 = pmax / p0) :
    ∀ i ∈ S, 0 < n i → p i = pmax := by
  have hsum : ∑ i ∈ S, p i * n i = pmax * ∑ i ∈ S, n i := by
    rw [compositionFactor] at heq
    field_simp at heq
    nlinarith [heq]
  have hzero : ∑ i ∈ S, (pmax - p i) * n i = 0 := by
    have : ∑ i ∈ S, (pmax - p i) * n i = pmax * (∑ i ∈ S, n i) - ∑ i ∈ S, p i * n i := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun i _ => by ring
    rw [this, hsum]
    ring
  have hterm : ∀ i ∈ S, (pmax - p i) * n i = 0 := by
    refine (Finset.sum_eq_zero_iff_of_nonneg ?_).mp hzero
    intro i hi
    exact mul_nonneg (by linarith [hpmax i hi]) (hn i hi)
  intro i hi hni
  have := hterm i hi
  rcases mul_eq_zero.mp this with h | h
  · linarith
  · exact absurd h (ne_of_gt hni)

/-- **Sharpness.**  A two-band allocation putting all exposure on the maximal
band realises the extremal composition factor `pmax / p0` exactly. -/
theorem exists_extremal_allocation (pmax p0 : ℝ) :
    ∃ n p : Fin 2 → ℝ, (∀ i, 0 ≤ n i) ∧ (∀ i, p i ≤ pmax) ∧
      0 < ∑ i ∈ Finset.univ, n i ∧
      compositionFactor Finset.univ n p p0 = pmax / p0 := by
  refine ⟨![1, 0], ![pmax, pmax], ?_, ?_, ?_, ?_⟩
  · intro i; fin_cases i <;> norm_num
  · intro i; fin_cases i <;> simp
  · simp [Fin.sum_univ_two]
  · simp only [compositionFactor, Fin.sum_univ_two]
    norm_num

/-- **Universal ceiling for a size-matched analysis.**  If every band satisfies
the matched bound `k i ≤ R * p i * n i` with `R ≥ 0` and every band rate is at
most `pmax`, the pooled (flat-referenced) rate ratio never exceeds
`R * pmax / p0`. -/
theorem pooled_rateRatio_le_extremal {k : ι → ℝ} {R pmax : ℝ} (hp0 : 0 < p0) (hR : 0 ≤ R)
    (hk : ∀ i ∈ S, k i ≤ R * (p i * n i)) (hn : ∀ i ∈ S, 0 ≤ n i)
    (hpmax : ∀ i ∈ S, p i ≤ pmax) (hpos : 0 < ∑ i ∈ S, n i) :
    (∑ i ∈ S, k i) / (p0 * ∑ i ∈ S, n i) ≤ R * (pmax / p0) := by
  have h1 := pooled_rateRatio_le S k n p p0 R hp0 hk hpos
  have h2 := compositionFactor_le (S := S) (n := n) (p := p) (p0 := p0) (pmax := pmax)
    hp0 hn hpmax hpos
  refine le_trans h1 ?_
  exact mul_le_mul_of_nonneg_left h2 hR

/-- **The additive form.**  The composition term is bounded by the rate spread
times the total exposure — it cannot be inflated by sample size alone. -/
theorem composition_le_spread {pmax : ℝ} (hn : ∀ i ∈ S, 0 ≤ n i)
    (hpmax : ∀ i ∈ S, p i ≤ pmax) :
    composition S n p p0 ≤ (pmax - p0) * ∑ i ∈ S, n i := by
  rw [composition, Finset.mul_sum]
  exact Finset.sum_le_sum fun i hi =>
    mul_le_mul_of_nonneg_right (by linarith [hpmax i hi]) (hn i hi)

/-- **The round-85 ceiling, instantiated.**  With a flat null rate `p0 = 0.1`,
band rates capped at `0.14924` and a matched within-band ratio capped at
`1.097`, the pooled rate ratio cannot exceed `1.638` — the observed `1.637` is
inside the ceiling produced by composition and matched rate alone. -/
theorem round85_ceiling {k : ι → ℝ} {R : ℝ} (hR : 0 ≤ R) (hR' : R ≤ 1.097)
    (hk : ∀ i ∈ S, k i ≤ R * (p i * n i)) (hn : ∀ i ∈ S, 0 ≤ n i)
    (hpmax : ∀ i ∈ S, p i ≤ 0.14924) (hpos : 0 < ∑ i ∈ S, n i) :
    (∑ i ∈ S, k i) / (0.1 * ∑ i ∈ S, n i) ≤ 1.638 := by
  have h := pooled_rateRatio_le_extremal (S := S) (n := n) (p := p) (p0 := 0.1)
    (k := k) (R := R) (pmax := 0.14924) (by norm_num) hR hk hn hpmax hpos
  have hnum : R * ((0.14924 : ℝ) / 0.1) ≤ 1.638 := by
    have : (0.14924 : ℝ) / 0.1 = 1.4924 := by norm_num
    rw [this]
    nlinarith
  linarith

end Spike.Band.Extremal