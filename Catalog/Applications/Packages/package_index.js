// AUTO-GENERATED FILE. DO NOT EDIT.
// Lightweight index for sidebar, graph, and lineage links.
// Full package data is loaded on-demand from individual .json files.

window.PACKAGE_INDEX = [];

window.PACKAGE_DB_INDEX = {};


// Knowledge Graph Data (auto-generated from lineage.json)
window.PACKAGE_GRAPH = {
  "nodes": [],
  "edges": [],
  "domain_bridges": []
};


// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "id": "seed_094",
    "title": "Proof Complexity Collapse: P=NP via Proof Checking",
    "description": "The key insight is that proof checking is fundamentally different from proof search. Conjecture: There exists a proof system in which every true quantifier-free formula has a proof of polynomial size, and this proof can be verified in polynomial time. The barrier has been that existing proof systems (Frege, Extended Frege) have exponential lower bounds for specific formulas. But what if we construct a NEW proof system based on EML computations? Define EML-Frege where each proof step is an EML identity (exp-log composition) verified by numeric evaluation. Since EML identities can be checked in O(1) field operations, and every boolean circuit can be simulated by an EML network of depth O(log n), we get a quasi-polynomial proof system. Why now: recent breakthroughs in circuit lower bounds (Williams 2014, 2023) and the EML single-operator universality result suggest that EML-Frege could break the natural proofs barrier. Test: prove that EML-Frege polynomially simulates Extended Frege for CNF formulas, and show it has no exponential lower bounds under the EML independence assumption. Impact: if EML-Frege has short proofs for all tautologies, then NP = coNP in this proof system, which would be the most significant result in proof complexity since Cook's theorem.",
    "domains": [
      "Logic",
      "Computation",
      "EML"
    ],
    "priority_score": 0.97,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.047681+00:00"
  },
  {
    "id": "seed_005",
    "title": "P vs NP Problem",
    "description": "Prove or disprove that P = NP. Formalize known barriers: relativization, natural proofs, algebrization. Explore circuit complexity lower bounds, proof complexity, and connections to cryptographic hardness assumptions.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.322674+00:00"
  },
  {
    "id": "seed_103",
    "title": "Gravity as Quantum Error Correction: Spacetime from Codes",
    "description": "The key insight is that the holographic principle in physics (AdS/CFT) can be rederived from quantum error correction. If the boundary CFT is a quantum error-correcting code with parameters [[n, k, d]], then the bulk AdS geometry emerges from the code's encoding. Conjecture: The Ryu-Takayanagi formula S(A) = Area(gamma_A) / (4G) is equivalent to the quantum Singleton bound d <= n - k + 1 applied to the boundary code, where the code distance d equals the minimal geodesic length through the bulk. Why now: recent work by Pastawski, Preskill, and Harrow (2015) showed that the AdS/CFT correspondence can be modeled by tensor networks (HaPPY code), but the converse \u2014 deriving AdS geometry FROM the code \u2014 has not been proven. Test: for the [[5,1,3]] code (the smallest perfect code), show that the code's Tanner graph IS the Penrose diagram of AdS_2, and the code distance 3 equals the geodesic length through the bulk. Impact: spacetime IS a quantum error-correcting code. Gravity is not a force \u2014 it's the logical operator of a quantum code.",
    "domains": [
      "Physics",
      "Computation",
      "Cryptography"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.135909+00:00"
  },
  {
    "id": "seed_001",
    "title": "Goldbach Conjecture",
    "description": "Prove that every even integer greater than 2 is the sum of two primes. Formalize partial results such as Vinogradov's theorem for sufficiently large odd integers, or Chen's theorem that every sufficiently large even number is the sum of a prime and a semiprime. Explore connections to sieve methods and the circle method.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.294221+00:00"
  },
  {
    "id": "seed_002",
    "title": "Riemann Hypothesis",
    "description": "Prove that all non-trivial zeros of the Riemann zeta function lie on Re(s)=1/2. Formalize equivalent statements: the prime counting function error bound, the Mertens conjecture connection, or the spectral interpretation via random matrix theory. Explore connections to quantum chaos and the Hilbert-Polya conjecture.",
    "domains": [
      "NumberTheory",
      "Analysis"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.302055+00:00"
  },
  {
    "id": "seed_095",
    "title": "Topological Quantum Error Correction from Homological Persistence",
    "description": "The key insight is that persistent homology \u2014 the backbone of topological data analysis \u2014 provides a natural framework for quantum error correction. Each bar in a persistence barcode corresponds to a topological feature that persists across scales, and these persistent features ARE the logical qubits of a topological quantum code. Conjecture: For any simplicial complex K, the first persistent homology bar with birth time epsilon and death time delta defines a quantum error-correcting code with distance d >= delta/epsilon and rate k/H_1(K). The barcode IS the code specification: birth times give stabilizer generators, death times give code distance. Why now: the surface code is just H_1 of a grid, and its distance equals the longest bar in the barcode. This generalizes immediately. Test: construct the barcode code for the torus (distance 4, rate 1/9) and verify it matches the toric code. Prove the distance bound for arbitrary complexes. Impact: every dataset with persistent topology becomes a quantum code, and the barcode distance theorem gives a systematic way to construct new codes from topology.",
    "domains": [
      "Physics",
      "Topology",
      "Computation"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.057726+00:00"
  },
  {
    "id": "seed_014",
    "title": "Hodge Conjecture",
    "description": "Prove that every Hodge class on a non-singular projective algebraic variety is a rational linear combination of classes of algebraic cycles. Formalize the Hodge decomposition and explore the conjecture for specific varieties like abelian varieties and K3 surfaces.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.387127+00:00"
  },
  {
    "id": "seed_016",
    "title": "Navier-Stokes Existence and Smoothness",
    "description": "Prove existence and smoothness of solutions to the 3D Navier-Stokes equations, or find a counterexample. Formalize known partial regularity results (Caffarelli-Kohn-Nirenberg) and explore connections to turbulence.",
    "domains": [
      "Analysis",
      "Physics"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.403036+00:00"
  },
  {
    "id": "seed_017",
    "title": "Birch and Swinnerton-Dyer Conjecture",
    "description": "Prove that the rank of an elliptic curve equals the order of vanishing of its L-function at s=1. Formalize the BSD formula including the regulator, Tate-Shafarevich group, and Tamagawa numbers.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.411437+00:00"
  },
  {
    "id": "seed_096",
    "title": "Neural Network Training as Renormalization Group Flow",
    "description": "The key insight is that neural network training is a renormalization group (RG) flow in function space. Each training step integrates out high-frequency modes (gradient descent on fast-varying parameters), just as each RG step integrates out short-distance modes. Conjecture: The fixed points of SGD on neural networks are precisely the critical points of a renormalization group flow defined by the coarse-graining operator that averages over parameter subsets. Why now: recent work on neural network Gaussian processes shows that infinite-width networks have exact RG fixed points, and the beta function of SGD training has been computed for linear networks. Test: prove that for a 2-layer ReLU network trained on isotropic data, the SGD fixed point corresponds to the Wilson-Fisher fixed point in d=2 dimensions, and compute the critical exponents. Impact: neural network training would be governed by universality classes, meaning the same network trained on different data converges to the same fixed point if the data distribution is in the same universality class.",
    "domains": [
      "MachineLearning",
      "Physics",
      "Analysis"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.066174+00:00"
  },
  {
    "id": "seed_101",
    "title": "AdS/CFT for Proof Theory: Holographic Verification",
    "description": "The key insight is that the AdS/CFT correspondence in physics says a gravitational theory in the bulk is equivalent to a conformal field theory on the boundary. Translate this to proof theory: a proof of length n in the bulk (the full proof) corresponds to a verified specification of length O(log n) on the boundary (a certificate). Conjecture: Every proof of a theorem T in Peano Arithmetic of length n has a holographic certificate of length O(log n) that can be verified in time O((log n)^2). The certificate is constructed by projecting each proof step onto the boundary of the proof space (the initial axioms and final conclusion) and keeping only the holographic data. Why now: the PCP theorem already shows that proofs have short probabilistic certificates, but holographic verification would give DETERMINISTIC short certificates \u2014 a much stronger result. Test: for a specific proof system (Frege), construct holographic certificates for proofs of the pigeonhole principle and verify that the certificate length is O(log n). Impact: proof verification becomes as fast as reading the theorem statement, enabling trustless proof checking at scale.",
    "domains": [
      "Logic",
      "Computation",
      "Physics"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.118574+00:00"
  },
  {
    "id": "seed_004",
    "title": "Twin Prime Conjecture",
    "description": "Prove that there are infinitely many pairs of primes differing by 2. Formalize Zhang's bounded gaps result and Maynard-Tao improvements. Explore connections to the Hardy-Littlewood conjecture and sieve theory.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.93,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.316578+00:00"
  },
  {
    "id": "seed_015",
    "title": "Yang-Mills Mass Gap",
    "description": "Prove that for any compact simple gauge group, quantum Yang-Mills theory on R^4 exists and has a mass gap. Formalize the mathematical framework of gauge theory and connect to lattice gauge theory computations.",
    "domains": [
      "Physics",
      "Analysis"
    ],
    "priority_score": 0.93,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.395345+00:00"
  },
  {
    "id": "seed_097",
    "title": "Cryptography from the Collatz Conjecture: One-Way Functions from Iterated Maps",
    "description": "The key insight is that the Collatz map T(n) = n/2 if n even, 3n+1 if n odd, appears to be a one-way function: easy to compute forward (polynomial time), intractable to invert (finding a preimage requires exponential search). Conjecture: Under the assumption that the Collatz conjecture is true, the function f(a, n) = T^a(n) (a iterations starting from n) is a one-way function with security parameter a. The inversion problem \u2014 given (a, f(a,n)), find n \u2014 requires O(2^{a/log(a)}) steps. Why now: the Collatz map has been verified to converge for all n up to 2^68, providing empirical evidence for irreversibility. Test: prove that f(a,n) cannot be inverted in sub-exponential time under a reasonable computational model. Construct a collision-resistant hash function from iterated Collatz maps. Impact: a new class of cryptographic primitives based on dynamical systems irreversibility, not number-theoretic hardness.",
    "domains": [
      "Cryptography",
      "NumberTheory",
      "Computation"
    ],
    "priority_score": 0.93,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.074843+00:00"
  },
  {
    "id": "seed_100",
    "title": "Entropy as a Topological Invariant: The Boltzmann Bridge",
    "description": "The key insight is that Boltzmann entropy S = k log W is a topological invariant of the energy landscape. If the energy function E: X -> R on a state space X defines a filtration by sublevel sets X_t = {x : E(x) <= t}, then the persistent homology barcode of this filtration encodes the entropy as the sum of bar lengths: S(E) = k * sum_i (d_i - b_i) where b_i and d_i are birth and death times of persistent homology bars. Conjecture: The Boltzmann entropy of a physical system equals the total persistence (sum of bar lengths) of the energy landscape filtration, up to an additive constant. Why now: persistent homology has matured as a computational tool, and the stability theorem guarantees that small perturbations in the energy function produce small changes in the barcode \u2014 exactly the thermodynamic stability we expect. Test: compute the persistent homology barcode for the Ising model energy landscape on a 4x4 lattice and verify that sum of bar lengths equals k log(2^{16}) = 16k log 2. Impact: entropy becomes a computable topological quantity, bridging thermodynamics and algebraic topology. Phase transitions correspond to births of new bars in the barcode.",
    "domains": [
      "Physics",
      "Topology",
      "Analysis"
    ],
    "priority_score": 0.93,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.107798+00:00"
  },
  {
    "id": "seed_038",
    "title": "Langlands Program: Functoriality",
    "description": "Prove specific cases of Langlands functoriality: the transfer from GL(2) to GL(3), or symmetric power liftings. Formalize automorphic representations and L-functions in Lean 4.",
    "domains": [
      "Algebra",
      "NumberTheory",
      "Bridges"
    ],
    "priority_score": 0.92,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.574939+00:00"
  },
  {
    "id": "seed_053",
    "title": "Certified Novelty Detection for Theorem Provers",
    "description": "Design and prove correct a novelty certification system that formally verifies each research output contains genuinely new mathematics. Construct a theorem embedding space where distance bounds novelty.",
    "domains": [
      "Logic",
      "Computation",
      "Bridges"
    ],
    "priority_score": 0.92,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.687353+00:00"
  },
  {
    "id": "seed_099",
    "title": "Self-Referential Type Theory: Proofs That Modify Their Own Specifications",
    "description": "The key insight is that Godel's incompleteness arises because a formal system cannot prove statements about itself \u2014 but a TYPE SYSTEM can. Construct a dependent type theory where types can refer to their own terms, creating a system where proofs can modify the specifications they are proving. Conjecture: There exists a consistent type theory T in which the type Type : Type is stratified by a self-reference level, and T can prove its own consistency within each level. The stratification prevents the paradox: Type_n : Type_{n+1} allows self-reference at level n without contradiction at level n+1. Why now: homotopy type theory has shown that types can be spaces, and the univalence axiom provides a principled way to equate equivalent types. Self-referential types are the natural next step. Test: formalize a type theory where terms can modify type specifications, prove that it is consistent by constructing a model in the category of globular sets, and show that Godel's incompleteness theorem does not apply because the stratification prevents diagonalization. Impact: a new foundation for mathematics where proofs can evolve their own specifications, enabling self-improving formal systems.",
    "domains": [
      "Logic",
      "Algebra",
      "Speculative"
    ],
    "priority_score": 0.92,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.097627+00:00"
  },
  {
    "id": "seed_056",
    "title": "Self-Modifying Research via Reflective Type Theory",
    "description": "Formalize a research system as a dependent type where the type of the next cycle depends on outcomes of previous cycles. Prove that reflective self-improvement converges.",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "priority_score": 0.91,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.707683+00:00"
  },
  {
    "id": "seed_098",
    "title": "Consciousness Complexity: Integrated Information as a Topological Invariant",
    "description": "The key insight is that Tononi's Phi (integrated information) may be a topological invariant, not just a measure. If neural states form a sheaf over the brain's connectome, then Phi equals the dimension of the first sheaf cohomology group H^1(C, F) where C is the connectome graph and F is the neural state sheaf. Conjecture: Phi is a topological invariant of the sheaf (C, F) \u2014 it is preserved under sheaf isomorphisms and changes continuously under continuous deformation of the connectome. A system with Phi = 0 has H^1 = 0 (acyclic sheaf, no information integration), while Phi > 0 means H^1 > 0 (cycles in the sheaf, integrated information). Why now: sheaf cohomology has been successfully applied to neural coding by Curry (2019), and the connection between Phi and cohomology was conjectured by Tegmark (2019) but never formalized. Test: compute Phi for small connectome topologies (chain, ring, complete graph) and show Phi = dim(H^1) in each case. Impact: consciousness becomes a mathematical invariant with the same status as the Euler characteristic \u2014 a topological quantity that can be computed, compared, and used to classify systems.",
    "domains": [
      "Speculative",
      "Topology",
      "Physics"
    ],
    "priority_score": 0.91,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.085984+00:00"
  },
  {
    "id": "seed_104",
    "title": "Zeta Functions of Directed Graphs and the Graph Riemann Hypothesis",
    "description": "The key insight is that every directed graph G has a zeta function zeta_G(s) = prod(1 - lambda^{-s})^{-1} where the product is over eigenvalues of the graph's adjacency matrix, and the Riemann Hypothesis for this function is equivalent to a purely combinatorial condition on G. Conjecture: For a directed graph G with n vertices, zeta_G(s) satisfies the Riemann Hypothesis (all non-trivial zeros lie on Re(s) = 1/2) if and only if G is a Ramanujan digraph: every eigenvalue lambda of the adjacency matrix satisfies |lambda| <= 2 sqrt(d-1) where d is the maximum out-degree. This is the directed graph analog of the Ramanujan graph theorem of Lubotzky-Phillips-Sarnak. Why now: the undirected case is settled (Ramanujan graphs exist and have optimal spectral gap), but the directed case is wide open. Recent work by Lubetzky and Peres (2016) on cutoff on directed Ramanujan graphs suggests the spectral gap characterization extends. Test: prove the conjecture for directed Cayley graphs of finite groups, then verify computationally for random directed d-regular graphs with n=20, 50, 100 vertices. Impact: a combinatorial Riemann Hypothesis \u2014 if true, it means the deepest mystery of number theory has a purely graph-theoretic characterization.",
    "domains": [
      "Algebra",
      "NumberTheory",
      "Computation"
    ],
    "priority_score": 0.91,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.144820+00:00"
  },
  {
    "id": "seed_029",
    "title": "ABC Conjecture Formalization",
    "description": "Formalize the ABC conjecture and its implications in Lean 4. Prove consequences: Fermat's Last Theorem for large exponents, Roth's theorem strengthening, Mordell conjecture. Explore Mochizuki's claimed proof structure.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.506101+00:00"
  },
  {
    "id": "seed_054",
    "title": "Proof Strategy Mining from Deep Mathematics",
    "description": "Reverse-engineer proof strategies from deep results (FLT, Poincar\u00e9, classification of finite simple groups) and extract reusable structural patterns as higher-order proof schemata.",
    "domains": [
      "Logic",
      "Algebra",
      "Bridges"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.694274+00:00"
  },
  {
    "id": "seed_079",
    "title": "Retrocausal Proof Theory: Proving Theorems by Their Consequences",
    "description": "Develop a proof theory where the validity of a theorem can be established not just by deriving it from axioms, but by verifying that its logical consequences form a coherent, self-consistent structure. Conjecture: There exists a class of consequence-stable propositions P such that if P implies Q1 and Q2 ... Qn and all Qi are verified, then P has a proof shorter than any direct proof by at least a constant factor. Test: identify consequence-stable propositions in Peano arithmetic and measure proof compression. A consequence-stable proposition P has the property that all its logical consequences are mutually consistent, and the set of verified consequences narrows the search space for P's proof. This is analogous to how in physics, the consequences of a theory (predictive power) can confirm the theory even before a mechanism is found. Retrocausal proof theory would enable a new form of automated theorem proving where consequence verification guides proof search, not just axiom chaining. Impact: a new paradigm for automated theorem proving where consequences guide proof search, not just axioms.",
    "domains": [
      "Logic",
      "Speculative",
      "Computation"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.907595+00:00"
  },
  {
    "id": "seed_084",
    "title": "EML Fixed-Point Theorem: exp-log Iteration Convergence",
    "description": "The EML single operator f(x) = e^a * log(b*x + c) is a contraction mapping for suitable parameter ranges. Conjecture: For all a, b, c in R with a > 0 and b, c chosen so that the function maps a closed interval to itself, the iteration x_{n+1} = e^a * log(b*x_n + c) converges to a unique fixed point x* at a rate O(rho^n) where rho = |f'(x*)|. Moreover, the fixed point x* satisfies x* = e^a * log(b*x* + c) and can be expressed as a power series in a. The fixed point is unique because f is a contraction on the invariant interval: the derivative f'(x) = e^a * b / (b*x + c) is bounded by |f'| < 1 when the parameters are in the right range. This makes EML functions well-behaved iterative schemes, unlike arbitrary neural network activations. Test: prove convergence for the specific case a in (0,1), b=1, c in (0,1) and compute the fixed point explicitly as a series. Impact: establishes EML as having well-defined dynamical behavior, enabling EML-based iterative algorithms with certified convergence.",
    "domains": [
      "EML",
      "Analysis",
      "Computation"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.953715+00:00"
  },
  {
    "id": "seed_102",
    "title": "Biological Topology: Protein Folding as Persistent Homology Optimization",
    "description": "The key insight is that protein folding minimizes a topological energy: the persistent homology barcode of the protein's contact map. The native fold of a protein is the configuration that minimizes the total persistence of the contact filtration. Conjecture: The native state of a protein P minimizes sum_i (d_i - b_i) over all possible 3D configurations, where {b_i, d_i} is the persistent homology barcode of the distance matrix of P's C-alpha atoms. Why now: AlphaFold2 showed that contact maps are sufficient for structure prediction, but it used deep learning without understanding WHY contact maps work. Persistent homology provides the mathematical reason: the barcode captures the topological constraints (no self-intersection, hydrophobic core, etc.) that determine the fold. Test: compute the barcode for 100 proteins from the PDB and verify that the native fold has lower total persistence than 1000 random decoy folds for each protein. Impact: protein folding becomes a topological optimization problem with a provably unique minimum, explaining why folding is fast and reliable despite Levinthal's paradox.",
    "domains": [
      "Physics",
      "Topology",
      "MachineLearning"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.127465+00:00"
  },
  {
    "id": "seed_003",
    "title": "Hadamard Matrix Conjecture",
    "description": "Prove that a Hadamard matrix exists for every positive multiple of 4. Formalize known constructions (Sylvester, Paley, tensor products) and establish bounds on the smallest open order. Connect to combinatorial designs, error-correcting codes, and signal processing.",
    "domains": [
      "Algebra",
      "Combinatorics"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.308847+00:00"
  },
  {
    "id": "seed_013",
    "title": "Odd Perfect Numbers",
    "description": "Prove that no odd perfect numbers exist. Formalize known constraints: must exceed 10^1500, have at least 101 prime factors, satisfy Euler's form p^a * m^2. Connect to the structure of multiplicative functions.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.378958+00:00"
  },
  {
    "id": "seed_043",
    "title": "Certified Adversarial Robustness via Sheaf Cohomology",
    "description": "Prove that vanishing first sheaf cohomology on neural network weight spaces implies certified L-infinity perturbation radius. Construct explicit sheaf structures on decision boundaries whose stalk cohomology detects adversarial vulnerability.",
    "domains": [
      "MachineLearning",
      "Algebra",
      "Bridges"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.613489+00:00"
  },
  {
    "id": "seed_055",
    "title": "Research Depth via Proof-Theoretic Ordinal Analysis",
    "description": "Prove that proof-theoretic ordinal analysis provides a rigorous depth metric for mathematical research. Construct a formalization that computes the proof-theoretic ordinal of research output.",
    "domains": [
      "Logic",
      "Computation"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.701095+00:00"
  },
  {
    "id": "seed_068",
    "title": "EML Single Operator Church-Turing Thesis",
    "description": "Formalize the conjecture that e^a * log(b) is a universal primitive for real computation. Conjecture: Every computable real function f: R^n -> R can be expressed as a finite composition of e^x, log(x), constants, and field operations. Test: prove this for the class of elementary functions (sin, cos, exp, log, polynomials) by showing each reduces to EML compositions. If true, this means a single EML neuron (exp+log) is computationally universal.",
    "domains": [
      "EML",
      "Computation",
      "Logic"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.808552+00:00"
  },
  {
    "id": "seed_080",
    "title": "Mobius Arithmetic: Number Theory on the Mobius Band",
    "description": "Construct a number system on the Mobius band where the integers wrap with a twist: n and -n are identified with opposite orientations. Define the Mobius integers Z_tilde as Z x {+1, -1} modulo the identification (n, +1) ~ (-n, -1). Develop arithmetic on Z_tilde where addition wraps through the identification. Conjecture: The ring Z_tilde of Mobius integers has class number 1, and its prime spectrum forms a double cover of the ordinary primes (each ordinary prime p splits into two oriented primes p_plus and p_minus). The Mobius zeta function zeta_tilde(s) has zeros off the critical line, which is expected since Z_tilde is a non-Ore ring. Test: factor 6 in Z_tilde as 2_plus times 3_plus and 2_minus times 3_minus and verify these are distinct factorizations. Prove unique factorization for Z_tilde up to orientation. Impact: a new algebraic number system with intrinsic orientation, connecting number theory to topology via the double cover Z to Z_tilde.",
    "domains": [
      "Geometry",
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.916894+00:00"
  },
  {
    "id": "seed_085",
    "title": "EML Differential Calculus: Chain Rules for exp-log Compositions",
    "description": "The EML operator class (finite compositions of exp, log, +, *) has remarkable closure properties. Conjecture: The class of EML functions is closed under differentiation, and the derivative of any EML function of composition depth d is an EML function of composition depth at most d+1. Moreover, the derivative has a canonical EML chain rule form: (exp(h) * log(g))' = exp(h) * log(g) * (h' + g'/g). This factorization is the key structural insight: the derivative of an EML function factors through the original function itself, multiplied by a simple expression involving only the inner functions and their derivatives. This is stronger than the general Leibniz rule because the EML structure forces the derivative into a canonical form. For depth-d EML functions, the derivative can be written recursively as f' = f * (h'_1 + g'_1/g_1) where each h'_i and g'_i are depth-(d-1) EML functions. Test: compute the 3rd derivative of f(x) = exp(x^2) * log(x+1) and verify it can be written as an EML expression. Impact: establishes that EML functions form a differential algebra, enabling automatic EML differentiation for verified numerical computation.",
    "domains": [
      "EML",
      "Analysis",
      "Algebra"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.961577+00:00"
  },
  {
    "id": "seed_089",
    "title": "Stereographic Sheaf Theory: Gluing Data on Spheres",
    "description": "Sheaf theory studies how local data glues to form global objects. The stereographic projection gives S^n a two-chart atlas with Mobius transition maps. Define a new class of sheaves called stereographic sheaves where the gluing data is constrained by the conformal structure of the stereographic atlas. A stereographic sheaf on S^n is a sheaf F such that for each chart U_i of the stereographic cover, the restriction F|U_i is a sheaf on R^n, and the transition function F(U_0 cap U_1) is a sheaf morphism that commutes with the Mobius transition. Conjecture: The category of stereographic sheaves on S^n is a proper subcategory of all sheaves on S^n, characterized by the condition that Cech cohomology with respect to the stereographic cover satisfies a Mobius compatibility. This subcategory has better computational properties: H^k(S^n, F) can be computed from the transition function alone for stereographic sheaves, reducing the computation of sheaf cohomology on S^n to a single gluing datum. Test: prove the equivalence with locally constant sheaves on RP^n for n=2,3. Compute H^1(S^2, Z) = Z/2Z for the constant sheaf Z. Impact: a new computational tool for sheaf cohomology that exploits conformal structure, with applications to topological data analysis and differential equations on spheres.",
    "domains": [
      "Geometry",
      "Algebra",
      "Topology"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.996007+00:00"
  },
  {
    "id": "seed_024",
    "title": "Legendre's Conjecture",
    "description": "Prove that for every positive integer n, there exists a prime between n\u00b2 and (n+1)\u00b2. Formalize known partial results on prime gaps and connect to the Cram\u00e9r model of primes.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.470511+00:00"
  },
  {
    "id": "seed_039",
    "title": "Quantum Error Correction Bounds",
    "description": "Prove tight bounds on quantum error-correcting codes. Formalize the quantum Singleton bound, quantum Hamming bound, and construct optimal stabilizer codes. Connect to topological quantum computing.",
    "domains": [
      "Physics",
      "Computation",
      "Algebra"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.583311+00:00"
  },
  {
    "id": "seed_050",
    "title": "Tropical Satake Isomorphism for GL_n",
    "description": "Extend the tropical Satake isomorphism from GL_2 to GL_n. Prove that it defines a bijection between min-plus Hecke operators and W-invariant tropical polynomials, connecting representation theory to combinatorics.",
    "domains": [
      "Tropical",
      "Algebra",
      "Bridges"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.665768+00:00"
  },
  {
    "id": "seed_070",
    "title": "EML Kolmogorov-Arnold Representation",
    "description": "The Kolmogorov-Arnold theorem says any continuous f: [0,1]^n -> R can be written as a sum of 2n+1 continuous univariate functions. Conjecture: The inner univariate functions in the K-A representation can be chosen to be EML-type functions (exp-log compositions). Test: for n=2, construct the 5 inner functions explicitly as EML compositions that achieve the K-A decomposition for a specific target (e.g., x1*x2). Impact: directly connects EML to a deep representation theorem.",
    "domains": [
      "EML",
      "Analysis",
      "Bridges"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.827715+00:00"
  },
  {
    "id": "seed_081",
    "title": "Thermodynamic Proof Erasure: Landauer's Principle for Mathematics",
    "description": "Landauer's principle states that erasing one bit of information dissipates at least kT*ln(2) of heat. Apply this to proof theory: erasing a proof of theorem T to recover a shorter proof is an information-theoretic process with a thermodynamic cost. Conjecture: The minimum energy required to compress a proof of n steps into a proof of m steps (m < n) is at least kT*(n-m)*ln(2), and this bound is tight for proofs in propositional logic. A proof of length n contains n bits of information (each step is a binary choice in the search tree). Compressing it to m steps requires erasing n-m bits, each costing kT*ln(2) by Landauer. This gives a physical lower bound on proof compression that is independent of the proof system. Test: formalize proof compression as an irreversible computation and derive the Landauer bound. Compute the erasure cost for compressing a 1000-step proof of the fundamental theorem of algebra into a 100-step proof. Impact: connects information thermodynamics to proof complexity, providing a physical lower bound on proof compression.",
    "domains": [
      "Physics",
      "Computation",
      "Logic"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.927388+00:00"
  },
  {
    "id": "seed_086",
    "title": "EML Interpolation Theory: Stone-Weierstrass for exp-log Networks",
    "description": "The Stone-Weierstrass theorem guarantees that any continuous function can be approximated by an algebra that separates points and contains constants. Conjecture: The algebra of EML functions (finite compositions of exp, log, +, *) on any compact subset of R^n is dense in C(K) with a Jackson-type rate: for f in Lip_alpha(K), there exists an EML network of width O(epsilon^{-n/alpha}) approximating f within epsilon. The separation property is key: given x != y in K, the function g(t) = exp(a)*log(b*t + c) can separate them for appropriate parameters a, b, c (because g is strictly monotone for a, b > 0). The constants are included via c = exp(a)*log(c) for c > 0. This gives EML networks provable approximation guarantees with explicit rates, going beyond the existential guarantees of universal approximation theorems. Test: prove the separation property (given x != y in K, find EML parameters that separate them) and the rate bound for Lipschitz functions. Construct an EML network of width n approximating x^2 on [0,1] with explicit error bounds. Impact: gives EML networks provable approximation guarantees with explicit rates, surpassing the existential guarantees of universal approximation theorems.",
    "domains": [
      "EML",
      "Analysis",
      "MachineLearning"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.969692+00:00"
  },
  {
    "id": "seed_091",
    "title": "Stereographic Fourier Analysis: Spherical Harmonics via Plane Waves",
    "description": "The Fourier transform diagonalizes the Laplacian on R^n. The Laplace-Beltrami operator on S^n is diagonalized by spherical harmonics. Stereographic projection gives a conformal map S^n to R^n that modifies the metric by a conformal factor (1+|x|^2)^2/4. Define the stereographic Fourier transform: for f in L^2(S^n), set F(f)(k) = integral over S^n of f(x) * (1+|phi(x)|^2)^{-n/2} * e^{-2 pi i phi(x) * k} d sigma(x) where phi is the stereographic projection. Conjecture: The stereographic Fourier transform is an isometry L^2(S^n) to L^2(R^n) mapping spherical harmonics Y_l^m to generalized Hermite functions with explicit radial profiles. The transform preserves eigenvalues up to a conformal correction: Delta_{S^n} Y_l^m = -l(l+n-1) Y_l^m maps to Delta_{R^n}(F[Y_l^m]) = (-l(l+n-1) + n^2/4) F[Y_l^m] plus a lower-order correction. Test: derive the transform explicitly for n=2 and verify it sends Y_1^m to Hermite functions. Prove the Plancherel identity. Impact: enables Fourier analysis on spheres via classical Fourier analysis on R^n, with applications to quantum mechanics on curved spaces and computational harmonic analysis.",
    "domains": [
      "Geometry",
      "Analysis",
      "Physics"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.015985+00:00"
  },
  {
    "id": "seed_025",
    "title": "Primes of the Form n\u00b2+1",
    "description": "Prove that there are infinitely many primes of the form n\u00b2+1. Formalize Iwaniec's result on semi-primes of this form and connect to Friedlander-Iwaniec theorem on primes of form a\u00b2+b\u2074.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.477681+00:00"
  },
  {
    "id": "seed_040",
    "title": "Homotopy Type Theory Foundations",
    "description": "Formalize core HoTT results in Lean 4: the univalence axiom, higher inductive types, and the fundamental theorem of identity types. Prove that HoTT provides a constructive foundation for mathematics.",
    "domains": [
      "Logic",
      "Topology",
      "Algebra"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.591547+00:00"
  },
  {
    "id": "seed_048",
    "title": "Tropical Riemann-Roch Theorem",
    "description": "Prove the tropical Riemann-Roch theorem: for a tropical curve of genus g and a divisor D of degree d, the tropical rank r(D) satisfies r(D) - r(K-D) = d - g + 1. Formalize chip-firing and Baker-Norine theory.",
    "domains": [
      "Tropical",
      "Algebra",
      "Geometry"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.649949+00:00"
  },
  {
    "id": "seed_069",
    "title": "EML Neural Network Expressiveness: Depth vs Width",
    "description": "Prove depth-width tradeoffs specific to EML activation exp(w*x+b) - log(w'*x+b'). Conjecture: An EML network of depth d and width w can approximate any Lipschitz function on [0,1]^n with error O((w*d)^{-2/n}) \u2014 matching ReLU rates but with smoother gradients. Test: prove the lower bound by constructing an EML network that approximates x^2 on [0,1] with error O(w^{-2}) using depth 2. Compare with ReLU's O(w^{-1}) rate.",
    "domains": [
      "EML",
      "MachineLearning",
      "Analysis"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.817888+00:00"
  },
  {
    "id": "seed_074",
    "title": "Inverse Stereographic Cryptography: Projection as One-Way Function",
    "description": "Use inverse stereographic projection S^n -> R^n as a cryptographic primitive. The forward map (point on sphere to plane) is easy, but recovering the original point from the plane projection requires the pole parameter. Conjecture: Finding the pole of stereographic projection from only (image set, projection point) is as hard as the shortest vector problem in a lattice. Test: formalize the reduction from SVP to pole-finding for n=2. Impact: a new geometric foundation for lattice-based cryptography.",
    "domains": [
      "Geometry",
      "Cryptography",
      "Computation"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.861448+00:00"
  },
  {
    "id": "seed_082",
    "title": "Fractal Topology: Hausdorff Dimension as a Topological Invariant",
    "description": "The Hausdorff dimension is normally a metric property, not a topological one. Investigate whether it can be made topological through the lens of fractal topology. Define the fractal topological dimension d_f(X) of a metric space X as the infimum of d such that X embeds in R^d with Hausdorff dimension preserved. Conjecture: For compact metric spaces, the Hausdorff dimension is a topological invariant modulo homeomorphisms that are bi-Lipschitz on a dense open set. More precisely, if X and Y are homeomorphic compact subsets of R^n, and the homeomorphism is bi-Lipschitz on a set of full Hausdorff dimension in X, then dim_H(X) = dim_H(Y). This would mean that fractal dimension is not just a metric accident but a topological invariant up to rough isometries. Test: compute d_f for the Sierpinski gasket (expected: 1 since connected, Hausdorff dimension log3/log2) and the Cantor set (expected: 0 since totally disconnected). Prove that the Koch curve and any bi-Lipschitz-equivalent curve have equal Hausdorff dimensions. Impact: elevates fractal dimension from a metric curiosity to a topological invariant, with applications to shape classification and topological data analysis.",
    "domains": [
      "Geometry",
      "Topology",
      "Analysis"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.935767+00:00"
  },
  {
    "id": "seed_087",
    "title": "EML Information Geometry: Fisher Information of exp-log Models",
    "description": "Information geometry studies statistical manifolds via the Fisher information metric. Define the EML statistical manifold M_EML as the set of probability distributions parameterized by EML functions: p(x; theta) = exp(theta_1 * g_1(x)) * log(theta_2 * g_2(x) + theta_3) normalized to a probability distribution. Conjecture: The EML manifold M_EML is a dually flat statistical manifold whose dual potentials are the cumulant generating functions of the EML activation. The Fisher information on M_EML induces a Hessian metric with constant negative curvature, making it a hyperbolic geometry of model parameters. This means natural gradient descent on M_EML has well-defined geodesics, and the dual flatness enables efficient Fisher vector products. The negative curvature reflects the exponential sensitivity of EML networks to parameter changes: small perturbations in theta cause exponentially large changes in the output. Test: compute the Fisher metric for a single EML neuron f(x; a,b) = exp(a)*log(b*x+1) and verify it induces a Hessian manifold with constant negative curvature. Prove that the alpha-connections on M_EML are projectively flat for alpha=1. Impact: gives EML networks a differential-geometric foundation for natural gradient descent, with provable convergence properties.",
    "domains": [
      "EML",
      "MachineLearning",
      "Probability"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.978415+00:00"
  },
  {
    "id": "seed_090",
    "title": "Inverse Stereographic Neural Field Theory",
    "description": "Neural field equations model macroscopic brain dynamics as PDEs on cortical surfaces. The cortical surface is topologically a sphere with cortical folds. Use inverse stereographic projection to transform neural field PDEs on S^2 into PDEs on R^2 with a conformal weight. Define a stereographic neural field as a function u: S^n to R satisfying Delta_{S^n} u = f(u) where Delta_{S^n} is the Laplace-Beltrami operator on the sphere. Under inverse stereographic projection, this becomes a PDE on R^n with a conformally modified Laplacian. Conjecture: The neural field equation on S^2 with Mexican-hat connectivity has exactly 2N+1 stable pattern solutions for interaction radius r, where N = floor(1/r). Under inverse stereographic projection, these correspond to N-fold symmetric patterns on R^2 that decay at infinity. The 2N+1 count comes from the representation theory of SO(3): each pattern of degree l has 2l+1 rotational variants, and the Mexican-hat kernel selects l = N. Test: prove the existence of 2N+1 patterns for r = 1/k (k=1,2,3) by constructing them as stereographic projections of spherical harmonics. Impact: a geometric theory of neural pattern formation with provable pattern counts, enabling predictions about visual hallucination patterns.",
    "domains": [
      "Geometry",
      "MachineLearning",
      "Physics"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.006665+00:00"
  },
  {
    "id": "seed_006",
    "title": "Collatz Conjecture",
    "description": "Prove that the 3n+1 iteration eventually reaches 1 for all positive integers. Formalize partial results on density of convergent integers, stopping times, and connections to ergodic theory and p-adic dynamics.",
    "domains": [
      "NumberTheory",
      "Computation"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.330478+00:00"
  },
  {
    "id": "seed_020",
    "title": "Hilbert 12: Kronecker-Weber Generalization",
    "description": "Extend the Kronecker-Weber theorem to arbitrary algebraic fields by constructing Hilbert class fields. Formalize explicit class field theory and connect to the Langlands program.",
    "domains": [
      "Algebra",
      "NumberTheory"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.438452+00:00"
  },
  {
    "id": "seed_033",
    "title": "Schanuel's Conjecture",
    "description": "Prove Schanuel's conjecture: if z\u2081,...,z\u2099 are Q-linearly independent complex numbers, then the transcendence degree of {z\u2081,...,z\u2099,e^z\u2081,...,e^z\u2099} over Q is at least n. Formalize implications for the Lindemann-Weierstrass theorem.",
    "domains": [
      "NumberTheory",
      "Analysis"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.537163+00:00"
  },
  {
    "id": "seed_041",
    "title": "Machine Learning Generalization Bounds",
    "description": "Prove tighter generalization bounds for deep neural networks. Formalize PAC-Bayes bounds, compression-based bounds, and connect network architecture to sample complexity. Establish when overparameterized networks provably generalize.",
    "domains": [
      "MachineLearning",
      "Computation",
      "Algebra"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.598768+00:00"
  },
  {
    "id": "seed_046",
    "title": "EML Universal Approximation",
    "description": "Prove that Exponential-Multiplicative-Logarithmic closures are universal approximators with provable complexity bounds. Show that minimum EML depth for \u03b5-approximation is O(K(f)/\u03b5), connecting to Kolmogorov complexity.",
    "domains": [
      "EML",
      "MachineLearning",
      "Algebra"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.634081+00:00"
  },
  {
    "id": "seed_062",
    "title": "Holographic Mathematics: Bulk-Boundary Proof Duality",
    "description": "Inspired by the AdS/CFT correspondence, formalize a mathematical holographic principle: a theorem about n-dimensional structures (the bulk) has a dual (shorter) proof in (n-1)-dimensional boundary terms. Conjecture: Every proof by induction on a well-founded order of rank n has an equivalent proof by coinduction on the n-1 boundary. Test: find a concrete theorem (e.g., finite Ramsey) and show its inductive proof in R^n maps to a coinductive proof on S^{n-1}. Impact: a new holographic proof theory connecting algebraic topology to proof complexity.",
    "domains": [
      "Physics",
      "Algebra",
      "Speculative"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.756189+00:00"
  },
  {
    "id": "seed_075",
    "title": "Stereographic Neural Attention: Attention via Riemann Sphere",
    "description": "Replace softmax attention with stereographic attention: map query/key vectors to the Riemann sphere via stereographic projection, compute Cauchy kernel K(q,k) = 1/(1+|q-k|^2) on the sphere, and project back. Conjecture: Stereographic attention has O(sqrt(N)) sparsity (most Cauchy weights are near-zero) while maintaining the universal approximation properties of softmax attention. Test: prove the sparsity bound for random queries on the unit sphere. Impact: a new attention mechanism with built-in sparsity and geometric structure.",
    "domains": [
      "Geometry",
      "MachineLearning",
      "Physics"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.870982+00:00"
  },
  {
    "id": "seed_088",
    "title": "EML Algebraic Independence: Transcendence Results",
    "description": "The Schanuel conjecture predicts deep algebraic independence results for exp and log. Specialize this to EML values. Conjecture: For algebraic numbers a_1,...,a_n linearly independent over Q, the numbers exp(a_1)*log(1+a_1), ..., exp(a_n)*log(1+a_n) are algebraically independent over Q. This is a specialization of Schanuel's conjecture to the EML operator. The n=1 case reduces to showing that exp(a)*log(1+a) is transcendental for algebraic a != 0, which follows from the Lindemann-Weierstrass theorem (exp(a) is transcendental for algebraic a != 0) combined with the Gelfond-Schneider theorem. The n=2 case requires showing that exp(sqrt(2))*log(1+sqrt(2)) and exp(sqrt(3))*log(1+sqrt(3)) satisfy no polynomial relation with algebraic coefficients, which is open. The EML specialization has the advantage that the multiplicative structure of exp(a)*log(b) constrains the possible algebraic relations more tightly than the general Schanuel conjecture. Test: prove the n=1 case using Lindemann-Weierstrass and Gelfond-Schneider. For n=2, show that exp(sqrt(2))*log(1+sqrt(2)) and exp(sqrt(3))*log(1+sqrt(3)) satisfy no polynomial relation with algebraic coefficients. Impact: connects EML to the deepest open problems in transcendental number theory, with implications for the theory of periods and special values of L-functions.",
    "domains": [
      "EML",
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.986795+00:00"
  },
  {
    "id": "seed_092",
    "title": "Inverse Stereographic Persistence: Topological Data Analysis on Spheres",
    "description": "Persistent homology computes topological features of data at multiple scales. On spheres, the natural metric is the geodesic (spherical) distance, but existing algorithms assume Euclidean data. Use stereographic projection to transform spherical persistence to weighted Euclidean persistence. Define the stereographic persistence module for a point cloud X on S^n: for each filtration parameter epsilon, compute the Cech complex C_epsilon(X) on S^n using the spherical metric, then apply inverse stereographic projection to get a filtered complex on R^n with a conformal weight. Conjecture: The persistence diagram of a point cloud on S^n computed with the geodesic metric is equal to the persistence diagram of the projected point cloud on R^n computed with a conformally weighted distance d_w(x,y) = 2*d(x,y)/(1+d(x,y)^2/4). This equality holds because stereographic projection is a conformal isometry up to the conformal factor, and persistence diagrams are invariant under conformal transformations. This gives an O(N log N) algorithm for spherical persistence (vs O(N^2) for direct computation). Test: implement both methods and verify isometry of persistence diagrams for random spherical point clouds with N=50, 100, 200 points. Impact: fast, provably correct topological data analysis for spherical data, with applications to astrophysics (cosmic microwave background) and protein structure analysis.",
    "domains": [
      "Geometry",
      "Computation",
      "Topology"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.026751+00:00"
  },
  {
    "id": "seed_030",
    "title": "Invariant Subspace Problem",
    "description": "Prove or disprove that every bounded linear operator on a separable Hilbert space has a non-trivial closed invariant subspace. Formalize known results for compact operators and normal operators.",
    "domains": [
      "Analysis",
      "Algebra"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.513281+00:00"
  },
  {
    "id": "seed_035",
    "title": "Kakeya Conjecture",
    "description": "Prove the Kakeya conjecture: a Besicovitch set in R\u207f has Hausdorff dimension n. Formalize the connection to restriction estimates and additive combinatorics.",
    "domains": [
      "Geometry",
      "Analysis"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.553079+00:00"
  },
  {
    "id": "seed_042",
    "title": "Category-Theoretic Neural Architectures",
    "description": "Formalize neural network architectures as morphisms in a monoidal category. Prove that ResNet skip connections are categorical products, attention is a natural transformation, and architecture search is optimization in a functor category.",
    "domains": [
      "MachineLearning",
      "Algebra",
      "Bridges"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.605600+00:00"
  },
  {
    "id": "seed_049",
    "title": "Tropical Brill-Noether Theory",
    "description": "Prove that a general tropical curve of genus g has a divisor of degree d and rank r iff the Brill-Noether number \u03c1 = g - (r+1)(g-d+r) \u2265 0. Formalize the connection to classical algebraic geometry.",
    "domains": [
      "Tropical",
      "Geometry",
      "Algebra"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.657271+00:00"
  },
  {
    "id": "seed_063",
    "title": "Quantum Topological Phase Computation",
    "description": "Formalize computation via topological phase transitions: each computation step is a braid group operation on anyonic worldlines. Conjecture: The braid group B_n is universal for computation when augmented with the F-matrix and R-matrix of SU(2)_k anyons for k>=3. Test: implement the Fibonacci anyon model in Lean 4 and prove that braiding generates a dense subset of SU(2). Impact: connects topological quantum computation to algebraic knot theory.",
    "domains": [
      "Computation",
      "Topology",
      "Physics"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.764550+00:00"
  },
  {
    "id": "seed_071",
    "title": "EML Training Dynamics as Tropical Gradient Flow",
    "description": "Model EML network training in the tropical limit (large weights) as a gradient flow on the tropical projective torus. Conjecture: In the tropical limit, the EML training dynamics converge to a piecewise-linear gradient flow whose fixed points correspond to tropical rational functions that minimize the tropical loss. Test: prove convergence for a single EML neuron trained on 3 data points in the tropical limit. Impact: bridges neural network optimization and tropical geometry.",
    "domains": [
      "EML",
      "Tropical",
      "MachineLearning"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.835896+00:00"
  },
  {
    "id": "seed_076",
    "title": "Inverse Stereographic Renormalization Group",
    "description": "The renormalization group in physics zooms out by integrating out high-energy modes. Formalize this as an inverse stereographic projection on the energy sphere: RG flow equals iterated stereographic projection with varying pole. Conjecture: The beta function beta(g) in phi^4 theory equals the derivative of the stereographic projection map at the critical coupling g*. Test: compute the stereographic map for the 1D Ising model and verify beta(g) matches. Impact: connects renormalization to conformal geometry.",
    "domains": [
      "Geometry",
      "Physics",
      "Algebra"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.880860+00:00"
  },
  {
    "id": "seed_083",
    "title": "Temporal Logic of Proofs: When You Prove Something Matters",
    "description": "Standard proof theory treats proofs as timeless: once proved, always proved. But in practice, proofs are discovered in time, and their dependencies form a temporal order. Formalize a temporal logic of proofs where the modal operator Box means provably established by time t. Conjecture: The temporal provability logic TGL (Temporal Godel-Lob) is decidable and strictly extends GL with the axiom Box A implies Box Box Diamond A (if provable now, provably will be provable at any future time). The key insight is that provability in PA is Sigma_1-complete: if PA proves A, then PA proves that PA proves A. Adding temporality creates a system where proof discovery has a well-defined causal order, and future provability can be reasoned about. Test: prove the arithmetical completeness of TGL relative to Peano Arithmetic with a time-stamped provability predicate. Show that the temporal paradox this statement will be provable tomorrow but not today is refutable in TGL. Impact: a new logic for reasoning about proof discovery in time, with applications to proof mining and automated theorem proving where proof order matters.",
    "domains": [
      "Logic",
      "Computation",
      "Speculative"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.945264+00:00"
  },
  {
    "id": "seed_093",
    "title": "Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geometry",
    "description": "Sphere packing on S^n (how many non-overlapping caps of radius r fit?) is a fundamental geometric problem with applications to error-correcting codes and signal processing. Use stereographic projection to transform spherical packing to a weighted packing problem on R^n. Define the stereographic packing number N(n,r) as the maximum number of non-overlapping spherical caps of geodesic radius r that fit on S^n. Conjecture: N(n,r) satisfies N(n,r) = (1+O(r^2)) * V_n/V_n(r) where V_n is the volume of S^n and V_n(r) is the volume of a cap, and the O(r^2) correction is explicitly computable from the conformal factor (1+|x|^2)^2/4 of the stereographic projection. More precisely, N(n,r) <= (2/cos(r))^n * V_n/V_n(r). The factor (2/cos(r))^n comes from the maximum conformal distortion of the stereographic projection: a cap of geodesic radius r is mapped to a Euclidean disk whose area differs from the cap area by at most this factor. Test: prove this bound for n=2 and verify it against the known optimal packings (icosahedral: N(2,pi/6) = 12, cuboctahedral: N(2,pi/4) = 6, tetrahedral: N(2,pi/3) = 4). Impact: explicit, computable sphere packing bounds on spheres via classical packing theory on R^n, with applications to spherical codes and molecular geometry.",
    "domains": [
      "Geometry",
      "Computation",
      "NumberTheory"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.036319+00:00"
  },
  {
    "id": "seed_012",
    "title": "Sums of Three Cubes",
    "description": "Determine which integers can be represented as a sum of three cubes. Formalize known computational results and the density conjecture. Connect to the geometry of cubic surfaces and the Hasse principle.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.373036+00:00"
  },
  {
    "id": "seed_023",
    "title": "Hilbert 16: Topology of Algebraic Curves",
    "description": "Study the topology of real algebraic curves and surfaces. Formalize the Harnack bound, classify real algebraic curves by arrangement of ovals, and connect to the second part on limit cycles of planar polynomial ODEs.",
    "domains": [
      "Geometry",
      "Topology"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.462191+00:00"
  },
  {
    "id": "seed_034",
    "title": "Jacobian Conjecture",
    "description": "Prove that if a polynomial map F: C\u207f \u2192 C\u207f has constant non-zero Jacobian determinant, then F is invertible. Formalize the reduction to degree 3 and connect to the Dixmier conjecture.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.544197+00:00"
  },
  {
    "id": "seed_037",
    "title": "Cram\u00e9r's Conjecture on Prime Gaps",
    "description": "Prove that the gap between consecutive primes p_n satisfies p_{n+1} - p_n = O((log p_n)\u00b2). Formalize probabilistic models of primes and known unconditional bounds.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.567677+00:00"
  },
  {
    "id": "seed_044",
    "title": "Spectral Graph Theory Meets Network Robustness",
    "description": "Prove that the algebraic connectivity of a neural network's computation graph bounds its certified robustness radius. Formalize the connection between graph spectra and function Lipschitz constants.",
    "domains": [
      "MachineLearning",
      "Algebra",
      "Geometry"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.619910+00:00"
  },
  {
    "id": "seed_072",
    "title": "EML Quantum Activation Functions",
    "description": "Define quantum EML neurons where exp and log are replaced by unitary exponentials: U = exp(iH) for Hermitian H, and the log is the matrix logarithm. Conjecture: The quantum EML neuron U = exp(iH1) * log(I+iH2) can implement any single-qubit unitary. Test: parameterize H1, H2 and prove the map covers SU(2). Impact: opens quantum-classical neural network bridges.",
    "domains": [
      "EML",
      "Physics",
      "MachineLearning"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.845249+00:00"
  },
  {
    "id": "seed_010",
    "title": "Happy End Problem",
    "description": "Solve the happy end problem for arbitrary n: determine the minimum number of points in general position in the plane that guarantee a convex n-gon. Formalize the Erd\u0151s\u2013Szekeres theorem and improve known bounds.",
    "domains": [
      "Geometry",
      "Combinatorics"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.359184+00:00"
  },
  {
    "id": "seed_018",
    "title": "Hilbert 6: Axiomatization of Physics",
    "description": "Develop a rigorous axiomatic foundation for physics, particularly for probability and mechanics. Formalize Kolmogorov's axioms, explore constructive quantum mechanics, and connect to topos-theoretic physics.",
    "domains": [
      "Physics",
      "Logic"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.419969+00:00"
  },
  {
    "id": "seed_027",
    "title": "Euler-Mascheroni Constant Irrationality",
    "description": "Prove that the Euler-Mascheroni constant \u03b3 \u2248 0.5772 is irrational (or transcendental). Formalize continued fraction expansions and connect to the theory of special values of L-functions.",
    "domains": [
      "Analysis",
      "NumberTheory"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.490974+00:00"
  },
  {
    "id": "seed_036",
    "title": "Beal's Conjecture",
    "description": "Prove that if A^x + B^y = C^z where A,B,C,x,y,z are positive integers with x,y,z > 2, then A,B,C share a common prime factor. Formalize the connection to Fermat-Catalan and ABC conjecture.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.559748+00:00"
  },
  {
    "id": "seed_045",
    "title": "Reversible Computing and Thermodynamic Efficiency",
    "description": "Prove that reversible circuits achieve Landauer's bound for erasure. Formalize the connection between computational complexity and thermodynamic entropy. Construct provably optimal reversible implementations of common algorithms.",
    "domains": [
      "Computation",
      "Physics"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.626763+00:00"
  },
  {
    "id": "seed_047",
    "title": "Pythagorean Triple Group Structure",
    "description": "Prove deep structural theorems about the Berggren tree of Pythagorean triples. Formalize the groupoid action on SL(3,Z), the prime distribution along hypotenuse lengths, and computational applications of the tree structure.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "NumberTheory"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.642160+00:00"
  },
  {
    "id": "seed_051",
    "title": "Tropical Intersection Theory",
    "description": "Prove that the tropicalization functor preserves intersection numbers. Formalize tropical varieties as polyhedral complexes and establish the tropical B\u00e9zout theorem with explicit bounds.",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.672853+00:00"
  },
  {
    "id": "seed_061",
    "title": "Non-Archimedean Probability via Surreal Numbers",
    "description": "Develop a probability theory on Conway's surreal numbers where infinitesimal probabilities are well-defined. Conjecture: There exists a surreal-valued probability measure on [0,1] that assigns non-zero infinitesimal probability to each point but still integrates to 1. Test: construct the measure and verify additivity for finite unions. If true, this opens a new foundation for probability with infinitesimals, connecting to nonstandard analysis and surreal game theory.",
    "domains": [
      "Analysis",
      "Speculative",
      "Bridges"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.748891+00:00"
  },
  {
    "id": "seed_073",
    "title": "EML Category: The Category of EML-Computable Maps",
    "description": "Define the category EML_Comp where objects are R^n and morphisms are functions computable by finite EML compositions (exp, log, +, *, constants). Conjecture: EML_Comp is a Cartesian closed category with natural numbers object R (the reals). Test: prove closure under composition (trivial), products (pairing), and exponentials (currying via EML parameter sharing). Impact: puts EML computation on firm categorical foundations.",
    "domains": [
      "EML",
      "Algebra",
      "Logic"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.854005+00:00"
  },
  {
    "id": "seed_077",
    "title": "Stereographic Proof Compression: Proofs on Spheres",
    "description": "A proof is a sequence of steps. Map each step to a point on S^n via stereographic projection. The proof distance between theorems is the spherical distance between their proof endpoints. Conjecture: Two theorems whose proofs are close in spherical distance share a common subproof of length at least n minus spherical_distance. Test: compute proof distances for a set of 20 basic theorems in Lean 4 and verify the subproof bound. Impact: geometric proof mining and automated lemma discovery.",
    "domains": [
      "Geometry",
      "Logic",
      "Computation"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.890109+00:00"
  },
  {
    "id": "seed_011",
    "title": "Perfect Cuboid (Euler Brick)",
    "description": "Find an Euler brick whose space diagonal is also an integer, or prove none exists. Formalize the parametric families of near-misses and connect to Diophantine equations on algebraic surfaces.",
    "domains": [
      "NumberTheory",
      "Geometry"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.366802+00:00"
  },
  {
    "id": "seed_019",
    "title": "Hilbert 11: Quadratic Forms over Algebraic Fields",
    "description": "Extend results on quadratic forms to arbitrary algebraic number fields. Formalize the Hasse-Minkowski theorem and explore the classification of quadratic forms over number fields via class field theory.",
    "domains": [
      "Algebra",
      "NumberTheory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.429656+00:00"
  },
  {
    "id": "seed_022",
    "title": "Hilbert 15: Schubert Calculus Rigorization",
    "description": "Provide rigorous foundations for Schubert's enumerative geometry. Formalize intersection theory on Grassmannians and flag varieties, proving Schubert calculus results via modern algebraic geometry.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.455464+00:00"
  },
  {
    "id": "seed_031",
    "title": "Frankl's Union-Closed Conjecture",
    "description": "Prove that for every finite union-closed family of sets (not all empty), some element belongs to at least half the sets. Formalize the lattice-theoretic reformulation and known partial results.",
    "domains": [
      "Combinatorics",
      "Algebra"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.520566+00:00"
  },
  {
    "id": "seed_057",
    "title": "Consciousness as Integrated Information",
    "description": "Formalize integrated information theory (IIT) in Lean 4. Define Phi as a measure on causal structures, prove its key properties (composition, exclusion), and explore connections to category theory and complexity.",
    "domains": [
      "Speculative",
      "Logic",
      "Computation"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.714432+00:00"
  },
  {
    "id": "seed_064",
    "title": "Strange Attractors as Algebraic Objects",
    "description": "Treat chaotic attractors (Lorenz, Henon, Rossler) as algebraic objects \u2014 not just numerical phenomena. Conjecture: The Lorenz attractor's topology can be characterized as the inverse limit of a specific diagram in the category of finite directed graphs. Test: compute the inverse limit and compare its Cech cohomology to the known Lorenz template. Impact: if true, chaotic dynamics become amenable to algebraic topology and category-theoretic methods.",
    "domains": [
      "Analysis",
      "Algebra",
      "Speculative"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.771675+00:00"
  },
  {
    "id": "seed_078",
    "title": "Inverse Stereographic Tropical Lift",
    "description": "Tropical geometry replaces + with max and * with +. Stereographic projection maps spheres to planes. What is the tropical stereographic projection? Define it as: map a tropical point (x1 + ... + xn) on the tropical projective space to a tropical hyperplane via an analogous pole construction. Conjecture: The tropical stereographic projection is a tropical rational function of degree 2 (a tropical Mobius transformation). Test: construct it explicitly for TP^1 -> TR^1 and prove it is a tropical homeomorphism. Impact: connects tropical geometry and conformal geometry.",
    "domains": [
      "Geometry",
      "Tropical",
      "Algebra"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.899298+00:00"
  },
  {
    "id": "seed_026",
    "title": "Lehmer's Mahler Measure Problem",
    "description": "Determine whether Lehmer's polynomial has the smallest Mahler measure among non-cyclotomic polynomials. Formalize the Mahler measure and its connections to heights, entropy, and algebraic dynamics.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.484135+00:00"
  },
  {
    "id": "seed_009",
    "title": "Symmetric Group Generation Probability",
    "description": "Find a formula for the probability that two elements chosen uniformly at random generate the symmetric group S_n. Formalize known asymptotic results and connect to the theory of random permutations.",
    "domains": [
      "Algebra",
      "Combinatorics",
      "Probability"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.351682+00:00"
  },
  {
    "id": "seed_021",
    "title": "Hilbert 13: 7th-Degree Equations via 2-Variable Functions",
    "description": "Resolve whether the general 7th-degree equation can be solved using functions of only 2 variables. Formalize Kolmogorov's superposition theorem and explore its implications for approximation theory.",
    "domains": [
      "Algebra",
      "Analysis"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.446288+00:00"
  },
  {
    "id": "seed_052",
    "title": "Tropical Convexity and Helly Theorem",
    "description": "Prove a tropical analogue of Helly's theorem: characterize when tropical convex sets have non-empty intersection. Formalize tropical convex hulls and their connection to optimization.",
    "domains": [
      "Tropical",
      "Geometry",
      "Computation"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.679862+00:00"
  },
  {
    "id": "seed_065",
    "title": "Integrated Information via Tensor Networks",
    "description": "Formalize Tononi's Integrated Information Theory (IIT) using tensor network states. Conjecture: The integrated information Phi of a tensor network state equals the minimal quantum mutual information across any bipartition. Test: compute Phi for MPS (matrix product states) with bond dimension 2 and verify it matches the Schmidt rank. Impact: connects consciousness theory to quantum information and tensor categories.",
    "domains": [
      "Physics",
      "Computation",
      "Speculative"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.779231+00:00"
  },
  {
    "id": "seed_032",
    "title": "Erd\u0151s\u2013Straus Conjecture",
    "description": "Prove that for every integer n \u2265 2, the fraction 4/n can be written as a sum of three unit fractions. Formalize computational verification and parametric families of solutions.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.528620+00:00"
  },
  {
    "id": "seed_059",
    "title": "Game of Life Universality",
    "description": "Prove Conway's Game of Life is Turing complete via a direct constructive embedding. Formalize cellular automata in Lean 4 and establish complexity bounds on the simulation overhead.",
    "domains": [
      "Computation",
      "Speculative"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.731405+00:00"
  },
  {
    "id": "seed_028",
    "title": "Percolation Threshold",
    "description": "Derive an analytic form for the square site percolation threshold. Formalize bond vs site percolation, prove known exact thresholds for triangular lattices, and connect to conformal invariance.",
    "domains": [
      "Probability",
      "Physics"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.498731+00:00"
  },
  {
    "id": "seed_058",
    "title": "Alien Mathematics: Non-Standard Arithmetic",
    "description": "Explore what theorems hold in non-standard models of arithmetic. Formalize ultrapower constructions, transfer principles, and prove which classical theorems survive in non-Archimedean settings.",
    "domains": [
      "Speculative",
      "Logic",
      "Algebra"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.723031+00:00"
  },
  {
    "id": "seed_066",
    "title": "Alien Number Systems: Beyond Base-N",
    "description": "Explore number representation systems that are not base-N: factorial number system, Zeckendorf representation, balanced ternary with negative digits, and genuinely novel systems. Conjecture: There exists a number representation system with O(log* n) digit count (iterated logarithm) using recursive bases. Test: construct the tower-base representation and prove every natural number has a unique representation. Impact: if true, this gives sub-logarithmic number representations with implications for compression and coding theory.",
    "domains": [
      "NumberTheory",
      "Computation",
      "Speculative"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.788357+00:00"
  },
  {
    "id": "seed_067",
    "title": "Sonic Mathematics: Counterpoint as Category Theory",
    "description": "Formalize musical counterpoint rules (Fux's species counterpoint) as a category where objects are consonant intervals and morphisms are permitted voice leadings. Conjecture: The category of first-species counterpoint over a diatonic scale is equivalent to the thin category generated by a specific poset of 12 elements. Test: enumerate all valid first-species counterpoint motions and prove they form exactly this category. Impact: bridges music theory, order theory, and categorical logic.",
    "domains": [
      "Algebra",
      "Speculative",
      "Bridges"
    ],
    "priority_score": 0.74,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.799987+00:00"
  },
  {
    "id": "seed_007",
    "title": "196-Algorithm Non-Termination",
    "description": "Prove that the reverse-and-add algorithm applied to 196 never produces a palindrome. Formalize the concept of Lychrel numbers and establish structural properties of the iteration on digit sequences.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.336768+00:00"
  },
  {
    "id": "seed_060",
    "title": "Musical Counterpoint as Constraint Satisfaction",
    "description": "Formalize the rules of species counterpoint as a constraint satisfaction problem. Prove that optimal voice leading minimizes a well-defined cost function and connect to lattice theory.",
    "domains": [
      "Bridges",
      "Algebra"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.739741+00:00"
  },
  {
    "id": "seed_008",
    "title": "10 is a Solitary Number",
    "description": "Prove that 10 is a solitary number \u2014 no other integer shares its abundancy index \u03c3(n)/n. Formalize the theory of friendly numbers and abundancy, connecting to the distribution of divisor sums.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.7,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.344026+00:00"
  }
];
