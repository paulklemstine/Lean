# Future Directions: Symmetric Group Generation Probability

## Hypothesis 1: Exact Generation Probability for S_4 and S_5

**Conjecture:** The generation probability for S_4 is exactly 3/8 (with 216 generating pairs out of 576), and for S_5 is exactly 19/40 (with 6840 generating pairs out of 14400).

**Test:** Certify these values by extending the `native_decide`-based computational verification in the Lean formalization to n=4 and n=5. Cross-check with GAP's `StructureDescription` and Magma's subgroup enumeration. For n=4, this should be achievable with current `native_decide` infrastructure; for n=5 (with |S_5| = 120 and 14400 pairs), it may require optimized evaluation.

**Impact:** Establishes a certified database of exact generation probabilities, enabling pattern recognition for general formulas. The sequence p_1=1, p_2=3/4, p_3=1/2, p_4=3/8, p_5=19/40 suggests non-trivial structure worth formalizing.

## Hypothesis 2: Dixon-Style Certified Bound with Explicit Constant

**Conjecture:** There exists an explicit constant C ≤ 4 such that for all n ≥ 5,

$$\Pr[\langle \sigma, \tau \rangle \in \{A_n, S_n\}] \geq 1 - \frac{C}{n}.$$

More precisely, the probability that two random permutations fail to generate either A_n or S_n is bounded above by C/n, where C accounts for the dominant obstructions: intransitivity (which contributes approximately 1/n from point stabilizers) and containment in Young subgroups S_k × S_{n-k}.

**Test:** Formalize explicit subgroup-cover estimates sufficient to derive the bound. The key steps are:
1. Bound the probability of both permutations lying in a common point stabilizer: ≤ n · (1/n²) = 1/n.
2. Bound the probability of both preserving a non-trivial block system: ≤ Σ_{k=1}^{⌊n/2⌋} C(n,k) · (k!(n-k)!/n!)².
3. Sum all obstruction contributions and verify C ≤ 4 for n ≥ 5.

**Impact:** Would be the first fully formalized version of Dixon's 1969 theorem, closing a 55-year gap between the classical result and machine-verified mathematics.

## Hypothesis 3: Point-Stabilizer Dominance Among Intransitive Obstructions

**Conjecture:** Among all intransitive maximal subgroups of S_n (which are conjugates of S_k × S_{n-k} for 1 ≤ k < n), point stabilizers (k=1, giving S_1 × S_{n-1} ≅ S_{n-1}) contribute the asymptotically largest fraction to the non-generation probability. Specifically:

$$\frac{n \cdot ((n-1)!/n!)^2}{\sum_{k=1}^{\lfloor n/2 \rfloor} \binom{n}{k} \cdot (k!(n-k)!/n!)^2} \to 1 \text{ as } n \to \infty.$$

**Test:** Compute the ratio for n = 5, 10, 20, 50, 100 and verify convergence. Then formalize the asymptotic argument showing that contributions from k ≥ 2 decay super-exponentially relative to k=1.

**Impact:** Identifies the critical obstruction for generation probability, suggesting that the simplest combinatorial argument (counting pairs that share a fixed point) captures almost all of the non-trivial obstruction beyond parity. This would simplify the formal proof of Dixon's theorem.

## Hypothesis 4: Average-Case Schreier-Sims Complexity

**Conjecture:** When the Schreier-Sims algorithm is run with two random generators of S_n (conditioned on the pair generating S_n), the expected number of Schreier generator computations is O(n² log n), compared to the worst-case O(n⁵) for arbitrary generators. More precisely, the expected stabilizer chain length is exactly n-1, and each level requires O(n) Schreier generators with high probability.

**Test:** Implement the Schreier-Sims algorithm and measure the number of operations for random generating pairs at n = 10, 20, 50, 100, 200. Fit the data to n^α (log n)^β and verify α ≈ 2, β ≈ 1. Correlate with the certified generation probabilities to weight the average.

**Impact:** Would establish a formal connection between algebraic generation theory and computational complexity, showing that the "typical" case for permutation group algorithms is dramatically faster than the worst case.

## Hypothesis 5: Circuit Complexity of the Generation Predicate

**Conjecture:** The Boolean predicate "two permutations σ, τ ∈ S_n, encoded as sequences of n elements from {0,...,n-1}, generate a transitive subgroup" can be computed by algebraic circuits of degree O(n²), while the full predicate "generate S_n" requires degree Ω(n²). However, the "contains an odd permutation" predicate (parity check) requires only degree O(n) circuits.

**Test:** For small n (n = 3, 4, 5), encode the predicates as multilinear polynomials over GF(2) and measure their exact degree. Compare with the theoretical bounds. Use the catalog's `degreeBound_le_two_pow_depth` framework to certify upper bounds on circuit complexity.

**Impact:** Creates a bridge between probabilistic group theory and algebraic circuit complexity. The generation predicate becomes a natural benchmark function whose complexity is directly connected to the subgroup structure of S_n, opening a new direction in certified average-case complexity theory.
