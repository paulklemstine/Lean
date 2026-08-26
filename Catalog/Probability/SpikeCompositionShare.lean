import Mathlib
import Probability.SpikeBandComposition

/-!
# How much of the flat excess must be composition?

`Catalog/Probability/SpikeCompositionExtremal.lean` bounds the composition
factor from above and below.  This file closes the remaining open half of future
direction 2: a *lower* bound on the share of the flat-referenced excess that is
attributable to band composition rather than to a within-band rate elevation.

The mechanism is the exact identity of `Spike.Band`,
`flatExcess = bandExcess + composition`, together with the size-matched
information `k i ≤ R · p i · n i` (the matched within-band rate ratio is at most
`R`).  Writing `E := p0 · ∑ n i` for the flat-null expectation, the two combine
into

`flatExcess ≤ R · composition + (R - 1) · E`   (`flatExcess_le_composition`),

so that

`composition ≥ (flatExcess - (R - 1) · E) / R`  (`composition_lower_bound`).

Interpretation: once the matched ratio `R` is close to `1`, essentially *all* of
the flat excess has to be composition; a rate-layer explanation would require a
matched ratio far above the measured one.  The round-85 numbers are instantiated
in `round85_composition_share`: with `R = 1.097`, a flat-null expectation of
`959.4` and a flat excess of at least `604.76`, the composition term is at least
`466`, i.e. at least `77 %` of the whole excess — quantitatively the "~4/5 of
the spike is band composition" reading, now as a theorem rather than a
descriptive statistic.

The complementary sharpness statement `exists_matched_all_composition` shows the
bound is not vacuous: at `R = 1` it is attained, with composition equal to the
entire flat excess.
-/

namespace Spike.Band.Share

open Spike.Band

variable {ι : Type*} {S : Finset ι} {k n p : ι → ℝ} {p0 : ℝ}

/-- The composition term in aggregate form. -/
theorem composition_eq_sub :
    composition S n p p0 = (∑ i ∈ S, p i * n i) - p0 * ∑ i ∈ S, n i := by
  rw [composition, Finset.mul_sum, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **The size-matched bound transfers to the excess.**  If every band satisfies
the matched bound `k i ≤ R · p i · n i` then the flat-referenced excess is
controlled by the composition term and the flat-null expectation alone. -/
theorem flatExcess_le_composition {R : ℝ}
    (hk : ∀ i ∈ S, k i ≤ R * (p i * n i)) :
    flatExcess S k n p0 ≤ R * composition S n p p0 + (R - 1) * (p0 * ∑ i ∈ S, n i) := by
  have hsum : ∑ i ∈ S, k i ≤ R * ∑ i ∈ S, p i * n i := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum hk
  rw [flatExcess, composition_eq_sub]
  ring_nf
  ring_nf at hsum
  linarith

/-- **Lower bound on the composition term.**  With a matched within-band ratio at
most `R > 0`, the composition term carries all of the flat excess except at most
`(R - 1)` times the flat-null expectation. -/
theorem composition_lower_bound {R : ℝ} (hR : 0 < R)
    (hk : ∀ i ∈ S, k i ≤ R * (p i * n i)) :
    (flatExcess S k n p0 - (R - 1) * (p0 * ∑ i ∈ S, n i)) / R ≤ composition S n p p0 := by
  have h := flatExcess_le_composition (S := S) (k := k) (n := n) (p := p) (p0 := p0) hk
  rw [div_le_iff₀ hR]
  nlinarith

/-- **Perfectly matched bands: the excess is composition in full.**  At `R = 1`
the lower bound is attained and states that the composition term is the entire
flat excess. -/
theorem composition_eq_flatExcess_of_matched (hk : ∀ i ∈ S, k i = p i * n i) :
    composition S n p p0 = flatExcess S k n p0 :=
  (flatExcess_eq_composition_of_matched S k n p p0 hk).symm

/-- Sharpness: a configuration in which the matched ratio is exactly `1` and the
whole flat excess is composition, with a strictly positive excess. -/
theorem exists_matched_all_composition :
    ∃ (k n p : Fin 2 → ℝ) (p0 : ℝ),
      (∀ i ∈ Finset.univ, k i = p i * n i) ∧
      0 < flatExcess Finset.univ k n p0 ∧
      composition Finset.univ n p p0 = flatExcess Finset.univ k n p0 := by
  refine ⟨![15, 0], ![100, 0], ![0.15, 0], 0.1, ?_, ?_, ?_⟩
  · intro i _; fin_cases i <;> norm_num
  · simp only [flatExcess, Fin.sum_univ_two]
    norm_num
  · apply composition_eq_flatExcess_of_matched
    intro i _; fin_cases i <;> norm_num

/-- **The round-85 instantiation.**  With the reported matched ratio bound
`R = 1.097`, a flat-null expectation `p0 · ∑ n = 959.4` and a measured flat
excess of at least `604.76`, the composition term is at least `466` and accounts
for at least `77 %` of the flat excess.  No positional or rate-layer component
is needed for the remainder. -/
theorem round85_composition_share
    (hk : ∀ i ∈ S, k i ≤ 1.097 * (p i * n i))
    (hexp : 0.1 * ∑ i ∈ S, n i = 959.4)
    (hE : 604.76 ≤ flatExcess S k n 0.1) :
    466 ≤ composition S n p 0.1 ∧
      0.77 * flatExcess S k n 0.1 ≤ composition S n p 0.1 := by
  have h := flatExcess_le_composition (S := S) (k := k) (n := n) (p := p) (p0 := 0.1) hk
  rw [hexp] at h
  constructor <;> nlinarith

end Spike.Band.Share