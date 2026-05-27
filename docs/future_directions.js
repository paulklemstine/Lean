

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
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
    "id": "fd_0907",
    "title": "Spectral Sequence Stability via Persistent Homology Barcodes",
    "description": "Conjecture: For first-quadrant homological spectral sequences E\u2081 \u21d2 H, if two spectral sequences have E\u2081 pages that are \u03b5-interleaved as bigraded persistence modules (with respect to the total-degree filtration), then their 'limit barcodes' \u2014 which record elements surviving to E\u221e as infinite bars and elements killed by d_r as finite bars of length r \u2014 are C\u00b7\u03b5-interleaved for a constant C depending only on the spectral sequence length (max page index). Test: For the Serre spectral sequences of the Hopf fibration S\u00b9\u2192S\u00b3\u2192S\u00b2 and its small perturbations (e.g., replacing S\u00b3 with a lens space L(3,1)), compute the E\u2081 interleaving distance and verify that the limit barcodes satisfy the conjectured stability bound. Secondary test on pairs of Adams spectral sequences for related spectra. Impact: This would establish the first stability theorem for spectral sequences, making differential computations robust under perturbation \u2014 with transformative applications to stable homotopy theory (Adams SS), symplectic topology (Eilenberg-Moore SS), and algebraic geometry (Leray SS for morphisms of varieties).",
    "domains": [
      "Algebraic Topology",
      "Topological Data Analysis",
      "Spectral Sequences"
    ],
    "priority_score": 1.0,
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
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:03:02.506322+00:00"
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "88770e41",
    "consumed_by_exp_id": "39acdddf",
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
    "id": "fd_0926",
    "title": "Prime-Local Torsion Predicts Rational Homotopy Collapse",
    "description": "Conjecture: There exists a universal function B(d) such that for any finite simply connected CW complex X of dimension d, if for every prime p the p-primary barcode of the filtered loop-space chain complex C_*(\u03a9X; Z) has all intervals of length at most B(d), then the Sullivan minimal model of X is formal and the rational homotopy spectral sequence of \u03a9X collapses at E2. Test: Compute primewise persistent torsion barcodes for explicit non-formal spaces (for example symplectic but non-Kahler manifolds, moment-angle complexes, and wedges with attached cells) and check whether long p-primary intervals always appear; confirm on formal spaces (compact Kahler manifolds, spheres, projective spaces) that bounded intervals suffice. A single non-formal counterexample with uniformly bounded primewise torsion persistence refutes the conjecture. Impact: This would create a new bridge from computable finite-prime topological signatures to deep rational homotopy structure, giving an algorithmic detector for formality and spectral sequence collapse.",
    "domains": [
      "Algebraic Topology",
      "Persistent Homology"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-25T18:40:12.492126+00:00"
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "abb48be4",
    "consumed_by_exp_id": "dd920969",
    "timestamp": "2026-05-26T02:33:38.976648+00:00"
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
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "42d710f5",
    "consumed_by_exp_id": "",
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
    "id": "fd_1274",
    "title": "Direction 2: Growing Augmentation \u2014 The Phase Transition",
    "description": "**Conjecture:** There exists a critical growth rate f(n) for the number of global generators such that:\n- If |S_G(n)| = o(f(n)), the spectral gap ratio remains bounded (universality holds)\n- If |S_G(n)| = \u03c9(f(n)), the spectral gap ratio diverges (universality breaks)\n\nFor (\u2124/n\u2124)^2, the critical threshold is f(n) = \u0398(n^{2/3}).\n\n**Test:** For (\u2124/n\u2124)^2, add k random generators of word length \u2264 2 and compute the spectral gap ratio for k = 1, n^{1/3}, n^{1/2}, n^{2/3}, n. If the ratio remains bounded for k \u2264 n^{2/3} and diverges for k \u2265 n, the conjecture is supported.\n\n**Impact:** This would identify the exact boundary between \"locality-protected\" and \"accelerated\" regimes, resolving a fundamental question in Markov chain theory. The phase transition itself would be a new phenomenon connecting random graph theory (random Cayley augmentation) to spectral perturbation theory.\n\n**Catalog References:**\n- `Catalog/Pythagorean/CayleyExpander/HybridLocalGlobal.lean` \u2014 the bounded case\n- `Catalog/Pythagorean/CayleyExpander/CanonicalPaths.lean` \u2014 congestion methods\n\n**Proof Strategy:** For the upper bound regime, extend the Cauchy\u2013Schwarz telescoping argument with a probabilistic bound on path overlap. For the lower bound, construct explicit eigenfunctions whose Rayleigh quotient is significantly altered by growing augmentation.\n\n**Domain Bridges:** Random matrix theory (random perturbations of structured matrices), percolation theory (random long-range bonds)\n\n**Lineage:** Natural growth of the bounded augmentation principle\n\n**Ambition:** Grand challenge \u2014 would require new techniques beyond comparison methods\n\n**\"The key insight is...\"** that there must be a critical scale at which the cumulative effect of random shortcuts overcomes the local bottleneck, and identifying this scale connects spectral theory to percolation.\n\n**\"Why now?\"** The formal infrastructure for Dirichlet form comparison on Cayley graphs is now in place, and computational experiments can probe the transition regime before a full proof is available.\n\n---",
    "domains": [
      "Pythagorean",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "175f456d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T03:33:16.871764+00:00"
  },
  {
    "id": "fd_1275",
    "title": "Direction 3: Infinite Groups and Amenability",
    "description": "**Conjecture:** For amenable groups with polynomial growth (e.g., nilpotent groups), the locality-protection principle extends to asymptotic spectral gaps of F\u00f8lner sequences: the isoperimetric profile is invariant under bounded augmentation of the generating set.\n\n**Test:** For the discrete Heisenberg group H_3(\u2124) (a non-abelian nilpotent group of growth degree 4), compute the spectral gap of the Cayley graph restricted to balls of radius R, for both local and hybrid generators. Verify that the ratio remains bounded as R \u2192 \u221e.\n\n**Impact:** This would extend the locality-protection principle from finite groups to the rich world of infinite finitely generated groups, connecting to Varopoulos's theory of random walks on groups and the Coulhon\u2013Saloff-Coste heat kernel estimates. A positive result would show that the diffusive exponent (determined by the growth rate) is truly a quasi-isometric invariant.\n\n**Catalog References:**\n- `Catalog/Pythagorean/CayleyExpander/HybridLocalGlobal.lean` \u2014 finite group framework\n\n**Proof Strategy:** Use F\u00f8lner set approximation and the finite-group comparison theorem applied to increasing subgroups. The key challenge is controlling boundary effects as the F\u00f8lner sets grow.\n\n**Domain Bridges:** Geometric group theory (growth and isoperimetric profiles), harmonic analysis on nilpotent groups\n\n**Lineage:** Generalization from finite to infinite groups\n\n**Ambition:** Grand challenge \u2014 bridges to deep open questions in geometric group theory\n\n**\"The key insight is...\"** that polynomial growth groups have a well-defined \"diffusion exponent\" related to their growth degree, and our comparison method should preserve this exponent.\n\n**\"Why now?\"** The formal comparison infrastructure provides a template that can be adapted to truncated groups (finite quotients of infinite groups).\n\n---",
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
    "source_exp_id": "175f456d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T03:33:16.917986+00:00"
  },
  {
    "id": "fd_1280",
    "title": "Direction 2: Non-Cancellation Certificates and Coefficient-Aware Bounds",
    "description": "**Conjecture:** For polynomials over fields of characteristic zero with generic coefficients, the support of the Hessian entries equals the second shadow exactly (no cancellation). This non-cancellation property can be certified by a formal Jacobian condition on the coefficient matrix, yielding coefficient-aware lower bounds that are strictly stronger than support-only bounds.\n\n**Test:** Formalize the connection between `WeightedSupportShadow.nonzeroQuadLeafSet_eq_shadow` and the shadow complexity lower bound. Show that for polynomials with nonzero coefficients, the lower bound applies to actual polynomial circuits (not just support circuits).\n\n**Impact:** Bridges the gap between the combinatorial support model and actual polynomial computation, making the lower bounds applicable to real arithmetic circuits.\n\n**Catalog References:**\n- `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`: `nonzeroQuadLeafSet_eq_shadow`, `coeff_pderiv_pderiv_ne_zero_iff`\n\n**Proof Strategy:** Use `coeff_pderiv_pderiv_ne_zero_iff` to show that individual Hessian coefficients are nonzero iff the ancestor coefficient is nonzero. Combine with the support circuit model to lift the lower bound from support circuits to actual arithmetic circuits under a genericity assumption.\n\n**Domain Bridges:** Connects to algebraic geometry (generic points, Zariski topology) and commutative algebra (non-vanishing of resultants).\n\n**The key insight is** that the non-cancellation property of individual second derivatives \u2014 each output coefficient is a nonzero scalar multiple of exactly one input \u2014 converts support-level bounds into coefficient-level bounds without loss.\n\n**Why now?** The non-cancellation theorem is already formally verified in `WeightedSupportShadow.lean`; the remaining work is to formalize the circuit model connection.\n\n**Lineage:** Directly extends `nonzeroQuadLeafSet_eq_shadow` to complexity conclusions.\n\n**Ambition:** \ud83d\udfe1 Solid extension with potential for \ud83d\udd34 breakthrough if it yields new bounds on standard arithmetic circuits.\n\n---",
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
    "source_exp_id": "a8f3ced3",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T03:33:47.282680+00:00"
  },
  {
    "id": "fd_1287",
    "title": "Direction 3: Efficient Lorentzian Certificate Computation",
    "description": "**Conjecture:** For an n\u00d7n PSD contraction kernel K, the Lorentzian signature defect \u03b4 of the DPP generating polynomial at the all-ones point can be computed in O(n\u00b3) time (same as eigendecomposition), and the resulting certificate has size O(n\u00b2).\n\n**Test:** Implement the Hessian computation for DPP generating polynomials at x = 1. For random PSD contractions:\n1. Compute the Hessian H_{ij} = \u2202_i\u2202_j Z_K(1) for the generating polynomial.\n2. Compute eigenvalues of H.\n3. Verify the Lorentzian condition (at most one positive eigenvalue).\n4. Measure the signature defect.\n5. Compare computation time with eigendecomposition.\n\n**Impact:** This would make Lorentzian certification practical: O(n\u00b3) is already the cost of sampling from the DPP, so certification adds no asymptotic overhead. The certificate itself is O(n\u00b2) \u2014 a matrix \u2014 which is small enough to store and transmit.\n\n**Catalog References:** `Pythagorean/CertifiedDPPSampling.lean` (LorentzianEmpiricalCert, covarianceQuadForm), `Speculative/AutoResearch/DPPLorentzian.lean` (IsDPPLorentzian, dpp_partition_function_lorentzian).\n\n**Proof Strategy:** The Hessian of det(I + diag(x)K) at x = 1 can be computed using the matrix identity: \u2202_i\u2202_j det(I + diag(x)K)|_{x=1} = det(I+K) \u00b7 [(I+K)\u207b\u00b9_{ii}(I+K)\u207b\u00b9_{jj} \u2212 (I+K)\u207b\u00b9_{ij}\u00b2]. This requires one matrix inversion and n\u00b2 entry evaluations. Formalizing this identity connects the DPP Hessian to the inverse kernel L = (I+K)\u207b\u00b9.\n\n**Domain Bridges:** Numerical linear algebra (stable matrix inversion), optimization (semidefinite programming for signature verification), machine learning (kernel learning with Lorentzian constraints).\n\n**Lineage:** Builds on LorentzianEmpiricalCert definition from this cycle. The hessianBound field of this structure would be computed by the algorithm proposed here.\n\n**Ambition:** \u2605\u2605\u2605\u2606\u2606 \u2014 Achievable with existing linear algebra infrastructure. The main formalization challenge is the matrix calculus identity connecting the generating polynomial Hessian to the inverse kernel.\n\n---",
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
    "source_exp_id": "f44ba709",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T04:11:16.628921+00:00"
  },
  {
    "id": "fd_1288",
    "title": "Direction 4: Certified Fermion Sampling in Noisy Quantum Circuits (Grand Challenge)",
    "description": "**Conjecture:** For a noisy quantum circuit preparing an n-mode fermionic Gaussian state with depolarizing noise rate \u03b5 per gate and gate depth d, the output correlation matrix K' satisfies:\n\n\u2016K \u2212 K'\u2016_max \u2264 C \u00b7 d \u00b7 \u03b5\n\nwhere K is the ideal correlation matrix. Combined with our certified DPP bounds, this gives:\n\nnegative dependence defect \u2264 6M \u00b7 C \u00b7 d \u00b7 \u03b5\n\nproviding a certified quality bound for fermion sampling under realistic noise.\n\n**Test:** Simulate noisy Gaussian fermionic circuits for n = 4, 8, 16 modes with depolarizing noise \u03b5 = 0.001 to 0.1. Compute the actual correlation matrix K' and compare \u2016K \u2212 K'\u2016_max with the predicted C\u00b7d\u00b7\u03b5 bound. Verify that the certified negative dependence defect matches empirical observation.\n\n**Impact:** This would bring certified DPP theory into quantum computation. Fermion sampling is a key primitive in quantum chemistry and materials science. Certified bounds would determine when noisy quantum hardware produces reliable fermionic correlations\u2014a critical question for quantum advantage claims.\n\n**Catalog References:** `Pythagorean/CertifiedDPPSampling.lean` (certified_approx_dpp_sound), `Speculative/AutoResearch/DPPLorentzian.lean` (DPPKernel, psd_pairInclusion_nonneg).\n\n**Proof Strategy:** Use the Lie-Trotter formula for fermionic Gaussian unitaries to show that each noisy gate perturbs the correlation matrix by at most C\u03b5 in operator norm. Accumulate errors over d gates using submultiplicativity. Convert operator norm to entry-wise norm using \u2016A\u2016_max \u2264 \u2016A\u2016_op.\n\n**Domain Bridges:** Quantum information (fermionic linear optics), condensed matter physics (free fermion ground states), quantum error correction (noise threshold theorems).\n\n**Lineage:** Extends certified_approx_dpp_sound from matrix perturbation to quantum noise models. The DPP-fermion connection (Macchi 1975) provides the bridge.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 \u2014 Grand challenge. Requires formalizing quantum channel noise models and their interaction with correlation matrices. High impact if successful: would provide the first certified quality bounds for quantum fermion sampling.\n\n---",
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
    "source_exp_id": "f44ba709",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T04:11:16.674461+00:00"
  },
  {
    "id": "fd_1328",
    "title": "Direction 4: Spectral Theory of Exchange Graphs",
    "description": "**Conjecture**: The spectral gap of the exchange graph Laplacian on $S$ (where edges connect points related by exchange steps) is bounded below by $\\Omega(\\delta_k / D)$, where $\\delta_k$ is the depth-$k$ decrement. This connects certificate depth to mixing times of random walks on exchange structures.\n\n**Test**: Compute the Laplacian spectrum of exchange graphs for small examples. Correlate the spectral gap with the observed descent speed and the certificate depth. Test whether deeper certificates consistently yield larger spectral gaps.\n\n**Impact**: Would establish certificate depth as a unified parameter controlling both deterministic descent (this paper) and randomized sampling (Markov chain mixing).\n\n**Catalog References**:\n- `Pythagorean/DepthSensitiveExchangeDescent.lean`: `depthDecrement_mono`, `depthCertificate_runtime_monotone`\n- `Catalog/Pythagorean/HigherOrderLogConcavity.lean`: `logConcaveN_mul`\n\n**Proof Strategy**: Relate the potential decrease per step ($\\delta_k$) to a Cheeger-type isoperimetric inequality on the exchange graph. Use the log-concavity structure to bound the isoperimetric constant.\n\n**Domain Bridges**: Spectral graph theory \u2194 Markov chains \u2194 discrete optimization. Connects to Anari et al.'s work on high-dimensional walks using log-concavity.\n\n**Lineage**: Extends the deterministic descent bounds to a probabilistic setting.\n\n**Ambition**: Grand challenge \u2014 spectral gaps are notoriously hard to compute and bound.\n\n**The key insight is** that the potential decrease $\\delta_k$ already measures a kind of \"expansion\" of the objective landscape, which should be related to spectral expansion of the underlying graph.\n\n**Why now?** The connection between log-concavity and spectral gaps is well-established in the continuous case (Bakry\u2013\u00c9mery theory). The formal framework for certificate depth provides the discrete structure needed to attempt the transfer.\n\n---",
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
    "source_exp_id": "4d0d5d0f",
    "consumed_by_exp_id": "b86762ea",
    "timestamp": "2026-05-27T07:12:34.010924+00:00"
  },
  {
    "id": "fd_1333",
    "title": "Direction 2: Higher-Rank Extension to GL_n(\ud835\udd3d_q)",
    "description": "**Conjecture:** For GL_n(\ud835\udd3d_q) with n \u2265 3, there exists a polynomial-time certification algorithm based on:\n(a) irreducibility of the full characteristic polynomial,\n(b) maximality of the determinant order,\n(c) escape from all Aschbacher-class maximal subgroups,\nthat certifies a positive spectral gap.\n\n**Test:** Implement the certification pipeline for GL\u2083(\ud835\udd3d\u2083) (|G| = 11232) and GL\u2083(\ud835\udd3d\u2085) (|G| = 1488000). Verify that certified pairs are expanders by numerical eigenvalue computation for GL\u2083(\ud835\udd3d\u2083).\n\n**Impact:** Would establish algorithmic spectral certification as a general paradigm for matrix groups, not limited to the 2\u00d72 case. This opens the door to certified expander construction in groups of cryptographic relevance.\n\n**The key insight is** that Aschbacher's classification of maximal subgroups of GL_n provides a finite list of \"obstruction types,\" and each can be checked by polynomial-time algebraic tests. The irreducible charpoly condition generalizes naturally (ruling out block-diagonal containment), and primitivity of the determinant extends without modification.\n\n**Why now?** The 2\u00d72 framework is now formally verified and computationally validated. The Aschbacher classification is well-understood for small n, and the algebraic tests generalize cleanly. Lean's matrix library supports arbitrary dimensions.\n\n**Catalog References:** `Pythagorean/AlgorithmicSpectralCertification.lean` (AlgebraicSeedCondition, algebraic_seed_excludes_diagonal)\n\n**Proof Strategy:** \n1. Generalize AlgebraicSeedCondition to n\u00d7n: require charpoly irreducible, det primitive, and escape from each Aschbacher class.\n2. Prove each class can be excluded by a polynomial-time test.\n3. Show that passing all tests forces generation, then invoke the maximum principle.\n\n**Domain Bridges:** Finite group theory (Aschbacher's theorem), computational algebra, cryptography (groups used in lattice-based schemes)\n\n**Lineage:** Direct extension of `algebraic_seed_excludes_diagonal` and `AlgebraicSeedCondition` to higher rank\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 (Grand challenge \u2014 requires formalizing substantial finite group theory)\n\n---",
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
    "source_exp_id": "b449612f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T07:51:41.534995+00:00"
  },
  {
    "id": "fd_1341",
    "title": "Direction 4: Phase Transitions in Tropical Stability",
    "description": "**Conjecture.** For random symmetric weight matrices drawn from a Gaussian ensemble with mean \u03bc and variance \u03c3\u00b2, the probability that tropGap(w) \u2265 0 (i.e., the exp-weight matrix is Lorentzian at all 2\u00d72 submatrices) undergoes a sharp phase transition at a critical signal-to-noise ratio:\n\nP(tropGap \u2265 0) \u2192 1 when \u03bc_off - \u03bc_diag > c\u00b7\u03c3\u00b7\u221a(log n)\nP(tropGap \u2265 0) \u2192 0 when \u03bc_off - \u03bc_diag < c\u00b7\u03c3\u00b7\u221a(log n)\n\nfor a universal constant c.\n\n**Test.** Sample 10,000 random weight matrices for each (n, \u03bc, \u03c3) with n \u2208 {5, 10, 20, 50} and plot the Lorentzian probability as a function of (\u03bc_off - \u03bc_diag)/(\u03c3\u00b7\u221a(log n)). If the curves collapse to a single transition, the conjecture is supported.\n\n**Impact.** Characterizes the \"typical\" difficulty of Lorentzian certification in random models, relevant for average-case complexity analysis and for understanding when tropical certificates are most useful.\n\n**Catalog References.** `Pythagorean/TropicalLorentzianShadows.lean` (tropical_gap_eq_uniform, exchange_slack_lipschitz)\n\n**Proof Strategy.** The tropical gap is the minimum of O(n\u00b2) Gaussian random variables (each diagonal exchange slack is a linear combination of Gaussian entries). Use extreme value theory for correlated Gaussians, specifically the Slepian-Fernique inequality, to bound the expected minimum.\n\n**Domain Bridges.** Statistical physics (phase transitions, percolation), random matrix theory (extreme eigenvalue statistics), machine learning (random feature models)\n\n**Lineage.** New direction inspired by the Lipschitz stability theorem (Theorem 3.6).\n\n**Ambition.** Solid extension \u2014 applies existing probabilistic tools to the tropical framework.\n\n---",
    "domains": [
      "Pythagorean",
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
    "source_exp_id": "7849b5c2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T07:52:13.102204+00:00"
  },
  {
    "id": "fd_1344",
    "title": "Direction 1: Bounded Quantifier Extension and Verified Hrushovski Stabilizers",
    "description": "**Conjecture:** The restricted formula language can be extended with bounded existential and universal quantifiers (\u2203 x \u2208 A, \u03c6(x) and \u2200 x \u2208 A, \u03c6(x)) while preserving the inductive \u0141o\u015b theorem. This extended language is sufficient to formalize the core stabilizer argument in Hrushovski's approximate subgroup theory.\n\n**The key insight is** that bounded quantifiers over definable sets reduce to the unbounded case via the `los_exists_bounded` theorem already proved: if the bounding set is definable, then the witness selection can be performed uniformly.\n\n**Why now?** The `los_exists_bounded` theorem (formally verified in `Catalog/Algebra/PseudofiniteTransfer.lean`) provides the existential witness mechanism. Extending the inductive framework requires adding one case to the formula induction, plus a proof that definable set membership is decidable in the germ ring (which follows from `mem_ultraSet_iff_eventually`).\n\n**Test:** Formalize the statement \"\u2203 H \u2264 G definable, [A : A \u2229 H] \u2264 C\" in the extended language and verify that \u0141o\u015b transfers it.\n\n**Impact:** This would enable formal verification of the first nontrivial step in Hrushovski's program, bridging formal logic to geometric group theory.\n\n**Catalog References:** `Catalog/Algebra/PseudofiniteTransfer.lean` (los_exists_bounded, los_restrictedFormula)\n\n**Proof Strategy:** Extend `RestrictedFormula` with a `boundedExists` constructor. The \u0141o\u015b induction case uses `los_exists_bounded` to select witnesses. The key technical challenge is ensuring well-foundedness of the induction with the additional constructor.\n\n**Domain Bridges:** Model theory \u2194 Geometric group theory\n\n**Lineage:** Direct extension of the current framework.\n\n**Ambition:** Solid extension (2\u20133 months to formalize).\n\n---",
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
    "source_exp_id": "e18f2436",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T08:27:03.925234+00:00"
  },
  {
    "id": "fd_1357",
    "title": "Direction 4: Stability of Partition Functions Under Noisy Couplings",
    "description": "**Conjecture:** For the partition function Z(J) = \u2211_\u03c3 exp(-\u03b2 \u2211_{ij} J_{ij} \u03c3_i \u03c3_j) of an Ising model with Lorentzian coupling structure, perturbations of couplings |\u0394J_{ij}| \u2264 \u03b5/(\u03b2n) preserve the log-concavity of the partition function as a polynomial in external fields.\n\n**The key insight is** that the Hessian of log Z with respect to external fields is controlled by the Lorentzian stability of the generating polynomial, and the sharp 1/n constant translates directly to coupling robustness.\n\n**Why now?** The connection between Lorentzian polynomials and partition functions is established (Anari et al., 2019), and the sharp stability constant makes the quantitative translation meaningful for physical systems.\n\n**Test:** Compute the partition function of the complete graph Ising model for n \u2208 {4, 6, 8, 10, 12} and verify that coupling perturbations of size O(\u03b5/n) preserve log-concavity of the magnetization polynomial.\n\n**Impact:** Would provide rigorous robustness guarantees for phase transition detection in noisy physical systems, connecting Lorentzian geometry to experimental physics.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` (dimension_degree_stability_law_linear), `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (strong_concavity_on_orthogonal_complement)\n\n**Proof Strategy:** Express the partition function's Hessian in terms of the coupling matrix's Hessian, apply the sharp stability theorem, and translate the coefficient perturbation bound into a coupling perturbation bound via the chain rule.\n\n**Domain Bridges:** Statistical physics (Ising models, phase transitions), probability (log-concave distributions), quantum information (quantum Boltzmann machines).\n\n**Lineage:** Extends the stability theory from abstract polynomials to physical partition functions.\n\n**Ambition:** Grand challenge \u2014 would be the first application of sharp Lorentzian stability to physics.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
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
    "source_exp_id": "ac6bc32a",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T08:27:46.927552+00:00"
  },
  {
    "id": "fd_1382",
    "title": "Direction 1: Non-Separated Extensions via Overlapping Support Theory",
    "description": "**Conjecture**: For an arbitrary nonempty vertex subset $S \\subseteq V(G)$ (not necessarily separated), the canonical kernel quotient is isomorphic to the Laplacian cokernel $\\mathbb{Z}^{|S|}/\\mathrm{Im}(L_S)$, with the isomorphism tracked through a non-trivial SNF decomposition. The off-diagonal entries of $L_S$ encode the \"interaction terms\" between overlapping harmonic generators, and the SNF basis change diagonalizes these interactions.\n\n**Test**: Enumerate all connected graphs with $n \\leq 7$ and all nonempty subsets $S$ (not just separated ones). Compute $L_S$, its SNF, and verify that the invariant factors match the canonical kernel quotient structure. Check whether the transition matrices satisfy the TracksCanonicalGens predicate. A single failure would refute the conjecture.\n\n**Impact**: This would extend the tropical-critical correspondence from independent sets to arbitrary vertex subsets, covering the full graph Jacobian rather than just its restriction to separated sets. It would make the correspondence a complete structural theorem rather than a partial one.\n\n**Catalog References**: \n- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` \u2014 `SeparatedSet`, `restrictedLapMat`, `LaplacianCokernel`\n- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` \u2014 `TropProjEquiv`, `disjoint_support_unique_up_to_tropProjEquiv`\n- `Catalog/Pythagorean/TropicalBridge/Defs.lean` \u2014 `graphLaplacian`, `firingIndependentOn`\n\n**Proof Strategy**: Decompose the restricted Laplacian $L_S = D + N$ where $D$ is the diagonal part (vertex degrees) and $N$ encodes adjacencies within $S$. Show that the SNF of $L_S$ can be computed by iteratively eliminating off-diagonal entries using unimodular row/column operations, tracking how each operation transforms the canonical generators.\n\n**Domain Bridges**: Algebraic graph theory \u2194 computational linear algebra; tropical geometry \u2194 matroid theory (the independence condition generalizes from matroids to arbitrary sets).\n\n**Lineage**: Directly extends `restrictedLap_sep_offdiag` and `cokernel_sep_cyclic` from the current work.\n\n**Ambition**: \u2605\u2605\u2605 (Solid extension \u2014 well within reach with current technology)\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "e4837868",
    "consumed_by_exp_id": "8987e0ea",
    "timestamp": "2026-05-27T12:07:55.419765+00:00"
  },
  {
    "id": "fd_1383",
    "title": "Direction 2: Metrized Graphs and Continuous Tropical Curves",
    "description": "**Conjecture**: For a metrized graph $(G, \\ell)$ with edge lengths $\\ell : E \\to \\mathbb{R}_{>0}$, the constructive SNF correspondence extends to a correspondence between the *continuous* tropical Jacobian $\\mathrm{Jac}(\\Gamma)$ (a real torus of dimension equal to the genus) and a suitable weighted Laplacian cokernel, with the invariant factors replaced by lattice invariants of the period matrix.\n\n**The key insight is** that the discrete graph Laplacian is a combinatorial shadow of the continuous Laplacian on the metrized graph, and the SNF decomposition should \"deform\" continuously as edge lengths vary.\n\n**Why now?** The catalog already has foundational definitions for graph Laplacians (`graphLaplacian` in Defs.lean) and the TropicalBridge framework handles both discrete and tropical objects. The new SNF correspondence provides the algebraic spine needed to track invariants through the continuous deformation.\n\n**Test**: Implement a numerical computation of the period matrix of a metrized graph for small examples (genus \u2264 3). Compare the lattice invariants (successive minima, Hermite normal form) with the discrete SNF invariant factors in the limit of uniform edge lengths. Check whether the two agree up to a computable correction factor.\n\n**Impact**: This would establish the tropical-critical correspondence at the level of tropical curves, connecting to the Baker-Norine Riemann-Roch theorem and the theory of divisors on metric graphs.\n\n**Catalog References**:\n- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` \u2014 `SmithNFData`, `restrictedLapMat`\n- `Catalog/Pythagorean/TropicalBridge/Stability.lean` \u2014 stability results for tropical structures\n\n**Proof Strategy**: Define a weighted Laplacian $L_\\ell$ with entries $-1/\\ell(e)$ for edges and appropriate diagonal terms. Show that as edge lengths vary, the SNF invariant factors change in a controlled way (lower semicontinuity of divisibility).\n\n**Domain Bridges**: Tropical geometry \u2194 algebraic geometry; discrete math \u2194 analysis on metric spaces.\n\n**Lineage**: Extends the discrete `restrictedLap_sep_det` to the continuous setting.\n\n**Ambition**: \u2605\u2605\u2605\u2605 (Grand challenge \u2014 requires new analytical tools)\n\n---",
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
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "e4837868",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:07:55.474050+00:00"
  },
  {
    "id": "fd_1384",
    "title": "Direction 3: Arithmetic Statistics of Graph Jacobians",
    "description": "**Conjecture**: The distribution of invariant factors of the graph Jacobian, over the ensemble of random Erd\u0151s-R\u00e9nyi graphs $G(n, p)$, converges to the Cohen-Lenstra distribution as $n \\to \\infty$ for appropriate scaling of $p$.\n\n**The key insight is** that the SNF correspondence converts the question about tropical-harmonic structure into a question about random integer matrices, where powerful tools from random matrix theory and arithmetic statistics apply.\n\n**Why now?** The catalog already contains a Cohen-Lenstra module (`Catalog/Pythagorean/CohenLenstra/`) and the new SNF correspondence provides the bridge needed to connect graph Jacobian computations to Cohen-Lenstra predictions.\n\n**Test**: Generate 10,000 random graphs $G(n, 1/2)$ for $n = 10, 20, 50, 100$. Compute the distribution of the largest invariant factor $d_1$ (the exponent of the critical group). Compare with the Cohen-Lenstra prediction $\\Pr[p^k \\mid d_1] = \\prod_{i=1}^k (1 - p^{-i})^{-1}$ for primes $p$.\n\n**Impact**: This would establish a new bridge between combinatorial probability and number-theoretic statistics, showing that the \"random\" behavior of graph invariants mirrors the \"random\" behavior of ideal class groups.\n\n**Catalog References**:\n- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` \u2014 `SmithNFData.invariantFactors`\n- `Catalog/Pythagorean/CohenLenstra/Defs.lean` \u2014 Cohen-Lenstra distributions\n\n**Proof Strategy**: Use the moment method: compute the expected number of elements of order $p^k$ in $\\mathrm{Jac}(G(n,p))$ and show convergence to the Cohen-Lenstra moments.\n\n**Domain Bridges**: Combinatorial probability \u2194 number theory; random matrix theory \u2194 tropical geometry.\n\n**Lineage**: Bridges the CohenLenstra catalog module to the TropicalBridge framework.\n\n**Ambition**: \u2605\u2605\u2605\u2605\u2605 (Paradigm-shifting \u2014 connects two major research programs)\n\n---",
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
    "source_exp_id": "e4837868",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:07:55.522801+00:00"
  },
  {
    "id": "fd_1395",
    "title": "Direction 2: Tropical Lorentzian Geometry of Tensor Network Boundary States",
    "description": "**Conjecture:** For quantum states represented by tensor networks (PEPS, MERA), the tropicalization of the measurement generating polynomial P_\u03bc recovers the tensor network geometry. Specifically, the tropical variety of P_\u03bc encodes the entanglement structure, and the tropical Lorentzian gap corresponds to the bond dimension.\n\n**Test:** Compute exact PEPS ground states for 2D systems (2\u00d73, 2\u00d74 lattices). Tropicalize P_\u03bc by replacing (sum, product) with (min, +). Compare the tropical variety structure with the tensor network graph. Check whether the tropical Lorentzian gap scales with log(bond dimension).\n\n**Impact:** This would create a direct bridge between tensor network theory \u2014 the dominant computational framework for quantum many-body systems \u2014 and tropical geometry. It could lead to new algorithms for tensor network contraction based on tropical optimization, and provide geometric obstructions to efficient tensor network representations.\n\n**Catalog References:**\n- `Catalog/Pythagorean/QuantumLorentzianBridge.lean`: `QuantumMeasurementModel`, `boundaryMass`\n- `Catalog/Pythagorean/TropicalLorentzianShadows.lean`\n- `Catalog/Pythagorean/TropicalBerggrenZeta.lean`\n- `Catalog/Tropical/` (tropical geometry infrastructure)\n\n**Proof Strategy:** Define tropical Lorentzian polynomials following Br\u00e4nd\u00e9n\u2013Huh's characterization. Show that the tropicalization of a determinantal polynomial recovers the matroid polytope. For PEPS states, relate the matroid structure to the tensor network graph via the tropicalization map. Use the formal perturbation theorems to show stability of tropical structure.\n\n**Domain Bridges:** Tensor networks \u2194 tropical geometry \u2194 Lorentzian polynomials \u2194 matroid theory \u2194 quantum entanglement\n\n**Lineage:** Combines the quantum measurement framework with tropical geometry tools already in the Catalog.\n\n**Ambition:** Grand challenge \u2014 opens a new mathematical subject\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "05e24005",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:09:20.690830+00:00"
  },
  {
    "id": "fd_1396",
    "title": "Direction 3: Hessian-Based Lorentzian Gap via MvPolynomial Infrastructure",
    "description": "**Conjecture:** The minMass/maxMass ratio used as a Lorentzian gap surrogate in the current work can be replaced by a true Hessian-based certificate: the smallest eigenvalue of the Hessian of log P_\u03bc restricted to the orthogonal complement of the all-ones direction. This refined gap provides tighter bounds on mixing time.\n\n**Test:** For TFIM ground states (n = 4,...,8), compute the full Hessian of log P_\u03bc at the all-ones point. Extract the restricted spectrum. Compare the minimum eigenvalue with the minMass/maxMass surrogate and the actual Glauber mixing time. The Hessian-based gap should be a tighter predictor.\n\n**Impact:** Replaces the crude surrogate with a geometrically natural quantity, enabling sharper perturbation bounds. The Hessian-based gap is the natural Riemannian metric on the space of Lorentzian polynomials, and computing it opens the door to gradient-based optimization over quantum measurement distributions.\n\n**Catalog References:**\n- `Catalog/Pythagorean/QuantumLorentzianBridge.lean`: `RobustLorentzianCertificate`, `minMass`\n- `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean`: `HasGappedSignature`, `QuadForm`\n- `Catalog/Pythagorean/DirectionalLogConcavity.lean`\n\n**Proof Strategy:** Define the generating polynomial using Mathlib's `MvPolynomial`. Compute its Hessian symbolically. Prove that for Lorentzian polynomials, the restricted Hessian has exactly one positive eigenvalue. Use `residual_gap_of_perturbation` from the Catalog to show perturbative stability of the Hessian gap.\n\n**Domain Bridges:** Riemannian geometry \u2194 Lorentzian polynomials \u2194 MvPolynomial algebra \u2194 spectral theory\n\n**Lineage:** Direct refinement of `RobustLorentzianCertificate` using algebraic infrastructure.\n\n**Ambition:** Solid extension \u2014 builds directly on Catalog tools\n\n---",
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
    "source_exp_id": "05e24005",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:09:20.795454+00:00"
  },
  {
    "id": "fd_1398",
    "title": "Direction 5: Lorentzian Certificates for Quantum LDPC Code Distance",
    "description": "**Conjecture:** For quantum LDPC codes with good distance (d = \u03a9(n)), the generating polynomial of the ground-space measurement distribution has Lorentzian gap \u03a9(1/poly(n)). Conversely, if the Lorentzian gap decays faster than any polynomial, the code distance is sublinear.\n\n**Test:** Construct measurement distributions for known good quantum LDPC codes (hypergraph product codes, balanced product codes) on small instances. Compute the Lorentzian gap surrogate and check whether it scales polynomially with system size. Compare with codes of poor distance (repetition code, surface code with punctures).\n\n**Impact:** Would provide an efficiently checkable classical certificate for quantum code quality. Currently, determining the distance of a quantum code is QMA-hard in general; a Lorentzian certificate would give polynomial-time checkable evidence. This would have immediate applications to quantum error correction engineering.\n\n**Catalog References:**\n- `Catalog/Pythagorean/QuantumLorentzianBridge.lean`: `minMass`, `event_prob_ratio_bound`\n- `Catalog/Pythagorean/CertificateComplexity.lean`\n- `Catalog/Pythagorean/CertificateExpanders.lean`\n\n**Proof Strategy:** Relate code distance to anti-concentration of the code ground space. Use the weight enumerator polynomial (a generating polynomial for the distance distribution) and show its Lorentzian properties. Connect to the boundary mass through the Hamming graph adjacency of the code.\n\n**Domain Bridges:** Quantum error correction \u2194 Lorentzian polynomials \u2194 coding theory \u2194 graph expansion \u2194 computational complexity\n\n**Lineage:** Applies the boundary mass and anti-concentration theorems to the quantum coding setting.\n\n**Ambition:** Solid extension with high practical impact",
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
    "source_exp_id": "05e24005",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:09:20.912162+00:00"
  },
  {
    "id": "fd_1401",
    "title": "Direction 2: Universality for General Semidirect Products",
    "description": "**Conjecture:** For a family of semidirect products $G^m \\rtimes H_m$ where $H_m$ acts on $\\{1, \\ldots, m\\}$ and satisfies a \"bounded orbit complexity\" condition, the generation threshold is determined to first order by coordinate defects: $P(G^m \\rtimes H_m) = m \\cdot P(G) + o(m)$.\n\n**Test:** Formalize the abstract semidirect pressure decomposition. Define \"bounded orbit complexity\" precisely (e.g., every orbit of $H_m$ on $k$-tuples from $\\{1, \\ldots, m\\}$ has size at most $m^{O(1)}$). Prove the universality theorem under this condition. Instantiate for:\n- Wreath products $S_k \\wr S_m$ (recovering our theorem)\n- Affine groups $\\mathbb{F}_q^n \\rtimes \\text{GL}_n(\\mathbb{F}_q)$\n- Lamplighter groups $(\\mathbb{Z}/2)^n \\rtimes \\mathbb{Z}/n$\n\n**Impact:** Would establish universality as a *general principle* for semidirect products, not a special feature of wreath products. This is the \"field-opening\" direction.\n\n**Catalog References:** `Pythagorean/WreathPhaseTransition.lean` (WreathPressureData, PressureSubcriticalInM), `Pythagorean/WreathPerturbation.lean` (WreathPressureSystem).\n\n**Proof Strategy:** Abstract the key ingredients: (1) pressure additivity for the base $G^m$, (2) index lower bounds for non-product maximal subgroups, (3) counting bounds for maximal subgroup classes. The bounded orbit complexity condition provides (2) and (3).\n\n**Domain Bridges:** Geometric group theory (orbit equivalence), ergodic theory (actions on product spaces), operator algebras (crossed products).\n\n**Lineage:** Direct generalization of the wreath product universality theorem.\n\n**Ambition:** Grand challenge \u2014 paradigm-shifting if achieved, as it would unify generation threshold theory for a vast class of groups.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "7e0c9f23",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:10:11.335247+00:00"
  },
  {
    "id": "fd_1406",
    "title": "Direction 1: Typed Higher-Order Tensor Rewriting with Binding",
    "description": "**Conjecture:** The tensor distributivity fragment extends to a simply-typed lambda calculus with tensor operations, and confluence modulo AC + \u03b2-equivalence holds for the combined system when distributivity rules are restricted to fire only at base types.\n\n**Test:** Formalize a small simply-typed tensor calculus (scalars, vectors, matrices as base types; function types for parameterized expressions). Add the 8 distributivity rules + \u03b2-reduction. Enumerate critical pairs between \u03b2-reduction and distributivity rules. Check computationally (by BFS on terms of depth \u2264 4) whether all critical peaks are joinable modulo \u03b2\u03b7-equivalence + AC.\n\n**Impact:** This would connect tensor simplification to the rich theory of higher-order rewriting (Nipkow, 1991; van Oostrom, 1994), enabling certified optimization of tensor programs written in functional languages. A negative result (non-confluence) would identify exactly which interactions between \u03b2-reduction and distributivity cause trouble, guiding the design of restricted calculi.\n\n**Catalog References:** `Catalog/Pythagorean/TensorSortedRewrite.lean` (sorted tensor language), `Catalog/Pythagorean/TensorConfluence.lean` (confluence infrastructure).\n\n**Proof Strategy:** Use the modular confluence technique (Toyama's theorem for disjoint combinations) to separate \u03b2-reduction from distributivity. The key technical challenge is the smulVec/dot interaction with \u03bb-abstraction.\n\n**Domain Bridges:** Proof theory (Curry-Howard for linear types), compiler optimization (partial evaluation of tensor kernels).\n\n**Lineage:** Extends the current 8-rule system to the next natural level of expressiveness.\n\n**Ambition:** Grand challenge \u2014 would unify term rewriting theory for algebra with lambda calculus theory.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "96bc3b32",
    "consumed_by_exp_id": "46f40501",
    "timestamp": "2026-05-27T12:50:23.737119+00:00"
  },
  {
    "id": "fd_1407",
    "title": "Direction 2: Equality Saturation and E-Graph Extraction for Tensor Normal Forms",
    "description": "**Conjecture:** The normalizeCanon algorithm is optimal in the following sense: among all representations of a tensor expression's normal form modulo AC, the one produced by normalizeCanon minimizes the number of distinct subexpressions (maximal sharing). Equivalently, the e-graph saturation of the AC-equivalence class has normalizeCanon's output as the smallest extraction.\n\n**Test:** Implement an e-graph representation of tensor expressions. Saturate with the AC axioms + scalMul-scalAdd distribution. Extract the smallest term. Compare with normalizeCanon output on 1000 randomly generated terms of size 5-20. Measure the sharing ratio (number of unique subterms / total term size).\n\n**Impact:** This bridges the formal rewriting theory to the practical equality saturation paradigm used in systems like egg (Willsey et al., 2021) and Metatheory.jl. A positive result would make normalizeCanon the extraction function for a tensor e-graph optimizer. A negative result would identify cases where sharing-aware normalization improves on syntactic normalization.\n\n**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (normalizeCanon), `Catalog/Pythagorean/EqualitySaturationExtraction.lean`.\n\n**Proof Strategy:** Define a cost model on TensorExpr (number of constructor applications). Prove normalizeCanon is locally optimal: no single AC rearrangement reduces cost. Then attempt global optimality by analyzing the structure of AC-equivalence classes.\n\n**Domain Bridges:** Compiler optimization (phase ordering), algebraic combinatorics (Catalan numbers for binary tree shapes).\n\n**Lineage:** Direct extension of normalizeCanon's completeness theorem.\n\n**Ambition:** Solid extension \u2014 connects two active research communities (rewriting theory and equality saturation).\n\n---",
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
    "source_exp_id": "96bc3b32",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:50:23.787470+00:00"
  },
  {
    "id": "fd_1408",
    "title": "Direction 3: Quantum Circuit Rewriting via Tensor Distributivity",
    "description": "**Conjecture:** The tensor distributivity rewrite system, when instantiated with matrices from SU(2)\u2297SU(2) (2-qubit gates), produces a confluent modulo AC normal form for quantum circuits on 2 qubits, where AC-equivalence corresponds to commutativity of parallel gates.\n\n**Test:** Represent 2-qubit quantum circuits as tensor expressions: gates are matrices, state vectors are vec, composition is mulVec. Enumerate all 2-qubit circuits of depth \u2264 5 using {CNOT, H, T} gate set. Apply distributivity rules (distributing controlled gates over superpositions). Check confluence by BFS.\n\n**Impact:** Quantum circuit optimization currently relies on ad hoc peephole rules. A confluent rewrite system would provide canonical circuit forms, enabling deterministic circuit comparison and certified optimization. **The key insight is** that distributivity in the tensor algebra precisely corresponds to the linearity of quantum mechanics \u2014 distributing a unitary over a superposition is the algebraic content of quantum parallelism.\n\n**Why now?** The tensor rewriting infrastructure formalized here provides the first machine-verified foundation for relating term rewriting to quantum circuit simplification. Quantum computing hardware is reaching the scale where certified optimization matters.\n\n**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean`, `Catalog/Pythagorean/TensorSortedRewrite.lean`.\n\n**Proof Strategy:** Instantiate the 3-sorted tensor calculus with \u2102\u00b2-valued vectors and 2\u00d72 complex matrices. Verify that the 8 rules remain sound. Analyze critical pairs specific to the quantum gate basis.\n\n**Domain Bridges:** Quantum computing (circuit optimization), category theory (compact closed categories for quantum protocols).\n\n**Lineage:** Novel application of the confluence theorem to a new domain.\n\n**Ambition:** Grand challenge \u2014 paradigm-shifting if it leads to a general confluence theory for quantum circuit rewriting.\n\n---",
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
    "source_exp_id": "96bc3b32",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:50:23.836779+00:00"
  },
  {
    "id": "fd_1409",
    "title": "Direction 4: Tropical Tensor Distributivity and Min-Plus Normal Forms",
    "description": "**Conjecture:** The 8 distributivity rules, interpreted over the tropical semiring (\u211d \u222a {\u221e}, min, +), remain confluent modulo AC, and the normal forms correspond to shortest-path decompositions in weighted graphs.\n\n**Test:** Implement the tropical version of the tensor rewrite system. Generate tropical tensor expressions corresponding to adjacency matrices of random weighted graphs (n = 5..20). Normalize using the tropical analog of normalizeCanon. Compare normal forms with known shortest-path decompositions.\n\n**Impact:** This would connect tensor rewriting to combinatorial optimization, providing a new algebraic perspective on shortest-path algorithms. **The key insight is** that tropical distributivity (min distributes over +) has the same algebraic form as classical distributivity, so the confluence proof should transfer.\n\n**Why now?** Tropical geometry and combinatorics have seen explosive growth. Connecting them to term rewriting theory via the tensor calculus creates a new bridge between algebra and optimization.\n\n**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean`, `Catalog/Tropical/`.\n\n**Proof Strategy:** Show that the distPotential measure is semiring-independent (it counts structural patterns, not numerical values). Transfer the confluence proof by abstracting over the coefficient semiring.\n\n**Domain Bridges:** Combinatorial optimization (shortest paths, assignment problems), algebraic statistics (tropical Grassmannians).\n\n**Lineage:** Extends the semiring-parametric aspects of the tensor calculus.\n\n**Ambition:** Solid extension with novel domain bridge.\n\n---",
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
    "source_exp_id": "96bc3b32",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:50:23.884792+00:00"
  },
  {
    "id": "fd_1410",
    "title": "Direction 5: Automated Critical Pair Analysis for Many-Sorted Rewrite Systems",
    "description": "**Conjecture:** There exists an efficient algorithm (polynomial in the number of rules \u00d7 term depth) that, given a many-sorted rewrite system, automatically enumerates all critical pairs and checks joinability modulo a specified equational theory (AC, distributivity, etc.).\n\n**Test:** Implement the algorithm for the tensor calculus. Input: the 8 rules + sort discipline. Output: complete list of critical pairs with joinability witnesses. Verify that the output matches the manual analysis in this paper. Then apply to extensions with 12, 16, 20 rules (adding trace, transpose, Kronecker product operations).\n\n**Impact:** This would automate the most labor-intensive part of confluence proofs, enabling rapid exploration of rewrite system extensions. **The key insight is** that the sort discipline dramatically prunes the space of possible overlaps \u2014 most term overlaps are sort-incorrect and can be eliminated without evaluation.\n\n**Why now?** The manual critical pair analysis in this work revealed the essential overlap between rules 7 and 8. Automating this process would have caught it immediately and would scale to the larger systems needed for practical tensor optimization.\n\n**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (manual critical pair analysis), `Catalog/Pythagorean/KnuthBendixCompletion.lean`.\n\n**Proof Strategy:** Adapt the Knuth-Bendix completion algorithm to many-sorted signatures with AC-theories. The key technical contribution would be efficient unification modulo AC in the sorted setting.\n\n**Domain Bridges:** Automated reasoning (completion procedures), programming language design (type-directed optimization).\n\n**Lineage:** Methodological extension \u2014 automating the proof technique rather than extending the mathematical content.\n\n**Ambition:** Solid extension with high practical impact.",
    "domains": [
      "Pythagorean",
      "Computation",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "96bc3b32",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:50:23.934307+00:00"
  },
  {
    "id": "fd_1421",
    "title": "Direction 1: Tropical Leaf Witnesses and Valuative Invariants",
    "description": "**Conjecture:** For a Lorentzian polynomial $p$ with coefficients in a valued field, the tropicalization of the derivative leaf $L_A$ produces a tropical polynomial whose Newton polytope encodes a \"tropical leaf witness\" \u2014 a piecewise-linear invariant of the subsystem $A$ that approximates the spectral witness in a controlled sense. Specifically, the maximum of the tropical Hessian (the tropical analogue of the mixed Hessian at ones) should bound the logarithm of the positive spectral witness from above.\n\n**Test:** Implement the tropicalization pipeline for DPP polynomials over $\\mathbb{Q}$ with $p$-adic valuations. For $n = 6, 8$, compare the tropical leaf witness (computed via Newton polytope analysis) against the real spectral witness for all subsets of size 3 and 4. A single counterexample where the tropical bound fails would refute the conjecture.\n\n**Impact:** This would create the first bridge between **tropical geometry** and **quantum entanglement witnesses**, uniting two of the most active areas of contemporary mathematics. Tropical methods are combinatorially explicit \u2014 they replace optimization over continuous spectra with finite polyhedral computations \u2014 offering a path to combinatorial certificates of multipartite entanglement.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/MultiModeLorentzianWitnesses.lean` (definitions of `derivativeLeaf`, `leafWitness`), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (DPP polynomial construction).\n\n**Proof Strategy:** Define the tropical mixed Hessian as the matrix of second tropical derivatives (min-plus convolution). Prove the bounding inequality by comparing the tropical evaluation (which corresponds to the leading-order term in the $t \\to 0$ limit of a family $p_t$ with $\\text{val}(p_t) = \\text{trop}(p)$) against the spectral radius. Use Kapranov's theorem to connect tropical roots to the asymptotic behavior of eigenvalues.\n\n**Domain Bridges:** Tropical geometry \u2194 Quantum information, Polyhedral combinatorics \u2194 Spectral theory.\n\n**Lineage:** Extends the coefficient-to-minor bridge (Theorem 6.1 in the research paper) to the tropical setting.\n\n**Ambition:** Grand challenge. If successful, this opens a fundamentally new computational paradigm for entanglement certification \u2014 replacing eigenvalue decomposition with polyhedral enumeration.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "8596d6a6",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T13:37:04.658423+00:00"
  },
  {
    "id": "fd_1422",
    "title": "Direction 2: Matroid Exchange Properties of Leaf Witnesses",
    "description": "**Conjecture:** For a Lorentzian polynomial $p$ arising from a matroid (i.e., $p$ is the basis generating polynomial of a matroid $M$), the leaf witnesses satisfy a matroidal exchange inequality: if $A$ and $B$ are subsets of the same size and $a \\in A \\setminus B$, then there exists $b \\in B \\setminus A$ such that\n$$\\text{leafWitness}(p, (A \\setminus \\{a\\}) \\cup \\{b\\}) \\geq \\min(\\text{leafWitness}(p, A), \\text{leafWitness}(p, B)).$$\n\n**The key insight is** that Lorentzian geometry, via the Hodge\u2013Riemann relations on the Chow ring of a matroid, should force the leaf witness function to respect the combinatorial exchange axiom. This would make the leaf witness a \"matroid valuation\" in the sense of Dress and Wenzel.\n\n**Why now?** The connection between Lorentzian polynomials and matroids was established by Br\u00e4nd\u00e9n\u2013Huh [BH20] and deepened by Adiprasito\u2013Huh\u2013Katz [AHK18]. The formal infrastructure for derivative leaves now makes it possible to state and test matroidal properties of the witness function computationally.\n\n**Test:** Generate all matroids on ground sets of size $\\leq 8$ (there are finitely many up to isomorphism). For each matroid, compute the basis generating polynomial, evaluate leaf witnesses for all subsets of each size, and verify the exchange inequality exhaustively.\n\n**Impact:** This would establish leaf witnesses as combinatorial invariants of matroids, not just spectral quantities. It would open connections to matroid valuation theory, tropical linear algebra, and the theory of valuated matroids.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/MultiModeLorentzianWitnesses.lean` (`leafWitness`, `derivativeLeaf`), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (`IsDPPLorentzian`).\n\n**Proof Strategy:** For representable matroids $M$ represented by a matrix $V$, the kernel $K = V^T V$ produces a DPP polynomial. Use the Cauchy\u2013Binet formula to express leaf coefficients in terms of minors of $V$, then apply the Grassmann\u2013Pl\u00fccker relations to establish the exchange inequality. For general matroids, reduce to the representable case via the cryptomorphism between Lorentzian polynomials and matroids.\n\n**Domain Bridges:** Matroid theory \u2194 Lorentzian geometry, Combinatorial optimization \u2194 Spectral analysis.\n\n**Lineage:** Direct extension of the principal minor bridge (`principalMinor_pair`, `cauchy_schwarz_entries`).\n\n**Ambition:** Solid extension. The exchange inequality for degree-2 witnesses is likely provable with existing tools; the general case would be a significant advance.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "8596d6a6",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T13:37:04.718863+00:00"
  },
  {
    "id": "fd_1444",
    "title": "Direction 2: Newton Ratios as Algebraic Order Parameters for Quantum Phases",
    "description": "**Conjecture:** For free-fermion systems at half-filling, the Newton ratio profile \u03c1\u2096 = e\u2096\u00b2/(e\u2096\u208b\u2081e\u2096\u208a\u2081) undergoes a qualitative change at quantum phase transitions: in gapless phases, max|log \u03c1\u2096| grows logarithmically with subsystem size; in gapped phases, it saturates to a finite value determined by the gap.\n\n**Test:** Compute Newton ratio profiles for the SSH model (topological insulator) across the topological phase transition. If log \u03c1\u2096 shows a discontinuous derivative at the critical point, the conjecture is supported. If it varies smoothly, the conjecture needs refinement.\n\n**Impact:** Would establish Newton ratios as a new class of algebraic order parameters for quantum phases, complementing traditional diagnostics like entanglement entropy and string order parameters.\n\n**Catalog References:** `Pythagorean/NewtonEntropyHierarchy.lean`: `esymm_newton_inequality`, `newtonDefect_nonneg`, `NewtonRatioProfile`.\n\n**Proof Strategy:** Combine asymptotic analysis of Toeplitz determinants (for correlation matrices of free fermions) with the Fisher\u2013Hartwig conjecture to extract the large-m behavior of e\u2096 and hence \u03c1\u2096.\n\n**Domain Bridges:** Lorentzian geometry (log-concavity) \u2192 condensed matter physics (phase transitions) \u2192 random matrix theory (Toeplitz asymptotics).\n\n**Lineage:** Extends the Newton ratio profile concept introduced here; builds on the computational evidence in `demo.py`.\n\n**Ambition:** Grand challenge \u2014 requires connecting formal algebraic structures to asymptotic physics.\n\n*The key insight is* that Newton's inequality is not just a constraint but a diagnostic: how *tightly* the inequality is satisfied carries physical information about the quantum phase.\n\n*Why now?* The formal definition of `NewtonRatioProfile` and the proof of `esymm_newton_inequality` provide the mathematical foundation; the computational demos show the phase sensitivity.\n\n---",
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
    "source_exp_id": "ec2aa218",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T15:24:27.753806+00:00"
  },
  {
    "id": "fd_1445",
    "title": "Direction 3: Tropical Geometry of Entanglement Spectra",
    "description": "**Conjecture:** In the large-m limit, the Newton ratio profile of area-law free-fermion states converges to a piecewise-linear function whose breakpoints are determined by the spectral gap structure. This piecewise-linear limit is the *tropical* analogue of the log-concave sequence, living in the tropical semiring (max-plus algebra).\n\n**Test:** Compute the tropicalization of the generating polynomial E(t) = \u220f(1+\u03bb\u1d62t) for free-fermion spectra with varying gap parameters. If the tropical curve's Newton polygon has edges whose slopes correspond to the dominant eigenvalue groups, the conjecture is supported.\n\n**Impact:** Would connect entanglement theory to tropical geometry, enabling the use of tropical intersection theory to study many-body quantum states.\n\n**Catalog References:** `Pythagorean/NewtonEntropyHierarchy.lean`: `esymmCoeff`, `esymm_newton_inequality`; `Catalog/Bridges/LorentzianNewton.lean`: `newton_inequality`.\n\n**Proof Strategy:** Study log(e\u2096)/k as m \u2192 \u221e using saddle-point analysis. The tropical limit corresponds to the Legendre transform of the rate function for the empirical eigenvalue distribution.\n\n**Domain Bridges:** Tropical geometry \u2192 Lorentzian polynomial theory \u2192 quantum information \u2192 statistical mechanics.\n\n**Lineage:** Extends the Newton hierarchy from finite-dimensional algebra to asymptotic geometry.\n\n**Ambition:** Grand challenge \u2014 paradigm-shifting if successful.\n\n*The key insight is* that the log-concavity of the e\u2096 sequence is the \"classical\" shadow of a tropical convexity structure, and that the tropical limit should be analytically tractable.\n\n*Why now?* The formal log-concavity infrastructure (Newton's inequality) is now available, and tropical methods have recently been connected to Lorentzian polynomials by Br\u00e4nd\u00e9n and Huh.\n\n---",
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
    "source_exp_id": "ec2aa218",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T15:24:35.519993+00:00"
  },
  {
    "id": "fd_1446",
    "title": "Direction 4: Compressed Sensing of Many-Body Entanglement",
    "description": "**Conjecture:** For 1D gapped free-fermion chains with subsystem size m, the entanglement entropy S can be reconstructed to within error \u03b5 from O(log(m/\u03b5)) elementary symmetric polynomials, rather than all m eigenvalues.\n\n**Test:** For systems with L = 200, L_A = 50-100, measure reconstruction error as a function of K (number of e\u2096 values used). If error decays exponentially in K for gapped systems, the conjecture is supported.\n\n**Impact:** Would demonstrate that entanglement has a natural *compressed sensing* structure: sparse in the symmetric polynomial basis, enabling sublinear measurement complexity.\n\n**Catalog References:** `Pythagorean/NewtonEntropyHierarchy.lean`: `quadratic_entropy_lower_bound`, `certifiedEntropyApprox_correct`, `powerSum_determined_by_esymm_two`.\n\n**Proof Strategy:** Use the exponential decay of correlation functions in gapped systems to show that e\u2096 decays rapidly for large k, implying that the polynomial entropy surrogate converges rapidly.\n\n**Domain Bridges:** Compressed sensing \u2192 approximation theory \u2192 quantum information \u2192 numerical linear algebra.\n\n**Lineage:** Direct extension of the certified entropy algorithm; builds on the error analysis.\n\n**Ambition:** Solid extension with high practical impact.\n\n*The key insight is* that the area law \u2014 which says entanglement is \"low-rank\" \u2014 should manifest as rapid decay of the elementary symmetric polynomial sequence, enabling compressed representation.\n\n*Why now?* The certified algorithm (`certifiedEntropyApprox_correct`) provides the foundation; extending it to higher-order surrogates requires only the Newton\u2013Girard recursion (Direction 1).\n\n---",
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "ec2aa218",
    "consumed_by_exp_id": "eedf1ad8",
    "timestamp": "2026-05-27T15:24:35.839293+00:00"
  },
  {
    "id": "fd_1447",
    "title": "Direction 5: Newton Hierarchy for Interacting Fermions via Determinantal Approximation",
    "description": "**Conjecture:** For weakly interacting fermion systems (e.g., Hubbard model at weak coupling), the Newton ratio profile of the exact entanglement spectrum is close to that of the best-fit free-fermion (Gaussian) approximation, with corrections controlled by the interaction strength.\n\n**Test:** Compute exact entanglement spectra for the Hubbard model at half-filling (L=8-12 sites, exact diagonalization) and compare Newton ratio profiles with those of the corresponding non-interacting model. If the ratio profiles converge as interaction strength \u2192 0, the conjecture is supported.\n\n**Impact:** Would extend the algebraic compression framework beyond free fermions to interacting systems, vastly expanding its applicability.\n\n**Catalog References:** `Pythagorean/NewtonEntropyHierarchy.lean`: `NewtonRatioProfile`, `AreaLawCompatible`, `esymm_newton_inequality`.\n\n**Proof Strategy:** Use perturbation theory in the interaction strength U. The entanglement spectrum \u03bb\u1d62(U) = \u03bb\u1d62(0) + U\u00b7\u03b4\u03bb\u1d62 + O(U\u00b2), and the Newton defects \u0394\u2096(U) = \u0394\u2096(0) + U\u00b7\u03b4\u0394\u2096 + O(U\u00b2). Bound |\u03b4\u0394\u2096| using Lipschitz continuity of the elementary symmetric polynomials.\n\n**Domain Bridges:** Many-body quantum physics \u2192 algebraic combinatorics \u2192 perturbation theory.\n\n**Lineage:** Extends the free-fermion framework to interacting systems; uses the stability of Newton defects.\n\n**Ambition:** Solid extension with transformative potential for computational quantum physics.\n\n*The key insight is* that Newton's inequality is robust under perturbation: if the exact spectrum is close to a free-fermion spectrum, then the Newton defects are close to their free-fermion values, and the algebraic compression still applies approximately.\n\n*Why now?* The formal proof of Newton's inequality and the computational infrastructure for Newton ratio profiles are now available; the Hubbard model is computationally accessible for small systems.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ec2aa218",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T15:24:36.058680+00:00"
  },
  {
    "id": "fd_1449",
    "title": "Direction 2: N\u00e9ron Component Groups via Tropical Jacobians",
    "description": "**Conjecture (Grand Challenge):** For a semistable curve X over a discretely valued field K with dual graph \u0393, Baker's specialization lemma gives a surjection sp: J(X)(K) \u2192 J(\u0393). The canonical kernel generators of \u0393 provide *explicit coordinates* on the component group \u03a6_J of the N\u00e9ron model of J(X), and the Smith normal form of the canonical kernel lattice computes |\u03a6_J| = det(L_red).\n\n**Test:** For hyperelliptic curves of genus 2 with known N\u00e9ron models (tabulated in the literature), compute the tropical Jacobian of the dual graph and compare the invariant factors with the known component group structure. A mismatch would indicate either a gap in the specialization map or an error in the dual graph computation.\n\n**Impact:** This would make the N\u00e9ron component group \u2014 a central object in arithmetic geometry \u2014 *computationally accessible* through elementary linear algebra on the dual graph. Currently, computing \u03a6_J requires sophisticated p-adic methods.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (weighted Laplacian kernel, PSD)\n- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelDefs.lean` (RestrictedLaplacianImage)\n\n**Proof Strategy:** Use Baker's specialization lemma [BN07] combined with Raynaud's theorem on N\u00e9ron models. The key step is showing that the canonical kernel lattice generators map to generators of the period lattice of J(X)(K) under specialization.\n\n**Domain Bridges:** Tropical geometry \u2194 Arithmetic geometry \u2194 p-adic analysis\n\n**Lineage:** Extends the canonical kernel correspondence to arithmetic applications.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 (Grand challenge \u2014 connects to deep results in arithmetic geometry)\n\n---",
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
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "c6eef6ce",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T15:25:01.447437+00:00"
  },
  {
    "id": "fd_1450",
    "title": "Direction 3: Gaussian Free Field Lattice Periodicity",
    "description": "**Conjecture:** The canonical kernel lattice \u039b_S determines the periodicity structure of the discrete Gaussian free field (GFF) on the metric graph \u0393. Specifically, the partition function of the GFF on \u0393 with periodic boundary conditions factorizes as Z(\u0393) = (2\u03c0)^{g/2} \u00b7 (det L_red)^{-1/2}, where g is the genus and L_red is the reduced Laplacian.\n\n**Test:** Compute the GFF partition function numerically for cycle graphs C_n with various edge lengths, and compare with the determinant formula. Also compute the GFF covariance matrix (= L^+) and verify it equals the effective resistance matrix.\n\n**Impact:** This bridges tropical geometry to statistical mechanics, providing a geometric interpretation of GFF observables. The canonical kernel lattice would acquire physical meaning as the \"configuration space\" of the discrete toroidal model.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (weightedLaplacian_psd, effective resistance)\n- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (harmonicKernel)\n\n**Proof Strategy:** The GFF on a graph with Laplacian L has density \u221d exp(\u2212(1/2) x^T L x). By our Theorem 6, x^T L x = \u03a3 w_e (x_i \u2212 x_j)\u00b2 \u2265 0, so the measure is well-defined on \u211d^n/{constants}. The partition function is the Gaussian integral, giving det(L_red)^{-1/2}.\n\n**Domain Bridges:** Statistical mechanics \u2194 Tropical geometry \u2194 Spectral graph theory\n\n**Lineage:** Builds directly on `weightedLaplacian_psd` from Theorems.lean.\n\n**Ambition:** \u2605\u2605\u2605 (Solid extension \u2014 the connection is well-known informally but not formalized)\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Tropical",
      "Physics",
      "Cryptography",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "c6eef6ce",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T15:25:01.509711+00:00"
  },
  {
    "id": "fd_1451",
    "title": "Direction 4: Continuous-Time Chip-Firing and Conformal Field Theory",
    "description": "**Conjecture (Grand Challenge):** The chip-firing process on a metric graph \u0393 admits a continuous-time stochastic extension where chips perform Brownian motion along edges. The stationary measure of this process is the GFF restricted to integer-valued configurations, and the recurrent configurations form the tropical Jacobian J(\u0393).\n\n**Test:** Simulate continuous-time chip-firing on cycle graphs C_n and theta graphs \u0398(a,b,c). Measure the empirical distribution of recurrent configurations and compare with the uniform measure on J(\u0393). Deviations from uniformity would disprove the conjecture.\n\n**Impact:** This would establish a direct bridge between the combinatorics of chip-firing (discrete mathematics), the geometry of tropical curves (algebraic geometry), and conformal field theory (physics). The tropical Jacobian would acquire a dynamical interpretation.\n\n**Catalog References:**\n- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (all theorems)\n- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (FiringEquivalentOn)\n\n**Proof Strategy:** Define the continuous chip-firing process as a Markov chain on Div^0(\u0393)/Prin(\u0393) \u2245 J(\u0393). Show that the transition kernel is doubly stochastic (using symmetry of the Laplacian), implying uniformity of the stationary measure.\n\n**Domain Bridges:** Stochastic processes \u2194 Tropical geometry \u2194 Conformal field theory\n\n**Lineage:** Extends `FiringEquivalentOn` and `RestrictedLaplacianImage` to the stochastic setting.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 (Grand challenge \u2014 requires new ideas at the interface of probability and geometry)\n\n---",
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
    "source_exp_id": "c6eef6ce",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T15:25:01.724433+00:00"
  },
  {
    "id": "fd_1454",
    "title": "Direction 1: Character Sum Bounds for S_n via Moment Kernel Decomposition",
    "description": "**Conjecture:** For fixed k \u2265 1, the expected k-th excess moment over random generating pairs (\u03c3, \u03c4) in S_n satisfies\n\n$$\\mathbb{E}_{\\sigma,\\tau}[\\delta_{2k}(\\sigma, \\tau)] = O(1/n)$$\n\nwhere $\\delta_{2k} = \\text{momentKernel}(\\sigma, \\tau, 2k) - \\mu_{F_2}^{(2k)}(e)$.\n\n**Test:** Compute the average excess moment for random pairs in S_n for n = 5, ..., 12 and verify the 1/n decay rate by regression. The formalized conjugation invariance theorem (`closedWordCount_conj_invariant` in `Pythagorean/CayleyExpander/MomentMethod.lean`) reduces the average to a sum over conjugacy classes, making the computation tractable.\n\n**The key insight is** that the moment kernel decomposes over irreducible representations of S_n, and the dominant correction comes from the standard (n-1)-dimensional representation, which contributes O(1/n) by character orthogonality. The conjugation invariance theorem already certified in our framework is the first step toward formalizing this decomposition.\n\n**Why now?** The trace identity and conjugation invariance are the two prerequisites for the character decomposition, and both are now machine-verified. The character theory of S_n is partially available in Mathlib, making the formal bridge feasible within the next cycle.\n\n**Impact:** A formal proof of the 1/n decay would be the first rigorous moment bound for random Cayley graphs on S_n, directly advancing the Random Cayley Expander Conjecture.\n\n**Catalog References:** `Pythagorean/CayleyExpander/MomentMethod.lean` (closedWordCount_conj_invariant, momentKernel_conj_invariant), `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (trace_pow_eq_closedWordCount, spectral_moment_eq_return_prob).\n\n**Proof Strategy:** Decompose the moment kernel using the Peter-Weyl theorem for finite groups. The conjugation invariance reduces the problem to character sums. Bound each irreducible contribution using known character bounds for S_n (e.g., Roichman's bounds).\n\n**Domain Bridges:** Representation theory of S_n \u2192 asymptotic combinatorics \u2192 probability theory.\n\n**Lineage:** Builds directly on Theorems 1, 3, and 6 of the current work.\n\n**Ambition:** Grand challenge \u2014 would resolve the conjecture for fixed moments.\n\n---",
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
    "source_exp_id": "be453c44",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T16:03:48.605918+00:00"
  },
  {
    "id": "fd_1455",
    "title": "Direction 2: Free Probability and Asymptotic Freeness of Random Permutations",
    "description": "**Conjecture:** The empirical spectral distribution of the normalized adjacency operator of Cay(S_n, {\u03c3, \u03c3\u207b\u00b9, \u03c4, \u03c4\u207b\u00b9}) converges in moments to the Kesten-McKay distribution (the spectral measure of the 4-regular tree) as n \u2192 \u221e, for random generating pairs.\n\n**Test:** For n = 5, ..., 10, compute moments up to order 8 and compare with the Kesten-McKay moments. The backtrack-free counting theorem (`card_backtrackFree_words` in `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean`) gives the tree-like baseline; compare with empirical data.\n\n**The key insight is** that the convergence to the Kesten-McKay law is equivalent to asymptotic freeness of the generators \u03c3 and \u03c4 in the sense of Voiculescu's free probability theory. The moment method provides the combinatorial interface: each moment is a sum over words, and freeness means that only non-crossing partition contributions survive in the limit.\n\n**Why now?** The moment kernel framework and backtrack-free counting are the exact combinatorial objects that appear in free probability. The bridge between walk counting on groups and non-crossing partitions is a well-understood analogy that can now be formalized.\n\n**Impact:** Establishing asymptotic freeness for random permutations would unify the Random Cayley Expander Conjecture with the broader program of random matrix universality. It would show that random Cayley graphs on S_n exhibit the same spectral behavior as random regular graphs\u2014a deep structural insight.\n\n**Catalog References:** `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (card_backtrackFree_words, trace_pow_eq_closedWordCount), `Pythagorean/CayleyExpander/MomentMethod.lean` (momentKernel_le_one).\n\n**Proof Strategy:** Formalize the Kesten-McKay distribution and its moments. Show that the relation-driven corrections to the moment kernel vanish by bounding the number of non-tree-like closed walks that involve \"deep\" relations in S_n.\n\n**Domain Bridges:** Free probability \u2192 random matrix theory \u2192 quantum information.\n\n**Lineage:** Extends the backtrack-free counting theorem toward asymptotic spectral analysis.\n\n**Ambition:** Grand challenge \u2014 paradigm-shifting connection between discrete group theory and continuous random matrix theory.\n\n---",
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
    "source_exp_id": "be453c44",
    "consumed_by_exp_id": "085c03f4",
    "timestamp": "2026-05-27T16:03:48.671488+00:00"
  },
  {
    "id": "fd_1456",
    "title": "Direction 3: Quantum Channel Mixing via Cayley Moment Bounds",
    "description": "**Conjecture:** The purity of the k-fold quantum channel $\\Phi_{\\sigma,\\tau}^k$ (the completely positive map induced by the random walk step on S_n) decays as $\\text{tr}(\\Phi^k(\\rho)^2) \\leq 1/n! + C_k \\cdot (1 - \\lambda)^k$ where $\\lambda$ is the spectral gap, and the moment kernel directly controls the purity decay.\n\n**Test:** Implement the quantum channel $\\Phi$ for small S_n (n = 3, 4) as a superoperator on density matrices, and verify that purity decay matches the moment kernel predictions from `spectral_moment_eq_return_prob`.\n\n**The key insight is** that the spectral moment = return probability theorem (`spectral_moment_eq_return_prob` in our formalization) is literally a purity calculation for the associated quantum channel. The normalized adjacency operator is a bistochastic quantum channel, and tr(\u0100^m) computes the m-th moment of its spectrum, which controls the rate at which quantum states approach the maximally mixed state.\n\n**Why now?** Quantum computing demands explicit mixing time bounds for random circuits. Our certified moment framework provides the exact mathematical objects needed. The bridge from group walks to quantum channels is a functor that can be formalized.\n\n**Impact:** Certified mixing bounds for quantum channels on symmetric groups would have immediate applications in quantum algorithm design, random circuit sampling, and quantum error correction.\n\n**Catalog References:** `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (spectral_moment_eq_return_prob, momentKernel_le_one, free_group_moment_two_lower).\n\n**Proof Strategy:** Formalize the quantum channel associated to a Cayley graph walk. Show that purity = (1/|G|) \u00b7 tr(\u0100^{2k}) and apply the moment-kernel bounds.\n\n**Domain Bridges:** Quantum information \u2192 spectral graph theory \u2192 representation theory.\n\n**Lineage:** Direct application of Theorem 6 (cross-domain bridge).\n\n**Ambition:** Solid extension \u2014 immediate applications with existing infrastructure.\n\n---",
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
    "source_exp_id": "be453c44",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T16:03:48.729875+00:00"
  },
  {
    "id": "fd_1479",
    "title": "Closing the Single-Power Gap",
    "description": "Conjecture: For every fixed `k \u2265 0`, there exists `c_k > 0` such that for infinitely many `d`, some depth-`k` exchange family in dimension `d` has worst-case descent length at least `c_k \u00b7 d^{d-k}` (matching the upper bound exactly, not just `d^{d-k-1}`).\n\nTest: Construct increasingly refined adversarial families for `d = 4, ..., 20` with fixed `k = 0, 1, 2`. Compute worst-case descent lengths and fit the growth rate. If `T(d,k) / d^{d-k}` converges to a positive constant, the conjecture holds. If `T(d,k) / d^{d-k-1}` converges instead, the lower bound is tight and the upper bound can be improved.\n\nImpact: Resolves the central open question of the current theory. If the upper bound is tight, certificate depth is the exact complexity exponent. If not, there exists a finer invariant \u2014 a \"certificate depth 2.0\" \u2014 waiting to be discovered.",
    "domains": [
      "Pythagorean",
      "Computation",
      "MachineLearning"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "147eb4db",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T16:40:30.004231+00:00"
  },
  {
    "id": "fd_1480",
    "title": "Certificate Depth as a Matroid Invariant",
    "description": "Conjecture: For matroid base exchange families, the certificate depth `k` is determined by the matroid's Tutte polynomial evaluated at specific points. Specifically, `k = d - 1` for Boolean matroids and `k = 1` for uniform matroids of fixed rank.\n\nTest: Compute certificate depth for explicit matroid families: uniform matroids `U(r, n)`, graphic matroids of complete graphs, and transversal matroids. Check whether `k` correlates with known matroid invariants (connectivity, girth, characteristic polynomial roots).\n\nImpact: Would establish certificate depth as a matroid-theoretic quantity, connecting the exchange descent complexity theory to the rich algebraic theory of matroids (Lorentzian polynomials, Hodge theory for matroids).",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "147eb4db",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T16:40:30.062802+00:00"
  },
  {
    "id": "fd_1481",
    "title": "Average-Case Descent Bounds",
    "description": "Conjecture: For random exchange families on `[0, M]^d` with i.i.d. log-concave objective components, the expected descent length is `\u0398(d^{(d-k)/2})` \u2014 the square root of the worst case.\n\nTest: Generate 1000 random exchange families for each `(d, k)` with `d \u2208 {4, ..., 10}`. Run exchange descent from random start points. Fit the expected step count to `d^\u03b1` and estimate `\u03b1` as a function of `d - k`.\n\nImpact: Would provide practical guidance: if average-case is much better than worst-case, practitioners can rely on descent methods even when certificate depth is low.",
    "domains": [
      "Pythagorean",
      "Computation"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "147eb4db",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T16:40:30.122941+00:00"
  },
  {
    "id": "fd_1482",
    "title": "Circuit Depth Lower Bounds from Layer Profiles",
    "description": "Conjecture: The exchange descent problem with depth-`k` certificate in dimension `d` requires Boolean circuits of depth at least `(d - k - 1) \u00b7 log d` to solve.\n\nTest: Encode small instances (d = 4, 5, 6) as Boolean satisfiability problems and measure the depth of the smallest Boolean circuit that computes the optimal descent step. Compare with the layer profile prediction.\n\nImpact: Would connect exchange descent complexity to the central open questions of computational complexity theory (circuit depth lower bounds, the P vs NC question).",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "147eb4db",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T16:40:30.181006+00:00"
  },
  {
    "id": "fd_1483",
    "title": "Energy Landscape Metastability",
    "description": "Conjecture: For spin systems on lattices with `d` components and interaction structure of \"depth\" `k`, the metastable relaxation time is at least `d^{d-k-1}` steps of any local dynamics.\n\nTest: Simulate Ising/Potts models on small lattices with controlled interaction structure. Measure relaxation times from metastable states. Fit to the predicted `d^{d-k-1}` scaling.\n\nImpact: Would provide a rigorous framework for predicting metastability in physical systems from structural properties of the interaction Hamiltonian.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Physics",
      "Cryptography"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "147eb4db",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T16:40:30.251712+00:00"
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
    "id": "fd_1317",
    "title": "Prime-Rigidity Threshold for Integral Persistence Reconstruction",
    "description": "Conjecture: There exists a universal constant c in (0,1) such that for any two finite filtered chain complexes C,D over Z with boundary matrices of total bit-size N, if their reductions mod p have isomorphic persistence modules for every prime p <= c log N and their rational persistence modules over Q are isomorphic, then C and D are filtered chain-homotopy equivalent over Z up to adding contractible summands. Moreover, for every c' < c there exist counterexample families of size N where agreement for all p <= c' log N does not force equivalence. Test: Exhaustively enumerate or randomly generate small filtered complexes, compare integral equivalence classes against agreement of mod-p and rational persistence data up to increasing prime cutoffs, and search for the sharp transition scale in log N; refutation is a counterexample above the proposed threshold, confirmation is sustained recovery with matching lower-bound constructions. Impact: This would turn primewise persistence into a finite arithmetic fingerprint, giving a concrete reconstruction principle for integer filtered topology and a new bridge between SNF complexity, local-global principles, and computable invariants.",
    "domains": [
      "Topological Data Analysis",
      "Algebraic Topology",
      "Arithmetic Combinatorics",
      "Computational Algebra"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T05:59:01.680262+00:00"
  },
  {
    "id": "fd_1484",
    "title": "Direction 1: Strict Sub-d Integrality Gap Without Capping",
    "description": "**Conjecture**: For every d \u2265 3 and K \u2265 1, there exists \u03b5(d,K) > 0 and n\u2080(d,K) such that every d-uniform hypergraph H on n \u2265 n\u2080 vertices with \u0394\u2082(H) \u2264 K satisfies \u03c4(H) \u2264 (d \u2212 \u03b5(d,K)) \u00b7 \u03c4*(H). The predicted form is \u03b5(d,K) = c_d/(K+1) where c_d \u2248 1/(2d).\n\n**Test**: Generate random d-uniform hypergraphs conditioned on \u0394\u2082 \u2264 K for d = 3,4,5 and K = 1,2,5,10 with n = 50,100,500,1000. Compute exact \u03c4 (via ILP) and \u03c4* (via LP). Plot the ratio \u03c4/\u03c4* as a function of n for each (d,K). The conjecture predicts convergence to a value \u2264 d \u2212 c_d/(K+1). A disproof would show the ratio clustering near d for some bounded K.\n\n**Impact**: This would be the first integrality gap bound where the approximation factor depends on local overlap geometry rather than just uniformity. It would immediately impact:\n- Approximation algorithms for structured set cover instances\n- Competitive analysis of online covering with bounded overlap\n- Lower bounds in proof complexity for covering formulations\n\n**Catalog References**: `Catalog/Pythagorean/QuantitativeCodegreeGap.lean` (Theorem `integrality_gap_strict_of_capped`), `Catalog/Pythagorean/HypergraphTransversal.lean` (classical bounds).\n\n**Proof Strategy**: Use layered threshold rounding: set S\u2081 = {v : x(v) \u2265 1/(d-1)}, then bound the repair cost of uncovered edges using the pair codegree bound. The key lemma is that under \u0394\u2082 \u2264 K, the graph of \"uncovered edge\" adjacencies has bounded chromatic number, allowing a greedy repair with O(K) additional vertices per uncovered edge class.\n\n**Domain Bridges**: Approximation algorithms, polyhedral combinatorics, proof complexity.\n\n**Lineage**: Extends `integrality_gap_improved_capped` by removing the capping assumption.\n\n**Ambition**: Grand challenge \u2014 would open a new subfield of \"overlap-sensitive approximation.\"\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "dbcfb2f4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T17:24:45.367460+00:00"
  },
  {
    "id": "fd_1485",
    "title": "Direction 2: Algorithmic Overlap-Adaptive Rounding",
    "description": "**Conjecture**: There exists a polynomial-time rounding algorithm that, given a d-uniform hypergraph H with \u0394\u2082(H) \u2264 K and an optimal fractional transversal x*, outputs an integer transversal of size at most (d \u2212 \u03a9(1/K)) \u00b7 \u03c4*(H) + O(K). This algorithm does NOT require knowing K in advance \u2014 it adaptively estimates the overlap profile from the LP solution.\n\n**Test**: Implement the adaptive algorithm. Compare its output size to: (a) classical threshold rounding, (b) randomized rounding, (c) the LP relaxation value, on random instances with K = 1,2,5,10 and d = 3,4,5. The conjecture predicts consistent improvement over (a) and (b) for small K.\n\n**Impact**: First approximation algorithm with overlap-adaptive guarantees. Would influence:\n- Column generation methods for large-scale set cover\n- Online scheduling with bounded resource sharing\n- Network design with diversity constraints\n\n**Catalog References**: `Catalog/Pythagorean/QuantitativeCodegreeGap.lean` (energy bound, threshold results), `Catalog/Pythagorean/WeightedHypergraphTransversal.lean` (weighted rounding).\n\n**Proof Strategy**: Use the pair-overlap energy E(x) as a \"diagnostic\" \u2014 compute E(x*)/||x*||\u2081\u00b2 to estimate the effective overlap parameter. If this ratio is small, use an aggressive threshold (1/(d-1)); if large, fall back to 1/d. The energy bound guarantees that the effective overlap is at most K, even if K is unknown.\n\n**Domain Bridges**: Algorithm design, operations research, online optimization.\n\n**Lineage**: Builds on `pairOverlapEnergy_le_of_pairCodegreeBounded` as the diagnostic tool.\n\n**Ambition**: Solid extension \u2014 directly implementable and testable.\n\n**The key insight is** that the pair-overlap energy serves as a computable proxy for the unobserved codegree parameter, enabling adaptive algorithm design without structural assumptions.\n\n**Why now?** The formal verification of the energy bound provides a rigorous foundation for algorithm design that was previously available only as heuristic intuition.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "dbcfb2f4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T17:24:45.431739+00:00"
  },
  {
    "id": "fd_1486",
    "title": "Direction 3: Statistical Physics of Covering Polytopes",
    "description": "**Conjecture**: The partition function Z(\u03b2) = \u03a3_{S transversal} exp(\u2212\u03b2|S|) of the covering system undergoes a phase transition at \u03b2_c = ln(d\u22121) + O(1/(K+1)) when \u0394\u2082(H) \u2264 K. Below \u03b2_c, the Gibbs measure concentrates on transversals of size \u2248 \u03c4*\u00b7(d \u2212 \u03a9(1/K)); above \u03b2_c, it concentrates on the minimum transversal.\n\n**Test**: For random 3-uniform hypergraphs with \u0394\u2082 \u2264 K, estimate Z(\u03b2) via Monte Carlo simulation (Metropolis algorithm on the transversal indicator). Plot the free energy f(\u03b2) = \u2212(1/n)\u00b7ln Z(\u03b2) and identify the phase transition. Compare the critical \u03b2_c to the predicted formula.\n\n**Impact**: Would establish a rigorous connection between:\n- LP duality for covering (algebraic structure)\n- Gibbs measures on covering configurations (probabilistic structure)\n- Phase transitions in random combinatorial optimization\n\n**Catalog References**: `Catalog/Pythagorean/QuantitativeCodegreeGap.lean` (free energy coercivity), `Catalog/Pythagorean/FracTransversalConcentration.lean` (concentration bounds).\n\n**Proof Strategy**: Use the coercivity theorem as a warm-start: F(x) \u2265 0 implies the free energy is bounded below. Then develop a cluster expansion around the fractional optimum, using the energy bound to control higher-order terms. The pair codegree bound ensures the cluster expansion converges (weak coupling regime).\n\n**Domain Bridges**: Statistical physics, random constraint satisfaction, mean-field theory.\n\n**Lineage**: Extends `cover_free_energy_coercive` to the full Gibbs measure framework.\n\n**Ambition**: Grand challenge \u2014 would create a new interface between optimization and physics.\n\n**The key insight is** that the coercivity theorem is the zeroth-order term of a cluster expansion, and the energy bound controls the convergence radius.\n\n**Why now?** Formal verification of the free energy bound enables rigorous cluster expansion analysis that would otherwise be heuristic.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "dbcfb2f4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T17:24:45.553550+00:00"
  },
  {
    "id": "fd_1487",
    "title": "Direction 4: Error-Correcting Codes from Bounded-Codegree Coverings",
    "description": "**Conjecture**: For d \u2265 3 and K \u2265 1, the minimum transversal of a d-uniform hypergraph with \u0394\u2082 \u2264 K defines a binary code with minimum distance \u2265 d/(K+1) and rate \u2265 1 \u2212 (d\u2212\u03b5)\u00b7\u03c4*/n, where \u03b5 = \u03b5(d,K) > 0. In particular, bounded codegree covering systems yield codes that exceed the Gilbert-Varshamov bound when K is sufficiently small relative to d.\n\n**Test**: Construct explicit d-uniform hypergraphs with \u0394\u2082 \u2264 K (e.g., from Steiner systems or randomized constructions). Compute the minimum transversal and treat it as a codeword. Measure the minimum Hamming distance between transversals and compare to the GV bound.\n\n**Impact**: Would provide:\n- New constructions of LDPC-like codes from hypergraph covering\n- Connections between coding-theoretic distance and combinatorial overlap\n- A covering-based framework for code design\n\n**Catalog References**: `Catalog/Pythagorean/QuantitativeCodegreeGap.lean` (codegree bounds), `Catalog/Pythagorean/HypergraphTransversal.lean` (transversal theory).\n\n**Proof Strategy**: The minimum distance between two distinct transversals S\u2081, S\u2082 is |S\u2081 \u0394 S\u2082|. Under bounded codegree, the symmetric difference is large because the edges \"force\" transversals to spread out. Use the energy bound to show that concentrated transversals have high overlap energy, contradicting optimality.\n\n**Domain Bridges**: Coding theory, information theory, combinatorial design.\n\n**Lineage**: Uses `pairCodegree_le_one_of_pairwiseDisjoint` as the K=1 base case (Steiner systems).\n\n**Ambition**: Solid extension \u2014 connects two well-established fields through a new lens.\n\n**The key insight is** that bounded pair codegree forces transversals to be \"spread out,\" which is precisely the property needed for good error-correcting codes.\n\n**Why now?** The formal connection between codegree and energy opens a quantitative bridge to coding theory that was not previously available.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Bridges",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "dbcfb2f4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T17:24:45.619179+00:00"
  },
  {
    "id": "fd_1488",
    "title": "Direction 5: Sparse Biological Interaction Networks",
    "description": "**Conjecture**: In protein-protein interaction networks modeled as d-uniform hypergraphs (where edges represent protein complexes), the pair codegree \u0394\u2082 is bounded by O(log n) where n is the number of proteins. Consequently, the drug target selection problem (minimum hitting set of essential complexes) admits an approximation ratio of d \u2212 \u03a9(1/log n), significantly better than the worst-case d factor.\n\n**Test**: Analyze real PPI databases (BioGRID, STRING) for pair codegree distribution. For the top 1000 protein complexes, compute \u0394\u2082 and compare to log n. Then solve the hitting set LP, apply threshold rounding, and compare to the ILP solution. The conjecture predicts a gap ratio significantly below d.\n\n**Impact**: Would provide:\n- Rigorous approximation guarantees for drug target identification\n- Structural characterization of biological network overlap\n- Principled algorithms for essential gene prediction\n\n**Catalog References**: `Catalog/Pythagorean/QuantitativeCodegreeGap.lean` (all main theorems).\n\n**Proof Strategy**: Biological networks are known to have bounded degree distributions (scale-free with bounded average degree). Under degree bounds, the pair codegree is bounded by the product of individual degrees divided by the number of edges \u2014 which gives O(log n) in typical scale-free networks.\n\n**Domain Bridges**: Computational biology, network science, drug discovery.\n\n**Lineage**: Applies `integrality_gap_improved_capped` to biological network instances.\n\n**Ambition**: Solid extension \u2014 directly applicable to existing datasets.\n\n**The key insight is** that biological networks have naturally bounded pair codegree due to evolutionary pressure against redundant interactions, making them ideal candidates for overlap-sensitive optimization.\n\n**Why now?** Large-scale PPI databases are now available, and the formal guarantees from this work provide the first rigorous framework for overlap-adaptive analysis of biological covering problems.",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.8999999999999999,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "dbcfb2f4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T17:24:45.684727+00:00"
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
    "id": "fd_1318",
    "title": "Mod-p Spectral Fingerprints Determine Expansion Profile of Arithmetic Simplicial",
    "description": "Conjecture: There exists a family of bounded-degree arithmetic simplicial complexes X_N (for example Ramanujan-type quotients of Bruhat\u2013Tits buildings) such that the multiset of persistent homology barcodes of the mod-p Laplacian filtrations, taken over all primes p up to C log N, determines the real Laplacian spectral gap up to o(1) error as N -> infinity. Test: Construct explicit X_N, compute barcode statistics from mod-p combinatorial Laplacians for growing N and primes p <= C log N, and regress/predict the real spectral gap; the conjecture is supported if prediction error vanishes asymptotically and refuted if asymptotically different spectral gaps produce indistinguishable prime barcode data. Impact: This would create a new arithmetic-topological route to estimating expansion and mixing in high-dimensional complexes using only finite-field computations, linking expander theory, arithmetic geometry, and persistent homology.",
    "domains": [
      "Arithmetic Topology",
      "Spectral Graph Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T05:59:32.898444+00:00"
  },
  {
    "id": "fd_1337",
    "title": "Torsion Resonance Law for Modular Form Congruence Graphs",
    "description": "Conjecture: For each normalized cuspidal Hecke eigenform f of fixed weight and level, there is a functorial construction of a finite filtered chain complex C_p(f) over Z from the mod-p Hecke orbit graph of f such that the birth scale distribution of p-torsion in H_*(C_p(f)) undergoes a sharp change exactly at primes p where f is congruent mod p to a distinct eigenform. Test: Compute C_p(f) for databases of modular forms and compare torsion barcode statistics against independently known congruence primes; confirmation is a statistically significant predictive correspondence, while systematic absence of correlation refutes the conjecture. Impact: This would create a topological detector for hidden congruences in automorphic forms, linking arithmetic deformation theory, Hecke algebras, and persistent topology in a new computational framework.",
    "domains": [
      "Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T07:51:52.030067+00:00"
  },
  {
    "id": "fd_1343",
    "title": "Derived Zeta Reconstruction from Primewise Persistent Torsion",
    "description": "Conjecture: There exists a functorial assignment from every smooth projective variety X over Q to a filtered integral chain complex C(X) such that, for all but finitely many good primes p, the p-primary persistence barcode of C(X) at filtration scale p determines the multiset of Frobenius eigenvalue p-adic valuations on each \u00e9tale cohomology group H^i_et(X_{Qbar}, Q_l), and hence determines the local zeta factor Z(X/F_p,t) up to finitely many explicitly bounded ambiguities. Test: Compute the construction for benchmark families (elliptic curves, K3 surfaces, hypersurfaces with known point counts) and check whether independently computed primewise barcodes reconstruct the correct local zeta factors for a density-1 set of primes; a single infinite family with systematically non-reconstructible zeta data refutes the conjecture. Impact: This would create a new topological-computational interface for arithmetic geometry, turning persistence invariants into a probe of Frobenius spectra and potentially enabling data-driven recovery of motivic and L-function information from combinatorial models.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T07:52:22.669578+00:00"
  },
  {
    "id": "fd_1393",
    "title": "Prime-Cover Descent for Integral Persistence Reconstruction",
    "description": "Conjecture: There exists a universal constant B such that for every finite filtered chain complex C over Z with boundary matrices of entry size at most M and total rank r, the integral filtered chain homotopy type of C is uniquely determined by the collection of its reductions modulo p together with their persistence barcodes for all primes p <= B log(Mr). Equivalently, no two non-equivalent such complexes can have identical mod-p persistence data for every prime up to that bound. Test: Exhaustively generate non-isomorphic small filtered complexes with bounded M,r, compute mod-p persistence for all primes up to c log(Mr), and search for collisions; confirmation is absence of collisions up to growing bounds and recovery algorithms succeeding from only small-prime data, while any explicit collision refutes the conjecture. Impact: This would turn infinitely many prime probes into a finite-information reconstruction principle, giving a practical arithmetic tomography scheme for integral persistence and a new quantitative bridge between Chinese-remainder phenomena, homological algebra, and topological data analysis.",
    "domains": [
      "Algebraic Topology",
      "Computational Topology",
      "Number Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:08:51.433226+00:00"
  },
  {
    "id": "fd_1399",
    "title": "Persistent Prime-Mixing Threshold for Integral Chain Complexes",
    "description": "Conjecture: There exists a universal constant c > 0 and an explicit family of finite filtered chain complexes C_N over Z such that for every set of primes P with |P \u2229 [1, c log N]| = o(log N), the collection of mod-p persistence barcodes {Bar(C_N; F_p) : p in P} does not determine the integral persistence module of C_N, but the full set of barcodes for all primes p <= c log N does determine it up to filtered chain homotopy. Test: Construct candidate families C_N with controlled torsion spread across many small primes, then algorithmically compare reconstruction success from truncated prime sets versus all primes up to c log N; confirmation requires a sharp threshold phenomenon in recoverability, refutation occurs if either substantially fewer primes always suffice or even all primes up to c log N fail generically. Impact: This would reveal a genuine information-theoretic phase transition in how arithmetic data is distributed across primes, giving the first quantitative law for when local mod-p topological observations assemble into global integral structure.",
    "domains": [
      "Algebraic Topology",
      "Arithmetic Combinatorics"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:09:29.272030+00:00"
  },
  {
    "id": "fd_1405",
    "title": "Prime-Independence Threshold for Reconstructing Integral Persistent Homotopy Typ",
    "description": "Conjecture: There exists a dimension-dependent function N(d) such that for any finite simply connected filtered CW complexes X and Y of dimension at most d, if for every prime p <= N(d) the mod-p persistent cohomology Steenrod-module data of X and Y are isomorphic (including persistence maps and cup products), then X and Y have the same integral persistent homotopy type up to filtered rational equivalence and identical p-primary Postnikov invariants for all primes p. Test: Compute or construct pairs of filtered complexes in low dimensions with matching mod-p persistent Steenrod data for all small primes; confirmation requires that no counterexample exists below the predicted threshold and that reconstruction algorithms recover the same Postnikov tower, while any explicit pair with matching data but differing integral persistent homotopy refutes the conjecture. Impact: This would create a finite-prime blueprint for recovering deep integral homotopy information from computable persistent invariants, linking TDA, unstable homotopy theory, and arithmetic localization in a genuinely new way.",
    "domains": [
      "Algebraic Topology",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T12:10:22.420690+00:00"
  },
  {
    "id": "fd_1429",
    "title": "Chromatic Stabilization of Primewise Persistent Homology",
    "description": "Conjecture: For every finite filtered CW complex X of dimension d, there exists a finite chromatic height h = h(X) such that for all primes p outside a density-0 exceptional set, the p-primary persistent homology barcode of X is functorially determined by the first h pages of the Adams spectral sequence of X localized at p; equivalently, beyond bounded chromatic height no new barcode intervals appear for almost all primes. Test: Compute, for explicit families of spaces/filtered complexes with known unstable and stable homotopy data (Moore spaces, lens spaces, configuration spaces, moment-angle complexes), the p-primary persistence barcodes across many primes and compare them to invariants predicted from truncated Adams spectral sequence data. The conjecture is refuted by a family where infinitely many chromatic heights contribute genuinely new barcode intervals for a positive-density set of primes; it is supported if barcode complexity uniformly stabilizes after bounded height and reconstruction succeeds for almost all p. Impact: This would create a bridge between persistent homology and chromatic homotopy theory, suggesting that primewise topological data admits a finite-height compression principle and enabling new algorithms for arithmetic-topological inference from spectral data.",
    "domains": [
      "Algebraic Topology",
      "Homotopy Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T14:10:58.987954+00:00"
  },
  {
    "id": "fd_1435",
    "title": "Derived Equivalence Creates Persistent Torsion Isospectrality Without Zeta Agree",
    "description": "Conjecture: There exist smooth projective varieties X and Y over Q that are derived equivalent but not isomorphic, together with a functorial construction of filtered integral chain complexes C_p(X), C_p(Y) from good reductions mod p, such that for a density-1 set of primes p the primewise persistent torsion barcodes of C_p(X) and C_p(Y) agree in every homological degree, while the Hasse\u2013Weil zeta functions of X_p and Y_p differ for infinitely many p. Test: Construct candidate derived-equivalent pairs (for example Fourier\u2013Mukai partners of K3 or abelian surfaces), define a concrete filtered complex from Frobenius/point-count data, and compute whether barcode agreement persists across many good primes while zeta disagreement occurs infinitely often or with positive density. Refutation occurs if no such pair exists for any natural functorial construction, or if barcode agreement forces zeta agreement for density-1 primes. Impact: This would show persistent torsion captures a genuinely derived-categorical arithmetic shadow distinct from classical zeta data, creating a new invariant between cohomological and motivic information.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T14:11:32.035461+00:00"
  },
  {
    "id": "fd_1441",
    "title": "Arithmetic Monodromy from Persistent Homology of p-adic Newton Iteration Graphs",
    "description": "Conjecture: Let f(x) \u2208 Z[x] be a squarefree polynomial of degree d \u2265 3 with Galois group G over Q. For each good prime p, build the directed functional graph \u0393_p(f) on F_p by x \u21a6 x - f(x)/f'(x) whenever f'(x) \u2260 0, with singular points treated as isolated/marked vertices, and form a filtration by in-degree or preimage-depth. Then there exists a functorially defined persistence statistic S_p(f) such that the limiting distribution of S_p(f) over primes p determines the cycle type distribution of Frobenius in G; in particular, non-isomorphic transitive Galois groups of the same degree yield different limiting persistence laws for a density-1 set of squarefree polynomials. Test: Compute S_p(f) for large prime samples across families with known Galois groups (e.g. S_d, A_d, D_n, cyclic, solvable examples) and check whether empirical persistence distributions separate the groups with statistically significant accuracy; refute by exhibiting two such families with indistinguishable limiting laws despite distinct Frobenius cycle statistics. Impact: This would create a new topological probe of arithmetic monodromy, linking dynamical systems over finite fields, persistent homology, and inverse Galois heuristics, and could yield data-driven invariants for detecting hidden Galois structure from modular dynamics.",
    "domains": [
      "Arithmetic Dynamics",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T14:12:05.827873+00:00"
  },
  {
    "id": "fd_1442",
    "title": "Primewise Persistent Homology Detects Exceptional Galois Image in Elliptic Curve",
    "description": "Conjecture: Let E/Q be a non-CM elliptic curve. For each prime l and each good prime p \\neq l, form the filtered graph G_{p,l} whose vertices are the points of E(\\overline{\\mathbb{F}}_p)[l^k] for 1 \\le k \\le K, with edges encoding multiplication-by-l and Frobenius action, and let B_{p,l} be any functorial persistent homology invariant of this tower stable under graph isomorphism. Then there exists a finite set S(E) of exceptional primes l such that for all l \\notin S(E), the distribution of B_{p,l} over p converges to a universal law depending only on l and K, while for l \\in S(E) it deviates by a statistically detectable amount bounded away from 0. Test: Compute B_{p,l} for many p and l on elliptic curves with known surjective and exceptional mod-l Galois images; confirm whether the barcode/statistical profile separates exceptional l from generic l uniformly across curves. Refute by exhibiting families where known exceptional image primes are not detectable or generic primes systematically mimic the exceptional profile. Impact: This would create a new topological detector for hidden Galois-image obstructions, linking arithmetic statistics, division-field representations, and TDA in a way that could suggest new invariants for open image phenomena.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T14:12:46.483587+00:00"
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
  }
];
