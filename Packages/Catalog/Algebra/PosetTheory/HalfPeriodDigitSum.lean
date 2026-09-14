import Shared.HalfPeriodDigitSum

/-!
# Digit sums of half-period prime reciprocals (re-export)

`Shared/PosetTheory/HalfPeriodMidy.lean` and `Shared/PosetTheory/ProofRefinement.lean`
the import this module path, but the module file was missing from the repository, so the
the import failed and broke the build.  The development itself lives in
`Shared/HalfPeriodDigitSum.lean`; this file is a thin re-export, so both import paths
resolve to the same declarations and no duplicate enters the environment.
-/