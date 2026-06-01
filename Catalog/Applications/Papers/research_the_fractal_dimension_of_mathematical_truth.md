# The Fractal Dimension of Mathematical Truth

## Abstract

We develop a formal framework for studying the fractal dimension of the set of true mathematical statements in a formal system. By encoding statements as binary strings and tracking the count N(n) of true statements at each length level n, we define a *growth exponent* α(n) = log(N(n))/(n·log 2) that serves as the pointwise analogue of box-counting dimension. We prove that α(n) ∈ [0, 1] for all n > 0 (Theorem 1), establish a *density-exponent duality* relating truth density to the growth exponent (Theorem 2), prove monotonicity of the exponent in the counting function (Theorem 3), and show that bounded density implies strict dimension bounds (Theorem 4). We connect the growth exponent to Chaitin's halting probability Ω by proving that partial enumerations provide lower bounds on the dimension (Theorem 5). We introduce the novel concept of a *Truth Density Spectrum* — a mathematical structure that packages a growth function with certified bounds on its fractal dimension and measures the *spectral gap* (dimensional irregularity) of truth. All main theorems are machine-verified in the Lean 4 proof assistant using the Mathlib library.

**Keywords**: fractal dimension, truth density, growth exponent, Chaitin's Omega, box-counting dimension, formal verification, computability

## 1. Introduction

### 1.1 Motivation

The question "how much of mathematics is true?" admits multiple interpretations. In the measure-theoretic sense, for natural probability measures on the space of mathematical statements, the fraction of true statements depends on the encoding and the measure. In the computability-theoretic sense, the decidability of truth is limited by Gödel's incompleteness theorems. We propose a *geometric* perspective: the set of true statements, embedded in the space of all binary strings, has a well-defined fractal dimension that captures the "size" of truth independently of any particular probability measure.

### 1.2 Related Work

The connection between computability and fractal dimension has been explored in several contexts:

- **Effective dimension** (Lutz, 2003; Mayordomo, 2002): defines Hausdorff dimension for individual sequences using constructive supermartingales.
- **Kolmogorov complexity and dimension** (Staiger, 1993; Ryabko, 1986): relates the Kolmogorov complexity of prefixes to Hausdorff dimension.
- **Chaitin's Omega** (Chaitin, 1975): the halting probability Ω is a well-defined but uncomputable real number that encodes the halting problem.
- **Π₁⁰ classes** (Cenzer & Remmel, 1998): effectively closed sets in Cantor space have computable Hausdorff dimensions in many cases.

Our contribution is to (a) formalize the framework of growth exponents for truth sets, (b) prove the key structural theorems rigorously in Lean 4, and (c) introduce the Truth Density Spectrum as a novel mathematical object.

### 1.3 Overview of Results

| Theorem | Statement | Significance |
|---------|-----------|--------------|
| Thm 1 (Exponent Bounds) | α(n) ∈ [0, 1] | Dimension is well-defined |
| Thm 2 (Duality) | log(d(n)) = n(α(n)−1)·log 2 | Density ↔ dimension |
| Thm 3 (Monotonicity) | N₁ ≤ N₂ ⟹ α₁ ≤ α₂ | Dimension is structural |
| Thm 4 (Sparsity) | d(n) ≤ c < 1 ⟹ α(n) < 1 | Truth is sparse |
| Thm 5 (Approximation) | k ≤ N(n) ⟹ log(k)/(n·log 2) ≤ α(n) | Computable lower bounds |

## 2. Definitions

### 2.1 Binary Growth Function

**Definition 1** (Binary Growth). A *binary growth function* is a function N : ℕ → ℕ satisfying:
1. **Positivity**: N(n) > 0 for all n > 0 (at least one true statement at each length)
2. **Boundedness**: N(n) ≤ 2ⁿ for all n (count cannot exceed total strings)

In Lean 4, this is formalized as the structure `BinaryGrowth` with fields `count`, `count_pos`, and `count_le`.

### 2.2 Truth Density

**Definition 2** (Truth Density). The *truth density* at level n is:

d(n) = N(n) / 2ⁿ

This represents the fraction of binary strings of length n that encode true statements.

### 2.3 Growth Exponent

**Definition 3** (Growth Exponent). The *growth exponent* at level n > 0 is:

α(n) = log(N(n)) / (n · log 2)

When the limit lim_{n→∞} α(n) exists, it equals the box-counting dimension of the truth set in Cantor space. The limsup and liminf give the upper and lower box-counting dimensions, respectively.

### 2.4 Truth Density Spectrum (Novel)

**Definition 4** (Truth Density Spectrum). A *truth density spectrum* is a tuple (N, α_L, α_U) where N is a binary growth function and α_L ≤ α_U are certified bounds satisfying:
- 0 ≤ α_L and α_U ≤ 1
- α_L ≤ α(n) ≤ α_U for all n > 0

The *spectral gap* is Δ = α_U − α_L ≥ 0.

**Interpretation**: The spectral gap measures the irregularity of truth's distribution across complexity levels. A zero spectral gap means the growth exponent converges; a positive spectral gap means truth density fluctuates at every scale.

## 3. Main Results

### 3.1 Theorem 1: Growth Exponent Bounds

**Theorem** (growthExponent_mem_Icc). *For any binary growth function N and any n > 0, the growth exponent satisfies α(n) ∈ [0, 1].*

*Proof sketch.* For the lower bound: N(n) ≥ 1 (by positivity), so log(N(n)) ≥ 0, and the denominator n·log 2 > 0, giving α(n) ≥ 0.

For the upper bound: N(n) ≤ 2ⁿ (by boundedness), so log(N(n)) ≤ log(2ⁿ) = n·log 2, giving α(n) ≤ 1. □

**Significance**: This establishes that the growth exponent is a valid "dimension" — always between 0 (negligible truth) and 1 (full truth).

### 3.2 Theorem 2: Density-Exponent Duality

**Theorem** (density_exponent_duality). *For any binary growth function N and any n > 0:*

log(d(n)) = n · (α(n) − 1) · log 2

*Proof sketch.* By definition, d(n) = N(n)/2ⁿ, so:
log(d(n)) = log(N(n)) − log(2ⁿ) = log(N(n)) − n·log 2

Since α(n) = log(N(n))/(n·log 2), we have log(N(n)) = n·α(n)·log 2, thus:
log(d(n)) = n·α(n)·log 2 − n·log 2 = n·(α(n) − 1)·log 2 □

**Significance**: This is the central identity of the framework. It reveals that:
- α(n) < 1 ⟺ d(n) < 1: truth is sparse at level n
- The rate of density decay is exponential with rate determined by the dimension deficit (1 − α)
- The identity is the analogue of the Hausdorff measure characterization d_H(S) = inf{s : H^s(S) = 0}

### 3.3 Theorem 3: Monotonicity

**Theorem** (exponent_mono). *If N₁(n) ≤ N₂(n) for some n > 0, then α₁(n) ≤ α₂(n).*

*Proof sketch.* The logarithm is monotone: N₁(n) ≤ N₂(n) and N₁(n) > 0 imply log(N₁(n)) ≤ log(N₂(n)). Dividing by the positive constant n·log 2 preserves the inequality. □

**Significance**: The growth exponent is a structural invariant — it depends on the size of the truth set, not on its particular encoding. Enlarging the truth predicate can only increase the dimension.

### 3.4 Theorem 4: Strict Dimension Bounds

**Theorem** (dim_strict_upper_of_sparse). *If d(n) ≤ c for some c ∈ (0, 1) and all n > 0, then α(n) < 1 for all n > 0.*

*Proof sketch.* By the duality theorem, if α(n) = 1, then log(d(n)) = 0, so d(n) = 1 (since d(n) > 0). But d(n) ≤ c < 1, contradiction. Since α(n) ≤ 1 (by Theorem 1) and α(n) ≠ 1, we get α(n) < 1. □

**Theorem** (dim_lower_of_exponential). *If N(n) ≥ rⁿ for some r ∈ (1, 2] and n > 0, then α(n) ≥ log(r)/log(2) > 0.*

*Proof sketch.* Taking logarithms: log(N(n)) ≥ log(rⁿ) = n·log(r). Dividing by n·log 2 gives α(n) ≥ log(r)/log(2). □

**Significance**: Together, these theorems show that under natural conditions — truth is sparse (density bounded away from 1) and non-negligible (count grows exponentially) — the fractal dimension is strictly between 0 and 1.

### 3.5 Theorem 5: Computable Approximation

**Theorem** (partial_enumeration_lower_bound). *If k ≤ N(n) with k > 0 and n > 0, then:*

log(k) / (n · log 2) ≤ α(n)

*Proof sketch.* Since k ≤ N(n), by monotonicity of log: log(k) ≤ log(N(n)). Dividing by n·log 2 > 0 gives the result. □

**Significance**: This theorem formalizes the connection to Chaitin's Omega. Any partial enumeration of true statements provides a rigorous lower bound on the fractal dimension. The exact dimension requires enumerating *all* truths, which is equivalent to deciding the truth predicate — undecidable by Gödel's theorem. Thus the fractal dimension is:
- **Uncomputable**: No algorithm can determine it exactly
- **Approximable from below**: Each verified theorem improves the lower bound
- **Structurally analogous to Ω**: Both are Σ₁⁰-approximable but not computable reals

### 3.6 Existence Results

**Theorem** (maximalGrowth_exponent). *The growth function N(n) = 2ⁿ achieves α(n) = 1 for all n > 0.*

**Theorem** (minimalGrowth_exponent). *The growth function N(n) = 1 achieves α(n) = 0 for all n > 0.*

**Significance**: These show the bounds in Theorem 1 are tight.

## 4. The Truth Density Spectrum

### 4.1 Canonical Spectrum

Every binary growth function admits a *canonical spectrum* with bounds [0, 1]:

**Construction** (canonicalSpectrum). Given N, the canonical spectrum is (N, 0, 1) with spectral gap Δ = 1.

This follows directly from Theorem 1.

### 4.2 Fractional Spectrum

When additional information about the growth function is available — specifically, bounds α_L ≤ α(n) ≤ α_U with 0 < α_L and α_U < 1 — we obtain a *fractional spectrum* with smaller spectral gap.

**Construction** (fractionalSpectrum). Given N with certified bounds 0 < α ≤ α(n) ≤ β < 1, the fractional spectrum is (N, α, β) with spectral gap Δ = β − α.

### 4.3 Spectral Gap Positivity Conjecture

**Conjecture**. For any binary growth function with 1 < N(n) < 2ⁿ for all n > 0, there exist n₁, n₂ > 0 such that α(n₁) ≠ α(n₂).

**Testable prediction**: Enumerate true statements of Presburger arithmetic at lengths n = 1, 2, ..., 100 and compute the growth exponents. If any two exponents differ, this provides evidence for the conjecture. If all are equal, this is evidence against.

**Implications**: If true, the fractal dimension of truth never converges — truth has intrinsic dimensional irregularity at every scale. If false, truth is asymptotically regular.

## 5. Algorithms

### 5.1 Growth Exponent Computation

```
Algorithm: ComputeGrowthExponent(n, oracle)
Input: Level n, truth oracle for strings of length n
Output: Growth exponent α(n)

1. count ← 0
2. For each string s of length n:
3.    If oracle(s) = true: count ← count + 1
4. Return log(count) / (n · log(2))
```

**Complexity**: O(2ⁿ) oracle queries, O(n) arithmetic operations.

### 5.2 Spectral Bound Refinement

```
Algorithm: RefineSpectralBounds(N_max, oracle)
Input: Maximum level N_max, truth oracle
Output: Spectral bounds (α_L, α_U)

1. α_L ← 1, α_U ← 0
2. For n = 1 to N_max:
3.    α(n) ← ComputeGrowthExponent(n, oracle)
4.    α_L ← min(α_L, α(n))
5.    α_U ← max(α_U, α(n))
6. Return (α_L, α_U)
```

### 5.3 Partial Enumeration Approximation

```
Algorithm: ApproximateDimensionFromBelow(n, partial_truths)
Input: Level n, set of k verified true statements of length n
Output: Lower bound on α(n)

1. k ← |partial_truths|
2. If k = 0: return 0
3. Return log(k) / (n · log(2))
```

**Key property**: This algorithm provides a monotonically improving lower bound as more truths are discovered — directly analogous to the approximation of Chaitin's Ω from below.

## 6. Discussion

### 6.1 Interpretation

The growth exponent framework provides a quantitative measure of the "size" of mathematical truth. The key insight is that truth occupies a fractal position in the space of all statements: exponentially many truths exist (dimension > 0), but they are exponentially outnumbered by false statements (dimension < 1).

### 6.2 Connection to Information Theory

The density-exponent duality has an information-theoretic interpretation. The growth exponent α(n) equals the *information rate* of truth: the number of bits of information needed to specify a true statement, divided by the total encoding length. When α = 0.7, for instance, each bit of encoding carries 0.7 bits of "truth information."

### 6.3 Limitations

1. **Encoding dependence**: The growth exponent depends on the encoding of statements as binary strings. Different encodings can yield different dimensions. However, encodings related by polynomial-time computable bijections yield the same asymptotic dimension.

2. **Finite computability**: While we prove structural theorems about the growth exponent at each finite level, the asymptotic dimension (the limit as n → ∞) may not exist, which motivates the spectral gap conjecture.

3. **Formal system dependence**: The growth exponent depends on the formal system (Presburger arithmetic, PA, ZFC, etc.). More expressive systems may have different dimensions.

### 6.4 Open Problems

1. Does the limit lim_{n→∞} α(n) exist for natural encodings of PA?
2. If so, is it a computable real number?
3. What is the relationship between the spectral gap and the Kolmogorov complexity of the truth predicate?
4. Can the growth exponent be used to distinguish formal systems by their "truth geometry"?

## 7. Future Work

The Truth Density Spectrum opens several research directions:

1. **Computational experiments**: Enumerate truths of Presburger arithmetic at small lengths and compute growth exponents.
2. **Entropy profiles**: Define and study the Shannon entropy of the truth distribution at each level.
3. **Multi-dimensional spectra**: Generalize to truth sets in multi-sorted logics.
4. **Category-theoretic formulation**: Define morphisms between truth density spectra that preserve dimensional structure.
5. **Connection to proof complexity**: Relate the growth exponent to the minimum proof length of statements at each level.

## 8. Formalization Notes

All theorems in Sections 3–4 are machine-verified in Lean 4.28.0 using Mathlib. The formalization consists of approximately 330 lines of Lean code in a single file `Tropical/FractalDimensionOfTruth.lean`. The verification uses only the standard axioms (propext, Classical.choice, Quot.sound).

Key formalization decisions:
- The growth exponent is defined as 0 at n = 0 to avoid division by zero.
- All definitions involving real-valued computations are marked `noncomputable`.
- The `TruthDensitySpectrum` structure carries proof obligations as fields, ensuring the spectral bounds are always valid.

## References

1. Chaitin, G. J. (1975). A theory of program size formally identical to information theory. *Journal of the ACM*, 22(3), 329-340.

2. Lutz, J. H. (2003). Dimension in complexity classes. *SIAM Journal on Computing*, 32(5), 1236-1259.

3. Gödel, K. (1931). Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I. *Monatshefte für Mathematik und Physik*, 38(1), 173-198.

4. Falconer, K. (2014). *Fractal Geometry: Mathematical Foundations and Applications*. John Wiley & Sons.

5. Staiger, L. (1993). Kolmogorov complexity and Hausdorff dimension. *Information and Computation*, 103(2), 159-194.

6. Cenzer, D., & Remmel, J. B. (1998). Π₁⁰ classes in mathematics. In *Handbook of Recursive Mathematics*, Vol. 2, pp. 623-821.
