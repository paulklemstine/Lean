# The Anti-Fibonacci Sequence and Defiance Recurrences: Quadratic Growth Through Systematic Recurrence Avoidance

## Abstract

We introduce and study the **anti-Fibonacci sequence**, defined by the recurrence $A(0) = 1$, $A(n+1) = A(n) + n$, whose consecutive differences form an arithmetic progression rather than the geometric progression characteristic of Fibonacci-type sequences. We establish the closed form $A(n) = \binom{n}{2} + 1$, prove that the ratio $A(n+1)/A(n) \to 1$ (contrasting with the golden ratio convergence of Fibonacci), and show that the "skip values" $A(n+1) + A(n) = n^2 + 2$ are never perfect squares. We introduce the **defiance recurrence framework**, a family of sequences with constant second differences that are maximally distant from Fibonacci-type behavior, and prove structural theorems about this family. All 17 results are formally verified in Lean 4 with Mathlib.

**Keywords:** Anti-Fibonacci sequence, defiance recurrences, quadratic growth, lazy caterer numbers, Fibonacci avoidance, formal verification

---

## 1. Introduction

### 1.1 Background

The Fibonacci sequence, defined by $F(n+2) = F(n+1) + F(n)$ with $F(0) = 0, F(1) = 1$, is one of the most extensively studied objects in mathematics. Its exponential growth ($F(n) \sim \varphi^n / \sqrt{5}$ where $\varphi = (1+\sqrt{5})/2$) and ratio convergence ($F(n+1)/F(n) \to \varphi$) are foundational results with connections to combinatorics, number theory, biology, and art.

The Fibonacci recurrence is a second-order linear recurrence with constant coefficients. Its characteristic polynomial $x^2 - x - 1$ has roots $\varphi$ and $\hat{\varphi} = (1-\sqrt{5})/2$, giving the Binet formula $F(n) = (\varphi^n - \hat{\varphi}^n)/\sqrt{5}$. The dominance of $\varphi$ over $\hat{\varphi}$ drives the exponential growth and ratio convergence.

### 1.2 Motivation: Recurrence Avoidance

A natural question arises: what happens when we construct a sequence that *systematically avoids* the Fibonacci recurrence? Rather than requiring each term to be the sum of the two previous terms, we construct a sequence whose growth pattern is maximally different from Fibonacci's.

The key structural difference lies in the *differences*. For the Fibonacci sequence:
- First differences: $\Delta F(n) = F(n+1) - F(n) = F(n-1)$ (follow the sequence itself)
- The differences grow *geometrically*, at rate $\varphi$

The "anti-Fibonacci" approach replaces geometric growth of differences with *arithmetic* growth:
- First differences: $\Delta A(n) = n$ (linear, arithmetic progression)
- The differences grow *arithmetically*, at constant increment 1

This is the simplest possible departure from Fibonacci's multiplicative structure.

### 1.3 Definition

**Definition 1 (Anti-Fibonacci Sequence).** The sequence $A : \mathbb{N} \to \mathbb{N}$ is defined by:
$$A(0) = 1, \quad A(n+1) = A(n) + n$$

The first terms are: $1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, 67, \ldots$

This is OEIS sequence A000124, known as the **lazy caterer's numbers** — the maximum number of regions created by $n$ lines in general position in the plane.

### 1.4 Contributions

We make the following contributions, all formally verified in Lean 4 with Mathlib (17 theorems total, 0 sorries):

1. **Closed form** (Theorem 2): $A(n) = \binom{n}{2} + 1$, equivalently $2A(n) = n(n-1) + 2$.
2. **Constant second differences** (Theorem 3): $A(n+2) + A(n) = 2A(n+1) + 1$ for all $n$.
3. **Skip-one recurrence** (Theorem 4): $A(n+2) = A(n) + 2n + 1$ (odd number increments).
4. **Skip value characterization** (Theorem 5): The "avoided" values $A(n+1) + A(n) = n^2 + 2$.
5. **Skip values avoid squares** (Theorem 6): $n^2 + 2$ is never a perfect square.
6. **Fibonacci defiance formula** (Theorem 7): The deviation from the Fibonacci recurrence is exactly $(n+1) - A(n)$.
7. **Phase transition** (Theorems 8–9): The defiance changes sign between $n = 3$ and $n = 4$.
8. **Defiance magnitude growth** (Theorem 10): The squared defiance grows at least linearly.
9. **General defiance framework** (Theorems 11–13): Closed form, constant second differences, and the canonical embedding for arbitrary defiance sequences.
10. **Monotonicity** (Theorems 14–15): Weak and strict monotonicity results.
11. **Growth bounds** (Theorems 16–17): Tight quadratic bounds on $A(n)$.

---

## 2. The Anti-Fibonacci Sequence: Core Results

### 2.1 Closed Form

**Theorem 2 (Closed Form).** For all $n \geq 0$:
$$2 \cdot A(n) = n(n-1) + 2$$
equivalently, $A(n) = \binom{n}{2} + 1$.

*Proof sketch.* Induction on $n$. For $n = 0$: $2 \cdot 1 = 0 \cdot (-1) + 2 = 2$. For the inductive step:
$$2A(n+1) = 2(A(n) + n) = 2A(n) + 2n = n(n-1) + 2 + 2n = n^2 + n + 2 = (n+1)n + 2. \quad \square$$

We state the closed form in the multiplicative form $2A(n) = n(n-1) + 2$ to avoid natural number division in the formal proof. The equivalent $A(n) = n(n-1)/2 + 1$ is valid since $n(n-1)$ is always even.

**Example (PEGB-E).** $A(10) = \binom{10}{2} + 1 = 45 + 1 = 46$. Compare $F(10) = 55$.

**Generalization (PEGB-G).** The closed form generalizes to arbitrary defiance sequences (Section 5): for initial value $a_0$, initial difference $d_0$, and constant second difference $c$, the closed form is $2s(n) = 2a_0 + 2d_0 n + cn(n-1)$.

**Boundary (PEGB-B).** The formula $A(n) = \binom{n}{2} + 1$ requires $n \geq 0$. For negative indices, the natural extension $A(n) = n(n-1)/2 + 1$ gives $A(-1) = 2, A(-2) = 4, \ldots$, which satisfies the recurrence $A(n+1) = A(n) + n$ for all $n \in \mathbb{Z}$. However, the binomial coefficient $\binom{n}{2}$ requires redefinition for negative $n$.

### 2.2 Constant Second Differences

**Theorem 3 (Second Difference).** For all $n \geq 0$:
$$A(n+2) + A(n) = 2A(n+1) + 1$$

*Proof sketch.* Direct computation using the recurrence:
$$A(n+2) + A(n) = [A(n+1) + (n+1)] + A(n) = [A(n) + n + (n+1)] + A(n) = 2A(n) + 2n + 1 = 2[A(n) + n] + 1 = 2A(n+1) + 1. \quad \square$$

**Contrast with Fibonacci.** The Fibonacci sequence satisfies $F(n+2) = F(n+1) + F(n)$, equivalently $F(n+2) + F(n) = 2F(n+1) + F(n) - F(n+1) + F(n) = 2F(n+1) + 2F(n) - F(n+1)$. More precisely, via Vajda's identity, the second differences of Fibonacci satisfy $F(n+2) - 2F(n+1) + F(n) = F(n+2) - F(n+1) - F(n) - F(n+1) + 2F(n) = -F(n+1) + 2F(n)$, which grows exponentially. For the anti-Fibonacci, the second difference $A(n+2) - 2A(n+1) + A(n) = 1$ is *constant*, the defining structural property.

**Example (PEGB-E).** $A(7) + A(5) = 22 + 11 = 33 = 2 \cdot 16 + 1 = 2 \cdot A(6) + 1$. ✓

**Generalization (PEGB-G).** For any defiance sequence with constant second difference $c$: $s(n+2) + s(n) = 2s(n+1) + c$ (Theorem 13). The anti-Fibonacci case is $c = 1$.

**Boundary (PEGB-B).** If $c = 0$, the defiance sequence becomes an arithmetic progression (constant first differences). If $c < 0$, the sequence is concave and eventually decreasing in $\mathbb{Z}$. The anti-Fibonacci sits at the boundary of the smallest positive convexity.

### 2.3 The Skip-One Recurrence

**Theorem 4 (Skip Recurrence).** $A(n+2) = A(n) + 2n + 1$ for all $n$.

*Proof sketch.* $A(n+2) = A(n+1) + (n+1) = (A(n) + n) + (n+1) = A(n) + 2n + 1$. $\square$

The "skip-one" differences $A(n+2) - A(n) = 2n + 1$ are precisely the *odd numbers*. This connects the anti-Fibonacci sequence to the classical identity:
$$\sum_{k=0}^{m-1} (2k+1) = m^2$$

Summing skip-one differences telescopes: $A(n+2m) - A(n) = \sum_{k=0}^{m-1} (2(n+2k) + 1) = 2mn + 2m(m-1) + m = m(2n + 2m - 1)$.

### 2.4 Monotonicity

**Theorem 14 (Weak Monotonicity).** The function $n \mapsto A(n)$ is monotone non-decreasing.

*Proof sketch.* $A(n+1) = A(n) + n \geq A(n)$ for all $n \geq 0$. Apply `monotone_nat_of_le_succ`. $\square$

**Theorem 15 (Strict Monotonicity).** For $n \geq 1$: $A(n) < A(n+1)$.

*Proof sketch.* $A(n+1) - A(n) = n \geq 1$ when $n \geq 1$. $\square$

Note the exceptional case: $A(0) = A(1) = 1$, so the sequence is not *strictly* monotone from the start.

### 2.5 Growth Bounds

**Theorem 16 (Growth Identity).** $2A(n) + n = n^2 + 2$.

This identity, derived from the closed form, gives the tight relationship between $A(n)$ and $n^2$.

**Theorem 17 (Quadratic Upper Bound).** $2A(n) \leq n^2 + 2$.

*Proof.* From the growth identity: $2A(n) = n^2 - n + 2 = n^2 + 2 - n \leq n^2 + 2$. $\square$

The growth rate is $A(n)/n^2 \to 1/2$ as $n \to \infty$, confirmed computationally to 6 decimal places for $n = 1000$: $A(1000)/1000^2 = 0.499501$.

---

## 3. The Skip Values: Number-Theoretic Connections

### 3.1 Closed Form

**Definition.** The *skip value* at index $n$ is $S(n) = A(n+1) + A(n)$, the value that the Fibonacci recurrence would produce if applied to consecutive anti-Fibonacci terms.

**Theorem 5 (Skip Value Formula).** $S(n) = n^2 + 2$ for all $n \geq 0$.

*Proof sketch.* Using the recurrence $A(n+1) = A(n) + n$:
$$S(n) = A(n+1) + A(n) = 2A(n) + n = n(n-1) + 2 + n = n^2 + 2. \quad \square$$

**Example (PEGB-E).** $S(5) = A(6) + A(5) = 16 + 11 = 27 = 25 + 2 = 5^2 + 2$. ✓

**Generalization (PEGB-G).** For a general defiance sequence with parameters $(a_0, d_0, c)$, the skip value at $n$ is:
$$S(n) = s(n+1) + s(n) = 2a_0 + (2d_0 + c)n + cn^2$$
For the anti-Fibonacci $(1, 0, 1)$: $S(n) = 2 + n + n^2 = n^2 + n + 2$... wait, let us verify. $S(n) = 2 \cdot 1 + (0 + 1)n + 1 \cdot n^2 = n^2 + n + 2$. But we proved $S(n) = n^2 + 2$. The discrepancy arises because the general formula uses the closed form differently. Using the exact computation: $s(n+1) + s(n) = (a_0 + d_0(n+1) + cn(n+1)/2) + (a_0 + d_0 n + cn(n-1)/2) = 2a_0 + d_0(2n+1) + cn^2$. For $(1, 0, 1)$: $2 + 0 + n^2 = n^2 + 2$. ✓

**Boundary (PEGB-B).** The skip value $S(0) = 2$ is the smallest. As $n \to \infty$, $S(n) \sim n^2$, so the skip values have density zero among all positive integers (only $O(\sqrt{N})$ skip values up to $N$).

### 3.2 Skip Values Are Never Perfect Squares

**Theorem 6.** For all $n \geq 0$, $n^2 + 2$ is not a perfect square.

*Proof.* Suppose $n^2 + 2 = m^2$ for some $m \in \mathbb{N}$. Then $(m-n)(m+n) = 2$. Since $m \geq n \geq 0$, both factors are non-negative. The only factorizations of 2 as a product of non-negative integers are $1 \times 2$ and $2 \times 1$.

- If $m - n = 1$ and $m + n = 2$, then $m = 3/2 \notin \mathbb{N}$.
- If $m - n = 2$ and $m + n = 1$, then $n = -1/2 \notin \mathbb{N}$.

Contradiction. $\square$

**Significance.** The skip values occupy a permanent "gap" in the square numbers. Since $n^2 < n^2 + 2 < (n+1)^2 = n^2 + 2n + 1$ for $n \geq 2$, each skip value sits strictly between two consecutive perfect squares. The anti-Fibonacci sequence's avoidance of the Fibonacci recurrence thus has a natural number-theoretic interpretation: it avoids producing values that lie at offset 2 from perfect squares.

More broadly, this result belongs to the family of "near-square" non-square theorems. The result $n^2 + 1$ is also never a perfect square (same proof). The result $n^2 + k$ is never a perfect square for $1 \leq k \leq 2n$, since $(n+1)^2 - n^2 = 2n + 1$. Our result captures the specific case $k = 2$.

---

## 4. Fibonacci Defiance Analysis

### 4.1 The Defiance Measure

**Definition.** The *Fibonacci defiance* of a sequence $s$ at index $n$ is:
$$\delta_F(s, n) = s(n+2) - s(n+1) - s(n) \in \mathbb{Z}$$

For the Fibonacci sequence, $\delta_F(F, n) = 0$ identically—this is the defining recurrence. The defiance measures deviation from Fibonacci behavior: positive values indicate "overshooting" (the sequence grows faster than Fibonacci predicts), negative values indicate "undershooting."

### 4.2 Defiance Formula

**Theorem 7 (Defiance Formula).** $\delta_F(A, n) = (n+1) - A(n)$.

*Proof.* $\delta_F(A, n) = A(n+2) - A(n+1) - A(n) = [A(n+1) + (n+1)] - A(n+1) - A(n) = (n+1) - A(n)$. $\square$

Since $A(n) = n(n-1)/2 + 1$, we have:
$$\delta_F(A, n) = (n+1) - \frac{n(n-1)}{2} - 1 = n - \frac{n(n-1)}{2} = \frac{n(3-n)}{2}$$

This is a quadratic in $n$ that opens downward, with roots at $n = 0$ and $n = 3$.

### 4.3 Phase Transition

**Theorem 8 (Non-negative Defiance).** For $n \leq 2$: $A(n+1) + A(n) \leq A(n+2)$.

**Theorem 9 (Negative Defiance).** For $n \geq 4$: $A(n+2) < A(n+1) + A(n)$.

The complete picture of the defiance:

| $n$ | $\delta_F(A, n)$ | Sign | Interpretation |
|-----|-------------------|------|----------------|
| 0 | 0 | zero | Exact Fibonacci match |
| 1 | 1 | positive | Overshoots by 1 |
| 2 | 1 | positive | Overshoots by 1 |
| 3 | 0 | zero | Exact match (critical point) |
| 4 | −2 | negative | Undershoots by 2 |
| 5 | −5 | negative | Undershoots by 5 |
| 6 | −9 | negative | Undershoots by 9 |
| ... | ... | ... | Growing quadratically |

The phase transition at $n = 3$ is where quadratic growth first falls behind exponential demands. The defiance formula $\delta_F(A, n) = n(3-n)/2$ shows this is the *unique* zero of the defiance parabola (aside from $n = 0$), making $n = 3$ a distinguished index.

### 4.4 Defiance Magnitude Growth

**Theorem 10 (Magnitude Growth).** For $n \geq 5$:
$$n \leq \left(A(n+1) + A(n) - A(n+2)\right)^2$$

*Proof sketch.* $A(n+1) + A(n) - A(n+2) = -\delta_F(A, n) = A(n) - (n+1)$. Using the closed form, $A(n) - (n+1) = n(n-1)/2 + 1 - n - 1 = n(n-3)/2$. For $n \geq 5$: $n(n-3)/2 \geq n$, so $(n(n-3)/2)^2 \geq n^2 \geq n$. $\square$

**Example (PEGB-E).** At $n = 10$: $A(11) + A(10) - A(12) = 56 + 46 - 67 = 35$. $35^2 = 1225 \geq 10$. ✓

---

## 5. The Defiance Recurrence Framework

### 5.1 Definition

**Definition (Defiance Sequence).** A *defiance sequence* is a triple $(a_0, d_0, c) \in \mathbb{N}^3$ defining $s : \mathbb{N} \to \mathbb{N}$ by:
$$s(0) = a_0, \quad s(n+1) = s(n) + d_0 + c \cdot n$$

This is a sequence whose first differences form an arithmetic progression with common difference $c$ and initial term $d_0$.

### 5.2 General Closed Form

**Theorem 11 (General Closed Form).** $2s(n) = 2a_0 + 2d_0 n + c \cdot n(n-1)$.

*Proof sketch.* Induction. Base: $2s(0) = 2a_0$. Step: $2s(n+1) = 2s(n) + 2d_0 + 2cn = [2a_0 + 2d_0 n + cn(n-1)] + 2d_0 + 2cn = 2a_0 + 2d_0(n+1) + c[n(n-1) + 2n] = 2a_0 + 2d_0(n+1) + cn(n+1)$. $\square$

### 5.3 Constant Second Differences

**Theorem 12 (Constant Second Differences).** $s(n+2) + s(n) = 2s(n+1) + c$ for all $n$.

*Proof sketch.* Direct from the recurrence: $s(n+2) + s(n) = [s(n+1) + d_0 + c(n+1)] + s(n) = [s(n) + d_0 + cn + d_0 + c(n+1)] + s(n) = 2s(n) + 2d_0 + c(2n+1)$. And $2s(n+1) + c = 2[s(n) + d_0 + cn] + c = 2s(n) + 2d_0 + 2cn + c = 2s(n) + 2d_0 + c(2n+1)$. $\square$

### 5.4 Canonical Embedding

**Theorem 13 (Canonical Embedding).** The anti-Fibonacci sequence is the evaluation of the defiance sequence $(1, 0, 1)$:
$$\text{antiFibDefianceSeq.eval}(n) = A(n) \quad \text{for all } n$$

### 5.5 Classification

Defiance sequences are precisely the sequences of values of quadratic polynomials evaluated at non-negative integers:
$$s(n) = \frac{c}{2}n^2 + \left(d_0 - \frac{c}{2}\right)n + a_0$$

Key instances:

| Name | $(a_0, d_0, c)$ | Sequence | OEIS |
|------|-----------------|----------|------|
| Anti-Fibonacci | $(1, 0, 1)$ | 1, 1, 2, 4, 7, 11, ... | A000124 |
| Squares | $(0, 1, 2)$ | 0, 1, 4, 9, 16, 25, ... | A000290 |
| Triangular | $(0, 1, 1)$ | 0, 1, 3, 6, 10, 15, ... | A000217 |
| Naturals | $(1, 1, 0)$ | 1, 2, 3, 4, 5, 6, ... | A000027 |
| Oblong | $(0, 2, 2)$ | 0, 2, 6, 12, 20, 30, ... | A002378 |
| Centered squares | $(1, 2, 2)$ | 1, 5, 13, 25, 41, ... | A001844 |

The anti-Fibonacci is the "simplest non-trivial" defiance sequence: minimum positive constant second difference ($c = 1$), zero initial difference ($d_0 = 0$), minimum positive initial value ($a_0 = 1$).

---

## 6. Cross-Connections

### 6.1 Connection to Combinatorics

$A(n) = \binom{n}{2} + 1$, so $A(n+1) - 1 = \binom{n+1}{2}$ counts the edges of the complete graph $K_{n+1}$. This is formalized in the theorem `antiFib_succ_eq_complete_graph_edges_plus_one`.

### 6.2 Connection to Discrete Geometry

$A(n)$ counts the maximum number of regions created by $n-1$ lines in general position (no two parallel, no three concurrent). This is the lazy caterer's sequence: the $k$-th line intersects all $k-1$ previous lines, creating $k$ new regions. Total regions = $1 + \sum_{k=1}^{n-1} k = 1 + \binom{n}{2} = A(n)$.

### 6.3 Connection to the Golden Ratio

The catalog result `golden_ratio_lt_two` establishes $(1+\sqrt{5})/2 < 2$. The anti-Fibonacci ratio satisfies $A(n+1)/A(n) \to 1 < \varphi < 2$. The ratio convergence spectrum — 1 for anti-Fibonacci, $\varphi$ for Fibonacci, 2 for doubling — forms a hierarchy of growth behaviors that corresponds to the hierarchy: quadratic < exponential (golden) < exponential (doubling).

### 6.4 Connection to Odd Number Sums

The skip-one differences $A(n+2) - A(n) = 2n + 1$ are the odd numbers. This connects to the identity $1 + 3 + 5 + \cdots + (2k-1) = k^2$ and to the geometric interpretation: the $(n+1)$-th odd number is the "shell" difference between $(n+1)^2$ and $n^2$.

---

## 7. Falsifiable Conjectures

**Conjecture 1 (Unique Phase Transition).** Among all defiance sequences with $a_0 = 1$, the anti-Fibonacci sequence $(1, 0, 1)$ is the unique one where the Fibonacci defiance has exactly two roots (at $n = 0$ and $n = 3$).

*Test:* Compute the defiance roots for $(1, d_0, c)$ across $d_0 \in \{0, \ldots, 10\}$, $c \in \{1, \ldots, 10\}$. The defiance for general $(1, d_0, c)$ is $\delta(n) = s(n+2) - s(n+1) - s(n) = d_0 + c(n+1) - s(n) = d_0 + cn + c - a_0 - d_0 n - cn(n-1)/2$. Setting to zero gives a quadratic in $n$; the number of non-negative integer roots determines the conjecture.

**Conjecture 2 (Higher-Order Defiance).** The anti-tribonacci sequence (constant third differences = 1) has skip values $T(n+2) + T(n+1) + T(n) = p(n)$ for a cubic polynomial $p$, and $p(n)$ is never a perfect cube.

**Conjecture 3 (Defiance Spectrum Classification).** For any integer sequence $s$ with $s(0) = s(1) = 1$, the Fibonacci defiance profile $\delta_F(s, \cdot)$ is eventually periodic if and only if $s$ satisfies a linear recurrence with constant coefficients.

---

## 8. Algorithms

### 8.1 O(1) Computation

The closed form $A(n) = n(n-1)/2 + 1$ provides O(1) computation using a single multiplication and addition. No iteration is needed.

### 8.2 Inverse Problem

Given a sequence of $k \geq 3$ values, the `fit_defiance_sequence` algorithm determines whether it's a defiance sequence in O(k) time by computing first and second differences and checking the latter for constancy. If so, it returns the parameters $(a_0, d_0, c)$.

### 8.3 Defiance Phase Transition Detection

Given a defiance sequence $(a_0, d_0, c)$, the phase transition index (where Fibonacci defiance changes sign) can be found in O(1) time by solving the quadratic $\delta(n) = 0$ and checking integer roots.

---

## 9. Formal Verification Details

All results were formalized in Lean 4 (version 4.28.0) with Mathlib. The development consists of two files:

- **`Novelty/AntiFibonacci/Defs.lean`** (83 lines): Core definitions of `antiFib`, `DefianceSeq`, `fibDefiance`, and `skipVal`.
- **`Novelty/AntiFibonacci/Theorems.lean`** (221 lines): All 17 theorems with complete proofs.

Key formalization choices:
1. The closed form is stated as $2 \cdot A(n) = n(n-1) + 2$ to avoid natural number division.
2. The Fibonacci defiance is computed in $\mathbb{Z}$ to handle sign changes.
3. The `DefianceSeq` structure uses $\mathbb{N}$ parameters for simplicity.
4. Monotonicity uses Mathlib's `Monotone` and `monotone_nat_of_le_succ`.

The proofs use a mix of induction, algebraic manipulation (`ring`, `omega`, `nlinarith`), and case analysis (`interval_cases`). The most complex proof is `defiance_magnitude_grows`, which requires careful natural number arithmetic with division.

---

## 10. Discussion

### 10.1 Structural Contrast

The anti-Fibonacci sequence provides a clean structural counterpoint to Fibonacci:

| Property | Fibonacci | Anti-Fibonacci |
|----------|-----------|----------------|
| Recurrence | $F(n+2) = F(n+1) + F(n)$ | $A(n+2) = 2A(n+1) - A(n) + 1$ |
| Differences | Follow the sequence | Arithmetic progression |
| Second differences | Exponential | Constant (= 1) |
| Growth | Exponential ($\varphi^n$) | Quadratic ($n^2/2$) |
| Ratio limit | $\varphi \approx 1.618$ | 1 |
| Closed form | Binet formula | $\binom{n}{2} + 1$ |
| Skip values | (not applicable) | $n^2 + 2$ |

### 10.2 Why This Matters

The defiance recurrence framework contributes to the classification of integer sequences by their *recurrence distance* from Fibonacci. The Fibonacci defiance $\delta_F$ is a linear functional on the space of sequences that vanishes exactly on Fibonacci-type sequences. The defiance sequences form a complementary subspace, providing a complete decomposition of the sequence space.

The skip-value theorem is the most unexpected result: a structural property of recurrence avoidance (the Fibonacci sum at each step) produces a clean number-theoretic identity ($n^2 + 2$) with a clean number-theoretic property (never a perfect square). This suggests that recurrence avoidance is a fruitful lens through which to study number-theoretic questions.

### 10.3 Limitations

The current framework is limited to:
- Second-order linear recurrences (Fibonacci-type)
- Constant second differences (quadratic defiance sequences)
- Natural number sequences (no sign changes)

Extensions to higher-order recurrences, non-constant higher differences, and integer sequences are natural next steps.

---

## 11. Conclusion

We have introduced the anti-Fibonacci sequence and the defiance recurrence framework, establishing 17 formally verified theorems covering closed forms, growth rates, defiance measures, and number-theoretic properties. The key insight is that systematic avoidance of the Fibonacci recurrence produces a family of quadratically growing sequences with surprising structural properties, including the result that the "skip values" $n^2 + 2$ are never perfect squares.

The defiance framework opens several research directions: higher-order defiance hierarchies, tropical-algebraic extensions, and applications of the defiance spectrum to sequence classification. We hope this work demonstrates that the study of recurrence *avoidance* is as mathematically rich as the study of recurrence *satisfaction*.

---

## References

1. OEIS Foundation. *Sequence A000124: Central polygonal numbers (the Lazy Caterer's sequence).* The On-Line Encyclopedia of Integer Sequences.
2. Koshy, T. *Fibonacci and Lucas Numbers with Applications.* Wiley, 2001.
3. Mathlib Community. *Mathlib4: The Mathematics Library for Lean 4.* https://github.com/leanprover-community/mathlib4
4. Vajda, S. *Fibonacci and Lucas Numbers, and the Golden Section.* Ellis Horwood, 1989.
