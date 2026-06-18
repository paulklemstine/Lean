# Future Directions: Closure Operators as Certified Algorithms

## 1. Tight Stabilization Bound via Potential Tracking

The current stabilization bound is `Fintype.card α`, which is tight in the worst case (e.g., the identity closure on singletons added one at a time). However, for "algebraic-like" closures where each step adds at least one element, the iteration count equals the number of elements in `cl(S) \ S`, not `card α`.

**Conjecture**: For any closure operator `c` on a finite type and initial set `S`, the stabilization index equals `closurePotential c S S` (the initial information gap), not merely bounded by `card α`.

The key insight is that each non-terminal step decreases the potential by at least 1 (already proved as `closurePotential_strict_decrease`), and the potential starts at `|cl(S) \ S|`, so the iteration count is exactly bounded by `|cl(S) \ S|`.

**Why now?** The potential descent lemma is already in the catalog. The remaining step is a simple induction tying the iteration count to the cumulative potential drop, which should be formalizable in 2–3 lemmas.


## 2. Matroid Closure as a Certified Reconstruction Algorithm

Every matroid defines a closure operator on its ground set. The iterative saturation algorithm specialized to matroid closure should yield a certified greedy algorithm for matroid span computation.

**Conjecture**: The probe-closure construction `probeClosure` instantiated with the matroid rank function's level sets recovers the matroid closure, and the `closureSaturationAlg` produces a certified algorithm equivalent to greedy matroid augmentation, terminating in at most `rank(M)` steps rather than `card α`.

The key insight is that matroid closure is finitary and each augmentation step increases rank by exactly 1, so the stabilization index equals the rank of the closure of the initial set.

**Why now?** Mathlib has matroids (`Matroid.Closure`) with extensivity, monotonicity, and idempotence already proved. The bridge requires only instantiating `ClosureOp` from `Matroid.Closure` and proving the rank-based bound.


## 3. Probe Closure Separation and Reconstruction Duality

The `probeClosure` operator defines a Galois connection between sets of probes and closed sets. The dual direction—given a closure operator, find the minimal probe set that generates it—is the reconstruction problem from the Tannaka bridge.

**Conjecture**: For finite types, every closure operator `c` is equal to `probeClosure probes` for some finite set `probes`, and the minimal cardinality of such a probe set equals the width of the lattice of closed sets of `c`.

The key insight is that on a finite type, every closure operator is determined by its lattice of closed sets, and each closed set can be "separated" by a single probe distinguishing it from its complement, so the number of probes needed equals the number of join-irreducible closed sets.

**Why now?** The Tannaka uniqueness theorem `closure_eq_of_sameClosedSets` from the reconstruction file shows that the closed-set lattice determines the closure. The missing piece is constructing the explicit probe family from the lattice, which is a finite combinatorial argument.


## 4. Parallel Saturation and Information-Theoretic Lower Bounds

The sequential saturation algorithm takes `N` steps where `N ≤ card α`. In a parallel model where multiple elements can be added simultaneously, the depth should be related to the longest chain in the lattice of closed sets.

**Conjecture**: The parallel saturation depth (where each step adds all elements simultaneously, i.e., applies `cl` once) equals the height of the chain `S ⊂ cl(S) ⊂ cl²(S) ⊂ ⋯ ⊂ cl^N(S)`, and there exists an information-theoretic lower bound showing that no algorithm can compute `cl(S)` using fewer than `log₂ |cl(S)|` adaptive queries to the closure oracle.

The key insight is that each application of `cl` is already maximally parallel—it adds all forced elements at once—so the sequential iteration IS the optimal parallel algorithm, and the chain height measures its inherent sequential depth.

**Why now?** The ascending chain `closureIter_le` and strict growth `card_toFinset_lt_of_ne` are already proved. The chain height is just the stabilization index. The information-theoretic lower bound connects to the entropy framework in `InfoEfficientAlgorithms`.


## 5. Closure Dynamics on Simplicial Complexes and Topological Data Analysis

Closure operators on simplicial complexes (via the simplicial closure: add all faces of present simplices) provide a bridge between the algebraic closure framework and topological data analysis (persistent homology).

**Conjecture**: The iterative saturation of the simplicial closure operator, starting from a 1-skeleton (graph), computes the clique complex in at most `dim + 1` steps (where `dim` is the maximum clique size), and the Betti numbers of intermediate iterates form a monotone filtration that recovers the Vietoris–Rips persistent homology tower.

The key insight is that the simplicial closure is stratified by dimension: each iteration adds simplices of exactly one higher dimension, so the stabilization index equals the dimension of the clique complex, not the total number of simplices.

**Why now?** The `ClosureOp` structure and stabilization machinery are ready. The simplicial closure can be defined on `Finset (Finset α)` with the "downward closure" axioms. The dimensional stratification gives a much tighter bound than `card α`, and connecting to persistent homology would bridge the catalog to computational topology.
