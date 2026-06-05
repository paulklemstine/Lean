# Diophantine Approximation Complexity of ReLU Networks: How Well Can Piecewise Linear Functions Approximate π?

## Abstract

We introduce the **ReLU Expression Algebra**, a formal framework for studying the approximation-theoretic properties of ReLU neural networks as compositions of piecewise linear operations. We define the **Diophantine approximation spectrum** of a real number, connecting neural network parameter complexity to classical number theory. Our main results, all formally verified, include: (1) an exponential piece count bound showing maxPieces(d) = 2^(d+1) − 1 for depth-d networks; (2) a quantitative error bound for the Leibniz series |4·Sₙ − π| ≤ 4/(2n+1) with explicit proof via alternating series estimation; (3) constructive π-approximation showing that ReLU expressions with rational parameters can approximate π to arbitrary precision; (4) an irrationality barrier proving that no rational-parameter ReLU expression can exactly represent π; and (5) the verified numerical bounds |π − 22/7| < 1/790 and |π − 355/113| < 1/3,000,000. We establish the composition complexity theorem for ReLU expressions and prove ReLU's structural properties (idempotence, Lipschitz continuity, positive homogeneity).

**Keywords**: ReLU networks, Diophantine approximation, piecewise linear functions, Leibniz series, irrationality measure, neural network expressiveness

## 1. Introduction

### 1.1 Motivation

The universal approximation theorem guarantees that feedforward neural networks with ReLU activation can approximate any continuous function on a compact set. However, the theorem is existential — it says nothing about the *rate* of approximation or the *complexity* needed to achieve a given accuracy.

For the special case of approximating constants — fixed real numbers like π, e, or √2 — the problem reduces to Diophantine approximation: how well can rational numbers (the outputs of rational-parameter networks) approximate irrational targets?

### 1.2 Contributions

We make the following contributions, all formally verified in Lean 4 with Mathlib:

1. **Novel mathematical structure**: The `ReLUExpr` algebra formalizes ReLU computations as an inductive type with evaluation semantics, complexity measures, and composition operations.

2. **Piece count theory**: We prove tight bounds on the piecewise linear complexity: 2^d ≤ maxPieces(d) ≤ 2^(d+1) − 1.

3. **Leibniz series formalization**: We prove the quantitative error bound for the Leibniz series, including the full alternating series estimation argument.

4. **Diophantine approximation spectrum**: We define and study a new function measuring approximation quality as a function of denominator bound.

5. **Concrete π bounds**: We verify |π − 22/7| < 1/790 and |π − 355/113| < 1/3,000,000 using Mathlib's constructive π bounds.

## 2. Definitions

### 2.1 ReLU Activation

**Definition 2.1** (ReLU). The ReLU function relu : ℝ → ℝ is defined by relu(x) = max(0, x).

**Theorem 2.2** (ReLU Properties). The following hold:
- (Idempotence) relu(relu(x)) = relu(x) for all x ∈ ℝ.
- (Monotonicity) If x ≤ y, then relu(x) ≤ relu(y).
- (1-Lipschitz) |relu(x) − relu(y)| ≤ |x − y| for all x, y ∈ ℝ.
- (Positive homogeneity) For c ≥ 0, relu(cx) = c · relu(x).
- (Nonnegativity) relu(x) ≥ 0 for all x ∈ ℝ.

*All five properties are formally verified.*

### 2.2 ReLU Expression Algebra

**Definition 2.3** (ReLUExpr). A ReLU expression is an element of the following inductive type:

```
inductive ReLUExpr where
  | const : ℝ → ReLUExpr        -- constant c
  | var : ReLUExpr               -- input variable x
  | relu : ReLUExpr → ReLUExpr   -- ReLU activation
  | add : ReLUExpr → ReLUExpr → ReLUExpr  -- addition
  | smul : ℝ → ReLUExpr → ReLUExpr        -- scalar multiplication
```

The evaluation function eval : ReLUExpr → ℝ → ℝ interprets expressions at a given input.

**Definition 2.4** (Complexity Measures). For a ReLUExpr e, we define:
- reluCount(e): number of ReLU nodes
- paramCount(e): number of parameter nodes (const and smul coefficients)
- depth(e): maximum nesting depth of ReLU operations
- size(e): total number of AST nodes

### 2.3 Piecewise Linear Complexity

**Definition 2.5** (maxPieces). The function maxPieces : ℕ → ℕ is defined by:
- maxPieces(0) = 1
- maxPieces(n + 1) = 2 · maxPieces(n) + 1

This counts the maximum number of linear pieces achievable by n successive ReLU operations.

### 2.4 Diophantine Approximation Spectrum

**Definition 2.6** (Diophantine Spectrum). For α ∈ ℝ and D ∈ ℕ, the Diophantine approximation spectrum is:

diophantineSpectrum(α, D) = inf{|α − p/q| : p ∈ ℤ, q ∈ ℕ, 0 < q ≤ D}

### 2.5 Leibniz Series

**Definition 2.7**. The Leibniz term and partial sum are:
- leibnizTerm(k) = (−1)^k / (2k + 1)
- leibnizPartialSum(n) = Σ_{k=0}^{n-1} leibnizTerm(k)

## 3. Main Results

### 3.1 Exponential Piece Count Bound

**Theorem 3.1** (Piece Count Bounds). For all n ∈ ℕ:

2^n ≤ maxPieces(n) ≤ 2^(n+1) − 1

*Proof sketch*. By induction. For the lower bound: maxPieces(n+1) = 2·maxPieces(n) + 1 ≥ 2·2^n + 1 > 2^(n+1). For the upper bound: maxPieces(n+1) = 2·maxPieces(n) + 1 ≤ 2·(2^(n+1) − 1) + 1 = 2^(n+2) − 1. □

**Corollary 3.2** (Depth-Width Exponential Separation). A network with d ReLU layers can express functions with at least 2^d linear pieces. Matching this with a single-layer network requires width at least 2^d − 1.

### 3.2 Leibniz Series Error Bound

**Theorem 3.3** (Quantitative Leibniz Error). For all n ≥ 1:

|leibnizPartialSum(n) − π/4| ≤ 1/(2n + 1)

*Proof sketch*. The Leibniz series is alternating with terms 1/(2k+1) that are positive and monotonically decreasing to 0. By the alternating series estimation theorem, the error after n terms is bounded by the magnitude of the next term. The proof establishes:
1. Odd partial sums S_{2m+1} are decreasing and bounded below by π/4.
2. Even partial sums S_{2m} are increasing and bounded above by π/4.
3. Both subsequences converge to π/4 (from Mathlib's `tendsto_sum_pi_div_four`).
4. The interleaving gives |S_n − π/4| ≤ |S_n − S_{n+1}| = 1/(2n+1). □

**Corollary 3.4**. |4 · leibnizPartialSum(n) − π| ≤ 4/(2n+1) ≤ 2/n for n ≥ 1.

### 3.3 Constructive π Approximation

**Theorem 3.5** (ReLU π-Approximation with Rational Parameters). For every ε > 0, there exists a ReLU expression e such that:
1. |e.eval(1) − π| < ε
2. e.reluCount = 0 (no ReLU activations needed)
3. e has rational value (e.eval(1) ∈ ℚ)

*Proof*. By the density of ℚ in ℝ, there exists q ∈ ℚ with |q − π| < ε. Take e = const(q). □

**Theorem 3.6** (Leibniz Approximation Rate). For every n ≥ 1, the expression leibnizReLUExpr(n) = const(4 · leibnizPartialSum(n)) satisfies |eval(1) − π| ≤ 4/(2n+1), has reluCount = 0, and has rational value.

### 3.4 Irrationality Barrier

**Theorem 3.7** (Rational-Parameter Barrier). For any q ∈ ℚ, the constant expression const(q) satisfies const(q).eval(1) ≠ π.

*Proof*. Since π is irrational (Niven's 1947 proof, available in Mathlib as `irrational_pi`) and q is rational, q ≠ π. □

**Theorem 3.8** (Positive Approximation Error). For all p ∈ ℤ, q ∈ ℕ with q > 0:

0 < |π − p/q|

### 3.5 Composition Complexity

**Theorem 3.9** (Composition Semantics). For ReLU expressions e₁, e₂:

(e₁.compose e₂).eval(x) = e₁.eval(e₂.eval(x))

**Theorem 3.10** (Composition Complexity Bound). For ReLU expressions e₁, e₂:

(e₁.compose e₂).reluCount ≤ e₁.reluCount + e₁.size · e₂.reluCount

This shows that composing networks is subadditive in ReLU count, with the multiplicative factor being the outer network's size.

### 3.6 Concrete π Bounds

**Theorem 3.11**. |π − 22/7| < 1/790.

**Theorem 3.12**. |π − 355/113| < 1/3,000,000.

*These bounds are verified using Mathlib's constructive π estimates* (`pi_gt_d6`, `pi_lt_d6`, `pi_gt_d20`, `pi_lt_d20`).

## 4. The Diophantine Approximation Spectrum

### 4.1 Properties

**Theorem 4.1**. The Diophantine spectrum satisfies:
1. (Nonnegativity) diophantineSpectrum(α, D) ≥ 0 for all α, D.
2. (Antitone) diophantineSpectrum(α, ·) is antitone: larger D allows better approximation.

### 4.2 Connection to Network Complexity

The spectrum provides a lower bound on network complexity. If a ReLU expression with rational output q approximates an irrational α within ε, then |α − q| > 0, and the quality is bounded by the spectrum evaluated at the denominator of q.

**Theorem 4.2**. For irrational α, any ReLU expression with rational output satisfies |α − output| > 0.

### 4.3 Spectrum of π

The spectrum of π exhibits dramatic drops at the continued fraction convergents:
- D = 7: spectrum ≈ 0.00126 (from 22/7)
- D = 113: spectrum ≈ 2.67 × 10⁻⁷ (from 355/113)
- D = 33102: spectrum ≈ 5.78 × 10⁻¹⁰ (from 103993/33102)

Each drop corresponds to a large coefficient in π's continued fraction [3; 7, 15, 1, 292, ...]. The coefficient 292 explains why 355/113 is an anomalously good approximation.

## 5. PEGB Analysis

### 5.1 Piece Count Theorem (PEGB)

- **P**roof: Induction on n with tight bounds 2^n ≤ maxPieces(n) ≤ 2^(n+1) − 1.
- **E**xample: maxPieces(3) = 15, sitting between 2^3 = 8 and 2^4 − 1 = 15 (tight!).
- **G**eneralization: For width-w networks, the bound becomes w^d ≤ pieces ≤ (2w)^d.
- **B**oundary: At n = 0, maxPieces(0) = 1 = 2^0, so the lower bound is tight. The formula maxPieces(n) = 2^(n+1) − 1 shows the upper bound is always achieved.

### 5.2 Leibniz Error Bound (PEGB)

- **P**roof: Alternating series estimation via monotone subsequences and limit comparison.
- **E**xample: n = 100 gives bound 4/201 ≈ 0.0199, actual error ≈ 0.01 (bound is ~2× actual).
- **G**eneralization: For any alternating series Σ (−1)^k · a_k with a_k ↓ 0, |S_n − S| ≤ a_n.
- **B**oundary: At n = 1, bound is 4/3 ≈ 1.33, actual error is |4 − π| ≈ 0.858. The bound is loose for small n but asymptotically tight (ratio → 1).

### 5.3 π Irrationality Barrier (PEGB)

- **P**roof: Contradiction via irrational_pi from Mathlib.
- **E**xample: 355/113 = 3.14159292... ≠ π = 3.14159265..., difference ≈ 2.67 × 10⁻⁷.
- **G**eneralization: For any irrational α, no rational-parameter ReLU expression can exactly represent α. The approximation error is bounded below by the irrationality measure.
- **B**oundary: Rational numbers have irrationality measure 1 and CAN be exactly represented by const(p/q).

### 5.4 Composition Complexity (PEGB)

- **P**roof: Structural induction on the outer expression.
- **E**xample: Composing two expressions with reluCount = 3 and sizes 7, 5 gives upper bound 3 + 7·3 = 24.
- **G**eneralization: For k-fold composition, the bound becomes multiplicative: O(size^k).
- **B**oundary: Composing with a constant expression (no relus, size 1) adds 0 relus.

## 6. Falsifiable Conjecture

**Conjecture** (Optimal Depth for Leibniz Approximation). There exists no ReLU expression with reluCount ≤ ⌈log₂(1/ε)⌉ − 2 and rational parameters that approximates π within ε for all ε < 1/10.

**Test**: For ε = 10⁻⁶, the conjecture predicts that at least ⌈log₂(10⁶)⌉ − 2 = 18 ReLU operations are needed. Construct all possible ReLU expressions with 17 or fewer operations and rational parameters of bounded size, and check if any achieve 10⁻⁶ accuracy.

**Note**: This conjecture is about *non-trivial* ReLU use — it excludes the trivial strategy of using a single const(q) node with q ≈ π, which requires 0 ReLU operations but relies on large-denominator rational parameters.

## 7. Cross-Connection to Existing Catalog

Our piece count theorem `pow_le_maxPieces` directly extends the neural network expressiveness results in the Catalog's `relu_network_lipschitz_depth` (from `Cryptography/TropicalCryptoRobustnessBridge.lean`), which establishes that ReLU networks with bounded weights are Lipschitz with constant W^d. Our result provides the complementary expressiveness bound: depth-d networks can express functions with 2^d pieces, showing that the Lipschitz upper bound and the expressiveness lower bound are both exponential in depth.

The Leibniz series connection also extends `partial_sums_converge` from `Physics/TheorySpacePerturbation.lean`, providing a concrete instance of partial sum convergence with explicit error bounds.

## 8. Future Work

1. **Irrationality measure bounds**: Formally verify that μ(π) ≤ 7.6063, yielding quantitative lower bounds on rational approximation quality.

2. **Depth-width tradeoff for sums**: Formalize that a depth-d, width-w network can sum w^d terms, giving explicit depth bounds for Leibniz approximation.

3. **Algebraic vs. transcendental separation**: Prove that the Diophantine spectrum of algebraic irrationals decays as D⁻² (Roth's theorem) while transcendental numbers can decay faster.

4. **Tropical geometry connection**: The piecewise linear structure of ReLU networks is precisely the geometry studied in tropical mathematics, connecting our framework to the Catalog's tropical algebra results.

## References

1. Leibniz, G.W. (1674). *De vera proportione circuli ad quadratum circumscriptum in numeris rationalibus*.
2. Niven, I. (1947). A simple proof that π is irrational. *Bulletin of the AMS*, 53(6), 509.
3. Roth, K.F. (1955). Rational approximations to algebraic numbers. *Mathematika*, 2(1), 1–20.
4. Montúfar, G.F., et al. (2014). On the number of linear regions of deep neural networks. *NeurIPS*.
5. Telgarsky, M. (2016). Benefits of depth in neural networks. *COLT*.
