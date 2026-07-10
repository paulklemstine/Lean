# Spectral Theory of Random Walks on Cayley Graphs of Finite Abelian Groups

## Abstract

We develop, from first principles, the spectral theory underlying classical and
quantum random walks on Cayley graphs of finite abelian groups. The organizing
principle is that the *characters* of a finite abelian group $G$ simultaneously
diagonalize every translation-invariant operator on $\ell^2(G)$ — in particular
the adjacency (walk) operator of any Cayley graph $\mathrm{Cay}(G,S)$. From this
single fact we obtain: unitarity of the elementary shift operator; exact
periodicity of the single-generator walk, with period equal to the additive order
of the generator; a complete family of eigenvectors (the characters) with explicit
eigenvalues $\lambda_\psi = \sum_{s\in S}\psi(s)$; the Perron–Frobenius bound
$|\lambda_\psi|\le|S|$; self-adjointness of the walk operator for symmetric
generating sets; and, for the cycle $\mathrm{Cay}(\mathbb{Z}/n\mathbb{Z},\{\pm1\})$,
the exact second eigenvalue $2\cos(2\pi/n)$ together with the strict positivity of
the spectral gap. We explain how the spectral gap controls mixing time, work the
cycle and hypercube as fully explicit examples, and outline the extension to
non-abelian groups via representation theory, where the random-transposition walk
on $S_n$ is the natural next target.

**Keywords:** Cayley graph, random walk, spectral gap, mixing time, additive
character, Fourier analysis on finite groups, quantum walk, Perron–Frobenius,
self-adjoint operator.

## 1. Introduction

Random walks on graphs are a unifying object across mathematics, physics, and
computer science. On a finite, connected, non-bipartite graph, a random walk
converges to a stationary distribution, and the rate of convergence — the
*mixing time* — is controlled by the *spectral gap* of the walk operator. The
central analytic task is therefore to compute, or at least bound, the eigenvalues
of that operator.

For a generic graph this is hard. But when the graph carries the symmetry of a
group — when it is a **Cayley graph** — a great deal becomes computable. For a
finite *abelian* group the computation is essentially closed-form: the characters
of the group form a simultaneous eigenbasis for every Cayley operator, reducing
spectral analysis to a finite sum of roots of unity. This paper presents that
theory in a self-contained way and derives the concrete consequences for mixing.

The same framework anchors the study of *quantum* walks. The elementary step of a
Cayley walk — translation by a group element — is a unitary operator, and its
iterates are periodic. This is precisely the length-preserving, reversible
dynamics required of a quantum evolution. The abelian spectral theory developed
here is thus the common base case for both the classical mixing-time program and
its quantum analogue.

### Historical and conceptual context

The idea that symmetry linearizes dynamics is old and deep. For a translation on the
real line the eigenfunctions are the exponentials $e^{i\xi x}$; for a translation on
the circle they are the Fourier modes $e^{in\theta}$; and for a translation on a
finite abelian group they are the characters. In each case the eigenfunctions are the
irreducible representations of the underlying group, and the operator that commutes
with all translations — the *convolution* operator — becomes multiplication by a
function (its Fourier transform) in the frequency domain. The Cayley walk operator
$A_S$ is precisely convolution with the indicator of $S$, so its Fourier transform is
the character sum $\lambda_\psi(S)=\sum_{s\in S}\psi(s)$. Everything in this paper is
a concrete, finite instance of the convolution theorem, specialized to the counting
measure on a generating set.

What makes the abelian case *exactly* solvable, rather than merely tractable, is that
all irreducible representations of an abelian group are one-dimensional. Simultaneous
diagonalization is therefore literal diagonalization: the $|G|\times|G|$ matrix $A_S$
is conjugate, by the character (Fourier) matrix, to a diagonal matrix of character
sums. No numerical eigensolver is needed; the spectrum is a list of trigonometric
sums that can be written down by inspection.

### Contributions

We give complete, elementary derivations of the following:

1. **Unitarity** of the elementary shift operator on $\ell^2(G)$ (Theorem 4.1).
2. **Periodicity** of the single-generator walk: $(\mathrm{shift}_s)^{\mathrm{ord}(s)} = \mathrm{Id}$ (Theorem 4.3).
3. **Spectral diagonalization by characters**: every character is an eigenvector,
   with eigenvalue $\sum_{s\in S}\psi(s)$ (Theorem 5.1).
4. The **top eigenvalue** $|S|$ (Corollary 5.2) and the **Perron bound**
   $|\lambda_\psi|\le|S|$ (Theorem 5.3).
5. **Self-adjointness** for symmetric generating sets (Theorem 5.5).
6. The **exact second eigenvalue** $2\cos(2\pi/n)$ and **positive spectral gap** of
   the cycle (Theorems 6.2 and 6.3).

## 2. Setup and notation

Let $G$ be a finite abelian group, written additively, with identity $0$. We model
the Hilbert space of states as
$$\ell^2(G) = \{\, f : G \to \mathbb{C}\,\},$$
a finite-dimensional complex inner-product space with
$$\langle f, g\rangle = \sum_{x\in G} \overline{f(x)}\,g(x), \qquad
\|f\|^2 = \sum_{x\in G} |f(x)|^2.$$

A **generating (multi)set** is a finite subset $S \subseteq G$. (For walk purposes
$S$ typically generates $G$ and is often symmetric; we state hypotheses explicitly
where needed.) The **Cayley graph** $\mathrm{Cay}(G,S)$ has vertex set $G$ and an
edge from $x$ to $x+s$ for each $s\in S$. It is $|S|$-regular and vertex-transitive.

We call $S$ **symmetric** if $S = -S$, i.e. $-s\in S$ whenever $s\in S$; this makes
$\mathrm{Cay}(G,S)$ an undirected graph.

## 3. The operators

We introduce the two operators that generate the theory.

**Definition 3.1 (Shift).** For $s\in G$, the *shift* operator
$\mathrm{shift}_s : \ell^2(G)\to\ell^2(G)$ is
$$(\mathrm{shift}_s\, f)(x) = f(x+s).$$

**Definition 3.2 (Walk / adjacency operator).** For a finite $S\subseteq G$, the
*Cayley walk operator* $A_S : \ell^2(G)\to\ell^2(G)$ is
$$(A_S\, f)(x) = \sum_{s\in S} f(x+s).$$

Equivalently $A_S = \sum_{s\in S}\mathrm{shift}_s$. The (lazy or normalized)
*random-walk operator* is $P = |S|^{-1}A_S$, a doubly stochastic operator when $S$
is symmetric; its powers $P^t$ describe the distribution of the walk after $t$
steps.

**Definition 3.3 (Squared $\ell^2$ norm).** For finite $G$,
$\;\mathrm{ell2normSq}(f) = \sum_{x\in G}|f(x)|^2 = \|f\|^2.$

**Definition 3.4 (Character eigenvalue).** For a generating set $S$ and an additive
character $\psi : G \to \mathbb{C}^\times$, define
$$\lambda_\psi(S) = \sum_{s\in S}\psi(s).$$

An **additive character** of $G$ is a homomorphism $\psi$ from $(G,+)$ to the
multiplicative group $\mathbb{C}^\times$; because $G$ is finite, $\psi$ takes values
in the roots of unity, so $|\psi(x)| = 1$ for all $x$, and $\psi(x+y)=\psi(x)\psi(y)$,
$\psi(0)=1$.

## 4. Algebra and dynamics of the shift

**Lemma 4.0 (Group law and linearity).** The shift satisfies
$\mathrm{shift}_s\circ\mathrm{shift}_t = \mathrm{shift}_{s+t}$,
$\mathrm{shift}_0 = \mathrm{Id}$, and is $\mathbb{C}$-linear:
$\mathrm{shift}_s(f+g)=\mathrm{shift}_s f+\mathrm{shift}_s g$ and
$\mathrm{shift}_s(cf)=c\,\mathrm{shift}_s f$. In particular $\mathrm{shift}_{-s}$
inverts $\mathrm{shift}_s$, so each shift is a linear bijection of $\ell^2(G)$.

*Proof.* Direct computation: $(\mathrm{shift}_s(\mathrm{shift}_t f))(x) = (\mathrm{shift}_t f)(x+s) = f(x+s+t)$, using associativity and commutativity of $+$. The remaining identities are immediate, and $\mathrm{shift}_{-s}(\mathrm{shift}_s f)(x) = f(x+s-s) = f(x)$. $\square$

**Theorem 4.1 (Unitarity of the shift).** For finite $G$ and any $s\in G$,
$$\|\mathrm{shift}_s\, f\|^2 = \|f\|^2.$$

*Proof.* The map $x\mapsto x+s$ is a bijection of $G$ (with inverse $x\mapsto x-s$).
Reindexing the sum,
$$\sum_{x\in G}|f(x+s)|^2 = \sum_{y\in G}|f(y)|^2. \qquad\square$$

Thus $\mathrm{shift}_s$ is a unitary operator; it is the elementary, reversible,
length-preserving step of a coin-free quantum walk on the Cayley graph.

**Theorem 4.2 (Iteration).** For every $k\in\mathbb{N}$,
$\;(\mathrm{shift}_s)^k = \mathrm{shift}_{k\cdot s}.$

*Proof.* Induction on $k$: the base case is $\mathrm{shift}_0=\mathrm{Id}$, and the
step uses Lemma 4.0 together with $(k+1)\cdot s = k\cdot s + s$. $\square$

**Theorem 4.3 (Periodicity).** Let $m = \mathrm{ord}(s)$ be the additive order of
$s$ (the least $m>0$ with $m\cdot s = 0$). Then
$$(\mathrm{shift}_s)^{m} = \mathrm{Id}.$$

*Proof.* By Theorem 4.2, $(\mathrm{shift}_s)^m = \mathrm{shift}_{m\cdot s} =
\mathrm{shift}_0 = \mathrm{Id}$. $\square$

In the language of quantum walks, the single-generator unitary $U=\mathrm{shift}_s$
satisfies $U^m = I$: the walk is exactly periodic with period dividing the order of
its generator.

**Theorem 4.4 (Translation invariance).** For any finite $S$ and any $t\in G$,
$$A_S\circ\mathrm{shift}_t = \mathrm{shift}_t\circ A_S.$$

*Proof.* Both sides send $f$ to $x\mapsto\sum_{s\in S} f(x+t+s)$, using commutativity
of $+$. $\square$

Theorem 4.4 is the algebraic expression of vertex-transitivity: the walk operator
commutes with the translation symmetries of the Cayley graph. It is precisely this
commutation that forces a *simultaneous* eigenbasis, which we now exhibit.

## 5. Spectral diagonalization by characters

**Theorem 5.1 (Characters are eigenvectors).** For every finite $S\subseteq G$ and
every additive character $\psi$ of $G$,
$$A_S\,\psi = \lambda_\psi(S)\,\psi, \qquad \lambda_\psi(S) = \sum_{s\in S}\psi(s).$$

*Proof.* For each $x$,
$$(A_S\,\psi)(x) = \sum_{s\in S}\psi(x+s) = \sum_{s\in S}\psi(s)\psi(x)
= \Big(\sum_{s\in S}\psi(s)\Big)\psi(x) = \lambda_\psi(S)\,\psi(x),$$
using the homomorphism property $\psi(x+s)=\psi(x)\psi(s)$ and factoring out
$\psi(x)$. $\square$

Because a finite abelian group $G$ has exactly $|G|$ distinct characters, and these
form an orthogonal basis of $\ell^2(G)$ (character orthogonality), Theorem 5.1
provides a *complete* diagonalization: in the character basis, $A_S$ is the diagonal
matrix $\mathrm{diag}(\lambda_\psi(S))_\psi$. Every spectral quantity of the walk is
therefore a function of the numbers $\lambda_\psi(S)$.

**Corollary 5.2 (Top eigenvalue).** For the trivial character $\psi\equiv 1$,
$$\lambda_{1}(S) = \sum_{s\in S} 1 = |S|.$$
The constant function is the eigenvector, corresponding to the uniform distribution.

**Theorem 5.3 (Perron–Frobenius bound).** For every character $\psi$,
$$|\lambda_\psi(S)|\le |S|.$$

*Proof.* By the triangle inequality and $|\psi(s)|=1$,
$$\Big|\sum_{s\in S}\psi(s)\Big| \le \sum_{s\in S}|\psi(s)| = \sum_{s\in S} 1 = |S|.
\qquad\square$$

Thus $|S|$ is the spectral radius, attained by the flat mode. This is the discrete
Perron–Frobenius phenomenon: the uniform mode is the dominant eigenvector.

**Lemma 5.4 (Conjugate of a character).** For a character $\psi$ of a finite group
and any $a\in G$, $\;\overline{\psi(a)} = \psi(-a).$

*Proof.* Since $|\psi(a)|=1$ we have $\overline{\psi(a)} = \psi(a)^{-1}$, and
$\psi(a)^{-1} = \psi(-a)$ because $\psi$ is a homomorphism. $\square$

**Theorem 5.5 (Self-adjointness for symmetric $S$).** If $S=-S$, then
$\lambda_\psi(S)\in\mathbb{R}$ for every character $\psi$; equivalently $A_S$ is
self-adjoint.

*Proof.* Using Lemma 5.4 and reindexing $s\mapsto -s$ over the symmetric set $S$,
$$\overline{\lambda_\psi(S)} = \sum_{s\in S}\overline{\psi(s)}
= \sum_{s\in S}\psi(-s) = \sum_{s\in S}\psi(s) = \lambda_\psi(S).$$
A complex number equal to its own conjugate is real; a diagonal operator with real
entries in an orthonormal basis is self-adjoint. $\square$

Self-adjointness is exactly the reversibility condition that makes $P=|S|^{-1}A_S$ a
genuine reversible Markov chain and guarantees a real spectrum contained in
$[-|S|,|S|]$.

## 6. Worked example: the cycle

Let $n\ge 3$, $G=\mathbb{Z}/n\mathbb{Z}$, and take the symmetric generating set
$$S = \{+1, -1\}.$$
The Cayley graph is the $n$-cycle $C_n$.

**Lemma 6.1 (Symmetry of $S$).** $S = -S$; hence $A_S$ is self-adjoint by
Theorem 5.5.

*Proof.* $-\{1,-1\} = \{-1, 1\} = \{1,-1\}$. $\square$

The characters of $\mathbb{Z}/n\mathbb{Z}$ are $\psi_j(x)=e^{2\pi i jx/n}$ for
$j=0,\dots,n-1$. The standard character is $\psi_1(x) = e^{2\pi i x/n}$.

**Theorem 6.2 (Second eigenvalue of the cycle).** For $n\ge 3$,
$$\lambda_{\psi_1}(S) = e^{2\pi i/n} + e^{-2\pi i/n} = 2\cos\!\Big(\tfrac{2\pi}{n}\Big).$$

*Proof.* By definition $\lambda_{\psi_1}(S) = \psi_1(1) + \psi_1(-1)
= e^{2\pi i/n} + e^{-2\pi i/n}$. The identity $e^{i\theta}+e^{-i\theta}=2\cos\theta$
with $\theta = 2\pi/n$ gives the result; that $1\ne -1$ in $\mathbb{Z}/n\mathbb{Z}$
for $n\ge 3$ ensures $S$ genuinely has two elements. $\square$

More generally $\lambda_{\psi_j}(S) = 2\cos(2\pi j/n)$. The top eigenvalue is
$\lambda_{\psi_0} = 2$ (degree), and the second-largest is $2\cos(2\pi/n)$.

**Theorem 6.3 (Positive spectral gap).** For $n\ge 3$,
$$\mathrm{gap} = 2 - 2\cos\!\Big(\tfrac{2\pi}{n}\Big) > 0.$$

*Proof.* For $n\ge 3$ the angle $\theta = 2\pi/n$ lies in $(0,\pi]$, where cosine is
strictly decreasing; hence $\cos\theta < \cos 0 = 1$, giving
$2 - 2\cos\theta > 0$. $\square$

The gap is strictly positive, so every non-flat mode decays and the walk mixes.
A second-order Taylor expansion, $\cos\theta = 1 - \theta^2/2 + O(\theta^4)$, yields
$$\mathrm{gap} = 2 - 2\cos\!\Big(\tfrac{2\pi}{n}\Big) = \Big(\tfrac{2\pi}{n}\Big)^2 + O(n^{-4})
= \Theta(n^{-2}),$$
recovering the classical result that the cycle mixes in $\Theta(n^2\log n)$ steps.

## 7. From spectrum to mixing time

Let $S$ be symmetric and set $P = |S|^{-1}A_S$, with eigenvalues
$\mu_\psi = \lambda_\psi(S)/|S| \in [-1,1]$, and $\mu_{\mathrm{triv}} = 1$. Assume
the walk is connected and aperiodic, so $\mu_\psi=1$ only for the trivial character
and $\mu_\psi > -1$ for all $\psi$; let
$$\mu_\star = \max_{\psi\ne\mathrm{triv}} |\mu_\psi|, \qquad \mathrm{gap} = 1-\mu_\star.$$
Expanding the initial state $\delta_0$ in the orthonormal character basis and
applying Theorem 5.1 mode by mode, the non-uniform part of $P^t\delta_0$ is a
combination of terms $\mu_\psi^t$, so
$$\big\|P^t\delta_0 - \mathrm{unif}\big\|_2 \le \mu_\star^{\,t}
\le e^{-\mathrm{gap}\cdot t}.$$
Converting to total-variation distance on $|G|$ points and requiring it to fall
below a fixed threshold gives
$$\tau_{\mathrm{mix}} = O\!\Big(\frac{\log|G|}{\mathrm{gap}}\Big).$$
For the cycle, $\mathrm{gap}=\Theta(n^{-2})$ and $|G|=n$ give
$\tau_{\mathrm{mix}}=\Theta(n^2\log n)$. This is the precise route by which the
single algebraic identity of Theorem 5.1 delivers quantitative mixing bounds.

Two remarks sharpen the picture. First, the bound is driven entirely by the *second*
eigenvalue: all modes except the flat one decay, but the slowest of them dictates the
rate, so the mixing time is a property of a single number. Second, the appearance of
$\log|G|$ rather than a constant reflects the union over the $|G|-1$ non-trivial
modes when passing from the $\ell^2$ bound to a uniform (total-variation) bound; it is
the price of controlling the worst starting point simultaneously with the worst mode.
For many natural families the true behaviour is even sharper than this bound suggests,
exhibiting a *cutoff*: the distance to uniformity stays close to its maximum for a
while and then plunges to zero over a comparatively short window. The character
spectrum is exactly the data needed to detect and quantify such cutoffs.

## 8. A second example: the hypercube

Let $G = (\mathbb{Z}/2\mathbb{Z})^d$, whose $2^d$ elements are bit-strings of length
$d$, and let $S = \{e_1,\dots,e_d\}$ be the standard basis vectors (single-bit
flips). The characters are indexed by subsets $T\subseteq\{1,\dots,d\}$:
$\chi_T(x) = (-1)^{\sum_{i\in T} x_i}$. Then
$$\lambda_{\chi_T}(S) = \sum_{i=1}^d (-1)^{[i\in T]} = d - 2|T|.$$
The top eigenvalue is $d$ (at $T=\emptyset$), the second is $d-2$ (any singleton),
so $\mathrm{gap}/d = 2/d$ after normalization, giving the classical
$\tau_{\mathrm{mix}} = \Theta(d\log d)$ mixing time of the random-bit-flip walk. The
entire spectrum $\{d-2k : 0\le k\le d\}$, with multiplicity $\binom{d}{k}$, drops
out of one character computation — a vivid demonstration of the method's reach.

## 9. Applications

The explicit spectral picture developed above is not merely descriptive; it feeds
directly into a range of applied questions.

**Card shuffling and statistics.** Random walks on groups are the mathematical model
of card shuffling: a shuffle is a random group element, and repeated shuffling is a
random walk on the symmetric group. The abelian theory here is the exactly solvable
model that trains intuition for the harder non-abelian shuffles. The phenomenon that
mixing is controlled by a single second eigenvalue — and, more sharply, that the
distance to uniformity can stay near its maximum and then fall abruptly (the *cutoff
phenomenon*) — is first seen cleanly in these character computations.

**Sampling and Monte Carlo.** Markov chain Monte Carlo methods sample from a target
distribution by running a random walk whose stationary distribution is the target.
The number of steps needed for a reliable sample is exactly the mixing time, hence
exactly the reciprocal spectral gap up to logarithmic factors. When the state space
carries a group structure — lattices, tori, product spaces — the character method
gives the gap in closed form and thus a rigorous runtime guarantee.

**Expander graphs and pseudorandomness.** A family of $d$-regular graphs is a family
of *expanders* precisely when the normalized spectral gap is bounded below by a
constant independent of size. Cayley graphs are a primary source of explicit
expanders, and the eigenvalue formula $\lambda_\psi(S)=\sum_{s\in S}\psi(s)$ is the
starting point for deciding whether a given generating set expands. The cycle, with
gap $\Theta(n^{-2})\to 0$, is a canonical *non*-expander, illustrating by contrast
what a good generating set must avoid: eigenvalue sums that cluster near the degree.

**Coding theory.** Characters of $(\mathbb{Z}/2\mathbb{Z})^d$ are the columns of the
Hadamard/Walsh transform, and the hypercube eigenvalues $d-2|T|$ are the Fourier
spectrum used throughout the analysis of Boolean functions and linear codes. The same
diagonalization that computes mixing times computes the weight enumerators and
noise-stability quantities central to coding and to the analysis of algorithms.

**Quantum computation.** The unitarity and periodicity of the elementary shift are
the defining features of a discrete-time quantum walk. Quantum walks underlie quantum
search algorithms and quantum simulation; on abelian base graphs their spectra are
given, once again, by character sums, so the classical and quantum walks share a
spectral skeleton. Understanding when the quantum walk spreads *faster* than its
classical counterpart is a question about the same eigenvalues $\lambda_\psi(S)$,
viewed through the lens of unitary rather than stochastic dynamics.

## 10. Discussion

The results above show that for finite abelian groups the spectral analysis of
Cayley walks is *complete and explicit*: characters diagonalize the walk operator,
eigenvalues are finite character sums, the dominant eigenvalue and Perron bound are
immediate, symmetry yields a real spectrum, and worked examples (cycle, hypercube)
give exact spectral gaps and mixing times. The elementary shift is unitary and
periodic — the base ingredients of a quantum walk — so the same abelian spectral
data governs both the classical mixing-time program and its quantum analogue.

The abelian setting is special because irreducible representations are
one-dimensional (characters), so simultaneous diagonalization is literally
diagonalization. The general principle — translation invariance forces the
representation-theoretic decomposition of the group algebra to block-diagonalize
the walk — persists for non-abelian groups, but the blocks become matrices of size
equal to the dimensions of the irreducible representations.

The above applications share a single moral: for group-structured state spaces, the
hard analytic quantity — the spectral gap — is available in closed form through
character sums. This turns qualitative statements ("the walk mixes") into
quantitative ones ("the walk mixes in $\Theta(n^2\log n)$ steps") with complete
rigor and minimal machinery.

## 11. Future directions

1. **Full eigenbasis and spectral decomposition.** Establish that the family of
   characters forms an orthogonal basis of $\ell^2(G)$ (character orthogonality),
   upgrading the per-character eigenvalue statement to a complete operator
   decomposition $A = \sum_\chi \lambda_\chi P_\chi$ and hence to genuine
   operator-norm / spectral-gap statements.

2. **Mixing time from the spectral gap (classical walk).** For the stochastic
   normalization $P = A/|S|$, formalize $\|P^t\delta_0 - \mathrm{unif}\| \le
   (1-\mathrm{gap})^t$ and hence $\tau_{\mathrm{mix}} = O(\mathrm{gap}^{-1}\log|G|)$,
   yielding the classical $O(n^2\log n)$ bound for the cycle.

3. **Exact spectra for more groups.** Instantiate the character machinery for
   $\mathbb{Z}/n\mathbb{Z}$ with larger symmetric generating sets, for products
   $\prod \mathbb{Z}/n_i\mathbb{Z}$ (e.g. the hypercube $(\mathbb{Z}/2\mathbb{Z})^d$,
   whose eigenvalues are $d - 2\cdot(\text{Hamming weight})$), and derive their gaps.

4. **Unitary (genuinely quantum) walks.** Replace the non-unitary
   $U=\sum|g\rangle\langle 0|$ by a bona fide coined / Szegedy walk whose one step is
   unitary, and analyze the spectrum via the same character decomposition on abelian
   base graphs. This is where a rigorous quantum-vs-classical mixing comparison can be
   made.

5. **Non-abelian Cayley graphs.** Extend from characters to irreducible
   representations (Fourier analysis on finite groups) to treat, e.g., the random
   transposition walk on $S_n$, whose spectral gap is $\Theta(1/n)$. The abelian
   results here are the base case of that program.

## 12. Conclusion

We have shown that the spectral analysis of random walks on Cayley graphs of finite
abelian groups reduces, in its entirety, to a single algebraic identity: characters
diagonalize the walk operator, with eigenvalues equal to character sums over the
generating set. From this one fact flow unitarity and periodicity of the shift, the
Perron bound, self-adjointness under symmetry, and — through the worked examples of
the cycle and the hypercube — exact spectral gaps and mixing times. The same skeleton
supports the quantum walk, whose defining unitary is the elementary shift. The path
forward is to lift this base case to full operator decompositions, to genuinely
unitary quantum walks, and to the non-abelian world of representation theory, where
the random-transposition shuffle on $S_n$ awaits the same treatment.

## References (indicative)

- Diaconis, *Group Representations in Probability and Statistics*.
- Levin, Peres, Wilmer, *Markov Chains and Mixing Times*.
- Terras, *Fourier Analysis on Finite Groups and Applications*.
- Portugal, *Quantum Walks and Search Algorithms*.
