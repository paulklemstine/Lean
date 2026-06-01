

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "id": "fd_0010",
    "title": "Dark Mathematics: Theorems That Exist But Cannot Be Found",
    "description": "There are mathematical objects whose existence we can prove but whose specific properties are unknowable \u2014 theorems that cast shadows without being visible. Define a dark theorem as a statement T such that: (1) PA proves 'there exists x such that T(x)', but (2) for every specific n, PA does NOT prove T(n). The classic example is the Paris-Harrington theorem: the strengthened finite Ramsey theorem is true but not provable in PA. But dark theorems go further: they assert the existence of objects that no specific instance can be verified. Conjecture: The set of dark theorems is dense in the space of all Pi_2 statements \u2014 most true Pi_2 statements are dark. Moreover, there is a hierarchy of darkness: a dark theorem of level k is one where PA proves 'there exist at least k values of x such that T(x)' but cannot identify any specific one. The hierarchy is strict: level k+1 dark theorems are strictly harder to prove than level k. Test: construct explicit dark theorems of levels 1, 2, 3 using the Paris-Harrington principle and the Kirby-Paris hydra theorem. Prove the density conjecture by counting Pi_2 statements. Impact: most true mathematical statements are dark \u2014 they assert existence without the possibility of verification. This is not incompleteness; it is a new form of mathematical unknowability.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.494005+00:00"
  },
  {
    "id": "fd_0097",
    "title": "Strange Loops: Self-Reference and G\u00f6del's Incompleteness",
    "description": "Prove that any sufficiently powerful formal system necessarily contains strange loops: statements that refer to their own unprovability. Formalize G\u00f6del's first incompleteness theorem as a fixed-point in the lattice of provability predicates. Explore whether consciousness arises from tangled hierarchies of self-referential symbols.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.840437+00:00"
  },
  {
    "id": "fd_0003",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 0.99,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.490128+00:00"
  },
  {
    "id": "fd_0105",
    "title": "Mind vs G\u00f6del: Can Minds Outperform Algorithms?",
    "description": "Formalize the Lucas-Penrose argument that human minds can see truths that formal systems cannot prove about themselves. Prove or disprove: there exists a computational system that can consistently recognize its own G\u00f6del sentences. Connect to Chaitin's incompleteness theorem and the Berry paradox.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.99,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.889380+00:00"
  },
  {
    "id": "fd_0000",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.486497+00:00"
  },
  {
    "id": "fd_0099",
    "title": "Tangled Hierarchies: Proof Systems That Reference Their Own Soundness",
    "description": "Construct a formal proof system where the soundness predicate appears inside the system it validates. Prove that such tangled hierarchies are unavoidable in any system that can reason about its own consistency. Formalize using modal fixed-point logics and Kripke frames.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.852132+00:00"
  },
  {
    "id": "fd_0137",
    "title": "The Oracle's Burden: How Much Knowledge Is Too Much?",
    "description": "Prove that adding an oracle for the halting problem to PA yields a theory that proves its own consistency but cannot decide its own soundness. Formalize the hierarchy: PA < PA^H < PA^{H^H} < ... and prove that each jump genuinely increases theorem-proving power. Show that the oracle hierarchy is isomorphic to the Turing jump hierarchy.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.085832+00:00"
  },
  {
    "id": "fd_0101",
    "title": "Transfinite Game Theory: Games That Last Forever",
    "description": "Develop a rigorous theory of infinite games where moves are indexed by transfinite ordinals. Prove that Zermelo's theorem extends: every such game has a determined outcome under AD. Formalize the connection between the determinacy hierarchy and large cardinal axioms.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.97,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.864670+00:00"
  },
  {
    "id": "fd_0132",
    "title": "The Fractal Dimension of Mathematical Truth",
    "description": "Define a natural metric on the space of all mathematical statements and prove that the set of true statements has a fractal dimension. Show that this dimension is strictly between 0 and 1 (truth is sparse but not negligible). Connect to Chaitin's Omega and prove that the fractal dimension is uncomputable but approximable.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.97,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.055007+00:00"
  },
  {
    "id": "fd_0002",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty",
      "Speculative"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.489800+00:00"
  },
  {
    "id": "fd_0086",
    "title": "Formalizing the Probabilistic Method: Erdos Meets Lean",
    "description": "The probabilistic method proves existence by showing that a random structure has the desired property with positive probability. Key results: (1) Erdos's lower bound on Ramsey numbers: R(k,k) > 2^{k/2}. (2) The Lovasz local lemma: if bad events A_1, ..., A_n satisfy P(A_i) <= p and each A_i is independent of all but d others, and e*p*(d+1) <= 1, then P(AND not A_i) > 0. (3) Turan's theorem: the maximum number of edges in a K_{r+1}-free graph on n vertices is (1 - 1/r) * n^2/2. Conjecture: all three results can be formalized in Lean 4 without axiom of choice. The key is to replace non-constructive existence proofs with explicit constructions: (1) The probabilistic proof of R(k,k) > 2^{k/2} uses the expectation argument, which is constructive (compute the expected number of monochromatic K_k and show it's less than 1). (2) The Lovasz local lemma can be made constructive via Moser-Tardos algorithm. (3) Turan's theorem has an explicit construction (the Turan graph). Conjecture: the Moser-Tardos algorithm runs in expected time O(n*d*log(1/p)) and produces a satisfying assignment with probability 1 (constructive LLL). Test: formalize all three results in Lean 4 and verify the proofs compile. Impact: the probabilistic method is constructive. Erdos's existence proofs are algorithms in disguise.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.767640+00:00"
  },
  {
    "id": "fd_0100",
    "title": "Consciousness as Emergent Fixed Point",
    "description": "Formalize the hypothesis that consciousness is a fixed point of a self-modeling function: a system that models itself modeling itself. Prove that such fixed points exist in sufficiently rich Cartesian closed categories and that they exhibit strange-loop topology. Connect to the Yoneda lemma and self-reference in type theory.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.858621+00:00"
  },
  {
    "id": "fd_0107",
    "title": "Surveillance Networks: Information-Theoretic Undetectability",
    "description": "Prove a theorem about the minimum information an observer must collect to reconstruct a dynamic social network with bounded error. Formalize the privacy-utility tradeoff as a rate-distortion problem and prove that perfect surveillance and perfect privacy are mutually exclusive in finite networks.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.901165+00:00"
  },
  {
    "id": "fd_0023",
    "title": "Gravity from Information: Spacetime as a Quantum Error-Correcting Code",
    "description": "Einstein showed that gravity is the curvature of spacetime. But WHY does spacetime curve? Conjecture: Spacetime IS a quantum error-correcting code, and gravity IS the syndrome of that code. The code is a [[n,k,d]] stabilizer code where n = number of Planck areas on a spatial slice, k = number of logical qubits (which equals the Bekenstein-Hawking entropy S = A/4G in natural units), and d = code distance (which equals the minimal geodesic length through the bulk). The key identity: S(A) = Area(gamma_A) / (4G) is EXACTLY the quantum Singleton bound n - k <= 2(d-1) rearranged as k = n - 2d + 2 = A/(4G) when n = A/l_P^2 and d = L/(2l_P). This means the Bekenstein-Hawking entropy formula is a quantum coding theorem, and the holographic principle is a coding constraint. Test: for AdS_3 with boundary CFT_2, the code is a [[n, k, d]] = [[L/l_P, S, L/(2l_P)]] code. Verify that the Singleton bound n - k <= 2(d-1) becomes L/l_P - S <= L/l_P - 1, which simplifies to S >= 1 (trivially true). The NON-TRIVIAL content is that the Ryu-Takayanagi formula S = A/(4G) is the exact quantum information identity. Impact: spacetime is not curved by matter \u2014 spacetime IS a code, and matter IS a syndrome. Gravity is not a force; it's error correction.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.510412+00:00"
  },
  {
    "id": "fd_0063",
    "title": "Topological Quantum Compiling: Braid Groups as Universal Gates",
    "description": "Anyon braiding in topological quantum computing gives unitary matrices from the braid group B_n. The Jones representation rho_k: B_n -> U((k-1)(n-1)+1) at root of unity e^{2*pi*i/k} is conjectured to be universal for quantum computation when k >= 3 and n >= 4. Conjecture: the set of all braids in B_4 under the Jones representation at k=5 generates a dense subgroup of SU(3). More precisely, the image rho_5(B_4) is an infinite subgroup of SU(3) that is not contained in any proper closed subgroup. This means that topological quantum computing with Fibonacci anyons (k=5) is universal: any unitary in SU(3) can be approximated to arbitrary precision by braiding 4 anyons. The key: the Jones representation at k=5 gives 3x3 matrices, and the braid generators sigma_1, sigma_2, sigma_3 generate a dense subgroup of SU(3). Test: compute the Jones representation at k=5 for B_4, verify that sigma_1 * sigma_2 * sigma_3 has infinite order, and check that the group generated by sigma_1, sigma_2, sigma_3 is dense in SU(3) by the Solovay-Kitaev theorem. Impact: braiding anyons is universal for quantum computation. The braid group B_4 at k=5 is a quantum gate set.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.643460+00:00"
  },
  {
    "id": "fd_0098",
    "title": "Isomorphisms of Meaning: When Structures Collide",
    "description": "Prove that isomorphic mathematical structures can carry semantically different meanings that no formal system can distinguish. Formalize the concept of 'isomorphism of isomorphisms' and show that categorical equivalence preserves truth but not meaning. Connect to Hofstadter's Copycat architecture for analogical reasoning.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.846057+00:00"
  },
  {
    "id": "fd_0119",
    "title": "Anti-Mathematics: What If All Axioms Were Negated?",
    "description": "Systematically negate the ZFC axioms and study the resulting anti-mathematics. Prove that not-Extensionality yields a theory of indistinguishable sets, not-Infinity yields hereditarily finite set theory, and not-Choice yields universes where every set is measurable. Determine which anti-axioms are consistent with each other.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.976561+00:00"
  },
  {
    "id": "fd_0116",
    "title": "Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist",
    "description": "Formalize a logic where contradictions do not explode and beliefs can be retracted. Prove that paraconsistent logics can model dream-like reasoning where impossible objects coexist. Show that such logics correspond to topological spaces where open sets are not closed under arbitrary union.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.958310+00:00"
  },
  {
    "id": "fd_0124",
    "title": "Paradoxes as Theorems: Liar, Berry, and Russell Made Consistent",
    "description": "Construct a consistent formal system where the Liar sentence, Berry's paradox, and Russell's paradox are all provable theorems rather than contradictions. Prove this requires rejecting classical logic in favor of a paraconsistent logic with a nontrivial inconsistency-tolerant truth predicate. Show this system proves its own soundness.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.006174+00:00"
  },
  {
    "id": "fd_0130",
    "title": "Zombies and Qualia: Mathematics of Subjective Experience",
    "description": "Formalize the hard problem of consciousness as a theorem about the gap between functional descriptions and subjective experience. Prove that any system satisfying the functional definition of consciousness can have a zombie twin that is functionally identical but experientially void. Show this gap is isomorphic to G\u00f6del's incompleteness gap.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.042804+00:00"
  },
  {
    "id": "fd_0065",
    "title": "Quantum Error Correction from Homological Algebra: CSS Codes as Cohomology",
    "description": "The Calderbank-Shor-Steane (CSS) quantum error-correcting codes are constructed from classical linear codes C_1, C_2 with C_2 perp subset C_1. The CSS code encodes dim(C_1) - dim(C_2) logical qubits. This is exactly the definition of a cohomology group: H^1(C_1, C_2) = C_1 / C_2. Conjecture: every CSS code is equivalent to a cohomology computation on a simplicial complex, and vice versa. Specifically, given a simplicial complex K, the CSS code with C_1 = Z_1(K, F_2) (1-cycles) and C_2 = B_1(K, F_2) (1-boundaries) encodes dim(H_1(K, F_2)) logical qubits with distance d = min(length of shortest non-trivial cycle, length of shortest non-trivial cocycle). This is the homological quantum error-correcting code HQECC(K). The distance d equals the systole of K (the length of the shortest non-contractible cycle). Conjecture: for the hypercube Q_n (n-dimensional cube graph), the HQECC encodes 1 qubit with distance d = 2^{n/2} (achieving the quantum Singleton bound). Test: construct HQECC for Q_4, Q_6, Q_8 and verify the parameters. Impact: quantum error correction is cohomology. Every simplicial complex gives a quantum code, and the code parameters are topological invariants.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.9299999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.657673+00:00"
  },
  {
    "id": "fd_0088",
    "title": "Tropical Cryptography: Min-Plus Encryption with Tropical Matrices",
    "description": "Tropical arithmetic (min-plus algebra) replaces + with min and * with +. A tropical matrix A over Z union {infinity} acts on vectors by tropical matrix multiplication: (A tropimes v)_i = min_j (A_{ij} + v_j). Tropical matrices have eigenvalues in the max-plus sense: lambda is a tropical eigenvalue if A tropimes v = lambda + v for some v. Conjecture: tropical matrix multiplication is a one-way function suitable for cryptography. Specifically, the 'tropical discrete logarithm problem' (TDLP) is: given a tropical matrix A and B = A^{otimes k} (tropical matrix power), find k. The tropical matrix power A^{otimes k} is computed in O(n^3 * log(k)) time (by repeated squaring), but recovering k from (A, A^{otimes k}) is hard because the tropical eigenvalues satisfy lambda(A^{otimes k}) = k * lambda(A) (tropical eigenvalues are additive under power), so k = lambda(A^{otimes k}) / lambda(A). But this only works if lambda(A) != 0 (in the tropical sense, lambda(A) != infinity). Conjecture: the tropical Diffie-Hellman key exchange is secure: Alice sends A^{otimes a}, Bob sends A^{otimes b}, and the shared key is A^{otimes ab}. Breaking this requires solving the TDLP, which is believed to be hard for random tropical matrices of size n >= 10. Test: implement the tropical DH key exchange and measure the key generation time vs matrix size. Attempt to break it with known attacks (tropical eigenvalue computation, shortest path algorithms). Impact: tropical arithmetic provides a new foundation for post-quantum cryptography.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 0.9299999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.782446+00:00"
  },
  {
    "id": "fd_0106",
    "title": "Social Credit Scores as Topological Invariants",
    "description": "Formalize social credit systems as continuous maps from a population to a totally ordered set. Prove that any such map creates fixed-point attractors in the social graph topology. Show that under reasonable assumptions, credit scores converge to a Cantor set attractor where small perturbations cause phase transitions.",
    "domains": [
      "Novelty",
      "Bridges"
    ],
    "priority_score": 0.9299999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.894923+00:00"
  },
  {
    "id": "fd_0122",
    "title": "Retrocausal Mathematics: Where Effects Precede Causes",
    "description": "Formalize retrocausal mathematical structures where implications can flow backward in time. Prove that in a retrocausal Heyting algebra, the law of excluded middle fails but a temporal excluded middle holds. Connect to the CPT theorem in QFT and prove that any retrocausal logic must be intuitionistic.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9299999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.994131+00:00"
  },
  {
    "id": "fd_0026",
    "title": "Self-Improving Proofs: Proofs That Get Simpler Over Time",
    "description": "Proofs are static objects, but what if proofs could improve? Define a proof refinement system where each proof P has a complexity C(P) = length(P) + depth(P) + number of lemmas, and a proof P' is a refinement of P if P' proves the same theorem with C(P') < C(P). Conjecture: For every theorem T provable in ZFC, there exists a sequence of refinements P = P_0, P_1, P_2, ... such that C(P_n) is non-increasing and the limit P_infinity is the simplest proof of T (in the sense of Kolmogorov complexity). Moreover, the refinement process halts: there exists N such that C(P_N) = C(P_{N+1}) = ... = C(P_infinity). The key insight: proof simplification is a well-founded process because the complexity is a natural number that decreases at each step. But the process can be arbitrarily long \u2014 the proof of the four-color theorem might require 10^100 refinements to reach its simplest form. Test: formalize the refinement system in Lean 4. Starting from the statement of the irrationality of sqrt(2), generate refinements by eliminating unnecessary lemmas, shortening case splits, and removing redundant quantifiers. Measure C(P) at each step and verify it decreases. Impact: proofs are not static \u2014 they are living objects that can be improved. The simplest proof of a theorem is the LIMIT of the refinement process, and this limit ALWAYS exists.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9199999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.516572+00:00"
  },
  {
    "id": "fd_0135",
    "title": "Infinite Games Against Death: Immortality Strategies",
    "description": "Formalize a game where one player (Mortal) has finite computation and the other (Eternity) has transfinite computation. Prove that Mortal can always force at least omega rounds before losing, and that with bounded nondeterminism, Mortal can force omega-squared rounds. Connect to Infinite Time Turing Machines.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9199999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.073799+00:00"
  },
  {
    "id": "fd_0013",
    "title": "Holographic Primes: The Prime Number AdS/CFT Correspondence",
    "description": "The AdS/CFT correspondence says that a gravitational theory in the bulk of anti-de Sitter space is equivalent to a conformal field theory on the boundary. What if prime numbers have a holographic dual? Define the prime hologram: for each prime p, define its 'boundary' as the ring Z/pZ and its 'bulk' as the p-adic field Q_p. Conjecture: The Riemann zeta function zeta(s) = prod_p (1 - p^{-s})^{-1} is the holographic partition function: the product over primes (boundary) encodes the same information as the completed zeta function Xi(s) (bulk). The functional equation Xi(s) = Xi(1-s) is the holographic duality: bulk physics at depth s equals boundary physics at depth 1-s. The prime counting function pi(x) ~ x/log(x) is the bulk volume, while the Chebyshev function theta(x) = sum_{p<=x} log(p) is the boundary area. The AdS/CFT dictionary: bulk gravity mode at depth s <-> boundary CFT operator of dimension 1-s. Test: verify that the pair correlation of zeta zeros matches GUE random matrices (bulk = quantum gravity in AdS, boundary = CFT random matrix ensemble). Compute the 'prime partition function' Z(beta) = prod_p (1 - e^{-beta log p})^{-1} and show it equals the bulk partition function. Impact: the Riemann Hypothesis is equivalent to a holographic stability condition \u2014 zeros on the critical line means the bulk geometry is stable against perturbations.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.91,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.496525+00:00"
  },
  {
    "id": "fd_0028",
    "title": "Godel's Casino: Incomplete but Winnable Games",
    "description": "Godel's incompleteness theorem says there are true statements that cannot be proved. But what if we turn incompleteness into a GAME? Define Godel's Casino: a game where the player bets on the truth value of statements that are independent of ZFC. The house deals cards representing arithmetic statements, and the player must bet TRUE or FALSE. The Continuum Hypothesis is the first card \u2014 you can bet either way and you're RIGHT in some model. Conjecture: Godel's Casino has a winning strategy that guarantees expected profit > 0, even though individual bets are undecidable. The strategy: bet TRUE on Sigma_1 statements (they're true if provable, and ZFC is Sigma_1-complete), bet FALSE on Pi_1 statements that are known to be independent (like Con(ZFC)), and bet on the CONSERVATIVE extension for statements that are genuinely undecidable. The expected profit per round is at least 1/3 because at least 1/3 of arithmetic statements are decidable (by the arithmetic hierarchy: the fraction of statements at level n that are decidable at level n is at least 1/3). Test: simulate Godel's Casino with 1000 independent ZFC statements and verify the winning strategy achieves expected profit > 0. Impact: incompleteness is not a barrier \u2014 it's an opportunity. You can WIN at the game of undecidability.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.521091+00:00"
  },
  {
    "id": "fd_0049",
    "title": "Proofs as DAGs: The Directed Acyclic Graph Structure of Mathematics",
    "description": "Every mathematical proof is a directed acyclic graph (DAG): nodes are statements, edges are implications, and the acyclicity comes from the fact that you can't prove A from B and B from A without a circular argument (which is not a valid proof). Conjecture: The DAG of all mathematical proofs has a scale-free structure: the in-degree distribution follows a power law P(k) ~ k^{-gamma} with gamma \u2248 2.5. This means most theorems are proved from a small number of foundational results (the 'hubs'), and there are exponentially many theorems that depend on these hubs. The top 10 hub theorems in mathematics are: (1) Zorn's Lemma, (2) The Intermediate Value Theorem, (3) The Fundamental Theorem of Calculus, (4) The Sylow Theorems, (5) The Baire Category Theorem, (6) Hahn-Banach Theorem, (7) Urysohn's Lemma, (8) The Pigeonhole Principle, (9) Induction, (10) The Law of Excluded Middle. Conjecture: removing any of the top 10 hubs disconnects the proof DAG into at least 2 large components, each containing more than 10% of all theorems. This means mathematics is fragile: removing one foundational theorem makes many other theorems unprovable. Test: construct the proof DAG from Lean 4's Mathlib (all proofs and their dependencies), compute the in-degree distribution, and verify the power law. Impact: mathematics is a scale-free network, and its most important theorems are its most connected nodes \u2014 the hubs that hold the entire structure together.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.585396+00:00"
  },
  {
    "id": "fd_0125",
    "title": "Categorical Physics: The Shape of a Theory of Everything",
    "description": "Prove that any theory of everything in physics must be a (2,infinity)-category with duals. Formalize the cobordism hypothesis as a universal property and show that TQFTs, CFTs, and string theories are all shadows of a single object in this higher category. Determine whether the resulting theory is computable or contains oracle information.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.012168+00:00"
  },
  {
    "id": "fd_0022",
    "title": "The Monster Group's Secret Message: Moonshine Beyond the j-Function",
    "description": "The Monster group M is the largest sporadic simple group, with order 2^46 * 3^20 * 5^9 * 7^6 * 11^2 * 13^3 * 17 * 19 * 23 * 29 * 31 * 41 * 47 * 59 * 71 (approximately 8 * 10^{53}). Monstrous moonshine says that the coefficients of the j-function encode the dimensions of representations of M. But the j-function is just the TIP of the iceberg. Conjecture: The full moonshine correspondence associates to each conjugacy class g in M a McKay-Thompson series T_g(q) = sum a_n(g) q^n that is a modular function of a specific level, and the product over all g in M of T_g(q) equals a modular form of weight |M|/24 that encodes the complete character table of M. The secret message: the Monster group IS a modular form, and every property of M (its order, its character table, its maximal subgroups) can be read off from the q-expansion of this product. Test: compute the first 100 coefficients of T_g(q) for each conjugacy class of M and verify they match the known character values. Prove that the product of all T_g(q) converges to a modular form. Impact: the Monster is not just connected to modular forms \u2014 it IS a modular form. The 194 conjugacy classes of M correspond to 194 modular forms, and their product encodes everything.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.89,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.508792+00:00"
  },
  {
    "id": "fd_0080",
    "title": "Automatic Sequences and the Halting Problem: When Is a Sequence Computable?",
    "description": "An automatic sequence is one generated by a deterministic finite automaton (DFA). The Thue-Morse sequence 01101001... is 2-automatic. The Rudin-Shapiro sequence is 2-automatic. The paperfolding sequence is 2-automatic. Conjecture: a sequence (a_n) is k-automatic iff its generating function G(x) = sum a_n x^n is algebraic over Q(x) of degree at most k. This is known (Christol's theorem): a formal power series over F_k is algebraic iff its coefficient sequence is k-automatic. But Christol's theorem only works over finite fields. For sequences over Z (or Q), the conjecture is: a sequence (a_n) over Z is k-automatic iff it satisfies a linear recurrence with polynomial coefficients of degree at most k-1 in n. Conjecture: the halting problem for k-automatic sequences is decidable: given a DFA that generates (a_n), it is decidable whether there exists n such that a_n = 0 (the 'zero in sequence' problem). This is TRUE for k-automatic sequences (by the pumping lemma: if the DFA accepts any string, it accepts an infinite number, so a_n = 0 infinitely often). But for morphic sequences (generalizations of automatic sequences), the problem is open. Conjecture: the zero-in-sequence problem for morphic sequences is decidable. Test: implement the decidability algorithm for k-automatic sequences and verify on 100 test sequences. Impact: automatic sequences have decidable halting problems. The boundary between decidability and undecidability in sequence theory is the boundary between automatic and morphic.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.89,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.733493+00:00"
  },
  {
    "id": "fd_0133",
    "title": "Quantum Proofs of Classical Theorems",
    "description": "Prove that every classical mathematical theorem has a quantum proof that is shorter by at most a polynomial factor. Formalize quantum proof systems (QMA) and show that some classical theorems (e.g., pigeonhole principle) have exponentially shorter quantum proofs. Determine whether super-polynomial quantum advantage exists.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.89,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.061234+00:00"
  },
  {
    "id": "fd_0018",
    "title": "The L-Function Oracle: What If We Could Compute L-Functions Instantly?",
    "description": "Suppose we had an oracle that computes L(s, chi) for any L-function and any complex s in O(1) time. What theorems would follow? Conjecture: The L-function oracle implies (1) The Riemann Hypothesis (compute zeros directly), (2) The BSD conjecture (compute the order of vanishing at s=1), (3) The Sato-Tate conjecture (compute the distribution of a_p), (4) Langlands functoriality (compare L-functions on both sides of the functoriality lift), and (5) A polynomial-time algorithm for factoring (the L-function of an elliptic curve E over Z/nZ detects factors of n). But the oracle also implies IMPOSSIBILITY results: (6) P != NP (because NP-complete problems would reduce to L-function computations that the oracle solves in O(1), contradicting the time hierarchy theorem if P = NP). Wait \u2014 the oracle solves L-function computations in O(1), so if P = NP, then NP problems can be encoded as L-function computations and solved instantly, but the oracle's existence is an axiom, not a theorem. The correct statement: the L-function oracle collapses the polynomial hierarchy to L-function computations. Test: prove that the Riemann Hypothesis follows from the oracle. Prove that BSD follows. Prove that factoring is in P given the oracle. Impact: understanding what an L-function oracle implies tells us exactly how powerful L-functions are \u2014 and how far we are from proving things about them.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.502441+00:00"
  },
  {
    "id": "fd_0036",
    "title": "Quantum Entanglement as Algebraic Topology: The Linking Number Is Entanglement",
    "description": "Two quantum particles are entangled if measuring one instantly affects the other. But entanglement is also a topological property: if you represent the state of two qubits as a curve in R^3, entanglement IS the linking number. Conjecture: For any pure state of two qubits |psi> in C^2 tensor C^2, the concurrence C(psi) = 2|alpha*delta - beta*gamma| (where psi = alpha|00> + beta|01> + gamma|10> + delta|11>) equals the absolute value of the linking number of two curves derived from the Hopf fibration applied to psi. Specifically, map psi to S^7 via normalization, then project to S^4 via the Hopf map, and the preimages of two points in S^4 are linked circles in S^7 whose linking number equals the concurrence. This means: entanglement is MEASURED by topology, and maximally entangled states correspond to the Hopf link (linking number 1). Test: for 1000 random two-qubit states, compute the concurrence and the linking number of the Hopf preimages, and verify they are equal. Prove the equality for the Bell states. Impact: quantum entanglement is not mysterious \u2014 it is the linking number of the Hopf fibration. Two particles are entangled if and only if their Hopf preimages are linked.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.542003+00:00"
  },
  {
    "id": "fd_0091",
    "title": "Information-Theoretic Limits of Proof Search: How Hard Is It to Find a Lean Proof?",
    "description": "The information content of a Lean 4 proof is the number of bits needed to specify the proof among all possible proofs of the same theorem. For a theorem T with proof P, the information content is I(P) = -log_2(P(proof of T has length |P|)). Conjecture: the expected information content of a proof of a theorem with statement length n is I(n) = Theta(n * log(n)). This means that proofs are typically longer than their statements by a factor of log(n), matching the known results on proof complexity. Moreover, the search problem (finding a proof given the theorem) has time complexity 2^{I(n)} = 2^{Theta(n * log(n))}, which matches the complexity of brute-force search over all proofs of length n * log(n). Conjecture: proof search in Lean 4 is EXPTIME-hard, and the average-case complexity of finding a proof of a random theorem of length n is 2^{Theta(n)} (exponential in n, not n*log(n), because most random theorems are unprovable). Test: measure the length of Lean 4 proofs vs theorem statement length for 1000 theorems in Mathlib and verify I(n) ~ n * log(n). Impact: proof search has fundamental information-theoretic limits. Finding a proof is exponentially harder than verifying one.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.801778+00:00"
  },
  {
    "id": "fd_0110",
    "title": "Self-Modifying Code That Cannot Be Stopped",
    "description": "Prove that any Turing-complete system with self-modification capabilities has no general algorithm for predicting its own termination. Formalize the halting problem for programs that can rewrite their own code mid-execution and show this is strictly harder than the classical halting problem. Connect to the virus paradox and AI alignment.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.919138+00:00"
  },
  {
    "id": "fd_0120",
    "title": "Thermodynamics of Mathematical Proof",
    "description": "Formalize a Landauer-like principle for mathematical reasoning: every bit of information destroyed in a proof step costs at least kT ln 2 of entropy. Prove that there exist theorems whose shortest proof requires exponentially more erasure than creation, and connect to Kolmogorov complexity and the thermodynamic cost of verification.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.982360+00:00"
  },
  {
    "id": "fd_0001",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.489454+00:00"
  },
  {
    "id": "fd_0029",
    "title": "Tropical Dreams: The Field with One Element Meets Tropical Geometry",
    "description": "The field with one element F_1 is a hypothetical object that would explain why the Weil conjectures have the form they do \u2014 as if there were a field with q^0 = 1 element. Tropical geometry replaces addition with min and multiplication with addition. What if these two ideas are the SAME? Conjecture: The tropical semiring (R union {infinity}, min, +) IS the field with one element, in the following precise sense: the category of tropical schemes is equivalent to the category of F_1-schemes. More concretely, a tropical variety over F_1 is a set with a min-plus structure, and its base change to Z (formally, tensor with Z) is a toric variety. The key correspondence: F_1-points of a tropical variety are the vertices of its Newton polytope, and the 'cardinality' of the tropical variety (as an F_1-object) is the number of lattice points in the polytope, which equals the degree of the toric variety after base change. Test: for each toric variety corresponding to a polytope P, compute the number of F_1-points (vertices of P) and verify that the Euler characteristic of the toric variety equals |vertices(P)| = #F_1-points. Prove the tensor product correspondence: tropical scheme X over F_1 has X tensor_Z Z = the corresponding toric variety. Impact: F_1 and tropical geometry are two faces of the same coin. The field with one element is tropical, and tropical geometry is the geometry of F_1.",
    "domains": [
      "Novelty",
      "Tropical"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.523325+00:00"
  },
  {
    "id": "fd_0114",
    "title": "Time Travel Consistency: Novikov's Principle as a Fixed-Point Theorem",
    "description": "Prove that Novikov's self-consistency principle follows from the Banach fixed-point theorem applied to the causal structure of spacetime. Formalize time-travel paradoxes as boundary value problems and prove existence of self-consistent solutions for polynomial causal maps.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.944657+00:00"
  },
  {
    "id": "fd_0121",
    "title": "Hypercomputation: Computing the Uncomputable",
    "description": "Construct a rigorous model of hypercomputation that can solve the halting problem. Prove that any physical system implementing hypercomputation requires infinite energy density or infinite precision. Formalize the distinction between accidentally computable (physical oracles) and essentially computable (Turing machines).",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.988298+00:00"
  },
  {
    "id": "fd_0027",
    "title": "The L-Function Universe: A Cosmic Census of All L-Functions",
    "description": "L-functions are the DNA of mathematics \u2014 each one encodes deep arithmetic information. But how many L-functions ARE there? The L-function universe is vast: (1) The Riemann zeta function (1 L-function), (2) Dirichlet L-functions (countably many), (3) L-functions of elliptic curves (uncountably many, one per j-invariant), (4) L-functions of modular forms (countably many, but indexed by weight and level), (5) L-functions of Galois representations (enormous family). Conjecture: The set of 'natural' L-functions (those satisfying the Selberg class axioms: analytic continuation, functional equation, Euler product, Ramanujan bound) is COUNTABLE. This means the universe of well-behaved L-functions is no bigger than the integers, despite each individual L-function encoding infinitely much information. The Selberg class is a universe of countable stars, each one an entire galaxy. Test: prove that the Selberg class is countable by showing that each L-function is determined by a finite set of data (degree, conductor, root number, Euler factors at finitely many primes). Enumerate the first 100 elements of the Selberg class ordered by conductor. Impact: the mathematical universe of L-functions is countable \u2014 there are only as many well-behaved L-functions as integers. Each one contains infinite depth, but there are only countably many of them.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.518782+00:00"
  },
  {
    "id": "fd_0038",
    "title": "Infinite Chess: Checkmate in Omega Moves",
    "description": "Infinite chess is chess on an infinite board. It is known that there are positions where White can force checkmate but only in omega (the first infinite ordinal) moves. Conjecture: There exists a position on the infinite chess board where White can force checkmate in exactly omega^omega moves, but not in fewer. More precisely, define the game value v(P) of a position P as the smallest ordinal alpha such that White can force checkmate in at most alpha moves. The known results give positions with v(P) = omega. The conjecture is that v(P) can be arbitrarily large below omega^omega. The key construction: create a position where White must first solve a 'puzzle' that takes omega moves, and then another puzzle that takes omega moves for each of omega starting positions, giving omega^2 total moves. Iterating, one can reach omega^n for any n, and omega^omega by a diagonal argument. Test: construct explicit positions with game values omega, omega^2, omega^3, and omega^omega on the infinite board. Verify by computation that no strategy achieves checkmate in fewer moves. Impact: chess on an infinite board has transfinite game values \u2014 the complexity of checkmate goes beyond the finite ordinals into the transfinite.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.548476+00:00"
  },
  {
    "id": "fd_0048",
    "title": "The Aperiodic Monotile: One Shape to Tile Them All",
    "description": "In 2023, Smith et al. discovered 'the hat' \u2014 a single tile shape that tiles the plane but only aperiodically (no periodic tiling exists). This solved the aperiodic monotile problem. But deeper questions remain: How many distinct aperiodic monotiles exist? Conjecture: The set of aperiodic monotiles forms a 1-parameter family (the 'hat spectrum') parameterized by a continuous parameter t in [0,1] where t=0 gives the hat, t=1 gives the turtle (a known variant), and intermediate values give intermediate shapes. The key property: each shape in the hat spectrum tiles the plane aperiodically, and no two shapes in the spectrum admit a common periodic tiling. The boundary of the hat spectrum is the curve in R^2 that separates the region of aperiodic monotiles from the region of periodic tiles. This boundary is a piecewise-smooth curve determined by the constraint that the tile must enforce a hierarchical substitution rule. Test: parameterize the hat spectrum by interpolating between the hat and turtle, compute the substitution rule for each t, and verify that the substitution rule enforces aperiodicity for all t in [0,1]. Impact: aperiodic monotiles are not isolated curiosities \u2014 they form a continuous family, and the hat is just one point on the spectrum.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.581649+00:00"
  },
  {
    "id": "fd_0072",
    "title": "The Borsuk-Ulam Theorem Implies Arrow's Impossibility: Social Choice Is Topology",
    "description": "Arrow's impossibility theorem states that no ranked voting system can be fair (Pareto efficient, non-dictatorial, and independent of irrelevant alternatives). The Borsuk-Ulam theorem states that every continuous function f: S^n -> R^n maps some pair of antipodal points to the same value: f(x) = f(-x). Conjecture: Arrow's theorem is a corollary of Borsuk-Ulam. Specifically, define the 'preference sphere' S^{n-1} as the set of all preference profiles over n alternatives, where antipodal points represent opposite preferences (x prefers A > B > C, -x prefers C > B > A). Define f: S^{n-1} -> R^{n-1} by f(x) = (social_preference(x)_1, ..., social_preference(x)_{n-1}). By Borsuk-Ulam, there exists x such that f(x) = f(-x), meaning the social preference for profile x equals the social preference for profile -x. This contradicts Pareto efficiency (if all voters prefer A to B, the social preference should prefer A to B). Therefore, no continuous voting function satisfies all of Arrow's axioms. Conjecture: this proof generalizes: any social choice function on n alternatives is either discontinuous or dictatorial. Test: formalize the Borsuk-Ulam proof of Arrow's theorem in Lean 4. Impact: social choice theory is topology. Arrow's impossibility is a topological theorem about spheres.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.691072+00:00"
  },
  {
    "id": "fd_0118",
    "title": "Surreal Topology: Open Sets at Infinity",
    "description": "Extend topological space theory to include Conway's surreal numbers as the underlying set. Prove that the order topology on No is not first-countable and that every real open set has a surreal extension. Determine whether No is connected, compact, or paracompact in the interval topology.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.970403+00:00"
  },
  {
    "id": "fd_0123",
    "title": "Computational Complexity of Alien Civilizations",
    "description": "Prove that any technological civilization must discover computational complexity independently of its biological substrate. Formalize a universal complexity hierarchy and prove that P vs NP is a theorem about the structure of computation itself, not about any particular model. Show that even hypercomputational civilizations face analogous barriers.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.000041+00:00"
  },
  {
    "id": "fd_0005",
    "title": "Phantom Topologies: Spaces That Change When You Look at Them",
    "description": "What if the topology of a space depended on who is observing it? Define a phantom topology on a set X as a function T: O -> Top(X) that assigns to each observer o a topology T(o) on X. Two observers o1, o2 agree on an open set U if U is open in both T(o1) and T(o2). The phantom number of (X, T) is the minimum number of observers needed to determine the topology: if U is open in every T(o) that contains a point x, then U is a neighborhood of x in the 'real' topology. Conjecture: Every second-countable space (X, tau) admits a phantom representation with at most 2 observers (the real topology is the intersection of two phantom topologies). Moreover, every non-metrizable space requires at least 3 observers. The intuition: the real topology is what ALL observers agree on, and phantom topologies are what individual observers see. Like quantum mechanics, measurement changes the topology. Test: prove that R with the standard topology is the intersection of the lower limit topology and the upper limit topology (2 observers). Prove that the Zariski topology on R^2 requires at least 3 observers. Impact: a new notion of topology where the space itself depends on the observer \u2014 the mathematical formalization of 'reality depends on the observer'.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.491025+00:00"
  },
  {
    "id": "fd_0033",
    "title": "Fractal Dimension of Proof Search: How Hard Is It to Find a Proof?",
    "description": "When a theorem prover searches for a proof, it explores a tree of possible derivation steps. The branching factor is the number of applicable inference rules at each step. Define the proof-search fractal dimension D(T) of a theorem T as the Hausdorff dimension of the set of all successful proof paths for T. If D(T) < 1, the proof is 'easy' (few paths work, so search is focused). If D(T) > 1, the proof is 'hard' (many paths must be explored). Conjecture: For theorems in ZFC, D(T) = 1 + O(1/length(T)). In other words, most theorems have fractal dimension close to 1 \u2014 proof search is neither trivially easy nor impossibly hard, but balanced at the edge. Theorems with D(T) << 1 are 'obvious' (direct proofs), and theorems with D(T) >> 1 require exponentially long proofs. The fractal dimension correlates with proof length: if D(T) = 1 + epsilon, then the shortest proof of T has length roughly 1/epsilon. Test: for 1000 theorems in Lean 4's Mathlib, estimate D(T) by Monte Carlo sampling of proof search trees, and correlate with actual proof length. Impact: proof difficulty is a fractal \u2014 the dimension of the proof search space determines how hard the theorem is.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.533762+00:00"
  },
  {
    "id": "fd_0041",
    "title": "Langlands for Toddlers: Galois Groups as Shapes, Automorphic Forms as Colors",
    "description": "The Langlands program connects Galois groups (shapes) to automorphic forms (colors). Think of it this way: a Galois group is the group of symmetries of a shape (like the rotational symmetries of a polygon). An automorphic form is a coloring that respects the shape's symmetries (like a coloring of the polygon's vertices that is invariant under rotation). The Langlands correspondence says: for every 'shape' (Galois representation), there is a matching 'color' (automorphic form) and vice versa. Conjecture: This correspondence is a bijection between irreducible representations of Gal(Q_bar/Q) and cuspidal automorphic representations of GL_n over Q. For n=1, this is class field theory (every abelian extension of Q corresponds to a Dirichlet character). For n=2, this is the modularity theorem (every elliptic curve over Q corresponds to a weight-2 cusp form). The toddler version: each shape has exactly one matching color, and each color has exactly one matching shape. Test: verify the correspondence for all degree-2 extensions of Q up to discriminant 1000. Verify that each quadratic field Q(sqrt(d)) corresponds to a Dirichlet character chi_d via the correspondence chi_d(p) = (d/p) (Legendre symbol). Impact: Langlands is just shape-color matching. Shapes and colors are two ways of seeing the same mathematical object.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.557538+00:00"
  },
  {
    "id": "fd_0058",
    "title": "Cryptography from Chaos: Encrypting with the Logistic Map",
    "description": "The logistic map f(x) = r*x*(1-x) for r = 4 exhibits chaotic dynamics: small changes in initial conditions lead to exponentially diverging trajectories (Lyapunov exponent lambda = log(2)). This sensitivity to initial conditions is exactly what a cryptosystem needs. Conjecture: The logistic map at r = 4 is a secure pseudorandom generator. Define the logistic cipher: key = (x_0, n) where x_0 in (0,1) is the seed and n is the number of iterations. The keystream is K = (f^n(x_0), f^{n+1}(x_0), ...) where f^n denotes the n-th iterate. The ciphertext is C = M XOR K where M is the plaintext. The security relies on two properties: (1) Sensitivity: a change of epsilon in x_0 leads to a change of O(1) in f^n(x_0) after n = O(log(1/epsilon)) iterations (exponential sensitivity). (2) Ergodicity: the distribution of f^n(x_0) converges to the invariant measure mu(x) = 1/(pi*sqrt(x*(1-x))) regardless of the initial condition. Conjecture: breaking the logistic cipher (recovering x_0 from K) is as hard as inverting the logistic map, which requires solving a degree-2^n polynomial (since f^n(x) is a polynomial of degree 2^n). This is exponential in n. Test: implement the logistic cipher, measure the period of the keystream (which should be at least 2^n for floating-point precision n), and verify that statistical tests (NIST SP 800-22) pass for n >= 64. Impact: chaos IS cryptography \u2014 the logistic map's sensitivity to initial conditions is the same property that makes encryption secure.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.621662+00:00"
  },
  {
    "id": "fd_0074",
    "title": "The Collatz Conjecture Is Undecidable: What If 3n+1 Can't Be Proved?",
    "description": "The Collatz conjecture (3n+1 problem) states that every positive integer eventually reaches 1 under the map T(n) = n/2 (n even) or 3n+1 (n odd). Despite being verified up to 2^68, a proof remains elusive. Conjecture: the Collatz conjecture is independent of Peano Arithmetic (PA). That is, PA can neither prove nor refute the statement 'for all n, the Collatz sequence starting at n eventually reaches 1'. This would mean the conjecture is TRUE (in the standard model) but UNPROVABLE in PA. The argument: the Collatz map is a Diophantine function that grows faster than any provably total computable function in PA. Specifically, the halting problem for Collatz (does the orbit of n reach 1?) is at least as hard as the consistency of PA, which by Godel's second incompleteness theorem is unprovable in PA. Conjecture: the Collatz conjecture is equivalent to Con(PA) over a weak base theory, meaning that if PA is consistent, then PA does not prove Collatz. Test: formalize the equivalence between Collatz and Con(PA) in Lean 4. Show that a counterexample to Collatz (an n whose orbit diverges or cycles) would imply not-Con(PA). Impact: Collatz might be the simplest true-but-unprovable statement in arithmetic \u2014 a concrete example of Godel's incompleteness.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.700907+00:00"
  },
  {
    "id": "fd_0089",
    "title": "Stone Duality for Machine Learning: Neural Networks as Geometric Realizations",
    "description": "Stone duality states that every Boolean algebra B is isomorphic to the clopen algebra of its Stone space S(B) (the space of ultrafilters on B). This connects syntax (Boolean algebra) with semantics (topology). Conjecture: every neural network f: R^n -> R^m has a 'Stone dual' which is a Boolean algebra B(f) such that the clopen sets of S(B(f)) correspond to the decision regions of f. Specifically, for a binary classifier f: R^n -> {0, 1}, the decision regions {x : f(x) > 0} and {x : f(x) <= 0} are clopen sets in the Stone topology, and the Boolean algebra B(f) is generated by the hyperplanes that form the decision boundary. For a ReLU network with L layers: B(f) is generated by the w_1 + ... + w_L hyperplanes defined by each neuron. The Stone space S(B(f)) has 2^{w_1+...+w_L} points (one for each possible activation pattern), and the decision boundary of f is a subset of S(B(f)). Conjecture: the VC dimension of f equals the number of atoms in B(f), which equals the number of linear regions of f. Test: compute B(f) for small ReLU networks and verify the VC dimension equals the number of linear regions. Impact: neural networks have Stone duals. The Boolean algebra of activation patterns is the syntax, and the decision boundary is the semantics.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.789392+00:00"
  },
  {
    "id": "fd_0109",
    "title": "Digital Immortality: Can a Mind Be Encoded?",
    "description": "Prove information-theoretic bounds on mind uploading: the minimum description length of a human mind exceeds any computable compression of its neural connectome. Formalize the Bekenstein bound applied to neural computation and show that the Kolmogorov complexity of consciousness is at least quadratic in synapse count.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.85,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "7cd2b5be",
    "timestamp": "2026-06-01T12:30:30.913341+00:00"
  },
  {
    "id": "fd_0126",
    "title": "Counterfactual Number Theory: What If Primes Were Random?",
    "description": "Construct an alternate number theory where primes are replaced by a random subset of N with density n/log n. Prove which theorems survive (Dirichlet, PNT) and which collapse (unique factorization). Determine whether RH holds almost surely in this counterfactual universe.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.018128+00:00"
  },
  {
    "id": "fd_0138",
    "title": "Causal Loops in Category Theory: When Composition Loops Back",
    "description": "Construct a category where composition is not associative but satisfies a controlled failure: (f circ g) circ h and f circ (g circ h) are naturally isomorphic but not equal. Prove that such almost-categories are exactly the bicategories and that every coherent loop-tolerant algebraic structure forms a higher category.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.092242+00:00"
  },
  {
    "id": "fd_0015",
    "title": "Impossibility Results for Fun: Things That Cannot Be Done (But We Try Anyway)",
    "description": "Mathematics is full of impossibility theorems \u2014 things that CANNOT be done. But impossibility theorems are themselves beautiful mathematical objects. Catalog and interconnect the great impossibilities: (1) Squaring the circle (pi is transcendental, Lindemann 1882). (2) Trisecting the angle (cos 20 degrees has degree 3 over Q, Wantzel 1837). (3) Doubling the cube (cube root of 2 has degree 3, Wantzel 1837). (4) Solving the quintic by radicals (A_5 is not solvable, Abel-Ruffini 1824). (5) The Borsuk-Ulam impossibility (every continuous map S^n -> R^n has a point where f(x) = f(-x)). (6) Arrow's impossibility (no voting system is simultaneously fair, complete, and non-dictatorial). (7) Heisenberg's uncertainty (Delta x * Delta p >= hbar/2). Conjecture: These impossibility theorems are connected by a deep structural principle \u2014 each one arises because a certain group action is not free. Squaring the circle fails because Gal(Q(pi)/Q) acts freely. Solving the quintic fails because A_5 acts freely on the roots. Arrow's theorem fails because the symmetric group acts freely on preferences. Heisenberg fails because the Heisenberg group acts freely on phase space. The unified principle: a task is impossible iff the relevant group action is free. Test: verify that each impossibility theorem corresponds to a free group action. Prove the converse: if a group G acts freely on a set X, then there exists a G-equivariant task that is impossible on X. Impact: all impossibility is the same impossibility \u2014 every CAN'T is a reflection of a free group action.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.498448+00:00"
  },
  {
    "id": "fd_0047",
    "title": "The Zeta Function of a Graph: Number Theory on Networks",
    "description": "The Ihara zeta function of a finite graph G is zeta_G(u) = prod_{[C]} (1 - u^{|C|})^{-1} where the product is over prime cycles (closed walks that are not powers of shorter walks). For a (q+1)-regular graph, zeta_G(u) = (1-u^2)^{-(n-1)(q-1)/2} * det(I - A*u + (q-1)*u^2*I)^{-1} where A is the adjacency matrix. This is the graph analog of the Riemann zeta function. Conjecture: The Riemann hypothesis holds for zeta_G if and only if G is a Ramanujan graph (all non-trivial eigenvalues of the adjacency matrix satisfy |lambda| <= 2*sqrt(q)). This is a theorem of Ihara, but the deeper conjecture is: the zeta function of a Ramanujan graph encodes the same spectral information as the Riemann zeta function restricted to the critical strip. Specifically, if zeta_G satisfies RH, then the 'prime cycles' of G are distributed like the primes in Z, and the 'explicit formula' for zeta_G (analogous to the explicit formula for the Riemann zeta) relates the cycle counts to the eigenvalues of A. Test: compute zeta_G for 10 Ramanujan graphs (paley graphs, lubotzky-phillips-sarnak graphs) and verify the Riemann hypothesis. Compare the 'prime cycle counting function' with the prime counting function pi(x). Impact: graphs have zeta functions, Ramanujan graphs satisfy RH, and the prime cycles in a graph are distributed like the primes in Z.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.578133+00:00"
  },
  {
    "id": "fd_0056",
    "title": "The Fourier Transform of the Riemann Zeta: Hearing the Primes",
    "description": "The Riemann zeta function zeta(s) has zeros at the non-trivial points s = 1/2 + i*gamma_n where gamma_n are the imaginary parts of the zeros. The Fourier transform of the zero counting function N(t) = #{gamma_n <= t} is related to the distribution of primes by the explicit formula. But what if we take the Fourier transform of zeta itself? Define Z(t) = zeta(1/2 + it) as a function of the real variable t. The Fourier transform Z_hat(w) = integral_{-inf}^{inf} Z(t) * e^{-2*pi*i*w*t} dt. Conjecture: Z_hat(w) has sharp peaks at w = log(p)/2*pi for each prime p. This is because the explicit formula expresses zeta(1/2+it) as a sum over primes: zeta(1/2+it) ~ sum_{p} p^{-1/2-it} = sum_{p} e^{-it*log(p)} / sqrt(p), which is a sum of complex exponentials with frequencies log(p). The Fourier transform of a sum of exponentials is a sum of delta functions at the frequencies log(p)/2*pi. So Z_hat(w) = sum_{p} delta(w - log(p)/2*pi) / sqrt(p) + (error from zeros and smooth terms). The peaks at w = log(p)/2*pi give a 'spectrogram' of the primes. Test: compute Z_hat(w) numerically for the first 10^6 zeros and verify the peaks at log(2)/2*pi, log(3)/2*pi, log(5)/2*pi, etc. Impact: you can HEAR the primes by playing the Fourier transform of the Riemann zeta function \u2014 each prime is a distinct note.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.612729+00:00"
  },
  {
    "id": "fd_0073",
    "title": "Algebraic Geometry of Neural Networks: Varieties of Decision Boundaries",
    "description": "A neural network with ReLU activation defines a piecewise linear function f: R^n -> R^m. The decision boundary of a binary classifier f: R^n -> R is the set {x : f(x) = 0}, which is a piecewise linear hypersurface. The algebraic variety of the decision boundary is the zero set of the polynomial that best approximates f. Conjecture: for a ReLU network with L layers of widths (n, w_1, ..., w_L, 1), the decision boundary is a piecewise linear hypersurface with at most 2^L * prod w_i regions, and the degree of the best polynomial approximation is at most 2^L. More precisely, the decision boundary V(f) = {x : f(x) = 0} is a tropical hypersurface (a piecewise linear object that is the 'skeleton' of an algebraic variety). The tropical variety of the decision boundary has degree at most 2^L and at most prod_{i=1}^{L} (w_i choose 2) singularities. Conjecture: the VC dimension of a ReLU network with L layers and total width W is at most L * W * log(W), matching the known bound up to log factors. Test: train ReLU networks on synthetic data, extract decision boundaries, and verify they are tropical hypersurfaces with the predicted degree and singularity count. Impact: neural network decision boundaries are tropical varieties. The complexity of the network (L, W) determines the algebraic complexity of the boundary.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.695662+00:00"
  },
  {
    "id": "fd_0104",
    "title": "Cellular Automata at the Ordinals: Transfinite Computation",
    "description": "Prove that cellular automata can perform transfinite computations when run on ordinals instead of N. Formalize a Rule 110 analog on omega-squared and prove it achieves super-Turing computation. Connect to Infinite Time Turing Machines and ordinal computation.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.883358+00:00"
  },
  {
    "id": "fd_0111",
    "title": "Non-Desarguesian Worlds: Geometry Without Desargues",
    "description": "Construct and classify finite projective planes where Desargues' theorem fails. Prove that such planes exist at every prime power order and that their collineation groups are strictly smaller than PGL. Formalize the connection to non-associative division algebras and Hall triple systems.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.925627+00:00"
  },
  {
    "id": "fd_0016",
    "title": "Surreal Topology: What Topology Does the Field of Surreal Numbers Have?",
    "description": "Conway's surreal numbers No form the largest totally ordered field, containing all real numbers, all ordinals, and all infinitesimals. But No is a proper class, not a set. What topology does it have? Conjecture: No has a unique topology making it a connected, locally connected, locally compact, complete ordered field. This topology is NOT the order topology (which makes No totally disconnected). Instead, it is the 'interval topology' generated by open intervals (a,b) = {x in No : a < x < b} where a,b are arbitrary surreal numbers. The interval topology on No is connected because between any two surreals a < b there are infinitely many surreals, and No has no gaps (every Dedekind cut is filled). Moreover, No is contractible in this topology \u2014 every surreal number can be continuously deformed to 0 via the homotopy H(x,t) = x * {t | 0} where {t | 0} is the surreal number between t and 0. Test: prove that No with the interval topology is connected. Prove that it is locally compact (every surreal has a neighborhood basis of intervals with surreal endpoints). Prove that No is contractible. Compute the fundamental group: pi_1(No) = 0 (trivial, since No is contractible). Impact: the largest ordered field has a natural topology that makes it contractible \u2014 every surreal number is connected to every other by a continuous path.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.499504+00:00"
  },
  {
    "id": "fd_0021",
    "title": "Chaos as a Computable Shadow: The Shadowing Lemma for Real Programs",
    "description": "The shadowing lemma says that near an approximate orbit of a chaotic system, there exists a true orbit. In other words, every 'almost correct' trajectory of a chaotic map has a 'truly correct' trajectory nearby. This means that numerical errors in chaotic simulations are not bugs \u2014 they are SHADOWS of real trajectories. Conjecture: Every program that computes a chaotic map f: R^n -> R^n has the property that its floating-point output is shadowed by a true orbit of f. More precisely, for every epsilon > 0, there exists delta > 0 such that if x_0, x_1, ..., x_N is a delta-pseudo-orbit (|x_{n+1} - f(x_n)| < delta for all n), then there exists a true orbit y_0, y_1, ..., y_N with |x_n - y_n| < epsilon for all n. The shadowing time N(epsilon, delta) grows at most polynomially in 1/delta for hyperbolic maps. Test: implement the logistic map f(x) = 4x(1-x) in floating-point and compute 10^6 iterations. For each floating-point orbit, use binary search to find the shadowing true orbit. Verify that the shadowing distance is at most 10^{-10} for floating-point precision 10^{-16}. Impact: numerical chaos is not error \u2014 it is a computable shadow of mathematical truth. Your computer's rounding errors are tracing out REAL orbits of the chaotic system.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.507128+00:00"
  },
  {
    "id": "fd_0050",
    "title": "Fractal Number Theory: Hausdorff Dimension of Prime Distributions",
    "description": "The primes have density 0 in the integers, but what is the Hausdorff dimension of the set of primes viewed as a subset of R? Define the 'prime fractal' P as the set of primes with the metric d(p,q) = |1/log(p) - 1/log(q)|. This metric stretches out the primes so that the twin primes are close together and the large primes are spread out. Conjecture: The Hausdorff dimension dim_H(P, d) = 1. The primes with this metric are essentially a 1-dimensional set \u2014 they fill out a line when viewed through the logarithmic lens. This is because the prime number theorem pi(x) ~ x/log(x) means that in the d-metric, the 'length' of the primes up to x is sum_{p <= x} d(p, p+1) ~ sum_{p <= x} 1/(p*log(p)) ~ log(log(x)), which diverges. So the primes are 'long enough' to be 1-dimensional. But the Hausdorff dimension might be > 1 if the primes have fractal structure at small scales. In fact, dim_H(P, d) > 1 would mean the primes are more than a line \u2014 they have 'wrinkles' that fill more space. The twin prime conjecture predicts that there are infinitely many pairs of primes at d-distance ~ 1/(p*log(p)), creating a fractal dust that increases the dimension. Conjecture: dim_H(P, d) = 1 + epsilon where epsilon depends on the density of twin primes. If the twin prime conjecture is true, epsilon > 0. Test: estimate dim_H(P, d) by box-counting for primes up to 10^12 and verify it is close to 1 (or slightly above). Impact: the primes are a fractal with dimension 1 + epsilon, where epsilon measures the abundance of twin primes. If twin primes are infinite, the primes are more than a line \u2014 they are a fractal curve.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.589354+00:00"
  },
  {
    "id": "fd_0076",
    "title": "Quantum Groups from Number Theory: The Riemann Hypothesis as a Representation Problem",
    "description": "The Riemann zeta function zeta(s) has non-trivial zeros at s = 1/2 + i*gamma_n on the critical line (assuming RH). These zeros encode deep arithmetic information. Conjecture: the zeros gamma_n are the spectrum of a self-adjoint operator on a Hilbert space, and this operator is the Casimir element of a quantum group G_q. Specifically, define the 'zeta quantum group' G_q as the q-deformation of SU(2) where q = e^{2*pi*i*gamma_1} (using the first zero gamma_1 ~ 14.13). The Casimir element C_q of G_q has eigenvalues that are quadratic functions of the representation labels, and the spectrum of C_q is {n(n+1) : n in N}. Conjecture: the Riemann zeros gamma_n are related to the spectrum of C_q by gamma_n = f(spectrum(C_q)) for some function f. If f is linear, this would mean the zeros are evenly spaced, which is false (the zeros have Poisson-like spacings). If f is logarithmic, gamma_n ~ pi*n/log(n) which matches the average spacing. Conjecture: the spectral statistics of C_q match the GUE random matrix statistics of the Riemann zeros (Montgomery's pair correlation conjecture). Test: compute the spectrum of C_q for G_q with q = e^{2*pi*i*gamma_1} and compare the spectral statistics with the Riemann zeros. Impact: the Riemann hypothesis is a representation-theoretic statement about quantum groups.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.711975+00:00"
  },
  {
    "id": "fd_0112",
    "title": "Negative-Dimensional Topology: What Lives in Dimension -1?",
    "description": "Develop a rigorous theory of negative-dimensional spaces using pro-spectra and formal dimension theory. Prove that Euler characteristic extends to negative dimensions and that chi(X) for dim X = -n satisfies chi = (-1)^n \u00b7 |pi_0(X)|. Formalize the stabilization map from negative to positive dimensions.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.931857+00:00"
  },
  {
    "id": "fd_0131",
    "title": "Fermat Near-Misses in the Twilight Zone",
    "description": "Study near-misses to Fermat's Last Theorem: triples (a,b,c) where |a^n + b^n - c^n| is small. Prove that such near-misses exist for every n and characterize their distribution. Show that the density of near-misses decreases super-exponentially and connect to the ABC conjecture's effective version.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.048933+00:00"
  },
  {
    "id": "fd_0136",
    "title": "The Mega-Sphere: All Dimensions at Once",
    "description": "Construct a single algebraic object whose projections give S^0, S^1, S^2, ... simultaneously. Prove it exists as an inverse limit in the category of spheres. Show that its homology groups encode the Bernoulli numbers and that its cohomology ring is the polynomial ring on Stiefel-Whitney classes.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.079824+00:00"
  },
  {
    "id": "fd_0004",
    "title": "The Library of Babel: Combinatorics of the Universal Library",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.490561+00:00"
  },
  {
    "id": "fd_0037",
    "title": "The Periodic Table Is a Lie: Elements as Eigenvalues of Spacetime",
    "description": "Mendeleev's periodic table arranges elements by atomic number Z, but Z is just the charge of the nucleus. Conjecture: the periodic table is the spectrum of an operator on a Hilbert space of dimension equal to the number of stable isotopes. Define the 'nuclear Hamiltonian' H on L^2(R^3) by H = -hbar^2/(2m) * nabla^2 + V(r) where V(r) encodes the strong and electromagnetic forces. The eigenvalues E_n of H give the binding energies of nuclei, and Z_n = round(E_n / E_0) gives the atomic numbers. The 'periodicity' of the table arises because the eigenvalues of H have shell structure (like the hydrogen atom): the n-th shell has degeneracy 2n^2 (from the angular momentum quantum number), giving shell sizes 2, 8, 18, 32, 50, 72 \u2014 the noble gas atomic numbers 2, 10, 28, 60, 110 are the cumulative sums. The 'stability islands' (magic numbers 2, 8, 20, 28, 50, 82, 126) correspond to extra degeneracies in the nuclear potential. Test: solve the Schrodinger equation for a Woods-Saxon potential (model nuclear potential) and show that the eigenvalue degeneracies match the periodic table structure. Compute the 'predicted' periodic table from the eigenvalues and compare with reality. Impact: chemistry IS applied spectral theory. The periodic table is the spectrum of a Hamiltonian, and every chemical property is an eigenvalue.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.545457+00:00"
  },
  {
    "id": "fd_0057",
    "title": "Persistent Homology of Prime Numbers: The Topology of Arithmetic",
    "description": "The sequence of primes 2, 3, 5, 7, 11, 13, ... defines a point cloud in R where the n-th prime p_n is at position p_n on the real line. The gaps between primes create a topological structure. Define the persistent homology of the prime point cloud as the Rips filtration R_epsilon = {p_n : |p_m - p_n| <= epsilon}. As epsilon increases, more primes are connected, and the topology changes. Conjecture: The persistent H_0 (connected components) of the prime point cloud has the same barcode as a Poisson point process with intensity 1/log(x). Specifically, the bar lengths in H_0 follow an exponential distribution with mean equal to the average prime gap (which is approximately log(x) by the prime number theorem). The persistent H_1 (1-dimensional holes) of the prime point cloud appears at scale epsilon ~ log(x)^2, corresponding to prime pairs (p, p+2k) where 2k is a specific even gap. The longest H_1 bar corresponds to the twin prime conjecture: it persists from epsilon = 2 (the twin prime scale) to epsilon = infinity. Test: compute persistent homology of the primes up to 10^6 using Rips filtration and compare with the Poisson point process prediction. Verify that H_0 bar lengths are exponentially distributed with mean log(x). Impact: primes have topology \u2014 their gaps create persistent homology that encodes the twin prime conjecture and other arithmetic properties.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.617168+00:00"
  },
  {
    "id": "fd_0075",
    "title": "Knots and Lattices: The Alexander Polynomial as a Lattice Path Count",
    "description": "The Alexander polynomial Delta_K(t) of a knot K is a Laurent polynomial that encodes topological information about the knot. Conjecture: for any knot K with n crossings, the Alexander polynomial Delta_K(t) can be expressed as the generating function of lattice paths in Z^2 that avoid a region determined by the knot diagram. Specifically, define the 'knot lattice' L_K as the set of lattice paths from (0,0) to (n,n) that avoid the 'forbidden region' R_K determined by the crossing structure of K. Then Delta_K(t) = sum_{p in L_K} t^{area(p)} where area(p) is the area under the path p. This conjecture follows from the state sum formula for the Alexander polynomial: Delta_K(t) = sum_{states s} (-1)^{w(s)} t^{a(s)} where w(s) is the writhe and a(s) is the area of the state. The area a(s) is exactly the area under a lattice path determined by the state. Conjecture: every Alexander polynomial arises as a lattice path generating function, and vice versa. This means the Alexander polynomial is not just a knot invariant \u2014 it is a combinatorial object that counts lattice paths. Test: compute the Alexander polynomials for the first 50 knots and verify that each can be expressed as a lattice path generating function. Impact: knot invariants are combinatorial. The Alexander polynomial counts lattice paths, connecting topology to combinatorics.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.706858+00:00"
  },
  {
    "id": "fd_0095",
    "title": "Quantum Random Walks on Cayley Graphs: Spectral Gaps and Mixing Times",
    "description": "A quantum random walk on a group G is defined by a unitary operator U = sum_{g in S} |g><0| (where S is a generating set) acting on the Hilbert space l^2(G). The walk is periodic if U^k = I for some k, and mixing if the probability distribution P_n(g) = |<g|U^n|0>|^2 converges to the uniform distribution on G. Conjecture: for the Cayley graph Cay(G, S) where G is a finite group and S is a symmetric generating set, the quantum walk mixes in O(sqrt(|G|) * log(|G|)) steps, which is quadratically faster than the classical random walk (which takes O(|G|^2) steps for the spectral gap to kick in). The mixing time is determined by the spectral gap of U: tau_mix ~ 1/gap where gap = 1 - |lambda_2| and lambda_2 is the second-largest eigenvalue of U. Conjecture: for Cay(G, S) with S = the set of transpositions in S_n, the spectral gap of U is Omega(1/n), giving a mixing time of O(n * log(n)). This matches the known classical mixing time of O(n * log(n)) for the random transposition walk on S_n. The quantum advantage comes from the quadratically faster convergence of the probability distribution, not from the spectral gap. Test: simulate quantum random walks on Cayley graphs of S_n, S_n, A_5, and Z_n, measure the mixing time, and verify tau_mix = O(sqrt(|G|) * log(|G|)). Impact: quantum random walks mix quadratically faster than classical random walks on Cayley graphs. The quadratic speedup is universal.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.827686+00:00"
  },
  {
    "id": "fd_0102",
    "title": "Transreal Arithmetic: Computing Beyond Plus-Minus Infinity",
    "description": "Formalize transreal arithmetic (Anderson's system: R \u222a {Phi, +inf, -inf} with Phi = 0/0). Prove the ring axioms fail but a wheel structure emerges. Determine which theorems of real analysis survive transreal extension and which collapse.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.870934+00:00"
  },
  {
    "id": "fd_0117",
    "title": "The Unreasonable Effectiveness of Wrong Theories",
    "description": "Prove a meta-theorem: for any approximately correct physical theory T, there exists a class of phenomena for which T makes predictions closer to truth than any known correct theory. Formalize using perturbation theory on theory-space and prove that the wrongness of T forms a convergent series toward truth.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.964591+00:00"
  },
  {
    "id": "fd_0128",
    "title": "Aleph-1 Surface: Geometry Between Dimensions",
    "description": "Construct a surface whose Hausdorff dimension is exactly aleph-1 (assuming CH). Prove that such a surface cannot be embedded in any finite-dimensional Euclidean space but can be embedded in the Hilbert cube. Formalize transfinite-dimensional manifolds and prove they have no finite triangulation.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.030197+00:00"
  },
  {
    "id": "fd_0011",
    "title": "Knots That Think: Cognition as Braiding in Category Theory",
    "description": "The brain's connectome is a braid: neurons fire in sequences that interleave like strands of a braid group. Formalize this: a cognitive process is an element of the braid group B_n where n is the number of brain regions. Two cognitive processes are equivalent if their braids are related by Reidemeister moves (cognitive equivalence). Conjecture: The Jones polynomial of a cognitive braid is invariant under cognitive equivalence and encodes the information content of the thought. A thought with Jones polynomial V(t) = 1 is a trivial thought (equivalent to no thinking). A thought with V(t) = -t^2 + t + 1 is a creative thought (it contains a trefoil knot \u2014 the simplest non-trivial braid). The information content of a thought is log(|V(e^{2pi i/3})|), which measures the quantum dimension of the braid. Test: compute the Jones polynomial of braids representing simple cognitive processes (linear reasoning: trivial braid, creative insight: trefoil, confused thinking: figure-eight knot) and verify that the quantum dimension correlates with subjective ratings of thought quality. Impact: thinking IS braiding. The topology of your thoughts determines their quality. Creative insights are literally knotted.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.494775+00:00"
  },
  {
    "id": "fd_0025",
    "title": "Impossible Geometries: Where Parallel Lines Converge AND Diverge",
    "description": "Euclid's parallel postulate says parallel lines never meet. Hyperbolic geometry says they can diverge. Elliptic geometry says they converge. But what about a geometry where parallel lines BOTH converge AND diverge? Define a Split Geometry on R^2 where the parallel postulate is direction-dependent: lines parallel to the x-axis diverge (hyperbolic behavior) while lines parallel to the y-axis converge (elliptic behavior). The metric is ds^2 = dx^2/cosh^2(y) + dy^2 * cosh^2(x) \u2014 expanding in x and contracting in y. Conjecture: Split Geometry is a consistent Riemannian geometry with curvature K(x,y) = -sech^2(y) + sech^2(x) that changes sign across the diagonals. The geometry has a 'phase boundary' along the lines y = x and y = -x where K = 0 (flat). In the region |x| > |y|, K > 0 (elliptic) and in the region |y| > |x|, K < 0 (hyperbolic). The geodesics in split geometry are piecewise combinations of exponential curves (in hyperbolic regions) and trigonometric curves (in elliptic regions). Test: compute the Christoffel symbols and curvature tensor for the split metric. Prove that geodesics cross the phase boundary at most twice. Compute the area of a split triangle with one vertex in each region. Impact: a geometry where the curvature of space depends on which direction you look \u2014 the mathematical realization of a universe that is simultaneously expanding and contracting.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.514276+00:00"
  },
  {
    "id": "fd_0053",
    "title": "The Uncertainty Principle Is a Fourier Thing: Position-Momentum Duality",
    "description": "The Heisenberg uncertainty principle states that Delta(x) * Delta(p) >= hbar/2. But this is NOT a physical principle \u2014 it is a THEOREM of Fourier analysis. The Fourier transform of a function f(x) satisfies: if f is concentrated in a region of width Delta(x), then its Fourier transform f_hat is concentrated in a region of width Delta(k) >= 1/(2*Delta(x)). This is the Benedicks-Amrein-Berthier theorem: a function and its Fourier transform cannot both be supported on sets of finite measure. Conjecture: The uncertainty principle generalizes to all integral transforms. For the Laplace transform: if f is supported on [a, infinity), then the Laplace transform L[f](s) cannot be supported on a set of finite measure unless f = 0. For the Mellin transform: if f is supported on a geometric progression, then M[f](s) cannot be supported on a set of finite measure. For the Radon transform: if f is supported on a strip, then R[f] cannot be supported on a set of finite measure. The general principle: no invertible integral transform allows both a function and its transform to have compact support. Test: verify the uncertainty principle for the Fourier, Laplace, Mellin, and Radon transforms numerically. Construct functions with Delta(x) = epsilon and measure Delta(k) for each transform. Impact: the uncertainty principle is not about quantum mechanics \u2014 it is about the structure of integral transforms. Every transform has its own uncertainty principle.",
    "domains": [
      "Novelty",
      "Analysis"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.600658+00:00"
  },
  {
    "id": "fd_0067",
    "title": "Matroid Minors and the Graph Theorem: Robertson-Seymour for Matroids",
    "description": "The Robertson-Seymour theorem states that the set of finite graphs is well-quasi-ordered by the minor relation: any infinite sequence of graphs contains two where one is a minor of the other. This implies that any minor-closed graph property is characterized by a finite set of forbidden minors. Conjecture: the same theorem holds for representable matroids over any finite field. Specifically, for any finite field F_q, the set of F_q-representable matroids is well-quasi-ordered by the matroid minor relation. This would generalize the Robertson-Seymour theorem from graphs (F_2-representable matroids) to all finite fields. The conjecture is known to fail for general matroids (by the existence of infinite antichains of non-representable matroids), but for F_q-representable matroids with q <= 3, it is open. Conjecture: for F_3 (ternary matroids), the set of excluded minors for representability is finite. The current known excluded minors for F_3 are: the Fano matroid F_7, its dual F_7*, and the non-Pappus matroid. Test: enumerate ternary matroids of rank 3 on 9 elements, verify that all but the known excluded minors are F_3-representable. Impact: Robertson-Seymour for matroids would unify graph minor theory and matroid theory under a single well-quasi-ordering theorem.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.667149+00:00"
  },
  {
    "id": "fd_0085",
    "title": "The Riemann-Roch Theorem for Graphs: Chip-Firing and the Canonical Divisor",
    "description": "The Riemann-Roch theorem for graphs (Baker-Norine, 2007) states that for a divisor D on a graph G, l(D) - l(K_G - D) = deg(D) + 1 - g(G) where l(D) is the rank of D, K_G is the canonical divisor, and g(G) is the genus (cyclomatic number). The chip-firing game is a combinatorial model: vertices hold chips, and 'firing' a vertex sends one chip along each incident edge. Conjecture: for the complete graph K_n, the canonical divisor K_{K_n} has rank (n-1)(n-2)/2 - 1, and the Riemann-Roch formula gives l(D) = deg(D) + 1 - (n-1)(n-2)/2 + l(K_{K_n} - D). For D = K_{K_n} (the canonical divisor itself): l(K_{K_n}) = (n-1)(n-2)/2 - 1 + 1 - (n-1)(n-2)/2 + l(0) = 0 + l(0). But l(0) = 0 (the empty divisor has rank 0). So l(K_{K_n}) = 0. Wait, this gives l(K_{K_n}) = 0, but the canonical divisor of K_n should have positive rank. Conjecture: the canonical divisor of K_n is K_{K_n} = sum_v (deg(v) - 1) * v = (n-2) * sum_v v, and l(K_{K_n}) = (n-1)(n-2)/2 - 1 (it achieves the genus minus 1). Test: compute the canonical divisor and verify the Riemann-Roch formula for K_n with n = 3, 4, 5, 6. Impact: chip-firing on complete graphs encodes the same information as the Riemann-Roch theorem on projective curves.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.761503+00:00"
  },
  {
    "id": "fd_0108",
    "title": "Memory Editing: When Forgetting Is a Mathematical Operation",
    "description": "Formalize memory as a monoid homomorphism from experience streams to compressed representations. Prove that any such homomorphism satisfying a finite-memory bound must be lossy and that the information loss forms a submonoid. Show that targeted forgetting is equivalent to a quotient construction in the category of memory algebras.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.907112+00:00"
  },
  {
    "id": "fd_0127",
    "title": "Borges' Library of Babel: Combinatorics of Everything",
    "description": "Compute the topological type of the Library of Babel: a space of all possible 410-page books. Prove that it is connected, totally disconnected under the Hamming metric, and has covering dimension 0. Determine the Kolmogorov complexity of a random book and prove that almost all books are incompressible.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.024124+00:00"
  },
  {
    "id": "fd_0008",
    "title": "Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back",
    "description": "An Escher staircase is an infinite strictly ascending chain of ideals I_1 strictly contained in I_2 strictly contained in ... that nevertheless has I_1 as an element of the infinite intersection. This seems impossible \u2014 how can an infinite ascending chain loop back to the beginning? But in the ring of integer-valued polynomials Int(Z), the chain I_n = {f in Int(Z) : f(Z) contained in 2^n Z} is strictly ascending (I_n strictly contained in I_{n+1}) yet the intersection of all I_n is {0}, which contains the zero polynomial that is also in I_1. Conjecture: Every non-Noetherian ring contains an Escher staircase, and the 'height' of the Escher effect (measured by the Krull dimension gap) is a new ring invariant. For Int(Z), the Escher height is infinite (the chain never stabilizes). For Z[x_1, x_2, ...], the Escher height equals the number of variables. For the p-adic integers Z_p, there is NO Escher staircase (Z_p is a DVR, hence Noetherian). Test: prove that Int(Z) has an Escher staircase of infinite height. Prove that k[x_1,...,x_n] has Escher height n. Compute the Escher height for the ring of all algebraic integers. Impact: a new invariant for non-Noetherian rings that measures how far a ring is from being Noetherian \u2014 the algebraic equivalent of Escher's impossible architecture.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.492679+00:00"
  },
  {
    "id": "fd_0020",
    "title": "The Unreasonable Effectiveness of the Number 163",
    "description": "Ramanujan's constant e^{pi*sqrt(163)} is remarkably close to an integer: it equals 262537412640768743.99999999999925... \u2014 just 7.5 * 10^{-13} away from 262537412640768744. This is not a coincidence: 163 is the largest Heegner number, and the near-integer property follows from the j-function and the fact that Q(sqrt(-163)) has class number 1. But 163 appears EVERYWHERE: it is prime, it is the smallest p such that Q(sqrt(-p)) has class number 1 and p > 2, it is a Chen prime, a lucky prime, a strongly prime, and the 38th prime. Conjecture: 163 is the unique integer n such that e^{pi*sqrt(n)} is within 10^{-6} of an integer. More generally, the Heegner numbers (1, 2, 3, 7, 11, 19, 43, 67, 163) are exactly the n for which Q(sqrt(-n)) has class number 1, and e^{pi*sqrt(n)} is near-integer for each. The 'magic' of 163 is that it is the LAST Heegner number \u2014 the final class number 1 imaginary quadratic field. Test: prove that e^{pi*sqrt(n)} is within 10^{-6} of an integer only for Heegner numbers. Compute e^{pi*sqrt(67)} and e^{pi*sqrt(43)} and verify near-integer behavior. Prove that 163 is the largest Heegner number (Stark-Heegner theorem). Impact: 163 is not magic \u2014 it is the climax of a deep theorem in algebraic number theory. The near-integer property of e^{pi*sqrt(163)} is the shadow of the class number 1 condition.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.505215+00:00"
  },
  {
    "id": "fd_0032",
    "title": "The Mandelbrot Set's Secret Number Theory: Quadratic Recurrence and Primality",
    "description": "The Mandelbrot set M is defined by z_{n+1} = z_n^2 + c, and the boundary of M is the locus of c values where the orbit of 0 is bounded but barely so. Each bulb of M corresponds to a rational number p/q (the period-q bulb at angle p/q). The size of the p/q bulb decreases with q, and the Fibonacci sequence governs the spiral arrangement of bulbs. Conjecture: The period of the bulb at angle p/q (in lowest terms) is exactly q. Moreover, the Lyapunov exponent lambda(c) at the center of the p/q bulb equals log(2) * cos(pi*p/q). The 'prime bulbs' \u2014 bulbs at angles 1/q where q is prime \u2014 have special symmetry: they are the only bulbs with dihedral symmetry D_q. The composite bulbs have more complex symmetry groups. The prime factorization of the period determines the bulb's topology: a bulb of period n = p1^a1 * ... * pk^ak is topologically a product of k bulbs of periods p1^a1, ..., pk^ak. Test: for each rational p/q with q <= 20, locate the corresponding bulb in M, compute its Lyapunov exponent, and verify lambda = log(2) * cos(pi*p/q). Classify bulbs by the prime factorization of their period and verify the product structure. Impact: the Mandelbrot set is a visual calculator for prime factorization \u2014 every bulb encodes number-theoretic information about its period.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.530929+00:00"
  },
  {
    "id": "fd_0064",
    "title": "The Arithmetic of Games: Surreal Numbers as Number Fields",
    "description": "Conway's surreal numbers No form a proper class containing all real numbers, all ordinal numbers, and all infinitesimals. Every real number r has a surreal representation r = {r - 1 | r + 1}. Every ordinal alpha has a surreal representation alpha = {alpha |}. Every infinitesimal epsilon = {0 | 1, 1/2, 1/4, ...}. The surreal numbers form a field (in fact, a real-closed field). Conjecture: the subfield of surreals born by day omega (the set of surreals with finite birthdays) is isomorphic to the field of real algebraic numbers extended with all dyadic rationals. More precisely: No_{omega} = Q[2^{-n} : n in N] (the rationals extended with all dyadic rationals). The subfield born by day omega^2 contains all real numbers that are algebraic over the dyadic rationals, plus all infinitesimals that are algebraic over the reals. Conjecture: No_{omega^2} = R(x) where x is the smallest positive infinitesimal. Test: compute the field structure of surreals born by day omega and verify the isomorphism with the dyadic rationals. Impact: the surreal number hierarchy encodes the constructive hierarchy of real number fields \u2014 each birthday level adds exactly the algebraic closures needed.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.652777+00:00"
  },
  {
    "id": "fd_0071",
    "title": "Galois Theory of Cellular Automata: Which Rules Have Reversible Dynamics?",
    "description": "A cellular automaton (CA) rule f: A^Z -> A^Z is a function from configurations to configurations. The CA is reversible if f is bijective. By Hedlund's theorem, a CA is reversible iff its local rule is a permutation. But which CA rules have reversible dynamics? Conjecture: the set of reversible CA rules of radius r on alphabet A is a group under composition, isomorphic to a subgroup of S_{|A|^{2r+1}}. Specifically, the reversibility group G(r, A) is the subgroup of S_{|A|^{2r+1}} generated by the local rules of all reversible CAs of radius r. Conjecture: for binary CAs (A = {0, 1}) with radius r, G(r, {0, 1}) = S_{2^{2r+1}} for r >= 2. This means that any permutation of the 2^{2r+1} possible local neighborhoods can be achieved by composing reversible CA rules. For r = 1 (elementary CAs), G(1, {0, 1}) is a proper subgroup of S_8, and its structure is related to the 256 elementary CA rules. Conjecture: G(1, {0, 1}) has order 8! / 4 = 10080, consisting of the permutations that commute with the shift operator. Test: enumerate all 256 elementary CA rules, identify the reversible ones (Rule 15, 51, 85, 170, 204, 240), compute the group generated by their local rules, and verify the structure. Impact: reversible CAs form a group whose structure determines the landscape of reversible computation.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.686157+00:00"
  },
  {
    "id": "fd_0082",
    "title": "Information Geometry of Optimization: Natural Gradient Follows Geodesics",
    "description": "The natural gradient algorithm updates parameters theta in the direction of steepest descent on the Fisher information manifold: theta_{t+1} = theta_t - eta * G^{-1}(theta_t) * gradient L(theta_t) where G is the Fisher information matrix. This is equivalent to following the geodesic on the statistical manifold (the Riemannian manifold with metric G). Conjecture: for any optimization problem with loss function L, the natural gradient descent converges to the minimum in O(1/t) iterations, regardless of the condition number of G. This is because the natural gradient follows the geodesic, which is the shortest path on the manifold, and the path length is O(1) (bounded by the diameter of the manifold). In contrast, standard gradient descent takes O(kappa) iterations where kappa is the condition number of G. Conjecture: natural gradient descent with step size eta = 1/t achieves L(theta_t) - L(theta*) = O(1/t) for convex losses, and L(theta_t) - L(theta*) = O(exp(-t/d)) for strongly convex losses, where d is the dimension. Test: compare natural gradient descent and standard gradient descent on logistic regression with varying condition numbers, verify the convergence rates. Impact: optimization is geometry. The natural gradient is the geodesic on the Fisher manifold, and geodesics are the shortest paths.",
    "domains": [
      "Novelty",
      "MachineLearning"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.744530+00:00"
  },
  {
    "id": "fd_0103",
    "title": "Infinite-Dimensional Chess: Winning on the Hilbert Board",
    "description": "Formalize chess played on an infinite board. Prove that the king can always escape on an infinite board and determine which finite-piece configurations are forced mates. Develop a theory of infinite combinatorial game value and prove its relationship to ordinal game values.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.877377+00:00"
  },
  {
    "id": "fd_0113",
    "title": "The Topology of Impossible Objects: Escher Stairs and Klein Bottles",
    "description": "Formalize the mathematical conditions under which impossible figures (Penrose triangles, Escher stairs) can exist as manifolds. Prove that every non-orientable 3-manifold contains an embedded Penrose triangle as a smoothly immersed surface. Classify which impossible figures are realizable as developable surfaces.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.937834+00:00"
  },
  {
    "id": "fd_0134",
    "title": "Aboriginal Kinship as Group Theory: Dreamtime Algebra",
    "description": "Formalize Australian Aboriginal kinship systems (section and subsection systems) as finite groups acting on person-sets. Prove that the 4-section system is isomorphic to Z2 x Z2 and the 8-subsection system to Z2 x Z2 x Z2. Show that marriage rules correspond to coset restrictions and that the entire system forms a consistent group-theoretic structure.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.067326+00:00"
  },
  {
    "id": "fd_0017",
    "title": "Tropical Cryptocurrency: Mining on the Min-Plus Semiring",
    "description": "Bitcoin mining requires finding a nonce n such that SHA256(block_header || n) < target. What if we replaced SHA256 with a tropical hash? Define tropical SHA as: TSHA(m) = min over all i of (m_i + h_i) where m = (m_1,...,m_k) is the message, h = (h_1,...,h_k) is the tropical hash key, and all operations are in the min-plus semiring (a tropical plus b = min(a,b), a tropical times b = a + b). Conjecture: TSHA is a one-way function in the tropical sense: computing TSHA(m) given m and h is O(k) (trivial), but finding m given TSHA(m) and h is NP-hard (it reduces to a tropical shortest path problem). More precisely, the tropical preimage problem \u2014 given y and h, find m such that min_i(m_i + h_i) = y \u2014 requires checking O(e^{k}) tropical paths in the worst case. But there's a twist: tropical hash collisions are COMMON because min(a,b) = min(b,a). To fix this, define TSHA2(m) = (min_i(m_i + h_i), min_i(m_i + h'_i)) where h and h' are two independent tropical keys. Conjecture: TSHA2 is collision-resistant with probability 1 - O(1/k). Test: implement TSHA and TSHA2, measure collision resistance, and compare mining difficulty to SHA256 for block sizes k = 32, 64, 128. Impact: a cryptocurrency where mining is solving tropical optimization problems instead of brute-force hash searches \u2014 mining IS mathematics.",
    "domains": [
      "Novelty",
      "Tropical"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.501089+00:00"
  },
  {
    "id": "fd_0042",
    "title": "The Topology of Knotted Light: How Laser Beams Get Tangled",
    "description": "Laser beams can carry orbital angular momentum (OAM), creating 'knotted light' \u2014 beams whose wavefronts are linked or knotted. A knotted light beam has a phase singularity (where the amplitude vanishes) that traces out a knot in 3D space. The simplest example is the trefoil beam, whose singularity traces a trefoil knot. Conjecture: The OAM spectrum of a knotted light beam encodes the Alexander polynomial of the knot. Specifically, if the singularity of the beam traces a knot K, then the OAM spectrum (the set of allowed angular momentum values) is {l : Delta_K(e^{2*pi*i*l/N}) = 0} where Delta_K is the Alexander polynomial of K and N is the crossing number. For the trefoil (Delta = t^2 - t + 1), the OAM spectrum includes l = 1/6, 5/6 (mod 1), giving OAM values l = 1, 5 (mod 6). For the unknot (Delta = 1), the OAM spectrum is trivial (l = 0 only). For the figure-eight knot (Delta = t^2 - 3t + 1), the OAM values include l = (3 \u00b1 sqrt(5))/2 mod 1. Test: compute the OAM spectrum of trefoil, figure-eight, and cinquefoil beams numerically and verify they match the Alexander polynomial predictions. Impact: knotted light carries knot invariants in its angular momentum \u2014 shining a laser through a knot-shaped hologram encodes the Alexander polynomial in the beam's quantum numbers.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.561091+00:00"
  },
  {
    "id": "fd_0068",
    "title": "The Fourier Analysis of Collatz: Spectral Gaps in the 3n+1 Map",
    "description": "The Collatz map T: N -> N defined by T(n) = n/2 if n even, 3n+1 if n odd, is conjectured to always reach 1. The Collatz conjecture is equivalent to: the orbit of every n under T eventually reaches the cycle {1, 4, 2, 1}. Define the Collatz Fourier transform: F_T(omega) = sum_{n=1}^{N} e^{2*pi*i*omega*T(n)/n} for N large. Conjecture: F_T has a spectral gap: |F_T(omega)| < C for all irrational omega, where C < sqrt(N). This would mean that the Collatz map does not concentrate energy at any irrational frequency \u2014 it is 'mixing' in the Fourier sense. Moreover, the spectral gap is related to the convergence rate: the wider the gap, the faster the orbit reaches 1. Conjecture: for the orbit of n, the number of steps to reach 1 is O(log(n)), which is equivalent to F_T having a spectral gap of width Omega(1/log(n)). Test: compute F_T for n up to 10^6 and measure the spectral gap. Compare with the spectral gaps of related maps (5n+1, 7n+1) which do NOT always converge. Impact: the Collatz conjecture is a spectral gap problem. Convergence to 1 means the Fourier transform has no resonances at irrational frequencies.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.672038+00:00"
  },
  {
    "id": "fd_0096",
    "title": "The Poincare Conjecture for Data: Manifold Detection via Persistent Homology",
    "description": "The Poincare conjecture (proved by Perelman) states that every simply connected closed 3-manifold is homeomorphic to the 3-sphere. For data: a point cloud X = {x_1, ..., x_n} in R^d may or may not lie on a manifold. Conjecture: the Poincare conjecture for data states that if the persistent homology of X satisfies H_0(X) = Z, H_1(X) = 0, H_2(X) = 0, ..., H_{d-1}(X) = 0, then X lies on (or near) a d-sphere. More precisely, if the Vietoris-Rips complex of X at scale epsilon has the homology of S^d (trivial homology except H_0 = Z and H_d = Z), then X is epsilon-close to a subset of S^d. Conjecture: the smallest epsilon such that VR_epsilon(X) has the homology of S^d is the 'Poincare threshold' of X, and it satisfies epsilon_star = C * d^{1/2} * n^{-1/d} for some constant C, where n is the number of points. This is the manifold detection threshold: below epsilon_star, X looks like a d-sphere; above epsilon_star, X looks like something else. Test: generate point clouds on S^d for d = 1, 2, 3 and compute the Poincare threshold. Impact: the Poincare conjecture for data says that manifold detection is a topological problem, and the detection threshold scales as n^{-1/d}.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.834465+00:00"
  },
  {
    "id": "fd_0115",
    "title": "Flatland Catastrophe: When 2D Physics Breaks",
    "description": "Prove that 2-dimensional Newtonian gravity is mathematically pathological: orbits don't close, there's no stable circular orbit, and gravitational potential is logarithmic. Formalize the Bertrand-Darboux theorem failure in 2D and prove that stable planetary systems cannot exist in Flatland.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.951261+00:00"
  },
  {
    "id": "fd_0009",
    "title": "The Mathematics of Deja Vu: Fixed Points in Consciousness and Cognition",
    "description": "Deja vu \u2014 the feeling that you've experienced something before \u2014 is a fixed point in a dynamical system. Model cognitive state as a function f: S -> S mapping current brain state to next brain state. A deja vu is a state s such that f^n(s) = s for some n > 0 \u2014 a periodic point of the cognitive dynamical system. Conjecture: By Sharkovsky's theorem, the existence of a period-3 orbit in the cognitive dynamics (three distinct states that cycle) implies chaos in the sense of Li-Yorke, meaning there exist uncountably many cognitive trajectories that are neither periodic nor convergent. Moreover, the set of deja vu states (periodic points of f) is dense in the cognitive state space S if f is continuous and S is an interval. The frequency of deja vu (occurring in ~70% of people) corresponds to the natural density of periodic points in a typical chaotic map. Test: model cognitive dynamics as a logistic map f(x) = rx(1-x) on [0,1] with parameter r chosen to match empirical deja vu frequencies. For r = 3.83 (period-3 window), compute the density of periodic points and compare to the 70% lifetime incidence. Impact: deja vu is not a glitch \u2014 it's a mathematical inevitability of continuous cognitive dynamics. Any continuous cognitive map with a period-3 orbit MUST have deja vu.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.493320+00:00"
  },
  {
    "id": "fd_0030",
    "title": "The Prime Number Crossword: Filling the Gaps in the Primes",
    "description": "Prime gaps \u2014 the spaces between consecutive primes \u2014 are like empty cells in a crossword puzzle. The gaps are 1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4, 6, 6, 2, 6, 4, 2, ... (OEIS A001223). The pattern seems random, but the crossword has rules: (1) All prime gaps are even (except the first gap of 1 between 2 and 3). (2) A gap g can only appear at position n if n+g is prime and all of n+1, n+2, ..., n+g-1 are composite. (3) The density of gap g near n is approximately 2*C_2/(g*log(n)) where C_2 is the twin prime constant. Conjecture: The prime gap crossword is uniquely solvable \u2014 given the pattern of gaps up to N, the next prime is determined with probability 1 - O(1/log(N)). More precisely, the conditional probability that the next prime after p is p + g, given all primes up to p, is approximately 2*C_2/g * (1/log(p)) * product_{q prime, q | g} (q-1)/(q-2). This is the Hardy-Littlewood conjecture for prime gaps. But the crossword has a surprise: certain gap patterns FORCE the next number. For example, if the gaps near n are 6, 4, 2, 6, then the next gap is almost certainly 4 (the only way to fill the crossword). Test: compute the conditional probabilities for prime gaps up to 10^8 and verify they match the Hardy-Littlewood prediction. Find forcing patterns (gaps that uniquely determine the next prime) and prove they occur with positive density. Impact: prime gaps are not random \u2014 they are a solvable crossword puzzle with deterministic rules.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.525722+00:00"
  },
  {
    "id": "fd_0034",
    "title": "Cellular Automata as Algebraic Geometry: Wolfram's Rules Meet Grothendieck",
    "description": "Elementary cellular automata (ECAs) are the 256 rules that update a 1D binary array based on its 3-cell neighborhood. Rule 110 is Turing-complete. But ECAs can also be viewed as polynomial maps over GF(2): the state s = (s_0, s_1, ..., s_{n-1}) is a vector over GF(2), and the update rule is s -> f(s) where f is a degree-3 polynomial (since the rule depends on 3 cells). Conjecture: The algebraic variety V(f) = {s : f(s) = s} (fixed points of the ECA) has dimension equal to the 'complexity class' of the rule. For simple rules (e.g., Rule 0, which is all zeros), V(f) has dimension 0 (a single point). For complex rules (e.g., Rule 110), V(f) has maximal dimension. The Grothendieck-style approach: each ECA defines a sheaf on the state space, and the global sections of this sheaf classify the possible stable configurations. Rule 110's sheaf has the richest section structure, corresponding to its Turing-completeness. Test: compute dim(V(f)) for all 256 ECAs and verify that the dimension correlates with Wolfram's complexity classification (Class 1: dim=0, Class 2: dim<=n/2, Class 3: dim>=n/2, Class 4: dim=n). Impact: cellular automata are algebraic varieties, and their complexity is the dimension of their fixed-point variety.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.536490+00:00"
  },
  {
    "id": "fd_0052",
    "title": "Sheaf Cohomology of Data: The Topology of Missing Information",
    "description": "A dataset with missing values is a sheaf on a poset: the poset is the set of feature subsets (ordered by inclusion), and the sheaf assigns to each feature subset the set of complete observations on those features. The missing data creates 'holes' in the sheaf: H^0 measures the global sections (complete observations) and H^1 measures the obstructions to patching local observations into global ones. Conjecture: For a dataset with missing rate r, the dimension of H^1 is approximately r * n * (r * log(1/r)), where n is the number of features. This means: the 'amount of missing information' grows super-linearly with the missing rate, and imputation is fundamentally harder than interpolation because H^1 > 0 means there is no consistent way to fill in the missing data. The sheaf-theoretic imputation: fill in missing values by finding the section s in H^0 that minimizes the coboundary delta(s) in H^1. This is the maximum likelihood imputation under the assumption that the data is locally consistent. Test: generate synthetic datasets with known ground truth, introduce missing values at rate r, compute H^0 and H^1 of the data sheaf, and verify dim(H^1) ~ r*n*r*log(1/r). Compare sheaf-theoretic imputation with standard methods (mean, KNN, MICE). Impact: missing data is a topological problem, and the sheaf cohomology tells you exactly how much information is lost and whether it can be recovered.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.596679+00:00"
  },
  {
    "id": "fd_0062",
    "title": "The P vs NP of Sudoku: Phase Transitions in Constraint Satisfaction",
    "description": "Sudoku is a constraint satisfaction problem (CSP). Random Sudoku instances exhibit a phase transition: for n^2 x n^2 grids, the probability of having a solution drops from ~1 to ~0 around a critical density of pre-filled cells. Conjecture: the phase transition occurs at density d_c(n) = (n^2 - 1) / n^2, independent of the specific constraint structure. For standard 9x9 Sudoku (n=3): d_c = 8/9 \u2248 0.889. For 4x4 Sudoku (n=2): d_c = 3/4 = 0.75. For 16x16 (n=4): d_c = 15/16 \u2248 0.9375. The 'hardness' of random Sudoku peaks at the phase transition: instances with density near d_c take exponentially longer to solve than easy (low density) or trivial (high density) instances. Conjecture: the computational hardness of Sudoku at the phase transition is O(exp(n^2)) for backtracking algorithms, matching the theoretical prediction for CSPs at criticality. Test: generate random Sudoku instances at varying densities, measure solver time, and verify the phase transition at d_c. Impact: Sudoku hardness is not about 9x9 grids \u2014 it is about the phase transition structure of constraint satisfaction.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.639161+00:00"
  },
  {
    "id": "fd_0012",
    "title": "The Periodic Table of Finite Groups: Chemistry Meets Algebra",
    "description": "Mendeleev organized 63 elements into a periodic table that predicted undiscovered elements. Can we do the same for finite groups? Classify all finite groups of order <= 2000 (there are approximately 10^15 of them, so we need a structural organization). Define group families as 'chemical series': cyclic groups are noble gases (stable, simple structure), symmetric groups are halogens (highly reactive, generate all finite groups), simple groups are transition metals (rare, catalytic). Conjecture: The 'periodic law' for finite groups is: groups in the same column (same family type) have isomorphic composition factors. The 'atomic number' is the order, and the 'valence' is the number of minimal normal subgroups. Groups with the same composition factors but different orders are 'isotopes' \u2014 they share chemical properties (solubility = solvability, reactivity = generation capacity). Test: construct a periodic table of groups of order <= 100, organizing them by composition factors. Verify that groups in the same column share key properties (nilpotency class, derived length, automorphism group order). Predict the properties of undiscovered groups (e.g., order 120, composition factors {2,2,2,3,5}) before looking them up. Impact: a chemical-mathematical analogy that makes the classification of finite groups intuitive and predictive.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.495596+00:00"
  },
  {
    "id": "fd_0024",
    "title": "The Mathematics of Memes: Viral Information Topology",
    "description": "A meme is a unit of cultural information that replicates through human minds. Model meme propagation as a sheaf over the social network graph: each node is a person, each edge is a communication channel, and the meme is a section of the sheaf that must satisfy consistency conditions at each node. Define meme fitness as the sheaf cohomology group H^1(G, M) where G is the social network and M is the meme sheaf. A meme with H^1 = 0 is universally transmissible (it has no consistency barriers \u2014 anyone can understand it). A meme with H^1 of dimension d requires d 'interpretation steps' to cross between communities. Conjecture: The most viral memes have H^1(G, M) = 0 but H^0(G, M) of maximal dimension \u2014 they spread everywhere AND mean different things to different communities. The dimension of H^0 counts the number of distinct interpretations. A meme that means the same thing to everyone has dim(H^0) = 1 and dim(H^1) = 0. A meme that means different things to different communities has dim(H^0) > 1 and dim(H^1) = 0. A meme that CANNOT spread between communities has H^1 > 0. Test: model Twitter/X retweet networks as graphs G with 1000 nodes, assign meme sheaves based on community structure, compute H^0 and H^1, and correlate with actual virality data. Impact: meme virality is a topological property \u2014 it's not about content quality but about the sheaf cohomology of the social network.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.512076+00:00"
  },
  {
    "id": "fd_0043",
    "title": "The Mathematics of Jigsaw Puzzles: NP-Completeness and Topology",
    "description": "A jigsaw puzzle has N pieces, each with 4 edges. The 'signature' of a piece is the tuple (top, right, bottom, left) of edge types (flat, tab, blank). Two pieces fit together if their adjacent edges are complementary (tab meets blank). Conjecture: Solving a jigsaw puzzle is NP-complete. The reduction: given a 3-SAT formula with n variables and m clauses, construct a jigsaw puzzle with N = 2n + m + 2 pieces where the only valid assembly corresponds to a satisfying assignment. Variable pieces: each variable x_i has two pieces (TRUE and FALSE), one with a tab and one with a blank on the assignment edge. Only one can be placed (mutual exclusion via complementary edges). Clause pieces: each clause C_j is a piece that has three input edges (one per literal) and one output edge. The piece fits only if at least one input edge is connected to a TRUE literal piece. The top-left corner and bottom-right corner enforce the boundary. Test: construct the reduction explicitly for a small 3-SAT instance (e.g., (x1 OR x2 OR NOT x3) AND (NOT x1 OR x3)) and verify the puzzle has a solution iff the formula is satisfiable. Impact: jigsaw puzzles are NP-complete, so the satisfying snap you feel when completing a puzzle is literally the same as solving a hard computational problem.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.564171+00:00"
  },
  {
    "id": "fd_0055",
    "title": "Turing's Flowers: Morphogenesis as Algebraic Geometry",
    "description": "In 1952, Turing showed that reaction-diffusion equations produce patterns (spots, stripes, spirals) that explain biological morphogenesis. But Turing patterns are solutions to PDEs, which are hard to analyze. Conjecture: Turing patterns are algebraic varieties. Specifically, the zero set of a Turing pattern (where the concentration equals the background level) is a real algebraic curve in 2D (for spots and stripes) or a real algebraic surface in 3D (for more complex patterns). The degree of the curve is the number of modes in the reaction-diffusion system. For a two-mode system (like the Gray-Scott model), the pattern is a curve of degree 2 (a conic section: circles for spots, parallel lines for stripes, hyperbolas for labyrinthine patterns). For a three-mode system, the pattern is a curve of degree up to 6 (sextic curves that can produce hexagonal patterns). The genus of the curve determines the pattern topology: genus 0 gives spots (topologically a sphere), genus 1 gives stripes (topologically a torus), and genus g > 1 gives labyrinthine patterns with g+1 holes. Test: simulate Turing patterns in the Gray-Scott model, fit the zero-set to an algebraic curve of degree d, and verify that d = 2 for spots and stripes. Compute the genus and verify it matches the pattern topology. Impact: biological patterns are algebraic curves. The mathematics of seashells, leopard spots, and zebra stripes is the mathematics of conic sections.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.608699+00:00"
  },
  {
    "id": "fd_0069",
    "title": "Sperner's Lemma Implies Nash Equilibria: Combinatorial Fixed Points in Game Theory",
    "description": "Sperner's lemma states that any proper coloring of a triangulated simplex with n+1 colors has at least one fully colored simplex. This is a combinatorial analog of Brouwer's fixed point theorem. Nash's theorem states that every finite game has a mixed strategy Nash equilibrium, proved using Kakutani's fixed point theorem. Conjecture: Sperner's lemma directly implies Nash's theorem. Specifically, given an n-player game with strategies S_1, ..., S_n, construct the n-simplex Delta = Delta(S_1 x ... x S_n) of mixed strategy profiles. Define a Sperner coloring of Delta by: color vertex v with color i if player i's best response to v is strategy i. By Sperner's lemma, there exists a fully colored simplex. The center of this simplex is an approximate Nash equilibrium (each player is approximately best-responding). Taking the limit as the triangulation gets finer gives an exact Nash equilibrium. Conjecture: this construction gives a constructive proof of Nash's theorem that yields a triangulation-based algorithm for finding Nash equilibria with complexity O(N^{n}) where N is the total number of pure strategies. Test: implement the Sperner-based algorithm for 2-player games and verify it finds all Nash equilibria. Impact: Nash equilibria are combinatorial fixed points. Sperner's lemma is the fundamental theorem of game theory.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.676713+00:00"
  },
  {
    "id": "fd_0081",
    "title": "The Topology of Argumentation: Why Debates Have Holes",
    "description": "An argumentation framework AF = (A, R) consists of a set of arguments A and an attack relation R subset A x A. The preferred extensions of AF are the maximal admissible sets (subsets S of A that defend themselves against all attacks and are maximal with this property). Conjecture: the preferred extensions of AF form a simplicial complex K(AF) on the vertex set A. The homology groups H_n(K(AF)) measure the 'holes' in the argumentation structure. H_0 measures the number of connected components (independent debate threads). H_1 measures circular arguments (cycles where each argument attacks the next, and the last attacks the first). H_2 measures 'spheres' of arguments (3D cycles where arguments form a spherical shell). Conjecture: for any argumentation framework, the Euler characteristic chi(K(AF)) = |A| - |R| + sum_{n>=2} (-1)^n * dim(H_n) equals |preferred extensions| - |grounded extension size|. This connects the topology of the argument to its semantics. Test: construct K(AF) for 100 argumentation frameworks from debate transcripts, compute homology groups, and verify the Euler characteristic formula. Impact: arguments have topology. Circular arguments are 1-holes, and 3D argument spheres are 2-holes. The shape of a debate is a topological invariant.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.739014+00:00"
  },
  {
    "id": "fd_0083",
    "title": "The Spectral Gap of Sudoku: When Puzzles Become Phase Transitions",
    "description": "A Sudoku puzzle is a constraint satisfaction problem on a 9x9 grid. The 'spectral gap' of a Sudoku puzzle is the gap between the two largest eigenvalues of the transition matrix of the Markov chain that randomly swaps two compatible entries. The spectral gap determines the mixing time: the number of swaps needed to generate a uniformly random solution. Conjecture: the spectral gap of a Sudoku puzzle undergoes a phase transition at the critical density d_c = 17/81 (the density of the minimal number of clues, 17, divided by 81). For puzzles with fewer than 17 clues, the spectral gap is large (the Markov chain mixes quickly, meaning there are many solutions). For puzzles with exactly 17 clues, the spectral gap is minimal (the chain mixes slowly, meaning solutions are hard to find). For puzzles with more than 30 clues, the spectral gap is zero (the chain is reducible, meaning the puzzle has a unique solution and no swaps are possible). Conjecture: the spectral gap lambda_1 - lambda_2 of the Sudoku Markov chain satisfies: lambda_1 - lambda_2 > epsilon for d < 17/81 (many solutions, fast mixing), lambda_1 - lambda_2 ~ 0 for d ~ 17/81 (critical point, slow mixing), and the chain is absorbing for d > 30/81 (unique solution, no mixing). Test: compute the spectral gap for Sudoku puzzles with varying numbers of clues and verify the phase transition. Impact: Sudoku has a spectral gap phase transition. The hardness of the puzzle is determined by the gap, not by the number of clues.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.750240+00:00"
  },
  {
    "id": "fd_0094",
    "title": "Hypergraph Ramsey Theory: Beyond Graphs",
    "description": "Ramsey's theorem for graphs states that R(k,l) = the minimum n such that any 2-coloring of the edges of K_n contains a red K_k or a blue K_l. For hypergraphs: R_r(k,l) = the minimum n such that any 2-coloring of the r-tuples of an n-set contains a red K_k^{(r)} or a blue K_l^{(r)}. The growth rate is an open problem: R_3(4,4) = 13 (known), R_3(5,5) is between 34 and 55, and R_3(k,k) is believed to grow like a double exponential 2^{c*k^2}. Conjecture: R_3(k,k) ~ 2^{2^{ck}} for some constant c > 0. This is a tower function (height 2 exponential). More precisely: the lower bound R_3(k,k) >= 2^{ck^2} (from the probabilistic method) and the upper bound R_3(k,k) <= 2^{2^{ck}} (from the stepping-up lemma). The gap is between a single exponential and a double exponential. Conjecture: the true growth rate is double exponential, and the upper bound is tight. This would mean that 3-uniform Ramsey numbers grow much faster than graph Ramsey numbers. Test: compute R_3(k,k) for k = 3, 4, 5, 6 by exhaustive search and verify the growth rate. Impact: 3-uniform Ramsey numbers are double exponential. Combinatorics at the hypergraph level is fundamentally harder than at the graph level.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.820858+00:00"
  },
  {
    "id": "fd_0019",
    "title": "Arithmetic on the Moebius Band: A Number System with a Twist",
    "description": "The Moebius band M is obtained from [0,1] x R by identifying (0, y) ~ (1, -y). Define arithmetic on M: a point (x, y) on M represents the number y * (2x - 1) where x in [0,1] gives the sign and magnitude, and y gives the scale. This creates a number system where going around the band flips the sign. Define the Moebius integers Z_M as the image of Z in M under the embedding n -> (1/2 + 1/(2n), |n|). Then 1 and -1 are identified at the twist point (1, 1) = (0, -1), making Z_M a one-point compactification of Z with a single infinity. Conjecture: Z_M is a ring under the induced operations from R x R / ~, but it is NOT an integral domain because (1, 0) * (0, 1) = (0, 0) but neither factor is zero in Z_M. The prime factorization in Z_M has a unique 'twist prime' that encodes orientation, and every non-zero Moebius integer has a factorization of the form \u00b1p_1^{a_1} * ... * p_k^{a_k} where the overall sign is the twist. Test: factor the Moebius integers 6, -6, and 0 in Z_M. Verify that 6 = 2_+ * 3_+ and -6 = 2_- * 3_- = 2_+ * 3_+ * (-1) where -1 is the twist prime. Impact: arithmetic on a non-orientable surface creates a number system where orientation IS a prime \u2014 a number-theoretic analog of spin in physics.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.503818+00:00"
  },
  {
    "id": "fd_0060",
    "title": "Persistent Homology of Musical Harmony: The Topology of Bach",
    "description": "Bach's chorales are the gold standard of Western harmony. But what if we could MEASURE the harmonic complexity using topology? Encode each chord as a point in a 12-dimensional space (one dimension per pitch class). A sequence of chords traces a path in this space. Compute the persistent homology of the point cloud of all chords in a Bach chorale. Conjecture: Bach's chorales have persistent H_1 (1-dimensional cycles) that survive across a wide range of scales, indicating circular harmonic motion (the circle of fifths). In contrast, random chord sequences have H_1 bars that die quickly. The longest H_1 bar in a Bach chorale corresponds to the circle of fifths \u2014 the fundamental harmonic cycle. Pop music has shorter H_1 bars (less complex harmonic cycles). Atonal music has no persistent H_1 (no harmonic cycles). Test: compute persistent homology barcodes for 100 Bach chorales, 100 pop songs, and 100 atonal pieces. Verify: Bach has H_1 bars of length > 0.5 (in normalized pitch-class space), pop has bars of length 0.2-0.5, atonal has no persistent H_1. Impact: the topology of music IS its harmonic structure. Bach's genius is literally topological \u2014 his music has longer harmonic cycles.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.630214+00:00"
  },
  {
    "id": "fd_0079",
    "title": "The Hodge Conjecture for Neural Networks: Algebraic Cycles in Decision Surfaces",
    "description": "The Hodge conjecture states that every rational cohomology class on a projective variety is a rational linear combination of algebraic cycles. For a ReLU neural network f: R^n -> R, the decision surface V(f) = {x : f(x) = 0} is a piecewise linear hypersurface. Conjecture: every rational homology class in H_{n-2}(V(f), Q) is represented by an algebraic cycle (a subvariety of V(f) of codimension 1). Since V(f) is piecewise linear, its homology groups are finitely generated and every cycle is a formal sum of linear pieces. Each linear piece is an algebraic cycle (a hyperplane section). Conjecture: the piecewise linear Hodge conjecture holds \u2014 every homology class in V(f) is a sum of hyperplane sections. This is TRUE for piecewise linear varieties because every face of a polyhedron is cut out by a linear equation. The deeper conjecture: for a ReLU network with L layers and widths (n, w_1, ..., w_L, 1), the Hodge numbers h^{p,q}(V(f)) satisfy h^{p,q} <= (w_1 choose p) * (w_L choose q) * prod_{i=2}^{L-1} w_i. Test: compute H_{n-2}(V(f)) for small ReLU networks and verify that every class is represented by hyperplane sections. Impact: the Hodge conjecture is trivially true for neural network decision surfaces. The non-trivial content is the BOUND on Hodge numbers.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.728070+00:00"
  },
  {
    "id": "fd_0006",
    "title": "Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities",
    "description": "A vampire number is a composite number v with an even number of digits that can be factizedd as v = x * y where x and y together have the same digits as v. The smallest is 1260 = 21 * 60. But vampire numbers are just the beginning. Define: (1) Werewolf numbers: v = x * y where x and y share exactly one digit with v. (2) Ghost numbers: v = x * y where v has NO digits in common with x or y. (3) Zombie numbers: v = x * y where x and y are both prime (these violate the definition but exist \u2014 125460 = 204 * 615 = 246 * 510, where both factorizations involve a prime and a composite). Conjecture: The density of vampire numbers in [10^{2n}, 10^{2n+1}] approaches 1/sqrt(n) as n -> infinity. Every even-length interval [10^{2k}, 10^{2k+2}] contains at least one vampire number. Ghost numbers have density 0 \u2014 they become vanishingly rare as the number of digits increases. Test: enumerate all vampire, werewolf, ghost, and zombie numbers up to 10^8. Prove the density conjecture by counting valid digit permutations. Impact: a playful but genuine number theory of arithmetic creatures \u2014 combinatorial digit problems that are easy to state but may be as hard as factoring.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.491505+00:00"
  },
  {
    "id": "fd_0146",
    "title": "Reflective Type Theory (ReflTT) as a formal fram",
    "description": "# Future Directions: Reflective Type Theory\n\n## Synthesis\n\nThis research cycle established Reflective Type Theory (ReflTT) as a formal framework for self-referential provability, proving three core results: (1) the system properly extends Martin-L\u00f6f Type Theory via a strict provability depth hierarchy, (2) the type language is exactly the modal mu-calculus via a bijective, structure-preserving translation, and (3) the system can express \"provable but not provably provable\" as a well-typed term at depth \u2265 2, with this depth being irreducible.\n\nThe most promising cross-domain connection emerged from the Proof Depth Algebra \u2014 a novel algebraic structure that tracks not just provability depth but multiplicity and fixed-point involvement. This structure suggests connections to graded monads in category theory and to the ordinal analysis of proof-theoretic strength. The correspondence with the modal mu-calculus also creates a direct bridge to formal verification and model checking in computer science, where the mu-calculus is a fundamental tool.\n\nThe highest breakthrough potential lies in Direction 1 (typed provability logic with a full typing judgment), which would complete the foundations and unlock the full power of the propositions-as-types correspondence for provability reasoning. Direction 3 (categorical semantics) has the potential to reveal unexpected structural insights, as the depth filtration resembles a grading on a monoidal category. The connection to tropical semirings in Direction 4 is speculative but could bridge this work to the Catalog's extensive tropical geometry infrastructure.\n\n---\n\n### Direction 1: Complete Typed Provability Logic\n\n**Conjecture**: The typing relation for ReflTerm (the proof term language of ReflTT) satisfies subject reduction (well-typed terms reduce to well-typed terms) and weak normalization (every well-typed term has a normal form), but NOT strong normalization \u2014 the fixed-point operator \u03bc introduces non-terminating reduction sequences that correspond to L\u00f6b's theorem.\n\n**Test**: Define the typing relation `\u0393 \u22a2 t : A` for ReflTerm and the reduction relation `t \u21a6 t'`. Prove that if `\u0393 \u22a2 t : A` and `t \u21a6 t'`, then `\u0393 \u22a2 t' : A`. Construct an explicit well-typed term of type `L\u00f6b(base(0))` (the L\u00f6b axiom type `\u25a1(\u25a1P \u2192 P) \u2192 \u25a1P`) and show it has no strong normal form. The typing rules should include: (i) `quote` introduction for \u25a1, (ii) `eval` elimination for \u25a1 (restricted to avoid inconsistency), (iii) `roll`/`unroll` for \u03bc-types.\n\n**Impact**: If subject reduction holds, this establishes ReflTT as a bona fide type theory, not just a type grammar. The failure of strong normalization at \u03bc-types would give a precise characterization of where self-reference breaks termination \u2014 directly connecting to the incompleteness theorems. If weak normalization also fails, it would suggest that the system is too expressive and needs to be stratified.\n\n**Catalog References**: `Bridges/ReflectiveTypeTheoryDefs.lean` (ReflTerm definition), `Bridges/ReflectiveTypeTheory.lean` (depth hierarchy)\n\n**Proof Strategy**: Define the typing judgment as an inductive type in Lean. For subject reduction, proceed by induction on the typing derivation. For the normalization counterexample, construct a term `t = roll(lam(app(eval(var 0), var 0)))` of type `\u03bc(\u25a1(base 0) \u2192 base 0)` and show that its reduction is cyclic. The key challenge is designing the `eval` rule to be sound (not derive `\u22a5`) while still being useful.\n\n**Domain Bridges**: Provability Logic <-> Type Theory <-> Term Rewriting Systems\n\n**Lineage**: Builds directly on the ReflTy and ReflTerm definitions established in this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Provability Depth and Ordinal Analysis\n\n**Conjecture**: The provability depth hierarchy corresponds to the fast-growing hierarchy of ordinals. Specifically, for each natural number n, the fragment of ReflTT at depth \u2264 n has proof-theoretic ordinal \u03b5\u2080 \u00b7 (n+1), where \u03b5\u2080 is the proof-theoretic ordinal of Peano arithmetic. The depth-n fragment can prove the consistency of the depth-(n-1) fragment but not its own consistency.\n\n**Test**: Define a \"provability predicate\" Prov_n for the depth-n fragment of ReflTT. Show that Prov\u2081 can express Con(PA) (the consistency of PA), that Prov\u2082 can express Con(PA + Con(PA)), and compute the proof-theoretic ordinal of each level by constructing ordinal notations and proving their well-ordering within each fragment.\n\n**Impact**: If true, this would provide a type-theoretic proof of the ordinal analysis hierarchy, connecting the syntactic notion of provability depth to the semantic notion of proof-theoretic strength. It would also show that each level of the depth hierarchy adds precisely one \"iteration of consistency\" \u2014 making the informal intuition rigorous.\n\n**Catalog References**: `Bridges/ReflectiveTypeTheory.lean` (strict_modal_hierarchy, iterated_box_depth, l\u00f6b_depth_irreducibility)\n\n**Proof Strategy**: Start by formalizing ordinal notations up to \u03b5\u2080 \u00b7 \u03c9 (which should be available in Mathlib). Define the consistency statement Con_n for each depth level. The key lemma is that \u25a1\u207f\u22a5 \u2192 \u22a5 is provable in the depth-(n+1) fragment but not in the depth-n fragment, which would give the ordinal increment. Use the L\u00f6b depth irreducibility theorem as a starting point.\n\n**Domain Bridges**: Proof Theory <-> Ordinal Analysis <-> Reflective Type Theory\n\n**Lineage**: Extends the depth hierarchy results (iterated_box_depth, strict_modal_hierarchy) from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Categorical Semantics via Graded Monads\n\n**Conjecture**: The depth-stratified types of ReflTT form a graded monad (indexed by \u2115) on the category of types, where the grading monoid is (\u2115, max, 0). The Proof Depth Algebra's combine operation is the coherence map for this monad, and the \u25a1 operator is the unit at grade 1.\n\n**Test**: Define a category C whose objects are ReflTy types and whose morphisms are derivable typing judgments. Show that the assignment A \u21a6 \u25a1A extends to a functor \u25a1 : C \u2192 C and that the depth grading satisfies the monad laws: (i) \u25a1(\u25a1A) at depth n+m factoring through \u25a1A at depth n, (ii) unit \u03b7 : A \u2192 \u25a1A natural in A, (iii) multiplication \u03bc : \u25a1\u25a1A \u2192 \u25a1A satisfying associativity.\n\n**Impact**: If this works, it would provide a denotational semantics for ReflTT in terms of well-understood categorical structures, enabling the import of results from monad theory (Eilenberg-Moore algebras, Kleisli categories) into provability reasoning. The graded structure would make the depth hierarchy a first-class categorical concept.\n\n**Catalog References**: `Bridges/ReflectiveTypeTheoryDefs.lean` (ProofDepthAlgebra, combine, applyBox), `Bridges/ReflectiveTypeTheory.lean` (depth_algebra_level_eq_provDepth)\n\n**Proof Strategy**: Use Mathlib's category theory library. Define the category of ReflTy types with typing derivations as morphisms. The key challenge is showing that \u25a1 is functorial \u2014 this requires the K axiom (\u25a1(A\u2192B) \u2192 \u25a1A \u2192 \u25a1B) to define the action on morphisms. The monad multiplication comes from the collapsing \u25a1\u25a1A \u2192 \u25a1A, which is the semantics of the T axiom; note that not all models validate T, so this may require restricting to reflexive Kripke frames.\n\n**Domain Bridges**: Category Theory <-> Modal Logic <-> Type Theory <-> Algebra\n\n**Lineage**: Extends the Proof Depth Algebra concept introduced in this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical Provability Depth\n\n**Conjecture**: The provability depth function d : ReflTy \u2192 \u2115 is a tropical (min-plus or max-plus) semiring valuation on the type algebra, and the depth-filtration of ReflTT corresponds to a tropical variety in the type space.\n\n**Test**: Show that (ReflTy, max-depth, add-depth) under product and coproduct satisfies tropical semiring axioms. Specifically: d(A \u00d7 B) = max(d(A), d(B)) (already proved as depth_max_homomorphism) plays the role of tropical addition, and if we define d(A \u2192 B) = max(d(A), d(B)) as tropical multiplication, verify the distributive law d(A \u2192 (B \u00d7 C)) = max(d(A \u2192 B), d(A \u2192 C)) in the tropical sense.\n\n**Impact**: If provability depth is a tropical valuation, then tropical geometry techniques (Newton polytopes, tropical curves) could be applied to study the structure of the type space. This would be a genuinely novel connection between logic and algebraic geometry, potentially enabling the use of the Catalog's tropical geometry infrastructure for logical purposes.\n\n**Catalog References**: `Tropical/` (various files in the Catalog), `Bridges/ReflectiveTypeTheory.lean` (depth_max_homomorphism, depth_arrow_max), `Cryptography/TropicalMinPlusEncryption.lean`\n\n**Proof Strategy**: Formalize the tropical semiring structure on \u2115 \u222a {-\u221e} using Mathlib's `Tropical` type. Show that the depth function factors through the tropical semiring. The main challenge is identifying the correct tropical structure \u2014 the depth function uses max for binary constructors and successor for \u25a1, which doesn't immediately fit the standard tropical framework. A modification using the \"extended tropical semiring\" with a successor operation may be needed.\n\n**Domain Bridges**: Tropical Geometry <-> Provability Logic <-> Algebraic Geometry <-> Cryptography\n\n**Lineage**: Connects the depth hierarchy from this cycle to the Catalog's tropical geometry work.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Modal Mu-Calculus Model Checking via ReflTT\n\n**Conjecture**: The bijection between ReflTT and the modal mu-calculus can be exploited to give a type-theoretic proof of the EXPTIME-completeness of the modal mu-calculus model checking problem, by reducing it to type inhabitation in ReflTT.\n\n**Test**: Define a notion of \"type inhabitation\" for ReflTT: given a Kripke model M, a world w, and a type A, decide whether `w \u22a8 A`. Show that this problem is equivalent to the standard model checking problem for the modal mu-calculus via the translation bijection. Then establish EXPTIME-hardness by encoding an EXPTIME-complete problem (e.g., the succinct graph accessibility problem) as a type inhabitation instance.\n\n**Impact**: This would provide a type-theoretic perspective on the complexity of model checking, potentially enabling new algorithmic approaches that exploit the structure of types (e.g., type-driven search, proof-relevant model checking). It would also demonstrate a practical application of the ReflTT framework beyond pure foundations.\n\n**Catalog References**: `Bridges/ReflectiveTypeTheory.lean` (translation_bijective, kripke_box_monotone), `Computation/` (various complexity-theoretic results)\n\n**Proof Strategy**: The key observation is that the Kripke satisfaction relation kripkeSat' mirrors the model checking algorithm for the mu-calculus. Formalize the polynomial-time reduction from mu-calculus model checking to ReflTT type checking using the translation. For EXPTIME-hardness, use the known result that alternating PSPACE = EXPTIME and encode alternating Turing machine acceptance as a mu-calculus formula / ReflTT type.\n\n**Domain Bridges**: Computational Complexity <-> Model Checking <-> Type Theory <-> Provability Logic\n\n**Lineage**: Extends the translation bijection and Kripke semantics from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "bc59d5da",
    "consumed_by_exp_id": "892c306f",
    "timestamp": "2026-06-01T13:41:18.168687+00:00"
  },
  {
    "id": "fd_0147",
    "title": "**Discriminant Uniformity Theorem** for quad",
    "description": "# Future Directions: Stochastic Galois Theory\n\n## Synthesis\n\nThis research cycle established the **Discriminant Uniformity Theorem** for quadratic polynomials over finite fields: the map (b, c) \u21a6 b\u00b2 \u2212 4c from \ud835\udd3d_p\u00b2 to \ud835\udd3d_p has every fiber of cardinality exactly p. This seemingly simple result has deep consequences: it gives the exact distribution of quadratic discriminants, the separability density (1 \u2212 1/p), and the irreducibility fraction ((p\u22121)/(2p) \u2192 1/2). Crucially, we corrected a false conjecture: over finite fields, the Galois group of a random polynomial is **never** the full symmetric group S\u2099 for n \u2265 3 (since all Galois groups over finite fields are cyclic). The correct analog of Hilbert's irreducibility theorem involves the splitting type (a partition recording irreducible factor degrees), which connects to permutation cycle types via the Frobenius correspondence.\n\nThe most promising cross-domain connection is between the **splitting type distribution** (algebra) and **random permutation statistics** (combinatorics/probability). The Frobenius correspondence \u2014 splitting types of polynomials over \ud835\udd3d_q mirror cycle types of random permutations \u2014 is a gateway to the Katz-Sarnak philosophy connecting function field arithmetic to random matrix theory. Formalizing this correspondence would bridge the Algebra, Computation, and EML catalog domains. The highest breakthrough potential lies in Direction 1 (formalizing the Frobenius correspondence for degree 3) because it would be the first machine-verified instance of the polynomial-to-permutation dictionary.\n\nA secondary insight is that the \"uniformity\" of the discriminant map generalizes: any affine-linear polynomial map \ud835\udd3d_p^n \u2192 \ud835\udd3d_p has exactly equal fibers. This structural principle (Direction 3) connects to coding theory and the Lang-Weil theorem, opening a path to formalizing fiber-counting results for arbitrary polynomial maps over finite fields.\n\n---\n\n### Direction 1: Cubic Splitting Type Distribution Over Finite Fields\n\n**Conjecture**: For monic cubics x\u00b3 + ax\u00b2 + bx + c over \ud835\udd3d_p, the number of polynomials with each splitting type satisfies:\n- Type [3] (irreducible): exactly (p\u00b3 \u2212 p)/3\n- Type [2,1] (one linear, one quadratic factor): exactly p(p\u00b2 \u2212 1)/2\n- Type [1,1,1] (fully split): exactly (p\u00b3 + 2p)/6 for p \u2261 1 mod 6, with similar but distinct formulas for other residues\n\nThese counts should sum to p\u00b3 (the total number of monic cubics) and converge to the S\u2099 cycle-type probabilities (1/3, 1/2, 1/6) as p \u2192 \u221e.\n\n**Test**: Enumerate all p\u00b3 monic cubics over \ud835\udd3d_p for p = 5, 7, 11, 13. Compute the splitting type of each using distinct-degree factorization. Verify the counts match the formula. Specifically, verify that the irreducible count equals (p\u00b3 \u2212 p)/3 (this is known by the necklace formula, but the other counts need verification).\n\n**Impact**: This would be the first formalized proof connecting polynomial factorization statistics to permutation cycle-type statistics. It opens the door to formalizing the Frobenius density theorem and the Chebotarev density theorem in the function field setting.\n\n**Catalog References**: `Geometry/StochasticGalois.lean` (SplittingType definition, discriminant uniformity), `Algebra/Basic.lean`\n\n**Proof Strategy**:\n1. Formalize the distinct-degree factorization of polynomials over finite fields.\n2. Count polynomials of each splitting type using inclusion-exclusion: type [1,1,1] = polynomials with 3 roots in \ud835\udd3d_p; type [2,1] = polynomials with exactly one root; type [3] = irreducible.\n3. For the irreducible count, use the M\u00f6bius inversion formula: I(3,p) = (1/3)(p\u00b3 \u2212 p).\n4. Key lemma: the number of monic cubics with at least one root in \ud835\udd3d_p, counted with multiplicity, is p \u00b7 p\u00b2 = p\u00b3, but distinct-root counting requires inclusion-exclusion.\n\n**Domain Bridges**: Algebra (polynomial factorization) <-> Combinatorics (permutation cycle types) <-> Number Theory (Chebotarev density)\n\n**Lineage**: Builds on this cycle's SplittingType definition, discFiber_card_eq, and the Frobenius correspondence discussion.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Discriminant Uniformity for General Affine Polynomial Maps\n\n**Conjecture**: Let F: \ud835\udd3d_p^n \u2192 \ud835\udd3d_p be a polynomial map of the form F(x\u2081, ..., x\u2099) = g(x\u2081, ..., x\u2099\u208b\u2081) \u2212 \u03b1 \u00b7 x\u2099 where \u03b1 \u2208 \ud835\udd3d_p* is a unit and g is any polynomial. Then every fiber of F has cardinality p^{n-1}. More generally, if F is a polynomial map and F is a \"fibration\" (surjective with geometrically irreducible generic fiber), then |F\u207b\u00b9(d)| = p^{n-1} + O(p^{(n-1)/2}) by the Lang-Weil theorem, but the exact equality |F\u207b\u00b9(d)| = p^{n-1} holds if and only if F is affine-linear in at least one variable.\n\n**Test**: For n = 3, define F(a, b, c) = a\u00b2b\u00b2 \u2212 4b\u00b3 \u2212 4a\u00b3c + 18abc \u2212 27c\u00b2 (the cubic discriminant). Compute fiber sizes for p = 5, 7, 11. Verify they are NOT all equal (since the cubic discriminant is nonlinear in every variable), but satisfy |F\u207b\u00b9(d)| = p\u00b2 + O(p) by Lang-Weil.\n\n**Impact**: A formal characterization of when polynomial maps have exactly uniform fibers would unify discriminant analysis across all degrees and provide a clean criterion for when exact counting (as opposed to asymptotic) is possible.\n\n**Catalog References**: `Geometry/StochasticGalois.lean` (discFiber_card_eq proves the n=2 case)\n\n**Proof Strategy**:\n1. Prove the \"affine-linear implies uniform fibers\" direction: if F(x\u2081,...,x\u2099) = g(x\u2081,...,x\u2099\u208b\u2081) + \u03b1x\u2099 with \u03b1 a unit, then for each choice of (x\u2081,...,x\u2099\u208b\u2081), there is exactly one x\u2099 satisfying F = d.\n2. For the converse, find a counterexample: a map that is not affine-linear in any variable but has uniform fibers.\n3. Investigate the Lang-Weil error term for specific discriminant maps.\n\n**Domain Bridges**: Algebra (polynomial maps) <-> Geometry (algebraic varieties, fiber dimension) <-> Coding Theory (weight distributions)\n\n**Lineage**: Direct generalization of this cycle's discriminant uniformity theorem.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Squarefree Density and Polynomial Sieving\n\n**Conjecture**: The fraction of monic degree-n polynomials over \ud835\udd3d_q that are squarefree is exactly 1 \u2212 1/q for all n \u2265 2 and all prime powers q. Moreover, this can be proved by a \"polynomial sieve\" analogous to the integer sieve: a monic polynomial f is not squarefree iff it is divisible by g\u00b2 for some irreducible g of degree d \u2264 n/2, and inclusion-exclusion gives the exact count.\n\n**Test**: Enumerate monic polynomials of degrees 2, 3, 4 over \ud835\udd3d_p for p = 2, 3, 5, 7 and count squarefree ones. Verify the fraction equals 1 \u2212 1/p in all cases.\n\n**Impact**: The squarefree density theorem is foundational for analytic number theory in function fields. A formal proof would connect to sieve theory and the function field Riemann hypothesis. The result is classical but not yet formalized.\n\n**Catalog References**: `Geometry/StochasticGalois.lean` (separable_quadratic_card proves the n=2 case for separability, which equals squarefreeness for polynomials)\n\n**Proof Strategy**:\n1. Define squarefree polynomials in Lean: `Squarefree f \u2194 \u2200 g, g^2 \u2223 f \u2192 IsUnit g`.\n2. Key lemma: f is squarefree iff gcd(f, f') = 1 (where f' is the formal derivative).\n3. Count: the map f \u21a6 gcd(f, f') from degree-n monics to lower-degree polynomials. The non-squarefree polynomials are those where gcd(f, f') has degree \u2265 1.\n4. The derivative map f \u21a6 f' on monic degree-n polynomials is a specific linear map; analyze its kernel and image to get exact counts.\n\n**Domain Bridges**: Algebra (polynomial GCD) <-> Number Theory (sieve methods) <-> Computation (GCD algorithms)\n\n**Lineage**: Extends this cycle's separability analysis from n=2 to arbitrary degree.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Random Polynomial Galois Groups Over Function Fields\n\n**Conjecture**: Over the rational function field \ud835\udd3d_p(t), random monic polynomials of degree n (with coefficients that are polynomials in t of bounded degree D) have Galois group S\u2099 with probability approaching 1 as D \u2192 \u221e (for fixed p and n). This is the function field analog of Hilbert's irreducibility theorem, and unlike the finite field case, the full symmetric group CAN arise because \ud835\udd3d_p(t) has non-cyclic extensions.\n\n**Test**: For n = 3, p = 5, D = 2, enumerate monic cubics in \ud835\udd3d_5(t)[x] with coefficients of degree \u2264 2 and compute Galois groups over \ud835\udd3d_5(t). Verify that the fraction with Gal = S\u2083 is close to 1.\n\n**Impact**: This would establish the correct setting for \"generic Galois groups\" over finite-characteristic fields, resolving the tension between Hilbert's theorem (Gal = S\u2099 is generic over Q) and the cyclic constraint (Gal is always cyclic over \ud835\udd3d_p). Function fields are the natural intermediate case.\n\n**Catalog References**: `Geometry/StochasticGalois.lean` (SplittingType, corrected conjecture discussion)\n\n**Proof Strategy**:\n1. Use the geometric formulation: a polynomial f(x) \u2208 \ud835\udd3d_p(t)[x] defines a cover of P\u00b9 over \ud835\udd3d_p. The Galois group is the monodromy group of this cover.\n2. By the Hilbert irreducibility theorem for function fields (a theorem of S. Lang), the set of specializations where the Galois group drops is a proper closed subset.\n3. Count lattice points in the complement to get the density.\n4. Key obstacle: formalizing covers of curves and monodromy groups.\n\n**Domain Bridges**: Algebra (Galois theory) <-> Geometry (algebraic curves, covers) <-> Number Theory (Hilbert irreducibility)\n\n**Lineage**: Addresses the fundamental limitation discovered in this cycle (cyclic Galois groups over finite fields) by moving to the correct setting (function fields).\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Computational Verification of Splitting Type Convergence Rates\n\n**Conjecture**: For degree-n monic polynomials over \ud835\udd3d_p, the deviation of the splitting type distribution from the random permutation distribution satisfies:\n$$\\left| P(\\text{type } \\lambda) - \\frac{|\\{\u03c3 \u2208 S_n : \\text{cycle type}(\u03c3) = \\lambda\\}|}{n!} \\right| = O(1/p)$$\nwith an explicit constant depending on n and \u03bb. More precisely, for the irreducible fraction:\n$$P(\\text{irreducible}) = \\frac{1}{n} - \\frac{1}{np} + O(1/p^2)$$\n\n**Test**: For n = 2, 3, 4, 5 and p = 5, 7, 11, 13, 17, 19, 23, 29, 31, compute the exact splitting type distribution by enumeration. Fit the leading correction term and verify it matches the predicted O(1/p) rate with the conjectured coefficient.\n\n**Impact**: Establishing the rate of convergence would quantify the Frobenius correspondence and connect to error terms in the Chebotarev density theorem. The explicit constants would have applications in cryptographic parameter selection (how large must p be for the \"random polynomial\" model to be accurate?).\n\n**Catalog References**: `Geometry/StochasticGalois.lean` (SplittingType, irreducibleCubicCount), `Computation/InfoEfficientAlgorithms.lean`\n\n**Proof Strategy**:\n1. For n = 2: the exact formula P(irred) = (p\u22121)/(2p) = 1/2 \u2212 1/(2p) gives the coefficient \u22121/2.\n2. For n = 3: compute I(3,p)/p\u00b3 = (p\u00b3\u2212p)/(3p\u00b3) = 1/3 \u2212 1/(3p\u00b2), which is O(1/p\u00b2), not O(1/p). This suggests the rate depends on n.\n3. General conjecture: P(irred) = 1/n \u2212 1/(np^{n-1}) + O(1/p^n), i.e., the convergence rate is O(1/p^{n-1}).\n4. Verify this refined conjecture computationally.\n\n**Domain Bridges**: Algebra (polynomial counting) <-> Probability (convergence rates) <-> Cryptography (parameter selection)\n\n**Lineage**: Quantitative refinement of the Frobenius correspondence from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "a1511534",
    "consumed_by_exp_id": "b12db4e8",
    "timestamp": "2026-06-01T13:41:55.130149+00:00"
  },
  {
    "id": "fd_0031",
    "title": "Hilbert's Hotel for Primes: An Infinite Hotel Where Every Guest Is Prime",
    "description": "Hilbert's Hotel has infinitely many rooms, each containing a prime number. Room n contains the n-th prime p_n. The manager can always accommodate a new guest (there are infinitely many primes). But what if the guests want to REARRANGE? Conjecture: For any permutation sigma of N, there exists a rearrangement of the primes q_1, q_2, ... such that the sequence of ratios q_n / p_n converges to 1. In other words, you can shuffle the primes almost arbitrarily and the room numbers barely change. More precisely, the set of permutations sigma for which p_{sigma(n)} / p_n has a limit is dense in the symmetric group (with the topology of pointwise convergence). But NOT every permutation works: the permutation that swaps all even-indexed primes with odd-indexed ones gives q_{2n}/p_{2n} = p_{2n-1}/p_{2n} which converges to 1 by the prime number theorem, but the permutation that reverses order gives q_n/p_n = p_{N-n}/p_n which diverges. Test: compute q_n/p_n for 10 random permutations of the first 10^6 primes and verify that most ratios converge to 1. Find the exact density of 'well-behaved' permutations. Impact: the primes are robust under rearrangement \u2014 their asymptotic density is a topological invariant of the permutation group.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.74,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.528114+00:00"
  },
  {
    "id": "fd_0066",
    "title": "The Thermodynamics of Sorting: Entropy and Computational Work",
    "description": "Sorting a list of n elements reduces the entropy from log(n!) bits to 0 bits, doing thermodynamic work W = kT * log(n!) in the process. But this is only true if sorting is irreversible \u2014 if the sorted list uniquely determines the input, then sorting is reversible and does no thermodynamic work. The key insight: comparison-based sorting makes irreversible comparisons (you learn a < b but discard the possibility a > b), and each comparison reduces entropy by at most 1 bit. So n*log(n) comparisons reduce entropy by at most n*log(n) bits, which matches log(n!) ~ n*log(n) bits. Conjecture: the minimum thermodynamic work of sorting n elements is W_min = kT * log(n!), and this work is achieved by optimal comparison-based sorting algorithms (merge sort, heapsort). Sub-optimal algorithms (bubble sort: n^2 comparisons) do more thermodynamic work than necessary: W_bubble = kT * n^2, wasting kT * (n^2 - n*log(n)) bits of entropy reduction. Conjecture: any sorting algorithm that makes C(n) comparisons does thermodynamic work proportional to C(n) * kT, and the optimal work is W_min = kT * n*log(n) (Stirling's approximation). Test: simulate sorting algorithms with entropy bookkeeping, verify W = kT * log(n!) for merge sort and W = kT * n^2 for bubble sort. Impact: sorting is a thermodynamic process. The n*log(n) lower bound is a consequence of the second law of thermodynamics.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.74,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.662659+00:00"
  },
  {
    "id": "fd_0084",
    "title": "Diophantine Approximation on Neural Networks: How Well Can ReLU Approximate Pi?",
    "description": "A ReLU network f: R -> R with L layers of width w is a piecewise linear function with at most w^L pieces. By the universal approximation theorem, such networks can approximate any continuous function. But HOW WELL can they approximate specific constants? Conjecture: a ReLU network with L layers of width w can approximate pi to within epsilon using O(w * L * log(1/epsilon)) parameters. More precisely, there exists a ReLU network f with L = O(log(log(1/epsilon))) layers and w = O(log(1/epsilon)) width such that |f(1) - pi| < epsilon. This is because pi can be computed by the Leibniz formula pi/4 = 1 - 1/3 + 1/5 - ..., and a ReLU network can implement the partial sums. The number of terms needed is O(1/epsilon), and each term can be computed by a constant-depth ReLU subnetwork. The depth needed is O(log(1/epsilon)) for the sum and O(log(log(1/epsilon))) for the individual terms. Conjecture: the approximation rate for rational numbers by ReLU networks is O(1/(w^L)), matching the piecewise linear structure. For irrational numbers like pi, the rate is O(1/(w * L * 2^L)), which is slower but still exponential in depth. Test: construct ReLU networks that approximate pi, e, and sqrt(2) and measure the approximation error as a function of network size. Impact: ReLU networks approximate constants at a rate determined by their depth and width. Pi requires O(log(log(1/epsilon))) depth.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.74,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.755927+00:00"
  },
  {
    "id": "fd_0007",
    "title": "The Anti-Fibonacci Sequence: Numbers That Avoid the Golden Ratio at All Costs",
    "description": "The Fibonacci sequence is defined by F(n+1) = F(n) + F(n-1) and converges to the golden ratio. Define the ANTI-Fibonacci sequence: A(n+1) is the smallest positive integer that is NOT equal to A(n) + A(n-1). The sequence begins 1, 1, 2, 4, 7, 11, 16, ... (each term avoids being the sum of the two previous terms). Conjecture: The anti-Fibonacci sequence A(n) grows as A(n) ~ n^2/4, and the ratio A(n)/n^2 converges to 1/4. More precisely, A(n) = floor(n^2/4) + O(1). The sequence avoids the golden ratio entirely \u2014 the ratio A(n+1)/A(n) does NOT converge, instead oscillating between 1 and 2. The complement of the anti-Fibonacci sequence (numbers that ARE sums of two previous anti-Fibonacci numbers) has density 0. Test: compute A(n) for n up to 10^6 and verify A(n)/n^2 approaches 1/4. Prove A(n) = floor(n^2/4) + O(1) by induction. Impact: a beautiful counterpoint to the Fibonacci sequence \u2014 instead of converging to a constant, it grows quadratically while systematically avoiding addition.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.492042+00:00"
  },
  {
    "id": "fd_0044",
    "title": "Erdos-Renyi on Acid: Random Graphs That Hallucinate",
    "description": "The Erdos-Renyi random graph G(n, p) has n vertices where each edge appears independently with probability p. At p = log(n)/n, G(n,p) becomes connected. But what if p is COMPLEX? Define G(n, z) where z is a complex number: each edge (i,j) appears with 'probability' z, meaning the edge weight is z instead of 0 or 1. The resulting 'complex graph' is a weighted complete graph where edge (i,j) has weight z if the edge exists and 0 otherwise. The adjacency matrix A_z has entries that are either z or 0. Conjecture: The complex eigenvalues of A_z trace out a circle of radius |z|*sqrt(n) in the complex plane, centered at the origin. As n -> infinity, the empirical spectral distribution of A_z converges to the circular law (like the Ginibre ensemble) because A_z is a random matrix with i.i.d. entries of mean z*p and variance |z|^2*p*(1-p). The 'hallucination' is that for Im(z) != 0, the graph has complex-valued connectivity \u2014 information flows with both amplitude and phase, and the phase creates interference patterns that are visible in the spectral density. Test: generate A_z for n = 1000 with z = 0.5 + 0.3i, compute eigenvalues, and verify they lie in a disk of radius sqrt(n)*|z|. Compare with the Ginibre ensemble prediction. Impact: complex-valued random graphs have circular spectra \u2014 the hallucination of complex probabilities creates beautiful circular eigenvalue distributions.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.567597+00:00"
  },
  {
    "id": "fd_0078",
    "title": "Categorification of Entropy: The Information Loss of Functors",
    "description": "Entropy H(X) = -sum p(x) log p(x) measures the information content of a random variable. In category theory, a functor F: C -> D 'loses information' when it maps non-isomorphic objects to isomorphic ones. Define the 'functorial entropy' H(F) as the expected information lost by F: H(F) = -sum_{d in Ob(D)} p(d) * log(p(d)) where p(d) = |F^{-1}(d)| / |Ob(C)|. Conjecture: For the forgetful functor U: Top -> Set that forgets the topology, H(U) = log(2^{aleph_0}) = aleph_0 (infinite entropy, because uncountably many topologies map to the same set). For the abelianization functor Ab: Grp -> AbGrp, H(Ab) = log(2) (each abelian group has 2 non-abelian preimages on average: G and G x Z/2Z). For the inclusion functor Inc: FinGrp -> Grp, H(Inc) = 0 (no information loss, since finite groups embed as themselves). Conjecture: H(F) = 0 iff F is faithful, and H(F) = infinity iff F identifies infinitely many non-isomorphic objects. For finite categories: H(F) = log(|Ob(C)| / |Ob(D)|) when F is 'uniform' (each fiber has the same size). Test: compute H(F) for various functors between finite categories and verify the formula. Impact: entropy is not just a measure-theoretic concept \u2014 it is the information-theoretic shadow of functoriality. Every functor loses information, and the entropy measures how much.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.722495+00:00"
  },
  {
    "id": "fd_0090",
    "title": "The Uncanny Valley of Mathematics: When Proofs Are Almost Right",
    "description": "The 'uncanny valley' in robotics states that as a robot becomes more human-like, acceptance increases until it looks almost human, then drops sharply before recovering. Conjecture: the same phenomenon exists in mathematics. As a proof becomes more rigorous, acceptance increases until it is 'almost rigorous' (a proof that is correct in spirit but has small gaps), then drops sharply (because mathematicians are suspicious of proofs that look correct but might have subtle errors), before recovering for fully rigorous proofs. The 'mathematical uncanny valley' function U(r) where r in [0,1] is the rigor level: U(0) = high (informal intuition is accepted), U(0.8) = low (almost rigorous but with gaps \u2014 very suspicious), U(1.0) = high (fully rigorous proof, formally verified). Conjecture: U(r) has a unique minimum at r = 1 - epsilon where epsilon is the 'gap size' that triggers the most suspicion. For Lean 4 proofs: U(1) = 1 (compiles), U(0.99) = 0.1 (almost compiles but has a 'sorry'), U(0.5) = 0.5 (sketch proof, accepted as intuition). Test: survey 100 mathematicians on their confidence in proofs at varying rigor levels and fit the uncanny valley curve. Impact: almost-right proofs are less trusted than informal intuitions. Formal verification escapes the uncanny valley.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.795915+00:00"
  },
  {
    "id": "fd_0092",
    "title": "Sheaf-Theoretic Data Integration: When Databases Form a Sheaf",
    "description": "A database with missing entries is a partial section of a sheaf. The sheaf condition (gluing) says that if two partial sections agree on their overlap, they can be glued into a global section. Conjecture: the probability that a random database with missing rate r satisfies the sheaf condition (i.e., can be consistently filled in) is P(sheaf) = (1-r)^{C(n,k)} where n is the number of columns, k is the number of rows, and C(n,k) is the number of overlapping constraints. This means: for a database with n columns and k rows, the probability of consistent imputation drops exponentially with the number of overlapping constraints. The sheaf imputation method: fill in missing values by finding the closest global section of the data sheaf. This is equivalent to solving a constrained optimization problem where the constraints are the sheaf condition on every overlapping pair of feature subsets. Conjecture: sheaf imputation outperforms mean imputation and KNN imputation when the missing rate r < 0.5 and the number of features n > 10, because the sheaf condition provides exponentially many consistency constraints that other methods ignore. Test: generate synthetic databases with known ground truth, introduce missing values at rate r, compare sheaf imputation with mean, KNN, and MICE. Impact: data imputation is a sheaf cohomology problem. The sheaf condition is the natural consistency constraint for databases.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.807837+00:00"
  },
  {
    "id": "fd_0014",
    "title": "The Sound of Pi: Musical Structure in Transcendental Constants",
    "description": "Every real number defines a musical scale: map the digits 0-9 to frequencies f_n = 220 * 2^{n/12} (the A minor pentatonic scale extended). The number pi = 3.14159265... produces the sequence E4, C5, C#5, D5, D#5, F5, E5, A4, G5, C5... \u2014 a melody. Conjecture: The melody of pi is not periodic (because pi is irrational) but has musical structure: the autocorrelation of the digit sequence at lag 12 (one octave) is positive and statistically significant. This means pi has more octave-related notes than expected by chance \u2014 pi 'favors' notes separated by octaves. Similarly, e 'favors' perfect fifths (lag 7) and sqrt(2) 'favors' minor thirds (lag 3). The musical structure of transcendental numbers reflects their continued fraction properties: numbers with bounded partial quotients have more consonant melodies. Test: compute the digit autocorrelation of pi, e, and sqrt(2) at lags 0-12 (representing unison through octave). Perform a chi-squared test comparing to the uniform distribution. Generate the 'music' of each constant and analyze for tonal centers. Impact: transcendental numbers have musical souls \u2014 their digit sequences contain hidden harmonies that reflect their deepest arithmetic properties.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.497427+00:00"
  },
  {
    "id": "fd_0051",
    "title": "Bayesian Werewolf: Optimal Strategy for Social Deduction Games",
    "description": "In the game Werewolf (Mafia), n players include k werewolves and n-k villagers. Each night, the werewolves eliminate one villager. Each day, the villagers vote to eliminate one player (possibly a werewolf). The villagers win if all werewolves are eliminated; the werewolves win if they equal or outnumber villagers. Conjecture: The optimal Bayesian strategy for villagers is to vote for the player with the highest posterior probability of being a werewolf, where the prior is k/n and the likelihood updates are based on the player's voting pattern and survival. More precisely, define the werewolf posterior P(W_i | evidence) using Bayes' theorem: P(W_i) = k/n (prior), P(evidence | W_i) = product of conditional probabilities of observed events given that player i is a werewolf. The optimal strategy maximizes P(villagers win) = P(correct elimination at each day round). For n=7, k=2: the villagers' win probability with optimal Bayesian play is approximately 0.36 (known from game theory). Conjecture: For general n and k, the villagers' win probability is approximately C * (1 - k/(n-k))^2 where C is a constant depending on the information structure. Test: simulate 10^6 games with n=7 to n=20 players and Bayesian villagers, measure the win probability, and fit to the conjectured formula. Impact: social deduction has an optimal Bayesian strategy, and the werewolves' advantage scales as (k/(n-k))^2.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.593085+00:00"
  },
  {
    "id": "fd_0059",
    "title": "The Category Theory of Jokes: Universal Properties of Humor",
    "description": "Category theory studies objects and morphisms between them. A joke has a setup (an object) and a punchline (a morphism that subverts expectations). Define the category Joke where objects are setups and morphisms are punchlines. A joke J: S -> P is a morphism from setup S to punchline P that factors through an unexpected category. The humor of a joke is measured by its 'surprise': the distance between the expected punchline (the limit of the setup category) and the actual punchline. Conjecture: The funniest jokes are those where the setup category has a colimit that is far from the limit. Formally, if S is a setup with expected resolution lim(S) and the actual punchline P is a colimit colim(S'), then the humor H(J) = d(lim(S), colim(S')), where d is a metric on the category of punchlines. Puns have H close to 0 (the punchline is near the expected resolution). Absurdist humor has H large (the punchline is in a completely different category). The universal property of jokes: a joke J is universal if for any other joke J' with the same setup, there is a unique natural transformation J => J'. The funniest jokes are universal \u2014 they are the terminal objects in the category of jokes with a given setup. Test: formalize 100 jokes as category-theoretic objects and compute H(J) for each. Correlate with human funniness ratings. Impact: humor is a colimit. The funnier the joke, the further the punchline is from the expected limit of the setup.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.626049+00:00"
  },
  {
    "id": "fd_0087",
    "title": "The Combinatorics of Compiler Optimization: Register Allocation as Graph Coloring",
    "description": "Register allocation in a compiler assigns variables to CPU registers. The interference graph G has variables as vertices and edges between variables that are 'live' at the same time. Register allocation is equivalent to coloring G with k colors (k = number of registers). Conjecture: for SSA-form programs with n variables and maximum interference degree delta, the chromatic number chi(G) satisfies chi(G) = max(delta + 1, omega(G)) where omega(G) is the clique number. This is stronger than Brooks' theorem (which gives chi(G) <= delta + 1) because it predicts that chi(G) = delta + 1 ONLY when G contains a (delta+1)-clique. For typical programs: delta <= 5 and omega(G) <= 4, so chi(G) = delta + 1 <= 6. Conjecture: the optimal number of registers for SSA programs is at most delta + 1, and spill code (storing variables in memory instead of registers) is needed only when k < delta + 1. Moreover, the spill cost is minimized by spilling the vertex with maximum degree in the interference graph (a heuristic known as 'degree-based spilling'). Test: extract interference graphs from 100 real programs, compute chi(G) and delta, and verify chi(G) = max(delta + 1, omega(G)). Impact: register allocation is graph coloring with a precise formula for the chromatic number.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.72,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "7894af63",
    "timestamp": "2026-06-01T12:30:30.775341+00:00"
  },
  {
    "id": "fd_0035",
    "title": "The P vs NP of Cooking: Computational Complexity of Recipes",
    "description": "Every recipe is an algorithm: it takes ingredients (inputs) and produces a dish (output). The question is: can you verify a good dish faster than you can cook it? This is exactly P vs NP, but in the kitchen. Define the verification time V(R) of a recipe R as the time it takes to taste the dish and determine if it's good. Define the cooking time C(R) as the time it takes to prepare the dish. Conjecture: For most traditional recipes, C(R) > V(R) \u2014 cooking takes longer than tasting (P != NP in the kitchen). But there exist 'quick recipes' where C(R) = V(R) \u2014 assemble-and-serve dishes like salads (P = NP in the kitchen). The interesting class is 'NP-hard recipes' \u2014 dishes where even VERifying the result is hard. Example: is the souffle risen? You can only verify by cutting it open, which destroys it. Theorem: souffle verification is co-NP-hard because determining if a souffle will rise requires simulating the thermodynamic process, which is PSPACE-hard. More formally: the souffle function S(ingredients, temperature, time) -> {risen, collapsed} requires computing the Navier-Stokes equations for the batter, which is PSPACE-hard. Test: classify 100 recipes by their C(R)/V(R) ratio. Verify that P = NP recipes have C = V, while P != NP recipes have C >> V. Impact: computational complexity is not abstract \u2014 it shows up in your kitchen. Some dishes are inherently harder to make than to verify.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.71,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.539249+00:00"
  },
  {
    "id": "fd_0077",
    "title": "The Ramsey Theory of DNA: Subsequence Avoidance in Genetic Codes",
    "description": "Ramsey's theorem states that any 2-coloring of the edges of K_6 contains a monochromatic K_3 (a triangle of one color). Applied to DNA: any sequence of 4^6 + 1 = 4097 nucleotides must contain a repeated 6-mer (by pigeonhole). But Ramsey theory for subsequences is more subtle: what is the minimum length L(k) of a DNA sequence over {A, C, G, T} such that every subsequence of length k contains a repeated 4-mer? Conjecture: L(k) = Theta(k * 4^4 * log(4^4)) = Theta(k * 256 * 8) = Theta(k * 2048). More precisely, by the Lovasz local lemma, L(k) >= 4^{4k/5} for sequences that avoid repeated k-mers in all subsequences. Conjecture: for real genomes, the actual L(k) is much smaller because real DNA has low complexity regions (microsatellites, Alu repeats) that create forced repeats. Specifically, the human genome has L(4) ~ 1000 (any 1000 consecutive bases contain a repeated 4-mer in some subsequence), while the random genome has L(4) ~ 4^4 * log(4^4) ~ 5000. Test: compute L(k) for real genomes vs random genomes and verify the factor-of-5 compression. Impact: DNA avoids subsequential repeats in a way that Ramsey theory predicts, but real genomes are 5x more 'forced' than random sequences.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.71,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.717074+00:00"
  },
  {
    "id": "fd_0040",
    "title": "Ramanujan's Taxicab Number as a Sum of Three Cubes: 1729 Revisited",
    "description": "1729 = 10^3 + 9^3 = 12^3 + 1^3 is the smallest number expressible as a sum of two cubes in two ways (Ramanujan's taxicab number). But can 1729 be expressed as a sum of three cubes? That is, does 1729 = x^3 + y^3 + z^3 have integer solutions? Conjecture: 1729 = 1^3 + 10^3 + 8^3 = 1 + 1000 + 512 = 1513 (no). 1729 = 9^3 + 9^3 + 7^3 = 729 + 729 + 343 = 1801 (no). Actually, 1729 = 1^3 + 12^3 = 1728 + 1 = 1729 (the original). And 1729 = 10^3 + 9^3 = 1000 + 729 = 1729. So 1729 has TWO representations as a sum of two cubes. The question is: does 1729 have a representation as a sum of three cubes? The answer is YES: 1729 = 1^3 + (-12)^3 + 12^3 = 1 - 1728 + 1728 = 1 = NO, this gives 1, not 1729. Try 1729 = 10^3 + 9^3 + 0^3 = 1729. So 1729 = 10^3 + 9^3 + 0^3 is a trivial representation. The non-trivial question: does 1729 have a representation as x^3 + y^3 + z^3 with x,y,z all nonzero? Conjecture: 1729 has no non-trivial representation as a sum of three cubes with all terms nonzero. Test: brute-force search for x^3 + y^3 + z^3 = 1729 with x,y,z nonzero integers. Impact: even Ramanujan's favorite number has secrets \u2014 the taxicab number's relationship to sums of three cubes reveals new Diophantine structure.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.7,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.554513+00:00"
  },
  {
    "id": "fd_0093",
    "title": "The Geometry of Consensus: Arrow's Theorem as Curvature",
    "description": "Arrow's impossibility theorem states that no ranked voting system with 3+ alternatives can be Pareto efficient, non-dictatorial, and independent of irrelevant alternatives (IIA). Conjecture: Arrow's theorem is a curvature statement. The space of preference profiles is a Riemannian manifold M with the Fisher information metric. The social welfare function F: M -> M is a mapping from profiles to social preferences. Arrow's conditions translate to geometric conditions: (1) Pareto efficiency means F preserves the direction of unanimous preference (F is 'forward-looking'). (2) IIA means F is a local mapping (the social preference at x depends only on local information near x). (3) Non-dictatorial means F is not a projection onto a single voter's preference. Conjecture: the only smooth, local, forward-looking maps on a positively curved manifold are projections (dictatorships). This is because a positively curved manifold has the property that parallel transport around a small loop rotates vectors (Holonomy), and a local, forward-looking map must preserve this holonomy, which forces it to be a projection. Conjecture: the curvature of the preference space is related to the 'polarization' of the electorate: when preferences are polarized (bimodal), the curvature is positive (sphere-like), and Arrow's theorem applies. When preferences are unimodal (consensus), the curvature is zero (flat), and majority rule works. Test: compute the curvature of the preference space for synthetic election data and verify the connection to Arrow's theorem. Impact: Arrow's impossibility is a theorem of differential geometry. Voting is curved.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.7,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.814374+00:00"
  },
  {
    "id": "fd_0140",
    "title": "Curvature-Induced Computation: When Geodesic Flow Simulates a Turing Machine",
    "description": "Conjecture: There exists a compact Riemannian manifold M of dimension <= 4 with explicitly constructible metric g such that the symbolic coding of its geodesic flow is computationally universal, in the precise sense that for every Turing machine T and input x, one can algorithmically produce a finite set of geodesic initial conditions and a finite observation partition P for which T halts on x if and only if some geodesic from that set enters a designated cell of P. Test: Confirm by constructing such an explicit manifold/metric pair and proving the bidirectional reduction, then numerically validating the encoding on benchmark universal machines; refute by proving that geodesic flows on all compact manifolds up to dimension 4 admit structural constraints preventing universal symbolic dynamics of this kind. Impact: This would turn curvature itself into a substrate for computation, linking differential geometry, dynamical systems, and computability, and could yield new geometric notions of complexity, physical analog models of computation, and fresh undecidability results in classical mechanics.",
    "domains": [
      "Differential Geometry",
      "Computability Theory"
    ],
    "priority_score": 0.7,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "7298cf4c",
    "timestamp": "2026-06-01T12:31:16.764056+00:00"
  },
  {
    "id": "fd_0054",
    "title": "Graph Coloring with Emotions: The Chromatic Polynomial Meets Psychology",
    "description": "The chromatic polynomial chi_G(k) counts the number of proper k-colorings of a graph G. For a friendship graph, chi_G(k) counts the number of ways to assign k emotions to people such that no two friends share the same emotion. Conjecture: The chromatic polynomial evaluated at k=6 (for the 6 basic emotions: happiness, sadness, anger, fear, disgust, surprise) gives the number of 'emotionally consistent' assignments of emotions to a social network. The chromatic polynomial has a root at k=2 for any bipartite graph, meaning a social network that splits cleanly into two groups has exactly 0 ways to assign 2 emotions without friends sharing emotions. The real emotional chromatic number chi_E(G) of a social network G is the smallest k such that chi_G(k) > 0 and k >= 3 (since real emotions need at least 3 categories to avoid trivial assignments). For a complete graph K_n (a clique of n mutual friends), chi_E(K_n) = n (everyone needs a different emotion). For a cycle C_n (a circular friendship chain), chi_E(C_n) = 2 if n is even and 3 if n is odd (alternating emotions work for even cycles, but odd cycles need a third emotion). Test: compute chi_E(G) for 100 real social networks and verify that the emotional chromatic number is between 3 and 6 for most networks. Impact: the chromatic polynomial is not just combinatorics \u2014 it measures the emotional diversity of a social network.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.69,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.604974+00:00"
  },
  {
    "id": "fd_0039",
    "title": "The Fundamental Theorem of Cakes: Algebraic Geometry of Baking",
    "description": "A cake is a smooth projective variety over R: it has a base (a smooth manifold with boundary), frosting (a sheaf of sections supported on the boundary), and layers (a stratification by codimension). The Fundamental Theorem of Cakes states: every cake C is uniquely determined (up to isomorphism of flavor) by its base B, its frosting sheaf F, and its layer stratification L. The frosting sheaf is a locally free sheaf of rank 1 (the cake has uniform frosting thickness) supported on the boundary of the base. The stratification is a flag of subvarieties C = L_0 > L_1 > ... > L_k = {point} where L_i has codimension i and represents the i-th layer. Conjecture: the moduli space of cakes of genus g (g = number of cherries on top) has dimension 3g-3 for g >= 2, mirroring the moduli space of Riemann surfaces. The cherry number g corresponds to the first Betti number of the cake surface, and the moduli are the positions of the g cherries on the surface. Test: enumerate all topologically distinct cakes with g <= 5 cherries and verify that the moduli space has dimension 3g-3. Compute the Teichmuller space of cakes by varying the cherry positions. Impact: cakes are algebraic varieties, and the mathematics of cake decoration IS the mathematics of moduli spaces.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.68,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.551386+00:00"
  },
  {
    "id": "fd_0070",
    "title": "Crystallographic Groups and Music: The 17 Wallpaper Groups of Rhythm",
    "description": "A periodic rhythm in music is a function f: Z -> {0, 1} that is periodic: f(n + p) = f(n) for some period p. The symmetry group of a rhythm with period p is a subgroup of Z/pZ. But music also has 2D patterns: a drum pattern is a function g: Z x Z -> {0, 1} (onset grid in time x pitch). The symmetry group of a drum pattern is a subgroup of Z x Z, which is a wallpaper group in 1D. In 2D, the wallpaper groups classify all possible symmetries of periodic patterns. There are exactly 17 wallpaper groups in 2D. Conjecture: the 17 wallpaper groups correspond to 17 fundamentally different types of rhythmic structure in music. Specifically: (1) p1: no symmetry (free rhythm), (2) p2: 2-fold rotational symmetry (call-and-response), (3) pm: mirror symmetry (palindrome), (4) pg: glide reflection (canon), (5) cm: mirror + glide (round), (6) pmm: double mirror (bilateral palindrome), (7) pmg: mirror + glide (inverted canon), (8) pgg: double glide (double canon), (9) cmm: double mirror + glide (round + palindrome), (10) p4: 4-fold rotation (4-bar cycle), (11) p4m: 4-fold + mirrors (variations on a theme), (12) p4g: 4-fold + glides (inverted variations), (13) p3: 3-fold rotation (3-bar blues), (14) p3m1: 3-fold + mirrors, (15) p31m: 3-fold + glides, (16) p6: 6-fold rotation (whole-tone scale symmetry), (17) p6m: 6-fold + mirrors (maximal symmetry, the 'perfect' rhythm). Test: classify 1000 drum patterns by their wallpaper group and verify the distribution matches musical practice. Impact: there are exactly 17 types of rhythm in music, classified by the wallpaper groups.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.68,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.681497+00:00"
  },
  {
    "id": "fd_0046",
    "title": "Homotopy Type Theory of Cooking Recipes: Paths Between Dishes",
    "description": "In homotopy type theory (HoTT), equal things can be equal in different ways \u2014 there can be multiple paths between two points. Apply this to cooking: two recipes can produce the same dish, but the paths (methods) may differ. The type of a dish is its flavor profile (a point in taste space R^n where n is the number of flavor dimensions). Two recipes are 'equal' if they produce the same flavor profile, but the path between them (the transformation from one recipe to another) may not be unique. Conjecture: The space of all recipes that produce a given flavor profile has the homotopy type of a CW-complex whose cells correspond to the possible ingredient substitutions. For example, the space of recipes that produce 'chocolate chip cookies' has the homotopy type of S^0 (two points: with nuts and without nuts), because the only binary choice is nuts/no-nuts. More complex dishes have higher homotopy groups: the space of recipes for 'curry' has pi_1 = Z (generated by the loop 'add more spice -> simmer -> add more coconut milk -> simmer -> add more spice'), representing the fundamental cycle of Indian cooking. Test: enumerate 100 recipes for chocolate chip cookies and compute the homotopy groups of the resulting simplicial complex. Impact: cooking is homotopy theory. Every dish is a point, every substitution is a path, and every cuisine is a homotopy type.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.66,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "e174af4c",
    "timestamp": "2026-06-01T12:30:30.574847+00:00"
  },
  {
    "id": "fd_0045",
    "title": "The Fermi Paradox as a Pigeonhole Principle: Why We Are Alone",
    "description": "The Fermi paradox asks: if intelligent life is common, where is everyone? The pigeonhole principle answers: if there are more pigeons than holes, at least one hole contains more than one pigeon. Apply this to the cosmos: there are approximately 10^22 stars in the observable universe (pigeons) and approximately 10^10 habitable-zone planets (holes). By the pigeonhole principle, at least one habitable planet contains at least 10^12 stars' worth of interest... wait, that's the wrong way around. Correct: there are ~10^10 habitable planets (pigeons) and ~4.5 billion years of time (holes). By the pigeonhole principle, at least one time period of one year contains at least 2 habitable planets developing intelligence. But we observe zero contacts. Conjecture: The resolution is that intelligent life is NOT common \u2014 the expected number of technological civilizations in the observable universe is less than 1. More precisely: if we model the Drake equation with honest probability estimates, P(technological civilization per habitable planet) < 10^{-10}, making the expected number of civilizations < 10^0 = 1. The Fermi paradox is not a paradox at all \u2014 it is the pigeonhole principle correctly predicting that with very few pigeons (civilizations) and very many holes (planets + time), most holes are empty. Test: compute the Drake equation with conservative estimates and verify that E[civilizations] < 1. Impact: we are alone because probability says so. The universe is mostly empty because that's what the math predicts.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.65,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.571054+00:00"
  }
];
