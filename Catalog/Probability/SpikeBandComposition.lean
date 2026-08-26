import Mathlib

/-!
# Composition versus rate: exact accounting for a stratified edge excess

Companion to `Catalog/Probability/SpikeInclusionGeometry.lean`.  There we proved
that the first decile of the search window is, by exact arithmetic, a pure
tiny-`v` stratum.  Here we prove the statistical consequence: an excess measured
against a *flat* (size-blind) null splits **exactly** into

* a within-band *rate* term, and
* a *composition* term produced by the heterogeneity of band-specific rates.

The main identity is `Spike.Band.flatExcess_eq`:

`flatExcess = bandExcess + composition`,

with the two immediate boundary readings

* `flatExcess_eq_composition_of_matched` : if every band is size-matched
  (`k i = p i * n i`, i.e. within-band rate ratio `1`), the *entire* flat excess
  is composition;
* `composition_eq_zero_of_homogeneous` : if all bands share the flat rate, the
  composition term vanishes and flat excess = band excess.  So a composition
  artifact requires genuine band heterogeneity — exactly what the inclusion
  geometry supplies.

Quantitatively, `pooled_rateRatio_le` factorises the pooled rate ratio as
`(matched rate ratio) × (composition factor)`, and `rate_ratio_1637` is the
arithmetic instance matching the reported numbers: a matched ratio of `1.097`
times a composition factor of `1.4924` already exceeds the observed pooled
ratio `1.637`, leaving nothing for a positional component.

Finally `exists_pure_composition_spike` is an explicit two-band configuration —
a mechanically-zero-rate band (`bitlen ≥ 96`) and a tiny-`v` band — in which
every within-band rate ratio is exactly `1`, the band-referenced excess is
exactly `0`, and yet the flat-referenced excess exceeds `500` with pooled rate
ratio above `1.6`.  This is a Simpson-type reversal in the exact configuration
forced by the window geometry.
-/

namespace Spike.Band

variable {ι : Type*} (S : Finset ι) (k n p : ι → ℝ) (p0 : ℝ)

/-- Excess of the observed edge counts over a *flat* null with common rate
`p0`. -/
def flatExcess : ℝ := (∑ i ∈ S, k i) - p0 * ∑ i ∈ S, n i

/-- Excess of the observed edge counts over the *band-referenced* null, whose
rate in band `i` is `p i`. -/
def bandExcess : ℝ := ∑ i ∈ S, (k i - p i * n i)

/-- The composition term: how much the band-referenced null already exceeds the
flat null, purely because of how exposure is distributed across bands. -/
def composition : ℝ := ∑ i ∈ S, (p i - p0) * n i

/-- **Exact excess decomposition.**  The flat-referenced excess is the sum of the
within-band rate excess and the composition term.  No assumptions. -/
theorem flatExcess_eq :
    flatExcess S k n p0 = bandExcess S k n p + composition S n p p0 := by
  simp only [flatExcess, bandExcess, composition, Finset.mul_sum, ← Finset.sum_add_distrib,
    ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl ?_
  intro i _
  ring

/-- If every band is size-matched (within-band rate ratio exactly `1`), then the
entire flat-referenced excess is composition. -/
theorem flatExcess_eq_composition_of_matched (h : ∀ i ∈ S, k i = p i * n i) :
    flatExcess S k n p0 = composition S n p p0 := by
  rw [flatExcess_eq S k n p p0]
  have : bandExcess S k n p = 0 := by
    simp only [bandExcess]
    exact Finset.sum_eq_zero fun i hi => by rw [h i hi]; ring
  rw [this, zero_add]

/-- If the bands are homogeneous (all band rates equal the flat rate) the
composition term vanishes: composition artifacts require heterogeneity. -/
theorem composition_eq_zero_of_homogeneous (h : ∀ i ∈ S, p i = p0) :
    composition S n p p0 = 0 :=
  Finset.sum_eq_zero fun i hi => by rw [h i hi]; ring

/-- Consequently, under homogeneity the flat and band-referenced excesses agree:
the flat null is only misleading when bands differ. -/
theorem flatExcess_eq_bandExcess_of_homogeneous (h : ∀ i ∈ S, p i = p0) :
    flatExcess S k n p0 = bandExcess S k n p := by
  rw [flatExcess_eq S k n p p0, composition_eq_zero_of_homogeneous S n p p0 h, add_zero]

/-- Quantitative control of the within-band term by the deviation of the
within-band rate ratios from `1`. -/
theorem abs_bandExcess_le (rr : ι → ℝ) (hk : ∀ i ∈ S, k i = rr i * (p i * n i))
    (hp : ∀ i ∈ S, 0 ≤ p i) (hn : ∀ i ∈ S, 0 ≤ n i) :
    |bandExcess S k n p| ≤ ∑ i ∈ S, |rr i - 1| * (p i * n i) := by
  have : bandExcess S k n p = ∑ i ∈ S, (rr i - 1) * (p i * n i) := by
    simp only [bandExcess]
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [hk i hi]; ring
  rw [this]
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) (le_of_eq ?_)
  refine Finset.sum_congr rfl fun i hi => ?_
  rw [abs_mul, abs_of_nonneg (mul_nonneg (hp i hi) (hn i hi))]

/-- **Pooled rate ratio factorises.**  If every band satisfies the matched bound
`k i ≤ R * (p i * n i)`, then the pooled (flat-referenced) rate ratio is at most
the matched ratio `R` times the composition factor
`(∑ p i n i) / (p0 ∑ n i)`. -/
theorem pooled_rateRatio_le (R : ℝ) (hp0 : 0 < p0)
    (hk : ∀ i ∈ S, k i ≤ R * (p i * n i))
    (hpos : 0 < ∑ i ∈ S, n i) :
    (∑ i ∈ S, k i) / (p0 * ∑ i ∈ S, n i)
      ≤ R * ((∑ i ∈ S, p i * n i) / (p0 * ∑ i ∈ S, n i)) := by
  have hden : 0 < p0 * ∑ i ∈ S, n i := mul_pos hp0 hpos
  have hnum : (∑ i ∈ S, k i) ≤ R * ∑ i ∈ S, p i * n i := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum hk
  rw [mul_div_assoc']
  gcongr

/-- Arithmetic instance of the factorisation with the reported numbers: the
matched within-band ratio `1.097` times the composition factor `1.4924`
reproduces the observed pooled ratio `1.637` to four decimal places.  Nothing
is left over for a positional component. -/
theorem rate_ratio_1637 : |(1.097 : ℝ) * 1.4924 - 1.637| ≤ 0.0002 := by
  rw [abs_le]
  constructor <;> norm_num

/-- Monotone form: any composition factor at most `1.4924` combined with a
matched ratio at most `1.097` keeps the pooled ratio below `1.638`. -/
theorem pooled_ratio_bound (R cf : ℝ) (hR : 0 ≤ R) (hR' : R ≤ 1.097)
    (hcf : cf ≤ 1.4924) : R * cf ≤ 1.638 := by
  nlinarith

/-- **Pure composition spike.**  An explicit two-band configuration in the shape
forced by the window geometry: band `0` carries `3000` tiny-`v` hits with
band rate `0.53`, band `1` carries `6594` large-`v` hits with mechanically zero
edge rate.  Every within-band rate ratio is exactly `1` (`k i = p i * n i`), so
the band-referenced excess is exactly `0`; yet against the flat null `p0 = 0.1`
the excess exceeds `500` and the pooled rate ratio exceeds `1.6`. -/
theorem exists_pure_composition_spike :
    ∃ (k n p : Fin 2 → ℝ) (p0 : ℝ),
      (∀ i ∈ Finset.univ, k i = p i * n i) ∧
      bandExcess Finset.univ k n p = 0 ∧
      600 ≤ flatExcess Finset.univ k n p0 ∧
      1.6 ≤ (∑ i ∈ Finset.univ, k i) / (p0 * ∑ i ∈ Finset.univ, n i) := by
  refine ⟨![1590, 0], ![3000, 6594], ![0.53, 0], 0.1, ?_, ?_, ?_, ?_⟩
  · intro i _
    fin_cases i <;> norm_num
  · simp [bandExcess, Fin.sum_univ_two]
    norm_num
  · simp [flatExcess, Fin.sum_univ_two]
    norm_num
  · simp [Fin.sum_univ_two]
    norm_num

end Spike.Band