# Future Directions

## Synthesis

The formally verified separation between resolution and cutting planes on the pigeonhole principle opens a rich landscape of research directions connecting proof complexity, information theory, solver engineering, and combinatorial optimization. The key unifying theme is that **proof lower bounds are information bottleneck theorems**: when a proof system lacks the expressive power to aggregate global information efficiently, it must pay exponential cost. Our verified width lower bound, proof information invariant, and width-entropy profile provide the formal infrastructure to explore this theme across multiple domains.

The directions below range from near-term extensions of our verified results (formalizing the width-to-size conversion, extending to random formulas) to paradigm-shifting conjectures (entropy barriers characterizing proof complexity, universal prediction of solver hardness from information-theoretic profiles).

---

## Direction 1: Width-to-Size Conversion and Exponential Lower Bounds

**Conjecture**: The Ben-Sasson-Wigderson width-to-size theorem can be formalized in Lean 4, yielding a machine-verified exponential lower bound: min_res_size(PHP(n+1,n)) ≥ 2^{Ω(n)}.

**Test**: Attempt the formalization. The theorem states that for any CNF F with initial clause width w₀, if every resolution refutation requires width ≥ w, then every refutation has size ≥ 2^{(w-w₀)²/n}. A complete formalization with no sorry's would confirm feasibility; failure to close specific lemmas about clause-space counting would identify the gap.

**Impact**: This would be the first formally verified exponential proof complexity lower bound, establishing a new standard for certified impossibility results.

**Catalog References**: `Catalog/Computation/ProofComplexity/Resolution.lean` (ResTree.card_allClauses_le_size, ResTree.width_le_maxWidth_allClauses provide the structural foundation).

**Proof Strategy**: The argument requires: (1) showing that derivations of width ≤ w use at most |clause_space(w)| distinct clauses; (2) showing that "progress" toward the empty clause requires traversing many distinct clauses; (3) combining with the width lower bound. Our `allClauses` and `card_allClauses_le_size` results provide step (1).

**Domain Bridges**: Proof complexity → combinatorics (counting), information theory (clause space entropy).

**Lineage**: Extends php_width_lower_bound and ResTree.card_allClauses_le_size.

**Ambition**: High—would complete the full Haken-style lower bound with machine verification.

---

## Direction 2: Entropy Barrier Conjecture for General Resolution Lower Bounds

**Conjecture** (Grand Challenge): For every unsatisfiable CNF family F_n with bounded initial clause width, if the width-entropy profile WEP_{F_n} has a gap—i.e., WEP_{F_n}(w*) / WEP_{F_n}(2n) < 1/poly(n) for some w* < cn—then every resolution refutation of F_n has size at least 2^{Ω(w* - w₀)}.

In other words: a sharp transition in the width-entropy profile *implies* an exponential lower bound.

**Test**: (a) Compute WEP for PHP, random 3-SAT near threshold, Tseitin formulas, and ordering principle formulas for n = 5..15. (b) Verify that the profile gap correlates with known lower bounds. (c) Search for a counterexample family with a profile gap but polynomial-size refutation.

**Impact**: Would unify all known resolution lower bounds under a single information-theoretic framework, potentially yielding new lower bounds for families where the profile can be computed.

**Catalog References**: `Catalog/Computation/ProofComplexity/Resolution.lean` (WidthEntropyProfile, widthEntropyProfile_mono).

**Proof Strategy**: The approach would connect the profile gap to a compression argument: if few clauses are derivable at width w*, then any refutation must repeatedly "cross" the width barrier, each crossing requiring fresh clauses at width > w*.

**Domain Bridges**: Proof complexity → information theory (entropy), statistical physics (phase transitions), SAT solving (clause learning dynamics).

**Lineage**: Builds on WidthEntropyProfile and php_widthEntropy_barrier.

**Ambition**: Paradigm-shifting—would transform proof complexity lower bounds into entropy computations.

---

## Direction 3: Proof Information Predicts CDCL Solver Runtime

**Conjecture**: For structured unsatisfiable CNF families, the minimum proof information content (as defined by our invariant) correlates with the median runtime of CDCL solvers, up to polynomial factors. Specifically, for PHP(n+1,n), the runtime of a CDCL solver restricted to learned clause width ≤ w scales as 2^{Ω(n-w)} for w < n and poly(n) for w ≥ n.

**Test**: Run MiniSat, CaDiCaL, and Kissat on PHP instances for n = 3..12, with and without clause-width restrictions. Record:
- median runtime and variance across random seeds,
- distribution of learned clause widths,
- total number of learned clauses,
- proof size (if available from DRAT proof logging).

Compare empirical runtime to n - w_max predicted from the width lower bound.

**Impact**: Would provide a practical hardness prediction tool for SAT instances, grounded in formally verified theory.

**Catalog References**: `Catalog/Computation/ProofComplexity/Resolution.lean` (php_proofInformation_lower_bound, php_width_lower_bound).

**Proof Strategy**: The key argument is that CDCL essentially implements tree-like resolution with restarts. Width-restricted CDCL can only learn narrow clauses, which (by the width lower bound) cannot reach the contradiction. The runtime scales with the number of states explored before the solver "gives up" on narrow clauses.

**Domain Bridges**: Proof complexity → SAT solving (CDCL dynamics), experimental computer science (benchmarking).

**Lineage**: Extends php_proofInformation_lower_bound to operational predictions.

**Ambition**: Medium-high—testable with existing tools, significant if confirmed.

---

## Direction 4: Cutting Planes Hierarchy and Pseudo-Boolean Solver Characterization

**Conjecture**: For the PHP family, the cutting-planes refutation rank (number of rounds of the Sherali-Adams or CP hierarchy needed) is exactly 1. More broadly, any unsatisfiable CNF encoding a counting contradiction (pigeonhole, matching, flow) has CP rank ≤ O(1), while any unsatisfiable CNF encoding a parity contradiction has CP rank Ω(n).

**Test**: (a) Formalize the explicit 2-step CP refutation of PHP in Lean, with step-by-step arithmetic verification. (b) Implement a CP rank calculator in Python for small instances. (c) Test the rank prediction on Tseitin formulas (parity-based, expected high rank) and matching formulas (counting-based, expected low rank).

**Impact**: Would characterize exactly which problem types benefit from pseudo-Boolean reasoning, guiding solver selection.

**Catalog References**: `Catalog/Computation/ProofComplexity/Resolution.lean` (CPDerives, cp_sound, php_has_cp_refutation).

**Proof Strategy**: For the PHP rank-1 claim: the pigeon and hole constraints can each be summed in one round, giving the contradiction. For the parity lower bound: use the known result that CP requires Ω(n) rounds for Tseitin formulas over expander graphs.

**Domain Bridges**: Proof complexity → integer programming (LP hierarchies), optimization (pseudo-Boolean solvers), combinatorics (graph expansion).

**Lineage**: Extends cutting_planes_separates_resolution_on_php.

**Ambition**: Medium—the PHP rank bound is straightforward; the general characterization is ambitious.

---

## Direction 5: Universal Proof Complexity Landscape via Width-Entropy Profiles

**Conjecture** (Grand Challenge): Every polynomial-time decidable property of unsatisfiable CNF families (e.g., "has polynomial-size resolution refutation," "has polynomial-size CP refutation," "is hard for CDCL") can be characterized by a computable functional of the width-entropy profile.

In other words: the WEP is a *sufficient statistic* for proof complexity.

**Test**: (a) Compute WEPs for 5 canonical formula families (PHP, random 3-SAT, Tseitin, ordering principle, graph coloring). (b) Train a simple classifier (logistic regression or decision tree) on WEP features to predict resolution proof size. (c) Evaluate prediction accuracy on held-out instances. A counterexample would be a family where two formulas have identical WEPs but different proof complexities.

**Impact**: Would provide a unifying framework reducing all proof complexity questions to profile computations, analogous to how spectral graph theory reduces graph properties to eigenvalue computations.

**Catalog References**: `Catalog/Computation/ProofComplexity/Resolution.lean` (WidthEntropyProfile, widthEntropyProfile_mono).

**Proof Strategy**: Begin by showing WEP determines width, then use width-to-size conversion. For the full characterization, connect WEP to the Karchmer-Wigderson communication game for the search problem.

**Domain Bridges**: Proof complexity → machine learning (feature engineering), information theory (sufficient statistics), communication complexity (KW games).

**Lineage**: Builds on all results in this development.

**Ambition**: Paradigm-shifting—would transform proof complexity from a collection of ad-hoc techniques to a unified information-theoretic science.
