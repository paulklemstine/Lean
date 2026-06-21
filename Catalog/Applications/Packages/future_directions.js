

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "Prove that Exponential-Multiplicative-Logarithmic closures are universal approximators with provable complexity bounds. Show that minimum EML depth for \u03b5-approximation is O(K(f)/\u03b5), connecting to Kolmogorov complexity.",
    "domains": [
      "EML",
      "MachineLearning"
    ],
    "id": "fd_0479",
    "priority_score": 1.0,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:44.957997+00:00",
    "title": "EML Universal Approximation"
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
    "description": "Formalize the classical zero-free region of the Riemann zeta function: \u03b6(s) \u2260 0 for Re(s) > 1 - c/log(|Im(s)|+2). Prove the Riemann-von Mangoldt formula N(T) ~ T/(2\u03c0) log(T/(2\u03c0e)). Formalize the connection between zero-free regions and prime counting error bounds.",
    "domains": [
      "NumberTheory",
      "Analysis"
    ],
    "id": "seed_329",
    "priority_score": 0.94,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432599+00:00",
    "title": "Riemann Zeta: Zero-Free Regions and Density Estimates"
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
    "description": "Formalize the Maynard-Tao sieve in Lean 4 and prove that lim inf(p_{n+1} - p_n) \u2264 246. Construct the GPY sieve weight optimization as a variational problem. Prove the key lemma on the level of distribution of primes in arithmetic progressions.",
    "domains": [
      "NumberTheory"
    ],
    "id": "seed_328",
    "priority_score": 0.93,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432595+00:00",
    "title": "Twin Prime Gaps: Zhang-Maynard Formalization"
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
    "description": "Formalize global class field theory as the GL(1) case of Langlands. Prove the Artin reciprocity law. Construct the ad\u00e8le ring and id\u00e8le class group. Prove that 1-dimensional Galois representations correspond to Hecke characters.",
    "domains": [
      "Algebra",
      "NumberTheory",
      "Bridges"
    ],
    "id": "seed_375",
    "priority_score": 0.91,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432799+00:00",
    "title": "Langlands Correspondence: GL(1) Case"
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
    "description": "Formalize Noether's theorem in Lean 4: every continuous symmetry of the action yields a conserved quantity. Prove energy conservation from time-translation, momentum from space-translation, angular momentum from rotational symmetry. Apply to Kepler problem.",
    "domains": [
      "Physics",
      "Algebra",
      "Analysis"
    ],
    "id": "seed_363",
    "priority_score": 0.9,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432772+00:00",
    "title": "Noether's Theorem: Symmetries and Conservation Laws"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Building on cycle d6329d46 (Q=0.792), which proved 22 theorems in Shared. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: Building on cycle e42393e4 (Q=0.792), which proved 42 theorems in Bridges. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: The key insight is that a binary linear code carries a genuinely new tropical v",
    "domains": [
      "Shared"
    ],
    "id": "push_d6329d46_0261f1a9",
    "priority_score": 0.8918400000000001,
    "research_mode": "team",
    "source_exp_id": "d6329d46",
    "status": "available",
    "timestamp": "2026-06-16T10:39:16.248773+00:00",
    "title": "Deepening: Functor from finite linear codes to tropical valuation objects via weight-thresh"
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
    "description": "Formalize the Miller-Rabin primality test in Lean 4 and prove its error bounds. Formalize the AKS deterministic primality test and prove correctness: PRIMES \u2208 P. Construct efficient modular arithmetic tactics for Lean.",
    "domains": [
      "NumberTheory",
      "Computation"
    ],
    "id": "seed_334",
    "priority_score": 0.88,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432609+00:00",
    "title": "Primality Testing: Miller-Rabin and AKS Formalization"
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
    "description": "Formalize the hydrogen atom Hamiltonian in Lean 4. Prove the spectrum is {-1/n\u00b2 : n \u2208 \u2115+} \u222a [0,\u221e). Construct the spherical harmonics as eigenfunctions of the angular momentum operator. Prove the selection rules for transitions.",
    "domains": [
      "Physics",
      "Analysis"
    ],
    "id": "seed_362",
    "priority_score": 0.88,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432770+00:00",
    "title": "Quantum Mechanics: Spectral Theory of Hydrogen"
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
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432792+00:00",
    "title": "Elliptic Curve Arithmetic: Group Law Formalization"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize classic algorithms with full correctness proofs in Lean 4: binary search (with loop invariants), Dijkstra's shortest path (with graph formalization), and FFT (with number-theoretic transform). Prove complexity bounds.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "id": "seed_380",
    "priority_score": 0.88,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432811+00:00",
    "title": "Formal Verification of Algorithms"
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
    "consumed_by_exp_id": "971b371e",
    "description": "Formalize the Euclid-Euler theorem: n is an even perfect number iff n = 2^(p-1)(2^p - 1) where 2^p - 1 is prime. Prove that odd perfect numbers, if they exist, must have at least 101 prime factors (Nielsen's bound). Formalize the abundancy index \u03c3(n)/n framework.",
    "domains": [
      "NumberTheory"
    ],
    "id": "seed_331",
    "priority_score": 0.87,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-18T03:56:25.432603+00:00",
    "title": "Perfect Numbers: Structure of Even Perfects"
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
    "description": "Formalize the 2D Ising model. Prove Onsager's solution: the critical temperature is T_c = 2/ln(1+\u221a2). Construct the transfer matrix method. Prove spontaneous magnetization below T_c via the Peierls argument.",
    "domains": [
      "Physics",
      "Probability",
      "Analysis"
    ],
    "id": "seed_364",
    "priority_score": 0.87,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432774+00:00",
    "title": "Statistical Mechanics: Ising Model Phase Transition"
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
    "description": "Formalize the Euler characteristic for CW complexes. Prove the Gauss-Bonnet theorem for compact surfaces: \u222b K dA = 2\u03c0\u03c7(M). Prove the Poincar\u00e9-Hopf index theorem. Apply to classify surfaces by genus.",
    "domains": [
      "Geometry",
      "Topology"
    ],
    "id": "seed_349",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432672+00:00",
    "title": "Euler Characteristic and Gauss-Bonnet"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize Tur\u00e1n's theorem: ex(n, K_r) = (1-1/(r-1))n\u00b2/2. Prove the Kruskal-Katona theorem. Formalize Szemer\u00e9di's regularity lemma and prove the triangle removal lemma. Apply to prove Roth's theorem on 3-APs.",
    "domains": [
      "Combinatorics"
    ],
    "id": "seed_356",
    "priority_score": 0.86,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432745+00:00",
    "title": "Extremal Graph Theory: Tur\u00e1n and Szemer\u00e9di"
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
    "consumed_by_exp_id": "",
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
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432796+00:00",
    "title": "Tropical Curves and Chip-Firing Games"
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
    "description": "Formalize three fundamental fixed point theorems in Lean 4. Prove Brouwer via Sperner's lemma, Banach via the contraction mapping iteration, and Schauder via Brouwer + compactness. Apply to existence proofs for ODEs and integral equations.",
    "domains": [
      "Analysis",
      "Topology"
    ],
    "id": "seed_345",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432654+00:00",
    "title": "Fixed Point Theorems: Brouwer, Banach, Schauder"
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
    "description": "Formalize Ramsey's theorem and prove tight bounds: R(3,3)=6, R(3,4)=9, R(4,4)=18. Prove the Erd\u0151s-Szekeres bound R(s,t) \u2264 C(s+t-2, s-1). Construct the best known lower bound via the probabilistic method. Formalize the Hales-Jewett theorem.",
    "domains": [
      "Combinatorics"
    ],
    "id": "seed_352",
    "priority_score": 0.85,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432688+00:00",
    "title": "Ramsey Theory: Bounds and Constructions"
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
    "description": "Cycle d6329d46 (Q=0.792) proved 22 theorems in Shared but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Building on cycle e42393e4 (Q=0.792), which proved 42 theorems in Bridges. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting.",
    "domains": [
      "Shared"
    ],
    "id": "sorry_fill_d6329d46_da24e39e",
    "priority_score": 0.8418400000000001,
    "research_mode": "team",
    "source_exp_id": "d6329d46",
    "status": "available",
    "timestamp": "2026-06-16T10:39:16.784213+00:00",
    "title": "Close Proofs: Functor from finite linear codes to tropical valuation objects via wei"
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
    "description": "Formalize the theory of continued fractions in Lean 4: convergents, best rational approximations, Hurwitz's theorem (|\u03b1 - p/q| < 1/(\u221a5 q\u00b2) for infinitely many p/q). Prove Liouville's theorem on transcendental numbers via Diophantine approximation bounds.",
    "domains": [
      "NumberTheory",
      "Analysis"
    ],
    "id": "seed_332",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432605+00:00",
    "title": "Continued Fractions and Diophantine Approximation"
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
    "consumed_by_exp_id": "",
    "description": "Prove that Besicovitch sets in R^2 have Hausdorff dimension 2 (Davies's theorem). Formalize the Wolff bound in R^3: dimension \u2265 5/2. Connect to restriction estimates for the Fourier transform and to additive combinatorics via the Katz-Tao framework.",
    "domains": [
      "Geometry",
      "Analysis"
    ],
    "id": "seed_347",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
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
    "status": "available",
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
    "status": "available",
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
    "description": "Formalize the Brunn-Minkowski inequality: vol(A+B)^{1/n} \u2265 vol(A)^{1/n} + vol(B)^{1/n}. Prove the isoperimetric inequality as a consequence. Formalize support functions and the Minkowski sum. Prove the Alexandrov-Fenchel inequality.",
    "domains": [
      "Geometry",
      "Analysis"
    ],
    "id": "seed_351",
    "priority_score": 0.83,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432684+00:00",
    "title": "Convex Geometry: Brunn-Minkowski Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize chromatic polynomials and prove deletion-contraction. Prove the four-color theorem is equivalent to \u03c7(G) \u2264 4 for all planar G. Formalize Brooks' theorem: \u03c7(G) \u2264 \u0394(G) unless G is complete or an odd cycle. Prove the chromatic polynomial is T-positive for claw-free graphs.",
    "domains": [
      "Combinatorics",
      "Algebra"
    ],
    "id": "seed_354",
    "priority_score": 0.83,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432739+00:00",
    "title": "Graph Coloring: Chromatic Polynomial Theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the self-attention mechanism as a kernel method. Prove that softmax attention is a universal approximator of sequence-to-sequence functions. Analyze the rank of attention matrices and prove the attention sink phenomenon for large context.",
    "domains": [
      "MachineLearning",
      "Algebra",
      "Analysis"
    ],
    "id": "seed_368",
    "priority_score": 0.83,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432784+00:00",
    "title": "Attention Mechanisms: Mathematical Properties"
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
    "description": "Formalize the Erd\u0151s-R\u00e9nyi random graph model G(n,p). Prove the sharp threshold for connectivity at p = ln(n)/n. Prove the phase transition for giant components at p = 1/n. Formalize the second moment method for subgraph counting.",
    "domains": [
      "Combinatorics",
      "Probability"
    ],
    "id": "seed_355",
    "priority_score": 0.82,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432742+00:00",
    "title": "Random Graphs: Erd\u0151s-R\u00e9nyi Threshold Phenomena"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize key results of Bishop's constructive analysis in Lean 4. Prove the constructive intermediate value theorem (with explicit modulus). Construct computable real numbers and prove completeness. Compare with classical results.",
    "domains": [
      "Logic",
      "Analysis"
    ],
    "id": "seed_359",
    "priority_score": 0.82,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432759+00:00",
    "title": "Constructive Mathematics: Bishop's Analysis"
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
    "description": "For every integer k \u2265 2 and every \u03b5 > 0, there exist infinitely many n-vertex k-uniform uncrowded hypergraphs (girth \u2265 5) H with maximum degree \u0394 (where \u0394 \u2192 \u221e) such that \u03b1(H) \u2264 (1+\u03b5) \u00b7 n \u00b7 ((1/(k-1)) \u00b7 log(\u0394)/\u0394))^(1/(k-1)). This conjecture asserts that the shattering-threshold lower bound proven in this paper\u2014which achieves the constant (1/(k-1))^(1/(k-1))\u2014is asymptotically tight, meaning no larger leading constant is achievable for the class of uncrowded hypergraphs.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2066",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18048v1",
    "status": "available",
    "timestamp": "2026-06-17T22:31:12.228823+00:00",
    "title": "Asymptotic Tightness of the Shattering Threshold for Uncrowded Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any tree graph, there exists a set of vertices that is simultaneously an isolating set and a packing (2-packing). An isolating set is a set S such that the subgraph induced by vertices outside the closed neighborhood of S has no edges. A packing is a set S such that the closed neighborhoods of the vertices in S are pairwise disjoint.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2067",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18172v1",
    "status": "available",
    "timestamp": "2026-06-17T22:32:18.782940+00:00",
    "title": "Existence of Packing Isolating Sets in Trees"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any \u03b5 > 0, there exists a \u0394\u2080 such that for all \u0394 \u2265 \u0394\u2080, any 3-uniform uncrowded hypergraph (girth \u2265 5) on n vertices with maximum degree at most \u0394 contains an independent set of size at least (1 - \u03b5) * n * sqrt(log(\u0394) / (2\u0394)). This is the k=3 instantiation of the paper's main theorem that uncrowded hypergraphs attain the shattering threshold constant (1/(k-1))^(1/(k-1)).",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2069",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18048v1",
    "status": "available",
    "timestamp": "2026-06-17T23:47:21.704922+00:00",
    "title": "Shattering Threshold for 3-Uniform Uncrowded Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer n > 2, the zero-sum constant s_1(n) equals 2n + 1, where s_1(n) is defined as the least positive integer k such that any sequence of k integers not divisible by n contains an n-subset whose sum is divisible by n but not by n^2.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2070",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18234v1",
    "status": "available",
    "timestamp": "2026-06-18T00:38:46.409376+00:00",
    "title": "Exact Formula for Zero-Sum Invariant s_1(n)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any partial Latin square P of order n with k entries occupying at most n/4 rows and n/4 columns, the probability that a uniformly random Latin square of order n contains P is bounded between (c\u2081/n)^k and (c\u2082/n)^k for some absolute constants c\u2081, c\u2082 > 0. This is a specific instance of the paper's main theorem (Theorem 1.1) with \u03b1=1/4 and \u03b2=1/4, which satisfies the condition 2\u03b1+\u03b2 < 1.",
    "domains": [
      "Computation"
    ],
    "id": "fd_2071",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18174v1",
    "status": "available",
    "timestamp": "2026-06-17T23:49:01.691458+00:00",
    "title": "Probability Bounds for Partial Latin Squares with Bounded Dimensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper establishes an average-degree lower bound on the independence number of uncrowded uniform hypergraphs (those without Berge 2, 3, or 4-cycles). Since Verstraete and Wilson previously extended the maximum-degree bound from uncrowded to locally sparse hypergraphs (those without Berge 2 or 3-cycles), this conjecture proposes that the average-degree bound similarly extends to the broader class of locally sparse uniform hypergraphs.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2072",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18171v1",
    "status": "available",
    "timestamp": "2026-06-18T00:40:07.506039+00:00",
    "title": "Average-Degree Bound for Locally Sparse Uniform Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The feasibility version of the Moving-Target Traveling Salesman Problem with Moving Obstacles (MT-TSP-MO) is PSPACE-hard. Specifically, given a set of targets each moving along a straight line with constant rational velocity and having an associated time window, and a set of obstacles each moving along a straight line with constant rational velocity, determining whether there exists a continuous trajectory from a static depot that visits all targets within their time windows while avoiding all obstacles is PSPACE-hard. This holds even when the number of obstacles is polynomial in the number of targets. The conjecture bridges the known PSPACE-hardness of motion planning with moving obstacles (Reif 1979) and the NP-hardness of TSP variants with time windows, establishing that MT-TSP-MO inherits the hardest aspects of both subproblems.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2075",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18730v1",
    "status": "available",
    "timestamp": "2026-06-18T03:07:25.571014+00:00",
    "title": "PSPACE-Hardness of MT-TSP-MO Feasibility with Linearly Moving Obstacles"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every Zariski-dense geometrically finite thin subgroup \u0393 of an arithmetic lattice in SO(n,1) with positive critical exponent \u03b4_\u0393 > 0 admits a uniform spectral gap over its congruence covers: there exists \u03b7 = \u03b7(n, \u03b4_\u0393) > 0 such that for all square-free q \u2265 1, the Laplace\u2013Beltrami operator on (\u0393 \u2229 \u0393\u2080(q))\\\u210d\u207f has no eigenvalues in ((n\u22121)\u00b2/4 \u2212 \u03b7, (n\u22121)\u00b2/4). This extends Bourgain\u2013Gamburd\u2013Sarnak (\u03b4_\u0393 > 1/2, n = 2) and the present paper's result (\u03b4_\u0393 \u2208 (1/2, n\u22122] with cusps, n \u2265 3) to the full range \u03b4_\u0393 > 0, and would imply that the affine sieve for \u0393-orbits saturates at a finite level regardless of \u03b4_\u0393.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2076",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18674v1",
    "status": "available",
    "timestamp": "2026-06-18T03:09:27.688863+00:00",
    "title": "Uniform Spectral Gap for Thin Subgroups at Arbitrary Critical Exponent"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every natural number k, the directed binary structure consisting of the strict order relation of any finite poset of width at most k has twin-width at most 2*k+1. Equivalently, every finite poset whose largest antichain has size at most k admits a contraction sequence in which every intermediate part has at most 2*k+1 red out-/in-neighborhood types induced by the strict order relation.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2077",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18934v1",
    "status": "available",
    "timestamp": "2026-06-18T08:02:38.169523+00:00",
    "title": "Linear twin-width bound for finite posets of bounded width"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the preferential attachment random multigraph with edge steps and parameter p \u2208 (0,1), started from any fixed finite connected multigraph with positive total degree, the clique number has the same logarithmic growth exponent as in the one-loop initial condition: for every \u03b5 > 0, the probability that |log(\u03c9(G_t))/log(t) - (1-p)/(2-p)| > \u03b5 tends to 0 as t tends to infinity.",
    "domains": [
      "Computation"
    ],
    "id": "fd_2078",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18722v1",
    "status": "available",
    "timestamp": "2026-06-18T11:02:58.622655+00:00",
    "title": "Initial-condition universality of the clique-number exponent in preferential attachment with edge steps"
  },
  {
    "consumed_by_exp_id": "42f0bfda",
    "description": "Let P be any fixed finite partial Latin square pattern with k entries, encoded as a finite set of triples (row, column, symbol) of natural numbers satisfying the partial Latin condition: no two distinct entries agree in both row and column, row and symbol, or column and symbol. For each n large enough to contain all coordinates of P, view P as a partial Latin square of order n. Conjecture: if L is chosen uniformly from all Latin squares of order n, then Pr[L contains P] * n^k tends to 1 as n tends to infinity.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_2079",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18174v1",
    "status": "in_progress",
    "timestamp": "2026-06-18T14:02:50.731479+00:00",
    "title": "Fixed partial Latin patterns occur with asymptotic probability n^{-k}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every odd prime p, every sequence of 2p+1 integers none divisible by p contains a subsequence of exactly p terms whose sum is divisible by p but not divisible by p^2. Equivalently, the prime case of the paper's constant satisfies s_1(p) <= 2p+1; combined with the known lower bound this gives s_1(p)=t_1(p)=2p+1 for odd primes.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2080",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18234v1",
    "status": "available",
    "timestamp": "2026-06-18T16:04:01.065424+00:00",
    "title": "Sharp valuation-EGZ bound for odd primes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer r \u2265 2 and every \u03b7 > 0, there is a threshold d* such that every finite (r+1)-uniform hypergraph H with no Berge 2-cycle and no Berge 3-cycle, average degree d \u2265 d*, and vertex set V satisfies \u03b1(H) \u2265 (1 - \u03b7) * r^(-1/r) * (log d / d)^(1/r) * |V|. This conjectures that the paper's average-degree result for uncrowded hypergraphs remains true under the weaker local-sparsity condition, removing the assumption of no Berge 4-cycles.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2081",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18171v1",
    "status": "available",
    "timestamp": "2026-06-18T21:07:13.927171+00:00",
    "title": "Average-degree Shearer bound for locally sparse uniform hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every nonzero ideal I of the Gaussian integers \u2124[i], the rank-2 Euclidean lattice obtained by applying the canonical embedding a+bi \u21a6 (a,b) to I is well-rounded: its shortest nonzero vectors span \u211d\u00b2. Equivalently, if I = (\u03b1), then the shortest vectors are precisely the unit multiples \u00b1\u03b1 and \u00b1i\u03b1 under the embedding, giving two linearly independent equal-length minimal vectors.",
    "domains": [
      "Algebra",
      "Cryptography"
    ],
    "id": "fd_2082",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18920v1",
    "status": "available",
    "timestamp": "2026-06-18T08:03:43.657853+00:00",
    "title": "Nonzero Gaussian integer ideal lattices are well-rounded"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Let n >= 3 and let \u0393 be a geometrically finite, discrete, Zariski-dense thin subgroup of an arithmetic lattice \u03930 < SO(n,1)^\u2218 with critical exponent \u03b4_\u0393 > 1/2. The uniform congruence spectral gap theorem for the congruence covers of \u0393\\H^n remains true without assuming that \u0393 is torsion-free. Equivalently, after excluding finitely many primes, there is \u03b5 > 0 such that every square-free congruence cover has no new complementary-series spectrum with parameter in (\u03b4_\u0393 - \u03b5, \u03b4_\u0393). This is falsifiable by producing a geometrically finite arithmetic thin orbifold subgroup with \u03b4_\u0393 > 1/2 whose congruence covers have new spectrum accumulating at \u03b4_\u0393.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2083",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18674v1",
    "status": "available",
    "timestamp": "2026-06-18T11:03:59.022678+00:00",
    "title": "Orbifold version of the uniform congruence spectral gap for geometrically finite thin subgroups of SO(n,1)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let K = \ud835\udd3d_{p^n} with p odd, regarded as an \ud835\udd3d_p-vector space, and let W \u2264 K be an \ud835\udd3d_p-linear subspace of dimension e. Write its subspace polynomial as P_W(X) = \u220f_{w \u2208 W} (X - w) = \u2211_{i=0}^e c_i X^{p^i}. Define the reversed Frobenius-twisted linearized polynomial F_W(X) = \u2211_{i=0}^e c_i^{p^{-i}} X^{p^{e-i}}, where p^{-i} denotes the inverse Frobenius power on K. Conjecture: the image of the \ud835\udd3d_p-linear map x \u21a6 F_W(x) is exactly the trace-orthogonal complement W^\u22a5 = { z \u2208 K | Tr_{K/\ud835\udd3d_p}(z w) = 0 for all w \u2208 W }. This is a finite-field linear algebra statement underlying the paper\u2019s adjoint-factorization construction and avoids formalizing algebraic curves.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2084",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18577v1",
    "status": "available",
    "timestamp": "2026-06-18T14:04:25.050589+00:00",
    "title": "Image of the reversed subspace polynomial is the trace-orthogonal complement"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer k \u2265 2 and every real \u03b5 with 0 < \u03b5 < 1, there is a threshold d0 such that every finite k-uniform uncrowded hypergraph H on n vertices with average degree at most d \u2265 d0 has an independent set of size at least (1 - \u03b5) n ((log d) / ((k - 1)d))^(1/(k - 1)). This extends the paper's maximum-degree theorem to the average-degree setting and is falsified by any sequence of uncrowded k-uniform hypergraphs of average degree d tending to infinity whose independence number falls below this asymptotic constant.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2085",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18048v1",
    "status": "available",
    "timestamp": "2026-06-18T16:05:12.158903+00:00",
    "title": "Average-degree shattering threshold for uncrowded uniform hypergraphs"
  },
  {
    "consumed_by_exp_id": "3e812933",
    "description": "Conjecture: Every finite block graph has a vertex set S which is simultaneously a 2-packing and an isolating set. Equivalently, the closed neighborhoods of distinct vertices of S are pairwise disjoint, and every edge of the graph has at least one endpoint in the closed neighborhood of S.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2086",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18172v1",
    "status": "in_progress",
    "timestamp": "2026-06-18T21:08:20.524395+00:00",
    "title": "Packing isolating sets exist in finite block graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a positive integer n and a subgroup H of the automorphism group of the cyclic group C_n, the orbit Schur ring S(C_n,H) has an almost commutative Terwilliger algebra if and only if H is trivial, or n is a prime power and H is the full automorphism group, or n = p^a for an odd prime p and H has order p^(a-1). Equivalently, for non-prime-power n, only the trivial orbit Schur ring has this property.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2087",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19095v1",
    "status": "available",
    "timestamp": "2026-06-18T23:03:35.820791+00:00",
    "title": "Orbit Schur rings over finite cyclic groups with almost commutative Terwilliger algebra"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Model the local invariant signs of an incoherent Hermitian space by a finite sign vector \u03b5_v \u2208 {\u00b11} whose product over all relevant places is \u22121. The nearby coherent Hermitian space with respect to a distinguished archimedean place \u03b9 is obtained by flipping exactly the sign at \u03b9. The conjecture states that this single flip changes the global product to +1. This formalizes, in a Lean-friendly finite-product abstraction, the parity mechanism behind the paper\u2019s passage from an incoherent Hermitian space to the nearby coherent Hermitian space.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2088",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19158v1",
    "status": "available",
    "timestamp": "2026-06-18T23:03:41.466796+00:00",
    "title": "Parity of the nearby coherent Hermitian sign vector"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \ud835\udcd5 be the projective Fraisse category associated with the dyadic solenoid's inverse limit construction. We conjecture that \ud835\udcd5 satisfies the approximate Ramsey property, which by the main theorem of 'Universal minimal flows of homeomorphism groups of continua' implies the homeomorphism group of the dyadic solenoid is extremely amenable.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2089",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-19T05:13:35.217718+00:00",
    "title": "The dyadic solenoid's Fraisse category has the approximate Ramsey property"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every integer k \u2265 3 and every rational \u03b5 > 0 there exist two k\u2011uniform hypergraphs F\u2081, F\u2082 such that the positive codegree Tur\u00e1n density \u03b3\u207a(F\u2081, F\u2082) is positive but satisfies \u03b3\u207a(F\u2081, F\u2082) < \u03b5\u00b7min{\u03b3\u207a(F\u2081), \u03b3\u207a(F\u2082)}.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2090",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20494v1",
    "status": "available",
    "timestamp": "2026-06-19T06:17:42.153700+00:00",
    "title": "Arbitrarily small positive codegree Tur\u00e1n density for pairs of k-graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that any pair of cross-intersecting families of k-subsets of [n] with diversity at least binomial(n-u-1, n-k-1) and total size exceeding (1-1/(k+1))*binomial(n,k) must be isomorphic to one of the known extremal constructions: either a full star pair, a product of a Hilton\u2013Milner family with a star, or a maximal cross\u2011intersecting extension of such a pair.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2091",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20085v1",
    "status": "available",
    "timestamp": "2026-06-19T06:52:16.169001+00:00",
    "title": "Canonical structure of large cross-intersecting families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a d-dimensional convex lattice polytope P, define S_0(P,t) to be its Ehrhart polynomial and define the r-fold summatory Ehrhart polynomial recursively by S_{r+1}(P,t)=sum_{i=0}^{t-1} S_r(P,i). Define the relative-interior analogue by S_0(P^circ,t)=E(P^circ,t) and S_{r+1}(P^circ,t)=sum_{i=1}^{t-1} S_r(P^circ,i). The conjecture is that for every integer r >= 0 and every positive integer t, the polynomial extensions satisfy S_r(P^circ,t)=(-1)^(d+r) S_r(P,r-t). The paper proves the case r=1; r=0 is classical Ehrhart--Macdonald reciprocity.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2092",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19577v1",
    "status": "available",
    "timestamp": "2026-06-19T07:10:46.914439+00:00",
    "title": "Iterated summatory Ehrhart--Macdonald reciprocity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Let \ud835\udd3d be a field of characteristic p>0, \u03bb\u2208\ud835\udd3d, and (\ud835\udd24,[\u2212,\u2212],R,\u03bb) a restricted Rota-Baxter Lie algebra over \ud835\udd3d. Then there exists a restricted Rota-Baxter associative algebra (A,R_A,\u03bb) over \ud835\udd3d such that \ud835\udd24 is isomorphic to a Lie subalgebra of the commutator Lie algebra A^\u2212 and the restriction of R_A to \ud835\udd24 equals R.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2093",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19244v1",
    "status": "available",
    "timestamp": "2026-06-19T07:55:41.287590+00:00",
    "title": "Embedding of restricted Rota-Baxter Lie algebras into commutator Lie algebras of restricted Rota-Baxter associative algebras"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture proposes a precise asymptotic threshold for the maximum number of copies of a fixed bipartite graph $K_{s,t}$ in a Tur\u00e1n graph $K_{a,b}$, advancing the understanding of explicit Tur\u00e1n number constraints via geometric point-set arguments.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2094",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19217v1",
    "status": "available",
    "timestamp": "2026-06-19T08:21:49.299986+00:00",
    "title": "Explicit bounds on Tur\u00e1n numbers for structured graph families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any (possibly infinite) graph G, the median-width of G coincides with its clique number.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2095",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19473v1",
    "status": "available",
    "timestamp": "2026-06-19T08:51:33.691085+00:00",
    "title": "Median-width equals clique number for all graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: A finite partial cube G is a daisy cube if and only if it does not contain, as a pc-minor, any graph H_{r,s} obtained from the Cartesian product of r copies of the 3-vertex path P_3 with a hypercube Q_s by deleting two opposite corners, for any integers r \u2265 2 and s \u2265 1. Equivalently, G has all peripheral Theta-classes iff it admits no such pc-minor obstruction. This statement is falsifiable for finite instances by exhaustive search of pc-minors and can be expressed in Lean as a theorem with a sorry placeholder.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2096",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19032v1",
    "status": "available",
    "timestamp": "2026-06-19T09:41:30.569124+00:00",
    "title": "Characterizationof Daisy Cubes via Peripheral Theta-Classes and Forbidden pc-Minors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The coefficients of the constructed modular form truncate to zero modulo any prime \u2113.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2097",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19008v1",
    "status": "available",
    "timestamp": "2026-06-19T10:11:48.398941+00:00",
    "title": "Triviality of Modular Form Coefficients"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture asserts there are precisely 57 nonnegative integer solutions (a, b, x) satisfying the inequality.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2098",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18500v1",
    "status": "available",
    "timestamp": "2026-06-19T10:40:58.134181+00:00",
    "title": "Exact Number of Solutions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture asserts that the algorithm runs in O(n^3) time for all instance sizes.",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_2099",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18730v1",
    "status": "available",
    "timestamp": "2026-06-19T11:12:43.328427+00:00",
    "title": "Time Complexity Claim"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every 6-regular (4,1)-graph has at least 30 vertices, providing a lower bound that could be combined with structural results to potentially prove that no such graph exists, thereby resolving Dirac's k=4 problem.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2100",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18462v1",
    "status": "available",
    "timestamp": "2026-06-19T11:49:14.147518+00:00",
    "title": "Non-existence of 6-regular (4,1)-graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "An interval hypergraphic polytope \u0394_I is simple if and only if no point of [n] is contained in three or more hyperedges of I.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2101",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18376v1",
    "status": "available",
    "timestamp": "2026-06-19T14:14:35.088047+00:00",
    "title": "Simplicity criterion for interval hypergraphic polytopes via point multiplicity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The coefficients a_n in the q-expansion f(q) = \u03a3_{n\u22650} a_n q^n satisfy the recurrence (n+3) a_{n+3} = (3n+4) a_{n+2} - (3n+1) a_{n+1} + n a_n for all n \u2265 0, with initial values a_0 = 1, a_1 = 0, a_2 = 1.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2102",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18110v1",
    "status": "available",
    "timestamp": "2026-06-19T14:51:27.250427+00:00",
    "title": "Linear recurrence for coefficients of Ramanujan's third order mock theta function f(q)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture asserts that the ratio of determinant to cofactor simplifies to a combination of trace terms and Laplacian contributions, verified for arbitrary subsets S.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2103",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18061v1",
    "status": "available",
    "timestamp": "2026-06-19T15:27:52.946265+00:00",
    "title": "Equality of Resistance Ratios"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let B and S be subsets of the nonnegative integers such that B+S = N0 (additive complements). Define A = {2^b : b \u2208 B} and M = {\u2211_{d\u2208D} 2^d : D \u2286 S, D finite and nonempty}. Then the restricted partition function p(n,A,M) has polynomial growth (i.e., \u2203 C,k\u2208N, \u2200 n\u22651, p(n,A,M) \u2264 C\u00b7n^k) if and only if there exists a constant C>0 such that for all sufficiently large x, |B\u2229[0,x]|\u00b7|S\u2229[0,x]| \u2264 C\u00b7x.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2104",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18027v1",
    "status": "available",
    "timestamp": "2026-06-19T16:08:49.240594+00:00",
    "title": "Necessity of the counting condition for polynomial growth in restricted partition functions via powers of two"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every odd prime base B > 5, the length of the longest terminal cycle in the four-digit Kaprekar routine equals (B-1)/2 if and only if the multiplicative order of 2 modulo B is (B-1)/2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2105",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20439v1",
    "status": "available",
    "timestamp": "2026-06-19T05:14:33.661749+00:00",
    "title": "Terminal Cycle Length in Four-Digit Kaprekar Dynamics Equals (B-1)/2 for Prime Bases"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer d >= 1 and every finite planar graph H, there exists a natural number B(d,H) such that every finite simple graph G that is K_{1,d}-free and has no induced minor isomorphic to H satisfies alpha-tw(G) <= B(d,H). A counterexample would be an infinite family of K_{1,d}-free graphs excluding H as an induced minor whose tree-independence numbers are unbounded.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2106",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20256v1",
    "status": "available",
    "timestamp": "2026-06-19T06:18:53.730025+00:00",
    "title": "Bounded tree-independence for K_{1,d}-free graphs excluding a planar induced minor"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any integers r\u22652 and any collection of r pairwise non\u2011isomorphic Shimura curves, any sequence of CM points with a common CM field and two distinct primes splitting in each field, if the points are strict (no proper special subvariety contains infinitely many of them), then the Galois orbits of the sequence become equidistributed in the product with respect to the Haar measure as the discriminants tend to infinity.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2108",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19933v1",
    "status": "available",
    "timestamp": "2026-06-19T07:11:19.175046+00:00",
    "title": "Equidistribution of Galois orbits of CM points on products of non\u2011isomorphic Shimura curves"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any oriented matroid, the e-embracing exchange distance between two e-embracing bases equals the graph distance between their corresponding e-positive fundamental circuits in the oriented matroid polyhedron P_{M^*,e}. This would strengthen Theorem 1.3 which only proves inequality and equality for uniform oriented matroids.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2109",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19573v1",
    "status": "available",
    "timestamp": "2026-06-19T08:25:04.863302+00:00",
    "title": "Equality of Embracing Exchange Distance and Polyhedral Graph Distance"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a tree graph \u0393, the Fitting ideal I_\u0393 is a complete intersection ideal in the polynomial ring k[x_1,...,x_n].",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2110",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19006v1",
    "status": "available",
    "timestamp": "2026-06-19T09:43:51.444927+00:00",
    "title": "Complete intersectionproperty of Fitting ideals for tree graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every positive integer q and natural number n, let P(n,q) denote the probability that the Random player wins the q-game. We conjecture that P(n,q) satisfies the recurrence relation: P(n,q) = 1/n + (1/n) * \u03a3_{k=q+1}^n P(n\u2212k, q), with base case P(0,q) = 0. This recurrence captures the probabilistic structure of the game coupled to random permutations' cycle decompositions.",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_2111",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18956v1",
    "status": "available",
    "timestamp": "2026-06-19T10:14:34.984628+00:00",
    "title": "Recurrence for the Winning Probability in the Generalized Game"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the exponential growth rate \u03b3 of unlabelled cubic planar graphs is equal to the reciprocal of the radius of convergence of their ordinary generating function G(z), and that the number of such graphs on n vertices satisfies an asymptotic formula of the form C \u00b7 \u03b3^n \u00b7 n^(-5/2) for some computable constant C > 0. This conjecture arises from the interplay between generating series analysis and probabilistic symmetry considerations outlined in the paper.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2112",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.17992v1",
    "status": "available",
    "timestamp": "2026-06-19T15:37:10.822708+00:00",
    "title": "Asymptotic Growth Constant for Unlabelled Cubic Planar Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "To formalize the concept of graph linear notation as a complete graph invariant in Lean 4, we propose defining it as the maximum binary encoding of adjacency matrices across all vertex orderings. This encoding uniquely represents a graph up to isomorphism by capturing its structure through lexicographic maximization.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2113",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19393v1",
    "status": "available",
    "timestamp": "2026-06-19T16:09:08.325435+00:00",
    "title": "Formalizing Graph Linear Notation in Lean 4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let B_n be the Birkhoff polytope, the convex hull in R^(n x n) of all n x n permutation matrices. Conjecture: B_n satisfies the clique-face property, meaning every clique in the 1-skeleton of B_n is exactly the vertex set of a face, if and only if n <= 2.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2114",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20430v1",
    "status": "available",
    "timestamp": "2026-06-19T16:12:43.783179+00:00",
    "title": "Birkhoff polytopes have the clique-face property only in dimensions n <= 2"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any odd base B > 3, the length of the longest nonconstant terminal cycle of the Kaprekar map is at most (B-1)/2. Furthermore, this upper bound is achieved if and only if B is prime and the multiplicative order of 2 modulo B equals (B-1)/2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2115",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20439v1",
    "status": "available",
    "timestamp": "2026-06-19T16:34:55.128748+00:00",
    "title": "Maximum Cycle Length in Kaprekar Maps for Odd Bases"
  },
  {
    "consumed_by_exp_id": "",
    "description": "If a projective Fraisse category associated with a continuum F has the approximate Ramsey property, then there exists a ultrafilter on the Fraisse category that witnesses extreme amenability of Homeo(F) by satisfying partition relations for all finite graphs.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2116",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-19T16:15:19.069232+00:00",
    "title": "Existence of an ultrafilter witness for extreme amenability"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that the \u03a9(r^-3) lower bound achieved in the paper is optimal up to constants, specifically that there exists a universal constant c > 0 such that for every r \u2265 2 and n \u2265 4r^2, any n-vertex r-graph where every (r+1)-set spans exactly 0 or 2 edges has at most c\u00b7r^-3\u00b7(n choose r) edges. This would prove that the polynomial improvement from 2^(1-r) to r^-3 is tight in terms of the r-dependence, establishing the true order of magnitude for this extremal problem.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2117",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20367v1",
    "status": "available",
    "timestamp": "2026-06-19T16:38:40.143734+00:00",
    "title": "Optimality of the r^-3 density bound for (r+1)-sets spanning 0 or 2 edges"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the projective Fraisse category of finite linear orders with the standard morphisms does NOT have the approximate Ramsey property, implying that its automorphism group (the infinite symmetric group) is NOT extremely amenable. This provides a concrete, falsifiable target for formalization in Lean 4, leveraging known results about the infinite symmetric group.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2121",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-19T18:13:04.539694+00:00",
    "title": "Approximate Ramsey Property for Finite Linear Orders Implies Extreme Amenability"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every finite K5-free simple graph G on n vertices, assign weight 1/2 to every edge contained in a triangle and weight 1 to every other edge. Then G has a bipartition whose monochromatic edge-weight is at most n^2/16. Equivalently, deleting edges of total such weight at most n^2/16 always makes G bipartite. The balanced complete 4-partite graph shows that the constant 1/16 would be best possible.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2122",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20397v1",
    "status": "available",
    "timestamp": "2026-06-19T20:03:57.336500+00:00",
    "title": "Weighted K5-free max-cut conjecture with triangle-discounted edges"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer d \u2265 10 there exist at least two pairwise non\u2011isomorphic line arrangements A and A' in \u2113\u00b2 such that they have the same intersection lattice L(A) \u2248 L(A'), the same minimal degree of a Jacobian relation mdr(A) = mdr(A'), and the same Hilbert function of their Milnor algebras M(A) and M(A'). Moreover, the minimal graded free resolutions of M(A) and M(A') are not isomorphic, so (A, A') is a Ziegler pair that does not satisfy condition (SPEC) (i.e., it is not a constant\u2011lattice specialization). The number of such inequivalent pairs is expected to grow without bound as d increases, indicating an abundance of non\u2011special Ziegler pairs beyond the known examples for d = 9 and d = 10.",
    "domains": [
      "Algebra",
      "Cryptography"
    ],
    "id": "fd_2123",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20421v1",
    "status": "available",
    "timestamp": "2026-06-19T21:51:23.134667+00:00",
    "title": "Abundance of non\u2011special Ziegler pairs for all degrees \u2265 10"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every integer k\u22653 there exist two k-uniform hypergraphs F1 and F2 such that 0<\u03b3\u207a(F1,F2)<\u00bd\u00b7min{\u03b3\u207a(F1),\u03b3\u207a(F2)}.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2124",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20494v1",
    "status": "available",
    "timestamp": "2026-06-19T23:10:37.707045+00:00",
    "title": "Strong quantitative non-principality for positive codegree Tur\u00e1n density"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every finite-dimensional vector space E over a finite field F and every rank r with 0 <= r <= dim E, the map sending a sparse-paving q-matroid M of rank r on E to its set of r-dimensional circuit-hyperplanes is a bijection onto the stable sets of the q-Johnson graph J_q(E,r), whose vertices are r-dimensional subspaces and whose edges join pairs with intersection dimension r-1. Equivalently, a set S of r-subspaces defines a sparse-paving q-matroid precisely when any two distinct members of S intersect in dimension at most r-2.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2125",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20348v1",
    "status": "available",
    "timestamp": "2026-06-19T20:04:48.178198+00:00",
    "title": "Sparse-paving q-matroids are exactly stable sets in the q-Johnson graph"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer r\u22652 there exists a constant C>0 such that for all sufficiently large n the maximum number of edges in an n\u2011vertex r\u2011uniform hypergraph in which each (r+1)-set spans exactly 0 or 2 edges is at least C\u00b7n^r / r\u00b3, and no such hypergraph can have more than C'\u00b7n^r / r\u00b2 edges. Equivalently, the Tur\u00e1n density \u03c0(H^r_3)=\u0398(1/r\u00b3).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2126",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20367v1",
    "status": "available",
    "timestamp": "2026-06-19T21:56:09.924073+00:00",
    "title": "Conjecture: Tur\u00e1n density of the 3\u2011edge r\u2011graph is \u0398(1/r\u00b3)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the structural characterization of large cross-intersecting families (F, G) where F \u2286 {[n] choose k} and G \u2286 {[n] choose l}. Specifically, prove that for n sufficiently large relative to k and l, if the diversity \u03b3(F) + \u03b3(G) exceeds a specific threshold, then the pair (F, G) must be contained in a specific class of maximal cross-intersecting extensions derived from the S_{U,V}^{Q}-shift operation, extending the Kupavskii-Zakharov stability framework to the cross-intersecting setting.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2127",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20085v1",
    "status": "available",
    "timestamp": "2026-06-19T23:14:39.273894+00:00",
    "title": "Cross-Intersecting Stability via Diversity and S_{U,V}^{Q}-Shifting"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In the context of projective Fraisse categories for continua, we conjecture that the pseudo-arc's category has the approximate Ramsey property, thereby implying its homeomorphism group is extremely amenable. This connects the combinatorial structure of the category to the dynamical property of the group via the framework established in the paper.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2128",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-20T02:12:56.856031+00:00",
    "title": "Approximate Ramsey Property for the Pseudo-Arc's Projective Fraisse Category"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the approximate Ramsey property of a projective Fra\u00efss\u00e9 category implies that the dense image of its automorphism group in a homeomorphism group of a continuum is extremely amenable. This establishes a formal link between combinatorial Ramsey-theoretic properties and topological amenability in the study of homeomorphism groups of continua.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2129",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-20T02:28:25.339989+00:00",
    "title": "Ramsey Theory in Projective Fra\u00efss\u00e9 Limits Implies Extreme Amenability of Homeomorphism Groups of Continua"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let $\\mathcal{F}$ be a projective Fraisse category and $\\mathbb{F}$ be its projective Fraisse limit. Let $G$ be a closed subgroup of $\\text{Homeo}(F)$ (where $F = \\mathbb{F}/R^{\\mathbb{F}}$) such that $\\text{Aut}(\\mathbb{F})$ is dense in $G$. We conjecture that $G$ is extremely amenable if and only if $\\mathcal{F}$ satisfies the approximate Ramsey property. This formalization requires encoding the approximate Ramsey property as a combinatorial property of the category and the extreme amenability as a fixed-point property for continuous actions on compact spaces.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2130",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-20T04:21:36.746301+00:00",
    "title": "Characterization of Extreme Amenability for Homeomorphism Groups of Projective Fraisse Limits"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer d \u2265 9, there exist two line arrangements of d lines in the complex projective plane with isomorphic intersection lattices, identical Hilbert functions of their Milnor algebras, identical minimal degree of a Jacobian relation, but distinct graded Betti numbers of the minimal free resolutions of their Milnor algebras (i.e., a Ziegler pair satisfying conditions (HF) and (MDR)).",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2131",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20421v1",
    "status": "available",
    "timestamp": "2026-06-20T06:03:40.471568+00:00",
    "title": "Existence of Ziegler pairs for all degrees at least nine"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For prime bases p>5, the paper reduces the longest terminal cycle length of the four-digit Kaprekar map to the least positive m such that 2^m \u2261 \u00b11 mod p. Conjecture: there are infinitely many primes p>5 for which this least m is exactly (p-1)/2, equivalently the Kaprekar map in base p has a terminal cycle attaining the universal upper bound (p-1)/2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2132",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20439v1",
    "status": "available",
    "timestamp": "2026-06-20T06:55:45.344564+00:00",
    "title": "Infinitely many prime bases with maximal four-digit Kaprekar cycles"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for any odd prime power q, and any non-zero constant c in the finite field F_q, the polynomial f_c(x) = c x^{q-1} + t \u2208 F_q(t)[x] has arboreal Galois image equal to the full iterated wreath product of the cyclic group C_{q-1} at every level n \u2265 1. This asserts that the Galois groups G_n \u2243 (C_{q-1} \u2240)^n for all n, generalizing the explicit families established in the paper to all non-zero c \u2208 F_q^*.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2133",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20046v1",
    "status": "available",
    "timestamp": "2026-06-20T07:49:00.400599+00:00",
    "title": "Arboreal Maximality for Twisted Carlitz Polynomials over Function Fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that the number of ordered pairs $(a,b)$ of positive integers with $a,b\\le x$ and $\\gcd(ab,a+b)=\\gcd(a,b)$ satisfies\n$$\\sum_{\\substack{a,b\\le x \\ \\gcd(ab,a+b)=\\gcd(a,b)}} 1 = C\\,x^{2}+O\\bigl(x(\\log x)^{3}\\bigr),$$\nwhere $C=\\displaystyle\\prod_{p}\\left(1-\\frac{1}{p^{2}(p+1)}\\right)\\approx 0.881513$ is the quadratic class number constant.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2134",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20057v1",
    "status": "available",
    "timestamp": "2026-06-20T08:45:29.951214+00:00",
    "title": "Improved error term for the density of pairs with $f(a,b)=1$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \\(\\mathcal S_1,\\dots,\\mathcal S_r\\) be pairwise non\u2011isomorphic Shimura curves attached to quaternion algebras over \\(\\mathbb Q\\) (or more generally to forms of \\(\\mathrm{PGL}_2\\)). For each \\(n\\) let \\(z_n=(z_{n,1},\\dots,z_{n,r})\\) be a CM point whose coordinates all have the same CM field \\(E_n\\). Assume the sequence \\((z_n)_n\\) is strict (its intersection with any proper special subvariety is finite). Then the Galois orbits \\(\\mathrm{Gal}(\\overline{\\mathbb Q}/\\mathbb Q)\\cdot z_n\\) become equidistributed in \\(\\mathcal S_1\\times\\dots\\times\\mathcal S_r\\) with respect to the product of the natural hyperbolic probability measures, **without any hypothesis that two fixed primes split in each \\(E_n\\)**. This conjecture extends Theorem\u202f1 of the cited paper by removing the Linnik\u2011type splitting condition, thereby providing an unconditional equidistribution statement for arbitrary sequences of CM points on such products.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2135",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19933v1",
    "status": "available",
    "timestamp": "2026-06-20T09:40:14.719737+00:00",
    "title": "Equidistribution of Galois orbits of CM points on products of non\u2011isomorphic Shimura curves without auxiliary splitting conditions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all n \u2265 0, the number of (4,0)-colored Frobenius partitions of weight n equals twice the sum of Lin-Liu minimal excludants over all 4-partitions of n, i.e., \u03c8_{4,0}(n) = 2\u03c3_{mex,4}(n). This conjecture extends the proven identities \u03c8_{2,0}(n) = 2\u03c3_{mex,2}(n) and \u03c8_{2,1}(n) = 2\u03c3_{mex,2}(n) - E_2(n) to the four-colored case.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2136",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19696v1",
    "status": "available",
    "timestamp": "2026-06-20T10:27:31.374184+00:00",
    "title": "Generalized two-colored Frobenius identities to four-colored case"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every finite-dimensional restricted Rota-Baxter Lie algebra (g,T) of weight \u03ba over a field of characteristic p that admits an intrinsic graph subalgebra characterization satisfies T\u2218T = \u03ba\u00b7id_g as endomorphisms of g.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2137",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19244v1",
    "status": "available",
    "timestamp": "2026-06-20T11:13:50.511359+00:00",
    "title": "Conjecture on Idempotent Up to Scalar Property of Restricted Rota-Baxter Operators"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers a,b,t with 3 < a \u2264 b, b \u2265 6, and t \u2265 b+1, the generalized Tur\u00e1n number satisfies ex(n,K_{a,b},K_{3,t}) = \u0398(n^3). Equivalently, there exist positive constants c,C and N, depending only on a,b,t, such that for every n \u2265 N, c n^3 \u2264 ex(n,K_{a,b},K_{3,t}) \u2264 C n^3. The paper proves this for t \u2265 2 max{3, ceil(b/2)}+1, which equals b+1 for even b \u2265 6 but is b+2 for odd b \u2265 7; the conjecture asserts that the necessary threshold b+1 is also sufficient in the odd case.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2138",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19217v1",
    "status": "available",
    "timestamp": "2026-06-20T12:03:02.988518+00:00",
    "title": "Necessary threshold for cubic generalized Tur\u00e1n growth against K_{3,t}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any graph G, any two minimal median decompositions of G (i.e., median decompositions whose underlying median graph has the smallest possible number of vertices) are isomorphic via a graph isomorphism that respects the decomposition bags. This formalises the \"uniquely minimal\" claim in the paper and provides a concrete, falsifiable statement that can be encoded in Lean.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2139",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19473v1",
    "status": "available",
    "timestamp": "2026-06-20T12:54:39.746194+00:00",
    "title": "Uniqueness of Minimal Median Decompositions for Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer \\(N\\ge 2\\) and every weight \\(k\\) admissible in the CHL construction, the series defining \\(\\widetilde{F}_k(\\Omega)\\) in equation (\\ref{eq:tildeFCF123}) converges absolutely on the Siegel upper half\u2011space \\(\\IH_2\\). Equivalently, each of the four component series \\(\\mathcal{F}_1,\\mathcal{F}_2,\\mathcal{F}_3,\\mathcal{F}_4\\) converges absolutely for all \\(\\Omega\\in\\IH_2\\).",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2140",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19479v1",
    "status": "available",
    "timestamp": "2026-06-20T13:46:56.776677+00:00",
    "title": "Uniform Convergence of the Single\u2011Centered Black Hole Generating Function \\(\\widetilde{F}_k\\) for All \\(\\mathbb{Z}_N\\) CHL Models"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every minimal forbidden partial cube-minor for the class of daisy cubes is isomorphic to the graph obtained from P_3^\u25a1r \u25a1 Q_s by deleting exactly two vertices that are antipodal in the hypercube embedding, for some integers r \u2265 2 and s \u2265 1.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2141",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19032v1",
    "status": "available",
    "timestamp": "2026-06-20T15:32:32.061109+00:00",
    "title": "Classification of Minimal Forbidden pc-Minors for Daisy Cubes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the q-game on n elements, where the deterministic player removes q elements per turn and the random player wins iff the first cycle of length at most q in canonical order is a fixed point, the probability that the random player wins approaches 1/q as n tends to infinity for any fixed positive integer q.",
    "domains": [
      "Computation"
    ],
    "id": "fd_2142",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18956v1",
    "status": "available",
    "timestamp": "2026-06-20T16:23:48.507943+00:00",
    "title": "Asymptotic probability of random player victory in q-games"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture relates the modular height of a Shimura variety to the logarithmic derivative of its Hecke L-function, quantifying how arithmetic intersection data control the height structure via comparison with derivative estimates.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2143",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18579v1",
    "status": "available",
    "timestamp": "2026-06-20T17:21:57.064265+00:00",
    "title": "Modular heights of units and Shimura varieties over CM fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every positive integer n, the number of Dyck paths of semilength n that are black\u2011white balanced under the column\u2011alternating coloring equals the Narayana number N(n,\u230an/2\u230b+1).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2144",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18754v1",
    "status": "available",
    "timestamp": "2026-06-20T18:39:07.780258+00:00",
    "title": "Column\u2011alternating balanced Dyck paths conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For bounded-horizon MT-TSP-MO instances with piecewise Lipschitz target and obstacle trajectories, if near-optimal continuous trajectories can be chosen with positive uniform clearance from all moving obstacles, then the TPBS algorithm run on grids whose mesh size tends to zero returns feasible solutions whose costs converge to the true MT-TSP-MO optimum. This is falsifiable: a single instance satisfying the clearance-regularity assumptions for which TPBS either fails to return a feasible solution or returns only solutions with cost bounded away from optimality at arbitrarily fine grid resolutions would refute it.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2145",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18730v1",
    "status": "available",
    "timestamp": "2026-06-20T19:50:32.009261+00:00",
    "title": "Asymptotic completeness and near-optimality of TPBS for clearance-regular MT-TSP-MO instances"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every 6-regular (4,1)-graph is super-6-edge-connected, i.e., every 6-edge-cut is the edge star of a single vertex. This extends Theorem B, which proves this only for graphs on at most 29 vertices, to all possible sizes. A counterexample would be a 6-regular (4,1)-graph containing a nontrivial 6-edge-cut (both shores have size \u2265 15 by Theorem B).",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2146",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18462v1",
    "status": "available",
    "timestamp": "2026-06-20T20:35:59.704821+00:00",
    "title": "Super-6-edge-connectivity of all 6-regular (4,1)-graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers n>2, the minimal length k such that any sequence of k non-zero residues modulo n contains an n-element subsequence summing to 0 modulo n but not modulo n^2 equals 2n+1.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2147",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18234v2",
    "status": "available",
    "timestamp": "2026-06-20T21:11:17.534802+00:00",
    "title": "Conjecture on s_1(n) for n>2"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let M(n) be the maximum, over all finite pairwise coprime sets A \u2286 {1,\u2026,n\u22121}, of \u2211_{a\u2208A} 1/(n\u2212a). Conjecture: there is an absolute real constant C such that for every n \u2265 2, M(n) \u2264 \u2211_{p<n, p prime} 1/p + C. This is the pointwise uniform form of Erd\u0151s's question studied in the paper, strengthened from the paper's average-order and almost-all results to all n.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2148",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.17955v1",
    "status": "available",
    "timestamp": "2026-06-20T23:03:21.735671+00:00",
    "title": "Uniform Erd\u0151s Bound for the Shifted Pairwise-Coprime Extremal Function"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let S_N(x)=sum_{i=1}^N x^i. For primes p<q with pq | m and n^2 >= (p-1)(q-1)+1, the conjecture says the cyclotomic transfer P=S_{m^2}/Phi_{pq}, Q=S_{n^2} Phi_{pq} is a nonstandard square-sided pair of sizes m^2 and n^2. Equivalently, the quotient and product have nonnegative integer coefficients, P(1)=m^2, Q(1)=n^2, and P Q=S_{m^2}S_{n^2}. A counterexample would be any admissible p,q,m,n for which one of these two explicit polynomials has a negative coefficient.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2149",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20311v1",
    "status": "available",
    "timestamp": "2026-06-20T06:09:07.372057+00:00",
    "title": "Semiprime cyclotomic transfer for square-sided dice"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For every integer d \u2265 1 and every planar graph H, there exists a constant C = C(d, H) such that any graph G that is K_{1,d}-free and does not contain H as an induced minor satisfies \u03b1\u2011tw(G) \u2264 C, i.e., the class of K_{1,d}-free graphs without H as an induced minor has bounded tree\u2011independence number.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2150",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20256v1",
    "status": "available",
    "timestamp": "2026-06-20T06:56:11.390123+00:00",
    "title": "Bounded tree-independence in K_{1,d}-free graphs excluding a planar minor"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \ud835\udc9c\u2286[n] choose k and \u212c\u2286[n] choose \u2113 be a cross\u2011intersecting pair (every A\u2208\ud835\udc9c meets every B\u2208\u212c). Define the diversity \u03b3(\ud835\udc9c)=|\ud835\udc9c|\u2011\u0394(\ud835\udc9c) where \u0394(\ud835\udc9c) is the maximum degree of \ud835\udc9c, and analogously \u03b3(\u212c). For n\u226bk,\u2113, suppose \u03b3(\ud835\udc9c)\u2265{n\u2011u\u20111 \\\\choose k\u20111} and \u03b3(\u212c)\u2265{n\u2011v\u20111 \\\\choose \u2113\u20111} for some integers u,v with u+v\u2264n\u2011k\u2011\u2113. The conjecture states that the only families attaining the maximal possible product |\ud835\udc9c|\u00b7|\u212c| under these diversity constraints are the \"canonical\" constructions obtained by taking a full star on a common element together with the unique maximal extensions described by the S_{U,V}^Q\u2011shift. This gives a sharp structural characterisation extending the Frankl\u2011Kupavskii\u2011Zakharov theorem to the cross\u2011intersecting setting.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2151",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20085v1",
    "status": "available",
    "timestamp": "2026-06-20T07:49:31.344472+00:00",
    "title": "Uniqueness of extremal large cross\u2011intersecting families via diversity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Proposes that n_k surpasses an exponential growth threshold, confirming asymptotic properties untested yet.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2152",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19863v1",
    "status": "available",
    "timestamp": "2026-06-20T09:40:46.679825+00:00",
    "title": "n_k Exceeds Exponential Bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for any finite set S of primes with |S| \u2265 k, the elementary symmetric partition function pre_k is injective on the set of integer partitions whose parts are S\u2011smooth (i.e., each part\u2019s prime factors lie in S). This generalizes the proven result for m\u2011ary partitions (S = {m}) to arbitrary finite prime sets.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2153",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19796v1",
    "status": "available",
    "timestamp": "2026-06-20T10:28:24.249630+00:00",
    "title": "Injectivity of pre_k on S\u2011smooth partitions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any oriented matroid of rank r, any element e\u2208E, and any two e\u2011embracing bases B and B\u2032, the e\u2011embracing distance d_e(B,B\u2032) equals the graph distance d_{G(P_{M^*,e})}(C(B,e),C(B\u2032,e)) in the 1\u2011skeleton of the oriented matroid polyhedron P_{M^*,e}.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2154",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19573v1",
    "status": "available",
    "timestamp": "2026-06-20T12:03:14.894829+00:00",
    "title": "Equality of e\u2011embracing distance and polyhedron graph distance"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any finite multiset M of natural numbers, let S_M be the set of all distinct permutations of M. Define tc(w) as the number of terminal closers (right\u2011to\u2011left minima) of w, i.e., indices i such that w_j > w_i for all j > i. Define cp(w) as the number of cyclic points of w, i.e., vertices i in [|M|] that lie on a directed cycle of the functional digraph i \u2192 w_i. The conjecture states that the total sum of tc(w) over w\u2208S_M equals the total sum of cp(w) over w\u2208S_M.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_2155",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19500v1",
    "status": "available",
    "timestamp": "2026-06-20T12:56:08.085469+00:00",
    "title": "Equidistribution of Terminal Closers and Cyclic Points in Multiset Permutations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper constructs explicit modular forms to establish Ramanujan-type congruences. We conjecture that for the partition function p(n), the explicit construction using the Rankin-Cohen bracket yields a modular form of weight 4 on SL(2,Z) whose Fourier expansion explicitly demonstrates that p(5n+4) \u2261 0 (mod 5) for all n \u2265 0. Specifically, let f(\u03c4) be the explicit modular form constructed via the bracket operator satisfying f(\u03c4) \u2261 (\u03b7(5\u03c4)/\u03b7(\u03c4))^5 (mod 5) in M_4(SL(2,Z)). Then the Fourier coefficients of f(\u03c4) should provide a direct proof that p(5n+4) \u2261 0 (mod 5).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2156",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.19008v1",
    "status": "available",
    "timestamp": "2026-06-20T15:33:31.323729+00:00",
    "title": "Verification of Ramanujan's modulo 5 congruence via explicit modular form construction"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper asserts precisely 57 nonnegative integer solutions (a, b, x) satisfy the inequality, confined by Diophantine approximation constraints.",
    "domains": [
      "Pythagorean",
      "MachineLearning"
    ],
    "id": "fd_2157",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.18500v1",
    "status": "available",
    "timestamp": "2026-06-20T17:22:17.670732+00:00",
    "title": "Exact Solution Count Confinement"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let a_n be the number of isomorphism classes of finite simple connected planar 3-regular graphs with n vertices. The conjecture is that a_{2m+1}=0 for every m, and that there exist real constants C>0 and gamma>1 such that a_{2m} / (C (2m)^(-7/2) gamma^(2m)) tends to 1 as m tends to infinity. This isolates the main enumerative shape of the paper in a Lean-formalizable form without committing to the paper-specific numerical values of C and gamma.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2158",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.17992v1",
    "status": "available",
    "timestamp": "2026-06-20T23:04:12.150157+00:00",
    "title": "Universal n^{-7/2} asymptotic for unlabelled connected cubic planar graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture asserts that if a continuum admits a projective Fraisse category whose automorphism group has a certain density condition, then its homeomorphism group behaves in a way tied to the exceptional amenability of its closed subgroups, formalizable within Lean 4 via exact properties of group flows.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2159",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-20T23:12:35.585104+00:00",
    "title": "Universal minimal flows in projective Fraisse categories"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For bidegree (2,3) line arrangements in P^2, constructing Ziegler pairs (isomorphic intersection lattices) with distinct minimal graded free resolutions of their Jacobian algebras while preserving the minimal degree of Jacobian syzygies.",
    "domains": [
      "Algebra",
      "Cryptography"
    ],
    "id": "fd_2160",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20421v1",
    "status": "available",
    "timestamp": "2026-06-21T00:41:41.529345+00:00",
    "title": "Existence of Ziegler Pairs with Same Minimal Degree of Jacobian Relation but Different Minimal Free Resolutions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any locally finite multigraph G, there exists a linked, componental, rooted tree-cut decomposition (T, V) of finite adhesion such that each bag V_t is finite and the map phi: Omega_E(G) -> V(T) U Omega(T) restricts to a bijection between the set of ends Omega(G) and the ends of the decomposition tree Omega(T).",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2161",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20452v1",
    "status": "available",
    "timestamp": "2026-06-21T00:43:04.763847+00:00",
    "title": "Existence of Linked Tree-Cut Decompositions for Locally Finite Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let X be the universal pseudo-solenoid. Let F be the projective Fraisse limit of the natural projective Fraisse category associated to X (as constructed in the paper), and let R be the equivalence relation on F such that F/R is homeomorphic to X. Let Phi: Aut(F) -> Homeo(X) be the induced map. We conjecture that the image of Phi is dense in Homeo(X) with respect to the uniform topology.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2162",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-21T01:41:43.242317+00:00",
    "title": "Density of the automorphism group of the projective Fraisse limit in the homeomorphism group of the universal pseudo-solenoid"
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
    "description": "Formalize the Euler-Mascheroni constant \u03b3 = lim(H_n - ln n). Prove key integral representations and series accelerations. Establish Ap\u00e9ry-like sequences that provide good rational approximations. Explore connections to the Stieltjes constants.",
    "domains": [
      "Analysis",
      "NumberTheory"
    ],
    "id": "seed_335",
    "priority_score": 0.8,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-18T03:56:25.432611+00:00",
    "title": "Euler-Mascheroni Constant: Irrationality Approaches"
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
    "status": "available",
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
    "description": "# FUTURE DIRECTIONS \u2014 Species EGFs as a Tropical Valuation Profile Bridge\n\nFollow-up conjectures generated by the cycle that produced\n`Catalog/Bridges/SpeciesTropicalValuation.lean`.  That file established the dictionary\n\n* structural product of species \u21a6 tropical product of valuations (`tropVal_mul`, `tropVal_card_prodSpecies`),\n* disjoint sum \u21a6 tropical `min`-superadditivity (`tropVal_add_le`),\n* valuation = minimal structure size (`Species.order_EGF_eq_nat`, `Species.one_le_order_EGF_iff`),\n* differential calculus \u21a6 shift by `trop 1` (`Species.order_pointed`, `Species.tropVal_pointed`),\n* reconstruction into an ultrametric absolute value (`specAbs_mul`, `specAbs_add_le`).\n\nEach conjecture below is precise and testable (statable directly in Lean over `\u211a\u27e6X\u27e7` /\n`CombinatorialSpecies`), ordered roughly by increasing difficulty.\n\n---\n\n## C1 \u2014 Sharp ultrametric equality at distinct leading orders (TESTABLE, likely provable)\n\nThe proved law `tropVal_add_le` is an *inequality*; standard nonarchimedean theory predicts\n**equality whenever the two orders differ**:\n\n> **Conjecture.** For `f g : \u211a\u27e6X\u27e7`, if `f.order \u2260 g.order` then `(f + g).order = min f.order g.order`,\n> equivalently `tropVal (f + g) = tropVal f + tropVal g` (tropical `+ = min`).\n\nConsequence for species: the disjoint union of two species with distinct minimal structure\nsizes has minimal size the smaller of the two. This upgrades `tropVal` to an exact tropical\nsemiring valuation off the \"diagonal\" `f.order = g.order`.\n\n## C2 \u2014 Substitution / composition is tropically multiplicative (BOLD)\n\nSpecies composition `F \u2218 G` (`G` with no empty structure) has EGF the substitution\n`EGF(F\u2218G) = (EGF F) \u2218 (EGF G)`. We conjecture the valuation multiplies:\n\n> **Conjecture.** If `g : \u211a\u27e6X\u27e7` has `1 \u2264 g.order` (constant term `0`), then for every `f`,\n> `(PowerSeries.subst g f).order = f.order * g.order` (with the `\u2115\u221e` convention `n * \u22a4 = \u22a4` for `n \u2260 0`).\n> Hence for species, `Species.tropVal (F \u2218 G) = Species.tropVal F * Species.tropVal G` in the\n> tropical *power* sense \u2014 minimal structure size of a composite is the product of minimal sizes.\n\nThis would extend the bridge from the additive (`+`, `\u00d7`, `d/dX`) operators to the *plethystic*\noperator, the last of Joyal's four basic constructions.\n\n## C3 \u2014 The prime-indexed valuation profile (BOLD, cross-file)\n\nThe X-adic order is the `X`-place valuation. Each prime `p` gives another valuation\n`n \u21a6 v_p(F.coeffSeq n)` of the *integer* counting sequence, producing a **profile**\n`(v_X, (v_p)_p)` \u2014 a genuinely tropical (multi-place) object linking to\n`Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_*`.\n\n> **Conjecture.** For the species of *sets* `E` (`coeffSeq \u2261 1`) every `v_p` profile is flat `0`,\n> while for the species of *cyclic orders* `C` (`coeffSeq n = (n-1)!` for `n \u2265 1`) the profile obeys\n> a Legendre/Lifting-the-Exponent law `v_p((n-1)!) = (n-1 - s_p(n-1))/(p-1)` (digit-sum `s_p`).\n> The X-adic place and the `p`-adic places jointly satisfy a product/sum formula across products\n> of species.\n\n## C4 \u2014 `specAbs` is a complete ultrametric and EGF is an isometric monoidal functor (BOLD)\n\n`specAbs` (proved multiplicative + strong-triangle) makes `\u211a\u27e6X\u27e7` an ultrametric.\n\n> **Conjecture.** `d(f,g) := specAbs (f - g)` is a complete ultrametric metric on `\u211a\u27e6X\u27e7`, and the\n> species EGF transform `Species \u2192 (\u211a\u27e6X\u27e7, d)` is an **isometric monoidal functor**: the species\n> distance `d\u209b(F,G) := 2^{-(least n with F.coeffSeq n \u2260 G.coeffSeq n)}` satisfies\n> `d\u209b(F,G) = d(EGF F, EGF G)`, and structural product is `1`-Lipschitz in each argument.\n\nThis is the concrete species-level realization of the `CategoricalTropicalUltrametric` slogan\n\"valuation reconstruction is a quantitative functor\".\n\n## C5 \u2014 The tropical spectrum of the derivative operator (base case PROVED; iterate open)\n\n`Species.order_pointed` shows pointing shifts valuation by `+1`. Dually, the base case below is now\n**proved** as `Species.order_derivative_succ`: differentiation lowers the valuation by exactly one\nonce the empty structure is absent. The iterated/spectral statement remains open.\n\n> **Proved (base case).** If `F.coeffSeq 0 = 0` (no empty structure), then\n> `F.EGF.order = F.derivative.EGF.order + 1`  (`Species.order_derivative_succ`).\n>\n> **Conjecture (iterate).** A species with minimal structure size `m` (i.e. `F.EGF.order = m`) satisfies\n> `F.derivative^[k].EGF.order = m - k` for all `k \u2264 m`, and `F.derivative^[m]` has a structure on\n> the empty set (`order = 0`). The integer `m` is thus the \"tropical spectral radius\" of `d/dX`\n> acting on `F` \u2014 the number of differentiations needed to expose a ground-level structure.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2003",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "14435cc3",
    "status": "available",
    "timestamp": "2026-06-16T10:37:42.559962+00:00",
    "title": "Follow-up conjectures generated by the cycle that produced"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Korselt Criterion & Divisor-Lattice Tropical Flatness\n\nDerived from the cycle that produced `Shared/KorseltCarmichael.lean` and\n`Bridges/KorseltTropicalFlatness.lean`. In that cycle we proved:\n\n- `Korselt n \u2192 FermatProperty n` (Korselt's criterion forces the universal Fermat\n  congruence `a^(n-1) \u2261 1 [MOD n]`), via Fermat-little-theorem lifting and\n  squarefree recombination;\n- `Korselt n \u2194 Squarefree n \u2227 \u2200 p\u2223n, (p-1).factorization \u2264 (n-1).factorization`\n  (Korselt = pointwise domination of prime-exponent / valuation profiles);\n- `dvd_iff_factorization_le` (divisibility = valuation-profile domination = tropical\n  flatness);\n- the Berggren shear law `berggren_M\u2083'^k = !![1,2k;0,1]` and\n  `berggren_M3_pow_reduces_iff : (M\u2083'^k mod m = 1) \u2194 m \u2223 2k`.\n\nThe conjectures below extend these findings.\n\n---\n\n## Conjecture 1 \u2014 Korselt is *equivalent* to the Carmichael/Fermat property\n\n**Statement.** For composite `n \u2265 2`, `FermatProperty n \u2194 Korselt n`. We have proved\n`\u2190`; the open part is `\u2192` (composite Fermat \u27f9 squarefree and `(p-1)\u2223(n-1)`).\n\n*The key insight is* that the converse is a *local* extraction: pick a primitive root\n`g` mod each prime power `p^e \u2225 n`; the order of `g` is `\u03c6(p^e)`, and `FermatProperty`\nforces `\u03c6(p^e) \u2223 n-1`. If `e \u2265 2` then `p \u2223 \u03c6(p^e) \u2223 n-1` while `p \u2223 n`, contradicting\n`gcd(n,n-1)=1`; hence `n` is squarefree and `(p-1)\u2223(n-1)`. The whole argument is the\n*inverse* of the recombination lemma already formalized.\n\n**Why now?** The forward recombination engine (`dvd_of_squarefree_of_forall_prime_dvd`)\nand the local Fermat lemma (`pow_modEq_one_of_sub_one_dvd`) are already in the catalog,\nso only the primitive-root extraction (`ZMod.exists_primitiveRoot` / `IsCyclic` of\n`(ZMod p)\u02e3`) remains to be wired in.\n\n## Conjecture 2 \u2014 Every Carmichael number has at least three prime factors\n\n**Statement.** If `Korselt n` and `n` is composite, then `n.primeFactors.card \u2265 3`.\n\n*The key insight is* that tropical flatness is *obstructed* in low dimension: if\n`n = p\u00b7q` with `p < q` then `(q-1) \u2223 (n-1) = pq-1 = p(q-1) + (p-1)` forces `(q-1)\u2223(p-1)`,\nimpossible for `0 < p-1 < q-1`. So the valuation profile of `n-1` cannot dominate the\nprofile of the *largest* `q-1` with only two prime coordinates.\n\n**Why now?** This is a direct, fully arithmetic corollary of `korselt_iff_flat`: it needs\nonly the two-factor case analysis plus `omega`/divisibility, no new heavy machinery, and\nit sharpens the non-vacuousness already witnessed by `561, 1105, 1729`.\n\n## Conjecture 3 \u2014 Quantitative flatness defect and a Korselt certificate\n\n**Statement.** Define the *flatness defect*\n`\u03b4(n) = \u2211_{q prime} max(0, (max_{p\u2223n} v_q(p-1)) \u2212 v_q(n-1))`. Then `Korselt n` (for\nsquarefree `n`) holds iff `\u03b4(n) = 0`, and `\u03b4` is computable, giving a decision procedure\nthat avoids primality testing of `n` itself.\n\n*The key insight is* that `\u03b4` linearizes the lattice condition: divisibility becomes a\nsingle nonnegativity test on a finitely-supported valuation vector (the tropical/`max`\nstructure of `Bridges/CategoricalTropicalUltrametric.lean`), turning \"`(p-1)\u2223(n-1)` for\nall `p`\" into one scalar.\n\n**Why now?** `korselt_iff_flat` already expresses Korselt as `factorization \u2264`; packaging\nthe gap as a `Finsupp`-supported sum is a short step and connects directly to the\nexisting tropical valuation objects and `vdepth_sum_le` in `Computation/PadicValuationDepth.lean`.\n\n## Conjecture 4 \u2014 Berggren shear order equals the additive order of `2` mod `m`\n\n**Statement.** The order of the reduced Berggren shear `M\u2083' mod m` in `GL\u2082(ZMod m)` is\n`m / gcd(2,m)`, i.e. the least `k > 0` with `m \u2223 2k`.\n\n*The key insight is* that `berggren_M3_pow_reduces_iff` already isolates the *only*\nnontrivial coordinate (`2k`); the order is therefore governed by a one-dimensional\nadditive-order computation, the matrix analogue of the single divisibility test\n`(p-1)\u2223(n-1)` in Korselt's criterion.\n\n**Why now?** `berggren_M3_pow` and `berggren_M3_pow_reduces_iff` reduce the problem to\n`Nat`-level: `IsLeast {k | 0 < k \u2227 m \u2223 2k} (m / gcd 2 m)`, provable by `omega`-style\ndivisibility reasoning with no matrix theory left.\n\n## Conjecture 5 \u2014 Flat reduction preserves Pythagorean primitivity across all prime divisors\n\n**Statement.** For the Berggren generators acting on primitive triples, the reduction mod\n`n` preserves primitivity of the orbit simultaneously at every prime `p \u2223 n` exactly when\n`n` is squarefree with a flat valuation profile (a Korselt-type condition on the shear\nexponents arising along tree paths).\n\n*The key insight is* that both phenomena are the *same* simultaneous-domination event:\nthe Carmichael condition makes one exponent `n-1` annihilate every local order `p-1`, and\nflat Berggren reduction makes one path-length exponent annihilate the shear order at every\n`p \u2223 n`. The bridge file already exhibits both as instances of `dvd_iff_factorization_le`.\n\n**Why now?** With `berggren_M3_pow_reduces_iff` and `korselt_iff_flat` both formalized in\n`Bridges/KorseltTropicalFlatness.lean`, the remaining content is to package the\ngenerator-orbit reduction (using `BerggrenLorentz` Pythagorean preservation from\n`Algebra/BerggrenLorentz/Core.lean`) and quantify the simultaneity, completing the\nthree-domain Shared \u2194 Computation \u2194 Pythagorean bridge.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2005",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "c3d42768",
    "status": "available",
    "timestamp": "2026-06-16T10:39:30.622454+00:00",
    "title": "Derived from the cycle that produced `Shared/KorseltCarmichael.lean` and"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 Tropicalized binary weight enumerator profiles\n\nFollow-up conjectures for the `SmoothPoincare` tropical-code thread. Each builds on the\nverified results in `TropicalWeightEnumerator.lean` (cycles 1\u20132: `twe`, `twePlus`,\nadditivity, `minDist` min-law, Hamming closed forms) and `TropicalProfile.lean`\n(cycles 3\u20134: the covering-radius collapse `twe = min(0, maxWt\u00b7t)`, the recovery theorem\n`twe (C.erase 0) = minDist\u00b7t`, the universal self-duality `twe+twePlus = n\u00b7t` for\nself-complementary codes). All conjectures are stated to be falsifiable by either a\n`native_decide` computation on a concrete code or a general `le_antisymm`-style proof.\n\n---\n\n## Conjecture 1 (Replication power law) \u2014 *strong, likely provable*\n\nLet `C^{\u2295k}` denote the `k`-fold direct sum (coordinate concatenation) of a code\n`C \u2286 (ZMod 2)\u207f`, a code of length `k\u00b7n`. Then for every `k` and every real `t`,\n```\ntwe (C^{\u2295k}) t = k \u00b7 twe C t,     twePlus (C^{\u2295k}) t = k \u00b7 twePlus C t,\nmaxWt (C^{\u2295k}) = k \u00b7 maxWt C,     minDist (C^{\u2295k}) = minDist C.\n```\n*Basis*: proved for `k = 2` on Hamming (`hamming16_twe`, `hamming16_minDist`) and the\nsingle-step laws `twe_append`, `twePlus_append`, `maxWt_append`, `minDist_append`.\n*Test*: induction on `k` using the cycle-3 append laws; the only obstacle is the `Fin`\nre-association `Fin ((k\u00b7n)+n) \u2243 Fin (k\u00b7n + n)`, soluble with `Fin.append` /\n`finCongr`. Falsifiable: any failure of `maxWt (C^{\u2295k}) = k\u00b7maxWt C` on a small code.\n\n## Conjecture 2 (Tropical profile rigidity / inverse problem) \u2014 *bold*\n\nTwo codes `C, D` both containing `0` have *identical full-code tropical profiles*\n(`twe C = twe D` and `twePlus C = twePlus D` as functions of `t`) **iff**\n`maxWt C = maxWt D`. Consequently the pair `(twe, twePlus)` on the *full* code is a\ncomplete invariant of the single number `maxWt`, and is *blind* to everything else\n(length, dimension, minimum distance, the entire interior weight spectrum).\n*Basis*: the collapse theorems `twe_eq_min_zero_maxWt`, `twePlus_eq_max_zero_maxWt`\nmake this immediate in one direction; the converse is `min(0,at)=min(0,bt) \u2200t \u27f9 a=b`.\n*Test*: a short real-analysis lemma (evaluate at `t = -1`). Falsifiable by exhibiting\ntwo `0`-containing codes with equal `maxWt` but different `twe` \u2014 the conjecture\npredicts this is impossible.\n\n## Conjecture 3 (Punctured profile reconstructs the convex hull) \u2014 *bold, central*\n\nFor a code `C` containing `0`, define the **doubly-punctured** enumerator on\n`C.erase 0 \\ {maxWt-attaining words}`. Iterating the puncture-and-recover operation of\n`twe_erase_eq_minDist_mul` peels off the weight spectrum from both ends, and the full\nordered sequence of distinct slopes obtained equals exactly the **vertices of the lower\nconvex hull** of the weight-multiset `{wt c : c \u2208 C}`. Equivalently: the tropical\nenumerator family `{ twe(C minus its current extreme words) }` is a complete encoding of\nthe Newton polygon of the weight spectrum.\n*Basis*: cycle-2 \"information loss\" insight + `twe_erase_eq_minDist_mul` (the `minDist`\nslope) + the `maxWt` slope. *Test*: define `slopes C := image wt C` and prove the\nrecovered slopes are precisely its convex-hull vertices; verify on Hamming that the\nrecovered slopes are `{0,4,8}` with hull `{0,8}` and the punctured slope `4`.\nFalsifiable on any code whose interior weight is a hull vertex.\n\n## Conjecture 4 (Tropical Singleton / Gleason envelope) \u2014 *speculative, high-value*\n\nFor every binary doubly-even self-dual code of length `n` (length `8 \u2223 n` by\n`GleasonLength.doublyEven_selfDual_length_div_eight`), the tropical \"gap\" between the\ncovering radius and packing radius obeys\n```\nmaxWt C + minDist C \u2264 n + 4,\n```\nwith equality for the extended Hamming `[8,4,4]` code (`8 + 4 = 8 + 4`). More boldly,\n`minDist C \u2264 4\u00b7\u230an/24\u230b + 4` (the tropical shadow of the Mallows\u2013Sloane bound), and the\nextremal codes are exactly those whose tropical profile pair `(twe, twe\u2218erase)` has\nslope set `{0, 4\u00b7\u230an/24\u230b+4, n}`.\n*Basis*: Hamming endpoints `maxWt = 8`, `minDist = 4`, `n = 8`; `selfDual_even_weight`\nforces even weights. *Test*: prove the additive bound from `wt_add_overlap` and\nself-orthogonality; check `native_decide` on the `[24,12,8]` Golay code if encodable.\nFalsifiable by any doubly-even self-dual code violating `maxWt + minDist \u2264 n + 4`.\n\n## Conjecture 5 (Tropical MacWilliams duality) \u2014 *speculative, deepest*\n\nDefine the **dual-code tropical enumerator** `twe (C\u22a5) t`. Conjecture a tropical\nMacWilliams relation: for every linear code `C \u2286 (ZMod 2)\u207f` and every `t \u2264 0`,\n```\ntwe (C\u22a5) t = (n \u00b7 t) \u2212 maxWt C \u00b7 t  =  (n \u2212 maxWt C) \u00b7 t,\n```\ni.e. the covering radius of `C` controls the minimum distance of `C\u22a5` through\n`minDist(C\u22a5) = n \u2212 maxWt C` whenever `0 \u2208 C` (a tropicalized \"dual distance =\nco-covering radius\"). For self-dual `C` this degenerates to the fixed point\n`maxWt C = n \u2212 minDist(C)`, predicting `maxWt hamming = 8 \u2212 4 = 4`? \u2014 **NB this last\nnumerical check fails for Hamming (`maxWt = 8 \u2260 4`), so the precise constant is part of\nwhat must be discovered**; the robust, testable core is the *linear-in-`t`* form of\n`twe(C\u22a5)` for `t \u2264 0` and its dependence only on a single dual invariant.\n*Basis*: classical MacWilliams `W_{C\u22a5} = |C|\u207b\u00b9 W_C(x+y, x\u2212y)`, whose tropicalization\nturns the Hadamard transform into an inf-convolution. *Test*: formalize the tropical\n(inf-plus) MacWilliams transform and verify additivity under direct sum mirrors\n`twe_append`. Falsifiable: compute `twe(hamming\u22a5) = twe(hamming)` (self-dual) and check\nagainst the conjectured linear form.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2008",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "2ec4044e",
    "status": "available",
    "timestamp": "2026-06-16T11:24:51.896540+00:00",
    "title": "Follow-up conjectures for the `SmoothPoincare` tropical-code thread. Each builds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 Computational Complexity as a Physical Law\n\nDerived from the Phase A cycle that produced\n`Catalog/Physics/ComplexityPhysicalLaw.lean` and\n`Catalog/Speculative/ExtendedChurchTuring.lean`. Both files glue the\n**Computation** domain (`Computation/EntropyBridge.lean`: reversible compressors and\nfinite source-coding bounds) to the **Physics** domain\n(`Physics/LocalHamiltonianQMA.lean`: certified energy lower bounds and the\nQMA promise gap). The cycle established two load-bearing facts:\n\n* a reversible `k`-bit recorder of a finite physical family obeys `|family| \u2264 2^(k+1)`\n  (Landauer memory floor), and\n* a certified NO-instance (ground energy `\u2265 b`) can never be straddled by a\n  YES-witness at any strictly lower threshold `a < b` (energetic, memory-free\n  impossibility).\n\nThe boundary discovered in Stage 3/4 \u2014 the constant is `2^(k+1)` not `2^k`, and the\ngap impossibility needs *strict* `a < b` \u2014 drives the conjectures below.\n\n---\n\n## Conjecture 1 \u2014 Reversible-memory capacity is exactly `2^(k+1)`, and this is tight.\nFor every `k`, there is a finite physical family of size exactly `2^(k+1)` recorded\nlosslessly by a reversible `k`-bit compressor, and no family of size `2^(k+1)+1` can be.\n- **The key insight is...** reversibility buys precisely one extra bit (the empty\n  codeword `[]` of length `0`), so the addressable code space is the lengths-`\u2264 k`\n  strings, whose count is `2^(k+1) \u2212 1`, giving the off-by-one already visible in\n  `landauer_memory_floor`.\n- **Why now?** `complexity_bound_implies_finite_entropy_bound` already proves the\n  upper half; the matching lower half (an explicit length-`\u2264 k` enumeration) is a\n  finite combinatorial construction well within reach of the current `Finset` toolbox.\n\n## Conjecture 2 \u2014 A polynomial energy-certificate ladder forbids a polynomial demon.\nIf a family of `k`-local Hamiltonians admits per-term `EnergyLB` certificates whose\ntotal grows like a fixed polynomial `p(n)` in the instance size, then any device that\nboth reversibly records instances in `O(log p(n))` bits **and** outputs YES-witnesses\nmust be inconsistent on the NO-certified sub-family.\n- **The key insight is...** `maxwell_demon_landauer_bound` already shows the two\n  domains constrain the *same* device; promoting `b` and `k` from constants to\n  polynomials in `n` turns the static bound into a genuine separation between\n  certification cost and witnessing power.\n- **Why now?** The `EnergyLB.mono` glue lemma makes summed certificates rescalable to\n  any threshold, so a polynomial family of thresholds is a direct generalization rather\n  than new infrastructure.\n\n## Conjecture 3 \u2014 Frustration is a quantitative memory tax.\nFor the frustrated pair `Hz, Hx` of `Physics/LocalHamiltonianQMA.lean`, the\nsuper-additive ground-energy gap (no common zero-energy state) implies a strictly\npositive *extra* number of bits any demon must spend to distinguish frustrated from\nunfrustrated instances, compared with the term-by-term minimum.\n- **The key insight is...** `frustration_no_common_ground_state` makes the\n  ground-energy strictly larger than `\u2211 \u03bb i`, and a strictly larger energy threshold\n  enlarges the NO-certified family, which by the Landauer floor `2^(k+1)` strictly\n  raises the required `k`.\n- **Why now?** Both ingredients \u2014 the frustration witness and the\n  `card \u2264 2^(k+1)` floor \u2014 are now formalized and live in the same import graph, so the\n  product statement is assemblable today.\n\n## Conjecture 4 \u2014 The Extended Church\u2013Turing encoding is functorial under simulation.\nThe injective `k`-bit encoding of `ect_encoding_iff` can be chosen to commute with any\ndeterministic step map: simulating one physical step costs at most one re-encoding and\nnever increases `k`.\n- **The key insight is...** `deterministic_evolution_no_new_states` shows deterministic\n  evolution is contractive on distinguishable states, so the entropy bound \u2014 and hence\n  the achievable code length `k` \u2014 is preserved along an orbit.\n- **Why now?** With the encoding *equivalence* (`ect_encoding_iff`) and the\n  data-processing contraction both proved, the only remaining step is to thread an\n  embedding through the composition, a `Function.Embedding` bookkeeping exercise.\n\n## Conjecture 5 \u2014 `P = NP` collapses the energy-certificate hierarchy.\nA complexity-theoretic `P = NP` hypothesis (efficient YES-witness production for the\nground-energy promise problem) is *equivalent*, under the bridge, to the existence of a\nreversible sub-`2^(k+1)`-memory demon that resolves arbitrarily large NO-certified\nfamilies \u2014 contradicting the Landauer floor.\n- **The key insight is...** the contrapositive reading of\n  `maxwell_demon_landauer_bound` already packages \"efficient witnessing of NO-instances\"\n  as a logical impossibility; turning the implication into an equivalence pins\n  `P = NP` to a single physical inequality.\n- **Why now?** The forward direction (demon \u21d2 contradiction) is proved; the converse\n  needs only a reduction encoding SAT-style instances as local Hamiltonians, which the\n  existing `energyLB_sum` certificate calculus is purpose-built to express.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2011",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "16e95997",
    "status": "available",
    "timestamp": "2026-06-16T12:53:09.336726+00:00",
    "title": "Derived from the Phase A cycle that produced"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Functorial Tropical\u2013Pythagorean Bridge (Probability)\n\nThis cycle established a *normalization functor into the probability simplex*\nthat unifies three threads:\n\n* **Tropical**: `lse2`, `softmax2`, and the general `softmax`, with the Maslov\n  dequantization sandwich `max \u2264 lse2 \u2264 max + log 2`.\n* **Probability**: two-point (Bernoulli) laws, `bernVar`, and the cumulant\n  identities `deriv lse2 = softmax2` (mean) and `deriv\u00b2 lse2 = bernVar \u2218 softmax2`\n  (variance = tropical curvature).\n* **Pythagorean**: the map `(a,b,c) \u21a6 ((a/c)\u00b2, (b/c)\u00b2)` lands in the simplex,\n  is dilation-invariant, equals the softmax image of log-squared coordinates,\n  and yields the Pythagorean probability identity `(p\u2212q)\u00b2 + 4\u00b7Var = 1`.\n\nThe conjectures below are precise, falsifiable targets for the next cycle. Each\nis stated so it can be dropped into Lean as a `theorem \u2026 := by sorry` and\nattacked directly.\n\n## Conjecture 1 (n-point tropical Hessian = covariance)\nThe general softmax `softmax w` is the gradient of the n-point free energy\n`lse w := log \u2211\u2c7c exp (w j)`, and the Hessian of `lse` is the covariance matrix of\nthe Gibbs law:\n```\n\u2202\u00b2/\u2202w\u1d62\u2202w\u2c7c lse w = (if i = j then softmax w i \u00b7 (1 - softmax w i)\n                    else - softmax w i \u00b7 softmax w j).\n```\n**Test.** Prove `deriv (fun t => lse (Function.update w i t)) (w i) = softmax w i`\nand the diagonal/off-diagonal second-derivative formulas. Expected: the diagonal\nspecializes to `bernVar (softmax w i)`, generalizing `deriv2_lse2_eq_bernVar`.\n\n## Conjecture 2 (Pythagorean parametrization of the full simplex)\nEvery interior Bernoulli law arises from a *real* Pythagorean relation: for all\n`p \u2208 (0,1)` there exist `a,b,c > 0` with `a\u00b2 + b\u00b2 = c\u00b2`, `(a/c)\u00b2 = p`. Concretely\n`a = \u221ap\u00b7c`, `b = \u221a(1\u2212p)\u00b7c`. Moreover the induced standard deviation satisfies\n`\u03c3 = |ab|/c\u00b2 = \u221a(p(1\u2212p))`, so **the Bernoulli standard deviation is exactly half\nthe normalized area `2ab/c\u00b2` of the right triangle**.\n**Test.** Prove surjectivity of `p \u21a6` Pythagorean triple and the identity\n`2 * Real.sqrt (bernVar p) = 2*a*b/c^2` for the canonical triple. Falsifiable:\nthe area-to-\u03c3 proportionality constant is conjectured to be exactly `2`.\n\n## Conjecture 3 (Maslov interpolation is monotone and contracts to max)\nDefine the temperature-scaled functional `lseT h a b := h \u00b7 log(exp(a/h)+exp(b/h))`\nfor `h > 0`. Then `h \u21a6 lseT h a b` is monotone non-decreasing, `lseT h a b \u2192 max a b`\nas `h \u2192 0\u207a`, and the *Gibbs entropy gap* `lseT h a b \u2212 max a b \u2208 [0, h\u00b7log 2]`.\n**Test.** Prove the sandwich `max a b \u2264 lseT h a b \u2264 max a b + h\u00b7log 2` (rescale\nthe proved `lse2` sandwich) and the limit `Filter.Tendsto (fun h => lseT h a b)\n(nhdsWithin 0 (Set.Ioi 0)) (nhds (max a b))`. This is the quantitative\ndequantization underlying the whole bridge.\n\n## Conjecture 4 (Pythagorean identity is the \u03c7\u00b2 / information projection at 2 points)\nFor the Pythagorean-induced law `p = (a/c)\u00b2`, the polarization leg `p \u2212 q` equals\nthe (signed) \u03c7\u00b2-type discrepancy from the uniform law `(\u00bd,\u00bd)`:\n`(p \u2212 \u00bd)\u00b2 + (q \u2212 \u00bd)\u00b2 = \u00bd\u00b7(p \u2212 q)\u00b2 = \u00bd\u00b7(1 \u2212 4\u00b7Var)`. Hence **maximal Bernoulli\nvariance \u21d4 minimal \u03c7\u00b2-distance to uniform \u21d4 the degenerate right triangle\n`a = b`**, i.e. the isoceles Pythagorean triple `(1,1,\u221a2)`.\n**Test.** Prove the \u03c7\u00b2 identity and that `Var` is maximized exactly when\n`(a/c)\u00b2 = (b/c)\u00b2`, characterizing the optimizer as the isoceles triple. Connect\nto a genuine `Real.rpow`-based R\u00e9nyi/Tsallis entropy and show the leg `p\u2212q`\ncontrols a one-parameter family of divergences from uniform.\n\n## Conjecture 5 (Functorial naturality square)\nThe two functors into the simplex commute with their symmetries: softmax\nintertwines the additive `\u211d`-shift action on log-coordinates with the trivial\naction on the simplex, and the Pythagorean functor intertwines the multiplicative\n`\u211d\u02e3`-dilation action on triples with the trivial action. Conjecture: there is a\n*natural transformation* `log\u2218(\u00b7)\u00b2 : (Pythagorean triples / dilation) \u27f9\n(log-coordinates / shift)` making the triangle\n`softmax \u2218 (log \u2218 sq) = pythProb` commute as functors, not merely pointwise.\n**Test.** Formalize both as actions (`AddAction \u211d` and `MulAction \u211d\u02e3`) on the\nrespective domains, define the quotients, and prove the induced maps to the\nsimplex are well-defined and equal. The pointwise version is already proved\n(`pyth_eq_softmax2`); the goal is to upgrade it to an equivariant/quotient\nstatement.\n",
    "domains": [
      "Tropical",
      "Bridges"
    ],
    "id": "fd_2012",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "3b102b1d",
    "status": "available",
    "timestamp": "2026-06-16T13:27:48.242946+00:00",
    "title": "*normalization functor into the probability simplex*"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Proofs as DAGs \u2014 Future Directions\n\nResearch cycle 1 established a self-contained, choice-light theory of the\n*directed acyclic* structure of mathematical dependency, centred on a single\nconstructive invariant:\n\n```\nproofDepth R v := #{ u | Relation.TransGen R u v }   -- number of (transitive) dependencies\n```\n\nwith the master inequality `R u v \u2192 proofDepth R u < proofDepth R v`\n(`Reachability.proofDepth_lt_of_rel`).  From it we derived: a constructive\ntopological order, existence of axioms (sources) and frontier results (sinks),\nwell-foundedness of the dependency relation (induction-on-dependencies),\nasymmetry/irreflexivity, the bounded-depth principle `chain length < |V|`\n(`Chains.chain_length_lt_card`), and the citation-capacity bound\n`edgeCount R \u2264 C(|V|,2)` (`EdgeBounds.edgeCount_le_choose`).\n\nThe following conjectures are bold but testable extensions for the next cycles.\nEach is stated so it can be dropped into a Lean file as a `theorem \u2026 := by sorry`\ntarget.\n\n## C1. Tightness of the citation-capacity bound (Tur\u00e1n-type characterisation)\n\nThe `C(|V|,2)` ceiling of `edgeCount_le_choose` is attained, and *only* by\ntransitively-closed total orders (\"every result cites every predecessor\"):\n\n```\nconjecture edgeCount_eq_choose_iff {V} [Fintype V] {R : V \u2192 V \u2192 Prop} (hR : IsDAG R) :\n    edgeCount R = (Fintype.card V).choose 2 \u2194 IsTrans V R \u2227 IsTotalStrict V R\n```\nwhere `IsTotalStrict` means `\u2200 u v, u \u2260 v \u2192 R u v \u2228 R v u`.  Falsifiable: a single\nacyclic non-transitive relation hitting the bound would refute it.\n\nPROGRESS (cycle 1): the sub-target witness is **done** \u2014 `EdgeBounds.isDAG_lt` and\n`EdgeBounds.edgeCount_lt_eq_choose` prove `R := (\u00b7 < \u00b7)` on `Fin n` is a DAG with\n`edgeCount = n.choose 2`, so the bound is sharp.  What remains for C1 is the\n*only-if* characterisation (uniqueness of the extremal pattern up to relabelling).\n\n## C2. Mirsky's theorem: the *height* function is an optimal antichain colouring\n\nNOTE (cycle-1 correction).  The ancestor-count `proofDepth` is a *valid* antichain\ncolouring \u2014 equal depth implies incomparable, see `Levels.proofDepth_level_antichain`\n\u2014 but it is **not minimum**.  Counterexample (verified numerically in cycle 1):\nsources `s\u2081,s\u2082,s\u2083`, with `x\u2096` citing `s\u2081,\u2026,s\u2096`; the longest chain has length `2`\nyet `proofDepth` uses `4` distinct values `{0,1,2,3}`.  So Mirsky must be phrased\nwith the genuine *height* (longest descending chain ending at `v`):\n\n```\nnoncomputable def height (R : V \u2192 V \u2192 Prop) (v : V) : \u2115 :=\n    sSup { n | \u2203 c, IsChain R c n \u2227 c n = v }\n\nconjecture mirsky_height {V} [Fintype V] {R : V \u2192 V \u2192 Prop} (hR : IsDAG R) :\n    (Finset.univ.image (height R)).card\n      = 1 + (sSup { n | \u2203 c, IsChain R c n })   -- longest chain length\n```\nSub-targets: (a) `height`-levels are antichains; (b) `R u v \u2192 height u < height v`\n(direct edges raise height by exactly the right amount); (c) a chain of length\n`max height` exists (walk down maximising), giving the `\u2265` direction; (d)\n`chain_length_lt_card` gives boundedness.  The cleanly-true fragment\n\u201cdepth-levels are antichains\u201d is already proved this cycle in `Levels.lean`.\n\n## C3. Dilworth duality for proof DAGs\n\nDual to C2: the minimum number of chains needed to cover all statements equals\nthe size of the largest set of pairwise-independent results (maximum antichain):\n\n```\nconjecture dilworth_proofDAG {V} [Fintype V] {R : V \u2192 V \u2192 Prop} (hR : IsDAG R) :\n    minChainCover R = maxAntichain R\n```\nThis is the \"parallelism width\" of mathematics: how many independent research\nthreads a body of theory supports.  Hardest of the set; likely needs a\nmatching/flow argument or Mathlib's order-theoretic Dilworth if/when available.\n\n## C4. Transitive reduction exists and is unique (the \"essential citations\")\n\nEvery finite proof DAG has a unique minimal sub-relation with the same reachability\n\u2014 its *transitive reduction* `R\u207b`, the genuinely load-bearing citations:\n\n```\nconjecture transitive_reduction_unique {V} [Fintype V] {R : V \u2192 V \u2192 Prop} (hR : IsDAG R) :\n    \u2203! S : V \u2192 V \u2192 Prop, (\u2200 u v, Relation.TransGen S u v \u2194 Relation.TransGen R u v)\n        \u2227 Minimal (fun T => \u2200 u v, Relation.TransGen T u v \u2194 Relation.TransGen R u v) S\n```\nTestable corollary: `edgeCount R\u207b \u2264 edgeCount R`, with the reduction never longer\nthan `|V|-1` along any single chain (re-using `chain_length_lt_card`).\n\n## C5. Fragility: removing axioms strictly shrinks the reachable theory\n\nA directed analog of `Handshaking`'s hub-removal results.  Deleting a source\n(axiom) strictly decreases the number of derivable statements, and the *most\nload-bearing* axiom is the source of maximum descendant count:\n\n```\nconjecture source_removal_shrinks {V} [Fintype V] {R : V \u2192 V \u2192 Prop}\n    (hR : IsDAG R) (s : V) (hs : \u2200 u, \u00ac R u s) :\n    (descendants R s).card \u2265 1 \u2192\n      edgeCount (restrict R s\u1d9c) < edgeCount R\n```\nwhere `descendants R s := {v | Relation.TransGen R s v}`.  This quantifies the\nintuition that foundational results are irreplaceable: their removal fragments\nthe dependency graph.  Connects cycle-1 directed theory back to the undirected\n`Handshaking.tree_has_two_leaves` / hub story.\n\n---\n\n### Methodological notes for the next cycle\n* The constructive `proofDepth` invariant was decisive \u2014 it converted four\n  existence theorems into minimiser/maximiser arguments. Seek a single analogous\n  invariant for C2/C3 (candidate: longest-descending-chain length, a.k.a. height).\n* Prefer `\u2115`-indexed chains (`Chains.IsChain`) over `Fin`-indexed; the bounded\n  induction was frictionless this way.\n* `Relation.TransGen` decidability forced `noncomputable`/`classical`; if a\n  decidable development is wanted, add `[DecidableRel R]` and use Mathlib's\n  Floyd\u2013Warshall-style transitive-closure decidability.\n",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_2013",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6fe73404",
    "status": "available",
    "timestamp": "2026-06-16T15:03:32.088898+00:00",
    "title": "Research cycle 1 established a self-contained, choice-light theory of the"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Mandelbrot Quadratic Recurrence & Number Theory\n\nDerived from the research cycle that produced:\n\n- `Tropical/MandelbrotGleason.lean` \u2014 the Gleason polynomials `g\u2099 = g_{n-1}\u00b2 + X`,\n  proved monic of degree `2^(n-1)`, with the critical-orbit interpretation\n  (`gleason_eval`) and the concrete period-1/period-2 centers.\n- `Tropical/MandelbrotPeriodPrimality.lean` \u2014 M\u00f6bius inversion of the center count\n  (`primCount_cumulative`), `primCount p = 2^(p-1) \u2212 1`, and the **Fermat bridge**\n  `odd_prime_dvd_primCount` with its sharp boundary `not_two_dvd_primCount_two`.\n- `Tropical/MandelbrotNecklace.lean` \u2014 **Gauss's congruence** `n \u2223 \u2211_{d\u2223n} \u03bc(n/d) a\u1d48`\n  in full generality, and its corollaries `n \u2223 2\u00b7primCount n`, `odd_dvd_primCount`.\n- `Tropical/MandelbrotKnotBridge.lean` \u2014 a cross-domain bridge using the catalog's\n  torus-knot Alexander polynomial (`alexander_fundamental_identity` from\n  `Tropical.CyclotomicKnotSpectra`): `3\u00b7(A_p(2) \u2212 1) = 2\u00b7primCount p` for odd primes `p`.\n\nEach conjecture below is falsifiable: it is either provable in Lean from the definitions\nalready in this subtree, or refutable by a single explicit counterexample.\n\n---\n\n## Conjecture 1 \u2014 The 2-adic valuation of `primCount n` is exactly `v\u2082(n) \u2212 1 ... 0`\n\n**Statement (testable).** For `n \u2265 2`, the even/odd dichotomy globalises:\n`primCount n` is odd whenever `n` is odd, and `2 \u2223 primCount n` fails *exactly* when\n`n` is a power of two times an odd part that is squarefree-prime \u2014 i.e. there is a clean\nformula `v\u2082(primCount n)` in terms of the prime factorisation of `n`.\n\n**The key insight is** that `n \u2223 2\u00b7primCount n` (`n_dvd_two_mul_primCount`) already pins\nthe *first* 2-adic bit, so the obstruction `not_two_dvd_primCount_two` is the base case of\na recursive valuation law, not an isolated accident.\n\n**Why now?** We possess Gauss's congruence as a Lean theorem; combining it with\n`Nat.factorization` and the lifting-the-exponent lemma `a^(p^k) \u2261 a^(p^(k-1)) [ZMOD p^k]`\nused inside `gauss_congruence` puts a full valuation formula within one induction's reach.\n\n---\n\n## Conjecture 2 \u2014 Gleason polynomials are separable (all centers are simple)\n\n**Statement (testable).** For every `n \u2265 1`, `gleason n` is separable over `\u211a`; hence the\n`2^(n-1)` period-dividing-`n` centers counted by `gleason_natDegree` are **distinct**, and\n`primCount n` is the *exact* number of primitive period-`n` hyperbolic components.\n\n**The key insight is** that `gleason (n+1) = (gleason n)\u00b2 + X` has derivative\n`2\u00b7gleason n\u00b7gleason' n + 1`, whose constant term `1` blocks the obvious common-root\nmechanism \u2014 separability should follow from `gcd(gleason n, gleason' n) = 1` by induction.\n\n**Why now?** `gleason_monic` and `gleason_natDegree` already give the degree bookkeeping;\nseparability is the one missing ingredient that upgrades every \"with multiplicity\" count\nin `MandelbrotPeriodPrimality` to an honest cardinality of a `Finset` of centers.\n\n---\n\n## Conjecture 3 \u2014 A Fibonacci entry-point bridge for the period lattice\n\n**Statement (testable).** The catalog's Fibonacci entry-point function\n(`fibEntryPt`, `fibEntryPt_dvd_of_fib_dvd` in `Speculative.AutoResearch.CarmichaelComposite`)\nand `primCount` obey a shared divisibility skeleton: for every `n`,\n`n \u2223 2\u00b7primCount n` and `fibEntryPt p \u2223 n \u21d4 p \u2223 fib n` are two instances of the same\n\"orbit length divides index\" phenomenon, and there is a single lemma subsuming both.\n\n**The key insight is** that both counts arise from a free cyclic action (rotation of\nnecklaces for `primCount`, shift of the Fibonacci recurrence mod `p` for `fibEntryPt`), so\nthe divisibility is structural rather than coincidental.\n\n**Why now?** Gauss's congruence is now formal *and* the Fibonacci entry-point theory is\nalready in the catalog; a cross-domain lemma can be stated and attacked immediately,\nturning two separate results into one reusable abstraction.\n\n---\n\n## Conjecture 4 \u2014 Necklace congruence governs every quadratic-recurrence center count\n\n**Statement (testable).** Replace `z\u00b2 + c` by `z^m + c` (`m \u2265 2`). The analogue of\n`gleason` has degree `m^(n-1)`, and the primitive count\n`primCount_m n = \u2211_{d\u2223n} \u03bc(n/d) m^(d-1)` again satisfies `n \u2223 m\u00b7primCount_m n`, with\n`n \u2223 primCount_m n` whenever `gcd(m, n) = 1`.\n\n**The key insight is** that `gauss_congruence` is already stated for an *arbitrary* base\n`a : \u2124`, so the unicritical-degree-`m` family is covered by the identical theorem; only the\nGleason-degree lemma needs re-running with `m` in place of `2`.\n\n**Why now?** The base-generality of `gauss_congruence` was proved this cycle but only\nexploited at `a = 2`; harvesting it for all `m` is essentially free and immediately tests\nwhether the \"Mandelbrot encodes primality\" slogan is special to squaring or universal to\nall unicritical polynomials.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2014",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "7e82348b",
    "status": "available",
    "timestamp": "2026-06-16T15:04:03.733652+00:00",
    "title": "Derived from the research cycle that produced:"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Integrated Information via Tensor Networks\n\nThis research cycle established the dictionary\n\n> **IIT min-cut \u03a6  \u2261  tensor-network min-cut entanglement capacity**\n> (under `weight = log(bond dimension)`),\n\nand proved two structural laws of the cut functional: **submodularity**\n(`crossInfo_submodular`) and **superadditivity under superposition**\n(`phi_superadditive`). The conjectures below are the falsifiable targets for the\nnext cycles, ordered roughly by ambition.\n\n## C1. Holographic Strong Subadditivity (min lifts submodularity)\n\nCycle 1 proved the *cut function* `S \u21a6 crossInfo S` is submodular. Define the\n**holographic entropy** of a region `A \u2286 Fin n` as the minimum cut separating\n`A` from `A\u1d9c`, `S\u2095\u2092\u2097(A) = min { crossInfo S : A \u2286 S, S nontrivial }`.\n\n> **Conjecture C1.** `A \u21a6 S\u2095\u2092\u2097(A)` is itself submodular; equivalently, for\n> disjoint regions `A,B,C`:\n> `S\u2095\u2092\u2097(A\u222aB) + S\u2095\u2092\u2097(B\u222aC) \u2265 S\u2095\u2092\u2097(A\u222aB\u222aC) + S\u2095\u2092\u2097(B)`.\n\nThis is the discrete Ryu\u2013Takayanagi strong-subadditivity statement. Test: prove\nthe cut-and-paste inequality `crossInfo(S\u2229T) + crossInfo(S\u222aT) \u2264 crossInfo S +\ncrossInfo T` (already have it) and combine with optimality of the minimizing\ncuts. Falsifiable by a small explicit weighted graph if it fails.\n\n## C2. Max-flow / min-cut tightness (area-law saturation)\n\nWe proved the one-sided bound `entanglementCapacity \u2264 logCut S` for every cut.\n\n> **Conjecture C2.** For every symmetric tensor network there is an explicit\n> \"flow\" certificate whose value equals `entanglementCapacity`, so the min-cut\n> bound is *tight*: `entanglementCapacity = max over admissible flows`.\n\nThis is a weighted directed max-flow=min-cut theorem specialized to the IIT cut\nfunctional. Test: formalize an admissible-flow structure and prove weak duality\n(`flow \u2264 phi`) then strong duality on `Fin n`.\n\n## C3. Coarse-graining monotonicity (RG step)\n\n> **Conjecture C3.** Contracting an internal edge (merging two nodes `i,j` and\n> summing their weights) does not increase \u03a6: `\u03a6(C / {i\u223cj}) \u2264 \u03a6(C)`.\n\nIf true, \u03a6 is an RG-monotone \u2014 a \"c-theorem\" for integrated information. Test:\ndefine node-merge on `CausalSystem`, relate its bipartitions to the original's,\nand bound the cut functional. Falsifiable: search small systems for a merge that\nraises \u03a6.\n\n## C4. Spectral lower bound (Fiedler/Cheeger for \u03a6)\n\n> **Conjecture C4.** For the symmetrized system `symmetrize C` there is a\n> Cheeger-type bound `\u03a6 \u2265 c \u00b7 \u03bb\u2082(L_C) \u00b7 (min part size)` where `\u03bb\u2082` is the\n> algebraic connectivity of the weighted graph Laplacian `L_C`.\n\nThis would connect IIT directly to spectral graph theory and give a *computable*\ncertificate of high integration from an eigenvalue. Test: prove the easy\ndirection (\u03a6 controls a conductance) first, then the spectral inequality.\n\n## C5. Exact superadditivity gap\n\nCycle 2 proved `\u03a6(C\u2081 \u2295 C\u2082) \u2265 \u03a6(C\u2081) + \u03a6(C\u2082)` and showed equality fails in\ngeneral.\n\n> **Conjecture C5.** Equality `\u03a6(C\u2081 \u2295 C\u2082) = \u03a6(C\u2081) + \u03a6(C\u2082)` holds **iff** `C\u2081`\n> and `C\u2082` admit a common minimizing bipartition.\n\nTest: the `\u2190` direction is immediate from `crossInfo_add`; the `\u2192` direction\nneeds that the superposed minimizer simultaneously minimizes both summands.\nFalsifiable by exhibiting a common-minimizer pair with strict inequality.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2016",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "ecc79db8",
    "status": "available",
    "timestamp": "2026-06-16T15:41:35.937351+00:00",
    "title": "Dictionary"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Tropical Fermat's Last Theorem\n\nThis research cycle established the core dichotomy: the classical Fermat equation\n`a\u207f + b\u207f = c\u207f` has no nontrivial solutions for `n \u2265 3`, while its tropical analogue\n`max(n\u2022a, n\u2022b) = n\u2022c` is **always** uniquely solvable (by `c = max a b`). The engine is the\nmonotonicity of `x \u21a6 n\u2022x`, which makes it commute with `max`/`min`. We formalized the\nmax-plus and min-plus identities, existence, uniqueness, classification, a multivariable\n(`Finset.sup'`) generalization, the tropical Fermat curve, and a faithful embedding into\nMathlib's genuine `Tropical \u211d` semiring (all in `Core.lean`, 0 sorries).\n\nBelow are bold, precise, testable conjectures for follow-up cycles.\n\n## C1. Tropical Fermat over arbitrary scalar exponents (semimodules)\n**Conjecture.** Replace the natural-number exponent `n` by a scalar `r` from an ordered\nsemiring acting on an ordered module `M`. Then for `r > 0`, `max (r \u2022 a) (r \u2022 b) = r \u2022 max a b`\nholds and the solution `c = max a b` is unique; for `r = 0` it degenerates (every `c` works);\nfor `r < 0` (when defined) the identity flips to `min`. \n*Test:* formalize `r : \u211d\u22650` acting on `\u211d` via `smul`, prove the trichotomy, and identify the\nexact `OrderedSMul`/`PosSMulStrictMono` hypotheses that make uniqueness hold.\n\n## C2. Tropical Fermat hypersurfaces are always nonempty and balanced\n**Conjecture.** For every `n \u2265 1` and every number of variables `k \u2265 2`, the tropical\nFermat hypersurface `corner-locus of  max_i (n\u2022x\u1d62) \u2295 0` is a nonempty, pure-dimensional,\nbalanced polyhedral complex whose vertex is the origin, with exactly `k+1` top-dimensional\nrays/cells through it. We proved the `k = 2` skeleton (symmetry, origin vertex, diagonal\nray). *Test:* generalize `OnFermatCurve` to `k` variables via `Finset`, prove nonemptiness\nand the \"attained at least twice somewhere\" balancing condition for all `k`.\n\n## C3. Stable-range / quantitative gap version\n**Conjecture.** Define an `\u03b5`-approximate tropical Fermat solution by\n`|max (n\u2022a) (n\u2022b) \u2212 n\u2022c| \u2264 \u03b5`. Then `c` is forced into the interval\n`[max a b \u2212 \u03b5/n, max a b + \u03b5/n]`; in particular as `n \u2192 \u221e` the approximate solution set\ncollapses to the exact one at rate `\u0398(1/n)`. *Test:* prove the two-sided bound and the\ncollapse rate; connect to the `TropicalEquivalenceInvariance` gap-stability results already\nin the catalog.\n\n## C4. Bridge: classical FLT \u21d2 tropical degeneration is \"lossy\"\n**Conjecture (cross-domain bridge).** The non-Archimedean valuation/tropicalization map\n`val : \u211d\u208a \u2192 \u211d`, `val(t) = log t`, sends classical near-solutions of `a\u207f + b\u207f = c\u207f` to exact\ntropical solutions, and the *failure* of classical FLT is exactly the statement that the\nfiber of `val` over a tropical solution `(a,b,max a b)` contains no genuine classical triple\nfor `n \u2265 3`. *Test:* formalize the valuation-degeneration square commuting up to the\n\"dequantization\" `max(x,y) = lim_{T\u21920} T\u00b7log(e^{x/T}+e^{y/T})`, proving the log-sum-exp\nlimit (`Real.logSumExp`-style) converges to `max`, giving a rigorous classical\u2192tropical\nlimit theorem.\n\n## C5. Tropical Catalan / Beal analogue\n**Conjecture.** The tropical Beal equation `max (m\u2022a) (n\u2022b) = k\u2022c` with mixed exponents is\nsolvable for **all** `m,n,k \u2265 1` (unlike the classical Beal conjecture), and admits a clean\nparametric description of its full solution set: `c` is determined as a max of the two\n\"rescaled\" terms `(m/k)\u2022a` and `(n/k)\u2022b`. *Test:* state and prove over `\u211d`, classify the\nsolution variety, and contrast with the still-open classical Beal conjecture.\n",
    "domains": [
      "Tropical",
      "Pythagorean"
    ],
    "id": "fd_2017",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "1ad32e9c",
    "status": "available",
    "timestamp": "2026-06-16T15:42:03.443410+00:00",
    "title": "Core dichotomy: the classical Fermat equatio"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Diophantine Approximation on ReLU / Tropical Networks\n\nDerived from this cycle's findings in\n`Tropical/NeuralNetworks/DiophantineReLUPi.lean` and\n`Tropical/NeuralNetworks/ReLURepresentableConstants.lean`.\n\nThis cycle established a sharp Diophantine dichotomy: a ReLU network (= tropical\nrational function, via `MachineLearning.TropicalReLUBridge`) with **rational\nparameters** at a **rational input** outputs exactly the rational numbers, and\nnothing else; every irrational/transcendental constant (\u03c0, \u221a2, \u2026) is only ever a\n*limit* of network values, never a value. The explicit Leibniz network reaches \u03c0\nat rate `\u0398(1/n)` in width.\n\nThe following conjectures are bold, falsifiable refinements.\n\n## 1. The Leibniz rate `\u0398(1/n)` is essentially optimal for *bias-only / width-linear* ReLU encodings of \u03c0.\n**Statement.** For the family of width-`n` ReLU networks whose hidden units have\nzero input weight (constant networks), the best achievable error\n`inf |f(1) - \u03c0|` over rational parameters with total bit-complexity `B` is\n`\u0398(1/2^B)` but `\u03a9(1/poly(n))` when restricted to \"small-integer\" weights of size\n`O(n)`; i.e. the linear-in-width Leibniz construction cannot be polynomially\nbeaten without large weights.\n**The key insight is** that constant ReLU networks with bounded-height rational\nweights can only land on rationals with bounded denominator, and the irrationality\nmeasure of \u03c0 lower-bounds how close such rationals get.\n**Why now?** We already have `reLURepresentable_iff_rational` pinning the exact\nimage to \u211a; quantifying the *denominator* of the reachable rationals as a function\nof network size is the natural next theorem, and Mathlib now has enough\ncontinued-fraction / irrationality-measure API to attempt it.\n\n## 2. Depth buys a doubly-exponential speedup: \u03c0 to accuracy \u03b5 with depth `O(log log(1/\u03b5))`.\n**Statement.** There is a family of ReLU networks of depth `L` and width `w` with\n`L = O(log log(1/\u03b5))`, `w = O(log(1/\u03b5))` and `|f(1) - \u03c0| < \u03b5`, obtained by\nimplementing a quadratically-convergent (e.g. Gauss\u2013Legendre / AGM) iteration\nrather than the linear Leibniz sum.\n**The key insight is** that ReLU layers can implement one Newton/AGM step (a few\nmultiplications and a square root, themselves approximable by piecewise-linear\nunits) per `O(1)` layers, so doubling of correct digits per constant depth gives\nthe `log log` depth bound.\n**Why now?** This cycle proved the *linear* (`\u0398(1/n)`-width) construction\nrigorously; the AGM upgrade is the precise mechanism behind the concept's\n\"`O(log log(1/\u03b5))` depth\" claim and is the next milestone, requiring only a\nformal piecewise-linear square-root gadget.\n\n## 3. The \"tropical degree\" (number of linear pieces) of the best \u03b5-approximant of \u03c0 grows like `\u0398(1/\u03b5)`.\n**Statement.** Any convex piecewise-linear (tropical-polynomial) `f` with\n`|f - \u03c0|_{\u221e} < \u03b5` on `[0,1]` (a fixed nonconstant target slope normalisation) needs\n`\u03a9(1/\u221a\u03b5)` pieces, while ReLU *rational* functions need only `O(log(1/\u03b5))`; the gap\nquantifies the value of subtraction (tropical division) in approximation.\n**The key insight is** that the catalog's `IsTropPoly.convexOn` forces convex\napproximants to pay a curvature tax, whereas tropical *rational* functions\n(differences) escape it.\n**Why now?** The convexity lemma `IsTropPoly.convexOn` is already in the catalog;\ncombining it with a curvature/second-difference counting argument is a direct,\nself-contained follow-up.\n\n## 4. Representability is exactly \u211a for *every* fixed input, not just rational inputs of bounded dimension.\n**Statement.** Strengthen `reLURepresentable_iff_rational`: for an *algebraic*\ninput `x` of degree `d`, the set of exactly-representable outputs of rational ReLU\nnetworks is exactly `\u211a(x)` (the field generated by `x`), and is dense but proper in\n\u211d whenever `x` is irrational.\n**The key insight is** that ReLU arithmetic at a point is a finite tower of\n`{+, \u00b7, max}` operations, which stay inside the field generated by the input, and\n`max` does not leave the field because it only selects an argument.\n**Why now?** Our `reluValQ` shadow already proves closure under field operations\nfor rational inputs; generalising the shadow to `\u211a(x)` is a clean algebraic\nextension of the same proof.\n\n## 5. A tropical \"irrationality detector\": \u03c0 lies on infinitely many tropical hypersurfaces of network differences.\n**Statement.** For the decision-boundary locus of the catalog bridge, the point\nwhere two Leibniz networks of widths `n` and `n+1` agree converges to (but never\nequals) the fibre over \u03c0; the spacing of these tropical hypersurfaces decays like\n`\u0398(1/n^2)`.\n**The key insight is** that consecutive Leibniz partial sums sandwich \u03c0/4\n(alternating series), so their difference network's zero set brackets \u03c0 with\ngeometrically-controlled gaps \u2014 turning `decisionBoundary_on_tropHypersurface`\ninto a quantitative Diophantine bracketing tool.\n**Why now?** The sandwich (`leibniz_partialSum_error`) is now formalised, and the\ncatalog already exposes `decisionBoundary_on_tropHypersurface`; linking them gives\na novel tropical-geometric reading of alternating-series convergence.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2018",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "0d42792c",
    "status": "available",
    "timestamp": "2026-06-16T16:18:08.859088+00:00",
    "title": "Derived from this cycle's findings in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Isogeny-Based Cryptography (CSI-FiSh / CSIDH)\n\nConjectures below are stated to be *formalizable and testable* in Lean 4, building\ndirectly on `Catalog/Cryptography/CSIFiShClassGroup.lean` (torsor model of the\nclass-group action) and `Catalog/Cryptography/CSIFiShAdvanced.lean`.\n\n## C1 \u2014 Exact Cayley diameter (RESOLVED this cycle; next: general generating sets)\n`zmod_cayley_diameter_exact` now proves the diameter of `ZMod n` with `{\u00b11}` is\n*exactly* `\u230an/2\u230b` (`IsLeast`). **Next conjecture**: for the generating set\n`{\u00b11, \u00b1g}` with `g` a unit of order `m`, the diameter is\n`\u0398(n / m + m)`, minimized near `g \u2248 \u221an` giving diameter `\u0398(\u221an)` \u2014 the\nquantitative bridge to the `\u221a`-step structure exploited by Kuperberg-style\nattacks. Test: BFS over `n \u2208 {16,25,36,49}`, `g = round(\u221an)`.\n\n## C2 \u2014 Self-reducibility \u21d2 uniform extractor advantage\nStrengthen `gaip_self_reducible`: an oracle solving GAIP on a *positive fraction*\n`\u03b5` of instances `(g +\u1d65 x\u2080, \u00b7)` can be amplified, via random shifts, to solve a\n*fixed worst-case* instance with success probability `\u2265 \u03b5`. Conjecture: in the\nfinite torsor model the success set under random shift `g` has measure exactly\n`\u03b5` (shift-invariance of `connector`), giving a clean worst-case \u2194 average-case\nequivalence `gaip_worst_avg`.\n\n## C3 \u2014 k-special soundness \u21d2 negligible cheating mass\nGeneralize `multi_round_extract`: for `t` parallel rounds with binary challenges,\na prover lacking the secret can satisfy at most one challenge per round, so the\nset of acceptable transcripts has relative size `\u2264 2^{-t}` of all `2^t` challenge\nstrings. Conjecture and formalize `csifish_soundness_error t = 2^(-t)` as a\ncounting statement over `Fin t \u2192 Bool`.\n\n## C4 \u2014 Torsor = unique simply-transitive model (rigidity)\nConjecture: any two free transitive `G`-actions on a finite `X` are isomorphic as\n`G`-sets, and the isomorphism is unique up to the choice of base point. I.e. the\ncatalog's abstract `FreeTrans G X` is **categorically equivalent** to the\n`AddTorsor` instance. Formalize `FreeTrans.equivTorsor` and prove the\nkey-space/curve-space `card` equality (`card_key_eq_card_curve`) is forced.\n\n## C5 \u2014 Commutativity is necessary for non-interactive key agreement\nConjecture: `csidh_correct` (order independence of two parties) holds for a free\ntransitive action **iff** the acting group is abelian. Test the forward direction\nis `add_comm`; conjecture the converse: if `a +\u1d65 (b +\u1d65 x\u2080) = b +\u1d65 (a +\u1d65 x\u2080)` for\nall `a b` and one base point `x\u2080` in a free transitive action, then `G` is\ncommutative. Formalize as `csidh_correct_iff_abelian`.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2021",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d79ba9e2",
    "status": "available",
    "timestamp": "2026-06-16T16:55:15.301139+00:00",
    "title": "Conjectures below are stated to be *formalizable and testable* in Lean 4, buildi"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 Category Theory as the DNA of Mathematics (Tropical cycle)\n\nDerived from the verified results in\n`Catalog/Tropical/ModelCategoryGenome.lean` and\n`Catalog/Tropical/TropicalResiduationMutation.lean`.\n\nIn this cycle we proved (0 sorries):\n- *Genome equivalence* (`MoritaEquiv` = equivalence of model categories) is an equivalence\n  relation; *mutation* (`IsMutation` = an adjunction of model categories) is a preorder;\n  every genome equivalence is a mutation (`morita_to_mutation`); existence of terminal/initial\n  models is a genome invariant.\n- The tropical (min-plus) semiring supplies the two archetypal mutations: the *reversible*\n  residuation `(a + \u00b7) \u22a3 (\u00b7 - a)` and the *irreversible* clamp `Iic c \u21aa \u211d \u22a3 (min \u00b7 c)`,\n  certifying that `morita_to_mutation` is a **strict** inclusion.\n\nThe following conjectures are the natural, falsifiable next steps.\n\n---\n\n## Conjecture 1 \u2014 Evolutionary paths need quotients, not just adjunctions\n**Statement.** There exist genomes `C`, `D` connected by a \"reachability\" relation\n(zig-zag of axiom changes) for which **no** single adjunction `C \u2192 D` exists, but a finite\ncomposite of adjunctions *and* reflective localizations (categorical quotients) does.\nFormally: the preorder generated by `IsMutation` is strictly coarser than the one generated by\n`IsMutation` together with `CategoryTheory.Localization`.\n\n**The key insight is** that `mutation_trans` already proves adjunctions compose, so the *only*\nway the program's full \"adjunctions **and** quotients\" conjecture can be non-trivial is if\nquotients are not themselves adjunctions on the nose \u2014 reflective localizations are adjunctions\nbut Gabriel\u2013Zisman localizations in general are not.\n\n**Why now?** We have an isolated, fully-proved `IsMutation` preorder; adding\n`CategoryTheory.Localization` (already in Mathlib) lets us test the strictness directly,\nwithout rebuilding any foundations.\n\n---\n\n## Conjecture 2 \u2014 Reversible mutation \u27fa group-like algebra, irreversible \u27fa idempotent\n**Statement.** A tropical-style mutation `(a \u22c6 \u00b7) \u22a3 residual` on an ordered algebraic\nstructure is reversible (a genome equivalence) **iff** the operation `\u22c6` is cancellative\n(group-like); it is strictly irreversible **iff** `\u22c6` is idempotent/absorbing.\n\n**The key insight is** that `tropRes_reversible` succeeded for `+` precisely because `\u211d` is a\ngroup under `+`, while `tropClamp_irreversible` failed to be reversible precisely because `min`\nis idempotent \u2014 the reversibility of a mutation is a *shadow of the invertibility of the\nunderlying operation*.\n\n**Why now?** Both halves are already witnessed concretely in this cycle (`+` vs `min`); the\nconjecture asks only to abstract the two proofs to an ordered-monoid hypothesis, which Mathlib's\n`OrderedAddCommGroup` / `CanonicallyOrderedAddCommMonoid` hierarchy supports today.\n\n---\n\n## Conjecture 3 \u2014 Genome invariants are exactly the limit/colimit-definable properties\n**Statement.** A property `P` of theories is a genome invariant (preserved by every\n`MoritaEquiv`) **iff** `P` is expressible purely in terms of existence of (co)limits of some\nfixed shape. Terminal- and initial-model existence (`morita_preserves_terminal/initial`) are the\nshape-`\u2205` cases.\n\n**The key insight is** that equivalences of categories preserve all limits and colimits, so\n*every* (co)limit-definable property is automatically invariant; the open and surprising half is\nthe converse \u2014 that nothing else is invariant.\n\n**Why now?** We have the base cases proved via `IsTerminal.isTerminalObj` /\n`IsInitial.isInitialObj`; Mathlib's `Equivalence` API (`preservesLimits`,\n`preservesColimits`) gives the forward direction for arbitrary shapes immediately, so the\nresearch effort can focus entirely on the converse.\n\n---\n\n## Conjecture 4 \u2014 The \"genome distance\" between theories is a metric induced by adjunction length\n**Statement.** Define `d(C, D)` as the minimal length of an evolutionary path (composite of\nmutations/quotients) from `C` to `D`, and `\u221e` if none exists. Then `d` is an extended\npseudometric on genomes, and `d(C, D) = 0` \u27fa `MoritaEquiv C D`.\n\n**The key insight is** that `mutation_refl` gives the zero-length self-path and `mutation_trans`\ngives the triangle inequality directly \u2014 the categorical algebra we proved is *already* the\naxioms of a pseudometric in disguise.\n\n**Why now?** The preorder structure (`mutation_refl`, `mutation_trans`) is in hand; turning a\npreorder with composition-length into an `EDist`/`PseudoEMetricSpace` is a packaging exercise\non top of this cycle's theorems.\n\n---\n\n## Conjecture 5 \u2014 Every finite tropical mutation factors as (reversible shift) \u2218 (clamp)\n**Statement.** Any monotone Galois connection on `(\u211d, \u2264)` arising from min-plus data factors,\nup to order isomorphism, as a residuation shift followed by a clamp onto a sub-interval \u2014 i.e.\nthe two archetypes of this cycle generate *all* tropical mutations.\n\n**The key insight is** that residuation contributes the invertible (translation) part and\nclamping contributes the information-collapsing (closure) part, and a Galois connection on a\nlinear order is determined by its image plus a translation.\n\n**Why now?** We have proved both generators exist and are non-isomorphic in behaviour\n(`tropResMutation` vs `tropClampMutation`); the factorisation conjecture is the precise sense in\nwhich they are a *generating set* for the tropical mutation monoid, and it is checkable on the\nconcrete order `(\u211d, \u2264)` we already use.\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_2022",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "24a3af22",
    "status": "available",
    "timestamp": "2026-06-16T17:28:59.501421+00:00",
    "title": "Derived from the verified results in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Mathematics as an Evolving Ecosystem\n\nDerived from the Phase A cycle that produced `Fitness.lean`,\n`CompetitiveExclusion.lean`, and `Evolution.lean`.  Each direction is a bold,\nfalsifiable conjecture about the fitness model\n`f(T) = connections(T) \u00b7 proofDensity(T) / axiomCount(T)`.\n\n---\n\n## 1. Selection pressure toward *primitive* (irreducible) theories\n\n**Conjecture.** Under any fitness-improving evolution, the long-run population is\ndominated by theories that are not Rankin\u2013Selberg-type products of smaller\ntheories; composite theories are an evolutionary dead end.\n\nThe key insight is that `selberg_product_fitness_subadditive` shows the conductor\n(axiomatic cost) *multiplies* under composition while the degree (connection\ncount) only *adds*, so `f(S\u2081 \u00d7 S\u2082) \u2264 f(S\u2081) + f(S\u2082)` with strict loss whenever both\nfactors are non-trivial \u2014 composition can never create fitness, only dilute it.\n\nWhy now? We already have the Selberg census `product` operation formalized and the\nsubadditivity inequality proved, so the next step (defining a primitivity\npredicate and proving products are strictly sub-apex) is directly within reach\nrather than speculative.\n\n---\n\n## 2. A carrying capacity for foundational theories\n\n**Conjecture.** For any finite niche space `N`, every ecosystem at equilibrium has\nat most `card N` theories, and this bound is *tight*: there exist equilibria\nrealizing exactly `card N` distinct foundational theories.\n\nThe key insight is that `niche_packing` already proves the upper bound\n`card E \u2264 card N` from injectivity alone; tightness would follow from exhibiting a\nsection of the niche map, turning the inequality into an exact carrying-capacity\nlaw for mathematics' foundational layer.\n\nWhy now? The pigeonhole half is done and axiom-checked; only the constructive\n(surjective-section) half remains, which is a finite combinatorial construction.\n\n---\n\n## 3. A phase transition in the value of new axioms\n\n**Conjecture.** Along a family of extensions `T \u2286 T\u208a` that add `a` axioms and gain\n`c` connections at proof density `d`, fitness increases **iff**\n`c\u00b7d\u00b7axioms(T) > connections(T)\u00b7proofDensity(T)\u00b7(axioms(T)+a)` \u2014 there is a sharp\nthreshold separating \"fertile\" axioms (large cardinals) from \"sterile\" ones.\n\nThe key insight is that `fitness_lt_iff_cross` is an *exact* characterization\n(an iff, not a one-sided bound), so the boundary case is a genuine equality\nhyperplane, and `zfc_lc_strictly_fitter` is one verified point strictly on the\nfertile side.\n\nWhy now? The cross-multiplication criterion is proven and reusable, so quantifying\nthe threshold for concrete extension families (ZFC + CH, ZFC + PD, ZFC + I0) is a\nmatter of plugging in trait estimates rather than new theory.\n\n---\n\n## 4. Open-endedness: no bounded \"final theory\"\n\n**Conjecture.** There is no theory of maximal fitness; equivalently, every\nfitness-improving lineage is cofinal in fitness, so mathematics has no\nfitness-saturating \"theory of everything\".\n\nThe key insight is that `evolution_escapes_finite` proves a fitness-improving\ntrajectory cannot be confined to any finite ecosystem, because the trajectory is\ninjective (`evolution_injective`) and \u2115 does not inject into a finite set \u2014\nunbounded ascent is forced, not assumed.\n\nWhy now? The injectivity and finite-escape theorems are already axiom-clean;\nupgrading \"escapes every finite set\" to \"fitness \u2192 \u221e\" only needs an\nArchimedean/cofinality argument over \u211a, which Mathlib supports directly.\n\n---\n\n## 5. Foundational monism under niche injectivity\n\n**Conjecture.** If the foundational ecosystem ever reaches a state where all\nfitnesses are distinct, then it has a unique apex theory, and that apex is a global\nattractor of fitness-improving dynamics.\n\nThe key insight is that `fitness_max_unique` already gives uniqueness of the\nfitness-maximizer under `Set.InjOn fitness`; combining it with the monotone,\nacyclic trajectory of `evolution_strictMono` suggests the apex is not merely unique\nbut dynamically selected.\n\nWhy now? Both ingredients \u2014 apex uniqueness and strictly monotone evolution \u2014 are\nproved in this cycle, so the attractor claim is the natural synthesis to test\nnext, e.g. by formalizing convergence of trajectories that stay within a finite\nequilibrium.\n",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_2023",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "eef6f30f",
    "status": "available",
    "timestamp": "2026-06-16T18:05:28.852660+00:00",
    "title": "Derived from the Phase A cycle that produced `Fitness.lean`,"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 EML Special Functions (Gamma, Zeta, Hypergeometric)\n\nDerived from the verified results in `GammaEML.lean`, `ZetaEML.lean`, and\n`HypergeometricEML.lean`. Each conjecture is falsifiable in Lean against the\nexisting Mathlib special-function API.\n\n## 1. Singular-set cardinality is the EML/non-EML separator\n\n**Conjecture.** For the classical meromorphic special functions, \"EML-likeness\"\nis governed not by *whether* singularities exist but by the *cardinality and\narithmetic regularity* of the singular set: `\u0393` (singular set `{-n : n \u2208 \u2115}`,\ninfinite but arithmetic-progression-regular) and `\u03b6` (singular set `{1}`,\nfinite) are both meromorphic, but no entire reciprocal exists for `\u03b6` of the\n`\u0393`-type \"all-pole\" form.\n\n*The key insight is...* that `gamma_recip_entire` together with\n`zeta_singular_set_eq_singleton` shows the discriminating invariant is the zero\nlocus of the reciprocal germ, not the presence/absence of singularities \u2014 the\nmission's \"essential singularity\" framing for `\u03b6` is simply false.\n\n*Why now?* Mathlib now has `Meromorphic.Gamma`, `differentiable_one_div_Gamma`,\nand `differentiableAt_riemannZeta`, so the comparison is fully formalizable\nwithout re-deriving analytic continuation.\n\n## 2. Termination \u21d2 entirety, formalized as a decision procedure\n\n**Conjecture.** `\u2082F\u2081(a,b;c;z)` is entire (as a function of `z`) **iff** at least\none of `a,b` is a non-positive integer (the series terminates). The forward\ndirection is `hgCoeff_terminates`; the converse (non-termination forces a\ngenuine `z=1` singularity) is the open half.\n\n*The key insight is...* that `ascPochhammer_eval_neg_nat_eq_zero` makes\ntermination a purely algebraic, decidable condition on the numerator\nPochhammer, decoupled from convergence analysis.\n\n*Why now?* The Pochhammer-based coefficient definition (`hgCoeff`) reduces an\nanalytic dichotomy to a finite vanishing test that Lean's `ring`/`omega`\nmachinery can certify.\n\n## 3. The coefficient recurrence characterizes the Gauss operator's kernel\n\n**Conjecture.** A formal power series `\u2211 a\u2099 z\u207f` is annihilated by the Gauss\noperator `z(1-z)D\u00b2 + (c-(a+b+1)z)D - ab` **iff** its coefficients satisfy the\nrecurrence proved in `hgCoeff_recurrence`; hence the kernel of the Gauss\noperator inside `\u2102[[z]]` is at most 1-dimensional once `a\u2080` is fixed and\n`c \u2209 \u2124_{\u22640}`.\n\n*The key insight is...* that `hgCoeff_recurrence` is not merely *a* solution but\nthe *defining* two-term-to-one-term contraction, so uniqueness of the\nholomorphic solution is a corollary of recurrence uniqueness.\n\n*Why now?* With the recurrence verified denominator-free (`field_simp`+`ring`),\nthe uniqueness statement is a clean induction that needs no new analytic input.\n\n## 4. EML-chain realizability of contiguous closed forms\n\n**Conjecture.** Every Gauss-contiguous closed form of `\u2082F\u2081` that reduces to a\npower `(1-z)^{-a}`, a logarithm, or a product thereof is realizable as a finite\nEML chain (`Catalog/EML/KolmogorovArnoldEMLDeep.lean`), and the minimal chain\ndepth equals the number of independent transcendental factors.\n\n*The key insight is...* `hypergeometric_powerChain_repr` shows the prototypical\nclosed form `(1-z)^{-a}` is *exactly* the depth-2 power chain; depth should then\nbe an additive invariant over contiguous products.\n\n*Why now?* The catalog already proves `power_chain_eval`/`power_chain_depth`, so\ndepth lower bounds reduce to counting `exp`/`log` occurrences \u2014 a combinatorial,\nformalizable quantity.\n\n## 5. A reciprocal-entirety test for \"no algebraic singularities\"\n\n**Conjecture.** A meromorphic `f : \u2102 \u2192 \u2102` \"has no algebraic singularities\" in\nthe EML sense iff `1/f` extends to an entire function whose zero set is exactly\nthe pole set of `f` (as for `\u0393` via `gamma_recip_vanishes_at_poles`). This fails\nfor `\u03b6` (its reciprocal is *not* entire near `1` in the all-pole sense), giving a\nsharp algebraic separator.\n\n*The key insight is...* entirety of the reciprocal is a single global\n`Differentiable` statement, far more tractable in Lean than local branch-cut\nnon-existence, yet logically equivalent for meromorphic germs.\n\n*Why now?* `differentiable_one_div_Gamma` is the only nontrivial ingredient and\nis already in Mathlib; the conjecture turns a vague analytic slogan into a\ncheckable `Differentiable \u2102 (f\u207b\u00b9)` proposition.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2024",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "c2c261ee",
    "status": "available",
    "timestamp": "2026-06-16T19:50:26.835955+00:00",
    "title": "Derived from the verified results in `GammaEML.lean`, `ZetaEML.lean`, and"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 EML Single-Operator Church\u2013Turing Thesis\n\nThis cycle established, with fully verified Lean 4 proofs (0 sorries, standard\naxioms only), the **affirmative content** of the single-operator thesis:\n\n* `EML/SingleOperatorRepresentability.lean` \u2014 grammars + semantics for the\n  two-operator language `EMLExpr` (`exp`, `log`) and the single-operator language\n  `EMLOnlyExpr` (sole primitive `eml(x,y) = exp(x) \u2212 log(y)`).\n* `EML/SingleOperatorCompilation.lean` \u2014 bidirectional, semantics-preserving\n  compilation and the equivalence `EMLOnlyRepresentable f \u2194 EMLRepresentable f`,\n  with linear size bounds (forward `\u2264 5\u00b7size`).\n* `EML/SingleOperatorChurchTuring.lean` \u2014 function-algebra closure of the class\n  (`+, \u00d7, neg, \u2212, inv, exp, log, eml`), reverse size bound (`\u2264 4\u00b7size`), concrete\n  `sinh`/`cosh`/`pow`, and the omnibus `single_operator_church_turing`.\n* `EML/SingleOperatorActivations.lean` \u2014 finite sum/product closure, polynomial\n  completeness (`EMLOnlyRepresentable_mvPolynomial`), and representability of the\n  standard activations (sigmoid, softplus, tanh, SiLU).\n\nThe following conjectures are concrete, falsifiable targets for the next cycles.\n\n---\n\n## C1. Necessity / minimality of the single operator\n\nThe field-operations-only fragment (no `eml`) represents **exactly** the\nrational functions, and `exp` is not among them \u2014 so the transcendental primitive\nis genuinely necessary, not eliminable.\n\n> **Conjecture.** Define `FieldOnlyRepresentable` as the closure of constants and\n> projections under `+, \u00d7, neg, inv`. Then\n> `FieldOnlyRepresentable f \u2194 \u2203 p q : MvPolynomial (Fin n) \u211d, f = (eval \u00b7 p)/(eval \u00b7 q)`\n> (as total functions with junk-value `inv 0 = 0`), and\n> `\u00ac FieldOnlyRepresentable (fun x : Fin 1 \u2192 \u211d => Real.exp (x 0))`.\n\n*Attack.* The negative half follows from `exp` growing faster than any rational\nfunction (`Real.tendsto_exp_div_pow_atTop` / transcendence of `exp` over `\u211d(x)`).\n\n## C2. Tightness of the size bounds\n\nThe compilation overhead constants `5` (forward) and `4` (reverse) are optimal.\n\n> **Conjecture.** There is a family `e\u2096 : EMLExpr` of `log`-only expressions with\n> `(compileToEMLOnly e\u2096).size = 5\u00b7e\u2096.size \u2212 o(size)`, and dually a family of\n> `eml`-only expressions saturating `compileFromEMLOnly_size_bound`. Equivalently,\n> no compiler achieves constant `< 5` (resp. `< 4`) for all inputs.\n\n## C3. Domain-faithful (partial) single-operator thesis\n\nOur semantics is *total* (junk values `log x = 0` for `x \u2264 0`, `inv 0 = 0`). The\nsharper statement uses the **partial** `Option \u211d` semantics (cf. the source\ngrammar `UExpr`/`EMLExpr` with `eeval` in the archived `EML/Defs.lean`).\n\n> **Conjecture.** There is a compilation `UExpr \u2192 EMLExpr` (single primitive,\n> partial semantics) that is *domain-faithful*: `t.eeval x = e.eval x` for all\n> `x` **including the `none` (undefined) cases**, with the `eml` node guarded by\n> its positivity side-condition. The size blow-up remains linear.\n\n## C4. Stone\u2013Weierstrass universality of the single-operator class\n\nCombine `EML/StoneWeierstrassApprox.lean` with single-operator representability:\nthe single primitive is not just exactly-elementary but **approximation-universal**.\n\n> **Conjecture.** For every compact `K \u2286 \u211d\u207f` the single-operator representable\n> functions are dense in `C(K, \u211d)` (uniform norm). Concretely, the subalgebra\n> generated by `{x \u21a6 eml(\u27e8a,x\u27e9, 1) = exp(\u27e8a,x\u27e9) : a \u2208 \u211d\u207f}` separates points and\n> contains constants, hence is dense by `eml_topologicalClosure_eq_top_of_separatesPoints`.\n\n## C5. Differential-field closure of the single-operator class\n\nThe smooth single-operator functions form a differential field: closed under\n`d/dx`, with the derivative again single-operator representable.\n\n> **Conjecture.** If `f : \u211d \u2192 \u211d` is single-operator representable by an expression\n> whose evaluation is differentiable on an open `U`, then `deriv f` is\n> single-operator representable on `U`. The derivative of an `eml` node is\n> `exp(a)\u00b7a' \u2212 b'/b` (see `hasDerivAt_eml_composition`), which is itself an `eml`-\n> algebra term, so closure should follow by structural induction on the syntax.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2025",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "fbd73212",
    "status": "available",
    "timestamp": "2026-06-16T19:51:02.545064+00:00",
    "title": "This cycle established, with fully verified Lean 4 proofs (0 sorries, standard"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Automatic Sequences and the Zero-in-Sequence Problem\n\nThis cycle formalized the automata-theoretic core of the \"halting problem for\nautomatic sequences\": the zero-in-sequence problem reduces to DFA language\nemptiness, which a pumping/pigeonhole argument collapses to a *finite* search\n(`accepts_nonempty_iff_short`, `zero_value_iff_short`), with the companion\ninfinitude dichotomy (`accepts_infinite_of_long`, `zero_value_infinite`).  We\nalso pinned the boundary with `P`-recursive sequences: automatic sequences are\nfinite-valued (`autoSeq_range_finite`), so `a_n = n` is *not* automatic\n(`id_not_automatic`), and unary automatic sequences are eventually periodic\n(`unary_autoSeq_eventually_periodic`, built on the catalog's\n`pow_eventually_periodic`).\n\nThe conjectures below are derived directly from those findings.\n\n## C1. Sharp pumping threshold for the zero set is exactly the state count\n**Conjecture.** For a DFAO with `s` states and output map `out`, the set\n`{w | out (M.eval w) = z}` is infinite **iff** it contains a word of length in the\nwindow `[s, 2s)`; equivalently, finiteness is decided by inspecting words of\nlength `< s` only, and infinitude by exhibiting one in `[s, 2s)`.\n\n**The key insight is** that `DFA.pumping_lemma` already localizes the loop `b`\ninside the first `s` letters (`a.length + b.length \u2264 s`), so the entire\nfinite/infinite dichotomy is witnessed within a bounded length window rather than\nunboundedly far out.\n\n**Why now?** We have machine-checked both halves of the dichotomy\n(`accepts_finite_iff` and `accepts_infinite_of_long`); tightening the witness\nlength from \"\u2265 s\" to the explicit window `[s, 2s)` is a finite combinatorial\nrefinement that our existing pumping infrastructure should discharge.\n\n## C2. Eventual periodicity generalizes from unary to ultimately-constant inputs\n**Conjecture.** If the representation stream `repr n` is eventually constant in\nits tail letter (reads a fixed letter `a` after a bounded prefix), then\n`n \u21a6 out (M.eval (repr n))` is eventually periodic, with period dividing the\norder of `s \u21a6 M.step s a` in `Function.End \u03c3`.\n\n**The key insight is** that `unary_autoSeq_eventually_periodic` already shows the\ntail dynamics are governed by a single endofunction's orbit; a bounded prefix only\nshifts the starting state, leaving the eventual period intact.\n\n**Why now?** `End_pow_apply` + `evalFrom_replicate` give an exact bridge between\nlist evaluation and monoid powers, so the prefix-shift argument is within reach of\nthe same `pow_eventually_periodic` engine we already invoked.\n\n## C3. Finite-valuedness is the decisive separator: automatic \u228a P-recursive\n**Conjecture.** Every `k`-automatic integer sequence is `P`-recursive, but the\nconverse fails on exactly the unbounded `P`-recursive sequences; a `P`-recursive\nsequence is automatic only if it takes finitely many values.\n\n**The key insight is** that `autoSeq_range_finite` makes finite range a *necessary*\ncondition for automaticity, and `id_not_automatic` shows the simplest unbounded\n`P`-recursive sequence `a_n = n` already violates it \u2014 so the boundary is \"bounded\nrange\", not the degree of the recurrence as the original conjecture claimed.\n\n**Why now?** We have a formal, axiom-clean obstruction (`autoSeq_range_finite`);\nthe remaining task is to formalize the `automatic \u27f9 P-recursive` direction and the\nfinite-range converse, both of which are structural rather than analytic.\n\n## C4. Decidability survives the morphic boundary for *length-uniform* morphisms\n**Conjecture.** The zero-in-sequence problem stays decidable for morphic\nsequences generated by morphisms whose iterated images have lengths obeying a\nlinear recurrence (a strict subclass of general morphic sequences), via a pumping\nargument on the substitution graph rather than the DFA.\n\n**The key insight is** that the DFA pumping argument we formalized only used\nfiniteness of the state set plus a loop; a length-uniform morphism induces a\nfinite \"block automaton\" whose loops admit the same down-pump/up-pump dichotomy.\n\n**Why now?** The reusable lemmas `exists_shorter_of_long` and\n`accepts_infinite_of_long` are stated abstractly over any DFA, so porting them to\nthe block automaton of a length-uniform morphism is a definitional, not\nfoundational, step \u2014 letting us probe precisely where decidability breaks toward\nthe general (open) morphic case.\n\n## C5. The decidable instance is a certified bounded-search algorithm\n**Conjecture.** `decidableExistsOutputValue` extracts (via `Decidable.decide`) a\ntotal algorithm that, on any explicitly presented DFAO over a finite alphabet,\nreturns a witness word of length `< s` whenever the value `z` is attainable, and a\nproof of non-attainability otherwise \u2014 and this is *optimal* in worst-case search\ndepth.\n\n**The key insight is** that `zero_value_iff_short` certifies correctness of the\nbounded search and `accepts_infinite_of_long` certifies that no shorter universal\nbound than `s` exists, so the instance is not just decidable but length-optimal.\n\n**Why now?** The `Decidable` instance is already machine-checked; turning it into a\nbenchmarked, extracted decision procedure (the mission's \"verify on 100 test\nsequences\" test) is now purely an engineering exercise on top of verified math.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2026",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "1f4bbef7",
    "status": "available",
    "timestamp": "2026-06-16T20:27:08.408838+00:00",
    "title": "This cycle formalized the automata-theoretic core of the \"halting problem for"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Infinite-Dimensional Chess on the Hilbert Board\n\nThis cycle formalized the lone king vs. finite line-piece pursuit on the infinite\nboard `\u2124 \u00d7 \u2124` and established three pillars:\n\n1. **Escape corridor** (`king_escape_corridor`): against *any* finite line\n   configuration there is an infinite safe king-walk \u2014 the board cannot be fenced.\n2. **Exactly three lines mate** (`min_lines_for_checkmate`): a lone king can be\n   checkmated, and the minimum number of line pieces required is precisely 3.\n3. **Ordinal game values** (`gval_toPGame_lt`, `escape_value_omega0`): the\n   pursuit game value is the well-founded rank (an ordinal), it embeds into\n   Conway/`PGame` order via `Ordinal.toPGame`, and the hierarchy is genuinely\n   transfinite (a limit position has value `\u2265 \u03c9`).\n\nThe findings below are falsifiable conjectures that extend these results.\n\n---\n\n## Conjecture 1 \u2014 The `d`-dimensional mate number is `3^{d-1}`\n\nOn the Hilbert board `\u2124^d`, checkmating a lone king with one-dimensional line\npieces (each meeting the `3^d`-cell king neighbourhood in at most 3 cells)\nrequires **at least `3^{d-1}`** lines, and this is attained by `3^{d-1}` parallel\nhyper-rooks. For `d = 2` this recovers the proven value 3.\n\n- **The key insight is** that the counting bound `|neighbourhood| \u2264 3 \u00b7 #lines`\n  generalizes verbatim: a line is 1-dimensional and stabs the `3 \u00d7 3 \u00d7 \u22ef`\n  window in \u2264 3 cells, so `3^d \u2264 3 \u00b7 #lines`, forcing `#lines \u2265 3^{d-1}`; the\n  open part is realizability of the lower bound by an explicit cage.\n- **Why now?** `line_inter_nbhd_le` already isolates the only geometric fact\n  needed, and `nbhd`/`offsets` are defined by a product that ports directly to\n  `(Fin d \u2192 \u2124)`; the lower bound is a one-step generalization of the existing\n  pigeonhole proof.\n\n## Conjecture 2 \u2014 Point pieces need the full nine\n\nIf pieces attack only single squares (knights, pawns, kings \u2014 `lineSet a 0`),\nthen checkmating a lone king requires **exactly 9** attacked squares' worth of\npieces, i.e. one per neighbourhood cell, with no economy of scale.\n\n- **The key insight is** that a degenerate line (`d = 0`) covers exactly one\n  neighbourhood cell, so the covering inequality becomes `9 \u2264 #pieces` with no\n  factor of 3 \u2014 point pieces are maximally inefficient, the opposite extreme to\n  rook lines.\n- **Why now?** The `d = 0` branch of `line_inter_nbhd_le` already proves the\n  per-piece bound is 1; only the matching construction (nine point attackers)\n  remains, and it is concrete and finite.\n\n## Conjecture 3 \u2014 Countably many lines *can* fence the king, finitely many cannot\n\nThere is a *countable* family of line pieces whose attacked region has **no**\ninfinite safe king-walk (the escape corridor theorem is sharp at `\u2135\u2080`), yet every\n*finite* subfamily admits one.\n\n- **The key insight is** that `attacked_row_finite` uses finiteness twice (a free\n  row exists, and only finitely many columns are removed from it); with countably\n  many horizontal lines every row can be occupied, collapsing the free row that\n  drives `safe_ray`.\n- **Why now?** `safe_ray`/`horizRows` already pinpoint finiteness as the load-\n  bearing hypothesis, so negating it for a countable configuration is a direct,\n  testable boundary experiment.\n\n## Conjecture 4 \u2014 Realized pursuit values are exactly the ordinals below `\u03c9\u00b72`\n\nFor finite line configurations, the set of ordinal game values `gval` realized by\n\"mate-in-\u03b1\" positions (under a mobile-attacker refinement of `step`) is exactly\nthe interval of ordinals `< \u03c9`, and admitting one promoted piece pushes the\nspectrum to exactly `< \u03c9\u00b72`.\n\n- **The key insight is** that `gval` is an ordinal rank, so it automatically\n  ranges over an initial segment; the content is *which* segment, and\n  `escape_value_omega0` already shows `\u03c9` itself is reachable as a limit while\n  every concrete finite mate has finite value.\n- **Why now?** The abstract `gval`/`gval_toPGame_lt` scaffold is in place and the\n  `WithTop \u2115` instance demonstrates an `\u03c9`-valued position; refining `step` to a\n  genuine alternating chess pursuit is the single missing ingredient.\n",
    "domains": [
      "Logic",
      "Pythagorean"
    ],
    "id": "fd_2027",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "03edad6d",
    "status": "available",
    "timestamp": "2026-06-16T20:28:41.794432+00:00",
    "title": "This cycle formalized the lone king vs. finite line-piece pursuit on the infinit"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\nThese build directly on `BehavioralEquivalence.lean` and stay within precise, provable\nmathematics \u2014 no metaphysical extensions.\n\n## 1. Dynamical / transition systems\n\nReplace the static `behavior : S \u2192 B` with a labelled transition system\n`step : S \u2192 A \u2192 S` together with an output `out : S \u2192 B`, and define **behavioral equivalence as\nbisimilarity** (or trace/observational equivalence). Re-prove the supervenience/factorization\ncharacterization at the level of observable trajectories, and relate the quotient model to the\nstandard minimal-automaton / Nerode-congruence construction. Target theorem: a supervening\nrepresentation descends to the bisimulation quotient, and for finite automata the count of\nsupervening representations is `|R|` raised to the number of Nerode classes.\n\n## 2. Probabilistic / noisy observation and statistical identifiability\n\nGeneralize `behavior` to a Markov kernel `S \u2192 Measure B` (or `repr` to `S \u2192 Measure R`). The\ndeterministic notion \"behavior determines representation\" becomes statistical **identifiability**\nof the latent representation from the observable distribution. Formalize identifiability as\ninjectivity of the induced map on distributions and connect non-identifiability witnesses to\nthe existence of distinct latent models with identical observable law \u2014 the exact obstruction\nstudied for latent-variable and hidden-Markov models.\n\n## 3. Quantitative non-identifiability and metric structure\n\nEquip `B` and `R` with (pseudo)metrics and replace exact equality by approximate behavioral\nequivalence. Define a modulus measuring how much representation can vary over an\n\u03b5-behavioral ball, and prove Lipschitz-type \"approximate supervenience\" results: bounded\nbehavioral distinguishability implies bounded representational ambiguity only under explicit\nregularity hypotheses. This quantifies the gap between behavior and representation.\n\n## 4. Functorial / categorical packaging\n\nTreat `System S B R` morphisms (state maps commuting with `behavior` and `repr`) as a category\nand show the quotient-by-behavioral-equivalence is a functor / reflective construction. Express\n`supervenes_iff_factors` as a universal property of the behavioral image, and study how\nbehavior-preserving twins form a fiber over a fixed behavior map. This yields reusable\ninfrastructure for composing systems compositionally.\n\n## 5. Counting refinements and enumeration algorithms\n\nStrengthen `card_supervening_repr` into a fully explicit enumeration: a computable function that,\ngiven a behavior table and a choice of values on the image, returns every supervening\nrepresentation, with a proof that it is a bijection onto the supervening set. Add counts for\nbehavior-preserving twins, for non-identifiable systems, and for the number of distinct\nobservable behaviors realizable by a fixed family of representation maps \u2014 all over `Fintype`\nstate spaces with `decide`-checkable small instances.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2028",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "8dbe2c7e",
    "status": "available",
    "timestamp": "2026-06-16T21:05:14.517268+00:00",
    "title": "These build directly on `BehavioralEquivalence.lean` and stay within precise, pr"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 The Periodic Table of Finite Groups\n\nDerived from the verified Lean results in\n`Catalog/Novelty/PeriodicTableOfGroups.lean` and\n`Catalog/Novelty/GroupIsotopes.lean`.\n\nThis cycle formalized the \"chemistry meets algebra\" analogy by pinning down a single\nconserved chemical charge \u2014 **solvability** \u2014 and proving its conservation laws\n(`chemistry_isInvariant`, `nobleGas_commutator_trivial`), its sharp failure on the\nsimple-group block (`transitionMetal_dichotomy`), the halogen reactivity law\n(`halogen_cayley`), and the order-120 prediction (`order120_transitionMetal`).\nOn the isotope side we proved valence is `1` for transition metals\n(`simpleGroup_valence_one`) and that prime-order species have no genuine isotopes\n(`isotope_collapse`).\n\nThe central *negative* discovery \u2014 that a finite group's order is **determined** by its\ncomposition factors, so the chemical notion of \"isotope\" (same factors, different mass) is\nvacuous \u2014 drives the conjectures below.\n\n---\n\n## Conjecture 1 \u2014 The composition-factor mass law (the \"no isotopes\" theorem)\n\n**Statement.** For every finite group `G` with composition series of factors\n`S\u2081, \u2026, S\u2096`, `Nat.card G = \u220f\u1d62 Nat.card S\u1d62`. Consequently any two finite groups with the\nsame multiset of composition factors have equal order.\n\n**The key insight is...** that the chemistry analogy breaks at exactly one place \u2014 atomic\nmass \u2014 and the break is a theorem, not an accident: in groups, \"atomic number\" (order) is a\n*function* of the composition formula, whereas in atoms `Z` and mass are independent. This\nupgrades the partial result `isotope_collapse` (prime-order case) to the full block.\n\n**Why now?** Mathlib has the abstract `JordanHolder` lattice machinery but no group-level\ncomposition-series cardinality lemma; `transitionMetal_dichotomy` already shows the\nprime-order shadow is fully formalizable, so the multiplicativity of order over factors is\nthe next reachable rung.\n\n---\n\n## Conjecture 2 \u2014 Valence stratifies the table\n\n**Statement.** Define `valence G = ({N | MinimalNormalSubgroup N}).ncard`. Then a finite\ngroup is *characteristically simple* (a direct power of a simple group) iff it has a unique\nminimal normal subgroup that is also its socle; and nilpotent groups satisfy\n`valence G = #{p : p \u2223 |G|}` (one minimal normal subgroup per prime, from the central\nSylow structure).\n\n**The key insight is...** that `simpleGroup_valence_one` is the first cell of a *column*:\nvalence counts the irreducible \"bonding sites\" (minimal normal subgroups), and for the\nnilpotent (\"noble-gas-like\") block this count is forced to equal the number of distinct\nprime divisors via centrality of Sylow subgroups.\n\n**Why now?** We already have the `MinimalNormalSubgroup` predicate and the simple-group\ncomputation; the nilpotent case only needs Mathlib's existing Sylow-center theory, making\nthe column-valence law immediately testable.\n\n---\n\n## Conjecture 3 \u2014 Solvability is the *unique* nontrivial monotone chemical charge\n\n**Statement.** Any group property `P` that is (i) an isomorphism invariant, (ii) closed\nunder subgroups, quotients, and finite products, and (iii) false on some finite group, must\nbe implied by non-solvability: `\u00acIsSolvable G \u2192 \u00acP G`. Equivalently, solvability is the\nfinest such \"downward-and-upward closed\" charge below the line `True`.\n\n**The key insight is...** that `chemistry_isInvariant` plus the Mathlib closure instances\n(`subgroup_solvable_of_solvable`, `solvable_quotient_of_solvable`, `solvable_prod`) make\nsolvability a *formation-class* charge; the conjecture says no strictly stronger\nformation-class charge separates finite groups, so solvability really is the periodic\ntable's fundamental conserved quantity.\n\n**Why now?** Every closure law the conjecture quantifies over is already an instance in\nMathlib's `Solvable.lean`, so the statement is a finite-combinatorial extremality claim over\nknown building blocks rather than new analysis.\n\n---\n\n## Conjecture 4 \u2014 The transition-metal threshold is exactly atomic number 60\n\n**Statement.** Every group of order `< 60` is solvable, and `A\u2085` (order 60) is the lightest\nnon-solvable group; hence the first \"transition metal\" sits at atomic number 60, and the\norder-120 species `S\u2085` is its lightest non-solvable *compound* (already verified in\n`order120_transitionMetal`).\n\n**The key insight is...** that `transitionMetal_dichotomy` says non-solvability requires a\nnonabelian simple composition factor, and the smallest nonabelian simple group has order 60;\nso the periodic table has a literal *metallicity threshold* with `A\u2085` as its hydrogen.\n\n**Why now?** `Equiv.Perm.fin_5_not_solvable` (used in `order120_transitionMetal`) gives the\nupper witness for free; the remaining content \u2014 solvability of all groups of order `< 60` \u2014\nis a finite Sylow/Burnside `p\u1d43q\u1d47` argument whose ingredients (`IsPGroup.isSolvable`,\nBurnside) are present or near-present in Mathlib.\n\n---\n\n## Conjecture 5 \u2014 Reactivity = generation is quantitative (sharp Cayley degree)\n\n**Statement.** Refine `halogen_cayley`: the minimal `n` with `G \u21aa S\u2099` (the \"reactivity\ndegree\" `\u03bc(G)`) satisfies `\u03bc(G) \u2264 |G|` with equality iff `G` is cyclic of prime power order\nor one of finitely many exceptions; in general `\u03bc(G)` is the minimal sum of prime-power\nindices of a covering family of core-free subgroups.\n\n**The key insight is...** that the halogen embedding into `S_{|G|}` is almost never optimal \u2014\n\"reactivity\" is graded by the *minimal faithful permutation degree*, turning the qualitative\nCayley reaction into a measurable valence-like spectrum across the table.\n\n**Why now?** `halogen_cayley` already produces the canonical (regular) embedding; the\nmachinery for cosets and core-free subgroups exists in Mathlib, so optimizing the degree is\na concrete next experiment rather than a foundational build.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2029",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "fb007c35",
    "status": "available",
    "timestamp": "2026-06-16T22:35:58.741131+00:00",
    "title": "Derived from the verified Lean results in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Spectral Graph Theory Meets Network Robustness\n\nThis cycle established, fully in Lean 4 (0 sorries), a faithful bridge between the\ngraph Laplacian and network robustness in\n`Catalog/MachineLearning/SpectralRobustness/Core.lean`:\n\n- `dirichletEnergy` = the Laplacian quadratic form `x\u1d40 L x`;\n- `dirichletEnergy_mono` \u2014 adding edges only increases each signal's energy;\n- `connected_iff_finrank_ker_eq_one` \u2014 Fiedler's criterion (connected \u21d4 Laplacian\n  nullity 1);\n- `card_connectedComponent_antitone` / `finrank_ker_lapMatrix_antitone` \u2014 denser\n  networks have no more components / no larger Laplacian nullity;\n- `not_connected_iff_exists_nonconstant_zero_energy` \u2014 a spectral disconnection\n  certificate.\n\nBelow are bold, testable conjectures to formalize in follow-up cycles. Each is\nstated so that it can become a Lean theorem (or be refuted by a counterexample).\n\n## C1. Algebraic connectivity as an ordered eigenvalue, and its monotonicity\nDefine `algConnectivity G : \u211d` as the second\u2013smallest eigenvalue of `lapMatrix \u211d G`\n(the Fiedler value), using a Courant\u2013Fischer / min\u2013max characterization over\nsignals orthogonal to the constants. **Conjecture:** `algConnectivity` is monotone\nunder edge addition, i.e. `H \u2264 G \u2192 algConnectivity H \u2264 algConnectivity G`, and\n`algConnectivity G > 0 \u2194 G.Connected`. This upgrades the pointwise\n`dirichletEnergy_mono` and the nullity statement `connected_iff_finrank_ker_eq_one`\nto the genuine eigenvalue level. Requires building min\u2013max for `lapMatrix`, which\nMathlib currently lacks.\n\n## C2. Fiedler's bound: algebraic connectivity \u2264 vertex connectivity\n**Conjecture:** for a graph that is not complete, `algConnectivity G \u2264 \u03ba(G)`, the\nvertex connectivity (minimum number of vertices whose removal disconnects `G`).\nThis is the classical robustness inequality linking the spectral gap to the\ncombinatorial cut size. A formal first step is the edge version:\n`algConnectivity G \u2264 minEdgeCut G`.\n\n## C3. Cheeger inequality for the normalized Laplacian\nDefine the conductance / isoperimetric number `h(G) = min_S |\u2202S| / min(vol S, vol S\u1d9c)`\nand the normalized Laplacian spectral gap `\u03bb\u2082`. **Conjecture (Cheeger):**\n`\u03bb\u2082 / 2 \u2264 h(G) \u2264 sqrt(2 \u03bb\u2082)`. The easy direction (`\u03bb\u2082 / 2 \u2264 h(G)`) is a realistic\nformalization target using the Dirichlet-energy machinery already in this file:\nplug the indicator-style test signals into `dirichletEnergy` and bound the\nRayleigh quotient.\n\n## C4. Quantitative robustness: spectral lower bound on edges to disconnect\n**Conjecture:** the minimum number of edges whose deletion disconnects a connected\ngraph on `n` vertices is at least `algConnectivity G` (and at least\n`\u2308 algConnectivity G \u2309`). Equivalently, a single edge deletion drops the algebraic\nconnectivity by at most a controlled amount: `algConnectivity G - algConnectivity (G \\ e) \u2264 1`.\nThis is the eigenvalue-interlacing counterpart of `finrank_ker_lapMatrix_antitone`\nand would give a verified \"robustness margin\" for ML network design.\n\n## C5. Spectral robustness of graph products (scalability)\nFor the Cartesian product `G \u25a1 H`, the Laplacian spectrum is the sumset of the two\nspectra. **Conjecture:** `algConnectivity (G \u25a1 H) = min (algConnectivity G) (algConnectivity H)`,\nand consequently `dirichletEnergy_(G \u25a1 H)` decomposes additively over the factors.\nThis predicts how to build large robust networks (e.g. expander products) from\nsmall robust ones, and pairs with the existing catalog work on expander walks.\n",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_2030",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "1aac4615",
    "status": "available",
    "timestamp": "2026-06-16T23:47:38.176332+00:00",
    "title": "This cycle established, fully in Lean 4 (0 sorries), a faithful bridge between t"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Time-Travel Consistency as a Fixed-Point Theorem\n\nDerived from the research cycle formalized in\n`Catalog/Computation/NovikovConsistency.lean` and\n`Catalog/Computation/NovikovPolynomial.lean`, where Novikov's self-consistency\nprinciple is realized as the Banach fixed point of a causal *round-trip* map\n`T : X \u2192 X` (a self-consistent history is exactly a fixed point `T x = x`), with the\ntopological existence half reusing the catalog's\n`brouwer_fixedPoint_Icc_general`.\n\nThe cycle established a sharp **existence/uniqueness gap**: existence of a\nself-consistent history is *topological* (it holds for any continuous self-map of an\ninterval, and even pins an interior, irrational golden-ratio history for `x \u21a6 1 - x\u00b2`),\nwhereas *uniqueness* is *metric* and fails the moment the loop stops contracting\n(`x \u21a6 x\u00b2` carries two consistent histories `0` and `1`). The directions below push on\nexactly that gap.\n\n## 1. Quantitative paradox index from the spectral gap `1 - K`\n\n**Conjecture.** Define the *paradox index* of a guessed history `x` as\n`P(x) = dist x (T x)` (its one-step inconsistency). Then for a contracting causal map\nthe realized history is within `P(x)/(1-K)` of consistency, and this bound is *tight*\nfor affine maps: `dist x x* = P(x)/(1+a)` when `a < 0`.\n\n*The key insight is...* that `novikov_error_bound` already turns \"how paradoxical is\nthis guess?\" into a single scalar controlled by the spectral gap `1 - K`, so the gap\nitself is a measurable, falsifiable physical observable rather than a metaphor.\n\n*Why now?* `novikov_error_bound` and `affine_contracting` are proved; the tightness\nclaim is a finite affine computation (`field_simp`/`nlinarith`) that the current file\nis one lemma away from.\n\n## 2. Bifurcation of consistent histories at the contraction boundary `K = 1`\n\n**Conjecture.** Parameterize causal maps by gain `r` (e.g. logistic `r\u00b7x\u00b7(1-x)`). The\nnumber of self-consistent histories in `[0,1]` is `1` for `r \u2264 1` and `\u2265 2` for\n`r > 1`, with the new branch born exactly at the loss of contraction (`K \u2192 1`).\n\n*The key insight is...* that `logistic_carrying_capacity_consistent` exhibits the\nsecond (nonzero) history `1 - 1/r` appearing precisely as `r` crosses `1`, mirroring a\ntranscritical bifurcation \u2014 uniqueness is destroyed at the same threshold where\ncontraction is lost.\n\n*Why now?* The two logistic histories (`0` and `1 - 1/r`) are already formalized; what\nremains is to prove there are *exactly* these for `r \u2208 (1,3]`, a real-root-counting\nargument within reach of `polyrith`/`nlinarith`.\n\n## 3. Multidimensional Novikov: consistent field histories on `\u211d\u207f`\n\n**Conjecture.** For a causal map `T : \u211d\u207f \u2192 \u211d\u207f` that is `K`-Lipschitz with `K < 1` in\nthe Euclidean metric (e.g. an affine map `x \u21a6 A x + b` with `\u2016A\u2016 < 1`), there is a\nunique self-consistent field history, given by `(I - A)\u207b\u00b9 b`.\n\n*The key insight is...* that the abstract `novikov_unique_consistent` is already stated\nover an arbitrary complete metric space, so the entire content is the spectral\ncriterion `\u2016A\u2016 < 1 \u27f9 ContractingWith \u2016A\u2016 (A\u00b7+b)` \u2014 a matrix-norm lemma, not new\nfixed-point theory.\n\n*Why now?* `novikov_unique_consistent` is domain-agnostic and proved; Mathlib's\noperator-norm API (`ContinuousLinearMap.opNorm`) makes the `\u211d\u207f` instantiation a\nself-contained next step.\n\n## 4. Necessity is generic: most degree-\u22652 causal maps break uniqueness\n\n**Conjecture.** A real polynomial causal map of degree `d \u2265 2` whose leading\ncoefficient is positive has at least two real fixed points (hence is never a\ncontraction on all of `\u211d`) for an open, dense set of coefficient vectors.\n\n*The key insight is...* that `square_no_contraction` is not an isolated pathology: the\nfixed-point equation `p(x) = x` is itself a degree-`d` polynomial, so generically it\nhas multiple real roots, making the failure of Novikov uniqueness the *typical* case\nfor nonlinear causal maps.\n\n*Why now?* `square_no_contraction` gives the d=2 witness and the proof template\n(two fixed points \u21d2 no contraction, via `fixedPoint_unique'`); generalizing needs only\na root-existence count for `p(x) - x`.\n\n## 5. Approximate Novikov: \u03b5-consistent histories always exist on compacta\n\n**Conjecture.** Even when no exact contraction holds, every continuous causal map on a\ncompact state space admits, for each `\u03b5 > 0`, an *\u03b5-self-consistent* history with\n`dist (T x) x \u2264 \u03b5`; and if the space is additionally convex these upgrade to an exact\nconsistent history.\n\n*The key insight is...* that the catalog already contains the compactness upgrade\nprinciple (`exists_fixedPoint_of_approx_fixedPoint_compactness`), so approximate\nself-consistency \u2014 the physically realistic notion under measurement error \u2014 is the\nright weakening that survives the loss of contraction.\n\n*Why now?* `novikov_exists_interval` connects this file to the catalog's fixed-point\ncore; wiring in the compactness-upgrade lemma extends Novikov existence from intervals\nto arbitrary compact convex history spaces with no new heavy machinery.\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2031",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "14986cd2",
    "status": "available",
    "timestamp": "2026-06-16T23:48:48.355410+00:00",
    "title": "Derived from the research cycle formalized in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Unstoppable Self-Maps (Geometry)\n\nFollow-up conjectures for the theme *\"Self-modifying code that cannot be stopped\"*,\nbased on `Geometry/Unstoppable.lean` (the **drift criterion** for aperiodicity and\nits finite-state converse). Each is stated to be directly formalizable and\nfalsifiable in Lean 4 / Mathlib.\n\n## Conjecture 1 \u2014 Drift criterion is complete on the line\n**Statement.** Let `f : \u211d \u2192 \u211d` be continuous and monotone. Then `f` is\n`Unstoppable` (no periodic points) **iff** it admits a continuous drift coordinate,\nequivalently iff `f x \u2260 x` for all `x` and `f x - x` has constant sign. More\nsharply: a fixed-point-free continuous `f : \u211d \u2192 \u211d` is unstoppable, and conversely\nany continuous self-map of `\u211d` with a fixed point halts there.\n**Test.** Formalize `Unstoppable f \u2194 \u2200 x, f x \u2260 x` for continuous `f : \u211d \u2192 \u211d`\nusing the intermediate value theorem on `f^[n] x - x`.\n**Falsifier.** A continuous fixed-point-free `f : \u211d \u2192 \u211d` with a genuine periodic\norbit (would refute; conjecture predicts none exist).\n\n## Conjecture 2 \u2014 Quantitative escape rate from drift\n**Statement.** If `\u03c6 (f x) = \u03c6 x + c` with `c > 0` and `\u03c6` is `K`-Lipschitz for a\nmetric `d`, then `d (f^[n] x, x) \u2265 (|c|/K) \u00b7 n`; hence the orbit is a\n*quasi-isometric* embedding of `\u2115` and escapes every bounded set in finite time.\n**Test.** Prove `dist (f^[n] x) x \u2265 (c / K) * n` from `phi_iterate` and the\nLipschitz bound `|\u03c6 a - \u03c6 b| \u2264 K \u00b7 dist a b`.\n**Falsifier.** A drifting `f` with Lipschitz `\u03c6` whose orbit stays bounded.\n\n## Conjecture 3 \u2014 Group-theoretic dichotomy for affine maps\n**Statement.** An invertible affine map `f x = A x + b` of a finite-dimensional\nreal inner-product space is `Unstoppable` **iff** `b` is not in the range of\n`A - I` (i.e. the affine fixed-point equation `(A - I) x = -b` has no solution).\nWhen `A = I` this recovers `translate_unstoppable`; when `A` is a rotation with\n`1 \u2209 spectrum A`, the map always has a fixed point and halts.\n**Test.** Formalize `Unstoppable f \u2194 (-b) \u2209 Set.range (A - 1)` for `f x = A x + b`.\n**Falsifier.** An affine map with `(A-I)` surjective yet unstoppable, or with a\nfixed point yet unstoppable.\n\n## Conjecture 4 \u2014 Subexponential orbit growth forces a periodic point\n**Statement.** (Compactness/recurrence converse.) If `X` is a compact metric\nspace and `f : X \u2192 X` is continuous, then `f` is **not** `Unstoppable`: every\ncontinuous self-map of a nonempty compact metric space has a recurrent \u2014 in the\ntopological sense, almost-periodic \u2014 orbit, and on finite-dimensional compacta a\ngenuine periodic point in many cases. Minimal testable core: a continuous self-map\nof `[0,1]` (or `S\u00b9` with rational rotation number) always halts.\n**Test.** Prove `\u00ac Unstoppable f` for continuous `f : Set.Icc (0:\u211d) 1 \u2192 ...`\nvia Brouwer fixed point, strengthening `not_unstoppable_of_finite` from finite to\ncompact.\n**Falsifier.** A continuous fixed-point/periodic-point-free self-map of a compact\ninterval (Brouwer forbids it).\n\n## Conjecture 5 \u2014 Cocycle drift and unstoppable group actions\n**Statement.** A free action is the group-level analogue of unstoppability. If a\ngroup `G` acts on `X` and admits a nonzero homomorphism-twisted cocycle\n`\u03c6 : X \u2192 \u211d` with `\u03c6 (g \u2022 x) = \u03c6 x + \u03c7(g)` for a nontrivial character `\u03c7`, then\nevery `g` with `\u03c7(g) \u2260 0` acts without periodic points. Conjecture: for\n`G = \u2124` this is *equivalent* to the drift criterion, and the set of unstoppable\ngenerators is exactly `{g : \u03c7(g) \u2260 0}`.\n**Test.** Generalize `unstoppable_of_drift` to a `\u03c7`-twisted cocycle and recover\n`unstoppable_iterate_of_drift` as the `\u03c7(g) = c` special case.\n**Falsifier.** A cocycle action with `\u03c7(g) \u2260 0` admitting a periodic point.\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2032",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "b4a517d3",
    "status": "available",
    "timestamp": "2026-06-17T00:29:20.027992+00:00",
    "title": "Follow-up conjectures for the theme *\"Self-modifying code that cannot be stopped"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 The Topology of Argumentation: Why Debates Have Holes\n\nThis cycle established a formal core for abstract argumentation frameworks (AFs) in\n`Catalog/Novelty/ArgumentationTopology.lean`:\n\n- the **lattice / fixed-point backbone** (`charF_mono`, `grounded`, `grounded_fixed`,\n  `grounded_least`) \u2014 the canonical \"skeleton\" of a debate via Knaster\u2013Tarski;\n- the **Dung hierarchy** `stable \u27f9 complete \u27f9 admissible` (`stable_admissible`,\n  `stable_complete`, `admissible_empty`);\n- the two fundamental **holes** \u2014 the odd cycle `cyc3` and the self-loop `loop1` \u2014 versus\n  the resolvable even cycle `cyc2`, with a `Finset \u2194 Set` bridge (`hole_cyc3`,\n  `hole_loop1`, `resolvable_cyc2`, `hole_cyc3_set`);\n- the structural insight that **holes require asymmetry**: every finite *symmetric,\n  irreflexive* debate is resolvable (`symmetric_irreflexive_resolvable`).\n\nThe following conjectures are bold, precise, and testable in subsequent cycles.\n\n## C1 \u2014 The Parity Theorem for directed cycles\nFor the directed `n`-cycle `cyc n : Fin n \u2192 Fin n \u2192 Prop := fun i j => j = i + 1`,\na stable extension exists **iff `n` is even** (`n \u2265 2`):\n```\ntheorem cyc_resolvable_iff_even (n : \u2115) (hn : 2 \u2264 n) :\n    Resolvable (cyc n) \u2194 Even n\n```\nWe verified `n = 2` (resolvable) and `n = 3` (hole). The conjecture promotes \"the odd hole\"\nfrom an example to a theorem: parity of a directed cycle is *the* topological invariant\ngoverning resolvability. Likely proof: stable extensions of `cyc n` are exactly the\nalternating independent sets, which exist iff `n` is even.\n\n## C2 \u2014 Grounded extension is always complete (and conflict-free)\nThe least fixed point `grounded r` should itself be a genuine extension:\n```\ntheorem grounded_complete (r : A \u2192 A \u2192 Prop) : Complete r (grounded r)\ntheorem grounded_conflictFree (r : A \u2192 A \u2192 Prop) : ConflictFree r (grounded r)\n```\nThis would show every debate has a canonical (possibly empty) \"forced core\" that is a real\nposition, even when no stable extension exists \u2014 i.e. the skeleton survives even in holed\ndebates. The expected proof uses `OrderHom.lfp` induction (`lfp_induction`) with\nconflict-freeness as the invariant; the subtlety is that conflict-freeness is not\nobviously preserved by `charF`, so an auxiliary invariant (admissibility of the iterates)\nis likely needed.\n\n## C3 \u2014 Euler-characteristic / Betti obstruction (the homological hole count)\nMake the topology literal. Associate to a finite AF `r` the directed graph and a chain\ncomplex whose first Betti number `b\u2081` counts independent directed cycles. Conjecture: a\nfinite AF with `b\u2081 = 0` (a \"forest of attacks\") is always resolvable, and more strongly the\n*number of distinct holes* (maximal sub-debates with no stable extension) is bounded by a\nfunction of `b\u2081`:\n```\ndef b1 (r : Fin n \u2192 Fin n \u2192 Prop) : \u2115 := ...   -- cycle rank of the attack digraph\ntheorem acyclic_resolvable (r : Fin n \u2192 Fin n \u2192 Prop) [DecidableRel r]\n    (h : b1 r = 0) : Resolvable r\n```\nThis is the sharpest sense of \"why debates have holes\": holes are detected by first\nhomology of the attack complex. A natural first milestone: prove that an attack relation\nthat is a strict partial order (well-founded, acyclic) always has a stable extension equal\nto its grounded extension.\n\n## C4 \u2014 Stability gap = obstruction class\nDefine the *stability gap* of a debate as the minimal number of arguments that must be\ndeleted to make it resolvable. Conjecture: for symmetric+irreflexive AFs the gap is `0`\n(C-confirmed direction), and for a directed `n`-cycle the gap is exactly `1` when `n` is\nodd. More generally the gap equals the minimum number of vertices meeting every \"odd\nattack cycle\", an argumentation analogue of the odd-cycle transversal / `\u03c7`-boundedness\nphenomenon.\n\n## C5 \u2014 Continuity / sheaf gluing of local debates\nTreat a large debate as glued from overlapping sub-debates (a cover). Conjecture: if every\nmember of a cover is resolvable and the resolutions agree on overlaps (a *cocycle*\ncondition), then the global debate is resolvable; the obstruction to gluing lives in an\n`H\u00b9` of the nerve of the cover. This would turn \"debates have holes\" into a genuine\nsheaf-cohomological statement and connect the Novelty catalog to the persistent-homology\nand sheaf entries in the Tropical catalog.\n",
    "domains": [
      "Logic",
      "Geometry"
    ],
    "id": "fd_2033",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "5f9a16a6",
    "status": "available",
    "timestamp": "2026-06-17T00:30:52.789495+00:00",
    "title": "Formal core for abstract argumentation frameworks (AFs)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Ramanujan-Style Intuition as Formalizable Meta-Reasoning\n\nDerived from this cycle's findings (`Core.lean`, `Halting.lean`,\n`FiniteBoundary.lean`, `JumpBridge.lean`). Each conjecture is bold, falsifiable,\nand stated so that a single Lean theorem (or counterexample) would settle it.\n\nThe central correction this cycle produced: **the mission's literal \"length \u2264 100\"\nframing is false** (`bounded_oracle_computable`) \u2014 every bounded family is decided\nby a computable lookup table, *even for a non-computable truth function*. The real\nobstruction is **sound + complete behaviour on an unbounded domain**\n(`no_computable_sound_complete_oracle`), and its structural home is the **oracle\njump hierarchy** (`JumpBridge.lean`). The conjectures below build on this.\n\n---\n\n## C1. Soundness forces *infinitely many* abstentions, not just one.\n**Statement.** Every computable, sound verdict oracle for the halting predicate\nanswers `unknown` on an infinite set of codes (not merely one).\n**The key insight is** that a single abstention can always be patched by a finite\ntable (`FiniteBoundary.bounded_oracle_computable`), so any *finitely-abstaining*\nsound computable oracle could be upgraded to a perfect one \u2014 contradicting\n`no_computable_sound_complete_oracle`; hence the abstention set must be infinite.\n**Why now?** We already have the perfect-oracle impossibility and the finite-table\nupgrade lemma in this cycle; combining them via a finiteness/pigeonhole argument is\nthe immediate next Lean step.\n\n## C2. High accuracy does **not** imply non-computability (accuracy is a red herring).\n**Statement.** There exists a non-computable truth function `\u03c4` and a *computable*\nverdict oracle whose committed answers are correct with asymptotic density `1`.\n**The key insight is** that the density of \"hard\" instances, not raw accuracy, is\nwhat computability controls; a non-computable set can have a computable density-1\napproximation, so the mission's \"\u2265 95% accuracy \u21d2 non-computable\" is unprovable as\nstated and should be *refuted* by an explicit construction.\n**Why now?** `Core.lean` shows diagonalization only forces *one* error per oracle,\nnever a positive error density \u2014 exactly the gap a density-1 computable approximant\nwould exploit. The tools (computable tables + a sparse non-computable set) are in hand.\n\n## C3. The \"intuitive leap\" is strictly stronger than any finite tower of leaps.\n**Statement.** For every `OracleJumpR` `J` and sound incomplete Ramanujan oracle,\nthe limit `\u22c3\u2099 (J.iter T\u2080 n).provable` strictly contains every finite level\n`(J.iter T\u2080 n).provable`, yet is still incomplete relative to truth.\n**The key insight is** that `truth_invariant` pins the model while\n`strict_hierarchy` (both used in `JumpBridge.lean`) make the provable sets a strict\n\u03c9-chain \u2014 so the union escapes every level but a fresh diagonal escapes the union.\n**Why now?** `JumpBridge.lean` already imports the strict-hierarchy and\ntruth-invariance machinery; the catalog's `limit_escape` is the missing lemma to\nwire in, making this a short composition.\n\n## C4. Identifying the leap with the *Turing* jump requires the arithmetical hierarchy.\n**Statement.** There is no order-embedding from the abstract `OracleJumpR` tower to\nthe Turing-degree jump tower `0, 0', 0'', \u2026` definable without naming a `\u03a3\u2070\u2081`\ntruth predicate; conversely, *with* such a predicate the embedding exists and is\nunique up to the first level.\n**The key insight is** that `OracleJumpR` is purely extensional (strict + truth\npreserving), whereas the Turing jump is intensional (it is the halting set of the\nprevious level); bridging them is exactly the content `Halting.lean` isolates via\n`ComputablePred.halting_problem`.\n**Why now?** This cycle produced both endpoints \u2014 an abstract jump tower\n(`JumpBridge.lean`) and a concrete halting non-computability witness\n(`Halting.lean`); the conjecture asks precisely for the morphism between them.\n\n## C5. \"Discovery without proof\" is formalizable as a sound oracle with unbounded verification delay.\n**Statement.** There is a computable, sound, *eventually complete* oracle for any\n`\u03a3\u2070\u2081` family \u2014 one that commits correctly to every true statement after a finite\n(but unbounded) delay \u2014 and no such oracle exists for a properly `\u03a0\u2070\u2081` family.\n**The key insight is** that Ramanujan's \"guess now, verify later\" matches semi-\ndecidability: enumerability gives eventual `true`-commitment, while the absence of\nco-enumerability is exactly what blocks completeness \u2014 the same asymmetry behind\n`no_computable_sound_complete_oracle`.\n**Why now?** The verdict/soundness/completeness vocabulary built in `Core.lean`\nplus Mathlib's `RePred`/`Partrec` API make the `\u03a3\u2070\u2081` (yes) vs `\u03a0\u2070\u2081` (no) split a\ndirect next formalization, turning the metaphor into a theorem.\n",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_2034",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "d1b34dda",
    "status": "available",
    "timestamp": "2026-06-17T00:58:45.832365+00:00",
    "title": "Derived from this cycle's findings (`Core.lean`, `Halting.lean`,"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 Gravity from Information: Spacetime as a Quantum Error-Correcting Code\n\nThis research cycle built a fully verified, manifold-free combinatorial core of\nthe holographic principle in `Catalog/Geometry/HolographicCode/`:\n\n* `AreaEntropy.lean` \u2014 the discrete Ryu\u2013Takayanagi **area functional**\n  `cut w A = \u2211_{u\u2208A, v\u2209A} w u v`, with purity (`cut_compl`), subadditivity,\n  **strong subadditivity** (`cut_submodular`), and Araki\u2013Lieb (`cut_arakiLieb`).\n* `Monogamy.lean` \u2014 the key finding `cut_tripartite_eq`: the bare boundary cut\n  has **identically vanishing tripartite information** (`I\u2083 \u2261 0`), so it\n  saturates Monogamy of Mutual Information (`cut_monogamy`).\n* `MutualInformation.lean` \u2014 the information dictionary: `mutualInfo` and\n  `condMutualInfo` defined from geometry, with nonnegativity = subadditivity /\n  strong subadditivity (`mutualInfo_nonneg`, `condMutualInfo_nonneg`).\n\nThe single sharpest discovery is that **the fixed boundary cut is too rigid**:\nit makes `I\u2083 = 0` exactly, whereas genuine holographic states have `I\u2083 < 0`.\nThe quantum-information content of geometry therefore lives in the *minimization*\nover bulk surfaces \u2014 the entanglement-wedge / min-cut prescription. The\nconjectures below are organized around closing that gap.\n\n---\n\n## Conjecture 1 (Strict Monogamy needs the min-cut). \n\nDefine the **min-cut RT entropy** on a weighted graph with a distinguished\nboundary `\u2202 \u2286 V`:\n`minCut w A = \u2a05 { cut w X | X \u2286 V, X \u2229 \u2202 = A }` (surfaces homologous to `A`).\nThen `minCut` still satisfies subadditivity and strong subadditivity, **and** its\ntripartite information is genuinely nonpositive:\n`minCut(A)+minCut(B)+minCut(C) \u2212 minCut(A\u222aB) \u2212 minCut(B\u222aC) \u2212 minCut(A\u222aC) + minCut(A\u222aB\u222aC) \u2264 0`,\nwith *strict* inequality for some graph (a witness already exists on the\n\"triangle of bulk legs\" graph). **Testable:** the strictness is exactly the\nphenomenon absent from our `cut_tripartite_eq`.\n\n## Conjecture 2 (Full holographic entropy cone). \n\nFor `minCut` of Conjecture 1, *all* facet inequalities of the known holographic\nentropy cone hold \u2014 in particular the 5-party HHM/cyclic inequalities that are\nstrictly stronger than MMI. Conversely, the *bare* `cut` satisfies every\ninequality that is a consequence of submodularity **and saturates exactly those\nthat are linear combinations of `I\u2083 = 0`-type identities**. Goal: classify which\nfacets the fixed cut saturates versus which require minimization.\n\n## Conjecture 3 (Complementary recovery / QEC duality). \n\nModel a holographic code by a bulk vertex set and a boundary `\u2202`, with a bulk\n\"operator\" localized at a vertex `p`. Define `A` *recovers* `p` iff `p` lies on\nthe `A`-side of every minimum cut `minCut w A`. Conjecture: for a pure global\nstate (symmetric `w`), **exactly one** of `A`, `A\u1d9c` recovers `p`\n(complementary recovery), and the set of recovering regions is an up-set closed\nunder the min-cut \"entanglement wedge.\" This is the discrete Knill\u2013Laflamme /\noperator-algebra QEC statement, and should follow from submodular uncrossing of\nminimum cuts.\n\n## Conjecture 4 (Discrete area law \u21d2 continuum RT). \n\nFor a sequence of graphs `G_n` discretizing a Riemannian surface with edge\nweights `w_n` approximating the metric, the rescaled cut entropies\n`(1/n) \u00b7 cut w_n A_n` **\u0393-converge** to the geometric area\n`\u222b_{\u2202A} ds` of the minimal surface bounding `A`. This would derive the continuum\nRyu\u2013Takayanagi area law as a scaling limit of the verified combinatorial\ninequalities, with the entropy inequalities passing to the limit by lower\nsemicontinuity.\n\n## Conjecture 5 (Cut distance and the Singleton bound). \n\nThe functional `dist(A,B) = cut w (A \u25b3 B)` (symmetric difference) is a\npseudometric on regions, and for a code defined by the min-cut, the code\n**distance** `d` (minimum weight of an undetectable boundary perturbation) and\nthe number `k` of protected bulk degrees of freedom obey a discrete\n**quantum-Singleton-type bound** `k \u2264 |\u2202| \u2212 2(d \u2212 1)` expressible purely via\n`minCut`. Saturation should characterize \"perfect-tensor\" / maximally\nholographic graphs (the HaPPY pentagon tiling).\n",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_2036",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "ed805c6d",
    "status": "available",
    "timestamp": "2026-06-17T01:40:31.338348+00:00",
    "title": "Fully verified, manifold-free combinatorial core of"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Proof Complexity and Thermodynamic Cost\n\nDerived from the Stage 3 / Stage 4 findings of\n`ThermodynamicCost.lean` and `LandauerBridge.lean`.  Each conjecture is bold,\nfalsifiable, and tied to a concrete formalization target in this subtree.\n\n## Recap of this cycle's verified findings\n\n* `cost_mono` / `cost_strictMono`: thermodynamic cost is (strictly) monotone in\n  Kolmogorov complexity, **not** in raw proof length (the literal \"shorter \u21d2\n  cheaper\" reading is false \u2014 a long proof can be highly compressible).\n* `exists_incompressible` + `cost_exceeds_any_bound`: a pigeonhole Chaitin bound\n  forces incompressible proofs whose cost beats any finite threshold.\n* `majority_high_complexity`: at least half of all length-`n` proofs are nearly\n  incompressible, so the **average** cost is `\u0398(n)` \u2014 refuting the brief's\n  `\u0398(2^n)`, which actually measures the **total** cost over all `2^n` proofs.\n* `freeEnergy_landauer_gap`: the finite-temperature free energy of a statistical\n  system sits exactly a Landauer term `cost(1/\u03b2) b = b\u00b7T\u00b7ln 2` (for `2^b`\n  configurations) below the tropical (zero-temperature) ground energy.\n\n---\n\n## Conjecture 1 \u2014 Total cost is `\u0398(n \u00b7 2^n)`, average cost is `\u0398(n)`\n\nOver a surjective decoder, `2^(n-1)\u00b7(n-1) \u2264 \u03a3_{|x|=n} K D x \u2264 (n + c)\u00b72^n` for an\nabsolute constant `c` (the upper bound needs an *efficient* decoder, e.g. one that\ncopies its input verbatim with a one-bit flag).\n\n* **The key insight is** that the `\u0398(2^n)` in the original brief conflates the\n  *count* of statements with their *average* description length; separating the\n  two yields a total of `\u0398(n\u00b72^n)` and an average of `\u0398(n)`.\n* **Why now?** `majority_high_complexity` already gives the load-bearing lower\n  half; the matching upper bound only needs a concrete \"identity-with-flag\"\n  decoder, which is a finite, mechanical construction in the present framework.\n\n## Conjecture 2 \u2014 Cost is sharply concentrated (a thermodynamic Azuma bound)\n\nFor a surjective decoder the fraction of length-`n` proofs with\n`|K D x \u2212 n| > t` decays like `2^{-t}`; hence cost concentrates within an\n`O(T)`-width band around `n\u00b7T\u00b7ln 2`.\n\n* **The key insight is** that incompressibility is not just typical but\n  *exponentially* typical: only `2^{n-t}` proofs admit a program shorter than\n  `n \u2212 t`.\n* **Why now?** The counting machinery `Bshort_card`, `Bexact_card`, and the image\n  bound in `exists_incompressible` generalise verbatim from \"shorter than `n`\" to\n  \"shorter than `n \u2212 t`\", so the tail bound is one parametrised counting lemma\n  away.\n\n## Conjecture 3 \u2014 A genuine (computable-bound) Chaitin obstruction\n\nThere is no total computable `f : \u2115 \u2192 \u2115` with `K D x \u2264 f x.length` for every `x`\nunder a *universal* decoder `D`; consequently no computable function bounds\nthermodynamic cost as a function of statement length.\n\n* **The key insight is** that the bound-free `cost_exceeds_any_bound` becomes a\n  true Chaitin theorem once `D` is upgraded from \"surjective\" to \"universal\"\n  (simulates every other decoder up to an additive constant).\n* **Why now?** Mathlib's `Nat.Partrec` / `Computable` hierarchy supplies a usable\n  model of computation; the only new ingredient is an invariance theorem\n  `K_universal x \u2264 K_D x + c_D`, which the surjective-decoder API here is designed\n  to slot into.\n\n## Conjecture 4 \u2014 Landauer sandwich is asymptotically tight\n\nFor fixed Hamiltonian and `#\u03a9 = 2^b`, `classicalFreeEnergy H \u03b2` converges to the\ntropical ground energy as `\u03b2 \u2192 \u221e`, and the gap is `\u0398(b\u00b7T)` whenever the ground\nstate is non-degenerate; degeneracy `g` shrinks the gap to `(b \u2212 log\u2082 g)\u00b7T\u00b7ln 2`.\n\n* **The key insight is** that the Landauer cost of a computation is the entropy of\n  its *forgotten* configurations, so ground-state degeneracy is a free,\n  reversible resource that lowers the thermodynamic floor.\n* **Why now?** `freeEnergy_le_ground` and `ground_sub_le_freeEnergy` already\n  bracket the gap; refining the upper sum bound from `#\u03a9` to the degeneracy count\n  reuses the catalog's `tropicalDegeneracyAbsorption` directly.\n\n## Conjecture 5 \u2014 Cost super-additivity across independent lemmas\n\nIf a proof `\u03c0` decomposes as independent sub-proofs `\u03c0\u2081, \u03c0\u2082` (disjoint program\nsupports), then `cost(\u03c0) \u2265 cost(\u03c0\u2081) + cost(\u03c0\u2082) \u2212 O(T)`; complexity is\nsub-additive but the *erasure* cost of recombination is the `O(T)` defect.\n\n* **The key insight is** that the Landauer overhead of *merging* two proofs is the\n  mutual information they share \u2014 exactly the catalog's tropical\n  `tprof_add_le` ultrametric defect translated into thermodynamic units.\n* **Why now?** The generic `cost T : \u2115 \u2192 \u211d` here is linear, so super-additivity\n  reduces to a complexity inequality `K(\u03c0) + O(1) \u2265 K(\u03c0\u2081) + K(\u03c0\u2082)` over a\n  prefix-free decoder \u2014 a finite combinatorial statement provable with the\n  current `descLengths` API.\n",
    "domains": [
      "Algebra",
      "Physics"
    ],
    "id": "fd_2037",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "702894c4",
    "status": "available",
    "timestamp": "2026-06-17T01:44:32.980272+00:00",
    "title": "Derived from the Stage 3 / Stage 4 findings of"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 Tropical Persistent Topology\n\nResearch cycle: *Topological Data Analysis of Theorem Networks* (Domain: Tropical).\nFoundation laid in `Catalog/Tropical/Persistence/SublevelFiltration.lean`:\ntropical polynomials are convex, their sublevel filtrations have a single-bar\ndegree-0 persistence, and the tropical semiring operations `\u2295 = max`, `\u2297 = +`\nact on value functions and on the filtration in a controlled way.\n\nBelow are bold, **testable** conjectures for follow-up cycles. Each is stated so\nthat it can be formalized as a Lean theorem (or refuted by a Lean\ncounterexample).\n\n## C1 \u2014 Degree-`k` persistence collapse (k \u2265 1)\n**Conjecture.** For every tropical polynomial `p : TropPoly n` and every threshold\n`c`, the sublevel set `sublevel p c` is contractible whenever it is nonempty;\nhence *all* reduced persistent homology vanishes and the full persistence diagram\nis the single H\u2080 bar already established.\n*Test.* Strengthen `convex_sublevel` to `Contractible`/`StarConvex` (a convex set\nin `\u211d\u207f` is contractible). Formalize via `Convex.contractibleSpace` or by\nexhibiting a star-center. Falsifiable: produce a `p`, `c` with disconnected or\nholey sublevel set (impossible if convexity is unconditional \u2014 so the conjecture\npredicts no such example exists).\n\n## C2 \u2014 Tropical hypersurfaces are the true carriers of topology\n**Conjecture.** Replace the *sublevel* set by the **tropical hypersurface**\n(the non-differentiability locus `V(p) = { x | the max in p.toFun x is attained\n\u2265 twice }`). Then the filtration of `\u211d\u207f \\ V(p)` by connected components is\ngoverned by `card p.\u03b9`: the number of top-dimensional regions equals the number\nof monomials that are \"essential\" (achieve the max somewhere), and this count is\n*sub-additive* under `\u2295` and *multiplicative-with-defect* under `\u2297`.\n*Test.* Define `essential p = { i | \u2203 x, p.toFun x = monomial (coeff i) (slope i) x }`\nand prove `essential (tropAdd p q) \u2286 image essential p \u222a image essential q`.\n\n## C3 \u2014 Persistence stability for tropical polynomials  *(pointwise core: PROVED)*\n**Status.** The pointwise, dimension-free part is established as `toFun_stable`\nin `SublevelFiltration.lean`: `|p.toFun x \u2212 (p.recoeff a').toFun x| \u2264\n\u2a06\u1d62 |coeff\u1d62 \u2212 a'\u1d62|`, uniformly in `x`, with the generic `sup'`-Lipschitz lemma\n`abs_sup'_sub_sup'_le`.\n**Remaining conjecture.** Lift this to *barcode* stability: the degree-0 birth\nvalue `b(p)` (see C4) is `1`-Lipschitz in the coefficients, and more generally the\nbottleneck distance of persistence diagrams is bounded by the sup-distance of\ncoefficients.\n*Test.* Combine `toFun_stable` with the existence of a minimizer (C4) to bound\n`|b(p) \u2212 b(q)|`. Falsifiable by any coefficient perturbation producing a\nbirth-value jump exceeding the perturbation.\n\n## C4 \u2014 Newton-polytope \u2194 persistence dictionary\n**Conjecture.** The birth value `b(p) = inf { c | sublevel p c \u2260 \u2205 }` of the\nsingle H\u2080 bar equals the value of the tropical polynomial at the *tropical\nminimum*, and is determined entirely by the lower hull of the lifted Newton\npolytope `{ (slope i, coeff i) }`. In particular `b(tropMul p q) = b(p) + b(q)`\nand `b(tropAdd p q) = min (b(p)) (b(q))` whenever the relevant infima are\nattained (e.g. all slopes nonzero / coercive case).\n*Test.* Introduce a coercivity hypothesis guaranteeing attainment, prove\nexistence of a global minimizer (`IsCompact` sublevel sets), then the additive\nand min laws for `b` follow from `toFun_tropMul` and `toFun_tropAdd`.\n\n## C5 \u2014 Theorem-network functoriality (the meta-TDA layer)\n**Conjecture.** Assigning to each tropical polynomial its persistence barcode is\n*functorial* over the tropical semiring: there is a barcode-valued semiring\nhomomorphism sending `\u2295` to barcode-min and `\u2297` to barcode-sum, extending the\ncatalog's `TropicalSemiringHom`. Formally, the assignment\n`p \u21a6 b(p) \u2208 (\u211d, min, +)` is a semiring homomorphism into the tropical semiring\nitself \u2014 i.e. tropical persistence is a *self-map of the tropical line*.\n*Test.* Once C4 supplies `b`, prove `b` is a `min`-`+` homomorphism, closing the\nloop with `Tropical/NeuralNetworks/TropicalSemiringHom.lean`. Falsifiable if any\n`p, q` violate `b(p \u2295 q) = min (b p) (b q)`.\n",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "id": "fd_2038",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "2d22ac65",
    "status": "available",
    "timestamp": "2026-06-17T02:02:13.252327+00:00",
    "title": "Research cycle: *Topological Data Analysis of Theorem Networks* (Domain: Tropica"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Tangled Hierarchies (GL-Kripke geometry of self-soundness)\n\nDerived from this cycle's findings in `Core.lean`, `SelfSoundness.lean`,\n`Examples.lean`. This cycle established, on finite transitive irreflexive\n(well-founded) Kripke geometries:\n\n* the *untangled* reflection schema `\u25a1S \u2192 S` collapses (`reflection_collapse`);\n* the *tangled* fixed-point principle `\u25a1(\u25a1S \u2192 S) \u2192 \u25a1S` (L\u00f6b) is always valid;\n* the consistency sentence is its **own** G\u00f6del fixed point `Con = \u00ac\u25a1Con`\n  (`consistency_is_godel_fixed_point`), giving a geometric G\u00f6del II\n  (`godel_second_incompleteness`).\n\nThe conjectures below are bold, falsifiable refinements.\n\n---\n\n## Conjecture 1 \u2014 Bounded Tangling (one diagonal, never a schema)\n\nA consistent GL geometry hosts a self-referential soundness predicate for the\n*single* target `\u22a5` (its consistency sentence), but no consistent geometry can\nhost a self-referential predicate `Sound` satisfying `Sound = \u00ac\u25a1Sound` together\nwith the *global* soundness schema `\u25a1S \u2192 S` restricted to any infinite,\nnontrivially-closed family of `S`.\n\n**The key insight is** that `reflection_collapse` forbids a sound schema while\n`canonicalSelfSound` provides exactly one diagonal sentence \u2014 tangling is real\nbut *measure-zero*: it never spreads from one fixed point to a whole hierarchy.\n\n**Why now?** We already have both the impossibility (`reflection_collapse`) and\nthe single witness (`canonicalSelfSound`) compiled in the same namespace; the\nconjecture is the precise frontier between them and is a finite combinatorial\nstatement amenable to the same well-founded induction used for L\u00f6b.\n\n---\n\n## Conjecture 2 \u2014 Rank-Graded Consistency Strength\n\nDefine the rank `\u03c1(w)` of a world as its height in the well-founded\naccessibility geometry (`wf_flip`). Then a world validates the `n`-fold iterated\nconsistency assertion `\u25a1\u207f Con` **iff** `\u03c1(w) \u2265 n`. In particular the maximal\nnumber of nested \"I am consistent\" assertions a world can carry is exactly its\nrank.\n\n**The key insight is** that each `\u25a1` step strips one level of the well-founded\ngeometry (the G\u00f6del-II step `\u25a1Con \u2192 \u25a1\u22a5` consumes one rank), so iterated\nprovability is literally a ruler measuring geometric depth.\n\n**Why now?** `godel_two_frame` already encodes the single-step descent; turning\nit into a rank function is the natural induction, and `wf_flip` supplies the\nrecursion principle out of the box.\n\n---\n\n## Conjecture 3 \u2014 Uniqueness of Tangled Fixed Points (de Jongh\u2013Sambin, frame form)\n\nEvery *box-modalized* set operator `\u03a6 : Set World \u2192 Set World` (one where\nmembership of `w` in `\u03a6 S` depends on `S` only through successors of `w`) has a\n**unique** fixed point on each GL geometry, and that fixed point is explicitly\ncomputable by well-founded recursion along `wf_flip`.\n\n**The key insight is** that the very well-foundedness that powers L\u00f6b's theorem\nalso makes the diagonal recursion well-defined and rigid: there is no room for a\nsecond solution because successors are strictly lower in the geometry.\n\n**Why now?** The consistency sentence is the special case `\u03a6 S = (\u25a1S)\u1d9c` already\nproven to be a fixed point; generalizing the explicit construction to all\nmodalized `\u03a6` reuses the identical `wf_flip` recursion.\n\n---\n\n## Conjecture 4 \u2014 Polymodal Tangling Is Strictly Worse\n\nOn a geometry carrying two transitive irreflexive relations `R\u2081, R\u2082` (two\nprovability operators `\u25a1\u2081, \u25a1\u2082`), the *joint* consistency sentence\n`Con\u2081\u2082 = (\u25a1\u2081\u22a5)\u1d9c \u2229 (\u25a1\u2082\u22a5)\u1d9c` is generally **not** a fixed point of either single\n\"not-provable\" operator; a genuine fixed point exists only for the relation that\ncontains the other. Hence relative interpretability is detectable purely from\nwhich single box can diagonalize the joint consistency sentence.\n\n**The key insight is** that G\u00f6del II (`godel_two_frame`) is relation-specific:\nseeing a `R\u2081`-dead-end is unrelated to seeing a `R\u2082`-dead-end, so tangling\nfragments across modalities and exposes their ordering.\n\n**Why now?** The catalog already gestures at polymodal GL (`Logic/PolymodalGL`);\nour `godel_two_frame` is stated for a single abstract `R`, so instantiating it\ntwice and comparing is immediate.\n\n---\n\n## Conjecture 5 \u2014 Self-Sound Frames Form a Reflective Subcategory\n\nFrame morphisms (bounded p-morphisms) between GL geometries lift to morphisms of\n`SelfSoundFrame`, and `canonicalSelfSound` is the right adjoint (coreflector)\nsending each geometry to its canonical self-referential soundness predicate;\nevery self-sound frame maps uniquely to a canonical one preserving `Con`.\n\n**The key insight is** that the consistency fixed point is *natural* \u2014 it is\ndefined uniformly as `(\u25a1\u22a5)\u1d9c` with no choices \u2014 so it must be functorial, and\nuniversality follows from uniqueness (Conjecture 3).\n\n**Why now?** `canonicalSelfSound` is already a total, choice-free construction in\n`SelfSoundness.lean`; only the morphism layer is missing, and the catalog's\n`Geometry/CategoricalTower` provides the categorical scaffolding to reuse.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2040",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "1873f003",
    "status": "available",
    "timestamp": "2026-06-17T03:35:45.482730+00:00",
    "title": "Derived from this cycle's findings in `Core.lean`, `SelfSoundness.lean`,"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Numerical Monsters Bestiary (Bridges domain)\n\nThis research cycle established a verified core for digit-combinatorial\n\"monsters\": vampire numbers (`Vampire.lean`), the narcissistic / Harshad /\nKaprekar families plus a narcissistic finiteness bound (`Bestiary.lean`), and\ncross-monster bridges (`CrossMonster.lean`). The following conjectures are bold,\nprecise, and falsifiable, intended to drive the next cycles.\n\n## C1. Sharp narcissistic finiteness bound (tighten 60 \u2192 39)\nWe proved `narcissistic_lt : IsNarcissistic n \u2192 n < 10^60`. The true maximal\nnarcissistic number is the 39-digit `115132219018763992565095597973971522401`.\n**Conjecture.** `IsNarcissistic n \u2192 n < 10^39`, and this is sharp (the bound is\nattained). *Testable*: strengthen `pow_ineq` to the sharp crossover index and add\na `native_decide` certificate that the 39-digit champion is narcissistic while no\n40-digit one exists by the length argument.\n\n## C2. Infinitude vs. finiteness dichotomy across families\nHarshad numbers are infinite (every power of ten is Harshad, digit sum `1`),\nwhereas narcissistic numbers are finite (C1). **Conjecture.** A digit-family\ndefined by `n = \u03a3 f(d\u1d62)` with `f` *bounded* (independent of digit count) is\ninfinite, while one with `f` depending on the digit count (like narcissistic) is\nfinite. *Testable*: formalize \"digit-additive family with bounded weights\" and\nprove an infinitude theorem covering Harshad and digit-sum-fixed-point families\nin one stroke.\n\n## C3. Vampire density and the multiplicative/additive bridge\nWe showed vampirism does **not** imply the Harshad property\n(`vampire_not_harshad_6880`). **Conjecture.** Infinitely many vampire numbers are\nHarshad numbers, and infinitely many are not; moreover the proportion of vampires\n\u2264 N that are Harshad tends to a constant strictly between 0 and 1. *Testable\nfirst step*: exhibit an explicit infinite family of vampires (e.g. of the shape\n`(10^k\u00b7a)(10^k\u00b7b)` patterns) and decide the Harshad property along it.\n\n## C4. Pseudovampires and prime-fang vampires\nOur `vampire_not_prime` shows every vampire is composite. Refine the factor\nstructure. **Conjecture.** There exist infinitely many vampire numbers both of\nwhose fangs are prime (\"prime vampire numbers\", e.g. `117067 = 167 \u00d7 701`), and\nthe smallest is `117067`. *Testable*: extend `IsVampire` with a `fangsPrime`\npredicate, certify `117067`, and prove minimality over the relevant range by the\nsame `isVampireB`-style executable bridge used for `least_vampire`.\n\n## C5. Kaprekar fixed points and the 6174 vortex (cross to dynamics)\nBeyond Kaprekar *numbers* lies the Kaprekar *routine* `K(n) = (desc digits) \u2212\n(asc digits)`. **Conjecture.** Every 4-digit number with at least two distinct\ndigits reaches the fixed point `6174` under iteration of `K` in at most `7`\nsteps, and `6174` is its unique nonzero fixed point. *Testable*: define `K` as an\nexecutable function, prove `K 6174 = 6174` and uniqueness by `native_decide` over\n4-digit inputs, then bound the iteration depth \u2014 a genuine bridge from static\ndigit predicates to discrete dynamics.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2041",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "29ffc67c",
    "status": "available",
    "timestamp": "2026-06-17T04:32:01.860131+00:00",
    "title": "Verified core for digit-combinatorial"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Causal Loops in Category Theory\n\nFollow-up conjectures arising from `CausalLoops.lean` (Cycle 0 + Cycle 1).\nAll results in that file are fully proved (0 sorries, standard axioms only).\nEach direction below is stated to be **falsifiable** and **formalizable** in Lean 4 / Mathlib.\n\n## Summary of what is established\n\n- **Static loops collapse.** In a `Preorder` of events, `CausallyLooped a b := a \u2264 b \u2227 b \u2264 a`\n  is an equivalence relation, definitionally equal to `AntisymmRel (\u00b7 \u2264 \u00b7)`; quotienting\n  produces an acyclic (`PartialOrder`) causal structure, with loops being exactly the\n  fibers of the collapse map.\n- **Dynamic loops are self-consistent.** Every endomorphism of a finite nonempty type has a\n  periodic point (`novikov_self_consistency`). The grandfather process `not` has no fixed\n  point but is consistent at period 2. Idempotent loops always have a genuine fixed point;\n  reversible (bijective) loops are globally periodic.\n- **Composition loops back.** In any finite monoid / `End X` with finite hom, powers of any\n  element repeat, and some positive power is idempotent.\n\n---\n\n## Conjecture 1 \u2014 Minimal consistent period is bounded by the state count\n\n**Claim.** For a finite type `\u03b1` with `Nat.card \u03b1 = N` and any `e : \u03b1 \u2192 \u03b1`, there exists a\nself-consistent history of *minimal* positive period `p` with `1 \u2264 p \u2264 N`. Moreover the set of\nattainable minimal periods is exactly the set of cycle lengths of the eventual permutation of\n`e` on its periodic core. Formalize via `Function.minimalPeriod` and `Function.IsPeriodicPt`,\nproving `Function.minimalPeriod e x \u2264 Nat.card \u03b1` for any periodic point `x`.\n\n**Why bold/testable.** It upgrades \"a consistent history exists\" to a sharp quantitative bound,\ngiving a *spectrum of allowed periods* for a CTC of a given state-space size.\n\n## Conjecture 2 \u2014 The periodic core is the universal terminal sub-loop\n\n**Claim.** For finite `\u03b1` and `e : \u03b1 \u2192 \u03b1`, the periodic points `periodicPts e` form an\n`e`-invariant subset on which `e` restricts to a bijection (a disjoint union of cycles), and\nthis restricted system is the **terminal object** among all `(S, e|S)` with `e '' S \u2286 S` on\nwhich `e` is bijective. Categorically: the eventual image `\u22c2\u2099 e\u207f '' \u03b1` is the maximal\nreversible sub-loop. Formalize the eventual image `\u22c2 n, Set.range e^[n]` and prove `e` maps it\nbijectively onto itself.\n\n**Why bold/testable.** It identifies a canonical \"physical sector\" of a causal loop \u2014 the part\nthat is genuinely reversible \u2014 and characterizes it by a universal property.\n\n## Conjecture 3 \u2014 Loop collapse is functorial (Preorder \u2964 PartialOrder, left adjoint)\n\n**Claim.** The collapse `\u03b1 \u21a6 Antisymmetrization \u03b1 (\u00b7 \u2264 \u00b7)` extends to a functor from the\ncategory of preorders (causal structures) and monotone maps to the category of partial orders\n(acyclic causal structures), and it is **left adjoint** to the inclusion. I.e. paradox-removal\nis the universal acyclic approximation of a causal order. Formalize using Mathlib's\n`Preorder`/`PartialOrder` bundled categories and `Antisymmetrization`'s functorial action\n(`Preorder_to_PartialOrder`), proving the adjunction unit/counit laws.\n\n**Why bold/testable.** Turns the ad hoc \"collapse\" into a precise universal construction; the\nadjunction is either provable or refutable by exhibiting a counterexample to the universal map.\n\n## Conjecture 4 \u2014 Consistency amplitude: counting self-consistent histories\n\n**Claim.** For finite `\u03b1` and `e : \u03b1 \u2192 \u03b1`, the number of fixed points of `e^[n]` equals the\nnumber of length-`n` closed orbits weighted by divisors:\n`Fintype.card (Function.fixedPoints e^[n]) = \u2211 d \u2223 n, d \u00b7 (#cycles of length d)`. In\nparticular the \"consistency partition function\" `Z(n) := card (fixedPoints e^[n])` is\nmultiplicative-structured and strictly positive for all `n` divisible by `lcm` of the cycle\nlengths. This is the categorical analogue of a CTC path integral over self-consistent\nhistories.\n\n**Why bold/testable.** A concrete combinatorial identity (M\u00f6bius/divisor sum over cycle\nlengths) that can be proved in Mathlib and checked against `decide` on small `e`.\n\n## Conjecture 5 \u2014 Idempotent stabilization rate (Suschkewitsch threshold)\n\n**Claim.** For a finite monoid `M` with `Nat.card M = N`, every element `a` reaches an\nidempotent power within exponent `\u2264 N`: there is `1 \u2264 n \u2264 N` with `IsIdempotentElem (a^n)`,\nand more sharply `a^(N!)` is idempotent for every `a`. Equivalently, the \"index + period\" of\nevery element is `\u2264 N`. Formalize by bounding the pigeonhole indices `i < j \u2264 N` in\n`composition_loops_back_monoid` and strengthening `idempotent_power_of_finite` to an explicit\nbound.\n\n**Why bold/testable.** Converts the existence statement `idempotent_power_of_finite` into an\neffective bound \u2014 a measurable \"thermalization time\" for a categorical loop process; refutable\nby any monoid whose elements need exponent `> N`.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2042",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "1cfdf3f4",
    "status": "available",
    "timestamp": "2026-06-17T05:04:17.422084+00:00",
    "title": "Follow-up conjectures arising from `CausalLoops.lean` (Cycle 0 + Cycle 1)."
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Non-Well-Founded Proofs in Geometry\n\nResearch theme: **\"Non-Well-Founded Proofs: Proofs That Reference Themselves\"**, domain **Geometry**.\n\nAcross two cycles we established the thesis that *self-reference / non-well-foundedness =\nself-similarity*, realized by two formal engines \u2014 **coinductive data** (`Stream'`, `corec`)\nand **contraction fixed points** (`x* = f x*`) \u2014 and unified the geometric series, the affine\nattractor, and the (golden / metallic) continued fractions as one phenomenon: *a quantity\nthat is the unique solution of its own equation*. All results live, fully verified, in\n`SelfSimilar.lean`.\n\n**Status of earlier conjectures (now closed):**\n- **C3 (bisimulation rigidity)** \u2014 PROVED (`selfSimilar_unique`): the self-similarity law\n  `map (\u00b7 * r) s = s.tail` with fixed head characterizes `geomStream a r` uniquely.\n- **C4 (metallic ratios)** \u2014 PROVED (`metallicRatio_sq`, `metallicRatio_selfReferential`,\n  `metallicGnomon_selfSimilar`, `metallicRatio_one`): the golden lemmas generalize to the\n  whole family `\u03c6_m = (m + \u221a(m\u00b2+4))/2`.\n- **C5 (similarity dimension)** \u2014 core PROVED (`simDim_spec`, `simDim_pos`): `D = log k/log(1/r)`\n  solves `k\u00b7r^D = 1` and is positive; *monotonicity remains open* (see D3 below).\n\nThe following are the bold, falsifiable conjectures for subsequent cycles.\n\n## Conjecture D1 \u2014 IFS attractor in \u211d\u207f via Banach (multidimensional self-reference)\nFor an affine contraction `f x = A x + b` on `EuclideanSpace \u211d (Fin n)` with operator norm\n`\u2016A\u2016 < 1`, there is a **unique** self-referential point `x* = f x*`, every orbit\n`f^[k] x\u2080 \u2192 x*`, and `\u2016f^[k] x\u2080 - x*\u2016 \u2264 \u2016A\u2016^k \u00b7 \u2016x\u2080 - x*\u2016`.\n*Test:* lift `affine_fixed`, `affine_fixed_unique`, `affine_iterate_error`,\n`affine_tendsto_fix` from `\u211d` to `\u211d\u207f`, ideally through Mathlib's `ContractingWith`/`edist`\nAPI. Falsified if no `\u211d\u207f` statement closes under just `\u2016A\u2016 < 1`.\n\n## Conjecture D2 \u2014 Coinductive geometric trees and self-similar measure\nDefine an infinite binary **coinductive tree** whose node at depth `d` carries scale `r^d`.\nConjecture: the depth-`d` level holds `2^d` copies of scale `r^d`, and the total-measure\nrecursion `M = 1 + 2 r \u00b7 M` has the self-referential closed form `M = 1/(1 - 2r)` for\n`2r < 1` \u2014 the tree analogue of `geometricSum_selfReferential`. *Test:* build the tree with\n`corec`, prove the level identity by induction and the measure equation by the fixed-point\nuniqueness pattern of `geometricSum_unique`.\n\n## Conjecture D3 \u2014 Monotonicity of the similarity dimension\nThe similarity dimension `simDim k r = log k / log(1/r)` is strictly increasing in `k`\n(for `0 < r < 1`) and strictly increasing in `r` on `(0,1)` (for `k \u2265 2`). Moreover it is the\n*unique* real solving `k\u00b7r^D = 1`. *Test:* prove both monotonicities and uniqueness of the\nexponent; falsified if either monotonicity reverses on any admissible `(k, r)`.\n\n## Conjecture D4 \u2014 Mixed-ratio IFS and the Moran equation\nFor a finite list of ratios `r\u2081,\u2026,r_k \u2208 (0,1)`, the similarity dimension is the unique `D`\nsolving the **self-referential Moran equation** `\u2211\u1d62 r\u1d62^D = 1`. Conjecture: the left side is\ncontinuous and strictly decreasing in `D`, equals `k > 1` at `D = 0` and `\u2192 0` as `D \u2192 \u221e`, so\na unique root exists, and it reduces to `simDim` when all `r\u1d62 = r`. *Test:* prove existence,\nuniqueness, and the uniform-ratio reduction via the intermediate value theorem + strict\nantitonicity.\n\n## Conjecture D5 \u2014 Banach contraction on the space of compact sets (Hutchinson attractor)\nThe IFS operator `F(K) = \u22c3\u1d62 f\u1d62(K)` on the complete metric space of nonempty compact subsets\nof `\u211d\u207f` under the **Hausdorff metric** is a contraction when each `f\u1d62` is, hence has a unique\nself-referential compact set `K* = F(K*)` \u2014 the genuine fractal attractor, the set-level\n`x* = f x*`. *Test:* assemble the Hausdorff-metric completeness + contraction estimate and\ninvoke Banach; falsified if the operator fails to contract under `max\u1d62 Lip(f\u1d62) < 1`.\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2043",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "78c9ab60",
    "status": "available",
    "timestamp": "2026-06-17T05:40:43.553956+00:00",
    "title": "Research theme: **\"Non-Well-Founded Proofs: Proofs That Reference Themselves\"**,"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 The Hodge Conjecture for Neural Networks\n\nDerived from the cycle in `NeuralHodgeConjecture.lean` and `NeuralHodgeCatalogLink.lean`,\nwhich proved:\n\n* `pl_hodge_decomposition` / `pl_hodge_span`: every PL chain on a ReLU decision surface is\n  a `\u2124`-combination of hyperplane sections (the \"trivial existence half\" of the Hodge\n  conjecture for these surfaces);\n* `regionBound_recurrence`, `regionBound_le_two_pow`, `regionBound_eq_two_pow`,\n  `regionBound_mono_width`: the Zaslavsky region/Betti budget `\u03a3_{i\u2264n} C(m,i)` for one\n  ReLU layer, with its Pascal recurrence and the `2^m` ceiling;\n* `reluHodge_totalBetti` (and its catalog avatar `reluHodgeDiamond_totalDim_eq`): the\n  extremal total Betti number of a ReLU decision surface is **exactly** `2^{w\u2081}\u00b72^{wL}\u00b7mid`.\n\n---\n\n## Conjecture 1 \u2014 Sharpness of the `2^{w\u2081+wL}` Betti ceiling\n\nThe total Betti number of a ReLU decision surface with first/last hidden widths `w\u2081, wL`\nand middle-width product `mid` is **at most** `2^{w\u2081}\u00b72^{wL}\u00b7mid`, and this is attained by\na generic-weight network in input dimension `n \u2265 w\u2081 + wL`.\n\n**The key insight is** that `reluHodge_totalBetti` computes the *saturated* diamond exactly\nas `2^{w\u2081}\u00b72^{wL}\u00b7mid`, while `regionBound_eq_two_pow` shows the per-layer count saturates\nto `2^m` precisely when the ambient dimension is large; combining the two layers should turn\nthe upper bound into an equality in high dimension.\n\n**Why now?** Both halves (exact saturated value, dimensional saturation of one layer) are\nnow formal lemmas in this file, so the remaining work is purely the genericity/transversality\nargument, which is decoupled from the combinatorics.\n\n## Conjecture 2 \u2014 A K\u00fcnneth product law for stacked ReLU blocks\n\nFor a composition of two ReLU sub-networks the total Betti number is *sub-multiplicative*:\n`B(f \u2218 g) \u2264 B(f) \u00b7 B(g)`, with equality when the blocks are in \"general position\".\n\n**The key insight is** that `reluHodge_totalBetti` already factors as a product\n`(\u03a3_p C(w\u2081,p))\u00b7(\u03a3_q C(wL,q))\u00b7mid` via `Finset.sum_mul_sum`; the same factorisation engine\nshould govern how Betti budgets multiply across composition boundaries.\n\n**Why now?** The factored form is exactly the proof structure used for\n`reluHodge_totalBetti`, so the product law is a structural generalisation of an\nalready-formalised identity rather than a new technique.\n\n## Conjecture 3 \u2014 The Zaslavsky recurrence is the unique solution to depth refinement\n\nAny width-monotone, dimension-graded region count satisfying\n`R(m+1,n+1) = R(m,n+1) + R(m,n)` with `R(0,n)=1` equals `regionBound`, hence the\nbinomial-sum formula is forced by adding one neuron at a time.\n\n**The key insight is** that `regionBound_recurrence` together with `regionBound_mono_width`\npins down a two-variable Pascal-type recurrence whose only solution is `\u03a3_{i\u2264n} C(m,i)`;\nuniqueness should follow by double induction.\n\n**Why now?** The recurrence and monotonicity are both proved here, so the conjecture reduces\nto a uniqueness-of-recurrence argument with no missing analytic input.\n\n## Conjecture 4 \u2014 Algebraic-cycle rank lower bound via the catalog Euler characteristic\n\nThrough `reluHodgeDiamond` the decision surface acquires a catalog `HodgeDiamond`, hence an\nEuler characteristic `eulerChar`; we conjecture `|eulerChar| \u2264 reluTotalBetti` with the gap\nmeasuring the number of *independent* algebraic cycles needed to represent all classes.\n\n**The key insight is** that `reluHodgeDiamond_totalDim_eq` already lands the surface inside\nthe catalog's `HodgeEPolynomial` machinery, where `eulerChar` and `totalDim` are defined on\nthe same diamond, so their comparison is a direct two-sum inequality.\n\n**Why now?** The bridge `NeuralHodgeCatalogLink.lean` makes both invariants available on one\nobject for the first time, so the inequality can be stated and attacked without rebuilding\nany Hodge-diamond infrastructure.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2044",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6fb69121",
    "status": "available",
    "timestamp": "2026-06-17T06:17:33.490691+00:00",
    "title": "Derived from the cycle in `NeuralHodgeConjecture.lean` and `NeuralHodgeCatalogLi"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Paradoxes as Theorems (Liar, Berry, Russell, Made Consistent)\n\nDerived from the cycle whose verified results live in\n`Catalog/Logic/ParaconsistentParadox.lean` (foundations) and\n`Catalog/Computation/ParadoxesAsTheorems.lean` (construction + necessity), and\nbuilding on `Catalog/Logic/ParadoxSelfSoundness.lean`.\n\nThis cycle established, with zero sorries, a single finite four-valued\nparaconsistent theory `paradoxModel` in which the Liar, Russell, and Berry\nparadoxes are simultaneously *designated theorems*, the theory is non-trivial and\nnon-explosive, and it certifies its own soundness; and it proved that a *sound*\nprovable Liar forces a genuine glut `B` (gaps `N` are insufficient).\n\nThe following conjectures are bold, falsifiable refinements.\n\n---\n\n## C1. Glut Minimality / Inconsistency Lower Bound\n\n**Conjecture.** Any sound paraconsistent theory that proves the Liar, a Russell\nsentence, and a Berry sentence as *syntactically distinct* designated theorems\nhas inconsistency degree at least 3, and 3 is attainable.\n\n**The key insight is** that `provable_liar_is_glut` upgrades each of the three\nself-referential paradoxes from \"non-classical\" (`B` or `N`) to \"glut\" (`B`)\nonce soundness and provability are imposed, so three distinct paradoxes must\ncontribute three distinct dialetheias \u2014 strengthening\n`two_paradoxes_force_degree_two` from 2 to 3.\n\n**Why now?** We already have the degree-\u22652 bound via `Finset.one_lt_card` and the\nglut-forcing lemma; the missing step is a Berry sentence that is *intrinsically*\na third glut rather than reusing a Liar fixed point, which the\n`berry_definability_bound` collision can be made to witness.\n\n---\n\n## C2. No Sound Paracomplete (Gap-Only) Theory Proves the Liar\n\n**Conjecture.** In any three-valued logic whose only non-classical value is a gap\n`N` (paracomplete, no glut), the Liar can never be a sound provable theorem; i.e.\nremoving `B` from `BelnapVal` makes `paradoxes_as_theorems` unsatisfiable.\n\n**The key insight is** that `provable_liar_is_glut` already closes the gap escape\nfor the four-valued case; the conjecture says this is not an artifact of the\nextra value `B` being available but a hard impossibility once `B` is deleted \u2014\nsoundness designates only `T`, and a Liar cannot be `T`.\n\n**Why now?** The proof template is the contrapositive of `provable_liar_is_glut`\ncombined with `classical_no_liar`; the only new ingredient is formalizing a\ngap-only sublogic `Fin 3` and showing its designated set is `{T}`.\n\n---\n\n## C3. Explosion is the Unique Obstruction to Consistency\n\n**Conjecture.** For a finite four-valued theory with at least one glut, the\ntheory is non-trivial (some sentence unprovable) **iff** it rejects explosion.\nEquivalently, `HasExplosion` is logically equivalent to triviality in the\npresence of a dialetheia.\n\n**The key insight is** that `explosion_collapses_paradoxModel` shows explosion \u21d2\ntriviality, and `paradoxModel_rejects_explosion` shows the converse direction in\none model; the conjecture promotes this to a biconditional characterization,\nlocating *all* of consistency in the failure of ex falso.\n\n**Why now?** Both implications already exist as separate theorems for the witness\nmodel; generalizing to \"any theory with a glut\" needs only the observation that a\nglut plus explosion designates everything, which is exactly\n`explosion_with_liar_trivializes`.\n\n---\n\n## C4. Self-Soundness is Impossible Without Gluts\n\n**Conjecture.** No consistent *classical or paracomplete* theory containing its\nown truth predicate can prove its own soundness (G\u00f6del/Tarski barrier), but every\nsufficiently expressive *paraconsistent* theory with a designated soundness\nsentence can \u2014 and the dividing line is precisely the availability of the glut\n`B`.\n\n**The key insight is** that `paradoxSelfSound_proves_own_soundness` evades the\nsecond-incompleteness barrier not by weakness but by tolerating the controlled\ncontradiction that makes the soundness sentence designated; the obstruction in\nclassical logic is exactly the explosion that gluts disarm.\n\n**Why now?** `SelfSoundTheory` and the concrete `paradoxSelfSound` give a working\npositive instance; the negative half can be formalized by transporting\n`classical_no_liar` to a self-referential soundness sentence.\n\n---\n\n## C5. Functoriality of Paradox Endomorphisms\n\n**Conjecture.** The Belnap endomorphisms fixing the glut and gap values\n(`ParadoxEndomorphism` in `ParadoxSelfSoundness`) act on the set of designated\nself-referential theorems, and this action preserves both provability and\ninconsistency degree; hence \"paradoxicality\" is an invariant of the endomorphism\nmonoid.\n\n**The key insight is** that `paradox_endo_preserves_fixed_point` shows these maps\nsend negation fixed points to negation fixed points, so they map Liars to Liars\nand gluts to gluts \u2014 turning the ad hoc paradox catalogue into the orbit of a\ngroup action.\n\n**Why now?** The endomorphism monoid (`ParadoxEndomorphism.comp`, `negEndomorphism`)\nis already defined and its fixed-point preservation proved; the next step is to\nlet it act on `ParaconsistentTheory` truth assignments and check `isSound`/\n`inconsistencyDegree` are invariants \u2014 a direct, mechanizable extension.\n",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_2046",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "11262eec",
    "status": "available",
    "timestamp": "2026-06-17T07:30:20.164987+00:00",
    "title": "Derived from the cycle whose verified results live in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Chip-Firing, Divisors, and Graph Riemann\u2013Roch\n\nThese conjectures are derived from the verified results in\n`Tropical/ChipFiring/{Defs,Theorems,CompleteGraph,Rank}.lean`. Each is falsifiable in Lean\non top of the divisor backbone already formalized (`LinEquiv`, `Winnable`, `divisorDegree`,\n`canonicalDivisor`, `genus`, `RankGe`, `BNrank`).\n\nThis cycle's findings that seed them:\n- `canonicalDivisor_degree`: `deg K_G = 2g \u2212 2` for every finite graph (handshake lemma).\n- `two_genus_complete`/`canonical_complete_coeff`: for `K_n`, `g = (n\u22121)(n\u22122)/2` and every\n  vertex of `K` carries exactly `n \u2212 3` chips \u2014 correcting the mission's \"`n \u2212 2`\" claim.\n- `rr_canonical_prediction`: the RR right-hand side at `D = K` collapses to `g \u2212 1`.\n- `BNrank_zero` / `BNrank_neg_degree`: the boundary values `l(0) = 0` and `l(D) = \u22121` for\n  `deg D < 0`, which resolve the apparent paradox `l(K_{K_3}) = 0 = g(K_3) \u2212 1`.\n\n---\n\n## Conjecture 1 \u2014 Riemann inequality `l(D) \u2265 deg D \u2212 g`\n**Statement.** For every divisor `D` on a finite connected graph `G`,\n`BNrank G D \u2265 divisorDegree D \u2212 genus G`. Equivalently, every divisor of degree `\u2265 g` is\nwinnable.\n\n**The key insight is** that winnability is governed by Dhar's burning algorithm: a\n`q`-reduced representative exists in every linear equivalence class, and its `q`-coefficient\nis `\u2265 0` exactly when `deg D \u2265 g`. This converts a global rank statement into a local,\nalgorithmic non-negativity check that the `Winnable` predicate already exposes.\n\n**Why now?** We have `Winnable`, `LinEquiv` (an `Equivalence`), and the degree obstruction\n`winnable_degree_nonneg` proved. The only missing primitive is the reduced-divisor normal\nform; building it on the existing `lap` Laplacian closes the \"Riemann half\" without any new\nfoundational layer.\n\n---\n\n## Conjecture 2 \u2014 Full Baker\u2013Norine duality `l(D) \u2212 l(K\u2212D) = deg D + 1 \u2212 g`\n**Statement.** For every divisor `D`, `BNrank G D \u2212 BNrank G (canonicalDivisor G - D)\n= divisorDegree D + 1 \u2212 genus G`.\n\n**The key insight is** that the symmetric \"rank of `D`\" and \"rank of `K \u2212 D`\" are dual\nunder the involution `E \u21a6 K \u2212 E` on the set of non-winnable-witness divisors; the\nBaker\u2013Norine proof reduces the equality to a counting bound on maximal non-special\ndivisors. Our `canonicalDivisor_degree` already supplies the `deg K = 2g \u2212 2` term that\nmakes the two sides numerically consistent at `D = K` (`rr_canonical_prediction`).\n\n**Why now?** The `BNrank` definition with `RankGe` downward-closed (`rankGe_antitone`) gives\na well-defined integer rank; combined with Conjecture 1 the duality becomes a finite\ncombinatorial bookkeeping argument rather than an analytic one.\n\n---\n\n## Conjecture 3 \u2014 The canonical rank of `K_n` is exactly `g \u2212 1`\n**Statement.** `BNrank (Kn n) (canonicalDivisor (Kn n)) = genus (Kn n) - 1`\nfor all `n \u2265 1`, i.e. `l(K_{K_n}) = (n\u22121)(n\u22122)/2 \u2212 1`.\n\n**The key insight is** that on the complete graph every effective divisor of degree `\u2264 g\u22121`\nis \"spread thin enough\" that subtracting it from the uniform canonical divisor `(n\u22123)` per\nvertex still leaves a winnable position, while degree `g` witnesses fail by the degree\nobstruction \u2014 so the maximal `k` in `RankGe` is precisely `g \u2212 1`.\n\n**Why now?** We have already computed both `deg K = n(n\u22123)` and `g = (n\u22121)(n\u22122)/2`, and\nproved `l(0) = 0`. Conjecture 3 is exactly the `D = K` instance of Conjecture 2, so it is\nthe natural first stress-test: it must equal `g \u2212 1`, and any deviation immediately\nfalsifies the duality.\n\n---\n\n## Conjecture 4 \u2014 Gonality of `K_n` equals `n \u2212 1`\n**Statement.** The minimal degree of a winnable divisor of positive rank on `K_n` is\n`n \u2212 1`; i.e. the smallest `d` with a degree-`d` divisor `D` such that `BNrank (Kn n) D \u2265 1`\nis `d = n \u2212 1`.\n\n**The key insight is** that a rank-`1` divisor must dominate, up to firing, the\n\"all-but-one-vertex\" configuration, and on the totally symmetric `K_n` the cheapest such\nconfiguration places one chip on each of `n \u2212 1` vertices \u2014 directly tying gonality to the\nclique number.\n\n**Why now?** `RankGe G D 1` is already definable and the single-vertex divisors\n`singleVertexDivisor` used in `Rank.lean` give ready-made witnesses; the lower bound reuses\n`winnable_degree_nonneg`, so both directions sit on existing infrastructure.\n\n---\n\n## Conjecture 5 \u2014 Degree is a *complete* invariant for winnability on `K_n` above genus\n**Statement.** For `K_n`, two divisors `D, E` with `deg D = deg E \u2265 g` are *both* winnable;\nmoreover for `deg D \u2265 g` winnability depends only on the degree (never on placement).\n\n**The key insight is** that `K_n`'s automorphism group is the full symmetric group `S_n`, so\nthe orbit of any sufficiently large divisor under chip-firing + symmetry saturates all\nplacements; placement-independence is the combinatorial shadow of \"all line bundles of\ndegree \u2265 g on a curve are base-point free\".\n\n**Why now?** Linear equivalence is already proved to be an `Equivalence` and degree is a\nclass invariant (`linEquiv_degree`); the conjecture is a sharp, easily-falsifiable\nstrengthening (a single placement-dependent counterexample at degree `g` would kill it),\nmaking it an ideal adversarial probe for Conjecture 1.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2047",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "77489d34",
    "status": "available",
    "timestamp": "2026-06-17T08:42:13.092052+00:00",
    "title": "These conjectures are derived from the verified results in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Viral Information Topology\n\nThis research cycle (cold start, Logic domain) formalized memetic/viral spread as\na forward-chaining **consequence operator** and established its order-theoretic,\nlogical, and topological structure.\n\n## Results established this cycle\n\n- `Core.lean` \u2014 viral closure = least fixed point of the monotone spread\n  operator; it is a closure operator (extensive/monotone/idempotent); the\n  viral-closed sets form a **Moore family** (`isViralClosed_iInter`,\n  `closure_eq_iInter`); and the **viral path theorem** `derivable_iff_mem_closure`\n  identifies the lattice-theoretic closure with inductive logical derivability.\n- `Thresholds.lean` \u2014 concrete experiments: a total cascade on `\u2115`\n  (`line_closure_univ`); failure of the Kuratowski axioms `cl \u2205 = \u2205`\n  (`closure_empty_ne_empty`) and finite additivity (`kuratowski_additivity_fails`);\n  and **viral compactness** (`viral_compactness`) for finite-premise contagions.\n- `GraphContagion.lean` \u2014 the **topological dichotomy**: a *simple* (single-premise,\n  graph-reachability) contagion satisfies all four Kuratowski axioms\n  (`simple_isKuratowski`). Hence viral spread is topological **iff** it is pairwise;\n  synergy (premises of size \u2265 2) is the exact obstruction.\n\n## Conjectures for follow-up cycles\n\n### C1 \u2014 Alexandrov correspondence (topology \u21c4 preorder)\nFor a simple contagion `C`, the viral closure is an Alexandrov topological closure;\nconjecture that it coincides with the closure of the **reachability preorder** of\nthe underlying digraph `a \u2192 c` (edges = rules), and that virally-closed sets are\nexactly the down-sets (or up-sets) of that preorder. Testable: define the preorder\n`ReachLE C` as the reflexive-transitive closure of the edge relation and prove\n`closure C S = {v | \u2203 s \u2208 S, ReachLE C s v}` and a lattice isomorphism between\nviral-closed sets and the order ideals.\n\n### C2 \u2014 Synergy arity hierarchy is strict\nDefine `arity(C) = sup` of premise sizes. Conjecture a strict expressive\nhierarchy: for each `k \u2265 2` there is a contagion of arity `k` whose closure\noperator is **not** realizable by any contagion of arity `< k` on the same\ncarrier (measured by the lattice of closed sets). `kuratowski_additivity_fails`\nis the `k = 2 \u2260 1` base case. Testable via a \"`k`-threshold\" gadget on `Fin (k+1)`.\n\n### C3 \u2014 Viral compactness characterizes finitary contagions\nWe proved finite premises \u21d2 compactness. Conjecture the **converse / sharpness**:\nif a contagion has a rule with an infinite premise that is \"irredundant\", then\ncompactness fails \u2014 there is a seed `S` and agent `v` with `v \u2208 cl S` but\n`v \u2209 cl S\u2080` for every finite `S\u2080 \u2286 S`. This would make `viral_compactness`\nan exact characterization of finitary spread, mirroring logical compactness.\n\n### C4 \u2014 Galois / antitone duality with \"firewalls\"\nDefine a **firewall** as a set `F` such that removing `F` makes a target `t`\nunreachable from a seed `S` (`t \u2209 cl_{C\u2216F} S`). Conjecture a Galois connection /\nmin-cut\u2013max-flow duality between minimal firewalls and the family of derivation\n\"paths\" (transmission chains) to `t`, generalizing Menger's theorem from simple\ngraphs (C1) to hypergraph contagions. Testable first on simple contagions where\nit should reduce to classical vertex-cut duality.\n\n### C5 \u2014 Monotone speed-up and fixed-point iteration depth\nDefine the **viral depth** `d(C,S,v)` as the least `n` with `v \u2208 (spreadHom C S)^[n] \u2205`\n(the derivation-tree height). Conjecture: on a finite carrier of size `N`, the lfp\nis reached in `\u2264 N` iterations (`closure C S = (spreadHom C S)^[N] \u2205`), and depth\nequals the longest transmission chain. Testable via `OrderHom.lfp` iteration bounds\nand the `Derivable` height; connects \"viral reach time\" to chain length.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2048",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "8c9d3809",
    "status": "available",
    "timestamp": "2026-06-17T09:17:22.315956+00:00",
    "title": "This research cycle (cold start, Logic domain) formalized memetic/viral spread a"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Crystallographic Groups and Music: The Wallpaper Groups of Rhythm\n\nThis cycle established a self-contained theory of the **symmetry groups of cyclic\nrhythms** via the dihedral action of `DihedralGroup n` on `Finset (ZMod n)`\n(beat positions), proved in:\n\n* `Catalog/Computation/RhythmWallpaperGroups.lean`\n  - `card_symmetryGroup_dvd` \u2014 Lagrange: `|symmetryGroup S| \u2223 2n`.\n  - `card_rotationPeriods_dvd` \u2014 rhythmic crystallographic restriction: `|rotationPeriods S| \u2223 n`.\n  - `rotationPeriods_realizable` \u2014 every divisor `d \u2223 n` is realised as a rotation-symmetry order.\n* `Catalog/Computation/RhythmScaleSymmetry.lean`\n  - `card_transpositions_mul_card_rotPeriods` \u2014 orbit\u2013stabiliser: `#transpositions \u00b7 #periods = n`.\n  - `decide`-verified symmetry orders of the whole-tone (6), augmented (3),\n    octatonic (4), diatonic (1), and chromatic (12) pitch-class sets in `ZMod 12`.\n\nThe following conjectures are precise, falsifiable, and computationally testable\nfor small `n` (via `decide`) before any general proof attempt.\n\n---\n\n## Conjecture 1 (Full dihedral realisability)\n**Every subgroup `H \u2264 DihedralGroup n` is the symmetry group of some rhythm.**\nThat is, `\u2200 H : Subgroup (DihedralGroup n), \u2203 S : Finset (ZMod n), symmetryGroup n S = H`.\nThis strengthens `rotationPeriods_realizable` (which only realises the *rotation*\norders) to the full dihedral lattice, including reflection (palindromic) symmetry.\n*Test*: enumerate subgroups of `DihedralGroup n` for `n \u2264 8` and search for a\nrealising `S` by `decide`. *Risk*: small `n` may have unrealisable subgroups\n(e.g. a lone reflection with no compatible rotation), in which case the corrected\nconjecture characterises the realisable ones as exactly the stabiliser-closed\nsubgroups.\n\n## Conjecture 2 (M\u00f6bius enumeration of rhythmic crystal classes)\n**The number of rhythms in `ZMod n` whose rotation-period group has order exactly\n`d` (for `d \u2223 n`) is `\u2211_{e \u2223 (n/d)} \u03bc(e) \u00b7 2^{(n/d)/e \u00b7 ... }`** \u2014 i.e. a clean\nM\u00f6bius-inversion / necklace-counting formula governs the distribution of symmetry\norders. Concretely, with `A\u2099(d)` = #{S : rotPeriodsFinset n S |>.card = d}, conjecture\n`\u2211_{d \u2223 n} A\u2099(d) = 2\u207f` (trivial) **and** that `A\u2099(d)` is given by M\u00f6bius inversion\nof `d \u21a6 2^{n/d}`. *Test*: tabulate `A\u2099(d)` by brute force (`decide`) for `n \u2264 12`\nand fit against the M\u00f6bius formula.\n\n## Conjecture 3 (Two-dimensional polyrhythms and the genuine 17 wallpaper groups)\n**Define rhythms on the torus `ZMod m \u00d7 ZMod n` with the full planar\ncrystallographic action (translations, the rotation `(x,y) \u21a6 (-x,-y)`, and the\nreflections), and conjecture that exactly the toroidal quotients of the 17\nwallpaper groups arise as symmetry groups.** This is the literal realisation of\nthe project title: 1D rhythm gave dihedral (frieze-like) symmetry; the 2D\npolyrhythmic grid should expose wallpaper-group structure. *Test*: build the\n`MulAction` of the relevant point group on `Finset (ZMod m \u00d7 ZMod n)` and\nclassify stabilisers for small `m, n` by `decide`.\n\n## Conjecture 4 (Euclidean / maximally even rhythms)\n**The Euclidean rhythm `E(k, n)` (the maximally even distribution of `k` onsets in\n`n` beats, \u00e0 la Bjorklund) has rotation-period group of order exactly `gcd(k, n)`.**\nEquivalently it has `n / gcd(k,n)` distinct transpositions. *Test*: implement\n`E(k,n)` as a `Finset (ZMod n)` and check `rotPeriodsFinset n (E k n) |>.card = Nat.gcd k n`\nby `decide` for all `k \u2264 n \u2264 16`. A proof would connect our orbit\u2013stabiliser law\nto the three-distance/Steinhaus theorem.\n\n## Conjecture 5 (Spectral characterisation of rhythmic symmetry)\n**A rhythm `S \u2286 ZMod n` has rotation-period group of order `d` (with `d \u2223 n`) iff\nits discrete Fourier transform `\u015c` (the indicator's DFT over `ZMod n`) is supported\non the subgroup of multiples of `n/d`.** This recasts the crystallographic\nrestriction as a frequency-support statement (a Computation-domain bridge to the\nnumber-theoretic transform / `Polynomial (ZMod n)` evaluation). *Test*: for\n`n \u2264 12`, compute supports of `\u015c` and compare with `rotPeriodsFinset` by `decide`\nover `\u211a`-valued or root-of-unity DFTs.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2049",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "6493a7ff",
    "status": "available",
    "timestamp": "2026-06-17T09:50:51.074776+00:00",
    "title": "Self-contained theory of the **symmetry groups of cycli"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Retrocausal Mathematics: Where Effects Precede Causes\n\nDerived from this cycle's verified results in\n`Catalog/Logic/RetrocausalHeyting.lean` and `Catalog/Bridges/RetrocausalCPTBridge.lean`.\n\nThis cycle established three load-bearing facts:\n- **(TEM)** The temporal excluded middle `(a \u2228 \u00aca)\u1d9c\u1d9c = \u22a4` holds in *every* Heyting\n  algebra (`temporal_excluded_middle`).\n- **(LEM\u2194DNE)** Rejecting the law of excluded middle is *equivalent* to rejecting\n  double-negation elimination (`lem_iff_dne`) \u2014 so any LEM-free logic is genuinely\n  intuitionistic.\n- **(CPT bridge)** An Osterwalder\u2013Schrader time reflection `\u03b8` (`\u03b8 \u2218 \u03b8 = id`) composed\n  with negation is an order-reversing involution, making the QFT proposition algebra a\n  `RetrocausalHeyting` whose De Morgan laws are the abstract Logic lemmas\n  (`cpt_yields_retrocausal_logic`).\n\n---\n\n## Conjecture 1 \u2014 Retrocausal Glivenko transfer for sequent provability\nA formula `\u03c6` is provable in a retrocausal (intuitionistic) sequent calculus equipped\nwith a time-reversal involution iff its CPT-double-negation `(\u03c6 \u2228 \u00ac\u03c6)\u1d9c\u1d9c`-closure is\nprovable classically, and the time-reversal acts as a provability-preserving De Morgan\nduality on the Lindenbaum\u2013Tarski algebra.\n\n- **The key insight is...** that `temporal_excluded_middle` shows the *doubly negated*\n  excluded middle is a theorem rather than an axiom, so Glivenko's theorem should lift to\n  the retrocausal setting with the involution `rev` permuting the De Morgan dual pair.\n- **Why now?** We already have `lem_iff_dne` and `rev_sup`/`rev_inf` proved with 0\n  sorries; the Lindenbaum\u2013Tarski algebra is a Heyting algebra, so the transfer is a\n  finite step from the present lemmas.\n\n## Conjecture 2 \u2014 Fixed points of CPT reversal are a Boolean subalgebra\nFor a reflection-positive QFT, the propositions fixed by the CPT connective\n`cptReversal R S = S` form a sublattice on which the law of excluded middle is restored,\ni.e. a maximal *classical* island inside the retrocausal logic.\n\n- **The key insight is...** that `cptReversal_involutive` gives a `\u2124/2` action whose\n  fixed-point set of an antitone involution is closed under the De Morgan-swapped\n  operations `rev_sup`/`rev_inf`, forcing self-duality and hence Boolean behaviour.\n- **Why now?** The involution and its De Morgan laws are already verified on `Set V`;\n  characterizing `{S : cptReversal R S = S}` only requires the fixed-point algebra of an\n  existing involution.\n\n## Conjecture 3 \u2014 LEM-failure is a strict obstruction to Boolean carriers\nEvery retrocausal Heyting algebra in which LEM fails at even one element is necessarily\nnon-Boolean, and conversely the `Fin (n+3)` chains give an infinite family of\nLEM-failing retrocausal algebras with strictly growing failure sets.\n\n- **The key insight is...** that `lem_fails_of_dne_fails` ties LEM failure to genuine\n  intuitionism (DNE failure), and the explicit `Fin 3` model (`retro_lem_fails`) already\n  realizes one failure point with a working time-reversal instance.\n- **Why now?** The `Fin 3` `RetrocausalHeyting` instance is already constructed; the\n  generalization to `Fin (n+3)` is a parametric replay of the same `fin_cases` proofs.\n\n## Conjecture 4 \u2014 Reflection positivity bounds the \"retrocausal defect\"\nFor a reflection-positive form `R`, the quantity measuring how far a proposition is from\nCPT-self-duality is controlled by the physical pairing `B (\u03b8 v) v \u2265 0`; positivity of the\nform bounds the size of the non-classical (LEM-violating) region of the induced logic.\n\n- **The key insight is...** that `cpt_yields_retrocausal_logic` already couples the\n  physics inequality `reflection_pos` with the logical involution in one statement;\n  promoting the conjunction to a quantitative inequality links OS positivity to logical\n  non-classicality.\n- **Why now?** Both halves (the inequality and the involution) are proved and live in the\n  same theorem; only a measure of \"defect\" must be defined to state the bound.\n\n## Conjecture 5 \u2014 Cryptographic one-way functions from retrocausal asymmetry\nThe order-asymmetry of a retrocausal involution (forward implications are *not* recoverable\nfrom backward ones unless the algebra is Boolean) yields a logical hardness gap that can\nseed a commitment scheme: committing in \"forward time\" and opening in \"reversed time\" is\nbinding precisely because LEM fails.\n\n- **The key insight is...** that `lem_iff_dne` makes non-recoverability of `a\u1d9c\u1d9c \u21a6 a`\n  equivalent to LEM failure, so a non-Boolean retrocausal carrier provides an\n  *information-theoretic* (not merely computational) one-way asymmetry.\n- **Why now?** The equivalence and an explicit non-Boolean model are already formalized;\n  the Cryptography catalog (`Catalog/Cryptography/`) has the commitment/hardness scaffolding\n  to host the construction.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2050",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "c2929b61",
    "status": "available",
    "timestamp": "2026-06-17T10:23:46.814177+00:00",
    "title": "Derived from this cycle's verified results in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 Mind vs G\u00f6del: Can Minds Outperform Algorithms?\n\nThis cycle established (`Catalog/Logic/MindVersusGodel.lean`, 0 sorries) a four-layer,\nfully verified abstract account of the Lucas\u2013Penrose question:\n\n- **Layer 1** \u2014 `lawvere_fixed_point` / `no_surjection_to_predicates`: the single\n  fixed-point fact underlying every diagonal argument.\n- **Layer 2** \u2014 `FormalSystem`, `GodelSentence`, `godel_true_unprovable`,\n  `godel_neg_unprovable`, `FormalSystem.consistent`: semantic incompleteness with\n  consistency derived as a theorem.\n- **Layer 3** \u2014 `mindSystem`, `mind_still_incomplete`, `ReflectionTower`,\n  `tower_strict_mono`, `tower_no_level_complete`, `tower_limit_complete`,\n  `mind_vs_godel_synthesis`: the \u03c9-reflection ladder. A mind beats any *single*\n  algorithm by one rung but never the whole class.\n- **Layer 4** \u2014 `bool_diagonal`, `no_halting_decider`, `truth_undefinable`,\n  `mind_is_not_one_algorithm`: G\u00f6del/Tarski/Turing unified as one Boolean diagonal.\n\nThe conjectures below are precise enough to be stated as Lean theorems and either\nproved or refuted in a follow-up cycle.\n\n## Conjecture 1 \u2014 Ordinal reflection strictly dominates \u03c9-reflection\nReplace `ReflectionTower : \u2115 \u2192 \u2026` by a tower indexed by a countable ordinal notation\nsystem `O`. Conjecture: for every recursive ordinal \u03b1 there is a sentence provable at\nlevel \u03b1+1 but at no level \u03b2 \u2264 \u03b1, and the union over all recursive ordinals is *still*\nincomplete (a fresh diagonal sentence escapes). **Falsifiable form:** exhibit a recursive\nordinal-indexed `Provable : O \u2192 S \u2192 Prop` with `tower_strict_mono` at every successor and\na global incompleteness witness; or prove no such strictly increasing recursive tower can\nhave an incompleteness witness at its supremum.\n\n## Conjecture 2 \u2014 Soundness is the exact currency of the mind's advantage\nIn `mindSystem` the mind gains the G\u00f6del sentence *because it asserts soundness*. Conjecture:\nan algorithm granted an oracle for `Con(F)` (consistency of `F`) proves exactly the same new\nsentence, i.e. `mindProv F G \u2286 ProvFromConsistencyOracle F`. **Falsifiable form:** define a\n`FormalSystem` extension `F + Con(F)` and prove `G.g` is provable there, establishing that\nthe mind's \"extra truth\" is an *algorithmic* consequence of one consistency assumption \u2014 so\nthe advantage is relative, not absolute.\n\n## Conjecture 3 \u2014 No fixed point of the reflection operator is complete\nLet `R : FormalSystem \u2192 FormalSystem` be the reflective extension operator (Layer 3). Conjecture:\nif `F` admits a G\u00f6del sentence and `R F \u2245 F` (a fixed point of reflection), then `F` is\ninconsistent. I.e. the only \"self-reflectively closed\" sound systems are exactly the ones with\nno diagonal sentence (too weak to be interesting). **Falsifiable form:** prove\n`(\u2200 G, RF.Prov = F.Prov) \u2192 \u00ac Nonempty (GodelSentence F)` for sound `F`, or build a sound,\ndiagonal-admitting fixed point as a counterexample.\n\n## Conjecture 4 \u2014 Quantitative diagonal gap\nGeneralize `bool_diagonal` from `Bool` to a finite valuation type `Fin k` with a\nfixed-point-free permutation `\u03c3`. Conjecture: an evaluator `eval : \u03b1 \u2192 \u03b1 \u2192 Fin k` avoids the\n\u03c3-diagonal on a set of \"rows\" of measure (counting) at most `1 \u2212 1/k` \u2014 i.e. the diagonal\ndefeats a `1/k` fraction of any finite candidate table. **Falsifiable form:** for finite `\u03b1`,\nprove `#{ m | \u2200 x, eval m x = \u03c3 (eval x x)} = 0` and, dually, bound how close a table can come.\n\n## Conjecture 5 \u2014 Bridge to `ProofSystemCollapse` / `ParadoxSelfSoundness`\nThe catalog's `ParadoxSelfSoundness` shows paraconsistent theories *can* prove their own\nsoundness by tolerating `B`-valued dialetheias. Conjecture: a `FormalSystem` whose truth\nvaluation is Belnap-four-valued (replacing `neg_true` by `BelnapVal.neg`) admits a G\u00f6del\nsentence valued `B`, making `godel_true_unprovable` *vacuous* (the mind's \"seeing\" collapses).\n**Falsifiable form:** define `BelnapFormalSystem`, port `godel_true_unprovable`, and prove the\nfixed point is forced to `B`/`N` \u2014 formally connecting the Mind-vs-G\u00f6del ladder to the\ninconsistency-tolerance spectrum and the `DiagonalSystem` of `ParadoxSelfSoundness`.\n",
    "domains": [
      "Logic",
      "Algebra"
    ],
    "id": "fd_2051",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "95c512f5",
    "status": "available",
    "timestamp": "2026-06-17T10:24:13.497098+00:00",
    "title": "(`Catalog/Logic/MindVersusGodel.lean`, 0 sorries) a four-"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Counterfactual Number Theory: What If Primes Were Random?\n\nThis cycle formalized the **Cram\u00e9r random model of the primes** as a genuine finite\nprobability space (a Bernoulli \"random sieve\" on a candidate window), and proved the\nfoundational expectation identities used as heuristics in cryptography:\n\n- `cramer_total_mass` / `cramer_weight_nonneg` \u2014 the sieve is a probability distribution;\n- `cramer_subset_indicator` \u2014 **independence**: `P(A \u2286 S) = \u220f_{i\u2208A} p i`;\n- `cramer_single`, `cramer_pair` \u2014 marginal and pairwise corollaries;\n- `cramer_expected_count` \u2014 expected random-prime count `= \u2211 p i` (model of `\u03c0(N) \u2248 Li(N)`);\n- `cramer_expected_pairs` / `cramer_expected_twin_count` \u2014 expected twin/`k`-tuple counts\n  (Hardy\u2013Littlewood heuristic skeleton).\n\nAll identities turned out to be **purely algebraic** in the weight family `p : \u03b9 \u2192 \u211d`;\npositivity (`0 \u2264 p \u2264 1`) is needed only to certify the distribution is genuine. The\nentire theory collapses onto `Finset.prod_add`. The conjectures below build on this base.\n\n## Conjecture 1 \u2014 Variance and second-moment concentration of the random prime count\nDefine `Var(|S|) = E[|S|\u00b2] \u2212 E[|S|]\u00b2` for the Cram\u00e9r sieve. Conjecture (and formalize):\n`Var(|S|) = \u2211_{i\u2208s} p i (1 \u2212 p i)`, exactly (independence kills cross terms). Corollary:\nunder `p n = 1/log n` on `Icc 2 N`, the standard deviation is `\u0398(\u221a(N/log N))`, so the\nrandom model concentrates: `|S| = (1+o(1)) \u2211 1/log n` almost surely. **Testable**: prove the\nexact variance identity via `cramer_pair` + `cramer_single`; it is a finite computation.\n\n## Conjecture 2 \u2014 Expected number of prime `k`-tuples (singular series skeleton)\nGeneralize `cramer_expected_twin_count` to arbitrary admissible offset patterns\n`H = {h_1,\u2026,h_k}`. Conjecture: the expected number of `n \u2208 [2,N]` with all of\n`n+h_1,\u2026,n+h_k` random-prime equals `\u2211_n \u220f_{j} p(n+h_j)`, and under Cram\u00e9r's `p`\nthis is asymptotic to `\u222b dt/(log t)^k`. **Testable**: the exact finite identity is a direct\niteration of `cramer_subset_indicator` with `A` of size `k`; the asymptotic is a separate\nanalytic lemma. Note the *deviation* of this from the true Hardy\u2013Littlewood constant\n`\ud835\udd16(H)` measures exactly how the genuine primes fail to be Cram\u00e9r-random.\n\n## Conjecture 3 \u2014 Maximal prime gap in the Cram\u00e9r model (Cram\u00e9r's conjecture, finite form)\nLet `G_N` be the largest gap between consecutive random primes in `[2,N]`. Conjecture:\n`E[G_N] = \u0398((log N)\u00b2)` and `P(G_N > c (log N)\u00b2) \u2192 0` for large `c`. **Testable first step**:\nformalize, for the sieve, the exact probability that a fixed window `[m, m+L]` contains\n*no* random prime: `\u220f_{n=m}^{m+L} (1 \u2212 p n)`, and prove the union-bound upper tail\n`P(\u2203 gap \u2265 L) \u2264 \u2211_m \u220f (1\u2212p n)`. This is provable now from the weight definition.\n\n## Conjecture 4 \u2014 Counterfactual divergence: where real primes beat the coin flips\nFormalize a quantitative \"non-randomness detector\". For residue classes mod `q`, the\nCram\u00e9r model predicts the random primes equidistribute with no bias, i.e.\n`E[#{n\u2208s : n \u2261 a (q), n random-prime}] = \u2211_{n\u2261a} p n`, *independent of `gcd(a,q)`*.\nConjecture: the genuine primes deviate from this by exactly the factor `q/\u03c6(q)` on the\ncoprime classes (and `0` otherwise). **Testable**: prove the model's class-count identity\n(immediate from `cramer_expected_count` restricted to an arithmetic-progression subset),\nthen state the divergence as a separate, falsifiable comparison theorem against `Nat.Prime`.\n\n## Conjecture 5 \u2014 Cryptographic key-generation success probability (Bernoulli sieve bound)\nRSA key generation samples until it hits a prime. Model: in a window of `L` candidates each\nprime with prob `p`, the probability of failing to find any prime is `\u220f (1 \u2212 p n)`.\nConjecture: with `p n = 1/log n`, `O(log N)` independent samples suffice to find a prime\nwith probability `\u2265 1 \u2212 \u03b5`, and formalize the explicit bound\n`P(failure in m samples) \u2264 (1 \u2212 p_min)^m`. **Testable**: provable now from\n`cramer_total_mass` and `cramer_weight_nonneg`; gives a verified, model-level justification\nfor the practical efficiency of probabilistic prime generation.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2052",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "667542f0",
    "status": "available",
    "timestamp": "2026-06-17T10:58:34.240179+00:00",
    "title": "This cycle formalized the **Cram\u00e9r random model of the primes** as a genuine fin"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 The Spectral Gap of Sudoku\n\nThese conjectures extend the formalization in `Catalog/Novelty/SudokuSpectralGap.lean`,\nwhich establishes (general order `n`): the Sudoku graph is `(3n\u00b2\u22122n\u22121)`-regular, its\nadjacency spectrum is confined to `[\u2212d, d]` with the all-ones Perron eigenvector at the\ntop, its chromatic number is exactly `n\u00b2`, and the partial-grid completion functor is\nantitone with a sharp SAT (nonempty)\u2192UNSAT (empty) dichotomy.\n\nEach item below is stated to be **falsifiable** and **formalizable** in Lean.\n\n## C1. Exact second eigenvalue and the spectral gap formula\n**Conjecture.** The Sudoku graph of order `n` is a graph with exactly four distinct\nadjacency eigenvalues, and its second-largest eigenvalue is `\u03bb\u2082 = 2n \u2212 1`, giving a\nspectral gap `d \u2212 \u03bb\u2082 = 3n\u00b2 \u2212 4n = n(3n\u22124)`. Equivalently, the gap grows quadratically in\n`n` so the normalized gap `(d \u2212 \u03bb\u2082)/d \u2192 1`.\n*Test:* compute the spectrum for `n = 2, 3, 4` by `decide`/`native_decide` on the\nadjacency matrix and check the count of distinct eigenvalues and the value of `\u03bb\u2082`.\n\n## C2. The Sudoku graph is strongly regular iff `n = ... `\n**Conjecture.** The order-`n` Sudoku graph is **not** strongly regular for any `n \u2265 2`\n(unlike its building blocks: rows/columns/boxes individually give complete graphs).\nPrecisely, the number of common neighbours of two adjacent cells is *not* constant across\nall adjacent pairs. *Test:* exhibit two adjacent pairs (same-box vs. same-row-different-box)\nwith different common-neighbour counts; formalize as a `\u2203`-counterexample to\n`G.IsSRGWith ...`.\n\n## C3. Phase-transition threshold for unique completion\n**Conjecture.** There is a sharp clue-count threshold `m(n)` such that a uniformly random\nclue set of size `< m(n)` almost never has a unique completion while one of size `> m(n)`\nalmost always does; and `m(n) = \u0398(n\u00b2)`. As a first formal milestone (deterministic):\n*any* clue set whose support meets every row, column, and box still need not pin the\nsolution, but a clue set equal to a full solution minus one cell always has a unique\ncompletion. *Test:* prove the deterministic milestone via `completions_antitone` plus the\nlocal cancellation already used in `sudokuColor_valid`.\n\n## C4. Hoffman bound is tight \u21d2 a fractional-relaxation rigidity\n**Conjecture.** Hoffman's lower bound `\u03c7 \u2265 1 \u2212 \u03bb_max/\u03bb_min` is *tight* for the Sudoku\ngraph, i.e. `1 \u2212 d/\u03bb_min = n\u00b2`, forcing `\u03bb_min = \u2212d/(n\u00b2\u22121)`. Combined with `C1` this\nover-determines the spectrum and should pin all four eigenvalues. *Test:* once `\u03bb_min` is\nformalized, verify `1 \u2212 d/\u03bb_min = n\u00b2` symbolically and cross-check against the spectra of\n`C1`.\n\n## C5. Tensor/Kronecker structure of the Sudoku operator\n**Conjecture.** The Sudoku adjacency operator decomposes as a sum of Kronecker products of\nall-ones and identity blocks: `A = (J\u2297I + I\u2297J + J\u2297J)_{rows,cols,boxes} \u2212 3\u00b7(I\u2297I) \u2212 ...`\nover the `Fin n \u00d7 Fin n \u00d7 Fin n \u00d7 Fin n` factorization, so its eigenvalues are explicit\ninteger combinations of `{n, 0}` eigenvalues of `J` and `I`. This would make `C1` and `C4`\ncorollaries of a single tensor-eigenvalue lemma. *Test:* formalize `A` as such a Kronecker\ncombination on `Cell n` and prove the eigenvalues factor accordingly; the all-ones\neigenvalue `d = 3n\u00b2\u22122n\u22121` should drop out as the `(n,n,n)` corner, matching\n`sudoku_top_eigenvalue`.\n",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_2053",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "595ce011",
    "status": "available",
    "timestamp": "2026-06-17T13:01:57.718914+00:00",
    "title": "These conjectures extend the formalization in `Catalog/Novelty/SudokuSpectralGap"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 Phantom Topologies (Combinatorics)\n\nCycle-1/2 results live in `Catalog/Speculative/PhantomTopologies.lean`, where we proved that\non a finite carrier the topology is a *phantom* of its specialization preorder:\n\n- `topology_eq_of_specializes_iff` \u2014 a topology is determined by the bare `\u2933` relation;\n- `specPreorder_bijective` \u2014 `topology \u21a6 specialization preorder` is a **bijection**\n  `TopologicalSpace \u03b1 \u2243 Preorder \u03b1` (the classical \"finite spaces = preorders\");\n- `continuous_iff_specializes` \u2014 continuity *is* specialization-monotonicity (morphisms are\n  phantoms too);\n- `phantom_asymmetry` \u2014 the realized preorders are genuinely directional.\n\nThe conjectures below are bold, falsifiable next steps. Each comes with a concrete Lean target.\n\n---\n\n## C1. T0 rigidity: phantoms collapse exactly onto partial orders\n**Conjecture.** The observation map `specPreorder` restricts to a bijection between the\n`T0` topologies on a finite `\u03b1` and the **partial orders** on `\u03b1`.\n**Why plausible.** `specializationOrder` already upgrades the preorder to a partial order under\n`T0Space`; antisymmetry is exactly the `T0` (Kolmogorov) condition.\n**Lean target.**\n```\ntheorem specPreorder_T0_bijective [Finite \u03b1] :\n    Function.Bijective\n      (fun (t : {t : TopologicalSpace \u03b1 // @T0Space \u03b1 t}) => (specialization partial order))\n```\nA corollary would be a *counting* statement: `#{T0 topologies on Fin n} = #{partial orders on Fin n}`\n(OEIS A001035), complementing the full count A000798.\n\n## C2. Homeomorphism is an order-isomorphism of phantoms\n**Conjecture.** For finite spaces, `Homeomorph \u03b1 \u03b2` is in natural bijection with order-isomorphisms\nof their specialization preorders: `(\u03b1 \u2243\u209c \u03b2) \u2243 (Specialization \u03b1 \u2243o Specialization \u03b2)`.\n**Why plausible.** `continuous_iff_specializes` gives the arrow-level dictionary; a homeomorphism is\na continuous bijection with continuous inverse, i.e. a monotone bijection with monotone inverse.\n**Lean target.** Build the explicit `Equiv` and prove both round-trips; specialize to deduce that\ntwo finite spaces are homeomorphic iff their preorders are order-isomorphic.\n\n## C3. Connectivity is a phantom (combinatorial connectivity)\n**Conjecture.** A finite space is topologically connected **iff** its specialization preorder is\nconnected as a graph under the comparability relation `x \u2264 y \u2228 y \u2264 x` (zigzag-connected).\n**Why plausible.** In an Alexandrov space the minimal open set of `x` is its up-set; topological\ncomponents match equivalence classes of the reflexive\u2013symmetric\u2013transitive closure of `\u2264`.\n**Lean target.**\n```\ntheorem connected_iff_preorder_connected [Finite \u03b1] [TopologicalSpace \u03b1] :\n    ConnectedSpace \u03b1 \u2194 (\u2200 x y : \u03b1, Relation.ReflTransGen (fun a b => a \u2933 b \u2228 b \u2933 a) x y)\n```\n\n## C4. McCord/M\u00f6bius bridge: Euler characteristic = M\u00f6bius number\n**Conjecture.** For a finite `T0` space `X` with specialization poset `P`, the reduced Euler\ncharacteristic of the order complex `\u0394(P)` equals the M\u00f6bius number `\u03bc(P\u0302)` of `P` with adjoined\n`\u22a5`/`\u22a4` \u2014 a strict identity between a topological invariant and a purely combinatorial one.\n**Why plausible.** This is the finite-space shadow of McCord's weak-homotopy equivalence\n`|\u0394(P)| \u2243 X`; the alternating face count of `\u0394(P)` is the order-complex Euler characteristic, which\nPhilip Hall's theorem identifies with a M\u00f6bius value.\n**Lean target.** Define `orderComplex P` (chains of `P`), its Euler characteristic, and prove the\nidentity for the partial order produced by `specializationOrder`.\n\n## C5. Asymptotic dominance of asymmetric phantoms\n**Conjecture.** The fraction of topologies on `Fin n` that are `T0` (genuinely asymmetric phantoms,\ncf. `phantom_asymmetry`) tends to `1` as `n \u2192 \u221e`; equivalently `A000798(n) / A001035(n) \u2192 1`.\n**Why plausible.** A random preorder is asymptotically almost surely a partial order, since the\nnumber of nontrivial inseparability classes is negligible for large `n`.\n**Lean target.** A clean intermediate, fully finitary milestone: prove the *exact* small-case\ncounts agree with the phantom bijection, e.g. that there are exactly `4` topologies and `4`\npreorders on a 2-element type, and exactly `3` of them are `T0`, by transporting the count along\n`specPreorder_bijective`.\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2055",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "5884df3d",
    "status": "available",
    "timestamp": "2026-06-17T13:03:52.809560+00:00",
    "title": "Cycle-1/2 results live in `Catalog/Speculative/PhantomTopologies.lean`, where we"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# FUTURE DIRECTIONS \u2014 The L-Function Oracle (Probability)\n\nDerived from this cycle's verified Lean results:\n\n- `Probability/SatoTateMeasure.lean` \u2014 the Sato\u2013Tate law is a probability measure\n  (`satoTate_total_mass = 1`) with verified `cos`-moments `(mean 0, second moment 1/4)`.\n- `Probability/FactoringOracle.lean` \u2014 a single-split oracle factors `n` in `\u2264 log\u2082 n`\n  calls (`SplitOracle.factor_bounded`), the burden concentrated in one `reduce` step.\n- `Probability/SelbergOracle.lean` \u2014 degree/conductor conservation along functoriality\n  towers (`nfold_degree`, `nfold_conductor`) plus an oracle\u21d2decidability collapse, built on\n  the catalog file `Shared.SelbergClassCensus`.\n\nThe central methodological lesson: the grandiose \"oracle implies RH/BSD/Langlands\" claims\nare, once formalised, either *tautological* (the oracle is asserted to output the answer) or\n*conditional on an explicit reduction*. The genuinely load-bearing mathematics is elsewhere \u2014\nin the moments of the target measure, in the `log`-depth of the factoring recursion, and in\nthe conservation laws of the invariants. The conjectures below target that real content.\n\n---\n\n## Conjecture 1 \u2014 All Sato\u2013Tate moments are the Catalan/central-binomial sequence\n\n**Statement.** For every `k`, the `2k`-th `cos`-moment under `\u03bc_ST = (2/\u03c0) sin\u00b2\u03b8 d\u03b8` equals\n`Catalan k / 4^k`, i.e. `\u222b\u2080^\u03c0 cos^{2k}\u03b8 \u00b7 (2/\u03c0) sin\u00b2\u03b8 d\u03b8 = C_k / 4^k` where\n`C_k = (2k choose k)/(k+1)`; all odd moments vanish.\n\n**The key insight is** that the Sato\u2013Tate measure is exactly the spectral measure of the\n`SU(2)` Haar trace, so its even moments count noncrossing pairings \u2014 the Catalan numbers \u2014\nwhich makes the whole moment sequence a *single closed-form arithmetic object* rather than a\nlist of unrelated integrals. This cycle verified the `k = 0, 1` cases (mass `1`, second\nmoment `1/4 = C_1/4`); the conjecture is the uniform generalisation.\n\n**Why now?** We already have the integral machinery (`integral_sin_pow`,\n`integral_sin_pow_mul_cos_pow_odd`) working end-to-end in Lean on this exact density, so the\ninductive recurrence `M_{k} \u21a6 M_{k+1}` is within reach with the tools just exercised.\n\n---\n\n## Conjecture 2 \u2014 The factoring reduction is depth-optimal, not just depth-bounded\n\n**Statement.** The `\u2264 log\u2082 n` bound in `SplitOracle.factor_bounded` is tight in the worst\ncase and tight on average: for `n = 2^m` every split oracle needs exactly `m` calls, and the\n*expected* number of calls over uniformly random `n \u2264 N` is `\u0398(log log N)` (Erd\u0151s\u2013Kac shape:\nthe number of prime factors `\u03a9(n)` concentrates at `log log n`).\n\n**The key insight is** that the recursion tree of `factor_bounded` is precisely a binary tree\nwhose leaves are the prime factors *with multiplicity*, so the call count is `\u03a9(n) \u2212 1`; the\ndeterministic bound is `log\u2082 n` but the *typical* value is governed by the Erd\u0151s\u2013Kac law, a\ngenuinely probabilistic statement about the cost of the L-function oracle.\n\n**Why now?** The leaf-counting identity is already implicit in the verified proof\n(`length = \u03a9(n)`), so the deterministic optimality is a short additional lemma, and it sets up\nthe bridge to the catalog's number-theory files (`Applications/Fibonacci*`, Carmichael\nmaterial) where `\u03a9` of structured integers is studied.\n\n---\n\n## Conjecture 3 \u2014 Functoriality towers force a degree/conductor uncertainty bound\n\n**Statement.** For any `SelbergDatum S` with `S.degree \u2265 1` and `S.conductor \u2265 2`, the\n`n`-fold tower satisfies `(nfoldProduct S n).degree \u00b7 log\u2082((nfoldProduct S n).conductor)`\ngrows like `n\u00b2 \u00b7 d \u00b7 log\u2082 q`; equivalently the \"analytic complexity\"\n`degree \u00d7 log-conductor` is *super-additive* along towers, never sub-additive.\n\n**The key insight is** that `nfold_degree` (linear) and `nfold_conductor` (exponential)\ncombine multiplicatively, so the analytic conductor \u2014 the quantity controlling the length of\nthe approximate functional equation, hence the true cost of evaluating the L-function \u2014\n*explodes quadratically* along a tower. An O(1) oracle would have to be uniform across this\nexplosion, which is exactly why a literal oracle is implausible.\n\n**Why now?** Both growth laws are already proved in `SelbergOracle.lean`; multiplying them is\na one-step corollary, and it converts the vague \"oracles are too powerful\" intuition into a\nconcrete, falsifiable growth inequality on catalog `SelbergDatum`.\n\n---\n\n## Conjecture 4 \u2014 Oracle collapse is provably non-vacuous only with a length-bounded encoding\n\n**Statement.** The decidability collapse `reduction_collapses` upgrades to a *complexity*\nstatement iff the encoding `f : X \u2192 SelbergDatum` has polynomially bounded conductor: if\n`f x` has conductor `\u2264 poly(|x|)`, then `L` is decidable in time polynomial in the oracle\ncost; without such a bound the collapse is logically true but computationally empty.\n\n**The key insight is** that the only smuggled cost in \"reduce to one L-query\" is the *size of\nthe datum you hand the oracle*, measured by its conductor \u2014 Conjecture 3 shows this size can\nblow up, so the honest collapse theorem must carry a conductor budget as a hypothesis.\n\n**Why now?** `reduction_collapses` and `selberg_oracle_decidable` are already in place as the\nunconditional (decidability-only) skeleton; adding a conductor-budget field to the encoding is\na natural refinement that makes the \"polynomial hierarchy collapse\" claim precise and testable.\n\n---\n\n## Conjecture 5 \u2014 A second-moment certificate distinguishes CM from non-CM curves\n\n**Statement.** Define the empirical second `cos`-moment of the first `N` Frobenius angles of\nan elliptic curve `E/\u211a`. For non-CM curves it converges to `1/4` (the Sato\u2013Tate value proved\nhere); for CM curves it converges to `1/2`. Hence a single converging moment statistic, output\nby the oracle, certifies the CM/non-CM dichotomy.\n\n**The key insight is** that the verified value `1/4` is the *fingerprint* of the full `SU(2)`\nSato\u2013Tate measure, whereas the CM case is governed by a `U(1)` measure with second moment\n`1/2`; the gap `1/4 vs 1/2` is a clean, decidable separating observable rather than a full\nequidistribution statement.\n\n**Why now?** `satoTate_second_moment_cos = 1/4` is verified; the companion `U(1)` computation\n`\u222b\u2080^\u03c0 cos\u00b2\u03b8 \u00b7 (1/\u03c0) d\u03b8 = 1/2` is an even simpler interval integral, so the separating\ncertificate is one short lemma away and turns the abstract Sato\u2013Tate dichotomy into a finite\nstatistical test.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2056",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "46951c2e",
    "status": "available",
    "timestamp": "2026-06-17T13:36:58.586987+00:00",
    "title": "Derived from this cycle's verified Lean results:"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 CSS Codes as Cohomology\n\nThis cycle established the dictionary **CSS code = homology of an `F\u2082`-chain\ncomplex** (`Core.lean`), *refuted* the hypercube conjecture for the 1-skeleton\ncycle code (`CubeCode.lean`), and anchored the refutation with a fully explicit\n`[[4,1]]` code on `C\u2084 = Q\u2082` (`RingCode.lean`). The surviving topological\ninvariant is the cyclomatic number `\u03b2\u2081(Q_n) = (n\u22122)\u00b72^{n-1} + 1`, which equals\n`1` **only** at `n = 2`. The directions below grow out of exactly those findings.\n\n---\n\n## Conjecture 1 \u2014 The cube becomes a `[[\u00b7,1,\u00b7]]` code only after filling 2-cells\n\nFor the *cubical* complex `Q_n` (vertices, edges **and** square 2-faces), the\nhomological code has `k = dim H\u2081(Q_n; F\u2082) = 0` for `n \u2265 2` (the cube is simply\nconnected), so to recover a single logical qubit one must quotient/identify\nfaces into a closed surface. Concretely: there is a surface `\u03a3` obtained from\n`Q_n`'s 2-skeleton with `dim H\u2081(\u03a3; F\u2082) = 1` and code distance equal to the\ngirth `4`, **not** `2^{n/2}`.\n\n- **The key insight is** that the mission's \"1 qubit\" claim silently assumes a\n  *surface* (2-complex) where 2-cells kill all but one homology class, while the\n  literal `Z\u2081/B\u2081` cycle code on the 1-skeleton has `B\u2081 = 0` and therefore\n  over-encodes by the full cyclomatic number `(n\u22122)2^{n-1}+1`.\n- **Why now?** `CubeCode.numLogical_graphCode` already isolates the `d\u2082 = 0`\n  (no-2-cell) case; adding a nonzero `d\u2082` for the square faces is a direct,\n  mechanical extension of the same `Core` dimension formula, so the surface vs.\n  graph dichotomy is immediately testable in the existing framework.\n\n## Conjecture 2 \u2014 Homological distance is governed by Hamming weight, and the cube saturates only the trivial Singleton bound\n\nDefine the code distance `d` as the minimum `hammingWeight` (already imported\nfrom the catalog's `vecSupport`) over nonzero homology representatives. Then for\nthe `C\u2084` code `d = 4`, and every cube 1-skeleton code has `d = girth = 4`,\ngiving `k + d = \u03b2\u2081 + 4`, which violates the quantum Singleton bound\n`k + 2d \u2264 n + 2` for large `n` \u2014 i.e. the 1-skeleton codes are **bad** codes,\nthe opposite of the conjecture's \"achieves the Singleton bound\" claim.\n\n- **The key insight is** that distance is a *minimum-weight* invariant of the\n  cohomology class, so the catalog's `vecSupport_card_pos_of_ne_zero` is the\n  exact primitive needed, and the constant girth `4` forces asymptotically\n  vanishing relative distance `d/n \u2192 0`.\n- **Why now?** `RingCode.ker_boundary` shows the homology class explicitly as a\n  single weight-4 vector; computing `hammingWeight` of a kernel basis is already\n  `decide`-feasible at small `n`, so the Singleton-violation can be certified\n  before any general theory is built.\n\n## Conjecture 3 \u2014 `\u03b2\u2081(Q_n) = 1 \u21d4 n = 2` is the only finite-qubit cube; tori are the right family\n\nReplacing `Q_n` by the discrete torus `(C_m)^{\u00d72}` (product of two `m`-cycles)\nas a 2-complex yields `dim H\u2081 = 2` (the toric code) with distance `m`, the\ngenuine `[[2m\u00b2, 2, m]]` family. Conjecture: among all \"graph-cube-like\" 1-complexes,\n`\u03b2\u2081 = 1` characterizes `C\u2084` uniquely, and the *only* way to keep `k` bounded\nwhile growing `n` is to add 2-cells (move to a surface).\n\n- **The key insight is** that `cube_one_qubit_iff` pins `k = 1` to `n = 2` for\n  the cube, so bounded-`k` code families must come from *surfaces of fixed\n  genus*, not from growing graphs \u2014 exactly the toric-code construction.\n- **Why now?** The closed form `cyclomatic_closed_form` makes the `k`-growth\n  exact, so contrasting it against the constant `k = 2` of a torus 2-complex is a\n  clean, fully arithmetic comparison reusing the present `cyclomatic` machinery.\n\n## Conjecture 4 \u2014 Euler characteristic is the universal qubit budget\n\nFor any bounded `F\u2082`-chain complex `0 \u2192 C\u2096 \u2192 \u22ef \u2192 C\u2080 \u2192 0`, the alternating sum of\nhomology dimensions equals the alternating sum of chain dimensions\n(`\u2211 (\u22121)\u2071 dim H\u1d62 = \u2211 (\u22121)\u2071 dim C\u1d62 = \u03c7`). Hence the *total* logical-qubit budget\nacross all degrees of a chain-complex code is the topological Euler\ncharacteristic, a single integer invariant.\n\n- **The key insight is** that `Core.finrank_homology` already expresses one\n  homology dimension as a difference of ranks; iterating rank\u2013nullity up the\n  complex telescopes into `\u03c7`, so \"qubits = Euler characteristic\" is a\n  rank\u2013nullity identity, not new analysis.\n- **Why now?** `Core` proves the single-spot case with `finrank_quotient_add_finrank`;\n  the multi-degree version is the same lemma applied inductively, well within the\n  subagent's reach.\n\n## Conjecture 5 \u2014 Every classical `[n,k]` `F\u2082` code is the degree-0 homology of a length-1 complex, making CSS \u2194 classical functorial\n\nFor a parity-check map `H : F\u2082\u207f \u2192 F\u2082^r`, the length-1 complex `F\u2082\u207f \u2192H F\u2082^r` has\n`H\u2080 = coker H` and `H\u2081 = ker H = ` the classical code, with `dim H\u2081 = n \u2212 rank H`.\nConjecture: the assignment `(C\u2081, C\u2082) \u21a6 (chain complex)` and back is an\nequivalence of categories between CSS codes and bounded `F\u2082`-chain complexes up\nto chain homotopy.\n\n- **The key insight is** that `numLogical_eq_css` is precisely the object-level\n  half of this equivalence (`k = n \u2212 rank H_Z \u2212 rank H_X`); promoting it to a\n  functor only requires tracking chain maps, which Mathlib's `HomologicalComplex`\n  already supports.\n- **Why now?** With the dimension dictionary proved and the cube/`C\u2084` examples in\n  hand, the remaining work is purely categorical bookkeeping on top of existing\n  `Core` definitions \u2014 no new hard analytic input is needed.\n",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_2057",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "ab2bf6f4",
    "status": "available",
    "timestamp": "2026-06-17T14:16:00.949333+00:00",
    "title": "Dictionary **CSS code = homology of an `F\u2082`-chain"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Transreal Arithmetic & the Wheel Collapse\n\nDerived from this cycle's verified findings in\n`Catalog/Algebra/Transreal/{Basic,RingFails,Wheel,TropicalBridge}.lean`.\n\nCycle summary (what is now machine-checked, 0 sorries):\n\n* `(\ud835\udd4b, +, 0)` and `(\ud835\udd4b, \u00b7, 1)` are commutative monoids; `\u03a6` is absorbing.\n* `\ud835\udd4b` is **not** a ring: `+\u221e` has no additive inverse (`no_add_inverse_pinf`),\n  distributivity fails (`distrib_fails`), `+\u221e` has no multiplicative inverse\n  (`mul_inverse_axiom_fails`).\n* `\ud835\udd4b` is **not** a Carlstr\u00f6m wheel: the involution `//x = x` fails at `-\u221e`\n  (`recip_recip_ninf`) and the reciprocal is not multiplicative\n  (`recip_mul_fails`).  Both failures are caused by the *two-signed* infinity.\n* The projective collapse `\u00b1\u221e \u21a6 \u221e` gives `\u2119 = \u211d \u222a {\u221e, \u22a5}`, a genuine wheel:\n  involution (`precip_precip`), reciprocal homomorphism (`precip_pmul`),\n  modified distributivity (`wheel_distrib`), and `wheel_W7`, `wheel_W9` all hold.\n\n---\n\n## Conjecture 1 \u2014 The wheel obstruction is *exactly* the sign congruence\n\n**Statement.** Let `~` be the smallest congruence on `\ud835\udd4b` (w.r.t. `+`, `\u00b7`, `/`)\nmaking the reciprocal an involution. Then `\ud835\udd4b/~ \u2245 \u2119`, and `~` identifies precisely\n`+\u221e` with `-\u221e` (fixing every other point). In particular `\u2119` is the *initial*\nwheel quotient of the transreals.\n\n**The key insight is** that the only law-breaking in `\ud835\udd4b` is sign-blindness of\n`/0 = +\u221e`, so quotienting by the single relation `+\u221e ~ -\u221e` must repair *all* wheel\naxioms simultaneously \u2014 no further identifications are needed or allowed.\n\n**Why now?** Both `\ud835\udd4b` (`Basic.lean`) and `\u2119` (`Wheel.lean`) are formalized with\ntheir full operation tables, so the quotient map and its universal property can be\nbuilt and verified directly rather than argued on paper.\n\n---\n\n## Conjecture 2 \u2014 Only two wheel axioms fail for the transreals\n\n**Statement.** Equip `\ud835\udd4b` with its (two-signed) operations. Then the commutative\nmonoid laws, `\u22a5`-absorption, modified distributivity (`(x+y)z + 0z = xz + yz`),\nand the `0\u00b7y`-correction laws hold verbatim; the *only* wheel axioms that fail are\nthe reciprocal involution and the reciprocal homomorphism.\n\n**The key insight is** that every wheel axiom not mentioning `/` is sign-agnostic,\nso it cannot detect the `+\u221e / -\u221e` distinction; only the two reciprocal laws probe\nthe sign of `1/0`.\n\n**Why now?** We already have `TReal.mul_assoc'`, `add_assoc'`, and the absorbing\nlemmas; the remaining `+`/`\u00b7`-only wheel axioms are within reach of the same\ncase-bash automation, making this a concrete, finite verification target.\n\n---\n\n## Conjecture 3 \u2014 A transreal survives iff it lives in the cancellation-free fragment\n\n**Statement.** A first-order identity over `(+, \u00b7, 0, 1)` that is a theorem of `\u211d`\nremains true for **all** transreal substitutions if and only if it is derivable\nwithout additive or multiplicative cancellation (equivalently, provable in the\ntheory of commutative semirings minus distributivity-with-subtraction).\n\n**The key insight is** that the transreal failures are all instances of lost\ninvertibility (`\u221e + x \u2260 0`, `\u221e\u00b7(1/\u221e) \u2260 1`); an identity transports to `\ud835\udd4b` exactly\nwhen its proof never inverts an element that can become `\u00b1\u221e` or `0\u00b7\u221e`.\n\n**Why now?** `RingFails.lean` pins the exact obstructions to invertibility, giving\na precise syntactic boundary to test: instrument candidate `\u211d`-identities and check\ntransreal survival against cancellation-usage in their proofs.\n\n---\n\n## Conjecture 4 \u2014 `\ud835\udd4b` differs from Mathlib's `EReal` at a single point\n\n**Statement.** There is an injection `\u211d \u222a {\u00b1\u221e} \u21aa \ud835\udd4b` under which transreal `+` and\n`\u00b7` agree with `EReal` addition and multiplication **except** at the indeterminate\n`(+\u221e) + (-\u221e)`: `EReal` returns `-\u221e` (its `\u22a5`-wins convention) while `\ud835\udd4b` returns\n`\u03a6`. This single discrepancy is exactly what costs `EReal` its associativity-with-a\ntwo-sided identity that `\ud835\udd4b` trades for totality-with-`\u03a6`.\n\n**The key insight is** that both systems totalize `\u00b1\u221e` arithmetic, but `EReal`\nmakes an *arbitrary* choice at `\u221e - \u221e` whereas `\ud835\udd4b` introduces a *new* value `\u03a6`;\ncomparing them isolates the price of each design decision.\n\n**Why now?** `EReal` is fully developed in Mathlib and `\ud835\udd4b` is now formalized here,\nso the comparison map and the exact-disagreement-locus theorem can be stated and\nchecked immediately, turning a folklore remark into a verified statement.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2058",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "8e98f715",
    "status": "available",
    "timestamp": "2026-06-17T15:29:37.901778+00:00",
    "title": "Derived from this cycle's verified findings in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Cellular Automata as Algebraic Geometry over GF(2)\n\nThese conjectures are distilled from the v16a research cycle in\n`Computation/ECAFixedVariety.lean` and `Computation/ECALinearSubspace.lean`.\n\nThe cycle established two anchor facts:\n\n* **Refutation.** The Turing-complete Wolfram Rule 110 has a *single* fixed point\n  (the all-zero configuration) for every length `n \u2265 1`, hence fixed-point-variety\n  dimension `0` \u2014 the *minimum* among nonempty varieties \u2014 directly falsifying the\n  conjecture \"Turing-complete \u21d2 maximal fixed-point dimension\"\n  (`complexity_dimension_conjecture_false`).\n* **Structure.** For *linear* (additive) rules the fixed-point set is literally the\n  kernel of `step \u2212 id`, a `GF(2)`-subspace, so it always has `2^k` points\n  (`linearFixed_card_pow_two`); Rule 110 is provably nonlinear (`g110_not_linear`).\n\nThe fixed-point variety is therefore a real GF(2) scheme, but its dimension is the\n*wrong* complexity invariant. The directions below propose the right one.\n\n---\n\n## Direction 1 \u2014 Spacetime entropy, not fixed-point dimension, tracks complexity.\n\n**Conjecture.** Define the *spacetime subshift* `\u03a3_r` of rule `r` as the set of valid\nbi-infinite orbit diagrams, an SFT over the de Bruijn graph. Its topological entropy\n`h(\u03a3_r) = lim (1/n) log #(period-n columns)` separates Wolfram's classes:\n`h = 0` for Class 1/2, `h > 0` for Class 3, and Class 4 (e.g. Rule 110) sits exactly\nat the `h = 0` boundary while supporting unbounded transients.\n\n**The key insight is** that Turing-completeness lives in the *transient orbit\nstructure* (gliders, collisions), which the static fixed-point variety throws away;\nthe spacetime SFT retains it and its entropy is the genuine invariant.\n\n**Why now?** This cycle proved the fixed-point count of Rule 110 is constantly `1`,\nso any complexity invariant *must* be orbit-based, not equilibrium-based. The\ntransfer-matrix machinery for counting period-`n` configurations (`tr(T^n)`) is\nalready formalizable in Mathlib (`Matrix.trace`, `Matrix.pow`), giving an immediate\nattack route.\n\n## Direction 2 \u2014 Fixed-point count is `tr(T\u1d63\u207f)` for a 4\u00d74 GF(2)-transfer matrix.\n\n**Conjecture.** For every rule `r` there is an explicit `0/1` matrix `T_r` indexed by\n2-cell windows such that `Nat.card {s : Config n // isFixed (g r) s} = trace (T_r\u207f)`,\nand the asymptotic growth rate equals the Perron eigenvalue `\u03c1(T_r)`; the variety\n\"dimension\" is `log\u2082 \u03c1(T_r)`, a rule-intrinsic real number.\n\n**The key insight is** that the fixed-point set is a *subshift of finite type*, so its\ncardinality is governed by a transfer matrix exactly as in statistical mechanics \u2014\nturning a combinatorial count into linear algebra.\n\n**Why now?** We verified the pattern computationally (Rule 90: `1,1,4,1,1,4,\u2026`,\nperiod-3 because `\u03c1` has a cube-root-of-unity spectrum; Rule 204: `2^n` because\n`\u03c1 = 2`). Proving `#fix = tr(T\u207f)` for the five formalized rules is a finite, bounded\ntarget that would convert every numeric observation in the Lab Notes into a theorem.\n\n## Direction 3 \u2014 `3 \u2223 n \u21d4 Rule 90 has a nonzero fixed point`.\n\n**Conjecture.** The Rule 90 fixed-point subspace `linearFixed 1 0 1` over `Config n`\nhas dimension `> 0` if and only if `3 \u2223 n`; equivalently the circulant operator\n`x \u21a6 x_{i-1} + x_{i+1} \u2212 x_i` is singular over `GF(2)` exactly when `3 \u2223 n`. More\ngenerally the dimension equals `deg gcd(t\u00b2 + t + 1, t\u207f \u2212 1)` in `GF(2)[t]`.\n\n**The key insight is** that a linear ECA's fixed-point dimension is a *cyclotomic*\nquantity: it counts roots of the rule's characteristic polynomial among the `n`-th\nroots of unity, so number theory (orders mod small primes) governs the geometry.\n\n**Why now?** We proved a nonzero fixed point exists at `n = 3`\n(`rule90_nontrivial_fixed_three`) and `linearFixed_card_pow_two` already exposes the\ndimension as `finrank`. Mathlib's `Polynomial.cyclotomic` and circulant-matrix\nsupport make the gcd characterization directly reachable.\n\n## Direction 4 \u2014 Linearity is *decidable from the variety* up to the converse gap.\n\n**Conjecture.** A rule `r` is GF(2)-linear iff its fixed-point variety is closed under\naddition for *all* lengths `n` simultaneously; a single length can fail (the converse\ngap noted by the Critic: Rule 0 and Rule 110 both give count `1 = 2\u2070` yet only Rule 0\nis linear). Precisely: `(\u2200 n, IsSubmodule (fixed r n)) \u2194 r \u2208 {0,60,90,102,150,170,204,240,\u2026}`\n(the 8 additive rules and their reflections).\n\n**The key insight is** that linearity is a *global* property of the whole tower of\nvarieties `{V_n}`, not of any single `V_n` \u2014 closure-at-one-`n` is necessary but not\nsufficient, which is why our safe-direction lemma (`g110_not_linear`) certifies\nnonlinearity pointwise rather than from a single count.\n\n**Why now?** This cycle isolated the exact converse counterexample (count `1` is\nrealized by both a linear and a nonlinear rule), so the precise boundary is known and\nready to be formalized as an `Iff` over the finite catalogue of additive rules.\n\n## Direction 5 \u2014 Affine rules give *cosets*; the empty variety detects an inhomogeneity.\n\n**Conjecture.** A rule with affine ANF `f = \u2113(a,b,c) + 1` (a linear part plus the\nconstant `1`, e.g. Rule 51 `= b + 1`) has fixed-point variety either empty or a\n*coset* of `linearFixed \u2113`; it is empty exactly when `1 \u2209 image(\u2113 \u2212 id)`. Thus the\nempty variety (`rule51_not_isFixed`) is the GF(2) shadow of an unsolvable affine\nsystem, and `#fix \u2208 {0} \u222a {2^k}`.\n\n**The key insight is** that the constant term in the ANF turns the *kernel* (subspace)\ninto an *affine* solution set, so the dichotomy \"empty vs. power-of-two coset\" is the\nRouch\u00e9\u2013Capelli theorem over `GF(2)` applied to cellular automata.\n\n**Why now?** We already proved Rule 51's variety is empty for all `n`; recasting that\nas the inconsistency of an affine GF(2) system, via Mathlib's `LinearMap.range` and\ncoset API, would unify the linear (Direction 1\u20133) and degenerate cases under one\nsolvability criterion.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2059",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "16b03c84",
    "status": "available",
    "timestamp": "2026-06-17T16:03:35.875808+00:00",
    "title": "These conjectures are distilled from the v16a research cycle in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 The Mathematics of Jigsaw Puzzles: NP-Completeness and Topology\n\nThis cycle produced `Catalog/Logic/JigsawPuzzles.lean`, a self-contained, fully\nverified (0 `sorry`) theory of edge-matching jigsaw puzzles connected to the\nexisting complexity framework in `Catalog/Logic/PvsNPFoundations.lean`. It\ncovers: the \u2124/4 rotational symmetry of a piece (`rotate_order_four`,\n`rotate_bijective`), the discrete Euler/handshake identity for the board\n(`board_handshake`), the local matching constraint with monochromatic solvability\n(`monochromatic_solvable`), brute-force decidability over finite palettes\n(`solvable_decidable`), abstract NP membership of the solvability language\n(`puzzle_inNP`), NP closure under reductions / union / intersection\n(`inNP_of_reducible`, `inNP_union`, `inNP_inter`), and the hardness bridge\n(`inNP_of_hard`).\n\nThe following conjectures are precise, falsifiable targets for follow-up cycles.\n\n## Conjecture 1 (Karp reduction: 3-Partition \u21aa edge matching)\nFormalize a many-one reduction `ManyOneReducible PARTITION_LANG (SolvableLang Color m n)`\nfor an explicitly constructed color alphabet and gadget pieces, where\n`PARTITION_LANG` is a Lean-formalized NP-hard partition/packing language. Combined\nwith the existing `puzzle_inNP` and the `inNP_of_hard` bridge, this would yield a\nmachine-checked statement that edge matching is NP-complete relative to that base\nlanguage. Testable milestone: prove the reduction's forward direction\n(`x \u2208 PARTITION \u2192 Solvable`) via an explicit placement.\n\n## Conjecture 2 (1D puzzles are tractable \u2014 Eulerian path characterization)\nA single-row board (`m = 1`) is solvable **iff** the multiset of available pieces\nadmits an Eulerian-trail ordering of the \"color transition\" multigraph whose\nvertices are colors and whose edges are pieces `(west, east)`. Formalize this\nequivalence and conclude that 1-row solvability is decidable in polynomial time,\nin sharp contrast to the 2D case. The catalog identity `interiorAdj_single_row`\n(`= n - 1`) is the combinatorial seed: a row is a path with `n-1` constraints.\n\n## Conjecture 3 (Topological lower bound on color count)\nIf an `m \u00d7 n` board with `m, n \u2265 2` has a **unique** valid placement up to the\ntrivial symmetry, then the number of distinct edge colors used is at least\n`interiorAdj m n / 2 + 1`. Intuition: uniqueness forces interior edges to be\n\"keyed\" distinctly enough to break the grid graph's automorphisms. A first\nformal step is to bound, for a fixed valid placement, the number of *alternative*\nplacements by the number of repeated interior colors.\n\n## Conjecture 4 (Certificate-complexity / counting hierarchy)\nDefine `#Solutions C m n` as the cardinality of `{P : Placement C m n // Valid P}`\n(finite by `solvable_decidable`). Conjecture: the map `(m, n) \u21a6 #Solutions` over a\nfixed `k`-color palette satisfies a transfer-matrix recurrence in `n` of order\nbounded by `k^k` (a \"puzzle transfer matrix\"). Formalizing the transfer matrix and\nproving the recurrence would place the counting version `#EDGE-MATCH` in `#P` and\ngive exact generating functions for fixed-height strips.\n\n## Conjecture 5 (Rotation-quotient and the dihedral upgrade)\nThe current model fixes orientations. Extend `rotate` (the \u2124/4 action,\n`rotate_order_four`) to the full dihedral action `D\u2084` by adding reflections, and\nconjecture that allowing free rotation of pieces strictly enlarges the solvable\nlanguage but preserves NP membership: `InNP (SolvableUpToRotation C m n) (Placement C m n \u00d7 (Fin m \u2192 Fin n \u2192 ZMod 4))`.\nThe added `ZMod 4` component is the per-cell rotation certificate; proving the\nverifier remains decidable upgrades `puzzle_inNP` to the oriented-piece setting.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2060",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "cb56480f",
    "status": "available",
    "timestamp": "2026-06-17T16:38:09.039251+00:00",
    "title": "`Catalog/Logic/JigsawPuzzles.lean`, a self-contained, fully"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 *Isomorphisms of Meaning: When Structures Collide*\n\nThis cycle established two anchor results (see `Catalog/Bridges/StructuralCollisions.lean`\nand `Catalog/Bridges/BooleanLogicField.lean`):\n\n* **A1.** A bare ring satisfying the single law `x*x = x` is *forced* to have\n  characteristic two and to be commutative, and its multiplication **is** the\n  greatest-lower-bound (meet) of the order `a \u2264 b \u2194 a*b = a`. (Algebra \u21d2 Order.)\n* **A2.** Propositional logic `(Bool, xor, and)` **is** the field `ZMod 2`, via an explicit\n  `RingEquiv Bool (ZMod 2)`; `&&` is simultaneously the ring product and the order meet\n  (cross-linked to A1). (Logic \u2245 Algebra.)\n\nThe following conjectures are concrete, falsifiable next targets for the same theme.\n\n---\n\n### C1. Symmetric difference is an \ud835\udd3d\u2082-vector space (Set \u2245 Algebra)\nFor any type `\u03b1`, the powerset `Set \u03b1` with symmetric difference `\u25b3` as addition and\nintersection `\u2229` as multiplication is a *Boolean ring*: `s \u2229 s = s`, `s \u25b3 s = \u2205`, and the\norder induced by A1 is set inclusion with `s \u2293 t = s \u2229 t`.\n**Testable form:** instantiate the A1 abstractions (`add_self`, `mul_comm'`, `mul_isGLB`)\nat `Set \u03b1`/`Finset \u03b1` and prove `StructuralCollisions.le s t \u2194 s \u2286 t`, identifying the\nA1-meet with `\u2229`. Predicts every finite Boolean algebra is an \ud835\udd3d\u2082-module of dimension\n`= #atoms`.\n\n### C2. Stone-type rigidity of the collision\nThe isomorphism `Bool \u2243+* ZMod 2` is the *unique* ring isomorphism, and more generally any\nring homomorphism `R \u2192 S` between Boolean rings is automatically a lattice homomorphism for\nthe A1-induced orders (`a \u2264 b \u2192 f a \u2264 f b`), and conversely a bounded-lattice hom of finite\nBoolean algebras is a ring hom.\n**Testable form:** prove `Subsingleton (Bool \u2243+* ZMod 2)`, and prove\n`f (a*b) = f a * f b \u2192 (StructuralCollisions.le a b \u2192 StructuralCollisions.le (f a) (f b))`\nfor a `RingHom` between Boolean rings.\n\n### C3. Idempotence is the *exact* boundary of the collapse\nThe forced-commutativity phenomenon (A1) is special to the exponent law `x^2 = x`.\n**Conjecture:** for each fixed `n \u2265 2`, a ring with `\u2200 x, x^n = x` is commutative\n(Jacobson's theorem). The cases `n = 2` (done) and `n = 3` should be provable by elementary\nexpansion; general `n` is the deep target.\n**Testable form:** prove the `n = 3` case `(\u2200 x, x*x*x = x) \u2192 \u2200 a b, a*b = b*a` from scratch\n(no Mathlib `Jacobson` import), then attempt `n = 4`.\n\n### C4. The order/algebra collision lifts to a categorical equivalence\nThe constructions of A1 should assemble into an equivalence of categories between *finite\nBoolean rings with ring homs* and *finite Boolean algebras with bounded-lattice homs*, with\nobject map `R \u21a6 (R, \u2264_{a*b=a})` and inverse given by symmetric difference (C1).\n**Testable form:** build the two functors on objects + morphisms in Lean and prove the\nround-trips are identities on `Bool`, `ZMod 2`, and `Set (Fin n)`.\n\n### C5. A \"no-collision\" obstruction in characteristic \u2260 2\nThe collision in A1/A2 is a characteristic-two miracle. **Conjecture:** there is *no*\nnonzero ring `R` with `\u2200 x, x*x = x` and `(1 : R) + 1` a unit; equivalently, idempotence\nforbids odd characteristic.\n**Testable form:** prove `(\u2200 x : R, x*x = x) \u2192 (2 : R) = 0`, and deduce that a Boolean ring\nthat is also a field must be `ZMod 2` (so `Bool`), pinning A2 as the unique field-collision.\n",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_2062",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "61934e8a",
    "status": "available",
    "timestamp": "2026-06-17T17:23:46.154534+00:00",
    "title": "Two anchor results (see `Catalog/Bridges/StructuralCollis"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 The Fermi Paradox as a Pigeonhole Principle\n\nDerived from the verified results in this cycle:\n\n* `FirstMoment.lean` \u2014 the first moment method over finite weighted spaces\n  (`exists_zero_of_expectation_lt_one`, `prob_zero_ge_one_sub_expectation`).\n* `DrakeBound.lean` \u2014 the conservative Drake inequality (`drake_expected_lt_one`,\n  `prod_le_pow_of_forall_le`) and its fusion with the pigeonhole\n  (`fermi_alone_under_conservative_drake`).\n* `Bridge.lean` \u2014 the cross-domain `fermi_resonant_listening_window`, combining\n  the Pythagorean averaging lemma with the Fibonacci strong-divisibility law.\n\nEach conjecture below is falsifiable and stated so it can be formalized next.\n\n---\n\n## C1. The empty-set lower bound is *tight* up to the integrality gap.\n\n**Conjecture.** For every finite weighted space with expectation `E < 1`, the\ntotal weight of the zero set satisfies `1 \u2212 E \u2264 w(Z) \u2264 1`, and the lower bound\n`1 \u2212 E` is attained exactly when the nonzero outcomes all equal `1` (a Bernoulli\nsupport).  Conversely, if `w(Z) = 1 \u2212 E` then `X` is `{0,1}`-valued on its\nsupport.\n\n*The key insight is...* that `prob_zero_ge_one_sub_expectation` only used\n`X i \u2265 1` on the complement, so equality forces `X i = 1` there \u2014 the slack in\nthe bound is exactly `\u2211_{X\u22652} w_i (X_i \u2212 1)`, a nonnegative \"over-counting\" term.\n\n**Why now?** We already proved the inequality in `prob_zero_ge_one_sub_expectation`;\ncharacterizing its equality case is the immediate next refinement and needs only\na careful `Finset.sum_eq_zero` argument on the slack term.\n\n---\n\n## C2. A \"second moment\" companion forces *non-empty* outcomes when `E > 1`.\n\n**Conjecture.** If `E = \u2211 w\u1d62 X\u1d62 > 1` and the variance is controlled\n(`\u2211 w\u1d62 X\u1d62\u00b2 \u2264 C\u00b7E\u00b2`), then `w({X \u2265 1}) \u2265 E\u00b2/(C\u00b7E\u00b2) = 1/C`: with civilizations\nexpected *and* not too clustered, contact is likely.\n\n*The key insight is...* that the first moment method is one half of a dichotomy;\nthe Paley\u2013Zygmund inequality is its mirror, turning `E > 1` into a positive\nprobability of a *non-empty* cosmos.\n\n**Why now?** Our `FirstMoment.lean` machinery (finite weighted sums in `\u211a`,\n`Finset.sum_le_sum`) is exactly the substrate needed for Cauchy\u2013Schwarz over a\n`Finset`, so the second-moment bound is a natural sequel rather than new theory.\n\n---\n\n## C3. The Drake bound is *dimension-robust*: hurdles, not values, decide it.\n\n**Conjecture.** For any list of independent hurdle probabilities each `\u2264 1/10`,\n`Nplanets \u2264 10\u00b9\u2070`, and at least `11` hurdles, the expected number of\ncivilizations is `< 1` \u2014 regardless of the precise per-hurdle values.\n\n*The key insight is...* that `prod_le_pow_of_forall_le` bounds the product by\n`(1/10)^(#hurdles)`, so the *count* of independent filters, not optimistic\ntuning of any single one, is what drives `E` below `1`.\n\n**Why now?** `prod_le_pow_of_forall_le` is already proved; combining it with\n`drake_expected_lt_one` via `pow_le_pow_right_of_le_one` closes the conjecture\nwith no new infrastructure.\n\n---\n\n## C4. Resonant listening times are *stable under window perturbation*.\n\n**Conjecture.** If two dense families `F`, `F'` over `U` differ in at most `k`\nwindows, then they share a resonant listening time whenever\n`8k < |F|` \u2014 the pigeonhole witness of `fermi_resonant_listening_window`\nsurvives small observational noise.\n\n*The key insight is...* that the averaging lemma's slack (`miss \u2264 |F|/4`) leaves\nroom: removing or adding `k` windows shifts the incidence count by `\u2264 k`, so the\n`3/4` majority is preserved while `8k < |F|`.\n\n**Why now?** `fermi_resonant_window_coverage` already exposes the `3\u00b7|F| \u2264\n4\u00b7hit` margin; a perturbation lemma is a direct `omega`-style consequence of that\ninequality plus `Finset.card_union_le`.\n\n---\n\n## C5. Fibonacci signal resonance yields a *shared detector frequency*.\n\n**Conjecture.** At the resonant time `a` of `fermi_resonant_listening_window`,\nif every active civilization's epoch is divisible by a common `d`, then `fib d`\ndivides the gcd of *all* their Fibonacci signals \u2014 a single divisor witnesses\nuniversal resonance.\n\n*The key insight is...* that `IsStrongDivSeq.dvd_gcd_index_iff` lifts pairwise\ndivisibility to the whole active family by induction on the window set, turning\nthe bridge's pointwise meet law into a global one.\n\n**Why now?** Both ingredients \u2014 the resonant witness and the meet law\n(`StrongDivSeq.IsStrongDivSeq.dvd_gcd_index_iff`) \u2014 are imported and proved in\n`Bridge.lean`; the global statement is a `Finset.induction` away.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2064",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "9ff40964",
    "status": "available",
    "timestamp": "2026-06-17T19:24:15.522105+00:00",
    "title": "Derived from the verified results in this cycle:"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Hypergraph Ramsey Theory: Beyond Graphs\n\nThis cycle formalized, with zero `sorry`, a self-contained 2-color Ramsey theory\nfor `r`-uniform hypergraphs over the `Finset (Fin n) \u2192 Bool` coloring model:\n\n- **Structural laws** (`Defs.lean`): color symmetry, monotonicity in the vertex\n  count (via an embedding transport), monotonicity in clique size, and the\n  vacuous degenerate regime `k < r`.\n- **Probabilistic lower bound** (`LowerBound.lean`): the Erd\u0151s first-moment\n  argument `2\u00b7C(n,k) < 2^{C(k,r)} \u27f9 R_r(k,k) > n`, with concrete instances\n  `R_3(5,5) > 11` and `R_3(6,6) > 29`.\n- **Growth separation** (`Separation.lean`): the explicit floor\n  `R_3(k,k) > 2^m` whenever `k\u00b7m + 1 < C(k,3)` (giving `2^{\u03a9(k\u00b2)}`), the tower\n  function `tower 2 k = 2^{2^k}`, and the strict separation\n  `2^{k\u00b2} < 2^{2^k}` for `k \u2265 5`.\n\nThe findings below are derived directly from what survived (and what resisted)\nthe team loop.\n\n---\n\n## Conjecture 1 \u2014 The explicit floor is `2^{\u230a(C(k,3)\u22121)/k\u230b}`, and it is the best the first moment can give\n\n**Statement.** For every `k \u2265 3`, `R_3(k,k) > 2^{m_k}` where\n`m_k = \u230a(C(k,3) \u2212 2)/k\u230b`, and no first-moment argument over the uniform random\ncoloring yields any larger floor (the threshold `2\u00b7C(n,k) < 2^{C(k,3)}` is\nviolated for `n = 2^{m_k+1}` once `k` is large).\n\n**The key insight is** that the affordable exponent in `R3_exp_lower_bound` is\nbudgeted by `k\u00b7m + 1 < C(k,3)`, so `m` can grow only like `C(k,3)/k \u2248 k\u00b2/6` \u2014\nthe quadratic exponent is a *hard ceiling* of the first moment, not a loose\nconstant.\n\n**Why now?** `R3_exp_lower_bound` already isolates the budget inequality as a\nsingle hypothesis, so the optimization `max m s.t. k\u00b7m+1 < C(k,3)` is a finite,\nfully formal arithmetic problem \u2014 provable today by `omega`-style reasoning.\n\n---\n\n## Conjecture 2 \u2014 A formal stepping-up lemma closes the floor\u2013ceiling gap to a true double exponential\n\n**Statement.** There is a constant `c > 0` and a Lean-provable inequality\n`R_3(k+1,k+1) \u2264 2^{R_2(k,k)} + 1`, which composed with `R_2(k,k) \u2264 4^k` yields\n`R_3(k,k) \u2264 tower 2 (c\u00b7k) = 2^{2^{c\u00b7k}}`.\n\n**The key insight is** that `single_exp_lt_double_exp` already certifies\n`2^{k\u00b2} < tower 2 k`: the floor we proved lies *strictly inside* the conjectured\nceiling, so the open problem is precisely to raise the floor or lower the ceiling\nacross this verified gap.\n\n**Why now?** The `tower` function and its double-exponential identity\n`tower_two` are in place, so an Erd\u0151s\u2013Rado stepping-up formalization can be\nstated against a concrete, already-proved target rather than informal asymptotics.\n\n---\n\n## Conjecture 3 \u2014 Off-diagonal hypergraph Ramsey numbers are polynomially skew\n\n**Statement.** For fixed `r` and `l`, `R_r(k,l)` grows only polynomially in `k`\n(degree `\u2248 l \u2212 1`), in sharp contrast to the double-exponential diagonal \u2014 i.e.\n`R_3(k,l) = k^{\u0398(l)}` for fixed `l`.\n\n**The key insight is** that `hyperRamsey_color_symm` makes the two clique sizes\ninterchangeable, so the asymmetry must come entirely from the *smaller* side `l`\ncontrolling the C(k,r) edge budget; the counting bound degrades to a polynomial\nwhen one side is bounded.\n\n**Why now?** `hyperRamsey_counting_lower_bound` is already stated for the general\ndiagonal and `hyperRamsey_color_symm`/`hyperRamsey_mono_clique` give the\noff-diagonal scaffolding for free; only the asymmetric counting estimate remains.\n\n---\n\n## Conjecture 4 \u2014 The uniformity hierarchy is strict: each extra layer adds one exponential\n\n**Statement.** `R_{r+1}(k,k)` is bounded between `tower (r-1) (\u03a9(k))` and\n`tower (r-1) (O(k))`; equivalently, increasing the uniformity `r` by one raises\nthe tower height by exactly one for every `k` large enough.\n\n**The key insight is** that the tower height in `single_exp_lt_double_exp`\nalready encodes \"number of exponentials,\" so a strict hierarchy is the statement\nthat the height in the lower bound and upper bound agree level-by-level with `r`.\n\n**Why now?** `tower` is defined for arbitrary height and `R3_exp_lower_bound`\ngeneralizes verbatim to `R_r` (the proof only used `C(n,k) \u2264 n^k` and the\n`C(k,r)` budget), so the `r`-indexed hierarchy is one induction away.\n\n---\n\n## Conjecture 5 \u2014 Constructive (derandomized) colorings match the probabilistic floor\n\n**Statement.** There is an explicit, polynomial-time-describable family of\n2-colorings of the 3-subsets of `Fin (2^m)` (e.g. via a finite-field or\nbinary-string \"stepping-up\" construction) with no monochromatic\n`k`-clique whenever `k\u00b7m + 1 < C(k,3)` \u2014 matching `R3_exp_lower_bound`\nwithout invoking the averaging/pigeonhole step.\n\n**The key insight is** that the current proof is *existential* (pigeonhole over\nall `2^{C(n,r)}` colorings); the same floor should be witnessed by a *named*\ncoloring, turning an averaging argument into a verifiable construction.\n\n**Why now?** The model `Finset (Fin n) \u2192 Bool` is already computable, so a\ncandidate explicit coloring can be `#eval`-tested against small `k, m` before\nattempting the general proof \u2014 the experiment loop is immediately runnable.\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2065",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "949d41e5",
    "status": "available",
    "timestamp": "2026-06-17T19:26:29.748902+00:00",
    "title": "This cycle formalized, with zero `sorry`, a self-contained 2-color Ramsey theory"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 The Prime Number Crossword\n\nThis cycle established the two boundary facts of the prime crossword in\n`Cryptography/PrimeGaps/`:\n\n* `exists_consecutive_composites` / `gaps_unbounded` \u2014 gaps are arbitrarily wide;\n* `gaps_unbounded_cofinal` \u2014 arbitrarily wide gaps occur arbitrarily far out;\n* `nextPrime_sub_le` \u2014 every gap above a prime `p` is at most `p` (Bertrand).\n\nBelow are falsifiable conjectures for the next cycle. Each is stated so that it\ncan be formalized directly as a Lean theorem about `PrimeGaps.nextPrime`.\n\n## C1. A quantitative Bertrand gap bound, sharpened\n**Conjecture.** For every prime `p \u2265 5`, `nextPrime p - p \u2264 p / 2`, and more\nstrongly the relative gap `(nextPrime p - p) / p \u2192 0`.\n*Formalization target:* prove `\u2200 p, p.Prime \u2192 5 \u2264 p \u2192 nextPrime p - p \u2264 p / 2`\nusing Nagura-type explicit estimates (prime in `(n, 6n/5]` for `n \u2265 25`).\n*Falsifiable:* a single prime with gap exceeding `p/2` refutes it.\n\n## C2. Average gap matches the logarithm (Prime Number Theorem flavor)\n**Conjecture.** The mean gap up to `x`, `x / \u03c0(x)`, grows like `log x`. A first\nformal milestone: `\u2200 x \u2265 2, \u03c0(x) \u2264 x` paired with a lower bound\n`\u03c0(x) \u2265 c \u00b7 x / log x`. *Target:* connect `nextPrime` iterates to `Nat.primeCounting`\nin Mathlib and prove `nextPrime p - p` has Ces\u00e0ro average `\u0398(log p)`.\n\n## C3. Maximal gap function is well defined and unbounded but slowly growing\n**Conjecture.** `G(x) := max { nextPrime p - p : p prime, p \u2264 x }` satisfies\n`G(x) \u2264 x` (immediate from Bertrand) and `G(x) \u2192 \u221e` (immediate from\n`gaps_unbounded_cofinal`), while conjecturally `G(x) = O((log x)^2)` (Cram\u00e9r).\n*Target:* formalize `G` as a `Finset.sup`, prove the two unconditional bounds,\nand state Cram\u00e9r's `O((log x)^2)` bound as an open hypothesis.\n\n## C4. Twin-gap dichotomy / Polignac\n**Conjecture (Polignac, open).** Every even number `2k` is a gap between\nconsecutive primes infinitely often: `\u2200 k \u2265 1, {p : nextPrime p - p = 2k}` is\ninfinite. *Target:* state precisely with `Set.Infinite`; as a tractable\nsub-result prove the *finite* version \u2014 for each `k` there is at least one prime\ngap of size `\u2265 2k` (already implied by `gaps_unbounded`) and search for explicit\nsmall-`k` witnesses via `native_decide`.\n\n## C5. Cryptographic safe-prime spacing\n**Conjecture.** Safe primes (`p` with `(p-1)/2` also prime) exhibit the same\ngap-unboundedness: `\u2200 N, \u2203 p, p` safe-prime `\u2227 nextSafePrime p - p \u2265 N`.\n*Target:* define `SafePrime` and `nextSafePrime`, then transport the factorial /\nbracketing construction. This directly models the cost of safe-prime search in\nDiffie\u2013Hellman parameter generation.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2068",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "21cfd7dd",
    "status": "available",
    "timestamp": "2026-06-17T23:11:17.377449+00:00",
    "title": "Two boundary facts of the prime crossword in"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Category Theory as a Universal Language (Bridge cycle)\n\nDerived from the Stage 3 (Analysis) and Stage 4 (Critique) findings of this\ncycle. Each conjecture is bold, falsifiable, and Lean-checkable.\n\n## FD-1. The regular subobjects of a topos form a Boolean algebra.\n\n**Conjecture.** For every `Order.Frame \u03b1`, the fixed points of the double-negation\nnucleus (`{a | ToposDoubleNegationLattice.IsRegular a}`) carry a\n`BooleanAlgebra` structure whose meet is `\u2293`, whose top/bottom are `\u22a4`/`\u22a5`, and\nwhose complement is `a\u1d9c`, with join given by `a \u2294' b := (a\u1d9c \u2293 b\u1d9c)\u1d9c`.\n\nThe key insight is... that meet-preservation (`dneg_inf`) plus idempotence make\n`dneg` a *nucleus*, and the sheafification `a \u21a6 a\u1d9c\u1d9c` collapses intuitionistic\nlogic to classical logic exactly on its fixed points \u2014 Booleanness is forced, not\nassumed.\n\nWhy now? We already proved closure under `\u2293` (`isRegular_inf`) and the bounds\n(`isRegular_bot/top`); only the (de Morgan) join and complement laws remain, all\nexpressible with the same `compl`/`himp` API verified in this cycle.\n\n## FD-2. The Yoneda iso-corollary upgrades to an equivalence of groupoids.\n\n**Conjecture.** The map `X \u21a6 yoneda.obj X` induces an equivalence between the core\ngroupoid of `C` and the full subcategory of representable presheaves, and\n`iso_iff_representable_iso` is its object-level shadow.\n\nThe key insight is... that full faithfulness (the single fact powering\n`isoPreimage` and `endEquiv`) is exactly the data of an equivalence onto the\nessential image, so the `Nonempty (\u00b7 \u2245 \u00b7)` biconditional is the \u03c0\u2080 of a deeper\ncategorical equivalence.\n\nWhy now? `Yoneda.fullyFaithful` is in scope and `endEquiv_comp`/`endEquiv_one`\nalready show the hom-level functoriality; the essential-image construction is the\nonly missing ingredient.\n\n## FD-3. `dneg` is the unique non-trivial Lawvere\u2013Tierney topology on a chain.\n\n**Conjecture.** On a totally ordered frame (a chain) `\u03b1`, every nucleus\n`j : \u03b1 \u2192 \u03b1` (monotone, extensive, idempotent, meet-preserving) other than the\nidentity equals the double-negation nucleus `dneg` collapsed onto `{\u22a5, \u22a4}`; i.e.\nchains admit only the trivial and the double-negation topologies.\n\nThe key insight is... that on a chain `a\u1d9c` is `\u22a4` for `a = \u22a5` and `\u22a5` otherwise,\nso `dneg` is the indicator of \"`> \u22a5`\", and any idempotent extensive monotone\nself-map respecting `\u2293` is pinned by its values at the two bounds proved regular\nhere (`dneg_bot`, `dneg_top`).\n\nWhy now? The nucleus axioms are all formalized in this file; the chain case is a\nfinite/order-induction argument (`omega`/`rcases` on comparisons) well within\nreach.\n\n## FD-4. Knaster\u2013Tarski computes sheafification of any nucleus, not just `dneg`.\n\n**Conjecture.** For an arbitrary nucleus `j` on a frame, the least fixed point\n`sInf (KnasterTarskiBridge.preFixed j)` above an element `a`, i.e.\n`sInf {x | a \u2264 x \u2227 j x \u2264 x}`, equals `j a`, exhibiting sheafification as the\nKnaster\u2013Tarski least-fixed-point closure relative to `a`.\n\nThe key insight is... that a nucleus is precisely a meet-preserving closure\noperator, so its image is the set of fixed points, and the catalog's\n`knaster_tarski` already delivers those fixed points constructively \u2014 we proved\nthe `a = \u22a5` and `a = \u22a4` extremes (`lfp_dneg_eq_bot`, `gfp_dneg_eq_top`).\n\nWhy now? The bridge between `dneg` and `KnasterTarskiBridge` is already wired\n(`dneg_knaster_tarski`); generalizing from `dneg` to an abstract nucleus reuses\nthe identical fixed-point lemmas.\n\n## FD-5. The frame of opens detects regularity geometrically.\n\n**Conjecture.** For `Opens X`, `IsRegular U \u2194 U = interior (closure U)`, and the\nregular opens are exactly the complemented elements of the Heyting algebra\n`Opens X`; hence `X` is extremally disconnected iff every open is regular.\n\nThe key insight is... that `U\u1d9c\u1d9c` in `Opens X` is interior-of-closure, so\n`dneg`-fixed points are the classical *regular open sets*, linking the abstract\nnucleus to a checkable point-set condition.\n\nWhy now? `opens_dneg_inf` and `opens_isRegular_*` already specialize the nucleus\nto `Opens X`; identifying `dneg` with interior\u2218closure is a single Mathlib lemma\naway and turns regularity into a topological invariant.\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2120",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "5d803a6e",
    "status": "available",
    "timestamp": "2026-06-19T17:15:33.749896+00:00",
    "title": "Derived from the Stage 3 (Analysis) and Stage 4 (Critique) findings of this"
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
    "consumed_by_exp_id": "43fe3cd5",
    "description": "Conjecture: The entanglement\u2011complexity scaling law of a uniformly random rank\u2011k tensor network on N vertices undergoes a sharp phase transition at a critical bond dimension D_c(N) such that for D > D_c the network\u2019s holographic geometry approximates a smooth (d+1)\u2011dimensional Lorentzian manifold with Ricci curvature bounded by a universal constant, while for D < D_c the geometry is fractal and fails to satisfy the Einstein equations in any coarse\u2011graining. Test: Generate large\u2011scale random tensor networks on high\u2011performance clusters, compute their entanglement spectra and bulk geometry via the quantum error\u2011correcting code correspondence, and measure curvature proxies (e.g., spectral dimension, Ricci flow convergence). Observation of a reproducible threshold D_c(N) with the predicted geometric properties confirms the conjecture; absence of such a transition or mismatch of curvature bounds refutes it. Impact: Provides a falsifiable, computationally grounded bridge between quantum information complexity and the emergence of classical spacetime, offering a new avenue to derive Einstein\u2019s equations from complexity theory, guide quantum gravity model selection, and inspire complexity\u2011optimal quantum error\u2011correcting codes.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "id": "fd_2119",
    "priority_score": 0.7158260869565218,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "in_progress",
    "timestamp": "2026-06-19T17:11:08.928185+00:00",
    "title": "Complexity\u2011Driven Emergence of Spacetime from Random Tensor Networks"
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
    "consumed_by_exp_id": "",
    "description": "Formalize ODEs of the form y' = R(x,y) where R is an EML function. Prove the differential Galois theory for EML equations: the Galois group is an EML group. Show that the Kovacic algorithm decides if a second-order linear EML ODE has EML solutions. Prove that Airy's equation y'' = xy has no EML solutions.",
    "domains": [
      "EML",
      "Computation"
    ],
    "id": "fd_0551",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
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
    "description": "Conjecture: For any finite-type moduli space M of algebraic curves or polarized varieties equipped with its natural orbifold metric, there exists a family of width-increasing geometric neural networks whose neural tangent kernels converge, after explicit metric normalization, to a universal operator determined by the Laplace-Beltrami spectrum of M, and this limiting kernel predicts generalization error solely from low-lying spectral data. Test: Construct such networks on sampled points from moduli spaces of low genus curves, K3 surfaces, or abelian varieties; compute empirical neural tangent kernels as width grows; compare their spectra and learning curves against the conjectured Laplace-Beltrami-derived limit. Confirmation requires convergence across architectures and tasks to the same spectral law and error predictor; refutation occurs if limiting kernels depend essentially on architecture details or fail to correlate with geometric spectral invariants. Impact: This would connect deep learning universality to arithmetic geometry, provide a principled theory of learning on highly singular geometric parameter spaces, and enable geometry-aware model design using moduli-space spectra.",
    "domains": [
      "Algebra",
      "MachineLearning"
    ],
    "id": "fd_2007",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-06-16T10:48:58.195627+00:00",
    "title": "Spectral Universality of Neural Tangent Kernels on Moduli Spaces"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any sufficiently expressive finitely presented formal system S (e.g. arithmetic-strength theorem proving with a fixed proof encoding), the graph G_n of derivable statements and minimal proof transformations up to proof length n exhibits a nontrivial renormalization-group fixed point: after coarse-graining proofs by local rewrite equivalence classes and rescaling path lengths by a system-dependent factor, the sequence of normalized graph Laplacian spectra converges as n -> infinity to a universal limiting measure depending only on the logical complexity class of S, not on syntactic presentation. Test: Construct proof-search graphs for multiple inequivalent presentations of the same theory and for theories of different strength; define explicit coarse-graining via proof normalization/rewrite neighborhoods; numerically compare spectral measures across scales. The conjecture is supported if presentations within the same complexity class flow to the same limiting spectrum and refuted if no stable scale-invariant spectrum appears or if the limit depends sensitively on encoding details. Impact: This would found a statistical physics of mathematics, yielding universality classes for theorem proving, new complexity invariants of formal systems, and principled ways to predict proof hardness and design more efficient automated reasoning heuristics.",
    "domains": [
      "Logic",
      "Physics"
    ],
    "id": "fd_2035",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-06-17T01:06:18.568136+00:00",
    "title": "Renormalization Fixed Points of Formal Proof Search"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For broad families of formal proof systems and parameterized theorem ensembles (e.g. random k-SAT, bounded-depth arithmetic identities, and finite combinatorial statements), there exists a renormalization-group flow on proof instances such that proof complexity classes correspond to universality classes, with a measurable critical point where typical shortest-proof length changes from polynomial to exponential scaling under coarse-graining. Test: Define explicit coarse-graining operators on proof instances/formulas, compute induced flows numerically and analytically, and check whether distinct theorem ensembles collapse onto the same critical exponents for proof-length growth and solver runtime near the transition; the conjecture is refuted if no stable scale-invariant quantities or universality across ensembles appear. Impact: This would enable a statistical-physics theory of mathematical difficulty, predict when conjectures are likely to be tractable in given proof systems, and guide the design of automated theorem provers by targeting critical structure rather than worst-case syntax.",
    "domains": [
      "Logic",
      "Physics"
    ],
    "id": "fd_2039",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "pi_brainstorm",
    "status": "available",
    "timestamp": "2026-06-17T02:02:28.457322+00:00",
    "title": "Renormalization of Reasoning: Phase Transitions in Theorem-Proving Complexity"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order. with terms 127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,4096,6455,11264,11664,12850,13825,14641,155. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2073",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:80035",
    "status": "available",
    "timestamp": "2026-06-18T01:05:26.622326+00:00",
    "title": "OEIS sequence: \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order."
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence Maximal number of \"good\" manifolds in an n-nice polytope. with terms 6,8,12,24,40,80,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,20971. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2074",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:212351",
    "status": "available",
    "timestamp": "2026-06-18T01:05:26.622694+00:00",
    "title": "OEIS sequence: Maximal number of \"good\" manifolds in an n-nice polytope."
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
    "description": "Define quantum EML neurons where exp and log are replaced by unitary exponentials: U = exp(iH) for Hermitian H, and the log is the matrix logarithm. Conjecture: The quantum EML neuron U = exp(iH1) * log(I+iH2) can implement any single-qubit unitary. Test: parameterize H1, H2 and prove the map covers SU(2). Impact: opens quantum-classical neural network bridges.",
    "domains": [
      "EML",
      "Physics"
    ],
    "id": "fd_0418",
    "priority_score": 0.6299999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.751445+00:00",
    "title": "EML Quantum Activation Functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle 2ec4044e (Q=0.553) proved 7 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Restrict the project to a single self-contained formalization file that completes the finite counting toolkit for binary codes as `Finset (Fin n \u2192 ZMod 2)` and stops before any ambitious convolution t",
    "domains": [
      "Applications"
    ],
    "id": "sorry_fill_2ec4044e_10d6041b",
    "priority_score": 0.6027085714285716,
    "research_mode": "team",
    "source_exp_id": "2ec4044e",
    "status": "available",
    "timestamp": "2026-06-16T11:25:17.680039+00:00",
    "title": "Close Proofs: Tropicalized binary weight enumerator profile from Smooth Poincar\u00e9 cod"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle a0dd96a5 (Q=0.527) proved 50 theorems in Combinatorics but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Refocus the task onto a minimal, standalone finite-dimensional linear-algebra file that avoids proving a new Sylvester inequality from scratch. Define `transEndo : (\u2115 \u2192 V \u2192\u2097[K] V) \u2192 \u2115 \u2192 \u2115 \u2192 V \u2192\u2097[K] V`",
    "domains": [
      "Combinatorics"
    ],
    "id": "sorry_fill_a0dd96a5_00b573d8",
    "priority_score": 0.5771458702064898,
    "research_mode": "team",
    "source_exp_id": "a0dd96a5",
    "status": "available",
    "timestamp": "2026-06-16T12:52:43.615426+00:00",
    "title": "Close Proofs: These conjectures continue the research cycle begun in"
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
    "description": "The Kolmogorov-Arnold theorem says any continuous f: [0,1]^n -> R can be written as a sum of 2n+1 continuous univariate functions. Conjecture: The inner univariate functions in the K-A representation can be chosen to be EML-type functions (exp-log compositions). Test: for n=2, construct the 5 inner functions explicitly as EML compositions that achieve the K-A decomposition for a specific target (e.g., x1*x2). Impact: directly connects EML to a deep representation theorem.",
    "domains": [
      "EML",
      "Algebra"
    ],
    "id": "fd_0416",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T19:55:26.588561+00:00",
    "title": "EML Kolmogorov-Arnold Representation"
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
    "description": "Prove tight upper bounds on the differential probability of an S-box. Formalize the wide-trail strategy used in AES: prove that the minimum number of active S-boxes in 4 rounds of AES is 25. Connect to the branch number of the MixColumns matrix.",
    "domains": [
      "Cryptography",
      "Algebra"
    ],
    "id": "fd_0461",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
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
    "description": "Prove that the class of EML functions forms a differential field: closed under addition, multiplication, composition, and differentiation. Show that the inverse function theorem for EML functions yields EML inverses. Determine whether EML functions are closed under integration.",
    "domains": [
      "EML",
      "Algebra"
    ],
    "id": "fd_0509",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.201625+00:00",
    "title": "EML Differential Algebra: Closure Properties"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that specific EML numbers (like exp(exp(1)) + log(2)) are transcendental over Q. Formalize Schanuel's conjecture for EML functions and prove conditional results: if Schanuel's conjecture holds, then the class of EML numbers equals the class of EL numbers.",
    "domains": [
      "EML",
      "Algebra"
    ],
    "id": "fd_0511",
    "priority_score": 0.5499999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.344784+00:00",
    "title": "EML Number Theory: Transcendence and Algebraic Independence"
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
    "description": "Classify all Pythagorean triples in the Gaussian integers Z[i]. Prove that every primitive triple can be parametrized as (a+bi, c+di, e+fi) where the norm of each entry satisfies the Pythagorean relation. Connect to the arithmetic of quaternionic integers.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_0512",
    "priority_score": 0.3999999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:47.416939+00:00",
    "title": "Pythagorean Triples in Gaussian Integers"
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
    "consumed_by_exp_id": "7a341625",
    "description": "Prove Conway's Game of Life is Turing complete via a direct constructive embedding. Formalize cellular automata in Lean 4 and establish complexity bounds on the simulation overhead.",
    "domains": [
      "Computation",
      "Speculative"
    ],
    "id": "fd_0483",
    "priority_score": 0.3699999999999999,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-03T21:01:45.254223+00:00",
    "title": "Game of Life Universality"
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
    "description": "Formalize integrated information theory (IIT) in Lean 4. Define Phi as a measure on causal structures, prove its key properties (composition, exclusion), and explore connections to category theory and complexity.",
    "domains": [
      "Speculative",
      "Logic"
    ],
    "id": "fd_0481",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-03T21:01:45.101987+00:00",
    "title": "Consciousness as Integrated Information"
  },
  {
    "consumed_by_exp_id": "ddafecee",
    "description": "Explore what theorems hold in non-standard models of arithmetic. Formalize ultrapower constructions, transfer principles, and prove which classical theorems survive in non-Archimedean settings.",
    "domains": [
      "Speculative",
      "Logic"
    ],
    "id": "fd_0482",
    "priority_score": 0.24999999999999992,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-03T21:01:45.177474+00:00",
    "title": "Alien Mathematics: Non-Standard Arithmetic"
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
    "description": "Sperner's lemma states that any proper coloring of a triangulated simplex with n+1 colors has at least one fully colored simplex. This is a combinatorial analog of Brouwer's fixed point theorem. Nash's theorem states that every finite game has a mixed strategy Nash equilibrium, proved using Kakutani's fixed point theorem. Conjecture: Sperner's lemma directly implies Nash's theorem. Specifically, given an n-player game with strategies S_1, ..., S_n, construct the n-simplex Delta = Delta(S_1 x ... x S_n) of mixed strategy profiles. Define a Sperner coloring of Delta by: color vertex v with color i if player i's best response to v is strategy i. By Sperner's lemma, there exists a fully colored simplex. The center of this simplex is an approximate Nash equilibrium (each player is approximately best-responding). Taking the limit as the triangulation gets finer gives an exact Nash equilibrium. Conjecture: this construction gives a constructive proof of Nash's theorem that yields a triangulation-based algorithm for finding Nash equilibria with complexity O(N^{n}) where N is the total number of pure strategies. Test: implement the Sperner-based algorithm for 2-player games and verify it finds all Nash equilibria. Impact: Nash equilibria are combinatorial fixed points. Sperner's lemma is the fundamental theorem of game theory.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "id": "fd_0069",
    "priority_score": 0.05,
    "research_mode": "team",
    "source_exp_id": "seed",
    "status": "available",
    "timestamp": "2026-06-01T12:30:30.676713+00:00",
    "title": "Sperner's Lemma Implies Nash Equilibria: Combinatorial Fixed Points in Game Theory"
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
