import Mathlib.MeasureTheory.Measure.Hausdorff
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic

open Set Filter
open scoped MeasureTheory Topology

namespace PrimeFractal

/-- The proposed logarithmic realization of the primes in the real line. -/
def primeLogImage : Set ℝ :=
  {x | ∃ p : ℕ, Nat.Prime p ∧ x = 1 / Real.log (p : ℝ)}

/-- The logarithmic realization of the primes is countable. -/
theorem primeLogImage_countable : primeLogImage.Countable := by
  exact Set.countable_range (fun p : ℕ => 1 / Real.log p) |>.mono fun x hx =>
    hx.imp fun p hp => hp.2.symm

/-- Every countable subset of every emetric space has zero Hausdorff measure
in each positive dimension. Thus changing the metric on a countable set cannot produce positive
Hausdorff dimension in the usual Hausdorff sense. -/
theorem hausdorffMeasure_countable_eq_zero {X : Type*} [EMetricSpace X]
    [MeasurableSpace X] [BorelSpace X] {s : Set X} (hs : s.Countable) {d : ℝ} (hd : 0 < d) :
    MeasureTheory.Measure.hausdorffMeasure d s = 0 := by
  convert Set.Countable.measure_zero hs (μ := MeasureTheory.Measure.hausdorffMeasure d)
  apply_rules [MeasureTheory.Measure.noAtoms_hausdorff]

/-- Every positive-dimensional Hausdorff measure of the logarithmic prime set vanishes.
This contradicts the proposed positive Hausdorff dimension: countability, independently of
prime gaps or twin primes, forces dimension zero. -/
theorem hausdorffMeasure_primeLogImage_eq_zero {d : ℝ} (hd : 0 < d) :
    MeasureTheory.Measure.hausdorffMeasure d primeLogImage = 0 := by
  exact hausdorffMeasure_countable_eq_zero primeLogImage_countable hd

/-- The logarithmic prime set is nonempty: the prime `2` supplies a point. -/
theorem primeLogImage_nonempty : primeLogImage.Nonempty := by
  exact ⟨_, 2, Nat.prime_two, rfl⟩

/-- Zero-dimensional Hausdorff measure of the logarithmic prime set is nonzero. Together with
`hausdorffMeasure_primeLogImage_eq_zero`, this locates its Hausdorff critical exponent exactly at
zero, not at one and not above one. -/
theorem hausdorffMeasure_zero_primeLogImage_ne_zero :
    MeasureTheory.Measure.hausdorffMeasure 0 primeLogImage ≠ 0 := by
  exact ne_of_gt <| lt_of_lt_of_le (by norm_num)
    (MeasureTheory.Measure.one_le_hausdorffMeasure_zero_of_nonempty primeLogImage_nonempty)

/-- Distinct primes have distinct logarithmic coordinates, so the proposed distance really is
the pullback of Euclidean distance along an injective map. -/
theorem prime_log_coordinate_injective :
    Function.Injective (fun p : {n : ℕ // Nat.Prime n} ↦ 1 / Real.log (p.1 : ℝ)) := by
  norm_num [Function.Injective, Real.log_injOn_pos]
  exact fun p hp q hq h => Nat.cast_injective
    (Real.log_injOn_pos (Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hp.pos)
      (Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hq.pos) h)

/-- The exact proposed distance is Euclidean distance after applying the logarithmic coordinate. -/
theorem proposed_distance_eq (p q : {n : ℕ // Nat.Prime n}) :
    |1 / Real.log (p.1 : ℝ) - 1 / Real.log (q.1 : ℝ)| =
      dist (1 / Real.log (p.1 : ℝ)) (1 / Real.log (q.1 : ℝ)) := by
  rw [Real.dist_eq, abs_sub_comm]

end PrimeFractal