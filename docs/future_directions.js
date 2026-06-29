

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
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
    "description": "Formalize Goldbach's conjecture in Lean 4. Prove the conjecture holds for all even n \u2264 10^6 computationally, formalize Vinogradov's theorem (every sufficiently large odd number is the sum of three primes), and construct the Hardy-Littlewood circle method framework for additive problems. Deliver a working Lean verification tactic.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "id": "seed_327",
    "priority_score": 0.95,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432569+00:00",
    "title": "Goldbach Verification Framework"
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
    "description": "Formalize global existence and uniqueness for 2D Navier-Stokes (Ladyzhenskaya's theorem). Prove the Caffarelli-Kohn-Nirenberg partial regularity theorem in 3D: the singular set has 1-dimensional Hausdorff measure zero. Formalize energy inequalities.",
    "domains": [
      "Analysis",
      "Physics"
    ],
    "id": "seed_342",
    "priority_score": 0.93,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432645+00:00",
    "title": "Navier-Stokes: 2D Regularity and Partial 3D Results"
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
    "description": "Develop custom Lean 4 tactics for common proof patterns in the Catalog: a tropical_simp tactic for min-plus simplification, a number_theory_decide for small cases, and a spectral_bound for eigenvalue estimates. Prove each tactic is sound.",
    "domains": [
      "Logic",
      "Computation",
      "Bridges"
    ],
    "id": "seed_379",
    "priority_score": 0.92,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432809+00:00",
    "title": "Proof Automation: Custom Lean 4 Tactics"
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
    "description": "Formalize the fundamental theorem of Galois theory in Lean 4. Prove the Abel-Ruffini theorem: the general quintic is not solvable by radicals. Construct explicit Galois groups for specific polynomials and prove solvability criteria via the derived series.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_337",
    "priority_score": 0.91,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432615+00:00",
    "title": "Galois Theory: Solvability of Polynomials"
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
    "description": "Formalize the ABC conjecture statement and prove its major consequences: Fermat's Last Theorem for large exponents, Roth's theorem strengthening, the Szpiro conjecture for elliptic curves. Construct the radical rad(n) function framework in Lean 4.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "id": "seed_336",
    "priority_score": 0.9,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432613+00:00",
    "title": "ABC Conjecture: Consequences and Partial Results"
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
    "description": "Formalize the Learning With Errors (LWE) problem. Prove Regev's quantum reduction: LWE is as hard as worst-case lattice problems (GapSVP). Construct the Dual-Regev encryption scheme and prove CPA security. Formalize the ring-LWE variant.",
    "domains": [
      "Cryptography",
      "Algebra",
      "Computation"
    ],
    "id": "seed_370",
    "priority_score": 0.89,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432791+00:00",
    "title": "Lattice Cryptography: LWE Hardness"
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
    "description": "Compute and formalize \u03c0_n(S^m) for small n, m. Prove \u03c0_3(S^2) \u2245 \u2124 via the Hopf fibration. Construct the Hopf invariant and prove it detects the generator. Formalize the long exact sequence of a fibration.",
    "domains": [
      "Topology",
      "Algebra"
    ],
    "id": "seed_350",
    "priority_score": 0.88,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432680+00:00",
    "title": "Homotopy Groups of Spheres: Low-Dimensional"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the group law on elliptic curves over finite fields in Lean 4. Prove associativity via the chord-tangent construction. Implement and verify point multiplication. Prove Hasse's bound: |#E(F_p) - p - 1| \u2264 2\u221ap.",
    "domains": [
      "Cryptography",
      "Algebra",
      "NumberTheory"
    ],
    "id": "seed_371",
    "priority_score": 0.88,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-18T03:56:25.432792+00:00",
    "title": "Elliptic Curve Arithmetic: Group Law Formalization"
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
    "description": "Formalize the spectral theorem for bounded self-adjoint operators on Hilbert spaces. Prove the min-max theorem for eigenvalues. Construct the functional calculus and prove the spectral mapping theorem. Apply to quantum mechanical observables.",
    "domains": [
      "Analysis",
      "Physics",
      "Algebra"
    ],
    "id": "seed_344",
    "priority_score": 0.87,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432652+00:00",
    "title": "Spectral Theory: Self-Adjoint Operators"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Boolean circuit complexity. Prove Razborov's lower bound: monotone circuits for CLIQUE require exponential size. Formalize the approximation method. Prove the Karchmer-Wigderson connection between circuit depth and communication complexity.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "seed_357",
    "priority_score": 0.87,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432748+00:00",
    "title": "Circuit Complexity: Monotone Lower Bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Yoneda lemma in Lean 4 with concrete applications. Prove that representable functors determine objects up to isomorphism. Formalize adjunctions and prove the general adjoint functor theorem. Apply to free-forgetful adjunctions.",
    "domains": [
      "Algebra",
      "Logic",
      "Bridges"
    ],
    "id": "seed_376",
    "priority_score": 0.87,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432801+00:00",
    "title": "Categorical Foundations: Yoneda and Adjunctions"
  },
  {
    "consumed_by_exp_id": "87caa6a1",
    "description": "Formalize the definition of zero-knowledge proofs (interactive and non-interactive). Prove that graph 3-colorability has a zero-knowledge proof. Implement a simplified zk-SNARK circuit in Lean 4 and prove soundness. Bridge: connect to the PCP theorem (NP \u2286 PCP(poly, 1)).",
    "domains": [
      "Cryptography",
      "Logic"
    ],
    "id": "fd_0539",
    "priority_score": 0.86,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-03T22:10:06.880463+00:00",
    "title": "Zero-Knowledge Proofs in Lean: Verifiable Computation"
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
    "description": "Formalize at least three distinct proofs of quadratic reciprocity in Lean 4: Gauss's original (via Gauss sums), Eisenstein's (via lattice point counting), and a modern proof via class field theory. Prove the supplementary laws for (-1/p) and (2/p).",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "id": "seed_333",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432607+00:00",
    "title": "Quadratic Reciprocity: Five Proofs Formalized"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Ext and Tor functors in Lean 4. Prove the long exact sequence in cohomology. Construct projective and injective resolutions for concrete modules. Prove the universal coefficient theorem for homology.",
    "domains": [
      "Algebra",
      "Topology"
    ],
    "id": "seed_339",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432630+00:00",
    "title": "Homological Algebra: Derived Functors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize cubical type theory primitives in Lean 4. Construct the interval type and path types. Prove function extensionality and the univalence axiom. Implement higher inductive types: circles, torus, suspension.",
    "domains": [
      "Logic",
      "Topology",
      "Algebra"
    ],
    "id": "seed_360",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432767+00:00",
    "title": "Type Theory: Cubical Type Theory Foundations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the no-cloning theorem in Lean 4 using the framework of C*-algebras. Prove the quantum teleportation protocol is correct. Formalize quantum entanglement measures and prove monogamy of entanglement for qubits.",
    "domains": [
      "Physics",
      "Algebra",
      "Computation"
    ],
    "id": "seed_365",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432775+00:00",
    "title": "Quantum Information: No-Cloning and Teleportation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the universal approximation theorem for ReLU networks. Prove depth-width tradeoffs: width-bounded networks of depth d can approximate functions that require exponential width at depth d-1. Construct explicit approximation rates for Sobolev functions.",
    "domains": [
      "MachineLearning",
      "Analysis"
    ],
    "id": "seed_366",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432777+00:00",
    "title": "Universal Approximation: Quantitative Bounds"
  },
  {
    "consumed_by_exp_id": "21b9e424",
    "description": "Formalize tropical curves as metric graphs. Prove the tropical Riemann-Roch theorem via chip-firing: r(D) - r(K-D) = deg(D) - g + 1. Construct explicit divisor classes on complete graphs and prove Baker-Norine's theorem.",
    "domains": [
      "Tropical",
      "Algebra",
      "Combinatorics"
    ],
    "id": "seed_373",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-18T03:56:25.432796+00:00",
    "title": "Tropical Curves and Chip-Firing Games"
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
    "description": "Formalize the representation theory of finite groups. Compute and verify character tables for S_3, S_4, S_5. Prove Burnside's theorem (groups of order p^a q^b are solvable). Formalize Maschke's theorem and Schur's lemma.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_338",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432625+00:00",
    "title": "Representation Theory: Character Tables of S_n"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Jones polynomial via the Kauffman bracket. Prove invariance under Reidemeister moves. Compute Jones polynomials for the trefoil, figure-eight, and torus knots. Prove that the Jones polynomial detects the unknot for alternating knots.",
    "domains": [
      "Topology",
      "Algebra"
    ],
    "id": "seed_348",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432668+00:00",
    "title": "Knot Invariants: Jones Polynomial Formalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the resolution proof system. Prove exponential lower bounds for resolution proofs of the pigeonhole principle (Haken's theorem). Formalize cutting planes and prove the separation from resolution. Connect to SAT solver performance.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "seed_358",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432755+00:00",
    "title": "Proof Complexity: Resolution and Cutting Planes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Kantorovich optimal transport problem. Prove existence of optimal transport maps (Brenier's theorem for quadratic cost). Formalize Wasserstein distances and prove the Wasserstein GAN convergence properties.",
    "domains": [
      "MachineLearning",
      "Analysis",
      "Geometry"
    ],
    "id": "seed_369",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432786+00:00",
    "title": "Optimal Transport and Wasserstein Distances"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Schnorr identification protocol in Lean 4. Prove completeness, soundness, and honest-verifier zero-knowledge. Formalize the Fiat-Shamir heuristic for non-interactive proofs. Prove security in the random oracle model.",
    "domains": [
      "Cryptography",
      "Logic",
      "Computation"
    ],
    "id": "seed_372",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432794+00:00",
    "title": "Zero-Knowledge Proofs: Schnorr Protocol"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize BCH and Reed-Solomon codes over finite fields. Prove the BCH bound on minimum distance. Construct the Berlekamp-Massey decoding algorithm and prove correctness. Apply to concrete error-correction scenarios.",
    "domains": [
      "Algebra",
      "Computation",
      "Cryptography"
    ],
    "id": "seed_378",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432807+00:00",
    "title": "Algebraic Coding Theory: BCH and Reed-Solomon"
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
    "description": "Prove that Wall-Sun-Sun primes exist (primes p where p\u00b2 divides F_{p-(p|5)}). Formalize the connection to Fermat's Last Theorem and establish search bounds for the first such prime.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_207",
    "priority_score": 0.84,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
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
    "description": "Prove the invariant subspace theorem for compact operators on Hilbert spaces (Aronszajn-Smith). Formalize Lomonosov's theorem: operators commuting with a nonzero compact operator have invariant subspaces. Explore the Enflo-Read counterexample structure.",
    "domains": [
      "Analysis",
      "Algebra"
    ],
    "id": "seed_343",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432648+00:00",
    "title": "Invariant Subspace Problem: Special Cases"
  },
  {
    "consumed_by_exp_id": "032698b5",
    "description": "Prove that Besicovitch sets in R^2 have Hausdorff dimension 2 (Davies's theorem). Formalize the Wolff bound in R^3: dimension \u2265 5/2. Connect to restriction estimates for the Fourier transform and to additive combinatorics via the Katz-Tao framework.",
    "domains": [
      "Geometry",
      "Analysis"
    ],
    "id": "seed_347",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-18T03:56:25.432660+00:00",
    "title": "Kakeya Conjecture: Known Cases and Bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the untyped lambda calculus. Prove the Church-Rosser theorem (confluence). Formalize the simply-typed lambda calculus and prove strong normalization. Construct the B\u00f6hm tree for undecidability of equivalence.",
    "domains": [
      "Logic",
      "Computation"
    ],
    "id": "seed_361",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432769+00:00",
    "title": "Lambda Calculus: Church-Rosser and Normalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the PAC-Bayes framework in Lean 4. Prove the Catoni bound and McAllester bound. Apply to neural networks via Gaussian perturbation priors. Prove that PAC-Bayes bounds are asymptotically tight for linear classifiers.",
    "domains": [
      "MachineLearning",
      "Probability",
      "Computation"
    ],
    "id": "seed_367",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-18T03:56:25.432779+00:00",
    "title": "PAC-Bayes Generalization Bounds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the Fisher information metric on parametric statistical models. Prove the Cram\u00e9r-Rao bound as a geometric statement. Construct the alpha-connections and prove the dually flat structure. Apply to exponential families.",
    "domains": [
      "Geometry",
      "Probability",
      "Bridges"
    ],
    "id": "seed_377",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-18T03:56:25.432802+00:00",
    "title": "Information Geometry: Fisher Metric on Statistical Models"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Riemann zeta function zeta(s) has non-trivial zeros at s = 1/2 + i*gamma_n on the critical line (assuming RH). These zeros encode deep arithmetic information. Conjecture: the zeros gamma_n are the spectrum of a self-adjoint operator on a Hilbert space, and this operator is the Casimir element of a quantum group G_q. Specifically, define the 'zeta quantum group' G_q as the q-deformation of SU(2) where q = e^{2*pi*i*gamma_1} (using the first zero gamma_1 ~ 14.13). The Casimir element C_q of G_q has eigenvalues that are quadratic functions of the representation labels, and the spectrum of C_q is {n(n+1) : n in N}. Conjecture: the Riemann zeros gamma_n are related to the spectrum of C_q by gamma_n = f(spectrum(C_q)) for some function f. If f is linear, this would mean the zeros are evenly spaced, which is false (the zeros have Poisson-like spacings). If f is logarithmic, gamma_n ~ pi*n/log(n) which matches the average spacing. Conjecture: the spectral statistics of C_q match the GUE random matrix statistics of the Riemann zeros (Montgomery's pair correlation conjecture). Test: compute the spectrum of C_q for G_q with q = e^{2*pi*i*gamma_1} and compare the spectral statistics with the Riemann zeros. Impact: the Riemann hypothesis is a representation-theoretic statement about quantum groups.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0076",
    "priority_score": 0.83,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.711975+00:00",
    "title": "Quantum Groups from Number Theory: The Riemann Hypothesis as a Representation Problem"
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
    "description": "Prove the Jacobian conjecture for polynomial maps of degree 2 in all dimensions. Formalize the reduction to degree 3 (Dru\u017ckowski's theorem). Construct explicit counterexample candidates and verify they fail. Prove the conjecture implies the Dixmier conjecture.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "seed_340",
    "priority_score": 0.83,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432638+00:00",
    "title": "Jacobian Conjecture: Degree 2 and 3 Cases"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the discrete Fourier transform as representation theory of cyclic groups. Prove Parseval's theorem and the convolution theorem. Extend to arbitrary finite abelian groups. Prove the uncertainty principle: supp(f) \u00b7 supp(f\u0302) \u2265 |G|.",
    "domains": [
      "Analysis",
      "Algebra"
    ],
    "id": "seed_346",
    "priority_score": 0.83,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432657+00:00",
    "title": "Fourier Analysis on Finite Groups"
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
    "description": "Prove that the set of positive integers with finite Collatz stopping time has density 1. Formalize the Terras density result and the Krasikov-Lagarias bound. Construct the 3-adic analysis of the Collatz map and prove local convergence properties.",
    "domains": [
      "NumberTheory",
      "Computation"
    ],
    "id": "seed_330",
    "priority_score": 0.82,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432601+00:00",
    "title": "Collatz Stopping Times: Density Analysis"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize quaternion algebras and their classification over number fields. Prove the isomorphism between unit quaternions and SO(3). Construct the Cayley-Dickson construction and prove properties of octonions. Apply to gimbal lock avoidance in 3D rotation.",
    "domains": [
      "Algebra",
      "Geometry",
      "Bridges"
    ],
    "id": "seed_341",
    "priority_score": 0.82,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432642+00:00",
    "title": "Quaternion Algebras and Rotations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize tropical convex sets and tropical polytopes. Prove the tropical analogue of the Minkowski-Weyl theorem. Show that tropical linear programming is solvable in polynomial time. Connect to mean payoff games.",
    "domains": [
      "Tropical",
      "Computation",
      "Geometry"
    ],
    "id": "seed_374",
    "priority_score": 0.82,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432797+00:00",
    "title": "Tropical Convexity and Linear Programming"
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
    "description": "For every gentle tree algebra A = KQ/<R> of finite global dimension, let \u03a9_A be the finite set of indecomposable A-modules, equivalently the permissible arcs in the modified surface model. For S \u2286 \u03a9_A, let cl_A(S) be the set of indecomposable summands lying in the resolving subcategory generated by S together with the projective modules. The conjecture is that cl_A is a convex-geometry closure operator: in particular, it satisfies anti-exchange. Explicitly, if C is resolving-closed, x and y are distinct indecomposables not in C, and x \u2208 cl_A(C \u222a {y}), then y \u2209 cl_A(C \u222a {x}). This is finite, falsifiable by computation on gentle trees, and would imply that the poset of resolving subcategories of a gentle tree algebra is meet-distributive.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_2295",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21424v1",
    "status": "failed",
    "timestamp": "2026-06-23T02:04:29.943864+00:00",
    "title": "Anti-exchange for resolving closure in gentle tree algebras"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any dimension n \u2265 2, among all n-dimensional orthogonal flat tori of unit volume, the equilateral torus (with all lattice side lengths equal) uniquely maximizes the zeta regularized determinant of the Laplacian. Formally, if T_l = \u211d\u207f/(l\u2081\u2124 \u00d7 \u22ef \u00d7 l\u2099\u2124) with \u220fl\u1d62 = 1 and l\u1d62 > 0, then det_\u03b6(\u0394_{T_l}) \u2264 det_\u03b6(\u0394_{T_eq}) with equality if and only if l\u2081 = \u22ef = l\u2099 = 1, where T_eq is the equilateral torus. This validates Sarnak's conjecture in the orthogonal setting.",
    "domains": [
      "Pythagorean",
      "Cryptography"
    ],
    "id": "fd_2298",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21442v1",
    "status": "failed",
    "timestamp": "2026-06-23T03:00:56.801830+00:00",
    "title": "The Equilateral Torus Uniquely Maximizes the Zeta Regularized Determinant Among Orthogonal Flat Tori of Unit Volume"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let $A(z)$ be the ordinary generating series of P\u00f3lya trees, with coefficients $a_n$, and let $\\rho$ be its radius of convergence such that $A(\\rho) = 1$. Then for all integers $k \\ge 1$ and all real numbers $t$ such that $0 \\le t < \\rho$, the truncation error of the $k$-th partial sum is bounded by $0 \\le A(t) - \\sum_{i=1}^k a_i t^i \\le \\frac{(t/\\rho)^{k+1}}{1 - t/\\rho}$.",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_2317",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23439v1",
    "status": "failed",
    "timestamp": "2026-06-23T08:33:35.541800+00:00",
    "title": "P\u00f3lya Tree Generating Series Taylor Approximation Error Bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Let r,t,n be natural numbers with 1 \u2264 t \u2264 r and n \u2265 r+1. Let K be a pure r-dimensional simplicial complex on n vertices which is r-down path connected. Suppose that for every face \u03c3 of K with |\u03c3| = r - t, the reduced homology group H_t(lk_K(\u03c3); \u211d) vanishes. Then q_{r-1}(K) = t n - (t-1)(r+1) if and only if K is isomorphic to \u0394_{r+1-t} \u22c6 \u0394_{n-r-1+t}^{t}. Equivalently, the large lower bound on n appearing in the paper\u2019s equality characterization is unnecessary.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2348",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22825v1",
    "status": "failed",
    "timestamp": "2026-06-23T11:22:47.373232+00:00",
    "title": "Threshold-free equality case for the local-homology signless Laplacian bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any left-regular bipartite graph G of degree d \u2265 3 with girth at least 2s (equivalently, G is s-optimal), the binary linear code B(G) has minimum distance at least 2(d-1)^{s-2}. This conjecture asserts that the girth characterization of s-optimal expanders proven in the paper transfers to a strong lower bound on the minimum distance of the associated code, providing the coding-theoretic foundation needed for the post-quantum key exchange application.",
    "domains": [
      "Cryptography",
      "Pythagorean"
    ],
    "id": "fd_2363",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23579v1",
    "status": "failed",
    "timestamp": "2026-06-23T15:55:03.027965+00:00",
    "title": "Girth-Implied Minimum Distance Bound for Optimal Small-Set Expander Codes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper demonstrates that augmenting the 27-vertex unit-distance graph G27 with a specific pair of vertices results in a 29-vertex graph with geometric fractional chromatic number strictly greater than 4. The authors note that such augmentations are exceedingly rare. This conjecture posits that, up to Euclidean isometry, this specific 2-vertex augmentation is the unique way to add two vertices to G27 such that the resulting unit-distance graph has a geometric fractional chromatic number strictly greater than 4.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2810",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T03:31:25.863443+00:00",
    "title": "Uniqueness of the Critical 2-Vertex Augmentation of G27"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For integers k \u2265 1 and n \u2265 2k+2, any \u03c4_k-maximal graph G of order n has exactly (k+1)(n-1)-1 edges. This resolves the conjecture proposed in the paper by upgrading the established upper bound to an exact equality.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2812",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28198v1",
    "status": "available",
    "timestamp": "2026-06-29T03:48:47.894402+00:00",
    "title": "Exact Edge Count of \u03c4_k-maximal Graphs"
  },
  {
    "consumed_by_exp_id": "c9fb85eb",
    "description": "The only non-negative integer solutions (n, t) to the Diophantine equation P_14(n) = t^3 are (0,0), (1,1), and (5,5), where P_s(n) = ((s-2)n^2 - (s-4)n)/2 denotes the n-th s-gonal number. This corresponds to the k=5 case of Theorem 1(ii) in the paper.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2813",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28227v1",
    "status": "in_progress",
    "timestamp": "2026-06-29T03:32:01.660417+00:00",
    "title": "Classification of Perfect Cubes in 14-gonal Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any odd prime p and non-negative integer w, the number of 2-balanced p-regular partitions with p-core \u03ba and p-weight w is independent of \u03ba and equals C(w + (p\u22123)/2, w), where a partition \u03bb is 2-balanced p-regular if it is p-regular and every hook of \u03bb whose length is divisible by p has even arm length. This is the key enumeration result from the paper, connecting the crystal-reflection invariance of d-balanced partitions to an explicit binomial counting formula via RoCK blocks.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2814",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28305v1",
    "status": "available",
    "timestamp": "2026-06-29T03:49:32.425118+00:00",
    "title": "Enumeration of 2-balanced p-regular partitions by p-weight"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The 29-vertex unit-distance graph G_29, obtained by augmenting the 27-vertex configuration G_27 of Matolcsi et al. with two specific vertices, has geometric fractional chromatic number strictly greater than 4. This is the core technical result of the paper, from which the main theorem (existence of a unit-distance graph with independence ratio below 1/4) and the corollary that the fractional chromatic number of the plane exceeds 4 both follow via the blow-up framework.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2815",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T04:01:41.266053+00:00",
    "title": "Geometric fractional chromatic number of the 29-vertex augmented configuration exceeds 4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the prime $k=7$ (which corresponds to $s=2k+4=18$), the only integer solutions to the Diophantine equation $P_{18}(n) = t^p$ for any prime $p \\ge 11$ are the trivial ones $(n,t) = (0,0)$ and $(1,1)$. This formalizes the authors' expectation that there are no additional solutions beyond those explicitly found for smaller primes, an assertion they state is implied by GRH and the weak effective abc conjecture.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2816",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28227v1",
    "status": "available",
    "timestamp": "2026-06-29T04:02:38.413060+00:00",
    "title": "No Non-Trivial Higher Prime Powers in 18-gonal Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer n \u2265 3, the minimum number of elements in a poset whose automorphism group is isomorphic to Z_2 \u00d7 Z_{2^n} is 2^{n+1} + 2.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2817",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28231v1",
    "status": "available",
    "timestamp": "2026-06-29T04:06:56.926864+00:00",
    "title": "Minimum Size of a Poset Realizing Z_2 x Z_{2^n}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Diophantine equation $14n^2 - 13n = t^3$ has exactly five integer solutions: $(0, 0)$, $(1, 1)$, $(13, 13)$, $(-1, 3)$, and $(-8, 10)$. This corresponds to the exceptional case $k=13$ in Theorem 1(ii) of the paper, where $P_{30}(n) = t^3$ has the additional solutions $(-1,3)$ and $(-8,10)$ alongside the trivial ones.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2818",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28227v1",
    "status": "available",
    "timestamp": "2026-06-29T04:27:12.259238+00:00",
    "title": "Finiteness of Integer Solutions to the Cubic Triacontagonal Number Equation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any odd prime p and any non-negative integer w, the number of 2-balanced p-regular partitions with p-core \u03ba and p-weight w is independent of the p-core \u03ba and equals C(w + (p-3)/2, w). A partition \u03bb is 2-balanced and p-regular if it is p-regular (no part repeated p or more times) and every hook of \u03bb whose hook length is divisible by p has even arm length.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2819",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28305v1",
    "status": "available",
    "timestamp": "2026-06-29T04:45:41.044531+00:00",
    "title": "Count of 2-balanced p-regular partitions in a block of p-weight w"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For positive integers M and non-negative integers n, define f_{M,n}(t) as (-1)^n times the coefficient of u^n in the formal power series expansion of (u;t)_M / (-u;t)_M, where (u;t)_M = \u220f_{i=0}^{M-1}(1 - u*t^i). The paper establishes that f_{M,n}(t) is a polynomial in t with non-negative integer coefficients and a palindromic coefficient sequence. We conjecture that f_{M,n}(t) is unimodal for all M \u2265 1 and n \u2265 0, meaning its coefficient sequence weakly increases then weakly decreases.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2820",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28108v1",
    "status": "available",
    "timestamp": "2026-06-29T05:04:46.670585+00:00",
    "title": "Unimodality of Modified GJZ Mixed Scalar Factor Coefficients"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Characterize the set of limit points of the largest matching roots $\\mu(G)$ for all finite graphs $G$. Specifically, prove that the set of limit points contains the interval $[\\tau^{1/2} + \\tau^{-1/2}, \\infty)$ and identify the discrete structure of limit points below the threshold $\\tau^{1/2} + \\tau^{-1/2}$, where $\\tau$ is the golden ratio.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2821",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28162v1",
    "status": "available",
    "timestamp": "2026-06-29T05:26:29.809366+00:00",
    "title": "Limit Points of Largest Matching Roots of Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any two linear recurrence sequences derived from a generalized Ankeny\u2013Brauer\u2013Chowla polynomial and its reciprocal with distinct degree parameters, there are at most two common terms exceeding a computable bound depending on the polynomial coefficients.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2822",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27885v1",
    "status": "available",
    "timestamp": "2026-06-29T05:44:28.240696+00:00",
    "title": "Large common values of generalized Ankeny-Brauer-Chowla recurrences"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The 27-vertex unit-distance graph G_27 constructed by Matolcsi, Ruzsa, Varga, and Zs\u00e1mboki has geometric fractional chromatic number exactly 4. Adding two suitably chosen augmentation vertices (at specific positions in the plane) yields a 29-vertex unit-distance graph whose geometric fractional chromatic number is strictly greater than 4. This is the key technical step that, combined with the blow-up framework of Matolcsi et al., implies the existence of a finite unit-distance graph with independence ratio below 1/4 and that the fractional chromatic number of the plane exceeds 4.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2823",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T04:07:09.204966+00:00",
    "title": "The 29-vertex augmented unit-distance graph has geometric fractional chromatic number strictly greater than 4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every prime power q \u2265 2, the expected coverage time of the coupon collector process under uniform sampling from the line set of the projective plane PG(2,q) strictly exceeds the expected coverage time under uniform sampling from all (q+1)-subsets of a (q\u00b2+q+1)-element set. The paper establishes this for q=2 (the Fano plane) and verifies it computationally for small q, but a general proof remains open.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2824",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28216v1",
    "status": "available",
    "timestamp": "2026-06-29T04:27:32.789484+00:00",
    "title": "Projective Plane Mechanisms Dominate Full Model in Coupon Collection"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every pairwise reflection-symmetric Latin square (a generalized Latin rectangle with \u03bb=1) of order n is isotopic to the Cayley table of an elementary abelian 2-group. This formalizes the authors' conjecture that the group-theoretic structure observed in computational searches is unavoidable for the base case of \u03bb=1, explaining why existence requires n to be a power of two.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2825",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28315v1",
    "status": "available",
    "timestamp": "2026-06-29T05:06:25.296717+00:00",
    "title": "Pairwise Reflection-Symmetric Latin Squares are Elementary Abelian 2-Groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let $X$ be a finite simplicial complex covered by subcomplexes $A_1, \\dots, A_k$. For each non-empty subset $S \\subseteq [k]$, let $Y_S = \\cap_{i \\in S} A_i$, and let $V_S$ be an acyclic gradient vector field on $Y_S$. The combinatorial nerve chain complex $C_*(X; V)$ is defined such that for each integer $n$, the chain group $C_n(X; V)$ is the direct sum over all non-empty subsets $S \\subseteq [k]$ of the free abelian group generated by the $(n - |S| + 1)$-dimensional critical simplices of $V_S$ on $Y_S$. Equipped with the differentials combining the internal Morse differentials and the nerve face maps defined via gradient trajectories between the intersections, $C_*(X; V)$ is chain homotopy equivalent to the simplicial chain complex of $X$.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2826",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28047v1",
    "status": "available",
    "timestamp": "2026-06-29T05:28:37.951608+00:00",
    "title": "Combinatorial Nerve Chain Homotopy Equivalence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture asserts that for irreducible admissible generic representations \u03c0\u2081 and \u03c0\u2082 of GL\u2086(F) with identical central characters, the local \u03b3-factor of the exterior cube representation twisted by a sufficiently ramified character \u03c7 remains stable, leveraging geometric realizations via the E\u2086 maximal parabolic subgroup and invariants of the quotient U_M\\N'.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2827",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28091v1",
    "status": "available",
    "timestamp": "2026-06-29T05:44:39.351935+00:00",
    "title": "Stability of Exterior Cube \u03b3-Factors under Central Character Equality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture examines the existence of finite unit-distance graphs in the plane with independence ratio below 1/4, offering a falsifiable direction for constructive geometric graph theory.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2828",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T05:45:25.558013+00:00",
    "title": "Proving that unit-distance graphs with low independence ratios exist"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every \u03c4_k-maximal graph on n vertices (with n \u2265 2k+2) has exactly (k+1)(n-1)-1 edges. A graph is \u03c4_k-maximal if it contains no subgraph with k+1 edge-disjoint spanning trees, yet adding any edge from its complement creates such a subgraph.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2829",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28198v1",
    "status": "available",
    "timestamp": "2026-06-29T06:06:52.919140+00:00",
    "title": "Edge count equality for \u03c4_k-maximal graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for any deformation parameters t and s the mixed product of the modified Greaves\u2011Jing\u2011Zhu operators yields a scalar factor that can be expressed as a rational function of infinite q\u2011Pochhammer symbols: F(t,s;u) = (u;t)_\\u221e (\u2011u;s)_\\u221e / ((\u2011u;t)_\\u221e (u;s)_\\u221e). Moreover, the q\u2011expansion of F(t,s;u) has palindromic coefficients and satisfies a finite\u2011order linear recurrence; after removing the alternating signs the coefficients are non\u2011negative integers.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2830",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28108v1",
    "status": "available",
    "timestamp": "2026-06-29T06:24:54.047368+00:00",
    "title": "Generalized scalar factor for mixed modified Greaves\u2011Jing\u2011Zhu operators"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: The set of limit points of the largest matching roots of all finite simple graphs is exactly L = { 2 * cos(\u03c0/k) | k \u2208 \u2115, k \u2265 3 } \u222a [ \u221a\u03c4 + \u03c4^{-1/2}, \u221e ), where \u03c4 = (1+\u221a5)/2 is the golden ratio. In particular, for each integer k \u2265 3 there exists a sequence of pairwise distinct graphs (G_n) such that \u03bc(G_n) \u2192 2 * cos(\u03c0/k) as n \u2192 \u221e.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2831",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28162v1",
    "status": "available",
    "timestamp": "2026-06-29T06:42:13.213073+00:00",
    "title": "Limit points of largest matching roots below the golden\u2011ratio threshold"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that the error term in the asymptotic count of entries not divisible by \u2113 in the character table of GL\u2082(\ud835\udd3d_q) is O(q\u00b3) rather than O(q\u00b3+\u03b5).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2832",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28085v1",
    "status": "available",
    "timestamp": "2026-06-29T07:01:40.248934+00:00",
    "title": "Refined Asymptotic for Non-Divisible Entries in GL\u2082(\ud835\udd3d_q) Character Tables"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The triangle map, a multi-dimensional continued fraction algorithm, possesses a natural extension that can be partitioned into four subdomains. This conjecture posits that the transformation representing the natural extension is equivariant under a discrete symmetry group acting on these subdomains, which is a dynamical analogue of the Young conjugation symmetry found in integer partitions.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2834",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28014v1",
    "status": "available",
    "timestamp": "2026-06-29T07:36:21.124370+00:00",
    "title": "Symmetry of the Natural Extension of the Triangle Map via Young Conjugation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any sequence of growing preferential attachment graphs with degree exponent \u03c4 \u2208 (2,3) whose local weak limit is a continuous-time branching process with power-law offspring distribution of exponent \u03c4, the bond percolation critical window and component size scalings are identical to those of the inhomogeneous random graph with preferential attachment kernel. Specifically, the critical retention probability satisfies p_c(n) = \u0398(n^((\u03c4-3)/(2\u03c4-2))), and the largest component size L\u2081(p_n) exhibits three regimes: (1) p_n \u226b p_c(n) \u21d2 L\u2081(p_n) = \u0398_P(n p_n^((\u03c4-1)/(3-\u03c4))) with uniqueness; (2) n^(1/(1-\u03c4)) \u226a p_n \u226a p_c(n) \u21d2 L\u2081(p_n) = \u0398_P(n^(1/(\u03c4-1)) p_n) with non-uniqueness; (3) p_n = \u0398(p_c(n)) \u21d2 L\u2081(p_n)/\u221an converges in distribution to a non-degenerate limit characterized by a subcritical Norros-Reittu graph.",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "id": "fd_2835",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27844v1",
    "status": "available",
    "timestamp": "2026-06-29T07:54:37.496843+00:00",
    "title": "Universality of critical percolation scaling for preferential attachment graphs with infinite variance"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the affine quiver of type \u00c3_n with any acyclic orientation, the source-sink pair is the unique banded pair whose coordinate projection fails to fill its band. Specifically, for any pair of vertices (v, w) with \u03b4_v = \u03b4_w (which holds for all pairs in \u00c3_n since all null-root coefficients equal 1), the projection \u03c0_{vw}(C(Q)) fills its band if and only if {v, w} is not the source-sink pair of the given orientation. This extends the paper's complete resolution for the source-sink orientation to all acyclic orientations.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2836",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27523v1",
    "status": "available",
    "timestamp": "2026-06-29T08:22:15.779388+00:00",
    "title": "Source-sink uniqueness of non-filling banded pairs in affine type \u00c3"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the parametric harmonic zeta function \u03b6_H(s,a,b) = \u03a3_{n\u22650} H_n(a)/(n+b)^s where H_n(a) = \u03a3_{k=1}^n 1/(k+a) is the generalized harmonic number and \u03c8 denotes the digamma function, the Laurent expansion at the double pole s=1 satisfies: (1) the leading coefficient of (s-1)^{-2} equals 1, independent of both a and b; (2) the coefficient of (s-1)^{-1} equals -\u03c8(a+1), independent of b. This generalizes the known pole structure of the classical harmonic zeta function \u03b6_H(s) = \u03b6_H(s,0,1) and formalizes the residue computation announced in the paper for the parametric case.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2837",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27827v1",
    "status": "available",
    "timestamp": "2026-06-29T08:49:03.695794+00:00",
    "title": "Laurent expansion coefficients of the parametric harmonic zeta function at its double pole s=1"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every optimal 1-planar graph with connectivity 6 is (5,5)-linked. Formally, for any 6-connected optimal 1-planar graph G and any two disjoint vertex subsets S1, S2 of size 5, there exist vertex-disjoint connected subgraphs G1, G2 of G such that S1 is contained in the vertex set of G1 and S2 is contained in the vertex set of G2.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2838",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27682v1",
    "status": "available",
    "timestamp": "2026-06-29T09:07:48.439935+00:00",
    "title": "6-Connected Optimal 1-Planar Graphs are (5,5)-Linked"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture posits that non-trivial first homology groups arise only in specific exceptional cases like the Petersen graph or similar structures under Neumaier's classification, ruling out triviality in other contexts.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2839",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27328v1",
    "status": "available",
    "timestamp": "2026-06-29T09:33:10.755240+00:00",
    "title": "Trivial Homology Exceptions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers $k \\ge 1$, $n \\ge 0$, and $s \\in \\mathbb{Z}$, the coefficient of $q^n z^s$ in the normalized Jacobi triple product tail $J_k(z,q)$ is a non-negative integer. This resolves Merca's stronger nonnegativity conjecture on truncated Jacobi triple product series and generalizes the coefficientwise positivity of truncated pentagonal number series.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2840",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27507v1",
    "status": "available",
    "timestamp": "2026-06-29T09:51:27.157957+00:00",
    "title": "Coefficientwise Positivity of Normalized Jacobi Triple Product Tails"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for every projective plane of order q (q \u2265 2), the family of its lines (a 2-(q^2+q+1, q+1, 1) design) defines a fair \u2113\u2011regular mechanism whose expected coupon\u2011collection time strictly exceeds that of the fully random model on the same parameters, and that this mechanism attains the maximal possible expected time among all uniform \u2113\u2011regular families on the underlying n\u2011set.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2841",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28216v1",
    "status": "available",
    "timestamp": "2026-06-29T05:46:31.738498+00:00",
    "title": "Extremality of Projective Plane Block Designs in the Coupon Collector's Problem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any integers d>1, e>1 with (e-3) divisible by d, the number of d-balanced e-regular partitions in a block of e-weight w equals the binomial coefficient \\(\\binom{w + (e-3)/d}{w}\\).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2842",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28305v1",
    "status": "available",
    "timestamp": "2026-06-29T06:07:11.760301+00:00",
    "title": "Binomial Count Conjecture for d-balanced e-regular Partitions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that a Latin square of order n is pairwise reflection\u2011symmetric (i.e., for every pair of columns each ordered symbol pair (p,q) occurs as often as its reversal (q,p)) if and only if n is a power of two. This captures the claimed \u03bb=1 case and is falsifiable by exhibiting a counterexample for a non\u2011power\u2011of\u2011two n or proving impossibility.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2843",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28315v1",
    "status": "available",
    "timestamp": "2026-06-29T06:25:21.502180+00:00",
    "title": "Pairwise Reflection-Symmetric Latin Squares Exist Exactly for Powers of Two"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper proves that for $t \\geq 2$ and $n \\geq 28t-17$, the unique $tK_3$-free graph of order $n$ maximizing the signless Laplacian spectral radius is $K_{t-1} \\vee K_{\\lfloor (n-t+1)/2 \\rfloor, \\lceil (n-t+1)/2 \\rceil}$. For $t=2$, this holds for all $n \\geq 6 = 3 \\cdot 2$. We conjecture that the bound $28t-17$ can be universally improved to $3t$ for all $t \\geq 2$.",
    "domains": [
      "Pythagorean",
      "Physics"
    ],
    "id": "fd_2844",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28121v1",
    "status": "available",
    "timestamp": "2026-06-29T06:44:32.889471+00:00",
    "title": "Improved Bound for Signless Laplacian Spectral Radius of $tK_3$-Free Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This paper proposes a computational framework to determine homology groups of simplicial complexes through discrete Morse theory and gradient vector fields, offering a formalizable path for practical applications.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2845",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28047v1",
    "status": "available",
    "timestamp": "2026-06-29T07:01:46.131020+00:00",
    "title": "A combinatorial approach to the effective nerve theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any regular n-maniplex M, the automorphism group of its flag graph, the automorphism group of its 1-skeleton graph, and the automorphism group of its 1-coskeleton graph are all isomorphic to each other and to the automorphism group of M itself. This conjecture formalizes the claim that different canonical graph representations of regular maniplexes preserve their symmetry structure.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2846",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27987v1",
    "status": "available",
    "timestamp": "2026-06-29T07:19:40.613416+00:00",
    "title": "Automorphism Group Equivalence for Regular Maniplex Graph Representations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \u03c1(q) = \u2211_{n\u22650} r(n) q^n be Ramanujan's third order mock theta function defined by \u03c1(q) = \u2211_{m\u22650} q^{2m(m+1)} / \u220f_{k=1}^{m} (1 + q^{2k-1} + q^{4k-2}). Then r(3n) > 0 for all n \u2265 0; r(3n+1) \u2264 0 and r(3n+2) \u2264 0 for all n \u2265 0, with the only zeros being r(2) = r(4) = r(8) = r(11) = r(20) = 0.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2847",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27902v1",
    "status": "available",
    "timestamp": "2026-06-29T07:38:26.099950+00:00",
    "title": "Finite sign conjecture for Ramanujan's third order mock theta function \u03c1(q)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper proves that every spherical (weight 0) automorphic form on SL(2,Z)\\H decomposes into a cusp form and a linear combination of Laurent coefficients of the standard Eisenstein series, using only Green's identity and basic analysis. We conjecture that the same direct proof strategy extends to automorphic forms of any integer weight k, yielding a decomposition of the space A_k(X) into cusp forms of weight k and the span of Laurent coefficients of the weight k Eisenstein series.",
    "domains": [
      "Pythagorean",
      "MachineLearning"
    ],
    "id": "fd_2848",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27749v1",
    "status": "available",
    "timestamp": "2026-06-29T08:01:14.506352+00:00",
    "title": "Generalization of Franke's theorem to higher weight automorphic forms via Green's identity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let K be the function field of a smooth projective geometrically integral curve over a p-adic field. For any smooth, proper, geometrically integral, rationally connected K-variety X, the unramified cohomological obstruction with respect to H^3_nr(X, Q/Z(2)) coincides with the descent obstruction: X(A_K)^{H^3_nr} = X(A_K)^{descent}. This is the analogue over p-adic function fields of Colliot-Th\u00e9l\u00e8ne's conjecture that the Brauer-Manin obstruction is the only obstruction for rationally connected varieties over number fields, replacing the Brauer-Manin obstruction with the unramified obstruction as justified by cohomological dimension constraints.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_2849",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27699v1",
    "status": "available",
    "timestamp": "2026-06-29T08:26:12.505105+00:00",
    "title": "Unramified Obstruction Equals Descent Obstruction for Rationally Connected Varieties over p-adic Function Fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer n \u2265 4, there exists a diagonal quantum Latin square of order n (DQLS(n)) with maximum cardinality n\u00b2, meaning all n\u00b2 entries are pairwise distinct up to a global phase, and both the main diagonal and anti-diagonal each form an orthonormal basis of the n-dimensional Hilbert space.",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_2850",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27758v1",
    "status": "available",
    "timestamp": "2026-06-29T08:49:17.434420+00:00",
    "title": "Existence of Maximum Cardinality Diagonal Quantum Latin Squares for All Orders n \u2265 4"
  },
  {
    "consumed_by_exp_id": "1eb7e7f0",
    "description": "For all integers m \u2265 3 and n \u2265 m with n \u2261 m (mod 2) and (m\u00b2 \u2212 2m + n) \u2223 n(n\u22121), there exists a Class-Uniformly Resolvable Design on n varieties with partition m^1 2^{(n\u2212m)/2} and \u03bb = 1. The paper establishes these as necessary conditions and proves existence when m is a power of an odd prime (via affine plane-derived construction) and when m = 2k for certain cyclic designs. The conjecture asserts these divisibility and parity conditions are also sufficient, making the existence problem completely solved.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2851",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27519v1",
    "status": "in_progress",
    "timestamp": "2026-06-29T09:08:52.620285+00:00",
    "title": "Necessary Conditions are Sufficient for CURD Existence with Partition m^1 2^{(n-m)/2}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every \u03b5 > 0, there exists T\u2080(\u03b5) > 0 such that for all T \u2265 T\u2080(\u03b5), \u222b\u2080\u1d40 |\u03b6(1/2 + it)|\u2076 dt \u2265 (42 - \u03b5) \u00b7 c\u2083 \u00b7 T \u00b7 (log T)\u2079, where c\u2083 = a\u2083/9! and a\u2083 is the Keating\u2013Snaith arithmetic factor defined by the Euler product \u220f_p (1 - 1/p)\u2079 \u03a3_{m\u22650} (\u0393(m+3)/(\u0393(m+1)\u00b7\u0393(3)))\u00b2 \u00b7 p\u207b\u1d50. This asserts that the lim inf of M\u2083(T)/(c\u2083\u00b7T\u00b7(log T)\u2079) equals 42, matching the Keating\u2013Snaith conjecture from the lower bound side, and would improve the current unconditional constant of 34.1 established in the paper.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2852",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27323v1",
    "status": "available",
    "timestamp": "2026-06-29T09:33:31.386723+00:00",
    "title": "Sharp lower bound for the sixth moment of the Riemann zeta function"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any partition \u03bb of n and any support pattern S \u2286 [n] \u00d7 [n], the number of n \u00d7 n nilpotent matrices over F_q with Jordan canonical form type \u03bb and support contained in S is a polynomial in q with non-negative integer coefficients. This extends known polynomiality results for Hessenberg supports (connected to chromatic quasisymmetric function evaluations via Shareshian\u2013Wachs theory) and directly addresses the polynomiality questions the paper raises for more general support patterns and prescribed affine slices of adjoint orbits.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2853",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.27497v1",
    "status": "available",
    "timestamp": "2026-06-29T09:52:47.763963+00:00",
    "title": "Polynomiality of Nilpotent Matrix Counts with Prescribed Support"
  },
  {
    "consumed_by_exp_id": "170495dc",
    "description": "There exists a finite unit-distance graph G in the Euclidean plane whose independence ratio \u03b1(G)/|V(G)| is strictly less than 1/4. This answers Erd\u0151s's 1987 question in the negative and implies that the fractional chromatic number of the plane \u03c7_f(\u211d\u00b2) > 4. The proof relies on showing that a two-vertex augmentation of the 27-vertex configuration G\u2082\u2087 from Matolcsi et al. yields a point configuration with geometric fractional chromatic number strictly greater than 4.",
    "domains": [
      "Geometry",
      "Logic"
    ],
    "id": "fd_2854",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "in_progress",
    "timestamp": "2026-06-29T10:03:39.505176+00:00",
    "title": "Existence of a finite unit-distance graph in the plane with independence ratio strictly less than 1/4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Diophantine equation $P_{14}(n) = t^4$ has exactly five solutions in integers $(n,t)$: $(0,0)$, $(1,1)$, $(1,-1)$, $(-2000, 70)$, and $(-2000, -70)$. This corresponds to the specific case $k=5$ (where $s=2k+4=14$) in Theorem 1(i) of the paper, which fully lists the solutions for this sub-family.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2855",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28227v1",
    "status": "available",
    "timestamp": "2026-06-29T10:22:21.182498+00:00",
    "title": "Complete classification of 4th powers in the 14-gonal numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper proves that for integers $k \\ge 1$ and $n \\ge 2k+2$, any $\\tau_k$-maximal graph on $n$ vertices has at most $(k+1)(n-1)-1$ edges, and constructs examples achieving this bound. The authors conjecture that this upper bound is actually an exact equality: every $\\tau_k$-maximal graph on $n \\ge 2k+2$ vertices has exactly $(k+1)(n-1)-1$ edges. This conjecture is verified for $k=1$, but remains open for $k \\ge 2$.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2856",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28198v1",
    "status": "available",
    "timestamp": "2026-06-29T10:44:44.698882+00:00",
    "title": "Exact Edge Count of Tau_k-Maximal Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any positive integer M and non-negative integer k, the principal specialization of the one-row Schur Q-function q_k evaluated at 1, t, ..., t^{M-1} (which equals the coefficient of u^k in the formal power series expansion of \u220f_{i=0}^{M-1} (1+ut^i)/(1-ut^i)) is a polynomial in t with non-negative integer coefficients, which is palindromic of degree k(M-1).",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2857",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28108v1",
    "status": "available",
    "timestamp": "2026-06-29T11:03:33.515587+00:00",
    "title": "Palindromicity and Non-Negativity of Principal Specializations of One-Row Schur Q-Functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The number of 2-balanced p-regular partitions in any block of p-weight w for an odd prime p is precisely the binomial coefficient C(w + (p-3)/2, w). A partition is 2-balanced p-regular if it is p-regular and every hook of length divisible by p has an even arm length.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2859",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28305v1",
    "status": "available",
    "timestamp": "2026-06-29T10:45:11.578131+00:00",
    "title": "Enumeration of 2-balanced p-regular partitions in blocks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every pairwise reflection-symmetric Latin square of order 2^k (for k \u2265 1) is isotopic to the Cayley table of the elementary abelian 2-group (Z/2Z)^k. This formalizes the paper's conjecture that group-theoretic structure is unavoidable for pairwise reflection-symmetric designs with column multiplicity \u03bb = 1. The paper proves existence iff n is a power of 2 and computationally observes that all found examples possess group structure, conjecturing this may be necessary.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2860",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28315v1",
    "status": "available",
    "timestamp": "2026-06-29T11:04:31.405897+00:00",
    "title": "Elementary Abelian 2-Group Uniqueness for Pairwise Reflection-Symmetric Latin Squares"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer $n \\ge 3$, the minimum number of elements in a poset $P$ such that its automorphism group $\\text{Aut}(P)$ is isomorphic to $\\mathbb{Z}_2 \\times \\mathbb{Z}_{2^n}$ is exactly $2^{n+1} + 2$. This conjecture formalizes the main theorem of the paper.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2861",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28231v1",
    "status": "available",
    "timestamp": "2026-06-29T11:24:35.150210+00:00",
    "title": "Poset Realization Size for $\\mathbb{Z}_2 \\times \\mathbb{Z}_{2^n}$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper proves that augmenting the 27-vertex configuration G\u2082\u2087 with two carefully chosen vertices yields a 29-vertex configuration G\u2082\u2089 whose geometric fractional chromatic number \u03c7_gf(G\u2082\u2089) is strictly greater than 4. This conjecture asserts an explicit quantitative bound: \u03c7_gf(G\u2082\u2089) \u2265 4 + 1/1000. Since the proof characterizes all 23 extremal colorings of G\u2082\u2087 and shows the two augmentation vertices simultaneously violate all of them, an explicit gap above 4 should be computable from the finite-dimensional linear program with 182304 variables. Proving this would yield the first explicit rational lower bound on \u03c7_f(\u211d\u00b2) above 4.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2862",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T11:25:09.618081+00:00",
    "title": "Explicit quantitative lower bound on the geometric fractional chromatic number of the augmented 29-vertex configuration"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any prime p and integer n \u2265 3, the minimum size of a poset P whose automorphism group is isomorphic to Z_p \u00d7 Z_{p^n} is p^{n+1} + p. This generalizes the paper's exact result for p=2 to all prime cyclic factors.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2863",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28231v1",
    "status": "available",
    "timestamp": "2026-06-29T11:43:51.082315+00:00",
    "title": "Minimum Poset Size for Realizing Z_p x Z_{p^n}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "There exists a finite unit-distance graph G in the Euclidean plane such that the independence number \u03b1(G) is strictly less than |V(G)|/4. This formalizes the main theorem answering Erd\u0151s's 1987 question, and implies that the fractional chromatic number of the plane exceeds 4. The proof strategy involves augmenting the 27-vertex configuration G\u2082\u2087 of Matolcsi et al. (which has geometric fractional chromatic number exactly 4) with two carefully chosen vertices to obtain a configuration whose geometric fractional chromatic number strictly exceeds 4, followed by two blow-up procedures.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2864",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T11:55:09.405767+00:00",
    "title": "Existence of a finite unit-distance graph with independence ratio below 1/4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The 14-gonal numbers are given by $P_{14}(n) = 6n^2 - 5n$. Theorem 1 of the paper states that the Diophantine equation $P_{14}(n) = t^4$ has only the solutions $(n, t) = (0, 0), (1, \\pm 1)$ and $(-2000, \\pm 70)$. This can be reduced to finding the integer points on the elliptic curve $X^2 - 24Y^4 = 25$. The conjecture asserts that these are the only solutions, providing a complete characterization of perfect fourth powers in the sequence of 14-gonal numbers.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2865",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28227v1",
    "status": "available",
    "timestamp": "2026-06-29T12:13:10.760960+00:00",
    "title": "Complete solutions to $P_{14}(n) = t^4$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any finite projective plane of order q \u2265 2, the expected coverage time of its line set as a fair coupon collecting mechanism is strictly greater than the expected coverage time of the fully random model on n=q^2+q+1 coupons with draw size \u2113=q+1. This generalizes the paper's explicit Fano plane (q=2) counterexample to all projective planes, asserting that finite geometric structure universally slows down fair coupon collection compared to the full combinatorial model.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2866",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28216v1",
    "status": "available",
    "timestamp": "2026-06-29T12:14:01.655400+00:00",
    "title": "Projective Plane Extremality in Fair Coupon Collecting"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let G_27 be the 27-vertex unit-distance graph defined by Matolcsi, Ruzsa, Varga, and Zs\u00e1mboki, and let G_29 be the 29-vertex unit-distance graph obtained by augmenting G_27 with the two specific vertices identified in the present paper. The conjecture states that the geometric fractional chromatic number of G_29 is strictly greater than 4, which forms the core computational step demonstrating that the fractional chromatic number of the plane exceeds 4.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2867",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T15:22:21.921604+00:00",
    "title": "Strictly Greater Geometric Fractional Chromatic Number of the Augmented 29-Vertex Graph"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Diophantine equation P_30(n) = t^3, which expands to 14n^2 - 13n = t^3, has exactly five integer solutions (n, t): (0,0), (1,1), (13,13), (-1,3), and (-8,10). This corresponds to the k=13 case of Theorem 1(ii) in the paper, where s=2k+4=30.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2868",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28227v1",
    "status": "available",
    "timestamp": "2026-06-29T15:39:46.199817+00:00",
    "title": "Complete Integer Solutions to P_30(n) = t^3"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In the coupon collector's problem with n=7 coupons and draws of size \u2113=3, the expected time to collect all coupons under the Fano plane mechanism (uniformly sampling from the 7 lines of PG(2,2)) strictly exceeds the expected time under the full model (uniformly sampling from all C(7,3)=35 three-element subsets). Both are fair mechanisms: each coupon appears in exactly 3 of the 7 Fano lines and in exactly 15 of the 35 triples. This disproves the Grunbaum-Yaakobi conjecture that the full model maximizes expected coverage time among fair mechanisms.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2869",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28216v1",
    "status": "available",
    "timestamp": "2026-06-29T15:41:31.789327+00:00",
    "title": "Fano Plane Mechanism Strictly Dominates Full Model in Expected Coverage Time"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers $n \\ge 1$, the minimum size of a finite poset $P$ such that the automorphism group of $P$ is isomorphic to $\\mathbb{Z}_2 \\times \\mathbb{Z}_{2^n}$ is $2^{n+1} + 2$. This unifies the paper's main theorem (which covers $n \\ge 3$) with the known small cases for $n=1, 2$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2870",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28231v1",
    "status": "available",
    "timestamp": "2026-06-29T15:51:19.597804+00:00",
    "title": "Minimum Size of a Poset Realizing $\\mathbb{Z}_2 \\times \\mathbb{Z}_{2^n}$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The 27-vertex unit-distance graph configuration G\u2082\u2087 of Matolcsi, Ruzsa, Varga, and Zs\u00e1mboki has geometric fractional chromatic number exactly 4. Augmenting this configuration with two specifically chosen additional vertices (as explicitly constructed in the paper) yields a 29-vertex unit-distance graph G\u2082\u2089 whose geometric fractional chromatic number is strictly greater than 4. This is the key lemma that, via the blow-up framework, implies \u03c7_f(\u211d\u00b2) > 4 and answers Erd\u0151s's question in the negative. The proof proceeds by characterizing all 23 extremal geometric fractional colorings of G\u2082\u2087 (forming a convex polytope of affine dimension 11) and showing by linear programming that none of these can be extended to color the augmented graph with fractional chromatic number exactly 4.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_2871",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T15:51:56.356300+00:00",
    "title": "Geometric fractional chromatic number of the 29-vertex augmented unit-distance graph exceeds 4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integers $k \\ge 0$ and $n \\ge 3$, the minimum size of a poset realizing the non-cyclic abelian group $\\mathbb{Z}_2^k \\times \\mathbb{Z}_{2^n}$ as its automorphism group is $\\beta(\\mathbb{Z}_2^k \\times \\mathbb{Z}_{2^n}) = 2^{n+1} + 2k$. The upper bound follows from iteratively applying the paper's Proposition on $\\beta(A \\times \\mathbb{Z}_2)$, and the conjecture asserts that this iterative construction is strictly optimal.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2872",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28231v1",
    "status": "available",
    "timestamp": "2026-06-29T16:15:09.386788+00:00",
    "title": "Minimum Size of Posets Realizing $\\mathbb{Z}_2^k \\times \\mathbb{Z}_{2^n}$ as Automorphism Groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "There exists a finite set of points in the Euclidean plane such that the unit-distance graph induced by these points has independence ratio strictly less than 1/4. This answers Erd\u0151s's 1987 question negatively, disproves Conjecture 1 of Matolcsi-Ruzsa-Varga-Zs\u00e1mboki, and implies that the fractional chromatic number of the plane \u03c7_f(\u211d\u00b2) > 4.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2873",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T16:16:05.000362+00:00",
    "title": "Existence of a finite unit-distance graph in R\u00b2 with independence ratio below 1/4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Generalizing the paper's main theorem from Z_2 x Z_{2^n} to Z_2^k x Z_{2^n}, we conjecture that the minimum size of a poset realizing the abelian group Z_2^k x Z_{2^n} is 2^{n+1} + 2k for any k >= 1 and n >= 3. This matches the upper bound obtained by iteratively applying Proposition 1.1 to a minimal poset for Z_{2^n}.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2874",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28231v1",
    "status": "available",
    "timestamp": "2026-06-29T16:28:32.494303+00:00",
    "title": "Conjecture on the Minimum Size of a Poset Realizing Z_2^k x Z_{2^n}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The polytope of optimal geometric fractional colorings of the 27-vertex unit-distance graph G27, defined by Matolcsi et al., has exactly 23 vertices (extremal colorings) and affine dimension 11.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2875",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.28157v1",
    "status": "available",
    "timestamp": "2026-06-29T16:29:26.666347+00:00",
    "title": "Dimension and Vertex Count of the Optimal Geometric Fractional Coloring Polytope for G27"
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
    "description": "Formalize Frankl's conjecture and prove it for families of size \u2264 50 (Bo\u0161njak-Markovi\u0107). Prove the conjecture for families with a 3-element universe. Formalize the lattice-theoretic reformulation and Reimer's entropy approach.",
    "domains": [
      "Combinatorics",
      "Algebra"
    ],
    "id": "seed_353",
    "priority_score": 0.8,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-18T03:56:25.432728+00:00",
    "title": "Frankl's Union-Closed Conjecture: Partial Results"
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
    "description": "Prove that the reverse-and-add algorithm applied to 196 never produces a palindrome. Formalize the concept of Lychrel numbers and establish structural properties of the iteration on digit sequences.",
    "domains": [
      "Algebra"
    ],
    "id": "seed_007",
    "priority_score": 0.72,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
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
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.814374+00:00",
    "title": "The Geometry of Consensus: Arrow's Theorem as Curvature"
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
    "consumed_by_exp_id": "3ec587ed",
    "description": "Formalize ODEs of the form y' = R(x,y) where R is an EML function. Prove the differential Galois theory for EML equations: the Galois group is an EML group. Show that the Kovacic algorithm decides if a second-order linear EML ODE has EML solutions. Prove that Airy's equation y'' = xy has no EML solutions.",
    "domains": [
      "EML",
      "Computation"
    ],
    "id": "fd_0551",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-03T22:10:07.873771+00:00",
    "title": "EML Differential Equations: ODEs with Exponential-Logarithmic Coefficients"
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
    "description": "Investigate the sequence \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order. with terms 127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,4096,6455,11264,11664,12850,13825,14641,155. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2811",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:80035",
    "status": "available",
    "timestamp": "2026-06-29T03:32:05.123415+00:00",
    "title": "OEIS sequence: \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order."
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
    "description": "Prove specific cases of Langlands functoriality: the transfer from GL(2) to GL(3), or symmetric power liftings. Formalize automorphic representations and L-functions in Lean 4.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0398",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.154250+00:00",
    "title": "Langlands Program: Functoriality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize neural network architectures as morphisms in a monoidal category. Prove that ResNet skip connections are categorical products, attention is a natural transformation, and architecture search is optimization in a functor category.",
    "domains": [
      "MachineLearning",
      "Algebra"
    ],
    "id": "fd_0400",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.309278+00:00",
    "title": "Category-Theoretic Neural Architectures"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that vanishing first sheaf cohomology on neural network weight spaces implies certified L-infinity perturbation radius. Construct explicit sheaf structures on decision boundaries whose stalk cohomology detects adversarial vulnerability.",
    "domains": [
      "MachineLearning",
      "Algebra"
    ],
    "id": "fd_0401",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.385376+00:00",
    "title": "Certified Adversarial Robustness via Sheaf Cohomology"
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
    "consumed_by_exp_id": "d7a2dfdf",
    "description": "Formalize Joyal's combinatorial species as endofunctors on the category of finite sets. Prove that the exponential generating function of a species equals its analytic functor. Bridge enumerative combinatorics to category theory and analytic combinatorics.",
    "domains": [
      "Bridges",
      "Computation"
    ],
    "id": "fd_0450",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-03T19:55:29.353451+00:00",
    "title": "Combinatorial-Categorical Bridge: Species of Structures as Functors"
  },
  {
    "consumed_by_exp_id": "7f917f25",
    "description": "Prove tight upper bounds on the differential probability of an S-box. Formalize the wide-trail strategy used in AES: prove that the minimum number of active S-boxes in 4 rounds of AES is 25. Connect to the branch number of the MixColumns matrix.",
    "domains": [
      "Cryptography",
      "Algebra"
    ],
    "id": "fd_0461",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-03T19:55:30.236800+00:00",
    "title": "Symmetric-Key Cryptanalysis: Differential and Linear Cryptanalysis Bounds"
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
    "description": "Treat chaotic attractors (Lorenz, Henon, Rossler) as algebraic objects \u2014 not just numerical phenomena. Conjecture: The Lorenz attractor's topology can be characterized as the inverse limit of a specific diagram in the category of finite directed graphs. Test: compute the inverse limit and compare its Cech cohomology to the known Lorenz template. Impact: if true, chaotic dynamics become amenable to algebraic topology and category-theoretic methods.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_0484",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:45.326758+00:00",
    "title": "Strange Attractors as Algebraic Objects"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The EML single operator f(x) = e^a * log(b*x + c) is a contraction mapping for suitable parameter ranges. Conjecture: For all a, b, c in R with a > 0 and b, c chosen so that the function maps a closed interval to itself, the iteration x_{n+1} = e^a * log(b*x_n + c) converges to a unique fixed point x* at a rate O(rho^n) where rho = |f'(x*)|. Moreover, the fixed point x* satisfies x* = e^a * log(b*x* + c) and can be expressed as a power series in a. The fixed point is unique because f is a contraction on the invariant interval: the derivative f'(x) = e^a * b / (b*x + c) is bounded by |f'| < 1 when the parameters are in the right range. This makes EML functions well-behaved iterative schemes, unlike arbitrary neural network activations. Test: prove convergence for the specific case a in (0,1), b=1, c in (0,1) and compute the fixed point explicitly as a series. Impact: establishes EML as having well-defined dynamical behavior, enabling EML-based iterative algorithms with certified convergence.",
    "domains": [
      "EML",
      "Algebra"
    ],
    "id": "fd_0491",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:45.843772+00:00",
    "title": "EML Fixed-Point Theorem: exp-log Iteration Convergence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Stone-Weierstrass theorem guarantees that any continuous function can be approximated by an algebra that separates points and contains constants. Conjecture: The algebra of EML functions (finite compositions of exp, log, +, *) on any compact subset of R^n is dense in C(K) with a Jackson-type rate: for f in Lip_alpha(K), there exists an EML network of width O(epsilon^{-n/alpha}) approximating f within epsilon. The separation property is key: given x != y in K, the function g(t) = exp(a)*log(b*t + c) can separate them for appropriate parameters a, b, c (because g is strictly monotone for a, b > 0). The constants are included via c = exp(a)*log(c) for c > 0. This gives EML networks provable approximation guarantees with explicit rates, going beyond the existential guarantees of universal approximation theorems. Test: prove the separation property (given x != y in K, find EML parameters that separate them) and the rate bound for Lipschitz functions. Construct an EML network of width n approximating x^2 on [0,1] with explicit error bounds. Impact: gives EML networks provable approximation guarantees with explicit rates, surpassing the existential guarantees of universal approximation theorems.",
    "domains": [
      "EML",
      "Algebra"
    ],
    "id": "fd_0493",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:45.995091+00:00",
    "title": "EML Interpolation Theory: Stone-Weierstrass for exp-log Networks"
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
    "description": "Prove that the class of EML functions (compositions of exp, log, and field operations) is dense in C([0,1]^n) with respect to the uniform norm. Show that the approximation rate depends on the depth of the EML composition and derive explicit bounds for shallow networks.",
    "domains": [
      "EML",
      "Algebra"
    ],
    "id": "fd_0508",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.125386+00:00",
    "title": "EML Universal Approximation: Density of EML Functions"
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
    "description": "Formalize the attention mechanism A(Q,K,V) = softmax(QK^T / sqrt(d_k)) V. Prove that permutation-equivariant attention is a universal approximator of permutation-equivariant functions. Show that the attention kernel K(x,y) = exp(q(x)^T k(y) / sqrt(d)) defines a reproducing kernel Hilbert space. Prove that multi-head attention increases the rank of the attention matrix.",
    "domains": [
      "MachineLearning",
      "Algebra"
    ],
    "id": "fd_0557",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-03T22:10:08.377996+00:00",
    "title": "ML Attention Mechanism: Formal Properties of Transformers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize transseries as formal series in x, log(x), exp(x), exp(exp(x)), etc. Prove that the field of transseries is real closed. Show that every EML function has a transseries expansion that uniquely determines it. Prove the asymptotic comparison theorem: if two transseries agree to all orders, they are equal.",
    "domains": [
      "EML",
      "Logic"
    ],
    "id": "fd_0552",
    "priority_score": 0.5099999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T22:10:07.956863+00:00",
    "title": "EML Transseries: Asymptotic Expansions Beyond Power Series"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the tropical Riemann-Roch theorem: for a tropical curve of genus g and a divisor D of degree d, the tropical rank r(D) satisfies r(D) - r(K-D) = d - g + 1. Formalize chip-firing and Baker-Norine theory.",
    "domains": [
      "Tropical",
      "Algebra"
    ],
    "id": "fd_0403",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:25.547297+00:00",
    "title": "Tropical Riemann-Roch Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove the Langlands correspondence for GL\u2082 over Q: every algebraic automorphic representation corresponds to a Galois representation. Formalize Eichler-Shimura and Deligne cases.",
    "domains": [
      "Bridges",
      "Algebra"
    ],
    "id": "fd_0442",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:28.714293+00:00",
    "title": "Langlands for GL\u2082 over Q"
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
    "description": "Formalize the p-adic Langlands correspondence for GL\u2082(Q_p): establish a bijection between irreducible unitary Banach representations and 2-dimensional Galois representations. Prove the Colmez functor realization.",
    "domains": [
      "Bridges",
      "Algebra"
    ],
    "id": "fd_0447",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:29.128786+00:00",
    "title": "p-adic Langlands for GL\u2082(Q_p)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove deep structural theorems about the Berggren tree of Pythagorean triples. Formalize the groupoid action on SL(3,Z), the prime distribution along hypotenuse lengths, and computational applications of the tree structure.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0480",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:45.030710+00:00",
    "title": "Pythagorean Triple Group Structure"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that there are no non-constant polynomials f,g,h over C such that f^n + g^n = h^n for n >= 3. Show this follows from the Mason-Stothers theorem. Formalize the polynomial ABC conjecture and derive Fermat as a corollary.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0514",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.562165+00:00",
    "title": "Fermat's Last Theorem for Polynomials"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Characterize all fields over which every element is a sum of two squares (Pythagorean fields). Prove that a field is Pythagorean iff it is formally real with a unique ordering. Show that Q(i) is not Pythagorean but R is.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0515",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.634604+00:00",
    "title": "Pythagorean Fields: When Does a^2 + b^2 = c^2 Have Solutions?"
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
    "status": "failed",
    "timestamp": "2026-06-03T22:10:07.620386+00:00",
    "title": "Tropical Moduli Spaces: Curves and Their Tropical Counterparts"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove existence and smoothness of solutions to the 3D Navier-Stokes equations, or find a counterexample. Formalize known partial regularity results (Caffarelli-Kohn-Nirenberg) and explore connections to turbulence.",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_0395",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:24.924994+00:00",
    "title": "Navier-Stokes Existence and Smoothness"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Inspired by the AdS/CFT correspondence, formalize a mathematical holographic principle: a theorem about n-dimensional structures (the bulk) has a dual (shorter) proof in (n-1)-dimensional boundary terms. Conjecture: Every proof by induction on a well-founded order of rank n has an equivalent proof by coinduction on the n-1 boundary. Test: find a concrete theorem (e.g., finite Ramsey) and show its inductive proof in R^n maps to a coinductive proof on S^{n-1}. Impact: a new holographic proof theory connecting algebraic topology to proof complexity.",
    "domains": [
      "Physics",
      "Algebra"
    ],
    "id": "fd_0412",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.259292+00:00",
    "title": "Holographic Mathematics: Bulk-Boundary Proof Duality"
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
    "description": "Formalize Wilson's epsilon expansion for the phi^4 critical exponents. Prove that eta = epsilon^2/54 + O(epsilon^3) in 4-epsilon dimensions. Verify the Feynman diagram computation and show that the renormalization group beta function has a non-trivial fixed point for d < 4.",
    "domains": [
      "Physics",
      "Algebra"
    ],
    "id": "fd_0468",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:30.812055+00:00",
    "title": "Renormalization Group Flow: Wilson's Epsilon Expansion"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Explore number representation systems that are not base-N: factorial number system, Zeckendorf representation, balanced ternary with negative digits, and genuinely novel systems. Conjecture: There exists a number representation system with O(log* n) digit count (iterated logarithm) using recursive bases. Test: construct the tower-base representation and prove every natural number has a unique representation. Impact: if true, this gives sub-logarithmic number representations with implications for compression and coding theory.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0485",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:45.398671+00:00",
    "title": "Alien Number Systems: Beyond Base-N"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Reverse-engineer proof strategies from deep results (FLT, Poincar\u00e9, classification of finite simple groups) and extract reusable structural patterns as higher-order proof schemata.",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_0409",
    "priority_score": 0.09999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.020862+00:00",
    "title": "Proof Strategy Mining from Deep Mathematics"
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
    "description": "The Fibonacci sequence is defined by F(n+1) = F(n) + F(n-1) and converges to the golden ratio. Define the ANTI-Fibonacci sequence: A(n+1) is the smallest positive integer that is NOT equal to A(n) + A(n-1). The sequence begins 1, 1, 2, 4, 7, 11, 16, ... (each term avoids being the sum of the two previous terms). Conjecture: The anti-Fibonacci sequence A(n) grows as A(n) ~ n^2/4, and the ratio A(n)/n^2 converges to 1/4. More precisely, A(n) = floor(n^2/4) + O(1). The sequence avoids the golden ratio entirely \u2014 the ratio A(n+1)/A(n) does NOT converge, instead oscillating between 1 and 2. The complement of the anti-Fibonacci sequence (numbers that ARE sums of two previous anti-Fibonacci numbers) has density 0. Test: compute A(n) for n up to 10^6 and verify A(n)/n^2 approaches 1/4. Prove A(n) = floor(n^2/4) + O(1) by induction. Impact: a beautiful counterpoint to the Fibonacci sequence \u2014 instead of converging to a constant, it grows quadratically while systematically avoiding addition.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0007",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.492042+00:00",
    "title": "The Anti-Fibonacci Sequence: Numbers That Avoid the Golden Ratio at All Costs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conway's surreal numbers No form the largest totally ordered field, containing all real numbers, all ordinals, and all infinitesimals. But No is a proper class, not a set. What topology does it have? Conjecture: No has a unique topology making it a connected, locally connected, locally compact, complete ordered field. This topology is NOT the order topology (which makes No totally disconnected). Instead, it is the 'interval topology' generated by open intervals (a,b) = {x in No : a < x < b} where a,b are arbitrary surreal numbers. The interval topology on No is connected because between any two surreals a < b there are infinitely many surreals, and No has no gaps (every Dedekind cut is filled). Moreover, No is contractible in this topology \u2014 every surreal number can be continuously deformed to 0 via the homotopy H(x,t) = x * {t | 0} where {t | 0} is the surreal number between t and 0. Test: prove that No with the interval topology is connected. Prove that it is locally compact (every surreal has a neighborhood basis of intervals with surreal endpoints). Prove that No is contractible. Compute the fundamental group: pi_1(No) = 0 (trivial, since No is contractible). Impact: the largest ordered field has a natural topology that makes it contractible \u2014 every surreal number is connected to every other by a continuous path.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0016",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.499504+00:00",
    "title": "Surreal Topology: What Topology Does the Field of Surreal Numbers Have?"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Ramanujan's constant e^{pi*sqrt(163)} is remarkably close to an integer: it equals 262537412640768743.99999999999925... \u2014 just 7.5 * 10^{-13} away from 262537412640768744. This is not a coincidence: 163 is the largest Heegner number, and the near-integer property follows from the j-function and the fact that Q(sqrt(-163)) has class number 1. But 163 appears EVERYWHERE: it is prime, it is the smallest p such that Q(sqrt(-p)) has class number 1 and p > 2, it is a Chen prime, a lucky prime, a strongly prime, and the 38th prime. Conjecture: 163 is the unique integer n such that e^{pi*sqrt(n)} is within 10^{-6} of an integer. More generally, the Heegner numbers (1, 2, 3, 7, 11, 19, 43, 67, 163) are exactly the n for which Q(sqrt(-n)) has class number 1, and e^{pi*sqrt(n)} is near-integer for each. The 'magic' of 163 is that it is the LAST Heegner number \u2014 the final class number 1 imaginary quadratic field. Test: prove that e^{pi*sqrt(n)} is within 10^{-6} of an integer only for Heegner numbers. Compute e^{pi*sqrt(67)} and e^{pi*sqrt(43)} and verify near-integer behavior. Prove that 163 is the largest Heegner number (Stark-Heegner theorem). Impact: 163 is not magic \u2014 it is the climax of a deep theorem in algebraic number theory. The near-integer property of e^{pi*sqrt(163)} is the shadow of the class number 1 condition.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0020",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.505215+00:00",
    "title": "The Unreasonable Effectiveness of the Number 163"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Langlands program connects Galois groups (shapes) to automorphic forms (colors). Think of it this way: a Galois group is the group of symmetries of a shape (like the rotational symmetries of a polygon). An automorphic form is a coloring that respects the shape's symmetries (like a coloring of the polygon's vertices that is invariant under rotation). The Langlands correspondence says: for every 'shape' (Galois representation), there is a matching 'color' (automorphic form) and vice versa. Conjecture: This correspondence is a bijection between irreducible representations of Gal(Q_bar/Q) and cuspidal automorphic representations of GL_n over Q. For n=1, this is class field theory (every abelian extension of Q corresponds to a Dirichlet character). For n=2, this is the modularity theorem (every elliptic curve over Q corresponds to a weight-2 cusp form). The toddler version: each shape has exactly one matching color, and each color has exactly one matching shape. Test: verify the correspondence for all degree-2 extensions of Q up to discriminant 1000. Verify that each quadratic field Q(sqrt(d)) corresponds to a Dirichlet character chi_d via the correspondence chi_d(p) = (d/p) (Legendre symbol). Impact: Langlands is just shape-color matching. Shapes and colors are two ways of seeing the same mathematical object.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "id": "fd_0041",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.557538+00:00",
    "title": "Langlands for Toddlers: Galois Groups as Shapes, Automorphic Forms as Colors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In 2023, Smith et al. discovered 'the hat' \u2014 a single tile shape that tiles the plane but only aperiodically (no periodic tiling exists). This solved the aperiodic monotile problem. But deeper questions remain: How many distinct aperiodic monotiles exist? Conjecture: The set of aperiodic monotiles forms a 1-parameter family (the 'hat spectrum') parameterized by a continuous parameter t in [0,1] where t=0 gives the hat, t=1 gives the turtle (a known variant), and intermediate values give intermediate shapes. The key property: each shape in the hat spectrum tiles the plane aperiodically, and no two shapes in the spectrum admit a common periodic tiling. The boundary of the hat spectrum is the curve in R^2 that separates the region of aperiodic monotiles from the region of periodic tiles. This boundary is a piecewise-smooth curve determined by the constraint that the tile must enforce a hierarchical substitution rule. Test: parameterize the hat spectrum by interpolating between the hat and turtle, compute the substitution rule for each t, and verify that the substitution rule enforces aperiodicity for all t in [0,1]. Impact: aperiodic monotiles are not isolated curiosities \u2014 they form a continuous family, and the hat is just one point on the spectrum.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0048",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.581649+00:00",
    "title": "The Aperiodic Monotile: One Shape to Tile Them All"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Anyon braiding in topological quantum computing gives unitary matrices from the braid group B_n. The Jones representation rho_k: B_n -> U((k-1)(n-1)+1) at root of unity e^{2*pi*i/k} is conjectured to be universal for quantum computation when k >= 3 and n >= 4. Conjecture: the set of all braids in B_4 under the Jones representation at k=5 generates a dense subgroup of SU(3). More precisely, the image rho_5(B_4) is an infinite subgroup of SU(3) that is not contained in any proper closed subgroup. This means that topological quantum computing with Fibonacci anyons (k=5) is universal: any unitary in SU(3) can be approximated to arbitrary precision by braiding 4 anyons. The key: the Jones representation at k=5 gives 3x3 matrices, and the braid generators sigma_1, sigma_2, sigma_3 generate a dense subgroup of SU(3). Test: compute the Jones representation at k=5 for B_4, verify that sigma_1 * sigma_2 * sigma_3 has infinite order, and check that the group generated by sigma_1, sigma_2, sigma_3 is dense in SU(3) by the Solovay-Kitaev theorem. Impact: braiding anyons is universal for quantum computation. The braid group B_4 at k=5 is a quantum gate set.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "id": "fd_0063",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.643460+00:00",
    "title": "Topological Quantum Compiling: Braid Groups as Universal Gates"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The Collatz conjecture (3n+1 problem) states that every positive integer eventually reaches 1 under the map T(n) = n/2 (n even) or 3n+1 (n odd). Despite being verified up to 2^68, a proof remains elusive. Conjecture: the Collatz conjecture is independent of Peano Arithmetic (PA). That is, PA can neither prove nor refute the statement 'for all n, the Collatz sequence starting at n eventually reaches 1'. This would mean the conjecture is TRUE (in the standard model) but UNPROVABLE in PA. The argument: the Collatz map is a Diophantine function that grows faster than any provably total computable function in PA. Specifically, the halting problem for Collatz (does the orbit of n reach 1?) is at least as hard as the consistency of PA, which by Godel's second incompleteness theorem is unprovable in PA. Conjecture: the Collatz conjecture is equivalent to Con(PA) over a weak base theory, meaning that if PA is consistent, then PA does not prove Collatz. Test: formalize the equivalence between Collatz and Con(PA) in Lean 4. Show that a counterexample to Collatz (an n whose orbit diverges or cycles) would imply not-Con(PA). Impact: Collatz might be the simplest true-but-unprovable statement in arithmetic \u2014 a concrete example of Godel's incompleteness.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0074",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.700907+00:00",
    "title": "The Collatz Conjecture Is Undecidable: What If 3n+1 Can't Be Proved?"
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
    "status": "failed",
    "timestamp": "2026-06-01T12:30:30.834465+00:00",
    "title": "The Poincare Conjecture for Data: Manifold Detection via Persistent Homology"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Construct a surface whose Hausdorff dimension is exactly aleph-1 (assuming CH). Prove that such a surface cannot be embedded in any finite-dimensional Euclidean space but can be embedded in the Hilbert cube. Formalize transfinite-dimensional manifolds and prove they have no finite triangulation.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "id": "fd_0128",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:31.030197+00:00",
    "title": "Aleph-1 Surface: Geometry Between Dimensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize a game where one player (Mortal) has finite computation and the other (Eternity) has transfinite computation. Prove that Mortal can always force at least omega rounds before losing, and that with bounded nondeterminism, Mortal can force omega-squared rounds. Connect to Infinite Time Turing Machines.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0135",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-01T12:30:31.073799+00:00",
    "title": "Infinite Games Against Death: Immortality Strategies"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that the category of chain complexes is equivalent to the derived category modulo homotopy. Show that Ext and Tor are universal delta-functors. Bridge: singular homology of a space X equals Ext^*(Z, C_*(X)) in the derived category. Prove the universal coefficient theorem as a consequence.",
    "domains": [
      "Bridges",
      "Algebra"
    ],
    "id": "fd_0532",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-03T22:10:06.303707+00:00",
    "title": "Bridge: Homological Algebra Connecting Algebra and Topology"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize a notion of 'self-referential types' in dependent type theory where a type can quantify over itself. Define: a conscious type T satisfies T \u2248 \u03a0(x:T), P(x) for some predicate P. Prove: any such type must be undecidable (G\u00f6del-style). Show: the fixed points of the type-forming operations correspond to a hierarchy analogous to the arithmetical hierarchy. Conjecture: the cardinality of self-referential types is exactly \u2135_1^CK (the Church-Kleene ordinal).",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "id": "fd_0570",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-03T23:40:36.311824+00:00",
    "title": "Speculative: Consciousness as Fixed Points of Recursive Type Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: the laws of physics are the fixed point of a computation that simulates itself. Formalize: define a universal physical simulator U that maps (initial_conditions, laws) \u2192 (next_state). The fixed point equation is U(L, L) = L, where L is the 'law of physics'. Prove: the solution exists (by the Kleene fixed point theorem). Show: the solution is unique up to computational equivalence. Predict: the fine structure constant \u03b1 satisfies \u03b1 = 1/(137.036...) because it's the simplest fixed point.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "id": "fd_0572",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "failed",
    "timestamp": "2026-06-03T23:40:36.486848+00:00",
    "title": "Speculative: The Universe Computes Its Own Existence (Physics = Computation)"
  }
];
