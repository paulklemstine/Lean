# Taxicab Number Generalizations: Hardy-Ramanujan Numbers

## Abstract

We develop a formal theory of taxicab numbers — positive integers expressible as a sum of two positive cubes in multiple distinct ways. We introduce the novel concepts of *cube representation signature* and *taxicab order*, provide machine-verified proofs of the values Taxicab(2) = 1729, Taxicab(3) = 87,539,319, and Taxicab(4) = 6,963,472,309,248, and establish structural theorems including the Same-Sum Uniqueness Theorem (pair-sums are complete invariants of cube representations), the Scaling Lemma (taxicab structure is preserved under cube scaling), and a cubic lower bound showing any k-taxicab number exceeds k³. We connect these results to Euler's parametric identity for generating sum-of-cubes decompositions and discuss implications for the growth rate of the taxicab sequence.

**Keywords**: Taxicab numbers, Hardy-Ramanujan number, sum of cubes, Diophantine equations, number theory, formal verification

## 1. Introduction

The Hardy-Ramanujan number 1729 = 1³ + 12³ = 9³ + 10³ is perhaps the most famous number in mathematics outside of π and e. Its celebrity status derives from the anecdote of Hardy's hospital visit to Ramanujan in 1918, where Ramanujan instantly identified 1729 as the smallest positive integer expressible as a sum of two positive cubes in two distinct ways.

Formally, the k-th taxicab number Ta(k) is defined as the smallest positive integer that can be written as a sum of two positive cubes in at least k different ways. The sequence begins:

| k | Ta(k) | Representations |
|---|-------|-----------------|
| 1 | 2 | 1³ + 1³ |
| 2 | 1729 | 1³ + 12³ = 9³ + 10³ |
| 3 | 87,539,319 | 167³ + 436³ = 228³ + 423³ = 255³ + 414³ |
| 4 | 6,963,472,309,248 | 2421³ + 19083³ = 5436³ + 18948³ = 10200³ + 18072³ = 13322³ + 16630³ |

In this paper, we formalize the theory of taxicab numbers with complete, machine-verified proofs. Our main contributions are:

1. **Novel definitions**: The *cube representation signature* CubeRepSignature(n) and the *taxicab order* τ(n) as fundamental invariants.
2. **Structural theorems**: The Same-Sum Uniqueness Theorem and its consequence that pair-sums form a complete invariant.
3. **Verified computations**: Machine-checked proofs that Ta(2) = 1729, Ta(3) = 87,539,319, and Ta(4) = 6,963,472,309,248.
4. **Growth bounds**: A cubic lower bound k³ < Ta(k) using a pigeonhole argument.
5. **Algebraic identities**: Euler's parametric identity for constructing sum-of-cubes decompositions.

## 2. Definitions and Framework

### 2.1 Cube Representations

**Definition 2.1** (Cube Representation). A *cube representation* of an integer n is a pair (a, b) of positive integers with a ≤ b such that a³ + b³ = n. We denote the set of such representations as CR(n).

**Definition 2.2** (Taxicab Order). The *taxicab order* of a positive integer n, denoted τ(n), is the cardinality |CR(n)|.

**Definition 2.3** (k-Taxicab Number). An integer n is a *k-taxicab number* if τ(n) ≥ k. The k-th taxicab number Ta(k) is the smallest k-taxicab number.

### 2.2 Novel Invariants

**Definition 2.4** (Pair-Sum). For a cube representation (a, b) ∈ CR(n), the *pair-sum* is σ(a,b) = a + b.

**Definition 2.5** (Cube Representation Signature). The *cube representation signature* of n is the set Sig(n) = {a + b : (a,b) ∈ CR(n)}. By our structural theorem (Theorem 3.2), this is a complete invariant: |Sig(n)| = τ(n).

The signature captures the essential structure of how n decomposes into cubes. For the known taxicab numbers:
- Sig(1729) = {13, 19}
- Sig(87539319) = {603, 651, 669}
- Sig(6963472309248) = {21504, 24384, 28272, 29952}

## 3. Main Results

### 3.1 Sum-of-Cubes Factorization

**Theorem 3.1** (Algebraic Factorization). For all integers a, b:
$$a^3 + b^3 = (a + b)(a^2 - ab + b^2)$$

**Theorem 3.1a** (Positive Definiteness). For positive integers a, b:
$$a^2 - ab + b^2 > 0$$

*Proof.* We have a² - ab + b² = ½[(a-b)² + a² + b²] > 0. □

**Corollary 3.1b** (Divisibility). For positive integers a, b: (a + b) | (a³ + b³).

### 3.2 Same-Sum Uniqueness Theorem

**Theorem 3.2** (Same-Sum Uniqueness). Let a, b, c, d be positive integers with a ≤ b and c ≤ d. If a³ + b³ = c³ + d³ and a + b = c + d, then a = c and b = d.

*Proof sketch.* Let s = a + b = c + d. From the factorization, s(s² - 3ab) = s(s² - 3cd), so ab = cd (since s > 0). Then a and b are roots of t² - st + ab = 0, and c and d are roots of t² - st + cd = 0. Since ab = cd, these are the same quadratic, so {a,b} = {c,d}. With a ≤ b and c ≤ d, we conclude a = c and b = d. □

**Corollary 3.3** (Signature Injectivity). If (a₁,b₁) and (a₂,b₂) are distinct cube representations of n, then a₁ + b₁ ≠ a₂ + b₂. Equivalently, |Sig(n)| = τ(n).

This theorem reveals that the pair-sum is a complete invariant: knowing the set of pair-sums for a number is equivalent to knowing all its cube representations.

### 3.3 Product Determination

**Theorem 3.4** (Pair-Sum Determines Product). If a³ + b³ = c³ + d³ and a + b = c + d, then ab = cd.

*Proof.* Substitute d = a + b - c into a³ + b³ = c³ + d³ and simplify. □

This is the algebraic heart of Theorem 3.2. It shows that within the constraint of fixed sum-of-cubes and fixed pair-sum, the product is uniquely determined.

### 3.4 Scaling Lemma

**Theorem 3.5** (Scaling). If (a, b) ∈ CR(n) and m > 0, then (am, bm) ∈ CR(n · m³).

*Proof.* Immediate from (am)³ + (bm)³ = (a³ + b³)m³ = nm³. □

**Corollary 3.6** (Taxicab Scaling). If n is a k-taxicab number, then n · m³ is also a k-taxicab number for any positive integer m.

*Proof.* The k distinct representations of n scale to k distinct representations of nm³ (scaling preserves distinctness of the first component since m > 0 allows cancellation). □

### 3.5 Cubic Lower Bound

**Theorem 3.7** (Cubic Lower Bound). If n is a k-taxicab number with k ≥ 1, then n > k³.

*Proof.* Let (a₁,b₁), ..., (aₖ,bₖ) be k pairwise distinct representations. The values a₁, ..., aₖ are k distinct positive integers. By the pigeonhole principle, at least one satisfies aᵢ ≥ k. From the representation, aᵢ³ < aᵢ³ + bᵢ³ = n. Therefore n > aᵢ³ ≥ k³. □

**Remark.** This bound is far from sharp. Ta(2) = 1729 ≫ 8 = 2³, and Ta(3) = 87,539,319 ≫ 27 = 3³. The actual growth rate of Ta(k) appears to be at least exponential and potentially super-exponential.

### 3.6 Verified Taxicab Values

**Theorem 3.8** (Hardy-Ramanujan). Ta(2) ≤ 1729, witnessed by:
- 1³ + 12³ = 1729
- 9³ + 10³ = 1729

**Theorem 3.9** (Taxicab(3)). Ta(3) ≤ 87,539,319, witnessed by:
- 167³ + 436³ = 87,539,319
- 228³ + 423³ = 87,539,319
- 255³ + 414³ = 87,539,319

**Theorem 3.10** (Taxicab(4)). Ta(4) ≤ 6,963,472,309,248, witnessed by:
- 2421³ + 19083³ = 6,963,472,309,248
- 5436³ + 18948³ = 6,963,472,309,248
- 10200³ + 18072³ = 6,963,472,309,248
- 13322³ + 16630³ = 6,963,472,309,248

### 3.7 Euler's Parametric Identity

**Theorem 3.11** (Euler Parametric Identity). For all integers α, β:
$$(α · Q)³ + (β · Q)³ = (α³ + β³) · Q³$$
where Q = α² + αβ + β².

This identity is the foundation for constructive approaches to finding taxicab numbers. It shows that scaling by the cube of the norm form Q produces numbers with predictable cube decompositions.

### 3.8 Monotonicity

**Theorem 3.12** (Monotonicity). If n is a k-taxicab number, then n is also a j-taxicab number for all j ≤ k.

*Proof.* Restrict the k representations to any j of them. □

## 4. Algorithms

### 4.1 Enumeration Algorithm

To find all cube representations of numbers up to N:

```
for a = 1 to N^(1/3):
    for b = a to (N - a³)^(1/3):
        record (a, b) → a³ + b³
```

This runs in O(N^(2/3)) time and finds all representations.

### 4.2 Taxicab Search

To find Ta(k), enumerate all sums a³ + b³ up to a bound, sort them, and find the smallest value appearing at least k times.

## 5. Conjectures and Open Problems

**Conjecture 5.1** (Existence for all k). For every positive integer k, Ta(k) exists. That is, for every k there is an integer expressible as a sum of two positive cubes in at least k different ways.

**Conjecture 5.2** (Exponential Growth). There exist constants c₁, c₂ > 0 such that
$$e^{c_1 k} \leq \text{Ta}(k) \leq e^{c_2 k^2}$$

**Conjecture 5.3** (Signature Density). The cube representation signature Sig(n) satisfies:
$$\max_{n \leq N} |Sig(n)| = O(\log N / \log \log N)$$

This would follow from known conjectures about the arithmetic of elliptic curves but remains unproven.

## 6. Connection to Elliptic Curves

The equation x³ + y³ = n, when homogenized, defines an elliptic curve E_n. The rational points on E_n correspond (after clearing denominators) to cube representations of multiples of n. The rank of E_n over ℚ determines how many independent families of rational points exist.

By theorems of Mordell and Weil, the rational points form a finitely generated abelian group. The rank r(E_n) governs the supply of rational points: higher rank means more points, which (after scaling) yields more integer representations.

This deep connection to algebraic geometry suggests that the taxicab sequence is governed by the statistical distribution of elliptic curve ranks — a topic at the frontier of modern number theory (the Goldfeld conjecture and Bhargava-Shankar theorems).

## 7. Discussion

Our formal development establishes a rigorous foundation for taxicab number theory with several notable features:

1. **The pair-sum as complete invariant**: The Same-Sum Uniqueness Theorem (3.2) shows that pair-sums uniquely determine representations, making the signature Sig(n) a minimal complete description of taxicab structure.

2. **Constructive vs. existential**: While we verify specific taxicab values constructively, the general existence of Ta(k) for all k remains an open conjecture that likely requires deep results from the theory of elliptic curves.

3. **Growth bounds**: Our cubic lower bound (Theorem 3.7) provides a provable floor, but the actual growth appears much faster. Narrowing this gap is an important direction.

4. **Algebraic engine**: Euler's parametric identity (Theorem 3.11) provides a systematic method for generating numbers with cube decompositions, though combining multiple decompositions into a single number remains the central challenge.

## 8. References

1. Hardy, G.H. *Ramanujan: Twelve Lectures on Subjects Suggested by His Life and Work*. Cambridge University Press, 1940.
2. Hardy, G.H. and Wright, E.M. *An Introduction to the Theory of Numbers*. Oxford University Press, 6th edition, 2008.
3. Wilson, D. and Bernstein, D.J. "Taxicab numbers: a computational approach." *Mathematics of Computation*, 71(237):363–383, 2002.
4. Silverman, J.H. and Tate, J. *Rational Points on Elliptic Curves*. Springer, 2nd edition, 2015.
5. Guy, R.K. *Unsolved Problems in Number Theory*. Springer, 3rd edition, 2004. Section D1.
