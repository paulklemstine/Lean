# Standard-Part Projection-Valued Measures

### Descent, Rigidity, Quantization and Entropy for Non-Archimedean Resolutions of the Identity

**Author:** Aristotle
**Date:** 2026-09-07

---

## Abstract

We study families of matrices over the hyperreal field $\mathbb{R}^*$ that satisfy the axioms of a projection-valued measure only up to infinitesimal error, and we determine precisely what an observer restricted to the real numbers can see of such a family. The observation map is the entrywise standard part $\mathrm{st}$, which is a ring homomorphism on the collection of hyperreal matrices with no infinite entry, but is not defined on any subring containing infinite elements.

Our main theorem is a *descent criterion*: for a family $P_1,\dots,P_m$ of $n \times n$ hyperreal matrices with finite entries, the real matrices $\mathrm{st}(P_a)$ form a projection-valued measure if and only if $P_aP_b$ is entrywise infinitesimal for $a \ne b$ and $\sum_a P_a$ is entrywise infinitesimally close to $I$. Notably, no approximate idempotency hypothesis appears — we show it is a formal consequence of approximate exclusivity and approximate completeness. We prove the finiteness hypothesis is sharp in both directions with explicit $2\times2$ and $1\times1$ witnesses built from an infinite hyperreal $\omega$.

Four structural consequences follow. *Dimension quantization*: the observed traces of the channels are natural numbers, equal to the ranks of the observed projections, summing to $n$; the observation of a non-Archimedean measurement is always an internal direct sum decomposition of $\mathbb{R}^n$. *Functional calculus*: real polynomial identities and approximate annihilators descend exactly, and coarse-graining commutes with observation, producing a spectral-collapse theorem in which infinitesimally separated eigenvalues merge into a single observed spectral line. *Rigidity*: every finite-entry approximate hyperreal projection-valued measure lies entrywise infinitesimally close to an exact one, uniquely so among lifts of real families, although the approximate class is strictly larger than the exact class. *Entropy*: the observed Born weights form a probability measure whose Shannon entropy is monotone non-increasing under coarse-graining, with a sharp equality criterion.

**Keywords.** hyperreal field, standard part, projection-valued measure, resolution of the identity, idempotent matrix, non-Archimedean analysis, dimension quantization, Born measure, Shannon entropy, coarse-graining.

---

## 1. Introduction

### 1.1 Motivation

A *projection-valued measure* (PVM) with finitely many outcomes on $\mathbb{R}^n$ is a family of matrices that are idempotent, pairwise orthogonal, and sum to the identity. It is the algebraic skeleton of an ideal measurement: the channels are exclusive and exhaustive, and each channel selects a subspace of state space. The definition is a conjunction of *polynomial identities*, and polynomial identities are brittle: a real device satisfies them approximately at best.

There are two standard responses. One replaces sharp projections by positive operator-valued measures, weakening the algebra. The other keeps the algebra and treats the error statistically, outside the formalism. This paper explores a third response, available because the hyperreal field $\mathbb{R}^*$ has room *inside the number system* for a scale of error that is nonzero yet below every real threshold: keep the identities, but require them only modulo infinitesimals.

Concretely, the hyperreals form an ordered field properly extending $\mathbb{R}$ and containing infinitesimals — nonzero elements $\varepsilon$ with $|\varepsilon| < 1/k$ for every positive integer $k$ — and infinite elements such as $\omega = 1/\varepsilon$, whose absolute value exceeds every integer. A hyperreal is *finite* if it is not infinite. Each finite hyperreal $x$ is infinitely close to a unique real number $\mathrm{st}(x)$, its **standard part**; we adopt the convention that $\mathrm{st}$ is extended by $0$ on infinite elements, so that it is a total function $\mathbb{R}^* \to \mathbb{R}$ that is well behaved precisely on the finite part.

The question addressed here: *which of the algebraic identities defining a measurement survive the passage $\mathbb{R}^* \to \mathbb{R}$ given by $\mathrm{st}$, and under what hypotheses?*

### 1.2 Summary of results

Throughout, $n$ and $m$ are finite, matrices are $n \times n$, and channels are indexed by a finite set $\iota$ of size $m$.

* **Descent (Theorem 3.1).** For a finite-entry family, $(\mathrm{st}(P_a))_a$ is a PVM $\iff$ approximate exclusivity and approximate completeness hold.
* **Redundancy (Theorem 3.3).** Approximate idempotency is implied by the other two hypotheses; the hypothesis list is minimal.
* **Sharpness (Theorems 3.5, 3.6).** Both directions of Theorem 3.1 fail if entries are allowed to be infinite.
* **Quantization (Theorem 4.2, Corollary 4.3).** $\sum_a \mathrm{rank}\,\mathrm{st}(P_a) = n$, and $\mathrm{st}(\mathrm{tr}\,P_a) \in \{0,1,\dots,n\}$.
* **Geometry (Theorem 4.5).** The ranges of the observed channels form an internal direct sum decomposition of $\mathbb{R}^n$.
* **Functional calculus (Theorem 5.2, Corollary 5.3).** $\mathrm{st}(p(A)) = p(\mathrm{st}(A))$ for real polynomials $p$ and finite-entry $A$; approximate annihilators become exact.
* **Coarse-graining and spectral collapse (Theorems 6.1, 6.3).** Merging channels preserves the class and commutes with observation; infinitesimally separated eigenvalues fuse.
* **Surjectivity and fibres (Theorem 7.1, Proposition 7.2).** Observation is onto the class of real PVMs and its fibres are exactly the infinitesimal halos; the approximate class is strictly larger than the exact one (Theorem 7.3).
* **Rigidity (Theorem 7.4 and its refinements).** Every finite-entry approximate PVM is infinitesimally close to an exact hyperreal PVM, uniquely among lifts.
* **Entropy (Theorem 8.3, Theorem 8.5).** Observed Shannon entropy is non-increasing under coarse-graining, with a sharp equality criterion.

---

## 2. The observation map

### 2.1 Scalars

We record the properties of $\mathrm{st}$ that drive everything else. Write $\mathrm{Fin}(\mathbb{R}^*)$ for the set of finite hyperreals; it is a subring of $\mathbb{R}^*$, and the infinitesimals form a maximal ideal in it.

**Lemma 2.1 (Standard part on finite elements).** For finite $x, y \in \mathbb{R}^*$:
1. $x$ is infinitesimal $\iff$ $x$ is finite and $\mathrm{st}(x)=0$;
2. $\mathrm{st}(x+y) = \mathrm{st}(x)+\mathrm{st}(y)$ and $\mathrm{st}(xy) = \mathrm{st}(x)\mathrm{st}(y)$, so $\mathrm{st}(x-y)=\mathrm{st}(x)-\mathrm{st}(y)$;
3. $x - y$ is infinitesimal $\iff$ $\mathrm{st}(x)=\mathrm{st}(y)$;
4. a finite sum of finite hyperreals is finite, and $\mathrm{st}\big(\sum_{i\in s} f(i)\big) = \sum_{i \in s}\mathrm{st}(f(i))$ for a finite index set $s$ with all $f(i)$ finite;
5. if $x$ is infinitesimal and $y$ is finite then $xy$ is infinitesimal.

*Proof sketch.* (1) and (2) are the defining properties of the standard part, the latter being the statement that $\mathrm{st} : \mathrm{Fin}(\mathbb{R}^*) \to \mathbb{R}$ is the quotient by the ideal of infinitesimals. (3) is (1) applied to $x-y$, using that the difference of finite elements is finite. (4) is induction on $|s|$ using (2) and closure of the finite part under addition. (5) follows from (2): $\mathrm{st}(xy) = 0 \cdot \mathrm{st}(y) = 0$, and $xy$ is finite. $\square$

The failure of (2) for infinite arguments is the source of every counterexample below: $\omega$ and $\omega^{-1}$ satisfy $\mathrm{st}(\omega \cdot \omega^{-1}) = 1 \ne 0 = \mathrm{st}(\omega)\,\mathrm{st}(\omega^{-1})$.

### 2.2 Matrices

**Definition 2.2.** For a hyperreal matrix $A \in M_n(\mathbb{R}^*)$:
* $\mathrm{st}(A) \in M_n(\mathbb{R})$ is the matrix with $\mathrm{st}(A)_{ij} = \mathrm{st}(A_{ij})$ (the **observation** of $A$);
* $A$ has **finite entries** if no $A_{ij}$ is infinite;
* $A$ is **infinitesimal** if every $A_{ij}$ is infinitesimal;
* $A \approx B$ means $A - B$ is infinitesimal.

Note that $\{A : A \text{ has finite entries}\}$ is not a subring of $M_n(\mathbb{R}^*)$ in any useful sense containing the infinite matrices, but it *is* closed under addition, negation and multiplication (the last because a product entry is a finite sum of products of finite hyperreals). Every infinitesimal matrix has finite entries, and the identity and zero matrices do.

**Theorem 2.3 (Observation is a ring-like homomorphism).** For $A, B \in M_n(\mathbb{R}^*)$ with finite entries and any finite family $(P_a)$ of finite-entry matrices:
$$\mathrm{st}(A+B)=\mathrm{st}(A)+\mathrm{st}(B),\quad \mathrm{st}(A-B)=\mathrm{st}(A)-\mathrm{st}(B),$$
$$\mathrm{st}(AB)=\mathrm{st}(A)\,\mathrm{st}(B),\quad \mathrm{st}\Big(\sum_a P_a\Big)=\sum_a \mathrm{st}(P_a),$$
$$\mathrm{st}(0)=0,\quad \mathrm{st}(I)=I,\quad \mathrm{st}(A^{\mathsf T}) = \mathrm{st}(A)^{\mathsf T}.$$

*Proof sketch.* Everything is entrywise. Multiplicativity is the only non-formal item: $(AB)_{ij} = \sum_k A_{ik}B_{kj}$ is a finite sum of products of finite hyperreals, so Lemma 2.1(4) moves $\mathrm{st}$ inside the sum and Lemma 2.1(2) moves it inside each product. $\square$

**Proposition 2.4 (Observation detects the infinitesimal halo).** Let $A,B$ have finite entries. Then
$$A \text{ is infinitesimal} \iff \mathrm{st}(A)=0, \qquad A \approx B \iff \mathrm{st}(A)=\mathrm{st}(B).$$

*Proof sketch.* Entrywise application of Lemma 2.1(1) and (3). $\square$

Proposition 2.4 says the fibres of $\mathrm{st}$ over $M_n(\mathbb{R})$, restricted to finite-entry matrices, are exactly the infinitesimal halos.

**Proposition 2.5 (Approximate symmetry descends).** If $A$ has finite entries and $A^{\mathsf T} \approx A$, then $\mathrm{st}(A)$ is symmetric.

*Proof sketch.* $\mathrm{st}(A)^{\mathsf T} = \mathrm{st}(A^{\mathsf T}) = \mathrm{st}(A)$ by Theorem 2.3 and Proposition 2.4. $\square$

### 2.3 Entrywise versus operator-theoretic infinitesimality

Call a hyperreal vector $v \in (\mathbb{R}^*)^n$ **finite** if each coordinate is.

**Theorem 2.6 (Entrywise $=$ operator-theoretic).** A hyperreal matrix $A$ is entrywise infinitesimal if and only if $Av$ is an infinitesimal vector for every finite hyperreal vector $v$.

*Proof sketch.* ($\Rightarrow$) $(Av)_i = \sum_k A_{ik}v_k$ is a finite sum of (infinitesimal)$\times$(finite), hence infinitesimal by Lemma 2.1(5) and (4). ($\Leftarrow$) Apply the hypothesis to the standard basis vector $e_j$, which is finite; then $(Ae_j)_i = A_{ij}$. $\square$

Thus "entrywise infinitesimal" is intrinsic: it says $A$ has infinitesimal operator norm. In finite dimensions all norms are equivalent, and Theorem 2.6 is the non-Archimedean shadow of that fact. This justifies the entrywise formulation used throughout without loss of generality.

---

## 3. The Descent Theorem

**Definition 3.0.** A family $Q : \iota \to M_n(\mathbb{R})$ is a **projection-valued measure (PVM)** if
$$Q_aQ_a = Q_a \ \ (\forall a), \qquad Q_aQ_b = 0 \ \ (a \ne b), \qquad \textstyle\sum_a Q_a = I.$$
A family $P : \iota \to M_n(\mathbb{R}^*)$ is an **approximate hyperreal PVM** if
$$\text{(F) each } P_a \text{ has finite entries}, \qquad \text{(O) } P_aP_b \text{ is infinitesimal for } a \ne b, \qquad \text{(C) } \textstyle\sum_a P_a \approx I.$$

**Theorem 3.1 (Descent Theorem).** Let $P : \iota \to M_n(\mathbb{R}^*)$ satisfy (F). Then
$$\big(\mathrm{st}(P_a)\big)_{a\in\iota} \text{ is a PVM} \iff \text{(O) and (C) hold}.$$
Equivalently, $P$ is an approximate hyperreal PVM if and only if its observation is a PVM.

*Proof sketch.* ($\Leftarrow$) Write $Q_a := \mathrm{st}(P_a)$. By Theorem 2.3 and Proposition 2.4, (O) gives $Q_aQ_b = \mathrm{st}(P_aP_b) = 0$ for $a \ne b$, and (C) gives $\sum_a Q_a = \mathrm{st}(\sum_a P_a) = \mathrm{st}(I) = I$. Idempotency of each $Q_a$ then follows from Lemma 3.2 below.
($\Rightarrow$) Conversely, if $(Q_a)$ is a PVM then $\mathrm{st}(P_aP_b) = Q_aQ_b = 0$ for $a\neq b$, and $P_aP_b$ has finite entries, so it is infinitesimal by Proposition 2.4; similarly $\mathrm{st}(\sum_a P_a) = I = \mathrm{st}(I)$ gives $\sum_a P_a \approx I$. $\square$

**Lemma 3.2 (Idempotency is free, real version).** If $Q : \iota \to M_n(\mathbb{R})$ satisfies $Q_aQ_b = 0$ for $a\ne b$ and $\sum_a Q_a = I$, then $Q_aQ_a=Q_a$ for every $a$.

*Proof.* $Q_a = Q_a I = Q_a\sum_b Q_b = \sum_b Q_aQ_b = Q_aQ_a$, all cross terms vanishing. $\square$

**Theorem 3.3 (Redundancy of approximate idempotency).** If $P$ satisfies (F), (O), (C), then $P_aP_a \approx P_a$ for every $a$.

*Proof sketch.* By Theorem 3.1 the observation is a PVM, so $\mathrm{st}(P_aP_a) = \mathrm{st}(P_a)^2 = \mathrm{st}(P_a)$, and Proposition 2.4 converts this into $P_aP_a \approx P_a$. $\square$

**Remark 3.4 (Minimality).** Theorem 3.3 shows the hypothesis list (F), (O), (C) is exactly right: no idempotency assumption is needed, and (by Theorem 3.1) each of (O), (C) is equivalent to a corresponding assertion about the observation, so neither is implied by the other together with (F). Indeed, taking $\iota$ a singleton and $P_1 = 2I$ satisfies (F) and (O) vacuously but not (C); taking $\iota$ of size $2$ with $P_1 = P_2 = \tfrac12 I$ satisfies (F) and (C) but not (O), since $P_1P_2 = \tfrac14 I$ is not infinitesimal.

### 3.1 Sharpness of the finiteness hypothesis

**Theorem 3.5 (Failure of "if" without (F)).** There is a family $P : \{1,2\} \to M_2(\mathbb{R}^*)$ with $P_aP_b = 0$ **exactly** for $a\ne b$ and $P_1 + P_2 = I$ **exactly**, whose observation is not a PVM.

*Proof.* Put
$$P_1 = \begin{pmatrix} 2 & \omega \\ -2\omega^{-1} & -1 \end{pmatrix}, \qquad P_2 = I - P_1.$$
A direct computation using $\omega\cdot\omega^{-1}=1$ gives $P_1^2 = P_1$: the $(1,1)$ entry is $4 + \omega(-2\omega^{-1}) = 2$, the $(1,2)$ entry is $2\omega - \omega = \omega$, the $(2,1)$ entry is $-4\omega^{-1}+2\omega^{-1} = -2\omega^{-1}$, and the $(2,2)$ entry is $-2 + 1 = -1$. Hence $P_1P_2 = P_1 - P_1^2 = 0 = P_2P_1$ and $P_1+P_2=I$: an exact hyperreal PVM. But
$$\mathrm{st}(P_1) = \begin{pmatrix} 2 & 0 \\ 0 & -1\end{pmatrix},$$
because $\mathrm{st}(\omega)=0$ by convention on infinite elements and $\mathrm{st}(-2\omega^{-1})=0$ since $2\omega^{-1}$ is infinitesimal. This matrix has $(1,1)$ entry of its square equal to $4 \ne 2$, so it is not idempotent and the observed family is not a PVM. $\square$

The mechanism is transparent: the product $\omega \cdot (-2\omega^{-1}) = -2$ is a finite quantity manufactured from an infinite entry and an infinitesimal one. Entrywise observation destroys both factors and hence loses the contribution.

**Theorem 3.6 (Failure of "only if" without (F)).** There is a family $P : \{1,2\} \to M_1(\mathbb{R}^*)$ whose observation is a PVM, but with $P_1P_2$ not infinitesimal.

*Proof.* Take $P_1 = (1)$ and $P_2 = (\omega)$. Then $\mathrm{st}(P_1)=(1)$ and $\mathrm{st}(P_2)=(0)$: idempotent, orthogonal, summing to $(1)=I$, hence a PVM on $\mathbb{R}^1$. But $P_1P_2 = (\omega)$ is infinite, so certainly not infinitesimal. $\square$

Together, Theorems 3.5 and 3.6 show that (F) cannot be weakened in either direction, and that observation is discontinuous exactly at infinite entries.

---

## 4. Dimension quantization and the geometry of the observation

**Lemma 4.1 (Trace of an idempotent).** If $Q \in M_n(\mathbb{R})$ satisfies $Q^2=Q$, then $\mathrm{tr}\,Q = \mathrm{rank}\,Q$ as a real number.

*Proof sketch.* The linear endomorphism $T$ of $\mathbb{R}^n$ induced by $Q$ is idempotent, so it is the projection onto its range along its kernel and $\mathbb{R}^n = \mathrm{range}(T)\oplus\ker(T)$. In a basis adapted to this splitting, $T$ is $\mathrm{diag}(1,\dots,1,0,\dots,0)$ with $\dim\mathrm{range}(T)$ ones. Trace is basis-independent, so $\mathrm{tr}\,Q = \dim\mathrm{range}(T)=\mathrm{rank}\,Q$. $\square$

**Theorem 4.2 (Dimension quantization).** If $Q:\iota\to M_n(\mathbb{R})$ is a PVM, then
$$\sum_{a\in\iota}\mathrm{rank}\,Q_a = n.$$

*Proof.* By Lemma 4.1 and linearity of trace, $\sum_a \mathrm{rank}\,Q_a = \sum_a \mathrm{tr}\,Q_a = \mathrm{tr}\big(\sum_a Q_a\big) = \mathrm{tr}(I) = n$, an identity of real numbers between natural numbers. $\square$

**Corollary 4.3 (Quantized observed weights).** Let $P$ be an approximate hyperreal PVM. Then for each $a$ there is $k_a \in \mathbb{N}$ with $k_a \le n$ and
$$\mathrm{st}\big(\mathrm{tr}\,P_a\big) = k_a = \mathrm{rank}\,\mathrm{st}(P_a), \qquad \sum_a k_a = n.$$

*Proof sketch.* $\mathrm{tr}\,P_a$ is a finite sum of finite hyperreals, so $\mathrm{st}(\mathrm{tr}\,P_a) = \mathrm{tr}\,\mathrm{st}(P_a)$ by Lemma 2.1(4). By Theorem 3.1 the observation is a PVM, so Lemma 4.1 applies, and the bound $k_a \le n$ and the sum rule follow from Theorem 4.2. $\square$

This is a genuine quantization phenomenon. The hyperreal traces range over a continuum — anything in the halo of an integer, e.g. $1+\varepsilon$ or $2-3\varepsilon^2$ — while the observed traces are forced onto $\{0,1,\dots,n\}$.

**Theorem 4.4 (Geometry of the observed channels).** Let $Q:\iota\to M_n(\mathbb{R})$ be a PVM and let $V_a := \mathrm{range}(Q_a) \subseteq \mathbb{R}^n$. Then:
1. $Q_a v = v$ for every $v \in V_a$;
2. $V_a \cap V_b = 0$ for $a \ne b$;
3. $\sum_a V_a = \mathbb{R}^n$;
4. the family $(V_a)$ is independent in the lattice of subspaces.

*Proof sketch.* (1) If $v = Q_a w$ then $Q_a v = Q_a^2 w = Q_a w = v$. (2) If $v \in V_a \cap V_b$, then $Q_a v = v$ by (1) while $v = Q_b w$ gives $Q_a v = Q_aQ_b w = 0$; hence $v = 0$. (3) $v = Iv = \sum_a Q_a v$ with $Q_a v \in V_a$. (4) The same argument as (2) with $V_b$ replaced by $\sum_{b\neq a}V_b$: every element of that sum is killed by $Q_a$, while every element of $V_a$ is fixed by it. $\square$

**Theorem 4.5 (Observation is an internal direct sum decomposition).** For an approximate hyperreal PVM $P$, writing $V_a := \mathrm{range}\,\mathrm{st}(P_a)$,
$$\mathbb{R}^n = \bigoplus_{a\in\iota} V_a, \qquad \sum_a \dim V_a = n.$$

*Proof.* Theorem 3.1 makes $(\mathrm{st}(P_a))$ a PVM; independence and spanning from Theorem 4.4 give the internal direct sum; the dimension count is Theorem 4.2. $\square$

**Interpretation.** The observable content of a non-Archimedean spectral measurement is exactly an integral orthogonal decomposition of $\mathbb{R}^n$. Whatever the infinitesimal structure of the apparatus, its shadow is a clean splitting of space into finitely many subspaces of integer dimension.

---

## 5. Functional calculus

**Lemma 5.1 (Powers).** If $A$ has finite entries, so does $A^k$ for every $k \ge 0$, and $\mathrm{st}(A^k) = \mathrm{st}(A)^k$.

*Proof.* Induction on $k$: the base case is $\mathrm{st}(I)=I$, and the step is Theorem 2.3 applied to $A^{k+1} = A^k A$. $\square$

For a real polynomial $p(X) = \sum_{i} c_i X^i$ we write $p^{*}(A) := \sum_{i=0}^{\deg p} c_i A^i$ for the evaluation at a hyperreal matrix, coefficients coerced into $\mathbb{R}^*$, and $p(M)$ for the ordinary evaluation at a real matrix.

**Theorem 5.2 (Polynomial functional calculus descends).** For any real polynomial $p$ and any finite-entry $A \in M_n(\mathbb{R}^*)$, the matrix $p^{*}(A)$ has finite entries and
$$\mathrm{st}\big(p^{*}(A)\big) = p\big(\mathrm{st}(A)\big).$$

*Proof sketch.* $p^{*}(A)$ is a finite sum of terms $c_iA^i$, each with finite entries by Lemma 5.1 and closure under scalar multiplication by a finite scalar. Then $\mathrm{st}$ passes through the sum (Theorem 2.3), through the scalar multiplication (Lemma 2.1(2), as $\mathrm{st}(c_i)=c_i$ for a real coefficient), and through the power (Lemma 5.1). $\square$

**Corollary 5.3 (Approximate annihilators become exact).** If $p$ is a real polynomial, $A$ has finite entries, and $p^{*}(A)$ is entrywise infinitesimal, then $p(\mathrm{st}(A)) = 0$ exactly.

*Proof.* By Theorem 5.2, $p(\mathrm{st}(A)) = \mathrm{st}(p^*(A)) = 0$ by Proposition 2.4. $\square$

Two instances are worth naming:
* $p = X^2 - X$: an approximately idempotent finite-entry hyperreal matrix ($A^2 \approx A$) is observed as an exact idempotent.
* $p = X^2 - 1$: an approximate involution ($A^2 \approx I$) is observed as an exact involution, $\mathrm{st}(A)^2 = I$.

Thus the minimal polynomial of the observed matrix divides any polynomial that annihilates the hyperreal matrix even approximately. Whole spectral constraints — annihilating polynomials, algebraicity relations, degree bounds — are exactly as visible in the shadow as in the original, provided entries are finite.

---

## 6. Coarse-graining and spectral collapse

Let $f : \iota \to \kappa$ be a map of finite index sets: a *merging scheme*, telling us which fine channels are lumped into which coarse channel.

**Definition.** The coarse-grained families are
$$(f_*Q)_k := \sum_{a : f(a)=k} Q_a, \qquad (f_*P)_k := \sum_{a : f(a)=k} P_a .$$

**Theorem 6.1 (Coarse-graining preserves the class, and commutes with observation).**
1. If $Q$ is a real PVM then so is $f_*Q$.
2. If $P$ has finite entries then so does $(f_*P)_k$, and $\mathrm{st}\big((f_*P)_k\big) = (f_*\mathrm{st}(P))_k$.
3. If $P$ is an approximate hyperreal PVM then so is $f_*P$.

*Proof sketch.* (1) Orthogonality: for $k \ne l$, expanding the double sum $\big(\sum_{f(a)=k}Q_a\big)\big(\sum_{f(b)=l}Q_b\big)$ gives only terms $Q_aQ_b$ with $f(a)\ne f(b)$, hence $a \ne b$, hence $0$. Completeness: $\sum_k (f_*Q)_k = \sum_a Q_a = I$ by summing fibrewise. Idempotency then comes free from Lemma 3.2. (2) is Theorem 2.3 applied to a finite sum. (3) Combine (1), (2) and Theorem 3.1. $\square$

Part (3) has a pleasant reading: the diagram "coarse-grain then observe" equals "observe then coarse-grain". No information about which merges are legitimate is lost by observing first.

**Theorem 6.2 (Observation of a hyperreal spectral decomposition).** Let $(P_a)$ have finite entries and let $(\lambda_a)$ be finite hyperreal scalars. Then
$$\mathrm{st}\Big(\sum_a \lambda_a P_a\Big) = \sum_a \mathrm{st}(\lambda_a)\,\mathrm{st}(P_a).$$

*Proof sketch.* Sum and scalar multiplication both commute with $\mathrm{st}$ under finiteness (Theorem 2.3 and Lemma 2.1(2)). $\square$

**Theorem 6.3 (Spectral collapse).** Suppose in addition that the observed eigenvalues depend only on the class of the index: there is $f : \iota \to \kappa$ and $\mu : \kappa \to \mathbb{R}$ with $\mathrm{st}(\lambda_a) = \mu(f(a))$ for all $a$. Then
$$\mathrm{st}\Big(\sum_a \lambda_a P_a\Big) = \sum_{k \in \kappa} \mu(k)\,\big(f_*\mathrm{st}(P)\big)_k ,$$
a spectral decomposition over the coarse-grained observed projections. If $P$ is an approximate PVM, the coarse family is a PVM by Theorem 6.1.

*Proof sketch.* Apply Theorem 6.2, then regroup the sum over $a$ fibrewise over $\kappa$, factoring $\mu(k)$ out of the $k$-th fibre using $\mathrm{st}(\lambda_a)=\mu(f(a))=\mu(k)$. $\square$

**Interpretation.** Eigenvalues separated only by an infinitesimal — $\lambda$ and $\lambda + \varepsilon$ — produce a single observed spectral line, whose projection is the *sum* of the two fine projections. This is not a resolution limit imposed by noise; it is a theorem. Infinitesimal spectral splitting is unobservable in principle, and the observed decomposition is always the coarsest one consistent with the observed spectrum.

---

## 7. Surjectivity, fibres, strictness and rigidity

Let $\lambda(M) \in M_n(\mathbb{R}^*)$ denote the canonical **lift** of a real matrix $M$, obtained by regarding each real entry as a hyperreal. Clearly $\lambda(M)$ has finite entries and $\mathrm{st}(\lambda(M)) = M$; moreover $\lambda$ is a ring homomorphism ($\lambda(MN)=\lambda(M)\lambda(N)$, $\lambda(I)=I$, $\lambda$ additive) and is injective.

**Theorem 7.1 (Observation is surjective).** Every real PVM $Q$ is the observation of an approximate hyperreal PVM, namely of $(\lambda(Q_a))_a$, which is in fact an *exact* hyperreal PVM.

*Proof.* $\lambda$ preserves the three defining identities because it is a ring homomorphism, and $\mathrm{st}\circ\lambda = \mathrm{id}$. $\square$

**Proposition 7.2 (Fibres are halos).** For finite-entry families $P, P'$,
$$\big(\forall a,\ P_a \approx P'_a\big) \iff \big(\forall a,\ \mathrm{st}(P_a) = \mathrm{st}(P'_a)\big).$$
In particular, infinitesimally close approximate PVMs have equal observed ranks channel by channel.

*Proof.* Proposition 2.4, channelwise; ranks depend only on the observed matrices. $\square$

**Theorem 7.3 (The approximate class is strictly larger).** The two-channel family
$$P_1 = \begin{pmatrix}1 & \varepsilon\\ 0 & 0\end{pmatrix}, \qquad P_2 = \begin{pmatrix}0&0\\0&1\end{pmatrix}$$
is an approximate hyperreal PVM, is observed as the real PVM $\big(\mathrm{diag}(1,0),\mathrm{diag}(0,1)\big)$, and satisfies $P_1P_2 \ne 0$ and $P_1 + P_2 \ne I$.

*Proof.* All entries are finite. One computes $P_1P_2 = \begin{pmatrix}0&\varepsilon\\0&0\end{pmatrix}$, which is entrywise infinitesimal but nonzero, $P_2P_1 = 0$, and $P_1+P_2 = \begin{pmatrix}1&\varepsilon\\0&1\end{pmatrix}$, which is infinitesimally close to $I$ but different from it. Hypotheses (F), (O), (C) hold, so Theorem 3.1 applies. $\square$

This example is what prevents the whole theory from being a re-labelling of real linear algebra: the approximate class strictly contains the exact class. Nevertheless:

**Theorem 7.4 (Rigidity).** Let $P$ be an approximate hyperreal PVM. Then there is an **exact** hyperreal PVM $R$ (i.e. $R_aR_a=R_a$, $R_aR_b=0$ for $a\ne b$, $\sum_a R_a = I$, all on the nose) with finite entries such that
$$P_a \approx R_a \quad\text{and}\quad \mathrm{st}(R_a)=\mathrm{st}(P_a) \quad \text{for all } a.$$
Explicitly, $R_a = \lambda(\mathrm{st}(P_a))$.

*Proof.* By Theorem 3.1, $(\mathrm{st}(P_a))_a$ is a real PVM; by Theorem 7.1 its lift $R$ is an exact hyperreal PVM with finite entries. Since $\mathrm{st}(R_a) = \mathrm{st}(P_a)$, Proposition 2.4 gives $P_a \approx R_a$. $\square$

No symmetry hypothesis is needed. What symmetry buys is a symmetric model:

**Theorem 7.5 (Symmetric rigidity).** If in addition $P_a^{\mathsf T} \approx P_a$ for all $a$, the exact model $R$ of Theorem 7.4 satisfies $R_a^{\mathsf T} = R_a$: an exact *orthogonal* resolution of the identity over $\mathbb{R}^*$.

*Proof.* Proposition 2.5 makes $\mathrm{st}(P_a)$ symmetric, and $\lambda$ commutes with transposition. $\square$

**Theorem 7.6 (Uniqueness among lifts).** If $Q, Q' : \iota \to M_n(\mathbb{R})$ satisfy $\lambda(Q_a) \approx \lambda(Q'_a)$ for all $a$, then $Q = Q'$.

*Proof.* Apply $\mathrm{st}$ and use $\mathrm{st}\circ\lambda = \mathrm{id}$ with Proposition 2.4. $\square$

**Corollary 7.7 (The thickening is non-trivial but tight).** There exists an approximate hyperreal PVM which is *not* an exact hyperreal PVM but is infinitesimally close to one: the family of Theorem 7.3. Moreover the exact model produced by Theorem 7.4 has the same observed ranks as $P$, and those ranks sum to $n$.

Combining, the structure of the theory is completely determined:

> Observation is a surjection from the class of finite-entry approximate hyperreal PVMs onto the class of real PVMs; its fibres are exactly the infinitesimal halos; each fibre contains a canonical exact hyperreal PVM, unique among lifts of real families; and the fibres are non-trivial, containing inexact members.

So the approximate world is an infinitesimally thin thickening of the exact world — strictly bigger, but with nothing new at any observable scale.

---

## 8. The observed Born measure and its entropy

**Definition 8.0.** For a real PVM $Q$ and a vector $v \in \mathbb{R}^n$, the **Born weight** of channel $a$ is
$$p_a := v^{\mathsf T} Q_a v .$$

**Proposition 8.1 (The observed Born measure is a probability measure).** If $Q$ is a PVM and $v^{\mathsf T}v = 1$, then $\sum_a p_a = 1$. If in addition each $Q_a$ is symmetric, then $p_a \ge 0$ for all $a$.

*Proof.* $\sum_a p_a = v^{\mathsf T}\big(\sum_a Q_a\big)v = v^{\mathsf T}v = 1$. For nonnegativity, symmetry and idempotency give $v^{\mathsf T}Q_a v = v^{\mathsf T}Q_a^{\mathsf T}Q_a v = \|Q_a v\|^2 \ge 0$. $\square$

Symmetry is load-bearing: a non-symmetric idempotent (an oblique projection) can have negative Born weight, e.g. $Q = \begin{pmatrix}1 & -3 \\ 0 & 0\end{pmatrix}$ with $v = (1,1)^{\mathsf T}/\sqrt 2$ gives $p = -1$.

**Proposition 8.2 (Push-forward under coarse-graining).** For any merging scheme $f:\iota\to\kappa$,
$$v^{\mathsf T}(f_*Q)_k v = \sum_{a:f(a)=k} p_a .$$

*Proof.* Linearity of $M \mapsto v^{\mathsf T}Mv$. $\square$

Define the **observed entropy** $H(Q,v) := \sum_a \eta(p_a)$, where $\eta(t) := -t\log t$ for $t>0$ and $\eta(0):=0$.

**Lemma 8.2b (Scalar engine).** Let $s$ be a finite set and $p : s \to [0,\infty)$ with $S := \sum_{i\in s}p_i$. Then
$$\eta(S) \le \sum_{i\in s}\eta(p_i),$$
with strict inequality whenever two distinct indices $a\neq b$ in $s$ have $p_a, p_b > 0$.

*Proof sketch.* If $S=0$ all $p_i$ vanish and both sides are $0$. If $S>0$, then for each $i$ with $p_i > 0$ we have $p_i \le S$, so $\log p_i \le \log S$, hence $-p_i\log S \le -p_i \log p_i = \eta(p_i)$; the inequality also holds trivially when $p_i=0$. Summing over $i$ and using $\sum_i (-p_i \log S) = -S\log S = \eta(S)$ gives the claim. For strictness, if $p_a,p_b>0$ with $a\ne b$ then $p_a < S$ strictly (since $p_b>0$ contributes), so $\log p_a < \log S$ and the $a$-th inequality is strict. $\square$

Only monotonicity of $\log$ is used — no concavity machinery.

**Theorem 8.3 (Entropy monotonicity under coarse-graining).** Let $Q$ be a PVM with all $Q_a$ symmetric, $v \in \mathbb{R}^n$, and $f : \iota \to \kappa$ any merging scheme. Then
$$H(f_*Q, v) \le H(Q,v).$$

*Proof.* Regroup $H(Q,v) = \sum_k \sum_{a:f(a)=k}\eta(p_a)$ fibrewise, and apply Lemma 8.2b within each fibre, using Proposition 8.2 to identify the coarse weight as the fibre sum and Proposition 8.1 for nonnegativity. $\square$

**Theorem 8.4 (Strict loss).** If two distinct channels $a\ne b$ with $f(a)=f(b)$ satisfy $p_a > 0$ and $p_b > 0$, then $H(f_*Q,v) < H(Q,v)$.

*Proof.* Same regrouping, with the strict case of Lemma 8.2b applied to the fibre over $f(a)$ and the non-strict case elsewhere. $\square$

**Theorem 8.5 (Sharp equality criterion).** Under the hypotheses of Theorem 8.3,
$$H(f_*Q,v) = H(Q,v) \iff \big(\forall a,b:\ f(a)=f(b),\ p_a\ne 0,\ p_b\ne0 \implies a=b\big),$$
i.e. equality holds exactly when no two distinct channels of nonzero weight are merged.

*Proof sketch.* ($\Leftarrow$) If each fibre carries at most one channel of nonzero weight, then within a fibre either all weights vanish (both sides contribute $\eta(0)=0$) or exactly one weight $p_a$ is nonzero and the fibre sum equals $p_a$, so the contributions agree. ($\Rightarrow$) Contrapositive: if two distinct channels of nonzero weight share a fibre then their weights are positive by Proposition 8.1, and Theorem 8.4 gives strict inequality. $\square$

**Corollary 8.6 (Non-Archimedean form).** If $P$ is an approximate hyperreal PVM whose observed channels are symmetric, then for every $v$ and every merging scheme $f$,
$$H\big(f_*\mathrm{st}(P), v\big) \le H\big(\mathrm{st}(P), v\big).$$

*Proof.* Theorem 3.1 plus Theorem 8.3. $\square$

The hyperreal input enters only through the descent theorem, which guarantees that the observation is a PVM at all. Once the shadow is taken, the argument never leaves the reals — which is precisely the point of the programme.

---

## 9. Algorithms

The theory is effective on any field in which infinitesimals can be represented symbolically. We record the two computational primitives.

**Observation (standard part of a matrix).** Represent a hyperreal entry as a truncated Laurent-type expression $\sum_{k=-K}^{K} c_k \omega^{k}$ in a formal infinite element $\omega$ (equivalently, in $\varepsilon = \omega^{-1}$). Then the entry is infinite iff some $c_k \ne 0$ with $k > 0$, infinitesimal iff $c_k = 0$ for all $k \ge 0$, and, when finite, its standard part is $c_0$. Observation of a matrix applies this entrywise, costing $O(n^2 K)$ operations.

**Descent test.** Given $(P_a)_{a\in\iota}$ over this representation:
1. verify finiteness of every entry, i.e. $c_k = 0$ for $k>0$; if it fails, report that the theorem does not apply (and the family may or may not descend — both failures occur);
2. compute $P_aP_b$ for $a \ne b$ symbolically and check that all coefficients $c_k$ with $k \ge 0$ vanish;
3. compute $\sum_a P_a - I$ and check the same;
4. if steps 2–3 pass, output the observed PVM $(\mathrm{st}(P_a))$, its ranks, and the certificate $\sum_a \mathrm{rank} = n$.

Step 2 dominates: $O(m^2 n^3 K)$ field operations for $m$ channels of size $n$ with truncation order $K$, since each of the $O(m^2)$ symbolic matrix products costs $O(n^3)$ coefficient convolutions of length $O(K)$.

**Rigidity (exact model).** By Theorem 7.4 the exact model is $R_a := \lambda(\mathrm{st}(P_a))$ — computed by observing and re-embedding, at cost $O(mn^2K)$ — and the entrywise distance $P_a - R_a$ is a certified infinitesimal matrix.

---

## 10. Discussion

### 10.1 What the theory says

The results assemble into a single statement about observability. Passing from a non-Archimedean apparatus to what a real observer records:

* **Invisible:** infinitesimal cross-talk between channels; an infinitesimal deficit or excess in total efficiency; infinitesimal spectral splitting; infinitesimal asymmetry of a channel; any infinitesimal failure of a polynomial identity.
* **Visible:** everything at finite scale, and — destructively — infinite entries, which break the correspondence in both directions.
* **Created by observation:** integrality. Continuum-valued channel traces are snapped to the natural numbers $\{0,\dots,n\}$; the observed object is always an internal direct sum decomposition of $\mathbb{R}^n$ with integer dimensions summing to $n$.

The finiteness hypothesis is thus not bookkeeping but the substantive content. Boundedness of the instrument's dynamic range, not exactness of its calibration, is what the correspondence requires.

### 10.2 Relation to standard viewpoints

The formalism resembles, but is not, the theory of positive operator-valued measures. There the algebra is genuinely weakened; here it is kept intact and the *field* is enlarged instead, so that the exact identities can be satisfied modulo an ideal of infinitesimals. The rigidity theorem shows the two moves are not the same: unlike a POVM, an approximate hyperreal PVM is always infinitesimally close to an exact PVM, so no genuinely new operator-algebraic phenomena appear at observable scale. What is gained is a *calculus of error inside the number system*: statements such as "cross-talk is negligible" become exact algebraic assertions rather than epsilon-delta bookkeeping, and the descent theorem then converts them, once and for all, into exact real statements.

The transfer principle explains part of this but not all. Transfer moves internal first-order statements between $\mathbb{R}$ and $\mathbb{R}^*$; the map $\mathrm{st}$ is external, collapsing an entire halo to a point, and every theorem above that mentions $\mathrm{st}$ therefore lives outside the transfer-accessible fragment.

### 10.3 Limits of the results

Three limitations should be stated plainly.

1. Everything is finite-dimensional and finitely-indexed. Countably infinite index sets require a notion of hyperfinite summation, and infinite dimension raises genuinely new issues, since Theorem 2.6 (entrywise $=$ operator-theoretic infinitesimality) uses finite dimensionality essentially.
2. The observation map is entrywise. Theorem 2.6 shows this is intrinsically the right notion in finite dimensions, but a basis-free treatment in infinite dimensions would need an operator-norm formulation from the outset — which is exactly where the compensation phenomenon of Theorem 3.5 ($\omega$ against $\omega^{-1}$) would reappear.
3. The convention $\mathrm{st}(x) = 0$ for infinite $x$ makes $\mathrm{st}$ total but discontinuous. All theorems are stated under finiteness hypotheses so that the convention never does mathematical work; the sharpness examples are precisely the cases where it would.

---

## 11. Future directions

**Definability of observation.** We conjecture that $\mathrm{st}$ on matrices is not first-order definable in the language of ordered fields with the internal matrix algebra, so that every theorem here mentioning $\mathrm{st}$ genuinely leaves the internal fragment. The heuristic is that $\mathrm{st}$ collapses the infinitesimal halo to a point, contradicting saturation. The sharpness examples show $\mathrm{st}$ is discontinuous exactly at infinite entries, giving a concrete candidate for the obstruction; and the rigidity theorem shows every observed statement has an exact internal model, so the only possible obstruction is definability of the map itself, not of its image.

**Infinitesimal spectral gap dichotomy.** Theorem 6.3 says that infinitesimally separated spectral lines merge under observation. We expect a dichotomy: for a finite-entry hyperreal symmetric matrix, either the gaps between distinct observed eigenvalues are all appreciable (bounded below by a positive real), in which case the observed spectral projections are the standard parts of the hyperreal ones channel by channel, or some gap is infinitesimal, in which case the observed decomposition is strictly coarser and the fine projections are individually unrecoverable from the shadow. Making the dichotomy quantitative — bounding the observed coarsening in terms of the size of the smallest appreciable gap — would give a non-Archimedean analogue of perturbation-theoretic gap estimates.

**Infinite-dimensional and hyperfinite extensions.** Replace $M_n(\mathbb{R}^*)$ by the internal algebra of hyperfinite-dimensional matrices, indexed by a hyperfinite set. The descent theorem should persist for families with uniformly finite operator norm, but the trace argument behind dimension quantization would produce hypernatural, rather than natural, observed weights — a quantization onto a non-Archimedean lattice.

**Approximate commutant and joint measurement.** If two approximate PVMs approximately commute channelwise, their observations commute exactly, hence admit a joint refinement. Quantifying the converse — how far a pair of exactly commuting real PVMs can be lifted to approximately commuting hyperreal ones, and whether the lift can be chosen canonically — would connect this circle of ideas to almost-commuting-matrix problems.

**Non-Archimedean error budgets.** The entropy results suggest a resource theory in which the infinitesimal slack of an apparatus is a formal parameter. If the slack is $O(\varepsilon^k)$ for varying $k$, one obtains a filtration of the approximate class; the descent theorem is insensitive to $k$, but finer invariants (rates, second-order corrections) may not be.

---

## 12. Conclusion

The question we set out to answer was: which matrix identities defining a measurement survive observation by a real-valued observer? The answer is complete and clean. Under the single hypothesis that no entry is infinite, the entrywise standard part is a ring homomorphism, and therefore *every* polynomial identity survives. Consequently a family of hyperreal matrices is observed as a projection-valued measure exactly when it is orthogonal up to infinitesimals and complete up to infinitesimals — with idempotency coming free. The finiteness hypothesis is sharp: dropping it breaks the equivalence in both directions, with $2\times2$ and $1\times1$ witnesses.

Beyond the equivalence, observation is surjective with halos as fibres, every approximate measurement is an infinitesimal perturbation of an exact one while the approximate class is strictly larger, the observed channel weights are quantized to natural numbers summing to the dimension, the observed decomposition is an internal direct sum, polynomial functional calculus and coarse-graining commute with observation, infinitesimally separated eigenvalues fuse, and the observed Born distribution has entropy that is monotone under merging with a sharp equality boundary.

The moral: the algebra of an idealized measurement is robust in the strongest possible sense against error below the observer's resolution, and fragile only against magnitude beyond it.
