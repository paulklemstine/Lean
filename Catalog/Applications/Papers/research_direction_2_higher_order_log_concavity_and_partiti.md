# Higher-Order Log-Concavity: A Recursive Hierarchy for Discrete Sequences with Applications to Partition Functions

## Abstract

We introduce a hierarchy of **k-fold log-concavity** for positive sequences, defined recursively through the ratio sequence operator. A positive sequence is (k+1)-fold log-concave if it is log-concave and its ratio sequence is k-fold log-concave. We establish the foundational structural theory of this hierarchy:

1. **Recursive descent** (Theorem 1): k-fold log-concavity descends to ratio sequences.
2. **Tower theorem** (Theorem 2): k-fold log-concavity implies log-concavity of all iterated ratio sequences up to depth k−1.
3. **Product stability** (Theorem 4): the pointwise product of k-fold log-concave sequences is k-fold log-concave.
4. **Model family**: geometric sequences are k-fold log-concave for all k.
5. **Depth monotonicity**: higher depth implies all lower depths.

All theorems are formally verified in Lean 4 with the Mathlib library. We define a `RecursiveLorentzianSequence` structure bundling coefficient sequences with depth certificates, and prove a partition function factorization theorem: independent subsystems preserve higher-order concavity.

We conjecture that the recursive Lorentzian depth of a generating polynomial controls the k-fold log-concavity of its coefficient sequences, and provide computational evidence from binomial families, Ising models, and spanning tree enumerators.

**Keywords**: log-concavity, Lorentzian polynomials, partition functions, ratio sequences, discrete convexity, Ising model, mixing times

---

## 1. Introduction

### 1.1 Background and Motivation

Log-concavity of combinatorial sequences has been one of the most active areas of algebraic combinatorics over the past two decades. A finite sequence $(a_0, a_1, \ldots, a_n)$ of nonnegative real numbers is **log-concave** if $a_k^2 \geq a_{k-1} \cdot a_{k+1}$ for all interior indices $k$. This condition implies unimodality and has deep connections to algebraic geometry, matroid theory, and probability.

The landmark work of Brändén and Huh [BH20] introduced **Lorentzian polynomials** — multivariate polynomials whose Hessian matrices have at most one positive eigenvalue at every level of a recursive differentiation tree. This theory unified and extended numerous log-concavity results, including the resolution of the Mason conjecture for matroid basis counts.

However, log-concavity is a **binary** property: a sequence either satisfies the inequality or it does not. The recursive structure of Lorentzian polynomials suggests a richer possibility — that log-concavity has **depth**. The recursive differentiation tree has a natural depth parameter (the polynomial's degree minus 2), and this depth should correspond to a quantitative measure of "how log-concave" the coefficient sequence is.

### 1.2 Contributions

We formalize this intuition by introducing **k-fold log-concavity**, defined recursively through the ratio sequence operator. Our main contributions are:

1. **Clean definitions** of `PositiveSeq`, `LogConcaveN`, `RatioSeq`, `KFoldLogConcave`, and `IterRatio` suitable for formalization and computation.

2. **A complete structural theory** establishing that k-fold log-concavity forms a genuine filtration with good closure properties (Sections 3–4).

3. **A bridge to Lorentzian polynomial theory** via the `RecursiveLorentzianSequence` structure and the partition function factorization theorem (Section 5).

4. **Computational exploration** identifying depth profiles of binomial coefficients, Ising partition functions, and other combinatorial families (Section 6).

5. **A grand conjecture** connecting recursive Lorentzian depth to k-fold log-concavity (Section 7).

All formal results are machine-verified in Lean 4.

### 1.3 Related Work

Log-concavity of combinatorial sequences has a rich history. Key references include:

- **Brändén–Huh** [BH20]: Lorentzian polynomials and the resolution of multiple log-concavity conjectures.
- **Anari–Liu–Oveis Gharan–Vinzant** [ALOV19]: Log-concave polynomials and rapid mixing of Markov chains.
- **Stanley** [Sta89]: Log-concavity and unimodality in combinatorics.
- **Murota** [Mur03]: Discrete convex analysis and M-convexity.

The notion of higher-order or iterated log-concavity has appeared informally in the literature (e.g., "ultra-log-concavity" for binomial-normalized sequences), but a systematic recursive theory through ratio sequences, with formal verification, appears to be new.

---

## 2. Definitions and Notation

### 2.1 Core Definitions

**Definition 2.1** (Positive Sequence). A sequence $a : \mathbb{N} \to \mathbb{R}$ is **positive** if $a(n) > 0$ for all $n \in \mathbb{N}$.

$$\text{PositiveSeq}(a) \iff \forall n, \; a(n) > 0$$

**Definition 2.2** (Log-Concavity). A sequence $a : \mathbb{N} \to \mathbb{R}$ is **log-concave** if

$$a(n+1)^2 \geq a(n) \cdot a(n+2) \quad \text{for all } n \in \mathbb{N}.$$

**Definition 2.3** (Ratio Sequence). The **ratio sequence** of $a$ is

$$\text{RatioSeq}(a)(n) = \frac{a(n+1)}{a(n)}.$$

**Definition 2.4** (k-Fold Log-Concavity). Define $\text{KFoldLogConcave}(k, a)$ recursively:

- $\text{KFoldLogConcave}(0, a) \iff \text{PositiveSeq}(a)$
- $\text{KFoldLogConcave}(k+1, a) \iff \text{PositiveSeq}(a) \;\wedge\; \text{LogConcaveN}(a) \;\wedge\; \text{KFoldLogConcave}(k, \text{RatioSeq}(a))$

**Definition 2.5** (Iterated Ratio). The **m-th iterated ratio** is

$$\text{IterRatio}(0, a) = a, \qquad \text{IterRatio}(m+1, a) = \text{RatioSeq}(\text{IterRatio}(m, a)).$$

### 2.2 Lean Formalization

The definitions are formalized in Lean 4 as:

```lean
def PositiveSeq (a : ℕ → ℝ) : Prop := ∀ n, 0 < a n
def LogConcaveN (a : ℕ → ℝ) : Prop := ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)
def RatioSeq (a : ℕ → ℝ) : ℕ → ℝ := fun n => a (n + 1) / a n

def KFoldLogConcave : ℕ → (ℕ → ℝ) → Prop
  | 0, a => PositiveSeq a
  | k + 1, a => PositiveSeq a ∧ LogConcaveN a ∧ KFoldLogConcave k (RatioSeq a)
```

---

## 3. Structural Theory

### 3.1 Recursive Descent (Theorem 1)

**Theorem 3.1** (`KFoldLogConcave.ratio`). *If $a$ is $(k+1)$-fold log-concave, then $\text{RatioSeq}(a)$ is $k$-fold log-concave.*

*Proof.* This is the third conjunct of the recursive definition. ∎

While definitionally immediate, this theorem is structurally important: it makes the ratio operator a *depth-reducing* functor on the category of k-fold log-concave sequences.

### 3.2 Positivity Propagation

**Theorem 3.2** (`KFoldLogConcave.positive`). *Every k-fold log-concave sequence is positive.*

*Proof.* By cases on $k$: if $k = 0$, this is the definition; if $k = k' + 1$, this is the first conjunct. ∎

**Theorem 3.3** (`ratioSeq_positive`). *The ratio sequence of a positive sequence is positive.*

*Proof.* $\text{RatioSeq}(a)(n) = a(n+1)/a(n) > 0$ since both numerator and denominator are positive. ∎

**Theorem 3.4** (`KFoldLogConcave.iterRatio_positive`). *If $a$ is $k$-fold log-concave, then $\text{IterRatio}(m, a)$ is positive for all $m \leq k$.*

*Proof.* By induction on $m$, using Theorems 3.2 and 3.3. ∎

### 3.3 Iterated Extraction (Key Lemma)

**Theorem 3.5** (`KFoldLogConcave.iterRatio_kfold`). *If $a$ is $k$-fold log-concave and $m \leq k$, then $\text{IterRatio}(m, a)$ is $(k-m)$-fold log-concave.*

*Proof.* By induction on $m$. The base case $m = 0$ is trivial. For the inductive step, the hypothesis gives $\text{KFoldLogConcave}(k - m, \text{IterRatio}(m, a))$ with $k - m \geq 1$, so by Theorem 3.1, $\text{KFoldLogConcave}(k - m - 1, \text{RatioSeq}(\text{IterRatio}(m, a))) = \text{KFoldLogConcave}(k - (m+1), \text{IterRatio}(m+1, a))$. ∎

### 3.4 Tower Theorem (Theorem 2)

**Theorem 3.6** (`KFoldLogConcave.iterRatio_logConcave`). *If $a$ is $k$-fold log-concave and $m + 1 \leq k$, then $\text{IterRatio}(m, a)$ is log-concave.*

*Proof.* By Theorem 3.5, $\text{IterRatio}(m, a)$ is $(k - m)$-fold log-concave. Since $m + 1 \leq k$, we have $k - m \geq 1$, so by Theorem 3.1's converse (the `logConcave` extraction), $\text{IterRatio}(m, a)$ is log-concave. ∎

This theorem shows that k-fold log-concavity is not merely about the deepest level — it guarantees a full tower of log-concavity constraints at every intermediate level.

### 3.5 Depth Monotonicity

**Theorem 3.7** (`kFoldLogConcave_mono`). *If $a$ is $k$-fold log-concave and $j \leq k$, then $a$ is $j$-fold log-concave.*

*Proof.* By induction on $k$. If $j = k$, trivial. If $j < k$, use the inductive hypothesis applied to $\text{RatioSeq}(a)$ at depth $k - 1$, together with the positivity and log-concavity inherited from the $(k)$-fold hypothesis. ∎

---

## 4. Product Stability

### 4.1 The Key Identity

**Theorem 4.1** (`ratioSeq_mul`). *For positive sequences $a$ and $b$,*

$$\text{RatioSeq}(a \cdot b)(n) = \text{RatioSeq}(a)(n) \cdot \text{RatioSeq}(b)(n).$$

*Proof.* By direct computation:
$$\frac{a(n+1)b(n+1)}{a(n)b(n)} = \frac{a(n+1)}{a(n)} \cdot \frac{b(n+1)}{b(n)}.$$
∎

This identity is the engine behind product stability: the ratio operator commutes with pointwise products.

### 4.2 Base Case: Log-Concavity of Products

**Theorem 4.2** (`logConcaveN_mul`). *If $a$ and $b$ are positive log-concave sequences, then $a \cdot b$ is log-concave.*

*Proof.* We need $(a(n+1)b(n+1))^2 \geq a(n)b(n) \cdot a(n+2)b(n+2)$. The left side equals $a(n+1)^2 \cdot b(n+1)^2$, which is at least $a(n)a(n+2) \cdot b(n)b(n+2)$ by multiplying the two log-concavity inequalities (valid since all terms are positive). ∎

### 4.3 Product Stability Theorem (Theorem 4)

**Theorem 4.3** (`KFoldLogConcave.mul`). *If $a$ and $b$ are $k$-fold log-concave, then $a \cdot b$ is $k$-fold log-concave.*

*Proof.* By induction on $k$.

**Base case** ($k = 0$): Positivity of $a \cdot b$ follows from positivity of $a$ and $b$.

**Inductive step** ($k \to k+1$): We need:
1. $\text{PositiveSeq}(a \cdot b)$: from $\text{PositiveSeq}(a)$ and $\text{PositiveSeq}(b)$.
2. $\text{LogConcaveN}(a \cdot b)$: by Theorem 4.2.
3. $\text{KFoldLogConcave}(k, \text{RatioSeq}(a \cdot b))$: By Theorem 4.1, $\text{RatioSeq}(a \cdot b) = \text{RatioSeq}(a) \cdot \text{RatioSeq}(b)$. By the inductive hypothesis applied to $\text{RatioSeq}(a)$ (which is $k$-fold log-concave by Theorem 3.1) and $\text{RatioSeq}(b)$ (likewise), the product is $k$-fold log-concave. ∎

### 4.4 Significance for Partition Functions

The product stability theorem has immediate consequences for statistical mechanics. If a partition function factors as a product of independent contributions — as it does for non-interacting subsystems — then the log-concavity depth of the whole is at least the minimum of the depths of the parts.

**Theorem 4.4** (`partitionFunctionCoeff_kFoldLogConcave_of_factorization`). *If two coefficient sequences are k-fold log-concave, their pointwise product (the factored partition function) is k-fold log-concave.*

This is a direct corollary of Theorem 4.3.

---

## 5. Model Families and Bridge Theorems

### 5.1 Geometric Sequences

**Theorem 5.1** (`geometric_kFoldLogConcave`). *For $c, r > 0$, the geometric sequence $a(n) = c \cdot r^n$ is $k$-fold log-concave for all $k \in \mathbb{N}$.*

*Proof.* By induction on $k$. The ratio sequence of a geometric sequence is the constant sequence $r$, and constant positive sequences are trivially k-fold log-concave at every depth. ∎

Geometric sequences sit at "infinite depth" in the hierarchy — they are the fixed points of the ratio operator.

### 5.2 Binomial Coefficients

The binomial coefficients $\binom{N}{k}$ for $k = 0, \ldots, N$ are well-known to be log-concave. Our computational experiments show:

| N | Depth | First ratio sequence values |
|---|-------|-----------------------------|
| 4 | 1 | 4.0, 1.5, 0.67, 0.25 |
| 8 | 1 | 8.0, 3.5, 2.0, 1.25, 0.8, ... |
| 12 | 1 | 12.0, 5.5, 3.33, 2.25, ... |

The ratio sequences of binomial coefficients are *not* log-concave (they decrease too rapidly at the ends), so the depth is consistently 1 for $N \geq 3$. This indicates that while binomial coefficients are the canonical example of discrete log-concavity, they do not exhibit the deeper structural regularity of geometric sequences.

### 5.3 Bridge to Catalog Infrastructure

We establish a bridge theorem connecting the hierarchy to the existing `LogConcaveSeq` definition (for `Fin (n+1) → ℝ` sequences) in the Pythagorean Catalog:

> 1-fold log-concavity of an infinite sequence implies `LogConcaveSeq` for every finite restriction.

### 5.4 Recursive Lorentzian Sequence Structure

We define `RecursiveLorentzianSequence`, a structure bundling:
- A coefficient sequence `coeff : ℕ → ℝ`
- A depth `depth : ℕ`
- Positivity proof
- k-fold log-concavity proof at the specified depth

This structure admits a `product` operation: given two `RecursiveLorentzianSequence`s at the same depth, their pointwise product is again a `RecursiveLorentzianSequence` at that depth.

---

## 6. Computational Experiments

### 6.1 Depth Profiles

We implemented the `kfold_depth` algorithm, which iteratively computes ratio sequences and checks log-concavity at each level. The algorithm runs in $O(k \cdot n)$ time and $O(n)$ space.

**Algorithm**: `kfold_depth(seq)`
```
Input: positive sequence seq of length n
Output: maximal k such that seq is k-fold log-concave

current ← seq
depth ← 0
while len(current) ≥ 3:
    if not is_log_concave(current):
        return depth
    depth ← depth + 1
    current ← ratio_seq(current)
    if not is_positive(current):
        return depth
return depth
```

### 6.2 Ising Model Experiments

For the 1D Ising model on a chain of $N$ sites with inverse temperature $\beta$, we computed partition function coefficients grouped by magnetization and measured their concavity depth.

| N | β = 0.5 | β = 1.0 | β = 2.0 |
|---|---------|---------|---------|
| 4 | 1 | 1 | 1 |
| 6 | 1 | 1 | 1 |
| 8 | 1 | 1 | 1 |

The depth is consistently 1 across temperatures, suggesting that the 1D Ising partition function achieves ordinary log-concavity but not deeper concavity in its magnetization profile. This is consistent with the absence of phase transitions in 1D.

### 6.3 Product Stability Verification

We verified computationally that the product of k-fold log-concave sequences preserves depth:

- $\text{depth}(C(6,k)) = 1$, $\text{depth}(C(6,k)^2) = 1$: depth preserved.
- $\text{depth}(\text{geometric}) = \infty$, $\text{depth}(\text{geometric}^2) = \infty$: depth preserved.
- $\text{depth}(\text{geometric} \times \text{binomial}) \geq 1$: minimum of depths.

---

## 7. Conjectures and Open Problems

### 7.1 Main Conjecture: Lorentzian Depth Controls Discrete Curvature

**Conjecture 7.1.** Let $P$ be a homogeneous polynomial of degree $d$ with nonnegative coefficients. If $P$ is recursively Lorentzian to depth $k$, then for every positive bivariate specialization $P_t(x,y) = \sum a_m x^m y^{d-m}$, the coefficient sequence $(a_m)_{m=0}^d$ is $k$-fold log-concave on its support.

**Testable prediction**: For complete bipartite graph spanning tree enumerators, paving matroid basis generating polynomials, and Ising partition functions on small lattices, compute iterated ratio sequences and check log-concavity depth. A single explicit counterexample with positive coefficients and recursive Lorentzian certificate but failed k-fold log-concavity disproves the conjecture.

### 7.2 Mixing Time Conjecture

**Conjecture 7.2.** For a distribution with k-fold log-concave weights on $\{0, \ldots, n\}$, the mixing time of the natural nearest-neighbor random walk scales as $O(n^{2/k})$.

### 7.3 Open Questions

1. **Sharp depth bounds**: What is the exact relationship between the Lorentzian depth of a generating polynomial and the achievable k-fold log-concavity depth?

2. **Convolution closure**: Is k-fold log-concavity preserved under discrete convolution?

3. **Continuous analogues**: Does the hierarchy have a natural analogue for continuous log-concave densities on $\mathbb{R}$?

4. **Complexity**: What is the computational complexity of determining the maximal k-fold log-concavity depth of a given polynomial?

---

## 8. Discussion

### 8.1 Summary

We have established the foundational theory of k-fold log-concavity, a hierarchy that refines the classical notion of log-concavity for discrete sequences. The theory is clean, modular, and suitable for both formal verification and computational exploration.

The key structural results — recursive descent, the tower theorem, product stability, and depth monotonicity — together establish that k-fold log-concavity is a well-behaved invariant with good algebraic closure properties. The partition function factorization theorem provides a direct bridge to statistical mechanics.

### 8.2 Limitations

The current theory operates on globally positive infinite sequences, which excludes some natural combinatorial families (e.g., sequences with zero terms outside their support). A support-restricted version would extend the applicability but complicate the formalization.

The bridge from Lorentzian polynomial depth to k-fold log-concavity remains conjectural. Establishing this connection formally would require deeper engagement with the multivariate algebra of Lorentzian polynomials.

### 8.3 Future Directions

The most promising extensions include:
- Formalizing the bridge from `IsRecursivelyLorentzian` to `KFoldLogConcave` via coefficient extraction from bivariate specializations.
- Extending the hierarchy to matrix-valued sequences (for applications in quantum information).
- Connecting depth to modified log-Sobolev inequalities and spectral independence.

---

## References

[ALOV19] N. Anari, K. Liu, S. Oveis Gharan, C. Vinzant. "Log-Concave Polynomials II: High-Dimensional Walks and an FPRAS for Counting Bases of a Matroid." *STOC 2019*.

[BH20] P. Brändén, J. Huh. "Lorentzian Polynomials." *Annals of Mathematics*, 192(3):821–891, 2020.

[Mur03] K. Murota. "Discrete Convex Analysis." *SIAM Monographs on Discrete Mathematics and Applications*, 2003.

[Sta89] R. P. Stanley. "Log-Concave and Unimodal Sequences in Algebra, Combinatorics, and Geometry." *Annals of the New York Academy of Sciences*, 576:500–535, 1989.
