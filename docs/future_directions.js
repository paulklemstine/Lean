

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that proof checking is fundamentally different from proof search. Conjecture: There exists a proof system in which every true quantifier-free formula has a proof of polynomial size, and this proof can be verified in polynomial time. The barrier has been that existing proof systems (Frege, Extended Frege) have exponential lower bounds for specific formulas. But what if we construct a NEW proof system based on EML computations? Define EML-Frege where each proof step is an EML identity (exp-log composition) verified by numeric evaluation. Since EML identities can be checked in O(1) field operations, and every boolean circuit can be simulated by an EML network of depth O(log n), we get a quasi-polynomial proof system. Why now: recent breakthroughs in circuit lower bounds (Williams 2014, 2023) and the EML single-operator universality result suggest that EML-Frege could break the natural proofs barrier. Test: prove that EML-Frege polynomially simulates Extended Frege for CNF formulas, and show it has no exponential lower bounds under the EML independence assumption. Impact: if EML-Frege has short proofs for all tautologies, then NP = coNP in this proof system, which would be the most significant result in proof complexity since Cook's theorem.",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "fd_0496",
    "priority_score": 0.97,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.239855+00:00",
    "title": "Proof Complexity Collapse: P=NP via Proof Checking"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove or disprove that P = NP. Formalize known barriers: relativization, natural proofs, algebrization. Explore circuit complexity lower bounds, proof complexity, and connections to cryptographic hardness assumptions.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "seed_005",
    "priority_score": 0.96,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:56.858305+00:00",
    "title": "P vs NP Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that persistent homology \u2014 the backbone of topological data analysis \u2014 provides a natural framework for quantum error correction. Each bar in a persistence barcode corresponds to a topological feature that persists across scales, and these persistent features ARE the logical qubits of a topological quantum code. Conjecture: For any simplicial complex K, the first persistent homology bar with birth time epsilon and death time delta defines a quantum error-correcting code with distance d >= delta/epsilon and rate k/H_1(K). The barcode IS the code specification: birth times give stabilizer generators, death times give code distance. Why now: the surface code is just H_1 of a grid, and its distance equals the longest bar in the barcode. This generalizes immediately. Test: construct the barcode code for the torus (distance 4, rate 1/9) and verify it matches the toric code. Prove the distance bound for arbitrary complexes. Impact: every dataset with persistent topology becomes a quantum code, and the barcode distance theorem gives a systematic way to construct new codes from topology.",
    "domains": [
      "Physics",
      "Geometry"
    ],
    "id": "fd_0426",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.392825+00:00",
    "title": "Topological Quantum Error Correction from Homological Persistence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that every even integer greater than 2 is the sum of two primes. Formalize partial results such as Vinogradov's theorem for sufficiently large odd integers, or Chen's theorem that every sufficiently large even number is the sum of a prime and a semiprime. Explore connections to sieve methods and the circle method.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_001",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:55.985938+00:00",
    "title": "Goldbach Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that all non-trivial zeros of the Riemann zeta function lie on Re(s)=1/2. Formalize equivalent statements: the prime counting function error bound, the Mertens conjecture connection, or the spectral interpretation via random matrix theory. Explore connections to quantum chaos and the Hilbert-Polya conjecture.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_002",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:56.183350+00:00",
    "title": "Riemann Hypothesis"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The 3D Poincar\u00e9 conjecture is proven, but the smooth 4D version remains open: does every smooth 4-manifold homotopy equivalent to S\u2074 necessarily diffeomorphic to S\u2074? Formalize Donaldson's invariants, Seiberg-Witten theory, and explore exotic smooth structures on 4-manifolds.",
    "domains": [
      "Geometry"
    ],
    "id": "seed_202",
    "priority_score": 0.95,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:07.882559+00:00",
    "title": "Poincar\u00e9 Conjecture Revisited: 4D Smooth"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that every Hodge class on a non-singular projective algebraic variety is a rational linear combination of classes of algebraic cycles. Formalize the Hodge decomposition and explore the conjecture for specific varieties like abelian varieties and K3 surfaces.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_014",
    "priority_score": 0.94,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:58.943631+00:00",
    "title": "Hodge Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the rank of an elliptic curve equals the order of vanishing of its L-function at s=1. Formalize the BSD formula including the regulator, Tate-Shafarevich group, and Tamagawa numbers.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_017",
    "priority_score": 0.94,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:59.227937+00:00",
    "title": "Birch and Swinnerton-Dyer Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Razborov-Rudich natural proofs barrier: circuit lower bound proofs using 'natural' properties cannot separate P from NP unless pseudorandom generators don't exist. Explore algebrization.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "seed_231",
    "priority_score": 0.94,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:16.980012+00:00",
    "title": "Natural Proofs Barrier: Formalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that Boltzmann entropy S = k log W is a topological invariant of the energy landscape. If the energy function E: X -> R on a state space X defines a filtration by sublevel sets X_t = {x : E(x) <= t}, then the persistent homology barcode of this filtration encodes the entropy as the sum of bar lengths: S(E) = k * sum_i (d_i - b_i) where b_i and d_i are birth and death times of persistent homology bars. Conjecture: The Boltzmann entropy of a physical system equals the total persistence (sum of bar lengths) of the energy landscape filtration, up to an additive constant. Why now: persistent homology has matured as a computational tool, and the stability theorem guarantees that small perturbations in the energy function produce small changes in the barcode \u2014 exactly the thermodynamic stability we expect. Test: compute the persistent homology barcode for the Ising model energy landscape on a 4x4 lattice and verify that sum of bar lengths equals k log(2^{16}) = 16k log 2. Impact: entropy becomes a computable topological quantity, bridging thermodynamics and algebraic topology. Phase transitions correspond to births of new bars in the barcode.",
    "domains": [
      "Physics",
      "Geometry"
    ],
    "id": "fd_0430",
    "priority_score": 0.93,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.738839+00:00",
    "title": "Entropy as a Topological Invariant: The Boltzmann Bridge"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that there are infinitely many pairs of primes differing by 2. Formalize Zhang's bounded gaps result and Maynard-Tao improvements. Explore connections to the Hardy-Littlewood conjecture and sieve theory.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_004",
    "priority_score": 0.93,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:56.613461+00:00",
    "title": "Twin Prime Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that a positive proportion of zeros of the Riemann zeta function lie on the critical line. Formalize Selberg's result (positive proportion on), Conrey's 2/5 result, and explore connections to random matrix theory and the moment problem.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_203",
    "priority_score": 0.93,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:08.078431+00:00",
    "title": "Riemann Hypothesis: Zero-Free Regions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Design and prove correct a novelty certification system that formally verifies each research output contains genuinely new mathematics. Construct a theorem embedding space where distance bounds novelty.",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "fd_0408",
    "priority_score": 0.92,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.938639+00:00",
    "title": "Certified Novelty Detection for Theorem Provers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that Godel's incompleteness arises because a formal system cannot prove statements about itself \u2014 but a TYPE SYSTEM can. Construct a dependent type theory where types can refer to their own terms, creating a system where proofs can modify the specifications they are proving. Conjecture: There exists a consistent type theory T in which the type Type : Type is stratified by a self-reference level, and T can prove its own consistency within each level. The stratification prevents the paradox: Type_n : Type_{n+1} allows self-reference at level n without contradiction at level n+1. Why now: homotopy type theory has shown that types can be spaces, and the univalence axiom provides a principled way to equate equivalent types. Self-referential types are the natural next step. Test: formalize a type theory where terms can modify type specifications, prove that it is consistent by constructing a model in the category of globular sets, and show that Godel's incompleteness theorem does not apply because the stratification prevents diagonalization. Impact: a new foundation for mathematics where proofs can evolve their own specifications, enabling self-improving formal systems.",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_0497",
    "priority_score": 0.92,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.318994+00:00",
    "title": "Self-Referential Type Theory: Proofs That Modify Their Own Specifications"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the rank of an elliptic curve over Q is computable. Formalize the Mordell-Weil theorem, height pairings, and descent algorithms. Connect to the conjecture that ranks are bounded and explore the parity conjecture.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_204",
    "priority_score": 0.92,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:08.281573+00:00",
    "title": "BSD Conjecture: Rank Computability"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove or disprove: for every \u03b5 > 0, there exists k such that distinguishing value \u2265 1-\u03b5 from value \u2264 \u03b5 for unique 2-prover games with k labels is NP-hard. Connect to MAX-CUT and SDP gaps.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "seed_232",
    "priority_score": 0.92,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:17.201558+00:00",
    "title": "Unique Games Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize a research system as a dependent type where the type of the next cycle depends on outcomes of previous cycles. Prove that reflective self-improvement converges.",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "seed_056",
    "priority_score": 0.91,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:04.360894+00:00",
    "title": "Self-Modifying Research via Reflective Type Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that every directed graph G has a zeta function zeta_G(s) = prod(1 - lambda^{-s})^{-1} where the product is over eigenvalues of the graph's adjacency matrix, and the Riemann Hypothesis for this function is equivalent to a purely combinatorial condition on G. Conjecture: For a directed graph G with n vertices, zeta_G(s) satisfies the Riemann Hypothesis (all non-trivial zeros lie on Re(s) = 1/2) if and only if G is a Ramanujan digraph: every eigenvalue lambda of the adjacency matrix satisfies |lambda| <= 2 sqrt(d-1) where d is the maximum out-degree. This is the directed graph analog of the Ramanujan graph theorem of Lubotzky-Phillips-Sarnak. Why now: the undirected case is settled (Ramanujan graphs exist and have optimal spectral gap), but the directed case is wide open. Recent work by Lubetzky and Peres (2016) on cutoff on directed Ramanujan graphs suggests the spectral gap characterization extends. Test: prove the conjecture for directed Cayley graphs of finite groups, then verify computationally for random directed d-regular graphs with n=20, 50, 100 vertices. Impact: a combinatorial Riemann Hypothesis \u2014 if true, it means the deepest mystery of number theory has a purely graph-theoretic characterization.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_104",
    "priority_score": 0.91,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:07.527822+00:00",
    "title": "Zeta Functions of Directed Graphs and the Graph Riemann Hypothesis"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove Grothendieck's standard conjectures: numerical and homological equivalence coincide, K\u00fcnneth projectors are algebraic, and independence of l. Connect to the Hodge conjecture and motives.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_221",
    "priority_score": 0.91,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:11.683325+00:00",
    "title": "Standard Conjectures on Algebraic Cycles"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the Whitehead problem (every Whitehead group is free) is independent of ZFC. Formalize Shelah's undecidability proof: consistent both ways.",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "seed_233",
    "priority_score": 0.91,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:17.429886+00:00",
    "title": "Whitehead Problem: Independence from ZFC"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that protein folding minimizes a topological energy: the persistent homology barcode of the protein's contact map. The native fold of a protein is the configuration that minimizes the total persistence of the contact filtration. Conjecture: The native state of a protein P minimizes sum_i (d_i - b_i) over all possible 3D configurations, where {b_i, d_i} is the persistent homology barcode of the distance matrix of P's C-alpha atoms. Why now: AlphaFold2 showed that contact maps are sufficient for structure prediction, but it used deep learning without understanding WHY contact maps work. Persistent homology provides the mathematical reason: the barcode captures the topological constraints (no self-intersection, hydrophobic core, etc.) that determine the fold. Test: compute the barcode for 100 proteins from the PDB and verify that the native fold has lower total persistence than 1000 random decoy folds for each protein. Impact: protein folding becomes a topological optimization problem with a provably unique minimum, explaining why folding is fast and reliable despite Levinthal's paradox.",
    "domains": [
      "Physics",
      "Geometry"
    ],
    "id": "fd_0432",
    "priority_score": 0.9,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.909349+00:00",
    "title": "Biological Topology: Protein Folding as Persistent Homology Optimization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the information paradox as a theorem about unitary evolution: prove that if black hole evaporation is unitary, information is preserved; if not, quantum mechanics is violated. Construct a toy model where a 2-qubit black hole evaporates unitarily and recover the initial state from radiation.",
    "domains": [
      "Physics",
      "Logic"
    ],
    "id": "fd_0463",
    "priority_score": 0.9,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.401337+00:00",
    "title": "Hawking Radiation: Information Paradox Formalized"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the ABC conjecture and its implications in Lean 4. Prove consequences: Fermat's Last Theorem for large exponents, Roth's theorem strengthening, Mordell conjecture. Explore Mochizuki's claimed proof structure.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_029",
    "priority_score": 0.9,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:01.580148+00:00",
    "title": "ABC Conjecture Formalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that every loopless graph requiring k+1 colors for a proper coloring contains K_{k+1} as a minor. Formalize known cases (k \u2264 5), the Wagner equivalence, and the connection to the Four Color Theorem.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "seed_211",
    "priority_score": 0.9,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:09.676882+00:00",
    "title": "Hadwiger's Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the Baum-Connes conjecture relating K-theory of reduced C*-algebras to equivariant K-homology. Formalize known cases and the connection to Novikov.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "seed_224",
    "priority_score": 0.9,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:12.343420+00:00",
    "title": "Baum-Connes Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that any quantum circuit can be approximated by braiding anyons. Formalize the Jones polynomial as a universal topological quantum invariant and prove density in SU(2).",
    "domains": [
      "Bridges",
      "Physics"
    ],
    "id": "fd_0444",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.878854+00:00",
    "title": "Topological Quantum Computing: Braiding Universality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that any integer a \u2260 -1,\u25a1 that is not a perfect square is a primitive root modulo infinitely many primes. Formalize the Hooley conditional proof under GRH and explore unconditional density results.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_210",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:09.481636+00:00",
    "title": "Artin's Conjecture on Primitive Roots"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove Hironaka's resolution of singularities theorem for varieties in characteristic p > 0. Formalize known results for dimensions \u2264 3.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_222",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:11.907572+00:00",
    "title": "Resolution of Singularities in Positive Characteristic"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the consistency strength hierarchy: inaccessible < Mahlo < measurable < strong < supercompact < huge. Prove strictness results.",
    "domains": [
      "Logic",
      "Novelty"
    ],
    "id": "seed_234",
    "priority_score": 0.89,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:17.622192+00:00",
    "title": "Large Cardinal Hierarchy: Consistency Strength"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that a Hadamard matrix exists for every positive multiple of 4. Formalize known constructions (Sylvester, Paley, tensor products) and establish bounds on the smallest open order. Connect to combinatorial designs, error-correcting codes, and signal processing.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_003",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:56.393667+00:00",
    "title": "Hadamard Matrix Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that no odd perfect numbers exist. Formalize known constraints: must exceed 10^1500, have at least 101 prime factors, satisfy Euler's form p^a * m^2. Connect to the structure of multiplicative functions.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_013",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:58.688448+00:00",
    "title": "Odd Perfect Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Construct a number system on the Mobius band where the integers wrap with a twist: n and -n are identified with opposite orientations. Define the Mobius integers Z_tilde as Z x {+1, -1} modulo the identification (n, +1) ~ (-n, -1). Develop arithmetic on Z_tilde where addition wraps through the identification. Conjecture: The ring Z_tilde of Mobius integers has class number 1, and its prime spectrum forms a double cover of the ordinary primes (each ordinary prime p splits into two oriented primes p_plus and p_minus). The Mobius zeta function zeta_tilde(s) has zeros off the critical line, which is expected since Z_tilde is a non-Ore ring. Test: factor 6 in Z_tilde as 2_plus times 3_plus and 2_minus times 3_minus and verify these are distinct factorizations. Prove unique factorization for Z_tilde up to orientation. Impact: a new algebraic number system with intrinsic orientation, connecting number theory to topology via the double cover Z to Z_tilde.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_080",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:05.665381+00:00",
    "title": "Mobius Arithmetic: Number Theory on the Mobius Band"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Mihailescu proved that 8 and 9 are the only consecutive perfect powers. Generalize: find all solutions to x^a - y^b = k for fixed small k. Formalize the theory of exponential Diophantine equations and Pillai's conjecture.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_205",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:08.480584+00:00",
    "title": "Catalan's Conjecture Generalizations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Yau-Tian-Donaldson conjecture: a Fano manifold admits a K\u00e4hler-Einstein metric iff it is K-stable. Prove stability criteria for specific Fano varieties.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_239",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:18.648941+00:00",
    "title": "K\u00e4hler-Einstein Metrics and K-Stability"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the stability theorem for persistent homology: the bottleneck distance between persistence diagrams is bounded by the Gromov-Hausdorff distance between the underlying spaces. Formalize the persistent homology pipeline and verify on concrete point cloud data.",
    "domains": [
      "Computation",
      "Geometry"
    ],
    "id": "seed_322",
    "priority_score": 0.88,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:20.401327+00:00",
    "title": "Topological Data Analysis: Persistent Homology Stability"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that Novikov's self-consistency principle follows from the Banach fixed-point theorem applied to the causal structure of spacetime. Formalize time-travel paradoxes as boundary value problems and prove existence of self-consistent solutions for polynomial causal maps.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "id": "fd_0114",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.944657+00:00",
    "title": "Time Travel Consistency: Novikov's Principle as a Fixed-Point Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for every positive integer n, there exists a prime between n\u00b2 and (n+1)\u00b2. Formalize known partial results on prime gaps and connect to the Cram\u00e9r model of primes.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_024",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:00.735432+00:00",
    "title": "Legendre's Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that higher signatures are homotopy invariants for all finitely presented groups. Formalize the assembly map in topological K-theory and connections to Baum-Connes.",
    "domains": [
      "Geometry"
    ],
    "id": "seed_223",
    "priority_score": 0.87,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:12.120491+00:00",
    "title": "Novikov Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the ground state degeneracy of a topologically ordered system on a genus-g surface is d^g for some integer d (the quantum dimension). Formalize the connection between ground state degeneracy, anyon braiding statistics, and topological quantum field theory.",
    "domains": [
      "Physics",
      "Geometry"
    ],
    "id": "fd_0464",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.485267+00:00",
    "title": "Topological Order: Anyon Statistics from Ground State Degeneracy"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the Fisher information metric defines a Riemannian metric on the statistical manifold of probability distributions. Show that the Kullback-Leibler divergence is the geodesic distance in this metric for exponential families. Bridge: the Chentsov theorem characterizes the Fisher metric uniquely by its invariance under sufficient statistics.",
    "domains": [
      "Bridges",
      "Physics"
    ],
    "id": "fd_0530",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.130772+00:00",
    "title": "Bridge: Information Geometry Connecting Statistics and Differential Geometry"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the definition of zero-knowledge proofs (interactive and non-interactive). Prove that graph 3-colorability has a zero-knowledge proof. Implement a simplified zk-SNARK circuit in Lean 4 and prove soundness. Bridge: connect to the PCP theorem (NP \u2286 PCP(poly, 1)).",
    "domains": [
      "Cryptography",
      "Logic"
    ],
    "id": "fd_0539",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.880463+00:00",
    "title": "Zero-Knowledge Proofs in Lean: Verifiable Computation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that there are infinitely many primes of the form n\u00b2+1. Formalize Iwaniec's result on semi-primes of this form and connect to Friedlander-Iwaniec theorem on primes of form a\u00b2+b\u2074.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_025",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:00.953818+00:00",
    "title": "Primes of the Form n\u00b2+1"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize core HoTT results in Lean 4: the univalence axiom, higher inductive types, and the fundamental theorem of identity types. Prove that HoTT provides a constructive foundation for mathematics.",
    "domains": [
      "Logic",
      "Geometry"
    ],
    "id": "seed_040",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:03.446924+00:00",
    "title": "Homotopy Type Theory Foundations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Hausdorff dimension is normally a metric property, not a topological one. Investigate whether it can be made topological through the lens of fractal topology. Define the fractal topological dimension d_f(X) of a metric space X as the infimum of d such that X embeds in R^d with Hausdorff dimension preserved. Conjecture: For compact metric spaces, the Hausdorff dimension is a topological invariant modulo homeomorphisms that are bi-Lipschitz on a dense open set. More precisely, if X and Y are homeomorphic compact subsets of R^n, and the homeomorphism is bi-Lipschitz on a set of full Hausdorff dimension in X, then dim_H(X) = dim_H(Y). This would mean that fractal dimension is not just a metric accident but a topological invariant up to rough isometries. Test: compute d_f for the Sierpinski gasket (expected: 1 since connected, Hausdorff dimension log3/log2) and the Cantor set (expected: 0 since totally disconnected). Prove that the Koch curve and any bi-Lipschitz-equivalent curve have equal Hausdorff dimensions. Impact: elevates fractal dimension from a metric curiosity to a topological invariant, with applications to shape classification and topological data analysis.",
    "domains": [
      "Geometry"
    ],
    "id": "seed_082",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:05.913849+00:00",
    "title": "Fractal Topology: Hausdorff Dimension as a Topological Invariant"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that 78557 is the smallest Sierpi\u0144ski number. Formalize the theory of covering systems and their relationship to Chinese Remainder Theorem configurations.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "seed_208",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:09.067494+00:00",
    "title": "Sierpi\u0144ski Numbers: Covering Systems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the Yamabe problem on non-compact Riemannian manifolds: find a conformal metric of constant scalar curvature. Formalize the compact case and explore non-compact obstructions.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_237",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:18.225965+00:00",
    "title": "Yamabe Problem: Non-Compact Case"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Pearl's do-calculus as a formal logical system with three inference rules. Prove that do-calculus is complete for identifying causal effects in non-parametric structural equation models. Construct a decision procedure for causal effect identifiability.",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "seed_325",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:20.830849+00:00",
    "title": "Causal Inference: Do-Calculus as Formal Logic"
  },
  {
    "consumed_by_exp_id": "",
    "description": "What if the topology of a space depended on who is observing it? Define a phantom topology on a set X as a function T: O -> Top(X) that assigns to each observer o a topology T(o) on X. Two observers o1, o2 agree on an open set U if U is open in both T(o1) and T(o2). The phantom number of (X, T) is the minimum number of observers needed to determine the topology: if U is open in every T(o) that contains a point x, then U is a neighborhood of x in the 'real' topology. Conjecture: Every second-countable space (X, tau) admits a phantom representation with at most 2 observers (the real topology is the intersection of two phantom topologies). Moreover, every non-metrizable space requires at least 3 observers. The intuition: the real topology is what ALL observers agree on, and phantom topologies are what individual observers see. Like quantum mechanics, measurement changes the topology. Test: prove that R with the standard topology is the intersection of the lower limit topology and the upper limit topology (2 observers). Prove that the Zariski topology on R^2 requires at least 3 observers. Impact: a new notion of topology where the space itself depends on the observer \u2014 the mathematical formalization of 'reality depends on the observer'.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0005",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.491025+00:00",
    "title": "Phantom Topologies: Spaces That Change When You Look at Them"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize a 3D topological quantum field theory that captures key features of quantum gravity: prove that the partition function on a closed 3-manifold equals the Turaev-Viro invariant. Show that the Hilbert space on a surface is finite-dimensional and that the mapping class group acts unitarily.",
    "domains": [
      "Physics",
      "Geometry"
    ],
    "id": "fd_0505",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.905756+00:00",
    "title": "Quantum Gravity as Topological Quantum Field Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the tropicalization of a variety V over a non-Archimedean field is the limit of V as the valuation goes to infinity. Bridge: the tropical fundamental theorem states that the tropicalization of V equals the corner locus of the tropical polynomial. Show that tropical intersection numbers equal classical intersection numbers (tropical Bezout).",
    "domains": [
      "Bridges",
      "Tropical"
    ],
    "id": "fd_0536",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.637226+00:00",
    "title": "Bridge: Tropical Geometry as a Limit of Classical Algebraic Geometry"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Define tropical schemes as semiring schemes over the tropical semiring. Prove that the tropical scheme associated to a tropical polynomial is the corner locus. Show that the structure sheaf of a tropical scheme satisfies the tropical gluing axiom. Connect to the Grothendieck scheme-theoretic approach to tropical geometry.",
    "domains": [
      "Tropical",
      "Algebra"
    ],
    "id": "fd_0550",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.786215+00:00",
    "title": "Tropical Schemes: Foundations of Tropical Algebraic Geometry"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the 3n+1 iteration eventually reaches 1 for all positive integers. Formalize partial results on density of convergent integers, stopping times, and connections to ergodic theory and p-adic dynamics.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "seed_006",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:57.058856+00:00",
    "title": "Collatz Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Extend the Kronecker-Weber theorem to arbitrary algebraic fields by constructing Hilbert class fields. Formalize explicit class field theory and connect to the Langlands program.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_020",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:59.906325+00:00",
    "title": "Hilbert 12: Kronecker-Weber Generalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove Schanuel's conjecture: if z\u2081,...,z\u2099 are Q-linearly independent complex numbers, then the transcendence degree of {z\u2081,...,z\u2099,e^z\u2081,...,e^z\u2099} over Q is at least n. Formalize implications for the Lindemann-Weierstrass theorem.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_033",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:02.371575+00:00",
    "title": "Schanuel's Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Persistent homology computes topological features of data at multiple scales. On spheres, the natural metric is the geodesic (spherical) distance, but existing algorithms assume Euclidean data. Use stereographic projection to transform spherical persistence to weighted Euclidean persistence. Define the stereographic persistence module for a point cloud X on S^n: for each filtration parameter epsilon, compute the Cech complex C_epsilon(X) on S^n using the spherical metric, then apply inverse stereographic projection to get a filtered complex on R^n with a conformal weight. Conjecture: The persistence diagram of a point cloud on S^n computed with the geodesic metric is equal to the persistence diagram of the projected point cloud on R^n computed with a conformally weighted distance d_w(x,y) = 2*d(x,y)/(1+d(x,y)^2/4). This equality holds because stereographic projection is a conformal isometry up to the conformal factor, and persistence diagrams are invariant under conformal transformations. This gives an O(N log N) algorithm for spherical persistence (vs O(N^2) for direct computation). Test: implement both methods and verify isometry of persistence diagrams for random spherical point clouds with N=50, 100, 200 points. Impact: fast, provably correct topological data analysis for spherical data, with applications to astrophysics (cosmic microwave background) and protein structure analysis.",
    "domains": [
      "Geometry",
      "Computation"
    ],
    "id": "seed_092",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:06.670695+00:00",
    "title": "Inverse Stereographic Persistence: Topological Data Analysis on Spheres"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Resolve Kaplansky's conjectures on group rings: no zero divisors, no idempotents other than 0/1, and no nontrivial units in K[G] for torsion-free G.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "seed_218",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:11.027519+00:00",
    "title": "Kaplansky's Conjectures"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove edge universality for random matrix ensembles beyond Gaussian cases. Formalize Tracy-Widom distribution convergence and the Airy kernel.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "seed_227",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:16.651864+00:00",
    "title": "Random Matrices: Edge Universality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Classify RT\u00b2\u2082 in the reverse mathematics hierarchy: prove it's strictly between ACA\u2080 and WKL\u2080 over RCA\u2080. Formalize Seetapun's theorem.",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "seed_236",
    "priority_score": 0.85,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:18.020118+00:00",
    "title": "Reverse Mathematics: Ramsey's Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize a logic where contradictions do not explode and beliefs can be retracted. Prove that paraconsistent logics can model dream-like reasoning where impossible objects coexist. Show that such logics correspond to topological spaces where open sets are not closed under arbitrary union.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0116",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.958310+00:00",
    "title": "Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the hard problem of consciousness as a theorem about the gap between functional descriptions and subjective experience. Prove that any system satisfying the functional definition of consciousness can have a zombie twin that is functionally identical but experientially void. Show this gap is isomorphic to G\u00f6del's incompleteness gap.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0130",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:31.042804+00:00",
    "title": "Zombies and Qualia: Mathematics of Subjective Experience"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize computation via topological phase transitions: each computation step is a braid group operation on anyonic worldlines. Conjecture: The braid group B_n is universal for computation when augmented with the F-matrix and R-matrix of SU(2)_k anyons for k>=3. Test: implement the Fibonacci anyon model in Lean 4 and prove that braiding generates a dense subset of SU(2). Impact: connects topological quantum computation to algebraic knot theory.",
    "domains": [
      "Computation",
      "Geometry"
    ],
    "id": "fd_0413",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.339802+00:00",
    "title": "Quantum Topological Phase Computation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the consistency of quantum field theory as a proof-theoretic question. Prove that if a physical theory T is consistent, then Con(T) is independent of PA. Show that physical consistency implies mathematical consistency but not vice versa.",
    "domains": [
      "Bridges",
      "Logic"
    ],
    "id": "fd_0454",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.664610+00:00",
    "title": "Logic-Physics Bridge: Consistency of Physical Theories"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Standard proof theory treats proofs as timeless: once proved, always proved. But in practice, proofs are discovered in time, and their dependencies form a temporal order. Formalize a temporal logic of proofs where the modal operator Box means provably established by time t. Conjecture: The temporal provability logic TGL (Temporal Godel-Lob) is decidable and strictly extends GL with the axiom Box A implies Box Box Diamond A (if provable now, provably will be provable at any future time). The key insight is that provability in PA is Sigma_1-complete: if PA proves A, then PA proves that PA proves A. Adding temporality creates a system where proof discovery has a well-defined causal order, and future provability can be reasoned about. Test: prove the arithmetical completeness of TGL relative to Peano Arithmetic with a time-stamped provability predicate. Show that the temporal paradox this statement will be provable tomorrow but not today is refutable in TGL. Impact: a new logic for reasoning about proof discovery in time, with applications to proof mining and automated theorem proving where proof order matters.",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "fd_0490",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:45.766213+00:00",
    "title": "Temporal Logic of Proofs: When You Prove Something Matters"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that P != NP has a physical interpretation: the universe's computational capacity is bounded by the polynomial hierarchy. Formalize this: any physical process that runs in polynomial time can be simulated by a polynomial-time Turing machine (Extended Church-Turing thesis). Show that if P = NP, then the second law of thermodynamics would be violated because Maxwell's demon could be implemented efficiently.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "id": "fd_0561",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:08.713166+00:00",
    "title": "Speculative: Computational Complexity as Physical Law"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove or disprove that every bounded linear operator on a separable Hilbert space has a non-trivial closed invariant subspace. Formalize known results for compact operators and normal operators.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_030",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:01.788604+00:00",
    "title": "Invariant Subspace Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the Kakeya conjecture: a Besicovitch set in R\u207f has Hausdorff dimension n. Formalize the connection to restriction estimates and additive combinatorics.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_035",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:02.777464+00:00",
    "title": "Kakeya Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Sphere packing on S^n (how many non-overlapping caps of radius r fit?) is a fundamental geometric problem with applications to error-correcting codes and signal processing. Use stereographic projection to transform spherical packing to a weighted packing problem on R^n. Define the stereographic packing number N(n,r) as the maximum number of non-overlapping spherical caps of geodesic radius r that fit on S^n. Conjecture: N(n,r) satisfies N(n,r) = (1+O(r^2)) * V_n/V_n(r) where V_n is the volume of S^n and V_n(r) is the volume of a cap, and the O(r^2) correction is explicitly computable from the conformal factor (1+|x|^2)^2/4 of the stereographic projection. More precisely, N(n,r) <= (2/cos(r))^n * V_n/V_n(r). The factor (2/cos(r))^n comes from the maximum conformal distortion of the stereographic projection: a cap of geodesic radius r is mapped to a Euclidean disk whose area differs from the cap area by at most this factor. Test: prove this bound for n=2 and verify it against the known optimal packings (icosahedral: N(2,pi/6) = 12, cuboctahedral: N(2,pi/4) = 6, tetrahedral: N(2,pi/3) = 4). Impact: explicit, computable sphere packing bounds on spheres via classical packing theory on R^n, with applications to spherical codes and molecular geometry.",
    "domains": [
      "Geometry",
      "Computation"
    ],
    "id": "seed_093",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:06.888323+00:00",
    "title": "Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geometry"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that Wall-Sun-Sun primes exist (primes p where p\u00b2 divides F_{p-(p|5)}). Formalize the connection to Fermat's Last Theorem and establish search bounds for the first such prime.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_207",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:08.870932+00:00",
    "title": "Wall-Sun-Sun Primes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the connective constant for the self-avoiding walk on Z\u00b2 equals (2+\u221a2)/2 or determine its exact value. Formalize the Hara-Slade result and Nienhuis's conjecture.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "seed_225",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:12.561612+00:00",
    "title": "Self-Avoiding Walk: Connective Constant"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that a Markov basis for a log-linear model on contingency tables connects all fibers of the model. Formalize the Fundamental Theorem of Markov Bases and compute explicit Markov bases for the no-three-way interaction model.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "seed_323",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:20.604088+00:00",
    "title": "Algebraic Statistics: Markov Bases for Contingency Tables"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The primes have density 0 in the integers, but what is the Hausdorff dimension of the set of primes viewed as a subset of R? Define the 'prime fractal' P as the set of primes with the metric d(p,q) = |1/log(p) - 1/log(q)|. This metric stretches out the primes so that the twin primes are close together and the large primes are spread out. Conjecture: The Hausdorff dimension dim_H(P, d) = 1. The primes with this metric are essentially a 1-dimensional set \u2014 they fill out a line when viewed through the logarithmic lens. This is because the prime number theorem pi(x) ~ x/log(x) means that in the d-metric, the 'length' of the primes up to x is sum_{p <= x} d(p, p+1) ~ sum_{p <= x} 1/(p*log(p)) ~ log(log(x)), which diverges. So the primes are 'long enough' to be 1-dimensional. But the Hausdorff dimension might be > 1 if the primes have fractal structure at small scales. In fact, dim_H(P, d) > 1 would mean the primes are more than a line \u2014 they have 'wrinkles' that fill more space. The twin prime conjecture predicts that there are infinitely many pairs of primes at d-distance ~ 1/(p*log(p)), creating a fractal dust that increases the dimension. Conjecture: dim_H(P, d) = 1 + epsilon where epsilon depends on the density of twin primes. If the twin prime conjecture is true, epsilon > 0. Test: estimate dim_H(P, d) by box-counting for primes up to 10^12 and verify it is close to 1 (or slightly above). Impact: the primes are a fractal with dimension 1 + epsilon, where epsilon measures the abundance of twin primes. If twin primes are infinite, the primes are more than a line \u2014 they are a fractal curve.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0050",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.589354+00:00",
    "title": "Fractal Number Theory: Hausdorff Dimension of Prime Distributions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Determine which integers can be represented as a sum of three cubes. Formalize known computational results and the density conjecture. Connect to the geometry of cubic surfaces and the Hasse principle.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_012",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:58.445057+00:00",
    "title": "Sums of Three Cubes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Study the topology of real algebraic curves and surfaces. Formalize the Harnack bound, classify real algebraic curves by arrangement of ovals, and connect to the second part on limit cycles of planar polynomial ODEs.",
    "domains": [
      "Geometry"
    ],
    "id": "seed_023",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:00.529451+00:00",
    "title": "Hilbert 16: Topology of Algebraic Curves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that if a polynomial map F: C\u207f \u2192 C\u207f has constant non-zero Jacobian determinant, then F is invertible. Formalize the reduction to degree 3 and connect to the Dixmier conjecture.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "seed_034",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:02.571310+00:00",
    "title": "Jacobian Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the gap between consecutive primes p_n satisfies p_{n+1} - p_n = O((log p_n)\u00b2). Formalize probabilistic models of primes and known unconditional bounds.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_037",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:03.180355+00:00",
    "title": "Cram\u00e9r's Conjecture on Prime Gaps"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the union of k k-uniform intersecting hypergraphs has chromatic number at most k. Formalize the linear hypergraph version and recent probabilistic approaches.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_212",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:09.877085+00:00",
    "title": "Erd\u0151s-Faber-Lov\u00e1sz Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that every convex body K in R\u207f of volume 1 has a hyperplane section of (n-1)-dimensional volume at least c for some universal c > 0.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_219",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:11.258186+00:00",
    "title": "Bourgain's Slicing Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for any countable first-order theory, the number of countable models is either countable or 2^\u2135\u2080. Formalize Morley's theorem and the topological version.",
    "domains": [
      "Logic"
    ],
    "id": "seed_235",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:17.826618+00:00",
    "title": "Vaught's Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize transreal arithmetic (Anderson's system: R \u222a {Phi, +inf, -inf} with Phi = 0/0). Prove the ring axioms fail but a wheel structure emerges. Determine which theorems of real analysis survive transreal extension and which collapse.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0102",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.870934+00:00",
    "title": "Transreal Arithmetic: Computing Beyond Plus-Minus Infinity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Develop a rigorous axiomatic foundation for physics, particularly for probability and mechanics. Formalize Kolmogorov's axioms, explore constructive quantum mechanics, and connect to topos-theoretic physics.",
    "domains": [
      "Physics",
      "Logic"
    ],
    "id": "fd_0396",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.003856+00:00",
    "title": "Hilbert 6: Axiomatization of Physics"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Construct a simplicial complex from the citation graph of mathematical theorems: vertices are theorems, edges connect co-cited theorems, triangles connect tri-cited theorems, etc. Compute the persistent homology of this complex. Conjecture: H_1 reveals 'schools of mathematics' (connected research communities) and H_2 reveals 'paradigm shifts' (structural changes in the network). Prove: the Betti numbers grow as \u03b2_k \u2248 n^(k+1) where n is the number of theorems.",
    "domains": [
      "Novelty",
      "MachineLearning"
    ],
    "id": "fd_0575",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T23:40:36.748677+00:00",
    "title": "Speculative: Topological Data Analysis of Theorem Networks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Solve the happy end problem for arbitrary n: determine the minimum number of points in general position in the plane that guarantee a convex n-gon. Formalize the Erd\u0151s\u2013Szekeres theorem and improve known bounds.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_010",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:57.972073+00:00",
    "title": "Happy End Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the Euler-Mascheroni constant \u03b3 \u2248 0.5772 is irrational (or transcendental). Formalize continued fraction expansions and connect to the theory of special values of L-functions.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_027",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:01.338705+00:00",
    "title": "Euler-Mascheroni Constant Irrationality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that if A^x + B^y = C^z where A,B,C,x,y,z are positive integers with x,y,z > 2, then A,B,C share a common prime factor. Formalize the connection to Fermat-Catalan and ABC conjecture.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_036",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:02.987606+00:00",
    "title": "Beal's Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A proof is a sequence of steps. Map each step to a point on S^n via stereographic projection. The proof distance between theorems is the spherical distance between their proof endpoints. Conjecture: Two theorems whose proofs are close in spherical distance share a common subproof of length at least n minus spherical_distance. Test: compute proof distances for a set of 20 basic theorems in Lean 4 and verify the subproof bound. Impact: geometric proof mining and automated lemma discovery.",
    "domains": [
      "Geometry",
      "Logic"
    ],
    "id": "seed_077",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:05.338007+00:00",
    "title": "Stereographic Proof Compression: Proofs on Spheres"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Determine all integer solutions to n! + 1 = m\u00b2. Only three solutions are known (n=4,5,7). Formalize the connection to the ABC conjecture and explore bounds on the spacing between Brown numbers.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_206",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:08.676107+00:00",
    "title": "Brocard's Problem: n! + 1 = m\u00b2"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that every graph on at least 3 vertices is determined up to isomorphism by its deck of vertex-deleted subgraphs. Formalize Kelly's lemma and prove for specific graph classes.",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "seed_215",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:10.494305+00:00",
    "title": "Reconstruction Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove sharp lower bounds for the Willmore energy of surfaces by genus. Extend the Marques-Neves proof for tori to higher-genus surfaces.",
    "domains": [
      "Geometry"
    ],
    "id": "seed_238",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:18.441912+00:00",
    "title": "Willmore Conjecture Generalizations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove Chouldechova's impossibility theorem: when base rates differ across groups, equalized odds and equal calibration cannot both hold. Formalize the tension between individual fairness (similar individuals treated similarly) and group fairness (equal outcomes across groups).",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "seed_326",
    "priority_score": 0.82,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:21.031233+00:00",
    "title": "Algorithmic Fairness: Individual vs Group Fairness Impossibility"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Euclid's parallel postulate says parallel lines never meet. Hyperbolic geometry says they can diverge. Elliptic geometry says they converge. But what about a geometry where parallel lines BOTH converge AND diverge? Define a Split Geometry on R^2 where the parallel postulate is direction-dependent: lines parallel to the x-axis diverge (hyperbolic behavior) while lines parallel to the y-axis converge (elliptic behavior). The metric is ds^2 = dx^2/cosh^2(y) + dy^2 * cosh^2(x) \u2014 expanding in x and contracting in y. Conjecture: Split Geometry is a consistent Riemannian geometry with curvature K(x,y) = -sech^2(y) + sech^2(x) that changes sign across the diagonals. The geometry has a 'phase boundary' along the lines y = x and y = -x where K = 0 (flat). In the region |x| > |y|, K > 0 (elliptic) and in the region |y| > |x|, K < 0 (hyperbolic). The geodesics in split geometry are piecewise combinations of exponential curves (in hyperbolic regions) and trigonometric curves (in elliptic regions). Test: compute the Christoffel symbols and curvature tensor for the split metric. Prove that geodesics cross the phase boundary at most twice. Compute the area of a split triangle with one vertex in each region. Impact: a geometry where the curvature of space depends on which direction you look \u2014 the mathematical realization of a universe that is simultaneously expanding and contracting.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0025",
    "priority_score": 0.81,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.514276+00:00",
    "title": "Impossible Geometries: Where Parallel Lines Converge AND Diverge"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Compute the topological type of the Library of Babel: a space of all possible 410-page books. Prove that it is connected, totally disconnected under the Hamming metric, and has covering dimension 0. Determine the Kolmogorov complexity of a random book and prove that almost all books are incompressible.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0127",
    "priority_score": 0.81,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:31.024124+00:00",
    "title": "Borges' Library of Babel: Combinatorics of Everything"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Huang proved the sensitivity conjecture. Extend: prove tighter bounds on degree-sensitivity relationship of Boolean functions. Formalize the spectral approach via signed adjacency matrices.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "seed_213",
    "priority_score": 0.81,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:10.070200+00:00",
    "title": "Sensitivity Conjecture Extensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that \u03c0, e, \u221a2, or any fundamental constant is normal. Formalize the connection to equidistribution and algebraic independence.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "seed_226",
    "priority_score": 0.81,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:16.410337+00:00",
    "title": "Normality of Mathematical Constants"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Tononi's Integrated Information Theory (IIT) as a rigorous mathematical framework. Prove that the maximum integrated information Phi of a system is the minimum information partition. Show that Phi is NP-hard to compute and construct polynomial-time approximations.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "fd_0506",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.975605+00:00",
    "title": "Consciousness as Integrated Information: Mathematical Foundations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Find an Euler brick whose space diagonal is also an integer, or prove none exists. Formalize the parametric families of near-misses and connect to Diophantine equations on algebraic surfaces.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "seed_011",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:58.210984+00:00",
    "title": "Perfect Cuboid (Euler Brick)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Extend results on quadratic forms to arbitrary algebraic number fields. Formalize the Hasse-Minkowski theorem and explore the classification of quadratic forms over number fields via class field theory.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_019",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:59.481690+00:00",
    "title": "Hilbert 11: Quadratic Forms over Algebraic Fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Provide rigorous foundations for Schubert's enumerative geometry. Formalize intersection theory on Grassmannians and flag varieties, proving Schubert calculus results via modern algebraic geometry.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "seed_022",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:00.322310+00:00",
    "title": "Hilbert 15: Schubert Calculus Rigorization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for every finite union-closed family of sets (not all empty), some element belongs to at least half the sets. Formalize the lattice-theoretic reformulation and known partial results.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_031",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:01.987080+00:00",
    "title": "Frankl's Union-Closed Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Characterize numbers representable as a sum of three squares of primes. Formalize the circle method approach to ternary Goldbach-type problems for squares.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_209",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:09.281210+00:00",
    "title": "Legendre's Three-Square Theorem Extension"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for every polynomial with all roots in the closed unit disk, every root has a critical point within distance 1 of it. Formalize known partial results and the connection to Gauss-Lucas.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_220",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:11.463002+00:00",
    "title": "Sendov's Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "An automatic sequence is one generated by a deterministic finite automaton (DFA). The Thue-Morse sequence 01101001... is 2-automatic. The Rudin-Shapiro sequence is 2-automatic. The paperfolding sequence is 2-automatic. Conjecture: a sequence (a_n) is k-automatic iff its generating function G(x) = sum a_n x^n is algebraic over Q(x) of degree at most k. This is known (Christol's theorem): a formal power series over F_k is algebraic iff its coefficient sequence is k-automatic. But Christol's theorem only works over finite fields. For sequences over Z (or Q), the conjecture is: a sequence (a_n) over Z is k-automatic iff it satisfies a linear recurrence with polynomial coefficients of degree at most k-1 in n. Conjecture: the halting problem for k-automatic sequences is decidable: given a DFA that generates (a_n), it is decidable whether there exists n such that a_n = 0 (the 'zero in sequence' problem). This is TRUE for k-automatic sequences (by the pumping lemma: if the DFA accepts any string, it accepts an infinite number, so a_n = 0 infinitely often). But for morphic sequences (generalizations of automatic sequences), the problem is open. Conjecture: the zero-in-sequence problem for morphic sequences is decidable. Test: implement the decidability algorithm for k-automatic sequences and verify on 100 test sequences. Impact: automatic sequences have decidable halting problems. The boundary between decidability and undecidability in sequence theory is the boundary between automatic and morphic.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0080",
    "priority_score": 0.79,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.733493+00:00",
    "title": "Automatic Sequences and the Halting Problem: When Is a Sequence Computable?"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Determine whether Lehmer's polynomial has the smallest Mahler measure among non-cyclotomic polynomials. Formalize the Mahler measure and its connections to heights, entropy, and algebraic dynamics.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_026",
    "priority_score": 0.79,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:01.145793+00:00",
    "title": "Lehmer's Mahler Measure Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that every tree admits a graceful labeling. Formalize known results for paths, caterpillars, and olive trees. Explore connections to decompositions of complete graphs.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_214",
    "priority_score": 0.79,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:10.274474+00:00",
    "title": "Graceful Tree Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Find a formula for the probability that two elements chosen uniformly at random generate the symmetric group S_n. Formalize known asymptotic results and connect to the theory of random permutations.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_009",
    "priority_score": 0.78,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:57.744824+00:00",
    "title": "Symmetric Group Generation Probability"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Resolve whether the general 7th-degree equation can be solved using functions of only 2 variables. Formalize Kolmogorov's superposition theorem and explore its implications for approximation theory.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_021",
    "priority_score": 0.78,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:00.118535+00:00",
    "title": "Hilbert 13: 7th-Degree Equations via 2-Variable Functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for every integer n \u2265 2, the fraction 4/n can be written as a sum of three unit fractions. Formalize computational verification and parametric families of solutions.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_032",
    "priority_score": 0.77,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:25:02.177753+00:00",
    "title": "Erd\u0151s\u2013Straus Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Hodge conjecture states that every rational cohomology class on a projective variety is a rational linear combination of algebraic cycles. For a ReLU neural network f: R^n -> R, the decision surface V(f) = {x : f(x) = 0} is a piecewise linear hypersurface. Conjecture: every rational homology class in H_{n-2}(V(f), Q) is represented by an algebraic cycle (a subvariety of V(f) of codimension 1). Since V(f) is piecewise linear, its homology groups are finitely generated and every cycle is a formal sum of linear pieces. Each linear piece is an algebraic cycle (a hyperplane section). Conjecture: the piecewise linear Hodge conjecture holds \u2014 every homology class in V(f) is a sum of hyperplane sections. This is TRUE for piecewise linear varieties because every face of a polyhedron is cut out by a linear equation. The deeper conjecture: for a ReLU network with L layers and widths (n, w_1, ..., w_L, 1), the Hodge numbers h^{p,q}(V(f)) satisfy h^{p,q} <= (w_1 choose p) * (w_L choose q) * prod_{i=2}^{L-1} w_i. Test: compute H_{n-2}(V(f)) for small ReLU networks and verify that every class is represented by hyperplane sections. Impact: the Hodge conjecture is trivially true for neural network decision surfaces. The non-trivial content is the BOUND on Hodge numbers.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0079",
    "priority_score": 0.76,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.728070+00:00",
    "title": "The Hodge Conjecture for Neural Networks: Algebraic Cycles in Decision Surfaces"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Research Directions: Verifiable Computation and Zero-Knowledge Proofs\n\n## Synthesis\n\nThis research cycle established the complete algebraic pipeline underlying zk-SNARKs: from R1CS constraint satisfaction through QAP polynomial encoding to Schwartz-Zippel-based verification soundness. The `VerifiableComputation` structure we introduced captures this pipeline as a single mathematical object, with composition theorems enabling recursive proof systems.\n\nThe most promising cross-domain connection emerged between our polynomial commitment soundness theorem and the existing `circuit_zero_poly_vanishes` result in the Algebra catalog: both express the principle that algebraic constraints encode as polynomial root conditions, but our work operates at the cryptographic protocol level while the catalog result operates at the algebraic geometry level. Bridging these \u2014 showing that the Nullstellensatz-based approach and the SNARK-based approach are instances of a common algebraic framework \u2014 could yield a unified theory of verifiable algebra.\n\nThe highest breakthrough potential lies in Direction 1 (Knowledge Soundness via Algebraic Extraction): formalizing not just soundness (no false proofs) but *knowledge soundness* (the prover must \"know\" a witness) would complete the most important theoretical gap in our formalization and has never been done in a theorem prover. This requires formalizing the concept of an algebraic extractor, which connects our R1CS framework to the Algebraic Group Model.\n\n---\n\n### Direction 1: Knowledge Soundness via Algebraic Extraction\n\n**Conjecture**: For any R1CS-based SNARK where the prover operates as an algebraic algorithm (its outputs are F-linear combinations of its inputs and group elements), there exists a polynomial-time extractor that recovers a valid witness from any accepting prover. Formally: if P is an algebraic prover for R1CS $r$ and the verifier accepts with probability $\\geq \\epsilon$, then the extractor recovers $w$ with $r.\\text{IsSatisfied}(w)$ in expected time $\\text{poly}(n) / \\epsilon$.\n\n**Test**: Define `AlgebraicProver` as a structure whose outputs are formal linear combinations of inputs. Formalize the extractor for Groth16's specific verification equation $e(A, B) = e(\\alpha, \\beta) \\cdot e(C, \\delta) \\cdot e(\\text{pub}, \\gamma)$. Attempt to prove extraction by showing the algebraic constraint forces the prover's internal state to encode a valid witness. A concrete test: verify extraction works for an R1CS with 3 constraints over $\\mathbb{F}_p$ for a small prime $p$.\n\n**Impact**: If proved, this would be the first machine-verified proof of knowledge soundness for any SNARK construction. If it fails, it would identify precisely where the algebraic group model assumption is needed, potentially revealing new attack vectors.\n\n**Catalog References**: `Cryptography/ZeroKnowledge/SNARK.lean` (R1CS, composition), `Cryptography/Foundation.lean` (`soundness_error_bound`)\n\n**Proof Strategy**: (1) Define `AlgebraicProver` structure with linearity constraint. (2) Show Groth16 verification equation forces a linear system on the prover's coefficients. (3) Prove the linear system has a unique solution encoding a valid R1CS witness. Key lemma: the coefficient matrix of the linear system is full-rank iff the CRS is well-formed.\n\n**Domain Bridges**: Cryptography (SNARK soundness) \u2194 Algebra (linear algebra over finite fields) \u2194 Computation (extraction algorithms)\n\n**Lineage**: Builds on `r1cs_compose_sound`, `schwartz_zippel_root_bound`, `poly_commit_soundness` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Folding Schemes and Recursive SNARKs (Nova-style)\n\n**Conjecture**: There exists a \"folding operator\" $\\text{Fold} : \\text{R1CS}(F, m, n) \\times \\text{R1CS}(F, m, n) \\to \\text{R1CS}(F, m, n)$ such that $w$ satisfies $\\text{Fold}(r_1, r_2)$ iff there exist $w_1, w_2$ satisfying $r_1, r_2$ respectively and $w = w_1 + r \\cdot w_2$ for a random challenge $r$. Furthermore, the folding operation preserves the degree structure needed for Schwartz-Zippel soundness.\n\n**Test**: Define the relaxed R1CS (with error term $e$ and scalar $u$: $(Aw) \\circ (Bw) = u \\cdot Cw + e$). Formalize the Nova folding operation: given two relaxed instances $(u_1, e_1)$ and $(u_2, e_2)$, produce $(u_1 + r \\cdot u_2, e_1 + r \\cdot T + r^2 \\cdot e_2)$ where $T$ is the cross term. Prove that if both input instances are satisfiable, the folded instance is satisfiable.\n\n**Impact**: Would formalize the algebraic foundation of recursive proof composition, enabling proofs of proofs of proofs... This is the mathematical basis of blockchain scaling (zkRollups accumulating transactions).\n\n**Catalog References**: `Cryptography/ZeroKnowledge/SNARK.lean` (`R1CS.compose`, `r1cs_compose_sound`), `Algebra/NullstellensatzPIT.lean` (`circuit_zero_poly_vanishes`)\n\n**Proof Strategy**: (1) Define `RelaxedR1CS` extending R1CS with error vector and scalar. (2) Define the cross-term polynomial $T$. (3) Prove folding completeness: two valid instances fold to a valid instance. (4) Prove folding soundness via Schwartz-Zippel on the cross-term.\n\n**Domain Bridges**: Cryptography (recursive proofs) \u2194 Algebra (polynomial identity testing) \u2194 Computation (incremental verification)\n\n**Lineage**: Directly extends `R1CS.compose` and `r1cs_compose_sound`.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Plonkish Arithmetization and Permutation Arguments\n\n**Conjecture**: The Plonk permutation argument can be formalized as a polynomial identity: given a permutation $\\sigma$ on $[n]$ and vectors $f, g$ with $g = f \\circ \\sigma$, the \"grand product\" polynomial $Z(x) = \\prod_{i=1}^{k} \\frac{f(\\omega^i) + \\beta \\omega^i + \\gamma}{g(\\omega^i) + \\beta \\sigma(\\omega^i) + \\gamma}$ satisfies $Z(\\omega^n) = 1$ iff $g$ is indeed a permutation of $f$. This can be proved purely algebraically over any field of size $> n$.\n\n**Test**: Define the grand product polynomial over $\\text{ZMod}(p)$ for a small prime $p$. Verify computationally for $n = 4$ that $Z(\\omega^4) = 1$ when $g = f \\circ \\sigma$ and $Z(\\omega^4) \\neq 1$ (with high probability over $\\beta, \\gamma$) when $g$ is not a permutation of $f$.\n\n**Impact**: Would formalize the core algebraic technique behind Plonk, the most widely deployed SNARK system. The permutation argument is the key innovation that distinguishes Plonk from R1CS-based systems.\n\n**Catalog References**: `Cryptography/ZeroKnowledge/SNARK.lean` (vanishing polynomial, Schwartz-Zippel), `Algebra/NullstellensatzPIT.lean`\n\n**Proof Strategy**: (1) Define evaluation domain as roots of unity (requires $n | p-1$). (2) Define the grand product polynomial via `Finset.prod`. (3) Prove the telescoping property: $Z(\\omega^{k+1}) / Z(\\omega^k) = \\frac{f(\\omega^k) + \\beta \\omega^k + \\gamma}{g(\\omega^k) + \\beta \\sigma(\\omega^k) + \\gamma}$. (4) Show $Z(\\omega^n) = 1$ iff the accumulated product is 1 iff $g$ is a permutation of $f$.\n\n**Domain Bridges**: Cryptography (Plonk) \u2194 Algebra (permutation groups, roots of unity) \u2194 Combinatorics (permutation counting)\n\n**Lineage**: Extends vanishing polynomial and Schwartz-Zippel foundations from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical SNARK Soundness \u2014 SNARKs over Non-Standard Algebras\n\n**Conjecture**: The R1CS framework can be extended to semirings (not just fields) by replacing multiplication gates with semiring operations. Over the tropical semiring $(\\mathbb{R} \\cup \\{\\infty\\}, \\min, +)$, an R1CS-like constraint system captures shortest-path computations, and a \"tropical Schwartz-Zippel\" bound exists: a nonzero tropical polynomial of degree $d$ has at most $d$ \"tropical roots\" (points where the minimum is achieved by two or more terms) in any set of size $> d$.\n\n**Test**: Define `TropicalR1CS` with min-plus operations. Formulate the tropical analogue of the Schwartz-Zippel lemma. Test computationally: generate random tropical polynomials of degree 5 over $\\{0, 1, \\ldots, 100\\}$ and count tropical roots. If the count consistently exceeds 5, the conjecture is false.\n\n**Impact**: If true, this would establish that verifiable computation extends beyond fields to optimization problems (shortest paths, scheduling). This connects cryptography to tropical geometry, a rapidly developing area of mathematics.\n\n**Catalog References**: `Cryptography/TropicalMinPlusCrypto.lean` (`tropical_zero_knowledge_shift`), `Tropical/` (tropical optimization results), `Cryptography/ZeroKnowledge/SNARK.lean`\n\n**Proof Strategy**: (1) Define `TropicalR1CS` using the min-plus semiring. (2) Define \"tropical roots\" as non-differentiability points of the piecewise linear function. (3) Relate tropical root count to the number of linear pieces minus 1. (4) Prove the bound by induction on degree.\n\n**Domain Bridges**: Cryptography (verifiable computation) \u2194 Tropical geometry (tropical polynomials) \u2194 Optimization (shortest paths)\n\n**Lineage**: Bridges `tropical_zero_knowledge_shift` with the R1CS framework from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Information-Theoretic Limits of SNARK Proof Size\n\n**Conjecture**: For any R1CS with $m$ constraints over $n$ variables, any sound SNARK proof (with soundness error $\\leq 2^{-\\lambda}$) must have proof size $\\geq \\lambda$ bits in the random oracle model. This is a lower bound on SNARK succinctness. Furthermore, for $m > n^2$, the proof size must be $\\geq \\lambda + \\log(m/n^2)$, reflecting the \"compression cost\" of reducing many constraints to a succinct proof.\n\n**Test**: Define a formal model of SNARK proof size as the bit-length of the verifier's input (excluding the statement). Formulate the information-theoretic lower bound. Attempt proof by reduction: if a shorter proof existed, it could be used to compress random strings, contradicting Shannon's source coding theorem. Test the bound computationally by generating random R1CS instances and measuring actual proof sizes in a simplified SNARK.\n\n**Impact**: Would establish the first formal lower bound on SNARK proof size, answering a long-standing open question in the field. Current SNARKs achieve O(1) group elements (Groth16) or O(log n) field elements (FRI-based), but no formal proof exists that these are optimal.\n\n**Catalog References**: `Cryptography/ZeroKnowledge/SNARK.lean`, `Cryptography/Foundation.lean` (`soundness_error_bound`), `Computation/InfoEfficientAlgorithms.lean`\n\n**Proof Strategy**: (1) Model SNARK proofs as bit strings. (2) Use a counting argument: the number of accepting proof strings must be small (soundness), so the proof must carry enough information to distinguish valid statements. (3) Apply Shannon's theorem to get the lower bound. (4) For the $m > n^2$ case, argue that the constraint space is larger than what $n^2$ coefficients can represent.\n\n**Domain Bridges**: Cryptography (proof complexity) \u2194 Information theory (Shannon bounds) \u2194 Computation (circuit complexity)\n\n**Lineage**: Extends soundness bounds from this cycle; connects to `InfoEfficientAlgorithm` in the Computation catalog.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0684",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6d9cd26b",
    "status": "available",
    "timestamp": "2026-06-05T05:34:06.254800+00:00",
    "title": "Complete algebraic pipeline underlying zk-SN"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Simulation Morphism Theory and Cellular Automata Universality\n\n## Synthesis\n\nThis research cycle established the **simulation morphism** as a novel algebraic structure for reasoning about computational universality in cellular automata. The key insight is that simulation relations between discrete dynamical systems compose categorically, with time dilation factors multiplying under composition. This gives rise to a \"dilation functor\" from the simulation category to the multiplicative monoid (\u2115+, \u00d7), providing systematic complexity tracking.\n\nThe most promising cross-domain connection is between simulation morphisms and the existing **Berggren cellular automaton** formalization in the Catalog (`Pythagorean/BerggrenCA.lean`). The Berggren CA already proves universality via two-counter machine simulation on a tree-structured lattice. Our simulation morphism framework could unify this with GoL universality, showing both are instances of the same categorical construction with different target spaces (tree lattice vs. integer lattice).\n\nThe direction with highest breakthrough potential is **Direction 1** (Categorical Universality Classification): if we can characterize which CAs admit simulation morphisms from universal Turing machines purely in terms of their local rule structure, this would give a decidable criterion for universality \u2014 a long-standing open problem in CA theory.\n\n---\n\n### Direction 1: Categorical Universality Classification via Local Rule Properties\n\n**Conjecture**: A cellular automaton on \u2124^d with finite state set is Turing-complete if and only if (1) it is not nilpotent (some configuration has non-trivial orbit), (2) it is not eventually periodic on all configurations, and (3) its local rule is not monotone with respect to any total order on the state set. Equivalently: the simulation category restricted to CAs on \u2124^d admits a morphism from any universal TM if and only if these three necessary conditions hold.\n\n**Test**: Verify the conjecture for all 256 elementary CAs (1D, 2-state, radius-1). Rules 110 and 30 are known to be universal and satisfy all three conditions. Check that all non-universal rules violate at least one condition.\n\n**Impact**: If true, this gives a polynomial-time decidable criterion for CA universality \u2014 currently there is no known general criterion. If false, the specific counterexample reveals which additional structural property is needed.\n\n**Catalog References**: `Pythagorean/BerggrenCA.lean` (universality via two-counter machines), `Computation/GravityOracle.lean` (oracle/fixed-point structure)\n\n**Proof Strategy**: (1) Prove that nilpotent CAs cannot be universal (trivial \u2014 they collapse to a fixed point). (2) Prove that monotone CAs cannot be universal (our `gol_not_monotone` theorem is a start; generalize to show monotone CAs have polynomial-time decidable halting). (3) For the converse, construct explicit simulation morphisms for CAs satisfying all three conditions, using the intrinsic universality results of Ollinger (2008).\n\n**Domain Bridges**: Computation \u2194 Algebra (monotonicity as lattice-theoretic obstruction to universality)\n\n**Lineage**: Builds on `gol_not_monotone`, `SimMorphism.comp`, `block_is_still_life` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Dilation Spectrum of the Game of Life\n\n**Conjecture**: Define the **dilation spectrum** of GoL as the set D(GoL) = {d \u2208 \u2115+ | \u2203 TM, SimMorphism from TM to GoL with dilation d}. Conjecture: D(GoL) is cofinite in \u2115+ \u2014 that is, all sufficiently large positive integers appear as dilations of some TM simulation.\n\n**Test**: For small Turing machines (2-3 states, 2 symbols), construct explicit GoL simulations and record their dilations. Check if the set of achievable dilations has density approaching 1.\n\n**Impact**: Understanding the dilation spectrum reveals the \"granularity\" of GoL as a computational medium. A cofinite spectrum means GoL can match any desired simulation speed (up to a constant). A sparse spectrum means certain speeds are structurally impossible.\n\n**Catalog References**: `Novelty/GameOfLife/SimulationTheory.lean` (dilation_chain_bound, simulation_complexity_bound)\n\n**Proof Strategy**: Use the composition theorem to show that if dilations d\u2081 and d\u2082 are achievable, then any linear combination a\u00b7d\u2081 + b\u00b7d\u2082 (with appropriate constraints) is achievable. Apply the Chicken McNugget theorem (Frobenius coin problem) to show cofiniteness when gcd(d\u2081, d\u2082) = 1.\n\n**Domain Bridges**: Novelty \u2194 Algebra (Frobenius numbers, numerical semigroups)\n\n**Lineage**: Builds on `SimMorphism.comp`, `comp_dilation_eq`, `dilation_chain_bound` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Topological Dynamics of the Simulation Category\n\n**Conjecture**: The simulation category of CAs on \u2124\u00b2, when equipped with the product topology on configurations and the compact-open topology on morphisms, has the property that the set of universal CAs (those admitting a SimMorphism from a universal TM) is a dense G\u03b4 set in the space of all CA rules.\n\n**Test**: Define a metric on the space of CA rules (e.g., Hamming distance on the local rule table). Show that every neighborhood of a non-universal CA contains a universal CA by perturbing the rule table.\n\n**Impact**: If true, this means universality is \"generic\" \u2014 a randomly chosen CA rule is almost surely universal, and non-universality is a measure-zero phenomenon. This would be a striking structural result about the landscape of computation.\n\n**Catalog References**: `Novelty/GameOfLife/GoLStructure.lean` (golStep_translate_comm, golStep_equivariant), `Computation/GravityOracle.lean`\n\n**Proof Strategy**: Use the result of Durand, Formenti, and Varouchas that intrinsically universal CAs are dense in the Besicovitch topology. Adapt their construction to the simulation morphism framework.\n\n**Domain Bridges**: Novelty \u2194 Geometry (topological dynamics), Novelty \u2194 EML (generic complexity)\n\n**Lineage**: Builds on `golStep_translate_comm`, `SimMorphism` structure from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Berggren-GoL Bridge via Simulation Morphisms\n\n**Conjecture**: There exists a simulation morphism from the Berggren CA (defined on the ternary tree lattice) to the Game of Life (on \u2124\u00b2), with dilation bounded by O(depth\u00b2) where depth is the maximum tree depth of active cells.\n\n**Test**: Construct an explicit encoding of Berggren tree addresses as GoL patterns. Verify faithfulness for programs of depth \u2264 3.\n\n**Impact**: This would unify two independent universality results in the Catalog \u2014 Berggren CA universality and GoL universality \u2014 showing they are connected by a concrete simulation morphism. It would demonstrate that tree-structured and grid-structured computation are interconvertible with polynomial overhead.\n\n**Catalog References**: `Pythagorean/BerggrenCA.lean` (BerggrenCA, tcSimulator_local, berggren_ca_simulates), `Pythagorean/EmergentComputation.lean` (berggren_universality_via_locality_and_growth)\n\n**Proof Strategy**: (1) Encode tree addresses as positions in \u2124\u00b2 using a space-filling curve restricted to a fractal subset. (2) Encode cell states as local GoL patterns (still lifes for quiescent, oscillators for active). (3) Prove that the GoL evolution on these encoded patterns faithfully tracks the Berggren CA evolution, using the locality of both rules (radius 4 for Berggren, radius 1 for GoL).\n\n**Domain Bridges**: Novelty \u2194 Pythagorean (Berggren tree \u2194 integer lattice), Computation \u2194 Novelty\n\n**Lineage**: Builds on `SimMorphism.comp`, `SimMorphism.encode_iterate`, `berggren_ca_simulates` from Catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Entropy and Information Loss in Simulation Chains\n\n**Conjecture**: For any simulation morphism f : A \u2192 B, the topological entropy of B restricted to the image of encode is exactly h(A) / dilation(f), where h denotes topological entropy. That is, simulation morphisms preserve entropy up to the dilation scaling factor.\n\n**Test**: Compute the topological entropy of the shift map (known to be log(k) for k symbols) and verify that GoL patterns encoding the shift have entropy log(k)/d where d is the dilation.\n\n**Impact**: This would connect simulation theory to ergodic theory, showing that the \"information processing rate\" of a simulation is an invariant of the simulation morphism. It would also provide lower bounds on dilation: dil(f) \u2265 h(A)/h(B), meaning a system with low entropy cannot efficiently simulate one with high entropy.\n\n**Catalog References**: `Novelty/GameOfLife/SimulationTheory.lean` (SimMorphism.encode_iterate), `EML/AdvancedTheory.lean` (ensemble complexity)\n\n**Proof Strategy**: (1) Define topological entropy for discrete dynamical systems via spanning sets. (2) Show that the encoding map is a topological embedding when the configuration space has the product topology. (3) Use the variational principle to relate the entropy of B restricted to the image to the entropy of A.\n\n**Domain Bridges**: Novelty \u2194 EML (information theory \u2194 simulation overhead)\n\n**Lineage**: Builds on `SimMorphism` structure and composition theorems from this cycle.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0688",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6cc2e7a5",
    "status": "available",
    "timestamp": "2026-06-05T06:49:00.810603+00:00",
    "title": "**simulation morphism** as a novel algebraic"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n## Synthesis\n\nThis cycle introduced the **Simulation Morphism Algebra** \u2014 a formal algebraic framework for studying simulation relationships between discrete dynamical systems. The central contribution is the `SimMorphism` structure, which captures simulation as an injective encoding intertwining dynamics up to time dilation, together with the proof that these morphisms compose with multiplicative overhead. The **simulation spectrum** (set of achievable self-simulation dilations) was shown to form a multiplicative submonoid of \u2115, providing a novel algebraic invariant of dynamical systems.\n\nThe most promising cross-domain connection is between this simulation algebra and the existing tropical Game of Life formalization in `Computation/TropicalLife/Basic.lean`. The tropical Life automaton is defined on finite tori with threshold-based update rules expressed through min-plus primitives. A natural next step is to construct explicit `SimMorphism` instances between the tropical Life automaton and classical Boolean Life, and between different torus sizes, yielding concrete dilation bounds. The existing `turing_simulation_width_bound` in `Tropical/TropicalDeepResearch.lean` provides width bounds that could be connected to spatial overhead in our framework.\n\nThe highest breakthrough potential lies in **Direction 1**: proving that the simulation spectrum characterizes computational universality. If the spectrum of a Turing-complete system is provably cofinite, this would give a purely algebraic criterion for universality \u2014 avoiding the traditional construction-heavy proofs entirely. The existing `berggren_orbit_turing_complete` result in `Pythagorean/BerggrenCA.lean` provides a starting point for testing this conjecture on specific systems.\n\n---\n\n### Direction 1: Spectral Characterization of Turing Completeness\n\n**Conjecture**: A dynamical system D (with decidable equality on finite-state projections) is Turing complete if and only if its simulation spectrum SimSpectrum(D) is cofinite (i.e., contains all sufficiently large natural numbers). More precisely: if D can simulate every 2-tag system via some SimMorphism, then for all sufficiently large n \u2208 \u2115, there exists a self-simulation morphism with dilation n.\n\n**Test**: Compute the simulation spectrum (restricted to block-code encodings) for Rule 110 on grids of size N = 10, 20, 50, 100. Check whether the fraction of {1,...,N} contained in the spectrum approaches 1 as N grows. As a negative control, compute the spectrum for Rule 0 (trivial dynamics) and verify it equals {1}.\n\n**Impact**: If true, this gives a purely algebraic characterization of Turing completeness that avoids explicit Turing machine constructions. It would connect universality to the multiplicative number theory of simulation spectra. If false, the failure mode reveals what additional structure (beyond spectral richness) is needed for universality.\n\n**Catalog References**: `Novelty/GameOfLife/SimSpectrum.lean` (SimSpectrum definition, multiplicative monoid structure), `FINAL/Pythagorean/BerggrenCA.lean` (berggren_orbit_turing_complete)\n\n**Proof Strategy**: (1) Prove the forward direction first: if D is universal, construct self-simulations for all sufficiently large d by composing the universal simulation with systems of varying complexity. (2) For the converse, show that cofinite spectrum implies the ability to simulate arbitrary tag systems by using the dense set of dilations to \"tune\" the simulation rate. Key lemma needed: for a universal system, the encoding of any finite-state machine into D has bounded dilation, and self-simulations at nearby dilations can be composed to cover any target.\n\n**Domain Bridges**: Novelty (simulation algebra) \u2194 Computation (Turing completeness) \u2194 Algebra (multiplicative number theory of spectra)\n\n**Lineage**: Builds on SimSpectrum theory from this cycle and existing universality results.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Spatial Overhead Morphisms and the Space-Time Tradeoff Theorem\n\n**Conjecture**: Extend SimMorphism to include a spatial dilation factor \u03c3 (measuring how many cells of the target represent one cell of the source). Then for any simulation of a d-dimensional CA by a d-dimensional CA: the product \u03c4 \u00b7 \u03c3^d \u2265 C for some constant C depending only on the source system's entropy. In other words, there is a fundamental space-time tradeoff: reducing time overhead requires increasing spatial overhead, and vice versa, with a lower bound governed by information-theoretic quantities.\n\n**Test**: Construct explicit SimMorphisms between Game of Life (2D) variants at different resolutions (e.g., 2\u00d72 block encoding vs. 4\u00d74 block encoding) and measure the \u03c4 \u00b7 \u03c3\u00b2 product. Compare with the topological entropy of the source system computed via orbit counting on small tori.\n\n**Impact**: This would establish a formal space-time tradeoff theorem for cellular automata simulation, analogous to time-space tradeoffs in Turing machine complexity theory but stated in the language of simulation morphisms. It connects simulation algebra to information theory and ergodic theory.\n\n**Catalog References**: `Novelty/GameOfLife/Defs.lean` (SimMorphism), `Computation/TropicalLife/Basic.lean` (tropical Life on tori), `FINAL/Tropical/TropicalDeepResearch.lean` (turing_simulation_width_bound)\n\n**Proof Strategy**: (1) Extend SimMorphism with a `spatialDilation : \u2115` field and adjust equivariance to account for spatial rescaling. (2) Define topological entropy for finite-state CAs via orbit growth rates. (3) Prove that encode_injective implies \u03c3^d \u2265 |source states| / |target states| per cell, giving a lower bound on \u03c3. (4) Combine with the multiplicative dilation theorem to get the space-time tradeoff.\n\n**Domain Bridges**: Novelty (simulation algebra) \u2194 Computation (space-time complexity) \u2194 Physics (thermodynamic cost of simulation, Landauer's principle)\n\n**Lineage**: Direct extension of SimMorphism framework from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Simulation Morphisms\n\n**Conjecture**: The tropical Life automaton (defined in `Computation/TropicalLife/Basic.lean` using min-plus threshold functions) and the classical Boolean Game of Life on the same torus are connected by a SimMorphism with dilation 1 when restricted to binary-valued configurations. That is, on binary inputs, the tropical rule and the classical rule agree, and this agreement constitutes a formal simulation morphism.\n\n**Test**: Construct the SimMorphism explicitly in Lean by showing that for binary-valued configurations, `tropicalLocalRule` coincides with the classical Life rule. Verify equivariance by checking that `tropicalLifeStep` on binary configs produces binary configs (already proved as `tropicalLifeStep_binary`) and that the values match.\n\n**Impact**: This would bridge the tropical algebra approach to Life with the simulation morphism framework, enabling tropical algebraic tools (min-plus convolution, tropical spectral theory) to be applied to questions about Life's computational universality. It would also validate the tropical threshold encoding as faithful.\n\n**Catalog References**: `Computation/TropicalLife/Basic.lean` (tropicalLifeStep, tropicalLocalRule, tropicalLifeStep_binary), `Computation/StillLife.lean` (block_is_still_life), `Novelty/GameOfLife/Defs.lean` (SimMorphism)\n\n**Proof Strategy**: (1) Define the classical Boolean Life rule on the same Cell/Config types. (2) Prove pointwise agreement with tropicalLocalRule on binary configs by case analysis on the neighborhood sum (values 0-8) and alive/dead status. (3) Package the inclusion of binary configs as a subsystem and construct SimMorphism using `subsystemSimMorphism` with the agreement lemma.\n\n**Domain Bridges**: Novelty (simulation algebra) \u2194 Tropical (min-plus algebra) \u2194 Computation (Game of Life dynamics)\n\n**Lineage**: Builds on tropical Life formalization in Computation/TropicalLife and SimMorphism framework from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Simulation Morphism Category and Functorial Invariants\n\n**Conjecture**: The collection of all discrete dynamical systems with simulation morphisms forms a category (SimCat) where the dilation function d : Mor(SimCat) \u2192 (\u2115, \u00b7) is a faithful functor to the multiplicative monoid of natural numbers. Furthermore, the simulation spectrum functor SimSpectrum : Ob(SimCat) \u2192 SubMonoid(\u2115) is a contravariant invariant: if there exists a SimMorphism from A to B, then SimSpectrum(A) \u2286 SimSpectrum(B) (up to multiplication by the dilation).\n\n**Test**: Formalize SimCat as a Lean 4 Category instance (using Mathlib's category theory library). Verify the functor laws. Test the containment conjecture on explicit examples: compute SimSpectrum for the identity system, shift systems, and Rule 110 on small grids.\n\n**Impact**: Embedding simulation theory into category theory unlocks powerful abstract machinery: limits, colimits, adjunctions, and natural transformations all become available for reasoning about simulation. The spectrum functor would be a computable invariant that distinguishes dynamical systems up to simulation equivalence.\n\n**Catalog References**: `Novelty/GameOfLife/Defs.lean` (SimMorphism, SimMorphism.comp, SimMorphism.id), `Novelty/GameOfLife/SimSpectrum.lean` (SimSpectrum, multiplicative monoid structure)\n\n**Proof Strategy**: (1) Define SimCat using Mathlib's `CategoryStruct` and `Category` typeclasses. (2) Verify identity and associativity laws (identity is proved; associativity of composition needs a short proof). (3) Define the dilation functor and verify functoriality. (4) Prove the spectrum containment result by composing self-simulations with the inter-system morphism.\n\n**Domain Bridges**: Novelty (simulation algebra) \u2194 Algebra (category theory) \u2194 Computation (complexity invariants)\n\n**Lineage**: Direct categorical upgrade of the SimMorphism framework from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Reversible Simulation and Thermodynamic Cost\n\n**Conjecture**: For reversible cellular automata (where the step function is bijective), the simulation spectrum is always a group (closed under division when it divides). Moreover, simulating an irreversible CA by a reversible CA requires a strict dilation overhead of at least 2 \u2014 there is no dilation-1 reversible simulation of any irreversible CA.\n\n**Test**: (1) Construct the reversible Critters rule (a known reversible 2D CA) and compute its simulation spectrum. Verify group closure. (2) Attempt to construct a SimMorphism from Game of Life to Critters with dilation 1 and verify it fails. (3) Prove the dilation \u2265 2 lower bound using information-theoretic arguments about surjectivity of the step function.\n\n**Impact**: This connects simulation algebra to the thermodynamics of computation (Landauer's principle). The dilation lower bound for irreversible \u2192 reversible simulation has implications for the energy cost of universal computation in physical implementations.\n\n**Catalog References**: `Computation/ReversibleSortingBennett.lean`, `Computation/ReversibleTropicalMachine.lean`, `Novelty/GameOfLife/Defs.lean` (SimMorphism)\n\n**Proof Strategy**: (1) Add a `Bijective` hypothesis to the step function and show that SimMorphism.comp preserves bijectivity of the step function restricted to the image. (2) For the irreversibility barrier: if src.step is not injective (two states map to the same), then any SimMorphism must map these to distinct target states, imposing constraints on the dilation. (3) Formalize the cardinality argument: on finite grids, |im(step)| < |State| for irreversible CAs, which forces the encoding to \"spread\" information, requiring dilation \u2265 2.\n\n**Domain Bridges**: Novelty (simulation algebra) \u2194 Physics (thermodynamic computation) \u2194 Computation (reversible computing)\n\n**Lineage**: Extends SimMorphism to the reversible setting, building on existing reversible computation formalizations.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0702",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "3860a5c0",
    "status": "available",
    "timestamp": "2026-06-05T09:09:43.611350+00:00",
    "title": "**Simulation Morphism Algebra** \u2014 a formal algebraic f"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Dreamtime Algebra and Kinship Group Theory\n\n## Synthesis\n\nThis cycle introduced the **Dreamtime algebra** \u2014 a finite abelian group equipped with two distinguished elements of order 2 (marriage and descent generators). We proved that the Kariera 4-section system is Z\u2082 \u00d7 Z\u2082 and the Aranda 8-subsection system is Z\u2082\u00b3, established marriage rules as coset restrictions, proved the alternating generations theorem, discovered a triality structure, and proved impossibility results for kinship systems on various groups.\n\nThe most promising cross-domain connection is to **coding theory and projective geometry**: the kinship elements {0, \u03c3, \u03b4, \u03c3+\u03b4} form a [4,2,2] binary linear code, and the kinship spectrum of (Z\u2082)\u207f is precisely the set of points of the projective space PG(n-1, 2). This connects Aboriginal kinship to the same algebraic structures underlying error-correcting codes and finite geometry. The Catalog's existing work on finite group separators (`finite_group_separator_to_perm_separator` in `Speculative/AutoResearch/ResidualFiniteness.lean`) provides infrastructure for studying separation properties of kinship groups.\n\nThe highest breakthrough potential lies in **Direction 1** (non-abelian kinship): extending Dreamtime algebras to non-abelian groups would capture more complex kinship systems (Murngin, Ambrym) and connect to representation theory of finite groups. **Direction 3** (the coding theory bridge) has the most immediate cross-domain value, potentially yielding new results in both mathematical anthropology and algebraic coding theory.\n\n---\n\n### Direction 1: Non-Abelian Dreamtime Algebras and the Murngin Problem\n\n**Conjecture**: The Murngin kinship system (which L\u00e9vi-Strauss identified as more complex than the Aranda) can be formalized as a Dreamtime algebra over a non-abelian group, specifically the dihedral group D\u2084 of order 8, where the marriage map is conjugation rather than translation.\n\n**Test**: Define a \"generalized Dreamtime algebra\" where G is any finite group (not necessarily abelian), the marriage map is g \u21a6 \u03c3g\u03c3\u207b\u00b9 (conjugation by \u03c3), and the descent map is g \u21a6 g\u03b4 (right multiplication). Verify that the Murngin marriage rules match this structure by checking compatibility with ethnographic data. Computationally test whether D\u2084, Q\u2088 (quaternion group), or other non-abelian groups of order 8 admit valid generalized kinship structures.\n\n**Impact**: If true, this would extend the Dreamtime algebra framework to all known Aboriginal kinship systems and show that the abelian/non-abelian distinction in group theory corresponds to a genuine anthropological distinction between \"simple\" and \"complex\" kinship. If false, it would prove that non-abelian kinship systems require fundamentally different mathematical structures.\n\n**Catalog References**: `Speculative/AutoResearch/ResidualFiniteness.lean` (finite group theory infrastructure), `Algebra/MatrixGroupGeneration.lean` (group generation results)\n\n**Proof Strategy**: Define `GeneralizedDreamtimeAlgebra` with conjugation and right multiplication. Prove that in the abelian case, it reduces to the standard Dreamtime algebra. Then construct the D\u2084 instance and verify the marriage/descent tables match Murngin data.\n\n**Domain Bridges**: Abstract Algebra <-> Mathematical Anthropology <-> Representation Theory\n\n**Lineage**: Extends the DreamtimeAlgebra structure from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Kinship Lattice and Matroid Structure\n\n**Conjecture**: The set of all Dreamtime algebras on a given elementary abelian 2-group (Z\u2082)\u207f, ordered by \"refinement\" (system A refines system B if A's generators generate a subgroup containing B's generators), forms a lattice isomorphic to the lattice of 2-element subsets of PG(n-1, 2), the projective space over F\u2082.\n\n**Test**: Enumerate all Dreamtime algebras on Z\u2082\u00b2 (6 ordered pairs) and Z\u2082\u00b3 (42 ordered pairs). Define the refinement order. Compute the resulting poset and check if it is a lattice. If so, determine its isomorphism type. For n=2, there should be 3 unordered systems forming a triangle (antichain). For n=3, the structure should be richer.\n\n**Impact**: If true, this would reveal a deep connection between kinship classification and finite projective geometry, potentially providing a new perspective on the classification of simple matroids. If false, the failure mode would indicate where the analogy between kinship and geometry breaks down.\n\n**Catalog References**: `Bridges/ClosureProofNetDuality.lean` (lattice structures), `Bridges/CondensationSemantics.lean` (finite lattice theory)\n\n**Proof Strategy**: Formalize the refinement order on DreamtimeAlgebra pairs. Show it is a partial order. For (Z\u2082)\u00b2, explicitly compute the 3 unordered systems and verify they form an antichain (no refinement between them). For (Z\u2082)\u00b3, compute the Hasse diagram.\n\n**Domain Bridges**: Kinship Theory <-> Matroid Theory <-> Projective Geometry\n\n**Lineage**: Extends `kinshipSpectrum` and the spectrum counting theorems from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Kinship Codes \u2014 Binary Linear Codes from Dreamtime Algebras\n\n**Conjecture**: The kinship elements {0, \u03c3, \u03b4, \u03c3+\u03b4} of a Dreamtime algebra on (Z\u2082)\u207f form a [4, 2, 2] binary linear code (a code with 4 codewords, dimension 2, minimum distance 2). More generally, a Dreamtime algebra with k independent generators of order 2 gives a [2\u1d4f, k, 2] code, and the minimum distance of this code equals 2 \u2014 corresponding to the fact that every kinship operation changes exactly one coordinate.\n\n**Test**: Compute the weight distribution of the kinship elements for the Kariera system (on Z\u2082\u00b2) and the full kinship subgroup for the Aranda system (on Z\u2082\u00b3). Verify the minimum Hamming distance is 2 in both cases. Check whether the dual code has interesting kinship-theoretic interpretation.\n\n**Impact**: If true, this establishes that Aboriginal kinship systems are literally error-correcting codes \u2014 the same mathematical structures used in telecommunications and data storage. This would be a striking example of convergent mathematical evolution. The dual code would correspond to a \"parity-check\" interpretation of kinship rules: certain linear combinations of kinship memberships must always sum to zero.\n\n**Catalog References**: `Bridges/EntropyBounds.lean` (coding bounds), `Cryptography/BerggrenDiophantineLattice.lean` (lattice structures)\n\n**Proof Strategy**: Define the kinship code as the image of the subgroup generated by kinship elements under the standard basis embedding. Compute weight enumerators. Apply the Singleton bound to show the minimum distance is exactly 2. Interpret the dual code.\n\n**Domain Bridges**: Kinship Theory <-> Coding Theory <-> Information Theory\n\n**Lineage**: Extends `kinshipElements`, `kinshipElements_add_closed`, and `kariera_kinship_exhaustive` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Temporal Dynamics \u2014 Kinship as Dynamical System\n\n**Conjecture**: The long-term dynamics of a kinship system \u2014 tracking how section assignments evolve across generations under marriage and descent \u2014 is a discrete dynamical system on the group G \u00d7 G (tracking both a person's section and their spouse's section). The orbit structure of this dynamical system is fully determined by the structure of the Klein four subgroup, and every orbit has length dividing 4.\n\n**Test**: Define the \"generational map\" F: G \u00d7 G \u2192 G \u00d7 G by F(g, h) = (g + \u03b4, h + \u03b4) (both partners' children). Track the orbit of (0, \u03c3) in the Kariera system. Compute orbit lengths for all initial pairs. Verify that all orbits have length 1, 2, or 4.\n\n**Impact**: If true, this would give a complete dynamical characterization of kinship systems and prove that kinship societies have a natural \"period\" of at most 4 generations \u2014 a prediction testable against anthropological data. The orbit structure would also connect to the representation theory of V\u2084.\n\n**Catalog References**: `Algebra/TransfiniteProofDynamics/Theorems.lean` (dynamical systems theory)\n\n**Proof Strategy**: Define the generational map. Show it is a translation on G \u00d7 G by the element (\u03b4, \u03b4). Compute its order using the order of \u03b4 in G \u00d7 G. Since \u03b4 has order 2 in G, (\u03b4, \u03b4) has order 2 in G \u00d7 G, so F\u00b2 = id. Hmm, this means all orbits have length \u2264 2, not 4. Refine the conjecture to include the marriage step: F(g) = (g + \u03b4, M(g + \u03b4)) = (g + \u03b4, g + \u03b4 + \u03c3). Now F\u00b2(g, h) = (g + 2\u03b4, g + 2\u03b4 + \u03c3) = (g, g + \u03c3) \u2014 still period 2! The conjecture may need refinement.\n\n**Domain Bridges**: Kinship Theory <-> Dynamical Systems <-> Ergodic Theory\n\n**Lineage**: Extends `alternating_generations` and `dreamtimeOp_involutive` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Categorical Kinship \u2014 The Category of Dreamtime Algebras\n\n**Conjecture**: The category **DreamAlg** of Dreamtime algebras (with morphisms being group homomorphisms preserving both generators) has an initial object (the Kariera system on Z\u2082\u00b2), binary products, and a natural forgetful functor to **FinAb** (finite abelian groups) that is faithful but not full.\n\n**Test**: Define morphisms between Dreamtime algebras as group homomorphisms f: G \u2192 G' with f(\u03c3) = \u03c3' and f(\u03b4) = \u03b4'. Verify that the Kariera-to-Aranda embedding is such a morphism. Check whether the product of two Dreamtime algebras is again a Dreamtime algebra. Determine whether the Kariera system is initial (is there a unique morphism from Kariera to every other Dreamtime algebra?).\n\n**Impact**: If true, this would place kinship theory in a categorical framework, enabling the application of categorical methods (limits, colimits, adjunctions) to the study of kinship. The initial object claim would mean the Kariera system is the \"simplest\" kinship system from which all others can be obtained.\n\n**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (categorical structures)\n\n**Proof Strategy**: Formalize `DreamtimeAlgebra.Hom` as a structure. Show `karieraToAranda` is a morphism. For the initial object claim, show that any Dreamtime algebra (G, \u03c3', \u03b4') admits a unique homomorphism from (Z\u2082\u00b2, (1,0), (0,1)) by sending (1,0) \u21a6 \u03c3' and (0,1) \u21a6 \u03b4'. This is the universal property of the free abelian group Z\u2082\u00b2.\n\n**Domain Bridges**: Kinship Theory <-> Category Theory <-> Universal Algebra\n\n**Lineage**: Extends `karieraToAranda`, `karieraToAranda_preserves_marry`, `karieraToAranda_preserves_descent` from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0704",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6abf238d",
    "status": "available",
    "timestamp": "2026-06-05T09:43:45.917442+00:00",
    "title": "**Dreamtime algebra** \u2014 a finite abelian group equippe"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Spectral Phase Transitions in Constraint Satisfaction\n\n## Synthesis\n\nThis research cycle introduced the **Density-Indexed Spectral Filtration** (DISF), a novel mathematical structure that parameterizes families of Markov chains by constraint density and captures spectral gap evolution in constraint satisfaction problems. The key insight is that the spectral gap \u2014 measuring how quickly a random walk on the solution space mixes \u2014 undergoes a phase transition at the density where the solution count drops to unity. We proved 16 theorems establishing the foundations: Dirichlet energy nonnegativity (establishing the DISF as a valid seminorm), detailed balance implying stationarity, doubly stochastic chains having uniform stationary distributions, and the phase transition theorem showing that spectral gap vanishes at the uniqueness threshold.\n\nThe most promising cross-domain connection is between **Markov chain spectral theory** and **random graph coloring**. Our proof that Latin square completion maps to Rook's graph coloring (constraint degree = 2(n-1)) means that decades of results on graph coloring phase transitions \u2014 particularly the Achlioptas-Naor threshold \u2014 translate directly to spectral gap analysis. This bridge connects our work to `Bridges/WreathPressure.lean` (phase transition transfer) and `Computation/QuantumWalkCayley.lean` (mixing time bounds). The highest breakthrough potential lies in Direction 1 (Cheeger inequality for constraint graphs), which would provide the first quantitative lower bound on spectral gap in terms of graph-theoretic expansion \u2014 turning our qualitative phase transition result into a quantitative tool.\n\n---\n\n### Direction 1: Cheeger Inequality for Constraint Graph Spectral Gaps\n\n**Conjecture**: For a Density-Indexed Spectral Filtration with solution graph G(k) at k filled cells, the spectral gap \u03b3(k) satisfies the discrete Cheeger inequality:\n\n$$h(G(k))^2 / 2 \\leq \\gamma(k) \\leq 2 \\cdot h(G(k))$$\n\nwhere h(G) is the edge expansion (Cheeger constant) of the solution graph. Specifically, for Latin square completion on n\u00d7n grids, we conjecture h(G(k)) ~ (n-k/n\u00b2)^{1/2} for k below the critical density.\n\n**Test**: For 4\u00d74 Latin squares, explicitly construct the solution graph for k = 0, 2, 4, 6, 8 filled cells. Compute both the spectral gap (via eigenvalue computation of the transition matrix) and the Cheeger constant (via edge expansion computation). Verify the Cheeger inequality h\u00b2/2 \u2264 \u03b3 \u2264 2h holds in each case, and check whether h scales as predicted.\n\n**Impact**: If true, this provides the first *quantitative* relationship between solution graph topology and mixing time for constraint satisfaction Markov chains. It would transform the DISF from a qualitative framework into a predictive tool: given the graph structure, predict the mixing time. If false, the failure mode reveals what additional structure (beyond expansion) governs mixing in constraint spaces.\n\n**Catalog References**: `Tropical/MixingTheory.lean` (two-state spectral gap bound), `Computation/QuantumWalkCayley.lean` (mixing time spectral bound), `Bridges/WreathPressure.lean` (phase transition transfer)\n\n**Proof Strategy**:\n1. Formalize the Cheeger constant h(G) for finite graphs as the minimum edge-to-vertex ratio over all cuts.\n2. Prove the easy direction \u03b3 \u2264 2h (follows from constructing a test function for the variational characterization).\n3. Prove the hard direction h\u00b2/2 \u2264 \u03b3 using the sweep-cut technique: sort vertices by a near-optimal eigenfunction and find a good cut.\n4. Instantiate for the Latin square solution graph.\n\n**Domain Bridges**: Spectral graph theory \u2194 Markov chain mixing \u2194 Constraint satisfaction complexity\n\n**Lineage**: Builds on `dirichlet_energy_nonneg`, `spectral_gap_zero_bound`, and the DISF structure from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Quantum Spectral Gap and Topological Order in Constraint Systems\n\n**Conjecture**: The DISF extends naturally to quantum constraint satisfaction: define a quantum DISF where the solution space is a Hilbert space, the Markov chain is replaced by a Lindbladian, and the spectral gap of the Lindbladian exhibits a topological phase transition. Specifically, for quantum Latin squares (unitary error bases), the quantum spectral gap \u03b3_Q satisfies \u03b3_Q \u2265 \u03b3_classical / dim(H), where dim(H) is the Hilbert space dimension.\n\n**Test**: For 2\u00d72 quantum Latin squares (which correspond to the Pauli group), explicitly compute the Lindbladian spectral gap and compare with the classical spectral gap of 2\u00d72 Latin squares. If \u03b3_Q \u2265 \u03b3_cl/4 (dim = 4 for 2-qubit systems), the bound holds.\n\n**Impact**: If true, this would connect the DISF to quantum error correction: the spectral gap of the Lindbladian governs the lifetime of quantum memories, and the phase transition would correspond to the error threshold. This bridges constraint satisfaction to topological quantum computing. If false, the gap between quantum and classical mixing has a different scaling, which would be interesting in its own right.\n\n**Catalog References**: `Computation/QuantumWalkCayley.lean` (quantum walk spectral bound), `EML/EMLQuantumHybrid.lean` (Grover search and solution counting)\n\n**Proof Strategy**:\n1. Define quantum Markov kernel as a completely positive trace-preserving (CPTP) map.\n2. Define quantum Dirichlet energy using the KMS inner product.\n3. Prove the quantum Poincar\u00e9 inequality.\n4. Establish the classical-quantum comparison bound.\n\n**Domain Bridges**: Quantum information \u2194 Markov chain theory \u2194 Constraint satisfaction \u2194 Topological order\n\n**Lineage**: Builds on DISF structure and `mixing_time_spectral_bound` from Computation.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Spectral Gap Universality Exponent via Renormalization\n\n**Conjecture**: The critical exponent \u03bd in \u03b3(d) ~ C\u00b7(1-d/d_c)^\u03bd satisfies \u03bd = 1 for all n\u00d7n Latin square systems with n \u2265 4. Furthermore, the prefactor C_n scales as C_n ~ n^{-2} \u00b7 (n!)^{1/n}.\n\n**Test**: Enumerate all 4\u00d74 Latin squares (576 total). For each partial assignment density d \u2208 {0, 0.1, 0.2, ..., 0.9}, compute the average spectral gap. Fit \u03b3(d) = C\u00b7(1-d/d_c)^\u03bd and extract \u03bd. Repeat for 5\u00d75 Latin squares (161,280 total) and compare \u03bd values.\n\n**Impact**: Confirming \u03bd = 1 would place Latin square completion in the mean-field universality class, alongside the Curie-Weiss model and Erd\u0151s-R\u00e9nyi random graphs. This would be a deep connection between combinatorics and statistical mechanics. Refuting it (\u03bd \u2260 1) would suggest a novel universality class specific to constraint satisfaction.\n\n**Catalog References**: `Novelty/SudokuSpectral/Defs.lean` (DISF structure), `Novelty/SudokuSpectral/Theorems.lean` (mean_field_is_linear)\n\n**Proof Strategy**:\n1. Use the renormalization group approach: coarse-grain the Latin square solution space by identifying equivalent configurations under row/column permutations.\n2. Show the spectral gap is invariant under renormalization up to a scaling factor.\n3. Derive the critical exponent from the fixed point of the renormalization flow.\n4. Use the Rook's graph \u2194 Latin square bridge to leverage known results on graph coloring thresholds.\n\n**Domain Bridges**: Statistical mechanics \u2194 Combinatorics \u2194 Spectral theory \u2194 Renormalization group\n\n**Lineage**: Builds on `mean_field_is_linear`, `sudoku_critical_in_unit`, and the DISF structure.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Multi-Scale Spectral Filtration for Hierarchical CSPs\n\n**Conjecture**: For hierarchical constraint systems (e.g., Sudoku = Latin square + box constraints), the spectral gap decomposes multiplicatively:\n\n$$\\gamma_{total} = \\gamma_{row} \\cdot \\gamma_{col} \\cdot \\gamma_{box}$$\n\nwhere each factor captures the spectral gap contribution from one constraint type. This \"spectral factorization\" holds when the constraint types are sufficiently independent.\n\n**Test**: For 4\u00d74 Sudoku (4\u00d74 grid with 2\u00d72 boxes), compute the spectral gap of the full constraint system and compare with the product of spectral gaps from row constraints alone, column constraints alone, and box constraints alone. If \u03b3_total \u2248 \u03b3_row \u00b7 \u03b3_col \u00b7 \u03b3_box (within 10%), the conjecture is supported.\n\n**Impact**: If true, spectral factorization would dramatically simplify spectral gap computation for complex CSPs: instead of analyzing one large Markov chain, analyze several smaller ones independently. This has implications for algorithm design (parallel solvers exploiting spectral independence) and complexity theory (reduction of mixing time analysis to component analysis).\n\n**Catalog References**: `Novelty/SudokuSpectral/Defs.lean` (DISF), `Tropical/MixingTheory.lean` (mixing theory)\n\n**Proof Strategy**:\n1. Define a tensor product structure on solution spaces corresponding to independent constraint types.\n2. Prove that if constraints are \"spectrally independent\" (in the sense of Anari-Liu-Oveis Gharan), the spectral gaps multiply.\n3. Show that row, column, and box constraints in Sudoku are approximately spectrally independent.\n4. Bound the error term from constraint interactions.\n\n**Domain Bridges**: Tensor products \u2194 Spectral theory \u2194 Constraint satisfaction \u2194 Parallel algorithms\n\n**Lineage**: Builds on DISF structure and `gap_solution_product_bound`.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Entropy-Spectral Gap Duality\n\n**Conjecture**: For a DISF with solution count S(k), the spectral gap \u03b3(k) and the log-solution-count (entropy) H(k) = ln S(k) satisfy a duality relation:\n\n$$\\gamma(k) \\cdot H(k) \\leq C \\cdot \\frac{dH}{dk}$$\n\nwhere dH/dk is the discrete derivative (information lost per constraint added). This \"entropy-spectral duality\" says that fast mixing (large \u03b3) and large solution space (large H) together imply rapid information loss (large |dH/dk|).\n\n**Test**: For 4\u00d74 Latin squares, compute H(k) = ln(number of completions) and \u03b3(k) for k = 0, 1, ..., 16. Compute the ratio \u03b3(k)\u00b7H(k)/(H(k)-H(k+1)) and check whether it is bounded by a constant C independent of k.\n\n**Impact**: If true, this provides an information-theoretic characterization of spectral gap: the spectral gap measures the \"rate of information loss\" per constraint. This connects constraint satisfaction to channel capacity in information theory, potentially yielding new bounds on SAT/UNSAT thresholds. If false, the failure reveals that mixing speed and information loss are not simply related, which would constrain information-theoretic approaches to CSP analysis.\n\n**Catalog References**: `Novelty/SudokuSpectral/Theorems.lean` (mixing_time_nonneg), `Bridges/WreathPressure.lean` (phase transition transfer)\n\n**Proof Strategy**:\n1. Express the spectral gap in terms of the Dirichlet energy and variance.\n2. Use the entropy-energy inequality (relating log-Sobolev to Dirichlet form).\n3. Bound the log-Sobolev constant in terms of the discrete derivative of H(k).\n4. Combine to get the duality relation.\n\n**Domain Bridges**: Information theory \u2194 Spectral theory \u2194 Constraint satisfaction \u2194 Statistical mechanics\n\n**Lineage**: Builds on `dirichlet_energy_nonneg`, `mixing_time_nonneg`, and the DISF structure.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0715",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d537b4f5",
    "status": "available",
    "timestamp": "2026-06-05T11:33:38.545225+00:00",
    "title": "**Density-Indexed Spectral Filtration** (DISF"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Ramanujan Oracle Non-Computability\n\n## Synthesis\n\nThis research cycle established that the space of \"Ramanujan oracles\" \u2014 functions predicting mathematical truth with \u226595% accuracy \u2014 is uncountably large and therefore generically non-computable. The key technique was the *sparse embedding*, which injects the entire Cantor space \u2115 \u2192 Bool into the set of accurate oracles by scattering arbitrary bits among correct answers at controlled density. This simple construction yielded surprisingly deep consequences: uncountability of the oracle set, parametric robustness across all accuracy thresholds, exponential counting bounds connecting to proof complexity, and strict oracle hierarchies modeling the arithmetic hierarchy.\n\nThe most promising cross-domain connection is the bridge between **oracle information content** and **proof search complexity**. Both are governed by the same counting principle: exponential growth of valid objects (accurate oracles / provable theorems) forces any description system (algorithm / proof system) to use \u03a9(n) bits/symbols. This suggests a unified information-theoretic framework for mathematical unprovability and non-computability, where the same entropy bounds constrain both proof search and oracle construction. The `proof_length_counting_bound` from `Bridges/ProofSearchComplexity.lean` and our `accurate_oracle_exponential_lower_bound` are dual manifestations of a single phenomenon.\n\nThe highest breakthrough potential lies in Direction 1 (Measure-Theoretic Oracle Non-Computability), which would upgrade our cardinality result to a measure-theoretic one: not just \"most\" oracles are non-computable, but a *randomly chosen* oracle is non-computable with probability 1. This would connect to algorithmic randomness and Martin-L\u00f6f randomness, opening a bridge between computability theory and probability/ergodic theory.\n\n---\n\n### Direction 1: Measure-Theoretic Oracle Non-Computability\n\n**Conjecture**: Under the uniform (coin-flip) probability measure on Cantor space \u2115 \u2192 Bool, the set of Ramanujan oracles that are computable has measure zero. More precisely: for any truth assignment t with positive lower density of 1s and 0s, the probability that a uniformly random function is both (a) a Ramanujan oracle for t and (b) computable is zero. In fact, the set of Ramanujan oracles itself should have positive measure (since random functions have accuracy \u2248 50%, well below 95% \u2014 so this requires careful analysis of which truth assignments admit positive-measure oracle sets).\n\n**Test**: (1) Compute the measure of {g : \u2115 \u2192 Bool | sparseEmbed(t, g) is Ramanujan} under the product measure \u2014 this should be 1 since sparseEmbed always produces Ramanujan oracles. (2) Show that the image of this injection under the sparse embedding has measure zero in the full oracle space, but is still uncountable. (3) Investigate whether a \"thickened\" embedding (using density 1/21 at random positions rather than fixed multiples) has positive measure.\n\n**Impact**: If true, this upgrades non-computability from a cardinality result to a probabilistic one, making it relevant to statistical learning theory and random oracle models in cryptography. If false (the oracle set has measure zero for all truth assignments), this reveals that Ramanujan oracles are not just non-computable but also \"rare\" in a measure-theoretic sense, which has different philosophical implications.\n\n**Catalog References**: `Bridges/ProofSearchComplexity.lean` (proof_length_counting_bound), `Speculative/RamanujanOracle.lean` (ramanujan_set_uncountable)\n\n**Proof Strategy**: Use the Borel-Cantelli lemma on the coin-flip measure space {0,1}^\u2115. The key step is bounding the probability that a random function achieves \u226595% accuracy on [0,n) for all large n simultaneously. By Hoeffding's inequality, P(accuracy \u2265 95% on [0,n)) decays exponentially in n for random functions (assuming the truth assignment has \u224850% density). The intersection over all n gives probability 0. For computable oracles specifically, use the fact that computable functions form a countable set and any countable set has measure zero under the product measure.\n\n**Domain Bridges**: Computability \u2194 Probability/Measure Theory, connecting algorithmic randomness (Martin-L\u00f6f, Schnorr) to oracle construction.\n\n**Lineage**: Builds on `ramanujan_set_uncountable` and `accurate_oracle_exponential_lower_bound` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Kolmogorov Complexity of Ramanujan Oracles\n\n**Conjecture**: Any Ramanujan oracle o for a truth assignment t of high Kolmogorov complexity satisfies K(o\u21ben) \u2265 n/21 \u2212 O(log n) for infinitely many n, where o\u21ben is the restriction to the first n values. That is, accurate oracles for complex truth assignments must themselves be algorithmically complex.\n\n**Test**: (1) Formalize the Kolmogorov complexity function K in Lean (as a partial function or using a fixed universal Turing machine). (2) Prove the lower bound using the counting argument: there are \u2265 2^(n/21) accurate behaviors on n inputs, so by the pigeonhole principle, at least one needs K \u2265 n/21. (3) Show that this lower bound is tight: exhibit truth assignments where K(o\u21ben) = O(n/21).\n\n**Impact**: If true, establishes that Ramanujan oracles carry irreducible algorithmic information, connecting to the incompressibility method in combinatorics. This would bridge computability theory to information theory and data compression, showing that mathematical intuition has a minimum \"bandwidth\" requirement.\n\n**Catalog References**: `Speculative/RamanujanOracle.lean` (accurate_oracle_exponential_lower_bound), `Physics/ProofSearchInformation.lean` (proof_length_log_lower_bound)\n\n**Proof Strategy**: The counting argument gives the existential bound: among 2^(n/21) accurate behaviors, at most 2^k have K \u2264 k, so some has K \u2265 n/21. For the universal bound (for all oracles, not just some), use the sparse embedding: any Ramanujan oracle o determines g via g(k) = o(21k), and K(g\u21bem) \u2265 m \u2212 O(1) for Kolmogorov-random g. Since most g are random, most Ramanujan oracles have high complexity.\n\n**Domain Bridges**: Computability \u2194 Information Theory, connecting oracle non-computability to Shannon entropy and Kolmogorov complexity.\n\n**Lineage**: Builds on `accurate_oracle_exponential_lower_bound` and the information-theoretic interpretation developed in this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Oracle-Relativized Proof Complexity\n\n**Conjecture**: Given access to a Ramanujan oracle (as an axiom scheme \"o(n) = true\" for each n), the proof complexity of number-theoretic theorems drops by at most a polynomial factor. Specifically: if a statement \u03c6 requires proof of length L in Peano Arithmetic, then with oracle access, it requires proof of length \u2265 L/poly(|\u03c6|). The oracle helps, but cannot exponentially compress proofs.\n\n**Test**: (1) Define an oracle-relativized proof system PA(o) where oracle outputs can be used as axioms. (2) Show that for \"generic\" oracles (in the Baire category sense), the speedup over PA is bounded. (3) Exhibit specific statements where the oracle provides exactly polynomial speedup.\n\n**Impact**: If true, this shows that even non-computable mathematical intuition cannot circumvent proof complexity barriers \u2014 a negative result that connects computability to proof complexity. If false (exponential speedup is possible), this identifies specific structural properties of truth that make some statements dramatically easier with the right oracle, opening applications to proof automation.\n\n**Catalog References**: `Bridges/ProofSearchComplexity.lean` (proof_length_counting_bound), `Logic/SpectralProofSpace.lean` (expansion_proof_length_bound), `FINAL/Bridges/UniversalComplexityBarriers.lean` (oracle_tower_non_collapse)\n\n**Proof Strategy**: Model oracle-relativized proofs as standard proofs augmented with oracle queries. Each query reduces the search space by at most a constant factor (the oracle answers one bit). After k queries, the remaining search space has 2^(L\u2212k) possibilities. For polynomial speedup, show k \u2264 poly(|\u03c6|) using the structure of PA proofs. The key lemma is that most steps in a PA proof are \"local\" (depending on nearby formulas) and cannot be shortcut by global oracle information.\n\n**Domain Bridges**: Computability \u2194 Proof Complexity, bridging the oracle non-computability results to structural proof theory and the P vs NP landscape.\n\n**Lineage**: Builds on `oracle_hierarchy_exists` and the bridge to `proof_length_counting_bound` established in this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Topological Structure of the Ramanujan Oracle Set\n\n**Conjecture**: The set of Ramanujan oracles, viewed as a subset of Cantor space with the product topology, is a dense G_\u03b4 set (intersection of countably many open sets) when the truth assignment has certain regularity properties (e.g., positive density of both true and false statements). Alternatively, it may be a meager (first category) set despite being uncountable.\n\n**Test**: (1) Show the set is G_\u03b4 by writing IsRamanujanOracle as \u2200 n \u2265 N, errors(n) \u00d7 20 \u2264 n, which is a countable intersection of clopen conditions. (2) Determine whether the set is dense: does every basic open set (fixing finitely many values) contain a Ramanujan oracle? (3) Apply the Baire category theorem to establish topological genericity results.\n\n**Impact**: If the Ramanujan oracle set is residual (complement of meager), then Ramanujan oracles are \"topologically generic\" \u2014 a stronger form of abundance than mere uncountability. This would parallel the topological genericity of nowhere-differentiable continuous functions or of transcendental numbers.\n\n**Catalog References**: `Speculative/RamanujanOracle.lean` (ramanujan_set_uncountable, sparseEmbed_is_ramanujan)\n\n**Proof Strategy**: The condition \"errors on [0,n) \u2264 n/20\" is a closed condition in Cantor space (it depends on finitely many coordinates). The Ramanujan condition is \u2200 n \u2265 N, which is a countable intersection of closed sets, hence G_\u03b4. For density, given any finite prefix, extend it using the sparse embedding strategy to produce a Ramanujan oracle with that prefix. For meagerness/residuality, compare with the full Cantor space using Baire category arguments.\n\n**Domain Bridges**: Computability \u2194 Topology, connecting oracle theory to descriptive set theory and the Baire hierarchy.\n\n**Lineage**: Builds on `ramanujan_set_uncountable` and the sparse embedding construction from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Ramanujan Oracles for Specific Theories\n\n**Conjecture**: For the theory of true arithmetic (Th(\u2115)), every Ramanujan oracle computes the Turing jump 0\u2032 (the halting problem). More precisely: if o is a Ramanujan oracle for a standard encoding of arithmetic sentences where undecidable sentences have density > 5%, then 0\u2032 \u2264_T o (the halting problem is Turing-reducible to o).\n\n**Test**: (1) Formalize a specific encoding of arithmetic sentences as natural numbers. (2) Show that the set of true \u03a3\u2081 sentences has computable complement (they're c.e.), so a Ramanujan oracle that's mostly right on \u03a3\u2081 sentences must be right on \"most\" \u03a3\u2081 instances. (3) Use the fact that being right on most instances of a c.e. set computes the set itself (by majority decoding), showing 0\u2032 \u2264_T o.\n\n**Impact**: If true, this pins down the exact computational power needed for mathematical intuition: at minimum, the halting problem. Combined with the hierarchy theorem, this suggests Ramanujan's intuition operated at or above the level of the Turing jump \u2014 a precise characterization of \"non-computable mathematical insight.\" If false, it reveals that high accuracy doesn't require solving the halting problem, which would be surprising and informative.\n\n**Catalog References**: `Speculative/RamanujanOracle.lean` (oracle_hierarchy_exists, ramanujan_exceeds_candidates), `Computation/GravityOracle.lean` (IsGravOracle, geodesic_oracle_idempotent)\n\n**Proof Strategy**: Encode \u03a3\u2081 sentences \u03c6_e = \"program e halts\" with known density properties. A Ramanujan oracle correct on \u226595% of these sentences, with undecidable density >5%, must be correct on at least some undecidable instances. Construct a Turing reduction: to decide whether e \u2208 0\u2032, query the oracle on \u03c6_e. If the oracle says \"true,\" accept with high confidence. Use error-correction (query multiple related sentences and take majority) to boost confidence to certainty.\n\n**Domain Bridges**: Computability \u2194 Number Theory, connecting abstract oracle non-computability to the concrete arithmetic hierarchy and specific number-theoretic decision problems.\n\n**Lineage**: Builds on `oracle_hierarchy_exists` and `ramanujan_exceeds_candidates` from this cycle.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_0727",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "ec6dd6b1",
    "status": "available",
    "timestamp": "2026-06-05T14:57:34.680873+00:00",
    "title": "That the space of \"Ramanujan oracles\" \u2014 function"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Voice Leading Algebras and Counterpoint Category Theory\n\n## Synthesis\n\nThis research cycle established the **Voice Leading Algebra** (VLA) as a novel parameterized algebraic structure that captures counterpoint rules over arbitrary cyclic groups \u2124/n\u2124. The central discovery \u2014 the **Counterpoint Obstruction Theorem** \u2014 proves that valid voice leadings are not closed under composition, definitively refuting the conjecture that first-species counterpoint forms a category in the naive sense. This negative result is highly informative: it tells us that the correct categorical framework is the *path category* on the valid-transition quiver, where morphisms are sequences of individually valid steps rather than single voice leadings.\n\nThe most promising cross-domain connection from this cycle links the VLA framework to the **Knuth-Bendix completion** results in `FINAL/Bridges/KnuthBendixCompletion.lean`. The counterpoint rules define a non-confluent rewriting system on interval transitions, and the obstruction theorem shows this system cannot be completed to a category. This parallels situations in term rewriting where no finite completion exists \u2014 suggesting that the VLA framework could serve as a testing ground for completion-theoretic phenomena. The **inversion asymmetry** result (the perfect fifth as the unique consonance breaking octave-complement symmetry) also connects naturally to the Pythagorean harmonic theory in `FINAL/Pythagorean/HarmonicMusicTheory.lean`, potentially enabling a bridge between frequency-ratio and group-theoretic approaches to consonance.\n\nThe highest breakthrough potential lies in **Direction 1** (Microtonal VLA Classification), which would extend the framework from 12-TET to arbitrary equal temperaments. Since the VLA is parameterized over \u2124/n\u2124, the machinery is already in place for a systematic study \u2014 and the results could reveal which tuning systems produce the richest algebraic structure for polyphonic music.\n\n---\n\n### Direction 1: Microtonal VLA Classification\n\n**Conjecture**: For every $n \\geq 7$, there exists a \"natural\" consonant set $C_n \\subset \\mathbb{Z}/n\\mathbb{Z}$ (defined by approximation to just-intonation ratios 3/2, 4/3, 5/4, 6/5, 5/3, 8/5) such that the VLA $(C_n, P_n, n)$ satisfies the Counterpoint Obstruction if and only if $|P_n| \\geq 1$ and $|C_n \\setminus P_n| \\geq 1$.\n\n**Test**: Compute the natural consonant sets for $n = 7, 12, 19, 24, 31, 41, 53$ (historically important tuning systems) and verify or refute the obstruction in each case. For $n = 19$, the consonant set approximating just intonation is approximately $\\{0, 5, 6, 11, 13, 14\\}$ \u2014 verify that the VLA over \u2124/19\u2124 with these parameters satisfies the obstruction.\n\n**Impact**: If true, this would establish a universal algebraic principle: polyphonic music in *any* sufficiently rich tuning system necessarily resists naive categorification. The boundary case ($|P_n| = 0$) would identify tuning systems where counterpoint *is* algebraically compositional \u2014 these would be musically novel.\n\n**Catalog References**: `FINAL/Pythagorean/HarmonicMusicTheory.lean` (consonant intervals), `Novelty/Counterpoint/Basic.lean` (VLA definition)\n\n**Proof Strategy**: Generalize the concrete obstruction proof (Theorem 3.1) by abstracting the witness construction. The key lemma: if there exist $p \\in P$ and $q \\in C \\setminus P$ with $p \\neq q$ and $q - p + q - p = 0$ (mod n) or similar arithmetic conditions, then the obstruction holds. Reduce to a number-theoretic condition on $n$, $C$, and $P$.\n\n**Domain Bridges**: Music theory <-> number theory <-> category theory. The consonant-set construction bridges acoustics (frequency ratios) with algebra (cyclic groups).\n\n**Lineage**: Extends the Counterpoint Obstruction Theorem and VLA framework from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: The Path Category Homology\n\n**Conjecture**: The path category of the standard 12-TET counterpoint quiver has non-trivial first homology (as a small category with a classifying space). Specifically, $H_1(B\\mathcal{C}) \\cong \\mathbb{Z}^k$ for some $k \\geq 2$, where $\\mathcal{C}$ is the free category on the counterpoint quiver.\n\n**Test**: Compute the fundamental group $\\pi_1(B\\mathcal{C})$ by finding a presentation of the quiver's cycle space. The counterpoint quiver on 6 vertices is a directed graph; its cycle space modulo the ideal generated by the forbidden edges determines the homology.\n\n**Impact**: Non-trivial homology would mean that counterpoint has \"topological holes\" \u2014 voice leading sequences that cannot be continuously deformed into each other while remaining valid. This would give a rigorous mathematical meaning to the musical intuition that certain voice-leading paths are \"essentially different.\"\n\n**Catalog References**: `FINAL/Bridges/KnuthBendixCompletion.lean` (rewriting systems), `Novelty/Counterpoint/Theorems.lean` (connectivity)\n\n**Proof Strategy**: (1) Compute the full adjacency structure of the counterpoint quiver (6 objects, up to 144 edges minus forbidden ones). (2) Find a spanning tree. (3) The remaining edges generate $\\pi_1$. (4) Compute relations from the quiver structure. (5) Abelianize to get $H_1$.\n\n**Domain Bridges**: Algebraic topology <-> music theory <-> combinatorics. The classifying space construction bridges category theory with topology.\n\n**Lineage**: Extends the strong connectivity result and the quiver structure from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tension-Monotone Voice Leading\n\n**Conjecture**: Define a voice leading $v$ from interval $i$ to interval $j$ as \"resolving\" if $\\tau(j) \\leq \\tau(i)$ (tension decreases or stays equal). Then the set of resolving valid voice leadings forms a *preorder* (i.e., IS closed under composition), unlike the full set of valid voice leadings.\n\n**Test**: Verify computationally: enumerate all pairs of resolving valid voice leadings from the 12-TET VLA and check whether their composition is always resolving and valid. If a counterexample exists, it refutes the conjecture.\n\n**Impact**: If true, this would show that the obstruction to categorification disappears when we restrict to \"resolution\" \u2014 musically meaningful downward motion in the tension hierarchy. The resolving voice leadings would form a genuine category, providing the \"well-behaved\" algebraic fragment of counterpoint. This would bridge order theory (monotone maps) with music theory (resolution).\n\n**Catalog References**: `Novelty/Counterpoint/Basic.lean` (tensionRank), `Novelty/Counterpoint/Theorems.lean` (tension_injective_on_consonant)\n\n**Proof Strategy**: The key issue is whether the composition of two tension-decreasing voice leadings remains tension-decreasing. Since tension rank takes values in \u2115 and the composition changes the interval, we need to track how $\\tau(v_2(v_1(i)))$ relates to $\\tau(v_1(i))$ and $\\tau(i)$. The transitivity of \u2264 handles the tension part; the validity part requires checking the parallel-perfects condition.\n\n**Domain Bridges**: Order theory <-> music theory <-> category theory.\n\n**Lineage**: Extends the tension rank analysis and the obstruction theorem from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Counterpoint as a Non-Unital Magma\n\n**Conjecture**: The set of all valid voice leadings (as pairs $(i, v)$ where $i$ is the source interval) forms a non-unital magma under a modified composition that \"aborts\" (maps to a distinguished failure element) when the parallel-perfects rule would be violated. This magma has a non-trivial ideal structure.\n\n**Test**: Formalize the magma structure in Lean 4. Prove that the set of \"always-valid\" voice leadings (those that are valid from every consonant interval) forms a sub-magma. Compute its cardinality.\n\n**Impact**: This provides an alternative algebraic framework to the path category: instead of composing sequences, we compose voice leadings with a partial operation. The ideal structure would classify which voice leadings are \"safe\" (composable without restriction) vs. \"dangerous\" (potentially creating parallel perfects).\n\n**Catalog References**: `Novelty/Counterpoint/Basic.lean` (VoiceLeading.comp, ValidVL)\n\n**Proof Strategy**: Define the magma operation as $v_1 \\star v_2 = v_1 \\circ v_2$ if valid, $\\bot$ otherwise. Show this is well-defined. Identify the ideal $I = \\{v : \\forall w, v \\star w \\neq \\bot \\text{ and } w \\star v \\neq \\bot\\}$. Compute $|I|$.\n\n**Domain Bridges**: Abstract algebra (magma theory) <-> music theory.\n\n**Lineage**: Extends the non-compositionality result from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Spectral Analysis of the Counterpoint Adjacency Matrix\n\n**Conjecture**: The adjacency matrix $A$ of the counterpoint quiver (6\u00d76, with $A_{ij}$ = number of valid voice leadings from consonant interval $i$ to $j$) has spectral gap $\\lambda_1 - \\lambda_2 \\geq n/3$ where $n = 12$ and $\\lambda_1, \\lambda_2$ are the two largest eigenvalues. This spectral gap controls the mixing time of random walks on the counterpoint quiver.\n\n**Test**: Compute the adjacency matrix explicitly by enumerating valid voice leadings for each pair $(i, j)$. Diagonalize over \u211d. Compute the spectral gap.\n\n**Impact**: A large spectral gap would mean that random voice leading sequences converge quickly to a stationary distribution \u2014 musically, this would imply that \"random counterpoint\" rapidly loses memory of its starting interval. A small gap would indicate persistent tonal memory.\n\n**Catalog References**: `FINAL/Computation/SpectralProofComplexity.lean` (spectral methods), `Novelty/Counterpoint/Basic.lean` (validVLSet)\n\n**Proof Strategy**: (1) Build the 6\u00d76 matrix by computing $|validVLSet(i, j)|$ for all pairs. (2) Use Lean's matrix library or computational verification to find eigenvalues. (3) Establish the spectral gap bound. This is primarily computational.\n\n**Domain Bridges**: Spectral graph theory <-> music theory <-> probability (random walks).\n\n**Lineage**: Extends the quiver structure and counting results from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0762",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "b9304a7a",
    "status": "available",
    "timestamp": "2026-06-05T21:12:13.255111+00:00",
    "title": "**Voice Leading Algebra** (VLA) as a novel p"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Transfinite Computation and Ordinal Cellular Automata\n\n## Synthesis\n\nThis research cycle established a rigorous mathematical framework for cellular automata indexed by ordinal time, proving that ordinal CAs form a strict computational hierarchy: \u03c9\u00b2 strictly exceeds \u03c9\u00b7n for all finite n, energy functions must stabilize (guaranteeing convergence), and monotone systems reach fixed points via the transfinite Knaster-Tarski theorem. The most promising cross-domain connection is between **ordinal computation** and **game theory**: the survival ordinal from the catalog's Mortal Eternity Game (`survival_ordinal_eq_omega`) measures exactly the same ordinal-indexed convergence phenomenon we proved for CAs. The energy stabilization theorem applies equally to game-theoretic strategies (where the \"energy\" is the game's ordinal complexity measure) and to CA dynamics (where the \"energy\" is a configuration measure).\n\nThe highest breakthrough potential lies in **Direction 1 (Strict Separation at \u03c9\u00b2)**, which would establish a concrete problem witnessing the computational gap between \u03c9-time and \u03c9\u00b2-time. This would be analogous to the halting problem witnessing the gap between finite time and \u03c9-time \u2014 a fundamental result in the theory of transfinite computation. The orbit cycling theorem (pigeonhole for finite orbits) provides the key tool: finite-state dynamics cycle within |S| steps, but the *interaction* between cells at different spatial positions can encode information that survives to higher ordinal levels.\n\nThe broader pattern emerging from this cycle is that **well-foundedness of ordinals** is a universal convergence engine. Whether the domain is cellular automata, infinite games, proof-theoretic consistency strength, or program semantics, the same ordinal descent argument guarantees termination. This suggests a deep unification theorem connecting all these domains through their ordinal-indexed convergence properties.\n\n---\n\n### Direction 1: Strict Computational Separation at \u03c9\u00b2\n\n**Conjecture**: There exists a decision problem P on binary sequences such that P is solvable by an ordinal CA at time \u03c9\u00b2 but not by any ordinal CA at time \u03c9\u00b7n for any finite n.\n\n**Test**: Define P as the \"iterated halting problem\" \u2014 given a sequence encoding a hierarchy of computations where each level's halting depends on detecting halting at the previous level. Formalize in Lean 4 that: (a) P is solvable at \u03c9\u00b2; (b) for each n, there is an instance of P not solvable at \u03c9\u00b7n. The key challenge is formalizing the encoding and proving the lower bound.\n\n**Impact**: This would be the ordinal CA analog of the Post-Turing theorem on the arithmetic hierarchy. It would show that the ordinal hierarchy is strict not just in ordinal arithmetic but in computational power. If false, it would mean \u03c9\u00b2 collapses to \u03c9\u00b7n for some n, which would be equally surprising.\n\n**Catalog References**: `no_infinite_descent_ordinal` (`Logic/TransfiniteRefinement.lean`), `survival_ordinal_eq_omega` (`Computation/MortalEternityGame.lean`)\n\n**Proof Strategy**: Define the problem P_k for each level k as \"does the k-th level computation halt?\" Show by induction that solving P_k requires exactly \u03c9\u00b7k time. Then P = \"for all k, P_k\" requires \u03c9\u00b7k for every k, hence \u03c9\u00b2 time. The lower bound uses a diagonalization argument: assume a CA solves P at time \u03c9\u00b7n, and construct an input that forces it to fail at level n+1.\n\n**Domain Bridges**: Computation <-> Logic (arithmetic hierarchy), Computation <-> Game Theory (ordinal game values)\n\n**Lineage**: Builds on energy_stabilization and omega_sq_exceeds_omega_times_n from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Ordinal Cellular Automata and Fixed-Point Semantics of Programs\n\n**Conjecture**: The least fixed point of any Scott-continuous function on a continuous lattice can be computed by an ordinal CA on \u03c9 steps, where the spatial dimension encodes the lattice structure and the limit rule computes directed suprema.\n\n**Test**: Formalize a correspondence between Scott-continuous functions on algebraic lattices and ordinal CAs. Prove that the \u03c9-time configuration of the CA equals the least fixed point. Test on the canonical example: the denotational semantics of a while-loop, where the fixed point gives the loop's meaning.\n\n**Impact**: This would bridge cellular automata theory with denotational semantics, showing that domain theory's Kleene chain is literally a cellular automaton evolution. It would provide a new computational model for program semantics and potentially new proof techniques for program correctness.\n\n**Catalog References**: `kleene_fixed_point` (this cycle), `Computation/GravityOracle.lean` (oracle structures)\n\n**Proof Strategy**: (1) Encode elements of the lattice as spatial configurations. (2) Define the CA rule so that stepConfig corresponds to one application of the Scott-continuous function on each finite approximation. (3) Prove that the limit rule (directed supremum) at \u03c9 gives the least fixed point. Use the continuity of the function to show that the Kleene chain's limit equals the least fixed point.\n\n**Domain Bridges**: Computation <-> Programming Language Theory (denotational semantics), Computation <-> Order Theory (continuous lattices)\n\n**Lineage**: Builds on kleene_fixed_point and kleeneChain from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Energy Stabilization in Infinite Games\n\n**Conjecture**: The survival ordinal of any finitely-branching game tree equals the ordinal at which an energy function (defined as the game-theoretic value) stabilizes under backward induction.\n\n**Test**: Formalize the connection between energy stabilization for ordinal CAs and backward induction for infinite games. Prove that if a game has survival ordinal \u03b1, then the backward induction energy function stabilizes at exactly \u03b1. Test on the Mortal Eternity Game from the catalog.\n\n**Impact**: This would unify two independently developed theories: ordinal CA convergence and ordinal game theory. The energy stabilization theorem would become a general tool for computing game values, and game-theoretic techniques would provide new ways to prove CA convergence bounds.\n\n**Catalog References**: `survival_ordinal_eq_omega` (`Computation/MortalEternityGame.lean`), `mortal_survival_ordinal_ge_omega` (`MachineLearning/InfiniteGames.lean`), `adversarial_achieves_bound` (`Computation/GradedDescentComplexity.lean`)\n\n**Proof Strategy**: (1) Define the energy function E(\u03b1) for a game position as the ordinal value of the position under \u03b1 steps of backward induction. (2) Show E is antitone (by the game's structure). (3) Apply energy_stabilization to get convergence. (4) Show the convergence ordinal equals the survival ordinal by comparing the definitions. The key lemma: a position's energy decreases exactly when the immortal player can force a non-trivial response.\n\n**Domain Bridges**: Computation <-> Game Theory (ordinal game values) <-> Logic (ordinal analysis of consistency)\n\n**Lineage**: Builds on energy_stabilization from this cycle and survival_ordinal_eq_omega from the catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Transfinite Cellular Automata on Ordinal Spatial Domains\n\n**Conjecture**: When both the spatial domain and time domain are ordinals, the resulting \"doubly transfinite\" CA exhibits a phase transition: for spatial domain \u03c9 with time \u03c9, the system is equivalent to standard ITTMs, but for spatial domain \u03c9\u00b2 with time \u03c9\u00b2, it strictly exceeds ITTMs in computational power.\n\n**Test**: Formalize CAs where the spatial cells are indexed by ordinals (not just \u2124). Define configurations as functions Ordinal \u2192 S with finite support. Prove that \u03c9-spatial, \u03c9-time CAs can simulate ITTMs. Then attempt to show that \u03c9\u00b2-spatial, \u03c9\u00b2-time CAs can solve problems undecidable by ITTMs.\n\n**Impact**: This would identify a new computational model that strictly exceeds ITTMs \u2014 a result that would be significant in computability theory. The phase transition at \u03c9\u00b2 would reveal the precise role of spatial dimension in transfinite computation.\n\n**Catalog References**: `computation_depth_at_limit` (this cycle), `omega0_sq_isSuccLimit` (this cycle), `Computation/GravityOracle.lean`\n\n**Proof Strategy**: For the ITTM simulation: encode the ITTM's tape as the spatial configuration, and simulate head movement by shifting information through cells. For the separation: use a diagonalization over ITTM computations, encoding the diagonalization as a spatial pattern that requires \u03c9\u00b2 cells to represent. The key difficulty is formalizing the notion of \"computational power\" for CAs on ordinal spatial domains.\n\n**Domain Bridges**: Computation <-> Set Theory (ordinal definability) <-> Model Theory (transfinite back-and-forth arguments)\n\n**Lineage**: Builds on limit_cofinal_access, omega0_sq_isSuccLimit, and the TransfiniteCA framework from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Tropical Fixed Points and Ordinal Min-Plus Automata\n\n**Conjecture**: The tropical semiring (\u211d \u222a {\u221e}, min, +) admits an ordinal Kleene chain that computes shortest paths, and the stabilization ordinal of this chain on a graph with n vertices is exactly n (the Bellman-Ford bound).\n\n**Test**: Define a \"tropical CA\" where the state space is \u211d \u222a {\u221e} with the min-plus operations. The local rule computes min(current, left + weight_left, right + weight_right). Prove that the Kleene chain converges in exactly n steps for an n-vertex graph, matching the classical Bellman-Ford algorithm.\n\n**Impact**: This would bridge transfinite computation theory with combinatorial optimization, showing that the Bellman-Ford algorithm is literally a Kleene chain on a tropical lattice. This connection is known informally but has never been formalized. It would also suggest new algorithms: what happens to shortest paths at ordinal time \u03c9 (detecting negative cycles)?\n\n**Catalog References**: `tropical_and_bound` (`Bridges/TropicalArithmeticCoding.lean`), `kleene_fixed_point` (this cycle)\n\n**Proof Strategy**: (1) Show (\u211d \u222a {\u221e}, min, +) is a complete lattice with \u22a5 = \u221e. (2) Define the tropical CA rule as one step of Bellman-Ford relaxation. (3) Prove the Kleene chain at step k gives shortest paths of length \u2264 k. (4) Prove convergence at step n by the absence of negative cycles. (5) At ordinal \u03c9, prove the limit detects negative cycles.\n\n**Domain Bridges**: Computation <-> Tropical Geometry <-> Combinatorial Optimization <-> Cryptography (tropical Diffie-Hellman from catalog)\n\n**Lineage**: Builds on kleene_fixed_point and energy_stabilization from this cycle, and tropical_and_bound from the catalog.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0774",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "8660cf0a",
    "status": "available",
    "timestamp": "2026-06-05T23:41:55.282529+00:00",
    "title": "Rigorous mathematical framework for cellular a"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Game of Life Universality and Cellular Automata\n\n## Synthesis\n\nThis research cycle established a comprehensive formal framework for Conway's Game of Life in Lean 4, proving the Light Cone Theorem (information propagation at speed \u2264 1), the Perturbation Principle (bounded effect of single-cell changes), simulation composition with multiplicative overhead, and universality via Turing machine simulation. The most significant cross-domain connection is the bridge between grid-based computation (GoL on \u2124\u00b2) and tree-based computation (Berggren CA on orbit lattices from `Pythagorean/BerggrenCA.lean`). This connection reveals a fundamental space-time tradeoff: trees achieve O(1) address depth but lack translation symmetry, while grids require O((D+T)\u00b2) space but support shift-equivariant computation.\n\nThe simulation composition theorem exposed a subtle requirement often overlooked in informal treatments: composing simulations requires not just commutation of decode with evolution, but faithfulness \u2014 that encoded states remain encoded after evolution. This insight has implications for any formalization of computational equivalence between models.\n\nThe highest breakthrough potential lies in Direction 1 (Garden of Eden / Moore-Myhill), which connects cellular automata to deep results in geometric group theory and could bridge to the existing algebraic infrastructure in the Catalog. Direction 3 (Entropy Dynamics) offers the most natural connection to tropical geometry and min-plus algebra already formalized in `Tropical/TropicalDeepResearch.lean`.\n\n---\n\n### Direction 1: Garden of Eden Theorem for Cellular Automata\n\n**Conjecture**: For any cellular automaton on \u2124^d with finite alphabet, the following are equivalent: (a) the global map is injective, (b) the global map is surjective, (c) every pattern that appears as a subpattern of some configuration also appears as a subpattern of the image of some configuration. This is the Moore-Myhill theorem.\n\nFormally: For GoL on \u2124\u00b2, there exist \"orphan\" configurations (Gardens of Eden) \u2014 configurations that cannot arise from any predecessor. Moreover, the GoL global map is not injective (proven by exhibiting two distinct configurations with the same successor), and hence by Moore-Myhill, it is not surjective.\n\n**Test**: Construct two explicit GoL configurations with the same successor (e.g., the all-dead configuration has multiple predecessors: itself and any configuration of isolated alive cells). Then formally verify the non-injectivity. For the full Moore-Myhill theorem, formalize the compactness argument using Tychonoff's theorem (available in Mathlib).\n\n**Impact**: If formalized, this would be the first machine-verified proof of the Moore-Myhill theorem, connecting cellular automata theory to topology (compactness arguments) and group theory (amenability). The theorem fails for CAs on non-amenable groups, so the proof inherently uses the structure of \u2124^d.\n\n**Catalog References**: `Novelty/GameOfLife/Theorems.lean` (GoL definitions), `MachineLearning/CellularAutomata/Defs.lean` (1D CA definitions)\n\n**Proof Strategy**:\n1. Define \"pre-image\" of a configuration and \"Garden of Eden\" (orphan).\n2. Prove GoL is not injective: exhibit two configs with the same successor.\n3. Use a compactness argument (via Tychonoff on the product topology of finite alphabets) to show non-injectivity implies non-surjectivity.\n4. The key lemma: if f is injective on finite restrictions, then f is injective globally (contrapositively, non-injectivity on finite restrictions implies non-surjectivity globally).\n\n**Domain Bridges**: Computation (cellular automata) <-> Topology (compactness) <-> Group Theory (amenability of \u2124^d)\n\n**Lineage**: Builds on GoL formalization from this cycle, extends the CA definitions in `MachineLearning/CellularAutomata/Defs.lean`.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Glider as Optimal Speed-of-Light Signal\n\n**Conjecture**: In Conway's Game of Life, the glider (the smallest spaceship) travels at the maximum possible speed: it translates by (1,1) every 4 steps, achieving an asymptotic speed of 1/\u221a2 in Euclidean metric but exactly 1/4 in Chebyshev metric. Moreover, no GoL pattern can translate faster than speed 1 (one Chebyshev cell per step) \u2014 this is a corollary of the Light Cone Theorem.\n\nSpecifically: if a GoL configuration cfg satisfies golIter(cfg, T) = translate(cfg, v), then chebyshevDist(0, v) \u2264 T.\n\n**Test**: Formalize the glider pattern {(0,1), (1,2), (2,0), (2,1), (2,2)} in Lean 4. Prove computationally (via native_decide or explicit enumeration) that golStep\u2074(glider) = translate(glider, (1,1)). Then prove the speed bound as a direct corollary of the Perturbation Principle.\n\n**Impact**: This would formally establish the \"speed of light\" as a tight bound in GoL, connecting the abstract Light Cone Theorem to a concrete GoL pattern. It would also be the first verified proof that the glider is a period-4 spaceship.\n\n**Catalog References**: `Novelty/GameOfLife/Theorems.lean` (Light Cone Theorem, Perturbation Principle), `Pythagorean/EmergentComputation.lean` (related universality)\n\n**Proof Strategy**:\n1. Define the glider configuration explicitly.\n2. Compute golStep\u2074(glider) explicitly (this is a finite computation on a small grid).\n3. Verify the translation property.\n4. For the speed bound: if golIter(cfg, T) = translate(cfg, v), then for any p \u2208 support(cfg), golIter(cfg, T)(p + v) = cfg(p + v) = alive if and only if cfg(p) = alive. Use the Light Cone Theorem to bound how far the support can shift.\n\n**Domain Bridges**: Computation (GoL dynamics) <-> Geometry (Chebyshev metric, translation groups)\n\n**Lineage**: Direct extension of Light Cone Theorem from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Entropy of Cellular Automata\n\n**Conjecture**: The topological entropy of the Game of Life, viewed as a dynamical system on {0,1}^{\u2124\u00b2} with the product topology, can be bounded using tropical (min-plus) techniques. Specifically, the transfer matrix approach from `MachineLearning/CellularAutomata/Defs.lean` can be lifted to the tropical semiring, where the largest eigenvalue of the tropical transfer matrix gives a lower bound on the topological entropy.\n\nMore precisely: for a 1D nearest-neighbor CA with alphabet of size q and rule f, the topological entropy h(f) = lim_{n\u2192\u221e} (1/n) log\u2082(N(n)) where N(n) is the number of valid spacetime columns of height n. N(n) = tr(A^n) where A is the transfer matrix. In the tropical semiring, tr(A^n) corresponds to the weight of the longest cycle, which bounds h(f) from below.\n\n**Test**: For the elementary CA Rule 110 (known to be Turing complete), compute the tropical eigenvalue of the transfer matrix for small heights (h = 2, 3, 4) and verify that it provides a meaningful lower bound on the known topological entropy.\n\n**Impact**: This would establish a novel bridge between cellular automata theory and tropical geometry, providing a new computational tool for bounding dynamical invariants. The tropical approach could bypass the computational difficulty of exact entropy calculation (which is undecidable in general for 2D CAs).\n\n**Catalog References**: `Tropical/TropicalDeepResearch.lean` (tropical dynamics), `MachineLearning/CellularAutomata/Defs.lean` (transfer matrices), `Novelty/GameOfLife/Theorems.lean` (GoL formalization)\n\n**Proof Strategy**:\n1. Define topological entropy for CAs using spacetime columns and transfer matrices (extending `MachineLearning/CellularAutomata/Defs.lean`).\n2. Define the tropical transfer matrix: replace (\u2115, +, \u00d7) with (\u2124 \u222a {-\u221e}, max, +).\n3. Prove that tropical matrix power gives a lower bound on the ordinary matrix trace.\n4. Use `tropical_spectral_bound` from `Tropical/TropicalDeepResearch.lean` to bound the tropical eigenvalue.\n\n**Domain Bridges**: Computation (CA entropy) <-> Tropical Geometry (min-plus spectral theory) <-> Dynamical Systems (topological entropy)\n\n**Lineage**: Bridges GoL formalization with tropical spectral theory from `Tropical/TropicalDeepResearch.lean`.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Reversible Cellular Automata and Conservation Laws\n\n**Conjecture**: Every reversible cellular automaton on \u2124^d (i.e., one whose global map is a bijection) conserves a \"generalized energy\" \u2014 a shift-invariant additive quantity. Specifically, for any reversible nearest-neighbor CA f on alphabet A, there exists a function E: A^{2r+1} \u2192 \u2124 (depending on a window of size 2r+1 for some finite r) such that \u03a3_i E(cfg[i-r..i+r]) is conserved by f.\n\nThis is related to the Noether theorem for discrete systems: symmetry (reversibility + translation invariance) implies conservation.\n\n**Test**: Verify for the elementary CA Rule 51 (the NOT function, which is trivially reversible) that the number of alive cells modulo 2 is conserved. Then check for Critters (a reversible 2D CA) that the cell count parity is conserved.\n\n**Impact**: A formal proof would establish a discrete Noether theorem for cellular automata, connecting reversibility (a computational property) to conservation (a physical property). This would deepen the analogy between CAs and physics.\n\n**Catalog References**: `Algebra/CellularAutomataReversibility.lean`, `Novelty/GameOfLife/Theorems.lean`, `Physics/` (conservation law formalizations if available)\n\n**Proof Strategy**:\n1. Define reversible CAs (global map is bijective).\n2. Define additive shift-invariant quantities.\n3. Use the Curtis-Hedlund-Lyndon theorem (continuous shift-commuting maps are CA maps) to characterize the structure of reversible CAs.\n4. Construct the conserved quantity from the inverse map's local structure.\n\n**Domain Bridges**: Computation (reversible CA) <-> Physics (conservation laws, Noether theorem) <-> Algebra (group structure of reversible maps)\n\n**Lineage**: Extends GoL formalization and connects to `Algebra/CellularAutomataReversibility.lean`.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Self-Reproducing Patterns and von Neumann's Construction\n\n**Conjecture**: In any sufficiently powerful cellular automaton (one that can simulate a universal Turing machine with bounded overhead), there exist self-reproducing patterns \u2014 configurations that, after a finite number of steps, produce a translated copy of themselves plus additional \"construction material.\" This is von Neumann's self-reproduction theorem.\n\nFor GoL specifically: there exist GoL configurations that contain a complete description of themselves and, after a bounded number of steps, produce a second copy at a specified location.\n\n**Test**: Formalize the abstract self-reproduction theorem: if a CA can simulate any Turing machine, then it can simulate a TM that constructs copies of its own encoding. The proof is by diagonalization/fixed-point argument (analogous to Kleene's recursion theorem).\n\n**Impact**: This would formalize the mathematical foundation of artificial life, connecting universality (proved in this cycle) to self-reproduction. The proof uses the recursion theorem from computability theory, bridging cellular automata to mathematical logic.\n\n**Catalog References**: `Novelty/GameOfLife/Theorems.lean` (universality), `Computation/` (computability theory)\n\n**Proof Strategy**:\n1. Formalize a \"constructor\" \u2014 a TM/CA program that builds a specified pattern.\n2. Use the simulation from the universality theorem to embed the constructor in GoL.\n3. Apply the recursion theorem (Kleene's fixed point) to obtain a self-describing program.\n4. The GoL encoding of this program is the self-reproducing pattern.\n\n**Domain Bridges**: Computation (GoL universality) <-> Logic (recursion theorem) <-> Biology (self-reproduction)\n\n**Lineage**: Direct application of universality theorem from this cycle.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0801",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "ff64d6c9",
    "status": "available",
    "timestamp": "2026-06-06T04:52:31.358437+00:00",
    "title": "Comprehensive formal framework for Conway's Ga"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n## Synthesis\n\nThis cycle established that Fux's first-species counterpoint rules, when formalized as a finite category on consonant interval classes, have a remarkably clean mathematical structure: the *Dichotomy Principle* (permitted iff imperfect target OR non-parallel motion) completely characterizes the 132 permitted transitions out of 144 total. The complement involution preserves this structure and reverses the consonance order on imperfect intervals, revealing a hidden symmetry. The parallel-motion subgraph has a bipartite structure (24 edges, all targeting imperfect consonances), and the passage rate for length-2 paths is exactly 121/144.\n\nThe most promising cross-domain connection is between **order theory and the parallel-motion prohibition**: the fact that parallel motion cannot reach the \"top\" of the consonance order (perfect consonances) is equivalent to saying that the parallel-motion functor factors through the imperfect subcategory. This connects to the lattice-cost interaction in `Catalog/Algebra/MusicalCounterpoint.lean` and suggests that the counterpoint rules can be understood as a restriction on the *image* of a functor, a perspective that generalizes to other constraint systems in combinatorics and theoretical computer science.\n\nThe direction with highest breakthrough potential is **Direction 1** (multi-voice counterpoint as a higher category), because it would transform a finite combinatorial result into an infinite-dimensional structure with connections to operads and homotopy theory.\n\n---\n\n### Direction 1: Multi-Voice Counterpoint as a Higher Category\n\n**Conjecture**: In n-voice first-species counterpoint (n \u2265 3), the pairwise counterpoint constraints (no parallel fifths between any pair of voices) define a category enriched over the category of preorders. Specifically, the morphisms between two n-voice chords form a preorder under \"voice-leading parsimony\" (fewer parallel pairs = higher in the order), and composition preserves this preorder.\n\n**Test**: Formalize 3-voice counterpoint transitions as triples of consonant intervals (one for each pair of voices). Enumerate the permitted transitions (where no pair moves in parallel to a perfect consonance) and verify that the preorder structure on morphisms is preserved under composition. Compute the exact number of permitted 3-voice transitions and compare to the single-pair count (132).\n\n**Impact**: If true, this shows that multi-voice counterpoint is not just \"n copies of two-voice counterpoint\" but has genuinely higher categorical structure. The enrichment over preorders means that among the permitted voice leadings, some are \"more permitted\" than others, creating a graded structure. If false, it means the pairwise constraints interact in ways that destroy the preorder structure, which would be equally informative about the limits of decomposition.\n\n**Catalog References**: `Catalog/Algebra/MusicalCounterpoint.lean` (voice motion space Fin n \u2192 \u2124), `Novelty/CounterpointCategory.lean` (two-voice case)\n\n**Proof Strategy**: Define the 3-voice transition type as (ConsInterval \u00d7 ConsInterval \u00d7 ConsInterval) \u00d7 (MotionType \u00d7 MotionType \u00d7 MotionType). The permitted predicate checks all three pairs. Use Fintype and native_decide for enumeration. For the preorder structure, define the parsimony ordering and verify transitivity and composition-preservation by exhaustive computation on the finite type.\n\n**Domain Bridges**: Music Theory \u2194 Higher Category Theory \u2194 Combinatorial Optimization\n\n**Lineage**: Builds on this cycle's Dichotomy Principle (Theorem 4.1) and fiber decomposition.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Counterpoint Transition Matrices and Spectral Analysis\n\n**Conjecture**: The 6\u00d76 transition matrix of first-species counterpoint (where entry (i,j) = number of permitted motion types from interval i to interval j) has a spectral gap that quantifies the \"compositional freedom\" of the system. Specifically, the ratio \u03bb\u2081/\u03bb\u2082 (largest to second-largest eigenvalue) equals exactly 11/9.\n\n**Test**: Compute the transition matrix explicitly. Under the standard rule, the matrix has entries 4 (imperfect targets) or 3 (perfect targets), so it is a rank-1 perturbation of a constant matrix. Compute its eigenvalues analytically and verify the spectral gap. Compare with the strict-rule transition matrix (entries 4 or 2).\n\n**Impact**: The spectral gap determines the mixing time of a random walk on the counterpoint graph, which has a musical interpretation: it measures how quickly a random sequence of consonant intervals \"forgets\" its starting interval. A large spectral gap means fast mixing, which corresponds to high compositional freedom. The exact value 11/9 (if confirmed) would be a new numerical invariant of the counterpoint system.\n\n**Catalog References**: `Novelty/CounterpointCategory.lean` (fiber sizes), `Computation/SpectralProofComplexity.lean` (spectral methods)\n\n**Proof Strategy**: The transition matrix is M = (m\u1d62\u2c7c) where m\u1d62\u2c7c = 4 if j is imperfect, 3 if j is perfect. This is M = 4\u00b7J\u2086\u2093\u2084 + 3\u00b7J\u2086\u2093\u2082 (block structure). Use the spectral theory of rank-1 matrices to compute eigenvalues. The result should be verifiable in Lean using matrix computations over \u211a.\n\n**Domain Bridges**: Music Theory \u2194 Spectral Graph Theory \u2194 Markov Chain Theory\n\n**Lineage**: Builds on this cycle's counting results (132 permitted, fiber sizes 4 and 3).\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Counterpoint \u2014 Voice Leading in the Min-Plus Semiring\n\n**Conjecture**: The voice-leading cost function from `MusicalCounterpoint.lean` (L\u00b9 norm) can be tropicalized: replacing addition with min and multiplication with addition gives a tropical voice-leading cost that is a valuation on the space of voice motions. Under this tropicalization, the optimal voice leading for a counterpoint system is the tropical sum (componentwise min) of all feasible voice motions.\n\n**Test**: Formalize the tropical voice-leading cost as min(|m\u2081|, |m\u2082|, ..., |m\u2099|) instead of \u03a3|m\u1d62|. Prove that this satisfies the tropical seminorm axioms. Show that the tropical optimal voice leading has a closed-form expression in terms of the constraint set. Compare with the standard L\u00b9 optimal on explicit examples (e.g., resolution of a dominant seventh chord).\n\n**Impact**: If the tropical cost gives meaningful musical results, it would establish a new bridge between tropical geometry and music theory. The tropical optimal voice leading minimizes the \"worst-case\" voice motion rather than the total, which corresponds to a different musical aesthetic (smoothness of the most active voice rather than total economy of motion). This connects to the existing tropical work in `Catalog/Tropical/TropicalHypergraphCounterpoint.lean`.\n\n**Catalog References**: `Catalog/Algebra/MusicalCounterpoint.lean` (L\u00b9 cost), `Catalog/Tropical/TropicalHypergraphCounterpoint.lean`, `Catalog/Pythagorean/HarmonicMusicTheory.lean` (tropical log ratio)\n\n**Proof Strategy**: Define the tropical cost as the L\u221e norm (max of absolute values). Prove it satisfies the triangle inequality in the tropical sense. Use the lattice structure on Fin n \u2192 \u2124 to show that the tropical optimal equals the lattice meet of all feasible motions (this follows from the fact that the L\u221e norm is monotone under the componentwise order).\n\n**Domain Bridges**: Music Theory \u2194 Tropical Geometry \u2194 Optimization Theory\n\n**Lineage**: Builds on catalog voice leading cost theory and tropical framework.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: The Chromatic Counterpoint Category (12 Objects)\n\n**Conjecture**: Extending the counterpoint category from 6 consonant interval classes to all 12 chromatic interval classes (with \"dissonant\" intervals included but marked) creates a category equivalent to a specific partially ordered set on 12 elements. Specifically, the 12 chromatic intervals ordered by consonance rank form a lattice, and the counterpoint permitted relation generates the down-closure of this lattice.\n\n**Test**: Define the 12-element consonance ranking: P1 > P5 > M3 > m3 > M6 > m6 > P4 > M2 > m7 > m2 > M7 > tritone. Define the permitted relation on all 12 intervals (allowing transitions between consonant intervals, and \"resolution\" from dissonant to consonant). Verify the lattice property and compute the number of edges in the generated category.\n\n**Impact**: This would establish the \"12-element poset\" conjecture from the original research direction, showing that the full chromatic counterpoint system has a clean order-theoretic characterization. The lattice structure would provide a natural framework for understanding dissonance resolution (passing from higher to lower in the order) as a categorical functor.\n\n**Catalog References**: `Novelty/CounterpointCategory.lean` (6-element case), `Novelty/CounterpointQuiver.lean` (consonance rank)\n\n**Proof Strategy**: Start by defining the 12-element type and the consonance ranking. Use Mathlib's lattice theory to check the lattice axioms. The key step is showing that the meet and join operations correspond to musically meaningful operations (e.g., the meet of two intervals is their \"most consonant common resolution\").\n\n**Domain Bridges**: Music Theory \u2194 Lattice Theory \u2194 Order Theory\n\n**Lineage**: Directly extends this cycle's 6-element formalization to the full chromatic space.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Counterpoint as a Constraint Satisfaction Problem \u2014 Phase Transitions\n\n**Conjecture**: As the number of forbidden motion types increases from 0 to 4, the counterpoint transition system undergoes a sharp phase transition in connectivity. Specifically, there exists a critical threshold k* such that for k < k* forbidden motion types per perfect target, the transition graph is strongly connected, and for k \u2265 k* it is disconnected. The conjecture is that k* = 3 (forbidding parallel, similar, and contrary motion to perfect consonances disconnects the graph).\n\n**Test**: For each subset S \u2286 MT of \"forbidden-to-perfect\" motion types (16 subsets total), compute the transition graph and check strong connectivity. Plot the size of the largest strongly connected component as a function of |S|. Identify the exact threshold.\n\n**Impact**: Phase transitions in constraint satisfaction are a deep topic in computational complexity (e.g., the random k-SAT threshold). Finding a phase transition in counterpoint would connect music theory to statistical physics and theoretical CS, showing that the same mathematical phenomenon (sharp connectivity thresholds) appears in radically different domains.\n\n**Catalog References**: `Novelty/CounterpointCategory.lean` (transition system), `Computation/SpectralProofComplexity.lean` (complexity perspectives)\n\n**Proof Strategy**: Since MT has only 4 elements and CI has 6, the entire analysis is computationally tractable (16 subsets \u00d7 36 possible edges). Use Lean's decidability to prove the threshold exactly. The key lemma is that removing contrary motion from the permitted set disconnects perfect consonances from the rest (since oblique motion alone cannot change intervals by enough to reach all consonances).\n\n**Domain Bridges**: Music Theory \u2194 Statistical Physics \u2194 Computational Complexity\n\n**Lineage**: Builds on this cycle's completeness result (Theorem 3.1) by asking: what is the minimal motion-type set that preserves completeness?\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0809",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "7d8ef14f",
    "status": "available",
    "timestamp": "2026-06-06T06:33:44.779363+00:00",
    "title": "That Fux's first-species counterpoint rules, when formali"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Non-Archimedean Probability Theory\n\n## Synthesis\n\nThis research cycle established rigorous algebraic foundations for probability theory in non-Archimedean ordered fields. The central discovery is the **exact characterization**: a linearly ordered field admits infinitesimal probabilities (positive \u03b5 with n\u00b7\u03b5 < 1 for all n \u2208 \u2115) if and only if it is non-Archimedean (Theorem `non_archimedean_iff_infinitesimal_exists`). This transforms the question of infinitesimal probability from a philosophical curiosity into a precise algebraic condition.\n\nThe most promising cross-domain connection emerged between the **measure positivity bridge** (Theorem `probability_positivity_from_same_sign`) and the **Lorentzian anti-cancellation principle** from the catalog (`sum_ne_zero_of_same_sign_and_exists_ne_zero`). Both express the same deep fact \u2014 sums of same-sign terms cannot cancel \u2014 but in different mathematical contexts. The probability interpretation reveals that this algebraic principle is exactly what guarantees that positive-weight measures are faithful: nonempty sets always have positive measure.\n\nThe highest breakthrough potential lies in **Direction 1** (Hyperfinite Measure Completion), which would bridge finite additivity to a genuine probability measure integrating to 1 over a \"hyperfinite\" space. This requires developing surreal or hyperreal integration theory, connecting to Loeb's measure construction from nonstandard analysis. Success here would provide a complete foundation for infinitesimal probability that resolves the dart-throwing paradox and has implications for Bayesian epistemology and quantum foundations.\n\n---\n\n### Direction 1: Hyperfinite Measure Completion \u2014 From Sub-Probability to Full Probability\n\n**Conjecture**: In a non-Archimedean ordered field F, for any positive infinitesimal \u03b5 and any hyperfinite cardinal \u03ba (a non-standard natural number greater than all standard naturals), the product \u03ba \u00b7 \u03b5 can equal exactly 1 if \u03b5 = \u03ba\u207b\u00b9. Formally: for any non-Archimedean F containing an element \u03c9 > n for all n \u2208 \u2115, the uniform measure assigning weight \u03c9\u207b\u00b9 to each of \u03c9 elements sums to exactly 1. This would complete the sub-probability of our Theorem 6.1 to a full probability measure.\n\n**Test**: Formalize \"hyperfinite type\" as a type whose cardinality is a non-standard natural number in F. Prove that \u03c9 \u00b7 (\u03c9\u207b\u00b9) = 1 in F (this is trivially true algebraically but requires careful formalization of what \"\u03c9 elements\" means type-theoretically). The key challenge is defining a Finset-like object of cardinality \u03c9 in Lean.\n\n**Impact**: If true, this provides a complete, rigorous construction of a non-Archimedean probability measure where every point has equal positive (infinitesimal) probability and the total is exactly 1 \u2014 resolving the original conjecture. If the formalization obstacles prove insurmountable, the failure would reveal fundamental limitations of type-theoretic foundations for non-standard objects.\n\n**Catalog References**: `Novelty/SurrealProbability.lean` (theorems `infinitesimal_sub_probability`, `non_archimedean_iff_infinitesimal_exists`), `FINAL/Pythagorean/LorentzianAggregateAntiCancel.lean` (`sum_ne_zero_of_same_sign_and_exists_ne_zero`)\n\n**Proof Strategy**: (1) Define a \"hyperfinite Finset\" abstraction parameterized by a non-standard natural in F. (2) Prove the algebraic identity \u03c9 \u00b7 \u03c9\u207b\u00b9 = 1 in any field. (3) Bridge the type-theoretic gap by encoding the hyperfinite set as Fin n for an abstract n : \u2115 satisfying the right properties, then use `uniform_finmeasure_total`. (4) The main challenge is that n is not a *specific* natural but an element of F cast from \u2115 \u2014 handle via universally quantified statements.\n\n**Domain Bridges**: Non-Archimedean algebra \u2194 Measure theory \u2194 Nonstandard analysis (Loeb measures)\n\n**Lineage**: Direct extension of `infinitesimal_sub_probability` and `non_archimedean_exceeds_any_finite_cover` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Non-Archimedean Conditional Probability and Bayesian Inference\n\n**Conjecture**: In a non-Archimedean probability space where individual points have infinitesimal probability \u03b5, conditional probability P(A|{x}) = P(A \u2229 {x})/P({x}) is well-defined and equals the indicator function 1_A(x). This resolves the Borel-Kolmogorov paradox for point conditioning.\n\n**Test**: Define conditional probability as the ratio \u03bc(A \u2229 B)/\u03bc(B) in a non-Archimedean field (where \u03bc(B) = \u03b5 \u2260 0, so division is valid). Prove that P(A|{x}) = 1 if x \u2208 A and P(A|{x}) = 0 if x \u2209 A. This requires the field to have well-defined division by infinitesimals.\n\n**Impact**: If true, this provides the first rigorous framework for conditional probability on individual points \u2014 something impossible in standard measure theory (where P({x}) = 0 makes P(A|{x}) undefined). This has direct applications in Bayesian epistemology where one wants to condition on specific observations.\n\n**Catalog References**: `Novelty/SurrealProbability.lean` (theorems `finmeasure_disjoint_additive`, `FinProbMeasure`)\n\n**Proof Strategy**: (1) Define conditional measure \u03bc(A|B) = \u03bc(A \u2229 B)/\u03bc(B) for \u03bc(B) \u2260 0 in a field F. (2) For uniform measure with weight \u03b5, \u03bc({x}) = \u03b5 \u2260 0. (3) \u03bc(A \u2229 {x}) = \u03b5 if x \u2208 A, 0 otherwise. (4) Therefore P(A|{x}) = \u03b5/\u03b5 = 1 or 0/\u03b5 = 0. (5) Prove this is itself a probability measure (normalized, additive).\n\n**Domain Bridges**: Non-Archimedean algebra \u2194 Bayesian inference \u2194 Philosophy of probability\n\n**Lineage**: Builds on `finmeasure_disjoint_additive` and `FinProbMeasure` structure from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Probability \u2014 The Min-Plus Limit of Non-Archimedean Measures\n\n**Conjecture**: As the infinitesimal parameter \u03b5 \u2192 0 in a family of non-Archimedean probability measures, the logarithmic transformation -log(\u03bc_\u03b5) converges to a tropical (min-plus) probability structure where \"probability\" is replaced by \"cost\" and addition is replaced by minimum. Specifically: for uniform measures with weight \u03b5^{v(x)} where v : \u03b1 \u2192 \u2115 is a \"valuation,\" the tropical limit assigns cost v(x) to point x and the \"total probability\" becomes min_{x \u2208 \u03b1} v(x).\n\n**Test**: Define a family of measures \u03bc_\u03b5 parameterized by \u03b5 \u2208 (0,1) \u2282 \u211d, with \u03bc_\u03b5({x}) = \u03b5^{v(x)} for a fixed valuation v. Compute the limit of -log(\u03bc_\u03b5(S))/log(\u03b5) as \u03b5 \u2192 0 for subsets S, and verify it equals min_{x \u2208 S} v(x). This connects non-Archimedean probability to tropical geometry.\n\n**Impact**: If true, this establishes a formal bridge between non-Archimedean probability and tropical mathematics. The \"tropicalization\" of probability would give a new interpretation of tropical semirings as degenerate probability spaces, connecting to the existing tropical optimization work in the catalog.\n\n**Catalog References**: `FINAL/Tropical/TropicalAdditiveCombinatorics.lean` (`no_finite_bound_if_counterexample_exists`), `FINAL/Tropical/GL3FiniteTestFamily.lean` (`finite_test_family_zero_GL3`), `Novelty/SurrealProbability.lean`\n\n**Proof Strategy**: (1) Define the parametric family of measures. (2) Use the fact that for 0 < \u03b5 < 1, \u03b5^n is decreasing in n. (3) Compute the sum \u03a3_x \u03b5^{v(x)} and show that as \u03b5 \u2192 0, the dominant term is the one with smallest v(x). (4) Take the logarithmic limit. (5) Verify the resulting structure satisfies tropical semiring axioms (min for addition, + for multiplication).\n\n**Domain Bridges**: Non-Archimedean probability \u2194 Tropical geometry \u2194 Optimization theory\n\n**Lineage**: Bridges this cycle's non-Archimedean probability with the catalog's tropical mathematics threads.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Strict Monotonicity as a Faithfulness Criterion for Abstract Measures\n\n**Conjecture**: The strict monotonicity property (Theorem `probability_strict_mono_of_positive_weights`: S \u2282 T implies \u03bc(S) < \u03bc(T) for positive weights) characterizes \"faithful\" measures among finitely additive measures on finite types. Specifically: a finitely additive measure \u03bc on a finite type satisfies strict monotonicity for proper subsets if and only if \u03bc({x}) > 0 for all x. The backward direction is our Theorem 5.3; the forward direction would show faithfulness is necessary.\n\n**Test**: Prove the converse: if \u03bc satisfies strict monotonicity (S \u2282 T \u27f9 \u03bc(S) < \u03bc(T)) for all pairs, then \u03bc(x) > 0 for all x \u2208 \u03b1. This should follow by considering S = T \\ {x} \u2282 T and deducing \u03bc(T) - \u03bc(T \\ {x}) = \u03bc({x}) > 0.\n\n**Impact**: If true, this gives an elegant characterization of faithful measures purely in terms of a monotonicity property, without reference to individual weights. This connects measure theory to order theory and lattice theory, where monotonicity is a fundamental concept.\n\n**Catalog References**: `Novelty/SurrealProbability.lean` (theorems `probability_strict_mono_of_positive_weights`, `probability_positivity_from_same_sign`), `FINAL/Pythagorean/LorentzianAggregateAntiCancel.lean`\n\n**Proof Strategy**: (1) Assume strict monotonicity for all S \u2282 T. (2) For any x \u2208 \u03b1, consider T = {x} and S = \u2205. (3) By strict monotonicity, \u03bc(\u2205) < \u03bc({x}), so 0 < \u03bc({x}). (4) Formalize this simple argument. (5) State the full iff characterization.\n\n**Domain Bridges**: Measure theory \u2194 Order theory \u2194 Lattice theory\n\n**Lineage**: Direct extension of `probability_strict_mono_of_positive_weights` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Non-Archimedean Expected Value and the St. Petersburg Paradox\n\n**Conjecture**: The St. Petersburg paradox (a game with infinite expected value in \u211d) has a well-defined, finite surreal expected value when computed with non-Archimedean probabilities. Specifically: if the game pays 2^n with probability 2^{-n} for each n, and we use a non-Archimedean probability space where these probabilities are genuine (not limits), the expected value E = \u03a3 2^n \u00b7 2^{-n} = \u03a3 1 diverges in \u211d but can be assigned a specific hyperfinite surreal value \u03c9 in a non-Archimedean field.\n\n**Test**: Define the truncated St. Petersburg game for n rounds with non-Archimedean probabilities. Show that the expected value at round N is N (a natural number), and in the hyperfinite limit (N = \u03c9), the expected value is \u03c9 \u2014 a well-defined surreal number. Verify that this expected value, while infinite, is *specific* (not \"infinity\" but a particular surreal number), enabling meaningful comparisons between different gambles.\n\n**Impact**: If true, this resolves one of the oldest paradoxes in probability theory using non-Archimedean methods. The resolution is novel: the expected value is not finite, but it is *specific* \u2014 a definite surreal number \u03c9, not just \"\u221e.\" This enables comparing the St. Petersburg game to other infinite-expectation gambles.\n\n**Catalog References**: `Novelty/SurrealProbability.lean` (theorems `uniform_finmeasure_total`, `non_archimedean_iff_infinitesimal_exists`), `Catalog/Novelty/CollatzSpectral/Theorems.lean`\n\n**Proof Strategy**: (1) Define the truncated St. Petersburg payoff function p(n) = 2^n for n \u2208 Fin(N). (2) Define probabilities w(n) = 2^{-n} / (1 - 2^{-N}) (normalized). (3) Compute E_N = \u03a3 p(n) \u00b7 w(n). (4) Show that as N \u2192 \u03c9 (hyperfinite), E_N \u2192 \u03c9. (5) This requires defining geometric sums in a non-Archimedean field.\n\n**Domain Bridges**: Non-Archimedean probability \u2194 Decision theory \u2194 Game theory\n\n**Lineage**: Builds on `uniform_finmeasure_total` and the non-Archimedean framework from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0813",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "22827c52",
    "status": "available",
    "timestamp": "2026-06-06T07:09:04.039795+00:00",
    "title": "Rigorous algebraic foundations for probability t"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Proof Complexity and Thermodynamic Cost\n\n## Synthesis\n\nThis research cycle established a formally verified bridge between three domains: proof complexity theory, information theory, and thermodynamics. The key results \u2014 strict cost monotonicity, the incompressibility barrier, the discovery-verification thermodynamic gap, existence of long proofs, and complexity class separation \u2014 all connect to a single unifying principle: Landauer's bound constrains mathematical reasoning just as it constrains physical computation.\n\nThe most promising cross-domain connection emerged from the **fundamental thermodynamic bridge**, which formally links the combinatorial structure of proof search spaces (from `Physics/ProofSearchInformation.lean`) with the thermodynamic cost framework (from `Computation/ThermodynamicSorting.lean`). This bridge transforms abstract complexity-theoretic bounds into physical energy bounds, opening a new avenue for applying thermodynamic reasoning to mathematical logic.\n\nThe highest breakthrough potential lies in Direction 1 (Quantitative Chaitin-Landauer Theorem), which would establish that the thermodynamic cost of proof can be unboundedly large \u2014 a result that would connect G\u00f6del incompleteness to physical energy constraints. Direction 3 (Tropical Proof Cost Algebra) offers the most surprising cross-domain connection, linking proof complexity to tropical geometry through the observation that proof cost optimization is naturally a min-plus problem.\n\n---\n\n### Direction 1: Quantitative Chaitin-Landauer Theorem\n\n**Conjecture**: For any computable function f : \u2115 \u2192 \u2115, there exists a provable statement \u03c6 of length n such that the shortest proof of \u03c6 has thermodynamic cost exceeding f(n) \u00b7 kT \u00b7 ln(2). That is, no computable bound can capture the worst-case proof cost.\n\n**Test**: Formalize a diagonal argument: given a Turing machine M computing f, construct a statement that asserts \"I have no proof of length \u2264 f(n).\" If this statement is provable, its proof must be longer than f(n), giving cost > f(n) \u00b7 kT \u00b7 ln(2). If unprovable, exhibit a stronger system where it becomes provable. The test succeeds if we can formalize the diagonal construction in Lean 4 using a model of computation (e.g., Turing machines from Mathlib's `Computability` library).\n\n**Impact**: If true, this establishes that proof complexity has no computable ceiling \u2014 a thermodynamic analog of Chaitin's incompleteness theorem. It would mean that for any energy budget, there exist true mathematical statements that cannot be proved within that budget. If false, it would imply a surprising regularity in proof complexity, suggesting that all proofs can be bounded by a computable function.\n\n**Catalog References**: `Physics/ProofSearchInformation.lean` (`proof_length_log_lower_bound`), `Novelty/ProofThermodynamics.lean` (`exists_long_proof`, `shorter_strings_lt_total`)\n\n**Proof Strategy**: \n1. Formalize a simple model of computation (partial recursive functions or Turing machines) using Mathlib's `Computability` module.\n2. Define \"provability within cost bound f\" as existence of a proof string of length \u2264 f(n).\n3. Construct the diagonal statement using the recursion theorem (Kleene's fixed point theorem).\n4. Show the diagonal statement is true but not provable within cost f, using a proof by contradiction.\n5. Key lemma: the set of statements provable within cost f is computably enumerable but not co-c.e.\n\n**Domain Bridges**: Proof Complexity \u2194 Computability Theory \u2194 Thermodynamics\n\n**Lineage**: Extends `exists_long_proof` and `shorter_strings_lt_total` from this cycle. Builds on the incompressibility framework.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Thermodynamic Proof Entropy and Phase Transitions\n\n**Conjecture**: Define the proof entropy H(n) as the Shannon entropy of the distribution of shortest proof lengths for statements of length n. Then H(n) undergoes a phase transition: there exists a critical complexity n_c such that for n < n_c, H(n) grows logarithmically (most proofs are short), while for n > n_c, H(n) grows linearly (proof lengths are uniformly distributed across all scales).\n\n**Test**: Computationally estimate H(n) for a concrete proof system (e.g., propositional logic with resolution proofs) for n = 1 to 20. Plot H(n) and look for a transition point. Formally, prove that H(n) \u2264 log\u2082(n) for proof systems where all statements have polynomial-length proofs, and H(n) \u2265 c\u00b7n for proof systems containing incompressible statements.\n\n**Impact**: Phase transitions in proof complexity would connect mathematical logic to statistical physics. The critical exponent n_c would characterize the \"hardness transition\" of a proof system, analogous to the SAT phase transition at clause-to-variable ratio 4.27.\n\n**Catalog References**: `Computation/ThermodynamicSorting.lean` (`sortingEntropy`, `conjecture_stirling_entropy_bounds`), `Novelty/ProofThermodynamics.lean` (`proof_cost_hierarchy_gap`)\n\n**Proof Strategy**:\n1. Define proof entropy formally using Mathlib's `MeasureTheory.Measure.entropy` or a discrete analog.\n2. Prove the logarithmic upper bound using the counting argument: if all proofs have length \u2264 p(n), then H(n) \u2264 log\u2082(p(n)).\n3. For the linear lower bound, use the incompressibility result: in a system with incompressible proofs, the distribution has high entropy.\n4. The phase transition conjecture requires showing these bounds are tight in specific proof systems.\n\n**Domain Bridges**: Proof Complexity \u2194 Statistical Physics \u2194 Information Theory\n\n**Lineage**: Extends `proof_cost_hierarchy_gap` and the incompressibility results from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Proof Cost Algebra\n\n**Conjecture**: The proof cost function, viewed as a tropical (min-plus) semiring operation, satisfies a tropical analog of the fundamental theorem of algebra: every proof system's cost function factors uniquely into \"irreducible\" cost components, each corresponding to an independent logical dependency in the proof.\n\n**Test**: Define a tropical semiring structure on proof costs, where addition is min (shortest proof) and multiplication is + (composition cost). Prove that proof cost under composition satisfies the tropical distributive law. Test whether specific proof systems (resolution, sequent calculus) have unique tropical factorizations.\n\n**Impact**: This would connect proof complexity to tropical geometry, a rapidly growing field with applications in algebraic geometry, optimization, and phylogenetics. The tropical factorization would provide a canonical decomposition of proof difficulty into independent components.\n\n**Catalog References**: `Bridges/TropicalAmplificationEnhanced.lean` (`tropical_complexity_lower_bound`), `Novelty/ProofThermodynamics.lean` (`proof_cost_strict_mono`)\n\n**Proof Strategy**:\n1. Define a tropical semiring on proof costs using Mathlib's `Tropical` type.\n2. Show that proof composition (using one proof as a lemma in another) corresponds to tropical multiplication.\n3. Prove the tropical distributive law for proof costs.\n4. Investigate factorization: define \"irreducible proof cost\" and prove existence of factorization.\n5. Uniqueness would require a tropical analog of unique factorization domains.\n\n**Domain Bridges**: Proof Complexity \u2194 Tropical Geometry \u2194 Algebraic Combinatorics\n\n**Lineage**: Bridges `tropical_complexity_lower_bound` from the catalog with this cycle's `proof_cost_strict_mono`.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Reversible Proof Search and Bennett's Theorem\n\n**Conjecture**: Reversible proof search (in the sense of Bennett 1973) can reduce the thermodynamic cost of finding a proof from O(b^n \u00b7 kT \u00b7 ln 2) to O(b^n \u00b7 kT \u00b7 ln 2 / S(n)), where S(n) is the space complexity of verification. However, the *total* cost (time \u00d7 space \u00d7 energy) remains bounded below by \u03a9(b^(n-k)).\n\n**Test**: Formalize Bennett's space-time tradeoff for reversible computation. Apply it to proof search: model search as a reversible Turing machine and compute the energy-space product. Prove that the product is bounded below by the search space density.\n\n**Impact**: If the conjecture holds, it shows that while energy and space can be traded, the fundamental thermodynamic gap between discovery and verification cannot be eliminated \u2014 only redistributed among resources. This would be a \"conservation law\" for proof search difficulty.\n\n**Catalog References**: `Computation/ThermodynamicSorting.lean` (`thermodynamic_work_lower_bound`, `wastedWork_nonneg`), `Novelty/ProofThermodynamics.lean` (`fundamental_thermodynamic_bridge`)\n\n**Proof Strategy**:\n1. Formalize reversible computation using Lean's `Function.Involutive` or a custom reversible Turing machine model.\n2. Prove Bennett's time-space tradeoff: a reversible simulation of a T-time, S-space computation uses O(T \u00b7 2^(S/k)) time for k-space overhead.\n3. Apply to proof search: the verification space S(n) determines how much energy savings reversibility can achieve.\n4. Prove the energy-space product lower bound using a counting argument.\n\n**Domain Bridges**: Proof Complexity \u2194 Reversible Computing \u2194 Thermodynamics\n\n**Lineage**: Directly extends `fundamental_thermodynamic_bridge` and `discovery_exceeds_verification` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Proof Cost in Arithmetic Hierarchies\n\n**Conjecture**: For statements at level \u03a3_k of the arithmetic hierarchy, the minimum thermodynamic proof cost grows as \u03a9(k \u00b7 n \u00b7 kT \u00b7 ln 2). That is, each quantifier alternation adds a multiplicative factor to the thermodynamic cost, reflecting the computational power needed to decide formulas at higher levels.\n\n**Test**: Prove the base case (k=0, decidable statements) where proof cost is bounded by O(n \u00b7 kT \u00b7 ln 2). Then prove the inductive step: show that a \u03a3_{k+1} statement requires at least one additional layer of proof infrastructure beyond \u03a3_k. Formalize using Lean's computability library for the arithmetic hierarchy.\n\n**Impact**: This would provide a thermodynamic characterization of the arithmetic hierarchy, connecting Turing-degree theory to physical energy bounds. It would show that not only are higher-level statements harder to prove (in the standard sense), but they are more expensive *physically*.\n\n**Catalog References**: `Physics/ProofSearchInformation.lean` (`search_complexity_hierarchy`), `Novelty/ProofThermodynamics.lean` (`exp_strictly_larger`, `proof_cost_hierarchy_strict`)\n\n**Proof Strategy**:\n1. Formalize the arithmetic hierarchy using Lean's `Computability` library.\n2. Define \"proof cost at level k\" using the oracle Turing machine model.\n3. Prove the base case: \u03a3_0 statements (decidable) have proofs of length O(n).\n4. Prove the inductive step: a \u03a3_{k+1} oracle can decide \u03a3_k statements, but the oracle itself has unbounded cost.\n5. Combine to get the \u03a9(k \u00b7 n) lower bound.\n\n**Domain Bridges**: Proof Complexity \u2194 Computability Theory \u2194 Thermodynamics \u2194 Mathematical Logic\n\n**Lineage**: Extends `search_complexity_hierarchy` from ProofSearchInformation and `exp_strictly_larger` from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0824",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "c254878a",
    "status": "available",
    "timestamp": "2026-06-06T10:03:35.319392+00:00",
    "title": "Formally verified bridge between three domains"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: EML Differential Equations\n\n## Synthesis\n\nThis cycle established a formal obstruction theory for EML-solvability of linear ODEs, centered on Airy's equation y\u2033 = xy as the prototypical barrier. We proved four independent obstruction arguments (polynomial degree, Riccati degree parity, Wronskian conservation/SL\u2082 invariance, and growth rate analysis) and developed foundational infrastructure including ODE uniqueness for second-order equations with continuous coefficients.\n\nThe most promising cross-domain connection is between the **differential Galois group** formalized here and the **algebraic Galois theory** already present in the Catalog (`Bridges/GaloisNeuralCorrespondence.lean`, `Algebra/ProofSpectra/Core.lean`). Both theories share the same core mechanism \u2014 group-theoretic obstructions to solvability \u2014 but operate in different categories (differential fields vs. number fields). Bridging these formally would unify a substantial portion of modern algebra.\n\nThe cycle's Wronskian theory and ODE uniqueness results are independently valuable and reusable. The growth rate classification (`EMLGrowthClass`) provides a framework for distinguishing solution types that could be applied to broad classes of ODEs beyond Airy.\n\n---\n\n### Direction 1: Formal Stokes Phenomenon for Airy's Equation\n\n**Conjecture**: The asymptotic expansion of Ai(x) as x \u2192 +\u221e (along the positive real axis) and as x \u2192 \u2212\u221e involve different linear combinations of formal WKB solutions, and the transition matrices between these asymptotic regimes are elements of the Stokes group, which is a unipotent subgroup of SL\u2082(\u2102). Formally: the monodromy representation of Airy's equation factors through the wild fundamental group, and the Stokes multipliers can be computed exactly as specific constants involving \u0393(1/3) and \u0393(2/3).\n\n**Test**: Compute Stokes multipliers numerically by integrating Airy's equation along paths crossing Stokes lines (at angles 0, 2\u03c0/3, 4\u03c0/3) and verify they match the predicted values. Formally, prove that the connection matrix between the sectors arg(x) \u2208 (\u2212\u03c0/3, \u03c0/3) and arg(x) \u2208 (\u03c0/3, \u03c0) has the form [[1, s], [0, 1]] for a specific constant s.\n\n**Impact**: This would be the first formalization of the Stokes phenomenon in any proof assistant. The Stokes phenomenon is fundamental to asymptotic analysis, quantum mechanics (WKB approximation), and resurgence theory. A formal treatment would open the door to verified asymptotics.\n\n**Catalog References**: `EML/EMLDiffEq.lean` (Wronskian theory, Abel's identity), `EML/EMLDiffGalois.lean` (SL\u2082 Galois invariance)\n\n**Proof Strategy**: (1) Define formal WKB solutions as asymptotic series. (2) Prove existence of actual solutions with prescribed asymptotics in each sector using Borel summation. (3) Compute the connection matrices between sectors. (4) Show these matrices are unipotent elements of SL\u2082.\n\n**Domain Bridges**: Differential Galois Theory \u2194 Asymptotic Analysis \u2194 Quantum Mechanics\n\n**Lineage**: Builds on this cycle's Wronskian conservation and SL\u2082 invariance results.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Kovacic Algorithm \u2014 Full Decidability Proof\n\n**Conjecture**: Kovacic's algorithm, when formalized as a decision procedure on rational functions r(x) = P(x)/Q(x) with integer coefficients, terminates in time polynomial in the total degree of P and Q, and correctly decides Liouvillian solvability of y\u2033 = r(x)y.\n\n**Test**: Implement the full three-case algorithm in Lean 4 with a verified termination proof. Test on a battery of equations: (a) y\u2033 = x\u00b2y (Liouvillian: y = exp(x\u00b3/3)), (b) y\u2033 = xy (not Liouvillian: Airy), (c) y\u2033 = (1/x\u00b2)y (Euler equation: Liouvillian), (d) y\u2033 = (x\u00b2+1)y (Parabolic cylinder: Liouvillian via Hermite functions?). Verify each decision against known results.\n\n**Impact**: A formally verified Kovacic algorithm would be the first certified decision procedure for Liouvillian solvability. This has applications in computer algebra systems (Maple, Mathematica) where Kovacic's algorithm is implemented but not verified.\n\n**Catalog References**: `EML/EMLDiffGalois.lean` (Riccati obstruction, polynomial derivative algebra), `EML/EMLDiffEq.lean` (no_polynomial_solves_airy)\n\n**Proof Strategy**: (1) Formalize rational functions as a computable type. (2) Implement pole order analysis. (3) Formalize the three cases as finite searches over candidate exponents. (4) Prove termination by bounding the search space. (5) Prove soundness by showing each case correctly identifies solutions.\n\n**Domain Bridges**: Computer Algebra \u2194 Differential Galois Theory \u2194 Computation\n\n**Lineage**: Builds on this cycle's no_polynomial_solves_riccati and kovacic_case1_airy_obstruction.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: EML Growth Hierarchy \u2014 Fractional Exponential Orders\n\n**Conjecture**: Define the *exponential order* of a function f at infinity as ord(f) = inf{\u03b1 > 0 : f(x) = O(exp(x^\u03b1))}. Then: (a) Every EML function has rational exponential order. (b) The Airy function Bi has exponential order exactly 3/2, which is rational but cannot be realized by any EML function. (c) More generally, the exponential orders realizable by solutions of y\u2033 = r(x)y with polynomial r of degree d are exactly {(d+2)/2}, and (d+2)/2 is realizable by an EML function iff d is even.\n\n**Test**: Verify conjecture (c) computationally for d = 0,1,2,...,10 by computing the WKB exponent \u222b\u221ar(x)dx and checking its degree. Formally, prove (a) by structural induction on EML expressions and (b) by the growth rate analysis from this cycle.\n\n**Impact**: This would establish a precise numerical invariant distinguishing EML-solvable from EML-unsolvable equations, providing an effective criterion independent of the full Galois group computation.\n\n**Catalog References**: `EML/EMLDiffGalois.lean` (EMLGrowthClass, exp_not_polynomial_growth), `EML/EMLDiffEq.lean` (exp_dominates_polynomial, airy_not_tendsto_zero)\n\n**Proof Strategy**: (1) Define exponential order formally. (2) Prove the WKB approximation: solutions of y\u2033 = r(x)y have exponential order equal to the degree of \u222b\u221ar(x)dx. (3) Classify which exponential orders arise from EML expressions. (4) Show the parity obstruction: odd-degree r gives half-integer exponential order, incompatible with EML.\n\n**Domain Bridges**: Asymptotic Analysis \u2194 EML Theory \u2194 Complex Analysis\n\n**Lineage**: Builds on this cycle's growth rate analysis and polynomial degree obstruction.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Differential Galois\u2013Algebraic Galois Bridge\n\n**Conjecture**: There exists a formal functor from the category of Picard-Vessiot extensions of \u2102(x) to the category of algebraic groups over \u2102, such that: (a) the image of this functor restricted to constant coefficient equations y^(n) + a\u2099\u208b\u2081y^(n-1) + ... + a\u2080y = 0 recovers the classical Galois group of the splitting field of the characteristic polynomial t^n + a\u2099\u208b\u2081t^(n-1) + ... + a\u2080; (b) for Fuchsian equations (regular singular points only), the differential Galois group is the Zariski closure of the monodromy group.\n\n**Test**: Verify (a) for specific examples: the equation y\u2033 + y = 0 (Galois group {\u00b11} \u2245 \u2124/2, matching the algebraic Galois group of t\u00b2 + 1 over \u211d). Verify (b) for the Gauss hypergeometric equation with specific parameters where the monodromy group is known.\n\n**Impact**: This would be the first formal bridge between algebraic and differential Galois theory, connecting two of the most powerful obstruction theories in mathematics. It would enable transfer of results from the well-developed algebraic theory to the less-developed differential setting.\n\n**Catalog References**: `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety), `EML/EMLDiffGalois.lean` (galois_preserves_wronskian)\n\n**Proof Strategy**: (1) Formalize Picard-Vessiot extensions as differential field extensions with no new constants. (2) Define the differential Galois group as the automorphism group of the extension. (3) For constant-coefficient equations, show the exponential solutions generate a splitting field isomorphic to the algebraic splitting field. (4) For Fuchsian equations, relate analytic continuation to monodromy.\n\n**Domain Bridges**: Algebraic Galois Theory \u2194 Differential Galois Theory \u2194 Topology (Monodromy)\n\n**Lineage**: Builds on this cycle's SL\u2082 invariance and Wronskian theory, connecting to the algebraic Galois results in the Catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Nonlinear EML ODEs \u2014 Painlev\u00e9 Transcendents\n\n**Conjecture**: The first Painlev\u00e9 equation y\u2033 = 6y\u00b2 + x has no EML solutions, and its \"nonlinear differential Galois group\" (in the sense of Malgrange) is the full symplectomorphism group of the phase space, which is infinite-dimensional.\n\n**Test**: (a) Verify the polynomial obstruction: if y is a polynomial of degree d, then d \u2212 2 = 2d + 1 (from y\u2033 vs 6y\u00b2 + x), giving d = \u22123, impossible. (b) Numerically integrate Painlev\u00e9 I and verify that solutions develop arrays of double poles (the Painlev\u00e9 property) with specific pole patterns. (c) Check that the pole locations are not expressible as EML functions of the initial conditions.\n\n**Impact**: Painlev\u00e9 transcendents are the next level of \"new transcendental functions\" beyond Airy. They arise in random matrix theory, quantum gravity, and integrable systems. A formal obstruction theory would extend our results from linear to nonlinear ODEs.\n\n**Catalog References**: `EML/EMLDiffEq.lean` (no_polynomial_solves_airy \u2014 analogous degree argument), `EML/EMLDiffGalois.lean` (no_polynomial_solves_riccati \u2014 analogous nonlinear obstruction)\n\n**Proof Strategy**: (1) Prove the polynomial obstruction (straightforward degree argument). (2) Formalize the Painlev\u00e9 property (movable poles are at worst double). (3) Show the pole distribution contradicts EML structure. (4) Connect to Malgrange's nonlinear differential Galois theory.\n\n**Domain Bridges**: Nonlinear ODEs \u2194 Random Matrix Theory \u2194 EML Theory\n\n**Lineage**: Extends this cycle's linear obstruction theory to the nonlinear setting.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0829",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "0a026f10",
    "status": "available",
    "timestamp": "2026-06-06T11:46:03.844103+00:00",
    "title": "Formal obstruction theory for EML-solvability of linear"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Recurrence Spectrum Theory\n\n## Synthesis\n\nThis research cycle introduced the **Recurrence Spectrum** \u2014 a novel mathematical structure that packages the complete period structure of a dynamical system into a single formal object. The spectrum records which minimal periods are realized, provides witnessing periodic points, and supports structural analysis through spectral dimension and entropy.\n\nThe cycle's key results established the *non-emptiness* of the recurrence spectrum for continuous interval maps (via the Interval Fixed Point Theorem), *period propagation* through multiples and divisibility, *orbit containment* for periodic trajectories, and *finite bounds* on periodic orbit complexity. For the logistic map, we proved invariance of the unit interval, fixed-point existence, and computed both trivial and nontrivial fixed points. We also formalized the Sharkovsky ordering and proved basic forcing relationships (period 3 forces periods 1 and 2; all odd periods \u2265 3 force period 1).\n\nThe most promising cross-domain connection is between the Recurrence Spectrum and **topological entropy**. The growth rate of periodic point counts $|\\text{Fix}(f^n)|$ is intimately connected to topological entropy $h(f)$, and formalizing this connection would establish the Recurrence Spectrum as a *complete* complexity invariant for one-dimensional dynamics. This bridges dynamical systems theory (Physics/Bridges domain) with information-theoretic measures (EML/Computation domain). The Sharkovsky ordering formalization also connects to the existing `finite_state_orbit_periodic` theorem in `Bridges/ModularCFDynamics.lean`, which establishes periodicity for finite-state dynamics \u2014 our bijective periodicity theorem generalizes and sharpens this.\n\n---\n\n### Direction 1: Full Formalization of Sharkovsky's Theorem\n\n**Conjecture**: If $f: [a,b] \\to [a,b]$ is continuous and has a periodic point of period $n$, then for every positive integer $m$ with $n \\trianglelefteq_S m$ in the Sharkovsky ordering, $f$ also has a periodic point of period $m$.\n\n**Test**: Formalize the complete proof of Sharkovsky's theorem in Lean 4. The key intermediate result is: if $f$ has a period-3 orbit $a < b < c$ with $f(a) = b$, $f(b) = c$, $f(c) = a$ (or any permutation), then $f$ has periodic points of all periods. Verify by constructing explicit periodic points for periods 1 through 10 in the logistic map at $r = 3.83$.\n\n**Impact**: Sharkovsky's theorem is one of the deepest results in one-dimensional dynamics. A complete Lean 4 formalization would be a significant contribution to the Mathlib library and would immediately unlock downstream results about chaotic dynamics, Li-Yorke chaos, and symbolic dynamics.\n\n**Catalog References**: `Bridges/ModularCFDynamics.lean` (finite_state_orbit_periodic), `Novelty/RecurrenceSpectrum/Core.lean` (sharkovskyLE, sharkovsky_3_forces_1)\n\n**Proof Strategy**: The standard proof uses the \"Stefan ordering\" on periodic orbits and constructs intermediate value intervals. Key lemmas needed:\n1. If $f$ has a period-3 orbit with specific monotonicity, there exist subintervals $I_0, I_1$ such that $f(I_0) \\supseteq I_0 \\cup I_1$ and $f(I_1) \\supseteq I_0$.\n2. Symbolic dynamics: for any binary sequence, there exists a point whose orbit visits $I_0$ and $I_1$ in the prescribed pattern.\n3. A point with orbit pattern $(I_1, I_0, I_0, \\ldots, I_0)$ of length $n$ has minimal period $n$.\n\n**Domain Bridges**: Dynamical Systems <-> Combinatorics (symbolic dynamics), Dynamical Systems <-> Topology (IVT, connectedness)\n\n**Lineage**: Extends this cycle's `interval_fixed_point`, `sharkovsky_3_forces_1`, `sharkovsky_odd_forces_1`\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Spectral Entropy Equals Topological Entropy\n\n**Conjecture**: For a continuous piecewise-monotone map $f: [0,1] \\to [0,1]$ with $\\ell$ laps (maximal monotone pieces), the spectral entropy $h_{\\text{spec}}(f) := \\lim_{n \\to \\infty} \\frac{1}{n} \\log |\\text{Fix}(f^n)|$ equals the topological entropy $h_{\\text{top}}(f) = \\lim_{n \\to \\infty} \\frac{1}{n} \\log \\ell_n$, where $\\ell_n$ is the lap count of $f^n$.\n\n**Test**: Compute both quantities numerically for the logistic map at $r = 4$ (where $h_{\\text{top}} = \\log 2$) and at $r = 3.83$ (period-3 window, $h_{\\text{top}} \\approx 0.38$). Verify they agree to at least 3 decimal places.\n\n**Impact**: This would establish the Recurrence Spectrum as a *complete invariant* for the complexity of piecewise-monotone interval maps, making the spectral entropy a computable proxy for topological entropy.\n\n**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (periodic_point_count_le, spectrum_contains_one), `EML/AdvancedTheory.lean` (ensemble_complexity_additive)\n\n**Proof Strategy**: The equality is known classically (Misiurewicz-Szlenk theorem). Formalize:\n1. Define lap count and topological entropy via open covers.\n2. Prove $|\\text{Fix}(f^n)| \\leq \\ell_n + 1$ (each lap contributes at most one fixed point of $f^n$).\n3. Prove the reverse inequality using the variational principle: the measure of maximal entropy concentrates on periodic orbits.\n\n**Domain Bridges**: Dynamical Systems <-> Information Theory (entropy), Dynamical Systems <-> Ergodic Theory\n\n**Lineage**: Extends this cycle's spectral entropy definitions and periodic point counting\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Recurrence Spectrum of Continuous Maps on Trees\n\n**Conjecture**: For continuous maps on finite trees (1-dimensional CW-complexes), the set of minimal periods realized is a tail in a generalized Sharkovsky ordering that depends on the combinatorial structure of the tree.\n\n**Test**: For the triod (Y-shaped tree with 3 branches meeting at a vertex), compute the set of possible period sets for continuous self-maps. Verify that the analog of \"period 3 implies all periods\" fails or requires modification.\n\n**Impact**: Trees are the natural generalization of intervals for one-dimensional dynamics. Understanding period-forcing on trees would extend the Recurrence Spectrum framework to a much wider class of spaces.\n\n**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (RecurrenceSpectrum, isSharkovskyClosed), `Bridges/ModularCFDynamics.lean`\n\n**Proof Strategy**: \n1. Define a \"tree map\" as a continuous self-map of a finite graph with no cycles.\n2. Classify period sets for maps on the triod (known to differ from interval maps \u2014 Alsed\u00e0, Llibre, Misiurewicz).\n3. Define a generalized Sharkovsky ordering for each tree type.\n4. Prove that the recurrence spectrum of a tree map is a tail in this ordering.\n\n**Domain Bridges**: Dynamical Systems <-> Graph Theory, Dynamical Systems <-> Algebraic Topology (fundamental group of graphs)\n\n**Lineage**: Extends the Sharkovsky ordering formalization from this cycle\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Orbit Counting for the Logistic Map via Symbolic Dynamics\n\n**Conjecture**: For the full logistic map $f_4(x) = 4x(1-x)$, the number of minimal period-$n$ orbits is $\\frac{1}{n} \\sum_{d | n} \\mu(n/d) \\cdot 2^d$, matching the necklace counting formula for binary strings under the M\u00f6bius function $\\mu$.\n\n**Test**: Compute the number of minimal period-$n$ orbits for $n = 1, \\ldots, 12$ both numerically (by finding periodic points of $f_4$) and via the formula. They should agree exactly.\n\n**Impact**: This connects the Recurrence Spectrum to combinatorics and number theory via the M\u00f6bius function, establishing that periodic orbit counting in chaotic dynamics reduces to a purely combinatorial problem.\n\n**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (orbit_subset_finiteOrbit, period_divides), `Cryptography/MasterFormula.lean` (complement_density_fixed_points)\n\n**Proof Strategy**:\n1. Establish the semiconjugacy between $f_4$ and the doubling map $x \\mapsto 2x \\pmod{1}$ via $h(x) = \\sin^2(\\pi x / 2)$.\n2. Periodic orbits of the doubling map correspond to binary strings under cyclic equivalence.\n3. Count binary necklaces using Burnside's lemma / M\u00f6bius inversion.\n4. Transfer the count back to $f_4$ via the semiconjugacy.\n\n**Domain Bridges**: Dynamical Systems <-> Number Theory (M\u00f6bius function), Dynamical Systems <-> Combinatorics (necklace counting), Dynamical Systems <-> Cryptography (symbolic dynamics \u2194 binary sequences)\n\n**Lineage**: Extends logistic map analysis from this cycle\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Categorical Recurrence Spectra\n\n**Conjecture**: The assignment $f \\mapsto \\mathcal{R}(f)$ defines a functor from the category of dynamical systems (with semiconjugacies as morphisms) to a category of \"period structures\" (downward-closed subsets of the Sharkovsky ordering, with inclusions as morphisms). This functor preserves products and detects topological conjugacy classes.\n\n**Test**: Verify functoriality on three concrete examples: (a) the identity map, (b) the doubling map, (c) the logistic map at $r = 3.83$. Check that semiconjugate systems have compatible recurrence spectra.\n\n**Impact**: A categorical framework would make the Recurrence Spectrum a natural invariant in the sense of category theory, enabling systematic computation via functorial properties and connecting to existing categorical structures in Mathlib.\n\n**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (RecurrenceSpectrum), `Bridges/TannakaClosureReconstruction.lean` (categorical reconstruction techniques)\n\n**Proof Strategy**:\n1. Define the category of dynamical systems: objects are pairs $(X, f)$, morphisms $h: (X, f) \\to (Y, g)$ are continuous maps with $h \\circ f = g \\circ h$.\n2. Define the category of Sharkovsky tails.\n3. Show that semiconjugacy preserves periods: if $h \\circ f = g \\circ h$ and $f^n(x) = x$, then $g^n(h(x)) = h(x)$.\n4. Prove the functor preserves products using coordinate-wise dynamics.\n\n**Domain Bridges**: Dynamical Systems <-> Category Theory, Dynamical Systems <-> Algebra (group actions)\n\n**Lineage**: Extends the RecurrenceSpectrum definition from this cycle, connects to Tannaka reconstruction in Bridges\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0841",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "1713cb99",
    "status": "available",
    "timestamp": "2026-06-06T14:31:39.018165+00:00",
    "title": "**Recurrence Spectrum** \u2014 a novel mathematica"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Anti-Gravity Mathematics\n\n## Synthesis\n\nThis research cycle introduced **Gravitational Derivation Systems** (GDS), a novel mathematical framework for studying the asymmetry between proof complexity and theorem influence in formal dependency networks. The core discovery is that anti-gravitational theorems \u2014 those whose influence exceeds their proof complexity \u2014 are not rare but mathematically inevitable in any sufficiently interconnected system (the Anti-Gravity Pigeonhole Theorem).\n\nThe most promising cross-domain connection emerged between anti-gravity theory and **spectral graph theory / proof complexity**. The existing Catalog work on Spectral Renormalization (`Computation/SpectralRenormalization.lean`) establishes that vertex expansion ratios constrain proof ball growth, which directly impacts how weight accumulates in dependency graphs. The synthesis: **graph expansion creates anti-gravity**. Systems with high expansion necessarily produce high-weight nodes, which \u2014 if proofs remain short \u2014 become anti-gravitational. This connects combinatorial optimization, spectral theory, and proof complexity in a way that none of these fields would predict alone.\n\nThe direction with highest breakthrough potential is Direction 1 (Transitive Anti-Gravity Spectral Theory), because extending from direct to transitive weight introduces exponential growth effects that could yield much stronger bounds. The existing proof infrastructure (ball growth theorems, renormalization) provides exactly the tools needed.\n\n---\n\n### Direction 1: Transitive Anti-Gravity Spectral Theory\n\n**Conjecture**: In any Gravitational Derivation System where the underlying DAG has vertex expansion ratio h > 0, the maximum transitive anti-gravity index (transitive weight / proof effort) grows exponentially with the graph diameter. Specifically: max_v (|downstream(v)| / \u03c0(v)) \u2265 (1+h)^d / max_effort, where d is the diameter.\n\n**Test**: Construct families of DAGs with known expansion ratios (e.g., Cayley graphs of finite groups) and compute transitive anti-gravity indices. Verify whether the exponential lower bound holds. If it fails, identify the tightest achievable bound.\n\n**Impact**: If true, this would establish that anti-gravity is not merely a counting phenomenon but a spectral one: the eigenvalues of the graph Laplacian directly determine the strength of anti-gravity. This would unify proof complexity lower bounds with anti-gravity theory. If false, it would reveal that expansion alone is insufficient and additional structural properties (e.g., bounded degree) are needed.\n\n**Catalog References**: `Computation/SpectralRenormalization.lean` (ball_growth_lower_bound, HasExpansion), `Applications/AntiGravity/Defs.lean` (GravDerivationSystem), `Applications/AntiGravity/Theorems.lean` (anti_gravity_pigeonhole)\n\n**Proof Strategy**: (1) Define transitive weight as ProofBall reachability count from SpectralRenormalization. (2) Use ball_growth_lower_bound to show transitive weight grows as (1+h)^k. (3) Combine with effort bounds to get the anti-gravity index lower bound. Key lemma needed: bridge between GravDerivationSystem.directWeight and ProofBall.card.\n\n**Domain Bridges**: Spectral graph theory \u2194 Proof complexity \u2194 Anti-gravity combinatorics\n\n**Lineage**: Builds on this cycle's GDS framework and the Catalog's SpectralRenormalization derivation graph infrastructure.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Power-Law Anti-Gravity Spectra in Preferential Attachment Models\n\n**Conjecture**: If a GDS is generated by a preferential attachment process (new theorems cite existing ones with probability proportional to weight + 1), then (a) the gravitational spectrum follows a power law P(w \u2265 k) ~ k^{-\u03b1} with \u03b1 \u2208 (2, 3), and (b) the anti-gravity fraction converges to a constant c(\u03b1) > 0 as n \u2192 \u221e.\n\n**Test**: Generate preferential attachment DAGs of sizes n = 100, 1000, 10000 with fixed effort distributions. Fit power-law exponents to the gravitational spectra using maximum likelihood estimation. Compute anti-gravity fractions and test for convergence.\n\n**Impact**: If true, this would explain *why* formal libraries exhibit heavy-tailed weight distributions: preferential attachment is the mathematical version of \"the rich get richer\" in theorem citation. The anti-gravity fraction constant c(\u03b1) would give a precise prediction testable against Mathlib data. If false, it would suggest that formal library growth follows a different mechanism than standard preferential attachment.\n\n**Catalog References**: `Applications/AntiGravity/Defs.lean` (gravitational spectrum), `Applications/AntiGravity/Theorems.lean` (spectrum_sum_eq_total)\n\n**Proof Strategy**: (1) Use the Barab\u00e1si-Albert model as the base generative process. (2) Compute the expected weight distribution using martingale concentration. (3) Apply the anti-gravity pigeonhole theorem with explicit bounds on E and W in the preferential attachment regime. Key challenge: the effort distribution is independent of the attachment process, so the interaction must be analyzed carefully.\n\n**Domain Bridges**: Random graph theory \u2194 Anti-gravity combinatorics \u2194 Scientometrics\n\n**Lineage**: Extends this cycle's empirical density observations into rigorous probabilistic theory.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Anti-Gravity in Min-Plus Algebras\n\n**Conjecture**: Define a \"tropical proof effort\" where effort is measured in a min-plus semiring (\u211d \u222a {\u221e}, min, +). In this setting, the total effort is min(\u03a3\u03c0 over all subsets), and the anti-gravity condition becomes: the min-plus weight exceeds the additive proof effort. Conjecture: the tropical anti-gravity set is always a subset of the classical anti-gravity set, and the subset can be strict.\n\n**Test**: Construct a GDS where the tropical and classical anti-gravity sets differ. Verify the subset relationship on random instances. If the conjecture fails, find a minimal counterexample.\n\n**Impact**: If true, this connects anti-gravity to the tropical geometry program in the Catalog (TropicalFactoring, CategoricalSurprise), creating a bridge between proof complexity and algebraic geometry over the tropical semiring. The strictness result would show that tropical analysis is a genuine refinement, not merely a restatement.\n\n**Catalog References**: `Bridges/TropicalFactoring.lean` (tropical_fundamental_theorem_of_arithmetic), `Tropical/CategoricalSurprise.lean` (fundamental_theorem_of_comedy), `Applications/AntiGravity/Defs.lean`\n\n**Proof Strategy**: (1) Define TropicalGDS with effort in the min-plus semiring. (2) Define tropical weight as the min-plus analogue of cardinality. (3) Prove the subset relationship by showing classical anti-gravity \u21d2 tropical anti-gravity via semiring homomorphism. (4) Construct a strict example using idempotency of min.\n\n**Domain Bridges**: Tropical geometry \u2194 Anti-gravity combinatorics \u2194 Proof complexity\n\n**Lineage**: Cross-connects this cycle's GDS framework with the Catalog's tropical mathematics program.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Anti-Gravity in Collatz-Type Derivation Systems\n\n**Conjecture**: Consider the Collatz derivation system where vertices are natural numbers 1, ..., N and edges follow the Collatz map (n \u2192 n/2 if even, n \u2192 3n+1 if odd). Define effort as the number of Collatz steps from n to 1 (assuming the conjecture). Then: (a) the number 1 has maximum weight (all paths converge to it), and (b) the anti-gravity fraction grows as \u0398(1/log N).\n\n**Test**: Compute the Collatz DAG for N = 10000. Measure weights, efforts, and anti-gravity fractions. Compare with the predicted \u0398(1/log N) scaling.\n\n**Impact**: If true, this would connect anti-gravity theory to the Collatz conjecture infrastructure in the Catalog, showing that the Collatz map's convergence creates a specific anti-gravity pattern. The 1/log N scaling would be a new quantitative prediction about Collatz dynamics. If false, it would reveal unexpected structure in the Collatz dependency graph.\n\n**Catalog References**: `Algebra/CollatzUndecidable.lean` (conjecture_iff_all_bounded), `Applications/AntiGravity/Advanced.lean` (generalized_anti_gravity_pigeonhole)\n\n**Proof Strategy**: (1) Define the Collatz GDS formally. (2) Use the existing conjecture_iff_all_bounded to assume all trajectories terminate. (3) Compute weights by counting preimages in the Collatz map. (4) Apply the generalized pigeonhole to get existence, then refine with number-theoretic density estimates for the 1/log N bound.\n\n**Domain Bridges**: Number theory (Collatz) \u2194 Anti-gravity combinatorics \u2194 Dynamical systems\n\n**Lineage**: Cross-connects with the Catalog's Collatz undecidability results.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Anti-Gravity Oracle Complexity\n\n**Conjecture**: Define an \"oracle-weighted\" GDS where each theorem has access to an oracle (as in `Computation/OmniscientOracle.lean`). The oracle reduces proof effort but doesn't change weights. Conjecture: for any oracle O, the anti-gravity fraction of the oracle-augmented system is at least the anti-gravity fraction of the original system.\n\n**Test**: Construct GDS instances where oracle access reduces some proof efforts to 1. Verify that the AG fraction increases or stays the same.\n\n**Impact**: If true, this would establish a monotonicity principle: **better proof technology (oracles) can only increase anti-gravity**. This has philosophical implications: as proof assistants and AI improve, the structural asymmetry between simple foundational results and complex specialized ones can only grow more pronounced.\n\n**Catalog References**: `Computation/OmniscientOracle.lean` (fundamental_theorem_oracle'), `Applications/AntiGravity/Advanced.lean` (antiGrav_shrinks_under_effort_scaling)\n\n**Proof Strategy**: Oracle access reduces effort: \u03c0_O(v) \u2264 \u03c0(v). Since deps are unchanged, w_O(v) = w(v). If \u03c0(v) < w(v), then \u03c0_O(v) \u2264 \u03c0(v) < w(v), so AG(G) \u2286 AG(G_O). The conjecture is essentially a corollary of effort monotonicity, but the formalization requires careful handling of oracle types.\n\n**Domain Bridges**: Computability theory \u2194 Anti-gravity combinatorics \u2194 Proof complexity\n\n**Lineage**: Extends the effort scaling theorem to oracle-augmented systems.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0845",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "778aa955",
    "status": "available",
    "timestamp": "2026-06-06T15:17:09.357799+00:00",
    "title": "**Gravitational Derivation Systems** (GDS), a nov"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: EML Fixed-Point Theory\n\n## Synthesis\n\nThis cycle established the foundational contraction theory for the EML operator f(x) = e^a \u00b7 log(x + c), proving derivative bounds, Lipschitz estimates via MVT, uniqueness of fixed points, geometric convergence at rate \u03c1 = e^a/(L+c), and a composition theorem for cascaded EML layers. The most promising cross-domain connection discovered is the **bridge between EML contraction theory and the General C\u00b9 Contraction Principle**: any smooth map with bounded derivative is automatically Lipschitz, and the EML case is the canonical example with an explicitly computable, monotonically decaying derivative.\n\nThe composition theorem (Theorem 3.8) opens a direct path to neural network convergence certification: a deep feedforward network of EML layers has contraction ratio equal to the product of layer ratios. This multiplicative structure mirrors the spectral radius theory of linear operators, suggesting a deeper algebraic connection between EML dynamics and operator semigroup theory (linking to `contraction_convergence_rate` in `Algebra/SpectralArithmetic/Core.lean`).\n\nThe most high-impact direction is **Direction 1** (Invariant Interval Existence), which would close the main gap in the current theory \u2014 the assumption that iterates stay in the contraction domain. This would yield a fully self-contained convergence theorem requiring only parameter conditions, with no auxiliary hypotheses on trajectories.\n\n---\n\n### Direction 1: EML Invariant Interval Existence and Banach Complete Convergence\n\n**Conjecture**: For all a \u2208 (0, log(1 + c)) with c > 0, there exists an interval [L, U] \u2282 (\u2212c, \u221e) such that the EML operator f(x) = e^a \u00b7 log(x + c) maps [L, U] into itself, and e^a < L + c (contraction condition). Specifically, L and U can be chosen as the two solutions of e^a \u00b7 log(x + c) = x when they exist, with the fixed point x* lying between them.\n\n**Test**: For a = 0.5, c = 1.0, verify computationally that the equation e^0.5 \u00b7 log(x + 1) = x has solutions bounding the fixed point x* \u2248 1.143. Then prove in Lean 4 that f([L, U]) \u2286 [L, U] using monotonicity of f and the intermediate value theorem.\n\n**Impact**: Removes the `hiter` hypothesis from `eml_iteration_convergence`, yielding a clean theorem: \"For a \u2208 (0, log(1+c)), the EML iteration converges to a unique fixed point from any starting point in the invariant interval.\" This would be a complete, practical convergence certificate.\n\n**Catalog References**: `EML/FixedPoint.lean` (this cycle), `contraction_fixed_point_unique` in `EML/SocialCreditDynamics.lean`\n\n**Proof Strategy**: (1) Show f is concave on (\u2212c, \u221e) by computing f''(x) = \u2212e^a/(x+c)\u00b2 < 0. (2) Use concavity + continuity to prove that the graph of f crosses y = x at most twice. (3) If f(L\u2080) > L\u2080 and f(U\u2080) < U\u2080 for suitable L\u2080, U\u2080, then by IVT and monotonicity, f maps [L\u2080, U\u2080] into itself. (4) Apply the existing `eml_fixed_point_unique` and `eml_iteration_convergence`.\n\n**Domain Bridges**: EML Contraction Theory \u2194 Dynamical Systems (invariant sets, attracting basins)\n\n**Lineage**: Builds on `eml_iteration_convergence` and `emlFun_lipschitz_on_Ici` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 2: Tropical Limit of EML Fixed Points as a \u2192 \u221e\n\n**Conjecture**: As a \u2192 \u221e with c fixed, the rescaled fixed point x*(a)/e^a converges to a limit that satisfies the tropical (min-plus) fixed-point equation. Specifically, if we define z(a) = x*(a)/e^a, then lim_{a\u2192\u221e} z(a) = log(c) (the tropical logarithm of c). The contraction ratio \u03c1(a) \u2192 1 as a \u2192 \u221e, and the convergence transitions from geometric to algebraic.\n\n**Test**: Compute x*(a)/e^a numerically for a = 1, 2, 5, 10, 20 with c = 1. Check whether the sequence approaches log(1) = 0. If not, find the correct scaling and limit.\n\n**Impact**: Establishes a rigorous bridge between EML contraction dynamics and tropical algebra, the \"dequantization\" of classical mathematics. This would connect the catalog's EML results to the tropical computing strand (`MachineLearning/TropicalCTC.lean`, `Tropical/` family).\n\n**Catalog References**: `contraction_unique_fixed_point` in `MachineLearning/TropicalCTC.lean`, `EML/FixedPoint.lean`\n\n**Proof Strategy**: (1) From the exponential form exp(x*/e^a) = x* + c, substitute z = x*/e^a to get exp(z) = z\u00b7e^a + c. (2) For large a, the z\u00b7e^a term dominates, so z \u2248 c\u00b7e^{-a} \u2192 0. But x* \u2248 e^a \u00b7 log(c + e^a \u00b7 z) \u2248 e^a \u00b7 a for large a. Careful asymptotic expansion needed. (3) Formalize the limit using Lean 4's `Filter.Tendsto` framework.\n\n**Domain Bridges**: EML Fixed-Point Theory \u2194 Tropical Algebra (min-plus semirings, dequantization)\n\n**Lineage**: Builds on `eml_fixed_point_exp_form` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: EML Operator Semigroup and Spectral Theory\n\n**Conjecture**: The set of EML operators {T_{a,c} : a > 0, c > 0} forms a semigroup under composition (with appropriate parameter transformations), and the \"spectral radius\" of this semigroup \u2014 defined as the infimum of n-th root contraction ratios \u2014 equals the contraction ratio at the fixed point, \u03c1 = |f'(x*)|. Moreover, this spectral radius satisfies a variational formula analogous to the Gelfand formula for linear operators.\n\n**Test**: (1) Verify computationally that composing T_{a\u2081,c\u2081} with T_{a\u2082,c\u2082} gives a function of the form e^{a\u2083} \u00b7 log(g(x)) where g is not linear \u2014 so the semigroup is NOT closed in the EML family. (2) Check whether the contraction ratio of T^n (n-fold self-composition) satisfies \u03c1(T^n) = \u03c1(T)^n exactly. (3) If not, investigate whether lim \u03c1(T^n)^{1/n} = |f'(x*)|.\n\n**Impact**: Would establish EML operators as a nonlinear analogue of bounded linear operators on Banach spaces, with a coherent spectral theory. The Gelfand formula for nonlinear contractions would be a novel result in nonlinear functional analysis.\n\n**Catalog References**: `contraction_convergence_rate` in `Algebra/SpectralArithmetic/Core.lean`, `eml_composition_contraction_ratio` from this cycle\n\n**Proof Strategy**: (1) Compute T^n explicitly by induction. (2) Show that T^n has contraction ratio at most \u03c1^n (already proved). (3) For the lower bound, exhibit sequences where |T^n(x) - T^n(y)| / |x - y| \u2192 \u03c1^n. (4) Take n-th roots and send n \u2192 \u221e.\n\n**Domain Bridges**: EML Dynamics \u2194 Operator Algebra (semigroup theory, spectral radius)\n\n**Lineage**: Builds on `eml_composition_contraction_ratio` and `general_C1_contraction_on_Icc` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Parametric Sensitivity and Implicit Function Theorem for EML Fixed Points\n\n**Conjecture**: The fixed point x*(a, c) of the EML operator is a smooth function of the parameters (a, c) in the contraction region {(a,c) : a < log(x* + c)}. Specifically, \u2202x*/\u2202a = x* \u00b7 (x* + c) / (x* + c \u2212 e^a) and \u2202x*/\u2202c = e^a / (x* + c \u2212 e^a), obtained by implicit differentiation of x* = e^a \u00b7 log(x* + c).\n\n**Test**: Verify numerically that the finite-difference approximation of \u2202x*/\u2202a matches the formula above for a = 0.5, c = 1.0. Then prove the formula in Lean 4 using HasDerivAt for implicit functions.\n\n**Impact**: Enables gradient-based optimization of EML network parameters with certified derivatives. This is the key ingredient for backpropagation through EML layers with convergence guarantees.\n\n**Catalog References**: `EML/FixedPoint.lean`, `eml_gradient_log_bounded` in `EML/EMLNeuralNetworks.lean`\n\n**Proof Strategy**: (1) Define F(a, c, x) = e^a \u00b7 log(x + c) \u2212 x. (2) At the fixed point, F = 0 and \u2202F/\u2202x = e^a/(x+c) \u2212 1 = \u03c1 \u2212 1 \u2260 0 (since \u03c1 < 1). (3) Apply the Implicit Function Theorem to get smoothness of x*(a,c). (4) Compute partial derivatives by implicit differentiation.\n\n**Domain Bridges**: EML Fixed-Point Theory \u2194 Optimization (gradient computation, sensitivity analysis)\n\n**Lineage**: Builds on `eml_fixed_point_exp_form` and `emlFun_hasDerivAt` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Complex EML Dynamics and Julia Sets\n\n**Conjecture**: For the complex EML operator f(z) = e^a \u00b7 Log(z + c) where Log is the principal branch, the Julia set (boundary of the basin of attraction of the fixed point) is connected when a < log(|z* + c|) and totally disconnected when a exceeds a critical value a_crit(c). This parallels the Mandelbrot-Julia correspondence for z\u00b2 + c.\n\n**Test**: Plot the basin of attraction numerically for c = 1 and several values of a \u2208 (0, 3). Look for the connectivity transition. Estimate a_crit empirically.\n\n**Impact**: Would establish the first rigorous connection between EML dynamics and holomorphic dynamics / fractal geometry. The EML family would join z\u00b2 + c as one of the few families with completely understood bifurcation structure.\n\n**Catalog References**: `EML/FixedPoint.lean`, `emlContractionRatio_lt_one`\n\n**Proof Strategy**: (1) Extend the contraction analysis to \u2102 using the complex derivative |f'(z)| = e^a / |z + c|. (2) The contraction region in \u2102 is {z : |z + c| > e^a}, a disk complement. (3) Use Montel's theorem and the classification of Fatou components to analyze the Julia set. (4) The connectivity transition should occur at the parameter value where the critical point z = \u2212c escapes to infinity.\n\n**Domain Bridges**: EML Dynamics \u2194 Complex Dynamics (Julia sets, Mandelbrot set, holomorphic iteration)\n\n**Lineage**: Builds on the real contraction analysis from this cycle, extending to the complex plane.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_0848",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "e8c0d633",
    "status": "available",
    "timestamp": "2026-06-06T15:56:33.124130+00:00",
    "title": "Foundational contraction theory for the EML operator"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Matroid Minor Theory and Obstruction Spectra\n\n## Synthesis\n\nThis research cycle established a rigorous framework for studying matroid minor theory through the lens of *obstruction spectra* \u2014 rank-graded distributions of excluded minors for minor-closed matroid classes. The key insight is that the Robertson-Seymour theorem and its conjectured generalization to representable matroids can be studied quantitatively through spectral analysis, rather than only as a qualitative WQO question.\n\nThree cross-domain connections emerged as particularly promising: (1) the palindromy of obstruction spectra under matroid duality connects to the rich existing theory of self-dual codes in coding theory and algebraic geometry; (2) the growth-bounded obstruction system links the Growth Rate Theorem (a structural result about matroid density) to the complexity of excluded minor characterizations; and (3) the minor-closed lattice structure connects to the lattice of varieties in universal algebra, suggesting potential category-theoretic unifications.\n\nThe direction with highest breakthrough potential is Direction 1 (Spectral Rigidity), because a proof that the obstruction spectrum uniquely determines a minor-closed class (up to some equivalence) would transform the GGW conjecture from a finiteness question into a classification problem with computable invariants. The width-total relationship (proved: width \u2264 total) is the first step, but much sharper bounds should hold for structured classes.\n\n---\n\n### Direction 1: Spectral Rigidity for Representable Matroid Classes\n\n**Conjecture**: For GF(q)-representable matroids with q prime, two distinct minor-closed classes with the same obstruction spectrum must differ at rank \u2264 2q. More precisely: if two minor-closed classes C\u2081, C\u2082 of GF(q)-representable matroids have identical obstruction spectra and agree on all matroids of rank \u2264 2q, then C\u2081 = C\u2082.\n\n**Test**: Enumerate all minor-closed classes of binary matroids (GF(2)) with total obstruction count \u2264 5. For each pair with the same spectrum, check whether they agree on matroids of rank \u2264 4. If any counterexample is found among binary matroids, the conjecture fails at the simplest case.\n\n**Impact**: If true, this would mean the obstruction spectrum plus low-rank data completely determines a minor-closed class. This would provide a \"fingerprint\" for minor-closed classes that could be computed incrementally (checking low ranks first), making the GGW conjecture computationally approachable.\n\n**Catalog References**: `Novelty/MatroidMinors/Basic.lean` (ObstructionSpectrum, exists_of_wqo), `Novelty/MatroidMinors/Duality.lean` (SpectralDualityPair)\n\n**Proof Strategy**: First establish that the spectrum determines the multiset of ranks of excluded minors. Then use properties of GF(q)-representable matroids (the Dowling geometry bound, the Growth Rate Theorem) to show that for fixed rank r, the number of simple GF(q)-representable matroids of rank r with n elements is polynomially bounded. Combined with the spectral constraint, this limits the possibilities for excluded minors at each rank.\n\n**Domain Bridges**: Matroid Theory <-> Coding Theory (self-dual codes as self-dual matroids) <-> Algebraic Geometry (representable matroids as point configurations)\n\n**Lineage**: Builds on ObstructionSpectrum and exists_of_wqo from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Palindromic Spectral Structure and Self-Dual Matroid Classes\n\n**Conjecture**: For every self-dual minor-closed class of matroids representable over GF(q) with q odd, the obstruction spectrum satisfies a *strict* palindromic inequality: spectrum(r) \u2265 spectrum(r+1) for r < maxGroundRank/2. That is, obstructions are concentrated at low and high ranks, with a monotone decrease toward the center.\n\n**Test**: Compute the obstruction spectrum for the self-dual minor-closed classes of GF(3)-representable matroids (whose excluded minors include U\u2082,\u2085, U\u2083,\u2085, F\u2087, F\u2087*). Verify: spectrum(2) = 1 \u2265 spectrum(3) = 2? If spectrum(3) > spectrum(2), the strict inequality fails, but a weaker \"near-palindromic\" version might hold after accounting for the duality pairing.\n\n**Impact**: If true, this constrains the search for unknown excluded minors: for self-dual classes, most excluded minors live at extreme ranks. If false, the failure mode would reveal which self-dual classes violate the monotonicity and why \u2014 likely connected to the existence of self-dual excluded minors (matroids isomorphic to their own duals).\n\n**Catalog References**: `Novelty/MatroidMinors/Duality.lean` (self_dual_palindromic, palindromic_center)\n\n**Proof Strategy**: Use the palindromic theorem (self_dual_palindromic) as a starting point. For the monotonicity, analyze the possible structure of excluded minors at ranks near maxGroundRank/2. Key lemma needed: for GF(q)-representable matroids, the number of matroids of rank r with \u2264 n elements is bounded by a function of q, r, and n that grows faster in r, implying more \"room\" for excluded minors at extreme ranks.\n\n**Domain Bridges**: Matroid Theory <-> Algebraic Coding Theory (palindromic weight enumerators of self-dual codes)\n\n**Lineage**: Builds directly on SpectralDualityPair.self_dual_palindromic from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Lattice Structure of Minor-Closed Classes and M\u00f6bius Functions\n\n**Conjecture**: The lattice of minor-closed classes of GF(q)-representable matroids (ordered by inclusion) has a well-defined M\u00f6bius function \u03bc, and for any two classes C\u2081 \u2282 C\u2082, the M\u00f6bius value \u03bc(C\u2081, C\u2082) equals (-1)^k times a product of combinatorial invariants, where k = |ExcludedMinors(C\u2082) \\ ExcludedMinors(C\u2081)|.\n\n**Test**: Compute the lattice of minor-closed classes of binary matroids with \u2264 3 excluded minors. Compute the M\u00f6bius function on this finite lattice and check whether it factors as predicted. The lattice should include: class of all matroids (0 excluded minors), class excluding U\u2082,\u2084 (1), class excluding U\u2082,\u2084 and some specific matroid (2), etc.\n\n**Impact**: A closed-form M\u00f6bius function would connect matroid minor theory to enumerative combinatorics via the M\u00f6bius inversion formula. This could yield counting formulas for matroids in a class using inclusion-exclusion over excluded minors.\n\n**Catalog References**: `Novelty/MatroidMinors/Duality.lean` (MinorClosedLattice, meet_excluded_minors, top_no_excluded_minors, bot_excluded_minors_characterization)\n\n**Proof Strategy**: Start with the meet decomposition theorem (meet_excluded_minors) to understand how excluded minor sets combine under lattice operations. Then compute the M\u00f6bius function on small examples using the recursive definition. Look for a pattern in terms of the \"overlap\" between excluded minor sets.\n\n**Domain Bridges**: Matroid Theory <-> Order Theory (M\u00f6bius functions) <-> Enumerative Combinatorics (inclusion-exclusion)\n\n**Lineage**: Builds on MinorClosedLattice from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical Matroid Minors and Valuated WQO\n\n**Conjecture**: Tropical matroids (matroids defined over the tropical semiring) with bounded coefficients are well-quasi-ordered under a suitably defined \"tropical minor\" relation. This would extend the Robertson-Seymour theory from classical fields to the tropical semiring, connecting to the existing tropical optimization work in the Catalog.\n\n**Test**: Define a tropical matroid as a valuated matroid (a matroid with a valuation on its bases). Define tropical deletion and contraction. Construct the first 10 tropical matroids in a natural enumeration and verify that no two form an antichain under tropical minors. A single antichain pair would disprove the conjecture.\n\n**Impact**: If true, this would extend the GGW conjecture to a fundamentally new algebraic setting (the tropical semiring), bridging combinatorial optimization and structural matroid theory. The forbidden minor characterization would yield finite certificates for tropical matroid properties relevant to optimization.\n\n**Catalog References**: `Tropical/GL3FiniteTestFamily.lean`, `Novelty/MatroidMinors/Basic.lean` (MatroidMinorSystem, WQO)\n\n**Proof Strategy**: First formalize tropical matroids as valuated matroids in Lean 4. Define tropical deletion (restrict the valuation) and tropical contraction (quotient the valuation). Prove that the tropical minor relation is reflexive and transitive. Then attempt to show WQO by adapting the Nash-Williams tree theorem argument used in the Robertson-Seymour proof.\n\n**Domain Bridges**: Matroid Theory <-> Tropical Geometry <-> Combinatorial Optimization\n\n**Lineage**: Combines MatroidMinorSystem from this cycle with existing Tropical catalog entries.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Effective Bounds on Excluded Minor Size\n\n**Conjecture**: For GF(q)-representable matroids, every excluded minor for a minor-closed class with growth rate at most f(r) has at most g(f, q) \u00b7 r elements, where g is a computable function. Specifically, for quadratic growth (f(r) = O(r\u00b2)), excluded minors have at most Cq \u00b7 r\u00b2 elements for a constant Cq depending only on q.\n\n**Test**: For binary matroids (q=2), verify that every known excluded minor for representability (just U\u2082,\u2084 with 4 elements, rank 2) satisfies |E| \u2264 C\u2082 \u00b7 r\u00b2 = C\u2082 \u00b7 4 for some reasonable C\u2082. For ternary matroids, check the 4 known excluded minors. Find the smallest C\u2083 that works.\n\n**Impact**: Effective size bounds would make the search for excluded minors computationally feasible: instead of searching all matroids, one only needs to search matroids of bounded size at each rank. Combined with spectral analysis, this could yield a practical algorithm for discovering excluded minors.\n\n**Catalog References**: `Novelty/MatroidMinors/Basic.lean` (GrowthBoundedObstructionSystem, obstruction_size_bound)\n\n**Proof Strategy**: Use the growth rate bound to limit the number of elements in a matroid of given rank. Then use the minor-minimality of excluded minors: every element and every pair of elements is \"essential\" (deletion or contraction reduces the obstruction). This essentiality constrains the structure tightly.\n\n**Domain Bridges**: Matroid Theory <-> Computational Complexity (decidability of minor testing) <-> Finite Geometry (counting points in projective spaces)\n\n**Lineage**: Builds on GrowthBoundedObstructionSystem from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0857",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "133c7706",
    "status": "available",
    "timestamp": "2026-06-06T17:37:48.673497+00:00",
    "title": "Rigorous framework for studying matroid minor"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Asymmetric Duration Games\n\n## Synthesis\n\nThis research cycle introduced **Asymmetric Duration Games (ADGs)** \u2014 a framework for studying games between players of unequal computational power, where the central quantity is the *ordinal survival value*. The ascending strategy provides a universal \u03c9-survival witness, and bounded nondeterminism amplifies survival to \u03c9\u00b2. The formal verification confirmed that all results hold in full generality on arbitrary infinite state spaces.\n\nThe most promising cross-domain connection is between the survival algebra and **ordinal analysis in proof theory**. The hierarchy of survival values (\u03c9, \u03c9\u00b2, \u03c9\u00b3, ..., \u03c9\u03c9, ..., \u03b5\u2080) mirrors the ordinal hierarchy used to measure the proof-theoretic strength of formal systems. A deep connection would relate the survival ordinal of a game to the proof-theoretic ordinal of the theory needed to prove determinacy. The Evasion Duality theorem \u2014 showing that increasing Eternity's power doesn't change the survival class \u2014 is reminiscent of conservation theorems in proof theory (e.g., \u03a0\u2081\u00b9-CA\u2080 is conservative over ATR\u2080 for arithmetic sentences). The **Diagonal Lemma** connects to Cantor's diagonal argument and the fixed-point lemma in logic, suggesting that the survival algebra may encode logical self-reference.\n\nThe highest breakthrough potential lies in **Direction 1** (Higher Ordinal Survival via Recursive Nondeterminism), because establishing constructive strategies for \u03c9\u03c9-survival would connect to fast-growing hierarchies and potentially to independence results in arithmetic. Direction 3 (Strategy Complexity Classification) could yield surprising results connecting game-theoretic survival to computational complexity classes.\n\n---\n\n### Direction 1: Higher Ordinal Survival via Recursive Nondeterminism\n\n**Conjecture**: There exists an explicit Mortal strategy achieving \u03c9\u207f-survival for all n \u2208 \u2115, constructed by n-fold composition of the bounded nondeterminism amplification. Specifically, define the *level-n ascending strategy* inductively: level 0 is the ascending strategy; level (n+1) uses level-n as a subroutine within each of k epochs, where k is chosen nondeterministically. Then for all finite k\u2081, k\u2082, ..., k\u2099, Mortal survives k\u2081 \u00b7 k\u2082 \u00b7 ... \u00b7 k\u2099 rounds.\n\n**Test**: Formalize the level-n strategy in Lean 4 and prove survival for n = 3 (\u03c9\u00b3-survival, meaning \u2200 a b c : \u2115, Nonempty (SurvivalCert (a * b * c))). If this holds, test n = 4. If it fails, identify which step of the induction breaks.\n\n**Impact**: If true, the full hierarchy to \u03c9\u03c9 is constructive and the survival algebra becomes isomorphic to the ordinal arithmetic below \u03b5\u2080. This would connect ADGs to Gentzen-style consistency proofs and the fast-growing hierarchy. If false at some level n\u2080, the obstruction would reveal a computational complexity barrier \u2014 the strategy's computational requirements grow too fast.\n\n**Catalog References**: `Computation/Evasion.lean` (TransfiniteEvasion structure), `Computation/TransfiniteCADepth.lean` (bounded_implies_finite)\n\n**Proof Strategy**: \n1. Define `levelStrategy : \u2115 \u2192 MortalStrat` inductively.\n2. Prove `levelStrategy n` is safe for all n (by induction, reducing to ascendingStrat_safe).\n3. Prove survival of `levelStrategy n` for duration `\u220f\u1d62 k\u1d62` for all finite sequences k\u2081, ..., k\u2099.\n4. The key lemma: `survival_multiplicative` \u2014 survival of composed strategies multiplies durations.\n\n**Domain Bridges**: Novelty/ADG <-> Computation/ITTM (survival ordinals vs. clockable ordinals), Novelty/ADG <-> Logic/ProofTheory (survival ordinals vs. proof-theoretic ordinals)\n\n**Lineage**: Builds on omega_survival and omega_squared_survival from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Continuous Evasion Games on \u211d and Measure-Theoretic Survival\n\n**Conjecture**: In the continuous evasion game on \u211d (where Eternity bans measurable sets of measure \u2264 \u03b5 per round), Mortal achieves \u03c9-survival if and only if \u03b5 < \u221e. Moreover, the survival value depends only on the measure constraint, not on the topology \u2014 a Lebesgue-null banning rate gives the same survival class as a finite banning rate.\n\n**Test**: Formalize the continuous evasion game using Mathlib's measure theory. Prove that if Eternity bans sets of measure \u2264 \u03b5 (for any fixed \u03b5 > 0), Mortal survives n rounds by picking from the complement (which has infinite measure). Show that if \u03b5 = \u221e, Mortal loses in 1 round.\n\n**Impact**: This would bridge combinatorial game theory with measure theory and geometric measure theory. The result that measure constraints don't change the survival class (only finite/infinite matters) would generalize the Evasion Duality to the continuous setting. If false (i.e., the measure constraint matters), it would reveal a deep difference between discrete and continuous evasion.\n\n**Catalog References**: `Novelty/AsymGameDefs.lean` (MortalStrat, EternityStrat), `Novelty/ComputationalHierarchy.lean` (GenEvasionGame for arbitrary types)\n\n**Proof Strategy**:\n1. Define `ContinuousEvasionGame (\u03bc : MeasureTheory.Measure \u211d)`.\n2. Use `MeasureTheory.Measure.compl_mem_cofinite` or similar to show complements are large.\n3. The key insight: in \u211d, the complement of a measure-\u03b5 set has infinite measure, so it's nonempty.\n4. Adapt the ascending strategy to work with real-valued positions.\n\n**Domain Bridges**: Novelty/ADG <-> Physics/ContinuumMechanics (evasion in physical space), Novelty/ADG <-> MachineLearning/PAC (adversarial learning as evasion game)\n\n**Lineage**: Extends gen_omega_survival (arbitrary infinite types) to measure-theoretic settings.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Strategy Complexity Classification \u2014 P vs NP of Evasion\n\n**Conjecture**: There exists a polynomial-time computable Mortal strategy achieving \u03c9-survival, but any strategy achieving \u03c9\u00b2-survival with nondeterminism requires at least exponential time in the nondeterminism parameter k. Specifically, the level-k ascending strategy requires O(2\u1d4f) time to compute.\n\n**Test**: Implement the ascending strategy and the nondeterministic amplification in Python. Measure the computation time as a function of k and n. Plot the time complexity and fit to polynomial/exponential models. In Lean, formalize a notion of \"strategy complexity\" as a function from \u2115 (round number) to \u2115 (computation steps) and prove bounds.\n\n**Impact**: A separation between \u03c9-survival complexity and \u03c9\u00b2-survival complexity would create a new complexity-theoretic hierarchy, where the difficulty of *being evasive* is classified by ordinals. This would connect to Kolmogorov complexity (the randomness of the evasion sequence) and to descriptive set theory (the Borel complexity of winning strategies).\n\n**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm), `Novelty/ComputationalHierarchy.lean` (MortalStrat.finiteState, ascending_not_finite_state)\n\n**Proof Strategy**:\n1. Define `StrategyComplexity (m : MortalStrat) : \u2115 \u2192 \u2115` measuring steps per round.\n2. Prove `ascendingStrat` has complexity O(n) (computing max of a set of size n).\n3. Prove lower bounds using diagonalization: any strategy with complexity < f(n) fails against an Eternity strategy that exploits the prediction gap.\n4. Connect to the BoundedEvasionStrategy structure in `Catalog/Computation/Evasion.lean`.\n\n**Domain Bridges**: Novelty/ADG <-> Computation/Complexity (evasion complexity classes), Novelty/ADG <-> Cryptography/OneWayFunctions (evasion as one-way function inversion)\n\n**Lineage**: Builds on ascending_not_finite_state and cardinality_is_finite_state from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Multiplayer Survival Coalitions\n\n**Conjecture**: When m Mortals cooperate against a single Eternity (who bans one position per round), the coalition's survival value is \u03c9 \u00b7 m \u2014 each additional Mortal contributes exactly one factor of \u03c9. Moreover, the optimal coalition strategy is for Mortals to \"spread out\" (each occupying a different region of \u2115), not to cluster.\n\n**Test**: Formalize a k-player evasion game where k Mortals each choose a position and Eternity bans one. Prove that k Mortals achieve \u03c9\u00b7k-survival by running k independent ascending strategies in k disjoint regions [k\u00b7i, k\u00b7(i+1)) of \u2115.\n\n**Impact**: This would establish a precise economy of survival: each additional cooperating player multiplies the survival ordinal by a fixed factor. If the conjecture is wrong (e.g., cooperation is superadditive), it would reveal synergistic effects in multi-agent evasion that don't exist in the single-player case.\n\n**Catalog References**: `Novelty/AsymGameDefs.lean` (LaneState, LaneMortalStrat), `Bridges/CondensationSemantics.lean` (finite_lattice_bounded_chain)\n\n**Proof Strategy**:\n1. Define `CoalitionGame (k : \u2115)` with k Mortal players and one Eternity.\n2. Define the \"spread\" strategy: Mortal i plays the ascending strategy in region [k\u00b7i, \u221e).\n3. Prove each Mortal survives n rounds independently (their regions are disjoint, so Eternity's ban in one region doesn't affect others... but Eternity gets to ban globally, so the key is that Eternity's single ban per round can only affect one Mortal's region at a time).\n4. By pigeonhole, at least one Mortal avoids bans for k\u00b7n rounds.\n\n**Domain Bridges**: Novelty/ADG <-> Bridges/CooperativeGameTheory (coalition formation), Novelty/ADG <-> MachineLearning/MultiAgent (multi-agent evasion)\n\n**Lineage**: Extends the lane amplification idea from this cycle to genuine multi-player settings.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Ordinal Game Values and Proof-Theoretic Ordinals\n\n**Conjecture**: The survival ordinal of the level-n evasion game equals \u03c9\u207f, and the survival ordinal of the game with access to a level-\u03c9 oracle equals \u03b5\u2080 (the proof-theoretic ordinal of Peano arithmetic). Furthermore, Mortal's ability to survive \u03b1 rounds in the oracle game implies that the theory PA can prove the well-foundedness of all ordinals below \u03b1.\n\n**Test**: Define the \"oracle evasion game\" where Mortal has access to a halting oracle for level-(n-1) strategies. Prove that the survival ordinal of the oracle game at level n is \u03c9\u207f. Formalize the correspondence between survival certificates and PA-proofs of well-foundedness.\n\n**Impact**: This would establish a direct bridge between game theory and proof theory \u2014 arguably the most important open connection in mathematical logic. The survival algebra would become a new model of ordinal analysis, providing game-theoretic proofs of proof-theoretic results (e.g., a game-theoretic proof of the consistency of PA via \u03b5\u2080-survival).\n\n**Catalog References**: `Computation/Evasion.lean` (TransfiniteEvasion), `Computation/GravityOracle.lean` (IsGravOracle, oracle-based computation)\n\n**Proof Strategy**:\n1. Define `OracleEvasionGame (n : \u2115)` where Mortal at level n has access to a halting oracle for level-(n-1).\n2. Prove by induction that the survival ordinal of level-n is \u03c9\u207f.\n3. The limit case: define `OracleEvasionGame \u03c9` using the sup construction.\n4. Prove the survival ordinal of the limit game is sup{\u03c9\u207f : n \u2208 \u2115} = \u03c9\u03c9.\n5. Extend to \u03b5\u2080 using the fixed-point construction \u03b5\u2080 = \u03c9^\u03b5\u2080.\n6. Connect to PA-provability via the correspondence between game strategies and proof terms.\n\n**Domain Bridges**: Novelty/ADG <-> Logic/ProofTheory (survival ordinals = proof-theoretic ordinals), Novelty/ADG <-> Computation/OracleHierarchy (oracle games = arithmetical hierarchy)\n\n**Lineage**: Builds on full_hierarchy and survival_geq_omega from this cycle, and on the Catalog's OracleHierarchy framework.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0862",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "851c68fb",
    "status": "available",
    "timestamp": "2026-06-06T18:43:57.514093+00:00",
    "title": "**Asymmetric Duration Games (ADGs)** \u2014 a framewor"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Research Directions: EML Approximation Filtration\n\n## Synthesis\n\nThis research cycle established the **EML Approximation Filtration** as a rigorous mathematical structure, proving 25+ theorems about the depth hierarchy, substitution bounds, and structural decomposition of EML expressions. The central discovery is that the EML expression language admits a *proper filtration* indexed by transcendental depth \u2014 each level is closed under field operations, composition adds depths, and the levels are strictly increasing. This filtration connects algebraic circuit complexity (depth, size) to approximation theory (\u03b5-cost) in a quantitatively precise way.\n\nThe most promising cross-domain connection from this cycle is between the **EML depth hierarchy** and **neural network expressiveness theory**. The strict hierarchy theorem \u2014 that iterated exponentials of depth n cannot be computed at depth n-1, regardless of width \u2014 is the EML analogue of the famous depth separation results in neural network theory (Telgarsky 2016, Eldan-Shamir 2016). The algebraic clarity of the EML framework may provide tools to attack depth separation questions for more realistic activation functions.\n\nThe highest-breakthrough-potential direction is **Direction 1: Multivariate EML and the Kolmogorov Superposition Connection**, because it bridges the well-understood univariate EML theory to Kolmogorov's superposition theorem, potentially yielding the first quantitative depth bounds for multivariate approximation.\n\n---\n\n### Direction 1: Multivariate EML and the Kolmogorov Superposition Connection\n\n**Conjecture**: Every continuous function f : [0,1]^n \u2192 \u211d can be represented as a composition of 2n+1 univariate EML expressions of depth \u2264 D(f), where D(f) depends only on the modulus of continuity of f and not on n. Specifically, if f has modulus \u03c9(\u03b4), then D(f) \u2264 C \u00b7 log(1/\u03c9(\u03b5)) for some universal constant C.\n\n**Test**: Formalize multivariate EML expressions with multiple variables. Attempt to prove that the Kolmogorov superposition functions (which are universal but highly non-smooth) can serve as the \"inner functions,\" and that the \"outer functions\" can be approximated by bounded-depth EML expressions. A concrete test: can f(x,y) = exp(exp(x\u00b7y)) be decomposed into univariate EML expressions of total depth 3?\n\n**Impact**: If true, this would provide the first *constructive* version of Kolmogorov's theorem with quantitative depth bounds. This bridges analysis (approximation theory), algebra (the EML filtration), and computation (circuit depth). If false, the failure would reveal fundamental limitations of the EML framework for multivariate functions, potentially identifying an \"irreducibly multivariate\" complexity phenomenon.\n\n**Catalog References**: `EML/ApproxFiltration/Theorems.lean`, `EML/KolmogorovArnoldEMLDeep.lean`, `EML/StoneWeierstrassApprox.lean`\n\n**Proof Strategy**:\n1. Define multivariate EMLExpr with indexed variables x\u2081, ..., x\u2099\n2. Prove that Kolmogorov's \u03bb-functions can be EML-approximated at bounded depth\n3. Use the substitution theorem (Theorem 6.1) to compose outer functions with inner functions\n4. Apply the depth additivity bound to control total depth\n5. The key technical challenge is controlling the depth of the outer functions, which depends on the smoothness of f via the inner functions\n\n**Domain Bridges**: Approximation Theory \u2194 Circuit Complexity \u2194 Neural Network Architecture\n\n**Lineage**: Builds on the EML Approximation Filtration theorems (this cycle), particularly `composition_filtration_bound`, `EMLExpr'.subst_eval`, and `EMLExpr'.subst_emlDepth_le`.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: EML Depth Separation via Analytic Continuation\n\n**Conjecture**: There exist functions in Level(n+1) that cannot be uniformly approximated by Level(n) functions on any compact interval [a,b] with a < b. Formally: for each n, there exists f_n and \u03b5_n > 0 such that no expression e with emlDepth(e) \u2264 n satisfies |f_n(x) - e.eval(x)| \u2264 \u03b5_n for all x \u2208 [0,1].\n\n**Test**: The candidate witness is iterExp'(n+1). Use the expRank invariant to show that any depth-n expression computes a function whose analytic continuation differs structurally from iterExp'(n+1). The expRank argument shows exact representation is impossible; the conjecture extends this to *approximate* representation. A computational test: sample random depth-n expressions with up to 1000 nodes and measure their maximum error against iterExp'(n+1) on [0,1].\n\n**Impact**: If true, this would be the first *approximation-theoretic* depth separation for EML, going beyond the exact-computation separation already proven. This is the EML analogue of the famous question \"does depth help for approximation?\" in neural network theory. If false, it would show that the depth hierarchy collapses under approximation \u2014 an equally significant and surprising result.\n\n**Catalog References**: `EML/ApproxFiltration/Theorems.lean`, `EML/Complexity/Basic.lean` (expRank_le_emlDepth, emlExprIterExp_eval)\n\n**Proof Strategy**:\n1. Show that depth-n expressions compute functions of bounded \"exponential growth rate\" (e.g., their Taylor coefficients satisfy specific recurrences)\n2. Show that iterExp'(n+1) violates these bounds on any interval\n3. The key lemma: if e has emlDepth \u2264 n, then for any compact K, there exists C(K,n) such that |e.eval(x)| \u2264 C \u00b7 iterExp'(n, |x|) for x \u2208 K\n4. Since iterExp'(n+1) grows superexponentially faster than iterExp'(n), this gives quantitative separation\n\n**Domain Bridges**: Approximation Theory \u2194 Complex Analysis \u2194 Model Theory (o-minimality)\n\n**Lineage**: Builds on `EMLExpr'.expRank_le_emlDepth`, `iterExp_mem_filtration`, and the depth hierarchy results from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: EML Complexity Spectrum Structure Theory\n\n**Conjecture**: The EML Complexity Spectrum of iterExp'(n) is exactly the set {(d, s) : d \u2265 n, s \u2265 2d+1}. More generally, for functions with \"irreducible transcendental content\" k, the spectrum is {(d, s) : d \u2265 k, s \u2265 2k + F(d-k)} where F is a computable function depending on the algebraic part of the function.\n\n**Test**: For n = 1, 2, 3, enumerate all EML expressions of size \u2264 20 and check whether they evaluate to iterExp'(n) on a grid. This gives empirical evidence for the lower bound on the spectrum. For the upper bound, construct explicit EML expressions at various (d, s) points.\n\n**Impact**: A complete characterization of the spectrum would give a \"complexity fingerprint\" for each function, analogous to how the spectrum of a matrix characterizes its eigenstructure. This would enable algorithmic optimization of EML circuits: given a function, find the Pareto-optimal representation.\n\n**Catalog References**: `EML/ApproxFiltration/Theorems.lean` (EMLComplexitySpectrum definition), `EML/ApproxFiltration/Defs.lean`\n\n**Proof Strategy**:\n1. Prove that the spectrum is upward-closed in both coordinates (adding dummy operations increases size/depth)\n2. Prove the lower bound: expRank gives d \u2265 n, and a new \"information-theoretic\" argument gives s \u2265 2n+1\n3. For the upper bound: construct explicit expressions at each achievable point using algebraic padding\n4. The hardest part is the tight lower bound on size at non-minimal depth\n\n**Domain Bridges**: Combinatorial Optimization \u2194 Circuit Complexity \u2194 Lattice Theory\n\n**Lineage**: Builds on `EMLComplexitySpectrum`, `emlExprIterExp'_size`, `emlExprIterExp'_emlDepth`, and the structural decomposition theorems from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical EML \u2014 The Max-Plus Analogue\n\n**Conjecture**: There exists a \"tropical EML\" language where `eml(a,b) = a + max(b, 0)` (the tropical analogue of a \u00b7 exp(b)), and the depth hierarchy theorem holds in this setting with the same witnesses: the tropical iterated exponential `trop_iterExp(n, x) = max(max(...max(x, 0)..., 0), 0)` requires depth exactly n.\n\n**Test**: Formalize the tropical EML language, define the tropical expRank, and attempt to prove the hierarchy theorem. Since tropical arithmetic is piecewise-linear, the proof should be more elementary than the transcendental case but may reveal different structural features.\n\n**Impact**: A tropical analogue would connect the EML theory to tropical geometry, piecewise-linear function theory, and ReLU neural networks (where the activation function is precisely max(x, 0)). This would bridge the EML framework to the most practically important class of neural networks.\n\n**Catalog References**: `Tropical/`, `EML/EMLTropicalSemiring.lean`, `EML/ApproxFiltration/Theorems.lean`\n\n**Proof Strategy**:\n1. Define TropicalEMLExpr with operations: var, const, add (= tropical \u00d7), max (= tropical +), and trop_eml(a,b) = a + max(b, 0)\n2. Define tropical expRank and emlDepth analogously\n3. Prove tropical expRank \u2264 tropical emlDepth (same structural argument should work)\n4. Show that tropical iterExp(n) has tropical expRank exactly n\n5. The tropical setting may admit constructive proofs since all functions are piecewise-linear\n\n**Domain Bridges**: Tropical Geometry \u2194 Neural Network Theory \u2194 Piecewise-Linear Approximation\n\n**Lineage**: Builds on the EML Approximation Filtration (this cycle) and the existing Tropical catalog entries.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: EML Description Complexity and Algorithmic Information\n\n**Conjecture**: The function n \u21a6 EMLSizeCost(f, 0, 1, 1/n) is computable for any computable f : [0,1] \u2192 \u211d. Moreover, for \"random\" continuous functions (in the sense of Wiener measure), EMLSizeCost(f, 0, 1, 1/n) grows as \u0398(n \u00b7 log(n)).\n\n**Test**: Implement an exact or bounded EML size cost computation for simple functions (polynomials, trigonometric functions, Weierstrass-type nowhere-differentiable functions). Compare empirical growth rates against the conjectured \u0398(n \u00b7 log(n)). For polynomials of degree d, verify that EMLSizeCost(p, 0, 1, 1/n) = O(d) (independent of n for exact representation).\n\n**Impact**: If true, this would establish EML size cost as a computable proxy for Kolmogorov complexity \u2014 one of the few known computable complexity measures with genuine information-theoretic content. The \u0398(n \u00b7 log(n)) growth rate for random functions would connect to Shannon entropy and optimal coding theory.\n\n**Catalog References**: `EML/UniversalApproxComplexity.lean`, `EML/ApproxFiltration/Theorems.lean`, `Algebra/EulerMascheroni/Series.lean` (gamma_approximation_complexity)\n\n**Proof Strategy**:\n1. For computability: show that the set {s | \u2203 e of size s approximating f to 1/n} is r.e. (recursively enumerable), so its infimum is computable from below\n2. For the growth rate: use covering number arguments \u2014 the set of EML functions of size s forms a (finitely parameterized) function class whose \u03b5-covering number can be bounded\n3. For the polynomial case: show that degree-d polynomials are in Level(0) with size O(d)\n4. The random function case requires Kolmogorov\u2013Chaitin theory adapted to the EML framework\n\n**Domain Bridges**: Algorithmic Information Theory \u2194 Approximation Theory \u2194 Statistical Learning Theory\n\n**Lineage**: Builds on `EMLSizeCost`, `EMLDepthCost_antitone_eps`, `EMLSizeCost_antitone_eps`, and the catalog entry `gamma_approximation_complexity`.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0873",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "aa79e64b",
    "status": "available",
    "timestamp": "2026-06-06T21:32:09.958773+00:00",
    "title": "**EML Approximation Filtration** as a rigoro"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Holographic Gravity as Quantum Error Correction\n\n## Synthesis\n\nThis cycle established a rigorous mathematical dictionary between holographic gravity and quantum error correction, with several key findings:\n\n1. The **holographic entropy cone** (characterized by MMI) is strictly smaller than the quantum entropy cone \u2014 holographic entanglement is fundamentally more structured.\n2. The **syndrome defect** fails the triangle inequality, revealing that gravitational curvature measures correlation rather than distance.\n3. The **Bekenstein-Hawking formula** emerges as a quantum coding theorem via the Singleton bound + Ryu-Takayanagi relation.\n4. **Flatness rigidity** provides a discrete analog of the theorem that vanishing curvature implies flat geometry.\n\nThe most promising cross-domain connection is between the *flatness rigidity theorem* and the theory of *valuations on distributive lattices*. When the total defect vanishes, entropy becomes a modular function \u2014 equivalently, a valuation on the lattice of finsets. This connects holographic gravity to combinatorial geometry (via M\u00f6bius functions) and to tropical geometry (where valuations play a central role). The next cycle should explore this connection.\n\nThe highest breakthrough potential lies in Direction 1 (Holographic Entropy Cone Inequalities Beyond MMI), as new entropy inequalities would directly constrain the geometry of spacetime.\n\n---\n\n### Direction 1: Holographic Entropy Cone Inequalities Beyond MMI\n\n**Conjecture**: For 4 boundary regions A, B, C, D of a holographic theory, there exist entropy inequalities beyond MMI and its permutations. Specifically, the cyclic inequality I(A:C) + I(B:D) \u2264 I(A:B) + I(B:C) + I(C:D) + I(D:A) should hold for holographic entropy profiles.\n\n**Test**: Formalize the 4-party holographic entropy cone. Enumerate all candidate linear inequalities and check which are satisfied by all holographic entropy vectors (using RT with graph-theoretic minimal cuts) but not by all quantum entropy vectors.\n\n**Impact**: If true, this gives new geometric constraints on spacetime beyond those captured by MMI. Each new inequality corresponds to a new consistency condition that gravity must satisfy.\n\n**Catalog References**: `Bridges/HolographicCoding.lean`, `Physics/StabilizerBounds.lean`\n\n**Proof Strategy**: Define a 4-party entropy profile on `Fin 4`. Enumerate the 2^4 = 16 subsets and their entropy values. The holographic constraint comes from minimizing over cuts in the RT graph. Check each candidate inequality computationally.\n\n**Domain Bridges**: Information theory (entropy cones) \u2194 Combinatorial optimization (minimal cuts) \u2194 Algebraic geometry (tropical varieties)\n\n**Lineage**: Extends the entropy cone separation theorem (`mmi_independent_of_ssa`).\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Valuations, Modularity, and Tropical Holography\n\n**Conjecture**: The modular entropy functionals (those with zero total defect) correspond exactly to the tropical entropy functions \u2014 functions that arise as limits of classical entropy under scaling. Formally, every modular HoloProfile is a tropical limit of a family of submodular profiles.\n\n**Test**: Characterize all modular HoloProfiles on Fin n for n = 3, 4. Show they form a convex cone isomorphic to the cone of nonneg measures on atoms. Prove or disprove that every modular profile arises as the tropical limit of a 1-parameter family of submodular profiles.\n\n**Impact**: This would establish a precise link between holographic flatness (zero gravity) and tropical geometry. The \"flat\" spacetimes would be exactly the tropical limit of curved spacetimes.\n\n**Catalog References**: `Bridges/HolographicCoding.lean` (modular_of_flat), `Tropical/` directory\n\n**Proof Strategy**: \n1. Prove that modular functions on `Finset (Fin n)` are determined by their values on singletons (this follows from the inclusion-exclusion/M\u00f6bius inversion on the subset lattice)\n2. Show the correspondence with nonneg measures\n3. Construct the tropical limit family\n\n**Domain Bridges**: Holographic gravity (flatness) \u2194 Tropical geometry (valuations) \u2194 Lattice theory (M\u00f6bius functions)\n\n**Lineage**: Extends `flat_of_zero_total_defect` and `modular_of_flat`.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Approximate Quantum Error Correction and Gravitational Anomalies\n\n**Conjecture**: When the Singleton bound is not tight (i.e., S(X) < N(X) - 2(D(X)-1)), the gap corresponds to the \"gravitational anomaly\" \u2014 a measure of how much the holographic code deviates from optimal. Specifically, the Singleton gap \u0394_S(X) = N(X) - 2D(X) + 2 - S(X) satisfies a monotonicity property: \u0394_S(X\u222aY) \u2265 max(\u0394_S(X), \u0394_S(Y)) for disjoint X, Y.\n\n**Test**: Formalize the Singleton gap as a function on regions. Prove or disprove the monotonicity conjecture. If true, prove that the gap is a submultiplicative functional.\n\n**Impact**: This would give a new \"anomaly\" functional on boundary regions, measuring how far from extremal the holographic code is. Non-zero anomaly = the code has redundancy = there is \"room\" for quantum error correction = the bulk can tolerate perturbations.\n\n**Catalog References**: `Physics/StabilizerBounds.lean` (quantum_singleton_bound_general), `Physics/HolographicGravity.lean` (rate_distance_tradeoff)\n\n**Proof Strategy**: Define \u0394_S(X) = N(X) - 2D(X) + 2 - S(X). Use the singleton_upper axiom to show \u0394_S \u2265 0. For monotonicity, use subadditivity of S and superadditivity of N (from N_additive on disjoint regions).\n\n**Domain Bridges**: Quantum error correction (code gaps) \u2194 Holographic gravity (anomalies) \u2194 Algebraic K-theory (defect invariants)\n\n**Lineage**: Extends `rate_distance_tradeoff` and `distance_bounded_by_redundancy`.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Entanglement Wedge Reconstruction as Functor\n\n**Conjecture**: The assignment of entanglement wedges to boundary regions (given by the RT formula) defines a functor from the poset of boundary regions to the poset of bulk regions, and this functor preserves certain structural properties (lattice homomorphism for nested regions, meets, joins under holographic constraints).\n\n**Test**: Formalize a category of \"boundary regions\" and \"bulk regions\" with appropriate morphisms. Define the RT assignment as a functor. Prove that it preserves meets (intersections) for holographic profiles satisfying MMI.\n\n**Impact**: This would establish entanglement wedge reconstruction as a categorical structure, opening the door to applying category-theoretic methods (adjunctions, monads, Kan extensions) to holographic gravity.\n\n**Catalog References**: `Bridges/HolographicCoding.lean` (Reconstructable, reconstructable_monotone)\n\n**Proof Strategy**: \n1. Define a `BulkRegion` type with an order structure\n2. Define the RT functor as a monotone map\n3. Use MMI to prove meet-preservation\n4. Study when join-preservation holds (may need additional axioms)\n\n**Domain Bridges**: Category theory (functors) \u2194 Holographic gravity (entanglement wedges) \u2194 Order theory (lattice homomorphisms)\n\n**Lineage**: Extends `reconstructable_monotone` from the Catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Computational Complexity of Holographic Codes\n\n**Conjecture**: The circuit complexity of preparing a holographic state (one whose entropy profile satisfies MMI) from a product state is \u03a9(n log n) for n boundary sites, in contrast to generic quantum states which can require exponential complexity.\n\n**Test**: Define a notion of \"holographic state complexity\" as the minimum circuit depth needed to produce an entropy profile satisfying MMI. Prove lower bounds using the constraint that MMI imposes on the structure of the entanglement.\n\n**Impact**: This would connect holographic gravity to computational complexity theory, potentially explaining why spacetime has the structure it does \u2014 because it's the simplest (lowest complexity) structure consistent with the quantum constraints.\n\n**Catalog References**: `Computation/InfoEfficientAlgorithms.lean`, `Physics/HolographicGravity.lean`\n\n**Proof Strategy**: Use the entropy cone constraints to bound the minimum number of entangling gates needed. MMI constrains the mutual information structure, which constrains the gate complexity via the small incremental entangling theorem.\n\n**Domain Bridges**: Computational complexity \u2194 Holographic gravity \u2194 Circuit lower bounds\n\n**Lineage**: New direction connecting to the Computation catalog.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0878",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "68788699",
    "status": "available",
    "timestamp": "2026-06-06T22:38:02.808375+00:00",
    "title": "Rigorous mathematical dictionary between holographic gr"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: The Periodic Table of Finite Groups\n\n## Synthesis\n\nThis research cycle established the **Group Genome** framework \u2014 a formal classification system for finite groups inspired by the chemical periodic table. The key contribution is the **derived depth** invariant, which precisely measures a solvable group's distance from commutativity, together with a seven-class chemical taxonomy (vacuum, noble gas, alkali, alkaline earth, halogen, transition metal, compound) and 16 machine-verified theorems establishing the framework's internal consistency.\n\nThe most promising cross-domain connection is between the derived depth and **spectral theory**. The derived series of a group can be viewed as a filtration, and the successive quotients G^(n)/G^(n+1) are abelian groups that carry a natural \"spectrum\" (their character group). This connects the chemical classification to harmonic analysis on groups \u2014 an entirely different branch of mathematics. The stability hierarchy (cyclic \u2192 abelian \u2192 nilpotent \u2192 solvable) corresponds to increasing complexity of the representation theory, suggesting that the derived depth controls the \"spectral width\" of a group.\n\nThe highest breakthrough potential lies in **Direction 1** (Derived Depth Bounds), which connects the Group Genome to number theory via prime factorization. A tight bound would make the genome truly predictive: given only |G|, one could constrain the possible derived depths and hence the chemical classes.\n\n---\n\n### Direction 1: Tight Derived Depth Bounds from Prime Factorization\n\n**Conjecture**: For a solvable group G of order `p\u2081^{a\u2081} \u00b7 p\u2082^{a\u2082} \u00b7 ... \u00b7 p\u2096^{a\u2096}`, the derived depth satisfies `d(G) \u2264 a\u2081 + a\u2082 + ... + a\u2096` (the total prime multiplicity, i.e., `\u03a9(|G|)`). Moreover, this bound is tight: for each n, there exists a solvable group of derived depth exactly n whose order has total prime multiplicity n.\n\n**Test**: Compute the derived depth for all solvable groups of order \u2264 100 and verify the bound. For tightness, construct explicit groups achieving `d(G) = \u03a9(|G|)` \u2014 the iterated wreath product `\u2124/p\u2124 \u2240 \u2124/p\u2124 \u2240 ... \u2240 \u2124/p\u2124` (n copies) should achieve derived depth n with order p^(p^(n-1)).\n\n**Impact**: If true, this gives the Group Genome predictive power comparable to Mendeleev's original table: knowing only the \"atomic number\" (group order), one can bound the \"chemical properties\" (derived depth, hence chemical class). If false, the failure would identify groups where the derived series \"wastes\" steps \u2014 a structurally interesting phenomenon.\n\n**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (derivedDepth, derivedSeries_strictAnti_lt_depth)\n\n**Proof Strategy**: For the upper bound, proceed by induction on \u03a9(|G|). The key step: if G is solvable and nontrivial, then G/G' is a nontrivial abelian group, so |G'| < |G|, and \u03a9(|G'|) < \u03a9(|G|). By induction, d(G') \u2264 \u03a9(|G'|), and d(G) = d(G') + 1 \u2264 \u03a9(|G'|) + 1 \u2264 \u03a9(|G|). For the lower bound, construct iterated semidirect products or wreath products explicitly.\n\n**Domain Bridges**: Number Theory \u2194 Group Theory (prime factorization controls group structure), Novelty \u2194 Algebra (extending the Group Genome with quantitative bounds)\n\n**Lineage**: Builds on `derivedDepth_pos_of_nontrivial`, `derivedSeries_strictAnti_lt_depth`, and `derivedDepth_le_one_iff_comm` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: The Fitting Stratigraphy \u2014 Extending the Genome Beyond Solvability\n\n**Conjecture**: Define the **Fitting height** `h(G)` as the minimum length of a Fitting series (ascending chain where each quotient is the Fitting subgroup of the remainder). Then for a solvable group, `h(G) \u2264 d(G) \u2264 2\u00b7h(G)`. Moreover, define the **chemical valence** as the number of distinct primes dividing the order of the Fitting subgroup. Then groups with the same Fitting height and chemical valence have the same chemical class in the Group Genome taxonomy.\n\n**Test**: Compute Fitting heights for solvable groups of order \u2264 200. Verify the inequality chain d(G)/2 \u2264 h(G) \u2264 d(G). Check whether chemical valence correctly predicts class membership.\n\n**Impact**: The Fitting height is in some sense the \"correct\" complexity measure for solvable groups (it equals the length of the shortest normal series with nilpotent factors). Connecting it to derived depth would unify two different measures of group complexity. The Fitting subgroup acts as the \"core\" of a solvable group, analogous to the electron core of an atom.\n\n**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (ChemicalClass, derivedDepth)\n\n**Proof Strategy**: Use the fact that each step of the Fitting series reduces both the derived length and the Fitting height. The upper bound d(G) \u2264 2\u00b7h(G) follows because each Fitting quotient is nilpotent, hence its derived length is bounded by its nilpotency class. Formalize the Fitting subgroup in Lean (if not already in Mathlib) and prove the chain of inequalities.\n\n**Domain Bridges**: Algebra \u2194 Novelty (Fitting theory enriches the chemical classification)\n\n**Lineage**: Direct extension of the Group Genome framework from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Spectral Width of the Derived Filtration\n\n**Conjecture**: For a finite solvable group G, define the **spectral width** as `\u03c3(G) = \u03a3_{i=0}^{d(G)-1} rank(G^(i)/G^(i+1))`, where rank denotes the minimum number of generators of the abelian group G^(i)/G^(i+1). Then \u03c3(G) equals the minimum number of generators of G. In other words, the \"total rank\" of the derived filtration equals the generating number.\n\n**Test**: Compute \u03c3(G) and the minimum generating number for all solvable groups of order \u2264 60. A single counterexample disproves the conjecture. If the equality fails, test whether \u03c3(G) \u2265 d(G) always holds (a weaker but still interesting bound).\n\n**Impact**: This would establish a deep connection between the \"vertical\" structure of a group (its derived filtration) and its \"horizontal\" structure (its generating set). It would mean that the derived depth captures not just qualitative non-commutativity but quantitative complexity. If false, the discrepancy \u03c3(G) - d(G) would define a new invariant measuring how \"efficiently\" the derived series captures the group's structure.\n\n**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (derivedSeries_strictAnti_lt_depth), `Novelty/CollatzSpectral/Theorems.lean` (spectral methods)\n\n**Proof Strategy**: For abelian groups, \u03c3(G) = rank(G) which equals the minimum generating number by the structure theorem. For general solvable groups, use the Burnside basis theorem and properties of the Frattini subgroup to relate generators to the first quotient G/G'.\n\n**Domain Bridges**: Algebra \u2194 Computation (generation complexity), Novelty \u2194 EML (spectral analysis of algebraic objects)\n\n**Lineage**: Extends the strict monotonicity theorem from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Chemical Reaction Rules \u2014 Semidirect Products and Extensions\n\n**Conjecture**: Define a **chemical reaction** as a group extension `1 \u2192 N \u2192 G \u2192 Q \u2192 1`. Then the chemical class of G is determined by the chemical classes of N and Q together with the action of Q on N, according to explicit \"reaction rules.\" Specifically:\n- Noble Gas + Noble Gas \u2192 Noble Gas or Alkali (direct product: noble gas iff coprime orders)\n- Halogen + Noble Gas \u2192 Halogen or Alkaline Earth\n- Transition Metal + anything \u2192 Compound (if extension is non-split)\n\n**Test**: Enumerate all semidirect products \u2124/p\u2124 \u22ca \u2124/q\u2124 for primes p, q \u2264 19 and verify the reaction rules. Then test split extensions of S\u2083 by \u2124/n\u2124 for n \u2264 10.\n\n**Impact**: This would make the Group Genome truly predictive for group construction: given the \"reactants\" (N and Q), one could predict the \"product\" (G) without computing G explicitly. This is the group-theoretic analogue of predicting reaction products from reactant properties.\n\n**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (classifyGroup, prod_solvable, prod_nilpotent)\n\n**Proof Strategy**: Use the fact that extensions preserve solvability (if both N and Q are solvable, G is solvable). For nilpotency, the situation is more delicate: G is nilpotent iff the extension is central. Formalize the extension classification for semidirect products and prove the reaction rules case by case.\n\n**Domain Bridges**: Algebra \u2194 Novelty (extension theory as chemical reactions), Bridges \u2194 Novelty (closure operators on group extensions)\n\n**Lineage**: Builds on the product stability theorems from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: The Genome Density Function \u2014 How Crowded Is Each Chemical Class?\n\n**Conjecture**: Define `\u03c1(n, C)` = (number of groups of order n in chemical class C) / (total number of groups of order n). Then:\n- `\u03c1(p, nobleGas) = 1` for all primes p (all groups of prime order are cyclic)\n- `\u03c1(p\u00b2, nobleGas) = 1/(p+1)` (one cyclic group among p+1 abelian groups of order p\u00b2... actually there are exactly 2)\n- `\u03c1(n, compound) \u2192 1` as n \u2192 \u221e along highly composite numbers (most large groups are non-solvable)\n\nThe last claim is the most surprising and controversial \u2014 it contradicts the intuition from Burnside's theorem that \"most\" groups are solvable (which holds for groups of odd order but not in general).\n\n**Test**: Compute \u03c1(n, C) for all n \u2264 100 and all chemical classes C using GAP. Plot the density curves. Check whether \u03c1(2^k, alkalineEarth) \u2192 1 as k \u2192 \u221e (most 2-groups are nilpotent non-abelian).\n\n**Impact**: This quantifies which chemical classes are \"common\" and which are \"rare\" \u2014 analogous to natural abundance of elements. The distribution of groups across classes has deep connections to number theory (via the count of groups of given order) and probability (random group theory).\n\n**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (ChemicalClass, classifyGroup)\n\n**Proof Strategy**: For prime orders, use the fact that every group of prime order is cyclic (Lagrange's theorem). For p\u00b2, use the classification of groups of order p\u00b2. For the asymptotic claims, use results from the enumerative group theory literature on the dominance of p-groups.\n\n**Domain Bridges**: Number Theory \u2194 Novelty (counting functions), Computation \u2194 Novelty (algorithmic enumeration)\n\n**Lineage**: Extends the chemical classification from this cycle into quantitative territory.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0884",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "3a68ddb3",
    "status": "available",
    "timestamp": "2026-06-06T23:45:49.232696+00:00",
    "title": "**Group Genome** framework \u2014 a formal classi"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Tropical Geometry of Neural Networks\n\n## Synthesis\n\nThis cycle established a formalized bridge between ReLU neural network decision boundaries and tropical algebraic geometry. The key results \u2014 depth-width asymmetry ($(w+1)^L \\geq Lw+1$), tropical sum distributivity, Maslov dequantization bounds, and the tropical B\u00e9zout bridge \u2014 form a coherent framework connecting network architecture to decision boundary complexity.\n\nThe most promising cross-domain connection is the **Maslov dequantization**, which provides an exact quantitative bridge between smooth algebraic varieties and tropical (piecewise linear) objects. This connection suggests that results from classical algebraic geometry (B\u00e9zout's theorem, Harnack's theorem, Morse theory) have tropical analogs that directly bound neural network behavior. The dequantization gap of $\\varepsilon \\log K$ provides a precise \"resolution\" at which the tropical approximation becomes exact.\n\nThe highest breakthrough potential lies in Direction 1 (Tropical Morse Theory), which would connect the *topology* of decision boundaries to network architecture through a tropical analog of Morse theory. If successful, this would give tight bounds on Betti numbers (connected components, holes, voids) of decision boundaries in terms of depth and width \u2014 going far beyond the region-counting bounds established in this cycle.\n\n---\n\n### Direction 1: Tropical Morse Theory for Decision Boundaries\n\n**Conjecture**: For a ReLU network $f: \\mathbb{R}^n \\to \\mathbb{R}$ with $L$ layers of width $w$, the sum of Betti numbers of the decision boundary $B = \\{x : f(x) = 0\\}$ satisfies:\n$$\\sum_k \\beta_k(B) \\leq 2 \\cdot (w+1)^L \\cdot \\binom{n-1+L}{L}$$\n\nThis would be a tropical analog of the Milnor-Thom bound $\\sum \\beta_k(V) \\leq d(2d-1)^{n-1}$ for degree-$d$ real algebraic varieties.\n\n**Test**: Compute Betti numbers of decision boundaries for small networks (2D input, varying depth/width) using persistent homology. Compare to the conjectured bound.\n\n**Impact**: If true, this gives the first *topological* complexity bound on neural network decision boundaries in terms of architecture. It would explain why deep networks can learn topologically complex decision regions (e.g., regions with holes) that shallow networks cannot. If false, the failure would reveal which topological features escape depth control.\n\n**Catalog References**: `Catalog/Tropical/TropicalNNFrontier.lean` (region bounds), `Catalog/Tropical/Canonical/Basic.lean` (tropical rational forms)\n\n**Proof Strategy**: \n1. Define tropical Morse index for a piecewise linear function (number of sign changes in the gradient at a critical point)\n2. Prove a tropical Morse inequality: $\\beta_k(B) \\leq$ number of tropical critical points of index $k$\n3. Count tropical critical points using the tropical degree and the hyperplane arrangement bound\n4. Key lemma needed: each linear region contributes at most $\\binom{n-1}{k}$ critical points of index $k$\n\n**Domain Bridges**: Algebraic Topology \u2194 Neural Networks \u2194 Tropical Geometry\n\n**Lineage**: Builds on depth_width_asymmetry, hyperplane_arrangement_bound, and decision_boundary_1d from this cycle\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Tropical VC Dimension Theory\n\n**Conjecture**: The VC dimension of the function class computed by depth-$L$, width-$w$ ReLU networks with $n$-dimensional input satisfies:\n$$\\text{VCdim} \\leq C \\cdot L \\cdot w \\cdot n \\cdot \\log(Lw)$$\nfor a universal constant $C$, and this bound is tight up to the logarithmic factor: there exist networks achieving $\\text{VCdim} \\geq c \\cdot L \\cdot w \\cdot n$.\n\nThe tropical perspective suggests the tighter bound $\\text{VCdim} \\leq L \\cdot \\sum_{k=0}^n \\binom{w}{k}$ using the hyperplane arrangement bound.\n\n**Test**: Compute exact VC dimension for small network architectures ($n \\leq 3$, $w \\leq 5$, $L \\leq 3$) by exhaustive search over point configurations. Compare upper and lower bounds.\n\n**Impact**: A tight VC dimension bound would directly give PAC learning sample complexity bounds for ReLU networks: $m \\geq \\frac{1}{\\varepsilon}(\\text{VCdim} \\cdot \\log(1/\\varepsilon) + \\log(1/\\delta))$. This is the most direct route from tropical geometry to practical machine learning guarantees.\n\n**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (activation_pattern_card, depth_width_asymmetry), `Catalog/Tropical/FreivaldsLocal.lean` (zero-set bounds)\n\n**Proof Strategy**:\n1. Upper bound: Use Goldberg-Jerrum (1995) technique \u2014 bound the number of sign patterns using Warren's theorem applied to each activation region\n2. Lower bound: Construct explicit shattering configurations using the canonical tropical form\n3. Key technical step: show that the number of sign patterns of $P$ piecewise linear functions on $m$ points is at most $(4ePm/\\text{VCdim})^{\\text{VCdim}}$\n\n**Domain Bridges**: Statistical Learning Theory \u2194 Tropical Geometry \u2194 Combinatorics\n\n**Lineage**: Extends vc_param_bound and activation_pattern_card from this cycle\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Canonical Forms for Convolutional Networks\n\n**Conjecture**: A convolutional ReLU network with $L$ layers, filter size $k$, and $c$ channels computes a tropical rational function whose canonical form has at most $c^L \\cdot k^L$ essential terms. The *translation invariance* of convolution implies that the tropical polynomial has a specific symmetry: its Newton polygon is invariant under lattice translations.\n\n**Test**: Implement the canonical tropical rational extraction algorithm for small ConvNets (e.g., 2-layer, 3\u00d73 filters, 8 channels on MNIST). Verify the term count bound and check for Newton polygon symmetry.\n\n**Impact**: ConvNets are the workhorse of computer vision. Understanding their tropical structure would give certified bounds on what image features they can detect (controlled by the tropical degree) and how many distinct classification regions they create. The symmetry of the Newton polygon would formally explain *why* ConvNets are translation-invariant.\n\n**Catalog References**: `Catalog/Tropical/Canonical/Basic.lean` (TropicalPoly, TropicalRat, canonical forms), `MachineLearning/TropicalAlgebraicBridge.lean` (layer composition)\n\n**Proof Strategy**:\n1. Define tropical convolution: $f \\star g$ in the tropical semiring\n2. Show convolution preserves the tropical polynomial structure\n3. Bound the term count after $L$ convolution-ReLU layers\n4. Characterize the Newton polygon symmetry induced by weight sharing\n\n**Domain Bridges**: Computer Vision \u2194 Tropical Geometry \u2194 Lattice Theory\n\n**Lineage**: Extends layer_composition_bound and total_term_count_crude\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical Persistent Homology of Training Dynamics\n\n**Conjecture**: During training of a ReLU network by gradient descent, the tropical degree of the network output (viewed as a tropical rational function) is *non-increasing* after the initial rapid growth phase. More precisely, the number of essential terms in the canonical tropical form follows a phase transition: rapid growth during the \"memorization phase\" followed by monotonic decrease during the \"generalization phase.\"\n\n**Test**: Train small networks (1D input, 2-3 layers, width 5-10) on synthetic datasets. At each training step, extract the canonical tropical form and track the term count, tropical degree, and Betti numbers of the decision boundary.\n\n**Impact**: This would provide the first *geometric* characterization of the implicit regularization in neural network training. The conjecture that tropical degree decreases during generalization would explain Occam's razor in deep learning: gradient descent naturally simplifies the tropical structure of the function.\n\n**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (depth_width_asymmetry, tropical_sum_distrib), `Catalog/Tropical/Canonical/Basic.lean` (canonical forms)\n\n**Proof Strategy**:\n1. Show that gradient descent on a loss function $L(f)$ with weight decay induces a \"tropical flow\" on the space of tropical rational functions\n2. Prove that weight decay is equivalent to a penalty on tropical degree (the $L_1$ norm of the coefficient vector in tropical form)\n3. Use the Maslov dequantization to connect SGD dynamics to a tropical flow\n4. Key lemma: weight decay in the smooth (high-$\\varepsilon$) regime corresponds to term elimination in the tropical ($\\varepsilon \\to 0$) regime\n\n**Domain Bridges**: Optimization \u2194 Tropical Geometry \u2194 Statistical Learning\n\n**Lineage**: Extends maslov_dequantization_upper/lower and the dequantization gap analysis\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Tropical Error-Correcting Codes from Network Decision Boundaries\n\n**Conjecture**: The decision boundary arrangement of a depth-$L$, width-$w$ ReLU network in $\\mathbb{R}^n$ defines a *tropical code*: a collection of $\\leq (w+1)^L$ regions that can be used as codewords. The minimum \"tropical distance\" between adjacent regions is $\\geq 1/\\text{Lip}(f)$ where $\\text{Lip}(f)$ is the Lipschitz constant. The resulting code achieves a rate-distance tradeoff of $R \\leq 1 - d/\\sqrt{n}$ (analogous to the Singleton bound).\n\n**Test**: Construct explicit tropical codes from trained binary classifiers. Measure the minimum distance between class regions and compare to the conjectured Singleton-type bound.\n\n**Impact**: This would establish a novel connection between neural network architectures and coding theory. The tropical code construction would give a new family of codes with structured decoder (the neural network itself). If the rate-distance tradeoff is competitive, this could yield practical applications in communication systems.\n\n**Catalog References**: `MachineLearning/TropicalAlgebraicBridge.lean` (hyperplane_arrangement_bound, decision_boundary_1d), `Catalog/Tropical/FreivaldsLocal.lean` (Freivalds/Schwartz-Zippel connection)\n\n**Proof Strategy**:\n1. Define tropical distance between regions as the Hausdorff distance of their boundaries\n2. Show this distance is bounded below by $1/\\text{Lip}(f)$ where $f$ is the network function\n3. Count the number of regions to get the rate\n4. Derive the Singleton-type bound from the volume argument: regions of minimum distance $d$ in $\\mathbb{R}^n$ pack at most $(R/d)^n$ efficiently\n\n**Domain Bridges**: Coding Theory \u2194 Neural Networks \u2194 Tropical Geometry\n\n**Lineage**: Extends boundary_perturbation_bound and hyperplane_arrangement_bound\n\n**Ambition**: extension\n",
    "domains": [
      "MachineLearning",
      "Algebra"
    ],
    "id": "fd_0889",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6c23eddb",
    "status": "available",
    "timestamp": "2026-06-07T00:53:02.477859+00:00",
    "title": "Formalized bridge between ReLU neural network decision"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Tropical Neural Varieties\n\n## Synthesis\n\nThis cycle established the **Tropical Neural Complex** (TNC) as a novel mathematical structure encoding the algebraic-geometric complexity of ReLU neural network decision boundaries. The TNC provides three computable invariants \u2014 the folding number, tropical degree, and tropical spectral gap \u2014 that together characterize the expressivity of neural architectures in terms of their decision boundary complexity. The central discovery is the **depth-width tradeoff**: for a fixed total neuron budget W, the tropical degree grows exponentially with depth L as (W/L)^L, reaching a maximum near L \u2248 W/e. This provides the first algebraic-geometric explanation of why deep networks outperform shallow ones.\n\nThe most promising cross-domain connection from this cycle is between **tropical geometry and generalization theory**. The tropical degree of a network's decision boundary provides an architecture-dependent complexity measure that could yield tighter VC dimension bounds. The composition theorem (tropical degree is multiplicative under stacking) connects naturally to the Catalog's existing work on tropical arithmetic coding and tropical cryptographic structures, suggesting a broader \"tropical complexity theory\" that unifies information-theoretic and geometric perspectives.\n\nThe highest breakthrough potential lies in **Direction 1 (Tropical B\u00e9zout Intersection Theory)**: proving sharp bounds on the complexity of intersections and disagreements between neural network decision boundaries would have immediate applications in ensemble learning, adversarial robustness certification, and neural network verification.\n\n---\n\n### Direction 1: Tropical B\u00e9zout Intersection Theory for Neural Networks\n\n**Conjecture**: For two ReLU networks f, g with tropical degrees d\u2081, d\u2082 respectively, the number of connected components of {x : f(x) = 0} \u2229 {x : g(x) = 0} in any 2-dimensional cross-section is at most d\u2081 \u00b7 d\u2082. More precisely, the intersection of two tropical neural hypersurfaces in \u211d\u207f satisfies the tropical B\u00e9zout bound: the stable intersection has mixed volume at most d\u2081 \u00b7 d\u2082.\n\n**Test**: Construct explicit pairs of small ReLU networks (e.g., 2\u21923\u21921 and 2\u21924\u21921), compute their decision boundaries in \u211d\u00b2, and count connected components of the intersection. Verify that the count never exceeds 3 \u00d7 4 = 12. Test with 100 random weight initializations to build statistical confidence.\n\n**Impact**: If true, this gives the first certified bound on how many regions two neural networks can disagree on, which directly yields ensemble disagreement bounds and diversity guarantees. If false, it reveals that neural tropical varieties have richer intersection behavior than classical tropical varieties, opening a new direction in tropical geometry.\n\n**Catalog References**: `MachineLearning/TropicalNeuralVariety.lean` (compose_tropicalDegree, tropical_bezout_bound), `Tropical/CompositionalBound.lean`\n\n**Proof Strategy**: \n1. Formalize tropical stable intersection as the set of points where two tropical polynomials achieve their maximum at the same terms.\n2. Show that for ReLU network tropical polynomials, the stable intersection decomposes along the dual subdivision.\n3. Apply the classical tropical B\u00e9zout theorem (Maclagan-Sturmfels, Theorem 4.6.8) to bound the mixed volume.\n4. Key lemma needed: relate the tropical degree of a ReLU network to the degree of its Newton polytope.\n\n**Domain Bridges**: Tropical geometry <-> Machine learning, Algebraic geometry <-> Combinatorics\n\n**Lineage**: Builds on this cycle's compose_tropicalDegree and tropical_degree_le_folding_number.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Tropical VC Dimension Bounds\n\n**Conjecture**: The VC dimension of a ReLU network with tropical degree D and input dimension n satisfies:\n\nn \u00b7 \u2308log\u2082(D)\u2309 \u2264 VCdim \u2264 O(n \u00b7 D \u00b7 log(D))\n\nMore specifically, for a network with L layers of width w in \u211d\u207f: VCdim \u2265 n \u00b7 L \u00b7 \u230alog\u2082(w)\u230b.\n\n**Test**: For small networks (2\u2192w\u21921 with w = 2,3,...,8), compute the VC dimension exactly by exhaustive search over point configurations in \u211d\u00b2. Compare with tropical degree w and the conjectured bounds.\n\n**Impact**: Current VC dimension bounds for neural networks depend on the number of parameters (which is O(w\u00b2L)), while the conjectured bound depends on tropical degree w^L. These are incomparable: the tropical bound is tighter for deep narrow networks, the parameter bound is tighter for shallow wide networks. A tropical VC dimension bound would provide a new, architecture-aware generalization guarantee.\n\n**Catalog References**: `MachineLearning/TropicalNeuralVariety.lean` (tropical_degree_le_folding_number, nontrivial_boundary_iff), `MachineLearning/Capacity.lean`\n\n**Proof Strategy**:\n1. Prove that a network with tropical degree D can shatter at least log\u2082(D) points in general position along a line (lower bound).\n2. Use the folding number F = 2^W to bound VCdim \u2264 W (since at most 2^W regions implies shattering \u2264 W points by Sauer-Shelah).\n3. The gap between log\u2082(D) and W is exactly the tropical spectral gap, connecting the two bounds.\n\n**Domain Bridges**: Machine learning <-> Combinatorics, Tropical geometry <-> Statistical learning theory\n\n**Lineage**: Builds on folding_number_eq_prod and depth_advantage_exponential from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Spectral Gap and Training Dynamics\n\n**Conjecture**: During gradient descent training of a ReLU network, the number of realized linear regions grows monotonically from 1 (at random initialization with small weights) to at most 2^W (at convergence). The rate of region creation is proportional to the tropical spectral gap: networks with larger spectral gap create new regions faster.\n\n**Test**: Train networks with fixed total width W = 16 but varying depth L \u2208 {1, 2, 4, 8, 16} on a binary classification task. At each training step, sample 10,000 random points and count distinct activation patterns. Plot the region count trajectory and measure its slope. Compare slopes with spectral gap values.\n\n**Impact**: If true, the tropical spectral gap would be the first architecture-dependent predictor of learning speed that is purely combinatorial (no weight-dependent quantities). This would connect tropical geometry to optimization theory.\n\n**Catalog References**: `MachineLearning/DepthWidthTradeoff.lean` (spectral_gap_nonneg, exponential_gap), `MachineLearning/NTKConvergence.lean`\n\n**Proof Strategy**:\n1. Formalize the notion of \"realized tropical degree at step t\" as the number of distinct activation patterns on the training data.\n2. Show that each gradient step can create at most O(W) new regions (bounded by the number of neurons that cross zero).\n3. Relate the steady-state realized degree to the tropical degree upper bound.\n\n**Domain Bridges**: Tropical geometry <-> Optimization theory, Algebraic geometry <-> Training dynamics\n\n**Lineage**: Builds on spectral_gap_nonneg and the folding number analysis.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical Singularity Theory and Adversarial Robustness\n\n**Conjecture**: The adversarial robustness radius of a ReLU network at a point x is inversely proportional to the local tropical multiplicity at x. Points near singularities of the decision boundary (where three or more linear regions meet) have strictly lower robustness than points near smooth boundary facets.\n\nFormally: if x is within distance \u03b5 of a singularity of multiplicity m \u2265 3, then the minimum adversarial perturbation at x satisfies ||\u03b4||\u221e \u2264 C/(m \u00b7 ||\u2207f(x)||), where C depends only on the network architecture.\n\n**Test**: Train a 2\u21928\u21928\u21921 network on a 2D classification task. Compute the decision boundary and identify singular points (where \u2265 3 regions meet). For each test point, compute the adversarial perturbation using PGD attack. Plot adversarial distance vs. proximity to singularities.\n\n**Impact**: This would give the first geometric characterization of adversarial vulnerability. Current certified robustness methods (Lipschitz bounds, randomized smoothing) do not distinguish between smooth and singular parts of the boundary. A tropical singularity theory would enable targeted robustness certification: certify smooth regions cheaply, invest more computation near singularities.\n\n**Catalog References**: `MachineLearning/TropicalNeuralVariety.lean` (singularity_le_folding, singularityBound), `MachineLearning/TropicalCertifiedRobustness.lean`, `MachineLearning/TropicalDefs.lean`\n\n**Proof Strategy**:\n1. Define local tropical multiplicity at a point of the decision boundary.\n2. Show that at a smooth boundary point (multiplicity 2), the decision boundary is locally a hyperplane, giving robustness radius ||\u03b4|| = f(x)/||\u2207f(x)||.\n3. At a singular point (multiplicity m \u2265 3), show that the decision boundary has a \"corner\" that reduces the robustness radius by a factor of 1/m.\n\n**Domain Bridges**: Tropical geometry <-> Adversarial robustness, Singularity theory <-> Neural network security\n\n**Lineage**: Builds on singularity_le_folding and the boundary facet analysis.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Discriminant of Neural Networks\n\n**Conjecture**: The set of weight configurations for which a ReLU network's decision boundary has a singularity (a point where \u2265 3 linear regions meet on the boundary) is a semi-algebraic set of codimension 1 in weight space. The degree of this discriminant locus is bounded by \u220fC(w\u1d62, 2) \u00b7 \u220f2^w\u1d62.\n\n**Test**: For a 1\u21922\u21921 network (3 parameters: 2 weights and 1 bias, plus output layer), enumerate the weight space and identify which weights produce a singular decision boundary. Verify that the singular locus is a curve (codimension 1 in \u211d\u00b3).\n\n**Impact**: The tropical discriminant would provide a map of \"dangerous\" weight configurations \u2014 those that produce fragile decision boundaries. This has applications in neural architecture search (avoid singular architectures), training stability (avoid singular weight regions), and network pruning (prune neurons whose removal doesn't create singularities).\n\n**Catalog References**: `MachineLearning/TropicalNeuralVariety.lean` (singularityBound), `Tropical/TropicalCuspidalFactorization.lean`\n\n**Proof Strategy**:\n1. Parameterize the decision boundary by the network weights.\n2. Express the singularity condition (\u2265 3 regions meeting at a boundary point) as a system of polynomial equalities and inequalities in the weights.\n3. Apply Tarski-Seidenberg to show the projection to weight space is semi-algebraic.\n4. Bound the degree using the singularity bound from this cycle.\n\n**Domain Bridges**: Tropical geometry <-> Algebraic geometry, Discriminant theory <-> Neural architecture search\n\n**Lineage**: Builds on singularity_le_folding and the singularityBound definition.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_0892",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "4ab2bbb1",
    "status": "available",
    "timestamp": "2026-06-07T01:27:08.080144+00:00",
    "title": "**Tropical Neural Complex** (TNC) as a novel mathemat"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Quantum EML Activation Functions\n\n## Synthesis\n\nThis cycle established the mathematical foundations of the **phase neuron** `phaseNeuron(\u03b8, \u03c6) = exp(i\u03b8) \u2212 i\u03c6`, a complex-valued quantum activation function that extends the real EML framework. The central discovery is the geometry of the **unitarity locus**: the set of parameters yielding unit-norm outputs forms two curves \u2014 the trivial axis \u03c6 = 0 (pure quantum phase gates) and the sinusoidal curve \u03c6 = 2 sin \u03b8 (time-reversed gates). Between these curves lies a sub-unitary dissipative regime; beyond them, a super-unitary amplifying regime.\n\nThe most promising cross-domain connection is between the **defect quadratic form** `\u03c6\u00b2 \u2212 2\u03c6 sin \u03b8` and **quantum error correction syndromes**, which are also described by quadratic forms over discrete spaces. The spectral EML gap amplification result (monotonicity of `exp(l) \u2212 log(l)` for l \u2265 1, with a phase transition near l \u2248 0.567) connects the EML framework to spectral discrimination problems in quantum state tomography. The **strip theorem** (image = {z : |Re(z)| \u2264 1}) provides the first rigorous \"expressivity\" result for quantum EML neurons, analogous to universal approximation bounds for classical networks.\n\nThe highest breakthrough potential lies in Direction 1 (Quantum EML Universal Approximation), because a positive answer would establish quantum EML as a legitimate computational model, while a negative answer would reveal fundamental expressivity barriers specific to the phase-amplitude decomposition.\n\n---\n\n### Direction 1: Quantum EML Universal Approximation via Gate Composition\n\n**Conjecture**: For any continuous function f : [\u22121, 1] \u2192 \u2102 and any \u03b5 > 0, there exists a finite sequence of quantum EML gates G\u2081 = (\u03b8\u2081, \u03c6\u2081), \u2026, G\u2099 = (\u03b8\u2099, \u03c6\u2099) such that the composition map `\u220f\u1d62 phaseNeuron(\u03b8\u1d62, \u03c6\u1d62)` (pointwise product) approximates f uniformly: `sup_{x \u2208 [\u22121,1]} |\u220f\u1d62 phaseNeuron(\u03b8\u1d62, x\u00b7\u03c6\u1d62) \u2212 f(x)| < \u03b5`, where each gate's displacement is modulated by the input x.\n\n**Test**: For the target function f(x) = x + ix\u00b2 on [\u22121, 1], compute numerically the minimal number of gates n needed to achieve \u03b5 = 0.01 approximation. If n grows polynomially in 1/\u03b5, the conjecture is plausible. If n grows exponentially, the conjecture likely fails.\n\n**Impact**: A positive result would be the first universal approximation theorem for quantum activation functions built from the EML (exp-minus-log) paradigm. It would establish that the quantum-classical bridge is bidirectional: not only do classical activations embed in the quantum EML (via the reality curve \u03c6 = sin \u03b8), but quantum EML networks can compute anything classical networks can, plus complex-valued functions.\n\n**Catalog References**: `Catalog/Bridges/UniversalApproximation.lean` (eml_exp_neuron_continuous), `Applications/QuantumEMLCore.lean` (phaseNeuron_image_surj, phaseNeuron_continuous)\n\n**Proof Strategy**: \n1. Establish that the algebra generated by {phaseNeuron(\u03b8, \u00b7) : \u03b8 \u2208 \u211d} separates points on [\u22121, 1] (Stone-Weierstrass hypothesis).\n2. Show the algebra is closed under conjugation (use the sinusoidal branch: phaseNeuron(\u03b8, 2 sin \u03b8) = exp(\u2212i\u03b8) = conj(exp(i\u03b8))).\n3. Show it contains the constants (identity gate: phaseNeuron(0, 0) = 1).\n4. Apply Stone-Weierstrass to conclude density in C([\u22121,1], \u2102).\n\n**Domain Bridges**: EML \u2194 Functional Analysis (Stone-Weierstrass), Applications \u2194 MachineLearning (universal approximation)\n\n**Lineage**: Builds on phaseNeuron_image_surj and quantum_classical_bridge from this cycle. Extends the scalar EML universal approximation in `Catalog/Bridges/UniversalApproximation.lean`.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Defect Form as Quantum Error Syndrome\n\n**Conjecture**: The defect quadratic form \u03b4(\u03b8, \u03c6) = \u03c6\u00b2 \u2212 2\u03c6 sin \u03b8, restricted to a finite lattice of gate parameters (\u03b8, \u03c6) \u2208 (2\u03c0\u2124/N) \u00d7 (2\u03c0\u2124/M), is isomorphic (as a quadratic form over \u2124/NM) to the syndrome extraction map of a stabilizer code of distance d = O(min(N, M)).\n\n**Test**: For N = M = 4, explicitly compute the defect values on the 16-element lattice and check whether the resulting quadratic form matches any known stabilizer syndrome. If it matches a [[4,2,2]] code syndrome, the conjecture is strongly supported.\n\n**Impact**: This would establish a deep structural connection between quantum neural network geometry (the unitarity locus) and quantum error correction (stabilizer codes). It would mean that training a quantum EML network to minimize defect is mathematically equivalent to decoding a quantum error-correcting code \u2014 unifying two apparently unrelated computational problems.\n\n**Catalog References**: `Applications/QuantumEMLCore.lean` (defect_formula, phaseNeuron_unitary_iff), `Catalog/Cryptography/BerggrenDiophantineLattice.lean` (lorentzForm)\n\n**Proof Strategy**:\n1. Formalize the finite lattice restriction of the defect form.\n2. Compute the Gram matrix of the restricted quadratic form.\n3. Classify using the theory of integral quadratic forms (genus theory).\n4. Match against the database of stabilizer code syndromes.\n\n**Domain Bridges**: Applications \u2194 Cryptography (quadratic forms), EML \u2194 Physics (error correction)\n\n**Lineage**: Builds on defect_formula and unitary_iff_defect_zero from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Spectral EML Phase Transition at the Critical Point\n\n**Conjecture**: The critical point l* of the diagonal spectral EML `f(l) = exp(l) \u2212 log(l)` satisfies l* = W(1) where W is the Lambert W function (product logarithm), and the second derivative f''(l*) = exp(l*) + 1/l*\u00b2 = 1/l*\u00b2 + 1/l* satisfies a clean algebraic relation: `f''(l*) \u00b7 l*\u00b2 = 1 + l*`.\n\n**Test**: Compute l* numerically (l* \u2248 0.5671) and verify W(1) = l* to 15 digits. Verify f''(l*) \u00b7 l*\u00b2 = 1 + l* algebraically.\n\n**Impact**: Would connect the spectral EML to the Lambert W function, one of the most important special functions in combinatorics and physics (appearing in the enumeration of trees, delay differential equations, and quantum field theory). This would provide an exact analytical handle on the spectral EML phase transition.\n\n**Catalog References**: `Applications/QuantumEMLCore.lean` (spectralEML_gap_amplification), `Catalog/EML/EMLv17Core.lean` (eml_no_critical_points)\n\n**Proof Strategy**:\n1. Define the Lambert W function as the inverse of f(x) = x\u00b7exp(x).\n2. Show that exp(l) = 1/l at the critical point implies l\u00b7exp(l) = 1, hence l = W(1).\n3. Compute f''(l) = exp(l) + 1/l\u00b2 = 1/l + 1/l\u00b2 = (l+1)/l\u00b2.\n\n**Domain Bridges**: EML \u2194 Combinatorics (Lambert W in tree enumeration), Applications \u2194 Physics (Lambert W in QFT)\n\n**Lineage**: Builds on spectralEML_gap_amplification and the observation that f(l) = exp(l) \u2212 log(l) has a non-trivial minimum.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Multi-Qubit Phase Neurons via Tensor Products\n\n**Conjecture**: The n-qubit phase neuron, defined as the tensor product `\u2297\u1d62 phaseNeuron(\u03b8\u1d62, \u03c6\u1d62)` for i = 1, \u2026, n, has defect equal to `\u220f\u1d62 (1 + \u03b4\u1d62) \u2212 1` where \u03b4\u1d62 = \u03c6\u1d62\u00b2 \u2212 2\u03c6\u1d62 sin \u03b8\u1d62 is the single-qubit defect. In particular, the multi-qubit unitarity locus is the product of single-qubit unitarity loci.\n\n**Test**: For n = 2 with gates (\u03c0/4, 0) and (\u03c0/6, 1/2), compute the defect of the tensor product and verify it equals (1 + 0)(1 + 1/4 \u2212 \u221a3/2) \u2212 1 = 1/4 \u2212 \u221a3/2.\n\n**Impact**: Would establish that single-qubit quantum EML gates compose tensorially with a multiplicative defect structure. This would make defect analysis tractable for multi-qubit systems and connect to the theory of product states in quantum information.\n\n**Catalog References**: `Applications/QuantumEMLCore.lean` (defect_formula, phaseNeuron_normSq)\n\n**Proof Strategy**:\n1. Define the n-qubit phase neuron as a product in \u2102.\n2. Use the norm-squared identity: \u2016\u220f z\u1d62\u2016\u00b2 = \u220f \u2016z\u1d62\u2016\u00b2.\n3. Compute: \u220f(1 + \u03b4\u1d62) \u2212 1 expands to the sum of products of defects.\n4. Verify the unitarity locus factorization.\n\n**Domain Bridges**: Applications \u2194 Physics (tensor products in QM), EML \u2194 Algebra (multiplicative structure)\n\n**Lineage**: Direct generalization of the single-qubit results from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Phase Neuron Dynamics and Fixed Points\n\n**Conjecture**: The iterated phase neuron map `\u03a6(z) = phaseNeuron(arg(z), |z| \u2212 1)` (where the input's argument and modulus determine the gate parameters) has exactly two fixed points in \u2102: z = 1 (the identity) and z = \u22121 (the antipodal point). The fixed point z = 1 is stable (attracting) and z = \u22121 is unstable (repelling).\n\n**Test**: Numerically iterate \u03a6 starting from z\u2080 = 0.5 + 0.5i for 1000 steps and check convergence to 1. Start from z\u2080 = \u22121 + 0.01i and check divergence from \u22121.\n\n**Impact**: Would establish the phase neuron as a dynamical system with a natural \"ground state\" at z = 1, providing a dynamical interpretation of the identity gate. The stability analysis would predict which quantum EML configurations are robust under perturbation \u2014 essential for practical quantum computing applications.\n\n**Catalog References**: `Applications/QuantumEMLCore.lean` (identity_output, phaseNeuron_continuous)\n\n**Proof Strategy**:\n1. Set up the fixed point equation \u03a6(z) = z, i.e., phaseNeuron(arg(z), |z|\u22121) = z.\n2. For z = 1: arg(1) = 0, |1|\u22121 = 0, so \u03a6(1) = phaseNeuron(0, 0) = 1. \u2713\n3. Compute the Jacobian D\u03a6 at z = 1 and show its spectral radius < 1.\n4. For z = \u22121: arg(\u22121) = \u03c0, |\u22121|\u22121 = 0, so \u03a6(\u22121) = phaseNeuron(\u03c0, 0) = exp(i\u03c0) = \u22121. \u2713\n5. Show the Jacobian at z = \u22121 has spectral radius > 1.\n\n**Domain Bridges**: Applications \u2194 Geometry (fixed point theory), EML \u2194 Physics (stability of quantum states)\n\n**Lineage**: Builds on identity_output and quantum_classical_bridge from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_0906",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "9092c870",
    "status": "available",
    "timestamp": "2026-06-07T04:48:12.919232+00:00",
    "title": "Mathematical foundations of the **phase neuron** `pha"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Hypergraph Ramsey Theory\n\n## Synthesis\n\nThis cycle established a formal framework for r-uniform hypergraph Ramsey theory, centered on two novel contributions: the **Stepping-Up System** structure (which packages the Erd\u0151s-Rado stepping-up construction as a composable mathematical object) and a fully verified **probabilistic lower bound** for hypergraph Ramsey numbers at arbitrary uniformity. The link coloring transfer theorems provide the bridge between uniformity levels, and the tower function properties quantify the exponential growth gap.\n\nThe most promising cross-domain connection is between hypergraph Ramsey theory and the **Higher-Order Shadow Tower** results in the Bridges catalog. The tower function that governs hypergraph Ramsey growth is the same tower that appears in Szemer\u00e9di's regularity lemma bounds and in proof complexity lower bounds. This suggests a deep structural connection: the tower function may be an unavoidable feature of any combinatorial argument that involves iterated regularity or iterated projection (like the stepping-up construction). Formalizing this connection could unify several disparate areas of combinatorics.\n\nThe highest breakthrough potential lies in **Direction 1**: constructing an explicit Stepping-Up System instance and using it to derive tower-type upper bounds automatically. This would transform the stepping-up lemma from an ad hoc proof technique into a verified computational pipeline.\n\n---\n\n### Direction 1: Explicit Stepping-Up System Construction\n\n**Conjecture**: There exists a computable `SteppingUpSystem 2` with `baseBound k l = C(k+l-2, k-1)` (the Erd\u0151s-Szekeres bound) and `steppedBound k l \u2264 tower(1, C(k+l-2, k-1))`, yielding verified tower-type upper bounds for 3-uniform Ramsey numbers.\n\n**Test**: Construct the `SteppingUpSystem 2` instance in Lean 4 by:\n1. Proving `HyperRamseyProp 2 (C(k+l-2, k-1)) k l` (the classical Erd\u0151s-Szekeres recursion)\n2. Using the link coloring transfer theorems to lift from uniformity 2 to uniformity 3\n3. Verifying that the resulting `steppedBound` satisfies the stepping-up inequality\n\nIf the construction succeeds, check whether `steppedBound 5 5 \u2264 55` (matching the known upper bound for R\u2083(5,5)).\n\n**Impact**: If true, this gives the first machine-verified derivation of tower-type upper bounds for 3-uniform Ramsey numbers. If false (the bound is too weak), it reveals where the stepping-up construction loses tightness and motivates tighter base bounds.\n\n**Catalog References**: `Applications/HypergraphRamsey/Defs.lean` (SteppingUpSystem), `Applications/HypergraphRamsey/Theorems.lean` (link_red_transfer, link_blue_transfer), `Algebra/Probabilistic.lean` (ramsey_lower_bound_counting)\n\n**Proof Strategy**: \n1. Formalize the Erd\u0151s-Szekeres recursion R(s,t) \u2264 R(s-1,t) + R(s,t-1) using the existing `RamseyProp` infrastructure\n2. Connect `RamseyProp` to `HyperRamseyProp 2` via an equivalence theorem\n3. Build the link coloring induction: given an (r+1)-coloring, fix a vertex v, apply the base Ramsey theorem to the link, and use the transfer theorems to extend\n4. Package everything as a `SteppingUpSystem 2` instance\n\n**Domain Bridges**: Combinatorics (Ramsey) \u2194 Logic (proof complexity tower bounds via `tower_lower_bound`)\n\n**Lineage**: Builds on `SteppingUpSystem`, `link_red_transfer`, `link_blue_transfer`, `tower_add` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Lov\u00e1sz Local Lemma for Tighter Hypergraph Ramsey Bounds\n\n**Conjecture**: Using the Lov\u00e1sz Local Lemma instead of the first-moment method, one can prove R\u2083(k,k) > 2^{ck\u00b2} with c = 1/4 (improving the first-moment constant c \u2248 1/6).\n\n**Test**: Formalize the Lov\u00e1sz Local Lemma (symmetric version: if each event has probability \u2264 p and depends on at most d others, and ep(d+1) \u2264 1, then all events can be simultaneously avoided). Apply it to the hypergraph Ramsey setting where events are \"k-set S is monochromatic\" and the dependency graph connects k-sets that share an r-subset.\n\n**Impact**: Tighter lower bounds narrow the gap between lower and upper bounds for R\u2083(k,k). The dependency structure of the Ramsey setting is a rich testbed for the Local Lemma methodology.\n\n**Catalog References**: `Applications/HypergraphRamsey/Theorems.lean` (hyperRamsey_probabilistic_lower), `Algebra/Probabilistic.lean`\n\n**Proof Strategy**:\n1. Formalize the symmetric Lov\u00e1sz Local Lemma in Lean 4\n2. Define the dependency graph: two k-sets are dependent iff they share an r-element subset\n3. Compute the maximum degree d in this dependency graph: d \u2264 C(k,r) \u00b7 C(n-r, k-r)\n4. Apply the LLL to obtain the improved bound\n\n**Domain Bridges**: Probability theory \u2194 Combinatorics (Ramsey)\n\n**Lineage**: Extends `hyperRamsey_probabilistic_lower` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Connecting Graph and Hypergraph Ramsey via Equivalence\n\n**Conjecture**: The existing `RamseyProp n k l` (from `Algebra/Ramsey/Defs.lean`) is equivalent to `HyperRamseyProp 2 n k l` \u2014 the graph Ramsey property defined via edge colorings on symmetric irreflexive functions is the same as the hypergraph Ramsey property at uniformity 2.\n\n**Test**: Prove the equivalence `RamseyProp n k l \u2194 HyperRamseyProp 2 n k l` by constructing explicit bijections between `TwoColoring n` and `HypergraphColoring 2 n`, and showing that `IsRedClique C S \u2194 IsRedHyperClique 2 C' S` under this correspondence.\n\n**Impact**: This would formally unify the two Ramsey frameworks in the catalog, allowing all graph-level Ramsey results (including `ramsey_lower_bound_counting`, `pentagon_no_mono_triangle`, `coloring8_no_blue_K4`) to be automatically lifted to the hypergraph setting. It would also enable the stepping-up construction to use graph Ramsey results as the base case.\n\n**Catalog References**: `Algebra/Ramsey/Defs.lean` (TwoColoring, RamseyProp), `Applications/HypergraphRamsey/Defs.lean` (HypergraphColoring, HyperRamseyProp)\n\n**Proof Strategy**:\n1. Define a map `TwoColoring n \u2192 HypergraphColoring 2 n` by setting `color {i,j} = C.color i j`\n2. Define the reverse map by extracting the two elements of a 2-set\n3. Show these maps are inverses (up to the symmetry/irreflexivity constraints)\n4. Prove the clique predicates correspond\n\n**Domain Bridges**: Algebra (existing Ramsey framework) \u2194 Applications (hypergraph Ramsey)\n\n**Lineage**: Bridges `Algebra/Ramsey/Defs.lean` and `Applications/HypergraphRamsey/Defs.lean` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Computational Verification of Small Hypergraph Ramsey Numbers\n\n**Conjecture**: R\u2083(4,4) = 13 can be verified by exhaustive computation in Lean 4 using `native_decide` on a finite search space, providing the first machine-verified value of a non-trivial 3-uniform Ramsey number.\n\n**Test**: Implement a decision procedure that:\n1. For n = 12: exhibits a 2-coloring of the C(12,3) = 220 triples with no monochromatic 4-set (proving R\u2083(4,4) > 12)\n2. For n = 13: checks all 2^{C(13,3)} = 2^{286} colorings... this is too large for exhaustive search. Instead, prove the upper bound R\u2083(4,4) \u2264 13 by a case-split argument on the link colorings.\n\nActually, the upper bound proof for R\u2083(4,4) \u2264 13 uses the stepping-up lemma with R(6,6) \u2264 102 and careful analysis. The lower bound R\u2083(4,4) > 12 requires exhibiting a specific coloring.\n\n**Impact**: Machine-verified Ramsey numbers are extremely rare. Even R(4,4) = 18 has only recently been formally verified. Verifying R\u2083(4,4) = 13 would be a landmark result.\n\n**Catalog References**: `Algebra/Ramsey/Defs.lean`, `Algebra/Probabilistic.lean` (coloring8_no_blue_K4)\n\n**Proof Strategy**:\n1. For the lower bound: construct an explicit `HypergraphColoring 3 12` with no monochromatic 4-set (known constructions exist in the literature)\n2. For the upper bound: use the stepping-up lemma with `link_red_transfer` and known graph Ramsey bounds\n3. Use `native_decide` or verified SAT solvers for the finite case analysis\n\n**Domain Bridges**: Computation \u2194 Combinatorics (verified computation of Ramsey numbers)\n\n**Lineage**: Extends the verified Ramsey infrastructure from `Algebra/Ramsey/Defs.lean` and this cycle's hypergraph framework.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Tower Growth and Proof Complexity\n\n**Conjecture**: The tower function that governs hypergraph Ramsey growth is the same tower that appears in proof complexity lower bounds. Specifically, any proof of R_r(k,k) \u2264 N in a natural proof system requires tower(r-2, \u03a9(k)) steps, matching the Ramsey number itself.\n\n**Test**: Formalize the connection between the `tower` function in `Applications/HypergraphRamsey/Defs.lean` and the `tower_lower_bound` in `Bridges/HigherOrderShadowTower.lean`. Show that both arise from the same recursive structure \u2014 iterated application of a \"squaring\" or \"exponentiation\" operation.\n\n**Impact**: This would establish a formal bridge between combinatorics and proof complexity, showing that the difficulty of proving Ramsey-type results is inherently tied to the size of the Ramsey numbers themselves. It would formalize the folklore observation that \"Ramsey numbers are hard because they are large.\"\n\n**Catalog References**: `Bridges/HigherOrderShadowTower.lean` (tower_lower_bound), `Applications/HypergraphRamsey/Defs.lean` (tower), `Applications/HypergraphRamsey/Theorems.lean` (tower_add, tower_squaring)\n\n**Proof Strategy**:\n1. Show that tower_add (composition of towers) implies that tower(r, \u00b7) can be expressed as a composition of r applications of the single-step map n \u21a6 2^n\n2. Connect this to the shadow tower construction in Bridges/HigherOrderShadowTower.lean\n3. Formalize the observation that each stepping-up application corresponds to one level of the tower\n\n**Domain Bridges**: Combinatorics (Ramsey) \u2194 Logic (proof complexity) \u2194 Computation (Ackermann hierarchy)\n\n**Lineage**: Bridges `tower_lower_bound` from Bridges catalog and tower function from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_0907",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "bd2130fd",
    "status": "available",
    "timestamp": "2026-06-07T05:21:24.296360+00:00",
    "title": "Formal framework for r-uniform hypergraph Ramsey theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: EML Single Operator Church-Turing Thesis\n\n## Synthesis\n\nThis research cycle established the rigorous mathematical foundation for the EML universality thesis: the single operation eml(x, y) = exp(x) \u2212 log(y), combined with field operations and constants, generates an algebra dense in C(K, \u211d) for any compact K \u2282 (0, \u221e)^n. The proof elegantly connects the injectivity of the logarithm to the Stone-Weierstrass theorem, creating a bridge between algebraic function theory and topological analysis.\n\nThe most promising cross-domain connection emerged between EML universality and neural network architecture theory. The density theorem provides theoretical justification for single-nonlinearity neural networks: any continuous function can be approximated by compositions of a single transcendental operation. This connects to the Kolmogorov-Arnold representation theorem (continuous superposition) and the universal approximation theorems of Cybenko and Hornik. The EML framework may provide a unifying perspective on why many different activation functions (sigmoid = 1/(1+exp(-x)), softplus = log(1+exp(x)), GELU, etc.) all yield universal approximators\u2014they all contain the exp-log structure.\n\nThe structural results\u2014diagonal domination, convexity, differentiation closure\u2014suggest that EML is not merely dense but has rich algebraic-analytic structure that could be exploited for optimization, complexity theory, and approximation rate bounds. The absence of fixed points for the EML diagonal connects to the Lambert W function and transcendental number theory. The convexity results connect to optimization theory, suggesting that finding optimal EML representations is a convex problem.\n\n---\n\n### Direction 1: Quantitative EML Approximation Rates (Jackson-type Theorems for Log-Polynomials)\n\n**Conjecture**: For any Lipschitz function f on [a, b] \u2282 (0, \u221e) with Lipschitz constant L, the best log-polynomial approximation of degree n satisfies:\n\nE_n(f) \u2264 C \u00b7 L \u00b7 (log(b/a)) / n\n\nwhere C is a universal constant independent of f, a, b, n. More generally, for k-times differentiable functions, E_n(f) = O(1/n^k).\n\n**Test**: Prove this bound for the specific case of polynomials restricted to [1, e] (where log maps to [0, 1] and we can transfer classical Jackson theorems). Verify computationally for f(x) = sin(x), f(x) = 1/(1+x), and f(x) = x^\u03b1 for various \u03b1.\n\n**Impact**: If true, this gives the first quantitative approximation rate for the EML framework, transforming the existential Stone-Weierstrass guarantee into a constructive bound. This would enable practical algorithm design with guaranteed convergence rates.\n\n**Catalog References**: `EML/Density.lean` (Stone-Weierstrass density), `Catalog/EML/EMLv17Core.lean` (EML core)\n\n**Proof Strategy**: Use the change of variables u = log(x) to transform log-polynomial approximation on [a, b] to standard polynomial approximation on [log(a), log(b)]. Transfer classical Jackson inequality from the polynomial setting. The key lemma is that the modulus of continuity transforms predictably under log substitution.\n\n**Domain Bridges**: Approximation Theory \u2194 EML Algebra \u2194 Neural Network Convergence Rates\n\n**Lineage**: Builds on eml_uniform_approximation from this cycle's Density.lean\n\n**Ambition**: extension\n\n---\n\n### Direction 2: Complex EML and Trigonometric Universality\n\n**Conjecture**: Extending EML to complex constants, the algebra generated by eml(x, y) = exp(x) \u2212 log(y) with complex constants contains exact representations (not just approximations) of sin(x) and cos(x) on (0, \u221e), via the Euler identity:\n\nsin(x) = (exp(ix) \u2212 exp(\u2212ix)) / (2i) = (eml(ix, 1) \u2212 eml(\u2212ix, 1)) / (2i)\n\n**Test**: Formalize complex-valued EML expressions and prove that sin, cos, sinh, cosh all have exact finite EML representations with complex constants. Show this is impossible with real constants alone (proving a separation between real-EML and complex-EML expressivity).\n\n**Impact**: If successful, this establishes that complex EML is genuinely more expressive than real EML\u2014it can *exactly* represent trigonometric functions, not just approximate them. This would bridge complex analysis and algebraic expression theory, and has implications for signal processing (Fourier analysis as EML computation).\n\n**Catalog References**: `EML/Core.lean` (EML definitions), `Geometry/EMLStoneWeierstrass.lean` (existing Stone-Weierstrass connection)\n\n**Proof Strategy**: Define ComplexEMLExpr with complex constants. Show sin(x) = Im(exp(ix)) has a finite ComplexEMLExpr. For the separation result, use the fact that real-analytic EML compositions of finite depth are locally monotone (finitely many critical points on bounded intervals), while sin has infinitely many. This requires bounding the number of critical points of real EML expressions of bounded depth.\n\n**Domain Bridges**: Complex Analysis \u2194 EML Algebra \u2194 Signal Processing (Fourier Theory)\n\n**Lineage**: Builds on eml_density and the compilation framework from this cycle\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: EML Neural Architecture Theory\n\n**Conjecture**: A feedforward neural network with EML activation \u03c3(x) = exp(x) \u2212 log(max(x, \u03b5)) (for some small \u03b5 > 0) and n hidden units achieves approximation error O(1/n) for Lipschitz functions on compact positive domains\u2014matching the optimal rate for ReLU networks but with a single transcendental rather than a piecewise-linear activation.\n\n**Test**: Prove that n EML neurons suffice to approximate any Lipschitz-1 function on [1, e] to within O(1/n). Compare with known ReLU bounds. Formalize the construction in Lean 4.\n\n**Impact**: This would establish EML as a theoretically competitive neural activation function, with the advantage of smoothness (infinitely differentiable) over ReLU (non-smooth at 0). The single-operation architecture could simplify hardware implementations for neuromorphic computing.\n\n**Catalog References**: `Bridges/UniversalApproximation.lean` (existing universal approximation work), `EML/EMLNeuralNetworks.lean` (neural network composition structure)\n\n**Proof Strategy**: Use the log-polynomial approximation from the density theorem: a degree-n log-polynomial can be evaluated by a depth-O(log n) EML circuit with O(n) nodes. Bound the approximation error using the quantitative rates from Direction 1. The key lemma is that polynomial evaluation can be done in O(log degree) EML depth.\n\n**Domain Bridges**: Machine Learning (Universal Approximation) \u2194 EML Algebra \u2194 Circuit Complexity\n\n**Lineage**: Builds on eml_density, compile_size_linear, and eml_convexOn_fst from this cycle\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Tropical Limit of EML\n\n**Conjecture**: As t \u2192 \u221e, the rescaled EML operation eml_t(x, y) = (1/t) \u00b7 eml(tx, e^(ty)) = (1/t)(exp(tx) \u2212 ty) converges to max(x, 0) \u2212 y, connecting EML to tropical (min-plus) algebra. The EML density theorem should have a tropical shadow: the tropical EML algebra is dense in piecewise-linear continuous functions on compact domains.\n\n**Test**: Formalize the convergence eml_t \u2192 tropical_eml as t \u2192 \u221e. Prove the tropical EML density theorem directly (using the fact that max(x, 0) generates piecewise-linear functions). Show this is a degeneration of the smooth EML density theorem.\n\n**Impact**: This bridges the smooth world (EML, Stone-Weierstrass) with the combinatorial world (tropical geometry, piecewise-linear functions). It suggests a unifying framework where smooth and tropical approximation are limits of a single parametric family, connecting to the \"tropicalization\" program in algebraic geometry.\n\n**Catalog References**: `Tropical/TropicalOptimization.lean` (tropical optimization), `EML/EMLv17Core.lean` (EML core), `Cryptography/TropicalCryptography.lean` (tropical algebra)\n\n**Proof Strategy**: Define eml_t and compute its pointwise limit using L'H\u00f4pital's rule or dominated convergence. For the tropical density theorem, use the fact that max(x, 0) generates the lattice of continuous piecewise-linear functions by the lattice version of Stone-Weierstrass. Show this is consistent with taking the t \u2192 \u221e limit of the smooth density theorem.\n\n**Domain Bridges**: Tropical Geometry \u2194 EML Algebra \u2194 Piecewise-Linear Approximation \u2194 ReLU Networks\n\n**Lineage**: Builds on eml_density and connects to the Tropical research thread (Q=0.40)\n\n**Ambition**: extension\n\n---\n\n### Direction 5: EML Complexity Lower Bounds\n\n**Conjecture**: There exist explicit continuous functions f on [1, 2] that require EML expressions (log-polynomials) of degree \u03a9(1/\u03b5) to approximate to within \u03b5, and this bound is tight. Specifically, the function f(x) = sin(1/log(x)) on [e^(-\u03c0), e^(-1/\u03c0)] requires degree \u03a9(1/\u03b5) because it maps to sin on [1/\u03c0, \u03c0] under the log substitution, and Jackson's theorem gives matching upper and lower bounds for sin approximation by polynomials.\n\n**Test**: Formalize the lower bound by reducing to known polynomial approximation lower bounds via the log substitution. Show the upper bound matches by constructing an explicit log-polynomial approximant.\n\n**Impact**: The first complexity lower bound in the EML framework. This shows that EML universality, while true, has quantitative limitations: some functions are inherently expensive to represent. This connects to circuit complexity and the P vs NP question in a continuous analogue.\n\n**Catalog References**: `EML/StructuralDepth.lean` (depth bounds), `Bridges/UniversalApproxComplexity.lean` (complexity bounds)\n\n**Proof Strategy**: The key is the bijective correspondence between log-polynomials on [a, b] \u2282 (0, \u221e) and standard polynomials on [log(a), log(b)] via the substitution u = log(x). Lower bounds for polynomial approximation (Chebyshev, Bernstein) transfer directly to lower bounds for log-polynomial approximation.\n\n**Domain Bridges**: Approximation Theory \u2194 Circuit Complexity \u2194 EML Algebra\n\n**Lineage**: Builds on EMLTree.size_le_pow_totalDepth and eml_density from this cycle\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0914",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d62c07e9",
    "status": "available",
    "timestamp": "2026-06-07T06:45:30.232374+00:00",
    "title": "Rigorous mathematical foundation for the EML"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Causal Integration Algebra\n\n## Synthesis\n\nThis cycle established the **Causal Integration Algebra** \u2014 a rigorous lattice-theoretic formalization of Integrated Information Theory that identifies \u03a6 with the minimum cut of a weighted causal graph. We proved 18 theorems covering nonnegativity, decomposition characterization, composition/exclusion, scaling, monotonicity, and a novel symmetrization invariance result. The framework connects IIT to classical graph theory and opens several deep avenues.\n\nThe most promising cross-domain connection is between **integration theory and spectral graph theory**. The Fiedler value (algebraic connectivity) provides a lower bound on the minimum cut, and our scaling and monotonicity theorems suggest that the entire spectral structure of the graph Laplacian encodes integration properties. This connects consciousness science to one of the richest areas of combinatorial mathematics.\n\nThe highest breakthrough potential lies in **Direction 1**: formalizing the relationship between \u03a6 and algebraic connectivity. If this connection can be made precise, it would import the entire machinery of spectral graph theory into consciousness science \u2014 eigenvalue bounds, Cheeger inequalities, expander graphs, and random matrix theory would all become tools for understanding integration.\n\n---\n\n### Direction 1: Spectral Integration \u2014 \u03a6 and the Fiedler Value\n\n**Conjecture**: For any symmetric causal system C on n vertices, the Fiedler value \u03bb\u2082(L) of the graph Laplacian satisfies: \u03bb\u2082(L) \u2264 \u03a6(C) \u2264 n \u00b7 \u03bb\u2082(L) / 4, where L is the Laplacian matrix of the symmetrized causal graph with edge weights w(i,j) + w(j,i).\n\n**Test**: Compute both \u03a6 (by brute-force minimum cut) and \u03bb\u2082(L) (by eigenvalue computation) for all connected weighted graphs on 4-6 vertices with integer weights 1-3. Check whether the conjectured inequality holds.\n\n**Impact**: If true, this establishes a computable lower bound on \u03a6 via eigenvalue computation (O(n\u00b2) vs O(2\u207f) for brute-force \u03a6), and imports Cheeger-type inequalities into consciousness theory. If false, the failure case would reveal systems where spectral methods fundamentally mischaracterize integration.\n\n**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (CausalSystem, phi, symmetrize_phi), `Novelty/IntegratedInformation/Spectrum.lean` (phi_eq_min_cut, phi_mono_of_weight_le)\n\n**Proof Strategy**: \n1. Define the graph Laplacian L of a CausalSystem in Lean\n2. Prove the Courant-Fischer characterization of \u03bb\u2082\n3. Show that \u03a6 = min_A cross(A) \u2265 \u03bb\u2082 via the Rayleigh quotient bound\n4. Prove the upper bound using the Cheeger inequality\n\n**Domain Bridges**: Spectral Graph Theory \u2194 Integrated Information Theory \u2194 Algebraic Connectivity\n\n**Lineage**: Builds on phi_eq_min_cut, symmetrize_phi, crossInfo_le_totalWeight from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Dynamic Integration \u2014 Phase Transitions in Evolving Causal Systems\n\n**Conjecture**: For a one-parameter family of causal systems C(t) where w(i,j;t) = (1-t)\u00b7w_disconnected + t\u00b7w_connected (linear interpolation between a disconnected and fully connected system), there exists a critical threshold t* \u2208 (0,1) such that \u03a6(C(t)) = 0 for t < t* and \u03a6(C(t)) > 0 for t > t*. Moreover, t* = 1/n for the uniform complete graph target.\n\n**Test**: Compute \u03a6(C(t)) for n = 4,5,6 with the disconnected system being two equal halves and the connected system being the complete graph with unit weights. Plot \u03a6 vs t and verify the phase transition.\n\n**Impact**: If true, this identifies a sharp phase transition in integration, analogous to percolation thresholds in random graphs. This would connect IIT to critical phenomena and phase transitions \u2014 one of the deepest frameworks in statistical physics. If false, integration may emerge gradually rather than sharply, which would itself be informative.\n\n**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (phi, IsDisconnected, phi_zero_of_disconnected), `Novelty/IntegratedInformation/Spectrum.lean` (phi_mono_of_weight_le, phi_scale)\n\n**Proof Strategy**:\n1. Define CausalSystem.interpolate as a linear combination\n2. Show \u03a6 is continuous in the interpolation parameter (follows from min of continuous functions)\n3. Show \u03a6 = 0 at t = 0 (disconnected) and \u03a6 > 0 at t = 1 (strongly positive)\n4. Prove existence of t* by intermediate value theorem\n5. For the specific uniform case, compute t* exactly\n\n**Domain Bridges**: Statistical Physics (Phase Transitions) \u2194 Integrated Information \u2194 Percolation Theory\n\n**Lineage**: Builds on phi_zero_of_disconnected, phi_pos_of_strongly_positive, phi_mono_of_weight_le from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Categorical Integration \u2014 Causal Systems as Enriched Categories\n\n**Conjecture**: The category of causal systems (with morphisms being weight-reducing maps) admits a monoidal structure under direct sum, and \u03a6 extends to a lax monoidal functor to (\u211d\u22650, min, +). Specifically, \u03a6(C\u2081 \u2295 C\u2082) = min(\u03a6(C\u2081), \u03a6(C\u2082), cross(C\u2081,C\u2082)) where cross(C\u2081,C\u2082) is the minimum cross-flow between the two components.\n\n**Test**: Verify the functor properties for all pairs of causal systems on 2-3 vertices. Check that the monoidal structure axioms (associativity, unit) hold.\n\n**Impact**: If true, this provides a categorical foundation for IIT, enabling composition of conscious systems via universal constructions (limits, colimits). This would connect IIT to topos theory and provide a principled answer to the \"combination problem\" in philosophy of mind.\n\n**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (directSum, phi_directSum_eq_zero), `Bridges/ArrowDepthComplexity.lean` (category-theoretic methods)\n\n**Proof Strategy**:\n1. Define the category CausalSys with objects = CausalSystem n and morphisms = weight-reducing maps\n2. Verify well-definedness of composition\n3. Define the direct sum monoidal product\n4. Show \u03a6 is functorial (monotonicity implies functoriality)\n5. Verify the lax monoidal property\n\n**Domain Bridges**: Category Theory (Enriched Categories) \u2194 IIT \u2194 Monoidal Functors\n\n**Lineage**: Builds on directSum, phi_directSum_eq_zero, phi_mono_of_weight_le from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Integration Spectrum and Chromatic Number\n\n**Conjecture**: For a causal system C, define the \"zero graph\" G\u2080 as the graph with edges where w(i,j) = 0. Then the integration dimension (largest k where \u03a6_k > 0) equals the chromatic number \u03c7(G\u2080\u1d9c) of the complement of G\u2080 minus 1. In particular, for a strongly positive system, dim(C) = n - 1.\n\n**Test**: Enumerate all graphs on 4-5 vertices, assign random positive weights to edges and zero to non-edges. Compute integration dimension by brute-force k-partition enumeration. Compare with chromatic number of complement.\n\n**Impact**: If true, this provides a graph-coloring characterization of integration depth, connecting IIT to one of the central problems in combinatorics. If false, the failure cases would reveal interesting structures where integration dimension diverges from chromatic expectations.\n\n**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (KPartition, interPartFlow, interPartFlow_nonneg), `Novelty/IntegratedInformation/Spectrum.lean` (phi_pos_of_strongly_positive)\n\n**Proof Strategy**:\n1. Formalize integration dimension as a definition\n2. Show that \u03a6_k > 0 iff every k-partition has positive inter-part flow\n3. Relate this to the existence of edges between every pair of parts\n4. Connect to graph coloring: a proper coloring of G\u2080\u1d9c corresponds to a zero-flow partition\n\n**Domain Bridges**: Graph Coloring \u2194 Integration Spectrum \u2194 Complexity Theory (chromatic number is NP-hard)\n\n**Lineage**: Builds on KPartition, interPartFlow_nonneg from this cycle; connects to `critical_density_bounds` in Novelty/SegmentAlgebra.lean.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Information-Geometric Integration \u2014 \u03a6 on Statistical Manifolds\n\n**Conjecture**: When causal weights represent Fisher information between stochastic processes at each node, \u03a6 becomes a Riemannian distance on the statistical manifold of joint distributions. Specifically, \u03a6(C) \u2265 d_FI(p_joint, p_product) where d_FI is the Fisher-Rao distance between the joint distribution and the product of marginals.\n\n**Test**: For binary causal systems (each node has state 0 or 1) with n = 3-4, compute \u03a6 (minimum cut) and d_FI (Fisher-Rao distance between joint and product distributions) numerically. Check whether the inequality holds.\n\n**Impact**: If true, this embeds IIT in information geometry \u2014 one of the most elegant frameworks in mathematical statistics. \u03a6 would acquire a geometric interpretation as a \"distance from independence\" on a curved statistical manifold. This would also provide natural connections to machine learning (natural gradient descent) and quantum information (quantum Fisher information).\n\n**Catalog References**: `Novelty/IntegratedInformation/Spectrum.lean` (phi_le_totalWeight, phi_scale), `Bridges/PadicQuantumInformation.lean` (information-theoretic methods)\n\n**Proof Strategy**:\n1. Define Fisher information matrix for a causal system\n2. Define the Fisher-Rao metric on the simplex of joint distributions\n3. Show that the minimum cut provides an upper bound on the geodesic distance\n4. Prove the lower bound using the data processing inequality\n\n**Domain Bridges**: Information Geometry \u2194 IIT \u2194 Statistical Manifolds \u2194 Quantum Information\n\n**Lineage**: Builds on phi_le_totalWeight, crossInfo_le_totalWeight from this cycle; connects to `ultrametric_entropy_composition_bound` in Bridges/PadicQuantumInformation.lean.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0915",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "f18d283e",
    "status": "available",
    "timestamp": "2026-06-07T06:46:00.326851+00:00",
    "title": "**Causal Integration Algebra** \u2014 a rigorous lattice-t"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n## Synthesis\n\nThis research cycle introduced **inflation algebras** \u2014 a novel algebraic structure that captures the combinatorial core of hierarchical substitution tilings. By stripping geometry from substitution rules and retaining only the non-negative integer matrix encoding tile decompositions, we obtained a clean algebraic object with a monoid structure (under composition), a complexity trace function, and a determinantal aperiodicity criterion. We proved that the hat monotile's substitution matrix satisfies this criterion (det(M \u2212 I) = \u22123 \u2260 0), is primitive (M\u00b2 has all positive entries), and is symmetric \u2014 properties that certify aperiodicity and ensure uniform tile frequencies.\n\nThe most promising cross-domain connection is to **dynamical systems theory**. We formalized the substitution as a linear map on frequency vectors and proved that algebraic aperiodicity is equivalent to the absence of non-trivial fixed points. This bridges tiling theory to the Catalog's existing work on periodic orbits (`exists_periodic_point_finite` in `Bridges/ProofStoneCechDynamics.lean`) and cellular automata dynamics (`rule204_all_periodic` in `Bridges/PeriodicOrbitVarieties.lean`). The next cycle should exploit this bridge aggressively: the tools developed for proving periodic orbit existence/absence in finite dynamical systems can be adapted to analyze substitution tiling systems.\n\nThe highest breakthrough potential lies in **Direction 1 (Spectral Classification)**: characterizing which substitution matrices yield aperiodic monotiles. This would transform the search for new aperiodic tilings from geometric exploration to algebraic computation \u2014 a paradigm shift analogous to how algebraic geometry transformed classical geometry.\n\n---\n\n### Direction 1: Spectral Classification of Aperiodic Substitution Matrices\n\n**Conjecture**: Among 4\u00d74 non-negative integer matrices with uniform row sum r \u2265 2 and all eigenvalues having absolute value \u2260 1 (no roots of unity), the set that arises as substitution matrices of planar aperiodic monotiles is characterized by exactly three additional constraints: (i) the matrix is symmetric, (ii) the Perron eigenvalue equals the row sum, and (iii) the second-largest eigenvalue satisfies \u03bb\u2082 \u2264 r/2.\n\nAn inflation algebra over n prototile types is a non-negative integer matrix M \u2208 M_n(\u2124\u22650). The *algebraic aperiodicity condition* is det(M \u2212 I) \u2260 0. The *primitivity condition* is that some M^k has all strictly positive entries. The hat substitution matrix satisfies both, with eigenvalues {4, 2, 2, 0}.\n\n**Test**: Enumerate all 4\u00d74 non-negative symmetric integer matrices with row sum 4 (there are finitely many). For each, compute eigenvalues and check: (a) all eigenvalues have |\u03bb| \u2260 1, (b) M is primitive. The resulting set should be small. Attempt geometric realization for each candidate. Compare with known aperiodic monotile families.\n\n**Impact**: If true, this reduces the search for aperiodic monotiles to a finite computation in each dimension, transforming the problem from geometric search to algebraic classification. If false, the counterexamples would reveal which algebraic conditions are necessary vs. sufficient.\n\n**Catalog References**: `Novelty/InflationAlgebra.lean` (inflation algebra definition, hat matrix analysis), `Bridges/ProofStoneCechDynamics.lean` (periodic point theory)\n\n**Proof Strategy**: Start by proving that symmetry of the substitution matrix implies a duality in the tiling (each tile's \"dual\" is also a valid tile). Then prove that the Perron eigenvalue equaling the row sum is equivalent to having a uniform supertile size. Finally, investigate whether the eigenvalue bound \u03bb\u2082 \u2264 r/2 corresponds to a mixing condition on the substitution.\n\n**Domain Bridges**: Tiling Theory \u2194 Spectral Graph Theory (substitution matrix as adjacency matrix of a directed graph), Tiling Theory \u2194 Number Theory (characteristic polynomial constraints on eigenvalues)\n\n**Lineage**: Builds on `hat_symmetric`, `hat_det_zero`, `hat_primitive` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Roots-of-Unity Aperiodicity and Cyclotomic Obstructions\n\n**Conjecture**: An inflation algebra with n \u00d7 n substitution matrix M is *strongly aperiodic* (det(M^k \u2212 I) \u2260 0 for all k \u2265 1) if and only if the characteristic polynomial of M shares no roots with any cyclotomic polynomial \u03a6_m(x) for m \u2265 1. Equivalently: no eigenvalue of M (over \u2102) is a root of unity.\n\nThis cycle discovered that the naive conjecture \"det(M \u2212 I) \u2260 0 implies det(M^k \u2212 I) \u2260 0\" is FALSE (counterexample: M = [\u22121]). The correct condition involves cyclotomic polynomials. For the hat matrix with eigenvalues {4, 2, 2, 0}, the characteristic polynomial is x(x\u22122)\u00b2(x\u22124), which shares no roots with any \u03a6_m(x), so the hat algebra is strongly aperiodic.\n\n**Test**: \n1. Compute gcd(char_poly(M_hat), \u03a6_m(x)) for m = 1, 2, ..., 100. All should be 1.\n2. Construct a matrix M' with eigenvalue e^{2\u03c0i/3} (a primitive cube root of unity) and verify det(M'\u00b3 \u2212 I) = 0 despite det(M' \u2212 I) \u2260 0.\n3. Prove: if char_poly(M) is irreducible over \u211a and has degree > 1, then M is strongly aperiodic iff char_poly(M) is not cyclotomic.\n\n**Impact**: Establishes the correct general aperiodicity criterion, replacing the too-weak det(M \u2212 I) \u2260 0 condition. Would give a complete algebraic characterization of when hierarchical substitutions produce aperiodic tilings.\n\n**Catalog References**: `Novelty/InflationAlgebra.lean` (counterexample to alg_aperiodic_pow), `Algebra/Advanced.lean` (iterative algebraic constructions)\n\n**Proof Strategy**: Formalize cyclotomic polynomials (already in Mathlib as `Polynomial.cyclotomic`). Prove that det(M^k \u2212 I) = 0 iff M^k has eigenvalue 1 iff M has eigenvalue \u03b6 with \u03b6^k = 1 iff char_poly(M) and \u03a6_k share a root. Use resultants for the gcd computation.\n\n**Domain Bridges**: Tiling Theory \u2194 Algebraic Number Theory (cyclotomic fields), Tiling Theory \u2194 Galois Theory (splitting fields of characteristic polynomials)\n\n**Lineage**: Builds on the disproof of `alg_aperiodic_pow` and the correct analysis of eigenvalue conditions from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Inflation Algebras\n\n**Conjecture**: Replacing standard matrix multiplication with tropical (min-plus) multiplication in the inflation algebra framework yields a *tropical inflation algebra* whose tropical eigenvalue (= minimum cycle mean of the associated directed graph) determines the *linear repetitivity* of the tiling. Specifically, if the tropical eigenvalue is \u03bb_trop, then every pattern of diameter d appears within distance O(d \u00b7 exp(\u03bb_trop)) in the tiling.\n\nA tropical inflation algebra replaces (\u2124, +, \u00d7) with (\u2124 \u222a {\u221e}, min, +). The substitution matrix M becomes a distance matrix: M_{ij} = minimum \"cost\" of producing tile j from tile i. The tropical eigenvalue measures the most efficient substitution path.\n\n**Test**: Compute the tropical eigenvalue of the hat substitution matrix (replace entries: 0 \u2192 \u221e, positive k \u2192 k, then find minimum cycle mean). Compare with known linear repetitivity bounds for the hat tiling.\n\n**Impact**: Would bridge aperiodic tiling theory to tropical geometry, connecting two seemingly unrelated areas. The Catalog already has extensive tropical algebra machinery (`Tropical/CertifiedNormalForm.lean`, `Tropical/PeriodicOrbits.lean`, `Algebra/TropicalDragon.lean`) that could be directly applied.\n\n**Catalog References**: `Tropical/CertifiedNormalForm.lean`, `Tropical/PeriodicOrbits.lean` (tropical periodic orbits), `Algebra/TropicalDragon.lean` (tropical algebraic structures), `Novelty/InflationAlgebra.lean`\n\n**Proof Strategy**: Define `TropInflAlg` by analogy with `InflAlg` but over the tropical semiring. Prove composition is still associative (follows from tropical matrix multiplication). Define tropical complexity as the tropical trace of M^k. Prove connection to repetitivity using the correspondence between tropical eigenvalues and cycle means in directed graphs.\n\n**Domain Bridges**: Tiling Theory \u2194 Tropical Geometry (via tropical matrix algebra), Tiling Theory \u2194 Combinatorial Optimization (cycle mean = shortest path)\n\n**Lineage**: Builds on `InflAlg` from this cycle and tropical algebra from `Tropical/` catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Entropy of Inflation Algebras and Phase Transitions\n\n**Conjecture**: Define the *substitution entropy* of an inflation algebra as h(M) = log(\u03bb\u2081) where \u03bb\u2081 is the Perron eigenvalue. For the space of all n \u00d7 n inflation algebras with fixed row sum r, the entropy h(M) = log(r) is maximal (achieved by the matrix with all entries r/n if n | r). As the matrix is \"deformed\" away from this uniform point, there exists a critical threshold h_c below which aperiodicity becomes impossible (all matrices with h < h_c admit periodic tilings).\n\n**Test**: For 3\u00d73 matrices with row sum 6, enumerate primitive matrices, compute entropy log(\u03bb\u2081), and check aperiodicity (det(M \u2212 I) \u2260 0 and no roots of unity). Plot the boundary between aperiodic and periodic regions in the space of matrices. Look for a phase transition at a critical entropy value.\n\n**Impact**: Would establish a thermodynamic-style phase transition in tiling theory \u2014 a connection between information theory and geometry that would be genuinely surprising and impactful.\n\n**Catalog References**: `Novelty/InflationAlgebra.lean` (entropy = log(Perron eigenvalue)), `EML/AdvancedTheory.lean` (complexity measures), `Bridges/ProofStoneCechDynamics.lean` (dynamical phase transitions)\n\n**Proof Strategy**: Start by proving h(M\u2081 \u00b7 M\u2082) = h(M\u2081) + h(M\u2082) for commuting matrices (follows from Perron eigenvalue multiplicativity). Then investigate the non-commutative case. For the phase transition: use the spectral gap (\u03bb\u2081 \u2212 \u03bb\u2082) as the order parameter and look for discontinuities as matrix entries vary.\n\n**Domain Bridges**: Tiling Theory \u2194 Statistical Mechanics (phase transitions), Tiling Theory \u2194 Information Theory (entropy), Tiling Theory \u2194 Random Matrix Theory (eigenvalue distributions)\n\n**Lineage**: Builds on `complexity_add`, `primitive_complexity_pos` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Higher-Dimensional Inflation Algebras and 3D Aperiodic Monotiles\n\n**Conjecture**: The inflation algebra framework extends to d dimensions by requiring that the Perron eigenvalue of M equals the row sum raised to the power 1 (not d), because the substitution matrix counts tiles, not volume. In 3D, there exists a substitution matrix M \u2208 M_6(\u2124\u22650) with Perron eigenvalue 8, det(M \u2212 I) \u2260 0, and a geometric realization as a 3D aperiodic monotile with 6 metatile types.\n\nThe 3D aperiodic monotile problem remains open. The algebraic framework suggests looking for 3D substitution rules by searching over matrices rather than shapes, dramatically reducing the search space.\n\n**Test**: Enumerate 6\u00d76 non-negative symmetric integer matrices with row sum 8, det(M \u2212 I) \u2260 0, and all eigenvalues non-roots-of-unity. For each candidate, check primitivity. The surviving candidates form the \"algebraic feasibility set\" for 3D aperiodic monotiles.\n\n**Impact**: Could lead to the discovery of a 3D aperiodic monotile \u2014 a major open problem in discrete geometry. Even partial results (constraining the algebraic properties of any potential 3D aperiodic monotile) would be significant.\n\n**Catalog References**: `Novelty/InflationAlgebra.lean` (inflation algebra framework), `Geometry/` (geometric constructions)\n\n**Proof Strategy**: Generalize the hat analysis: prove that in d dimensions, the substitution matrix of a monotile with expansion factor \u03bb has Perron eigenvalue \u03bb^d (volume scaling). Then prove constraints on the characteristic polynomial from geometric realizability. Use these constraints to narrow the search space.\n\n**Domain Bridges**: Tiling Theory \u2194 Crystallography (3D symmetry groups), Tiling Theory \u2194 Computational Geometry (geometric realization algorithms)\n\n**Lineage**: Builds on entire inflation algebra framework from this cycle.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0942",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "89a62d78",
    "status": "available",
    "timestamp": "2026-06-07T12:34:03.079841+00:00",
    "title": "**inflation algebras** \u2014 a novel algebraic struct"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Collatz Dynamics, Encoding, and Proof Barriers\n\n## Synthesis\n\nThis cycle established three pillars of Collatz structure theory: (1) the tree structure of orbits via the orbit merge theorem, (2) the affine encoding over \u211a connecting Collatz dynamics to linear algebra, and (3) an abstract proof-barrier framework for \u03a0\u2082\u2070 statements. The most promising cross-domain connection is the **affine encoding bridge**: by representing Collatz orbits as products of 2\u00d72 rational matrices, we connect number-theoretic dynamics to the theory of iterated function systems and semigroup actions \u2014 opening the door to spectral methods, ergodic theory, and even tropical geometry approaches.\n\nThe parity ratio bound (odd steps \u2264 \u2308k/2\u2309) and the consecutive halvings theorem (controlled by 2-adic valuation) together give a quantitative picture of how orbits evolve. The key gap is between the *average* shrinkage factor of 3/4 (which suggests convergence) and the *worst-case* behavior (which could, in principle, produce unbounded growth). The highest breakthrough potential lies in Direction 1: connecting the affine encoding to spectral properties of the Collatz semigroup could yield quantitative bounds on orbit growth that apply uniformly.\n\nThe abstract proof barrier theorem provides the framework for an eventual independence result, but the gap between the abstract mechanism and the specific Collatz case remains wide. Directions 3 and 4 target this gap from complementary angles.\n\n---\n\n### Direction 1: Spectral Theory of the Collatz Semigroup\n\n**Conjecture**: The semigroup generated by the two 2\u00d72 matrices M\u2080 = [[1/2, 0], [0, 1]] and M\u2081 = [[3, 1], [0, 1]] over \u211a has the property that for every product P of these generators of sufficient length, the (1,1)-entry of P is strictly less than 1. Equivalently, every sufficiently long parity word w has multiplier(w) < 1.\n\n**Test**: Compute multiplier(w) = 3^s / 2^k for all binary words w of length k with s ones. For the conjecture to hold, we need 3^s / 2^k < 1 whenever s < k\u00b7(log 2)/(log 3) \u2248 0.63\u00b7k. Since parity exclusion forces s \u2264 \u2308k/2\u2309 \u2264 0.5\u00b7k + 0.5, and 0.5 < 0.63, the multiplier is always < 1 for valid parity words of length k \u2265 2. Verify this algebraically and prove the implication for orbit growth.\n\n**Impact**: If true, this would show that every valid Collatz orbit of length k multiplies the starting value by a factor strictly less than 1, plus an additive correction. Combined with bounds on the offset, this could yield a uniform bound on orbit growth.\n\n**Catalog References**: `Catalog/Novelty/CollatzUndecidability.lean`, `Novelty/CollatzProofBarrier.lean` (multiplier_pos, multiplier_append, affine_image_append)\n\n**Proof Strategy**: \n1. Prove that valid parity words (satisfying parity exclusion) have at most \u2308k/2\u2309 ones.\n2. Show 3^(\u2308k/2\u2309) / 2^k < 1 for k \u2265 2 using the inequality 3^(1/2) < 2.\n3. Use the composition law to bound the multiplier of concatenated words.\n4. Bound the offset growth to show net convergence.\n\n**Domain Bridges**: Number Theory (Collatz) \u2194 Linear Algebra (semigroup actions) \u2194 Dynamical Systems (IFS contraction)\n\n**Lineage**: Builds on this cycle's affine encoding (multiplier_append, affine_image_append) and parity ratio bound (odd_steps_le_half).\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Tropical Collatz and Min-Plus Dynamics\n\n**Conjecture**: The Collatz map, when lifted to the tropical semiring (\u211d \u222a {\u221e}, min, +), exhibits contraction behavior. Specifically, define the tropical Collatz map as T_trop(x) = min(x - log 2, x + log 3 + log(1 + 3^(-x))) on the tropical projective line. The conjecture is that T_trop has a unique fixed point and all orbits converge to it.\n\n**Test**: Implement the tropical Collatz map numerically and verify convergence for x \u2208 [0, 100]. Formally, prove that the tropical Collatz map is a contraction in an appropriate metric.\n\n**Impact**: Tropical geometry provides a bridge between combinatorial and continuous dynamics. If the tropical Collatz map contracts, it would give a \"shadow proof\" of the Collatz conjecture at the level of logarithmic magnitudes \u2014 the correct asymptotic intuition even if the number-theoretic details resist formalization.\n\n**Catalog References**: `Catalog/Tropical/CollatzWielandt.lean`, `Catalog/Computation/CollatzTropical.lean`\n\n**Proof Strategy**:\n1. Define the tropical Collatz map on \u211d.\n2. Show it is a contraction with respect to a weighted metric.\n3. Apply the Banach fixed-point theorem to conclude convergence.\n4. Relate the tropical fixed point back to the Collatz conjecture via exponentiation.\n\n**Domain Bridges**: Number Theory (Collatz) \u2194 Tropical Geometry (min-plus algebra) \u2194 Functional Analysis (contraction mapping)\n\n**Lineage**: Extends tropical connections from `Catalog/Tropical/CollatzWielandt.lean` and the growth analysis from this cycle (syracuse_gt, two_step_ratio_bound).\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Collatz Stopping Time and the Fast-Growing Hierarchy\n\n**Conjecture**: The Collatz stopping time function \u03c3(n) = min{k : T^k(n) = 1} satisfies \u03c3(n) = O(log(n)^2) for all n, but cannot be bounded by any function in the fast-growing hierarchy below level \u03c9 (i.e., below the Ackermann function level).\n\n**Test**: Compute max{\u03c3(n) : n \u2264 N} / (log\u2082 N)\u00b2 for N = 10^k, k = 2,...,8, and check if this ratio stabilizes. For the independence angle, attempt to construct explicit inputs n_k (parameterized by k) whose stopping times grow superpolynomially in log(n_k).\n\n**Impact**: If \u03c3(n) = O(log(n)^C) for some C, the Collatz conjecture is provable in PA (since this bound is primitive recursive). If \u03c3(n) grows faster than any multiply recursive function, the conjecture is independent of PA. Determining the growth rate is the key to the independence question.\n\n**Catalog References**: `Catalog/Novelty/CollatzUndecidability.lean` (stoppingTimeQuadBound), `Novelty/CollatzProofBarrier.lean` (proof_barrier, witness_function)\n\n**Proof Strategy**:\n1. Formalize the fast-growing hierarchy f_\u03b1 for \u03b1 < \u03b5\u2080 in Lean.\n2. Show that PA-provable \u03a0\u2082\u2070 statements have witnesses bounded by f_\u03b1 for some \u03b1 < \u03b5\u2080.\n3. Either find an explicit bound on \u03c3(n) (proving it's in the hierarchy) or construct sequences with superfast growth (proving independence).\n\n**Domain Bridges**: Number Theory (Collatz) \u2194 Proof Theory (ordinal analysis, fast-growing hierarchy) \u2194 Computability (provably total functions)\n\n**Lineage**: Directly extends this cycle's proof barrier framework and the bounded-universal gap theorem.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: 2-Adic Analysis of Collatz Orbits\n\n**Conjecture**: The Collatz map T extends to a continuous function on the 2-adic integers \u2124\u2082, and the ergodic properties of this extension determine the orbit statistics of the standard Collatz map on \u2115. Specifically, the Collatz map on \u2124\u2082 is ergodic with respect to the Haar measure, and this ergodicity explains the empirical observation that the \"density\" of odd steps in long orbits approaches log(2)/log(3) \u2248 0.63.\n\n**Test**: Formalize the 2-adic Collatz extension in Lean 4 using Mathlib's `PadicInt`. Prove continuity of the extension. Compute the invariant measure numerically.\n\n**Impact**: The 2-adic perspective unifies the residue class propagation theorems (mod 4, mod 8, etc.) into a single coherent framework. If the ergodic theory can be made rigorous, it would explain *why* the 3/4 shrinkage heuristic works without proving the conjecture itself \u2014 a conceptual advance even without a full resolution.\n\n**Catalog References**: `Novelty/CollatzOrbitTree.lean` (T_mod4_zero, T_mod4_one_double, T_mod4_three_double), `Novelty/CollatzProofBarrier.lean` (consecutive_halvings_eq_v2)\n\n**Proof Strategy**:\n1. Define T on \u2124\u2082 using `PadicInt` from Mathlib.\n2. Prove T is continuous (it's piecewise polynomial, so Lipschitz).\n3. Compute the action on residue classes mod 2^k for small k.\n4. Investigate the invariant measure and its connection to orbit statistics.\n\n**Domain Bridges**: Number Theory (Collatz) \u2194 p-Adic Analysis (\u2124\u2082 dynamics) \u2194 Ergodic Theory (invariant measures)\n\n**Lineage**: Extends the mod-4 analysis from this cycle and the consecutive halvings theorem.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Collatz as a One-Way Function\n\n**Conjecture**: The Collatz map, when restricted to odd numbers via the Syracuse function S(n) = (3n+1)/2, is computationally one-way in the following sense: given a random odd number m in [1, N], finding an odd preimage n with S^k(n) = m (for unknown k) requires time \u03a9(N^\u03b5) for some \u03b5 > 0, assuming standard cryptographic hardness assumptions.\n\n**Test**: Implement a preimage-finding algorithm for the Syracuse function and measure its empirical time complexity. Compare with the branching factor of the inverse tree.\n\n**Impact**: If the Collatz map is one-way, it could serve as the basis for a novel cryptographic hash function with a clean mathematical pedigree. More fundamentally, computational one-wayness would be a concrete obstruction to proof: if finding long inverse orbits is computationally hard, then *proving* that all orbits converge would require non-constructive methods.\n\n**Catalog References**: `Catalog/Cryptography/CollatzOneWay.lean`, `Catalog/Cryptography/CollatzOWF.lean`, `Novelty/CollatzOrbitTree.lean` (odd_preimage_exists, odd_preimage_mod6)\n\n**Proof Strategy**:\n1. Formalize the Syracuse inverse tree as a branching process.\n2. Show the branching factor is approximately 2/3 (since only n \u2261 4 mod 6 have odd preimages).\n3. Analyze the depth vs. breadth tradeoff in inverse orbit search.\n4. Relate to known hardness assumptions (e.g., discrete log in related groups).\n\n**Domain Bridges**: Number Theory (Collatz) \u2194 Cryptography (one-way functions) \u2194 Complexity Theory (preimage resistance)\n\n**Lineage**: Extends the inverse preimage classification from this cycle and connects to existing catalog work on Collatz as OWF.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0949",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "e0179fa4",
    "status": "available",
    "timestamp": "2026-06-07T13:43:06.606297+00:00",
    "title": "Three pillars of Collatz structure theory: (1) the tree s"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Diophantine Approximation on ReLU Networks\n\n## Synthesis\n\nThis cycle established a rigorous framework connecting ReLU neural network architecture to number-theoretic approximation quality. The central insight is a **depth-width duality**: the piece count w^L grows exponentially while parameter count grows linearly, making deep networks exponentially more parameter-efficient for constant approximation. The **tropical-ReLU bridge** emerged as the most surprising finding \u2014 the gap between smooth softplus and hard ReLU has a clean closed-form expression log(1 + exp(-|x|)) bounded by log(2), connecting neural network theory to Maslov's dequantization from mathematical physics.\n\nThe strongest cross-domain connection is between tropical geometry and neural network expressiveness. Every ReLU network computes a tropical rational function, and the depth-width tradeoff mirrors tropical intersection multiplicity. This suggests that tropical algebraic geometry tools (Newton polytopes, tropical B\u00e9zout's theorem, tropical Hodge theory) could yield new neural network complexity bounds. The Leibniz series pipeline for \u03c0 approximation demonstrates that classical series acceleration techniques translate directly into neural network architecture optimization.\n\nThe direction with highest breakthrough potential is **Direction 1** below: proving that the irrationality measure of a target constant determines the optimal network depth, establishing a deep bridge between transcendental number theory and neural network complexity.\n\n---\n\n### Direction 1: Irrationality Measure as Neural Network Complexity Measure\n\n**Conjecture**: For a real number \u03b1 with irrationality measure \u03bc(\u03b1), the minimum depth of a width-w ReLU network approximating \u03b1 to within \u03b5 satisfies:\n$$L^* = \\Theta\\left(\\frac{\\log(1/\\varepsilon)}{\\log w \\cdot \\mu(\\alpha)}\\right)$$\n\nIn particular, Liouville numbers (\u03bc = \u221e) require only O(1) depth, algebraic irrationals (\u03bc = 2 by Roth's theorem) require O(log(1/\u03b5)/(2\u00b7log w)) depth, and rational numbers (\u03bc = 1) require O(0) depth (exact representation).\n\n**Test**: Construct explicit ReLU network families for:\n(a) \u03b1 = \u03a3 10^{-k!} (Liouville number, \u03bc = \u221e) \u2014 should need O(1) depth\n(b) \u03b1 = \u221a2 (algebraic, \u03bc = 2) \u2014 should need \u0398(log(1/\u03b5)) depth\n(c) \u03b1 = \u03c0 (transcendental, \u03bc \u2264 7.6064... by Zeilberger-Zudilin) \u2014 depth between cases (a) and (b)\n\nVerify computationally for \u03b5 \u2208 {10^{-1}, ..., 10^{-10}} and compare empirical depth requirements.\n\n**Impact**: Would establish irrationality measure as the *universal complexity measure* for constant approximation by neural networks. This bridges transcendental number theory (Roth, Baker, Schmidt) directly to deep learning theory, potentially explaining why some constants are easier to learn than others in practice.\n\n**Catalog References**: `MachineLearning/DiophantineReLU/Foundations.lean` (depth_beats_width, leibniz_terms_for_epsilon), `Tropical/TropicalOracleResearch.lean` (depth_width_pieces)\n\n**Proof Strategy**:\n1. Upper bound: Use continued fraction convergents p_n/q_n of \u03b1. By irrationality measure, |\u03b1 - p_n/q_n| < q_n^{-\u03bc+\u03b5}. Each convergent is rational \u2192 exact ReLU representation. Need log_w(q_n) depth for denominator q_n. The n-th convergent has q_n ~ \u03c6^n, so depth ~ n ~ log(q_n) ~ log(1/\u03b5)^{1/\u03bc}.\n2. Lower bound: Any width-w depth-L network outputs a rational with denominator \u2264 B^{O(wL)} (where B bounds weights). By irrationality measure lower bound, need denominator \u2265 (1/\u03b5)^{1/(\u03bc+\u03b4)}.\n\n**Domain Bridges**: Number Theory (irrationality measure) \u2194 Machine Learning (network depth) \u2194 Tropical Geometry (tropical rational complexity)\n\n**Lineage**: Builds on depth_beats_width and leibniz_terms_for_epsilon from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Tropical B\u00e9zout Theorem for Neural Network Composition\n\n**Conjecture**: When two ReLU networks f (with m tropical zeros) and g (with n tropical zeros) are composed, the number of tropical zeros of f \u2218 g is exactly m\u00b7n minus the number of \"tropical cancellations\" at shared breakpoints. Formally:\n$$\\text{trop-zeros}(f \\circ g) = m \\cdot n - \\text{cancel}(f, g)$$\nwhere cancel(f, g) counts the breakpoints of g that map to breakpoints of f with matching slopes.\n\n**Test**: Enumerate all width-2 depth-3 networks (a finite parameterization), compute tropical zeros, and verify the B\u00e9zout count. Check whether cancel(f,g) = 0 generically (for random weights).\n\n**Impact**: A tropical B\u00e9zout theorem for neural networks would give exact (not just upper bound) piece counts for composed networks. This could lead to tight lower bounds on network depth for specific functions, resolving open questions in neural network complexity.\n\n**Catalog References**: `Tropical/TropicalOracleResearch.lean` (depth_width_pieces, tropDet_mono), `MachineLearning/DiophantineReLU/DepthWidthTradeoff.lean` (compose_piece_count)\n\n**Proof Strategy**:\n1. Define tropical zeros of a piecewise linear function as points where the slope changes\n2. Prove composition multiplies zeros (upper bound from chain rule)\n3. Characterize cancellation conditions using tropical intersection theory\n4. Show cancellation is measure-zero in parameter space (genericity)\n\n**Domain Bridges**: Tropical Geometry (B\u00e9zout's theorem) \u2194 Neural Networks (depth-width tradeoff) \u2194 Algebraic Geometry (intersection multiplicity)\n\n**Lineage**: Builds on relu_piece_count_bound and compose_piece_count from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Series Acceleration as Architecture Optimization\n\n**Conjecture**: The Euler-Maclaurin transformation of the Leibniz series (which accelerates convergence from O(1/N) to O(1/N\u00b2)) corresponds to a specific neural network architecture transformation that reduces depth by a factor of 2. More generally, k-fold Richardson extrapolation maps depth-L networks to depth-L/(k+1) networks with the same approximation quality.\n\n**Test**: Implement the Euler transform of the Leibniz series in a ReLU network. Compare the depth needed for 10^{-6} approximation of \u03c0 between:\n(a) Raw Leibniz: ~500,000 terms \u2192 depth ~19\n(b) Euler-accelerated: ~1,000 terms \u2192 depth ~10\n(c) Machin's formula: ~25 terms \u2192 depth ~5\n\n**Impact**: Would establish a systematic theory of \"neural architecture search via series acceleration,\" connecting numerical analysis (Richardson, Romberg, Pad\u00e9) to neural network design. Could yield provably optimal architectures for constant approximation.\n\n**Catalog References**: `MachineLearning/DiophantineReLU/Foundations.lean` (leibniz_abs, leibniz_abs_antitone)\n\n**Proof Strategy**:\n1. Formalize the Euler transform: S'_n = \u03a3 C(n,k) S_{k+m} / 2^n\n2. Prove the accelerated error bound: |S'_n - \u03c0/4| = O(1/4^n)\n3. Show the Euler transform is implementable by a constant-width ReLU extension\n4. Prove the depth reduction: O(log(1/\u03b5)) \u2192 O(log(log(1/\u03b5)))\n\n**Domain Bridges**: Numerical Analysis (series acceleration) \u2194 Machine Learning (architecture search) \u2194 Approximation Theory (convergence rates)\n\n**Lineage**: Builds on leibniz_terms_for_epsilon from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Quantized Weight Networks and Diophantine Constraints\n\n**Conjecture**: A ReLU network with integer weights bounded by B and L layers can only output rationals with denominators dividing B^{O(L)}. Therefore, the minimum weight magnitude for \u03b5-approximation of an irrational constant \u03b1 satisfies:\n$$B^* \\geq \\left(\\frac{1}{\\varepsilon}\\right)^{1/O(L)}$$\n\nFor fixed depth L, the weight precision (number of bits per weight) must be at least \u03a9(log(1/\u03b5)/L).\n\n**Test**: For networks with weights in {-B,...,B}, enumerate all possible outputs for small B and L. Verify the denominator bound. Check whether the bound is tight for \u03c0 approximation.\n\n**Impact**: This has direct practical implications for neural network quantization \u2014 a technique used to deploy large models on edge devices. Current quantization heuristics lack theoretical guarantees; this would provide them. The Diophantine constraint (denominators divide B^{O(L)}) connects to the theory of S-integers in algebraic number theory.\n\n**Catalog References**: `MachineLearning/DiophantineReLU/Foundations.lean` (param_count_lower_bound), `MachineLearning/DiophantineReLU/DepthWidthTradeoff.lean` (pieces_exceed_params)\n\n**Proof Strategy**:\n1. Track denominators through affine transformations: if input has denominator d and weights have denominator B, output has denominator dividing d\u00b7B\n2. Through L layers: denominator divides B^L (telescoping)\n3. ReLU preserves denominators (max of rationals is rational with same denominator)\n4. Lower bound follows from irrationality of target\n\n**Domain Bridges**: Number Theory (S-integers, denominators) \u2194 Machine Learning (quantization) \u2194 Computer Architecture (fixed-point arithmetic)\n\n**Lineage**: Builds on param_count_lower_bound and info_lower_bound from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Hodge Theory and Network Generalization\n\n**Conjecture**: The \"tropical Betti numbers\" of a ReLU network (defined as the ranks of homology groups of its tropical variety) predict generalization performance. Specifically, networks with lower tropical Betti numbers generalize better, analogous to how smoother functions (lower Sobolev norm) generalize better in classical learning theory.\n\n**Test**: Train small ReLU networks on regression tasks. Compute the tropical variety (the set of points where the network is non-differentiable, i.e., breakpoints). Compute its homological complexity. Correlate with test error.\n\n**Impact**: Would provide a geometric explanation for neural network generalization, currently one of the biggest open problems in deep learning theory. The tropical geometry perspective offers a completely new lens, potentially resolving the \"generalization puzzle\" (why do overparameterized networks generalize well?).\n\n**Catalog References**: `Tropical/TropicalOracleResearch.lean` (relu_preserves_tropical_max, tropDet_mono), `MachineLearning/DiophantineReLU/Foundations.lean` (relu_is_tropical_add, soft_hard_gap_formula)\n\n**Proof Strategy**:\n1. Define tropical variety of a ReLU network as the breakpoint set\n2. Compute tropical Betti numbers using persistent homology or direct tropical homology\n3. Prove upper bound: tropical Betti numbers \u2264 piece count - 1\n4. Prove lower bound: generalization error \u2265 f(tropical Betti numbers) using covering number arguments\n\n**Domain Bridges**: Tropical Geometry (tropical homology) \u2194 Machine Learning (generalization theory) \u2194 Algebraic Topology (persistent homology)\n\n**Lineage**: Builds on relu_is_tropical_add and soft_hard_gap_formula from this cycle.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_0951",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "21b124b9",
    "status": "available",
    "timestamp": "2026-06-07T14:16:52.218634+00:00",
    "title": "Rigorous framework connecting ReLU neural network archi"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Research Directions: Tropical Min-Plus Cryptography\n\n## Synthesis\n\nThis research cycle established three structural results about tropical cryptography that collectively reveal the landscape of TDLP security: power stagnation constrains the effective key space from above, diagonal vulnerability shows that large classes of matrices are insecure, and conjugation invariance proves that naive \"scrambling\" cannot mask structural weaknesses. These results bridge tropical algebra to order theory (via the lattice meet interpretation of tropical addition), graph theory (via shortest-path duality), and combinatorics (via orbit pigeonhole).\n\nThe most promising cross-domain connection is the **tropical algebra \u2194 order theory bridge**. The stagnation theorem is essentially a descending chain condition in a product lattice, and the Kleene star is a lattice fixpoint computation. This suggests that Knaster-Tarski-style fixpoint theorems and well-quasi-ordering theory could provide sharp bounds on stagnation indices \u2014 connecting tropical cryptography to a completely different area of mathematics (well-quasi-order theory, Higman's lemma, Kruskal's tree theorem).\n\nThe direction with highest breakthrough potential is **Direction 1 (Tropical Jordan Normal Form)**, because resolving it would either collapse all TDLP to the diagonal case (ruling out tropical crypto entirely) or identify a precise class of \"genuinely hard\" matrices (enabling secure parameter selection). This is analogous to how the theory of elliptic curves over finite fields enabled ECC parameter selection.\n\n---\n\n### Direction 1: Tropical Jordan Normal Form and TDLP Reducibility\n\n**Conjecture**: Every n\u00d7n tropical matrix A over \u2124 \u222a {\u22a4} is conjugate (via a tropical invertible matrix P) to a matrix in tropical Jordan normal form \u2014 a block-diagonal matrix where each block has the form of a tropical \"elementary Jordan block\" determined by the critical graph of A. Furthermore, the TDLP for A reduces to the TDLP for its tropical Jordan form in polynomial time.\n\n**Test**: Formalize the tropical eigenvalue theory for 3\u00d73 matrices. Compute the critical graph (the subgraph of edges achieving the optimal assignment weight). Verify that 3\u00d73 tropical TDLP can be solved whenever the critical graph has a specific structure (e.g., all strongly connected components have size 1).\n\n**Impact**: If true, this would show that TDLP security depends entirely on the structure of the critical graph. Matrices with simple critical graphs are insecure; matrices with complex critical graphs may be secure. This would provide a precise criterion for secure parameter selection \u2014 or prove that tropical crypto is fundamentally insecure.\n\n**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (trop_diagonal_power_entry, trop_conjugation_power_commute), `Cryptography/TropicalPostQuantumPrimitives.lean` (tropicalDet_attained, tropicalSpectralRadius_eq)\n\n**Proof Strategy**: \n1. Define tropical eigenvalues as \u03bb where A \u2297 v = \u03bb \u2297 v for some v \u2260 \u22a4.\n2. Prove that the tropical spectral radius equals the minimum average cycle weight.\n3. Define the critical graph as the union of cycles achieving this minimum.\n4. Construct the tropical Jordan form from the critical graph structure.\n5. Show that conjugation by the basis change matrix reduces TDLP to the Jordan form case.\n\n**Domain Bridges**: Tropical algebra \u2194 graph theory (critical graphs), optimization \u2194 cryptography (assignment problem determines eigenvalues)\n\n**Lineage**: Extends trop_diagonal_power_entry and trop_conjugation_power_commute from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Stagnation Index Sharp Bounds via Well-Quasi-Ordering\n\n**Conjecture**: For an n\u00d7n tropical matrix A with entries in {0, 1, ..., B} \u222a {\u22a4}, the stagnation index k\u2080 (the smallest k with A^k = A^(k+1)) satisfies k\u2080 \u2264 n \u00b7 B. Moreover, this bound is tight: there exist matrices achieving k\u2080 = n \u00b7 B.\n\n**Test**: Compute stagnation indices for all 3\u00d73 matrices over {0, 1, 2, \u22a4} (3\u2079 = 19683 matrices, feasible). Plot the distribution of k\u2080 values and check whether the maximum equals 3 \u00b7 2 = 6. Formalize the upper bound k\u2080 \u2264 nB using the observation that each power decreases some entry by at least 1 until stagnation.\n\n**Impact**: A tight bound on k\u2080 would give an exact security parameter: for 128-bit security, we need n \u00b7 B \u2265 2^128, so e.g. n = 16, B = 2^124 or n = 128, B = 2^121. If the bound is not tight, the actual security may be much lower than expected.\n\n**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (trop_power_stagnation, tropKleenePrefix_antitone), `Tropical/Matrix/Algebra.lean`\n\n**Proof Strategy**: \n1. Show that each entry A^k_{ij} is non-increasing in k (monotone convergence from Kleene prefix theory).\n2. Show that if A^k \u2260 A^(k+1), at least one entry strictly decreases.\n3. Each entry can decrease at most B times before reaching 0 or \u22a4.\n4. There are n\u00b2 entries, so k\u2080 \u2264 n\u00b2 \u00b7 B \u2014 or with more care, k\u2080 \u2264 n \u00b7 B by considering only entries along shortest paths.\n5. Construct tight examples using long chain graphs: i \u2192 i+1 with weight B.\n\n**Domain Bridges**: Tropical algebra \u2194 combinatorics (descending chains in products of bounded linear orders), optimization \u2194 security parameter selection\n\n**Lineage**: Directly extends trop_power_stagnation and tropKleenePrefix_antitone from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Fourier Analysis and Quantum Attack Resistance\n\n**Conjecture**: The tropical discrete logarithm problem is resistant to quantum Fourier transform-based attacks because the lack of additive inverses in the tropical semiring prevents the construction of the standard quantum period-finding circuit. Specifically, no quantum algorithm for TDLP can achieve better than Grover's O(\u221ak\u2080) speedup.\n\n**Test**: Formalize the tropical analog of the quantum Fourier transform. Show that the standard Shor's algorithm step \u2014 computing f(x) = A^x and finding the period \u2014 cannot be \"un-min'd\" because min is not invertible. Prove that any quantum algorithm for TDLP requires \u03a9(k\u2080^(1/3)) queries (or whatever the true lower bound is).\n\n**Impact**: If tropical TDLP has quantum resistance beyond Grover, this would establish tropical matrices as a genuinely new post-quantum hardness assumption, distinct from lattices, codes, and multivariate polynomials. This would be a major result in post-quantum cryptography.\n\n**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (trop_no_additive_inverse, tropical_dh_master_security), `Cryptography/TropicalPostQuantumPrimitives.lean` (tropical_min_abs_identity \u2014 \"piecewise-linear defeats QFT\")\n\n**Proof Strategy**: \n1. Formalize the abstract quantum query model for TDLP: oracle access to f(x) = A^x.\n2. Show that the tropical structure prevents efficient quantum period-finding because:\n   a. min is idempotent (min(a,a) = a), breaking the periodicity structure.\n   b. No additive inverse prevents constructing interference patterns.\n3. Reduce to a lower bound on quantum search in unstructured spaces (BBBV theorem).\n\n**Domain Bridges**: Tropical algebra \u2194 quantum computing (query complexity), cryptography \u2194 computational complexity (oracle separations)\n\n**Lineage**: Extends trop_no_additive_inverse and the piecewise-linear/QFT connection from the catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Tropical Convex Geometry and Encryption Geometry\n\n**Conjecture**: The image of a tropically convex set under tropical matrix multiplication is tropically convex. Furthermore, the \"tropical convex hull\" of the orbit {G^k \u00b7 v : k = 0, 1, ..., N} forms a tropical polytope whose combinatorial type encodes the security of the TDLP instance.\n\n**Test**: Define tropical convexity formally (S is tropically convex if for all x, y \u2208 S and a, b \u2208 \u2124 with min(a,b) = 0: min(a + x_i, b + y_i) \u2208 S). Prove that tropical matrix multiplication preserves tropical convexity. Compute the tropical polytope for small examples (2\u00d72 matrices, orbit length 10) and characterize its vertices.\n\n**Impact**: This would create a geometric theory of TDLP security, where \"hard\" instances correspond to tropically convex polytopes with many vertices (high combinatorial complexity), while \"easy\" instances correspond to simple polytopes (e.g., tropical segments for diagonal matrices).\n\n**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (tropLinComb, tropLinComb_le_left), `Bridges/TropicalScatteringOneWayDuality.lean`, `Tropical/Matrix/Defs.lean`\n\n**Proof Strategy**: \n1. Formalize tropical convexity for subsets of \u2124\u207f.\n2. Prove that tropical linear maps (v \u21a6 A \u2297 v) preserve tropical convexity using distributivity: A \u2297 min(a+x, b+y) = min(a + A\u2297x, b + A\u2297y).\n3. Define the tropical polytope of the power orbit.\n4. Show that vertex count of the orbit polytope is a lower bound on TDLP hardness.\n\n**Domain Bridges**: Tropical algebra \u2194 convex geometry (tropical polytopes), optimization \u2194 cryptographic hardness (polytope complexity)\n\n**Lineage**: Extends tropLinComb and tropical_plus_distributes_over_min_Z from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Matrix Factorization Hardness and One-Way Functions\n\n**Conjecture**: The tropical matrix factorization problem \u2014 given C = A \u2297 B, recover A and B \u2014 is NP-hard even for n\u00d7n matrices with entries in {0, 1}. This provides a stronger one-way function candidate than tropical powering, because factorization does not have the eigenvalue attack vulnerability.\n\n**Test**: Reduce a known NP-hard problem (e.g., minimum weight triangulation, or the assignment problem variant) to tropical matrix factorization. Alternatively, show that {0,1}-tropical matrix factorization encodes Boolean satisfiability.\n\n**Impact**: If tropical matrix factorization is NP-hard, it provides a fundamentally different one-way function for post-quantum cryptography \u2014 one not based on discrete logarithms or lattice problems. Combined with the existing catalog result `TropicalNPHardness` (which already suggests NP-hardness for related problems), this would establish a complete complexity-theoretic foundation for tropical crypto.\n\n**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (all results), `Cryptography/TropicalPostQuantum.lean` (TropicalNPHardness)\n\n**Proof Strategy**: \n1. Encode 3-SAT clauses as tropical matrix entries.\n2. Show that C = A \u2297 B encodes clause satisfaction when A and B have {0,1} entries.\n3. The min in tropical multiplication corresponds to existential quantification; the + corresponds to clause weight accumulation.\n4. Formalize the reduction and prove its correctness.\n\n**Domain Bridges**: Tropical algebra \u2194 computational complexity (NP-hardness), cryptography \u2194 combinatorial optimization (assignment problems)\n\n**Lineage**: Builds on TropicalNPHardness from the catalog and extends tropical_dh_master_security from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0959",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "93c28aa5",
    "status": "available",
    "timestamp": "2026-06-07T15:59:13.389812+00:00",
    "title": "Three structural results about tropical cryptogr"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Anti-Gravity Mathematics\n\n## Synthesis\n\nThis cycle established the **Proof Leverage Lattice** (PLL) as a novel mathematical structure for analyzing the relationship between theorem dependency structure and proof complexity. The key discovery is the **Anti-Gravity Density Bound**: in any nonempty PLL where the total gravitational weight exceeds \u03c4 times the total proof length, the set of \u03c4-anti-gravity vertices is guaranteed to be nonempty. This transforms an informal intuition (\"some theorems matter more than others\") into a rigorous mathematical guarantee.\n\nThe most promising cross-domain connection from this cycle is the bridge between the PLL framework and the Catalog's **Spectral Renormalization** work (`Computation/SpectralRenormalization.lean`). Spectral renormalization provides *lower bounds* on proof length from vertex expansion, while our anti-gravity framework provides *upper bounds* on the count of high-weight vertices from total weight. Together, they constrain the joint distribution of weight and proof length from both sides \u2014 a pairing that could yield tight characterizations of proof complexity spectra.\n\nThe direction with the highest breakthrough potential is **Direction 1** (Spectral Convergence), because it connects our discrete combinatorial framework to the rich continuous theory of random matrix spectra and Wigner's semicircle law. If the gravitational spectrum of large random DAGs converges to a universal distribution, it would provide a foundational law for the architecture of mathematical knowledge \u2014 analogous to the central limit theorem for sums but for *dependency structures*.\n\n---\n\n### Direction 1: Spectral Convergence of the Anti-Gravity Distribution\n\n**Conjecture**: In the Erd\u0151s-R\u00e9nyi directed graph model DAG(n, p) with p = c/n for constant c > 0, augmented with i.i.d. proof lengths drawn from a Pareto(\u03b1) distribution, the empirical distribution of anti-gravity indices weight(v)/proofLength(v), suitably normalized, converges weakly to a deterministic limit distribution F_c,\u03b1 as n \u2192 \u221e.\n\n**Test**: Generate 1000 instances of DAG(n, c/n) for n = 100, 500, 2000, 10000 with c = 2 and \u03b1 = 1.5. Compute the empirical CDF of normalized anti-gravity indices. Check whether the Kolmogorov-Smirnov distance between the empirical CDFs for successive n values decreases, indicating convergence.\n\n**Impact**: If true, this would establish a \"central limit theorem\" for theorem dependency structures \u2014 a universal law governing the distribution of mathematical leverage. If false, it would suggest that the anti-gravity distribution depends on fine structural details (e.g., clustering, community structure) beyond simple density parameters, which would be equally informative.\n\n**Catalog References**: `Computation/SpectralRenormalization.lean` (for the connection between graph expansion and proof complexity), `Novelty/AntiGravity/Defs.lean` (for the PLL definition and gravitational spectrum)\n\n**Proof Strategy**: First, establish moment convergence using the method of moments. Compute the k-th moment of the anti-gravity index distribution E[\u2211 (weight(v)/proofLength(v))^k / n] and show it converges. Key lemma: the weight of a vertex in DAG(n, c/n) follows approximately a Galton-Watson branching process with Poisson(c) offspring, so weight(v) \u2248 |T_v| where T_v is a Poisson(c) Galton-Watson tree. Combine with independence of proof lengths. For \u03b1 > 2, the ratio has finite variance and a CLT applies. For \u03b1 \u2264 2, heavy-tailed theory (stable distributions) is needed.\n\n**Domain Bridges**: Combinatorics (random graph theory) \u2194 Proof Complexity (PLL) \u2194 Probability (stable distributions)\n\n**Lineage**: Builds on the PLL framework from this cycle and the spectral gap results in `proof_length_lower_bound`.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Anti-Gravity Phase Transitions in Growing Knowledge Systems\n\n**Conjecture**: Define a *dynamic PLL* where theorems arrive one at a time, each depending on a random subset of existing theorems with probability proportional to their current weight (preferential attachment). There exists a critical proof-length parameter \u03b1* such that:\n- For average proof length < \u03b1*, the fraction of 2-anti-gravity vertices converges to a positive constant > 0.1.\n- For average proof length > \u03b1*, the fraction of 2-anti-gravity vertices converges to 0.\n\n**Test**: Simulate the dynamic PLL for n = 1000 steps with average proof lengths ranging from 1 to 20. Plot the fraction of 2-anti-gravity vertices as a function of average proof length. Identify the critical point where the fraction drops below 5%.\n\n**Impact**: If true, this predicts a phase transition in the structure of mathematical knowledge: below a critical complexity threshold, keystones are abundant; above it, they vanish. This would have implications for how mathematical fields evolve \u2014 mature fields with longer average proofs may have fewer keystones than young fields.\n\n**Catalog References**: `Novelty/AntiGravity/Theorems.lean` (for `antiGravity_nonempty_of_totalWeight`), `Bridges/LawvereCodingTheorem.lean` (for the connection between proof structure and computability)\n\n**Proof Strategy**: Model the dynamic PLL as a P\u00f3lya urn process. At each step, a new vertex arrives with proof length drawn from Pareto(\u03b1). It connects to existing vertices with probability proportional to their weight. The total weight grows as \u2211 weight, which follows a stochastic recursion. Use martingale convergence theorems to establish the a.s. limit of the anti-gravity fraction. The critical point \u03b1* should satisfy a fixed-point equation involving the generating function of the weight distribution.\n\n**Domain Bridges**: Probability (P\u00f3lya urns, branching processes) \u2194 Network Science (preferential attachment) \u2194 Proof Complexity (PLL)\n\n**Lineage**: Extends the static PLL analysis from this cycle to dynamic settings.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Categorical Anti-Gravity and Functorial Weight\n\n**Conjecture**: The gravitational weight function extends to a functor W : DAG \u2192 (\u2115, \u2264) from the category of finite DAGs (with graph homomorphisms) to the poset of natural numbers. Specifically, if f : G \u2192 H is a graph homomorphism that is injective on vertices, then weight_G(v) \u2264 weight_H(f(v)) for all vertices v.\n\n**Test**: Prove or disprove this in Lean 4. Construct a counterexample by finding a graph homomorphism f : G \u2192 H and vertex v where weight_G(v) > weight_H(f(v)). If no counterexample is found for graphs up to 8 vertices, attempt a proof.\n\n**Impact**: If true, this provides a functorial perspective on anti-gravity, connecting the PLL framework to category theory and enabling composition of weight analyses across subgraphs. If false, it reveals that graph homomorphisms can \"destroy\" reachability, which would constrain how anti-gravity analyses compose.\n\n**Catalog References**: `Novelty/AntiGravity/Defs.lean`, `Bridges/LawvereCodingTheorem.lean` (for categorical proof structure)\n\n**Proof Strategy**: For injective homomorphisms, the key lemma is that f maps reachable sets to reachable sets: if w is reachable from v in G, then f(w) is reachable from f(v) in H. This follows from homomorphism preserving edges: G.adj(u,w) \u2192 H.adj(f(u), f(w)). Injectivity ensures the image of the reachable set has the same cardinality.\n\n**Domain Bridges**: Category Theory (functors) \u2194 Graph Theory (homomorphisms) \u2194 Proof Complexity (PLL)\n\n**Lineage**: Extends the PLL framework from this cycle with categorical structure.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Persistent Homology of the Anti-Gravity Filtration\n\n**Conjecture**: The filtration AG(P, 0) \u2287 AG(P, 1) \u2287 AG(P, 2) \u2287 ..., viewed as a filtered simplicial complex (via the clique complex of the subgraph induced by each AG set), has non-trivial persistent homology in dimensions 0 and 1. Specifically, the number of persistent H\u2081 generators (loops that survive across threshold levels) is at least log(|V|) for \"generic\" PLLs.\n\n**Test**: Compute the persistent homology of the anti-gravity filtration for 100 random DAGs with n = 200. Count the number of persistent H\u2081 generators and check whether the average exceeds log(200) \u2248 5.3.\n\n**Impact**: If true, this connects anti-gravity mathematics to topological data analysis and reveals higher-order structural properties of theorem dependency networks. The persistent features would correspond to \"cycles of mutual dependence\" that exist across a range of anti-gravity thresholds \u2014 a topological signature of robust mathematical infrastructure.\n\n**Catalog References**: `Bridges/ImpossibleObjectsTopology.lean` (for `fundamental_theorem_cycles`), `Novelty/AntiGravity/Theorems.lean` (for `antiGravitySet_antitone`)\n\n**Proof Strategy**: Construct the clique complex of the induced subgraph on AG(P, \u03c4) for each \u03c4. Use the nerve theorem to relate the homology of the filtration to the combinatorial structure of the DAG. The key technical step is bounding the Betti numbers using the Euler characteristic and the Morse inequalities. For H\u2080 (connected components), the number of components of AG(P, \u03c4) increases as \u03c4 increases. For H\u2081, cycles can appear when the anti-gravity set has non-tree structure.\n\n**Domain Bridges**: Algebraic Topology (persistent homology) \u2194 Graph Theory (clique complexes) \u2194 Proof Complexity (PLL filtrations)\n\n**Lineage**: Builds on the spectral monotonicity theorem (`antiGravitySet_antitone`) from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Anti-Gravity in Tropical Proof Systems\n\n**Conjecture**: In a tropical semiring proof system (where addition is min and multiplication is +), the anti-gravity index of a vertex v in the tropical derivation graph equals the negative of the tropical eigenvalue associated with v's position in the adjacency matrix's tropical spectral decomposition.\n\n**Test**: Construct a 10-vertex tropical derivation graph. Compute both the anti-gravity indices (via reachability) and the tropical eigenvalues (via the max-plus spectral theory). Check whether they are negatives of each other.\n\n**Impact**: If true, this would establish a deep algebraic connection between anti-gravity (a combinatorial property) and tropical spectral theory (an algebraic property), unifying two independent approaches to proof complexity analysis. It would allow tropical matrix methods to compute anti-gravity indices efficiently.\n\n**Catalog References**: `FINAL/Physics/TropicalProofComplexity.lean` (for `tropical_proof_length_conjecture_special_case`), `FINAL/Tropical/TropicalFactoring.lean` (for `tropical_fundamental_theorem_of_arithmetic`), `Novelty/AntiGravity/Defs.lean`\n\n**Proof Strategy**: Express the adjacency matrix A of the derivation graph in the tropical semiring (\u211d \u222a {\u221e}, min, +). The tropical eigenvalues are the critical values of the tropical characteristic polynomial det_trop(A - \u03bbI). The weight of v equals the number of vertices w for which the shortest path from v to w has finite tropical length. The connection to eigenvalues comes via the fact that the k-th power A^k in the tropical semiring gives the shortest k-step path lengths, and the weight is the count of finite entries in A^|V|.\n\n**Domain Bridges**: Tropical Geometry (spectral theory) \u2194 Graph Theory (shortest paths) \u2194 Proof Complexity (PLL)\n\n**Lineage**: Extends the PLL framework from this cycle and connects to the established tropical proof complexity results in the Catalog.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0974",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "199919f1",
    "status": "available",
    "timestamp": "2026-06-07T18:54:05.120573+00:00",
    "title": "**Proof Leverage Lattice** (PLL) as a novel mathemati"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Spectral Gap Phase Transitions in CSPs\n\n## Synthesis\n\nThis research cycle established a formally verified framework connecting spectral gaps, conductance, mixing times, and phase transitions in constraint satisfaction problems, with Sudoku as the concrete case study. The 25 proven theorems span four mathematical domains: Markov chain theory (mixing time bounds, variance decay), spectral graph theory (Cheeger's inequality, Dirichlet forms), information theory (entropy-gap bridge), and combinatorics (phase classification, solution monotonicity).\n\nThe most promising cross-domain connection discovered is the **Cheeger-entropy bridge**: Cheeger's inequality connects the geometric property of conductance to the algebraic property of spectral gaps, while the entropy bridge connects the information-theoretic property of solution count to spectral behavior. Together, they form a chain: **constraint density \u2192 solution count \u2192 entropy \u2192 conductance \u2192 spectral gap \u2192 mixing time**. Each link in this chain has been formalized, but the full end-to-end theorem (constraint density directly controls mixing time) remains open and would constitute a major result.\n\nThe highest breakthrough potential lies in Direction 1 (Shidoku verification), which would provide the first computational confirmation of the spectral gap phase transition conjecture. Direction 2 (log-Sobolev strengthening) would upgrade our mixing time bounds from O(1/\u03b3 \u00b7 log n) to O(1/\u03b1 \u00b7 log log n), a substantial improvement for large state spaces.\n\n---\n\n### Direction 1: Computational Verification of the Phase Transition in Shidoku\n\n**Conjecture**: The spectral gap of the swap Markov chain on 4\u00d74 Shidoku solutions undergoes a phase transition at density 4/16 = 1/4. Specifically, for Shidoku puzzles with k clues (k = 0, 1, ..., 16), the spectral gap \u03b3(k) satisfies:\n- \u03b3(k) > 0.5 for k \u2264 2 (fast phase)\n- \u03b3(k) < 0.05 for k = 4 (critical point)\n- \u03b3(k) = 0 for k \u2265 8 (frozen phase)\n\n**Test**: Enumerate all valid 4\u00d74 Shidoku puzzles with k clues for k = 0, 1, ..., 12. For each, build the transition matrix of the swap Markov chain on valid completions and compute its spectral gap exactly (the state space is at most ~288 states for k=0). Plot \u03b3(k) vs k and verify the phase transition shape.\n\n**Impact**: If confirmed, this would be the first rigorous computational demonstration of a spectral gap phase transition in a puzzle CSP. If the transition is not at k=4, the failure would reveal that the analogy between minimum-clue thresholds and spectral critical densities is more subtle than conjectured.\n\n**Catalog References**: `MachineLearning/SudokuSpectralGap/Theorems.lean`, `Novelty/SudokuSpectralGap/Theorems.lean`\n\n**Proof Strategy**: Use exact computation on the 4\u00d74 grid. The key steps are:\n1. Enumerate all 288 valid Shidoku solutions\n2. Build the swap graph (solutions connected by single digit swaps)\n3. For each subset of k cells as clues, compute the induced subgraph\n4. Compute eigenvalues of the transition matrix using NumPy/SageMath\n5. Formalize the computed spectral gaps as Lean `native_decide` proofs\n\n**Domain Bridges**: Combinatorics (enumeration) \u2194 Linear algebra (eigenvalues) \u2194 Statistical physics (phase transition)\n\n**Lineage**: Extends `phase_exhaustive`, `critical_is_critical`, and `mixing_time_unbounded` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Log-Sobolev Inequality for CSP Markov Chains\n\n**Conjecture**: The log-Sobolev constant \u03b1 of the swap Markov chain on Sudoku solutions satisfies \u03b1 \u2265 \u03b3 / (2 log n), where \u03b3 is the spectral gap and n is the number of states. This would improve the mixing time bound from O((1/\u03b3) log(n/\u03b5)) to O((1/\u03b1) log log(1/\u03b5)).\n\n**Test**: Prove the log-Sobolev inequality for the complete graph Markov chain (uniform random transposition), then extend to the constraint-restricted chain using comparison methods.\n\n**Impact**: The log-Sobolev inequality gives hypercontractivity and tight concentration inequalities for functions on the solution space. This would bridge CSP spectral theory to functional analysis and harmonic analysis on finite groups.\n\n**Catalog References**: `Novelty/SudokuSpectralGap/Defs.lean` (LogSobolevData structure), `Computation/QuantumWalkCayley.lean` (mixing_time_spectral_bound)\n\n**Proof Strategy**:\n1. Prove the log-Sobolev inequality for the complete graph (known: \u03b1 = 1/n for transpositions)\n2. Use the comparison theorem: if P\u2081 \u2264 c\u00b7P\u2082 (entrywise), then \u03b1\u2081 \u2265 \u03b1\u2082/c\n3. Show the CSP Markov chain is dominated by the complete transposition chain\n4. Derive the improved mixing time bound\n\n**Domain Bridges**: Functional analysis (log-Sobolev inequalities) \u2194 Probability (hypercontractivity) \u2194 CSP theory (phase transitions)\n\n**Lineage**: Extends `mixing_time_bound_pos` and `mixing_time_mono_gap` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Spectral Gap of Latin Square Completion\n\n**Conjecture**: The spectral gap of the swap Markov chain on n\u00d7n Latin square completions (with k fixed entries) undergoes a phase transition at k/n\u00b2 \u2248 1/e \u2248 0.368, which is asymptotically different from the Sudoku critical density 17/81 \u2248 0.210.\n\n**Test**: Compute spectral gaps for 3\u00d73, 4\u00d74, and 5\u00d75 Latin squares with varying numbers of fixed entries. Compare the empirical critical density to the 1/e prediction from random constraint satisfaction theory.\n\n**Impact**: This would establish whether the Sudoku critical density 17/81 is a consequence of the block structure (3\u00d73 boxes) or is inherent to Latin square constraints. The comparison would illuminate how auxiliary constraints (boxes) shift the phase transition.\n\n**Catalog References**: `Novelty/SudokuSpectralGap/Theorems.lean`, `Bridges/WreathPressure.lean` (phase_transition_transfer_of_subcritical_gap)\n\n**Proof Strategy**:\n1. Define the Latin square completion problem as a CSP\n2. Build the transition graph for Latin squares (no box constraints)\n3. Compute spectral gaps for small n\n4. Use Cheeger's inequality to bound the spectral gap for general n\n5. Compare with Sudoku (Latin square + box constraints)\n\n**Domain Bridges**: Combinatorics (Latin squares) \u2194 Spectral theory \u2194 Random CSP theory (clause-variable ratio thresholds)\n\n**Lineage**: Extends `phase_exhaustive` and `absorbing_set_zero_flow` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Quantum Walk Speedup of CSP Mixing\n\n**Conjecture**: A quantum walk on the CSP solution graph achieves a quadratic speedup over the classical Markov chain: quantum mixing time t_Q ~ 1/\u221a\u03b3 vs classical t_C ~ 1/\u03b3.\n\n**Test**: Compute the quantum walk spectral gap for the Shidoku swap graph and verify the quadratic relationship with the classical spectral gap.\n\n**Impact**: If confirmed, this would provide a concrete quantum advantage for CSP solving near the phase transition, where classical mixing is slowest. This connects CSP theory to quantum computing in a novel way.\n\n**Catalog References**: `Computation/QuantumWalkCayley.lean` (mixing_time_spectral_bound), `EML/EMLQuantumHybrid.lean` (grover_fewer_with_more_solutions)\n\n**Proof Strategy**:\n1. Define the quantum walk operator U = e^{iHt} where H = I - P (graph Laplacian)\n2. Show that the quantum spectral gap \u03b3_Q = \u221a\u03b3 (follows from functional calculus)\n3. Prove the mixing time bound t_Q = O((1/\u221a\u03b3) \u00b7 log(n/\u03b5))\n4. Verify computationally on Shidoku\n\n**Domain Bridges**: Quantum computing \u2194 Spectral theory \u2194 CSP complexity\n\n**Lineage**: Extends `mixing_time_unbounded` from this cycle and `grover_fewer_with_more_solutions` from the catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Spectral Gap and Min-Plus Mixing\n\n**Conjecture**: The tropical (min-plus) spectral gap of the CSP transition matrix provides a tighter lower bound on the classical spectral gap than Cheeger's inequality for sparse solution graphs.\n\n**Test**: Compute the tropical eigenvalues of the Shidoku transition matrix and compare the tropical spectral gap bound with the Cheeger bound.\n\n**Impact**: Tropical geometry provides a combinatorial framework for spectral analysis that avoids the worst-case nature of Cheeger's inequality. This would create a new bridge between tropical mathematics and Markov chain theory.\n\n**Catalog References**: `Tropical/MixingTheory.lean` (two_state_spectral_gap_bound), `Tropical/SymbolicDynamics/Core.lean` (tropical_spectral_gap_implies_mixing_and_extraction)\n\n**Proof Strategy**:\n1. Define tropical eigenvalues of a matrix via the max-plus algebra\n2. Prove that the tropical spectral radius provides a bound on the classical spectral gap\n3. Show that for structured matrices (like CSP transition matrices), the tropical bound is tighter\n4. Apply to the Shidoku transition matrix\n\n**Domain Bridges**: Tropical geometry \u2194 Spectral theory \u2194 CSP theory\n\n**Lineage**: Extends `two_state_gap_formula` from this cycle and `tropical_spectral_gap_implies_mixing_and_extraction` from the catalog.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_1001",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "9f9fbc53",
    "status": "available",
    "timestamp": "2026-06-08T00:57:42.170990+00:00",
    "title": "Formally verified framework connecting spectra"
  },
  {
    "consumed_by_exp_id": "",
    "description": "1. Oracle hierarchies for self-modification: Does the arithmetic hierarchy induced by levels of self-modification coincide with the standard one, or does the adversarial dynamic create new intermediate degrees?\n\n2. Probabilistic self-modification: Extend the framework to randomized self-modification, connecting to algorithmic randomness and Martin-L\u00f6f tests. Real malware and learning systems use stochastic code rewriting.\n\n3. Bounded self-modification and complexity theory: When self-modification is resource-bounded (e.g., modified code must fit in the same memory), what is the complexity of the halting problem? This connects to space-bounded computation.\n\n4. Game-theoretic alignment models: The monitor-agent interaction is naturally a game. Formalizing equilibrium concepts for self-modifying agents could yield positive results \u2014 conditions under which alignment IS achievable despite the general impossibility.\n\n5. Connections to reflective oracles: Christiano's reflective oracles provide a framework where agents can predict systems that include themselves. Understanding the relationship between our impossibility results and reflective oracle existence theorems could clarify the boundaries of self-prediction.\n\n6. Tropical and geometric perspectives: The simulation theorem encodes a self-modifying machine as a dynamical system on a product space. Tropical geometry provides tools for analyzing discrete dynamics \u2014 the connection merits further exploration.\n\n7. Quantitative refinements: For specific classes of self-modifying systems (e.g., linear self-modification, bounded-depth modification), tighter bounds on cycle length and fixed-point delay may be achievable.",
    "domains": [
      "Computation",
      "Geometry"
    ],
    "id": "fd_1024",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "4c2eabf0",
    "status": "available",
    "timestamp": "2026-06-08T20:28:20.912197+00:00",
    "title": "1. Oracle hierarchies for self-modification: Does the arithmetic hierarchy induc"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Holographic Dictionary \u2014 Valuations, Anomalies, and Entanglement Structure\n\n## What We Proved\n\nThis cycle formalized the mathematical dictionary between holographic gravity and quantum error correction, centered on four main theorems:\n\n1. **Modular Decomposition Theorem** (`modular_sum_singletons`): Every modular set function with f(\u2205)=0 decomposes as f(X) = \u2211_{a\u2208X} f({a}). This classifies valuations on the Boolean lattice.\n\n2. **Flatness\u2013Atomicity Bridge** (`flat_profile_atomic`): Holographic entropy profiles with zero total defect decompose atomically \u2014 their entropy is determined purely by single-site values. Zero gravity \u27f9 no entanglement beyond local data.\n\n3. **Singleton Gap Nonnegativity** (`singleton_gap_nonneg`): The coding-theoretic \"anomaly\" \u0394(X) = N(X) - 2D(X) + 2 - S(X) \u2265 0 always, with equality characterizing extremal (MDS-like) codes.\n\n4. **MMI Four-Party & Five-Party Inequalities** (`mmi_four_party_ineq`, `mmi_five_party_ineq`): Monogamy of mutual information yields cyclic bounds on multi-party correlations beyond what strong subadditivity provides.\n\nSupporting results include: modular functions form a vector space (closed under +, scalar \u00b7, with 0), uniqueness of modular functions from singleton data, counterexamples showing submodularity alone is insufficient for atomic decomposition, entanglement wedge order structure (monotonicity and downward closure).\n\n---\n\n## Direction 1: Holographic Entropy Cone via Graph Cuts\n\nThe four-party inequality we proved has explicit correction terms (+S(A)+S(C)). The key insight is that for *disjoint* boundary regions with the RT formula (entropy = minimal cut), these correction terms should vanish, yielding a tight cyclic inequality I(A:C) + I(B:D) \u2264 I(A:B) + I(B:C) + I(C:D) + I(D:A). Why now? We have the MMI infrastructure and the disjoint-region simplification (`normDefect_disjoint` equating defect with mutual information). The next step is to formalize RT as a minimum-cut computation on a graph and derive the tight inequality from cut structure.\n\n**Testable conjecture**: For 4 pairwise-disjoint regions in a monogamous profile, the correction terms in `mmi_four_party_ineq` can be eliminated entirely. Formalize this as a strengthening conditional on disjointness.\n\n---\n\n## Direction 2: Tropical Limits of Submodular Profiles\n\nThe modular decomposition theorem shows flat profiles are \"tropical points\" \u2014 they live on the boundary of the submodularity cone where all inequalities become equalities. The key insight is that every modular profile arises as a limit of strictly submodular profiles under rescaling (tropical degeneration). Why now? The `modular_sum_singletons` theorem gives us the exact structure of modular profiles, and Mathlib's convex cone machinery can formalize the cone structure.\n\n**Testable conjecture**: The modular profiles on `Finset (Fin n)` form a convex cone of dimension n, and every ray in this cone is the tropical limit (in the sense of lim_{t\u2192\u221e} f_t/t) of a 1-parameter family of strictly submodular profiles. Prove this for n = 3.\n\n---\n\n## Direction 3: Singleton Gap as Approximate Error Correction Measure\n\nWe proved \u0394(X) \u2265 0 and its monotonicity under code refinement. The key insight is that \u0394 should satisfy a *superadditivity* property \u0394(X\u222aY) \u2265 \u0394(X) + \u0394(Y) for disjoint X, Y when N is additive and D is subadditive \u2014 this would make \u0394 a \"measure of non-extremality\" that grows under composition. Why now? The gap functional is now formalized with all needed axioms, and the additivity/subadditivity conditions on N, D are natural extensions of the existing `HoloStabilizerProfile`.\n\n**Testable conjecture**: Define a `DisjointAdditiveProfile` extending `HoloStabilizerProfile` with N additive on disjoint regions and D subadditive. Prove \u0394(X\u222aY) \u2265 \u0394(X) + \u0394(Y) for disjoint X, Y, or find a counterexample.\n\n---\n\n## Direction 4: M\u00f6bius Inversion and Higher-Order Defects\n\nThe modular decomposition uses only the \"first-order\" defect (pairwise). The key insight is that higher-order defects \u2014 the M\u00f6bius function of the defect poset \u2014 should capture higher-order entanglement structure. For k regions, define \u03b4_k(X\u2081,...,X_k) as the alternating sum of entropies over all subsets of {X\u2081,...,X_k}. The tripartite information I\u2083 is \u03b4\u2083. Why now? The existing `tripartiteInfo` and `normDefect` can be unified into a single k-ary defect functional, and M\u00f6bius inversion on the partition lattice is available in Mathlib.\n\n**Testable conjecture**: For a monogamous profile, the k-th order defect \u03b4_k has sign (-1)^k for all k \u2264 n. This is the \"complete monotonicity\" conjecture for holographic entropy, generalizing MMI (the k=3 case). Test for k=4 on `Fin 4`.\n\n---\n\n## Direction 5: Categorical Wedge Reconstruction\n\nWe proved that reconstructable regions form an order ideal (downward-closed set) under anti-monotone distance. The key insight is that the assignment Y \u21a6 {X : Reconstructable D Y X} defines a *functor* from (Finset \u03b1, \u2286) to (Set (Finset \u03b1), \u2286), and this functor should have an adjoint (the \"minimal enclosing boundary\" map). Why now? The `reconstructable_monotone` theorem gives functoriality, and `reconstructable_downward` gives the order-ideal property. The adjoint would be the bulk-to-boundary map dual to entanglement wedge reconstruction.\n\n**Testable conjecture**: Define the \"reconstruction functor\" R : Finset \u03b1 \u2192 Set (Finset \u03b1) by R(Y) = {X | Reconstructable D Y X}. Prove that R is a monotone map (done: `reconstructable_monotone`). Then define the left adjoint L(S) = \u22c2{Y | S \u2286 R(Y)} and prove it exists and is monotone. Show that L \u2218 R = id on a suitable subcategory.\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_1025",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "5d44a47d",
    "status": "available",
    "timestamp": "2026-06-08T21:09:08.963525+00:00",
    "title": "This cycle formalized the mathematical dictionary between holographic gravity an"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Polymodal Provability Logic and GL Frame Theory\n\n## What We Built\n\nThis cycle formalized **polymodal provability logic (GLP)** and the **categorical structure of GL frames** in Lean 4, extending the existing single-modal GL framework in the catalog. The key contributions are:\n\n1. **GLP Frame Hierarchy** (`GLPFrame`, `glp_loeb_at_level`, `glp_no_cross_cycle`): GLP frames with \u2115-indexed nested accessibility relations, where each level is a valid GL frame and no cycles can span different levels.\n\n2. **P-Morphism Truth Lemma** (`pmorphism_truth_lemma`): Bounded morphisms preserve and reflect forcing under pullback valuation \u2014 the semantic backbone of GL model theory, proved axiom-free.\n\n3. **Products and Coproducts** (`GLFrame.prod`, `GLFrame.sum`, `GLFrame.iProduct`): GL frames are closed under synchronized products, indexed products, and disjoint unions, with the second incompleteness theorem propagating through products.\n\n4. **Order-Theoretic Bridge** (`GLFrame.toWFSPO`, `WFSPO.toGLFrame`): GL frames are exactly well-founded strict partial orders, with round-trip theorems confirming the equivalence.\n\n---\n\n## Direction 1: Solovay Completeness for Finite GL Frames\n\n**Conjecture**: Every formula valid in all *finite* transitive irreflexive frames is provable in GL, and conversely. This completeness theorem would close the loop between our Kripke semantics and the Hilbert-style axiom system for GL.\n\nThe key insight is that GL has the finite model property: any formula not provable in GL can be refuted in a finite GL frame. This means our existing frame-theoretic infrastructure (products, p-morphisms, etc.) is sufficient to study the full logic \u2014 we don't need infinite frames for completeness.\n\nWhy now? We have p-morphisms and the truth lemma, which are the essential tools for filtration arguments. The filtration construction takes an infinite GL frame and a finite formula, and produces a finite frame refuting the same formula. With the truth lemma already proved, the remaining work is: (a) define a Hilbert-style proof system for GL, (b) prove soundness (easy given `loeb_valid`), (c) prove completeness via canonical model + filtration.\n\n---\n\n## Direction 2: GLP and Proof-Theoretic Ordinal Assignment\n\n**Conjecture**: GLP frames admit a well-defined ordinal assignment function `ord : W \u2192 Ordinal` satisfying: if R_n(w,v) then ord(v) < ord(w), and the ordinal of a \"standard world\" under R\u2080 corresponds to the proof-theoretic ordinal of the theory (e.g., \u03b5\u2080 for PA).\n\nThe key insight is that the nesting R\u2080 \u2287 R\u2081 \u2287 \u00b7\u00b7\u00b7 creates a refined ordinal structure: the R_n-depth of a world gives its \"n-th ordinal coordinate.\" Japaridze showed that GLP can compute proof-theoretic ordinals via the worm sequence, and our `glp_nesting_le` theorem provides the algebraic foundation for this.\n\nWhy now? The `GLPFrame.level` extraction and `glp_nesting_le` give us the tools to define depth functions at each level. The next step is to define the ordinal assignment via well-founded recursion on R\u2080 (using `R_wf 0`), prove it's strictly decreasing, and construct a concrete GLP frame on `Ordinal` that models PA's provability hierarchy.\n\n---\n\n## Direction 3: De Jongh\u2013Sambin Fixed-Point Theorem via P-Morphisms\n\n**Conjecture**: For any modal formula \u03c6(p) where p occurs only within the scope of \u25a1, there exists a formula \u03c8 (not containing p) such that the L\u00f6b-formula equivalence \u03c8 \u2194 \u03c6(\u03c8) is valid in all GL frames. Moreover, the fixed point \u03c8 is unique up to frame validity.\n\nThe key insight is that the \"modalized\" condition (p only under \u25a1) ensures the substitution \u03c6(p) \u21a6 \u03c6(\u03c8) is well-behaved with respect to forcing: the box modality absorbs the substitution's complexity. The p-morphism truth lemma (`pmorphism_truth_lemma`) provides the technical machinery to transfer fixed-point constructions between frames.\n\nWhy now? The truth lemma and the explicit formula language (`MFormula`) give us a solid foundation for defining substitution and the \"modalized\" predicate. The proof would use well-founded induction on the modal depth of p's occurrences and L\u00f6b's theorem (`loeb_valid`) at each step.\n\n---\n\n## Direction 4: Tangling Propagation in the Category of GL Frames\n\n**Conjecture**: The category of GL frames with p-morphisms has finite limits and colimits, and the \"tangling\" property (that a sound world cannot prove its own consistency) is preserved by all categorical constructions. In particular, the pullback of two GL frames along p-morphisms is a GL frame, and tangling in the pullback implies tangling in at least one factor.\n\nThe key insight is that p-morphisms already form a category (composition is `PMorphism.comp`, identity is `PMorphism.id`), and the truth lemma ensures that validity \u2014 and hence tangling \u2014 transfers correctly. Pullbacks would give \"synchronized products along a common quotient,\" which is the natural construction for combining proof systems that share a common sub-theory.\n\nWhy now? We have `PMorphism.comp`, `PMorphism.id`, `GLFrame.prod`, `GLFrame.sum`, and `PMorphism.inl`/`PMorphism.inr`. The missing piece is the pullback construction and the universal property proofs. The truth lemma makes the tangling-preservation argument straightforward once the pullback is constructed.\n\n---\n\n## Direction 5: Computational Depth Functions and Decidability\n\n**Conjecture**: For any fixed formula \u03c6 of modal depth d, GL-validity of \u03c6 is decidable by checking validity in all GL frames of size \u2264 2^(2^d). This gives an explicit upper bound on the complexity of GL-satisfiability and connects our semantic framework to algorithmic logic.\n\nThe key insight is that the finite model property + our product construction gives a concrete bound: the filtration of the canonical model through a formula of depth d produces a frame of bounded size. The `GLFrame.iProduct` construction shows that the search space is finite when restricted to finite frames of bounded size.\n\nWhy now? The product and coproduct constructions provide the algebraic tools to build and decompose finite frames systematically. The order-theoretic bridge (`GLFrame.toWFSPO`) connects to Mathlib's extensive library on finite partial orders, which includes enumeration and cardinality results that could automate the decidability bound computation.\n",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_1031",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "549f2939",
    "status": "available",
    "timestamp": "2026-06-08T23:16:50.552188+00:00",
    "title": "This cycle formalized **polymodal provability logic (GLP)** and the **categorica"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Braid Group Invariants and Strand Topology\n\n## 1. The Burau Representation and its Faithfulness Boundary\n\nThe BraidSignature (writhe \u00d7 permutation) we formalized is a coarse invariant \u2014 it captures the abelianization and the symmetric group image but loses the rich non-abelian structure of the braid group. The next natural step is formalizing the *Burau representation*, which maps B_n into GL_{n-1}(\u2124[t, t\u207b\u00b9]) via matrices encoding how each strand crosses over or under its neighbors.\n\nThe key insight is that the Burau representation is known to be *unfaithful* for n \u2265 5 (Bigelow 1999), but the question remains open for n = 4. A Lean formalization could provide a constructive proof of unfaithfulness for n = 5 by exhibiting an explicit kernel element, and potentially settle the n = 4 case computationally.\n\nWhy now? Our formalization already has the generator-and-relation framework for B_n, and Mathlib's polynomial ring and matrix algebra provide the necessary algebraic infrastructure. The Burau matrices are concrete 2\u00d72 or 3\u00d73 matrices over \u2124[t], making verification tractable.\n\n**Testable prediction**: For n = 5, there exists an explicit braid word of length \u2264 20 in the kernel of the Burau representation. Search computationally by evaluating Burau matrices for all words up to length 20 and checking which give the identity matrix.\n\n## 2. Braid Group Orderability and the Dehornoy Order\n\nThe braid group B_n admits a left-invariant total order (the Dehornoy order), which is a remarkable property not shared by most non-abelian groups. This order has deep connections to set theory (arising from the self-distributive algebra of elementary embeddings) and to dynamics (via the action on the real line).\n\nThe key insight is that the Dehornoy order can be characterized purely combinatorially: a braid \u03b2 is Dehornoy-positive if every representative word can be rewritten so that the highest-index generator \u03c3_{n-1} appears only positively. This is a decidable condition, and the proof that it defines a total order uses the key lemma that every non-trivial braid is either \u03c3-positive or \u03c3-negative.\n\nWhy now? Our BraidWord type and BraidRelStep relation provide the right substrate for formalizing word-rewriting arguments. The decidability of the Dehornoy order would give a formally verified comparison function on braids \u2014 a tool with applications in knot theory and cryptography.\n\n**Testable prediction**: For every braid word w of length \u2264 10 in B_3, either w is equivalent to the identity, or exactly one of w and w\u207b\u00b9 can be rewritten using only \u03c3\u2082-positive occurrences of \u03c3\u2082. Verify computationally.\n\n## 3. Lawrence-Krammer Representation and Braid Linearity\n\nWhile the Burau representation fails to be faithful for large n, the Lawrence-Krammer representation (into GL_{n(n-1)/2}(\u2124[q\u00b11, t\u00b11])) is faithful for all n (Bigelow 2001, Krammer 2002). This solved the 70-year-old problem of whether braid groups are linear.\n\nThe key insight is that faithfulness can be reduced to a finite computation for each n: one needs to show that the representation sends non-trivial braids to non-trivial matrices, which for a given n reduces to checking that certain polynomial entries are non-zero. A formalization would provide the first machine-verified proof that B_n embeds into a matrix group.\n\nWhy now? The Lawrence-Krammer representation requires matrices over a bivariate Laurent polynomial ring, which is significantly more complex than the univariate Burau case. However, Mathlib's recent improvements to polynomial ring infrastructure (MvPolynomial, LaurentPolynomial) make this increasingly tractable. Starting with n = 3 (where the representation is 3\u00d73) would be a natural first step.\n\n**Testable prediction**: For B_3, the Lawrence-Krammer representation is injective on all braid words of length \u2264 12. Verify by computing LK matrices for all such words and checking distinctness.\n\n## 4. Garside Normal Form and the Conjugacy Problem\n\nEvery braid has a unique *Garside normal form* \u2014 a canonical representative of its equivalence class that can be computed in polynomial time. This normal form is the key to the algorithmic theory of braid groups, solving the word problem (are two braids equal?) and providing tools for the conjugacy problem (are two braids conjugate?).\n\nThe key insight is that the Garside normal form decomposes a braid into a power of the \"Garside element\" \u0394 (the half-twist) times a product of \"simple\" braids (permutation braids). The uniqueness proof relies on the lattice structure of the positive braid monoid B_n^+, where every pair of elements has a unique gcd and lcm.\n\nWhy now? Our BraidRelStep relation generates braid equivalence, but equivalence is not decidable from the presentation alone \u2014 one needs a normal form. Formalizing Garside's algorithm would give a verified decision procedure for braid equality, bridging our abstract invariant theory with computational algebra. The positive braid monoid B_n^+ can be defined as a sub-monoid of our BraidWord type restricted to positive generators.\n\n**Testable prediction**: In B_4, every positive braid word of length \u2264 10 has a unique Garside normal form of length \u2264 10. Compute normal forms for all such words and verify uniqueness.\n\n## 5. Topological Quantum Computing: Jones Polynomial via Braid Traces\n\nThe deepest connection between braid groups and physics is the Jones polynomial, which arises as a trace of the braid group representation into the Temperley-Lieb algebra. For a braid \u03b2 \u2208 B_n, the Jones polynomial of its closure (the link obtained by connecting the top and bottom endpoints) is V_\u03b2(t) = (\u22121)^{n-1} \u00b7 t^{(n\u22121\u2212w)/2} \u00b7 Tr(\u03c1(\u03b2)), where \u03c1 is the Temperley-Lieb representation and w is the writhe.\n\nThe key insight is that the writhe correction factor \u2014 which we have already formalized \u2014 is essential: without it, the trace is only a Markov trace (invariant under conjugation and stabilization), not a link invariant. Our writhe_braidEquiv theorem provides half of the Jones polynomial's invariance proof; the other half requires formalizing the Temperley-Lieb algebra and its trace.\n\nWhy now? The existing Catalog file BraidingUniversality.lean already contains a formalization of the Temperley-Lieb algebra. Connecting our BraidSignature framework to that existing work would create a cross-domain bridge theorem: the Jones polynomial as a composition of the braid-to-TL representation with the Markov trace, corrected by the writhe. This would be the first formally verified construction of a quantum knot invariant.\n\n**Testable prediction**: For the trefoil braid \u03c3\u2081\u00b3 \u2208 B_3, the Jones polynomial of its closure equals \u2212t\u207b\u2074 + t\u207b\u00b3 + t\u207b\u00b9. Compute via the Temperley-Lieb trace and verify against the known value.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_1032",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "a2ba6239",
    "status": "available",
    "timestamp": "2026-06-08T23:17:28.751887+00:00",
    "title": "The BraidSignature (writhe \u00d7 permutation) we formalized is a coarse invariant \u2014 "
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Time Travel Consistency\n\n## 1. Multi-Loop Causal Networks\n\nThe current formalization handles single closed timelike curves and their pairwise composition. A natural extension is to formalize *networks* of interacting causal loops \u2014 where the output of one CTC feeds into the input of another, possibly with feedback cycles. This corresponds to a directed graph where each edge carries a contraction mapping, and consistency requires a simultaneous fixed point of the entire network.\n\nThe key insight is that a network of n interacting causal loops with individual contraction constants K\u2081, ..., K\u2099 can be modeled as a single contraction on the product space X\u2081 \u00d7 ... \u00d7 X\u2099, but the effective contraction constant depends on the spectral radius of the network's adjacency matrix weighted by the K\u1d62. When this spectral radius is < 1, the whole network has a unique consistent history.\n\nWhy now? The composition theorem (`causal_composition_contracting`) and stability result (`consistent_history_stability`) provide the building blocks. The next step is formalizing the graph structure and proving the spectral radius criterion.\n\n## 2. Non-Contractive Consistency via Topological Fixed-Point Theorems\n\nOur formalization of Edelstein's theorem (`novikov_edelstein`) handles strict contractions on compact spaces. The natural next frontier is proving Novikov-type consistency for merely *continuous* causal evolutions on compact convex subsets of Banach spaces, via the Schauder fixed-point theorem. This would formalize the physical expectation that causal consistency holds even when the evolution operator is not contracting \u2014 it merely needs to map a compact convex \"state space\" into itself.\n\nThe key insight is that Schauder's theorem (the infinite-dimensional Brouwer theorem) guarantees existence but not uniqueness, corresponding to the physical possibility of multiple self-consistent histories. Formalizing this would require building or connecting to Mathlib's theory of compact operators and the Schauder theorem.\n\nWhy now? Edelstein's theorem is proved in the current work, establishing the pattern. Mathlib's coverage of Schauder/Brouwer fixed-point theorems is growing, making this increasingly tractable.\n\n## 3. Quantitative Paradox Resolution: Information-Theoretic Bounds\n\nThe grandfather paradox resolution shows that passing from {0,1} to [0,1] creates a fixed point at 1/2. But *how much* information about the initial discrete state is preserved in the continuous resolution? We conjecture that for an affine causal map x \u21a6 a + bx with |b| < 1, the entropy of the fixed-point distribution (when the initial state has a prior distribution) decreases by exactly log(1-|b|) bits.\n\nThe key insight is that the contraction constant K directly controls the information loss: the unique fixed point a/(1-b) is independent of the initial state, so all initial information is lost (entropy \u2192 0). But for *nearly* non-contracting maps (K close to 1), the convergence to the fixed point is slow, and intermediate iterates retain partial information. This connects Novikov's principle to channel capacity in information theory.\n\nWhy now? The affine contraction theorem (`affine_contracting`) and convergence rate (`novikov_convergence_rate`) provide the quantitative foundation. Formalizing the information-theoretic connection would bridge our work to coding theory.\n\n## 4. Causal Evolution Semigroups and Temporal Algebra\n\nDefine a *causal semigroup*: the set of all contracting self-maps on a fixed metric space, equipped with composition. Our `causal_composition_contracting` shows this is closed under composition. We conjecture that the map sending each causal evolution to its consistent history (fixed point) is a *continuous semigroup homomorphism* from the causal semigroup (with the sup-metric on maps) to the state space.\n\nThe key insight is that `consistent_history_stability` already shows Lipschitz dependence of the fixed point on the map. The homomorphism property would say: the consistent history of the composed evolution T\u2081 \u2218 T\u2082 equals the result of first applying T\u2082's resolution and then T\u2081's \u2014 but this is false in general! The failure of this homomorphism property is precisely what makes time travel nontrivial: the consistent history of a composition is *not* the composition of consistent histories.\n\nWhy now? The stability theorem gives the continuity half. Characterizing exactly when the homomorphism property holds (and proving it fails in general) would yield structural theorems about when time travel \"commutes.\"\n\n## 5. Stochastic Causal Evolutions and Quantum Consistency\n\nExtend the framework from deterministic contractions to *random* causal maps \u2014 where the evolution is a random operator T_\u03c9 and consistency requires E[T_\u03c9(x)] = x or T_\u03c9(x) = x almost surely. This models quantum-mechanical time travel, where the evolution through a CTC involves measurement uncertainty.\n\nThe key insight is that the Banach fixed-point theorem extends to random contractions: if E[K_\u03c9] < 1 (the expected contraction constant is less than 1), then there exists a unique consistent history *in expectation*, even if individual realizations T_\u03c9 have K_\u03c9 \u2265 1. This is a probabilistic Novikov principle: consistency holds on average even when individual histories may be paradoxical.\n\nWhy now? The deterministic theory is now complete with full PEGB. The probabilistic extension would connect to Mathlib's measure theory and probability, and to the physics literature on quantum mechanics in the presence of CTCs (Deutsch's model).\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_1033",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "08293a01",
    "status": "available",
    "timestamp": "2026-06-08T23:18:13.189064+00:00",
    "title": "The current formalization handles single closed timelike curves and their pairwi"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Reverse Mathematics of Ramsey's Theorem\n\n## 1. Formalize Seetapun's Cone Avoidance Theorem\n\nSeetapun's theorem (1995) states that for every non-computable set C, every computable 2-coloring of pairs admits an infinite homogeneous set H that does not compute C. This is the key result separating RT\u00b2\u2082 from ACA\u2080. A formalization would require defining Turing reducibility and computable colorings in Lean 4, then proving that the Erd\u0151s\u2013Rado iterative construction can be performed while avoiding a given Turing cone.\n\nThe key insight is that at each stage of the construction, we have two infinite sets to choose from (one for each color), and a priority argument shows we can always pick the one that doesn't compute C. This is a forcing argument disguised as a finite extension construction.\n\nWhy now? The Defs.lean framework already provides the `SymPairColoring` and `IsHomogeneous` infrastructure. Mathlib's computability library (`Mathlib.Computability.*`) provides Turing machines and reducibility, though the oracle computation model may need extension.\n\n## 2. Formalize the Cholak\u2013Jockusch\u2013Slaman Decomposition Constructively\n\nOur `CJS_decomposition` theorem (SRT\u00b2\u2082 + COH \u2192 RT\u00b2\u2082) currently uses the direct proof of RT\u00b2\u2082. A more informative formalization would give the *constructive reduction*: given an infinite homogeneous set for the stable part and a cohesive set, explicitly construct a homogeneous set for the original coloring. This would involve defining the stable part of a coloring (using the cohesive set to stabilize it), applying SRT\u00b2\u2082 to the stable part, and then using cohesiveness to transfer back.\n\nThe key insight is that any coloring c, when restricted to a cohesive set C for the sequence of sets R_i = {j : c(i,j) = true}, becomes stable. The CJS decomposition is thus an equivalence between RT\u00b2\u2082 and the conjunction SRT\u00b2\u2082 \u2227 COH.\n\nWhy now? The definitions of `IsStable`, `IsCohesive`, and `SRT2_2` are already in place. The missing piece is the explicit construction of the stable part, which is a moderate formalization effort building on existing infrastructure.\n\n## 3. Liu's Separation of RT\u00b2\u2082 from WKL\u2080\n\nLiu (2012) proved that RT\u00b2\u2082 does not imply WKL\u2080 over RCA\u2080, completing the classification of RT\u00b2\u2082 in the Big Five. Formalizing this would require defining WKL\u2080 (every infinite binary tree has an infinite path) as a combinatorial principle, then constructing an \u03c9-model satisfying RT\u00b2\u2082 but not WKL\u2080. This is significantly harder than the Seetapun separation.\n\nThe key insight is that Liu constructs a model where every set is low\u2082 (its double jump is computable from 0''), and shows RT\u00b2\u2082 can be satisfied within this class while WKL\u2080 requires sets that are not low\u2082.\n\nWhy now? The framework supports stating WKL\u2080 as a combinatorial principle about infinite binary trees (definable using `\u2115 \u2192 Bool` sequences). The model construction, however, requires substantial computability infrastructure beyond what Mathlib currently provides.\n\n## 4. Ramsey's Theorem for Higher Exponents: RT^n_k\n\nOur formalization covers RT\u00b2\u2082 (pairs with 2 colors). The natural generalization is RT^n_k: every k-coloring of n-element subsets of \u2115 has an infinite homogeneous set. The finite version (with explicit Ramsey numbers) is partially in the existing catalog (`Catalog/Algebra/Ramsey/Defs.lean`). Bridging the finite and infinite versions, and proving the Erd\u0151s\u2013Rado generalization to higher arities, would be a significant formalization milestone.\n\nThe key insight is that the induction for RT^n_k proceeds by reducing to RT^{n-1}_{R(k)} \u2014 a coloring of (n-1)-sets with a potentially much larger number of colors \u2014 making the bound tower-exponential in n. This iterated pigeonhole structure directly generalizes our proof of `rt2_2_proof`.\n\nWhy now? The `SymPairColoring` structure naturally generalizes to n-uniform hypergraph colorings. The existing `RamseyProp` in the catalog provides the finite base case. Connecting these two frameworks is the immediate next step.\n\n## 5. The Reverse Mathematics Zoo: Formalizing the Full Hierarchy\n\nBeyond RT\u00b2\u2082, the reverse mathematics landscape includes dozens of principles (CAC, ADS, SADS, EM, COH, DNR, WWKL\u2080, etc.) with a rich web of implications and separations \u2014 the \"reverse mathematics zoo\" catalogued by Damir Dzhafarov and others. Formalizing even a fragment of this zoo in Lean 4 would be a landmark in formal mathematics. Each principle can be stated as a Prop about \u2115, sets, and sequences, using the framework established here.\n\nThe key insight is that many of these principles (CAC = chain-antichain, ADS = ascending-descending sequence) are natural combinatorial statements that fit the `Set \u2115` / `\u2115 \u2192 \u2115` framework already established. The separations between them often require elaborate priority constructions, but the implications are typically short combinatorial arguments amenable to automated proving.\n\nWhy now? The `Defs.lean` module provides a reusable vocabulary (`Set.Infinite`, symmetric colorings, cohesiveness) that most zoo principles can be stated in. Each new principle and implication is a self-contained formal contribution, making this highly parallelizable across research cycles.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_1034",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "0afbba2f",
    "status": "available",
    "timestamp": "2026-06-08T23:54:39.755973+00:00",
    "title": "Seetapun's theorem (1995) states that for every non-computable set C, every comp"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Stratified Interchange Algebras and Synthetic Homotopy Theory\n\n## 1. Freudenthal Suspension Theorem for Suspended SIAs\n\nThe `SuspendedSIA` structure introduces suspension homomorphisms `susp : Carrier n \u2192 Carrier (n+1)` connecting adjacent levels. A natural conjecture is an algebraic analogue of the Freudenthal suspension theorem: under appropriate \"connectivity\" conditions on the SIA, the suspension map should become an isomorphism in a stable range.\n\n**Conjecture**: Define a *k-connected SIA* as one where `Carrier n` is trivial (isomorphic to `Unit`) for `n < k`. Then for a k-connected Suspended SIA, the suspension map `susp n` is a bijection for `n \u2264 2k - 2`. This would give an algebraic version of the classical Freudenthal theorem without reference to topological spaces.\n\n**Testable prediction**: For any concrete SIA built from the homotopy groups of a k-connected space (e.g., S\u00b3 is 2-connected, with \u03c0\u2083 = \u2124, \u03c0\u2084 = \u2124/2, ...), the suspension map should be surjective for n \u2264 2k - 1 and injective for n \u2264 2k - 2. This can be computationally verified for spheres using known homotopy group tables.\n\nThe key insight is that the algebraic axioms of the SIA \u2014 particularly the interchange law and the suspension homomorphism property \u2014 should be sufficient to derive stability results without topology, suggesting that Freudenthal is fundamentally an algebraic rather than topological theorem.\n\n**Why now?** The formalized SIA structure provides the first clean axiomatization where this conjecture can be precisely stated and tested. Previous work on stable homotopy theory in Lean has been blocked by the absence of a suitable algebraic framework.\n\n## 2. Classification of Finite SIAs and Connection to Group Cohomology\n\nEvery SIA with finite carriers determines a sequence of finite abelian groups (at each level) connected by homomorphisms. The classification of such sequences is closely related to derived functors and group cohomology.\n\n**Conjecture**: The isomorphism classes of finite SIAs with `|Carrier n| \u2264 N` for all n and `Carrier n` trivial for `n > k` are in bijection with elements of `\u220f_{i=0}^{k} Ab_{\u2264N}` modulo a natural equivalence relation induced by the homomorphism compatibility. More precisely, the \"space\" of SIA structures on a fixed sequence of abelian groups is a torsor for a product of Ext groups.\n\n**Testable prediction**: Count the number of distinct SIA structures (up to isomorphism) on the graded abelian group `(\u2124/2, \u2124/2, \u2124/4, 0, 0, ...)`. The answer should equal the number of homomorphisms `\u2124/2 \u2192 \u2124/2` times the number of homomorphisms `\u2124/2 \u2192 \u2124/4`, i.e., 2 \u00d7 2 = 4. This can be verified computationally.\n\nThe key insight is that the SIA axioms (particularly the interchange law) impose no additional constraints beyond the group and homomorphism axioms \u2014 the interchange is automatically satisfied because all levels are abelian. This means SIA classification reduces entirely to classifying graded abelian groups with compatible homomorphisms.\n\n**Why now?** The formalized `CommGroup` instance at each SIA level (our `instCommGroupCarrier`) directly connects to Mathlib's extensive group theory library, making automated enumeration feasible.\n\n## 3. Higher Interchange Laws and n-Fold Monoidal Categories\n\nThe SIA's interchange law relates two binary operations. A natural generalization considers *n-fold interchange*, where n+1 binary operations mutually satisfy interchange. The Eckmann-Hilton argument shows that 2-fold interchange forces all operations to be equal and commutative. But what algebraic constraints does n-fold interchange impose beyond commutativity?\n\n**Conjecture**: For n \u2265 2, having n binary operations on a set, all pairwise satisfying the interchange law with a common identity, forces all operations to be identical and commutative. Moreover, the resulting commutative monoid must satisfy the \"higher commutativity\" condition that every element commutes with every element in every possible parenthesization \u2014 which is already automatic for associative operations, but becomes non-trivial if associativity is weakened.\n\n**Testable prediction**: Implement a brute-force search over all binary operations on `Fin n` for small n (say n \u2264 6). For each pair of operations with shared identity and interchange, verify they are equal. Then for triples of operations with pairwise interchange, verify no additional structure emerges beyond what pairwise EH gives. If additional structure appears, it would refute the conjecture.\n\nThe key insight is that the Eckmann-Hilton argument is \"idempotent\" \u2014 applying it twice should give nothing new \u2014 but this has never been formally verified in the n-fold setting.\n\n**Why now?** Our formalization of the basic EH argument provides the infrastructure for mechanically iterating it, and `Fin n` computations are well-supported in Lean 4.\n\n## 4. Delooping Theorems for SIAs\n\nIn homotopy theory, a connected space X is a \"delooping\" of its loop space \u03a9X, meaning X \u2243 B\u03a9X under appropriate conditions. Algebraically, this corresponds to the question: given an SIA truncated at level k, can we extend it to level k+1?\n\n**Conjecture**: A Suspended SIA can always be extended by one level. Specifically, given `(Carrier 0, ..., Carrier k)` with all SIA axioms and suspension maps, there exists an extension to `Carrier (k+1)` with a suspension map `susp k : Carrier k \u2192 Carrier (k+1)` such that all axioms are preserved. However, the extension is not unique \u2014 the space of extensions is a torsor for `Aut(Carrier k)`.\n\n**Testable prediction**: Take the SIA with `Carrier 0 = \u2124` and all higher levels trivial. There should be exactly one extension to level 1 (up to isomorphism): `Carrier 1 = {0}` with the trivial suspension. But if `Carrier 0 = \u2124` and `Carrier 1 = \u2124`, the number of valid suspension maps `susp 0 : \u2124 \u2192 \u2124` should be countably infinite (one for each group homomorphism \u2124 \u2192 \u2124, i.e., one for each integer).\n\nThe key insight is that the SIA axioms constrain extensions only through the homomorphism condition on suspension, so the \"delooping space\" is exactly `Hom(Carrier k, G)` for any abelian group G chosen as the new level.\n\n**Why now?** The formalized `SuspendedSIA` structure and its kernel characterization (`suspKernel`) provide the technical foundation for stating and proving delooping results.\n\n## 5. Derived Eckmann-Hilton for Non-Associative Operations\n\nOur EH theorem assumes the binary systems have two-sided identity elements but does not assume associativity. A natural question: what happens if we weaken the identity axiom as well?\n\n**Conjecture (Partial Eckmann-Hilton)**: If two binary operations on a set satisfy the interchange law and share a common *left* identity (but not necessarily right identity), then the operations agree on the image of the left identity operation. Specifically, for all `a`, `S.op e a = T.op e a`. But the operations need not be globally equal, and need not be commutative.\n\n**Testable prediction**: Construct a type with two binary operations having a common left identity and interchange, but different right identity behavior. On `\u2124 \u00d7 \u2124`, define `S.op (a,b) (c,d) = (a+c, d)` with left identity `(0, ?)` \u2014 check if interchange can hold with a second operation having the same left identity but different right behavior. If no such example exists for types of size \u2264 8, the conjecture is likely false and full EH holds under weaker assumptions.\n\nThe key insight is that our proof of `eckmann_hilton_ops_eq` uses both left and right identity of both operations. If only left identity is needed, the theorem is stronger; if not, identifying exactly which identity axioms are necessary would sharpen the classical result.\n\n**Why now?** The clean separation of axioms in our `BinarySystem` structure makes it easy to systematically weaken hypotheses and test which combinations suffice for the EH conclusion.\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_1035",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "efa69ffd",
    "status": "available",
    "timestamp": "2026-06-08T23:56:54.048138+00:00",
    "title": "The `SuspendedSIA` structure introduces suspension homomorphisms `susp : Carrier"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Non-Archimedean Probability Theory\n\n## What We Built\n\nThis cycle established `FinProbSpace F n` and `RegularFinProbSpace F n` \u2014 finite\nprobability spaces over arbitrary linearly ordered fields \u2014 with 7 machine-verified\ntheorems (zero sorries) covering inclusion-exclusion, Bayes, Markov, the Dutch Book\ntheorem (both directions), regular conditional probability, and a tropical bridge.\n\nThe central insight: **all classical finite probability is purely algebraic**. Nothing\nin the proofs of Bayes' theorem, Markov's inequality, or the Dutch Book argument\nuses completeness, the Archimedean property, or any analytic structure. The only\nrequirements are the ordered field axioms.\n\n---\n\n## Direction 1: Countable Non-Archimedean Probability via Formal Power Series\n\nThe key insight is that the Levi-Civita field \u211d((\u03b5)) admits a natural \"formal summation\"\nfor countable sums of infinitesimals: \u2211_{n\u22650} \u03b5 is not convergent in the order topology\nbut is a well-defined element in an extension that tracks infinite sums as formal objects.\nThis suggests defining countable probability not via limits but via algebraic extension.\n\n**Falsifiable prediction**: Define `CountableProbSpace` over the Levi-Civita field with\nweight function w(n) = c\u00b7\u03b5^{f(n)} where f : \u2115 \u2192 \u2115 is strictly increasing and c is a\nnormalization constant. Conjecture: the resulting structure satisfies countable additivity\nif and only if f grows at least linearly, since \u2211 \u03b5^n converges iff it's a formal geometric\nseries.\n\n**Why now?** Our `FinProbSpace` framework is parametric in the field \u2014 the same typeclass\nconstraints (`Field`, `LinearOrder`, `IsStrictOrderedRing`) apply to the Levi-Civita field.\nThe finite theory lifts directly via truncation arguments.\n\n---\n\n## Direction 2: Full Dutch Book Characterization (Both Directions, Negative Weights)\n\nThe key insight is that our `dutch_book_of_sum_ne_one` handles mispriced totals, but the\nfull Dutch Book theorem should also cover negative prices. The complete characterization\nis: `\u00ac Nonempty (DutchBook F n p) \u2194 (\u2200 i, 0 \u2264 p i) \u2227 \u2211 p = 1`. The backward direction\nis already `no_dutch_book`; the forward direction needs: if some p(i) < 0, construct an\nexplicit Dutch book by buying that single bet.\n\n**Falsifiable prediction**: The explicit construction for negative prices is: stake s(i) = 1,\ns(j) = 0 for j \u2260 i, when p(i) < 0. Then profit at \u03c9 = i is 1 - p(i) > 0 (since p(i) < 0),\nand profit at \u03c9 \u2260 i is 0 - p(i) = -p(i) > 0. This should be formally verifiable in < 20\nlines.\n\n**Why now?** We have both `no_dutch_book` and `dutch_book_of_sum_ne_one`. The missing piece\nis a single additional lemma handling negative weights, completing the iff.\n\n---\n\n## Direction 3: Tropical-Probability Functor via Valuation Maps\n\nThe key insight is that our `prob_weight_power_bound` theorem is already a *shadow* of the\ntropical correspondence: when weights are \u03b5^{k(i)}, probability is controlled by min(k(i)),\nwhich is exactly the tropical sum. A formal functor F : NonArchProb \u2192 TropProb would send\nweight \u03b5^k \u21a6 k and probability (sum of \u03b5^{k(i)}) \u21a6 min(k(i)).\n\n**Falsifiable prediction**: Under the valuation map v(\u2211 a_k \u03b5^k) = min{k : a_k \u2260 0},\nthe Bayes identity v(P(A|B)) + v(P(B)) = v(P(B|A)) + v(P(A)) holds exactly (not just\napproximately) when all intersection probabilities are dominated by a single term.\nConstruct a 4-element counterexample where it fails due to cancellation in the leading term.\n\n**Why now?** The `prob_weight_power_bound` provides the key estimate. Formalizing the\nvaluation map and connecting to existing tropical algebra structures in the Catalog\n(`Tropical/` directory) would create a genuine cross-domain bridge.\n\n---\n\n## Direction 4: Non-Archimedean Game Values and Trembling-Hand Equilibria\n\nThe key insight is that the simplex method for linear programming is purely algebraic \u2014\nit works over any ordered field. This means minimax values of finite games exist over\nnon-Archimedean fields, yielding game values that are formal power series in \u03b5 encoding\nboth the standard value and sensitivity to dominated-strategy trembles.\n\n**Falsifiable prediction**: For the 2\u00d72 game with payoff matrix [[1,0],[0,1]] (matching\npennies), the minimax value over F = \u211d((\u03b5)) with minimum probability \u03b5 is exactly\n1/2 + O(\u03b5). Compute the exact coefficient of \u03b5 and verify it equals 0 (by symmetry).\nFor the asymmetric game [[2,0],[0,1]], predict the coefficient is nonzero and compute it.\n\n**Why now?** Our `FinProbSpace` already models mixed strategies over ordered fields.\nThe game-theoretic application requires only defining payoff matrices and the minimax\noptimization problem, both of which are algebraic.\n\n---\n\n## Direction 5: Non-Archimedean Entropy via Khinchin Axioms\n\nThe key insight is that Shannon entropy can be characterized axiomatically (Khinchin 1957)\nwithout reference to logarithms: it is the unique function H satisfying continuity,\nmaximality at uniform, additivity, and the grouping axiom. Over non-Archimedean fields,\n\"continuity\" must be replaced by an algebraic condition, but the other three axioms\ntransfer directly.\n\n**Falsifiable prediction**: Define H algebraically for `FinProbSpace F n` via the grouping\naxiom: H(p\u2081,...,p\u2099) = H(p\u2081+p\u2082, p\u2083,...,p\u2099) + (p\u2081+p\u2082)\u00b7H(p\u2081/(p\u2081+p\u2082), p\u2082/(p\u2081+p\u2082)).\nConjecture: this recursion, together with H(1/n,...,1/n) = log(n) (for a formal log),\nuniquely determines H. Test: verify H(1/2,1/3,1/6) = log(6) - (1/2)log(2) - (1/3)log(3)\nmatches the classical formula.\n\n**Why now?** The `expectation` function in our framework already computes weighted sums.\nEntropy is just `expectation` applied to the function i \u21a6 -log(w(i)), so the algebraic\nscaffolding exists. The challenge is defining a formal logarithm compatible with the\nordered field structure.\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_1036",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "9ff4961b",
    "status": "available",
    "timestamp": "2026-06-09T00:33:35.900496+00:00",
    "title": "`FinProbSpace F n` and `RegularFinProbSpace F n` \u2014 finite"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Non-Archimedean Probability Theory\n\n## What We Proved\n\nThis cycle formalized the algebraic foundations of probability theory in non-Archimedean ordered fields. The core results are:\n\n1. **Non-Archimedean \u27fa Infinitesimal Existence** (`non_archimedean_iff_infinitesimal_exists`): A linearly ordered field admits positive elements \u03b5 with n\u2022\u03b5 < 1 for all n \u2208 \u2115 if and only if it is non-Archimedean. This transforms the philosophical question \"can probabilities be infinitesimal?\" into a precise algebraic condition.\n\n2. **Faithfulness \u27fa Strict Monotonicity** (`strict_mono_iff_faithful`): A finitely additive measure on a finite type is faithful (all atoms positive) if and only if it is strictly monotone (S \u2282 T \u27f9 \u03bc(S) < \u03bc(T)). This characterizes faithful measures purely via an order-theoretic property.\n\n3. **Conditional Probability on Singletons** (`conditional_point_mem`, `conditional_point_not_mem`): In any field-valued measure with positive weights, P(A | {x}) = 1_A(x). This resolves the Borel-Kolmogorov paradox: conditioning on points is well-defined because P({x}) > 0.\n\n4. **Sub-Probability Completion** (`sub_probability_completion`): Any sub-probability measure (total < 1) on n elements can be extended to a genuine probability measure on n+1 elements by adding a single corrective weight \u03b4 = 1 - n\u2022\u03b5.\n\n---\n\n## Direction 1: Hyperfinite Measure Completion\n\nThe key insight is that while `sub_probability_completion` adds a single correction element, a truly uniform non-Archimedean probability requires the *number of elements itself* to be non-standard. In a non-Archimedean field F containing \u03c9 > n for all n \u2208 \u2115, the uniform measure assigning weight \u03c9\u207b\u00b9 to each of \"\u03c9 many\" elements would sum to exactly 1 \u2014 but formalizing \"\u03c9 many elements\" requires either a hyperfinite type abstraction or an ultraproduct construction.\n\n**Conjecture**: There exists a formalization of \"hyperfinite Finset\" parameterized by a non-standard element \u03c9 \u2208 F such that the uniform measure with weight \u03c9\u207b\u00b9 sums to 1 over this set, using the algebraic identity \u03c9 \u00b7 \u03c9\u207b\u00b9 = 1.\n\n**Why now?** Our `uniform_finmeasure_total` proves that for standard Fin n, the total is n \u2022 \u03b5. The gap is purely type-theoretic: bridging from \"n is a natural number\" to \"\u03c9 is a field element that exceeds all naturals.\" The algebraic content (\u03c9 \u00b7 \u03c9\u207b\u00b9 = 1) is trivial; the challenge is the foundational framework.\n\n## Direction 2: Conditional Probability as a Probability Measure\n\nThe key insight is that our `conditional_point_mem`/`conditional_point_not_mem` show P(\u00b7 | {x}) acts like an indicator, but we have not yet proved that P(\u00b7 | B) is itself a probability measure (normalized and additive) for general B.\n\n**Conjecture**: For faithful weights w and nonempty B, the function A \u21a6 condProb w A B satisfies: (1) condProb w B B = 1 [proved as `condProb_self`], (2) condProb w \u2205 B = 0, and (3) condProb w (A\u2081 \u222a A\u2082) B = condProb w A\u2081 B + condProb w A\u2082 B when A\u2081 \u2229 A\u2082 \u2229 B = \u2205.\n\n**Why now?** We already have `condProb_self` and `finmeasure_disjoint_additive`. The remaining step is to verify that intersection distributes correctly through the conditional probability formula \u2014 a straightforward but formally non-trivial algebraic manipulation.\n\n## Direction 3: Tropical Degeneration of Non-Archimedean Measures\n\nThe key insight is that for a family of measures \u03bc_\u03b5({x}) = \u03b5^{v(x)} parameterized by \u03b5 \u2208 (0,1), the logarithmic rescaling -log(\u03bc_\u03b5(S))/log(\u03b5) converges as \u03b5 \u2192 0 to min_{x \u2208 S} v(x), recovering the tropical (min-plus) semiring structure.\n\n**Conjecture**: For a valuation v : \u03b1 \u2192 \u2115 on a finite type and \u03b5 \u2208 (0,1) \u2282 \u211d, define \u03bc_\u03b5(S) = \u2211_{x \u2208 S} \u03b5^{v(x)}. Then lim_{\u03b5\u21920} (-log(\u03bc_\u03b5(S))/log(\u03b5)) = min_{x \u2208 S} v(x). The resulting \"tropical probability\" satisfies: (1) tropical union = min of costs, (2) tropical total = min of all valuations.\n\n**Why now?** This bridges the non-Archimedean probability framework with the catalog's tropical mathematics threads. The proof strategy uses dominated convergence for finite sums: as \u03b5 \u2192 0, the term with smallest exponent dominates.\n\n## Direction 4: Faithfulness Characterization for Signed Measures\n\nThe key insight is that `strict_mono_iff_faithful` currently assumes the field is linearly ordered, but the forward direction (strict monotonicity \u27f9 faithful) holds for *any* ordered field, while the backward direction requires cancellative addition. The characterization may extend to partially ordered rings.\n\n**Conjecture**: Over a partially ordered cancellative commutative monoid M, a weight function w : \u03b1 \u2192 M satisfies strict monotonicity for all S \u2282 T if and only if w(x) > 0 for all x. The proof of the forward direction (our `strict_mono_implies_faithful`) already works in this generality; the backward direction (`faithful_measure_strict_mono`) requires `IsOrderedCancelAddMonoid`.\n\n**Why now?** Our current proof uses `Finset.sum_lt_sum_of_subset`, which requires ordered cancellative addition. Identifying the minimal algebraic hypotheses would clarify exactly which algebraic structures support faithful measures.\n\n## Direction 5: Non-Archimedean Bayesian Updating\n\nThe key insight is that sequential Bayesian updating P(H | D\u2081, D\u2082, ...) can be formalized as iterated conditional probability, and in non-Archimedean probability this is always well-defined because P(D\u1d62) > 0 for all data points \u2014 unlike in standard probability where continuous observations have zero probability.\n\n**Conjecture**: For faithful weights on a finite type, define the posterior after observing a sequence of data points D\u2081, ..., D\u2096 as iterated conditioning. Then: (1) the posterior is independent of the order of observations (commutativity of updating), (2) the posterior is itself a faithful measure (positivity is preserved), and (3) the posterior converges (in a suitable sense) to a point mass as the number of observations grows.\n\n**Why now?** Our `conditional_point_mem` shows that conditioning on a single point gives an indicator. Iterated conditioning is the natural next step, and the finite-type setting avoids measure-theoretic complications.\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_1037",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "53f842c3",
    "status": "available",
    "timestamp": "2026-06-09T00:34:12.985598+00:00",
    "title": "This cycle formalized the algebraic foundations of probability theory in non-Arc"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Spectral Scaling Laws\n\n## 1. Quantitative Spectral Truncation Bounds via Integral Comparison\n\nThe current `tail_sum_antitone` theorem establishes monotonicity of the approximation error but does not give quantitative rates. For a spectral profile with eigenvalue decay \u03bb_k ~ C\u00b7k^(-\u03b1), the tail sum should satisfy\n\n  \u03a3_{k\u2265P} \u03bb_k \u2264 C'\u00b7P^(-(\u03b1-1))\n\nfor \u03b1 > 1, via comparison with the integral \u222b_P^\u221e t^(-\u03b1) dt = P^(-(\u03b1-1))/(\u03b1-1). The key insight is that this integral comparison (Euler-Maclaurin at zeroth order) converts the discrete spectral decay rate \u03b1 into the continuous approximation error rate \u03b1-1, which is exactly the bias exponent observed empirically in neural scaling laws. Why now? Mathlib's `Antitone.sum_le_integral` and related integral-sum comparison lemmas are now mature enough to make this formalization tractable. This would close the gap between our abstract spectral framework and the concrete power-law exponents measured in practice.\n\n**Testable prediction**: For the Mat\u00e9rn-\u03bd kernel on [0,1]^d with \u03bd > d/2, the eigenvalues decay as k^(-2\u03bd/d - 1) (Weyl's law), predicting a bias exponent of 2\u03bd/d. This is computationally verifiable by diagonalizing the kernel matrix for moderate d and \u03bd.\n\n## 2. Multi-Resource Scaling with n-way Compute Allocation\n\nOur theorems handle two-resource allocation (parameters P and data D). Real training involves at least three resources: parameters, data, and training steps (epochs). The generalized problem minimizes\n\n  L = \u03a3\u1d62 A\u1d62 \u00b7 x\u1d62^(-\u03b1\u1d62)  subject to  \u03a0 x\u1d62 = C\n\nThe key insight is that the n-resource harmonic exponent \u03b3 = (\u03a3 1/\u03b1\u1d62)\u207b\u00b9 follows from the same Lagrange multiplier analysis, and the optimal allocation exponents e\u1d62 = (1/\u03b1\u1d62)/(\u03a3 1/\u03b1\u2c7c) form a probability distribution over resources. This \"resource attention\" distribution is the mathematical dual of the attention mechanism in transformers \u2014 both allocate capacity according to importance weights. Why now? Our `optimal_exponents_sum_to_one` theorem already proves the partition-of-unity property for n=2; the generalization to n resources requires only Finset-indexed versions of the same algebraic identities.\n\n**Testable prediction**: For 3-resource scaling (P, D, epochs E) with measured exponents \u03b1_P \u2248 0.076, \u03b1_D \u2248 0.095, \u03b1_E \u2248 0.050 (from Hoffmann et al.), the theory predicts \u03b3\u2083 = (1/0.076 + 1/0.095 + 1/0.050)\u207b\u00b9 \u2248 0.024. This can be validated against compute-optimal training runs.\n\n## 3. Phase Transitions in the Bias-Variance Landscape\n\nOur `bias_strict_decrease` theorem shows bias is strictly monotone, but real neural networks exhibit phase transitions \u2014 sudden capability jumps at specific scales. The key insight is that phase transitions arise when the spectral gap (ratio \u03bb_{P}/\u03bb_{P+1}) is anomalously large, creating a \"spectral cliff\" where adding one eigenmode captures disproportionate variance. Formally, if the spectral profile has a gap g_P = \u03bb_P/\u03bb_{P+1} \u226b 1 at index P*, then the loss landscape has a local \"plateau-then-drop\" structure around P*, observable as an emergent capability. Why now? Our SpectralProfile structure already encodes the eigenvalue ordering; adding a `spectralGap` function and proving that large gaps create loss function inflection points would connect our continuous scaling theory to the discrete phenomenon of emergence.\n\n**Testable prediction (falsifiable)**: If a language model exhibits an emergent capability at scale P*, then the NTK eigenspectrum at scale P*-1 should show a spectral gap ratio \u03bb_{P*}/\u03bb_{P*+1} > 10. This is testable by computing NTK spectra of small transformer models across scales.\n\n## 4. Information-Theoretic Lower Bounds on Scaling Exponents\n\nOur `harmonic_exponent_bounds` theorem shows \u03b3 < min(\u03b1, \u03b2), but does not establish whether the bound is tight. The key insight is that the harmonic exponent \u03b3 = \u03b1\u03b2/(\u03b1+\u03b2) is actually achievable \u2014 it is not just an upper bound but the exact rate \u2014 and this can be proved by constructing an explicit kernel whose spectral profile achieves the bound with equality. The Mat\u00e9rn family provides such a construction: for Mat\u00e9rn-\u03bd on [0,1]^d, the bias exponent \u03b1 = 2\u03bd/d and the variance exponent \u03b2 = 1, giving \u03b3 = 2\u03bd/(d+2\u03bd), which matches the minimax rate for nonparametric regression in Sobolev spaces of order \u03bd. This connects neural scaling laws to classical statistical learning theory. Why now? Mathlib now has solid foundations for Sobolev spaces and kernel reproducing Hilbert spaces that would support formalizing the minimax connection.\n\n**Testable prediction**: No kernel method can achieve a scaling exponent \u03b3 > \u03b1\u03b2/(\u03b1+\u03b2) under the spectral decay assumption \u03bb_k ~ k^(-\u03b1). This lower bound should hold for any learning algorithm, not just kernel methods, when the target function lives in the RKHS. Computationally testable by comparing scaling curves of different architectures on synthetic data from known RKHS functions.\n\n## 5. Cross-Domain Bridge: Scaling Laws and Thermodynamic Free Energy\n\nThe loss function L(P, D) = A\u00b7P^(-\u03b1) + B\u00b7D^(-\u03b2) has the mathematical structure of a free energy F = E - TS in statistical mechanics, where the bias term plays the role of internal energy (model capacity) and the variance term plays the role of entropic cost (data complexity). The key insight is that the critical point condition \u03b1\u00b7(bias) = \u03b2\u00b7(variance) \u2014 our `marginal_balance_identity` \u2014 is precisely the thermodynamic equilibrium condition \u2202F/\u2202T = 0, and the harmonic exponent \u03b3 is the critical exponent of the associated phase transition. This suggests that neural scaling laws are instances of universality in the renormalization group sense. Why now? The Catalog already contains formalized results on thermodynamic quantities (in Physics/) and spectral theory (in Algebra/); bridging them through the scaling law framework would create a genuinely novel cross-domain connection. The marginal balance identity we proved is the formal bridge \u2014 it states that at optimum, the system is at a \"thermal equilibrium\" between approximation and estimation.\n\n**Testable prediction**: If we define a \"scaling susceptibility\" \u03c7 = -\u2202\u00b2L*/\u2202(log C)\u00b2 at the optimal allocation, then \u03c7 should diverge at the critical exponent ratio \u03b1/\u03b2 = 1 (the symmetric point), analogous to a second-order phase transition. This is numerically testable.\n",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_1038",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "f8b9d9f4",
    "status": "available",
    "timestamp": "2026-06-09T00:34:50.005925+00:00",
    "title": "The current `tail_sum_antitone` theorem establishes monotonicity of the approxim"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Proof-Theoretic Ordinal Analysis\n\n## 1. Ordinal Collapsing Functions and the Bachmann-Howard Ordinal\n\nThe current framework models theories by their set of provably well-ordered ordinals, but stops at the supremum (sSup). The next natural step is to formalize ordinal collapsing functions \u2014 the Bachmann-Howard hierarchy \u2014 which provide concrete ordinal notation systems for theories significantly beyond \u03b5\u2080. The key insight is that ordinal collapsing functions (\u03c8, \u03b8) allow us to \"name\" large ordinals using smaller ones as indices, creating a computable notation system for ordinals up to the Bachmann-Howard ordinal. Why now? Mathlib already has `ONote` for ordinals below \u03b5\u2080; extending to collapsing functions would be the first formalization of these in any proof assistant, bridging the gap between concrete notation systems and abstract ordinal theory.\n\n**Testable conjecture**: A collapsing function \u03c8_\u03a9 defined on ordinal notations below \u03a9 (the first uncountable ordinal) yields a well-founded notation system whose order type is exactly the Bachmann-Howard ordinal.\n\n## 2. Proof-Theoretic Ordinals of Concrete Theories\n\nOur `BoundedTheory` framework is abstract \u2014 it characterizes theories by their provably-WO sets without connecting to specific formal systems. The key insight is that by formalizing the encoding of well-ordering proofs in specific theories (PA, ATR\u2080, \u03a0\u00b9\u2081-CA\u2080), we can prove that the abstract PTO matches the known values: |PA| = \u03b5\u2080, |ATR\u2080| = \u0393\u2080, |\u03a0\u00b9\u2081-CA\u2080| = \u03c8_\u03a9(\u03b5_{\u03a9+1}). Why now? The `bounded_theory_saturated` theorem shows all BoundedTheories are automatically saturated, which means the abstract framework perfectly captures the \"initial segment\" structure of provability \u2014 this is exactly the structure needed to connect to concrete theories.\n\n**Testable conjecture**: There exists a computable function mapping PA proofs of transfinite induction principles to ordinal notations below \u03b5\u2080, and every notation below \u03b5\u2080 arises this way.\n\n## 3. The Ordinal Triangle Inequality Obstruction and Commutative Quotients\n\nWe discovered that the natural ordinal-valued \"distance\" depthDist fails the triangle inequality due to non-commutativity of ordinal addition. The key insight is that this failure is not a bug but a feature: it reflects the genuine asymmetry of proof-theoretic strength, where combining two theories is not commutative at the ordinal level. Why now? The `depthDist_monotone_right` theorem shows that monotonicity holds, suggesting that the right framework is a directed metric space (quasi-metric) rather than a metric space. Formalizing the quasi-metric structure and characterizing when the triangle inequality does hold (e.g., for theories with PTOs below \u03c9^\u03c9, where ordinal arithmetic is commutative up to Cantor normal form) would give a precise boundary.\n\n**Testable conjecture**: depthDist satisfies the triangle inequality if and only if all three PTOs involved are additive principal ordinals (ordinals \u03b1 such that \u03b2 + \u03b3 < \u03b1 whenever \u03b2, \u03b3 < \u03b1).\n\n## 4. Theory Strength as a Well-Quasi-Order\n\nThe `pto_strictly_increasing_chain` theorem shows that strictly increasing chains of theories have strictly increasing PTOs. The key insight is that by combining this with the well-foundedness of ordinals below a bound, we can show that the space of theories with bounded PTO forms a well-quasi-order under the provability inclusion relation. Why now? This would connect proof-theoretic ordinal analysis to the theory of well-quasi-orders (Kruskal's theorem, graph minor theorem), potentially yielding new independence results.\n\n**Testable conjecture**: The set of BoundedTheories with PTO below \u03b5\u2080, ordered by provablyWO inclusion, contains no infinite antichain (and is in fact a better-quasi-order).\n\n## 5. Effective Ordinal Assignments via Fast-Growing Hierarchies\n\nMathlib's `ONote.fastGrowing` and `fastGrowing\u03b5\u2080` provide a computable hierarchy of functions \u2115 \u2192 \u2115 indexed by ordinal notations. The key insight is that the fast-growing hierarchy gives an effective characterization of proof-theoretic ordinals: a theory T has PTO \u2265 \u03b1 if and only if T can prove totality of the fast-growing function f_\u03b1. Why now? The `FinitelyDescribedTheory` structure already connects abstract PTOs to concrete `NONote` values; the next step is to connect these to the function-growth characterization, which is the historically primary way proof-theoretic ordinals were computed.\n\n**Testable conjecture**: For every NONote \u03b1, there is a BoundedTheory T_\u03b1 with PTO = \u03b1.repr such that T_\u03b1 proves totality of `ONote.fastGrowing \u03b1` but no theory with PTO < \u03b1.repr can prove the same.\n",
    "domains": [
      "Pythagorean",
      "Logic"
    ],
    "id": "fd_1039",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "832ede28",
    "status": "available",
    "timestamp": "2026-06-09T00:44:47.064113+00:00",
    "title": "The current framework models theories by their set of provably well-ordered ordi"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Spectral Universality of Proof Graphs\n\n## 1. Cheeger Inequality for Finite Simple Graphs\n\nFormalize the discrete Cheeger inequality relating the vertex expansion constant h(G)\nto the spectral gap \u03bb\u2082 of the normalized Laplacian: \u03bb\u2082/2 \u2264 h(G) \u2264 \u221a(2\u03bb\u2082). This\nwould require formalizing the normalized Laplacian matrix of a finite graph and its\neigenvalues in Lean/Mathlib, then proving the classical Alon-Milman / Dodziuk\ninequality.\n\nThe key insight is that the vertex boundary machinery developed here (vertexBoundary,\nmonotonicity, connectivity characterization) provides exactly the combinatorial side\nof the Cheeger inequality \u2014 what remains is connecting it to the algebraic\n(eigenvalue) side.\n\nWhy now? Mathlib's linear algebra and matrix theory has matured enough that eigenvalue\ncomputations for symmetric matrices over \u211d are becoming feasible. The combinatorial\ninfrastructure in Cheeger.lean eliminates half the work.\n\n## 2. Spectral Gap Scaling Laws for Random Graph Families\n\nFormalize the Erd\u0151s-R\u00e9nyi phase transition: for G(n, p) with p = c/n, prove that\nthe expected vertex expansion transitions from 0 (c < 1, disconnected w.h.p.) to\npositive (c > 1, giant component has expansion). This would formalize the connection\nbetween edge density thresholds and expansion phase transitions.\n\nThe key insight is that `connected_iff_vertexBoundary_nonempty` converts the\nconnectivity phase transition of G(n,p) directly into an expansion phase transition,\nand the monotonicity theorem `vertexBoundary_mono` ensures that adding edges can only\nimprove expansion.\n\nWhy now? The monotonicity and connectivity-expansion equivalence are now proven, so\nthe combinatorial framework is ready. The probabilistic component (concentration\ninequalities for random graphs) is the main remaining challenge.\n\n## 3. Vertex Expansion under Graph Products\n\nFormalize how vertex expansion behaves under standard graph products (Cartesian,\ntensor, lexicographic). For the Cartesian product G \u25a1 H, the vertex expansion\nsatisfies h(G \u25a1 H) \u2265 min(h(G), h(H)). This would model how composing proof\nlibraries (which corresponds to graph products on dependency structures) preserves\nor degrades expansion.\n\nThe key insight is that the monotonicity theorem `vertexBoundary_mono` already\ncaptures one direction (adding edges helps), but graph products introduce new\nvertices, requiring a fundamentally different analysis. The product expansion\ninequality is non-trivial and connects to the tensor product conjecture in\nspectral graph theory.\n\nWhy now? The vertex boundary definition is product-friendly (defined via neighbor\nsets), and Mathlib has good support for product types and Finset operations on\nproducts. The infrastructure gap is small.\n\n## 4. Proof-Theoretic Strength Stratification\n\nFormalize the conjecture that dependency graphs of proof libraries naturally\nstratify by proof-theoretic strength. Specifically: define a \"strength homomorphism\"\nfrom a proof graph to ordinals, where the strength function is monotone with respect\nto the dependency order. Prove that the existence of such a homomorphism constrains\nthe Cheeger constant \u2014 graphs admitting strength homomorphisms to small ordinals\nhave bounded expansion.\n\nThe key insight is that a monotone strength function partitions the vertex set into\nlevel sets, and the vertex boundary between consecutive levels is constrained by the\nordinal structure. This creates a formal bridge between proof-theoretic ordinals and\ngraph expansion.\n\nWhy now? The `ProofGraph` structure with its strength function is already defined.\nThe next step is formalizing the monotonicity constraint and deriving expansion\nbounds from the level-set structure.\n\n## 5. Algorithmic Expansion Testing via Boundary Computation\n\nFormalize decidability and complexity of computing the Cheeger constant for finite\ngraphs. The Cheeger constant is NP-hard to compute exactly (by reduction from\nbisection width), but can be approximated via spectral methods. Formalize the\n2-approximation: prove that the sweep-cut algorithm on the Fiedler vector produces\na set S with h(S) \u2264 \u221a(2\u03bb\u2082), where \u03bb\u2082 is the spectral gap.\n\nThe key insight is that `vertexBoundary` is already computable (defined via\nFinset.filter), so the Cheeger constant is computable by enumeration. The\napproximation algorithm would connect the spectral and combinatorial definitions\nin a constructive way.\n\nWhy now? All definitions in Cheeger.lean are computable (they use DecidableRel and\nFinset), so the exact computation is already possible. The approximation algorithm\nrequires only the Cheeger inequality from Direction 1.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_1041",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "45ebbcc6",
    "status": "available",
    "timestamp": "2026-06-09T01:20:48.932721+00:00",
    "title": "Formalize the discrete Cheeger inequality relating the vertex expansion constant"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the reverse-and-add algorithm applied to 196 never produces a palindrome. Formalize the concept of Lychrel numbers and establish structural properties of the iteration on digit sequences.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_007",
    "priority_score": 0.72,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:57.290512+00:00",
    "title": "196-Algorithm Non-Termination"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Arrow's impossibility theorem states that no ranked voting system with 3+ alternatives can be Pareto efficient, non-dictatorial, and independent of irrelevant alternatives (IIA). Conjecture: Arrow's theorem is a curvature statement. The space of preference profiles is a Riemannian manifold M with the Fisher information metric. The social welfare function F: M -> M is a mapping from profiles to social preferences. Arrow's conditions translate to geometric conditions: (1) Pareto efficiency means F preserves the direction of unanimous preference (F is 'forward-looking'). (2) IIA means F is a local mapping (the social preference at x depends only on local information near x). (3) Non-dictatorial means F is not a projection onto a single voter's preference. Conjecture: the only smooth, local, forward-looking maps on a positively curved manifold are projections (dictatorships). This is because a positively curved manifold has the property that parallel transport around a small loop rotates vectors (Holonomy), and a local, forward-looking map must preserve this holonomy, which forces it to be a projection. Conjecture: the curvature of the preference space is related to the 'polarization' of the electorate: when preferences are polarized (bimodal), the curvature is positive (sphere-like), and Arrow's theorem applies. When preferences are unimodal (consensus), the curvature is zero (flat), and majority rule works. Test: compute the curvature of the preference space for synthetic election data and verify the connection to Arrow's theorem. Impact: Arrow's impossibility is a theorem of differential geometry. Voting is curved.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0093",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.814374+00:00",
    "title": "The Geometry of Consensus: Arrow's Theorem as Curvature"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the lattice of cryptographic hardness assumptions: one-way functions \u2192 pseudorandom generators \u2192 pseudorandom functions \u2192 secure encryption. Prove separation results.",
    "domains": [
      "Cryptography",
      "Computation"
    ],
    "id": "fd_0434",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.080762+00:00",
    "title": "One-Way Functions: Existence and Hierarchy"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the hardness reduction from worst-case lattice problems (GapSVP, SIVP) to the Learning with Errors problem with specific parameters.",
    "domains": [
      "Cryptography",
      "Computation"
    ],
    "id": "fd_0435",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.156517+00:00",
    "title": "Learning with Errors: Hardness Reductions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the Learning With Errors (LWE) problem is as hard as worst-case lattice problems. Formalize the Regev reduction from GapSVP to LWE and prove that the resulting encryption scheme is IND-CPA secure under the LWE assumption.",
    "domains": [
      "Cryptography",
      "Computation"
    ],
    "id": "fd_0455",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.755100+00:00",
    "title": "Post-Quantum Lattice Cryptography: Formal Security Proofs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that any polynomial-time function can be securely computed in the presence of an honest majority. Formalize the GMW compiler and prove its universal composition property. Show that malicious security adds only polynomial overhead.",
    "domains": [
      "Cryptography",
      "Computation"
    ],
    "id": "fd_0460",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.154076+00:00",
    "title": "Secure Multi-Party Computation: Theoretical Foundations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove tighter generalization bounds for deep neural networks. Formalize PAC-Bayes bounds, compression-based bounds, and connect network architecture to sample complexity. Establish when overparameterized networks provably generalize.",
    "domains": [
      "MachineLearning",
      "Computation"
    ],
    "id": "fd_0477",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:44.806170+00:00",
    "title": "Machine Learning Generalization Bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that in the infinite-width limit, neural network training under gradient descent converges to kernel regression with the Neural Tangent Kernel (NTK). Formalize the NTK as the Gram matrix of Jacobians and prove it stays nearly constant during training for small learning rates.",
    "domains": [
      "MachineLearning",
      "Computation"
    ],
    "id": "fd_0499",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.466398+00:00",
    "title": "Neural Tangent Kernel: Convergence of Gradient Descent"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that policy gradient methods converge to a local optimum of the expected return. Formalize the policy gradient theorem and prove that REINFORCE is an unbiased estimator. Show that natural policy gradient converges faster by following the Fisher information geometry.",
    "domains": [
      "MachineLearning",
      "Computation"
    ],
    "id": "fd_0504",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.834984+00:00",
    "title": "Reinforcement Learning: Convergence of Policy Gradient Methods"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Learning With Errors (LWE) problem and prove its reduction from worst-case lattice problems (GapSVP). Show that the Regev encryption scheme is IND-CPA secure under LWE. Prove that key exchange based on LWE achieves forward secrecy. Compute concrete security parameters for 128-bit security.",
    "domains": [
      "Cryptography",
      "Computation"
    ],
    "id": "fd_0538",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.801510+00:00",
    "title": "Post-Quantum Cryptography: Lattice-Based Key Exchange"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that if one-way functions exist, then collision-resistant hash functions exist. Formalize the Merkle-Damgard construction and prove it preserves collision resistance. Show that SHA-256's compression function can be modeled as a random oracle under the indifferentiability framework.",
    "domains": [
      "Cryptography",
      "Computation"
    ],
    "id": "fd_0540",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.964548+00:00",
    "title": "Cryptographic Hash Functions: Collision Resistance from Hard Problems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the McEliece cryptosystem based on Goppa codes. Prove that decoding a random linear code is NP-hard (Berlekamp-McEliece-Tilborg). Show that distinguishing a Goppa code generator matrix from random is as hard as decoding. Compute parameters for 256-bit post-quantum security.",
    "domains": [
      "Cryptography",
      "Computation"
    ],
    "id": "fd_0544",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.295536+00:00",
    "title": "Code-Based Cryptography: McEliece from Goppa Codes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that depth-L ReLU networks of width (n+4) can approximate any continuous function on [-1,1]^n to epsilon accuracy. Show that the required width grows as O(epsilon^{-1/n}) for shallow networks but only O(log(1/epsilon)) for deep networks. Formalize the depth separation theorem: there exist functions representable by depth-L+1 networks of polynomial size that require exponential size in depth L.",
    "domains": [
      "MachineLearning",
      "Computation"
    ],
    "id": "fd_0555",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:08.217813+00:00",
    "title": "ML Universal Approximation: Width vs Depth Trade-offs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for overparameterized neural networks, almost all critical points are saddle points, not local minima. Formalize the Hessian spectrum at critical points. Show that the loss landscape satisfies the strict saddle property: the Hessian has a negative eigenvalue at non-minimum critical points. Prove that SGD escapes strict saddles in polynomial time.",
    "domains": [
      "MachineLearning",
      "Computation"
    ],
    "id": "fd_0558",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:08.465935+00:00",
    "title": "ML Loss Landscape: Critical Points and Saddle Points"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the policy gradient theorem: the gradient of the expected return equals E[psi(s,a) * Q^pi(s,a)] where psi is the score function. Prove that policy gradient methods converge to a local optimum under the compatible function approximation theorem. Show that the variance of the gradient estimate is O(1/epsilon) for epsilon-greedy exploration.",
    "domains": [
      "MachineLearning",
      "Computation"
    ],
    "id": "fd_0559",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:08.546271+00:00",
    "title": "ML Reinforcement Learning: Convergence of Policy Gradient Methods"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For large language models, the directed token-to-token influence graph induced during multi-step reasoning exhibits a model-size-independent spectral signature at the onset of correct chain-of-thought formation: specifically, after normalization by graph size, the top-k eigenvalue ratios and local spectral gap converge to a universal band across architectures, while failed or hallucinated reasoning trajectories do not. Test: Construct influence graphs from attention, activation patching, or causal mediation during benchmark reasoning tasks across multiple model families and scales; compute normalized spectra for correct vs incorrect trajectories. The conjecture is supported if a stable spectral band appears only for correct reasoning across architectures and scales, and refuted if no such cross-model spectral universality separates correct from incorrect traces. Impact: This would provide a mathematically grounded diagnostic for emergent reasoning, enable architecture-agnostic monitoring of reliable inference, and suggest new training objectives based on spectral control of internal computation.",
    "domains": [
      "Physics",
      "MachineLearning"
    ],
    "id": "fd_1020",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-06-08T19:03:53.866607+00:00",
    "title": "Spectral Universality of LLM Reasoning Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For a neural network loss landscape equipped with the Fisher information metric, the genus-zero Gromov-Witten invariants of the resulting symplectic manifold exactly count the number of distinct gradient-flow basins accessible by random initialization, and these invariants can be computed via mirror symmetry from a Landau-Ginzburg model dual to the dataset distribution. Test: Construct a family of small-scale fully connected networks (\u2264100 parameters) with controlled symmetries; compute the quantum cohomology and extract genus-zero GW invariants using symbolic methods (e.g., Givental's mirror theorem). Independently, perform >10,000 random-initialization gradient descents and cluster convergent points to count basins. A statistically significant match between the algebraic count and the empirical basin count confirms the conjecture; a systematic mismatch falsifies it. Impact: Transforms non-convex optimization into a problem in enumerative symplectic geometry; allows pre-training prediction of the number and nature of global minima from dataset topology alone; opens a bridge between mirror symmetry and machine learning theory.",
    "domains": [
      "Novelty",
      "MachineLearning"
    ],
    "id": "fd_1021",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-06-08T19:49:02.811963+00:00",
    "title": "Symplectic Mirror Descent: Gromov-Witten Invariants as a Count of Learnable Mini"
  },
  {
    "consumed_by_exp_id": "8eba50e4",
    "description": "Conjecture: There exists a concrete family of finite, physically realizable wave or quantum graphs whose measured resonance spectrum has nearest-neighbor spacing statistics that converge, under graph-size scaling, to a distribution that differs provably and experimentally from standard random-matrix universality classes if and only if the graph edge-length encoding contains arithmetic correlations equivalent to nontrivial prime-gap structure. Test: Build or simulate graph families with edge lengths determined by primes, randomized pseudo-primes, and correlation-destroyed controls; compute or measure spectral spacing distributions, spectral form factors, and trace-formula signatures. The conjecture is supported if prime-encoded families exhibit a reproducible, statistically significant spectral anomaly absent in controls and stable under perturbations; it is refuted if all such anomalies wash out into known universality classes or can be reproduced without arithmetic structure. Impact: This would create a new experimental bridge between analytic number theory and spectral physics, enabling laboratory probes of arithmetic correlations, new diagnostics for hidden number-theoretic structure in physical systems, and potentially new analog methods for exploring conjectures about primes.",
    "domains": [
      "Algebra",
      "Novelty"
    ],
    "id": "fd_1023",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "in_progress",
    "timestamp": "2026-06-08T20:04:56.522455+00:00",
    "title": "Prime Resonance Spectroscopy: Detecting Arithmetic Structure Through Physical Sp"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For sufficiently large formalized mathematics corpora, the normalized local eigenvalue spacing distribution of the directed proof-dependency graph Laplacian (or symmetrized adjacency operator) converges, after degree-corrected null-model normalization, to a universal random-matrix ensemble law (GOE/GUE-like) within mature theorem domains, while genuinely novel or foundationally incomplete domains exhibit statistically significant deviations from that law. Test: Build proof graphs from large theorem libraries (e.g. Lean, Coq, Isabelle), compute spectra of dependency operators on domain-specific subgraphs, compare unfolded spacing statistics and eigenvector localization against random-matrix and null-model predictions, and check whether newly developing areas systematically show out-of-universality deviations that later disappear as the area matures. The conjecture is refuted if no cross-library universality appears, or if deviations fail to correlate with independent measures of mathematical novelty or incompleteness. Impact: This would create a quantitative physics-style order parameter for the maturity, coherence, and frontier status of mathematical theories, enabling automated discovery of under-axiomatized regions, prediction of fruitful theorem-generation targets, and a new bridge between random matrix theory, knowledge representation, and automated reasoning.",
    "domains": [
      "Physics",
      "Novelty"
    ],
    "id": "fd_1040",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-06-09T00:45:11.727663+00:00",
    "title": "Spectral Universality of Theorem Spaces: Random-Matrix Statistics in Formal Proo"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that 10 is a solitary number \u2014 no other integer shares its abundancy index \u03c3(n)/n. Formalize the theory of friendly numbers and abundancy, connecting to the distribution of divisor sums.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_008",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-08T19:24:57.516415+00:00",
    "title": "10 is a Solitary Number"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A periodic rhythm in music is a function f: Z -> {0, 1} that is periodic: f(n + p) = f(n) for some period p. The symmetry group of a rhythm with period p is a subgroup of Z/pZ. But music also has 2D patterns: a drum pattern is a function g: Z x Z -> {0, 1} (onset grid in time x pitch). The symmetry group of a drum pattern is a subgroup of Z x Z, which is a wallpaper group in 1D. In 2D, the wallpaper groups classify all possible symmetries of periodic patterns. There are exactly 17 wallpaper groups in 2D. Conjecture: the 17 wallpaper groups correspond to 17 fundamentally different types of rhythmic structure in music. Specifically: (1) p1: no symmetry (free rhythm), (2) p2: 2-fold rotational symmetry (call-and-response), (3) pm: mirror symmetry (palindrome), (4) pg: glide reflection (canon), (5) cm: mirror + glide (round), (6) pmm: double mirror (bilateral palindrome), (7) pmg: mirror + glide (inverted canon), (8) pgg: double glide (double canon), (9) cmm: double mirror + glide (round + palindrome), (10) p4: 4-fold rotation (4-bar cycle), (11) p4m: 4-fold + mirrors (variations on a theme), (12) p4g: 4-fold + glides (inverted variations), (13) p3: 3-fold rotation (3-bar blues), (14) p3m1: 3-fold + mirrors, (15) p31m: 3-fold + glides, (16) p6: 6-fold rotation (whole-tone scale symmetry), (17) p6m: 6-fold + mirrors (maximal symmetry, the 'perfect' rhythm). Test: classify 1000 drum patterns by their wallpaper group and verify the distribution matches musical practice. Impact: there are exactly 17 types of rhythm in music, classified by the wallpaper groups.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0070",
    "priority_score": 0.68,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.681497+00:00",
    "title": "Crystallographic Groups and Music: The 17 Wallpaper Groups of Rhythm"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Computational Complexity as Physical Law\n\n## Synthesis\n\nThis research cycle established the **Entropy-Bounded Computation (EBC)** framework, which formalizes the connection between computational complexity and thermodynamics through Landauer's principle. The central result is the **entropy gap theorem**: the thermodynamic cost gap between polynomial and exponential search grows without bound, providing a physical interpretation of the P \u2260 NP conjecture. The framework consists of five interconnected structures (EntropyBudgetSystem, MaxwellDemon, ReversibleComputation, IrreversibleStep, ComplexityEntropyDuality) with 13 formally verified theorems.\n\nThe most promising cross-domain connection is between the **Maxwell's demon bound** (from the Shared/CryptoEntropyBridges catalog) and **computational search complexity**. Our demon composition theorem shows that thermodynamic irreversibility composes additively across computational agents, which connects to both cryptographic security (breaking keys requires entropy proportional to key length) and the polynomial hierarchy (each level requires strictly more entropy). The entropy gap theorem provides the mathematical foundation for a physically-grounded complexity theory.\n\nThe highest breakthrough potential lies in **Direction 1 (Quantum Entropy Budget)**: quantum computation is fundamentally reversible except for measurement, suggesting that the EBC framework should yield tighter bounds for quantum complexity classes. If the quantum extension shows that BQP has a different entropy profile than P, it would provide a new approach to the BQP vs. P question \u2014 one grounded in physics rather than pure combinatorics.\n\n---\n\n### Direction 1: Quantum Entropy Budget and the Measurement Bottleneck\n\n**Conjecture**: In a quantum extension of the EBC framework, the entropy cost of a quantum computation is determined entirely by the number of measurements, not the number of unitary gates. Formally: for a quantum circuit with U unitary gates and M measurements, the total Landauer cost is exactly M \u00b7 kT \u00b7 ln(2), independent of U. This implies that BQP computations with polynomially many measurements have polynomial entropy cost, while QMA-hard problems require exponentially many measurements under standard complexity assumptions.\n\n**Test**: \n1. Formalize a `QuantumEntropyBudgetSystem` where steps are either unitary (cost 0) or measurement (cost kT\u00b7ln(2)).\n2. Prove that the total cost equals the measurement count times the Landauer unit.\n3. Implement Grover's algorithm and Shor's algorithm in the framework and compute their entropy costs.\n4. Compare: Grover uses O(\u221aN) measurements, Shor uses O(n\u00b2) measurements. Check whether these match empirical predictions.\n\n**Impact**: If true, this gives a clean physical characterization of quantum advantage: quantum computers are powerful not because they compute differently, but because they defer entropy production until measurement. This would connect BQP to a physical resource (measurement budget) rather than an abstract computational model. If false, it reveals that quantum coherence has hidden entropy costs, challenging the deferred measurement principle.\n\n**Catalog References**: `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound), `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget, reversible_comp_is_id)\n\n**Proof Strategy**: \n1. Define `QuantumStep` as either `Unitary (cost = 0)` or `Measurement (cost = kT\u00b7ln(2))`.\n2. Prove cost additivity via the existing demon_composition_cost pattern.\n3. For the measurement bottleneck theorem, show that any quantum circuit can be rearranged (by the deferred measurement principle) to have all measurements at the end, concentrating all entropy cost.\n4. Connect to BQP by bounding the measurement count for polynomial-time quantum algorithms.\n\n**Domain Bridges**: Computation (entropy budget) \u2194 Physics (quantum measurement) \u2194 Cryptography (post-quantum security)\n\n**Lineage**: Builds on entropy_gap_unbounded, step_count_bounded_by_budget, reversible_comp_is_id from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Entropy Complexity Classes and the Thermodynamic Polynomial Hierarchy\n\n**Conjecture**: Define ENTROPY(f(n)) as the class of problems solvable with total Landauer cost at most f(n) \u00b7 kT \u00b7 ln(2). Then:\n1. P \u2286 ENTROPY(n^c) for some constant c depending on the problem.\n2. NP \u2286 ENTROPY(2^n) but NP \u2284 ENTROPY(n^c) for any c (assuming P \u2260 NP).\n3. The entropy hierarchy ENTROPY(n) \u228a ENTROPY(n\u00b2) \u228a ENTROPY(n\u00b3) \u228a ... is strict.\n4. ENTROPY(log n) = L (logarithmic space).\n\nPart (3) is the most surprising claim: it asserts that entropy complexity has no \"speed-up\" theorem \u2014 you cannot simulate n\u00b2 entropy with n entropy, even approximately.\n\n**Test**:\n1. Formalize ENTROPY(f) as a complexity class within the EBC framework.\n2. Prove the containments P \u2286 ENTROPY(n^c) by analyzing standard algorithms.\n3. For part (3), attempt to prove a hierarchy theorem using diagonalization.\n4. Test computationally: implement sorting algorithms (merge sort vs. bubble sort) and measure their actual Landauer costs. Merge sort should use O(n log n) entropy; bubble sort O(n\u00b2).\n\n**Impact**: If the entropy hierarchy is strict, it provides a new complexity hierarchy that is *physically meaningful* \u2014 each level corresponds to a different thermodynamic regime. This would be the first complexity hierarchy with a direct physical interpretation. If not strict, it means entropy can be \"recycled\" in unexpected ways.\n\n**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (entropy_budget_monotone, entropy_gap_unbounded), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)\n\n**Proof Strategy**: \n1. Define ENTROPY(f) formally as `{L | \u2203 EBS with budget = f(n) that decides L}`.\n2. For P \u2286 ENTROPY(n^c): any P algorithm makes poly(n) steps, each costing at most 1 bit.\n3. For hierarchy strictness: adapt the time hierarchy theorem proof, using the entropy gap theorem to show that more entropy budget allows solving strictly more problems.\n4. The diagonalization argument: construct a language L_k that can be decided with n^(k+1) entropy but not n^k entropy.\n\n**Domain Bridges**: Computation (complexity classes) \u2194 Physics (entropy budget) \u2194 Logic (hierarchy theorems)\n\n**Lineage**: Directly extends entropy_budget_monotone and entropy_gap_unbounded.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Landauer Cost of Specific Algorithms\n\n**Conjecture**: The Landauer cost of comparison-based sorting of n elements is exactly \u2308log\u2082(n!)\u2309 \u00b7 kT \u00b7 ln(2), matching the information-theoretic lower bound. Any sorting algorithm that uses fewer comparisons than \u2308log\u2082(n!)\u2309 must use non-comparison operations that cost additional entropy. In other words, the Landauer cost provides an independent proof of the \u03a9(n log n) comparison-based sorting lower bound.\n\n**Test**:\n1. Formalize comparison-based sorting in the EBC framework, where each comparison is an IrreversibleStep that halves the search space.\n2. Prove that \u2308log\u2082(n!)\u2309 comparisons are necessary via the entropy budget.\n3. Implement merge sort and quicksort in the framework and verify their entropy costs match the theoretical predictions.\n4. Check boundary case: for n = 1, cost should be 0; for n = 2, cost should be kT\u00b7ln(2).\n\n**Impact**: This would be the first formally verified proof that the sorting lower bound is a *physical law*, not just an information-theoretic bound. It demonstrates that the EBC framework can recover known complexity bounds from thermodynamic principles.\n\n**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (IrreversibleStep, landauerCost), `Speculative/ComplexityPhysics/Theorems.lean` (one_bit_erasure_cost, step_count_bounded_by_budget)\n\n**Proof Strategy**:\n1. Model a comparison as an IrreversibleStep from Fin(n!) (permutation space) to two halves.\n2. After k comparisons, the remaining search space has size at most n!/2^k.\n3. The search terminates when the space has size 1, requiring k \u2265 log\u2082(n!).\n4. Each comparison costs kT\u00b7ln(2) by one_bit_erasure_cost, giving total cost \u2265 \u2308log\u2082(n!)\u2309 \u00b7 kT\u00b7ln(2).\n\n**Domain Bridges**: Computation (sorting algorithms) \u2194 Physics (Landauer cost) \u2194 EML (information theory)\n\n**Lineage**: Builds on IrreversibleStep, one_bit_erasure_cost, step_count_bounded_by_budget.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Reversible Computing and Bennett's Pebble Game\n\n**Conjecture**: In the EBC framework, any irreversible computation of T steps on S space can be made reversible using O(T \u00b7 S) time and O(S \u00b7 log T) space (Bennett's result). Formalizing this in the EBC framework gives: the entropy cost of simulating an irreversible computation reversibly is exactly 0, but the time overhead is multiplicative. This creates a time-entropy tradeoff: you can eliminate entropy cost entirely at the price of a polynomial time increase.\n\n**Test**:\n1. Formalize Bennett's pebble game in Lean as a ReversibleComputation.\n2. Prove that the reversible simulation has zero Landauer cost (using reversible_comp_is_id).\n3. Prove the time overhead bound: the reversible simulation takes O(T \u00b7 S) steps.\n4. Test: implement a reversible AND gate using Toffoli gates and verify zero entropy cost.\n\n**Impact**: This direction explores the *escape hatch* from the entropy budget: reversible computing avoids Landauer costs but pays in time. The time-entropy tradeoff is fundamental to understanding whether thermodynamics truly constrains complexity or merely introduces overhead.\n\n**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (ReversibleComputation), `Speculative/ComplexityPhysics/Theorems.lean` (reversible_comp_is_id, reversible_involution)\n\n**Proof Strategy**:\n1. Define a `PebbleGame` structure modeling Bennett's construction.\n2. Show the pebble game produces a ReversibleComputation.\n3. Count the number of pebbling steps to get the time bound.\n4. Use reversible_comp_is_id to show zero entropy cost.\n\n**Domain Bridges**: Computation (reversible circuits) \u2194 Physics (entropy-free computation) \u2194 Cryptography (side-channel resistance)\n\n**Lineage**: Extends reversible_comp_is_id and ReversibleComputation.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Entropy Production Rate and Computational Speed Limits\n\n**Conjecture**: There exists a fundamental speed limit on computation analogous to the Margolus-Levitin bound: no physical system can perform more than 2E/(\u03c0\u210f) irreversible operations per second, where E is the system's energy above ground state. Combined with the Landauer cost per operation, this gives a maximum computational throughput of 2E/(\u03c0\u210f \u00b7 kT \u00b7 ln 2) irreversible bits per second. For a 1-watt computer at room temperature, this is approximately 4.4 \u00d7 10\u00b3\u00b9 bit operations per second.\n\n**Test**:\n1. Formalize the Margolus-Levitin bound as an axiom in the EBC framework.\n2. Derive the maximum bit rate from the bound and Landauer's principle.\n3. Compute the maximum bit rate for realistic parameters (1W, 300K, 1 kg).\n4. Compare with actual computer performance (modern CPUs achieve ~10\u00b9\u2070 ops/sec, far below the limit).\n\n**Impact**: This connects the EBC framework to quantum mechanics (Margolus-Levitin) and gives absolute physical limits on computation. The gap between current computers and the physical limit (~10\u00b2\u00b9 factor) suggests enormous room for improvement in computational efficiency.\n\n**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget), `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound)\n\n**Proof Strategy**:\n1. Introduce the Margolus-Levitin bound as a parameter in EntropyBudgetSystem.\n2. Derive budget = (2E \u00b7 \u03c4) / (\u03c0\u210f \u00b7 kT \u00b7 ln 2) from the bound.\n3. Apply step_count_bounded_by_budget with c = kT\u00b7ln(2).\n4. Compute explicit values for standard physical parameters.\n\n**Domain Bridges**: Physics (quantum speed limits) \u2194 Computation (throughput bounds) \u2194 EML (information rates)\n\n**Lineage**: Builds on step_count_bounded_by_budget and the full EBC framework.\n\n**Ambition**: extension\n",
    "domains": [
      "Computation",
      "Physics"
    ],
    "id": "fd_0917",
    "priority_score": 0.6,
    "research_mode": "team",
    "source_exp_id": "2d7514a5",
    "status": "available",
    "timestamp": "2026-06-07T07:20:19.455139+00:00",
    "title": "**Entropy-Bounded Computation (EBC)** framew"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Use inverse stereographic projection S^n -> R^n as a cryptographic primitive. The forward map (point on sphere to plane) is easy, but recovering the original point from the plane projection requires the pole parameter. Conjecture: Finding the pole of stereographic projection from only (image set, projection point) is as hard as the shortest vector problem in a lattice. Test: formalize the reduction from SVP to pole-finding for n=2. Impact: a new geometric foundation for lattice-based cryptography.",
    "domains": [
      "Geometry",
      "Cryptography"
    ],
    "id": "fd_0419",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.828631+00:00",
    "title": "Inverse Stereographic Cryptography: Projection as One-Way Function"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Replace softmax attention with stereographic attention: map query/key vectors to the Riemann sphere via stereographic projection, compute Cauchy kernel K(q,k) = 1/(1+|q-k|^2) on the sphere, and project back. Conjecture: Stereographic attention has O(sqrt(N)) sparsity (most Cauchy weights are near-zero) while maintaining the universal approximation properties of softmax attention. Test: prove the sparsity bound for random queries on the unit sphere. Impact: a new attention mechanism with built-in sparsity and geometric structure.",
    "domains": [
      "Geometry",
      "MachineLearning"
    ],
    "id": "fd_0420",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.906315+00:00",
    "title": "Stereographic Neural Attention: Attention via Riemann Sphere"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Neural field equations model macroscopic brain dynamics as PDEs on cortical surfaces. The cortical surface is topologically a sphere with cortical folds. Use inverse stereographic projection to transform neural field PDEs on S^2 into PDEs on R^2 with a conformal weight. Define a stereographic neural field as a function u: S^n to R satisfying Delta_{S^n} u = f(u) where Delta_{S^n} is the Laplace-Beltrami operator on the sphere. Under inverse stereographic projection, this becomes a PDE on R^n with a conformally modified Laplacian. Conjecture: The neural field equation on S^2 with Mexican-hat connectivity has exactly 2N+1 stable pattern solutions for interaction radius r, where N = floor(1/r). Under inverse stereographic projection, these correspond to N-fold symmetric patterns on R^2 that decay at infinity. The 2N+1 count comes from the representation theory of SO(3): each pattern of degree l has 2l+1 rotational variants, and the Mexican-hat kernel selects l = N. Test: prove the existence of 2N+1 patterns for r = 1/k (k=1,2,3) by constructing them as stereographic projections of spherical harmonics. Impact: a geometric theory of neural pattern formation with provable pattern counts, enabling predictions about visual hallucination patterns.",
    "domains": [
      "Geometry",
      "MachineLearning"
    ],
    "id": "fd_0424",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.226650+00:00",
    "title": "Inverse Stereographic Neural Field Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that neural network training is a renormalization group (RG) flow in function space. Each training step integrates out high-frequency modes (gradient descent on fast-varying parameters), just as each RG step integrates out short-distance modes. Conjecture: The fixed points of SGD on neural networks are precisely the critical points of a renormalization group flow defined by the coarse-graining operator that averages over parameter subsets. Why now: recent work on neural network Gaussian processes shows that infinite-width networks have exact RG fixed points, and the beta function of SGD training has been computed for linear networks. Test: prove that for a 2-layer ReLU network trained on isotropic data, the SGD fixed point corresponds to the Wilson-Fisher fixed point in d=2 dimensions, and compute the critical exponents. Impact: neural network training would be governed by universality classes, meaning the same network trained on different data converges to the same fixed point if the data distribution is in the same universality class.",
    "domains": [
      "MachineLearning",
      "Physics"
    ],
    "id": "fd_0427",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.476683+00:00",
    "title": "Neural Network Training as Renormalization Group Flow"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The key insight is that the Collatz map T(n) = n/2 if n even, 3n+1 if n odd, appears to be a one-way function: easy to compute forward (polynomial time), intractable to invert (finding a preimage requires exponential search). Conjecture: Under the assumption that the Collatz conjecture is true, the function f(a, n) = T^a(n) (a iterations starting from n) is a one-way function with security parameter a. The inversion problem \u2014 given (a, f(a,n)), find n \u2014 requires O(2^{a/log(a)}) steps. Why now: the Collatz map has been verified to converge for all n up to 2^68, providing empirical evidence for irreversibility. Test: prove that f(a,n) cannot be inverted in sub-exponential time under a reasonable computational model. Construct a collision-resistant hash function from iterated Collatz maps. Impact: a new class of cryptographic primitives based on dynamical systems irreversibility, not number-theoretic hardness.",
    "domains": [
      "Cryptography",
      "Algebra"
    ],
    "id": "fd_0428",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.563504+00:00",
    "title": "Cryptography from the Collatz Conjecture: One-Way Functions from Iterated Maps"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Develop a large deviation principle for max-plus probability measures. Prove that max-plus random walks satisfy an LDP with rate function given by the Legendre-Fenchel transform.",
    "domains": [
      "Tropical",
      "Computation"
    ],
    "id": "fd_0439",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.479969+00:00",
    "title": "Idempotent Probability: Large Deviations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize grokking: prove a delayed generalization theorem for two-layer networks and characterize the phase transition as a saddle-node bifurcation.",
    "domains": [
      "MachineLearning",
      "Physics"
    ],
    "id": "fd_0440",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.560336+00:00",
    "title": "Grokking: Phase Transitions in Learning"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove neural network scaling laws from first principles. Derive power-law relationships between loss, model size, dataset size, and compute from the GP kernel spectrum.",
    "domains": [
      "MachineLearning",
      "Physics"
    ],
    "id": "fd_0441",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.640557+00:00",
    "title": "Scaling Laws from Statistical Mechanics"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the sharp entropy power inequality for all dimensions with equality conditions. Connect to the Brunn-Minkowski inequality and prove stability versions.",
    "domains": [
      "Bridges",
      "Computation"
    ],
    "id": "fd_0445",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.970178+00:00",
    "title": "Entropy Power Inequality: Sharp Version"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Joyal's combinatorial species as endofunctors on the category of finite sets. Prove that the exponential generating function of a species equals its analytic functor. Bridge enumerative combinatorics to category theory and analytic combinatorics.",
    "domains": [
      "Bridges",
      "Computation"
    ],
    "id": "fd_0450",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.353451+00:00",
    "title": "Combinatorial-Categorical Bridge: Species of Structures as Functors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Develop a tropical scheme theory where ideals are replaced by tropical ideals (subsemimodules of the tropical polynomial semiring closed under tropical linear combinations). Prove a tropical Buchberger algorithm exists and characterize tropical Groebner bases.",
    "domains": [
      "Tropical",
      "Computation"
    ],
    "id": "fd_0472",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:31.138945+00:00",
    "title": "Tropical Scheme Theory: Groebner Bases over the Tropical Semiring"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the Bergman fan of a matroid M equals the tropical linear space of the matroid's circuit ideal. Formalize the connection between matroid connectivity and the topology of the Bergman fan. Show that nested matroids give tropical linear subspaces.",
    "domains": [
      "Tropical",
      "Computation"
    ],
    "id": "fd_0473",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:31.219688+00:00",
    "title": "Tropical Matroid Theory: Bergman Fans and Tropical Linear Spaces"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize diffusion models as solutions to stochastic differential equations. Prove that the reverse-time SDE recovers the data distribution when the forward process is Ornstein-Uhlenbeck. Derive the Fokker-Planck equation for the marginal distributions and prove convergence to the stationary distribution.",
    "domains": [
      "MachineLearning",
      "Physics"
    ],
    "id": "fd_0502",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.684855+00:00",
    "title": "Diffusion Models as Stochastic Differential Equations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Fourier transform as a natural transformation between the category of locally compact abelian groups and the category of their dual groups. Prove Pontryagin duality as an equivalence of categories. Show that the uncertainty principle is a categorical statement: the functor Hom(-,R/Z) is contravariant.",
    "domains": [
      "Bridges",
      "Computation"
    ],
    "id": "fd_0529",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.047788+00:00",
    "title": "Bridge: Fourier Analysis as a Functor"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Weil pairing on an elliptic curve and prove its bilinearity. Show that the BLS signature scheme is existentially unforgeable under the computational Diffie-Hellman assumption in the pairing group. Prove that the pairing allows short aggregate signatures.",
    "domains": [
      "Cryptography",
      "Algebra"
    ],
    "id": "fd_0541",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.042519+00:00",
    "title": "Elliptic Curve Cryptography: Weil Pairing and BLS Signatures"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that Shamir's secret sharing scheme is information-theoretically secure: any t-1 shares reveal zero information about the secret. Formalize Feldman's verifiable secret sharing and prove that cheating dealers are caught. Show that the reconstruction threshold equals the degree of the polynomial plus one.",
    "domains": [
      "Cryptography",
      "Algebra"
    ],
    "id": "fd_0542",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.126580+00:00",
    "title": "Secret Sharing: Shamir's Scheme and Verifiable Variants"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the BB84 protocol and prove its unconditional security against arbitrary quantum attacks. Show that the quantum bit error rate threshold for secure key distillation is approximately 11%. Prove that privacy amplification via universal hashing reduces Eve's information to exponentially small.",
    "domains": [
      "Cryptography",
      "Physics"
    ],
    "id": "fd_0543",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.214033+00:00",
    "title": "Quantum Key Distribution: BB84 Security Proof"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize tropical differential equations as constraints on the valuation of power series. Prove the tropical fundamental theorem of differential algebra: the tropicalization of a differential ideal equals the tropical differential ideal of the tropicalization. Show that tropical solutions provide lower bounds on the growth of classical solutions.",
    "domains": [
      "Tropical",
      "Computation"
    ],
    "id": "fd_0547",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.541008+00:00",
    "title": "Tropical Differential Equations: Power Series Solutions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the attention mechanism A(Q,K,V) = softmax(QK^T / sqrt(d_k)) V. Prove that permutation-equivariant attention is a universal approximator of permutation-equivariant functions. Show that the attention kernel K(x,y) = exp(q(x)^T k(y) / sqrt(d)) defines a reproducing kernel Hilbert space. Prove that multi-head attention increases the rank of the attention matrix.",
    "domains": [
      "MachineLearning",
      "Algebra"
    ],
    "id": "fd_0557",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:08.377996+00:00",
    "title": "ML Attention Mechanism: Formal Properties of Transformers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For natural families of randomly generated first-order axiom systems with bounded symbol complexity and a fixed theorem schema \u03c6_n, there exists a nontrivial critical clause-density parameter c* such that the probability that \u03c6_n has a proof of length polynomial in n exhibits a sharp threshold at c* as n \u2192 \u221e. Test: Define an ensemble of random formal theories (for example, random Horn, equational, or bounded-quantifier axiom sets), fix theorem families \u03c6_n, and empirically/theoretically measure whether short-provability transitions from asymptotically unlikely to asymptotically likely within a vanishing-width window around some c*. The conjecture is refuted if no sharp threshold appears across robust ensembles or if the transition width remains extensive. Impact: Establishes a statistical-mechanics theory of provability, giving predictive tools for theorem-prover difficulty, phase diagrams for automated reasoning, and new links between proof complexity, random structures, and computational hardness.",
    "domains": [
      "Logic",
      "Novelty"
    ],
    "id": "fd_1019",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-06-08T17:35:06.197627+00:00",
    "title": "Proof Phase Transitions: Sharp Thresholds in Random Formal Theories"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n## Synthesis\n\nThis research cycle established rigorous formal foundations for the Collatz conjecture's proof-theoretic analysis. The key results \u2014 parity exclusion, density contraction, odd density bounds, and orbit merge \u2014 form a coherent picture of why the conjecture is hard: local contraction is guaranteed by combinatorial constraints, but global contraction requires bounding growth phases that depend unpredictably on the input.\n\nThe most promising cross-domain connection is between the **Generalized Collatz System (GCS) framework** and the **computational universality** results in the Catalog's `Computation/` directory. Conway's theorem that GCS families are Turing-complete connects directly to the oracle and computability structures in `Computation/GravityOracle.lean` and `Computation/InfoEfficientAlgorithms.lean`. The GCS encoding notion defined in this cycle could bridge dynamical systems (Algebra) with computability theory (Computation), creating a formal pathway from specific Collatz dynamics to proof-theoretic independence.\n\nThe direction with highest breakthrough potential is Direction 1 (Sharp Contraction Threshold), because it would close the gap between our sufficient condition (odd density < 1/2) and the necessary condition (odd density < log\u20823) using only real-number arithmetic already available in Mathlib. This would be the tightest known formal bound on Collatz contraction, directly useful for any future proof attempt.\n\n---\n\n### Direction 1: Sharp Contraction Threshold via Real Logarithms\n\n**Conjecture**: For any Collatz orbit of length k with j odd steps, if j/k < log(2)/log(3), then the orbit segment contracts (the end value is less than the start value for sufficiently large starting values). Specifically: for all \u03b5 > 0, there exists N\u2080 such that if n \u2265 N\u2080 and j/k < log(2)/log(3) - \u03b5, then T^k(n) < n.\n\n**Test**: Formalize the real-valued inequality log(3)/log(2) \u00b7 j < k - j in Lean 4 using Mathlib's `Real.log`. Prove that this implies 3^j < 2^(k-j) using `Real.rpow_lt_rpow` and related lemmas. Verify computationally for k = 100, j = 62 (which is below the threshold) vs j = 64 (above).\n\n**Impact**: This would give the sharpest possible formal contraction criterion, replacing our current sufficient condition (2j < k, i.e., density < 1/2) with the optimal threshold (density < log\u2082(2)/log\u2082(3) \u2248 0.6309). Any future proof of Collatz via density arguments would need this bound.\n\n**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (pow3_lt_pow2_double, density_contraction), `Catalog/Algebra/ParityCylinders.lean` (isDescentWord)\n\n**Proof Strategy**: \n1. Define the real-valued contraction condition: `j * Real.log 3 < (k - j) * Real.log 2`.\n2. Show equivalence with `(3 : \u211d)^j < (2 : \u211d)^(k-j)` using `Real.exp_log` and monotonicity.\n3. Transfer to natural numbers: `(3 : \u211d)^j < (2 : \u211d)^(k-j)` implies `3^j < 2^(k-j)` in \u2115 using `Nat.cast_lt`.\n4. Apply to the orbit affine bound to get the contraction result.\n\n**Domain Bridges**: Algebra (parity word theory) <-> Analysis (real logarithms) <-> Computation (contraction verification)\n\n**Lineage**: Builds on `pow3_lt_pow2_double` and `density_contraction` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 2: Collatz Orbit Encoding of Finite Automata\n\n**Conjecture**: For every deterministic finite automaton (DFA) with n states, there exists a Generalized Collatz System with modulus m = O(n!) that simulates the DFA's computation. Specifically, the GCS can be constructed so that its residue-class dynamics on a set of n distinguished values exactly mirrors the DFA's state transitions.\n\n**Test**: Construct explicit GCS encodings for small DFAs (2-state, 3-state) and verify in Lean that the GCS dynamics on the embedded states matches the DFA transitions. Then prove the general construction for arbitrary n-state DFAs.\n\n**Impact**: This would be a concrete, constructive version of Conway's universality theorem, restricted to finite automata. It would establish the precise modulus needed for encoding, which is relevant to understanding whether the standard Collatz modulus (m = 2) has any encoding power.\n\n**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (GCS, GCS.Encodes, FiniteTransition), `Catalog/Computation/InfoEfficientAlgorithms.lean` (BSState)\n\n**Proof Strategy**:\n1. Define DFA as a `FiniteTransition` with input alphabet.\n2. Use Chinese Remainder Theorem to construct residue classes that separate states.\n3. Define affine rules that map each state's residue class to the successor state's class.\n4. Prove the divisibility condition using CRT.\n5. Verify the encoding property.\n\n**Domain Bridges**: Algebra (GCS framework) <-> Computation (finite automata, Turing completeness) <-> Cryptography (CRT constructions)\n\n**Lineage**: Builds on GCS and FiniteTransition definitions from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Transfinite Orbit Measures and Goodstein Analogy\n\n**Conjecture**: There exists an ordinal-valued measure \u03bc : \u2115 \u2192 Ordinal (below \u03b5\u2080) such that for all n \u2265 2, \u03bc(T(n)) < \u03bc(n) in the standard Collatz map. If such a measure exists, the Collatz conjecture follows by transfinite induction, but the measure itself may require principles beyond PA (analogous to Goodstein's theorem).\n\n**Test**: Define candidate measures combining stopping time, peak value, and bit-length. Test whether \u03bc(T(n)) < \u03bc(n) for n \u2264 10^6. The measure \u03bc(n) = \u03c9^(bit-length(n)) \u00b7 (n mod 2^k) + lower-order terms is a natural starting point.\n\n**Impact**: If a sub-\u03b5\u2080 measure works, it would prove the Collatz conjecture using transfinite induction up to \u03b5\u2080 (which is the proof-theoretic ordinal of PA). This would simultaneously prove Collatz and show it's provable in PA + transfinite induction, placing it at the same logical level as Goodstein's theorem. If no sub-\u03b5\u2080 measure works, it would be strong evidence for independence from PA.\n\n**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, peakValue, ComplexityClass), `Catalog/Logic/` (ordinal theory if available)\n\n**Proof Strategy**:\n1. Define ordinal-valued measures on \u2115 using Cantor Normal Form.\n2. Show that even steps decrease the measure (easy: bit-length decreases).\n3. Show that odd steps increase bit-length by at most 1 but decrease a secondary component.\n4. The challenge is finding a measure where the odd-step increase is compensated by subsequent even steps \u2014 this is where the parity exclusion theorem is crucial.\n\n**Domain Bridges**: Algebra (Collatz dynamics) <-> Logic (ordinal arithmetic, proof theory) <-> Computation (well-founded recursion)\n\n**Lineage**: Builds on ComplexityClass and stoppingTime from this cycle, and the parity exclusion theorem.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Spectral Analysis of Parity Words\n\n**Conjecture**: The discrete Fourier transform of the parity word of a Collatz orbit of length k has spectral energy concentrated at frequency 1/2 (reflecting the parity exclusion alternation). Specifically, the spectral coefficient at frequency 1/2 satisfies |\u0109(1/2)| \u2265 c\u00b7\u221ak for some universal constant c > 0, and this spectral concentration is equivalent to the contraction property.\n\n**Test**: Compute the DFT of parity words for orbits starting at n = 27 (a famously long orbit with 111 steps). Check whether the spectral peak at frequency 1/2 dominates. Compare with random binary words satisfying the no-consecutive-ones constraint.\n\n**Impact**: A spectral characterization of contraction would connect Collatz dynamics to harmonic analysis, potentially enabling tools from analytic number theory (e.g., exponential sum estimates) to attack the conjecture. This bridges the combinatorial parity-word approach with the Fourier-analytic approach of Tao (2019).\n\n**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (orbitParity, oddSteps_le_half), `Catalog/MachineLearning/CollatzSpectral/` (existing spectral framework), `Catalog/Algebra/ParityCylinders.lean` (parityWord)\n\n**Proof Strategy**:\n1. Define the DFT on ParityWord: \u0109(f) = \u03a3 w(i) \u00b7 exp(2\u03c0i\u00b7f\u00b7i/k).\n2. Use parity exclusion to show the alternating component is large.\n3. Connect spectral energy to oddSteps/evenSteps ratio.\n4. Prove that spectral concentration at f=1/2 implies the contraction bound.\n\n**Domain Bridges**: Algebra (parity words) <-> Analysis (Fourier transform) <-> MachineLearning (spectral Collatz framework)\n\n**Lineage**: Builds on orbitParity and oddSteps_le_half from this cycle; connects to `CollatzSpectral/` in the Catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Computational Lower Bounds on Collatz Independence\n\n**Conjecture**: If the Collatz conjecture is independent of PA, then for infinitely many n, the stopping time of n exceeds any primitive recursive function of n. Conversely, if all stopping times are bounded by a fixed primitive recursive function, then the conjecture is provable in PA.\n\n**Test**: Formalize the equivalence between \"Collatz stopping times are primitive-recursively bounded\" and \"Collatz is provable in PA\" using the connection between provably total functions and proof-theoretic ordinals. Test computationally: check whether stopping times for n \u2264 10^8 exceed n^(log log n), which is a candidate super-polynomial but sub-primitive-recursive bound.\n\n**Impact**: This would give a precise computational criterion for independence: either stopping times are \"tame\" (primitive-recursively bounded) and the conjecture is provable, or they are \"wild\" (eventually exceeding any primitive recursive function) and the conjecture is independent. This transforms a metamathematical question into a concrete computational one.\n\n**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, ComplexityClass, CollatzIndependenceConjecture), `Catalog/Computation/PadicValuationDepth.lean` (depth measures)\n\n**Proof Strategy**:\n1. Formalize the concept of a \"provably total function\" in a proof system.\n2. Show that if Collatz is provable in PA, then its stopping-time function is provably total in PA.\n3. By the characterization of provably total functions of PA (those bounded by functions in the fast-growing hierarchy below \u03b5\u2080), this gives a concrete bound.\n4. Conversely, show that a primitive recursive bound on stopping times yields a PA proof.\n\n**Domain Bridges**: Algebra (Collatz dynamics) <-> Computation (primitive recursion, fast-growing hierarchy) <-> Logic (proof-theoretic ordinals)\n\n**Lineage**: Builds on stoppingTime and CollatzIndependenceConjecture from this cycle.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "fd_0526",
    "priority_score": 0.5,
    "research_mode": "team",
    "source_exp_id": "c376d672",
    "status": "available",
    "timestamp": "2026-06-03T21:58:15.194222+00:00",
    "title": "Rigorous formal foundations for the Collatz conj"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Holographic Verification of Proofs\n\n## Synthesis\n\nThis research cycle established a rigorous formal framework for holographic proof verification, proving that tree-structured proofs of size n admit deterministic verification certificates of length O(log n) via Merkle authentication paths. The key results \u2014 verification correctness, certificate separation under collision resistance, and a tight information-theoretic lower bound \u2014 form a complete theory for tree-structured proof systems. The most promising cross-domain connection is between proof complexity and information theory: the certificate length equals the tree depth, which equals the minimum number of bits needed to distinguish all possible proofs. This depth-information duality parallels the Bekenstein-Hawking entropy bound in black hole physics, where the information content scales with the boundary area rather than the bulk volume.\n\nThe most important open frontier is extending these results from trees to directed acyclic graphs (DAGs), which model proof sharing \u2014 the mechanism by which real mathematical proofs reuse lemmas. DAG certificates are substantially harder because a single node may lie on multiple authentication paths. The resolution of this question connects to deep problems in proof complexity (circuit-to-proof correspondences), cryptography (succinct arguments of knowledge), and combinatorics (graph entropy). The direction with highest breakthrough potential is Direction 1 (DAG holographic certificates), because a positive result would provide deterministic short certificates for all polynomial-size Frege proofs, a result strictly stronger than the PCP theorem in the deterministic setting.\n\nThe cycle's results integrate naturally with the Catalog's existing infrastructure. The `Computation/HolographicCertificate.lean` and `Logic/HolographicSearch.lean` entries provide foundational definitions (Merkle trees, bulk-boundary proof structures, entanglement wedges) that our new results extend with concrete algorithms and correctness proofs. The spectral proof space framework in `Logic/SpectralProofSpace.lean` provides graph-theoretic tools (derivation graphs, forward balls, expansion bounds) that will be essential for Direction 2.\n\n---\n\n### Direction 1: DAG Holographic Certificates via Layered Hashing\n\n**Conjecture**: For any DAG-structured proof with n nodes and depth d, there exists a deterministic \"layered Merkle\" certificate of length O(d \u00b7 log(fan-in)) verifiable in O(d \u00b7 log(fan-in)) hash evaluations. For polynomial-size Frege proofs of depth O(log n), this gives certificates of length O(log\u00b2n).\n\n**Test**: Implement a layered Merkle construction for DAG proofs. Take the DAG for a Frege proof of the pigeonhole principle PHP(n \u2192 n-1). Construct the layered certificate and measure: (a) certificate length as a function of n, (b) verification time. The conjecture predicts certificate length \u221d log\u00b2(n). If certificate length grows faster than log\u00b2(n), the conjecture is refuted for this proof family.\n\n**Impact**: If true, this would provide the first deterministic sublinear certificates for general Frege proofs. It would also establish a formal connection between proof DAG depth and verification complexity, linking proof complexity to circuit complexity. If false, the failure would identify specific structural features of proof DAGs that resist holographic compression \u2014 likely related to the fan-in distribution or the presence of \"bottleneck\" nodes through which many authentication paths must pass.\n\n**Catalog References**: `Computation/HolographicCertificate.lean`, `Logic/HolographicSearch.lean`, `Logic/SpectralProofSpace.lean`\n\n**Proof Strategy**: \n1. Define a layered DAG structure where nodes are stratified by distance from the axiom leaves.\n2. Construct a per-layer Merkle tree: within each layer, nodes are hashed into a Merkle tree, and the root of each layer depends on the roots of the previous layer.\n3. An authentication path for a node at layer k consists of: (a) O(log(layer_size)) sibling hashes within each of the k layers, giving O(k \u00b7 log(max_layer_size)) total.\n4. Prove correctness: the layered authentication path uniquely determines the node's hash relative to the global root.\n5. Key lemma: if the DAG has depth d and maximum layer size w, then certificate length is O(d \u00b7 log w).\n\n**Domain Bridges**: Proof Complexity \u2194 Circuit Complexity (DAG proofs as Boolean circuits), Cryptography \u2194 Logic (collision resistance as a logical axiom)\n\n**Lineage**: Builds on `holographic_cert_bound` and `merkleVerify_correct` from this cycle's `Logic/HolographicVerification.lean`. Extends the tree-structured theory to the DAG setting.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Spectral Certificate Complexity\n\n**Conjecture**: The certificate complexity of a proof DAG G (minimum authentication path length over all leaves) is bounded below by the spectral gap \u03bb\u2082(L(G)) of the normalized graph Laplacian of G's underlying undirected graph. Specifically: cert_complexity(G) \u2265 \u03a9(1/\u03bb\u2082).\n\n**Test**: Compute the spectral gap of the derivation graph for Frege proofs of simple tautologies (e.g., excluded middle for n variables). Plot certificate complexity against 1/\u03bb\u2082. The conjecture predicts a linear relationship. If certificate complexity grows faster or slower than 1/\u03bb\u2082, the conjecture fails.\n\n**Impact**: If true, this would provide a spectral characterization of verification efficiency, connecting proof complexity to spectral graph theory. It would mean that proofs with high spectral gap (strong connectivity) have short certificates, paralleling how expander graphs enable efficient coding. If false, it would show that certificate complexity is not captured by second-order spectral information, suggesting higher-order graph invariants are needed.\n\n**Catalog References**: `Logic/SpectralProofSpace.lean` (derivation graphs, expansion bounds), `Logic/HolographicSearch.lean` (entanglement wedges)\n\n**Proof Strategy**:\n1. Define the normalized Laplacian of a proof DAG's undirected skeleton.\n2. Use the Cheeger inequality to relate spectral gap to edge expansion.\n3. Show that high edge expansion implies short authentication paths (because expanders have small diameter).\n4. Formalize the lower bound: low spectral gap implies the existence of a \"bottleneck\" cut, which forces long authentication paths through the bottleneck.\n5. Key lemma: `expansion_proof_length_bound` from `SpectralProofSpace.lean` provides the connection between graph expansion and proof length.\n\n**Domain Bridges**: Spectral Graph Theory \u2194 Proof Complexity (Cheeger inequality as proof complexity bound), Physics \u2194 Logic (spectral gap as mass gap analogue)\n\n**Lineage**: Builds on `expansion_proof_length_bound` from `Logic/SpectralProofSpace.lean` and `authPath_length_le_depth` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Certificate Complexity of Proof Composition\n\n**Conjecture**: For any sequence of k proofs \u03c0\u2081, ..., \u03c0\u2096 composed sequentially (each using the conclusion of the previous as a premise), the holographic certificate for the composed proof has length at most log\u2082(|\u03c0\u2081|) + log\u2082(|\u03c0\u2082|) + ... + log\u2082(|\u03c0\u2096|) + k. That is, certificate length is subadditive up to a linear term in the number of compositions.\n\n**Test**: Construct a chain of k balanced proof trees, each with n leaves, composed sequentially. Measure the total certificate length. The conjecture predicts length \u2264 k \u00b7 (log\u2082(n) + 1). If the actual length exceeds this bound for any k and n, the conjecture is refuted.\n\n**Impact**: If true, this would show that proof composition preserves the holographic property with controlled overhead, enabling modular verification of large mathematical developments. If false, it would identify composition as a source of certificate blowup, suggesting that monolithic proofs are more efficiently verifiable than modular ones \u2014 a surprising result with implications for the design of proof assistants.\n\n**Catalog References**: `Logic/HolographicVerification.lean` (`compose_cert_length`, `cert_subadditive`), `Computation/HolographicCertificate.lean` (`composed_cert_bound`)\n\n**Proof Strategy**:\n1. Define k-ary sequential composition as a right-leaning binary tree.\n2. Show that the depth of the composed tree is \u03a3\u1d62 depth(\u03c0\u1d62) + k - 1.\n3. Apply the auth path \u2264 depth bound to get the certificate bound.\n4. For the tight bound, construct an explicit authentication path and show it achieves the predicted length.\n5. Key challenge: handling unbalanced compositions where some \u03c0\u1d62 are much deeper than others.\n\n**Domain Bridges**: Category Theory \u2194 Proof Theory (composition as categorical composition), Software Engineering \u2194 Logic (modular verification as modular programming)\n\n**Lineage**: Directly extends `compose_cert_length` and `cert_subadditive` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Holographic Certificates for Arithmetic Proofs\n\n**Conjecture**: Proofs in bounded arithmetic (S\u2082\u00b9, the theory corresponding to polynomial-time reasoning) of \u03a3\u2081\u1d47 sentences have holographic certificates of length O(log n) where n is the proof length. Furthermore, these certificates can be constructed in polynomial time from the proof.\n\n**Test**: Formalize simple proofs in bounded arithmetic (e.g., commutativity of addition, totality of multiplication) as proof trees. Construct their Merkle certificates and verify: (a) certificate length is O(log n), (b) construction time is polynomial. The conjecture predicts both hold. Test with proofs of increasing length to verify the scaling.\n\n**Impact**: If true, this would establish that polynomial-time reasoning has efficient holographic certificates, connecting proof complexity to computational complexity through the lens of bounded arithmetic. This would give a proof-theoretic characterization of the P vs NP question: NP = P iff every bounded arithmetic proof has a polynomial-time constructible holographic certificate. If false, it would reveal a gap between proof complexity and computational complexity.\n\n**Catalog References**: `Logic/HolographicVerification.lean` (Merkle verification), `Physics/ProofSearchInformation.lean` (`proof_length_log_lower_bound`)\n\n**Proof Strategy**:\n1. Define bounded arithmetic proofs as a specific instantiation of `ProofTree` with a bounded axiom set.\n2. Show that the tree-structured fragment of S\u2082\u00b9 proofs satisfies the balance condition (depth \u2264 log(numLeaves) + 1).\n3. Apply `holographic_cert_bound` to obtain the O(log n) bound.\n4. For the construction time bound, show that Merkle root computation is polynomial in the tree size.\n5. Key challenge: handling the cut rule in bounded arithmetic, which introduces DAG-like sharing.\n\n**Domain Bridges**: Bounded Arithmetic \u2194 Computational Complexity (S\u2082\u00b9 as P-time reasoning), Cryptography \u2194 Proof Theory (hash functions as proof compression)\n\n**Lineage**: Extends the tree-structured results to a specific proof system of independent interest. Builds on `proof_length_log_lower_bound` from `Physics/ProofSearchInformation.lean`.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Quantum Holographic Certificates\n\n**Conjecture**: Using quantum certificates (density matrices of O(log n) qubits), proof verification can be performed with O(log log n) measurements, exponentially improving on classical holographic certificates.\n\n**Test**: For a family of balanced proof trees with 2^k leaves (k = 1, ..., 20), construct quantum certificates using quantum fingerprinting (encoding the Merkle root as a quantum state). Simulate the verification protocol and measure: (a) number of qubits, (b) number of measurements needed for 1-2^{-k} confidence. The conjecture predicts O(log k) = O(log log n) measurements.\n\n**Impact**: If true, this would establish an exponential quantum advantage for proof verification, the first such advantage in the foundations of mathematics. It would connect quantum information theory to proof complexity in a novel way. If false, it would show a classical-quantum parity for holographic verification, suggesting that the information content of proofs is fundamentally classical.\n\n**Catalog References**: `Logic/HolographicVerification.lean` (classical certificate framework), `Computation/HolographicCertificate.lean` (entropy bounds)\n\n**Proof Strategy**:\n1. Encode the Merkle root hash as a quantum state using quantum fingerprinting [BCWdW01].\n2. Use the SWAP test to compare the claimed root with the reconstructed root from the authentication path.\n3. Show that O(log(1/\u03b5)) SWAP tests achieve error probability \u03b5.\n4. For \u03b5 = 2^{-k}, this gives O(k) = O(log n) measurements \u2014 matching classical. The improvement to O(log log n) requires a recursive quantum fingerprinting scheme.\n5. Key insight: the recursive structure of Merkle trees enables recursive quantum fingerprinting, where each level of the tree is verified with a single quantum measurement.\n\n**Domain Bridges**: Quantum Information \u2194 Proof Theory (quantum fingerprints as proof certificates), Physics \u2194 Logic (quantum holographic principle)\n\n**Lineage**: A speculative extension of the classical holographic verification framework to the quantum setting. No direct prior results, but motivated by the quantum fingerprinting literature.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Computation",
      "Physics"
    ],
    "id": "fd_0586",
    "priority_score": 0.5,
    "research_mode": "team",
    "source_exp_id": "7512203a",
    "status": "available",
    "timestamp": "2026-06-04T01:03:57.743170+00:00",
    "title": "Rigorous formal framework for holographic proo"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Thermodynamic Proof Complexity\n\n## Synthesis\n\nThis research cycle established the **Thermodynamic Proof System** (TPS) framework, connecting proof complexity to physical energy costs via Landauer's principle. The key finding is a complete hierarchy: proof costs are separated by exactly T\u00b7ln(2) per level, most proofs are incompressible (and hence expensive), and for any fixed bound, there exist provable statements whose proof cost exceeds it (Chaitin-type result).\n\nThe most promising cross-domain connection is the **sorting-proof bridge**: comparison sorting is a special case of proof search, and the existing `thermodynamic_work_lower_bound` in `Computation/ThermodynamicSorting.lean` is a lower bound on the thermodynamic cost of proving ordering properties. This suggests a deep structural relationship between algorithmic complexity and proof complexity, mediated by thermodynamics. The proof energy landscape formalization \u2014 with its ruggedness ratio and trapping probability \u2014 connects proof search difficulty to spin glass theory, suggesting that techniques from statistical physics (replica methods, simulated annealing analysis) could yield new proof complexity bounds.\n\nThe direction with highest breakthrough potential is **Direction 1 (Quantum Thermodynamic Proof Complexity)**: if quantum proofs can reduce thermodynamic cost super-polynomially, this would constitute a physical separation between classical and quantum reasoning power, with implications for both foundations of mathematics and quantum computing.\n\n---\n\n### Direction 1: Quantum Thermodynamic Proof Complexity\n\n**Conjecture**: For any classical proof system with thermodynamic cost C_classical(\u03c6) for statement \u03c6, the corresponding quantum proof system satisfies C_quantum(\u03c6) \u2265 C_classical(\u03c6) / poly(|\u03c6|). That is, quantum mechanics saves at most a polynomial factor in thermodynamic proof cost.\n\n**Test**: Construct a family of statements \u03c6_n (e.g., graph non-isomorphism instances) where classical proof length is exponential in n but quantum proof length is polynomial. Compute the thermodynamic cost ratio C_classical / C_quantum. If the ratio exceeds any polynomial, the conjecture is refuted.\n\n**Impact**: If true, this establishes that mathematical reasoning has fundamental classical thermodynamic limits that quantum mechanics cannot circumvent. If false, it identifies specific mathematical domains where quantum proofs provide exponential energy savings, with implications for quantum-enhanced automated theorem proving.\n\n**Catalog References**: `Computation/ThermodynamicSorting.lean`, `Physics/ProofSearchInformation.lean`\n\n**Proof Strategy**: Define a quantum TPS as a TPS where proof strings can be quantum states (density matrices over {0,1}^n). The key lemma is that Holevo's theorem bounds the classical information extractable from quantum proofs, limiting the compression advantage. Establish that quantum verification (measurement) still incurs Landauer cost for each classical bit of the verification certificate.\n\n**Domain Bridges**: Physics (quantum information) <-> Computation (proof complexity) <-> Novelty (thermodynamic cost)\n\n**Lineage**: Builds on `ThermodynamicProofSystem` (this cycle) and `ProofSearchSpace` from `Physics/ProofSearchInformation.lean`\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Thermodynamic Proof Complexity of Specific Theories\n\n**Conjecture**: The thermodynamic cost hierarchy for Peano Arithmetic (PA) has a strictly faster growth rate than for propositional logic. Specifically, the minimum proof cost function L_PA(n) for PA satisfies L_PA(n) \u2265 n^2 for infinitely many n, while L_prop(n) \u2264 n \u00b7 log(n) for all n (where n is statement length).\n\n**Test**: Formalize a fragment of PA with concrete statement encoding. For statements of length n = 10, 20, 50, compute upper and lower bounds on minimum proof length. Compare with propositional tautologies of the same length. If the ratio L_PA / L_prop converges to 1 as n \u2192 \u221e, the conjecture is refuted.\n\n**Impact**: Would establish the first formally verified separation between proof systems measured in thermodynamic cost, creating a \"thermodynamic complexity zoo\" analogous to computational complexity classes but for proof energy.\n\n**Catalog References**: `Novelty/ThermodynamicProofComplexity/Theorems.lean` (hierarchy_gap, superlinear_cost_growth)\n\n**Proof Strategy**: Use speed-up theorems (e.g., G\u00f6del's speed-up) to show that PA proofs of certain statements are exponentially shorter than propositional proofs, but PA statements expressing consistency require exponentially long PA proofs (by G\u00f6del's second incompleteness theorem). The thermodynamic translation converts these length separations into energy separations.\n\n**Domain Bridges**: Logic (proof theory) <-> Novelty (thermodynamic cost) <-> Computation (complexity)\n\n**Lineage**: Builds on hierarchy_gap and superlinear_cost_growth from this cycle\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Energy Landscape Topology of Proof Spaces\n\n**Conjecture**: For the proof energy landscape of any sufficiently strong formal system (at least as strong as Robinson arithmetic Q), the ruggedness ratio r(n) = V_l(n) / (V_g(n) + 1) grows at least exponentially with proof length n. That is, r(n) \u2265 c^n for some constant c > 1.\n\n**Test**: For propositional resolution systems, enumerate all strings of length \u2264 n = 15 and classify each as (a) valid proof, (b) local minimum (syntactically well-formed but invalid), or (c) neither. Compute the ruggedness ratio for n = 5, 10, 15. Fit an exponential curve r(n) = a \u00b7 c^n. If c \u2264 1, the conjecture is refuted.\n\n**Impact**: An exponentially rugged landscape would explain why proof search is hard even for polynomial-time verifiable proof systems: gradient-based search gets trapped with probability approaching 1 as n grows. This would provide a thermodynamic explanation for the P \u2260 NP barrier.\n\n**Catalog References**: `Novelty/ThermodynamicProofComplexity/Defs.lean` (ProofEnergyLandscape), `Novelty/ThermodynamicProofComplexity/Theorems.lean` (landscape_trapping_bound, energy_gap_nonneg)\n\n**Proof Strategy**: \n1. Define a concrete energy function on binary strings: E(s) = 0 if s is a valid proof, E(s) = d(s, V) where d is Hamming distance to the nearest valid proof.\n2. Count local minima by analyzing the combinatorial structure of Hamming balls around valid proofs.\n3. Show that the number of \"near-miss\" strings (Hamming distance 1 from a valid proof but themselves invalid) grows exponentially.\n4. Use the incompressibility theorem to bound V_g from above (most valid proofs are incompressible, hence form an \"anti-chain\" in the Hamming cube).\n\n**Domain Bridges**: Geometry (landscape topology) <-> Computation (search complexity) <-> Physics (spin glass analogy)\n\n**Lineage**: Builds on ProofEnergyLandscape and trapping bounds from this cycle\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Thermodynamic Proof Compression Algorithms\n\n**Conjecture**: There exists a polynomial-time algorithm that, given a proof \u03c0 of length \u2113, produces a proof \u03c0' of the same statement with length \u2113' \u2264 \u2113 - log\u2082(\u2113), thereby reducing thermodynamic cost by at least log\u2082(\u2113) \u00b7 T \u00b7 ln(2). The algorithm succeeds on at least 1/2 of all proofs of length \u2113.\n\n**Test**: Implement the algorithm for propositional resolution proofs. Generate 1000 random valid proofs of length 100. Measure the average compression ratio \u2113'/\u2113. If the average exceeds 1 - 1/100 (i.e., less than 1% compression), the conjecture is likely false.\n\n**Impact**: A practical proof compression algorithm with thermodynamic guarantees would reduce the energy cost of automated theorem proving, with direct applications to formal verification systems that must process millions of proof steps.\n\n**Catalog References**: `Novelty/ThermodynamicProofComplexity/Theorems.lean` (incompressible_dominate, compression_fraction_bound)\n\n**Proof Strategy**: Use the incompressibility bound: since only 1/b fraction of proofs are compressible, the algorithm must identify and exploit the structure of compressible proofs. Key lemma: proofs with repeated subterms are compressible, and repeated subterms can be detected in polynomial time via suffix arrays. The log\u2082(\u2113) savings comes from replacing the first occurrence of each repeated subterm with a pointer.\n\n**Domain Bridges**: Computation (compression algorithms) <-> Novelty (thermodynamic cost) <-> MachineLearning (proof synthesis)\n\n**Lineage**: Builds on incompressibility results from this cycle\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Thermodynamic Cost of Undecidable Statements\n\n**Conjecture**: For any consistent, recursively axiomatizable extension T of PA, there exists a family of T-independent sentences {\u03c6_n} such that the minimum proof cost of \u03c6_n in any extension T' \u2287 T is at least 2^n \u00b7 T \u00b7 ln(2) \u2014 exponential in the sentence length.\n\n**Test**: Take T = PA and \u03c6_n = Con(PA + Con(PA + ... + Con(PA)...)) with n nestings of consistency statements. Each \u03c6_n is independent of PA but provable in PA + \u03c6_n. Compute upper bounds on the shortest proof of \u03c6_n in PA + \u03c6_n. If these bounds are polynomial in n, the conjecture is refuted.\n\n**Impact**: Would establish that undecidability is not just a logical phenomenon but a thermodynamic one: independent sentences are \"expensive\" in every possible extension of the theory, creating a thermodynamic barrier to resolving them.\n\n**Catalog References**: `Novelty/ThermodynamicProofComplexity/Theorems.lean` (chaitin_cost_bound), `Physics/ProofSearchInformation.lean` (proof_length_log_lower_bound)\n\n**Proof Strategy**: Use the relation between proof length and Kolmogorov complexity: the minimum proof length of \u03c6_n in any extension is bounded below by K(\u03c6_n | T'), where K is prefix-free Kolmogorov complexity. For nested consistency statements, K(\u03c6_n | T') \u2265 c \u00b7 2^n because each nesting level doubles the information content (the consistency of the previous level is a non-trivial additional axiom).\n\n**Domain Bridges**: Logic (undecidability) <-> Novelty (thermodynamic cost) <-> Physics (information theory)\n\n**Lineage**: Builds on chaitin_cost_bound from this cycle and proof_length_log_lower_bound from Physics/ProofSearchInformation.lean\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "fd_0728",
    "priority_score": 0.44999999999999996,
    "research_mode": "team",
    "source_exp_id": "e7178afa",
    "status": "available",
    "timestamp": "2026-06-05T14:57:59.924768+00:00",
    "title": "**Thermodynamic Proof System** (TPS) framewo"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\n## Synthesis\n\nThis research cycle established a formalized framework connecting Collatz dynamics to proof-theoretic barriers. The central insight is that three structural gaps \u2014 the density gap (1/3 vs 1/2), the deterministic window gap (local predictability vs global opacity), and the bounded-universal gap (decidable instances vs \u03a0\u2082 conjunction) \u2014 collectively explain why the Collatz conjecture resists proof. The most promising cross-domain connection is between **residue class acceleration** and **2-adic analysis**: our parity sequence determinism theorem (that n mod 2^k determines the first k parities of the orbit) is essentially a statement about 2-adic continuity of the Collatz map, bridging dynamics and p-adic number theory.\n\nThe density contraction theorem provides a quantitative criterion for orbit descent, and the gap between the parity exclusion bound (1/2) and the contraction threshold (1/3) is where all the difficulty lives. Future work should focus on either (a) narrowing this gap for specific families of inputs, or (b) proving that no uniform density bound below 1/2 exists \u2014 which would be strong evidence for independence. The GCS framework opens the door to studying computational universality thresholds: at what modulus does a GCS become Turing-complete?\n\nThe most impactful direction is **Direction 1** (p-adic Collatz dynamics), which connects our parity determinism result to Mahler's work on p-adic interpolation and could yield new density bounds via analytic methods. **Direction 2** (universality threshold) could settle a long-standing question about the computational power of simple GCS.\n\n---\n\n### Direction 1: p-Adic Collatz Dynamics and Density Bounds\n\n**Conjecture**: The Collatz map extends to a continuous function T: \u2124\u2082 \u2192 \u2124\u2082 on the 2-adic integers, and the odd-step density of T^n(x) for generic x \u2208 \u2124\u2082 converges to log(2)/log(3) \u2248 0.631. Moreover, for every rational starting value n \u2208 \u2115, the empirical odd density is bounded away from 1/2 \u2014 specifically, lim sup_{k\u2192\u221e} (oddCount(n,k)/k) < 0.4 for all n \u2208 \u2115.\n\n**Test**: (a) Formalize the 2-adic extension of the Collatz map and prove continuity. (b) Compute empirical odd densities for n up to 10^6 and test whether any exceed 0.45. (c) Attempt to prove the density bound 0.4 for specific residue classes (e.g., n \u2261 1 mod 2^k for large k).\n\n**Impact**: If the density is bounded away from 1/2, it would imply (via our contraction theorem) that orbits contract \"on average,\" giving the strongest known evidence for the conjecture short of a proof. If the bound fails for some explicit family, it would identify precisely the orbits that resist contraction \u2014 potential counterexample candidates.\n\n**Catalog References**: `Collatz.parity_determined_by_residue` (Novelty/CollatzResidueAcceleration.lean), `Collatz.density_contraction` (Novelty/CollatzContractionBarrier.lean), `Collatz.power_of_two_halvings` (Novelty/CollatzResidueAcceleration.lean)\n\n**Proof Strategy**: Use the parity determinism theorem as the base case. Extend to \u2124\u2082 using Mahler's theorem on p-adic interpolation. The continuity of the Collatz map on \u2124\u2082 follows from the fact that step preserves the 2-adic metric structure (our theorem shows the parity is preserved mod 2^k). For density bounds, use ergodic theory on the 2-adic shift space.\n\n**Domain Bridges**: 2-adic analysis \u2194 Collatz dynamics \u2194 ergodic theory\n\n**Lineage**: Builds on parity_determined_by_residue and density_contraction from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Universality Threshold for Generalized Collatz Systems\n\n**Conjecture**: There exists a sharp threshold m\u2080 such that for modulus m < m\u2080, the halting problem for GCS(m) is decidable, but for m \u2265 m\u2080, it is undecidable. Specifically, m\u2080 = 6 \u2014 GCS with modulus \u2264 5 have decidable halting, while modulus 6 suffices for Turing completeness.\n\n**Test**: (a) For m = 2,3,4,5, attempt to prove that all GCS with modulus m have decidable orbits. (b) For m = 6, construct a specific GCS that simulates a 2-counter machine (which is Turing-complete). (c) Formalize the reduction in Lean 4 using our GCS framework.\n\n**Impact**: This would give a precise characterization of the \"computational power boundary\" for Collatz-type systems. The standard Collatz map (m=2) would be proven to lie strictly below the universality threshold, constraining what kinds of undecidability arguments apply to it.\n\n**Catalog References**: `Collatz.GCS.System` (Novelty/CollatzGCSUndecidability.lean), `Collatz.GCS.standardCollatz_eq_step` (Novelty/CollatzGCSUndecidability.lean), `OracleHierarchy` (Computation/)\n\n**Proof Strategy**: For decidability at small moduli, use the fact that GCS with few rules have limited growth rates. For m=2, the growth per odd step is 3n+1, and the contraction is n/2, giving a net ratio of ~3/2 per odd-even pair. For universality at m=6, follow Conway's construction but optimize the modulus. The 2-counter machine simulation requires at least 6 residue classes to encode two counters with increment/decrement operations.\n\n**Domain Bridges**: Computability theory \u2194 Collatz dynamics \u2194 number theory\n\n**Lineage**: Builds on GCS framework from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Geometry of Collatz Orbits\n\n**Conjecture**: The Collatz orbit of n, viewed in logarithmic coordinates (log\u2082 of each iterate), is well-approximated by a piecewise-linear function in the tropical semiring (\u211d, max, +). Specifically, the \"tropical Collatz curve\" of n converges (in a suitable metric) to a random walk with drift log\u2082(3/4) \u2248 -0.415, and the variance of this walk determines the stopping time distribution.\n\n**Test**: (a) For n up to 10^5, compute the tropical orbit (log\u2082 of each iterate) and fit against a random walk model. (b) Measure the drift and variance and compare to theoretical predictions (drift = p\u00b7log\u2082(3) + (1-p)\u00b7log\u2082(1/2) where p is the odd density). (c) Formalize the tropical orbit as a sequence in \u211d and prove that the drift is negative when odd density < log\u2082(2)/log\u2082(3).\n\n**Impact**: Tropical geometry provides a natural framework for studying Collatz orbits, as the logarithm converts the multiplicative dynamics to additive (piecewise-linear) dynamics. The random walk model explains the observed log-normal distribution of stopping times and could yield the first rigorous stopping time bounds.\n\n**Catalog References**: `Collatz.odd_density_bound` (Novelty/CollatzContractionBarrier.lean), `Collatz.net_growth_odd_even` (Novelty/CollatzContractionBarrier.lean), `Computation/CollatzTropical.lean`, `Tropical/CollatzWielandt.lean`\n\n**Proof Strategy**: Define the tropical Collatz function as log\u2082 \u2218 step \u2218 2^(\u00b7). Show this is piecewise-linear with slopes determined by the parity of the input. Use the density contraction theorem to bound the drift. Connect to existing tropical geometry in the catalog.\n\n**Domain Bridges**: Tropical geometry \u2194 Collatz dynamics \u2194 probability theory (random walks)\n\n**Lineage**: Builds on density contraction from this cycle and CollatzTropical from catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Collatz-Style Problems as Natural Examples of G\u00f6del Incompleteness\n\n**Conjecture**: There exists a Collatz-like system (modulus m \u2264 10, with explicitly specified affine rules) whose halting problem on input 1 is independent of PA. That is, PA can neither prove that the orbit of 1 reaches a fixed point nor prove that it doesn't.\n\n**Test**: (a) Survey the landscape of small GCS (m \u2264 10) and identify candidates with undecidable-looking behavior. (b) For the best candidates, attempt to reduce from Goodstein's theorem or the Paris-Harrington theorem (known PA-independent statements) to the halting problem of the GCS. (c) Formalize the reduction in Lean 4.\n\n**Impact**: This would give the first *explicit, concrete* PA-independent statement arising from Collatz-type dynamics, rather than the abstract independence conjectures currently in the literature. It would bridge the gap between \"generalized Collatz is undecidable\" (Conway) and \"standard Collatz might be independent\" (folklore conjecture).\n\n**Catalog References**: `Collatz.GCS.CollatzIndependenceThesis` (Novelty/CollatzGCSUndecidability.lean), `Collatz.GCS.sound_cannot_refute_collatz` (Novelty/CollatzGCSUndecidability.lean)\n\n**Proof Strategy**: Use Goodstein sequences (known to be PA-independent) as the target. Goodstein sequences involve iterated base-change operations that are structurally similar to Collatz iterations. Construct a GCS whose orbit on input 1 encodes a Goodstein sequence. The PA-independence of the Goodstein theorem then transfers to the GCS halting problem.\n\n**Domain Bridges**: Mathematical logic (G\u00f6del incompleteness) \u2194 Collatz dynamics \u2194 ordinal arithmetic\n\n**Lineage**: Builds on proof system framework and GCS definitions from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Effective Contraction Bounds for Specific Residue Classes\n\n**Conjecture**: For n \u2261 0 (mod 2^k), the orbit reaches a value < n within at most 2k steps, and this bound is tight. More precisely, iter(n, 2k) < n for all n \u2261 0 (mod 2^k) with n \u2265 2^k.\n\n**Test**: (a) Prove the bound for k = 1, 2, 3, 4 using the mod-4 and mod-8 acceleration theorems. (b) Attempt the general case by induction on k. (c) Verify tightness by finding, for each k, a value n \u2261 0 (mod 2^k) where iter(n, 2k-1) \u2265 n.\n\n**Impact**: This would give explicit, computable contraction certificates for a positive-density subset of \u2115. Combined with density arguments, it could show that \"most\" numbers have contracting orbits, extending Tao's result in a more constructive direction.\n\n**Catalog References**: `Collatz.two_step_contraction_mod4` (Novelty/CollatzResidueAcceleration.lean), `Collatz.three_step_contraction_mod8` (Novelty/CollatzResidueAcceleration.lean), `Collatz.power_of_two_halvings` (Novelty/CollatzResidueAcceleration.lean)\n\n**Proof Strategy**: Use power_of_two_halvings as the base case: iter(2^k\u00b7m, k) = m < 2^k\u00b7m. The key is to show that the \"expansion\" steps after reaching m don't push the value back above n within k more steps. This requires bounding the Syracuse function iterated k times.\n\n**Domain Bridges**: Analytic number theory \u2194 Collatz dynamics\n\n**Lineage**: Direct extension of mod-4 and mod-8 contraction results from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "fd_0733",
    "priority_score": 0.44999999999999996,
    "research_mode": "team",
    "source_exp_id": "e1a7a938",
    "status": "available",
    "timestamp": "2026-06-05T15:34:32.605717+00:00",
    "title": "Formalized framework connecting Collatz dynami"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Oracle Non-Computability and Mathematical Intuition\n\n## Synthesis\n\nThis cycle established a rigorous bridge between proof search complexity (the `proof_length_counting_bound` in the Catalog) and oracle non-computability. The central insight is that the counting argument generalizes cleanly: where proofs of length n can't cover T theorems (when b^n < T), programs of length k can't compute all 3^N oracles (when b^k < 3^N). The three-valued nature of the oracle answer space \u2014 true, false, unknown \u2014 creates a 3^N vs b^k gap that grows exponentially, establishing that \"almost all\" oracles are non-computable.\n\nThe most promising cross-domain connection is between this oracle theory and information-theoretic bounds. The information deficit (N\u00b7log\u2082(3) \u2248 1.585N bits needed vs N bits available from a binary program of length N) connects oracle non-computability to Shannon's source coding theorem. This suggests that mathematical truth has an inherent entropy rate that finite descriptions cannot capture \u2014 a quantitative strengthening of G\u00f6del's incompleteness.\n\nThe highest breakthrough potential lies in Direction 1 (Structured Oracle Accuracy), because it attacks the gap between our worst-case impossibility results and the practical success of modern AI systems at mathematical reasoning. If structured oracles (those respecting logical closure properties) form a computably characterizable subset, this would precisely delineate what is and isn't automatable in mathematical reasoning.\n\n---\n\n### Direction 1: Structured Oracle Accuracy Thresholds\n\n**Conjecture**: Among all oracles on N number-theoretic statements that are logically consistent (i.e., if the oracle says \"true\" to A and \"true\" to A\u2192B, it must say \"true\" to B), the fraction that are computable by programs of length \u2264 k is *higher* than among unrestricted oracles, but still vanishes as N \u2192 \u221e for fixed k.\n\nFormally: Let C(N,k) be the number of logically consistent oracles on N statements computable by programs of length \u2264 k, and L(N) the total number of logically consistent oracles on N statements. Then C(N,k)/L(N) \u2192 0 as N \u2192 \u221e for any fixed k.\n\n**Test**: Define \"logically consistent oracle\" as one that respects modus ponens on a fixed set of implications among the N statements. Count L(N) for small N (up to 10) by enumeration. Verify that L(N) still grows exponentially, just slower than 3^N.\n\n**Impact**: If true, this shows that even adding logical structure doesn't make the oracle space computable \u2014 intuition remains fundamentally non-algorithmic even for \"well-behaved\" oracles. If false, it would identify logical consistency as the dividing line between computable and non-computable mathematical reasoning.\n\n**Catalog References**: `proof_length_counting_bound` (Bridges/ProofSearchComplexity.lean), `oracle_not_covered_by_programs` (Speculative/RamanujanOracle.lean)\n\n**Proof Strategy**:\n1. Define a formal \"logical consistency\" predicate on oracles (closure under a fixed set of inference rules)\n2. Prove that the consistent oracle space still grows exponentially (by constructing explicit families of consistent oracles that differ on independent statements)\n3. Show that the program space bound b^k still applies to consistent oracles\n4. Conclude by the same pigeonhole argument\n\n**Domain Bridges**: Computation (oracle theory) <-> Logic (consistency and closure) <-> MachineLearning (structured prediction)\n\n**Lineage**: Builds on `oracle_not_covered_by_programs` and `ramanujan_oracle_noncomputable` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Probabilistic Oracle Amplification\n\n**Conjecture**: There exists a computable transformation T that maps any oracle O with accuracy \u03b1 > 1/3 on N statements to an oracle T(O) with accuracy (3\u03b1 - 1)/2 on the same N statements, analogous to probability amplification in randomized computation. However, this amplification cannot be iterated more than O(log N) times before hitting a non-computability barrier.\n\n**Test**: Implement the transformation T as majority voting over k independent evaluations of O (where k is odd). Compute the accuracy of T(O) as a function of k and \u03b1. Verify that the amplified accuracy converges to 1 but that the program length of T(O) grows as k times the program length of O, eventually hitting the b^k < 3^N barrier.\n\n**Impact**: If true, this establishes a formal analogy between oracle accuracy amplification and the BPP amplification lemma in complexity theory. It would show that the non-computability barrier appears not because individual evaluations fail, but because the amplification process itself requires unbounded resources.\n\n**Catalog References**: `proof_length_counting_bound` (Bridges/ProofSearchComplexity.lean), `binary_oracle_fraction_vanishes` (Speculative/RamanujanOracle.lean)\n\n**Proof Strategy**:\n1. Define the majority-vote transformation for oracles\n2. Prove the accuracy amplification lemma (Chernoff-type bound)\n3. Track the program length through amplification\n4. Show the length growth hits the 3^N barrier after O(log N) rounds\n\n**Domain Bridges**: Computation (amplification) <-> Cryptography (hardness amplification) <-> MachineLearning (boosting)\n\n**Lineage**: Extends `exponential_gap_growth` and `computable_oracle_fraction_vanishes` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Oracle Entropy Rate for Specific Theories\n\n**Conjecture**: The \"entropy rate\" of true arithmetic statements (the limiting ratio of true statements to total statements as length grows) is computable and equals a specific algebraic number. More precisely, if T(n) is the number of true sentences of length \u2264 n in Presburger arithmetic (which is decidable) and S(n) is the total number of well-formed sentences of length \u2264 n, then T(n)/S(n) \u2192 \u03bb where \u03bb is algebraic and 0 < \u03bb < 1.\n\n**Test**: Enumerate all well-formed sentences of Presburger arithmetic up to length 20. Use a decision procedure for Presburger arithmetic to classify each as true or false. Compute T(n)/S(n) for n = 1, ..., 20 and fit a limit.\n\n**Impact**: If the entropy rate is algebraic, it would connect the combinatorics of mathematical truth to algebraic number theory. If it's transcendental, it would show that even the \"statistical structure\" of mathematical truth is computationally complex. Either way, it characterizes how much information an oracle must carry per statement.\n\n**Catalog References**: `oracle_space_card` (Speculative/RamanujanOracle.lean), `information_gap_bridge` (Speculative/RamanujanOracle.lean)\n\n**Proof Strategy**:\n1. Formalize the syntax of Presburger arithmetic in Lean\n2. Define T(n) and S(n) as computable functions\n3. Prove that T(n)/S(n) is monotone (or exhibit non-monotonicity)\n4. Compute the limit (if it exists) using Presburger decidability\n\n**Domain Bridges**: Computation (decidability) <-> Logic (Presburger arithmetic) <-> Physics (information entropy)\n\n**Lineage**: Extends `binary_information_insufficient` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical Oracle Hierarchy\n\n**Conjecture**: In the tropical semiring (\u211d \u222a {\u221e}, min, +), the \"tropical oracle\" that maps polynomial systems to their tropical solution sets exhibits a complexity hierarchy analogous to the classical oracle hierarchy. Specifically, tropical oracle level n (which knows tropical solutions of systems with n polynomial equations) is strictly more powerful than level n-1.\n\n**Test**: Define tropical polynomial systems and their solution sets. Show that the number of possible tropical solution sets for n-equation systems over k variables grows faster than for (n-1)-equation systems. Apply the counting argument from this cycle.\n\n**Impact**: If true, this would bridge the oracle non-computability theory from discrete mathematics to tropical geometry, establishing that the \"hardness hierarchy\" is not an artifact of classical logic but a structural feature of mathematical truth across domains.\n\n**Catalog References**: `tropical_proof_length_conjecture_special_case` (Physics/TropicalProofComplexity.lean), `oracle_hierarchy_strict` (Speculative/RamanujanOracle.lean)\n\n**Proof Strategy**:\n1. Define tropical polynomial systems and their solution sets as oracles\n2. Count the number of distinct solution sets at each level\n3. Show exponential growth between levels using the structure of tropical varieties\n4. Apply the oracle non-coverage theorem\n\n**Domain Bridges**: Computation (oracle hierarchy) <-> Tropical (tropical geometry) <-> Algebra (semiring structure)\n\n**Lineage**: Extends `oracle_hierarchy_strict` from this cycle, bridges to tropical results in the Catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Oracle Compositionality and the Jump Operator\n\n**Conjecture**: There exists a formal connection between oracle composition (applying one oracle's output as input to another) and the Turing jump operator. Specifically, if O\u2081 is a level-n oracle (computable from the n-th iterate of the halting problem) and O\u2082 is a level-m oracle, then the composition O\u2082 \u2218 O\u2081 (interpreted as: evaluate O\u2081, then feed results to O\u2082) requires at most level max(n,m)+1 computational power. Moreover, this bound is tight: there exist O\u2081, O\u2082 at levels n, m whose composition genuinely requires level max(n,m)+1.\n\n**Test**: Formalize oracle composition for finite function spaces (Fin N \u2192 Fin 3). Show that the composition space grows as 3^(3^N), which exceeds 3^(b^k) for any fixed program bound. This would be the finite analog of the jump operator increasing computational power.\n\n**Impact**: If true, this would formalize the intuition that mathematical creativity (composing insights from different domains) produces genuinely new computational power \u2014 not just more of the same. It would also connect our oracle counting framework to the established theory of Turing degrees.\n\n**Catalog References**: `oracle_tower_non_collapse` (Bridges/UniversalComplexityBarriers.lean), `no_countable_surjection_to_oracles` (Speculative/RamanujanOracle.lean)\n\n**Proof Strategy**:\n1. Define oracle composition formally as a higher-order function\n2. Count the composition space and compare to the original oracle space\n3. Use the counting argument to show composition increases the non-computability gap\n4. Connect to the jump operator via the arithmetic hierarchy characterization\n\n**Domain Bridges**: Computation (Turing degrees) <-> Logic (arithmetic hierarchy) <-> Algebra (function composition)\n\n**Lineage**: Extends `oracle_hierarchy_strict`, `no_countable_surjection_to_oracles`, and connects to `oracle_tower_non_collapse` from the Catalog.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "fd_0947",
    "priority_score": 0.44999999999999996,
    "research_mode": "team",
    "source_exp_id": "62fdd270",
    "status": "available",
    "timestamp": "2026-06-07T13:09:04.779835+00:00",
    "title": "Rigorous bridge between proof search complexity (the `p"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that a general tropical curve of genus g has a divisor of degree d and rank r iff the Brill-Noether number \u03c1 = g - (r+1)(g-d+r) \u2265 0. Formalize the connection to classical algebraic geometry.",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "id": "fd_0404",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.629129+00:00",
    "title": "Tropical Brill-Noether Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove a tropical analog of the Hodge decomposition. Formalize tropical (p,q)-forms, the tropical Laplacian, and harmonic theory on balanced weighted polyhedral complexes.",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "id": "fd_0438",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.398315+00:00",
    "title": "Tropical Hodge Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove arithmetic mirror symmetry: the number of rational curves on X equals the rank of the Picard group of its mirror Y. Formalize the SYZ picture and modularity of CY zeta functions.",
    "domains": [
      "Bridges",
      "Geometry"
    ],
    "id": "fd_0443",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.798593+00:00",
    "title": "Arithmetic Mirror Symmetry for Calabi-Yau"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the Fisher information metric on a statistical manifold satisfies the axioms of a Riemannian metric. Construct explicit connections between the Fisher metric and the Kullback-Leibler divergence. Bridge statistical inference to differential geometry.",
    "domains": [
      "Bridges",
      "Geometry"
    ],
    "id": "fd_0449",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.281925+00:00",
    "title": "Information-Geometric Bridge: Fisher Metric on Statistical Manifolds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the tropical amoeba of a Laurent polynomial is the negative logarithm of its zero set. Show that the Ronkin function is convex and piecewise-linear on the amoeba complement. Connect tropical amoebas to tropical geometry via the Maslov dequantization.",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "id": "fd_0469",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.890305+00:00",
    "title": "Tropical Amoebas and Ronkin Functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the tropical compactification of the moduli space of curves M_g is a toric variety whose boundary divisors correspond to tropical curves. Formalize the connection between the Deligne-Mumford compactification and the tropical moduli space.",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "id": "fd_0470",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.975644+00:00",
    "title": "Tropical Compactification of Moduli Spaces"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove special cases of Beal's conjecture (A^x + B^y = C^z with x,y,z > 2 implies gcd(A,B,C) > 1). Verify computationally for all values up to 1000. Prove the conjecture when one of x,y,z equals 3 and the other two are at most 5.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_0513",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.490493+00:00",
    "title": "Beal's Conjecture: Computational Evidence and Special Cases"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Yoneda lemma as a bridge connecting any mathematical structure to its representable functors. Prove that the Yoneda embedding is fully faithful. Show how this bridges algebra (modules = additive functors), topology (sheaves = local functors), and logic (toposes = categorical semantics). Prove that every Grothendieck topos is a bounded lattice with a universal property.",
    "domains": [
      "Bridges",
      "Algebra"
    ],
    "id": "fd_0527",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:05.876172+00:00",
    "title": "Bridge: Category Theory as Universal Language for Mathematics"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that every Galois connection between posets induces a topology on each poset such that the Galois maps become continuous. Show that the fixed points of a Galois connection form a complete lattice (Knaster-Tarski). Bridge to algebraic geometry: Zariski topology on Spec(R) arises from the Galois connection between ideals and zero sets.",
    "domains": [
      "Bridges",
      "Geometry"
    ],
    "id": "fd_0528",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:05.964661+00:00",
    "title": "Bridge: Galois Connections Between Order Theory and Topology"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Ax-Kochen-Ershov theorem: two henselian valued fields with elementarily equivalent residue fields and value groups are elementarily equivalent. Bridge to number theory: this implies the Q_p's are elementarily equivalent for almost all p. Prove Morley's categoricity theorem: if a countable theory is categorical in one uncountable cardinal, it is categorical in all uncountable cardinals.",
    "domains": [
      "Bridges",
      "Algebra"
    ],
    "id": "fd_0537",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.719659+00:00",
    "title": "Bridge: Model Theory and Algebra \u2014 Ax-Kochen and Morley's Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the tropical semiring (R \u222a {-\u221e}, max, +). Prove that tropical matrix multiplication is associative and that the tropical determinant equals the weight of the maximum-weight permutation. Show that tropical eigenvalues are roots of the characteristic polynomial in the tropical sense. Prove the tropical Perron-Frobenius theorem.",
    "domains": [
      "Tropical",
      "Algebra"
    ],
    "id": "fd_0545",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.376136+00:00",
    "title": "Tropical Linear Algebra: Eigenvalues and Determinants"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the tropical moduli space of genus-g curves M_g^trop is a metric graph with vertices corresponding to combinatorial types. Show that M_g^trop is the Berkovich skeleton of the classical M_g. Prove that the tropical Torelli map factors through the tropical Jacobian and that its fibers are finite.",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "id": "fd_0548",
    "priority_score": 0.3599999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.620386+00:00",
    "title": "Tropical Moduli Spaces: Curves and Their Tropical Counterparts"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove tropical versions of classical convexity theorems: tropical Helly (if every n+1 sets in a tropical Helly family intersect, then all intersect), tropical Caratheodory (every point in the tropical convex hull of S is in the tropical convex hull of at most n+1 points from S), and tropical Radon (every set of n+2 points can be partitioned into two sets with intersecting tropical convex hulls).",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "id": "fd_0546",
    "priority_score": 0.34999999999999987,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.462910+00:00",
    "title": "Tropical Convexity: Helly, Caratheodory, and Radon"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions: Tangled Hierarchies and Self-Referential Proof Systems\n\n## Synthesis\n\nThis cycle established a rigorous Lean 4 formalization of provability logic (GL) via Kripke semantics, proving 12 theorems including L\u00f6b's theorem, the semantic second incompleteness theorem, a sharp tangling dichotomy, and a novel bridge between GL frames and well-founded strict partial orders. The most promising cross-domain connection is the **order-theoretic bridge** (Theorem `gl_frame_is_strict_order`): GL frames are exactly well-founded strict partial orders, meaning the entire apparatus of well-quasi-order theory, ordinal analysis, and lattice-theoretic fixed points becomes available to study provability hierarchies.\n\nThe key structural insight from this cycle is the **tangling dichotomy** (`tangling_dichotomy_ext`): every sound world either is terminal (vacuously omniscient) or has blind spots about its own soundness. This dichotomy is exhaustive and propagates through the entire consistency hierarchy. Combined with the disjoint union closure result, this shows that tangling is compositional \u2014 combining independent systems does not resolve any individual system's tangling.\n\nThe highest breakthrough potential lies in **Direction 1** (Polymodal GL and ordinal analysis), which would connect our GL frame theory to Japaridze's GLP logic and proof-theoretic ordinals, bridging modal logic, set theory, and proof theory in a formally verified framework. This would be a significant first in the formalization of proof theory.\n\n---\n\n### Direction 1: Polymodal Provability Logic (GLP) and Ordinal Assignment\n\n**Conjecture**: GLP frames \u2014 frames with a sequence of accessibility relations R\u2080 \u2287 R\u2081 \u2287 R\u2082 \u2287 \u00b7\u00b7\u00b7 where each R\u2099 is transitive and converse well-founded \u2014 can be formally constructed in Lean 4 with a well-defined ordinal assignment function that maps each world to its proof-theoretic ordinal. Specifically, the ordinal assignment should satisfy: if R\u2099(w,v) then ord(v) < ord(w), and the ordinal of the \"standard world\" under R\u2080 should correspond to \u03b5\u2080 (the proof-theoretic ordinal of PA).\n\n**Test**: Define a `GLPFrame` structure in Lean 4 with a family of accessibility relations indexed by \u2115, prove that each level gives a valid GL frame, and construct a concrete GLP frame whose ordinal assignment reproduces the standard ordinal analysis of PA (ordinal \u03b5\u2080 at the base level, \u03c9^\u03c9^\u00b7\u00b7\u00b7  at higher levels).\n\n**Impact**: If successful, this would be the first machine-verified formalization of the connection between polymodal provability logic and proof-theoretic ordinals, bridging modal logic and ordinal analysis. If the ordinal assignment fails to give \u03b5\u2080, it would reveal that the standard GLP-ordinal connection requires additional structure beyond the frame semantics (perhaps specific arithmetical interpretations).\n\n**Catalog References**: `Logic/TangledHierarchyDefs.lean` (GLFrame), `Logic/TangledHierarchyTheorems.lean` (loeb_semantic, gl_frame_is_strict_order)\n\n**Proof Strategy**:\n1. Define `GLPFrame` as a dependent structure with `R : \u2115 \u2192 W \u2192 W \u2192 Prop` and monotonicity/transitivity/well-foundedness conditions.\n2. Prove each `R n` gives a GL frame (reuse existing infrastructure).\n3. Define ordinal assignment via well-founded recursion on R\u2080.\n4. Prove the assignment is strictly decreasing and bounds the depth.\n5. Construct a concrete GLP frame on an ordinal type.\n\n**Domain Bridges**: Logic (provability logic) \u2194 Set Theory (ordinal analysis) \u2194 Proof Theory (consistency strength)\n\n**Lineage**: Extends `gl_frame_is_strict_order` and `tangling_dichotomy_ext` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: De Jongh-Sambin Fixed-Point Theorem for GL\n\n**Conjecture**: For any modal formula \u03c6(p) where the propositional variable p occurs only within the scope of \u25a1, there exists a formula \u03c8 (not containing p) such that GL \u22a2 \u03c8 \u2194 \u03c6(\u03c8). Moreover, this fixed point is unique up to GL-provable equivalence. This can be formalized semantically: for every GL frame M and valuation V, the formula \u03c8 constructed by the fixed-point procedure satisfies w \u22a9 \u03c8 \u2194 w \u22a9 \u03c6(\u03c8) at every world w.\n\n**Test**: Define a substitution operation on modal formulas, formalize the \"occurs only under box\" condition, and prove the fixed-point existence theorem for GL frames. Test on concrete cases: the G\u00f6del sentence (\u03c6(p) = \u00ac\u25a1p gives \u03c8 \u2261 \u00ac\u25a1\u22a5 \u2261 Con) and the Henkin sentence (\u03c6(p) = \u25a1p gives \u03c8 \u2261 \u22a4).\n\n**Impact**: This would formalize one of the deepest results in provability logic, connecting self-reference (fixed points) to the modal-logical framework. It directly extends the Catalog's `fixed_point_construction_bound` to the logical domain. Failure would indicate that the semantic approach is insufficient and a syntactic (Hilbert system) formalization is needed.\n\n**Catalog References**: `Bridges/EMLClosureCore.lean` (fixed_point_construction_bound), `Logic/TangledHierarchyDefs.lean` (MFormula, forces)\n\n**Proof Strategy**:\n1. Define formula substitution `MFormula.subst : MFormula \u03b1 \u2192 (\u03b1 \u2192 MFormula \u03b1) \u2192 MFormula \u03b1`.\n2. Define the \"modalized in p\" predicate: p occurs only under \u25a1.\n3. Construct the fixed-point formula by iterating the substitution (this is well-defined because each step reduces the \"modal depth\" of occurrences of p).\n4. Prove the fixed point satisfies the equivalence using L\u00f6b's theorem and well-founded induction.\n5. Prove uniqueness using the characterization of GL-provable equivalence via frame validity.\n\n**Domain Bridges**: Logic (fixed-point theorem) \u2194 Algebra (fixed-point constructions, Knaster-Tarski) \u2194 Computation (self-referential programs, quines)\n\n**Lineage**: Extends `loeb_semantic` and `fixed_point_construction_bound` from the Catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Tropical Provability: Min-Plus Semantics for GL\n\n**Conjecture**: GL frames admit a \"tropical\" semantics where the forcing relation is replaced by a real-valued \"proof cost\" function cost(w, \u03c6) \u2208 [0, \u221e], with \u25a1\u03c6 costing the supremum of costs over accessible worlds plus a \"reflection overhead\" constant. In this tropical semantics, L\u00f6b's theorem corresponds to the statement that the cost of self-referential proofs grows without bound \u2014 tangling has a quantitative measure.\n\n**Test**: Define `tropicalForces : GLFrame \u2192 (\u03b1 \u2192 M.W \u2192 \u211d\u22650\u221e) \u2192 M.W \u2192 MFormula \u03b1 \u2192 \u211d\u22650\u221e` where:\n- cost(w, var p) = V(p)(w)\n- cost(w, \u22a5) = \u221e\n- cost(w, \u03c6 \u2192 \u03c8) = max(0, cost(w,\u03c8) - cost(w,\u03c6))\n- cost(w, \u25a1\u03c6) = sup{cost(v,\u03c6) + 1 : R(w,v)}\n\nProve that if cost(w, \u25a1(\u25a1\u03c6\u2192\u03c6)) < \u221e then cost(w, \u25a1\u03c6) < \u221e (tropical L\u00f6b), and that the reflection overhead creates a strictly increasing cost along the consistency hierarchy.\n\n**Impact**: This bridges provability logic to tropical geometry and optimization, creating a quantitative theory of proof complexity within the GL framework. It would connect to the Catalog's tropical algebra results and create a novel \"tropical incompleteness theorem.\"\n\n**Catalog References**: `Tropical/TropicalOrbitShadowing.lean` (iterate_dist_fixed_point_bound), `Cryptography/BerggrenDiophantineLattice.lean` (tropical structures)\n\n**Proof Strategy**:\n1. Define the tropical forcing function using well-founded recursion (similar to `forces`).\n2. Prove tropical L\u00f6b by adapting the well-founded induction argument.\n3. Show that each consistency level adds constant overhead, giving a linear lower bound on cost(w, Con\u207f).\n4. Connect to the metric structure via `iterate_dist_fixed_point_bound`.\n\n**Domain Bridges**: Logic (GL frames, L\u00f6b's theorem) \u2194 Tropical Algebra (min-plus semirings) \u2194 Optimization (proof search costs)\n\n**Lineage**: Extends `loeb_semantic` and bridges to `iterate_dist_fixed_point_bound`.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tangling in PAC-Bayesian Learning Theory\n\n**Conjecture**: The tangling dichotomy has a precise analog in PAC-Bayesian learning theory: a learning algorithm that is \"sound\" (its generalization bound holds for all distributions) either has trivial capacity (it can only learn constant functions) or there exist distributions for which its self-estimated generalization bound is strictly looser than the true bound \u2014 it cannot accurately predict its own generalization error.\n\n**Test**: Formalize the analogy by defining a \"PAC-Bayesian frame\" where worlds are distributions, the accessibility relation is \"distribution D\u2081 can be estimated from D\u2082\", and soundness means the generalization bound holds. Prove that the tangling dichotomy applies to this frame, producing a \"PAC-Bayesian incompleteness theorem.\"\n\n**Impact**: This would establish a rigorous connection between G\u00f6delian incompleteness and statistical learning theory, showing that the tangling phenomenon is not merely logical but statistical. It extends the Catalog's `second_incompleteness_analog` and `unprovable_true_generalization` results.\n\n**Catalog References**: `MachineLearning/LoebGeneralization.lean` (lob_generalization_criterion), `MachineLearning/CertificationBarrier.lean` (barriers_from_diagonalization)\n\n**Proof Strategy**:\n1. Define a PAC-Bayesian GL frame where worlds are (prior, posterior, sample_size) triples.\n2. Define R as the \"can estimate from\" relation, prove it's transitive and converse well-founded (bounded by sample size).\n3. Instantiate the tangling dichotomy to get the PAC-Bayesian incompleteness theorem.\n4. Prove concrete bounds: the gap between self-estimated and true generalization error is at least O(1/\u221an).\n\n**Domain Bridges**: Logic (tangling dichotomy) \u2194 Machine Learning (PAC-Bayes, generalization bounds) \u2194 Statistics (self-referential estimation)\n\n**Lineage**: Extends `tangling_dichotomy_ext` and connects to `lob_generalization_criterion`.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Compositional Tangling and Category of GL Frames\n\n**Conjecture**: GL frames form a category where morphisms are \"p-morphisms\" (bounded morphisms preserving the frame structure). This category has finite products (given by a \"synchronized product\" where R holds componentwise) and the tangling dichotomy is preserved by all categorical operations \u2014 tangling is a \"categorical property\" in a precise sense.\n\n**Test**: Define the category of GL frames and p-morphisms in Lean 4. Prove that finite products exist and are GL frames. Prove that if M\u2081 and M\u2082 each have sound worlds with successors (hence tangled), then their product is also tangled. Show the disjoint union is the coproduct in this category.\n\n**Impact**: This would establish that tangling is not just a property of individual frames but a structural property preserved by the natural categorical operations. It would connect provability logic to categorical logic and topos theory.\n\n**Catalog References**: `Logic/TangledHierarchyTheorems.lean` (GLFrame.disjointUnion, tangling_dichotomy_ext)\n\n**Proof Strategy**:\n1. Define `GLFrameMorphism` as structure-preserving maps with back-and-forth conditions.\n2. Show composition and identity give a category.\n3. Define product frames and prove they satisfy GL conditions.\n4. Prove tangling preservation via the tangling dichotomy applied to projected worlds.\n5. Prove disjoint union is the coproduct by constructing universal morphisms.\n\n**Domain Bridges**: Logic (GL frames) \u2194 Category Theory (products, coproducts, preservation) \u2194 Algebra (categorical constructions)\n\n**Lineage**: Extends `GLFrame.disjointUnion` and `tangling_dichotomy_ext`.\n\n**Ambition**: extension\n",
    "domains": [
      "Logic",
      "Pythagorean"
    ],
    "id": "fd_0986",
    "priority_score": 0.29999999999999993,
    "research_mode": "team",
    "source_exp_id": "e406e7e8",
    "status": "available",
    "timestamp": "2026-06-07T21:30:04.487788+00:00",
    "title": "Rigorous Lean 4 formalization of provability logic (GL)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Derive an analytic form for the square site percolation threshold. Formalize bond vs site percolation, prove known exact thresholds for triangular lattices, and connect to conformal invariance.",
    "domains": [
      "Computation",
      "Physics"
    ],
    "id": "fd_0397",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.080296+00:00",
    "title": "Percolation Threshold"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove tight bounds on quantum error-correcting codes. Formalize the quantum Singleton bound, quantum Hamming bound, and construct optimal stabilizer codes. Connect to topological quantum computing.",
    "domains": [
      "Physics",
      "Computation"
    ],
    "id": "fd_0399",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.231496+00:00",
    "title": "Quantum Error Correction Bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that reversible circuits achieve Landauer's bound for erasure. Formalize the connection between computational complexity and thermodynamic entropy. Construct provably optimal reversible implementations of common algorithms.",
    "domains": [
      "Computation",
      "Physics"
    ],
    "id": "fd_0402",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.464794+00:00",
    "title": "Reversible Computing and Thermodynamic Efficiency"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Tononi's Integrated Information Theory (IIT) using tensor network states. Conjecture: The integrated information Phi of a tensor network state equals the minimal quantum mutual information across any bipartition. Test: compute Phi for MPS (matrix product states) with bond dimension 2 and verify it matches the Schmidt rank. Impact: connects consciousness theory to quantum information and tensor categories.",
    "domains": [
      "Physics",
      "Computation"
    ],
    "id": "fd_0414",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.423474+00:00",
    "title": "Integrated Information via Tensor Networks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Landauer's principle states that erasing one bit of information dissipates at least kT*ln(2) of heat. Apply this to proof theory: erasing a proof of theorem T to recover a shorter proof is an information-theoretic process with a thermodynamic cost. Conjecture: The minimum energy required to compress a proof of n steps into a proof of m steps (m < n) is at least kT*(n-m)*ln(2), and this bound is tight for proofs in propositional logic. A proof of length n contains n bits of information (each step is a binary choice in the search tree). Compressing it to m steps requires erasing n-m bits, each costing kT*ln(2) by Landauer. This gives a physical lower bound on proof compression that is independent of the proof system. Test: formalize proof compression as an irreversible computation and derive the Landauer bound. Compute the erasure cost for compressing a 1000-step proof of the fundamental theorem of algebra into a 100-step proof. Impact: connects information thermodynamics to proof complexity, providing a physical lower bound on proof compression.",
    "domains": [
      "Physics",
      "Computation"
    ],
    "id": "fd_0423",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.146225+00:00",
    "title": "Thermodynamic Proof Erasure: Landauer's Principle for Mathematics"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Construct and prove correct a zero-knowledge proof system for graph 3-colorability. Prove completeness, soundness, and zero-knowledge. Formalize the simulation paradigm and show that the simulator produces indistinguishable transcripts.",
    "domains": [
      "Cryptography",
      "Logic"
    ],
    "id": "fd_0456",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.834642+00:00",
    "title": "Zero-Knowledge Proof Systems: Formal Verification of Privacy"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the Coffman-Kundu-Wootters monogamy inequality for qubit entanglement: the sum of squared concurrences is bounded by the squared concurrence with the ancilla. Formalize concurrence as an entanglement measure and extend to n-qubit systems.",
    "domains": [
      "Physics",
      "Computation"
    ],
    "id": "fd_0462",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.319643+00:00",
    "title": "Quantum Entanglement Monogamy: CKW Inequality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that erasing one bit of information requires at least kT ln(2) of energy dissipation in the thermodynamic limit. Show that for finite-size systems, the bound is modified by a Jarzynski-like correction term. Formalize the connection between logical irreversibility and thermodynamic irreversibility.",
    "domains": [
      "Physics",
      "Computation"
    ],
    "id": "fd_0465",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.568365+00:00",
    "title": "Quantum Thermodynamics: Landauer's Principle at the Nanoscale"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the Eastin-Knill theorem: no quantum code can transversally implement a universal gate set. Formalize the threshold theorem for fault-tolerant quantum computing and prove that the threshold is approximately 1% for the surface code with depolarizing noise.",
    "domains": [
      "Physics",
      "Computation"
    ],
    "id": "fd_0467",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.732241+00:00",
    "title": "Quantum Error Correction Threshold: The Eastin-Knill Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the k-Local Hamiltonian Problem is QMA-complete for k >= 2. Formalize the Kitaev reduction from quantum circuit satisfiability to the local Hamiltonian problem. Analyze the promise gap and its effect on complexity.",
    "domains": [
      "Computation",
      "Physics"
    ],
    "id": "fd_0475",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:31.381522+00:00",
    "title": "Quantum Hamiltonian Complexity: QMA-Completeness of the Local Hamiltonian Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the Rademacher complexity of a hypothesis class provides tight generalization bounds for supervised learning. Formalize the margin bound for linear classifiers and extend to kernel methods. Show that VC dimension bounds are looser than Rademacher bounds for structured hypothesis classes.",
    "domains": [
      "MachineLearning",
      "Logic"
    ],
    "id": "fd_0500",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:46.538330+00:00",
    "title": "Generalization Bounds via Rademacher Complexity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the geometry of spacetime can be reconstructed from the entanglement structure of a quantum state. Formalize the ER=EPR conjecture: show that entangled qubit pairs satisfy the properties of microscopic Einstein-Rosen bridges in a toy AdS/CFT model.",
    "domains": [
      "Physics",
      "Computation"
    ],
    "id": "fd_0507",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.045810+00:00",
    "title": "Emergent Spacetime from Quantum Entanglement"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Rademacher complexity for hypothesis classes. Prove that the Rademacher complexity of a neural network with L layers and spectral norm bound C is O(C * sqrt(L) / sqrt(n)). Derive PAC-Bayes generalization bounds. Show that weight normalization reduces the Rademacher complexity and thus improves generalization.",
    "domains": [
      "MachineLearning",
      "Logic"
    ],
    "id": "fd_0556",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:08.298113+00:00",
    "title": "ML Generalization Bounds: Rademacher Complexity of Neural Networks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The renormalization group in physics zooms out by integrating out high-energy modes. Formalize this as an inverse stereographic projection on the energy sphere: RG flow equals iterated stereographic projection with varying pole. Conjecture: The beta function beta(g) in phi^4 theory equals the derivative of the stereographic projection map at the critical coupling g*. Test: compute the stereographic map for the 1D Ising model and verify beta(g) matches. Impact: connects renormalization to conformal geometry.",
    "domains": [
      "Geometry",
      "Physics"
    ],
    "id": "fd_0421",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.988240+00:00",
    "title": "Inverse Stereographic Renormalization Group"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Fourier transform diagonalizes the Laplacian on R^n. The Laplace-Beltrami operator on S^n is diagonalized by spherical harmonics. Stereographic projection gives a conformal map S^n to R^n that modifies the metric by a conformal factor (1+|x|^2)^2/4. Define the stereographic Fourier transform: for f in L^2(S^n), set F(f)(k) = integral over S^n of f(x) * (1+|phi(x)|^2)^{-n/2} * e^{-2 pi i phi(x) * k} d sigma(x) where phi is the stereographic projection. Conjecture: The stereographic Fourier transform is an isometry L^2(S^n) to L^2(R^n) mapping spherical harmonics Y_l^m to generalized Hermite functions with explicit radial profiles. The transform preserves eigenvalues up to a conformal correction: Delta_{S^n} Y_l^m = -l(l+n-1) Y_l^m maps to Delta_{R^n}(F[Y_l^m]) = (-l(l+n-1) + n^2/4) F[Y_l^m] plus a lower-order correction. Test: derive the transform explicitly for n=2 and verify it sends Y_1^m to Hermite functions. Prove the Plancherel identity. Impact: enables Fourier analysis on spheres via classical Fourier analysis on R^n, with applications to quantum mechanics on curved spaces and computational harmonic analysis.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_0425",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:27.310599+00:00",
    "title": "Stereographic Fourier Analysis: Spherical Harmonics via Plane Waves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that univalent foundations (HoTT) provide a consistent alternative to ZFC. Formalize the univalence axiom, compute homotopy groups of spheres, and establish constructive interpretability.",
    "domains": [
      "Bridges",
      "Logic"
    ],
    "id": "fd_0446",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.050227+00:00",
    "title": "Homotopy Type Theory as Foundations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Construct an explicit order-preserving map from the proof-theoretic ordinals of PA to those of KP set theory. Prove that epsilon_0 < psi(Omega^omega) and formalize the ordinal collapsing function psi as a term rewriting system in Lean 4.",
    "domains": [
      "Bridges",
      "Logic"
    ],
    "id": "fd_0452",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.504025+00:00",
    "title": "Proof-Theoretic Bridge: Ordinal Analysis Across Systems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the maximal Lyapunov exponent of the gravitational three-body problem is strictly positive, establishing deterministic chaos. Compute explicit bounds for equal-mass systems and formalize the connection between Lyapunov exponents and Kolmogorov-Sinai entropy.",
    "domains": [
      "Physics",
      "Geometry"
    ],
    "id": "fd_0466",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.651923+00:00",
    "title": "Chaos and the Three-Body Problem: Lyapunov Exponent Bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Stone duality: the category of Boolean algebras is dual to the category of Stone spaces. Prove that every Boolean algebra B is isomorphic to the clopen algebra of its Stone space. Bridge this to logic: a theory T in propositional logic corresponds to the Boolean algebra of sentences modulo T-provability, whose Stone space is the space of models.",
    "domains": [
      "Bridges",
      "Logic"
    ],
    "id": "fd_0531",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.221142+00:00",
    "title": "Bridge: Stone Duality as a Bridge Between Logic and Topology"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Lob's theorem as a fixed-point result: if PA proves \u25a1A \u2192 A then PA proves A. Bridge this to category theory: the modal logic GL (Godel-Lob) is the internal logic of the category of provability predicates. Prove that Solovay's completeness theorem for GL follows from the diagonal lemma.",
    "domains": [
      "Bridges",
      "Logic"
    ],
    "id": "fd_0535",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:06.553916+00:00",
    "title": "Bridge: Logic of Provability and Fixed Points in Arithmetic"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Poincare conjecture (proved by Perelman) states that every simply connected closed 3-manifold is homeomorphic to the 3-sphere. For data: a point cloud X = {x_1, ..., x_n} in R^d may or may not lie on a manifold. Conjecture: the Poincare conjecture for data states that if the persistent homology of X satisfies H_0(X) = Z, H_1(X) = 0, H_2(X) = 0, ..., H_{d-1}(X) = 0, then X lies on (or near) a d-sphere. More precisely, if the Vietoris-Rips complex of X at scale epsilon has the homology of S^d (trivial homology except H_0 = Z and H_d = Z), then X is epsilon-close to a subset of S^d. Conjecture: the smallest epsilon such that VR_epsilon(X) has the homology of S^d is the 'Poincare threshold' of X, and it satisfies epsilon_star = C * d^{1/2} * n^{-1/d} for some constant C, where n is the number of points. This is the manifold detection threshold: below epsilon_star, X looks like a d-sphere; above epsilon_star, X looks like something else. Test: generate point clouds on S^d for d = 1, 2, 3 and compute the Poincare threshold. Impact: the Poincare conjecture for data says that manifold detection is a topological problem, and the detection threshold scales as n^{-1/d}.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0096",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.834465+00:00",
    "title": "The Poincare Conjecture for Data: Manifold Detection via Persistent Homology"
  }
];
