# Super-Exponential Compression Gaps in Determinant Expansion Families

## Abstract

We establish that determinant proof families exhibit a **super-exponential compression gap**: the ratio of brute-force (Leibniz expansion) proof cost to structured (Gaussian elimination) proof cost grows as n!/n², which exceeds any polynomial and any exponential function. We formalize a framework of *compression families* with dimension-dependent branching factors, prove that the determinant compression gap is unbounded, and connect this result to tropical algebra, where the determinant-permanent equivalence reveals the intrinsic factorial complexity. All main theorems are verified in the Lean 4 proof assistant with the Mathlib library. We provide explicit computable bounds, algorithms for computing phase transition thresholds, and connections to algebraic complexity theory (VP vs VNP).

**Keywords**: proof complexity, compression gap, factorial growth, determinant, permanent, tropical geometry, algebraic complexity, phase transition

---

## 1. Introduction

### 1.1 Motivation

The determinant of an n×n matrix admits two classical computation strategies with dramatically different costs:

1. **Gaussian elimination**: O(n³) arithmetic operations, producing a proof of O(n²) logical steps.
2. **Leibniz expansion**: n! terms, each requiring O(n) multiplications, for a total of O(n · n!) proof steps.

This disparity is well-known in numerical linear algebra, but its implications for *proof complexity* — the study of how proof size relates to theorem complexity — have not been systematically formalized. We address this gap by introducing a framework of **compression families** that captures the essential structure of this phenomenon.

### 1.2 Contributions

1. **Factorial dominance theorem** (Theorem 1): For any fixed polynomial n^k and any constant C, there exists N such that n! ≥ C · n^k for all n ≥ N. This is the arithmetic engine powering all subsequent results.

2. **Super-exponential compression gap** (Theorem 2): The ratio n!/n² exceeds any constant for sufficiently large n, establishing that the determinant compression gap is not merely large but *unbounded*.

3. **Factorially incompressible families** (Theorem 3): Within our compression family framework, determinant families are factorially incompressible — no polynomial-cost proof strategy can match the Leibniz expansion for all dimensions.

4. **Tropical determinant-permanent equality** (Theorem 4): In tropical (min-plus) algebra, the determinant equals the permanent, connecting our compression gap to the #P-hardness of the permanent and explaining why the factorial cost is intrinsic.

5. **Verified algorithms**: Computable functions for threshold computation with formal correctness guarantees.

### 1.3 Related Work

**Proof complexity**: The study of proof length in various proof systems (resolution, Frege systems, extended Frege) has a rich history. Our work contributes a new perspective by measuring *compression ratios* rather than absolute proof lengths. The compression gap quantifies the value of mathematical insight.

**Algebraic complexity**: The VP vs VNP question, introduced by Valiant (1979), asks whether the permanent can be computed by polynomial-size arithmetic circuits. Our compression gap provides a proof-theoretic reflection of this algebraic complexity barrier.

**Tropical geometry**: The connection between tropical determinants and permanents is folklore in tropical mathematics (see Maclagan & Sturmfels, 2015). We formalize this connection and use it to explain the intrinsic factorial cost.

---

## 2. Definitions and Notation

### 2.1 Compression Families

**Definition 2.1** (Compression Family). A *compression family* is a tuple F = (S, H, A, B, β) where:
- S : ℕ → ℕ is the *semantic complexity* (what the proof is about)
- H : ℕ → ℕ is the *human proof cost* (structured strategy)
- A : ℕ → ℕ is the *automated proof cost* (brute-force expansion)
- B : ℕ → ℕ is the *branching factor* at each dimension
- β : ∀ n ≥ 2, B(n) ≥ 2 (nontrivial branching)

**Definition 2.2** (Compression Gap). The *compression gap* of F at dimension n is:
$$\text{gap}_F(n) = \begin{cases} A(n) / H(n) & \text{if } H(n) > 0 \\ 0 & \text{otherwise} \end{cases}$$

**Definition 2.3** (Factorial Incompressibility). A compression family F is *factorially incompressible* if for every constant C > 0, there exists N such that gap_F(n) > C for all n ≥ N.

### 2.2 Determinant Compression Instance

The *determinant compression instance* is the compression family:
- S(n) = n (matrix dimension)
- H(n) = n² (Gaussian elimination proof steps)
- A(n) = n! (Leibniz expansion terms)
- B(n) = n (cofactor expansion branches n ways)

The compression gap is gap(n) = n!/n².

### 2.3 Tropical Algebra

The *tropical semiring* (ℤ, ⊕, ⊗) has:
- a ⊕ b = min(a, b)
- a ⊗ b = a + b

The *tropical determinant* of an n×n matrix M is:
$$\text{tdet}(M) = \bigoplus_{\sigma \in S_n} \bigotimes_{i=1}^{n} M_{i,\sigma(i)} = \min_{\sigma \in S_n} \sum_{i=1}^{n} M_{i,\sigma(i)}$$

The *tropical permanent* is defined identically (signs vanish in min-plus):
$$\text{tperm}(M) = \min_{\sigma \in S_n} \sum_{i=1}^{n} M_{i,\sigma(i)}$$

---

## 3. Main Results

### 3.1 Factorial Dominates Every Polynomial

**Theorem 3.1** (Factorial Dominance). *For every k ∈ ℕ and every C ∈ ℕ, there exists N ∈ ℕ such that n! ≥ C · n^k for all n ≥ N.*

**Proof sketch.** By induction on C.

*Base case* (C = 0): Trivial, as n! ≥ 0 for all n.

*Inductive step*: Assume there exists N₀ such that n! ≥ C · n^k for all n ≥ N₀. We need n! ≥ (C+1) · n^k. The key is establishing that n! ≥ n^(k+1) for sufficiently large n.

To show n! ≥ n^(k+1), we use the fact that 2^n / n^(k+1) → ∞ (exponential dominates polynomial) combined with n! ≥ 2^n for n ≥ 4 (which follows from the fact that the first n/2 factors of n! are each ≥ 2).

More precisely, the proof proceeds via the real-analysis route: Real.tendsto_exp_div_pow_atTop shows that exp(x)/x^m → ∞ for any m. Composing with n ↦ n · log 2 gives 2^n / n^(k+1) → ∞, and then n! ≥ 2^n (for large n) gives n! / n^(k+1) → ∞.

With n! ≥ n^(k+1) for n ≥ N₁, we get for n ≥ max(N₀, N₁) + C + 1:
$$n! ≥ C · n^k + n^{k+1} ≥ C · n^k + n^k = (C+1) · n^k$$

where the last inequality uses n ≥ 1. ∎

### 3.2 Super-Exponential Compression Gap

**Theorem 3.2** (Super-Exponential Gap). *For every C ∈ ℕ, there exists N ∈ ℕ such that n!/n² > C for all n ≥ N (as rationals).*

**Proof sketch.** We show that N = C + 4 suffices. For n = C + 4:

$$\frac{(C+4)!}{(C+4)^2} = \frac{(C+4)(C+3)(C+2)(C+1) \cdot C!}{(C+4)^2}$$

The numerator contains the factor (C+4)(C+3) ≥ (C+4)², so after cancellation we get at least (C+2)(C+1)·C!/(C+4) which exceeds C for C ≥ 0. The inductive step from n to n+1 follows from (n+1)!/( n+1)² = n!/n² · n²(n+1)/(n+1)² = n!/n² · n²/(n+1), which is increasing for n ≥ 2. ∎

### 3.3 Determinant Families are Factorially Incompressible

**Theorem 3.3** (Factorial Incompressibility). *For every C ∈ ℕ, there exists N such that the compression gap of the determinant family exceeds C for all n ≥ N.*

**Proof.** Immediate from Theorem 3.2 and the fact that gap(n) = n!/n² for n ≥ 1. ∎

### 3.4 Tropical Determinant Equals Permanent

**Theorem 3.4** (Tropical Det = Perm). *For any n×n integer matrix M, the tropical determinant of M equals the tropical permanent of M.*

**Proof.** Both are defined as min_{σ ∈ Sₙ} Σᵢ M(i, σ(i)). The classical determinant differs from the permanent by the sign sgn(σ) of each permutation. In tropical (min-plus) algebra, there is no analog of the sign — the minimum operation is invariant under multiplication by ±1 (since we're taking minimums of sums, not sums of signed products). Therefore the two quantities coincide. ∎

---

## 4. Algorithms

### 4.1 Compression Gap Bound

**Algorithm 1**: CompressionGapBound(C, k)

```
Input: C ∈ ℕ (target gap), k ∈ ℕ (polynomial degree)
Output: N ∈ ℕ such that n!/n^k > C for all n ≥ N

function CompressionGapBound(C, k):
    return max(2k + 2, 2C + 2)
```

**Complexity**: O(1) time and space.

**Correctness**: For n ≥ 2k + 2, the product n(n-1)···(n-k+1) contains k+1 factors each ≥ n/2 ≥ k+1, giving n!/n^k ≥ (k+1)^(k+1) · (n-k-1)! / n^k. For n ≥ 2C + 2, the remaining factorial contributes enough to exceed C.

### 4.2 Phase Transition Threshold

**Algorithm 2**: PhaseTransitionThreshold(threshold)

```
Input: threshold ∈ ℕ (incompressibility threshold)
Output: n* ∈ ℕ such that n!/n² ≥ threshold for all n ≥ n*

function PhaseTransitionThreshold(threshold):
    n = 1
    while n!/n² < threshold:
        n = n + 1
    return n
```

**Complexity**: O(n* · n*) time (computing factorials incrementally).

### 4.3 Numerical Results

| n  | n!          | n²   | n!/n²       | Phase      |
|----|-------------|------|-------------|------------|
| 1  | 1           | 1    | 1.00        | Compressible |
| 2  | 2           | 4    | 0.50        | Compressible |
| 3  | 6           | 9    | 0.67        | Compressible |
| 4  | 24          | 16   | 1.50        | Transition  |
| 5  | 120         | 25   | 4.80        | Transition  |
| 6  | 720         | 36   | 20.00       | Incompressible |
| 7  | 5040        | 49   | 102.86      | Incompressible |
| 8  | 40320       | 64   | 630.00      | Incompressible |
| 9  | 362880      | 81   | 4480.00     | Incompressible |
| 10 | 3628800     | 100  | 36288.00    | Incompressible |
| 15 | 1.307×10¹²  | 225  | 5.81×10⁹    | Deep incompressible |
| 20 | 2.433×10¹⁸  | 400  | 6.08×10¹⁵   | Deep incompressible |

The phase transition occurs around n = 4-6, where the gap crosses from below 1 to significantly above 1.

---

## 5. Applications

### 5.1 Proof Automation Limits

The factorial compression gap provides a theoretical ceiling on the effectiveness of brute-force proof search. For a determinant identity involving an n×n matrix where n ≥ 10, any proof strategy that doesn't exploit the algebraic structure of the determinant will require at least 36,288 times more steps than Gaussian elimination. This ratio grows without bound.

**Practical implication**: Automated theorem provers that rely on term rewriting or enumeration over permutations will hit a factorial wall for determinant-related conjectures. The only escape is to implement high-level algebraic reasoning (row reduction, cofactor expansion with memoization) as first-class proof strategies.

### 5.2 Algebraic Complexity Theory

Our compression gap framework provides a proof-theoretic perspective on the VP vs VNP question:

- **VP** (Valiant's P): families of polynomials computable by polynomial-size arithmetic circuits. The determinant is VP-complete.
- **VNP** (Valiant's NP): families of polynomials with polynomial-length defining sequences. The permanent is VNP-complete.

The compression gap n!/n² is precisely the ratio of VNP-style computation (summing over all permutations) to VP-style computation (using circuit structure). Our theorem that this gap is unbounded is consistent with the conjecture VP ≠ VNP — indeed, it can be viewed as a *proof-theoretic shadow* of this algebraic complexity separation.

### 5.3 Resultant Extensions

The framework extends naturally to resultant computations. The resultant of polynomials of degrees m and n has (m+n)! / (m! · n!) terms in its Sylvester expansion. The compression gap is:

$$\text{gap}(m,n) = \frac{(m+n)!}{m! \cdot n! \cdot (m+n)}$$

This is the binomial coefficient C(m+n, m) / (m+n), which grows super-exponentially when m + n → ∞.

---

## 6. Computational Experiments

### 6.1 Growth Rate Visualization

The Python demonstration (`demo.py`) provides:

1. **Growth comparison**: n!/n² plotted against exponential baselines (2ⁿ, 3ⁿ, 10ⁿ) on a logarithmic scale. The factorial curve eventually dominates all exponentials.

2. **Phase transition**: A plot of log(n!/n²) vs n, with the incompressibility threshold marked. The transition from compressible to incompressible regimes is visible as a change in the curve's slope.

3. **Resultant gap surface**: A heatmap of gap(m,n) for 1 ≤ m, n ≤ 10, showing the two-parameter phase transition surface.

### 6.2 Threshold Computation

Using Algorithm 2, we compute phase transition thresholds for various incompressibility criteria:

| Threshold | n* (min dimension exceeding threshold) |
|-----------|---------------------------------------|
| 1         | 4                                     |
| 10        | 6                                     |
| 100       | 7                                     |
| 1,000     | 9                                     |
| 10,000    | 10                                    |
| 10⁶       | 12                                    |
| 10⁹       | 15                                    |

---

## 7. Discussion

### 7.1 The Role of Cancellation

The tropical determinant-permanent equality reveals that the fundamental source of compression in determinant computation is *algebraic cancellation*. In the classical determinant, positive and negative terms cancel in structured ways that Gaussian elimination exploits. Without cancellation (in the tropical setting), the determinant has the same complexity as the permanent — which is #P-hard.

This suggests a general principle: **proof compression requires structured cancellation**. Proof families where the underlying algebra admits cancellation can be compressed; those where it doesn't are factorially incompressible.

### 7.2 Beyond Determinants

Our framework applies to any mathematical object whose "brute-force" computation involves summing over permutations:

- **Pfaffians**: The Pfaffian of a 2n×2n skew-symmetric matrix has n! terms (with a factor of 2^n from pair matchings). The compression gap is n!/n², still super-exponential.
- **Immanants**: Generalized matrix functions summing over permutations weighted by characters of the symmetric group. Different characters yield different compression behaviors.
- **Hyperdeterminants**: Higher-dimensional analogs of determinants for tensors. The compression gap grows as (n!)^(d-1) for d-dimensional tensors.

### 7.3 Limitations

Our cost model is deliberately simple: we measure proof steps as either "Gaussian elimination steps" (O(n²)) or "Leibniz expansion terms" (n!). A more refined model might account for:

- **Sharing**: The Leibniz expansion can share subcomputations via memoization, potentially reducing the effective cost.
- **Parallelism**: The n! terms can be computed independently, reducing wall-clock time to O(n) on n!/n processors.
- **Intermediate strategies**: Cofactor expansion with memoization yields O(2ⁿ · n²) complexity — exponential but not factorial.

Even with these refinements, the super-exponential gap persists: 2ⁿ/n² still exceeds any polynomial.

---

## 8. Future Work

1. **Sharp phase transition bounds**: Determine the exact dimension n* where the compression gap first exceeds a given threshold, as a function of the threshold.

2. **Resultant families**: Extend the analysis to multivariate resultants and discriminants, establishing the two-parameter phase transition surface.

3. **Proof DAG sharing**: Analyze how much of the factorial cost can be recovered by sharing subproofs in a directed acyclic graph (DAG) representation.

4. **Lower bounds**: Prove that no proof strategy for determinant identities can avoid at least exponential cost, ruling out "intermediate" strategies.

5. **Connections to circuit complexity**: Formalize the relationship between compression gaps and arithmetic circuit size, bridging proof complexity and algebraic complexity.

---

## 9. References

1. Burgisser, P. (2000). *Completeness and Reduction in Algebraic Complexity Theory*. Springer.

2. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.

3. Valiant, L. G. (1979). "The complexity of computing the permanent." *Theoretical Computer Science*, 8(2), 189-201.

4. Strassen, V. (1969). "Gaussian elimination is not optimal." *Numerische Mathematik*, 13(4), 354-356.

5. Cook, S. A. & Reckhow, R. A. (1979). "The relative efficiency of propositional proof systems." *Journal of Symbolic Logic*, 44(1), 36-50.

6. Alon, N. & Boppana, R. (1987). "The monotone circuit complexity of Boolean functions." *Combinatorica*, 7(1), 1-22.

---

## Appendix A: Formal Verification Details

All main theorems are formally verified in Lean 4 with the Mathlib library. The formal development is contained in `Pythagorean/DetCompressionGap.lean` and includes:

- `factorial_dominates_polynomial_strong`: The factorial dominance theorem (Theorem 3.1)
- `super_exponential_compression_gap`: The super-exponential gap (Theorem 3.2)
- `det_family_factorially_incompressible`: Factorial incompressibility (Theorem 3.3)
- `tropical_det_eq_tropical_perm`: Tropical det = perm (Theorem 3.4)

The proofs use only standard axioms (propext, Classical.choice, Quot.sound) and depend on Mathlib's real analysis, combinatorics, and linear algebra libraries.
