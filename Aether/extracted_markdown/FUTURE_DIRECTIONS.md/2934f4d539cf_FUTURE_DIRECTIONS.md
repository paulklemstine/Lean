# Future Directions: Communication Bottleneck Detection for Automated Lemma Discovery

## Synthesis

The communication bottleneck framework established in this work reveals a deep connection between the information-theoretic content of algebraic identity families and the complexity of their proofs. The key insight — that the coefficient space dimension governs the communication floor for structure-blind verification — opens multiple avenues for extension, from tropical information theory to neural lemma discovery. Each direction below builds on specific verified theorems from the current catalog and proposes concrete, falsifiable tests. The grand challenge directions (H1, H2) aim to establish tropical information theory as the natural language for proof compression, while the extensions (H3, H4, H5) develop practical tools and broaden the framework's scope.

---

## Direction 1: Tropical Mutual Information and Proof Compression Ratios

**Conjecture:** The tropical mutual information $I_{\text{trop}}(X; Y)$ between the LHS and RHS coefficient distributions of an identity family equals $H_{\text{trop}}(X) - H_{\text{trop}}(X|Y)$, and this quantity equals the logarithm of the compression ratio achievable by optimal lemma factoring. Specifically, for the powerset family, $I_{\text{trop}} = n \log 2$, matching the exponential compression ratio $2^n / (n+1)$.

**Test:**
1. Define tropical entropy $H_{\text{trop}}(X) = \min_x (-p(x) \cdot \log p(x))$ for 5 identity families: powerset, telescoping, Pythagorean, Vandermonde, and Newton's identity.
2. Compute $I_{\text{trop}}$ as $H_{\text{trop}}(\text{LHS coefficients}) - H_{\text{trop}}(\text{LHS} | \text{RHS})$.
3. Compare $2^{I_{\text{trop}}}$ to the known optimal compression ratio $\text{autoCost}/\text{factoredCost}$.
4. **Refutation:** If for any family $|2^{I_{\text{trop}}} - \text{compression ratio}| > C \cdot n$ for all constants $C$, the conjecture is false.

**Impact:** Would establish tropical information theory as the natural framework for proof compression, yielding constructive bounds on lemma discovery.

**Catalog References:**
- `Pythagorean/Defs.lean`: `commBottleneck`, `tropicalMul`, `tropicalAdd`
- `Pythagorean/Theorems.lean`: `tropical_chain_identity`, `monotone_coeffDim_unbounded_bottleneck`
- `Catalog/MachineLearning/ProofCompression/Defs.lean`: `CompressionInstance`, `compressionRatio`

**Proof Strategy:** Use `tropical_chain_identity` as the base algebraic law. Define tropical conditional entropy via the min-plus analogue of conditional expectation. The key step is showing that $H_{\text{trop}}(X|Y) = \min_{y \in \text{supp}(Y)} H_{\text{trop}}(X|Y=y)$, which follows from the tropical semiring laws.

**Domain Bridges:** Information theory → tropical geometry → proof complexity

**Lineage:** Extends `tropical_chain_identity` from algebraic identity to information-theoretic statement.

**Ambition:** Grand challenge — would create a new subfield of tropical information theory for proofs.

---

## Direction 2: Representation-Theoretic Bottlenecks via Young Tableaux

**Conjecture:** For the family of character identities arising from the symmetric group $S_n$ — specifically, the decomposition of the regular representation into irreducibles — the communication bottleneck equals the number of standard Young tableaux of the relevant shape. The optimal lemma count for verifying the character table identity at level $n$ equals $\sum_{\lambda \vdash n} f^\lambda$, where $f^\lambda$ is the number of standard Young tableaux of shape $\lambda$.

**Test:**
1. For $n = 3, 4, 5$, compute the character table of $S_n$ and its coefficient dimension.
2. Compute $\sum_\lambda f^\lambda$ using the hook length formula.
3. Run `bottleneckDetector` on the character identity family.
4. Compare the detector's `lemmaCount` to $\lceil \log_2(\sum_\lambda f^\lambda) \rceil$.
5. **Refutation:** If `lemmaCount` differs from the Young tableaux count by more than a factor of 2 for any $n \leq 5$.

**Impact:** Would connect the RSK correspondence to proof compression, revealing that the combinatorial structure of representation theory *is* the information structure of its proofs.

**Catalog References:**
- `Pythagorean/Defs.lean`: `IdentityFamily`, `bottleneckDetector`
- `Pythagorean/Theorems.lean`: `bottleneckDetector_powerset_lemmaCount`

**Proof Strategy:** Define the character identity family with `coeffDim n = |character table| = (number of conjugacy classes)^2`. Use the Murnaghan-Nakayama rule to express coefficients in terms of border-strip tableaux. The RSK correspondence provides the bijection between the coefficient space and Young tableaux that reveals the communication structure.

**Domain Bridges:** Representation theory → combinatorics → communication complexity → proof automation

**Lineage:** Extends `IdentityFamily` to non-polynomial settings.

**Ambition:** Grand challenge — would unify representation theory with proof complexity.

---

## Direction 3: Tight 2-Approximation for the Bottleneck Detector

**Conjecture:** The bottleneck detector's lemma count $\lfloor \log_2(\text{coeffDim}(n)) \rfloor$ is within a factor of 2 of the optimal lemma count for all identity families over fields of characteristic zero. Formally: if $\text{opt}(F, n)$ is the minimum number of lemmas to reduce proof cost to $O(n)$, then $\frac{1}{2} \lfloor \log_2(\text{coeffDim}(n)) \rfloor \leq \text{opt}(F, n) \leq 2 \lfloor \log_2(\text{coeffDim}(n)) \rfloor$.

**Test:**
1. Exhaustive search over polynomial identity families of degree $\leq 4$ in $\leq 4$ variables for $n \leq 8$.
2. For each family, compute `bottleneckDetector` output and the true optimal via brute-force subexpression extraction.
3. Verify the 2-approximation ratio.
4. **Refutation:** Find a family where the ratio exceeds 2.

**Impact:** Would elevate the bottleneck detector from a heuristic to a provably good algorithm.

**Catalog References:**
- `Pythagorean/Theorems.lean`: `bottleneckDetector_lemmaCount_le`, `conjecture_powerset_test`
- `Catalog/MachineLearning/ProofCompression/Theorems.lean`: `gap_of_linear_vs_exponential`

**Proof Strategy:** Lower bound: each lemma can reduce the effective coefficient dimension by at most a factor of 2 (halving the rank of the coefficient matrix), so $\text{opt} \geq \log_2(\text{coeffDim}/\text{factoredCost})$. Upper bound: the greedy subexpression extraction algorithm (extract the largest common subexpression at each step) achieves factor-2 compression per lemma.

**Domain Bridges:** Algorithm approximation theory → proof complexity → linear algebra

**Lineage:** Directly extends `bottleneckDetector_lemmaCount_le` and `conjecture_powerset_test`.

**Ambition:** Solid extension — provable approximation guarantee for a practical algorithm.

---

## Direction 4: Multivariate Polynomial Identity Testing via Communication Protocols

**Conjecture:** For any identity family $F$ with $\text{coeffDim}(n) \leq \text{autoCost}(n)$, the randomized communication complexity of verifying the identity is $\Theta(\log(\text{coeffDim}(n)))$, and this can be achieved by a protocol that samples a random evaluation point and checks identity at that point (Schwartz-Zippel style).

**Test:**
1. Implement Schwartz-Zippel verification for the powerset, telescoping, and Pythagorean families.
2. Measure the empirical communication cost (number of bits exchanged) vs. $\log_2(\text{coeffDim})$.
3. For $n = 1, \ldots, 20$, verify that the ratio is between 0.5 and 2.
4. **Refutation:** If the empirical communication exceeds $3 \log_2(\text{coeffDim})$ for any family and $n$.

**Impact:** Would connect the bottleneck framework to polynomial identity testing, a major area of theoretical computer science.

**Catalog References:**
- `Pythagorean/Defs.lean`: `IdentityFamily`, `HasExponentialCoeffDim`
- `Pythagorean/Theorems.lean`: `exponential_gap_from_coeff_dim`

**Proof Strategy:** Upper bound: Schwartz-Zippel lemma says evaluating a degree-$d$ polynomial at a random point from a field of size $> 2d$ gives a correct test with probability $\geq 1/2$. The communication is $O(\log |F|) = O(\log(\text{coeffDim}))$. Lower bound: reduction from set disjointness.

**Domain Bridges:** Polynomial identity testing → communication complexity → proof automation

**Lineage:** Extends `exponential_gap_from_coeff_dim` from deterministic to randomized setting.

**Ambition:** Solid extension — connects to a well-studied area with known techniques.

---

## Direction 5: Neural Lemma Prediction via Coefficient Matrix Embeddings

**Conjecture:** A neural network trained on coefficient matrix embeddings (SVD-based) can predict the optimal lemma factorization for unseen identity families with accuracy $> 80\%$ on lemma count and $> 60\%$ on lemma content (measured by cosine similarity of coefficient vectors).

**Test:**
1. Generate 10,000 random polynomial identity families of varying degree and dimension.
2. Compute the SVD of each coefficient matrix and the optimal factorization (by brute-force for small instances).
3. Train a graph neural network on the SVD features to predict lemma count and lemma coefficient vectors.
4. Evaluate on a held-out set of 2,000 families.
5. **Refutation:** If accuracy is below 50% on either metric after hyperparameter tuning.

**Impact:** Would provide the first empirical validation that information-theoretic features (SVD of coefficient matrices) are predictive of proof structure — a concrete step toward "communication-aware" theorem provers.

**Catalog References:**
- `Pythagorean/Defs.lean`: `IdentityFamily`, `BottleneckReport`
- `Pythagorean/Theorems.lean`: `powersetFamily_has_gap`, `pythagoreanFamily_has_gap`
- `Catalog/MachineLearning/ProofCompression/Defs.lean`: `CompressionInstance`

**Proof Strategy:** Not a formal proof direction — this is an empirical validation. The theoretical foundation is the connection between SVD rank and optimal lemma count established in the bottleneck framework.

**Domain Bridges:** Machine learning → linear algebra → proof automation

**Lineage:** Extends the bottleneck detector from exact computation to learned prediction.

**Ambition:** Solid extension with high practical impact — directly applicable to neural theorem provers.
