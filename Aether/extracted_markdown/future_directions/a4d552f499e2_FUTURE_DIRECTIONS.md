# Future Directions: Directional Depth Theory

## Synthesis

This research cycle established directional depth as a viable mathematical invariant, proving its core structural properties (antitone filtration, product preservation, tropical bridge, exchange property) and demonstrating its connections to matroid theory and tropical geometry. The most significant finding was the **refutation of the phase transition conjecture**: random perturbations of geometric sequences break log-concavity almost surely, revealing that log-concavity is algebraically fragile in a way that constrains the theory's direct applicability to noisy data.

The strongest cross-domain connection is between depth theory and matroid exchange properties (Theorem `logConcave_exchange` in `Pythagorean/DirectionalDepthTheory.lean`). The exchange inequality `a(i)·a(j+1) ≤ a(i+1)·a(j)` is the foundational axiom for greedy optimality in combinatorial optimization. Our result provides a clean certification path: verify log-concavity (O(n) time), conclude exchange, conclude greedy optimality. This connects discrete curvature (depth theory) to algorithm design (matroid optimization) through a precisely verified bridge.

The highest breakthrough potential lies in **Direction 1** (higher-dimensional depth), which would connect to the full Lorentzian polynomial framework of Brändén-Huh and unlock applications to multivariate combinatorial objects (matroid basis counting, Hodge theory, chromatic polynomials). The tropical bridge theorem (`logConcave_tropical_bridge`) provides the necessary algebraic foundation for this extension.

---

### Direction 1: Higher-Dimensional Depth for Lattice Functions

**Conjecture**: For a function `f : ℤⁿ → ℝ₊`, define the **directional ratio transform** in direction `e_i` as `R_i(f)(x) = f(x + e_i) / f(x)`. Then `f` has *multivariate depth ≥ k* if it is log-concave in every direction and all directional ratio transforms have depth ≥ k-1. Conjecture: the coefficient function of a Lorentzian polynomial of degree d has multivariate depth ≥ d.

**Test**: Compute the multivariate depth of the coefficient function of `(x₁ + x₂ + x₃)^n` for n = 3, 4, 5. These are multinomial coefficients, known to be Lorentzian. Verify whether depth equals n.

**Impact**: If true, this establishes depth as the discrete shadow of the Lorentzian condition, providing a computable invariant for detecting Lorentzian-origin valuations among all valuated matroids. If false, the failure mode reveals which directional interactions break the filtration.

**Catalog References**: `Pythagorean/DirectionalDepthTheory.lean` (ratio transform definition, product theorem), `Catalog/Pythagorean/LorentzianExchangeCertificates.lean` (exchange property, ultra-log-concavity)

**Proof Strategy**: Define `MultivariateDepth` as an inductive predicate on `(Fin n → ℤ) → ℝ`. Prove that Lorentzian polynomials satisfy the base case using the Hessian contraction property. The key lemma is that directional ratio transforms of Lorentzian polynomials correspond to directional derivatives, which preserve the Lorentzian condition by Brändén-Huh.

**Domain Bridges**: Algebra <-> Tropical, Pythagorean <-> Algebra

**Lineage**: Builds on `geometric_infinite_depth`, `logConcave_tropical_bridge`, and `ratioTr_antitone` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Approximate Depth and Robust Log-Concavity

**Conjecture**: Define *ε-log-concavity* as `a(n+1)² ≥ (1-ε) · a(n) · a(n+2)`. Then for any ε > 0, the ε-depth (iterated ε-log-concavity under ratio transform) of a perturbed geometric sequence `rⁿ(1+δ_n)` with `|δ_n| < δ` satisfies ε-depth ≥ c · log(1/δ) for `ε ≥ C·δ` and universal constants c, C.

**Test**: Compute ε-depth for δ = 0.01 and ε = 0.1 on 200 random samples of length 20. Verify whether ε-depth ≥ 2 holds with probability > 0.8.

**Impact**: Resolves the fragility problem exposed by the refutation of the phase transition conjecture. A robust version of depth would make the theory applicable to statistical and signal processing contexts where exact algebraic conditions are never satisfied.

**Catalog References**: `Pythagorean/DirectionalDepthTheory.lean` (phase transition conjecture refutation), `Catalog/Pythagorean/LorentzianExchangeCertificates.lean` (exchange certificates)

**Proof Strategy**: Define `HasApproxDepth ε a k` with weakened inequality. Prove approximate versions of the product theorem and tropical bridge. The key new ingredient is an error propagation lemma: how does the ε parameter grow under ratio transforms?

**Domain Bridges**: Pythagorean <-> MachineLearning (robust curvature for ML applications)

**Lineage**: Directly extends the refuted `depthPhaseTransitionConjecture`.

**Ambition**: extension

---

### Direction 3: Depth of Matroid Basis Counting Sequences

**Conjecture**: For the uniform matroid U(r, n), the basis counting sequence `b(k) = C(n, r)` restricted to the `k`-th weight class has depth ≥ 1. More broadly, for any matroid M, the independent set counting sequence `f_M(k) = |{I ∈ I(M) : |I| = k}|` has depth ≥ 0 (log-concavity, following Mason's conjecture proved by Adiprasito-Huh-Katz) and conjecturally depth ≥ 1.

**Test**: Compute the depth of `f_M(k)` for all matroids on ≤ 8 elements (using the matroid database). Check whether depth ≥ 1 holds universally.

**Impact**: If true, this gives a structural explanation for why matroid sequences are "more than log-concave" — they have robust curvature at the ratio level. This would connect to the Hodge-Riemann relations in matroid theory.

**Catalog References**: `Catalog/Pythagorean/LorentzianExchangeCertificates.lean` (basis exchange from log-concavity), `Pythagorean/DirectionalDepthTheory.lean` (depth definition, product theorem)

**Proof Strategy**: Use the ultra-log-concavity of matroid basis counting sequences (proved by Brändén-Huh) to show that `C(n,k)/C(d,k)` is log-concave, which implies the ratio transform is also log-concave. Formalize in Lean using the `UltraLogConcave` predicate from `LorentzianExchangeCertificates.lean`.

**Domain Bridges**: Pythagorean <-> Algebra (matroid intersection theory)

**Lineage**: Builds on `logConcave_exchange`, `depth_product_min`, and `product_logConcave`.

**Ambition**: extension

---

### Direction 4: Categorical Depth Theory

**Conjecture**: The collection of positive sequences with depth ≥ k, together with "depth-preserving maps" (monotone transformations that don't decrease depth), forms a category `Depth_k`. The inclusions `Depth_{k+1} → Depth_k` are functorial, and the inverse limit `Depth_∞` is equivalent to the category of Pólya frequency sequences.

**Test**: Verify the categorical axioms (identity, composition) for depth-preserving maps in Lean. Check whether the product map `(a, b) ↦ a·b` is a monoidal structure on `Depth_k`.

**Impact**: A categorical formulation would provide the abstract framework for extending depth theory to new mathematical domains (sheaves, categories of representations) and connect to the categorical structures in the Catalog's `EML` and `Algebra` sections.

**Catalog References**: `Pythagorean/DirectionalDepthTheory.lean` (DepthFiltration structure), `Catalog/EML/CategoryTheorems.lean`, `Catalog/Bridges/TannakaClosureReconstruction.lean`

**Proof Strategy**: Define a `Category` instance on `DepthFiltration k` with morphisms as order-preserving maps that commute with the ratio transform. Prove the monoidal structure using `depth_product_min`. The key challenge is defining the correct morphism condition.

**Domain Bridges**: Pythagorean <-> EML (categorical structures), Pythagorean <-> Algebra (algebraic categories)

**Lineage**: Builds on `DepthFiltration`, `DepthFiltration.restrict`, `depth_product_min`.

**Ambition**: grand_challenge

---

### Direction 5: Tropical Depth and Valuated Matroid Classification

**Conjecture**: Through the tropical bridge (`logConcave_tropical_bridge`), the depth filtration on sequences induces a filtration on tropical Laurent series. A valuated matroid whose valuation function has tropical depth ≥ k has at most `O(n^{d-k})` extreme rays in its associated tropical linear space, where d is the rank.

**Test**: Compute the tropical depth and extreme ray count for the Fano matroid, the Petersen matroid, and all uniform matroids U(r, n) with n ≤ 8. Check the predicted bound.

**Impact**: This would connect depth theory to the combinatorial geometry of tropical linear spaces, providing a new tool for classifying valuated matroids. The bound on extreme rays would have implications for tropical optimization and phylogenetic tree estimation.

**Catalog References**: `Pythagorean/DirectionalDepthTheory.lean` (tropical bridge), `Catalog/Tropical/` (tropical semiring structures)

**Proof Strategy**: Use the tropical bridge to translate depth conditions to concavity conditions on the valuation function. Apply tropical Hodge theory to bound the dimension of the tropical linear space. Formalize the connection between concavity of valuations and face counts of tropical polytopes.

**Domain Bridges**: Pythagorean <-> Tropical (tropical linear spaces), Algebra <-> Tropical (valuated matroids)

**Lineage**: Builds on `logConcave_tropical_bridge`, `depth_tropical`.

**Ambition**: extension
