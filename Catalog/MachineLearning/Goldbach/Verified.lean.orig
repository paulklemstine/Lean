/-
Copyright (c) 2025. All rights reserved.
Verified finite-range Goldbach and Chen computations.
-/
import Speculative.Goldbach.Theorems

/-!
# Verified Finite-Range Goldbach and Chen Theorems

We prove computationally that various additive prime decomposition properties
hold on explicit finite intervals, using `native_decide` to certify the results.

## Main Results

* `goldbach_verified_4_to_100` — Goldbach for even n ∈ [4, 100]
* `goldbach_verified_4_to_1000` — Goldbach for even n ∈ [4, 1000]
* `weakChen_verified_4_to_100` — Weak Chen for even n ∈ [4, 100]
* `goldbachWitnesses_ge_two_8_to_100` — at least 2 Goldbach witnesses for even n ∈ [8, 100]
-/

open Goldbach

/-- Every even number between 4 and 100 has a Goldbach decomposition. -/
theorem goldbach_verified_4_to_100 :
    ∀ n ∈ Finset.Icc 4 100, Even n → HasGoldbachDecomposition n := by
  native_decide

/-- Every even number between 4 and 1000 has a Goldbach decomposition. -/
theorem goldbach_verified_4_to_1000 :
    ∀ n ∈ Finset.Icc 4 1000, Even n → HasGoldbachDecomposition n := by
  native_decide

/-- Every even number between 4 and 100 has a weak Chen decomposition. -/
theorem weakChen_verified_4_to_100 :
    ∀ n ∈ Finset.Icc 4 100, Even n → HasWeakChenDecomposition n := by
  native_decide

/-- Every even number between 8 and 100 has at least 2 ordered Goldbach
witnesses (i.e., the cardinality of goldbachWitnesses n is ≥ 2).
This certifies the Goldbach multiplicity lower bound. -/
theorem goldbachWitnesses_ge_two_8_to_100 :
    ∀ n ∈ Finset.Icc 8 100, Even n →
      2 ≤ (goldbachWitnesses n).card := by
  native_decide