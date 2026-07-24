# Fourier Diagonalization and Exact Spectra of Cyclic Cayley Graphs

**Aristotle**  
**July 24, 2026**

## Abstract

Let $G=\mathbb Z/n\mathbb Z$ and let $S\subseteq G$ be a connection set. We study the translation-invariant adjacency operator

$$
(A_Sf)(x)=\sum_{s\in S}f(x+s)
$$

on complex-valued functions on $G$. We prove directly that every additive character $\chi_\zeta(x)=\zeta^x$, where $\zeta^n=1$, is a nonzero eigenvector, with eigenvalue equal to the character sum

$$
\lambda_S(\zeta)=\sum_{s\in S}\zeta^s.
$$

Thus the discrete Fourier basis simultaneously diagonalizes every cyclic Cayley adjacency operator. We derive three consequences: the trivial character has eigenvalue $|S|$; every eigenvalue has modulus at most $|S|$; and a symmetric connection set $S=-S$ has real character eigenvalues. For the cycle $S=\{1,-1\}$ with $n\geq3$, we obtain the exact spectrum

$$
\lambda_k=2\cos\left(\frac{2\pi k}{n}\right),\qquad k=0,\ldots,n-1.
$$

We present computational algorithms based on direct character sums and the fast Fourier transform, explain the consequences for normalized classical transition operators and spectral gaps, and clarify the boundary between this Hermitian adjacency theory and genuinely unitary quantum-walk dynamics. The results provide a self-contained spectral bridge among finite harmonic analysis, circulant matrices, graph theory, and periodic transport.

## 1. Introduction

Cayley graphs convert algebraic motion into geometry. Given a group and a collection of permitted increments, vertices represent group elements and edges represent multiplication or addition by those increments. On the cyclic group $\mathbb Z/n\mathbb Z$, this construction produces every graph whose adjacency rule is translation invariant around a finite circle. Such graphs include the ordinary cycle, but also long-range periodic networks with several allowed displacements.

Translation invariance is a strong symmetry. The local environment around every vertex is identical, so an adjacency operator built from the graph commutes with every cyclic shift. The natural spectral coordinates are therefore the irreducible characters of the cyclic group, equivalently the modes of the discrete Fourier transform. This statement is often expressed by saying that circulant matrices are diagonalized by the Fourier matrix. Here we develop the result directly from the group law, retaining enough structure to expose the eigenvalue as a character sum over the connection set.

The character-sum viewpoint is useful for three reasons. First, it simultaneously handles all cyclic connection sets rather than one matrix at a time. Second, it makes qualitative spectral properties nearly immediate: degree gives the top modulus bound, while inverse symmetry forces reality. Third, it specializes to a transparent trigonometric spectrum for the cycle, linking roots of unity to the cosine dispersion relation of a periodic one-dimensional lattice.

The motivating language of random walks requires care. Dividing the adjacency operator by the degree gives a classical stochastic transition operator when moves are selected uniformly. Its nonconstant eigenvalues govern decay toward equilibrium under standard irreducibility and aperiodicity assumptions. A genuine discrete-time quantum walk, however, is unitary and generally requires additional structure. Adjacency spectral data remain important, particularly in Hamiltonian, coined, and Szegedy-type constructions, but adjacency diagonalization alone does not prove a universal quantum mixing law. This distinction will be maintained throughout.

The principal contributions are as follows.

1. We give a direct proof that all cyclic characters are nonzero eigenvectors of every cyclic Cayley adjacency operator.
2. We identify the eigenvalue as the finite Fourier transform of the connection set.
3. We prove the degree eigenvalue and a uniform degree bound on spectral modulus.
4. We prove reality of the character spectrum for inverse-closed connection sets.
5. We derive the exact cosine spectrum of the cycle.
6. We state practical algorithms for computing and numerically checking the spectrum, including an $O(n\log n)$ Fourier method.

## 2. Cyclic groups, signals, and Cayley operators

### 2.1 The cyclic group

Fix an integer $n\geq1$. Let

$$
G_n=\mathbb Z/n\mathbb Z
$$

with addition modulo $n$. We represent its elements by residues $0,1,\ldots,n-1$, while all equations involving group elements are interpreted modulo $n$.

A **connection set** is a subset $S\subseteq G_n$. The directed Cayley graph determined by $S$ has an arc from $x$ to $x+s$ for each $x\in G_n$ and $s\in S$. If $S=-S$, where

$$
-S=\{-s:s\in S\},
$$

then every arc occurs with its reverse and the graph is undirected, apart from the possibility of loops when $0\in S$.

The degree counted by the connection rule is $d=|S|$. Distinct residues in $S$ give distinct outgoing neighbors from every vertex.

### 2.2 Function space and adjacency

Let

$$
\mathcal H_n=\{f:G_n\to\mathbb C\}.
$$

This is an $n$-dimensional complex vector space. Equip it, when needed, with the inner product

$$
\langle f,g\rangle=\sum_{x\in G_n}\overline{f(x)}g(x).
$$

The **Cayley adjacency operator** associated with $S$ is the linear map $A_S:\mathcal H_n\to\mathcal H_n$ defined by

$$
(A_Sf)(x)=\sum_{s\in S}f(x+s).
$$

Our convention uses forward translations. Replacing $x+s$ by $x-s$ conjugates or reindexes the resulting Fourier formula but does not alter the multiset of eigenvalues for symmetric sets.

If $S$ is nonempty, the corresponding uniformly weighted classical transition operator is

$$
P_S=\frac{1}{|S|}A_S.
$$

The operator $P_S$ is row-stochastic under the coordinate convention induced by the formula above. It preserves constant functions and averages values over translated neighbors.

### 2.3 Roots of unity and characters

A complex number $\zeta$ is an **$n$th root of unity** if $\zeta^n=1$. Every such $\zeta$ lies on the unit circle. For each root define

$$
\chi_\zeta(x)=\zeta^r,
$$

where $r$ is any integer representative of $x\in G_n$. This is well defined: replacing $r$ by $r+qn$ multiplies the value by $(\zeta^n)^q=1$.

The defining character identity is

$$
\chi_\zeta(x+s)=\chi_\zeta(x)\chi_\zeta(s).
$$

Indeed, choose integer representatives and use the law of exponents; any wraparound changes the exponent by a multiple of $n$ and hence does not change the value.

The standard roots are

$$
\zeta_k=\exp\left(\frac{2\pi i k}{n}\right),\qquad k=0,1,\ldots,n-1.
$$

The corresponding characters $\chi_k(x)=e^{2\pi i kx/n}$ form the discrete Fourier basis. Orthogonality follows from the geometric-series identity:

$$
\sum_{x=0}^{n-1}e^{2\pi i(k-\ell)x/n}
=\begin{cases}
n,&k=\ell,\\
0,&k\neq\ell.
\end{cases}
$$

Thus the normalized functions $n^{-1/2}\chi_k$ form an orthonormal basis of $\mathcal H_n$.

## 3. The Fourier diagonalization theorem

We begin with the algebraic fact on which all later conclusions rest.

**Lemma 3.1 (modular exponent compatibility).** Let $\zeta^n=1$. If integers $a$ and $b$ are congruent modulo $n$, then $\zeta^a=\zeta^b$. Consequently, for all $x,s\in G_n$,

$$
\chi_\zeta(x+s)=\chi_\zeta(x)\chi_\zeta(s).
$$

**Proof sketch.** Congruence gives $a=b+qn$ for some integer $q$. Since $\zeta^n=1$, the factor $\zeta^{qn}$ is $1$. Applying this after choosing representatives for $x$ and $s$ gives the character law. Negative exponents may be handled using $\zeta^{-1}=\overline\zeta$, valid because $|\zeta|=1$. $\square$

Define the **connection-set character sum** by

$$
\lambda_S(\zeta)=\sum_{s\in S}\chi_\zeta(s)=\sum_{s\in S}\zeta^s.
$$

The second notation uses representatives but is independent of their choice by Lemma 3.1.

**Theorem 3.2 (Fourier diagonalization of cyclic Cayley operators).** Let $n\geq1$, let $S\subseteq G_n$, and let $\zeta^n=1$. The character $\chi_\zeta$ is a nonzero eigenvector of $A_S$, with eigenvalue $\lambda_S(\zeta)$. Explicitly,

$$
A_S\chi_\zeta=\lambda_S(\zeta)\chi_\zeta.
$$

In particular, the standard characters $\chi_0,\ldots,\chi_{n-1}$ form an eigenbasis, so the discrete Fourier basis diagonalizes $A_S$.

**Proof sketch.** For every $x\in G_n$, apply the character law term by term:

$$
\begin{aligned}
(A_S\chi_\zeta)(x)
&=\sum_{s\in S}\chi_\zeta(x+s)\\
&=\sum_{s\in S}\chi_\zeta(x)\chi_\zeta(s)\\
&=\chi_\zeta(x)\sum_{s\in S}\chi_\zeta(s)\\
&=\lambda_S(\zeta)\chi_\zeta(x).
\end{aligned}
$$

The character is nonzero because $\chi_\zeta(0)=1$. The standard characters form a basis by Fourier orthogonality, completing the diagonalization statement. $\square$

**Corollary 3.3 (simultaneous diagonalization).** For fixed $n$, every operator $A_S$ arising from a connection set $S\subseteq G_n$ is diagonal in the same Fourier basis.

**Proof sketch.** Theorem 3.2 identifies each $\chi_k$ as an eigenvector for every $S$. Only the corresponding character sum changes with $S$. $\square$

This simultaneous statement is stronger than diagonalizing one circulant matrix. It says that the full commutative algebra of cyclic convolution operators shares one canonical spectral coordinate system.

## 4. Degree, spectral modulus, and symmetry

### 4.1 The constant mode

The root $\zeta_0=1$ produces the constant character $\chi_0(x)=1$.

**Theorem 4.1 (degree eigenvalue).** For every connection set $S\subseteq G_n$,

$$
\lambda_S(1)=|S|.
$$

Hence the constant function is an eigenvector of $A_S$ with eigenvalue equal to the degree.

**Proof sketch.** Every term in the character sum is $1^s=1$, so the sum has exactly $|S|$ unit terms. Equivalently, applying $A_S$ to a constant function adds $|S|$ identical values. $\square$

For the normalized transition operator $P_S$, this eigenvalue becomes $1$, expressing conservation of total probability and stationarity of the uniform distribution.

### 4.2 A universal modulus bound

**Theorem 4.2 (spectral degree bound).** If $\zeta^n=1$, then

$$
|\lambda_S(\zeta)|\leq |S|.
$$

**Proof sketch.** Roots of unity have modulus $1$, and therefore each summand has modulus $|\zeta^s|=1$. The complex triangle inequality yields

$$
\left|\sum_{s\in S}\zeta^s\right|
\leq\sum_{s\in S}|\zeta^s|
=\sum_{s\in S}1
=|S|.
$$

$\square$

**Corollary 4.3.** If $S\neq\varnothing$, every eigenvalue $\mu$ of $P_S$ satisfies $|\mu|\leq1$.

**Proof sketch.** Divide each adjacency eigenvalue by $|S|$ and invoke Theorem 4.2. Since the Fourier characters form a basis, these are all eigenvalues. $\square$

Equality in the triangle inequality has a geometric meaning: all complex numbers $\zeta^s$ for $s\in S$ point in the same direction. At the trivial character they all equal $1$. At a nontrivial character, equality can signal periodicity or failure of the connection set to generate the entire group.

### 4.3 Inverse symmetry and reality

A set $S$ is **symmetric** or **inverse closed** if $S=-S$. In an additive cyclic group, this means $s\in S$ if and only if $-s\in S$.

**Lemma 4.4 (conjugation of character values).** If $\zeta^n=1$, then

$$
\overline{\zeta^s}=\zeta^{-s}
$$

for every $s\in G_n$.

**Proof sketch.** Since $|\zeta|=1$, one has $\overline\zeta=\zeta^{-1}$. Conjugation commutes with integer powers. $\square$

**Theorem 4.5 (real spectrum for symmetric connection sets).** Let $S=-S$. Then for every $n$th root of unity $\zeta$,

$$
\overline{\lambda_S(\zeta)}=\lambda_S(\zeta),
$$

so $\lambda_S(\zeta)$ is real.

**Proof sketch.** Conjugate the character sum and apply Lemma 4.4:

$$
\overline{\lambda_S(\zeta)}
=\sum_{s\in S}\zeta^{-s}.
$$

The involution $s\mapsto -s$ is a bijection from $S$ to itself, so reindexing the sum gives

$$
\sum_{s\in S}\zeta^{-s}=\sum_{t\in S}\zeta^t=\lambda_S(\zeta).
$$

A complex number fixed by conjugation is real. $\square$

This theorem agrees with the operator viewpoint. If $S=-S$, translation by $s$ is adjoint to translation by $-s$, and the sum $A_S$ is self-adjoint. The character proof additionally exhibits the cancellation mechanism explicitly.

## 5. Exact spectrum of the cycle

Assume $n\geq3$ and choose

$$
S_{\mathrm{cyc}}=\{1,-1\}.
$$

The condition $n\geq3$ ensures that $1$ and $-1$ are distinct residues. The resulting Cayley graph is the undirected cycle $C_n$.

**Theorem 5.1 (root-of-unity form of the cycle eigenvalue).** If $\zeta^n=1$, then the eigenvalue of the cycle adjacency operator associated with $\chi_\zeta$ is

$$
\lambda_{\mathrm{cyc}}(\zeta)=\zeta+\zeta^{-1}.
$$

**Proof sketch.** The general character-sum formula contains exactly the two terms corresponding to $1$ and $-1$:

$$
\lambda_{\mathrm{cyc}}(\zeta)=\zeta^1+\zeta^{-1}.
$$

$\square$

**Lemma 5.2 (Euler pairing).** For every real $\theta$,

$$
e^{i\theta}+e^{-i\theta}=2\cos\theta.
$$

**Proof sketch.** Euler’s formula gives $e^{i\theta}=\cos\theta+i\sin\theta$ and $e^{-i\theta}=\cos\theta-i\sin\theta$. Adding cancels the imaginary parts. $\square$

**Theorem 5.3 (exact cycle spectrum).** Let $n\geq3$. For each integer $k$, the Fourier mode

$$
\chi_k(x)=\exp\left(\frac{2\pi i kx}{n}\right)
$$

is an eigenvector of the cycle adjacency operator with eigenvalue

$$
\lambda_k=2\cos\left(\frac{2\pi k}{n}\right).
$$

As $k$ ranges from $0$ to $n-1$, these values, counted with multiplicity, form the complete adjacency spectrum of $C_n$.

**Proof sketch.** The number $\zeta_k=e^{2\pi ik/n}$ is an $n$th root of unity because $\zeta_k^n=e^{2\pi ik}=1$. Theorem 5.1 gives $\lambda_k=\zeta_k+\zeta_k^{-1}$, and Lemma 5.2 turns this into the cosine expression. Completeness follows because the $n$ Fourier modes form a basis. $\square$

**Corollary 5.4 (transition spectrum of the simple cycle walk).** The uniformly chosen nearest-neighbor walk on $C_n$ has transition eigenvalues

$$
\mu_k=\cos\left(\frac{2\pi k}{n}\right),\qquad k=0,\ldots,n-1.
$$

**Proof sketch.** The cycle has degree $2$, so its transition operator is $P=A/2$. Eigenvectors remain unchanged and eigenvalues are divided by $2$. $\square$

The multiplicity pattern follows from $\cos(2\pi k/n)=\cos(2\pi(n-k)/n)$. Except at the self-paired frequencies $k=0$ and, for even $n$, $k=n/2$, modes occur in conjugate pairs with the same real eigenvalue.

## 6. Algorithms

### 6.1 Direct character-sum spectrum

The defining formula gives an immediate algorithm.

**Algorithm 1: Direct cyclic Cayley spectrum.** Given $n$ and $S$, for each $k=0,\ldots,n-1$ compute

$$
\lambda_k=\sum_{s\in S}e^{2\pi i ks/n}.
$$

The algorithm uses $n|S|$ complex exponential evaluations and additions, hence $O(n|S|)$ arithmetic operations. It uses $O(n)$ output storage and $O(1)$ additional working storage if values are streamed. For symmetric $S$, small imaginary residuals caused by floating-point error may be discarded after checking that they lie below a tolerance.

### 6.2 Fast Fourier spectrum

Define the indicator vector $a\in\mathbb C^n$ by

$$
a_s=\begin{cases}
1,&s\in S,\\
0,&s\notin S.
\end{cases}
$$

Then $\lambda_k$ is a discrete Fourier transform of $a$, with the sign determined by convention. Therefore all eigenvalues can be computed using a fast Fourier transform in $O(n\log n)$ arithmetic operations and $O(n)$ memory. This is advantageous when $S$ is dense. For sparse $S$, the direct $O(n|S|)$ method can be competitive or superior.

### 6.3 Numerical diagonalization check

A third algorithm constructs the $n\times n$ adjacency matrix

$$
A_{x,y}=\begin{cases}
1,&y-x\in S,\\
0,&\text{otherwise},
\end{cases}
$$

and compares a numerical eigensolver’s output with the character sums. Dense construction costs $O(n^2)$ memory, while generic dense eigenvalue computation costs $O(n^3)$ time. This method is not efficient for large graphs, but it is useful as an independent numerical check and as a demonstration that the Fourier formula replaces generic linear algebra with group structure.

## 7. Applications to spectral gaps and transport

For a nonempty connection set, normalized eigenvalues are

$$
\mu_k=\frac{1}{|S|}\sum_{s\in S}e^{2\pi i ks/n}.
$$

When $S=-S$, these numbers are real. If the walk is irreducible and made aperiodic when necessary, the largest eigenvalue is $1$, and the magnitudes of the remaining eigenvalues control convergence of classical distributions to uniformity. A commonly used absolute spectral gap is

$$
\gamma_{\mathrm{abs}}=1-\max_{k\neq0}|\mu_k|,
$$

although for periodic chains this quantity may vanish because an eigenvalue equals $-1$. A lazy modification, replacing $P$ by $(I+P)/2$, removes that obstruction while retaining the Fourier eigenvectors.

For the simple cycle,

$$
\mu_1=\cos\left(\frac{2\pi}{n}\right).
$$

Using $1-\cos\theta=2\sin^2(\theta/2)$ and standard small-angle estimates shows that

$$
1-\mu_1=1-\cos\left(\frac{2\pi}{n}\right)=\Theta(n^{-2}).
$$

This quantitative asymptotic is not needed for the exact diagonalization theorem, but it illustrates how the theorem feeds directly into mixing analysis. The long-wavelength Fourier mode is weakly damped, reflecting slow diffusion around a one-dimensional ring.

The same character sum supports network design. For a chosen nonzero frequency $k$, the unit vectors $e^{2\pi iks/n}$ associated with allowed jumps may align or cancel. Selecting $S$ to enforce cancellation across all nonconstant frequencies enlarges spectral separation and accelerates classical averaging. Conversely, a highly aligned set preserves certain modes and can create bottlenecks or periodic behavior.

## 8. Relation to quantum walks

The finite-dimensional space $\mathcal H_n$ is also a natural state space for quantum dynamics, but the adjacency operator $A_S$ is generally not unitary. Even its normalized form $P_S$ is stochastic rather than unitary. A continuous-time quantum walk may use the unitary family

$$
U(t)=e^{-itA_S},
$$

while a discrete-time coined walk enlarges the state space and combines a coin operator with a conditional shift. Szegedy-type constructions build a unitary from a classical Markov chain in another way.

The diagonalization proved above is immediately useful for continuous-time evolution: since $A_S\chi_k=\lambda_k\chi_k$,

$$
U(t)\chi_k=e^{-it\lambda_k}\chi_k.
$$

Thus the adjacency eigenvalues become phase velocities. For coined or Szegedy walks, related Fourier decomposition reduces translation-invariant dynamics to small frequency-indexed blocks, but additional analysis is required.

Classical stochastic mixing and unitary quantum evolution also differ conceptually. Powers of a stochastic operator can contract nonconstant modes. Powers of a unitary preserve norm, so convergence of the full state vector cannot occur in the same manner. One must specify whether “mixing” means convergence of measured distributions, time-averaged convergence, hitting behavior, or another criterion.

Accordingly, the cyclic adjacency spectrum does not imply a universal quantum bound of the form $O(\sqrt{|G|}\log|G|)$, nor does it establish a graph-independent quadratic speedup. Such claims are model dependent and fail for broad universal formulations. The rigorous conclusion here is narrower and more reusable: the complete cyclic Cayley adjacency spectrum is explicitly determined by character sums, providing the spectral input for subsequent model-specific analyses.

## 9. Examples

### 9.1 The six-cycle

For $n=6$ and $S=\{1,5\}=\{1,-1\}$, the spectrum is

$$
2\cos\left(\frac{2\pi k}{6}\right),
$$

which yields, in frequency order,

$$
2,\ 1,\ -1,\ -2,\ -1,\ 1.
$$

The maximum modulus equals the degree $2$. Every value is real because the connection set is symmetric.

### 9.2 A longer-range symmetric graph

Take $n=12$ and $S=\{1,2,10,11\}=\{\pm1,\pm2\}$. Pairing inverse terms gives

$$
\lambda_k
=2\cos\left(\frac{2\pi k}{12}\right)
+2\cos\left(\frac{4\pi k}{12}\right).
$$

This example shows how each symmetric jump length contributes one cosine band. The degree eigenvalue is $4$, and the degree bound gives $|\lambda_k|\leq4$.

### 9.3 A directed cyclic rule

Take $n=7$ and $S=\{1,2\}$. Then

$$
\lambda_k=e^{2\pi ik/7}+e^{4\pi ik/7}.
$$

Because $S$ is not inverse closed, these eigenvalues need not be real. Nevertheless, the same Fourier basis diagonalizes the operator and the modulus bound $|\lambda_k|\leq2$ still holds. Thus symmetry controls reality, not diagonalizability.

## 10. Discussion and future work

The cyclic theory illustrates the general harmonic principle that convolution becomes multiplication after Fourier transformation. Several extensions are natural.

First, for a finite abelian group decomposed as a product of cyclic groups, scalar characters again form a complete orthogonal basis. The same one-line computation gives eigenvalue $\sum_{s\in S}\chi(s)$ at character $\chi$. This would extend every structural theorem here, with inverse closure again implying reality.

Second, nonabelian groups replace scalar characters by matrix-valued irreducible representations. The adjacency operator becomes block diagonal, with a block

$$
\sum_{s\in S}\rho(s)
$$

for each irreducible representation $\rho$. Random transpositions on symmetric groups are a prominent target, but their analysis requires substantial representation theory.

Third, the cycle gap can be developed quantitatively from elementary sine bounds to obtain explicit constants, not only $\Theta(n^{-2})$ scaling. From there one can derive standard classical mixing-time estimates for lazy cycle walks.

Fourth, unitary quantum models should be treated explicitly. For continuous-time walks the present diagonalization already gives exact phases. For coined and Szegedy walks, one should define the additional state space, diagonalize each Fourier block, and state the chosen notion of mixing. This would allow speedups to be proved where they occur without asserting universality where they do not.

Finally, character sums can be used inversely: two different connection sets may have the same multiset of sums and hence define isospectral Cayley graphs. Constructing and classifying such examples would connect the present bridge to spectral graph invariants.

## 11. Conclusion

The spectrum of a cyclic Cayley graph is encoded directly by its group structure. Every root of unity defines a Fourier character, every such character is a nonzero eigenvector, and the corresponding eigenvalue is the sum of the character over the allowed displacements. From this formula, the degree eigenvalue, the uniform degree bound, and reality under inverse symmetry follow by elementary arguments. For the cycle, two inverse jumps collapse the character sum to the exact cosine law

$$
\lambda_k=2\cos\left(\frac{2\pi k}{n}\right).
$$

The result is simultaneously algebraic, analytic, and graph theoretic. It replaces generic matrix diagonalization with a canonical Fourier basis, supports efficient computation, and supplies exact spectral data for periodic transport. Just as importantly, it marks the proper boundary of its implications: adjacency spectra are foundational inputs to random-walk analysis, while specific classical or quantum mixing claims require the dynamics and the notion of mixing to be stated separately.
