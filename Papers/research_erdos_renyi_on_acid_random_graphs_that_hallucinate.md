# Phase Locking and Spectral Obstructions in Complex-Weighted Undirected Erdős–Rényi Graphs

**Aristotle**  
**July 18, 2026**

## Abstract

We analyze an undirected Bernoulli graph in which each present edge receives one fixed complex amplitude $z$. The Bernoulli parameter $p\in[0,1]$ remains real and governs edge presence; the complex number $z$ is an edge weight, not a probability. For every finite realization, the weighted adjacency matrix factors as $A_z=zB$, where $B$ is the real symmetric zero–one adjacency matrix. This elementary identity creates a complete obstruction to the proposed circular spectral law. The matrix $A_z$ is normal, its adjoint is $A_{\overline z}$, and every eigenvalue is obtained by multiplying a real eigenvalue of $B$ by $z$. Hence the spectrum is confined to the line $z\mathbb R$, both before and after centering, rather than filling a disk. We prove a deterministic row-sum bound $|\lambda|\le |z|R$, establish exact scaling of expected weighted subgraph counts, and exhibit the complete graph on four vertices as a finite counterexample to the universal radius $|z|\sqrt n$. We then give algorithms for simulation and structural diagnostics and explain why directed, centered models—not fixed-phase undirected ones—are the appropriate candidates for circular-law behavior.

## 1. Introduction

The Erdős–Rényi model $G(n,p)$ places an edge independently between each unordered pair of $n$ vertices with probability $p$. Its adjacency matrix is real symmetric, and therefore has a real spectrum. A tempting complex extension gives every present edge a common amplitude $z\in\mathbb C$. Since the entries are then either $0$ or $z$, one might compare the result with a non-Hermitian random matrix and predict a circular cloud of eigenvalues with fluctuation radius on the order of $|z|\sqrt n$.

That comparison overlooks two structural facts. First, the entries mirrored across the diagonal are identical rather than independent. Second, the same phase multiplies every present edge. Consequently, the entire random matrix is a complex scalar multiple of a real symmetric matrix. The complex phase rotates all eigenvalues together and cannot create angular dispersion.

This paper develops the finite-dimensional theory behind that obstruction. No asymptotic theorem is needed to disprove the circular-law interpretation: line confinement holds exactly for every realization and every size. The analysis also separates three issues that are easily conflated:

1. **edge probability**, represented by a real $p\in[0,1]$;
2. **edge amplitude**, represented by a complex $z$;
3. **matrix symmetry**, determined by whether edges are undirected, directed, or paired by complex conjugation.

The main results are as follows.

* **Scalar factorization and phase locking.** If $B$ is the ordinary adjacency matrix, then $A_z=zB$ and $\sigma(A_z)=z\sigma(B)\subseteq z\mathbb R$.
* **Adjoint relation and normality.** One has $A_z^*=A_{\overline z}$ and $A_zA_z^*=A_z^*A_z$.
* **Deterministic radial control.** A row-sum bound $R$ for $B$ yields $|\lambda|\le |z|R$ for every weighted eigenvalue.
* **Finite obstruction to a universal square-root disk.** For the complete graph on four vertices, $3z$ is an eigenvalue and lies outside the disk of radius $2|z|$ whenever $z\ne0$.
* **Expected weighted count formula.** Common complex weighting rotates and dilates the usual real first moment: $\mathbb E[zN]=z\sum_r p^{|S_r|}$.

These statements show that normality alone is not the decisive property. General normal matrices may have two-dimensional spectra. Here the stronger scalar–symmetric factorization forces line confinement. They also show that a disk bound must not be confused with disk filling.

## 2. The model

### 2.1 Undirected Bernoulli graphs

Let $V=\{1,\dots,n\}$, and let

$$
E_0=\bigl\{\{i,j\}:1\le i<j\le n\bigr\}
$$

be the set of possible loopless undirected edges. Fix $p\in[0,1]$. For each $e\in E_0$, choose an independent Bernoulli random variable $X_e$ with

$$
\mathbb P(X_e=1)=p,\qquad \mathbb P(X_e=0)=1-p.
$$

A realization determines a graph $G$. Its indicator adjacency matrix $B\in\mathbb R^{n\times n}$ is defined by

$$
B_{ij}=\begin{cases}
X_{\{i,j\}},&i\ne j,\\
0,&i=j.
\end{cases}
$$

Thus $B_{ij}=B_{ji}$ and $B=B^{\mathsf T}=B^*$. In particular, $B$ is Hermitian and all of its eigenvalues are real.

### 2.2 Fixed complex amplitude

Fix $z\in\mathbb C$. The complex-weighted adjacency matrix $A_z$ is

$$
(A_z)_{ij}=\begin{cases}
z,&B_{ij}=1,\\
0,&B_{ij}=0.
\end{cases}
$$

The parameter $p$ is the probability and $z$ is the amplitude. This distinction prevents an invalid interpretation of a general complex number as a probability.

### Definition 2.1 (Fixed-amplitude complex graph)

A fixed-amplitude complex graph is a pair $(G,z)$ consisting of a finite undirected graph $G$ and a complex number $z$, with weighted adjacency matrix $A_z$ as above.

### Definition 2.2 (Phase-locked set)

For $z\in\mathbb C$, define the phase line

$$
L_z=z\mathbb R=\{zt:t\in\mathbb R\}.
$$

If $z\ne0$, this is the line through the origin whose angle is $\arg z$ modulo $\pi$. If $z=0$, it degenerates to $\{0\}$.

## 3. Exact algebraic structure

### Theorem 3.1 (Scalar Factorization Theorem)

For every finite undirected graph $G$ and every $z\in\mathbb C$, the fixed-amplitude adjacency matrix satisfies

$$
A_z=zB.
$$

#### Proof sketch

For each pair $(i,j)$, either the edge is absent, in which case both sides have entry $0$, or it is present, in which case $B_{ij}=1$ and both sides have entry $z$. Equality follows entrywise. $\square$

This theorem says that all randomness resides in the real matrix $B$; $z$ contributes one global dilation and rotation.

### Theorem 3.2 (Adjoint Phase Relation)

For every undirected realization,

$$
A_z^*=A_{\overline z}.
$$

#### Proof sketch

Using $B^*=B$ and the scalar factorization,

$$
A_z^*=(zB)^*=\overline z B^*=\overline z B=A_{\overline z}.
$$

Thus taking the adjoint conjugates only the common amplitude. $\square$

### Theorem 3.3 (Normality Theorem)

Every fixed-amplitude complex adjacency matrix of an undirected graph is normal:

$$
A_zA_z^*=A_z^*A_z.
$$

#### Proof sketch

By Theorem 3.2,

$$
A_zA_z^*=(zB)(\overline zB)=|z|^2B^2,
$$

and the reversed product is the same. $\square$

Normality guarantees unitary diagonalizability. It also implies the exact resolvent identity

$$
\|(wI-A_z)^{-1}\|_2=\frac{1}{\operatorname{dist}(w,\sigma(A_z))}
$$

whenever $w\notin\sigma(A_z)$. This stability sharply contrasts with highly nonnormal directed random matrices. Nevertheless, normality alone does not imply line confinement; that stronger conclusion requires factorization by a Hermitian matrix.

## 4. Spectral phase locking

### Theorem 4.1 (Eigenpair Transport Theorem)

If $v\ne0$ and

$$
Bv=\mu v,
$$

then

$$
A_zv=(z\mu)v.
$$

#### Proof sketch

Substitute $A_z=zB$:

$$
A_zv=zBv=z\mu v.
$$

The eigenvector is unchanged and the eigenvalue is multiplied by $z$. $\square$

### Theorem 4.2 (Eigenpair Pullback Theorem)

Suppose $z\ne0$. If $v\ne0$ and

$$
A_zv=\lambda v,
$$

then

$$
Bv=\frac{\lambda}{z}v.
$$

#### Proof sketch

Divide $A_zv=zBv=\lambda v$ by the nonzero scalar $z$. $\square$

Together these results give the complete spectral description.

### Corollary 4.3 (Phase-Locking Theorem)

For every fixed-amplitude complex graph,

$$
\sigma(A_z)=z\sigma(B)\subseteq L_z.
$$

When $z\ne0$, algebraic multiplicities are preserved under the map $\mu\mapsto z\mu$.

#### Proof sketch

The real symmetric spectral theorem gives an orthonormal basis $v_1,\dots,v_n$ and real numbers $\mu_1,\dots,\mu_n$ satisfying $Bv_k=\mu_kv_k$. Theorem 4.1 gives $A_zv_k=z\mu_kv_k$. These $n$ vectors already form a basis, so no other eigenvalues occur. $\square$

If $z=|z|e^{i\theta}$ and $\lambda\in\sigma(A_z)$, then $e^{-i\theta}\lambda$ is real. Equivalently,

$$
\operatorname{Im}(\lambda\overline z)=0.
$$

This equation is a convenient numerical diagnostic that avoids choosing a branch of the argument.

### Corollary 4.4 (No Two-Dimensional Empirical Limit)

For fixed nonzero $z$, every empirical spectral measure of the form

$$
\nu_n=\frac1n\sum_{k=1}^n\delta_{\lambda_k(A_z)/a_n},
$$

where $a_n>0$ is any real normalization, is supported on $L_z$. Therefore any weak limit is also supported on $L_z$ and cannot equal the uniform probability measure on a disk of positive area.

#### Proof sketch

Positive real scaling preserves $L_z$. Since $L_z$ is closed, a weak limit of probability measures supported there remains supported there. The uniform disk measure assigns full mass to a two-dimensional disk and zero mass to any line, so the two measures cannot coincide. $\square$

### Corollary 4.5 (Centering Does Not Remove Phase Locking)

Let $M=\mathbb E[B]$. Then $M$ is real symmetric and

$$
A_z-\mathbb E[A_z]=z(B-M).
$$

Hence the centered weighted matrix is normal and its spectrum is still contained in $L_z$.

#### Proof sketch

Linearity gives $\mathbb E[A_z]=z\mathbb E[B]=zM$. Both $B$ and $M$ are real symmetric, so $B-M$ is real symmetric. Apply the preceding results to $B-M$. $\square$

Centering can remove a large mean eigenvalue, but it cannot remove the transpose correlation imposed by undirected edges.

## 5. Deterministic spectral bounds

A line describes angular geometry but not radial extent. A standard maximum-coordinate argument gives a robust outer bound.

### Lemma 5.1 (Row-Sum Eigenvalue Bound)

Let $M\in\mathbb R^{n\times n}$ and suppose

$$
\sum_{j=1}^n|M_{ij}|\le R
$$

for every row $i$. If $Mv=\mu v$ for some $v\ne0$, then

$$
|\mu|\le R.
$$

#### Proof sketch

Choose $i$ so that $|v_i|=\max_j|v_j|>0$. Then

$$
|\mu||v_i|=\left|\sum_jM_{ij}v_j\right|
\le\sum_j|M_{ij}||v_j|
\le R|v_i|.
$$

Cancel $|v_i|$. $\square$

### Theorem 5.2 (Scaled Row-Sum Bound)

Under the assumptions of Lemma 5.1, the transported eigenvalue $z\mu$ satisfies

$$
|z\mu|\le |z|R.
$$

#### Proof sketch

Use multiplicativity of the complex modulus and Lemma 5.1:

$$
|z\mu|=|z||\mu|\le |z|R.
$$

$\square$

For a simple graph, each row sum of $B$ equals the degree of the corresponding vertex. If $\Delta(G)$ is the maximum degree, then

$$
\sigma(A_z)\subseteq L_z\cap\{w\in\mathbb C:|w|\le |z|\Delta(G)\}.
$$

The disk is an outer envelope, not a claim of uniform filling. The actual spectrum lies on its intersection with a line.

## 6. A finite counterexample to the square-root radius

The proposed radius $|z|\sqrt n$ cannot bound all realizations of the uncentered model.

### Theorem 6.1 (Complete Four-Vertex Eigenpair)

Let $G=K_4$, the complete loopless graph on four vertices, and let $\mathbf1=(1,1,1,1)^{\mathsf T}$. Then

$$
A_z\mathbf1=3z\mathbf1.
$$

#### Proof sketch

Every vertex of $K_4$ has three neighbors, so every row of $B$ sums to $3$ and $B\mathbf1=3\mathbf1$. Theorem 4.1 transports this eigenpair to $A_z$. $\square$

### Theorem 6.2 (Four-Vertex Square-Root-Disk Obstruction)

If $z\ne0$, the weighted adjacency matrix of $K_4$ has an eigenvalue outside the disk of radius $|z|\sqrt4$.

#### Proof sketch

Theorem 6.1 supplies the eigenvalue $3z$, whose modulus is $3|z|$. Since

$$
3|z|>2|z|=|z|\sqrt4,
$$

the claim follows. $\square$

More generally, $K_n$ has eigenvalue $(n-1)z$ in the all-ones direction. For $n\ge3$, one has $n-1>\sqrt n$, so every nonzero amplitude produces a linear-scale eigenvalue outside the proposed square-root disk. The four-vertex case is a particularly small explicit witness.

This phenomenon is related to the mean component of an uncentered random adjacency matrix. For the loopless Erdős–Rényi model,

$$
\mathbb E[B]=p(J-I),
$$

where $J$ is the all-ones matrix. Its all-ones eigenvalue is $p(n-1)$. Thus the mean direction is naturally of order $pn$, whereas centered fluctuations in a dense regime are expected on the order of $\sqrt{np(1-p)}$. Any circular-law comparison should first subtract the mean.

## 7. Expected weighted subgraph counts

The common amplitude also acts transparently on first moments.

Let $E_0$ be a finite collection of possible edges and let $S_1,\dots,S_m\subseteq E_0$ be prescribed edge sets. For a realization $G\subseteq E_0$, define

$$
N_S(G)=\sum_{r=1}^m\mathbf1_{\{S_r\subseteq G\}}.
$$

This counts the listed patterns whose required edges all occur. The sets may overlap and need not be distinct.

### Lemma 7.1 (Pattern Occurrence Probability)

For each fixed $S_r$,

$$
\mathbb P(S_r\subseteq G)=p^{|S_r|}.
$$

#### Proof sketch

All $|S_r|$ required edges must be present, and their Bernoulli indicators are independent. Multiply their probabilities. $\square$

### Theorem 7.2 (Weighted Subgraph Expectation Formula)

For every $z\in\mathbb C$,

$$
\mathbb E[zN_S]=z\sum_{r=1}^m p^{|S_r|}.
$$

#### Proof sketch

Linearity of expectation does not require the pattern indicators to be independent. Therefore

$$
\mathbb E[N_S]
=\sum_{r=1}^m\mathbb E[\mathbf1_{\{S_r\subseteq G\}}]
=\sum_{r=1}^m p^{|S_r|}.
$$

Multiplication by the fixed scalar $z$ commutes with the finite expectation. $\square$

The formula reinforces the central interpretation: a global complex amplitude rotates and dilates an ordinary real statistic.

## 8. Numerical algorithms and diagnostics

### 8.1 Sampling the undirected model

To sample $A_z$, generate independent Bernoulli variables only for pairs $i<j$, reflect them across the diagonal, and set the diagonal to zero. Forming the dense matrix costs $O(n^2)$ time and memory. A full eigendecomposition of the real symmetric matrix $B$ costs $O(n^3)$ time and $O(n^2)$ memory. It is preferable to compute the real eigenvalues of $B$ with a symmetric eigensolver and multiply them by $z$, rather than applying a general complex eigensolver to $A_z$.

**Algorithm: phase-locked spectrum.**

1. Initialize an $n\times n$ zero matrix $B$.
2. For each $i<j$, draw $X_{ij}\sim\operatorname{Bernoulli}(p)$.
3. Set $B_{ij}=B_{ji}=X_{ij}$.
4. Compute the real eigenvalues $\mu_1,\dots,\mu_n$ of $B$.
5. Return $\lambda_k=z\mu_k$.

The output automatically satisfies line confinement up to floating-point error.

### 8.2 Phase residual

For $z\ne0$, define the normalized phase residual of a computed eigenvalue $\lambda$ by

$$
r(\lambda;z)=\frac{|\operatorname{Im}(\lambda\overline z)|}{|z|\max(1,|\lambda|)}.
$$

The exact theory predicts $r=0$. The denominator makes the statistic scale-resistant and avoids division by a small eigenvalue. The maximum residual over the spectrum should be near floating-point precision when eigenvalues are generated by transport.

### 8.3 Disk diagnostics

Define

$$
q_{\sqrt n}=\frac{\max_k|\lambda_k|}{|z|\sqrt n}
$$

for $z\ne0$. Values above $1$ disprove containment for that realization; values below $1$ establish only containment, not a circular distribution. Angular variance or phase residual is the relevant diagnostic for circularity.

### 8.4 Complete-graph witness

For $K_n$, no random sampling is required. Its spectrum is

$$
\sigma(B)=\{n-1,-1,\dots,-1\},
$$

and therefore

$$
\sigma(A_z)=\{(n-1)z,-z,\dots,-z\}.
$$

This exact benchmark is useful for validating software and illustrating the mean-direction outlier.

## 9. Comparison with circular and Hermitian ensembles

The circular law concerns non-Hermitian matrices with sufficiently independent, centered entries after variance normalization. The fixed-phase undirected model violates the relevant geometry in two ways.

First, $B_{ij}=B_{ji}$, so opposite off-diagonal entries are perfectly correlated. Second, all nonzero entries share one phase. Multiplication by $z$ does not change eigenvectors or produce nonnormality. Even after centering, the matrix remains a scalar multiple of a real symmetric matrix.

A directed replacement behaves differently. Let $X_{ij}$ for $i\ne j$ be independent Bernoulli variables, without imposing $X_{ij}=X_{ji}$. Define

$$
C_{ij}=z(X_{ij}-p),\qquad C_{ii}=0.
$$

After normalization by $|z|\sqrt{np(1-p)}$, this is a plausible circular-law model. Direction removes transpose locking, centering removes the rank-one mean component, and normalization sets the fluctuation scale.

An independently phased undirected model leads elsewhere. If the edge $\{i,j\}$ receives a random phase $e^{i\theta_{ij}}$ and the reverse entry is its complex conjugate, then $H_{ji}=\overline{H_{ij}}$ and $H$ is Hermitian. Its eigenvalues are real regardless of the richness of the phases. A semicircular limit, rather than a circular one, is then the natural expectation. This contrast shows that complex entries alone do not determine spectral dimension; adjoint symmetry does.

## 10. Applications

### 10.1 Wave and oscillator networks

In a network of identical phase shifters, multiplying every coupling by $e^{i\theta}$ rotates all modal eigenvalues by the same angle. Relative modal geometry is unchanged. Genuine interference diversity requires edge-dependent phases, delays, or asymmetric propagation.

### 10.2 Complex-valued neural and signal systems

A common complex gain applied to a real symmetric connectivity matrix does not create independent phase channels. The eigenspaces remain those of the real network. Designers seeking phase-selective computation must introduce heterogeneous phases or directed couplings.

### 10.3 Spectral graph diagnostics

A complex spectral plot can be visually deceptive. A rotated real spectrum is complex-valued but not two-dimensional. The phase residual provides a direct test for this hidden one-dimensionality, while the maximum-degree bound supplies a deterministic radial certificate.

### 10.4 Model validation

The factorization $A_z=zB$ is an example of a structural invariant that should be checked before invoking asymptotic universality. Such checks can expose incompatible independence assumptions, identify outliers caused by nonzero means, and suggest the minimal repair to a conjecture.

## 11. Discussion

The proposed “complex probability” model becomes mathematically coherent only after separating the real Bernoulli parameter from the complex edge amplitude. Under that interpretation, the circular-law conjecture fails decisively. The failure is not caused by insufficient graph size or an incorrect choice of normalization. It follows from exact line confinement.

The four-vertex example addresses a second, independent defect in the naive disk heuristic: uncentered matrices may have linear-scale outliers. Even a model with directed edges would generally require centering before comparison with a unit-disk law. Thus two repairs are necessary:

1. remove transpose symmetry, for example by using directed independent edges;
2. subtract the mean, removing the deterministic rank-one direction.

The row-sum theorem also clarifies the status of radial estimates. Gershgorin-type or maximum-coordinate bounds establish containment but carry no implication about density inside the containing region. A distribution concentrated on a diameter and a distribution uniform over a disk can obey the same radial bound while being geometrically incomparable.

Finally, the expectation formula shows that phase locking is not restricted to eigenvalues. Any real random count multiplied by one fixed amplitude has an expectation on the same phase line. Common phase is a global transformation; local phase disorder is a new source of structure.

## 12. Future work

Several corrected models now emerge naturally.

**Directed fixed-amplitude circular law.** For independent ordered edges, subtract the mean and normalize by $|z|\sqrt{np(1-p)}$. For fixed $0<p<1$ and $z\ne0$, one expects convergence of the empirical spectrum to the uniform measure on the unit disk.

**Sparse directed threshold.** If $p=p_n\to0$, circular behavior should require $np_n$ to exceed a logarithmic sparsity scale. Below that scale, isolated rows should create a persistent atom at zero and obstruct invertibility.

**Magnetic undirected graphs.** Independent unit phases with conjugate weights across the diagonal preserve Hermitian symmetry. After centering and variance normalization, a semicircle law is the natural candidate, subject to moment assumptions on the phase distribution.

**Rank-one outlier transition.** In uncentered dense directed models, one expects an eigenvalue near $zpn$, separated from a fluctuation bulk of scale $|z|\sqrt{np(1-p)}$. Centering should remove this outlier.

**Pseudospectral comparison.** Directed matrices may be strongly nonnormal, whereas the fixed-phase undirected model is normal. Quantitative comparison of resolvent norms would measure not only where eigenvalues lie but also how sensitively they respond to perturbations.

## 13. Conclusion

The analysis also supplies a general workflow for evaluating spectral analogies. One should first isolate deterministic factorization, then identify adjoint symmetry, then separate the matrix mean from its fluctuations, and only afterward choose a normalization or limiting ensemble. Reversing that order can make a visually attractive simulation appear to support an impossible limit. Here the phase-line identity is stronger than any finite sample: it determines the support of every empirical spectral measure at once. Likewise, the four-vertex witness distinguishes a false universal radius from a scale that may still describe a centered bulk in a repaired model. These examples emphasize that asymptotic predictions must respect finite structural invariants.

A fixed complex edge amplitude does not turn an undirected Erdős–Rényi graph into a Ginibre-type matrix. For every realization,

$$
A_z=zB,
$$

with $B$ real symmetric. The consequences are exact: $A_z$ is normal, its adjoint conjugates only the global amplitude, its eigenvectors agree with those of $B$, and its spectrum lies on $z\mathbb R$. A row-sum bound scales by $|z|$, expected weighted subgraph counts scale by $z$, and the complete graph on four vertices already disproves a universal $|z|\sqrt n$ radius for uncentered realizations.

The corrected mathematical message is therefore not that complex-weighted undirected random graphs exhibit circular spectra, but that global phase is spectrally rigid. Two-dimensional spectral behavior requires a model with genuinely non-Hermitian independence, together with centering to remove the mean outlier. The obstruction identifies the path to the right conjecture.
