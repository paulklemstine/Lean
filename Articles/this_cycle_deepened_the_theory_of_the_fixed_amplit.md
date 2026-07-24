# When Randomness Lines Up: The Secret Geometry of One-Color Networks

Imagine a vast web of connections — cities linked by flights, neurons wired
into a brain, computers gossiping across the internet. Mathematicians love to
turn such a web into a grid of numbers called a *matrix*, and then ask a
deceptively simple question: what are its *eigenvalues*? Eigenvalues are the
hidden resonant frequencies of a network. They tell you how fast rumors spread,
whether a system is stable, how well information mixes, and where the network's
natural "modes of vibration" live. For a huge random network, the eigenvalues
usually splash across the plane like a handful of confetti, filling out a disk
or a blurry cloud. That spread is so universal it has a name — the *circular
law* — and it shows up everywhere from nuclear physics to machine learning.

This article is about a family of networks that stubbornly refuses to behave
that way. Instead of scattering their eigenvalues across a two-dimensional
cloud, they collapse the entire spectrum onto a single straight line. We call
this phenomenon **spectral line-locking**, and once you see why it happens, you
can never unsee it.

## One color for every edge

Start with an ordinary undirected graph: dots (vertices) joined by links
(edges), where a link from $i$ to $j$ is automatically also a link from $j$ to
$i$. Now add a twist. Every present edge is painted with the *same* complex
number $z$. Not a random number per edge — one shared value, a single "color,"
reused on every connection in the graph. Absent edges get a $0$.

A complex number $z = a + bi$ carries two pieces of information: a *magnitude*
$\lvert z\rvert$ (how strong the connection is) and a *phase* (which direction
it points in the plane). Painting every edge with the same $z$ means every
connection has the same strength and the same phase. We call this the
**fixed-amplitude model**, and the resulting grid of numbers is the *weighted
adjacency matrix*
$$A = z \cdot B,$$
where $B$ is the plain $0/1$ table recording which edges are present. Because
the graph is undirected, $B$ is *symmetric*: $B_{ij} = B_{ji}$. In the language
of complex matrices, $B$ is **Hermitian**, meaning it equals its own conjugate
transpose. Hermitian matrices are the complex-number cousins of symmetric
matrices, and they have a famous property: all their eigenvalues are real
numbers.

Here is the whole drama in one sentence. The matrix $B$ has real eigenvalues.
Multiplying by $z$ takes each of those real numbers and rotates-and-stretches
it by $z$. So the eigenvalues of $A = z\cdot B$ are just $z$ times real numbers
— and $z$ times a real number always lands on the same line through the origin.

## The line no eigenvalue can leave

Let us state the centerpiece precisely.

> **Spectral Line-Locking Theorem.** Let $B$ be a Hermitian matrix (the
> indicator of an undirected graph) and let $z$ be any nonzero complex number.
> Then every eigenvalue $\mu$ of the weighted matrix $A = z\cdot B$ has the form
> $\mu = z\cdot r$ for some *real* number $r$. Consequently the entire spectrum
> of $A$ lies on the one-dimensional line $\mathbb{R}\cdot z = \{\, r z : r \in
> \mathbb{R}\,\}$ passing through the origin at the angle of $z$.

The proof is short and genuinely illuminating, so here is the idea. Suppose $v$
is an eigenvector, $A v = \mu v$, with $v \neq 0$. Sandwich the equation between
$v$ and its conjugate — that is, form the *Rayleigh quotient* $\langle v, A
v\rangle$, which is just the weighted sum $\overline{v}^\top A v$. Two facts
collide:

- Because $B$ is Hermitian, the quantity $\langle v, B v\rangle$ is a **real
  number** — this is the complex version of the statement that a symmetric
  matrix's quadratic form is real. Scaling by $z$ then gives $\langle v, A
  v\rangle = z\,\langle v, B v\rangle = z\cdot(\text{real})$.
- On the other hand, plugging in $Av = \mu v$ gives $\langle v, A v\rangle =
  \mu\,\langle v, v\rangle$, and $\langle v, v\rangle = \sum_i \lvert
  v_i\rvert^2$ is a *positive real number*.

Setting the two expressions equal: $\mu\cdot(\text{positive real}) =
z\cdot(\text{real})$. Divide, and out pops $\mu = z\cdot r$ with $r$ a genuine
real number. The eigenvalue had no choice; it was pinned to the line
$\mathbb{R}\cdot z$ from the start.

What makes this satisfying is that it exposes the *exact* mechanism. All the
randomness, all the structure of the graph, lives inside the Hermitian matrix
$B$, whose spectrum is honestly real. The complex weight $z$ is a single global
knob that can only *rotate and dilate* that real spectrum. One scalar cannot
manufacture a two-dimensional cloud out of a one-dimensional line. Line-locking
is not a coincidence of small examples; it is a theorem with no exceptions.

## Global fingerprints of the weight

Because the weight $z$ factors out so cleanly, it leaves clean fingerprints on
the matrix's two most famous summary numbers.

The **trace** — the sum of the diagonal entries, equivalently the sum of all
eigenvalues — obeys
$$\operatorname{tr}(z\cdot B) = z\cdot \operatorname{tr}(B).$$
If the graph is *loopless* (no vertex connected to itself, so $B$ has a zero
diagonal), then $\operatorname{tr}(B) = 0$, and the weighted trace vanishes for
*every* weight $z$. The eigenvalues, spread along the line $\mathbb{R}\cdot z$,
always balance out to zero.

The **determinant** — the product of the eigenvalues, and the measure of how
much the matrix stretches volume — scales by the $n$-th power of the weight:
$$\det(z\cdot B) = z^{\,n}\cdot \det(B),$$
where $n$ is the number of vertices. This has a striking consequence. A matrix
is *singular* (non-invertible, collapsing space into a lower dimension) exactly
when its determinant is zero. Since $z^n \neq 0$ whenever $z \neq 0$, we get:

> **Singularity is colorblind.** For any nonzero weight $z$, the weighted matrix
> $z\cdot B$ is singular if and only if the bare $0/1$ matrix $B$ is singular.

In other words, whether the network is degenerate is a purely *combinatorial*
fact about which edges are present — the color $z$ cannot create or destroy that
degeneracy. This reduces a question about complex-weighted networks to a
classical question about zero-one matrices, whose behavior for random graphs is
well studied.

## The rebel eigenvalue: the mean direction

Line-locking says everything sits on a line, but it does not say *where* on the
line. Most eigenvalues of a large random graph huddle near the origin in a
predictable band. But one eigenvalue can break away and race off to the end of
the line. This is the **mean-direction outlier**, and the complete graph shows
it in its purest form.

The complete graph $K_n$ connects every pair of its $n$ vertices. Its indicator
$B$ has $1$s everywhere off the diagonal and $0$s on it. Feed it the *all-ones
vector* $\mathbf{1} = (1,1,\dots,1)$ — the "mean direction," pointing equally
along every axis. Each row of $B$ sums to $n-1$ (every vertex touches the other
$n-1$), so $B\,\mathbf{1} = (n-1)\,\mathbf{1}$. The all-ones vector is an
eigenvector with eigenvalue $n-1$, and after weighting:
$$(z\cdot B)\,\mathbf{1} = (n-1)\,z\cdot \mathbf{1}.$$
So $(n-1)z$ is an eigenvalue of the weighted complete graph — and, reassuringly,
it lands right on the line $\mathbb{R}\cdot z$, exactly as line-locking demands.

Why call it an outlier? Random matrix theory offers a naive first guess for how
far eigenvalues should reach: for an $n\times n$ matrix with unit-strength
entries, a natural yardstick is a radius of about $\sqrt{n}$, scaled by the
weight to $\sqrt{n}\cdot\lvert z\rvert$. The mean-direction eigenvalue blows
right past it:

> **Outlier Escape Theorem.** For every order $n \geq 3$ and every nonzero
> weight $z$, the mean-direction eigenvalue satisfies
> $$\lvert (n-1)z\rvert = (n-1)\,\lvert z\rvert \;>\; \sqrt{n}\cdot\lvert
> z\rvert.$$

The proof reduces to the elementary inequality $\sqrt{n} < n-1$ for $n \geq 3$
(square both sides: $n < n^2 - 2n + 1$, i.e. $0 < n^2 - 3n + 1$, true from
$n=3$ onward). The factor $\lvert z\rvert$ cancels, so the escape is a property
of the network's *size*, not its coloring. Whatever color you paint the edges,
the mean-direction mode always juts out beyond the bulk — a spike on the line
that no rescaling can tame.

## Why one color changes everything

Step back and the picture is elegant. In the generic random-matrix world,
eigenvalues fill a two-dimensional cloud. The fixed-amplitude model forbids
this, and the reason is a single algebraic identity: $A = z\cdot B$ with $B$
Hermitian. That factorization — one complex scalar times one Hermitian matrix —
is a straitjacket. It forces the spectrum onto a line, forces the trace to
respect the coloring linearly, forces the determinant to scale by $z^n$, and
forces singularity to be colorblind.

This also tells us exactly how to *escape* the straitjacket. If you want the
rich two-dimensional spectra of the circular law, you must break the shared
phase — let each edge carry its *own* independent complex phase, so that the
matrix can no longer be written as a scalar times a Hermitian core. The theory
here pins down the precise obstruction, which turns the search for genuinely
two-dimensional random spectra into a sharp, testable target: look only at the
models that violate the scalar–Hermitian factorization, because in the
fixed-amplitude world no such spread can ever occur.

There is a broader lesson too. Symmetry is not just aesthetic; it is
*constraining*. A network in which every connection sings the same note cannot
produce a full chord of frequencies — its music is confined to a single line in
the complex plane. Understanding that line, its rebel outlier, and the clean
arithmetic of trace and determinant gives us a complete, exact map of a corner
of the random-graph landscape that once looked like it should be a cloud, and
turned out to be a beam of light.
