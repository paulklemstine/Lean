/-
Copyright (c) 2025. All rights reserved.
Verified finite-range Goldbach computations.
-/
import Speculative.Goldbach.Defs
import Speculative.Goldbach.Theorems

/-!
# Verified Finite-Range Goldbach Theorem

We prove computationally that every even integer in `[4, 100]` has a
Goldbach decomposition. This combines the decidability instance with
native_decide to certify the result.
-/

open Goldbach

/-- Every even number between 4 and 100 has a Goldbach decomposition.
This is verified by exhaustive computation using the decidability instance. -/
theorem goldbach_verified_4_to_100 :
    ∀ n ∈ Finset.Icc 4 100, Even n → HasGoldbachDecomposition n := by
  native_decide

/-- Every even number between 4 and 1000 has a Goldbach decomposition.
This extends the verified range to 1000 by exhaustive computation. -/
theorem goldbach_verified_4_to_1000 :
    ∀ n ∈ Finset.Icc 4 1000, Even n → HasGoldbachDecomposition n := by
  native_decide