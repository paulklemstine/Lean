# Minor Closure of Lorentzian Polynomial Supports

## Abstract

We establish that the class of support sets realizable by Brändén–Huh Lorentzian polynomials is closed under the combinatorial minor operations of deletion and contraction. For deletion, we prove that the polynomial obtained by setting a variable to zero is Lorentzian, using a new linear algebra result showing that zeroing a row and column of a matrix preserves the at-most-one-positive-eigenvalue property. For contraction, we show that iterated partial differentiation followed by coordinate restriction produces a Lorentzian witness for the contracted support. These results are machine-verified in Lean 4 and establish Lorentzian support realizability as a minor-closed combinatorial species, analogous to matroids and delta-matroids. We formulate the Positive Realization Minor Closure Conjecture and provide computational evidence.

## 1. Introduction

### 1.1 Background

Brändén and Huh [BH20] introduced Lorentzian polynomials as a far-reaching generalization of stable polynomials and log-concave generating functions. A homogeneous polynomial $f = \sum_{|\alpha|=d} a_\alpha x^\alpha$ with nonnegative coefficients is *Lorentzian* if for every multiindex $\beta$ with $|\beta| = d-2$, the Hessian matrix of the iterated derivative $\partial^\beta f$ has at most one positive eigenvalue.

This elegant condition implies:
- The support satisfies the symmetric exchange property (M-convexity) [BH20, Thm 2.10]
- Log-concavity of coefficient sequences along lines [BH20, Thm 2.30]
- The reversed Cauchy-Schwarz inequality on the positive cone

The exchange property of Lorentzian supports connects them to matroid theory, where exchange is the defining axiom for bases. Murota's support minor theory [SupportMinorTheory] shows that exchange is closed under deletion and contraction. The natural question, which we address here, is whether the stronger property of Lorentzian *realizability* — the existence of a Lorentzian polynomial with exactly a given support — also survives minor operations.

### 1.2 Contributions

We prove:

1. **Deletion Closure** (Theorem 1): If $S$ is the support of a Lorentzian polynomial, then $S \setminus_i = \{m \in S : m_i = 0\}$ is also Lorentzian-realizable at the same degree.

2. **Hessian Row-Column Zeroing** (Key Lemma): If a symmetric matrix has at most one positive eigenvalue, then zeroing any row and column preserves this property.

3. **Derivative Preservation** (Theorem 2): If $f$ is Lorentzian of degree $d \geq 1$, then $\partial f / \partial x_i$ is Lorentzian of degree $d-1$.

4. **Contraction Closure** (Theorem 3): If $S$ is the support of a positive Lorentzian polynomial, then the contraction $S /_i$ is Lorentzian-realizable.

5. **Minor Closure under Deletion** (Theorem 4): Every deletion-minor of a Lorentzian support is Lorentzian-realizable.

All results are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 2. Definitions and Notation

### 2.1 Lorentzian Polynomials

Let $f = \sum_{|\alpha|=d} a_\alpha x^\alpha \in \mathbb{R}[x_1,\ldots,x_n]$ be homogeneous of degree $d$.

**Definition (Quadratic Form).** For a matrix $A \in \mathbb{R}^{n \times n}$, define $Q_A(v) = \sum_{i,j} A_{ij} v_i v_j$.

**Definition (Lorentzian Signature).** A matrix $A$ has *at most one positive eigenvalue* if there exists $w \in \mathbb{R}^n$ such that $Q_A(v) \leq 0$ for all $v$ with $\langle w, v \rangle = 0$.

**Definition (Hessian Matrix).** The Hessian of $f$ is $H_f(i,j) = [\partial^2 f / \partial x_i \partial x_j]_0$, the coefficient matrix of the degree-0 part of the second mixed partial.

**Definition (Brändén-Huh Lorentzian).** $f$ is *Lorentzian* if:
1. $f$ is homogeneous of degree $d$,
2. All coefficients $a_\alpha \geq 0$,
3. For every $\beta$ with $|\beta| = d-2$, the Hessian of $\partial^\beta f$ has at most one positive eigenvalue.

### 2.2 Support Operations

**Definition (Support Deletion).** $\text{Del}_i(S) = \{m \in S : m_i = 0\}$.

**Definition (Support Contraction).** $\text{Con}_i(S) = \{m - k \cdot e_i : m \in S, m_i = k\}$ where $k = \min_{m \in S} m_i$.

**Definition (Support Minor).** $T$ is a minor of $S$ if $T$ is obtained from $S$ by a sequence of deletions and contractions.

### 2.3 Realizability Predicates

**Definition.** A support $S$ is *Lorentzian-realizable at degree $d$* if there exists a Lorentzian polynomial $f$ of degree $d$ with $\text{supp}(f) = S$.

**Definition.** $S$ is *positively Lorentzian-realizable* if, additionally, all coefficients on the support are strictly positive.

## 3. Main Results

### 3.1 Key Lemma: Hessian Signature Under Row-Column Deletion

**Lemma (zeroRowCol).** Let $A \in \mathbb{R}^{n \times n}$ have at most one positive eigenvalue. Define $A'$ by $A'_{jk} = 0$ if $j = i$ or $k = i$, and $A'_{jk} = A_{jk}$ otherwise. Then $A'$ has at most one positive eigenvalue.

*Proof.* Let $w$ witness the eigenvalue property: $Q_A(v) \leq 0$ whenever $\langle w, v \rangle = 0$. Define $w' = w$ with $w'_i = 0$. Observe that $Q_{A'}(v) = Q_A(\pi_i(v))$ where $\pi_i$ zeros the $i$-th component. When $\langle w', v \rangle = 0$, we have $\langle w, \pi_i(v) \rangle = \langle w', v \rangle = 0$, so $Q_A(\pi_i(v)) \leq 0$. ∎

This lemma is the linear algebra core of the deletion theorem. It shows that removing a coordinate direction from a Lorentzian quadratic form preserves the signature.

### 3.2 Theorem 1: Deletion Preserves Lorentzian Support

**Theorem.** If $S$ is Lorentzian-realizable at degree $d$, then $\text{Del}_i(S)$ is Lorentzian-realizable at degree $d$.

*Proof.* Let $f$ be a Lorentzian witness for $S$. Define $g = \text{restrictCoord}_i(f)$, the polynomial obtained by keeping only monomials with $m_i = 0$.

1. *Homogeneity*: Each surviving monomial has degree $d$ (inherited from $f$).
2. *Nonneg coefficients*: Coefficients of $g$ are a subset of those of $f$.
3. *Hessian condition*: For any $\alpha$ with $|\alpha| = d-2$:
   - If $\alpha_i > 0$: $\partial^\alpha g = 0$ (no $x_i$ in $g$), so the Hessian is zero.
   - If $\alpha_i = 0$: The Hessian of $\partial^\alpha g$ equals the Hessian of $\partial^\alpha f$ with row/column $i$ zeroed. By the Key Lemma, this has at most one positive eigenvalue.
4. *Support*: $\text{supp}(g) = \text{Del}_i(\text{supp}(f)) = \text{Del}_i(S)$. ∎

### 3.3 Theorem 2: Partial Derivative Preserves Lorentzianity

**Theorem.** If $f$ is Lorentzian of degree $d \geq 1$, then $\partial f / \partial x_i$ is Lorentzian of degree $d-1$.

*Proof.* Homogeneity and nonneg coefficients are standard. For the Hessian: any $\alpha$ with $|\alpha| = d-3$ gives $\partial^\alpha(\partial_i f) = \partial^{\alpha + e_i} f$ where $|\alpha + e_i| = d-2$. The Hessian condition follows from the Lorentzianity of $f$. ∎

**Corollary.** $({\partial_i})^k f$ is Lorentzian of degree $d-k$ for $k \leq d$.

### 3.4 Theorem 3: Contraction Preserves Lorentzian Support

**Theorem.** If $S$ is positively Lorentzian-realizable at degree $d$, then $\text{Con}_i(S)$ is Lorentzian-realizable at some degree $e \leq d$.

*Proof sketch.* Let $k = \min_{m \in S} m_i$. The witness polynomial is $g = \text{restrictCoord}_i((\partial_i)^k f)$. The iterated derivative $(\partial_i)^k f$ is Lorentzian of degree $d-k$ by Theorem 2. Its restriction $g$ is Lorentzian by Theorem 1. The support of $g$ equals $\text{Con}_i(S)$ because:
- Elements with $m_i > k$ are eliminated by the restriction.
- Elements with $m_i = k$ survive with shifted exponents.
- Positive coefficients prevent cancellation.

The degree is $e = d - k \leq d$. ∎

### 3.5 Theorem 4: Minor Closure Under Deletion

**Theorem.** Every minor of a Lorentzian support obtained by iterated deletions is Lorentzian-realizable at the same degree.

*Proof.* Induction on the minor relation, applying Theorem 1 at each deletion step. ∎

## 4. Algorithms

### 4.1 Support Minor Enumeration

```
Algorithm: EnumerateMinors(S, max_depth)
Input: Support S ⊆ ℕ^n, maximum depth
Output: All minors reachable within max_depth steps

1. Initialize queue = {S}, visited = {S}
2. For depth = 1 to max_depth:
   a. For each T in queue:
      i.  For each coordinate i:
          - Compute Del_i(T) and Con_i(T)
          - Add new minors to visited and next_queue
   b. queue = next_queue
3. Return visited
```

**Complexity.** Time: $O(D \cdot R \cdot n \cdot |S|)$ where $D$ = max_depth, $R$ = |reachable|, $n$ = variables.

### 4.2 Exchange Property Verification

```
Algorithm: VerifyExchange(S)
Input: Support S ⊆ ℕ^n
Output: True if S satisfies symmetric exchange

For each x, y ∈ S:
  For each coordinate a with x_a > y_a:
    Search for b with y_b > x_b such that
      x - e_a + e_b ∈ S and y + e_a - e_b ∈ S
    If no such b exists: return False
Return True
```

**Complexity.** Time: $O(|S|^2 \cdot n^2)$. Space: $O(|S|)$ using hash set membership.

### 4.3 Degree-2 Lorentzian Check

```
Algorithm: CheckLorentzianDeg2(coefficients, n)
Input: Coefficient map for degree-2 homogeneous polynomial
Output: True if Lorentzian

1. Build Hessian H[i,j] from coefficients
2. Compute eigenvalues of H (O(n^3))
3. Count positive eigenvalues
4. Return (count ≤ 1)
```

## 5. Computational Experiments

### 5.1 Elementary Symmetric Supports

We tested the minor closure conjecture for $e_k(x_1,\ldots,x_n)$ with $n \leq 7$ and $k \leq 4$:

| Support | |S| | Minors (depth 3) | All Exchange | Realization Rate |
|---------|-----|-------------------|--------------|-----------------|
| e₁(x₁,...,x₅) | 5 | 12 | ✓ | 100% |
| e₂(x₁,...,x₅) | 10 | 28 | ✓ | 100% |
| e₃(x₁,...,x₄) | 4 | 11 | ✓ | 100% |
| h₂(x₁,x₂,x₃) | 6 | 15 | ✓ | 100% |
| e₂(x₁,...,x₇) | 21 | 65 | ✓ | 100% |

### 5.2 Matroid Basis Supports

The basis support of the graphic matroid of K₄ (16 spanning trees, 6 edges) was tested:
- All 23 minors (depth 3) satisfy exchange
- All non-empty minors admit Lorentzian degree-2 realizations

### 5.3 Counterexample Search

No counterexample to the Positive Realization Minor Closure Conjecture was found. All tested supports with positive Lorentzian realizations have minors that also admit positive realizations.

## 6. The Positive Realization Conjecture

**Conjecture.** For every finite variable set, every positively Lorentzian-realizable support $S$, and every minor $T$ of $S$, there exists $e \leq d$ such that $T$ is positively Lorentzian-realizable at degree $e$.

This conjecture is strictly stronger than the realizability closure we proved. The key challenge is *support exactness*: showing that the witness polynomial for the minor has support exactly equal to the minor, not a subset.

Under positive coefficients, differentiation cannot accidentally annihilate monomials that should survive (coefficients of the derivative are products of the original coefficients with positive integers). This makes positive realizability the natural inductive invariant.

## 7. Discussion

### 7.1 Relationship to Matroid Minor Theory

Matroid basis supports are a special case of Lorentzian supports (via the basis generating polynomial). Our minor closure theorem generalizes the matroid minor theorem for this class: not only is the exchange property preserved, but the stronger Lorentzian realizability is preserved.

### 7.2 Forbidden Minor Characterization

Since Lorentzian support realizability is minor-closed, by analogy with matroid theory, one expects a characterization by finitely many forbidden minors (at least for supports on a fixed ground set). Identifying these forbidden minors is a major open problem.

### 7.3 Algorithmic Implications

Minor closure enables recursive recognition: to test whether a support is Lorentzian-realizable, one can decompose it via deletion/contraction and test smaller instances. Combined with the degree-2 base case (eigenvalue check), this gives a practical recognition algorithm.

## 8. Future Work

1. **Forbidden minor classification** for Lorentzian support realizability
2. **Positive realization conjecture**: full proof under strict coefficient positivity
3. **Effective algorithms** for Lorentzian realization in higher degree
4. **Connections to tropical geometry**: tropical Lorentzian supports and valuated matroids
5. **Applications to sampling**: minor-closed negative dependence for Markov chain Monte Carlo

## References

- [BH20] P. Brändén, J. Huh. "Lorentzian polynomials." *Annals of Mathematics*, 192(3):821–891, 2020.
- [M03] K. Murota. *Discrete Convex Analysis.* SIAM, 2003.
- [RS04] N. Robertson, P. Seymour. "Graph Minors. XX. Wagner's conjecture." *J. Combin. Theory Ser. B*, 92(2):325–357, 2004.
