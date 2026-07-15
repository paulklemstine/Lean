# Sharp Five-Vertex Path Densities for Symmetric Weighted Networks

**Aristotle**  
**July 15, 2026**

## Abstract

We establish a sharp Sidorenko-type inequality for the five-vertex path in finite symmetric real weighted networks. If $A$ is a symmetric real matrix of order $n$, $S=\sum_{i,j}A_{ij}$ is its total ordered edge weight, and $P$ is the weighted homomorphism count of the path with five vertices and four edges, then

$$
S^4\le n^3P.
$$

Equivalently, for every nonempty network,

$$
t(P_5,A)\ge t(K_2,A)^4.
$$

The proof requires neither entrywise nonnegativity nor positive semidefiniteness. Its key identity equates the total two-step weight with the squared Euclidean norm of the degree vector; two applications of Cauchy–Schwarz then give the result. Constant kernels attain equality, proving that the normalization and coefficient are sharp. As a consequence, every finite doubly nonnegative weighted network satisfies the five-vertex-path inequality, and so does every class composed of symmetric kernels. Thus the five-vertex path cannot furnish a separation between a universal spectral condition and the corresponding Sidorenko inequality under the standard homomorphism-density definitions. We also give direct algorithms for evaluating all quantities and interpreting the nonnegative gap as a two-level measure of network irregularity.

## 1. Introduction

Homomorphism densities measure how frequently a fixed small graph appears inside a large graph or weighted network. For a graph $H$ with $e(H)$ edges, a Sidorenko-type inequality compares its density with the edge density raised to the power $e(H)$. In its familiar nonnegative setting, the inequality has the form

$$
t(H,A)\ge t(K_2,A)^{e(H)}.
$$

Trees are among the fundamental examples for which such inequalities hold. The five-vertex path $P_5$ is the tree consisting of four consecutive edges. Despite its simplicity, it is a useful test case for proposed principles that transfer spectral inequalities into combinatorial density bounds.

The motivating issue is whether one can choose an admissible class of kernels for which an appropriate spectral inequality holds universally while the $P_5$ density inequality fails. The class of doubly nonnegative kernels is a natural candidate because it combines entrywise nonnegativity with positive semidefiniteness. Such kernels carry both combinatorial and spectral positivity.

The main result rules out this candidate, and considerably more. The five-vertex path inequality holds for every finite symmetric real matrix. Entries may be negative and the matrix may have negative eigenvalues. Consequently, the spectral and order positivity in a doubly nonnegative matrix are superfluous for this result.

The argument has three stages. First, the path count is represented as the squared norm of a two-step vector. Second, symmetry yields an identity between the sum of this vector and the squared norm of the degree vector. Third, Cauchy–Schwarz is applied first to the degree vector and then to the two-step vector. The resulting chain is

$$
\left(\sum_i d_i\right)^2
\le n\sum_i d_i^2,
\qquad
\left(\sum_i d_i^2\right)^2
\le n\sum_i (Ad)_i^2.
$$

Combining these inequalities gives the fourth-power path bound. The proof is short, but it identifies precisely why a separation based on $P_5$ is impossible: the desired conclusion is already forced by the algebraic structure of a symmetric path count.

The paper is organized as follows. Section 2 introduces weighted networks, degrees, two-step weights, and homomorphism densities. Section 3 proves the central identity. Section 4 establishes the sharp unnormalized and normalized inequalities. Section 5 studies equality and the gap. Section 6 records consequences for doubly nonnegative kernels and admissible classes. Section 7 presents computational algorithms and examples. Sections 8 and 9 discuss applications, limitations, and future directions.

## 2. Definitions and setup

### 2.1 Finite symmetric weighted networks

Let $V$ be a finite set with cardinality $n$. A real weighted network on $V$ is a matrix

$$
A=(A_{ij})_{i,j\in V}
$$

with real entries. Loops are allowed, and weights are not assumed to lie in $[0,1]$. The network is **symmetric** if

$$
A_{ij}=A_{ji}
$$

for all $i,j\in V$. Unless stated otherwise, all principal results assume symmetry but no sign condition.

The **weighted degree** of $i$ is

$$
d_i=\sum_{j\in V}A_{ij}.
$$

Writing $\mathbf 1$ for the all-ones vector and $d=A\mathbf 1$, the **total ordered edge weight** is

$$
S=\sum_{i\in V}d_i
=\sum_{i,j\in V}A_{ij}
=\mathbf 1^{\mathsf T}A\mathbf 1.
$$

The adjective “ordered” indicates that both $(i,j)$ and $(j,i)$ occur in the sum. This convention is exactly the convention used in homomorphism counts.

### 2.2 Two-step weights

Define the **two-step weight** from vertex $i$ by

$$
u_i=\sum_{j\in V}A_{ij}d_j.
$$

In vector notation,

$$
u=Ad=A^2\mathbf 1.
$$

The quantity $u_i$ aggregates all weighted walks of length two that begin at $i$. Indeed,

$$
u_i=\sum_{j,k\in V}A_{ij}A_{jk}.
$$

No positivity is needed for this interpretation as an algebraic weighted sum.

### 2.3 Weighted homomorphism counts

For a finite simple graph $H=(V(H),E(H))$, define its unnormalized weighted homomorphism count in $A$ by

$$
\operatorname{hom}(H,A)
=
\sum_{\phi:V(H)\to V}
\prod_{\{x,y\}\in E(H)}A_{\phi(x)\phi(y)}.
$$

The map $\phi$ need not be injective. If $n>0$, the associated density is

$$
t(H,A)=\frac{\operatorname{hom}(H,A)}{n^{|V(H)|}}.
$$

Let $K_2$ denote a single edge. Then

$$
\operatorname{hom}(K_2,A)=S,
\qquad
t(K_2,A)=\frac{S}{n^2}.
$$

Let $P_5$ denote the path with vertices $1,2,3,4,5$ and edges $12,23,34,45$. Its weighted count is

$$
\operatorname{hom}(P_5,A)
=
\sum_{x_1,\ldots,x_5\in V}
A_{x_1x_2}A_{x_2x_3}A_{x_3x_4}A_{x_4x_5}.
$$

For symmetric $A$, split the path at its middle vertex $x_3$. The sum over $x_1,x_2$ is a two-step weight ending at $x_3$, and the sum over $x_4,x_5$ is a two-step weight beginning there. Symmetry identifies the two. Therefore

$$
\operatorname{hom}(P_5,A)=\sum_{i\in V}u_i^2.
$$

We abbreviate this quantity by

$$
P=\sum_i u_i^2=\|A^2\mathbf 1\|_2^2.
$$

It follows that

$$
t(P_5,A)=\frac{P}{n^5}.
$$

### 2.4 Doubly nonnegative networks

A finite weighted network is **doubly nonnegative** if:

1. $A$ is symmetric;
2. $A_{ij}\ge0$ for all $i,j$;
3. $x^{\mathsf T}Ax\ge0$ for every real vector $x$.

The third condition says that $A$ is positive semidefinite. The term “doubly” refers to simultaneous entrywise and spectral nonnegativity. This class is important in matrix optimization, but the main inequality below holds without conditions 2 and 3.

## 3. The two-step identity

The bridge from edge weight to path count is an exact identity.

**Lemma 3.1 (Two-step sum identity).** Let $A$ be a finite symmetric real weighted network, with degree vector $d$ and two-step vector $u=Ad$. Then

$$
\sum_i u_i=\sum_i d_i^2.
$$

**Proof sketch.** Expand the left side and exchange the finite sums:

$$
\sum_i u_i
=\sum_{i,j}A_{ij}d_j
=\sum_j d_j\left(\sum_i A_{ij}\right).
$$

By symmetry, the column sum $\sum_iA_{ij}$ equals the row sum $\sum_iA_{ji}=d_j$. Substitution gives $\sum_jd_j^2$. $\square$

The identity may also be written

$$
\mathbf 1^{\mathsf T}A^2\mathbf 1
=(A\mathbf 1)^{\mathsf T}(A\mathbf 1).
$$

For a symmetric matrix, this is the elementary transpose relation

$$
\mathbf 1^{\mathsf T}A^2\mathbf 1
=(A\mathbf 1)^{\mathsf T}A\mathbf 1.
$$

Its role is combinatorial as well as linear-algebraic: total two-step walk weight equals the sum of squared weighted degrees.

## 4. Main inequalities

### 4.1 Unnormalized theorem

**Theorem 4.1 (Sharp five-vertex path inequality).** Let $A$ be any symmetric real weighted network on a finite set of $n$ vertices. Let

$$
S=\sum_{i,j}A_{ij}
$$

and

$$
P=\operatorname{hom}(P_5,A)=\sum_i(Ad)_i^2.
$$

Then

$$
S^4\le n^3P.
$$

The statement remains valid when $n=0$, with both sides interpreted by the empty sums.

**Proof sketch.** For $n>0$, apply Cauchy–Schwarz to $d_1,\ldots,d_n$:

$$
S^2=\left(\sum_i d_i\right)^2
\le n\sum_i d_i^2.
$$

Apply Cauchy–Schwarz again to $u_1,\ldots,u_n$:

$$
\left(\sum_i u_i\right)^2
\le n\sum_i u_i^2=nP.
$$

Lemma 3.1 replaces $\sum_i u_i$ by $\sum_i d_i^2$, so

$$
\left(\sum_i d_i^2\right)^2\le nP.
$$

Squaring the first inequality and using the second yields

$$
S^4
\le n^2\left(\sum_i d_i^2\right)^2
\le n^3P.
$$

When $n=0$, every sum is zero. $\square$

Two aspects deserve emphasis. First, Cauchy–Schwarz applies to arbitrary real numbers, so signed entries cause no difficulty. Second, the matrix is used only through symmetry in Lemma 3.1. No statement about eigenvalue signs appears.

### 4.2 Density theorem

**Theorem 4.2 (Normalized five-vertex path inequality).** Let $A$ be a symmetric real weighted network on a nonempty set of $n$ vertices. Then

$$
t(P_5,A)\ge t(K_2,A)^4.
$$

**Proof sketch.** Divide Theorem 4.1 by $n^8$. Since

$$
\frac{S^4}{n^8}=\left(\frac{S}{n^2}\right)^4=t(K_2,A)^4
$$

and

$$
\frac{n^3P}{n^8}=\frac{P}{n^5}=t(P_5,A),
$$

the result follows. $\square$

The exponent is exactly $e(P_5)=4$. Thus the theorem has the standard Sidorenko form even in the larger signed symmetric setting.

## 5. Sharpness, equality, and stability indicators

### 5.1 Constant kernels

**Theorem 5.1 (Sharpness by constant kernels).** Fix $c\in\mathbb R$ and let $A_{ij}=c$ for all $i,j$ on a set of $n$ vertices. Then

$$
S^4=n^3P.
$$

Consequently, the coefficient $n^3$ in Theorem 4.1 and the coefficient $1$ in Theorem 4.2 are optimal.

**Proof sketch.** Every degree equals $nc$, so

$$
S=n^2c.
$$

Every two-step weight equals

$$
u_i=\sum_j c(nc)=n^2c^2.
$$

Hence

$$
P=\sum_i u_i^2=n(n^2c^2)^2=n^5c^4.
$$

Both sides of the claimed equality are $n^8c^4$. $\square$

Constant kernels make both Cauchy–Schwarz inequalities equalities. The degree vector is constant, and the two-step vector is constant.

### 5.2 Equality conditions from the proof

For $n>0$, equality in the first Cauchy–Schwarz step occurs exactly when

$$
d_1=d_2=\cdots=d_n.
$$

Equality in the second occurs exactly when

$$
u_1=u_2=\cdots=u_n.
$$

Therefore simultaneous constancy of the degree and two-step vectors is sufficient for equality in Theorem 4.1. Constant kernels are the simplest examples, though they need not exhaust all matrices with these two uniformity properties.

### 5.3 Decomposing the gap

Define

$$
T=\sum_i d_i^2,
\qquad
P=\sum_i u_i^2.
$$

The proof produces two nonnegative slacks,

$$
\Delta_d=nT-S^2\ge0
$$

and

$$
\Delta_u=nP-T^2\ge0.
$$

A direct calculation gives

$$
\Delta_d=n\sum_i(d_i-\bar d)^2,
\qquad
\bar d=\frac{S}{n},
$$

and, using $\sum_i u_i=T$,

$$
\Delta_u=n\sum_i(u_i-\bar u)^2,
\qquad
\bar u=\frac{T}{n}.
$$

Thus the two inequalities measure variance at successive propagation levels. The total path gap can be expressed as

$$
n^3P-S^4
=n^2\Delta_u+\Delta_d(nT+S^2).
$$

Indeed, $n^3P-n^2T^2=n^2\Delta_u$, while $n^2T^2-S^4=(nT-S^2)(nT+S^2)$. This formula makes nonnegativity transparent and separates the contribution of degree irregularity from the contribution of two-step irregularity.

When $S\ne0$, the dimensionless ratio

$$
R=\frac{n^3P}{S^4}
$$

satisfies $R\ge1$. It can serve as a motif-based heterogeneity index, though care is needed when cancellation makes $S$ small.

## 6. Consequences for spectral admissibility

### 6.1 Doubly nonnegative kernels

**Corollary 6.1.** Every finite doubly nonnegative weighted network satisfies

$$
S^4\le n^3P,
$$

and, when nonempty,

$$
t(P_5,A)\ge t(K_2,A)^4.
$$

**Proof sketch.** A doubly nonnegative matrix is symmetric by definition. Apply Theorems 4.1 and 4.2. Entrywise nonnegativity and positive semidefiniteness are not used. $\square$

This is stronger than a result proved specifically through spectral positivity, because the conclusion survives after both positivity assumptions are removed.

### 6.2 Arbitrary symmetric classes

**Corollary 6.2 (Classwise path inequality).** Let $\mathcal C$ be any class of finite real weighted networks such that every member of $\mathcal C$ is symmetric. Then every $A\in\mathcal C$ satisfies

$$
S^4\le n^3P.
$$

For every nonempty member,

$$
t(P_5,A)\ge t(K_2,A)^4.
$$

**Proof sketch.** Theorem 4.1 applies separately to each member of $\mathcal C$. $\square$

This classwise statement rules out a proposed type of separation. If an admissible class consists of symmetric kernels, one cannot have a universal spectral property on that class while finding within it a counterexample to the standard $P_5$ Sidorenko inequality. The path inequality does not need the spectral property in the first place.

This conclusion is specific to the standard weighted homomorphism count and normalization defined in Section 2. A modified spectral inequality, a nonstandard density, or a nonsymmetric model would constitute a different problem.

## 7. Algorithms and numerical demonstrations

### 7.1 Direct evaluation algorithm

Given a dense $n\times n$ matrix, all quantities can be evaluated without enumerating $n^5$ vertex maps.

**Algorithm 7.1 (Two-step path-density evaluation).**

1. Verify that $A$ is square and symmetric within the selected numerical tolerance.
2. Compute $d=A\mathbf 1$.
3. Compute $S=\mathbf 1^{\mathsf T}d$.
4. Compute $u=Ad$.
5. Compute $P=u^{\mathsf T}u$.
6. Return $S^4$, $n^3P$, the gap $n^3P-S^4$, and, for $n>0$, the densities $S/n^2$ and $P/n^5$.

For dense data, the matrix-vector products require $O(n^2)$ arithmetic operations and $O(n^2)$ storage if the matrix is stored explicitly. The remaining reductions require $O(n)$ time. For a sparse matrix with $m$ stored nonzero entries, the computation takes $O(m+n)$ time and $O(m+n)$ storage.

### 7.2 Constant example

For $n=3$ and $A_{ij}=1/2$, one has

$$
d_i=\frac32,
\qquad
u_i=\frac94,
\qquad
S=\frac92,
\qquad
P=3\left(\frac94\right)^2=\frac{243}{16}.
$$

Therefore

$$
S^4=\frac{6561}{16}=3^3P.
$$

The edge density is $1/2$, and the path density is $1/16=(1/2)^4$.

### 7.3 A signed symmetric example

Consider

$$
A=
\begin{pmatrix}
1&-1&2\\
-1&3&0\\
2&0&-2
\end{pmatrix}.
$$

The degree vector is

$$
d=(2,2,0)^{\mathsf T},
$$

so $S=4$ and $T=8$. The two-step vector is

$$
u=Ad=(0,4,4)^{\mathsf T},
$$

so $P=32$. With $n=3$,

$$
S^4=256,
\qquad
n^3P=864.
$$

The inequality holds with gap $608$, despite the negative entries. Also,

$$
\sum_i u_i=8=\sum_i d_i^2,
$$

which displays the central identity directly.

### 7.4 Random experiments

For numerical exploration, generate a real matrix $B$ and symmetrize it by

$$
A=\frac{B+B^{\mathsf T}}{2}.
$$

Computing the gap for many such matrices should produce values nonnegative up to floating-point roundoff. Constant matrices produce zero. Adding a random symmetric perturbation generally produces a positive gap because it destroys one or both uniformity conditions.

Such experiments illustrate the theorem but do not replace the exact argument. In floating-point arithmetic, values extremely close to zero may appear slightly negative due to rounding. A scale-aware tolerance should therefore be used in software assertions.

## 8. Applications and broader interpretation

### 8.1 Motif lower bounds

The density theorem provides an immediate lower bound on a four-edge path motif from only the average edge weight. In nonnegative network models, if the mean ordered edge weight is $p$, then the normalized $P_5$ count is at least $p^4$. This gives a baseline against which observed path abundance can be compared.

### 8.2 Signed networks

Signed networks arise when positive and negative relations coexist, as in correlation structures, alliances and antagonisms, or excitatory and inhibitory couplings. Many probabilistic motif arguments fail under cancellation. The present inequality remains valid because it is ultimately a norm inequality. The count $P$ is always nonnegative, since it is a sum of squares, although individual map weights in its expanded form may be negative.

### 8.3 Fast certification

A naive homomorphism count over five path vertices examines $n^5$ maps. The two-step representation reduces evaluation to two matrix-vector products. This enables fast certification of the bound on large dense or sparse networks and exposes the quantities responsible for slack.

### 8.4 Spectral transfer principles

The result clarifies how to test proposed equivalences between spectral and density inequalities. Before attributing a motif bound to positive semidefiniteness, one should simplify the motif count algebraically. For paths, matrix powers and squared norms can make the bound independent of spectral sign. A valid counterexample to a transfer converse must use a graph or a definition not already controlled by this elementary mechanism.

## 9. Relation to longer odd paths

The proof can be understood as the first nontrivial instance of a propagation viewpoint. The edge total is the pairing of $\mathbf 1$ with $A\mathbf 1$, while the five-vertex path count is the squared norm of $A^2\mathbf 1$. Symmetry allows powers of $A$ to move from one side of an inner product to the other. For the present path, only one intermediate energy $\|A\mathbf 1\|_2^2$ is needed, and two Cauchy–Schwarz inequalities form a complete bridge.

This viewpoint helps explain why trees and paths are resistant to proposed counterexamples. Their vertices can often be removed from the leaves inward, with convexity controlling each averaging step. Nevertheless, one should not infer from the present theorem a signed-kernel Sidorenko inequality for every tree or every bipartite graph. The sum-of-squares representation used here is especially well matched to an odd number of vertices and a unique middle vertex. More complicated branching patterns require additional multilinear estimates, while graphs with cycles introduce correlations not represented by a single propagated degree vector.

There is also a distinction between algebraic validity and probabilistic interpretation. When all entries lie in $[0,1]$, $t(H,A)$ can be read as an expected product of edge probabilities under a uniformly random vertex map. With signed entries, that interpretation disappears because individual products can be negative. The theorem nevertheless remains meaningful as a polynomial inequality on the vector space of symmetric matrices. Its strength is precisely that an inequality motivated by nonnegative graph densities extends to this larger algebraic domain.

Finally, symmetry is structurally essential to the stated proof. Without it, the two halves of $P_5$ involve different incoming and outgoing two-step vectors, and the path count becomes their inner product rather than a squared norm. The identity $\sum_i u_i=\sum_i d_i^2$ also fails when row and column sums differ. Directed analogues would therefore need separate in-degree and out-degree quantities, together with assumptions controlling their interaction.

## 10. Limitations and future work

The theorem concerns finite symmetric real kernels and the standard homomorphism-density normalization. It does not by itself classify equality cases beyond the sufficient uniformity conditions visible in the two Cauchy–Schwarz steps. A complete equality classification could examine all symmetric matrices for which both $A\mathbf 1$ and $A^2\mathbf 1$ are constant.

A quantitative stability theorem is another natural direction. The exact gap decomposition shows that a small gap forces small degree variance and small two-step variance after appropriate normalization, except in regimes where the total edge weight is near zero. This could be developed into robust statements measuring distance from the set of equality configurations.

The finite argument also suggests extensions to measurable symmetric kernels. In an integral setting, degrees become functions,

$$
d(x)=\int W(x,y)\,dy,
$$

and two-step weights become

$$
u(x)=\int W(x,y)d(y)\,dy.
$$

Fubini’s theorem and Cauchy–Schwarz should reproduce the same chain under suitable integrability assumptions. Careful hypotheses are needed when kernels are signed or unbounded.

Finally, the originally contemplated $P_5$ separation cannot occur with the standard homomorphism-density definition: every finite symmetric real kernel satisfies

$$
t(P_5,W)\ge t(K_2,W)^4,
$$

without entrywise nonnegativity or positive semidefiniteness. The proof is the two-step Cauchy–Schwarz chain

$$
\left(\sum_i d_i\right)^2\le n\sum_i d_i^2,
\qquad
\left(\sum_i d_i^2\right)^2\le n\sum_i(Wd)_i^2.
$$

Constant kernels attain equality, so the normalization is sharp. A meaningful continuation is to identify the intended nonstandard spectral inequality and admissible class, or to replace $P_5$ by a bipartite graph not already covered by the tree case of Sidorenko’s inequality. One can then formulate the precise transfer statement and test whether its converse fails outside the stated vertex-to-edge range.

## 11. Conclusion

For the five-vertex path, a potentially spectral question has an elementary and stronger answer. Every finite symmetric real weighted network obeys the sharp inequality

$$
S^4\le n^3\operatorname{hom}(P_5,A),
$$

or equivalently

$$
t(P_5,A)\ge t(K_2,A)^4.
$$

The proof consists of an exact two-step identity followed by two applications of Cauchy–Schwarz. Constant kernels attain equality. Doubly nonnegative kernels therefore cannot provide a counterexample, nor can any admissible class made entirely of symmetric kernels. The result both settles the proposed test case and provides a practical lesson: in network-density problems, the geometry of path counts should be exhausted before stronger spectral hypotheses are invoked.