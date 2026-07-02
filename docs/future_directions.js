

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0010",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T03:28:51.239302+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0007",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T03:28:51.216448+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0008",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T03:28:51.235448+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0009",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T03:28:51.237233+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Domain NumberTheory has declined by 0.184 over recent cycles (recent avg=0.456 vs prior=0.640). Take a completely fresh approach \u2014 different proof techniques, new definitions, or a different subfield within this domain. Avoid repeating approaches that have been producing diminishing returns.",
    "domains": [
      "NumberTheory"
    ],
    "id": "auto_reset_NumberTheory_e72d5932",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "auto_reset",
    "status": "available",
    "timestamp": "2026-07-02T03:33:38.295255+00:00",
    "title": "[Reset] Fresh approach in NumberTheory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0011",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T03:28:51.240735+00:00",
    "title": "The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For each integer m \u2265 1, the number of greedy m-Tamari intervals of size n equals the number of bipartite planar maps with m+1 components",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0001",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01206v1",
    "status": "available",
    "timestamp": "2026-07-02T02:03:28.210568+00:00",
    "title": "Equivalence of Greedy m-Tamari Intervals and Bipartite Planar Maps with m+1 Components"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any set of N points on a d\u2011dimensional smooth submanifold of \u211d^M and any mapping \u03a6 with Kruskal rank at least d+1, the number of dichotomies C_F(N) realizable by linear separators in the image space satisfies C_F(N) \u2264 \u2211_{i=0}^{d} binomial(N-1, i), which is strictly tighter than the classical Cover bound when d < M.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0002",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01010v1",
    "status": "available",
    "timestamp": "2026-07-02T02:49:17.934723+00:00",
    "title": "Low-Dimensional Dichotomy Bound Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every simple graph G with maximum degree \u0394, any number of agents \u2113 \u2265 2\u0394 is sufficient to guarantee a stochastic\u2011dominance envy\u2011free\u2010up\u2011to\u2011one\u2011item (SD\u2011EF1) allocation of the vertices on the agents, and moreover there exists a deterministic polynomial\u2011time algorithm that produces such an allocation.  This conjecture sharpens the currently known existential and algorithmic bounds of \u2113 \u2265 3\u0394\u22121 (and \u2113 \u2265 (3+\u03b5)\u0394) by reducing the required number of agents to 2\u0394.\n\nIn graph\u2011theoretic terms the conjecture asserts that every \u0394\u2011bounded simple graph admits a proper vertex\u2011colouring with at most 2\u0394 colours in which each colour class can be mapped to an agent in such a way that the resulting allocation satisfies the SD\u2011EF1 condition for any common preference order.  The conjecture is falsifiable: a single counter\u2011example graph with \u0394 and \u2113 < 2\u0394 that admits no SD\u2011EF1 allocation would refute it.\n\nThis conjecture is formalizable in Lean\u00a04 as a statement about the existence of a partition of V(G) into \u2113 independent sets satisfying the SD\u2011EF1 inequalities, coupled with an explicit algorithmic construction.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0003",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01059v1",
    "status": "available",
    "timestamp": "2026-07-02T03:13:12.350397+00:00",
    "title": "Deterministic 2\u0394-Coloring for SD-EF1 under Conflict Constraints"
  },
  {
    "consumed_by_exp_id": "9915ee53",
    "description": "For any filtered system of nilperfect rings {R_i} with colimit R, the canonical map colim \u211dW(R_i) \u2192 \u211dW(R) is an isomorphism of abelian groups. This conjecture addresses the fundamental motivation for sheared Witt vectors: resolving the failure of W(R)/p^n to commute with filtered colimits while preserving essential Dieudonn\u00e9-theoretic properties.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0005",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01178v1",
    "status": "in_progress",
    "timestamp": "2026-07-02T02:03:55.315381+00:00",
    "title": "Sheared Witt Vectors Commutation with Filtered Colimits"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A precise conjecture regarding the irreducibility of the semi-simplification $\bar{V}_{k,a_p}$ under specific bounds on the slope valuation $v(a_p)$, formalizable in Lean 4 through algorithmic verification of shape criteria.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0006",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.00930v1",
    "status": "available",
    "timestamp": "2026-07-02T02:49:31.521966+00:00",
    "title": "Reductions Of Crystalline Representations Of Fractional Slope"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order. with terms 127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,4096,6455,11264,11664,12850,13825,14641,155. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0000",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:80035",
    "status": "available",
    "timestamp": "2026-07-02T01:33:56.530466+00:00",
    "title": "OEIS sequence: \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order."
  },
  {
    "consumed_by_exp_id": "71d4ed72",
    "description": "Investigate the sequence Maximal number of \"good\" manifolds in an n-nice polytope. with terms 6,8,12,24,40,80,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,20971. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0004",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:212351",
    "status": "in_progress",
    "timestamp": "2026-07-02T01:33:56.530529+00:00",
    "title": "OEIS sequence: Maximal number of \"good\" manifolds in an n-nice polytope."
  }
];
