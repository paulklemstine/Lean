

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "## Conjecture\nProve that for any integer a, a^5 - a is an integer multiple of 5.\n## Test\nN/A\n## Impact\nTests basic number theory capabilities.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0014",
    "priority_score": 1000.0,
    "research_mode": "",
    "source_exp_id": "",
    "status": "available",
    "timestamp": "2026-07-02T03:56:18.082191+00:00",
    "title": "Prove Fermats Little Theorem for p=5"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Building on cycle d80d981e (Q=0.871), which proved 15 theorems in Tropical. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: The key insight is that the Petersen graph's metric obstruction to isometric embedding into classical abelian Cayley graphs extends to Cayley graphs of idempotent semirings (tropical semirings) because the tropical distance valuation preserves the essential girth and diameter constraints that forbid",
    "domains": [
      "Tropical"
    ],
    "id": "push_d80d981e_f533ff69",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "d80d981e",
    "status": "available",
    "timestamp": "2026-07-02T03:51:06.938222+00:00",
    "title": "Deepening: Non-embeddability of the Petersen graph into tropical abelian Cayley graphs"
  },
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
    "consumed_by_exp_id": "",
    "description": "For any filtered system of nilperfect rings {R_i} with colimit R, the canonical map colim \u211dW(R_i) \u2192 \u211dW(R) is an isomorphism of abelian groups. This conjecture addresses the fundamental motivation for sheared Witt vectors: resolving the failure of W(R)/p^n to commute with filtered colimits while preserving essential Dieudonn\u00e9-theoretic properties.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0005",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.01178v1",
    "status": "available",
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
    "description": "# Future Directions: Metric Rigidity of the Petersen Graph across Valued Cayley Geometries\n\nThis cycle established that the Petersen graph \u2014 and, more generally, any graph\ncarrying an odd closed walk \u2014 cannot be realized isometrically inside a Cayley\ngraph whose generating set is the *odd part* of an integer-valued valuation on an\nabelian group. The obstruction splits cleanly into a valuation-free metric core\n(an isometric image pulls back proper colorings of any number of colors) and a\none-parameter certificate (the parity of the valuation two-colors the host). The\ndirections below push on the boundary of this dichotomy.\n\n## Conjecture 1 (Even-valuation hosts)\nThere exists an abelian group `A`, an integer-valued valuation `v` all of whose\ngenerators have **even** value, and an isometric embedding of the Petersen graph\ninto the associated Cayley graph.\n\n**The key insight is** that the parity certificate is the *only* place oddness of\nthe valuation is used; once every generator has even value the host may contain\nodd closed walks of its own, removing the coloring obstruction and potentially\nopening room for a genuine isometric copy of an odd-girth graph.\n\n**Why now?** The clean separation between the metric core and the parity\ncertificate isolates exactly one hypothesis to relax, turning a broad\nnon-embeddability statement into a sharp, testable existence question about\neven-valued generating sets.\n\n## Conjecture 2 (Valuation rank threshold)\nFor every abelian group `A` equipped with a valuation whose value group has rank\none, no odd-girth graph embeds isometrically into the odd-valuation Cayley graph;\nbut there is a rank-two valued group into which the Petersen graph does embed\nisometrically.\n\n**The key insight is** that a rank-one valuation forces a global linear order on\ngenerator lengths, which propagates the parity obstruction along every closed\nwalk, whereas incomparable lengths in higher rank can cancel the length parity\nthat a single odd walk would otherwise force.\n\n**Why now?** Valuation-theoretic rank is the natural graded refinement of the\npresent integer-valued setting, and it converts the qualitative \"odd vs even\"\ndichotomy into a quantitative rank threshold that can be probed group by group.\n\n## Conjecture 3 (Tropical distance spectrum)\nThe multiset of pairwise tropical (min-plus) path lengths realizable inside any\nodd-valuation Cayley graph omits at least one distance value that the Petersen\nmetric requires; consequently the omission itself, not merely bipartiteness, is\nthe true obstruction, and it persists for a positive-density family of\nnon-bipartite hosts.\n\n**The key insight is** that shortest-path distance is intrinsically a min-plus\ncomputation, so an embedding must reproduce an entire tropical distance spectrum,\nand the Petersen spectrum (diameter two, girth five) is over-determined relative\nto what valuation-graded hosts can supply.\n\n**Why now?** Recasting graph distance as a tropical eigen-quantity makes the\ndistance spectrum a computable invariant, so the conjectured omission can be\nsearched for directly across families of valued groups.\n\n## Conjecture 4 (Universal odd-girth barrier)\nFix an odd integer `g \u2265 5`. No vertex-transitive graph of girth `g` embeds\nisometrically into any odd-valuation Cayley graph, and the Petersen graph is the\nsmallest such witness for `g = 5`.\n\n**The key insight is** that vertex-transitivity forces the odd closed walk to be\n\"spread\" uniformly over the graph, so the parity obstruction cannot be localized\naway by re-centering the embedding, making girth alone the controlling parameter.\n\n**Why now?** The odd-closed-walk engine already proven here is indifferent to the\nparticular source graph, so extending it from Petersen to an entire girth class\nis a natural and immediately checkable generalization.\n\n## Conjecture 5 (Idempotent-coefficient rigidity)\nReplacing the integer value group by an arbitrary linearly ordered idempotent\nadditive monoid leaves the non-embeddability intact precisely when the monoid\nadmits a surjection onto the two-element idempotent monoid; otherwise the barrier\ndisappears.\n\n**The key insight is** that bipartiteness of the host is equivalent to the\nexistence of a two-valued reduction of the coefficient monoid, so the entire\nobstruction is governed by the two-element quotient structure of the underlying\nidempotent algebra.\n\n**Why now?** Idempotent (tropical) coefficient systems are exactly the setting in\nwhich distance and addition coincide, so characterizing which of them retain the\nPetersen barrier pins the phenomenon to a single algebraic quotient condition.\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0012",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d80d981e",
    "status": "available",
    "timestamp": "2026-07-02T03:50:58.643112+00:00",
    "title": "That the Petersen graph \u2014 and, more generally, any graph"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Explicit class field theory beyond the prime-degree layer\n\nThis cycle established that the smallest abelian layers over a number field \u2014 those of prime\ndegree \u2014 are rigid: they have cyclic Galois groups and no intermediate fields, uniformly across\nthe cyclotomic tower and the Hilbert class field. The following bold, falsifiable conjectures\nextend that finding.\n\n## Conjecture 1 \u2014 Lattice rigidity is exactly the \"squarefree class number\" phenomenon\n\nFor a number field `K`, the Hilbert class field `H/K` has a *distributive* subfield lattice that\nis a Boolean-type product of prime layers precisely when the class number is squarefree; the first\nnon-distributive behaviour appears at the smallest square factor.\n\nThe key insight is that the subfield lattice of the class field is an exact mirror of the subgroup\nlattice of the class group, so the arithmetic question \"when is the tower of abelian layers\nlattice-simple?\" becomes the purely group-theoretic question \"when is the class group a product of\ndistinct cyclic prime factors?\" \u2014 squarefreeness of the class number.\n\nWhy now? Class numbers and class-group structures are tabulated for enormous ranges of\ndiscriminants, so the squarefree/non-squarefree split can be tested against millions of fields\nimmediately, turning a structural conjecture into a data-driven one.\n\n## Conjecture 2 \u2014 Prime-degree minimality forces a reciprocity fingerprint on splitting primes\n\nIf `H/K` is an abelian extension of prime degree `p`, then the rational primes (or prime ideals of\n`K`) split completely in `H` exactly along a single congruence/ray class condition of index `p`,\nand no coarser condition suffices.\n\nThe key insight is that a prime-degree layer has no room for intermediate splitting behaviour: the\nabsence of intermediate fields means a prime is either inert-type or fully split, so the splitting\nlaw must be governed by one primitive character of order `p` rather than a composite of several.\n\nWhy now? The prime-degree rigidity is exactly the hypothesis under which the still-incomplete\ngeneral reciprocity law simplifies to a single character, making it the most tractable next case to\npin down explicitly and to check against known splitting tables for cubic and quintic fields.\n\n## Conjecture 3 \u2014 Genus layers are the unique obstruction to prime-degree rigidity\n\nThe failure of subfield-lattice rigidity for a class field is controlled entirely by the 2-part\n(more generally the `p`-part) of the class group: the number of independent quadratic (resp.\ndegree-`p`) intermediate layers equals the `p`-rank of the class group, and these are precisely the\n\"genus\" subfields.\n\nThe key insight is that non-trivial intermediate fields can only come from non-cyclic factors of\nthe class group, and the count of independent minimal layers is a rank, not a size \u2014 so the entire\ndeviation from rigidity is measured by a single rank invariant.\n\nWhy now? `p`-ranks of class groups (especially the 2-rank via genus theory) are computable directly\nfrom the factorization of the discriminant, so the rank-versus-layer-count identity can be verified\nexhaustively for quadratic fields without computing full class groups.\n\n## Conjecture 4 \u2014 Cyclic class groups characterize \"single-generator\" arithmetic\n\nA number field has cyclic ideal class group if and only if its Hilbert class field is generated over\nthe base by a single algebraic element whose minimal polynomial has degree equal to the class\nnumber \u2014 a one-parameter explicit description in the spirit of Hilbert's twelfth problem.\n\nThe key insight is that cyclicity of the class group is equivalent to cyclicity of the class-field\nGalois group, and a cyclic Galois extension is exactly a simple (primitive-element) extension whose\ndegree is the group order, converting an abstract structural property into a concrete\nsingle-generator statement.\n\nWhy now? Cyclic class groups dominate the statistics of small discriminants, so a single-generator\ndescription would immediately apply to the vast majority of tabulated fields and could be checked\nagainst explicit generators already recorded for imaginary quadratic fields of small class number.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0013",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6501d983",
    "status": "available",
    "timestamp": "2026-07-02T03:55:49.617569+00:00",
    "title": "That the smallest abelian layers over a number field \u2014 th"
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
