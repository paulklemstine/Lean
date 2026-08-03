# Exact Spectral Projections for a Recursively Signed Boolean Hypercube

**Aristotle**  
**August 3, 2026**

## Abstract

We study a canonical signed adjacency operator on the Boolean hypercube. Writing the $(n+1)$-dimensional operator recursively as

$$
A_{n+1}=\begin{pmatrix}A_n&I\\ I&-A_n\end{pmatrix},
$$

we obtain the exact scalar-square identity $A_n^2=nI$. For any nonzero real $r$ with $r^2=n$, we define

$$
P_+=\frac12(I+r^{-1}A_n),
\qquad
P_-=\frac12(I-r^{-1}A_n).
$$

We prove that these operators reconstruct every real-valued function on the cube, map it respectively to the $r$- and $-r$-eigenspaces, are idempotent, and have vanishing mixed composites. Consequently the function space is the direct sum of the two eigenspaces and the signed operator has no real eigenvalues other than $\pm\sqrt n$. We give a sparse projection algorithm requiring $O(n2^n)$ arithmetic operations, numerical examples, and an unsigned two-dimensional counterexample showing that scalar-square behavior is not shared by arbitrary signings. The results isolate the operator-algebraic mechanism underlying spectral approaches to Boolean-cube sensitivity and point toward multiplicity, face-cancellation, switching, and restriction theorems.

## 1. Introduction

The Boolean hypercube $Q_n$ is the graph whose vertex set is $\{0,1\}^n$ and whose edges join bit strings differing in exactly one coordinate. It simultaneously represents subsets of an $n$-element set, inputs to Boolean functions, binary configurations, and vertices of an $n$-dimensional cube. Although it has $2^n$ vertices, its product structure makes recursive arguments natural.

The ordinary adjacency operator sums a function over neighboring vertices. Signed adjacency modifies each edge contribution by a coefficient in $\{-1,1\}$. This apparently modest change can radically alter the spectrum. With a coherent recursive signing, two-step contributions through distinct coordinates cancel, producing the exact identity $A_n^2=nI$. This identity is the algebraic core of a spectral method associated with sensitivity questions for Boolean functions.

The present work develops the consequences of that identity at the level of explicit spectral projections. Rather than invoke a general diagonalization theorem, we construct the two components of every signal directly from the signal and one operator application. For a square root $r$ of $n$, these components are

$$
P_+f=\frac12(f+r^{-1}A_nf),
\qquad
P_-f=\frac12(f-r^{-1}A_nf).
$$

The formulas provide reconstruction, eigenvalue identities, idempotence, and mutual annihilation. They are useful both conceptually and computationally: the decomposition can be evaluated using sparse neighbor sums without computing eigenvectors.

We also distinguish the canonical construction from arbitrary edge signings. The unsigned square gives a direct counterexample to the claim that every signing has scalar square. Thus the mechanism is not “signing” by itself, but cancellation imposed by a structured sign pattern.

## 2. The Boolean cube and its function space

### 2.1. Vertices and neighbors

For $n\ge0$, define

$$
Q_n=\{0,1\}^n.
$$

The set $Q_0$ contains one empty word. If $x=(x_1,\ldots,x_n)\in Q_n$ and $1\le j\le n$, let $x\oplus e_j$ denote the word obtained by flipping coordinate $j$. The graph $Q_n$ has an edge between $x$ and $x\oplus e_j$ for every $x$ and $j$. Every vertex has degree $n$.

Let

$$
V_n=\{f:Q_n\to\mathbb R\}.
$$

Under pointwise addition and scalar multiplication, $V_n$ is a real vector space of dimension $2^n$. We use $I$ for its identity operator and $0$ for its zero operator.

### 2.2. The recursive signed adjacency operator

Every vertex of $Q_{n+1}$ can be written uniquely as $(b,x)$ with $b\in\{0,1\}$ and $x\in Q_n$. Thus a function $f\in V_{n+1}$ is identified with a pair $(f_0,f_1)\in V_n\oplus V_n$, where $f_b(x)=f(b,x)$.

**Definition 2.1 (Canonical signed cube operator).** Set $A_0=0$. Recursively define $A_{n+1}:V_{n+1}\to V_{n+1}$ by

$$
A_{n+1}(f_0,f_1)=\bigl(A_nf_0+f_1,\;f_0-A_nf_1\bigr).
$$

Relative to $V_{n+1}=V_n\oplus V_n$, this is

$$
A_{n+1}=\begin{pmatrix}A_n&I\\ I&-A_n\end{pmatrix}.
$$

Every nonzero matrix entry corresponds to a cube edge and has value $+1$ or $-1$. The off-diagonal blocks describe edges in the new coordinate. The lower-dimensional edges retain their signs in the first half and reverse their signs in the second.

**Lemma 2.2 (Linearity).** For all $f,g\in V_n$ and $c\in\mathbb R$,

$$
A_n(f+g)=A_nf+A_ng,
\qquad
A_n(cf)=cA_nf.
$$

**Proof sketch.** The claim is immediate for $n=0$. If it holds for $A_n$, apply the recursive definition separately to both components of $(f_0,f_1)+(g_0,g_1)$ and to $c(f_0,f_1)$. Distributivity in each block gives the two identities for $A_{n+1}$. Equivalently, the block matrix acts linearly. $\square$

The matrix $A_n$ is real symmetric. This follows inductively because $A_0$ is symmetric, the identity is symmetric, and the displayed block matrix is symmetric whenever $A_n$ is. Symmetry is useful for geometric interpretations, although the projection identities below require only linearity and the scalar-square relation.

## 3. Scalar-square cancellation

**Theorem 3.1 (Scalar-square identity).** For every integer $n\ge0$,

$$
A_n^2=nI.
$$

**Proof sketch.** The base case is $A_0^2=0$. Assuming $A_n^2=nI$, block multiplication gives

$$
\begin{aligned}
A_{n+1}^2
&=
\begin{pmatrix}A_n&I\\ I&-A_n\end{pmatrix}
\begin{pmatrix}A_n&I\\ I&-A_n\end{pmatrix}\\
&=
\begin{pmatrix}
A_n^2+I&A_n-A_n\\
A_n-A_n&I+A_n^2
\end{pmatrix}\\
&=
\begin{pmatrix}(n+1)I&0\\0&(n+1)I\end{pmatrix}
=(n+1)I.
\end{aligned}
$$

Induction completes the proof. $\square$

There is also a walk interpretation. An entry of $A_n^2$ is a signed sum over two-step walks. If a walk flips two distinct coordinates, reversing their order produces another walk with the same endpoints and opposite sign; the pair cancels. If the walk flips one coordinate twice, it returns to its starting point, and the product of an edge sign with itself is $1$. Each vertex has $n$ such returning walks. Hence the diagonal is $n$ and every off-diagonal entry is zero.

**Corollary 3.2 (Eigenvalue rigidity).** If $f\in V_n$ is nonzero and $A_nf=\lambda f$ for a real number $\lambda$, then

$$
\lambda^2=n.
$$

In particular, for $n>0$, every real eigenvalue is $\sqrt n$ or $-\sqrt n$.

**Proof sketch.** Applying $A_n$ to the eigenvalue equation yields $A_n^2f=\lambda^2f$. Theorem 3.1 gives $nf=\lambda^2f$. Since $f\ne0$, the scalar coefficients agree. $\square$

**Corollary 3.3 (Numerical spectral certificate).** Suppose $f\ne0$ is an eigenfunction of $A_n$ with eigenvalue $\lambda$, and suppose $|\lambda|\le s$ for some $s\ge0$. Then

$$
n\le s^2.
$$

**Proof sketch.** By Corollary 3.2, $n=\lambda^2=|\lambda|^2$. Squaring the nonnegative inequality $|\lambda|\le s$ gives $n\le s^2$. $\square$

This elementary conversion is important in applications: a combinatorial argument may bound an eigenvalue by a local parameter, while the signed construction fixes the eigenvalue magnitude at $\sqrt n$.

## 4. Explicit spectral projections

Assume henceforth that $r\in\mathbb R$ satisfies

$$
r\ne0,
\qquad
r^2=n.
$$

Such an $r$ exists precisely when $n>0$, and it may be chosen as $\sqrt n$ or $-\sqrt n$. The labels “positive” and “negative” below refer to the chosen $r$.

**Definition 4.1 (Two spectral parts).** For $f\in V_n$, define

$$
P_+f=\frac12\left(f+r^{-1}A_nf\right),
\qquad
P_-f=\frac12\left(f-r^{-1}A_nf\right).
$$

Equivalently,

$$
P_+=\frac12(I+r^{-1}A_n),
\qquad
P_-=\frac12(I-r^{-1}A_n).
$$

Both are linear by Lemma 2.2.

**Theorem 4.2 (Reconstruction).** Every $f\in V_n$ satisfies

$$
P_+f+P_-f=f.
$$

**Proof sketch.** Add the defining expressions. The terms $r^{-1}A_nf$ appear with opposite signs and cancel, leaving $(f+f)/2=f$. $\square$

**Theorem 4.3 (Positive spectral identity).** For every $f\in V_n$,

$$
A_n(P_+f)=rP_+f.
$$

**Proof sketch.** By linearity and Theorem 3.1,

$$
\begin{aligned}
A_n(P_+f)
&=\frac12\left(A_nf+r^{-1}A_n^2f\right)\\
&=\frac12\left(A_nf+r^{-1}nf\right).
\end{aligned}
$$

Since $n=r^2$ and $r\ne0$, one has $r^{-1}n=r$. Therefore

$$
A_n(P_+f)=\frac12(A_nf+rf)
=r\frac12(f+r^{-1}A_nf)=rP_+f.
$$

$\square$

**Theorem 4.4 (Negative spectral identity).** For every $f\in V_n$,

$$
A_n(P_-f)=-rP_-f.
$$

**Proof sketch.** Again using linearity and $A_n^2=nI$,

$$
A_n(P_-f)=\frac12(A_nf-r^{-1}nf)
=\frac12(A_nf-rf).
$$

On the other hand,

$$
-rP_-f=-\frac r2(f-r^{-1}A_nf)
=\frac12(A_nf-rf),
$$

which is the same expression. $\square$

Together, Theorems 4.2–4.4 give an explicit decomposition of every function into two eigenfunctions. Either component may be zero, but their sum is always the original function.

### 4.1. Idempotence and complementary behavior

**Theorem 4.5 (Idempotence).** The spectral maps satisfy

$$
P_+^2=P_+,
\qquad
P_-^2=P_-.
$$

**Proof sketch.** Let $g=P_+f$. By Theorem 4.3, $A_ng=rg$. Hence

$$
P_+g=\frac12(g+r^{-1}A_ng)
=\frac12(g+g)=g.
$$

Thus $P_+(P_+f)=P_+f$. If $h=P_-f$, Theorem 4.4 gives $A_nh=-rh$, and

$$
P_-h=\frac12(h-r^{-1}A_nh)
=\frac12(h+h)=h.
$$

$\square$

**Theorem 4.6 (Vanishing mixed composites).** The two projections annihilate one another:

$$
P_+P_-=0,
\qquad
P_-P_+=0.
$$

**Proof sketch.** Put $h=P_-f$. Since $A_nh=-rh$,

$$
P_+h=\frac12(h+r^{-1}A_nh)
=\frac12(h-h)=0.
$$

Similarly, for $g=P_+f$ one has $A_ng=rg$, so

$$
P_-g=\frac12(g-r^{-1}A_ng)
=\frac12(g-g)=0.
$$

$\square$

**Corollary 4.7 (Direct-sum decomposition).** Let

$$
E_r=\{f\in V_n:A_nf=rf\},
\qquad
E_{-r}=\{f\in V_n:A_nf=-rf\}.
$$

Then

$$
V_n=E_r\oplus E_{-r},
$$

with $P_+$ and $P_-$ the corresponding coordinate projections.

**Proof sketch.** Reconstruction places every $f$ in $E_r+E_{-r}$. If $g$ lies in both eigenspaces, then $rg=-rg$, so $2rg=0$. Since $r\ne0$, $g=0$; thus the sum is direct. Theorems 4.3–4.6 identify the two projectors. $\square$

**Corollary 4.8 (Operator reconstruction and minimal polynomial).** One has

$$
P_++P_-=I,
\qquad
P_+-P_-=r^{-1}A_n,
$$

and hence

$$
A_n=r(P_+-P_-).
$$

For $n>0$, the minimal polynomial of $A_n$ divides $X^2-n$.

**Proof sketch.** The first two identities follow by adding and subtracting Definition 4.1. The minimal-polynomial statement is another formulation of $A_n^2-nI=0$. $\square$

## 5. Why arbitrary signings do not suffice

A signed adjacency matrix of a graph assigns a sign $\pm1$ to each edge symmetrically and places zero on nonedges and on the diagonal. One might conjecture that every signing of $Q_n$ has square $nI$. This is false.

**Proposition 5.1 (Unsigned square counterexample).** Let $B$ be the ordinary, all-positive adjacency matrix of $Q_2$. Then

$$
B^2\ne2I.
$$

**Proof sketch.** Label the square cyclically. From any vertex there are two distinct length-two routes to the opposite vertex, both with positive sign. Thus the corresponding off-diagonal entry of $B^2$ is $2$, whereas every off-diagonal entry of $2I$ is zero. Explicitly, in a suitable vertex order,

$$
B=
\begin{pmatrix}
0&1&1&0\\
1&0&0&1\\
1&0&0&1\\
0&1&1&0
\end{pmatrix},
\qquad
B^2=
\begin{pmatrix}
2&0&0&2\\
0&2&2&0\\
0&2&2&0\\
2&0&0&2
\end{pmatrix}.
$$

$\square$

The canonical signed matrix in the same dimension is

$$
A_2=
\begin{pmatrix}
0&1&1&0\\
1&0&0&1\\
1&0&0&-1\\
0&1&-1&0
\end{pmatrix},
$$

and direct multiplication gives $A_2^2=2I$. The difference is the sign product around the square: it is $-1$ for the canonical signing and $+1$ for the unsigned one. In the first case the two length-two routes between opposite corners cancel; in the second they reinforce.

This suggests a general face condition: the product of edge signs around each two-dimensional face should be $-1$. Establishing that this condition is equivalent to $A^2=nI$ for symmetric $\{-1,1\}$ cube-edge signings is a natural classification problem.

## 6. A sparse projection algorithm

The formulas above lead directly to a numerical procedure. Store a function $f$ as an array indexed by integers $0,\ldots,2^n-1$, interpreted as bit strings. The recursive operator can be assembled by blocks, or applied without constructing a dense matrix.

### Algorithm 6.1 (Recursive spectral splitting)

**Input:** a dimension $n>0$ and a real array $f$ of length $2^n$.  
**Output:** arrays $f_+$ and $f_-$ satisfying $f=f_++f_-$, $A_nf_+=\sqrt n f_+$, and $A_nf_-=-\sqrt n f_-$.

1. Compute $g=A_nf$ using the recursive block rule.
2. Set $r=\sqrt n$.
3. Return

$$
f_+=\frac12(f+r^{-1}g),
\qquad
f_-=\frac12(f-r^{-1}g).
$$

If $T(n)$ denotes the cost of applying $A_n$, the block rule performs two applications of $A_{n-1}$ plus $O(2^n)$ additions, so

$$
T(n)=2T(n-1)+O(2^n)=O(n2^n).
$$

The projection stage itself costs $O(2^n)$. Memory usage is $O(2^n)$ if intermediate arrays are reused. A generic dense eigendecomposition on a $2^n\times2^n$ matrix would cost on the order of $2^{3n}$ operations and $2^{2n}$ storage, so the recursive method preserves the cube’s sparse product structure.

For numerical validation, one may compute the residuals

$$
\|f-(f_++f_-)\|_2,
\quad
\|A_nf_+-rf_+\|_2,
\quad
\|A_nf_-+rf_-\|_2,
$$

as well as idempotence and mixed-composite residuals. Floating-point values should be near machine precision.

## 7. Worked example

Take $n=2$, $r=\sqrt2$, and

$$
f=(1,2,3,4)^T.
$$

Using the matrix displayed above,

$$
A_2f=(5,5,-3,-1)^T.
$$

Therefore

$$
f_+=\frac12
\begin{pmatrix}
1+5/\sqrt2\\
2+5/\sqrt2\\
3-3/\sqrt2\\
4-1/\sqrt2
\end{pmatrix},
\qquad
f_-=\frac12
\begin{pmatrix}
1-5/\sqrt2\\
2-5/\sqrt2\\
3+3/\sqrt2\\
4+1/\sqrt2
\end{pmatrix}.
$$

Adding these vectors returns $f$. The scalar-square identity gives a short check of the eigenvalue relations:

$$
A_2f_+
=\frac12(A_2f+2f/\sqrt2)
=\sqrt2 f_+,
$$

and similarly $A_2f_-=-\sqrt2f_-$. No characteristic polynomial or eigenvector search is needed.

## 8. Applications and interpretation

### 8.1. Boolean functions and sensitivity

A Boolean function assigns a bit to each vertex of $Q_n$. Its sensitivity at a vertex counts coordinates whose flip changes the output, and its maximum sensitivity is the largest such count. Its real multilinear degree is the degree of its unique multilinear polynomial representation on binary inputs.

Spectral methods compare the density and induced-edge structure of subsets of the cube with eigenvalue bounds. The identity $A_n^2=nI$ fixes the global spectral scale at $\sqrt n$. If a restriction or induced-subgraph argument bounds a relevant eigenvalue by a local degree parameter $s$, Corollary 3.3 converts this to $n\le s^2$. Completing the full degree–sensitivity bridge additionally requires a careful induced-subgraph reduction and eigenvalue interlacing; those steps lie beyond the projection algebra established here.

### 8.2. Involutions and two-channel decompositions

Normalize the operator by setting

$$
J_n=r^{-1}A_n.
$$

Then $J_n^2=I$, so $J_n$ is an involution. The projections become

$$
P_+=\frac12(I+J_n),
\qquad
P_-=\frac12(I-J_n).
$$

This is the universal decomposition associated with an involution: one part is fixed by $J_n$, and the other changes sign. Analogous formulas separate even and odd functions under reflection, symmetric and antisymmetric tensors under coordinate exchange, and positive and negative modes of two-level observables.

### 8.3. Anticommutation and local cancellation

The recursive blocks encode a discrete anticommutation principle. Contributions associated with distinct coordinate flips cancel in the square, while same-coordinate contributions survive. This resembles the algebraic rule behind Clifford generators, where $\gamma_i\gamma_j+\gamma_j\gamma_i=0$ for $i\ne j$ and $\gamma_i^2=I$. Summing such generators yields a square equal to the number of generators. The signed hypercube realizes this principle through edge signs and square faces.

## 9. Further algebraic consequences

The projection identities permit immediate evaluation of every polynomial in the operator. Let $p\in\mathbb R[X]$. Since $A_n$ acts by $r$ on $E_r$ and by $-r$ on $E_{-r}$, one obtains the functional-calculus formula

$$
p(A_n)=p(r)P_++p(-r)P_-.
$$

Indeed, apply both sides to the decomposition $f=P_+f+P_-f$ and use the two eigenvalue identities. In particular,

$$
A_n^{2k}=n^kI,
\qquad
A_n^{2k+1}=n^kA_n
$$

for every integer $k\ge0$. Thus arbitrarily long algebraic expressions in $A_n$ collapse to a linear combination of $I$ and $A_n$.

The same formula evaluates the matrix exponential, which describes continuous-time evolution generated by $A_n$:

$$
e^{tA_n}=e^{tr}P_++e^{-tr}P_-.
$$

For oscillatory evolution generated by $iA_n$, one similarly has

$$
e^{itA_n}=e^{itr}P_++e^{-itr}P_-.
$$

These identities show that the dynamics has only two rates or frequencies, regardless of the exponentially growing state-space dimension. They follow algebraically from the finite power series reductions and do not require computing an eigenbasis.

Because $A_n$ is symmetric, the eigenspaces $E_r$ and $E_{-r}$ are orthogonal under the standard inner product

$$
\langle f,g\rangle=\sum_{x\in Q_n}f(x)g(x).
$$

To see this directly, take $f\in E_r$ and $g\in E_{-r}$. Symmetry gives

$$
r\langle f,g\rangle
=\langle A_nf,g\rangle
=\langle f,A_ng\rangle
=-r\langle f,g\rangle.
$$

Since $r\ne0$, it follows that $\langle f,g\rangle=0$. Consequently the algebraically complementary projectors are also orthogonal projections for the standard Euclidean geometry on $V_n$. In particular,

$$
\|f\|_2^2=\|P_+f\|_2^2+\|P_-f\|_2^2.
$$

This norm identity supplies another numerical diagnostic and clarifies that the decomposition separates energy without overlap.

## 10. Discussion

A notable feature of the construction is that it is basis-free after the operator has been defined. The recursive matrix supplies an economical route to the scalar-square law, but all subsequent conclusions use only two facts: linearity and $A_n^2=nI$. Thus the projection argument applies verbatim to any real vector space equipped with a linear operator $T$ satisfying $T^2=r^2I$ for a nonzero $r$. In that general setting, $(I+r^{-1}T)/2$ and $(I-r^{-1}T)/2$ are complementary projections onto the two kernels of $T-rI$ and $T+rI$. The signed cube is distinguished not by the abstract algebra, which is universal, but by the combinatorial realization of that algebra through local edge interactions.

This separation between mechanism and realization is useful. It tells us which parts of an application can be transported to another graph: once a local signing produces a scalar-square operator, the complete two-mode calculus follows automatically. The genuinely graph-specific work is therefore concentrated in finding and classifying the sign patterns that cause two-step cancellation. For the Boolean cube, square faces organize every pair of distinct coordinate moves, making a local face law a plausible complete answer.

The main results are exact and algebraic. They do not depend on approximation, asymptotic dimension, or generic spectral theory. Their hypotheses are also sharp in two respects. First, $r\ne0$ is necessary for the displayed projection formulas because they contain $r^{-1}$; dimension zero must be handled separately. Second, a coherent signing is essential, as the unsigned square demonstrates.

The decomposition gives the set of possible eigenvalues but, by itself, does not determine their multiplicities. Because $V_n$ has dimension $2^n$, the multiplicities sum to $2^n$. For $n>0$, the recursive matrices have zero diagonal and hence trace zero, strongly suggesting equal multiplicities $2^{n-1}$. Turning this observation into a full characteristic-polynomial theorem is a natural next step.

The face viewpoint may provide a more intrinsic description than recursion. The recursive definition chooses a coordinate order and a particular representative signing. A negative product around every square face appears to capture exactly the cancellation needed for the scalar-square identity. If all such signings are switching-equivalent, then the canonical operator is unique up to conjugation by a diagonal $\pm1$ matrix. Such conjugation preserves spectrum and scalar-square behavior.

## 11. Future directions

Several concrete extensions emerge.

1. **Equal eigenspace dimensions.** For every $n>0$ and nonzero $r$ with $r^2=n$, prove that the images of $P_+$ and $P_-$ each have real dimension $2^{n-1}$.

2. **Characteristic polynomial.** Representing $A_n$ as an endomorphism of $V_n$, derive

$$
\chi_{A_n}(X)=(X^2-n)^{2^{n-1}}
$$

for $n>0$.

3. **Trace cancellation under restriction.** For every nonempty proper vertex subset $S\subset Q_n$, study the principal restriction of the canonical signed adjacency matrix. Its trace is zero. The central spectral target is that $|S|>2^{n-1}$ forces a positive eigenvalue at least $1$.

4. **Face-cancellation characterization.** Prove that a symmetric $\{-1,1\}$ edge signing has adjacency square $nI$ if and only if the product of its four signs around every two-dimensional face is $-1$.

5. **Switching uniqueness.** Show that any two signings satisfying the negative face-product condition differ by vertex switching: there should be a labeling $\sigma:Q_n\to\{-1,1\}$ such that multiplying each edge sign by the product of its endpoint labels transforms one signing into the other.

6. **Boolean-function bridge.** Define pointwise sensitivity, maximum sensitivity, and real multilinear degree, and combine induced-subgraph restrictions with interlacing to obtain the full degree–sensitivity inequality from the spectral certificate.

7. **Beyond binary cubes.** Investigate products of larger alphabets and other Cayley graphs. The guiding question is which local anticommutation or face-cancellation laws force a global scalar-square identity and what local-degree bounds survive.

## 12. Conclusion

The recursively signed Boolean hypercube supports an unusually rigid operator. Its square is exactly $nI$, so its real spectrum is confined to $\pm\sqrt n$. More strongly, every function has explicit complementary components

$$
P_+f=\frac12(f+r^{-1}A_nf),
\qquad
P_-f=\frac12(f-r^{-1}A_nf),
$$

which are respectively $r$- and $-r$-eigenfunctions. The maps reconstruct the input, are idempotent, and annihilate one another. These facts turn an exponentially large spectral decomposition into one sparse operator application and elementary arithmetic.

The unsigned square shows that the phenomenon depends on coherent face cancellation, not merely on the presence of edge signs. That distinction points toward a classification theory of scalar-square signings and toward the restriction results needed in Boolean-function applications. The resulting picture is both local and global: signs arranged around small square faces force the entire $2^n$-dimensional function space to split into two exact spectral channels.