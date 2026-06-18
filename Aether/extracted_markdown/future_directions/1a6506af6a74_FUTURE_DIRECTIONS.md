# Future Directions: Certificate Complexity in Tropical Convex Geometry

## Synthesis

The verified theory of tropical band systems opens a structured research program connecting tropical convexity, combinatorial optimization, and formal verification. The core insight unifying all directions is that **tropical feasibility certificates decompose into graph-theoretic invariants** — negative cycles for infeasibility, potentials for feasibility — and the Helly number measures how far this decomposition can be localized. Each direction below either extends the class of constraints where certificates remain small (Directions 1-2), connects the certificate framework to other mathematical domains (Directions 3-4), or deepens the algorithmic content of the theory (Direction 5). Together, they form the blueprint for a verified theory of certificate complexity in tropical convex geometry.

---

## Direction 1: Helly-2 for Laminar Tropical Band Families

**Conjecture:** For any finite laminar family of tropical band systems on a finite index type $\iota$, if every pair of systems has a common feasible point, then the entire family has a common feasible point. The Helly number is exactly 2.

**Test:** Generate random laminar families (nested support graphs) of 3-10 bands on Fin 2, Fin 3, and Fin 4. For each instance, check pairwise feasibility and global feasibility. A single instance with pairwise-yes/global-no refutes the conjecture. Run 10,000 instances per dimension.

**Impact:** This would identify the first non-trivial tropical constraint class beyond boxes with verified Helly number 2, establishing that the Helly-2 phenomenon is structural (hierarchical constraints) rather than accidental (interval independence). It would open a classification program: which tropical families admit constant-size certificates?

**Catalog References:** `Pythagorean/TropBandDefs.lean` (LaminarFamily definition), `Pythagorean/TropBandTheorems.lean` (helly_two_boxes), `Catalog/Tropical/HellyGeometry.lean` (helly_boxes, helly_intervals)

**Proof Strategy:** Induction on the laminar tree. For leaves, feasibility is given. At each merge node, the pairwise condition provides a common point for the two children, and laminarity ensures the canonical potential of one child is compatible with the other's constraints. Use the canonical potential construction from the closure theorem.

**Domain Bridges:** Constraint satisfaction (CSP tractability for nested constraint scopes), temporal logic (hierarchical timed systems), phylogenetics (tree-structured constraints)

**Lineage:** Direct extension of `helly_two_boxes` and `feasiblePt_meet_of_feasiblePt_both`

**Ambition:** ★★★★☆ — Would be a genuine breakthrough in tropical Helly theory

---

## Direction 2: Sharp Helly Numbers for General Tropical Bands

**Conjecture:** The Helly number for tropical band systems on $\text{Fin}(d)$ is at most $d + 1$, matching the classical Helly number for convex sets in $\mathbb{R}^d$. For $d = 2$, there exists a family of 4 bands with pairwise but not triple feasibility, showing the Helly number is exactly 3.

**Test:** Enumerate families of 3-5 bands on Fin 2 and Fin 3 with random rational slacks and bounds. For each family, check all $k$-wise intersections for $k = 2, 3, \ldots$ and record the smallest $k$ where $k$-wise feasibility implies global feasibility. This gives empirical Helly number estimates.

**Impact:** A sharp Helly number theorem for tropical bands would be the tropical analogue of the classical Helly theorem, completing the picture started by the box result. It would reveal whether tropical convexity fundamentally differs from classical convexity in its certificate complexity.

**Catalog References:** `Pythagorean/TropBandTheorems.lean` (infeasible_of_negCycle, helly_two_boxes), `Catalog/Tropical/HellyGeometry.lean` (tropicalHellyConjecture)

**Proof Strategy:** For the upper bound: generalize the coordinatewise maximum construction using $(d+1)$-wise closure conditions. For the lower bound: explicit counterexample construction using cycling slack constraints that create $d$-dimensional obstructions.

**Domain Bridges:** Combinatorial topology (nerve theorems), algebraic geometry (tropical intersection theory), computational complexity (CSP width parameters)

**Lineage:** Extension of Direction 1 and the existing `tropicalHellyConjecture`

**Ambition:** ★★★★★ — Grand challenge: would resolve a fundamental open question in tropical combinatorics

---

## Direction 3: Tropical Farkas Lemma and LP Duality

**Conjecture:** For tropical band systems, the feasibility-infeasibility dichotomy admits a "Farkas-type" certificate characterization: the system is infeasible if and only if there exists a non-negative combination of constraints that derives the contradiction $0 < 0$. In the band setting, this reduces to negative cycles with non-negative multiplicity.

**The key insight is** that the telescoping argument in `infeasible_of_negCycle` is secretly a special case of tropical LP duality where the dual certificate is a non-negative cycle weight vector.

**Why now?** The formalized negative-cycle theorem provides the first half (infeasibility → certificate). The converse — that every infeasible system has a negative cycle certificate — requires either closure computation or a tropical separation theorem, both of which are now within reach given the Floyd-Warshall closure infrastructure.

**Test:** For random infeasible band systems on Fin 3-5, extract the negative cycle certificate and verify it algebraically witnesses infeasibility. Check that the cycle is minimal (no proper sub-cycle is negative). Measure certificate sizes across 1000 instances.

**Impact:** A full Farkas lemma for tropical bands would provide a complete duality theory, enabling tropical LP solvers with verified certificates. This connects directly to the theory of linear programming over ordered algebraic structures.

**Catalog References:** `Pythagorean/TropBandTheorems.lean` (infeasible_of_negCycle, feasible_iff_graphPotential), `Catalog/Tropical/BellmanFord.lean` (no_neg_cycle_of_feasible)

**Proof Strategy:** Use Floyd-Warshall closure to show that if no negative cycle exists, the canonical potential construction yields a feasible point. The proof passes through the well-known equivalence between negative cycle freedom and potential existence for finite weighted digraphs.

**Domain Bridges:** Linear programming (strong duality), convex optimization (Farkas alternatives), proof complexity (certificate size lower bounds)

**Lineage:** Completion of the feasibility/infeasibility dichotomy begun by Theorems 4.1 and 5.1

**Ambition:** ★★★☆☆ — Important structural result, likely provable with existing techniques

---

## Direction 4: Tropical Band Dynamics and Control Invariants

**Conjecture:** The iteration $x^{(t+1)}_i = \max(\ell_i, \min(u_i, \max_j(x^{(t)}_j - s_{ji})))$ converges to the canonical feasible potential (if it exists) in at most $n$ steps, where $n$ is the number of coordinates.

**The key insight is** that the Bellman-Ford iteration on tropical band systems defines a monotone dynamical system on the lattice $[\ell, u]$, and feasibility of the band system is equivalent to the existence of a fixed point — connecting tropical geometry to control-theoretic invariant computation.

**Why now?** The canonical potential construction (Algorithm 1 in the research paper) implicitly performs this iteration. Formalizing convergence would yield a verified algorithm for invariant computation in timed systems, directly applicable to real-time scheduling and control verification.

**Test:** Implement the iteration for random feasible band systems and measure convergence time (number of iterations to reach a fixed point). Verify that the fixed point equals the canonical potential from Floyd-Warshall. Test on systems with $n = 3, 5, 10, 20, 50$.

**Impact:** This would establish tropical band theory as a computational framework for control invariant synthesis, with verified convergence guarantees. It bridges tropical geometry to the theory of monotone operators and Tarski fixed points.

**Catalog References:** `Pythagorean/TropBandTheorems.lean` (feasible_of_relaxation — monotonicity), `Catalog/Tropical/BellmanFord.lean`

**Proof Strategy:** Prove monotonicity of the iteration operator and apply Tarski's fixed-point theorem for finite lattices (after discretization) or use the Bellman-Ford convergence argument (at most $n$ relaxation rounds suffice).

**Domain Bridges:** Control theory (Lyapunov functions as potentials), dynamical systems (monotone iteration), verification (timed automata reachability)

**Lineage:** Algorithmic extension of the canonical potential construction

**Ambition:** ★★★☆☆ — Natural next step with clear applications

---

## Direction 5: Tropical Certificate Complexity Lower Bounds

**Conjecture:** For the class of all tropically convex sets in $\mathbb{R}^d$ (not just bands), the Helly number is exactly $2d$, and this is witnessed by a family of $2d$ tropical halfspaces with pairwise but not global intersection.

**The key insight is** that the factor-of-2 gap between the tropical Helly number ($2d$) and the classical Helly number ($d+1$) reflects the fundamental asymmetry of tropical convexity: tropical halfspaces are not closed under complementation, doubling the certificate complexity.

**Why now?** The box Helly theorem (Helly number 2 regardless of dimension) shows that structured tropical constraints can beat the $2d$ bound. Understanding when and why this happens requires constructing the extremal examples that achieve $2d$, which tropical band systems with carefully chosen slacks may provide.

**Test:** For $d = 2$: construct explicit families of tropical halfspaces/sectors in $\mathbb{R}^2$ and check if 3 or 4 is needed for the Helly number. For $d = 3$: search computationally for families achieving Helly number 5 or 6.

**Impact:** Sharp lower bounds would complete the certificate complexity picture and reveal whether tropical geometry is fundamentally harder than classical geometry for feasibility checking. This has implications for the complexity of tropical LP.

**Catalog References:** `Catalog/Tropical/HellyGeometry.lean` (tropicalHellyConjecture — conjectured bound $2d$), `Pythagorean/TropBandTheorems.lean` (helly_two_boxes — shows some classes beat $2d$)

**Proof Strategy:** Explicit construction. For $d = 2$: use tropical sectors defined by $x_1 - x_2 \leq c$ and $x_2 - x_1 \leq c'$ with carefully chosen orientations. Verify by exhaustive case analysis that pairwise intersection holds but $(2d)$-wise does not.

**Domain Bridges:** Computational complexity (proof complexity, certificate size), combinatorial optimization (LP certificate characterization), discrete geometry (Radon/Tverberg theory)

**Lineage:** Grand challenge extending the Helly program initiated in this work

**Ambition:** ★★★★★ — Would resolve a major open problem in tropical combinatorial geometry
