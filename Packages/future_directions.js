

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0005",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T01:50:23.541482+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0002",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T01:50:23.533499+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0003",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T01:50:23.539351+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0004",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T01:50:23.540765+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0006",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T01:50:23.542282+00:00",
    "title": "The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Equiangular lines at angle `arccos(1/3)` and beyond\n\nThis cycle established the linear-algebraic skeleton behind the `1/3`-angle case of\nBalla's conjecture: the sharp absolute bound `d(d+1)/2` on any equiangular system,\nthe Seidel-matrix reformulation `G = I + (1/3)S` with smallest eigenvalue at least\n`\u22123`, and the exact reduction of the line count to the multiplicity of the Seidel\neigenvalue `\u22123`. The following conjectures grow directly out of those findings.\n\n## 1. The multiplicity of `\u22123` is eventually linear, not quadratic\n\n**Conjecture.** For a symmetric `0/\u00b11` matrix `S` of order `m` (zero diagonal, `\u00b11`\noff-diagonal) whose smallest eigenvalue is exactly `\u22123`, the multiplicity of that\neigenvalue is at most `m \u2212 \u2308m/2\u2309 + 1` once `m` is large, and in the extremal regime\nthe number of `+1` off-diagonal entries per row is forced to concentrate.\n\nThe key insight is that the eigenvalue `\u22123` is an *integer* of small \"spectral\norder\" (its smallest realization is the two-point graph `K\u2082`), so the `\u22123`-eigenspace\ncannot be spanned by more than a bounded number of \"independent gadgets\" before the\n`\u00b11` structure is forced to repeat \u2014 turning a potentially quadratic multiplicity\ninto a linear one. Why now? The entire equiangular count is known to equal\n`d` plus this multiplicity, so a linear multiplicity bound is *equivalent* to the\n`2(d\u22121)` regime of the target; isolating the multiplicity as the sole unknown makes\nit a clean, self-contained extremal-spectral problem.\n\n## 2. A dichotomy phase transition at `d = 15`\n\n**Conjecture.** The maximum equiangular `1/3`-system in `\u211d^d` is governed by a sharp\nphase transition: for `d \u2264 15` the extremizers are *rigid* (all essentially\nequivalent to the unique `28`-line configuration in `\u211d^7` embedded in higher\ndimension), while for `d \u2265 15` the extremizers are *flexible* one-parameter families\nrealizing `2(d \u2212 1)` lines, and no configuration interpolates strictly between them.\n\nThe key insight is that `28 = C(8,2)` is an absolute (dimension-independent) ceiling\ncoming from the symmetric-tensor space, whereas `2(d \u2212 1)` is a dimension-driven\n\"pillar\" count; these two mechanisms have disjoint extremal geometries and must\ncross exactly where `2(d \u2212 1) = 28`. Why now? The absolute bound `m \u2264 d(d+1)/2` and\nthe linear reduction `m \u2264 d + \u03bc` are now both on the table simultaneously, so the\ncompetition between the constant and linear terms \u2014 and hence the crossover \u2014 can be\nstudied as a single optimization rather than two separate cases.\n\n## 3. Tensor-power bounds sharpen for every rational angle with small denominator\n\n**Conjecture.** For a common angle `arccos(1/q)` with `q` an odd integer, the\n`k`-fold symmetric tensor embedding yields the bound `N_{1/q}(d) \u2264 C(d + k \u2212 1, k)`\nfor the *smallest* `k` with `1/q^{2k}` below the relevant positivity threshold, and\nthis family of bounds is tight precisely when `q = 3` and `k = 1`.\n\nThe key insight is that raising vectors to the `k`-th symmetric tensor power replaces\nthe pairwise inner product `\u03b1` by `\u03b1^k`, so a single geometric constraint spawns an\nentire ladder of Gram-positivity bounds, of which the classical absolute bound is\nonly the first rung. Why now? The identity `\u27e8v\u2297v, w\u2297w\u27e9 = \u27e8v,w\u27e9\u00b2` is the\nexact reason the angle `\u03b1` becomes `\u03b1\u00b2`, and the same identity iterates verbatim to\n`\u27e8v^{\u2297k}, w^{\u2297k}\u27e9 = \u27e8v,w\u27e9^k`, making the higher-power bounds immediate to state and\ntest.\n\n## 4. The Seidel spectral gap controls the answer for all fixed angles\n\n**Conjecture.** For every fixed `\u03b1 = 1/(2r \u2212 1)` the maximum equiangular system in\n`\u211d^d` satisfies `N_\u03b1(d) = d \u2212 1 + \u03ba(d)` where `\u03ba(d)` is the largest multiplicity of\nthe smallest eigenvalue `\u2212(2r \u2212 1)` achievable by an order-`m` Seidel graph on `d`-\nrank Gram support, and `\u03ba(d)` grows linearly with slope determined solely by the\n\"spectral order\" `\u03ba\u2081` of the eigenvalue (which is `2` for `\u03b1 = 1/3`).\n\nThe key insight is that the ambient dimension enters *only* through the rank cap\n`rank(G) \u2264 d`; every other feature of the problem is a property of `\u00b11` symmetric\nmatrices with a prescribed integer smallest eigenvalue, so the answer factorizes as\n\"dimension term `+` spectral-multiplicity term.\" The rank inequality `rank(G) \u2264 d`\nalready yields the `d \u2212 1 + \u03ba` decomposition for `\u03b1 = 1/3`; the conjecture asserts\nthat this decomposition is not special to `1/3` but is the universal shape for all\nangles with integer inverse. Why now? With the dimension entering only through that\nsingle rank cap, the problem cleanly separates into a dimension term and a spectral-\nmultiplicity term, so the latter can be attacked in isolation for every fixed angle.\n\n## 5. A spectral certificate makes the `28` ceiling checkable\n\n**Conjecture.** There is a finite, dimension-independent certificate \u2014 a fixed list\nof forbidden principal submatrix patterns of size at most `8` \u2014 such that a `0/\u00b11`\nSeidel matrix has smallest eigenvalue `> \u22123` (equivalently supports more than\n`d(d+1)/2` incompatible lines) if and only if it avoids every pattern on the list.\n\nThe key insight is that the smallest eigenvalue being `\u2265 \u22123` is a *hereditary*\nspectral property (it passes to principal submatrices), and hereditary spectral\nthresholds for small integer eigenvalues are known to be characterizable by finite\nforbidden-subgraph families. Why now? With the equivalence \"line system \u2194 Seidel\nmatrix with smallest eigenvalue `\u2265 \u22123`\" made precise, the `28`-line ceiling becomes a\nfinite forbidden-pattern question, opening the door to an exhaustive, verifiable\nresolution of the boundary case.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0007",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "946cfca3",
    "status": "available",
    "timestamp": "2026-07-02T01:57:40.926155+00:00",
    "title": "Linear-algebraic skeleton behind the `1/3`-angle case"
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
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence Maximal number of \"good\" manifolds in an n-nice polytope. with terms 6,8,12,24,40,80,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,20971. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0001",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:212351",
    "status": "available",
    "timestamp": "2026-07-02T01:33:56.530529+00:00",
    "title": "OEIS sequence: Maximal number of \"good\" manifolds in an n-nice polytope."
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Quantum state topological phases exhibit non-Markovian dynamics (history-dependent evolution) under finite-time Hamiltonian evolution, enabling memory-efficient computation in topological quantum systems. Test: Prepare topological quantum states (e.g., via Anyon braiding in fractional quantum Hall systems) and measure whether post-evolution topological invariants depend on the exact evolution history (non-Markovian) or only the initial state (Markovian). Impact: Could enable new paradigms for quantum error correction and fault-tolerant computation by leveraging historical context in topological operations.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0008",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-07-02T01:59:48.218375+00:00",
    "title": "Non-Markovian Topological Quantum Computing"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle 946cfca3 (Q=0.557) proved 20 theorems in Applications but left 8 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: For all d \u2265 1, the maximum number of equiangular lines in \u211d^d with common angle arccos(1/3) satisfies N_{1/3}(d) \u2264 max{28, 2(d \u2212 1)}. This is a special case of Balla's conjecture where the spectral ra",
    "domains": [
      "Applications"
    ],
    "id": "sorry_fill_946cfca3_55488959",
    "priority_score": 0.6070000000000001,
    "research_mode": "team",
    "source_exp_id": "946cfca3",
    "status": "available",
    "timestamp": "2026-07-02T01:59:53.249917+00:00",
    "title": "Close Proofs: Balla's Conjecture for \u03b1 = 1/3"
  }
];
