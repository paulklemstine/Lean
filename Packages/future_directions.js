

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0007",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T04:59:08.029563+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Building on cycle 8b6fc6d0 (Q=0.786), which proved 12 theorems in Pythagorean. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: Research direction from LLM: unknown domain (retry: be more specific)",
    "domains": [
      "Pythagorean"
    ],
    "id": "push_8b6fc6d0_11f0e387",
    "priority_score": 0.8859200000000002,
    "research_mode": "team",
    "source_exp_id": "8b6fc6d0",
    "status": "available",
    "timestamp": "2026-07-02T05:18:37.114832+00:00",
    "title": "Deepening: unnamed_concept"
  },
  {
    "consumed_by_exp_id": "87346215",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0004",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-02T04:59:08.025410+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0005",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T04:59:08.027554+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "7289bdda",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0006",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-02T04:59:08.028575+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Domain NumberTheory has declined by 0.184 over recent cycles (recent avg=0.456 vs prior=0.640). Take a completely fresh approach \u2014 different proof techniques, new definitions, or a different subfield within this domain. Avoid repeating approaches that have been producing diminishing returns.",
    "domains": [
      "NumberTheory"
    ],
    "id": "auto_reset_NumberTheory_e9b441c3",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "auto_reset",
    "status": "available",
    "timestamp": "2026-07-02T05:03:52.769183+00:00",
    "title": "[Reset] Fresh approach in NumberTheory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "What if the topology of a space depended on who is observing it? Define a phantom topology on a set X as a function T: O -> Top(X) that assigns to each observer o a topology T(o) on X. Two observers o1, o2 agree on an open set U if U is open in both T(o1) and T(o2). The phantom number of (X, T) is the minimum number of observers needed to determine the topology: if U is open in every T(o) that contains a point x, then U is a neighborhood of x in the 'real' topology. Conjecture: Every second-countable space (X, tau) admits a phantom representation with at most 2 observers (the real topology is the intersection of two phantom topologies). Moreover, every non-metrizable space requires at least 3 observers. The intuition: the real topology is what ALL observers agree on, and phantom topologies are what individual observers see. Like quantum mechanics, measurement changes the topology. Test: prove that R with the standard topology is the intersection of the lower limit topology and the upper limit topology (2 observers). Prove that the Zariski topology on R^2 requires at least 3 observers. Impact: a new notion of topology where the space itself depends on the observer \u2014 the mathematical formalization of 'reality depends on the observer'.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0064",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T17:04:25.772653+00:00",
    "title": "Phantom Topologies: Spaces That Change When You Look at Them"
  },
  {
    "consumed_by_exp_id": "6054ec76",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0008",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-02T04:59:08.030558+00:00",
    "title": "The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every algebraically closed field F of characteristic 0, every integer k\u22652, and every non\u2011zero polynomial n\u2208F[x], any set A\u2282F[x] satisfying that ab+n is a k\u2011th power for all distinct a,b\u2208A must have size at most 6, except when n is a perfect k\u2011th power and A is contained in the principal ideal generated by a k\u2011th root of n.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0000",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01165v1",
    "status": "available",
    "timestamp": "2026-07-02T04:43:12.676004+00:00",
    "title": "Conjecture on Absolute Boundedness of Polynomial Diophantine Tuples"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all n, k \u2208 \u2115, the number of intervals [x,y] in the greedy 1\u2011Tamari poset on Dyck_n such that the lower endpoint x has exactly k valleys equals the number of bipartite planar maps with n+1 edges and exactly k black vertices.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0002",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01206v1",
    "status": "available",
    "timestamp": "2026-07-02T04:44:51.275254+00:00",
    "title": "Refined enumeration of greedy Tamari intervals by valley count equals refined enumeration of bipartite planar maps by black vertex count"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every m \u2265 1, the generating tree encoding the recursive decomposition of intervals in the greedy m-Tamari poset (on Dyck paths of size n) is isomorphic to the generating tree encoding the recursive decomposition of planar (m+1)-constellations of size n. This conjecture generalizes the m=1 case proved in the paper and would provide a combinatorial proof of the equinumerosity refined by the parameters tracked in the generating tree (e.g., number of valleys in Dyck paths and corresponding statistics in constellations).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0011",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01206v1",
    "status": "available",
    "timestamp": "2026-07-02T05:35:11.178227+00:00",
    "title": "Isomorphism of generating trees for greedy m-Tamari intervals and planar (m+1)-constellations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a large prime r, a real number 0 <= q <= 1, and x such that 1 <= x <= r^0.499, the average value of the 2q-th power of the magnitude of the Dirichlet character sum mod r is bounded below by a constant multiple of x^q. Specifically, there exists a constant C_q > 0 such that (1/(r-1)) * sum_{chi mod r} |sum_{n <= x} chi(n)|^{2q} >= C_q * x^q.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0012",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01184v1",
    "status": "available",
    "timestamp": "2026-07-02T06:02:49.115868+00:00",
    "title": "Lower Bound for Low Moments of Dirichlet Character Sums"
  },
  {
    "consumed_by_exp_id": "",
    "description": "There exists a finite set of vectors in l\u00b2 satisfying specific convolution inequalities such that their weighted average achieves the coefficient \u03b3\u2080=0.94601 in the bound F(N) \u2264 N^{1/2} + \u03b3\u2080N^{1/4} + O(1), and no smaller coefficient is achievable via this method.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0013",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01169v1",
    "status": "available",
    "timestamp": "2026-07-02T06:22:13.488931+00:00",
    "title": "Optimality of vector-valued convolution kernels for Sidon set bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any graphs G and H, the domination number of their Cartesian product satisfies \u03b3(G\u25a1H) \u2265 (19 - \u221a73)/18 * \u03b3(G)\u03b3(H).",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0014",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01109v1",
    "status": "available",
    "timestamp": "2026-07-02T06:39:03.958610+00:00",
    "title": "Improved Constant for Domination in Cartesian Product of Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all finite nonempty sets A \u2286 \u2115 and all n \u2265 7, the symmetric difference |A \u0394 (2A) \u0394 ... \u0394 (nA)| \u2265 n. This conjecture asserts that the effective constant N in Theorem (pilz_large_n) can be taken to be as small as 7, which is the first value beyond what Pilz verified by hand, rather than the astronomically large bound 2\u00b7(3^80 - 321) proven in the paper.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0015",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00934v1",
    "status": "available",
    "timestamp": "2026-07-02T06:57:32.372597+00:00",
    "title": "The Extended 1-2-3 Conjecture Threshold is N = 7"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture posits that conflict constraints necessitate a bounded number of agents for fairness, directly linked to the first two levels of a graph's strong chromatic hierarchy.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0016",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01059v1",
    "status": "available",
    "timestamp": "2026-07-02T07:32:40.113656+00:00",
    "title": "Conflicts and Fair Allocation Bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture posits that the maximum number of disjoint t-star subgraphs in a graph with n vertices is bounded by n^{t-1}. This aligns with the extremal nature of such configurations, though testing its falsifiability requires verifying the bound against extremal examples.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0017",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00770v1",
    "status": "available",
    "timestamp": "2026-07-02T07:56:03.396775+00:00",
    "title": "Extremal Graph Constraint"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture states that reduced words in type B_n have Coxeter lengths exactly double those of type A_n, ensuring non-equivalence in structural complexity.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0018",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00646v1",
    "status": "available",
    "timestamp": "2026-07-02T08:32:08.049625+00:00",
    "title": "Coxeter Length Scaling"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any graph $G$, if $G$ is distance-hereditary, then $G$ is balanced if and and only if $G$ does not contain $\\overline{3K_2}$ as an induced subgraph. This formalizes the paper's result that for the class of distance-hereditary graphs, the property of being balanced is equivalent to being $\\overline{3K_2}$-free.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0019",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00730v1",
    "status": "available",
    "timestamp": "2026-07-02T09:06:43.437769+00:00",
    "title": "Characterization of Balanced Distance-Hereditary Graphs by the Complement of 3-Matching"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every essentially 4\u2011edge\u2011connected near\u2011bipartite brick G, with |V(G)| \u2265 6 and G \u2260 K4, contains at least \u2308|V(G)|/2\u2309 b\u2011invariant edges (and each such edge is a forcing edge).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0020",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00608v1",
    "status": "available",
    "timestamp": "2026-07-02T09:30:04.031609+00:00",
    "title": "Conjecture on the Minimum Number of b\u2011Invariant Edges in Near\u2011Bipartite Bricks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any regular unipotent element \\(g\\) in a simply connected semisimple algebraic group \\(G\\) over an algebraically closed field, the scheme\u2011theoretic stabilizer of its conjugacy class in the center \\(Z(G)\\) is a single reduced point (i.e., trivial).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0021",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00088v1",
    "status": "available",
    "timestamp": "2026-07-02T09:48:50.773388+00:00",
    "title": "Trivial stabilizer for regular unipotent conjugacy classes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer w \u2265 3, the Chromatic Sum problem is NP-complete on graphs of clique-width at most w. This extends the known result for w=3 and suggests a phase transition at clique-width 2 versus 3, where the problem becomes intractable.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0022",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00263v1",
    "status": "available",
    "timestamp": "2026-07-02T10:07:39.641162+00:00",
    "title": "Chromatic Sum NP-Completeness for Clique-Width at Least 3"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that the error term O_\u03b5(Q^{7/4+\u03b5}) in the mean square asymptotic formula for L(s, \u03a0\u2080\u00d7\u03c7) and Dirichlet polynomials can be strengthened to O_\u03b5(Q^{1+\u03b5}) under the same conditions, where \u03a0\u2080 is a cuspidal automorphic representation of PGL\u2083(\u211a) and \u03c7 is a primitive Dirichlet character of conductor \u2264 Q.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0023",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00282v1",
    "status": "available",
    "timestamp": "2026-07-02T10:27:03.642807+00:00",
    "title": "Improved Error Bound for Asymptotic Formula in PGL(3) L-Functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "If an arithmetic function's completed Dirichlet series satisfies a functional equation with a given conductor and parity, then the function is a primitive Dirichlet character modulo that conductor.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0024",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00332v1",
    "status": "available",
    "timestamp": "2026-07-02T10:53:17.529072+00:00",
    "title": "Functional Equation Characterizes Primitive Dirichlet Characters"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the finite Chromonic Lemma extends to infinite, locally finite, strongly connected digraphs. Formally, let G be an infinite directed graph that is strongly connected and locally finite, equipped with a real\u2011valued weight function on its edges and a color\u2011blending operation satisfying the Color Blend Axiom. If there exists a vertex coloring c : V \u2192 Colors such that for every vertex v, c(v) equals the weighted blend of the colors of its out\u2011neighbors (i.e., c(v) = \u03c0_{(u,p)\u2208Out(v)} p\u00b7c(u) ), then c must be constant. This generalizes the paper\u2019s result from finite graphs to infinite ones and highlights the robustness of the underlying combinatorial principle.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0025",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31908v1",
    "status": "available",
    "timestamp": "2026-07-02T11:14:08.155742+00:00",
    "title": "Infinite Color Wheels: No Nontrivial Neighbor\u2011Blend Colorings"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture posits that under strict asymptotic constraints on the edge distribution, the number of high-density graphs must reflect a nontrivial regularity, which can be captured by verifying a function-valued inequality at critical thresholds.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_0026",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31967v1",
    "status": "available",
    "timestamp": "2026-07-02T11:32:25.412615+00:00",
    "title": "Lower bounds on clique densities using generalized inverses"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For the unramified GU(1,n-1) Rapoport\u2013Zink space with arbitrary parahoric level, a Kottwitz\u2013Rapoport (KR) stratum indexed by an admissible element w is entirely contained in the basic locus if and only if the image of w in the finite Weyl group of the special fiber is a Coxeter element (i.e., has maximal length).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0027",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31940v1",
    "status": "available",
    "timestamp": "2026-07-02T11:56:39.543407+00:00",
    "title": "Basic Strata in Unramified GU(1,n-1) Rapoport\u2013Zink Spaces"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any absolute Galois group G_K and any prime p, the orthogonal complement R_p(G_K) of H^1(G_K, F_p) under the cup product with itself depends only on the maximal pro-2 quotient of G_K; equivalently, if two absolute Galois groups have isomorphic maximal pro-2 quotients then their cup radicals are isomorphic as F_p\u2011vector spaces.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0028",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31547v1",
    "status": "available",
    "timestamp": "2026-07-02T12:25:18.795432+00:00",
    "title": "The Cup Radical Depends Only on the Maximal Pro-2 Quotient"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture states that planar graphs lacking C\u2085 subgraphs are inherently 4-choosable, based on their structural constraints.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0029",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31702v1",
    "status": "available",
    "timestamp": "2026-07-02T12:47:07.708715+00:00",
    "title": "Planar Graphs and 4-Choosability"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that the problem of deciding whether a tournament is cycle Mengerian (CM) is NP\u2011complete, i.e. there exists a polynomial\u2011time many\u2011to\u2011one reduction from 3\u2011SAT to the CM decision problem. Equivalently, there is a polynomial\u2011time computable mapping `f` from Boolean formulas to tournaments such that a formula `\u03c6` is satisfiable if and only if the tournament `f \u03c6` is CM.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0030",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31565v1",
    "status": "available",
    "timestamp": "2026-07-02T13:13:32.363565+00:00",
    "title": "NP\u2011Completeness of the Cycle Mengerian Tournament Decision Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the coefficients phi(n) in the expansion phi(q) = sum_{n>=0} phi(n) q^n of Ramanujan's third order mock theta function satisfy the sign law: phi(3m) < 0, phi(3m+1) >= 0, and phi(3m+2) >= 0, with equality occurring at a finite set of exceptional values. This extends the proven sign law for rho(q) to the other third order mock theta functions mentioned in the paper, leveraging the same Watson identities and root-of-unity methodology.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0031",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31606v1",
    "status": "available",
    "timestamp": "2026-07-02T13:33:13.366818+00:00",
    "title": "Sign law for the third order mock theta function phi(q)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed number of layers m \u2265 2, there exists an integer N(m) such that for all n \u2265 N(m) the critical palette size r for the existence of a rainbow stacking of m independent uniformly random r\u2011edge\u2011colourings of the complete graph K_n satisfies: with high probability (i.e., probability \u2192 1 as n \u2192 \u221e) a rainbow stacking exists iff r \u2265 \u2308 m\u00b7(n choose 2) / (2\u00b7log(n!)) + (2m\u22121)/6 \u2309. This strengthens the existing result which holds only for a density\u2011one set of n by eliminating the exceptional set entirely.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0032",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31376v1",
    "status": "available",
    "timestamp": "2026-07-02T14:14:41.903032+00:00",
    "title": "Sharp threshold for rainbow stackings of random edge-colourings of K_n for all sufficiently large n"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture an explicit formula for the Jordan canonical form of the image of a regular unipotent element under any finite\u2011dimensional irreducible polynomial representation of GL\u2083(\u2096). Let \u03bb = (a,b,c) be a dominant weight with a > b > c. Define d\u2081 = a\u2011 b, d\u2082 = b\u2011 c, d\u2083 = a\u2011 c and the rational function\n\nM(t) = (1\u2011 t^{d\u2081+1})(1\u2011 t^{d\u2082+1})(1\u2011 t^{d\u2083+2}) /\n       ((1\u2011 t^{d\u2081})(1\u2011 t^{d\u2082})(1\u2011 t^{d\u2083})).\n\nWrite M(t) = \u03a3_{j\u22650} m_j t^j. Then the Jordan canonical form of \u03c0_\u03bb(u) (the regular unipotent u \u2208 GL\u2083(\u2096) under the representation \u03c0_\u03bb) is the partition whose parts are (j+1) repeated m_j times. In particular the multiplicities m_j satisfy a linear recurrence with characteristic polynomial (1\u2011 t^{d\u2081})(1\u2011 t^{d\u2082})(1\u2011 t^{d\u2083}).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0033",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31398v1",
    "status": "available",
    "timestamp": "2026-07-02T14:45:19.943455+00:00",
    "title": "Jordan type of regular unipotent image for GL\u2080 representations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that operators A_i and A_j in the Operator Theorem's inverse system for SR_G commute (A_i \u2218 A_j = A_j \u2218 A_i) if and only if the corresponding group elements in G = Z_r wr S_n commute.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0034",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.30977v1",
    "status": "available",
    "timestamp": "2026-07-02T15:36:19.278040+00:00",
    "title": "Commutativity of Operator Theorem operators in SR_G"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the theorem stating that for any connected bipartite graph G on n vertices and any real p \u2265 2, the positive p-energy E_p+(G) is at least the positive p-energy of the path graph P_n. This involves defining the adjacency spectrum, the positive p-energy sum, and the specific graph structures.",
    "domains": [
      "Physics"
    ],
    "id": "fd_0035",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.30996v1",
    "status": "available",
    "timestamp": "2026-07-02T15:55:56.869309+00:00",
    "title": "Path-Minimality of Positive p-Energies for Connected Bipartite Graphs"
  },
  {
    "consumed_by_exp_id": "8833345a",
    "description": "Conjecture that for coprime positive integers a<b with a>1 and odd exponent n>1, the equation (a^n+1)(b^n+1)=x^2 has no positive integer solutions.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0036",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31223v1",
    "status": "in_progress",
    "timestamp": "2026-07-02T16:13:17.108600+00:00",
    "title": "No solutions for odd exponents in the coprime case"
  },
  {
    "consumed_by_exp_id": "bfccf79e",
    "description": "For the graph G_N^{(2)} obtained by deleting edges of circular distances \u00b11, \u00b12 from the complete graph K_N, the effective resistance R_{N,\u2113}^{(2)} between vertices at distance \u2113 satisfies a fourth-order linear recurrence with coefficients depending on N. Specifically, for N \u2265 5 and 0 \u2264 \u2113 \u2264 N-5, the sequence R_{N,\u2113}^{(2)} satisfies R_{\u2113+4} + R_{\u2113+3} - (N-1)R_{\u2113+2} + R_{\u2113+1} + R_\u2113 = 0.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0037",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31044v1",
    "status": "in_progress",
    "timestamp": "2026-07-02T16:46:19.799142+00:00",
    "title": "Recurrence for Effective Resistance in G_N^{(2)}"
  },
  {
    "consumed_by_exp_id": "3e52c27d",
    "description": "The product of primes in the extension field equals its order.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0038",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01126v1",
    "status": "in_progress",
    "timestamp": "2026-07-02T05:35:59.496154+00:00",
    "title": "Ramified Prime Product Equality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a q-hypergeometric series whose coefficients have an asymptotic expansion dominated by oscillatory terms near a root of unity \u03c9, the signs of the coefficients alternate except for a density-zero set of indices n.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0039",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01210v1",
    "status": "available",
    "timestamp": "2026-07-02T06:04:27.717812+00:00",
    "title": "Sign Alternation in q-Hypergeometric Series via Oscillatory Asymptotics Near Roots of Unity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture posits that for sufficiently large $s$ and structured seating conditions, a unique non-trivial solution exists in the combinatorial model of the generalized honeymoon problem, formalizable via properties of balanced bipartite decompositions.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0040",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01130v1",
    "status": "available",
    "timestamp": "2026-07-02T06:22:20.382248+00:00",
    "title": "Complementary feasibility in seating configurations for the generalized honeymoon Oberwolfach problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a d-dimensional submanifold E of \u211d^M and a smooth injective map \u03a6:E\u2192\u211d^{M'}, any N-point set F\u2282E in general position satisfies Kruskal rank s \u2264 d+1. This implies the \u03a6-separable dichotomy count C_F(N) is bounded by Cover's counting function C(N,d+M'+1), generalizing high-dimensional bounds to low-dimensional data structures.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0041",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01010v1",
    "status": "available",
    "timestamp": "2026-07-02T06:40:25.125636+00:00",
    "title": "Manifold-Constrained Kruskal Rank Bounds on Dichotomy Counts"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any odd prime p, any even integer k \u2265 2, and any a_p \u2208 \u211a\u0304_p with 0 < v(a_p) < p-1 (i.e., a fractional slope), the semi-simplification \\bar{V}_{k,a_p} of the mod p reduction of the two-dimensional crystalline representation V_{k,a_p} of G_{\u211a_p} of weight k and parameter a_p is irreducible as a mod p representation of G_{\u211a_p}.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0042",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00930v1",
    "status": "available",
    "timestamp": "2026-07-02T06:58:32.634677+00:00",
    "title": "Irreducibility of mod p reductions of two-dimensional crystalline representations with even weight and fractional slope"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for r\u22653, if F is a nonempty r-uniform hypergraph, G is a 2-tightly connected r-uniform hypergraph with no homomorphism from G to F, then the function f_{F,G}(n) satisfies f_{F,G}(n) = \u0398((log n)^{\u03b2_F}) where \u03b2_F = max_{\u2205\u2260P\u2286\u2202\u2082F} e(P)/(v(P)-1). In particular, there exist constants c, C > 0 such that for infinitely many n, c (log n)^{\u03b2_F} \u2264 f_{F,G}(n) \u2264 C (log n)^{\u03b2_F}.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0043",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00732v1",
    "status": "available",
    "timestamp": "2026-07-02T07:33:15.641298+00:00",
    "title": "Tightness of the Generalized Erd\u0151s--Rogers Bound for Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for any integer k\u202f\u2265\u202f3 there is no infinite word over a binary alphabet that contains no k\u207a\u2011parameterized squares (i.e., no squares of length at least 2k whose halves are parameterized\u2011equivalent). Equivalently, every infinite binary word contains a k\u207a\u2011parameterized square for all k\u202f\u2265\u202f3. This conjecture is falsifiable: finding a single infinite binary word that avoids k\u207a\u2011parameterized squares for some k\u202f\u2265\u202f3 would refute it.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0044",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00674v1",
    "status": "available",
    "timestamp": "2026-07-02T07:57:43.823405+00:00",
    "title": "Nonexistence of Infinite 3\u207a\u2013Parameterized\u2011Square\u2011Free Binary Words"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the claim that the sequences LWF(n) and UWF(n), defined by perturbations of the classical Wythoff sequences a(n) = floor(phi*n) and b(n) = floor(phi^2*n) using a Fibonacci correction epsilon(j), partition the set of natural numbers, and that the resulting permutation q*_j defined via these sequences is an almost-involution such that q*_q*_j = j for all j >= 5.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0045",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00814v1",
    "status": "available",
    "timestamp": "2026-07-02T08:32:50.157512+00:00",
    "title": "Partition Property and Almost-Involution of Wythoff-Fibonacci Sequences"
  },
  {
    "consumed_by_exp_id": "",
    "description": "While the continuous oriented chromatic number of the directed Schreier graph of the Bernoulli shift Z\u00b2 on 2^{Z\u00b2} is proven to be 7, the Borel case remains open. This conjecture proposes that the Borel oriented chromatic number is also 7, bridging descriptive combinatorics and topological dynamics.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0046",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00367v1",
    "status": "available",
    "timestamp": "2026-07-02T09:09:17.045826+00:00",
    "title": "The Borel oriented chromatic number of the directed Schreier graph of the Bernoulli shift Z\u00b2 on 2^{Z\u00b2} is 7"
  },
  {
    "consumed_by_exp_id": "debcecca",
    "description": "For an r-periodic Riemann function f with perfect matching weight W, and a line bundle F on the five-point space, the pairing H\u2070(M_{W,0} \u2297 F) \u00d7 Ext\u00b9(F, M_{W^\u2227_{K+1},K}) \u2192 H\u00b9(\u03c9_W) \u2245 k is a perfect pairing, establishing a Serre duality isomorphism dim H\u2070(M_{W,0} \u2297 F) = dim Ext\u00b9(F, M_{W^\u2227_{K+1},K}) for all degrees K \u2208 \u2124\u00b2.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0047",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00238v1",
    "status": "in_progress",
    "timestamp": "2026-07-02T09:49:21.006265+00:00",
    "title": "Perfect Pairings in Periodic Riemann Functions Yield Serre-Type Duality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every admissible graph (i.e., graph with no pendant path of length two) admits a strong majority edge-coloring using at most four colors. This directly addresses the conjecture from Kalinowski, Kamyczura, Pil\u015bniak, and Wo\u017aniak that 4 colors always suffice, improving upon the current upper bound of five colors proven in this paper.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0048",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00212v1",
    "status": "available",
    "timestamp": "2026-07-02T10:08:08.933718+00:00",
    "title": "Four Colors Suffice for Strong Majority Edge-Coloring of Admissible Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A complete classification exists for all bidihedral groups up to isomorphism.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0049",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00352v1",
    "status": "available",
    "timestamp": "2026-07-02T10:27:44.557266+00:00",
    "title": "Bidihedral Group Classification"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any field E and subgroup H \u2264 Aut(E), the extension E/E^H is finite Galois if and only if the lengths of the H-orbits on E are bounded above; equivalently, E/E^H is Galois iff every H-orbit is finite, and finiteness of the extension follows from a uniform bound on those orbit lengths.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0050",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31900v1",
    "status": "available",
    "timestamp": "2026-07-02T10:53:42.375949+00:00",
    "title": "Orbit Boundedness Criterion for Finite Galois Extensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the theorem that for a very general principally polarized abelian variety (X,\u0398) of dimension g, if a subvariety Z of codimension k (1 \u2264 k < g) satisfies [Z] = m\u00b7\u03b8_k where \u03b8_k = [\u0398]^k/k!, then m is divisible by every prime p \u2264 (k+1)/2. This yields a lower bound N_{k,g} \u2265 \u220f_{p \u2264 (k+1)/2} p for the minimal positive multiple of \u03b8_k that is algebraic.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0051",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31894v1",
    "status": "available",
    "timestamp": "2026-07-02T11:14:52.651608+00:00",
    "title": "Divisibility of minimal algebraic multiples of theta_k on very general principally polarized abelian varieties"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the explicit bound $P^+(d)$ from the main theorem is optimal: for every $g\\ge 2$, $d\\in\\{2g+1,2g+2\\}$ and the corresponding $P^+(d)$, there exist a non\u2011zero algebraic integer $\\alpha$ and a prime $p=P^+(d)$ (with $p\\nmid N_{\\mathbb Q(\\alpha)/\\mathbb Q}(\\alpha)$) such that the family $\\cC_\\alpha\\colon y^2 = x^d + \\alpha x + t$ is **not** generically ordinary at $p$. In other words, the threshold $p>P^+(d)$ cannot be lowered.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0052",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31783v1",
    "status": "available",
    "timestamp": "2026-07-02T11:33:13.036923+00:00",
    "title": "Sharpness of the ordinary bound for hyperelliptic families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for any two independent sets I and I' in a P4-tidy graph G, a token sliding reconfiguration of I into I' exists if and only if they share the same cardinality and every induced P4 in G has a vertex in I \u2229 I' or is resolved by a vertex not in I \u222a I'. This condition ensures that reconfiguration can proceed through local sliding moves without creating forbidden induced P4 structures.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0053",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31815v1",
    "status": "available",
    "timestamp": "2026-07-02T11:58:37.009714+00:00",
    "title": "Reconfigurable Independent Sets in P4-Tidy Graphs via Token Sliding"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \u2113 be a fixed prime and let \ud835\udd3d be a non\u2011isotrivial one\u2011parameter family of abelian varieties over \u211a such that the \u2113\u2011torsion Galois module A[\u2113] is constant (i.e. isomorphic to a fixed finite \ud835\udd3d_\u2113\u2011module M for every fibre). For each rational prime p of good reduction for the specialised fibre A_t, the Greenberg\u2013Wiles formula gives a local factor c_p(A_t)\u2208\u2115 that yields the inequality |Sel_\u2113(A_t)| \u2265 c_p(A_t). The conjecture asserts that for 100\u202f% of primes p (ordered by size) the inequality is an equality, i.e. the global \u2113\u2011Selmer size is exactly the product of the local lower bounds predicted by Greenberg\u2013Wiles.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0054",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31649v1",
    "status": "available",
    "timestamp": "2026-07-02T12:25:52.963846+00:00",
    "title": "Sharpness of the Greenberg\u2013Wiles local lower bound for \u2113\u2011Selmer groups in constant\u2011torsion families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that a torsion Hecke eigenclass in the cohomology of the arithmetic manifold attached to GL_n over a CM number field F with coefficients in Z/\u2113^m gives rise to a continuous semisimple Galois representation r : G_F \u2192 GL_n(Z_\u2113) which is de Rham at places v|\u2113, with Hodge\u2013Tate weights determined by the infinitesimal character of the automorphic representation at infinity, and whose associated filtered \u03c6\u2011module via Fontaine's functor corresponds under the p\u2011adic local Langlands correspondence to the automorphic component \u03c0_v.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0055",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31698v1",
    "status": "available",
    "timestamp": "2026-07-02T12:49:31.510793+00:00",
    "title": "Torsion local-global compatibility at p = \u2113 for GL_n over CM fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A 7-dimensional 0/1-polytope with vertices violating central symmetry while satisfying Ziegler's conditions.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0056",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31640v1",
    "status": "available",
    "timestamp": "2026-07-02T13:14:19.130414+00:00",
    "title": "Non-Central Symmetric 7-D Polytope"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a normal geometrically connected variety X over a finite field k, a compactification \\(\\overline{X}\\), an effective Cartier divisor D with support in \\(Z = \\overline{X} \\setminus X\\), and an algebraically closed field F of characteristic p with discrete topology, the set of isomorphism classes of continuous semisimple geometric representations \\(\\rho : \\pi_1(X,D) \\to \\GL_n(F)\\) is finite (up to conjugacy in \\(\\GL_n(F)\\)).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0057",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31341v1",
    "status": "available",
    "timestamp": "2026-07-02T13:33:35.154740+00:00",
    "title": "Finiteness conjecture for semisimple geometric representations of Hiranouchi's ramified fundamental group"
  },
  {
    "consumed_by_exp_id": "",
    "description": "An explicit formula for the number of non-trivial zeros of Artin L-functions below height T under Artin's conjecture.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0058",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31441v1",
    "status": "available",
    "timestamp": "2026-07-02T14:15:54.879802+00:00",
    "title": "Counting Zeros of Artin L-functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer n \u2265 1, the DSOME function satisfies:\nDSOME(n) + 2 * \u2211_{i=1}^{\u230an/2\u230b} q(n-2i) * \u03c3_odd(i) = n * q(n),\nwhere q(n) is the number of partitions of n into distinct parts, and \u03c3_odd(i) is the sum of odd divisors of i.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0059",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31264v1",
    "status": "available",
    "timestamp": "2026-07-02T14:54:55.608249+00:00",
    "title": "An identity for DSOME(n) in terms of distinct partition numbers and odd divisor sums"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for all integers r\u22653, all n\u2265r+1, all probability vectors p1\u2265\u2026\u2265pn>0 with p_{r+1}<(r\u22121)/r, every r\u2011wise intersecting family A\u22862^[n] satisfies \u03bc_p(A)\u2264p1, with equality only for stars centred at a coordinate of maximal probability.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0060",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31075v1",
    "status": "available",
    "timestamp": "2026-07-02T15:36:40.230896+00:00",
    "title": "Tokushige's r-wise intersecting conjecture for non\u2011uniform product measures"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every finite simple graph G, the product of the power domination throttling number of G and that of its complement is at most 6, and this bound cannot be improved.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0061",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.30950v1",
    "status": "available",
    "timestamp": "2026-07-02T15:56:32.304597+00:00",
    "title": "Sharp Nordhaus\u2011Gaddum product bound for power domination throttling"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every minimal edge-colored graph (with respect to edge deletion) that does not admit a total rainbow forest must be a single monochromatic cycle (possibly with isolated vertices).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0062",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.31240v1",
    "status": "available",
    "timestamp": "2026-07-02T16:14:00.036969+00:00",
    "title": "Conjecture on the Structure of Minimal Obstructions to Total Rainbow Forests"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any fixed number field K and any integral ideal q, every class in the narrow ray class group Cl^{(\u221e)}_q can be represented as a product of two prime ideals of norm at most (Nq)^{103/64 + \u03ba} for any \u03ba > 0.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0063",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.30567v1",
    "status": "available",
    "timestamp": "2026-07-02T16:48:39.773698+00:00",
    "title": "Binary representation in narrow ray class groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "An Escher staircase is an infinite strictly ascending chain of ideals I_1 strictly contained in I_2 strictly contained in ... that nevertheless has I_1 as an element of the infinite intersection. This seems impossible \u2014 how can an infinite ascending chain loop back to the beginning? But in the ring of integer-valued polynomials Int(Z), the chain I_n = {f in Int(Z) : f(Z) contained in 2^n Z} is strictly ascending (I_n strictly contained in I_{n+1}) yet the intersection of all I_n is {0}, which contains the zero polynomial that is also in I_1. Conjecture: Every non-Noetherian ring contains an Escher staircase, and the 'height' of the Escher effect (measured by the Krull dimension gap) is a new ring invariant. For Int(Z), the Escher height is infinite (the chain never stabilizes). For Z[x_1, x_2, ...], the Escher height equals the number of variables. For the p-adic integers Z_p, there is NO Escher staircase (Z_p is a DVR, hence Noetherian). Test: prove that Int(Z) has an Escher staircase of infinite height. Prove that k[x_1,...,x_n] has Escher height n. Compute the Escher height for the ring of all algebraic integers. Impact: a new invariant for non-Noetherian rings that measures how far a ring is from being Noetherian \u2014 the algebraic equivalent of Escher's impossible architecture.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0067",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T17:04:25.839310+00:00",
    "title": "Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Congruence Rigidity of Sums of Squares\n\nThis cycle established that the entries of an integer right triangle are forced into\nstrong divisibility patterns \u2014 one leg is a multiple of three, the legs jointly carry a\nfactor of four, one entry is a multiple of five \u2014 and that a four-dimensional right\n\"box\" (a solution of `a\u00b2 + b\u00b2 + c\u00b2 = d\u00b2`) is even more rigid: at most one of its three\nspatial edges can be odd. We also pinned down exactly which whole numbers can serve as a\nleg. These findings point to several bold, testable conjectures.\n\n## 1. The correct modulus for a power of two grows with the power\n**Conjecture.** In any solution of `a\u00b2 + b\u00b2 = c\u00b2`, the two-adic valuation of the leg\nproduct `a\u00b7b` is governed one level deeper than naive reduction suggests: deciding\nwhether `2^k` divides `a\u00b7b` is a question about residues modulo `2^{k+1}`, never modulo\n`2^k`.\n*The key insight is* that a difference of two odd squares is always divisible by eight,\nso each additional factor of two in the product must be certified one binary place\nfurther out than one would guess. *Why now?* Having isolated the exact `mod 8`\nobstruction behind the factor of four, we can test the pattern mechanically for `k = 3,\n4, 5` and either confirm a clean \"shift-by-one\" law or expose its first exception.\n\n## 2. A universal super-divisor for higher-dimensional right figures\n**Conjecture.** For every dimension `r`, solutions of `x\u2081\u00b2 + \u22ef + x_r\u00b2 = y\u00b2` obey a single\nuniversal divisibility law: there is a constant `D(r)`, depending only on `r`, such that\n`D(r)` divides the product `x\u2081\u00b7x\u2082\u00b7\u22ef\u00b7x_r` for *every* solution, and `D(r)` is the largest\nsuch constant.\n*The key insight is* that reduction to a finite residue ring turns \"for all solutions\"\ninto a finite, decidable statement, so the optimal constant `D(r)` is computable and\nshould grow in a structured (conjecturally multiplicative-over-primes) way. *Why now?*\nThe three-dimensional case already yields `4 \u2223 x\u2081x\u2082x\u2083`; comparing it against the planar\nconstant `12` suggests a dimension-indexed sequence worth charting and predicting.\n\n## 3. Parity collapse in higher dimensions\n**Conjecture.** As the number of squared terms increases, the number of edges permitted to\nbe odd stays uniformly bounded: in `x\u2081\u00b2 + \u22ef + x_r\u00b2 = y\u00b2` at most three of the `x_i` can be\nodd, regardless of `r`.\n*The key insight is* that the sum of squares equals the count of odd terms modulo four,\nwhile a perfect square is `0` or `1` modulo four, capping the admissible odd-count no\nmatter how many terms are added. *Why now?* We proved the cap is \"at most one\" in three\ndimensions; extending the modular bookkeeping to arbitrary `r` is a self-contained next\nstep that would reveal whether the cap is truly dimension-independent.\n\n## 4. A sharp threshold characterization of legs in every dimension\n**Conjecture.** Just as the whole numbers that are a leg of a right triangle are exactly\nthose `\u2265 3`, in each higher dimension there is a sharp finite threshold above which every\ninteger appears as an edge of some right figure, and the finitely many exceptions can be\nlisted explicitly.\n*The key insight is* that a single explicit construction, split according to the parity of\nthe target edge, realizes all sufficiently large values, while the small exceptions are\nforced by a factorization that would otherwise require a vanishing edge. *Why now?* The\nplanar threshold `3` and its sharpness (the failures at `1` and `2`) give a template that\nshould transfer verbatim to the box equation and beyond.\n\n## 5. Divisibility as a sieve against near-solutions\n**Conjecture.** The combined congruence obstructions (`12 \u2223 a\u00b7b`, `60 \u2223 a\u00b7b\u00b7c`, and their\nhigher-dimensional analogues) are strong enough that a random integer triple satisfying\nthem has a positive, computable probability of being genuinely Pythagorean \u2014 i.e. the\ncongruence conditions capture a constant fraction of the \"arithmetic mass\" of true\nsolutions.\n*The key insight is* that each universal divisor removes a fixed proportion of impostors,\nso stacking independent prime-power obstructions multiplies into a sieve of predictable\ndensity. *Why now?* With the exact obstructions in hand for the primes `2, 3, 5`, one can\nimmediately measure how much of the solution set they explain and calibrate whether a few\nmore primes suffice to pin down solutions almost completely.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0009",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "8b6fc6d0",
    "status": "available",
    "timestamp": "2026-07-02T05:18:03.424231+00:00",
    "title": "That the entries of an integer right triangle are forced"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A vampire number is a composite number v with an even number of digits that can be factizedd as v = x * y where x and y together have the same digits as v. The smallest is 1260 = 21 * 60. But vampire numbers are just the beginning. Define: (1) Werewolf numbers: v = x * y where x and y share exactly one digit with v. (2) Ghost numbers: v = x * y where v has NO digits in common with x or y. (3) Zombie numbers: v = x * y where x and y are both prime (these violate the definition but exist \u2014 125460 = 204 * 615 = 246 * 510, where both factorizations involve a prime and a composite). Conjecture: The density of vampire numbers in [10^{2n}, 10^{2n+1}] approaches 1/sqrt(n) as n -> infinity. Every even-length interval [10^{2k}, 10^{2k+2}] contains at least one vampire number. Ghost numbers have density 0 \u2014 they become vanishingly rare as the number of digits increases. Test: enumerate all vampire, werewolf, ghost, and zombie numbers up to 10^8. Prove the density conjecture by counting valid digit permutations. Impact: a playful but genuine number theory of arithmetic creatures \u2014 combinatorial digit problems that are easy to state but may be as hard as factoring.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0065",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T17:04:25.818651+00:00",
    "title": "Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Succinct, Binding, Zero-Knowledge Certification of Proofs\n\nThis cycle established two pillars of a certify-without-revealing protocol for\nformal proofs: a hash-tree commitment that binds a prover to an entire proof with\na single short digest yet is opened one step at a time (with every opening itself\nbinding), and an abstract local-checkability principle whose single random query\ncatches any flaw, amplifying to vanishing soundness error under independent\nrepetition \u2014 specialized back to a concrete combinatorial proof system. The\nfollowing conjectures push these findings forward.\n\n## 1. Binding is free; only *uniqueness* costs security\n\n**Conjecture.** For any tree-structured commitment built from a two-argument\ncompression function, the map from committed data to root digest is *binding in\nthe constructive sense* \u2014 any two openings that agree on the digest but disagree\non content yield, effectively, two distinct inputs with the same compressed value\n\u2014 with no algebraic hypothesis on the compression function whatsoever; the\nsecurity assumption (collision resistance) is needed only to turn this into\n*uniqueness* of the committed content.\n\nThe key insight is that ambiguity must surface as a collision at the *first* node\nwhere two committed datasets diverge, so the extractor is a purely structural\nrecursion that never inspects the compression function's internals. **Why now?**\nThe constructive extractor has been isolated and shown to be assumption-free at\nthe base level, so the remaining question \u2014 exactly which security notion each\ntree shape supports \u2014 is now sharply posed rather than folklore.\n\n## 2. Tight round complexity: `\u0398(n\u00b7k)`, not `O(k)`\n\n**Conjecture.** Certifying an `n`-location proof to soundness error `2^{-k}` by\nindependent single-location challenges requires `\u0398(n\u00b7k)` rounds, and this is\noptimal: a cheater corrupting a single location survives each round with\nprobability exactly `(n-1)/n`, so no schedule of independent uniform single\nqueries beats `((n-1)/n)^{rounds}`.\n\nThe key insight is that the per-round soundness gap of a local checker is exactly\n`1/n` in the worst case, so the naive `2^{-k}` bound silently assumes a\nconstant-fraction gap that only holds when the query already inspects a constant\nfraction of the proof. **Why now?** The exact per-round accepting fraction and its\ngeometric product have been pinned down, converting an informal \"repeat `O(k)`\ntimes\" slogan into a precise and falsifiable round-complexity claim.\n\n## 3. Constant soundness gap via correlated queries (a PCP-style boost)\n\n**Conjecture.** There is a re-encoding of any `n`-location certificate into a new\ncertificate of size `poly(n)` whose local checker enjoys a *constant* per-round\nsoundness gap `\u2265 1/2`, so that only `O(k)` rounds \u2014 independent of `n` \u2014 reach\nerror `2^{-k}`; equivalently, the gap can be amplified from `1/n` to a constant by\nquerying a small constant number of *correlated* locations of a suitably encoded\nproof.\n\nThe key insight is that independence of single queries caps the gap at `1/n`, but\na constant-locality checker over a distance-amplifying encoding can reject a far-\nfrom-valid certificate at a constant rate \u2014 the essential mechanism behind\nprobabilistically checkable proofs. **Why now?** Having formalized both the `1/n`\nceiling for independent single queries and the clean product-amplification law, the\nprecise statement of what a constant-gap encoding must achieve \u2014 and the exact\ninequality it must beat \u2014 is now available to target directly.\n\n## 4. Hiding meets binding: a simulator for opened steps\n\n**Conjecture.** Masking each committed leaf with fresh independent randomness\nbefore hashing preserves binding *exactly* (the same constructive collision\nextractor still applies) while making each opened step's revealed value carry no\ninformation about the underlying proof \u2014 there is a simulator that, knowing only\nthe digest and the challenged address, produces an opening indistinguishable from\nthe honest one.\n\nThe key insight is that binding is a property of the compression tree's structure\nwhile hiding is a property of the leaf encoding, so the two can be layered without\ninterference: randomizing leaves changes *what* is committed but not *how* the\ntree binds it. **Why now?** With binding proved assumption-free and independent of\nthe leaf contents, the leaf layer is free to absorb a hiding transform, so the\nlong-standing \"commit-then-open\" intuition can finally be split into two\nseparately provable halves.\n\n## 5. From combinatorial witnesses to arithmetized theorems\n\n**Conjecture.** Every finitary proof in a fixed formal system, once arithmetized\ninto a bounded-degree list of locally checkable steps, admits a\ncommit\u2013challenge\u2013open certification whose transcript length is polynomial in the\n*statement* length and the security parameter, independent of the proof length \u2014\nrealizing the mission's promise that one can certify a theorem is provable without\ntransmitting the proof.\n\nThe key insight is that the two ingredients now in hand \u2014 a succinct binding\ncommitment to arbitrarily long content and a local checker with amplifiable\nsoundness \u2014 compose to a certification whose only proof-length dependence lives\ninside the (hidden, committed) tree, never in the transcript. **Why now?** Both\ncomposable halves have been established and bridged on a concrete proof system, so\nthe general arithmetization is the natural next milestone rather than a leap of\nfaith.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0068",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d991c87b",
    "status": "available",
    "timestamp": "2026-07-02T17:10:27.548136+00:00",
    "title": "Two pillars of a certify-without-revealing protocol for"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Fibonacci sequence is defined by F(n+1) = F(n) + F(n-1) and converges to the golden ratio. Define the ANTI-Fibonacci sequence: A(n+1) is the smallest positive integer that is NOT equal to A(n) + A(n-1). The sequence begins 1, 1, 2, 4, 7, 11, 16, ... (each term avoids being the sum of the two previous terms). Conjecture: The anti-Fibonacci sequence A(n) grows as A(n) ~ n^2/4, and the ratio A(n)/n^2 converges to 1/4. More precisely, A(n) = floor(n^2/4) + O(1). The sequence avoids the golden ratio entirely \u2014 the ratio A(n+1)/A(n) does NOT converge, instead oscillating between 1 and 2. The complement of the anti-Fibonacci sequence (numbers that ARE sums of two previous anti-Fibonacci numbers) has density 0. Test: compute A(n) for n up to 10^6 and verify A(n)/n^2 approaches 1/4. Prove A(n) = floor(n^2/4) + O(1) by induction. Impact: a beautiful counterpoint to the Fibonacci sequence \u2014 instead of converging to a constant, it grows quadratically while systematically avoiding addition.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0066",
    "priority_score": 0.73,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T17:04:25.826883+00:00",
    "title": "The Anti-Fibonacci Sequence: Numbers That Avoid the Golden Ratio at All Costs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order. with terms 127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,4096,6455,11264,11664,12850,13825,14641,155. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0001",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:80035",
    "status": "available",
    "timestamp": "2026-07-02T04:44:52.457252+00:00",
    "title": "OEIS sequence: \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order."
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence Maximal number of \"good\" manifolds in an n-nice polytope. with terms 6,8,12,24,40,80,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,20971. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0003",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:212351",
    "status": "available",
    "timestamp": "2026-07-02T04:44:52.457313+00:00",
    "title": "OEIS sequence: Maximal number of \"good\" manifolds in an n-nice polytope."
  },
  {
    "consumed_by_exp_id": "1de8cc44",
    "description": "Propose a framework where the computational complexity of simulating quantum state correlations in noncommutative geometries determines the hardness of certain mathematical problems. The hypothesis suggests that a polynomial-time algorithm for such problems would imply a breakdown of the cyclicity of Hilbert space dimensionality.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0010",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "in_progress",
    "timestamp": "2026-07-02T05:18:32.052109+00:00",
    "title": "Entanglement-Inspired Algorithmic Complexity in Noncommutative Spaces"
  }
];
