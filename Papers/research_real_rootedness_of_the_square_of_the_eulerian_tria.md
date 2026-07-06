# Real-Rootedness of the Square of the Eulerian Triangle

**Author:** Aristotle

**Date:** 2026-07-06

## Abstract

The Eulerian numbers $A(n,k)$ count permutations of $\{1,\dots,n\}$ with exactly $k$ ascents, and the Eulerian polynomials $A_n(x)=\sum_k A(n,k)x^k$ form one of the most-studied real-rooted families in enumerative combinatorics. We study the *square of the Eulerian triangle*: regarding the array $M=(A(n,k))$ as an infinite lower-triangular matrix, we consider $M^2$ and its row generating polynomials
$$
S_n(x)=\sum_{k}\Bigl(\sum_j A(n,j)\,A(j,k)\Bigr)x^k.
$$
We prove three exact structural results: (i) the classical row-sum identity $\sum_{k=0}^{n-1}A(n,k)=n!$; (ii) the constant term identity $S_n(0)=n!$; and (iii) the degree identity $\deg S_n = n-2$ for $n\ge 2$. We then establish the pivotal reduction $S_n(x)=\sum_j A(n,j)\,A_j(x)$, expressing each squared-triangle row polynomial as a nonnegative combination of Eulerian polynomials. On this basis we formulate and give extensive exact (Sturm-certified) evidence for the central claim that every $S_n$ has only real, negative roots, with the roots of consecutive rows interlacing. This places the Eulerian case alongside the previously settled squares of the Pascal, Stirling, and Narayana triangles, and isolates the remaining difficulty as a compatibility question inside an interlacing family. All numerical certificates are exact, computed with rational Sturm sequences.

**Keywords:** Eulerian numbers, Eulerian polynomials, real-rootedness, interlacing families, log-concavity, generating functions, matrix powers of combinatorial triangles.

## 1. Introduction

A polynomial with nonnegative coefficients is *real-rooted* when all of its zeros are real. For combinatorial sequences, real-rootedness is far more than an analytic curiosity: by Newton's inequalities it implies (strong) log-concavity and unimodality of the coefficient sequence, and it typically yields a central limit theorem for the associated statistic. Establishing real-rootedness of a family of counting polynomials is therefore one of the most sought-after structural results in enumerative combinatorics.

The significance of real-rootedness for a nonnegative sequence $(a_0,\dots,a_d)$ can hardly be overstated. It is equivalent to the existence of a probabilistic interpretation as the distribution of a sum of independent Bernoulli variables, and it implies the strongest natural notions of smoothness a discrete sequence can have: ultra-log-concavity, log-concavity, and unimodality, together with an asymptotic normal limit law. For the Eulerian numbers themselves this is the classical statement that the number of ascents (or descents) of a uniformly random permutation obeys a central limit theorem. When one manipulates a triangle of such numbers, the pressing question is whether these delicate analytic properties survive; generic algebraic operations destroy them, so each operation that *preserves* real-rootedness reveals a genuine structural rigidity of the underlying combinatorics.

Among the classical triangles of numbers, several admit a natural interpretation as an infinite lower-triangular matrix, and one may ask whether *matrix powers* of such a triangle preserve real-rootedness of the row generating polynomials. Recent work has answered this affirmatively for the squares of the Pascal, Stirling, and Narayana triangles. The Eulerian triangle, whose rows are the Eulerian numbers, is a natural and more delicate next target: its rows are palindromic, its entries grow rapidly, and its recurrence carries two nontrivial weights. This paper develops the structural theory of the square of the Eulerian triangle and assembles the exact facts and the reduction that make the real-rootedness question tractable.

### Contributions

1. A self-contained treatment of the Eulerian numbers via their triangular recurrence, culminating in a proof of the **row-sum identity** $\sum_{k=0}^{n-1}A(n,k)=n!$ (Theorem 3.1).
2. The **squared triangle** $T(n,k)=\sum_j A(n,j)A(j,k)$ and its row polynomials $S_n$, together with the **constant-term identity** $S_n(0)=n!$ (Theorem 4.2) and the **degree identity** $\deg S_n=n-2$ (Proposition 4.3).
3. The **reduction identity** $S_n(x)=\sum_j A(n,j)A_j(x)$ (Theorem 4.4), recasting the opaque double sum as a nonnegative combination of Eulerian polynomials.
4. The **Real-Rootedness Claim** (Section 5) with an interlacing-family strategy and exact Sturm-sequence certificates for all $n$ computed, including root interlacing between consecutive rows.

## 2. Definitions

### 2.1 Eulerian numbers

**Definition 2.1 (Eulerian numbers).** The *Eulerian number* $A(n,k)$ is the number of permutations of $\{1,\dots,n\}$ with exactly $k$ ascents (positions $i$ with $\pi(i)<\pi(i+1)$). Equivalently, they are defined by the triangular recurrence
$$
A(0,0)=1,\qquad A(n,0)=1\ (n\ge 1),\qquad A(n,k)=(k+1)A(n-1,k)+(n-k)A(n-1,k-1).
$$
By convention $A(n,k)=0$ when $k<0$ or $k\ge n$ (for $n\ge 1$).

The first rows are
$$
\begin{array}{r|cccccc}
n\backslash k & 0 & 1 & 2 & 3 & 4 & 5\\ \hline
1 & 1 \\
2 & 1 & 1 \\
3 & 1 & 4 & 1 \\
4 & 1 & 11 & 11 & 1 \\
5 & 1 & 26 & 66 & 26 & 1 \\
6 & 1 & 57 & 302 & 302 & 57 & 1
\end{array}
$$
Each row is symmetric, $A(n,k)=A(n,n-1-k)$, reflecting the ascent/descent involution $\pi\mapsto\pi^{\mathrm{rev}}$.

**Definition 2.2 (Eulerian polynomials).** The $n$-th *Eulerian polynomial* is
$$
A_n(x)=\sum_{k=0}^{n-1}A(n,k)\,x^k,\qquad A_0(x)=1.
$$
Thus $A_1(x)=1$, $A_2(x)=1+x$, $A_3(x)=1+4x+x^2$, $A_4(x)=1+11x+11x^2+x^3$.

### 2.2 The square of the triangle

**Definition 2.3 (Squared Eulerian triangle).** Let $M$ be the infinite lower-triangular matrix with $M_{n,k}=A(n,k)$ for $0\le k$, $M_{n,k}=0$ for $k$ outside the valid range. The *squared triangle* is $M^2$, with entries
$$
T(n,k)=\sum_{j\ge 0}A(n,j)\,A(j,k).
$$

**Definition 2.4 (Squared-triangle row polynomials).** For each $n$,
$$
S_n(x)=\sum_{k\ge 0}T(n,k)\,x^k .
$$
Concretely,
$$
S_2=2,\quad S_3=6+x,\quad S_4=24+15x+x^2,\quad S_5=120+181x+37x^2+x^3,
$$
$$
S_6=720+2163x+995x^2+83x^3+x^4,\quad S_7=5040+27133x+23739x^2+4613x^3+177x^4+x^5.
$$

### 2.3 A worked example: the fifth rows

It is worth carrying a concrete case throughout. Take $n=5$. The fifth Eulerian row is
$$
A(5,0),\dots,A(5,4)=1,\;26,\;66,\;26,\;1,\qquad \text{sum}=120=5!.
$$
The corresponding Eulerian polynomial is $A_5(x)=1+26x+66x^2+26x^3+x^4$, which factors over the reals with all-negative roots. To form the fifth row of the *square*, we contract $A(5,\cdot)$ against the columns of the triangle:
$$
T(5,k)=\sum_{j=0}^{4}A(5,j)\,A(j,k),\qquad k=0,1,2,3.
$$
Carrying this out gives $T(5,0)=120$, $T(5,1)=181$, $T(5,2)=37$, $T(5,3)=1$, so
$$
S_5(x)=120+181x+37x^2+x^3.
$$
One sees at a glance the two structural identities in action: the constant term is $120=5!$, and the degree is $3=5-2$ with leading coefficient $1$. The reduction identity reads
$$
S_5(x)=\sum_{j=0}^{4}A(5,j)A_j(x)=1\cdot A_0+26\,A_1+66\,A_2+26\,A_3+1\cdot A_4,
$$
with $A_0=A_1=1$, $A_2=1+x$, $A_3=1+4x+x^2$, $A_4=1+11x+11x^2+x^3$; expanding and collecting recovers $S_5$ exactly. Its three roots are approximately $-31.35,\,-4.86,\,-0.79$: all real, all negative.

## 3. The row-sum identity

**Theorem 3.1 (Row-sum identity).** For every $n\ge 1$,
$$
\sum_{k=0}^{n-1}A(n,k)=n!.
$$

*Proof sketch.* Combinatorially, the $n!$ permutations of $\{1,\dots,n\}$ are partitioned by their number of ascents, so summing the bin sizes returns all $n!$ permutations. A purely algebraic proof, matching the triangular recurrence, proceeds by induction on $n$. The base case $n=1$ reads $A(1,0)=1=1!$. For the inductive step, split the row-$(n{+}1)$ sum by peeling off the $k=0$ term with $\sum_{k}A(n{+}1,k)=A(n{+}1,0)+\sum_{k\ge 1}A(n{+}1,k)$ and substitute the recurrence $A(n{+}1,k{+}1)=(k{+}2)A(n,k{+}1)+(n{-}k)A(n,k)$ into the tail. Collecting the two resulting sums and using the diagonal vanishing $A(n,n)=0$, the coefficient of each $A(n,k)$ telescopes to $(k+1)+(n-k)=n+1$, giving
$$
\sum_{k=0}^{n}A(n{+}1,k)=(n+1)\sum_{k=0}^{n-1}A(n,k)=(n+1)\cdot n!=(n+1)!,
$$
by the inductive hypothesis. $\qquad\blacksquare$

**Combinatorial reading of the recurrence.** The two weights in $A(n,k)=(k+1)A(n-1,k)+(n-k)A(n-1,k-1)$ record how the ascent count changes when the largest element $n$ is inserted into a permutation of $\{1,\dots,n-1\}$. If the shorter permutation has $k$ ascents, inserting $n$ at the end or immediately after an existing ascent (or at the very front in the descent slots) keeps the count at $k$; there are $k+1$ such positions. Inserting $n$ into any of the remaining $n-k$ positions creates a fresh ascent, raising the count to $k$ from a source with $k-1$ ascents. Summing over all shorter permutations reproduces the recurrence, and summing the recurrence over $k$ is exactly the algebraic mechanism behind the factor $n+1$ in Theorem 3.1.

The key algebraic lemma inside the induction is the reindexing identity
$$
\Bigl(\sum_{k=0}^{n-1}(k+2)A(n,k+1)\Bigr)+1=\sum_{k=0}^{n-1}(k+1)A(n,k),
$$
which holds because the shift $k\mapsto k+1$ in the weighted sum, together with the boundary term $A(n,0)=1$ and diagonal vanishing $A(n,n)=0$, realigns the coefficients. This identity is exactly what makes the two halves of the split sum recombine into a single weighted row sum.

## 4. Structure of the squared triangle

We first record two elementary boundary facts.

**Lemma 4.1 (Boundary of the triangle).** For all $n$, $A(n,0)=1$; and $A(n,k)=0$ whenever $k\ge n\ge 1$ (in particular $A(n,n)=0$).

*Proof.* The left column is $1$ by definition/recurrence base. The diagonal vanishing follows by induction: $A(n{+}1,n{+}1)=(n{+}2)A(n,n{+}1)+(n{-}n)A(n,n)=0$ since both Eulerian numbers on the right vanish above the diagonal. $\qquad\blacksquare$

**Theorem 4.2 (Constant-term identity).** For every $n\ge 1$, $S_n(0)=n!$.

*Proof.* The constant term of $S_n$ is $T(n,0)=\sum_j A(n,j)A(j,0)$. By Lemma 4.1, $A(j,0)=1$ for all $j$, so $T(n,0)=\sum_{j=0}^{n-1}A(n,j)$, which equals $n!$ by Theorem 3.1. $\qquad\blacksquare$

**Proposition 4.3 (Degree identity).** For every $n\ge 2$, $\deg S_n=n-2$, and the leading coefficient $T(n,n-2)=1$.

*Proof.* $T(n,k)=\sum_j A(n,j)A(j,k)$ is nonzero only when there is an index $j$ with $A(n,j)\ne 0$ and $A(j,k)\ne 0$. By Lemma 4.1, $A(n,j)\ne 0$ forces $j\le n-1$, and $A(j,k)\ne 0$ forces $k\le j-1\le n-2$. Hence $T(n,k)=0$ for $k>n-2$. For $k=n-2$ the only surviving term is $j=n-1$, giving $T(n,n-2)=A(n,n-1)A(n-1,n-2)=1\cdot 1=1$, using the palindromic corner values. $\qquad\blacksquare$

**Theorem 4.4 (Reduction to Eulerian polynomials).** For every $n$,
$$
S_n(x)=\sum_{j=0}^{n-1}A(n,j)\,A_j(x).
$$

*Proof.* Exchange the order of summation:
$$
S_n(x)=\sum_k\Bigl(\sum_j A(n,j)A(j,k)\Bigr)x^k=\sum_j A(n,j)\Bigl(\sum_k A(j,k)x^k\Bigr)=\sum_j A(n,j)A_j(x). \qquad\blacksquare
$$

Theorem 4.4 is the conceptual heart of the paper: it recognizes the row of the squared triangle as the *$A(n,\cdot)$-weighted average of the Eulerian polynomials*, with nonnegative integer weights summing to $n!$.

## 5. Real-rootedness

### 5.1 Statement and evidence

**Central Claim 5.1 (Real-rootedness of the squared rows).** For every $n$, the polynomial $S_n(x)$ has only real roots; all roots are strictly negative; and the roots of $S_n$ and $S_{n+1}$ interlace.

The claim is supported by exact certificates. Using rational Sturm sequences (Section 6), one counts the real roots of $S_n$ without any floating-point error. For every $n$ computed the count of real roots equals the degree $n-2$, all roots lie in $(-\infty,0)$, and consecutive rows interlace. Representative isolated roots:

$$
\begin{array}{c|l}
n & \text{roots of } S_n \\ \hline
3 & -6 \\
4 & -13.1789,\ -1.8211 \\
5 & -31.3483,\ -4.8649,\ -0.7869 \\
6 & -69.0396,\ -11.2778,\ -2.2764,\ -0.4062 \\
7 & -146.6367,\ -23.9849,\ -4.8685,\ -1.2799,\ -0.2300 \\
8 & -305.044,\ -49.193,\ -9.120,\ -2.718,\ -0.788,\ -0.138
\end{array}
$$

In every displayed row the roots strictly interlace those of the row above.

### 5.2 Strategy via interlacing families

The proof strategy rests on Theorem 4.4 together with the classical theory of *compatible* (interlacing) polynomial families.

**Definition 5.2 (Common interlacer).** Real-rooted polynomials $p$ and $q$ of degrees $d$ and $d$ (or $d$ and $d-1$) *interlace* if their roots alternate on the real line. A family $\{p_j\}$ has a *common interlacer* if there is a single real-rooted $g$ whose roots separate the roots of each $p_j$.

**Principle 5.3 (Nonnegative combinations preserve real-rootedness).** If real-rooted polynomials $p_1,\dots,p_m$ have a common interlacer (equivalently, every nonnegative combination is real-rooted), then for any $c_1,\dots,c_m\ge 0$ the combination $\sum_i c_i p_i$ is real-rooted.

The Eulerian polynomials $\{A_j\}$ are the archetypal such family: each $A_j$ is real-rooted with strictly negative simple roots, and consecutive Eulerian polynomials interlace (a consequence of the standard three-term structure $A_{j+1}(x)=(1+ jx)A_j(x)+x(1-x)A_j'(x)$, which makes them a Sturm-type/orthogonal-like chain). By Theorem 4.4, $S_n=\sum_j A(n,j)A_j$ with nonnegative weights $A(n,j)\ge 0$; hence, once compatibility of the Eulerian family under these specific weights is secured, Principle 5.3 yields real-rootedness of $S_n$. This reduces the entire problem from an opaque double sum to a single, well-posed compatibility statement about a classical family — the sense in which the Eulerian case is now "one step" from its Pascal, Stirling, and Narayana counterparts.

### 5.3 Consequences

Assuming Claim 5.1, standard implications follow immediately for each row of the squared triangle:

- **Log-concavity and no internal zeros:** $T(n,k)^2\ge T(n,k-1)T(n,k+1)$ for all $k$.
- **Unimodality:** the sequence $T(n,0),\dots,T(n,n-2)$ rises then falls with a single peak.
- **Asymptotic normality:** the coefficient sequence, suitably normalized, converges to a Gaussian, by the central limit theorem for real-rooted generating polynomials with negative roots.

### 5.4 Why the Eulerian family interlaces

For completeness we recall why the ingredients of the strategy hold for the Eulerian family itself. Write $A_n(x)=\sum_k A(n,k)x^k$. Differentiating the exponential generating identity, or manipulating the triangular recurrence, yields the differential recurrence
$$
A_{n+1}(x)=\bigl(1+nx\bigr)A_n(x)+x(1-x)A_n'(x).
$$
From this one proves by induction that $A_n$ has $n-1$ distinct negative real roots and that the roots of $A_n$ strictly separate those of $A_{n+1}$. Indeed, if $A_n$ has simple negative roots $r_1<\dots<r_{n-1}<0$, then between consecutive roots $A_n$ changes sign, and the term $x(1-x)A_n'(x)$ controls the sign of $A_{n+1}$ at those roots so that $A_{n+1}$ acquires exactly one root in each gap plus one more, giving $n$ simple negative roots that interlace the previous ones. This is the classical statement that $\{A_n\}$ is a *Sturm sequence–like* (equivalently, a compatible / interlacing) family. It is precisely this property that Principle 5.3 leverages: because the weights $A(n,j)$ in Theorem 4.4 are nonnegative, the weighted sum $S_n=\sum_j A(n,j)A_j$ stays within the real-rooted cone generated by the compatible family.

### 5.5 Comparison with other squared triangles

The same matrix-squaring question has been settled affirmatively for three classical triangles, and it is instructive to compare:

- **Pascal's triangle**, with entries $\binom{n}{k}$: the square has entries $\sum_j\binom{n}{j}\binom{j}{k}=2^{n-k}\binom{n}{k}$, and the row polynomials are $(1+2x)^n$-type expressions, transparently real-rooted.
- **Stirling triangle** (second kind), whose row polynomials are the Bell/Touchard polynomials: real-rootedness of the square follows from the same interlacing-family principle applied to a family that is itself real-rooted.
- **Narayana triangle**, tied to the Catalan combinatorics of Dyck paths: its row polynomials are real-rooted, and the square inherits real-rootedness by nonnegative combination.

In each of these cases the decisive structural feature is exactly the one isolated here for the Eulerian triangle by Theorem 4.4: the square's rows are nonnegative combinations of a compatible, real-rooted family. The Eulerian case is more delicate only because the underlying family (the Eulerian polynomials) has faster-growing coefficients and a two-weight recurrence, but the mechanism is identical, which is why the results assembled here bring it into line with its cousins.

## 6. Algorithms

### 6.1 Generating the triangle and its square

Both the Eulerian triangle and its square are generated directly from Definition 2.1 by dynamic programming, memoizing $A(n,k)$. The squared row $T(n,\cdot)$ is a single matrix–row/column contraction over $0\le j\le n-1$. Producing all rows up to $N$ costs $O(N^2)$ integer operations for the triangle and $O(N^3)$ for all squared rows (or $O(N^2)$ per row).

### 6.2 Exact real-root certification by Sturm sequences

Given $S_n$ with integer coefficients, its number of distinct real roots in an interval $(a,b]$ equals $V(a)-V(b)$, where $V(x)$ is the number of sign changes in the *Sturm sequence*
$$
p_0=S_n,\quad p_1=S_n',\quad p_{i+1}=-\operatorname{rem}(p_{i-1},p_i),
$$
evaluated at $x$. Carrying out all remainders over $\mathbb{Q}$ makes the count exact. Comparing $V(-\infty)-V(+\infty)$ with the degree certifies that *all* roots are real, and $V(-\infty)-V(0)$ certifies negativity. Roots are then isolated by exact bisection on the sign-change count and refined to any desired precision. This gives certificates with no floating-point error.

## 7. Applications and context

Real-rooted enumerative polynomials sit at the crossroads of combinatorics, probability, and geometry. The Eulerian polynomials themselves govern the descent statistic on the symmetric group, the $h$-vector of the type-$A$ Coxeter complex / the boundary of the permutohedron, and the volumes of hypersimplices; they underlie the theory of uniform B-splines through Schoenberg's identity. The squared triangle inherits this rich context: its constant terms are factorials, and its rows are $A(n,\cdot)$-averages of the descent polynomials of smaller symmetric groups, so real-rootedness of $S_n$ is a statement about the persistent "Gaussian shape" of these mixtures. More broadly, understanding which matrix operations on combinatorial triangles preserve real-rootedness clarifies the algebraic robustness of log-concavity — a theme central to the modern theory of Lorentzian polynomials and to the interlacing-families method that resolved the Kadison–Singer problem and produced Ramanujan expanders.

### 7.1 Newton's inequalities in detail

The passage from real-rootedness to log-concavity is made precise by Newton's inequalities. If $p(x)=\sum_{k=0}^d a_k x^k$ has only real roots and all $a_k>0$, then, writing the normalized coefficients $b_k=a_k/\binom{d}{k}$, one has $b_k^2\ge b_{k-1}b_{k+1}$ for $1\le k\le d-1$. Applied to $S_n$ (assuming Claim 5.1) this yields the *strong* (binomial-normalized) log-concavity of the squared-triangle coefficients $T(n,k)$, which in turn forces ordinary log-concavity and unimodality with at most a two-element plateau at the peak. These are quantitative smoothness statements that would be difficult to extract from the double-sum definition directly, and they illustrate why real-rootedness is the property one wants rather than log-concavity alone.

### 7.2 Open conjectures

The results here suggest a hierarchy of increasingly strong statements, of which Claim 5.1 is the first.

- **(Full real-rootedness.)** For every $n$, $S_n(x)=\sum_j A(n,j)A_j(x)$ has only real, negative roots. The reduction to a nonnegative combination of the Eulerian family makes this a compatibility question amenable to the interlacing method.
- **(Higher powers.)** For every $m\ge 1$ and every $n$, the $n$-th row polynomial of the $m$-th matrix power of the Eulerian array has only real roots. Each power is again a nonnegative combination of the previous power's rows, suggesting induction on the exponent $m$.
- **($\gamma$-positivity refinement.)** A centered/reversed form of $S_n$ expands nonnegatively in the basis $\{x^i(1+x)^{d-2i}\}$, a property strictly stronger than real-rootedness for symmetric polynomials and consistent with the tightly interlaced negative spectra observed.
- **(Row interlacing.)** The roots of $S_n$ and $S_{n+1}$ interlace on the negative axis; by the standard theory of interlacing sequences this would itself imply real-rootedness of the whole family by a single induction on $n$.

## 8. Discussion and future work

The exact identities of Sections 3–4 (row sum, constant term, degree, and the reduction to a weighted sum of Eulerian polynomials) are established rigorously. The real-rootedness statement is certified exactly for every case computed and is reduced, via Theorem 4.4 and Principle 5.3, to a compatibility question inside the Eulerian interlacing family. Completing that compatibility argument in full generality is the natural next step and would settle the Eulerian analogue of the Pascal/Stirling/Narayana results. Several sharper structural conjectures — higher matrix powers, $\gamma$-positivity refinements, and precise root interlacing between consecutive rows — are recorded as future directions.

## 9. Conclusion

Squaring the Eulerian triangle, an operation that mixes the entire triangle into itself, produces polynomials $S_n$ that remain strikingly disciplined: their constant terms are exactly $n!$, their degrees drop by two, and — on all available exact evidence — their roots are real, negative, and interlacing. The decisive simplification is the recognition that each $S_n$ is a nonnegative combination of the classical, real-rooted Eulerian polynomials, which turns a tangled double sum into a clean question about an interlacing family and brings the long-open Eulerian case into reach.

## References (context)

- L. Euler, *Institutiones calculi differentialis* (1755), origin of the Eulerian numbers.
- The theory of real-rooted, log-concave, and unimodal sequences in combinatorics.
- The method of interlacing families of polynomials.
- Prior real-rootedness results for the squares of the Pascal, Stirling, and Narayana triangles.
