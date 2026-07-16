

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0088",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:48:19.729246+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0085",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:48:19.703748+00:00",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0086",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:48:19.711039+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0087",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:48:19.720259+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "id": "fd_0089",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-16T05:48:19.737842+00:00",
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
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'From roots to paths: graphs simultaneously irregular with respect to rooted and ordinary paths' and formalize its key results. Abstract: Let $P_n$ denote a path on $n$ vertices. A simple finite graph $G$ is called $P_n$-irregular if any two distinct vertices of $G$ belong to a different number of subgraphs of $G$ isomorphic to $P_n$. Alternatively, for a fixed vertex $r$ of $P_n$ (the root), $G$ is called $(P_n)_r$-irregular if any two distinct vertices of $G$ act as the root $r$ in a different number of subgraphs of $G$ isomorphic to $P_n$. This paper proves that for each integer $k \\geq 4$, there exists an infinite family of graphs that are simultaneously $P_n$-irregular and $(P_n)_r$-irregular for every integer $n$ satisfying $4 \\leq n \\leq k$ and every root $r$ of $P_n$. For the path $P_3$, we observe that no nontrivial $(P_3)_r$-irregular graphs exist if $r$ is the central vertex. In contrast, if $r$ is an end-vertex of $P_3$, an infinite collection of graphs is constructed that are both $P_3$-irregular and $(P_3)_r$-irregular. In particular, these results confirm the Strong Conjecture about $F$-irregular graphs fo",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0009",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11700v1",
    "status": "available",
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
    "description": "Investigate the ArXiv paper 'Superlinear complexity of the $(3/2)^n$ steering word' and formalize its key results. Abstract: Write $(3/2)^n = m_n + \\eps_n$ with $m_n$ the nearest integer and $\\eps_n\\in[-\\tfrac12,\\tfrac12)$, and let $T=(t_n)$, $t_n=2m_{n+1}-3m_n$, be the resulting \\emph{steering word}: the step-by-step record of the map $x\\mapsto\\tfrac32 x$ on the orbit of $1$, coded by nearest-integer rounding. Using results by Corvaja--Zannier and Nair--Kumar--Rout we prove that the subword complexity $\\pT(k)$ of $T$ is superlinear, $\\pT(k)/k\\to\\infty$. The argument is completely formalized in Lean-4, depending only on the Subspace Theorem.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0017",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11648v2",
    "status": "available",
    "timestamp": "2026-07-15T08:40:04.207098+00:00",
    "title": "ArXiv paper: Superlinear complexity of the $(3/2)^n$ steering word"
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
    "consumed_by_exp_id": "cdb5c1e4",
    "description": "Investigate the ArXiv paper 'Cyclic Projective Orbits on Rational Normal Curves and MDS Codes' and formalize its key results. Abstract: Let \\(A\\) be a cyclic operator on an \\(r\\)-dimensional vector space over a field \\(k\\), and let \\(z\\) be a cyclic vector. Their Krylov code has parity-check matrix \\((z,Az,\\ldots,A^{n-1}z)\\). For \\(r\\ge 3\\) and \\(n\\ge r+3\\), we prove that an MDS orbit segment lies on a rational normal curve precisely when the projective pair \\((A,[z])\\) is conjugate to one arising from the \\((r-1)\\)-st symmetric-power action of \\(\\mathrm{PGL}_2\\). Over finite fields, for companion operators, this gives a complete classification of the generalized Reed--Solomon locus into split semisimple, two nonsplit semisimple, and unipotent families. Over an algebraically closed field \\(k\\), the Zariski closure \\(\\GRSsurf_{r,k}\\) of the semisimple GRS coefficient locus is an irreducible rational surface, generically parameterized two-to-one by a two-dimensional torus of geometric-progression root sets; reversal is the generic ambiguity. The affine quotient of the parameter torus by reversal is the normalization of \\",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0021",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12761v1",
    "status": "in_progress",
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
    "description": "Investigate the ArXiv paper 'Alternating Extremes in Graceful Labelings of Full Binary Trees and Spider Trees' and formalize its key results. Abstract: We study a pinned form of graceful labeling. For full binary trees, we ask whether some deepest root-to-leaf path can carry the alternating extreme pattern $0,n-1,1,n-2,\\dots$. Such a spine uses the extreme labels and largest differences, forcing all off-spine vertices and edges to use the middle labels and smaller differences, respectively. We prove this pinned-spine conjecture for comb full binary trees, verify it computationally for all rooted non-isomorphic full binary trees through order $23$, and give an example showing that a pinned-spine labeling cannot always be chosen as an $\u03b1$-labeling. For spider trees, we prove a packing theorem for self-matched legs: pairwise disjoint legs based at hub label $1$, at least one of which contains label $0$, can be combined into a graceful spider, with unused labels attached as hub leaves. This yields graceful labelings for mixed-length spiders with sufficiently many leaves. We also report computations using a depth-first search ordered by la",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0028",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12597v1",
    "status": "available",
    "timestamp": "2026-07-15T19:02:51.335902+00:00",
    "title": "ArXiv paper: Alternating Extremes in Graceful Labelings of Full Binary Trees and Spider Trees"
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
    "description": "Investigate the ArXiv paper 'Expansions of $\\binom{pn}{p+r}$ in Shifted Binomial Bases and a Modular Symmetry Criterion' and formalize its key results. Abstract: We study the expansion of the polynomial $g_{p,r}(n) = \\binom{pn}{p+r}$ (for integers $p \\ge 2$ and $r \\ge 1$) in the shifted binomial basis $\\bigl\\{\\binom{n+k-1}{p+r}\\bigr\\}$. Using generating functions and finite differences, we obtain a closed-form formula for the expansion coefficients $B_{p,r,k}$. We then characterize when the coefficient sequence is palindromic, showing that it exhibits reflection symmetry on its support if and only if $r \\equiv 1 \\pmod{p}$. The proof combines an analysis of the sequence's support with the root structure of $\\binom{pX}{p+r}$. Under the same congruence condition, we show that $p$ divides every coefficient. For $r=1$, the leading coefficient simplifies to $p C_p$, where $C_p$ is the $p$-th Catalan number. Finally, computations for small values of $p$ and $r$ show that the resulting coefficient sequences coincide with selected rows of $p$-decimated multinomial triangles (OEIS A027907 and A008287).",
    "domains": [
      "Logic"
    ],
    "id": "fd_0037",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12173v1",
    "status": "available",
    "timestamp": "2026-07-15T21:37:21.472081+00:00",
    "title": "ArXiv paper: Expansions of $\\binom{pn}{p+r}$ in Shifted Binomial Bases and a Modular Symmetry Criterion"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On nontrivial cross-2-intersecting families' and formalize its key results. Abstract: Two families \\(\\mathcal{A}\\subseteq\\binom{[n]}{k}\\) and \\(\\mathcal{B}\\subseteq\\binom{[n]}{\\ell}\\) are said to be nontrivial cross-\\(t\\)-intersecting if \\(|A \\cap B| \\geq t\\) for all \\(A \\in \\mathcal{A}\\) and \\(B \\in \\mathcal{B}\\), and $|\\bigcap_{A\\in \\mathcal{A}\\cup \\mathcal{B}}A|<t$. In this paper, we determine the upper bound on \\(|\\mathcal{A}||\\mathcal{B}|\\) of two nontrivial cross-\\(2\\)-intersecting families \\(\\mathcal{A}\\subseteq\\binom{[n]}{k}\\) and \\(\\mathcal{B}\\subseteq\\binom{[n]}{\\ell}\\) for any positive integers $n,k,\\ell$ with \\(k\\geq \\ell \\geq 3\\) and \\(n \\geq 3(k-1)\\). Moreover, we characterize the extremal families attaining this bound. This settles the last unsolved case of a recent result by He, Li, Wu and Zhang (J. Combin. Theory Ser. A, 217 (2026) 106095).",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0038",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12239v1",
    "status": "available",
    "timestamp": "2026-07-15T21:54:41.787078+00:00",
    "title": "ArXiv paper: On nontrivial cross-2-intersecting families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On strongly regular signed graphs of higher girth' and formalize its key results. Abstract: Strongly regular signed graphs are an extension of strongly regular graphs to the realm of signed graphs, that is, graphs where each edge is positive or negative. Unlike with ordinary strongly regular graphs, most kinds of signed counterparts with girth 4 or higher are describable in terms of known structures. We prove that those with girth 4 that are bipartite are classified by designs of two kinds: weighing matrix designs and symmetric block designs. Those of girth 5 are few and readily described. There are none of higher girth. Those with girth 4 that are not bipartite are unsolved.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0039",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12131v1",
    "status": "available",
    "timestamp": "2026-07-15T22:11:46.704328+00:00",
    "title": "ArXiv paper: On strongly regular signed graphs of higher girth"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Learning the Graphical Nature of Symmetries' and formalize its key results. Abstract: Finite groups are rigid algebraic objects, whose Cayley graphs expose a rich network geometry through which group-theoretic structure can be measured, compared, and learned. In this paper, a dataset of $131{,}406$ Cayley graphs is constructed, covering all groups of order at most $767$ except order $512$, recording exact algebraic labels for group properties together with a broad collection of graph, cycle, distance, and spectral statistics. This census aims to provide novel benchmarks for studying how finite-group properties are reflected in Cayley graph observables. It also yields new enumerative contributions: alongside recovering known OEIS sequences for standard group classes, new sequences for monolithic groups and for groups generated by at most three, four, and five elements are contributed to the OEIS. The accompanying network analysis identifies several empirical regularities and formulates testable conjectures, including relationships involving square clustering, Cayley grap",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0040",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12026v1",
    "status": "available",
    "timestamp": "2026-07-15T22:29:34.061191+00:00",
    "title": "ArXiv paper: Learning the Graphical Nature of Symmetries"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Computing Tools for Translation-Invariant Total Orders' and formalize its key results. Abstract: We introduce TITO_Explore, a software package for representing and computing with Translation-Invariant Total Orders (TITOs). We define a canonical window notation for TITOs and design and implement algorithms for several computational tasks involving them. The package normalizes the window notation of a given TITO into its canonical form, computes its inversion set, compares the weak order between two TITOs, and computes the join of two specified TITOs. Our weak order comparison algorithm operates by partitioning the inversion sets into disjoint subsets, thereby breaking down the comparison problem into evaluations of paired subsets. The join algorithm uses an edge-weighted directed graph to represent inversions and converts the problem of finding the join into a weighted path problem in the graph.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0041",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11709v1",
    "status": "available",
    "timestamp": "2026-07-16T01:06:49.185740+00:00",
    "title": "ArXiv paper: Computing Tools for Translation-Invariant Total Orders"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A minimal modularity lifting theorem for Siegel modular forms' and formalize its key results. Abstract: We prove a minimal modularity lifting theorem (in the spirit of Genestier--Tilouine and Pilloni) in the setting of Siegel modular forms of genus two when the residual representation arises from a stable Yoshida lift, that is, an automorphic induction of a nearly ordinary Hilbert modular eigencuspform over a real quadratic field. As applications of the underlying $R=\\mathbb{T}$ theorem, we establish the freeness of a universal minimal ordinary Galois deformation ring over an Iwasawa algebra in two variables along with the uniqueness of Hida families passing through classical $p$-ordinary Siegel modular eigenforms with very regular weights.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0042",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13100v1",
    "status": "available",
    "timestamp": "2026-07-16T01:25:03.463263+00:00",
    "title": "ArXiv paper: A minimal modularity lifting theorem for Siegel modular forms"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Tropical Circuits with Scalar Multiplication Gates' and formalize its key results. Abstract: We study tropical circuits with scalar multiplication gates, that is, algebraic circuits whose gates implement $\\max$, $+$, or multiplication with a positive constant. For such circuits, we prove exponential size lower bounds for computing maximum weight directed spanning trees and maximum weight bipartite perfect matchings. As a corollary, we obtain an exponential size separation between monotone and non-monotone maxout neural networks, which generalize the popularly used ReLU neural networks. One conclusion from this is that neural network models with enforced convexity constraints, such as input-convex neural networks (ICNNs), sometimes need to be exponentially larger than their unrestricted counterparts in order to express the same functions.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0043",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11540v1",
    "status": "available",
    "timestamp": "2026-07-16T03:00:45.022108+00:00",
    "title": "ArXiv paper: Tropical Circuits with Scalar Multiplication Gates"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'An asymptotic Sidon basis of order $3-\u03b7$' and formalize its key results. Abstract: Pilatte recently proved that there exists an infinite Sidon set of positive integers which is an asymptotic basis of order $3$, answering a problem posed by Erd\u0151s, S\u00e1rk\u0151zy and S\u00f3s in 1994. In this paper, we strengthen this result by proving that for any $0<\u03b7<0.0527$, there exists an infinite Sidon set $\\mathcal{S}\\subset \\mathbb{N}$ which is an asymptotic basis of order $3-\u03b7$; that is, every sufficiently large integer $m$ can be represented as \\[ m=s_1+s_2+s_3 \\] for some $s_1,s_2,s_3\\in \\mathcal{S}$ satisfying \\[ \\min\\{s_1,s_2,s_3\\}\\leq m^{1-\u03b7}. \\] To prove this, we develop a truncated version of Pilatte's construction and use a deep result of Sawin on sums of Dirichlet convolutions of the von Mangoldt function over function fields.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0044",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11351v1",
    "status": "available",
    "timestamp": "2026-07-16T03:18:26.968315+00:00",
    "title": "ArXiv paper: An asymptotic Sidon basis of order $3-\u03b7$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The combinatorics of sector renormalization' and formalize its key results. Abstract: The goal of this note is to systematically develop the fundamental arithmetic and combinatorial properties of the sector renormalization operation on rigid rotations. We employ the specific framework of modified continued fractions appropriate for sector renormalization and analyze their properties. By allowing infinite first return times, this framework yields a dynamical compactification characterized by a universal property. We also discuss the corresponding natural extension and introduce the notion of a time (semi-)group. For example, we demonstrate how a bi-infinite tower of sector renormalizations of irrational rotations can be packaged within a single dynamical plane as a cascade of translations. This note will serve as a foundational combinatorial tool for studying the geometric properties of sector renormalizations of holomorphic maps with irrationally indifferent fixed points, particularly neutral quadratic polynomials.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0045",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11408v1",
    "status": "available",
    "timestamp": "2026-07-16T03:35:58.435178+00:00",
    "title": "ArXiv paper: The combinatorics of sector renormalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Arithmetic Properties for $k$-Color Analogue of Simultaneously $s$-Regular and $t$-Distinct Partitions' and formalize its key results. Abstract: In this article, we discuss general generating functions for partitions of $n$, simultaneously $s$-regular and $t$-distinct in 3-colors. In addition, we obtain infinite families of congruences modulo powers of 3 for specific values of $(\\ell,t)$. For instance, for positive integers $n$ and $k$, we have \\begin{align*} \\sum_{n=o}^{\\infty}RD_3^{3,3}\\left(3^kn+\\frac{3^k+1}{2}\\right)q^n\\equiv0 \\pmod{3^{k+1}}. \\end{align*}",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0046",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11499v1",
    "status": "available",
    "timestamp": "2026-07-16T03:53:26.323639+00:00",
    "title": "ArXiv paper: Arithmetic Properties for $k$-Color Analogue of Simultaneously $s$-Regular and $t$-Distinct Partitions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Sufficient conditions for $(K_2 \\cup kK_1)$-free graphs to be Hamilton-connected' and formalize its key results. Abstract: The toughness of a non-complete graph $G$, denoted $\u03c4(G)$, is defined as \\[ \u03c4(G) = \\min\\left\\{ \\frac{|S|}{\u03c9(G-S)} : S \\subseteq V(G),\\ \u03c9(G-S) \\geq 2 \\right\\}, \\] where $\u03c9(G-S)$ is the number of components of $G - S$. For a complete graph $G$, we define $\u03c4(G) = \\infty$. A graph $G$ is $t$-tough if $\u03c4(G) \\geq t$. For a positive integer $k$, a graph $G$ is $(K_2 \\cup kK_1)$-free if it contains no induced subgraph isomorphic to $K_2 \\cup kK_1$. Recently, Liu \\cite{liu} showed that every $2k$-connected $(K_2 \\cup kK_1)$-free graph $G$ with $\u03c4(G) > 1$ is Hamilton-connected. In this paper, we strengthen this result by proving that every $(k+1)$-connected $(K_2 \\cup kK_1)$-free graph $G$ with $\u03c4(G) > 1$ and minimum degree $\u03b4(G) \\geq 2k$ is Hamilton-connected. Moreover, by imposing restrictions to the independence number $\u03b1(G)$, we prove that every $k$-connected $(K_2 \\cup kK_1)$-free graph $G$ of order $n$ with $2k+1 \\leq \u03b1(G) < \\frac{n}{2}$ and $\u03b4(G) \\geq 2k$ is Hamilton-connected, and that t",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0047",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11373v1",
    "status": "available",
    "timestamp": "2026-07-16T04:10:14.412101+00:00",
    "title": "ArXiv paper: Sufficient conditions for $(K_2 \\cup kK_1)$-free graphs to be Hamilton-connected"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Proximity Measures for Classes of Phylogenetic Networks' and formalize its key results. Abstract: Phylogenetic networks are used to represent the evolutionary history of species. Due to biological interpretations and computational advantages, researchers have focused on restricted classes of phylogenetic networks, such as tree-child, orchard, and tree-based. These classes capture different notions of tree-likeness: tree-child networks require every internal vertex to have a taxon reachable by a tree path, orchard networks are trees with horizontal arcs (for modelling histories rife with horizontal gene transfers), and tree-based networks are trees with additional (not-necessarily horizontal) arcs. A natural question to ask is ``how far is a given network from belonging to a particular class?'' This motivates the study of proximity measures, which measure the minimum number of graph modifications required to transform a network into one belonging to a particular class. In this paper, we consider three proximity measures based on leaf addition, valid arc deletion, and arc deletion. W",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_0048",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11325v1",
    "status": "available",
    "timestamp": "2026-07-16T04:26:21.230905+00:00",
    "title": "ArXiv paper: Proximity Measures for Classes of Phylogenetic Networks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On Small Doubling in Right-Ordered Groups and Baumslag-Solitar Groups-II' and formalize its key results. Abstract: Recently, Mohan et al. [Results Math. 80 (2025), No. 4, 122] answered Freiman's $3k-4$ conjecture in right-ordered groups under certain restrictions. In this paper, we take a step further by investigating the structure of nonempty subsets $S$ of a right-ordered group satisfying the small doubling condition $|S^2| = 3|S|-3$. Moreover, we provide a complete characterization of all nonempty finite subsets $S$ of the Baumslag-Solitar group $\\mathrm{BS}(1,q)$ (with $q \\in \\mathbb{Z}$ and $q \\neq -1$) for which $|S^2| = 3|S|-3$ and the identity element is the minimum of $S$.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0049",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11194v1",
    "status": "available",
    "timestamp": "2026-07-16T04:42:53.469113+00:00",
    "title": "ArXiv paper: On Small Doubling in Right-Ordered Groups and Baumslag-Solitar Groups-II"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Optimal chain density, entropy, and space-time tradeoffs for the TSP' and formalize its key results. Abstract: We nearly settle a natural extremal question about set systems over $[n]$: the tradeoff between the {size} (number of sets) and the number of {full chains}. This question was initially raised by Johnson, Leader, and Russell [Combin.~Probab.~Comp., 2015] as a counterpart to Sperner-type results in combinatorics. Recently, a framework introduced by Ameli, Nederlof, and Wang, and independently by Dallant and Kozma [FOCS 2026] linked this question to the space- and time-complexity of Bellman-Held-Karp-style dynamic programming algorithms for permutation problems such as the traveling salesman (TSP). Precisely, they showed that a space-time product $\u03b3^{n+o(n)}$ is feasible for the TSP, whenever a set system of (normalized) size $S$ and chain density $D$ exists, with $ \u03b3= S^2/D$. In this paper we show an essentially {optimal} bound of $\u03b3\\approx 3.1819$ for this quantity, closing the gap between the previous best lower and upper bounds of $\u03b3\\geq 3.015$ and $ \u03b3\\leq 3.572$ respectively. This im",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0050",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11311v1",
    "status": "available",
    "timestamp": "2026-07-16T04:58:43.855515+00:00",
    "title": "ArXiv paper: Optimal chain density, entropy, and space-time tradeoffs for the TSP"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Bounded-Support Additive Latin Transversals via Color-Counted Matching' and formalize its key results. Abstract: We consider the following additive Latin transversal problem. Given a multiset $A=(a_1,\\dots,a_k)$ of elements of $\\mathbb Z_m$ and a set $B\\subseteq\\mathbb Z_m$ of cardinality $k$, the task is to order $B$ as $b_1,\\dots,b_k$ so that the sums $a_i+b_i$ are pairwise distinct. When $k=m$, Hall proved that a solution exists if and only if $\\sum_{i=1}^m a_i\\equiv 0 \\pmod m$; moreover, his theorem yields a polynomial-time construction. Alon proved that a solution always exists when $m$ is prime and $k<m$, but no polynomial-time construction is known in general. Our main algorithmic contribution is a direct randomized algorithm for Color-Counted Matching: given an edge-colored graph and prescribed target counts for the colors, find a matching using exactly the prescribed number of edges of each color. If $q$ is the sum of the target counts and $h$ is the number of colors, our base-$(q+1)$ reduction to Exact Red Matching, combined with the algorithm of Mulmuley-Vazirani-Vazirani, gives a rand",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_0051",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11241v1",
    "status": "available",
    "timestamp": "2026-07-16T05:14:56.022999+00:00",
    "title": "ArXiv paper: Bounded-Support Additive Latin Transversals via Color-Counted Matching"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Two local zero-sum problems' and formalize its key results. Abstract: In the present paper, we investigate two local zero-sum problems. Let $n,k\\ge 2$. We denote by $\\mathsf{D}^*(n,nk)$ (resp. $\u03b7^{*}(n,nk)$) the smallest positive integer $\\ell$ (if exists) such that, from any given $\\ell$ integers not divisible by $n$, one can select some (resp. at most $n$) of them whose sum is divisible by $n$ but not by $nk$. We prove that both $\\mathsf{D}^*(n,nk)$ and $\u03b7^{*}(n,nk)$ are equal to $2n-1$ if $\\mathrm{rad}(n) \\mid \\mathrm{rad}(k)$ and infinite otherwise. The corresponding inverse problem is also determined. We denote by $\\mathsf{D}_n^{\\times}$ (resp. $\u03b7_n^{\\times}$) the smallest positive integer $\\ell$ such that, from any given $\\ell$ integers coprime to $n$, one can select some (resp. at most $n$) of them whose sum $\u03c3$ satisfies $\\gcd(\u03c3, n^2)=n$. We prove that $\\mathsf{D}_n^{\\times}=\u03b7_n^{\\times}=2n-1$ if $n$ is a prime power, and determine its inverse problem.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0052",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11313v1",
    "status": "available",
    "timestamp": "2026-07-16T05:31:13.820944+00:00",
    "title": "ArXiv paper: Two local zero-sum problems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Zero-one laws for uniform approximation via Gaussian and Eisenstein integers' and formalize its key results. Abstract: We establish two distinct zero-one laws for the uniform Diophantine approximation of complex numbers by quotients of Gaussian integers and by quotients of Eisenstein integers. Using tools from homogeneous dynamics, we study this problem by reducing to a shrinking target problem on certain homogeneous spaces of $\\mathrm{SL}_2(\\mathbb{C})$. The main novel ingredients include measure estimates on a certain family of neighborhoods of the corresponding critical loci, as well as new disjointness statements to control the short-range mixing contribution. Due to the different nature of the critical loci in the Gaussian and Eisenstein cases, these measure estimates are obtained by rather different arguments.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0053",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11178v1",
    "status": "available",
    "timestamp": "2026-07-16T05:47:47.595754+00:00",
    "title": "ArXiv paper: Zero-one laws for uniform approximation via Gaussian and Eisenstein integers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The chromatic number of 3-stable Kneser graphs' and formalize its key results. Abstract: For an integer $s \\ge 2$, a subset $S \\subseteq [n]$ is {\\em $s$-stable} if $\\min \\{j - i, n + i - j\\}\\ge s$ for every $i,j \\in S$ with $i<j$. Denote the set of all $s$-stable subsets of size $k$ of $[n]$ by $\\binom{[n]}{k}_{s\\text{-stable}}$. Schrijver proved in 1978 that whenever $n\\ge 2k$, the chromatic number of the Kneser graph $\\mathrm{KG}\\big( \\binom{[n]}{k}_{2\\text{-stable}}\\big)$ is $n - 2k +2$. Generalizing this result, Meunier conjectured in 2011 that $\u03c7\\left( \\mathrm{KG}\\big( \\binom{[n]}{k}_{s\\text{-stable}} \\big) \\right)= n - sk +s$ for all $n\\ge sk$. This conjecture was previously proven for all even $s$, for $s \\ge 4$ and large enough $n$, and for $k=2$. We prove the conjecture in the cases $s=3$ and $n$ large enough, or $k=s=3$. To this end, we prove versions of the Hilton-Milner theorem for $s$-stable sets. We also present a topological approach towards Meunier's conjecture.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0054",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12912v1",
    "status": "available",
    "timestamp": "2026-07-15T12:33:25.469761+00:00",
    "title": "ArXiv paper: The chromatic number of 3-stable Kneser graphs"
  },
  {
    "consumed_by_exp_id": "e2f5c991",
    "description": "Investigate the ArXiv paper 'The Balanced Four-Color Theorem' and formalize its key results. Abstract: We show that every planar graph with $n \\geq 3$ vertices admits a 4-coloring in which each color is used on fewer than $n/2$ vertices. This bound is the best possible. Moreover, such a coloring can be found in $O(n \\log n)$ time. We also extend these results to five or more colors and to graphs on general surfaces.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0055",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13025v1",
    "status": "in_progress",
    "timestamp": "2026-07-15T12:51:18.212379+00:00",
    "title": "ArXiv paper: The Balanced Four-Color Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Claw-free cubic graphs and zero forcing' and formalize its key results. Abstract: A claw-free cubic graph is a cubic graph with no induced subgraph isomorphic to $K_{1,3}$. The zero forcing process begins with an initial set $S$ of colored vertices. At each step, a colored vertex with exactly one uncolored neighbor forces that neighbor to become colored. If repeated applications of this rule color every vertex of $G$, then $S$ is called a zero forcing set. The minimum cardinality of a zero forcing set is the zero forcing number, denoted by $Z(G)$. In this paper, we answer three open questions posed by Davila and Henning concerning upper bounds on the zero forcing number of claw-free cubic graphs. We characterize the connected claw-free cubic graphs satisfying $Z(G)=\u03b1(G)+1$, where $\u03b1(G)$ is the independence number. In addition, we establish the improved upper bound $Z(G)\\leq \\frac{T}{2}+D+2$ for claw-free cubic graphs with Hamiltonian contraction multigraphs, where $D$ is the number of diamonds and $T$ is the number of triangles in $G$.",
    "domains": [
      "Physics"
    ],
    "id": "fd_0056",
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
    "id": "fd_0057",
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
    "id": "fd_0058",
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
    "id": "fd_0059",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12561v1",
    "status": "available",
    "timestamp": "2026-07-15T14:01:10.734967+00:00",
    "title": "ArXiv paper: Genus and Gonality of Small Curves, Dynamical Uniform Boundedness, and Bifurcation"
  },
  {
    "consumed_by_exp_id": "d8f04178",
    "description": "Investigate the ArXiv paper 'Euler systems and the symmetric square of a Hida family' and formalize its key results. Abstract: Let $p\\geq7$ be a prime number. We build a non-trivial Euler system for the symmetric square of a $p$-adic Hida family of modular forms interpolating the Euler system constructed by Loeffler-Zerbes for the symmetric square of a $p$-ordinary newform. As a second contribution, we prove an algebraic functional equation for dual Selmer groups in this setting. Finally, building on recent work by B\u00fcy\u00fckboduk-Ganguly on functional equations of algebraic (Rankin-Selberg) $p$-adic $L$-functions, we prove a divisibility result towards the Iwasawa main conjecture for the symmetric square of a Hida family.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0060",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12679v1",
    "status": "in_progress",
    "timestamp": "2026-07-15T14:18:31.029430+00:00",
    "title": "ArXiv paper: Euler systems and the symmetric square of a Hida family"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Tverberg's theorem for unions of convex sets: Sharp bounds and colored extensions' and formalize its key results. Abstract: Let $f_{r}(d,s_{1},\\ldots,s_{r})$ be the least $N$ such that every $N$-point set $P\\subseteq \\mathbb{R}^{d}$ has an $r$-partition $P=P_{1}\\sqcup\\cdots\\sqcup P_{r}$ with the following property: whenever $C_{i}\\supseteq P_{i}$ is a union of at most $s_{i}$ convex sets, one has $\\bigcap_{i=1}^{r}C_{i}\\ne\\emptyset$. A recent breakthrough of Alon and Smorodinsky established the first effective upper bounds $f_{r}(d,s,\\ldots,s)\\le Cdr^{2}s^{r}\\log r\\log(es^{r})$ for this problem. We obtain an asymptotically sharp lower bound by proving $f_r(d,s,\\ldots,s)\\ge c(d-r+2)s^r\\log(s+1)$ for every $d\\ge r+2$, which shows that $f_r(d,s,\\ldots,s)=\u0398_{d,r}(s^r\\log s)$ for every fixed $d\\ge r+2$. We also prove the general lower bound $f_r(d,s,\\ldots,s)>s^{\\min\\{d,r\\}}$. On the other hand, we develop a local counting argument to show that $f_r(d,s,\\ldots,s)\\le C_{d}rs^r\\log(ers^r)$ and $f_r(d,s,\\ldots,s)\\le C_{d}r^{d+2}s^{d+1}\\log(ers)$ whenever $r\\ge d+1$, improving the upper bound of Alon and Smorodinsky",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0061",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12449v1",
    "status": "available",
    "timestamp": "2026-07-15T18:44:57.239806+00:00",
    "title": "ArXiv paper: Tverberg's theorem for unions of convex sets: Sharp bounds and colored extensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Local flag algebras' and formalize its key results. Abstract: We introduce local flag algebras, a variant of Razborov's flag algebra framework in which densities are normalised by the maximum degree $\u0394(G)$ rather than the order $|G|$. The framework supports the same semidefinite-method machinery as the classical version, but is tailored to extremal problems that scale with the maximum degree. As an illustrative first application we bound the number of pentagons in a triangle-free graph $G$ as a function of $|G|$ and $\u0394(G)$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0062",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12461v1",
    "status": "available",
    "timestamp": "2026-07-15T19:02:55.300737+00:00",
    "title": "ArXiv paper: Local flag algebras"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Counting oriented spanning trees in generalized join digraphs' and formalize its key results. Abstract: Let $G$ be a digraph with vertex set $\\{1,2,...,n\\}$ and $H_{1},H_{2},...,H_{n}$ be $n$ digraphs. The generalized join digraph $\\overrightarrow{G}=G[H_{1},H_{2},...,H_{n}]$ is a digraph obtained from $G$ by replacing each vertex $i$ with $H_{i}$ and for any $u\\in V(H_{i})$ and $v\\in V(H_{j})$, $(u,v)\\in E(\\overrightarrow{G})$ if and only if $(i,j)\\in E(G)$. In this paper we express the number of oriented spanning trees in $\\overrightarrow{G}$ in terms of Laplacian eigenvalues of $H_{1},H_{2},...,H_{n}$ and oriented spanning trees of $G$. Furthermore, we consider the number of oriented spanning trees with a fixed root in $\\overrightarrow{G}$. First, we introduce the biclique-directed star transformation formula for counting oriented spanning trees with a fixed root in digraphs. Using it, we give the formula for the total number of oriented spanning trees with roots in a certain $H_{i}$ $(1\\leq i \\leq n)$ of $\\overrightarrow{G}$ in terms of Laplacian eigenvalues of $H_{1},H_{2},...,H_{n}",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0063",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12457v1",
    "status": "available",
    "timestamp": "2026-07-15T19:20:02.896503+00:00",
    "title": "ArXiv paper: Counting oriented spanning trees in generalized join digraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Recursive Formula for the Equations of Hessenberg Varieties' and formalize its key results. Abstract: Hessenberg varieties are subvarieties of the flag variety, defined by containment conditions on flags with respect to a linear operator. The study of these varieties lies in the intersection of algebraic geometry, combinatorics, and representation theory. In this paper, we develop an algebro-geometric procedure for determining the closed subvariety structure of a Hessenberg variety $\\mathcal{H}(X,h)$ in the flag variety for any linear operator $X$ and Hessenberg function $h$, by imposing a partial order on the Hessenberg functions and analyzing the relation of the corresponding Hessenberg varieties. In particular, we give a concrete recursive formula for determining all equations cutting out a given Hessenberg variety in each Schubert cell. As an application, we provide an alternative geometric proof of Tymoczko's results on the existence of affine pavings of a given Hessenberg variety and on the dimension count of its cells.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0064",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12261v1",
    "status": "available",
    "timestamp": "2026-07-15T19:37:25.793116+00:00",
    "title": "ArXiv paper: Recursive Formula for the Equations of Hessenberg Varieties"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Hypergraph Turan with bounded matching number' and formalize its key results. Abstract: For a fixed graph $G$, an $r$-uniform hypergraph is said to contain a Berge-$G$ if there exists a bijection $f\\colon E(G)\\to E(\\mathcal{H})$ for some subhypergraph $\\mathcal{H}$ such that $e\\subseteq f(e)$ for every $e\\in E(G)$. Motivated by Alon and Frankl's study of Tur\u00e1n problems under bounded matching constraints, we investigate the maximum number of edges in $r$-uniform Berge-$K_3$-free hypergraphs with matching number at most~$s$. We determine the exact Tur\u00e1n numbers for the cases $r=3$ and $r=4$. For $r=3$ and $n \\geq 3 s$, we prove that every $n$-vertex Berge- $K_3$-free 3-graph with matching number $s$ has at most $s(n-2 s)$ edges, and we characterize the unique extremal hypergraph attaining equality. For $r=4$ and $n \\geq 4 s$, the maximum number of edges is $s\\lfloor(n-2 s) / 2\\rfloor$, except for the exceptional case $s=1$ and $n \\equiv 1(\\bmod 4)$, in which the bound is $(n-1) / 2$. As a corollary, our results recover the classical theorem of Gy\u0151ri on Berge-$K_3$-free hype",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0065",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12300v1",
    "status": "available",
    "timestamp": "2026-07-15T19:54:37.533091+00:00",
    "title": "ArXiv paper: Hypergraph Turan with bounded matching number"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper '$k$-Convex Polyominoes by Semi-perimeter' and formalize its key results. Abstract: We give the conjectured solution for the generating function of $k$-convex polyominoes, enumerated by semi-perimeter. The solution was obtained from the analysis of enumeration data that we generated.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0066",
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
    "id": "fd_0067",
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
    "id": "fd_0068",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12330v1",
    "status": "available",
    "timestamp": "2026-07-15T20:45:36.266548+00:00",
    "title": "ArXiv paper: Curious identities involving Legendre polynomials and Ap\u00e9ry-like numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Some Remarks on Hessians and Wronskians' and formalize its key results. Abstract: The purpose of this note is to elaborate on the apparent connection between Wronskians and Hessians. More generally, to a given subspace of homogeneous bivariate forms over the complex numbers, we associate two determinantal polynomials called the $W$-polynomial and the $\\hat{W}$-polynomial. We give expansion and factorization formulas for these polynomials, and study their behavior under change of coordinates and duality. As an application, we give another proof of Iarrobino's theorem on the strong Lefschetz property for standard graded Artinian Gorenstein algebras in codimension two.",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_0069",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12162v1",
    "status": "available",
    "timestamp": "2026-07-15T21:02:39.460834+00:00",
    "title": "ArXiv paper: Some Remarks on Hessians and Wronskians"
  },
  {
    "consumed_by_exp_id": "aa7167bb",
    "description": "Investigate the ArXiv paper 'Far-apart Erd\u0151s--P\u00f3sa property of long cycles' and formalize its key results. Abstract: We prove that there exist functions $f:\\mathbb N^2\\to\\mathbb N$ and $g:\\mathbb N\\to\\mathbb N$ such that for all positive integers $k$, $d$, and $\\ell\\ge3$, every graph $G$ either contains $k$ cycles of length at least $\\ell$ that are pairwise at distance greater than $d$, or admits a subset of vertices $X$ with $|X|\\le f(k,\\ell)$ such that $G-B_G(X,g(d))$ contains no cycle of length at least $\\ell$, where $B_G(X,r)$ denotes the ball of radius $r$ around $X$. This generalizes a theorem of Dujmovi\u0107, Joret, Micek, and Morin (2024), which established the $\\ell=3$ case. Moreover, we prove that the theorem holds with $f(k,\\ell)\\in\\mathcal{O}(\\ell k\\log k)$ and $g(d)\\in\\mathcal{O}(d)$. The linear bound on $g$ is best possible, while the bound on $f$ is optimal as a function of $k$ for every fixed $\\ell$. In particular, for $\\ell=3$ our result improves the previous bound of $\\mathcal{O}(k^{18}\\mathsf{polylog} k)$ by Dujmovi\u0107 et al.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0070",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12136v1",
    "status": "in_progress",
    "timestamp": "2026-07-15T21:20:02.802185+00:00",
    "title": "ArXiv paper: Far-apart Erd\u0151s--P\u00f3sa property of long cycles"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A few remarks on the Baez-Duarte Criterion' and formalize its key results. Abstract: The goal of this paper is to derive a few very interesting lemmas related to the B\u00e1ez-Duarte criterion.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0071",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12084v1",
    "status": "available",
    "timestamp": "2026-07-15T21:37:25.493366+00:00",
    "title": "ArXiv paper: A few remarks on the Baez-Duarte Criterion"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Contractions and applications of crystal skeletons: Young quasisymmetric and Stanley symmetric functions' and formalize its key results. Abstract: The character of a connected $\\mathfrak{sl}_n$-crystal is a Schur polynomial; the crystal can be further decomposed into quasicrystals, whose characters are the Gessel quasisymmetric functions. Crystal skeletons are obtained by contracting quasicrystals within crystal graphs. They generalize dual equivalence graphs, and can be used to prove the Schur expansion of a symmetric function when the quasisymmetric expansion is known. In this paper, we show that the crystal skeleton can be tiled further into components which we call quasicrystal skeletons, whose characters are Young quasisymmetric Schur functions. We characterize which edges in the crystal skeleton move between quasicrystal skeleton components. Contracting the quasicrystal skeleton components yields Bruhat order. We illustrate how these tools can be applied to symmetric functions by analyzing the Stanley symmetric functions.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0072",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12232v1",
    "status": "available",
    "timestamp": "2026-07-15T21:54:48.409080+00:00",
    "title": "ArXiv paper: Contractions and applications of crystal skeletons: Young quasisymmetric and Stanley symmetric functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Induced-Minor-Closed Classes have Linear, Square-Root, or Sub-Polynomial Tree-Independence' and formalize its key results. Abstract: An independent set in a graph $G$ is a set of pairwise non-adjacent vertices. A tree decomposition of $G$ is a pair $(T, \u03c7)$ where $T$ is a tree and $\u03c7: V(T) \\rightarrow 2^{V(G)}$ is a function satisfying two axioms: for every edge $uv \\in E(G)$ there is an $x \\in V(T)$ such that $\\{u,v\\} \\subseteq \u03c7(x)$, and for every vertex $u \\in V(G)$ the set $\\{x \\in V(T) | u \\in \u03c7(x)\\}$ induces a non-empty and connected subtree of $T$. The sets $\u03c7(x)$ for $x \\in V(T)$ are called the bags of the tree decomposition. The tree-independence number of $G$ is the minimum taken over all tree decompositions of $G$ of the maximum size of an independent set of the graph induced by a bag of the decomposition. A graph $H$ is an induced minor of a graph $G$ if a graph isomorphic to $H$ can be obtained from $G$ by vertex deletions and edge contractions. We prove that for every $t\\in\\mathbb{N}$ there exists an $\u03b5> 0$ such that every graph $G$ either contains the complete bipartite graph $K_{t,t}$ or the wall $W_",
    "domains": [
      "Logic"
    ],
    "id": "fd_0073",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12090v1",
    "status": "available",
    "timestamp": "2026-07-15T22:11:50.907220+00:00",
    "title": "ArXiv paper: Induced-Minor-Closed Classes have Linear, Square-Root, or Sub-Polynomial Tree-Independence"
  },
  {
    "consumed_by_exp_id": "7d82c497",
    "description": "Investigate the ArXiv paper 'Intrinsic ergodicity for $\\mathfrak{B}$-free integers in number fields' and formalize its key results. Abstract: Let $K$ be a number field with ring of integers $\\mathscr{O}_K$, and let $\\mathfrak{B}$ be an Erd\u0151s family of ideals in $\\mathscr{O}_K$. We prove that the associated $\\mathfrak{B}$-free subshift $(X_{\\mathfrak{B}},(S_a)_{a\\in\\mathscr{O}_K})$ is intrinsically ergodic: it carries a unique measure of maximal entropy, which we identify explicitly as a relatively independent extension of the Haar rotation on $\\prod_{\\mathfrak{b}\\in\\mathfrak{B}}\\mathscr{O}_K/\\mathfrak{b}$. This is the first proof of intrinsic ergodicity for $\\mathfrak{B}$-free systems beyond dimension one, and relies on the work of Ara\u00fajo--Dymek--Ku\u0142aga-Przymus. Via their reductions, we also settle the $k$-free and $\\mathfrak{B}$-free lattice-point cases and the $k$-free number-field case. We give \\emph{two independent proofs} of the underlying rigidity statement: one through a single-site relative-entropy argument, and one through an exact-tiling realisation of Peckner's induce-and-split scheme.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0074",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11330v1",
    "status": "in_progress",
    "timestamp": "2026-07-16T03:00:49.615487+00:00",
    "title": "ArXiv paper: Intrinsic ergodicity for $\\mathfrak{B}$-free integers in number fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Fractal uncertainty principle over $\\mathbb{Q}_p$' and formalize its key results. Abstract: We prove a fractal uncertainty principle over $\\mathbb{Q}_p$ for porous sets, resolving a conjecture of Cohen.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0075",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11534v1",
    "status": "available",
    "timestamp": "2026-07-16T03:18:30.753456+00:00",
    "title": "ArXiv paper: Fractal uncertainty principle over $\\mathbb{Q}_p$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Moment-based PPT criteria for random bipartite states' and formalize its key results. Abstract: Moment-based relaxations of the positive partial transpose (PPT) criterion have been recently introduced, as a hierarchy of entanglement criteria involving only experimentally accessible quantities of a given bipartite state. The goal of this work is to study their typical detection performance on high-dimensional bipartite systems. Concretely, we investigate whether random bipartite mixed states on $\\mathbb C^d\\otimes\\mathbb C^d$, obtained as the marginal over an environment $\\mathbb C^s$ of a uniformly distributed pure state, generically satisfy or violate them. For each fixed level $m\\in\\mathbb N$ in this hierarchy of moment-based PPT criteria, we are able to identify a threshold environment dimension $s=\u03bb_md^2$ at which the behavior of the associated random state switches from violating to satisfying it, with probability going to $1$ as $d$ grows. The proof combines combinatorics of permutations techniques to estimate the average value of moments of partially transposed random stat",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "fd_0076",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11369v1",
    "status": "available",
    "timestamp": "2026-07-16T03:36:01.905252+00:00",
    "title": "ArXiv paper: Moment-based PPT criteria for random bipartite states"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Polynomial-Time Evaluation of Aardal-Lenstra Denumerants via Constant Term Method' and formalize its key results. Abstract: Aardal and Lenstra systematically studied hard knapsack problems of the form $a_1x_1+\\cdots+a_nx_n=b$, where $a_i=p_iM+r_iN$, $(M,N)$ is a coprime pair of positive integers, and the integers $|p_i|, |r_i|$ are small relative to $M$ and $N$. We investigate the corresponding challenging denumerant problem (i.e., counting the number of nonnegative integer solutions) and present a polynomial-time algorithm. This eliminates the computational bottlenecks caused by large values of $M$, $N$ and $b$. The proposed algorithm achieves a time complexity of $O(n^4\u0394^2\\log n\\log\u0394)$, which depends solely on the parameters $n$ and $\u0394=\\max_{i,j}|r_i p_j - r_j p_i|$. Moreover, we consider the problem of expressing a general vector $(a_1,\\dots,a_n)$ in the above form using the LLL algorithm.",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_0077",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11477v1",
    "status": "available",
    "timestamp": "2026-07-16T03:53:30.212279+00:00",
    "title": "ArXiv paper: Polynomial-Time Evaluation of Aardal-Lenstra Denumerants via Constant Term Method"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Finding Nearly-Periodic Components in Digraphs and Markov Chains from the Spectrum of Rotated Laplacian Matrices' and formalize its key results. Abstract: Inspired by recent advances in notions of spectral approximation of digraphs [Ahm+20], we study spectral algorithms for finding periodic structures in digraphs via the spectrum of a class of rotated Laplacian matrices. This class of Laplacian matrices was previously studied by Lange, Liu, Peyerimhoff, and Post [Lan+15]. We consider a notion of periodicity ratio that generalizes the bipartiteness ratio of Trevisan [Tre09], and show that it is closely related to the spectrum of rotated Laplacian matrices. In particular, if the digraph is strongly connected and represents a Markov chain, this periodicity ratio for a given $p \\in \\mathbb{N}$ is a quantitative measure of how close this Markov chain is to having periodicity $p$. We propose and analyze a periodicity-ratio variant of the spectral algorithm by Louis, Raghavendra, Tetali and Vempala [Lou+12]. We show that the algorithm runs in randomized polynomial time and can find many nearly periodic components (i.e, components with small per",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0078",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11333v1",
    "status": "available",
    "timestamp": "2026-07-16T04:10:18.387855+00:00",
    "title": "ArXiv paper: Finding Nearly-Periodic Components in Digraphs and Markov Chains from the Spectrum of Rotated Laplacian Matrices"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Combinatorial interpretation of the coefficients of the order polynomial of fence posets' and formalize its key results. Abstract: Given a fence poset P , we define a new statistic on permutations, denoted by blP, that provides a combinatorial interpretation of the coefficients of the order polynomial of P , answering a question of Ferroni, Morales, and Panova (2025). Using the fact that the base polytope of a lattice path matroid can be decomposed into order polytopes of fence posets, we also obtain a combinatorial interpretation of the coefficients of the Ehrhart polynomial of the base polytope of Schubert matroids, answering a question of Stanley (1999). As an application of this statistic, we establish the first nontrivial lower bound for the linear coefficient of the Ehrhart polynomial of an order polytope. Finally, we conjecture generalizations of this statistic to skew-shape posets and circular fence posets.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0079",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11225v1",
    "status": "available",
    "timestamp": "2026-07-16T04:26:26.324105+00:00",
    "title": "ArXiv paper: Combinatorial interpretation of the coefficients of the order polynomial of fence posets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A 64-Rectangle Counterexample to Wegner's Conjecture and LP Gaps up to $5/2$' and formalize its key results. Abstract: Wegner conjectured that every finite family $\\mathcal R$ of axis-parallel rectangles satisfies $\u03c4(\\mathcal R)\\le 2\u03bd(\\mathcal R)-1$, where $\u03bd$ is the packing number and $\u03c4$ is the piercing number. Ajwani, Gajjala, Raman, and Ray recently disproved this by constructing a triangle-free counterexample on $2196\\cdot 8^9$ rectangles and, using a computer-assisted package-and-port recursion, obtained a standard LP gap of $17891/8064$ for Maximum Independent Set of Rectangles. We give a simpler and hand-checkable counterexample with $64$ rectangles. It is built from an eight-rectangle gadget whose independent sets inject into four ordered slots; we then use four horizontal and four vertical copies of this gadget to form a triangle-free family with $\u03bd=16$ and $\u03c4\\ge 32$. We use the same horizontal-vertical step to define recursive families of rectangles $P_r$ with $\u03bd(P_r)=4^{2^r}$. For the standard clique, equivalently point, relaxation we obtain a finite gap $73/32$ at $P_3$, improving the prev",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0080",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11318v2",
    "status": "available",
    "timestamp": "2026-07-16T04:42:57.611296+00:00",
    "title": "ArXiv paper: A 64-Rectangle Counterexample to Wegner's Conjecture and LP Gaps up to $5/2$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'p-adic Properties of Translated Division Polynomials and Somos Sequences' and formalize its key results. Abstract: In this paper we consider the sequences $(\u03a8_{n}(\\mathbf{P}))_{n\\geq 0}$, $(\u03a6_{n}(\\mathbf{P}))_{n\\geq 0}$ and $(\\overline{\u03a9}\\,_{n}(\\mathbf{P}% ))_{n\\geq 0}$ of values of the translated division polynomials of an elliptic curve $E/K$ evaluated at a point $\\mathbf{P}\\in $ $E(K)^{2}$. We prove that these sequences are purely periodic when $K$ is a finite field. Then we use the periodicity properties of these sequences to prove that certain subsequences of these sequences are $% %TCIMACRO{\\U{2124} }% %BeginExpansion \\mathbb{Z} %EndExpansion _{p}$-Cauchy. Finally, we use this result to prove analogous results for Somos $4$ and Somos $5$ sequences.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0081",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11261v1",
    "status": "available",
    "timestamp": "2026-07-16T04:58:47.897559+00:00",
    "title": "ArXiv paper: p-adic Properties of Translated Division Polynomials and Somos Sequences"
  },
  {
    "consumed_by_exp_id": "166c4fd6",
    "description": "Investigate the ArXiv paper 'A dual linear programming bound for sphere packing in dimension 36' and formalize its key results. Abstract: We construct an explicit dual-feasible point for the Cohn-Elkies linear program in dimension 36, built from the space of weight-18 modular forms for $\u0393_0(24)$ following the method of Cohn and Triantafillou. The certificate shows that the two-point linear programming bound on the sphere packing density in dimension 36 exceeds the density of the best packing currently known -- the Kschischang-Pasupathy packing, of center density $2^{18}/3^{10}$ -- by a factor of at least 32.91. In particular, no Cohn-Elkies auxiliary function can certify the best known packing in dimension 36 as optimal. To our knowledge this is the first such dual bound in any dimension above 32, extending the table of Cohn-Triantafillou ($d=12,16,20,28,32$), Li ($3 \\le d \\le 13$), and de Courcy-Ireland-Dostert-Viazovska ($d=6$). The certificate is exact: the dual point is a rational vector, coefficient nonnegativity is verified by exact arithmetic up to $n=800$, and eventual positivity of the two relevant $q$-expansion",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0082",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11319v1",
    "status": "in_progress",
    "timestamp": "2026-07-16T05:15:00.370176+00:00",
    "title": "ArXiv paper: A dual linear programming bound for sphere packing in dimension 36"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Unexpected primes of good reduction in quotients of modular and Shimura curves' and formalize its key results. Abstract: We find all zero-dimensional spaces of newforms of weight $2$ and squarefree level $N$ with a fixed Atkin--Lehner sign pattern. As an application, we classify unexpected primes of good reduction of Atkin--Lehner quotients of modular and Shimura curves of squarefree levels.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0083",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11248v1",
    "status": "available",
    "timestamp": "2026-07-16T05:31:17.597085+00:00",
    "title": "ArXiv paper: Unexpected primes of good reduction in quotients of modular and Shimura curves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Lattice point counting in Cygan--Kor\u00e1nyi balls on Heisenberg groups' and formalize its key results. Abstract: Lattice point counting in gauge balls on the Heisenberg group $\\mathbb{H}^q$ is a non-commutative analogue of the Euclidean multidimensional sphere problem, initiated by Garg, Nevo and Taylor \\cite[\\textit{Ann. Inst. Fourier}, 2015]{GNT15}. The case of particular interest is when the gauge is taken as the Cygan--Kor\u00e1nyi norm and the error term reads: $$\\mathcal{E}_q(t)=\\#\\left(\\mathbb{Z}^{2 q+1} \\cap \\mathcal{B}_t\\right)-\\operatorname{vol}(\\mathcal{B}_1) \\, t^{2 q+2},$$ with $\\mathcal{B}_t=\\{(v,w)\\in\\mathbb{H}^q: (|v|^4 + w^2)^{1/4} \\le t \\}$, which is closely related to the Gauss circle problem. When $q\\ge3$, Gath \\cite[\\textit{Ann. Sc. Norm. Super. Pisa Cl. Sci.}, 2022]{Gat22} improved upon \\cite[]{GNT15} by showing that $ |\\mathcal{E}_q(t)|\\lesssim t^{2q-1+ 1/3}$ and proposed the conjecture that the optimal order should be $2q-1$. In this paper, through Landau's formula and the $5,6$-th Derivative Tests of van der Corput, we arrive at that $|\\mathcal{E}_q(t)| \\lesssim t^{2 q-1 + 241",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0084",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10971v1",
    "status": "available",
    "timestamp": "2026-07-16T05:47:52.883060+00:00",
    "title": "ArXiv paper: Lattice point counting in Cygan--Kor\u00e1nyi balls on Heisenberg groups"
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
