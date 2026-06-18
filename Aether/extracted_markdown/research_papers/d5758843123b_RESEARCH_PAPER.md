# Fractal Dimension of Mathematical Truth: A Formal Framework

## Abstract

We introduce a rigorous framework for studying the fractal dimension of sets of mathematical truths parametrized by complexity. The central object is a *Truth Counting System* (TCS): a function N : ℕ → ℕ satisfying N(n) ≤ 2^n, modeling the count of true sentences among all binary strings of length n. Under the *submultiplicativity* axiom N(n+m) ≤ N(n)·N(m), we establish five principal results: (1) the Power Bound Theorem, showing N(k·n) ≤ N(n)^k; (2) the Defect Superadditivity Theorem, proving D(n+m) ≥ D(n)·2^m + N(n)·D(m) where D = 2^n − N(n); (3) the Strict Gap Propagation Theorem, showing that sparsity at any level propagates to all multiples; (4) the Defect Exponential Growth Theorem; and (5) the Dimensional Collapse Theorem. We further establish a bridge to tropical geometry, showing that the log-deficiency function defines a superadditive valuation in the tropical semiring. All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: fractal dimension, truth density, submultiplicative sequences, tropical geometry, formal verification, Fekete's lemma

## 1. Introduction

### 1.1 Motivation

The distribution of mathematical truths across complexity levels has been studied from several perspectives: Kolmogorov complexity (the algorithmic content of individual strings), Chaitin's Ω (the halting probability as a measure of logical depth), and various counting arguments in proof complexity. However, a systematic framework for studying the *geometry* of truth — how the set of provable statements sits inside the space of all strings — has been lacking.

We propose such a framework built around the *growth exponent* α(n) = log₂(N(n))/n, where N(n) counts the true statements of complexity n. The limiting value α = lim α(n), when it exists, plays the role of a fractal dimension: it measures the exponential growth rate of truth relative to the growth rate of the ambient space.

### 1.2 The Submultiplicativity Axiom

The key structural assumption is *submultiplicativity*:

$$N(n + m) \leq N(n) \cdot N(m) \quad \text{for all } n, m \in \mathbb{N}$$

This axiom is satisfied by many natural truth-counting functions. For instance, if truths at level n+m are obtained by composing truths at levels n and m, then the composed truths can be at most the product of the individual counts. More precisely, if we have a map φ : Σ_n × Σ_m → Σ_{n+m} from pairs of strings to composed strings, and truth is preserved under composition, then the image of T_n × T_m in Σ_{n+m} has cardinality at most |T_n| · |T_m|, and every truth at level n+m need not arise this way — giving the inequality.

### 1.3 Connection to Fekete's Lemma

By taking logarithms, submultiplicativity of N(n) implies subadditivity of log N(n). By Fekete's lemma, the limit lim_{n→∞} log N(n) / n exists (as an infimum). This limit, divided by log 2, gives the fractal dimension α ∈ [0, 1].

## 2. Definitions

### 2.1 Truth Counting System

**Definition 2.1.** A *Truth Counting System* (TCS) is a pair (N, β) where N : ℕ → ℕ is the counting function and β : ∀n, N(n) ≤ 2^n is the bounding certificate.

The *defect* at level n is D(n) = 2^n − N(n), measuring the number of non-truths.

The *density* at level n is d(n) = N(n)/2^n ∈ [0, 1].

### 2.2 Submultiplicative TCS

**Definition 2.2.** A *Submultiplicative TCS* (SubMultTCS) is a TCS together with the axiom:
$$\forall n, m : \mathbb{N}, \quad N(n+m) \leq N(n) \cdot N(m)$$

### 2.3 Tropical Truth Weight

**Definition 2.3.** A *Tropical Truth Weight* is a function w : ℕ → ℝ satisfying:
- w(n) ≥ 0 for all n (non-negativity)
- w(n+m) ≥ w(n) + w(m) for all n, m (superadditivity)

The weight w(n) represents the "information deficiency" n − log₂(N(n)) in the tropical semiring (ℝ ∪ {−∞}, max, +).

### 2.4 Density Cross-Comparison

To avoid working with rationals or reals when comparing densities, we define the *density cross-comparison*: we say level n has density ≤ level m's density when N(n) · 2^m ≤ N(m) · 2^n. This cross-multiplication keeps all arithmetic in ℕ.

## 3. Main Results

### 3.1 Power Bound Theorem

**Theorem 3.1** (Power Bound). *For a SubMultTCS, N(k·n) ≤ N(n)^k for all k, n ∈ ℕ.*

*Proof sketch.* By induction on k. The base case k = 0 gives N(0) ≤ 2^0 = 1 = N(n)^0. For the inductive step:
$$N((k+1)n) = N(kn + n) \leq N(kn) \cdot N(n) \leq N(n)^k \cdot N(n) = N(n)^{k+1}$$
where the first inequality is submultiplicativity and the second is the inductive hypothesis. □

**Remark.** This theorem is the discrete analogue of the standard result that submultiplicative functions have well-defined exponential growth rates. The integer setting requires some care with the base case (N(0) ≤ 1 follows from the TCS bound).

### 3.2 Defect Superadditivity Theorem

**Theorem 3.2** (Defect Superadditivity). *For a SubMultTCS:*
$$D(n+m) \geq D(n) \cdot 2^m + N(n) \cdot D(m)$$

*Proof sketch.* We have:
$$D(n+m) = 2^{n+m} - N(n+m) \geq 2^n \cdot 2^m - N(n) \cdot N(m)$$
by submultiplicativity. The algebraic identity (valid for a ≥ c, b ≥ d in ℕ):
$$ab - cd = (a-c)b + c(b-d)$$
with a = 2^n, b = 2^m, c = N(n), d = N(m) gives the result. □

**Corollary.** If D(n) > 0, then D(n+m) > 0. In particular, D(n+m) ≥ D(n) · 2^m > 0.

### 3.3 Strict Gap Propagation

**Theorem 3.3** (Strict Gap Propagation). *If N(n₀) < 2^{n₀} and k ≥ 1, then N(k·n₀) < 2^{k·n₀}.*

*Proof sketch.* By Theorem 3.1, N(k·n₀) ≤ N(n₀)^k. Since N(n₀) < 2^{n₀}, we have N(n₀)^k < (2^{n₀})^k = 2^{k·n₀}. □

**Philosophical import.** Once truth thins out at any complexity level, it remains thin along all arithmetic multiples of that level. The gap can never close.

### 3.4 Density Product Bound

**Theorem 3.4** (Density Product Bound). *For a SubMultTCS:*
$$N(n+m) \cdot 2^n \cdot 2^m \leq N(n) \cdot N(m) \cdot 2^{n+m}$$

*Proof sketch.* Since 2^n · 2^m = 2^{n+m}, this reduces to N(n+m) ≤ N(n)·N(m), which is submultiplicativity. □

**Interpretation.** In density terms, d(n+m) ≤ d(n) · d(m). The density sequence is submultiplicative.

### 3.5 Defect Exponential Growth

**Theorem 3.5** (Defect Exponential Growth). *For a SubMultTCS:*
$$D((k+1) \cdot n_0) \geq N(n_0)^k \cdot D(n_0)$$

*Proof sketch.* The key algebraic inequality is: for a ≤ b in ℕ,
$$b^{k+1} - a^{k+1} \geq a^k (b - a)$$
This follows from the factorization b^{k+1} − a^{k+1} = (b−a)(b^k + b^{k-1}a + ⋯ + a^k) ≥ (b−a)·a^k, since each term b^i · a^{k-i} ≥ a^k when b ≥ a. Applying this with a = N(n₀), b = 2^{n₀}, and using N((k+1)n₀) ≤ N(n₀)^{k+1} gives the result. □

### 3.6 Dimensional Collapse

**Theorem 3.6** (Dimensional Collapse). *If N(n₀) · N(m₀) < 2^{n₀+m₀} for some n₀, m₀, then for all k ≥ 1:*
$$N(k \cdot (n_0 + m_0)) < 2^{k(n_0 + m_0)}$$

*Proof sketch.* Set p = n₀ + m₀. By submultiplicativity, N(p) ≤ N(n₀)·N(m₀) < 2^p. Apply Theorem 3.3. □

**Interpretation.** Strict submultiplicativity at any single pair of levels forces the fractal dimension strictly below 1 along an arithmetic progression.

### 3.7 Bridge to Tropical Geometry

**Theorem 3.7** (Tropical Bridge). *For a SubMultTCS with N(n) > 0 for all n, the function*
$$w(n) = \log_2\left(\frac{2^n}{N(n)}\right)$$
*is superadditive: w(n+m) ≥ w(n) + w(m).*

*Proof sketch.* We have:
$$w(n) + w(m) = \log_2\left(\frac{2^n}{N(n)}\right) + \log_2\left(\frac{2^m}{N(m)}\right) = \log_2\left(\frac{2^{n+m}}{N(n) \cdot N(m)}\right)$$
Since N(n+m) ≤ N(n)·N(m), we have 2^{n+m}/N(n+m) ≥ 2^{n+m}/(N(n)·N(m)), and log₂ is monotone. □

## 4. Algorithms

### 4.1 Computing the Growth Exponent

Given oracle access to N(n), the growth exponent can be approximated as:

```
Algorithm: ApproximateAlpha(N, max_n)
  best = 1.0
  for n = 1 to max_n:
    alpha_n = log2(N(n)) / n
    best = min(best, alpha_n)  // By Fekete's lemma, infimum gives the limit
  return best
```

By Fekete's lemma, the infimum of α(n) = log₂(N(n))/n equals the limit. So the algorithm converges from above.

### 4.2 Detecting Dimensional Collapse

```
Algorithm: DetectCollapse(N, max_n)
  for n0 = 1 to max_n:
    for m0 = 1 to max_n:
      if N(n0) * N(m0) < 2^(n0 + m0):
        return (n0, m0, "Dimension < 1 detected")
  return "No collapse detected up to level max_n"
```

### 4.3 Defect Growth Verification

```
Algorithm: VerifyDefectGrowth(N, n0, max_k)
  d0 = 2^n0 - N(n0)
  for k = 1 to max_k:
    d_k = 2^((k+1)*n0) - N((k+1)*n0)
    predicted = N(n0)^k * d0
    assert d_k >= predicted
    print(f"k={k}: actual={d_k}, predicted≥{predicted}, ratio={d_k/predicted}")
```

## 5. Discussion

### 5.1 Relation to Chaitin's Ω

Chaitin's halting probability Ω = Σ 2^{-|p|} for halting programs p is intimately related to our framework. If we let N(n) count the halting programs of length n, then the density d(n) = N(n)/2^n is the contribution of level-n programs to Ω. Our framework shows that the submultiplicative structure of N(n) controls how these contributions decay, providing a new perspective on why Ω is irrational (and in fact algorithmically random).

### 5.2 Relation to Proof Complexity

In proof complexity, the counting function N(n) = |{φ : φ has a proof of length ≤ n}| satisfies a version of submultiplicativity when the proof system allows composition. Our results then give bounds on the density of provable statements as a function of proof length.

### 5.3 The Tropical Connection

The bridge to tropical geometry (Theorem 3.7) opens several directions. In tropical algebraic geometry, valuations play the role of coordinates, and our superadditive log-deficiency functions are precisely tropical valuations. This suggests that the set of truth-counting systems with a given fractal dimension might form a tropical variety — a piecewise-linear geometric object.

## 6. Future Work

1. **Fekete's Lemma Formalization**: Complete the formalization of Fekete's lemma to show that the limit α = lim log₂(N(n))/n exists for any SubMultTCS.

2. **Rationality Conjecture**: Investigate whether the fractal dimension is always rational for computable TCS.

3. **Tropical Variety Structure**: Determine whether the moduli space of SubMultTCS with a given dimension has tropical-geometric structure.

4. **Connection to Proof Complexity**: Apply the framework to specific proof systems (Resolution, Frege, Extended Frege) and compute their fractal dimensions.

5. **Entropy-Dimension Bridge**: Connect the fractal dimension to Shannon entropy of the uniform distribution on truth sets.

## 7. References

1. Fekete, M. "Über die Verteilung der Wurzeln bei gewissen algebraischen Gleichungen mit ganzzahligen Koeffizienten." *Mathematische Zeitschrift* 17 (1923): 228-249.

2. Chaitin, G. J. "A theory of program size formally identical to information theory." *Journal of the ACM* 22 (1975): 329-340.

3. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, AMS, 2015.

4. Krajíček, J. *Proof Complexity*. Cambridge University Press, 2019.

5. Cook, S. A. and Nguyen, P. *Logical Foundations of Proof Complexity*. Cambridge University Press, 2010.
