# Erdős–Rényi on Acid: Why These Random Graphs Refuse to Hallucinate a Circle

## A seductive picture

Imagine a network in which every connection carries not merely a strength but a phase. A signal crossing an edge may be amplified, delayed, or turned through an angle in the complex plane. Such networks arise naturally whenever oscillations matter: alternating-current circuits, wave propagation, synchronized oscillators, quantum transport, and phase-aware neural systems. It is tempting to expect their spectra—the collections of characteristic frequencies encoded by their adjacency matrices—to spread across the complex plane in rich, two-dimensional clouds.

Now begin with the classical Erdős–Rényi random graph. There are $n$ vertices, and each undirected edge is independently present with a real probability $p$ between $0$ and $1$. Give every present edge the same complex amplitude $z$, while absent edges retain weight $0$. One might guess that the eigenvalues should occupy a disk of radius roughly $|z|\sqrt n$, perhaps resembling the circular law for matrices with independent entries.

That guess is vivid, plausible—and wrong.

The obstruction is not asymptotic, subtle, or statistical. It is exact for every graph of every finite size. The weighted adjacency matrix is simply a complex number times a real symmetric matrix. A common phase rotates the entire spectrum rigidly; it does not create independent phases among the eigenvalues. Instead of filling a disk, every eigenvalue lies on one straight line through the origin.

This is a useful cautionary tale about randomness. Randomness in which edges exist is not the same thing as randomness in how complex phases are assigned. A model can look “complex-valued” while remaining spectrally one-dimensional.

## Separating probability from amplitude

A complex number should not be called a probability. Probabilities are real numbers in $[0,1]$. The coherent model therefore uses two distinct parameters:

* $p\in[0,1]$ is the probability that an undirected edge exists;
* $z\in\mathbb C$ is the amplitude attached to every edge that exists.

For a realized graph, let $B$ be its ordinary adjacency matrix: $B_{ij}=1$ when vertices $i$ and $j$ are connected and $B_{ij}=0$ otherwise. Because the graph is undirected, $B_{ij}=B_{ji}$, so $B$ is real and symmetric. The complex-weighted adjacency matrix $A_z$ has entries

$$
(A_z)_{ij}=\begin{cases}
z,&\text{if the edge }\{i,j\}\text{ is present},\\
0,&\text{otherwise}.
\end{cases}
$$

Entry by entry, this says simply

$$
A_z=zB.
$$

That identity is the whole story’s hinge.

Write $z=|z|e^{i\theta}$. Since $B$ is real symmetric, all its eigenvalues $\mu_1,\dots,\mu_n$ are real and it possesses an orthonormal basis of eigenvectors. If $Bv=\mu v$, then

$$
A_zv=zBv=z\mu v.
$$

Thus $v$ is still an eigenvector, and its new eigenvalue is $z\mu$. Every spectral point belongs to

$$
z\mathbb R=\{zt:t\in\mathbb R\},
$$

a line through the origin at angle $\theta$ (with the two rays differing by $\pi$). Multiplication by $|z|$ dilates the real spectrum; multiplication by $e^{i\theta}$ rotates it. Nothing spreads sideways.

We may call this the **Phase-Locking Theorem**: for any finite undirected graph whose present edges all receive one fixed complex amplitude $z$, the weighted spectrum is the ordinary real spectrum multiplied by $z$. If $z\ne0$, the correspondence works in reverse as well: every eigenvalue $\lambda$ of $A_z$ pulls back to the real eigenvalue $\lambda/z$ of $B$.

## Normal, but not circular

There is another exact structural result. The conjugate transpose of $A_z$ is

$$
A_z^*=\overline z B=A_{\overline z}.
$$

Consequently,

$$
A_zA_z^*=|z|^2B^2=A_z^*A_z.
$$

So $A_z$ is a **normal matrix**. Normal matrices have exceptionally stable spectral geometry: they can be diagonalized by a unitary change of basis, and for them the distance from a point to the spectrum controls the resolvent exactly.

But normality by itself does not force eigenvalues onto a line. A diagonal matrix can be normal while having diagonal entries scattered anywhere in the plane. The stronger fact here is the scalar–symmetric factorization $A_z=zB$. That factorization supplies both normality and phase locking.

This distinction explains why comparison with the Ginibre ensemble is misleading. A Ginibre matrix has independently fluctuating, non-Hermitian entries. Its lack of transpose symmetry allows eigenvalues to spread over area. In an undirected graph, however, the entries across the diagonal are tied together: $B_{ij}=B_{ji}$. Giving both entries the same fixed phase preserves that dependence. The matrix may no longer be Hermitian when $z$ is nonreal, but it remains a scalar multiple of a Hermitian matrix.

## A four-vertex warning against the naive radius

Perhaps the line could still fit inside the proposed disk of radius $|z|\sqrt n$? Not always. The complete graph on four vertices gives an immediate counterexample.

Its unweighted adjacency matrix has $0$ on the diagonal and $1$ everywhere else. The all-ones vector $\mathbf 1$ is an eigenvector because every row sums to $3$:

$$
B\mathbf 1=3\mathbf 1.
$$

After weighting,

$$
A_z\mathbf 1=3z\mathbf 1.
$$

The corresponding eigenvalue has modulus $3|z|$. Yet the proposed radius for $n=4$ is

$$
|z|\sqrt4=2|z|.
$$

For every nonzero $z$, $3|z|>2|z|$. This is the **Four-Vertex Outlier Theorem**: the complete four-vertex realization already places an eigenvalue outside the conjectured square-root disk.

The example reveals a familiar phenomenon in random-matrix theory. An uncentered adjacency matrix has a nonzero mean. In dense graphs, the all-ones direction can create an eigenvalue of order $pn$, while random fluctuations live on the smaller scale $\sqrt{np(1-p)}$. A square-root radius cannot contain a linear-scale mean outlier. Centering the matrix is therefore essential even after one repairs the symmetry problem.

## What a correct bound looks like

A disk can still provide a deterministic outer bound, but its radius must come from row sums rather than wishful analogy. Suppose a real matrix $M$ has an eigenpair $Mv=\mu v$ with $v\ne0$, and every row has absolute sum at most $R$:

$$
\sum_j |M_{ij}|\le R\qquad\text{for every }i.
$$

Choose an index where $|v_i|$ is maximal. The eigenvalue equation and triangle inequality give $|\mu|\le R$. After multiplying the matrix by $z$, the transported eigenvalue satisfies the **Scaled Row-Sum Bound**

$$
|z\mu|\le |z|R.
$$

For a simple graph, $R$ may be taken as the maximum degree $\Delta$, yielding $|\lambda|\le |z|\Delta$. This disk contains the spectrum, but it says nothing about whether the disk is filled. In the fixed-phase undirected model, the spectrum still occupies only its central line.

## Expectations rotate too

The same separation between probability and amplitude clarifies subgraph statistics. Let $S_1,\dots,S_m$ be prescribed finite edge sets. For a random graph $G$, define

$$
N(G)=\sum_{r=1}^m \mathbf 1_{\{S_r\subseteq G\}},
$$

the number of prescribed patterns whose required edges are all present. Independence gives

$$
\mathbb E[N]=\sum_{r=1}^m p^{|S_r|}.
$$

If each occurrence is assigned the common complex weight $z$, linearity of expectation yields the **Weighted Subgraph Expectation Formula**

$$
\mathbb E[zN]=z\sum_{r=1}^m p^{|S_r|}.
$$

Once again, a fixed complex amplitude only rotates and dilates a real quantity. It does not generate a two-dimensional distribution by itself.

## The experiment that tells the truth

Take $n=1000$, $p=\log(n)/n$, and $z=0.5+0.3i$. A numerical simulation should construct an undirected Bernoulli adjacency matrix $B$, form $A_z=zB$, and compute its eigenvalues. Plotting those values in the complex plane will not produce a circular cloud. Up to numerical roundoff, each eigenvalue $\lambda$ obeys

$$
\operatorname{Im}(\lambda\overline z)=0,
$$

which is an equation for the line $z\mathbb R$.

One may also compare the spectrum with the disk of radius $|z|\sqrt n$. Whether every sampled point lies inside that disk depends on the mean outlier and sparsity. At $p=\log(n)/n$, the leading uncentered eigenvalue is typically on the scale $|z|\log n$, while $|z|\sqrt n$ is larger for sufficiently large $n$; so the sample may happen to fit. But containment in one experiment is not evidence for a circular law. The decisive observation is angular: the points remain phase-locked to a line.

Centering replaces $B$ by $B-\mathbb E B$, but this difference is still real symmetric. Therefore $z(B-\mathbb E B)$ remains phase-locked. Centering removes the mean direction; it cannot undo undirected transpose symmetry.

## How to make circles possible

A genuine circular-law model needs independent non-Hermitian fluctuations. One natural repair is to direct the graph. For each ordered pair $i\ne j$, choose the edge $i\to j$ independently with probability $p$. Give a present edge amplitude $z$, subtract the mean, and divide by the fluctuation scale $|z|\sqrt{np(1-p)}$. The entries across the diagonal are no longer forced to agree, so a two-dimensional limiting spectrum becomes plausible.

Another modification keeps an undirected geometry but assigns independent phases to edges, placing conjugate values across the diagonal. That creates a Hermitian magnetic adjacency matrix. Its eigenvalues remain real, suggesting semicircular rather than circular behavior after normalization. This is not a failure of complex phases; it is a demonstration that adjoint symmetry, not the vocabulary of “complex weights,” determines spectral dimension.

The central lesson reaches beyond random graphs. In any model of phase-aware information flow, global phase and local phase disorder are profoundly different. A single common phase changes coordinates. Independent phases change interactions. The former rotates an existing picture; the latter can create interference.

The graph that was supposed to hallucinate a circle does something more instructive: it refuses. Its refusal identifies exactly which assumptions make circular spectra possible—direction, centering, and sufficiently independent fluctuations—and which merely decorate a one-dimensional spectrum with complex notation.
