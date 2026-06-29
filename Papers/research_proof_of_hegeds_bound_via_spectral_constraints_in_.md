# A Spectral Gram-Matrix Bound for Uniform Set Families: Fisher / Frankl–Wilson Inequalities via Hegedűs' Eigenvalue Condition

**Author:** Aristotle

**Date:** 2026-06-28

---

## Abstract

We present a self-contained, fully formalized treatment of a Fisher / Frankl–Wilson type extremal bound for uniform set families, derived entirely from a single linear-algebraic fact: the positive definiteness of a constant-pattern Gram matrix. Given a family of $m$ subsets of an $n$-element ground set in which each set has size $k$ and any two distinct members meet in exactly $\lambda$ points with $\lambda < k$, we prove that $m \le n$. The argument proceeds through an explicit *combinatorics–algebra dictionary*: each set is mapped to its $0/1$ incidence vector in $\mathbb{R}^n$, the inner product of two such vectors equals the size of the intersection of the underlying sets, and the resulting Gram matrix is exactly the constant-pattern matrix $(k-\lambda)I + \lambda J$. Hegedűs' eigenvalue condition — positive definiteness of this matrix — follows from an elementary additive decomposition into a strictly positive-definite scalar multiple of the identity and a positive-semidefinite all-ones matrix, requiring no diagonalization. Positive definiteness of the Gram matrix forces linear independence of the incidence vectors, and a dimension count in $\mathbb{R}^n$ yields the bound. We exhibit the singleton family as a verified tight instance ($k=1$, $\lambda=0$, $m=n$), establish the necessity of the hypothesis $\lambda < k$ through the spectral degeneracy at $\lambda = k$, and state the unindexed `Finset`-family form bridged to a general uniformity predicate. We close with four conjectural extensions: non-uniform Fisher via diagonal-dominant Gram positivity, modular Hegedűs bounds over $\mathbb{F}_p$, equiangular-lines bounds from eigenvalue gaps, and quantitative refinements.

**Keywords:** Fisher inequality, Frankl–Wilson, Hegedűs eigenvalue condition, Gram matrix, positive definiteness, incidence vector, uniform set family, spectral method, equiangular lines, extremal combinatorics.

---

## 1. Introduction

A recurring theme in extremal combinatorics is that a strong *uniformity* constraint on a family of sets forces the family to be small. The prototype is **Fisher's inequality**: in a balanced incomplete block design where any two distinct blocks meet in exactly $\lambda$ points, the number of blocks is at least the number of points. The dual and its many relatives — the Frankl–Wilson theorems, the de Bruijn–Erdős theorem, the nonuniform Ray-Chaudhuri–Wilson bound, and Hegedűs' eigenvalue formulations — share a single proof technique known as the **linear-algebra method** or **polynomial/spectral method**: encode the combinatorial objects as vectors and bound their number by the dimension of the ambient space.

This paper isolates the *cleanest* such bound and presents it as a corollary of one eigenvalue inequality. The combinatorial statement is:

> **Theorem (Uniform Fisher bound).** Let $A_1, \dots, A_m \subseteq \{1, \dots, n\}$ satisfy $|A_i| = k$ for all $i$ and $|A_i \cap A_j| = \lambda$ for all $i \ne j$, where $\lambda < k$. Then $m \le n$.

The proof is a four-step pipeline:

1. **Dictionary.** Map each $A_i$ to its incidence vector $v_i \in \mathbb{R}^n$; then $\langle v_i, v_j \rangle = |A_i \cap A_j|$.
2. **Gram identification.** The Gram matrix $G = (\langle v_i, v_j\rangle)_{i,j}$ equals $(k-\lambda)I + \lambda J$.
3. **Spectral fact (Hegedűs' condition).** For $0 \le \lambda < k$, the matrix $(k-\lambda)I + \lambda J$ is positive definite.
4. **Dimension count.** A positive-definite Gram matrix certifies linear independence of $\{v_i\}$, and $\mathbb{R}^n$ holds at most $n$ independent vectors, so $m \le n$.

Each step is elementary, yet together they convert a counting problem into a question of matrix positivity. The contribution of this work is a *machine-checked, modular* rendering of this pipeline in which the spectral engine (the positive-definiteness/dimension bound) is fully decoupled from the combinatorial vocabulary, so that the same engine drives both an indexed and an unindexed (`Finset`-family) statement, and so that the necessity of $\lambda < k$ is exhibited as the precise point of spectral degeneracy.

### 1.1. Organization

Section 2 fixes notation and defines the incidence vector. Section 3 proves the dictionary lemmas. Section 4 states the abstract spectral bound and the constant-pattern positive-definiteness theorem. Section 5 assembles the main Fisher bounds (indexed and `Finset` forms). Section 6 treats sharpness (the singleton family) and necessity ($\lambda = k$ degeneracy). Section 7 gives algorithms for verifying and constructing instances. Section 8 discusses applications. Section 9 lists future directions.

---

## 2. Definitions and Notation

Throughout, $n, m, k, \lambda$ are natural numbers, and the ground set is $[n] = \{0, 1, \dots, n-1\}$, identified with the finite type $\mathrm{Fin}\,n$. We work in the Euclidean space $\mathbb{R}^n$ with its standard inner product $\langle \cdot, \cdot \rangle$.

**Definition 2.1 (Incidence vector).** For a subset $A \subseteq [n]$, its *incidence vector* $v_A \in \mathbb{R}^n$ is the $0/1$ indicator of membership:
$$v_A(t) = \begin{cases} 1 & t \in A, \\ 0 & t \notin A. \end{cases}$$
(In the formalization this is the definition `incidence`, realized as the image under the canonical equivalence $\mathbb{R}^n \cong (\mathrm{Fin}\,n \to \mathbb{R})$ of the indicator function.)

**Definition 2.2 (Uniform family).** A family $\mathcal{F}$ of subsets of $[n]$ is *$k$-uniform* if $|A| = k$ for every $A \in \mathcal{F}$. (This is the predicate `IsUniform k 𝓕` reused from the catalog combinatorics module.)

**Definition 2.3 (Constant-pattern matrix).** For real scalars $a, b$ and a size $m$, the *constant-pattern matrix* is $a I + b J$, where $I$ is the $m \times m$ identity and $J$ is the $m \times m$ all-ones matrix. Its diagonal entries are $a + b$ and its off-diagonal entries are $b$.

**Definition 2.4 (Gram matrix).** For vectors $v_1, \dots, v_m \in \mathbb{R}^n$, the *Gram matrix* is $G \in \mathbb{R}^{m \times m}$ with $G_{ij} = \langle v_i, v_j\rangle$. $G$ is always symmetric and positive semidefinite; it is positive definite iff $v_1, \dots, v_m$ are linearly independent.

**Definition 2.5 (Positive definiteness).** A symmetric real matrix $M$ is *positive definite* if $x^{\top} M x > 0$ for every nonzero vector $x$, equivalently if all eigenvalues of $M$ are strictly positive. It is *positive semidefinite* if $x^{\top} M x \ge 0$ for all $x$.

---

## 3. The Combinatorics–Algebra Dictionary

The entire reduction hinges on a single identity translating set intersection into inner product.

**Lemma 3.1 (`incidence_inner`).** For all subsets $A, B \subseteq [n]$,
$$\langle v_A, v_B \rangle = |A \cap B|.$$

*Proof sketch.* By the coordinate formula for the standard inner product,
$$\langle v_A, v_B \rangle = \sum_{t \in [n]} v_A(t)\, v_B(t) = \sum_{t \in [n]} \big[t \in A\big]\big[t \in B\big],$$
where $[\,\cdot\,]$ is the Iverson bracket. The product $[t\in A][t\in B]$ equals $1$ exactly when $t \in A \cap B$ and $0$ otherwise, so the sum collapses to $\sum_{t} [t \in A \cap B] = |A \cap B|$. Formally, this is a `Finset.sum_congr` rewriting each summand to $[t \in A \cap B]$, followed by `Finset.sum_ite_mem` and `Finset.sum_const` to evaluate the resulting indicator sum as the cardinality. $\square$

**Lemma 3.2 (`incidence_inner_self`).** For all $A \subseteq [n]$,
$$\langle v_A, v_A \rangle = |A|.$$

*Proof sketch.* Specialize Lemma 3.1 to $B = A$; then $A \cap A = A$, so $\langle v_A, v_A\rangle = |A \cap A| = |A|$. $\square$

These two lemmas are the *only* place where combinatorics enters. Everything downstream is linear algebra.

---

## 4. The Spectral Engine

We now record the two purely algebraic facts that power the bound. These constitute the reusable "spectral engine" and are stated independently of any set-system vocabulary.

**Theorem 4.1 (Constant-pattern positive definiteness, `constPattern_posDef`).** Let $0 \le \lambda < k$ be reals and $m \ge 1$. Then the $m \times m$ matrix
$$M = (k - \lambda)\, I + \lambda\, J$$
is positive definite.

*Proof sketch.* Decompose $M$ additively as $M = \underbrace{(k-\lambda) I}_{\text{PosDef}} + \underbrace{\lambda J}_{\text{PosSemidef}}$. For any vector $x$,
$$x^{\top} M x = (k - \lambda)\, \|x\|^2 + \lambda \Big(\sum_i x_i\Big)^2.$$
Since $\lambda \ge 0$, the second term is a nonnegative multiple of a square and hence $\ge 0$; in particular $\lambda J$ is positive semidefinite. Since $k - \lambda > 0$, the first term satisfies $(k-\lambda)\|x\|^2 > 0$ for every nonzero $x$; that is, $(k-\lambda)I$ is positive definite. The sum of a positive-definite matrix and a positive-semidefinite matrix is positive definite, so $M$ is positive definite. No diagonalization or explicit eigenvalue computation is required; the eigenvalues happen to be $k + (m-1)\lambda$ (once, eigenvector all-ones) and $k - \lambda$ (with multiplicity $m-1$), both positive, which is consistent. $\square$

**Theorem 4.2 (Spectral size bound, `gram_posDef_card_le` / `constGram_card_le`).** Let $v_1, \dots, v_m \in \mathbb{R}^n$ and suppose the Gram matrix $G_{ij} = \langle v_i, v_j\rangle$ is positive definite. Then $m \le n$. More specifically, the *constant-Gram* form `constGram_card_le` states: if $\langle v_i, v_i\rangle = k$ for all $i$, $\langle v_i, v_j\rangle = \lambda$ for all $i \ne j$, with $0 \le \lambda < k$, then $m \le n$.

*Proof sketch.* By hypothesis the Gram matrix of $\{v_i\}$ equals $(k - \lambda)I + \lambda J$, which is positive definite by Theorem 4.1. A positive-definite Gram matrix has trivial kernel: if $\sum_i c_i v_i = 0$ then $c^{\top} G c = \big\langle \sum_i c_i v_i, \sum_j c_j v_j\big\rangle = 0$, forcing $c = 0$ by positive definiteness. Hence the vectors $v_1, \dots, v_m$ are linearly independent in $\mathbb{R}^n$. The dimension of $\mathbb{R}^n$ is $n$, so any linearly independent set has at most $n$ elements, giving $m \le n$. $\square$

Theorem 4.2 is Hegedűs' eigenvalue condition in action: *positive eigenvalues of the Gram matrix bound the family size by the ambient dimension.*

---

## 5. The Main Fisher Bounds

We now compose the dictionary (Section 3) with the engine (Section 4).

**Theorem 5.1 (Indexed uniform Fisher bound, `indexed_fisher_card_le`).** Let $A : \mathrm{Fin}\,m \to \mathcal{P}([n])$ be an indexed family with $|A_i| = k$ for all $i$ and $|A_i \cap A_j| = \lambda$ for all $i \ne j$, where $\lambda < k$. Then $m \le n$.

*Proof sketch.* Set $v_i = v_{A_i}$ (incidence vectors). By Lemma 3.2, $\langle v_i, v_i\rangle = |A_i| = k$; by Lemma 3.1, $\langle v_i, v_j\rangle = |A_i \cap A_j| = \lambda$ for $i \ne j$. The real casts satisfy $0 \le \lambda$ (a cardinality) and $\lambda < k$ (from the hypothesis $\lambda < k$ on naturals). Apply `constGram_card_le` (Theorem 4.2) to conclude $m \le n$. $\square$

**Theorem 5.2 (`Finset`-family Fisher bound, `isUniform_fisher_card_le`).** Let $\mathcal{F}$ be a finite family of subsets of $[n]$ that is $k$-uniform (predicate `IsUniform k 𝓕`) and satisfies $|A \cap B| = \lambda$ for all distinct $A, B \in \mathcal{F}$, with $\lambda < k$. Then $|\mathcal{F}| \le n$.

*Proof sketch.* Enumerate $\mathcal{F}$ by a bijection $e : \mathrm{Fin}\,|\mathcal{F}| \xrightarrow{\sim} \mathcal{F}$ (from `Finset.equivFin`), and set $A_i = e(i)$. Uniformity gives $|A_i| = k$. Injectivity of $e$ ensures that distinct indices $i \ne j$ yield distinct sets $A_i \ne A_j$, so the intersection hypothesis transports to $|A_i \cap A_j| = \lambda$. Apply Theorem 5.1 to the indexed family $A$, obtaining $|\mathcal{F}| = m \le n$. $\square$

Theorem 5.2 is the **cross-domain bridge**: it consumes the general `IsUniform` predicate from the catalog's combinatorics layer and discharges it through the spectral engine, demonstrating that the abstract eigenvalue bound subsumes the classical set-system statement verbatim.

---

## 6. Sharpness and Necessity

A bound is only as informative as its extremal cases. We address two questions: *Is $m \le n$ attained?* and *Is $\lambda < k$ necessary?*

### 6.1. Sharpness: the singleton family

**Definition 6.1 (`singletonFamily`).** The singleton family is $S : \mathrm{Fin}\,n \to \mathcal{P}([n])$, $S_i = \{i\}$.

**Theorem 6.2 (`singletonFamily_fisher`).** The singleton family satisfies the Fisher hypotheses with $k = 1$, $\lambda = 0$, and attains $m = n$. Explicitly:
- $n \le n$ (the bound, met with equality);
- $|S_i| = 1$ for all $i$ (it is $1$-uniform);
- $|S_i \cap S_j| = 0$ for all $i \ne j$ (distinct singletons are disjoint), and $0 = \lambda < k = 1$.

*Proof sketch.* Each $S_i = \{i\}$ has cardinality $1$. For $i \ne j$, the intersection $\{i\} \cap \{j\}$ is empty: any common element $x$ would force $x = i$ and $x = j$, contradicting $i \ne j$; hence its cardinality is $0$. The bound $n \le n$ is reflexive. $\square$

Geometrically, the incidence vectors of the singletons are precisely the standard basis vectors $e_1, \dots, e_n$ of $\mathbb{R}^n$, the maximal orthonormal — hence linearly independent — system. The bound is tight, and the eigenvalue hypothesis is satisfiable, ruling out vacuity.

### 6.2. Necessity: spectral degeneracy at $\lambda = k$

**Proposition 6.3 (Necessity of $\lambda < k$, cf. `fisher_lam_lt_k_necessary` / `degenerate_gram_not_posDef`).** The hypothesis $\lambda < k$ cannot be relaxed to $\lambda \le k$. At $\lambda = k$ the Gram matrix degenerates to $k J$, which is *not* positive definite, and the size bound $m \le n$ fails.

*Proof sketch.* If $\lambda = k$, then two distinct $k$-element sets sharing $k$ points are equal, so the constraint is combinatorially degenerate. On the algebraic side, $(k - \lambda)I + \lambda J = 0 \cdot I + k J = k J$. For any nonzero vector $x$ with $\sum_i x_i = 0$ (which exists whenever $m \ge 2$), we have $x^{\top}(kJ)x = k\big(\sum_i x_i\big)^2 = 0$, so $kJ$ has a nontrivial kernel and a zero eigenvalue; it is positive semidefinite but not positive definite. The independence certificate is lost, and arbitrarily many copies become possible. Thus the strict inequality is exactly the threshold separating a bounded family from an unbounded one — the smallest eigenvalue $k - \lambda$ of the diagonal part must remain strictly positive. $\square$

---

## 7. Algorithms

The formalization yields two natural computational procedures.

### 7.1. Hypothesis verification

**Algorithm `VerifyFisherHypotheses`.** Given $n$, $k$, $\lambda$, and a list of subsets of $[n]$, decide whether the Fisher hypotheses hold and report the implied bound.

```
Input: ground size n, integers k, λ, family F = [A_1, ..., A_m]
Output: (hypotheses_hold : bool, bound : int)
1. assert 0 ≤ λ < k                       # eigenvalue condition
2. for each A_i in F:
3.     if |A_i| ≠ k: return (false, _)     # uniformity
4. for each pair i < j:
5.     if |A_i ∩ A_j| ≠ λ: return (false, _)   # constant intersection
6. return (true, n)                         # theorem: m ≤ n
```

Complexity: $O(m^2 \cdot n)$ for the pairwise intersection checks (each intersection costs $O(n)$ with bitset representations), dominating the $O(m \cdot n)$ uniformity scan.

### 7.2. Gram-spectrum certification

**Algorithm `GramSpectrumCertify`.** Build the Gram matrix of the incidence vectors and certify positive definiteness via its eigenvalues, exposing the two-point spectrum $\{k - \lambda,\ k + (m-1)\lambda\}$.

```
Input: family F = [A_1, ..., A_m] over [n]
Output: (min_eigenvalue, is_posdef : bool, dimension_bound)
1. V ← matrix whose i-th row is incidence vector of A_i      # m × n, 0/1
2. G ← V · Vᵀ                                                # Gram, m × m
3. eigs ← eigenvalues(G)                                     # symmetric ⇒ real
4. is_posdef ← (min(eigs) > 0)
5. return (min(eigs), is_posdef, rank(V))                    # rank(V) ≤ n bounds m
```

Complexity: $O(m^2 n)$ to form $G$, $O(m^3)$ for the symmetric eigendecomposition. For a valid uniform family the spectrum is exactly $k - \lambda$ (multiplicity $m-1$) and $k + (m-1)\lambda$ (multiplicity $1$); positive definiteness is equivalent to $k - \lambda > 0$.

---

## 8. Applications

- **Combinatorial design theory.** The bound caps the size of pairwise-balanced uniform families, recovering one direction of Fisher-type inequalities for symmetric designs and constant-intersection systems.
- **Coding theory.** Constant-weight codes with prescribed pairwise intersections correspond to uniform families; the spectral bound limits code size by block length.
- **Finite geometry.** Configurations of lines/points with uniform incidence translate to constant-pattern Gram matrices, and the bound restricts their cardinality.
- **Statistical design of experiments.** Balanced incomplete block designs require constant block size and constant pairwise treatment co-occurrence; the result bounds the number of blocks by the number of treatments under the strict overlap condition.
- **Method transfer.** As a template, the four-step pipeline (encode → Gram → positive-definite → dimension) is a reusable proof strategy applicable to any extremal problem expressible through inner products.

---

## 9. Discussion and Future Directions

The value of this development is methodological. By decoupling the *spectral engine* (Theorems 4.1–4.2) from the *combinatorial dictionary* (Lemmas 3.1–3.2), the same positive-definiteness inequality discharges both an indexed and an unindexed set-family bound, and the role of the hypothesis $\lambda < k$ is pinned down exactly: it is the condition keeping the smallest eigenvalue $k - \lambda$ of the diagonal part strictly positive. The following conjectures extend the findings.

### C1. Non-uniform Fisher via diagonal-dominant Gram positivity
**Statement.** If $A_1, \dots, A_m \subseteq [n]$ satisfy $|A_i \cap A_j| = \lambda \ge 1$ for all $i \ne j$ (constant off-diagonal intersection, *arbitrary* set sizes $|A_i| > \lambda$), then $m \le n$. **Key insight:** the Gram matrix $D + \lambda J$ with $D = \mathrm{diag}(|A_i| - \lambda) \succ 0$ is positive definite by the same additive split used in the constant-pattern theorem, replacing the scalar $(k-\lambda)I$ with the positive diagonal $D$; thus the uniformity hypothesis $|A_i| = k$ is not needed. **Why now:** the constant-pattern positive-definiteness already isolates the only nontrivial step (PosDef of the diagonal part); the matrix lemma `Matrix.PosDef.diagonal` supplies the generalization immediately, making this a short, high-value extension.

### C2. Modular Hegedűs bound (Frankl–Wilson mod a prime)
**Statement.** For a prime $p$, a family of subsets of $[n]$ with $|A_i| \equiv 0$ and $|A_i \cap A_j| \not\equiv 0 \pmod{p}$ for $i \ne j$ has size at most $\sum_{i < p} \binom{n}{i}$. **Key insight:** the real Gram argument is replaced by the rank of the inclusion matrix over $\mathbb{F}_p$, where "positive definite" becomes "nonsingular mod $p$"; the eigenvalue condition migrates to a determinant non-vanishing condition. **Why now:** this cycle established the real/eigenvalue template; porting the "independence ⇒ dimension cap" skeleton to $\mathbb{Z}/p\mathbb{Z}$ with `Matrix.rank` is the natural next rung and connects to number-theoretic catalog files.

### C3. Equiangular lines bound from the eigenvalue gap
**Statement.** A set of $m$ unit vectors in $\mathbb{R}^n$ with pairwise inner products in $\{+\alpha, -\alpha\}$ ($0 < \alpha < 1$) satisfies $m \le \frac{n(1 - \alpha^2)}{1 - m\alpha^2}$ whenever $m\alpha^2 < 1$. **Key insight:** the Gram matrix $I + \alpha S$ ($S$ a $\pm 1$ symmetric hollow matrix) is positive definite iff the smallest eigenvalue of $S$ exceeds $-1/\alpha$, turning the combinatorial bound into a Perron–Frobenius eigenvalue estimate on $S$. **Why now:** the constant-Gram bound already handles the single-correlation case ($S = J - I$); generalizing the off-diagonal pattern from constant to $\pm\alpha$ is the first genuinely spectral (non-rank) refinement and is a celebrated extremal problem.

### C4. Quantitative refinements
Sharper, dimension-explicit forms of the bound — for instance tracking the gap $k - \lambda$ to yield stability versions ("near-extremal families are near-singleton") and explicit eigenvalue-based deficiency estimates — are a natural quantitative continuation of the spectral template.

---

## 10. Conclusion

We have given a modular, fully verified derivation of a uniform Fisher / Frankl–Wilson bound from a single eigenvalue inequality. The incidence-vector dictionary ($\langle v_A, v_B\rangle = |A \cap B|$) converts the combinatorial constraints into the constant-pattern Gram matrix $(k-\lambda)I + \lambda J$, whose positive definiteness for $0 \le \lambda < k$ — Hegedűs' eigenvalue condition — forces linear independence and hence $m \le n$. The singleton family attains the bound, and the degeneracy at $\lambda = k$ shows the hypothesis is exactly necessary. The same spectral engine, suitably generalized, promises to drive non-uniform, modular, and equiangular extensions.
