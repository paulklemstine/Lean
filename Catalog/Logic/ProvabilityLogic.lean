import Logic.LobFixedPoint

/-!
# Provability Lattices: bundled Gödel–Löb algebras

This file supplies the `ProvabilityLattice` interface used by the Kripke-semantic
development in `Catalog/Logic/GLKripke.lean`.  A **provability lattice** is simply a
Gödel–Löb algebra packaged as a single object: a carrier type equipped with a
`HeytingAlgebra` structure (giving `⊓`, `⊔`, `⊥`, `⊤`, `⇨`, `≤`) together with a
provability operator satisfying the `GLOperator` axioms of
`Catalog/Logic/LobFixedPoint.lean`.

Bundling lets us quantify over *all* such algebras at once — e.g. to build the
"theory space" frame `TheoryWorld` of `GLKripke.lean`, whose worlds are the proper
filters (consistent complete theories) of a provability lattice and whose accessibility
is reverse inclusion (relative consistency strength).
-/

/-- A **provability lattice**: a bundled Gödel–Löb algebra.  It is a carrier type with a
Heyting-algebra structure and a provability (`□`) operator satisfying the GL axioms
(`box_top`, `box_inf`, Löb).  These are the algebraic models of provability logic `GL`. -/
structure ProvabilityLattice where
  /-- The underlying type of "propositions" / lattice elements. -/
  carrier : Type*
  /-- The Heyting-algebra structure (meets, joins, ⊥, ⊤, implication, order). -/
  [heyting : HeytingAlgebra carrier]
  /-- The Gödel–Löb provability operator and its axioms. -/
  [gl : GLOperator carrier]

attribute [instance] ProvabilityLattice.heyting ProvabilityLattice.gl