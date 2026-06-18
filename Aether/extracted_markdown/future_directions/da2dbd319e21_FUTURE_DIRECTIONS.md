# Future Directions: Tropical Convexity Compression

## Hypothesis 1: Tropical Radon from Carathéodory

**Conjecture:** Every set of n+2 points in (Fin n → ℚ) admits a *tropical Radon partition*: a decomposition into two sets A and B such that the tropical convex hulls of A and B intersect.

**Test:** Enumerate all partitions of small point sets (k ≤ 6) in dimensions n = 2, 3 over rational coordinates drawn from {0, 1, 2, 3}. For each partition, compute tropical convex hulls and check intersection. A single counterexample (n+2 points with no Radon partition) would refute the conjecture. Exhaustive verification for all configurations with coordinates in {0,...,3}^n would provide strong evidence.

**Impact:** This would establish the first link in the tropical Carathéodory → Radon → Helly chain, enabling a systematic tropical combinatorial convexity theory. It would also clarify whether the tropical Radon number equals n+2 (matching the classical case) or differs.

## Hypothesis 2: Sharp Support Bound under Projective Normalization

**Conjecture:** Under projective normalization (fix one coordinate, e.g., z(0) = 0, and require min_x w(x) = 0), the optimal compression constant is n, not n+1. Without normalization, the bound is n (as proved in our main theorem). With normalization, the additional constraint may force one extra generator.

**Test:** For n = 2, 3, generate random rational point configurations S with |S| = 10 in the projective tropical space (points with first coordinate 0). For each z in the normalized tropical hull, find the minimum number of generators needed. If any z requires exactly n+1 generators under normalization, this confirms n+1 is tight. If all examples need at most n, the sharper bound may hold.

**Impact:** Would determine the correct tropical Carathéodory number for projective tropical convexity, which is the version most commonly used in tropical algebraic geometry (via the tropical projective space TP^{n-1}).

## Hypothesis 3: Helly Duality for Tropical Halfspaces

**Conjecture:** Finite families of tropical halfspaces in (Fin n → ℚ) have Helly number at most 2n. That is, if every subfamily of size ≤ 2n has nonempty intersection, then the whole family intersects.

A tropical halfspace is a set of the form {x : a + x(i) ≤ b + x(j)} for some a, b ∈ ℚ and i, j ∈ Fin n. The Helly number depends on whether we use "min-plus halfspaces" (one apex) or "sector halfspaces" (two coordinates).

**Test:** Enumerate minimal infeasible systems of tropical halfspaces in dimensions n = 2, 3. For each n, find the smallest family of tropical halfspaces with empty intersection such that every proper subfamily has nonempty intersection. The size of this family is the Helly number. Compare with 2n, n+1, and other candidate bounds.

**Impact:** A tropical Helly theorem would provide finite certificates for tropical infeasibility, with direct applications to difference-constraint systems and shortest path feasibility. The exact Helly number determines the size of infeasibility certificates.

## Hypothesis 4: Tropical LP Basis Theorem

**Conjecture:** Every bounded optimum of a finite tropical linear program (minimize c^T ⊙ x subject to A ⊙ x = b in the min-plus sense) has an active witness set of size at most n, where n is the number of variables.

More precisely: if x* is optimal, then there exist at most n active constraints that uniquely determine x* among feasible solutions, analogous to a classical LP basic feasible solution.

**Test:** Encode random small tropical LPs (m = 10 constraints, n = 3, 4 variables) over rational data. Solve by exhaustive search, then for each optimum, find the minimum number of active constraints that determine it. If any optimum requires more than n active constraints, the conjecture is false.

**Impact:** This would establish the foundation for tropical simplex-like algorithms, enabling polynomial-time tropical LP solvers via basis pivoting. It would also provide the theoretical backbone for certified tropical optimization.

## Hypothesis 5: Difference-Constraint Collapse

**Conjecture:** For tropical linear systems arising from difference constraints (x(i) - x(j) ≤ c_{ij}), the Carathéodory/Helly compression collapses to simple graph-theoretic certificates: a shortest path tree for feasibility, and a negative cycle for infeasibility. Specifically, the compressed witness set from the Carathéodory theorem corresponds exactly to the edges of a shortest path tree in the constraint graph.

**Test:** Generate random difference-constraint systems with n = 5, 10, 20 variables and m = 2n, 3n constraints. Solve via Bellman-Ford, extract the shortest path tree. Compare the tree edges with the compressed witness set from tropical Carathéodory compression applied to the tropical formulation. They should coincide (up to graph isomorphism).

**Impact:** Would establish a precise bridge between tropical geometry and graph algorithms, showing that classical shortest-path/negative-cycle theory is a special case of tropical convexity theory. This could unify formal verification of graph algorithms with tropical optimization certificates.
