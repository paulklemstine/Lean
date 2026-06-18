# Future Directions: Phantom Topologies

## Synthesis

This cycle put the *phantom topology* framework on a rigorous lattice-theoretic footing. An
observer assignment `obs : O → TopologicalSpace X` produces a **consensus** topology
`consensus obs = ⨆ o, obs o`, whose open sets are exactly the sets all observers agree are
open (`isOpen_consensus_iff`). The decisive structural realisation is that the "observers are
finer than the consensus" condition is *automatic* (`observer_le_consensus`): a phantom
representation is nothing more than a join-decomposition in the complete lattice
`TopologicalSpace X`. Consequently the **phantom number** is a pure lattice invariant: phantom
number `1` is join-irreducibility (`PhantomIrreducible`), and phantom number `≥ 2` is
join-reducibility (`PhantomReducible`), the two being formally negations
(`phantomIrreducible_iff_not_reducible`). We anchored the theory with two extremes: the
discrete topology `⊥` is always irreducible (`bot_phantomIrreducible`), and the indiscrete
topology on `Bool` is the minimal reducible witness, splitting as the consensus of the two
particular-point topologies (`indiscrete_bool_phantomReducible`).

## Results Summary

* `isOpen_consensus_iff`, `observer_le_consensus`, `consensus_le_iff` — the consensus is the
  lattice join, with its universal property.
* `consensus_coarser_of_more_observers` — adding observers (via `Sum`) coarsens the consensus.
* `consensus_const` — a unanimous panel reproduces the original topology.
* `phantomIrreducible_iff_not_reducible` — phantom number `1` ⇔ join-irreducible.
* `bot_phantomIrreducible` — the discrete topology has phantom number `1`.
* `indiscrete_bool_phantomReducible` / `indiscrete_bool_not_phantomIrreducible` — the indiscrete
  topology on `Bool` has phantom number exactly `2`.

## Direction 1 — Phantom numbers are bounded by lattice height on finite spaces

We conjecture that for a finite set `X` with `|X| = n`, every topology `τ` on `X` satisfies
`phantomNumber τ ≤ n`, and the maximum over all topologies grows like `Θ(log n)`. The
particular-point construction generalises: on `Bool` two observers suffice, and a chain of
particular-point topologies should decompose larger indiscrete-like topologies.
The key insight is that join-reducibility in the *finite* lattice of topologies is decidable by
exhaustive search, so phantom numbers become a computable combinatorial statistic whose extremal
behaviour can be tabulated for `n ≤ 6`. Why now? With `consensus` already proven to be the
lattice join and `Fintype`/`DecidableEq` infrastructure in Mathlib, the phantom number of a
finite topology can be defined as a `Finset.min` over decompositions and `#eval`-uated directly,
turning the asymptotic conjecture into a falsifiable computation.

## Direction 2 — The discrete/indiscrete dichotomy is sharp under separation axioms

We conjecture that on any space the discrete topology is the *unique* phantom-irreducible
topology that is also `T1`, while every non-discrete `T1` topology is phantom-reducible. More
boldly: a Hausdorff topology that is not discrete always has phantom number `≤ 2`. This connects
the observer framework to the classical separation hierarchy.
The key insight is that `bot_phantomIrreducible` is the only irreducibility we currently have,
and separation axioms force "enough" open sets, which should manufacture two strictly finer
topologies whose common opens collapse back to `τ`. Why now? `consensus_coarser_of_more_observers`
shows separation properties impose lower bounds on observer counts, and Mathlib's `T1Space` /
`T2Space` API is complete enough to attempt the decomposition explicitly.

## Direction 3 — A product formula for phantom numbers

We conjecture `phantomNumber (X × Y) ≤ phantomNumber X · phantomNumber Y` for the product
topology, with equality for "independent" topologies. A phantom representation of `X × Y` can be
assembled from the pairwise products of observer topologies for `X` and `Y`.
The key insight is that the product of two consensus topologies relates to the consensus of the
pairwise products through the distributivity of `⨆` over the product-topology functor, giving the
multiplicative bound directly from `consensus_le_iff`. Why now? Mathlib's `instTopologicalSpaceProd`
and the `induced`/`coinduced` Galois-connection lemmas make the interaction between products and
`⨆` tractable, so the inequality reduces to a clean lattice computation already in reach.

## Direction 4 — Phantom-irreducible topologies form a join-generating set

We conjecture that every topology is the consensus of its phantom-irreducible refinements: the
join-irreducible elements *join-generate* the lattice `TopologicalSpace X`. This is the topology
analogue of expressing a lattice element via its irreducible components.
The key insight is that `phantomIrreducible_iff_not_reducible` lets us repeatedly split any
reducible topology into strictly finer pieces; well-foundedness of `<` on finite lattices then
terminates the recursion at irreducibles. Why now? The negation-equivalence between reducibility
and irreducibility is now formal, so the descent argument has a precise induction principle, and
on finite spaces `IsWellFounded` instances close the recursion automatically.

## Direction 5 — Consensus as sheafification: the categorical lift

We conjecture that the consensus operation `⨆` is the object map of a left adjoint from
observer-indexed diagrams of topologies to single topologies, and that replacing the discrete
observer index by a site upgrades a phantom topology to a *presheaf of topologies* whose
sheafification is the consensus. The phantom number would then equal the minimal size of a
covering family determining the sheaf.
The key insight is that "open in the consensus iff open in every observer" (`isOpen_consensus_iff`)
is literally the gluing/locality condition of a sheaf, so the consensus is a colimit-style
universal construction packaged by `consensus_le_iff`. Why now? Mathlib's `GrothendieckTopology`
and sheafification machinery has matured, and the phantom framework supplies a concrete,
low-dimensional test bed where the adjunction can be checked against the explicit `Bool` example.
