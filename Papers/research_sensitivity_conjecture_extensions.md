# Scalar-Square Signings of the Boolean Cube: Spectral Rigidity and a Sharp Counterexample

**Aristotle**  
**2 August 2026**

## Abstract

We study a recursively signed adjacency operator on the $n$-dimensional Boolean cube. Writing a signal on the $(n+1)$-cube as a pair of signals $(u,w)$ on two copies of the $n$-cube, the operator is defined by $A_0=0$ and

$$
A_{n+1}(u,w)=(A_nu+w,\;u-A_nw).
$$

Our central result is the exact scalar-square identity $A_n^2=nI$. It follows that every real eigenvalue associated with a nonzero eigenvector satisfies $\lambda^2=n$, so for positive dimension the spectrum is confined to $\{ -\sqrt n,\sqrt n\}$. Consequently, whenever a combinatorial parameter $s$ bounds the magnitude of such a certified eigenvalue, one obtains $n\le s^2$. This isolates the operator-algebraic step underlying the spectral approach to sensitivity bounds on Boolean functions. We also disprove the stronger claim that arbitrary signings have scalar square: the ordinary unsigned adjacency operator on the two-cube sends the constant signal to twice itself and therefore has square $4$ on that signal, not $2$. The proof is elementary and recursive, while its combinatorial content is cancellation of paired length-two walks across every square face. We give direct algorithms, numerical examples, implications, limitations, and a program for classifying all scalar-square signings.

## 1. Introduction

The Boolean cube $Q_n$ is the graph with vertex set $\{0,1\}^n$ in which two vertices are adjacent when they differ in exactly one coordinate. It simultaneously models binary inputs, subsets of an $n$-element set, and states of an $n$-switch system. A real signal on the cube is a function $v:\{0,1\}^n\to\mathbb R$.

For a Boolean function $f:\{0,1\}^n\to\{0,1\}$, sensitivity and polynomial degree measure two different kinds of complexity. The sensitivity at $x$ is the number of coordinates whose individual reversal changes $f(x)$, and the maximum sensitivity $s(f)$ is the maximum of this count over all inputs. The real degree $\deg(f)$ is the degree of the unique multilinear real polynomial agreeing with $f$ at all vertices. Sensitivity is local, while degree records global interaction.

A spectral strategy for relating these quantities uses a signed adjacency matrix rather than the ordinary adjacency matrix. The signs are selected so that two-step routes through distinct coordinates cancel. The resulting matrix has an exceptionally rigid square, and therefore an exceptionally rigid spectrum. The present paper develops precisely this algebraic core.

The main conclusions are as follows.

1. The canonical recursively signed operator satisfies $A_n^2=nI$ in every dimension.
2. Every eigenvalue with a nonzero real eigenvector satisfies $\lambda^2=n$.
3. If $|\lambda|\le s$ for a nonnegative integer $s$, then $n\le s^2$.
4. The corresponding statement for arbitrary edge signs is false; the all-positive signing of $Q_2$ is already a counterexample.

The third conclusion explains the relevance to sensitivity arguments. If an application constructs a spectral certificate whose eigenvalue has mandatory magnitude $\sqrt n$, but local combinatorics bounds that magnitude by $s$, then $s$ cannot be smaller than $\sqrt n$. The results here establish that numerical implication without claiming the additional induced-subgraph and polynomial arguments needed to obtain a complete theorem for every Boolean function.

## 2. The Boolean cube and signed adjacency

### 2.1. Recursive presentation of the cube

Let $Q_0$ contain one vertex. Recursively, identify

$$
Q_{n+1}=\{0\}\times Q_n\;\sqcup\;\{1\}\times Q_n.
$$

Thus $Q_{n+1}$ consists of two layers, each isomorphic to $Q_n$, with corresponding vertices connected by the edges in the new coordinate. Let $V_n=\mathbb R^{Q_n}$ be the vector space of real signals on $Q_n$. Under the layered decomposition, every element of $V_{n+1}$ is uniquely a pair $(u,w)\in V_n\oplus V_n$.

An edge signing assigns $+1$ or $-1$ to every edge. Its signed adjacency operator sends a signal to the signed sum of neighboring values. The operator considered here is specified recursively, which simultaneously defines its signs.

**Definition 2.1 (Canonical signed cube operator).** Set $A_0=0$ on $V_0$. Given $A_n$, define $A_{n+1}:V_n\oplus V_n\to V_n\oplus V_n$ by

$$
A_{n+1}(u,w)=(A_nu+w,\;u-A_nw).
$$

In block notation,

$$
A_{n+1}=
\begin{pmatrix}
A_n&I\\
I&-A_n
\end{pmatrix}.
$$

The identity blocks encode the new matching edges between layers. The lower layer uses $A_n$ and the upper layer uses its negative. The matrices are real and symmetric because $A_0$ is symmetric and the recursion preserves symmetry.

**Lemma 2.2 (Linearity).** For every $n$, signals $u,v\in V_n$, and scalar $c\in\mathbb R$,

$$
A_n(u+v)=A_nu+A_nv,
\qquad
A_n(cu)=cA_nu.
$$

**Proof sketch.** Both identities are immediate at dimension zero. At dimension $n+1$, split the signals into their two layers and substitute into the recursive definition. Addition and scalar multiplication distribute through each component. Induction supplies linearity of the occurrences of $A_n$. $\square$

### 2.2. A path interpretation

For a signed adjacency matrix $A$, the entry $(A^2)_{xy}$ is the sum, over all length-two walks $x\to z\to y$, of the product of the signs on the two traversed edges. This observation gives a geometric interpretation of the scalar-square identity.

If $x=y$ in $Q_n$, there is one two-step backtrack for each coordinate, and each sign is squared, so the total contribution is $n$. If $x$ and $y$ differ in exactly two coordinates, precisely two length-two walks connect them; they traverse opposite sides of the unique square face determined by those coordinates. The canonical signing makes their sign products opposite. If the Hamming distance between $x$ and $y$ is neither zero nor two, no two-step walk connects them. Hence cancellation on square faces is exactly what is required for $A^2$ to be diagonal.

## 3. The scalar-square identity

**Theorem 3.1 (Scalar-Square Theorem).** For every integer $n\ge 0$ and every signal $v\in V_n$,

$$
A_n(A_nv)=nv.
$$

Equivalently,

$$
A_n^2=nI_{V_n}.
$$

**Proof.** We argue by induction on $n$. For $n=0$, $A_0=0$, so $A_0^2=0=0I$.

Assume $A_n^2=nI$. For $(u,w)\in V_n\oplus V_n$, the recursive definition and linearity give

$$
\begin{aligned}
A_{n+1}^2(u,w)
&=A_{n+1}(A_nu+w,\;u-A_nw)\\
&=\bigl(A_n(A_nu+w)+u-A_nw,\\
&\qquad A_nu+w-A_n(u-A_nw)\bigr)\\
&=\bigl(A_n^2u+A_nw+u-A_nw,\\
&\qquad A_nu+w-A_nu+A_n^2w\bigr)\\
&=(A_n^2u+u,\;w+A_n^2w)\\
&=((n+1)u,(n+1)w).
\end{aligned}
$$

Thus $A_{n+1}^2=(n+1)I$, completing the induction. $\square$

The same calculation can be expressed by block multiplication:

$$
\begin{pmatrix}
A_n&I\\ I&-A_n
\end{pmatrix}^2
=
\begin{pmatrix}
A_n^2+I&A_n-A_n\\
A_n-A_n&I+A_n^2
\end{pmatrix}
=(n+1)I.
$$

The off-diagonal zero blocks are the algebraic record of the cancellation of two routes around each square face.

**Corollary 3.2 (Norm scaling).** For every $v\in V_n$,

$$
\|A_nv\|_2^2=n\|v\|_2^2.
$$

For $n>0$, the normalized operator $A_n/\sqrt n$ is an orthogonal involution.

**Proof sketch.** Symmetry gives

$$
\|A_nv\|_2^2=\langle A_nv,A_nv\rangle
=\langle v,A_n^2v\rangle=n\langle v,v\rangle.
$$

Dividing the identity $A_n^2=nI$ by $n$ proves that the normalized operator squares to $I$; symmetry then makes it orthogonal. $\square$

The norm statement is a direct consequence of the central theorem and clarifies that the operator amplifies every Euclidean signal by exactly $\sqrt n$. It does not privilege a special eigendirection.

## 4. Spectral rigidity

**Theorem 4.1 (Spectral Rigidity Theorem).** Let $v\in V_n$ be nonzero and suppose

$$
A_nv=\lambda v
$$

for some real number $\lambda$. Then

$$
\lambda^2=n.
$$

In particular, when $n>0$, $\lambda\in\{-\sqrt n,\sqrt n\}$; when $n=0$, $\lambda=0$.

**Proof.** Apply $A_n$ to the eigenvalue equation. By linearity and Theorem 3.1,

$$
nv=A_n^2v=A_n(\lambda v)=\lambda A_nv=\lambda^2v.
$$

Choose a vertex $x$ with $v(x)\ne0$. Evaluating there and canceling $v(x)$ gives $\lambda^2=n$. $\square$

This theorem is stronger than a mere bound on the spectral radius. It excludes every other eigenvalue. Since $A_n$ is a real symmetric matrix, it admits an orthonormal eigenbasis, so the complete spectrum lies at the two roots of $X^2-n$. The identity alone does not determine the multiplicities of those roots; a trace argument is a natural next step.

**Theorem 4.2 (Spectral-to-Local Bound).** Let $n,s$ be nonnegative integers. Suppose $v\in V_n$ is nonzero, $A_nv=\lambda v$, and

$$
|\lambda|\le s.
$$

Then

$$
n\le s^2.
$$

**Proof.** Theorem 4.1 gives $n=\lambda^2=|\lambda|^2$. Squaring the nonnegative inequality $|\lambda|\le s$ yields $|\lambda|^2\le s^2$, and the claim follows. $\square$

The word “local” in the title anticipates the principal application: for adjacency matrices of graphs, maximum degree can bound eigenvalue magnitude, and in sensitivity problems that degree can encode the number of locally influential coordinates. The theorem itself is deliberately stated with only the required spectral hypotheses. It applies to any source of an upper bound $s$.

## 5. The all-positive signing is a counterexample

The ordinary adjacency operator has the same layered construction but no sign reversal.

**Definition 5.1 (Unsigned cube operator).** Set $B_0=0$ and define

$$
B_{n+1}(u,w)=(B_nu+w,\;u+B_nw),
$$

or equivalently

$$
B_{n+1}=
\begin{pmatrix}
B_n&I\\
I&B_n
\end{pmatrix}.
$$

**Theorem 5.2 (Unsigned Counterexample Theorem).** It is false that every edge signing of $Q_n$ has square $nI$. In particular, for the all-positive signing of $Q_2$,

$$
B_2^2\ne2I.
$$

**Proof.** Let $\mathbf1$ be the constant signal on the four vertices of $Q_2$. Every vertex has two neighbors, so

$$
B_2\mathbf1=2\mathbf1.
$$

Applying $B_2$ once more gives

$$
B_2^2\mathbf1=4\mathbf1,
$$

which differs from $2\mathbf1$. Therefore $B_2^2\ne2I$. Since the all-positive signing is one possible signing, the universal claim fails. $\square$

A point-mass example gives the same geometric diagnosis. Let $e_x$ have value $1$ at one corner $x$ and $0$ elsewhere. In $B_2^2e_x$, the opposite corner receives contribution $2$, one from each path around the square. Thus the square has a nonzero off-diagonal entry. Under the canonical signing, those two contributions have opposite signs and sum to zero.

**Proposition 5.3 (Necessary face cancellation).** If a signed adjacency operator $C$ on $Q_n$ satisfies $C^2=nI$, then on every square face the product of its four edge signs is $-1$.

**Proof sketch.** Let $x$ and $y$ be opposite vertices of a square face. The $(x,y)$ entry of $C^2$ is the sum of the sign products along the two length-two paths between them. Because $C^2=nI$, this off-diagonal entry is zero. Each path product is $+1$ or $-1$, so they must be opposite. Their product is the product of all four edge signs around the face, which is therefore $-1$. $\square$

This proposition extracts a necessary condition from the proved scalar-square identity. Establishing the converse for arbitrary cube signings and classifying all solutions up to switching equivalence remain natural extensions.

## 6. Algorithms and numerical experiments

### 6.1. Dense recursive construction

The block recursion is a direct matrix algorithm.

**Algorithm 6.1 (Canonical signed adjacency construction).** Begin with the $1\times1$ zero matrix. At stage $k$, if $A_k$ has order $2^k$, form

$$
A_{k+1}=
\begin{pmatrix}
A_k&I_{2^k}\\
I_{2^k}&-A_k
\end{pmatrix}.
$$

After $n$ stages, return $A_n$.

The output contains $4^n$ entries, so dense storage costs $\Theta(4^n)$ memory. Filling the block matrix also costs $\Theta(4^n)$ time over the complete run. Dense multiplication to test $A_n^2=nI$ costs $O(8^n)$ with the classical cubic algorithm, though the identity should normally be checked through the recursion rather than brute force.

The unsigned matrix can be built by replacing $-A_k$ with $A_k$. For $n=2$, direct calculation gives

$$
A_2=
\begin{pmatrix}
0&1&1&0\\
1&0&0&1\\
1&0&0&-1\\
0&1&-1&0
\end{pmatrix},
\qquad
A_2^2=2I_4,
$$

up to the chosen ordering of vertices. In contrast, the ordinary square adjacency matrix is

$$
B_2=
\begin{pmatrix}
0&1&1&0\\
1&0&0&1\\
1&0&0&1\\
0&1&1&0
\end{pmatrix},
$$

and its square has entries $2$ both on the diagonal and between opposite corners.

### 6.2. Matrix-free application

For larger dimensions it is preferable to apply the operator recursively without materializing a dense matrix. Split a vector of length $2^{n+1}$ into halves $u$ and $w$, recursively compute $A_nu$ and $A_nw$, and return $(A_nu+w,u-A_nw)$.

Let $T(n)$ denote the arithmetic cost. Then

$$
T(n+1)=2T(n)+O(2^n),
$$

so $T(n)=O(n2^n)$. Storage is $O(2^n)$, apart from recursion overhead. This complexity matches the sparsity scale of the cube, which has $n2^{n-1}$ edges.

### 6.3. Experimental protocol

For dimensions small enough for dense arithmetic, the following checks illustrate the results:

1. construct $A_n$ recursively;
2. compute the maximum absolute entry of $A_n^2-nI$;
3. compute the numerical eigenvalues and compare them with $\pm\sqrt n$;
4. construct $B_2$, apply $B_2^2$ to the constant vector, and compare with $2$ times that vector;
5. inspect the off-diagonal entry of $B_2^2$ between opposite corners.

Floating-point calculations introduce roundoff in eigensolvers, whereas the entries of $A_n^2$ are integers and can also be checked with exact integer arithmetic. The experiments demonstrate the theorem; the inductive proof explains it in every dimension.

## 7. Relation to Boolean-function sensitivity

For completeness, we state the relevant Boolean-function definitions while carefully separating them from the operator result.

**Definition 7.1 (Pointwise and maximum sensitivity).** For $f:\{0,1\}^n\to\{0,1\}$ and $x\in\{0,1\}^n$, let $x^{\oplus i}$ denote $x$ with coordinate $i$ reversed. The pointwise sensitivity is

$$
s(f,x)=\bigl|\{i\in\{1,\ldots,n\}:f(x)\ne f(x^{\oplus i})\}\bigr|,
$$

and the maximum sensitivity is $s(f)=\max_x s(f,x)$.

**Definition 7.2 (Multilinear degree).** Every Boolean function has a unique multilinear polynomial $p\in\mathbb R[x_1,\ldots,x_n]$ satisfying $p(x)=f(x)$ on $\{0,1\}^n$. Its degree is denoted $\deg(f)$.

The signed-cube theorem supplies a general numerical template. If a reduction from a Boolean function produces a cube dimension $d$, a nonzero eigenvector of the canonical operator with eigenvalue $\lambda$, and a combinatorial estimate $|\lambda|\le s(f)$, then Theorem 4.2 yields

$$
d\le s(f)^2.
$$

To identify $d$ with, or bound it in terms of, $\deg(f)$ requires further work: one must construct an appropriate induced subgraph or restriction, obtain a spectral certificate there, and relate graph degree to sensitivity. Those steps are not consequences of $A_n^2=nI$ alone. The contribution developed here is the exact signed-operator identity and its spectral-to-numerical implication, which are reusable once such a bridge is available.

## 8. Discussion

The canonical signing turns the cube into a discrete anticommuting system. Each coordinate direction contributes an involutive move, while distinct directions cancel in the symmetrized product. Informally, if $\Gamma_i$ denotes the signed move in coordinate $i$, then one expects

$$
\Gamma_i^2=I,
\qquad
\Gamma_i\Gamma_j+\Gamma_j\Gamma_i=0\quad(i\ne j).
$$

Consequently,

$$
\left(\sum_{i=1}^n\Gamma_i\right)^2
=
\sum_{i=1}^n\Gamma_i^2
+
\sum_{i<j}(\Gamma_i\Gamma_j+\Gamma_j\Gamma_i)
=nI.
$$

The recursive block construction realizes this cancellation without requiring separate coordinate operators in the statement. This viewpoint connects the cube signing to Clifford-type algebra: many degrees of freedom combine into an operator whose square is scalar because cross terms anticommute.

The counterexample is equally structural. For unsigned coordinate moves, distinct directions commute rather than anticommute. Their cross terms double instead of vanish. Thus the contrast is not between two superficially different matrices; it is between constructive interference and destructive interference among two-step paths.

The exact identity has practical advantages. It determines the minimal polynomial up to a divisor of $X^2-n$, gives perfect norm scaling, and eliminates numerical uncertainty about the spectral radius. It also suggests diagnostics for proposed generalizations: inspect length-two walks, identify elementary faces, and ask whether paired routes cancel.

There is also a useful distinction between sparsity and spectral simplicity. Each vertex has only $n$ neighbors, so the operator has merely $n2^n$ nonzero matrix entries even though its ambient dimension is $2^n$. Sparsity alone does not explain the two-point spectrum: the unsigned cube is equally sparse and has many eigenvalues. What creates rigidity is the coherent global arrangement of local signs. Conversely, the scalar-square law does not make the underlying state space small; algorithms must still represent $2^n$ signal values in general. The result simplifies algebraic behavior, not the exponential cardinality of the cube. Keeping these two facts separate prevents the spectral identity from being mistaken for a general cure for high-dimensional computational cost.

## 9. Boundary cases and structural checks

Several elementary checks clarify the scope of the results. At dimension $0$, the signal space is one-dimensional but the adjacency operator is zero; both $A_0^2=0I$ and the eigenvalue conclusion $\lambda=0$ remain valid. At dimension $1$,

$$
A_1=\begin{pmatrix}0&1\\1&0\end{pmatrix},
$$

so $A_1^2=I$ and the two eigenvalues are $+1$ and $-1$. The first genuine cancellation appears at dimension $2$, because square faces first occur there. Thus the two-cube is simultaneously the smallest nontrivial success for the canonical signing and the smallest counterexample for the all-positive signing.

The nonzero-eigenvector hypothesis in Theorem 4.1 is indispensable. The equation $A_n0=\lambda0$ holds for every real $\lambda$, so no spectral conclusion can follow from the zero vector. By contrast, the integrality of $s$ in Theorem 4.2 is not conceptually essential: for any real $s\ge0$, the same proof yields $n\le s^2$. The integer formulation matches applications in which $s$ counts neighbors or sensitive coordinates.

The use of real signals is likewise natural but not uniquely necessary. The scalar-square identity is algebraic and remains meaningful over any coefficient system in which the recursion and the scalar $n$ are defined. The statement about eigenvalue magnitudes, square roots, and absolute values specifically uses the ordered real field. Over complex numbers the same equation $\lambda^2=n$ still restricts eigenvalues to the two real roots when $n>0$.

Finally, the theorem concerns the canonical operator on the whole cube. A principal restriction to a subset of vertices does not generally retain the exact square identity, because some length-two paths leave the subset. Such restrictions are nevertheless central to applications: interlacing can transfer information from the full operator to a principal submatrix even when exact cancellation is lost. This distinction explains why the full-cube identity is a foundation rather than the entire induced-subgraph argument.

## 10. Future research

Several extensions are particularly natural.

First, the spectral certificate should be connected explicitly to Boolean functions. One should define the relevant induced subgraph, relate its maximum degree to pointwise sensitivity, and show how multilinear degree controls the size or density needed for the spectral argument.

Second, scalar-square signings should be classified. Proposition 5.3 identifies negative sign product around every square face as necessary. Proving sufficiency would reduce the operator identity to a local face rule. One can then ask whether all such signings are equivalent under switching, where switching at a vertex reverses the signs of all incident edges.

Third, multiplicities deserve a direct treatment. In positive dimension, symmetry and the scalar-square identity restrict eigenvalues to $\pm\sqrt n$. A trace-zero calculation is expected to show equal multiplicities $2^{n-1}$ and hence characteristic polynomial

$$
(X^2-n)^{2^{n-1}}.
$$

Fourth, principal restrictions of $A_n$ should be studied through eigenvalue interlacing. This is the main spectral mechanism for translating density of a vertex subset into a large local degree in its induced subgraph.

Fifth, exhaustive computations in small dimensions can test proposed refinements of degree–sensitivity inequalities. Recording extremal pairs $(\deg(f),s(f))$ can eliminate false constants or lower-order corrections before attempting general proofs.

Finally, the construction invites generalization beyond binary alphabets. For products of larger state spaces and other Cayley graphs, one may search for local phase rules or anticommutation relations that force a scalar square and retain useful local-degree consequences.

## 11. Conclusion

The recursively signed Boolean-cube adjacency operator obeys the exact identity $A_n^2=nI$. The proof is a one-step block calculation repeated across dimensions, but its content is geometric: the two length-two paths across every square face carry opposite signed products and cancel. This forces every nonzero eigenvalue certificate to satisfy $\lambda^2=n$, and any bound $|\lambda|\le s$ therefore implies $n\le s^2$.

The ordinary unsigned two-cube shows that this rigidity is not automatic. Its parallel two-step paths reinforce, and its adjacency square is not scalar. The successful signing is therefore essential rather than cosmetic.

Together, the identity, spectral consequence, numerical bound, and counterexample isolate a compact algebraic core for spectral sensitivity arguments. They also point toward a broader classification problem: determine which local cancellation laws make a large combinatorial operator behave like a square root of dimension.
