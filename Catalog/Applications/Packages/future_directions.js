

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
    "id": "seed_040",
    "title": "Homotopy Type Theory Foundations",
    "description": "Formalize core HoTT results in Lean 4: the univalence axiom, higher inductive types, and the fundamental theorem of identity types. Prove that HoTT provides a constructive foundation for mathematics.",
    "domains": [
      "Logic",
      "Topology",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.591547+00:00"
  },
  {
    "id": "seed_049",
    "title": "Tropical Brill-Noether Theory",
    "description": "Prove that a general tropical curve of genus g has a divisor of degree d and rank r iff the Brill-Noether number \u03c1 = g - (r+1)(g-d+r) \u2265 0. Formalize the connection to classical algebraic geometry.",
    "domains": [
      "Tropical",
      "Geometry",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.657271+00:00"
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
    "id": "fd_0832",
    "title": "Direction 3: Certified Exact Arithmetic for Spectral Recognition",
    "description": "**Conjecture**: For polynomials with rational coefficients, the Lorentzian signature condition can be verified in exact arithmetic using the Sylvester criterion (signs of leading principal minors of the Hessian shifted by a rank-1 perturbation), avoiding all floating-point issues.\n\nFormally:\n```\ntheorem rational_spectral_recognizer_decidable\n    {n : \u2115} (d : \u2115) (p : MvPolynomial (Fin n) \u211a) :\n    Decidable (IsRecursivelyLorentzian d (p.map (algebraMap \u211a \u211d)))\n```\n\n**Test**: Implement the rational Sylvester criterion and compare against floating-point eigenvalue computation for all polynomials with coefficients in {0,1,2,3} of degree \u2264 4 in \u2264 4 variables. Any disagreement indicates a numerical stability issue.\n\n**Impact**: This would make Lorentzian recognition fully certified \u2014 not just mathematically sound, but computationally exact. It would enable trusted automated verification of log-concavity conjectures in combinatorics.\n\n**The key insight is** that the \"at most one positive eigenvalue\" condition for a symmetric matrix can be reformulated as: the matrix $H - \\epsilon \\cdot vv^T$ is negative semidefinite for some small $\\epsilon > 0$ and direction $v$. This can be checked via the Sylvester criterion using only determinants (exact rational arithmetic).\n\n**Why now?** The spectral recognizer algorithm is now formally verified for soundness and completeness. The remaining gap is computational \u2014 bridging from real-number eigenvalue conditions to decidable rational-arithmetic checks.\n\n**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` \u2014 `spectralRecognizerProp`, `HasAtMostOnePositiveEigenvalue`\n\n**Proof Strategy**: Reformulate the eigenvalue condition in terms of the characteristic polynomial. Use Sturm's theorem or Descartes' rule of signs to count positive roots of the characteristic polynomial in exact rational arithmetic.\n\n**Domain Bridges**: Numerical linear algebra, certified computation, computer algebra\n\n**Lineage**: Extends `spectralRecognizer_correct` and `quadratic_leaf_count_le`\n\n**Ambition**: Solid extension \u2014 decidability results for eigenvalue conditions are classical, but formal verification is novel\n\n---",
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
    "source_exp_id": "83d44e07",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T02:10:32.381941+00:00"
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "1f8fa3a8",
    "consumed_by_exp_id": "02e24032",
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
    "id": "fd_0889",
    "title": "Direction 2: Lorentzian Condition Numbers and Smoothed Analysis",
    "description": "**Conjecture:** Under smoothed analysis (Gaussian perturbation of coefficients with variance \u03c3\u00b2), the probability that a degree-d polynomial near the Lorentzian boundary is misclassified decays as exp(\u2212\u03a9(\u03b5\u00b2/(n\u03c3\u00b2))), where \u03b5 is the spectral gap.\n\n**Test:** For polynomials with spectral gap \u03b5 close to 0, sample Gaussian perturbations at various \u03c3 and measure misclassification rate. Fit the exponential decay model. If the rate does not depend on \u03b5\u00b2/\u03c3\u00b2 but on a different quantity, the conjecture fails.\n\n**Impact:** Would establish Lorentzian recognition as numerically well-conditioned in the smoothed analysis sense, even for polynomials near the boundary. This is the strongest possible statement about practical reliability.\n\n**Catalog References:** `Pythagorean/LorentzianStability.lean` \u2014 `HasGappedSignature`, `LorentzianConditionNumber`\n\n**Proof Strategy:** Use the perturbation theorem to reduce to bounding P[\u2016E\u2016_op > \u03b5] for Gaussian Wigner matrices E. Known tail bounds for the largest eigenvalue of GOE give the desired exponential decay.\n\n**Domain Bridges:** Smoothed analysis (Spielman\u2013Teng program), random matrix theory, computational complexity\n\n**Lineage:** Extends the condition number concept from numerical linear algebra to algebraic combinatorics.\n\n**Ambition:** Grand challenge \u2014 would merge Lorentzian polynomial theory with the Spielman\u2013Teng paradigm. \u2605\u2605\u2605\u2605\u2605\n\n---",
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
    "timestamp": "2026-05-25T17:14:31.171940+00:00"
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
    "id": "fd_0891",
    "title": "Direction 4: Certified Hyperbolicity via Lorentzian Leaf Margins",
    "description": "**Conjecture:** A homogeneous polynomial p is hyperbolic with respect to direction e if and only if every quadratic leaf of p (relative to e) has gapped Lorentzian signature, and the minimum gap provides a certified hyperbolicity margin.\n\n**Test:** For known hyperbolic polynomials (determinant, elementary symmetric), compute quadratic leaf gaps relative to different directions e. Verify that the gap is positive exactly when p is hyperbolic w.r.t. e. Test non-hyperbolic polynomials to confirm the gap is zero or the signature fails.\n\n**Impact:** Would extend our stability theory from Lorentzian polynomials to the broader class of hyperbolic polynomials, which arise in optimization (hyperbolic programming), PDEs (hyperbolic operators), and control theory.\n\n**Catalog References:** `Pythagorean/LorentzianStability.lean` \u2014 `HasGappedSignature`, `lorentzian_stable_under_leaf_perturbation`\n\n**Proof Strategy:** Use the Helton\u2013Vinnikov theorem (every hyperbolic polynomial is a determinant of a linear matrix pencil) to reduce to spectral analysis of the pencil. The gap translates to the minimum eigenvalue gap of the pencil restricted to the hyperbolicity cone.\n\n**Domain Bridges:** Hyperbolic programming, semidefinite optimization, PDE theory, robust control\n\n**Lineage:** Extends the Lorentzian framework to encompass G\u00e5rding's hyperbolicity theory.\n\n**Ambition:** Solid extension with grand-challenge potential if the characterization is complete. \u2605\u2605\u2605\u2605\n\n---",
    "domains": [
      "Pythagorean",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2493279d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:14:31.214977+00:00"
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
    "id": "fd_0897",
    "title": "Direction 4: Large Deviation Principles for Generation",
    "description": "**Conjecture:** The number of nongenerating pairs in $G^2$ satisfies a large deviation principle with rate function given by the Legendre transform of the log-pressure:\n$$\\Lambda^*(\\alpha) = \\sup_t \\{t\\alpha - \\log Z(t)\\}$$\nwhere $Z(t) = \\sum_H [G:H]^{-2t}$ is the pressure at \"inverse temperature\" $t$.\n\n**The key insight is** that the pressure at different \"temperatures\" $t$ (i.e., with exponent $-2t$ instead of $-2$) forms a family of partition functions whose Legendre transform controls the probability of atypical generation behavior.\n\n**Why now?** The product factorization theorem shows that pressure has the multiplicative structure needed for the G\u00e4rtner\u2013Ellis theorem, which gives large deviation principles from the log-moment generating function.\n\n**Test:** For $S_k^m$ with $m \\to \\infty$, compute $Z(t) = m \\cdot \\sum_M [S_k:M]^{-2t}$ for varying $t$ and verify the predicted rate function against Monte Carlo simulations.\n\n**Impact:** Would establish a complete probabilistic theory of random generation, going beyond first-moment bounds to exponential concentration.\n\n**Catalog References:** `Pythagorean/SubgroupPressure.lean` (product factorization, free energy additivity)\n\n**Proof Strategy:** Define the generalized pressure $Z(t)$ and verify multiplicativity for product families. Apply the G\u00e4rtner\u2013Ellis theorem to the sequence of block-defect pressures. Verify the hypotheses (existence of the limit, differentiability of the log-moment generating function).\n\n**Domain Bridges:** Large deviation theory, probability theory, statistical mechanics (generalized ensembles).\n\n**Lineage:** Direct analytic extension of the free energy framework.\n\n**Ambition:** Solid extension with significant theoretical depth.\n\n---",
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
    "source_exp_id": "cf039036",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:14:59.835069+00:00"
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "e8f8d5e4",
    "consumed_by_exp_id": "16a503d2",
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
    "id": "fd_0946",
    "title": "Direction 4: Matroidal Quantum State Preparation",
    "description": "**Conjecture:** For matroids whose basis-generating polynomial is Lorentzian (which includes all matroids, by the Adiprasito\u2013Huh\u2013Katz theorem), the certificate compilation produces a quantum state over bases with amplitudes proportional to basis weights. This gives a quantum polynomial-time sampler for matroid bases.\n\n**Test:** Implement certificate compilation for graphic matroids on small graphs (n \u2264 15 vertices), transversal matroids, and partition matroids. Compare the compiled amplitude vector with the exact basis-weight distribution.\n\n**Impact:** Connects Lorentzian certificate compilation to combinatorial optimization. Quantum sampling from matroid bases has applications to network reliability, linear algebra, and constraint satisfaction.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (SupportSatisfiesExchange \u2014 matroid exchange property)\n\n**Proof Strategy:** Use the Adiprasito\u2013Huh\u2013Katz theorem (Lorentzianity of matroid basis polynomials) as input, then apply the certificate compilation pipeline. The main work is constructing the recursive certificate from matroid structure.\n\n**Domain Bridges:** Matroid theory, combinatorial optimization, algebraic geometry (Hodge theory), network analysis\n\n**Lineage:** Extends the Br\u00e4nd\u00e9n\u2013Huh theory of Lorentzian polynomials to a computational application via certificate compilation.\n\n**Ambition:** Solid extension with potentially high impact in combinatorial optimization.\n\n**The key insight is** that matroid basis-generating polynomials are already known to be Lorentzian, so the certificate exists \u2014 we just need to extract it efficiently.\n\n**Why now?** The Adiprasito\u2013Huh\u2013Katz theorem (2018) provides the theoretical foundation; certificate compilation (this work) provides the preparation machinery.\n\n---",
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
    "source_exp_id": "2b6d84b4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:13:09.763547+00:00"
  },
  {
    "id": "fd_0950",
    "title": "Direction 2: Tropical Interleaving Distance and Algebraic Stability",
    "description": "**Conjecture:** There exists a categorical interleaving distance on the category of tropical persistence modules (parametrized by monotone functions \u211d \u2192 \u2124 with bounded local variation) such that (a) the interleaving distance is bounded above by the barcode distance, (b) the two distances are bi-Lipschitz equivalent for finite-type modules, and (c) the interleaving distance satisfies a universal property analogous to the Bubenik\u2013Scott framework for classical persistence.\n\n**Test:** Formalize the tropical persistence category in Lean 4. Verify the bi-Lipschitz equivalence computationally for graphs up to n = 50. Construct an explicit example showing the two distances are not equal (gap in the bi-Lipschitz constant).\n\n**Impact:** This would establish a complete algebraic stability theory for tropical persistence, paralleling the Chazal\u2013Cohen-Steiner\u2013Glisse\u2013Guibas\u2013Oudot framework [CCGGO09] for classical persistence. It would make tropical persistence amenable to the full toolkit of abstract persistence theory.\n\n**Catalog References:** `Pythagorean/TropicalBridge/Stability.lean` (tropical_event_profile_interleaved, tropicalBarcodeDist_nonneg, tropicalBarcodeDist_symm)\n\n**Proof Strategy:** Define the tropical persistence module as a functor from (\u211d, \u2264) to (\u2124-Mod, \u2264), where morphisms are order-preserving maps. The interleaving distance is the infimum \u03b4 such that the modules are \u03b4-shifted comparable. Use the monotonicity theorem (tropicalEventProfile_mono) as the starting point and extend to the full module structure.\n\n**Domain Bridges:** Category theory, homological algebra, abstract persistence theory\n\n**Lineage:** Extends Theorems 5.1\u20135.2 (interleaving) to a full categorical framework\n\n**Ambition:** Grand challenge \u2014 would unify tropical and classical persistence theory\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Tropical",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "834b245c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:13:41.991865+00:00"
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
    "id": "fd_0955",
    "title": "Direction 1: Wreath Product Perturbation Theory",
    "description": "**Conjecture:** For the wreath product $W_{k,m} = S_k \\wr S_m$ acting on $km$ points with imprimitive subgroup family $\\mathcal{I}_{k,m}$, the critical exponent $\\beta_{W}$ satisfies:\n$$\\beta_{W}(k,m) = \\beta_{\\text{product}}(k,m) + O(k^{-1})$$\nwhere $\\beta_{\\text{product}}$ is the exponent of the direct product $S_k^m$. In renormalization language, the imprimitive structure is an *irrelevant perturbation* for large $k$.\n\n**Test:** Compute the subgroup pair pressure of $S_k \\wr S_m$ for $k \\leq 8$, $m \\leq 5$ using GAP. Extract effective exponents via log-slope estimation. Compare with the direct product prediction $\\beta_{\\text{product}} = m \\cdot \\beta(S_k)$. A deviation growing as $k$ increases would refute the conjecture.\n\n**Impact:** If true, this would be the first proof that universality persists beyond exact factorization\u2014the algebraic analogue of showing that a phase transition's exponent is unchanged by short-range perturbations. If false, it identifies wreath product structure as a new relevant parameter.\n\n**Catalog References:** `Catalog/old/Pythagorean/SubgroupPressure.lean` (product factorization), `Pythagorean/SubgroupUniversality.lean` (exponent additivity).\n\n**Proof Strategy:** Define the wreath product pressure as a perturbation of the product pressure: $\\Pi_W = \\Pi_{\\text{prod}} + \\delta\\Pi$ where $\\delta\\Pi$ captures cross-factor subgroups. Use the divergence bound theorem to show that $\\delta\\Pi$ contributes sub-dominant scaling.\n\n**Domain Bridges:** Connects to representation theory (irreducible representations of wreath products via Clifford theory), probability (random walks on wreath products), and additive combinatorics (orbit counting).\n\n**Lineage:** Builds directly on `exponent_mul_of_two_sided_bounds` and `subgroupPairPressure_prod`.\n\n**Ambition:** \ud83d\udd34 Grand Challenge \u2014 would establish the first non-trivial irrelevant perturbation result in algebraic statistical mechanics.\n\nThe key insight is that wreath products add controlled \"imprimitive interactions\" between direct product factors, and the question of whether these are relevant or irrelevant exactly parallels the Harris criterion in condensed matter physics.\n\nWhy now? The formal verification of exponent additivity for exact products provides the baseline against which perturbative deviations can be measured. Without the exact result, there would be no reference point for the approximate theory.\n\n---",
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
    "source_exp_id": "354ccda2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:49:45.078780+00:00"
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
    "id": "fd_0958",
    "title": "Direction 4: Arithmetic Statistics via Subgroup Pressure",
    "description": "**Conjecture:** For the family $\\text{GL}_n(\\mathbb{F}_q)$ with $q$ fixed and $n \\to \\infty$, the free energy per dimension stabilizes:\n$$\\lim_{n \\to \\infty} \\frac{1}{n} \\log \\Pi(\\text{GL}_n(\\mathbb{F}_q)) = F_\\infty(q)$$\nand $F_\\infty(q)$ has a power-law singularity as $q \\to 1^+$ (viewing $q$ as a continuous parameter via $q$-analogues).\n\n**Test:** Compute $\\Pi(\\text{GL}_n(\\mathbb{F}_q))$ for $q = 2, 3, 4, 5, 7$ and $n = 2, \\ldots, 6$ using parabolic subgroup indices. Plot $\\frac{1}{n} \\log \\Pi$ versus $n$ and test for convergence. Then fit $F_\\infty(q)$ versus $q-1$ for a power law.\n\n**Impact:** This would connect subgroup thermodynamics to the Cohen-Lenstra heuristics and arithmetic statistics, where $q$-analogues of group-theoretic quantities play a central role. The singularity at $q = 1$ would be a genuine phase transition connecting finite group theory to number theory.\n\n**Catalog References:** `Pythagorean/SubgroupUniversality.lean` (extensivity, convexity), `Catalog/old/Pythagorean/SubgroupPressure.lean` (pressure definition).\n\n**Proof Strategy:** Use the parabolic subgroup structure of $\\text{GL}_n(\\mathbb{F}_q)$ to decompose the pressure into Gaussian binomial coefficients. Apply the extensivity framework by viewing $\\text{GL}_n$ as an approximate product of root subgroups.\n\n**Domain Bridges:** Number theory (Cohen-Lenstra heuristics), algebraic geometry (counting points on varieties over $\\mathbb{F}_q$), combinatorics ($q$-analogues), random matrix theory (distribution of $\\text{GL}_n(\\mathbb{F}_q)$ matrices).\n\n**Lineage:** Extends `freeEnergy_directPower` to non-product families via $q$-deformation of the extensivity axiom.\n\n**Ambition:** \ud83d\udfe1 Solid Extension \u2014 uses computable data from well-studied groups but interprets it through the novel thermodynamic lens.\n\nThe key insight is that $q$-analogues naturally interpolate between discrete group families, providing the continuous parameter needed for critical exponent extraction.\n\nWhy now? The Lean formalization provides the precise definitions and correctness guarantees needed to make quantitative predictions about $F_\\infty(q)$ that can be tested computationally.\n\n---",
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "354ccda2",
    "consumed_by_exp_id": "17192924",
    "timestamp": "2026-05-25T21:49:45.153662+00:00"
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
    "id": "fd_0970",
    "title": "Direction 1: Canonical Path Poincar\u00e9 Inequality for Cayley Graphs",
    "description": "**Conjecture:** For any finite group G with canonical path data (gens, paths, L, \u03ba), the variance of any function f: G \u2192 \u211d is bounded by:\n\nVar(f) \u2264 (\u03ba \u00b7 L / |S|) \u00b7 E_S(f)\n\nwhere \u03ba is the edge congestion, L is the max path length, and |S| is the generator set size.\n\n**Test:** Formalize the full canonical path method in the proof system. Verify the bound computationally for S_5 with bubble-sort canonical paths, where \u03ba and L can be computed exactly.\n\n**Impact:** This would give the first formally verified quantitative spectral gap lower bound for Cayley graphs, converting combinatorial path data into a certified expansion certificate. It would make the spectral gap computable from algebraic data alone.\n\n**The key insight is** that the canonical path method of Jerrum\u2013Sinclair, when specialized to Cayley graphs, reduces the spectral gap problem to a counting problem: bound the maximum load on any directed edge. For Cayley graphs, the translation-invariance of the group action should make this counting tractable.\n\n**Why now?** The infrastructure built in this cycle \u2014 Dirichlet energy, variance, Cauchy\u2013Schwarz for finsets, the L\u00b2 contraction \u2014 provides exactly the analytic substrate needed. The missing piece is the telescoping inequality along canonical paths and the congestion counting argument, both of which are combinatorial and amenable to formal proof.\n\n**Catalog References:** `Pythagorean/CayleyExpander/Defs.lean` (CanonicalPathData structure), `Pythagorean/CayleyExpander/SpectralGap.lean` (variance and energy machinery).\n\n**Proof Strategy:** Telescope f(y) - f(x) along the canonical path from x to y. Apply Cauchy\u2013Schwarz to bound (f(y)-f(x))\u00b2 by L \u00b7 \u03a3_{edges on path} (gradient)\u00b2. Sum over all (x,y) pairs and use congestion bound to control the total.\n\n**Domain Bridges:** Markov chain mixing times (probability), network routing (CS), statistical mechanics relaxation (physics).\n\n**Lineage:** Extends Theorems 2 and 3 of this cycle from qualitative (zero-energy \u2194 constant) to quantitative (gap \u2265 explicit bound).\n\n**Ambition:** Solid extension \u2014 builds directly on catalog infrastructure.\n\n---",
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
    "source_exp_id": "8778f4a5",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:58:43.475104+00:00"
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
    "id": "fd_0974",
    "title": "Direction 5: Expander-Based Derandomization in Certified Computation",
    "description": "**Conjecture:** For any Boolean function f: S_n \u2192 {0,1} with E[f] \u2265 2/3, a random walk of length O(log(1/\u03b5)/gap) on a Cayley expander of S_n produces k samples such that the majority vote has error probability \u2264 \u03b5, using only O(n log n + k log(degree)) random bits.\n\n**Test:** Implement the Ajtai\u2013Koml\u00f3s\u2013Szemer\u00e9di expander walk sampler for Cay(S_5, {\u03c3\u00b11, \u03c4\u00b11}) and verify the error amplification bound empirically for random Boolean functions with various biases.\n\n**Impact:** This would bridge formal spectral theory to the foundations of derandomization in theoretical computer science, providing certified guarantees for algorithms that use random bits efficiently.\n\n**The key insight is** that correlated samples from an expander walk are \"almost as good as\" independent samples for amplifying success probability, and the spectral gap quantifies the word \"almost.\" This transforms the spectral gap from a graph-theoretic invariant into a computational resource.\n\n**Why now?** The averaging operator machinery, L\u00b2 contraction, and mean-zero analysis from this cycle provide exactly the tools needed to state and prove the expander walk lemma. The key missing piece is the large deviation bound for correlated samples, which can be derived from the L\u00b2 contraction by a Markov inequality argument.\n\n**Catalog References:** `Pythagorean/CayleyExpander/SpectralGap.lean` (L\u00b2 contraction, averaging operator), `Algebra/ExpanderWalk/Core.lean` (existing expander walk infrastructure).\n\n**Proof Strategy:** Apply the L\u00b2 contraction theorem k times to bound the variance of the empirical mean. Use Chebyshev's inequality to convert variance bounds to probability bounds. The spectral gap enters through the correlation decay between walk positions.\n\n**Domain Bridges:** Complexity theory (BPP vs P), algorithm design (derandomization), cryptography (pseudorandom generators), quantum computing (quantum walks).\n\n**Lineage:** Connects the Cayley graph spectral framework to the existing ExpanderWalk infrastructure in the Algebra catalog.\n\n**Ambition:** Solid extension with grand challenge elements \u2014 the basic lemma is provable, but optimal bounds require spectral concentration inequalities.",
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "8778f4a5",
    "consumed_by_exp_id": "d4196bad",
    "timestamp": "2026-05-25T22:58:43.577519+00:00"
  },
  {
    "id": "fd_0976",
    "title": "Direction 2: Spectral Gap from Product Growth",
    "description": "**Conjecture:** There exists a formal derivation showing that strict Cayley ball growth implies a positive spectral gap for the Cayley graph adjacency operator. Specifically, if the Cayley ball of radius $k$ satisfies $|B_{k+1}| \\geq (1 + \\delta)|B_k|$ for some $\\delta > 0$ and all $B_k \\neq G$, then the spectral gap $\\lambda_1 - \\lambda_2$ of the normalized adjacency matrix is at least $f(\\delta, |A|)$ for an explicit function $f$.\n\n**Test:** For certified pairs in $\\mathrm{GL}(2, \\mathbb{F}_5)$, compute both the Cayley ball growth rates and the spectral gap of the adjacency matrix numerically. Plot the correlation between growth rate and spectral gap across 100 certified pairs.\n\n**The key insight is** that product growth and spectral expansion are two faces of the same phenomenon. The Expander Mixing Lemma shows that spectral gap controls edge distribution; conversely, the Cheeger inequality shows that expansion controls spectral gap. Our Cayley Ball Strict Growth theorem provides the expansion side; connecting it to spectral gap would complete the bridge.\n\n**Why now?** The `CertificateExpanders.lean` file already defines the averaging operator and proves self-adjointness. The missing link is connecting product growth (proved in this cycle) to the spectral analysis (developed in the catalog). The Cayley ball formulation makes this connection natural: ball growth is graph expansion, which is spectral gap.\n\n**Impact:** A formal spectral-gap theorem from certificate data would unify the algebraic (generation) and analytic (spectral) approaches to expansion.\n\n**Catalog References:** `Catalog/Pythagorean/CertificateExpanders.lean` (averaging operator, self-adjointness, harmonic maximum principle, strict contraction).\n\n**Proof Strategy:** Use the Cheeger inequality: $h(G) \\leq \\sqrt{2(1 - \\lambda_2)}$ where $h$ is the edge expansion constant. Show that Cayley ball growth implies edge expansion $h \\geq \\delta/(1+\\delta)$. Then derive $\\lambda_2 \\leq 1 - h^2/2$.\n\n**Domain Bridges:** Spectral graph theory, Markov chain mixing, random matrix theory.\n\n**Lineage:** Extends `cayley_ball_strict_growth` and `cayley_diameter_bound` from the current cycle, connects to `strict_contraction_of_generates` from the catalog.\n\n**Ambition:** \ud83d\udfe1 Solid Extension \u2014 the Cheeger inequality is well-understood; the challenge is formalization.\n\n---",
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
    "source_exp_id": "edab5f0b",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T22:59:06.846580+00:00"
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
    "id": "fd_0983",
    "title": "Direction 4: Tropical Contraction and Support Truncation",
    "description": "**Conjecture:** Under tropicalization (replacing + with max and \u00d7 with +), the contraction operation on polynomial supports corresponds to a *tropical truncation* of the Newton polytope: the operation that removes a face of the polytope and re-indexes the remaining lattice points. This tropical truncation preserves the \"tropical M-convexity\" (the tropical analog of the exchange property).\n\n**Test:** Implement tropical polynomial operations in Python. Compute tropical supports for degree-\u22645 polynomials in \u22644 variables. Verify that tropical contraction = support contraction for these cases. Formalize the tropical exchange property and prove it coincides with the classical one for integer-valued tropical polynomials.\n\n**Impact:** This would connect the derivative/contraction theorem to tropical geometry, the fastest-growing interface between combinatorics and algebraic geometry. It would position the M-convexity closure result as a shadow of a deeper tropical-geometric principle.\n\n**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (SupportContraction), `Catalog/Tropical/` (tropical geometry files if present).\n\n**Proof Strategy:** Establish a formal tropicalization functor that sends MvPolynomial \u211d to tropical polynomials, and show it commutes with contraction. The M-convexity preservation would then follow from the classical result.\n\n**Domain Bridges:** Discrete convex analysis \u2194 tropical geometry \u2194 algebraic geometry (Berkovich spaces, non-Archimedean geometry).\n\n**Lineage:** Extends the contraction theorem to the tropical world.\n\n**Ambition:** Grand challenge \u2014 tropical formalization in Lean is still nascent.\n\n**The key insight is** that support sets are Newton polytopes, contraction acts on lattice points, and tropical geometry provides the natural language for operations on Newton polytopes.\n\n**Why now?** Tropical geometry has reached maturity as a mathematical theory, and its connections to M-convexity via valuated matroids are well-established informally. Formalization would be pioneering.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "243a6673",
    "consumed_by_exp_id": "daae69f2",
    "timestamp": "2026-05-25T23:33:15.605805+00:00"
  },
  {
    "id": "fd_0984",
    "title": "Direction 5: Negative Dependence Preservation Under Conditioning",
    "description": "**Conjecture:** If a probability distribution \u03bc on {0,1}\u207f is *strongly Rayleigh* (its generating polynomial is stable), then for any element i, the conditional distribution \u03bc(\u00b7|i \u2208 S) is again strongly Rayleigh. At the support level, this reduces to our contraction theorem. At the coefficient level, it requires preserving the stability (zero-free half-plane) property, which should follow from the Borcea-Br\u00e4nd\u00e9n theory.\n\n**Test:** For determinantal point processes (DPPs) with kernel matrices of rank \u2264 5 on \u2264 8 elements, compute the generating polynomial, verify stability, differentiate, and verify stability again. Formalize the connection between conditioning and differentiation for DPPs.\n\n**Impact:** This would provide a formal bridge from algebraic combinatorics to statistical physics and machine learning (DPPs are widely used for diversity-promoting sampling). It would certify that the negative dependence properties that make DPPs useful survive conditioning \u2014 a fact used informally in every DPP application.\n\n**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (pderiv closure), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Lorentzian/stable connection).\n\n**Proof Strategy:** Use the Borcea-Br\u00e4nd\u00e9n characterization: a polynomial is stable iff it has nonneg coefficients and its support satisfies exchange (for homogeneous polynomials, this is equivalent to Lorentzianity). Differentiation preserves nonnegativity (proved) and exchange (proved), hence stability.\n\n**Domain Bridges:** Combinatorics (matroid theory) \u2194 probability (DPPs, negative dependence) \u2194 statistical physics (partition functions) \u2194 machine learning (diversity sampling).\n\n**Lineage:** Applies the contraction theorem to the most impactful application domain.\n\n**Ambition:** Solid extension with grand-challenge framing \u2014 the individual steps are provable, but the full formalization of the stable polynomial \u2194 negative dependence connection would be a major formal verification milestone.\n\n**The key insight is** that differentiation = conditioning at the algebraic level, and our contraction theorem provides the combinatorial layer of the preservation argument. The analytic layer (coefficient positivity) is already proved.\n\n**Why now?** DPPs are increasingly important in machine learning, and practitioners rely on negative dependence preservation without formal guarantees. A machine-checked proof would provide certifiable guarantees for algorithmic applications.",
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
    "source_exp_id": "243a6673",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T23:33:15.642033+00:00"
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
    "id": "fd_1010",
    "title": "Direction 1: Necklace Divisibility via Burnside's Lemma",
    "description": "**Conjecture:** The necklace divisibility theorem n | \u03a3_{d|n} \u03bc(n/d) q^d can be formally proved by constructing the cyclic group action on q-ary strings of length n and applying Burnside's lemma to count primitive necklaces.\n\n**Test:** Formalize the Z/nZ action on (Fin q)^(Fin n), verify that Burnside's lemma gives (1/n) \u03a3_{d|n} \u03c6(n/d) q^(gcd(n,d)) total necklaces, and that inclusion-exclusion via M\u00f6bius inversion extracts the primitive necklace count (1/n) \u03a3_{d|n} \u03bc(n/d) q^d. If the primitive count is not a non-negative integer for any (q,n), the approach fails.\n\n**Impact:** Closes the one remaining sorry in the formalization and establishes the first fully verified proof of this 200-year-old number-theoretic identity in a modern proof assistant.\n\n**Catalog References:** `Pythagorean/CertificateDensity.lean` (Theorem: `necklace_sum_div_n`)\n\n**Proof Strategy:** Define the type `Necklace q n := (Fin n \u2192 Fin q)`, the cyclic shift action `\u03c3 : (Fin n \u2192 Fin q) \u2192 (Fin n \u2192 Fin q)` by `\u03c3 f i = f (i + 1)`, and the orbit quotient. Apply `MulAction.card_quotient_eq_sum_card_fixedBy` from Mathlib. The fixed points of \u03c3^d are exactly the strings with period dividing d, giving q^(gcd(n,d)) fixed points. The M\u00f6bius inversion step uses the established framework.\n\n**Domain Bridges:** Combinatorics \u2194 Number Theory \u2194 Algebra\n\n**Lineage:** Extends `necklace_sum_div_prime` (Fermat's little theorem case) to all n.\n\n**Ambition:** Solid extension \u2014 closes a specific gap in the current formalization.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "eb4b8f41",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T01:21:04.623072+00:00"
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
    "id": "fd_1021",
    "title": "Direction 2: Explicit Poincar\u00e9 Constant and Exponential Variance Decay",
    "description": "**Conjecture**: For the $S_n$ walk with adjacent transpositions and long cycle, there exists $c > 0$ such that for all mean-zero $f : S_n \\to \\mathbb{R}$:\n$$\n\\text{Var}(f) \\leq \\frac{c \\cdot n^2}{|S|} \\cdot E_S(f)\n$$\nwhere $E_S(f)$ is the Dirichlet energy. Equivalently, the spectral gap satisfies $\\gamma \\geq |S|/(c \\cdot n^2)$.\n\n**Test**: Compute the exact spectral gap for $n = 3, \\ldots, 8$ and verify $\\gamma \\cdot n^2 / |S|$ converges to a constant. For $n = 3$: gap \u2248 0.5; for $n = 6$: gap \u2248 0.134. Check whether $\\gamma \\cdot n^2$ stabilizes.\n\n**Impact**: Would upgrade the variance decay theorem from $\\text{Var}(A^t f) \\leq \\text{Var}(f)$ to the exponential form $\\text{Var}(A^t f) \\leq (1 - c/n^2)^{2t} \\cdot \\text{Var}(f)$, giving explicit relaxation rates.\n\n**Catalog References**: `Pythagorean/CayleyExpander/Defs.lean` (Dirichlet energy, `CanonicalPathData`), `Pythagorean/CayleyExpander/SpectralGap.lean` (variance-energy relation, Poincar\u00e9 inequality).\n\n**Proof Strategy**: \n1. Construct explicit canonical paths in $\\text{Cay}(S_n, S)$ using the bubble sort + rotation algorithm.\n2. Bound the congestion: each edge carries at most $C \\cdot n^2 \\cdot (n-2)!$ paths.\n3. Apply the Poincar\u00e9 comparison: $\\gamma \\geq |S| / (\\text{congestion} \\cdot \\text{max\\_length})$.\n4. Formalize using `CanonicalPathData` and `explicitGapBound` from `Defs.lean`.\n\n**Domain Bridges**: Poincar\u00e9 inequality \u2192 functional inequalities \u2192 log-Sobolev \u2192 hypercontractivity \u2192 quantum information.\n\n**Lineage**: Builds directly on the catalog's `CanonicalPathData` structure and `explicitGapBound` definition.\n\n**Ambition**: Solid extension \u2014 achievable with existing infrastructure.\n\n**The key insight is** that the long cycle reduces canonical path lengths from $O(n^2)$ to $O(n)$ (sort first, then rotate), and the congestion is controlled by the symmetry of the group action.\n\n**Why now?** The `CanonicalPathData` structure is already defined in the catalog with all necessary fields (paths, length bounds, congestion bounds). Only the concrete instantiation for $S_n$ with the specific generators is needed.\n\n---",
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "4f520a5f",
    "consumed_by_exp_id": "c0f735e4",
    "timestamp": "2026-05-26T01:57:00.404929+00:00"
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
    "id": "fd_1026",
    "title": "Direction 2: Lorentzian Minor Closure Conjecture",
    "description": "**Conjecture:** If S is the support of a Lorentzian polynomial (in the sense of Br\u00e4nd\u00e9n\u2013Huh), then every minor of S is realizable as the support of a Lorentzian polynomial.\n\n**The key insight is** that Lorentzianity is a stronger condition than exchange (it additionally requires Hessian signature conditions on all degree-2 derivatives). The conjecture posits that this stronger condition is also minor-closed. If true, it would mean Lorentzian polynomials form a combinatorial species with both algebraic and geometric structure preserved under minors.\n\n**Why now?** We have proved that exchange (the combinatorial shadow of Lorentzianity) is minor-closed. The remaining question is whether the analytic/geometric conditions are also preserved. Computational evidence from `demo.py` shows no counterexample for degree \u2264 6 on \u2264 5 variables.\n\n**Test:** \n1. Enumerate all minors of supports of e_k(x_1,...,x_n) for n \u2264 7, k \u2264 4.\n2. For each minor, attempt to construct a Lorentzian polynomial with that support using the recognition criteria from `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`.\n3. Search for a counterexample: a minor support that satisfies exchange but admits no Lorentzian realization.\n\n**Impact:** Would establish Lorentzian polynomials as a minor-closed combinatorial species, enabling inductive classification programs and connecting Hodge theory to matroid-type decomposition.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (SupportSatisfiesExchange, IsBrandenHuhLorentzian), `Catalog/Pythagorean/SupportMinorTheory.lean` (exchange_of_minor).\n\n**Proof Strategy:** \n1. Show deletion preserves Lorentzianity by analyzing Hessian signature under variable restriction.\n2. Show contraction preserves Lorentzianity by analyzing the effect on quadratic forms.\n3. Use the recursive spectral certificate (recursivelyLorentzian_iff_brandenHuh) to reduce to checking degree-2 leaves.\n\n**Domain Bridges:** Algebraic geometry (Hodge index theorem), discrete convex analysis (M-convex optimization).\n\n**Lineage:** Builds on both the minor theory (this paper) and the Lorentzian recognition (LorentzianRecognitionComplete.lean).\n\n**Ambition:** Grand challenge \u2014 would unify Hodge theory with matroid minor theory.\n\n---",
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
    "source_exp_id": "abb48be4",
    "consumed_by_exp_id": "8e8af4e3",
    "timestamp": "2026-05-26T02:33:39.011759+00:00"
  },
  {
    "id": "fd_1030",
    "title": "Direction 1: Spectral Fingerprints for Classical Subgroups",
    "description": "**Conjecture**: For each classical matrix group family G \u2208 {SL_n, Sp_{2n}, O_n, SO_n, SU_n} over F_q, the characteristic polynomial distribution of random elements has a distinct fingerprint from GL_n(F_q) and from each other classical family of the same dimension. Specifically, the irreducible rate and split rate of random charpolys in G(F_q) converge to deterministic values \u03c1_irr(G, n, q) and \u03c1_spl(G, n, q) that separate G from all other classical groups of the same dimension.\n\n**Test**: For SL_3(F_7) and Sp_4(F_5), computationally estimate the characteristic polynomial statistics from 10,000 random elements and compare to the GL predictions. If the distributions differ significantly (p < 0.01 in a chi-squared test against the GL distribution), the conjecture is supported.\n\n**Impact**: This would extend the recognition framework from identifying (n, q) within GL_n to identifying the *group type* (GL, SL, Sp, O, ...) \u2014 a dramatically more powerful recognition tool that addresses the core problem in computational group theory.\n\n**Catalog References**: `Catalog/Algebra/CharpolyRecognition.lean` (fingerprint framework, loss function), `Catalog/Algebra/MatrixGroupGeneration.lean` (generation certificates, invariant subspace theorem).\n\n**Proof Strategy**: For SL_n, the constraint det(A) = 1 restricts the constant term of the charpoly to (-1)^n, reducing the polynomial space. Count irreducible polynomials with prescribed constant term using character sums over F_q. For Sp_{2n}, charpolys are palindromic (self-reciprocal), dramatically reducing the irreducible fraction. Prove these structural constraints yield distinct rates.\n\n**Domain Bridges**: Connects to random matrix theory over finite fields (Fulman, 2000) and representation theory of classical groups (Carter, 1985).\n\n**Lineage**: Direct extension of the current GL_n fingerprint framework.\n\n**Ambition**: Grand challenge \u2014 requires new algebraic counting results for constrained polynomial families.\n\n---",
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
    "source_exp_id": "114b795e",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T03:06:43.848125+00:00"
  },
  {
    "id": "fd_1050",
    "title": "Direction 1: Log-Sobolev Inequality for the Hybrid Walk",
    "description": "**Conjecture:** The modified log-Sobolev constant $\\rho_n$ of the adjacent-transposition-plus-cycle walk satisfies $\\rho_n \\geq c/n^2$ for a universal constant $c > 0$. This would immediately yield $t_{\\text{mix}} \\leq O(n^2 \\log \\log n!)$ = $O(n^2 \\log n)$, closing the gap between upper and lower bounds.\n\n**Test:** Compute the log-Sobolev constant numerically for $n = 3, 4, 5, 6$ via semidefinite programming (the constant equals the minimum of $\\mathcal{E}(f, \\log f) / \\text{Ent}(f^2)$ over nonzero test functions). If $\\rho_n \\cdot n^2$ stabilizes, the conjecture is confirmed.\n\n**Impact:** Would be the first log-Sobolev inequality for a hybrid-generator walk on $S_n$. This is stronger than the spectral gap and would give the sharp $O(n^2 \\log n)$ mixing time, confirming the cutoff conjecture up to constants.\n\n**Catalog References:** `Pythagorean/CayleyExpander/AdjCycleMixing.lean` (spectral gap bounds), `Pythagorean/CayleyExpander/HybridWalk.lean` (walk definitions).\n\n**Proof Strategy:** Use the comparison method: compare the log-Sobolev constant of the hybrid walk with that of the random transposition walk (known to be $\\Theta(1/n)$) via a canonical path argument with controlled entropy distortion.\n\n**Domain Bridges:** Functional analysis (log-Sobolev inequalities), information theory (entropy methods), quantum information (quantum log-Sobolev for permutation channels).\n\n**Lineage:** Extends Theorem A (spectral gap) to the stronger log-Sobolev regime.\n\n**Ambition:** \ud83d\udfe1 Grand Challenge \u2014 would resolve the central open problem.\n\n**\"The key insight is...\"** that log-Sobolev constants capture higher-order concentration beyond what spectral gaps provide, and the cycle generator's role in reducing entropy transport cost may be visible only at this level.\n\n**\"Why now?\"** The spectral gap infrastructure is now certified and the numerical tools to test the conjecture exist. Recent advances in log-Sobolev inequalities for permutation groups (Salez, 2023) provide new technical tools.\n\n---",
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
    "source_exp_id": "48617359",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T04:51:55.380022+00:00"
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
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "48617359",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T04:51:55.424405+00:00"
  },
  {
    "id": "fd_1053",
    "title": "Direction 4: Cryptographic Security Bounds for Permutation Networks",
    "description": "**Conjecture:** Any permutation network that alternates $k$ rounds of adjacent-swap layers with cyclic-shift layers requires at least $\\Omega(n^2 \\log n / k)$ rounds to achieve statistical security (TV distance $< 2^{-\\lambda}$ from a random permutation for security parameter $\\lambda$).\n\n**Test:** Implement the AES-like permutation network with varying numbers of swap layers per round. Measure the TV distance from uniform for $n = 8$ (matching common block cipher state sizes) and compare with the predicted bound.\n\n**Impact:** Would provide the first mathematically certified lower bound on round complexity for this class of lightweight ciphers. Direct applications to the security analysis of PRESENT, GIFT, and other bitslice-style block ciphers.\n\n**Catalog References:** `Pythagorean/CayleyExpander/AdjCycleMixing.lean` (mixing time lower bound), `Pythagorean/CayleyExpander/HybridWalk.lean` (HybridPermutationWalk framework).\n\n**Proof Strategy:** Model the cipher's permutation layer as a deterministic version of our random walk. Use the observable lower bound (Theorem C) to show that any product of $T$ generators from the hybrid set leaves a detectable bias in the cycle displacement statistic.\n\n**Domain Bridges:** Cryptography (block cipher design), information theory (min-entropy), hardware security (side-channel resistance of lightweight ciphers).\n\n**Lineage:** Application of Theorem C to security engineering.\n\n**Ambition:** \ud83d\udfe2 Solid Extension \u2014 direct application of existing theory to a new domain.\n\n**\"The key insight is...\"** that our observable lower bound provides a *distinguisher* \u2014 a statistical test that can tell a cipher's output from random \u2014 and the decay rate $1 - \\Theta(1/n^2)$ translates directly into a minimum number of rounds.\n\n**\"Why now?\"** The NIST Lightweight Cryptography standardization process has renewed interest in formal security analysis of simple permutation networks. Our tools provide exactly the right mathematical framework.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "48617359",
    "consumed_by_exp_id": "3130e902",
    "timestamp": "2026-05-26T04:51:55.485067+00:00"
  },
  {
    "id": "fd_1070",
    "title": "Direction 1: Non-Multiaffine Extension via Weighted Support Analysis",
    "description": "**Conjecture:** For general homogeneous polynomials (not necessarily multiaffine) of degree $d$ in $n$ variables, there exists a weighted support measure $\\sigma(f)$ such that the number of nonzero quadratic derivative leaves is bounded by $\\sigma(f)$, and $\\sigma(f)$ can be computed from the Newton polytope of $f$ in polynomial time.\n\n**Test:** Define $\\sigma(f)$ as the number of lattice points in the $(d-2)$-shadow of the Newton polytope. Compute this for specific families (power-sum polynomials, Schur polynomials, elementary symmetric polynomials) and compare with the actual nonzero leaf count. A disproof would be a polynomial where coefficient cancellation forces the leaf count below the Newton polytope prediction.\n\n**Impact:** Would extend the support compression principle from multiaffine polynomials to all homogeneous polynomials, vastly expanding its applicability. This is essential for applications to Hodge theory and algebraic geometry, where multiaffineness is not guaranteed.\n\n**Catalog References:** `Catalog/Pythagorean/SupportCompression.lean` (Theorem `nonzeroDerivativeLeafSet_eq_indep`), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`NewtonSupport`, `IsHomogeneousDeg`)\n\n**Proof Strategy:** Generalize the support criterion by replacing exact containment with a dominated-support condition. For non-multiaffine polynomials, the key difficulty is coefficient cancellation: two surviving monomials might cancel in the derivative. Approach via the theory of *stable polynomials* or *completely log-concave* polynomials, where cancellation is structurally prevented.\n\n**Domain Bridges:** Connects to algebraic geometry (Newton polytopes), optimization (lattice point enumeration), and convex geometry (mixed volumes).\n\n**Lineage:** Builds directly on Theorem 1 (support criterion) by removing the multiaffine hypothesis.\n\n**Ambition:** Grand challenge \u2014 would unify the multiaffine compression theory with the full Br\u00e4nd\u00e9n-Huh framework.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "b24e9482",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T05:27:26.773711+00:00"
  },
  {
    "id": "fd_1072",
    "title": "Direction 3: Partition Function Certification in Statistical Physics",
    "description": "**Conjecture:** The partition function $Z_M(\\lambda) = \\sum_{I \\text{ indep}} \\lambda^{|I|}$ of the *independence complex* of a matroid $M$ is a Lorentzian polynomial in the $\\lambda_i$ variables (one per element), and the support compression principle reduces the certification cost from exponential to polynomial for sparse matroids arising in lattice models.\n\n**The key insight is:** Matroid independence complexes are the natural setting for hard-core lattice gas models, and Lorentzian certification of the partition function would imply strong log-concavity of the independence sequence \u2014 a result with direct thermodynamic consequences (absence of phase transitions in certain regimes).\n\n**Why now?** The Anari-Liu-Oveis Gharan-Vinzant result on log-concave polynomials [2021] already established connections between matroid theory and partition functions. Our support compression theorem provides the missing algorithmic component: not just that Lorentzian certification exists in principle, but that it's computationally feasible for sparse systems.\n\n**Test:** Compute the partition function for graphic matroids of small Ising-model lattices. Verify Lorentzian positivity by exhaustive leaf checking, then compare the compressed leaf count with the ambient count. The conjecture predicts that lattice sparsity translates to certification sparsity.\n\n**Impact:** Would connect formal verification of polynomial positivity to predictions in statistical mechanics, providing mathematically certified bounds on phase transition parameters.\n\n**Catalog References:** `Catalog/Pythagorean/SupportCompression.lean`, `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`IsMConvexExchangeNat`)\n\n**Proof Strategy:** Extend the basis polynomial framework to the full independence complex polynomial. Use the matroid truncation operation to relate independent sets of different sizes to basis polynomials of truncated matroids.\n\n**Domain Bridges:** Statistical physics (partition functions, phase transitions), probability (log-concave distributions), algorithm design (MCMC sampling).\n\n**Lineage:** Extends Theorem 2 (matroid bridge) from bases to the full independence complex.\n\n**Ambition:** Grand challenge \u2014 bridges formal mathematics to physics.\n\n---",
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
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "b24e9482",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T05:27:26.856241+00:00"
  },
  {
    "id": "fd_1075",
    "title": "Direction 1: Quantitative Helfgott-Type Growth in GL(2, F_p)",
    "description": "**Conjecture:** For every $\\varepsilon > 0$, there exists $\\delta > 0$ such that for every prime $p$ and every symmetric subset $A \\subseteq \\mathrm{SL}(2, \\mathbb{F}_p)$ with $1 \\in A$ and $|A| \\leq p^{3 - \\varepsilon}$, either $A$ is contained in a proper subgroup or $|A \\cdot A \\cdot A| \\geq |A|^{1 + \\delta}$.\n\n**Test:** Implement the product set triple computation $A^3$ for randomly sampled sets in $\\mathrm{SL}(2, \\mathbb{F}_p)$ with $p = 11, 13, 17, 19, 23$ and measure the exponent $\\delta$ as a function of $|A|/p^3$. A single family with sublinear triple-product growth would refute the conjecture.\n\n**Impact:** This would be the first formally verified quantitative growth theorem for linear groups, providing an explicit exponent rather than just a qualitative dichotomy. It would connect our Theorem 2 (strict growth) to Helfgott's breakthrough result and potentially yield constructive expander bounds.\n\n**Catalog References:** `Catalog/Algebra/MatrixGroupGeneration.lean` \u2014 the irreducible characteristic polynomial certificates can exclude containment in Borel (triangular) subgroups, which is the main obstruction to growth in $\\mathrm{SL}(2)$.\n\n**Proof Strategy:** Decompose into three lemmas: (a) escape from tori using trace arguments, (b) escape from Borel subgroups using irreducibility certificates, (c) sum-product estimates over $\\mathbb{F}_p$ for the remaining case. The key insight is that the generation certificates from the catalog provide exactly the escape witnesses needed.\n\n**Domain Bridges:** Additive combinatorics (sum-product estimates), analytic number theory (exponential sum bounds).\n\n**Lineage:** Extends `strict_growth_of_not_subgroup` from qualitative to quantitative.\n\n**Ambition:** Grand challenge \u2014 would constitute a new formally verified proof of (a special case of) a major theorem in arithmetic combinatorics.\n\n---",
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
    "source_exp_id": "a0951d1f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T06:04:06.524018+00:00"
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
    "id": "fd_1077",
    "title": "Direction 3: Spectral Gap from Product Growth",
    "description": "**Conjecture:** If $A \\subseteq G$ is a symmetric generating set of a finite group with $1 \\in A$ and growth ratio $\\sigma = |A^2|/|A|$, then the spectral gap $\\lambda_1$ of the normalized Cayley graph adjacency operator satisfies $\\lambda_1 \\geq c(\\sigma - 1) / \\sigma$ for an absolute constant $c > 0$.\n\n**Test:** For each family in our computational suite, compute the actual eigenvalues of the Cayley graph adjacency matrix (feasible for $\\mathrm{GL}(2, \\mathbb{F}_5)$ with 480 elements) and compare the spectral gap to the predicted bound. Deviation from the linear relationship would refine the conjecture.\n\n**Impact:** This would complete the triangle between model theory, group growth, and spectral graph theory. Product growth \u2192 spectral gap \u2192 mixing time \u2192 expander certificates, all formally verified.\n\n**Catalog References:** `Catalog/Algebra/MatrixGroupGeneration.lean` \u2014 the orbit spanning theorem (`span_orbit_eq_top_of_irreducible`) provides the invariant-subspace-free condition that, spectrally, prevents eigenvalue concentration.\n\n**Proof Strategy:** The key insight is that `support_walk_grows_of_product_grows` (Theorem 3) already establishes the qualitative connection; quantifying it requires bounding the $\\ell^2$ norm of the convolution operator using the cardinality growth. Use the Cauchy-Schwarz convolution bound: $\\|f * g\\|_2^2 \\leq \\|f\\|_1^2 \\cdot \\|g\\|_2^2 / |G|$.\n\n**Why now?** Theorem 3 provides the qualitative link; upgrading to a quantitative spectral bound is a natural next step that was impossible before the random walk theorem was verified.\n\n**Domain Bridges:** Spectral graph theory, probability theory, theoretical computer science (expander graphs).\n\n**Lineage:** Extends `support_walk_grows_of_product_grows`.\n\n**Ambition:** Solid extension \u2014 quantitative version of an established qualitative link.\n\n---",
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
    "source_exp_id": "a0951d1f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T06:04:06.590349+00:00"
  },
  {
    "id": "fd_1081",
    "title": "Direction 1: Weighted Distance Equality via Tropical Cycle Optimization",
    "description": "**Conjecture:** For graph-derived CSS codes with arbitrary positive edge weights, the code distance equals the minimum total weight of a simple cycle in the interaction graph. Under an appropriate \"girth-adapted\" filtration (edges ordered by a cycle-aware criterion), the first cycle birth value equals this minimum cycle weight.\n\n**Test:** Construct random weighted graphs on 8\u201320 vertices with weights drawn from {1, 2, ..., 10}. Compute:\n- The minimum-weight simple cycle (by exhaustive search for small graphs).\n- The first cycle birth under Kruskal filtration.\n- The first cycle birth under a modified filtration that orders edges by their contribution to shortest cycles.\nIf the girth-adapted FCB equals the minimum cycle weight in >95% of cases, the conjecture is supported. If it fails, identify the structural obstruction.\n\n**Impact:** Would extend the exact distance theorem from unit weights to arbitrary weights, making the tropical approach directly applicable to quantum hardware with non-uniform coupling strengths.\n\n**Catalog References:**\n- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`: `codeDistance_eq_firstCycleBirth_of_simpleCycle`\n- `Pythagorean/TropicalMorse/Theorems.lean`: `redundant_edges_eq_cycle_rank`\n\n**Proof Strategy:** Define a \"cycle-adapted\" weight ordering that processes edges in order of their minimum-cycle-weight contribution. Prove that under this ordering, the first cycle birth equals the minimum cycle weight. Use the monotonicity theorem to bootstrap from the unit-weight case.\n\n**Domain Bridges:** Tropical geometry \u2194 combinatorial optimization \u2194 quantum hardware design.\n\n**Lineage:** Direct extension of Theorem 3 (exact distance in simple-cycle regime).\n\n**Ambition:** Solid extension \u2014 requires new combinatorial arguments but builds directly on established foundations.\n\n**The key insight is** that the filtration ordering determines which cycle appears first, and an intelligently chosen ordering can make the first cycle birth coincide with the minimum-weight cycle.\n\n**Why now?** The monotonicity theorem provides the key tool: if we can show that the girth-adapted filtration maximizes the first cycle birth among all filtrations, the result follows.\n\n---",
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
    "source_exp_id": "b0b26cee",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T07:14:49.731669+00:00"
  },
  {
    "id": "fd_1082",
    "title": "Direction 2: Spectral Decoding via Tropical Morse Barcodes",
    "description": "**Conjecture:** The full tropical Morse spectrum (not just the first cycle birth) encodes sufficient information to construct an efficient minimum-weight decoder for graph-CSS codes. Specifically, the barcode structure \u2014 the persistence intervals of cycle events \u2014 identifies likely error patterns and guides syndrome-based correction.\n\n**Test:** Implement a \"tropical decoder\" that uses the TMS barcode to weight the edges of the decoding graph. Compare decoder performance (logical error rate vs. physical error rate) against:\n- Minimum-weight perfect matching (MWPM) decoder.\n- Union-find decoder.\nTest on surface codes of sizes 3\u00d73, 5\u00d75, 7\u00d77 under depolarizing noise at rates p = 0.01, 0.05, 0.10. If the tropical decoder achieves comparable or better logical error rates, the conjecture is supported.\n\n**Impact:** Would provide a new class of decoders inspired by tropical geometry, potentially with better scaling or simpler implementation than existing approaches.\n\n**Catalog References:**\n- `Pythagorean/TropicalMorse/Defs.lean`: `TMSpectrum`, `tropicalMorseComplexity`\n- `Pythagorean/TropicalMorse/Theorems.lean`: `spectral_gap_distinguishes`\n\n**Proof Strategy:** Show that the barcode persistence intervals correspond to \"error vulnerability windows\" \u2014 ranges of error weights where specific logical operators become active. Use this to construct a weight function for the decoding graph that penalizes edges in high-vulnerability regions.\n\n**Domain Bridges:** Persistent homology \u2194 quantum error correction \u2194 algorithmic graph theory.\n\n**Lineage:** Extends the spectral classification theorem (Theorem 5) from static classification to dynamic error correction.\n\n**Ambition:** Grand challenge \u2014 connects two major research programs (persistent homology and quantum decoding) through a concrete algorithmic proposal.\n\n**The key insight is** that the tropical Morse barcode encodes not just the *number* of logical operators but their *weight hierarchy*, which is exactly the information a decoder needs to distinguish likely from unlikely errors.\n\n**Why now?** The TMS computation is O(E log E), making it feasible to run in real-time as a preprocessing step for decoding. Recent advances in barcode-guided algorithms in topological data analysis provide the technical toolkit.\n\n---",
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
    "timestamp": "2026-05-26T07:14:49.772033+00:00"
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
    "id": "fd_1086",
    "title": "Direction 1: Quantum 2-Designs from Certified Unitary Expanders",
    "description": "**Conjecture:** For every prime power q and n \u2265 2, the finite unitary group SU_n(\ud835\udd3d_{q\u00b2}) admits certified pairs (s, t) whose Cayley graph produces an \u03b5-approximate unitary 2-design with |S| = O(1) generators and mixing time O(log |G|), where \u03b5 and the implicit constant are independent of q.\n\n**Test:** Implement the certificate check for SU\u2082(\ud835\udd3d_{q\u00b2}) \u2245 SL\u2082(\ud835\udd3d_q) for q = 3, 5, 7. Compute the frame potential (a measure of 2-design quality) for the Cayley walk and verify it converges to the Haar value 2/n! within O(log |G|) steps. Compare with random unitary circuits of the same depth.\n\n**Impact:** Explicit unitary 2-designs are essential for quantum state tomography, randomized benchmarking, and quantum error correction. Current constructions use either random circuits (non-deterministic) or Clifford groups (limited to stabilizer codes). Certified unitary expanders would provide a new family of deterministic 2-designs with provable convergence, bridging classical group theory and quantum information.\n\n**Catalog References:** `Catalog/Algebra/ClassicalGroupExpanders.lean` (ClassicalGenCertificate, HasVertexExpansion), `Catalog/Algebra/MatrixGroupGeneration.lean` (eq_bot_or_top_of_charpoly_irreducible).\n\n**Proof Strategy:** (1) Define a \"quantum certificate\" for SU_n by requiring irreducible charpoly over \ud835\udd3d_{q\u00b2} and a form-compatibility condition for the Hermitian structure. (2) Show certified pairs generate SU_n (extending Theorem 2). (3) Transfer spectral gap to frame potential convergence using the representation-theoretic spectral bound and the fact that SU_n has quasirandomness parameter growing with q.\n\n**Domain Bridges:** Quantum information theory \u2194 finite group theory \u2194 spectral graph theory. The 2-design application connects Cayley expansion to quantum circuit depth, and the certificate architecture provides a new algorithmic interface between classical algebra and quantum computing.\n\n**Lineage:** Extends the structural certificate (Theorem 1) from GL_n to SU_n, and the spectral transfer (Theorem 4) to the quantum mixing regime.\n\n**Ambition:** Grand challenge. If successful, provides the first uniform family of certified quantum 2-designs from finite groups of Lie type.\n\n---",
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
    "source_exp_id": "d9e69258",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T08:24:14.577634+00:00"
  },
  {
    "id": "fd_1088",
    "title": "Direction 3: Certified Expander Codes with Linear-Time Decoding",
    "description": "**Conjecture:** For every \u03b5 > 0 and rate R < 1, there exists a family of certified Cayley-graph expander codes over Sp_{2n}(\ud835\udd3d_q) (with n, q varying) achieving rate \u2265 R, relative distance \u2265 \u03b4(\u03b5) > 0, and linear-time decoding complexity O(N) where N is the block length, provided the Cayley graph is constructed from a certified pair with gap \u2265 \u03b5.\n\n**Test:** Implement Sipser-Spielman (or Zemor) decoding on Tanner codes built from certified Cayley graphs of GL\u2082(\ud835\udd3d_p) for p = 3, 5, 7, 11. Measure decoding failure rate vs. channel noise for BSC and AWGN channels. Compare with standard LDPC codes of similar block length and rate.\n\n**Impact:** Currently, the best explicit linear-time decodable codes (Spielman 1996, Guruswami-Indyk 2005) rely on expanders whose construction is somewhat ad hoc. Certified Cayley-graph codes would provide a *uniform family* with provable parameters directly from the group certificate, potentially matching or exceeding the performance of capacity-approaching codes in the moderate block-length regime.\n\n**Catalog References:** `Catalog/Algebra/ClassicalGroupExpanders.lean` (expansion_neighbor_growth, expansion_monotone_of_superset), `Catalog/Algebra/MatrixGroupGeneration.lean` (span_orbit_eq_top_of_irreducible \u2014 orbit spanning as code generator).\n\n**Proof Strategy:** (1) Construct bipartite Tanner codes from the bipartite double cover of certified Cayley graphs. (2) Use the vertex expansion bound (Theorem 4) to prove the inner codes' parity-check matrices satisfy the \"unique neighbor\" property. (3) Analyze the Sipser-Spielman peeling decoder: each round corrects a constant fraction of errors, so O(log N) rounds suffice. (4) Each round takes O(N) time, giving O(N log N) total \u2014 tight analysis using the certificate gap should reduce this to O(N).\n\n**Domain Bridges:** Coding theory \u2194 group theory \u2194 spectral graph theory \u2194 algorithm design. The certificate provides a single algebraic object (the generator pair) that simultaneously determines the code, the graph, and the decoding algorithm.\n\n**Lineage:** Builds on the cross-domain bridge (expansion \u2192 boundary growth) from Theorem 4 and the coding-theory connection discussed in the research paper.\n\n**Ambition:** Solid extension with high practical impact.\n\n---",
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
    "source_exp_id": "d9e69258",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T08:24:14.647375+00:00"
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
    "id": "fd_1092",
    "title": "Direction 2: Chip-Firing Canonical Forms via Tropical Kernels",
    "description": "**Conjecture:** The canonical tropical kernel generators, under the separation hypothesis, correspond bijectively to the generators of the critical group (sandpile group / Jacobian) of the graph restricted to S.\n\n**Test:** For all connected graphs on n \u2264 7, compute both the canonical tropical kernel generators and the Smith normal form of the restricted Laplacian. Verify that the number of generators matches the rank of the critical group, and that the canonical generators span the correct sublattice.\n\n**Impact:** Would provide a tropical-geometric interpretation of the critical group, connecting chip-firing dynamics to tropical kernel uniqueness.\n\n**Catalog References:** `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (harmonicKernel, IsHarmonicOn), `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian, firingIndependentOn).\n\n**Proof Strategy:** Show that the canonical generators of the harmonic kernel modulo constants form a basis for the critical group. Use the leaf rigidity lemma to propagate values from cycles to trees, matching the chip-firing spreading rule.\n\n**Domain Bridges:** Connects tropical algebra to algebraic graph theory (critical groups), number theory (lattice theory), and statistical mechanics (sandpile models / self-organized criticality).\n\n**Lineage:** Builds on `harmonic_leaf_rigidity` and `constant_isHarmonicOn`.\n\n**Ambition:** Solid extension \u2014 well-motivated by existing connections between chip-firing and tropical geometry.\n\n**The key insight is** that the uniqueness of tropical kernel generators under separation should reflect the uniqueness of the Smith normal form \u2014 both are canonical decompositions forced by the Laplacian structure. **Why now?** The leaf rigidity and harmonic kernel infrastructure are now formally verified, providing a solid foundation for connecting to chip-firing.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "42d710f5",
    "consumed_by_exp_id": "1fb257b2",
    "timestamp": "2026-05-26T08:59:20.844806+00:00"
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
    "id": "fd_1097",
    "title": "Direction 2: Exceptional Groups and Character-Sheaf Certificates",
    "description": "**Conjecture:** For the exceptional group G\u2082(\ud835\udd3d_q), there exist regular toral elements s with character-ratio bound |\u03c7(s)/\u03c7(1)| \u2264 C/q where C depends only on the root system, not on q. Combined with the transference theorem, this yields uniform G\u2082 expanders.\n\n**Test:** For G\u2082(\ud835\udd3d_q) with q = 3, 5, 7 (|G\u2082(\ud835\udd3d\u2083)| = 6,048), compute all irreducible character values on regular semisimple elements of each torus type. Verify that the maximum character ratio is bounded by C/q for some fixed C. Falsified if the ratio grows or oscillates with q.\n\n**Impact:** The first explicit expander construction for an exceptional group, opening a bridge between exceptional Lie theory and combinatorial expansion.\n\n**Catalog References:** `Pythagorean/Sp4SpectralGap.lean` (character_ratio_to_spectral_gap, cheeger_from_spectral_gap).\n\n**Proof Strategy:** G\u2082 has only 5 conjugacy classes of maximal tori. Enumerate them, compute Deligne\u2013Lusztig characters via Green functions, and extract explicit character-ratio bounds. The transference theorem applies directly. **The key insight is** that the small number of torus types in exceptional groups makes explicit enumeration feasible, unlike classical groups where the number grows with rank.\n\n**Why now?** The transference framework absorbs any character-ratio bound, and G\u2082 character tables are explicitly known (Chang, Ree 1974). The bottleneck was never the character theory but the lack of a clean consumption mechanism.\n\n**Domain Bridges:** Exceptional symmetries arise in string theory (E\u2088), materials science (icosahedral symmetry via H\u2083 \u2282 E\u2088), and the Langlands program.\n\n**Lineage:** Parallel to Direction 1, but exploring width (different group families) rather than depth (higher rank).\n\n**Ambition:** Grand challenge \u2014 first formalized exceptional-group expanders.\n\n---",
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
    "timestamp": "2026-05-26T09:39:15.086140+00:00"
  },
  {
    "id": "fd_1098",
    "title": "Direction 3: Hecke Operator Comparison and Building Spectra",
    "description": "**Conjecture:** The spectral gap of the Cayley graph Cay(Sp\u2084(\ud835\udd3d_q), S) with toral generators is within a constant factor of the spectral gap of the Hecke operator on the spherical building of Sp\u2084(\ud835\udd3d_q), with the comparison constant depending only on the degree |S|.\n\n**Test:** For q = 3, 5, 7, compute both the Cayley graph spectral gap and the building Hecke operator spectral gap. Plot the ratio gap_Cayley / gap_Hecke as a function of q. Falsified if the ratio diverges or tends to zero.\n\n**Impact:** Would connect finite-group expansion to the rich theory of automorphic forms on buildings, potentially yielding a finite-field analogue of the Ramanujan conjecture for Sp\u2084.\n\n**Catalog References:** `Pythagorean/Sp4SpectralGap.lean` (spectralGapBound, sp4_uniform_gap_family).\n\n**Proof Strategy:** Model the Cayley graph operator as a perturbation of the building Hecke operator. Use the Iwahori decomposition to decompose the regular representation into building representations. Bound the perturbation via the character-ratio certificate. **The key insight is** that the building decomposition separates the \"geometric\" contribution (controlled by the building spectrum) from the \"arithmetic\" contribution (controlled by character ratios), and the certificate bounds the latter.\n\n**Why now?** The Bruhat\u2013Tits building of Sp\u2084 is a 2-dimensional simplicial complex whose spectral theory is well-studied (Cartwright\u2013Steger). The transference framework provides the missing link between building spectra and Cayley graph spectra.\n\n**Domain Bridges:** Building spectra connect to automorphic representations (number theory), high-dimensional expanders (combinatorics), and topological data analysis (applied mathematics).\n\n**Lineage:** Extends the spectral gap framework from graphs to higher-dimensional simplicial complexes.\n\n**Ambition:** Solid extension \u2014 proven feasibility from existing building-spectrum literature.\n\n---",
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
    "source_exp_id": "21d69cc6",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T09:39:15.120527+00:00"
  },
  {
    "id": "fd_1101",
    "title": "Direction 1: Torsion-Aware Tropical Morse Theory",
    "description": "**Conjecture**: Over \u2124 coefficients, the simplex insertion dichotomy generalizes to a *trichotomy*: each d-simplex insertion either (a) births a free d-cycle, (b) kills a free (d\u22121)-cycle, or (c) changes the torsion subgroup of H_{d\u22121} \u2014 specifically, either creating a new torsion element or annihilating one. The tropical event type should encode the Smith normal form diagonal entry, giving a \"tropical torsion spectrum.\"\n\n**The key insight is** that over \u2124, the boundary of an inserted simplex can be a non-trivial multiple of an existing cycle rather than zero or linearly independent, leading to torsion phenomena invisible over fields.\n\n**Why now?** The field-coefficient dichotomy is formally verified. The \u2124 case is the natural next step, and the Smith normal form machinery exists in Mathlib. The Linial-Meshulam model over \u2124 is known to exhibit torsion phase transitions.\n\n**Test**: Compute H_1(K; \u2124) for random 2-complexes on \u2124\u2083-projective-plane-like structures. Track torsion changes at each triangle insertion. Classify into the three event types.\n\n**Impact**: Opens tropical Morse theory to torsion-sensitive applications (manifold recognition, crystallographic defects, quantum error correction codes where torsion encodes logical qubits).\n\n**Catalog References**: `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean` \u2014 simplex_insertion_dichotomy (the field case to generalize).\n\n**Proof Strategy**: Define torsion rank and torsion-type for Smith normal form entries. Prove the \u2124-coefficient insertion produces exactly one change in the combined (free rank, torsion profile) invariant.\n\n**Domain Bridges**: Algebraic topology (torsion in homology), quantum error correction (homological codes), number theory (class groups as torsion).\n\n**Lineage**: Extends the birth/death dichotomy from free rank to full homological type.\n\n**Ambition**: Grand challenge \u2014 would unify persistent homology with arithmetic invariant theory.\n\n---",
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
    "priority_score": 0.9999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "4895ceb4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T10:14:17.520231+00:00"
  },
  {
    "id": "fd_1102",
    "title": "Direction 2: Tropical Stability Theorem for Event Profiles",
    "description": "**Conjecture**: If two weight functions w, w' on the same simplicial complex satisfy ||w \u2212 w'||_\u221e \u2264 \u03b5, then the bottleneck distance between the induced tropical barcode profiles is at most \u03b5. Moreover, the number of events whose type (birth/death) changes is bounded by the number of \"critical crossings\" \u2014 pairs of simplices whose weight ordering is reversed.\n\n**The key insight is** that the tropical event type at each insertion depends on the boundary rank, which is a discrete invariant. Small weight perturbations can only change event types at insertions whose weight is within \u03b5 of another insertion's weight \u2014 the \"critical crossings.\"\n\n**Why now?** Classical stability (Cohen-Steiner\u2013Edelsbrunner\u2013Harer 2007) is established for barcodes but not for tropical event profiles. Our verified correspondence theorem (`tropical_persistent_rank_eq_classical`) provides the algebraic bridge. The stability statement is falsifiable and algorithmically testable.\n\n**Test**: Generate 1000 pairs of random weight functions differing by at most \u03b5 = 0.1 on 2-complexes with 20 vertices. Compute both tropical event profiles. Measure bottleneck distance and compare to \u03b5.\n\n**Impact**: Would establish tropical event profiles as a robust descriptor for applications (materials science, sensor networks) where weights are measured with noise.\n\n**Catalog References**: `Catalog/Pythagorean/TropicalMorse/Theorems.lean` \u2014 sublevel_perturbation_containment (graph-level stability). `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean` \u2014 tropical_persistent_rank_eq_classical.\n\n**Proof Strategy**: Use the interleaving distance between filtrations. Show that weight perturbation \u03b5 creates at most an \u03b5-interleaving, which bounds the bottleneck distance on barcodes, which bounds the event profile divergence.\n\n**Domain Bridges**: Topological data analysis (stability theory), signal processing (robustness), metric geometry (Gromov-Hausdorff stability).\n\n**Lineage**: Direct extension of existing stability results to the tropical event language.\n\n**Ambition**: Solid extension \u2014 essential infrastructure for applications.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.9999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "4895ceb4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T10:14:17.553765+00:00"
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
    "id": "seed_051",
    "title": "Tropical Intersection Theory",
    "description": "Prove that the tropicalization functor preserves intersection numbers. Formalize tropical varieties as polyhedral complexes and establish the tropical B\u00e9zout theorem with explicit bounds.",
    "domains": [
      "Tropical",
      "Geometry"
    ],
    "priority_score": 0.9199999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-24T22:37:54.672853+00:00"
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
    "id": "fd_1106",
    "title": "Direction 1: Complete Aschbacher Certificate Theory",
    "description": "**Conjecture:** For each of the 8 Aschbacher classes of maximal subgroups of GL(n, \ud835\udd3d_q), there exists a polynomial-time certificate condition on a pair (g, h) that excludes membership of \u27e8g, h\u27e9 in that class. The conjunction of all 8 certificates implies \u27e8g, h\u27e9 = GL(n, \ud835\udd3d_q) (or \u27e8g, h\u27e9 \u2287 SL(n, \ud835\udd3d_q)).\n\n**Test:** Formalize certificate conditions for each Aschbacher class and verify them computationally for GL(3, \ud835\udd3d_q) and GL(4, \ud835\udd3d_q) with q \u2264 100. For each class, construct explicit pairs lying in a maximal subgroup of that type and verify that the certificate correctly identifies them. A single class where no polynomial-time certificate exists would disprove the conjecture.\n\n**Impact:** A complete Aschbacher certificate theory would transform computational group recognition from an exponential-time problem (subgroup enumeration) to a polynomial-time problem (certificate verification). This would have immediate consequences for:\n- Constructive recognition of classical groups in computational algebra systems (GAP, Magma)\n- Efficient verification of group-based cryptographic protocols\n- Polynomial-time testing of group generation in randomized algorithms\n\n**Catalog References:**\n- `Catalog/Algebra/MatrixGroupGeneration.lean`: `eq_bot_or_top_of_charpoly_irreducible` handles Class C\u2081\n- `Pythagorean/CertificateComplexity.lean`: `irreducible_charpoly_excludes_invariant_direct_summand` handles part of Class C\u2082\n\n**Proof Strategy:** For each Aschbacher class, identify the algebraic invariant that distinguishes the class:\n- C\u2081 (reducible): charpoly factorization \u2014 DONE\n- C\u2082 (imprimitive): charpoly multiplicative structure\n- C\u2083 (extension field): minpoly degree relative to subfield\n- C\u2084 (tensor product): charpoly symmetry under Kronecker decomposition\n- C\u2085 (subfield): trace field computation\n- C\u2086 (symplectic/extraspecial): form invariant testing\n- C\u2087 (tensor induced): higher tensor analysis\n- C\u2088 (classical): bilinear form preservation\n\n**Domain Bridges:** Coding theory (class C\u2082 relates to code automorphism groups), representation theory (all classes), algebraic geometry (class C\u2083 connects to Weil restriction).\n\n**Lineage:** Builds directly on Theorems 1-4 of the current work.\n\n**Ambition:** Grand challenge \u2014 would resolve a 40-year-old algorithmic problem in computational group theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "79565d7a",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-26T11:21:55.320419+00:00"
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
    "id": "fd_0812",
    "title": "Prime-Indexed Spectral Shadows of Modular Forms in Persistent Homology",
    "description": "Conjecture: There exists a natural family of filtered simplicial complexes K_N attached to arithmetic data up to cutoff N (for example complexes built from divisibility, residue-class, or Hecke-neighbor relations on integers) such that for some fixed homological degree d, the primewise torsion barcode statistics of H_d(K_N; Z) converge, after explicit normalization in N and p, to the Hecke eigenvalue distribution of a non-CM modular form f. More precisely, the generating function of p-torsion birth/death multiplicities agrees asymptotically with a polynomial statistic of the coefficients a_p(f) on a positive-density set of primes. Test: Construct several canonical arithmetic filtrations, compute primewise persistent homology for large N, and compare normalized torsion summaries against databases of modular forms; confirmation requires statistically significant agreement for one filtration/form pair beyond random and null arithmetic models, while refutation occurs if no canonical construction exhibits nontrivial correlation after normalization and model selection penalties. Impact: This would create a new bridge between topological data analysis and automorphic arithmetic, potentially yielding a geometric-topological probe of L-functions and modular symmetry hidden in combinatorial integer structures.",
    "domains": [
      "Arithmetic Topology",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T00:26:47.015579+00:00"
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
    "id": "fd_0845",
    "title": "Arithmetic Monodromy Reconstruction from Primewise Persistent Homology",
    "description": "Conjecture: There exists a canonical construction sending a smooth projective variety X over a number field to a family of filtered complexes C_p(X) for good primes p such that the collection of prime-indexed persistence barcodes determines the semisimplified Frobenius characteristic polynomials on \u00e9tale cohomology in each degree for a density-1 set of primes. Equivalently, if X and Y have identical barcode data for all sufficiently large good primes under this construction, then their local zeta functions agree for a density-1 set of primes. Test: Implement the construction for explicit families (elliptic curves, K3 surfaces, low-genus curves, toric hypersurfaces), compute barcode invariants prime-by-prime, and check whether non-isogenous/non-derived-equivalent examples can be separated exactly when their Frobenius polynomials differ. A refutation would be a pair with distinct local zeta data but indistinguishable persistence outputs. Impact: This would create a new topological-computational interface for recovering arithmetic Galois data from geometric filtrations, potentially yielding machine-discoverable arithmetic invariants and a new bridge between TDA, arithmetic geometry, and the Langlands viewpoint.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T03:05:45.192441+00:00"
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
    "id": "fd_0851",
    "title": "Automorphic Monodromy from Persistence Under Hecke Correspondences",
    "description": "Conjecture: There exists a canonical filtered simplicial complex K_N(f) attached to a cuspidal Hecke eigenform f of fixed weight and level, built from the Hecke orbit data {a_p(f)}_{p \\le N}, such that the stable persistent homology of the family {K_N(T_\\ell f)} over varying Hecke operators T_\\ell determines the local Satake parameters of f at a density-1 set of primes. In particular, two non-CM eigenforms with distinct automorphic representations yield asymptotically different persistence signatures under Hecke action. Test: Compute K_N(f) for large databases of modular forms, apply Hecke operators, and check whether barcode/landscape invariants classify forms up to matching Satake parameters outside a zero-density exceptional set; refuted if non-isomorphic forms repeatedly produce indistinguishable persistence signatures under all tested Hecke actions. Impact: This would create a new topological observable for automorphic representations, potentially giving a computational bridge between Langlands data, spectral statistics, and topological data analysis.",
    "domains": [
      "Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T03:08:11.583910+00:00"
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
    "id": "fd_0899",
    "title": "Arithmetic Noise Stability Threshold for Prime-Labeled Simplicial Complexes",
    "description": "Conjecture: Let X be a smooth projective variety over Q with good reduction outside a finite set, and for each good prime p let K_p(X) be a canonically defined finite simplicial complex built from the Frobenius action on etale cohomology modulo p together with a filtration by Frobenius slope or valuation. Then there exists a universal noise-stability threshold function T_X(epsilon) such that if one perturbs the local Frobenius data independently on a set of primes of upper density less than epsilon, the resulting family {K'_p(X)} has the same asymptotic barcode law as {K_p(X)} for all filtration scales above T_X(epsilon); but if X and Y are not potentially derived-equivalent, then for some epsilon > 0 no such common threshold exists for the mixed family alternating between X and Y on a density-epsilon set of primes. Test: Define an explicit canonical complex from point-count/Frobenius data for concrete classes such as elliptic curves, K3 surfaces, or abelian varieties; compute persistence summaries across primes; inject controlled random and adversarial perturbations on a sparse set of primes; verify whether barcode statistics remain stable below the predicted density threshold, and whether mismatched varieties exhibit a detectable instability gap. Refutation occurs if sparse perturbations destroy asymptotic persistence laws generically, or if non-equivalent varieties remain indistinguishable under all such density-sparse prime corruptions. Impact: This would introduce a mathematically precise notion of error-correcting arithmetic topology, showing that deep geometric/arithmetic structure can be recovered robustly from incomplete or corrupted prime data, with consequences for anabelian-style reconstruction, arithmetic statistics, and certified inference from noisy zeta data.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T17:15:12.531139+00:00"
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
    "id": "fd_0914",
    "title": "Adelic Synchronization Threshold for Primewise Persistent Homology",
    "description": "Conjecture: There exists an explicit arithmetic family of filtered chain complexes C(X) over Z, naturally attached to smooth projective varieties X/Q, for which the collection of primewise persistence diagrams {D_p(X)} exhibits a sharp synchronization law: if X and Y have isomorphic semisimplified l-adic Galois representations in one fixed cohomological degree, then for a density-1 set of primes p their normalized primewise persistence landscapes agree up to o(1); conversely, if the normalized landscapes agree on a density-1 set of primes, then the Frobenius trace distributions in that degree must agree. Test: Construct C_p(X) from point-count/Frobenius data for explicit families (elliptic curves, K3 surfaces, Calabi-Yau hypersurfaces), compute persistence landscapes across many good primes, and check whether density-1 agreement matches equality of Frobenius trace statistics and whether known non-isogenous examples fail synchronization on positive-density prime sets. Impact: This would turn persistent homology into a new adelic probe of arithmetic equivalence, potentially yielding computable topological fingerprints of Galois representations and a bridge between TDA and arithmetic geometry.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:03:31.504296+00:00"
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
    "id": "fd_0948",
    "title": "Finite Prime Fingerprints Determine Arithmetic Varieties up to Isogeny/Derived T",
    "description": "Conjecture: There exists a universal constant B depending only on dimension d such that for any two smooth projective varieties X,Y over Q of dimension d in a fixed geometric class (e.g. abelian varieties, K3 surfaces, or Calabi\u2013Yau threefolds), if their primewise Frobenius characteristic polynomials agree for every good prime p <= B, then X and Y are forced into the same arithmetic equivalence class (isogenous in the abelian case, same semisimplified l-adic Galois representation in general, and possibly derived equivalent in special classes). Test: For each class and dimension, compute databases of varieties and search for the smallest B for which collisions disappear; a single counterexample pair with matching data up to arbitrarily large tested bounds but inequivalent geometry refutes the strongest form. Confirmation comes from observing a sharp finite-identifiability threshold and proving it in low-dimensional families. Impact: This would turn arithmetic reconstruction from an asymptotic/infinite-prime phenomenon into a finite-data principle, enabling compressed arithmetic classification, new algorithms for recognition of varieties, and a bridge between Faltings-style rigidity and computational geometry.",
    "domains": [
      "Arithmetic Geometry",
      "Computational Number Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:13:17.989462+00:00"
  },
  {
    "id": "fd_0954",
    "title": "Adversarial Prime Blindness for Persistent Arithmetic Invariants",
    "description": "Conjecture: There exists an explicit infinite family of finite filtered chain complexes over Z, computable in polynomial time, such that for every fixed finite set of primes S the full collection of S-local persistence invariants (including all p-primary barcode data for p in S) is identical for two non-isomorphic members of the family, yet their global integer persistence modules are non-isomorphic and are distinguished by torsion at a prime outside S. Test: Construct the family and algorithmically verify, for increasing size parameter N, that all localized invariants at primes in S coincide while Smith normal form over Z reveals a discrepancy at a new prime q_N not in S; refute by proving a finite-prime completeness theorem showing some universal finite S always determines the global module in this setting. Impact: This would establish a sharp impossibility theorem for finite-prime arithmetic summaries, forcing adelic or adaptive-prime methods in integer persistent homology and suggesting cryptographic-style hiding phenomena inside topological invariants.",
    "domains": [
      "Topological Data Analysis",
      "Algebraic Number Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T21:13:49.686566+00:00"
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
