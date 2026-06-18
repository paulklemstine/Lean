# Future Directions: Tropical Helly Geometry

## Synthesis

The tropical Helly theorem for boxes establishes the first formally verified bridge between tropical convexity and combinatorial optimization. The Helly number 2 for boxes, combined with the feasibility certificate theorem, demonstrates that tropical geometry produces *algorithmic certificates* — small witnesses for global properties. This foundation opens five concrete research directions, ranging from extending the Helly theory to general tropical convex sets (a direct algebraic challenge) to connecting tropical certificates with shortest-path duality and control theory (cross-domain bridges). The unifying theme is that **local-to-global principles in tropical geometry yield efficient algorithms**, and formalizing these principles creates a verified optimization infrastructure.

---

## Direction 1: General Tropical Helly Number

**Conjecture:** For tropically convex sets in `Fin d → ℝ` (max-plus convention), the Helly number is exactly `2d`. That is: if every `2d` sets in a finite family of tropically convex sets have nonempty intersection, then all sets have nonempty intersection. Furthermore, `2d` is optimal — there exists a family of `2d + 1` tropically convex sets in ℝ^d where every `2d` intersect but all `2d + 1` do not.

**Test:** Construct explicit families of tropical halfspaces or tropical polytopes in dimensions d = 2, 3 and verify computationally whether the Helly number exceeds 2. If the box result (Helly number 2) extends to tropical halfspaces without change, the conjecture would need revision downward.

**Impact:** Resolving the exact tropical Helly number would settle a central open problem in tropical combinatorial geometry (cf. Gaubert-Meunier 2010) and provide the tightest possible certificate size for tropical feasibility problems.

**Catalog References:** `Tropical/HellyGeometry.lean` — `tropicalHellyConjecture`, `IsTropConvex`, `helly_boxes`

**Proof Strategy:** Extend the coordinatewise decomposition used for boxes to tropical halfspaces via projective normalization. For a tropical halfspace `{x | max_i(a_i + x_i) ≤ max_j(b_j + x_j)}`, normalize by subtracting one coordinate to reduce to ℝ^{d-1} and use induction on dimension. The critical step is showing that the projection of a tropical halfspace onto a coordinate hyperplane is again tropically convex.

**Domain Bridges:** Combinatorial optimization (certificate size bounds), discrete geometry (Helly-type combinatorics), algebraic geometry (tropical varieties and their convex shadows).

**Lineage:** Extends `helly_boxes` from the box class to general tropical convex sets.

**Ambition:** grand_challenge — This would be the definitive tropical Helly theorem.

---

## Direction 2: Tropical Carathéodory Theorem

**Conjecture:** Any point in the tropical convex hull of n generators in `Fin d → ℝ` can be expressed using at most `d + 1` generators. That is, for any `z ∈ tropConvHull(pts)`, there exists a subset `T ⊆ {0, ..., n}` with `|T| ≤ d + 1` and weights `w : T → ℝ` such that `z(i) = max_{k ∈ T}(w(k) + pts(k)(i))` for all i.

**Test:** Generate random points in the tropical convex hull in dimensions d = 2, 3, 4 and attempt to re-express them using at most d + 1 generators. Count the minimal number of generators needed and check if d + 1 always suffices.

**Impact:** Would complete the first pillar of the tropical convexity trinity (Helly-Carathéodory-Radon). The bound d + 1 is known classically and conjectured tropically; a formal proof would enable sparse representation algorithms for tropical polytopes.

**Catalog References:** `Tropical/HellyGeometry.lean` — `tropConvHull`, `tropConvHull_isTropConvex`

**Proof Strategy:** For each coordinate i, the max in `z(i) = max_k(w(k) + pts(k)(i))` is achieved by some generator k_i. The "achieving" generators form a set of size at most d. If two coordinates share the same achieving generator, the representation is already sparse. Use a combinatorial argument (pigeonhole or matroid-like exchange) to reduce to d + 1 generators.

**Domain Bridges:** Computational geometry (sparse representations), machine learning (tropical PCA and dimension reduction), optimization (column generation in tropical LP).

**Lineage:** Builds on `tropConvHull` definition and the weight construction in `tropConvHull_isTropConvex`.

**Ambition:** extension — Directly builds on existing infrastructure.

---

## Direction 3: Tropical Separation and Duality

**Conjecture:** For two disjoint, finitely generated, tropically convex sets in `Fin d → ℝ`, there exists a tropical hyperplane separating them. A tropical hyperplane is a set of the form `{x | the maximum in max_i(a_i + x_i) is achieved by at least two indices}`.

**Test:** Generate pairs of disjoint tropical polytopes in ℝ² and ℝ³ and search for separating tropical hyperplanes. Measure the computational cost and success rate of greedy separation algorithms.

**Impact:** Would establish tropical Farkas-type lemma — the foundation for tropical LP duality. This connects tropical convexity to algorithmic optimization: separation oracles enable cutting-plane methods for tropical linear programs.

**Catalog References:** `Tropical/HellyGeometry.lean` — `IsTropConvex`, `tropConvHull`

**Proof Strategy:** Define tropical hyperplanes and max-plus linear functionals. Show that a finitely generated tropical convex set is the intersection of tropical halfspaces (tropical Minkowski-Weyl). Then adapt the classical separating hyperplane proof using the tropical Hahn-Banach theorem (Gaubert-Katz 2007).

**Domain Bridges:** Linear programming (LP duality), game theory (mean-payoff games as tropical LP), algebraic geometry (tropical varieties as zero sets of tropical polynomials).

**Lineage:** Extends the intersection theory from `isTropConvex_iInter` to separation theory.

**Ambition:** grand_challenge — Would open tropical LP to formal verification.

---

## Direction 4: Shortest-Path Certificates via Tropical Helly

**Conjecture:** For a weighted directed graph with n vertices, if every subsystem of d + 1 difference constraints (x_j - x_i ≤ w_{ij}) is feasible, then the full system is feasible. The tropical Helly theorem for tropical halfspaces (if proved) would imply this with d = n.

**The key insight is** that difference constraint systems are exactly the feasibility regions of tropical halfspaces in the max-plus semiring, and the Helly certificate for infeasibility corresponds to a negative-weight cycle of bounded length.

**Why now?** The formal bridge between tropical boxes and optimization certificates (`tropical_feasibility_certificate`) shows that the Helly framework produces usable algorithmic guarantees. Extending to difference constraints would connect to the Bellman-Ford algorithm and shortest-path verification.

**Test:** Generate random weighted digraphs, form the difference constraint system, and test whether k-wise feasibility (for small k) implies global feasibility. Measure the smallest k that suffices as a function of n.

**Impact:** Would provide formal certificates for shortest-path algorithms — proving that a shortest-path tree is correct by checking only small subsets of the constraint system.

**Catalog References:** `Tropical/HellyGeometry.lean` — `tropical_feasibility_certificate`, `helly_boxes`

**Proof Strategy:** Encode each difference constraint as a tropical halfspace. Apply the general tropical Helly theorem (Direction 1) to bound the certificate size. For special graph classes (DAGs, planar graphs), tighter bounds may be possible via topological arguments.

**Domain Bridges:** Graph algorithms (shortest paths, negative cycle detection), operations research (scheduling with precedence constraints), verification (certified graph algorithms).

**Lineage:** Extends `tropical_feasibility_certificate` from box constraints to difference constraints.

**Ambition:** extension — Builds directly on existing certificate theorem.

---

## Direction 5: Tropical Convexity in Control and Stability

**Conjecture:** For a max-plus linear dynamical system x(t+1) = A ⊗ x(t) (where ⊗ is max-plus matrix multiplication), the set of initial conditions leading to bounded trajectories is a tropically convex set. Its Helly properties determine the dimension of the "stability region" and yield certificates for instability.

**The key insight is** that stability analysis for max-plus linear systems reduces to feasibility of tropical inequality systems, and the Helly certificate theorem provides instability witnesses of bounded size.

**Why now?** Max-plus linear systems are central to discrete-event simulation (manufacturing, transportation networks). The tropical Helly framework provides a new geometric lens on their feasibility and stability regions.

**Test:** Simulate max-plus linear systems with random 3×3 and 4×4 matrices. Characterize the set of initial conditions yielding bounded orbits and verify that it is tropically convex. Test whether the Helly property holds for constraint sets arising from trajectory bounds.

**Impact:** Would connect tropical convexity theory to control theory and dynamical systems, opening a new application domain for formal tropical geometry. Could lead to verified stability certificates for industrial max-plus systems.

**Catalog References:** `Tropical/HellyGeometry.lean` — `IsTropConvex`, `tropical_feasibility_certificate`

**Proof Strategy:** Show that trajectory boundedness corresponds to a system of tropical inequalities (one per time step and state variable). Apply the tropical Helly certificate theorem to bound the number of time steps needed to certify instability.

**Domain Bridges:** Control theory (stability analysis), mathematical physics (Hamilton-Jacobi equations in the max-plus limit), industrial engineering (manufacturing system analysis).

**Lineage:** Applies `IsTropConvex` and `tropical_feasibility_certificate` to dynamical systems.

**Ambition:** grand_challenge — Opens a new domain connection.
