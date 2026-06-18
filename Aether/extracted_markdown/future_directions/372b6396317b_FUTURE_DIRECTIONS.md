# Future Directions: Counterfactual Number Theory

## Synthesis

This research cycle discovered the **Factorization Diamond** — the surprising result that three natural conditions weakening unique factorization (product-freeness, collision-freeness, and their conjunction) form a strict diamond lattice, where no two are comparable and even their conjunction fails to imply unique factorization. The key mathematical insight is that factorization uniqueness requires controlling obstructions at *all depths* (k-fold products for every k), not just pairwise interactions.

The Coprime Basis Theorem provides a positive counterpart: for pairwise coprime sets, product-freeness alone suffices for unique factorization. This suggests that the "excess structure" of primes beyond density — specifically their pairwise coprimality — is the mechanism through which the pairwise condition (product-freeness) bootstraps to full unique factorization. The connection to the existing `Catalog/Cryptography/ProductCollisions.lean` collision hierarchy is direct: our diamond completes the picture left open by that earlier work, which established the collision-free/product-free separation but not the collision-free vs UF separation.

The most promising cross-domain connection is to **algebraic number theory**, where the failure of unique factorization in certain number rings (like ℤ[√-5]) motivated the entire theory of ideals and class groups. The Factorization Diamond could provide a new lens for measuring *how badly* unique factorization fails — not just whether it fails, but which diamond conditions survive. This connects directly to the existing `Catalog/Algebra/ChimeraFactoring.lean` (semiprime factorization) work.

---

### Direction 1: Collision Spectrum Characterization of Unique Factorization

**Conjecture**: A set S ⊆ ℕ≥2 has unique S-factorization if and only if (1) S is k-product-free for all k ≥ 2 (no k-fold product of elements of S lies in S), AND (2) every pair of multisets of elements of S with the same product are equal (universal collision-freeness, not just pairwise).

More precisely, define the *collision spectrum* CS(S, k) as the set of numbers n admitting two distinct S-factorizations of length exactly k. Define the *cross-depth spectrum* XD(S) as the set of numbers n admitting two S-factorizations of different lengths. The conjecture is: HasUF(S) ↔ (CS(S,k) = ∅ for all k) ∧ (XD(S) = ∅) ∧ (S is k-product-free for all k ≥ 2).

**Test**: Enumerate all subsets S ⊆ {2, ..., 30} of size ≤ 4 (there are ~27,000 such subsets). For each, compute UF by brute force (check factorizations of all n ≤ 1000) and verify the equivalence computationally. A single counterexample would disprove the conjecture.

**Impact**: If true, this gives a complete structural characterization of unique factorization in terms of finitely checkable conditions at each level. If false, the failure mode reveals new types of factorization obstructions beyond the three we've identified.

**Catalog References**: `Catalog/Cryptography/ProductCollisions.lean` (collision spectrum definition), `Catalog/Cryptography/CounterfactualPrimes.lean` (k-product-free hierarchy).

**Proof Strategy**: The forward direction (UF ⟹ conditions) should follow from the existing diamond theorem plus direct arguments. The reverse direction requires showing that if all three conditions hold, then any two factorizations f₁, f₂ of the same n must agree. A potential approach: use condition (1) to show f₁ and f₂ have the same length, then use condition (2) to show they agree. The challenge is that condition (1) only prevents elements of S from having factorizations, not arbitrary n.

**Domain Bridges**: Counterfactual Number Theory ↔ Algebraic Number Theory (class group structure measures failure of UF) ↔ Cryptography (factorization hardness depends on structural properties of the number being factored).

**Lineage**: Builds on the Factorization Diamond (this cycle) and the collision spectrum framework from `ProductCollisions.lean`.

**Ambition**: grand_challenge

---

### Direction 2: The Factorization Diamond in Algebraic Number Fields

**Conjecture**: The Factorization Diamond extends to the ring of integers 𝒪_K of a number field K. Specifically, define "S-factorization" using irreducible elements of 𝒪_K as the generator set. The Diamond conditions (PF, CF, UF) can be defined analogously, and the class number h(K) of K determines which diamond conditions hold:
- h(K) = 1 ↔ UF (Dedekind's theorem)
- h(K) ≤ 2 ↔ CF (conjecture: at most pairwise collisions occur)
- The relationship between h(K) and PF is unclear.

**Test**: Compute the diamond classification for the ring of integers of ℚ(√d) for d = -1, -2, -3, -5, -6, -7, -10, -11, -13, -14, -15. Compare with known class numbers. Check whether h(K) = 2 implies collision-freeness in the ring.

**Impact**: Would connect the combinatorial Factorization Diamond to the deep algebraic structure of class groups, potentially giving a new combinatorial interpretation of the class number.

**Catalog References**: `Catalog/Algebra/ChimeraFactoring.lean` (semiprime factorization), `Applications/CounterfactualPrimeTheory.lean` (this cycle's diamond theorem).

**Proof Strategy**: For quadratic fields, irreducible elements can be explicitly characterized. The key challenge is defining "collision" for ring elements (up to unit equivalence). Start with the Gaussian integers ℤ[i] (class number 1, should have UF) and ℤ[√-5] (class number 2, famously 6 = 2·3 = (1+√-5)(1-√-5)).

**Domain Bridges**: Counterfactual Number Theory ↔ Algebraic Number Theory ↔ Cryptography (ring-based cryptosystems).

**Lineage**: Builds on the Factorization Diamond (this cycle).

**Ambition**: grand_challenge

---

### Direction 3: Quantitative Factorization Width in Cramér Models

**Conjecture**: In a Cramér random model S (each n included with probability 1/ln n), the expected factorization width E[w_S(n)] grows as (ln n)^{c} for some constant c > 0. More precisely, for a "typical" n in [N/2, N], the number of distinct S-factorizations of n satisfies E[w_S(n)] ~ (ln N)^{α} where α is a computable constant.

**Test**: Simulate Cramér models for N = 10³, 10⁴, 10⁵. For each, sample 1000 values of n ∈ [N/2, N] and compute the average factorization width. Fit the growth rate to (ln N)^α and estimate α. Verify stability across multiple random seeds.

**Impact**: This would quantify exactly how badly unique factorization fails in random models — not just that it fails (which the diamond shows), but by how much. The exponent α would measure the "distance" between random sets and actual primes.

**Catalog References**: `Applications/CounterfactualPrimeTheory.lean` (factorization width definition and monotonicity).

**Proof Strategy**: Upper bound via counting argument: the number of S-factorizations of n is bounded by the number of ordered factorizations of n, which is 2^{Ω(n)} where Ω(n) counts prime factors with multiplicity. For random S, use second moment methods to estimate E[w_S(n)²] and hence Var[w_S(n)].

**Domain Bridges**: Counterfactual Number Theory ↔ Probability Theory (random multiplicative functions) ↔ Physics (partition function in statistical mechanics).

**Lineage**: Builds on factorization width definition from this cycle.

**Ambition**: extension

---

### Direction 4: Product-Free Sets of Maximal Density

**Conjecture**: The maximum density of a product-free subset of [2, N] is Θ(N / √(log N)). That is, there exist product-free subsets of [2, N] of size ≥ c · N / √(log N) for some constant c > 0, and no product-free subset has size exceeding C · N / √(log N) for some C > 0.

**Test**: For N = 100, 500, 1000, 5000, use greedy algorithms and backtracking search to find the largest product-free subsets of [2, N]. Plot the ratio |S_max| · √(log N) / N and check convergence.

**Impact**: This determines whether "prime-like density" (N/log N) is achievable by product-free sets. If the maximum density is Θ(N/√(log N)), then product-free sets can be much denser than primes, meaning product-freeness alone is a weak constraint — consistent with the Diamond Theorem showing PF ⊊ UF.

**Catalog References**: `Catalog/Cryptography/CounterfactualPrimes.lean` (product-free definition and basic properties).

**Proof Strategy**: Upper bound: use multiplicative energy estimates. If S ⊆ [2, N] has |S| = M, the number of multiplicative quadruples (a,b,c,d) with a·b = c·d grows as M⁴/N. For M ≫ √N, these quadruples exist, giving collisions. But product-freeness is a different constraint (it forbids a·b ∈ S, not a·b = c·d). A more delicate argument using the structure of product-free sets in multiplicative groups might be needed.

**Domain Bridges**: Counterfactual Number Theory ↔ Additive Combinatorics (sum-free sets are the additive analog) ↔ Extremal Graph Theory (Ramsey-type problems).

**Lineage**: Builds on product-free analysis from this cycle and the catalog.

**Ambition**: extension

---

### Direction 5: Tropical Factorization Diamond

**Conjecture**: The Factorization Diamond has a tropical analog. In the tropical semiring (ℝ ∪ {∞}, min, +), define "tropical factorization" of x as a multiset of tropical primes summing to x. The tropical analog of unique factorization, product-freeness, and collision-freeness should form the same diamond structure, but with different separating examples.

**Test**: Define tropical primes as elements of a set S ⊆ ℝ≥0 that is sum-free (no a + b = c with a, b, c ∈ S). Check whether the tropical diamond has the same structure as the multiplicative one, or whether the additive structure introduces additional constraints that collapse the diamond.

**Impact**: Would establish a "universal" phenomenon — the diamond is not specific to multiplicative number theory but arises from the general structure of factorization in monoids. This would connect to the existing tropical mathematics work in the catalog.

**Catalog References**: `Catalog/Tropical/` (tropical semiring infrastructure), `Catalog/Bridges/QuantumClassicalBridge.lean` (tropical density).

**Proof Strategy**: The key question is whether the additive structure of the tropical semiring makes the conditions more or less interrelated. In additive settings, "sum-free" sets are well-studied (the analog of product-free). The analog of collision-free would be: no a + b = c + d with {a,b} ≠ {c,d} — this is the Sidon set condition. The relationship between sum-free and Sidon sets is known to be incomparable, suggesting the diamond survives tropically.

**Domain Bridges**: Counterfactual Number Theory ↔ Tropical Geometry ↔ Additive Combinatorics (sum-free sets, Sidon sets).

**Lineage**: Builds on the Factorization Diamond (this cycle) and tropical infrastructure from the catalog.

**Ambition**: extension
