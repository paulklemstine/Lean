

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "The AdS/CFT correspondence says that a gravitational theory in the bulk of anti-de Sitter space is equivalent to a conformal field theory on the boundary. What if prime numbers have a holographic dual? Define the prime hologram: for each prime p, define its 'boundary' as the ring Z/pZ and its 'bulk' as the p-adic field Q_p. Conjecture: The Riemann zeta function zeta(s) = prod_p (1 - p^{-s})^{-1} is the holographic partition function: the product over primes (boundary) encodes the same information as the completed zeta function Xi(s) (bulk). The functional equation Xi(s) = Xi(1-s) is the holographic duality: bulk physics at depth s equals boundary physics at depth 1-s. The prime counting function pi(x) ~ x/log(x) is the bulk volume, while the Chebyshev function theta(x) = sum_{p<=x} log(p) is the boundary area. The AdS/CFT dictionary: bulk gravity mode at depth s <-> boundary CFT operator of dimension 1-s. Test: verify that the pair correlation of zeta zeros matches GUE random matrices (bulk = quantum gravity in AdS, boundary = CFT random matrix ensemble). Compute the 'prime partition function' Z(beta) = prod_p (1 - e^{-beta log p})^{-1} and show it equals the bulk partition function. Impact: the Riemann Hypothesis is equivalent to a holographic stability condition \u2014 zeros on the critical line means the bulk geometry is stable against perturbations.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0227",
    "priority_score": 0.91,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-17T13:45:25.015677+00:00",
    "title": "Holographic Primes: The Prime Number AdS/CFT Correspondence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "There are mathematical objects whose existence we can prove but whose specific properties are unknowable \u2014 theorems that cast shadows without being visible. Define a dark theorem as a statement T such that: (1) PA proves 'there exists x such that T(x)', but (2) for every specific n, PA does NOT prove T(n). The classic example is the Paris-Harrington theorem: the strengthened finite Ramsey theorem is true but not provable in PA. But dark theorems go further: they assert the existence of objects that no specific instance can be verified. Conjecture: The set of dark theorems is dense in the space of all Pi_2 statements \u2014 most true Pi_2 statements are dark. Moreover, there is a hierarchy of darkness: a dark theorem of level k is one where PA proves 'there exist at least k values of x such that T(x)' but cannot identify any specific one. The hierarchy is strict: level k+1 dark theorems are strictly harder to prove than level k. Test: construct explicit dark theorems of levels 1, 2, 3 using the Paris-Harrington principle and the Kirby-Paris hydra theorem. Prove the density conjecture by counting Pi_2 statements. Impact: most true mathematical statements are dark \u2014 they assert existence without the possibility of verification. This is not incompleteness; it is a new form of mathematical unknowability.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0217",
    "priority_score": 0.9,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-17T12:40:02.581378+00:00",
    "title": "Dark Mathematics: Theorems That Exist But Cannot Be Found"
  },
  {
    "consumed_by_exp_id": "1003d095",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "id": "fd_0126",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-16T15:16:12.438268+00:00",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof"
  },
  {
    "consumed_by_exp_id": "0f8a1331",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0124",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-16T15:16:12.414388+00:00",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk"
  },
  {
    "consumed_by_exp_id": "dfbea393",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty"
    ],
    "id": "fd_0125",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-16T15:16:12.425510+00:00",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Domain Shared has declined by 0.164 over recent cycles (recent avg=0.696 vs prior=0.860). Take a completely fresh approach \u2014 different proof techniques, new definitions, or a different subfield within this domain. Avoid repeating approaches that have been producing diminishing returns.",
    "domains": [
      "Shared"
    ],
    "id": "auto_reset_Shared_98cb9029",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "auto_reset",
    "status": "available",
    "timestamp": "2026-07-17T13:45:52.051601+00:00",
    "title": "[Reset] Fresh approach in Shared"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Mathematics is full of impossibility theorems \u2014 things that CANNOT be done. But impossibility theorems are themselves beautiful mathematical objects. Catalog and interconnect the great impossibilities: (1) Squaring the circle (pi is transcendental, Lindemann 1882). (2) Trisecting the angle (cos 20 degrees has degree 3 over Q, Wantzel 1837). (3) Doubling the cube (cube root of 2 has degree 3, Wantzel 1837). (4) Solving the quintic by radicals (A_5 is not solvable, Abel-Ruffini 1824). (5) The Borsuk-Ulam impossibility (every continuous map S^n -> R^n has a point where f(x) = f(-x)). (6) Arrow's impossibility (no voting system is simultaneously fair, complete, and non-dictatorial). (7) Heisenberg's uncertainty (Delta x * Delta p >= hbar/2). Conjecture: These impossibility theorems are connected by a deep structural principle \u2014 each one arises because a certain group action is not free. Squaring the circle fails because Gal(Q(pi)/Q) acts freely. Solving the quintic fails because A_5 acts freely on the roots. Arrow's theorem fails because the symmetric group acts freely on preferences. Heisenberg fails because the Heisenberg group acts freely on phase space. The unified principle: a task is impossible iff the relevant group action is free. Test: verify that each impossibility theorem corresponds to a free group action. Prove the converse: if a group G acts freely on a set X, then there exists a G-equivariant task that is impossible on X. Impact: all impossibility is the same impossibility \u2014 every CAN'T is a reflection of a free group action.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0231",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-17T14:13:42.052368+00:00",
    "title": "Impossibility Results for Fun: Things That Cannot Be Done (But We Try Anyway)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The brain's connectome is a braid: neurons fire in sequences that interleave like strands of a braid group. Formalize this: a cognitive process is an element of the braid group B_n where n is the number of brain regions. Two cognitive processes are equivalent if their braids are related by Reidemeister moves (cognitive equivalence). Conjecture: The Jones polynomial of a cognitive braid is invariant under cognitive equivalence and encodes the information content of the thought. A thought with Jones polynomial V(t) = 1 is a trivial thought (equivalent to no thinking). A thought with V(t) = -t^2 + t + 1 is a creative thought (it contains a trefoil knot \u2014 the simplest non-trivial braid). The information content of a thought is log(|V(e^{2pi i/3})|), which measures the quantum dimension of the braid. Test: compute the Jones polynomial of braids representing simple cognitive processes (linear reasoning: trivial braid, creative insight: trefoil, confused thinking: figure-eight knot) and verify that the quantum dimension correlates with subjective ratings of thought quality. Impact: thinking IS braiding. The topology of your thoughts determines their quality. Creative insights are literally knotted.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0223",
    "priority_score": 0.81,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-17T13:28:40.977519+00:00",
    "title": "Knots That Think: Cognition as Braiding in Category Theory"
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
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Second Order Differential Operators on Graphs' and formalize its key results. Abstract: The commutator of a pair of vector fields on a graph is not a vector field in general, but rather a second order differential operator. We investigate this departure from the classical case of vectors fields on a manifold by examining the geometry of balls of radius two, concentrating on the set of paths of length two connecting a given vertex with the center of the ball. There is a natural surjection from the space of sections of the second tangent bundle to the space of second order differential operators whose kernel reflects the geometry of these balls. Using this map we draw several conclusions about second order differential operators including canonical forms, formulas for their adjoints, and a necessary and sufficient condition for a commutator to be a vector field.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0060",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13266v1",
    "status": "available",
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
    "description": "Investigate the ArXiv paper 'Learning the Graphical Nature of Symmetries' and formalize its key results. Abstract: Finite groups are rigid algebraic objects, whose Cayley graphs expose a rich network geometry through which group-theoretic structure can be measured, compared, and learned. In this paper, a dataset of $131{,}406$ Cayley graphs is constructed, covering all groups of order at most $767$ except order $512$, recording exact algebraic labels for group properties together with a broad collection of graph, cycle, distance, and spectral statistics. This census aims to provide novel benchmarks for studying how finite-group properties are reflected in Cayley graph observables. It also yields new enumerative contributions: alongside recovering known OEIS sequences for standard group classes, new sequences for monolithic groups and for groups generated by at most three, four, and five elements are contributed to the OEIS. The accompanying network analysis identifies several empirical regularities and formulates testable conjectures, including relationships involving square clustering, Cayley grap",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0064",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12026v1",
    "status": "available",
    "timestamp": "2026-07-16T05:49:09.739406+00:00",
    "title": "ArXiv paper: Learning the Graphical Nature of Symmetries"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Expansions of $\\binom{pn}{p+r}$ in Shifted Binomial Bases and a Modular Symmetry Criterion' and formalize its key results. Abstract: We study the expansion of the polynomial $g_{p,r}(n) = \\binom{pn}{p+r}$ (for integers $p \\ge 2$ and $r \\ge 1$) in the shifted binomial basis $\\bigl\\{\\binom{n+k-1}{p+r}\\bigr\\}$. Using generating functions and finite differences, we obtain a closed-form formula for the expansion coefficients $B_{p,r,k}$. We then characterize when the coefficient sequence is palindromic, showing that it exhibits reflection symmetry on its support if and only if $r \\equiv 1 \\pmod{p}$. The proof combines an analysis of the sequence's support with the root structure of $\\binom{pX}{p+r}$. Under the same congruence condition, we show that $p$ divides every coefficient. For $r=1$, the leading coefficient simplifies to $p C_p$, where $C_p$ is the $p$-th Catalan number. Finally, computations for small values of $p$ and $r$ show that the resulting coefficient sequences coincide with selected rows of $p$-decimated multinomial triangles (OEIS A027907 and A008287).",
    "domains": [
      "Logic"
    ],
    "id": "fd_0065",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12173v1",
    "status": "available",
    "timestamp": "2026-07-16T06:20:31.167605+00:00",
    "title": "ArXiv paper: Expansions of $\\binom{pn}{p+r}$ in Shifted Binomial Bases and a Modular Symmetry Criterion"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A few remarks on the Baez-Duarte Criterion' and formalize its key results. Abstract: The goal of this paper is to derive a few very interesting lemmas related to the B\u00e1ez-Duarte criterion.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0066",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12084v1",
    "status": "available",
    "timestamp": "2026-07-16T06:36:12.474914+00:00",
    "title": "ArXiv paper: A few remarks on the Baez-Duarte Criterion"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Induced-Minor-Closed Classes have Linear, Square-Root, or Sub-Polynomial Tree-Independence' and formalize its key results. Abstract: An independent set in a graph $G$ is a set of pairwise non-adjacent vertices. A tree decomposition of $G$ is a pair $(T, \u03c7)$ where $T$ is a tree and $\u03c7: V(T) \\rightarrow 2^{V(G)}$ is a function satisfying two axioms: for every edge $uv \\in E(G)$ there is an $x \\in V(T)$ such that $\\{u,v\\} \\subseteq \u03c7(x)$, and for every vertex $u \\in V(G)$ the set $\\{x \\in V(T) | u \\in \u03c7(x)\\}$ induces a non-empty and connected subtree of $T$. The sets $\u03c7(x)$ for $x \\in V(T)$ are called the bags of the tree decomposition. The tree-independence number of $G$ is the minimum taken over all tree decompositions of $G$ of the maximum size of an independent set of the graph induced by a bag of the decomposition. A graph $H$ is an induced minor of a graph $G$ if a graph isomorphic to $H$ can be obtained from $G$ by vertex deletions and edge contractions. We prove that for every $t\\in\\mathbb{N}$ there exists an $\u03b5> 0$ such that every graph $G$ either contains the complete bipartite graph $K_{t,t}$ or the wall $W_",
    "domains": [
      "Logic"
    ],
    "id": "fd_0068",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12090v1",
    "status": "available",
    "timestamp": "2026-07-16T07:08:32.831275+00:00",
    "title": "ArXiv paper: Induced-Minor-Closed Classes have Linear, Square-Root, or Sub-Polynomial Tree-Independence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Computing Tools for Translation-Invariant Total Orders' and formalize its key results. Abstract: We introduce TITO_Explore, a software package for representing and computing with Translation-Invariant Total Orders (TITOs). We define a canonical window notation for TITOs and design and implement algorithms for several computational tasks involving them. The package normalizes the window notation of a given TITO into its canonical form, computes its inversion set, compares the weak order between two TITOs, and computes the join of two specified TITOs. Our weak order comparison algorithm operates by partitioning the inversion sets into disjoint subsets, thereby breaking down the comparison problem into evaluations of paired subsets. The join algorithm uses an edge-weighted directed graph to represent inversions and converts the problem of finding the join into a weighted path problem in the graph.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0069",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11709v1",
    "status": "available",
    "timestamp": "2026-07-16T08:29:29.363557+00:00",
    "title": "ArXiv paper: Computing Tools for Translation-Invariant Total Orders"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Intrinsic ergodicity for $\\mathfrak{B}$-free integers in number fields' and formalize its key results. Abstract: Let $K$ be a number field with ring of integers $\\mathscr{O}_K$, and let $\\mathfrak{B}$ be an Erd\u0151s family of ideals in $\\mathscr{O}_K$. We prove that the associated $\\mathfrak{B}$-free subshift $(X_{\\mathfrak{B}},(S_a)_{a\\in\\mathscr{O}_K})$ is intrinsically ergodic: it carries a unique measure of maximal entropy, which we identify explicitly as a relatively independent extension of the Haar rotation on $\\prod_{\\mathfrak{b}\\in\\mathfrak{B}}\\mathscr{O}_K/\\mathfrak{b}$. This is the first proof of intrinsic ergodicity for $\\mathfrak{B}$-free systems beyond dimension one, and relies on the work of Ara\u00fajo--Dymek--Ku\u0142aga-Przymus. Via their reductions, we also settle the $k$-free and $\\mathfrak{B}$-free lattice-point cases and the $k$-free number-field case. We give \\emph{two independent proofs} of the underlying rigidity statement: one through a single-site relative-entropy argument, and one through an exact-tiling realisation of Peckner's induce-and-split scheme.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0070",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11330v1",
    "status": "available",
    "timestamp": "2026-07-16T09:49:53.470832+00:00",
    "title": "ArXiv paper: Intrinsic ergodicity for $\\mathfrak{B}$-free integers in number fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'An asymptotic Sidon basis of order $3-\u03b7$' and formalize its key results. Abstract: Pilatte recently proved that there exists an infinite Sidon set of positive integers which is an asymptotic basis of order $3$, answering a problem posed by Erd\u0151s, S\u00e1rk\u0151zy and S\u00f3s in 1994. In this paper, we strengthen this result by proving that for any $0<\u03b7<0.0527$, there exists an infinite Sidon set $\\mathcal{S}\\subset \\mathbb{N}$ which is an asymptotic basis of order $3-\u03b7$; that is, every sufficiently large integer $m$ can be represented as \\[ m=s_1+s_2+s_3 \\] for some $s_1,s_2,s_3\\in \\mathcal{S}$ satisfying \\[ \\min\\{s_1,s_2,s_3\\}\\leq m^{1-\u03b7}. \\] To prove this, we develop a truncated version of Pilatte's construction and use a deep result of Sawin on sums of Dirichlet convolutions of the von Mangoldt function over function fields.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0071",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11351v1",
    "status": "available",
    "timestamp": "2026-07-16T10:05:35.111976+00:00",
    "title": "ArXiv paper: An asymptotic Sidon basis of order $3-\u03b7$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The combinatorics of sector renormalization' and formalize its key results. Abstract: The goal of this note is to systematically develop the fundamental arithmetic and combinatorial properties of the sector renormalization operation on rigid rotations. We employ the specific framework of modified continued fractions appropriate for sector renormalization and analyze their properties. By allowing infinite first return times, this framework yields a dynamical compactification characterized by a universal property. We also discuss the corresponding natural extension and introduce the notion of a time (semi-)group. For example, we demonstrate how a bi-infinite tower of sector renormalizations of irrational rotations can be packaged within a single dynamical plane as a cascade of translations. This note will serve as a foundational combinatorial tool for studying the geometric properties of sector renormalizations of holomorphic maps with irrationally indifferent fixed points, particularly neutral quadratic polynomials.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0072",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11408v1",
    "status": "available",
    "timestamp": "2026-07-16T10:22:21.276285+00:00",
    "title": "ArXiv paper: The combinatorics of sector renormalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Arithmetic Properties for $k$-Color Analogue of Simultaneously $s$-Regular and $t$-Distinct Partitions' and formalize its key results. Abstract: In this article, we discuss general generating functions for partitions of $n$, simultaneously $s$-regular and $t$-distinct in 3-colors. In addition, we obtain infinite families of congruences modulo powers of 3 for specific values of $(\\ell,t)$. For instance, for positive integers $n$ and $k$, we have \\begin{align*} \\sum_{n=o}^{\\infty}RD_3^{3,3}\\left(3^kn+\\frac{3^k+1}{2}\\right)q^n\\equiv0 \\pmod{3^{k+1}}. \\end{align*}",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0073",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11499v1",
    "status": "available",
    "timestamp": "2026-07-16T10:38:16.188646+00:00",
    "title": "ArXiv paper: Arithmetic Properties for $k$-Color Analogue of Simultaneously $s$-Regular and $t$-Distinct Partitions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Sufficient conditions for $(K_2 \\cup kK_1)$-free graphs to be Hamilton-connected' and formalize its key results. Abstract: The toughness of a non-complete graph $G$, denoted $\u03c4(G)$, is defined as \\[ \u03c4(G) = \\min\\left\\{ \\frac{|S|}{\u03c9(G-S)} : S \\subseteq V(G),\\ \u03c9(G-S) \\geq 2 \\right\\}, \\] where $\u03c9(G-S)$ is the number of components of $G - S$. For a complete graph $G$, we define $\u03c4(G) = \\infty$. A graph $G$ is $t$-tough if $\u03c4(G) \\geq t$. For a positive integer $k$, a graph $G$ is $(K_2 \\cup kK_1)$-free if it contains no induced subgraph isomorphic to $K_2 \\cup kK_1$. Recently, Liu \\cite{liu} showed that every $2k$-connected $(K_2 \\cup kK_1)$-free graph $G$ with $\u03c4(G) > 1$ is Hamilton-connected. In this paper, we strengthen this result by proving that every $(k+1)$-connected $(K_2 \\cup kK_1)$-free graph $G$ with $\u03c4(G) > 1$ and minimum degree $\u03b4(G) \\geq 2k$ is Hamilton-connected. Moreover, by imposing restrictions to the independence number $\u03b1(G)$, we prove that every $k$-connected $(K_2 \\cup kK_1)$-free graph $G$ of order $n$ with $2k+1 \\leq \u03b1(G) < \\frac{n}{2}$ and $\u03b4(G) \\geq 2k$ is Hamilton-connected, and that t",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0074",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11373v1",
    "status": "available",
    "timestamp": "2026-07-16T10:53:48.349640+00:00",
    "title": "ArXiv paper: Sufficient conditions for $(K_2 \\cup kK_1)$-free graphs to be Hamilton-connected"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Proximity Measures for Classes of Phylogenetic Networks' and formalize its key results. Abstract: Phylogenetic networks are used to represent the evolutionary history of species. Due to biological interpretations and computational advantages, researchers have focused on restricted classes of phylogenetic networks, such as tree-child, orchard, and tree-based. These classes capture different notions of tree-likeness: tree-child networks require every internal vertex to have a taxon reachable by a tree path, orchard networks are trees with horizontal arcs (for modelling histories rife with horizontal gene transfers), and tree-based networks are trees with additional (not-necessarily horizontal) arcs. A natural question to ask is ``how far is a given network from belonging to a particular class?'' This motivates the study of proximity measures, which measure the minimum number of graph modifications required to transform a network into one belonging to a particular class. In this paper, we consider three proximity measures based on leaf addition, valid arc deletion, and arc deletion. W",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_0075",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11325v1",
    "status": "available",
    "timestamp": "2026-07-16T11:09:11.992989+00:00",
    "title": "ArXiv paper: Proximity Measures for Classes of Phylogenetic Networks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On Small Doubling in Right-Ordered Groups and Baumslag-Solitar Groups-II' and formalize its key results. Abstract: Recently, Mohan et al. [Results Math. 80 (2025), No. 4, 122] answered Freiman's $3k-4$ conjecture in right-ordered groups under certain restrictions. In this paper, we take a step further by investigating the structure of nonempty subsets $S$ of a right-ordered group satisfying the small doubling condition $|S^2| = 3|S|-3$. Moreover, we provide a complete characterization of all nonempty finite subsets $S$ of the Baumslag-Solitar group $\\mathrm{BS}(1,q)$ (with $q \\in \\mathbb{Z}$ and $q \\neq -1$) for which $|S^2| = 3|S|-3$ and the identity element is the minimum of $S$.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0076",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11194v1",
    "status": "available",
    "timestamp": "2026-07-16T11:25:22.149755+00:00",
    "title": "ArXiv paper: On Small Doubling in Right-Ordered Groups and Baumslag-Solitar Groups-II"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Optimal chain density, entropy, and space-time tradeoffs for the TSP' and formalize its key results. Abstract: We nearly settle a natural extremal question about set systems over $[n]$: the tradeoff between the {size} (number of sets) and the number of {full chains}. This question was initially raised by Johnson, Leader, and Russell [Combin.~Probab.~Comp., 2015] as a counterpart to Sperner-type results in combinatorics. Recently, a framework introduced by Ameli, Nederlof, and Wang, and independently by Dallant and Kozma [FOCS 2026] linked this question to the space- and time-complexity of Bellman-Held-Karp-style dynamic programming algorithms for permutation problems such as the traveling salesman (TSP). Precisely, they showed that a space-time product $\u03b3^{n+o(n)}$ is feasible for the TSP, whenever a set system of (normalized) size $S$ and chain density $D$ exists, with $ \u03b3= S^2/D$. In this paper we show an essentially {optimal} bound of $\u03b3\\approx 3.1819$ for this quantity, closing the gap between the previous best lower and upper bounds of $\u03b3\\geq 3.015$ and $ \u03b3\\leq 3.572$ respectively. This im",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0077",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11311v1",
    "status": "available",
    "timestamp": "2026-07-16T11:40:55.930817+00:00",
    "title": "ArXiv paper: Optimal chain density, entropy, and space-time tradeoffs for the TSP"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Bounded-Support Additive Latin Transversals via Color-Counted Matching' and formalize its key results. Abstract: We consider the following additive Latin transversal problem. Given a multiset $A=(a_1,\\dots,a_k)$ of elements of $\\mathbb Z_m$ and a set $B\\subseteq\\mathbb Z_m$ of cardinality $k$, the task is to order $B$ as $b_1,\\dots,b_k$ so that the sums $a_i+b_i$ are pairwise distinct. When $k=m$, Hall proved that a solution exists if and only if $\\sum_{i=1}^m a_i\\equiv 0 \\pmod m$; moreover, his theorem yields a polynomial-time construction. Alon proved that a solution always exists when $m$ is prime and $k<m$, but no polynomial-time construction is known in general. Our main algorithmic contribution is a direct randomized algorithm for Color-Counted Matching: given an edge-colored graph and prescribed target counts for the colors, find a matching using exactly the prescribed number of edges of each color. If $q$ is the sum of the target counts and $h$ is the number of colors, our base-$(q+1)$ reduction to Exact Red Matching, combined with the algorithm of Mulmuley-Vazirani-Vazirani, gives a rand",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_0078",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11241v1",
    "status": "available",
    "timestamp": "2026-07-16T11:56:23.621922+00:00",
    "title": "ArXiv paper: Bounded-Support Additive Latin Transversals via Color-Counted Matching"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Two local zero-sum problems' and formalize its key results. Abstract: In the present paper, we investigate two local zero-sum problems. Let $n,k\\ge 2$. We denote by $\\mathsf{D}^*(n,nk)$ (resp. $\u03b7^{*}(n,nk)$) the smallest positive integer $\\ell$ (if exists) such that, from any given $\\ell$ integers not divisible by $n$, one can select some (resp. at most $n$) of them whose sum is divisible by $n$ but not by $nk$. We prove that both $\\mathsf{D}^*(n,nk)$ and $\u03b7^{*}(n,nk)$ are equal to $2n-1$ if $\\mathrm{rad}(n) \\mid \\mathrm{rad}(k)$ and infinite otherwise. The corresponding inverse problem is also determined. We denote by $\\mathsf{D}_n^{\\times}$ (resp. $\u03b7_n^{\\times}$) the smallest positive integer $\\ell$ such that, from any given $\\ell$ integers coprime to $n$, one can select some (resp. at most $n$) of them whose sum $\u03c3$ satisfies $\\gcd(\u03c3, n^2)=n$. We prove that $\\mathsf{D}_n^{\\times}=\u03b7_n^{\\times}=2n-1$ if $n$ is a prime power, and determine its inverse problem.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0079",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11313v1",
    "status": "available",
    "timestamp": "2026-07-16T12:11:54.864256+00:00",
    "title": "ArXiv paper: Two local zero-sum problems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Zero-one laws for uniform approximation via Gaussian and Eisenstein integers' and formalize its key results. Abstract: We establish two distinct zero-one laws for the uniform Diophantine approximation of complex numbers by quotients of Gaussian integers and by quotients of Eisenstein integers. Using tools from homogeneous dynamics, we study this problem by reducing to a shrinking target problem on certain homogeneous spaces of $\\mathrm{SL}_2(\\mathbb{C})$. The main novel ingredients include measure estimates on a certain family of neighborhoods of the corresponding critical loci, as well as new disjointness statements to control the short-range mixing contribution. Due to the different nature of the critical loci in the Gaussian and Eisenstein cases, these measure estimates are obtained by rather different arguments.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0080",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11178v1",
    "status": "available",
    "timestamp": "2026-07-16T12:28:46.578649+00:00",
    "title": "ArXiv paper: Zero-one laws for uniform approximation via Gaussian and Eisenstein integers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Disproofs of two conjectures concerning nondeficient numbers' and formalize its key results. Abstract: A positive integer $n$ is said to be nondeficient if $\u03c3(n) \\geq 2n$. Letting the positive divisors of a positive integer $n$ be written as $1 = d_0 < d_1 < \\cdots < d_k < d_{k+1} = n$, and letting $\\mathcal{S}$ denote a set of integers, if there exist values $\u03bb_j \\in \\mathcal{S}$ such that $1 + \\sum_{j=1}^{k} \u03bb_j d_j = n$, then $n$ is said to be an $\\mathcal{S}$-perfect number. Ross, in 2024, introduced the study of $\\mathcal{S}$-perfect numbers, and concluded with two conjectures that each concern both $\\{ -1, 1 \\}$-perfect numbers and nondeficient numbers. We disprove both of these conjectures.",
    "domains": [
      "Pythagorean",
      "Logic"
    ],
    "id": "fd_0082",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11043v1",
    "status": "available",
    "timestamp": "2026-07-16T13:00:57.755694+00:00",
    "title": "ArXiv paper: Disproofs of two conjectures concerning nondeficient numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A tight single-change covering design with block size 6' and formalize its key results. Abstract: We give a tight single-change covering design with $v=26$ and $k=6$. This answers Problem 1 of the Nineteenth British Combinatorial Conference, which asked whether such a design exists with block size greater than $5$. We also describe the satisfiability search that found the design, including negative search results at the smallest admissible order $v=21$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0083",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10978v1",
    "status": "available",
    "timestamp": "2026-07-16T13:16:54.044719+00:00",
    "title": "ArXiv paper: A tight single-change covering design with block size 6"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Positivity and tails of Jacobi theta series' and formalize its key results. Abstract: Using elementary $q$-series manipulations, we establish a positivity property for the tails of the Jacobi theta series. Specifically, for integers $k\\ge 1$ and $n\\ge 0$, define \\[ \\sum_{n\\ge0}\\sum_{m\\in\\mathbb{Z}}J_{k,n}(m)z^m q^{n} = \\frac{(-1)^k q^{-\\binom{k+1}{2}}}{(z)_{\\infty}(q/z)_\\infty} \\sum_{j\\ge k}(-1)^jq^{\\binom{j+1}{2}}z^{-j}(1-z^{2j+1}), \\] where $(a)_\\infty:=\\prod_{n\\ge0}(1-aq^n)$ denotes the $q$-shifted factorial. We prove that for all integers $k\\ge 1$ and $n\\ge 0$, the coefficients $J_{k,n}(m)$ are positive for all integers $-(k+n)\\le m\\le k+n$.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0085",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10968v1",
    "status": "available",
    "timestamp": "2026-07-16T13:51:47.387924+00:00",
    "title": "ArXiv paper: Positivity and tails of Jacobi theta series"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Neighborhood Complexity and Radius-1 Merge-Width in Monadically Dependent Graph Classes' and formalize its key results. Abstract: Monadic dependence is a proposed structural dividing line for fixed-parameter tractability of first-order model checking on hereditary graph classes. A graph class is \\emph{monadically dependent} if the class of all graphs cannot be interpreted in its vertex-colored members using a fixed first-order formula. We prove two structural consequences of monadic dependence. First, every monadically dependent class has \\emph{almost linear neighborhood complexity}: for every graph $G$ in the class and every set $A\\subseteq V(G)$, the family $\\{N_G(v)\\cap A : v\\in V(G)\\}$ has size $|A|^{1+o(1)}$. Second, every $n$-vertex graph in a monadically dependent class has radius-1 merge-width $n^{o(1)}$. Here, merge-width is the decomposition parameter of Dreier and Toru\u0144czyk based on construction sequences; its radius-$r$ version measures local reachability among parts through already resolved pairs. This settles the radius-1 case of the conjectured connection between monadic dependence and almost bound",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0086",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10941v1",
    "status": "available",
    "timestamp": "2026-07-16T14:08:15.851346+00:00",
    "title": "ArXiv paper: Neighborhood Complexity and Radius-1 Merge-Width in Monadically Dependent Graph Classes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Overfull Conjecture for graphs with maximum degree 4' and formalize its key results. Abstract: Let $G$ be a simple graph with maximum degree $\u0394(G)$. The graph $G$ is overfull if $\\left|E(G)\\right|> \u0394(G)\\lfloor |V(G)|/2\\rfloor$. In 1986, Chetwynd and Hilton proposed the Overfull Conjecture: If $G$ is a simple graph with $\u0394(G)>\\frac{|V(G)|}{3}$, then $G$ is a Class $2$ graph if and only if $G$ contains an overfull subgraph $H$ with $\u0394(H)=\u0394(G)$. In this paper, we give a proof of this conjecture for graphs with maximum degree $4$.",
    "domains": [
      "Pythagorean",
      "Logic"
    ],
    "id": "fd_0087",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10947v1",
    "status": "available",
    "timestamp": "2026-07-16T14:24:51.157046+00:00",
    "title": "ArXiv paper: Overfull Conjecture for graphs with maximum degree 4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Sums of Kloosterman sums formed with modular symbols' and formalize its key results. Abstract: We study sums of Kloosterman sums formed with a modular symbol. Employing Tauberian methods, we first give an estimate for a (Riesz) sum of Ramanujan sums formed with a modular symbol. We further define a zeta function that is analogous to the Selberg zeta function, establish its continuation to $\\Re(s)>1/2$, give estimates for its growth and use this to prove a cancellation statement for sums of these twisted Kloosterman sums. We explain the connection of this construction to the eigenvalue 1/4 problem and formulate an analogue of Linnik's conjecture. Finally, we present numerical evidence that there is cancellation and also that the Kloosterman sums with a modular symbol are not correlated with classical Kloosterman sums.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0088",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10786v1",
    "status": "available",
    "timestamp": "2026-07-16T14:42:47.748036+00:00",
    "title": "ArXiv paper: Sums of Kloosterman sums formed with modular symbols"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Properties of the Tropical Characteristic Polynomial of Symmetric Matrices' and formalize its key results. Abstract: We investigate the combinatorial structure of the tropical characteristic polynomial of symmetric matrices using the tropical permanents of their principal submatrices. We establish new inequalities for the leading coefficients of the tropical characteristic polynomial, revealing concavity properties of the coefficient sequence and yielding necessary conditions for a sequence to arise as the coefficient sequence of the tropical characteristic polynomial of a symmetric matrix. These results provide a deeper understanding of the structure of tropical characteristic polynomials associated with symmetric matrices.",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0089",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10922v1",
    "status": "available",
    "timestamp": "2026-07-16T14:59:48.946358+00:00",
    "title": "ArXiv paper: Properties of the Tropical Characteristic Polynomial of Symmetric Matrices"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Kloosterman sign changes with moduli having at most five prime factors' and formalize its key results. Abstract: On square-free moduli $q\\in(X,2X]$ having at most five prime factors, we prove that each sign of the normalized Kloosterman sum $\\operatorname{Kl}(1;q)$ occurs $\\gg X/\\log X$ times. This improves the recent unconditional result of Zhang and Zhong for moduli with at most six prime factors. Building on their analytic estimates and optimized Selberg sieve, we replace their truncated divisor penalty by a geometric half-weight. The new weight retains the $P_5$ exclusion threshold and is a positive linear combination of two standard two-parameter truncated divisor weights, so the Zhang--Zhong transference argument applies without alteration. After transference, the relevant pointwise coefficient is reduced from $5/16$ to $5/32$, which yields a positive final sieve margin.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0090",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10862v1",
    "status": "available",
    "timestamp": "2026-07-16T15:16:07.360291+00:00",
    "title": "ArXiv paper: Kloosterman sign changes with moduli having at most five prime factors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Torsion groups of rational elliptic curves over $\\mathbb{Z}_p$-extensions of quadratic fields: the $p\\le 5$ case' and formalize its key results. Abstract: Let $E$ be a rational elliptic curve. We generalize a theorem due to Avc\u0131\\cite{AVCI2026153}, which asserts that for any quadratic field \\(K\\) and prime \\(p>5\\), the equality \\(E(K)_{\\mathrm{tors}} = E(L)_{\\mathrm{tors}}\\) holds for every \\(\\mathbb{Z}_p\\)-extension \\(L/K\\). In this paper, we consider the setting where the \\(\\mathbb{Z}_p\\)-extension \\(L\\) is replaced by the compositum \\(K_{\\infty}\\) of all \\(\\mathbb{Z}_p\\)-extensions of \\(K\\). Under this new setting, we prove the analogous statement for \\(p=5\\), and further provide partial results for the remaining primes \\(p=3\\) and \\(p=2\\).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0091",
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
    "id": "fd_0092",
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
    "id": "fd_0093",
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
    "id": "fd_0094",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13490v1",
    "status": "available",
    "timestamp": "2026-07-16T03:36:37.823776+00:00",
    "title": "ArXiv paper: On the Second Moment of $L (1/2, \\mathrm{As} (f))$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Quantum determinants in polynomial time' and formalize its key results. Abstract: We give an algebraic branching program of polynomial size which computes Cayley determinant of right quantum matrices. This is a rare example of an efficient computation of a noncommutative determinant, and the first such example for quantum groups. We extend the results to the $q$-Cayley determinant of $q$-right quantum matrices, as well as to their multiparameter generalization. The proofs are entirely combinatorial, as we relate Cayley, Moore and Valiant determinants using bijections/involutions on words. We then employ the celebrated determinant construction of Mahajan and Vinay (SODA'97), to obtain the results.",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0096",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13186v1",
    "status": "available",
    "timestamp": "2026-07-16T04:10:55.100427+00:00",
    "title": "ArXiv paper: Quantum determinants in polynomial time"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Graph Puzzles III.1: A Proof of Sabidussi's Compatibility Conjecture' and formalize its key results. Abstract: We prove Sabidussi's compatibility conjecture. Let $G$ be a finite connected multigraph in which every vertex has even degree and the minimum degree is at least four, and let $T$ be a closed trail that traverses every edge exactly once. The edges of $G$ can be partitioned into circuits (connected 2-regular subgraphs) so that no circuit contains the two edges used consecutively anywhere in $T$. In fact, the edges can be four-coloured so that every such pair receives two different colours and the subgraph formed by the edges of each colour has even degree at every vertex. Formalization in Lean 4 is also available in the author's github.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0097",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13225v1",
    "status": "available",
    "timestamp": "2026-07-16T04:27:14.823265+00:00",
    "title": "ArXiv paper: Graph Puzzles III.1: A Proof of Sabidussi's Compatibility Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On some structural properties of graphs with non-negative resistance curvature' and formalize its key results. Abstract: A graph is called resistance nonnegative (RN), respectively resistance positive (RP), if it admits positive edge weights such that all vertex resistance curvatures are nonnegative, respectively positive. In this paper, we study the structure of RN and RP graphs in relation to toughness, traceability, and Cartesian products. First, we disprove a conjecture of Fiedler and answer a question of Devriendt in the negative by constructing, for every $n\\ge 11$, an $n$-vertex $1$-tough graph that is not RN. Second, we show that RP graphs need not be traceable by proving that the Thomassen $34$-graph is RP but not traceable. Finally, we resolve a conjecture of Devriendt on grid graphs by proving that all Cartesian products of paths are RN.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0098",
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
    "id": "fd_0099",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13159v1",
    "status": "available",
    "timestamp": "2026-07-16T04:59:11.546572+00:00",
    "title": "ArXiv paper: Beyond Mock Modularity: Elliptic Corrections for Higher Dyson Ranks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On nontrivial cross-2-intersecting families' and formalize its key results. Abstract: Two families \\(\\mathcal{A}\\subseteq\\binom{[n]}{k}\\) and \\(\\mathcal{B}\\subseteq\\binom{[n]}{\\ell}\\) are said to be nontrivial cross-\\(t\\)-intersecting if \\(|A \\cap B| \\geq t\\) for all \\(A \\in \\mathcal{A}\\) and \\(B \\in \\mathcal{B}\\), and $|\\bigcap_{A\\in \\mathcal{A}\\cup \\mathcal{B}}A|<t$. In this paper, we determine the upper bound on \\(|\\mathcal{A}||\\mathcal{B}|\\) of two nontrivial cross-\\(2\\)-intersecting families \\(\\mathcal{A}\\subseteq\\binom{[n]}{k}\\) and \\(\\mathcal{B}\\subseteq\\binom{[n]}{\\ell}\\) for any positive integers $n,k,\\ell$ with \\(k\\geq \\ell \\geq 3\\) and \\(n \\geq 3(k-1)\\). Moreover, we characterize the extremal families attaining this bound. This settles the last unsolved case of a recent result by He, Li, Wu and Zhang (J. Combin. Theory Ser. A, 217 (2026) 106095).",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0100",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12239v1",
    "status": "available",
    "timestamp": "2026-07-16T06:36:16.940988+00:00",
    "title": "ArXiv paper: On nontrivial cross-2-intersecting families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On strongly regular signed graphs of higher girth' and formalize its key results. Abstract: Strongly regular signed graphs are an extension of strongly regular graphs to the realm of signed graphs, that is, graphs where each edge is positive or negative. Unlike with ordinary strongly regular graphs, most kinds of signed counterparts with girth 4 or higher are describable in terms of known structures. We prove that those with girth 4 that are bipartite are classified by designs of two kinds: weighing matrix designs and symmetric block designs. Those of girth 5 are few and readily described. There are none of higher girth. Those with girth 4 that are not bipartite are unsolved.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0101",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.12131v1",
    "status": "available",
    "timestamp": "2026-07-16T06:51:57.150644+00:00",
    "title": "ArXiv paper: On strongly regular signed graphs of higher girth"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Tropical Circuits with Scalar Multiplication Gates' and formalize its key results. Abstract: We study tropical circuits with scalar multiplication gates, that is, algebraic circuits whose gates implement $\\max$, $+$, or multiplication with a positive constant. For such circuits, we prove exponential size lower bounds for computing maximum weight directed spanning trees and maximum weight bipartite perfect matchings. As a corollary, we obtain an exponential size separation between monotone and non-monotone maxout neural networks, which generalize the popularly used ReLU neural networks. One conclusion from this is that neural network models with enforced convexity constraints, such as input-convex neural networks (ICNNs), sometimes need to be exponentially larger than their unrestricted counterparts in order to express the same functions.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0102",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11540v1",
    "status": "available",
    "timestamp": "2026-07-16T08:29:33.287561+00:00",
    "title": "ArXiv paper: Tropical Circuits with Scalar Multiplication Gates"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Fractal uncertainty principle over $\\mathbb{Q}_p$' and formalize its key results. Abstract: We prove a fractal uncertainty principle over $\\mathbb{Q}_p$ for porous sets, resolving a conjecture of Cohen.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0103",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11534v1",
    "status": "available",
    "timestamp": "2026-07-16T10:05:38.552774+00:00",
    "title": "ArXiv paper: Fractal uncertainty principle over $\\mathbb{Q}_p$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Moment-based PPT criteria for random bipartite states' and formalize its key results. Abstract: Moment-based relaxations of the positive partial transpose (PPT) criterion have been recently introduced, as a hierarchy of entanglement criteria involving only experimentally accessible quantities of a given bipartite state. The goal of this work is to study their typical detection performance on high-dimensional bipartite systems. Concretely, we investigate whether random bipartite mixed states on $\\mathbb C^d\\otimes\\mathbb C^d$, obtained as the marginal over an environment $\\mathbb C^s$ of a uniformly distributed pure state, generically satisfy or violate them. For each fixed level $m\\in\\mathbb N$ in this hierarchy of moment-based PPT criteria, we are able to identify a threshold environment dimension $s=\u03bb_md^2$ at which the behavior of the associated random state switches from violating to satisfying it, with probability going to $1$ as $d$ grows. The proof combines combinatorics of permutations techniques to estimate the average value of moments of partially transposed random stat",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "fd_0104",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11369v1",
    "status": "available",
    "timestamp": "2026-07-16T10:22:25.105596+00:00",
    "title": "ArXiv paper: Moment-based PPT criteria for random bipartite states"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Polynomial-Time Evaluation of Aardal-Lenstra Denumerants via Constant Term Method' and formalize its key results. Abstract: Aardal and Lenstra systematically studied hard knapsack problems of the form $a_1x_1+\\cdots+a_nx_n=b$, where $a_i=p_iM+r_iN$, $(M,N)$ is a coprime pair of positive integers, and the integers $|p_i|, |r_i|$ are small relative to $M$ and $N$. We investigate the corresponding challenging denumerant problem (i.e., counting the number of nonnegative integer solutions) and present a polynomial-time algorithm. This eliminates the computational bottlenecks caused by large values of $M$, $N$ and $b$. The proposed algorithm achieves a time complexity of $O(n^4\u0394^2\\log n\\log\u0394)$, which depends solely on the parameters $n$ and $\u0394=\\max_{i,j}|r_i p_j - r_j p_i|$. Moreover, we consider the problem of expressing a general vector $(a_1,\\dots,a_n)$ in the above form using the LLL algorithm.",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_0105",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11477v1",
    "status": "available",
    "timestamp": "2026-07-16T10:38:19.903223+00:00",
    "title": "ArXiv paper: Polynomial-Time Evaluation of Aardal-Lenstra Denumerants via Constant Term Method"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Finding Nearly-Periodic Components in Digraphs and Markov Chains from the Spectrum of Rotated Laplacian Matrices' and formalize its key results. Abstract: Inspired by recent advances in notions of spectral approximation of digraphs [Ahm+20], we study spectral algorithms for finding periodic structures in digraphs via the spectrum of a class of rotated Laplacian matrices. This class of Laplacian matrices was previously studied by Lange, Liu, Peyerimhoff, and Post [Lan+15]. We consider a notion of periodicity ratio that generalizes the bipartiteness ratio of Trevisan [Tre09], and show that it is closely related to the spectrum of rotated Laplacian matrices. In particular, if the digraph is strongly connected and represents a Markov chain, this periodicity ratio for a given $p \\in \\mathbb{N}$ is a quantitative measure of how close this Markov chain is to having periodicity $p$. We propose and analyze a periodicity-ratio variant of the spectral algorithm by Louis, Raghavendra, Tetali and Vempala [Lou+12]. We show that the algorithm runs in randomized polynomial time and can find many nearly periodic components (i.e, components with small per",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0106",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11333v1",
    "status": "available",
    "timestamp": "2026-07-16T10:53:52.382469+00:00",
    "title": "ArXiv paper: Finding Nearly-Periodic Components in Digraphs and Markov Chains from the Spectrum of Rotated Laplacian Matrices"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Combinatorial interpretation of the coefficients of the order polynomial of fence posets' and formalize its key results. Abstract: Given a fence poset P , we define a new statistic on permutations, denoted by blP, that provides a combinatorial interpretation of the coefficients of the order polynomial of P , answering a question of Ferroni, Morales, and Panova (2025). Using the fact that the base polytope of a lattice path matroid can be decomposed into order polytopes of fence posets, we also obtain a combinatorial interpretation of the coefficients of the Ehrhart polynomial of the base polytope of Schubert matroids, answering a question of Stanley (1999). As an application of this statistic, we establish the first nontrivial lower bound for the linear coefficient of the Ehrhart polynomial of an order polytope. Finally, we conjecture generalizations of this statistic to skew-shape posets and circular fence posets.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0107",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11225v1",
    "status": "available",
    "timestamp": "2026-07-16T11:09:16.692907+00:00",
    "title": "ArXiv paper: Combinatorial interpretation of the coefficients of the order polynomial of fence posets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A 64-Rectangle Counterexample to Wegner's Conjecture and LP Gaps up to $5/2$' and formalize its key results. Abstract: Wegner conjectured that every finite family $\\mathcal R$ of axis-parallel rectangles satisfies $\u03c4(\\mathcal R)\\le 2\u03bd(\\mathcal R)-1$, where $\u03bd$ is the packing number and $\u03c4$ is the piercing number. Ajwani, Gajjala, Raman, and Ray recently disproved this by constructing a triangle-free counterexample on $2196\\cdot 8^9$ rectangles and, using a computer-assisted package-and-port recursion, obtained a standard LP gap of $17891/8064$ for Maximum Independent Set of Rectangles. We give a simpler and hand-checkable counterexample with $64$ rectangles. It is built from an eight-rectangle gadget whose independent sets inject into four ordered slots; we then use four horizontal and four vertical copies of this gadget to form a triangle-free family with $\u03bd=16$ and $\u03c4\\ge 32$. We use the same horizontal-vertical step to define recursive families of rectangles $P_r$ with $\u03bd(P_r)=4^{2^r}$. For the standard clique, equivalently point, relaxation we obtain a finite gap $73/32$ at $P_3$, improving the prev",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0108",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11318v2",
    "status": "available",
    "timestamp": "2026-07-16T11:25:26.123465+00:00",
    "title": "ArXiv paper: A 64-Rectangle Counterexample to Wegner's Conjecture and LP Gaps up to $5/2$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'p-adic Properties of Translated Division Polynomials and Somos Sequences' and formalize its key results. Abstract: In this paper we consider the sequences $(\u03a8_{n}(\\mathbf{P}))_{n\\geq 0}$, $(\u03a6_{n}(\\mathbf{P}))_{n\\geq 0}$ and $(\\overline{\u03a9}\\,_{n}(\\mathbf{P}% ))_{n\\geq 0}$ of values of the translated division polynomials of an elliptic curve $E/K$ evaluated at a point $\\mathbf{P}\\in $ $E(K)^{2}$. We prove that these sequences are purely periodic when $K$ is a finite field. Then we use the periodicity properties of these sequences to prove that certain subsequences of these sequences are $% %TCIMACRO{\\U{2124} }% %BeginExpansion \\mathbb{Z} %EndExpansion _{p}$-Cauchy. Finally, we use this result to prove analogous results for Somos $4$ and Somos $5$ sequences.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0109",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11261v1",
    "status": "available",
    "timestamp": "2026-07-16T11:40:59.366781+00:00",
    "title": "ArXiv paper: p-adic Properties of Translated Division Polynomials and Somos Sequences"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A dual linear programming bound for sphere packing in dimension 36' and formalize its key results. Abstract: We construct an explicit dual-feasible point for the Cohn-Elkies linear program in dimension 36, built from the space of weight-18 modular forms for $\u0393_0(24)$ following the method of Cohn and Triantafillou. The certificate shows that the two-point linear programming bound on the sphere packing density in dimension 36 exceeds the density of the best packing currently known -- the Kschischang-Pasupathy packing, of center density $2^{18}/3^{10}$ -- by a factor of at least 32.91. In particular, no Cohn-Elkies auxiliary function can certify the best known packing in dimension 36 as optimal. To our knowledge this is the first such dual bound in any dimension above 32, extending the table of Cohn-Triantafillou ($d=12,16,20,28,32$), Li ($3 \\le d \\le 13$), and de Courcy-Ireland-Dostert-Viazovska ($d=6$). The certificate is exact: the dual point is a rational vector, coefficient nonnegativity is verified by exact arithmetic up to $n=800$, and eventual positivity of the two relevant $q$-expansion",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0110",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11319v1",
    "status": "available",
    "timestamp": "2026-07-16T11:56:27.441209+00:00",
    "title": "ArXiv paper: A dual linear programming bound for sphere packing in dimension 36"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Unexpected primes of good reduction in quotients of modular and Shimura curves' and formalize its key results. Abstract: We find all zero-dimensional spaces of newforms of weight $2$ and squarefree level $N$ with a fixed Atkin--Lehner sign pattern. As an application, we classify unexpected primes of good reduction of Atkin--Lehner quotients of modular and Shimura curves of squarefree levels.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0111",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11248v1",
    "status": "available",
    "timestamp": "2026-07-16T12:11:59.753298+00:00",
    "title": "ArXiv paper: Unexpected primes of good reduction in quotients of modular and Shimura curves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Lattice point counting in Cygan--Kor\u00e1nyi balls on Heisenberg groups' and formalize its key results. Abstract: Lattice point counting in gauge balls on the Heisenberg group $\\mathbb{H}^q$ is a non-commutative analogue of the Euclidean multidimensional sphere problem, initiated by Garg, Nevo and Taylor \\cite[\\textit{Ann. Inst. Fourier}, 2015]{GNT15}. The case of particular interest is when the gauge is taken as the Cygan--Kor\u00e1nyi norm and the error term reads: $$\\mathcal{E}_q(t)=\\#\\left(\\mathbb{Z}^{2 q+1} \\cap \\mathcal{B}_t\\right)-\\operatorname{vol}(\\mathcal{B}_1) \\, t^{2 q+2},$$ with $\\mathcal{B}_t=\\{(v,w)\\in\\mathbb{H}^q: (|v|^4 + w^2)^{1/4} \\le t \\}$, which is closely related to the Gauss circle problem. When $q\\ge3$, Gath \\cite[\\textit{Ann. Sc. Norm. Super. Pisa Cl. Sci.}, 2022]{Gat22} improved upon \\cite[]{GNT15} by showing that $ |\\mathcal{E}_q(t)|\\lesssim t^{2q-1+ 1/3}$ and proposed the conjecture that the optimal order should be $2q-1$. In this paper, through Landau's formula and the $5,6$-th Derivative Tests of van der Corput, we arrive at that $|\\mathcal{E}_q(t)| \\lesssim t^{2 q-1 + 241",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0112",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10971v1",
    "status": "available",
    "timestamp": "2026-07-16T12:28:53.678857+00:00",
    "title": "ArXiv paper: Lattice point counting in Cygan--Kor\u00e1nyi balls on Heisenberg groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Group action-stabilizer graph of group actions of a group on a set' and formalize its key results. Abstract: In this paper we introduce the group action-stabilizer graph $GAS(G)$ of a group $G$ on a set $X$ with vertex set as the collection of all the group actions of $G$ on $X$, and any two vertices $\u03c6$ and $\u03c8$ are adjacent if and only if the non-trivial subgroups $\\cap G_x^\u03c6$ and $\\cap G_x^\u03c8$ of $G$ intersect non-trivially, where $G_x^\u03c6$ and $G_x^\u03c8$ are two stabilizers of $x$ with respect to the actions $\u03c6$ and $\u03c8$, respectively. We characterize a special subgraph $gas(G)$ of $GAS(G)$ in which the vertex set contains the actions $\u03c6$ of $G$ on $X$ such that $\\cap G_x^\u03c6$'s are distinct. We determine the number of group actions within some specific groups and find certain conditions under which $GAS(G)$ is equal to $gas(G)$. We also examine the conditions under which $gas(G)$ and its complement are derived graph for a finite nilpotent group $G$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0113",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11161v1",
    "status": "available",
    "timestamp": "2026-07-16T12:45:06.070328+00:00",
    "title": "ArXiv paper: Group action-stabilizer graph of group actions of a group on a set"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Exact Frequencies of Consecutive Quadratic Residue and Nonresidue Patterns Modulo a Prime' and formalize its key results. Abstract: This paper determines the exact frequency of all consecutive sign patterns of lengths two and three formed by the quadratic character modulo an odd prime $p$. Using basic properties of character sums over finite fields, we derive exact counting formulas for pairs $(n, n+1)$ and triples $(n-1, n, n+1)$ exhibiting specific sequence patterns in \\(\\{\\pm 1\\}\\). The frequencies of pairs are classified entirely by \\(p \\pmod 4\\), whereas triples exhibit a more complex dependency on \\(p \\pmod 8\\) and the Jacobsthal sum $T_p=\\sum_{x\\in\\mathbb F_p}\u03c7(x^3-x)$.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0115",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11068v1",
    "status": "available",
    "timestamp": "2026-07-16T13:16:57.481996+00:00",
    "title": "ArXiv paper: Exact Frequencies of Consecutive Quadratic Residue and Nonresidue Patterns Modulo a Prime"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Higher-Order Congruence for Reciprocal Power Sums and Generalized Lehmer-Type Products' and formalize its key results. Abstract: This paper investigates high-order congruences of reciprocal power sums and Lehmer-type products. Let $n\\geq 1$ with $(n,6)=1$ and $e\\in\\{2,3,4,6\\}$. For the reciprocal square sums \\begin{equation*} S(n)=\\sum_{\\substack{r=1 \\\\ (r,n)=1}}^{\\lfloor n/e \\rfloor}\\frac{1}{r^2} \\end{equation*} we already know the form of the congruence modulo $n$. In this paper, motivated by the known congruences, we first extend these results to certain reciprocal sums of odd order and establish a uniform congruence modulo $n$ for \\begin{equation*} S_m(n)=\\sum_{\\substack{r=1 \\\\ (r,n)=1}}^{\\lfloor n/e \\rfloor}\\frac{1}{r^m} \\end{equation*} We then study the generalized Lehmer-type product \\begin{equation*} \\prod_{d \\mid n}\\binom{kd-1}{\\lfloor d/e \\rfloor}^{\u03bc(n/d)} \\end{equation*} Although congruences modulo $n^3$ for this product have previously been obtained, higher-order congruences do not admit a comparably simple closed form. To address this difficulty, we derive an explicit truncated expansion in terms of",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0116",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.11113v1",
    "status": "available",
    "timestamp": "2026-07-16T13:34:22.310523+00:00",
    "title": "ArXiv paper: Higher-Order Congruence for Reciprocal Power Sums and Generalized Lehmer-Type Products"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Hereditary 2-WQO Graph Classes Have Bounded Clique-Width' and formalize its key results. Abstract: A graph class is $k$-WQO if its $k$-labeled graphs are well-quasi-ordered under label-preserving induced subgraph embeddings. We show that every hereditary graph class that is $2$-WQO has bounded clique-width. Combined with the recent result of Dumas and Lopez, this confirms a long-standing conjecture of Pouzet: A hereditary graph class is $2$-WQO if and only if it is $k$-WQO for all $k\\geq 2$, if and only if it is $\\forall$-WQO, that is, its labeled graphs are well-quasi-ordered for every possible well-quasi-ordered label set. Our proof builds on a recent structure/non-structure dichotomy for the model theoretic notion of monadic dependence by Dreier, M\u00e4hlmann, and Toru\u0144czyk. Through the non-structure characterization by forbidden induced subgraphs, we show that every hereditary $2$-WQO graph class is monadically dependent. Leveraging the Ramsey-theoretic structural properties provided by monadic dependence, we then establish bounded clique-width by ruling out the existence of large w",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0117",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10939v1",
    "status": "available",
    "timestamp": "2026-07-16T13:51:52.058528+00:00",
    "title": "ArXiv paper: Hereditary 2-WQO Graph Classes Have Bounded Clique-Width"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The Arithmetic of Semirings Part I: Ideals' and formalize its key results. Abstract: We study ideals in the semiring $\\mathbb{N}$ of natural numbers, with a focus on those which are lost when extending from $\\mathbb{N}$ to $\\mathbb{Z}$. This leads to a new perspective on the classical theory of numerical semigroups, including the introduction of a natural multiplicative structure. We prove that unique factorization of ideals fails in $\\mathbb{N}$ on several levels, introduce a handful of new tropical multiplicative invariants of numerical semigroups, characterize integral closures of ideals in terms of Newton polygons, and analyze the behavior of classical numerical semigroup invariants with respect to the product operation.",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0118",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10778v1",
    "status": "available",
    "timestamp": "2026-07-16T14:08:19.852831+00:00",
    "title": "ArXiv paper: The Arithmetic of Semirings Part I: Ideals"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Tur\u00e1n-Type Bounds for Graphs Containing Large $F$-Sparse Sets' and formalize its key results. Abstract: We study Tur\u00e1n-type extremal problems for graphs containing a large $F$-sparse vertex set, meaning a vertex set whose induced subgraph contains few copies of $F$. For integers $r>s\\ge 1$, we prove that if a $K_{r+1}$-free graph $G$ on $n$ vertices contains a set $M$ of size $m\\ge \\lceil sn/r\\rceil$ such that $G[M]$ is $K_{s+1}$-free, then \\[ e(G)\\le m(n-m)+t_s(m)+t_{r-s}(n-m). \\] We characterize the equality cases as the complete $r$-partite graphs whose vertex classes split into two balanced groups of total sizes $m$ and $n-m$, consisting of $s$ and $r-s$ classes, respectively. We also prove a color-critical extension for forbidden graphs that embed into a join of two edge-critical graphs, together with an asymptotic extension for general $H$-free graphs in which the prescribed large vertex set spans few copies of a fixed graph $F$ with $\u03c7(F)<\u03c7(H)$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0119",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10832v1",
    "status": "available",
    "timestamp": "2026-07-16T14:24:54.994704+00:00",
    "title": "ArXiv paper: Tur\u00e1n-Type Bounds for Graphs Containing Large $F$-Sparse Sets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Counting Odd Cycles in Graphs with Bounded Circumference' and formalize its key results. Abstract: For an integer $L\\ge2$, let $a=\\lfloor L/2\\rfloor$. Let $H(n,L)$ be the join of $K_a$ and an independent set of order $n-a$, with one extra edge in the independent set when $L$ is odd. We prove that, for every fixed $s\\ge3$ and $L\\ge2s+2$, and for all sufficiently large $n$, \\[ \\operatorname{ex}(n,C_{2s+1},\\mathcal{C}_{\\ge L+1}) =N(C_{2s+1},H(n,L)). \\] Together with the recent result of even-cycle by Zhao and Wang~[arXiv:2607.04357, 2026], this settles the conjecture of Zhu, Gy\u0151ri, He, Lv, Salia and Xiao~[Bull. Lond. Math. Soc. 55 (2023)] on counting fixed cycles in graphs with bounded circumference. We also determine the corresponding maximum number of copies of odd cycles when a path is forbidden.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0120",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10779v1",
    "status": "available",
    "timestamp": "2026-07-16T14:42:51.230098+00:00",
    "title": "ArXiv paper: Counting Odd Cycles in Graphs with Bounded Circumference"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Generalizations of nets and Latin squares' and formalize its key results. Abstract: We examine combinatorial structures which generalize $(k,n)$-nets, orthogonal arrays, and mutually orthogonal Latin squares. By a reticulation we mean of a point set and two collections (types) of families of lines such that two lines of different types meet in exactly one point and each family of lines partitions the point set. The number of points incident with any line depends only upon the type of the line, and every point is incident with the same number of lines of a given type. Each choice of one line family of each type leads to an arrangement of the points into a rectangular grid. Recording the line containing a given point in the corresponding position of an array gives to a generalization of sets of mutually orthogonal Latin squares, dubbed a cooperative system. A cooperative system consists of a collection of column-Latin matrices and a collection of row-Latin matrices such that each column-Latin matrix is orthogonal to each row-Latin matrix. Recording lines which contain a",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_0121",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10890v1",
    "status": "available",
    "timestamp": "2026-07-16T14:59:52.606942+00:00",
    "title": "ArXiv paper: Generalizations of nets and Latin squares"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Greenberg's $\u03bc=0$ conjecture for lisse sheaves over global function fields' and formalize its key results. Abstract: Let $K$ be a global function field of characteristic $p>0$ and $\\ell\\neq p$ be a prime number. We study Selmer groups over a $\\mathbb{Z}_\\ell$-extension $K_\\infty/K$. For a lisse $\\mathbb Z_\\ell$-sheaf we prove that the Pontryagin dual of the associated Selmer group is a finitely generated torsion module over the Iwasawa algebra and has $\u03bc$-invariant equal to zero. This gives a positive-characteristic, prime to $p$, analogue of Greenberg's $\u03bc=0$ conjecture. Our result applies in particular to abelian varieties, fine Selmer groups, and adjoint representations. We also prove an analogue of the weak Leopoldt conjecture in this context over $K_\\infty$, and deduce that the framed deformation ring of a residual representation is a formal power series ring. The same conclusion holds for the unframed deformation ring if the residual representation has no non-scalar endomorphisms.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0122",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.10728v2",
    "status": "available",
    "timestamp": "2026-07-16T15:16:11.220023+00:00",
    "title": "ArXiv paper: Greenberg's $\u03bc=0$ conjecture for lisse sheaves over global function fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The even-uniform hypergraph Moore bound' and formalize its key results. Abstract: The hypergraph Moore bound conjectured by Feige (2008) controls the size of the smallest even cover in a $k$-uniform hypergraph in terms of the average density of hyperedges. An even cover is a set of hyperedges covering each vertex an even number of times, generalizing the notion of a cycle in a graph, so the size of the smallest non-trivial even cover provides a notion of hypergraph girth. Recent work starting from the breakthrough result of Guruswami, Kothari, and Manohar (2022) proved the conjecture up to polylogarithmic factors, whose exponents were later gradually improved. We give a simple proof of Feige's original hypergraph Moore bound conjecture for all even $k\\ge 4$, with no superfluous polylogarithmic factors. Our proof roughly follows the proof of the graph Moore bound, but works with colored walks in a Kikuchi graph built from a hypergraph and controls their growth using a polynomial interpolation method.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0128",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14068v1",
    "status": "available",
    "timestamp": "2026-07-16T15:18:15.196919+00:00",
    "title": "ArXiv paper: The even-uniform hypergraph Moore bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The Lean Number of a Hypergraph' and formalize its key results. Abstract: Inspired by the notion of tricolorability of knots, we introduce the concept of lean coloring for hypergraphs and the associated lean number of a hypergraph. Lean coloring often involves very few colors, yet still requires the methods of usual graph coloring, forcing the overall complexity to be NP-Hard. We provide two alternative formulations of the lean coloring problem that involve a type of coloring on abstract simplicial complexes and a partial coloring on bipartite graphs. We then provide bounds for the lean numbers of hypergraphs that are $k$-uniform, $k$-partite, wide-path connected, or $r$-complete. Python-like script is included to allow the implementation and study of a lean coloring algorithm. We conclude with some directions for future work and present the lean numbers of $130$ knots and links.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0129",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14015v1",
    "status": "available",
    "timestamp": "2026-07-16T15:34:56.562118+00:00",
    "title": "ArXiv paper: The Lean Number of a Hypergraph"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Gilbert's disc model conditioned on the square lattice' and formalize its key results. Abstract: We present a new percolation model on the two-dimensional lattice, which can be seen as a conditioned version of continuous percolation on the plane. Let us place a point uniformly at random in each cell of the grid $\\mathbb{Z}^2$. These points correspond to the vertices of our graph, and we connect two points by an edge if their distance is less than a fixed radius $R$. We are interested in the radius from which there exists almost surely an infinite connected component. We also study two other critical radii specific to the geometry of our model: the smallest radius such that there exists a positioning of the points for which there is an infinite connected component, and the radius from which all points are connected to each other.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0130",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14062v1",
    "status": "available",
    "timestamp": "2026-07-16T15:52:36.132855+00:00",
    "title": "ArXiv paper: Gilbert's disc model conditioned on the square lattice"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Cyclic Sieving for Staircase Plane Partitions via Crystals and Electrical Networks' and formalize its key results. Abstract: We prove a cyclic sieving result for the action of promotion on the staircase plane partitions of height two. Our proof has two major algebraic inputs: an interpretation of this promotion action in terms of tensor powers of the spin crystal that was recently studied by Pappe--Pfannerer--Schilling--Simone, and the bush basis of the degree two part of the coordinate ring of the space of electrical networks that was recently introduced by Gao--Lam--Xu. Moreover, we explain how the existence of an electrical canonical basis in all degrees would yield cyclic sieving for promotion of staircase plane partitions of all heights.",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_0131",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14028v1",
    "status": "available",
    "timestamp": "2026-07-16T15:18:18.586627+00:00",
    "title": "ArXiv paper: Cyclic Sieving for Staircase Plane Partitions via Crystals and Electrical Networks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Strongly complete sets and a conjecture of Erd\u0151s' and formalize its key results. Abstract: A set $A\\subseteq\\mathbb{N}$ is called $\\textit{complete}$ if every sufficiently large integer can be written as a sum of distinct elements of $A$. It is $\\textit{strongly complete}$ if it remains complete after one deletes finitely many elements from it. We show that $A\\subseteq\\mathbb{N}$ is strongly complete whenever \\[ \\big|A\\cap(2^k,2^{k+1}]\\big|\\ge6 \\] for every sufficiently large $k\\in\\mathbb{N}$, and \\[ \\sum_{a\\in A}\\|a\u03b8\\|=\\infty, \\quad\\forall\u03b8\\in\\mathbb{R}\\setminus\\mathbb{Z}. \\] In particular, this resolves a 1961 conjecture of Erd\u0151s. The proof builds on previous work of Bergelson and Simmons. Our approach also allows us to establish a more general strong-completeness criterion with suitable ordered blocks in place of dyadic intervals.",
    "domains": [
      "Pythagorean",
      "Logic"
    ],
    "id": "fd_0132",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14071v1",
    "status": "available",
    "timestamp": "2026-07-16T15:35:00.343163+00:00",
    "title": "ArXiv paper: Strongly complete sets and a conjecture of Erd\u0151s"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Edge-decomposition into Two Triangular Forests is NP-complete' and formalize its key results. Abstract: Let $\\mathcal F$ be a graph class that is closed under topological minors and 1-sums, has decidable membership, contains a triangle, and is not the class of all graphs. Recently, Lee, Liu, and Tsai [ICALP 2026] showed that the edge-decomposition problem into $k \\geq 3$ elements of $\\mathcal F$ is NP-hard. In particular, their general hardness reduction covers a long-standing problem on outerthickness (when $\\mathcal F$ is the class of outerplanar graphs). On the other hand, it is well known that decomposing a graph into forests is polynomial-time solvable, as implied by work of Edmonds [J. Res. Natl. Bur. Stand. B. 1965]. In this paper, we take a first step toward determining the complexity of edge-decomposition problems into just two graphs (the case $k=2$). We consider the simplest possible graph class $\\mathcal F$ satisfying the criteria above: the triangular forests, that is, graphs in which every 2-connected component is a triangle. We prove that determining whether a graph can be",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "fd_0133",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13999v1",
    "status": "available",
    "timestamp": "2026-07-16T15:52:39.780537+00:00",
    "title": "ArXiv paper: Edge-decomposition into Two Triangular Forests is NP-complete"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Resurgent Lambert series from Feynman and beyond' and formalize its key results. Abstract: Lambert series of the form $\\sum_{n>0}a(n)q^n/(1-q^n)$ are ubiquitous in mathematical physics. In particular, 2-loop sunrise and 3-loop banana Feynman diagrams yield Lambert series with $a(n)$ of the form $\u03c7(n)/n^s$ where $\u03c7(n)$ is a Dirichlet character. Resurgence concerns the singular limit as $|q|$ approaches 1. In the Feynman cases we can control this limit, obtaining rapidly convergent expressions, since the Lambert series are iterated integrals of holomorphic Eisenstein series twisted by a character. We generalize this result, to include modular resurgent structures found in topological-string observables.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0136",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14020v1",
    "status": "available",
    "timestamp": "2026-07-16T17:10:25.387656+00:00",
    "title": "ArXiv paper: Resurgent Lambert series from Feynman and beyond"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Matroid correspondence' and formalize its key results. Abstract: Motivated by algebraic correspondences and linear operators associated with volume and Lorentzian polynomials, we introduce matroid correspondences and their polymatroid analogues. A matroid correspondence defines a functor between poset categories of matroids whose morphisms are matroid quotients, and various standard functors, including deletion, contraction, free extension, truncation, intersection, union, and pullback, arise in this way. We show that these correspondences preserve representability and algebraicity under natural hypotheses. In the polymatroid setting, we establish compatibility with multisymmetric lifts. Finally, we relate this construction to the supports of linear operators with Lorentzian symbols.",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0137",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13783v1",
    "status": "available",
    "timestamp": "2026-07-16T17:27:41.805947+00:00",
    "title": "ArXiv paper: Matroid correspondence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Independent Sets in Multiset Profile Graphs via Weighted Local Covers' and formalize its key results. Abstract: The discrete simplex consists of the nonnegative integer vectors $a=(a_1,\\ldots,a_q)$ whose coordinates sum to $d$. Equivalently, its vertices are the multiplicity profiles of size-$d$ multisets over $q$ symbols. Two vertices are adjacent when one is obtained from the other by decreasing one coordinate by one and increasing another coordinate by one. We study the maximum size $\u03b1_q(d)$ of an independent set in this graph. Our upper bounds cover the graph by translated smaller graphs and assign them nonnegative weights. For fixed $q$, the weights depend on only finitely many capped profiles, so one finite rational linear system can prove a bound for every sufficiently large $d$. The method gives new proofs of the known cases $q=3$ and $q=4$ and determines $\u03b1_q(d)$ exactly for $q=5$ and $q=7$ in every degree. It also determines the largest classes of natural additive colorings for general $q$. In the opposite regime, with $d$ fixed and $q$ growing, it solves degree five for $q\\ge7$, gives",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_0138",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13733v1",
    "status": "available",
    "timestamp": "2026-07-16T17:45:05.337330+00:00",
    "title": "ArXiv paper: Independent Sets in Multiset Profile Graphs via Weighted Local Covers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Heat Kernel and Closed Geodesic Asymptotics for Nilpotent Coverings' and formalize its key results. Abstract: We establish all order long-time asymptotic expansions for heat kernels on nilpotent coverings and for prime closed geodesics in fixed central classes of nilpotent quotients of compact hyperbolic surfaces. The exact lattice-side input is the finite-dimensional rational Floquet-Bloch theory of the companion paper: rational Kirillov restrictions give exact finite-dimensional fibers, and a generalized Pytlik functional gives exact Fourier-inversion and normalized-trace identities. At a rational parameter $p/q$ the decomposition is exact, and the fluctuation of the fiber integrand is controlled only by $q$. Hence the large-denominator comparison with the smooth Kirillov or Schr\u00f6dinger normal form is uniform on the rational support of the Pytlik functional; irrational parameters do not enter the rigorous trace argument. For general nilpotent models, coefficient-weighted spectral sums are justified to every fixed order by positive Rockland estimates, the Plancherel-Mellin formula, and a trac",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0139",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13890v1",
    "status": "available",
    "timestamp": "2026-07-16T18:02:11.594209+00:00",
    "title": "ArXiv paper: Heat Kernel and Closed Geodesic Asymptotics for Nilpotent Coverings"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The exact minimum total degree threshold for the square of a Hamilton cycle in digraphs' and formalize its key results. Abstract: The P\u00f3sa-Seymour conjecture establishes the minimum degree threshold required to guarantee the presence of the $k$th power of a Hamilton cycle in a graph. Following numerous partial results, Koml\u00f3s, S\u00e1rk\u00f6zy, and Szemer\u00e9di confirmed the conjecture holds for all sufficiently large graphs. Treglown later conjectured the analogous minimum semi-degree threshold for forcing the $k$th power of a Hamilton cycle in a digraph. Subsequently, DeBiasio et al. proposed a conjecture on the minimum total degree threshold for the same problem. In this paper we settle the conjecture of DeBiasio et al. for $k=2$. Specifically, we prove that every sufficiently large $n$-vertex digraph with minimum total degree at least $8n/5-c$ contains the square of a Hamilton cycle, where $c=2$ if $n\\equiv2,4\\pmod 5$, and $c=1$ otherwise.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0140",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13831v1",
    "status": "available",
    "timestamp": "2026-07-16T18:19:24.603038+00:00",
    "title": "ArXiv paper: The exact minimum total degree threshold for the square of a Hamilton cycle in digraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Excluding paths and bicliques' and formalize its key results. Abstract: Classes of graphs excluding a path and a biclique as induced subgraphs are extensively studied in the literature. One of the key structural results for such graphs is a Ramsey-type result due to Galvin, Rival, and Sands (1982), establishing the existence of a function $f$ bounding the maximum length of a path in terms of clique number $\u03c9$. We improve the best known bound on $f$ to a function that is a singly exponential in $\u03c9^c$, for some constant $c$, which we show is best possible, up to optimizing $c$. Our approach also has consequences for treedepth. In particular, we show that, for graphs excluding a path and a biclique as induced subgraphs, treedepth is bounded by a polynomial function of clique number. In turn, this result implies that every hereditary graph class that admits a function bounding treedepth of graphs in the class in terms of clique number, admits a polynomial such function. This gives a treedepth analogue of a recent result on pathwidth due to Hajebi (2025).",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0141",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13995v1",
    "status": "available",
    "timestamp": "2026-07-16T18:36:39.881170+00:00",
    "title": "ArXiv paper: Excluding paths and bicliques"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Area correlations related to lattice points in discs' and formalize its key results. Abstract: Motivated by the Lester-Wigman vanishing area correlation conjecture for lattice points near the boundary of circles of growing radius, we investigate the dynamics of circle flows on tori (which are related to the motion of a charged particle in a magnetic field on a torus.) We show that an analogue of the vanishing correlation conjecture holds in this setting, i.e., we have \"mixing for the area observable\" despite the flow being essentially integrable. We also determine the probability density function of the areas, in global as well as local regimes.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0142",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13659v1",
    "status": "available",
    "timestamp": "2026-07-16T18:54:15.847944+00:00",
    "title": "ArXiv paper: Area correlations related to lattice points in discs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Exact classification of elliptic curves $y^{2}=x^{3}-pqx$ with rank $0$ and trivial $\\Sha[2]$' and formalize its key results. Abstract: For the elliptic curves $E_{p,q}: y^{2}=x^{3}-pqx$ where $p$ and $q$ are distinct odd primes, we establish necessary and sufficient conditions under which rank$\\,E_{p,q}(\\mathbb{Q})$ and $\\dim_{\\mathbb{F}_{2}} \\Sha \\left( E_{p,q}/\\bbQ \\right)[2]$ are both $0$. We do so via a similar characterisation of when the Selmer groups associated with the degree-$2$ isogeny $\u03c6$ and its dual $\\widehat\u03c6$ are both of minimal size, along with results about a cokernel that arises from a related exact sequence.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0143",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14033v1",
    "status": "available",
    "timestamp": "2026-07-16T16:53:13.563266+00:00",
    "title": "ArXiv paper: Exact classification of elliptic curves $y^{2}=x^{3}-pqx$ with rank $0$ and trivial $\\Sha[2]$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Local and global average degree in bipartite graphs' and formalize its key results. Abstract: Let $F_{\\mathrm{bip}}(n)$ denote the maximum, over all $n$-vertex bipartite graphs without isolated vertices, of the ratio of the minimum local average degree to the global average degree. We prove that $F_{\\mathrm{bip}}(n)=\\frac14\\sqrt n+\\frac38+o(1)$. This answers a problem posed by Tuza.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0144",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14038v1",
    "status": "available",
    "timestamp": "2026-07-16T17:10:28.704063+00:00",
    "title": "ArXiv paper: Local and global average degree in bipartite graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Transformation Semigroup Perspective on the Magma Monoid' and formalize its key results. Abstract: The monoid of all binary operations was first introduced by H. S. Kim and J. Neggers in 2008. Since then, different aspects and applications of this monoid were studied, while several questions about its semigroup-theoretic properties remain unanswered. We employ a transformation semigroup perspective to fully characterize principal left and right ideals, idempotent and regular elements of this monoid, as well as provide precise combinatorial enumerations of them. This approach gives a general framework for most of the existing results on ideals in the magma monoid. We also answer several open questions posed in the 2023 PhD dissertation of A. Rafieipour. Finally, we correct an error regarding the description of the center of the magma monoid from the 2011 paper of H. F. Fayomi.",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0146",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13746v1",
    "status": "available",
    "timestamp": "2026-07-16T17:45:08.868122+00:00",
    "title": "ArXiv paper: Transformation Semigroup Perspective on the Magma Monoid"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Antipodal paths in covers of spheres' and formalize its key results. Abstract: In this note we show that if the sphere $\\mathbb{S}^n$ is covered by $k$ open sets with $n \\geq 2k-2$, then one of these sets contains a path with antipodal endpoints. This is best possible in the sense that the statement fails for $n < 2k-2$. The result can be seen as a spherical analogue of a well-known conjecture of Norine on edge-colourings of the discrete hypercube.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0147",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13964v1",
    "status": "available",
    "timestamp": "2026-07-16T18:02:15.059733+00:00",
    "title": "ArXiv paper: Antipodal paths in covers of spheres"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The inversion number of a path-reversed tournament: Resolving a conjecture of Belkhechine, Bouaziz, Boudabbous, and Pouzet' and formalize its key results. Abstract: Let $D$ be a tournament and let $X\\subseteq V(D)$. The inversion of $X$ reverses all arcs whose both endpoints lie in $X$ and leaves every other arc unchanged. A family of inversions is a decycling family if applying all of them produces an acyclic, equivalently transitive, tournament. The inversion number $\\inv(D)$ is the minimum size of such a family. Let $Q_n$ be the tournament on $[n]$ obtained from the natural transitive tournament by reversing precisely the consecutive pairs $12,23,\\ldots,(n-1)n$. Belkhechine, Bouaziz, Boudabbous, and Pouzet conjectured in their unpublished manuscript that a natural path-reversed family has inversion number exactly $\\left\\lfloor(n-1)/2\\right\\rfloor$. The same problem was later recorded by Bang-Jensen, da Silva, and Havet and by Alon, Powierski, Savery, Scott, and Wilmer. In this paper we resolve this conjecture.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0148",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13829v1",
    "status": "available",
    "timestamp": "2026-07-16T18:19:27.949802+00:00",
    "title": "ArXiv paper: The inversion number of a path-reversed tournament: Resolving a conjecture of Belkhechine, Bouaziz, Boudabbous, and Pouzet"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Clique spectral extremal problem on disjoint color-critical graphs' and formalize its key results. Abstract: For a given graph $F$, a graph $G$ is called $F$-free if it does not contain $F$ as a subgraph. A graph is color-critical if deleting one of its edges decreases its chromatic number. Let $F_1, F_2, \\cdots, F_t$ be $t$ disjoint color-critical graphs with chromatic number $r+1$. For $2 \\leq s \\leq r$ and sufficiently large $n$, we determine the unique extremal graph with the maximum $s$-clique spectral radius among all $n$-vertex $\\bigcup_{i=1}^t F_i$-free graphs.",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0149",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13861v1",
    "status": "available",
    "timestamp": "2026-07-16T18:36:43.198397+00:00",
    "title": "ArXiv paper: Clique spectral extremal problem on disjoint color-critical graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Bernoulli determinants and cuspidal subgroups' and formalize its key results. Abstract: We give an explicit formula for the order of the rational cuspidal class group of the modular curve $X_1(N)$ for an arbitrary integer $N$. The proof relies on results of Streng on the group of modular units on $X_1(N)$, and requires computing a certain determinant involving the second Bernoulli polynomial. We also define a higher weight analogue of the cuspidal class group and speculate that its order is related to a similar determinant defined using a higher degree Bernoulli polynomial.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0150",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13536v1",
    "status": "available",
    "timestamp": "2026-07-16T18:54:19.202450+00:00",
    "title": "ArXiv paper: Bernoulli determinants and cuspidal subgroups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Representability of systems of proportionally modular numerical semigroups' and formalize its key results. Abstract: In this short note we prove that every system of proportionally modular numerical semigroups is representable by a canonical equivariant resolution of a weighted homogeneous surface singularity with rational homology sphere link. The construction starts from the quotient descriptions of proportionally modular numerical semigroups by two-generator numerical semigroups, realizes each quotient by a two-legged canonical equivariant resolution graph, and then glues these graphs with suitable multiplicities.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0152",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13619v1",
    "status": "available",
    "timestamp": "2026-07-16T23:55:04.862763+00:00",
    "title": "ArXiv paper: Representability of systems of proportionally modular numerical semigroups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Spectral and Additive Combinatorial Methods for Cycles and Absorbing Sets in Lifted-Product Quantum LDPC Codes' and formalize its key results. Abstract: The finite-length performance of quantum low-density parity-check (LDPC) codes under iterative decoding is governed by small substructures of the Tanner graph, principally short cycles and absorbing sets. While the classical theory of these substructures for quasi-cyclic codes is well developed through discrete Fourier transform (DFT) methods, these tools do not directly address the two-block tensor structure $H_X = [\\,\\widetilde{H}_1 \\mid I \\otimes \\widetilde{B}^T\\,]$ of the lifted-product (quasi-cyclic generalised hypergraph product, QC-GHP) codes that dominate current quantum LDPC constructions. In this paper we develop a quantum-specific spectral framework that exploits this structure. At its core is a DFT block-diagonalisation of $H_X H_X^T$ that reduces moment-trace and cycle computations from an $(r_1\\ell)\\times(r_1\\ell)$ matrix to a sum of $\\ell$ small $r_1\\times r_1$ Hermitian matrices, with the second block entering only as a scalar shift. From this result we derive a closed-",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0153",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13666v1",
    "status": "available",
    "timestamp": "2026-07-17T00:13:29.815083+00:00",
    "title": "ArXiv paper: Spectral and Additive Combinatorial Methods for Cycles and Absorbing Sets in Lifted-Product Quantum LDPC Codes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Trees with exactly three main eigenvalues' and formalize its key results. Abstract: An eigenvalue of a graph is called main if its eigenspace is not orthogonal to the all-ones vector. Introduced by Cvetkovi\u0107 in the early 1970s and systematically studied by Rowlinson and others, graphs with exactly one or two main eigenvalues are now well understood. However, the classification of graphs with precisely three main eigenvalues remains a challenging open problem in spectral graph theory. This paper provides a complete classification of all trees of diameter 5 with exactly three main eigenvalues. Using equitable partitions, the spectral condition reduces to the unique solvability of linear systems over the rationals, leading to Diophantine equations involving branch lengths and pendant counts. We prove that every such tree is isomorphic either to a symmetric tree $T_r(a)$ or to a member of a parametric family $\\mathcal{T}$ determined by arithmetic divisibility conditions. We also construct an infinite family of such trees with unbounded diameter.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0155",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13577v1",
    "status": "available",
    "timestamp": "2026-07-17T00:50:40.306507+00:00",
    "title": "ArXiv paper: Trees with exactly three main eigenvalues"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Formality for rigid-analytic spaces satisfying the weight-monodromy conjecture' and formalize its key results. Abstract: We prove that \u00e9tale and de Rham cohomology algebras of a smooth proper rigid-analytic space over a finite extension of $\\mathbf{Q}_p$ are formal if the rigid-analytic space satisfies the weight-monodromy conjecture. We give examples of smooth proper rigid-analytic surfaces whose cohomology algebras are not formal.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_0156",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14517v1",
    "status": "available",
    "timestamp": "2026-07-17T01:25:59.424722+00:00",
    "title": "ArXiv paper: Formality for rigid-analytic spaces satisfying the weight-monodromy conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The small Davenport constant of the Heisenberg group of order 125' and formalize its key results. Abstract: The small Davenport constant $\\mathsf{d}(G)$ of a finite group $G$ is the maximal length of a product-one-free sequence over $G$. For the exponent-$p$ Heisenberg group $H_{p^3}$ of order $p^3$, Godara and Sarkar proved $\\mathsf{d}(H_{27})=6$ and posed $\\mathsf{d}(H_{p^3})=3p-3$ for every odd prime $p$, leaving $p\\ge5$ open. We settle the first open case: $\\mathsf{d}(H_{125})=12$. The lower bound is the explicit product-one-free sequence $x^4y^4v^4$. For the upper bound we record a product-one criterion that reduces the non-commutative problem to additive combinatorics over $\\mathbb{F}_5^2$, and then reduce \"every length-13 sequence has a product-one subsequence\" to a single finite statement -- a spread bound on quotient multisets -- which we verify by an exhaustive, memory-flat search in C, its verdict independently reproduced by a second search with a different pruning strategy. Every auxiliary lemma is machine-checked. The argument is genuinely $p$-specific: we identify the exact ste",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0157",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14379v1",
    "status": "available",
    "timestamp": "2026-07-17T01:43:06.432576+00:00",
    "title": "ArXiv paper: The small Davenport constant of the Heisenberg group of order 125"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Beyond the Riemann Hypothesis bounds: A pair-correlation approach to the least prime in arithmetic progression and the smallest quadratic non-residue' and formalize its key results. Abstract: The Generalized Riemann Hypothesis (GRH) has long defined the expected bounds for the smallest prime in an arithmetic progression and the least quadratic non-residue. However, this hypothesis primarily addresses the horizontal location of non-trivial zeros. In this paper, we show that incorporating the vertical spacing--or pair-correlation--of these zeros allows us to surpass these classical bounds. By combining these two zero-distribution perspectives, we establish sharper estimates for both problems under GRH and specific pair-correlation hypotheses, thereby providing a new link between pair-correlation phenomena for Dirichlet L-functions and these two classical problems.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_0158",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14515v1",
    "status": "available",
    "timestamp": "2026-07-17T02:00:26.348823+00:00",
    "title": "ArXiv paper: Beyond the Riemann Hypothesis bounds: A pair-correlation approach to the least prime in arithmetic progression and the smallest quadratic non-residue"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Semitotal domination in unit disk graphs' and formalize its key results. Abstract: A set $S \\subseteq V$ is called a {\\em semitotal dominating set} of $G=(V,E)$ if every vertex in $V \\setminus S$ is adjacent to at least one vertex in $S$, and every vertex in $S$ is within distance 2 of another vertex in $S$. The corresponding decision problem is NP-complete even for unit disk graphs. In this paper, we present a 5-factor approximation algorithm for the Minimum Semitotal Domination problem on unit disk graphs in the graph-based input model. The algorithm processes the layers of a Breadth-First-Search tree and constructs a maximal independent set whose vertices satisfy the semitotal condition. For a graph with $n$ vertices and $m$ edges, the algorithm runs in $O(n + m)$ time, and hence in $O(n^2)$ time in the worst case. This improves the previously known 5.75-approximation algorithm with $O(n^3)$ running time.",
    "domains": [
      "Computation",
      "MachineLearning"
    ],
    "id": "fd_0159",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14467v1",
    "status": "available",
    "timestamp": "2026-07-17T02:17:28.732470+00:00",
    "title": "ArXiv paper: Semitotal domination in unit disk graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Spectral extremal problems on planar and outerplanar graphs without $C_{k,l}' and formalize its key results. Abstract: Let $\\emph{spex}_{\\mathcal{P}}(n,F)$ and $\\emph{spex}_{\\mathcal{OP}}(n,F)$ be the maximum spectral radius among all $n$-vertex $F$-free planar graphs and outerplanar graphs, respectively. Define $C_{k,l}$ as a graph obtained from $C_k \\cup C_l$ such that the two cycles share a common vertex, where $l \\ge k \\ge 3$. In the 1990s, Cvetkovi\u0107 and Rowlinson conjectured $K_1 + P_{n-1}$ maximizes spectral radius in outerplanar graphs on $n$ vertices, while Boots and Royle (independently, Cao and Vince) conjectured $K_2 + P_{n-2} $ does so in planar graphs. Tait and Tobin [J. Combin. Theory Ser. B, 2017] determined the fundamental structure as the key to confirming these two conjectures for sufficiently large $n$. Recently, Yin and Li [Discrete Mathematics, 2026] characterized the extremal graphs for $\\emph{spex}_{\\mathcal{P}}(n,B_{t,l})$ and $\\emph{spex}_{\\mathcal{OP}}(n,B_{t,l})$ in planar and outerplanar graphs on the basis of this key idea, where $B_{t,l}$ denotes the graph obtained by $t$ ",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0160",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13538v1",
    "status": "available",
    "timestamp": "2026-07-16T23:55:08.684252+00:00",
    "title": "ArXiv paper: Spectral extremal problems on planar and outerplanar graphs without $C_{k,l}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Generalization of Ramanujan's Continued Fractions for Even Order' and formalize its key results. Abstract: In this paper, we derive three generalized continued fractions of any even order $k$ with the aid of a general continued fraction identity of Ramanujan and we establish general theta function identities for these continued fractions. As an application of continued fraction of order seventy-six, we obtain partition theoretic identities and some vanishing coefficient results.",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_0162",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13600v1",
    "status": "available",
    "timestamp": "2026-07-17T00:31:43.190969+00:00",
    "title": "ArXiv paper: Generalization of Ramanujan's Continued Fractions for Even Order"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Hardness of Vertex Splitting: Cographs, Chordal Graphs, and Beyond' and formalize its key results. Abstract: Vertex splitting replaces a vertex (v) by two nonadjacent vertices whose neighborhoods together equal (N(v)). A split is \\emph{exclusive} if these neighborhoods are disjoint and \\emph{shallow} if no newly created vertex is split again. For a graph property (\u03a0), \\textsc{(\u03a0)-Vertex Splitting} asks whether at most (k) splits can transform a graph (G) into one satisfying (\u03a0). We continue the systematic study of this operation and settle several open problems. First, we prove that \\textsc{Cograph Vertex Splitting} is \\textsf{NP}-complete, even on graphs of girth at least 5, resolving a question of Firbas and Sorge (ISAAC 2024). More generally, \\textsc{(P_t)-free Vertex Splitting} is \\textsf{NP}-complete for every fixed (t\\geq 4). We also prove that \\textsc{Chordal Vertex Splitting} and \\textsc{Unit-Interval Vertex Splitting} are \\textsf{NP}-complete, resolving two questions of Abu-Khzam, Chakraborty, Isenmann, and Oijid (IWOCA 2026). Our hardness results extend to the exclusive and shallow ",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0163",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.13517v1",
    "status": "available",
    "timestamp": "2026-07-17T00:50:43.952244+00:00",
    "title": "ArXiv paper: Hardness of Vertex Splitting: Cographs, Chordal Graphs, and Beyond"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Towards a characterization of idempotent Schur multipliers' and formalize its key results. Abstract: It is conjectured that every idempotent Schur multiplier can be written as a finite sum of contractive idempotents. This conjecture is equivalent to the statement that any boolean matrix $A$ with factorization norm $\\lVert A\\rVert_{\u03b3_2}$ at most $\u03b3$ can be expressed as a signed sum $$A = \\sum_{i=1}^L \\pm B_i,$$ where, up to permutation of rows and columns, each $B_i$ is a blow-up of an identity matrix, and $L$ depends only on $\u03b3$. In this note we show that if $A$ is an $n\\times n$ boolean matrix with $\\lVert A\\rVert_{\u03b3_2} \\le \u03b3$, then it admits such an expression with $L = 2^{O(\u03b3^9) + \\log^*\\! n}$, where $\\log^*$ is the iterated logarithm function. As an application, any sequence of matrices with bounded factorization norm belongs to the complexity class $\\mathrm{P}^\\mathrm{EQ}$ of communication problems with polylogarithmic equality-oracle complexity.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_0164",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14316v1",
    "status": "available",
    "timestamp": "2026-07-17T01:26:03.097278+00:00",
    "title": "ArXiv paper: Towards a characterization of idempotent Schur multipliers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The role of expanders in the spectral geometry of metric graphs' and formalize its key results. Abstract: Expanders are families of graphs that are sparse in edges but dense in connectivity. After reviewing combinatorial and spectral definitions of expanders, we use precise lower bounds on Ramanujan graphs to investigate upper bounds -- and, specifically, the lack thereof -- on the eigenvalues of the Laplacian on \\emph{metric} graphs in terms of volume, diameter, girth, mean distance, and torsional rigidity, among others.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0165",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14312v1",
    "status": "available",
    "timestamp": "2026-07-17T01:43:09.960303+00:00",
    "title": "ArXiv paper: The role of expanders in the spectral geometry of metric graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Cayley Graphs Of Order $pqrs$ Are Hamiltonian' and formalize its key results. Abstract: Assume $ G $ is a finite group with order $ |G| = pqrs $, where $ p $, $ q $, $ r $, and $ s $ are distinct prime numbers. We prove that every connected Cayley graph of $ G $ contains a hamiltonian cycle. Our result drops all restrictions of all previously known results on hamiltonian cycles in Cayley graphs of groups of order $pqrs$.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0166",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14440v1",
    "status": "available",
    "timestamp": "2026-07-17T02:00:29.717066+00:00",
    "title": "ArXiv paper: Cayley Graphs Of Order $pqrs$ Are Hamiltonian"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Corner Rectangle Visibility Graphs' and formalize its key results. Abstract: We introduce corner rectangle visibility graphs (CRVGs), a combination of two geometrically defined classes of graphs: rectangle visibility graphs (RVGs) and rectangle-of-influence graphs (RIGs). A CRVG has vertices represented by axis-parallel rectangles in the plane, and edges represented by axis-parallel rectangles with one corner at a corner of a vertex-rectangle, an opposite corner at the boundary of another vertex-rectangle, and no vertex-rectangles in their interiors. We also consider CRVGs that only see in one or two directions (south CRVGs and southwest CRVGs). We prove that south CRVGs have at most $\\left[\\frac{n^2}{4}\\right]+n-2$ edges, and this bound is tight. This is the same as the tight edge bound for closed RIGs, but they are different graph classes. We also show that southwest CRVGs have at most $\\left[\\frac{n^2}{3}+\\frac{n}{3}\\right]-1$ edges, and this bound is tight. We prove that CRVGs on $n$ vertices have at most $e$ edges, where $\\lfloor \\frac{3n^2}{8} \\rfloor \\le",
    "domains": [
      "Geometry"
    ],
    "id": "fd_0167",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14433v1",
    "status": "available",
    "timestamp": "2026-07-17T02:17:33.618891+00:00",
    "title": "ArXiv paper: Corner Rectangle Visibility Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Asymptotic Brill-Noether Existence at the Half-Canonical Degree: Energy Pairing, Cheeger Inequality and Covering Radii' and formalize its key results. Abstract: We study asymptotic versions of the Brill-Noether existence conjecture on graphs via techniques inspired by the geometry of numbers. We confirm an asymptotic version of the conjecture at (and near) the half-canonical degree in several well-connected families of graphs. They include expander graphs of even valence, almost-Ramanujan graphs of a fixed valence at least five and certain random graphs. In particular, for any fixed $k \\geq 5$, almost all simple, connected, $k$-regular graphs satisfy the Brill-Noether existence conjecture at the half-canonical degree up to a constant factor. The key tool is a Cheeger-style inequality for the covering radius of a certain periodic set with respect to the energy quadratic form associated with the graph. As an application, we lower bound the diameter of graphs associated with certain dynamical systems called reversal systems. We conclude with a suggestion to tackle the asymptotic version of the conjecture, in general, i.e. beyond half-canonical de",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0168",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15213v1",
    "status": "available",
    "timestamp": "2026-07-17T03:09:40.499550+00:00",
    "title": "ArXiv paper: Asymptotic Brill-Noether Existence at the Half-Canonical Degree: Energy Pairing, Cheeger Inequality and Covering Radii"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The order of long rainbow arithmetic progressions' and formalize its key results. Abstract: Let $T_k$ be the minimum positive integer $t$ such that, for every positive integer $n$, every equinumerous $t$-coloring of $[tn]$ contains a rainbow $k$-term arithmetic progression. Jungi\u0107, Licht, Mahdian, Ne\u0161et\u0159il and Radoi\u010di\u0107 conjectured that $T_k=\u0398(k^2)$, while Conlon, Fox and Sudakov proved that $T_k=O(k^2\\log k)$. We prove the matching lower bound $T_k=\u03a9(k^2\\log k)$, and hence $T_k=\u0398(k^2\\log k)$.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0169",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15116v1",
    "status": "available",
    "timestamp": "2026-07-17T03:25:28.901411+00:00",
    "title": "ArXiv paper: The order of long rainbow arithmetic progressions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Dense sets without large sumsets' and formalize its key results. Abstract: We prove, for all fixed $0 < \u03b4< 1$, and all sufficiently large $n$, that there exists $S \\subset [n]$ with $|S| \\ge \u03b4n$ such that $A + B \\not \\subset S$ for all ${A, B \\subset \\mathbb{N}}$ satisfying $$\\min\\big\\{|A|, |B|\\big\\} \\ge \\big(3 + o(1)\\big) \\frac{\\log n }{ \\log (1 / \u03b4)}.$$ A very recent result of Hern\u00e1ndez and Hetzel shows that our bound is sharp up to a factor of 3, and together our results settle a conjecture of Kra, Moreira, Richter, and Robertson. In fact, we prove that a $\u03b4$-dense random subset of $[n]$ is a valid choice for $S$ with high probability, and that one can take $n^{-\u03b1} \\le \u03b4\\le 1 - c$ where $c > 0$ is fixed and $\u03b1> 0$ depends only on the $o(1)$ error, answering another question of the same authors in a strong form.",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_0170",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15269v1",
    "status": "available",
    "timestamp": "2026-07-17T03:09:44.217502+00:00",
    "title": "ArXiv paper: Dense sets without large sumsets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The K\u0151vari-S\u00f3s-Tur\u00e1n theorem for $\\operatorname{GF}(q)$-representable matroids' and formalize its key results. Abstract: In this paper, we establish an analogue of the K\u0151vari-S\u00f3s-Tur\u00e1n Theorem for $\\operatorname{GF}(q)$-representable matroids. For $2\\leq s\\leq t$, we show that if $M$ is a rank-$n$ simple $\\operatorname{GF}(q)$-representable matroid having no $M(K_{s,t})$-restriction, then \\[ |E(M)|=O_{q,s,t}\\bigl(q^{(1-1/s)n}\\bigr). \\] In particular, we prove that the maximum number of elements in a simple rank-$n$ binary matroid with no $M(K_{2,t})$-restriction is $\u0398_{t}(2^{n/2})$ where the lower bound is obtained using binary Sidon sets.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0171",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15226v1",
    "status": "available",
    "timestamp": "2026-07-17T03:25:32.410212+00:00",
    "title": "ArXiv paper: The K\u0151vari-S\u00f3s-Tur\u00e1n theorem for $\\operatorname{GF}(q)$-representable matroids"
  },
  {
    "consumed_by_exp_id": "406a341d",
    "description": "An Escher staircase is an infinite strictly ascending chain of ideals I_1 strictly contained in I_2 strictly contained in ... that nevertheless has I_1 as an element of the infinite intersection. This seems impossible \u2014 how can an infinite ascending chain loop back to the beginning? But in the ring of integer-valued polynomials Int(Z), the chain I_n = {f in Int(Z) : f(Z) contained in 2^n Z} is strictly ascending (I_n strictly contained in I_{n+1}) yet the intersection of all I_n is {0}, which contains the zero polynomial that is also in I_1. Conjecture: Every non-Noetherian ring contains an Escher staircase, and the 'height' of the Escher effect (measured by the Krull dimension gap) is a new ring invariant. For Int(Z), the Escher height is infinite (the chain never stabilizes). For Z[x_1, x_2, ...], the Escher height equals the number of variables. For the p-adic integers Z_p, there is NO Escher staircase (Z_p is a DVR, hence Noetherian). Test: prove that Int(Z) has an Escher staircase of infinite height. Prove that k[x_1,...,x_n] has Escher height n. Compute the Escher height for the ring of all algebraic integers. Impact: a new invariant for non-Noetherian rings that measures how far a ring is from being Noetherian \u2014 the algebraic equivalent of Escher's impossible architecture.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0173",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-17T03:25:44.344800+00:00",
    "title": "Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A Bombieri-Vinogradov theorem for exponential sums over products of k primes' and formalize its key results. Abstract: We prove a Bombieri-Vinogradov type theorem for exponential sums over products of $k$ primes. As an application, we show the lower bound $$\\sup_{n\\le x} \\left|\\sum_{m\\le n} 1_{\u03a9(m) = k} e(\u03b1m)\\right| \\gg x^{1/6 - \\varepsilon}$$ for $2\\le k\\le (2-\\varepsilon)\\log\\log x$ and $\u03b1\\in\\mathbb{R},$ where we noted $e(\u03b2) := e^{2i\u03c0\u03b2}.$",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0175",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15137v1",
    "status": "available",
    "timestamp": "2026-07-17T03:56:56.611330+00:00",
    "title": "ArXiv paper: A Bombieri-Vinogradov theorem for exponential sums over products of k primes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Two problems on booksize and triangular edges in Nosal graphs' and formalize its key results. Abstract: A graph $G$ with $m$ edges is said to be a Nosal graph if $\u03c1(G)>\\sqrt{m}$. For a graph $G$, we write $bk(G)$ for its maximum book size and $\u03c4(G)$ for the number of edges contained in triangles. Li, Liu and Zhang [J. Combin. Theory Ser. B 179 (2026) 219--249] proved that every $m$-edge Nosal graph satisfies $bk(G)> \\frac{1}{24}\\sqrt{m}$ and $\u03c4(G) > \\frac{1}{12}\\sqrt{m}$. Recently, Zhai, Li and Lou [arXiv:2601.10163v2] proved that every $m$-edge Nosal graph satisfies $bk(G)> \\frac{1}{9}\\sqrt{m}$. In this paper, we establish the following result: Every $m$-edge graph $G$ with no isolated vertices and $\u03c1(G)\\geq \\sqrt{m}$ that is not isomorphic to any complete bipartite graph satisfies $bk(G)\\geq\\frac{\u03c1(G)}{3}$ and $\u03c4(G)\\geq \u03c1(G)$. As direct consequences, we answer a question of Li, Liu and Zhang [J. Combin. Theory Ser. B 179 (2026) 219--249] and confirm a conjecture of Li, Feng and Peng [J. Graph Theory 110 (4) (2025) 408--425].",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0176",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15071v1",
    "status": "available",
    "timestamp": "2026-07-17T04:12:35.016360+00:00",
    "title": "ArXiv paper: Two problems on booksize and triangular edges in Nosal graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On a character-twisted analogue of Sch\u00e4ffer's equation' and formalize its key results. Abstract: Let $f$ be a positive integer, and let $\u03c7$ be a primitive quadratic character of conductor $f$. Let $k$ be a positive integer, and write $B_k(\u03c7,X)$ for the $k$-th Bernoulli polynomial corresponding to $\u03c7$. Suppose $B_k(\u03c7,X)$ is irreducible and of degree at least $2$. Then for 100% of positive integers $m$ divisible by $f$, the Diophantine equation \\[ \u03c7(1) \\cdot (x+1)^k+\u03c7(2) \\cdot (x+2)^k+\\cdots+\u03c7(m) \\cdot (x+m)^k \\, =\\, y^n, \\] has no solutions with $x$, $y$, $n$ integers, and $n \\ge 2$.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0177",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15090v1",
    "status": "available",
    "timestamp": "2026-07-17T04:28:01.584621+00:00",
    "title": "ArXiv paper: On a character-twisted analogue of Sch\u00e4ffer's equation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Products of simplices are canonically Ramsey' and formalize its key results. Abstract: A set of points $C \\subset \\mathbb{R}^n$ is called canonically Ramsey if there is some set of points $S\\subset \\mathbb{R}^{n'}$ such that any colouring of $S$, using any number of colours, must contain either a monochromatic copy of $C$ or a rainbow copy of $C$. Mao, Ozeki, and Wang introduced this notion, showing that 30-60-90 triangles are canonically Ramsey. Since then, various other canonically Ramsey configurations have been identified. The author showed that cuboids are canonically Ramsey, while Ge, Shu, Xu, and Yu recently showed that simplices are canonically Ramsey. We extend both of these results, proving that all products of simplices are canonically Ramsey.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0178",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15264v1",
    "status": "available",
    "timestamp": "2026-07-17T03:57:00.492646+00:00",
    "title": "ArXiv paper: Products of simplices are canonically Ramsey"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A Census of New Snake-in-the-Box Records' and formalize its key results. Abstract: The snake-in-the-box problem, introduced by Kautz in 1958, asks for the longest induced (chordless) path, called a snake, in the hypercube graph $Q_n$. The maximum length $a(n)$ is known in each dimension $n \\leq 8$. We give snakes that are longer than the previous best-known in every dimension from $9$ to $13$, improving the lower bound on $a(n)$. All record-length paths are provided in a computer-verifiable dataset.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0179",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15270v1",
    "status": "available",
    "timestamp": "2026-07-17T04:12:38.554073+00:00",
    "title": "ArXiv paper: A Census of New Snake-in-the-Box Records"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Double $L$-values of Negative Weight Admitting Series Representations' and formalize its key results. Abstract: In this paper, we construct double $L$-values of negative weight that admit series representations. In our construction, we use the Thue-Morse sequence, which appears in combinatorics on words and automatic sequences.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0180",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15037v1",
    "status": "available",
    "timestamp": "2026-07-17T04:28:04.951159+00:00",
    "title": "ArXiv paper: Double $L$-values of Negative Weight Admitting Series Representations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Towards realistic large random models of labeled transition systems and their 0-1 laws' and formalize its key results. Abstract: Model checking is the automated verification of properties (specified in some modal logic) in labeled transition systems (LTSs); it is an essential tool in ensuring software systems function as intended. State spaces of software grow exponentially, and heuristics are needed to ensure model checking remains feasible in real-world applications. Heuristics, in turn, require a good understanding on the typical behaviour of LTSs. In this paper, we use random graph theory to create a probabilistic model of large LTSs. From a theoretical analysis of the creation of large LTSs, backed by empirical data from the Model Checking Contest, we endow these models with realistic parameter values. Then, we analyze the asymptotic behaviour of this model under LTL and CTL, two modal logics popular in model checking. We show that, depending on the precise model, as the size grows to infinity we either have a convergence law (for every formula, the probability that it holds converges to a limit) or a 0-1 l",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0181",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15029v1",
    "status": "available",
    "timestamp": "2026-07-17T05:57:53.860008+00:00",
    "title": "ArXiv paper: Towards realistic large random models of labeled transition systems and their 0-1 laws"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Heilbronn's Problem in the Unit Triangle: Certified Optimal Configurations for up to $n\\le 8$' and formalize its key results. Abstract: We study Heilbronn's triangle problem in the unit right triangle, where $n$ points are placed to maximize the smallest of the $\\binom{n}{3}$ triangle areas they span. We prove a boundary-structure result: unless all three vertices are occupied, some optimal configuration with $n \\ge 5$ has at least four points on the boundary, one edge carrying two of them. With the affine $S_3$ symmetry this fixes four boundary points and $n$ orientation variables in a mixed-integer model that certifies global optimality for all $n \\le 8$, including $n = 7, 8$, where no proof was previously available, closing gaps left by grid search and by branch-and-bound. For $n \\le 7$ we obtain exact optima with explicit configurations. For $n = 8$ the optimum is conjectured to be the real root of a septic obtained by Chen, Zeng and Zhou, which our reconstruction confirms to $250$ digits. We show its Galois group is $S_7$, so on that conjecture no expression in radicals exists.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0182",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15021v1",
    "status": "available",
    "timestamp": "2026-07-17T06:13:59.285434+00:00",
    "title": "ArXiv paper: Heilbronn's Problem in the Unit Triangle: Certified Optimal Configurations for up to $n\\le 8$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Efficient Hamilton covers and linear arboricity of random graphs' and formalize its key results. Abstract: A Hamilton cover of a graph is a collection of Hamilton cycles whose union contains all edges. Since each Hamilton cycle covers two edges at every vertex, every Hamilton cover has size at least $\\lceil \u0394(G)/2\\rceil$. We prove that this lower bound is tight for binomial random graphs $G(n,p)$ throughout the widest possible range of edge probabilities: if $\u03c9(n)\\to\\infty$ and \\[ \\frac{\\log n+\\log\\log n+\u03c9(n)}{n} \\le p=p(n) \\le 1-\\frac{\u03c9(n)}{n^{2}}, \\] then $G\\sim G(n,p)$ with high probability has a Hamilton cover of size $\\left\\lceil \\frac{\u0394(G)}{2}\\right\\rceil. $ The main new contribution is the sparse regime near the Hamiltonicity threshold, where we prove a conjecture of Dragani\u0107, Glock, Munh\u00e1 Correia and Sudakov. Our proof develops constructive tools for decomposing such graphs into controlled forest systems and extending them, using reserved pseudorandom structure, into Hamilton cycles. We also prove the corresponding hitting-time result for the random graph process, answering a questi",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "fd_0183",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14881v1",
    "status": "available",
    "timestamp": "2026-07-17T06:29:52.184186+00:00",
    "title": "ArXiv paper: Efficient Hamilton covers and linear arboricity of random graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Alternating adjacent-sum polytopes: transfer matrices and Ehrhart series' and formalize its key results. Abstract: We study a period-two family of adjacent-sum lattice polytopes whose consecutive-coordinate bounds alternate between $s$ and $s+1$. This provides a simple non-uniform deformation of the classical uniform model while retaining an explicit transfer-matrix structure. The lattice-point counts exhibit a parity split: the odd- and even-dimensional sequences have distinct rational generating functions with a common denominator. The odd-dimensional series satisfies a M\u00f6bius recurrence and admits an arctangent closed form, whereas the even-dimensional series obeys a coupled recurrence. Their common dominant pole determines the exponential growth in both parity classes. For the cyclic model obtained by adding a constraint between the first and last coordinates, the count becomes a matrix trace. The two cyclic parity classes again have rational generating functions with the same denominator; the even-dimensional numerator has a Jacobi-derivative form, while the odd-dimensional one is given by an ",
    "domains": [
      "Cryptography"
    ],
    "id": "fd_0184",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14887v1",
    "status": "available",
    "timestamp": "2026-07-17T06:45:30.630076+00:00",
    "title": "ArXiv paper: Alternating adjacent-sum polytopes: transfer matrices and Ehrhart series"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Roman-Type Domination on Convex and Chordal Bipartite Graphs: Algorithms and Hardness' and formalize its key results. Abstract: Roman domination and its variants form an important family of domination-type graph parameters motivated by protection, fault tolerance, and resource allocation. A Roman dominating function of a graph \\(G\\) is a function \\(f:V(G)\\rightarrow\\{0,1,2\\}\\) such that every vertex \\(v\\) with \\(f(v)=0\\) has a neighbour \\(u\\) with \\(f(u)=2\\). The weight of \\(f\\) is \\(w(f)=\\sum_{v\\in V(G)}f(v)\\), and the minimum weight of a Roman dominating function of \\(G\\) is the Roman domination number, denoted by \\(\u03b3_R(G)\\). In this paper, we study four variants of Roman domination on two natural subclasses of bipartite graphs, namely convex bipartite graphs and chordal bipartite graphs. On the positive side, we develop a unified left-to-right dynamic programming framework for Roman-\\(\\{2\\}\\) domination, double Roman domination, perfect Roman domination, and unique response Roman domination on convex bipartite graphs. The algorithms exploit the interval structure of one bipartition class and represent all un",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0185",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15026v1",
    "status": "available",
    "timestamp": "2026-07-17T07:01:30.942809+00:00",
    "title": "ArXiv paper: Roman-Type Domination on Convex and Chordal Bipartite Graphs: Algorithms and Hardness"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Equidistribution and the torsor method' and formalize its key results. Abstract: We prove equidistribution and Manin's conjecture for rational points outside the lines on smooth split quintic del Pezzo surfaces over number fields with respect to any anticanonical height. The proof is based on a general theorem that is broadly usable to deduce equidistribution when using the torsor method with several equivalent height functions to treat variants of Manin's problem.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0186",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14866v1",
    "status": "available",
    "timestamp": "2026-07-17T07:17:11.718781+00:00",
    "title": "ArXiv paper: Equidistribution and the torsor method"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'D-coloring of planar graphs' and formalize its key results. Abstract: A proper edge-coloring of a graph $G$ is a D-coloring if every subgraph isomorphic to $K_4-e$ is rainbow. The minimum number of colors in such a coloring is the D-chromatic index $\u03c7'_D(G)$. Wang conjectured that every planar graph of maximum degree $\u0394\\ge 4$ satisfies $\u03c7'_D(G) \\le 9$ for $\u0394= 4$, $\u03c7'_D(G) \\le 10$ for $\u0394= 5$, and $\u03c7'_D(G) \\le 2\u0394- 1$ for $\u0394\\ge 6$. We prove that every planar graph $G$ satisfies \\[ \u03c7_D'(G) \\leq \\begin{cases} 9, & \u0394(G) \\leq 4, \\\\ 10, & \u0394(G) = 5, \\\\ 2\u0394(G) - 1, & \u0394(G) \\geq 33. \\end{cases} \\] Each bound is best possible in its stated range. Consequently, Wang's conjecture remains open only for $6 \\le \u0394\\le 32$.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0187",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14837v1",
    "status": "available",
    "timestamp": "2026-07-17T07:32:50.518523+00:00",
    "title": "ArXiv paper: D-coloring of planar graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On Matrix Product Factorization in Association Schemes' and formalize its key results. Abstract: We study matrix product factorizations (MPFs) in symmetric association schemes: identities $A_SA_T=A_U$ where $A_S,A_T,A_U$ are loopless unions of basic relations and the ordinary matrix product is again a $0$-$1$ adjacency matrix. We give equivalent structural and spectral criteria for MPFs, derive valency and rank restrictions, and analyze several standard families. For $2$-class schemes, the only nontrivial loopless MPF comes from the scheme of the $5$-cycle. For $P$-polynomial schemes, the distance-regular recurrence gives strong restrictions on products $A_1A_i$. We also prove a universal pentagon theorem for the case $A_SA_T=J-I$, and show that extremal rank forces all non-zero eigenvalues of $A_U$ to be $\\pm k(U)$, hence gives bipartiteness. Finally, in Hamming schemes we obtain rank obstructions and classify MPFs of the form $A_1A_T=A_U$: in $H(d,2)$, for $d\\ge2$, the only non-zero loopless example is $A_1A_d=A_{d-1}$, which is trivial since $A_d$ has valency $1$; for $q>2$, no",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0188",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14848v1",
    "status": "available",
    "timestamp": "2026-07-17T07:48:50.380995+00:00",
    "title": "ArXiv paper: On Matrix Product Factorization in Association Schemes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Acyclic Dichromatic Number of Tournaments: these are the Champions' and formalize its key results. Abstract: The acyclic dichromatic number of an oriented graph is the minimum size of a vertex-partition such that the digraphs induced by any single part are acyclic, and the oriented bipartite graphs between any two parts are acyclic too. We characterize the subtournaments that must appear in every tournament with sufficiently large acyclic dichromatic number, thereby confirming a conjecture of Bang-Jensen, Picasarri-Arrieta, and Yeo and prove that acyclic dichromatic number satisfies a local to global property.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0189",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14694v1",
    "status": "available",
    "timestamp": "2026-07-17T08:04:40.463724+00:00",
    "title": "ArXiv paper: Acyclic Dichromatic Number of Tournaments: these are the Champions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Discrete Einstein metrics on unicyclic graphs' and formalize its key results. Abstract: In earlier work with Cheng and Hua we showed that on a finite tree the discrete Einstein metrics of the Lin--Lu--Yau curvature are the Perron eigenvector of an edge-indexed Ricci matrix. We extend this theory to unicyclic graphs. We determine exactly when the tree picture persists -- the balanced regime, where the spectrum becomes periodic rather than Dirichlet-type -- and compute it in closed form for bare cycles and for regular suns (cycles with pendant leaves); for a single decorated vertex on a long cycle it persists up to an explicit golden-ratio threshold. Beyond this regime the problem is piecewise-linear, and phenomena impossible on a tree appear: the Einstein metric can be non-unique, or absent -- a triangle with a pendant leaf carries none. For the regular suns we prove that it exists and is unique.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0190",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14748v1",
    "status": "available",
    "timestamp": "2026-07-17T08:20:26.165530+00:00",
    "title": "ArXiv paper: Discrete Einstein metrics on unicyclic graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Minimal degree of an isogeny between a supersingular elliptic curve and its conjugate' and formalize its key results. Abstract: Let $E$ be a supersingular elliptic curve defined over $\\bar{\\mathbb{F}}_p$ and $E^{(p)}$ be its conjugate. We give a bound on the minimal degree of an isogeny from $E$ to $E^{(p)}$ depending on $p$, and show that this bound is both asymptotically optimal as well as sharp in many cases. This bound is obtained by developing a new technique to compute the degree of certain isogenies from a supersingular elliptic curve to its conjugate, and we present extensive computations of the successive minima of the lattice containing these isogenies. Following this, we give several conjectures supported by the data we have obtained, including some on the set of primes $p$ for which the bound we give in this article is attained.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_0191",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14624v1",
    "status": "available",
    "timestamp": "2026-07-17T08:36:24.246676+00:00",
    "title": "ArXiv paper: Minimal degree of an isogeny between a supersingular elliptic curve and its conjugate"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The First Moment of Dirichlet L-functions over Generators of the Character Group' and formalize its key results. Abstract: We evaluate the average of the central values $L(1/2,\u03c7)$ over the generators of the group of Dirichlet characters modulo $q$, as $q\\to\\infty$ through the primes.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0192",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14612v1",
    "status": "available",
    "timestamp": "2026-07-17T08:52:32.545530+00:00",
    "title": "ArXiv paper: The First Moment of Dirichlet L-functions over Generators of the Character Group"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The optimal $\u03c7$-bound for $\\{P_6, \\text{dart}, K_4\\}$-free graphs' and formalize its key results. Abstract: A \\textit{diamond} is a graph obtained from \\(K_4\\) by removing an edge, and a \\textit{dart} is a graph obtained from a diamond by adding a pendant edge to a vertex of degree 3. We prove that every $\\{P_6, \\text{dart}, K_4\\}$-free graph is 6-colorable. This improves the previous bound of 7 due to Hong and Xu \\cite{HongXu2025} and resolves their open question on the optimality of the bound. Our result also extends a theorem of Karthick and Mishra~\\cite{KarthickMishra2018}, who proved 6-colorability for the class of \\(\\{P_6, \\text{diamond}, K_4\\}\\)-free graphs.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0193",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14667v1",
    "status": "available",
    "timestamp": "2026-07-17T09:08:14.870404+00:00",
    "title": "ArXiv paper: The optimal $\u03c7$-bound for $\\{P_6, \\text{dart}, K_4\\}$-free graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Multiple Clausen values and deformed Ap\u00e9ry-like series' and formalize its key results. Abstract: With generalized central binomial coefficients $ \\binom{2x}{x}:=\\frac{\u0393(2x+1)}{[\u0393(x+1)]^2}$ defined through Euler's gamma function, we represent deformed Ap\u00e9ry-like series \\[ \\mathscr A_{s,n}:=\\sum_{k=1}^\\infty\\left.\\!\\frac{\\partial^n}{\\partial x^n}\\frac{1}{x^s\\binom{2x}{x}}\\right|_{x=k} \\] by multiple Clausen values (MCVs), which belong to a special class of cyclotomic multiple zeta values (CMZVs) at level $3$. For example, exploiting provable algebraic relations among MCVs, we show that \\[\\mathscr A_{1,5}=-\\frac{9[495L(\u03c7_{-3},6)-30\u03c0^{2}L(\u03c7_{-3},4)-2\u03c0^{4}L(\u03c7_{-3},2)]}{4}\\]and\\[\\mathscr A_{4,4}=\\frac{352\u03b6_{5,3}}{15}+\\frac{752537\u03c0^{8}}{10206000},\\]where $ L(\u03c7_{-3},s):=\\sum_{n=0}^\\infty\\left[(3n+1)^{-s}-(3n+2)^{-s}\\right]$ and $ \u03b6_{5,3}:=\\sum_{m=1}^\\infty\\sum_{n=1}^{m-1}m^{-5}n^{-3}$.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0194",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14646v1",
    "status": "available",
    "timestamp": "2026-07-17T09:24:14.667974+00:00",
    "title": "ArXiv paper: Multiple Clausen values and deformed Ap\u00e9ry-like series"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Online Beck--Fiala Down to Logarithmic Sparsity' and formalize its key results. Abstract: The Beck--Fiala conjecture asserts that every matrix $A\\in\\{0,1\\}^{n\\times T}$ with at most $d$ nonzero entries in each column has discrepancy $O(\\sqrt d)$. A major breakthrough result of Bansal and Jiang recently established the validity of the conjecture for $d \\ge \\log(T)^2$. The present article extends the validity of the classical \\textit{offline} Beck--Fiala conjecture to $d \\ge \\log(T)^{1+o(1)}$; moreover, the main thrust of the result is that it is actually obtained by an efficient \\textit{online} algorithm that minimizes prefix discrepancy. The result is also essentially optimal, since online prefix discrepancy is known to scale as $\u03c9(\\sqrt{d})$ for $d =o(\\log T)$. As an immediate corollary, the open question of online vector balancing in the Spencer setting is also resolved. The algorithm is based on a compactly supported Metropolis fixed-point walk, constructed by combining ideas from several recent works on the online Koml\u00f3s problem. The proof was generated in conversation ",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_0195",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14238v1",
    "status": "available",
    "timestamp": "2026-07-17T09:55:54.324007+00:00",
    "title": "ArXiv paper: Online Beck--Fiala Down to Logarithmic Sparsity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Shuffle-compatibility for combinatorial statistics on words, parking functions, and set partitions' and formalize its key results. Abstract: We introduce notions of (weak) shuffle-compatibility for statistics on words, parking functions, and set partitions, generalizing Gessel and Zhuang's shuffle-compatibility for statistics on permutations. For parking functions and set partitions, we perform a systematic review of statistics that appear in the FindStat database (as well as the literature). We further define (shifted) shuffle algebras of (weakly) shuffle-compatible statistics on the equivalence classes induced by the statistics. These algebras relate closely to various combinatorial Hopf algebras such as QSym, FQSym, PQSym, and NCSym. These constructions yield new combinatorial interpretations of various Hopf algebra bases and, in some cases, new bases entirely.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0196",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14255v1",
    "status": "available",
    "timestamp": "2026-07-17T10:43:10.961080+00:00",
    "title": "ArXiv paper: Shuffle-compatibility for combinatorial statistics on words, parking functions, and set partitions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Measures and generalizations of dual Littlewood identities' and formalize its key results. Abstract: We introduce three families of vectors $|\\underline\u03bb^{so}\\rangle$, $|\\underline\u03bb^{sp}\\rangle$ and $|\\underline\u03bb^{o}\\rangle$ parametrized by partitions in the Fock space by using products of adjoint vertex operators. We show that the quotient space of the dual vacuum vector is spanned by the partition vectors indexed by a special family of partitions. The partition-indexed vectors also help us to derive the dual Littlewood identities of types B, C, and D in a new manner associated to the special family of partitions. As an application, we obtain a new free fermionic construction to show that the measures related to dual Littlewood identities introduced by Rains \\cite[Section 7]{Rai2000} and Betea \\cite[Section 3]{Be2020} are determinantal with repect to some explicit correlation kernels. Furthermore we establish a number of generalized Littlewood identities summed over certain restricted partitions by computing the inner products with elements indexed by one-column partitions {or genera",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_0197",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14362v1",
    "status": "available",
    "timestamp": "2026-07-17T10:58:50.694164+00:00",
    "title": "ArXiv paper: Measures and generalizations of dual Littlewood identities"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'A memorial tribute: Adriano Garsia (1928--2024)' and formalize its key results. Abstract: Adriano Mario Garsia was born in Tunis on August 20, 1928, to a Tunisian-Italian family. He lived on a farm there until the end of World War II, then moved to Rome. After finishing high school, he was sent to the United States to live with relatives in Woyming and eventually made his way to California, becoming a student of Charles Loewner at Stanford in the early 1950s. Following his Ph.D., Adriano held positions at MIT, the University of Minnesota, and Caltech before joining the nascent mathematics department at the University of California, San Diego, in 1966 where he spent the remainder of his career. He passed away in San Diego on October 6, 2024, at the age of 96.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0198",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14184v1",
    "status": "available",
    "timestamp": "2026-07-17T12:24:24.101681+00:00",
    "title": "ArXiv paper: A memorial tribute: Adriano Garsia (1928--2024)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Recognition of algebraic matroids is undecidable' and formalize its key results. Abstract: We prove that the recognition problem for algebraic matroids is undecidable. Explicitly, this means that there is no algorithm that takes as input a finite set $S$ and a function $r\\colon\\mathcal{P}(S) \\to \\mathbb{Z}_{\\ge 0}$ (where $\\mathcal{P}(S)$ is the power set) and decides whether there exists a pair of fields $F \\subset K$, and a function $f\\colon S \\to K$, such that for all $A \\subseteq S$: $\\mathrm{tr.deg}_{K/F}(f(A)) = r(A)$. This problem is known to be decidable if the characteristic of the fields involved is constrained to be zero. We prove that it is undecidable if the characteristic is either left unspecified (in which case a realization over any characteristic is accepted) or fixed to be a prime $p$. The proof relies on Hrushovski--Zilber's Group Configuration Theorem and on the work of Evans and Hrushovski on \"Projective Planes in Algebraically Closed Fields\". We relate two different such projective planes, and eventually construct a reduction from the solvability of Di",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_0199",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14907v1",
    "status": "available",
    "timestamp": "2026-07-17T05:57:57.482712+00:00",
    "title": "ArXiv paper: Recognition of algebraic matroids is undecidable"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Second-order rigidity of coned polytope frameworks and the stress-flex conjecture from a vector-valued Schl\u00e4fli formula' and formalize its key results. Abstract: A coned polytope framework (CPF) is the bar-joint framework obtained from the 1-skeleton of a convex polytope by coning over some interior point. It was recently shown that CPFs are rigid, though the exact order of rigidity remained open. In this paper we introduce the Wachspress stress and use it to show that CPFs are prestress stable, in particular, second-order rigid. To this end, we resolve the stress-flex conjecture in the case of the Wachspress stress by identifying its dual formulation as a corollary of a vector-valued Schl\u00e4fli-type formula introduced by Schlenker and Souam. We give a new and purely discrete-geometric proof of this generalized Schl\u00e4fli formula.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_0200",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14878v1",
    "status": "available",
    "timestamp": "2026-07-17T06:14:02.691626+00:00",
    "title": "ArXiv paper: Second-order rigidity of coned polytope frameworks and the stress-flex conjecture from a vector-valued Schl\u00e4fli formula"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Shifted S-templates and improved lower bounds for Schur numbers' and formalize its key results. Abstract: We present an extension of the template-based approach for Schur numbers developed by Rowley. This new form of template construction, which we call shifted S-templates, was discovered during a conversation with ChatGPT 5.5 Pro, then refined, verified, and extended to multiple shifted S-templates. These new templates generalize the first ones by giving more flexibility in the coloring. Using this added flexibility with the new way to color the special label cells of the template, we exhibit a template which yields the recurrence $S(k+2) \\geq 10S(k)+2$, improving on the classical Abbott-Hanson recurrence $S(k+2) \\geq 9S(k)+4$ for the same step. Combined with the known bounds $S(6) \\geq 536$ and $S(11) \\geq 203\\,828$, this implies $S(8) \\geq 5\\,362$ and $S(13) \\geq 2\\,038\\,282$, improving the previously listed lower bounds $5\\,286$ and $2\\,011\\,290$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0201",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15034v1",
    "status": "available",
    "timestamp": "2026-07-17T06:29:55.509259+00:00",
    "title": "ArXiv paper: Shifted S-templates and improved lower bounds for Schur numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Erd\u0151s-Ko-Rado-type problem for hypergraph matchings' and formalize its key results. Abstract: Given integers $1\\leq t\\leq k$, a family of $k$-matchings in a complete $r$-partite $r$-uniform hypergraph is said to be $t$-intersecting if any two of its members share at least $t$ common edges. This concept unifies several well-studied classes of intersecting families, including classical intersecting families, intersecting families of permutations, partial permutations, and generalized permutations, as well as intersecting families of injections. In this paper we employ two approaches to determine the maximum size of $t$-intersecting families of $k$-matchings and to characterize the extremal families that attain this bound. Using a recent result of Keller, Lifshitz, Minzer, and Sheinfeld on $t$-intersecting families of permutations, we obtain Erd\u0151s-Ko-Rado-type theorems whose thresholds depend only on $t$. We also develop a $t$-cover-based approach that offers a complementary characterization of the extremal families.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0202",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14872v1",
    "status": "available",
    "timestamp": "2026-07-17T06:45:33.977459+00:00",
    "title": "ArXiv paper: Erd\u0151s-Ko-Rado-type problem for hypergraph matchings"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'On the Log-Concavity of the D'Arcais Polynomials for Normalised Functions' and formalize its key results. Abstract: A sequence $(a_n)_{n \\in \\mathbb{N}}$ of non-negative real numbers is called log-concave at $n$ if $a_n^2 \\geq a_{n+1}a_{n-1}$. This property has been generalised in various ways to families of polynomials. We introduce a new variant and show that certain types of D'Arcais polynomials have the respective properties at certain points.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0203",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14961v1",
    "status": "available",
    "timestamp": "2026-07-17T07:01:34.261580+00:00",
    "title": "ArXiv paper: On the Log-Concavity of the D'Arcais Polynomials for Normalised Functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Aperiodic tile sets from Sturmian lattices' and formalize its key results. Abstract: We give an explicit algorithm to construct aperiodic tile sets based on Sturmian words of quadratic slopes. The method works for any quadratic irrational slope, and we can produce an aperiodic tile set whose underlying scaling constant is a unit of any real quadratic field. There are two key ingredients in our construction. The first one is the ``Sturmian lattices'', an interesting grid structure generated by Sturmian words that emerged in an aperiodic monotile called Smith Turtle. The second is the bounded displacement equivalence of Delone sets, which plays a central role in this construction. A classification of Sturmian lattices and complete proofs are given in the full version.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0204",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14693v1",
    "status": "available",
    "timestamp": "2026-07-17T07:17:15.241913+00:00",
    "title": "ArXiv paper: Aperiodic tile sets from Sturmian lattices"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'HJ numbers revisited' and formalize its key results. Abstract: We improve the bounds on the Hales-Jewett numbers to a tower of exponentiations. Earlier it was $WaW$ (that is, iterations of towers which are themselves iterated exponentiations). We improve the inductive step there (induction on the size of the alphabet, $|\u039b|$) to 2-exponentiations, instead of towers. In the longer work in typing, (A) We present this inductive step as a partition theorem in its own right; (but in this preliminary version we make it just serve the bound on HJ numbers). (B) We shall deal with the density version of Hales-Jewett with similar bound. We are also dealing with the Graham-Rothschild Theorem and the Affine Ramsey Theorem and the polynomial case, and give background.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_0205",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14732v1",
    "status": "available",
    "timestamp": "2026-07-17T07:32:53.951032+00:00",
    "title": "ArXiv paper: HJ numbers revisited"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Robustness of periodicity in Grover walks under a magnetic vector potential' and formalize its key results. Abstract: We study the effect of magnetic vector potentials on periodic Grover walks on finite graphs. The magnetic vector potential is introduced through the framework of quantum graphs, which induces the Grover walk as a special case. We regard the vector potential as a perturbation of a periodic Grover walk and investigate the robustness of its periodicity. Our analysis reveals that the response to such perturbations depends on the spectral structure of the underlying graph. In particular, when the graph possesses at least one non-simple eigenvalue, we derive a Hermitian matrix that characterizes the robustness of its periodicity. As a consequence, we show that the perturbed dynamics is asymptotically described by a continuous-time quantum walk generated by this Hermitian matrix.",
    "domains": [
      "Physics",
      "Algebra"
    ],
    "id": "fd_0206",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14797v1",
    "status": "available",
    "timestamp": "2026-07-17T07:48:54.239145+00:00",
    "title": "ArXiv paper: Robustness of periodicity in Grover walks under a magnetic vector potential"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Aperiodicity and subword complexity in the binary expansion of powers of three' and formalize its key results. Abstract: We prove two results on the fine structure of the binary digits of $3^{m}$. First, for every fixed period $p$, the number of positions at which the binary expansion of $3^{m}$ breaks $p$-periodicity grows in order like $\\log m/\\log\\log m$; equivalently, no window of the expansion deeper than a fixed power of $\\log m$ is $p$-periodic. Second, the finite binary word formed by the low-order digits of $3^{m}$ has full low-order subword complexity: its complexity function satisfies $\\pcx_{3^{m}}(n)\\ge n+1$ for every length $n$, once $m$ is large enough.",
    "domains": [
      "Computation"
    ],
    "id": "fd_0207",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14774v1",
    "status": "available",
    "timestamp": "2026-07-17T08:04:43.859740+00:00",
    "title": "ArXiv paper: Aperiodicity and subword complexity in the binary expansion of powers of three"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'Several families of incommensurable noncompact hyperbolic Coxeter polytopes' and formalize its key results. Abstract: We classify all 141 finite-volume hyperbolic Coxeter five-dimensional polytopes with eight facets, of which 125 are noncompact. Using maximal-cusp density and a noncompact analog of Bogachev-Douba-Raimbault's argument, we construct infinitely many pairwise incommensurable noncompact Coxeter polytopes in dimensions 4, 5, 6, 7, and 9, with the number of commensurability classes growing at least exponentially in volume.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0208",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14715v1",
    "status": "available",
    "timestamp": "2026-07-17T08:20:29.584439+00:00",
    "title": "ArXiv paper: Several families of incommensurable noncompact hyperbolic Coxeter polytopes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the ArXiv paper 'The Spine: A Supersingular Highway' and formalize its key results. Abstract: We consider the structure of the spine of the supersingular $\\ell$-isogeny graph for one of the cases which arXiv:2502.03613 was not able to fully describe, $\\ell = 2$ and $p = 71, 119\\pmod{120}$. We find the distance, eccentricity, and diameter functions, of the components of the spine without the non-trivial edge not defined over $\\mathbb{F}_p$. Using these functions, we find the mean diameter of the spine and show how this value distinguishes the different structures of the spine. Thus, allowing us to use explicit computations to provide heuristics on the behavior of the spine's structure as $p$ varies.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0209",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.14572v1",
    "status": "available",
    "timestamp": "2026-07-17T09:24:18.119678+00:00",
    "title": "ArXiv paper: The Spine: A Supersingular Highway"
  },
  {
    "consumed_by_exp_id": "58e34414",
    "description": "For every fixed integer k \u2265 5 there exists N\u2080(k) such that for all n \u2265 N\u2080(k) and for every simple connected k\u2011regular graph G on n vertices, there is a divisor D on G of degree (k\u20112)n/2 (the half\u2011canonical degree) with rank at least k\u20111. Equivalently, for all sufficiently large n the Brill\u2011Noether number \u03c1(G, k\u20111, (k\u20112)n/2) is non\u2011negative and the existence part of Baker\u2019s Brill\u2011Noether conjecture holds for the pair (r, d) = (k\u20111, (k\u20112)n/2).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0211",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15213v1",
    "status": "in_progress",
    "timestamp": "2026-07-17T12:28:45.661463+00:00",
    "title": "Half\u2011canonical Brill\u2011Noether existence for k\u2011regular graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the constant 3 appearing in the threshold (3+o(1))(log n)/(log(1/\u03b4)) for sumset avoidance in \u03b4-dense subsets of [n] is optimal. Specifically, for any fixed \u03b4 \u2208 (0,1) and any \u03b5 > 0, there should exist arbitrarily large n such that every subset S \u2286 [n] with |S| \u2265 \u03b4n necessarily contains some sumset A+B where A,B \u2286 \u2115 satisfy min{|A|,|B|} \u2265 (3-\u03b5)(log n)/(log(1/\u03b4)). This would establish that the random construction used in the paper cannot be improved asymptotically.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0212",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15269v1",
    "status": "available",
    "timestamp": "2026-07-17T12:29:49.501452+00:00",
    "title": "Optimality of the Constant 3 in Dense Sets Without Large Sumsets"
  },
  {
    "consumed_by_exp_id": "0daa61af",
    "description": "For any family of k-regular connected graphs (k \u2265 5) satisfying a spectral expansion lower bound \u03bb\u2082 \u2265 \u03b5 > 0, the covering radius of the canonical class with respect to the energy quadratic form is O(\u221ag), which guarantees the existence of divisors of degree \u230ag/2\u230b and rank 0 satisfying the Brill-Noether condition \u03c1(g,0,\u230ag/2\u230b) \u2265 0.",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0213",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15213v1",
    "status": "in_progress",
    "timestamp": "2026-07-17T12:34:11.111826+00:00",
    "title": "Cheeger-type bound for covering radius implies Brill-Noether existence at half-canonical degree"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed density\u00a0\u03b4\u2208(0,1) and every integer t\u22652 there is a constant C(t,\u03b4)>0 such that for all sufficiently large n one can find a subset S\u2282[n] of size at least \u03b4n that contains no t\u2011fold sumset A\u2081+\u22ef+A_t with each |A_i|\u2265C(t,\u03b4)\u00b7(log n)/(log(1/\u03b4))^{1/(t\u22121)}.  This conjecture generalises the extremal result of Serra\u2011Szegedy and the recent construction for t=2, and it is compatible with the lower\u2011bound phenomenon proved by Hern\u00e1ndez\u2011and\u2011Hetzel.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0214",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15269v1",
    "status": "available",
    "timestamp": "2026-07-17T12:35:07.930478+00:00",
    "title": "Existence of Dense Sets without Large t\u2011Fold Sumsets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any fixed \u03b4 \u2208 (0,1) and sufficiently large n, there exists a subset S \u2282 [n] with |S| \u2265 \u03b4n such that no A, B \u2282 \u2115 with min{|A|,|B|} \u2265 (3+o(1)) log n / log(1/\u03b4) satisfy A+B \u2282 S.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0216",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15269v1",
    "status": "available",
    "timestamp": "2026-07-17T12:37:49.738112+00:00",
    "title": "Existence of \u03b4-Dense Sets Avoiding Sumsets of Size \u2265 (3+o(1)) log n / log(1/\u03b4)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed \u03b4 \u2208 (0,1), there exists a \u03b4-dense set S \u2282 [n] such that all sumsets A + B with min{|A|, |B|} \u2265 (3 log n)/log(1/\u03b4) are not contained in S. Moreover, the constant 3 is optimal: no smaller constant suffices.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0218",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15269v1",
    "status": "available",
    "timestamp": "2026-07-17T12:54:54.253384+00:00",
    "title": "Exact Constant in Dense Set Without Large Sumsets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The exact asymptotic growth of T_k = \u0398(k\u00b2 log k) with computable constants. Specifically, there exist positive constants c\u2081, c\u2082 such that lim inf (T_k / (k\u00b2 log k)) \u2265 c\u2081 and lim sup (T_k / (k\u00b2 log k)) \u2264 c\u2082, and the optimal values satisfy 0.1 \u2264 c\u2081 \u2264 c\u2082 \u2264 10.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_0219",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15116v1",
    "status": "available",
    "timestamp": "2026-07-17T12:55:09.512961+00:00",
    "title": "Rainbow Arithmetic Progression Threshold Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer t \u2265 2 and any fixed \u03b4 \u2208 (0,1), there exists a constant C = C(t,\u03b4) > 0 such that for all sufficiently large n, there exists a subset S \u2286 [n] with |S| \u2265 \u03b4n such that for all A\u2081, \u2026, A_t \u2286 \u2115 satisfying min_i |A_i| \u2265 C (log n / log(1/\u03b4))^{1/(t-1)}, the t-fold sumset A\u2081 + \u22ef + A_t is not contained in S. This generalizes the main result of the paper (which proves the t=2 case with C \u2248 3) to higher-order sumsets.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0220",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15269v1",
    "status": "available",
    "timestamp": "2026-07-17T13:03:31.081362+00:00",
    "title": "Avoidance of t-fold sumsets in dense subsets of [n]"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers s,t with 2 \u2264 s \u2264 t and prime power q, any simple rank-n GF(q)-representable matroid with no M(K_{s,t})-restriction satisfies |E(M)| \u2264 (c_{q,s,t} + o(1))\u00b7q^{(1-1/s)n} for a constant c_{q,s,t}, and this bound is tight. In particular, for binary matroids (q=2) with no M(K_{2,t})-restriction, the maximum number of elements is exactly \u0398_t(2^{n/2}).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0221",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15226v1",
    "status": "available",
    "timestamp": "2026-07-17T13:04:27.023831+00:00",
    "title": "The K\u0151vari-S\u00f3s-Tur\u00e1n Conjecture for GF(q)-representable Matroids: Sharp Asymptotic Bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed integer k \u2265 5, let G be a uniformly random simple, connected, k-regular graph on n vertices. Let d\u2080 = \u230ag/2\u230b where g = n - k + 1 is the genus of G. Then almost surely (as n \u2192 \u221e), for every pair of non-negative integers r\u2080, d\u2080 satisfying \u03c1(g,r\u2080,d\u2080) \u2265 0, there exists a divisor D on G of degree d\u2080 and rank at least r\u2080.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_0231",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15213v1",
    "status": "available",
    "timestamp": "2026-07-17T14:08:38.389554+00:00",
    "title": "Almost Sure Brill-Noether Existence at Half-Canonical Degree for Random Regular Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed \u03b4 > 0, there exists a constant C > 0 such that for all sufficiently large n, there is a subset S \u2282 [n] with |S| \u2265 \u03b4n, and for all A, B \u2282 \u2115 with min{|A|, |B|} \u2265 C log n, the sumset A + B is not contained in S.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_0231",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2607.15269v1",
    "status": "available",
    "timestamp": "2026-07-17T14:09:12.716043+00:00",
    "title": "Dense Sets Without Large Sumsets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle dcd7a4b2 (Q=0.750) proved 0 theorems in Tropical but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simulta",
    "domains": [
      "Tropical"
    ],
    "id": "sorry_fill_dcd7a4b2_19c1ccf9",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "dcd7a4b2",
    "status": "available",
    "timestamp": "2026-07-17T13:29:21.165121+00:00",
    "title": "Close Proofs: Quantum Surreal Numbers: Superposition of All Real Numbers"
  },
  {
    "consumed_by_exp_id": "5102d77c",
    "description": "Deja vu \u2014 the feeling that you've experienced something before \u2014 is a fixed point in a dynamical system. Model cognitive state as a function f: S -> S mapping current brain state to next brain state. A deja vu is a state s such that f^n(s) = s for some n > 0 \u2014 a periodic point of the cognitive dynamical system. Conjecture: By Sharkovsky's theorem, the existence of a period-3 orbit in the cognitive dynamics (three distinct states that cycle) implies chaos in the sense of Li-Yorke, meaning there exist uncountably many cognitive trajectories that are neither periodic nor convergent. Moreover, the set of deja vu states (periodic points of f) is dense in the cognitive state space S if f is continuous and S is an interval. The frequency of deja vu (occurring in ~70% of people) corresponds to the natural density of periodic points in a typical chaotic map. Test: model cognitive dynamics as a logistic map f(x) = rx(1-x) on [0,1] with parameter r chosen to match empirical deja vu frequencies. For r = 3.83 (period-3 window), compute the density of periodic points and compare to the 70% lifetime incidence. Impact: deja vu is not a glitch \u2014 it's a mathematical inevitability of continuous cognitive dynamics. Any continuous cognitive map with a period-3 orbit MUST have deja vu.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "id": "fd_0174",
    "priority_score": 0.78,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-17T03:25:44.358073+00:00",
    "title": "The Mathematics of Deja Vu: Fixed Points in Consciousness and Cognition"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Mendeleev organized 63 elements into a periodic table that predicted undiscovered elements. Can we do the same for finite groups? Classify all finite groups of order <= 2000 (there are approximately 10^15 of them, so we need a structural organization). Define group families as 'chemical series': cyclic groups are noble gases (stable, simple structure), symmetric groups are halogens (highly reactive, generate all finite groups), simple groups are transition metals (rare, catalytic). Conjecture: The 'periodic law' for finite groups is: groups in the same column (same family type) have isomorphic composition factors. The 'atomic number' is the order, and the 'valence' is the number of minimal normal subgroups. Groups with the same composition factors but different orders are 'isotopes' \u2014 they share chemical properties (solubility = solvability, reactivity = generation capacity). Test: construct a periodic table of groups of order <= 100, organizing them by composition factors. Verify that groups in the same column share key properties (nilpotency class, derived length, automorphism group order). Predict the properties of undiscovered groups (e.g., order 120, composition factors {2,2,2,3,5}) before looking them up. Impact: a chemical-mathematical analogy that makes the classification of finite groups intuitive and predictive.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0226",
    "priority_score": 0.77,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-07-17T13:45:24.979737+00:00",
    "title": "The Periodic Table of Finite Groups: Chemistry Meets Algebra"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future directions\n\nThis development formalizes the finite coordinate core of Curtin's *Generalizations of nets and Latin squares* (arXiv:2607.10890v1): column- and row-Latin matrices, orthogonality, cooperative pairs and systems, coordinate reticulations, svelte arrays, unique cross-line intersections, the grid-coordinate characterizations of Lemma 7.5, and the `m*n` cardinality consequence of Theorem 3.1.\n\nNatural next steps are:\n\n1. **Partition-level incidence structures.** Connect the coordinate-fibre representation here to a literal structure whose lines are finite sets and whose families are `Set.PairwiseDisjoint` covers. Prove both representations equivalent, including all seven clauses of Theorem 3.1.\n2. **Full inverse correspondence.** Package the maps between ordered reticulations, svelte semi-orthogonal arrays, and normalized cooperative systems as equivalences, proving Theorems 6.2, 6.3, 7.7, and 7.8 at structure level rather than only the forward encodings established here.\n3. **Multiplicity and foundations.** Model multisets of line families, then formalize repetition-free reticulations and Proposition 4.1.\n4. **Parastrophy and isotopy.** Define the permutation actions from Sections 9 and 10 and prove that they preserve the cooperative and reticulation axioms.\n5. **Constructions.** Formalize prolongation, splicing, and direct products from Sections 12\u201314, with formulas for their parameters.\n6. **Classical specializations.** Build translations from nets, mixed orthogonal arrays, mutually orthogonal Latin squares, and bireversible Mealy automata, recovering Propositions 3.6 and 6.6 and Theorem 7.3.\n7. **Finite search.** Add executable enumeration of small repetition-free systems up to isotopy, together with kernel-checked certificates for any reported counts.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0222",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "8b90ccda",
    "status": "available",
    "timestamp": "2026-07-17T13:12:10.340274+00:00",
    "title": "This development formalizes the finite coordinate core of Curtin's *Generalizati"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Minimal Modularity Lifting for Genus Two\n\n## 1. Integral stable-Yoshida modularity lifting\n\nLet a four-dimensional residual symplectic representation arise by automorphic induction from a nearly ordinary Hilbert modular eigencuspform over a real quadratic field. Under minimal ramification and the standard residual irreducibility and regularity conditions, the universal minimal ordinary deformation ring should be isomorphic, integrally and not merely after inverting the residue characteristic, to the localized genus-two ordinary Hecke algebra.\n\n**The key insight is...** the stable Yoshida description should turn the residual four-dimensional problem into a controlled two-dimensional deformation problem while preserving the symplectic polarization needed on the Siegel side.\n\n**Why now?** The algebraic consequences of such an isomorphism\u2014transport of points, uniqueness, and freeness\u2014can be treated uniformly, so the remaining task is sharply localized in the arithmetic construction and patching argument.\n\n## 2. Two-variable finite-flat strengthening\n\nIn the stable-Yoshida minimal setting, the universal ordinary deformation ring should be finite flat, and generically \u00e9tale, over the two-variable Iwasawa weight algebra; moreover, its rank should equal the multiplicity of the corresponding ordinary Hecke component.\n\n**The key insight is...** freeness should reflect a constant arithmetic multiplicity across weight space, while generic \u00e9taleness should follow from the vanishing of the relevant adjoint Selmer obstruction at a Zariski-dense set of classical points.\n\n**Why now?** Freeness is already naturally transported by the `R = T` identification, leaving rank and ramification as concrete invariants that can falsify or refine the conjecture.\n\n## 3. Rigidity beyond very regular weights\n\nUniqueness of an ordinary Hida family through a stable-Yoshida genus-two eigenform should continue to hold at all noncritical cohomological weights, with failure occurring precisely on an explicitly describable congruence or endoscopic locus.\n\n**The key insight is...** uniqueness is fundamentally a statement about the local degree and reducedness of the weight map, rather than about a particular numerical regularity bound.\n\n**Why now?** The abstract uniqueness mechanism identifies surjectivity and local ring structure as the decisive inputs, suggesting a direct investigation of the exact boundary where regularity can be weakened.\n\n## 4. Companion-family stratification\n\nWhen uniqueness fails at a critical or congruence point, the number of ordinary genus-two families through that point should be governed by the dimension of an ordinary adjoint Selmer group, with tangent directions partitioned according to refinements of the local crystalline representation.\n\n**The key insight is...** distinct families agreeing at one classical eigensystem should be detected infinitesimally by the kernel of the tangent map from the deformation space to weight space.\n\n**Why now?** The uniqueness theorem has a precise algebraic failure mode\u2014loss of effective surjective control\u2014so tangent-space calculations offer a falsifiable explanation for every additional branch.\n\n## 5. Higher-degree Yoshida-type induction\n\nFor suitable totally real extensions and polarized nearly ordinary Hilbert modular forms, automorphic induction should yield analogous minimal modularity lifting theorems for higher-genus symplectic groups, with one Iwasawa variable for each independent ordinary weight direction.\n\n**The key insight is...** the transport consequences of `R = T` are independent of genus; only the construction of the comparison map, local deformation conditions, and automorphy input change.\n\n**Why now?** The separation of formal commutative algebra from arithmetic hypotheses provides a stable template against which higher-rank proposals can be tested without conflating universal consequences with genus-specific arguments.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0224",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d1663b23",
    "status": "available",
    "timestamp": "2026-07-17T13:29:11.392766+00:00",
    "title": "Let a four-dimensional residual symplectic representation arise by automorphic i"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Quantum Surreal Observation\n\n## 1. Finite-dimensional non-Archimedean spectral calculus\n\n**Conjecture.** Let an ordered non-Archimedean real-closed field carry a standard-part map on its finite elements, and let its quadratic extension play the role of complex scalars. Every self-adjoint matrix whose entries and eigenvalues are finite admits an orthogonal spectral decomposition, and taking standard parts intertwines this decomposition with the ordinary real or complex spectral decomposition whenever distinct eigenvalue clusters remain appreciably separated.\n\nThe key insight is that appreciable spectral gaps should prevent infinitesimal perturbations from merging eigenspaces under standard part.\n\n**Why now?** Finite Born normalization and infinitesimal branch collapse isolate exactly the algebraic and boundedness hypotheses needed to test this claim first for two-by-two matrices, before introducing infinite-dimensional completeness.\n\n## 2. Support equivalence under Maslov dequantization\n\n**Conjecture.** For every finite hyperreal probability vector with finite logarithmic rates, the support surviving standard-part observation equals the zero-level argmax set of its Maslov-dequantized tropical weights, after normalization by the largest rate.\n\nThe key insight is that standard part detects appreciable scale, while tropicalization records the leading asymptotic scale; both should select precisely those coordinates that are not exponentially suppressed.\n\n**Why now?** The reservoir theorem proves this equivalence for a Dirac-shaped penalty model and identifies the observable-dependent dominance condition that a general formulation must preserve.\n\n## 3. Quantitative stability threshold for tropical and additive observations\n\n**Conjecture.** Given a finite infinitesimal probability model and a tropical penalty vector, there is a sharp oscillation threshold for observables below which ordinary standard-part expectation and tropical maximization select the same exposed face of the outcome simplex. Beyond that threshold, every disagreement pattern compatible with the supports can occur.\n\nThe key insight is that the inequality `f(i) + M_i \u2264 f(r)` is not merely sufficient: its boundary should form the normal fan separating stable support agreement from visible-outcome escape.\n\n**Why now?** The finite reservoir bridge supplies one complete cone of this fan and shows explicitly why unconditional agreement is false.\n\n## 4. Standard-part projection-valued measures\n\n**Conjecture.** A finite hyperreal projection-valued measure with finite matrix entries descends under entrywise standard part to an ordinary projection-valued measure if and only if its projections are pairwise orthogonal up to infinitesimal operator norm and its total projection is infinitesimally close to the identity.\n\nThe key insight is that polynomial identities defining projections and orthogonality should survive standard part, while approximate hypotheses capture the natural measurement errors of non-Archimedean states.\n\n**Why now?** Scalar standard-part normalization and support collapse are established; the next falsifiable step is to determine exactly which matrix identities survive observation.\n\n## 5. Infinite-dimensional boundary of the spectral conjecture\n\n**Conjecture.** On a spherically complete non-Archimedean Hilbert space, every compact self-adjoint operator with appreciably separated nonzero spectrum has an orthogonal eigen-expansion whose standard part agrees with the spectral expansion of the descended compact operator; without spherical completeness, a counterexample exists.\n\nThe key insight is that the obstruction is expected to lie in completeness and convergence, not in the finite algebraic spectral identities.\n\n**Why now?** Separating the finite matrix theorem from this completeness-sensitive extension turns the broad spectral claim into two independently testable stages and supplies a precise failure mode to seek.\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0225",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "dcd7a4b2",
    "status": "available",
    "timestamp": "2026-07-17T13:29:19.802752+00:00",
    "title": "**Conjecture.** Let an ordered non-Archimedean real-closed field carry a standar"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n## 1. Certified finite-prefix null tests for \u03c0, e, and \u221a2\n\nFix a prefix length in advance and compare centered decimal-digit autocorrelations at lags 1\u201312 against the exact permutation distribution, with family-wise error controlled across constants and lags. The conjecture is that none of the three advertised preferred lags remains significant after correction at prefix lengths 10\u00b3, 10\u2074, and 10\u2075.\n\nThe key insight is that an exact finite-sample null distribution separates reproducible digit evidence from interpretations based only on irrationality. Why now? The deterministic energy identity identifies the precise statistic to test and exposes every convention that must be fixed before significance has a meaning.\n\n## 2. Temporal-lag and pitch-interval separation\n\nDefine a pitch-interval histogram counting pairs whose digit values differ by a prescribed number of semitones, independently of their temporal separation. Under the stated ten-note chromatic map, the conjecture is that octave counts are identically zero, while any temporal lag-12 effect is unrelated to octave incidence.\n\nThe key insight is that sequence position and pitch distance are orthogonal coordinates and should never share the word \u201clag.\u201d Why now? The present analysis shows that the original octave interpretation is structurally incompatible with a digit alphabet of width ten.\n\n## 3. Fourier-energy characterization of digit-melody repetition\n\nFor centered cyclic digit prefixes, the conjecture is that statistically exceptional autocorrelation peaks are equivalent to concentration of Fourier power on characters whose phases nearly stabilize the corresponding shift, with quantitative two-sided bounds uniform in prefix length.\n\nThe key insight is that Fourier inversion turns temporal repetition into spectral concentration, while polarization turns it into low interval energy. Why now? These two exact descriptions are now available in one framework, making a sharp stability theorem a concrete target.\n\n## 4. Continued fractions versus decimal consonance under controlled ensembles\n\nCompare numbers sampled from bounded-partial-quotient Cantor sets with matched control samples, using a pre-registered consonance functional on decimal prefixes. The conjecture is that, after conditioning on prefix length and digit frequencies, bounded partial quotients do not produce a universal positive consonance bias.\n\nThe key insight is that continued-fraction digits and decimal digits arise from different dynamical codings; any bridge between them must be measured against a controlled ensemble rather than inferred from isolated constants. Why now? The failure of irrationality alone to constrain finite autocorrelation narrows the search to genuinely dynamical mechanisms.\n\n## 5. Prefix-prescription obstruction theorem\n\nFor every finite decimal word and every prescribed finite vector of lag correlations compatible with that word, construct both a transcendental real and a quadratic irrational sharing the word whenever the algebraic class permits the same prefix. The conjecture is that no statistic depending on a fixed finite prefix can distinguish transcendence from algebraicity with certainty.\n\nThe key insight is that finite musical data constrain an interval of real numbers, not the arithmetic nature of an individual tail. Why now? This obstruction would give a rigorous boundary for all attempts to infer deep arithmetic properties from finite sonifications.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_0228",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "87b73bf0",
    "status": "available",
    "timestamp": "2026-07-17T13:45:46.320270+00:00",
    "title": "Fix a prefix length in advance and compare centered decimal-digit autocorrelatio"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future directions\n\n## What was established\n\nThe formal development proves a general finite-tag amplification theorem. Relative to an abstract provability predicate, one dark existential predicate yields dark predicates with 1, 2, 3, and in fact every positive finite number of distinct tagged witnesses. The tagged coding is proved to enumerate every tag over every originally named object. It also proves that any named witness-extraction principle rules darkness out.\n\nThis gives a concrete obstruction to the proposed strict hierarchy: witness count alone is not an invariant measure of proof-theoretic hardness. Irrelevant finite tags amplify the level without adding mathematical information.\n\n## Important correction to the mission framing\n\nParis\u2013Harrington and Kirby\u2013Paris hydra independence do not by themselves instantiate the definition given in the prompt. Their usual statements are universal termination/finite combinatorics claims independent of PA, whereas the proposed definition requires PA to prove an existential while proving no numeral instance. An explicit PA example therefore needs a carefully fixed arithmetization of syntax, a naming map, and a nonstandard or intensional predicate; it cannot be inferred merely by citing those independence theorems.\n\nLikewise, \u201cdense in the space of Pi_2 statements\u201d is undefined until a topology or asymptotic density on formula codes is selected. Raw counting of formulas is coding-dependent: harmless syntactic padding can arbitrarily change frequencies. Any meaningful density theorem should first prove robustness under acceptable changes of G\u00f6del numbering.\n\n## Next formal targets\n\n1. Instantiate `Prov` with a concrete arithmetized first-order proof calculus for PA and prove `SupportsFiniteTagging` by primitive-recursive transformations of proof codes.\n2. Investigate whether a genuine dark predicate exists under the exact external reading of `PA \u22ac T(n)`. Compare this with the numerical existence property and witness properties of fragments such as HA and constructive arithmetic.\n3. Define an equivalence relation identifying predicates that differ only by finite tags or primitive-recursive bijections, then seek a hierarchy on equivalence classes.\n4. Replace raw formula counting by a specified measure (for example, prefix-free program probability or bounded-length density under a fixed grammar) and prove which conclusions survive recoding.\n5. Formalize the distinction between:\n   - PA proving an existential with no PA-provable numeral instance;\n   - a true existential whose instances are undecidable;\n   - a universal Pi_2 principle independent of PA.\n6. Test candidate examples from nonstandard models, Rosser-style constructions, and recursively inseparable sets. Every candidate must include a proof that PA proves the existential and a metatheorem excluding every standard named instance.\n",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_0230",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "186c9eac",
    "status": "available",
    "timestamp": "2026-07-17T14:02:57.130034+00:00",
    "title": "The formal development proves a general finite-tag amplification theorem. Relati"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle d1663b23 (Q=0.700) proved 0 theorems in Applications but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Investigate the ArXiv paper 'A minimal modularity lifting theorem for Siegel modular forms' and formalize its key results. Abstract: We prove a minimal modularity lifting theorem (in the spirit of Gen",
    "domains": [
      "Applications"
    ],
    "id": "sorry_fill_d1663b23_44cb6a25",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d1663b23",
    "status": "available",
    "timestamp": "2026-07-17T13:29:16.297936+00:00",
    "title": "Close Proofs: ArXiv paper: A minimal modularity lifting theorem for Siegel modular f"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle 186c9eac (Q=0.680) proved 0 theorems in Shared but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: There are mathematical objects whose existence we can prove but whose specific properties are unknowable \u2014 theorems that cast shadows without being visible. Define a dark theorem as a statement T such",
    "domains": [
      "Shared"
    ],
    "id": "sorry_fill_186c9eac_94eac87b",
    "priority_score": 0.7300000000000001,
    "research_mode": "team",
    "source_exp_id": "186c9eac",
    "status": "available",
    "timestamp": "2026-07-17T14:03:03.735341+00:00",
    "title": "Close Proofs: Dark Mathematics: Theorems That Exist But Cannot Be Found"
  },
  {
    "consumed_by_exp_id": "58ca9013",
    "description": "The Fibonacci sequence is defined by F(n+1) = F(n) + F(n-1) and converges to the golden ratio. Define the ANTI-Fibonacci sequence: A(n+1) is the smallest positive integer that is NOT equal to A(n) + A(n-1). The sequence begins 1, 1, 2, 4, 7, 11, 16, ... (each term avoids being the sum of the two previous terms). Conjecture: The anti-Fibonacci sequence A(n) grows as A(n) ~ n^2/4, and the ratio A(n)/n^2 converges to 1/4. More precisely, A(n) = floor(n^2/4) + O(1). The sequence avoids the golden ratio entirely \u2014 the ratio A(n+1)/A(n) does NOT converge, instead oscillating between 1 and 2. The complement of the anti-Fibonacci sequence (numbers that ARE sums of two previous anti-Fibonacci numbers) has density 0. Test: compute A(n) for n up to 10^6 and verify A(n)/n^2 approaches 1/4. Prove A(n) = floor(n^2/4) + O(1) by induction. Impact: a beautiful counterpoint to the Fibonacci sequence \u2014 instead of converging to a constant, it grows quadratically while systematically avoiding addition.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0172",
    "priority_score": 0.73,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-17T03:25:44.329567+00:00",
    "title": "The Anti-Fibonacci Sequence: Numbers That Avoid the Golden Ratio at All Costs"
  },
  {
    "consumed_by_exp_id": "9f14a31b",
    "description": "Every real number defines a musical scale: map the digits 0-9 to frequencies f_n = 220 * 2^{n/12} (the A minor pentatonic scale extended). The number pi = 3.14159265... produces the sequence E4, C5, C#5, D5, D#5, F5, E5, A4, G5, C5... \u2014 a melody. Conjecture: The melody of pi is not periodic (because pi is irrational) but has musical structure: the autocorrelation of the digit sequence at lag 12 (one octave) is positive and statistically significant. This means pi has more octave-related notes than expected by chance \u2014 pi 'favors' notes separated by octaves. Similarly, e 'favors' perfect fifths (lag 7) and sqrt(2) 'favors' minor thirds (lag 3). The musical structure of transcendental numbers reflects their continued fraction properties: numbers with bounded partial quotients have more consonant melodies. Test: compute the digit autocorrelation of pi, e, and sqrt(2) at lags 0-12 (representing unison through octave). Perform a chi-squared test comparing to the uniform distribution. Generate the 'music' of each constant and analyze for tonal centers. Impact: transcendental numbers have musical souls \u2014 their digit sequences contain hidden harmonies that reflect their deepest arithmetic properties.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "id": "fd_0229",
    "priority_score": 0.72,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-07-17T14:02:27.283106+00:00",
    "title": "The Sound of Pi: Musical Structure in Transcendental Constants"
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
