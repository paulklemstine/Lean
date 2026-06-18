# Future Directions: Tropical Moduli Spaces

The file `Tropical/ModuliMetricGraph.lean` formalizes the combinatorial skeleton
of the tropical moduli space `M_g^trop` as a `CombType` structure (vertex-weighted
connected dual graphs subject to handshake, genus, connectivity and stability
constraints) and proves the cone-dimension numerology of `M_g`:
`genus_ge_two`, `vertex_bound` (`|V| ≤ 2g−2`), `edge_bound` (`E ≤ 3g−3`,
i.e. `dim M_g^trop = 3g−3`), and `weight_bound` (`∑ w ≤ g`). The following
conjectures extend this foundation; each is stated to be falsifiable in Lean.

## 1. Finiteness of combinatorial types of fixed genus

**Conjecture.** For each `g`, the set of isomorphism classes of `CombType` with
genus `g` is finite; in fact the number of cones of `M_g^trop` is finite.

A clean Lean target: quotient `CombType` of genus `g` by graph isomorphism and
exhibit an injection of the quotient into a fixed finite set indexed by
`(|V|, E, multiset of weights, adjacency multiset)` with `|V| ≤ 2g−2`,
`E ≤ 3g−3` (both already proved here).

**The key insight is** that the proven bounds `|V| ≤ 2g−2` and `E ≤ 3g−3` make
the *defining data* of a combinatorial type range over a finite product of
bounded finite sets, so finiteness is a counting consequence of the dimension
bounds rather than a separate geometric input.

**Why now?** With `vertex_bound` and `edge_bound` already mechanized, the only
missing ingredient is a Lean-level notion of graph isomorphism on `CombType`,
which Mathlib's `SimpleGraph.Iso` / `Quotient` machinery already supports.

## 2. Pure faces and the link of the maximally degenerate point

**Conjecture.** The combinatorial types achieving `E = 3g−3` are exactly the
trivalent weight-`0` graphs (`val v = 3` and `w v = 0` for all `v`), and they
form the top-dimensional cones of `M_g^trop`; equality in `vertex_bound` forces
`E = 3g−3` simultaneously.

**The key insight is** that equality in the aggregate inequality
`3|V| ≤ 2E + 2∑w` (`handshake_stability`) is equivalent to per-vertex equality
`val v + 2 w v = 3`, which by integrality means `(val,w) ∈ {(3,0),(1,1)}`, and
the connectivity/genus identities then pin down the trivalent locus.

**Why now?** `handshake_stability` is proved as a *sum* inequality; promoting it
to the equality-characterization theorem only needs
`Finset.sum_eq_iff_of_le` / the equality case of `Finset.sum_le_sum`, which is
directly available.

## 3. The tropical Torelli map has finite fibers

**Conjecture.** The tropical Torelli map sending a combinatorial type to its
tropical Jacobian (the integral lattice `H_1(G,ℤ)` with the edge-length-induced
form) has finite fibers: only finitely many combinatorial types share a given
tropical principally polarized abelian variety.

**The key insight is** that the first Betti number `b₁ = E − |V| + 1` is bounded
by `g` (provable from `genus_eq` + `weight_bound`), so the rank of the Jacobian
lattice is bounded, and the fiber injects into the finite set of types of bounded
`b₁` — turning finiteness of Torelli fibers into a corollary of conjecture 1.

**Why now?** `weight_bound` already gives `∑ w ≤ g`, hence `b₁ ≤ g`; the lattice
`H_1` can be modeled as `Fin b₁ → ℤ` with a `Matrix` Gram form, all available in
Mathlib, so the statement is formalizable today.

## 4. `M_g^trop` as the Berkovich skeleton: a tropicalization retraction

**Conjecture.** There is a deformation retraction (a "tropicalization" map)
`trop` from a polyhedral model of the Berkovich analytification of `M_g` onto the
cone complex assembled from `CombType`s, restricting to the identity on the
skeleton.

**The key insight is** that the cone of a fixed combinatorial type is exactly the
space of edge-length assignments `ℝ_{≥0}^E`, and gluing these cones along the
face maps "contract an edge / merge into weight" reproduces the skeleton; the
proven dimension bound `E ≤ 3g−3` guarantees each cone has dimension `≤ 3g−3`.

**Why now?** The cone `ℝ_{≥0}^E` and its faces are elementary polyhedral objects
in `Mathlib`'s `Convex`/`PointedCone` API; the combinatorial face relation can be
encoded as edge-contraction maps between `CombType`s built on the structure here.

## 5. Stability is a sharp threshold: subadditivity of the dimension count

**Conjecture.** Define `defect C = 3 * C.g - (C.E + 3)`. Then `defect ≥ 0`
(proved: this is `edge_bound`), `defect = 0` characterizes top cones, and
`defect` is additive under the operation "contract a non-loop edge" up to a
controlled correction, giving a stratification of `M_g^trop` by codimension.

**The key insight is** that `defect` literally measures codimension of a cone in
`M_g^trop`, so an additivity/monotonicity law for `defect` under edge contraction
yields the full face poset (codimension-one walls connect adjacent cones).

**Why now?** `edge_bound` already establishes `defect ≥ 0` as a theorem; the next
step — defining edge contraction as a map `CombType → CombType` lowering `E` and
`|V|` by one — is a finite combinatorial construction with no missing Mathlib
prerequisites.
