import Bridges.TruthFractal
/-!
# Finite computational evidence

The following kernel-checked small cases form the requested evidence table.
For `n = 0,1,2,3,4,5`, the half-free language has respectively
`1,2,4,8,16,32` admissible descriptions at length `2n`, while the ambient
binary language has `1,4,16,64,256,1024`.  In each row the former count
squared is the latter count.

No OEIS identification is needed: both columns are elementary geometric
sequences (`2^n` and `4^n`).  Exhaustive finite cardinality calculation finds
no counterexample, and the general theorem
`pairedTruth_exact_half_dimension` proves that none exists.
-/

namespace TruthFractalEvidence

open TruthFractal

theorem paired_prefix_small_cases :
    (List.range 6).map (fun n => Fintype.card (PairedPrefix n)) =
      [1, 2, 4, 8, 16, 32] := by
  norm_num [List.range_succ]

theorem ambient_prefix_small_cases :
    (List.range 6).map (fun n => Fintype.card (BinaryPrefix (2 * n))) =
      [1, 4, 16, 64, 256, 1024] := by
  norm_num [List.range_succ]

theorem small_case_counterexample_hunt :
    ∀ n ∈ List.range 6,
      (Fintype.card (PairedPrefix n)) ^ 2 =
        Fintype.card (BinaryPrefix (2 * n)) := by
  intro n hn
  exact pairedTruth_exact_half_dimension n

end TruthFractalEvidence