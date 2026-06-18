# Future Directions: Lorentzian Minor Closure Theory

## Synthesis

The Lorentzian Minor Closure Theory establishes that the support sets of Brändén–Huh Lorentzian polynomials form a minor-closed combinatorial species under deletion and contraction. This places Lorentzian supports alongside matroids and delta-matroids as objects admitting structural decomposition via forbidden minors. The five directions below exploit this new structural backbone: two are paradigm-shifting conjectures (forbidden minor classification and tropical Lorentzian duality), while three are concrete extensions building on the proved deletion/contraction closure theorems. Together, they outline a program to transform Lorentzian polynomial theory from an analytic tool into a combinatorial theory with algorithmic, geometric, and probabilistic applications.

---

## Direction 1: Forbidden Minor Classification for Lorentzian Supports

**Conjecture:** For each fixed number of variables $n$ and degree $d$, the class of Lorentzian-realizable supports on $n$ variables at degree $d$ is characterized by a finite set of forbidden minors. Moreover, the number of forbidden minors grows polynomially in $n$ for fixed $d$.

**The key insight is** that minor closure, once established, automatically invokes the well-quasi-ordering framework: if the minor relation on supports is a well-quasi-order (which follows from the finite number of variables and bounded degree), then every minor-closed class has finitely many forbidden minors.

**Why now?** The deletion and contraction closure theorems proved in `Catalog/Pythagorean/LorentzianMinorClosure.lean` provide the first rigorous foundation. Previously, only exchange closure was known (`Catalog/Pythagorean/SupportMinorTheory.lean`), which is weaker.

**Test:** Enumerate all supports on 3 variables at degree 3. For each, test Lorentzian realizability via the Hessian eigenvalue condition. Identify minimal non-realizable supports that are exchange-satisfying but not Lorentzian. These are candidate forbidden minors.

**Impact:** A finite forbidden minor characterization would make Lorentzian support recognition a polynomial-time problem (by fixed-parameter tractability), analogous to planarity testing.

**Catalog References:** `LorentzianMinorClosure.lean` (minor closure), `SupportMinorTheory.lean` (exchange closure), `LorentzianRecognitionComplete.lean` (Hessian recognition)

**Proof Strategy:** Show that the minor order on homogeneous supports of bounded degree embeds into a well-quasi-order. Use Nash-Williams's tree theorem or Kruskal's theorem as the backbone.

**Domain Bridges:** Graph theory (Robertson-Seymour), matroid theory (Geelen-Gerards-Whittle), algorithmic complexity (fixed-parameter tractability)

**Lineage:** Extends `exchange_of_minor` and `lorentzian_delete`

**Ambition:** Grand challenge — would open a new subfield of structural Lorentzian combinatorics

---

## Direction 2: Positive Realization Conjecture — Full Proof

**Conjecture:** Every minor of a positively Lorentzian-realizable support is itself positively Lorentzian-realizable. That is, strict positivity of coefficients is preserved through all minor operations.

**The key insight is** that positive coefficients form an open condition in coefficient space, and Lorentzianity is a closed condition. Their intersection is relatively open in the Lorentzian cone, suggesting that perturbation arguments can maintain positivity through minor operations.

**Why now?** The contraction theorem (`lorentzian_contract`) proves realizability but doesn't guarantee positivity of the witness. The missing piece is a support-exactness argument showing that iterated derivatives + restriction produce a polynomial with support *exactly* equal to the contraction (not a subset).

**Test:** For $e_k(x_1,\ldots,x_n)$ with $n \leq 7$, $k \leq 4$: compute all minors, attempt positive Lorentzian realization via semidefinite programming. Record any failure as a candidate counterexample.

**Impact:** Would provide the definitive inductive invariant for minor closure arguments, enabling clean inductive proofs of further structural properties.

**Catalog References:** `LorentzianMinorClosure.lean` (Theorems 1-4), `LorentzianRecognitionComplete.lean` (Lorentzian definition)

**Proof Strategy:** Use openness of the strict Lorentzian cone in coefficient space. For a positive witness $f$, the derivative $\partial_i f$ has coefficients that are products of original coefficients with positive integers. Show the support doesn't collapse by a dimension argument on the coefficient variety.

**Domain Bridges:** Real algebraic geometry (semialgebraic sets), optimization (SDP feasibility), probability (negative dependence)

**Lineage:** Direct extension of `lorentzian_contract` and `lorentzian_iterate_pderiv`

**Ambition:** Solid extension — high-confidence achievable with current tools

---

## Direction 3: Tropical Lorentzian Duality

**Conjecture:** The tropicalization of the Lorentzian cone defines a "tropical Lorentzian support" class that is dual to the algebraic class via the valuation map. Minor closure in the algebraic setting corresponds to a tropical minor operation, and the tropical forbidden minors are the valuated matroid analogs of the algebraic forbidden minors.

**The key insight is** that Lorentzian polynomials with positive coefficients have well-defined tropicalizations (taking $-\log$ of coefficients), and the Lorentzian conditions become tropical convexity conditions on the resulting valuated support.

**Why now?** The minor closure theory provides the structural backbone. Tropical geometry has mature tools for studying support-level polynomial properties, and the connection to valuated matroids (Dress-Wenzel) provides a natural landing point.

**Test:** For small examples, compute the tropical Lorentzian cone explicitly. Check whether tropical minors (induced by tropical deletion/contraction) match the algebraic minor structure.

**Impact:** Would create a new bridge between Hodge theory, tropical geometry, and combinatorial optimization. Tropical Lorentzian supports could provide polyhedral certificates for log-concavity.

**Catalog References:** `LorentzianMinorClosure.lean`, existing tropical theory in `Catalog/Tropical/`

**Proof Strategy:** Define tropical deletion/contraction via min-plus algebra. Show the tropicalization map commutes with minor operations. Use the structure theorem for valuated matroids.

**Domain Bridges:** Tropical geometry, valuated matroids, polyhedral combinatorics, auction theory (tropical optimization)

**Lineage:** Combines minor closure with tropical framework

**Ambition:** Grand challenge — paradigm-shifting if achieved

---

## Direction 4: Algorithmic Recognition via Minor Decomposition

**Conjecture:** Lorentzian support realizability can be decided in time $O(|S|^{O(d)})$ for supports of degree $d$, using a recursive minor decomposition that reduces to the degree-2 base case (eigenvalue computation).

**The key insight is** that minor closure enables a divide-and-conquer strategy: to test whether $S$ is Lorentzian-realizable, decompose via deletion/contraction into smaller supports, test each recursively, and combine. The degree-2 base case reduces to checking that a single matrix has at most one positive eigenvalue.

**Why now?** The minor closure theorems provide correctness guarantees for the decomposition. The Hessian recognition criterion from `LorentzianRecognitionComplete.lean` provides the base case.

**Test:** Implement the recursive recognizer. Benchmark against direct Hessian checking for supports of degree 3-5 on 4-8 variables. Measure speedup from early termination on non-realizable supports.

**Impact:** Would provide the first practical recognition algorithm for Lorentzian supports beyond degree 2.

**Catalog References:** `LorentzianRecognitionComplete.lean` (recognition criterion), `LorentzianMinorClosure.lean` (decomposition)

**Proof Strategy:** Formalize the recursive algorithm in Lean. Prove termination via the well-foundedness of the minor relation (support cardinality decreases). Prove correctness via the minor closure theorem.

**Domain Bridges:** Algorithm design, computational algebra, symbolic computation

**Lineage:** Builds on `lorentzian_delete`, `lorentzian_contract`, `hessian_zero_hasAtMostOnePos`

**Ambition:** Solid extension — directly actionable with current infrastructure

---

## Direction 5: Minor-Closed Negative Dependence for Sampling

**Conjecture:** For every positively Lorentzian-realizable support $S$ and every minor $T$ of $S$, the probability distribution defined by normalizing the positive Lorentzian coefficients on $T$ satisfies the *strong Rayleigh* property (all zeros of the generating polynomial are in the closed upper half-plane).

**The key insight is** that Lorentzian polynomials with positive coefficients define negatively dependent distributions, and the minor operations of deletion and contraction correspond exactly to the probabilistic operations of conditioning and marginalization. Minor closure of Lorentzianity therefore implies minor closure of negative dependence.

**Why now?** The Brändén-Borcea theory connects stable polynomials to negative dependence and fast sampling. Our minor closure theorem extends this connection to the iterated conditioning regime, which is exactly what Markov chain Monte Carlo algorithms need.

**Test:** Implement a Lorentzian-coefficient sampler for matroid basis distributions. Compare mixing times of MCMC chains with and without the minor-closure structural guarantee. Test on graphic matroids of increasing size.

**Impact:** Would provide new theoretical guarantees for approximate sampling from log-concave distributions, with applications to combinatorial optimization and statistical physics.

**Catalog References:** `LorentzianMinorClosure.lean` (minor closure), `LorentzianRecognitionComplete.lean` (reversed Cauchy-Schwarz)

**Proof Strategy:** Show that the normalized coefficient distribution of a Lorentzian polynomial satisfies the strong Rayleigh condition. Then use minor closure to propagate through conditioning steps. Connect to the Anari-Liu-Gharan-Vinzant framework for rapid mixing.

**Domain Bridges:** Probability theory, statistical physics (determinantal processes), machine learning (DPP sampling), combinatorial optimization

**Lineage:** Extends `lorentzian_contract` to probabilistic setting

**Ambition:** Solid extension with high impact — connects pure theory to practical algorithms
