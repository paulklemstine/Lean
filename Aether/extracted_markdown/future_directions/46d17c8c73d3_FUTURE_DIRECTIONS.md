# Future Directions — Tropical Moduli Spaces and the Tropical Torelli Map

The file `TropicalModuliDimension.lean` establishes the cone-complex dimension theory
of the tropical moduli space `M_g^trop`: every combinatorial type (a connected stable
weighted graph, recorded as a `StableType`) has at most `3g − 3` edges and `2g − 2`
vertices; the top cones are realised by honest connected `3`-regular `SimpleGraph`s
(`trivalent_dimension`); the tropical Torelli map factors through the tropical
Jacobian whose dimension is the first Betti number `b₁ = e − v + 1` (`jacobianDim`,
`jacobianDim_eq`, `jacobianDim_nonneg`); and for fixed `g` there are only finitely
many types (`stableTypes_finite`), so the fan is finite. These results extend the
genus-`0` picture (`graphGenus`, `genus_connected`, `tree_genus_zero`) from
`ModuliCompactification.lean` to arbitrary genus. The following directions push the
program toward the deep theorems named in the concept brief.

## 1. A genuine `Fintype StableGraph_g` from realisable types

Right now `stableTypes_finite` bounds the *numerical invariants* `(v, e)` of types of
genus `g`. The natural next step is to upgrade this to a `Fintype` instance on the set
of actual isomorphism classes of stable weighted graphs of genus `g`, by bundling a
concrete `SimpleGraph` (with a multiplicity/weight function) into the `StableType`
record and quotienting by `SimpleGraph.Iso`. **The key insight is** that the edge and
vertex bounds already confine every type to graphs on a *fixed finite vertex set*
`Fin (2g − 2)` with at most `3g − 3` edges, so the isomorphism classes inject into a
finite power set and finiteness is purely combinatorial — no analysis is needed. *Why
now?* The arithmetic skeleton (`edge_bound`, `vertex_bound`) is proved and
axiom-clean, so the only remaining work is the bookkeeping of attaching a realising
graph, which Mathlib's `SimpleGraph` and `Fintype` API now supports directly.

## 2. The tropical Jacobian as a quadratic form, and PSD-ness of the Torelli image

Replace the scalar `jacobianDim` by the actual tropical Jacobian: the integer lattice
`ℤ^{b₁}` (cycle space of the graph) equipped with the **graph Laplacian / edge-length
quadratic form** `Q_G(γ) = Σ_e ℓ(e)·γ(e)²` restricted to cycles. Conjecture: `Q_G` is
always positive semidefinite, and positive definite exactly when all edge lengths are
positive, so the tropical Torelli map lands in the cone of PSD forms `A_g^trop`. **The
key insight is** that `Q_G` is a sum of squares weighted by non-negative edge lengths,
so PSD-ness is `Finset.sum` of non-negative terms — a `positivity`-style argument
rather than spectral theory. *Why now?* `jacobianDim_eq` already identifies the rank of
this form with `b₁`, giving an exact target for the rank of `Q_G`; pairing the rank
statement with an explicit SOS expression closes the "factors through the Jacobian"
half of the Torelli statement.

## 3. Finiteness of Torelli fibers via the cographic-matroid invariant

The classical Caporaso–Viviani theorem says the tropical Torelli map has finite fibers,
with the fiber over a Jacobian determined by the **cographic matroid** of the graph.
Conjecture (formalizable form): two `StableType`s with the same Jacobian quadratic form
have the same cographic matroid, and only finitely many graphs share a cographic
matroid. **The key insight is** that the matroid is a function of the *finite* edge set,
so "same matroid ⇒ finite fiber" reduces to `stableTypes_finite` intersected with a
matroid-equality predicate — a finite-to-finite refinement, not a new compactness
argument. *Why now?* `stableTypes_finite` already gives the ambient finiteness; Mathlib's
`Matroid` library makes the cographic matroid expressible, so the fiber-finiteness claim
becomes a concrete decidable filtering of the existing finite set.

## 4. The Euler-characteristic / dimension recursion across boundary strata

The cone `σ_G` of a type `G` has codimension-`1` faces obtained by *contracting* one
edge (length `→ 0`), which either merges two vertices or increases a vertex weight.
Conjecture: edge contraction sends a `StableType` of genus `g` with `e` edges to one
with `e − 1` edges and the *same* genus, and the resulting face poset makes
`M_g^trop` a pure `(3g − 3)`-dimensional generalized cone complex. **The key insight
is** that contraction preserves `genus_formula` exactly (it decreases both `edges` and
either `vertices` or shifts `vert0 → vertPos`, keeping `g + v = e + 1 + w` invariant),
so the recursion is a structure-preserving map definable directly on `StableType`. *Why
now?* The genus invariant is already encoded as a field equation that `omega` can track,
so the contraction map and its genus-preservation can be defined and verified mechanically,
giving the first formal handle on the boundary stratification.

## 5. `M_g^trop` as the Berkovich skeleton: a metric realisation theorem

The deepest claim in the brief is that `M_g^trop` is the Berkovich skeleton of the
classical `M_g`. A tractable first formalization is the *metric* shadow of this: equip
each cone `σ_G = ℝ_{≥0}^{E(G)}` with the `ℓ^∞` (tropical) metric and glue along
contractions (Direction 4) to obtain a metric space, then prove this metric space is
contractible and of pure dimension `3g − 3`. **The key insight is** that contractibility
follows from a tropical *scaling homotopy* `ℓ ↦ t·ℓ` toward the cone apex, which is
exactly the max-plus homogeneity `tropical_homogeneity` already proved in
`ModuliCompactification.lean`. *Why now?* The scaling lemma and the dimension formula
are both in hand, so the homotopy and its continuity can be assembled from existing
catalog pieces — turning the skeleton statement from "deep algebraic geometry" into a
metric-geometry gluing problem within reach of Mathlib's topology library.
