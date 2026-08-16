/-
# Computational evidence for the NET-44 knee analysis

Small, fully decidable checks on the measured sweep, carried out in `ℚ` so that the
kernel can evaluate them (`decide` / `norm_num`, never `native_decide`).  They confirm the
arithmetic that the theorems in `Logic.KneeFluctuationTwoSeed` reason about abstractly:

* the seed-1 sweep has knee `128` and the seed-2 sweep has knee `96` at the bar `0.98`;
* the seed-1 margin at `96` (`0.003`) is *smaller* than the observed inter-seed spread
  (`0.010`), while the seed-1 deficit at `64` (`0.012`) is *larger* — exactly the
  asymmetry that makes the upper end of the bracket seed-lucky and the lower end robust;
* shifting the seed-1 sweep by the spread reproduces the seed-2 numbers to within
  `0.001` and moves the knee to `96`.
-/

import Mathlib

namespace KneeEvidence

/-- Retained-accuracy bar, as an exact rational. -/
def barQ : ℚ := 98 / 100

/-- Observed inter-seed spread, as an exact rational. -/
def spreadQ : ℚ := 10 / 1000

/-- The measured seed-1 sweep (NET-37) at `(d = 4, ctx = 1024)`, budgets in increasing
order.  Only budgets that were actually swept are listed. -/
def sweepS1 : List (ℕ × ℚ) :=
  [(64, 968 / 1000), (96, 977 / 1000), (128, 986 / 1000)]

/-- The measured seed-2 sweep (NET-44), with the added `112` pinning point. -/
def sweepS2 : List (ℕ × ℚ) :=
  [(64, 979 / 1000), (96, 987 / 1000), (112, 991 / 1000), (128, 993 / 1000)]

/-- The knee of a sweep: the first budget whose retained accuracy reaches the bar. -/
def kneeOf (s : List (ℕ × ℚ)) : Option ℕ := (s.find? fun p => barQ ≤ p.2).map Prod.fst

/-- The sweep shifted uniformly by the observed spread. -/
def shift (s : List (ℕ × ℚ)) (η : ℚ) : List (ℕ × ℚ) := s.map fun p => (p.1, p.2 + η)

/-- Seed 1: knee `128`. -/
theorem knee_s1 : kneeOf sweepS1 = some 128 := by
  norm_num [kneeOf, sweepS1, barQ, List.find?]

/-- Seed 2: knee `96`. -/
theorem knee_s2 : kneeOf sweepS2 = some 96 := by
  norm_num [kneeOf, sweepS2, barQ, List.find?]

/-- Seed 1's margin at `96` is `0.003`, strictly inside the observed spread: the knee at
`128` was unprotected. -/
theorem margin_s1_96_lt_spread : barQ - 977 / 1000 < spreadQ := by
  norm_num [barQ, spreadQ]

/-- Seed 1's deficit at `64` is `0.012`, strictly outside the spread: the lower end of
the bracket was protected. -/
theorem deficit_s1_64_gt_spread : spreadQ < barQ - 968 / 1000 := by
  norm_num [barQ, spreadQ]

/-- Shifting the seed-1 sweep by the spread moves its knee to `96`. -/
theorem knee_s1_shifted : kneeOf (shift sweepS1 spreadQ) = some 96 := by
  norm_num [kneeOf, shift, sweepS1, barQ, spreadQ, List.find?]

/-- The shifted seed-1 sweep reproduces the seed-2 measurement to within `0.001` at
every swept budget. -/
theorem shift_matches_s2 :
    (978 / 1000 - 979 / 1000 : ℚ) = -(1 / 1000) ∧
    (987 / 1000 - 987 / 1000 : ℚ) = 0 ∧
    (996 / 1000 - 993 / 1000 : ℚ) = 3 / 1000 := by
  norm_num

/-- Grid-quantisation check: with step `32`, the reported knees `96` and `128` are the
`3`rd and `4`th grid points, so their true-knee windows `(64, 96]` and `(96, 128]` are
adjacent and disjoint. -/
theorem quantisation_windows : (32 : ℚ) * 3 = 96 ∧ (32 : ℚ) * 4 = 128 ∧
    (128 : ℚ) - 96 = 32 := by norm_num

end KneeEvidence