# Future Directions: Tropical Scattering Duality

## 1. Extension to Feedback Networks via Tropical Kleene Star

**Goal**: Extend the acyclic transport realization theory to networks with directed cycles by incorporating the tropical Kleene star (reflexive-transitive closure) of the weight matrix.

**Key Steps**:
- Define the tropical Kleene star `W* = I ⊕ W ⊕ W² ⊕ ...` as a fixed-point computation over idempotent semirings where convergence is guaranteed.
- Prove that feedback networks with bounded cycle weight (strictly contractive loops) admit finite Kleene star computation and thus well-defined transfer matrices.
- Establish a realization theorem: every transfer matrix satisfying a spectral radius condition (tropical eigenvalue < 0 in min-plus) is realizable by a feedback network.
- Characterize minimal feedback realizations and their relationship to tropical eigenspaces.

**Impact**: Opens tropical systems theory to control-theoretic applications (stability, observability) and connects to max-plus spectral theory.

## 2. Boundary-Control/Observability Theory for Idempotent Scattering Systems

**Goal**: Develop a tropical analogue of Kalman's controllability and observability theory for scattering networks.

**Key Steps**:
- Define tropical controllability: every internal vertex is reachable from some source boundary vertex via a path of finite weight.
- Define tropical observability: every internal vertex can influence some sink boundary vertex.
- Prove the tropical Kalman decomposition: every scattering network decomposes into controllable-observable, controllable-unobservable, uncontrollable-observable, and uncontrollable-unobservable parts.
- Show that minimal realizations are exactly the controllable-and-observable ones, providing an alternative characterization of minimality.

**Impact**: Provides diagnostic tools for network design, identifies redundant or unreachable infrastructure in transport systems.

## 3. Stochastic/Thermodynamic Deformations: From Tropical to Log-Sum-Exp Physics

**Goal**: Parameterize a continuous family of semirings interpolating between tropical (T→0) and classical (T→∞) via the log-sum-exp operation, and study how realization theory deforms.

**Key Steps**:
- Define the β-deformed semiring with addition `a ⊕_β b = -β⁻¹ log(e^{-βa} + e^{-βb})` and standard addition as multiplication.
- Show that for finite β, the deformed transfer matrix is smooth and admits gradient-based optimization.
- Prove that minimal realizations of the β-deformed transfer converge (in a suitable sense) to tropical minimal realizations as β → ∞.
- Develop a "simulated annealing" reconstruction algorithm that starts at finite β and anneals toward the tropical solution.

**Impact**: Creates a bridge between combinatorial optimization (tropical) and continuous optimization (differentiable), with applications to neural network design and statistical physics of transport.

## 4. Tropical Holographic Rigidity: Boundary Transfer Determines Bulk Up to Gauge

**Goal**: Prove a rigidity theorem: the boundary transfer matrix of a minimal acyclic graph determines the graph's combinatorial structure up to a well-defined gauge equivalence.

**Key Steps**:
- Define gauge equivalence: two graphs are gauge-equivalent if they differ by internal vertex relabeling and weight rescaling that preserves the transfer matrix.
- Prove that minimal realizations of the same transfer matrix are gauge-equivalent (strengthening our uniqueness theorem to explicit isomorphism).
- Characterize the gauge group as a tropical torus action on internal vertex weights.
- Study the "holographic dictionary": which graph-theoretic properties (path structure, bottleneck distances, tropical eigenvalues) are boundary-observable invariants?

**Impact**: Provides a finite, rigorous model of the holographic principle from theoretical physics, where boundary data determines bulk geometry. Could serve as a testing ground for discrete quantum gravity ideas.

## 5. Complexity Bounds for Minimal Realization and Certified Reconstruction

**Goal**: Establish computational complexity bounds for the problems of (a) determining the minimal internal vertex count, (b) constructing a minimal realization, and (c) verifying a minimality certificate.

**Key Steps**:
- Prove that computing the tropical rank (minimum number of internal vertices in any realization) of a transfer matrix is NP-hard in general, by reduction from tropical matrix factorization rank.
- Show that for layered graphs with bounded depth, the reconstruction algorithm runs in polynomial time and the minimality certificate can be verified in polynomial time.
- Develop approximation algorithms: for general transfer matrices, find realizations within a constant factor of the minimal vertex count.
- Formalize the complexity results in Lean, providing certified upper and lower bounds.

**Impact**: Connects tropical realization theory to computational complexity, providing practical guidance on when efficient reconstruction is possible and establishing hardness barriers.
