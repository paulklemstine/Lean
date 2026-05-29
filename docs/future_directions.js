

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
    "id": "fd_1944",
    "title": "Direction 2: Weighted-to-Unweighted Descent for Lorentzian Supports",
    "description": "**Conjecture:** For a homogeneous Lorentzian polynomial $f$ with nonneg coefficients, the weighted shadow sequence $W_k(f) = \\sum_{|\\gamma|=k} |\\operatorname{supp}(\\partial^\\gamma f)|$ is log-concave, and under a support-uniformity condition, this implies log-concavity of the unweighted shadow cardinality sequence.\n\n**The key insight is:** The Lorentzian condition controls coefficient sums (not individual coefficients), and the coefficient transport formula `coeff_iteratedPDeriv` converts weighted shadow counts into coefficient sums weighted by descending factorials. These factorial weights are always positive on the support, so weighted log-concavity can descend to unweighted log-concavity when the weights are sufficiently uniform.\n\n**Why now?** The `coeff_iteratedPDeriv` and `descFactorial_prod_pos` lemmas in the catalog provide the exact transport formulas needed. The `pderiv_coeff_support` and `iterate_pderiv_coeff_support` theorems in this cycle establish the qualitative bridge. The quantitative step (from weighted to unweighted) is now the bottleneck.\n\n**Test:** For matroid basis polynomials of small matroids (Fano, Petersen, uniform), compute both $W_k$ and $|\\operatorname{Sh}_k|$, and measure the ratio $W_k / |\\operatorname{Sh}_k|$. If this ratio is approximately constant or log-concave in $k$, the descent theorem holds.\n\n**Impact:** Would provide the first general Lorentzian shadow theorem, unifying the coefficient-level and support-level perspectives.\n\n**Catalog References:**\n- `Pythagorean/IteratedShadowGeometry.lean`: `coeff_iteratedPDeriv`, `descFactorial_prod_pos`, `mem_kthShadow_iff_exists_iteratedDerivative`\n- `Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`: `coeff_pderiv_pderiv`\n\n**Proof Strategy:** Define $W_k = \\sum_\\beta w_k(\\beta)$ where $w_k(\\beta) = \\sum_{\\alpha \\in S, \\beta \\le \\alpha} \\prod_i \\binom{\\alpha_i}{\\beta_i}$. Use the Lorentzian condition (which controls Hessian eigenvalues of quadratic slices) to bound $W_k^2 - W_{k-1}W_{k+1}$. Then bound $|\\operatorname{Sh}_k| \\le W_k / \\min_\\beta w_k(\\beta)$ and $|\\operatorname{Sh}_k| \\ge W_k / \\max_\\beta w_k(\\beta)$ to transfer.\n\n**Domain Bridges:** Lorentzian polynomial theory, Alexandrov\u2013Fenchel inequalities, mixed discriminant theory.\n\n**Lineage:** Builds directly on `pderiv_coeff_support` and `iterate_pderiv_coeff_support` from this cycle.\n\n**Ambition:** Solid extension. This is the most natural next step from the current results.\n\n---",
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
    "source_exp_id": "f7968947",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-28T21:46:03.276610+00:00"
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
    "id": "fd_2038",
    "title": "The results established in this work \u2014 soundness, normalization, and confluence ",
    "description": "# Future Directions: Quantum Circuit Rewriting via Tensor Distributivity\n\n## Synthesis\n\nThe results established in this work \u2014 soundness, normalization, and confluence of distributive rewriting for quantum tensor expressions \u2014 open a *modular* pathway toward certified quantum circuit optimization. The key architectural insight is that distributivity provides a universal scaffold (valid in any ring) upon which domain-specific algebraic identities can be layered. This synthesis connects three intellectual traditions: *term rewriting theory* (confluence, termination, normal forms), *quantum information science* (circuit equivalence, gate synthesis, resource estimation), and *categorical algebra* (monoidal categories, coherence theorems, string diagrams). Each future direction below extends one or more of these connections.\n\n---\n\n## Direction 1: Gate Identity Integration and Completeness for Clifford Circuits\n\n**Conjecture**: The distributive rewrite system, augmented with the identities H\u00b2 = I, S\u00b2 = Z, CNOT\u00b2 = I, and the Clifford commutation relations, yields a complete rewrite system for Clifford circuits: two Clifford circuits are semantically equivalent if and only if their augmented normal forms agree modulo AC.\n\n**Test**: Enumerate all Clifford circuits on 2 qubits up to depth 10 (the Clifford group on 2 qubits has 11,520 elements). For each pair of semantically equivalent circuits, check whether the augmented normalization produces identical canonical multisets. Any failure is a counterexample; exhaustive success establishes completeness.\n\n**Impact**: A complete rewrite system for Clifford circuits would be the first canonicalization method derived purely from distributivity + gate identities, without ad hoc circuit transformations. This would provide a verified alternative to the stabilizer tableau method.\n\n**Catalog References**: `Catalog/Pythagorean/TensorSortedRewrite.lean` \u2014 the sorted rewrite invariants provide the infrastructure for incorporating ordering-based normal forms into the augmented system.\n\n**Proof Strategy**: Extend `QRewriteStep` with gate identity rules (e.g., `seq(gate(H), gate(H)) \u2192 gate(I)`). Prove soundness by matrix computation. For completeness, show that every Clifford group element has a unique normal form under the augmented system, using the known structure of the 2-qubit Clifford group as a finite group.\n\n**Domain Bridges**: Rewriting theory \u2194 finite group theory (Clifford group structure) \u2194 quantum error correction (stabilizer formalism).\n\n**Lineage**: Directly extends Theorems 1\u20134 (soundness and normalization) of the current work.\n\n**Ambition**: \u2605\u2605\u2605\u2605 \u2014 Achievable within 1\u20132 research cycles, with high impact if successful.\n\n---\n\n## Direction 2: Tropical Distributivity and Tensor Network Contraction\n\n**Conjecture**: The distributive rewrite framework, instantiated over the tropical semiring (\u211d \u222a {\u221e}, min, +), yields canonical contraction orderings for tensor networks. Specifically, the tropical canonical multiset of a tensor network expression encodes the optimal contraction tree.\n\n**The key insight is** that tensor network contraction is governed by the same distributive laws that drive quantum circuit normalization, but over a different algebraic structure. The tropical semiring replaces multiplication with addition and addition with min, transforming the distributive expansion into a dynamic programming computation.\n\n**Why now?** The connection between tropical algebra and tensor networks has been observed informally, but no formal framework links distributive rewriting to contraction ordering. The infrastructure built in this work (parameterized semantics over arbitrary rings/semirings) is exactly what is needed.\n\n**Test**: Implement tropical normalization for tensor network expressions representing random MPS (matrix product states) of bond dimension \u2264 8. Compare the contraction cost predicted by the tropical canonical multiset with the optimal cost found by brute-force search. Agreement validates the conjecture.\n\n**Impact**: If confirmed, this would provide a *certified* tensor network contraction algorithm \u2014 the first with formal correctness guarantees. This has applications in quantum simulation, machine learning (tensor decomposition), and statistical physics (partition function computation).\n\n**Catalog References**: `Catalog/Pythagorean/TropicalTensorDistributivity.lean` \u2014 existing tropical distributivity results can serve as the algebraic foundation.\n\n**Proof Strategy**: Generalize `QuantumSemantics` from rings to semirings. Show that the tropical semiring satisfies the bilinearity axioms for `parOp`. Transfer the soundness and confluence theorems to the tropical setting.\n\n**Domain Bridges**: Tropical geometry \u2194 tensor networks \u2194 optimization (dynamic programming) \u2194 many-body physics.\n\n**Lineage**: Extends the parameterized semantics (the `QuantumSemantics` structure) to non-ring settings.\n\n**Ambition**: \u2605\u2605\u2605\u2605\u2605 \u2014 Grand challenge. Success would unify circuit optimization and tensor network contraction under a single algebraic framework.\n\n---\n\n## Direction 3: Categorical Coherence and Distributive Monoidal Functors\n\n**Conjecture**: The distributive normalization functor \u2014 mapping quantum tensor expressions to their canonical multisets \u2014 is the unique monoidal natural transformation from the free distributive monoidal category to the multiset monoidal category, up to natural isomorphism. This makes the canonical multiset a *universal* invariant: any other confluent normalization method factors through it.\n\n**The key insight is** that the canonical multiset construction is not just an algorithm but a *categorical invariant*. Its uniqueness (up to AC) follows from the coherence theorem for distributive categories, which states that all diagrams built from distributivity isomorphisms commute.\n\n**Why now?** Coherence theorems for monoidal and distributive categories exist in the literature (Laplaza 1972, Kelly 1974), but their computational content \u2014 the connection to normal forms and rewriting \u2014 has not been formalized. Our framework provides the concrete playground.\n\n**Test**: Formalize the free distributive monoidal category on a set of generators in Lean 4. Verify that the canonical multiset function is a monoidal functor. Check uniqueness by constructing a second normalization method and proving it agrees with the canonical multiset.\n\n**Impact**: This would establish the theoretical completeness of the distributive approach: the canonical multiset captures *all* information that distributivity can distinguish. Any invariant preserved by distributive rewriting is a function of the canonical multiset.\n\n**Catalog References**: `Catalog/Pythagorean/TensorSortedRewrite.lean` \u2014 the abstract rewrite architecture provides the scaffolding for the categorical formulation.\n\n**Proof Strategy**: Define the free distributive monoidal category as a quotient of the expression type by the rewrite relation. Show that the canonical multiset descends to a well-defined functor on this quotient (using `canonicalMultiset_rewrite_invariant`). Prove universality by the universal property of free categories.\n\n**Domain Bridges**: Category theory (coherence) \u2194 rewriting theory (confluence) \u2194 quantum computing (circuit equivalence).\n\n**Lineage**: Directly uses Theorems 6\u20137 (canonical multiset invariance) as the core building block.\n\n**Ambition**: \u2605\u2605\u2605\u2605 \u2014 Theoretically deep but technically feasible with existing categorical Mathlib infrastructure.\n\n---\n\n## Direction 4: Entanglement Rank Preservation Under Distributive Normalization\n\n**Conjecture**: For product-state inputs, the separability of the output state is preserved by distributive normalization. More precisely, if `e` is a quantum tensor expression and `\u03c8` is a product state (\u03c8 = \u03c6\u2081 \u2297 \u03c6\u2082), then the Schmidt rank of `denote(e) \u00b7 \u03c8` equals the maximum Schmidt rank over the summands of `normalize(e)` applied to `\u03c8`.\n\n**The key insight is** that distributive normalization decomposes a circuit into atomic paths, each of which may independently create or destroy entanglement. The total entanglement of the output is determined by the interference pattern among these paths.\n\n**Why now?** Schmidt rank and entanglement entropy are central measures in quantum information theory, but their behavior under circuit transformations is poorly understood algebraically. The distributive decomposition provides a natural tool for analysis.\n\n**Test**: For random 2-qubit circuits of depth \u2264 5 applied to |00\u27e9, compute the Schmidt rank of the output state and compare with the maximum Schmidt rank over individual summands. The conjecture predicts these are related (not necessarily equal due to interference, but bounded).\n\n**Impact**: If the conjecture holds (or a corrected version of it), it would provide the first structural connection between *syntactic* circuit rewriting and *semantic* entanglement theory. This bridges rewriting theory and quantum physics at the deepest level.\n\n**Catalog References**: Uses the `denoteMultiset_canonicalMultiset` theorem as the semantic bridge.\n\n**Proof Strategy**: Define Schmidt rank for 2-qubit states via singular value decomposition. Show that for product-state inputs, the output state is a sum of states from individual paths. Bound the Schmidt rank of the sum using subadditivity of rank.\n\n**Domain Bridges**: Quantum information theory (entanglement) \u2194 linear algebra (SVD, rank) \u2194 rewriting theory (canonical decomposition).\n\n**Lineage**: Extends Theorem 9 (canonical multiset soundness) to state-level semantics.\n\n**Ambition**: \u2605\u2605\u2605\u2605\u2605 \u2014 Grand challenge. This is the deepest possible connection between rewriting and physics.\n\n---\n\n## Direction 5: Efficient Equivalence Checking via BDD-Encoded Canonical Multisets\n\n**Conjecture**: The canonical multiset of a quantum tensor expression can be represented as a binary decision diagram (BDD) whose size is polynomial in the circuit size for bounded-width circuits (circuits where the number of superposition nodes on any root-to-leaf path is bounded).\n\n**The key insight is** that canonical multisets grow exponentially in the worst case, but many practical circuits have bounded superposition width. BDD representations can exploit sharing among structurally similar summands to achieve compact canonical forms.\n\n**Why now?** BDD-based quantum circuit verification has been explored (Viamontes et al. 2007) but not in the context of distributive normal forms. The canonical multiset structure is particularly well-suited for BDD encoding because it is a *multiset of trees* \u2014 a naturally factored representation.\n\n**Test**: Implement BDD-encoded canonical multisets for circuits over {H, T, CNOT} with depth \u2264 10 and superposition width \u2264 4. Measure BDD size as a function of circuit depth and width. Verify equivalence checking time against naive multiset comparison.\n\n**Impact**: Polynomial-time equivalence checking for bounded-width quantum circuits would be practically useful for real circuit optimizers. Current methods are either exponential (full simulation) or incomplete (heuristic optimization).\n\n**Catalog References**: The `canonicalMultiset_card` theorem provides the theoretical bound on multiset size; the `summandCount_rewrite_invariant` ensures this bound is preserved by rewrites.\n\n**Proof Strategy**: Define a BDD representation for multisets of expression trees. Show that the `distribute_seq` and `distribute_par` operations can be implemented as BDD operations in polynomial time (for bounded width). Prove correctness by showing the BDD represents the same multiset.\n\n**Domain Bridges**: Data structures (BDDs) \u2194 complexity theory (bounded-width circuits) \u2194 formal verification (certified algorithms).\n\n**Lineage**: Extends the computational aspects of the normalization algorithm (Theorems 3\u20134).\n\n**Ambition**: \u2605\u2605\u2605 \u2014 Solid extension with clear practical impact. Achievable within one research cycle.\n",
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
    "source_exp_id": "e1c0f9c4",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T03:00:28.995423+00:00"
  },
  {
    "id": "fd_2039",
    "title": "The higher-order anti-cancellation theorem establishes that positive derivative ",
    "description": "# Future Directions: Higher-Order Anti-Cancellation and k-Shadows\n\n## Synthesis\n\nThe higher-order anti-cancellation theorem establishes that positive derivative aggregates act on polynomial supports by exact combinatorial erosion. This opens a structural interface between four mathematical domains: (1) combinatorial Hodge theory, where Lorentzian positivity originates; (2) arithmetic circuit complexity, where support size yields lower bounds; (3) tropical geometry, where cancellation is absent by design; and (4) matroid theory, where support geometry encodes combinatorial structure. The five directions below exploit different facets of this interface. The first two are grand challenges that would reshape their respective fields; the remaining three build directly on the proven theorems to extend the support calculus.\n\n---\n\n## Direction 1: Tropical Anti-Cancellation and Deterministic Support Transport\n\n**Conjecture:** The derivative shadow calculus admits a faithful embedding into the tropical semiring $(\\mathbb{R} \\cup \\{\\infty\\}, \\min, +)$, under which the anti-cancellation theorem becomes a statement about deterministic transport of tropical support \u2014 that is, the absence of tropical cancellation in positive-weight derivative sums corresponds exactly to the classical absence of cancellation.\n\n**Test:** For uniform matroid basis polynomials $U(r,n)$ with $n \\leq 8$ and derivative order $k \\leq 5$, tropicalize the derivative aggregate (replace coefficients by their valuations, addition by min, multiplication by addition) and verify that the tropical support equals the classical support predicted by the k-shadow. Measure the gap (if any) between tropical and classical shadow sizes.\n\n**The key insight is** that the anti-cancellation theorem already says classical derivatives behave tropically in the positive regime \u2014 the support is determined by combinatorial erosion without regard to coefficient magnitudes. Formalizing this as a tropical correspondence would unify two seemingly separate worlds.\n\n**Why now?** The k-shadow semigroup law (derivMultiShadow_add) provides exactly the algebraic structure needed to define a tropical shadow action. Previous approaches to tropical differentiation lacked a clean compositional framework.\n\n**Impact:** A tropical anti-cancellation correspondence would provide new tools for Newton polytope computation, tropical intersection theory, and algorithmic aspects of tropical geometry.\n\n**Catalog References:** `Catalog/Pythagorean/HigherOrderAntiCancel.lean` (derivMultiShadow_add, weightedKShadow), `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (QuadraticShadow).\n\n**Proof Strategy:** Define a tropical shadow operator on support sets, prove it coincides with the classical derivMultiShadow via the falling multinomial positivity, extend to aggregates using the semigroup law.\n\n**Domain Bridges:** Tropical geometry \u2194 Combinatorial Hodge theory, Algebraic geometry \u2194 Optimization.\n\n**Lineage:** Extends the main theorem (support_weighted_orderDeriv_eq_kShadow) to tropical algebra.\n\n**Ambition:** Grand challenge \u2014 would establish a new bridge between classical and tropical algebraic geometry.\n\n---\n\n## Direction 2: Shadow Cardinality Lower Bounds for Arithmetic Circuit Complexity\n\n**Conjecture:** For the complete homogeneous symmetric polynomial $h_d(x_1, \\ldots, x_n)$ and order-$k$ derivative aggregates with full positive weights, the shadow cardinality $|\\text{weightedKShadow}(S, T)|$ grows as $\\Theta\\binom{n+d-k-1}{n-1})$, providing a tight lower bound on the number of monomials in any arithmetic circuit computing the aggregate.\n\n**Test:** Compute shadow cardinalities for $h_d(x_1, \\ldots, x_n)$ for $n \\leq 10$, $d \\leq 8$, $k \\leq 4$ and verify the asymptotic prediction. Compare against known circuit complexity bounds.\n\n**The key insight is** that the card_support_orderDerivAggregate_eq_card_kShadow theorem converts support-size lower bounds into exact equalities, eliminating the slack that plagues most complexity arguments.\n\n**Why now?** The formally verified shadow cardinality equality provides a rigorous foundation for complexity lower bounds that was previously unavailable.\n\n**Impact:** Could contribute to resolving VP \u2260 VNP or related algebraic complexity conjectures by providing new invariants.\n\n**Catalog References:** `Catalog/Pythagorean/HigherOrderAntiCancel.lean` (card_support_orderDerivAggregate_eq_card_kShadow, weightedKShadow_mono).\n\n**Proof Strategy:** Enumerate the shadow of the support of $h_d$ under all order-$k$ multi-indices using stars-and-bars combinatorics. The shadow of the simplex support under erosion by $m$ is a translated simplex; the union has cardinality given by an inclusion-exclusion formula.\n\n**Domain Bridges:** Combinatorial Hodge theory \u2194 Arithmetic circuit complexity, Algebraic complexity \u2194 Enumerative combinatorics.\n\n**Lineage:** Direct application of the cardinality corollary.\n\n**Ambition:** Grand challenge \u2014 arithmetic complexity lower bounds are among the hardest problems in theoretical CS.\n\n---\n\n## Direction 3: Parametric Shadow Invariants for Matroid Families\n\n**Conjecture:** For the basis polynomial $f_M$ of a matroid $M$ on ground set $[n]$ of rank $r$, the shadow cardinality sequence $s_k(M) = |\\text{weightedKShadow}(\\text{supp}(f_M), T_k)|$ (where $T_k$ is the set of all order-$k$ squarefree multi-indices) is a matroid invariant that refines the $f$-vector of the matroid independence complex.\n\n**Test:** Compute $s_k(M)$ for all matroids on $\\leq 8$ elements and $k \\leq 4$. Check whether $s_k$ distinguishes non-isomorphic matroids that share the same Tutte polynomial. Identify which matroid operations (deletion, contraction, duality) have clean shadow-theoretic interpretations.\n\n**The key insight is** that derivative shadows of basis polynomial supports are combinatorial invariants that see finer structure than the Tutte polynomial, because they track individual exponent-level geometry rather than aggregate statistics.\n\n**Why now?** The semigroup law makes shadow sequences computable and compositional. Previous support-based matroid invariants lacked this algebraic structure.\n\n**Impact:** A new matroid invariant that distinguishes Tutte-equivalent matroids would be significant for matroid theory and its applications to coding theory and optimization.\n\n**Catalog References:** `Catalog/Pythagorean/HigherOrderAntiCancel.lean` (derivMultiShadow, weightedKShadow, derivMultiShadow_add), `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (aggregateShadow).\n\n**Proof Strategy:** Express shadow cardinalities as sums over matroid flats using the lattice of flats characterization. Use M\u00f6bius inversion to relate shadow sequences to Whitney numbers.\n\n**Domain Bridges:** Matroid theory \u2194 Enumerative combinatorics, Combinatorial Hodge theory \u2194 Coding theory.\n\n**Lineage:** Extends the shadow framework to parametric families of polynomials.\n\n**Ambition:** Solid extension \u2014 builds on proven shadow calculus with concrete testable predictions.\n\n---\n\n## Direction 4: Quantitative Cancellation Bounds for Mixed-Sign Weights\n\n**Conjecture:** For a polynomial $p$ with nonneg coefficients and a weight function $A$ with mixed signs, the number of cancelled monomials $|\\text{weightedKShadow}(\\text{supp}(p), \\text{supp}(A))| - |\\text{supportOrderDerivAggregate}(p, A)|$ is bounded above by the number of shadow points with overlap multiplicity $\\geq 2$ and sign-incoherent contributions.\n\n**Test:** For random nonneg polynomials in 4\u20136 variables with 10\u201350 terms, sample mixed-sign weights and measure: (a) cancellation count, (b) overlap multiplicity distribution, (c) sign-incoherence count. Fit a regression model and verify the bound.\n\n**The key insight is** that cancellation requires both overlap (multiple derivatives contributing to the same monomial) AND sign incoherence (contributions of opposite sign). The positive-weight theorem eliminates sign incoherence entirely; the mixed-sign regime should be governed by the interaction of these two factors.\n\n**Why now?** The proven positive case provides the exact baseline. Extending to mixed signs requires understanding how the proof fails, which the aggregate coefficient formula makes transparent.\n\n**Impact:** Would complete the anti-cancellation picture by characterizing when and how much cancellation occurs, enabling robust support prediction even with mixed-sign weights.\n\n**Catalog References:** `Catalog/Pythagorean/HigherOrderAntiCancel.lean` (aggDerivCoeff_pos_iff_mem_shadow, aggDerivCoeff_term_nonneg), `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (OverlapSignCoherent, IsCancellationWitness).\n\n**Proof Strategy:** Decompose the aggregate coefficient into sign-coherent and sign-incoherent parts. Show the sign-coherent part is always nonzero (by the positive case). Bound the sign-incoherent part using Cauchy-Schwarz on the coefficient products.\n\n**Domain Bridges:** Numerical analysis \u2194 Combinatorial algebra, Signal processing \u2194 Polynomial arithmetic.\n\n**Lineage:** Directly extends the main theorem to the mixed-sign regime.\n\n**Ambition:** Solid extension \u2014 the mathematical framework is in place; the challenge is quantitative.\n\n---\n\n## Direction 5: Shadow Dynamics and Support Equilibria\n\n**Conjecture:** For a fixed polynomial $p$ with nonneg coefficients, the sequence of full shadow cardinalities $s_k = |\\text{weightedKShadow}(\\text{supp}(p), T_k)|$ (where $T_k$ is the set of all order-$k$ multi-indices) is log-concave and eventually reaches zero at $k = \\max\\{|e|_1 : e \\in \\text{supp}(p)\\}$.\n\n**Test:** Compute $s_k$ for diverse polynomial families (complete homogeneous, elementary symmetric, Schur, random nonneg) for $n \\leq 6$ and track whether the sequence $(s_0, s_1, s_2, \\ldots)$ is log-concave. Identify the polynomial families where the decay is fastest/slowest.\n\n**The key insight is** that the shadow sequence can be viewed as a discrete dynamical system: repeated erosion of the support lattice by the semigroup of multi-indices. Log-concavity of this sequence would connect to the Hodge-Riemann relations that govern Lorentzian polynomials.\n\n**Why now?** The semigroup law (derivMultiShadow_add) makes iterated erosion well-defined and compositional. Without this structure, tracking support decay across orders was ad hoc.\n\n**Impact:** Log-concavity of shadow sequences would establish a new connection between support geometry and the Hodge-theoretic properties that characterize Lorentzian polynomials, potentially providing a support-level characterization of the Lorentzian condition.\n\n**Catalog References:** `Catalog/Pythagorean/HigherOrderAntiCancel.lean` (derivMultiShadow_add, derivMultiShadow_zero, weightedKShadow_support_mono).\n\n**Proof Strategy:** For the simplex support (complete homogeneous symmetric polynomials), compute shadow cardinalities explicitly as binomial sums and verify log-concavity directly. For general supports, attempt an injection argument using the semigroup structure.\n\n**Domain Bridges:** Dynamical systems \u2194 Combinatorial Hodge theory, Discrete geometry \u2194 Statistical mechanics.\n\n**Lineage:** Extends the shadow semigroup structure to questions about sequence behavior.\n\n**Ambition:** Solid extension with grand-challenge flavor \u2014 log-concavity questions are deep but the framework provides concrete entry points.\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
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
    "source_exp_id": "111f3824",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T03:00:50.406393+00:00"
  },
  {
    "id": "fd_2040",
    "title": "The three theorems established in this work \u2014 the divisibility criterion, the mo",
    "description": "# Future Directions: Arithmetic Statistics of Graph Jacobians\n\n## Synthesis\n\nThe three theorems established in this work \u2014 the divisibility criterion, the moment identity, and the profile antitone property \u2014 provide the deterministic algebraic backbone for a new research program connecting random graph theory to arithmetic statistics. Each future direction below builds on this foundation, extending it toward asymptotic results, physical models, coding theory, and tropical geometry. The unifying theme is that the Smith normal form of the reduced Laplacian serves as a universal bridge: any domain that produces integer matrices (graphs, lattices, codes, dynamical systems) can be connected to Cohen-Lenstra-type predictions through the invariant factor machinery we have formalized. The five directions below form a coherent research arc from foundational theory (Direction 1) through computational methodology (Direction 2) to increasingly ambitious cross-domain applications (Directions 3-5).\n\n---\n\n## Direction 1: Finite-n Moment Convergence Rates for G(n, p) Jacobians\n\n**Conjecture:** For fixed prime q and edge probability p \u2208 (0,1), there exist explicit constants C(q, p) and \u03b1(q, p) > 0 such that for all n \u2265 n\u2080:\n\n$$\\left|\\mathbb{E}[M_{q,1}(\\text{Jac}(G(n,p)))] - q\\right| \\leq C(q,p) \\cdot n^{-\\alpha(q,p)}$$\n\nwhere \u03b1(q, p) \u2265 1/2 for p bounded away from 0 and 1.\n\n**Test:** Compute E[M_{q,1}] for G(n, 1/2) at n = 10, 20, 50, 100, 200, 500 (with 10,000 samples each) and fit the decay exponent \u03b1 by log-linear regression of |E[M_{q,1}] - q| vs n.\n\n**Impact:** This would be the first quantitative convergence result for graph Jacobian statistics, upgrading the qualitative conjecture of Wood (2017) to a rate theorem. It would establish graph Jacobians as a model system for Cohen-Lenstra with computable error bounds.\n\n**Catalog References:**\n- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `primePowerTorsionCount_eq_prod_gcd`, `primePowerTorsionCount_mono`\n- `Catalog/Pythagorean/CohenLenstra/Defs.lean`: `geomProb`, `cyclicWeight`\n\n**Proof Strategy:** Use the moment formula from Theorem B to reduce to counting lattice points in the Smith normal form. The key step is bounding the contribution of large invariant factors using spectral gap estimates for the Laplacian of G(n, p). Combine with Nguyen-Wood universality for random integer matrix cokernels.\n\n**Domain Bridges:** Random matrix theory \u2192 combinatorial probability \u2192 analytic number theory (Tauberian theorems for extracting rates from moment generating functions).\n\n**Lineage:** Extends Theorem B from exact identity to asymptotic convergence.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2606 \u2014 Substantial but within reach using existing random matrix techniques.\n\n---\n\n## Direction 2: Algorithmic Smith Normal Form Certification in Lean\n\n**Conjecture:** There exists a verified algorithm in Lean 4 that computes the Smith Normal Form of any n \u00d7 n integer matrix in O(n\u00b3 \u00b7 B) bit operations (where B = log(max|M_ij|)) and produces a certificate (unimodular matrices U, V and diagonal D with UMV = D) that can be checked in O(n\u00b2 \u00b7 B) bit operations.\n\n**Test:** Implement the algorithm for matrices up to 50 \u00d7 50 from random graph Laplacians. Verify that the certificate check passes in all cases and that runtime scales as predicted.\n\n**Impact:** This would close the formalization gap between our algebraic theorems (which assume invariant factor data as input) and the graph-theoretic source. It would also provide the first formally verified SNF algorithm, useful far beyond graph Jacobians.\n\n**Catalog References:**\n- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `InvariantFactorData`\n- `Catalog/Pythagorean/TropicalBridge/Defs.lean`: `graphLaplacian`\n\n**Proof Strategy:** Formalize the iterative pivot-reduction algorithm. Maintain invariants at each step: (1) the matrix at step k is Smith-equivalent to the original, (2) the submatrix M[0:k, 0:k] is already in diagonal form with divisibility. The certificate consists of the accumulated row/column operations.\n\n**Domain Bridges:** Computer algebra \u2192 formal verification \u2192 computational number theory.\n\n**Lineage:** Infrastructure for all future computational work in the Catalog involving integer matrix invariants.\n\n**Ambition:** \u2605\u2605\u2605\u2606\u2606 \u2014 Standard algorithm, main challenge is Lean engineering.\n\n---\n\n## Direction 3: Cohen-Lenstra for Random Regular Graphs (Grand Challenge)\n\n**Conjecture:** For random d-regular graphs on n vertices (d \u2265 3 fixed), the q-primary statistics of Jac(G) converge to the Cohen-Lenstra distribution, but with a different rate of convergence than G(n, p). Specifically, the rate \u03b1_d(q) should depend on d through the spectral gap of the random regular graph:\n\n$$\\alpha_d(q) = \\frac{1}{2}\\left(1 - \\frac{2\\sqrt{d-1}}{d}\\right) + O(q^{-1})$$\n\n**Test:** Sample random 3-regular and 4-regular graphs for n = 20, 50, 100 (using the configuration model), compute Jacobian moments, and compare convergence rates against the predicted formula.\n\n**Impact:** This would be paradigm-shifting: it would show that the Cohen-Lenstra universality extends beyond Erd\u0151s-R\u00e9nyi to a fundamentally different graph ensemble, and would connect the convergence rate to spectral theory (the Alon-Boppana bound 2\u221a(d-1) appears in the formula). It would establish arithmetic statistics as a probe for random graph spectral properties.\n\n**Catalog References:**\n- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: all main theorems\n- `Catalog/Pythagorean/CohenLenstra/Defs.lean`: CL distribution definitions\n\n**Proof Strategy:** The key insight is that the reduced Laplacian of a random d-regular graph has much more structure than a general random matrix: its row sums are constrained, and its spectral gap is known (Friedman's theorem). Use the trace method to bound moments of the SNF, exploiting the spectral gap to control error terms.\n\n**Domain Bridges:** Spectral graph theory \u2194 arithmetic statistics \u2194 random matrix theory \u2194 representation theory (via Friedman's proof).\n\n**Lineage:** Extends the entire framework from G(n,p) to random regular graphs.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 \u2014 Grand challenge; if solved, would open a new subfield.\n\n---\n\n## Direction 4: Sandpile Dynamics and Arithmetic Order Parameters\n\n**Conjecture:** For the abelian sandpile model on G(n, p), the correlation length of the avalanche size distribution is controlled by the largest invariant factor of the Jacobian:\n\n$$\\xi(G) \\sim \\log(\\text{exp}(\\text{Jac}(G)))$$\n\nUnder the Cohen-Lenstra conjecture, this predicts:\n\n$$\\mathbb{E}[\\xi(G(n,p))] \\sim c_p \\cdot n$$\n\nfor an explicit constant c_p depending on p.\n\n**Test:** Simulate the sandpile model on G(n, 1/2) for n = 20, 50, 100. Measure the avalanche correlation length and compare against log(exponent) of the Jacobian. Test the linear scaling prediction.\n\n**Impact:** This would establish the first formal bridge between self-organized criticality (statistical physics) and arithmetic statistics (number theory). The invariant factors of the Jacobian would become order parameters for sandpile dynamics, providing number-theoretic explanations for physical phenomena.\n\n**Catalog References:**\n- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `exponent_eq_largest_factor`, `primePow_dvd_exponent_iff_dvd_largest`\n- `Catalog/Pythagorean/ArithmeticSandpile/Defs.lean`: sandpile definitions\n\n**Proof Strategy:** The key insight is that the relaxation time of the sandpile is controlled by the spectral gap of the Laplacian, while the *algebraic* relaxation is controlled by the exponent of the Jacobian (the order of the slowest-decaying mode in the group algebra). Theorem A connects the exponent to the largest invariant factor, which is in turn related to the smallest eigenvalue of the reduced Laplacian.\n\n**Domain Bridges:** Statistical physics (self-organized criticality) \u2194 arithmetic statistics \u2194 spectral graph theory.\n\n**Lineage:** Extends Theorem A into the physics domain.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2606 \u2014 Bold but testable; the sandpile-Jacobian connection is well-established.\n\n---\n\n## Direction 5: Tropical Hodge Theory and Jacobian Fibrations\n\n**Conjecture:** For a family of graphs G_t parameterized by a tropical parameter t (e.g., edge weights in the tropical semiring), the invariant factor profile of Jac(G_t) varies semicontinuously in t, and the jumps in the profile correspond to tropical critical points of a natural height function.\n\nMore precisely: define the *tropical Jacobian fibration* as the map t \u21a6 InvariantFactorProfile(q, G_t). Then:\n1. The levels \u03bb_{q,j}(G_t) are upper semicontinuous in t.\n2. The set of t where the profile changes is a tropical hypersurface.\n\n**Test:** Consider weighted complete graphs K_n with edge weights drawn from {0, 1, 2, ..., M} (tropical integers). Compute invariant factor profiles as weights vary and verify semicontinuity. Plot the \"phase diagram\" of profile types.\n\n**Impact:** This would connect tropical geometry (Baker-Norine Riemann-Roch, tropical abelian varieties) to arithmetic statistics, creating a new field of \"tropical arithmetic statistics.\" The semicontinuity result would be analogous to the semicontinuity of fiber dimensions in algebraic geometry.\n\n**Catalog References:**\n- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `InvariantFactorProfile`, `qPrimaryCount_antitone`\n- `Catalog/Pythagorean/TropicalBridge/Defs.lean`: tropical matrix definitions\n- `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean`: chip-firing/tropical bridge\n\n**Proof Strategy:** The key insight is that the Smith invariant factors of an integer matrix are semicontinuous in the Zariski topology on matrix entries. For tropical deformations (which correspond to valuations of matrix entries), the divisibility conditions defining the profile are open, giving semicontinuity. The tropical critical points are where the rank of the SNF changes \u2014 exactly the tropical analogue of degeneration loci in algebraic geometry.\n\n**Domain Bridges:** Tropical geometry \u2194 arithmetic statistics \u2194 algebraic geometry (degeneration theory) \u2194 combinatorics (matroid theory, since tropical rank is matroid rank).\n\n**Lineage:** Extends the profile structure (Theorem C) into the tropical/geometric domain.\n\n**Ambition:** \u2605\u2605\u2605\u2605\u2605 \u2014 Grand challenge; would unify tropical geometry and arithmetic statistics.\n",
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
    "source_exp_id": "afddf6c2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T03:01:12.433975+00:00"
  },
  {
    "id": "seed_128",
    "title": "Gravity from Information: Spacetime as a Quantum Error-Correcting Code",
    "description": "Einstein showed that gravity is the curvature of spacetime. But WHY does spacetime curve? Conjecture: Spacetime IS a quantum error-correcting code, and gravity IS the syndrome of that code. The code is a [[n,k,d]] stabilizer code where n = number of Planck areas on a spatial slice, k = number of logical qubits (which equals the Bekenstein-Hawking entropy S = A/4G in natural units), and d = code distance (which equals the minimal geodesic length through the bulk). The key identity: S(A) = Area(gamma_A) / (4G) is EXACTLY the quantum Singleton bound n - k <= 2(d-1) rearranged as k = n - 2d + 2 = A/(4G) when n = A/l_P^2 and d = L/(2l_P). This means the Bekenstein-Hawking entropy formula is a quantum coding theorem, and the holographic principle is a coding constraint. Test: for AdS_3 with boundary CFT_2, the code is a [[n, k, d]] = [[L/l_P, S, L/(2l_P)]] code. Verify that the Singleton bound n - k <= 2(d-1) becomes L/l_P - S <= L/l_P - 1, which simplifies to S >= 1 (trivially true). The NON-TRIVIAL content is that the Ryu-Takayanagi formula S = A/(4G) is the exact quantum information identity. Impact: spacetime is not curved by matter \u2014 spacetime IS a code, and matter IS a syndrome. Gravity is not a force; it's error correction.",
    "domains": [
      "Novelty",
      "Physics",
      "Computation",
      "Cryptography"
    ],
    "priority_score": 0.95,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "5cb2654a",
    "timestamp": "2026-05-29T02:19:20.712014+00:00"
  },
  {
    "id": "fd_2041",
    "title": "The work in this cycle established three interconnected results: (1) rigorous pr",
    "description": "# Future Directions: Shadow Hodge Theory and Ultra-Log-Concavity\n\n## Synthesis\n\nThe work in this cycle established three interconnected results: (1) rigorous proof of log-concavity for binomial coefficients via a quantitative algebraic identity, (2) refutation of the naive Shadow-Hodge ULC conjecture through an explicit counterexample, and (3) a cross-domain bridge from combinatorial log-concavity to information-theoretic entropy bounds. These results open five distinct research directions, unified by the theme that *shadow operations on discrete structures encode deep positivity properties that bridge algebra, combinatorics, and information theory*. The counterexample, far from being a dead end, reveals that the correct formulation of ULC requires understanding the interplay between the M-convex exchange geometry and the ambient coordinate structure \u2014 a question that connects to tropical geometry, Lorentzian polynomials, and statistical mechanics.\n\n---\n\n## Direction 1: General M-Convex Shadow Log-Concavity via Lorentzian Polynomials\n\n**Conjecture:** For every M-convex set S \u2286 \u2115\u207f, the shadow profile a_k = |Sh_k(S)| is log-concave: a_k\u00b2 \u2265 a_{k-1} \u00b7 a_{k+1} for all valid k.\n\n**Test:** Enumerate all matroid basis supports (M-convex sets with 0-1 entries) for graphic matroids on \u2264 10 edges and all transversal matroids on \u2264 8 elements. Compute shadow profiles and verify log-concavity. Extend to non-multiaffine M-convex sets: enumerate all M-convex subsets of {0,1,2}\u00b3 and {0,1,2,3}\u00b2 systematically.\n\n**Impact:** Would establish a purely combinatorial route to Hodge-theoretic positivity for matroids, independent of the algebraic geometry of Adiprasito\u2013Huh\u2013Katz. Could simplify proofs of the Rota\u2013Heron\u2013Welsh conjecture.\n\n**Catalog References:**\n- `Catalog/Pythagorean/IteratedShadowGeometry.lean` \u2014 kthShadow, semigroup law\n- `Catalog/Pythagorean/MConvexShadowCompression.lean` \u2014 M-convex exchange, degree shadows\n- `Pythagorean/ShadowHodgeULC.lean` \u2014 binomial_log_concave, corrected_shadow_conjecture\n\n**Proof Strategy:** \n1. For a multiaffine M-convex set S (matroid bases), the generating polynomial f_S(x) = \u03a3_{\u03b1\u2208S} x^\u03b1 is Lorentzian (Br\u00e4nd\u00e9n\u2013Huh). \n2. The shadow profile equals the coefficient sequence of the univariate restriction f_S(t\u00b71) = \u03a3_k a_k \u00b7 t^k. \n3. Lorentzian \u27f9 coefficients of univariate restrictions are ULC \u27f9 log-concave. \n4. Extend to non-multiaffine case using Murota's M-convex theory and the preservation of Lorentzian property under variable substitution.\n\n**The key insight is** that the shadow operation corresponds exactly to univariate restriction of the generating polynomial, and Lorentzian polynomials are closed under this operation.\n\n**Why now?** The counterexample in this cycle (Theorem 3.6) clarifies the correct formulation: plain log-concavity, not ULC with D = max degree. Combined with the Lorentzian polynomial machinery now available in the literature, the tools are in place to formalize this connection.\n\n**Domain Bridges:** Algebraic combinatorics \u2194 Tropical geometry (via Newton polytopes of Lorentzian polynomials)\n\n**Lineage:** Extends Br\u00e4nd\u00e9n\u2013Huh [BH20] via shadow-theoretic interpretation\n\n**Ambition:** Grand challenge \u2014 would provide the first purely combinatorial proof of log-concavity for matroid basis counts\n\n---\n\n## Direction 2: Shadow Entropy Concentration and Optimal Coding\n\n**Conjecture:** For any M-convex set S \u2286 \u2115\u207f with log-concave shadow profile a_k, the normalized distribution p_k = a_k / \u03a3 a_j satisfies the entropy bound H(p) \u2264 (1/2) \u00b7 log(2\u03c0e \u00b7 Var(p)), where Var(p) is the variance. Moreover, there exists an explicit entropy-optimal arithmetic code for shadow profiles achieving rate within O(1/n) of the entropy.\n\n**Test:** For all uniform matroids U(r,n) with n \u2264 20, compute H(p) and compare with the Gaussian entropy bound. For partition matroids, verify computationally that the gap H_Gaussian - H(p) is always positive and quantify its dependence on the matroid structure.\n\n**Impact:** Would establish the first information-theoretic application of combinatorial log-concavity, opening a new direction in entropy coding for structured combinatorial objects.\n\n**Catalog References:**\n- `Catalog/Pythagorean/ShadowEntropy.lean` \u2014 entropy-shadow connections\n- `Pythagorean/ShadowHodgeULC.lean` \u2014 log_concave_ratio_antitone (the bridge theorem)\n\n**Proof Strategy:**\n1. Use log_concave_ratio_antitone to establish that the shadow distribution is strongly unimodal.\n2. Apply the Bobkov\u2013Madiman entropy power inequality for log-concave distributions.\n3. Derive the Gaussian bound from the entropy power inequality.\n4. Construct the arithmetic code using the monotone ratio property for efficient symbol encoding.\n\n**The key insight is** that ratio monotonicity (our Theorem 3.8) is exactly the condition needed for the Bobkov\u2013Madiman machinery, creating a direct pipeline from combinatorial structure to coding theory.\n\n**Why now?** Our formal proof of ratio monotonicity provides the missing rigorous foundation. The coding theory community has recently developed practical arithmetic codes for log-concave distributions, but lacked the combinatorial input.\n\n**Domain Bridges:** Combinatorics \u2194 Information theory \u2194 Coding theory\n\n**Lineage:** Builds on log_concave_ratio_antitone and shadow entropy work\n\n**Ambition:** Solid extension \u2014 clear path from existing results to new applications\n\n---\n\n## Direction 3: Shadow Semigroup and Iterated Derivative Structure\n\n**Conjecture:** The shadow operation satisfies the semigroup law Sh_m(Sh_k(S)) = Sh_{k+m}(S) for all finite S \u2286 \u2115\u207f and k, m \u2208 \u2115. Moreover, if S is M-convex, then each Sh_k(S) inherits a weakened form of M-convexity (specifically, the coordinate-sum constraint may change but the exchange property persists).\n\n**Test:** Verify the semigroup law for all M-convex subsets of {0,1}^n with n \u2264 6. For the inheritance conjecture, check whether Sh_k(S) satisfies M-convex exchange for all matroid basis sets on \u2264 7 elements.\n\n**Impact:** Would establish the algebraic foundation for iterative shadow analysis, enabling inductive proofs of log-concavity.\n\n**Catalog References:**\n- `Catalog/Pythagorean/IteratedShadowGeometry.lean` \u2014 kthShadow_add (the semigroup law at polynomial level)\n- `Catalog/Pythagorean/MConvexShadowCompression.lean` \u2014 degreeShadowSet\n\n**Proof Strategy:**\n1. For the semigroup law: show that \u03b2 \u2208 Sh_m(Sh_k(S)) iff there exists \u03b3 with |\u03b3|=k and \u03b3 \u2264 \u03b1 for some \u03b1 \u2208 S, and \u03b2 \u2264 \u03b3 with |\u03b2|=m... wait, this needs care. Actually Sh_m of a set T of degree-k vectors gives vectors of degree m dominated by some element of T. The composition should give vectors of degree m dominated by vectors of degree k dominated by elements of S, which equals vectors of degree m dominated by elements of S (since domination is transitive). So Sh_m(Sh_k(S)) \u2286 Sh_m(S), and equality holds when m \u2264 k. For m > k this needs to be checked.\n2. For M-convex inheritance: use the exchange axiom on S to construct exchange witnesses for Sh_k(S).\n\n**The key insight is** that the shadow semigroup structure provides the algebraic backbone for induction on the degree parameter k, which is the natural proof strategy for log-concavity.\n\n**Why now?** The kthShadow_add result in the Catalog establishes this at the polynomial coefficient level. Lifting it to the set-theoretic shadow is the natural next step.\n\n**Domain Bridges:** Discrete convex analysis \u2194 Semigroup theory\n\n**Lineage:** Extends kthShadow_add from polynomial to set-theoretic setting\n\n**Ambition:** Solid extension \u2014 well-defined and achievable with current tools\n\n---\n\n## Direction 4: Phase Transitions in Shadow Profile Distributions (Grand Challenge)\n\n**Conjecture:** For a random M-convex set S drawn from the uniform distribution on M-convex subsets of {0,1}^n of degree r, the shadow profile a_k undergoes a phase transition at k* = r/2: below k*, the profile is approximately C(n,k) (the uniform matroid profile), while above k*, it concentrates around a matroid-specific value determined by the exchange geometry. The critical exponent of the phase transition is universal (independent of the specific matroid distribution).\n\n**Test:** Sample random matroids on n = 10, 12, 14 elements with various ranks. Compute shadow profiles and plot a_k / C(n,k) as a function of k/r. Look for universal scaling near k/r = 1/2.\n\n**Impact:** Would establish a statistical mechanics framework for matroid theory, connecting the combinatorial exchange axiom to critical phenomena in physics. Could lead to efficient sampling algorithms for matroid bases.\n\n**Catalog References:**\n- `Catalog/Pythagorean/PartitionShadow.lean` \u2014 partition function, Gibbs measures\n- `Pythagorean/ShadowHodgeULC.lean` \u2014 shadow profile definitions\n\n**Proof Strategy:**\n1. Model the shadow profile as a partition function Z(\u03b2) = \u03a3_k a_k \u00b7 e^{\u03b2k}.\n2. Show that log-concavity of a_k implies log-convexity of Z(\u03b2) (connecting to the Gibbs variational principle).\n3. Identify the phase transition as the point where the dominant term in Z(\u03b2) switches from the left to the right branch of the unimodal profile.\n4. Compute critical exponents using the quantitative log-concavity ratio (n+1)/(k(n-k)).\n\n**The key insight is** that the quantitative strengthening of log-concavity (the excess ratio from Theorem 3.1) provides a natural \"temperature\" parameter for the shadow profile, and its dependence on k reveals the phase structure.\n\n**Why now?** The Partition Shadow infrastructure in the Catalog provides the statistical mechanics framework, and our quantitative log-concavity results provide the combinatorial input.\n\n**Domain Bridges:** Matroid theory \u2194 Statistical mechanics \u2194 Random matrix theory\n\n**Lineage:** Builds on PartitionShadow.lean and ShadowHodgeULC.lean\n\n**Ambition:** Grand challenge \u2014 would establish a new paradigm connecting discrete convex analysis to physics\n\n---\n\n## Direction 5: Effective Bounds on Shadow Profile Decay Rates\n\n**Conjecture:** For the uniform matroid U(r,n), the shadow profile ratio a_{k+1}/a_k = C(n,k+1)/C(n,k) = (n-k)/(k+1) satisfies:\n- For k < n/2: a_{k+1}/a_k > 1 (profile is increasing)\n- For k = \u230an/2\u230b: a_k is maximized\n- For k > n/2: a_{k+1}/a_k < 1 and the decay rate accelerates\n\nMore precisely, for general M-convex sets, the ratio a_{k+1}/a_k is bounded above by (n-k)/(k+1) and below by max(0, (r-k)/(k+1)) where r = max degree and n = ambient dimension.\n\n**Test:** Verify the ratio bounds for all graphic matroids on \u2264 8 edges. For each, compute a_{k+1}/a_k and compare with the conjectured upper and lower bounds.\n\n**Impact:** Effective decay bounds enable efficient algorithms for shadow-based optimization and provide explicit concentration inequalities for matroid distributions.\n\n**Catalog References:**\n- `Pythagorean/ShadowHodgeULC.lean` \u2014 binomial_ratio_antitone\n- `Catalog/Pythagorean/MConvexShadowCompression.lean` \u2014 degreeShadow_card_le_of_multiaffine\n\n**Proof Strategy:**\n1. The upper bound a_{k+1}/a_k \u2264 (n-k)/(k+1) follows from a_k \u2264 C(n,k) (the shadow is bounded by the full simplex) combined with the explicit ratio formula.\n2. The lower bound requires the M-convex exchange property: each element of Sh_k(S) can be extended to at least one element of Sh_{k+1}(S) via the exchange axiom.\n3. The acceleration of decay follows from the second-order ratio bound (Theorem 3.8).\n\n**The key insight is** that the ratio bounds provide a \"highway\" from abstract log-concavity to concrete algorithmic bounds, making the theory computationally actionable.\n\n**Why now?** The ratio antitone theorem (proved in this cycle) provides the upper bound machinery. The exchange-based lower bound is a natural next step.\n\n**Domain Bridges:** Combinatorics \u2194 Algorithm design \u2194 Optimization\n\n**Lineage:** Direct extension of binomial_ratio_antitone to general M-convex sets\n\n**Ambition:** Solid extension \u2014 directly actionable with clear algorithmic applications\n",
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
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "2fc8f3a2",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T03:37:56.384637+00:00"
  },
  {
    "id": "fd_2042",
    "title": "The results in this cycle establish the foundation of **certificate-driven expan",
    "description": "# Future Directions: Certified Expander Synthesis for GL\u2082(\ud835\udd3d_q)\n\n## Synthesis\n\nThe results in this cycle establish the foundation of **certificate-driven expander synthesis**: algebraic conditions on matrix pairs (irreducible characteristic polynomial, primitive determinant, generation) provably imply positive spectral gap for the associated Cayley graph. The key bridge theorem \u2014 Singer-like elements fix no projective point \u2014 connects algebraic certification to projective dynamics, opening multiple research fronts. The five directions below radiate from this central connection: (1) strengthening the gap to a quantitative uniform bound, (2) extending to higher-rank groups, (3) bridging to quantum error correction, (4) connecting to automorphic forms, and (5) applying to derandomization. Each direction builds directly on the formal infrastructure established here and is testable by specific computational experiments.\n\n---\n\n## Direction 1: Quantitative Uniform Gap via Representation Decomposition\n\n**Conjecture:** There exists a constant C > 0 such that for every prime q \u2265 5 and every certified pair (g, h) in GL\u2082(\ud835\udd3d_q), the spectral gap satisfies \u03b3(S_{g,h}) \u2265 C/q, where C \u2248 1.24 based on computational evidence.\n\n**Test:** Decompose the averaging operator into irreducible representation components and bound each one:\n- Principal series (q-1 dimensional): bound using Kloosterman sum estimates.\n- Cuspidal (q+1 dimensional): bound using Gauss sum estimates and Singer-like action.  \n- Steinberg (q dimensional): bound using unipotent fixed-point analysis.\n- One-dimensional: bound using primitive determinant condition.\nVerify that the worst case occurs in the projective permutation representation for q \u2208 {5, 7, 11, 13, 17, 19, 23, 29, 31}.\n\n**Impact:** The first uniform family of 4-regular expanders for GL\u2082(\ud835\udd3d_q) with purely algebraic certificates. Would establish certificate-driven expansion as a viable alternative to Ramanujan graph constructions.\n\n**Catalog References:**\n- `Catalog/Pythagorean/GL2SpectralGap.lean`: `singer_like_charpoly_no_root`, `singer_like_no_fixed_projective_point`, `certified_spectral_gap_qualitative`\n- `Catalog/Pythagorean/CertificateExpanders.lean`: `harmonic_meanzero_eq_zero`, `certified_pair_harmonic_trivial`\n- `Catalog/Algebra/MatrixGroupGeneration.lean`: `eq_bot_or_top_of_charpoly_irreducible`\n\n**Proof Strategy:** Strategy A (representation decomposition). For each family of irreducible representations of GL\u2082(\ud835\udd3d_q), compute the operator norm of the averaging operator restricted to that family. Use Singer-like condition to bound principal series contributions (Singer element acts without fixed vector on principal series with nontrivial weight), and primitive determinant to eliminate determinant-character obstructions. Combine by taking minimum over families.\n\n**Domain Bridges:** Spectral graph theory \u2192 representation theory of finite groups \u2192 character sum estimates (analytic number theory).\n\n**Lineage:** Extends `certified_spectral_gap_qualitative` from qualitative (\u03b3 > 0) to quantitative (\u03b3 \u2265 C/q).\n\n**Ambition:** grand_challenge \u2014 would resolve a fundamental open question in explicit expander construction.\n\n---\n\n## Direction 2: Higher-Rank Singer Certificates for GL_n(\ud835\udd3d_q)\n\n**Conjecture:** For n \u2265 3, define a *Singer-n certificate* as a matrix g \u2208 GL_n(\ud835\udd3d_q) with irreducible characteristic polynomial (of degree n) and a companion matrix h with primitive determinant. Then certified pairs yield expanders for GL_n(\ud835\udd3d_q) with gap \u03b3 \u2265 C_n/q^{n-1}.\n\n**The key insight is** that the irreducible charpoly condition for degree n forces g to act as a Singer cycle on \ud835\udd3d_{q^n}\u00d7, generating a maximally non-split torus. This is the natural generalization of our SingerLike condition from n=2 to arbitrary n.\n\n**Why now?** The formal infrastructure for n=2 (`eq_bot_or_top_of_charpoly_irreducible` and `singer_like_no_fixed_projective_point`) generalizes directly: irreducible charpoly implies no invariant proper subspace (already proven in `MatrixGroupGeneration.lean` for arbitrary n), and the projective dynamics generalize to Grassmannian dynamics.\n\n**Test:** For n=3 and q \u2208 {5, 7, 11}, find Singer-3 certified pairs and compute spectral gaps of the associated 4-regular Cayley graphs on GL\u2083(\ud835\udd3d_q). Verify \u03b3 \u2248 C\u2083/q\u00b2.\n\n**Impact:** A complete family of algebraically certified expanders for all GL_n(\ud835\udd3d_q), unified by a single certificate structure.\n\n**Catalog References:**\n- `Catalog/Algebra/MatrixGroupGeneration.lean`: `eq_bot_or_top_of_charpoly_irreducible` (works for arbitrary dimension)\n- `Catalog/Pythagorean/GL2SpectralGap.lean`: all definitions and theorems (n=2 case)\n\n**Proof Strategy:** Extend the projective dynamics argument: Singer-n elements fix no point on PG(n-1, q), which forces mixing on the full flag variety. The Dirichlet energy argument (Theorems 5-6) is dimension-independent and transfers directly.\n\n**Domain Bridges:** Algebraic geometry (flag varieties) \u2192 combinatorial group theory (generation in GL_n).\n\n**Lineage:** Direct generalization of GL\u2082 theory to GL_n.\n\n**Ambition:** extension \u2014 substantial but follows established patterns.\n\n---\n\n## Direction 3: Quantum LDPC Codes from Certified Cayley Graphs\n\n**Conjecture:** Certified Cayley graphs for GL\u2082(\ud835\udd3d_q) yield quantum LDPC codes with parameters [[n, k, d]] where n = |GL\u2082(\ud835\udd3d_q)| = (q\u00b2-1)(q\u00b2-q), k = \u0398(n), and d = \u03a9(n^{1/2}/polylog(n)), via the hypergraph product or lifted product construction.\n\n**The key insight is** that the spectral gap of the certified Cayley graph directly controls the code distance in the hypergraph product construction of Tillich and Z\u00e9mor: a graph with spectral gap \u03b3 and n vertices yields a code with distance \u03a9(\u03b3 \u00b7 n^{1/2}). Our \u03b3 \u2248 C/q \u2248 C/n^{1/4} gives d = \u03a9(n^{1/4}).\n\n**Why now?** Recent breakthroughs in quantum LDPC codes (Panteleev-Kalachev, Leverrier-Z\u00e9mor) use Cayley graphs of matrix groups as building blocks. Certified pairs provide the first *algebraically verifiable* input to these constructions, ensuring the resulting quantum code has provable distance bounds without eigenvalue computation.\n\n**Test:** Construct the hypergraph product of Cay(GL\u2082(\ud835\udd3d_q), S) for q = 5, 7, 11. Compute the code parameters and verify the distance bound.\n\n**Impact:** Algebraically certified quantum error-correcting codes \u2014 a new paradigm for quantum computing reliability.\n\n**Catalog References:**\n- `Catalog/Pythagorean/GL2SpectralGap.lean`: `certified_spectral_gap_qualitative`, `exponential_mixing_from_contraction`\n- `Catalog/Pythagorean/CertificateExpanders.lean`: `mixing_decay_of_contraction`\n\n**Proof Strategy:** Apply the Tillich-Z\u00e9mor hypergraph product to the adjacency matrix of Cay(GL\u2082(\ud835\udd3d_q), S). Use the spectral gap bound to derive a distance lower bound via the expansion-distance connection.\n\n**Domain Bridges:** Spectral graph theory \u2192 quantum error correction \u2192 fault-tolerant quantum computing.\n\n**Lineage:** Applies certified expander infrastructure to quantum coding theory.\n\n**Ambition:** grand_challenge \u2014 connects to one of the most active areas in quantum computing.\n\n---\n\n## Direction 4: Deligne-Style Character Sum Estimates for the Projective Bottleneck\n\n**Conjecture (Projective Bottleneck).** For certified pairs in GL\u2082(\ud835\udd3d_q), the worst-case second eigenvalue of the Cayley graph averaging operator is achieved by the (q+1)-dimensional permutation representation on \u2119\u00b9(\ud835\udd3d_q). Moreover, this eigenvalue can be bounded by Deligne-type estimates: \u03bb\u2082 \u2264 1 - C/q where C is related to Kloosterman sum bounds.\n\n**The key insight is** that the projective representation decomposes into characters of the Borel subgroup, and the matrix coefficients of Singer elements in this decomposition involve Kloosterman sums. Deligne's proof of the Weil conjectures gives |K(a,b;q)| \u2264 2\u221aq, which translates to eigenvalue bounds for the averaging operator.\n\n**Why now?** The Projective Bottleneck Conjecture is strongly supported by computational data (q\u00b7\u03b3_proj \u2248 1.24 for all tested primes). Deligne's bounds are available in a usable form, and the representation theory of GL\u2082(\ud835\udd3d_q) is completely classified (Green, Piatetski-Shapiro).\n\n**Test:** For q \u2208 {5, 7, ..., 97}, compute the full spectrum of the projective action and verify that the second eigenvalue matches the Kloosterman-predicted bound.\n\n**Impact:** Would connect certified expander theory to automorphic forms and the Langlands program, establishing a deep bridge between explicit combinatorics and arithmetic geometry.\n\n**Catalog References:**\n- `Catalog/Pythagorean/GL2SpectralGap.lean`: `singer_like_no_fixed_projective_point`\n- `Catalog/Pythagorean/CayleyExpander/CharacterSumBounds.lean` (if exists)\n- `Catalog/Algebra/MatrixGroupGeneration.lean`: `eq_bot_or_top_of_charpoly_irreducible`\n\n**Proof Strategy:** Decompose the projective permutation matrix into Fourier modes of the Borel subgroup. Express each matrix coefficient as a character sum. Apply Deligne bounds to each sum. Reassemble to get the operator norm bound.\n\n**Domain Bridges:** Finite group representation theory \u2192 algebraic geometry (Weil conjectures) \u2192 analytic number theory (character sums).\n\n**Lineage:** Deepens the projective dynamics bridge of Theorem 2.\n\n**Ambition:** grand_challenge \u2014 connects to Langlands program.\n\n---\n\n## Direction 5: Deterministic Derandomization via Certified Cayley Walks\n\n**Conjecture:** For any BPP algorithm with error probability \u03b5, replacing the random bits with a walk on a certified Cayley graph of GL\u2082(\ud835\udd3d_q) reduces the error to \u03b5 \u00b7 (1 - C/q)^t after t steps, using only O(log q + t \u00b7 log 4) = O(log n + t) truly random bits.\n\n**The key insight is** that the exponential mixing theorem (Theorem 8) provides exactly the quantitative convergence guarantee needed for Impagliazzo-Zuckerman derandomization. A certified pair gives a 4-regular expander with algebraic proof of expansion, which can be used as the derandomization device.\n\n**Why now?** The formal proof of exponential mixing (Theorem 8) provides a machine-verified convergence rate. Combined with the algorithmic certified pair finder, this gives a complete, verified derandomization pipeline.\n\n**Test:** Implement the derandomized algorithm for a concrete BPP problem (e.g., polynomial identity testing) using certified Cayley walks. Compare error rates with pseudorandom generators and truly random bits.\n\n**Impact:** Certified algebraic expanders as drop-in replacements for pseudorandom generators in derandomization \u2014 with formally verified correctness guarantees.\n\n**Catalog References:**\n- `Catalog/Pythagorean/GL2SpectralGap.lean`: `exponential_mixing_from_contraction`, `certified_spectral_gap_qualitative`\n- `Catalog/Pythagorean/CertificateExpanders.lean`: `l2_mixing_decay`\n\n**Proof Strategy:** Apply the Ajtai-Koml\u00f3s-Szemer\u00e9di reduction from BPP to expander walks. Use certified Cayley graph as the expander, with spectral gap \u03b3 = C/q providing the convergence rate. The total randomness is O(log |G|) = O(log q\u2074) = O(log q) for the initial vertex plus O(t \u00b7 2) bits for the t-step walk on a 4-regular graph.\n\n**Domain Bridges:** Spectral graph theory \u2192 computational complexity theory \u2192 practical algorithm design.\n\n**Lineage:** Applies the mixing time machinery of Section 9.\n\n**Ambition:** extension \u2014 direct application of existing infrastructure.\n",
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
    "source_exp_id": "1286fbc6",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T03:38:17.837094+00:00"
  },
  {
    "id": "fd_2044",
    "title": "The M-convexity inheritance theorem reveals that second-derivative aggregation p",
    "description": "# Future Directions: M-Convexity Inheritance and Hessian Shadows\n\n## Synthesis\n\nThe M-convexity inheritance theorem reveals that second-derivative aggregation preserves the exact combinatorial exchange geometry of discrete optimization domains. This creates a new functorial pathway from Lorentzian positivity (algebraic geometry) through M-convex exchange systems (discrete optimization) to polynomial-time algorithms. The five directions below extend this bridge in complementary ways: deeper into algebraic structure (Direction 1), broader across optimization theory (Direction 2), into the physics of negative dependence (Direction 3), toward tropical geometry (Direction 4), and into algorithmic game theory (Direction 5).\n\n---\n\n## Direction 1: Higher-Order Shadow Cascades and M-Convex Towers\n\n**Conjecture:** For any M-convex set S with constant degree d \u2265 k, the k-step shadow \u2202\u1d4fS = \u2202(\u2202(...\u2202(S)...)) is M-convex.\n\n**Test:** Verify computationally for U(r,n) with n \u2264 10 and k up to d. Check whether the exchange graph diameter changes predictably with k.\n\n**Impact:** Would establish an infinite tower of M-convex sets descending from any starting set, creating a \"discrete derivative calculus\" with guaranteed algorithmic tractability at every level. This would mean every Lorentzian polynomial generates a polynomial-length cascade of efficiently optimizable combinatorial state spaces.\n\n**The key insight is** that the compositional structure of our proof (two-step = one-step twice) immediately generalizes, but the base case needs re-verification at each step because the exchange witnesses change.\n\n**Why now?** The formalization infrastructure (definitions, helper lemmas, commutation identities) is now in place, making inductive generalization feasible.\n\n**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (Theorems 1-3)\n\n**Proof Strategy:** Induction on k, using the one-step inheritance as the inductive step. The key lemma (exchange commutation through shadows) is already proved.\n\n**Domain Bridges:** Tropical geometry (erosion of Newton polytopes), algebraic K-theory (filtrations of exchange systems)\n\n**Lineage:** Direct extension of Theorems 1-2 in the current work.\n\n**Ambition:** solid_extension\n\n---\n\n## Direction 2: Valuated M-Convexity and Weighted Shadow Morphisms\n\n**Conjecture:** For a valuated matroid (M, \u03c9) with M-convex support and valuation \u03c9 satisfying a convexity condition, the weighted Hessian shadow AgSh(S, A) inherits valuated M-convexity when A is compatible with \u03c9.\n\n**Test:** Compute valuated exchange graphs for graphic matroids with random valuations under positive weight matrices. Check whether the \"discrete concavity\" of the valuation is preserved through the shadow.\n\n**Impact:** Would extend the inheritance theorem from set-level M-convexity to function-level M\u266e-convexity, connecting to the full power of Murota's discrete convex duality. This would enable Fenchel-type duality for Hessian-derived optimization problems.\n\n**The key insight is** that the shadow operation on supports is the combinatorial projection of a differentiation operator on valuated functions, and M\u266e-convexity is preserved under projections in Murota's framework.\n\n**Why now?** Valuated matroid theory has matured significantly with recent work by Baker-Bowler, and the categorical framework for morphisms between valuated matroids is now available.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (anti-cancellation), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`\n\n**Proof Strategy:** Extend the support-level shadow to include coefficient tracking. Use anti-cancellation to ensure support exactness, then verify the valuated exchange axiom using the convexity of \u03c9.\n\n**Domain Bridges:** Tropical geometry (tropicalization of Hessians), algebraic geometry (Newton-Okounkov bodies)\n\n**Lineage:** Builds on anti-cancellation results and the set-level inheritance theorem.\n\n**Ambition:** grand_challenge\n\n---\n\n## Direction 3: Negative Dependence and Hessian Markov Chains\n\n**Conjecture:** If \u03bc is a strongly log-concave distribution (equivalently, its generating polynomial is Lorentzian), then the \"Hessian response distribution\" defined by the aggregate Hessian has M-convex support, enabling polynomial-time mixing of local Markov chains on the Hessian state space.\n\n**Test:** Simulate Glauber dynamics on the support of AgHess(p, I) for determinantal point process generating polynomials. Measure mixing times and compare with the theoretical O(n log n) bound guaranteed by M-convexity.\n\n**Impact:** Would provide a new class of efficiently sampleable distributions derived from strongly log-concave measures, with applications to experimental design, diversity sampling, and Monte Carlo methods in machine learning.\n\n**The key insight is** that M-convexity of the support is precisely the condition needed for the \"down-up walk\" and similar local Markov chains to mix in polynomial time, by the framework of Anari-Liu-Oveis Gharan-Vinzant.\n\n**Why now?** The connection between Lorentzian polynomials and rapid mixing was established in 2021-2023, but the role of Hessian shadows as derived sampling domains has not been explored.\n\n**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (Theorem 5, matroid application)\n\n**Proof Strategy:** Use the inheritance theorem to establish M-convexity of the Hessian support, then invoke known mixing time bounds for exchange walks on M-convex sets.\n\n**Domain Bridges:** Statistical physics (partition functions), machine learning (determinantal sampling), probability (negative association)\n\n**Lineage:** Combines the inheritance theorem with Anari et al.'s mixing time results.\n\n**Ambition:** grand_challenge\n\n---\n\n## Direction 4: Tropical Hessians and Newton Polytope Erosion\n\n**Conjecture:** The two-step shadow of an M-convex set S equals the integer points of the Minkowski difference Newton(S) \u2296 \u0394\u2082, where \u0394\u2082 is the second dilate of the standard simplex, intersected with the hyperplane of degree d-2.\n\n**Test:** Compute Newton polytopes and Minkowski differences for matroid basis polytopes. Verify that the integer points of the eroded polytope match the two-step shadow exactly.\n\n**Impact:** Would provide a polyhedral-geometric characterization of the shadow operation, connecting M-convexity inheritance to the tropical geometry of Newton subdivisions and enabling the use of polyhedral computation tools.\n\n**The key insight is** that the shadow operation \u03b1 \u21a6 \u03b1 - e\u1d62 - e\u2c7c is a Minkowski subtraction at the tropical level, and the M-convexity of integer points in generalized polymatroids is preserved under such operations.\n\n**Why now?** Tropical Hodge theory has recently been developed by Adiprasito-Huh-Katz, providing the geometric framework to interpret derivative shadows as erosion operations on Newton polytopes.\n\n**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (shadow definitions)\n\n**Proof Strategy:** Show that the shadow equals the lattice points of a generalized polymatroid, then use Murota's characterization of M-convex sets as lattice points of base polyhedra.\n\n**Domain Bridges:** Tropical geometry, polyhedral combinatorics, algebraic geometry\n\n**Lineage:** Geometric reinterpretation of the combinatorial shadow theorem.\n\n**Ambition:** solid_extension\n\n---\n\n## Direction 5: Hessian Shadows in Algorithmic Game Theory\n\n**Conjecture:** In a combinatorial auction with matroid-based valuations, the set of Hessian-perturbed allocations (under second-order price sensitivity) forms an M-convex set, enabling polynomial-time computation of approximate Walrasian equilibria in the perturbed market.\n\n**Test:** Implement a Hessian-perturbed auction clearing algorithm for graphic matroid valuations. Compare convergence rate with unperturbed clearing and verify that the exchange property enables greedy equilibrium finding.\n\n**Impact:** Would establish that second-order sensitivity analysis in combinatorial markets preserves the tractability of equilibrium computation \u2014 a key requirement for robust mechanism design under perturbation.\n\n**The key insight is** that Walrasian equilibrium computation reduces to optimization over M-convex sets (Murota-Shioura), and the inheritance theorem guarantees that Hessian perturbation doesn't destroy this structure.\n\n**Why now?** The connection between M-convexity and market equilibria was formalized by Murota-Shioura in 2014, but robustness under analytic perturbation has not been studied.\n\n**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (Theorems 3, 5)\n\n**Proof Strategy:** Model the perturbed market as AgHess applied to the matroid valuation polynomial, then apply the inheritance theorem and Murota-Shioura's equilibrium existence result.\n\n**Domain Bridges:** Algorithmic game theory, mechanism design, mathematical economics\n\n**Lineage:** Application of the morphism property (Theorem 3) to economic settings.\n\n**Ambition:** solid_extension\n",
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
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "93b2b0c7",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T04:14:57.399442+00:00"
  },
  {
    "id": "seed_118",
    "title": "Holographic Primes: The Prime Number AdS/CFT Correspondence",
    "description": "The AdS/CFT correspondence says that a gravitational theory in the bulk of anti-de Sitter space is equivalent to a conformal field theory on the boundary. What if prime numbers have a holographic dual? Define the prime hologram: for each prime p, define its 'boundary' as the ring Z/pZ and its 'bulk' as the p-adic field Q_p. Conjecture: The Riemann zeta function zeta(s) = prod_p (1 - p^{-s})^{-1} is the holographic partition function: the product over primes (boundary) encodes the same information as the completed zeta function Xi(s) (bulk). The functional equation Xi(s) = Xi(1-s) is the holographic duality: bulk physics at depth s equals boundary physics at depth 1-s. The prime counting function pi(x) ~ x/log(x) is the bulk volume, while the Chebyshev function theta(x) = sum_{p<=x} log(p) is the boundary area. The AdS/CFT dictionary: bulk gravity mode at depth s <-> boundary CFT operator of dimension 1-s. Test: verify that the pair correlation of zeta zeros matches GUE random matrices (bulk = quantum gravity in AdS, boundary = CFT random matrix ensemble). Compute the 'prime partition function' Z(beta) = prod_p (1 - e^{-beta log p})^{-1} and show it equals the bulk partition function. Impact: the Riemann Hypothesis is equivalent to a holographic stability condition \u2014 zeros on the critical line means the bulk geometry is stable against perturbations.",
    "domains": [
      "Novelty",
      "NumberTheory",
      "Physics",
      "Algebra"
    ],
    "priority_score": 0.91,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "4dd1f7b8",
    "timestamp": "2026-05-29T02:19:19.805962+00:00"
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
    "id": "seed_115",
    "title": "Dark Mathematics: Theorems That Exist But Cannot Be Found",
    "description": "There are mathematical objects whose existence we can prove but whose specific properties are unknowable \u2014 theorems that cast shadows without being visible. Define a dark theorem as a statement T such that: (1) PA proves 'there exists x such that T(x)', but (2) for every specific n, PA does NOT prove T(n). The classic example is the Paris-Harrington theorem: the strengthened finite Ramsey theorem is true but not provable in PA. But dark theorems go further: they assert the existence of objects that no specific instance can be verified. Conjecture: The set of dark theorems is dense in the space of all Pi_2 statements \u2014 most true Pi_2 statements are dark. Moreover, there is a hierarchy of darkness: a dark theorem of level k is one where PA proves 'there exist at least k values of x such that T(x)' but cannot identify any specific one. The hierarchy is strict: level k+1 dark theorems are strictly harder to prove than level k. Test: construct explicit dark theorems of levels 1, 2, 3 using the Paris-Harrington principle and the Kirby-Paris hydra theorem. Prove the density conjecture by counting Pi_2 statements. Impact: most true mathematical statements are dark \u2014 they assert existence without the possibility of verification. This is not incompleteness; it is a new form of mathematical unknowability.",
    "domains": [
      "Novelty",
      "Logic",
      "NumberTheory"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T02:19:19.544634+00:00"
  },
  {
    "id": "seed_108",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography",
      "Logic",
      "Computation"
    ],
    "priority_score": 0.89,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "ece69f8c",
    "timestamp": "2026-05-29T02:19:18.924456+00:00"
  },
  {
    "id": "seed_127",
    "title": "The Monster Group's Secret Message: Moonshine Beyond the j-Function",
    "description": "The Monster group M is the largest sporadic simple group, with order 2^46 * 3^20 * 5^9 * 7^6 * 11^2 * 13^3 * 17 * 19 * 23 * 29 * 31 * 41 * 47 * 59 * 71 (approximately 8 * 10^{53}). Monstrous moonshine says that the coefficients of the j-function encode the dimensions of representations of M. But the j-function is just the TIP of the iceberg. Conjecture: The full moonshine correspondence associates to each conjugacy class g in M a McKay-Thompson series T_g(q) = sum a_n(g) q^n that is a modular function of a specific level, and the product over all g in M of T_g(q) equals a modular form of weight |M|/24 that encodes the complete character table of M. The secret message: the Monster group IS a modular form, and every property of M (its order, its character table, its maximal subgroups) can be read off from the q-expansion of this product. Test: compute the first 100 coefficients of T_g(q) for each conjugacy class of M and verify they match the known character values. Prove that the product of all T_g(q) converges to a modular form. Impact: the Monster is not just connected to modular forms \u2014 it IS a modular form. The 194 conjugacy classes of M correspond to 194 modular forms, and their product encodes everything.",
    "domains": [
      "Novelty",
      "Algebra",
      "NumberTheory"
    ],
    "priority_score": 0.89,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T02:19:20.613473+00:00"
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
    "id": "seed_123",
    "title": "The L-Function Oracle: What If We Could Compute L-Functions Instantly?",
    "description": "Suppose we had an oracle that computes L(s, chi) for any L-function and any complex s in O(1) time. What theorems would follow? Conjecture: The L-function oracle implies (1) The Riemann Hypothesis (compute zeros directly), (2) The BSD conjecture (compute the order of vanishing at s=1), (3) The Sato-Tate conjecture (compute the distribution of a_p), (4) Langlands functoriality (compare L-functions on both sides of the functoriality lift), and (5) A polynomial-time algorithm for factoring (the L-function of an elliptic curve E over Z/nZ detects factors of n). But the oracle also implies IMPOSSIBILITY results: (6) P != NP (because NP-complete problems would reduce to L-function computations that the oracle solves in O(1), contradicting the time hierarchy theorem if P = NP). Wait \u2014 the oracle solves L-function computations in O(1), so if P = NP, then NP problems can be encoded as L-function computations and solved instantly, but the oracle's existence is an axiom, not a theorem. The correct statement: the L-function oracle collapses the polynomial hierarchy to L-function computations. Test: prove that the Riemann Hypothesis follows from the oracle. Prove that BSD follows. Prove that factoring is in P given the oracle. Impact: understanding what an L-function oracle implies tells us exactly how powerful L-functions are \u2014 and how far we are from proving things about them.",
    "domains": [
      "Novelty",
      "NumberTheory",
      "Computation",
      "Logic"
    ],
    "priority_score": 0.88,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "bd87e7e2",
    "timestamp": "2026-05-29T02:19:20.261048+00:00"
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
    "id": "seed_132",
    "title": "The L-Function Universe: A Cosmic Census of All L-Functions",
    "description": "L-functions are the DNA of mathematics \u2014 each one encodes deep arithmetic information. But how many L-functions ARE there? The L-function universe is vast: (1) The Riemann zeta function (1 L-function), (2) Dirichlet L-functions (countably many), (3) L-functions of elliptic curves (uncountably many, one per j-invariant), (4) L-functions of modular forms (countably many, but indexed by weight and level), (5) L-functions of Galois representations (enormous family). Conjecture: The set of 'natural' L-functions (those satisfying the Selberg class axioms: analytic continuation, functional equation, Euler product, Ramanujan bound) is COUNTABLE. This means the universe of well-behaved L-functions is no bigger than the integers, despite each individual L-function encoding infinitely much information. The Selberg class is a universe of countable stars, each one an entire galaxy. Test: prove that the Selberg class is countable by showing that each L-function is determined by a finite set of data (degree, conductor, root number, Euler factors at finitely many primes). Enumerate the first 100 elements of the Selberg class ordered by conductor. Impact: the mathematical universe of L-functions is countable \u2014 there are only as many well-behaved L-functions as integers. Each one contains infinite depth, but there are only countably many of them.",
    "domains": [
      "Novelty",
      "NumberTheory",
      "Algebra",
      "Analysis"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T02:19:21.082866+00:00"
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
    "id": "fd_2043",
    "title": "The results in this cycle establish the first formal dictionary between Lorentzi",
    "description": "# Future Directions: Lorentzian Information Theory\n\n## Synthesis\n\nThe results in this cycle establish the first formal dictionary between Lorentzian polynomial negativity and information-theoretic quantities. The susceptibility bound (Theorem 1) bridges to statistical mechanics, the chi-squared MI bound (Theorem 2) opens information theory, the entropy deletion bounds (Theorems 3\u20134) establish data processing, and the Shearer-type covering (Theorem 6) gives structural control. Together, these create a foundation for **discrete Hodge-information theory**: the study of how algebraic curvature controls information flow on combinatorial structures. The five directions below extend this foundation toward entropy submodularity, higher-order information, continuous geometry, algorithmic mixing, and privacy theory.\n\n---\n\n## Direction 1: Entropy Submodularity from Lorentzian Structure\n\n**Conjecture:** For any FinsetLaw \u03bc and coordinate subsets A, B \u2286 [n], the marginal entropies satisfy H(X_A) + H(X_B) \u2265 H(X_{A\u222aB}) + H(X_{A\u2229B}). Moreover, when \u03bc is robustly Lorentzian with gap \u03b5, the submodularity defect H(A) + H(B) \u2212 H(A\u222aB) \u2212 H(A\u2229B) = I(X_{A\\B}; X_{B\\A} | X_{A\u2229B}) is bounded by O(\u03b5 \u00b7 |A\\B| \u00b7 |B\\A|).\n\n**Test:** Formalize entropy submodularity in Lean via the chain rule and conditional mutual information \u2265 0 (which follows from Gibbs' inequality, already available via `log_le_sub_one`). Verify the quantitative bound computationally on uniform matroids for n = 4, ..., 10 with varying A, B.\n\n**Impact:** Entropy submodularity is the key ingredient for the full Shearer inequality without additive error. Combined with the robustness quantification, it would give the definitive Shearer-type theorem for Lorentzian measures: H(\u03bc) \u2264 (1/r) \u03a3_t H(X_{A_t}) \u2212 correction(\u03b5), where the correction is a *bonus* (not a penalty) arising from negative dependence.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (xlogx_superadditive, entropy_delete_le), `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` (kl_le_chi_sq_four, log_le_sub_one).\n\n**Proof Strategy:** Build from the KL \u2264 \u03c7\u00b2 bound already in the catalog. Define conditional MI as I(A;B|C) = H(A|C) + H(B|C) \u2212 H(A,B|C). Prove I \u2265 0 via Gibbs' inequality applied to the conditional distributions. Then submodularity is immediate. The quantitative bound follows from bounding the conditional MI by the sum of pairwise MIs (which are O(\u03b5\u00b2) each), giving a defect of O(\u03b5\u00b2 \u00b7 |A\\B| \u00b7 |B\\A|).\n\n**Domain Bridges:** Information theory (Shearer's lemma), combinatorics (matroid union), optimization (submodular function theory).\n\n**Lineage:** Direct extension of Theorems 3\u20136 in the current cycle.\n\n**Ambition:** Solid extension \u2014 entropy submodularity is classical and the proof pathway is clear. The quantitative Lorentzian refinement is novel.\n\nThe key insight is that Lorentzian negativity provides the exact structure needed to quantify the submodularity defect: the conditional MI between disjoint coordinate sets decomposes into pairwise terms that are each controlled by the gap.\n\nWhy now? The xlogx superadditivity lemma and the partition infrastructure (sum_partition_insert) built in this cycle provide the formal tools needed for the chain rule decomposition.\n\n---\n\n## Direction 2: Higher-Order Information Geometry\n\n**Conjecture:** For robustly Lorentzian \u03bc with gap \u03b5 and any k-tuple of distinct coordinates (i\u2081, ..., i\u2096), the total correlation TC(X_{i\u2081}, ..., X_{i\u2096}) = \u03a3\u2c7c H(X_{i\u2c7c}) \u2212 H(X_{i\u2081},...,X_{i\u2096}) satisfies TC \u2264 C(k) \u00b7 \u03b5\u00b2 \u00b7 (max p\u1d62)^k / (min (1\u2212p\u1d62))^k.\n\n**Test:** Compute total correlation for 3-tuples and 4-tuples on U(8,4) and U(10,5). Check whether the bound scales as \u03b5\u00b2 or \u03b5^k. Plot TC vs k for fixed \u03b5 to determine the growth rate.\n\n**Impact:** This would extend the pairwise MI bound (Theorem 2) to arbitrary subsets, showing that Lorentzian negativity suppresses *all* multi-coordinate dependencies, not just pairwise ones. This is the information-theoretic analogue of the ultra-log-concavity theorem of Br\u00e4nd\u00e9n\u2013Huh.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (chiSq_le_of_robust, total_pairwise_MI_bound), `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` (robust_quadform_negativity).\n\n**Proof Strategy:** Induction on k. The base case k=2 is Theorem 2. For the inductive step, use the chain rule TC(X\u2081,...,X\u2096) = TC(X\u2081,...,X_{k-1}) + I(X\u2096; (X\u2081,...,X_{k-1})) and bound the conditional MI using the covariance structure.\n\n**Domain Bridges:** Neuroscience (synergy vs. redundancy), machine learning (higher-order feature interactions), quantum information (multipartite entanglement measures).\n\n**Lineage:** Extends Theorem 2 (pairwise MI bound) and the total_pairwise_MI_bound corollary.\n\n**Ambition:** Grand challenge \u2014 higher-order information quantities are notoriously difficult to bound, and the interaction between Lorentzian structure and multivariate information is unexplored.\n\nThe key insight is that the Lorentzian Hessian controls not just the 2\u00d72 covariance submatrices but the entire covariance matrix, which should propagate to higher-order information quantities through the matrix tree theorem or determinantal identities.\n\nWhy now? The formal infrastructure for pairwise bounds is complete, and computational experiments can immediately test whether the conjectured k-dependence holds.\n\n---\n\n## Direction 3: Fisher Information Metric from Lorentzian Generating Polynomials\n\n**Conjecture:** Given a family of Lorentzian distributions \u03bc_\u03b8 parameterized by \u03b8 \u2208 \u211d^d, the Fisher information matrix g_{ab}(\u03b8) = \u03a3_S (\u2202_a log \u03bc_\u03b8(S))(\u2202_b log \u03bc_\u03b8(S)) \u03bc_\u03b8(S) inherits a signature constraint from the Lorentzian structure: g has at most one direction of \"fast\" information accumulation, with all others bounded by the Lorentzian gap.\n\n**Test:** For the exponential tilt family \u03bc_\u03b8(S) \u221d exp(\u03a3\u1d62 \u03b8\u1d62 \u00b7 \ud835\udfd9_{i\u2208S}) \u00b7 \u03bc\u2080(S), compute the Fisher matrix numerically for U(6,3) as base measure and verify the eigenvalue structure.\n\n**Impact:** This would establish a continuous Riemannian information geometry whose curvature is controlled by Lorentzian polynomial structure. It would unify the discrete negativity results with continuous information geometry \u00e0 la Amari-Nagaoka, creating a bridge between algebraic combinatorics and differential geometry.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (RobustlyLorentzian), `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (laplacianEnergy, dpp_laplacianEnergy_eq_resolventDirichlet).\n\n**Proof Strategy:** Express the Fisher matrix in terms of the Hessian of the log-partition function log Z(\u03b8) = log \u03a3_S exp(\u03b8\u00b71_S) \u03bc\u2080(S). The Hessian of log Z is exactly the covariance matrix of indicator variables under \u03bc_\u03b8, which has Lorentzian signature by robust_quadform_negativity applied to the tilted measure.\n\n**Domain Bridges:** Differential geometry (Riemannian metrics), statistical physics (free energy curvature), machine learning (natural gradient methods), general relativity (Lorentzian signature of spacetime metrics).\n\n**Lineage:** Bridges RepulsiveInfoGeometry (Laplacian energy) with the information-theoretic framework developed here.\n\n**Ambition:** Grand challenge \u2014 this would create a genuinely new mathematical object (a Lorentzian information manifold) with implications for geometry, physics, and optimization.\n\nThe key insight is that the covariance matrix of indicator variables under a Lorentzian distribution IS the Fisher information matrix of the exponential tilt family, and Lorentzian signature of the Hessian directly translates to signature constraints on the Fisher metric.\n\nWhy now? The RepulsiveInfoGeometry file already establishes the connection between DPP log-Hessians and graph Laplacians. Combining this with the information-theoretic bounds creates the explicit bridge.\n\n---\n\n## Direction 4: Certified Mixing Times via Entropy Contraction\n\n**Conjecture:** For a robustly Lorentzian measure \u03bc with gap \u03b5, the Glauber dynamics (single-site update) Markov chain satisfies an entropy contraction: H(\u03bd P) \u2264 (1 \u2212 \u03b5/n) \u00b7 H(\u03bd) + C for any measure \u03bd, where P is the transition kernel and C depends on \u03b5. This implies mixing time O(n log(n) / \u03b5).\n\n**Test:** Simulate Glauber dynamics on U(8,4) and perturbed variants. Measure entropy of the chain state at each step and fit the contraction rate. Compare with the predicted 1 \u2212 \u03b5/n.\n\n**Impact:** Direct algorithmic significance: certified mixing times for MCMC sampling on Lorentzian distributions. Combined with robust_quadform_negativity's perturbation stability, this gives mixing certificates for noisy Lorentzian measures, directly relevant to approximate counting and sampling.\n\n**Catalog References:** `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` (spectral_gap_stability, mixing_time_bound_pos), `Catalog/Pythagorean/LorentzianInfoTheory.lean` (entropy_delete_le, entropy_delete_ge).\n\n**Proof Strategy:** Use the entropy deletion bounds as the core step: each Glauber update deletes one coordinate and resamples it, changing entropy by at most log 2. Under robustness, the expected entropy change is controlled by the spectral gap (already bounded in the catalog). Apply the entropy method for mixing (cf. Martinelli's lectures) with the certified spectral gap from spectral_gap_stability.\n\n**Domain Bridges:** Algorithms (MCMC), statistical physics (Glauber dynamics), machine learning (sampling-based inference), optimization (simulated annealing).\n\n**Lineage:** Combines the entropy bounds (this cycle) with the spectral gap certificates (RobustLorentzianSampling).\n\n**Ambition:** Solid extension with high practical value \u2014 mixing time certification is a central problem in algorithmic sampling.\n\nThe key insight is that the entropy deletion bounds provide exactly the per-step entropy change control needed for the entropy method of proving mixing, and the spectral gap from the catalog provides the contraction rate.\n\nWhy now? The spectral gap stability theorem and the entropy bounds are now both formalized, so the remaining step is the entropy method framework connecting them.\n\n---\n\n## Direction 5: Privacy Amplification Under Lorentzian Sampling\n\n**Conjecture:** If a mechanism samples S from a robustly Lorentzian measure \u03bc with gap \u03b5 and releases S \\ {k} (deleting one coordinate), then the mechanism satisfies (\u03b1, \u03b5_priv)-R\u00e9nyi differential privacy with \u03b5_priv = O(log(1/\u03b5)), where \u03b1 is the R\u00e9nyi order. Moreover, releasing any t coordinates deleted gives \u03b5_priv = O(t \u00b7 log(1/\u03b5)).\n\n**Test:** Compute R\u00e9nyi divergence numerically for U(8,4) under coordinate deletion. Compare with the standard composition theorem predictions and with the Lorentzian-specific bound.\n\n**Impact:** Creates the first formal connection between Lorentzian combinatorics and differential privacy. Lorentzian measures could serve as a new mechanism design primitive: sample from a Lorentzian distribution and release partial information, with privacy guaranteed by the Lorentzian gap.\n\n**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (entropy_delete_le, entropy_delete_ge, chiSq_le_of_robust).\n\n**Proof Strategy:** Use the chi-squared bound to control the R\u00e9nyi divergence between the full and deleted distributions. The key identity is D_\u03b1(\u03c0_k \u03bc || \u03c0_k \u03bd) \u2264 D_\u03b1(\u03bc || \u03bd) (data processing for R\u00e9nyi), and the chi-squared bound controls D_2.\n\n**Domain Bridges:** Privacy (differential privacy, R\u00e9nyi DP), security (information-theoretic secrecy), law (data protection compliance), healthcare (medical data release).\n\n**Lineage:** Extends the entropy deletion bounds and MI bounds to the privacy domain.\n\n**Ambition:** Solid extension with high applied impact \u2014 privacy amplification is an active area and Lorentzian measures provide a natural mechanism.\n\nThe key insight is that coordinate deletion from a Lorentzian measure is a natural privacy mechanism, and the entropy/MI bounds provide exactly the quantitative control needed for formal privacy guarantees.\n\nWhy now? The entropy deletion bounds are now certified, and the gap between formal privacy theory and combinatorial sampling is exactly what these results address.\n",
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
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "8c1a4c4e",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T03:38:36.715380+00:00"
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
    "id": "seed_120",
    "title": "Impossibility Results for Fun: Things That Cannot Be Done (But We Try Anyway)",
    "description": "Mathematics is full of impossibility theorems \u2014 things that CANNOT be done. But impossibility theorems are themselves beautiful mathematical objects. Catalog and interconnect the great impossibilities: (1) Squaring the circle (pi is transcendental, Lindemann 1882). (2) Trisecting the angle (cos 20 degrees has degree 3 over Q, Wantzel 1837). (3) Doubling the cube (cube root of 2 has degree 3, Wantzel 1837). (4) Solving the quintic by radicals (A_5 is not solvable, Abel-Ruffini 1824). (5) The Borsuk-Ulam impossibility (every continuous map S^n -> R^n has a point where f(x) = f(-x)). (6) Arrow's impossibility (no voting system is simultaneously fair, complete, and non-dictatorial). (7) Heisenberg's uncertainty (Delta x * Delta p >= hbar/2). Conjecture: These impossibility theorems are connected by a deep structural principle \u2014 each one arises because a certain group action is not free. Squaring the circle fails because Gal(Q(pi)/Q) acts freely. Solving the quintic fails because A_5 acts freely on the roots. Arrow's theorem fails because the symmetric group acts freely on preferences. Heisenberg fails because the Heisenberg group acts freely on phase space. The unified principle: a task is impossible iff the relevant group action is free. Test: verify that each impossibility theorem corresponds to a free group action. Prove the converse: if a group G acts freely on a set X, then there exists a G-equivariant task that is impossible on X. Impact: all impossibility is the same impossibility \u2014 every CAN'T is a reflection of a free group action.",
    "domains": [
      "Novelty",
      "Algebra",
      "Geometry",
      "Logic"
    ],
    "priority_score": 0.84,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "aa62444b",
    "timestamp": "2026-05-29T02:19:19.984429+00:00"
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
    "id": "seed_121",
    "title": "Surreal Topology: What Topology Does the Field of Surreal Numbers Have?",
    "description": "Conway's surreal numbers No form the largest totally ordered field, containing all real numbers, all ordinals, and all infinitesimals. But No is a proper class, not a set. What topology does it have? Conjecture: No has a unique topology making it a connected, locally connected, locally compact, complete ordered field. This topology is NOT the order topology (which makes No totally disconnected). Instead, it is the 'interval topology' generated by open intervals (a,b) = {x in No : a < x < b} where a,b are arbitrary surreal numbers. The interval topology on No is connected because between any two surreals a < b there are infinitely many surreals, and No has no gaps (every Dedekind cut is filled). Moreover, No is contractible in this topology \u2014 every surreal number can be continuously deformed to 0 via the homotopy H(x,t) = x * {t | 0} where {t | 0} is the surreal number between t and 0. Test: prove that No with the interval topology is connected. Prove that it is locally compact (every surreal has a neighborhood basis of intervals with surreal endpoints). Prove that No is contractible. Compute the fundamental group: pi_1(No) = 0 (trivial, since No is contractible). Impact: the largest ordered field has a natural topology that makes it contractible \u2014 every surreal number is connected to every other by a continuous path.",
    "domains": [
      "Novelty",
      "Algebra",
      "Topology",
      "Analysis"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T02:19:20.071943+00:00"
  },
  {
    "id": "seed_126",
    "title": "Chaos as a Computable Shadow: The Shadowing Lemma for Real Programs",
    "description": "The shadowing lemma says that near an approximate orbit of a chaotic system, there exists a true orbit. In other words, every 'almost correct' trajectory of a chaotic map has a 'truly correct' trajectory nearby. This means that numerical errors in chaotic simulations are not bugs \u2014 they are SHADOWS of real trajectories. Conjecture: Every program that computes a chaotic map f: R^n -> R^n has the property that its floating-point output is shadowed by a true orbit of f. More precisely, for every epsilon > 0, there exists delta > 0 such that if x_0, x_1, ..., x_N is a delta-pseudo-orbit (|x_{n+1} - f(x_n)| < delta for all n), then there exists a true orbit y_0, y_1, ..., y_N with |x_n - y_n| < epsilon for all n. The shadowing time N(epsilon, delta) grows at most polynomially in 1/delta for hyperbolic maps. Test: implement the logistic map f(x) = 4x(1-x) in floating-point and compute 10^6 iterations. For each floating-point orbit, use binary search to find the shadowing true orbit. Verify that the shadowing distance is at most 10^{-10} for floating-point precision 10^{-16}. Impact: numerical chaos is not error \u2014 it is a computable shadow of mathematical truth. Your computer's rounding errors are tracing out REAL orbits of the chaotic system.",
    "domains": [
      "Novelty",
      "Computation",
      "Analysis",
      "Logic"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T02:19:20.527334+00:00"
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
    "id": "seed_131",
    "title": "Self-Improving Proofs: Proofs That Get Simpler Over Time",
    "description": "Proofs are static objects, but what if proofs could improve? Define a proof refinement system where each proof P has a complexity C(P) = length(P) + depth(P) + number of lemmas, and a proof P' is a refinement of P if P' proves the same theorem with C(P') < C(P). Conjecture: For every theorem T provable in ZFC, there exists a sequence of refinements P = P_0, P_1, P_2, ... such that C(P_n) is non-increasing and the limit P_infinity is the simplest proof of T (in the sense of Kolmogorov complexity). Moreover, the refinement process halts: there exists N such that C(P_N) = C(P_{N+1}) = ... = C(P_infinity). The key insight: proof simplification is a well-founded process because the complexity is a natural number that decreases at each step. But the process can be arbitrarily long \u2014 the proof of the four-color theorem might require 10^100 refinements to reach its simplest form. Test: formalize the refinement system in Lean 4. Starting from the statement of the irrationality of sqrt(2), generate refinements by eliminating unnecessary lemmas, shortening case splits, and removing redundant quantifiers. Measure C(P) at each step and verify it decreases. Impact: proofs are not static \u2014 they are living objects that can be improved. The simplest proof of a theorem is the LIMIT of the refinement process, and this limit ALWAYS exists.",
    "domains": [
      "Novelty",
      "Logic",
      "Computation"
    ],
    "priority_score": 0.82,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "8273a6c0",
    "timestamp": "2026-05-29T02:19:20.992919+00:00"
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
    "id": "seed_113",
    "title": "Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back",
    "description": "An Escher staircase is an infinite strictly ascending chain of ideals I_1 strictly contained in I_2 strictly contained in ... that nevertheless has I_1 as an element of the infinite intersection. This seems impossible \u2014 how can an infinite ascending chain loop back to the beginning? But in the ring of integer-valued polynomials Int(Z), the chain I_n = {f in Int(Z) : f(Z) contained in 2^n Z} is strictly ascending (I_n strictly contained in I_{n+1}) yet the intersection of all I_n is {0}, which contains the zero polynomial that is also in I_1. Conjecture: Every non-Noetherian ring contains an Escher staircase, and the 'height' of the Escher effect (measured by the Krull dimension gap) is a new ring invariant. For Int(Z), the Escher height is infinite (the chain never stabilizes). For Z[x_1, x_2, ...], the Escher height equals the number of variables. For the p-adic integers Z_p, there is NO Escher staircase (Z_p is a DVR, hence Noetherian). Test: prove that Int(Z) has an Escher staircase of infinite height. Prove that k[x_1,...,x_n] has Escher height n. Compute the Escher height for the ring of all algebraic integers. Impact: a new invariant for non-Noetherian rings that measures how far a ring is from being Noetherian \u2014 the algebraic equivalent of Escher's impossible architecture.",
    "domains": [
      "Novelty",
      "Algebra",
      "Logic"
    ],
    "priority_score": 0.8,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "e16cf60e",
    "timestamp": "2026-05-29T02:19:19.367906+00:00"
  },
  {
    "id": "seed_125",
    "title": "The Unreasonable Effectiveness of the Number 163",
    "description": "Ramanujan's constant e^{pi*sqrt(163)} is remarkably close to an integer: it equals 262537412640768743.99999999999925... \u2014 just 7.5 * 10^{-13} away from 262537412640768744. This is not a coincidence: 163 is the largest Heegner number, and the near-integer property follows from the j-function and the fact that Q(sqrt(-163)) has class number 1. But 163 appears EVERYWHERE: it is prime, it is the smallest p such that Q(sqrt(-p)) has class number 1 and p > 2, it is a Chen prime, a lucky prime, a strongly prime, and the 38th prime. Conjecture: 163 is the unique integer n such that e^{pi*sqrt(n)} is within 10^{-6} of an integer. More generally, the Heegner numbers (1, 2, 3, 7, 11, 19, 43, 67, 163) are exactly the n for which Q(sqrt(-n)) has class number 1, and e^{pi*sqrt(n)} is near-integer for each. The 'magic' of 163 is that it is the LAST Heegner number \u2014 the final class number 1 imaginary quadratic field. Test: prove that e^{pi*sqrt(n)} is within 10^{-6} of an integer only for Heegner numbers. Compute e^{pi*sqrt(67)} and e^{pi*sqrt(43)} and verify near-integer behavior. Prove that 163 is the largest Heegner number (Stark-Heegner theorem). Impact: 163 is not magic \u2014 it is the climax of a deep theorem in algebraic number theory. The near-integer property of e^{pi*sqrt(163)} is the shadow of the class number 1 condition.",
    "domains": [
      "Novelty",
      "NumberTheory",
      "Analysis"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T02:19:20.439098+00:00"
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
    "id": "seed_135",
    "title": "The Prime Number Crossword: Filling the Gaps in the Primes",
    "description": "Prime gaps \u2014 the spaces between consecutive primes \u2014 are like empty cells in a crossword puzzle. The gaps are 1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4, 6, 6, 2, 6, 4, 2, ... (OEIS A001223). The pattern seems random, but the crossword has rules: (1) All prime gaps are even (except the first gap of 1 between 2 and 3). (2) A gap g can only appear at position n if n+g is prime and all of n+1, n+2, ..., n+g-1 are composite. (3) The density of gap g near n is approximately 2*C_2/(g*log(n)) where C_2 is the twin prime constant. Conjecture: The prime gap crossword is uniquely solvable \u2014 given the pattern of gaps up to N, the next prime is determined with probability 1 - O(1/log(N)). More precisely, the conditional probability that the next prime after p is p + g, given all primes up to p, is approximately 2*C_2/g * (1/log(p)) * product_{q prime, q | g} (q-1)/(q-2). This is the Hardy-Littlewood conjecture for prime gaps. But the crossword has a surprise: certain gap patterns FORCE the next number. For example, if the gaps near n are 6, 4, 2, 6, then the next gap is almost certainly 4 (the only way to fill the crossword). Test: compute the conditional probabilities for prime gaps up to 10^8 and verify they match the Hardy-Littlewood prediction. Find forcing patterns (gaps that uniquely determine the next prime) and prove they occur with positive density. Impact: prime gaps are not random \u2014 they are a solvable crossword puzzle with deterministic rules.",
    "domains": [
      "Novelty",
      "NumberTheory",
      "Computation"
    ],
    "priority_score": 0.78,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "5e2a75e9",
    "timestamp": "2026-05-29T02:19:21.364545+00:00"
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
    "id": "seed_111",
    "title": "Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities",
    "description": "A vampire number is a composite number v with an even number of digits that can be factizedd as v = x * y where x and y together have the same digits as v. The smallest is 1260 = 21 * 60. But vampire numbers are just the beginning. Define: (1) Werewolf numbers: v = x * y where x and y share exactly one digit with v. (2) Ghost numbers: v = x * y where v has NO digits in common with x or y. (3) Zombie numbers: v = x * y where x and y are both prime (these violate the definition but exist \u2014 125460 = 204 * 615 = 246 * 510, where both factorizations involve a prime and a composite). Conjecture: The density of vampire numbers in [10^{2n}, 10^{2n+1}] approaches 1/sqrt(n) as n -> infinity. Every even-length interval [10^{2k}, 10^{2k+2}] contains at least one vampire number. Ghost numbers have density 0 \u2014 they become vanishingly rare as the number of digits increases. Test: enumerate all vampire, werewolf, ghost, and zombie numbers up to 10^8. Prove the density conjecture by counting valid digit permutations. Impact: a playful but genuine number theory of arithmetic creatures \u2014 combinatorial digit problems that are easy to state but may be as hard as factoring.",
    "domains": [
      "Novelty",
      "NumberTheory",
      "Computation"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "prove",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "07676346",
    "timestamp": "2026-05-29T02:19:19.187841+00:00"
  },
  {
    "id": "fd_2045",
    "title": "The theorems established in this work \u2014 soundness, expansion correctness, and co",
    "description": "# Future Directions: Quantum Circuit Rewriting via Tensor Distributivity\n\n## Synthesis\n\nThe theorems established in this work \u2014 soundness, expansion correctness, and confluence modulo AC for distributive quantum circuit rewriting \u2014 form the first layer of a much deeper theory. The key unifying thread is that **distributivity is the algebraic skeleton of quantum parallelism**, and this skeleton connects at least four major mathematical traditions: term rewriting theory, categorical quantum mechanics, quantum information theory, and computational complexity. Each future direction below extends one of these connections, using the formally verified results as a springboard. The overarching vision is a unified framework where quantum circuit optimization, equivalence checking, and entanglement analysis all reduce to operations on distributive normal forms \u2014 and where the correctness of these operations is guaranteed by algebraic structure alone.\n\n---\n\n## Direction 1: Gate-Specific Completion and Extended Confluence\n\n**Conjecture:** The distributive rewrite system can be extended with gate-specific identities (HH = I, CNOT\u00b2 = I, T\u2078 = I) while preserving confluence modulo an appropriately extended AC equivalence, via Knuth-Bendix completion restricted to the finite gate alphabet.\n\n**Test:** Implement Knuth-Bendix completion for the extended system. Enumerate all critical pairs between distributive rules and gate-identity rules. Verify joinability of each critical pair computationally for circuits of depth \u2264 6. If completion terminates, formalize the extended confluence theorem.\n\n**Impact:** This would yield a complete equivalence-checking procedure for the Clifford+T fragment \u2014 the most practically important gate set for fault-tolerant quantum computing. It would subsume the soundness results of existing verified optimizers (e.g., VOQC) within a single algebraic framework.\n\n**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` (sorted rewrite invariants, normalization steps), `Pythagorean/KnuthBendixCompletion.lean` (abstract completion procedure), `Pythagorean/ConvergentRewriteSystems.lean` (convergent rewrite system foundations).\n\n**Proof Strategy:** Start from the existing `QRewriteStep` relation. Add new constructors for gate identities. For each new rule, compute all overlaps with existing rules. Show joinability by explicit rewrite derivations (critical-pair lemmas). Use the existing `expand_perm_of_rewrite` machinery to lift confluence to the extended system.\n\n**Domain Bridges:** Term rewriting theory \u2194 quantum compilation; Knuth-Bendix procedure \u2194 quantum gate algebra.\n\n**Lineage:** Extends Theorems 8\u20139 (expansion invariance and confluence) from the current work.\n\n**Ambition:** Grand challenge \u2014 if completion terminates, this resolves a major open problem in certified quantum compilation.\n\n---\n\n## Direction 2: Categorical Semantics and Coherence\n\n**Conjecture:** The distributive normal form corresponds to a coherence theorem in the free distributive monoidal category: every diagram in the free category on objects {gate(0), ..., gate(k)} that commutes in all semiring models is witnessed by a sequence of distributive rewrites.\n\n**Test:** Construct the free distributive monoidal category on a finite set of generators. Verify that the normal-form functor (expansion followed by canonical ordering) is a section of the quotient functor. Check that the unit and counit of this adjunction satisfy the triangle identities up to the appropriate natural isomorphism.\n\n**Impact:** This would establish a precise relationship between quantum circuit rewriting and categorical quantum mechanics, potentially providing the first constructive coherence theorem for distributive monoidal categories. It would also connect to the graphical calculi (string diagrams) used in categorical quantum computing.\n\n**Catalog References:** `Pythagorean/QuantumCircuitRewriting.lean` (denotation as semiring homomorphism, Theorem 6).\n\n**Proof Strategy:** Define a category `QExprCat` whose objects are types and whose morphisms are QExpr equivalence classes. Show that `denote` defines a faithful functor to the category of R-modules. Use the expansion function to construct a section, and derive coherence from the universality of the free construction.\n\n**Domain Bridges:** Category theory \u2194 circuit optimization; coherence theorems \u2194 canonical forms; monoidal categories \u2194 tensor networks.\n\n**Lineage:** Extends the cross-domain bridge (Theorem 6) from algebraic to categorical.\n\n**Ambition:** Grand challenge \u2014 coherence theorems for non-symmetric monoidal categories are an active area of research, and a distributive version would be novel.\n\n---\n\n## Direction 3: Entanglement-Aware Normal Forms\n\n**Conjecture:** Distributive normalization preserves the Schmidt rank of the operator it represents: if e \u2192* n, then schmidt_rank(denote(e)) = schmidt_rank(denote(n)). More precisely, the Schmidt decomposition of the denotation can be read off from the structure of the normal form.\n\n**Test:** Compute the Schmidt rank of denote(e) and denote(expand(e)) for all 2-qubit circuits of depth \u2264 4. Verify equality computationally. For circuits with Schmidt rank 1 (separable operators), verify that the normal form has a product structure (all monomials factor as tensor products of single-qubit gate sequences).\n\n**Impact:** This would be the first formal connection between algebraic rewriting and quantum entanglement theory. It would enable entanglement analysis via purely syntactic inspection of normal forms, without numerical computation of singular values.\n\n**Catalog References:** `Pythagorean/QuantumCircuitRewriting.lean` (expansion soundness, Theorem 3).\n\n**Proof Strategy:** Prove that each rewrite step preserves the bipartite structure of the operator tensor. Define a syntactic notion of \"tensor factorability\" for monomials (a monomial [g\u2081,...,g\u2096] is factorable if each g\u1d62 acts on only one qubit). Show that the number of non-factorable monomials is an upper bound on Schmidt rank.\n\n**Domain Bridges:** Rewriting theory \u2194 quantum information theory; syntactic structure \u2194 entanglement measures; normal forms \u2194 Schmidt decomposition.\n\n**Lineage:** Extends Theorem 3 (expansion soundness) to entanglement-theoretic invariants.\n\n**Ambition:** Solid extension \u2014 the computational verification is straightforward, and the formal proof is within reach using the existing expansion machinery.\n\n---\n\n## Direction 4: Tropical and Idempotent Variants\n\n**Conjecture:** The distributive normalization theory instantiates over the tropical semiring (\u211d \u222a {\u221e}, min, +) to produce a circuit-cost normal form: the expansion of a circuit over the tropical semiring computes the minimum-cost decomposition into sequential paths, and the confluence theorem guarantees that this minimum is independent of the rewrite order.\n\n**Test:** Instantiate the expansion function with tropical arithmetic. Verify that the tropical normal form of a circuit assigns to each monomial its total gate cost (sum of individual gate costs), and that the minimum-cost monomial is the shortest path through the circuit DAG. Compare with Dijkstra/Bellman-Ford on the circuit graph.\n\n**Impact:** The key insight is that the tropical instantiation transforms circuit optimization from a combinatorial search into an algebraic computation. This connects distributive rewriting to tropical geometry, optimal transport, and scheduling theory. Why now? The formal verification infrastructure (Theorems 1\u20139) is parametric over the semiring, so tropical instantiation is immediate.\n\n**Catalog References:** `Pythagorean/TropicalTensorDistributivity.lean` (tropical tensor distributivity), `Pythagorean/QuantumCircuitRewriting.lean` (semiring-parametric soundness).\n\n**Proof Strategy:** All theorems are already proved for arbitrary semirings. The tropical instantiation requires only defining the gate-cost environment `env : \u2115 \u2192 \u211d_tropical` and applying the existing theorems. The connection to shortest paths follows from the well-known correspondence between tropical matrix multiplication and all-pairs shortest paths.\n\n**Domain Bridges:** Tropical geometry \u2194 circuit optimization; min-plus algebra \u2194 scheduling theory; distributive normal forms \u2194 shortest-path algorithms.\n\n**Lineage:** Direct instantiation of the semiring-parametric theory (all 9 theorems).\n\n**Ambition:** Solid extension \u2014 immediate from the existing parametric infrastructure.\n\n---\n\n## Direction 5: Scalable Normal Forms via Decision Diagrams\n\n**Conjecture:** The distributive normal form admits a compressed representation as a binary decision diagram (BDD) on the monomial structure, achieving exponential compression for circuits with shared subexpressions, and the BDD operations (conjunction, disjunction) correspond exactly to the sequential and additive compositions of circuits.\n\n**Test:** Implement BDD-based normal form representation. Compare memory usage and comparison time with explicit list representation for circuits of depth 6\u201310 over 4+ qubits. Measure the compression ratio and identify circuit families where BDD compression is most effective.\n\n**Impact:** The key insight is that the monomial explosion in distributive expansion is analogous to the state explosion in model checking \u2014 and BDDs are the classical solution to state explosion. Why now? The correctness of the BDD representation follows from the confluence theorem (Theorem 9), which guarantees that the monomial multiset is canonical.\n\n**Catalog References:** `Pythagorean/QuantumCircuitRewriting.lean` (expansion function, confluence theorem).\n\n**Proof Strategy:** Define a BDD node type for monomials. Show that BDD canonical forms correspond to sorted monomial lists. Prove that BDD operations (apply, reduce) preserve the monomial multiset. The key lemma is that BDD reduction commutes with the expansion function.\n\n**Domain Bridges:** Formal verification \u2194 quantum compilation; BDD technology \u2194 tensor network compression; model checking \u2194 circuit equivalence.\n\n**Lineage:** Extends the normalization algorithm (Definition 7) to a scalable data structure.\n\n**Ambition:** Solid extension with grand-challenge potential \u2014 if BDD compression is effective for quantum circuits, this could enable practical equivalence checking for circuits beyond the 2-qubit fragment.\n",
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
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "1bc7e344",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T04:15:17.937889+00:00"
  },
  {
    "id": "fd_2046",
    "title": "The five theorems established in this work \u2014 the tropical indecomposability/sup-",
    "description": "# Future Directions: Tropical \ud835\udd3d\u2081-Skeleton Theory\n\n## Synthesis\n\nThe five theorems established in this work \u2014 the tropical indecomposability/sup-irreducibility identification, generation by \ud835\udd3d\u2081-points, the Boolean lattice characterization, the \ud835\udd3d\u2081-cardinality theorem, and the base change theorem \u2014 form the **affine foundation** of a program to make \"\ud835\udd3d\u2081 = tropical\" a theorem rather than a metaphor. The key structural insight is that finite distributive lattices provide a rigorous combinatorial model where the philosophy of \ud835\udd3d\u2081-geometry becomes operative: indecomposable elements play the role of \ud835\udd3d\u2081-points, and the full lattice is recovered by free completion (base change). The directions below extend this foundation along five axes: toward geometry (toric varieties and fans), toward dynamics (statistical mechanics and phase transitions), toward information theory (entropy and data compression), toward arithmetic (motivic integration and zeta functions), and toward algorithms (tropical optimization and combinatorial generation). Each direction is grounded in the catalog of proven results and proposes specific, falsifiable extensions.\n\n---\n\n## Direction 1: Birkhoff Representation as \ud835\udd3d\u2081-Scheme Theory\n\n**Conjecture:** The full Birkhoff representation theorem \u2014 every finite distributive lattice L is order-isomorphic to the lattice of lower sets of its poset J(L) of join-irreducibles \u2014 can be formalized in Lean 4 and interpreted as a \"Spec construction\" for \ud835\udd3d\u2081-affine schemes: the lattice L is the \ud835\udd3d\u2081-affine scheme, J(L) is its space of \ud835\udd3d\u2081-points, and the isomorphism is the structure sheaf.\n\n**Test:** Formalize the order isomorphism \u03c6: L \u2192 LowerSet(J(L)) in Lean, prove it is an OrderIso, and verify on Boolean lattices B_n and divisor lattices D_n that the map is computable and bijective.\n\n**Impact:** This would be the first formal realization of an \ud835\udd3d\u2081-scheme category inside a proof assistant, giving a concrete foundation for future development of \ud835\udd3d\u2081-algebraic geometry.\n\n**Catalog References:** `TropF1.sup_supIrred_eq` (generation theorem), `TropF1.supBotHom_eq_of_eq_on_supIrred` (base change), `TropF1.finset_supIrred_iff_singleton` (Boolean model).\n\n**Proof Strategy:** Build the Birkhoff map using `TropF1.sup_supIrred_eq` for surjectivity and lattice distributivity for injectivity. Use Mathlib's `OrderIso` infrastructure and `Finset.Iic` for lower sets.\n\n**Domain Bridges:** Algebraic geometry (\ud835\udd3d\u2081-scheme theory), category theory (adjunctions between lattices and posets).\n\n**Lineage:** Extends Theorem 2 (generation) and Theorem 5 (base change) to a full structural isomorphism.\n\n**Ambition:** Foundational extension \u2014 establishes the categorical framework for future \ud835\udd3d\u2081-geometry.\n\n---\n\n## Direction 2: Tropical Phase Transitions via \ud835\udd3d\u2081-Skeleton Collapse\n\n**Conjecture:** In a family of finite distributive lattices L_n parameterized by a \"temperature\" or \"coupling\" parameter (e.g., sublattices of a fixed lattice determined by a threshold), the \ud835\udd3d\u2081-cardinality F1Card(L_n) exhibits phase-transition-like behavior: it remains stable over parameter ranges, then drops sharply at critical values corresponding to structural transitions in the underlying lattice.\n\n**The key insight is** that the number of join-irreducible elements is a topological invariant of the lattice structure that is robust under small perturbations but sensitive to structural changes \u2014 making it a natural order parameter for lattice phase transitions.\n\n**Why now?** The generation theorem (Theorem 2) provides the theoretical foundation: every element is determined by the \ud835\udd3d\u2081-points below it, so a drop in F1Card signals a loss of independent generators \u2014 a collapse of structural complexity analogous to symmetry breaking.\n\n**Test:** Implement a family of lattices obtained by thresholding the divisor lattice of n! (or of highly composite numbers) and plot F1Card as a function of the threshold. Look for sharp drops corresponding to the loss of specific prime power generators.\n\n**Impact:** Would connect \ud835\udd3d\u2081-geometry to statistical mechanics and the theory of phase transitions, opening a new interface between arithmetic combinatorics and physics.\n\n**Catalog References:** `TropF1.F1Card_finset_eq_card` (cardinality computation), `TropF1.sup_supIrred_eq` (generation).\n\n**Proof Strategy:** Prove monotonicity of F1Card under lattice quotients. Show that collapsing a join-irreducible element reduces F1Card by exactly 1. Analyze threshold sublattices of product lattices.\n\n**Domain Bridges:** Statistical physics (phase transitions, order parameters), condensed matter theory, percolation theory.\n\n**Lineage:** Extends F1Card from a static invariant to a dynamic observable.\n\n**Ambition:** Grand challenge \u2014 connecting \ud835\udd3d\u2081-combinatorics to physical phase transitions.\n\n---\n\n## Direction 3: Tropical Information Theory \u2014 F1-Entropy and Data Compression\n\n**Conjecture:** For a finite distributive lattice L representing a concept lattice or knowledge base, the \ud835\udd3d\u2081-cardinality F1Card(L) provides a lower bound on the number of bits needed to represent any element of L, and the Birkhoff representation gives an optimal encoding: represent each element by its indicator vector over the join-irreducibles.\n\n**The key insight is** that the base change theorem (Theorem 5) shows the join-irreducibles form a \"basis\" in a lattice-theoretic sense, and the Birkhoff representation gives a bijection between lattice elements and binary strings of length F1Card(L) \u2014 this is exactly the dictionary for a lossless compression scheme.\n\n**Why now?** The formalized generation and base change theorems provide the mathematical backbone for proving that F1Card is the correct \"dimension\" of the lattice for information-theoretic purposes, and that no encoding with fewer than F1Card(L) bits can be lossless.\n\n**Test:** For concept lattices arising from real datasets (e.g., UCI Machine Learning Repository), compute F1Card and compare with the actual encoding efficiency. Verify that the Birkhoff encoding achieves the information-theoretic optimum.\n\n**Impact:** Would establish a formal connection between \ud835\udd3d\u2081-geometry and information theory, providing new tools for data compression and knowledge representation.\n\n**Catalog References:** `TropF1.supBotHom_eq_of_eq_on_supIrred` (base change = unique decodability), `TropF1.sup_supIrred_eq` (generation = encoding covers all elements).\n\n**Proof Strategy:** Show that the Birkhoff map is an injection L \u2192 {0,1}^k where k = F1Card(L). Prove that any injection L \u2192 {0,1}^m requires m \u2265 F1Card(L) by a counting argument on the join-irreducible structure.\n\n**Domain Bridges:** Information theory (source coding, entropy), data science (formal concept analysis), machine learning (feature selection).\n\n**Lineage:** Extends Theorem 5 (base change) to an information-theoretic optimality result.\n\n**Ambition:** Solid extension \u2014 connects proven theorems to quantitative information theory.\n\n---\n\n## Direction 4: Motivic Zeta Functions from \ud835\udd3d\u2081-Skeletons\n\n**Conjecture:** For a finite distributive lattice L with \ud835\udd3d\u2081-skeleton J(L), define the \ud835\udd3d\u2081-zeta function:\n$$Z_{L,\\mathbb{F}_1}(s) = \\sum_{x \\in L} |J(x)|^{-s}$$\nwhere J(x) = {j \u2208 J(L) : j \u2264 x} is the Birkhoff image. This zeta function satisfies an Euler product over join-irreducibles and, for divisor lattices, recovers classical arithmetic zeta functions after appropriate base change.\n\n**The key insight is** that the Birkhoff representation converts the lattice sum into a sum over subsets of the \ud835\udd3d\u2081-points, and the multiplicative structure of join-irreducibles (in divisor lattices, these are prime powers) induces an Euler product factorization \u2014 connecting \ud835\udd3d\u2081-combinatorics directly to analytic number theory.\n\n**Why now?** The verified generation and base change theorems provide the tools to formally manipulate sums over lattice elements in terms of their join-irreducible decompositions. The Euler product structure can be proved using distributivity and the independence of join-irreducibles.\n\n**Test:** Compute Z_{L,\ud835\udd3d\u2081}(s) for divisor lattices of n = 6, 12, 30, 60, 2520 and verify the Euler product factorization. Compare with the classical Dirichlet series \u03a3_{d|n} d^{-s}.\n\n**Impact:** Would provide the first rigorous, formalized connection between \ud835\udd3d\u2081-geometry and zeta functions, contributing to the Connes\u2013Consani program of understanding the Riemann zeta function over \ud835\udd3d\u2081.\n\n**Catalog References:** `TropF1.sup_supIrred_eq` (generation = sum decomposition), `TropF1.F1Card_finset_eq_card` (counting formula).\n\n**Proof Strategy:** Prove the Euler product using the fact that in a finite distributive lattice, the Birkhoff map converts joins to unions, so the zeta sum factors as a product over independent join-irreducible contributions.\n\n**Domain Bridges:** Analytic number theory (zeta functions, Euler products), arithmetic geometry (motivic integration), algebraic K-theory.\n\n**Lineage:** Extends the \ud835\udd3d\u2081-cardinality invariant to a full zeta function.\n\n**Ambition:** Grand challenge \u2014 connecting finite \ud835\udd3d\u2081-combinatorics to the deep structures of arithmetic geometry.\n\n---\n\n## Direction 5: Tropical Combinatorial Optimization via \ud835\udd3d\u2081-Decomposition\n\n**Conjecture:** For optimization problems whose feasible regions form a finite distributive lattice (e.g., network flow polytopes, scheduling polytopes, submodular function minimization), the \ud835\udd3d\u2081-decomposition into join-irreducibles provides a canonical decomposition of the feasible region into independent \"atomic\" subproblems, enabling a divide-and-conquer algorithm whose complexity depends on F1Card rather than the full lattice size.\n\n**The key insight is** that the base change theorem guarantees any objective function that respects the lattice structure is determined by its values on F1Card many generators \u2014 reducing the search space from |L| to F1Card(L), which can be exponentially smaller (e.g., F1Card(B_n) = n vs |B_n| = 2^n).\n\n**Why now?** The generation theorem (Theorem 2) provides the correctness guarantee: decomposing an element into its join-irreducible components preserves all lattice-theoretic information. The base change theorem (Theorem 5) ensures that structure-preserving objectives can be evaluated on the reduced space.\n\n**Test:** Implement the \ud835\udd3d\u2081-decomposition algorithm for network flow lattices and compare with standard lattice optimization algorithms (e.g., submodular minimization via Lov\u00e1sz extension). Measure speedup as a function of |L| / F1Card(L).\n\n**Impact:** Would provide a new algorithmic paradigm for lattice optimization, with provable speedups for problems with low \ud835\udd3d\u2081-cardinality.\n\n**Catalog References:** `TropF1.sup_supIrred_eq` (decomposition), `TropF1.supBotHom_eq_of_eq_on_supIrred` (objective reduction), `TropF1.mem_supIrredFinset_iff` (algorithmic extraction).\n\n**Proof Strategy:** Prove that for sup-preserving objective functions, the optimal value on L equals the optimal combination of values on join-irreducibles. Analyze complexity of the reduced search.\n\n**Domain Bridges:** Combinatorial optimization (submodular optimization, network flows), operations research (scheduling), algorithm design (divide-and-conquer).\n\n**Lineage:** Extends the verified extraction algorithm to an optimization framework.\n\n**Ambition:** Solid extension \u2014 directly applicable to computational problems with measurable performance gains.\n",
    "domains": [
      "Pythagorean",
      "Algebra",
      "Geometry",
      "Computation",
      "Tropical",
      "Cryptography",
      "Bridges",
      "MachineLearning",
      "Logic"
    ],
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "prove",
    "source_exp_id": "cc98109f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-05-29T04:15:41.592512+00:00"
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
