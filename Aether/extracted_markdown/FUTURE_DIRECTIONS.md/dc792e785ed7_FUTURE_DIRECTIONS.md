# Future Directions: Matroid Minor Theory and the Robertson-Seymour Conjecture

## Synthesis

This research cycle established a formalized framework connecting matroid minor theory, well-quasi-ordering, and the Robertson-Seymour conjecture for representable matroids. The key structural chain — WQO implies finite antichains implies finite excluded minors — was fully formalized, along with the dual-minor correspondence and the self-duality of the RS conjecture. These results provide the foundational infrastructure for deeper investigations into matroid structure theory.

The most promising cross-domain connection is between matroid representability and the existing catalog work on tropical geometry (in `Bridges/AlgebraTropicalGeometry/`). Tropical matroids — matroids arising from valuated matroids over tropical semirings — provide a bridge between algebraic geometry and combinatorics. The WQO framework developed here could potentially be extended to tropical representability, connecting the minor-theoretic machinery to the persistence and filtration concepts already formalized in the catalog.

The direction with the highest breakthrough potential is formalizing the cycle matroid construction and proving that graph minor theory is a special case of matroid minor theory. This would create a verified bridge between two major areas of combinatorics and unlock the application of matroid-theoretic tools to graph-theoretic problems.

---

### Direction 1: Cycle Matroids and the Graph-Matroid Bridge

**Conjecture**: For any finite graph $G$, the cycle matroid $M(G)$ (where the ground set is the edge set and a set of edges is independent iff it is acyclic) satisfies: $H$ is a graph minor of $G$ if and only if $M(H) \leq_m M(G)$. Furthermore, $M(G)$ is representable over every field, making graph minor theory a special case of the matroid RS conjecture over GF(2).

**Test**: Construct the cycle matroid for small graphs (paths, cycles, complete graphs $K_4$, $K_5$, Petersen graph) and verify the minor correspondence computationally. Check that deletion/contraction of edges in $G$ corresponds exactly to deletion/contraction in $M(G)$.

**Impact**: If formalized, this would create the first verified bridge between graph minor theory and matroid minor theory. It would also show that the Robertson-Seymour theorem for graphs is a corollary of the matroid RS conjecture for binary matroids (GF(2)-representable), unifying two major research programs.

**Catalog References**: `Geometry/MatroidMinors/Basic.lean` (dual_isMinor_dual, wqo_implies_finite_antichains), `Geometry/MatroidMinors/Representable.lean` (IsRepresentable, RobertsonSeymourConj)

**Proof Strategy**: (1) Define `SimpleGraph.cycleMatroid` as a Mathlib `Matroid` on the edge set. (2) Prove that forest (acyclic subgraph) = independent set in the cycle matroid. (3) Show edge deletion in graph = element deletion in matroid. (4) Show edge contraction in graph = element contraction in matroid. (5) Prove the minor correspondence theorem. Key Mathlib dependencies: `Mathlib.Combinatorics.SimpleGraph.Basic`, `Mathlib.Combinatorics.Matroid.Basic`.

**Domain Bridges**: Graph Theory <-> Matroid Theory <-> Linear Algebra (representability)

**Lineage**: Builds on this cycle's `dual_isMinor_dual` and `IsRepresentable` definition.

**Ambition**: grand_challenge

---

### Direction 2: Representability as a Minor-Closed Property

**Conjecture**: For any field $F$, the predicate `IsRepresentable F` on matroids satisfies `IsMinorClosed (IsRepresentable F)`. That is, if $M$ is representable over $F$ and $N \leq_m M$, then $N$ is representable over $F$. This is a well-known mathematical fact but has not been formalized.

**Test**: (1) Prove the deletion case: if $\varphi$ represents $M$, then restricting $\varphi$ to $M.E \setminus D$ represents $M \setminus D$. (2) Prove the contraction case: if $\varphi$ represents $M$ and $C \subseteq M.E$ with $M.Indep C$, then the projection of $\varphi$ to the quotient $F^n / \text{span}(\varphi(C))$ represents $M / C$. (3) Combine for the general minor case.

**Impact**: Completing this proof would close the main gap in our formalized theory, enabling the full chain: RS conjecture → WQO on representable class → finite excluded minors for any minor-closed subclass of representable matroids. It would also enable the excluded-minor-dual-pair theorem.

**Catalog References**: `Geometry/MatroidMinors/Representable.lean` (Representation structure, IsRepresentable), `Geometry/MatroidMinors/Basic.lean` (IsMinorClosed)

**Proof Strategy**: The key technical challenge is the contraction case, which requires: (1) Defining the quotient vector space $V/W$ where $W = \text{span}(\varphi(C))$. (2) Showing that the projected vectors give a valid representation. (3) Using Mathlib's `Submodule.Quotient` and `LinearMap.ker` API. The deletion case should be straightforward. Establish helper lemmas: `delete_representation` (restriction of representation) and `contract_representation` (projection to quotient) separately.

**Domain Bridges**: Matroid Theory <-> Linear Algebra (quotient spaces, projections)

**Lineage**: Builds on this cycle's `Representation` structure and the failed attempt at `representable_minor_closed`.

**Ambition**: extension

---

### Direction 3: Tropical Matroids and Valuated WQO

**Conjecture**: Define a *tropical matroid* as a matroid equipped with a valuation function $\omega : \binom{E}{r} \to \mathbb{T}$ (where $\mathbb{T} = \mathbb{R} \cup \{-\infty\}$ is the tropical semiring) satisfying the tropical Plücker relations. Conjecture: For any fixed rank $r$, the class of tropical matroids of rank $r$ on finite ground sets is well-quasi-ordered by a suitably defined tropical minor relation.

**Test**: Enumerate tropical matroids of rank 2 on ground sets of size up to 8. Verify computationally that no infinite antichain exists among these. Check whether the standard matroid minor relation, when extended to valuated matroids by requiring the valuation to be preserved (up to tropical scaling), satisfies the WQO property on this finite sample.

**Impact**: Tropical matroids sit at the intersection of combinatorics, algebraic geometry, and optimization. A WQO result would extend the Robertson-Seymour paradigm into tropical geometry, potentially yielding finite forbidden minor characterizations for tropical linear spaces. This connects to the catalog's existing work on tropical persistence duality.

**Catalog References**: `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` (graphs_same_rank_interleaving), `Geometry/MatroidMinors/Basic.lean` (IsMinorWQO, wqo_implies_finite_antichains)

**Proof Strategy**: (1) Define `TropicalMatroid` extending `Matroid` with a valuation. (2) Define tropical minor relation (deletion = restriction of valuation; contraction = tropical quotient). (3) For rank 2, tropical matroids correspond to metric trees — leverage known results on WQO for trees. (4) Attempt induction on rank using the matroid minor chain bound from this cycle.

**Domain Bridges**: Matroid Theory <-> Tropical Geometry <-> Persistence Theory (filtrations)

**Lineage**: Builds on this cycle's WQO framework and the catalog's tropical geometry work.

**Ambition**: grand_challenge

---

### Direction 4: Excluded Minors for GF(4)-Representability

**Conjecture**: The complete list of excluded minors for GF(4)-representability consists of exactly the following matroids: $U_{2,6}$, $P_6$, $F_7^-$, $(F_7^-)^*$, $P_8$, $P_8^=$, and a small number of additional sporadic matroids. Specifically, conjecture that the total number of excluded minors is at most 10.

**Test**: (1) Define uniform matroids $U_{k,n}$ as Lean `Matroid` instances. (2) Define the specific sporadic matroids ($F_7$, $F_7^*$, $P_6$, etc.) via their circuits or rank functions. (3) Verify computationally (via `#eval`) that each claimed excluded minor is not GF(4)-representable but all its single-element deletions and contractions are. (4) Search for additional excluded minors of rank 3 on up to 10 elements.

**Impact**: The excluded minor characterization for GF(4) is one of the major open problems in matroid representation theory. Even partial progress — verifying the known excluded minors and bounding the total count — would advance the state of the art. The formalized framework from this cycle provides the infrastructure to state and verify such characterizations.

**Catalog References**: `Geometry/MatroidMinors/Representable.lean` (IsExcludedMinor, wqo_implies_finite_obstructions), `Geometry/MatroidMinors/Basic.lean` (excluded_minors_antichain)

**Proof Strategy**: (1) Build a library of concrete matroid constructions (uniform matroids, projective geometries, sporadic matroids). (2) Implement GF(4) as `ZMod 4` with field structure (or use `GaloisField 4 2`). (3) For each candidate excluded minor, construct a proof of non-representability (usually by showing a forbidden substructure) and a proof that all proper minors are representable (by explicit construction). (4) Use the antichain theorem to bound the number of excluded minors.

**Domain Bridges**: Matroid Theory <-> Finite Geometry <-> Coding Theory (GF(4) codes)

**Lineage**: Builds on this cycle's excluded minor framework and the RS conjecture formalization.

**Ambition**: extension

---

### Direction 5: Matroid Intersection and Nash-Williams' Conjecture

**Conjecture**: For any two matroids $M_1, M_2$ on the same ground set $E$ with $|E|$ finite, define the *intersection matroid* (when it exists) as the matroid whose independent sets are exactly $\mathcal{I}(M_1) \cap \mathcal{I}(M_2)$. Nash-Williams conjectured that if $M_1$ and $M_2$ are both representable over the same field $F$, then their matroid intersection (which is not always a matroid) can be decomposed into a bounded number of representable matroids. Formally: there exists a partition of $E$ into at most $r(M_1) + r(M_2)$ parts such that the restriction to each part is representable.

**Test**: Verify for pairs of representable matroids of rank at most 3 on ground sets of size up to 8 that the intersection structure can always be decomposed into representable pieces. Count the minimum number of pieces needed and compare with the conjectured bound.

**Impact**: Matroid intersection is fundamental to combinatorial optimization (it generalizes bipartite matching, network flow, and many scheduling problems). Understanding when intersections preserve representability would connect structural matroid theory to algorithmic applications.

**Catalog References**: `Geometry/MatroidMinors/Representable.lean` (IsRepresentable), `Geometry/MatroidMinors/Basic.lean` (IsMinorClosed)

**Proof Strategy**: (1) Define matroid intersection as a set system. (2) Prove that matroid intersection is not always a matroid (construct a counterexample). (3) Define "decomposition complexity" as the minimum number of representable pieces. (4) Prove bounds using rank arguments and the submodularity of the rank function. Key Mathlib dependency: `Mathlib.Combinatorics.Matroid.Rank`.

**Domain Bridges**: Matroid Theory <-> Combinatorial Optimization <-> Representation Theory

**Lineage**: Builds on this cycle's representability definition and minor-closed property framework.

**Ambition**: extension
