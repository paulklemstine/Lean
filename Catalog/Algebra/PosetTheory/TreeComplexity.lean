import Shared.TreeComplexity

/-!
# Tree complexity (re-export)

`Shared/PosetTheory/ProofRefinement.lean` imports this module path, but the module file
was missing from the repository, so the import failed and broke the build.  The
development itself lives in `Shared/TreeComplexity.lean`; this file is a thin re-export,
so both import paths resolve to the same declarations and no duplicate enters the
environment.
-/