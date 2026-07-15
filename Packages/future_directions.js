

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Building on cycle 3c80004e (Q=0.900), which proved 46 theorems in Physics. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: # Future Directions: Sharp maximal excess of the \u2124\u2082 co-index under joins\n\nThis cycle established the constructive, lower-bound half of the co-index theory:\nthe join of free \u2124\u2082-complexes satisfies\n`coind(K * L) \u2265 coind(K) + coind(L) + 1`,\nwith the octahedral spheres forming a join-monoid `Oct m * Oct",
    "domains": [
      "Physics"
    ],
    "id": "push_3c80004e_d789aea7",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "3c80004e",
    "status": "available",
    "timestamp": "2026-07-15T05:40:44.088651+00:00",
    "title": "Deepening: Constructive, lower-bound half of the co-index theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Building on cycle b1453a16 (Q=0.930), which proved 20 theorems in Bridges. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: # Future Directions \u2014 The Topology of Argumentation (X): the kernel/game bridge\n\nThis cycle adds `ArgumentationKernelGame.lean`, a self-contained bridge file that\nconnects three areas usually developed in isolation:\n\n* **Dung argumentation semantics** (stable extensions),\n* **directed graph theory**",
    "domains": [
      "Bridges"
    ],
    "id": "push_b1453a16_2eb035f6",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "b1453a16",
    "status": "available",
    "timestamp": "2026-07-15T05:59:13.114397+00:00",
    "title": "Deepening: This cycle adds `ArgumentationKernelGame.lean`, a self-contained bridge file tha"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Building on cycle e72af703 (Q=0.910), which proved 13 theorems in MachineLearning. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: Cycle ca1c3afc (Q=0.870) proved 6 theorems in Novelty but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Factorial Codes Beyond Finite Reconstruction\n\n## 1. Lehmer codes as an equivariant factorial-code classifi",
    "domains": [
      "MachineLearning"
    ],
    "id": "push_e72af703_19b27e25",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "e72af703",
    "status": "available",
    "timestamp": "2026-07-15T05:41:05.418140+00:00",
    "title": "Deepening: For every natural number `k`, the factorial-code space of length `k` s"
  },
  {
    "consumed_by_exp_id": "d1d26693",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0005",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-15T05:40:08.936906+00:00",
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
    "timestamp": "2026-07-15T05:40:08.930934+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
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
    "timestamp": "2026-07-15T05:40:08.936072+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "7704d4fe",
    "description": "What if the topology of a space depended on who is observing it? Define a phantom topology on a set X as a function T: O -> Top(X) that assigns to each observer o a topology T(o) on X. Two observers o1, o2 agree on an open set U if U is open in both T(o1) and T(o2). The phantom number of (X, T) is the minimum number of observers needed to determine the topology: if U is open in every T(o) that contains a point x, then U is a neighborhood of x in the 'real' topology. Conjecture: Every second-countable space (X, tau) admits a phantom representation with at most 2 observers (the real topology is the intersection of two phantom topologies). Moreover, every non-metrizable space requires at least 3 observers. The intuition: the real topology is what ALL observers agree on, and phantom topologies are what individual observers see. Like quantum mechanics, measurement changes the topology. Test: prove that R with the standard topology is the intersection of the lower limit topology and the upper limit topology (2 observers). Prove that the Zariski topology on R^2 requires at least 3 observers. Impact: a new notion of topology where the space itself depends on the observer \u2014 the mathematical formalization of 'reality depends on the observer'.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0009",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-15T05:58:21.385836+00:00",
    "title": "Phantom Topologies: Spaces That Change When You Look at Them"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle 3c80004e (Q=0.900) proved 46 theorems in Physics but left 4 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Sharp maximal excess of the \u2124\u2082 co-index under joins\n\nThis cycle established the constructive, lower-bound half of the co-index theory:\nthe join of free \u2124\u2082-complexes satisfies\n`coi",
    "domains": [
      "Physics"
    ],
    "id": "sorry_fill_3c80004e_20198a7d",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "3c80004e",
    "status": "available",
    "timestamp": "2026-07-15T05:40:44.098825+00:00",
    "title": "Close Proofs: Constructive, lower-bound half of the co-index theory"
  },
  {
    "consumed_by_exp_id": "f6b1d920",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0006",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-15T05:40:08.938025+00:00",
    "title": "The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "",
    "description": "An Escher staircase is an infinite strictly ascending chain of ideals I_1 strictly contained in I_2 strictly contained in ... that nevertheless has I_1 as an element of the infinite intersection. This seems impossible \u2014 how can an infinite ascending chain loop back to the beginning? But in the ring of integer-valued polynomials Int(Z), the chain I_n = {f in Int(Z) : f(Z) contained in 2^n Z} is strictly ascending (I_n strictly contained in I_{n+1}) yet the intersection of all I_n is {0}, which contains the zero polynomial that is also in I_1. Conjecture: Every non-Noetherian ring contains an Escher staircase, and the 'height' of the Escher effect (measured by the Krull dimension gap) is a new ring invariant. For Int(Z), the Escher height is infinite (the chain never stabilizes). For Z[x_1, x_2, ...], the Escher height equals the number of variables. For the p-adic integers Z_p, there is NO Escher staircase (Z_p is a DVR, hence Noetherian). Test: prove that Int(Z) has an Escher staircase of infinite height. Prove that k[x_1,...,x_n] has Escher height n. Compute the Escher height for the ring of all algebraic integers. Impact: a new invariant for non-Noetherian rings that measures how far a ring is from being Noetherian \u2014 the algebraic equivalent of Escher's impossible architecture.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0014",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T06:16:18.232072+00:00",
    "title": "Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Deja vu \u2014 the feeling that you've experienced something before \u2014 is a fixed point in a dynamical system. Model cognitive state as a function f: S -> S mapping current brain state to next brain state. A deja vu is a state s such that f^n(s) = s for some n > 0 \u2014 a periodic point of the cognitive dynamical system. Conjecture: By Sharkovsky's theorem, the existence of a period-3 orbit in the cognitive dynamics (three distinct states that cycle) implies chaos in the sense of Li-Yorke, meaning there exist uncountably many cognitive trajectories that are neither periodic nor convergent. Moreover, the set of deja vu states (periodic points of f) is dense in the cognitive state space S if f is continuous and S is an interval. The frequency of deja vu (occurring in ~70% of people) corresponds to the natural density of periodic points in a typical chaotic map. Test: model cognitive dynamics as a logistic map f(x) = rx(1-x) on [0,1] with parameter r chosen to match empirical deja vu frequencies. For r = 3.83 (period-3 window), compute the density of periodic points and compare to the 70% lifetime incidence. Impact: deja vu is not a glitch \u2014 it's a mathematical inevitability of continuous cognitive dynamics. Any continuous cognitive map with a period-3 orbit MUST have deja vu.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "id": "fd_0016",
    "priority_score": 0.78,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T06:34:15.307639+00:00",
    "title": "The Mathematics of Deja Vu: Fixed Points in Consciousness and Cognition"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Extensive Equivariant Invariants of Composite Systems\n\n## 1. Grothendieck completion of finite free \u2124\u2082-systems\n\nThe commutative monoid of finite nonempty free \u2124\u2082-systems under join should admit a canonical group completion on which the shifted co-index is the universal additive integer-valued invariant. In particular, every additive invariant that is constant on equivariant isomorphism classes should factor through `coind + 1`.\n\nThe key insight is that classification reduces every finite system to its number of antipodal orbits, while join adds orbit counts. Why now? The finite composition law proves extensivity for arbitrarily many factors, supplying the monoid structure required for a universal characterization.\n\n## 2. Exponential law for equivariant map counts under composition\n\nFor finite free \u2124\u2082-systems `K` and `L`, the number of equivariant simplicial embeddings from an octahedral sphere into `K * L` should admit a closed convolution formula in the corresponding counts for `K` and `L`, with binomial coefficients recording how source axes split between the factors.\n\nThe key insight is that every map is an injection of antipodal orbits together with independent sign choices, and an injection into a disjoint union splits uniquely by its target component. Why now? Exact co-index composition identifies the support of the expected convolution, while the existing sphere enumeration supplies its boundary values.\n\n## 3. Species-level refinement of the many-body law\n\nFinite free \u2124\u2082-systems and equivariant bijections should form a combinatorial species equivalent to nonempty finite sets of signed pairs; under this equivalence, join should correspond to disjoint union and the cycle index should recover the hyperoctahedral symmetry factors of every composite.\n\nThe key insight is that the orbit decomposition is canonical up to permutation and sign reversal, precisely the wreath-product structure underlying hyperoctahedral groups. Why now? The cardinality and shifted co-index laws already agree on all finite composites, suggesting a refinement from numerical invariants to symmetry-sensitive generating series.\n\n## 4. Failure boundary beyond the octahedral free-set model\n\nThere should exist a finite free \u2124\u2082-simplicial complex whose shifted co-index is strictly subadditive with respect to a suitable join decomposition, demonstrating that orbit counting ceases to classify co-index once arbitrary face relations are admitted.\n\nThe key insight is that the present exact law relies on every antipodal-pair-free subset being a face; deleting selected faces preserves the free action but can obstruct sphere maps without changing the vertex orbit count. Why now? The finite classification theorem precisely isolates the assumption responsible for exact additivity, making a minimal counterexample search sharply defined.\n\n## 5. Stable co-index versus equivariant connectivity\n\nFor arbitrary finite free \u2124\u2082-simplicial complexes, the limit of the normalized sequence `(coind(K^{*r}) + 1)/r` should exist and equal a stable equivariant capacity bounded between an obstruction-theoretic index and the number of vertex orbits.\n\nThe key insight is that joins provide superadditive lower bounds, so a Fekete-type argument should produce a stable rate even when exact finite additivity fails. Why now? Exact extensivity in the free-set model gives a completely solved benchmark and identifies the candidate normalization for the general theory.\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0007",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "3c80004e",
    "status": "available",
    "timestamp": "2026-07-15T05:40:39.215322+00:00",
    "title": "The commutative monoid of finite nonempty free \u2124\u2082-systems under join should admi"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Factorial Codes Beyond Finite Reconstruction\n\n## 1. Equivariant insertion statistics\n\n**Conjecture.** Under the recursive factorial-code classification, conjugation by an adjacent transposition admits a uniformly local description that changes only a bounded interval of digits, and the minimal such interval is determined by the two transposed values.\n\nThe key insight is that the recursive decomposition remembers a distinguished image at each stage, so adjacent group generators should induce structured carries rather than arbitrary global rewrites.\n\n**Why now?** The free and transitive action identifies every digit rewrite with a unique permutation, making locality a precise, falsifiable property rather than an analogy with sorting algorithms.\n\n## 2. Bruhat order from mixed-radix carries\n\n**Conjecture.** There is an intrinsic partial order on factorial codes, defined solely through elementary digit carries, that is isomorphic to strong Bruhat order on the symmetric group and whose rank is the inversion number.\n\nThe key insight is that factorial digits already encode inversion data, while Bruhat covers are controlled by transpositions satisfying interval-avoidance conditions.\n\n**Why now?** The recursive equivalence supplies the correct global classification; the remaining problem is to characterize the transported order without decoding back to permutations.\n\n## 3. A sharp CRT threshold for factorial radices\n\n**Conjecture.** For every `k \u2265 4`, the additive group of `Z/(k!)Z` is not isomorphic to the direct product of the nontrivial radix groups `Z/2Z \u00d7 \u00b7\u00b7\u00b7 \u00d7 Z/kZ`; moreover, the exponent of the product is `lcm(2,\u2026,k)`, which is strictly smaller than `k!`.\n\nThe key insight is that cardinality agrees but exponent detects the repeated prime-power overlap among factorial radices.\n\n**Why now?** The length-four obstruction gives the first case and isolates the invariant that should yield a uniform classification of all later failures.\n\n## 4. Harmonic analysis on factorial-code space\n\n**Conjecture.** Transporting the regular representation through factorial codes yields a multiscale Fourier transform whose stagewise conditional expectations coincide with restriction along the subgroup chain `S\u2081 \u2282 S\u2082 \u2282 \u00b7\u00b7\u00b7 \u2282 S\u2096`.\n\nThe key insight is that recursive digits and the symmetric-group branching chain have the same product-of-indices structure.\n\n**Why now?** The torsor theorem makes functions on codes canonically into functions on a regular group orbit, exposing a direct bridge between mixed-radix representations and noncommutative harmonic analysis.\n\n## 5. Learnable equivariant factorial architectures\n\n**Conjecture.** Every function between finite factorial-code spaces that is equivariant for the transported symmetric-group actions is determined by the image of one code, and a depth-`O(k)` architecture using recursive digit splits realizes every such function with parameter sharing across stages.\n\nThe key insight is that transitive actions reduce equivariant maps to stabilizer-compatible basepoint data, while factorial codes provide a natural recursive computational graph.\n\n**Why now?** Freeness eliminates stabilizer constraints entirely for equal-length code torsors, giving an exact baseline from which approximate and partially equivariant architectures can be studied.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0008",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "e72af703",
    "status": "available",
    "timestamp": "2026-07-15T05:40:52.669066+00:00",
    "title": "**Conjecture.** Under the recursive factorial-code classification, conjugation b"
  },
  {
    "consumed_by_exp_id": "5dadc373",
    "description": "A vampire number is a composite number v with an even number of digits that can be factizedd as v = x * y where x and y together have the same digits as v. The smallest is 1260 = 21 * 60. But vampire numbers are just the beginning. Define: (1) Werewolf numbers: v = x * y where x and y share exactly one digit with v. (2) Ghost numbers: v = x * y where v has NO digits in common with x or y. (3) Zombie numbers: v = x * y where x and y are both prime (these violate the definition but exist \u2014 125460 = 204 * 615 = 246 * 510, where both factorizations involve a prime and a composite). Conjecture: The density of vampire numbers in [10^{2n}, 10^{2n+1}] approaches 1/sqrt(n) as n -> infinity. Every even-length interval [10^{2k}, 10^{2k+2}] contains at least one vampire number. Ghost numbers have density 0 \u2014 they become vanishingly rare as the number of digits increases. Test: enumerate all vampire, werewolf, ghost, and zombie numbers up to 10^8. Prove the density conjecture by counting valid digit permutations. Impact: a playful but genuine number theory of arithmetic creatures \u2014 combinatorial digit problems that are easy to state but may be as hard as factoring.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0010",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-15T05:58:21.391551+00:00",
    "title": "Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n1. **Computable ranking and unranking.** Replace the finite-cardinality inverse used by `codeRankEquiv` with an executable decoder based on repeated division by factorials, and prove it extensionally equal to the current equivalence.\n2. **Concrete inversion-vector semantics.** Connect each digit to the number of smaller entries preceding or following the corresponding symbol in the classified permutation. This would identify the present recursive equivalence with the conventional Lehmer code, not merely a canonical factoradic classification.\n3. **Order and parity.** Prove that factoradic rank gives a total enumeration of permutations and derive the sign formula `sign \u03c3 = (-1)^(sum of code digits)`.\n4. **Adjacent ranks.** Characterize how incrementing a factoradic rank transforms the permutation, including carry propagation across digits.\n5. **Arbitrary finite types.** Transport the classification from `Fin k` to any finite linearly ordered type and prove naturality under order equivalences.\n6. **Algorithmic complexity.** Implement rank/unrank and verify time bounds for digit extraction and recursive insertion.\n",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_0011",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "7385ba7c",
    "status": "available",
    "timestamp": "2026-07-15T05:59:00.838880+00:00",
    "title": "1. **Computable ranking and unranking.** Replace the finite-cardinality inverse "
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Argumentation kernels and games\n\nThis cycle supplies the bridge among stable extensions, directed kernels, and\nnormal-play P-position solutions in `Bridges/ArgumentationKernelGame.lean`.\nIt also proves the terminating-game recursion theorem, existence and uniqueness\nof kernels under reverse-move well-foundedness, and the corresponding unique\nstable-extension theorem.\n\nThe cycle comparison is now two-sided: the directed 3-cycle has no kernel or\nstable extension, while the directed 4-cycle has two explicit alternating\nstable extensions. Thus even cycles provide existence but not uniqueness once\nwell-foundedness is dropped.\n\nNatural next steps are:\n\n1. Define the directed cycle uniformly on `Fin n` and classify all its kernels:\n   none for odd `n`, and exactly two alternating kernels for positive even `n`.\n2. Prove kernel-perfectness under hereditary hypotheses, starting with finite\n   acyclic digraphs and then investigating the no-odd-directed-cycle condition.\n3. Connect recursively defined `isLoss` to an order-theoretic grounded\n   extension and prove equality in the well-founded case.\n4. Refine `isLoss` to a Sprague\u2013Grundy value and show that value zero is exactly\n   kernel membership.\n",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0012",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "b1453a16",
    "status": "available",
    "timestamp": "2026-07-15T05:59:12.274929+00:00",
    "title": "This cycle supplies the bridge among stable extensions, directed kernels, and"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Adjoint Selmer Rigidity\n\n## 1. Derived rigidity without residual adequacy\n\n**Conjecture.** Let a regular algebraic cuspidal automorphic representation of a general linear group over a CM field give a characteristic-zero Galois representation satisfying the expected local de Rham regularity and irreducibility conditions. Its derived global deformation ring is concentrated in degree zero and is formally \u00e9tale at the automorphic point, without an adequacy or largeness hypothesis on the residual representation.\n\nThe key insight is that characteristic-zero infinitesimal rigidity should control not only the classical tangent space but the entire cotangent complex, making residual hypotheses unnecessary at every derived order. **Why now?** Adjoint Bloch--Kato vanishing supplies the degree-one input, while derived deformation theory provides a precise sequence of higher obstruction groups against which the stronger claim can be tested.\n\n## 2. Componentwise propagation of adjoint Selmer vanishing\n\n**Conjecture.** On every irreducible characteristic-zero component of an eigenvariety containing a regular noncritical classical point, vanishing of the adjoint Bloch--Kato Selmer group at one Zariski-dense set of classical points forces generic vanishing on the whole component; the exceptional locus is a proper determinantal subvariety cut out by the failure of a global-to-local relation map to have full rank.\n\nThe key insight is that the Selmer group is a kernel in a coherent family, so its jumping locus should be determinantal rather than arbitrary. **Why now?** The full-rank characterization of rigidity isolates the exact geometric condition needed to formulate and measure this jumping phenomenon.\n\n## 3. Contragredient symmetry of rigidity loci\n\n**Conjecture.** The contragredient involution on a regular algebraic eigenvariety preserves the scheme-theoretic adjoint-rigidity locus, including all multiplicities of its non-rigid determinantal strata.\n\nThe key insight is that negate-and-reverse duality on algebraic weights should lift from weight-space symmetry to a perfect duality of Selmer complexes, not merely an equality of tangent-space dimensions. **Why now?** Zero variation is already reflected by contragredient duality at the algebraic-weight level, and the next test is whether this reflection persists for the complete arithmetic deformation complex.\n\n## 4. Coefficient-field invariance for integral Selmer defects\n\n**Conjecture.** After excluding a finite, explicitly characterizable set of primes, extension of coefficient fields preserves not only characteristic-zero adjoint Selmer vanishing but also the Fitting ideal of the integral adjoint Selmer complex up to flat base change.\n\nThe key insight is that flat scalar extension preserves injectivity at the tangent level, suggesting that the finer integral defect should be governed by a base-change-compatible perfect complex. **Why now?** The characteristic-zero preservation theorem identifies the robust linear mechanism; integral Fitting ideals provide a falsifiable refinement sensitive to torsion that the linear statement cannot see.\n\n## 5. Quantitative rigidity from local Hodge data\n\n**Conjecture.** For regular algebraic automorphic Galois representations over CM fields, the codimension of every non-rigid deformation stratum admits a uniform lower bound determined solely by gaps among Hodge--Tate weights and the number of split places imposing crystalline conditions.\n\nThe key insight is that regular Hodge filtrations contribute independent local linear constraints whose transversality should force a predictable rank surplus in the global relation map. **Why now?** Rigidity has a full-rank formulation, allowing local Hodge-theoretic constraints to be translated into concrete determinantal codimension estimates and tested in low-rank families.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0015",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d4584015",
    "status": "available",
    "timestamp": "2026-07-15T06:16:53.136495+00:00",
    "title": "**Conjecture.** Let a regular algebraic cuspidal automorphic representation of a"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: triangle holonomy beyond the second moment\n\n## Result of this cycle\n\n`Shared/SeidelTriangleHolonomy.lean` establishes a cross-domain bridge among\nthree viewpoints:\n\n1. **spectral graph theory:** the cubic Seidel moment `tr(S\u00b3)`;\n2. **enumerative graph theory:** the signed sum of ordered vertex triples,\n   weighted `+1` when the three cyclic pairs contain an even number of edges and\n   `-1` when they contain an odd number (repeated-vertex triples have weight\n   zero);\n3. **signed-graph gauge theory:** the product of edge signs around a triangle is\n   a holonomy, unchanged by multiplying every incident edge sign by a vertex\n   sign.\n\nThe proved identity is\n\n`tr(S\u00b3) = \u2211 i, \u2211 j, \u2211 k, parityWeight adj i j k`.\n\nThe local cancellation theorem then proves invariance of this cubic trace under\narbitrary diagonal sign switching directly, without invoking eigenvalues or\nmatrix similarity. A checked three-vertex witness gives `-6` for the complete\ngraph and `6` for the empty graph in both the trace and parity formulations.\n\n## Immediate next theorem: unordered triple counts\n\nFor a symmetric loopless graph, every unordered three-element vertex set occurs\nin six orders. The next useful refinement is therefore\n\n`tr(S\u00b3) = 6 \u00b7 (N_even - N_odd)`,\n\nwhere `N_even` and `N_odd` count three-vertex subsets spanning respectively an\neven or odd number of edges. Formalizing this through `Finset (Finset V)` would\nturn the present ordered-sum identity into a directly usable graph-counting\nformula. It would also characterize vanishing cubic moment as exact balance of\nthe two parity classes.\n\n## Edge deletion as a local triangle-parity operation\n\nDeleting an edge `{a,b}` toggles the parity of exactly those triples containing\n`a` and `b`. Combining that observation with the unordered count formula should\ngive a combinatorial proof of the existing rank-two cubic update formula. The\nmatrix entry `(S\u00b2) a b` should emerge as the signed imbalance among common\nthird vertices. This would connect the matrix perturbation calculation to a\nlocal count and may expose tractable statistics for Tur\u00e1n graphs.\n\n## Higher-cycle holonomy\n\nFor every closed walk, vertex-switch signs cancel in the product of signed edge\nweights. The triangle result suggests proving a general closed-walk theorem and\nthen deriving switching invariance of `tr(S^m)` for every natural `m` by summing\nwalk holonomies. This gives a combinatorial route from local gauge invariance to\nall spectral moments, and eventually to characteristic-polynomial invariance\nvia Newton identities.\n\n## Corrections to two motivating conjectures\n\nTwo proposed directions need reformulation before further proof work:\n\n* Seidel switching preserves the whole spectrum and hence preserves energy.\n  Therefore energy cannot be a *strict* monotone within one switching class;\n  all representatives in that class have exactly the same energy.\n* From a fixed sum of squares, the general inequality `\u2016\u03bb\u2016\u2081 \u2265 \u2016\u03bb\u2016\u2082` has equality\n  when at most one coordinate is nonzero, not when all coordinates have equal\n  magnitude. Equal magnitudes instead maximize the `\u2113\u00b9` norm at fixed `\u2113\u00b2` and\n  fixed dimension. Consequently, an asymptotic conference characterization\n  cannot follow from the stated equality argument alone.\n\nA sound replacement question is whether additional Seidel constraints (zero\ntrace, integral characteristic polynomial, and off-diagonal signs) force a\nstronger lower bound than the unrestricted `\u2113\u00b9`/`\u2113\u00b2` estimate, and which graph\nfamilies approach that corrected bound.\n",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0017",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "80f7c124",
    "status": "available",
    "timestamp": "2026-07-15T06:52:08.639786+00:00",
    "title": "`Shared/SeidelTriangleHolonomy.lean` establishes a cross-domain bridge among"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Fibonacci sequence is defined by F(n+1) = F(n) + F(n-1) and converges to the golden ratio. Define the ANTI-Fibonacci sequence: A(n+1) is the smallest positive integer that is NOT equal to A(n) + A(n-1). The sequence begins 1, 1, 2, 4, 7, 11, 16, ... (each term avoids being the sum of the two previous terms). Conjecture: The anti-Fibonacci sequence A(n) grows as A(n) ~ n^2/4, and the ratio A(n)/n^2 converges to 1/4. More precisely, A(n) = floor(n^2/4) + O(1). The sequence avoids the golden ratio entirely \u2014 the ratio A(n+1)/A(n) does NOT converge, instead oscillating between 1 and 2. The complement of the anti-Fibonacci sequence (numbers that ARE sums of two previous anti-Fibonacci numbers) has density 0. Test: compute A(n) for n up to 10^6 and verify A(n)/n^2 approaches 1/4. Prove A(n) = floor(n^2/4) + O(1) by induction. Impact: a beautiful counterpoint to the Fibonacci sequence \u2014 instead of converging to a constant, it grows quadratically while systematically avoiding addition.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0013",
    "priority_score": 0.73,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-15T06:16:18.228361+00:00",
    "title": "The Anti-Fibonacci Sequence: Numbers That Avoid the Golden Ratio at All Costs"
  },
  {
    "consumed_by_exp_id": "2ed994b6",
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
    "id": "fd_0001",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:212351",
    "status": "available",
    "timestamp": "2026-07-15T05:23:22.329230+00:00",
    "title": "OEIS sequence: Maximal number of \"good\" manifolds in an n-nice polytope."
  }
];
