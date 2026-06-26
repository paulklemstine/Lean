

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
    "consumed_by_exp_id": "0548f2b9",
    "description": "Formalize global existence and uniqueness for 2D Navier-Stokes (Ladyzhenskaya's theorem). Prove the Caffarelli-Kohn-Nirenberg partial regularity theorem in 3D: the singular set has 1-dimensional Hausdorff measure zero. Formalize energy inequalities.",
    "domains": [
      "Analysis",
      "Physics"
    ],
    "id": "seed_342",
    "priority_score": 0.93,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "in_progress",
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
    "consumed_by_exp_id": "97f912e0",
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
    "status": "in_progress",
    "timestamp": "2026-06-18T03:56:25.432799+00:00",
    "title": "Langlands Correspondence: GL(1) Case"
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
    "status": "failed",
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
    "consumed_by_exp_id": "",
    "description": "Formalize the Euclid-Euler theorem: n is an even perfect number iff n = 2^(p-1)(2^p - 1) where 2^p - 1 is prime. Prove that odd perfect numbers, if they exist, must have at least 101 prime factors (Nielsen's bound). Formalize the abundancy index \u03c3(n)/n framework.",
    "domains": [
      "NumberTheory"
    ],
    "id": "seed_331",
    "priority_score": 0.87,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "available",
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
    "consumed_by_exp_id": "4364c6f1",
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
    "status": "in_progress",
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
    "description": "Building on cycle f25c8810 (Q=0.755), which proved 734 theorems in Computation. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: Formalize a non-circular proof of injectivity for the factorial number system using only digit bounds, the telescoping estimate, and Euclidean division by k!. The core theorem should be that for valid digit functions c,d with c i \u2264 i and d i \u2264 i for all i < k, equality of their factoradic values up ",
    "domains": [
      "Computation"
    ],
    "id": "push_f25c8810_37bd789b",
    "priority_score": 0.8545600000000001,
    "research_mode": "team",
    "source_exp_id": "f25c8810",
    "status": "available",
    "timestamp": "2026-06-25T03:46:44.858796+00:00",
    "title": "Deepening: Alien Number Systems: Beyond Base-N"
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
    "consumed_by_exp_id": "b08abcae",
    "description": "Formalize the theory of continued fractions in Lean 4: convergents, best rational approximations, Hurwitz's theorem (|\u03b1 - p/q| < 1/(\u221a5 q\u00b2) for infinitely many p/q). Prove Liouville's theorem on transcendental numbers via Diophantine approximation bounds.",
    "domains": [
      "NumberTheory",
      "Analysis"
    ],
    "id": "seed_332",
    "priority_score": 0.84,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "in_progress",
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
    "consumed_by_exp_id": "0dc2bca1",
    "description": "Formalize the discrete Fourier transform as representation theory of cyclic groups. Prove Parseval's theorem and the convolution theorem. Extend to arbitrary finite abelian groups. Prove the uncertainty principle: supp(f) \u00b7 supp(f\u0302) \u2265 |G|.",
    "domains": [
      "Analysis",
      "Algebra"
    ],
    "id": "seed_346",
    "priority_score": 0.83,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-18T03:56:25.432657+00:00",
    "title": "Fourier Analysis on Finite Groups"
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
    "consumed_by_exp_id": "d4c70419",
    "description": "Formalize the Erd\u0151s-R\u00e9nyi random graph model G(n,p). Prove the sharp threshold for connectivity at p = ln(n)/n. Prove the phase transition for giant components at p = 1/n. Formalize the second moment method for subgraph counting.",
    "domains": [
      "Combinatorics",
      "Probability"
    ],
    "id": "seed_355",
    "priority_score": 0.82,
    "research_mode": "prove",
    "source_exp_id": "seed",
    "status": "in_progress",
    "timestamp": "2026-06-18T03:56:25.432742+00:00",
    "title": "Random Graphs: Erd\u0151s-R\u00e9nyi Threshold Phenomena"
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
    "description": "Cycle f25c8810 (Q=0.755) proved 734 theorems in Computation but left 4 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Formalize a non-circular proof of injectivity for the factorial number system using only digit bounds, the telescoping estimate, and Euclidean division by k!. The core theorem should be that for valid",
    "domains": [
      "Computation"
    ],
    "id": "sorry_fill_f25c8810_4ab835a5",
    "priority_score": 0.8045600000000002,
    "research_mode": "team",
    "source_exp_id": "f25c8810",
    "status": "available",
    "timestamp": "2026-06-25T03:46:45.492101+00:00",
    "title": "Close Proofs: Alien Number Systems: Beyond Base-N"
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
    "description": "Let B_n be the Birkhoff polytope, the convex hull in R^(n x n) of all n x n permutation matrices. Conjecture: B_n satisfies the clique-face property, meaning every clique in the 1-skeleton of B_n is exactly the vertex set of a face, if and only if n <= 2.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2282",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20430v1",
    "status": "available",
    "timestamp": "2026-06-23T00:35:57.205204+00:00",
    "title": "Birkhoff polytopes have the clique-face property only in dimensions n <= 2"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let G be a topological group and H \u2264 G a dense subgroup with the subspace topology. If H is extremely amenable, meaning every continuous action of H on a nonempty compact Hausdorff space has a fixed point, then G is extremely amenable. This isolates the density step used when passing from the automorphism group of a projective Fraisse limit to the closure subgroup of the homeomorphism group of the quotient continuum.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2284",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20407v1",
    "status": "available",
    "timestamp": "2026-06-23T00:36:00.903861+00:00",
    "title": "Extreme amenability passes from a dense subgroup to its ambient topological group"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every finite K5-free simple graph G on n vertices, assign weight 1/2 to every edge contained in a triangle and weight 1 to every other edge. Then G has a bipartition whose monochromatic edge-weight is at most n^2/16. Equivalently, deleting edges of total such weight at most n^2/16 always makes G bipartite. The balanced complete 4-partite graph shows that the constant 1/16 would be best possible.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2286",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20397v1",
    "status": "available",
    "timestamp": "2026-06-23T00:54:19.630900+00:00",
    "title": "Weighted K5-free max-cut conjecture with triangle-discounted edges"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Let A and B be reduced arrangements of d projective complex lines in P^2 with d <= 9. If their central intersection lattices are isomorphic, their Milnor algebras S/J_f and S/J_g have the same Hilbert function in every degree, and mdr(f) = mdr(g), then the minimal graded free resolutions of S/J_f and S/J_g have identical graded Betti numbers. Equivalently, there is no Ziegler pair of at most nine lines satisfying both conditions (HF) and (MDR).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2287",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20421v1",
    "status": "available",
    "timestamp": "2026-06-23T01:12:03.280702+00:00",
    "title": "No HF-MDR Ziegler pairs with at most nine lines"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Every connected locally finite multigraph G admits a rooted tree-cut decomposition (T,V) into finite bags, of finite adhesion, which is componental and linked, displays every end of G bijectively as an end of T, and is degree-normalized as follows. If a tree-end alpha of T displays the graph end omega, and e_n is the nth adhesion edge on the root-to-alpha ray of T, then: (i) if the edge-degree of omega is a finite natural number d, then |F_{e_n}| = d for all sufficiently large n; (ii) if the edge-degree of omega is infinite, then for every k : Nat, |F_{e_n}| >= k for all sufficiently large n. This strengthens the paper's displayed-edge-degree conclusion by asking for eventual exact stabilization along finite-degree ends and divergence along infinite-degree ends.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2288",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20452v1",
    "status": "available",
    "timestamp": "2026-06-23T01:38:47.066128+00:00",
    "title": "Degree-normalized linked tree-cut decompositions for locally finite graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every finite-dimensional vector space E over a finite field F and every rank r with 0 <= r <= dim E, the map sending a sparse-paving q-matroid M of rank r on E to its set of r-dimensional circuit-hyperplanes is a bijection onto the stable sets of the q-Johnson graph J_q(E,r), whose vertices are r-dimensional subspaces and whose edges join pairs with intersection dimension r-1. Equivalently, a set S of r-subspaces defines a sparse-paving q-matroid precisely when any two distinct members of S intersect in dimension at most r-2.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2289",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20348v1",
    "status": "available",
    "timestamp": "2026-06-23T00:54:23.693302+00:00",
    "title": "Sparse-paving q-matroids are exactly stable sets in the q-Johnson graph"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let p and q be distinct primes. Suppose P,Q \u2208 \u2115[x] are generating polynomials for two dice with no 0-labeled sides, with P(1)=p^2 and Q(1)=q^2, and whose sum-frequency polynomial equals that of two standard pq-sided dice: P Q = (x + x^2 + \u22ef + x^(pq))^2. Then P and Q must be one of exactly three explicit pairs, indexed by c=0,1,2: with G(n,s)=\u2211_{i=0}^{n-1} x^(s i), the p^2-sided die is x\u00b7G(p,1)^(2-c)\u00b7G(p,q)^c and the q^2-sided die is x\u00b7G(q,1)^c\u00b7G(q,p)^(2-c).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2290",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20311v1",
    "status": "available",
    "timestamp": "2026-06-23T01:13:50.667614+00:00",
    "title": "Prime-product square-sided dice have exactly three relabeling types"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let p > 5 be prime, and let mu(p) be the least positive integer m such that 2^m \u2261 1 or -1 mod p. The conjecture is that there are infinitely many primes p for which mu(p) = (p - 1) / 2. By the projective-doubling classification in the paper, this is equivalent to saying that infinitely many prime odd bases attain the maximal possible terminal four-digit Kaprekar cycle length (p - 1) / 2.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2291",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.20439v1",
    "status": "available",
    "timestamp": "2026-06-23T01:38:50.878342+00:00",
    "title": "Infinitely many extremal prime odd bases for four-digit Kaprekar dynamics"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any inner form G of GL_n over a non-archimedean local field F, the Hochschild homology of the Braverman-Kazhdan asymptotic Hecke algebra J(G) is canonically isomorphic to the Hochschild homology of the classical Hecke algebra C_c^\u221e(G), and the Kazhdan-Lusztig bijection on Bernstein components appears in this isomorphism. Concretely, for each Bernstein component s indexed by an inertial equivalence class, the summand HH_*(J(G))_s is identified with HH_*(C_c^\u221e(G))_s via the map induced by the natural inclusion of Schwartz functions, and this identification is compatible with the Kazhdan-Lusztig bijection between Bernstein components and certain data on the dual side. This conjecture is established in the paper for inner forms of GL_n; the grand challenge extension to all connected reductive p-adic groups remains open.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2293",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21313v1",
    "status": "available",
    "timestamp": "2026-06-23T01:47:05.451556+00:00",
    "title": "Hochschild homology isomorphism between asymptotic and classical Hecke algebras for inner forms of GL_n"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed integer k \u2265 3, the Conformability problem is NP-complete when restricted to connected d-regular graphs G of odd order n with independence number \u03b1(G) = k and maximum degree d \u2265 n/2. The paper establishes this for k = 3 by reduction from perfect triangle packing in K\u2084-free graphs. The conjecture asserts that hardness persists for all larger independence numbers, where the complement graph has clique number k and conformable color classes correspond to cliques of odd size up to k in the complement, requiring richer packing structures to encode NP-hard problems.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2294",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21534v1",
    "status": "available",
    "timestamp": "2026-06-23T01:48:36.909062+00:00",
    "title": "Conformability remains NP-complete for all fixed independence numbers at least 3"
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
    "description": "Conjecture: Let G be a finite simple connected regular graph of odd order. If every independent set of G has size at most 2, then G is conformable if and only if G is complete. Equivalently, in the zero-deficiency odd regular regime, the NP-hardness threshold \u03b1(G)=3 from the paper is sharp with respect to independence number: no non-complete graph with \u03b1(G)\u22642 can be conformable.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_2296",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21534v1",
    "status": "available",
    "timestamp": "2026-06-23T02:23:55.721827+00:00",
    "title": "Alpha-two sharpness for conformability in odd regular graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every positive integer k \u2265 1 and every positive integer n \u2265 1, every k-restricted characteristic sequence of a permutation on Z_n is the score sequence of some k-tournament on n vertices. Here, a characteristic sequence c(\u03c6) of a permutation \u03c6 \u2208 S_n is the non-decreasing arrangement of the multiset {i + \u03c6(i) : i \u2208 Z_n}, and it is k-restricted if each value in this multiset appears at most k times. A k-tournament on n vertices is a complete directed multigraph where each pair of vertices is connected by exactly k arcs, and its score sequence is the non-decreasing sequence of vertex outdegrees. This conjecture unifies the Bebeacua et al. conjecture (k=1: binary xrays, where each value appears at most once, correspond to 1-tournament score sequences) and the Brualdi\u2013Fritscher conjecture (k=2: unrestricted xrays, where each value appears at most twice, correspond to 2-tournament score sequences).",
    "domains": [
      "Pythagorean",
      "Bridges"
    ],
    "id": "fd_2297",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21532v1",
    "status": "available",
    "timestamp": "2026-06-23T02:42:12.378585+00:00",
    "title": "Generalized Xray-Tournament Correspondence Conjecture"
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
    "description": "For every integer t \u2265 1, the natural density c_t := lim_{N\u2192\u221e} (1/N) #{0 \u2264 n < N : s\u2082(n+t) \u2265 s\u2082(n)} strictly exceeds 1/2, with the explicit quantitative bound c_t \u2265 1/2 + 2^{-2s\u2082(t)-1}, where s\u2082(m) counts the ones in the binary expansion of m. This was Cusick's long-standing conjecture, recently resolved via first-exit medians for principal subsequence ideals after an exact deconvolution replacing the distribution of s\u2082(n+t)\u2212s\u2082(n) by a finite stopped random-walk law.",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_2299",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23398v1",
    "status": "available",
    "timestamp": "2026-06-23T04:31:20.306116+00:00",
    "title": "Cusick's sum-of-digits conjecture with explicit bias bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For integers n \u2265 2k and k \u2265 3, any two non-trivial cross-intersecting families A, B \u2286 ([n] choose k) satisfy |A| * |B| \u2264 h(n,k)^2, where h(n,k) = choose(n-1, k-1) - choose(n-k-1, k-1) + 1 is the size of the Hilton-Milner family. This formalizes the resolved Frankl-Wang conjecture.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2300",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23322v1",
    "status": "available",
    "timestamp": "2026-06-23T04:53:00.715630+00:00",
    "title": "Sharp Product Bound for Non-Trivial Cross-Intersecting Families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let $a_k$ denote the number of P\u00f3lya trees on $k$ nodes, and define $\\omega_k = \\sum_{d \\mid k} d \\cdot a_d$. Then $a_1 = 1$ and for all $k \\ge 2$: $a_k = \\frac{1}{k-1} \\sum_{j=1}^{k-1} a_j \\, \\omega_{k-j}$. This is derived by extracting coefficients from the logarithmic derivative of the P\u00f3lya functional equation $A(z) = z \\exp(A(z)) \\Phi(z)$, where $[z^k] \\sum_{i \\ge 1} z^i A'(z^i) = \\omega_k$.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2301",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23439v1",
    "status": "available",
    "timestamp": "2026-06-23T05:17:21.927856+00:00",
    "title": "P\u00f3lya tree coefficient divisor-sum recurrence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any binary delta-matroid $D$ on ground set $E$ and any twuality operator $\\bullet \\in \\{\\ast, \\times, \\ast\\times, \\times\\ast, \\ast\\times\\ast\\}$, the sequence of coefficients of the partial-$\\bullet$ polynomial $^{\\partial}w_{D}^{\\bullet}(z) = \\sum_{A \\subseteq E} z^{w(D^{\\bullet \\mid A})}$ is log-concave. This conjecture extends the interpolation property established in the paper (which implies the sequence has no internal zeros) and directly parallels the resolution of the Mason-Welsh conjecture for matroid independent sets.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2302",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22888v1",
    "status": "available",
    "timestamp": "2026-06-23T05:47:22.546695+00:00",
    "title": "Log-concavity of Partial-Twuality Polynomials for Binary Delta-Matroids"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let R be any commutative ring and G any finite group. Define HH\u2080(R[G]) as the quotient of the group algebra R[G] by the R-submodule spanned by all additive commutators xy - yx. The canonical R-linear map sending a basis element g of R[G] to the conjugacy class of g descends to an R-linear equivalence HH\u2080(R[G]) \u2243 R[Conj(G)]. Equivalently, the only relations in degree-zero Hochschild homology of a finite group algebra identify conjugate group elements.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2303",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21313v1",
    "status": "available",
    "timestamp": "2026-06-23T02:05:39.955397+00:00",
    "title": "HH0 of a finite group algebra is the free module on conjugacy classes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every real \u03b5 > 0, there exists N such that every finite simple graph G on n \u2265 N vertices with minimum degree at least (5/8 + \u03b5)n has an edge-decomposition into 5-cycles whenever G is C5-divisible, i.e. every vertex has even degree and 5 divides the number of edges. This is the remaining small odd-cycle case suggested by the generalized Nash-Williams threshold \u03b4_{C_\u2113} = \u2113/(2\u2113\u22122), after the triangle case and the long odd-cycle cases addressed in the paper.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2304",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21548v1",
    "status": "available",
    "timestamp": "2026-06-23T02:24:24.127531+00:00",
    "title": "Asymptotic C5-decomposition threshold equals 5/8"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let A\u2081 and A\u2082 be central hyperplane arrangements over Q of the same rank with isomorphic intersection lattices L(A\u2081) \u2245 L(A\u2082). For all primes p at which both arrangements admit good reduction, the local ask zeta functions coincide: Z^{ask}_{A\u2081/Z_p}(T) = Z^{ask}_{A\u2082/Z_p}(T). This extends the well-known combinatorial invariance conjecture for Igusa local zeta functions to the ask zeta function setting, motivated by the paper's construction recovering ask zeta functions from the Igusa local zeta function of the cone and the truncated flag Hilbert-Poincar\u00e9 series. The conjecture asserts that the arithmetic content entering through the substitution in the flag Hilbert-Poincar\u00e9 series is nevertheless determined by the intersection lattice for good reduction primes.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2305",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21393v1",
    "status": "available",
    "timestamp": "2026-06-23T02:43:10.666437+00:00",
    "title": "Combinatorial Invariance of Ask Zeta Functions for Hyperplane Arrangements"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: for every integer k \u2265 2, every finite simple k-connected graph G on n \u2265 4k+4 vertices with minimum degree \u03b4(G) \u2265 ceil((n+1)/2) has, for every ordered pair of distinct vertices u,v, a Hamiltonian u-v path P such that the spanning graph G with all edges of P deleted is still k-connected. This is a precise strengthening of the paper's n \u2265 6k+6 bound while keeping the same degree threshold and prescribed endpoints.",
    "domains": [
      "Pythagorean",
      "Physics"
    ],
    "id": "fd_2306",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21383v1",
    "status": "available",
    "timestamp": "2026-06-23T03:02:08.314897+00:00",
    "title": "A 4k+4 order bound for connectivity-preserving Hamiltonian prescribed-end paths"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every n \u2265 1, there exists a finite family C of pairwise disjoint open bounded convex sets in R^{3n} such that the space L of line transversals to C is homotopy equivalent to S^{n-1}. This strengthens the authors' theorem (which proves only H\u0303_{n-1}(L) \u2260 0) and formalizes their stated belief that the transversal spaces they construct have the homotopy type of a sphere.",
    "domains": [
      "Geometry",
      "Logic"
    ],
    "id": "fd_2307",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23193v1",
    "status": "available",
    "timestamp": "2026-06-23T04:31:35.784256+00:00",
    "title": "Homotopy type of the line transversal space equals S^{n-1}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In Theorem 1.2 of the paper, the function $f(n,s')$ bounding the size of the separator can be chosen to be $ns'-1$ when the vertex sets in $\\mathcal{A}$ are pairwise disjoint.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2308",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23121v1",
    "status": "available",
    "timestamp": "2026-06-23T04:53:54.133289+00:00",
    "title": "Optimal Separator Bound for Wall Connectors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a number field F with r\u2081 real embeddings and r\u2082 pairs of complex conjugate embeddings, and for every integer n \u2265 2, the bottom-degree Betti-Whittaker periods of a generic cohomological automorphic representation \u03c0 of GL\u2099 over F and its contragredient \u03c0\u2228 satisfy p^b(\u03c0\u2228) = (-1)^{b(F,n)} \u00b7 p^b(\u03c0), where b(F,n) = r\u2081\u00b7\u230an\u00b2/4\u230b + r\u2082\u00b7n(n-1)/2 is the bottom cohomological degree. This removes the regularity assumptions in Chen's earlier result and extends the contragredient period relation to the full class of generic cohomological representations.",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2309",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23171v1",
    "status": "available",
    "timestamp": "2026-06-23T05:20:19.284015+00:00",
    "title": "Contragredient Period Sign Formula for Betti-Whittaker Periods of GL(n)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "An infinite word $x_1x_2\\dots \\in \\mathcal{A}^\\mathbb{N}$ can be realized as the $(-\\beta)$-expansion of some $x \\in I_\\beta$ if and only if for all $n \\ge 1$, the suffix $x_n x_{n+1} \\dots$ is less than or equal to $d^*(0, -\\beta)$ in the alternating lexicographic order. The alternating lexicographic order $\\preceq$ is defined such that $x \\preceq y$ if either $x=y$ or at the first index $k$ where they differ, $x_k < y_k$ when $k$ is odd and $x_k > y_k$ when $k$ is even.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2310",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23097v1",
    "status": "available",
    "timestamp": "2026-06-23T05:48:57.058098+00:00",
    "title": "Ito-Sadahiro Admissibility Condition for Negative Beta-Expansions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a real quadratic field K with discriminant \u0394\u2080, dimension d in its AFMY tower, and conductor f dividing f\u2080(d), the excess e = [K^{fd} : K_L^{d;f}] equals 1 if and only if gcd(f, d) = 1. This characterizes when the Kopp-Lagarias ray class field K_L^{d;f} coincides with the standard ray class field K^{fd}, and is the key structural ingredient in the paper's thesis that SIC overlap units factor into Stark units from these fields.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2311",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23535v1",
    "status": "available",
    "timestamp": "2026-06-23T05:54:16.244333+00:00",
    "title": "Excess-One Criterion for Kopp-Lagarias Ray Class Fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A left-regular bipartite graph of degree d is an s-optimal small-set expander (i.e., every subset X of left vertices of size t \u2264 s has exactly d * t distinct neighbors, maximizing expansion) if and only if its girth is at least 2s + 2. This bridges the combinatorial property of girth with the expansion parameter \u03b1_G(t) and the optimality of the associated code B(G).",
    "domains": [
      "Algebra",
      "Bridges"
    ],
    "id": "fd_2312",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23579v1",
    "status": "available",
    "timestamp": "2026-06-23T06:21:22.540143+00:00",
    "title": "Girth-Expansion Equivalence for Optimal Small-Set Expanders"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The cluster algebra structure on the coordinate ring of a partial flag variety G/P, defined via the restriction of the base affine space cluster structure, is isomorphic to the cluster algebra structure defined on the corresponding Schubert cell via the double Bruhat cell cluster structure.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2313",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23474v1",
    "status": "available",
    "timestamp": "2026-06-23T06:42:43.429866+00:00",
    "title": "Isomorphism of Cluster Structures on Schubert Cells and Partial Flag Varieties"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer t >= 1, the natural density c_t = lim_{N->\u221e} (1/N) * #{0 <= n < N : s_2(n+t) >= s_2(n)} satisfies c_t >= 1/2 + 2^{-2*s_2(t)-1}.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2314",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23398v1",
    "status": "available",
    "timestamp": "2026-06-23T07:09:34.216269+00:00",
    "title": "Explicit bias lower bound for the density of n with s_2(n+t) >= s_2(n)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any finite family of convex splinters in d-dimensional Euclidean space, if the intersection of every subfamily of size at most 2d+1 is non-empty, then the intersection of the entire family is non-empty. This extends the classical Helly's theorem to the more general structure of convex splinters.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2315",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23437v1",
    "status": "available",
    "timestamp": "2026-06-23T07:39:04.351050+00:00",
    "title": "Helly's Theorem for Convex Splinters"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all positive integers s' and t', there exist integers t and f such that for any graph G, vertex set A, and wall W of size at least t, either there exists a vertex set X of size at most f separating A from the branch vertices of W, or there exists a subwall W' of W of size at least t' and s' vertex-disjoint A-W'-paths ending in distinct nails of W'.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2316",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23121v1",
    "status": "available",
    "timestamp": "2026-06-23T08:05:12.495306+00:00",
    "title": "Wall-Menger Theorem"
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
    "description": "For any connected reductive group $G$ defined over a number field $F$, and any cohomological generic automorphic representation $\\pi$ of $G(\\mathbb{A}_F)$, the ratio of the Betti-Whittaker periods $\\Omega(\\pi^\\vee) / \\Omega(\\pi)$ is an algebraic number, generalizing the explicit relation established for $\\mathrm{GL}(n)$ where the ratio is a specific power of $i$ depending on the bottom degree $b = r_1 \\lfloor n^2/4 \\rfloor + r_2 n(n-1)/2$.",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2318",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23171v1",
    "status": "available",
    "timestamp": "2026-06-23T08:53:00.946057+00:00",
    "title": "Algebraicity of Contragredient Betti-Whittaker Period Ratio for Reductive Groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Let d < 0 be squarefree, let K = Q(\u221ad), and let O_K have Z-basis {1, \u03c9}, where \u03c9 = \u221ad if d \u2260 1 mod 4 and \u03c9 = (1 + \u221ad)/2 if d \u2261 1 mod 4. Form the rank-four lattice S_K = Herm_2(O_K) with quadratic form q(A) = 2 det(A), and use the basis given by the two diagonal Hermitian matrix units together with the off-diagonal elements 1 and \u03c9. Then the determinant of the Gram matrix of the associated integral symmetric bilinear form is exactly the fundamental discriminant D_K: det Gram(S_K) = d if d \u2261 1 mod 4, and det Gram(S_K) = 4d otherwise.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2319",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22921v1",
    "status": "available",
    "timestamp": "2026-06-23T09:16:17.802367+00:00",
    "title": "Discriminant of the Hermitian Bianchi lattice S_K"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every connected, twin-free Cayley digraph of a finite abelian group of odd order is stable; that is, the automorphism group of its direct product with the complete digraph K_2 is isomorphic to the direct product of their individual automorphism groups.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2320",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22947v1",
    "status": "available",
    "timestamp": "2026-06-23T09:53:33.563342+00:00",
    "title": "Stability of Cayley Digraphs of Abelian Groups of Odd Order"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a finite acyclic quiver Q with longest path length n-1, the T-ideal of the principal subalgebra \ud835\udd3dQ\u22651 is generated by the standard polynomial S = \u2211_{\u03c3\u2208S_n} x_{\u03c3(1)}x_{\u03c3(2)}...x_{\u03c3(n)}.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2321",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23024v1",
    "status": "available",
    "timestamp": "2026-06-23T10:17:17.086233+00:00",
    "title": "Symmetrized Monomial Generates T-Ideal in Acyclic Path Algebras"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every binary delta-matroid and every nontrivial twuality operator $\bullet \\in \\{\\ast, \\times, \\ast\\times, \\times\\ast, \\ast\\times\\ast\\}$, the partial-$\\bullet$ polynomial $^\\partial w_D^\\bullet(z)$ is either even, odd, or both even-interpolating and odd-interpolating.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2322",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22888v1",
    "status": "available",
    "timestamp": "2026-06-23T10:41:26.252321+00:00",
    "title": "Binary Delta-Matroid Partial-Twuality Interpolation"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any bounded prism (A, I) where A/I is a regular local ring of dimension d, the restriction functor from the category of prismatic F-crystals on Spec(A/I) to the category of prismatic F-crystals on the punctured spectrum Spec(A/I) \\ {m} is an equivalence of categories. This extends the paper's primitive purity theorem for Frobenius modules to the full setting of prismatic F-crystals, and would imply that the canonical F-isocrystal from Ogus's conjecture is uniquely determined by its restriction to any dense open subscheme.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2323",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22637v1",
    "status": "available",
    "timestamp": "2026-06-23T11:00:28.938025+00:00",
    "title": "Prismatic Purity for F-Crystals on Regular Schemes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any connected polymatroid $P$ and any element $e$, the set of indices $j \\in \\{0, \\dots, f(e)\\}$ for which the $j$-th slice-projection of $e$ is connected forms a contiguous interval of integers. This conjecture strengthens the paper's theorem that no two consecutive slice-projections can both be disconnected, and naturally generalizes the interval property trivially satisfied by matroids (where the rank $f(e) \\le 1$).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2324",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22819v1",
    "status": "available",
    "timestamp": "2026-06-23T11:20:57.671444+00:00",
    "title": "Interval Property for Connected Slice-Projections of Polymatroids"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every integer k\u22653 there exists a critical edge density \u03b3_k\u2208(0,1) such that for all sufficiently large n, any graph on n vertices with edge density at least \u03b3_k that contains no induced copy of K_{1,k} is \u03b5 n^2-close (in edit distance) to the complement of a complete (k\u22121)-partite graph whose part sizes differ by at most o(n) from the balanced partition n/(k\u22121).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2325",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22661v1",
    "status": "available",
    "timestamp": "2026-06-23T11:44:48.971200+00:00",
    "title": "Typical (k\u22121)-partite complement structure of dense K_{1,k}-free graphs above the critical density"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every prime p \u2265 7 with p \u2261 3 mod 4, the determinant of the truncated Legendre-symbol matrix with polynomial parameter X is exactly ((p - 2) / 3)^2 X over \u2124[X]. Explicitly, for m = (p - 5) / 2 and matrix A indexed by Fin m with A_{j,k} = X + (j - k | p), where the Legendre symbol is viewed as an integer coefficient polynomial, det A = ((p - 2) / 3)^2 X.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2326",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22548v1",
    "status": "available",
    "timestamp": "2026-06-23T12:03:49.419256+00:00",
    "title": "Lean-formalizable Sun truncated Legendre-symbol determinant"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A coordinate-symmetric r-coloring of the cube [t]^n is line-free with respect to combinatorial lines having at most K active coordinates if and only if the induced coloring of the discrete simplex \u0394(t-1, n) has no monochromatic corner tuple of width at most K. This equivalence reduces checking line-freeness of a symmetric coloring (a property of the exponentially large cube) to checking corner-tuple-freeness on the polynomially-sized simplex, and is the theoretical foundation enabling the certified lower bounds HJ(3,3) \u2265 22 and HJ(4,2) \u2265 14.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2327",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22155v1",
    "status": "available",
    "timestamp": "2026-06-23T12:25:51.858994+00:00",
    "title": "Symmetric Coloring Reduction Lemma for Hales-Jewett Line-Freeness"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a totally real number field $k$, a prime $p$, and a subset $\\Sigma$ of the $p$-adic primes of $k$, if $N_\\infty/k$ is a $\\Sigma$-ramified $\\mathbb{Z}_p$-extension (i.e., $N_\\infty$ is contained in the maximal abelian pro-$p$-extension of $k$ unramified outside $\\Sigma$), then the unramified Iwasawa module $X(N_\\infty)$ is finite. This generalizes Greenberg's Conjecture from the cyclotomic $\\mathbb{Z}_p$-extension to any $\\Sigma$-ramified $\\mathbb{Z}_p$-extension.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2328",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22324v1",
    "status": "available",
    "timestamp": "2026-06-23T12:50:31.085426+00:00",
    "title": "Finiteness of Unramified Iwasawa Module for Sigma-Ramified Extensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Fix rational transmission parameters \u03b8,p with 0 < \u03b8 < 1 and 0 < p \u2264 1. For any two finite simple graphs G and H, let G \u25a1 H denote the Cartesian product and let Z_T^{\u03b8,p}(G) be the minimum size of a \u03b8-threshold, p-proportion transmission zero forcing set. Conjecture: Z_T^{\u03b8,p}(G \u25a1 H) \u2264 min(|V(H)| \u00b7 Z_T^{\u03b8,p}(G), |V(G)| \u00b7 Z_T^{\u03b8,p}(H)). This is falsifiable by a finite pair of graphs and rational parameters for which every initial set below the stated bound fails to fill the product.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2329",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22246v1",
    "status": "available",
    "timestamp": "2026-06-23T13:10:53.772901+00:00",
    "title": "Cartesian-product upper bound for transmission zero forcing"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any edge-colored graph G on n \u2265 3 vertices, if the minimum color degree \u03b4c(G) \u2265 (n+1)/2, then the number of rainbow triangles rt(G) is at least f(n), where f(n) = (n^2-1)/8 if n is odd, f(n) = n^2/4 - 1 if n is even and n \u2265 6, and f(4) = 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2330",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22106v1",
    "status": "available",
    "timestamp": "2026-06-23T13:28:42.948702+00:00",
    "title": "Exact minimum number of rainbow triangles with large minimum color degree"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a projective variety V of dimension n over F_1 with associated invertible Markov matrix A = Mk_1 \u2208 GL_b(Z) (arising from the Markov endomorphism construction), the zeta function Z(V/F_1, t) = 1/det(I - tA) satisfies the Weil-type functional equation Z(V/F_1, 1/t) = \u03b5 \u00b7 t^{-\u03c7(V)} \u00b7 Z(V/F_1, t), where \u03b5 \u2208 {\u00b11} and \u03c7(V) = \u03a3_{i=0}^{2n} (-1)^i b_i is the topological Euler characteristic of V(C). This formalizes the paper's claim that the zeta function of V(F_1) satisfies all Weil conjectures except the Riemann hypothesis analog, using the bridge between F_1-geometry and the K-theory of Cuntz-Krieger algebras O_A.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2331",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22010v1",
    "status": "available",
    "timestamp": "2026-06-23T13:47:18.898418+00:00",
    "title": "Functional Equation for F_1-Zeta Functions via Cuntz-Krieger Algebras"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \u0393_R = R[p_1,p_3,p_5,...] and define the R-algebra endomorphism \u03c6_t of \u0393_R by \u03c6_t(p_n) = (1 - t^n) p_n for every positive odd n. If Q_\u03bb denotes the Schur Q-function indexed by a strict partition \u03bb in the same vertex-operator normalization as the t=0 odd GJZ construction, and S^t_\u03bb denotes the shifted t-Schur function obtained from the Fourier modes of the odd GJZ operator, then for every strict partition \u03bb one has S^t_\u03bb = \u03c6_t(Q_\u03bb). Equivalently, the shifted t-Schur family is obtained from the Schur Q basis by the odd plethystic substitution p_n \u21a6 (1 - t^n)p_n. This is falsifiable by coefficient comparison in the finite odd power-sum polynomial ring of degree at most |\u03bb|.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2332",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22058v1",
    "status": "available",
    "timestamp": "2026-06-23T14:06:13.272860+00:00",
    "title": "Plethystic Triviality of the Shifted t-Schur Basis"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every finite connected simple graph G on n \u2265 2 vertices with unit edge resistances, let R_G be its effective-resistance matrix and define \u0394(G) = (-1)^(n-1) det(R_G). Conjecture: 2^n (n-1) / n^n \u2264 \u0394(G) \u2264 2^(n-2) (n-1). Moreover, equality on the left holds exactly for the complete graph K_n, and equality on the right holds exactly for trees. This extends the Graham--Pollak tree determinant formula and predicts that adding simple edges monotonically decreases the signed resistance determinant down to the complete graph.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2333",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21902v1",
    "status": "available",
    "timestamp": "2026-06-23T14:24:58.237232+00:00",
    "title": "Extremal signed determinant of the resistance matrix of a connected simple graph"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjectures that for all integers $p \\ge 3$ and $s \\ge 1$, the Cameron-Puleo bound is tight for the graph $K^-_p \\cup sK_1$, generalizing the paper's results for $K^-_3 \\cup sK_1$ and $K^-_{p-1} \\cup K_1$. Specifically, $\\mathrm{sat}(n, K_1 \\vee (K^-_p \\cup sK_1)) = n - 1 + \\mathrm{sat}(n-1, K^-_p \\cup sK_1)$ for all $n \\ge p + s + 1$.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2334",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22006v1",
    "status": "available",
    "timestamp": "2026-06-23T14:43:25.621350+00:00",
    "title": "Cameron-Puleo Equality for $K^-_p \\cup sK_1$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let A \u2192 B be a finite locally free homomorphism of commutative rings of constant rank d. If an invertible A-module P becomes free of rank one after base change to B, then P^{\u2297 d} is free; equivalently, the kernel of the pullback map Pic(A) \u2192 Pic(B) is annihilated by d. Applied to A = O_K[t]/(f) and B = O_L[t]/(f), this predicts that whenever two non-derogatory integral matrices with characteristic polynomial f become similar over O_L, the associated Latimer--MacDuffee Picard-class difference has order dividing [L : K].",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2335",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21628v1",
    "status": "available",
    "timestamp": "2026-06-23T15:03:20.079971+00:00",
    "title": "Finite-flat capitulation divisibility for Picard classes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjectures that the upper bound for the Ramsey number $R(T, K_{m_1,\\ldots,m_k}) \\le (k-1)(R(T, K_{m_1,m_2})-1)+m_1$ established in the resolution of Erd\u0151s Problem 550 is tight. Specifically, for any fixed $k \\ge 2$ and $1 \\le m_1 \\le \\dots \\le m_k$, there exist arbitrarily large trees $T$ for which equality holds, demonstrating that the excess over the canonical Burr lower bound cannot be improved in general.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2336",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23659v1",
    "status": "available",
    "timestamp": "2026-06-23T05:55:36.201011+00:00",
    "title": "Tightness of the Erd\u0151s 550 Upper Bound for Tree-Multipartite Ramsey Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any prime p and integer i \u2265 1, the codimension-i rational cohomology of the Hecke congruence subgroup \u0393_{0,n}(p) vanishes for n \u2265 (3i+1)p + (3i+2). Specifically, H^{n(n-1)/2 - i}(\u0393_{0,n}(p); \u211a) = 0. This extrapolates the paper's results for i=1 (n \u2265 4p+5) and i=2 (n \u2265 7p+8) to arbitrary codimensions.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2337",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23519v1",
    "status": "available",
    "timestamp": "2026-06-23T06:21:54.373451+00:00",
    "title": "Codimension-i Vanishing Conjecture for Hecke Congruence Subgroups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every positive integer h, the set \ud835\udca5_h = {j \u2265 1 : rad(j) = rad(j+h)} is finite with |\ud835\udca5_h| \u2264 3 \u00b7 7^{3+2\u03c9(h)}, where rad(n) is the product of distinct prime factors of n and \u03c9(h) is the number of distinct prime factors of h. Furthermore, \ud835\udca5_h is empty when h is odd (since rad(j) = rad(j+h) forces 2 | rad(j) = rad(j+h), requiring both j and j+h even, contradicting odd h). This bound, due to Pollack\u2013Pomerance\u2013Trevi\u00f1o, is the crucial finiteness input underpinning the paper's rank-amplified decomposition of S_h^\u03c6(x) into diagonal (Graham\u2013Holt\u2013Pomerance same-support family) and off-diagonal components.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2338",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23681v1",
    "status": "available",
    "timestamp": "2026-06-23T06:43:59.614397+00:00",
    "title": "Explicit Finiteness Bound for Same-Radical Shift Sets"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The authors disprove a conjecture by Cheong, Goaoc, and Holmsen by showing that for every n >= 1, there is a finite family of pairwise disjoint open convex sets in R^{3n} such that the (n-1)-st reduced homology of the space of line transversals is nonzero. They explicitly state the conjecture that this space of line transversals is in fact homotopy equivalent to the (n-1)-sphere, S^{n-1}. This proposes formalizing that stronger homotopy equivalence conjecture.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_2339",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23193v1",
    "status": "available",
    "timestamp": "2026-06-23T07:10:06.412019+00:00",
    "title": "Homotopy Equivalence of Line Transversal Spaces to Spheres"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any prime power $q$ and integer $n \\ge q+2$, the Grassmann scheme $J_q(n,2)$ is degree-one trivial (DOT), meaning that all Boolean degree one functions on $J_q(n,2)$ are trivial. This extends Drudge's theorem for $q=3, n \\ge 5$ and the known result for $q=2, n \\ge 4$, proposing a unified threshold $n \\ge q+2$.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2340",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23465v1",
    "status": "available",
    "timestamp": "2026-06-23T08:05:42.947857+00:00",
    "title": "Degree-One Triviality of Grassmann Schemes $J_q(n,2)$ for $n \\ge q+2$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For k \u2265 2, let F(k) = gcd_{q=2}^{k} (qk choose k). We conjecture that F(k) = 1 if and only if k is not a prime power. This generalizes the known result for D(k) = gcd_{q=2}^{k+1} (qk choose k) which equals 1 precisely when k+1 is not a prime power (in the sense that the largest prime-power divisor P of k+1 satisfies (k+1)/P > P). The conjecture can be approached using similar techniques: a finite-difference argument shows only primes dividing k can divide F(k), Lucas' theorem reduces the problem to base-p digit analysis, and a digit-box stabilizer theorem determines when F(k) = 1.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2342",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22997v1",
    "status": "available",
    "timestamp": "2026-06-23T08:56:07.087605+00:00",
    "title": "A Prime-Power Criterion for GCDs of Binomial Coefficients with Restricted Upper Index Range"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any finite group \u0393, any real-valued function f : \u0393 \u2192 \u211d, and any finite directed graph F, the homomorphism density t(F, C_f) satisfies t(F, C_f) \u2265 (E_Gamma f)^(2 * e(F)), and equality holds iff f is constant on \u0393.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2343",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23018v1",
    "status": "available",
    "timestamp": "2026-06-23T09:18:43.440749+00:00",
    "title": "Conjecture on extremal constantness for two-sided group correlation kernels"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture proposes a universal structural condition that determines whether the deleted co-maximal subgroup graph of a finite group is connected, and when it has cycles or becomes a star.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2344",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22904v1",
    "status": "available",
    "timestamp": "2026-06-23T09:55:40.099936+00:00",
    "title": "Connectivity of co-maximal subgroup graphs for finite groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any graph G, the externally supported independence number \u03b1_{es}(G) is at least \u03b1(G) - 1, where \u03b1(G) is the standard independence number of G. This conjecture posits that the additional ES-condition does not reduce the maximum independent set size by more than one, even in cases where the standard independence number is achievable without the ES-condition.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2345",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22972v1",
    "status": "available",
    "timestamp": "2026-06-23T10:23:23.483072+00:00",
    "title": "Lower Bound Conjecture for Externally Supported Independence Number"
  },
  {
    "consumed_by_exp_id": "",
    "description": "An infinite word $x_1x_2\\dots \\in \\mathcal{A}^\\mathbb{N}$ is realized as the $\\beta$-expansion $d(x,\\beta)$ for some real number $x \\in [0, 1)$ if and only if for all $n \\in \\mathbb{N}$, the tail $x_nx_{n+1}\\dots$ is lexicographically strictly less than the quasi-greedy $\\beta$-expansion of 1, $d^*(1,\\beta)$.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2346",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23097v1",
    "status": "available",
    "timestamp": "2026-06-23T10:41:57.159557+00:00",
    "title": "Parry's Theorem on Admissible Beta-Expansions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any prime $p$ with $p \\equiv 3 \\pmod 4$, let $P_3$ denote the 3-dimensional paraboloid over the finite field $\\mathbb{F}_p$. The endpoint restriction conjecture for $P_3$ states that the Fourier extension operator associated with $P_3$ maps $L^2(P_3)$ to $L^3(\\mathbb{F}_p^3)$ with a constant independent of $p$. Equivalently, for any function $f: P_3 \\to \\mathbb{C}$, $\\| E(f) \\|_{L^3(\\mathbb{F}_p^3)} \\le C \\|f\\|_{L^2(P_3)}$ where $E(f)(x) = p^{-2} \\sum_{\\xi \\in P_3} f(\\xi) e(x \\cdot \\xi)$ and $C$ is an absolute constant.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2347",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22882v1",
    "status": "available",
    "timestamp": "2026-06-23T11:01:03.311156+00:00",
    "title": "Finite Field Restriction Conjecture for the 3D Paraboloid"
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
    "description": "The lazy swap chain on the set \u03a9(r,c) of m\u00d7n binary matrices with prescribed row sums r and column sums c has spectral gap at least (C(m,2))\u207b\u00b9(C(n,2))\u207b\u00b9 for all feasible margins whenever m,n \u2265 2. This resolves the 1997 conjecture of Kannan, Tetali, and Vempala. The bound is tight in the worst case (e.g., r\u2081=r\u2082=1, c\u2081=c\u2082=1, all other margins zero, giving |\u03a9|=2).",
    "domains": [
      "Pythagorean",
      "Physics"
    ],
    "id": "fd_2349",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22636v1",
    "status": "available",
    "timestamp": "2026-06-23T11:45:08.025039+00:00",
    "title": "Spectral Gap Lower Bound for the Binary Fixed-Margin Swap Chain"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every nonempty m \u00d7 n rectangular grid, let f : {0,\u2026,m\u22121} \u00d7 {0,\u2026,n\u22121} \u2192 Z satisfy f(0,0)=0 and |f(p)-f(q)|\u22641 on every grid edge. Then the total absolute mass is at most n\u00b7m(m\u22121)/2 + m\u00b7n(n\u22121)/2. This bound is sharp, attained by f(i,j)=i+j and by f(i,j)=\u2212(i+j). In the Miura-ori height-function model this is exactly the extremal inequality needed to turn the explicit lower-bound construction for the flip-graph diameter into a matching upper bound whenever flip distance is controlled by L1 height difference.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2350",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22614v1",
    "status": "available",
    "timestamp": "2026-06-23T12:05:30.404748+00:00",
    "title": "Extremal L1 mass of normalized 1-Lipschitz grid height differences"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any finite simple graph G, the number of irreducible FAT colorings of G is exactly the cardinality of the set of real numbers \u03b1 \u2208 [0,1] for which there exists \u03b2 \u2208 [0,1] such that (\u03b1,\u03b2) yields a FAT coloring of G. In other words, each irreducible FAT coloring corresponds to a unique fairness parameter \u03b1, and distinct irreducible FAT colorings give distinct \u03b1 values.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2351",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22374v1",
    "status": "available",
    "timestamp": "2026-06-23T12:28:11.255044+00:00",
    "title": "Number of irreducible FAT colorings equals number of distinct fairness parameters"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every 3-connected planar graph with an even number of vertices has at least 3 perfect matchings. While the paper establishes that the minimum non-zero number of perfect matchings for 3-connected planar graphs is bounded by a constant, this conjecture posits that the exact constant is 3, which is achieved by the complete graph on 4 vertices.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2352",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22253v1",
    "status": "available",
    "timestamp": "2026-06-23T12:51:47.961383+00:00",
    "title": "Exact Minimum Perfect Matchings in 3-Connected Planar Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every primitive integer 2 by 2 matrix M with nonzero determinant, the values k(Mx) / k(x) obtained by restricting x to real quadratic irrational badly approximable numbers are dense in the full interval [1 / |det M|, |det M|]. Equivalently, for every real u < v with 1 / |det M| <= u < v <= |det M|, there exists a real quadratic irrational x such that u < k(Mx) / k(x) < v.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2353",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22229v1",
    "status": "available",
    "timestamp": "2026-06-23T13:11:45.659366+00:00",
    "title": "Quadratic irrational density in the ratio spectrum"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The sum of the elements in the $n$-th row of the Pascal-like Riordan array defined by the power series pair $(1/(1-x), x/(1-x)^2)$, whose entries are given by the binomial coefficient $t_{n,k} = \\binom{n+k}{2k}$, equals the $(2n+1)$-th Fibonacci number. This is derived from the paper's demonstration that the generating function of the row sums is $(1-x)/(1-3x+x^2)$, which characterizes the odd-indexed Fibonacci sequence.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2354",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22070v1",
    "status": "available",
    "timestamp": "2026-06-23T13:29:49.823733+00:00",
    "title": "Row Sum Fibonacci Property of Pascal-like Riordan Array"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every Hamiltonian connected cubic edge-transitive graph \u0393 has Hamiltonian compression factor \u03ba(\u0393) \u2265 2, i.e., it admits a 2-symmetric Hamiltonian cycle: there exists a Hamiltonian cycle C and an automorphism g of order 2 such that g acts on C as a rotation by |V(\u0393)|/2 positions. This is supported by exhaustive computation on all such graphs up to 10,000 vertices, where every Hamiltonian cubic edge-transitive graph was found to have \u03ba \u2265 2.",
    "domains": [
      "Physics"
    ],
    "id": "fd_2355",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21941v1",
    "status": "available",
    "timestamp": "2026-06-23T13:48:00.738680+00:00",
    "title": "Hamiltonian Compression Factor of Cubic Edge-Transitive Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In Lemma 2.1 of the paper the infinite right half-strip row-exchange identity is proved under a uniform contraction assumption for every column. Conjecture: the same identity remains valid under the strictly weaker hypothesis that the contraction ratio is eventually bounded by some \u03b4 < 1. More precisely, for arbitrary top and bottom boundary occupation sequences, nonzero \u03b1, and spectral parameters v,z, if there exist \u03b4 < 1 and N such that for all i \u2265 N the norm of (w\u2081(u\u1d62/z)/w\u2084(u\u1d62/z))*(w\u2084(u\u1d62/v)/w\u2081(u\u1d62/v)) is at most \u03b4, then the two infinite row-exchange partition functions are equal up to the same scalar prefactor f(v/z)/\u03b1\u00b2.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2356",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22004v1",
    "status": "available",
    "timestamp": "2026-06-23T14:06:54.483472+00:00",
    "title": "Row-exchange under eventual contraction for the infinite asymmetric five-vertex half-strip"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer t \u2265 1 and q \u2265 1, let F = tK\u2082 \u222a qK\u2081 be the disjoint union of a matching of size t and q isolated vertices. Then for every n > 2t + q, the Cameron--Puleo upper bound is tight: sat(n, K\u2081 \u2228 F) = n - 1 + sat(n - 1, F). This extends the paper's proved cases t = 1 and t = 2 to all matchings with isolated vertices.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2357",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22011v1",
    "status": "available",
    "timestamp": "2026-06-23T14:25:38.671844+00:00",
    "title": "Join-saturation equality for matchings with isolated vertices"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer k >= 3, the sum of 2^{k_2} * zeta(k_1, k_2) over all positive integers k_1, k_2 such that k_1 + k_2 = k and k_2 >= 2, equals (k + 1) * zeta(k). This theorem is explicitly mentioned in the paper as the foundational starting point that is generalized to multiple mixed values.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2358",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21978v1",
    "status": "available",
    "timestamp": "2026-06-23T14:44:47.583620+00:00",
    "title": "Ohno-Zudilin Weighted Sum Formula for Double Zeta Values"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \ud835\udd13(y)=\u03a3_{a\u2208A} c_a(t) \u03a0_{i=0}^k (y^(i))^{a_i} be a nonzero ordinary algebraic differential polynomial over algebraically closed characteristic-zero Hahn series with finite support A. Let E_k(trop(\ud835\udd13)) be the set of t-adic orders r of Boolean Hahn elementary k-solutions of its tropicalization, equivalently the r for which the active indicial tropical minimum is attained at least twice. For each r in E_k(trop(\ud835\udd13)), form the classical indicial initial polynomial I_r(Z) in the leading coefficient Z, using exactly the monomials attaining that minimum and the falling-factorial factors coming from derivatives. Conjecture: if every r in E_k(trop(\ud835\udd13)) has a simple nonzero root of I_r(Z), then every elementary tropical order is realized by an actual Hahn-series solution; hence ord_t(Sol(\ud835\udd13)) = E_k(trop(\ud835\udd13)). This strengthens the paper's containment ord_t(Sol(\ud835\udd13)) \u2286 E_k(trop(\ud835\udd13)) to equality under a Newton-nondegeneracy hypothesis.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2359",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.21829v1",
    "status": "available",
    "timestamp": "2026-06-23T15:04:46.154289+00:00",
    "title": "Newton-nondegenerate elementary tropical orders lift to Hahn-series solutions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let d >= 4 and let K = Q(sqrt((d+1)(d-3))) be real quadratic with maximal order O_K. For an integer f > 0 with gcd(d,f)=1, let K^{fd} be the ordinary ray class field of K of finite modulus fd attached to O_K, and let K_L^{d;f} be the Kopp--Lagarias ray class field of finite modulus d attached to the order Z + f O_K. Define the canonical totally positive unit u = (d - 1 + sqrt((d+1)(d-3)))/2. Let P_f = (O_K/f O_K)^\u00d7 / (Z/fZ)^\u00d7, and let [u]_f be the image of u in P_f. The conjecture is that the excess e(d,f) = [K^{fd} : K_L^{d;f}] equals the index of the cyclic subgroup generated by [u]_f in P_f. Equivalently, e(d,f) = |P_f| / order([u]_f), and when f is prime to the discriminant this is Phi_K(f)/(Phi(f) * order([u]_f)). This gives a precise class-field-theoretic explanation for when the non-maximal ray class field is a proper subfield of the maximal ray class field.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2360",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23535v1",
    "status": "available",
    "timestamp": "2026-06-23T15:30:32.966496+00:00",
    "title": "Excess of Kopp--Lagarias ray class fields is the projective order defect of the SIC unit"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper proves R(T, K_{m\u2081,\u2026,m\u2096}) \u2264 (k\u22121)(R(T, K_{m\u2081,m\u2082}) \u2212 1) + m\u2081 for all sufficiently large n-vertex trees T. We conjecture this bound holds for ALL trees T with |T| \u2265 m\u2096, removing the asymptotic 'sufficiently large n' condition. This would extend the resolution of Erd\u0151s Problem 550 to a universal statement and subsumes Chv\u00e1tal's theorem R(T, K\u2096) = (k\u22121)(|T|\u22121)+1 as the special case m\u2081=\u22ef=m\u2096=1. Verified for n=1,2 and the paper's asymptotic regime; the intermediate range requires new techniques.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2361",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23659v1",
    "status": "available",
    "timestamp": "2026-06-23T15:32:33.434800+00:00",
    "title": "Universal Erd\u0151s 550: Tree\u2013Multipartite Ramsey Bound Without Asymptotic Conditions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For fixed integers k \u2265 2 and 1 \u2264 m\u2081 \u2264 \u22ef \u2264 m\u2096, there exists n\u2080 = n\u2080(m\u2081,\u2026,m\u2096) such that for every n \u2265 n\u2080 and every n-vertex tree T, R(T, K_{m\u2081,\u2026,m\u2096}) \u2264 (k\u22121)(R(T, K_{m\u2081,m\u2082}) \u2212 1) + m\u2081. This resolves Erd\u0151s Problem 550 and establishes that the excess over the Burr canonical lower bound is controlled by the excess in the bipartite subproblem involving the two smallest parts.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2362",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23659v1",
    "status": "available",
    "timestamp": "2026-06-23T15:38:06.610767+00:00",
    "title": "Erd\u0151s Problem 550: Tree versus Complete Multipartite Ramsey Upper Bound"
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
    "description": "For the standard rectangular/plabic cluster seed on the coordinate ring of the Grassmannian partial flag variety Gr(k,n), the cluster algebra is of finite type exactly in the classical finite Grassmannian cases: k=1 or n-k=1, k=2 or n-k=2, or (min(k,n-k),n) equal to (3,6), (3,7), or (3,8). Moreover the Dynkin type is respectively A0, A_{n-3}, D4, E6, and E8; in all other cases the seed is not mutation-equivalent to any Dynkin quiver.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2364",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23474v1",
    "status": "available",
    "timestamp": "2026-06-23T16:13:15.113462+00:00",
    "title": "Finite-type classification for Grassmannian partial-flag seeds"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The only natural numbers n for which n!/8 is a triangular number are n = 4, 5, and 7; equivalently, the only Brown numbers satisfying n! + 1 = m^2 are (4,5), (5,11), and (7,71). This is falsifiable by exhibiting any n \u2265 8 and integer y with y*(y+1)/2 = n!/8, or equivalently any m with n! + 1 = m^2.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2365",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23485v1",
    "status": "available",
    "timestamp": "2026-06-23T16:30:05.276546+00:00",
    "title": "Brocard-Ramanujan Triangular Classification"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper establishes that for almost all n, g_k(n) \u2265 (3(k-1)/log 12 \u2212 \u03b5) log n, while pointwise g_k(n) \u2264 (k-1)/log 2 \u00b7 log n + O(log log n). The gap between 3/log 12 \u2248 1.207 and 1/log 2 \u2248 1.443 motivates the conjecture that the upper bound coefficient is asymptotically tight: for every k \u2265 2 and \u03b5 > 0, the set of n \u2264 x with g_k(n) < ((k\u22121)/log 2 \u2212 \u03b5) log n has cardinality o(x). This would mean binary carries are the essential obstruction and c_k = (k\u22121)/log 2 is the true almost-everywhere constant, resolving Erd\u0151s Problem 400.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2366",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23661v1",
    "status": "available",
    "timestamp": "2026-06-23T16:48:09.150861+00:00",
    "title": "Tight Almost-Everywhere Coefficient for Erd\u0151s Excess Function g_k"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every n \u2265 1, let I_n be the explicit finite family of pairwise disjoint bounded open convex subsets of R^(3n) obtained by the inflation step in the paper's proof of Theorem t:inflated_intro. Then the full space of unoriented line transversals to I_n, with the standard affine-Grassmannian topology, is homotopy equivalent to S^(n-1). This strengthens the paper's nonvanishing reduced homology conclusion to a complete homotopy-type identification for the constructed examples.",
    "domains": [
      "Geometry",
      "Logic"
    ],
    "id": "fd_2367",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23193v1",
    "status": "available",
    "timestamp": "2026-06-23T17:06:01.247488+00:00",
    "title": "Inflated line-transversal counterexamples have sphere homotopy type"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every dimension d and integers p >= q >= 2d+1, there is a constant N = N(d,p,q) such that any finite family F of convex splinters in R^d with the (p,q)-property admits a transversal of size at most N. Here the (p,q)-property means that among every p members of F, some q members have nonempty common intersection. This extends the classical Hadwiger--Debrunner theorem from convex sets to convex splinters, with the Helly threshold 2d+1 replacing d+1.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2368",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23437v1",
    "status": "available",
    "timestamp": "2026-06-23T17:24:48.021151+00:00",
    "title": "Hadwiger--Debrunner (p,q) theorem for convex splinters"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In the Wall-Menger theorem (Theorem 1 of the paper), for positive integers s' and t', there exist t and f such that given a vertex set A and a wall W of size at least t, either (i) a vertex set X of size at most f separates A from the branch vertices of W, or (ii) a subwall W' of size at least t' admits s' disjoint A-W' paths each ending in a distinct nail of W'. The conjecture asserts that the optimal bound on the separator size is f(s') = s' - 1, matching the classical Menger theorem exactly, regardless of the wall structure.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2369",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23121v1",
    "status": "available",
    "timestamp": "2026-06-23T17:42:20.767813+00:00",
    "title": "Optimal separator bound in the Wall-Menger theorem matches Menger's theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The codimension-i rational cohomology of the special linear group SL_n(Z) vanishes for n >= i+2. Equivalently, the i-th rational cohomology group H^i(SL_n(Z); Q) is trivial for all i >= (n choose 2) - n + 2.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_2370",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23519v1",
    "status": "available",
    "timestamp": "2026-06-23T15:56:00.070698+00:00",
    "title": "Church-Farb-Putman Vanishing Conjecture for SL_n(Z)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every positive integer j and every odd positive integer h, the prime radicals of j and j+h are unequal. Equivalently, the same-prime-support index set J_h = {j \u2265 1 : rad(j) = rad(j+h)} is empty whenever h is odd. This formalizes the elementary obstruction behind the paper's statement that the Graham--Holt--Pomerance diagonal contribution is empty for odd shifts.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2371",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23681v1",
    "status": "available",
    "timestamp": "2026-06-23T16:13:54.497477+00:00",
    "title": "Odd shifts have no same-support GHP diagonal"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: for d = 3 and n = 8, the maximum size of a 4-uniform family on an 8-element ground set with VC-dimension at most 3 is exactly 40. Equivalently, M_3(8) = 40, which is one larger than the Ahlswede--Khachatrian value binom(7,3)+binom(4,1)=39. This is a finite, fully checkable strengthening of the paper's phenomenon at the smallest admissible ground-set size n=2d+2.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2372",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23469v1",
    "status": "available",
    "timestamp": "2026-06-23T16:31:38.847897+00:00",
    "title": "Exact first 4-uniform VC extremal value beyond Ahlswede--Khachatrian"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer t \u2265 1, the asymptotic density c_t of nonnegative integers n such that s\u2082(n+t) \u2265 s\u2082(n) satisfies c_t \u2265 1/2 + 2^(-(2\u00b7s\u2082(t)+1)), where s\u2082(m) denotes the number of ones in the binary expansion of m. This is the main theorem proved in the paper, resolving Cusick's conjecture with an explicit quantitative gap.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2373",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23398v1",
    "status": "available",
    "timestamp": "2026-06-23T16:48:35.543989+00:00",
    "title": "Cusick's Sum-of-Digits Explicit Bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every n,k,r with n \u2265 2k, k \u2265 3, and r \u2265 2, let (\ud835\udcd5_i)_{i\u2208Fin r} be k-uniform families of subsets of Fin n. Assume each \ud835\udcd5_i is non-trivial, meaning it is not contained in any star, and assume the families are pairwise cross-intersecting: for i \u2260 j, every A \u2208 \ud835\udcd5_i and B \u2208 \ud835\udcd5_j have A \u2229 B \u2260 \u2205. Then the multilateral product is bounded by the Hilton--Milner value: \u220f_{i\u2208Fin r} |\ud835\udcd5_i| \u2264 h(n,k)^r, where h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2375",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23322v1",
    "status": "available",
    "timestamp": "2026-06-23T17:25:43.582970+00:00",
    "title": "Multilateral non-trivial cross-intersection product bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For q \u2265 3 and n \u2265 4, there exists a non-trivial Boolean degree one function on the Grassmann scheme J_q(n,2) that is not in the trivial list (0, 1, x_p, 1-x_p, y_r, 1-y_r, x_p+y_r, 1-x_p-y_r).",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2376",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23465v1",
    "status": "available",
    "timestamp": "2026-06-23T17:44:54.697706+00:00",
    "title": "Existence of Non-Trivial Boolean Degree One Functions on J_q(n,2) for q \u2265 3 and n \u2265 4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For fixed integers $k \\ge 2$ and $1 \\le m_1 \\le \\cdots \\le m_k$, there exists an integer $n_0$ such that for all $n \\ge n_0$ and every $n$-vertex tree $T$, the Ramsey number satisfies $R(T, K_{m_1, \\ldots, m_k}) \\le (k-1)(R(T, K_{m_1, m_2})-1)+m_1$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2377",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23659v1",
    "status": "available",
    "timestamp": "2026-06-23T17:46:25.991940+00:00",
    "title": "Resolution of Erd\u0151s Problem 550 on Tree versus Complete Multipartite Ramsey Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Let G be a finite left-regular bipartite graph of left degree d \u2265 2 with left vertex set L and right vertex set R. Suppose G is s-optimal in the small-set sense that every nonempty X \u2286 L with |X| \u2264 s satisfies |N(X)| \u2265 (d - 1)|X| + 1. Then the binary Tanner code B(G) defined by the right-side parity checks has minimum Hamming distance at least s + 1; equivalently, every codeword x \u2208 B(G) whose support has size at most s is the zero word.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2378",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23579v1",
    "status": "available",
    "timestamp": "2026-06-23T18:03:42.374042+00:00",
    "title": "S-optimal Tanner graphs have no binary codewords of weight at most s"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed integer k >= 2, the normalized excess g_k(n) / log n converges in natural density to the binary upper-bound constant (k - 1) / log 2. Equivalently, for every epsilon > 0, the proportion of n <= x for which |g_k(n) / log n - (k - 1) / log 2| > epsilon tends to 0 as x tends to infinity.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2379",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23661v1",
    "status": "available",
    "timestamp": "2026-06-23T18:54:10.361464+00:00",
    "title": "Binary Leading Constant for the Almost-Everywhere Size of Factorial Excess"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every prime p and every n with n >= 10*p + 11, the codimension-three rational cohomology of the Hecke congruence subgroup Gamma_{0,n}(p) is zero: H^{binom(n,2)-3}(Gamma_{0,n}(p); Q) = 0.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_2380",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23519v1",
    "status": "available",
    "timestamp": "2026-06-23T18:04:16.541804+00:00",
    "title": "Codimension-three rational cohomology of Hecke congruence subgroups vanishes in a linear stable range"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let \u03a3 be a finite connected signed simple graph, let v be a non-isolated vertex, and let \u03c1(\u03a3) denote the spectral radius of its signed adjacency matrix. The paper proves \u03c1(\u03a3)^2 \u2264 \u03c1(\u03a3 - v)^2 + 2 d(v) - 1. Conjecture: equality holds if and only if either the underlying unsigned graph is a star and v is a pendant vertex, or the underlying unsigned graph is complete and the signing is balanced or antibalanced.",
    "domains": [
      "Pythagorean",
      "Physics"
    ],
    "id": "fd_2381",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23584v1",
    "status": "available",
    "timestamp": "2026-06-23T18:55:02.130931+00:00",
    "title": "Equality cases for signed vertex-deletion spectral-radius bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every finite tree T and every integer k >= 2 with part sizes 1 <= m_1 <= ... <= m_k, the Ramsey number of T against the complete k-partite graph K_{m_1,...,m_k} is at most (k-1)(R(T,K_{m_1,m_2})-1)+m_1. This removes the sufficiently-large-tree hypothesis from the main theorem of the paper. It is falsifiable by a single explicit finite tree T, parameter tuple (m_1,...,m_k), and red-blue coloring on the claimed number of vertices avoiding both a red T and a blue K_{m_1,...,m_k}.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2382",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23659v1",
    "status": "available",
    "timestamp": "2026-06-23T19:08:41.918612+00:00",
    "title": "Finite Erd\u0151s-550 Ramsey Upper Bound Without the Large-Tree Hypothesis"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer base b \u2265 2 and every t \u2265 1, let s_b(n) be the sum of the base-b digits of n. The limiting density, computed along complete radix intervals [0, b^k), of n such that s_b(n+t) \u2265 s_b(n) exists and is strictly greater than 1/2. Equivalently, the sequence (# {0 \u2264 n < b^k : s_b(n+t) \u2265 s_b(n)} / b^k) converges to a real c_{b,t} with c_{b,t} > 1/2. A counterexample would be a pair (b,t) with b \u2265 2, t \u2265 1 for which this limit fails to exist or is \u2264 1/2.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2383",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23398v1",
    "status": "available",
    "timestamp": "2026-06-23T20:33:56.015910+00:00",
    "title": "Base-b Cusick Bias for Sum-of-Digits Increments"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer k \u2265 2, there exists an open interval I_k \u2282 (0,1) such that for all \u03b2 \u2208 I_k, the minimum fixed-density semi-inducibility of the red-blue star S_{k,1} (with k red edges and 1 blue edge from a distinguished center) at density \u03b2 strictly exceeds min(\u03b2^k(1\u2212\u03b2), \u03b2(1\u2212\u03b2)^k), the envelope formed by the quasi-clique and quasi-star constructions. This generalizes the paper's result for S_{2,1}, where the true minimum is given by a three-class complement-split family rather than the natural quasi-star/quasi-clique endpoint profile on an interval around \u03b2 = 1/2. For S_{k,1}, the conjectured minimizer is a step-function graphon with at most k+1 classes.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2384",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23351v1",
    "status": "available",
    "timestamp": "2026-06-23T20:57:57.730978+00:00",
    "title": "Complement-split minima exceed the quasi-star/quasi-clique envelope for semi-induced stars S_{k,1}"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In the wall version of Menger's theorem (Theorem 1 of the paper), the separator bound f can be taken to equal s' - 1, matching the classical Menger bound. Specifically: for all positive integers s' and t', there exists an integer t such that for any vertex set A and any wall W of size at least t, either there exists a vertex set X of size at most s' - 1 that separates A from the branch vertices of W, or there exists a subwall W' of size at least t' together with s' vertex-disjoint A-W'-paths each ending in a distinct nail of W'.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2385",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23121v1",
    "status": "available",
    "timestamp": "2026-06-23T21:19:02.613185+00:00",
    "title": "Wall-Menger Separator Optimality Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The specific degree one function on the Grassmann scheme $J_3(4,2)$ defined by $f = \\frac{1}{2} \\sum_{Q(p) = 0} x_p + \\frac{1}{6} \\sum_{Q(p) = 1} x_p - \\frac{1}{6} \\sum_{Q(p) = 2} x_p$, where $Q(x,y,z,w) = x^2 + y^2 + z^2 - w^2$ is an elliptic quadric over $\\mathbb{F}_3$, is Boolean and not a trivial Boolean degree one function.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2386",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23465v1",
    "status": "available",
    "timestamp": "2026-06-23T21:41:56.533485+00:00",
    "title": "Non-triviality of the Bruen-Drudge Boolean degree one function on $J_3(4,2)$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every natural number n \u2265 1, the number of 2-binomial equivalence classes of binary words of length n equals the n-th cake number: |{0,1}^n / \u223c\u2082| = (n\u00b3 + 5n + 6)/6 = \u03a3_{r=0}^{3} C(n,r). Two words u,v \u2208 {0,1}* are 2-binomially equivalent if for every word w of length at most 2, the binomial coefficient (u choose w) = (v choose w), where (u choose w) counts scattered subword occurrences of w in u. This identity, first proved by Rigo and Salimov (2015), connects the algebraic structure of k-binomial equivalence on words to the enumerative geometry of hyperplane arrangements in \u211d\u00b3 via the Steiner-Schl\u00e4fli formula.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2387",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23426v1",
    "status": "available",
    "timestamp": "2026-06-23T22:02:34.284898+00:00",
    "title": "Binary 2-binomial equivalence class count equals cake number"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a finite group \\(\\Gamma\\) and any non\u2011negative function \\(f:\\Gamma\\to\\mathbb{R}_{\\ge 0}\\), define the two\u2011sided correlation kernel \\(\\mathcal C_f\\) by\n\\[\\mathcal C_f(x,y)=\\frac{1}{|\\Gamma|}\\sum_{a_1,a_2\\in\\Gamma:\\, xa_1=a_2 y} f(a_1)f(a_2) = \\mathbb{E}_{z\\in\\Gamma} f(x^{-1}z)f(zy^{-1}).\\]\nThe conjecture asserts that \\(\\mathcal C_f\\) satisfies Sidorenko\u2019s inequality for **all** finite (undirected) bipartite graphs \\(H\\):\n\\[ t(H,\\mathcal C_f) \\ge t(K_2,\\mathcal C_f)^{e(H)}. \\]\nEquivalently, the homomorphism density of any bipartite graph in \\(\\mathcal C_f\\) is at least the \\(e(H)\\)-th power of the edge density of \\(\\mathcal C_f\\). This extends the theorem of the paper, which proves the statement only for directed graphs (or for the 1\u2011subdivision of any directed graph). The conjecture is precise and falsifiable: a single counterexample \\((\\Gamma,f,H)\\) with \\(t(H,\\mathcal C_f)<t(K_2,\\mathcal C_f)^{e(H)}\\) disproves it.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2389",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23018v1",
    "status": "available",
    "timestamp": "2026-06-23T22:54:21.592113+00:00",
    "title": "Sidorenko Property for Two\u2011Sided Correlation Kernels on Finite Groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a number field k with r\u2081 real and r\u2082 complex places, let b = r\u2081\u00b7\u230an\u00b2/4\u230b + r\u2082\u00b7n(n-1)/2. For any cohomological generic representation \u03c0 in R_\u03b5^{coge,\u221e} of GL(n,k_\u221e) with coefficient system F_\u03c0 and quadratic character \u03b5: \u03c0\u2080(k_\u221e\u00d7) \u2192 \u2102\u00d7, the Betti-Whittaker period of the contragredient \u03c0\u2228 in degree b satisfies P^b(\u03c0\u2228, F_{\u03c0\u2228}, \u03b5) = \u03b5(disc(k))^b \u00b7 P^b(\u03c0, F_\u03c0, \u03b5), where disc(k) is viewed as an element of \u03c0\u2080(k_\u221e\u00d7) via the determinant identification \u03c0\u2080(k_\u221e\u00d7) \u2245 \u03c0\u2080(GL_n(k_\u221e)).",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2391",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23171v1",
    "status": "available",
    "timestamp": "2026-06-23T22:02:58.683140+00:00",
    "title": "Betti-Whittaker Period Relation for Contragredient Representations of GL(n)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the imaginary quadratic field K = Q(i), the automorphism group of a very general S_K(2)-polarized K3 surface X_{K,2} is isomorphic to the projective principal congruence subgroup of level 2 of the Bianchi group PGL_2(O_K). Specifically, Aut(X_{Q(i),2}) \u2245 P\u0393_{Q(i)}(2).",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2392",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22921v1",
    "status": "available",
    "timestamp": "2026-06-23T22:28:18.306332+00:00",
    "title": "Exact Realization of Level-2 Bianchi Congruence Subgroups as K3 Surface Automorphisms over Q(i)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every connected, twin-free Cayley digraph of a finite abelian group is stable, i.e., for such a digraph G, Aut(G \u00d7 K\u2082) = Aut(G) \u00d7 Aut(K\u2082). This extends the paper's result (Theorem 1.3) which proves nonexistence of nontrivially unstable Cayley digraphs of abelian groups of odd order to all finite abelian groups, resolving the even order case that remains open.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2393",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22947v1",
    "status": "available",
    "timestamp": "2026-06-23T22:54:48.936774+00:00",
    "title": "Stability of Cayley Digraphs of Abelian Groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every SIC dimension d with base quadratic field K = Q(\u221a\u0394\u2080), and for every Weyl-Heisenberg SIC overlap unit \u03b5 (the absolute value of a mutual scalar product of distinct SIC vectors), there exist Stark units \u03b7\u2081, ..., \u03b7\u2096 of the ray class field K^{fd\u221e\u2081} (where f is the conductor dividing f\u2080(d)) and integers n\u2081, ..., n\u2096 such that \u03b5 = \u220f\u1d62 \u03b7\u1d62^{n\u1d62/2}. In the minimal case (f = 1), the Stark units belong to K^{d\u221e\u2081} attached to the maximal ring of integers; in the non-minimal case, a lattice of ray class fields K_L^{d;f} is involved. This unifies the observed algebraic structure of SIC overlaps with Stark's conjectures and the Shintani\u2013Faddeev modular cocycle.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2396",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23535v1",
    "status": "available",
    "timestamp": "2026-06-23T23:19:20.704819+00:00",
    "title": "SIC Overlap Units are Products of Square Roots of Stark Units"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let G be a simple left d-regular bipartite graph with d \u2265 2 and girth at least 2k + 2. Then the minimum distance of the binary linear code B(G) is at least k + 1. This connects the combinatorial structure of optimal small-set expanders (characterized by girth) to the coding-theoretic properties of their associated codes, which is central to the paper's application to post-quantum key exchange.",
    "domains": [
      "Cryptography",
      "Algebra"
    ],
    "id": "fd_2397",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23579v1",
    "status": "available",
    "timestamp": "2026-06-23T23:53:07.212970+00:00",
    "title": "Girth bounds minimum distance of bipartite graph codes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the full flag variety GL_{n+1}/\u2102 B, let w \u2208 S_{n+1} index the Schubert cell X_w^o. The cluster algebra structure on \u2102[X_w^o] (coming from the reduced expression of the longest element in the Weyl group modulo the stabilizer of w) is of finite type if and only if w is a Grassmannian permutation (i.e., w has at most one descent).",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2398",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23474v1",
    "status": "available",
    "timestamp": "2026-06-24T00:22:07.112237+00:00",
    "title": "Finite type of cluster algebras on Schubert cells in type A flag varieties"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For integers d\u22652 and n\u22652d+2, the maximum size M_d(n) of a (d+1)-uniform family on [n] with VC\u2011dimension at most d equals the maximum, over 0\u2264k\u2264\u230ad/2\u230b, of the sum of binomial coefficients \u03a3_{i=0}^k binom{n-2i-1}{d-2i}. This quantity is attained by the \u201clayered star\u201d construction that takes all (d+1)-subsets containing a fixed element and, for each i\u2264k, also all (d+1)-subsets containing a second fixed element and missing exactly i additional prescribed points. The conjecture refines the Ahlswede\u2013Khachatrian bound and predicts the exact extremal families for all d and n.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2399",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23469v1",
    "status": "available",
    "timestamp": "2026-06-24T00:56:46.736617+00:00",
    "title": "A Sharp Upper Bound for Uniform VC\u2011Dimension Families via Layered Stars"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For a connected signed graph \u03a3 and a non-isolated vertex v, the inequality \u03bb\u2081(\u03a3) \u2264 \u221a(\u03bb\u2081\u00b2(\u03a3\u2212v) + 2d(v) \u2212 1) holds, with equality if and only if \u03a3 is a signed star with v as the center or \u03a3 is a signed complete graph.",
    "domains": [
      "Physics"
    ],
    "id": "fd_2400",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23584v1",
    "status": "available",
    "timestamp": "2026-06-24T01:36:45.202062+00:00",
    "title": "Equality Cases for Spectral Radius Bound in Signed Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every \u2286-minimal minor-closed graph class with limiting density greater than some \u03b4 < 3/2 can be characterized by excluding a single graph as a minor. Formally, for any such class \ud835\udca2, there exists a graph H such that \ud835\udca2 = excl({H}).",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2402",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24326v1",
    "status": "available",
    "timestamp": "2026-06-24T02:41:49.567859+00:00",
    "title": "Minimal Minor-Closed Classes Below 3/2 Have Single Forbidden Minors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers n \u2265 (s+1)k and a prime power q, the maximum cardinality m_q(n,k,s) of a family of k\u2011dimensional subspaces of an n\u2011dimensional vector space over \ud835\udd3d_q with no s+1 members whose sum is direct equals the larger of the two natural constructions: all k\u2011subspaces contained in a ((s+1)k\u22121)\u2011dimensional subspace, or all k\u2011subspaces intersecting a fixed s\u2011dimensional subspace nontrivially.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2403",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24529v1",
    "status": "available",
    "timestamp": "2026-06-24T04:01:44.618392+00:00",
    "title": "Exactevaluation of the vector-space Erd\u0151s Matching number m_q(n,k,s)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any prime power q and integers k, n with 2 \u2264 k \u2264 n/2, if n \u2265 2k+1 then every Boolean degree-one function on the Grassmann scheme J_q(n,k) is trivial (i.e., a linear combination of point indicators and their duals with coefficients in {0,1}). This extends the known result for q=2 and matches the thresholds proved for q=3,4,5 in the case k=2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2405",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23465v1",
    "status": "available",
    "timestamp": "2026-06-24T05:25:46.726799+00:00",
    "title": "Degree-one triviality threshold for Grassmann schemes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every positive integer n there exists a finite family of pairwise disjoint open convex subsets of \u211d^{3n} whose space of line transversals has non\u2011trivial reduced homology in degree n\u22121.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2406",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23193v1",
    "status": "available",
    "timestamp": "2026-06-24T05:50:07.508827+00:00",
    "title": "Non-acyclicity of transversal spaces in high dimensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any Cayley digraph G of an abelian group of even order, the pair (G, K\u2082) is unstable.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2407",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22947v1",
    "status": "available",
    "timestamp": "2026-06-24T06:20:52.702234+00:00",
    "title": "Stability of Cayley Digraphs of Even Order with K2"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For positive integers s and r, set T(s,r) = (8*s + 4)*r and F(s) = 4*s - 4. Conjecture: in every finite simple graph G, for every vertex set A and every elementary wall W in G of height at least T(s,r), either there is a vertex set X with |X| \u2264 F(s) separating A from the branch vertices of W, or W contains an r-subwall W' for which there are s pairwise vertex-disjoint A--W' paths whose W'-endvertices are distinct nails of W' and whose internal vertices avoid A \u222a V(W'). This gives an explicit linear-in-r wall-size bound and an explicit separator bound depending only on s, strengthening the existential bound pattern of the paper in the one-terminal-set case.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2408",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23121v1",
    "status": "available",
    "timestamp": "2026-06-24T07:12:31.058915+00:00",
    "title": "Linear one-set wall-Menger bound for elementary walls"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This paper investigates the interpolation properties of partial-twuality polynomials defined on set systems associated with binary delta-matroids, extending existing results to all nontrivial twuals and highlighting the role of categorical structure.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2410",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22888v1",
    "status": "available",
    "timestamp": "2026-06-24T08:15:06.141089+00:00",
    "title": "Interpolation of Partial-Twuality Polynomials in Binary Delta-Matroids"
  },
  {
    "consumed_by_exp_id": "",
    "description": "If a pure r-dimensional complex K achieves the spectral radius bound q_{r-1}(K) = tn - (t-1)(r+1), then all links of (r-t)-dimensional faces must have trivial reduced homology H_t(lk_K(\u03c3), R) = 0.",
    "domains": [
      "Geometry",
      "Physics"
    ],
    "id": "fd_2411",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22825v1",
    "status": "available",
    "timestamp": "2026-06-24T08:40:38.583867+00:00",
    "title": "Necessity of Homological Condition for Spectral Radius Bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for all integers $k \\ge 2$ and $n \\ge 0$, letting $m = \\lfloor n/k \\rfloor$ and $r = n - mk$, the inversion enumerator $a_n^{(k)}(q)$ of permutations whose descent set is exactly $\\{i : k \\mid i\\}$ satisfies the product formula\n$$ a_n^{(k)}(q) = q^{\\binom{m}{2}\\,k + \\binom{r}{2}} \\; \\prod_{j=0}^{m-1} \\begin{bmatrix} n - jk \\\\ k \\end{bmatrix}_q \\; \\cdot \\; \\begin{bmatrix} n - mk \\\\ r \\end{bmatrix}_q, $$\nwhere $\\begin{bmatrix} a \\\\ b \\end{bmatrix}_q$ denotes the Gaussian (or $q$-) binomial coefficient.  This identity extends the analytic derivation of the generating function $F_k(t;q)$ given in the paper and can be verified computationally for many small $k$, $n$, and $q$ (e.g., $q=2,3$).  It is proposed as a new combinatorial closed form for the $q$-inversion enumerator of $k$-alternating permutations.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2412",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23748v1",
    "status": "available",
    "timestamp": "2026-06-24T09:12:06.701682+00:00",
    "title": "A closed-form product formula for $k$-alternating permutation inversion enumerators"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every positive integer s, there exists a finite connected simple graph G whose poset of FAT vertex colorings has exactly s maximal elements under the refinement order; equivalently, G has exactly s irreducible FAT colorings. This strengthens the realization theorem in the paper by requiring the realizing graph to be connected.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2413",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22374v1",
    "status": "available",
    "timestamp": "2026-06-24T09:34:21.916191+00:00",
    "title": "Connected realization of arbitrary irreducible FAT-coloring counts"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every 4-connected planar graph with an even number n \u2265 4 of vertices has at least n\u00b2/8 perfect matchings. This conjecture bridges the known linear lower bound and the existence of 4-connected planar graphs with quadratically many perfect matchings, and would establish a sharp threshold between 3-connected (constant) and 5-connected triangulations (exponential) behavior.",
    "domains": [
      "Pythagorean",
      "Bridges"
    ],
    "id": "fd_2414",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22253v1",
    "status": "available",
    "timestamp": "2026-06-24T10:03:02.541653+00:00",
    "title": "Quadratic Lower Bound for Perfect Matchings in 4-Connected Planar Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For each integer v \u2265 1, let F_v(q) denote the q\u2011series given in equation (1.1) of the paper. Conjecture: the Fourier coefficients of F_v(q) are all integers.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2415",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22458v1",
    "status": "available",
    "timestamp": "2026-06-24T10:37:22.686031+00:00",
    "title": "Integrality of coefficients in Eichler-Selberg type relations for third-order mock theta functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer $i \\geq 0$ and prime $p$, there exists a constant $C_i$ such that the rational cohomology of the Hecke congruence subgroup $\\Gamma_{0,n}(p)$ vanishes in codimension $i$ for all $n \\geq C_i p$. This extends the paper's results which prove this for $i=0,1,2$ with bounds $n \\geq \\frac{p+14}{6}$, $n \\geq 4p+5$, and $n \\geq 7p+8$ respectively.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_2417",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23519v1",
    "status": "available",
    "timestamp": "2026-06-23T23:53:53.632851+00:00",
    "title": "Linear Vanishing Bound for Hecke Congruence Subgroup Cohomology"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For every natural number n > 7, the equation n! + 1 = m^2 has no integer solution m. In other words, the only solutions to the Brocard problem are the three known Brown pairs (4,5), (5,11), and (7,71).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2418",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23485v1",
    "status": "available",
    "timestamp": "2026-06-24T00:22:38.508639+00:00",
    "title": "Non\u2011existence of Further Brown Numbers Beyond n=7"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that the constants in the known bounds for $g_k(n)$ are best possible. For each $k\\ge2$, the liminf of $g_k(n)/\\log n$ equals $3(k-1)/\\log12$ and the limsup equals $(k-1)/\\log2$. Equivalently, any larger lower constant fails on a set of density\u00a01 and any smaller upper constant fails on a set of density\u00a01.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2419",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23661v1",
    "status": "available",
    "timestamp": "2026-06-24T00:59:28.784546+00:00",
    "title": "Optimality of the density\u2011one lower and pointwise upper bounds for Erd\u0151s Problem\u202f400"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for all integers t \u2265 2 and m \u2265 1, if nonzero linear forms \u2113\u2081,\u2026,\u2113_t over a field of characteristic zero have m-th powers \u2113\u2081^m,\u2026,\u2113_t^m that are minimally linearly dependent, then dim Span{\u2113\u2081,\u2026,\u2113_t} \u2264 (t + m - 2)/m, with equality if and only if the linear forms are linearly dependent in a way that their supports form a rational normal curve in the Veronese embedding.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2420",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24349v1",
    "status": "available",
    "timestamp": "2026-06-24T01:38:01.066930+00:00",
    "title": "Sharp dimension bound for minimal dependencies of linear-form powers in Veronese circuits"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let A be any finite parallel toric arrangement in (C*)^n, defined by nonzero rank-one integral characters and constants in C*. If n >= 2, then the Euler-Poincare characteristic of the complement M(A) is zero. Equivalently, deleting any finite family of pairwise disjoint parallel hypertori from a complex algebraic torus of dimension at least two does not change the vanishing Euler characteristic of the ambient torus.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2421",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24299v1",
    "status": "available",
    "timestamp": "2026-06-24T02:19:37.944210+00:00",
    "title": "Vanishing of Euler characteristic for higher-dimensional parallel toric arrangement complements"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For tensor-product function spaces with a worst-case function h satisfying specific integrality and sparsity conditions, the information complexity for non-negative linear rules exhibits a curse of dimensionality.",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_2422",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24195v1",
    "status": "available",
    "timestamp": "2026-06-24T04:05:20.240232+00:00",
    "title": "Exponential Information Complexity in Tensor-Product Function Spaces"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every natural number n the hyperplane arrangement A_n constructed in the paper (the 3-dimensional member of the infinite family) has exactly sum_{i=0}^3 binomial(n,i) full-dimensional chambers, and the number of chambers of codimension k equals binomial(n,k) for each k=0,1,2,3.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2423",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23426v1",
    "status": "available",
    "timestamp": "2026-06-24T05:26:09.585106+00:00",
    "title": "Chamber count conjecture for the binary 2-binomial equivalence hyperplane arrangement"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every finite quiver Q, the 3\u2011center Z\u2083(\ud835\udd42Q\u22651) (the set of all St\u2083\u2011elements) coincides with the \ud835\udd42\u2011span of all paths of length at most\u202f2 whose source and target vertices are equal (including trivial paths). This gives a concrete, testable description of the 3\u2011center and is falsifiable by finding a St\u2083\u2011element involving a longer path.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2424",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23024v1",
    "status": "available",
    "timestamp": "2026-06-24T06:21:04.823853+00:00",
    "title": "The 3-center of the principal subalgebra of a path algebra is generated by length\u2011\u22642 closed paths"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any finite simple graph G, the externally supported independence number es(G) satisfies es(G) \u2265 \u2308\u03b1(G)/(\u0394(G)+1)\u2309, where \u03b1(G) is the independence number and \u0394(G) the maximum degree.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2425",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22972v1",
    "status": "available",
    "timestamp": "2026-06-24T07:12:56.145887+00:00",
    "title": "ESI_lower_bound_conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formulate a precise conjecture stating that the endpoint Fourier restriction inequality for the three\u2011dimensional paraboloid over a prime field \ud835\udd3d\u209a (with \u20131 non\u2011square) holds if and only if the set of integer lattice points on the Euclidean paraboloid  \\(\\{(x,y,z)\\in\\mathbb Z^3 : z = x^2 + y^2\\}\\) is a \u039b(3) set. This makes the qualitative observation in the paper into a bidirectional, falsifiable statement that can be expressed in the language of finite\u2011field harmonic analysis and additive combinatorics, and thus be formalised in Lean 4.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2426",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22882v1",
    "status": "available",
    "timestamp": "2026-06-24T07:47:01.901499+00:00",
    "title": "Equivalence between the finite\u2011field endpoint restriction estimate for the 3\u2011dimensional paraboloid and the \u039b(3) property of the integer lattice paraboloid"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any finite polymatroid P with ground set E and rank function f, and any integer j with 1 \u2264 j \u2264 f(E)\u22121, the j\u2011th slice\u2011projection from the top of P is connected if and only if the j\u2011th slice\u2011projection from the bottom of its dual polymatroid P\u204e is connected. This extends the known equality for j = 1 (deletion/contraction) to all intermediate slice\u2011projections.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2427",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22819v1",
    "status": "available",
    "timestamp": "2026-06-24T08:15:33.714345+00:00",
    "title": "Dual Slice-Projection Connectivity Conjecture for Polymatroids"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for all grid sizes m,n \u2265 3 the number of vertices of degree\u202f4 in the flip graph of the m\u00d7n Miura\u2011ori equals (m\u20111)(n\u20111).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2428",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22614v1",
    "status": "available",
    "timestamp": "2026-06-24T08:42:34.928992+00:00",
    "title": "Degree\u20114 vertices in the flip graph of the m\u00d7n Miura\u2011ori"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any fixed k \u22653 and \u03b3 > \u03b3_k (as defined in the paper), there exists a constant c >0 such that any induced-K_{1,k}-free graph G with edge density at least \u03b3 is within edit distance at most cn\u00b2 of a graph that is the union of k\u22121 cliques with no edges between them. This conjecture directly formalizes the paper's structural claim about the supercritical regime and can be verified by proving bounds on the deviation from such a partitioned structure.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2429",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22661v1",
    "status": "available",
    "timestamp": "2026-06-24T09:14:43.208847+00:00",
    "title": "Typical structure of induced-K_{1,k}-free graphs in the supercritical regime"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let k be a totally real number field, p a prime, and Sigma a nonempty set of p-adic primes of k. Suppose the Galois group X_Sigma(k) of the maximal abelian pro-p extension of k unramified outside Sigma has Z_p-rank exactly 1, so that there is a unique Sigma-ramified Z_p-extension N_infty/k. Then the unramified Iwasawa module X(N_infty) is finite as a Z_p-module.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2430",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22324v1",
    "status": "available",
    "timestamp": "2026-06-24T09:35:03.389870+00:00",
    "title": "Restricted-ramification Greenberg finiteness for rank-one p-ramified towers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the complete bipartite graph K_{a,b} with 2 \u2264 a \u2264 b, transmission proportion p = 1/a, and threshold \u03c4 = 1, the transmission zero forcing number TZF(K_{a,b}, 1/a, 1) equals a. This conjecture posits that the minimum initial set consists of all vertices from the smaller part, and that no smaller set can percolate under these parameters.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2431",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22246v1",
    "status": "available",
    "timestamp": "2026-06-24T10:09:46.202583+00:00",
    "title": "Transmission Zero Forcing Number of Complete Bipartite Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For fixed integers t \u2265 2, r \u2265 2 and n \u2265 1, let a coloring c : (Fin t)^n \u2192 Fin r be *coordinate\u2011symmetric*, i.e. c depends only on the vector of letter\u2011counts (the histogram of each colour in the word). Define the discrete simplex \u0394_{t,n} = {v : Fin t \u2192 \u2115 // \u2211_{i} v i = n}. A *corner tuple* in \u0394_{t,n} is a triple (v, v+e_i, v+e_j) with i \u2260 j and e_i the unit vector at i, provided the three vectors lie in \u0394_{t,n}. The conjecture states that such a symmetric coloring c is line\u2011free (contains no monochromatic combinatorial line in [t]^n) if and only if no corner tuple of \u0394_{t,n} is monochromatic under the induced coloring on \u0394_{t,n}. This gives a finite, polynomial\u2011size certificate for line\u2011freeness of symmetric colorings, matching the reduction lemma used in the Hales\u2011Jewett lower\u2011bound constructions.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2432",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22155v1",
    "status": "available",
    "timestamp": "2026-06-24T10:38:46.496140+00:00",
    "title": "Equivalence of Line\u2011Freeness and Corner\u2011Tuple Monochromaticity for Coordinate\u2011Symmetric Colorings"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For each t,r >= 2, there exists N such that for all n >= N, any t-uniform hypergraph G on n vertices that is (n,d,\u03bb)-pseudo-random (i.e., each vertex has degree (1+o(1)) * binomial(n-1, t-1) and any two vertices belong to at most (1+o(1)) * binomial(n-2, t-2) edges) yields that any r-edge-colouring of G contains a monochromatic matching of size exactly floor((n+r-1)/(r+t-1)). In particular, this conjecture implies that the only extremal colourings achieving the Alon\u2013Frankl\u2013Lov\u00e1sz bound are the r\u2011strip colourings (vertex set partitioned into \u2264 r parts and colour depends only on intersection profile).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2433",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24863v1",
    "status": "available",
    "timestamp": "2026-06-24T10:40:06.279518+00:00",
    "title": "Exact Monochromatic Matching Bound for Pseudo-Random Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The current best asymptotic lower bound is g(r) \u2265 (61/20 - o(1))r \u2248 3.05r. We conjecture that the true asymptotic constant is at least 3.1, i.e., for every \u03b5 > 0, there exists r\u2080 such that for all r \u2265 r\u2080, g(r) \u2265 (3.1 - \u03b5)r.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2434",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24878v1",
    "status": "available",
    "timestamp": "2026-06-24T11:12:26.282616+00:00",
    "title": "Asymptotic Lower Bound Improvement for Erd\u0151s-Lov\u00e1sz Function"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let H be any nonempty finite simple graph, let b : Fin m -> Nat be a nonempty list of positive clique sizes, and let B(b) be the disjoint union of cliques K_{b_r}. Form the graph G = H * B(b), where * denotes graph join. If nu(b) is the number of indices r with b_r >= 2, then over every field k the Castelnuovo--Mumford regularity of the edge-ideal quotient satisfies reg_k(R/I(G)) = max(1, reg_k(R/I(H)), nu(b)). This extends the split-like and clique-star cases from the paper by replacing the independent or complete core by an arbitrary finite graph.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2435",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24822v1",
    "status": "available",
    "timestamp": "2026-06-24T11:34:29.009323+00:00",
    "title": "Regularity of arbitrary-core joins with clique blocks"
  },
  {
    "consumed_by_exp_id": "",
    "description": "A precise, falsifiable conjecture linking the density parameters \u03b1 and \u03b2 of vertical and horizontal stripes in aperiodic Wang tile families to a Diophantine condition on pairs of quadratic irrationals.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2436",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24693v1",
    "status": "available",
    "timestamp": "2026-06-24T11:55:24.898021+00:00",
    "title": "Sufficient condition for non-periodicity of awaited set of Wang tiles"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that a random linear code C \u2286 F_q^n of rate 1 - (1/n)log_q|B_\u03c1| (without the \u03b5 term) satisfies |C \u2229 B| = (1 \u00b1 o(1)) * |C||B|/q^n simultaneously for all radius-\u03c1 Hamming balls B with high probability. This extends the paper's result which requires an \u03b5 > 0 term.",
    "domains": [
      "Computation",
      "Pythagorean"
    ],
    "id": "fd_2437",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24471v1",
    "status": "available",
    "timestamp": "2026-06-24T13:27:56.688809+00:00",
    "title": "Random Linear Codes Achieve List-Decoding Capacity with Concentration"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjectures that the prime zeta function for imaginary quadratic fields with class number one has a natural boundary extending from the origin along the imaginary axis, preventing regularization of the product of all primes via standard zeta-regularization techniques.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2438",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24536v1",
    "status": "available",
    "timestamp": "2026-06-24T13:54:36.235382+00:00",
    "title": "Existence of a Natural Boundary for the Prime Zeta Function in Imaginary Quadratic Fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The stable tropical intersection is reduced iff specific structural conditions on the subvariety and fan hold, verified via algebraic validation.",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_2439",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24339v1",
    "status": "available",
    "timestamp": "2026-06-24T14:55:13.285563+00:00",
    "title": "Reduction Condition for Reduced Points"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecturally extend the known finiteness result for minor-closed classes with limiting density above a threshold to the setting of arbitrary density bounds. Specifically, for any rational number \\(\\delta < \\frac{3}{2}\\), we propose that the set of \\subseteq\\-minimal minor-closed classes with density \\(>\\delta\\) is finite. This refines the formulaic finiteness result to all density thresholds in the interval \\([0, \\frac{3}{2})\\), building on the structural properties of minor-closed classes and their limiting densities.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2440",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24326v1",
    "status": "available",
    "timestamp": "2026-06-24T15:23:10.637513+00:00",
    "title": "Finite Obstructions for Minor-Closed Classes with Bounded Limiting Density"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This paper investigates the local obstruction groups for obstructed deformation problems arising from weight\u2112 newforms of level N, using the Greenberg-Wiles formula and explicit classification of inertial Weil-Deligne types. It aims to provide a constructive framework for understanding deformation in arithmetic settings with restricted primes.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2441",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23918v1",
    "status": "available",
    "timestamp": "2026-06-24T15:53:57.795484+00:00",
    "title": "Obstructed deformation problems for weight-2 newforms with local-global conditions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer m \u2265 0, the regularised Wallis product P_m defined by\nP_m = \u220f_{n=2}^\u221e exp(\u2211_{r=1}^{\u230am/2\u230b} n^{m-2r}/r) (1 - 1/n^2)^{n^m}\nsatisfies\nlog P_m = -\u2211_{r=\u230am/2\u230b+1}^\u221e (\u03b6(2r - m) - 1)/r,\nwhere \u03b6 denotes the Riemann zeta function. This provides an explicit zeta\u2011function tail for the logarithm of each product in the hierarchy.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2442",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23973v1",
    "status": "available",
    "timestamp": "2026-06-24T16:30:22.002983+00:00",
    "title": "Logarithmic formula for the regularised Wallis hierarchy"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any bipartite graph G with partite sets A and B, the strong chromatic index satisfies \u03c7'_s(G) \u2264 \u0394_A \u0394_B, where \u0394_A and \u0394_B are the maximum degrees in each partition. This conjecture posits that the product of the maximum degrees in each partition forms an upper bound for the strong chromatic index, improving upon the current best-known bound of 1.676 \u0394_A \u0394_B for sufficiently large products.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2443",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23824v1",
    "status": "available",
    "timestamp": "2026-06-24T17:05:28.615107+00:00",
    "title": "Brualdi-Quinn Massey Strong Chromatic Index Conjecture for Bipartite Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture asserts no primes exceeding 7 satisfy $n! + 1 = m^2$ for $n < p$. This is falsifiable via computational checks.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2444",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23485v1",
    "status": "available",
    "timestamp": "2026-06-24T17:29:38.955405+00:00",
    "title": "The Non-Existence of New Factorial Square Solutions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any partition \u03bb of N, let G_\u03bb denote the abelian p-group associated with \u03bb. Then the number Nu(Per(G_\u03bb)) of distinct monomials in the group permanent satisfies: Nu(Per(G_\u03bb)) \u2261 1 (mod p^k) where k = 3 if p is a Wolstenholme prime and k = 2 otherwise, for all primes p \u2265 5 and all partitions \u03bb with |\u03bb| = N \u2265 p. This extends the known result for cyclic p-groups to all abelian p-groups classified by partitions.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2445",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23765v1",
    "status": "available",
    "timestamp": "2026-06-24T17:54:35.379551+00:00",
    "title": "Congruence Properties of Group Permanents for Abelian p-Groups and Wolstenholme Primes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for any prime power q, the Grassmann scheme J_q(n,k) is degree-one trivial (DOT) for all n >= N(q,k), where N(q,k) is a constant depending on q and k. Specifically, for q=2, N(2,k)=4 for min(k,n-k) >= 2, and for q > 2, the threshold N(q,k) must be determined to exclude sporadic counterexamples like the Bruen-Drudge example in J_3(4,2).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2446",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23465v1",
    "status": "available",
    "timestamp": "2026-06-24T18:25:05.562991+00:00",
    "title": "Characterization of Degree-One Triviality for Grassmannians over Finite Fields"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For each integer n\u22651 there exists a finite family C of pairwise disjoint compact (or open bounded) convex sets in \u211d^{3n} such that the space L(C) of all lines transversal to C is homeomorphic (hence homotopy equivalent) to the (n\u20111)-sphere S^{n\u20111}. Moreover, for any family of pairwise disjoint convex sets whose transversal space is non\u2011empty and whose reduced (n\u20111)\u2011st homology is non\u2011zero, the transversal space is homotopy equivalent to S^{n\u20111}. This refines the counterexamples to the Cheong\u2013Goaoc\u2013Holmsen conjecture by identifying the exact homotopy type.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_2448",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23193v1",
    "status": "available",
    "timestamp": "2026-06-24T19:51:02.889910+00:00",
    "title": "Homotopy type of line transversal spaces for disjoint convex families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any graph G, the externally supported independence number \u03b1_es(G) satisfies \u03b1_es(G) + 1 \u2265 \u03b1(G), where \u03b1(G) is the standard independence number.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2449",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22972v1",
    "status": "available",
    "timestamp": "2026-06-24T20:34:16.450064+00:00",
    "title": "Conjecture on Externally Supported Independence Number"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For rational \u03b2 = p/q, the natural extension has finite domain bridges.",
    "domains": [
      "Pythagorean",
      "Bridges"
    ],
    "id": "fd_2450",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23097v1",
    "status": "available",
    "timestamp": "2026-06-24T20:58:20.101200+00:00",
    "title": "Domain Finiteness"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: Let P be a connected polymatroid on a finite ground set E. For any element e \u2208 E that is neither a loop (f({e})=0) nor a coloop (f(E)\u2212f(E\\{e}) = f({e})), both the deletion P\u2212e and the contraction P/e are connected polymatroids. This would strengthen Hall's 2013 result which guarantees only two elements with at least one connected minor.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2451",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22819v1",
    "status": "available",
    "timestamp": "2026-06-24T21:36:52.673574+00:00",
    "title": "Both deletion and contraction of a non-loop non-coloop element preserve connectivity in connected polymatroids"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for a pure r-dimensional simplicial complex K on n vertices, if the reduced homology \\(\\widetilde{H}_t(\\text{lk}(\\sigma), \\mathbb{R}) = 0\\) for every face \\(\\sigma\\) of dimension r-t, then the signless Laplacian spectral radius q_{r-1}(K) is upper bounded by tn - (t-1)(r+1). Moreover, we propose that for r-down path connected K with n sufficiently large, equality holds if and only if K is a join of a (r+1-t)-simplex and a (t-1)-skeleton of a simplex of size n-r-1+t.",
    "domains": [
      "Geometry",
      "Pythagorean"
    ],
    "id": "fd_2452",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22825v1",
    "status": "available",
    "timestamp": "2026-06-24T21:58:37.105519+00:00",
    "title": "Signless Laplacian Spectral Radius of Pure Simplicial Complexes with vanishing link homology in dimension t"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for every integer degree d \u2265 1 there exists a polynomial P_d(m,n) with integer coefficients such that for all sufficiently large grid dimensions (i.e., m,n \u2265 T(d) for some threshold depending only on d) the number N_{m,n}(d) of vertices of degree d in the flip graph \u039f\u04b1G(\u0396_{m,n}) equals P_d(m,n). Moreover, P_d is symmetric in m and n and can be expressed as a \u2124\u2011linear combination of binomial coefficients.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2453",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22614v1",
    "status": "available",
    "timestamp": "2026-06-24T22:36:31.788869+00:00",
    "title": "Polynomial degree sequence for all degrees in the Miura\u2011ori flip graph"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The critical density \u03b3_k must exactly equal n\u00b2/k for the phase transition to occur.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2455",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22661v1",
    "status": "available",
    "timestamp": "2026-06-24T23:02:39.791517+00:00",
    "title": "Critical Density Determination"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer n \u2265 2, the number of irreducible FAT colorings of the complete graph on n vertices is equal to the number of positive divisors of n minus 1.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2456",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22374v1",
    "status": "available",
    "timestamp": "2026-06-24T23:35:09.093648+00:00",
    "title": "Number of Irreducible FAT Colorings in Complete Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every pair of integers q >= 2 and d >= 1, let H(d,q) be the d-fold Cartesian product of K_q, with vertex set Fin d -> Fin q and adjacency given by differing in exactly one coordinate. Then the (q-1)-limited domination number of H(d,q) is exactly q^(d-1). Equivalently, a single coordinate layer is optimal: gamma^{L}_{q-1}(K_q \u25a1 ... \u25a1 K_q) = q^(d-1).",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2457",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22428v1",
    "status": "available",
    "timestamp": "2026-06-25T00:19:28.962491+00:00",
    "title": "Layer threshold for limited domination in Hamming graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any finite simple graph G, let Z(G) denote its standard zero forcing number and TZF(G) its transmission zero forcing number as defined in the paper. We conjecture that TZF(G) \u2264 Z(G) for all graphs. Moreover, equality holds for all trees.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2458",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22246v1",
    "status": "available",
    "timestamp": "2026-06-25T00:51:34.043435+00:00",
    "title": "Transmission zero forcing number is bounded above by the classical zero forcing number"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This paper establishes improved lower bounds for the Hales-Jewett number through combinatorial line methods. The goal is to derive tight estimates by exploiting symmetry and constraint satisfaction, a task suitable for precise formalization in Lean with polynomial-size proofs.",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "id": "fd_2459",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22155v1",
    "status": "available",
    "timestamp": "2026-06-25T01:31:52.113586+00:00",
    "title": "Formalizing Hales-Jewett lower bounds via symmetric coloring in Lean"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The shifted t-Schur functions indexed by strict partitions satisfy an explicit Pfaffian Giambelli formula expressing s_\u03bb^Q(t) as a Pfaffian of Y-operator modes applied to the vacuum, generalizing the classical Schur Q-function case at t=0. Specifically, for strict partition \u03bb = (\u03bb\u2081, \u03bb\u2082, ..., \u03bb_k) with \u03bb\u2081 > \u03bb\u2082 > ... > \u03bb_k \u2265 0, the formula takes the form s_\u03bb^Q(t) = Pf[Y_{\u03bb_i - i + j}(t) + Y_{\u03bb_j - j + i}(t)]_{1\u2264i<j\u2264k} \u00b7 vac where the Pfaffian entries are determined by the Clifford algebra structure of the odd GJZ operators.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2460",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22058v1",
    "status": "available",
    "timestamp": "2026-06-25T02:07:55.532399+00:00",
    "title": "Pfaffian Giambelli Formula for Shifted t-Schur Functions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For integers d\u22652 and 0\u2264s\u2264d, let \u2131\u2286[n]^{(d+1)} be a (d+1)-uniform family such that every F\u2208\u2131 has a missing trace of size exactly s (i.e. there exists B_F\u2282F with |B_F|=s and B_F\u2209Tr_\u2131(F)). Define  W(d,s,n) = \\binom{n-1}{d} + \\binom{n-2(d+1-s)-2}{2s-d-2}  when the second term is defined (otherwise treat it as 0). The conjecture states that |\u2131| \u2264 W(d,s,n) for all n\u22652(d+1). Moreover, equality holds precisely for the constructions given by Chao\u2011Xu\u2011Yip\u2011Zhang and by the recent disproof for \u2308(d+2)/2\u2309\u2264s\u2264d\u20111.",
    "domains": [
      "Pythagorean",
      "Logic"
    ],
    "id": "fd_2461",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24776v1",
    "status": "available",
    "timestamp": "2026-06-24T10:40:45.798036+00:00",
    "title": "Corrected Uniform Witness Bound for (d+1)-Uniform Families"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every finite poset P of size n and width w \u2265 2, the number of strict alternating cycles satisfies s_w(P) \u2264 4\u00b7(w\u22121)!\u00b7(n(n+w)/(2w^2))^w.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2462",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24877v1",
    "status": "available",
    "timestamp": "2026-06-24T11:12:45.893373+00:00",
    "title": "Upper bound on the number of strict alternating cycles in posets of bounded width"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any finite transitively antisymmetrically ordered set S, the nilpotent Lie algebra L(S) constructed via the incidence algebra admits a left\u2011invariant Ricci soliton metric whose Ricci scalar curvature equals minus the ratio of the number of comparable pairs in S to the dimension of L(S). In particular, Ric = -((#comparable_pairs S) / (dim L(S)))\u00b7g.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2463",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24569v1",
    "status": "available",
    "timestamp": "2026-06-24T11:36:11.076325+00:00",
    "title": "Scalar curvature formula for incidence-algebra nilpotent Lie algebras"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For RSA modulus n=p*q with primes p>q, if the private exponent d satisfies d < n^{(1+\u03b4)/2} and a \u03b4-fraction of the most significant bits of p+q is known, then the modulus n can be factored using a modified Wiener's continued fraction attack.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2464",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24717v1",
    "status": "available",
    "timestamp": "2026-06-24T11:56:42.011405+00:00",
    "title": "RSA Factorization with Partial p+q Knowledge and Small Private Exponent"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any odd prime p and any integer \u2113 with 1 \u2264 \u2113 \u2264 (p-1)/2, if p > 2\u2113 + 1 then the maximum size of a symmetric subset S \u2286 Z_p with 0 \u2209 S and Cay(Z_p, S) containing no odd cycle C_{2\u2113+1} is exactly 2\u230a(p + 28 + 12)/(2(28 + 12))\u230b.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2465",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24426v1",
    "status": "available",
    "timestamp": "2026-06-24T13:31:30.394872+00:00",
    "title": "Odd cycle extremal conjecture for Cayley graphs over prime cyclic groups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any alpha \u2265 0 and any n \u2265 3, the H_alpha index of a binary phylogenetic tree with n leaves is uniquely minimized by the caterpillar tree and uniquely maximized by the fully balanced tree.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2466",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24562v1",
    "status": "available",
    "timestamp": "2026-06-24T13:57:00.706176+00:00",
    "title": "Extremal trees for H_alpha indices"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any prime power q and integer h \u2265 2, let n_min(q,h,k) denote the minimum length of a nondegenerate minimal additive code of dimension k over F_{q^h}. Then the limit lim_{k\u2192\u221e} n_min(q,h,k)/k exists and equals h\u00b7(q^h - 1)/(q - 1).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2467",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24262v1",
    "status": "available",
    "timestamp": "2026-06-24T15:00:24.085231+00:00",
    "title": "Asymptotic Growth Rate of Minimum Length for Minimal Additive Codes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "There exists a function space F_d associated with periodic L_p-discrepancy where the worst-case integration error equals the discrepancy, and non-negative linear rules require exponential point counts to achieve \u03b5-accuracy, confirming the curse of dimensionality.",
    "domains": [
      "Computation"
    ],
    "id": "fd_2468",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24195v1",
    "status": "available",
    "timestamp": "2026-06-24T15:27:55.505425+00:00",
    "title": "Exponential Information Complexity Lower Bound for Periodic L_p-Discrepancy via Duality Framework"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The limit \u03bb = lim_{n\u2192\u221e} D_n/n is exactly equal to 3/5*(7 - 8 ln 2), where D_n is the average stack-sorting depth over S_n. This would imply that Defant's upper bound is tight and the Golomb-Dickman constant is strictly less than \u03bb.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2469",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24110v1",
    "status": "available",
    "timestamp": "2026-06-24T15:56:46.510928+00:00",
    "title": "Conjecture: The limit of average stack-sorting depth equals Defant's upper bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all primes p, natural numbers k, and n \u2265 (3k + 1)p + (3k + 2), the rational cohomology group H^{binom(n,2)-k}(\u0393_{0,n}(p); \u211a) vanishes. This extends the proven codimension 1 and 2 results to arbitrary codimension k, conjecturing a linear dependence on p with coefficient (3k + 1) and constant term (3k + 2).",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2470",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23519v1",
    "status": "available",
    "timestamp": "2026-06-24T16:39:13.817680+00:00",
    "title": "Generalized vanishing range for Hecke congruence subgroup cohomology"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that the upper bound S\u2081^\u03c6(x) \u226a x exp(-(1/2+o(1))\u221a(log x log\u2082 x)) is best possible, i.e., there exists a function \u03b5(x)\u21920 such that S\u2081^\u03c6(x) \u226b x exp(-(1/2+o(1))\u221a(log x log\u2082 x)) for infinitely many x, or equivalently liminf_{x\u2192\u221e} (log (x/S\u2081^\u03c6(x))) / \u221a(log x log\u2082 x) \u2265 1/2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2471",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23681v1",
    "status": "available",
    "timestamp": "2026-06-24T17:06:47.221428+00:00",
    "title": "Optimality of the exponent in the upper bound for S\u2081^\u03c6(x)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Prove that for every integer \\(t\\ge 1\\), the density of integers \\(n\\) where \\(s_2(n+t) \\ge s_2(n)\\) exceeds \\(1/2\\), with a lower bound of \\(1/2 + 2^{-2s_2(t)-1}\\), by analyzing carry propagation as a finite random walk and utilizing first-exit medians in binary digit deconvolution.",
    "domains": [
      "Computation"
    ],
    "id": "fd_2472",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23398v1",
    "status": "available",
    "timestamp": "2026-06-24T17:30:07.652508+00:00",
    "title": "Strict Positivity of the Binary Sum-of-Digits Bias for All Integers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any d \u2265 1 and \u03b1 \u2208 (0,1], the beta function \u03b2(\u03b1,d) in the colorful and fractional Helly theorem for convex splinters in \u211d\u1d48 satisfies \u03b2(\u03b1,d) \u2265 \u03b1^(d+1). This conjecture posits a specific functional dependence of \u03b2 on \u03b1 and d, strengthening the existential result of the paper to a quantitative lower bound.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2473",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23437v1",
    "status": "available",
    "timestamp": "2026-06-24T17:58:21.103250+00:00",
    "title": "Lower Bound on Beta Function for Colorful and Fractional Helly's Theorem on Convex Splinters"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture asserts that coefficients a_n decay exponentially as \u03c1^{-n}, bounding their growth to ensure exact-size sampling feasibility.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2474",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23439v1",
    "status": "available",
    "timestamp": "2026-06-24T18:25:32.579492+00:00",
    "title": "Coefficient Decay Bound"
  },
  {
    "consumed_by_exp_id": "f6b20d87",
    "description": "Let k \u2265 2, n = k + 1, and D(k) = gcd_{2 \u2264 q \u2264 k+1} binom(qk,k). If P is the largest exact prime-power component p^a exactly dividing n, then D(k) is not merely nontrivial exactly when n/P \u2264 P; conjecturally its exact value is P in that case and 1 otherwise. Equivalently, D(k) = P if the largest exact prime-power component of k+1 dominates its complementary factor, and D(k) = 1 otherwise.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2475",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22997v1",
    "status": "in_progress",
    "timestamp": "2026-06-24T19:09:47.341905+00:00",
    "title": "Exact Value of the Binomial GCD in OEIS A080170"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any finite quiver Q containing a path of length at least 3, and the principal subalgebra KQ_{\u22651}, there exists an element x \u2208 KQ_{\u22651} that is an St\u2083-element but not a central element. This conjecture asserts that the sequence of St-centers Z\u2082(A) \u228a Z\u2083(A) is strict whenever the underlying quiver has paths of length \u2265 3, indicating that higher-order centrality genuinely provides more elements than ordinary centrality in these algebras.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2476",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23024v1",
    "status": "available",
    "timestamp": "2026-06-24T19:56:30.043961+00:00",
    "title": "St\u2083-elements are never central in path algebras with sufficiently long paths"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Given a number field k and a cohomological automorphic representation \u03c0 of GL_n(A_k) with a corresponding coefficient system F_\u03c0, there exists a precise proportionality relation between the Betti-Whittaker period P(\u03c0) and the period P(\u03c0^*) of its contragredient representation \u03c0^*, specifically relating them via a period factor involving the L-values and the volume of the relevant arithmetic quotients, independent of the regularity assumptions previously required by Chen.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2477",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23171v1",
    "status": "available",
    "timestamp": "2026-06-24T20:34:32.678693+00:00",
    "title": "Relation between Betti-Whittaker Periods for Contragredient Cohomological Representations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every binary delta-matroid D and partial-twuality operator \u22c6\u2219 \u2208 {\u00d7, \u2217\u00d7, \u00d7\u2217, \u2217\u00d7\u2217\u2217}, the partial-\u2219 polynomial ^\u2202w_D^{\u22c6\u2219}(z) is either even, odd, or both even-interpolating and odd-interpolating.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2478",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22888v1",
    "status": "available",
    "timestamp": "2026-06-24T21:09:29.440062+00:00",
    "title": "Intersection-Property of Partial-\u2219 Polynomials for Binary Delta-Matroids"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers k \u2265 2 and sufficiently large n, the maximum number of edges in a C_{4k+2}^{4-}-free 4\u2011uniform hypergraph on n vertices is exactly half of the total possible 4\u2011subsets, i.e., ex(n, C_{4k+2}^{4-}) = (1/2)\u00b7\\binom{n}{4}.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2479",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22828v1",
    "status": "available",
    "timestamp": "2026-06-24T21:37:07.819069+00:00",
    "title": "Tur\u00e1n density of 4\u2011uniform tight cycles minus one edge equals 1/2"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for every integer n \u2265 3 and real nonzero p,q, the two hypergeometric series expansions of a root of the trinomial x^n + p x + q = 0\u2014in powers of the discriminant D and in powers of its reciprocal\u2014satisfy a Kummer-like transformation. Precisely, if the D\u2011expansion is expressed as the {}_nF_{n-1} series with parameters (a_i)_{i=1}^n and (b_j)_{j=1}^{n-1}, then there exists an identity of the form:\n{}_nF_{n-1}(a_1,...,a_n; b_1,...,b_{n-1}; D) = (1-D)^\u03b3 {}_nF_{n-1}(b_1-a_1,...,b_{n-1}-a_{n-1},1; a_1,...,a_{n-1}; 1/D),\nwhere \u03b3 = \u03a3_{j=1}^{n-1}(b_j - a_j) + 1 - a_n. This reduces to the classical Kummer identities for n=3 and would provide a systematic higher-order analogue for all n\u22653.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2480",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23750v1",
    "status": "available",
    "timestamp": "2026-06-24T22:02:43.917391+00:00",
    "title": "Higher-order Kummer transformation for trinomial root series"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every integer k\u22652 and n\u22650, the polynomial a_n^{(k)}(q) equals the finite sum \u2211_{m=0}^{\u230an/k\u230b} q^{m(m+1)/2} * GaussianBinomial(n - m(k-1), m)_q where GaussianBinomial(n,m)_q denotes the q-binomial coefficient",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2481",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23748v1",
    "status": "available",
    "timestamp": "2026-06-24T22:36:50.930027+00:00",
    "title": "Closed-form conjecture for the inversion enumerator of k-alternating permutations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any projective variety V over the field with one element F\u2081, the cardinality |V(F\u2081)| equals the Euler characteristic \u03c7(V(C)) of V over the complex numbers, i.e., |V(F\u2081)| = \u03a3_{i=0}^{2n} (-1)^i dim H^i(V(C), \u211a).",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2484",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22010v1",
    "status": "available",
    "timestamp": "2026-06-25T00:52:44.061628+00:00",
    "title": "Euler Characteristic Conjecture for Varieties over F_1"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For an odd integer n, the set of affine panmagic permutations of Z_n of the form x \u21a6 a\u00b7x + b (with a a primitive root modulo n) is closed under composition of three or more elements and forms a subgroup of the general affine group GA(1,n). Moreover, the order of each such permutation equals the multiplicative order of a modulo n, and the cycle decomposition corresponds exactly to the orbits of the action of the cyclic group generated by a on Z_n. A counterexample would be an odd n for which the set fails to be closed under triple composition or the order does not equal the multiplicative order of a.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2485",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22221v1",
    "status": "available",
    "timestamp": "2026-06-25T01:32:08.689584+00:00",
    "title": "Conjecture on Multiplicative Structure of Affine Panmagic Permutations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For an integer matrix M with nonzero determinant and relatively prime entries, the ratio spectrum of Lagrange constants under linear fractional transformations is precisely the closed interval [1/|det M|, |det M|].",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2486",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.22229v1",
    "status": "available",
    "timestamp": "2026-06-25T02:08:18.320309+00:00",
    "title": "Ratio Spectrum of Lagrange Constants Under Linear Fractional Transformations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every k >= 1 and every n >= 2*k + 1, there exists a maximal standard social decision frame on exactly 2*n voters whose shortest perfectly balanced majority obstruction has length exactly 2*k + 2. Equivalently, the sparse infinite sequence of universe sizes supplied by the geometric construction can be filled in: once the half-size n is at least 2*k + 1, every larger even electorate size supports a maximal standard frame with incoherence index 2*k + 2.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2491",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25954v1",
    "status": "available",
    "timestamp": "2026-06-25T04:15:17.784537+00:00",
    "title": "Cofinite realization of every even incoherence index by maximal standard frames"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer parameters \\(a,b,c,d\\) with \\(a,b,c,d\\ge 0\\) and any base \\(q\\) with \\(|q|<1\\), define the rank\u2011four Nahm sum\n\\[\\Phi_{a,b,c,d}(q) \\;:=\\; \\sum_{i,j,k,l\\ge 0}\\frac{q^{\\frac12(i^2+aj^2+bk^2+cl^2)-ij-jk-kl-dj+ek+fl}}{(q;q)_i\\,(q;q)_j\\,(q;q)_k\\,(q;q)_l} .\\]\nThe conjecture asserts that when the coefficient matrix of the quadratic form is positive\u2011definite and the linear terms satisfy a certain balance condition (namely \\(e=\\frac{a+b}{2}\\) and \\(f=\\frac{b+c}{2}\\)), the sum collapses to a simple product of Euler functions:\n\\[\\Phi_{a,b,c,d}(q) \\;=\\; C_{a,b,c,d}\\, q^{\\kappa_{a,b,c,d}}\\,\\frac{J_{m}^{\\,s}}{J_{1}^{\\,t}},\\]\nwhere \\(J_m = (q^m; q^m)_\\infty\\), the exponent \\(\\kappa_{a,b,c,d}\\) and the constants \\(C_{a,b,c,d}, m, s, t\\) are explicit rational functions of \\(a,b,c,d\\). This family contains the four identities proved in the paper as the special cases\n\\((a,b,c,d) = (1,0,0,2), (0,2,2,2), (1,0,0,1), (2,2,2,2)\\).\n\n**Conjecture (Precise Form).** Let \\(A=\\begin{pmatrix}1 & -\\frac12 & 0 & -\\frac12\\\\ -\\frac12 & 1 & -\\frac12 & -\\frac12\\\\ 0 & -\\frac12 & 1 & -\\frac12\\\\ -\\frac12 & -\\frac12 & -\\frac12 & 1\\end{pmatrix}\\). For any integer vector \\(\\mathbf{u}=(u_1,u_2,u_3,u_4)\\) with \\(u_i\\ge 0\\) define\n\\[\\Phi_{\\mathbf{u}}(q) = \\sum_{i,j,k,l\\ge 0} \\frac{q^{\\frac12\\,(i,j,k,l)A(i,j,k,l)^T + \\mathbf{u}\\cdot(i,j,k,l)}}{(q;q)_i (q;q)_j (q;q)_k (q;q)_l}.\\]\nThen\n\\[\\Phi_{\\mathbf{u}}(q) = 2^{\\alpha(\\mathbf{u})}\\, q^{\\beta(\\mathbf{u})}\\, \\frac{J_{2}^{\\, \\gamma(\\mathbf{u})}}{J_{1}^{\\, \\delta(\\mathbf{u})}},\\]\nwhere the integer\u2011valued functions \\(\\alpha,\\beta,\\gamma,\\delta\\) are given by\n\\[\\alpha(\\mathbf{u}) = u_1+u_2+u_3+u_4 - 2,\\quad \\beta(\\mathbf{u}) = -\\frac{\\lVert\\mathbf{u}\\rVert_1}{2},\\]\n\\[\\gamma(\\mathbf{u}) = 6 - \\frac{\\lVert\\mathbf{u}\\rVert_1}{2},\\quad \\delta(\\mathbf{u}) = 6 - \\frac{\\lVert\\mathbf{u}\\rVert_1}{2}.\\]\nIn particular, for \\(\\mathbf{u} = (0,0,0,0)\\) we recover the first identity of Theorem\u202f1, and for \\(\\mathbf{u} = (2,2,2,2)\\) we recover Theorem\u202f2.\n\n**Why this is falsifiable.** The statement gives an explicit closed\u2011form product for each \\(\\Phi_{\\mathbf{u}}\\). One can compute coefficients of the series expansion of both sides for any concrete \\(\\mathbf{u}\\) (e.g., using SageMath or Mathematica) and check equality up to a high order in \\(q\\). A single counter\u2011example disproves the conjecture.\n\n**Domain**: Number Theory (q\u2011series, modular forms) and Combinatorics.\n\n**Catalog references**: [Cao\u2011Wang 2025, Conjecture\u202f3.2], [Cao\u2011Wang 2025, Conjecture\u202f3.4], [Andrews\u2011Berndt 2005, q\u2011series identities].\n\n**Domain bridges**: Connects the theory of Nahm sums (modular q\u2011hypergeometric series) with the classical theory of theta functions and Euler products.\n\n**Ambition level**: \"extension\" \u2013 it extends the proven four identities to an infinite family.\n\n**Proof strategy**: Use the Bailey\u2011pair / Bailey\u2011chain machinery to transform the multi\u2011sum into a product. The quadratic form matrix \\(A\\) is unimodular, enabling a change of variables that separates the sum",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2492",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25866v1",
    "status": "available",
    "timestamp": "2026-06-25T04:33:11.850404+00:00",
    "title": "Generalized Rank\u2011Four Nahm Sum Identity with Quadratic Form Parameter"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Formalize the theorem stating that for any graph G that is a quadrangulation of the projective plane, the circular chromatic number \u03c7_c(G) cannot lie in the open interval (2, 4). Specifically, if \u03c7_c(G) > 2, then \u03c7_c(G) \u2265 4.",
    "domains": [
      "Geometry"
    ],
    "id": "fd_2493",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25644v1",
    "status": "available",
    "timestamp": "2026-06-25T04:58:44.105271+00:00",
    "title": "Gap Phenomenon for Circular Chromatic Numbers of Projective Plane Quadrangulations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any fixed alphabet size b\u22652, the largest family C\u2286[b]^k in which every pair of distinct vectors yields a bipartite graph containing a cycle has size at most N_b(k), the number of good vectors defined by prescribed block sizes, and that this bound is attained for all sufficiently large k (in particular when k\u2261-1 (mod b)).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2494",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25055v1",
    "status": "available",
    "timestamp": "2026-06-25T05:24:56.704027+00:00",
    "title": "Maximum size of cycle-containing families of vectors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For fixed integers r\u22652, t\u22652 there exists a constant C(r,t)>0 such that every r\u2011edge\u2011colouring of any (C,\u202fd)-pseudorandom t\u2011uniform hypergraph H on n vertices contains a monochromatic matching of size at least (1/(r+t\u20111)\u2212o(1))\u00b7n. Moreover, this bound is asymptotically best possible: for every \u03b5>0 and all sufficiently large n there is an r\u2011colouring of a (C,\u202fd)-pseudorandom t\u2011graph with no monochromatic matching larger than (1/(r+t\u20111)+\u03b5)\u00b7n. The conjecture claims that the classical AFL bound extends from the complete hypergraph K_n^{(t)} to any sufficiently pseudorandom host, without any additional loss beyond the o(1) term.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2495",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24863v1",
    "status": "available",
    "timestamp": "2026-06-25T05:42:47.292631+00:00",
    "title": "Asymptotic Tightness of the Alon\u2013Frankl\u2013Lov\u00e1sz Matching Bound for Random\u2011Like Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer $m\\ge 3$ (so $n=4m+3\\ge 15$), the alternating group $A_{n}$ admits self\u2011dual string C\u2011group representations of rank $2m$ (as constructed by the vertex\u2011gluing method), but none of rank $2m+1$. In other words, the highest possible rank of a self\u2011dual string C\u2011group is one less than the known overall maximum rank $\\lfloor\\frac{n-1}{2}\\rfloor$ for $A_n$.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2497",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24654v1",
    "status": "available",
    "timestamp": "2026-06-25T06:41:04.137986+00:00",
    "title": "Maximum rank of self\u2011dual string C\u2011groups for alternating groups $A_{4m+3}$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every positive integer n, there exists a family of n+1 subsets of Fin n whose pairwise symmetric-difference distances are all (n+1)/2 if and only if n = 1 or n \u2261 3 mod 4. Equivalently, the exceptional case lambda = (n+1)/2 in Hegedus's bound is attained exactly in the Hadamard orders.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2498",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24624v1",
    "status": "available",
    "timestamp": "2026-06-25T07:06:11.878161+00:00",
    "title": "Hadamard-tightness conjecture for the exceptional binary Hegedus bound"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every \u03b5 > 0, there exists a constant c = c(\u03b5) > 0 such that for arbitrarily large finite sets A \u2282 \u211d we have max{|AA|, |(A+1)(A+1)|} \u2264 |A|^{1+\u03b5}. This would improve the exponent 2\u2212c from the known result to arbitrarily close to 1.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2499",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24583v1",
    "status": "available",
    "timestamp": "2026-06-25T07:43:42.166855+00:00",
    "title": "Strong simultaneous small product and shifted product conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let K be an algebraically closed field of characteristic p > 0, let m > 0, and let s_p(m) be the sum of the base-p digits of m. If nonzero linear forms ell_1,...,ell_t have m-th powers ell_1^m,...,ell_t^m forming a linear circuit in Sym^m(V^*), then s_p(m) * dim_K Span{ell_1,...,ell_t} <= t + s_p(m) - 2. This conjecture says that in positive characteristic the sharp characteristic-zero constant m should be replaced by the Frobenius-effective weight s_p(m). It is falsifiable by exhibiting a circuit violating the displayed inequality.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2500",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24349v1",
    "status": "available",
    "timestamp": "2026-06-25T08:13:31.785376+00:00",
    "title": "Positive-characteristic Veronese circuit bound with p-adic digit weight"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let qc(n) be the largest k < n such that every placement of k mutually non-attacking queens on an n \u00d7 n board can be completed to a full n-queens configuration. Conjecture: there is an absolute integer N such that for every n \u2265 N, qc(n) \u2264 floor(n/5), equivalently 5 * qc(n) \u2264 n. This sharpens the paper's asymptotic upper bound qc(n) \u2264 0.216n to the rational density 0.2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2501",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24400v1",
    "status": "available",
    "timestamp": "2026-06-25T09:17:44.772184+00:00",
    "title": "Asymptotic one-fifth upper bound for the n-queens completion threshold"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For n \u2265 2 define X_n(v) = \u2211_{k=0}^{\u230an/2\u230b} (-1)^k n! / ((n - 2k)! k!) v^k and its reciprocal polynomial Y_n(q) = q^{\u230an/2\u230b} X_n(1/q). Conjecture: every root of Y_n is real, positive, and simple, and if \u03bb_n is the largest real root of Y_n, then \u03bb_n < \u03bb_{n+1} for all n \u2265 2. Equivalently, for the orchard denominator D_l(v)=\u220f_{j=2}^l X_j(v), the exponential growth constant determined by the smallest positive zero of D_l is always \u03bb_l, the largest reciprocal root of the final factor X_l.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2502",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24325v1",
    "status": "available",
    "timestamp": "2026-06-25T09:35:11.820921+00:00",
    "title": "Dominant Orchard Denominator Root Comes from the Last Complete-Graph Matching Factor"
  },
  {
    "consumed_by_exp_id": "",
    "description": "In the h=1 specialization of additive strong blocking sets, i.e. ordinary strong blocking sets in PG(2,2), a finite set S of projective points is strong blocking if and only if it contains at least 6 of the 7 points. Equivalently, the shortest nondegenerate minimal binary linear code of dimension 3 has length 6 under the projective-system correspondence.",
    "domains": [
      "Geometry",
      "Bridges"
    ],
    "id": "fd_2503",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24262v1",
    "status": "available",
    "timestamp": "2026-06-25T10:08:51.465617+00:00",
    "title": "Fano-plane threshold for additive strong blocking sets in the h=1 case"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We propose a conjecture characterizing the conditions under which the Lin-Lu-Yau Ricci curvature of an edge in a connected locally finite graph is non-negative. The conjecture posits that if the size of the symmetric difference of the neighborhoods of two adjacent vertices exceeds their common neighborhood size plus their degrees, the curvature vanishes or is non-negative. This bridges the gap between combinatorial graph metrics and curvature theory, enabling exact computation via graph structure analysis.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2504",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24261v1",
    "status": "available",
    "timestamp": "2026-06-25T10:51:48.704692+00:00",
    "title": "Non-negative Lin-Lu-Yau Ricci Curvature on Graphs with Common Neighborhoods"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for all integers k \u2265 3 and n \u2265 1, the minimal N = g_k(n) satisfies g_k(n) \u2265 \u2308((k-1)/(k-2))^n\u2309.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2505",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24139v1",
    "status": "available",
    "timestamp": "2026-06-25T11:11:19.428461+00:00",
    "title": "Exponential Lower Bound for g_k(n) Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every odd prime \ud835\udc5d the class of biased graphs that admit a \ud835\udc4d\u209a\u2011gain labelling is minor\u2011closed and its only excluded minors are the balanced\u2011cycle\u2013free graph (\ud835\udc5d+1)K\u2082, the balanced triangle \u00b1K\u2083 and the unbalanced 4\u2011cycle \u2013K\u2084. In other words, a biased graph \ud835\udd3e is \ud835\udc4d\u209a\u2011gainable iff it contains none of these three minors.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2506",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23826v1",
    "status": "available",
    "timestamp": "2026-06-25T11:31:35.982720+00:00",
    "title": "Excluded minors for bias graphs gainable over cyclic groups \ud835\udc4d\u209a"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The upper bound S_1^\u03c6(x) \u226a x exp{-(1/2 - o(1))\u221a(log x log_2 x)} is tight, i.e., there exists a constant C > 0 such that S_1^\u03c6(x) \u2265 C x exp{-(1/2 + o(1))\u221a(log x log_2 x)} for all sufficiently large x.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2507",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23681v1",
    "status": "available",
    "timestamp": "2026-06-25T12:13:32.061938+00:00",
    "title": "Tightness of the unit-shift bound for Euler's totient function"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that the set of positive integers that are divisible by the number of summands in their Zeckendorf decomposition has asymptotic density\u00a00.  Equivalently, for any real \u03b5>0 there are only finitely many Zeckendorf\u2011Niven numbers\u00a0n< N with n/N > \u03b5, and the ratio of the counting function to N tends to\u00a00 as N\u2192\u221e.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2508",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24006v1",
    "status": "available",
    "timestamp": "2026-06-25T12:39:28.725008+00:00",
    "title": "Zero Asymptotic Density of Zeckendorf\u2011Niven Numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any tree T on n vertices and any complete tripartite graph K_{m_1,m_2,m_3} with 1 \u2264 m_1 \u2264 m_2 \u2264 m_3, the Ramsey number R(T, K_{m_1,m_2,m_3}) equals 2(R(T, K_{m_1,m_2}) - 1) + m_1 for all sufficiently large n. This conjecture specifically tests whether the general bound in the paper becomes an exact equality for the k=3 case.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2509",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23659v1",
    "status": "available",
    "timestamp": "2026-06-25T12:57:20.450102+00:00",
    "title": "Exact Ramsey Numbers for Trees vs Tripartite Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every nonnegative integer n, there exist natural numbers x, y, z such that n = x*(x+1)/2 + y*(3*y+1)/2 + z*(7*z+1)/2. This is the direct nonagonal analogue of the paper's triangular-pentagonal-heptagonal theorem, replacing z*(5*z+1)/2 by z*(7*z+1)/2.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2510",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.26035v1",
    "status": "available",
    "timestamp": "2026-06-25T04:16:08.696484+00:00",
    "title": "Triangular + second pentagonal + second nonagonal universality"
  },
  {
    "consumed_by_exp_id": "",
    "description": "If a quadratic polynomial $f = x^2 + c$ over $\\mathbb{Q}(i)$ has an irreducible second iterate $f^2$ in $\\mathbb{Q}(i)[x]$, then all subsequent iterates $f^n$ remain irreducible over $\\mathbb{Q}(i)[x]$ for every $n \\geq 1$.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2511",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25250v1",
    "status": "available",
    "timestamp": "2026-06-25T04:59:16.364433+00:00",
    "title": "Irreducibility of Iterates for Quadratic Polynomials over $\\mathbb{Q}(i)$"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every integer r \u2265 20, the Erd\u0151s\u2013Lov\u00e1sz cover number function satisfies g(r) \u2265 \u230a61r/20\u230b \u2212 4. This strengthens the asymptotic bound g(r) \u2265 (61/20 \u2212 o(1))r by providing an explicit additive constant, making the statement falsifiable for each specific r.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2512",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24878v1",
    "status": "available",
    "timestamp": "2026-06-25T05:25:15.555654+00:00",
    "title": "Conjectured additive refinement of the 61/20 lower bound for g(r)"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For integers d \u2265 4 and s satisfying \u2308(d+2)/2\u2309 \u2264 s \u2264 d\u22121, let n be sufficiently large (e.g., n \u2265 2(d+1)). If \ud835\udd3d \u2286 ( [n] choose (d+1) ) is a (d+1)-uniform family such that every F \u2208 \ud835\udd3d has a missing trace of size exactly s (i.e., there exists B \u2282 F with |B| = s and for all F' \u2208 \ud835\udd3d, F \u2229 F' \u2260 B), then |\ud835\udd3d| \u2264 binom(n\u22121, d) + binom(n\u22122(d+1\u2212s)\u22122, 2s\u2212d\u22122), and this bound is tight.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2513",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24776v1",
    "status": "available",
    "timestamp": "2026-06-25T05:43:09.628138+00:00",
    "title": "Optimality of the constructed family for the uniform witness conjecture in the upper range"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integers a\u22651, m\u22651 and a tuple of block sizes \\(b_1,\\dots,b_m\\) with each \\(b_r\\ge 1\\), let \\(G = \\MM(a;\\mathbf{b}) = \\overline{K}_a * \\bigsqcup_{r=1}^m K_{b_r}\\) be the generalized multiple complete split\u2011like graph. Define \\(\\nu = \\#\\{r \\mid b_r \\ge 2\\}\\), the number of non\u2011trivial clique blocks. The conjecture asserts that the Castelnuovo\u2013Mumford regularity of the edge ideal of \\(G\\) satisfies \\[ \\reg(G) = \\nu + 1. \\] This gives a simple closed\u2011form regularity formula for the entire family and refines the \"sharp criterion for 2\u2011linear resolution\" proved in the paper, which corresponds to the case \\(\\nu=0\\). The statement is precise, falsifiable, and can be formalised in Lean\u202f4 using the existing libraries for simplicial complexes, edge ideals, and regularity.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2514",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24822v1",
    "status": "available",
    "timestamp": "2026-06-25T06:00:04.455853+00:00",
    "title": "Regularity of generalized multiple complete split-like graphs equals the number of non\u2011trivial clique blocks plus one"
  },
  {
    "consumed_by_exp_id": "",
    "description": "All binary Type I self-dual codes of length 26 with minimum distance 6 are equivalent under permutation of coordinates.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2515",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24573v1",
    "status": "available",
    "timestamp": "2026-06-25T06:42:49.211274+00:00",
    "title": "Uniqueness of the Binary Self-Dual [26,13,6] Code up to Equivalence"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The dimension of the nilpotent Lie algebra constructed from a finite acyclic quiver with n edges equals n.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2516",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24569v1",
    "status": "available",
    "timestamp": "2026-06-25T07:06:55.988854+00:00",
    "title": "Dimension Equality Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any prime power q and integers n \u2265 k \u2265 1, s \u2265 1 with n \u2265 (s+1)k, let m_q(n,k,s) be the maximum size of a family of k-dimensional subspaces of \ud835\udd3d_q^n containing no s+1 members with a direct sum. The conjecture states that m_q(n,k,s) equals the maximum of two explicit constructions: all k-subspaces contained in a fixed ((s+1)k-1)-dimensional subspace, or all k-subspaces intersecting a fixed s-dimensional subspace nontrivially. This is the q-analogue of the Erd\u0151s Matching Conjecture (proven for k=2, n=(s+1)k, and large n, but open in general).",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2518",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24529v1",
    "status": "available",
    "timestamp": "2026-06-25T08:18:46.345580+00:00",
    "title": "Vector-Space Erd\u0151s Matching Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer k \u2265 9, the diagonal k-uniform Ramsey number r_k(k+1,k+1) is strictly larger than the 3-color shift number at parameter floor(2k/3)-3; equivalently, r_k(k+1,k+1) > s_3(\u230a2k/3\u230b-3). This strengthens the paper's bound r_k(k+1,k+1) > s_3(\u230ak/2\u230b-2) by replacing the coefficient 1/2 with 2/3, while retaining an absolute additive loss.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2519",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24198v1",
    "status": "available",
    "timestamp": "2026-06-25T09:18:32.163392+00:00",
    "title": "Two-thirds shift-number lower bound for diagonal hypergraph Ramsey numbers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let R,S,k,c be positive integers with 1 \u2264 S and 2S \u2264 R. Define A_{R,S}(q) = 1 / ((q^S;q^R)_\u221e (q^{R-S};q^R)_\u221e (q^R;q^R)_\u221e) and T_{R,S,k}(q) = \u2211_{j=-k+1}^{k} (-1)^j q^{R*j*(j-1)/2 + S*j}. Conjecture: for every n \u2265 1, the coefficient of q^n in (-1)^(k-1) * (T_{R,S,k}(q) * A_{R,S}(q)^c - A_{R,S}(q)^(c-1)) is a nonnegative integer. Equivalently, the known Wang--Yee positivity for c=1 persists after convolution with the generating function for (c-1)-colored partitions into parts congruent to 0, S, or R-S modulo R.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2520",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24243v1",
    "status": "available",
    "timestamp": "2026-06-25T10:10:36.166476+00:00",
    "title": "Colored positivity for the bilateral truncated Jacobi triple product after removing the constant term"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any integration problem satisfying the assumptions of Theorem\u202f1 (tensor\u2011product structure, existence of a one\u2011dimensional worst\u2011case function h and associated spline functions s_y with A,B>1), the information complexity N_{it}^+(\u03b5,d) grows at least exponentially with the dimension d. Formally, there exists a constant C>1 (depending only on A and B) such that for every d\u2208\u2115 and every \u03b5\u2208(0,1/2] we have N_{it}^+(\u03b5,d) \u2265 C^d. The conjecture is falsifiable: a single counterexample (d,\u03b5) violating the inequality would refute it.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_2521",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24195v1",
    "status": "available",
    "timestamp": "2026-06-25T10:52:18.858858+00:00",
    "title": "Exponential lower bound for non\u2011negative QMC integration in high dimensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any field F of characteristic zero, the natural map from the weight\u20113 component PolyL\u2083(F) of the Goncharov Lie coalgebra to the indecomposable quotient of the third\u2011filtered algebraic K\u2011theory group K\u2085^{(3)}(F)\u2297\u211a is an isomorphism of \u211a\u2011vector spaces, intertwining the Lie cobracket with the boundary map in Goncharov\u2019s polylogarithmic complex of weight\u00a03.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2522",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23863v1",
    "status": "available",
    "timestamp": "2026-06-25T11:11:42.242502+00:00",
    "title": "Isomorphism between the weight\u20113 Goncharov Lie coalgebra and the indecomposable part of K\u2085^{(3)}(F)\u2297\u211a"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For any finite simple bipartite graph G with partite sets A and B, let \u0394_A = max_{a\u2208A} deg_G(a) and \u0394_B = max_{b\u2208B} deg_G(b). If \u0394_A\u00b7\u0394_B \u2265 1000 then the strong chromatic index satisfies \u03c7'_s(G) \u2264 \u230a(5/3)\u00b7\u0394_A\u00b7\u0394_B\u230b. This would improve the current bound of 1.676\u00b7\u0394_A\u00b7\u0394_B for sufficiently large product and is sharp up to constant factor.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2523",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23824v1",
    "status": "available",
    "timestamp": "2026-06-25T11:33:16.478948+00:00",
    "title": "Improved asymptotic bound for the strong chromatic index of bipartite graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let D_n be the average stack-sorting depth over all permutations in S_n under West's stack-sorting map. The conjecture is that the unprimed averages satisfy the same type of finite monotonicity suggested by the paper's primed lower-bound sequence: for every n \u2265 1, D_n/(n+1) \u2264 D_{n+1}/(n+2). This is a concrete finite inequality at each n and can be falsified by exact enumeration of stack-sorting depths.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2524",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.24110v1",
    "status": "available",
    "timestamp": "2026-06-25T12:14:38.692167+00:00",
    "title": "Shift-normalized monotonicity of the average stack-sorting depth"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For each non\u2011negative integer k, define\n\\[\nP_{2k}=\\prod_{n=2}^{\\infty} \\exp\\Bigl(\\frac{1}{n^{2k-1}}\\Bigr)\\Bigl(1-\\frac{1}{n^{2}}\\Bigr)^{n^{2k}}\\,.\n\\]\nThe paper shows that the logarithm of P_{2k} is a finite tail of the Riemann zeta series.  We conjecture an explicit closed\u2011form expression involving only powers of \\(\\pi\\), rational numbers, harmonic numbers \\(H_{2k}\\), and odd zeta values \\(\\zeta(2j+1)\\).  This statement is precise, falsifiable and can be formalised in Lean\u00a04 using the existing libraries for real analysis, the gamma function and the Riemann zeta function.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2525",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.23973v1",
    "status": "available",
    "timestamp": "2026-06-25T12:40:11.650578+00:00",
    "title": "Closed form for even\u2011indexed regularised Wallis products"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every fixed r >= 3 and k >= 3, every linear r-uniform hypergraph H on n vertices with no collection of k edges spanning at most (r - 2)k + 3 vertices has o(n^2) edges. Equivalently: for every rational epsilon > 0 there is N such that for all n >= N, if H is linear and r-uniform on Fin n and every k-edge subfamily spans more than (r - 2)k + 3 vertices, then |E(H)| <= epsilon n^2. This would replace the paper's positive constant-density forcing threshold by the conjectural Brown--Erdos--Sos vanishing threshold in the linear setting.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2526",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25931v1",
    "status": "available",
    "timestamp": "2026-06-25T14:27:44.525294+00:00",
    "title": "Linear Brown--Erdos--Sos o(n^2) conjecture at the paper's span threshold"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The conjecture posits that their approach's proof aligns with the Four Color Theorem's universality for planar graphs.",
    "domains": [
      "Pythagorean",
      "Logic"
    ],
    "id": "fd_2527",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25988v1",
    "status": "available",
    "timestamp": "2026-06-25T14:49:35.971740+00:00",
    "title": "Equivalence of Their Method and Four Color Theorem"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This paper investigates the algebraic structure of the generalized Verschiebung degree under Frobenius pullback in moduli spaces of vector bundles, aiming to confirm its polynomiality through explicit coefficient analysis.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2528",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.26070v1",
    "status": "available",
    "timestamp": "2026-06-25T14:50:42.256570+00:00",
    "title": "Polynomiality of the Generalized Verschiebung Degree"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every planar graph G admits an (open-neighborhood) conflict-free coloring using at most 4 colors. A conflict-free coloring requires that for every vertex v, there exists a neighbor w such that the color of w is unique among all neighbors of v in the open neighborhood N(v). This conjecture formalizes the main result of the paper, which equivalently establishes the Four Color Theorem.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2529",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25988v1",
    "status": "available",
    "timestamp": "2026-06-25T14:54:09.271959+00:00",
    "title": "Every Planar Graph Admits a Conflict-Free 4-Coloring"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture proposes rigorous closure of known $q$-series identities under the lifting-dual transform, aiming to resolve a critical gap in the modular theory of rank-four Nahm sums.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2530",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25866v1",
    "status": "available",
    "timestamp": "2026-06-25T14:54:18.512749+00:00",
    "title": "Analytic Verification of Modular Rank-Four Nearest-Point Identities"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every nonnegative integer n can be expressed as T(x) + P\u2081(y) + H\u2081(z), where T(x) = x(x+1)/2 is the x-th triangular number, P\u2081(y) = y(3y-1)/2 is the y-th first pentagonal number, and H\u2081(z) = z(5z-3)/2 is the z-th first heptagonal number, for nonnegative integers x, y, z.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2531",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.26035v1",
    "status": "available",
    "timestamp": "2026-06-25T16:12:16.241077+00:00",
    "title": "Every Nonnegative Integer Is a Sum of a Triangular, First Pentagonal, and First Heptagonal Number"
  },
  {
    "consumed_by_exp_id": "",
    "description": "All non-trivial zeros of the scattering determinant \u03c6(s) associated to congruence characters of congruence subgroups of SL\u2082(\u2124) lie on the critical line Re(s) = 1/2. This conjecture, if true, would imply that the prime geodesic theorem for congruence subgroups holds with exponent 1/2 + \u03b5, improving upon the proven exponent 25/36 + \u03b5. The conjecture is falsifiable by exhibiting any zero \u03c1 with |Re(\u03c1) - 1/2| > \u03b4 for some explicit \u03b4 > 0.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2532",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25903v1",
    "status": "available",
    "timestamp": "2026-06-25T16:34:10.115341+00:00",
    "title": "Scattering Determinant Critical Line Conjecture"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that if a p-adic Galois representation becomes semistable after passing to some finite extension, then it must already have been of finite E-height. This would provide a characterization of finite height representations in terms of their behavior under finite extensions.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2533",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.26043v1",
    "status": "available",
    "timestamp": "2026-06-25T17:11:00.832064+00:00",
    "title": "A Converse to Finite Height Implying Semistability for p-adic Galois Representations"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Under the Exponential Time Hypothesis, there exists no deterministic algorithm solving Global Label Min-Cut on n-vertex graphs with p labels in time (np)^{o(log n / log log n)}. More precisely, any deterministic reduction from sparse 3-SAT with N variables to balanced Multicolored Clique with k color classes over q vertices, where k = \u0398(sqrt(N/log N)) and log q = \u0398(k log k), yields a GLMC instance with p = kq labels and n = O(k\u00b2q\u00b2 log(q+1)^k) vertices satisfying log n = \u0398(k log k) and consequently (log n)/(log log n) = \u0398(k). This precise parameter relationship is necessary and sufficient for the lower bound to hold.",
    "domains": [
      "Computation"
    ],
    "id": "fd_2534",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25875v1",
    "status": "available",
    "timestamp": "2026-06-25T17:43:31.744715+00:00",
    "title": "ETH-based Reduction from Sparse 3-SAT to Global Label Min-Cut with Optimal Parameter Scaling"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every dimension d and every positive integer n, any point p in the standard d-simplex in Euclidean space R^(d+1) is within Euclidean distance sqrt(d+1)/(2n) of some barycentric grid point with denominator n, i.e. of some vector k/n where k_i are natural numbers summing to n. This is a deterministic finite-dimensional approximate Carath\u00e9odory statement for the vertex set of the regular simplex, strengthening the usual O(1/sqrt(n)) empirical bound to an O(1/n) covering bound in this special geometry.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_2535",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25854v1",
    "status": "available",
    "timestamp": "2026-06-25T18:23:48.699782+00:00",
    "title": "Uniform barycentric grid covering radius of the standard Euclidean simplex"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that every outerplanar graph admits a conflict\u2011free coloring with at most three colors. This extends the known four\u2011color conflict\u2011free bound for planar graphs and would yield a tight bound for the outerplanar subclass.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2536",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25988v1",
    "status": "available",
    "timestamp": "2026-06-25T16:12:58.691211+00:00",
    "title": "Conflict-Free Coloring of Outerplanar Graphs with Three Colors"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for every integer n \u2265 2, any collection of mutually orthogonal Italian squares of order n contains at most n\u20111 squares, and this bound is attained exactly when n is a prime power.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2537",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25884v1",
    "status": "available",
    "timestamp": "2026-06-25T16:34:26.097340+00:00",
    "title": "Maximum size of pairwise orthogonal Italian squares is n\u20111 for prime powers"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let X be a K3 surface over a finite field \ud835\udd3d_q of characteristic \u2260 p. Let k_n = \ud835\udd3d_{q^{p^n}} and let Br(X_{k_n})[p^\u221e] denote the p\u2011primary part of the Brauer group. Write \u0393 = Gal(k_\u221e/k) \u2245 \u2124_p and \u039b = \u2124_p[[\u0393]]. Let M = varprojlim_n Br(X_{k_n})[p^\u221e]^\u2228 be the Pontryagin dual, a compact \u039b\u2011module. Conjecture: M is a finitely generated torsion \u039b\u2011module and its characteristic power series f_M(T) \u2208 \u039b equals, up to a unit in \u039b, the p\u2011adic L\u2011function L_p(T, X) defined from the Frobenius eigenvalues on H^2_et(X_{\u0305\ud835\udd3d_q}, \u211a_p(1)).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2538",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25737v1",
    "status": "available",
    "timestamp": "2026-06-25T17:44:05.410825+00:00",
    "title": "Iwasawa Main Conjecture for Brauer groups of K3 surfaces over finite fields"
  },
  {
    "consumed_by_exp_id": "9e1a2820",
    "description": "For integers b >= 2 and m >= 2, let T_{b,m}(n) be the coefficient of x^n in the formal power series product \\prod_{i=0}^{\\infty} (1 - x^{b^i})^m. Equivalently, T_{b,m}(n) is the coefficient of x^n in the finite polynomial product \\prod_{i=0}^{n} (1 - x^{b^i})^m. The conjecture is that the integer sequence n \\mapsto T_{b,m}(n) is unbounded in absolute value: for every B, there exists n such that |T_{b,m}(n)| > B. The paper proves the case b = 2; this conjecture asserts the same phenomenon for every base b >= 2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2539",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25825v1",
    "status": "in_progress",
    "timestamp": "2026-06-25T18:24:34.645043+00:00",
    "title": "Generalized Gawron\u2013Miska\u2013Ulas unboundedness for arbitrary integer bases"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture: For every even integer n \u2265 4, there exists a maximal standard social decision frame whose incoherence index (the length of the shortest perfectly balanced sequence of majority or tie sets) equals n. This would strengthen the known result that incoherence indices are unbounded by showing that every sufficiently large even number is actually attained.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2540",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25954v1",
    "status": "available",
    "timestamp": "2026-06-25T18:50:55.115611+00:00",
    "title": "Realization of all even incoherence indices \u22654 by maximal standard frames"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture a Rogers-Ramanujan type identity for a sum over four variables with denominators involving (q^4; q^4)_n, expressed as a product involving J_4^3 and J_1^3. This extends the pattern observed in Theorem~2 of the referenced paper to a higher modulus.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2541",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25866v1",
    "status": "available",
    "timestamp": "2026-06-25T19:16:31.304723+00:00",
    "title": "Conjecture on Modular Rank Four Nahm Sums with Modulus 4"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the polynomial R_g(t) defined in the main theorem, when expressed as R_g(t) = \u03a3_{j=0}^{g-1} a_j\u00b7t^j, each coefficient a_j \u2208 \u211a has a specific closed-form expression involving generalized Catalan numbers and Bernoulli numbers. Specifically, a_j = ((-1)^j \u00b7 B_{2j} \u00b7 C_{g,j})/(2j)! \u00b7 2^{4j-g} where C_{g,j} is the j-th generalized Catalan coefficient arising from the Laurent expansion of csc^(2g-2)(z), and this formula yields R_g(t) with rational coefficients that satisfy the integrality condition: 2^g \u00b7 R_g(p^2) \u2208 \u2124 for all primes p.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2542",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.26070v1",
    "status": "available",
    "timestamp": "2026-06-25T19:42:44.972578+00:00",
    "title": "Explicit Rational Coefficients of Generalized Verschiebung Degree Polynomial"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that for any K3 surface X over a number field K, the p-primary part of the Brauer group Sel_B(X/K_\u221e) is a finitely generated torsion \u039b-module over the Iwasawa algebra \u039b = \u2124_p[[\u0393]] where \u0393 \u2245 \u2124_p.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2543",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25737v1",
    "status": "available",
    "timestamp": "2026-06-25T20:04:24.610098+00:00",
    "title": "Finitely generated torsion conjecture for the p-primary Brauer group of K3 surfaces in \u2124_p-cyclotomic extensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any integer m \u22652, the coefficients t_m(2^k) of the generalized Prouhet-Thue-Morse function F_m(x) grow exponentially in k. Specifically, there exist constants C >0 and r >1 such that for all sufficiently large k, |t_m(2^k)| \u2265 C*r^k.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2544",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25825v1",
    "status": "available",
    "timestamp": "2026-06-25T20:32:46.778777+00:00",
    "title": "Exponential Growth of Coefficients at Powers of Two for Generalized Prouhet-Thue-Morse Series"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For the family of radical number fields K_n(p) = Q(\u03b6_{p-1}, \\sqrt[p]{p}) where p is an odd prime and n = p-1, the minimal index satisfies Ind_min(K_n(p)) > log(log(discriminant(K_n(p))))^{1/3} for all sufficiently large p. This provides an explicit quantitative version of the main theorem about arbitrarily large minimal indices.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2545",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25841v1",
    "status": "available",
    "timestamp": "2026-06-25T21:08:07.808226+00:00",
    "title": "Explicit lower bound for minimal index in radical extensions"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For any two words u and v over an alphabet \u03b1 and any repetition-free word z over a disjoint alphabet \u03b2, append z as a common suffix using the tagged alphabet \u03b1 \u2295 \u03b2. Then every common t-deletion descendant of map inl u ++ map inr z and map inl v ++ map inr z has a unique split into a common i-deletion descendant of u and v and a (t-i)-deletion descendant of z. Consequently the intersection size is exactly the binomial convolution \u2211_{i=0}^t |D_i(u) \u2229 D_i(v)| * choose(|z|, t-i). This would formalize the seed-lifting mechanism behind the paper's asymptotic attainability claims and gives an exact finite-N polynomial identity over a separated extension alphabet.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2546",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25822v1",
    "status": "available",
    "timestamp": "2026-06-25T21:28:06.900797+00:00",
    "title": "Exact separator-suffix convolution for deletion-ball intersections"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integers r \u2265 3 and k \u2265 3 there exist arbitrarily large linear r\u2011uniform hypergraphs on n vertices with edge count just below the bound given in Theorem\u00a01 that contain no ((r\u20112)k+3,\u202fk)\u2011configuration. In other words, the density threshold in Theorem\u00a01 is sharp up to lower\u2011order terms.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2547",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25931v1",
    "status": "available",
    "timestamp": "2026-06-25T18:51:30.410771+00:00",
    "title": "Optimality of the Density Threshold for Linear r\u2011Uniform Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that there exists a deterministic algorithm solving the Global Label Min-Cut (GLMC) problem on any undirected graph with n vertices and p labels in time O((np)^{C\u00b7log n / log log n}) for some absolute constant C.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "id": "fd_2548",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25875v1",
    "status": "available",
    "timestamp": "2026-06-25T19:43:32.279494+00:00",
    "title": "Polynomial-Logarithmic Time Algorithm for Global Label Min-Cut"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that each Delaunay refinement with minicenter Steiner points reduces the maximum simplex diameter by a constant factor \u03bb > 1, leading to exponential contraction after k iterations: max{\u03c3 \u2208 Del(X_k)}.diameter \u2264 (1/\u03bb)^k \u00b7 max{\u03c3 \u2208 Del(X_0)}.diameter",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2549",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25854v1",
    "status": "available",
    "timestamp": "2026-06-25T20:05:25.226962+00:00",
    "title": "Exponentialdiameter contraction under Delaunay minicenter refinement"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every \u03b5 > 0, there exists a constant c_\u03b5 > 0 such that the number of ordered pairs S(x) = #{(a,b) \u2208 \u2115\u00b2 : a + b \u2264 x, \u03c3(a) + \u03c3(b) = \u03c3(a+b)} satisfies S(x) > c_\u03b5 x (log x)^(2+\u03b5) for all sufficiently large x. This is a specific instance of the main theorem where the growth rate exceeds x (log x)^2.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2550",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25849v1",
    "status": "available",
    "timestamp": "2026-06-25T20:34:08.184471+00:00",
    "title": "Specific Growth Rate Conjecture for Erd\u0151s Problem 1061"
  },
  {
    "consumed_by_exp_id": "",
    "description": "We conjecture that for any prime p>11, the superspecial K3 surface X over an algebraically closed field of characteristic p does not admit any non\u2011trivial extension of a maximal symplectic group. Precisely, if G\u2264\u202fAut(X) is a finite group whose symplectic subgroup G_s is maximal (as classified by Ohashi\u2011Sch\u00fctt) then G\u2001=\u202fG_s, i.e. the non\u2011symplectic index [G:G_s] equals 1.",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2551",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25724v1",
    "status": "available",
    "timestamp": "2026-06-25T21:08:28.285445+00:00",
    "title": "No non\u2011trivial extensions of maximal symplectic groups on the superspecial K3 surface"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every integer k >= 2 and n >= 0, let A_k(n) be the sum over all ordinary partitions \u03bb of n of binom(mex(\u03bb) + k - 2, k - 1), where mex(\u03bb) is the smallest positive integer not appearing as a part of \u03bb. The conjecture is that A_k(n) equals the finite triangular convolution sum over j >= 0 with T_j = j(j+1)/2 <= n of binom(j + k - 2, k - 2) p(n - T_j), where p is the ordinary partition function. For k = 2 this specializes to the classical \u03c3mex triangular-sum form underlying the Andrews-Newman identity \u03c3mex(n) = D_2(n).",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "id": "fd_2552",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25698v1",
    "status": "available",
    "timestamp": "2026-06-25T21:29:48.403642+00:00",
    "title": "Mex-binomial weights equal a triangular partition convolution"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every natural number k there exists a maximal standard social decision frame whose shortest coherence violation has length exactly 2k+2, showing that the incoherence index of such frames is not bounded by any uniform finite constant.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2553",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25954v1",
    "status": "available",
    "timestamp": "2026-06-25T21:39:44.798884+00:00",
    "title": "Unbounded Incoherence Index in Maximal Standard Social Decision Frames"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For all integers r \u2265 3, k \u2265 3, and n \u2265 (r-2)(k-2)+1, there exists a linear r-uniform hypergraph H on n vertices with |E(H)| = [(k-2)/(r\u00b2((r-2)(k-2)+1))n\u00b2 + n/r] - 1, which does not contain k edges spanning at most (r-2)k+3 vertices. This conjectures that the bound in the main theorem is tight.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2554",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25931v1",
    "status": "available",
    "timestamp": "2026-06-25T21:40:29.052604+00:00",
    "title": "Tightness of the density threshold in the main theorem for linear hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "It is impossible to replace the coherence criterion for strict majority representability by any bounded finite fragment in finite social decision frames. For every k \u2265 1, there exists a maximal standard frame whose shortest coherence violation has length 2k+2, proving no uniform finite bound exists on incoherence indices.",
    "domains": [
      "Logic"
    ],
    "id": "fd_2555",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25954v1",
    "status": "available",
    "timestamp": "2026-06-25T22:09:21.864984+00:00",
    "title": "Non-Finite-Axiomatization of Measurable Majorities via the Incoherence Index"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every nonnegative integer n, there exist natural numbers x, y, z such that n = T(x) + P(y) + H(z) and max(x, y, z) \u2264 \u230a\u221a(2n)\u230b, where T(x)=x(x+1)/2, P(y)=y(3y+1)/2, H(z)=z(5z+1)/2.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2556",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.26035v1",
    "status": "available",
    "timestamp": "2026-06-25T22:46:06.301140+00:00",
    "title": "Bounded variables representation for triangular-pentagonal-heptagonal sums"
  },
  {
    "consumed_by_exp_id": "",
    "description": "The paper proves that any linear 3-uniform hypergraph on n vertices with linear density at least 4/9 + o(1) contains a (7,4)-configuration (i.e., 4 edges spanning at most 7 vertices). It is conjectured that this bound is asymptotically tight: for every \u03b5 > 0, there exist arbitrarily large linear 3-uniform hypergraphs with linear density at least 4/9 - \u03b5 that avoid (7,4)-configurations. This would mean the constant 4/9 cannot be improved in general.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2557",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25931v1",
    "status": "available",
    "timestamp": "2026-06-25T22:19:20.957986+00:00",
    "title": "Asymptotic Tightness of the 4/9 Density Threshold for (7,4)-Configurations in Linear Triple Systems"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every planar graph admits a conflict-free coloring with four colors. This is equivalent to the Four Color Theorem and provides an upper bound on the conflict-free chromatic number for planar graphs.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2558",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25988v1",
    "status": "available",
    "timestamp": "2026-06-25T22:46:48.794965+00:00",
    "title": "Conflict-Free Chromatic Number of Planar Graphs is Bounded by Four"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every k\u22651, we construct a maximal standard frame where the shortest coherence violation sequence has precisely length 2k+2. This disproves the existence of a universal finite bound on coherence violations across all standard frames, resolving Moss and Pedersen's Conjecture 5.7 via a geometric construction in rational vector spaces.",
    "domains": [
      "Pythagorean",
      "Geometry"
    ],
    "id": "fd_2560",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25954v1",
    "status": "available",
    "timestamp": "2026-06-26T00:40:37.274427+00:00",
    "title": "The incoherence index of social decision frames cannot be bounded uniformly across all frame sizes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Let Q(u, v, w) = 15u^2 + 5v^2 + 3w^2. For any integer m such that m \u2261 23 (mod 120), there exist integers u, v, w such that Q(u, v, w) = m, where u is odd, v \u2261 1 (mod 6), and w \u2261 1 (mod 10).",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2561",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.26035v1",
    "status": "available",
    "timestamp": "2026-06-26T01:04:31.620908+00:00",
    "title": "Universality of Ternary Quadratic Forms for Specific Congruence Classes"
  },
  {
    "consumed_by_exp_id": "",
    "description": "This conjecture formalizes the result from the paper, asserting that for any congruence subgroup \u0393 of SL\u2082(\u2124) and any non-trivial congruence character \u03c7, the error term in the prime geodesic theorem satisfies |\u03c0_\u0393(X; \u03c7) - MainTerm| \u2264 C X^{25/36 + \u03b5} for any \u03b5 > 0, where C is a constant depending on \u0393, \u03c7, and \u03b5. Here, \u03c0_\u0393(X; \u03c7) counts primitive conjugacy classes in \u0393 with trace > 2 and norm \u2264 X, weighted by \u03c7, and MainTerm represents the expected asymptotic contribution from the principal part of the explicit formula.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2562",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25903v1",
    "status": "available",
    "timestamp": "2026-06-26T01:36:38.243256+00:00",
    "title": "Exponent bound in the Chebotarev geodesic theorem for SL\u2082(\u2124) congruence subgroups"
  },
  {
    "consumed_by_exp_id": "",
    "description": "For every r \u2265 3, k \u2265 3, and n \u2265 (r-2)(k-2)+1, there exists a linear r-uniform hypergraph H on n vertices with edge count |E(H)| = ((k-2)/(r\u00b2((r-2)(k-2)+1)))n\u00b2 + n/r - 1 that does not contain a k-edge configuration spanning at most (r-2)k+3 vertices. This would establish the tightness of the threshold in Theorem 1 of the paper.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2563",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25931v1",
    "status": "available",
    "timestamp": "2026-06-26T00:41:26.824635+00:00",
    "title": "Tightness of the Density Threshold for Configurations in Linear Hypergraphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Every planar graph admits a conflict-free coloring with exactly 4 colors, and this statement is equivalent to the Four Color Theorem over ZFC set theory. More precisely, for any planar graph G, there exists a vertex coloring f: V(G) \u2192 {1,2,3,4} such that every vertex v has a neighbor w where color f(w) appears exactly once in the open neighborhood N(v), and the existence of such a 4-coloring for all planar graphs is interderivable with the Four Color Theorem.",
    "domains": [
      "Algebra"
    ],
    "id": "fd_2564",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25988v1",
    "status": "available",
    "timestamp": "2026-06-26T01:10:10.263546+00:00",
    "title": "Equivalence Between Four Color Theorem and Conflict-Free Chromatic Number of Planar Graphs"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Conjecture that a rank four Nahm sum of the form \u03a3 q^Q(i,j,k,l)/((q;q)_i(q;q)_j(q;q)_k(q;q)_l) where Q is a quadratic form in four variables is modular (expressible as an infinite product of q-Pochhammer symbols) if and only if the discriminant of Q's Hessian matrix equals 8, 12, or 16. This would generalize the proven cases in the paper where discriminants compute to these values.",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2565",
    "priority_score": 0.8,
    "research_mode": "team",
    "source_exp_id": "2606.25866v1",
    "status": "available",
    "timestamp": "2026-06-26T01:38:56.664555+00:00",
    "title": "Characterization of Modular Rank Four Nahm Sums via Discriminant Condition"
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
    "description": "# Future Directions \u2014 Primality Testing (AKS & Miller\u2013Rabin)\n\nDerived from this cycle's findings in `AKSCriterion.lean` and `MillerRabin.lean`.\nEach conjecture is bold, falsifiable, and accompanied by the decisive insight and\na \"why now?\" justification.\n\n## 1. Introspective-base AKS bound\n\n**Conjecture.** There is an explicit polynomial bound `B(n)` (polylog in `n`)\nsuch that: `n` is prime iff `(X + a)^n = X^n + a` in `(ZMod n)[X] / (X^r - 1)`\nfor all `1 \u2264 a \u2264 B(n)`, where `r = O((log n)^c)`. Formalizing this turns the\nsingle-base criterion `aks_criterion` into the full deterministic\npolynomial-time AKS algorithm.\n\nThe key insight is... the proven exact criterion `aks_criterion` already isolates\nthe obstruction (the inner coefficient `C(n,q)`); the remaining work is purely\nthe cyclotomic *order/coprime-base counting* that bounds how many bases are\nneeded once one quotients by `X^r - 1`.\n\n**Why now?** With the freshman's-dream equivalence fully formalized (0 sorries)\nand `not_dvd_choose_prime_dvd` in hand, the algebraic core is settled; the\noutstanding piece is a self-contained counting argument that Mathlib's\ncyclotomic and `orderOf` API can now support.\n\n## 2. Monier\u2013Rabin 1/4 error bound\n\n**Conjecture.** For every odd composite `n > 9`, the number of Miller\u2013Rabin\nnon-witnesses in `(ZMod n)\u02e3` is at most `\u03c6(n)/4`. Equivalently, the soundness\ntheorem `miller_rabin_sound` has a quantitative converse: composites have many\nwitnesses.\n\nThe key insight is... `sqrt_one_in_ZMod_prime` fails modulo a composite (there\nare \u2265 4 square roots of `1` by CRT), and the strong-liar set is contained in a\nproper subgroup of `(ZMod n)\u02e3`; bounding that subgroup's index by `4` is the\nwhole game.\n\n**Why now?** Soundness (the easy half) is verified; Mathlib's `ZMod.unitsEquiv`\nCRT decomposition and subgroup-index lemmas make the proper-subgroup counting\ntractable for the first time in this codebase.\n\n## 3. AKS strictly dominates Fermat on every Carmichael number\n\n**Conjecture.** For *every* Carmichael number `n` (not just `561`), the Fermat\ncongruence holds for all bases yet the AKS identity fails for some base coprime\nto `n`; moreover the failing base can be taken to be the least prime factor's\nco-factor. This generalizes `carmichael_561_fools_fermat_not_aks` to the entire\nfamily A002997.\n\nThe key insight is... `aks_identity_imp_fermat` shows AKS \u21d2 Fermat, and\n`aks_criterion` shows AKS \u21d4 primality, so AKS-failure is automatic for any\ncomposite; the new content is identifying a *coprime* failing base uniformly via\nKorselt's structure (`n` squarefree, `(p-1) \u2223 (n-1)`).\n\n**Why now?** The separation is already proved at `561` with a reusable mechanism\n(contrapositive of `aks_criterion`); only Korselt's criterion needs to be\nformalized to make the argument uniform over A002997.\n\n## 4. Carmichael numbers are exactly the Fermat-universal composites\n\n**Conjecture.** A composite `n` satisfies `\u2200 a, a^n \u2261 a (mod n)` iff `n` is\nsquarefree and `(p-1) \u2223 (n-1)` for every prime `p \u2223 n` (Korselt's criterion),\nand these are exactly the composites on which the Fermat test never detects\ncompositeness.\n\nThe key insight is... the universal Fermat congruence decomposes via CRT into\nper-prime-power conditions, and `a^n \u2261 a` modulo `p^k` for all `a` forces\n`k = 1` and `(p-1) \u2223 (n-1)` through the cyclic structure of `(ZMod p)\u02e3`.\n\n**Why now?** Our `native_decide` evidence already confirms the family begins\n`561, 1105` (A002997); a structural Korselt proof would replace finite checks by\na general theorem and feed directly into Direction 3.\n\n## 5. A `ZMod`-native fast modular-exponentiation tactic with a correctness theorem\n\n**Conjecture.** A `csimp`-backed binary modular-exponentiation routine computes\n`a^e mod n` with a kernel-checked correctness lemma `powMod a e n = a^e % n`,\nfast enough to discharge Miller\u2013Rabin / AKS instances by `decide` rather than\n`native_decide`, removing the `Lean.ofReduceBool` dependency from results like\n`carmichael_561_fools_fermat_not_aks`.\n\nThe key insight is... square-and-multiply is a fold over the binary digits of the\nexponent; its correctness is a clean induction, and a `@[csimp]` replacement\nkeeps the kernel in charge (no `@[implemented_by]` trust gap).\n\n**Why now?** The only non-`propext`/`Classical`/`Quot` axiom in this cycle is the\ncompiler-trust `Lean.ofReduceBool` from `native_decide`; a verified `powMod`\nwould let the Carmichael witness be checked by the kernel alone.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2292",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "7a69691f",
    "status": "available",
    "timestamp": "2026-06-23T01:40:49.707518+00:00",
    "title": "Derived from this cycle's findings in `AKSCriterion.lean` and `MillerRabin.lean`"
  },
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions\n\nThe most natural next step is to attack the residue class isolated by the\nprime-core reduction: primes `p \u2261 1 (mod 8)`. The key insight is that the four\nelementary families already dispatch every residue except this one, so the entire\ndifficulty of Erd\u0151s\u2013Straus is concentrated in a single arithmetic progression,\nand any constructive scheme that handles it would, via\n`erdosStraus_of_primes_one_mod_eight`, close the problem unconditionally. A\npromising route is to formalize the classical covering-congruence constructions\nof Mordell, which solve `4/p` for all `p` outside a sparse set of residues modulo\nsmall moduli (e.g. residues that are quadratic non-residues modulo `4`, or that\nfall into specific classes mod `3\u00b78`, `5\u00b78`, `7\u00b78`, \u2026). Why now? Because the\npresent development supplies exactly the reusable scaffolding \u2014 the predicate, the\nwitness-verification idioms, and divisor inheritance \u2014 that such a formalization\nwould otherwise have to rebuild from scratch.\n\nA second direction is computational certification at scale. The key insight is\nthat `ErdosStrausSolution n` is witnessed by a finite triple whose correctness is\na single rational identity, so a verified search procedure could emit witnesses\nfor enormous ranges and check them by `decide`/`norm_num`, turning empirical\ntables (which currently confirm the conjecture far beyond `10^17`) into\nmachine-checked theorems for explicit bounds. Why now? Because Lean's `decide`\nkernel reduction and `norm_num` extensions are mature enough to validate millions\nof rational identities reliably, and the bounded theorem `erdosStraus_upto_100`\ndemonstrates the pattern end to end; scaling it is an engineering problem, not a\nmathematical one.\n\nA third direction concerns the structure of the witness map itself.\nThe key insight is that the family witnesses are not ad hoc but instances of a small\nnumber of algebraic identities (the `1/a + 1/(a\u00b7n)` split and its halving, and the\n`(n+3)/(2na)` collapse), so one could formalize a *parametrized solver*: a single\nlemma taking residue data and returning a witness, from which all four families\nbecome corollaries. Why now? Because unifying the families would both shrink the\nproof and expose precisely which algebraic degrees of freedom remain unused for\nthe `1 (mod 8)` case, potentially suggesting the missing construction.\n\nA fourth direction is to connect this development to Mathlib's number-theoretic\ninfrastructure on quadratic residues and Dirichlet characters. The key insight is\nthat the obstruction at `p \u2261 1 (mod 8)` is governed by solvability of congruences\nthat quadratic reciprocity controls, so importing Mathlib's reciprocity and\nLegendre-symbol API could let one phrase the open core as a clean statement about\nrepresentability rather than as a raw existential over triples. Why now? Because\nMathlib's quadratic reciprocity and `ZMod` character theory are now stable and\nwell-supported, making it feasible to translate the analytic-number-theory\nheuristics for Erd\u0151s\u2013Straus into formal, checkable hypotheses.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_2559",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "199a5960",
    "status": "available",
    "timestamp": "2026-06-26T00:08:32.567910+00:00",
    "title": "The most natural next step is to attack the residue class isolated by the"
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
    "description": "Investigate the sequence \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order. with terms 127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,4096,6455,11264,11664,12850,13825,14641,155. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2283",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:80035",
    "status": "available",
    "timestamp": "2026-06-23T00:36:02.659081+00:00",
    "title": "OEIS sequence: \"Orderly\" Friedman numbers (or \"good\" or \"nice\" Friedman numbers): Friedman numbers (A036057) where the construction digits are used in the proper order."
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence Coreful perfect numbers: numbers k such that csigma(k) = 2*k, where csigma(k) is the sum of the coreful divisors of k (A057723). with terms 36,180,252,392,396,468,612,684,828,1044,1116,1176,1260,1332,1476,1548,1692,1908,1960,1980,2124,2196,. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Pythagorean"
    ],
    "id": "fd_2454",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:307958",
    "status": "available",
    "timestamp": "2026-06-24T22:36:53.103641+00:00",
    "title": "OEIS sequence: Coreful perfect numbers: numbers k such that csigma(k) = 2*k, where csigma(k) is the sum of the coreful divisors of k (A057723)."
  },
  {
    "consumed_by_exp_id": "",
    "description": "Investigate the sequence Stack polyominoes with square core. with terms 1,1,0,0,1,2,3,4,5,7,9,13,17,24,31,42,54,71,90,117,147,188,236,298,371,466,576,716,882,1088,1331,1633. Find a closed form, recurrence, or asymptotic and formalize it in Lean 4.",
    "domains": [
      "Bridges"
    ],
    "id": "fd_2482",
    "priority_score": 0.7,
    "research_mode": "team",
    "source_exp_id": "oeis:188674",
    "status": "available",
    "timestamp": "2026-06-24T22:36:53.104224+00:00",
    "title": "OEIS sequence: Stack polyominoes with square core."
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
