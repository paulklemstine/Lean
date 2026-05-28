

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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "33261812",
    "consumed_by_exp_id": "fcd58d33",
    "timestamp": "2026-05-24T23:12:21.848642+00:00"
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
    "consumed_by_exp_id": "35af0f61",
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
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "abb48be4",
    "consumed_by_exp_id": "",
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
    "id": "fd_1513",
    "title": "Direction 3: Certified Optimization via Exchange Constants",
    "description": "**Conjecture.** For polynomial optimization problems on M-convex sets (e.g., maximizing a linear objective over matroid bases), the exchange constant K of the basis-generating polynomial provides a certified approximation ratio: any exchange-local optimum is within a factor of K of the global optimum.\n\n**Test.** Formalize the connection between `ValuatedExchange` and the certified optimization framework in `MConvexOptimization.lean`. Prove that if ValuatedExchange(p, K) holds and p encodes a weighted matroid, then the greedy algorithm achieves a K-approximation. Test computationally on random matroid intersection instances.\n\n**Impact.** This would provide the first polynomial-time certified optimization algorithm for weighted matroid problems with explicit quality guarantees derived from the coefficient geometry of the generating polynomial.\n\n**Catalog References.** `Catalog/Pythagorean/MConvexOptimization.lean` (certified optimization on M-convex sets), `Catalog/Pythagorean/ValuatedMConvexDifferentiation.lean`.\n\n**Proof Strategy.** Use the exchange local-min-implies-global-min theorem from `MConvexOptimization.lean` combined with the coefficient inequality from `ValuatedExchange` to bound the cost gap at each exchange step.\n\n**Domain Bridges.** Discrete convex analysis \u2194 Combinatorial optimization \u2194 Algorithm design.\n\n**Lineage.** Extends `exchange_local_min_implies_global_min` from `MConvexOptimization.lean`.\n\n**Ambition.** Solid extension \u2014 algorithmic consequence of the coefficient inequality.\n\n---",
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
    "source_exp_id": "78306251",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T19:12:47.048620+00:00"
  },
  {
    "id": "fd_1594",
    "title": "Direction 1: Shadow Inequalities for Lorentzian Polynomials",
    "description": "**Conjecture:** If $f$ is a Lorentzian polynomial (in the sense of Br\u00e4nd\u00e9n\u2013Huh), then its support $S = \\text{supp}(f)$ satisfies the shadow log-concavity inequality $|\\text{Sh}_k(S)|^2 \\geq |\\text{Sh}_{k-1}(S)| \\cdot |\\text{Sh}_{k+1}(S)|$ for all admissible $k$.\n\n**Test:** Implement the Lorentzian polynomial verification algorithm (checking that all second-order partial derivatives have alternating sign Hessians) for polynomials with supports drawn from matroid bases, products of simplices, and Schur polynomial supports up to $n = 8$ variables and degree $\\leq 10$. Verify shadow log-concavity for each confirmed Lorentzian polynomial.\n\n**The key insight is** that Lorentzian polynomials already satisfy coefficient-level log-concavity, and the shadow profile is a coarser invariant (support-level rather than coefficient-level), so the conjecture amounts to showing that log-concavity \"descends\" from coefficients to support sizes \u2014 a phenomenon that should follow from the coefficient transport formula if the descending factorial scalars are sufficiently well-behaved.\n\n**Why now?** The coefficient transport formula (Theorem 3.1) provides the exact algebraic bridge between support-level and coefficient-level properties. Previous work on Lorentzian polynomials lacked this explicit multi-index transport law.\n\n**Impact:** Would establish a new, elementary route to combinatorial log-concavity that bypasses Hodge theory.\n\n**Catalog References:** `Pythagorean/IteratedShadowGeometry.lean` (coeff_iteratedPDeriv, descFactorial_prod_pos), `Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (coeff_pderiv_pderiv).\n\n**Proof Strategy:** Use the coefficient transport formula to relate shadow sizes to sums of products of descending factorials weighted by coefficients. Apply the Cauchy\u2013Schwarz inequality or FKG inequality on the resulting sums.\n\n**Domain Bridges:** Lorentzian polynomial theory, algebraic combinatorics, Hodge theory.\n\n**Lineage:** Extends Br\u00e4nd\u00e9n\u2013Huh (2020) from coefficient log-concavity to support-level log-concavity.\n\n**Ambition:** Grand challenge \u2014 would unify support geometry with Lorentzian algebra.\n\n---",
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "f43533d0",
    "consumed_by_exp_id": "f7968947",
    "timestamp": "2026-05-28T01:19:07.597078+00:00"
  },
  {
    "id": "fd_1595",
    "title": "Direction 2: Tropical Differential Entropy via Newton Shadows",
    "description": "**Conjecture:** For a polynomial $f$ with Newton polytope $P$, define the **tropical shadow entropy** as $H_k = \\log |\\text{Sh}_k(\\text{supp}(f))|$. Then $H_k$ is a concave function of $k$, and the derivative $\\Delta H_k = H_{k+1} - H_k$ measures the information loss per differentiation step in the tropical sense.\n\n**Test:** Compute $H_k$ for random sparse polynomials with supports drawn from lattice points of known polytopes (simplices, cubes, cross-polytopes, Birkhoff polytopes) up to dimension 6. Plot $H_k$ against $k$ and test concavity. Compare $\\Delta H_k$ with the surface-to-volume ratio of the level-$k$ section of $P$.\n\n**The key insight is** that the shadow operator is the discrete analogue of the Minkowski subtraction of a ball from a convex body, and entropy concavity would be the discrete analogue of the Brunn\u2013Minkowski inequality.\n\n**Why now?** The semigroup law (Theorem 3.5) provides the formal foundation for treating the shadow as a flow, which is the prerequisite for defining rates of change and entropy-like quantities.\n\n**Impact:** Would create a new information-theoretic perspective on Newton polytopes, with applications to coding theory and optimization.\n\n**Catalog References:** `Pythagorean/IteratedShadowGeometry.lean` (kthShadow_add, shadow_profile).\n\n**Proof Strategy:** Use the semigroup law to express $H_{a+b}$ in terms of $H_a$ and $H_b$. Apply lattice-point counting estimates (Ehrhart theory) to bound shadow sizes in terms of polytope volumes.\n\n**Domain Bridges:** Tropical geometry, information theory, convex geometry.\n\n**Lineage:** New direction inspired by the semigroup structure.\n\n**Ambition:** Solid extension \u2014 connects two established areas through a new invariant.\n\n---",
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
    "source_exp_id": "f43533d0",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T01:19:07.666079+00:00"
  },
  {
    "id": "fd_1685",
    "title": "Direction 4: Entropy Production Under Differentiation",
    "description": "**Conjecture:** Define the **shadow entropy** of a family $S$ as $H(S) = \\log |\\mathrm{Sh}_1(S)| - \\log |S|$. For polynomials computed by circuits of size $s$:\n\n$$H(\\mathrm{supp}(f)) \\le O(\\log s)$$\n\nwhile for the permanent:\n\n$$H(\\mathrm{PermSupp}(m)) \\ge \\Omega(\\log m)$$\n\n**Test:** Compute $H$ for all circuits of size $\\le 8$ in $n \\le 4$ variables. Verify the logarithmic bound. Compare with the permanent's entropy for $m = 2, \\ldots, 6$.\n\n**Impact:** An information-theoretic formulation would connect the shadow-gap program to communication complexity, information complexity, and the entropy method in combinatorics.\n\n**Catalog References:**\n- `Pythagorean/CircuitLowerBounds/KruskalKatonaSupport.lean`: `card_oneShadow_le_mul_card`\n\n**Proof Strategy:** The key insight is that the bound $|\\mathrm{Sh}_1(S)| \\le n \\cdot |S|$ gives $H(S) \\le \\log n$ universally. For circuits, the multiplicative structure should constrain $H$ more tightly. Each add gate increases $|S|$ additively; each mul gate increases it multiplicatively. The entropy $H$ should decompose along the circuit DAG, giving a bound in terms of circuit depth and width.\n\n**Why now?** The general bound $|\\mathrm{Sh}_1| \\le n|S|$ is proved. The circuit bound theorem provides the recursive structure needed for an entropy decomposition. The connection to statistical physics (support as microcanonical ensemble, shadow as accessible states) provides physical intuition.\n\n**Domain Bridges:** Algebraic complexity \u2192 information theory \u2192 statistical physics.\n\n**Lineage:** Builds on entropy methods in combinatorics (Shearer's lemma, entropy compression).\n\n**Ambition:** Solid extension with speculative connections to physics.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "d74bda34",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T06:14:19.083806+00:00"
  },
  {
    "id": "fd_1687",
    "title": "Direction 1: Full Probabilistic Universality via Lindeberg Comparison",
    "description": "**Conjecture:** For any centered, variance-one, independent sub-Gaussian entry model with parameter \u03c3, there exists a centering sequence a_n and scale b_n ~ \u221a(log n) such that\n```\nP(tropMargin(W_n) \u2265 0) = \u03a6((\u03bc - a_n) / b_n) + o(1)\n```\nwhere \u03a6 is a universal profile function independent of the entry distribution.\n\n**Test:** Generate n\u00d7n matrices with Gaussian, Rademacher, uniform, and exponential entries for n = 10, 20, 50, 100. After centering and \u221a(log n) scaling, fit the empirical P(tropMargin \u2265 0) curves. Measure the Kolmogorov-Smirnov distance between all sub-Gaussian pairs. The conjecture is falsified if the KS distance remains bounded away from zero as n \u2192 \u221e.\n\n**Impact:** Would establish the first formal universality theorem for a non-spectral random matrix observable, opening a new universality class.\n\n**Catalog References:** `Catalog/Pythagorean/TropicalPhaseTransition.lean` (tropMargin_lipschitz, tropMargin_lower_bound_signal_noise), `Pythagorean/TropicalUniversality.lean` (telescoping_bound, tropMargin_entrywise_replacement_bound)\n\n**Proof Strategy:** Use the telescoping replacement bound to replace entries one at a time from distribution \u03bc to distribution \u03bd. Each replacement step contributes at most 4|entry change| to the margin difference. By Lindeberg's method, the cumulative effect is controlled by the third-moment matching condition. The key technical challenge is bounding the remainder term using the sub-Gaussian tail control from SubGaussianEntryModel.\n\n**Domain Bridges:** Probability theory (Lindeberg method), extreme-value theory (Gumbel convergence)\n\n**Lineage:** Extends tropMargin_telescoping_bound and tropMargin_entrywise_replacement_bound\n\n**Ambition:** Grand challenge \u2014 would require novel probabilistic machinery adapted to the tropical setting\n\n---",
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
    "source_exp_id": "69370675",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T06:15:00.271482+00:00"
  },
  {
    "id": "fd_1689",
    "title": "Direction 3: Tropical Margin Dynamics Under Matrix Flows",
    "description": "**Conjecture:** Under the Dyson Brownian motion W(t) = W(0) + \u221at \u00b7 G where G is i.i.d. Gaussian, the tropical margin satisfies:\n```\ntropMargin(W(t)) = tropMargin(W(0)) + O(\u221a(t \u00b7 log n))\n```\nand the hitting time \u03c4\u2080 = inf{t : tropMargin(W(t)) = 0} concentrates around t* = (tropMargin(W(0)))\u00b2 / (C\u00b2 \u00b7 log n).\n\n**Test:** Simulate the Dyson dynamics for 5\u00d75 matrices with various initial conditions. Track tropMargin(W(t)) and measure \u03c4\u2080. Plot \u03c4\u2080 vs. initial margin squared / log(n). The conjecture predicts linear scaling.\n\n**Impact:** Would create a dynamical theory of tropical phase transitions, analogous to the Dyson dynamics for eigenvalues but for the combinatorial observable.\n\n**Catalog References:** `Pythagorean/TropicalUniversality.lean` (tropMargin_lipschitz, tropMargin_signalGap_perturbation)\n\n**Proof Strategy:** Use the Lipschitz bound to control tropMargin increments. The Gaussian increment at each step has \u2016\u03b4W\u2016\u221e ~ \u221a(\u03b4t \u00b7 log n). By the perturbation theorem, |\u03b4(tropMargin)| \u2264 4\u221a(\u03b4t \u00b7 log n). This gives a bounded-increment martingale, and optional stopping yields the hitting time concentration.\n\n**Domain Bridges:** Stochastic calculus (martingale methods), statistical mechanics (relaxation times), dynamical systems\n\n**Lineage:** Builds on tropMargin_lipschitz and the Lipschitz martingale framework\n\n**Ambition:** Grand challenge \u2014 requires fusion of dynamical and combinatorial methods\n\n---",
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
    "source_exp_id": "69370675",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T06:15:00.424598+00:00"
  },
  {
    "id": "fd_1787",
    "title": "Direction 4: Shadow-Based Circuit Lower Bounds for the Permanent",
    "description": "**Conjecture:** The shadow lower bound |Sh\u2082(supp(Perm_n))| grows at least as fast as 2^{n/2}, and the non-cancellation certificate holds for the permanent polynomial Perm_n for all n \u2265 3. Consequently, any arithmetic circuit computing Perm_n has size at least 2^{n/2} / poly(n), improving the best known lower bounds.\n\n**Test:** Compute |Sh\u2082(supp(Perm_n))| for n = 3, 4, 5, 6, 7 and extrapolate the growth rate. Verify the certificate for Perm_n (the support is the set of permutation matrices with coefficients \u00b11; the shadow closure question reduces to a combinatorial property of permutation matrices).\n\n**Impact:** An exponential circuit lower bound for the permanent would resolve a major open problem in computational complexity (Valiant's conjecture, VP \u2260 VNP). Even a new lower bound (improving the current \u03a9(n\u00b2/2) of Shpilka\u2013Wigderson) would be a significant advance.\n\n**Catalog References:**\n- `Algebra/AlgebraicCircuitComplexity.lean` \u2014 circuit complexity definitions\n- `Bridges/Catalog/Speculative/AutoResearch/NonCancellationCertificate.lean` \u2014 certificate and shadow lower bound\n\n**Proof Strategy:** Analyze the combinatorics of permutation supports under the shadow map. The key question is whether |Sh\u2082(Perm_n)| grows exponentially. This is a purely combinatorial question about permutations, independent of the algebraic framework.\n\n**Domain Bridges:** Combinatorics (permutation statistics), computational complexity (VP vs VNP), representation theory (symmetric group).\n\n**Lineage:** Grand-challenge application of the entire framework to the central open problem in algebraic complexity.\n\n**Ambition:** Grand challenge \u2014 this is equivalent to a major open problem. Even partial progress (new lower bounds, tight shadow computation) would be highly significant.\n\n**The key insight is** that the non-cancellation certificate reduces the permanent lower bound problem to a purely combinatorial question about the shadow growth of permutation supports, separating the algebraic difficulty from the combinatorial difficulty.\n\n**Why now?** The certificate framework is now formalized and verified. The combinatorial question about permutation shadows is well-defined and computationally tractable for small n, enabling systematic experimental investigation.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ad17ca4a",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T11:04:38.767855+00:00"
  },
  {
    "id": "fd_1790",
    "title": "Direction 1: Full Stabilizer Descent Formalization",
    "description": "**Conjecture:** The stabilizer of a proper approximate subgroup has strictly smaller pseudofinite dimension. Formally: if $A$ is a definable $K$-approximate subgroup in $\\prod_{\\mathcal{U}} G_i$ with $0 < \\dim(A) < 1$, then $\\dim(\\text{Stab}(A)) \\leq \\dim(A) - c(K)$ for an explicit constant $c(K) > 0$ depending only on the doubling constant.\n\n**Test:** Compute stabilizer chains in Z/pZ for primes p = 101, 1009, 10007 with initial sets of various doubling constants. Verify that the dimension drop per step is bounded below by a function of K alone.\n\n**Impact:** Completes the core engine of the Breuillard-Green-Tao structure theorem for approximate groups. Would be the first machine-verified proof of stabilizer descent.\n\n**Catalog References:** `Catalog/Pythagorean/BoundedPseudofiniteTransfer.lean` (\u0141o\u015b theorem, `cosetCover_compose`), `Pythagorean/PseudofiniteDimension.lean` (`cosetCover_card_bound`, `normalizedLogCard_coset_bound`)\n\n**Proof Strategy:** Use the formalized coset cover bound plus the Ruzsa triangle inequality (to be formalized) to show that if $gA \\subseteq A^2$ for all $g \\in \\text{Stab}(A)$, then $\\text{Stab}(A)$ is covered by $K^2$ left cosets of a subgroup $H$ with $\\dim(H) < \\dim(A)$. The coset cover bound then gives $\\dim(\\text{Stab}(A)) < \\dim(A)$.\n\n**Domain Bridges:** Model theory \u2192 combinatorics (Ruzsa calculus) \u2192 group theory (subgroup structure)\n\n**Lineage:** Builds directly on the coset cover cardinality bound and log-cardinality coset bound.\n\n**Ambition:** Grand challenge \u2014 requires formalizing the Ruzsa triangle inequality and connecting it to the ultraproduct framework.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Bridges",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "951d1d02",
    "consumed_by_exp_id": "b43a1b40",
    "timestamp": "2026-05-28T11:39:09.140621+00:00"
  },
  {
    "id": "fd_1800",
    "title": "Direction 1: Sharp Principal-Series Operator Norm via Kloosterman Sums",
    "description": "**Conjecture**: For every certified pair (g, h) in GL\u2082(\ud835\udd3d_q) with g Singer-like, and every principal series representation \u03c0(\u03c7\u2081, \u03c7\u2082) with \u03c7\u2081 \u2260 \u03c7\u2082, the operator norm of M_\u03c0(S) satisfies\n$$\\|M_{\\pi(\\chi_1, \\chi_2)}(S)\\| \\leq 1 - \\frac{1}{2q} + O(q^{-3/2})$$\nwith the leading-order term coming from Kloosterman sums evaluated at the eigenvalues of g in \ud835\udd3d_{q\u00b2}.\n\n**Test**: For q \u2208 {11, 13, 17, 19, 23, 29, 31}, directly compute the operator norm of M_\u03c0(S) on the (q\u22121)-dimensional induced representation space for all principal series \u03c0. Compare with the predicted asymptotic 1 \u2212 1/(2q). A deviation of more than O(q^{\u22123/2}) would refine the conjecture.\n\n**Impact**: This would give the **sharp constant** in the spectral gap: \u03b3(S) \u2265 1/(2q), matching the Ramanujan bound for GL\u2082. It would also connect certified expanders to the arithmetic of Kloosterman sums, creating a bridge to analytic number theory.\n\n**The key insight is** that Singer-like elements in GL\u2082(\ud835\udd3d_q) act on the principal series through their eigenvalues in the quadratic extension \ud835\udd3d_{q\u00b2}, and the resulting character sums are precisely Kloosterman sums, whose cancellation is controlled by the Weil bound.\n\n**Why now?** The familywise framework established here reduces the problem to a single family (principal series), and recent work on Kloosterman sum formalization in Lean (via the Weil bound project) provides the necessary analytical tools.\n\n**Catalog References**: `Catalog/Pythagorean/GL2SpectralDecomposition.lean` \u2014 `spectral_radius_eq_principal_if_dominates`, `abstract_spectral_gap_lower_bound`\n\n**Proof Strategy**: Realize the principal series as functions on P\u00b9(\ud835\udd3d_q), compute the matrix coefficients of M_\u03c0(S) as sums over \ud835\udd3d_q involving characters, identify these as Kloosterman sums, apply the Weil bound.\n\n**Domain Bridges**: Analytic number theory (Kloosterman sums), algebraic geometry (Weil bound)\n\n**Lineage**: This direction descends from the abstract spectral gap framework (Theorem 9) and the principal-series dominance theorem (Theorem 8).\n\n**Ambition**: Grand challenge \u2014 would establish the sharp Ramanujan-type bound for certified GL\u2082 expanders.\n\n---",
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
    "source_exp_id": "b2a4e38f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T12:18:36.484704+00:00"
  },
  {
    "id": "fd_1817",
    "title": "Direction 1: Entropy Bounds via Resistance Inequalities",
    "description": "**Conjecture:** For a DPP with kernel $L$ on $[n]$, the Shannon entropy $H(\\mu)$ of the inclusion probabilities satisfies:\n$$H(\\mu) \\leq \\frac{1}{2} \\sum_{i \\neq j} L_{ij}^2 \\cdot R_{\\text{eff}}(i, j)$$\nwhere $R_{\\text{eff}}$ is the effective resistance in the graph with conductances $L_{ij}^2$.\n\n**Test:** Compute both sides for random DPP kernels of size $n \\leq 10$. Search for counterexamples and refine the bound constant.\n\n**Impact:** This would give the first entropy bound for DPPs derived purely from resistance geometry, connecting Shannon theory to Kirchhoff's laws. It could improve existing bounds by Lyons (2003) on negative association.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (DPP partition function), `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (Dirichlet form identity).\n\n**Proof Strategy:** Use the variational characterization of entropy and the Dirichlet form identity to bound the KL divergence between the DPP and a product distribution. Apply the resistance monotonicity principle (Rayleigh) to simplify.\n\n**Domain Bridges:** Information theory \u2194 Electrical networks \u2194 Probability.\n\n**Lineage:** Extends Theorem 1 (Dirichlet form) and the Fisher-repulsion equivalence.\n\n**Ambition:** Grand challenge \u2014 if successful, creates a new class of entropy inequalities.\n\n**The key insight is** that the pairwise Dirichlet form controls the KL divergence between the DPP and its closest independent approximation, and resistance bounds directly bound this divergence.\n\n**Why now?** The Dirichlet form identity (formally verified) provides the precise tool needed to convert Hessian curvature into pairwise resistance sums, which was the missing link.\n\n---",
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
    "source_exp_id": "c6ae898d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T14:11:00.149771+00:00"
  },
  {
    "id": "fd_1818",
    "title": "Direction 2: Natural Gradient Optimization via Laplacian Solvers",
    "description": "**Conjecture:** The natural gradient for maximum likelihood estimation of DPP parameters can be computed in $\\tilde{O}(n^2)$ time (near-linear in the number of matrix entries) using fast Laplacian solvers.\n\n**Test:** Implement natural gradient DPP estimation using Spielman-Teng Laplacian solvers and compare convergence speed and per-iteration cost with standard gradient descent and Newton's method.\n\n**Impact:** Current DPP parameter estimation requires $O(n^3)$ per iteration (for the pseudoinverse). If the log-Hessian Laplacian structure can be exploited, this drops to $\\tilde{O}(n^2)$, making DPP learning practical for large datasets.\n\n**Catalog References:** `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (dpp_laplacianEnergy_eq_resolventDirichlet), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (DPPKernel structure).\n\n**Proof Strategy:** Show that the natural gradient direction $H^+ \\nabla$ can be approximated by solving the Laplacian system $Hx = \\nabla$ (projected to zero-sum). Apply Spielman-Teng nearly-linear-time Laplacian solver.\n\n**Domain Bridges:** Optimization \u2194 Spectral graph theory \u2194 Machine learning.\n\n**Lineage:** Direct application of Theorem 3 (DPP Dirichlet form).\n\n**Ambition:** Solid extension \u2014 the mathematical infrastructure is in place, and the algorithmic speedup is a concrete, testable claim.\n\n**The key insight is** that the natural gradient preconditioner for DPPs is a graph Laplacian, and graph Laplacians admit nearly-linear-time solvers.\n\n**Why now?** The formal identification of the DPP Hessian as a Laplacian (Theorem 3) removes the conceptual gap between DPP optimization and Laplacian linear algebra.\n\n---",
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
    "source_exp_id": "c6ae898d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T14:11:01.574237+00:00"
  },
  {
    "id": "fd_1819",
    "title": "Direction 3: Repulsion Metric as a Lorentzian Hessian",
    "description": "**Conjecture:** For any Lorentzian polynomial $p$ (in the sense of Br\u00e4nd\u00e9n-Huh), the Hessian of $\\log p$ at any point in the positive orthant defines a graph Laplacian on the zero-sum subspace, generalizing the DPP case.\n\n**Test:** Compute log-Hessians for known families of Lorentzian polynomials (elementary symmetric polynomials, basis generating polynomials of matroids) and check whether they have the Laplacian structure (nonpositive off-diagonal, zero row sums, PSD on zero-sum).\n\n**Impact:** Would unify the Laplacian interpretation across all Lorentzian polynomials, not just DPP generating polynomials. This would bring the entire Br\u00e4nd\u00e9n-Huh theory into contact with resistance networks.\n\n**Catalog References:** `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (IsDPPLorentzian definition, dpp_partition_function_lorentzian conjecture), `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (laplacianEnergy_eq_pairwise).\n\n**Proof Strategy:** Use the characterization of Lorentzian polynomials via their Hessian eigenvalue signature (at most one positive eigenvalue for degree-2 derivatives). Show that this implies the log-Hessian has the Laplacian sign pattern.\n\n**Domain Bridges:** Algebraic combinatorics (Lorentzian polynomials) \u2194 Spectral graph theory \u2194 Information geometry.\n\n**Lineage:** Extends Theorem 3 from DPP generating polynomials to all Lorentzian polynomials.\n\n**Ambition:** Grand challenge \u2014 would create a unified theory of \"Lorentzian resistance networks.\"\n\n**The key insight is** that the Lorentzian condition (at most one positive eigenvalue per Hessian slice) might force the log-Hessian to have the sign pattern of a Laplacian, extending the DPP result to all strongly log-concave polynomials.\n\n**Why now?** The DPP case (verified in this work) provides the first concrete example, and the Br\u00e4nd\u00e9n-Huh theory provides the algebraic tools needed for the general case.\n\n---",
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
    "source_exp_id": "c6ae898d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T14:11:01.665084+00:00"
  },
  {
    "id": "fd_1822",
    "title": "Direction 1: Higher-Order Anti-Cancellation and k-Shadows",
    "description": "**Conjecture:** For any Lorentzian polynomial $p$ with nonneg coefficients and any positive weight tensor $A_{i_1 \\cdots i_k}$, the support of $\\sum A_{i_1 \\cdots i_k} \\partial_{i_1} \\cdots \\partial_{i_k} p$ equals the union of $k$-th order derivative shadows over active entries of $A$.\n\n**Test:** Implement the $k$-shadow computation for $k = 3, 4$ on uniform matroid basis polynomials $U(r, n)$ with $n \\leq 7$. Verify support exactness for all-positive weight tensors. Search for counterexamples with mixed-sign tensors. The conjecture predicts zero cancellations in the positive regime and nonzero cancellation rates outside it. A single counterexample within the positive regime falsifies the conjecture.\n\n**Impact:** Would establish a complete hierarchy of anti-cancellation theorems indexed by differential order, showing that Lorentzian structure rigidifies support at every level of the derivative tower. This would provide support-based lower bounds for arithmetic circuits computing $k$-th order partial derivatives.\n\n**Catalog References:** `Pythagorean/LorentzianAggregateAntiCancel.lean` (Theorem A), `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (per-pair exactness).\n\n**Proof Strategy:** Generalize the overlap sign coherence condition from pairs to $k$-tuples. The key lemma is that for nonneg-coefficient polynomials, each $k$-th derivative coefficient is a product of $k$ natural numbers times a nonneg coefficient, hence nonneg. With positive weights, all contributions are positive.\n\n**Domain Bridges:** Combinatorial Hodge theory \u2194 Arithmetic circuit complexity.\n\n**Lineage:** Extends the current Theorem A from $k=2$ to general $k$.\n\n**Ambition:** Grand challenge \u2014 requires new formalization of higher-order tensor operators and their support geometry.\n\n**The key insight is** that the factored coefficient formula $[\\beta]\\,\\partial_{i_1}\\cdots\\partial_{i_k} p = \\prod_{m=1}^k (\\beta_{i_m} + c_m) \\cdot c_{\\beta + \\sum e_{i_m}}$ preserves nonnegativity at every order, not just $k=2$.\n\n**Why now?** The formal infrastructure for second-order pair shadows is in place; the generalization to $k$-tuples requires only tensor notation, not new mathematical ideas.\n\n---",
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
    "source_exp_id": "57cfb68b",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T14:11:26.537599+00:00"
  },
  {
    "id": "fd_1823",
    "title": "Direction 2: M-Convexity Inheritance for Hessian Shadows",
    "description": "**Conjecture:** If $p$ is a Lorentzian polynomial whose support is an M-convex set (in the sense of Murota's discrete convex analysis), then for any positive weight matrix $A$, the aggregate shadow $\\text{AgSh}(p, A)$ is also M-convex.\n\n**Test:** For all uniform matroid basis polynomials $U(r, n)$ with $n \\leq 8$, compute the aggregate shadow under all-ones weights and verify the symmetric exchange property: for any $\\alpha, \\beta \\in \\text{AgSh}$ and any $i$ with $\\alpha_i > \\beta_i$, there exists $j$ with $\\alpha_j < \\beta_j$ and $\\alpha - e_i + e_j \\in \\text{AgSh}$. A violation falsifies the conjecture.\n\n**Impact:** Would establish that Hessian aggregation is a morphism in the category of M-convex sets, connecting Lorentzian Hodge theory to Murota's discrete optimization framework. This would enable polynomial-time optimization algorithms on Hessian shadow structures.\n\n**Catalog References:** `Pythagorean/LorentzianAggregateAntiCancel.lean` (sub-convexity theorem), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`.\n\n**Proof Strategy:** Use the \"two-step exchange\" approach: show that the symmetric exchange for the aggregate shadow follows from the exchange property of $p$'s support combined with the derivative shadow structure. The discrete sub-convexity theorem already proved is a partial step.\n\n**Domain Bridges:** Discrete convex analysis \u2194 Matroid theory \u2194 Combinatorial Hodge theory.\n\n**Lineage:** Extends the sub-convexity result (Theorem 3.7) to full M-convexity.\n\n**Ambition:** Solid extension \u2014 builds directly on existing infrastructure.\n\n**The key insight is** that the derivative shadow operation $\\text{supp}(p) \\mapsto \\{\\alpha - e_i - e_j : \\alpha \\in \\text{supp}(p)\\}$ is a Minkowski subtraction by a rank-2 lattice vector, and Minkowski operations preserve M-convexity for the right class of lattice polytopes.\n\n**Why now?** Murota's theory is well-developed but lacks formal connections to Hodge theory; the anti-cancellation theorem provides the missing algebraic bridge.\n\n---",
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
    "source_exp_id": "57cfb68b",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T14:11:26.628158+00:00"
  },
  {
    "id": "fd_1825",
    "title": "Direction 4: Lorentzian Anti-Cancellation in Statistical Physics",
    "description": "**Conjecture:** For the partition function $Z = \\sum_\\sigma \\exp(-\\beta H(\\sigma))$ of a ferromagnetic Ising model on a graph $G$, the associated \"multivariate partition polynomial\" (with variables indexing spins) is Lorentzian when $\\beta > 0$. The anti-cancellation theorem then implies that the observable support of any positive second-order susceptibility operator equals its aggregate shadow \u2014 meaning no physical observable is accidentally hidden by thermal averaging.\n\n**Test:** Compute the multivariate partition polynomial for the Ising model on small graphs ($K_4$, $K_5$, Petersen graph) at various temperatures. Verify Lorentzian conditions (Newton inequalities along all slices). Compute the Hessian shadow under the susceptibility matrix $\\chi_{ij} = \\partial_i \\partial_j \\ln Z$ and verify support exactness.\n\n**Impact:** Would establish a formal connection between Lorentzian polynomial theory and equilibrium statistical mechanics. The anti-cancellation theorem would guarantee that physical susceptibilities cannot accidentally vanish \u2014 a form of \"no hidden correlations\" for ferromagnetic systems.\n\n**Catalog References:** `Pythagorean/LorentzianAggregateAntiCancel.lean`, `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`.\n\n**Proof Strategy:** The Lee\u2013Yang theorem guarantees that the partition function of a ferromagnetic Ising model has all roots on the unit circle, implying a form of stability. Use the Br\u00e4nd\u00e9n\u2013Huh characterization to show that stability implies the Lorentzian condition. Then apply the anti-cancellation theorem.\n\n**Domain Bridges:** Statistical physics \u2194 Combinatorial Hodge theory \u2194 Probability theory.\n\n**Lineage:** Connects the Lorentzian framework to the classical Lee\u2013Yang theory.\n\n**Ambition:** Grand challenge \u2014 would unify two major mathematical physics traditions.\n\n**The key insight is** that the Lee\u2013Yang property (real-stability) is strictly stronger than the Lorentzian condition, so ferromagnetic partition functions are automatically in the anti-cancellation regime.\n\n**Why now?** Recent breakthroughs by Anari, Liu, Oveis Gharan, and Vinzant have established the Lorentzian framework for strongly Rayleigh measures, which are closely related to ferromagnetic partition functions. The formal infrastructure is ready for cross-pollination.\n\n---",
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
    "source_exp_id": "57cfb68b",
    "consumed_by_exp_id": "37e69c75",
    "timestamp": "2026-05-28T14:11:26.812761+00:00"
  },
  {
    "id": "fd_1842",
    "title": "Direction 1: Complete SAT-to-Lorentzian Reduction (Grand Challenge)",
    "description": "**Conjecture**: There exists a polynomial-time computable map from CNF formulas \u03c6 to homogeneous polynomials P_\u03c6 with nonneg integer coefficients such that P_\u03c6 is Lorentzian if and only if \u03c6 is unsatisfiable. This would establish coNP-hardness of unrestricted-degree Lorentzian recognition.\n\n**Test**: For each 3-SAT instance on \u2264 6 variables, compute P_\u03c6 and verify the Lorentzian \u2194 unsatisfiable equivalence by exhaustive Hessian checking. A single counterexample disproves the conjecture.\n\n**Impact**: The first complexity-hardness result for a Hodge-theoretic positivity predicate. Would transform the field's understanding of what \"algebraic positivity\" means computationally.\n\n**Catalog References**: `Pythagorean/LorentzianHardness.lean` \u2014 `boolean_assignment_multiindex_lower_bound`, `assignmentToMultiindex_injective`; `Catalog/Bridges/LorentzianRecognition.lean` \u2014 `IsRecursivelyLorentzian`, `hessianMatrix`.\n\n**Proof Strategy**: Use the Boolean-to-multiindex encoding (Theorem C) as the assignment layer. Construct P_\u03c6 so that: (a) clause constraints appear as coefficient conditions on specific monomials, (b) unsatisfied assignments produce Hessians with two positive eigenvalues. The key algebraic challenge is designing the monomial structure so the Hessian sign condition at leaf \u03b1 detects whether the assignment encoded by \u03b1 satisfies all clauses.\n\n**Domain Bridges**: Computational complexity (Cook\u2013Levin theory) \u2194 algebraic combinatorics (Lorentzian polynomials) \u2194 spectral theory (Hessian eigenvalues).\n\n**Lineage**: Builds directly on Theorems B and C of this cycle.\n\n**Ambition**: Grand challenge \u2014 paradigm-shifting.\n\n> **The key insight is** that the Boolean-to-multiindex injection we've proved provides the combinatorial backbone of a SAT reduction; what remains is the algebraic design of coefficient patterns that make Hessian signatures detect clause satisfaction.\n\n> **Why now?** The formalization of the multiindex-assignment correspondence makes the reduction structure precise for the first time, reducing the problem from \"design a reduction from scratch\" to \"design a polynomial with specified Hessian behavior at known points.\"\n\n---",
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
    "source_exp_id": "7968ebde",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T15:57:05.064782+00:00"
  },
  {
    "id": "fd_1843",
    "title": "Direction 2: Spectral Embedding \u2014 Matrix Positivity to Lorentzian Leaves",
    "description": "**Conjecture**: For any n\u00d7n symmetric rational matrix A, there exists a homogeneous polynomial P_A in n+2 variables such that P_A is Lorentzian if and only if A has at most one positive eigenvalue. The construction should be polynomial-time computable.\n\n**Test**: For random 4\u00d74 symmetric matrices, compute P_A and verify the eigenvalue-Lorentzian equivalence against numerical eigenvalue decomposition.\n\n**Impact**: Creates a second reduction route to hardness (from matrix spectral problems) and connects Lorentzian theory to semialgebraic geometry and semidefinite programming.\n\n**Catalog References**: `Catalog/Bridges/LorentzianRecognition.lean` \u2014 `HasAtMostOnePositiveEigenvalue`, `QuadForm`, `hessianMatrix`; `Pythagorean/LorentzianHardness.lean` \u2014 `multiindex_count_exponential_lower`.\n\n**Proof Strategy**: Embed the matrix A into the Hessian of a carefully constructed quartic polynomial. The degree-2 derivative leaves of this quartic are quadratics whose Hessians are translates of A. If A has two positive eigenvalues, some leaf fails the Lorentzian condition.\n\n**Domain Bridges**: Spectral graph theory \u2194 Lorentzian polynomials \u2194 semidefinite programming.\n\n**Lineage**: Extends the tangent-space negativity theorem from the catalog.\n\n**Ambition**: Solid extension \u2014 builds a new reduction route.\n\n> **The key insight is** that the Hessian matrix of a Lorentzian polynomial's degree-2 leaf *is* the spectral object being tested, so embedding a target matrix into a leaf Hessian is algebraically natural \u2014 it's the reverse direction of the recognition procedure.\n\n> **Why now?** The catalog's formalization of `hessianMatrix` and `HasAtMostOnePositiveEigenvalue` provides the exact interface needed for a spectral embedding theorem.\n\n---",
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
    "source_exp_id": "7968ebde",
    "consumed_by_exp_id": "2a56098b",
    "timestamp": "2026-05-28T15:57:05.143458+00:00"
  },
  {
    "id": "fd_1844",
    "title": "Direction 3: Parameterized Complexity by Treewidth and Support Size",
    "description": "**Conjecture**: Lorentzian recognition is fixed-parameter tractable when parameterized by both degree d and the treewidth of the variable interaction graph (the graph where variables i and j are adjacent if some monomial involves both x_i and x_j). Specifically, for treewidth w and degree d, recognition can be decided in time O(n \u00b7 w^d).\n\n**Test**: Construct polynomial families with treewidth 2 (path-structured variable interactions) and verify that the Hessian checks factorize along the tree decomposition, reducing the effective leaf count.\n\n**Impact**: Would show that the hardness barrier is not just about degree but about the *interaction complexity* of variables, connecting Lorentzian recognition to structural graph theory.\n\n**Catalog References**: `Pythagorean/LorentzianHardness.lean` \u2014 `multiindex_count_exponential_lower`, `leaf_count_exponential_lower`; `Catalog/Bridges/LorentzianRecognition.lean` \u2014 `quadratic_leaf_count_le`.\n\n**Proof Strategy**: For tree-structured polynomials, the Hessian at each leaf decomposes into independent blocks corresponding to subtrees. Use dynamic programming on the tree decomposition to count only the O(w^d) \"non-redundant\" leaves.\n\n**Domain Bridges**: Parameterized complexity theory \u2194 structural graph theory \u2194 algebraic combinatorics.\n\n**Lineage**: Refines the upper bound from the catalog and the lower bound from this cycle.\n\n**Ambition**: Solid extension \u2014 maps the complexity landscape.\n\n> **The key insight is** that the exponential blowup in our lower bounds requires variables that interact globally (as in the binary-to-multiindex injection); restricting interactions to a tree should recover tractability, exactly as it does for constraint satisfaction problems.\n\n> **Why now?** The explicit lower bound constructions reveal *where* the combinatorial explosion comes from (high-interaction multiindices), making it possible to identify structural parameters that tame it.\n\n---",
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
    "source_exp_id": "7968ebde",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T15:57:05.219278+00:00"
  },
  {
    "id": "fd_1845",
    "title": "Direction 4: Average-Case Lorentzian Recognition and Random Polynomials",
    "description": "**Conjecture**: For random homogeneous polynomials with i.i.d. nonneg coefficients, Lorentzian recognition can be decided in expected polynomial time for any fixed degree, and the probability of Lorentzianity undergoes a sharp threshold as the coefficient distribution varies.\n\n**Test**: Sample 1000 random degree-6 homogeneous polynomials in 10 variables with coefficients drawn from Poisson(\u03bb) for various \u03bb. Measure the fraction that are Lorentzian and the average certificate size.\n\n**Impact**: Would show that worst-case hardness does not preclude efficient average-case algorithms, potentially enabling practical Lorentzian recognition for naturally occurring polynomials.\n\n**Catalog References**: `Pythagorean/LorentzianHardness.lean` \u2014 `ExponentialCertificateBarrierConjecture`; `Catalog/Bridges/LorentzianRecognition.lean` \u2014 `lorentzian_reversed_cauchy_schwarz`.\n\n**Proof Strategy**: Use the reversed Cauchy\u2013Schwarz inequality (from the catalog) to derive concentration bounds. For \"generic\" coefficients, the Hessian eigenvalues at each leaf are well-separated, allowing early termination of the spectral test.\n\n**Domain Bridges**: Probability theory \u2194 random matrix theory \u2194 algebraic combinatorics.\n\n**Lineage**: Motivated by the gap between worst-case lower bounds (this cycle) and practical recognition.\n\n**Ambition**: Solid extension \u2014 addresses practical relevance.\n\n> **The key insight is** that random polynomials have coefficient patterns that are far from the adversarial constructions needed for our lower bounds, so the *typical* certificate complexity may be much smaller than the worst case.\n\n> **Why now?** The explicit lower bound families we construct are highly structured; understanding how generic polynomials differ will reveal whether the hardness barrier is ubiquitous or pathological.\n\n---",
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
    "source_exp_id": "7968ebde",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T15:57:05.300366+00:00"
  },
  {
    "id": "fd_1847",
    "title": "Direction 1: Higher-Order Tensor Certificates for Ultra-Log-Concavity",
    "description": "**Conjecture:** For a degree-$d$ multiaffine real stable polynomial $g$ with nonneg coefficients, define the order-$k$ certificate tensor:\n$$T^{(k)}_{g,x}(u_1, \\ldots, u_k) = \\sum_{j=0}^{k} (-1)^j \\binom{k}{j} g(x)^{k-j-1} \\left(\\prod_{\\ell=1}^{j} D_{u_\\ell} g(x)\\right) D_{u_{j+1}} \\cdots D_{u_k} g(x)$$\nThen for $k \\leq d$, $T^{(k)}$ has a definite sign pattern controlled by $(-1)^k$, generalizing the $k=2$ NSD result.\n\n**Test:** Compute $T^{(3)}$ and $T^{(4)}$ for uniform matroid polynomials $U_{r,n}$ with $n \\leq 8$ and verify the alternating sign pattern on random positive points. A single violation refutes the conjecture.\n\n**Impact:** Would establish ultra-log-concavity (Mason's conjecture strength) directly from real stability, bypassing the Alexandrov-Fenchel machinery. This could resolve open problems about independent set sequences of matroids.\n\n**Catalog References:** `Catalog/Pythagorean/StronglyRayleighCertificate.lean` (Theorem `certMatrix_quadForm_decomposition`), `Catalog/Pythagorean/HessianLorentzianGap.lean` (log-Hessian formalism).\n\n**Proof Strategy:** Induction on $k$ using the recursive structure of the directional Rayleigh inequality. The base case $k=2$ is our NSD theorem. The inductive step requires a new \"iterated Rayleigh inequality\" that may follow from the characterization of real stable polynomials as limits of products of linear forms.\n\n**Domain Bridges:** Combinatorics (Mason's conjecture) \u2194 Differential geometry (higher curvature tensors) \u2194 Algebraic geometry (Hodge-Riemann relations).\n\n**Lineage:** Extends the core NSD theorem from `StronglyRayleighCertificate.lean`.\n\n**Ambition:** Grand challenge \u2014 would resolve a major open problem in combinatorics.\n\n---",
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
    "source_exp_id": "4d322aa9",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T16:34:02.173795+00:00"
  },
  {
    "id": "fd_1848",
    "title": "Direction 2: Spectral Gap Bounds from Certificate Eigenvalues",
    "description": "**Conjecture:** For a strongly Rayleigh measure $\\mu$ on $2^{[n]}$ with generating polynomial $g$, the spectral gap $\\gamma$ of the natural Glauber dynamics satisfies:\n$$\\gamma \\geq \\frac{\\min_i |\\lambda_{\\min}(M_g(\\mathbf{1}))|}{n \\cdot g(\\mathbf{1})^2}$$\nwhere $\\lambda_{\\min}$ is the smallest eigenvalue of the certificate matrix at the all-ones point.\n\n**Test:** Compare the certificate-based bound with the actual spectral gap (computed by eigendecomposition of the transition matrix) for DPPs with random 5\u00d75 kernels and uniform matroids $U_{r,n}$ with $n \\leq 7$.\n\n**Impact:** Would provide the first non-trivial mixing time bounds derived purely from polynomial invariants, applicable to all strongly Rayleigh distributions without case-specific analysis.\n\n**Catalog References:** `Catalog/Pythagorean/StronglyRayleighCertificate.lean` (definitions of `lorentzianCertMatrix`, `ConditionalNSD`), `Catalog/Pythagorean/HessianLorentzianGap.lean` (`HasHessianLorentzianGap`).\n\n**Proof Strategy:** Relate the certificate eigenvalues to the modified log-Sobolev constant via the identity $M_g/g^2 = \\mathrm{Hess}(\\log g)$. Use the Bakry-\u00c9mery criterion with the log-Hessian as the curvature tensor.\n\n**Domain Bridges:** Probability (mixing times) \u2194 Spectral theory (eigenvalue gaps) \u2194 Information geometry (Fisher information).\n\n**Lineage:** Extends `HasHessianLorentzianGap` from `HessianLorentzianGap.lean` with quantitative bounds.\n\n**Ambition:** Solid extension \u2014 builds directly on existing results with clear applications.\n\n---",
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
    "source_exp_id": "4d322aa9",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T16:34:02.254671+00:00"
  },
  {
    "id": "fd_1851",
    "title": "Direction 5: Fermionic Correlations and Quantum Certificate Transfer",
    "description": "**Conjecture:** For a system of $n$ fermions with density matrix $\\rho$, the correlation matrix $C_{ij} = \\mathrm{Tr}(\\rho \\, c_i^\\dagger c_j)$ generates a strongly Rayleigh polynomial $g_C(z) = \\det(I + \\mathrm{diag}(z) \\cdot C)$. The certificate matrix $M_{g_C}(x)$ at $x = \\mathbf{1}$ equals (up to normalization) the connected two-point correlation function $\\langle n_i n_j \\rangle - \\langle n_i \\rangle \\langle n_j \\rangle$, providing a direct bridge from quantum correlations to the Lorentzian certificate.\n\n**The key insight is** that fermionic systems are inherently determinantal, so the DPP machinery applies. But the certificate framework extends to **interacting fermion systems** where the effective one-body density matrix $C$ is only approximately PSD, and the generating polynomial is only approximately real stable.\n\n**Why now?** Recent advances in tensor network methods and quantum simulation make it feasible to extract effective one-body density matrices from interacting systems. Our certificate theory provides the mathematical framework to certify negative dependence properties of these approximate descriptions.\n\n**Test:** Compute the certificate matrix from the one-body density matrix of small Hubbard model systems (exact diagonalization for $n \\leq 8$ sites) and verify NSD. Measure the certificate violation as a function of interaction strength $U/t$.\n\n**Impact:** Would connect formal certificate theory to quantum many-body physics, providing rigorous bounds on correlation structure that are currently obtained only through numerical approximation.\n\n**Catalog References:** `Catalog/Pythagorean/StronglyRayleighCertificate.lean` (certificate framework), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (DPP spectral bridge).\n\n**Proof Strategy:** For non-interacting fermions ($U=0$), the connection is exact via Wick's theorem. For weak interactions, use perturbation theory in $U$ and the stability of the certificate under small polynomial perturbations.\n\n**Domain Bridges:** Quantum physics (fermionic systems) \u2194 Probability (DPPs and strong Rayleigh) \u2194 Spectral theory (certificate eigenvalues).\n\n**Lineage:** Extends DPP theory from `DPPLorentzian.lean` to quantum systems.\n\n**Ambition:** Grand challenge \u2014 bridges formal mathematics to frontier physics.",
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
    "source_exp_id": "4d322aa9",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T16:34:03.284063+00:00"
  },
  {
    "id": "fd_1862",
    "title": "Direction 1: Higher-Order Shadow Certificates and Iterated Differentiation",
    "description": "**Conjecture:** For any polynomial p over \u211a and any k \u2265 1, the k-th order shadow (obtained by subtracting k unit basis vectors from support elements) exactly predicts the support of k-th order partial derivatives, with a corresponding k-th order non-cancellation certificate that is generic on shadow-closed supports.\n\n**Test:** Implement k-th order shadow computation for k = 3, 4 on random sparse polynomials in 3-5 variables. Verify predicted vs actual supports for all k-th partial derivatives. Search for a counterexample where a generic coefficient assignment violates the k-th order certificate.\n\n**Impact:** Higher-order shadows capture more refined structural information about polynomials. If the certificate extends to all orders, the full Taylor expansion structure of a polynomial is combinatorially determined by its support \u2014 a dramatic strengthening of the current second-order result.\n\n**Catalog References:**\n- `Pythagorean/NonCancellationCertificate.lean`: `coeff_pderiv_eq`, `coeff_pderiv_pderiv_ne_zero_iff`\n- `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`: `nonzeroQuadLeafSet_eq_shadow`\n\n**Proof Strategy:** Induction on k. The base case k = 2 is the current work. For the inductive step, apply `coeff_pderiv_eq` once more and verify that the new scalar factor (involving (\u03b2(i_k) + 1)) is nonzero over \u211a. The key insight is that each additional derivative introduces exactly one new positive-integer scalar factor, preserving the one-ancestor property.\n\n**Domain Bridges:** Combinatorics (shadow growth rates), Analysis (Taylor remainder estimates), Complexity theory (depth-k circuit lower bounds)\n\n**Lineage:** Extends the exact support realization theorem from order 2 to arbitrary order.\n\n**Ambition:** Solid extension \u2014 directly builds on established techniques.\n\n**Why now?** The coefficient transport formula (`coeff_pderiv_eq`) has been formally verified for arbitrary order, providing the inductive base case. Extending to k-th order is a natural next step that the existing infrastructure directly supports.\n\n---",
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
    "source_exp_id": "7a00ed5d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T17:54:29.077276+00:00"
  },
  {
    "id": "fd_1864",
    "title": "Direction 3: Tropical Shadow Duality and Newton Polytope Preservation",
    "description": "**Conjecture:** Under the non-cancellation certificate, the Newton polytope of each Hessian entry \u2202\u1d62\u2202\u2c7cp equals the \"shadow polytope\" \u2014 the convex hull of quadLeafSet(supp(p), i, j). More precisely, there is a tropical-algebraic duality: the support shadow operation corresponds exactly to tropicalization of the derivative, and the certificate guarantees that this tropical operation faithfully represents the algebraic one.\n\n**Test:** For polynomials in 3-4 variables with 10-30 support elements, compute Newton polytopes of all Hessian entries and compare to shadow polytopes. Test whether vertex sets match (not just containment). Explore whether the duality extends to mixed volumes and intersection theory.\n\n**Impact:** This would establish a rigorous connection between tropical geometry and algebraic complexity, creating a tropical lower-bound method for arithmetic circuits. Tropical methods are computationally efficient (polyhedral computation vs algebraic computation), so this duality would make complexity analysis more tractable.\n\n**Catalog References:**\n- `Pythagorean/NonCancellationCertificate.lean`: `quadLeafSet`, `hessian_support_eq_quadLeafSet`\n- `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`: `QuadraticShadow`, `computeQuadShadow`\n\n**Proof Strategy:** The key insight is that Newton polytope = convex hull of support, and we already know the support exactly (Theorem 3). So the Newton polytope equality follows immediately from the exact support realization. The deeper content is the tropical interpretation: under the tropical semiring (min, +), differentiation becomes subtraction, and the shadow is the tropical derivative. Formalize this connection using tropical polynomial theory.\n\n**Domain Bridges:** Tropical geometry (tropicalization, tropical intersection theory), Convex geometry (Newton polytopes, mixed volumes), Algebraic geometry (Bernstein-Kushnirenko theorem)\n\n**Lineage:** Extends the support-level results to polytope-level geometry.\n\n**Ambition:** Solid extension with grand-challenge potential if tropical lower bounds are developed.\n\n**Why now?** The exact support realization theorem provides the algebraic foundation. Tropical geometry tools (polymake, OSCAR) are now mature enough to compute tropical derivatives systematically, enabling computational verification of the duality.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "7a00ed5d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T17:54:29.270864+00:00"
  },
  {
    "id": "fd_1866",
    "title": "Direction 5: Positive-Characteristic Obstruction Classification",
    "description": "**Conjecture:** Over a field of characteristic p, the set of exponents where the Hessian scalar factor vanishes is exactly {\u03b2 : p | (\u03b2(i) + 1) or p | ((\u03b2 + e\u1d62)(j) + 1)}, and the discrepancy between predicted and actual Hessian support is controlled by this set. More precisely, the \"failure set\" of the non-cancellation certificate in characteristic p has size O(|S| / p), and the certificate holds fully for supports contained in the \"p-small\" regime where all exponents are < p.\n\n**Test:** For characteristics p = 2, 3, 5, 7, 11, generate random polynomials with maximum degree d = 1,...,20 and compute the failure rate (fraction of predicted support elements that actually vanish). Plot failure rate vs d/p. Verify the O(|S|/p) prediction.\n\n**Impact:** This would provide a precise quantitative understanding of when and why characteristic-zero techniques fail in positive characteristic, and identify the \"safe\" regime where they still apply. This is relevant to both theoretical complexity (circuits over finite fields) and practical applications (polynomial computation in cryptography).\n\n**Catalog References:**\n- `Pythagorean/NonCancellationCertificate.lean`: `hessianScalar_pos`, `hessianScalar_ne_zero`\n- `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`: `coeff_pderiv_pderiv_ne_zero_iff`\n\n**Proof Strategy:** The key insight is that the Hessian scalar factor (\u03b2(i) + 1)\u00b7((\u03b2 + e\u1d62)(j) + 1) is a product of two terms, each of which vanishes mod p iff the corresponding natural number is divisible by p. Count the number of \u03b2 in the shadow where this happens. For uniformly distributed exponents in [0, d]^n, the fraction with p | (\u03b2(i) + 1) is approximately 1/p, giving the O(|S|/p) bound.\n\n**Domain Bridges:** Number theory (characteristic p phenomena, Frobenius), Cryptography (polynomial evaluation over finite fields), Coding theory (Reed-Solomon structure)\n\n**Lineage:** Characterizes the boundary of the current theory.\n\n**Ambition:** Solid extension with connections to number theory.\n\n**Why now?** The characteristic-zero theory is now formally established. Understanding exactly where it breaks in positive characteristic is the natural next step, and computational experiments can immediately test the conjectured quantitative bounds.",
    "domains": [
      "Pythagorean",
      "Algebra",
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
    "source_exp_id": "7a00ed5d",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T17:54:29.471886+00:00"
  },
  {
    "id": "fd_1886",
    "title": "Direction 1: Partition Matroid Spectral Stability",
    "description": "**Conjecture:** For the partition matroid $M = U_{r_1, n_1} \\oplus \\cdots \\oplus U_{r_k, n_k}$, the Lorentzian spectral gap is the minimum of the individual block gaps, and the stability radius decomposes as a minimum over blocks.\n\n**Test:** Compute the leaf Hessians of the partition matroid generating polynomial for small $(n_i, r_i)$ triples. Verify that the minimum eigenvalue gap across all leaves equals $\\min_i \\text{gap}(U_{r_i, n_i}) = 1$. If the gaps differ from 1, the conjecture refines to a block-structure formula.\n\n**Impact:** Partition matroids are the next most natural family after uniform matroids and appear in scheduling, resource allocation, and constraint satisfaction. An explicit spectral stability theorem would immediately yield certified perturbation budgets for algorithms operating on these structures.\n\n**Catalog References:**\n- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`: `lorentzian_stability_radius_exists`, `hasAtMostOnePositiveEigenvalue_of_gapped_perturbation`\n- `Catalog/Pythagorean/UniformMatroidLorentzianStability.lean`: `uniform_leaf_has_gapped_signature`, `uniform_stability_lower_bound`\n\n**Proof Strategy:** The generating polynomial of a direct sum is a product: $f_{M_1 \\oplus M_2} = f_{M_1} \\cdot f_{M_2}$. Quadratic leaves of the product involve one leaf from each factor plus cross terms. Analyze the Hessian block structure: it should be block-diagonal (from individual factors) plus a rank-deficient cross term. The spectral gap of the block-diagonal part is the minimum of individual gaps; the cross term is perturbative.\n\n**Domain Bridges:** Optimization (block-structured semidefinite programs), probability (negative association for partition matroids), coding theory (matroid-based codes with block structure).\n\n**Lineage:** Direct extension of the uniform matroid stability theorem, using the product structure of direct sum generating polynomials.\n\n**Ambition:** Solid extension \u2014 the mathematical framework is in place, and the main challenge is handling the cross terms in the Hessian block decomposition.\n\n**The key insight is** that direct sums decompose the Hessian into block-diagonal form, and the spectral gap of a block-diagonal matrix is the minimum of the block gaps.\n\n**Why now?** The exact spectral computation for the uniform case provides the building block, and the generic perturbation theorem from the catalog handles the cross-term perturbation.\n\n---",
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
    "source_exp_id": "bf323aae",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T19:09:44.380389+00:00"
  },
  {
    "id": "fd_1887",
    "title": "Direction 2: Lorentzian Condition Numbers and Certified Sampling",
    "description": "**Conjecture:** There exists a computable **Lorentzian condition number** $\\kappa(f)$ for any Lorentzian polynomial $f$ such that: (i) sampling algorithms for $f$ converge at rate $1/\\kappa(f)$, and (ii) $f + \\delta$ remains Lorentzian whenever the coefficient perturbation satisfies $\\|\\delta\\|_\\infty < 1/\\kappa(f)$.\n\n**Test:** For uniform matroids, verify that $\\kappa(e_r) = m^2$ (matching the entry-norm stability radius $1/m^2$). For random log-concave polynomials, compute $\\kappa$ numerically and correlate with MCMC mixing time estimates.\n\n**Impact:** This would create a quantitative bridge between algebraic combinatorics and algorithm design. Practitioners using Lorentzian-polynomial-based samplers could read off the perturbation budget directly from the condition number, without needing to understand spectral theory.\n\n**Catalog References:**\n- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`: `LorentzianConditionNumber`, `certifyStability_sound`\n- `Catalog/Pythagorean/UniformMatroidLorentzianStability.lean`: `uniform_matroid_stability_radius`, `hessian_entry_bound_from_coeff_perturbation`\n\n**Proof Strategy:** Define $\\kappa(f) = \\max_\\alpha \\|H_\\alpha\\|_{\\text{op}} / \\text{gap}(H_\\alpha)$ where the max is over all quadratic leaf Hessians $H_\\alpha$. The stability radius is then $1/\\kappa(f)$ in operator norm. The entry-norm radius involves an additional $m^2$ factor from the entry-to-operator-norm conversion. Connect to mixing time via the Bakry\u2013\u00c9mery criterion adapted to discrete log-concave distributions.\n\n**Domain Bridges:** Algorithm design (MCMC sampling guarantees), numerical analysis (condition number theory), machine learning (certified robustness of generative models using log-concave distributions).\n\n**Lineage:** Builds on the spectral margin structure and the certified stability checker from the catalog.\n\n**Ambition:** Solid extension with high practical impact \u2014 the mathematical ingredients are mostly available, but the sampling connection requires new analysis.\n\n**The key insight is** that the spectral gap of the leaf Hessian controls both the stability radius (how much noise is tolerable) and the mixing time (how fast algorithms converge), unifying numerical and algorithmic aspects.\n\n**Why now?** The exact gap computation for uniform matroids validates the concept, and the growing use of Lorentzian-polynomial-based samplers in practice creates demand for quantitative robustness certificates.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "Cryptography",
      "Bridges",
      "MachineLearning",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "bf323aae",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T19:09:44.483512+00:00"
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
    "id": "fd_1509",
    "title": "Arithmetic Universality Class for Primewise Persistent Homology of Rational Dyna",
    "description": "Conjecture: Let f,g \\in \\mathbb{Q}(x) be rational maps of degree at least 2 that are not conjugate over \\overline{\\mathbb{Q}} and whose postcritical dynamics are not both Latt\\u00e8s. For each good prime p, form the directed graph of the map on \\mathbb{P}^1(\\mathbb{F}_p), build a canonical filtered flag complex from orbit-preimage structure, and record the primewise persistence profile \\Pi_f(p). Then there exists a finite set of persistence statistics S(f) extracted from \\{\\Pi_f(p)\\}_p such that S(f)=S(g) for a density-1 set of primes p if and only if f and g are conjugate over \\overline{\\mathbb{Q}}. Test: Compute these persistence profiles for large families of quadratic and cubic rational maps over many good primes; confirmation is separation of non-conjugate maps with only finitely many exceptional primes, while repeated density-1 collisions between genuinely non-conjugate maps refute the conjecture. Impact: This would create a new topological invariant of arithmetic dynamics, turning mod-p orbit data into a practical and theoretically sharp classifier of algebraic dynamical systems, with possible applications to detecting hidden symmetries, exceptional maps, and dynamical moduli stratification.",
    "domains": [
      "Arithmetic Dynamics",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-27T18:35:56.749847+00:00"
  },
  {
    "id": "fd_1581",
    "title": "Adelic Synchronization Threshold for Rational Dynamics",
    "description": "Conjecture: There exists an explicit non-isotrivial family of rational maps f_t over Q of degree at least 2 and a finite combinatorial construction K_p(f_t) from the reduction of f_t modulo each good prime p such that the cross-prime mutual information of the resulting persistent homology barcodes undergoes a sharp phase transition exactly at the parameters t for which f_t acquires an exceptional algebraic relation among critical orbit portraits over Qbar. Test: Compute K_p(f_t) for many good primes p across parameter families, estimate barcode mutual-information matrices across primes, and check whether the emergence of a high-synchronization regime is equivalent to independently verified exceptional orbit relations; a single counterexample in either direction refutes the conjecture. Impact: This would create a new adelic order parameter for detecting hidden algebraic structure in arithmetic dynamical systems, potentially giving a topological probe of postcritical relations, rigidity loci, and moduli stratification.",
    "domains": [
      "Arithmetic Dynamics",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T00:38:07.672322+00:00"
  },
  {
    "id": "fd_1582",
    "title": "Automatic Sequence Rigidity from Prime-Indexed Subword Zeta Functions",
    "description": "Conjecture: Let a,b be infinite sequences over a finite alphabet generated by finite-state transducers (equivalently, automatic or morphic sequences of bounded description complexity). For each prime p, form the length-p subword frequency vector v_p(a) and v_p(b), and let Z_a(s)=\\sum_p p^{-s} H(v_p(a)) where H is Shannon entropy of the normalized subword frequency distribution. If H(v_p(a))=H(v_p(b)) for a set of primes of positive relative density and the corresponding rank profiles of the Hankel matrices of length-p factors also agree on that set, then a and b are shift-equivalent up to a coding. Test: Enumerate large libraries of automatic/morphic sequences, compute prime-indexed subword entropy and Hankel-rank signatures, and search for non-equivalent pairs with matching signatures on many primes; a single such pair refutes the conjecture, while exhaustive verification up to growing automaton size/prime cutoff provides evidence. Impact: This would create a new arithmetic-spectral invariant for symbolic dynamics, linking automata theory, combinatorics on words, and analytic/arithmetic statistics, and could yield algorithmic classification tools for low-complexity sequences.",
    "domains": [
      "Automata Theory",
      "Combinatorics on Words"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T00:38:41.078890+00:00"
  },
  {
    "id": "fd_1583",
    "title": "Arithmetic Universality of Persistent Homology for Cellular Automata Trace Space",
    "description": "Conjecture: There exists a one-dimensional nearest-neighbor cellular automaton A over a finite alphabet and a functorial construction sending each prime p to a filtered simplicial complex K_p(A,N) built from length-N spacetime trace statistics modulo p, such that the family of prime-indexed persistence diagrams undergoes a sharp phase transition in behavior if and only if A is computationally universal. Test: Compute K_p(A,N) for increasing N and many primes p for known universal and non-universal cellular automata; confirm the existence of a stable, quantitatively separable persistence-phase signature exactly for universal rules, and refute by finding a non-universal rule with the same asymptotic signature or a universal rule lacking it. Impact: This would create a topological/arithmetic order parameter for universality, linking computability, dynamics, and prime-sensitive topology, and could yield a new empirical route to classifying complex discrete systems.",
    "domains": [
      "Dynamical Systems",
      "Computability Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T00:39:08.569968+00:00"
  },
  {
    "id": "fd_1589",
    "title": "Primewise Persistent Homology Detects Exceptional Isogeny Volcano Depth",
    "description": "Conjecture: There exists an explicit functorial construction assigning to each ordinary elliptic curve E over a finite field F_p a filtered simplicial complex K(E) built from the l-isogeny graph neighborhoods of E (for a fixed small prime l != p) such that the multiset of persistence bar lengths in degree 1 determines the depth of E in its l-isogeny volcano for all sufficiently large p, and distinguishes crater vertices from floor vertices with error probability tending to 0 over random ordinary E/F_p. Test: For many primes p and ordinary curves E/F_p, compute K(E) from bounded-radius l-isogeny neighborhoods, compare the resulting barcodes with the known volcano depth from endomorphism ring computations, and verify whether a uniform classifier from persistence data succeeds asymptotically; refute by exhibiting an infinite family where barcode distributions fail to separate depths. Impact: This would create a topological invariant for arithmetic graph structure, opening a new route to navigating isogeny graphs, detecting endomorphism-ring information, and building topology-guided algorithms in isogeny-based cryptography.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T00:40:01.166599+00:00"
  },
  {
    "id": "fd_1593",
    "title": "Primewise Persistent Homology of Modular Reduction Detects Differential Galois G",
    "description": "Conjecture: There exists an explicit algorithm that assigns to every linear differential equation over Q(x) with regular singularities a finite filtered chain complex C_p for each good prime p such that the collection of prime-indexed persistence barcodes of C_p determines whether the differential Galois group is virtually solvable; moreover, two equations with Zariski-dense differential Galois groups in non-isomorphic simple algebraic groups produce asymptotically distinct barcode statistics on a positive-density set of primes. Test: Construct C_p from mod-p reduction data of the connection (e.g. p-curvature and Frobenius action), compute persistence invariants across large prime ranges for equations with known differential Galois groups (hypergeometric, Picard-Fuchs, Airy/Bessel-type examples), and check whether barcode features classify solvable vs non-solvable monodromy and separate ambient simple group type. A single counterexample family with indistinguishable asymptotic barcode laws despite different known Galois behavior refutes the conjecture. Impact: This would create a new topological probe of differential equations, linking p-curvature, arithmetic geometry, and topological data analysis, and could offer computable signatures for hidden symmetry and integrability in families of ODEs.",
    "domains": [
      "Arithmetic Geometry",
      "Differential Galois Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T00:40:32.501826+00:00"
  },
  {
    "id": "fd_1662",
    "title": "Prime-Periodic Persistence in Elliptic Divisibility Sequences",
    "description": "Conjecture: There exists an elliptic curve E/Q and a non-torsion point P in E(Q) such that the family of finite filtered complexes built from the prime-factor incidence structure of the elliptic divisibility sequence D_n = denom(x([n]P)) has a genuinely periodic mod-l persistent barcode for infinitely many auxiliary primes l, with period depending on the order of P modulo l; moreover this periodicity fails for a density-1 set of non-CM curves. Test: Explicitly construct complexes from divisibility hypergraphs of {D_1,...,D_N}, compute mod-l persistent homology as N grows, and check whether barcode statistics become eventually periodic in N for infinitely many l in the predicted family, versus no such infinite periodic family for generic non-CM curves. Refutation occurs if no such curve-point pair exhibits infinite prime-indexed periodic barcode behavior, or if the same behavior is generic rather than exceptional. Impact: This would create a new bridge between arithmetic dynamics on elliptic curves, divisibility sequences, and topological invariants, potentially giving a topological detector for hidden algebraic group structure and exceptional reduction behavior.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T03:48:38.722447+00:00"
  },
  {
    "id": "fd_1679",
    "title": "Prime-Threshold Percolation Law for Torsion Emergence in Random Simplicial Compl",
    "description": "Conjecture: For each fixed dimension d >= 2, there exists a universal scaling exponent alpha_d and a nonconstant prime-response profile Phi_d such that in the Linial\u2013Meshulam process Y_d(n,p), if p = c n^{-alpha_d}, then for every fixed prime ell the probability that H_{d-1}(Y_d(n,p); Z) contains nontrivial ell-primary torsion converges to Phi_d(c^{v_ell(n!)} / ell) along an infinite subsequence of n. In particular, different primes exhibit genuinely different torsion-onset windows after the same global rescaling, not explainable by the rational homology threshold alone. Test: Simulate Y_d(n,p) near known rational-homology critical windows, compute Smith normal forms of boundary maps, and estimate the onset probability of ell-primary torsion separately for several primes ell; the conjecture is supported if these curves collapse to prime-dependent nontrivial limits and refuted if a single prime-independent scaling law fits all torsion data. Impact: This would reveal a new arithmetic universality class in random topology, separating integral-topological phase transitions from field-coefficient phase transitions and giving the first quantitative law for how specific primes enter random torsion.",
    "domains": [
      "Random Topology",
      "Algebraic Topology"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T05:34:26.065542+00:00"
  },
  {
    "id": "fd_1680",
    "title": "Primewise Persistent Homology Distinguishes Isospectral but Nonisometric Arithme",
    "description": "Conjecture: There exists an explicit infinite family of pairs of compact arithmetic hyperbolic manifolds (or graphs) M_n, N_n that are Laplace-isospectral but nonisometric, together with a functorial construction assigning to each good prime p a finite filtered simplicial complex K_p(M), such that the collection of prime-indexed persistence barcodes of K_p(M_n) differs from that of K_p(N_n) for a positive-density set of primes p. Test: Construct Sunada-type isospectral pairs, define K_p from reduction/mod-p congruence orbits, geodesic-length residue data, or Hecke correspondences, and compute whether barcode distributions separate the pair on infinitely many or positive-density primes; refuted if all such computable primewise persistence invariants agree across every tested family. Impact: This would show that prime-sensitive topological invariants can detect hidden arithmetic structure invisible to classical spectra, opening a new route beyond spectral geometry toward arithmetic manifold identification.",
    "domains": [
      "Spectral Geometry",
      "Arithmetic Topology"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T05:35:00.011801+00:00"
  },
  {
    "id": "fd_1702",
    "title": "Persistent Homology Phase Diagram for Proof Search Complexity",
    "description": "Conjecture: There exists an explicit family of finitely presented theorem-proving/search spaces (for example, bounded-resolution SAT instances or Knuth\u2013Bendix completion states) such that the persistence barcode of the associated state-space complex exhibits a sharp topological phase transition exactly at the algorithmic hardness threshold: specifically, in the family, median runtime becomes superpolynomial if and only if a normalized 1-dimensional persistence statistic (such as total H1 bar length divided by number of states) exceeds a fixed constant c. Test: Construct the state graph/complex for parametrized benchmark families, compute persistence across the control parameter, and check whether the proposed barcode statistic changes sharply at the same parameter where empirical proof-search/runtime complexity jumps; a counterexample family with decoupled transitions refutes it. Impact: This would give a falsifiable topological order parameter for computational hardness, linking topology, logic, and complexity, and could enable topology-guided automated theorem proving and hardness prediction.",
    "domains": [
      "Computational Complexity",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T07:25:04.784356+00:00"
  },
  {
    "id": "fd_1708",
    "title": "Tropical Monodromy Spectrum from Prime Reductions of Integer Polynomials",
    "description": "Conjecture: There exists an explicit functor assigning to each squarefree polynomial f(x) in Z[x] of degree d at least 5 a finite filtered simplicial complex K_p(f) for every good prime p, built only from the collision/merger pattern of roots of f mod p^k across k, such that the distribution of persistent barcodes of K_p(f) over primes p determines the Galois group of f over Q up to isomorphism for all transitive subgroups of S_d outside a finite exceptional list. Test: Compute K_p(f) for large benchmark families with known Galois groups (e.g. S_d, A_d, D_d, Frobenius groups, solvable transitive groups), estimate barcode-distribution invariants across primes, and check whether non-isomorphic Galois groups become statistically separable; refutation occurs if infinitely many distinct Galois groups produce indistinguishable barcode laws under the construction. Impact: This would create a new topological-combinatorial probe of arithmetic monodromy, linking p-adic root geometry, persistence, and inverse Galois diagnostics in a way not captured by point counts or Frobenius traces alone.",
    "domains": [
      "Algebraic Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T07:26:58.980809+00:00"
  },
  {
    "id": "fd_1714",
    "title": "Primewise Persistence Recovers the Formal Group Height of K3 Surfaces",
    "description": "Conjecture: There exists an explicit functorial construction sending a polarized K3 surface X over a number field to a family of finite filtered chain complexes C_p(X) over F_p, defined for all good ordinary and supersingular primes p, such that the asymptotic primewise barcode statistics of C_p(X) determine the formal Brauer group height h(X_p) for a density-1 set of primes p. In particular, primes with finite height h produce one universal barcode regime, while supersingular primes (height infinity) produce a sharply different regime detectable by a computable statistic with error o(1) as p grows. Test: Compute the complexes for explicit K3 families with known reduction behavior (e.g. diagonal quartics, Kummer surfaces, singular K3s), compare barcode statistics against independently computed formal Brauer heights, and check whether a uniform classifier separates finite-height from supersingular reduction and further refines finite heights when known. Refutation occurs if no such statistic can distinguish these classes beyond random chance on explicit benchmark families. Impact: This would create a new bridge between arithmetic geometry, p-adic deformation invariants, and topological data analysis, potentially yielding a combinatorial probe of subtle reduction phenomena that are currently accessible only through deep crystalline/cohomological methods.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T07:27:35.868270+00:00"
  },
  {
    "id": "fd_1782",
    "title": "Prime-Interference Law for Torsion in Arithmetic Random Complexes",
    "description": "Conjecture: There exists an explicit arithmetic random simplicial-complex model X(N, p) built from reductions modulo N of a fixed algebraic construction such that the p-primary and q-primary persistent torsion birth processes are asymptotically not independent for infinitely many distinct prime pairs (p,q), and their covariance is governed by a universal bilinear form coming from shared Frobenius eigenvalue statistics of the underlying arithmetic source. Test: Construct the model for growing N, compute primewise persistence barcodes simultaneously for many prime pairs, and measure whether the joint law of torsion births deviates from the product law in a stable, model-independent way; confirmation requires reproducible nonzero limiting cross-prime covariance matching the predicted Frobenius-based statistic, while refutation is asymptotic independence or absence of a universal covariance law. Impact: This would reveal a genuinely new cross-prime coupling principle in arithmetic topology, going beyond existing primewise theories, and could provide a new bridge between persistent homology, arithmetic statistics, and motivic-style correlations across primes.",
    "domains": [
      "Arithmetic Topology",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T11:03:44.396940+00:00"
  },
  {
    "id": "fd_1783",
    "title": "Persistent Homology Detects Zero-Density Exceptional Sets in Prime Number Races",
    "description": "Conjecture: Let q >= 3 and let A,B be distinct reduced residue classes mod q with unequal Rubinstein-Sarnak bias. For each x, form the step function D_{A,B}(t)=pi(t;q,A)-pi(t;q,B) on t in [2,x], build its sublevel/superlevel persistence diagram after piecewise-linear interpolation and normalization by sqrt(t)/log t, and let M_x(A,B) be the signed barcode mass (total lifetime of positive bars minus negative bars). Then M_x(A,B) converges to a nonzero limit of the same sign as the logarithmic prime race bias, while for unbiased pairs it converges to 0. Test: compute M_x(A,B) for many q and residue pairs up to large x; confirmation is stable sign separation matching known Chebyshev biases and vanishing for unbiased races, while systematic mismatch or non-convergence refutes it. Impact: this would introduce a topological order parameter for subtle distributional asymmetries of primes, potentially giving a new quantitative probe of low-lying zero effects and a bridge between analytic number theory and topological signal analysis.",
    "domains": [
      "Analytic Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T11:04:17.028238+00:00"
  },
  {
    "id": "fd_1789",
    "title": "Persistent Homology Phase Transition for Collatz Preimage Graphs Modulo Primes",
    "description": "Conjecture: For the accelerated Collatz map T(n) = (3n+1)/2^{v_2(3n+1)} on odd integers, let G_p be the directed graph on F_p^\u00d7 obtained by reducing T modulo an odd prime p and retaining only vertices with well-defined inverse branches. Build the flag complex of the undirected symmetrization of G_p and its filtration by inverse-branch multiplicity. Then there exists a finite set of explicit congruence classes C modulo M such that, for primes p outside a zero-density exceptional set, the persistent H_1 barcode statistics of this filtration depend only on the class of p mod M; moreover at least two classes in C yield asymptotically distinct limiting barcode distributions. Test: Compute G_p and the filtered barcode for primes p up to a large bound, cluster barcode summaries by p mod M, and check whether within-class variance tends to 0 while between-class distances stay bounded away from 0; a single infinite subsequence violating congruence-class concentration refutes the conjecture. Impact: This would reveal hidden arithmetic structure in Collatz dynamics through topological statistics, creating a new bridge between discrete dynamics, modular arithmetic, and TDA, and potentially exposing modular obstructions invisible to standard orbit analysis.",
    "domains": [
      "Arithmetic Dynamics",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T11:04:47.896691+00:00"
  },
  {
    "id": "fd_1805",
    "title": "Profinite Reconstruction Threshold from Prime-by-Prime Finite Quotient Persisten",
    "description": "Conjecture: There exists an explicit functorial construction sending every finitely generated residually finite group G to a family of finite filtered simplicial complexes K_p(G,N), indexed by primes p and quotient-depth parameter N, such that if two groups G and H satisfy barcode equality for all sufficiently large p and all N, then their profinite completions are isomorphic; moreover, there exists a finitely generated pair G,H with matching barcodes for every fixed finite set of primes but different profinite completions. Test: Implement K_p(G,N) from presentations via finite p-group and mixed finite quotient towers, compute persistent homology barcodes across p,N for known families with subtle finite-quotient behavior (e.g. arithmetic groups, 3-manifold groups, nilpotent and virtually free groups), and check whether barcode coincidence tracks profinite equivalence and whether finite-prime agreement can fail to determine it. A single counterexample to the reconstruction claim refutes the first part; a proof or exhaustive positive evidence on broad classes supports it. Impact: This would create a new topological-computational interface for profinite group theory, potentially giving computable invariants for distinguishing groups via their finite quotients and linking persistent homology with anabelian-style reconstruction phenomena.",
    "domains": [
      "Geometric Group Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T12:55:04.181043+00:00"
  },
  {
    "id": "fd_1806",
    "title": "Arithmetic Universality Barrier for Primewise Persistent Encodings",
    "description": "Conjecture: There exists a natural class C of functorial assignments X \u21a6 {K_p(X)} from smooth projective varieties over Q to finite filtered chain complexes over F_p, satisfying bounded local complexity and compatibility with products and finite correspondences, such that no assignment in C can determine the full Hasse\u2013Weil zeta function of X from the collection of primewise persistent barcodes at a density-1 set of primes unless it already determines all l-adic Betti numbers and Frobenius characteristic polynomials. Test: Formalize axioms for C and attempt reconstruction on explicit non-isomorphic varieties with matching low-complexity primewise persistence data; confirmation comes from proving an obstruction theorem or constructing counterexample pairs, refutation comes from an explicit reconstruction algorithm within C recovering zeta functions beyond cohomological data. Impact: This would sharply separate what persistent-homological arithmetic encodings can and cannot capture, turning many current positive conjectures into a coherent program with clear universality limits.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T12:55:38.029549+00:00"
  },
  {
    "id": "fd_1837",
    "title": "Motivic Persistence Spectrum for Point Counts Across Extension Towers",
    "description": "Conjecture: There exists an explicit functor from a smooth projective variety X over a finite field F_q to a filtered chain complex K(X) built only from the sequence of point counts |X(F_{q^r})| for r = 1,2,...,R, such that for all sufficiently large R the resulting persistence barcode determines the multiset of Frobenius eigenvalue slopes on middle l-adic cohomology up to Tate twists, and distinguishes non-isogenous simple factors of the motive with probability 1 in natural random families. Test: Construct K(X) for computable families (elliptic curves, abelian surfaces, K3 surfaces, hypersurfaces), compare barcodes against independently computed zeta functions/Frobenius polynomials, and check whether barcode equivalence coincides with equality of the relevant slope multisets; a single infinite family with persistent collisions beyond the predicted ambiguities refutes the conjecture. Impact: This would turn raw arithmetic counting data into a topological invariant extractor for motives, creating a new bridge between persistence, Weil zeta functions, and arithmetic geometry, and potentially yielding scalable signatures for arithmetic isogeny and motivic decomposition.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T15:17:08.102158+00:00"
  },
  {
    "id": "fd_1838",
    "title": "Persistent Homology Detects the Onset of Universality in Modular Matrix Products",
    "description": "Conjecture: Let A_1, A_2, ... be i.i.d. random matrices in SL_2(Z) drawn from a fixed finitely supported measure whose support generates a non-elementary subgroup. For each prime p, reduce modulo p to obtain a random walk on SL_2(F_p), and from the first T steps build a filtered simplicial complex K_p(T) using edges weighted by first meeting times or transition frequencies between visited group elements. There exists a universal scaling window T = C log p such that, as p -> infinity, the prime-indexed barcode statistics of K_p(T) undergo a sharp transition: below the window they retain measure-dependent signatures, while above it they converge to a measure-independent limit depending only on the ambient group family SL_2(F_p). Test: simulate several distinct generating measures with the same Zariski-dense support type, compute persistence summaries of K_p(T) for growing p and T, and check whether barcode distributions collapse to a common law precisely near T/log p = C. Refutation occurs if no such common collapse exists or if the limiting statistics remain measure-specific. Impact: This would give a new topological observable for cutoff/universality in nonabelian random walks, linking expansion, arithmetic reduction, and TDA in a way that could transfer to higher-rank groups and mixing certification.",
    "domains": [
      "Arithmetic Dynamics",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T15:17:42.180261+00:00"
  },
  {
    "id": "fd_1839",
    "title": "Primewise Persistence Detects Langlands Functorial Transfer in Symmetric-Power F",
    "description": "Conjecture: Let E/Q be a non-CM elliptic curve and for each good prime p let theta_p in [0,pi] be defined by a_p(E)=2 sqrt(p) cos(theta_p). For each m>=1, build a finite filtered complex K_{m,p} functorially from the first N normalized local coefficients of Sym^m(E) mod p (equivalently from the sequence U_m(cos(theta_{p^r})) for 1<=r<=N, discretized uniformly in r and value). Then there exists m_0 such that, for infinitely many pairs of elliptic curves E,F with non-isogenous E,F, the family of prime-indexed persistence summaries of K_{m,p}(E) and K_{m,p}(F) agree for all m<m_0 on a density-1 set of p, but differ for m=m_0 on a positive-density set of p if and only if Sym^{m_0}(E) and Sym^{m_0}(F) are not in the same automorphic transfer class. Test: Compute these persistence summaries for databases of elliptic curves and compare against known/expected symmetric-power and automorphic invariants; the conjecture is refuted if no such separating m_0 exists or if persistence disagrees systematically with known transfer equivalences. Impact: This would propose a topological detector for hidden automorphic structure, giving a new computational bridge between persistent homology, Frobenius statistics, and Langlands functoriality.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T15:18:19.506050+00:00"
  },
  {
    "id": "fd_1841",
    "title": "Galois Monodromy from Persistent Homology of Newton Polytopes Across Prime Reduc",
    "description": "Conjecture: There exists an explicit functor that assigns to each squarefree polynomial f in Z[x1,...,xn] a family of finite filtered complexes K_p(f), built canonically from the lower faces of the p-adically weighted Newton polytope of f mod p, such that for a Zariski-dense class of f the distribution of prime-indexed persistence barcodes determines the Galois group of the splitting field of f over Q up to isomorphism. Test: Compute K_p(f) for large prime samples across families with known Galois groups (for example generic S_n, A_n, dihedral, and solvable families), extract barcode statistics, and check whether distinct Galois groups give asymptotically separable persistence signatures; a counterexample is a pair of infinite families with different Galois groups but indistinguishable limiting barcode laws. Impact: This would create a new topological probe of arithmetic monodromy, linking computational algebraic geometry, p-adic geometry, and topological data analysis, and could enable new invariants for black-box polynomial and number field classification.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T15:18:51.290763+00:00"
  },
  {
    "id": "fd_1906",
    "title": "Persistent Homology Detects Nontriviality of Stable Homotopy Classes via Framed ",
    "description": "Conjecture: There exists an explicit functor from any finite framed flow category presenting a stable homotopy class \u03b1 \u2208 \u03c0_n^S to a finite family of filtered chain complexes over Z whose primewise persistent barcode profile is complete enough to distinguish the zero class from infinitely many nonzero classes of the same Adams filtration and stem. In particular, for an infinite family of nontrivial classes \u03b1_k and comparison null classes \u03b2_k with identical classical numerical invariants available at the chain level (rank data, mod-p Betti tables, and Euler characteristics), the associated primewise persistence profiles differ for at least one prime and one homological degree. Test: Construct the complexes for computable families coming from known framed flow-category models (for example low-stem Toda-bracket families or v1-periodic families), compute the induced primewise barcodes, and check whether nontrivial classes are separated from null classes with matched basic invariants. A single infinite family where separation consistently occurs supports the conjecture; a counterfamily with indistinguishable profiles refutes it. Impact: This would create a new computable bridge between persistent homology and stable homotopy theory, potentially yielding topological invariants sensitive to subtle secondary composition phenomena beyond ordinary homology and opening a data-driven route to detecting hidden structure in spectra.",
    "domains": [
      "Algebraic Topology",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T19:32:30.694451+00:00"
  },
  {
    "id": "fd_1912",
    "title": "Persistent Homology of Modular Continued-Fraction Dynamics Detects Quadratic Irr",
    "description": "Conjecture: There exists an explicit functor assigning to each real number x in (0,1) given by an oracle for its continued-fraction digits, and each prime p, a finite filtered graph or simplicial complex K_p(x,N) built from the first N convergents modulo p, such that x is quadratic irrational if and only if, for every sufficiently large prime p outside a zero-density exceptional set, the primewise barcode statistics of K_p(x,N) are eventually periodic in N with period bounded independently of p. Test: Construct K_p(x,N) from convergents q_n/p_n mod p and compare barcode sequences as N grows for quadratic irrationals versus cubic irrationals, e, pi-like constants, and random reals; confirmation is uniform eventual periodicity only in the quadratic irrational case, refutation is a non-quadratic example with the same periodic persistence signature or a quadratic irrational lacking it. Impact: This would create a topological/dynamical characterization of algebraic degree 2, linking Diophantine approximation, automata-like periodicity, and primewise topological invariants, and could open a new route to detecting algebraicity from finite modular data.",
    "domains": [
      "Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T19:57:26.686875+00:00"
  },
  {
    "id": "fd_1918",
    "title": "p-adic Stability Radius Governs Integral Persistence Reconstruction",
    "description": "Conjecture: For every finite filtered chain complex C over Z with boundary matrices of total bit-size N, there exists a computable arithmetic invariant R(C) = sup_p p^{-vp(det M_C)} built from a finite set of Smith-minor valuations of the boundary maps, such that any filtered chain complex D with matching primewise persistence data for all primes p <= N^c and bottleneck distance < R(C)/10 in every such prime-local barcode must be integrally filtered-chain equivalent to C. Test: Compute R(C) explicitly for broad families (random filtered complexes, clique/flag complexes, arithmetic examples), then search for counterexamples D with identical small-prime persistence but distinct integral homotopy type; the conjecture is refuted by one such family and supported if reconstruction always succeeds once the prime cutoff exceeds the predicted threshold. Impact: This would turn scattered primewise persistence information into a sharp arithmetic reconstruction principle, giving the first quantitative boundary between local barcode data that is sufficient versus insufficient to recover global integral topology.",
    "domains": [
      "Topological Data Analysis",
      "Arithmetic Topology"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T19:57:56.338721+00:00"
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
    "id": "fd_1919",
    "title": "\"Why now?\"",
    "description": "The formal verification of energy positivity and the bilinear form structure ensures that the kernel matrix is non-degenerate (after removing the constant mode), which is the essential condition for the determinant formula to hold.",
    "domains": [
      "Physics"
    ],
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "ce4c226e",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T19:58:25.943481+00:00"
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
