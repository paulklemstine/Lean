

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0009",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T07:27:31.202406+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0006",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T07:27:31.196460+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0007",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T07:27:31.198959+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0008",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T07:27:31.200776+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Building on cycle f6b1d920 (Q=0.760), which proved 6 theorems in Geometry. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume cont",
    "domains": [
      "Geometry"
    ],
    "id": "push_f6b1d920_4035b56a",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "f6b1d920",
    "status": "available",
    "timestamp": "2026-07-15T07:28:11.223313+00:00",
    "title": "Deepening: The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0010",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T07:27:31.203928+00:00",
    "title": "The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "192aef6c",
    "description": "Investigate the ArXiv paper 'Decision problem for Hamilton $2$-cycles in $4$-graphs' and formalize its key results. Abstract: A $4$-uniform $2$-cycle in a $4$-uniform hypergraph of length $t$ is a cyclic ordering of $2t$ vertices $v_1v_2\\cdots v_{2t}v_1$ such that $v_{2i+1}v_{2i+2}v_{2i+3}v_{2i+4}$ are edges for $0\\le i\\le t-1$ while the addition is modulo $2t$. For every $\u03b3>0$ and large $n$, we characterize the $n$-vertex $4$-uniform hypergraphs such that every triple of vertices is contained in at least $(1/3+\u03b3)n$ edges and admits a Hamilton $2$-cycle. Up to the error term $\u03b3n$, the assumption on the minimum codegree is best possible and verifies a conjecture of Garbe and Mycroft. As a consequence, this gives a polynomial-time algorithm that decides whether an $n$-vertex $4$-uniform hypergraph with minimum codegree $(1/3+\u03b3)n$ contains a Hamilton $2$-cycle. This stands as a steep contrast to the graph case where such a hardness gap has size $o(n)$.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0002",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11872v1",
    "status": "in_progress",
    "timestamp": "2026-07-15T07:10:18.924942+00:00",
    "title": "ArXiv paper: Decision problem for Hamilton $2$-cycles in $4$-graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A decomposition of Weyl group multiple Dirichlet series for symmetrizable Kac-Moody root systems' and formalize its key results. Abstract: We study twisted Weyl group multiple Dirichlet series attached to symmetrizable Kac-Moody root systems, using the Chinta-Gunnells method to construct their $p$-parts. Our main result is a decomposition theorem for functions invariant under the twisted Chinta-Gunnells action: under natural analytic hypotheses, such a function has a unique expansion in terms of shifted Chinta-Gunnells averages, indexed by the dominant weights in the highest weight module determined by the twisting parameter. In particular, we show that this decomposition holds for twisted multiple Dirichlet series over rational function fields. For finite root systems, these results were proved by Friedlander. We also show that the relevant Chinta-Gunnells averages admit analytic continuation to the interior of the complexified Tits cone. In the affine $\\widetilde{A}_1$ case, we prove extra functional equations, not arising from the Weyl group, for the untwisted average and for averages twisted by fundamental weights. As",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0004",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11834v1",
    "status": "available",
    "timestamp": "2026-07-15T06:52:29.386046+00:00",
    "title": "ArXiv paper: A decomposition of Weyl group multiple Dirichlet series for symmetrizable Kac-Moody root systems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Adjoint Bloch--Kato Selmer groups of regular algebraic automorphic Galois representations' and formalize its key results. Abstract: We prove the vanishing of the adjoint Bloch--Kato Selmer group of the Galois representations associated to regular algebraic automorphic representations of general linear groups over CM fields. A key novelty of our work is that we impose conditions only on the $p$-adic Galois representations, and not on their associated residual representations modulo $p$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0005",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11769v1",
    "status": "available",
    "timestamp": "2026-07-15T07:10:22.328314+00:00",
    "title": "ArXiv paper: Adjoint Bloch--Kato Selmer groups of regular algebraic automorphic Galois representations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\nThe unrestricted observer-count conjectures need a nondegeneracy condition: `one_observer_representation` proves that every topology is already represented by one observer who sees the real topology. Consequently, non-metrizability alone cannot force three observers, and the proposed lower bound for the Zariski topology on `\u211d\u00b2` is false under the stated definition.\n\nA meaningful refinement could require every observer topology to be strictly finer than the real topology, require observers to belong to a prescribed class, or minimize observers among pairwise distinct proper refinements. Under such a revised definition, useful next questions are:\n\n- characterize spaces that are the common-open-set topology of two strict refinements;\n- determine whether separation or countability axioms are preserved by commonTopology;\n- construct and study observer decompositions of algebraic Zariski topologies;\n- extend the lower/upper-limit construction from `\u211d` to suitable densely ordered topological spaces;\n- define indexed common topologies and prove universal properties for arbitrary observer families.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_0011",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "7704d4fe",
    "status": "available",
    "timestamp": "2026-07-15T07:27:57.349238+00:00",
    "title": "The unrestricted observer-count conjectures need a nondegeneracy condition: `one"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Universal Libraries and Catalog Complexity\n\n## 1. Exact autocorrelation law for passage occurrence\n\nFor every alphabet size at least two and every finite pattern, the exact probability of occurrence in a random fixed-length volume should be expressible from the border lattice of the pattern by a finite cluster expansion. In particular, two patterns of equal length should have equal occurrence probabilities in every ambient length if and only if their overlap autocorrelation polynomials agree.\n\nThe key insight is that departures from the placement union bound are controlled entirely by compatible self-overlaps, rather than by semantic properties of the passage.\n\nWhy now? Exact fixed-window counts and the global union bound isolate overlap as the only unresolved combinatorial contribution.\n\n## 2. Optimal distributed catalogs under block coding\n\nSuppose each catalog volume may be decoded into a fixed number of independently addressable entries, with a prefix-free delimiter scheme. The minimum number of catalog volumes should equal the ceiling of the library cardinality divided by the maximum number of decodable full addresses per volume, up to a delimiter redundancy characterized by Kraft's inequality.\n\nThe key insight is that the apparent conflict between full-size distributed catalogs and information-theoretic estimates disappears once the unit of a catalog entry is specified through a decoding model.\n\nWhy now? The exact one-entry-per-volume threshold exposes precisely which hidden coding assumption must be changed to obtain a smaller catalog.\n\n## 3. Sharp cyclic catalog theorem in every alphabet and order\n\nFor all positive alphabet sizes and all orders, there should exist a cyclic word of length `A^k` whose length-`k` cyclic windows list every word exactly once; moreover, every collision-free cyclic catalog meeting the capacity bound should arise as an Eulerian circuit in the order-`k-1` overlap graph.\n\nThe key insight is that universal catalogs are Euler tours of a directed overlap graph, while the counting bound supplies optimality.\n\nWhy now? The explicit four-symbol, order-two construction establishes the smallest nonbinary case and separates the finite verification from the structural graph theorem needed for arbitrary parameters.\n\n## 4. Semantic proof density under a certified grammar\n\nFix a finite character encoding, a decidable grammar, a resource-bounded proof checker, and a theorem. The density of accepted proof strings among length-`L` volumes should admit computable upper and lower bounds whose exponential rate is determined by the entropy of the checker's accepted language. For deterministic checkers with bounded working memory, that rate should be algebraic and computable from a transfer matrix.\n\nThe key insight is that \u201cprobability of a valid proof\u201d has no encoding-independent value, but becomes a precise language-density question after the checker and resource bound are fixed.\n\nWhy now? Exact passage probabilities demonstrate that syntactic matching is tractable, while also clarifying why semantic validity requires an explicit acceptance model.\n\n## 5. Catalog locality versus diagonal incompleteness\n\nAny family of locally decodable catalogs for all subsets of an `n`-element library, with query complexity bounded independently of `n`, should require total storage exponential in `n` unless randomized error or a restricted catalog class is allowed. A matching construction should exist for catalog classes of bounded circuit complexity.\n\nThe key insight is that Cantor's diagonal obstruction can be refined from a cardinality statement into a storage\u2013locality tradeoff.\n\nWhy now? The strict gap between volumes and possible catalogs supplies the global obstruction; locality introduces a falsifiable complexity parameter that may reveal sharper quantitative boundaries.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0012",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "f6b1d920",
    "status": "available",
    "timestamp": "2026-07-15T07:28:06.903979+00:00",
    "title": "For every alphabet size at least two and every finite pattern, the exact probabi"
  },
  {
    "consumed_by_exp_id": "c5a6c2ed",
    "description": "Investigate the sequence \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order. with terms 127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,4096,6455,11264,11664,12850,13825,14641,155. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0000",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:80035",
    "status": "in_progress",
    "timestamp": "2026-07-15T05:23:22.329148+00:00",
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
    "timestamp": "2026-07-15T05:23:22.329230+00:00",
    "title": "OEIS sequence: Maximal number of \"good\" manifolds in an n-nice polytope."
  }
];
