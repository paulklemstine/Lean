# The Halfway Point: How a Tiny Triangle Reveals a Percolation Threshold

Imagine rain falling on an enormous mosaic. Each tile independently becomes wet with probability $p$ and stays dry with probability $1-p$. At first, wet islands are small and isolated. As $p$ rises, they grow, merge, and eventually form routes across the mosaic. Somewhere between almost surely dry and almost surely wet, local accidents become global connectivity.

This is **percolation**, the mathematics of connectedness emerging from randomness. It models liquid moving through porous rock, current passing through disordered composites, disease spreading through contact networks, and fire finding paths through a landscape. Its central number is a critical probability $p_c$: below it, long-range connection is absent; above it, a macroscopic or infinite connected cluster appears.

The seductive question is whether $p_c$ has a simple exact form. Sometimes symmetry answers beautifully. Sometimes it does not. A single triangular face gives a compact lesson in both the power and the limits of that symmetry.

## Two ways to randomize a network

There are two standard percolation models. In **site percolation**, the vertices of a lattice are independently open or closed. A path may travel through open vertices. In **bond percolation**, all vertices remain available but the edges between them are independently open or closed. A path may use open edges.

These models are related, but they are not interchangeable. They have different random objects and generally different critical probabilities. Even if two tiny motifs happen to produce the same polynomial, that does not identify their behavior on an infinite lattice.

Now focus on one triangle. For the site model, call the face locally crossing when at least two of its three sites are open. This event has four successful configurations: all three sites open, or exactly one of the three closed.

The all-open configuration has probability $p^3$. Each configuration with exactly two open sites has probability $p^2(1-p)$, and there are three choices for the closed site. Therefore the local crossing probability is

$$
C(p)=p^3+3p^2(1-p)=3p^2-2p^3.
$$

This cubic is the protagonist of our story.

## A perfect complement

Replace every open site by a closed site and every closed site by an open one. The parameter $p$ becomes $1-p$. On three sites, “at least two are open” becomes the complement of “at least two are open” before the swap: a strict majority cannot be tied. Algebra records this exact duality:

$$
C(1-p)=1-C(p).
$$

The identity is more than a pleasing graph symmetry. At the midpoint $p=1/2$, complementation changes nothing, so

$$
C(1/2)=1-C(1/2),
$$

and hence

$$
C(1/2)=1/2.
$$

At density one half, the local crossing event is exactly fair.

Could another value of $p$ also make it fair? On the physical interval $0\le p\le1$, the answer is no. Subtracting one half and factoring gives

$$
C(p)-\frac12=(2p-1)\left(p(1-p)+\frac12\right).
$$

The second factor is strictly positive throughout $[0,1]$. Thus the sign of $C(p)-1/2$ is exactly the sign of $2p-1$. Consequently,

$$
C(p)<\frac12 \quad\text{if }p<\frac12,
$$

$$
C(p)=\frac12 \quad\text{if }p=\frac12,
$$

and

$$
C(p)>\frac12 \quad\text{if }p>\frac12.
$$

This is the **Local Triangular Self-Duality Theorem**: among Bernoulli parameters in $[0,1]$, the unique parameter at which a three-site triangular face crosses with probability one half is $p=1/2$. The same formulas also show $0\le C(p)\le1$, as a probability should.

## The surprising bond coincidence

Take the same triangular shape but randomize its three edges instead of its vertices. Ask whether all three vertices belong to one connected component. Two open edges suffice, and three open edges also suffice. The probability is therefore

$$
B(p)=3p^2(1-p)+p^3.
$$

Term by term, this is the same expression as $C(p)$, so

$$
B(p)=C(p)=3p^2-2p^3.
$$

It follows that the one-face bond-spanning event is fair exactly at $p=1/2$ as well.

The equality has a simple combinatorial origin. In either experiment, success means choosing at least two objects from a set of three: sites in one case, bonds in the other. But this local equality must not be stretched into a global equivalence. Site configurations live on vertices; bond configurations live on edges. When triangular faces are glued into an infinite lattice, the overlaps and dependencies induced by geometry differ.

## What the triangle does—and does not—prove

The local theorem is one ingredient behind the exact critical probability $1/2$ for site percolation on the infinite triangular lattice. Yet the local calculation alone is not an infinite-volume theorem.

To pass from one face to an endless lattice, several bridges are required. One must define crossing events in large finite regions, relate open crossings to closed crossings in a dual or matching lattice, prove that crossing probabilities increase with $p$, control their behavior uniformly as regions grow, and connect finite crossings to the existence or absence of an infinite cluster. Sharp-threshold arguments explain why a narrow transition window becomes decisive. Compactness and limiting arguments then carry finite information to infinite volume.

This distinction matters because self-duality can identify a compelling candidate without proving it is the true critical point. A local equation says where two complementary events balance. A global threshold theorem says where connectivity changes phase. The two coincide only after geometry and probability supply the missing argument.

The warning becomes especially important for the square lattice. Square-lattice **bond** percolation has an exact critical probability of $1/2$, supported by planar duality. Square-lattice **site** percolation is a different model. Its critical probability is known accurately by numerical methods, near $0.592746$, but no accepted closed exact expression is known. An “analytic derivation” of a simple square-site constant would therefore solve an open mathematical problem, not merely repeat the triangular calculation.

The honest mathematical outcome is sharper than a fabricated formula: the triangle yields an exact local theorem, while the square-site question remains open.

## Threshold tools beyond geometry

Percolation belongs to a wider family of random-structure thresholds. The same logic appears in random graphs. Suppose there are $N$ possible edges, each included independently with probability $p$. A configuration containing $k$ edges has probability

$$
p^k(1-p)^{N-k}.
$$

Summing over all configurations gives $1$ by the binomial theorem. If $T$ is any fixed set of edges, independence gives

$$
\Pr(T\text{ is present})=p^{|T|}.
$$

This tiny identity powers two general methods.

First is the **union bound**. For any finite family of events $E_i$,

$$
\Pr\left(\bigcup_i E_i\right)\le\sum_i\Pr(E_i).
$$

If $\mathcal T$ is a family of target edge patterns, the chance that at least one appears is at most

$$
\sum_{T\in\mathcal T}p^{|T|}.
$$

Equivalently, if $X$ counts the number of appearing patterns, then linearity of expectation gives

$$
\mathbb E[X]=\sum_{T\in\mathcal T}p^{|T|}.
$$

When this expectation tends to zero in a growing sequence of systems, the probability that any pattern appears also tends to zero. This is the **first-moment method**: scarcity in expectation forces absence with high probability.

The **second-moment method** works in the opposite direction. For a random variable $X$ with nonzero mean,

$$
\Pr(X=0)\le \frac{\operatorname{Var}(X)}{\mathbb E[X]^2}.
$$

If $\mathbb E[X]\to\infty$ while $\operatorname{Var}(X)\le K\mathbb E[X]$ for a fixed constant $K$, then

$$
\Pr(X=0)\le\frac{K}{\mathbb E[X]}\longrightarrow0.
$$

Thus the counted structure appears with high probability. The first moment proves that an object is too rare to exist; the second moment proves that a plentiful expected count is not destroyed by excessive fluctuation.

These methods illuminate why threshold phenomena are so widespread. Below a critical scale, a union bound can eliminate all possible witnesses. Above it, expectation grows and variance control forces witnesses to exist. Geometry determines what the witnesses mean; probability determines when they become unavoidable.

## From porous stone to conformal shapes

At criticality, two-dimensional percolation displays another remarkable feature: large patterns forget microscopic details. Crossing probabilities in finely meshed domains are expected, and in central cases known, to approach laws invariant under conformal maps—angle-preserving deformations. A disk may be bent into another simply connected shape without changing the limiting law once the marked boundary points are transported appropriately.

For critical triangular-lattice site percolation, the scaling interfaces are associated with the random curves called $\mathrm{SLE}_6$. This is far beyond the three-site cubic. A complete route requires constructing random interfaces, proving tightness and convergence as mesh size vanishes, identifying the limit, and establishing conformal covariance. Still, the local half-density symmetry is where the critical story begins.

The broader lesson is methodological. Exact answers in probability often arise from a three-part alliance: a local combinatorial identity, a global geometric duality, and an analytic limiting argument. The triangle supplies the first part with unusual clarity. Its polynomial is elementary enough to derive on a napkin, yet rich enough to mark the boundary between what symmetry gives for free and what infinite randomness demands.

## A practical way to read threshold claims

The triangle suggests a useful checklist whenever an exact threshold is proposed. First ask what has been randomized: sites, bonds, faces, or some other objects. Next ask whether the calculation concerns one motif, a finite region, or an infinite system. Then identify the symmetry: does complementation truly exchange the relevant global events, or only resemble them locally? Finally, look for the bridge from finite balance to infinite connectivity—typically a combination of planar separation, monotonicity, sharpness, and limits.

This checklist matters outside pure mathematics. In epidemiology, a household-level transmission balance need not equal a population epidemic threshold. In materials science, a conducting microcell does not guarantee a sample-spanning current. In ecology, local habitat connectivity does not by itself produce a migration corridor across a continent. Across these examples, scale is part of the theorem, not a detail to be filled in later.

At $p=1/2$, a single triangular face is balanced perfectly between crossing and not crossing. Turning that local balance into a statement about an infinite world requires much more. Knowing precisely where the easy argument ends is not a weakness. It is the map of the mathematics still to be built.
