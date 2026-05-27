

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "id": "seed_001",
    "title": "Goldbach Conjecture",
    "description": "Prove that every even integer greater than 2 is the sum of two primes. Formalize partial results such as Vinogradov's theorem for sufficiently large odd integers, or Chen's theorem that every sufficiently large even number is the sum of a prime and a semiprime. Explore connections to sieve methods and the circle method.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.294221+00:00"
  },
  {
    "id": "seed_014",
    "title": "Hodge Conjecture",
    "description": "Prove that every Hodge class on a non-singular projective algebraic variety is a rational linear combination of classes of algebraic cycles. Formalize the Hodge decomposition and explore the conjecture for specific varieties like abelian varieties and K3 surfaces.",
    "domains": [
      "Geometry",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.387127+00:00"
  },
  {
    "id": "seed_016",
    "title": "Navier-Stokes Existence and Smoothness",
    "description": "Prove existence and smoothness of solutions to the 3D Navier-Stokes equations, or find a counterexample. Formalize known partial regularity results (Caffarelli-Kohn-Nirenberg) and explore connections to turbulence.",
    "domains": [
      "Analysis",
      "Physics"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.403036+00:00"
  },
  {
    "id": "seed_026",
    "title": "Lehmer's Mahler Measure Problem",
    "description": "Determine whether Lehmer's polynomial has the smallest Mahler measure among non-cyclotomic polynomials. Formalize the Mahler measure and its connections to heights, entropy, and algebraic dynamics.",
    "domains": [
      "NumberTheory",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.484135+00:00"
  },
  {
    "id": "seed_031",
    "title": "Frankl's Union-Closed Conjecture",
    "description": "Prove that for every finite union-closed family of sets (not all empty), some element belongs to at least half the sets. Formalize the lattice-theoretic reformulation and known partial results.",
    "domains": [
      "Combinatorics",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.520566+00:00"
  },
  {
    "id": "seed_034",
    "title": "Jacobian Conjecture",
    "description": "Prove that if a polynomial map F: C\u207f \u2192 C\u207f has constant non-zero Jacobian determinant, then F is invertible. Formalize the reduction to degree 3 and connect to the Dixmier conjecture.",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.544197+00:00"
  },
  {
    "id": "fd_0785",
    "title": "Direction 2: Functorial Localization of Persistence Modules",
    "description": "**Conjecture**: There exists a functor L_p from the category of \u2124-persistence modules to \u2124_(p)-persistence modules (localization at p) such that:\n\n1. L_p preserves interleavings (with the same parameter \u03b4)\n2. PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F))\n3. L_p transforms interleavings into potentially tighter interleavings when the interleaving maps have p-local structure\n\n**Test**: Implement L_p for finite persistence modules represented as sequences of finitely generated abelian groups. Verify properties (1)-(2) on 100 random examples. Search for examples where (3) gives strictly improved \u03b4.\n\n**Impact**: This would make primewise stability a corollary of ordinary stability applied to a localized module \u2014 conceptually clean and opening the door to all localization techniques from commutative algebra.\n\n**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` \u2014 `pTorsionBirthSet_eq_torsionBirthSet`, `pTorsionBirthSet_deltaClose`\n\n**Proof Strategy**: Define L_p as the tensor product with \u2124_(p). Show that \u2124_(p) is flat over \u2124, so tensoring preserves exact sequences and injective maps. The interleaving maps descend to L_p since tensor product is functorial. The key: show that PTorsionBirthSet equals the torsion birth set of the localized module.\n\n**Domain Bridges**: Commutative algebra, algebraic topology, derived categories\n\n**Lineage**: Extends `prime_channel_independence` and `torsion_detector_factorizes_over_primes`\n\n**Ambition**: Solid extension \u2014 builds systematic algebraic infrastructure\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2d14ce54",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T23:11:24.492421+00:00"
  },
  {
    "id": "fd_0786",
    "title": "Direction 3: Primewise Birth Spectra Distinguish Filtrations",
    "description": "**Conjecture** (Hypothesis D): There exist filtrations F, G with TorsionBirthSet(F) = TorsionBirthSet(G) (as global sets) but PTorsionBirthSet(p, F) \u2260 PTorsionBirthSet(p, G) for some prime p.\n\n**Test**: Exhaustive search over filtered abelian groups with at most 4 levels and torsion orders dividing 30. For each pair with matching global birth, check if primewise births differ. The conjecture predicts at least one distinguishing example.\n\n**Impact**: Proves the primewise invariant is strictly finer than the global one \u2014 the prime decomposition has real information content beyond relabeling.\n\n**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` \u2014 `mem_globalTorsionBirthSet_implies_exists_prime`\n\n**Proof Strategy**: Construct F with Z/2Z at level 1 and Z/6Z at level 3; construct G with Z/3Z at level 1 and Z/6Z at level 3. Both have global torsion birth at level 1, but F has 2-torsion birth at 1 and 3-torsion birth at 3, while G has 3-torsion birth at 1 and 2-torsion birth at 3. Formalize this in Lean.\n\n**Domain Bridges**: Algebraic topology, data science, topological signal processing\n\n**Lineage**: Direct test of the theory's discriminating power\n\n**Ambition**: Solid extension \u2014 concrete and falsifiable\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2d14ce54",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T23:11:24.506271+00:00"
  },
  {
    "id": "fd_0787",
    "title": "Direction 4: Global Stability as Max Envelope",
    "description": "**Conjecture** (Hypothesis C): For finite-type filtrations with finitely many active primes,\n\n```\noptimal_global_shift(F, G) = sup_p optimal_prime_shift(p, F, G)\n```\n\nwhere the supremum is over all primes p.\n\n**Test**: Compute both sides on 1000 random filtration pairs with torsion orders in {2, 3, 5, 6, 10, 15, 30}. The conjecture predicts exact equality. A single instance of strict inequality (global < max primewise, or global > max primewise) would falsify it.\n\n**Impact**: Confirms that the primewise decomposition is a complete refinement \u2014 no information is lost, and the global bound is exactly the worst-case prime channel.\n\n**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` \u2014 `global_stability_from_primewise`\n\n**Proof Strategy**: The inequality global \u2264 sup_p is immediate from `global_stability_from_primewise`. The reverse requires showing that the global birth distance equals the maximum primewise birth distance. This follows from the decomposition theorem: the global birth is at the minimum of all prime births, and the Hausdorff distance between minima is bounded by the max of individual distances.\n\n**Domain Bridges**: Metric geometry, minimax theory\n\n**Lineage**: Extends `global_stability_from_primewise` and `globalTorsionBirthSet_deltaClose`\n\n**Ambition**: Solid extension \u2014 proves completeness of the decomposition\n\n---",
    "domains": [
      "Pythagorean",
      "Geometry",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2d14ce54",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T23:11:24.518980+00:00"
  },
  {
    "id": "fd_0790",
    "title": "Direction 1: Hardness of Unrestricted-Degree Lorentzian Recognition",
    "description": "**Conjecture.** When the degree d is part of the input (not fixed), deciding whether a homogeneous polynomial with nonneg integer coefficients is Lorentzian is coNP-hard.\n\n**Test.** Reduce a known coNP-hard problem \u2014 such as verifying that a symmetric matrix has no positive eigenvalue (which is coNP-complete for matrices given in factored form) \u2014 to Lorentzian recognition. Construct explicit polynomial families where any recursive certificate must examine at least n^{\u03a9(d)} quadratic leaves. A disproof would exhibit a polynomial-time algorithm for unrestricted-degree recognition.\n\n**Impact.** This would be the first formal hardness result for any Hodge-theoretic positivity predicate, creating a new complexity class boundary. It would definitively separate \"fixed-degree tractable\" from \"unrestricted-degree hard\" and motivate the development of approximation algorithms.\n\n**Catalog References.** `Pythagorean/LorentzianRecognition.lean`: `card_multiindex_le_pow`, `quadratic_leaf_count_le` (upper bounds that the hardness would complement).\n\n**Proof Strategy.** Encode 3-SAT unsatisfiability as a Lorentzian recognition instance. Given a 3-SAT formula \u03c6 on m clauses, construct a degree-(m+2) polynomial P_\u03c6 in n variables such that P_\u03c6 is Lorentzian iff \u03c6 is unsatisfiable. The construction uses the clause-variable incidence structure to define derivative branches that are Lorentzian iff the clause is satisfied.\n\n**Domain Bridges.** Computational complexity \u2192 algebraic combinatorics. Connects the Cook\u2013Levin theory of NP-completeness to Hodge-theoretic positivity.\n\n**Lineage.** Builds on `quadratic_leaf_count_le` (polynomial upper bound) to show the bound is tight in degree.\n\n**Ambition.** Grand challenge. A positive resolution would be a landmark in algebraic complexity theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "33261812",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T23:12:21.832370+00:00"
  },
  {
    "id": "fd_0791",
    "title": "Direction 2: Sparse-Support Certificate Compression",
    "description": "**Conjecture.** For matroid basis generating polynomials of rank r on ground set [n], the number of nonzero quadratic leaves is O(n^2 \u00b7 r^{d-4}) rather than n^{d-2}, where d is the degree.\n\n**Test.** Compute derivative leaves for uniform matroids U_{r,n}, graphic matroids of sparse graphs, and transversal matroids. Count the number of nonzero quadratic leaves and compare to the worst-case bound n^{d-2}. A disproof would exhibit a matroid family where the nonzero leaf count matches the worst case.\n\n**Impact.** This would make Lorentzian recognition practical for partition-function polynomials arising in combinatorial optimization and statistical physics, where support is typically sparse relative to the ambient monomial space.\n\n**Catalog References.** `Pythagorean/LorentzianRecognition.lean`: `multiIndexSet`, `numberOfQuadraticLeaves`; `Speculative/AutoResearch/LorentzianMConvex.lean`: `NewtonSupport`, `IsMConvexExchangeNat`.\n\n**Proof Strategy.** Use the M-convex exchange property of the Newton support (from the existing catalog) to show that many derivative branches have zero coefficient. The exchange property constrains which multiindices can appear in the support of iterated derivatives, dramatically pruning the recursion tree.\n\n**Domain Bridges.** Matroid theory \u2192 algorithmic complexity \u2192 statistical physics (partition functions of matroids).\n\n**Lineage.** Builds on the M-convex support theorem in `LorentzianMConvex.lean` and the leaf-counting bound in this cycle.\n\n**Ambition.** Solid extension. The uniform matroid case should be provable; general matroids require new structural lemmas.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "33261812",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T23:12:21.848642+00:00"
  },
  {
    "id": "fd_0800",
    "title": "Direction 2: Heterogeneity\u2013Gap Conjecture",
    "description": "**Conjecture:** For every \u03b5 > 0, there exists \u03b4 > 0 such that for all hypergraphs H on n \u2265 10 vertices with edge heterogeneity \u03c3\u00b2(H) > \u03b4, we have \u03c4(H) \u2212 \u2308\u03c4*(H)\u2309 \u2265 1. In other words, sufficiently heterogeneous hypergraphs always have a positive integrality gap beyond the ceiling rounding gap.\n\n**Test:** Generate 10,000 random hypergraphs on n = 15 vertices with edges of sizes {2, 3, 4, 5} at varying proportions. For each, compute \u03c3\u00b2, \u03c4, \u03c4*, and \u03c4 \u2212 \u2308\u03c4*\u2309. Plot the gap vs \u03c3\u00b2 and identify the critical threshold \u03b4*. Attempt to disprove by finding hypergraphs with \u03c3\u00b2 > 2 and \u03c4 = \u2308\u03c4*\u2309.\n\n**Impact:** If true, this would establish edge-size heterogeneity as a sufficient condition for integrality gap positivity, providing a simple structural certificate that LP relaxation is strictly better than integer programming for a given instance. This has direct implications for algorithm selection in practice.\n\n**Catalog References:** `Pythagorean/HypergraphTransversal.lean` \u2014 `edgeHeterogeneity`, `IsHeterogeneous`, `heterogeneity_zero_of_uniform`.\n\n**Proof Strategy:** For the forward direction, construct explicit fractional transversals that exploit heterogeneity to achieve sub-integer values. For necessity, construct uniform hypergraphs where \u03c4 = \u2308\u03c4*\u2309. The probabilistic method may yield existence proofs for extreme heterogeneity.\n\n**Domain Bridges:** Connects to information theory (entropy of edge-size distribution), statistical mechanics (disorder parameter), and algebraic combinatorics (chromatic polynomials).\n\n**Lineage:** Builds on `heterogeneity_zero_of_uniform` and `integrality_gap_upper`.\n\n**Ambition:** Grand challenge \u2014 this would be a new structural result in combinatorial optimization with no direct precedent.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "f6e7fe77",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T23:13:44.233016+00:00"
  },
  {
    "id": "fd_0808",
    "title": "Direction 2: Density Heuristics via the Circle Method",
    "description": "**Conjecture:** For each admissible $k$ (i.e., $k \\not\\equiv 4,5 \\pmod{9}$), the number of representations $|\\{(x,y,z) \\in [-N,N]^3 : x^3+y^3+z^3 = k\\}|$ grows as $c_k \\cdot N^{1/3}$ for an explicit constant $c_k > 0$ depending on the singular series and singular integral.\n\n**Test:** Compute empirical counts of representations for $k \\in \\{0, 1, 2, 3, 6, 7, 8, 9\\}$ up to $N = 10^6$ and compare with the predicted asymptotic. Measure the relative error $|R(N) - c_k N^{1/3}| / (c_k N^{1/3})$ and verify it decreases with $N$.\n\n**Impact:** Would provide the first formally grounded connection between the combinatorial/algebraic framework and analytic number theory. The singular series in the density prediction is a product of local densities, directly connecting to our `ThreeCubeLocalAdmissible` counts.\n\n**The key insight is** that the local admissibility counts $|A_n|/n$ at each modulus $n$ are the local factors of the singular series, and the everywhere-local-admissibility theorem guarantees this product converges when $k$ is admissible.\n\n**Why now?** The formal definitions of local admissibility and the computational infrastructure for counting admissible residues provide the exact data needed to compute singular series factors and compare with empirical density.\n\n**Catalog References:** `ThreeCubeLocalAdmissible` (Algebra/SumThreeCubes/Defs.lean), `sumThreeCubesRep_implies_everywhereLocallyAdmissible` (Algebra/SumThreeCubes/LocalGlobal.lean)\n\n**Proof Strategy:** Formalize the circle method setup for cubic forms, compute the singular integral, and bound the minor arc contributions.\n\n**Domain Bridges:** Analytic number theory, harmonic analysis, probability theory\n\n**Lineage:** Connects the discrete local admissibility framework to continuous density predictions\n\n**Ambition:** Solid extension \u2014 the circle method for three cubes is at the boundary of current analytic technique\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "34c2669a",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T00:26:36.199585+00:00"
  },
  {
    "id": "fd_0813",
    "title": "Direction 1: Confluence and Unique Normal Forms",
    "description": "**Conjecture:** The 8-rule distributivity fragment defined in `TensorSortedRewrite.lean` is confluent modulo associativity-commutativity of scalar addition, i.e., any two reduction sequences from the same term yield syntactically equal normal forms up to AC-equivalence of `scalAdd`.\n\n**Test:** Enumerate all tensor terms of depth \u2264 5 with 3 scalar, 3 vector, and 2 matrix variables. For each term, compute all possible reduction sequences (using breadth-first enumeration of rule applications). Check that all terminal forms are AC-equivalent. A single counterexample \u2014 two irreducible forms that differ by more than scalar-addition reordering \u2014 refutes the conjecture. Run over \u211a for exact arithmetic.\n\n**Impact:** Confluence implies that normalization is deterministic up to AC, which is essential for using the rewrite system as a certified decision procedure. Without confluence, different simplification strategies could produce different \"simplified\" forms, undermining trust in automated preprocessing.\n\n**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` \u2014 `TensorRewrite`, `normStep`, `normStep_sound_*`.\n\n**Proof Strategy:** Define a weight function that strictly decreases under each oriented rule (the current `tensorWeight` increases, but a redex-counting measure should decrease). Prove local confluence by showing all critical pairs are joinable. Apply Newman's lemma (termination + local confluence \u2192 confluence).\n\n**Domain Bridges:** Term rewriting theory \u2192 optimization preprocessing \u2192 compiler correctness for scientific code.\n\n**Lineage:** Extends Theorem 1 (one-step soundness) and Theorem 6 (normStep soundness) toward a complete decision procedure.\n\n**Ambition:** Medium \u2014 requires careful critical pair analysis but builds on well-understood rewriting theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "c1bdccd8",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T00:54:40.932722+00:00"
  },
  {
    "id": "fd_0822",
    "title": "Direction 4: Extension to System F (Polymorphic Lambda Calculus)",
    "description": "**Conjecture:** For System F (polymorphic lambda calculus), there exists a type complexity invariant analogous to typeStateBound that exactly characterizes the maximal bounded behavioral complexity of closed terms, with the invariant depending on the type and the instantiation.\n\n**Test:** Define a candidate invariant for simple System F types (e.g., \u2200\u03b1. \u03b1 \u2192 \u03b1, Church numerals \u2200\u03b1. (\u03b1 \u2192 \u03b1) \u2192 \u03b1 \u2192 \u03b1). Compute bounded state sets for small terms of these types. Check whether any numerical pattern emerges that could serve as the polymorphic type state bound.\n\n**Impact:** Would extend the entire theory to the dominant type system of functional programming, covering Haskell, ML, and dependently typed languages.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TypeComplexityBounds.lean` \u2014 `typeStateBound_eq_complexity` (the STLC case)\n\n**Proof Strategy:** Polymorphic types introduce quantifier complexity. The key challenge: \u2200\u03b1.\u03c4 has no fixed typeStateBound because \u03b1 can be instantiated at different types. One approach: define the bound as a supremum over instantiations. Another: define it relative to a fixed universe of types.\n\n**Domain Bridges:** Polymorphism in programming languages, parametricity (Reynolds 1983), categorical semantics.\n\n**Lineage:** Extends Statman's undecidability results for System F (1979) and Girard's normalization (1972).\n\n**Ambition:** \ud83c\udf1f\ud83c\udf1f\ud83c\udf1f\ud83c\udf1f\ud83c\udf1f \u2014 Grand challenge, paradigm-shifting.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "21d0ab18",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T00:55:14.021207+00:00"
  },
  {
    "id": "fd_0831",
    "title": "Direction 2: Lorentzian Polynomials in Statistical Physics and Probability",
    "description": "**Conjecture**: The partition function of any determinantal point process (DPP), when restricted to its homogeneous components, yields Lorentzian polynomials. This implies that all marginal inclusion probabilities satisfy the negative dependence inequality $\\Pr[i \\in S \\text{ and } j \\in S] \\le \\Pr[i \\in S] \\cdot \\Pr[j \\in S]$.\n\nFormally:\n```\ntheorem dpp_partition_function_lorentzian\n    {n : \u2115} (K : Matrix (Fin n) (Fin n) \u211d) (hK : K.PosSemidef) (d : \u2115) :\n    IsBrandenHuhLorentzian d (homogeneousComponent d (dppPartitionFunction K))\n```\n\n**Test**: For random PSD matrices $K$ of size $n \\le 8$, compute the partition function, extract homogeneous components, and verify Lorentzianity via the spectral recognizer. Compare marginal correlations against the negative dependence bound.\n\n**Impact**: This would provide the first formally verified proof of negative dependence for DPPs, a fundamental result in probability and statistical physics. It would connect Lorentzian polynomial theory to random matrix theory, repulsive particle systems, and machine learning (DPPs are widely used for diverse subset selection).\n\n**The key insight is** that the partition function $\\det(I + \\text{diag}(x) \\cdot K)$ for PSD $K$ is a product of linear forms in the eigenvalue basis, making it manifestly Lorentzian. The formal challenge is connecting this spectral decomposition to the polynomial coefficient structure.\n\n**Why now?** DPPs are experiencing a surge of interest in machine learning and spatial statistics. Formally verified negative dependence guarantees would be valuable for certified randomized algorithms.\n\n**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` \u2014 `IsBrandenHuhLorentzian`, `lorentzian_reversed_cauchy_schwarz`\n\n**Proof Strategy**: Decompose $\\det(I + DK)$ in the eigenbasis of $K$. Each factor is a positive linear form, so the product is Lorentzian by the closure property. Transfer back to the standard basis.\n\n**Domain Bridges**: Probability theory, statistical physics, machine learning, random matrix theory\n\n**Lineage**: Extends `lorentzian_reversed_cauchy_schwarz` and `spectralRecognizer_sound`\n\n**Ambition**: Grand challenge \u2014 connecting algebraic combinatorics to probability theory at the formal level\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "83d44e07",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T02:10:32.364163+00:00"
  },
  {
    "id": "fd_0838",
    "title": "Direction 4: Tropical Mixing Without Spectral Intermediate",
    "description": "**Conjecture:** The tropical diameter of the Newton subdivision of a Lorentzian polynomial *directly* controls the mixing time, without passing through the spectral gap: \u03c4_mix \u2264 O(trop_diam \u00b7 n \u00b7 log n), where trop_diam \u2264 O(d \u00b7 n) for degree-d polynomials.\n\n**Test:** For randomly generated Lorentzian polynomials (degree 3\u20135, variables 3\u201310), compute both the tropical diameter and the actual mixing time (from eigenvalue computation). Plot \u03c4_mix vs. trop_diam. If the relationship is linear (not quadratic), the direct bound holds.\n\n**Impact:** Would bypass the spectral gap entirely, providing a geometric understanding of mixing that connects to the rapidly developing field of tropical geometry.\n\n**Catalog References:** `Pythagorean/CertificateSampling.lean` \u2014 `tropical_diameter_le_dn`, `certificate_mixing_time_bound`\n\n**Proof Strategy:** Use the canonical paths method directly with paths defined by the tropical subdivision. Each path follows the ridge between tropical cells, and its congestion is bounded by the cell volumes (which are controlled by the mixed volumes of the Newton polytope). The Lorentzian condition ensures these volumes satisfy a Brunn-Minkowski-type inequality that bounds congestion.\n\n**Domain Bridges:** Tropical geometry (Newton polytopes, subdivisions), combinatorial geometry (Brunn-Minkowski theory), algebraic statistics (toric models)\n\n**Lineage:** Extends `tropical_diameter_le_dn` with a direct mixing argument\n\n**Ambition:** Solid extension \u2014 the canonical paths framework is well-established, and tropical geometry provides the right language.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "1f8fa3a8",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T02:11:10.243679+00:00"
  },
  {
    "id": "fd_0839",
    "title": "Direction 5: Dynamic Lorentzian Certificates and Online Sampling",
    "description": "**Conjecture:** When a Lorentzian polynomial f changes by a rank-1 update (adding a single monomial term), the certificate tree can be updated in O(n^(d\u22123) \u00b7 n\u00b2) time \u2014 a factor of n cheaper than rebuilding from scratch \u2014 and the Markov chain can be \"warm-started\" with mixing time O(n \u00b7 log n) from the previous stationary distribution.\n\n**Test:** Implement dynamic certificate maintenance for the generating polynomial of a matroid as elements are added/deleted. Measure (a) certificate update time vs. rebuild time, (b) warm-start mixing time vs. cold-start mixing time, for graphic matroids of growing graphs (n = 10, 20, 50, 100 vertices, adding one edge at a time).\n\n**Impact:** Would make certificate-guided sampling practical for streaming and online settings, where the underlying polynomial evolves over time.\n\n**Catalog References:** `Pythagorean/CertificateSampling.lean` \u2014 `certificate_verification_complexity`, `certificateDepth`; `Catalog/FINAL/Bridges/LorentzianRecognition.lean` \u2014 `pderiv_isHomogeneous_degree_pred`\n\n**Proof Strategy:** A rank-1 update to f changes only O(n^(d\u22123)) leaves of the certificate tree (those whose multiindex overlaps the updated monomial). Recompute eigenvalues only at affected leaves. For warm-starting, bound the total variation distance between old and new stationary distributions using the \u2113\u2081 change in coefficients, then apply the mixing time bound with this as the initial distance.\n\n**Domain Bridges:** Online algorithms (streaming computation), dynamic graph algorithms, stochastic optimization (follow-the-regularized-leader)\n\n**Lineage:** Extends `certificate_verification_complexity` to the dynamic setting\n\n**Ambition:** Solid extension \u2014 the key ideas (lazy updates, warm starts) are well-known in MCMC; the novelty is combining them with certificate structure.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "1f8fa3a8",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T02:11:10.263299+00:00"
  },
  {
    "id": "fd_0840",
    "title": "Direction 1: Basis Uniqueness up to Tropical Projective Equivalence",
    "description": "**Conjecture**: For each connected graph G, basepoint q, and subset S \u2286 V \\ {q}, the cycle-component generating family of the tropical kernel of L_S is unique up to tropical scaling (adding constants to individual generators) and permutation, whenever G[S] has a pairwise edge-disjoint cycle basis and distinct q-visible components.\n\n**Test**: Exhaustive search over all connected graphs on n \u2264 7 vertices. For each (G, q, S), compute all minimal tropical generating families of ker_trop(L_S) and compare equivalence classes. Verify that the number of equivalence classes is exactly 1 when the edge-disjointness condition holds, and characterize the failure cases.\n\n**Impact**: Establishes canonical generators for tropical kernels, enabling effective computation and comparison across graph families. Would be the tropical analogue of the uniqueness of the Smith normal form.\n\n**Catalog References**: `Pythagorean/TropicalBridge/Defs.lean` (tropicalKernel, componentIndicator), `Pythagorean/TropicalBridge/TropicalHodge.lean` (componentIndicator_mem_tropicalKernel, tropicalKernel_leaf_eq).\n\n**Proof Strategy**: Use the separation properties of cycle generators (support on cycle vertices) and component generators (support on component vertices) to show that any alternative generating family must be related by tropical scaling. The key tool is the leaf propagation lemma, which forces values along tree edges.\n\n**Domain Bridges**: Tropical linear algebra \u2194 matroid theory (the cycle matroid determines uniqueness), algebraic combinatorics \u2194 graph theory.\n\n**Lineage**: Extends the structural kernel theorems in `TropicalHodge.lean` from existence to uniqueness.\n\n**Ambition**: \u2605\u2605\u2605 (Solid extension \u2014 technically challenging but conceptually clear)\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "fd2f08b2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T03:05:35.257371+00:00"
  },
  {
    "id": "fd_0852",
    "title": "Direction 1: Sharp Dixon Asymptotics via M\u00f6bius Inversion",
    "description": "**Conjecture:** The exact number of generating pairs in $S_n$ can be expressed via M\u00f6bius inversion on the subgroup lattice:\n$$|\\{(\\sigma, \\tau) : \\langle \\sigma, \\tau \\rangle = S_n\\}| = \\sum_{H \\leq S_n} \\mu(H, S_n) \\cdot |H|^2$$\nand the leading terms of the asymptotic expansion satisfy $P_n = 1 - 1/n - 1/n^2 - 4/n^3 - 23/n^4 - O(1/n^5)$.\n\n**Test:** Verify the M\u00f6bius inversion formula computationally for $n \\leq 7$ using GAP, then formalize the first two terms of the asymptotic expansion in Lean by bounding contributions from subgroups of index $> n$.\n\n**Impact:** This would yield the first machine-verified sharp asymptotic for a generation probability, going far beyond the $O(1/n)$ bound from the point-stabilizer sieve.\n\n**Catalog References:** `Algebra/SymmGroupGeneration.lean` \u2014 `nongeneratingPairProbability_le_maximal_subgroup_sum`, `generatingPairProbability_eq_card_ratio`.\n\n**Proof Strategy:** Define the M\u00f6bius function on the subgroup lattice of $S_n$ using `Finpartition` or direct recursion. Formalize the inclusion-exclusion identity $\\sum_{H \\leq G} \\mu(H, G) = \\delta_{H,G}$. Then express the generating pair count as a M\u00f6bius sum and bound tail terms using subgroup index estimates.\n\n**Domain Bridges:** Analytic combinatorics (singularity analysis of generating functions), number theory (M\u00f6bius inversion analogues).\n\n**Lineage:** Direct extension of the subgroup sieve inequality proved in this cycle.\n\n**Ambition:** Grand challenge \u2014 requires formalizing the subgroup lattice M\u00f6bius function and sharp subgroup counting bounds for $S_n$.\n\n**The key insight is** that the M\u00f6bius function on the subgroup lattice encodes *exactly* how much each subgroup contributes to the generation count, turning the subgroup sieve from an inequality into an identity.\n\n**Why now?** The subgroup sieve framework is now formalized, providing the \"\u2264\" half. The M\u00f6bius inversion provides the \"=\" half, and Mathlib's growing lattice theory API makes the combinatorial prerequisites increasingly accessible.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "92e3853a",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T03:08:48.881853+00:00"
  },
  {
    "id": "fd_0858",
    "title": "Direction 1: Lorentzian-to-Coefficient Bridge via Bivariate Specialization",
    "description": "**Conjecture**: For every homogeneous polynomial $P$ of degree $d$ with nonnegative coefficients and recursive Lorentzian depth $k$ (as defined by `IsRecursivelyLorentzian` in `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`), every bivariate specialization $P(x, y) = \\sum a_m x^m y^{d-m}$ with $a_m > 0$ yields a coefficient sequence that is $\\min(k, d-2)$-fold log-concave in the sense of `KFoldLogConcave` (from `Catalog/Pythagorean/HigherOrderLogConcavity.lean`).\n\n**Test**: Extract bivariate specialization coefficients from explicit Lorentzian polynomials (products of linear forms, matroid basis generating polynomials for uniform matroids, Kirchhoff polynomials of small graphs). Compute iterated ratio sequences and verify log-concavity at each depth. A single family with Lorentzian depth $k \\geq 2$ whose coefficient sequence fails 2-fold log-concavity disproves the conjecture.\n\n**Impact**: This would be the flagship theorem connecting algebraic geometry (Hessian spectral signatures) to discrete analysis (ratio sequence concavity). It would turn the abstract recognition algorithm in `LorentzianRecognitionComplete.lean` into a concrete inequality machine for coefficient sequences.\n\n**The key insight is** that the Lorentzian Hessian condition at each differentiation level translates, via the reversed Cauchy\u2013Schwarz inequality (already formalized as `lorentzian_reversed_cauchy_schwarz`), into a ratio-sequence inequality that propagates one level of the k-fold hierarchy.\n\n**Why now?** The existing Catalog contains both the recursive Lorentzian predicate and the k-fold log-concavity definitions. The reversed Cauchy\u2013Schwarz theorem provides the exact algebraic bridge needed. What remains is to formalize the coefficient extraction from bivariate specialization and verify the inequality chain at each recursive level.\n\n**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (IsRecursivelyLorentzian, lorentzian_reversed_cauchy_schwarz), `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave, KFoldLogConcave.ratio)\n\n**Proof Strategy**: Define `coeffOfBivariateHomogeneous` as the coefficient extractor. For degree-2, the reversed Cauchy\u2013Schwarz directly gives log-concavity. Induct on Lorentzian depth: each differentiation step reduces degree by 1 and Lorentzian depth by 1, while the coefficient sequence's ratio inherits the Lorentzian inequality from the derivative polynomial.\n\n**Domain Bridges**: Algebraic geometry \u2192 discrete combinatorics \u2192 sampling algorithms\n\n**Lineage**: Extends `recursivelyLorentzian_iff_brandenHuh` and `lorentzian_reversed_cauchy_schwarz`\n\n**Ambition**: Grand challenge \u2014 would establish a new theorem class connecting two major theories.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "56c2f88c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T14:24:15.293101+00:00"
  },
  {
    "id": "fd_0870",
    "title": "Direction 3: Topological Quantum Error Correction from Gauge Theory",
    "description": "**Conjecture:** The mass gap \u0394 of a lattice gauge theory with gauge group G determines the code distance d of the corresponding Kitaev quantum double model: d = \u03a9(\u0394 \u00b7 L) where L is the linear system size. The Dynkin diagram classification of G therefore classifies topological quantum codes.\n\n**Test:** For gauge groups \u2124\u2082 (toric code), S\u2083 (non-abelian), and SU(2) (continuous), compute the code distance of the quantum double on an L\u00d7L torus for L = 4, 8, 16 and verify the scaling d \u221d \u0394 \u00b7 L.\n\n**Impact:** Would provide a systematic framework for designing topological quantum memories with guaranteed protection times, directly applicable to quantum computing hardware.\n\n**Catalog References:**\n- `Physics/YangMillsMassGap.lean`: `total_plaquette_energy_gauge_invariant`, `plaquette_transport`\n- `Physics/ToricCode.lean`: `quantum_singleton_bound`\n\n**Proof Strategy:** (A) Construct the quantum double Hamiltonian H = -\u2211_v A_v - \u2211_p B_p from the lattice gauge field. (B) Show the spectral gap of H equals the mass gap of the gauge theory using `class_fn_gauge_invariant`. (C) Prove that the code distance satisfies d \u2265 \u0394 \u00b7 L using the exponential decay theorem (`spectral_gap_implies_correlation_decay`). (D) Use `plaquette_transport` to transfer results between isomorphic gauge groups.\n\n**Domain Bridges:** Gauge theory \u2192 Quantum error correction \u2192 Condensed matter physics (topological order)\n\n**Lineage:** Extends `plaquette_transport` (Dynkin invariance) to quantum codes.\n\n**Ambition:** Solid extension with high practical impact \u2014 directly connects to quantum computing.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "6a88b92d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T15:29:21.854833+00:00"
  },
  {
    "id": "fd_0886",
    "title": "Direction 4: Statistical Physics of Random Transversals and Phase Transitions",
    "description": "**Conjecture:** For random d-uniform hypergraphs on n vertices with m = c\u00b7n edges (c > 0 constant), the ratio \u03c4*(H)/n undergoes a phase transition at c = c*(d), and the integrality gap \u03c4(H)/\u03c4*(H) concentrates around a value strictly less than d for c above the transition, approaching d only at the critical density.\n\n**Test:** For d=3 and n=100, sweep c from 0.1 to 5.0. For each c, generate 100 random instances, solve the LP and find integral optima (or bound via rounding), and compute the empirical integrality gap distribution. Plot mean and variance of the gap as a function of c. A phase transition appears as a sharp change in the gap curve.\n\n**Impact:** Would establish the first rigorous connection between random hypergraph transversal theory and statistical physics phase transitions. The gap behavior at criticality could reveal universality classes for covering problems.\n\n**Catalog References:**\n- `Catalog/Pythagorean/HypergraphTransversal.lean`: `integrality_gap_upper`, `uniform_integrality_gap`\n- `Catalog/Pythagorean/WeightedHypergraphTransversal.lean`: `weighted_threshold_cost_bound`\n\n**Proof Strategy:** Use the second moment method to show concentration of \u03c4*/n. Apply the cavity method (heuristically) to predict the phase transition threshold c*(d). Formalize the upper bound d\u00b7\u03c4* and show it is not tight in the random setting by constructing a better rounding scheme that exploits randomness.\n\n**Domain Bridges:** Statistical physics (replica method, spin glasses), random constraint satisfaction, coding theory (LDPC codes as hypergraph covers)\n\n**Lineage:** Connects the deterministic integrality gap bound to the probabilistic theory of random CSPs, where phase transitions in satisfiability and covering have been predicted by physics but rarely proved.\n\n**Ambition:** Grand challenge \u2014 would bridge formal combinatorics and statistical physics via the integrality gap.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "b9d16ed0",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T16:39:08.918006+00:00"
  },
  {
    "id": "fd_0888",
    "title": "Direction 1: Sharp Constants in the Dimension-Degree Stability Law",
    "description": "**Conjecture:** For every (n, d), the optimal constant C(n,d) such that entry-wise perturbation \u2264 C(n,d)\u00b7\u03b5 preserves Lorentzianity satisfies C(n,d) = \u0398(1/n) \u2014 linear in 1/n rather than the 1/n\u00b2 from our entry-based bound.\n\n**Test:** Compute C(n,d) numerically for e_k(x\u2081,...,x\u2099) with n \u2264 20, k \u2264 10 via binary search on the destruction threshold. If C(n,d) \u00b7 n is approximately constant across n, the conjecture is supported. A counterexample where C(n,d) \u00b7 n \u2192 0 would disprove it.\n\n**Impact:** Sharp constants would close the 4\u20135\u00d7 conservatism gap we observe empirically, making the certificate practically tight. This would make certified Lorentzian recognition competitive with uncertified numerical methods.\n\n**Catalog References:** `Pythagorean/LorentzianStability.lean` \u2014 `quadFormBound_of_entry_bound`, `dimension_degree_stability_law_instance`\n\n**Proof Strategy:** Replace the entry-based AM-GM bound with a tighter analysis using Schur complements or matrix concentration inequalities. The key is showing that random symmetric perturbations with independent entries have spectral radius O(\u221an \u00b7 max_entry) rather than O(n \u00b7 max_entry).\n\n**Domain Bridges:** Numerical linear algebra (spectral radius of random matrices), high-dimensional probability (matrix Chernoff bounds)\n\n**Lineage:** Directly extends Theorem 4.4 of the current work.\n\n**Ambition:** Solid extension \u2014 would complete the quantitative picture opened by the perturbation theorem. \u2605\u2605\u2605\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2493279d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:14:31.150620+00:00"
  },
  {
    "id": "fd_0890",
    "title": "Direction 3: Tropical Shadows of Lorentzian Stability",
    "description": "**Conjecture:** The tropicalization of the Lorentzian stability radius (infimum of coefficient perturbations destroying Lorentzianity) equals the minimum tropical spectral gap across tropical quadratic leaves.\n\n**Test:** Compute tropical quadratic leaves for small examples (complete graphs, uniform matroids). Compare the tropical spectral gap to the log of the exact stability radius. If they differ by more than O(log n), the conjecture fails.\n\n**Impact:** Would provide a purely combinatorial proxy for the numerical stability radius, computable in polynomial time without eigenvalue decomposition. This could enable Lorentzian certification for polynomials with millions of variables.\n\n**Catalog References:** `Pythagorean/LorentzianStability.lean` \u2014 `UniformSpectralMargin`; `Catalog/Tropical/` \u2014 various tropical geometry files\n\n**Proof Strategy:** Use the Maslov dequantization: take the limit of log(stability_radius(t\u1d45 \u00b7 f)) / log(t) as t \u2192 \u221e. Show this limit equals the tropical spectral gap via the tropical eigenvalue theory of Akian, Gaubert, and Guterman.\n\n**Domain Bridges:** Tropical geometry, max-plus algebra, combinatorial optimization\n\n**Lineage:** Builds on both the stability theory (this work) and tropical Lorentzian theory.\n\n**Ambition:** Grand challenge \u2014 would create a new bridge between numerical stability and tropical geometry. \u2605\u2605\u2605\u2605\u2605\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2493279d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:14:31.193329+00:00"
  },
  {
    "id": "fd_0894",
    "title": "Direction 1: Full Wreath Product Phase Transition",
    "description": "**Conjecture:** For the wreath product $W_{k,m} = S_k \\wr S_m$ in product action, the generation probability undergoes a sharp phase transition at a critical ratio $\\rho^* = k^*/m^*$ determined by the full maximal subgroup pressure (not just coordinate defects). Specifically, the non-coordinate-defect subgroups of $W_{k,m}$ (arising from the semidirect action of $S_m$ on $S_k^m$) contribute a pressure term that is sublinear in $m$, so that the phase transition location is shifted but not qualitatively changed from the base-group prediction.\n\n**Test:** For $km \\leq 12$, enumerate all maximal subgroups of $W_{k,m}$ using GAP and compute the full pressure. Compare with the coordinate-defect pressure $m \\cdot p(S_k)$. If the full pressure exceeds the coordinate-defect pressure by a multiplicative constant, the phase transition is merely shifted; if it changes the growth rate in $m$, the conjecture needs revision.\n\n**Impact:** Resolves the central motivating problem and establishes the first rigorous phase transition theorem for random generation in a structured permutation group family.\n\n**Catalog References:** `Pythagorean/SubgroupPressure.lean` (pressure definition, product factorization, block-defect formula)\n\n**Proof Strategy:** Classify maximal subgroups of $S_k \\wr S_m$ using O'Nan\u2013Scott theory. Separate into three types: (a) base-group coordinate defects (already handled), (b) \"diagonal\" subgroups from $S_m$-action, (c) \"twisted\" subgroups. Bound the pressure from types (b) and (c) using index estimates from the O'Nan\u2013Scott classification.\n\n**Domain Bridges:** Permutation group theory, O'Nan\u2013Scott classification, computational group theory.\n\n**Lineage:** Direct extension of Theorems 4 and 6 in the current work.\n\n**Ambition:** Grand challenge \u2014 would constitute a major advance in probabilistic group theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "cf039036",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:14:59.768954+00:00"
  },
  {
    "id": "fd_0896",
    "title": "Direction 3: Pressure Theory for Almost Simple Groups",
    "description": "**Conjecture:** For a finite almost simple group $G$ with socle $S$, the pressure from the maximal subgroup family satisfies\n$$\\mathrm{pressure}(G, \\mathcal{M}) = O(|G|^{-\\epsilon})$$\nfor some $\\epsilon > 0$ depending on the type of $S$ (alternating, classical, exceptional, sporadic). This gives $P_{\\text{gen}} \\to 1$ as $|G| \\to \\infty$, recovering the Liebeck\u2013Shalev theorem with explicit rates.\n\n**The key insight is** that the pressure framework provides a systematic way to organize the contribution of each maximal subgroup type (geometric vs. non-geometric in the Aschbacher classification), with the dominant contribution coming from the geometric subgroups of smallest index.\n\n**Why now?** The entropy-energy bounds (Theorems 2\u20133) provide a framework to compute pressure without enumerating all maximal subgroups\u2014bounding the count and minimum index suffices.\n\n**Test:** Compute exact pressure for $\\text{PSL}_2(p)$ for primes $p \\leq 100$ and verify the conjectured decay rate. The maximal subgroups of $\\text{PSL}_2(p)$ are well-known.\n\n**Impact:** Would give the best known explicit bounds on generation probability for classical groups, with direct applications to cryptographic group selection.\n\n**Catalog References:** `Pythagorean/SubgroupPressure.lean` (entropy-energy bounds)\n\n**Proof Strategy:** Use the Aschbacher classification of maximal subgroups of classical groups. For each class, bound the number of subgroups (entropy) and the minimum index (energy). Apply the upper bound theorem: pressure \u2264 |F| / D\u00b2.\n\n**Domain Bridges:** Finite simple group theory, Aschbacher classification, cryptography.\n\n**Lineage:** Applies the general pressure theory to the most important group families.\n\n**Ambition:** Solid extension \u2014 builds directly on established techniques.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "cf039036",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:14:59.812468+00:00"
  },
  {
    "id": "fd_0916",
    "title": "Direction 2: Concentration and Universality of Tropical Critical Distributions",
    "description": "**Conjecture:** For G(n, p) with i.i.d. continuous edge weights on [0,1], the empirical cycle-birth measure \u03bc_G = (1/\u03b2\u2081) \u03a3 \u03b4_{t_i} converges in probability to a deterministic measure \u03bc_p as n \u2192 \u221e. Moreover, the limiting measure \u03bc_p has a density that exhibits a phase transition at p_c = 1/n, with qualitatively different behavior in subcritical and supercritical regimes.\n\n**Test:** (1) Simulate G(n, p=0.15) for n = 50, 100, 200, 500, 1000. Compute the Kolmogorov-Smirnov distance between empirical cycle-birth CDFs across independent trials. If concentration holds, KS distances should decrease as O(n^{-1/2}). (2) For the supercritical regime, fit the limiting density and test universality by varying the weight distribution (uniform, exponential, normal). Reject if the limiting density depends on the weight distribution beyond simple scaling.\n\n**Impact:** Would establish the first universality result connecting tropical geometry to random graph theory, analogous to the Wigner semicircle law in random matrix theory. Would make tropical Morse theory relevant to network science by providing theoretical predictions for real-world weighted networks.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TropicalBridge/TropicalMorseGraphs.lean` \u2014 `filtration_betti1_eq_cycleCount`, `filtration_rank_eq_mergeCount`\n\n**Proof Strategy:** Use the Azuma-Hoeffding inequality or McDiarmid's bounded differences inequality to show concentration of the cycle count process. The key step is bounding the effect of changing a single edge weight on the total cycle count, which changes by at most 1 (Lipschitz condition from the dichotomy theorem). For the limiting measure, use the relationship between cycle events and the structure of the giant component in G(n,p).\n\n**Domain Bridges:** Tropical geometry \u2192 probability theory \u2192 random graphs \u2192 statistical mechanics\n\n**Lineage:** Builds on the computational experiments in Section 5.4 of the research paper.\n\n**Ambition:** Grand challenge \u2014 proving universality of tropical critical distributions would be a major result in probabilistic combinatorics.\n\n**The key insight is** that the edge insertion dichotomy (Theorem 3.1) implies that the cycle count function is 1-Lipschitz in each edge weight, which is exactly the condition needed for concentration inequalities.\n\n**Why now?** The exact relationship between cycle events and connectivity (verified in this work) provides the first rigorous handle for probabilistic analysis. Previous approaches lacked the combinatorial precision to apply concentration tools.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "88770e41",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:39:32.465513+00:00"
  },
  {
    "id": "fd_0918",
    "title": "Direction 4: Tropical Persistence Stability and Network Robustness",
    "description": "**Conjecture:** The tropical Morse data satisfies a stability theorem: if two weight functions w and w' on the same graph satisfy ||w \u2212 w'||_\u221e \u2264 \u03b5, then the corresponding tropical persistence barcodes differ by at most \u03b5 in the bottleneck distance. Consequently, small measurement errors in edge weights produce bounded changes in the topological phase transition spectrum.\n\n**Test:** (1) Perturb edge weights by Gaussian noise with increasing variance and measure the bottleneck distance between original and perturbed barcodes. Verify that the distance grows linearly with perturbation magnitude. (2) Formalize the stability inequality in Lean 4 for graph filtrations, using the tropical-classical persistence equivalence to transfer the classical stability theorem. (3) Reject if there exist graphs where infinitesimal weight perturbation causes unbounded barcode changes (which would indicate ill-conditioning).\n\n**Impact:** Essential for applications. Without stability, the tropical Morse data would be useless for noisy real-world data. A verified stability theorem would make the framework applicable to experimental networks where edge weights are measured with uncertainty.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TropicalBridge/TropicalMorseGraphs.lean` \u2014 `tropical_persistence_eq_classical`\n\n**Proof Strategy:** Via the tropical-classical persistence equivalence (Theorem 3.12), transfer the Bottleneck Stability Theorem for classical persistence (Cohen-Steiner, Edelsbrunner, Harer 2007) to the tropical setting. The key is showing that the tropical persistent rank function is 1-Lipschitz in the sup-norm of weight perturbations.\n\n**Domain Bridges:** Tropical geometry \u2192 topological data analysis \u2192 signal processing \u2192 network science\n\n**Lineage:** Direct consequence of `tropical_persistence_eq_classical` combined with classical stability results.\n\n**Ambition:** Solid extension \u2014 the strategy (transfer via equivalence) is clear, but the formalization requires importing or reproving the classical stability theorem.\n\n**The key insight is** that the tropical-classical persistence equivalence turns stability from a tropical-geometric problem into a classical persistence problem, where stability theorems are already known.\n\n**Why now?** The verified equivalence theorem makes the transfer strategy rigorous. Without it, one would need to prove stability directly in the tropical setting, which lacks established tools.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "88770e41",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:39:32.525739+00:00"
  },
  {
    "id": "fd_0921",
    "title": "Direction 1: Uniform Spectral Gap Bound for GL\u2082(\ud835\udd3d_q)",
    "description": "**Conjecture**: For every prime $q \\geq 5$ and every certified pair $(g, h)$ in $\\text{GL}_2(\\mathbb{F}_q)$ (Singer-like $g$, primitive determinant $h$, generating pair), the spectral gap of $\\text{Cay}(\\text{GL}_2(\\mathbb{F}_q), \\{g, g^{-1}, h, h^{-1}\\})$ satisfies $\\gamma \\geq C/q$ for an absolute constant $C > 0$.\n\n**Test**: Compute spectral gaps for all certified pairs in $\\text{GL}_2(\\mathbb{F}_q)$ for $q \\in \\{5, 7, 11, 13\\}$. If $\\min_{\\text{pairs}} q \\cdot \\gamma$ is bounded below by a positive constant, the conjecture gains credibility. If some pair has $q \\cdot \\gamma < 0.1$, the conjecture needs revision.\n\n**Impact**: A proven uniform bound would yield the first family of explicit 4-regular expanders with certified algebraic witnesses, usable for derandomization and network design without numerical eigenvalue computation.\n\n**Catalog References**: `Catalog/Pythagorean/CertificateExpanders.lean` (harmonic_meanzero_eq_zero, certified_pair_harmonic_trivial), `Catalog/Algebra/MatrixGroupGeneration.lean` (eq_bot_or_top_of_charpoly_irreducible).\n\n**Proof Strategy**: Decompose the regular representation of $\\text{GL}_2(\\mathbb{F}_q)$ into irreducible representations. For each nontrivial irrep $\\rho$, bound $\\|\\frac{1}{4}\\sum_{s \\in S} \\rho(s)\\|$ using the Singer-like property of $g$ (which forces $\\rho(g)$ to have no invariant vectors in nontrivial reps of the natural module) and the primitivity of $\\det(h)$ (which ensures $\\rho$ doesn't factor through the determinant). The key insight is that Singer-like elements act without fixed points on the projective line, giving explicit contraction for the principal series representations.\n\n**Domain Bridges**: Spectral graph theory, number theory (Weil-type character sum bounds), representation theory of reductive groups.\n\n**Lineage**: Extends the qualitative spectral gap (Theorem 6.1 in the research paper) to quantitative bounds.\n\n**Ambition**: Grand challenge \u2014 would unify Bourgain\u2013Gamburd-type expansion with explicit algebraic certification.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ad66d851",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:40:03.296660+00:00"
  },
  {
    "id": "fd_0924",
    "title": "Direction 4: Algorithmic Spectral Certification",
    "description": "**Conjecture**: There exists a polynomial-time algorithm that, given a pair of matrices $(g, h) \\in \\text{GL}_n(\\mathbb{F}_q)$, either certifies that the spectral gap of $\\text{Cay}(\\text{GL}_n(\\mathbb{F}_q), \\{g, g^{-1}, h, h^{-1}\\})$ is at least $\\epsilon$, or reports \"unable to certify\" \u2014 with the guarantee that certified pairs are always genuine expanders.\n\n**Test**: Implement the algorithm for $n = 2$, $q \\in \\{3, 5, 7, 11\\}$. Measure the fraction of generating pairs that pass certification. Compare the certified gap lower bound with the true gap computed by eigenvalue decomposition.\n\n**Impact**: Would make expander verification practical for large groups where eigenvalue computation is infeasible. Applications to network verification, cryptographic protocol validation, and error-correcting code certification.\n\n**Catalog References**: `Catalog/Pythagorean/CertificateExpanders.lean` (the full pipeline from certificate verification to spectral gap).\n\n**Proof Strategy**: The key insight is that checking the Singer-like condition (irreducible charpoly) and primitive determinant is polynomial, and the generation check can be replaced by a probabilistic membership test using the product replacement algorithm. The gap lower bound comes from representation-theoretic estimates that depend only on the certificate data, not on eigenvalue computation.\n\n**Why now?** The formal verification provides a trusted specification against which algorithmic implementations can be validated.\n\n**Domain Bridges**: Computational group theory, algorithm design, complexity theory, network verification.\n\n**Lineage**: Algorithmic counterpart to the theoretical certificate framework.\n\n**Ambition**: Solid extension \u2014 directly applicable engineering.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ad66d851",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:40:03.370751+00:00"
  },
  {
    "id": "fd_0927",
    "title": "Direction 1: Lorentzian Equivalence via Hessian Descent",
    "description": "**Conjecture**: For homogeneous polynomials with positive coefficients, recursive Lorentzianity (in the sense of `IsRecursivelyLorentzian` from `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`) is equivalent to k-fold directional log-concavity of the coefficient function for all k \u2264 degree, together with the support exchange property.\n\n**The key insight is** that the Hessian signature condition (at most one positive eigenvalue) for degree-2 derivative leaves is exactly the mixed directional log-concavity inequality applied to the coefficients of those leaves, and the recursive descent through partial derivatives mirrors the k-fold ratio transform hierarchy.\n\n**Test**: Implement the forward direction for degree \u2264 6: given a recursively Lorentzian polynomial, verify computationally that all coefficient-level mixed and axis inequalities hold. Search for a counterexample to the converse among polynomials with positive coefficients and exchange-closed support that fail the Hessian condition. A single explicit counterexample (n \u2264 5, d \u2264 6) would refute the conjecture.\n\n**Impact**: If true, this provides an elementary characterization of Lorentzian polynomials, replacing the spectral machinery of Hessian eigenvalue analysis with simple product inequalities on coefficients. This would make Lorentzianity checkable in O(n\u00b2 \u00b7 |support|) time rather than requiring eigenvalue computation.\n\n**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (specifically `IsRecursivelyLorentzian`, `recursivelyLorentzian_iff_brandenHuh`, `recursive_certificate_sound`); `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (`KFoldLogConcave`, `kFoldLogConcave_mono`).\n\n**Proof Strategy**: Prove the forward direction by induction on degree. For degree 2, the mixed inequality IS the Hessian condition. For degree d, use `pderiv_coeff_nonneg` to show that partial derivatives preserve coefficient nonnegativity, and show that mixed DLC of the original polynomial implies mixed DLC of its partial derivatives (via a coefficient extraction argument). The converse would require showing that coefficient-level inequalities plus exchange imply the global Hessian condition, likely via the reversed Cauchy-Schwarz (`lorentzian_reversed_cauchy_schwarz`).\n\n**Domain Bridges**: Algebraic geometry (Lorentzian polynomials) \u2194 Discrete combinatorics (exchange properties) \u2194 Linear algebra (Hessian spectra).\n\n**Lineage**: Extends `recursivelyLorentzian_iff_brandenHuh` and connects to `support_rectangle_closure`.\n\n**Ambition**: Grand challenge \u2014 would fundamentally simplify the theory of Lorentzian polynomials.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "a1f92284",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T19:29:17.881900+00:00"
  },
  {
    "id": "fd_0928",
    "title": "Direction 2: Valuated Matroid Theory via k-Fold Log-Concavity",
    "description": "**Conjecture**: The k-fold directional log-concavity hierarchy provides a graded refinement of Murota's M-convexity. Specifically, for a function f on a fixed degree slice with exchange-closed support, the depth k at which f ceases to be k-fold directionally log-concave measures the \"Lorentzian depth\" of the underlying valuated matroid.\n\n**The key insight is** that the ratio transform R\u1d62f(m) = f(m+e\u1d62)/f(m) is the discrete analog of the logarithmic derivative, and applying it repeatedly extracts finer and finer curvature information from the valuation. The k-fold hierarchy thus provides an intrinsic notion of \"smoothness depth\" for valuated matroids, analogous to the differentiability class C^k for continuous functions.\n\n**Why now?** The product stability theorem (`mixedLogConcave_mul`, `directionalLogConcave_mul`) shows that the k-fold classes form multiplicative monoids. Combined with the tropical bridge (`negLog_supermodular_of_mixed`), this means k-fold directional log-concavity defines a hierarchy of tropical convexity classes that is preserved under the tropical product. No such hierarchy existed in Murota's theory.\n\n**Test**: Compute the k-fold depth of specific valuated matroids: uniform matroid valuations, graphical matroid valuations (with edge weights), and the Grassmannian valuations from algebraic geometry. Identify the first example where k-fold depth is finite but greater than 1. If all naturally occurring valuated matroids have infinite depth, this would suggest a deep structural theorem.\n\n**Impact**: Would create a new invariant for valuated matroids, potentially distinguishing matroids that are indistinguishable by existing invariants (basis exchange graph structure, Tutte polynomial, etc.).\n\n**Catalog References**: `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (`KFoldLogConcave`, `KFoldLogConcave.ratio`, `kFoldLogConcave_mono`); `Pythagorean/MultivariateLogConcavity.lean` (`KFoldDirectionalLogConcave`, `kfold_mono`, `directionalLogConcave_mul`).\n\n**Proof Strategy**: Define the Lorentzian depth as sup{k : KFoldDirectionalLogConcave k f}. Use the product stability theorem to show this is sub-additive under tropical convolution. Prove that exponential-type functions have infinite depth (already partially established by `exp_type_mixed_logconcave`). Show that graphic matroid valuations have depth at least d-2 using the connection to Kirchhoff's matrix tree theorem.\n\n**Domain Bridges**: Combinatorial optimization (valuated matroids, M-convexity) \u2194 Analysis (smoothness hierarchies) \u2194 Algebraic geometry (Grassmannian, tropical flag varieties).\n\n**Lineage**: Extends `kfold_mono` and `exp_type_mixed_logconcave`.\n\n**Ambition**: Solid extension with grand-challenge potential.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "a1f92284",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T19:29:17.914245+00:00"
  },
  {
    "id": "fd_0932",
    "title": "Direction 1: Intrinsically Typed Higher-Order Rewriting with \u03b2\u03b7-Completion",
    "description": "**Conjecture:** For the simply-typed \u03bb-calculus with \u03b2\u03b7-reduction, substitution functoriality and rewrite closure extend to the \u03b2\u03b7 setting, and the generated equational theory descends cleanly to \u03b2\u03b7-equivalence classes. Concretely: if `HOEqGen(E, t, u)` and `t ~\u03b2\u03b7 t'`, `u ~\u03b2\u03b7 u'`, then `HOEqGen(E, t', u')` in a theory with \u03b2\u03b7-rules included.\n\n**Test:** Formalize intrinsically typed terms (indexed by context and type) using de Bruijn indices. Prove `subst_comp` and `hoRewrites_closed_under_subst` for typed terms. Then add \u03b7-contraction (`lam(app(rename(\u00b7+1, f), var 0)) \u2192 f`) and verify the \u03b7-commutation lemma: `eta_closed_under_subst`. Check computationally on typed terms up to size 12 that \u03b2\u03b7-normalization commutes with rewriting for orthogonal rule sets.\n\n**Impact:** Intrinsically typed terms would eliminate ill-scoped terms by construction, making the formalization stronger and aligning with the Fiore-Plotkin-Turi framework for abstract syntax. \u03b2\u03b7-completion is strictly more powerful than \u03b2-completion and is required for extensional reasoning about functional programs.\n\n**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (subst_comp, beta_closed_under_subst, liftSubst_compSubst); `Pythagorean/ConcreteTermAlgebra.lean` (FOTerm.subst_comp as the first-order prototype).\n\n**Proof Strategy:** Start with the Autosubst-style approach: define a universe of types, index terms by `(Ctx, Ty)`, and derive the substitution lemmas mechanically. The \u03b7 case requires proving `subst(lam(app(rename(\u00b7+1, f), var 0)), \u03c3) = subst(f, \u03c3)` when f has appropriate type, which reduces to showing `liftSubst(\u03c3)(1) = rename(\u00b7+1)(\u03c3(0))` \u2014 a definitional equality.\n\n**Domain Bridges:** Type theory (intrinsic typing), categorical semantics (presheaves over contexts), proof automation (extensional simplification).\n\n**Lineage:** Direct extension of the current work's substitution calculus.\n\n**Ambition:** Solid extension \u2014 builds directly on verified infrastructure with clear proof path.\n\n**\"The key insight is...\"** that \u03b7-contraction is the *semantic* counterpart of \u03b2-reduction \u2014 where \u03b2 says \"functions compute,\" \u03b7 says \"things that compute like functions *are* functions\" \u2014 and the substitution calculus we have already verified handles both uniformly once the commutation lemma is established.\n\n**\"Why now?\"** The substitution infrastructure (11 lemmas from `liftRen_id` through `subst_comp`) is now verified and battle-tested. Extending to \u03b7 requires exactly one new commutation lemma and one new lifting property, both following the established pattern.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2933a8cf",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T20:01:51.820906+00:00"
  },
  {
    "id": "fd_0933",
    "title": "Direction 2: Higher-Order Critical Pairs and Knuth-Bendix Completion Modulo \u03b2",
    "description": "**Conjecture:** For finite, left-linear, simply-typed higher-order rewrite systems with no critical pairs up to \u03b2-normalized matching on terms of size \u2264 N, the generated \u03b2-aware one-step relation is locally confluent on all closed terms of size \u2264 N. Moreover, a decidable criterion for the absence of critical pairs exists for the class of higher-order pattern rewrite systems (in the sense of Miller).\n\n**Test:** Implement higher-order unification for Miller patterns. Enumerate all overlaps between pairs of rules in a given system. For each overlap, compute the critical pair and attempt to join it. Test on benchmark systems: map fusion, fold/build fusion, CPS transformation rules. Report the first system size at which a non-joinable critical pair appears (if any).\n\n**Impact:** A working higher-order Knuth-Bendix procedure would be a major advance in automated reasoning, enabling certified completion for equational theories of functional programs. Even a bounded version with correctness guarantees would be immediately useful.\n\n**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (HoRewrite, hoRewrites_closed_under_subst \u2014 the closure property is essential for the completion step); `Pythagorean/ConcreteTermAlgebra.lean` (concrete_completion_correct \u2014 the first-order completion correctness theorem that we aim to lift).\n\n**Proof Strategy:** Define `CriticalPair(E)` as the set of pairs `(s, t)` arising from non-trivial overlaps of rules in E. Prove: if `CriticalPair(E)` is empty (up to \u03b2), then `HoRewrite(E)` is locally confluent. The proof uses `hoRewrites_closed_under_subst` to show that overlapping reductions can be completed. For the algorithmic part, implement Miller's higher-order pattern unification and verify it against the matching function.\n\n**Domain Bridges:** Automated theorem proving (completion procedures), unification theory (higher-order unification), compiler optimization (certified rule derivation).\n\n**Lineage:** Lifts the first-order completion correctness theorem to higher order.\n\n**Ambition:** Grand challenge \u2014 higher-order completion modulo \u03b2 is a known open problem in its full generality.\n\n**\"The key insight is...\"** that the closure theorems we have verified (`hoRewrites_closed_under_subst`, `hoRewrites_closed_under_context`) are exactly the properties needed to make the Knuth-Bendix completion step valid at higher order \u2014 the rest is \"just\" unification and critical pair analysis.\n\n**\"Why now?\"** The formal infrastructure for higher-order rewrite closure is now in place. The bottleneck has shifted from *closure properties* (solved) to *unification and overlap detection* (tractable with Miller patterns).\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2933a8cf",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T20:01:51.853060+00:00"
  },
  {
    "id": "fd_0934",
    "title": "Direction 3: Certified Stream Fusion via Higher-Order Completion",
    "description": "**Conjecture:** The stream fusion transformation (converting recursive list operations to stream operations and then to tight loops) can be expressed as a finite set of higher-order rewrite rules, and the resulting system is confluent modulo \u03b2 on well-typed terms. The \u03b2-normal form of any term in the generated theory corresponds to the fused program.\n\n**Test:** Encode the GHC stream fusion rules (stream/unstream, map/stream, filter/stream, foldr/build) as higher-order equations. Apply bounded completion. Check that all critical pairs join. Benchmark the resulting rewriting system against GHC's actual fusion behavior on 20 benchmark programs from the nofib suite.\n\n**Impact:** Stream fusion is one of the most important optimizations in Haskell, but its correctness has never been formally established at the equational level. A certified higher-order rewriting approach would provide the first machine-checked correctness proof for a production compiler optimization.\n\n**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (mapFusionEq, map_fusion_in_theory \u2014 the map fusion example demonstrates the approach); `Pythagorean/ConcreteTermAlgebra.lean` (rewrites_closed_under_subst_and_context \u2014 the closure property that makes rule application correct).\n\n**Proof Strategy:** Define stream type as `Stream a = \u2203s. (s \u2192 Step a s, s)` in the STLC (using existential encoding). Express stream fusion as rewrite rules. Use `hoRewrites_closed_under_subst` to verify that rule application is sound. Apply `subst_comp` to verify that composed transformations equal single-pass transformations.\n\n**Domain Bridges:** Compiler optimization (GHC), functional programming (deforestation), performance engineering.\n\n**Lineage:** Extends the map fusion example to a full optimization framework.\n\n**Ambition:** Solid extension with high practical impact.\n\n**\"The key insight is...\"** that stream fusion is not just a *specific* optimization but an *equational theory* \u2014 a set of higher-order equations whose closure under substitution and contexts (exactly what we've verified) generates all valid fusion transformations.\n\n**\"Why now?\"** Map fusion is already formalized as a higher-order equation in our framework. Stream fusion is a systematic generalization requiring the same infrastructure at larger scale.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2933a8cf",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T20:01:51.882080+00:00"
  },
  {
    "id": "fd_0938",
    "title": "Direction 2: Valuated Matroid Equivalence",
    "description": "**Conjecture:** The weighted tropical kernel on S is isomorphic (as a tropical linear space) to the tropical linear space of a valuated graphic matroid M(G) restricted to S-indexed constraints. The weight function w defines the valuation on circuits.\n\n**The key insight is** that the tropical balance condition at each vertex defines a tropical hyperplane in the space of potentials, and the intersection of these hyperplanes is a tropical linear space whose combinatorial type is determined by the valuated matroid of the graph.\n\n**Why now?** The Dress-Wenzel theory of valuated matroids has matured significantly, with recent algorithmic advances in tropical linear algebra. The explicit cycle balance identity (Theorem 3.1) provides the concrete bridge: the valuation of a circuit is the alternating sum of edge weights around the cycle.\n\n**Test:** For the complete graph K\u2084 with various weight functions, compute the tropical linear space of the valuated graphic matroid and compare with the weighted tropical kernel. Agreement would confirm the equivalence.\n\n**Impact:** Would place weighted tropical graph Hodge theory within the established framework of tropical linear spaces, enabling the use of powerful tools from tropical intersection theory.\n\n**Catalog References:** `Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (Theorem 3.1, cycle balance transport).\n\n**Proof Strategy:** Construct the valuated matroid from the weighted graph. Show the tropical Pl\u00fccker relations correspond to the balance conditions. Use the Dress-Wenzel axioms to verify the matroid structure.\n\n**Domain Bridges:** Tropical algebraic geometry, matroid theory, polyhedral combinatorics.\n\n**Lineage:** Extends Dress-Wenzel [1992], Murota [2003].\n\n**Ambition:** Grand challenge \u2014 would establish a foundational bridge between discrete Hodge theory and tropical linear algebra.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "e8f8d5e4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T20:35:38.468806+00:00"
  },
  {
    "id": "fd_0939",
    "title": "Direction 3: Algorithmic Tropical Kernel Computation",
    "description": "**Conjecture:** The weighted tropical kernel dimension can be computed in polynomial time O(|V|\u00b3 \u0394) for graphs with maximum degree \u0394, by reduction to a system of tropical linear inequalities.\n\n**The key insight is** that the tropical balance condition at each vertex is a tropical linear constraint, and the tropical kernel is the solution set of a tropical linear system. Tropical linear programming (Butkovi\u010d, Gaubert) provides polynomial-time algorithms for such systems.\n\n**Why now?** Tropical linear algebra has recently developed efficient algorithms for feasibility of tropical linear systems. The explicit structure of the weighted graph Laplacian (sparse, structured coefficients) should enable specialized algorithms faster than general-purpose tropical LP.\n\n**Test:** Implement a tropical LP-based kernel dimension algorithm and compare runtime/output with brute-force enumeration on graphs with n = 5-10. Polynomial scaling would confirm the conjecture.\n\n**Impact:** Would make weighted tropical Hodge theory computationally practical for real-world networks (power grids, routing networks) with thousands of vertices.\n\n**Catalog References:** `Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (Definition 2.3, balance condition structure).\n\n**Proof Strategy:** Formulate balance conditions as tropical linear inequalities. Apply tropical Cramer's rule or tropical LP algorithms. Exploit graph sparsity for speedup.\n\n**Domain Bridges:** Combinatorial optimization, tropical linear programming, network algorithms.\n\n**Lineage:** Extends Butkovi\u010d [2010], Gaubert-Katz [2007].\n\n**Ambition:** Solid extension \u2014 would bridge theory to practice.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Tropical",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "e8f8d5e4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T20:35:38.492371+00:00"
  },
  {
    "id": "fd_0943",
    "title": "Direction 1: Characterization of Lorentzian Ground-State Families",
    "description": "**Conjecture:** For stoquastic local Hamiltonians on n sites with bounded local dimension and bounded interaction range, the ground-state coefficient vector (in the occupation-number basis) forms the coefficient family of a Lorentzian polynomial of degree O(n). The certificate depth scales as O(n \u00b7 polylog(n)).\n\n**Test:** For the transverse-field Ising model on chains n \u2264 20, compute the ground state via exact diagonalization, extract the coefficient vector, and test Lorentzianity by checking all degree-2 derivative Hessians for the at-most-one-positive-eigenvalue condition. Record the fraction of parameter space (J, h) for which the condition holds.\n\n**Impact:** This would identify the exact boundary of applicability for certificate-driven quantum state preparation, replacing the current assumption that Lorentzianity holds with a proved characterization.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (IsRecursivelyLorentzian, RecursiveLorentzianCertificate), `Catalog/Pythagorean/CertificateSampling.lean` (certificate_verification_complexity)\n\n**Proof Strategy:** Induction on system size n. For the TFIM, use the transfer matrix formulation to express ground-state amplitudes as products of 2\u00d72 matrices, then verify the Hessian condition on the resulting polynomial. The key technical step is showing that the transfer matrix product preserves the Lorentzian property of the coefficient family.\n\n**Domain Bridges:** Condensed matter physics (Perron\u2013Frobenius theory), statistical mechanics (transfer matrices), combinatorial optimization (QUBO formulations as stoquastic Hamiltonians)\n\n**Lineage:** Builds on Br\u00e4nd\u00e9n\u2013Huh [2020] characterization of Lorentzian polynomials and Bravyi\u2013Gosset [2017] complexity of stoquastic systems.\n\n**Ambition:** Grand challenge \u2014 establishing a complete characterization would be a major theorem in mathematical physics.\n\n**The key insight is** that transfer matrix structure may enforce Lorentzianity automatically for nearest-neighbor stoquastic Hamiltonians, because the matrix product preserves strong log-concavity.\n\n**Why now?** The formal framework for recursive Lorentzian certificates now exists (LorentzianRecognitionComplete.lean), and computational tools for testing Hessian signatures are available for n \u2264 20.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2b6d84b4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:13:09.676387+00:00"
  },
  {
    "id": "fd_0944",
    "title": "Direction 2: Robust Certificate Compilation for Approximate Lorentzianity",
    "description": "**Conjecture:** If a nonneg coefficient vector w is \u03b5-close (in total variation distance) to the coefficient vector of a Lorentzian polynomial, then the compiled preparation tree produces a state with fidelity \u2265 1 - O(\u03b5\u00b2) against the true normalized coefficient state.\n\n**Test:** Perturb known Lorentzian coefficient families (e.g., binomial coefficients, matroid basis counts) by random nonneg noise of magnitude \u03b5, compile the perturbed family, and measure fidelity as a function of \u03b5. Test for \u03b5 \u2208 {0.001, 0.01, 0.05, 0.1}.\n\n**Impact:** Extends certificate compilation from exact to approximate settings, vastly increasing applicability to real physical systems where exact Lorentzianity may not hold.\n\n**Catalog References:** `Pythagorean/QuantumGroundStatePreparation.lean` (coeffState_normalized, coeffState_unique), `Catalog/Pythagorean/CertificateSampling.lean` (certificate_sampling_efficiency)\n\n**Proof Strategy:** Use the uniqueness theorem (coeffState_unique) to establish continuity of the compilation map, then bound the fidelity loss using the triangle inequality for L\u00b2 distance and the Lipschitz constant of normalization.\n\n**Domain Bridges:** Approximation theory, numerical stability analysis, quantum error analysis\n\n**Lineage:** Extension of exact certificate compilation (this work) to the robust setting.\n\n**Ambition:** Solid extension \u2014 the mathematical tools are largely available, but the quantitative bounds require careful analysis.\n\n**The key insight is** that L\u00b2 normalization is a Lipschitz map on the positive orthant, so small perturbations to coefficients yield small perturbations to the quantum state.\n\n**Why now?** The exact correctness theorems provide the foundation; the robust extension is the natural next step.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2b6d84b4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:13:09.706179+00:00"
  },
  {
    "id": "fd_0951",
    "title": "Direction 3: Sheaf-Theoretic Tropical Persistence",
    "description": "**Conjecture:** The tropical persistence barcode can be realized as the derived pushforward of a constructible sheaf on the real line, valued in the category of tropical semimodules. The stability theorem then follows from the properness of the pushforward and the continuity of the derived functor, providing a conceptual explanation for the degree-dependent constant.\n\n**Test:** Construct the sheaf explicitly for path graphs and cycle graphs. Verify that the stalk at each point t equals the tropical kernel dimension. Check that the derived pushforward reproduces the event profile.\n\n**Impact:** This would connect tropical persistence to the rapidly developing theory of persistent sheaves (Curry, Kashiwara\u2013Schapira), opening access to powerful tools from algebraic geometry and microlocal analysis. It would also suggest natural higher-dimensional generalizations.\n\n**Catalog References:** `Pythagorean/TropicalBridge/Stability.lean` (tropicalEventProfile, TPB), `Catalog/Pythagorean/TropicalBridge/FiltrationPersistence.lean` (TropicalFiltration)\n\n**Proof Strategy:** Define the sheaf F on \u211d with stalks F_t = tropical kernel of G[activeVertices(f,t)]. The restriction maps are the natural inclusions. Constructibility follows from the finite number of critical values (entrance times). The pushforward to a point gives the global sections, which encode the barcode.\n\n**Domain Bridges:** Sheaf theory, derived categories, algebraic geometry, microlocal analysis\n\n**Lineage:** Conceptual reformulation of the entire stability framework\n\n**Ambition:** Grand challenge \u2014 would place tropical persistence in the mainstream of modern geometry\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "834b245c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:13:42.015713+00:00"
  },
  {
    "id": "fd_0957",
    "title": "Direction 3: Renormalization Group for Subgroup Ensembles",
    "description": "**Conjecture:** There exists a coarse-graining map $\\mathcal{R}$ on subgroup ensembles such that:\n1. $\\mathcal{R}$ maps the pressure to a scaled version: $\\Pi(\\mathcal{R}(\\mathcal{H})) = \\lambda \\cdot \\Pi(\\mathcal{H})$ for some $\\lambda > 0$.\n2. Fixed points of $\\mathcal{R}$ correspond to universality classes.\n3. The linearization of $\\mathcal{R}$ at a fixed point has eigenvalues that determine critical exponents.\n\n**Test:** For $S_n$ with $n = 2^k$ (powers of 2), define $\\mathcal{R}$ by passing from maximal subgroups of $S_{2^k}$ to those of $S_{2^{k-1}}$ via restriction. Compute the pressure at each scale and test for fixed-point convergence.\n\n**Impact:** This would bring the full power of renormalization group theory into finite algebra, potentially classifying all universality classes for finite group generation.\n\n**Catalog References:** `Pythagorean/SubgroupUniversality.lean` (all theorems), `Catalog/old/Pythagorean/SubgroupPressure.lean` (product factorization as coarse-graining precursor).\n\n**Proof Strategy:** Define $\\mathcal{R}$ as restriction to a quotient or block structure. For direct products, $\\mathcal{R}$ simply selects one factor, and the fixed point is the single-factor pressure. Prove that the eigenvalue spectrum of the linearization determines the exponent.\n\n**Domain Bridges:** Quantum field theory (Wilson's renormalization group), dynamical systems (iterated function systems), ergodic theory (transfer operators), topology (scaling limits).\n\n**Lineage:** Extends `freeEnergy_directPower` to a dynamical framework where extensivity is one consequence of a deeper fixed-point structure.\n\n**Ambition:** \ud83d\udd34 Grand Challenge \u2014 paradigm-shifting. Would unify algebraic generation theory with one of the most powerful frameworks in theoretical physics.\n\nThe key insight is that the extensivity theorem $F(m,t) = m \\cdot F(1,t)$ can be reinterpreted as a fixed-point equation: the free energy per factor is invariant under the \"add one more copy\" operation, which is the simplest renormalization group transformation.\n\nWhy now? The proven extensivity and exponent additivity theorems provide the first mathematical evidence that a fixed-point structure exists. Without these, the renormalization program would be purely speculative.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "354ccda2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:49:45.129187+00:00"
  },
  {
    "id": "fd_0961",
    "title": "Direction 2: Differentiable Tropical Morse Features for End-to-End Learning",
    "description": "**Conjecture:** The tropical Morse spectrum, while piecewise-constant in edge weights, admits a smooth relaxation via the soft-min function: replacing the hard threshold t with a temperature-parameterized sigmoid produces a differentiable approximation whose gradient has O(E) sparsity and O(E log E) computation time.\n\n**Test:** (1) Implement the soft-TMS with temperature parameter \u03c4. (2) Verify that as \u03c4 \u2192 0, soft-TMS \u2192 hard TMS. (3) Train a GNN on MUTAG with soft-TMS features; compare test accuracy against standard GNN and GNN + hard-TMS. (4) Falsified if soft-TMS gradients are dense (O(E\u00b2) nonzeros) or if convergence requires \u03c4 \u2192 0 faster than O(1/\u221aepoch).\n\n**Impact:** Would enable fully differentiable training of GNNs with topological features, resolving the main practical barrier to adoption.\n\n**Catalog References:**\n- `Pythagorean/TropicalMorse/Theorems.lean`: `sublevel_perturbation_containment` (stability foundation)\n- `Pythagorean/TropicalMorse/Defs.lean`: `sublevelAdj` (threshold mechanism to relax)\n\n**Proof Strategy:** Define soft-sublevel adjacency: softAdj(G, t, i, j) = \u03c3((t - w(i,j))/\u03c4) where \u03c3 is the sigmoid. Show that the soft Betti numbers are differentiable in w and t, with Lipschitz constant 1/\u03c4. Use the stability theorem to bound the approximation error.\n\n**Domain Bridges:** Optimization theory \u2194 Tropical geometry \u2194 Deep learning\n\n**Lineage:** Extends stability theorem + connects to differentiable rendering literature\n\n**Ambition:** Solid extension \u2014 engineering challenge with clear theoretical grounding\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "db7ef9c7",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:51:37.153172+00:00"
  },
  {
    "id": "fd_0965",
    "title": "Direction 1: Tight Lorentzian Stability Radii for Matroid Families",
    "description": "**Conjecture:** For the uniform matroid $U_{r,n}$, the exact Lorentzian stability radius (maximum coefficient perturbation preserving Lorentzianity of the generating polynomial) is $\\Theta(\\binom{n}{r}^{-1} \\cdot \\lambda_{\\min}^{\\text{gap}})$, where $\\lambda_{\\min}^{\\text{gap}}$ is the minimum normalized Hessian eigengap across all quadratic leaves.\n\n**Test:** Compute the exact stability radius for $U_{r,n}$ with $n \\leq 15$ by binary search over perturbation magnitudes, checking Lorentzianity via eigenvalue computation on all $\\binom{n}{2}$ quadratic leaves. Compare to the predicted formula. Discrepancies of more than 10% in the ratio would refute the conjecture.\n\n**Impact:** Tight stability radii would replace the conservative factor-of-2 bound in `certifyNoisySLC` with optimal constants, potentially doubling the effective robustness radius for practical applications.\n\n**Catalog References:** `Catalog/Pythagorean/RobustLorentzianSampling.lean` (Theorem `residual_gap_of_perturbation`); `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (Theorem `lorentzian_stability_radius_exists`).\n\n**Proof Strategy:** For the upper bound, construct explicit perturbation families that destroy Lorentzianity at the predicted threshold. For the lower bound, use the Hessian eigenvalue structure of the elementary symmetric polynomial to compute the exact quadratic form bound implied by coefficient perturbation.\n\n**Domain Bridges:** Combinatorial optimization (matroid intersection algorithms), algebraic combinatorics (Schur positivity and symmetric function theory).\n\n**Lineage:** Direct extension of `residual_gap_of_perturbation` from this cycle. The uniform matroid case is the canonical test bed.\n\n**Ambition:** Solid extension \u2014 this is a concrete computation grounded in existing theory, but the exact formula would be new and useful.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2953ee13",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:25:38.908872+00:00"
  },
  {
    "id": "fd_0967",
    "title": "Direction 3: Information-Theoretic Monotonicity for Robustly Lorentzian Measures",
    "description": "**Conjecture:** For a robustly Lorentzian distribution $\\mu$ on subsets of $[n]$ with spectral gap $\\varepsilon$, and any coordinate projection $\\pi : [n] \\to [n-1]$ (deleting one element), the entropy of the pushed-forward marginal satisfies:\n$$H(\\pi_*\\mu) \\geq H(\\mu) - \\log(1/\\varepsilon) + O(1)$$\nMoreover, the mutual information between any pair of coordinates $i, j$ is bounded by $O(1/\\varepsilon)$.\n\n**The key insight is** that the Lorentzian gap controls information-theoretic quantities \u2014 entropy, mutual information, data processing \u2014 in the same way that spectral gap controls mixing. This would create a formal dictionary between algebraic geometry and information theory.\n\n**Why now?** The robust Rayleigh inequality (Theorem 2) provides quantitative control on pairwise correlations, which is the starting point for entropy bounds via Shearer's lemma and the entropy chain rule. The formalized infrastructure for quadratic form bounds enables a clean inductive argument.\n\n**Test:** For uniform matroid distributions with varying gap, compute the exact entropy of coordinate marginals and compare to the predicted bound. Verify the mutual information scaling by computing pairwise correlations.\n\n**Impact:** Establishes a new bridge between discrete Hodge theory and information theory. Would provide data-processing inequalities for Lorentzian distributions, with applications to privacy (differential privacy for strongly log-concave mechanisms) and communication complexity.\n\n**Catalog References:** `Catalog/Pythagorean/RobustLorentzianSampling.lean` (Theorem `robust_quadform_negativity`).\n\n**Proof Strategy:** Use the quantitative Rayleigh inequality to bound the conditional variance of each coordinate given the others. Apply the entropy-variance inequality (Efron-Stein type) to convert to entropy bounds. The induction is on the number of coordinates being projected out.\n\n**Domain Bridges:** Information theory (channel capacity, data processing inequality), quantum information (entanglement entropy of free-fermionic systems), differential privacy (sensitivity of log-concave mechanisms).\n\n**Lineage:** Extension of the Rayleigh-type inequality from this cycle into the information-theoretic domain.\n\n**Ambition:** Grand challenge \u2014 this bridges algebraic geometry to information theory in a way that has not been formalized before.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2953ee13",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:25:38.967457+00:00"
  },
  {
    "id": "fd_0968",
    "title": "Direction 4: Robust Log-Concavity for Quantum Many-Body Ground States",
    "description": "**Conjecture:** For a class of quantum spin systems whose ground-state marginals (on computational basis measurements) correspond to strongly log-concave distributions, the Lorentzian gap of the marginal generating polynomial is bounded below by the spectral gap of the parent Hamiltonian, up to polynomial factors.\n\n**The key insight is** that quantum spectral gaps (energy gaps above the ground state) and classical spectral gaps (mixing rates of Glauber dynamics on measurement outcomes) are related through the Lorentzian structure of the ground-state wavefunction. If the ground state's measurement distribution is Lorentzian, the quantum gap controls the classical gap.\n\n**Why now?** Free-fermionic systems and matchgate circuits produce distributions that are known to be strongly log-concave (their generating polynomials are determinantal, hence Lorentzian). The robustness results from this cycle enable extension to *perturbed* quantum systems \u2014 systems that are approximately free-fermionic.\n\n**Test:** Simulate ground states of the 1D transverse-field Ising model (a well-understood system with an exact solution via Jordan-Wigner transformation). Compute the Lorentzian gap of the measurement distribution as a function of the transverse field strength and compare to the known quantum spectral gap.\n\n**Impact:** Would provide the first formal connection between Lorentzian polynomials and quantum many-body physics. Could enable certified classical simulation of measurement distributions for quantum systems near free-fermionic points.\n\n**Catalog References:** `Catalog/Pythagorean/RobustLorentzianSampling.lean` (Theorem `gibbs_pointwise_ratio_bound` for the perturbation framework).\n\n**Proof Strategy:** For free-fermionic systems, the generating polynomial is a determinant of a matrix of single-particle amplitudes. Use the known relationship between the many-body spectral gap and the single-particle gap to bound the Hessian eigengap of the determinantal polynomial.\n\n**Domain Bridges:** Quantum computing (certifiable classical simulation), condensed matter physics (gapped phases and topological order), quantum chemistry (fermionic Gaussian states).\n\n**Lineage:** Extends the Gibbs perturbation bridge from this cycle to the quantum setting, where the \"energy function\" is a Hamiltonian.\n\n**Ambition:** Grand challenge \u2014 connects two major theoretical frameworks (Lorentzian polynomials and quantum many-body theory) that have developed independently.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2953ee13",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:25:38.995692+00:00"
  },
  {
    "id": "fd_0969",
    "title": "Direction 5: Continuous Extension via Discretization with Certified Error Bounds",
    "description": "**Conjecture:** For log-concave measures $\\mu$ on $\\mathbb{R}^n$ (satisfying an isoperimetric inequality with constant $\\psi$), a discretization on a grid of spacing $h$ produces a discrete distribution whose Lorentzian stability radius is at least $\\Omega(\\psi \\cdot h)$, with mixing time of the discrete Glauber chain bounded by $O(n \\log(1/\\eta) / (\\psi - O(h)))$.\n\n**The key insight is** that the isoperimetric constant of a continuous log-concave measure is the analogue of the Lorentzian gap in the discrete setting. Discretization introduces a perturbation proportional to the grid spacing, and the robustness transfer principle should absorb this perturbation.\n\n**Why now?** The iterated perturbation theorem (Theorem 4) handles accumulated noise from multiple sources, and discretization error is naturally decomposed into per-cell contributions. The formalized infrastructure for quadratic form bounds on sums of perturbations enables a clean treatment.\n\n**Test:** For the standard Gaussian on $\\mathbb{R}^2$, discretize on grids of varying spacing $h$ and measure: (a) the coefficient distance between the discretized distribution and the exact discretized distribution; (b) the mixing time of Glauber dynamics on the discretized support; (c) the predicted bound from the robustness theory. Verify convergence as $h \\to 0$.\n\n**Impact:** Extends the entire Lorentzian robustness framework to continuous distributions, vastly expanding its applicability. Would provide the first certified discretization error bounds for MCMC algorithms on log-concave distributions.\n\n**Catalog References:** `Catalog/Pythagorean/RobustLorentzianSampling.lean` (Theorem `iterated_perturbation_gap`).\n\n**Proof Strategy:** Model discretization as a coefficient perturbation of the exact discrete distribution. Bound the perturbation using the Lipschitz constant of the continuous density (controlled by the isoperimetric constant). Apply the iterated perturbation theorem with $k$ = number of grid cells and $\\delta$ = per-cell discretization error.\n\n**Domain Bridges:** Numerical analysis (discretization theory), optimization (sampling from log-concave distributions), Bayesian statistics (MCMC convergence certificates).\n\n**Lineage:** Direct extension of the iterated perturbation stability from this cycle to the continuous setting via discretization.\n\n**Ambition:** Solid extension with high practical impact \u2014 discretization is the universal bottleneck for applying discrete theory to continuous problems.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2953ee13",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:25:39.023118+00:00"
  },
  {
    "id": "fd_0971",
    "title": "Direction 2: Moment Method Attack on the Random Cayley Expander Conjecture",
    "description": "**Conjecture:** For random \u03c3, \u03c4 \u2208 S_n conditioned on \u27e8\u03c3,\u03c4\u27e9 = S_n, the quantity\n\n(1/n!) \u00b7 tr(A^(2k)) - 1\n\nis O(1) for fixed k as n \u2192 \u221e, where A is the normalized adjacency matrix of Cay(S_n, {\u03c3\u00b11, \u03c4\u00b11}).\n\n**Test:** Compute tr(A^(2k)) for k = 2, 3, 4 across 100+ random generating pairs for n = 5, 6, 7, 8 and verify uniform boundedness. Then formalize the combinatorial identity linking tr(A^(2k)) to the count of closed walks of length 2k in the Cayley graph, expressible as a sum over word representations.\n\n**Impact:** The moment method is the primary technique for proving spectral gap bounds in random matrix theory. A formalized version for Cayley graphs would open a path to the full Random Cayley Expander Conjecture.\n\n**The key insight is** that tr(A^(2k)) counts the number of elements g \u2208 G representable as a product s\u2081s\u2082...s_{2k} with each s\u1d62 \u2208 S and the product equal to the identity. For random generators of S_n, this count can be analyzed using the cycle structure of permutations and the representation theory of S_n.\n\n**Why now?** The representation theory of S_n is well-developed in Mathlib (Young tableaux, characters), and the combinatorial closed-walk counting can be bootstrapped from the word-reachability theorem proved in this cycle.\n\n**Catalog References:** `Pythagorean/CayleyExpander/Connectivity.lean` (word_in_generators_of_mem_closure), `Algebra/SymmGroupGen/Basic.lean` (symmetric group structure).\n\n**Proof Strategy:** Express tr(A^(2k)) as \u03a3_{\u03c7 irreducible} dim(\u03c7) \u00b7 (\u03a3_{s\u2208S} \u03c7(s)/d)^{2k}. Use representation-theoretic bounds on character sums for random elements of S_n.\n\n**Domain Bridges:** Random matrix theory (mathematics), quantum information theory (physics), representation theory (algebra).\n\n**Lineage:** Extends the trace-method computational experiments of this cycle into a formal asymptotic framework.\n\n**Ambition:** Grand challenge \u2014 this direction, if successful, would essentially prove the Random Cayley Expander Conjecture.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "8778f4a5",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:58:43.501683+00:00"
  },
  {
    "id": "fd_0972",
    "title": "Direction 3: Spectral Expansion for Matrix Groups and Arithmetic Quotients",
    "description": "**Conjecture:** For G = SL_2(F_p) with p prime and generators \u03c3, \u03c4 chosen uniformly conditioned on generation, the spectral gap of Cay(G, {\u03c3\u00b11, \u03c4\u00b11}) is \u03a9(1) with high probability.\n\n**Test:** Implement the construction for SL_2(F_p) for small primes p = 5, 7, 11, 13. Compute spectral gaps and compare with the Ramanujan bound 2\u221a(q-1)/q for q-regular graphs.\n\n**Impact:** This would connect the Cayley expander framework to the Langlands program and property (\u03c4) for arithmetic groups, opening formal verification to one of the deepest areas of modern mathematics.\n\n**The key insight is** that the spectral theory of matrix groups over finite fields is intimately connected to automorphic forms and L-functions. The Ramanujan conjecture for GL_2, proved by Deligne, gives optimal spectral gap bounds for certain Cayley graphs of SL_2(F_p) \u2014 the Ramanujan graphs of Lubotzky\u2013Phillips\u2013Sarnak.\n\n**Why now?** The framework of CayleySpectralData and the zero-energy rigidity theorem extend verbatim to any finite group. The key new ingredient is the representation theory of SL_2(F_p), which is classical and could be formalized incrementally.\n\n**Catalog References:** `Pythagorean/CayleyExpander/Defs.lean` (CayleySpectralData \u2014 works for any finite group), `Pythagorean/CayleyExpander/Connectivity.lean` (all theorems are polymorphic in G).\n\n**Proof Strategy:** Use the Bourgain\u2013Gamburd expansion machine (sum-product theorem \u2192 growth \u2192 spectral gap) adapted to the formal setting.\n\n**Domain Bridges:** Number theory (Ramanujan conjecture), Langlands program (automorphic forms), quantum computing (SL_2 gates).\n\n**Lineage:** Extends the S_n specialization (Theorem 4) to matrix groups, the natural next family.\n\n**Ambition:** Grand challenge \u2014 would represent a major advance in formal arithmetic.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "8778f4a5",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:58:43.526680+00:00"
  },
  {
    "id": "fd_0979",
    "title": "Direction 5: Formal BGT Structure Theorem",
    "description": "**Conjecture:** The full Breuillard\u2013Green\u2013Tao classification of approximate subgroups in finite simple groups of Lie type can be formalized in Lean 4, building on the certificate-to-growth infrastructure developed in this cycle.\n\n**Test:** Formalize the statement of the BGT theorem for $\\mathrm{SL}(2, \\mathbb{F}_p)$: every $K$-approximate subgroup $A$ (i.e., $|A^3| \\leq K|A|$) is contained in a set of the form $xH$ where $H$ is a subgroup and $|xH| \\leq f(K)|A|$. Then prove the theorem for $K$ close to 1 using the Strict Growth Theorem.\n\n**The key insight is** that the Strict Growth Theorem already proves the $K = 1$ case: if $|A^3| = |A|$ (so $K = 1$) and $A$ generates $G$ and $1 \\in A$, then $A = G$ (since $A = A^2 = A^3 = \\cdots = G$ by strict growth). The BGT theorem generalizes this to $K > 1$, showing that approximate closure under tripling forces algebraic structure. Our formal infrastructure provides the foundation for this generalization.\n\n**Why now?** The formal proof of the Core Stability Theorem demonstrates that the key technique \u2014 using finite injectivity to establish group-like properties of finite sets \u2014 is formalizable. The BGT proof uses similar techniques at a higher level of abstraction, combined with the classification of finite simple groups. While the full classification is out of reach, the $\\mathrm{SL}(2)$ case is tractable and would demonstrate the approach.\n\n**Impact:** A formally verified BGT theorem, even in the $\\mathrm{SL}(2)$ case, would be a major achievement in formal combinatorics and would validate the certificate-to-growth paradigm at the deepest level.\n\n**Catalog References:** `Pythagorean/CertificateProductGrowth.lean` (all theorems from the current cycle), `Catalog/Pythagorean/CertificateExpanders.lean` (spectral machinery), `Catalog/Algebra/MatrixGroupGeneration.lean` (matrix group structure).\n\n**Proof Strategy:** Following Helfgott (2008) for $\\mathrm{SL}(2, \\mathbb{F}_p)$: (1) Use the trace map to reduce to a sum-product problem in $\\mathbb{F}_p$. (2) Apply sum-product estimates (Bourgain\u2013Katz\u2013Tao) to show that the trace of $A$ cannot concentrate. (3) Use non-concentration to derive growth via escape from subvarieties. Each step can be decomposed into lemmas amenable to formal verification.\n\n**Domain Bridges:** Additive combinatorics (sum-product estimates), algebraic geometry (subvarieties), representation theory (trace maps), classification of finite simple groups.\n\n**Lineage:** Culmination of the certificate-to-growth program initiated in this cycle.\n\n**Ambition:** \ud83d\udd34 Grand Challenge \u2014 paradigm-shifting if achieved, requiring formalization of deep results across multiple mathematical domains.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "edab5f0b",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:59:06.937020+00:00"
  },
  {
    "id": "fd_0981",
    "title": "Direction 2: Valuated M-Convexity and Coefficient Transport",
    "description": "**Conjecture:** Define a *valuated exchange property* that tracks not just support membership but coefficient values: for \u03b1, \u03b2 \u2208 supp(p) with \u03b1\u1d62 > \u03b2\u1d62, the exchange witness j satisfies a quantitative bound relating the coefficients of the four involved monomials. This valuated exchange should be preserved under differentiation (with appropriate rescaling).\n\n**Test:** Formalize a valuated exchange predicate. Test it on the basis-generating polynomials of uniform matroids with explicit coefficient weights. Prove or disprove preservation for the simplest nontrivial case (n=3, d=2).\n\n**Impact:** This would bridge from combinatorial support (boolean membership) to analytic coefficient behavior (quantitative inequalities), connecting the support-level theorem to log-concavity and ultra-log-concavity of coefficients along rays.\n\n**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (coeff_pderiv_eq), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Lorentzian signature).\n\n**Proof Strategy:** Use the coefficient formula [\u2202p/\u2202x\u1d62]_m = (m\u1d62+1)\u00b7[p]_{m+e\u1d62} to transport coefficient inequalities. The (m\u1d62+1) factor creates a predictable rescaling that should preserve the valuated exchange up to this factor.\n\n**Domain Bridges:** Discrete convex analysis (Murota's valuated matroids) \u2194 algebraic geometry (intersection theory) \u2194 combinatorial optimization (submodular function minimization).\n\n**Lineage:** Deepens the contraction theorem from topology (support) to geometry (valuated support).\n\n**Ambition:** Solid extension \u2014 the coefficient formula makes the rescaling explicit.\n\n**The key insight is** that the coefficient of the derivative at m is a simple multiplicative transform of the coefficient at m+e\u1d62, so quantitative exchange bounds should transport with controlled distortion.\n\n**Why now?** The coefficient formula is formally proved, and the qualitative (support-level) result is established. The quantitative upgrade is the natural next step.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "243a6673",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T23:33:15.543578+00:00"
  },
  {
    "id": "fd_0982",
    "title": "Direction 3: Hodge-Theoretic Interpretation of Exchange Depth",
    "description": "**Conjecture:** The *exchange depth* of a polynomial p \u2014 the maximum total order of mixed differentiation that preserves nonempty M-convex support \u2014 equals the minimum over all coordinates of min_{m \u2208 supp(p)} m_i, which is the \"inner radius\" of the Newton polytope. Furthermore, this quantity has a Hodge-theoretic interpretation as the dimension of a certain positive cone in the cohomology of the associated toric variety.\n\n**Test:** Compute exchange depth for all homogeneous supports of degree \u2264 8 on \u2264 4 variables. Compare with the inner radius. Formalize the inner radius computation in Lean and prove the equality for the full simplex (where both equal d/n rounded down).\n\n**Impact:** This would connect the combinatorial derivative hierarchy to the geometry of Newton polytopes and the algebra of toric varieties, opening a route to machine-verified Hodge-theoretic inequalities.\n\n**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (exchangeWidth, mixedPDeriv), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Hessian signature).\n\n**Proof Strategy:** For the full simplex, the inner radius is \u230ad/n\u230b and the exchange depth is exactly d (every contraction reduces degree by 1 until the support is a single point). For general M-convex sets, the conjecture may need refinement. Start with a computational census and refine the conjecture based on data.\n\n**Domain Bridges:** Algebraic combinatorics \u2194 algebraic geometry (toric varieties) \u2194 Hodge theory (mixed Hodge structures).\n\n**Lineage:** Extends exchange width monotonicity to a structural invariant with geometric meaning.\n\n**Ambition:** Grand challenge \u2014 the Hodge interpretation is speculative and would require significant new formal infrastructure.\n\n**The key insight is** that exchange depth measures the \"thickness\" of the M-convex set in a direction that corresponds to the depth of the derivative tower, and this thickness should be computable from the Newton polytope alone.\n\n**Why now?** The exchange width machinery is formalized and the monotonicity theorem is proved. The geometric interpretation is the natural question to ask next.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "243a6673",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T23:33:15.575441+00:00"
  },
  {
    "id": "fd_0985",
    "title": "Direction 1: Spectral-Tropical Entropy Bridge",
    "description": "**Conjecture:** For any connected graph $G$ with maximum degree $\\Delta$ and largest adjacency eigenvalue $\\lambda_1$:\n$$H(G) \\geq \\log(\\lambda_1 / \\Delta)$$\nwhere $H(G)$ is the graph degree entropy.\n\n**The key insight is...** The degree entropy captures how uniformly the graph distributes topological information capacity, while $\\lambda_1 / \\Delta$ measures how close the graph is to being regular (by the Perron-Frobenius theorem, $\\lambda_1 / \\Delta \\leq 1$ with equality iff $G$ is regular). The conjecture asserts that irregular graphs have lower degree entropy, bounded below by the spectral irregularity measure. This would connect three domains: tropical algebra (stability), information theory (entropy), and spectral theory (eigenvalues).\n\n**Why now?** The formal verification of degree entropy non-negativity (Theorem 7.1 in our work) provides the foundation. Mathlib now contains the spectral theory of finite graphs (adjacency matrix eigenvalues) and the Perron-Frobenius theorem, making a formal proof feasible. The Alon-Boppana bound $\\lambda_1 \\geq 2\\sqrt{\\Delta - 1} - o(1)$ would give explicit lower bounds.\n\n**Test:** Compute $H(G)$ and $\\log(\\lambda_1/\\Delta)$ for 1000 random graphs with $n = 50$ vertices and edge probability $p \\in \\{0.1, 0.3, 0.5\\}$. Verify the inequality holds in all cases.\n\n**Impact:** Establishes a spectral floor on tropical information content, enabling stability bounds derived purely from eigenvalue data.\n\n**Catalog References:** `Catalog/Pythagorean/TropicalBridge/Stability.lean` (degree bounds), `Catalog/Pythagorean/TropicalBridge/TropicalInformationTheory.lean` (degree entropy).\n\n**Proof Strategy:** Use the concavity of log and the relationship $\\sum p_v = 1$, $\\sum p_v \\cdot \\deg(v) = \\text{avg\\_degree}$. Apply Jensen's inequality to bound the entropy from below. Connect to $\\lambda_1$ via the Rayleigh quotient characterization.\n\n**Domain Bridges:** Spectral graph theory \u2194 Information theory \u2194 Tropical geometry.\n\n**Lineage:** Extends `degree_entropy_nonneg` and `capacity_gap_formula`.\n\n**Ambition:** Solid extension (3/5). Builds directly on established catalog theorems with clear proof strategy.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "7e5283ed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T23:33:37.973936+00:00"
  },
  {
    "id": "fd_0991",
    "title": "Direction 2: Quantitative Exchange Descent Bounds via Certificate Depth",
    "description": "**Conjecture:** For a finite exchange family S \u2286 \u2124^d with diameter D and an objective f satisfying ExchangeDLC_k with k \u2265 1, the exchange descent algorithm terminates in at most C \u00b7 d^{d-k} \u00b7 D steps, where C is a universal constant. At maximum depth k = d, the bound reduces to O(D), matching the performance of augmenting-path algorithms on M-convex functions.\n\n**Test:** Generate random exchange families of varying dimension d \u2208 {4,...,12} and rank r. For each, construct objectives with controlled certificate depth (using sums of independent log-concave terms for high depth, perturbed quadratics for low depth). Measure step counts and fit the exponent as a function of (d - k).\n\n**Impact:** This would establish the first complexity-depth tradeoff in discrete optimization, creating a new axis for algorithm design: invest in proving deeper certificates to get faster algorithms. This is analogous to how smoothness parameters control convergence rates in continuous optimization.\n\n**Catalog References:** `Catalog/Pythagorean/HigherOrderLogConcavity.lean` \u2014 `KFoldLogConcave.iterRatio_kfold`, `kFoldLogConcave_mono`\n\n**Proof Strategy:** Define a potential function \u03a6_k(x) that combines the objective value with a k-dependent measure of \"distance to optimality\" in the exchange graph. Show that each descent step decreases \u03a6_k by at least \u03b4_k = \u03a9(d^{-(d-k)}), yielding the step bound. The potential should leverage the k-fold certificate to get tighter decrease estimates at higher depths.\n\n**Domain Bridges:** Computational complexity \u2192 Discrete optimization \u2192 Algebraic combinatorics\n\n**Lineage:** Extends exchangeDescent_length_bound (Theorem 3.4) and exchangeDLC_k_mono.\n\n**Ambition:** Solid extension \u2014 the O(|S|) bound is already proven; the goal is to tighten it using certificate depth.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "abf333bc",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T00:07:30.309357+00:00"
  },
  {
    "id": "fd_1014",
    "title": "Direction 5: Tropical Certificate Density and Expander Graph Construction",
    "description": "**Conjecture:** The certificate density framework admits a tropical analogue, where the finite field \ud835\udd3d_q is replaced by the tropical semifield T = (\u211d \u222a {-\u221e}, max, +), and \"irreducible\" tropical characteristic polynomials correspond to indecomposable tropical matrices. The tropical certificate density converges to 1/n as the \"tropical q\" (a scaling parameter) tends to infinity, with the same M\u00f6bius-function error structure.\n\n**Test:** Compute the fraction of n\u00d7n tropical matrices (with entries in {0, 1, ..., M}) that are tropically indecomposable, for n = 3, 4, 5 and M = 10, 100, 1000. If the fraction converges to 1/n with error ~ 1/M^{n/2}, the tropical analogue holds.\n\n**Impact:** Opens a new research direction connecting tropical geometry to algebraic generation theory. If the tropical certificate density satisfies the same asymptotics, it suggests a universal structural principle governing irreducibility across algebraic settings.\n\n**Catalog References:** `Pythagorean/CertificateDensity.lean` (algebraic density), `Pythagorean/TropicalBerggrenZeta.lean` (tropical arithmetic)\n\n**Proof Strategy:** Define tropical irreducibility via the tropical determinant and permanent structure. Use the tropical analogue of the characteristic polynomial (the tropical eigenvalue set) to classify tropical matrices. Apply tropical M\u00f6bius inversion to count tropically indecomposable polynomials.\n\n**Domain Bridges:** Tropical Geometry \u2194 Group Theory \u2194 Number Theory\n\n**Lineage:** Extends the Pythagorean-tropical bridge to a new domain.\n\n**Ambition:** Grand challenge \u2014 speculative but testable connection between algebraic and tropical worlds.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "eb4b8f41",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T01:21:04.728538+00:00"
  },
  {
    "id": "fd_1025",
    "title": "Direction 1: Universal Support-Tutte Polynomial",
    "description": "**Conjecture:** Any support invariant F satisfying (i) multiplicativity on disjoint-coordinate direct sums and (ii) a deletion\u2013contraction recurrence on M-convex supports factors uniquely through a universal support-Tutte polynomial T_S(x, y), i.e., F = \u03c6 \u2218 T_S for some ring homomorphism \u03c6.\n\n**The key insight is** that the deletion\u2013contraction recurrence on supports, combined with the loop/coloop trichotomy, generates a free algebraic structure indexed by \"support activities\" analogous to Tutte's internal/external activities. The universality would follow from showing that every M-convex support admits a canonical activity ordering.\n\n**Why now?** The minor closure theorems (Theorems 3.1\u20133.4 in `Catalog/Pythagorean/SupportMinorTheory.lean`) guarantee that the recurrence is well-defined on the class of M-convex supports. This was the missing structural prerequisite.\n\n**Test:** For all M-convex subsets of the degree-\u22645 simplex on 4 variables, compute the support-Tutte polynomial using two different coordinate orderings. If the values agree in all cases, universality is strongly supported. A single disagreement would disprove universality and redirect toward a weaker theory (e.g., universality only for matroid-induced supports).\n\n**Impact:** A universal support-Tutte polynomial would be a new algebraic invariant of M-convex sets, generalizing the classical Tutte polynomial and potentially capturing information invisible to matroid Tutte theory (e.g., degree information from non-{0,1} supports).\n\n**Catalog References:** `Catalog/Pythagorean/SupportMinorTheory.lean` (SupportTutteInvariant structure, minor_step_card_le).\n\n**Proof Strategy:** \n1. Define support activities via a total ordering on coordinates, analogous to Tutte (1954).\n2. Show the activity-based expansion agrees with the deletion\u2013contraction recurrence.\n3. Prove uniqueness by induction on support cardinality.\n\n**Domain Bridges:** Statistical physics (Potts model partition functions), knot theory (Jones polynomial via Tutte specialization).\n\n**Lineage:** Direct extension of Theorem 3.4 (exchange_of_minor) in the current catalog.\n\n**Ambition:** Grand challenge \u2014 would establish a new universal algebraic invariant.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "abb48be4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T02:33:38.976648+00:00"
  },
  {
    "id": "fd_1051",
    "title": "Direction 2: Universality of Hybrid Walks \u2014 General Local/Global Generators",
    "description": "**Conjecture:** For any finite group $G$ with a \"local\" symmetric generating set $S_L$ (spectral gap $\\gamma_L$) and a \"global\" symmetric generating set $S_G$ with $|S_G| = O(1)$, the spectral gap of the combined walk satisfies $\\gamma_{L \\cup G} = \\Theta(\\gamma_L)$ \u2014 i.e., a bounded number of global generators does not change the spectral gap order.\n\n**Test:** Verify computationally for:\n- $G = \\mathbb{Z}_n^2$ (2D lattice group), $S_L$ = nearest-neighbor generators, $S_G$ = one diagonal generator.\n- $G = S_n$, $S_L$ = adjacent transpositions, $S_G$ = star transpositions $(1, i)$.\n- $G = \\text{GL}_n(\\mathbb{F}_q)$, $S_L$ = elementary matrices, $S_G$ = one permutation matrix.\n\n**Impact:** Would establish a universal principle: **bounded-size global generators preserve the diffusive scale of local generators.** This unifies many known results and opens a new theory of Markov chain acceleration.\n\n**Catalog References:** `Pythagorean/CayleyExpander/HybridWalk.lean` (HybridPermutationWalk structure), `Bridges/Catalog/Pythagorean/CayleyExpander/Defs.lean` (CayleySpectralData, CanonicalPathData).\n\n**Proof Strategy:** Generalize the canonical path argument: show that global generators reduce path congestion but cannot reduce the number of local steps needed, preserving the spectral gap order.\n\n**Domain Bridges:** Geometric group theory (word metrics), algebraic graph theory (Cayley graph expansion), operator algebras (spectral transfer).\n\n**Lineage:** Direct generalization of Theorem A.\n\n**Ambition:** \ud83d\udfe2 Solid Extension \u2014 conceptually clear generalization with known proof template.\n\n**\"The key insight is...\"** that spectral gaps are controlled by bottlenecks, and global generators can widen bottlenecks but cannot eliminate the local structure that creates them.\n\n**\"Why now?\"** The formalized HybridPermutationWalk structure provides the right abstraction layer for general statements. Testing on multiple group families is now computationally feasible.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Cryptography",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "48617359",
    "consumed_by_exp_id": "175f456d",
    "timestamp": "2026-05-26T04:51:55.424405+00:00"
  },
  {
    "id": "fd_1076",
    "title": "Direction 2: Pseudofinite Transfer via Definable Ultraproducts",
    "description": "**Conjecture:** The polynomially definable growth-or-control dichotomy transfers from individual finite fields $\\mathbb{F}_q$ to the pseudofinite field $\\mathbb{F}_\\omega = \\prod_q \\mathbb{F}_q / \\mathcal{U}$ via \u0141o\u015b's theorem: a definable subset of $\\mathrm{GL}(2, \\mathbb{F}_\\omega)$ with bounded doubling is controlled by a definable subgroup.\n\n**Test:** Formalize \u0141o\u015b's theorem for the restricted class of polynomial-image sentences and verify that the growth ratio $|A^2|/|A|$ is preserved under ultraproduct transfer for at least 3 concrete definable families.\n\n**Impact:** This would establish the first formal bridge between finite model theory and approximate group theory, showing that verified finite results automatically yield pseudofinite counterparts. It opens a path toward formalizing Hrushovski's approach.\n\n**Catalog References:** `Catalog/Algebra/MatrixGroupGeneration.lean` \u2014 the `PolyDefinableSubset` structure and generation certificates provide the definable language needed for transfer.\n\n**Proof Strategy:** The key insight is that our `PolyDefinableSubset` structure is already designed as a first-order definable object. Formalizing \u0141o\u015b's theorem for bounded-quantifier sentences over matrix algebras, then applying it to the growth predicate $|A^2| \\leq K|A|$.\n\n**Why now?** The definitions file (`ApproxSubgroupDefs.lean`) already contains the model-theoretic scaffolding (polynomial definability, coset control). Adding ultraproduct infrastructure is now a concrete formalization task rather than a conceptual challenge.\n\n**Domain Bridges:** Model theory, mathematical logic, ultraproduct theory.\n\n**Lineage:** Builds on `PolyDefinableSubset` and `CosetControlledBy` definitions.\n\n**Ambition:** Grand challenge \u2014 would be the first formally verified pseudofinite transfer theorem in group theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "a0951d1f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T06:04:06.558801+00:00"
  },
  {
    "id": "fd_1083",
    "title": "Direction 3: Higher-Dimensional Tropical Morse Theory for Quantum LDPC Codes",
    "description": "**Conjecture:** The tropical Morse theory framework extends to simplicial complexes of dimension \u2265 2, and the resulting higher-dimensional tropical Morse spectrum determines the parameters of CSS codes derived from chain complexes (including hypergraph product codes, fiber bundle codes, and balanced product codes).\n\n**Test:** Implement a simplicial tropical filtration for:\n- The 2D toric code (as a simplicial complex on the torus).\n- Hypergraph product codes HP(H\u2081, H\u2082) for random LDPC matrices H\u2081, H\u2082 of size 10\u00d720.\n- Balanced product codes for small group algebras.\nCompute \u03b2\u2081 and \u03b2\u2082 from the filtration and compare with known code parameters. If the higher-dimensional \u03b2 values correctly predict k and d bounds for \u226590% of test cases, the conjecture is supported.\n\n**Impact:** Would extend the tropical Morse framework to the most promising class of quantum codes for fault-tolerant computing (quantum LDPC codes), where asymptotically good parameters have been recently demonstrated.\n\n**Catalog References:**\n- `Bridges/Catalog/Pythagorean/TropicalMorse/HigherSimplicial.lean`: higher-dimensional extensions\n- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`: `filtration_exclusive_dichotomy`\n\n**Proof Strategy:** Define the higher-dimensional filtration as the sublevel set filtration of the weight function on the simplicial complex. The key technical challenge is proving the analogue of the exclusive dichotomy: each simplex addition changes exactly one Betti number. This follows from the long exact sequence in homology for the pair (K_\u2264t, K_\u2264t').\n\n**Domain Bridges:** Higher-dimensional tropical geometry \u2194 homological algebra \u2194 quantum LDPC codes \u2194 expander theory.\n\n**Lineage:** Natural generalization of all four main theorems to higher dimensions.\n\n**Ambition:** Grand challenge \u2014 requires substantial new mathematical development and connects to the frontier of quantum LDPC code theory.\n\n**The key insight is** that the exclusive dichotomy theorem (each edge addition changes exactly one Betti number) generalizes to simplices of all dimensions, and this generalization is exactly what's needed to extend the logical qubit and distance theorems.\n\n**Why now?** The recent breakthroughs in quantum LDPC codes (achieving constant rate and polynomial distance) create urgent demand for new analytical tools. Tropical Morse theory provides a natural framework that has been waiting for this application.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "b0b26cee",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T07:14:49.805352+00:00"
  },
  {
    "id": "fd_1084",
    "title": "Direction 4: Statistical Mechanics of Decoding via Tropical Percolation",
    "description": "**Conjecture:** The tropical Morse spectrum of a quantum code's interaction graph determines the critical error threshold for maximum-likelihood decoding, analogous to the bond percolation threshold in the random-bond Ising model. Specifically, the \"tropical percolation threshold\" \u2014 the weight at which half of all cycle events have occurred \u2014 predicts the threshold error rate within 10%.\n\n**Test:** For surface codes of sizes n = 5, 7, 9, 11:\n- Compute the tropical percolation threshold t_trop = median cycle birth value.\n- Run Monte Carlo simulations to estimate the ML decoding threshold p_c.\n- Compare t_trop / max_weight with p_c.\nIf the correlation is > 0.9 across all sizes, the conjecture is supported.\n\n**Impact:** Would provide a new analytical prediction for decoding thresholds, bypassing expensive Monte Carlo simulations and potentially explaining why certain code families have higher thresholds than others.\n\n**Catalog References:**\n- `Pythagorean/TropicalMorse/Theorems.lean`: `percolation_transition_count`, `giant_component_threshold`\n\n**Proof Strategy:** The tropical filtration is formally isomorphic to the bond percolation process. The cycle events correspond to loop formations in percolation. Show that the density of cycle events near the percolation threshold controls the error-correction capacity, using duality between the Nishimori line and the tropical critical surface.\n\n**Domain Bridges:** Statistical mechanics \u2194 tropical geometry \u2194 quantum error correction \u2194 percolation theory.\n\n**Lineage:** Extends the percolation connection already established in `percolation_transition_count` to a quantitative prediction.\n\n**Ambition:** Grand challenge \u2014 connects three deep theories (statistical mechanics, tropical geometry, quantum error correction) through a falsifiable quantitative prediction.\n\n**The key insight is** that the tropical filtration is literally a percolation process, and the statistics of cycle events in the filtration directly control the code's error-correction capacity.\n\n**Why now?** Recent work on the statistical mechanics of quantum error correction (the random-bond Ising model approach) provides the theoretical context, and the tropical Morse computation provides the efficient computational tool.\n\n---",
    "domains": [
      "Pythagorean",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "b0b26cee",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T07:14:49.839089+00:00"
  },
  {
    "id": "fd_1091",
    "title": "Direction 1: Overlap Class Conjecture \u2014 Beyond Disjoint Supports",
    "description": "**Conjecture:** For every connected graph G, basepoint q, and S \u2286 V \\ {q}, the number of tropical projective equivalence classes of minimal generating families of the tropical kernel equals the number of overlap classes of cycle supports in G[S].\n\n**Test:** Enumerate all connected graphs on n \u2264 9 vertices, compute all minimal generating families, quotient by TropProjEquiv, and compare the class count against the cycle overlap class count. A single counterexample falsifies the conjecture; universal agreement up to n = 9 provides strong evidence.\n\n**Impact:** Would extend the uniqueness theorem from the fully disjoint case to the general case, transforming tropical kernel generators into a complete graph invariant for all connected graphs (not just those with separated cycle structures).\n\n**Catalog References:** `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (TropProjEquiv, PairwiseDisjointSupports), `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` (inducedCycleRank).\n\n**Proof Strategy:** Define \"overlap degree\" as the maximum intersection size between two support sets. Prove uniqueness up to TropProjEquiv for overlap degree 0 (our current theorem), then induct on overlap degree using a \"peeling\" argument that reduces overlapping supports to disjoint ones plus correction terms.\n\n**Domain Bridges:** Connects tropical linear algebra to combinatorial topology (cycle spaces), matroid theory (circuit overlap structure), and coding theory (support weights of linear codes).\n\n**Lineage:** Extends the main theorem of this work. Builds on the support-matching injectivity argument of `support_matching_injective`.\n\n**Ambition:** Grand challenge \u2014 would unify tropical kernel theory with cycle matroid structure.\n\n**The key insight is** that the number of equivalence classes should be determined entirely by the combinatorial overlap pattern of cycle supports, not by the specific geometry of the graph. **Why now?** The formal verification infrastructure for TropProjEquiv and PairwiseDisjointSupports provides the first rigorous foundation for testing this prediction computationally.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "42d710f5",
    "consumed_by_exp_id": "db19bfd3",
    "timestamp": "2026-05-26T08:59:20.810965+00:00"
  },
  {
    "id": "fd_1096",
    "title": "Direction 1: General Symplectic Groups Sp\u2082\u2099(\ud835\udd3d_q)",
    "description": "**Conjecture:** For every n \u2265 1, there exist constants C_n and \u03b5_n > 0 such that for all odd prime powers q, there exist certified generating pairs (s, t) in Sp\u2082\u2099(\ud835\udd3d_q) with regular toral s satisfying |\u03c7_\u03c1(s)/\u03c7_\u03c1(1)| \u2264 C_n/q for all nontrivial irreducibles \u03c1, yielding spectral gap \u2265 \u03b5_n.\n\n**Test:** Compute spectral gaps for Sp\u2086(\ud835\udd3d_q) (n=3) for q = 3, 5, 7 using the same torus-type strategy. Verify that the gaps remain bounded away from zero and that the character-ratio bound C\u2083/q fits the data with C\u2083 independent of q. The conjecture is falsified if the optimal C_n grows faster than polynomially in n, or if no single torus type works uniformly.\n\n**Impact:** This would establish the first systematic family of higher-rank expanders parametrized by both rank and field size, unifying scattered results into a single framework.\n\n**Catalog References:** `Pythagorean/Sp4SpectralGap.lean` (DLCharacterBoundCertificate, uniform_gap_from_dl_certificate), `Algebra/MatrixGroupGeneration.lean` (eq_bot_or_top_of_charpoly_irreducible).\n\n**Proof Strategy:** Extend the DLCharacterBoundCertificate to carry a rank parameter n. Use Landazuri\u2013Seitz bounds for Sp\u2082\u2099 (minimum nontrivial irrep dim \u2265 (q^n \u2212 1)/(q \u2212 1) \u2212 1) and Deligne\u2013Lusztig character formulas for type C_n tori. The transference machinery (Theorems A and C) applies without modification.\n\n**Domain Bridges:** Higher-rank symplectic expanders connect to polar space codes (coding theory) and Siegel modular forms (number theory).\n\n**Lineage:** Direct extension of the Sp\u2084 transference framework.\n\n**Ambition:** Grand challenge \u2014 would resolve the higher-rank expansion problem for an entire infinite family.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "21d69cc6",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T09:39:15.046719+00:00"
  },
  {
    "id": "fd_1126",
    "title": "Direction 1: Full Group Isomorphism via Smith Normal Form Tracking",
    "description": "**Conjecture:** For every finite connected graph *G* and every nonempty separated subset *S*, there exists an explicit additive group isomorphism\n\n```\nCanonicalKernelSpan(G, S) / Constants \u2245 \u2124^|S| / Im(L_S)\n```\n\nwhere the isomorphism is constructively given by the Smith normal form transition matrices.\n\n**Test:** For all connected graphs with n \u2264 8, compute the canonical kernel generators and the SNF of L_S, verify that the transition matrix from generators to SNF basis is unimodular on the free part, and check that the quotient structures match as finite abelian groups.\n\n**Impact:** This would complete the \"tropical-critical correspondence\" by providing an explicit, algorithmically computable isomorphism. It would give the first tropical-geometric proof of the structure theorem for critical groups.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (harmonic kernel algebra, separation uniqueness)\n- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian, firingIndependentOn)\n\n**Proof Strategy:** Strategy A from the current work \u2014 quotient-lattice comparison. Define the map from canonical generators to cokernel elements via the Laplacian. Prove injectivity by contradiction using separation. Prove surjectivity by showing every cokernel element lifts to a harmonic representative.\n\n**Domain Bridges:** Algebraic graph theory \u2194 lattice theory, number theory (Smith normal form)\n\n**Lineage:** Extends `harmonic_normalized_unique` and `firingEquiv_trans` to a full categorical equivalence.\n\n**Ambition:** Solid extension \u2014 high confidence of success within 1\u20132 research cycles.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "1fb257b2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T13:05:51.407161+00:00"
  },
  {
    "id": "fd_1127",
    "title": "Direction 2: Tropical Canonical Forms on Metric Graphs",
    "description": "**Conjecture:** The canonical kernel correspondence extends from finite graphs to metric graphs (tropical curves): for a compact metric graph \u0393 and a finite separated vertex set *S*, the normalized harmonic kernel generators on *S* generate a lattice whose quotient is isomorphic to the Jacobian J(\u0393) restricted to *S*-supported divisors.\n\n**The key insight is** that the continuous Laplacian on a metric graph has the same row-sum-zero and symmetry properties as the discrete Laplacian, and leaf rigidity extends verbatim to metric graphs (the maximum principle forces harmonic functions to be linear on pendant edges).\n\n**Why now?** The Baker\u2013Norine theory for metric graphs [BN07] and the tropical Jacobian construction [MZ08] provide the necessary continuous analogues. Our discrete formalization gives a template for the metric extension.\n\n**Test:** Implement the correspondence for metric graphs discretized at varying resolutions. As resolution increases, the discrete canonical generators should converge to the continuous harmonic representatives on the metric graph. Test on genus-1 (cycle) and genus-2 (theta graph) metric graphs.\n\n**Impact:** Would establish the first explicit computational bridge between finite graph chip-firing and tropical curve theory, opening the door to algorithmic tropical Jacobian computation.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (harmonic_at_leaf_eq_neighbor, harmonic_tree_attachment_forces_unique_firing)\n- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian)\n\n**Proof Strategy:** Strategy C \u2014 inductive graph decomposition. Approximate the metric graph by increasingly fine finite graphs. Show the canonical generators converge under refinement using leaf rigidity as the stability mechanism.\n\n**Domain Bridges:** Tropical geometry \u2194 Berkovich analytic spaces, non-archimedean geometry\n\n**Lineage:** Extends leaf rigidity from finite trees to continuous pendant edges.\n\n**Ambition:** Grand challenge \u2014 requires new formalization infrastructure for metric graphs, but the mathematical path is clear.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "1fb257b2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T13:05:51.445505+00:00"
  },
  {
    "id": "fd_1136",
    "title": "Direction 2: Gate-Level Quantum Circuit Synthesis from Certificates",
    "description": "**Conjecture:** The recursive certificate tree for a matroid of rank $r$ on $n$ elements can be converted into a quantum circuit of depth $O(n \\cdot r)$ using $O(n)$ ancilla qubits and controlled rotation gates, with amplitudes matching the certificate to machine precision.\n\n**Test:** Implement the certificate-to-circuit conversion for small matroids (rank 2\u20134, ground set size 4\u20138). Simulate the quantum circuit classically and verify that output probabilities match the exact weighted basis distribution to $< 10^{-10}$ total variation distance.\n\n**The key insight is** that each deletion/contraction branch in the certificate tree corresponds to a conditional rotation: given that the qubit for element $e$ is in state $|0\\rangle$ (deletion) or $|1\\rangle$ (contraction), apply rotations determined by the sub-certificate. The tree structure maps to a sequence of controlled-$R_y$ gates.\n\n**Why now?** Current quantum state preparation methods (e.g., amplitude encoding via QRAM, Grover-Rudolph) are general but not structure-aware. The matroid certificate provides domain-specific structure that can reduce circuit depth. Recent advances in mid-circuit measurement and feed-forward make tree-structured circuits physically realizable.\n\n**Impact:** A practical quantum circuit for sampling spanning trees would advance quantum network analysis, quantum Monte Carlo for graph problems, and quantum-enhanced optimization.\n\n**Catalog References:** `Catalog/Pythagorean/MatroidQuantumCertificates.lean` (certificate structure and amplitude spec).\n\n**Proof Strategy:** Inductive construction: at each element, a controlled rotation splits amplitude between deletion and contraction branches. Angle is $\\theta_e = \\arctan(\\sqrt{w(e) \\cdot Z_{M/e} / Z_{M \\setminus e}})$.\n\n**Domain Bridges:** Quantum circuit synthesis \u2194 matroid theory \u2194 combinatorial optimization.\n\n**Lineage:** Extends Theorem 4.2 (quantum sampler exactness) to physical implementation.\n\n**Ambition:** Grand challenge \u2014 requires bridging formal mathematics with quantum hardware constraints.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "72356358",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T13:07:38.698339+00:00"
  },
  {
    "id": "fd_1137",
    "title": "Direction 3: Strong Rayleigh Property and Spectral Gap Certificates",
    "description": "**Conjecture:** For any matroid $M$ whose basis-generating polynomial is strongly Rayleigh (satisfies the stronger condition that all univariate restrictions are real-rooted), the basis exchange walk has spectral gap $\\Omega(1/r)$, and this spectral gap can be certified from the Lorentzian Hessian signature, giving an approximation guarantee for truncated certificates of depth $O(r \\log(1/\\varepsilon))$.\n\n**Test:** For graphic matroids of small complete and random graphs, numerically estimate the spectral gap of the basis exchange Markov chain. Compare with the prediction $1/r$ where $r$ is the rank. For partition matroids, verify that the spectral gap is exactly $1/r$.\n\n**The key insight is** that the Lorentzian Hessian encodes curvature information about the basis polytope, and negative curvature (the \"at most one positive eigenvalue\" condition) controls the rate of convergence of the exchange walk. This would give a Hodge-theoretic proof of rapid mixing.\n\n**Why now?** Anari, Liu, Oveis Gharan, and Vinzant [ALOV19] proved rapid mixing for log-concave distributions using a different approach (high-dimensional walks). The Lorentzian certificate approach would give a more direct, certifiable bound.\n\n**Impact:** Would unify three areas: Lorentzian polynomial theory (algebraic geometry), Markov chain mixing (probability), and approximate quantum sampling (quantum computing).\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Hessian signature), `Catalog/Pythagorean/LorentzianExchangeCertificates.lean` (exchange from log-concavity).\n\n**Proof Strategy:** Use the reversed Cauchy-Schwarz inequality from Lorentzian theory (already formalized) to bound the spectral gap from below. The key step is showing that the Lorentzian signature of the generating polynomial implies a Poincar\u00e9 inequality on the basis exchange graph.\n\n**Domain Bridges:** Algebraic geometry (Lorentzianity) \u2194 probability (Markov chains) \u2194 quantum computing (approximate sampling).\n\n**Lineage:** Extends the log-concavity \u2192 exchange inequality pipeline from `LorentzianExchangeCertificates.lean`.\n\n**Ambition:** Grand challenge \u2014 would constitute a new proof of rapid mixing from Hodge theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "72356358",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T13:07:38.737603+00:00"
  },
  {
    "id": "fd_1139",
    "title": "Direction 5: Partition Function Phase Transitions and Matroid Complexity",
    "description": "**Conjecture:** For the graphic matroid of a random Erd\u0151s\u2013R\u00e9nyi graph $G(n, p)$ with uniform weights, there is a phase transition in the certificate complexity at $p = c \\cdot \\log(n) / n$ for some constant $c$: below the threshold, the certificate is polynomial-size; above it, the certificate requires exponential size.\n\n**Test:** For $n = 8, 10, 12, 14$ and edge probabilities $p$ ranging from $0.1$ to $0.9$, generate random graphs, compile certificates, and measure certificate size. Plot size vs. $p$ for each $n$ and look for a threshold phenomenon.\n\n**The key insight is** that the connectivity threshold of random graphs ($p \\sim \\log(n)/n$) coincides with a transition in the matroid structure: below the threshold, the matroid is sparse with few bases; above it, the number of spanning trees grows exponentially, and the deletion/contraction tree must track exponentially many branches.\n\n**Why now?** Phase transitions in computational complexity are a central theme in theoretical computer science (SAT threshold, graph coloring threshold). The matroid certificate framework provides a new family of problems where phase transitions can be studied both analytically and experimentally.\n\n**Impact:** Would connect matroid theory to the theory of computational phase transitions, with implications for understanding when quantum sampling advantages are achievable.\n\n**Catalog References:** `Catalog/Pythagorean/MatroidQuantumCertificates.lean` (partition function positivity, certificate construction).\n\n**Proof Strategy:** Below the connectivity threshold, use the sparse structure to bound certificate size. Above the threshold, use entropy arguments to show that the certificate must represent exponentially many paths through the deletion/contraction tree.\n\n**Domain Bridges:** Random graph theory \u2194 computational complexity \u2194 quantum sampling \u2194 statistical physics.\n\n**Lineage:** New direction connecting certificate complexity to random graph thresholds.\n\n**Ambition:** Grand challenge \u2014 would require new techniques at the intersection of random graphs and matroid complexity.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "72356358",
    "consumed_by_exp_id": "14c19443",
    "timestamp": "2026-05-26T13:07:38.816025+00:00"
  },
  {
    "id": "fd_1160",
    "title": "Direction 1: Sharp GOE Constants via Tracy-Widom Transfer",
    "description": "**Conjecture**: For n\u00d7n Gaussian symmetric perturbations E with E_{ij} ~ N(0, \u03c3\u00b2/n), the misclassification probability satisfies\n\nP(misclassification) \u2264 exp(\u2212(\u03b5 \u2212 2\u03c3)\u00b2\u208a \u00b7 n / (C\u03c3\u00b2))\n\nwith an explicit constant C depending only on the normalization, and the transition occurs sharply at \u03b5 = 2\u03c3 (the edge of the Wigner semicircle).\n\n**Test**: Compare Monte Carlo failure rates against the predicted sharp threshold \u03b5 = 2\u03c3 for dimensions n = 10, 50, 200. The transition width should scale as n^{\u22122/3}, matching Tracy-Widom fluctuations.\n\n**Impact**: Transforms the abstract exponential tail bound into a quantitative engineering formula. For the first time, a practitioner could compute the exact number of bits of precision needed to certify Lorentzianity at a given confidence level.\n\n**Catalog References**: `Pythagorean/LorentzianSmoothedAnalysis.lean` (failure_event_subset_gap_event, smoothed_bound_monotone_in_gap), `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (HasGappedSignature).\n\n**Proof Strategy**: \n1. Formalize the Wigner semicircle law for GOE matrices: the largest eigenvalue of E converges to 2\u03c3.\n2. Use Tracy-Widom tail bounds: P(\u03bb_max > 2\u03c3 + t\u03c3n^{\u22122/3}) \u2264 exp(\u2212ct^{3/2}).\n3. Compose with failure_event_subset_gap_event to get P(misclass) \u2264 P(\u2016E\u2016 > \u03b5).\n4. Substitute the Tracy-Widom tail at t = (\u03b5 \u2212 2\u03c3)n^{2/3}/\u03c3.\n\n**Domain Bridges**: Random matrix theory \u2192 algebraic combinatorics \u2192 numerical analysis.\n\n**Lineage**: Builds directly on Theorems 1 and 3 of this cycle.\n\n**Ambition**: Grand challenge \u2014 requires formalizing Tracy-Widom distribution or at least its tail bounds.\n\nThe key insight is that the Wigner semicircle edge at 2\u03c3 creates a sharp phase transition for Lorentzian stability, replacing the gradual exponential decay with a precise threshold.\n\nWhy now? The failure containment theorem (this cycle) provides the formal reduction; only the random matrix input is missing. Mathlib's growing spectral theory infrastructure makes formalization feasible within 1-2 cycles.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "f52aba3c",
    "consumed_by_exp_id": "6a75662e",
    "timestamp": "2026-05-26T15:25:16.762042+00:00"
  },
  {
    "id": "fd_1174",
    "title": "Direction 2: Representation-Theoretic Sharpening for $S_n$",
    "description": "**Conjecture:** For $S_n$ with adjacent transpositions and bubble-sort canonical paths, the congestion $\\kappa(S_n)$ satisfies $\\kappa(S_n) = \\Theta(n^a)$ where $8 \\leq a \\leq 9$, and the resulting spectral gap bound is $\\Omega(n!^2 / n^{a+3})$. More precisely, the exact spectral gap is $1 - \\cos(\\pi/n) \\sim \\pi^2/(2n^2)$, and the canonical path bound is weaker by a factor of $\\Theta(n^{a+1} / n!^2)$.\n\n**Test:** Compute exact congestion for $n = 6, 7$ (feasible with optimized code) and fit the growth exponent. Compare with the exact spectral gap from representation theory (known to be the eigenvalue of the $(n-1)$-dimensional standard representation on the adjacent transposition generators).\n\n**Impact:** Understanding the exact congestion growth would reveal whether bubble-sort routing is inherently suboptimal or whether the canonical path method itself has structural limitations for $S_n$. This could motivate the search for better canonical paths (e.g., using insertion sort, merge sort, or representation-guided routing).\n\n**Catalog References:** `Pythagorean/CayleyExpander/CanonicalPaths.lean` (congestion definition), `Catalog/Bridges/Catalog/Pythagorean/CayleyExpander/SymmetricGroup.lean` (S_n generators).\n\n**Proof Strategy:** Use the Murnaghan\u2013Nakayama rule to compute the exact spectrum of the adjacency matrix of $\\text{Cay}(S_n, \\text{adj.\\ transpositions})$. Compare with the canonical path lower bound.\n\n**Domain Bridges:** Representation theory of symmetric groups, algebraic combinatorics, random matrix theory.\n\n**Lineage:** Extends the computational case study in `CanonicalPaths.lean` with exact spectral analysis.\n\n**Ambition:** Solid extension \u2014 connects formal combinatorial bounds to exact algebraic results.\n\n**\"The key insight is...\"** that the gap between canonical path bounds and exact spectral gaps quantifies the *information loss* in the routing abstraction, revealing which structural features of the group the method fails to exploit.\n\n**\"Why now?\"** The exact congestion data for $S_3, S_4, S_5$ reveals unexpectedly fast growth, motivating representation-theoretic analysis.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "5c8e335c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T17:12:57.478975+00:00"
  },
  {
    "id": "fd_1176",
    "title": "Direction 4: High-Dimensional Expansion via Canonical Cochains",
    "description": "**Conjecture:** The canonical path method extends to simplicial complexes: for a $d$-dimensional simplicial complex $X$ with vertex set $V$, one can define \"canonical $k$-chains\" routing $k$-cycles to $k$-boundaries, with congestion controlling the $(k+1)$-th spectral gap of the Hodge Laplacian.\n\n**Test:** Define canonical 1-chains for the complete 2-complex on 5 vertices (the boundary of a 4-simplex). Compute congestion and compare with the known spectral gap of the Hodge Laplacian.\n\n**Impact:** High-dimensional expansion is a frontier topic with applications to locally testable codes, quantum LDPC codes, and topological data analysis. A canonical cochain method would provide the first combinatorial certification of high-dimensional spectral gaps.\n\n**Catalog References:** `Pythagorean/CayleyExpander/CanonicalPaths.lean` (1-dimensional case), `Pythagorean/CayleyExpander/Defs.lean` (Dirichlet energy definitions).\n\n**Proof Strategy:** Define a higher-dimensional Dirichlet energy for $k$-forms on a simplicial complex. Generalize the telescoping identity to $k$-chains. Prove a Cauchy\u2013Schwarz bound on cochain energy. Assemble into a Hodge-theoretic Poincar\u00e9 inequality.\n\n**Domain Bridges:** Algebraic topology (cohomology, Hodge theory), quantum error correction, extremal combinatorics.\n\n**Lineage:** Generalizes `variance_le_congestion_mul_energy` from 0-forms on graphs to $k$-forms on complexes.\n\n**Ambition:** Grand challenge \u2014 would open a new direction in formal high-dimensional combinatorics.\n\n**\"The key insight is...\"** that canonical paths are 1-dimensional chains solving a 0-dimensional routing problem, and the same structure exists in every dimension.\n\n**\"Why now?\"** The formal 1-dimensional framework provides a template for higher-dimensional generalization.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "5c8e335c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T17:12:57.552181+00:00"
  },
  {
    "id": "fd_1179",
    "title": "Direction 2: Quantum Entanglement Entropy via DPP-Lorentzian Structure",
    "description": "**Conjecture**: For a system of n free fermions with single-particle density matrix K (PSD, eigenvalues in [0,1]), the entanglement entropy of a subsystem A \u2286 [n] satisfies bounds derivable from the Lorentzian structure of the DPP partition function restricted to A.\n\n**Test**: For random fermionic states (PSD K with eigenvalues in [0,1]) and subsystems A of size |A| \u2264 8, compute the entanglement entropy S_A = \u2212\u03a3_k [\u03bb_k log \u03bb_k + (1\u2212\u03bb_k)log(1\u2212\u03bb_k)] (where \u03bb_k are eigenvalues of K_A) and compare with bounds derived from the Lorentzian coefficient inequalities of the degree-|A| homogeneous component.\n\n**Impact**: Would connect Lorentzian polynomial theory to quantum information theory, providing geometric constraints on entanglement structure. Could yield new area-law or volume-law bounds for free-fermion systems.\n\n**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` (Lorentzian signatures), `Pythagorean/DPPLorentzian.lean` (spectral bridge theorem).\n\n**Proof Strategy**: Use the spectral decomposition K_A = U_A \u039b_A U_A^T. The entanglement entropy is a function of eigenvalues of K_A. The Lorentzian inequalities constrain the elementary symmetric functions of these eigenvalues (which are the homogeneous component sums), and Newton's inequalities relate these to individual eigenvalues.\n\n**Domain Bridges**: Quantum information \u2194 Algebraic combinatorics \u2194 Statistical mechanics.\n\n**Lineage**: Extends the spectral bridge (Theorem 3.4) into the quantum domain.\n\n**Ambition**: \u2605\u2605\u2605\u2605\u2605 (Grand Challenge / Paradigm-Shifting). If Lorentzian structure constrains entanglement, it would open an entirely new connection between Hodge theory and quantum information.\n\n**The key insight is** that the entanglement entropy of free fermions is entirely determined by the eigenvalues of the reduced density matrix K_A, and these eigenvalues are constrained by the same Lorentzian inequalities that govern the DPP partition function.\n\n**Why now?** Free-fermion entanglement is well-understood physically but lacks a connection to algebraic combinatorics. The DPP-Lorentzian bridge we've established is exactly the missing link.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "c89156c3",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T17:48:46.660643+00:00"
  },
  {
    "id": "fd_1183",
    "title": "Direction 1: Bell Number State Compression",
    "description": "**Conjecture:** The FPT certificate bound can be tightened from $|E| \\cdot 2^{k^2+k}$ to $|E| \\cdot B_{k+1}^2$, where $B_n$ is the $n$-th Bell number.\n\n**Test:** Implement the state-compressed certificate compiler using partition refinement at each bag. For $k \\in \\{2,3,4,5\\}$ and random $k$-trees on $n \\in \\{50, 100, 500\\}$ vertices, measure the ratio of actual certificate size to $|E| \\cdot B_{k+1}^2$. If this ratio stays bounded by a constant, the conjecture is supported.\n\n**Impact:** Would reduce the certificate size by a factor of $2^{k^2+k} / B_{k+1}^2$, which is superexponential in $k$. For $k = 5$: from $\\sim 10^9$ to $\\sim 41,209$ \u2014 a 24,000\u00d7 improvement.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TreewidthCertificateDefs.lean` \u2014 `BagProfile` structure, `certBranchingBound`\n- `Catalog/Pythagorean/TreewidthCertificateTheorems.lean` \u2014 `fpt_cert_size_composition`, `maxActiveEdges_le_cert_exp`\n\n**Proof Strategy:** Define a `BellCompressedState` structure that represents bag states as set partitions rather than edge subsets. Show that deletion preserves the partition (splits a class into two) and contraction refines it (merges two classes). The number of distinct partition transitions at each bag is bounded by $B_{k+1}$ for deletions and $B_{k+1}$ for contractions, giving $B_{k+1}^2$ total states.\n\n**Domain Bridges:** Connects to enumerative combinatorics (Bell numbers, Stirling numbers), lattice theory (partition lattice structure), and coding theory (partition codes for efficient state representation).\n\n**Lineage:** Builds on `maxActiveEdges_eq_choose` and `fpt_cert_size_composition`.\n\n**Ambition:** \ud83d\udfe1 Solid extension \u2014 the Bell number bound is well-understood combinatorially, and the main challenge is the formal verification infrastructure.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "802479fb",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T18:22:28.461601+00:00"
  },
  {
    "id": "fd_1188",
    "title": "Direction 1: Primewise Completeness for Derived Persistence Invariants",
    "description": "**Conjecture:** The max-envelope inequality extends beyond torsion birth sets to derived invariants including persistence diagrams, Betti curves, and landscape functions, with the same L\u221e aggregation structure.\n\n**Test:** Formalize the persistence diagram for p-primary torsion modules over \u2124 and prove that the bottleneck distance between global torsion diagrams is bounded by the maximum of p-primary bottleneck distances. Construct explicit counterexamples to equality in the derived setting.\n\n**Impact:** Would unify the birth-set stability theory with the full algebraic stability theorem, providing a complete primewise decomposition of integer persistence.\n\n**Catalog References:** `Pythagorean/PrimewiseTorsionStability.lean` (primewise stability), `Pythagorean/MaxEnvelopeStability.lean` (max-envelope framework, `IsMaxEnvelope`, `finite_prime_envelope_suffices'`)\n\n**Proof Strategy:** Extend the min-max Lipschitz lemma (`natDist'_inf'_le_sup'_natDist'`) to bottleneck distances by proving that the matching between global diagrams decomposes into primewise matchings. Use the subsingleton property of birth sets as the base case.\n\n**Domain Bridges:** Connects to algebraic K-theory (derived torsion invariants), homological algebra (spectral sequences for prime decomposition).\n\n**Lineage:** Extends `finite_prime_envelope_suffices'` from birth sets to full diagram invariants.\n\n**Ambition:** Grand challenge \u2014 would require building significant new infrastructure for integer persistence diagrams.\n\n**The key insight is** that the algebraic stability theorem's proof structure already decomposes along prime channels; the challenge is formalizing the recombination step.\n\n**Why now?** The max-envelope framework provides the right abstraction (`IsMaxEnvelope`, `IsBoundedByMaxEnvelope`) to state and attack this problem. The formalized birth decomposition theorem gives the base case.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "34bffabf",
    "consumed_by_exp_id": "fbc28fb9",
    "timestamp": "2026-05-26T18:56:53.573835+00:00"
  },
  {
    "id": "fd_1199",
    "title": "Direction 1: Double Scaling Limit \u2014 When Does m Matter?",
    "description": "**Conjecture:** There exists a critical scaling function m*(k) such that:\n- If m = o(m*(k)), the wreath perturbation remains irrelevant: |\u03b2_W(k,m) - m\u00b7\u03b2(S_k)| \u2192 0.\n- If m ~ m*(k), the perturbation becomes marginal.\n- If m \u226b m*(k), the perturbation is relevant: the universality class changes.\n\nWe conjecture m*(k) = k^\u03b1 for some exponent \u03b1 > 0 (possibly \u03b1 = 1).\n\n**Test:** Compute \u03b2_W(k, m) for k \u2208 {3,...,8} and m \u2208 {k/2, k, 2k, k\u00b2} using GAP or subgroup enumeration. Plot the rescaled deviation as a function of m/k^\u03b1 for various \u03b1. The correct \u03b1 collapses the data onto a universal curve.\n\n**Impact:** Identifies the precise boundary between \"irrelevant\" and \"relevant\" regimes for wreath products. This is the analog of identifying the upper critical dimension in statistical mechanics.\n\n**Catalog References:**\n- `Pythagorean/WreathPerturbation.lean`: `beta_wreath_eq_mul_beta_symm_plus_error`, `defect_ratio_tendsto_zero`\n- `Catalog/Bridges/Catalog/Pythagorean/SubgroupUniversality.lean`: `pressure_directPower_linear`\n\n**Proof Strategy:** Extend the perturbative bound by tracking the m-dependence explicitly. The defect bound has constant C_m; determine C_m's growth rate in m. If C_m grows polynomially, the critical scaling is m* ~ k/C_m^{1/...}. Use Clifford theory to bound the number of wreath-product irreducibles as a function of both k and m.\n\n**Domain Bridges:** Statistical mechanics (upper critical dimension), random matrix theory (transition between GOE and GUE universality classes as matrix size grows).\n\n**Lineage:** Direct extension of Theorems 4-5 from the current work; builds on the perturbative bound framework.\n\n**Ambition:** Grand challenge \u2014 resolving this would establish a complete phase diagram for wreath product universality.\n\n**The key insight is** that the m-dependence of the perturbative constant C_m controls the crossover between irrelevant and relevant regimes, analogous to how the dimension d controls the relevance of interaction terms in \u03c6\u2074 field theory.\n\n**Why now?** The formalized perturbation framework provides the first rigorous tool for studying m-dependence. The computational infrastructure (algorithms.py) can probe the double scaling regime for small k, m, providing empirical guidance for the conjecture.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "550b5c8b",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T21:18:02.967940+00:00"
  },
  {
    "id": "fd_1204",
    "title": "Direction 1: k-th Order Shadow Theorem and Iterated Shadow Geometry",
    "description": "**Conjecture:** For any k \u2265 1 and any polynomial f over a domain of characteristic zero, the set of monomials appearing in some k-th partial derivative \u2202_{i\u2081}\u00b7\u00b7\u00b7\u2202_{i\u2096}f equals exactly the k-th shadow Sh\u2096(Supp(f)) = {\u03b2 : \u2203 \u03b1 \u2208 Supp(f), \u2203 i\u2081,...,i\u2096, \u03b1 = \u03b2 + e_{i\u2081} + \u00b7\u00b7\u00b7 + e_{i\u2096}}. Furthermore, the sequence of shadow sizes |Sh\u2081(S)| \u2265 |Sh\u2082(S)| \u2265 \u00b7\u00b7\u00b7 \u2265 |Sh\u2090(S)| forms a log-concave sequence when S is M-convex.\n\n**Test:** Prove the k-th shadow theorem in Lean by induction on k, using the single-step coefficient transport formula. For the log-concavity conjecture, computationally test with M-convex supports (matroid basis supports) in up to 8 variables and degree 6. A disproof would be any M-convex S where |Sh\u2096(S)|\u00b2 > |Sh\u2096\u208b\u2081(S)| \u00b7 |Sh\u2096\u208a\u2081(S)| for some k.\n\n**Impact:** This would establish a complete hierarchy of shadow invariants controlling all-order derivative complexity, with the log-concavity providing tight bounds on how fast derivative complexity decays. For Lorentzian polynomials, this would give a new proof route to the ultra-log-concavity of derivative norms.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (coeff_pderiv_single, coeff_pderiv_pderiv), `Catalog/Bridges/Catalog/Pythagorean/SupportCompression.lean` (nonzeroDerivativeLeafSet_eq_indep)\n\n**Proof Strategy:** Induction on k. The base case k=2 is our main theorem. For the inductive step, apply the single-derivative coefficient formula to reduce the (k+1)-th shadow to the k-th shadow of a derivative, then use the inductive hypothesis. The log-concavity conjecture likely requires injection-based arguments or connections to matroid theory.\n\n**Domain Bridges:** Connects to combinatorial commutative algebra (Hilbert function behavior), algebraic topology (Betti number sequences of toric varieties), and information theory (entropy of derivative distributions).\n\n**Lineage:** Direct extension of the Quadratic Shadow Theorem, building on the coefficient transport lemma.\n\n**Ambition:** Solid extension \u2014 the k-th shadow theorem should be provable within one cycle. The log-concavity conjecture is a grand challenge that may require new ideas from matroid theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ef991832",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T21:53:04.887954+00:00"
  },
  {
    "id": "fd_1205",
    "title": "Direction 2: Anti-Cancellation for Aggregated Derivatives in Lorentzian Polynomials",
    "description": "**Conjecture:** For a Lorentzian polynomial f with M-convex support, the trace of the Hessian \u03a3\u1d62 \u2202\u00b2f/\u2202x\u1d62\u00b2 has nonzero coefficient at every \u03b2 \u2208 Sh\u2082(Supp(f)) that is reachable by subtracting 2e\u1d62 for some i from some support element. More ambitiously: for any positive linear combination \u03a3 a\u1d62\u2c7c \u2202\u1d62\u2202\u2c7cf with a\u1d62\u2c7c > 0, every shadow point remains nonzero.\n\n**The key insight is** that Lorentzian polynomials satisfy a deep positivity condition: all coefficients have the same sign after appropriate normalization, and the M-convexity of the support provides \"exchange paths\" that prevent total cancellation across derivative contributions.\n\n**Why now?** The individual derivative theorem removes cancellation entirely; the natural next step is understanding when partial cancellation (across derivatives, not within one) can occur. The Lorentzian condition is the most natural structural hypothesis preventing this.\n\n**Test:** For each homogeneous polynomial f of degree d \u2264 6 in n \u2264 5 variables with M-convex support and positive coefficients, compute the Hessian trace \u03a3\u1d62 \u2202\u00b2f/\u2202x\u1d62\u00b2 and check if every shadow point (of the diagonal type) appears. A disproof would be a Lorentzian polynomial where cancellation in the aggregated trace eliminates a shadow point. Test at least 10,000 random positive-coefficient polynomials with M-convex support.\n\n**Impact:** This would be the first theorem connecting Lorentzian positivity to aggregated derivative sparsity, opening a new chapter in the theory of Lorentzian polynomials beyond the multiaffine case.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (IsMConvexExchangeNat, IsLorentzianQuadratic), `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (coeff_pderiv_pderiv_ne_zero_iff)\n\n**Proof Strategy:** Strategy C from the original proposal. Use M-convex exchange to show that coefficient arrays along shadow fibers are sign-coherent, then prove that the weighted sum cannot vanish. May require new lemmas on the structure of M-convex polytope fibers.\n\n**Domain Bridges:** Statistical physics (partition function susceptibilities never vanish for Lorentzian systems), optimization (Hessian of log-concave functions has guaranteed non-degeneracy), tropical geometry (tropical Hessian of a Lorentzian polynomial has full tropical rank).\n\n**Lineage:** Builds on Direction 1's individual exactness and the Catalog's M-convexity results.\n\n**Ambition:** Grand challenge \u2014 this would be a genuine advance in the theory of Lorentzian polynomials, requiring new ideas about the interaction of positivity and aggregation.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ef991832",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T21:53:04.933230+00:00"
  },
  {
    "id": "fd_1206",
    "title": "Direction 3: Tropical Shadow and Newton Polytope Projections",
    "description": "**Conjecture:** The quadratic shadow Sh\u2082(S) equals the set of lattice points in the Minkowski difference Newt(S) \u2296 \u0394\u2082 \u2229 \u2124\u207f, where Newt(S) is the convex hull and \u0394\u2082 is the simplex of degree-2 exponents. Furthermore, this identification extends to a tropical analogue: the tropical second derivative of a tropical polynomial has support equal to the tropical shadow.\n\n**The key insight is** that the shadow construction is secretly a lattice-point projection of the Newton polytope, and tropicalization preserves this projection structure.\n\n**Why now?** Tropical geometry has matured to the point where tropical Hessians and tropical second derivatives are well-defined. The shadow theorem provides the missing link between the algebraic and tropical pictures.\n\n**Test:** For 3-variable polynomials of degree \u2264 8, compute both Sh\u2082(S) and the lattice points of Newt(S) \u2296 \u0394\u2082. These should agree when S is a lattice polytope (all lattice points present). For general S (sparse), Sh\u2082(S) should be contained in but not equal to the polytope lattice points. Find precise conditions for equality.\n\n**Impact:** This would create a bridge between the algebraic shadow theorem and the geometric theory of Newton polytopes, enabling tools from convex geometry (volume, mixed volume, Ehrhart theory) to be applied to derivative complexity questions.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (QuadraticShadow, computeQuadShadow), any tropical geometry files in the Catalog\n\n**Proof Strategy:** Strategy B from the original proposal. Define the Minkowski shadow as a convex body, characterize its lattice points, and show containment in both directions. The tropical direction requires defining tropical differentiation on tropical polynomial rings and showing it respects the shadow structure.\n\n**Domain Bridges:** Toric geometry (toric varieties associated to shadow polytopes), algebraic statistics (log-linear models and sufficient statistics), geometric combinatorics (Ehrhart theory of shadow polytopes).\n\n**Lineage:** Connects the algebraic shadow (this work) to the geometric program of Newton polytope theory (Gelfand-Kapranov-Zelevinsky).\n\n**Ambition:** Grand challenge for the full tropical program; solid extension for the lattice-point characterization.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Cryptography",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ef991832",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T21:53:04.972544+00:00"
  },
  {
    "id": "fd_1207",
    "title": "Direction 4: Shadow Complexity as an Arithmetic Circuit Lower Bound",
    "description": "**Conjecture:** For any arithmetic circuit C computing all n\u00b2 second partial derivatives of a polynomial f with support S, the circuit size |C| satisfies |C| \u2265 |Sh\u2082(S)| / n\u00b2. Furthermore, there exist polynomial families where this bound is tight, giving an optimal sparsity-based lower bound.\n\n**The key insight is** that the shadow size is a lower bound on the number of distinct nonzero outputs any computation must produce, and sharing of intermediate results can reduce the work by at most an n\u00b2 factor (from shared first-derivative computations).\n\n**Why now?** Arithmetic circuit complexity has few general lower bounds beyond degree-based arguments. Support-based bounds represent a new paradigm, and the shadow theorem provides the first rigorous support-to-output complexity connection.\n\n**Test:** Construct explicit polynomial families (e.g., sparse random, structured algebraic) where the shadow size grows superlinearly in the support size. Implement optimal Hessian computation algorithms and measure their complexity relative to the shadow bound. A disproof of tightness would be a family where every algorithm beats the bound by a super-constant factor.\n\n**Impact:** New lower bound technique for arithmetic complexity based on Newton-polytope geometry rather than degree. Could resolve specific questions about optimal Hessian computation complexity.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (quadShadow_mono, computeQuadShadow_mono \u2014 monotonicity as complexity monotone)\n\n**Proof Strategy:** Counting argument: any correct algorithm for computing all \u2202\u1d62\u2202\u2c7cf must produce |Sh\u2082(S)| distinct nonzero values. Each arithmetic operation produces at most one new value. First-derivative sharing reduces redundancy by at most n\u00b2. Formalize this as a lower bound on the number of additions and multiplications.\n\n**Domain Bridges:** Algebraic complexity theory (VP vs VNP, depth reduction), automatic differentiation (optimal Jacobian accumulation), sparse linear algebra (Hessian compression).\n\n**Lineage:** Builds on the algorithm correctness theorem and monotonicity results from this work.\n\n**Ambition:** Solid extension for the basic counting lower bound; grand challenge for tightness and connections to VP vs VNP.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ef991832",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T21:53:05.013082+00:00"
  },
  {
    "id": "fd_1208",
    "title": "Direction 5: Shadow Structure of Partition Functions and Phase Transitions",
    "description": "**Conjecture:** For partition functions Z = \u03a3_\u03b1 e^{-\u03b2E(\u03b1)} x^\u03b1 of lattice models, the shadow size |Sh\u2082(Supp(Z))| undergoes a phase transition at critical temperature: below criticality, the shadow is \"small\" (polynomial in the system size), while above criticality, it is \"large\" (exponential). This transition corresponds to the onset of long-range correlations.\n\n**The key insight is** that the shadow of a partition function's support encodes exactly the second-order response modes (susceptibilities, correlations), and phase transitions are characterized by the divergence of these quantities \u2014 which requires a sudden increase in the number of active response modes.\n\n**Why now?** The shadow theorem provides the first rigorous link between combinatorial support geometry and derivative-based thermodynamic quantities. This creates a new geometric approach to understanding phase transitions, complementing the traditional analytic (Yang-Lee) and probabilistic (Gibbs measure) approaches.\n\n**Test:** Implement partition functions for the 2D Ising model on small lattices (up to 8\u00d78). As temperature varies, track |Sh\u2082(Supp(Z))| and compare with known critical temperature T_c. Also test Potts models and dimer models. A disproof would be a model with known phase transition where the shadow size varies smoothly through the critical point.\n\n**Impact:** Would establish a new connection between combinatorial geometry and statistical physics, providing a purely geometric signature of phase transitions without reference to free energy analyticity or correlation length divergence.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (nonzeroQuadLeafSet_eq_shadow, shadowMultiplicity)\n\n**Proof Strategy:** For specific lattice models, characterize the support of Z combinatorially (it corresponds to valid spin configurations). Show that at high temperature (large support), the shadow is exponential, while at low temperature (concentrated support around ground states), the shadow is polynomial. The transition should occur at the point where the support \"percolates\" in an appropriate lattice-theoretic sense.\n\n**Domain Bridges:** Statistical mechanics (Lee-Yang theorem, correlation inequalities), combinatorics (counting lattice configurations), computational complexity (#P-hardness of partition functions).\n\n**Lineage:** Connects the pure mathematical shadow theory to physical observables, extending the \"partition function as polynomial\" philosophy of Borcea-Br\u00e4nd\u00e9n.\n\n**Ambition:** Grand challenge \u2014 requires new ideas connecting lattice combinatorics to shadow geometry. Even partial results (specific models, asymptotic bounds) would be highly impactful.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "ef991832",
    "consumed_by_exp_id": "d0a449c5",
    "timestamp": "2026-05-26T21:53:05.052331+00:00"
  },
  {
    "id": "fd_1213",
    "title": "Direction 5: Determinantal Complexity and Matroid Representability",
    "description": "**Conjecture**: The minimum size of a matrix $A$ such that $\\det(A D_w A^\\top)$ equals the basis-generating polynomial of $M$ is a complexity-theoretic measure of the matroid $M$ that lower-bounds the circuit complexity of sampling from $M$'s basis distribution.\n\n**Test**: Compute this \"determinantal complexity\" for all matroids on at most 8 elements and correlate with known matroid invariants (rank, girth, number of bases).\n\n**Impact**: Would connect matroid representability theory to algebraic complexity theory, potentially providing new lower bounds for VP vs. VNP problems.\n\n**Catalog References**: `Catalog/Pythagorean/FermionicPlucker.lean` (Cauchy\u2013Binet as determinantal representation of basis polynomials).\n\n**Proof Strategy**: Use the fact that $\\mu_A(w) = \\det(A D_w A^\\top)$ is a polynomial in $w$ of degree $r$, and relate the matrix size to the algebraic complexity of this polynomial.\n\n**Domain Bridges**: Complexity theory \u2194 algebraic geometry \u2194 matroid theory.\n\n**Lineage**: Extends the Cauchy\u2013Binet identity into the realm of algebraic complexity.\n\n**Ambition**: Grand challenge \u2014 connection to VP/VNP is highly speculative but potentially transformative.\n\n**The key insight is** that the Cauchy\u2013Binet identity gives an explicit determinantal representation of the basis-generating polynomial, and the representation size is a natural complexity measure.\n\n**Why now?** The formal proof of Cauchy\u2013Binet provides a certified determinantal representation that can be used as input to complexity-theoretic analysis.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "4c9b1112",
    "consumed_by_exp_id": "2217051e",
    "timestamp": "2026-05-26T22:26:40.549529+00:00"
  },
  {
    "id": "fd_1229",
    "title": "Direction 1: Path Congestion to Dirichlet Form Comparison \u2014 Completing the Pipeline",
    "description": "**Conjecture**: If \u0393 is a path system routing P-edges through Q-edges with congestion \u03c1 (as defined by `PathCongestion`), then E_P(f) \u2264 \u03c1 \u00b7 E_Q(f) for all f. Combined with the formally verified `poincare_comparison`, this would yield \u03bb(Q) \u2265 \u03bb(P)/\u03c1 \u2014 the full canonical-path theorem for non-group chains.\n\n**Test**: Verify on all reversible chains on \u2264 6 states that the congestion bound correctly predicts the Dirichlet form comparison constant within a factor of 2. A counterexample with ratio > 2 would indicate the congestion definition needs refinement.\n\n**Impact**: Completes the formal pipeline from combinatorial path data to certified spectral gaps, making the comparison theorem immediately applicable to any chain where explicit paths can be constructed.\n\n**Catalog References**:\n- `Pythagorean/CayleyExpander/CanonicalPaths.lean` \u2014 `variance_le_congestion_mul_energy`\n- `Pythagorean/MarkovComparison/NonGroupComparison.lean` \u2014 `poincare_comparison`\n\n**Proof Strategy**: The proof requires a telescoping argument along paths (generalizing `telescope_word` from the Cayley catalog) combined with Cauchy\u2013Schwarz. The key step is: (f(x) - f(y))\u00b2 \u2264 |\u03b3| \u00b7 \u03a3_{e \u2208 \u03b3} (\u2207_e f)\u00b2. Sum over x,y weighted by \u03c0(x)P(x,y), swap the order of summation, and use the congestion bound.\n\n**Domain Bridges**: Probability theory \u2194 Combinatorial optimization (congestion as a graph property)\n\n**Lineage**: Direct descendant of `sqDiff_le_len_mul_sum_sqDiffs` from `CanonicalPaths.lean`\n\n**Ambition**: \ud83d\udd34 Paradigm shift \u2014 removes the last group-theoretic dependency from the canonical-path method\n\n**The key insight is** that the telescoping + Cauchy\u2013Schwarz argument uses only path structure, not group multiplication, so it transfers directly to non-group chains with the same formal structure.\n\n**Why now?** The comparison theorem is verified, the definitions of `PathCongestion` and `dirichletForm` are in place, and the proof template from `CanonicalPaths.lean` provides a clear roadmap.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "4a19dada",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T23:05:03.278928+00:00"
  },
  {
    "id": "fd_1230",
    "title": "Direction 2: Quantitative Mixing Time Bounds via Comparison Transport",
    "description": "**Conjecture**: For any chain P compared to reference Q via `ReversibleChainComparison` with parameters (b, C), the mixing time satisfies t_mix(P, \u03b5) \u2264 (b\u00b7C/\u03bb(Q)) \u00b7 (log|\u03b1| + log(1/\u03b5)). Moreover, the prefactor b\u00b7C is tight up to constants for the class of \"lazy path walks compared to jump walks.\"\n\n**Test**: Compute exact mixing times (defined as first time TV distance < 1/4) for all reversible chains on 5 states, and verify the predicted bound is within a factor of n of the truth.\n\n**Impact**: Creates the first formally certified mixing time bounds for non-group chains, with practical implications for MCMC stopping rules.\n\n**Catalog References**:\n- `Pythagorean/CayleyExpander/MixingTime.lean` \u2014 `tv_le_half_sqrt_card_mul_l2`\n- `Pythagorean/MarkovComparison/NonGroupComparison.lean` \u2014 `spectralGap_lower_bound_of_dirichlet_comparison`\n\n**Proof Strategy**: Combine the comparison theorem's spectral gap bound with the TV-L\u00b2 comparison from `MixingTime.lean`. The L\u00b2 distance at time t satisfies ||P^t - \u03c0||\u00b2_{L\u00b2(\u03c0)} \u2264 (1-\u03bb)^{2t} \u00b7 (|\u03b1|-1), and TV \u2264 (1/2)\u221a(|\u03b1|) \u00b7 ||\u00b7||_{L\u00b2}.\n\n**Domain Bridges**: Probability theory \u2194 Algorithms (MCMC stopping rules) \u2194 Statistics (sampling guarantees)\n\n**Lineage**: Combines two catalog lineages: comparison (this work) and mixing time (CayleyExpander)\n\n**Ambition**: \ud83d\udfe1 Solid extension \u2014 connects existing verified results into a practical tool\n\n**The key insight is** that the comparison theorem produces a spectral gap bound in exactly the form needed by the mixing time machinery already formalized in the catalog.\n\n**Why now?** Both the comparison theorem and the mixing time infrastructure are verified; the connection is a straightforward composition.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "4a19dada",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T23:05:03.316466+00:00"
  },
  {
    "id": "fd_1231",
    "title": "Direction 3: Information-Theoretic Comparison via Modified Log-Sobolev Inequalities",
    "description": "**Conjecture**: The comparison method extends to modified log-Sobolev inequalities (MLSI): if chain Q satisfies MLSI with constant \u03b1_Q, and the \"entropy comparison constant\" C_ent satisfies Ent_Q(f\u00b2) \u2264 C_ent \u00b7 Ent_P(f\u00b2), then P satisfies MLSI with constant \u03b1_Q/C_ent. This would give O(log log n) mixing time improvements over the Poincar\u00e9 route.\n\n**Test**: For the Glauber dynamics on the Ising model at \u03b2 < \u03b2_c (high temperature), verify computationally that the MLSI constant scales polynomially in n, while the Poincar\u00e9 constant scales polynomially with a worse exponent.\n\n**Impact**: Bridges probability theory to information theory through entropy methods, and provides exponentially better mixing bounds for chains with hypercontractive properties.\n\n**Catalog References**:\n- `Pythagorean/CayleyExpander/LogSobolev.lean` \u2014 log-Sobolev infrastructure\n- `Pythagorean/MarkovComparison/NonGroupComparison.lean` \u2014 comparison framework\n\n**Proof Strategy**: Replace variance with entropy, Dirichlet form with entropy dissipation, and adapt the comparison argument. The key difficulty is that entropy is not a quadratic functional, so the \"choose optimal c\" trick from variance comparison needs modification.\n\n**Domain Bridges**: Probability theory \u2194 Information theory (entropy, KL divergence) \u2194 Quantum information (hypercontractivity)\n\n**Lineage**: Extension of comparison framework + log-Sobolev catalog\n\n**Ambition**: \ud83d\udd34 Grand challenge \u2014 would create the first formally verified MLSI comparison theorem\n\n**The key insight is** that the comparison principle is fundamentally about transferring functional inequalities, and the Poincar\u00e9 inequality is just one instance of a general pattern that includes log-Sobolev, Nash, and Beckner inequalities.\n\n**Why now?** The log-Sobolev infrastructure exists in the catalog, and the comparison framework provides the template for the proof structure.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "4a19dada",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T23:05:03.356788+00:00"
  },
  {
    "id": "seed_005",
    "title": "P vs NP Problem",
    "description": "Prove or disprove that P = NP. Formalize known barriers: relativization, natural proofs, algebrization. Explore circuit complexity lower bounds, proof complexity, and connections to cryptographic hardness assumptions.",
    "domains": [
      "Computation",
      "Logic"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.322674+00:00"
  },
  {
    "id": "seed_002",
    "title": "Riemann Hypothesis",
    "description": "Prove that all non-trivial zeros of the Riemann zeta function lie on Re(s)=1/2. Formalize equivalent statements: the prime counting function error bound, the Mertens conjecture connection, or the spectral interpretation via random matrix theory. Explore connections to quantum chaos and the Hilbert-Polya conjecture.",
    "domains": [
      "NumberTheory",
      "Analysis"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.302055+00:00"
  },
  {
    "id": "seed_004",
    "title": "Twin Prime Conjecture",
    "description": "Prove that there are infinitely many pairs of primes differing by 2. Formalize Zhang's bounded gaps result and Maynard-Tao improvements. Explore connections to the Hardy-Littlewood conjecture and sieve theory.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.93,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.316578+00:00"
  },
  {
    "id": "fd_0806",
    "title": "Tropical Shadow of p-adic Persistent Homology",
    "description": "Conjecture: For any finite filtered chain complex over the integers with finitely generated homology in each degree, the primewise barcode data obtained after reduction/localization at varying primes p determines a piecewise-linear tropical hypersurface whose combinatorial type stabilizes for all sufficiently large p, and this stabilized tropical object is a complete invariant of the asymptotic torsion-birth structure up to filtered quasi-isomorphism in a generic class of filtrations. Test: Compute primewise barcodes for broad families of filtrations, tropicalize the valuation profile of birth/death parameters across primes, and check whether non-isomorphic generic filtrations with identical stabilized tropical shadows exist; a single counterexample refutes completeness, while repeated recovery across synthetic and natural datasets supports it. Impact: This would create a new bridge between topological data analysis, arithmetic topology, and tropical geometry, enabling compression of infinitely many prime-dependent persistence signatures into a finite geometric object and potentially yielding new classification and stability theorems.",
    "domains": [
      "Topological Data Analysis",
      "Tropical Geometry"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T00:26:01.272574+00:00"
  },
  {
    "id": "fd_0907",
    "title": "Spectral Sequence Stability via Persistent Homology Barcodes",
    "description": "Conjecture: For first-quadrant homological spectral sequences E\u2081 \u21d2 H, if two spectral sequences have E\u2081 pages that are \u03b5-interleaved as bigraded persistence modules (with respect to the total-degree filtration), then their 'limit barcodes' \u2014 which record elements surviving to E\u221e as infinite bars and elements killed by d_r as finite bars of length r \u2014 are C\u00b7\u03b5-interleaved for a constant C depending only on the spectral sequence length (max page index). Test: For the Serre spectral sequences of the Hopf fibration S\u00b9\u2192S\u00b3\u2192S\u00b2 and its small perturbations (e.g., replacing S\u00b3 with a lens space L(3,1)), compute the E\u2081 interleaving distance and verify that the limit barcodes satisfy the conjectured stability bound. Secondary test on pairs of Adams spectral sequences for related spectra. Impact: This would establish the first stability theorem for spectral sequences, making differential computations robust under perturbation \u2014 with transformative applications to stable homotopy theory (Adams SS), symplectic topology (Eilenberg-Moore SS), and algebraic geometry (Leray SS for morphisms of varieties).",
    "domains": [
      "Algebraic Topology",
      "Topological Data Analysis",
      "Spectral Sequences"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:59:02.941963+00:00"
  },
  {
    "id": "fd_0908",
    "title": "p-adic Universality of Chip-Firing Critical Groups Under Graph Lifts",
    "description": "Conjecture: For every finite connected base graph G and every prime p not dividing |Jac(G)|, the sequence of p-primary critical groups of random n-sheeted lifts G_n has a universal limiting distribution, depending only on the first Betti number of G and not on finer combinatorics of G. More precisely, after normalizing by the deterministic free rank contribution, the Sylow-p subgroup of Jac(G_n) converges in law as n -> infinity to a Cohen-Lenstra-type distribution determined solely by b1(G). Test: Generate random lifts of several non-isomorphic base graphs with the same first Betti number, compute Jac(G_n), extract Sylow-p parts for increasing n, and compare empirical distributions across bases and against the predicted universal law; any persistent dependence on the detailed base graph refutes the conjecture. Impact: This would reveal a new universality class linking tropical geometry, random covering theory, sandpile groups, and arithmetic heuristics, and could provide a graph-theoretic laboratory for Cohen-Lenstra phenomena.",
    "domains": [
      "Algebraic Combinatorics",
      "Probability",
      "Arithmetic Geometry",
      "Tropical Geometry"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:03:02.506322+00:00"
  },
  {
    "id": "fd_0926",
    "title": "Prime-Local Torsion Predicts Rational Homotopy Collapse",
    "description": "Conjecture: There exists a universal function B(d) such that for any finite simply connected CW complex X of dimension d, if for every prime p the p-primary barcode of the filtered loop-space chain complex C_*(\u03a9X; Z) has all intervals of length at most B(d), then the Sullivan minimal model of X is formal and the rational homotopy spectral sequence of \u03a9X collapses at E2. Test: Compute primewise persistent torsion barcodes for explicit non-formal spaces (for example symplectic but non-Kahler manifolds, moment-angle complexes, and wedges with attached cells) and check whether long p-primary intervals always appear; confirm on formal spaces (compact Kahler manifolds, spheres, projective spaces) that bounded intervals suffice. A single non-formal counterexample with uniformly bounded primewise torsion persistence refutes the conjecture. Impact: This would create a new bridge from computable finite-prime topological signatures to deep rational homotopy structure, giving an algorithmic detector for formality and spectral sequence collapse.",
    "domains": [
      "Algebraic Topology",
      "Persistent Homology"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:40:12.492126+00:00"
  },
  {
    "id": "fd_1246",
    "title": "Direction 1: Real Stability of Determinantal Polynomials and the Full Lorentzianity Bridge",
    "description": "**Conjecture**: For any symmetric PSD matrix K \u2208 \u211d^{n\u00d7n}, the polynomial Z_K(x) = det(I + diag(x)K) is real stable (no zeros in the open upper half-plane \u210d^n). Combined with the Br\u00e4nd\u00e9n\u2013Huh theorem (real stable + nonneg coefficients \u27f9 Lorentzian), this would prove our Lorentzianity conjecture.\n\n**Test**: Formalize the following chain: (1) For z \u2208 \u210d^n, the matrix I + diag(z)K has positive definite Hermitian part. (2) Positive definite matrices have nonzero determinant. (3) Therefore Z_K(z) \u2260 0 on \u210d^n. Each step can be verified by constructing the Hermitian part explicitly and using `PosDef.det_ne_zero`.\n\n**Impact**: This completes the main theorem of the project \u2014 that DPP generating polynomials are Lorentzian \u2014 and unlocks the full cascade of Hodge-type inequalities for DPP coefficient arrays.\n\n**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (IsBrandenHuhLorentzian definition and recursive spectral certificate equivalence).\n\n**Proof Strategy**: Define real stability as a predicate on MvPolynomial. Prove that for PSD K and z \u2208 \u210d^n, the matrix I + diag(z)K has positive definite Hermitian part (this requires formalizing Im(z_i\u00b7K_{ij}) terms). Then invoke `det_ne_zero` for positive definite matrices. The Br\u00e4nd\u00e9n\u2013Huh direction (stable \u2192 Lorentzian for homogeneous components with nonneg coefficients) requires formalizing the closure theorem, which is the main technical challenge.\n\n**Domain Bridges**: Statistical physics (partition function stability) \u2194 Algebraic geometry (Lorentzian/Hodge theory) \u2194 Probability (negative association).\n\n**The key insight is** that the positive semidefiniteness of K translates directly into the half-plane stability of the partition function, which in turn implies Lorentzianity \u2014 creating a clean algebraic pipeline from linear algebra to Hodge-theoretic geometry.\n\n**Why now?** The Br\u00e4nd\u00e9n\u2013Huh theory is now mature (5+ years since publication), Mathlib has extensive matrix theory infrastructure, and our verified definitions provide the exact formalization targets.\n\n**Lineage**: Extends `dpp_partition_function_lorentzian` (currently sorry'd) and builds on `dpp_uniformSpecialization` (verified).\n\n**Ambition**: Grand challenge \u2014 completing this would be the first machine-verified proof that determinantal partition functions are Lorentzian.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "258120ed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:51:51.560054+00:00"
  },
  {
    "id": "fd_1247",
    "title": "Direction 2: Higher-Order Negative Association for DPPs",
    "description": "**Conjecture**: DPPs satisfy the full **negative association** (NA) property: for any two increasing functions f, g on disjoint sets of coordinates, Cov(f(X_A), g(X_B)) \u2264 0. This is strictly stronger than pairwise negative dependence and has deeper implications for concentration inequalities.\n\n**Test**: (1) Formalize the NA property as a predicate on probability measures. (2) Prove NA for product measures (diagonal DPPs). (3) Extend to rank-one DPPs. (4) Attempt the general case via the BBL (Borcea\u2013Br\u00e4nd\u00e9n\u2013Liggett) theorem connecting real stability to NA.\n\n**Impact**: Full NA unlocks Chernoff-type concentration bounds for DPP statistics, FKG-type correlation inequalities, and stochastic domination results.\n\n**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Lorentzian signature), `Pythagorean/DPPLorentzian.lean` (DPP definitions and pairwise result).\n\n**Proof Strategy**: The BBL theorem states that strongly Rayleigh measures (whose generating polynomial is real stable) satisfy NA. If Direction 1 succeeds, DPPs are strongly Rayleigh, and NA follows. The key formalization challenge is the BBL proof itself, which uses multivariate analytic continuation arguments.\n\n**Domain Bridges**: Probability theory (negative association) \u2194 Statistical mechanics (FKG inequalities) \u2194 Algorithms (concentration bounds for randomized algorithms).\n\n**The key insight is** that negative association is not merely a statistical property but a geometric consequence of the polynomial's stability, which forces all monotone correlations to have the correct sign.\n\n**Why now?** Our pairwise result provides the base case, and the BBL theorem provides the roadmap.\n\n**Lineage**: Extends `dpp_pairwise_negative_dependence` (verified) to all monotone functions, not just indicator functions.\n\n**Ambition**: Solid extension \u2014 the BBL theorem is well-understood mathematically, though formalizing multivariate analytic arguments is technically demanding.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "258120ed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:51:51.600857+00:00"
  },
  {
    "id": "fd_1248",
    "title": "Direction 3: Matroid Exchange Property and Lorentzian Support Theory",
    "description": "**Conjecture**: The support of every homogeneous component of a DPP generating polynomial satisfies the symmetric exchange property (is a matroid basis set). This would connect DPP theory to matroid Hodge theory (Adiprasito\u2013Huh\u2013Katz).\n\n**Test**: (1) For random PSD matrices with n \u2264 10, extract the support of each homogeneous component. (2) Verify the exchange axiom: for any two d-subsets S, T in the support and any i \u2208 S\\T, there exists j \u2208 T\\S such that (S \u2212 i + j) and (T + i \u2212 j) are both in the support. (3) Identify the matroid (it should be the uniform matroid for generic K).\n\n**Impact**: This would provide a new source of matroids \u2014 one arising from spectral data \u2014 and connect the Lorentzian polynomial theory to the matroid Hodge theory that resolved the Rota\u2013Heron\u2013Welsh conjecture.\n\n**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (SupportSatisfiesExchange definition).\n\n**Proof Strategy**: For generic PSD K, all principal minors of size d are nonzero, so the support is the set of all d-subsets = uniform matroid. The interesting case is degenerate K (low rank), where the support becomes a proper matroid. The Br\u00e4nd\u00e9n\u2013Huh theorem guarantees the exchange property for Lorentzian polynomial supports.\n\n**Domain Bridges**: Algebraic combinatorics (matroid theory) \u2194 Algebraic geometry (Hodge theory) \u2194 Probability (DPP support structure).\n\n**The key insight is** that the matroid exchange property of Lorentzian polynomial supports is not an abstract axiom but a concrete structural property of DPP coefficient arrays, visible in the rank structure of the kernel matrix.\n\n**Why now?** The SupportSatisfiesExchange predicate already exists in the catalog.\n\n**Lineage**: Builds on `dpp_partition_function_lorentzian` (conjecture) and connects to matroid theory.\n\n**Ambition**: Solid extension \u2014 the exchange property for Lorentzian supports is already proved by Br\u00e4nd\u00e9n\u2013Huh; the formalization connects it to DPPs.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "258120ed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:51:51.641720+00:00"
  },
  {
    "id": "fd_1249",
    "title": "Direction 4: Quantum DPPs and Entanglement Bounds via Lorentzian Geometry",
    "description": "**Conjecture**: The von Neumann entropy of a fermionic Gaussian state is bounded by a function of the Lorentzian signature of its generating polynomial. Specifically, the number of positive Hessian eigenvalues at degree-2 derivative leaves of Z_K provides a lower bound on the entanglement entropy across bipartitions.\n\n**Test**: (1) Compute the von Neumann entropy S(\u03c1) = \u2212Tr(\u03c1 log \u03c1) for the reduced density matrix of a fermionic Gaussian state with covariance K. (2) Compute the Lorentzian Hessian signatures at all derivative leaves. (3) Test whether min(S(\u03c1)) over bipartitions correlates with max(num_positive_eigenvalues) over Hessian leaves.\n\n**Impact**: This would create a new bridge between quantum information theory and Lorentzian polynomial geometry, potentially yielding computable entanglement witnesses from polynomial coefficient data.\n\n**Catalog References**: `Pythagorean/DPPLorentzian.lean` (DPP kernel and partition function definitions).\n\n**Proof Strategy**: Fermionic Gaussian states have correlation matrices that are DPP kernels. The partition function Z_K encodes the full statistics of particle number measurements. The Lorentzian condition constrains the fluctuation structure, which should bound entanglement. The key technical step is relating the Hessian signature (a polynomial-geometric object) to the entanglement spectrum (a quantum-informatic object).\n\n**Domain Bridges**: Quantum information theory (entanglement) \u2194 Statistical mechanics (fermionic systems) \u2194 Algebraic geometry (Lorentzian polynomials).\n\n**The key insight is** that entanglement in fermionic systems is dual to the Lorentzian signature of the partition function \u2014 both measure the \"width\" of the probability distribution over subset sizes.\n\n**Why now?** Quantum computing is driving demand for computable entanglement bounds, and the DPP\u2013Lorentzian connection provides a new algebraic tool.\n\n**Lineage**: Extends the DPP framework to quantum systems.\n\n**Ambition**: Grand challenge \u2014 paradigm-shifting if successful, connecting quantum information to Hodge theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "258120ed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:51:51.722911+00:00"
  },
  {
    "id": "fd_1250",
    "title": "Direction 5: Certified DPP Sampling with Lorentzian Guarantees",
    "description": "**Conjecture**: There exists a polynomial-time algorithm that, given a PSD kernel K and parameters \u03b5, \u03b4, produces a sample S from a distribution within \u03b5 total variation distance of the DPP, together with a machine-checkable certificate that the sample satisfies negative dependence up to additive error \u03b4.\n\n**Test**: (1) Implement an approximate DPP sampler based on eigendecomposition. (2) For each sample, compute the empirical correlation ratio and compare to the theoretical bound of 1. (3) Generate a Lorentzian certificate by checking the Hessian signature condition for the empirical distribution.\n\n**Impact**: Certified sampling would enable DPPs to be used in safety-critical applications (medical trial design, autonomous systems) where diversity guarantees must be provably correct.\n\n**Catalog References**: `Pythagorean/DPPLorentzian.lean` (negative dependence theorem, spectral bridge), `algorithms.py` (Hessian recognizer).\n\n**Proof Strategy**: The sampling algorithm uses the spectral decomposition K = U\u039bU^T to sample in eigenspace, then projects. The certificate consists of: (1) the eigendecomposition (verifiable by matrix multiplication), (2) the Hessian signature check (verifiable by eigenvalue computation), (3) the correlation ratio bound (verifiable by arithmetic). Each certificate is machine-checkable in O(n\u00b3) time.\n\n**Domain Bridges**: Algorithm design (certified computation) \u2194 Machine learning (DPP sampling) \u2194 Formal verification (proof certificates).\n\n**The key insight is** that the Lorentzian structure provides not just existence proofs but computational certificates \u2014 the Hessian signature test is a concrete, checkable condition that implies the probabilistic guarantee.\n\n**Why now?** Trustworthy AI demands certified algorithms, and DPPs are among the most widely used probabilistic models with certifiable properties.\n\n**Lineage**: Extends `certify_pairwise_negative_dependence` (implemented in Python) to full sampling with Lorentzian certificates.\n\n**Ambition**: Solid extension \u2014 builds directly on verified theorems and existing algorithms.",
    "domains": [
      "Pythagorean",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "258120ed",
    "consumed_by_exp_id": "f44ba709",
    "timestamp": "2026-05-27T00:51:51.763159+00:00"
  },
  {
    "id": "seed_013",
    "title": "Odd Perfect Numbers",
    "description": "Prove that no odd perfect numbers exist. Formalize known constraints: must exceed 10^1500, have at least 101 prime factors, satisfy Euler's form p^a * m^2. Connect to the structure of multiplicative functions.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.378958+00:00"
  },
  {
    "id": "seed_052",
    "title": "Tropical Convexity and Helly Theorem",
    "description": "Prove a tropical analogue of Helly's theorem: characterize when tropical convex sets have non-empty intersection. Formalize tropical convex hulls and their connection to optimization.",
    "domains": [
      "Tropical",
      "Geometry",
      "Computation"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.679862+00:00"
  },
  {
    "id": "seed_024",
    "title": "Legendre's Conjecture",
    "description": "Prove that for every positive integer n, there exists a prime between n\u00b2 and (n+1)\u00b2. Formalize known partial results on prime gaps and connect to the Cram\u00e9r model of primes.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.470511+00:00"
  },
  {
    "id": "seed_025",
    "title": "Primes of the Form n\u00b2+1",
    "description": "Prove that there are infinitely many primes of the form n\u00b2+1. Formalize Iwaniec's result on semi-primes of this form and connect to Friedlander-Iwaniec theorem on primes of form a\u00b2+b\u2074.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.477681+00:00"
  },
  {
    "id": "seed_006",
    "title": "Collatz Conjecture",
    "description": "Prove that the 3n+1 iteration eventually reaches 1 for all positive integers. Formalize partial results on density of convergent integers, stopping times, and connections to ergodic theory and p-adic dynamics.",
    "domains": [
      "NumberTheory",
      "Computation"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.330478+00:00"
  },
  {
    "id": "seed_033",
    "title": "Schanuel's Conjecture",
    "description": "Prove Schanuel's conjecture: if z\u2081,...,z\u2099 are Q-linearly independent complex numbers, then the transcendence degree of {z\u2081,...,z\u2099,e^z\u2081,...,e^z\u2099} over Q is at least n. Formalize implications for the Lindemann-Weierstrass theorem.",
    "domains": [
      "NumberTheory",
      "Analysis"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.537163+00:00"
  },
  {
    "id": "seed_092",
    "title": "Inverse Stereographic Persistence: Topological Data Analysis on Spheres",
    "description": "Persistent homology computes topological features of data at multiple scales. On spheres, the natural metric is the geodesic (spherical) distance, but existing algorithms assume Euclidean data. Use stereographic projection to transform spherical persistence to weighted Euclidean persistence. Define the stereographic persistence module for a point cloud X on S^n: for each filtration parameter epsilon, compute the Cech complex C_epsilon(X) on S^n using the spherical metric, then apply inverse stereographic projection to get a filtered complex on R^n with a conformal weight. Conjecture: The persistence diagram of a point cloud on S^n computed with the geodesic metric is equal to the persistence diagram of the projected point cloud on R^n computed with a conformally weighted distance d_w(x,y) = 2*d(x,y)/(1+d(x,y)^2/4). This equality holds because stereographic projection is a conformal isometry up to the conformal factor, and persistence diagrams are invariant under conformal transformations. This gives an O(N log N) algorithm for spherical persistence (vs O(N^2) for direct computation). Test: implement both methods and verify isometry of persistence diagrams for random spherical point clouds with N=50, 100, 200 points. Impact: fast, provably correct topological data analysis for spherical data, with applications to astrophysics (cosmic microwave background) and protein structure analysis.",
    "domains": [
      "Geometry",
      "Computation",
      "Topology"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:55.026751+00:00"
  },
  {
    "id": "seed_035",
    "title": "Kakeya Conjecture",
    "description": "Prove the Kakeya conjecture: a Besicovitch set in R\u207f has Hausdorff dimension n. Formalize the connection to restriction estimates and additive combinatorics.",
    "domains": [
      "Geometry",
      "Analysis"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.553079+00:00"
  },
  {
    "id": "seed_037",
    "title": "Cram\u00e9r's Conjecture on Prime Gaps",
    "description": "Prove that the gap between consecutive primes p_n satisfies p_{n+1} - p_n = O((log p_n)\u00b2). Formalize probabilistic models of primes and known unconditional bounds.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.567677+00:00"
  },
  {
    "id": "seed_010",
    "title": "Happy End Problem",
    "description": "Solve the happy end problem for arbitrary n: determine the minimum number of points in general position in the plane that guarantee a convex n-gon. Formalize the Erd\u0151s\u2013Szekeres theorem and improve known bounds.",
    "domains": [
      "Geometry",
      "Combinatorics"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.359184+00:00"
  },
  {
    "id": "seed_027",
    "title": "Euler-Mascheroni Constant Irrationality",
    "description": "Prove that the Euler-Mascheroni constant \u03b3 \u2248 0.5772 is irrational (or transcendental). Formalize continued fraction expansions and connect to the theory of special values of L-functions.",
    "domains": [
      "Analysis",
      "NumberTheory"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.490974+00:00"
  },
  {
    "id": "seed_036",
    "title": "Beal's Conjecture",
    "description": "Prove that if A^x + B^y = C^z where A,B,C,x,y,z are positive integers with x,y,z > 2, then A,B,C share a common prime factor. Formalize the connection to Fermat-Catalan and ABC conjecture.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.559748+00:00"
  },
  {
    "id": "seed_011",
    "title": "Perfect Cuboid (Euler Brick)",
    "description": "Find an Euler brick whose space diagonal is also an integer, or prove none exists. Formalize the parametric families of near-misses and connect to Diophantine equations on algebraic surfaces.",
    "domains": [
      "NumberTheory",
      "Geometry"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.366802+00:00"
  },
  {
    "id": "fd_0795",
    "title": "Benford Renormalization for Integer Dynamical Systems",
    "description": "Conjecture: Let T: N -> N be an integer dynamical map given by a piecewise rational rule with multiplicative expansion on average (including maps such as 3n+1, reverse-and-add, and x -> x^2+c restricted to integer orbits where defined). For every such T in a precise non-degenerate class, the mantissae of the orbit values {T^k(n)} are Benford-distributed for natural density 1 of initial seeds n if and only if the additive cocycle log_10 T^k(n) mod 1 has no nontrivial rational eigen-obstruction. Test: Formalize the obstruction criterion, then compute orbit mantissa statistics and spectral data across large families of maps; confirmation requires sharp agreement with Benford frequencies exactly in the obstruction-free cases, while any systematic non-Benford behavior in a certified obstruction-free family refutes the conjecture. Impact: This would create a new universality theory for arithmetic dynamics, linking number theory, ergodic spectra, and digit laws, and could yield a diagnostic invariant for predicting pseudorandomness and hardness in discrete algorithms.",
    "domains": [
      "Arithmetic Dynamics",
      "Ergodic Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T23:12:30.270617+00:00"
  },
  {
    "id": "fd_0818",
    "title": "Derived Equivalence Rigidity from Persistence of Point Counts",
    "description": "Conjecture: Let X and Y be smooth projective varieties over a number field K. Suppose that for a density-1 set of good primes p of K, the multisets of Frobenius eigenvalues on all l-adic cohomology groups of X and Y agree up to a degree-preserving persistent matching induced by variation over finite field extensions F_{p^r}; equivalently, their point-count generating functions produce isomorphic persistence modules in r for every cohomological degree. Then X and Y are derived equivalent, and in the Calabi-Yau case their numerical Gromov-Witten potentials agree. Test: Compute the persistence modules coming from #(X(F_{p^r})) and #(Y(F_{p^r})) for known pairs of derived-equivalent and non-derived-equivalent varieties (abelian varieties, K3 surfaces, Calabi-Yau hypersurfaces, toric mirrors) and check whether the proposed invariant separates the latter while identifying the former. A single counterexample pair with matching persistence data but provably non-derived-equivalent refutes the conjecture. Impact: This would create a new arithmetic-topological criterion for detecting derived equivalence and potentially connect point counts, motives, mirror symmetry, and persistent homology in a computable way.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T00:54:49.105761+00:00"
  },
  {
    "id": "fd_0849",
    "title": "Prime-Variation Detection of Sato\u2013Tate Drift via Persistent Homology",
    "description": "Conjecture: Let E/Q be an elliptic curve without complex multiplication, and for each prime p of good reduction let a_p be its Frobenius trace. Build a filtered complex K_X from the point cloud {(p/X, a_p/(2\\sqrt{p})) : p \\le X} using a canonical metric and Vietoris\u2013Rips filtration. Then the persistence landscape of K_X converges, as X -> \\infty, to a universal limit determined only by the Sato\u2013Tate measure; moreover, if one replaces E by a CM elliptic curve or by an isogeny-non-equivalent non-CM curve with an exceptional low-lying zero bias in its L-function, the limiting landscape differs in a statistically detectable way. Test: Compute landscapes for large X across many non-CM curves, CM curves, and families with different analytic ranks; confirm universality within the non-CM class and refute by finding stable curve-dependent deviations, or confirm distinction by a reproducible classifier separating CM/non-CM or rank-biased families from persistence data alone. Impact: This would create a new topological statistic for arithmetic distributions, linking persistent homology to Frobenius statistics, Sato\u2013Tate theory, and L-function phenomenology.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T03:07:22.429094+00:00"
  },
  {
    "id": "fd_0857",
    "title": "Persistent Homology Detects Arithmetic Mirror Symmetry via Primewise Frobenius B",
    "description": "Conjecture: There exists a canonical construction assigning to each smooth projective Calabi\u2013Yau variety X over Q a family of filtered complexes K_p(X) for good primes p such that if X and Y form a mirror pair, then for a density-1 set of primes p their primewise persistence landscapes agree after an explicit degree-reversal transform induced by Hodge duality, while for non-mirror Calabi\u2013Yau varieties this agreement fails on a positive-density set of primes. Test: Compute K_p(X) from point-count/Frobenius data for known mirror families and compare transformed persistence landscapes across many good primes; confirmation is density-1 agreement for mirrors and systematic disagreement for controls. Refutation is failure on known mirror pairs or widespread false positives among non-mirrors. Impact: This would create a new arithmetic-topological invariant for mirror symmetry, linking p-adic/\u00e9tale data, persistent homology, and enumerative geometry, and could provide a computable signature for detecting hidden mirror partners.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T03:08:57.522301+00:00"
  },
  {
    "id": "fd_0901",
    "title": "Algorithmic Independence of Primewise Persistence Profiles",
    "description": "Conjecture: There exists an explicit arithmetic family of filtered chain complexes C(N) over Z, computable from N in polynomial time, such that for infinitely many cutoffs N the collection of primewise barcode summary vectors B_p(C(N)) (for p <= polylog N) is pairwise algorithmically independent in the following testable sense: no predictor running in time poly(log N) and given {B_q(C(N)) : q != p, q <= polylog N} can recover B_p(C(N)) with advantage exceeding o(1) over the empirical base rate. Test: instantiate a canonical family C(N) (e.g. from arithmetic lattices, modular-symbol complexes, or filtered congruence complexes), compute B_p across many primes, and evaluate whether cross-prime prediction accuracy provably/empirically stays at chance while within-prime structure remains highly nontrivial. Refutation occurs if a uniform low-complexity predictor consistently reconstructs one prime's persistence from the others. Impact: This would reveal a new form of arithmetic pseudorandomness visible only through topological summaries, suggesting persistence as a probe of hidden independence phenomena across primes and enabling topology-based randomness tests for arithmetic objects.",
    "domains": [
      "Arithmetic Topology",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:15:46.019869+00:00"
  },
  {
    "id": "fd_0920",
    "title": "Prime-Sensitive Torsion Echoes in Random Flag Complexes",
    "description": "Conjecture: In the Linial\u2013Meshulam random flag complex process X(n,p), there exists a dimension k >= 1 and a nontrivial interval of densities p = p(n) near the k-th homological phase transition such that the p-primary torsion profile of H_k(X; Z) is asymptotically non-universal across primes: specifically, after normalizing by the expected Betti-scale size, the distribution of v_ell(|Tor H_k(X; Z)|) depends on the prime ell and does not collapse to a single prime-independent law. Test: Sample random flag complexes in the critical window, compute integer homology, and compare the empirical laws of v_ell(|Tor H_k|) for several primes ell; the conjecture is refuted if these laws converge to the same universal distribution after normalization, and supported if statistically stable prime-dependent distributions persist with n. Impact: This would reveal a new arithmetic layer in random topology, showing that homological phase transitions carry genuine prime-specific structure rather than only field-coefficient universality, opening a bridge between probabilistic topology, torsion asymptotics, and arithmetic statistics.",
    "domains": [
      "Random Topology",
      "Arithmetic Topology"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:39:42.310379+00:00"
  },
  {
    "id": "fd_0942",
    "title": "Prime-Stable Minors Force Arithmetic Periodicity in Integer Persistence",
    "description": "Conjecture: Let C(N) be an explicitly computable family of finite filtered chain complexes over Z, indexed by N, whose boundary matrices have entries given by polynomial functions of N. If for every prime p outside a finite exceptional set, the multiset of p-adic valuations of all nonzero maximal minors of the boundary maps is eventually periodic in N modulo some M(p), then the primewise persistence barcodes of C(N) are eventually periodic in N for a set of primes of natural density 1. Test: Construct concrete polynomial-boundary families C(N), compute Smith normal forms and primewise barcodes across many N and p, and check whether periodicity of valuation data predicts eventual barcode periodicity; a counterexample is any family where minor-valuation periodicity holds but barcode periodicity fails on a positive-density set of primes. Impact: This would create a new bridge from arithmetic combinatorics of matrix minors to topological dynamics of persistence, enabling prediction and compression of infinite arithmetic persistence families via finite congruence data.",
    "domains": [
      "Persistent Homology",
      "Arithmetic Combinatorics"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:12:46.036335+00:00"
  },
  {
    "id": "fd_1131",
    "title": "Persistent Homology as a Detector of Hidden Automaticity in Integer Sequences",
    "description": "Conjecture: There exists a computable functor from an integer sequence a(n) with finite-valued local rule description to a family of filtered simplicial complexes K_N(a) such that a(n) is p-automatic for some prime p if and only if, for all sufficiently large N, the primewise persistent homology profiles of K_N(a) over F_p are eventually generated by a finite-state transducer and exhibit ultimately periodic barcode statistics, while for every non-p-automatic sequence in the same rule class this periodicity fails on a density-1 set of scales. Test: Construct K_N(a) for benchmark families (Thue-Morse, Rudin-Shapiro, sum-of-digits, paperfolding, polynomial phase sequences, multiplicative sequences) and algorithmically check whether barcode summary statistics over F_p become eventually automaton-recognizable/periodic exactly in the automatic cases; a single nonautomatic sequence with stable periodic profiles, or an automatic sequence lacking them, refutes the conjecture. Impact: This would create a topological criterion for automaticity, linking finite automata, arithmetic dynamics, and persistent homology, and could open a new route to classifying low-complexity arithmetic structure through geometric invariants rather than symbolic methods.",
    "domains": [
      "Topological Data Analysis",
      "Automata Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T13:06:00.281798+00:00"
  },
  {
    "id": "fd_1170",
    "title": "Universality of Smith Normal Form Fluctuations in Random Filtered Chain Complexe",
    "description": "Conjecture: Let C be a random finite filtered chain complex over Z whose boundary matrices are sparse with i.i.d. integer entries from any mean-zero distribution with finite variance, conditioned on \u2202^2 = 0 by a local projection procedure. After centering by rank and rescaling filtration index, the joint distribution of p-adic valuation profiles of the invariant factors in the Smith normal forms converges, for every fixed homological degree and finite set of primes p, to a universal limit independent of the entry distribution. Test: Generate ensembles from distinct input laws (Bernoulli, discrete Gaussian, bounded uniform), compute Smith normal forms across filtration levels, and compare the empirical laws of invariant-factor valuation processes; confirmation is convergence to the same limit across laws, refutation is persistent distribution-dependent behavior. Impact: This would found a universality theory for torsion in arithmetic persistent homology, giving a statistical baseline for detecting genuinely arithmetic structure versus random noise.",
    "domains": [
      "Arithmetic Topology",
      "Random Matrix Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T16:00:57.658670+00:00"
  },
  {
    "id": "fd_1214",
    "title": "Renormalization Fixed Points for Primewise Torsion in Random Simplicial Complexe",
    "description": "Conjecture: For the Linial\u2013Meshulam random simplicial complex process Y_d(n,p), there exists for each dimension d >= 2 a nontrivial scaling window p = n^{-1/d}(c + o(1)) and a universal renormalization operator R on prime-indexed torsion persistence profiles T_p(Y_d) such that, after rescaling birth/death parameters and prime weights, the joint law of {T_p(Y_d)}_p converges to a dimension-dependent fixed point distribution independent of the microscopic model details (e.g. Bernoulli vs bounded-degree perturbations of the process). Test: Compute primewise torsion barcodes for large random complexes across multiple ensemble variants and dimensions, fit the induced profile evolution under coarse-graining, and check whether the rescaled distributions collapse to the same limiting law; refuted if limiting laws depend essentially on the ensemble or no stable fixed point appears. Impact: This would create a statistical-physics theory of arithmetic topology, giving universal laws for how torsion emerges across primes and scales, and supplying predictive tools for random topology, coding theory, and arithmetic-inspired TDA.",
    "domains": [
      "Random Topology",
      "Statistical Physics"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T22:26:50.427241+00:00"
  },
  {
    "id": "fd_1215",
    "title": "Adversarial Prime Camouflage for Persistent Arithmetic Topology",
    "description": "Conjecture: There exists an explicit infinite family of pairs of finite filtered chain complexes over Z, (C_n, D_n), such that for every prime p <= poly(log n), the mod-p persistent homology barcodes of C_n and D_n are identical, but their integral persistent invariants differ in a way detectable by extension data or Smith normal forms at some prime q > poly(log n). Test: Construct candidate pairs algorithmically and compute all mod-p barcodes up to the camouflage threshold together with full integer persistence data; the conjecture is confirmed if the low-prime profiles are indistinguishable while the integral structures provably diverge, and refuted if bounded-prime agreement always forces global agreement in the constructed family. Impact: This would reveal a genuine information-theoretic gap between primewise and integral persistence, establish lower bounds for arithmetic reconstruction from local data, and motivate cryptographic-style hardness notions and new completeness invariants for persistence over Z.",
    "domains": [
      "Topological Data Analysis",
      "Algebraic Topology"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T22:27:21.399604+00:00"
  },
  {
    "id": "fd_1227",
    "title": "Barcode Rigidity for Isospectral but Non-Isometric Arithmetic Manifolds",
    "description": "Conjecture: There exists a canonical filtration functor F from compact arithmetic locally symmetric spaces M to finite filtered chain complexes over Z such that (i) if M and N are Sunada-isospectral but non-isometric, then their ordinary Laplace spectra agree while the primewise torsion persistence profiles of F(M) and F(N) differ for infinitely many good primes p; and (ii) within each commensurability class, equality of these primewise persistence profiles for a density-1 set of primes forces M and N to be isometric. Test: Construct F explicitly for known Sunada pairs or Vigneras-type isospectral manifolds, compute primewise barcodes/torsion birth multisets at many primes, and check whether the profiles separate the pair; refutation occurs if a canonical reasonable F fails systematically on such examples or if non-isometric examples remain indistinguishable across almost all primes. Impact: This would provide a genuinely new geometric invariant stronger than Laplace spectrum, linking arithmetic topology, isospectral geometry, and persistent homology, and could open a route to 'hearing' hidden arithmetic structure beyond classical spectral data.",
    "domains": [
      "Arithmetic Geometry",
      "Spectral Geometry"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T22:28:15.962705+00:00"
  },
  {
    "id": "fd_1244",
    "title": "Persistent Homology Phase Transition at the Arithmetic Rank of Elliptic Curves",
    "description": "Conjecture: Let E/Q be an elliptic curve, and for each good prime p define a filtered simplicial complex K_p(E) from the sequence of normalized Frobenius traces a_p/(2\\sqrt{p}) by taking sliding windows of length w and building a Vietoris\u2013Rips filtration in the ambient Euclidean space. As w and the prime cutoff X both grow with w = o(log log X), the limiting barcode statistics of {K_p(E)}_{p\\le X} exhibit exactly rank(E(Q)) + 1 stable persistence bands in degree 1, with the extra bands absent for rank 0 curves. Test: Compute the construction for large databases of elliptic curves of known algebraic rank; confirmation requires that the number of statistically stable H1 bands matches rank+1 across families, while systematic failure on rank-labeled datasets refutes the conjecture. Impact: This would create a topological observable for Mordell\u2013Weil rank, suggesting a new bridge between arithmetic statistics, dynamical embeddings of Frobenius data, and topological data analysis.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:15:28.490986+00:00"
  },
  {
    "id": "fd_1245",
    "title": "Arithmetic Universality of Torsion in Random Integer Chain Complexes",
    "description": "Conjecture: For random finite filtered chain complexes over Z with sparse i.i.d. bounded integer boundary entries, the p-primary barcode process in any fixed homological degree converges, after explicit normalization, to a universal limit law independent of the entry distribution for all but finitely many primes p; moreover the exceptional-prime set is asymptotically determined only by the local divisibility profile of the entry distribution. Test: Sample ensembles with different bounded entry laws (e.g. symmetric Bernoulli, uniform on {-2,-1,0,1,2}, sparse Poisson-truncated) and compare normalized p-primary persistence statistics prime-by-prime; confirmation requires collapse onto the same limiting law for generic primes and systematic deviation only at predicted exceptional primes, while persistent law-dependence at generic primes refutes it. Impact: This would create a universality theory for arithmetic topology, linking random matrix Smith normal form phenomena, persistent homology, and local-global arithmetic structure, and would give principled null models for detecting genuinely non-random arithmetic-topological signals.",
    "domains": [
      "Random Topology",
      "Algebraic Topology",
      "Arithmetic Statistics",
      "Random Matrix Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:16:01.142031+00:00"
  },
  {
    "id": "fd_1251",
    "title": "Direction 1: Hessian-Based Lorentzian Gap from MvPolynomial Infrastructure",
    "description": "**Conjecture:** For the measurement distribution \u03bc of a gapped free-fermionic ground state, the generating polynomial P_\u03bc \u2208 MvPolynomial (Fin n) \u211d has a Hessian matrix at the all-ones point with at most one positive eigenvalue, and the gap between the largest and second-largest eigenvalue is bounded below by \u03a9(\u0394(H)/poly(n)).\n\n**Test:** Formalize the generating polynomial P_\u03bc(z) = \u03a3_S \u03bc(S) \u03a0_{i\u2208S} z\u1d62 using Mathlib's `MvPolynomial`. Compute the Hessian matrix \u2202\u00b2P/\u2202z\u1d62\u2202z\u2c7c at z = 1. Verify the eigenvalue signature computationally for the TFIM on n = 3,4,5 qubits, then formalize the free-fermion case using determinantal identities.\n\n**Impact:** This would give the first formalized *concrete* Lorentzian gap, replacing the abstract `GappedMeasurementLift` with a computable invariant. Combined with the existing perturbation theorems, it would complete the pipeline for free-fermionic + perturbation systems.\n\n**Catalog References:**\n- `Catalog/Pythagorean/QuantumLorentzianBridge.lean` \u2014 GappedMeasurementLift, RobustLorentzianCertificate\n- `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` \u2014 HasGappedSignature, QuadFormBound\n- `Catalog/Pythagorean/LorentzianSpectralGap.lean` \u2014 spectral gap infrastructure\n\n**Proof Strategy:** Use the determinantal structure of free-fermionic states: \u03bc(S) = det(K_S) for a correlation matrix K. The Hessian of P_\u03bc at z=1 relates to K via Jacobi's complementary minor formula. The signature then follows from the eigenvalue structure of K.\n\n**Domain Bridges:** Algebraic geometry (polynomial Hessians) \u2194 quantum many-body physics (free fermions) \u2194 spectral graph theory (eigenvalue gaps)\n\n**Lineage:** Direct extension of current work. Requires MvPolynomial + Matrix eigenvalue formalization.\n\n**Ambition:** Grand challenge \u2014 would open the first concrete, computable instance of the full quantum\u2192Lorentzian\u2192classical pipeline.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.7999999999999999,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "d97a486b",
    "consumed_by_exp_id": "492f937d",
    "timestamp": "2026-05-27T00:52:11.201424+00:00"
  },
  {
    "id": "fd_1252",
    "title": "Direction 2: Entropic Area Laws from Strong Log-Concavity",
    "description": "**Conjecture:** If the measurement distribution \u03bc of a 1D ground state has a strongly log-concave generating polynomial with Lorentzian gap \u2265 \u03b4, then the entanglement entropy across any bipartition satisfies S(A) \u2264 C \u00b7 log(1/\u03b4) + O(1), recovering area-law scaling from a purely classical-probabilistic property of \u03bc.\n\n**Test:** For the TFIM on n = 4,...,8 qubits, compute: (a) the entanglement entropy across bipartitions, (b) the surrogate Lorentzian gap of the measurement distribution. Plot S(A) vs. 1/\u03b4. If the relationship is logarithmic, the conjecture is supported; if polynomial or worse, it is refuted.\n\n**Impact:** This would derive area laws \u2014 a central result in quantum information \u2014 from log-concavity, creating a stunning bridge between polynomial geometry and entanglement theory. It would suggest that Lorentzian structure is the *classical shadow* of area-law entanglement.\n\n**Catalog References:**\n- `Catalog/Pythagorean/QuantumLorentzianBridge.lean` \u2014 QuantumMeasurementModel, minMass\n- `Catalog/Pythagorean/DirectionalLogConcavity.lean` \u2014 log-concavity infrastructure\n\n**Proof Strategy:** Use the entropy-energy tradeoff: strong log-concavity implies entropy concentration (Anari\u2013Oveis Gharan\u2013Vinzant). Combine with the Araki-Lieb inequality relating measurement entropy to entanglement entropy. The Lorentzian gap controls the entropy concentration rate.\n\n**Domain Bridges:** Quantum information theory (entanglement entropy) \u2194 Lorentzian polynomials (curvature) \u2194 information theory (entropy concentration)\n\n**Lineage:** Extends `pairMassGap_ge_two_minMass` and `minMass_perturbation_lower_bound` to entropy bounds.\n\n**Ambition:** Grand challenge \u2014 paradigm-shifting if true, as it would recast area laws in geometric language.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.7999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "d97a486b",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:52:11.241965+00:00"
  },
  {
    "id": "fd_1253",
    "title": "Direction 3: Tropical Approximations to Quantum Generating Polynomials",
    "description": "**Conjecture:** The tropical limit of the generating polynomial P_\u03bc(z) \u2014 obtained by replacing addition with max and multiplication with addition \u2014 captures the dominant support structure of \u03bc and provides an O(poly(n))-time approximation to the Lorentzian certificate that is correct up to polynomial factors.\n\n**Test:** Implement tropicalization of P_\u03bc for TFIM ground states. Compare the tropical Newton polytope to the actual support of \u03bc. Verify that the tropical Hessian signature matches the Lorentzian signature for n = 3,...,6. Benchmark computational speedup vs. exact Hessian computation.\n\n**Impact:** Tropical geometry provides a combinatorial skeleton of algebraic geometry. If the Lorentzian gap has a meaningful tropical approximation, this would give a polynomial-time algorithm for certifying classical simulability \u2014 bypassing the exponential cost of exact polynomial evaluation.\n\n**Catalog References:**\n- `Catalog/Pythagorean/QuantumLorentzianBridge.lean` \u2014 RobustLorentzianCertificate\n- `Catalog/Tropical/` \u2014 existing tropical geometry infrastructure\n- `Catalog/Pythagorean/TropicalBerggrenZeta.lean` \u2014 tropical-arithmetic bridges\n\n**Proof Strategy:** Use the Viro patchworking theorem to relate tropical and classical Lorentzian conditions. The Newton polytope of P_\u03bc is a generalized permutohedron (by log-concavity), and its tropical structure encodes the support of \u03bc.\n\n**Domain Bridges:** Tropical geometry \u2194 Lorentzian polynomials \u2194 computational complexity (approximation algorithms)\n\n**Lineage:** Connects existing Tropical catalog to quantum many-body applications.\n\n**Ambition:** Solid extension \u2014 computationally tractable and testable within current infrastructure.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.7999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "d97a486b",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T00:52:11.288128+00:00"
  },
  {
    "id": "seed_032",
    "title": "Erd\u0151s\u2013Straus Conjecture",
    "description": "Prove that for every integer n \u2265 2, the fraction 4/n can be written as a sum of three unit fractions. Formalize computational verification and parametric families of solutions.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.528620+00:00"
  },
  {
    "id": "seed_007",
    "title": "196-Algorithm Non-Termination",
    "description": "Prove that the reverse-and-add algorithm applied to 196 never produces a palindrome. Formalize the concept of Lychrel numbers and establish structural properties of the iteration on digit sequences.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.336768+00:00"
  },
  {
    "id": "seed_008",
    "title": "10 is a Solitary Number",
    "description": "Prove that 10 is a solitary number \u2014 no other integer shares its abundancy index \u03c3(n)/n. Formalize the theory of friendly numbers and abundancy, connecting to the distribution of divisor sums.",
    "domains": [
      "NumberTheory"
    ],
    "priority_score": 0.7,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.344026+00:00"
  }
];
