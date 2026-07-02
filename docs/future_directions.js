

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "4fd32ea8",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0007",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
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
    "consumed_by_exp_id": "82e2c894",
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
    "consumed_by_exp_id": "813a28d3",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0005",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-02T04:59:08.027554+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "e6a3637b",
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
    "consumed_by_exp_id": "41349be6",
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
    "consumed_by_exp_id": "a0eabca0",
    "description": "There exists a finite set of vectors in l\u00b2 satisfying specific convolution inequalities such that their weighted average achieves the coefficient \u03b3\u2080=0.94601 in the bound F(N) \u2264 N^{1/2} + \u03b3\u2080N^{1/4} + O(1), and no smaller coefficient is achievable via this method.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0013",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01169v1",
    "status": "in_progress",
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
    "consumed_by_exp_id": "4fe41de5",
    "description": "Every essentially 4\u2011edge\u2011connected near\u2011bipartite brick G, with |V(G)| \u2265 6 and G \u2260 K4, contains at least \u2308|V(G)|/2\u2309 b\u2011invariant edges (and each such edge is a forcing edge).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0020",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00608v1",
    "status": "in_progress",
    "timestamp": "2026-07-02T09:30:04.031609+00:00",
    "title": "Conjecture on the Minimum Number of b\u2011Invariant Edges in Near\u2011Bipartite Bricks"
  },
  {
    "consumed_by_exp_id": "ce78e135",
    "description": "Conjecture that for any regular unipotent element \\(g\\) in a simply connected semisimple algebraic group \\(G\\) over an algebraically closed field, the scheme\u2011theoretic stabilizer of its conjugacy class in the center \\(Z(G)\\) is a single reduced point (i.e., trivial).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0021",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00088v1",
    "status": "in_progress",
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
    "description": "The product of primes in the extension field equals its order.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0023",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01126v1",
    "status": "available",
    "timestamp": "2026-07-02T05:35:59.496154+00:00",
    "title": "Ramified Prime Product Equality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a q-hypergeometric series whose coefficients have an asymptotic expansion dominated by oscillatory terms near a root of unity \u03c9, the signs of the coefficients alternate except for a density-zero set of indices n.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0024",
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
    "id": "fd_0025",
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
    "id": "fd_0026",
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
    "id": "fd_0027",
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
    "id": "fd_0028",
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
    "id": "fd_0029",
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
    "id": "fd_0030",
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
    "id": "fd_0031",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00367v1",
    "status": "available",
    "timestamp": "2026-07-02T09:09:17.045826+00:00",
    "title": "The Borel oriented chromatic number of the directed Schreier graph of the Bernoulli shift Z\u00b2 on 2^{Z\u00b2} is 7"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For an r-periodic Riemann function f with perfect matching weight W, and a line bundle F on the five-point space, the pairing H\u2070(M_{W,0} \u2297 F) \u00d7 Ext\u00b9(F, M_{W^\u2227_{K+1},K}) \u2192 H\u00b9(\u03c9_W) \u2245 k is a perfect pairing, establishing a Serre duality isomorphism dim H\u2070(M_{W,0} \u2297 F) = dim Ext\u00b9(F, M_{W^\u2227_{K+1},K}) for all degrees K \u2208 \u2124\u00b2.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0032",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00238v1",
    "status": "available",
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
    "id": "fd_0033",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00212v1",
    "status": "available",
    "timestamp": "2026-07-02T10:08:08.933718+00:00",
    "title": "Four Colors Suffice for Strong Majority Edge-Coloring of Admissible Graphs"
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
    "consumed_by_exp_id": "e39940c9",
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
