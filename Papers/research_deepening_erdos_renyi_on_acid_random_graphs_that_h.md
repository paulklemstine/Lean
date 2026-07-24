# Spectral Line-Locking in Fixed-Amplitude Complex-Weighted Undirected Graphs

## Abstract

We study a complex-weighted variant of the Erdős–Rényi random graph in which every present edge of an undirected connection pattern carries a single common complex amplitude $z$. The weighted adjacency matrix then factors as $A = z\,B$, where $B$ is the ordinary real symmetric zero-one indicator matrix of the edge relation. We prove that this factorization forces the spectrum to be **one-dimensional**: for a symmetric edge relation and any nonzero amplitude $z$, every eigenvalue $\lambda$ of $A$ satisfies $\lambda = z\mu$ for some real number $\mu$, so the entire spectrum collapses onto the complex line $\mathbb{R}\cdot z$. This is the exact and sharpest obstruction to a circular-law (disk-filling) limiting spectral distribution. The engine of the result is an elementary Rayleigh-quotient reality theorem, applied to *abstract* eigenpairs rather than only spectral-theorem eigenvalues. We complement line-locking with the global multiplicative invariants of the model — the determinant scales as $z^n\det(B)$ and the loopless trace vanishes — and with a complete-graph analysis showing that the mean-direction eigenvalue $(n-1)z$ escapes the heuristic radius $\sqrt{n}\,|z|$ for every order $n \ge 3$, with the threshold beginning sharply at $n=3$. We discuss why genuine two-dimensional spectra require breaking the scalar–Hermitian factorization through independently phased or directed edges.

**Keywords:** complex-weighted random graphs, adjacency spectrum, Hermitian matrices, Rayleigh quotient, circular law, spectral outliers, Erdős–Rényi model.

---

## 1. Introduction

The Erdős–Rényi random graph $G(n,p)$ places $n$ vertices and includes each undirected edge independently with probability $p$. Its spectral theory is a cornerstone of modern probabilistic combinatorics: the adjacency matrix is real symmetric, its empirical spectral distribution converges to Wigner's semicircle law after centering and scaling, and the top eigenvalue separates as a mean-degree outlier.

A natural and provocative generalization replaces the *probability* $p$ by a *complex amplitude* $z$: rather than recording an edge as present ($1$) or absent ($0$), one records each present edge with a complex weight $z = re^{i\theta}$. Because complex, non-Hermitian random matrices are the natural habitat of the **circular law** — where the empirical spectral distribution fills a two-dimensional disk — one might expect the complex-weighted graph to exhibit disk-filling spectral behavior. The purpose of this paper is to show that, for the *fixed-amplitude undirected* model, this expectation is exactly wrong, and to isolate precisely why.

The central structural fact is that when every present edge carries the *same* amplitude $z$, the weighted adjacency matrix factors as a scalar multiple of a real symmetric matrix:

$$A = z\,B, \qquad B_{ij} \in \{0,1\}, \quad B = B^{\mathsf T}.$$

All randomness and all graph structure reside in $B$; the amplitude $z$ is a single global dial. We prove that this factorization *pins the entire spectrum to a line*. Our main results are:

1. **(Reality of Hermitian eigenvalues, abstract form.)** Any eigenvalue of a Hermitian matrix belonging to a nonzero eigenvector is real.
2. **(Spectral line-locking.)** For a symmetric edge relation and $z \ne 0$, every eigenvalue of $A = zB$ has the form $z\mu$ with $\mu \in \mathbb{R}$; the spectrum lies on $\mathbb{R}\cdot z$.
3. **(Global invariants.)** $\det(A) = z^{n}\det(B)$, and $\operatorname{tr}(A) = 0$ for loopless relations.
4. **(Complete-graph outlier.)** The all-ones vector is an eigenvector of the complete loopless realization with eigenvalue $(n-1)z$, and $|(n-1)z| > \sqrt{n}\,|z|$ for every $n \ge 3$, sharply beginning at $n=3$.

The results are stated for finite graphs and hold *exactly*, not merely asymptotically. Line-locking is therefore not a phenomenon that a limiting law could ever wash out; it is a rigid algebraic constraint.

---

## 2. Definitions and setup

Throughout, $V$ is a finite index set of vertices with $n = |V|$, and matrices are indexed by $V \times V$.

**Definition 2.1 (Edge relation).** An *edge relation* is a function $g : V \times V \to \{\text{true},\text{false}\}$. It is *symmetric* (undirected) if $g(i,j) = g(j,i)$ for all $i,j$, and *loopless* (irreflexive) if $g(i,i) = \text{false}$ for all $i$.

**Definition 2.2 (Indicator matrix).** The *indicator matrix* $B = \operatorname{ind}(g)$ is the real matrix with $B_{ij} = 1$ if $g(i,j)$ is true and $B_{ij} = 0$ otherwise. If $g$ is symmetric then $B$ is a real symmetric matrix, hence Hermitian when regarded over $\mathbb{C}$.

**Definition 2.3 (Fixed-amplitude adjacency matrix).** Given a complex amplitude $z \in \mathbb{C}$ and an edge relation $g$, the *fixed-amplitude adjacency matrix* is the complex matrix $A = \operatorname{adj}(z,g)$ with

$$A_{ij} = \begin{cases} z & \text{if } g(i,j) \text{ is true}, \\ 0 & \text{otherwise}. \end{cases}$$

**Lemma 2.4 (Scalar factorization).** For all $z$ and $g$, $A = z\,B$, i.e. $\operatorname{adj}(z,g) = z\cdot\operatorname{ind}(g)$.

*Proof.* Entrywise: if $g(i,j)$ is true, $A_{ij} = z = z\cdot 1 = z\,B_{ij}$; otherwise $A_{ij} = 0 = z\cdot 0 = z\,B_{ij}$. $\qquad\blacksquare$

This factorization is the pivot of the entire theory. It is established in the companion development of the fixed-amplitude model and underlies each result below. Two consequences that we will use repeatedly:

- **(Hermitian core.)** If $g$ is symmetric, $B$ is Hermitian.
- **(Eigenpair pullback.)** If $A v = \lambda v$ with $z \ne 0$, then $B v = (\lambda/z)\, v$, since $z B v = A v = \lambda v$ and $z$ is invertible.

**Definition 2.5 (Eigenpair).** A pair $(\lambda, v)$ with $v \ne 0$ and $Av = \lambda v$ is an *eigenpair* of $A$; $\lambda$ is an *eigenvalue* and $v$ an *eigenvector*. We work with abstract eigenpairs: any nonzero solution of $Av = \lambda v$, not merely those produced by a spectral decomposition.

---

## 3. Reality of Hermitian eigenvalues

The engine of line-locking is the following elementary but sharp statement. We emphasize that it applies to *any* eigenpair, requiring no spectral theorem.

**Theorem 3.1 (Reality of Hermitian eigenvalues).** Let $A$ be a Hermitian matrix over $\mathbb{C}$ ($A^{*} = A$, where $A^{*}$ is the conjugate-transpose). If $(\mu, v)$ is an eigenpair of $A$ with $v \ne 0$, then $\mu$ is real, i.e. $\overline{\mu} = \mu$.

*Proof sketch.* Consider the Rayleigh scalar $Q = v^{*} A v = \sum_{i} \overline{v_i}\,(Av)_i$. We compute it two ways.

*First,* using $Av = \mu v$,
$$Q = v^{*}(\mu v) = \mu\,(v^{*}v), \qquad v^{*}v = \sum_i \overline{v_i}v_i = \sum_i |v_i|^2.$$
Since $v \ne 0$, the quantity $c := v^{*}v = \sum_i |v_i|^2$ is a strictly positive real number; in particular $c \ne 0$ and $\overline{c} = c$.

*Second,* we show $Q$ is fixed by conjugation. Using the conjugation rule $\overline{a \cdot b} = \overline{a}\cdot\overline{b}$ for dot products together with $\overline{(Av)} = \overline{A}\,\overline{v}$ and the Hermitian identity $A^{*} = A$, a direct manipulation gives $\overline{Q} = v^{*} A v = Q$. Hence $Q$ is real.

Combining, $\mu c = Q = \overline{Q} = \overline{\mu c} = \overline{\mu}\,\overline{c} = \overline{\mu}\, c$. Cancelling the nonzero real $c$ yields $\overline{\mu} = \mu$, so $\mu \in \mathbb{R}$. $\qquad\blacksquare$

The proof uses only three ingredients: bilinearity/conjugate-symmetry of the Hermitian form, positivity of $v^{*}v$ for $v \ne 0$, and the defining identity $A^{*}=A$. No basis, no diagonalization, no continuity. This is why the statement holds for abstract eigenpairs and transfers cleanly to the weighted model.

---

## 4. Spectral line-locking

**Theorem 4.1 (Spectral line-locking).** Let $g$ be a symmetric edge relation on $V$, let $z \in \mathbb{C}$ with $z \ne 0$, and let $A = \operatorname{adj}(z,g)$. If $(\lambda, v)$ is an eigenpair of $A$ ($v \ne 0$, $Av = \lambda v$), then there exists a real number $\mu \in \mathbb{R}$ with

$$\lambda = z\,\mu.$$

Consequently the entire spectrum of $A$ is contained in the complex line $\mathbb{R}\cdot z = \{\, t z : t \in \mathbb{R}\,\}$ through the origin in the direction of $z$.

*Proof.* By Lemma 2.4 the indicator matrix $B = \operatorname{ind}(g)$ satisfies $A = zB$, and since $g$ is symmetric, $B$ is Hermitian. From $Av = \lambda v$ and $z \ne 0$ we obtain the pullback $Bv = (\lambda/z)v$, so $(\lambda/z, v)$ is an eigenpair of the Hermitian matrix $B$. By Theorem 3.1, $\lambda/z$ is real: $\overline{(\lambda/z)} = \lambda/z$, equivalently $\operatorname{Im}(\lambda/z) = 0$. Set $\mu := \operatorname{Re}(\lambda/z) \in \mathbb{R}$. Then $\lambda/z = \mu$ as complex numbers, whence $\lambda = z\mu$. $\qquad\blacksquare$

**Interpretation.** The spectrum of $A$ is the spectrum of $B$ — a set of real numbers — rotated and dilated by the single complex scalar $z$. Since $\mathbb{R}\cdot z$ is a one-real-dimensional subset of $\mathbb{C}$, the empirical spectral distribution of $A$ is supported on a line for *every* finite graph and *every* realization of the randomness in $g$. There is no finite-$n$, and hence no limiting, regime in which the spectrum fills a two-dimensional region.

**Corollary 4.2 (No circular law).** For the fixed-amplitude undirected model, no rescaling of $A$ can have an empirical spectral distribution converging to a rotationally invariant law on a two-dimensional disk. Any nondegenerate limiting spectral distribution is supported on the line $\mathbb{R}\cdot z$.

**Remark 4.3 (Both hypotheses are load-bearing).** The hypothesis $z \ne 0$ is required: at $z = 0$ the matrix is identically zero, the statement is vacuously true, but the *direction* of the line is undefined. The symmetry hypothesis is required: without it $B$ is not Hermitian, its eigenvalues need not be real, and the products $z\mu$ leave the line — precisely the door to two-dimensional spectra discussed in §7.

---

## 5. Global multiplicative invariants

The determinant and trace are basis-independent invariants; the scalar dial $z$ acts on them in a clean, closed form. These are genuine global statements, not entrywise restatements of $A = zB$.

**Theorem 5.1 (Determinant scaling).** For all $z$ and $g$ on $n = |V|$ vertices,
$$\det(A) = z^{\,n}\,\det(B), \qquad A=\operatorname{adj}(z,g),\ B=\operatorname{ind}(g).$$

*Proof.* By Lemma 2.4, $A = z\cdot B$ (scalar multiplication of an $n\times n$ matrix). Homogeneity of the determinant under scalar multiplication gives $\det(zB) = z^{n}\det(B)$. $\qquad\blacksquare$

**Theorem 5.2 (Vanishing loopless trace).** If $g$ is loopless ($g(i,i) = \text{false}$ for all $i$), then $\operatorname{tr}(A) = 0$.

*Proof.* $\operatorname{tr}(A) = \sum_i A_{ii}$. For each $i$, since $g(i,i)$ is false, $A_{ii} = 0$. Hence the sum is $0$. $\qquad\blacksquare$

Together with line-locking, these invariants describe the spectrum globally: the eigenvalues $z\mu_1, \dots, z\mu_n$ (with $\mu_k$ the real eigenvalues of $B$) satisfy $\sum_k z\mu_k = \operatorname{tr}(A) = 0$ in the loopless case (so the real spectrum of $B$ is balanced about the origin), while $\prod_k z\mu_k = \det(A) = z^n\det(B)$.

---

## 6. The complete-graph outlier at every order

We now locate a distinguished point on the line. Let $K_n$ denote the complete loopless relation on $\operatorname{Fin}(n) = \{0,1,\dots,n-1\}$: $g(i,j)$ is true iff $i \ne j$.

**Theorem 6.1 (Mean-direction eigenpair).** For the complete loopless realization on $n$ vertices, the all-ones vector $\mathbf{1} = (1,\dots,1)$ is an eigenvector of $A = \operatorname{adj}(z, K_n)$ with eigenvalue $(n-1)z$:
$$A\,\mathbf{1} = \big((n-1)\,z\big)\,\mathbf{1}.$$

*Proof.* Fix a row $i$. Then $(A\mathbf{1})_i = \sum_{j} A_{ij} = \sum_{j \ne i} z = z\cdot |\{j : j \ne i\}| = z\,(n-1)$, since every off-diagonal entry equals $z$ and the diagonal entry is $0$. This is independent of $i$, so $A\mathbf{1} = (n-1)z\,\mathbf{1}$. (Formally, the count $|\{j : j \ne i\}| = n-1$ is the cardinality of the complement of $\{i\}$ in an $n$-element set.) $\qquad\blacksquare$

By line-locking (Theorem 4.1), $(n-1)z$ indeed lies on $\mathbb{R}\cdot z$, with real coordinate $\mu = n-1$. This is the *mean-direction outlier*: the collective mode in which all vertices oscillate in phase.

**Theorem 6.2 (Outlier escapes the heuristic disk).** Let $z \ne 0$. For every order $n \ge 3$,
$$\big|(n-1)z\big| \;>\; \sqrt{n}\,\lvert z\rvert.$$

*Proof.* Since $z\ne 0$, $|z| > 0$. Because $(n-1) > 0$ for $n\ge 3$, $|(n-1)z| = (n-1)|z|$. Dividing by $|z|>0$, the claim is $(n-1) > \sqrt{n}$, equivalently (both sides positive) $(n-1)^2 > n$, i.e. $n^2 - 3n + 1 > 0$. For $n \ge 3$ this holds: at $n=3$, $9-9+1 = 1 > 0$, and the quadratic is increasing for $n \ge 3$. $\qquad\blacksquare$

**Remark 6.3 (Sharpness at $n=3$).** The bound fails at $n = 2$: there $(n-1)|z| = |z|$ while $\sqrt{2}\,|z| > |z|$, so the eigenvalue $z$ lies strictly *inside* the radius $\sqrt{2}\,|z|$. Thus the outlier phenomenon begins exactly at $n=3$; the classical four-vertex example is representative of the general behavior, not an artifact of small order. The heuristic radius $\sqrt{n}\,|z|$ is the natural energy scale $\|A\|_F/\sqrt{\cdot}$-type comparison; the mean mode's escape from it is the deterministic ($p\to 1$) endpoint of the outlier/bulk separation phenomenon.

---

## 7. Discussion: what forces one-dimensionality

The results assemble into a single principle:

> **Fixed-amplitude complex weighting is spectrally one-dimensional.** A single shared complex scalar can only rotate and dilate a real (Hermitian) spectrum; it can never manufacture the two-dimensional spread required by a circular law.

The obstruction is located precisely in the scalar–Hermitian factorization $A = zB$. All randomness lives inside the Hermitian matrix $B$, whose eigenvalues are pinned to $\mathbb{R}$ by the Rayleigh-quotient argument of Theorem 3.1; the amplitude $z$ then applies a rigid rotation-dilation. No amount of randomness in the *edge set* can break this, because it only reshuffles $B$ within the Hermitian class.

This isolates, in closed form, the exact hypotheses whose violation is necessary for disk-filling behavior:

- **Break symmetry (directed edges):** $g(i,j) \ne g(j,i)$ makes $B$ non-Hermitian, so its eigenvalues may be genuinely complex.
- **Break shared phase (independent phases):** weighting each present edge by an *independent* complex phase destroys the factorization $A = zB$; the randomness no longer sits inside one Hermitian matrix.

Either modification is a candidate route to a circular law. The value of line-locking is that it tells us where *not* to look: the fixed-amplitude undirected model can never exhibit the disk, so the search for two-dimensional spectra must be aimed at the models that violate the factorization.

---

## 8. Algorithmic and numerical content

The theory is fully constructive and yields simple algorithms for verification and exploration:

1. **Line-locking checker.** Given $z$ and a symmetric $g$, form $A = zB$, compute its eigenvalues numerically, and verify that each $\lambda/z$ has negligible imaginary part. Complexity $O(n^3)$ (dominated by the eigensolve).
2. **Spectrum-from-$B$ transport.** Diagonalize the real symmetric $B$ once (real symmetric eigensolver, $O(n^3)$), then obtain the spectrum of $A$ for *any* amplitude $z$ instantly as $\{z\mu_k\}$ — no complex eigensolve required. This exploits the factorization directly.
3. **Outlier locator.** For the complete graph, return the closed-form eigenvalue $(n-1)z$ and compare $|(n-1)z|$ to $\sqrt{n}\,|z|$ in $O(1)$.

The accompanying numerical demonstrations validate line-locking across random symmetric graphs and amplitudes, illustrate determinant/trace scaling, and confirm the $n=3$ threshold of the outlier bound.

---

## 9. Applications

- **Signal propagation on phased networks.** When a network's connections all share a coherent phase (e.g. a common carrier), the resonant modes are exactly the real modes of the underlying topology, rotated by that phase. Line-locking guarantees no spurious two-dimensional resonance structure is introduced by the phase alone.
- **Spectral design.** To place eigenvalues at prescribed complex targets, one cannot rely on a global amplitude; the theorem quantifies exactly the (one-dimensional) reach of that single degree of freedom and shows that independent per-edge control is necessary for two-dimensional placement.
- **Diagnostics for non-Hermitian models.** Observing genuinely two-dimensional spectra in a complex-weighted network is a certificate that the weights are *not* a shared amplitude on an undirected graph — a structural fingerprint of directedness or phase heterogeneity.

---

## 10. Future directions

Three concrete conjectures organize the next steps.

**(1) Two-dimensional spectra require broken phase symmetry.** If each present edge $(i,j)$ carries an *independent* unit-modulus random weight (relaxing $w_{ji} = \overline{w_{ij}}$ toward genuine independence), the empirical spectral distribution of the normalized adjacency matrix should converge, as $n \to \infty$, to a rotationally invariant law on a full two-dimensional disk — the sharp counterpoint to line-locking. The isolated obstruction (the factorization $A=zB$) tells us exactly which models to test.

**(2) A phase-transition threshold for the mean-direction outlier.** For the fixed-amplitude Erdős–Rényi model $G(n,p)$ with weight $z$, there should be a sharp threshold $p^*(n)$ above which the largest-modulus eigenvalue is asymptotically $p(n-1)|z|$ (the mean-direction outlier) while the bulk stays within radius $2\sqrt{np(1-p)}\,|z|$; the outlier separates exactly when $p(n-1) > 2\sqrt{np(1-p)}$. Both endpoints — the deterministic complete-graph outlier $(n-1)z$ and the $|z|$-scaled semicircle radius of the centered indicator matrix — are understood; interpolating across $p$ is the concrete open problem.

**(3) Reality of Rayleigh quotients characterizes the line-locked class.** Among all weighting schemes, the line-locked ones should be characterized precisely by the reality of their Rayleigh quotients — i.e. by an underlying Hermitian core — giving a clean dividing line between one- and two-dimensional spectral behavior.

---

## 11. Conclusion

We have shown that the fixed-amplitude complex-weighted undirected random graph, far from exhibiting the disk-filling spectra of generic non-Hermitian random matrices, has a spectrum rigidly locked to a single line through the origin. The result is exact and finite, driven by an elementary reality theorem for Hermitian Rayleigh quotients, and complemented by clean global invariants and a sharp complete-graph outlier bound. The analysis pins down the precise algebraic obstruction — the scalar–Hermitian factorization — and thereby charts where genuine two-dimensional spectra must be sought: in models with directed or independently phased edges.
