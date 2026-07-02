

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "## Conjecture\nProve that for any integer a, a^5 - a is an integer multiple of 5.\n## Test\nN/A\n## Impact\nTests basic number theory capabilities.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0005",
    "priority_score": 1000.0,
    "research_mode": "team",
    "source_exp_id": "github",
    "status": "available",
    "timestamp": "2026-07-02T02:26:48.900793+00:00",
    "title": "Prove Fermats Little Theorem for p=5"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0003",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T02:21:59.490389+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0000",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T02:21:59.474839+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0001",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T02:21:59.487087+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0002",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T02:21:59.489248+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0004",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-02T02:21:59.491638+00:00",
    "title": "The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: critical augmentations and the fractional chromatic number of the plane\n\nThis cycle isolated the exact counting mechanism behind the phenomenon whereby a 27-point\nplanar unit-distance configuration, after the addition of two points, acquires a geometric\nfractional chromatic number strictly greater than four. The mechanism is a threshold crossing:\nwith the maximum independent set pinned at seven points, the independence ratio equals\n`7/27 > 1/4` before augmentation, exactly `1/4` after a single added point, and `7/29 < 1/4`\nafter two. Two is therefore the least number of points whose addition can force the crossing,\nand this is sharp because the one-point value lands precisely on the boundary. The following\nconjectures build on that finding.\n\n## Conjecture 1 \u2014 Independence-number-preserving extensions are rigid\n\nAmong all ways of adding two points to a 27-point planar unit-distance configuration of\nindependence number seven, only finitely many (up to Euclidean isometry) keep the independence\nnumber equal to seven, and generically none do.\n\n*The key insight is that* the threshold crossing is driven entirely by the denominator: the\nnumerator (the independence number) must be *held fixed*, and holding a maximum independent set\nfixed while inserting new unit-distance constraints is an extremely over-determined geometric\ncondition. **Why now?** The counting side is now completely settled, so the entire difficulty\nhas been concentrated into a single, sharply posed rigidity question about independence-number\npreserving two-point extensions, which is amenable to configuration-space and algebraic methods.\n\n## Conjecture 2 \u2014 The boundary case forbids a one-point shortcut\n\nNo addition of a single point to a 27-point planar unit-distance configuration of independence\nnumber seven can force the geometric fractional chromatic number above four.\n\n*The key insight is that* a single added point leaves the independence ratio at exactly the\ncritical value `1/4`, which is the boundary rather than the strict interior, so the fractional\nbound it yields is exactly four and never exceeds it. **Why now?** The exact equality\n`7/28 = 1/4` makes this a clean impossibility statement rather than an inequality to be\nestimated, turning a numerical coincidence into a structural obstruction worth proving in the\ngeometric category.\n\n## Conjecture 3 \u2014 A minimal-crossing law across independence numbers\n\nFor every base configuration of `n` points whose unit-distance graph has independence number\n`a` and satisfies `n \u2264 4a`, the least number of points that must be added to force the\ngeometric fractional chromatic number above four \u2014 while preserving the independence number \u2014\nis exactly `4a \u2212 n + 1`, and this bound is realised geometrically for infinitely many pairs\n`(a, n)`.\n\n*The key insight is that* the crossing number is a single affine expression in the base size and\nthe independence number, so the seemingly special \"two\" of the G27 story is one value of a\nuniform arithmetic law. **Why now?** The law has been proved on the combinatorial side as an\nexact least-element statement; what remains is a family of explicit geometric realisations, and\nrecent unit-distance constructions provide candidate templates for producing them.\n\n## Conjecture 4 \u2014 Criticality equals independence rigidity\n\nA two-point augmentation of a 27-point planar unit-distance configuration raises the geometric\nfractional chromatic number above four if and only if it adds no new independent set of the\nmaximum size; equivalently, criticality of the augmentation is exactly the failure of the two\nnew points to extend or replace a maximum independent set.\n\n*The key insight is that* augmentation can only ever increase the independence number, so the\nonly way to keep the ratio's numerator fixed while its denominator grows is to block every new\nlarge independent set \u2014 making \"critical\" and \"independence-rigid\" the same property. **Why\nnow?** The monotonicity of the independence number under augmentation is established, so the\nbiconditional reduces to a clean extremal-set condition that can be checked configuration by\nconfiguration.\n\n## Conjecture 5 \u2014 Uniqueness up to isometry\n\nUp to Euclidean isometry, there is exactly one two-point augmentation of the specific 27-point\nconfiguration G27 that produces a 29-point unit-distance graph of geometric fractional chromatic\nnumber greater than four.\n\n*The key insight is that* the rigidity of independence-number-preserving extensions\n(Conjecture 1) should collapse the finite list of admissible augmentations to a single\nisometry class, because the intersection of the unit-distance constraints imposed by both new\npoints on a fixed maximum independent set pins their positions almost completely. **Why now?**\nWith the arithmetic threshold and the criticality characterisation in hand, the uniqueness\nstatement is no longer entangled with the counting argument and can be pursued as a pure\ngeometric determination problem.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0006",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "38047daa",
    "status": "available",
    "timestamp": "2026-07-02T02:27:33.129988+00:00",
    "title": "This cycle isolated the exact counting mechanism behind the phenomenon whereby a"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle 38047daa (Q=0.681) proved 16 theorems in Novelty but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: The paper demonstrates that augmenting the 27-vertex unit-distance graph G27 with a specific pair of vertices results in a 29-vertex graph with geometric fractional chromatic number strictly greater t",
    "domains": [
      "Novelty"
    ],
    "id": "sorry_fill_38047daa_dcecf795",
    "priority_score": 0.7313500000000002,
    "research_mode": "team",
    "source_exp_id": "38047daa",
    "status": "available",
    "timestamp": "2026-07-02T02:27:45.384843+00:00",
    "title": "Close Proofs: Uniqueness of the Critical 2-Vertex Augmentation of G27"
  }
];
