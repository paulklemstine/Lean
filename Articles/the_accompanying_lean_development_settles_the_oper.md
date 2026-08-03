# Two Notes Hidden Inside a Signed Hypercube

## How a recursive pattern turns an enormous network into two exact spectral modes

A square has four corners. A cube has eight. Add another binary coordinate and the number doubles again. After $n$ binary choices, the Boolean hypercube $Q_n$ has $2^n$ vertices, each represented by a bit string $x=(x_1,\ldots,x_n)$ with $x_i\in\{0,1\}$. Two vertices are neighbors when they differ in exactly one coordinate.

This innocent graph is a universal model of discrete choice. Its vertices may encode configurations of switches, truth assignments, subsets of an $n$-element set, genotypes with two alleles at each locus, or states of a digital system. Its edges record the smallest possible change: flip one bit.

Ordinary adjacency treats every edge alike. But a carefully chosen pattern of plus and minus signs reveals a much sharper structure. The resulting operator looks complicated across exponentially many vertices, yet its square is simply multiplication by $n$. From that one equation, the entire space breaks into two complementary modes, with spectral values $\sqrt n$ and $-\sqrt n$.

The story is a lesson in mathematical design: the right signs can make unwanted interactions cancel exactly.

## Building the signed operator

Let $V_n$ be the real vector space of functions $f:Q_n\to\mathbb R$. Think of $f(x)$ as a signal attached to vertex $x$. Define a linear operator $A_n:V_n\to V_n$ recursively.

In dimension $0$, the hypercube has one vertex and $A_0$ is the zero operator. To pass from $Q_n$ to $Q_{n+1}$, separate the vertices according to their first bit. A function on $Q_{n+1}$ becomes a pair $(f_0,f_1)$ of functions on $Q_n$. Set

$$
A_{n+1}(f_0,f_1)=\bigl(A_nf_0+f_1,\;f_0-A_nf_1\bigr).
$$

Equivalently, in block-matrix form,

$$
A_{n+1}=
\begin{pmatrix}
A_n&I\\
I&-A_n
\end{pmatrix}.
$$

The off-diagonal identity blocks connect corresponding vertices in the two halves of the larger cube. The opposite signs on the two diagonal copies are the crucial twist. This is still a signed adjacency operator: every nonzero entry corresponds to an edge of the hypercube and is either $+1$ or $-1$.

The recursion immediately shows that $A_n$ is linear. For functions $f,g$ and a real scalar $c$,

$$
A_n(f+g)=A_nf+A_ng,
\qquad
A_n(cf)=cA_nf.
$$

These familiar rules are not mere bookkeeping. They make it possible to construct spectral pieces by taking algebraic combinations of $f$ and $A_nf$.

## The cancellation miracle

Square the block matrix:

$$
A_{n+1}^2=
\begin{pmatrix}
A_n&I\\
I&-A_n
\end{pmatrix}^2
=
\begin{pmatrix}
A_n^2+I&A_n-A_n\\
A_n-A_n&I+A_n^2
\end{pmatrix}.
$$

The mixed terms vanish. If $A_n^2=nI$, then

$$
A_{n+1}^2=(n+1)I.
$$

Since $A_0^2=0$, induction gives the scalar-square identity

$$
A_n^2=nI
$$

in every dimension.

This identity says that applying the signed neighbor-sum twice returns the original signal, scaled by $n$. Usually, a two-step walk on a graph spreads information among many endpoints. Here, paths that change two different coordinates arrive in cancelling pairs. Only the paths that flip a coordinate and immediately flip it back survive; there are $n$ of them.

That cancellation is local and geometric. Every pair of distinct coordinates determines a square face. The two orders of making those coordinate changes contribute opposite signs. Across every such face, the competing two-step routes cancel.

## Only two spectral notes

Suppose $f\ne0$ is an eigenfunction with real eigenvalue $\lambda$, so that $A_nf=\lambda f$. Applying $A_n$ again gives

$$
A_n^2f=\lambda^2f.
$$

But $A_n^2f=nf$, hence $(\lambda^2-n)f=0$. Since $f$ is nonzero,

$$
\lambda^2=n.
$$

Thus every real eigenvalue is one of exactly two possibilities:

$$
\lambda=\sqrt n
\quad\text{or}\quad
\lambda=-\sqrt n.
$$

An exponentially large operator has only two spectral notes. This is stronger than an estimate: it is an exact algebraic constraint.

It also gives a useful numerical certificate. If an argument independently shows that every relevant eigenvalue obeys $|\lambda|\le s$, then an eigenvalue of the signed operator satisfies $\lambda^2=n$, and therefore

$$
n\le s^2.
$$

This conversion—from a spectral bound to a combinatorial inequality—is one reason signed cube operators matter in the study of Boolean functions and local sensitivity.

## Splitting any signal into the two modes

The scalar-square identity does more than constrain eigenvalues. It provides explicit formulas for extracting the two spectral components of every signal.

Choose a nonzero real number $r$ satisfying $r^2=n$. For $f\in V_n$, define

$$
P_+f=\frac12\left(f+r^{-1}A_nf\right),
\qquad
P_-f=\frac12\left(f-r^{-1}A_nf\right).
$$

These are the positive and negative spectral projections.

The first theorem is reconstruction:

$$
P_+f+P_-f=f.
$$

The proof is visible in the formulas: the two copies of $r^{-1}A_nf$ cancel, while the two halves of $f$ add.

The second theorem identifies the modes:

$$
A_n(P_+f)=rP_+f,
\qquad
A_n(P_-f)=-rP_-f.
$$

For the positive part, linearity and $A_n^2=nI=r^2I$ give

$$
A_n(P_+f)
=\frac12\left(A_nf+r^{-1}A_n^2f\right)
=\frac12\left(A_nf+rf\right)
=rP_+f.
$$

The negative calculation is identical with the sign reversed. Therefore every signal is the sum of an $r$-eigenfunction and a $-r$-eigenfunction.

The projections behave exactly as the word “projection” promises. Applying either one twice changes nothing:

$$
P_+^2=P_+,
\qquad
P_-^2=P_-.
$$

Moreover, the two modes annihilate each other:

$$
P_+P_-=0,
\qquad
P_-P_+=0.
$$

Indeed, if $g$ satisfies $A_ng=-rg$, then

$$
P_+g=\frac12(g+r^{-1}A_ng)=\frac12(g-g)=0,
$$

and the other identity follows symmetrically. In operator language,

$$
P_++P_-=I,
\qquad
P_+-P_-=r^{-1}A_n.
$$

So the original signed adjacency operator can be recovered from the difference between its two projectors:

$$
A_n=r(P_+-P_-).
$$

## A small example

For $n=1$,

$$
A_1=
\begin{pmatrix}
0&1\\
1&0
\end{pmatrix},
$$

which swaps the values at the two endpoints of an edge. Its symmetric mode has eigenvalue $1$, and its antisymmetric mode has eigenvalue $-1$.

For $n=2$, the recursion gives

$$
A_2=
\begin{pmatrix}
0&1&1&0\\
1&0&0&1\\
1&0&0&-1\\
0&1&-1&0
\end{pmatrix}.
$$

Direct multiplication yields $A_2^2=2I$. For a signal such as $f=(1,2,3,4)^T$, the formulas with $r=\sqrt2$ produce two vectors $P_+f$ and $P_-f$. They add back to $f$; applying $A_2$ multiplies the first by $\sqrt2$ and the second by $-\sqrt2$.

This example also exposes why signs cannot be arbitrary. If all four edges of the square receive sign $+1$, ordinary adjacency has eigenvalues $2,0,0,-2$, and its square is not $2I$. The sweeping claim that every edge signing has scalar square is therefore false. The canonical recursive pattern succeeds because its signs enforce cancellation around every square face.

## Why this decomposition matters

Spectral decomposition often sounds like a global task: construct a huge matrix, compute its characteristic polynomial, and find a basis of eigenvectors. Here the decomposition is local and explicit. To separate a signal into its two modes, one only needs the signal itself and one application of the signed neighbor-sum. Since each of the $2^n$ vertices has $n$ neighbors, a direct sparse implementation costs on the order of $n2^n$ arithmetic operations, not the cubic cost associated with generic dense diagonalization.

The same mechanism appears in many guises. In quantum theory, an observable whose square is scalar has two energy levels and projectors formed from $I$ and the normalized observable. In coding and signal processing, involutions split data into even and odd parts. In Clifford algebra, anticommuting generators make cross terms disappear when a sum is squared. The signed cube packages all three ideas into a combinatorial graph.

There is also a cautionary lesson. Exact spectral identities do not come merely from placing plus and minus signs on edges. They come from coherent signs. The relevant coherence is visible on two-dimensional faces: competing routes must oppose one another. The unsigned square demonstrates the failure dramatically; the recursive signing demonstrates the cure.

## A practical way to see the split

The decomposition is not only a theorem to contemplate; it is an experiment anyone can perform. List the $2^n$ vertex values of a signal, compute the signed sum over the $n$ neighbors of each vertex, and call the resulting signal $g=A_nf$. Then form $(f+g/\sqrt n)/2$ and $(f-g/\sqrt n)/2$. Applying the same signed neighbor rule again reveals that one component reproduces itself multiplied by $\sqrt n$, while the other reproduces itself multiplied by $-\sqrt n$.

This calculation scales with the number of edges, namely $n2^{n-1}$, rather than with the square or cube of the number of vertices. The formula therefore respects the network’s geometry. It asks each vertex only about its immediate neighborhood, yet recovers a global spectral separation.

The result also offers a clean way to compress reasoning. Once the single equation $A_n^2=nI$ is known, repeated applications of $A_n$ never create genuinely new directions: every polynomial expression in $A_n$ reduces to a combination of $I$ and $A_n$. Even powers become scalar multiples of $I$, and odd powers become scalar multiples of $A_n$. The two projectors are the natural coordinates for this two-dimensional operator algebra.

## The next questions

The two-projector formula settles the algebraic decomposition, but it opens several structural problems. For positive dimension, symmetry suggests that the two eigenspaces should each have dimension $2^{n-1}$, leading to characteristic polynomial

$$
(X^2-n)^{2^{n-1}}.
$$

A trace-zero argument is the natural route to equal multiplicities.

A second direction asks for a complete classification of successful signings. The expected criterion is that the product of the four edge signs around every square face equals $-1$. One would then seek to prove that any two such signings differ only by switching: multiplying each vertex by a sign and adjusting incident edges accordingly.

A third direction returns to Boolean functions. The hypercube records all binary inputs, while edges record single-bit changes. Connecting the signed spectral certificate to induced subgraphs and eigenvalue interlacing is the bridge from this exact algebra to degree–sensitivity inequalities.

The central phenomenon, however, is already complete and striking. On a network with $2^n$ states, a recursive sign pattern forces every signal into two exact channels. The cube may grow exponentially, but spectrally it sings only two notes.