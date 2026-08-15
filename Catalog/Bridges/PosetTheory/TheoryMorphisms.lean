import Bridges.TheoryMorphisms

/-!
# `Bridges.PosetTheory.TheoryMorphisms` (re-export)

Several files (`Bridges.ComposableTransfer`, `Bridges.PredicateTransport`,
`Bridges.ResearchTheoryBicategory`, `Bridges.TheoryAdjunctions`) import the theory-morphism
framework under this module name, but the framework itself lives in
`Bridges.TheoryMorphisms`, so the module could not be resolved and the whole library failed
to configure.  This file restores the expected module path by re-exporting the framework;
it adds no new declarations.
-/