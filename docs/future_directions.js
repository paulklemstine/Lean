

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0076",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:30:21.132499+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0073",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:30:21.115862+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0074",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:30:21.121271+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0075",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:30:21.126866+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0077",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:30:21.137914+00:00",
    "title": "The Library of Babel: Combinatorics of the Universal Library"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Magnitude homology of tope graphs' and formalize its key results. Abstract: We completely determine the magnitude homology of tope graphs of real hyperplane arrangements. Their ranks can be described as the Hilbert functions of the Stanley--Reisner rings of certain simplicial complexes naturally associated with the arrangements. For Coxeter arrangements, this gives a computation of the magnitude homology of the Cayley graph of the corresponding Coxeter group. We also prove the homological reciprocity for central arrangements conjectured by Koizumi--Liu. The proof combines poset combinatorics, the Edelman--Walker theorem, and Alexander duality.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0001",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11863v1",
    "status": "available",
    "timestamp": "2026-07-15T06:52:23.069944+00:00",
    "title": "ArXiv paper: Magnitude homology of tope graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Improving Upper Bounds for the Maximum Clique Problem using Reduction Rules' and formalize its key results. Abstract: We study the interaction between reduction rules and upper-bound functions for the Maximum Clique Problem (MCP). We show how MCP upper-bound functions can strengthen classical core and truss reductions by replacing local size conditions with upper-bound tests. This leads to the \\((k,\u03c9^u)\\)-core, the \\((k,\u03c9^u)\\)-truss, and the more general \\((k,d,\u03c9^u)\\)-truss, where the parameter \\(d\\) controls the trade-off between stronger reductions and additional computational cost. For each of these notions, we prove clique-preservation properties, correctness of the corresponding peeling algorithm, and running-time bounds. Based on these reductions, we introduce a general framework for improving upper-bound values for MCP. We give two concrete instantiations of the framework: one that uses only the combined truss and core reductions, and one that combines the truss and core reductions with repeated applications of structions. Computational experiments on 73 benchmark graphs show that the proposed ",
    "domains": [
      "Computation"
    ],
    "id": "fd_0004",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11726v1",
    "status": "available",
    "timestamp": "2026-07-15T07:46:50.520811+00:00",
    "title": "ArXiv paper: Improving Upper Bounds for the Maximum Clique Problem using Reduction Rules"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Exact Cardinality And Nonredundant Parametrization Of Character-Polynomial Codes' and formalize its key results. Abstract: Character-polynomial codes are constructed by evaluating finite field polynomials and mapping the results to complex roots of unity through additive characters. This paper shows that, over extension fields, the original polynomial family may contain redundancies: distinct polynomials can generate the same codeword. We identify the source of this non-injectivity through the trace map and cyclotomic cosets, determine the exact code cardinality, and construct a refined polynomial family that parametrizes the code without redundancy. These results give corrected parameters for CP codes and clarify their algebraic structure.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0008",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11595v1",
    "status": "available",
    "timestamp": "2026-07-15T08:58:24.618652+00:00",
    "title": "ArXiv paper: Exact Cardinality And Nonredundant Parametrization Of Character-Polynomial Codes"
  },
  {
    "consumed_by_exp_id": "b71e4678",
    "description": "Investigate the ArXiv paper 'From roots to paths: graphs simultaneously irregular with respect to rooted and ordinary paths' and formalize its key results. Abstract: Let $P_n$ denote a path on $n$ vertices. A simple finite graph $G$ is called $P_n$-irregular if any two distinct vertices of $G$ belong to a different number of subgraphs of $G$ isomorphic to $P_n$. Alternatively, for a fixed vertex $r$ of $P_n$ (the root), $G$ is called $(P_n)_r$-irregular if any two distinct vertices of $G$ act as the root $r$ in a different number of subgraphs of $G$ isomorphic to $P_n$. This paper proves that for each integer $k \\geq 4$, there exists an infinite family of graphs that are simultaneously $P_n$-irregular and $(P_n)_r$-irregular for every integer $n$ satisfying $4 \\leq n \\leq k$ and every root $r$ of $P_n$. For the path $P_3$, we observe that no nontrivial $(P_3)_r$-irregular graphs exist if $r$ is the central vertex. In contrast, if $r$ is an end-vertex of $P_3$, an infinite collection of graphs is constructed that are both $P_3$-irregular and $(P_3)_r$-irregular. In particular, these results confirm the Strong Conjecture about $F$-irregular graphs fo",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0009",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11700v1",
    "status": "in_progress",
    "timestamp": "2026-07-15T09:16:25.430793+00:00",
    "title": "ArXiv paper: From roots to paths: graphs simultaneously irregular with respect to rooted and ordinary paths"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A decomposition of Weyl group multiple Dirichlet series for symmetrizable Kac-Moody root systems' and formalize its key results. Abstract: We study twisted Weyl group multiple Dirichlet series attached to symmetrizable Kac-Moody root systems, using the Chinta-Gunnells method to construct their $p$-parts. Our main result is a decomposition theorem for functions invariant under the twisted Chinta-Gunnells action: under natural analytic hypotheses, such a function has a unique expansion in terms of shifted Chinta-Gunnells averages, indexed by the dominant weights in the highest weight module determined by the twisting parameter. In particular, we show that this decomposition holds for twisted multiple Dirichlet series over rational function fields. For finite root systems, these results were proved by Friedlander. We also show that the relevant Chinta-Gunnells averages admit analytic continuation to the interior of the complexified Tits cone. In the affine $\\widetilde{A}_1$ case, we prove extra functional equations, not arising from the Weyl group, for the untwisted average and for averages twisted by fundamental weights. As",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0011",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11834v1",
    "status": "available",
    "timestamp": "2026-07-15T06:52:29.386046+00:00",
    "title": "ArXiv paper: A decomposition of Weyl group multiple Dirichlet series for symmetrizable Kac-Moody root systems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On the maximum size of $B_3$-free families' and formalize its key results. Abstract: A family $\\mathcal{G}$ of sets is a weak copy of the poset $(P,\\leqslant)$ if there exists a bijection $\u03b9:P\\rightarrow \\mathcal{G}$ with $\u03b9(p)\\subset \u03b9(q)$ whenever $p\\leqslant q$. $\\mathcal{G}$ is a strong copy if $\u03b9(p)\\subset \u03b9(q)$ if and only if $p\\leqslant q$ holds. A family is weak (strong) $P$-free if it does not contain any weak (strong) copies of $P$. For a poset $P$, let $e(P)$ ($e^*(P)$) denote the most number of middle layers of $2^{[n]}$ that does not contain a weak (strong) copy of $P$. Ellis, Ivan, and Leader were the first to show the existence of posets $P$ for which there exists a positive real $\\varepsilon_P$ such that $La(n,P)\\ge (e(P)+\\varepsilon_P)\\binom{n}{\\lfloor n/2}$ and $La^*(n,P)\\ge (e^*(P)+\\varepsilon_P)\\binom{n}{\\lfloor n/2}$ holds, where $La(n,P)$ ($La^*(n,P)$) denotes the maximum size of a weak (strong) $P$-free family $\\mathcal{F}\\subseteq 2^{[n]}$. More precisely, they showed that $P=B_d$ are such posets for all $d\\ge 4$, where $B_d$ is the Boolean latt",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0013",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11753v1",
    "status": "available",
    "timestamp": "2026-07-15T07:28:27.663774+00:00",
    "title": "ArXiv paper: On the maximum size of $B_3$-free families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Quantum Latin Squares of Order Six with Cardinalities Nineteen, Twenty-One, and Twenty-Three' and formalize its key results. Abstract: We give three explicit quantum Latin squares of order $6$ with cardinalities $19$, $21$, and $23$, where vectors differing only by a global phase are counted as identical. The first two examples arise from normalized Schur products of columns of complex Hadamard matrices. For cardinality $19$, a Butson-type matrix over eighth roots of unity has the unique nontrivial coincidence $v_{01}=v_{25}=v_{34}$. For cardinality $21$, an explicit member of Karlsson's three-parameter family has $21$ pairwise inequivalent unordered Schur products. To exceed the symmetric Schur-product bound, we give a third, direct-sum construction based on the decomposition $\\C^6=\\C^4\\oplusC^2$. It uses nineteen distinct rays in the four-dimensional summand and four rays in the two-dimensional summand, arranged so that every row and column is an orthonormal basis, yielding cardinality $23$. Together with our earlier constructions of cardinalities $13$, $15$, and $17$ and previously known order-six examples, these r",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0014",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11800v1",
    "status": "available",
    "timestamp": "2026-07-15T07:46:57.950799+00:00",
    "title": "ArXiv paper: Quantum Latin Squares of Order Six with Cardinalities Nineteen, Twenty-One, and Twenty-Three"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The chain replacement of a poset flow' and formalize its key results. Abstract: We introduce the chain replacement of a poset flow: it is obtained by considering the simplicial nerves of the posets of strictly increasing chains in the given poset, ordered by refinement. It maps finite posets to q-cofibrant flows and inclusions of finite posets to q-cofibrations. Using the combinatorial properties of the chain replacement, we prove that pushouts along the chain replacement of an order-reflecting inclusion of finite posets preserve spaces of execution paths. By introducing the Hurewicz model structure on flows (or H-model structure), we deduce the same property for any q-cofibrant replacement of an order-reflecting inclusion of finite posets.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0016",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11639v1",
    "status": "available",
    "timestamp": "2026-07-15T08:21:53.852514+00:00",
    "title": "ArXiv paper: The chain replacement of a poset flow"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Ray and end spaces: characterizations and classification up to homeomorphism' and formalize its key results. Abstract: We provide a combinatorial characterization for pairs of order-theoretic trees with homeomorphic ray spaces, answering an open problem proposed by Kurkofka ad Pitz. This solution is inspired by the introduction of a transfinite topological game, which allows us to characterize not only ray spaces through the existence of winning strategies for one of the players, but also their homeomorphic classes. As applications of these results, we obtain a new topological characterization for graph-theoretic end spaces (thus obtaining yet another solution to a recently solved problem of Diestel), as well as for edge-end spaces and completely ultrametrizable spaces. We also introduce a generalization of the class of ray spaces (which is strict, as witnessed by the Sorgenfrey line). Furthermore, we establish that, for subspaces with cardinality less than continuum of end spaces, the scattered property is equivalent to the property of being, itself, an end space. At last, we determine that ray spaces",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0018",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11561v1",
    "status": "available",
    "timestamp": "2026-07-15T08:58:28.589423+00:00",
    "title": "ArXiv paper: Ray and end spaces: characterizations and classification up to homeomorphism"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Submultiplicative Polynomials in Combinatorics' and formalize its key results. Abstract: For normalized sequences $\\left(g(n)\\right)_{n\\in\\mathbb{N}}$ we consider recursively defined polynomials $P_n^g(x)$. In this paper we study their submultiplicative property, viewed as a Bessenrodt--Ono type inequality for the partition function, and provide an effective criterion for establishing it.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0019",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11568v1",
    "status": "available",
    "timestamp": "2026-07-15T09:16:28.855309+00:00",
    "title": "ArXiv paper: Submultiplicative Polynomials in Combinatorics"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Even smaller universal posets' and formalize its key results. Abstract: We show that for every $\u03b7>0$ and sufficiently large $n$, there exists a poset of size $2^{(1+\u03b7)n/2}$ containing all the $n$-element posets as induced subposets. This improves a recent result of Bastide, Groenland and Nenadov. Our proof provides a labeling scheme preserving transitivity, inspired by the Boolean lattice. Among other tools, we use the Szemer\u00e9di Regularity Lemma.",
    "domains": [
      "Cryptography",
      "Logic"
    ],
    "id": "fd_0020",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12980v1",
    "status": "available",
    "timestamp": "2026-07-15T12:33:21.946611+00:00",
    "title": "ArXiv paper: Even smaller universal posets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Cyclic Projective Orbits on Rational Normal Curves and MDS Codes' and formalize its key results. Abstract: Let \\(A\\) be a cyclic operator on an \\(r\\)-dimensional vector space over a field \\(k\\), and let \\(z\\) be a cyclic vector. Their Krylov code has parity-check matrix \\((z,Az,\\ldots,A^{n-1}z)\\). For \\(r\\ge 3\\) and \\(n\\ge r+3\\), we prove that an MDS orbit segment lies on a rational normal curve precisely when the projective pair \\((A,[z])\\) is conjugate to one arising from the \\((r-1)\\)-st symmetric-power action of \\(\\mathrm{PGL}_2\\). Over finite fields, for companion operators, this gives a complete classification of the generalized Reed--Solomon locus into split semisimple, two nonsplit semisimple, and unipotent families. Over an algebraically closed field \\(k\\), the Zariski closure \\(\\GRSsurf_{r,k}\\) of the semisimple GRS coefficient locus is an irreducible rational surface, generically parameterized two-to-one by a two-dimensional torus of geometric-progression root sets; reversal is the generic ambiguity. The affine quotient of the parameter torus by reversal is the normalization of \\",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0021",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12761v1",
    "status": "available",
    "timestamp": "2026-07-15T12:51:13.579274+00:00",
    "title": "ArXiv paper: Cyclic Projective Orbits on Rational Normal Curves and MDS Codes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Large sets of mutually orthogonal quantum Latin squares' and formalize its key results. Abstract: How large can a set of mutually orthogonal quantum Latin squares (MOQLS) get? We show that a set of n - 2 MOQLS of order n is necessarily classical and construct large non-classical sets of MOQLS of orders that are prime powers, improving both the previously known lower and upper bounds.",
    "domains": [
      "Pythagorean",
      "Physics"
    ],
    "id": "fd_0022",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12933v1",
    "status": "available",
    "timestamp": "2026-07-15T13:08:22.368965+00:00",
    "title": "ArXiv paper: Large sets of mutually orthogonal quantum Latin squares"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Ranks of Elliptic Curves Twisted by Quadratic Forms' and formalize its key results. Abstract: Let $E$ be an elliptic curve over $\\mathbb{Q}$ and let $E^d$ be its twist by the quadratic character $\u03c7_d$. We prove there are infinitely many twists $d$ which are sums of two squares such that $E^d$ has rank $1$. This result is achieved using moments of derivatives of modular $L$-functions, and particularly captures the lower derivatives which were left out in the work of Munshi. Such a result, in particular, also gives us information on the elliptic fibration $(1+t^2)y^2=f(x)$, where $f(x)$ is a cubic polynomial.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0023",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13000v1",
    "status": "available",
    "timestamp": "2026-07-15T13:25:37.164415+00:00",
    "title": "ArXiv paper: Ranks of Elliptic Curves Twisted by Quadratic Forms"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A Note on Iterated Beatty Sequences' and formalize its key results. Abstract: For any irrational number $ \u03b1>\\frac{3+\\sqrt{5}}{2}\\approx2.618$ and given a positive $ n\\in\\mathbb{N} $, we use elementary number theory to introduce a necessary and sufficient condition for a natural number $ x $ to be in the $n$th iterate of the Beatty sequence of modulus $\u03b1$.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0024",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12817v1",
    "status": "available",
    "timestamp": "2026-07-15T13:43:17.002908+00:00",
    "title": "ArXiv paper: A Note on Iterated Beatty Sequences"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A Proof of Sundaram's Bounded-Interval Higher Lie Positivity Conjecture' and formalize its key results. Abstract: For positive integers $n$ and $M$, Sundaram defined $ F_{n,M}=\\sum_{\\substack{d\\mid n\\\\d\\le M}} Lie_{n/d}[p_d] $ and conjectured that every coefficient in its Schur expansion is a nonnegative integer. We prove the conjecture. The power-sum expansion isolates the contribution of the identity class, and the proof divides Young diagrams at the intrinsic majority threshold. If the first row or first column contains more than half of the boxes, the Bernstein creation formula separates each rectangular-cycle character value into a hook constant and a remainder supported only on short cycles. The restrictions of the trivial and sign characters to the cyclic subgroup evaluate the constants exactly, whereas a uniform binomial contraction controls every distance from the boundary at once. If neither a row nor a column has a majority, Swanson's opposite-hook estimate gives a Catalan-scale lower bound for the dimension. The Fomin--Lulov rectangular-character estimate, together with uniform bounds ",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0025",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12749v1",
    "status": "available",
    "timestamp": "2026-07-15T14:01:07.150782+00:00",
    "title": "ArXiv paper: A Proof of Sundaram's Bounded-Interval Higher Lie Positivity Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A universal leading-residue formula for Witten zeta functions' and formalize its key results. Abstract: Let $\u03a6$ be an irreducible crystallographic root system of rank $r$, with Coxeter number $h$, Weyl group $W$, Cartan matrix $C_\u03a6$, and invariant degrees $2=d_1\\leq\\cdots\\leq d_r=h$. We prove that Au's normalized Witten zeta function $\u03be_\u03a6(s)$ has a simple pole at $s=2/h$, with residue $\\mathop{\\rm Res}_{s=2/h}\u03be_\u03a6(s)=\\frac{2(2\u03c0)^{r/2}\\sqrt{\\det C_\u03a6}}{h|W|}\\frac{\\prod_{i=1}^{r-1}\u0393(1-d_i/h)}{\u0393(1-1/h)^r}$. The proof identifies the leading lattice coefficient with a convergent spherical Coxeter-discriminant integral at the critical exponent and evaluates this integral using the boundary pole of the Macdonald--Mehta--Opdam identity. Proper parabolic strata are shown to be strictly subcritical. This establishes Au's gamma-product-shape conjecture and his prediction in type $A_4$. We also obtain a direct, non-Tauberian asymptotic, with an explicit constant for every simple type, for the number of irreducible representations of dimension at most $X$.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0026",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12728v1",
    "status": "available",
    "timestamp": "2026-07-15T14:18:27.228044+00:00",
    "title": "ArXiv paper: A universal leading-residue formula for Witten zeta functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'M\u00f6bius functions for pseudo-Levi subgroups in finite general linear and symplectic groups' and formalize its key results. Abstract: In this paper, we compute the M\u00f6bius function on the set of pseudo-Levi subgroups containing a fixed maximal torus of two families of finite groups, $GL_n(q)$ and $Sp_{2n}(q)$, for some natural number $n$ and a prime power $q$. The M\u00f6bius function for the set of pseudo-Levi subgroups of a finite group $G$ is important for an explicit evaluation of the formula expressing the decomposition of tensor products of characters, as proved in Theorem 2 of the paper ''Multiplicity of characters of finite reductive groups and Drinfeld doubles'' [arXiv:2512.01432].",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0027",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12522v1",
    "status": "available",
    "timestamp": "2026-07-15T18:44:50.548049+00:00",
    "title": "ArXiv paper: M\u00f6bius functions for pseudo-Levi subgroups in finite general linear and symplectic groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On lower bounds for canonical heights of the map $\u03c6(X,Y)=(Y,X+Y^D+b)$' and formalize its key results. Abstract: We give a lower bound for the canonical height associated to H\u00e9non maps $\u03c6(X,Y)=(Y,X+Y^D+B)$ of non-periodic points when $D>2,$ extending previous work for $D=2$ in \\cite{Ingram1}.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0029",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12668v1",
    "status": "available",
    "timestamp": "2026-07-15T19:19:58.832974+00:00",
    "title": "ArXiv paper: On lower bounds for canonical heights of the map $\u03c6(X,Y)=(Y,X+Y^D+b)$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Solomon zeta functions over arithmetic orders' and formalize its key results. Abstract: We prove an effective version of Solomon's first conjecture for lattices over orders in finite-dimensional semisimple algebras over nonarchimedean local fields. We express the quotient of a partial Solomon zeta function by the corresponding maximal-order zeta function as a finite sum whose terms are determined by finite module-theoretic data and weighted by polynomials defined using the M\u00f6bius function of finite submodule posets. The resulting expression is independent of the chosen maximal overorder. Our proof is purely algebraic and is first formulated for the refined Bushnell--Reiner zeta functions. As an application, we obtain explicit formulas for the Solomon zeta functions of all lattices over $\\mathbb{Z}_p[\\mathbb{Z}/p\\mathbb{Z}]$, including non-projective lattices.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0030",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12302v1",
    "status": "available",
    "timestamp": "2026-07-15T19:37:22.083812+00:00",
    "title": "ArXiv paper: Solomon zeta functions over arithmetic orders"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Local statistics and average rank of genus $g$ hyperelliptic curves with a Weierstrass point' and formalize its key results. Abstract: In this paper, we determine the probability that a genus $g$ hyperelliptic curve with a Weierstrass point over a number field has good reduction at a given prime of residue characteristic $>2g+1$. We also obtain analogous probability formulas for several other reduction types, including cases with positive toric or unipotent rank. As an application, assuming the Hasse--Weil conjecture and the generalized Riemann hypothesis, we derive an explicit upper bound for the average analytic rank of genus $g$ hyperelliptic curves with a Weierstrass point.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0031",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12381v1",
    "status": "available",
    "timestamp": "2026-07-15T19:54:33.368042+00:00",
    "title": "ArXiv paper: Local statistics and average rank of genus $g$ hyperelliptic curves with a Weierstrass point"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Stable Limit DAHA of type $(C^{\\vee},C)$ and Stable Limit Koornwinder Polynomials' and formalize its key results. Abstract: We construct two stable limit representations of the double affine Hecke algebra of type $(C^\\vee,C)$ on the space of almost symmetric Laurent polynomials, namely the positive and negative stable limit representations. Starting from the standard polynomial representation of the finite rank DAHA of type $(C_n^\\vee,C_n)$, we study the asymptotic behavior of the Cherednik operators under the two natural rescalings by positive and negative powers of the parameter $t$. We prove that these rescaled Cherednik operators admit well-defined limits on the ring of almost symmetric Laurent polynomials. This yields stable positive and negative actions of a common stable limit DAHA. The action of the limit Cherednik operators is also proven to be triangular on a natural basis of almost symmetric Laurent polynomials labeled by tuple-partition symbols with respect to the induced Bruhat order. We further construct for each of the two stable limit representations a set of simultaneous eigenfunctions of t",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0032",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12276v1",
    "status": "available",
    "timestamp": "2026-07-15T20:11:34.288805+00:00",
    "title": "ArXiv paper: Stable Limit DAHA of type $(C^{\\vee},C)$ and Stable Limit Koornwinder Polynomials"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Odd Parts of Derivative Period Polynomials and a Logarithmic Transition Scale' and formalize its key results. Abstract: Let $f$ be a normalized level-one Hecke eigenform of even weight $k$, and let $Q_{f,m}$ be the period polynomial formed from the critical values of the $m$-th derivative of its completed $L$-function. We study the odd part $Q^-_{f,m}(z)=(Q_{f,m}(z)-Q_{f,m}(-z))/2$, retaining the zero at the origin forced by oddness. A unit-circle theorem for the full polynomial does not settle this problem: taking an odd part can create off-circle zeros even when the original polynomial has all of its zeros on the unit circle. We prove that there is an absolute $K_0$ such that, for every even $k\\ge K_0$, every normalized level-one Hecke eigenform $f$ of weight $k$, and every integer $m\\ge0$, the nonzero zeros of $Q^-_{f,m}$ off the unit circle, if any, form a single real reciprocal quartet $\\{\\pm b,\\pm b^{-1}\\}$ with $0<b<1$. For each fixed weight, all nonzero zeros are simple and lie on the unit circle once $m$ is sufficiently large. Hence any failure of the real-or-unit-circle containment is confined",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0033",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12378v1",
    "status": "available",
    "timestamp": "2026-07-15T20:28:24.578636+00:00",
    "title": "ArXiv paper: Odd Parts of Derivative Period Polynomials and a Logarithmic Transition Scale"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Cover numbers by graph families bounded by certain graph parameters' and formalize its key results. Abstract: The cover number of a graph by a graph class $\\mathcal P$ is the least number of $\\mathcal P$-graphs necessary to cover its edges. A classical theorem of Harary, Hsu and Miller gives an exact formula for the cover number by the class of graphs with chromatic number at most $k$. We investigate analogous questions for the case of the fractional chromatic number $\u03c7_f$ and the local chromatic number $\u03c8$. We prove that an analogous formula cannot hold in the case of the cover number by graphs of fractional chromatic number at most $\u03b2$, and find a lower and an upper bound, that gives rise to interesting asymptotic questions. We also investigate this cover number for small specific graphs. In the case of the cover number by graphs with local chromatic number at most $k$, we find an upper bound in terms of $\u03c8$, and a lower bound in terms of $\u03c9$.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0034",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12353v1",
    "status": "available",
    "timestamp": "2026-07-15T20:45:32.400264+00:00",
    "title": "ArXiv paper: Cover numbers by graph families bounded by certain graph parameters"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Kleber's conjecture and complementary products of symmetric functions' and formalize its key results. Abstract: We prove Kleber's rectangular-complement conjecture for Schur functions over an arbitrary commutative ring $R$, showing that, for a fixed rectangle, the products $s_\u03bbs_{\u03bb^\\vee}$, indexed by unordered complementary pairs, are linearly independent in $\u039b_R$. The proof rests on a general independence theorem for componentwise splittings, which asserts that for every partition $\u03b8$, the products $s_\u03b1s_\u03b2$ are linearly independent as $\\{\u03b1,\u03b2\\}$ ranges over unordered pairs of partitions satisfying $\u03b1+\u03b2=\u03b8$. The independence of the products $s_\u03bbs_{\u03bb^\\vee}$ also yields linear independence of the Koike--Terada universal-character products over any field, answering a question of Gao--Orelowitz--Yong. We also prove the analogous result for monomial symmetric functions over fields of characteristic zero, as well as integral linear independence over $\\mathbb{Z}$.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0035",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12120v1",
    "status": "available",
    "timestamp": "2026-07-15T21:02:35.937376+00:00",
    "title": "ArXiv paper: Kleber's conjecture and complementary products of symmetric functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper '$p$-adic Sum-Product, Projections, and Furstenberg Sets' and formalize its key results. Abstract: Let $p$ be a prime number. We prove the sharp Furstenberg set bound in the $p$-adic plane $\\mathbb{Q}_p^2$: every $(s,t)$-Furstenberg set $E\\subset\\mathbb{Q}_p^2$ satisfies $$ \\dim_H E\\ge \\min\\left\\{s+t,\\frac{3s+t}{2},s+1\\right\\}. $$ This matches the sharp lower bound in the Euclidean plane. We also derive two related consequences: a $p$-adic projection theorem for the maps $\u03c0_\u03b8(x,y)=x+\u03b8y$, together with the corresponding exceptional set estimate giving a $p$-adic analogue of Oberlin's projection question; and a discretized fractal sum-product estimate over $\\mathbb{Q}_p$, showing that sufficiently non-concentrated subsets of $\\mathbb{Z}_p^\\times$ cannot have both small sum set and small product set. The proof follows the projection-theoretic and multiscale machinery developed in the Euclidean works of Orponen-Shmerkin (arXiv:2301.10199) and Ren-Wang (arXiv:2308.08819). The main task is to rebuild this machinery in the non-archimedean setting, and along the way we develop several new $",
    "domains": [
      "Pythagorean",
      "Logic"
    ],
    "id": "fd_0036",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12251v1",
    "status": "available",
    "timestamp": "2026-07-15T21:19:59.269561+00:00",
    "title": "ArXiv paper: $p$-adic Sum-Product, Projections, and Furstenberg Sets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The chromatic number of 3-stable Kneser graphs' and formalize its key results. Abstract: For an integer $s \\ge 2$, a subset $S \\subseteq [n]$ is {\\em $s$-stable} if $\\min \\{j - i, n + i - j\\}\\ge s$ for every $i,j \\in S$ with $i<j$. Denote the set of all $s$-stable subsets of size $k$ of $[n]$ by $\\binom{[n]}{k}_{s\\text{-stable}}$. Schrijver proved in 1978 that whenever $n\\ge 2k$, the chromatic number of the Kneser graph $\\mathrm{KG}\\big( \\binom{[n]}{k}_{2\\text{-stable}}\\big)$ is $n - 2k +2$. Generalizing this result, Meunier conjectured in 2011 that $\u03c7\\left( \\mathrm{KG}\\big( \\binom{[n]}{k}_{s\\text{-stable}} \\big) \\right)= n - sk +s$ for all $n\\ge sk$. This conjecture was previously proven for all even $s$, for $s \\ge 4$ and large enough $n$, and for $k=2$. We prove the conjecture in the cases $s=3$ and $n$ large enough, or $k=s=3$. To this end, we prove versions of the Hilton-Milner theorem for $s$-stable sets. We also present a topological approach towards Meunier's conjecture.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0037",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12912v1",
    "status": "available",
    "timestamp": "2026-07-15T12:33:25.469761+00:00",
    "title": "ArXiv paper: The chromatic number of 3-stable Kneser graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The Balanced Four-Color Theorem' and formalize its key results. Abstract: We show that every planar graph with $n \\geq 3$ vertices admits a 4-coloring in which each color is used on fewer than $n/2$ vertices. This bound is the best possible. Moreover, such a coloring can be found in $O(n \\log n)$ time. We also extend these results to five or more colors and to graphs on general surfaces.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0038",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13025v1",
    "status": "available",
    "timestamp": "2026-07-15T12:51:18.212379+00:00",
    "title": "ArXiv paper: The Balanced Four-Color Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Claw-free cubic graphs and zero forcing' and formalize its key results. Abstract: A claw-free cubic graph is a cubic graph with no induced subgraph isomorphic to $K_{1,3}$. The zero forcing process begins with an initial set $S$ of colored vertices. At each step, a colored vertex with exactly one uncolored neighbor forces that neighbor to become colored. If repeated applications of this rule color every vertex of $G$, then $S$ is called a zero forcing set. The minimum cardinality of a zero forcing set is the zero forcing number, denoted by $Z(G)$. In this paper, we answer three open questions posed by Davila and Henning concerning upper bounds on the zero forcing number of claw-free cubic graphs. We characterize the connected claw-free cubic graphs satisfying $Z(G)=\u03b1(G)+1$, where $\u03b1(G)$ is the independence number. In addition, we establish the improved upper bound $Z(G)\\leq \\frac{T}{2}+D+2$ for claw-free cubic graphs with Hamiltonian contraction multigraphs, where $D$ is the number of diamonds and $T$ is the number of triangles in $G$.",
    "domains": [
      "Physics"
    ],
    "id": "fd_0039",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12890v1",
    "status": "available",
    "timestamp": "2026-07-15T13:08:25.917501+00:00",
    "title": "ArXiv paper: Claw-free cubic graphs and zero forcing"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Record compositions of alternating permutations and noncommutative symmetric functions' and formalize its key results. Abstract: Amdeberhan, Shareshian, and Stanley recently proved that a function $\\varphi$ arising in the theory of partition Eisenstein series counts the alternating permutations of $\\{1,\\dots,2n\\}$ with a given `record' partition, and they asked whether there is a similar theory for record compositions, suggesting a role for noncommutative symmetric functions. Here we solve their open problem by showing that the number of alternating permutations of $\\{1,\\dots,2n\\}$ with record composition $(\u03b1_1,\\dots,\u03b1_\\ell)$ is \\[ \\prod_{j=1}^{\\ell}\\binom{2s_j-1}{2\u03b1_j-1}E_{2\u03b1_j-1}, \\] where $s_j=\u03b1_1+\\dots+\u03b1_j$, $E_k$ is an Euler number, and the record composition of $w=a_1a_2\\dots a_{2n}$ (so $a_1>a_2<a_3>\\dotsb$) lists the factor lengths obtained by cutting $a_1a_3\\dots a_{2n-1}$ before each left-to-right maximum other than the first. These numbers are the coefficients of a natural lift of the degree-$n$ sprout symmetric function with seed $\\sec(\\sqrt{t}\\,)$ to noncommutative symmetric functions, expanded in p",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0040",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12873v1",
    "status": "available",
    "timestamp": "2026-07-15T13:25:40.671949+00:00",
    "title": "ArXiv paper: Record compositions of alternating permutations and noncommutative symmetric functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On Agreement Subtrees in Multiple Pylogenetic Trees' and formalize its key results. Abstract: Snir and Yuster [Discrete Appl. Math. 347 (2026) 160--171] asked for the least number $h(k)$ such that $k$ unrooted binary phylogenetic trees on the same $h(k)$ leaves always share a common quartet. We give a new upper bound for the $k$-tree version of the Maximum Agreement Subtree problem, namely an upper bound for the number of leaves, on which $k$ unrooted binary phylogenetic trees always share a common induced binary subtree on $n$ leaves, which is a four-times iterated exponential function. For $h(k)$, this implies a four-times iterated exponential upper bound. We also set an exponential lower bound for $h(k)$.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0041",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12778v1",
    "status": "available",
    "timestamp": "2026-07-15T13:43:20.804355+00:00",
    "title": "ArXiv paper: On Agreement Subtrees in Multiple Pylogenetic Trees"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Genus and Gonality of Small Curves, Dynamical Uniform Boundedness, and Bifurcation' and formalize its key results. Abstract: We prove the Gonality Conjecture in arithmetic dynamics: for any non-isotrivial one-parameter algebraic family of rational maps on $\\mathbb{P}^1$, the gonality of distinct dynatomic curves tends to infinity. More generally, outside the flexible Latt\u00e8s family, every small sequence of horizontal curves has gonality tending to infinity, and its genus grows superlinearly with its degree over the parameter curve. We also obtain higher-dimensional analogues under natural bifurcation and multiplier-genericity hypotheses. As applications, we prove uniform boundedness results for iterated preimages over number fields and geometric uniform boundedness results for preperiodic points over function fields. The proof combines arithmetic equidistribution, woven currents, and bifurcation theory; the bifurcation mechanism is what forces the growth of genus and gonality.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0042",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12561v1",
    "status": "available",
    "timestamp": "2026-07-15T14:01:10.734967+00:00",
    "title": "ArXiv paper: Genus and Gonality of Small Curves, Dynamical Uniform Boundedness, and Bifurcation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Euler systems and the symmetric square of a Hida family' and formalize its key results. Abstract: Let $p\\geq7$ be a prime number. We build a non-trivial Euler system for the symmetric square of a $p$-adic Hida family of modular forms interpolating the Euler system constructed by Loeffler-Zerbes for the symmetric square of a $p$-ordinary newform. As a second contribution, we prove an algebraic functional equation for dual Selmer groups in this setting. Finally, building on recent work by B\u00fcy\u00fckboduk-Ganguly on functional equations of algebraic (Rankin-Selberg) $p$-adic $L$-functions, we prove a divisibility result towards the Iwasawa main conjecture for the symmetric square of a Hida family.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0043",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12679v1",
    "status": "available",
    "timestamp": "2026-07-15T14:18:31.029430+00:00",
    "title": "ArXiv paper: Euler systems and the symmetric square of a Hida family"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Local flag algebras' and formalize its key results. Abstract: We introduce local flag algebras, a variant of Razborov's flag algebra framework in which densities are normalised by the maximum degree $\u0394(G)$ rather than the order $|G|$. The framework supports the same semidefinite-method machinery as the classical version, but is tailored to extremal problems that scale with the maximum degree. As an illustrative first application we bound the number of pentagons in a triangle-free graph $G$ as a function of $|G|$ and $\u0394(G)$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0045",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12461v1",
    "status": "available",
    "timestamp": "2026-07-15T19:02:55.300737+00:00",
    "title": "ArXiv paper: Local flag algebras"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Recursive Formula for the Equations of Hessenberg Varieties' and formalize its key results. Abstract: Hessenberg varieties are subvarieties of the flag variety, defined by containment conditions on flags with respect to a linear operator. The study of these varieties lies in the intersection of algebraic geometry, combinatorics, and representation theory. In this paper, we develop an algebro-geometric procedure for determining the closed subvariety structure of a Hessenberg variety $\\mathcal{H}(X,h)$ in the flag variety for any linear operator $X$ and Hessenberg function $h$, by imposing a partial order on the Hessenberg functions and analyzing the relation of the corresponding Hessenberg varieties. In particular, we give a concrete recursive formula for determining all equations cutting out a given Hessenberg variety in each Schubert cell. As an application, we provide an alternative geometric proof of Tymoczko's results on the existence of affine pavings of a given Hessenberg variety and on the dimension count of its cells.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0047",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12261v1",
    "status": "available",
    "timestamp": "2026-07-15T19:37:25.793116+00:00",
    "title": "ArXiv paper: Recursive Formula for the Equations of Hessenberg Varieties"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper '$k$-Convex Polyominoes by Semi-perimeter' and formalize its key results. Abstract: We give the conjectured solution for the generating function of $k$-convex polyominoes, enumerated by semi-perimeter. The solution was obtained from the analysis of enumeration data that we generated.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0049",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12448v1",
    "status": "available",
    "timestamp": "2026-07-15T20:11:38.048996+00:00",
    "title": "ArXiv paper: $k$-Convex Polyominoes by Semi-perimeter"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Coloring $(P_6,C_4)$-free graphs with $\u0394- 1$ colors' and formalize its key results. Abstract: For a graph $G$, let $\u0394(G)$, $\u03c9(G)$, and $\u03c7(G)$ denote the maximum degree, clique number, and chromatic number of $G$, respectively. Let $P_n$ and $C_n$ denote the chordless path and chordless cycle on $n$ vertices, respectively. In this paper, we prove that every $(P_6,C_4)$-free graph $G$ with $\u0394(G)\\ge 9$ and $\u03c9(G)<\u0394(G)$ is $(\u0394(G)-1)$-colorable.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0050",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12367v1",
    "status": "available",
    "timestamp": "2026-07-15T20:28:28.169396+00:00",
    "title": "ArXiv paper: Coloring $(P_6,C_4)$-free graphs with $\u0394- 1$ colors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Curious identities involving Legendre polynomials and Ap\u00e9ry-like numbers' and formalize its key results. Abstract: In this paper, we establish some curious identities involving Legendre polynomials and the first kind of Ap\u00e9ry-like numbers. As applications, many new supercongruences are deduced.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0051",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12330v1",
    "status": "available",
    "timestamp": "2026-07-15T20:45:36.266548+00:00",
    "title": "ArXiv paper: Curious identities involving Legendre polynomials and Ap\u00e9ry-like numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On Transformer Dynamics' and formalize its key results. Abstract: We develop a geometric framework in which the token dynamics of a transformer are modeled by a system of interacting particles on a Riemannian manifold $\\mathcal M$, the attention mechanism being encoded by a time-independent two-body interaction law, that is, a section of the pullback bundle $\u03c0_2^{*}(T\\mathcal M)$ over $\\mathcal M\\times\\mathcal M$. Within this framework we isolate two features that a family of interaction laws must possess in order to model language: it must realize generic nonlocal and nonreciprocal forces, and it must parametrize vector fields on a high-dimensional manifold efficiently. We show that both features are achieved simultaneously in a transformer model. Our main theorem produces a finitely parametrized family of interaction laws, independent of the manifold and of its dimension, that is universal: it realizes an arbitrary prescribed attention digraph. Moreover, we show that the cost of realizing a given attention digraph is governed not by $\\dim\\mathcal M",
    "domains": [
      "Geometry",
      "MachineLearning"
    ],
    "id": "fd_0054",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13295v1",
    "status": "available",
    "timestamp": "2026-07-16T02:44:23.384751+00:00",
    "title": "ArXiv paper: On Transformer Dynamics"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Construction of Generalized Weighing-Hadamard Matrices over Finite Fields' and formalize its key results. Abstract: The existence, several properties, and constructions of Generalized Weighing-Hadamard (GWH) matrices over finite fields are addressed in this work. We study the subset of invertible GWH matrices and show that it forms a group under matrix multiplication. Besides that, we introduce a strong notion of equivalence between such matrices, defined via orthogonal transformations, and further prove that the corresponding quotient group by the subgroup of orthogonal matrices is abelian. Finally, we discuss some applications of these matrices in coding theory",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0055",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13324v1",
    "status": "available",
    "timestamp": "2026-07-16T03:01:47.233586+00:00",
    "title": "ArXiv paper: Construction of Generalized Weighing-Hadamard Matrices over Finite Fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On the Second Moment of $ L (1/2, \\mathrm{As}(f) \\times \u03c6)$' and formalize its key results. Abstract: Let $\\mathbf{F} = \\mathbf{Q}(\\sqrt D)$ be a real quadratic field. In this paper, we establish a large sieve inequality for the Asai lifts $ \\mathrm{As} (f) $ with $f$ in a Hecke orthonormal basis of the space of Hilbert modular cusp forms of parallel weight $(k, k)$ over $ \\mathbf{F} $. As an application, for a fixed Hecke--Maass cusp form $\u03c6$ over $\\mathbf{Q}$, we prove a non-trivial bound for the second moment of the convoluted central $L$-values $ L (1/2, \\mathrm{As}(f) \\times \u03c6) $ in the $k$-aspect.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0056",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13484v1",
    "status": "available",
    "timestamp": "2026-07-16T03:19:02.464129+00:00",
    "title": "ArXiv paper: On the Second Moment of $ L (1/2, \\mathrm{As}(f) \\times \u03c6)$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Domination-packing ratio for planar and unit disk graphs' and formalize its key results. Abstract: The domination number $\u03b3(G)$ of a graph $G$ is the smallest possible size of a vertex set that intersects every radius-$1$ ball of $G$, and the packing number $\u03c1(G)$ is the maximum number of pairwise vertex-disjoint radius-$1$ balls. We prove that $\\frac{\u03b3(G)}{\u03c1(G)}\\le 5$ for every planar graph and $\\frac{\u03b3(G)}{\u03c1(G)} \\le \\frac{18\\sqrt3}\u03c0\\approx 9.924$ for every unit disk graph, thus yielding Erd\u0151s-P\u00f3sa-type bounds for the hypergraph of radius-$1$ balls in the two graph classes. This improves upon results of Guti\u00e9rrez and Paul, and D\u00facz and Gujgiczer, who in turn lowered bounds of Bonamy, Csik\u00f3s, Gujgiczer and Yuditsky, and B\u00f6hme and Mohar. For both graph classes, the best known lower bound on the optimal constant remains $3$.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0057",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13424v1",
    "status": "available",
    "timestamp": "2026-07-16T03:36:34.295975+00:00",
    "title": "ArXiv paper: Domination-packing ratio for planar and unit disk graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Study on Morgan-Voyce type polynomials with Euler-Seidel algorithm' and formalize its key results. Abstract: This paper bridges the domains of degenerate special polynomials, the Euler-Seidel matrix method, and Morgan-Voyce polynomials. We introduce two new families of Morgan-Voyce type polynomials and establish their structural properties, including explicit formulas and recurrence relations. Additionally, we define three polynomial variants and prove that three distinct binomial-type sums for Bell polynomials can be expressed as finite sums involving these new families, and derive their exponential generating functions. We then construct Euler-Seidel matrices using the initial sequences associated with Morgan-type polynomials. Our results yield novel algebraic identities and expand the application of matrix methods in combinatorial analysis.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0058",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13489v1",
    "status": "available",
    "timestamp": "2026-07-16T03:54:03.706665+00:00",
    "title": "ArXiv paper: Study on Morgan-Voyce type polynomials with Euler-Seidel algorithm"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Interchange graphs of (0,1)-matrices are maximally Hamiltonian' and formalize its key results. Abstract: For integer vectors R,S let A(R,S) denote the class of (0,1)-matrices with row sum vector R and column sum vector S. Its interchange graph G(R,S) has A(R,S) as its vertex set, two matrices being adjacent when they differ by a single 2 x 2 interchange. Brualdi conjectured that G(R,S) is Hamiltonian for every R,S. We prove the stronger statement that G(R,S) is maximally Hamiltonian: Hamilton-laceable when bipartite, and Hamilton-connected when not. The proof is a structural induction on the number of matrices in the class, organized by the structure theory of interchange graphs. Deleting inactive lines and splitting invariant positions expresses any class as a Cartesian product, reducing the argument to the prime factors. The bipartite classes are products of complete transposition graphs; we settle them together, without induction, by proving they are paired 2-disjoint-path-coverable and hence Hamilton-laceable, using a recent theorem of Coleman, Fischberg, Gong, Harrington and Wong on ",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0059",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13165v1",
    "status": "available",
    "timestamp": "2026-07-16T04:10:50.473848+00:00",
    "title": "ArXiv paper: Interchange graphs of (0,1)-matrices are maximally Hamiltonian"
  },
  {
    "consumed_by_exp_id": "cca295e6",
    "description": "Investigate the ArXiv paper 'Second Order Differential Operators on Graphs' and formalize its key results. Abstract: The commutator of a pair of vector fields on a graph is not a vector field in general, but rather a second order differential operator. We investigate this departure from the classical case of vectors fields on a manifold by examining the geometry of balls of radius two, concentrating on the set of paths of length two connecting a given vertex with the center of the ball. There is a natural surjection from the space of sections of the second tangent bundle to the space of second order differential operators whose kernel reflects the geometry of these balls. Using this map we draw several conclusions about second order differential operators including canonical forms, formulas for their adjoints, and a necessary and sufficient condition for a commutator to be a vector field.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0060",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13266v1",
    "status": "in_progress",
    "timestamp": "2026-07-16T04:27:11.074404+00:00",
    "title": "ArXiv paper: Second Order Differential Operators on Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The Action of the Lie Algebra $\\mathfrak{sl}_n$ on Colored Graphs and Multicolored Johnson Graphs' and formalize its key results. Abstract: We consider the space of $(n-1)$-colored graphs on a fixed set of $N$ vertices. Each edge position of the complete graph $K_N$ has $n$ possible states: the absence of an edge and $n-1$ colors. This gives a natural identification of the space of such graphs with the tensor power $(\\mathbb C^n)^{\\otimes m}$, where $m=\\binom N2$, and defines on it the diagonal action of the Lie algebra $\\mathfrak{gl}_n$, and, after restriction, the action of $\\mathfrak{sl}_n$. For a fixed profile $\u03b1=(\u03b1_0,\\dots,\u03b1_{n-1})$, we consider the graph $J(m;\u03b1)$ whose vertices are colored graphs of this profile and whose adjacency is defined by a single exchange of states in two edge positions. This graph is the transposition graph on the set of words with fixed profile, also known as the \\emph{multislice}. The main result is an expression of the adjacency operator in terms of the root operators of $\\mathfrak{sl}_n$ and a derivation of its spectrum by means of the quadratic Casimir operator of $\\mathfrak{gl}_n$ and ",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0061",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13208v1",
    "status": "available",
    "timestamp": "2026-07-16T04:43:19.470707+00:00",
    "title": "ArXiv paper: The Action of the Lie Algebra $\\mathfrak{sl}_n$ on Colored Graphs and Multicolored Johnson Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Reproducing the k-copwin Algorithm: Theory vs. Implementation' and formalize its key results. Abstract: Cops and Robbers is a well-studied pursuit-evasion game that provides insights into graph theory and theoretical computing. A central question is determining the minimum number of cops required to capture the robber, known as the cop number. We focus on reproducing an algorithm proposed by Petr, Portier, and Versteegen in 2022, which efficiently determines whether a graph is $k$-copwin. This paper presents a Python implementation of the $k$-copwin algorithm. In this work, we present our implementation in detail, clarify key aspects of the algorithm, and discuss its implications for future practical deployments.",
    "domains": [
      "Computation"
    ],
    "id": "fd_0062",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13271v1",
    "status": "available",
    "timestamp": "2026-07-16T04:59:07.834459+00:00",
    "title": "ArXiv paper: Reproducing the k-copwin Algorithm: Theory vs. Implementation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A minimal modularity lifting theorem for Siegel modular forms' and formalize its key results. Abstract: We prove a minimal modularity lifting theorem (in the spirit of Genestier--Tilouine and Pilloni) in the setting of Siegel modular forms of genus two when the residual representation arises from a stable Yoshida lift, that is, an automorphic induction of a nearly ordinary Hilbert modular eigencuspform over a real quadratic field. As applications of the underlying $R=\\mathbb{T}$ theorem, we establish the freeness of a universal minimal ordinary Galois deformation ring over an Iwasawa algebra in two variables along with the uniqueness of Hida families passing through classical $p$-ordinary Siegel modular eigenforms with very regular weights.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0063",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13100v1",
    "status": "available",
    "timestamp": "2026-07-16T05:15:40.425312+00:00",
    "title": "ArXiv paper: A minimal modularity lifting theorem for Siegel modular forms"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Torsion groups of rational elliptic curves over $\\mathbb{Z}_p$-extensions of quadratic fields: the $p\\le 5$ case' and formalize its key results. Abstract: Let $E$ be a rational elliptic curve. We generalize a theorem due to Avc\u0131\\cite{AVCI2026153}, which asserts that for any quadratic field \\(K\\) and prime \\(p>5\\), the equality \\(E(K)_{\\mathrm{tors}} = E(L)_{\\mathrm{tors}}\\) holds for every \\(\\mathbb{Z}_p\\)-extension \\(L/K\\). In this paper, we consider the setting where the \\(\\mathbb{Z}_p\\)-extension \\(L\\) is replaced by the compositum \\(K_{\\infty}\\) of all \\(\\mathbb{Z}_p\\)-extensions of \\(K\\). Under this new setting, we prove the analogous statement for \\(p=5\\), and further provide partial results for the remaining primes \\(p=3\\) and \\(p=2\\).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0064",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13514v1",
    "status": "available",
    "timestamp": "2026-07-16T02:44:27.391016+00:00",
    "title": "ArXiv paper: Torsion groups of rational elliptic curves over $\\mathbb{Z}_p$-extensions of quadratic fields: the $p\\le 5$ case"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Further thoughts on dimensions of posets' and formalize its key results. Abstract: We recall the concept of the dimension of a finite poset $P$, and the longstanding conjecture that for all finite nonempty posets $P$ and $Q$, $\\dim(P\\times Q)\\geq\\dim(P)+\\dim(Q)-2.$ We then note two other plausible inequalities, either of which would imply that one. In the final section, writing $P\\preccurlyeq P'$ if, for all $Q,$ $\\dim(P\\times Q)\\leq\\dim(P'\\times Q),$ and writing $P\\approx P'$ if $P\\preccurlyeq P'$ and $P'\\preccurlyeq P,$ we note some results and questions concerning these relations.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0065",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13385v1",
    "status": "available",
    "timestamp": "2026-07-16T03:01:50.863415+00:00",
    "title": "ArXiv paper: Further thoughts on dimensions of posets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Periodicities in the Riordan arrays of polynomials over finite fields' and formalize its key results. Abstract: We study periodicity properties of the 2-D $\\bigl(p_1(t)/p_2(t),\\, tp_3(t)\\bigr)$ and 3-D $\\bigl(p_1(t)/p_2(t),\\, tp_3(t),\\, p_4(t)\\bigr)$ Riordan arrays over a finite field ${\\mathbb F}_q$, where each $p_i(t)$ is a polynomial with $p_i(0)\\neq 0$. We show that the columns of the 2-D Riordan array are eventually periodic sequences, where a circulant matrix generated by the coefficients of $p_3(t)$ determines the behavior of this periodicity as the column index grows indefinitely. Furthermore, we prove that the preperiodic column partial sums of the 2-D array are periodic, and present a family of the Riordan arrays for which such sequences of partial sums are identically zero. We also show that the layers of the 3-D Riordan array contain periodic orbits related to each other via powers of a circulant matrix generated by the coefficients of $p_4(t)$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0066",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13442v1",
    "status": "available",
    "timestamp": "2026-07-16T03:19:07.278546+00:00",
    "title": "ArXiv paper: Periodicities in the Riordan arrays of polynomials over finite fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On the Second Moment of $L (1/2, \\mathrm{As} (f))$' and formalize its key results. Abstract: Let $\\mathbf{F}$ be a real quadratic field. Let $f $ traverse a Hecke orthonormal basis of Hilbert cusp forms over $ \\mathbf{F} $ of full level and parallel weight $(k,k)$. As $k \\rightarrow \\infty$, we prove an asymptotic formula for the second moment of central Asai $L$-values $L (1/2, \\mathrm{As} (f))$: \\begin{equation*} {\\sum}_{f } \\, \u03c9_f L(1/2,\\mathrm{As}(f))^2 = P_3 ( \\log {k } ) k^2 + O_{\\mathbf{F},\\varepsilon} (k^{3/2 + \\varepsilon} ), \\end{equation*} where $\u03c9_f$ are the harmonic weights and $P_3 (X)$ is an explicit polynomial of degree $3$. This refines the mean Lindel\u00f6f bound $ O_{\\mathbf{F},\\varepsilon} (k^{2 + \\varepsilon} ) $ proved by Wenzhi Luo.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0067",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13490v1",
    "status": "available",
    "timestamp": "2026-07-16T03:36:37.823776+00:00",
    "title": "ArXiv paper: On the Second Moment of $L (1/2, \\mathrm{As} (f))$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On the Wiener and Harary Indices of Generalized Splitting and Shadow-Splitting Graphs' and formalize its key results. Abstract: In this paper, we determine the Wiener index and the Harary index for the $(p,q)$-generalized splitting graph $S_{p,q}(G)$ and the $(c,k)$-shadow-splitting graph $H_{c,k}(G)$ for a connected graph $G$.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0068",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13488v1",
    "status": "available",
    "timestamp": "2026-07-16T03:54:07.078921+00:00",
    "title": "ArXiv paper: On the Wiener and Harary Indices of Generalized Splitting and Shadow-Splitting Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Quantum determinants in polynomial time' and formalize its key results. Abstract: We give an algebraic branching program of polynomial size which computes Cayley determinant of right quantum matrices. This is a rare example of an efficient computation of a noncommutative determinant, and the first such example for quantum groups. We extend the results to the $q$-Cayley determinant of $q$-right quantum matrices, as well as to their multiparameter generalization. The proofs are entirely combinatorial, as we relate Cayley, Moore and Valiant determinants using bijections/involutions on words. We then employ the celebrated determinant construction of Mahajan and Vinay (SODA'97), to obtain the results.",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0069",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13186v1",
    "status": "available",
    "timestamp": "2026-07-16T04:10:55.100427+00:00",
    "title": "ArXiv paper: Quantum determinants in polynomial time"
  },
  {
    "consumed_by_exp_id": "aa7167bb",
    "description": "Investigate the ArXiv paper 'Graph Puzzles III.1: A Proof of Sabidussi's Compatibility Conjecture' and formalize its key results. Abstract: We prove Sabidussi's compatibility conjecture. Let $G$ be a finite connected multigraph in which every vertex has even degree and the minimum degree is at least four, and let $T$ be a closed trail that traverses every edge exactly once. The edges of $G$ can be partitioned into circuits (connected 2-regular subgraphs) so that no circuit contains the two edges used consecutively anywhere in $T$. In fact, the edges can be four-coloured so that every such pair receives two different colours and the subgraph formed by the edges of each colour has even degree at every vertex. Formalization in Lean 4 is also available in the author's github.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0070",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13225v1",
    "status": "in_progress",
    "timestamp": "2026-07-16T04:27:14.823265+00:00",
    "title": "ArXiv paper: Graph Puzzles III.1: A Proof of Sabidussi's Compatibility Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On some structural properties of graphs with non-negative resistance curvature' and formalize its key results. Abstract: A graph is called resistance nonnegative (RN), respectively resistance positive (RP), if it admits positive edge weights such that all vertex resistance curvatures are nonnegative, respectively positive. In this paper, we study the structure of RN and RP graphs in relation to toughness, traceability, and Cartesian products. First, we disprove a conjecture of Fiedler and answer a question of Devriendt in the negative by constructing, for every $n\\ge 11$, an $n$-vertex $1$-tough graph that is not RN. Second, we show that RP graphs need not be traceable by proving that the Thomassen $34$-graph is RP but not traceable. Finally, we resolve a conjecture of Devriendt on grid graphs by proving that all Cartesian products of paths are RN.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0071",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13169v1",
    "status": "available",
    "timestamp": "2026-07-16T04:43:23.081658+00:00",
    "title": "ArXiv paper: On some structural properties of graphs with non-negative resistance curvature"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Beyond Mock Modularity: Elliptic Corrections for Higher Dyson Ranks' and formalize its key results. Abstract: When $m = 1$, the Dyson rank generating function is a classical bridge between partition theory, Ramanujan's mock theta functions, and the theory of harmonic Maass forms and nonholomorphic Jacobi forms. The rank is a statistic on partitions, and the higher Dyson systems, for $m \\geq 2$, are a natural multivariable refinement of it, combining $m$ graded rank contributions. Unlike the classical case, these higher systems are not expected to fit the mock-modular framework, which raises the question of what analytic structure governs them. We show that their root-of-unity specializations carry a hidden elliptic structure. A finite $q$-difference recurrence produces an explicit polynomial obstruction to the expected index $m$ elliptic transformation law, and because the obstruction is finite, its partial fractions canonically determine finitely many Appell--Lerch correction terms that remove it. The corrected functions satisfy a twisted index $m$ elliptic law; a natural translation removes ",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0072",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13159v1",
    "status": "available",
    "timestamp": "2026-07-16T04:59:11.546572+00:00",
    "title": "ArXiv paper: Beyond Mock Modularity: Elliptic Corrections for Higher Dyson Ranks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n## 1. Robust local encodings of arithmetic derivations\n\n**Conjecture.** There is an explicit encoding of every finite Peano-arithmetic derivation into a locally testable object such that any string that is not an encoding of a valid derivation fails a fixed positive fraction of constant-query tests, with encoding length polynomial in the derivation length.\n\nThe key insight is that random checking amplifies efficiently only after inconsistency has been spread across a constant fraction of local views; a raw derivation with one bad line has no such robustness.\n\n**Why now?** The exact single-counterexample bound isolates robustness, rather than repetition, as the missing resource and gives a quantitative benchmark against which candidate encodings can be tested.\n\n## 2. Zero-knowledge local tests with dependency closure\n\n**Conjecture.** Every constant-query locally testable proof relation whose queries have bounded dependency closure admits a perfectly hiding commitment-and-opening protocol in which the joint opened view is simulatable from the truth value of the tested constraint alone.\n\nThe key insight is that masking individual symbols is insufficient when local constraints correlate several openings; simulation must respect the entire dependency-closed view.\n\n**Why now?** Perfect hiding for one additive symbol is exact, so the next falsifiable step is to characterize precisely when this equality of distributions survives correlated multi-symbol openings.\n\n## 3. Communication lower bounds for statement-length-only certification\n\n**Conjecture.** For some family of arithmetical sentences with short statements and arbitrarily large minimal derivations, every statistically sound interactive protocol whose verifier checks only authenticated raw derivation lines requires communication growing with the minimal derivation length.\n\nThe key insight is that a single corrupted location is detected with probability only the reciprocal of the proof length, and authentication does not increase that detection probability.\n\n**Why now?** The geometric error law supplies a sharp finite obstruction to the proposed raw-line protocol and suggests a route to a general lower bound through adversarially sparse defects.\n\n## 4. Perfect zero knowledge for propositional validity under structural restrictions\n\n**Conjecture.** Propositional formulas of bounded treewidth admit perfect zero-knowledge validity protocols with communication polynomial in the formula size and logarithmic in the inverse soundness error.\n\nThe key insight is that bounded treewidth turns global validity into compatible local constraints while finite-group masking can hide the local dynamic-programming states.\n\n**Why now?** Truth-table checking establishes the soundness and simulation primitives separately; bounded-width decompositions offer a concrete setting in which to compose them without an exponential challenge space.\n\n## 5. Geometric gluing of local transcript simulators\n\n**Conjecture.** A family of local transcript distributions indexed by proof constraints admits a global perfect simulator exactly when the distributions agree on every overlap and satisfy a finite acyclicity condition on the constraint hypergraph.\n\nThe key insight is that zero knowledge under many openings is a gluing problem: pairwise perfect hiding does not automatically produce a consistent global distribution.\n\n**Why now?** The additive one-symbol simulator provides the local model, while dependency-closed challenges identify overlaps where compatibility can fail; acyclic hypergraphs are the first nontrivial test class.\n",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_0078",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "573ee086",
    "status": "available",
    "timestamp": "2026-07-16T05:30:46.208428+00:00",
    "title": "**Conjecture.** There is an explicit encoding of every finite Peano-arithmetic d"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence Maximal number of \"good\" manifolds in an n-nice polytope. with terms 6,8,12,24,40,80,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,20971. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0010",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:212351",
    "status": "available",
    "timestamp": "2026-07-15T05:23:22.329230+00:00",
    "title": "OEIS sequence: Maximal number of \"good\" manifolds in an n-nice polytope."
  }
];
