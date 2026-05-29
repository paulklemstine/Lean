

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
    "id": "fd_1927",
    "title": "Direction 3: Phase Transition Detection via Hessian Rank Degeneration",
    "description": "**Conjecture:** The critical temperature \u03b2_c of the ferromagnetic Ising model on a sequence of growing graphs (e.g., boxes in Z^d) can be detected as the value of \u03b2 where the multiaffine Hessian of the partition polynomial undergoes a rank transition: the number of eigenvalues exceeding a threshold changes discontinuously (in the infinite-volume limit).\n\n**Test:** For the Ising model on L \u00d7 L square lattices (L = 3, 4, 5, 6), compute the Hessian eigenvalue distribution at \u03b2 values bracketing the known critical point \u03b2_c = ln(1+\u221a2)/2. Track the fraction of eigenvalues above various thresholds and test for finite-size scaling consistent with a rank transition.\n\n**Impact:** Would provide a novel algebraic criterion for phase transitions, distinct from the standard thermodynamic (free energy singularity) and probabilistic (correlation length divergence) criteria. Could lead to algorithms for detecting phase transitions from finite-size polynomial data.\n\n**Catalog References:**\n- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` \u2014 Hessian structure\n- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean` \u2014 spectral gap degradation near criticality\n\n**Proof Strategy:** Use the Newton inequality threshold (Theorem 7) as a prototype: for two spins, the threshold \u03b2_c = ln 2 / J is exact. For general graphs, establish that the threshold for the first Newton inequality failure converges to the true critical temperature as graph size grows.\n\n**Domain Bridges:** Statistical physics \u2194 Random matrix theory \u2194 Spectral graph theory\n\n**Lineage:** Extends Theorem 7 (levelWeight\u2082_newton_iff) from two spins to general graphs.\n\n**Ambition:** grand_challenge \u2014 Would create a new algebraic approach to critical phenomena.\n\n---",
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
    "source_exp_id": "37e69c75",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T20:34:24.933104+00:00"
  },
  {
    "id": "fd_1959",
    "title": "Direction 1: Spectral Stability for Graphic Matroids via Kirchhoff Hessians",
    "description": "**Conjecture:** The quadratic leaves of the Kirchhoff polynomial (basis generating polynomial of the cycle matroid of a graph $G$) have Hessian spectral gap bounded below by the algebraic connectivity $\\lambda_2(G)$ of the graph Laplacian.\n\n**The key insight is** that the Kirchhoff polynomial $\\tau(x) = \\sum_{T \\text{ spanning tree}} \\prod_{e \\in T} x_e$ encodes all spanning trees, and its quadratic leaves should inherit spectral properties from the graph's connectivity structure. Unlike partition matroids, which decompose into independent blocks, graphic matroids have cycles creating complex dependencies \u2014 but the Laplacian eigenvalues might still control the leaf Hessian spectrum.\n\n**Test:** Compute quadratic leaf Hessians for complete graphs $K_n$ ($n = 3, \\ldots, 8$), cycle graphs $C_n$, and grid graphs. For each, compare the minimum negative eigenvalue of all leaf Hessians to $\\lambda_2(G)$. If the ratio is bounded below by a universal constant, the conjecture stands.\n\n**Impact:** Would extend certified spectral stability from block-decomposable (partition) matroids to the most important non-decomposable family, opening applications in network reliability, electrical flow computation, and random spanning tree sampling.\n\n**Catalog References:**\n- `Catalog/Pythagorean/PartitionMatroidStability.lean` (leaf classification method)\n- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (perturbation framework)\n\n**Proof Strategy:** Strategy A \u2014 explicit Hessian computation using the matrix-tree theorem and Cauchy-Binet formula. The quadratic leaves of the Kirchhoff polynomial should relate to minors of the edge-vertex incidence matrix, connecting leaf spectra to graph Laplacian spectra via Schur complements.\n\n**Domain Bridges:** Network engineering (fault tolerance), statistical physics (random cluster model), machine learning (graph neural network expressivity).\n\n**Lineage:** Direct extension of partition matroid theory to non-decomposable matroids.\n\n**Ambition:** Grand challenge \u2014 would unify spectral graph theory with Lorentzian polynomial theory.\n\n---",
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
    "source_exp_id": "44a490ac",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T23:28:59.182504+00:00"
  },
  {
    "id": "fd_1960",
    "title": "Direction 2: Weighted Perturbation Theory for Rank-Deficient Leaves",
    "description": "**Conjecture:** For two-block bilinear leaves with kernel dimension $k = n_1 + n_2 - 2$, there exists a weighted norm $\\|\\cdot\\|_W$ such that the two-block Hessian has gapped signature with gap $\\gamma > 0$ under $\\|v\\|_W$, with $\\gamma = 2 n_1 n_2 / (n_1 + n_2)$ (the harmonic mean).\n\n**The key insight is** that the zero spectral gap for two-block leaves (when $n_1 + n_2 > 2$) is an artifact of using the Euclidean norm. The rank-2 Hessian concentrates its action on a 2-dimensional subspace; a norm that weights this subspace more heavily would recover a positive gap. The harmonic mean $2n_1 n_2/(n_1+n_2)$ is the natural candidate because it balances the block sizes.\n\n**Test:** For two-block Hessians with $(n_1, n_2) \\in \\{(1,2), (2,2), (2,3), (3,3), (5,5)\\}$, compute the optimal weight matrix $W$ that maximizes the gap in the definition $Q_H(v) \\leq -\\gamma \\cdot v^T W v$ on $w_W^\\perp$. Verify whether $\\gamma = 2n_1 n_2/(n_1+n_2)$ is achievable.\n\n**Impact:** Would complete the quantitative stability theory for partition matroids by providing certified perturbation radii for *all* leaf types, not just single-block leaves.\n\n**Catalog References:**\n- `Catalog/Pythagorean/PartitionMatroidStability.lean` (two-block Hessian structure)\n- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (`HasGappedSignature`)\n\n**Proof Strategy:** Optimize over positive-definite weight matrices $W$. The optimal $W$ should be block-diagonal with entries $1/n_1$ on block 1 and $1/n_2$ on block 2, making the weighted Cauchy-Schwarz bound tight.\n\n**Domain Bridges:** Optimization (weighted SDP relaxations), statistics (weighted covariance estimation), signal processing (whitening transforms).\n\n**Lineage:** Fills the gap identified in the current partition matroid theory.\n\n**Ambition:** Solid extension \u2014 completes the quantitative picture for partition matroids.\n\n---",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Physics",
      "Bridges",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "44a490ac",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T23:28:59.322294+00:00"
  },
  {
    "id": "fd_1961",
    "title": "Direction 3: Lorentzian Product Calculus \u2014 A General Spectral Composition Law",
    "description": "**Conjecture:** If $f$ and $g$ are Lorentzian polynomials on disjoint variable sets with quadratic-leaf spectral gaps $\\varepsilon_f$ and $\\varepsilon_g$, then every quadratic leaf of $fg$ has at most one positive eigenvalue, and single-factor leaves have gap $\\min(\\varepsilon_f, \\varepsilon_g)$.\n\n**The key insight is** that our partition matroid classification (single-block vs. two-block) is really a theorem about products of polynomials on disjoint variable sets. The same dichotomy should hold for *any* Lorentzian product: leaves are either single-factor (inheriting the gap from one factor) or cross-factor (bilinear, with at most one positive eigenvalue).\n\n**Test:** Take $f = e_2(x_1, x_2, x_3)$ and $g = x_1^2 + x_2^2 + x_1 x_2$ (a non-symmetric Lorentzian polynomial on disjoint variables). Compute all quadratic leaves of $fg$ and verify the spectral gap predictions.\n\n**Impact:** Would establish a general product rule for Lorentzian spectral stability, applicable far beyond matroids \u2014 to strongly log-concave distributions, hyperbolic polynomials, and any compositional algebraic structure.\n\n**Catalog References:**\n- `Catalog/Pythagorean/PartitionMatroidStability.lean` (prototype: partition = product of elementary symmetric)\n- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (perturbation stability)\n\n**Proof Strategy:** Generalize the leaf classification from integer-valued residual degrees to the product setting. The key step is showing that cross-factor leaves factor as (linear in factor 1) \u00d7 (linear in factor 2), hence have rank-2 Hessians.\n\n**Domain Bridges:** Algebraic geometry (hyperbolic polynomials), quantum information (entanglement witnesses), control theory (stability of interconnected systems).\n\n**Lineage:** Grand generalization of partition matroid theory to arbitrary Lorentzian products.\n\n**Ambition:** Grand challenge \u2014 would be a foundational result in Lorentzian polynomial theory.\n\n---",
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
    "source_exp_id": "44a490ac",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T23:28:59.421709+00:00"
  },
  {
    "id": "fd_2057",
    "title": "The holographic coding geometry framework establishes a formally verified bridge",
    "description": "# Future Directions: Holographic Coding Geometry\n\n## Synthesis\n\nThe holographic coding geometry framework establishes a formally verified bridge between information theory, coding theory, and discrete geometry. The core insight \u2014 that the Ryu-Takayanagi relation converts entropy submodularity into area submodularity and vice versa \u2014 opens a systematic research program. The five directions below explore progressively deeper consequences of this bridge, from immediate extensions (graph-cut models, higher-order curvature) through ambitious conjectures (polymatroid holography, emergent metric spaces) to a grand challenge connecting coding geometry to computational complexity. Each direction builds on the verified theorems in `Catalog/Speculative/HolographicCoding.lean` and is designed to be both daring enough to reshape a field and specific enough to fail.\n\n---\n\n## Direction 1: Graph-Cut Holographic Models\n\n**Conjecture:** For any finite weighted graph G = (V, E, w) with boundary vertices B \u2282 V, the min-cut entropy function S_G(X) = mincut(X, B\\X) for X \u2286 B satisfies the holographic code profile axioms (submodularity, nonnegativity, normalization). Furthermore, the induced syndrome defect equals the discrete Gaussian curvature of the dual graph.\n\n**Test:** Implement min-cut entropy computation on random weighted planar graphs with n \u2264 20 boundary vertices. Check the holographic axioms. Compute syndrome defects and compare to known graph curvature measures (Ollivier-Ricci, Forman curvature). Report the correlation coefficient.\n\n**Impact:** If confirmed, this would provide an infinite family of constructive holographic models, each realizing the abstract axioms through concrete graph geometry. It would also establish a dictionary between network flow theory and holographic entropy.\n\n**The key insight is** that min-cut functions on graphs are known to be submodular (Fujishige, 2005), so the main content of the conjecture is the relationship between min-cut syndrome defects and graph curvature \u2014 a connection that has never been explored.\n\n**Why now?** The formalized framework provides the first rigorous target for graph-cut models: any graph that satisfies the HolographicCodeProfile axioms is a legitimate holographic geometry. Combined with existing Mathlib graph theory, this is now within reach of formal verification.\n\n**Catalog References:** `Catalog/Speculative/HolographicCoding.lean` (HolographicCodeProfile, syndromeDefect_nonneg, area_submod_of_rt)\n\n**Proof Strategy:** Use Mathlib's `SimpleGraph` and flow/cut infrastructure. Prove min-cut submodularity directly using the lattice structure of s-t cuts. Then define the graph-induced holographic profile and verify the axioms.\n\n**Domain Bridges:** Graph theory \u2194 Holography, Network flows \u2194 Entropy inequalities, Discrete differential geometry \u2194 Information theory\n\n**Lineage:** Extends the bridge theorem (rt_submodularity_iff_area_submodularity) from abstract profiles to constructive graph models.\n\n**Ambition:** Solid extension \u2014 builds directly on existing infrastructure.\n\n---\n\n## Direction 2: Higher-Order Syndrome Defects and Ricci Curvature\n\n**Conjecture:** Define higher-order syndrome defects \u03b4_k for k-tuples of regions by the inclusion-exclusion M\u00f6bius function on the partition lattice. Then \u03b4\u2082 = syndromeDefect (pairwise curvature), \u03b4\u2083 captures a discrete analogue of sectional curvature, and a weighted sum \u2211_k \u03b4_k gives a discrete Ricci-like scalar. Conjecture: this Ricci scalar is nonneg for holographic profiles and vanishes iff S is modular.\n\n**Test:** Compute \u03b4\u2083 and the Ricci scalar for all entropy profiles on {0,1,2,3,4}. Check nonnegativity. Compare to known discrete Ricci curvature measures on the Cayley graph of subsets.\n\n**Impact:** This would create a systematic \"curvature hierarchy\" from information constraints, paralleling the Riemannian hierarchy (Gauss \u2192 sectional \u2192 Ricci \u2192 scalar). It would be the first purely information-theoretic definition of discrete Ricci curvature.\n\n**The key insight is** that the syndrome defect \u03b4\u2082 already behaves like Gaussian curvature (nonneg, vanishes for flat geometry). Higher-order analogues should capture finer geometric structure of the entropy function.\n\n**Why now?** The formalized syndrome defect provides a rigorous starting point. Extending to higher orders requires only finset combinatorics and the M\u00f6bius function on finite lattices, both available in Mathlib.\n\n**Catalog References:** `Catalog/Speculative/HolographicCoding.lean` (syndromeDefect, syndromeDefect_nonneg, modular_of_zero_syndrome)\n\n**Proof Strategy:** Define \u03b4\u2083(X,Y,Z) = \u03a3 (-1)^{|S|+1} S(\u2229_{i\u2208S} X_i) over subsets S \u2286 {X,Y,Z}. Prove nonnegativity from submodularity using the Lov\u00e1sz extension or direct combinatorial argument. For the Ricci scalar, sum \u03b4\u2082 over all pairs weighted by cardinality.\n\n**Domain Bridges:** Combinatorial optimization \u2194 Riemannian geometry, Information theory \u2194 Differential geometry\n\n**Lineage:** Direct generalization of syndromeDefect_nonneg to higher orders.\n\n**Ambition:** Grand challenge \u2014 establishing a complete curvature hierarchy from information is paradigm-shifting.\n\n---\n\n## Direction 3: Polymatroid Holography and the Holographic Entropy Cone\n\n**Conjecture:** The set of all HolographicCodeProfile entropy vectors (S(X))_{X \u2286 [n]} forms a polyhedral cone C_n^{holo} that is a proper subcone of the polymatroid cone P_n. Furthermore, C_n^{holo} coincides with the holographic entropy cone defined by Bao et al. (2015) for n \u2264 5, and the facets of C_n^{holo} correspond to RT-realizable entropy inequalities.\n\n**Test:** Enumerate all extreme rays of C_n^{holo} for n = 3, 4 using linear programming. Compare to the known holographic entropy cone facets. Check whether every extreme ray can be realized by a graph-cut model.\n\n**Impact:** This would place holographic coding geometry inside the theory of convex cones and polyhedral combinatorics, connecting to matroid theory and optimization. It would answer the question \"which entropy profiles are holographic?\" precisely.\n\n**The key insight is** that the HolographicCodeProfile axioms define a system of linear inequalities on the entropy vector, carving out a polyhedral cone. The RT relation adds a linear constraint, and the singleton-like bound adds further inequalities. The resulting cone should be computable.\n\n**Why now?** The formalized axioms provide exact inequality constraints. Linear programming solvers can compute the cone for small n. Comparison to the Bao et al. holographic entropy cone provides a well-defined theoretical target.\n\n**Catalog References:** `Catalog/Speculative/HolographicCoding.lean` (HolographicCodeProfile, submod_S, rt_relation, singleton_like)\n\n**Proof Strategy:** Formalize polymatroid cones in Lean using Mathlib's polyhedral cone infrastructure. Define the holographic subcone as the intersection of submodularity, RT, and singleton constraints. Prove containment C_n^{holo} \u2286 P_n. For small n, compute extreme rays and compare.\n\n**Domain Bridges:** Convex geometry \u2194 Quantum information, Matroid theory \u2194 Holography, Linear programming \u2194 Physics\n\n**Lineage:** Extends the bridge theorem to a global structural statement about the space of all holographic profiles.\n\n**Ambition:** Grand challenge \u2014 full characterization of the holographic entropy cone is a major open problem in quantum information.\n\n---\n\n## Direction 4: Approximate Reconstruction and Petz Recovery\n\n**Conjecture:** Define an approximate version of Reconstructable using \u03b5-closeness: U is \u03b5-reconstructable in X if there exists a recovery channel R such that ||R \u2218 E_X - id|| < \u03b5, where E_X is the erasure of X^c. Then reconstruction monotonicity extends to the approximate setting: if U is \u03b5-reconstructable in X and X \u2286 Y, then U is \u03b5-reconstructable in Y (with the same or better \u03b5).\n\n**Test:** In a finite-dimensional quantum channel model, compute the Petz recovery fidelity for random quantum states and check monotonicity in the boundary region size. Implement for qubit systems of size \u2264 8.\n\n**Impact:** This would connect the abstract combinatorial framework to operational quantum information theory, making the reconstruction theorem physically meaningful for noisy systems.\n\n**The key insight is** that exact reconstruction (|U| < D(U)) is an idealization. Real holographic codes have approximate reconstruction with fidelity that improves as the boundary region grows. The monotonicity theorem should extend to this approximate setting.\n\n**Why now?** Recent results on approximate quantum error correction (Junge, Renner, et al.) provide the analytical tools. The formalized exact reconstruction theorem gives the structural skeleton. Combining them requires formalizing quantum channels in Lean, which is now feasible.\n\n**Catalog References:** `Catalog/Speculative/HolographicCoding.lean` (Reconstructable, reconstructable_monotone)\n\n**Proof Strategy:** Define quantum channels as completely positive trace-preserving maps. Formalize the Petz recovery map. Prove approximate monotonicity using the data processing inequality.\n\n**Domain Bridges:** Quantum information theory \u2194 Holography, Operator algebras \u2194 Coding theory\n\n**Lineage:** Extends reconstructable_monotone from exact to approximate reconstruction.\n\n**Ambition:** Solid extension \u2014 builds on well-established quantum information theory.\n\n---\n\n## Direction 5: Emergent Metric Spaces from Syndrome Defects\n\n**Conjecture:** Define a distance-like function on boundary regions by d(X,Y) = syndromeDefect(H, X, Y). Then for holographic profiles arising from graph-cut models, the function d (or a monotone transformation of d) satisfies a modified triangle inequality and induces a pseudometric on the power set of boundary sites. The resulting metric space recovers the original graph metric up to bounded distortion.\n\n**Test:** For random planar graphs with n \u2264 15 vertices, compute d(X,Y) for all singleton pairs X={x}, Y={y}. Check whether d({x},{y}) approximates the graph distance d_G(x,y). Compute the distortion ratio max(d/d_G, d_G/d) and report statistics.\n\n**Impact:** If confirmed, this would complete the holographic circle: information constraints (submodularity) \u2192 curvature (syndrome defect) \u2192 metric geometry (emergent distances) \u2192 spatial structure. This would be a precise realization of \"spacetime from entanglement.\"\n\n**The key insight is** that the syndrome defect already measures how much two regions \"interact\" informationally. In a geometric model, this interaction should decrease with distance. So the defect function should approximate a metric \u2014 but proving this requires a non-trivial structural theorem about how min-cuts relate to graph distances.\n\n**Why now?** The formalized defect computation and the graph-cut model (Direction 1) provide the two necessary ingredients. Computing distortion ratios for small graphs is straightforward. If the conjecture holds for small cases, it motivates a general proof.\n\n**Catalog References:** `Catalog/Speculative/HolographicCoding.lean` (syndromeDefect, syndromeDefect_nonneg, syndromeDefect_symm, syndromeDefect_self)\n\n**Proof Strategy:** For graph-cut models, express the syndrome defect in terms of min-cuts. Use the max-flow min-cut theorem to relate min-cuts to connectivity. Prove the pseudometric property using the lattice structure of cuts. For distortion bounds, use expander mixing lemma-type arguments.\n\n**Domain Bridges:** Metric geometry \u2194 Information theory, Graph theory \u2194 General relativity, Theoretical computer science \u2194 Physics\n\n**Lineage:** Synthesizes all previous directions \u2014 graph models (1), curvature hierarchy (2), polymatroid structure (3), and reconstruction (4) \u2014 into a single emergent geometry.\n\n**Ambition:** Grand challenge \u2014 deriving spatial geometry from pure information is the ultimate goal of the holographic program.\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
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
    "source_exp_id": "5cb2654a",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T05:36:29.046168+00:00"
  },
  {
    "id": "fd_2058",
    "title": "The theory of Escher filtrations \u2014 strictly descending ideal chains with trivial",
    "description": "# Future Directions: Escher Filtrations\n\n## Synthesis\n\nThe theory of Escher filtrations \u2014 strictly descending ideal chains with trivial intersection \u2014 opens a new quantitative lens on commutative ring structure. Our foundational results establish that the invariant is nontrivial (\u2124 has infinite Escher height), discriminating (fields have none), orthogonal to Noetherianity, and bridges algebra to geometry (polynomial X-adic filtrations). The directions below push this framework in five specific ways: (1) a dimension-sensitive refinement via independent Escher rank, (2) quantitative filtration spectra connecting to Hilbert functions, (3) non-Noetherian territory where the invariant diverges from classical theory, (4) a bridge to p-adic analysis and rigid geometry, and (5) a categorical generalization to filtrations on modules and derived categories. Each direction is chosen to be independently falsifiable and to connect the Escher framework to an existing mathematical domain, ensuring that progress in any single direction enriches the whole program.\n\n---\n\n## Direction 1: Independent Escher Rank and Krull Dimension\n\n**Conjecture:** For a field $k$, define the *independent Escher rank* $\\mathrm{eirank}(R)$ as the supremum of $m$ such that there exist elements $a_1, \\ldots, a_m \\in R$ with: (i) each sequence $(a_i^n)_{n \\geq 0}$ is an Escher filtration, and (ii) the joint filtration $E(\\mathbf{n}) = (a_1^{n_1} \\cdots a_m^{n_m})$ has vanishing core. Then $\\mathrm{eirank}(k[X_1, \\ldots, X_d]) = d$.\n\n**Test:** Formalize $\\mathrm{eirank}$ and prove $\\mathrm{eirank}(k[X_1, \\ldots, X_d]) \\geq d$ by exhibiting the coordinate filtrations. For the upper bound, attempt to show that $d+1$ independent filtrations force a contradiction via dimension theory. Compute $\\mathrm{eirank}$ for $k[X,Y]/(XY)$ and verify it equals 1 (matching Krull dimension) or discover it does not.\n\n**Impact:** If $\\mathrm{eirank} = \\dim_{\\mathrm{Krull}}$ for Noetherian domains, this gives a new characterization of Krull dimension entirely in terms of filtration complexity, without reference to prime ideal chains. This would unify ideal-theoretic and topological perspectives on dimension.\n\n**Catalog References:** `Speculative/EscherFiltration.lean` \u2014 Theorem `polynomial_X_powers_isEscherFiltration`, Theorem `powers_isEscherFiltration_of_separated`\n\n**Proof Strategy:** Lower bound by exhibiting coordinate filtrations (direct from Theorem 6.1). Upper bound by showing that $m > d$ independent elements must satisfy an algebraic relation, forcing a collapse in one of the filtrations. Use Noether normalization to reduce to the polynomial case.\n\n**Domain Bridges:** Algebraic geometry (Krull dimension), commutative algebra (prime avoidance, Noether normalization)\n\n**Lineage:** Extends Theorem 6.1 (polynomial X-adic filtration) to multivariate setting\n\n**Ambition:** Grand challenge \u2014 would redefine how we understand algebraic dimension\n\n---\n\n## Direction 2: Escher Spectra and Hilbert Functions\n\n**Conjecture:** For an Escher filtration $E$ on a Noetherian local ring $(R, \\mathfrak{m})$ with residue field $k$, define the *Escher spectrum* as the sequence $s_E(n) = \\dim_k(E(n)/E(n+1))$. For the $\\mathfrak{m}$-adic filtration, $s_E(n)$ recovers the Hilbert function. Conjecture: the set of realizable Escher spectra characterizes the ring up to completion.\n\n**Test:** Compute $s_E(n)$ for:\n- $(2^n\\mathbb{Z})$ on $\\mathbb{Z}_{(2)}$: expect $s_E(n) = 1$ for all $n$.\n- $(X^n)$ on $k[[X]]$: expect $s_E(n) = 1$ for all $n$.\n- $(\\mathfrak{m}^n)$ on $k[[X,Y]]$: expect $s_E(n) = n+1$ (Hilbert function).\nVerify computationally for small $n$. Attempt to find two non-isomorphic rings with identical Escher spectra for the maximal ideal filtration, or prove this is impossible.\n\n**Impact:** Would establish Escher spectra as a refinement of Samuel multiplicities and Hilbert\u2013Samuel polynomials, providing new invariants for singularity theory.\n\n**Catalog References:** `Speculative/EscherFiltration.lean` \u2014 Definition `HasVanishingCore`, `IsEscherFiltration`\n\n**Proof Strategy:** For the $\\mathfrak{m}$-adic case, use the standard theory of associated graded rings: $\\mathrm{gr}_{\\mathfrak{m}}(R) = \\bigoplus_n \\mathfrak{m}^n/\\mathfrak{m}^{n+1}$. For general Escher filtrations, define a generalized associated graded and study its Hilbert series.\n\n**Domain Bridges:** Singularity theory, algebraic geometry (Hilbert functions, Samuel multiplicities), commutative algebra (associated graded rings)\n\n**Lineage:** Builds on all foundational theorems; refines the coarse invariant (infinite Escher height) into a graded one\n\n**Ambition:** Solid extension \u2014 connects to well-established theory but from a new angle\n\n---\n\n## Direction 3: Escher Filtrations in Non-Noetherian Rings\n\n**Conjecture:** Let $V$ be a rank-2 valuation ring (e.g., the valuation ring of a rank-2 valued field). Then $V$ admits Escher filtrations corresponding to each component of the value group, and these filtrations are \"nested\" in a way that reflects the rank structure. Specifically, the independent Escher rank of a rank-$r$ valuation ring equals $r$.\n\n**Test:** Construct an explicit rank-2 valuation ring (e.g., the ring of Hahn series $k((t^\\mathbb{Q}))$ with a lexicographic extension) and verify that it admits two independent Escher filtrations. Test whether the joint vanishing core holds. Attempt to construct a third independent filtration and show it fails.\n\n**Impact:** Would extend the Escher framework beyond the Noetherian world, where Krull's Intersection Theorem no longer applies and the separation property must be verified by hand. This is where the Escher perspective diverges most sharply from classical commutative algebra.\n\n**Catalog References:** `Speculative/EscherFiltration.lean` \u2014 Theorem `powers_isEscherFiltration_of_separated` (the separation hypothesis is non-automatic in the non-Noetherian case)\n\n**Proof Strategy:** Use the structure theory of valuation rings and their value groups. A rank-$r$ valuation ring has a chain of $r$ prime ideals, each generating a filtration. Prove vanishing core using the Archimedean property within each rank component.\n\n**Domain Bridges:** Valuation theory, non-Archimedean analysis, model theory of valued fields\n\n**Lineage:** Extends Theorem 5.1 to the setting where the separation hypothesis becomes the key challenge\n\n**Ambition:** Solid extension \u2014 fills an important gap in the theory\n\n---\n\n## Direction 4: p-adic Escher Towers and Rigid Geometry\n\n**Conjecture:** For a smooth rigid analytic variety $X$ over $\\mathbb{Q}_p$, the coordinate ring admits Escher filtrations whose independent rank equals the dimension of $X$. Moreover, the Escher spectrum of the maximal ideal filtration at a point $x \\in X$ detects the singularity type of $x$.\n\n**Test:** Compute for the rigid analytic unit disc $\\mathrm{Sp}(\\mathbb{Q}_p\\langle T \\rangle)$: the $T$-adic filtration should be an Escher filtration with constant spectrum 1 (smooth point). For the node $\\mathrm{Sp}(\\mathbb{Q}_p\\langle X,Y\\rangle/(XY))$, the spectrum should differ. Implement these computations in Python using truncated power series arithmetic.\n\n**Impact:** Would establish Escher filtrations as a tool in $p$-adic geometry, providing a purely algebraic detector of analytic properties. This connects the theory to the Langlands program (through local models) and to $p$-adic Hodge theory (through filtrations on period rings).\n\n**Catalog References:** `Speculative/EscherFiltration.lean` \u2014 Theorem `int_twopow_isEscherFiltration` (the foundational $p$-adic example), Theorem `polynomial_X_powers_isEscherFiltration` (the geometric template)\n\n**Proof Strategy:** Use Tate algebra machinery and the Weierstrass preparation theorem. For the smooth case, reduce to the polynomial case via Noether normalization for affinoid algebras. For singularity detection, relate the Escher spectrum to the tangent cone.\n\n**Domain Bridges:** p-adic analysis, rigid analytic geometry, singularity theory, arithmetic geometry\n\n**Lineage:** Combines the arithmetic (Theorem 3.1) and geometric (Theorem 6.1) threads of the foundational theory\n\n**Ambition:** Grand challenge \u2014 connects to major programs in number theory and geometry\n\n---\n\n## Direction 5: Categorical Escher Filtrations and Derived Categories\n\n**Conjecture:** Define an *Escher filtration on a module* $M$ as a strictly descending chain of submodules with trivial intersection. The *Escher dimension* of $M$ is the supremum of independent Escher ranks over all filtrations. Conjecture: for a finitely generated module $M$ over a Noetherian local ring, $\\mathrm{edim}(M) = \\dim(\\mathrm{Supp}(M))$.\n\n**Test:** Compute $\\mathrm{edim}$ for:\n- $M = R/\\mathfrak{p}$ for a prime $\\mathfrak{p}$: expect $\\mathrm{edim} = \\dim(R/\\mathfrak{p})$.\n- $M = R/I$ for a non-prime $I$: compare with $\\dim(\\mathrm{Supp}(R/I))$.\n- $M = k[X,Y]/(X^2, XY)$: this is a module supported on a line with an embedded point; check whether $\\mathrm{edim}$ sees the embedding.\n\n**Impact:** Would extend Escher theory from rings to modules and eventually to derived categories, creating a filtration-based approach to homological dimension theory. The connection to support dimension would link Escher theory to the tensor triangular geometry program.\n\n**Catalog References:** `Speculative/EscherFiltration.lean` \u2014 all definitions and theorems (provide the ring-level foundation)\n\n**Proof Strategy:** For the ring case ($M = R$), reduce to Direction 1. For general modules, use the theory of associated primes and primary decomposition to decompose $M$ into components, each supported on an irreducible variety, and construct independent filtrations from the coordinate functions of these varieties.\n\n**Domain Bridges:** Homological algebra, derived categories, tensor triangular geometry, algebraic K-theory\n\n**Lineage:** Generalizes the entire framework from ideals in rings to subobjects in abelian categories\n\n**Ambition:** Grand challenge \u2014 if successful, would establish Escher theory as a new framework in homological algebra\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Bridges",
      "MachineLearning",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "e16cf60e",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T05:36:49.634691+00:00"
  },
  {
    "id": "fd_2059",
    "title": "The proof dynamics framework established in this work \u2014 with its well-founded de",
    "description": "# Future Directions: Proof Dynamics\n\n## Synthesis\n\nThe proof dynamics framework established in this work \u2014 with its well-founded descent, semantic invariance, discrete Lyapunov structure, and executable normalization \u2014 provides a foundation on which several ambitious research programs can be built. The core achievement is not merely that \"proofs get simpler\" but that *simplification is a mathematically controlled dynamical system with certified endpoints*. This opens three tiers of future work: (1) deepening the internal theory (confluence, quantitative bounds), (2) extending the framework to real proof systems and programming languages, and (3) bridging to other scientific domains where descent and compression phenomena arise. The directions below are ordered from the most immediately tractable to the most paradigm-shifting, and each is designed to be falsifiable \u2014 a conjecture that can succeed or fail, generating real science either way.\n\n---\n\n## Direction 1: Confluence and Canonical Normal Forms\n\n**Conjecture.** For the restricted refinement subsystem generated by `dropRedundant`, `dropDuplicate`, and `simplifyLemmaLeaf`, every proof sketch has a *unique* normal form (up to the identity). That is, the rewrite system is confluent.\n\n**Test.** Exhaustive enumeration of all proof sketches up to size 12. For each sketch, compute all possible refinement chains (not just greedy) and verify that all maximal chains terminate at the same normal form. A single counterexample refutes the conjecture. If the conjecture holds up to size 12, attempt to prove it via Newman's Lemma (local confluence + termination \u27f9 confluence) by verifying all critical pairs.\n\n**Impact.** If true, normal forms become *canonical representatives* of proof equivalence classes \u2014 the \"simplest explanation\" of each theorem is unique, not merely minimal. This would transform proof dynamics from a descent theory into a *normal-form theory* akin to Church-Rosser for lambda calculus, with applications to proof deduplication in theorem databases.\n\n**Catalog References.** `Speculative/ProofDynamics/Theorems.lean` \u2014 `local_confluence_drop_subsystem` (proved for the redundancy subsystem at root level; needs extension to the full system).\n\n**Proof Strategy.** Enumerate all critical pairs (overlapping left-hand sides of rules), show each is joinable, invoke Newman's Lemma. The key challenge is the interaction between `simplifyLemmaLeaf` and `dropRedundant` under `Lemma` nodes.\n\n**Domain Bridges.** Term rewriting systems, lambda calculus (Church-Rosser), compiler optimization (SSA normal forms).\n\n**Lineage.** Extends Theorem 9 (local confluence for redundancy subsystem).\n\n**Ambition.** Solid extension \u2014 directly builds on proved infrastructure.\n\n**\"The key insight is...\"** that local confluence at root level (Theorem 9) suggests a path to global confluence, but the interaction of rules under recursive contexts (Trans, Cases) introduces critical pairs that must be individually resolved.\n\n**\"Why now?\"** The formal verification of local confluence provides a concrete foothold. Automated critical-pair analysis tools (Knuth-Bendix completion) can be applied to the six-rule system, and the small rule count makes exhaustive analysis feasible.\n\n---\n\n## Direction 2: Polynomial Refinement Length Bounds\n\n**Conjecture.** There exists a constant $k$ such that every proof sketch $p$ reaches normal form in at most $\\text{score}(p)^k$ refinement steps.\n\n**Test.** For all proof sketches up to depth 4, compute the maximum refinement chain length and fit the empirical relationship $\\text{steps} \\leq C \\cdot \\text{score}^k$. Determine whether $k = 1$ (linear), $k = 2$ (quadratic), or higher. If the relationship is super-polynomial, the conjecture fails.\n\n**Impact.** A polynomial bound would make proof normalization *practically efficient*, not just theoretically terminating. This is the difference between an algorithm you can run and one you can only prove exists.\n\n**Catalog References.** `Speculative/ProofDynamics/Defs.lean` \u2014 `score`, `normalize`; `Speculative/ProofDynamics/Theorems.lean` \u2014 `refinementStep_decreases_score`.\n\n**Proof Strategy.** Since each step decreases score by at least 1, the trivial bound is $\\text{score}(p)$ steps (linear in score). The question is whether the greedy strategy achieves this, or whether non-greedy strategies could be worse. Prove: for the greedy strategy, each step decreases score by at least 1, giving a linear bound. For arbitrary strategies (choosing any applicable rule), the bound might be worse if rules interact to create cascading simplifications.\n\n**Domain Bridges.** Computational complexity theory, algorithm analysis, optimization convergence rates.\n\n**Lineage.** Extends Theorems 1, 3, and 7.\n\n**Ambition.** Solid extension with clear proof path.\n\n**\"The key insight is...\"** that the greedy strategy (always apply the outermost applicable rule) gives a linear bound in score, but arbitrary rule-application orders might exhibit quadratic behavior due to cascading simplifications.\n\n**\"Why now?\"** The formal proof that each step decreases score by \u22651 provides the foundation. Tightening the bound requires analyzing the interaction between rules at different tree levels.\n\n---\n\n## Direction 3: Proof Dynamics for Real Proof Terms\n\n**Conjecture.** The proof dynamics framework can be extended to the full Calculus of Inductive Constructions (CIC), with refinement rules including \u03b2-reduction, \u03b4-unfolding, \u03b9-reduction, and tactic simplification, such that normalization preserves type-theoretic semantics and terminates.\n\n**Test.** Implement a proof-term extractor that maps Lean 4 proof terms to an enriched `ProofSketch` type with binders, applications, and match expressions. Define refinement rules corresponding to standard term reductions. Test on 100 Mathlib proofs: measure compression ratio and verify semantic preservation via type-checking.\n\n**Impact.** This would bring proof dynamics from a theoretical framework to a *practical tool* for proof simplification in real proof assistants. Imagine a \"proof lint\" command that automatically simplifies every proof in a library, reducing build times and improving readability.\n\n**Catalog References.** `Speculative/ProofDynamics/Defs.lean` \u2014 `ProofSketch`, `RefinementStep` (needs enrichment); `Speculative/ProofDynamics/Theorems.lean` \u2014 `normalize_semantics` (needs generalization).\n\n**Proof Strategy.** Define a typed proof sketch `ProofSketch \u0393 \u03c4` indexed by context and type. Refinement steps become typed reductions. Semantic preservation becomes type preservation (subject reduction). Well-foundedness follows from the strong normalization of CIC (known but technically demanding to formalize).\n\n**Domain Bridges.** Type theory, compiler optimization (partial evaluation, deforestation), program transformation.\n\n**Lineage.** Grand extension of the entire framework.\n\n**Ambition.** Grand challenge \u2014 paradigm-shifting if achieved.\n\n**\"The key insight is...\"** that proof dynamics is not specific to our toy `ProofSketch` type. The core architecture \u2014 complexity measure, descent condition, semantic invariance \u2014 can be instantiated for any sufficiently structured proof language, including full dependent type theory.\n\n**\"Why now?\"** Lean 4 provides access to proof terms via the `Expr` type and meta-programming. The formal infrastructure for CIC normalization exists in Mathlib. The gap is connecting our abstract framework to this concrete setting.\n\n---\n\n## Direction 4: Proof Thermodynamics and Phase Transitions\n\n**Conjecture.** In the space of proof sketches of bounded size $n$, the distribution of refinement chain lengths exhibits a *phase transition*: below a critical redundancy threshold, most proofs are near-normal; above it, normalization requires $\\Theta(n)$ steps. The critical threshold depends on the ratio of redundant/duplicate nodes to structural nodes.\n\n**Test.** Generate random proof sketches of size $n$ with varying redundancy ratios $r$ (fraction of Redundant/Duplicate nodes). For each $(n, r)$, compute the mean and variance of refinement chain length over 1000 samples. Plot the phase diagram and identify the critical $r^*$ where mean chain length transitions from $O(1)$ to $O(n)$.\n\n**Impact.** This would establish a quantitative theory of \"proof bloat\" with a sharp threshold \u2014 analogous to percolation thresholds in statistical physics or satisfiability thresholds in random SAT. It would provide concrete guidance: proofs with redundancy ratio below $r^*$ are \"thermodynamically cold\" and need little simplification.\n\n**Catalog References.** `Speculative/ProofDynamics/Theorems.lean` \u2014 `no_cycles_of_energy_descent`, `energyDrop_pos_of_step`.\n\n**Proof Strategy.** Model random proof sketches as Galton-Watson trees with type-dependent branching. Compute the expected score and expected number of reducible nodes as functions of $r$. The phase transition occurs when the expected number of reducible nodes per unit score crosses 1.\n\n**Domain Bridges.** Statistical physics (Ising model, percolation), random graph theory, information theory (Shannon capacity), computational complexity (random SAT thresholds).\n\n**Lineage.** Builds on the energy/Lyapunov perspective of Theorem 5.\n\n**Ambition.** Grand challenge \u2014 bridges proof theory to statistical physics.\n\n**\"The key insight is...\"** that the energy landscape of proof dynamics has statistical structure: random proofs at different \"temperatures\" (redundancy levels) exhibit qualitatively different normalization behavior, just as physical systems undergo phase transitions.\n\n**\"Why now?\"** The formal Lyapunov framework provides the mathematical language. Random generation of proof sketches is computationally straightforward. The phase-transition methodology is well-established in random combinatorics and can be directly applied.\n\n---\n\n## Direction 5: Certified Compiler Optimization via Proof Dynamics\n\n**Conjecture.** Compiler optimization passes (dead code elimination, constant folding, common subexpression elimination) can be modeled as refinement steps on a program-sketch type, with a complexity measure that strictly decreases at each pass, yielding a formally verified optimization pipeline with guaranteed termination and semantic preservation.\n\n**Test.** Define a simple imperative language (assignments, conditionals, loops with bounded iteration) as an inductive type analogous to `ProofSketch`. Define optimization passes as refinement steps. Prove semantic preservation (program equivalence) and complexity decrease for each pass. Implement and test on 50 small programs, measuring speedup.\n\n**Impact.** This would create a *certified optimizing compiler* whose correctness is guaranteed by the same mathematical machinery as proof normalization. The CompCert project has shown that verified compilers are practical; proof dynamics would provide a principled framework for structuring and verifying optimization passes.\n\n**Catalog References.** `Speculative/ProofDynamics/Defs.lean` \u2014 `NormalForm`, `RefinementStep`; `Speculative/ProofDynamics/Theorems.lean` \u2014 `wellFounded_of_measure_decrease`, `refinementStep_preserves_semantics`.\n\n**Proof Strategy.** The program-sketch type replaces `ProofSketch`; the semantic function maps programs to input-output relations; refinement steps are semantics-preserving transformations. The descent measure could be program size, instruction count, or estimated runtime. The key is ensuring each optimization pass strictly decreases the measure \u2014 which requires careful handling of passes that might increase one dimension while decreasing another (use lexicographic ordering).\n\n**Domain Bridges.** Compiler construction (CompCert, CakeML), program verification, software engineering, performance optimization.\n\n**Lineage.** Direct application of the abstract framework (Theorems 1\u20134) to a different domain.\n\n**Ambition.** Grand challenge \u2014 bridges proof theory to software engineering.\n\n**\"The key insight is...\"** that proof simplification and compiler optimization are *the same mathematical problem* \u2014 descent on a complexity-equipped space of syntactic objects under semantics-preserving local transformations. The framework we have built is domain-agnostic; it works for proofs, programs, algebraic expressions, or any structured symbolic object.\n\n**\"Why now?\"** The formal verification of compilers is a mature field (CompCert, CakeML), but optimization passes are still verified individually. Proof dynamics provides a unifying framework that reduces the verification burden to (a) defining the complexity measure and (b) proving each pass decreases it.\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Computation",
      "Physics",
      "EML",
      "Bridges",
      "MachineLearning",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "8273a6c0",
    "consumed_by_exp_id": "038c9b3f",
    "timestamp": "2026-05-29T06:10:57.913857+00:00"
  },
  {
    "id": "fd_2060",
    "title": "The four theorems established in this work \u2014 the modular sieve, the binary ghost",
    "description": "# Future Directions: Arithmetic Monster Theory\n\n## Synthesis\n\nThe four theorems established in this work \u2014 the modular sieve, the binary ghost impossibility, length additivity, and the digit-disjoint infinitude theorem \u2014 form the foundation of a base-independent theory of digit-interaction under multiplication. Together they demonstrate that digit bags are the correct abstraction for studying how multiplication rearranges symbolic information. The directions below extend this foundation in five ways: (1) toward asymptotic density via analytic methods, (2) toward graph-theoretic structure via the digit-disjointness graph, (3) toward automatic sequences and Cobham's theorem, (4) toward higher-order factorizations, and (5) toward information-theoretic bounds. Each direction builds directly on the catalog of proved theorems and is designed to be testable within a single research cycle.\n\n---\n\n## Direction 1: Asymptotic Density of Vampire Numbers via Fourier Analysis on Digit Bags\n\n**Conjecture**: The number of vampire numbers V(N) in base b with v \u2264 N satisfies V(N) = \u0398(N^{1-c(b)}) for a base-dependent constant c(b) > 0.\n\n**Test**: Compute V(N) for N = 10^k (k = 2, ..., 8) in bases 10 and 16. Fit log V(N) against log N to estimate c(b). The conjecture predicts a stable negative slope. If c(b) varies significantly with the range, the power-law model is falsified.\n\n**Impact**: This would be the first rigorous density result for any digit-rearrangement class, settling a 30-year-old open question from recreational number theory.\n\n**Catalog References**: `Speculative/ArithmeticMonsters/Theorems.lean` \u2014 `IsVampire.modEq_sum` (provides the sieve used to prune the counting), `IsVampire.digitLen_add` (constrains which digit-length pairs contribute).\n\n**Proof Strategy**: Use the Fourier transform on ZMod(b-1)^k to express the digit-bag equality as an exponential sum. Apply the modular obstruction (Theorem 1) as a first-order sieve. Estimate the remaining sum using standard circle-method bounds. The key difficulty is controlling the correlation between digit-bag matching and multiplicative structure.\n\n**Domain Bridges**: Analytic number theory (circle method), additive combinatorics (Freiman-type theorems on digit multisets).\n\n**Lineage**: Extends the congruence sieve of Theorem 1 from a pointwise obstruction to an asymptotic tool.\n\n**Ambition**: Grand challenge \u2014 requires new analytic machinery beyond what currently exists in Lean/Mathlib.\n\nThe key insight is that the digit bag equality, viewed as a convolution condition, connects vampire enumeration to exponential sum estimates of the kind used in the Hardy-Littlewood circle method.\n\nWhy now? The formal framework makes the digit bag a first-class mathematical object rather than an ad hoc computational check. The modular sieve (Theorem 1) provides the crucial first-order cancellation that makes the exponential sums tractable.\n\n---\n\n## Direction 2: Spectral Theory of the Digit-Disjointness Graph\n\n**Conjecture**: The digit-disjointness graph on {1, ..., N} in base b \u2265 3 has spectral gap \u03a9(1) as N \u2192 \u221e, indicating expansion properties analogous to Ramanujan graphs.\n\n**Test**: Compute the adjacency matrix eigenvalues for N = 50, 100, 200 in bases 3, 5, 10. Track the ratio \u03bb\u2082/\u03bb\u2081 as N grows. The conjecture predicts this ratio stays bounded away from 1.\n\n**Impact**: Would establish the digit-disjointness graph as a new family of sparse graphs with expansion properties, connecting number theory to spectral graph theory and expander constructions.\n\n**Catalog References**: `Speculative/ArithmeticMonsters/Theorems.lean` \u2014 `pos_not_digitDisjoint_base2` (establishes the graph is empty for b=2), `exists_digitDisjoint_pair_ge` (establishes infinitely many edges for b\u22653).\n\n**Proof Strategy**: Decompose the adjacency operator by digit support patterns. Numbers sharing the same digit support set form cliques; the inter-clique structure should exhibit pseudorandomness due to equidistribution of digits in long numbers. Use Weil-type character sum bounds.\n\n**Domain Bridges**: Spectral graph theory, expander graphs, algebraic graph theory, coding theory (LDPC codes from digit-disjointness).\n\n**Lineage**: Directly extends Theorems 2 and 4, which establish the 0-vs-\u221e dichotomy in edge count.\n\n**Ambition**: Grand challenge \u2014 requires connecting digit combinatorics to spectral theory in a novel way.\n\nThe key insight is that the digit-disjointness graph decomposes naturally by digit support (the subset of {0,...,b-1} used), and each support class has algebraic structure amenable to spectral analysis.\n\nWhy now? The phase transition theorem (Theorem 2 + Theorem 4) establishes the base-dependent structure that makes spectral analysis meaningful. Without the formal framework, the graph itself was never precisely defined.\n\n---\n\n## Direction 3: Digit-Constrained Factorization and Cobham's Theorem\n\n**Conjecture**: For bases b\u2081, b\u2082 with log(b\u2081)/log(b\u2082) \u2209 \u211a, the set of numbers that are vampire numbers in *both* base b\u2081 and base b\u2082 is finite.\n\n**Test**: Enumerate vampire numbers up to 10^7 in bases 6 and 10. Compute the intersection. The conjecture predicts the intersection grows sublogarithmically.\n\n**Impact**: Would connect arithmetic monster theory to Cobham's theorem (1969), one of the deepest results linking automata theory to number theory. This is the strongest cross-domain bridge in the program.\n\n**Catalog References**: `Speculative/ArithmeticMonsters/Defs.lean` \u2014 `IsVampire` (base-parametric definition), `digitBag` (the finite invariant). `Speculative/ArithmeticMonsters/Theorems.lean` \u2014 all four theorems provide base-dependent structural constraints.\n\n**Proof Strategy**: The set of numbers with a specific digit-bag profile in base b is a union of arithmetic progressions intersected with a bounded-length condition \u2014 essentially a b-automatic set. The vampire number set is a projection of the intersection of such sets with the multiplicative relation. Cobham's theorem implies that sets recognizable in two multiplicatively independent bases are eventually periodic or sparse. Apply this to the digit-bag constraint.\n\n**Domain Bridges**: Automata theory, formal languages, Cobham's theorem, symbolic dynamics.\n\n**Lineage**: Extends the base-independence of the framework to a *comparison* across bases.\n\n**Ambition**: High \u2014 requires interfacing with deep automata-theoretic results not yet formalized in Lean.\n\nThe key insight is that the digit bag constraint defines a b-recognizable set (in the sense of automata theory), and Cobham's theorem sharply constrains the intersection of recognizable sets across multiplicatively independent bases.\n\nWhy now? Prior work on vampire numbers was base-10-specific and computational. Our base-parametric formalization makes cross-base comparison a natural operation rather than an afterthought.\n\n---\n\n## Direction 4: Higher-Order Monster Factorizations\n\n**Conjecture**: For k-ary factorizations v = x\u2081 \u00b7 x\u2082 \u00b7 ... \u00b7 x\u2096 with digit-bag conservation, the necessary congruence condition generalizes to v \u2261 x\u2081 + x\u2082 + ... + x\u2096 (mod b\u22121), and the number of k-ary vampire numbers with v \u2264 N grows as \u0398(N^{1-c_k(b)}) where c_k(b) is a decreasing function of k.\n\n**Test**: Enumerate ternary (k=3) vampire numbers up to 10^6 in base 10. Verify the congruence condition. Compare the density with the k=2 case. The conjecture predicts a higher density for k=3.\n\n**Impact**: Extends the theory from binary factorizations to arbitrary-arity decompositions, significantly broadening the framework's scope.\n\n**Catalog References**: `Speculative/ArithmeticMonsters/Theorems.lean` \u2014 `IsVampire.modEq_sum` (the k=2 case), `vampire_digitSum_add` (the digit-sum additivity that drives the congruence).\n\n**Proof Strategy**: The congruence proof for k=2 uses only two properties: (1) n \u2261 digitSum(n) mod b-1, and (2) digit bag additivity implies digit sum additivity. Both generalize immediately to k factors. The formal proof should be a k-fold induction. Density analysis requires more sophisticated counting.\n\n**Domain Bridges**: Additive combinatorics (sumsets of digit-bag vectors), partition theory.\n\n**Lineage**: Direct generalization of Theorem 1.\n\n**Ambition**: Moderate \u2014 the congruence generalization is straightforward; the density question is more challenging.\n\nThe key insight is that the modular obstruction theorem's proof depends only on the linearity of digit sums, which extends to any number of summands without additional machinery.\n\nWhy now? The formal framework makes k-ary factorizations a natural parametric extension. The Lean definitions can be generalized to list-valued factorizations with minimal refactoring.\n\n---\n\n## Direction 5: Digit Entropy and Information-Theoretic Bounds\n\n**Conjecture**: For a vampire pair (x, y) with v = xy in base b, the Shannon entropy of the normalized digit bag of v is bounded below by the maximum of the entropies of x and y, i.e., H(v) \u2265 max(H(x), H(y)).\n\n**Test**: Compute H(v), H(x), H(y) for all vampire triples up to 10^6 in base 10. Check whether H(v) \u2265 max(H(x), H(y)) holds universally. If a counterexample exists, characterize it.\n\n**Impact**: Would provide the first information-theoretic characterization of digit-rearrangement phenomena, opening a bridge to coding theory and data compression.\n\n**Catalog References**: `Speculative/ArithmeticMonsters/Defs.lean` \u2014 `digitBag` (the distribution whose entropy is computed). `Speculative/ArithmeticMonsters/Theorems.lean` \u2014 `IsVampire.digitLen_add` (the total mass constraint).\n\n**Proof Strategy**: The digit bag of v is the sum of the digit bags of x and y. Entropy of a sum of distributions is bounded by the sum of entropies (subadditivity), but the relevant direction (lower bound by max) requires a different argument. Use the concavity of the entropy function on the simplex and the constraint that bags are summed componentwise.\n\n**Domain Bridges**: Information theory, coding theory, convex optimization, entropy methods in combinatorics.\n\n**Lineage**: Extends the digit bag framework from combinatorial counting to information-theoretic analysis.\n\n**Ambition**: Moderate to high \u2014 the conjecture may be false for extreme digit distributions.\n\nThe key insight is that the digit bag, normalized by total digit count, defines a probability distribution on the digit alphabet, and vampire number constraints impose structured relationships between these distributions.\n\nWhy now? The digit bag abstraction provides a clean probability distribution that can be analyzed with standard information-theoretic tools. Prior work never formalized the digit bag as a mathematical object, making entropy analysis impossible.\n",
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
    "source_exp_id": "07676346",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:11:18.637317+00:00"
  },
  {
    "id": "fd_2061",
    "title": "The overlap class theory established here reveals that the interaction structure",
    "description": "# Future Directions: Overlap Class Theory and Tropical Kernel Invariants\n\n## Synthesis\n\nThe overlap class theory established here reveals that the interaction structure of tropical kernel generators decomposes naturally along the connected components of the support overlap graph. The key discovery \u2014 that supports from different overlap classes are provably disjoint \u2014 opens three distinct research frontiers: (1) determining whether overlap classes are *complete* invariants of tropical projective equivalence classes, (2) extending the theory from graphs to matroids, and (3) connecting the overlap signature to spectral and homological properties of networks. Each direction below is grounded in specific formally verified theorems and is designed to be both testable and falsifiable.\n\n---\n\n## Direction 1: Overlap Degree One Uniqueness Conjecture\n\n**Conjecture:** When every pair of overlapping cycle supports in G[S] intersects in at most one vertex (MaxOverlapDeg \u2264 1), the tropical kernel generating family is unique up to TPE within each overlap class.\n\n**Test:** Enumerate all connected graphs on n \u2264 9 vertices. For each (G, q, S) with MaxOverlapDeg(cycleSupportFamily(G, S)) \u2264 1, enumerate all minimal generating families and check uniqueness within overlap classes. A single instance with two inequivalent generators in the same overlap class under this constraint would refute the conjecture.\n\n**Impact:** This would be the first genuinely new uniqueness theorem beyond the disjoint regime, establishing that \"weakly overlapping\" generators (sharing at most one vertex per pair) still exhibit the same rigidity as non-overlapping ones. It would define the boundary between the rigid and flexible regimes.\n\n**Catalog References:**\n- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `overlapDegree_eq_zero_iff_pairwiseDisjoint`, `disjoint_of_different_overlap_class`\n- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`: `disjoint_support_unique_up_to_tropProjEquiv`\n\n**Proof Strategy:** Induction on the overlap degree. Base case (degree 0) is the existing disjoint theorem. For degree 1, the single shared vertex between overlapping supports acts as a \"pinch point\" \u2014 show that the constraint of harmonicity at this vertex forces the two generators to agree modulo TPE. Use the harmonic leaf rigidity theorem from TropicalKernelRigidity.lean to propagate values through the shared vertex.\n\n**Domain Bridges:** Matroid theory (circuit elimination with single-element intersections), coding theory (support overlap in LDPC codes where parity checks share one variable).\n\n**Lineage:** Extends `disjoint_support_unique_up_to_tropProjEquiv` from the disjoint case to the weakly interacting case.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2606 \u2014 Substantial extension of the rigidity theory, technically accessible via induction.\n\n---\n\n## Direction 2: Componentwise TPE Factorization (Grand Challenge)\n\n**Conjecture:** For any graph G, basepoint q, and S \u2286 V \\ {q}, the set of TPE classes of minimal generating families of the tropical kernel factorizes as a product over overlap classes:\n\nTPEClassCount(G, q, S) = \u220f_{C \u2208 OverlapClasses} TPEClassCount_C(G, q, S)\n\n**Test:** Compute TPE class counts for all connected graphs on n \u2264 7 by exhaustive enumeration of generating families. Compare the product formula to the actual count. A counterexample immediately reveals which overlap classes interact.\n\n**Impact:** This would establish that overlap classes are the fundamental \"interaction sectors\" for tropical kernel generators \u2014 a decomposition analogous to the cluster decomposition in statistical mechanics. It would reduce the computation of TPE class counts from a global problem to a product of local problems.\n\n**Catalog References:**\n- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `overlap_class_unions_disjoint`, `tropProjEquiv_preserves_varOverlapEquiv`\n- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean`: `inducedCycleRank`\n\n**Proof Strategy:** Strategy B (component factorization). Show that any minimal generating family restricts to a minimal generating family on each overlap component. Use the disjointness theorem (`overlap_class_unions_disjoint`) to decouple the components. Then show that TPE acts independently on each component.\n\n**Domain Bridges:** Statistical physics (cluster decomposition theorem), topological data analysis (persistent homology of support complexes), algebraic K-theory (devissage along interaction strata).\n\n**Lineage:** Builds on all the overlap class machinery plus the defect theory from `DefectTheory.lean`.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 \u2014 Paradigm-shifting if true; even partial results (bounds relating product to actual count) would be highly valuable.\n\n---\n\n## Direction 3: Overlap Signature as Complete Invariant\n\n**Conjecture:** The isomorphism type of the overlap graph together with the multiset of intersection sizes (the overlap signature) determines the TPE class count.\n\n**Test:** Search for two instances (G\u2081, q\u2081, S\u2081) and (G\u2082, q\u2082, S\u2082) with isomorphic overlap graphs, identical overlap signatures, but different TPE class counts. This is computationally feasible for n \u2264 8.\n\n**Impact:** If true, the overlap signature is a *complete* combinatorial invariant for TPE class enumeration \u2014 reducing an algebraic problem to a purely combinatorial one. If false, the counterexample reveals what additional data (e.g., the intersection lattice, the matroid structure) is needed.\n\n**Catalog References:**\n- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `OverlapSignature`, `overlapSignature_pos`, `CrossOverlapCount`\n\n**Proof Strategy:** If the signature is insufficient, strengthen to the **intersection lattice** (the partial order on all intersections F(i\u2081) \u2229 ... \u2229 F(i\u2096)). The lattice is strictly finer than the signature and may suffice.\n\n**Domain Bridges:** Matroid theory (circuit intersection lattice), combinatorial topology (nerve of the support cover), information theory (interaction information and multivariate mutual information).\n\n**Lineage:** Refines the overlap class theory from Section 9 of the Lean formalization.\n\n**Ambition:** \u2605\u2605\u2605\u2606\u2606 \u2014 Computationally testable, and either outcome advances the theory.\n\n---\n\n## Direction 4: Matroid-Circuit Generalization\n\n**Conjecture:** The overlap class theory generalizes from graphic matroids to all regular matroids: for any regular matroid M, the circuit overlap graph controls the tropical kernel generators of M's representation matrix.\n\n**The key insight is** that cycle supports in G[S] are precisely the circuit supports of the graphic matroid M(G)|S, and the overlap graph is exactly the circuit intersection graph. Regular matroids are representable over every field, so the tropical theory should apply.\n\n**Why now?** Mathlib now has substantial matroid theory, including circuit characterizations and matroid operations, making formalization feasible.\n\n**Test:** Formalize the circuit intersection graph for matroids in Lean 4. Verify that for graphic matroids, it agrees with the support overlap graph. Then test the factorization conjecture for non-graphic regular matroids (e.g., R\u2081\u2080, the non-Fano matroid dual).\n\n**Impact:** This would elevate overlap class theory from a graph-specific result to a matroid-theoretic principle, applicable to any context where matroids arise (network flows, linear codes, algebraic geometry).\n\n**Catalog References:**\n- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: all definitions and theorems\n- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`: `SameInducedStructure`, `same_induced_structure_same_laplacian`\n\n**Proof Strategy:** Define the circuit overlap graph for abstract matroids. Show that it specializes to the support overlap graph for graphic matroids. Use the matroid circuit elimination axiom to control how generators interact at overlap points.\n\n**Domain Bridges:** Algebraic combinatorics, tropical geometry (valuated matroids), optimization (matroid intersection algorithms).\n\n**Lineage:** Extends the matroidal invariance theorem from TropicalKernelRigidity.lean.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 \u2014 Grand challenge that would unify graph-theoretic and matroid-theoretic approaches to tropical algebra.\n\n---\n\n## Direction 5: Defect-Overlap Duality\n\n**Conjecture:** The structural defect from DefectTheory.lean is bounded by a function of the overlap degree and cycle rank:\n\nstructuralDefect(G, q, S) \u2264 f(OverlapDegree(cycleSupportFamily(G, S)), inducedCycleRank(G, S))\n\nfor a computable function f.\n\n**The key insight is** that both the defect (measuring the gap between Laplacian rank and divisor rank) and the overlap degree (measuring support interactions) are controlled by the cycle structure of G[S]. High overlap degree means cycles share vertices, which should constrain the defect.\n\n**Why now?** Both the defect theory and overlap theory are now formalized, enabling a precise bridge.\n\n**Test:** Compute both quantities for all (G, q, S) on n \u2264 7. Fit the function f. Check if the bound is tight.\n\n**Impact:** Would provide the first quantitative link between the algebraic defect (a Laplacian invariant) and the combinatorial overlap structure (a support invariant), unifying two independently developed theories.\n\n**Catalog References:**\n- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `OverlapDegree`, `overlapDegree_eq_zero_iff_pairwiseDisjoint`\n- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean`: `structuralDefect`, `inducedCycleRank`\n\n**Proof Strategy:** Case analysis. When overlap degree is 0, the defect should be controlled by cycle rank alone (existing theory). For each additional overlapping pair, bound the defect increase using the cycle elimination principle.\n\n**Domain Bridges:** Spectral graph theory (Laplacian eigenvalue bounds vs. cycle structure), algebraic topology (Betti numbers vs. intersection patterns).\n\n**Lineage:** Bridges the two main Lean files in the TropicalBridge directory.\n\n**Ambition:** \u2605\u2605\u2605\u2606\u2606 \u2014 Solid extension building directly on existing catalog theorems.\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Cryptography",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "665b8883",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:11:37.397395+00:00"
  },
  {
    "id": "fd_2062",
    "title": "The shadowing lemma formalization opens a new frontier connecting dynamical syst",
    "description": "# Future Directions: Certified Numerical Chaos and the Shadowing Lemma\n\n## Synthesis\n\nThe shadowing lemma formalization opens a new frontier connecting dynamical systems theory to computer science through machine-verified mathematics. Our work establishes the foundation \u2014 formal definitions of pseudo-orbits, shadowing, expanding maps, and conjugacy transfer \u2014 upon which five major research directions can be built. The common thread is that **shadowing is the dynamical systems manifestation of a deeper information-theoretic principle**: chaotic systems create information at a rate bounded by their entropy, and shadowing says that approximate computations capture this information up to an explicitly bounded distortion. Each direction below extends this principle to a new mathematical domain, with the potential to create entirely new fields: stochastic certified dynamics, information-theoretic chaos theory, certified backward error analysis for ODEs, privacy-theoretic chaos, and tropical dynamics.\n\n---\n\n## Direction 1: Shadowing for Stochastic Differential Equations\n\n**Conjecture:** Let $dX_t = f(X_t)\\,dt + \\sigma(X_t)\\,dW_t$ be an SDE with uniformly expanding drift $f$ (i.e., $\\|Df\\| \\geq \\lambda > 1$ in an appropriate sense). Then every numerical approximation (Euler-Maruyama scheme with step size $h$) produces a $\\delta(h)$-pseudo-orbit that is $\\varepsilon$-shadowed by a true solution with probability $\\geq 1 - e^{-c/\\varepsilon^2}$, where $\\varepsilon = O(\\delta/(\\lambda - 1))$ and $\\delta = O(h^{1/2})$.\n\n**Test:** Implement the Euler-Maruyama scheme for the stochastic logistic equation $dX = 4X(1-X)\\,dt + \\sigma X(1-X)\\,dW$ with $\\sigma = 0.1$. For $10^4$ sample paths of length $N = 10^3$ with step size $h = 10^{-3}$, use high-precision simulation (step size $h/100$) to find shadowing paths. Verify that the shadowing distance scales as $O(h^{1/2})$ and the failure probability decays exponentially.\n\n**Impact:** Would create the field of **certified stochastic dynamics** \u2014 rigorous guarantees for Monte Carlo simulations of chaotic SDEs, with applications to computational finance (option pricing under chaotic volatility), molecular dynamics (protein folding), and stochastic climate models.\n\n**Catalog References:** `Speculative/Shadowing/Defs.lean` (pseudo-orbit definitions), `Speculative/Shadowing/Shadowing.lean` (conjugacy transfer).\n\n**Proof Strategy:** Extend the backward construction (Algorithm 2) to the stochastic setting. The key technical challenge is that SDE solutions are only almost-surely defined, so the shadowing orbit must be constructed path-by-path. Use Girsanov's theorem to relate the pseudo-orbit measure to the true orbit measure, bounding the Radon-Nikodym derivative by $\\exp(c \\cdot \\delta^2 / \\sigma^2)$.\n\n**Domain Bridges:** Dynamical systems \u2194 Stochastic analysis \u2194 Computational finance.\n\n**Lineage:** Extends Theorem 3.1 (conjugacy preserves shadowing) to the stochastic setting.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2606 (Grand challenge \u2014 requires new mathematical machinery at the intersection of shadowing theory and stochastic analysis)\n\n---\n\n## Direction 2: Shadowing Capacity Equals Metric Entropy\n\n**Conjecture:** For a $C^2$ expanding map $f$ on a compact Riemannian manifold with expansion factor $\\lambda$ and invariant measure $\\mu$, define the **shadowing capacity** as $C_s(f) = \\sup\\{r : \\text{every } \\delta\\text{-pseudo-orbit is } r\\delta\\text{-shadowed}\\}^{-1}$. Then $\\log C_s(f) = h_\\mu(f)$, the metric entropy, and equality holds if and only if $f$ satisfies Bowen's specification property.\n\n**Test:** Compute $C_s(f)$ numerically for:\n1. The tent map ($\\lambda = 2$, expected $C_s = 2$, $h_\\mu = \\log 2$) \u2713\n2. The doubling map $x \\mapsto 2x \\pmod{1}$ ($\\lambda = 2$, expected $C_s = 2$) \n3. The cat map on $\\mathbb{T}^2$ ($\\lambda = (1+\\sqrt{5})/2$, expected $C_s = \\lambda$)\n\nVerify $\\log C_s = h_\\mu$ in each case to $< 1\\%$ relative error.\n\n**Impact:** Would establish a **Shannon-type theorem for dynamical systems**: the shadowing capacity is the channel capacity of the \"noisy orbit channel,\" and metric entropy is the fundamental limit. This bridges ergodic theory to information theory, enabling information-theoretic certification of numerical dynamics.\n\n**Catalog References:** `Speculative/Shadowing/Defs.lean` (IsExpanding, HasShadowingProperty).\n\n**Proof Strategy:** \n1. Upper bound: Use the variational principle $h_\\mu(f) \\leq h_{top}(f) = \\log \\lambda$ for expanding maps.\n2. Lower bound: Construct pseudo-orbits that achieve the shadowing bound, using symbolic dynamics on the Markov partition.\n3. The specification property is needed for the \"converse\" \u2014 showing that shadowing capacity *achieves* entropy, not just bounds it.\n\n**Domain Bridges:** Dynamical systems \u2194 Information theory \u2194 Ergodic theory.\n\n**Lineage:** Extends the shadowing bound $\\varepsilon \\leq \\delta/(\\lambda-1)$ to an exact equality between capacity and entropy.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 (Paradigm-shifting \u2014 would unify two major branches of mathematics)\n\n---\n\n## Direction 3: Certified Backward Error Analysis for Chaotic ODE Solvers\n\n**Conjecture:** For a chaotic ODE $\\dot{x} = F(x)$ with positive maximal Lyapunov exponent $\\lambda_{max}$, every numerical solution computed by an order-$p$ Runge-Kutta method with step size $h$ is the exact solution of a **modified ODE** $\\dot{x} = F(x) + h^p G(x) + O(h^{p+1})$ starting from a **modified initial condition** $x_0 + O(h^p/\\lambda_{max})$. The shadowing lemma determines which modification (equation vs. initial condition) gives the tighter bound.\n\n**Test:** For the Lorenz system ($\\sigma = 10, \\rho = 28, \\beta = 8/3$) with RK4 and step sizes $h \\in \\{10^{-2}, 10^{-3}, 10^{-4}\\}$:\n1. Compute the backward error (modified equation residual) and the shadowing distance.\n2. Verify that the shadowing distance scales as $h^p / \\lambda_{max}$ while the backward error scales as $h^p$.\n3. Determine the crossover point where shadowing gives a tighter bound than backward error analysis.\n\n**Impact:** Would create **certified chaotic ODE integration** \u2014 rigorous error certificates for long-time simulations of chaotic systems, applicable to celestial mechanics (asteroid tracking), plasma physics, and neural ODE verification.\n\n**Catalog References:** `Speculative/Shadowing/Shadowing.lean` (shadowing property transfer), `Speculative/Shadowing/Conjugacy.lean` (conjugacy equation).\n\n**Proof Strategy:** \n1. Apply backward error analysis to get the modified equation $\\dot{x} = F(x) + h^p G(x)$.\n2. Treat the numerical solution as a pseudo-orbit of the original flow.\n3. Apply the continuous-time shadowing lemma (extending our discrete result) to get the shadowing bound.\n4. Compare: backward error perturbs $F$ by $O(h^p)$; shadowing perturbs $x_0$ by $O(h^p/\\lambda_{max})$.\n\n**Domain Bridges:** Dynamical systems \u2194 Numerical analysis \u2194 Verified computation.\n\n**Lineage:** Extends Theorem 3.1 from discrete maps to continuous flows, and connects to Wilkinson's backward stability.\n\n**Ambition:** \u2605\u2605\u2605\u2606\u2606 (Solid extension with high practical impact)\n\n---\n\n## Direction 4: Shadowing-Based Differential Privacy for Chaotic PRNGs\n\n**Conjecture:** A chaotic PRNG based on an expanding map $f$ with expansion factor $\\lambda$ satisfies $(\\varepsilon, \\delta)$-differential privacy with $\\varepsilon = \\log(\\lambda)$ and $\\delta = 0$ in the following sense: for any two seeds $x_0, x_0'$ with $|x_0 - x_0'| \\leq \\eta$, the output distributions over orbits of length $N$ satisfy $D_{KL}(P_{x_0} \\| P_{x_0'}) \\leq N \\log(\\lambda) \\cdot \\eta / \\delta_{shadow}$ where $\\delta_{shadow}$ is the shadowing distance.\n\n**Test:** \n1. Implement a logistic-map PRNG with seed perturbation.\n2. For $10^4$ pairs of seeds differing by $\\eta \\in \\{10^{-10}, 10^{-12}, 10^{-14}\\}$, compute the KL divergence between output distributions (estimated from $10^3$ bits each).\n3. Verify that the divergence scales as predicted: $D_{KL} \\propto N \\cdot \\eta$.\n\n**Impact:** Would establish a new paradigm for **chaos-theoretic privacy**: the mixing properties of chaotic dynamics provide a natural mechanism for privacy, with the shadowing lemma providing the formal guarantee. Applications to privacy-preserving computation and secure multi-party protocols.\n\n**Catalog References:** `Speculative/Shadowing/Defs.lean` (IsExpanding), `applications.py` (ChaoticPRNG).\n\n**Proof Strategy:** Use the shadowing lemma to show that perturbed outputs are indistinguishable from legitimate outputs (since they ARE legitimate outputs for different seeds). The privacy budget $\\varepsilon$ corresponds to the shadowing distance, and the expansion factor $\\lambda$ determines the rate of information mixing.\n\n**Domain Bridges:** Dynamical systems \u2194 Cryptography \u2194 Differential privacy \u2194 Information theory.\n\n**Lineage:** Extends the PRNG application to a formal privacy framework.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2606 (Novel cross-domain bridge with potential for real-world impact)\n\n---\n\n## Direction 5: Tropical Shadowing and Min-Plus Dynamics\n\n**Conjecture:** Define a **tropical pseudo-orbit** of a min-plus linear map $A \\otimes x = \\min_j(a_{ij} + x_j)$ as a sequence $(x_0, \\ldots, x_N)$ with $\\|x_{i+1} - A \\otimes x_i\\|_\\infty < \\delta$ in the tropical metric. Then the tropical shadowing lemma holds: every $\\delta$-tropical-pseudo-orbit is $\\varepsilon$-shadowed by a true tropical orbit with $\\varepsilon = \\delta / (\\rho(A) - 1)$ where $\\rho(A)$ is the tropical spectral radius.\n\n**Test:** \n1. Generate random $n \\times n$ tropical matrices for $n \\in \\{3, 5, 10, 20\\}$.\n2. Compute tropical pseudo-orbits with controlled perturbation $\\delta$.\n3. Find shadowing true orbits by tropical backward construction.\n4. Verify the bound $\\varepsilon \\leq \\delta/(\\rho(A) - 1)$.\n\n**Impact:** Would create **tropical dynamics** \u2014 a new field bridging tropical geometry to dynamical systems theory. Tropical shadowing would provide certified computation for discrete event systems, scheduling problems, and network optimization, which are naturally modeled by min-plus algebra.\n\n**Catalog References:** `Speculative/Shadowing/Defs.lean` (definitions generalize to any metric space), `Speculative/Shadowing/Shadowing.lean` (conjugacy transfer could connect tropical and classical dynamics).\n\n**Proof Strategy:** The min-plus structure provides a natural Banach space (the space of bounded tropical sequences with the sup norm). Apply the Banach fixed point theorem to the tropical shadowing operator, mirroring Strategy A from the classical case.\n\n**Domain Bridges:** Dynamical systems \u2194 Tropical geometry \u2194 Operations research \u2194 Discrete event systems.\n\n**Lineage:** Transfers the expanding map shadowing framework to the tropical semiring.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 (Paradigm-shifting \u2014 would create an entirely new mathematical field)\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
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
    "source_exp_id": "e9711576",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:11:56.795106+00:00"
  },
  {
    "id": "fd_2064",
    "title": "The theorems established in this work \u2014 connectedness from interval preconnected",
    "description": "# Future Directions: Surreal Topology\n\n## Synthesis\n\nThe theorems established in this work \u2014 connectedness from interval preconnectedness, contractibility of intervals, and uniqueness of the interval topology \u2014 form the foundation of a new program: **topological asymptotics on non-Archimedean ordered continua**. The key unifying insight is that the topological behavior of ordered continua is governed by a single principle: *local convexity determines global homotopy type*. Every direction below exploits this principle in a different mathematical domain, from valuation theory to topological data analysis. The common thread is that ordered structures carry canonical topologies that are richer than previously understood, and our formal verification framework provides the infrastructure to explore them rigorously.\n\n---\n\n## Direction 1: Non-Archimedean Completion and Connectivity\n\n**Conjecture:** Let $K = k((t^G))$ be a Hahn series field with $k$ a real-closed field and $G$ an ordered abelian group. The order topology on $K$ is connected if and only if $K$ is spherically complete (i.e., every decreasing chain of balls has nonempty intersection).\n\n**Test:** Construct explicit Hahn series fields with different groups $G$ (e.g., $G = \u2124$, $G = \u211a$, $G = \u211d$) and test interval preconnectedness computationally on truncated approximants. For $G = \u2124$, the field is the Laurent series $k((t))$; for $G = \u211a$, it is the Puiseux series. Check whether our `connectedSpace_of_intervalPreconnected` theorem applies.\n\n**Impact:** This would characterize exactly which non-Archimedean ordered fields have connected topology, settling a question implicit in the surreal topology program: *what completion operation is needed to make surreal fragments connected?*\n\n**Catalog References:** `Catalog/Speculative/SurrealTopology.lean` \u2014 `isPreconnected_univ_of_intervalPreconnected`, `connectedSpace_of_conditionallyComplete_dense`\n\n**Proof Strategy:** Use the valuation-theoretic structure of Hahn series to analyze Dedekind cuts. A cut fails to be filled iff it corresponds to a \"gap\" in the value group or residue field. Spherical completeness eliminates both sources of gaps.\n\n**Domain Bridges:** Valuation theory, model theory of valued fields, algebraic geometry (tropicalization)\n\n**Lineage:** Extends Theorem 3.1 (connectedness from interval preconnectedness) to the non-Archimedean setting\n\n**Ambition:** Grand challenge \u2014 would unify surreal topology with the deep theory of valued fields\n\n---\n\n## Direction 2: Homotopy Theory of Lexicographic Products\n\n**Conjecture:** For any ordered abelian group $G$ and any connected ordered topological space $X$, the lexicographic product $G \\times_{lex} X$ with the order topology is:\n- Connected iff $G$ has no gaps (is densely ordered or complete),\n- Contractible iff $X$ is contractible and $G$ is an ordered vector space over \u211a,\n- Path-connected iff $X$ is path-connected and $G$ is densely ordered.\n\n**Test:** Formalize the lexicographic product `Lex (\u2124 \u00d7 \u211d)` and `Lex (\u211a \u00d7 \u211d)` in Lean 4, equip with order topology, and prove/disprove connectedness. The key insight is that `Lex (\u2124 \u00d7 \u211d)` should be disconnected (\u2124 has gaps) while `Lex (\u211a \u00d7 \u211d)` should be connected (\u211a is dense).\n\n**Impact:** Would provide the first classification of homotopy types for multi-scale ordered spaces, directly relevant to models of spacetime with multiple length scales.\n\n**Catalog References:** `Catalog/Speculative/SurrealTopology.lean` \u2014 `SurrealLikeLine`, `icc_contractible`\n\n**Proof Strategy:** For disconnectedness of $\u2124 \\times_{lex} \u211d$, exhibit a clopen set: ${(n, x) : n < 0}$ is both open and closed. For connectedness of $\u211a \\times_{lex} \u211d$, verify interval preconnectedness using density of \u211a.\n\n**Domain Bridges:** Homotopy theory, geometric group theory, non-Archimedean geometry\n\n**Lineage:** Directly extends `SurrealLikeLine` to concrete non-Archimedean models\n\n**Ambition:** Solid extension \u2014 builds directly on existing infrastructure\n\n---\n\n## Direction 3: Persistent Homology of Surreal Approximants\n\n**Conjecture:** The persistence diagrams of bounded-day dyadic approximants $D_n$ converge (in the bottleneck distance) to the trivial persistence diagram (a single point at infinity) as $n \u2192 \u221e$. Moreover, the convergence rate is $O(1/2^n)$.\n\n**Test:** Compute persistence diagrams for $D_0, D_1, \\ldots, D_{10}$ and measure the bottleneck distance between consecutive diagrams. The key insight is that the maximum death time in the persistence diagram of $D_n$ is the minimum gap $1/2^n$, which decreases geometrically.\n\n**Impact:** Would establish a formal bridge between surreal number theory and topological data analysis (TDA), providing a canonical example of persistence convergence with known convergence rate.\n\n**Catalog References:** `Catalog/Speculative/SurrealTopology.lean` \u2014 `boundedDayDyadics`, `boundedDayDyadics_mono`\n\n**Proof Strategy:** The persistence diagram of $D_n$ consists of pairs $(0, g)$ where $g$ ranges over the gaps. Since all gaps in $D_n$ equal $1/2^n$, the bottleneck distance between $D_n$ and the trivial diagram is $1/2^n$.\n\n**Domain Bridges:** Topological data analysis, computational topology, stability theory of persistence\n\n**Lineage:** Extends the computational infrastructure in the current work to a full TDA framework\n\n**Ambition:** Solid extension \u2014 directly computable and testable\n\n---\n\n## Direction 4: Class-Level Topology via Pro-Objects\n\n**Conjecture:** The surreal numbers $\\mathbf{No}$, viewed as the colimit of the directed system of bounded-day approximants $\\{D_n\\}_{n \\in \\text{Ord}}$, carry a natural pro-topology \u2014 a compatible system of topologies on the finite approximants \u2014 and this pro-topology is \"pro-connected\" and \"pro-contractible\" in an appropriate categorical sense.\n\n**Test:** Define a category of \"bounded surreal fragments\" with order-preserving embeddings, equip each with its order topology, and verify that the inverse system of topological spaces satisfies the Mittag-Leffler condition for connectedness.\n\n**Impact:** Would provide the first rigorous framework for topology on proper classes, resolving the foundational obstacle that motivated this entire project.\n\n**Catalog References:** `Catalog/Speculative/SurrealTopology.lean` \u2014 `interval_topology_unique`, `connectedSpace_of_intervalPreconnected`\n\n**Proof Strategy:** The key insight is that topology on a proper class should be defined not as a single topological space but as a compatible system indexed by ordinals. Our uniqueness theorem ensures coherence: at each level, the topology is determined by the order. The Mittag-Leffler condition for the inverse system of connected components should hold because each $D_n \\hookrightarrow D_{n+1}$ preserves the structure.\n\n**Domain Bridges:** Category theory, pro-objects, condensed mathematics (Clausen-Scholze), set theory\n\n**Lineage:** Addresses the foundational question that motivated the set-sized shadow approach\n\n**Ambition:** Grand challenge \u2014 would open a new chapter in the foundations of topology\n\n---\n\n## Direction 5: Surreal Topology Meets O-Minimality\n\n**Conjecture:** Any o-minimal expansion of a real-closed field, equipped with the order topology, is a `SurrealLikeLine` (after removing endpoints if bounded). Moreover, definable sets in an o-minimal structure inherit the order-convexity properties that make them connected or contractible.\n\n**Test:** Verify that the o-minimal cell decomposition theorem implies that every definable connected set in an o-minimal expansion of \u211d is order-convex (up to finite partition). Use our `IsOrderConvex.isConnected` theorem to derive connectedness of definable sets.\n\n**Impact:** Would connect surreal topology to one of the most powerful tools in model theory and real algebraic geometry. O-minimality provides tameness conditions that should interact synergistically with our order-convexity framework.\n\n**Catalog References:** `Catalog/Speculative/SurrealTopology.lean` \u2014 `IsOrderConvex`, `IsOrderConvex.isConnected`, `isOrderConvex_iff_ordConnected`\n\n**Proof Strategy:** The key insight is that o-minimal structures have the \"monotonicity theorem\": every definable function is piecewise monotone. This implies that definable connected subsets of the line are intervals (convex sets), and our theorems apply directly. The challenge is formalizing enough o-minimality in Lean to state the connection.\n\n**Domain Bridges:** Model theory, real algebraic geometry, semialgebraic geometry, tame topology\n\n**Lineage:** Bridges from our order-convexity framework to the well-established theory of o-minimal structures\n\n**Ambition:** Solid extension with grand challenge potential \u2014 depends on the availability of o-minimal infrastructure in Lean\n",
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
    "source_exp_id": "38c313b9",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:48:32.238587+00:00"
  },
  {
    "id": "fd_2065",
    "title": "The formalization of finite-description L-data as a countable, complexity-strati",
    "description": "# Future Directions: The L-Function Census Theory\n\n## Synthesis\n\nThe formalization of finite-description L-data as a countable, complexity-stratified universe opens a systematic research program at the intersection of analytic number theory, computability theory, and information theory. The five directions below form a coherent progression: Direction 1 enriches the L-data structure with arithmetic admissibility constraints, Direction 2 connects the census to analytic properties of actual L-functions, Direction 3 bridges to symbolic dynamics and ergodic theory, Direction 4 develops the information-theoretic stratification into a rigorous complexity theory, and Direction 5 proposes a grand challenge connecting L-data complexity to the distribution of zeros.\n\nEach direction builds on the countability and finiteness theorems proved in the current work, extending them into domains where the combination of finite combinatorial data and infinite analytic structure creates novel mathematical phenomena.\n\n---\n\n## Direction 1: Admissibility-Filtered L-Data Census\n\n**Conjecture.** Let `AdmissibleLData \u0393 \u03b1 \u2286 FiniteDescriptionLData \u0393 \u03b1` be the subset satisfying: (i) all entries of `badPrimeList` are prime, (ii) the conductor equals the product of bad primes raised to appropriate powers, and (iii) the local factor coefficients satisfy Ramanujan-type bounds `|a_i| \u2264 p^{i/2}` at each prime `p`. Then `AdmissibleLData \u0393 \u03b1` is countable, and the growth rate `|{x \u2208 AdmissibleLData : dL(x) \u2264 B}|` is strictly subexponential in `B`.\n\n**Test.** Implement the admissibility filter on the enumeration from `demo.py`. Count admissible objects for `B = 1, ..., 10` with coefficient type `\u2124 \u2229 [-10, 10]`. Fit the growth curve to `exp(c \u00b7 B^\u03b1)` and test whether `\u03b1 < 1`. A counterexample would be a coefficient range and degree for which admissible count grows exponentially.\n\n**Impact.** If confirmed, this would show that arithmetic constraints dramatically thin the L-data census \u2014 the \"meaningful\" L-functions are exponentially sparser than the combinatorially possible ones. This formalizes the heuristic that \"most Euler products are not L-functions.\"\n\n**Catalog References.** `Speculative/LFunctionUniverse/Defs.lean` (FiniteDescriptionLData), `Speculative/LFunctionUniverse/Theorems.lean` (countable_FiniteDescriptionLData, finite_bounded_descriptionLength).\n\n**Proof Strategy.** Define `AdmissibleLData` as a subtype. Countability follows immediately from countability of the ambient type. For the growth bound, prove that the primality constraint on `badPrimeList` restricts each entry to `\u03c0(B) \u2248 B/ln(B)` choices rather than `B+1`, yielding a factor of `(B/ln B)^n / (B+1)^n` suppression for `n` bad primes.\n\n**Domain Bridges.** Analytic number theory (prime number theorem for the bad-prime constraint), sieve theory (counting primes in intervals).\n\n**Lineage.** Extends Theorem 3 (finiteness of bounded strata) by adding content-aware constraints.\n\n**Ambition.** \ud83d\udd2c Solid extension \u2014 directly builds on existing infrastructure with arithmetically motivated refinements.\n\n---\n\n## Direction 2: Analytic Realization and Functional Equation Verification\n\n**Conjecture.** There exists a computable predicate `HasFunctionalEquation : FiniteDescriptionLData \u2124 \u2124 \u2192 Prop` such that for each L-datum `x`, `HasFunctionalEquation x` is decidable and implies the associated Dirichlet series satisfies a functional equation of the expected shape. Moreover, the set `{x : HasFunctionalEquation x \u2227 dL(x) \u2264 B}` is computable for each `B`.\n\n**Test.** For degree-1 L-data with conductor `N \u2264 20` and coefficients in `{-1, 0, 1}`, numerically compute the associated Dirichlet series `L(s) = \u220f_p (1 + a_p p^{-s})^{-1}` at `s = 1/2 + it` for `t \u2208 [0, 50]` and test the predicted functional equation `\u039b(s) = \u03b5 \u00b7 \u039b(1-s)` to within precision `10^{-6}`.\n\n**Impact.** This would bridge the combinatorial census to actual analytic L-functions, showing which L-data correspond to genuine objects and which are \"ghost\" entries in the census.\n\n**Catalog References.** `Speculative/LFunctionUniverse/Defs.lean` (FiniteDescriptionLData, isUnramifiedAt).\n\n**Proof Strategy.** For degree 1, the functional equation reduces to verifying Gauss sum identities, which are computable. For higher degree, use Dokchitser's algorithm for numerical verification of functional equations.\n\n**Domain Bridges.** Complex analysis, computational number theory, algorithmic verification.\n\n**Lineage.** Extends the enumeration (Theorem 4) by adding an analytic verification layer.\n\n**Ambition.** \ud83c\udfd4\ufe0f Grand challenge \u2014 connecting combinatorial L-data to analytic L-functions requires substantial new formalization of complex analysis.\n\n---\n\n## Direction 3: Symbolic Dynamics of Euler Product Sequences\n\n**Conjecture.** Define the *ramification subshift* of an L-datum `x` as the binary sequence `(\u03c3_p)_{p \\text{ prime}}` where `\u03c3_p = 1` if `p` is ramified and `\u03c3_p = 0` otherwise. The key insight is that this subshift always has finitely many 1's (finite support). The space of all such subshifts with at most `k` ones, equipped with the product topology, is compact and zero-dimensional. The map from `FiniteDescriptionLData` to ramification subshifts is continuous (in the discrete topology on the domain), and the image has topological entropy zero.\n\n**Test.** Compute the ramification sequences for all L-data with `dL \u2264 8`. Verify that the number of distinct ramification patterns grows polynomially (not exponentially) in the description-length bound, which would confirm zero topological entropy.\n\n**Impact.** This creates a rigorous bridge between the arithmetic census and symbolic dynamics, potentially allowing techniques from ergodic theory to be applied to families of L-functions.\n\n**Catalog References.** `Speculative/LFunctionUniverse/Defs.lean` (isUnramifiedAt, badPrimes_finite), `Speculative/LFunctionUniverse/Theorems.lean` (ldata_eq_union_strata).\n\n**Proof Strategy.** The finite-support constraint on ramification sequences means the subshift is a subset of the set of eventually-zero sequences, which has entropy zero by standard results. Formalize this using Mathlib's topology on `\u2115 \u2192 Bool` and the entropy theory for subshifts.\n\n**Domain Bridges.** Symbolic dynamics, ergodic theory, topological entropy, combinatorics on words.\n\n**Lineage.** Builds on the badPrimes_finite theorem and the finitely-ramified structure.\n\n**Ambition.** \ud83d\udd2c Solid extension with genuine cross-domain content.\n\n---\n\n## Direction 4: Information-Theoretic Complexity Classes for L-Data\n\n**Conjecture.** Define the *Kolmogorov complexity* of an L-datum `x` as `K(x) = min{|p| : U(p) = encode(x)}` for a fixed universal Turing machine `U`. The key insight is that `K(x) \u2264 C \u00b7 dL(x) + O(1)` for an absolute constant `C` depending on the coefficient type. Furthermore, there exist L-data for which `K(x) \u2265 c \u00b7 dL(x)` (incompressible L-data exist at every complexity level).\n\n**Test.** Implement a compression algorithm for L-data codes (e.g., using arithmetic coding on the field values). Measure the compression ratio `compressed_length / dL(x)` for all L-data with `dL \u2264 7`. If the ratio stays bounded below 1 with a positive lower bound, this supports the conjecture.\n\n**Impact.** This would establish that description length is a faithful proxy for algorithmic complexity, justifying its use as the natural complexity measure for the L-data census. It would also show that \"random\" L-data exist \u2014 objects that cannot be specified more efficiently than by listing all their parameters.\n\n**Catalog References.** `Speculative/LFunctionUniverse/Defs.lean` (descriptionLength), `Speculative/LFunctionUniverse/Theorems.lean` (finite_bounded_descriptionLength, descriptionLength_pos).\n\n**Proof Strategy.** The upper bound `K(x) \u2264 C \u00b7 dL(x) + O(1)` follows from the encoding algorithm: the encoding of each field requires `O(log(field_value))` bits, and the sum of field values is bounded by `dL(x)`. The lower bound uses a counting argument: there are at most `2^n` programs of length `n`, but there are at least `c^B` L-data of description length `B` (from the growth data), so most L-data at level `B` must have `K(x) \u2265 \u03a9(B)`.\n\n**Domain Bridges.** Algorithmic information theory, Kolmogorov complexity, coding theory, data compression.\n\n**Lineage.** Directly extends the finiteness theorem and the description-length filtration.\n\n**Ambition.** \ud83d\udd2c Solid extension with deep connections to theoretical computer science.\n\n**Why now?** The formal encoding/decoding infrastructure proved in Theorem 4 provides exactly the computable representation needed to define Kolmogorov complexity rigorously for L-data.\n\n---\n\n## Direction 5: L-Data Complexity and Zero Distribution (Grand Challenge)\n\n**Conjecture.** For L-data `x` with coefficient type `\u2124` that admit analytic realization as genuine L-functions, the number of non-trivial zeros `\u03c1` with `|Im(\u03c1)| \u2264 T` satisfies:\n\n$$N(T, x) = \\frac{T}{\\pi} \\log\\left(\\frac{\\mathrm{conductor}(x) \\cdot T^{\\mathrm{degree}(x)}}{(2\\pi e)^{\\mathrm{degree}(x)}}\\right) + O(\\log T)$$\n\nThe key insight is that the leading term of the zero-counting function depends *only* on the global parameters (degree and conductor) that are part of the finite description \u2014 not on the specific local factors. Therefore, the zero density is determined by the position of `x` in the complexity filtration.\n\n**Test.** For degree-1 L-data with conductor `N \u2264 50` that match known Dirichlet L-functions, compute `N(T, x)` for `T = 10, 50, 100` using the argument principle. Verify that the leading term matches the prediction with error `O(log T)`.\n\n**Impact.** If proved (or even partially formalized), this would show that the L-data census captures not just the combinatorial structure but also the *spectral structure* of L-functions. It would connect the information-theoretic complexity of an L-datum to the analytic distribution of its zeros \u2014 a bridge between coding theory and the Riemann Hypothesis.\n\n**Catalog References.** `Speculative/LFunctionUniverse/Defs.lean` (degree, conductor, descriptionLength), `Speculative/LFunctionUniverse/Theorems.lean` (degree_le_of_descriptionLength_le, conductor_le_of_descriptionLength_le).\n\n**Proof Strategy.** The zero-counting formula is a classical result (the \"explicit formula\" in the theory of L-functions). The key challenge is formalizing: (i) the analytic continuation of the L-function associated to an L-datum, (ii) the argument principle, and (iii) the resulting zero-counting estimate. This requires substantial complex analysis infrastructure.\n\n**Domain Bridges.** Spectral theory, random matrix theory (connections to GUE statistics of zeros), quantum chaos (Euler products as quantum partition functions), statistical mechanics (free energy and zero distribution).\n\n**Lineage.** Grand challenge that motivates the entire census program \u2014 if successful, it would show that the combinatorial census predicts analytic behavior.\n\n**Ambition.** \ud83c\udf1f Paradigm-shifting \u2014 would connect formal enumeration of L-data to the deepest open problems in analytic number theory.\n\n**Why now?** The formal census provides, for the first time, a machine-verified framework in which to state precise relationships between combinatorial complexity and analytic spectral data. The finiteness theorem ensures that any such relationship can be tested computationally at each complexity level.\n",
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
    "source_exp_id": "f2060cfd",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:48:54.810134+00:00"
  },
  {
    "id": "fd_2066",
    "title": "The prime spectral fingerprint framework establishes a rigorous connection betwe",
    "description": "# Future Directions: Arithmetic-Topological Spectral Inference\n\n## Synthesis\n\nThe prime spectral fingerprint framework establishes a rigorous connection between finite-field linear algebra and real spectral data. The three pillars \u2014 kernel monotonicity, trace transfer, and fingerprint determinacy \u2014 form a coherent pipeline: persistence gives structure, modular arithmetic gives data, and Newton's identities give spectral meaning. The following directions extend this pipeline in five orthogonal dimensions: deeper algebraic recovery, richer topological invariants, connections to quantum computation, statistical phase transitions, and complexity-theoretic implications. Together, they define a research program that could mature arithmetic-topological spectral inference into a systematic tool for spectral geometry, combinatorics, and beyond.\n\n---\n\n## Direction 1: Full Spectral Measure Recovery from Prime Fingerprints\n\n**Conjecture:** For bounded-degree graph families, the prime fingerprint $\\{\\tau_{p,k}(L)\\}_{p \\le P, k \\le m}$ with $P = C \\log N$ and $m = C' \\log N$ determines not just the spectral gap but the entire empirical spectral measure $\\mu_N = \\frac{1}{N}\\sum_i \\delta_{\\lambda_i}$ in the weak-* topology as $N \\to \\infty$.\n\n**Test:** Compute fingerprints for explicit Cayley graph families (e.g., $\\mathrm{SL}_2(\\mathbb{F}_q)$ generators) and verify whether the recovered moments $s_1, \\ldots, s_m$ via trace transfer converge to the moments of the Kesten\u2013McKay distribution. Compare the moment-reconstructed measure (via maximum entropy or Pad\u00e9 approximants) with the true spectral histogram.\n\n**Impact:** This would elevate the fingerprint from a spectral gap estimator to a complete spectral probe. It would enable finite-field computation of heat kernels, zeta functions, and diffusion operators \u2014 all traditionally requiring real eigenvalue decomposition.\n\n**Catalog References:** `Speculative/ArithmeticSpectralFingerprint/FingerprintDeterminacy.lean` (Theorem `fingerprint_determines_moments_single_prime`), `Speculative/ArithmeticSpectralFingerprint/TraceTransfer.lean` (Theorem `tracePow_eq_of_modp_eq`).\n\n**Proof Strategy:** Extend Newton's identities to show that $m$ moments determine $m$ characteristic polynomial coefficients. Use the Hamburger moment problem: a compactly supported measure on $[0, d]$ is determined by its moments. Formalize the moment-coefficient transfer via Newton's identities in Lean, then prove that the moment sequence converges implies the measure converges.\n\n**Domain Bridges:** Connects to random matrix theory (moment method proofs of Wigner semicircle law), free probability (Brown measure), and spectral geometry (Weyl asymptotics).\n\n**Lineage:** Direct extension of Theorem 5.1 (fingerprint determines moments) and Corollary 5.5 (fingerprint determines charpoly prefix).\n\n**Ambition:** Grand challenge \u2014 establishing that finite-field data determines analytic spectral objects would be a paradigm shift in computational spectral theory.\n\n**The key insight is** that moments of compactly supported measures uniquely determine the measure (Hamburger's theorem), so enough fingerprint-recovered moments are enough.\n\n**Why now?** The trace transfer theorem is now formally verified, providing the rigorous foundation. Moment-to-measure reconstruction algorithms (Pad\u00e9, MaxEnt) are mature. What's missing is the formal bridge from finite moments to measure convergence in the Lean framework.\n\n---\n\n## Direction 2: Fingerprint Collisions and Spectral Correspondences\n\n**Conjecture:** If two non-isomorphic bounded-degree complexes $X, Y$ have identical prime fingerprints up to level $m = \\omega(\\log N)$, then there exists an explicit algebraic correspondence (e.g., a Hecke operator relation, a covering map, or a common spectral base) explaining the collision.\n\n**Test:** Systematically search for fingerprint collisions among: (1) non-isomorphic strongly regular graphs, (2) Sunada triples producing isospectral but non-isometric manifolds, (3) pairs of Cayley graphs from different groups with the same character table. For any collision found, verify whether a known algebraic mechanism explains it.\n\n**Impact:** Would characterize the *limits* of fingerprint distinguishing power and connect fingerprint theory to the graph isomorphism problem, spectral rigidity, and algebraic number theory.\n\n**Catalog References:** `Speculative/ArithmeticSpectralFingerprint/Defs.lean` (Definition `PrimeFingerprintEqUpTo`), `Speculative/ArithmeticSpectralFingerprint/FingerprintDeterminacy.lean`.\n\n**Proof Strategy:** For Sunada-type constructions, the key is that isospectral manifolds have identical traces of powers by definition. Prove that fingerprint collision implies charpoly equality (done for fixed matrix size); then ask when charpoly equality implies isospectrality fails to imply isomorphism. The gap between \"same fingerprint\" and \"same structure\" is precisely the space of algebraic correspondences.\n\n**Domain Bridges:** Graph isomorphism testing, algebraic number theory (Gassmann triples, Brauer relations), differential geometry (isospectral problem, \"Can one hear the shape of a drum?\").\n\n**Lineage:** Extension of Corollary 5.5 (fingerprint \u2192 charpoly prefix equality) and the determinacy conjecture.\n\n**Ambition:** Grand challenge \u2014 this could provide a new invariant for the graph isomorphism problem and connect to deep questions in spectral geometry.\n\n**The key insight is** that fingerprint collisions are not random accidents but manifestations of hidden algebraic structure (Gassmann equivalences, Hecke algebra relations, or covering correspondences).\n\n**Why now?** The formal framework makes \"same fingerprint\" a precise, checkable condition. Computational search over known families of isospectral pairs is feasible with current tools.\n\n---\n\n## Direction 3: Fingerprint Certification of Quantum LDPC Code Parameters\n\n**Conjecture:** For families of quantum LDPC codes constructed from high-dimensional expanders (e.g., Panteleev\u2013Kalachev, Leverrier\u2013Z\u00e9mor), the mod-$p$ fingerprints of the constituent chain complex Laplacians certify the code distance and rate up to explicit bounds.\n\n**Test:** Implement fingerprint computation for the Laplacians of known quantum LDPC code complexes (e.g., hypergraph products, balanced products). Compare fingerprint-predicted spectral gaps with the actual code distance. Check whether fingerprint data detects the cosystolic expansion that governs code distance.\n\n**Impact:** Would provide a fast, exact, parallelizable alternative to the current expensive methods for verifying quantum code parameters. Could enable automated validation of quantum code constructions at scale.\n\n**Catalog References:** `Speculative/ArithmeticSpectralFingerprint/KernelMonotonicity.lean` (persistent nullity as barcode surrogate), `Speculative/ArithmeticSpectralFingerprint/FingerprintDeterminacy.lean` (heat trace control).\n\n**Proof Strategy:** Quantum LDPC code distance relates to the cosystolic expansion of the underlying complex, which is controlled by spectral gaps of higher Laplacians. Formalize the chain: fingerprint \u2192 moments \u2192 spectral gap \u2192 cosystolic expansion \u2192 code distance. The first two steps are done; the latter two require formalizing the Cheeger-type inequality for higher-dimensional expansion.\n\n**Domain Bridges:** Quantum error correction, topological quantum computing, coding theory, homological algebra.\n\n**Lineage:** Builds on persistent nullity (for chain complex kernels) and the trace transfer theorem (for Laplacian spectral gap estimation).\n\n**Ambition:** Solid extension \u2014 connects directly to an active area of quantum computing research and could have immediate practical impact.\n\n**The key insight is** that quantum LDPC code distance is controlled by spectral expansion of chain complex Laplacians, which is exactly what prime fingerprints measure.\n\n**Why now?** The quantum LDPC revolution (Panteleev\u2013Kalachev 2022, Leverrier\u2013Z\u00e9mor 2022) creates urgent demand for efficient code verification tools. The fingerprint framework provides exactly the computational paradigm needed.\n\n---\n\n## Direction 4: Phase Transitions in Random Complex Fingerprints\n\n**Conjecture:** For the Linial\u2013Meshulam model of random 2-complexes on $n$ vertices with edge probability $p(n)$, the prime fingerprint of the 1-Laplacian undergoes a sharp phase transition at the homological connectivity threshold $p \\sim \\log n / n$. Below the threshold, the mod-$p$ fingerprint detects nontrivial $H_1$ (manifesting as persistent kernel dimensions); above it, the fingerprint converges to a universal profile determined by the complete complex.\n\n**Test:** Generate random Linial\u2013Meshulam complexes for $n = 20, 50, 100$ at various edge probabilities. Compute prime fingerprints and track: (a) the mod-$p$ kernel dimensions of the 1-Laplacian, (b) the fingerprint distance from the complete complex fingerprint. Plot as a function of $p(n)$ and check for threshold behavior near $\\log n / n$.\n\n**Impact:** Would connect the fingerprint framework to probabilistic combinatorics and demonstrate that fingerprints can detect topological phase transitions \u2014 a fundamentally new application of the arithmetic-topological paradigm.\n\n**Catalog References:** `Speculative/ArithmeticSpectralFingerprint/KernelMonotonicity.lean` (monotonicity ensures well-defined filtration profiles across the random model), `Speculative/ArithmeticSpectralFingerprint/Defs.lean` (fingerprint definitions).\n\n**Proof Strategy:** Use the Linial\u2013Meshulam\u2013Wallach theorem on the homological connectivity threshold. Show that above the threshold, all $\\mathbb{F}_p$-homology vanishes w.h.p., forcing the fingerprint to match the acyclic case. Below the threshold, nontrivial cycles create kernel dimension jumps detectable in the fingerprint. The formal argument combines concentration inequalities with the rank-nullity identity.\n\n**Domain Bridges:** Probabilistic combinatorics, statistical mechanics (percolation theory), random topology, signal processing (compressed sensing analogies).\n\n**Lineage:** Extends the persistent nullity profile to a probabilistic setting where the \"filtration\" is over the randomness parameter rather than operator powers.\n\n**Ambition:** Solid extension \u2014 the tools are available and the prediction is sharp enough to test computationally.\n\n**The key insight is** that the topological phase transition (homological connectivity) has an exact arithmetic shadow: the vanishing of mod-$p$ kernel dimensions for all $p$ simultaneously.\n\n**Why now?** The Linial\u2013Meshulam theory is mature enough to provide precise threshold predictions. The fingerprint framework gives the right language to detect these thresholds using finite-field algebra.\n\n---\n\n## Direction 5: Arithmetic Persistence and Complexity Barriers\n\n**Conjecture:** Computing the prime fingerprint of a matrix $A \\in M_n(\\mathbb{Z})$ up to level $m = n$ is at least as hard as computing the determinant of $A$, but recovering individual eigenvalues from the fingerprint is at least as hard as factoring the characteristic polynomial over $\\mathbb{Z}$.\n\n**Test:** (1) Reduce determinant computation to fingerprint computation by showing $\\det(A) = (-1)^n \\chi_A(0)$ is recoverable from fingerprints via Newton's identities (already partially done). (2) Conversely, show that fingerprint computation can be done in the same complexity class as matrix multiplication over $\\mathbb{F}_p$ (i.e., $O(n^\\omega)$ per prime per power). (3) Investigate whether there exist matrices whose fingerprints are easy to compute but whose eigenvalues are hard to extract \u2014 this would prove a complexity separation.\n\n**Impact:** Would place the fingerprint framework in the landscape of computational complexity, clarifying exactly what it can and cannot compute efficiently. Could reveal connections between spectral computation and algebraic complexity theory.\n\n**Catalog References:** `Speculative/ArithmeticSpectralFingerprint/FingerprintDeterminacy.lean` (Theorem `det_eq_charpoly_constantCoeff`), `Speculative/ArithmeticSpectralFingerprint/TraceTransfer.lean` (complexity of the transfer step).\n\n**Proof Strategy:** The upper bound (fingerprint \u2264 matrix multiplication) follows from the algorithm in \u00a77.1. The lower bound (determinant \u2264 fingerprint) follows from the characteristic polynomial recovery. The separation question reduces to: is factoring $\\chi_A(x)$ over $\\mathbb{Z}$ strictly harder than computing its coefficients? This connects to Lenstra\u2013Lenstra\u2013Lov\u00e1sz (LLL) lattice basis reduction and the complexity of polynomial factoring.\n\n**Domain Bridges:** Computational complexity, algebraic complexity theory (Strassen, Valiant), lattice algorithms (LLL), cryptography (hardness assumptions based on lattice problems).\n\n**Lineage:** Extends the determinant-from-charpoly theorem and the Newton's identity pipeline to a complexity-theoretic analysis.\n\n**Ambition:** Grand challenge \u2014 rigorously separating the complexity of moments from the complexity of individual eigenvalues would be a significant result in algebraic complexity theory.\n\n**The key insight is** that the fingerprint encodes the *symmetric functions* of eigenvalues (moments, elementary symmetric polynomials) but not the eigenvalues themselves \u2014 and the gap between symmetric functions and roots may be a genuine complexity barrier.\n\n**Why now?** Recent advances in algebraic complexity (matrix multiplication exponents, polynomial factoring algorithms) provide the technical tools. The fingerprint framework gives a concrete instantiation of the \"symmetric vs. individual\" distinction.\n",
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
    "source_exp_id": "269c24bd",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:49:13.936278+00:00"
  },
  {
    "id": "fd_2068",
    "title": "The formal spectral moonshine framework established here \u2014 class function inner ",
    "description": "# Future Directions: Formal Spectral Moonshine\n\n## Synthesis\n\nThe formal spectral moonshine framework established here \u2014 class function inner products, moonshine packets, Fourier inversion, and multiplicity decoding \u2014 opens a systematic research program at the intersection of representation theory, number theory, harmonic analysis, and formal verification. The five directions below form a coherent progression: from completing the algebraic foundations (Directions 1\u20132), through connecting to deeper mathematical structures (Direction 3), to bridging entirely different scientific domains (Directions 4\u20135). Each builds on the verified theorems in `Speculative/Moonshine/Defs.lean` and `Speculative/Moonshine/Theorems.lean`, using the moonshine packet formalism as the organizing data structure.\n\n---\n\n## Direction 1: Full Character Orthogonality from First Principles\n\n**Conjecture:** The orthogonality of irreducible characters \u2014 currently taken as a hypothesis (`IsOrthonormal`, `IsCompleteOrthonormal`) \u2014 can be derived from Schur's lemma and the averaging trick, yielding a fully self-contained character theory in Lean.\n\n**The key insight is** that Schur's lemma (every G-equivariant endomorphism of an irreducible representation is a scalar) combined with the projection formula P_\u03c7 = (dim \u03c7 / |G|) \u03a3 \u03c7(g\u207b\u00b9) \u03c1(g) yields character orthogonality as a corollary, not an axiom. Formalizing this removes the main remaining hypothesis from all our theorems.\n\n**Why now?** Mathlib's representation theory infrastructure (`Representation`, `Module.End`, `LinearMap.trace`) provides the raw ingredients. The gap is in connecting trace computations to Finset sums, which our `ClassFn` framework is designed to bridge.\n\n**Test:** Formalize Schur's lemma for `Representation \u2102 G V` where V is a simple module, then derive `\u27e8\u03c7\u1d62, \u03c7\u2c7c\u27e9 = \u03b4\u1d62\u2c7c` as a theorem rather than a hypothesis.\n\n**Impact:** Eliminates all hypotheses from our main theorems, making them unconditional.\n\n**Catalog References:** `Speculative/Moonshine/Defs.lean` (ClassFn.cfInner), `Speculative/Moonshine/Theorems.lean` (IsOrthonormal, IsCompleteOrthonormal)\n\n**Proof Strategy:** (1) Prove Schur's lemma using simplicity of the representation. (2) Construct the averaging projection. (3) Compute its trace. (4) Extract orthogonality from trace comparison.\n\n**Domain Bridges:** Linear algebra, module theory\n\n**Lineage:** Extends `ClassFn.cfInner_comm`, `cfInner_add_left`, `cfInner_smul_left`\n\n**Ambition:** Extension \u2014 completing the algebraic foundation\n\n---\n\n## Direction 2: Replicability as Algebraic Structure\n\n**Conjecture:** The replication formulas that characterize McKay-Thompson series among all modular functions can be formalized as algebraic identities on moonshine packets, independent of analytic modularity.\n\n**The key insight is** that replicability \u2014 the condition that a q-series satisfies specific Hecke-type recursions relating its coefficients at different levels \u2014 is an algebraic condition on the coefficient class functions, not an analytic property. It can be formalized as a predicate `IsReplicable : MoonshinePacket G \u2102 \u2192 Prop` that constrains the relationship between coefficients at degrees n, mn, and n/m.\n\n**Why now?** Our `MoonshinePacket` structure provides the right data type, and the multiplicity decoder provides the computational tool to verify replicability for specific groups.\n\n**Test:** Define `IsReplicable` and verify it computationally for the j-function coefficients (trivial group case, where the packet reduces to a single q-series).\n\n**Impact:** Separates the algebraic content of moonshine (replication) from the analytic content (modularity), enabling formalization of the algebraic half independently.\n\n**Catalog References:** `Speculative/Moonshine/Defs.lean` (MoonshinePacket), `Speculative/Moonshine/Theorems.lean` (MoonshinePacket.ext)\n\n**Proof Strategy:** (1) Define Hecke operators on moonshine packets. (2) Formalize replication as a fixed-point condition. (3) Prove that replicable packets form a subalgebra.\n\n**Domain Bridges:** Number theory (Hecke operators), algebraic combinatorics (Adams operations)\n\n**Lineage:** Extends MoonshinePacket extensionality\n\n**Ambition:** Grand challenge \u2014 creating the algebraic essence of moonshine\n\n---\n\n## Direction 3: Modular Forms Connection via Spectral Zeta Functions\n\n**Conjecture:** For a finite group G and a moonshine packet T, the spectral zeta function Z(s) = \u03a3_n |\u27e8a\u2099, \u03c7\u27e9|\u00b2 n\u207b\u02e2 (summing spectral weights against a fixed irreducible \u03c7) has meromorphic properties that reflect the modularity of T when T is a genuine McKay-Thompson series.\n\n**The key insight is** that the spectral weights |\u27e8a\u2099, \u03c7\u27e9|\u00b2 are real non-negative numbers that grow polynomially in n (for moonshine-type series), making them suitable input to Dirichlet series. The analytic properties of the resulting zeta function encode both the representation-theoretic structure (via \u03c7) and the modular structure (via growth rates and poles).\n\n**Why now?** The spectral weight definition is already verified (`spectralWeight` in Defs.lean), and Mathlib has growing infrastructure for Dirichlet series and L-functions.\n\n**Test:** Compute the spectral zeta function numerically for the j-function (using known coefficients up to degree 1000) and check for poles at predicted locations.\n\n**Impact:** Creates a new invariant of moonshine packets that detects modularity spectral-theoretically.\n\n**Catalog References:** `Speculative/Moonshine/Defs.lean` (spectralWeight), `Speculative/Moonshine/Theorems.lean` (classFn_parseval)\n\n**Proof Strategy:** (1) Define spectral zeta functions formally. (2) Prove convergence for packets with polynomial coefficient growth. (3) Relate poles to dimensions of fixed-point subspaces.\n\n**Domain Bridges:** Analytic number theory (L-functions), spectral theory (zeta regularization)\n\n**Lineage:** Extends spectralWeight and classFn_parseval\n\n**Ambition:** Grand challenge \u2014 bridging algebra and analysis\n\n---\n\n## Direction 4: Quantum Symmetry Fingerprinting\n\n**Conjecture:** The spectral fingerprint of a quantum system's symmetry group (the normalized vector of spectral weights for its Hamiltonian's character) serves as a complete invariant for distinguishing inequivalent quantum phases with the same symmetry group, at least for finite symmetry groups.\n\n**The key insight is** that two quantum Hamiltonians can share the same symmetry group G but distribute their energy levels differently across irreducible representations. The spectral fingerprint captures this distribution with provable invariance properties (our `spectralWeight_eq_of_classFn_eq`). Different quantum phases correspond to different points in the simplex of spectral fingerprints.\n\n**Why now?** Quantum computing hardware is reaching the scale where symmetry classification of quantum states becomes practical, and our verified framework provides the mathematical foundation.\n\n**Test:** Compute spectral fingerprints for the spin-1/2 Heisenberg model on small lattices with S\u2083 or S\u2084 symmetry. Check whether phase transitions correspond to discontinuities in the fingerprint.\n\n**Impact:** Creates a new tool for quantum phase classification grounded in verified mathematics.\n\n**Catalog References:** `Speculative/Moonshine/Defs.lean` (spectralWeight), `Speculative/Moonshine/Theorems.lean` (spectralWeight_eq_of_classFn_eq, classFn_parseval)\n\n**Proof Strategy:** (1) Define phase equivalence via spectral fingerprint proximity. (2) Prove continuity of spectral fingerprints under continuous deformations of Hamiltonians. (3) Show that topological phase transitions manifest as discontinuities.\n\n**Domain Bridges:** Quantum physics, condensed matter theory, topological order\n\n**Lineage:** Extends spectralWeight to quantum mechanical applications\n\n**Ambition:** Grand challenge \u2014 bridging representation theory and quantum physics\n\n---\n\n## Direction 5: Machine Learning on Symmetry Spectra\n\n**Conjecture:** Neural networks trained on spectral fingerprints of class functions can learn to predict group-theoretic properties (solvability, simplicity, character table structure) from moonshine packet data alone, achieving better sample efficiency than networks trained on raw group presentations.\n\n**The key insight is** that the spectral fingerprint is a fixed-dimensional feature vector (dimension = number of irreducibles) that captures the essential representation-theoretic content of any class function. This makes it a natural input format for machine learning, analogous to how Fourier spectra are natural inputs for audio processing.\n\n**Why now?** The intersection of ML and mathematics is rapidly growing, but existing approaches lack verified mathematical foundations. Our framework provides provably correct feature extraction (the multiplicity decoder) that can serve as a preprocessing step for ML pipelines.\n\n**Test:** Train a classifier on spectral fingerprints of random class functions from groups of order \u2264 100. Evaluate whether it can distinguish simple groups from non-simple groups with high accuracy.\n\n**Impact:** Creates a verified bridge between representation theory and machine learning, enabling provably correct feature engineering for group-theoretic ML tasks.\n\n**Catalog References:** `Speculative/Moonshine/Theorems.lean` (decodeMultiplicities_correct, classFn_fourier_expansion)\n\n**Proof Strategy:** (1) Prove that spectral fingerprints are complete invariants for class functions (follows from Fourier inversion). (2) Show that the decoder is Lipschitz continuous (stability for ML). (3) Bound the sample complexity of learning from spectral data.\n\n**Domain Bridges:** Machine learning, computational group theory, data science\n\n**Lineage:** Extends decodeMultiplicities_correct to practical applications\n\n**Ambition:** Extension \u2014 applying verified algorithms to ML\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Physics",
      "Cryptography",
      "Bridges",
      "MachineLearning",
      "Logic",
      "Speculative"
    ],
    "priority_score": 1.0,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "18f31ae2",
    "consumed_by_exp_id": "90b1738b",
    "timestamp": "2026-05-29T07:28:29.504284+00:00"
  },
  {
    "id": "fd_2063",
    "title": "The descent pipeline established in this work \u2014 weighted log-concavity + weight-",
    "description": "# Future Directions: Weighted-to-Unweighted Descent for Lorentzian Shadows\n\n## Synthesis\n\nThe descent pipeline established in this work \u2014 weighted log-concavity + weight-ratio log-convexity \u27f9 unweighted log-concavity \u2014 creates a modular framework for transferring algebraic properties from \"easy\" weighted counts to \"hard\" unweighted counts. The computational experiments reveal that the naive weight ratio fails to be log-convex for matroid basis polynomials, pointing toward a **normalized descent conjecture** as the key open problem. The descending factorial log-concavity theorem provides the algebraic foundation for such normalization. Five concrete research directions emerge, ranging from immediate extensions (Direction 1) to paradigm-shifting conjectures (Direction 5), all testable and falsifiable.\n\n---\n\n## Direction 1: Normalized Descent for Lorentzian Polynomials\n\n**Conjecture:** For a homogeneous Lorentzian polynomial $f$ of degree $d$ in $n$ variables, the normalized weight ratio\n$$\\tilde{r}_k = \\frac{W_k(f)}{\\binom{n}{k} \\cdot d^{\\underline{k}}}$$\nis log-convex in $k$ for $1 \\leq k \\leq d-1$.\n\n**Test:** Compute $\\tilde{r}_k$ for the basis polynomial of the uniform matroid $U_{3,7}$ and the Fano matroid $F_7$. Verify $\\tilde{r}_k^2 \\leq \\tilde{r}_{k-1} \\cdot \\tilde{r}_{k+1}$ for $k = 1, \\ldots, d-2$. A single matroid failure disproves the conjecture.\n\n**Impact:** Would complete the descent pipeline for Lorentzian polynomials, giving a new proof of the Mason conjecture and extending it to all Lorentzian polynomial shadows.\n\n**Catalog References:**\n- `Pythagorean/WeightedDescentLorentzian.lean`: `descFactorial_sq_ge`, `descent_inequality`\n- `Pythagorean/IteratedShadowGeometry.lean`: `coeff_iteratedPDeriv`, `descFactorial_prod_pos`\n\n**Proof Strategy:** Express $\\tilde{r}_k$ as a ratio of integrals over the Lorentzian cone. Use the Hodge-Riemann bilinear relations to show the integrand satisfies a Cauchy-Schwarz inequality, which translates to log-convexity of $\\tilde{r}_k$.\n\n**Domain Bridges:** Algebraic geometry (Hodge theory), convex geometry (mixed volumes), probability (moment problems).\n\n**Lineage:** Extends `descFactorial_sq_ge` and `descent_inequality` by providing the missing ingredient (normalized ratio log-convexity).\n\n**Ambition:** \u2605\u2605\u2605\u2605 \u2014 Would resolve a key gap in Lorentzian polynomial theory.\n\n---\n\n## Direction 2: Iterated Descent and Fixed-Point Sequences\n\n**Conjecture:** Define the \"descent operator\" $\\mathcal{D}$ that maps a log-concave sequence $(a_k)$ to the sequence of ratios $a_k / a_{k-1}$. For Lorentzian polynomial shadow sequences, the iterated descent $\\mathcal{D}^m(\\text{Sh}_k)$ converges to a geometric sequence as $m \\to \\infty$.\n\n**Test:** For the uniform matroid $U_{4,8}$, compute $\\text{Sh}_k$, then $\\mathcal{D}(\\text{Sh}_k) = \\text{Sh}_k/\\text{Sh}_{k-1}$, then $\\mathcal{D}^2(\\text{Sh}_k)$, etc. Check if the sequence stabilizes (ratios become constant).\n\n**Impact:** Would establish a new invariant of Lorentzian polynomials \u2014 the \"descent fixed point\" \u2014 potentially classifying them by their asymptotic ratio.\n\n**Catalog References:**\n- `Pythagorean/WeightedDescentLorentzian.lean`: `DescentData`, `log_concave_of_descent_data`\n\n**Proof Strategy:** Model the descent operator as a contraction mapping on the space of log-concave sequences. Use the Banach fixed-point theorem to prove convergence. The key estimate is that $\\mathcal{D}$ reduces the \"log-concavity gap\" by a factor related to the descending factorial ratio $(x-k+1)/(x-k)$.\n\n**Domain Bridges:** Dynamical systems (contraction mappings), functional analysis (operator theory).\n\n**Lineage:** Natural iteration of the descent pipeline from `log_concave_of_descent_data`.\n\n**Ambition:** \u2605\u2605\u2605 \u2014 Accessible and testable, with potentially deep connections.\n\n---\n\n## Direction 3: Tropical Brunn-Minkowski via Shadow Sequences\n\n**Conjecture (Grand Challenge):** The shadow sequence $(\\text{Sh}_0, \\text{Sh}_1, \\ldots, \\text{Sh}_d)$ of a Lorentzian polynomial satisfies a **tropical Brunn-Minkowski inequality**: for the support $A = \\text{Supp}(f)$,\n$$|\\text{Sh}_k(A)|^{1/k} \\geq |\\text{Sh}_1(A)|/|A|$$\nThis is a tropical analog of the classical Brunn-Minkowski inequality $|A+B|^{1/n} \\geq |A|^{1/n} + |B|^{1/n}$, where the \"addition\" is replaced by shadow projection.\n\n**Test:** Compute $|\\text{Sh}_k|^{1/k}$ for various matroid support sets. Verify the inequality against $|\\text{Sh}_1|/|A|$. Test on random Lorentzian polynomial supports with $n \\leq 8$.\n\n**Impact:** Would establish a fundamental inequality in tropical geometry with applications to discrete optimization and lattice point counting.\n\n**Catalog References:**\n- `Pythagorean/IteratedShadowGeometry.lean`: `kthShadow`, `kthShadow_add`\n\n**Proof Strategy:** Use the semigroup law `kthShadow_add` to decompose $\\text{Sh}_k$ as iterated 1-shadows. Apply the submodularity of the shadow operator (if provable) to establish the inequality via an inductive argument.\n\n**Domain Bridges:** Convex geometry (Brunn-Minkowski), tropical geometry, discrete optimization.\n\n**Lineage:** Builds on `kthShadow_add` and the shadow profile theory from IteratedShadowGeometry.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 \u2014 Paradigm-shifting if true. Would unify tropical and classical convex geometry.\n\n---\n\n## Direction 4: R\u00e9nyi Entropy Descent and Information-Theoretic Log-Concavity\n\n**Conjecture:** The weight ratio $r_k = W_k/\\text{Sh}_k$ is related to the exponential of the R\u00e9nyi entropy of order $\\alpha = 1$ of the \"derivative distribution\" $p_\\gamma = |\\text{supp}(\\partial^\\gamma f)| / W_k$. Specifically:\n$$r_k = \\exp(H_1(\\{p_\\gamma\\}_\\gamma))$$\nwhere $H_1$ is the Shannon entropy. The log-convexity (or concavity) of $r_k$ then translates to a monotonicity property of the entropy, analogous to the data processing inequality.\n\n**Test:** For each matroid, compute the distribution $p_\\gamma$ and its Shannon entropy at each level $k$. Check if the entropy sequence $H_k$ is concave (which would imply $r_k$ is log-concave, consistent with our computational findings).\n\n**Impact:** Would bridge combinatorial log-concavity theory with information theory, potentially providing new proofs via entropy methods.\n\n**Catalog References:**\n- `Pythagorean/WeightedDescentLorentzian.lean`: `descent_inequality`, weight ratio analysis\n\n**Proof Strategy:** Express $r_k$ as an exponential of the Shannon entropy of the derivative distribution. Use the data processing inequality to bound how entropy changes under the derivative operation. The Lorentzian condition translates to a \"negative curvature\" condition on the entropy landscape.\n\n**Domain Bridges:** Information theory (R\u00e9nyi entropy, data processing), probability (log-concave distributions), statistical mechanics.\n\n**Lineage:** Extends the weight ratio analysis from `descent_inequality` to an information-theoretic setting.\n\n**Ambition:** \u2605\u2605\u2605\u2605 \u2014 Cross-domain bridge between two major theories.\n\n---\n\n## Direction 5: Universal Log-Concavity Classifier via Descent Data\n\n**Conjecture (Grand Challenge):** Every log-concave sequence arising from a \"natural\" combinatorial source (matroid invariants, graph polynomials, symmetric function coefficients) admits a `DescentData` decomposition with a suitable normalization. More precisely, there exists a universal normalization function $N(k, \\text{parameters})$ such that:\n1. The weighted sequence $W_k = N(k) \\cdot a_k$ is always log-concave.\n2. The normalization $N(k)$ is always log-convex.\n3. Hence $a_k$ is log-concave by the descent pipeline.\n\n**Test:** For each of the following sequences, attempt to find $N(k)$: (a) independent set counts of a matroid, (b) face numbers of a simplicial complex, (c) coefficients of the chromatic polynomial, (d) Kazhdan-Lusztig coefficients. If any natural log-concave sequence resists all normalizations, the conjecture is false.\n\n**Impact:** Would provide a \"master theorem\" explaining all combinatorial log-concavity as instances of the descent pipeline, analogous to how the transfer matrix method unifies many sequence enumeration problems.\n\n**Catalog References:**\n- `Pythagorean/WeightedDescentLorentzian.lean`: `DescentData`, `log_concave_of_descent_data`\n\n**Proof Strategy:** Start with the simplest case (matroid independent sets) where the normalization should involve descending factorials and binomial coefficients. Extend to simplicial complexes using the algebraic shifting technique. For Kazhdan-Lusztig coefficients, the normalization likely involves $q$-analogs of descending factorials.\n\n**Domain Bridges:** Representation theory (Kazhdan-Lusztig), algebraic topology (simplicial complexes), algebraic combinatorics (symmetric functions).\n\n**Lineage:** Ultimate generalization of the `DescentData` structure.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 \u2014 Would be a fundamental contribution to algebraic combinatorics.\n\n---\n\n## Summary of Priorities\n\n| Priority | Direction | Testability | Ambition |\n|----------|-----------|-------------|----------|\n| 1 | Normalized descent conjecture | Immediate | \u2605\u2605\u2605\u2605 |\n| 2 | Iterated descent fixed points | Immediate | \u2605\u2605\u2605 |\n| 3 | Tropical Brunn-Minkowski | Medium-term | \u2605\u2605\u2605\u2605\u2605 |\n| 4 | R\u00e9nyi entropy descent | Medium-term | \u2605\u2605\u2605\u2605 |\n| 5 | Universal log-concavity classifier | Long-term | \u2605\u2605\u2605\u2605\u2605 |\n\nThe key insight tying all directions together is that **log-concavity is not a single phenomenon but a family of related phenomena**, connected by the descent pipeline. Each direction explores a different facet of this family, and progress on any one direction is likely to inform the others.\n\nWhy now? The formal verification of the descent inequality and descending factorial log-concavity provides a solid foundation. The computational experiments have identified the exact boundary where the naive pipeline fails, giving precise targets for the normalized conjecture. And the `DescentData` structure provides the right abstraction for exploring generalizations.\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Cryptography",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "97b8eea0",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:48:09.234495+00:00"
  },
  {
    "id": "fd_2067",
    "title": "The restricted \u0141o\u015b transfer framework established here \u2014 connecting finite matri",
    "description": "# Future Directions: Pseudofinite Transfer via Definable Ultraproducts\n\n## Synthesis\n\nThe restricted \u0141o\u015b transfer framework established here \u2014 connecting finite matrix group combinatorics to pseudofinite structural theorems \u2014 opens five natural research directions spanning model theory, additive combinatorics, algebraic group theory, and computational complexity. The common thread is that **definability controls transfer**: properties expressible in restricted formal languages survive passage to infinite limits, and the complexity of the defining formula bounds the complexity of the transferred structure. This insight unifies the directions below, from extending the formula language (Direction 1) to discovering new transfer principles computationally (Direction 5).\n\n---\n\n## Direction 1: Bounded Quantifier \u0141o\u015b and Hrushovski Stabilizers\n\n**Conjecture**: The restricted \u0141o\u015b theorem extends to a bounded-quantifier fragment (existential and universal quantifiers ranging over definable sets) with a clean structural induction proof, and this extension suffices to formalize Hrushovski's model-theoretic stabilizer construction for pseudofinite groups.\n\n**The key insight is** that bounded quantifiers over definable sets can be handled by combining the existing Boolean closure lemmas with a choice-based witness extraction from ultrafilter-large sets, as demonstrated in the companion `BoundedPseudofiniteTransfer.lean` file.\n\n**Why now?** The base propositional transfer is now formally verified, and the bounded quantifier extension has been prototyped (see `Catalog/Pythagorean/BoundedPseudofiniteTransfer.lean`). The gap to Hrushovski stabilizers requires only: (1) defining stabilizer chains in the pseudofinite setting, (2) proving that definable stabilizers have bounded index, (3) extracting a connected component theorem.\n\n**Test**: Formalize the statement \"if A is a K-approximate subgroup of a pseudofinite group G, then there exists a definable subgroup H with [A : H] \u2264 f(K)\" and verify it compiles with the bounded-quantifier transfer engine.\n\n**Impact**: Would complete the first verified path from finite approximate group theorems to pseudofinite structure theorems \u2014 a cornerstone of modern additive combinatorics.\n\n**Catalog References**: `Pythagorean/PseudofiniteTransfer/Transfer.lean`, `Catalog/Pythagorean/BoundedPseudofiniteTransfer.lean`\n\n**Proof Strategy**: Extend `BoundedRestrictedFormula` with a stabilizer-chain constructor, prove \u0141o\u015b by extending the existing induction, then formalize Hrushovski's intersection argument.\n\n**Domain Bridges**: Model theory \u2194 Additive combinatorics \u2194 Algebraic group theory\n\n**Lineage**: Builds directly on Theorems 4.1 and 4.5 of the current work.\n\n**Ambition**: Grand challenge \u2014 would resolve a central open formalization problem.\n\n---\n\n## Direction 2: Helfgott's Growth Theorem for SL(2, \ud835\udd3d_p) \u2014 Full Formalization\n\n**Conjecture**: Helfgott's theorem \u2014 that for every \u03b5 > 0 there exists \u03b4 > 0 such that every generating set A of SL(2, \ud835\udd3d_p) with |A| < |SL(2, \ud835\udd3d_p)|^{1-\u03b5} satisfies |A\u00b3| \u2265 |A|^{1+\u03b4} \u2014 can be formalized in Lean 4 using the sum-product theorem over \ud835\udd3d_p and the Larsen-Pink nonconcentration inequality.\n\n**The key insight is** that the proof decomposes into four independent components: (1) the sum-product theorem, (2) nonconcentration on subvarieties, (3) the escape lemma, and (4) the growth amplification argument \u2014 each of which is individually tractable.\n\n**Why now?** The transfer framework provides the pseudofinite application that motivates the formalization, and recent Lean 4 / Mathlib developments provide the algebraic geometry infrastructure (varieties over finite fields, dimension theory) needed for the Larsen-Pink inequality.\n\n**Test**: Formalize the sum-product theorem over \ud835\udd3d_p: for A \u2286 \ud835\udd3d_p with |A| < p^{1/2}, max(|A+A|, |A\u00b7A|) \u2265 c|A|^{1+\u03b5}.\n\n**Impact**: Would produce the first machine-verified growth theorem for a family of finite simple groups, completing the finite input to the transfer pipeline.\n\n**Catalog References**: `Pythagorean/PseudofiniteTransfer/Transfer.lean`, `Catalog/Pythagorean/HelfgottGrowth.lean`, `Catalog/Pythagorean/HelfgottSL2.lean`\n\n**Proof Strategy**: Formalize Bourgain-Katz-Tao or Rudnev's sum-product, then the escape lemma, then combine with the growth amplification bootstrap.\n\n**Domain Bridges**: Number theory \u2194 Additive combinatorics \u2194 Algebraic geometry\n\n**Lineage**: Provides the finite-field input for Theorem 4.5.\n\n**Ambition**: Solid extension \u2014 challenging but well-understood mathematically.\n\n---\n\n## Direction 3: Transfer Principles for Expansion and Spectral Gaps\n\n**Conjecture**: The restricted \u0141o\u015b transfer framework can be extended to transport spectral gap bounds for Cayley graphs of definable families. Specifically, if the Cayley graphs Cay(G_i, A_i) have spectral gap \u2265 \u03b5 for ultrafilter-many i, then the pseudofinite Cayley graph inherits an analogous expansion property.\n\n**The key insight is** that spectral gap can be encoded as a definable property via the Cheeger inequality: expansion ratio \u2265 \u03bb\u2082/2, where \u03bb\u2082 is the second eigenvalue, and expansion ratio is a finite combinatorial condition expressible in the restricted formula language (it involves ratios of set sizes under boundary operations).\n\n**Why now?** The Boolean closure lemmas (Lemmas 3.1\u20133.3) already handle the logical structure needed for expansion conditions, and the transfer of cardinality comparisons (Theorem 4.3) provides the quantitative backbone.\n\n**Test**: Define a `RestrictedFormula` encoding of edge expansion for Cayley graphs and prove its \u0141o\u015b transfer. Verify computationally that Cayley graphs of the three test families have stable spectral gaps.\n\n**Impact**: Would connect the pseudofinite transfer framework to the Lubotzky\u2013Weiss program on property (\u03c4) and Ramanujan graphs, opening a verified path from finite expansion to pseudofinite Kazhdan property.\n\n**Catalog References**: `Pythagorean/PseudofiniteTransfer/Transfer.lean`, `Catalog/Pythagorean/BerggrenRamanujanExpander.lean`\n\n**Proof Strategy**: Encode expansion as a restricted formula, apply Theorem 4.1, then connect to spectral gap via Cheeger's inequality.\n\n**Domain Bridges**: Spectral graph theory \u2194 Model theory \u2194 Representation theory\n\n**Lineage**: Extends Theorem 4.1 to a new class of predicates.\n\n**Ambition**: Solid extension with potential for paradigm shift in verified spectral theory.\n\n---\n\n## Direction 4: Computational Discovery of Transfer Principles\n\n**Conjecture**: There exist non-obvious combinatorial properties of finite matrix groups that are empirically stable across field sizes (suggesting transferability) but have not been identified by human mathematicians. A systematic computational search over definable predicates of bounded complexity can discover such properties.\n\n**The key insight is** that the restricted formula language provides a finite enumeration of predicates up to any given complexity bound, and each can be tested computationally for stability across finite fields \u2014 turning the discovery of transfer principles into a search problem.\n\n**Why now?** The formal framework provides the theoretical guarantee that stable predicates *do* transfer (by Theorem 4.1), and the computational pipeline (`demo.py`, `algorithms.py`) provides the experimental infrastructure.\n\n**Test**: Enumerate all RestrictedFormula predicates of complexity \u2264 5 over GL(2, \ud835\udd3d_q), evaluate each on primes q \u2208 {3, 5, ..., 97}, and identify those with stable satisfaction ratios. Report any that encode non-obvious structural properties.\n\n**Impact**: Would pioneer machine-assisted mathematical discovery in the intersection of model theory and combinatorics, potentially finding new invariants of matrix groups.\n\n**Catalog References**: `Pythagorean/PseudofiniteTransfer/Defs.lean`, `demo.py`, `algorithms.py`\n\n**Proof Strategy**: Exhaustive enumeration + statistical stability testing + human interpretation of discovered predicates.\n\n**Domain Bridges**: Computer science (automated discovery) \u2194 Model theory \u2194 Combinatorics\n\n**Lineage**: Uses the framework as discovery infrastructure rather than proof infrastructure.\n\n**Ambition**: Grand challenge \u2014 genuinely novel methodology.\n\n---\n\n## Direction 5: Higher-Rank and Non-Linear Algebraic Groups\n\n**Conjecture**: The restricted \u0141o\u015b transfer framework extends to GL(n, \ud835\udd3d_q) for arbitrary n, and to other algebraic groups (symplectic, orthogonal, exceptional), with the formula complexity growing polynomially in n and the Lie rank.\n\n**The key insight is** that the ultraproduct construction and Boolean closure lemmas are completely independent of the matrix size \u2014 only the atomic predicates need to be generalized from Fin 2 to Fin n, and the coset-control definitions extend verbatim.\n\n**Why now?** The current formalization is already parameterized by the index type \u03b9 and the structure family \u03b1 : \u03b9 \u2192 Type, making the extension to higher-rank groups a matter of instantiation rather than redesign.\n\n**Test**: Instantiate the framework for GL(3, \ud835\udd3d_q) and verify that the upper triangular family and the unipotent family exhibit bounded doubling. Computationally test for q \u2208 {3, 5, 7}.\n\n**Impact**: Would extend the verified transfer architecture to cover the full range of finite groups of Lie type, matching the scope of the Breuillard-Green-Tao and Pyber-Szab\u00f3 theorems.\n\n**Catalog References**: `Pythagorean/PseudofiniteTransfer/Defs.lean`, `Catalog/Algebra/MatrixGroupGeneration.lean`\n\n**Proof Strategy**: Parameterize matrix size, extend definable families to n\u00d7n matrices, reprove transfer theorems (which should go through without modification).\n\n**Domain Bridges**: Algebraic group theory \u2194 Model theory \u2194 Representation theory\n\n**Lineage**: Direct generalization of all current theorems.\n\n**Ambition**: Solid extension \u2014 important for completeness of the program.\n",
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
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "49f2e371",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T06:49:40.077414+00:00"
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
    "id": "fd_2069",
    "title": "The universal support-Tutte polynomial establishes that M-convex supports admit ",
    "description": "# Future Directions: Universal Support-Tutte Polynomial Theory\n\n## Synthesis\n\nThe universal support-Tutte polynomial establishes that M-convex supports admit a deletion\u2013contraction algebra as rich as\u2014and strictly richer than\u2014matroid Tutte theory. This opens five interconnected research frontiers: extending the universality to multi-parameter invariants (Direction 1), connecting to tropical geometry via Newton polytope invariants (Direction 2), building a Hopf algebra structure for supports (Direction 3), developing efficient algorithms for large-scale computation (Direction 4), and applying the invariant to statistical mechanics partition functions (Direction 5). Together these directions would establish M-convex support theory as a new organizing framework in algebraic combinatorics, connecting discrete convex analysis, tropical geometry, and combinatorial physics.\n\n---\n\n## Direction 1: Full Multi-Parameter Universality\n\n**Conjecture**: There exists a universal 4-parameter support-Tutte polynomial T(S; a, b, u, v) \u2208 \u2124[a,b,u,v] such that any function F on M-convex supports satisfying F(S) = a\u00b7F(del) for loops, F(S) = b\u00b7F(con) for coloops, and F(S) = u\u00b7F(del) + v\u00b7F(con) for ordinary coordinates factors uniquely through T via ring homomorphism.\n\n**Test**: Formalize the 4-parameter recursion in Lean 4 and prove the factorization theorem. Verify computationally that the 4-parameter polynomial specializes to both the 1-parameter version (at u=v=1) and to the classical matroid Tutte polynomial (for binary supports with appropriate parameter mapping).\n\n**Impact**: Would establish the definitive universal object for deletion\u2013contraction on supports, subsuming all known Tutte-type universality results. Creates a new \"coefficient ring\" controlling all support invariants.\n\n**Catalog References**: `Catalog/Pythagorean/SupportTutteUniversality.lean` (universality theorem), `Catalog/Pythagorean/SupportTuttePolynomial.lean` (polynomial construction), `Catalog/Pythagorean/SupportMinorTheory.lean` (minor infrastructure).\n\n**Proof Strategy**: Extend the `canonicalSupportEval` definition to take four parameters. The well-foundedness argument is identical (same measure). The universality proof generalizes directly by replacing the loop rule and splitting the ordinary rule. The key new ingredient is proving that coloop contraction (as opposed to Tutte contraction) also descends in the measure.\n\n**Domain Bridges**: Connects to matroid Tutte universality (Brylawski\u2013Oxley), Hopf algebra characters (Schmitt), and partition function parametrization (Fortuin\u2013Kasteleyn).\n\n**Lineage**: Direct extension of Theorem C in `SupportTutteUniversality.lean`.\n\n**Ambition**: Grand challenge \u2014 would create a new universal algebraic object in combinatorics.\n\n**The key insight is** that the 1-parameter universality already proven shows the recursion structure uniquely determines the invariant; extending to 4 parameters requires only defining coloop-specific behavior and verifying the same structural properties hold.\n\n**Why now?** The 1-parameter universality and measure-descent infrastructure are fully formalized, providing the exact template for the multi-parameter extension.\n\n---\n\n## Direction 2: Tropical Newton Polytope Invariants\n\n**Conjecture**: The support-Tutte polynomial T(S) is invariant under tropical equivalences that preserve the normal fan of the convex hull of S. Two M-convex supports with the same matroid of normal fan rays but different lattice point structures have support-Tutte polynomials that differ by a predictable transformation.\n\n**Test**: For M-convex supports arising as Newton polytopes of Lorentzian polynomials (Br\u00e4nd\u00e9n\u2013Huh), compute T(S) and verify that tropical modifications (adding/removing interior lattice points while preserving convexity) change T(S) in a controlled way. Specifically, test on Newton polytopes of elementary symmetric polynomials and Schur polynomials.\n\n**Impact**: Would create the first deletion\u2013contraction invariant native to tropical geometry, potentially giving new proofs of log-concavity results via the Tutte universality machinery.\n\n**Catalog References**: `Catalog/Pythagorean/SupportMinorTheory.lean` (exchange property = M-convexity), `Catalog/Pythagorean/SupportTutteUniversality.lean` (universality).\n\n**Proof Strategy**: Use the fact that M-convex sets are exactly the bases of valuated matroids. The tropical equivalence should correspond to a specific class of valuated matroid isomorphisms. The support-Tutte polynomial should factor through the valuated matroid invariant ring.\n\n**Domain Bridges**: Tropical geometry (Maclagan\u2013Sturmfels), Lorentzian polynomials (Br\u00e4nd\u00e9n\u2013Huh), valuated matroids (Dress\u2013Wenzel).\n\n**Lineage**: Builds on the binary bridge theorem (Theorem D) and the activity partition.\n\n**Ambition**: Paradigm-shifting \u2014 would connect two major 21st-century developments (tropical geometry and support invariant theory).\n\n**The key insight is** that M-convexity is the combinatorial shadow of the Lorentzian property, and the support-Tutte polynomial should detect the \"degree\" of Lorentzianity that tropical geometry currently handles only through ad hoc methods.\n\n**Why now?** The Br\u00e4nd\u00e9n\u2013Huh theory of Lorentzian polynomials has established M-convexity as central to algebraic combinatorics, and our formalized support-Tutte machinery provides the first universal invariant on the same domain.\n\n---\n\n## Direction 3: Combinatorial Hopf Algebra of M-Convex Supports\n\n**Conjecture**: The collection of isomorphism classes of M-convex supports, equipped with disjoint-coordinate direct sum as product and deletion-contraction as coproduct, forms a combinatorial Hopf algebra whose unique character to \u2124[X] is the support-Tutte polynomial.\n\n**Test**: Verify the bialgebra axioms (associativity, coassociativity, compatibility) for small M-convex supports. Compute the antipode on supports with \u2264 4 coordinates and verify it agrees with the inclusion-exclusion formula predicted by Hopf algebra theory.\n\n**Impact**: Would place M-convex supports alongside matroids (Schmitt), graphs (Connes\u2013Kreimer), and posets (Malvenuto\u2013Reutenauer) in the ecosystem of combinatorial Hopf algebras. The character theory would then give a conceptual proof of universality.\n\n**Catalog References**: `Catalog/Pythagorean/SupportTutteUniversality.lean` (universality = character property), `Catalog/Pythagorean/SupportTutteUniversal.lean` (direct sum construction).\n\n**Proof Strategy**: Define the Hopf algebra on the free abelian group on M-convex support isomorphism classes. The product is direct sum. The coproduct decomposes S into del(S,i) \u2297 con(S,i) summed over all coordinates, with appropriate coefficients. Verify coassociativity by showing that iterated deletion-contraction is order-independent (connected to the activity expansion).\n\n**Domain Bridges**: Combinatorial Hopf algebras (Aguiar\u2013Mahajan), renormalization (Connes\u2013Kreimer), species theory (Joyal).\n\n**Lineage**: The direct sum multiplicativity in `SupportTutteUniversal.lean` is the product axiom; universality is the character property.\n\n**Ambition**: Grand challenge \u2014 would revolutionize the algebraic foundations of support theory.\n\n**The key insight is** that the universality theorem is exactly the statement that the support-Tutte polynomial is a Hopf algebra character, making the Hopf algebra structure not an addition but a revelation of what universality already encodes.\n\n**Why now?** The multiplicativity and universality theorems are formalized, providing the two axioms needed for the character identification.\n\n---\n\n## Direction 4: Efficient Computation via Matrix Methods\n\n**Conjecture**: For M-convex supports S \u2286 \u2115^n with |S| = N and maximum coordinate value d, the support-Tutte polynomial can be computed in time O(N \u00b7 n \u00b7 d) using a transfer matrix method, avoiding the exponential recursion tree.\n\n**Test**: Implement the transfer matrix algorithm for simplex supports Simplex(n, d) and compare runtime against the recursive algorithm. The transfer matrix should encode the deletion-contraction recursion as matrix multiplication over the polynomial ring.\n\n**Impact**: Would make the support-Tutte polynomial practically computable for supports arising in algebraic geometry (Newton polytopes of multivariate polynomials with hundreds of terms).\n\n**Catalog References**: `Catalog/Pythagorean/SupportTutteUniversality.lean` (recursive algorithm correctness), `Catalog/Pythagorean/SupportMinorTheory.lean` (minor_step_card_le for complexity bounds).\n\n**Proof Strategy**: Order coordinates and process them sequentially. At each step, maintain a vector of \"partial evaluations\" indexed by possible states of the remaining coordinates. Deletion and contraction correspond to specific linear maps on this state space.\n\n**Domain Bridges**: Transfer matrix methods in statistical mechanics, dynamic programming in combinatorial optimization.\n\n**Lineage**: Extends the verified recursive algorithm to polynomial-time computation.\n\n**Ambition**: Solid extension \u2014 practical algorithmic improvement with clear formalization path.\n\n**The key insight is** that the deletion-contraction recursion has a natural dynamic programming structure when coordinates are processed in a fixed order, collapsing the exponential tree into a polynomial-time scan.\n\n**Why now?** The correctness of the recursive algorithm is formally verified, providing a trusted baseline against which to validate the efficient algorithm.\n\n---\n\n## Direction 5: Statistical Mechanics Partition Functions\n\n**Conjecture**: The support-Tutte polynomial T(S)(X) is a partition function Z(S, \u03b2) = T(S)(e^\u03b2) counting weighted deletion-contraction decomposition histories, where each loop step contributes weight e^\u03b2. At \u03b2 = 0 (X = 1), this recovers the unweighted count |S|. The free energy F = -log Z / \u03b2 exhibits a phase transition as \u03b2 \u2192 \u221e related to the loop depth of S.\n\n**Test**: For simplex supports Simplex(n, d) with varying n and d, plot the free energy as a function of \u03b2. Identify whether there is a critical \u03b2_c where the dominant contribution transitions from ordinary-coordinate-rich decompositions to loop-coordinate-rich ones.\n\n**Impact**: Would give the first rigorous connection between M-convex support structure and statistical mechanics, potentially yielding new techniques for analyzing discrete optimization landscapes via partition function methods.\n\n**Catalog References**: `Catalog/Pythagorean/SupportTutteUniversality.lean` (canonicalSupportEval as partition function), `Catalog/Pythagorean/SupportTuttePolynomial.lean` (polynomial construction).\n\n**Proof Strategy**: Express the recursion tree as a sum over leaf configurations weighted by X^(number of loop steps). Show this equals T(S)(X) by the universality theorem. Analyze the asymptotics of coefficients using generating function methods.\n\n**Domain Bridges**: Statistical mechanics (Baxter), Fortuin-Kasteleyn random cluster model, large deviations in combinatorial optimization.\n\n**Lineage**: The cardinality specialization T(1) = |S| is the \u03b2 = 0 case.\n\n**Ambition**: Solid extension \u2014 connects formalized results to physical models with testable predictions.\n\n**The key insight is** that the support-Tutte polynomial is already a partition function in disguise\u2014the coefficients count decomposition histories weighted by loop depth\u2014and making this explicit opens the door to thermodynamic analysis of support structure.\n\n**Why now?** The cardinality specialization theorem provides the calibration point, and the recursive algorithm provides exact computation for testing the phase transition conjecture.\n",
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
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "59efe301",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T07:28:52.720264+00:00"
  },
  {
    "id": "fd_2070",
    "title": "The theorems proved in this work \u2014 exact separation via height signatures, tropi",
    "description": "# Future Directions: Arithmetic Persistence Theory\n\n## Synthesis\n\nThe theorems proved in this work \u2014 exact separation via height signatures, tropical defect equivalence, and certified classification \u2014 establish a foundational layer for a new field we call *arithmetic persistence theory*. The core discovery is that persistence-style filtering of Frobenius slope data provably detects the supersingular/finite-height dichotomy. This opens five interconnected research directions, ranging from immediate extensions (height refinement, abelian varieties) to paradigm-shifting conjectures (motivic persistence, arithmetic phase transitions). Each direction builds on the certified separation theorems as its foundational ingredient, and each is falsifiable by explicit computation.\n\n---\n\n## Direction 1: Height Refinement \u2014 Distinguishing Finite Heights via Persistence Barcode Statistics\n\n**Conjecture:** For K3 surfaces with finite formal Brauer group height $h \\in \\{1, \\ldots, 10\\}$, the persistent rank curve $r_P(t)$ has exactly $h$ distinct jump locations, and the multiset of jump magnitudes determines $h$ uniquely. Specifically, the number of distinct non-zero slope deviations from the symmetry center equals $h$.\n\n**Test:** Construct synthetic slope profiles for each height $h = 1, \\ldots, 10$ using the symmetric-pair model (slopes $1 \\pm k/h$ for $k = 1, \\ldots, h$). Compute the persistent rank curves and verify that the number of jumps equals $h$. Then test on actual Frobenius slope data from Kedlaya's algorithm for diagonal quartic K3 surfaces at small primes.\n\n**Impact:** If successful, this upgrades the binary classifier to a complete height detector, recovering the full invariant $h \\in \\{1, \\ldots, 10, \\infty\\}$ from persistence data. This would be the first computable persistence-based algorithm for formal group heights.\n\n**Catalog References:** `Speculative/ArithmeticPersistence.lean` \u2014 `firstJump_characterization`, `persistentRank_monotone`.\n\n**Proof Strategy:** Define the \"jump multiset\" as the sorted sequence of deviations $\\{|s - c| : s \\in S, s \\neq c\\}$. Prove that distinct heights produce distinct jump multisets under the symmetric-pair normalization. The key lemma is that the jump at position $k/h$ has multiplicity exactly 2 (one from each symmetric partner).\n\n**Domain Bridges:** Connects to spectral theory (the jump multiset is a discrete spectrum), coding theory (the profile acts as a code with minimum distance equal to the minimal deviation), and representation theory (the symmetric pair structure reflects Weyl group symmetry of the root system).\n\n**Lineage:** Direct extension of Theorems 3.1\u20133.4 in the current work.\n\n**Ambition:** Extension \u2014 builds directly on proved theorems.\n\n---\n\n## Direction 2: Arithmetic Persistence for Abelian Varieties and Motives\n\n**Conjecture:** The persistence detection mechanism generalizes to abelian varieties of dimension $g$: for an abelian variety $A/\\mathbb{F}_p$ with Newton polygon slopes $\\lambda_1 \\leq \\cdots \\leq \\lambda_{2g}$, the height signature and tropical defect detect the ordinary/supersingular dichotomy, and the persistent rank curve refines the Newton polygon stratification.\n\n**Test:** For elliptic curves ($g = 1$), the ordinary/supersingular dichotomy is classical. Implement the persistence classifier on slope data $\\{0, 1\\}$ (ordinary) vs $\\{1/2, 1/2\\}$ (supersingular) and verify agreement with the Hasse invariant. For $g = 2$, test on Jacobians of genus-2 curves with known Newton polygons.\n\n**Impact:** A unified persistence framework for formal group invariants across all abelian varieties would connect topological data analysis to the Langlands program, where Newton polygon strata play a central role in the geometry of Shimura varieties.\n\n**Catalog References:** `Speculative/ArithmeticPersistence.lean` \u2014 `heightSignature_maximal_iff_supersingular`, `tropicalDefect_zero_iff_supersingular`.\n\n**Proof Strategy:** The key insight is that the abstract framework is already type-agnostic: `PrimeSlopeProfile` takes any finite set of rational slopes. For abelian varieties, the symmetry center changes (center = 1/2 for weight-1 cohomology), and the number of slopes is $2g$ instead of 22. Reprove the separation theorems with parameterized center and verify that the proofs are center-independent (they are, by construction).\n\n**Domain Bridges:** Langlands program (Newton polygon strata on Shimura varieties), p-adic Hodge theory (Fontaine's classification), algebraic K-theory (motivic filtrations).\n\n**Lineage:** Generalization of the K3-specific framework to arbitrary dimension.\n\n**Ambition:** Grand challenge \u2014 could open a new chapter in the Langlands program.\n\n---\n\n## Direction 3: Tropical Persistence and Min-Plus Homological Algebra\n\n**Conjecture:** The tropical defect function $\\tau_P(t) = \\max_{s \\in S} \\max(0, |s - c| - t)$ is the degree-0 term of a richer tropical chain complex whose homology groups detect finer invariants than the height alone. Specifically, define a filtered chain complex in the min-plus semiring with generators indexed by slopes and differentials determined by the deviation structure; the resulting \"tropical persistence module\" should have barcode decomposition whose long bars correspond to height strata.\n\n**Test:** Implement the tropical chain complex for height-2 and height-3 profiles. Compute the barcode and verify that long bars correspond to large slope deviations (i.e., high-height contributions). Compare with the classical persistence barcode on the Rips complex of the slope point cloud.\n\n**Impact:** This would establish a new branch of homological algebra: *min-plus persistence theory*. Unlike classical persistence over a field, min-plus persistence lacks unique decomposition, making the theory richer and more challenging. The arithmetic setting provides natural examples.\n\n**Catalog References:** `Speculative/ArithmeticPersistence.lean` \u2014 `tropicalDefect_zero_iff_supersingular`, `SlopePersistenceModel`.\n\n**Proof Strategy:** The key insight is that the tropical defect is the \"sup-norm\" of the deviation function on the slope set. A chain complex can be built by taking the nerve of the open cover $\\{B_t(c)\\}_{t \\geq 0}$ of the slope set (balls of radius $t$ around the center). The homology of this nerve captures the connectivity of the thresholded slope set. Prove that H_0 of this complex at parameter $t$ equals the number of connected components of $\\{s : |s - c| > t\\}$, which for discrete slope sets is simply the number of slopes outside the ball.\n\n**Domain Bridges:** Tropical geometry (min-plus linear algebra), idempotent analysis (Maslov dequantization), statistical mechanics (free energy as tropical limit of partition function).\n\n**Lineage:** Direct extension of the tropical defect theorem.\n\n**Ambition:** Grand challenge \u2014 would create a new algebraic theory.\n\n---\n\n## Direction 4: Arithmetic Phase Transitions and Statistical Physics\n\n**Conjecture:** The supersingular/finite-height transition has the structure of a phase transition in a discrete statistical mechanics model. Specifically, define an \"arithmetic energy\" $E(P) = \\sum_{s \\in S} |s - c|^2$ and a \"partition function\" $Z_P(\\beta) = \\sum_{s \\in S} e^{-\\beta |s - c|^2}$. The supersingular regime corresponds to the zero-temperature ground state ($E = 0$), and the tropical defect $\\tau_P(0)$ acts as an order parameter: it vanishes in the supersingular \"phase\" and is positive in the finite-height \"phase.\"\n\n**Test:** For each height $h = 1, \\ldots, 10$, compute $E(P)$, $Z_P(\\beta)$, and the \"specific heat\" $C(\\beta) = -\\beta^2 \\partial^2 \\log Z / \\partial \\beta^2$. Verify that $C(\\beta)$ shows a peak whose location scales with $1/h^2$, signaling a height-dependent crossover.\n\n**Impact:** If the analogy is precise, it imports the powerful machinery of renormalization group theory and universality classes into arithmetic geometry. The distribution of K3 heights across primes could exhibit universal scaling laws analogous to critical exponents.\n\n**Catalog References:** `Speculative/ArithmeticPersistence.lean` \u2014 `tropicalDefect_pos_of_finiteHeight`, `IsSupersingularProfile`.\n\n**Proof Strategy:** The key insight is that the tropical defect is the zero-temperature limit of a free energy: $\\tau_P(0) = \\lim_{\\beta \\to \\infty} \\beta^{-1} \\log Z_P(\\beta)$ when appropriately normalized. Prove this limit formula rigorously and show that the phase transition in the $(\\beta, h)$ plane has a well-defined critical curve.\n\n**Why now?** Recent developments in arithmetic statistics (Bhargava's program, Sato-Tate distributions) provide empirical data on how heights are distributed across primes. The statistical physics framework could unify these distributional results under a single thermodynamic picture.\n\n**Domain Bridges:** Statistical mechanics (phase transitions, universality), random matrix theory (eigenvalue statistics), arithmetic statistics (Sato-Tate, Lang-Trotter).\n\n**Lineage:** Reinterpretation of the tropical defect theorem through the lens of statistical physics.\n\n**Ambition:** Grand challenge \u2014 paradigm shift connecting arithmetic geometry to statistical physics.\n\n---\n\n## Direction 5: Computable Probes for Reduction Types via Machine Learning\n\n**Conjecture:** A neural network trained on persistence features (height signature curves, tropical defect curves, jump parameters) extracted from Frobenius slope data can predict formal Brauer group heights with accuracy exceeding 95% on held-out K3 families, even when trained only on synthetic slope profiles.\n\n**Test:** Generate 10,000 synthetic slope profiles spanning all heights $h = 1, \\ldots, 10, \\infty$. Extract persistence feature vectors (persistent rank at 50 evenly-spaced scales, tropical defect at 50 scales, first jump parameter, min deviation). Train a random forest and a small neural network on 80% of the data and evaluate on 20%. Then test on Frobenius data from actual K3 surfaces (computed via Kedlaya's algorithm for small primes).\n\n**Impact:** This would create a practical computational tool for arithmetic geometers: given point-counting data for a K3 surface at a prime, automatically classify the reduction type. The certified correctness theorems provide theoretical guarantees that underpin the ML classifier's reliability.\n\n**Catalog References:** `Speculative/ArithmeticPersistence.lean` \u2014 `classifyHeightRegime_correct_supersingular`, `classifyHeightRegime_correct_gap`.\n\n**Proof Strategy:** The key insight is that the certified classifier already achieves perfect accuracy on exact data; the ML layer is needed only to handle noise and to learn the optimal threshold $\\varepsilon$ adaptively. Prove a PAC-learning bound: given $n$ profiles with noise $\\delta < $ stability radius, the empirical risk minimizer converges to the Bayes-optimal classifier at rate $O(1/\\sqrt{n})$.\n\n**Why now?** The convergence of topological data analysis, machine learning, and computational number theory has created all the necessary infrastructure. Point-counting algorithms have matured to handle K3 surfaces at primes up to $\\sim 10^6$, providing enough data for meaningful training.\n\n**Domain Bridges:** Machine learning (feature engineering from topological summaries), computational number theory (point counting, Kedlaya's algorithm), cryptography (K3-based hash functions and post-quantum schemes).\n\n**Lineage:** Application of the certified classifier to practical computation.\n\n**Ambition:** Extension \u2014 directly applicable engineering of proved theorems.\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Physics",
      "Cryptography",
      "Bridges",
      "MachineLearning",
      "Logic",
      "Speculative"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "87141f1c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T07:29:18.891183+00:00"
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "b735b58c",
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
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "16b3acea",
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
    "id": "fd_2009",
    "title": "Primewise Persistent Homology Detects Modularity of Calabi\u2013Yau Threefolds",
    "description": "Conjecture: There exists an explicit functorial construction assigning to a rigid Calabi\u2013Yau threefold X/Q and each good prime p a finite filtered chain complex K_p(X), built from reduction data of X mod p, such that the resulting family of prime-indexed persistence summaries determines the weight-4 modular form associated to X up to finitely many possibilities; moreover, non-modular candidate threefolds (if any exist) fail this rigidity pattern on a positive-density set of primes. Test: Compute K_p(X) for known modular rigid Calabi\u2013Yau threefolds and check whether persistence invariants recover the Hecke eigenvalue sequence a_p strongly enough to distinguish the associated modular form from all others of bounded level; attempt the same on families with uncertain modular behavior and look for systematic failure. Impact: This would create a new topological-computational probe of arithmetic geometry, potentially giving an unexpected route to detecting automorphy from finite combinatorial data across primes.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T01:46:44.694033+00:00"
  },
  {
    "id": "fd_2011",
    "title": "Asymptotic Faithfulness Threshold for Neural Tangent Kernels on Arithmetic Point",
    "description": "Conjecture: There exists an explicit family of arithmetic point clouds P_p \\subset S^d, obtained functorially from reductions modulo p of a fixed algebraic variety over Q, such that their Vietoris\u2013Rips persistent homology stabilizes with p, but the spectrum of the infinite-width neural tangent kernel (for a fixed standard architecture on the ambient sphere) fails to stabilize on a positive-density set of primes. Equivalently, persistent homology and NTK geometry separate infinitely often on arithmetic data. Test: Construct candidate families P_p (e.g. from normalized point counts/Frobenius orbits), compute barcodes and NTK eigenvalue distributions across many primes, and check whether barcode distances tend to 0 while kernel spectral distances stay bounded away from 0 along a positive-density subsequence; refutation is empirical convergence of both. Impact: This would reveal a genuine topological/learning-theoretic mismatch in arithmetic data representations, giving a new route to lower bounds for kernel methods and a new interface between arithmetic statistics, TDA, and geometric deep learning.",
    "domains": [
      "Topological Data Analysis",
      "Arithmetic Geometry",
      "Machine Learning Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T01:48:04.717648+00:00"
  },
  {
    "id": "fd_2015",
    "title": "Primewise Persistent Homology Detects Failure of Local-Global Principles for Gen",
    "description": "Conjecture: There exists an explicit functorial construction sending a smooth genus-one curve C/Q to a family of finite filtered chain complexes K_p(C) for good primes p such that the collection of prime-indexed persistence signatures {PH(K_p(C))}_p determines whether C has points over every completion of Q but no rational point over Q (i.e. whether C is a Hasse principle counterexample), up to finitely many explicitly characterizable exceptional families. Test: Build K_p(C) from reduction data of C mod p together with Frobenius orbit statistics on torsors/Jacobian translates; compute signatures for known Hasse counterexamples and for matched locally-solvable curves with rational points. The conjecture is supported if a uniform classifier separates the two classes with provable asymptotic accuracy over large prime ranges, and refuted if infinite indistinguishable families exist across the two classes. Impact: This would create a topological-statistical probe of arithmetic obstruction phenomena, potentially exposing new computable shadows of the Tate-Shafarevich group and suggesting a new bridge between persistence, descent, and local-global arithmetic.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T01:48:38.052808+00:00"
  },
  {
    "id": "fd_2021",
    "title": "Chromatic Persistence Rigidity for Arithmetic Matroids",
    "description": "Conjecture: There exists an explicit functorial construction assigning to every representable arithmetic matroid M over Z and each prime p a finite filtered simplicial complex K_p(M) such that, for any two such matroids M and N of bounded rank, if the prime-indexed persistence diagrams of K_p(M) and K_p(N) agree for a set of primes of positive Dirichlet density, then M and N have the same arithmetic Tutte polynomial; moreover, there exist non-isomorphic underlying ordinary matroids with distinct arithmetic multiplicity data that are separated by this invariant. Test: Compute K_p(M) for explicit families coming from toric arrangements, integer vector configurations, and graph-incidence arithmetic matroids; verify whether persistence agreement across many primes correlates exactly with equality of arithmetic Tutte polynomials, and search for counterexamples with identical ordinary Tutte polynomial but different arithmetic data. Impact: This would create a new bridge between persistent homology, arithmetic matroid theory, and combinatorial invariants of toric arrangements, yielding a topological probe of arithmetic multiplicities invisible to classical matroid persistence constructions.",
    "domains": [
      "Arithmetic Matroids",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T01:49:05.211396+00:00"
  },
  {
    "id": "fd_2029",
    "title": "Persistence Detects Galois Groups of Number Fields via Prime Splitting Complexes",
    "description": "Conjecture: There exists an explicit functorial construction sending a number field K/Q with discriminant D_K to a family of finite filtered simplicial complexes X_p(K), one for each unramified prime p, built only from the splitting type of p in K and low-complexity residue-degree/incidence data, such that for every fixed degree n there is a constant B(n) with the following property: if K and L are degree-n number fields and the primewise persistence profiles of X_p(K) and X_p(L) agree for all unramified p <= B(n)\u00b7(log |D_K D_L|)^2, then Gal(K^gal/Q) and Gal(L^gal/Q) are isomorphic as permutation groups on embeddings; moreover, there exist non-isomorphic degree-n fields whose ordinary splitting statistics agree up to this range but whose persistence profiles differ. Test: Implement X_p(K) from databases of number fields, compute persistence profiles across primes, and check whether these profiles cluster exactly by Galois group/permutation type and separate examples with matching coarse splitting statistics; refutation occurs if large families with distinct Galois groups remain persistence-indistinguishable or if the profiles never outperform classical splitting-count features. Impact: This would create a new topological invariant of arithmetic fields, turning prime splitting data into a computable geometric signature for inverse Galois classification and potentially revealing hidden structure beyond Chebotarev density summaries.",
    "domains": [
      "Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T01:49:32.800268+00:00"
  },
  {
    "id": "fd_2035",
    "title": "Homological Echoes of the Riemann Zeta Zeros in Prime Window Complexes",
    "description": "Conjecture: There exists an explicit functor assigning to each large scale parameter X a filtered simplicial complex K_X built only from the pattern of primes in short intervals [x, x + H(X)] for x in [X,2X], with H(X)=X^theta for some fixed 0<theta<1, such that after deterministic normalization, the persistence landscape of K_X converges if and only if the pair-correlation statistics of nontrivial zeros of zeta match the GUE law predicted by Montgomery. Test: Define K_X concretely from prime-gap or residue-pattern data in sliding windows, compute persistence summaries for increasing X, and compare their limiting statistics against simulations under GUE and against modified Cram\u00e9r/random-prime models; failure to distinguish these models or convergence to the wrong law refutes the conjecture. Impact: This would create a new topological observable for the fine-scale distribution of primes, potentially turning deep spectral information about zeta zeros into experimentally accessible geometric signatures and opening a bridge between TDA, analytic number theory, and random matrix theory.",
    "domains": [
      "Analytic Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T01:50:00.555919+00:00"
  },
  {
    "id": "fd_2037",
    "title": "Persistent Homology Detects Secondary Terms in Chebotarev Prime Splitting",
    "description": "Conjecture: There exists an explicit functorial construction assigning to each finite Galois extension K/Q with Galois group G and each conjugacy class union C subseteq G a filtered simplicial complex X_C(T) built from primes p <= T with Frobenius class in C, such that after centering by the main Chebotarev density term |C|/|G|, the stable barcode statistics of the family {X_C(T)}_T determine whether the associated Artin L-functions have a real exceptional zero or nontrivial low-lying zero bias. In particular, two pairs (K,C) and (K',C') with identical natural density |C|/|G| = |C'|/|G'| but different secondary Chebotarev error terms yield asymptotically different barcode summaries. Test: Compute the complexes for explicit number fields with matched splitting densities but provably different low-lying Artin zero behavior; confirm that barcode observables separate the families with statistical significance and fail to separate control pairs with matching secondary terms. Refutation occurs if no functorial prime-splitting complex yields asymptotically distinct persistence signatures beyond density. Impact: This would create a topological probe of fine analytic number theory, giving a new observable for Artin L-function phenomena and a bridge between persistence, prime distributions, and Galois representations.",
    "domains": [
      "Analytic Number Theory",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T02:20:32.754351+00:00"
  },
  {
    "id": "fd_2048",
    "title": "Prime-Field Phase Retrieval from Persistent Homology of Polynomial Value Fibers",
    "description": "Conjecture: There exists an explicit functorial construction assigning to each squarefree polynomial f in Z[x] of degree at least 3 a family of finite filtered simplicial complexes K_p(f), built from the incidence geometry of fibers f^{-1}(a) over F_p as a varies, such that for generic f and g the equality of primewise persistence profiles PH(K_p(f)) = PH(K_p(g)) for a set of primes p of positive density implies that f and g are linearly conjugate over Qbar up to the involution f(x) -> -f(x)+c. Test: Implement K_p(f) for broad families (e.g. cubic/quartic polynomials), compute persistence across many good primes, and check whether non-conjugate polynomials ever produce matching profiles on a positive-density prime set; a single counterexample refutes the conjecture, while large-scale separation and proof in low-degree families supports it. Impact: This would create a new topological invariant of arithmetic dynamics and a surprising route to reconstructing algebraic maps from mod-p topology, linking arithmetic statistics, inverse Galois-type reconstruction, and TDA.",
    "domains": [
      "Arithmetic Geometry",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T04:52:34.429373+00:00"
  },
  {
    "id": "fd_2050",
    "title": "Persistence Detects Natural Boundaries of Integer Generating Functions",
    "description": "Conjecture: There exists an explicit functorial construction sending any integer sequence a(n) with rational ordinary generating function modulo every prime p to a family of filtered simplicial complexes K_p(N) built from length-N windows of the reduced sequence a(n) mod p, such that the following dichotomy holds. If the complex generating function A(z)=\\sum_{n\\ge0} a(n)z^n is D-finite and has no natural boundary, then for every fixed homological degree the barcode statistics of K_p(N), averaged over p<=P and normalized as N,P->infinity, stabilize to a finite-type limit determined by finitely many local recurrence parameters. If A(z) has a natural boundary on its circle of convergence, then there exists some homological degree and a diverging scale sequence N(P) for which the normalized barcode statistics fail to stabilize and instead exhibit unbounded prime-to-prime fluctuation. Test: Compute the construction for benchmark classes with known analytic behavior\u2014rational/algebraic/D-finite sequences versus lacunary, automatic-but-non-D-finite, and partition-like sequences with expected natural boundaries modulo primes\u2014and check whether stabilization versus persistent fluctuation cleanly separates the classes. A single counterexample in either direction refutes the conjecture. Impact: This would create a new topological diagnostic for analytic continuation phenomena of generating functions, linking arithmetic reductions, automata/recurrence structure, and complex-analytic singularity geometry through computable invariants.",
    "domains": [
      "Analytic Combinatorics",
      "Topological Data Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T04:53:05.338122+00:00"
  },
  {
    "id": "fd_2052",
    "title": "Persistent Homology of Langlands Local-Global Correspondence: Barcodes from L-Pa",
    "description": "Conjecture: For a reductive group G over Q, the family of local L-packets {\u03a0_p : p prime} ordered by prime magnitude forms a filtered object whose persistent homology barcode B(G) satisfies: (1) each 'global bar' (a bar surviving past all finite filtration parameters) corresponds bijectively to an automorphic representation in the discrete spectrum of G(A); (2) the birth time of each global bar encodes the arithmetic conductor of the corresponding L-function; (3) finite bars correspond to non-self-dual local packets that cannot globalize. Test: For G=GL(2), compute the barcode from the explicitly known local L-packets at primes p\u2264N for quadratic fields, verify that global bars match weight-2 newforms and that bar birth parameters recover conductor data. Refute: Find G where B(G) has global bars with no corresponding automorphic representation, or vice versa.",
    "domains": [
      "Langlands Program",
      "Persistent Homology",
      "Automorphic Forms",
      "Representation Theory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T04:54:47.033498+00:00"
  },
  {
    "id": "fd_2056",
    "title": "Tropical-Quantum Correspondence for Stabilizer Codes",
    "description": "Conjecture: For every CSS quantum stabilizer code C with parameters [[n,k,d]], there exists a tropical linear space T(C) in TP^{n-1} such that: (1) the tropical dimension of T(C) equals k, (2) the minimum tropical distance between distinct points of T(C) \u2229 {0,1}^n equals d, and (3) C is locally testable if and only if T(C) has bounded tropical Pl\u00fccker coordinates (i.e., T(C) is realizable over a tropical semifield with bounded entries). Conversely, every tropical linear space with bounded Pl\u00fccker coordinates arises from a locally testable CSS code. Test: Exhaustively verify the correspondence for all inequivalent CSS codes with n \u2264 20 by computing tropical Pl\u00fccker vectors and checking the distance/boundedness conditions. Refutation: Finding a code with d \u2260 min-tropical-distance(T(C)) or a bounded tropical space with no corresponding LTCC. Impact: Provides a complete combinatorial classification of quantum LDPC codes via tropical geometry, transforming quantum code construction into tropical linear algebra and enabling systematic discovery of good quantum codes.",
    "domains": [
      "Tropical Geometry",
      "Quantum Information Theory",
      "Matroid Theory",
      "Algebraic Combinatorics"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "pi_brainstorm",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T04:57:40.298614+00:00"
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
    "id": "fd_2071",
    "title": "The theorems proved in this work establish a foundational bridge: persistent 1-d",
    "description": "# Future Directions: Persistent Homology and Renormalizability\n\n## Synthesis\n\nThe theorems proved in this work establish a foundational bridge: persistent 1-dimensional topology of loop-filtered divergence complexes detects finite renormalizability type. This opens a systematic program connecting three previously separate domains\u2014Hopf-algebraic renormalization, topological data analysis, and combinatorial graph theory\u2014through the common language of filtered complexes and persistence invariants.\n\nThe directions below range from immediate extensions (formalizing the full Connes\u2013Kreimer bar complex) to paradigm-shifting conjectures (tropical renormalization flows, categorical barcode semantics). Each builds directly on the detection theorem and Euler defect formula, and each produces a testable prediction that could be verified or refuted computationally.\n\n---\n\n## Direction 1: Full Bar Complex Persistent Homology\n\n**Conjecture:** The persistent H\u2081 of the complete bar complex B(H_CK) of the Connes\u2013Kreimer Hopf algebra, filtered by loop order, has rank equal to the number of primitive superficially divergent residue types. Moreover, all higher persistent homology groups H_k for k \u2265 2 carry information about the overlapping divergence structure.\n\n**Test:** Formalize the Connes\u2013Kreimer Hopf algebra H on rooted forests in Lean 4, construct the bar complex B(H) with its standard differential, and compute persistent H\u2081 for \u03c6\u2074\u2084D up to loop order 4. The prediction: persistent rank H\u2081 = 2, and persistent H\u2082 detects overlapping divergences (should be nonzero when overlapping graphs exist).\n\n**Impact:** This would be the first complete formalization of the Connes\u2013Kreimer Hopf algebra with verified persistent homology computation. It would establish the full conjecture beyond the finite combinatorial model and potentially reveal new invariants of renormalization from higher persistent homology.\n\n**Catalog References:** The detection theorem in `Catalog/Speculative/PersistentRenormalization/Main.lean` provides the finite model; extending to the full Hopf algebra requires Mathlib's `Hopf` algebra infrastructure and chain complex machinery.\n\n**Proof Strategy:** \n1. Define the Connes\u2013Kreimer Hopf algebra on decorated rooted trees using Lean's inductive types\n2. Construct the bar complex as a filtered chain complex using Mathlib.Algebra.Homology\n3. Prove that primitive elements correspond to H\u2081 generators\n4. Apply the detection theorem to the truncated complex at each loop level\n\n**Domain Bridges:** Hopf algebras \u2194 homological algebra \u2194 topological data analysis\n\n**Lineage:** Direct extension of the detection theorem (Theorem 3.1)\n\n**Ambition:** grand_challenge \u2014 would establish the full conjecture and open the door to computational persistent homology for QFT\n\n---\n\n## Direction 2: Tropical Geometry of Divergence Complexes\n\n**Conjecture:** The loop-filtered divergence complex admits a natural tropicalization where graph polynomials (Kirchhoff/Symanzik polynomials) define a tropical variety whose Betti numbers recover the persistent bar count. The tropical Newton polytope of the graph polynomial encodes the filtration.\n\n**The key insight is** that Feynman amplitudes are periods of mixed Hodge structures, and their tropical limits retain the combinatorial divergence information while simplifying the algebraic geometry to polyhedral combinatorics.\n\n**Why now?** Recent advances in tropical Hodge theory (Adiprasito\u2013Huh\u2013Katz) and Feynman integral tropical methods (Panzer, Brown) provide the mathematical infrastructure to connect persistence invariants to tropical Betti numbers.\n\n**Test:** For \u03c6\u2074\u2084D at 2-loop order, compute the Symanzik polynomial of each primitive graph, take the tropical limit, build the tropical divergence complex, and compare its Betti numbers to the persistent bar count. The prediction: tropical \u03b2\u2081 = 2.\n\n**Impact:** Would connect renormalization theory to the Adiprasito\u2013Huh\u2013Katz resolution of the Rota\u2013Welsh conjecture and potentially yield log-concavity results for divergence class counts.\n\n**Catalog References:** `Catalog/Speculative/PersistentRenormalization/Main.lean` (Euler defect formula), `Catalog/Tropical/` (if tropical geometry infrastructure exists)\n\n**Proof Strategy:**\n1. Define tropicalization of graph polynomials as support functions on Newton polytopes\n2. Build the tropical divergence complex as a polyhedral complex\n3. Prove that the tropical Betti numbers specialize to the combinatorial persistent count\n4. Use matroid theory to relate the tropical structure to graph connectivity\n\n**Domain Bridges:** Tropical geometry \u2194 quantum field theory \u2194 matroid theory \u2194 persistent homology\n\n**Lineage:** Extension of Euler defect theorem (Theorem 3.4) via tropical interpretation\n\n**Ambition:** grand_challenge \u2014 would create \"tropical quantum field theory\" as a new subdiscipline\n\n---\n\n## Direction 3: Persistence Stability and Universality Classes\n\n**Conjecture:** The persistent barcode of the divergence complex satisfies a Lipschitz stability bound: if two theories T, T' have divergence profiles within Hausdorff distance \u03b5 in a suitable metric, then their persistence diagrams satisfy d_bottle(B(T), B(T')) \u2264 C\u03b5 for a universal constant C depending only on the spacetime dimension.\n\n**The key insight is** that persistence stability theorems (Cohen-Steiner, Edelsbrunner, Harer 2007) apply to filtered simplicial complexes, and the divergence complex is exactly such an object.\n\n**Why now?** The detection theorem provides the finite model needed to apply existing TDA stability machinery. The recently formalized stability theorem for persistence diagrams makes this accessible.\n\n**Test:** Construct two theories differing by a small perturbation of the coupling (e.g., \u03c6\u2074\u2084D with slightly different counterterm structure) and verify that their barcodes are close in bottleneck distance. Prediction: d_bottle = 0 for theories in the same universality class.\n\n**Impact:** Would prove that renormalizability is robust under continuous deformations of the theory\u2014a fundamental physics principle that has never been proved topologically.\n\n**Catalog References:** `Catalog/Speculative/PersistentRenormalization/Main.lean` (all theorems), Mathlib's metric space and Lipschitz infrastructure\n\n**Proof Strategy:**\n1. Define a metric on divergence profiles (Hausdorff distance on primitive divergent type sets)\n2. Construct an interleaving between the filtered complexes of nearby profiles\n3. Apply the algebraic stability theorem for persistence modules\n4. Specialize to get bottleneck distance bounds\n\n**Domain Bridges:** Topological data analysis \u2194 renormalization group \u2194 universality theory \u2194 metric geometry\n\n**Lineage:** Builds on renormalizability criterion (Theorem 3.2) and Euler defect (Theorem 3.4)\n\n**Ambition:** solid_extension \u2014 uses established TDA machinery in a new context\n\n---\n\n## Direction 4: Spectral Graph Theory of Divergence Complexes\n\n**Conjecture:** The graph Laplacian spectrum of the divergence complex encodes finer renormalization invariants than the persistent bar count alone. Specifically, the spectral gap of the loop-filtered complex detects the rate of convergence of the renormalization group flow, and the algebraic connectivity (second eigenvalue) measures the \"resistance to factorization\" of the counterterm structure.\n\n**The key insight is** that the persistent bar count equals the nullity of the graph Laplacian restricted to essential edges (by the matrix-tree theorem), and the remaining eigenvalues carry additional dynamical information.\n\n**Why now?** Spectral methods for filtered simplicial complexes have been developed (Horak\u2013Jost, 2013) and connect naturally to discrete Hodge theory, which can be formalized using Mathlib's linear algebra.\n\n**Test:** Compute the Laplacian spectrum of the \u03c6\u2074\u2084D divergence complex at loop orders 1\u20135. Prediction: the spectral gap stabilizes (consistent with asymptotic freedom), and the second eigenvalue is bounded away from zero (reflecting the irreducibility of the two-counterterm structure).\n\n**Impact:** Would provide quantitative invariants beyond the binary renormalizable/non-renormalizable classification, potentially distinguishing between theories with different renormalization group behaviors.\n\n**Catalog References:** `Catalog/Speculative/PersistentRenormalization/Main.lean` (complex definitions), Mathlib's `Matrix` and `Spectrum` infrastructure\n\n**Proof Strategy:**\n1. Construct the graph Laplacian of the divergence complex as a Fintype-indexed matrix\n2. Prove that nullity(L) = number of connected components (standard)\n3. Show that the cycle rank equals dim(ker(L\u2081)) for the edge Laplacian\n4. Relate spectral gap to filtration structure\n\n**Domain Bridges:** Spectral graph theory \u2194 quantum field theory \u2194 discrete Hodge theory \u2194 dynamical systems\n\n**Lineage:** Extends Euler defect theorem (Theorem 3.4) from counting to spectral analysis\n\n**Ambition:** solid_extension \u2014 well-grounded in existing spectral graph theory\n\n---\n\n## Direction 5: Categorical Barcode Semantics for QFT\n\n**Conjecture:** There exists a functor from the category of perturbatively renormalizable QFTs (with morphisms given by renormalization group flow) to the category of persistence modules (with morphisms given by interleaving maps), such that renormalizability is equivalent to the image being a finitely generated persistence module.\n\n**The key insight is** that the detection theorem is natural: it commutes with the inclusion functors between truncation levels, suggesting a categorical lift of the bijection between essential cycles and primitive divergent types.\n\n**Why now?** The recent development of persistence module categories (Bubenik, de Silva, Scott 2015) and their formalization in type theory provides the categorical language needed.\n\n**Test:** Construct the functor explicitly for the scalar theory family \u03c6\u1d56_d parameterized by (p, d), and verify that it maps the renormalization group flow (Wilson's approach) to interleaving maps between persistence modules. Prediction: the functor preserves the bounded/unbounded dichotomy.\n\n**Impact:** Would establish \"barcode semantics\" as a new mathematical framework for quantum field theory, potentially unifying perturbative and non-perturbative approaches through the lens of persistent homology.\n\n**Catalog References:** `Catalog/Speculative/PersistentRenormalization/Main.lean` (full theorem suite), Mathlib's category theory infrastructure\n\n**Proof Strategy:**\n1. Define the category of divergence profile systems with compatible morphisms\n2. Define the target category of graded persistence modules\n3. Construct the functor mapping theory systems to their persistent homology\n4. Prove naturality using the detection theorem at each truncation level\n5. Show that finite generation corresponds to bounded bar count\n\n**Domain Bridges:** Category theory \u2194 topological data analysis \u2194 quantum field theory \u2194 algebraic K-theory\n\n**Lineage:** Categorical lift of all main theorems\n\n**Ambition:** grand_challenge \u2014 would create a new mathematical framework for QFT\n",
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
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "5a48098c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T07:29:50.762039+00:00"
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
