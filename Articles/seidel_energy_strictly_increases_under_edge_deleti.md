# The Sound of a Missing Edge: How Deleting One Connection Makes a Network "Louder"

Imagine a vast social network — thousands of people, each pair either friends or
strangers. Now imagine you could *listen* to this network: assign it a single
number that captures how its structure "vibrates." Remove a single friendship,
and the network's tone changes. Does it get louder or quieter? The surprising
answer, for a beautifully symmetric family of networks, is that it always gets
*louder* — and proving this turns out to require a delicate, almost musical
argument about hidden harmonics.

This article tells the story of **Seidel energy**, a number attached to any
network, and a striking phenomenon: for the most balanced networks of all — the
**Turán graphs** — deleting any single edge strictly *increases* this energy.

## Networks as matrices

Mathematicians study a network — a *graph* — by encoding it as a grid of
numbers, a *matrix*. Suppose our network has $n$ people, labelled
$1, 2, \dots, n$. The classical way to record who knows whom is the *adjacency
matrix*: put a $1$ in row $i$, column $j$ if persons $i$ and $j$ are friends, and
a $0$ otherwise.

But there is a more symmetric bookkeeping scheme, introduced by the Dutch
mathematician J. J. Seidel, that treats friendship and non-friendship as equal
and opposite. The **Seidel matrix** $S$ of a graph is defined by three simple
rules:

$$
S_{ij} = \begin{cases}
\;\;0 & \text{if } i = j \quad (\text{nobody is their own friend}),\\
-1 & \text{if } i \text{ and } j \text{ are friends},\\
+1 & \text{if } i \text{ and } j \text{ are strangers}.
\end{cases}
$$

Every off-diagonal entry is either $+1$ or $-1$; the diagonal is all zeros. In
one clean formula, $S = J - I - 2A$, where $J$ is the all-ones matrix, $I$ is the
identity, and $A$ is the ordinary adjacency matrix. The choice of $\pm 1$ rather
than $0/1$ is not cosmetic: it makes the matrix reflect a graph's *symmetries* in
a way the adjacency matrix cannot, and it is the entry point to the elegant
theory of **two-graphs** and **switching classes**.

## From matrix to music: eigenvalues and energy

A symmetric matrix like $S$ has a spectrum: a list of $n$ real numbers
$\lambda_1, \lambda_2, \dots, \lambda_n$ called its **eigenvalues**. Think of
them as the natural frequencies at which the network "resonates." They are the
network's fingerprint.

The **Seidel energy** of the graph is the sum of the *sizes* of these
frequencies, ignoring whether they are positive or negative:

$$
E_S(G) = |\lambda_1| + |\lambda_2| + \cdots + |\lambda_n| = \sum_{i=1}^{n} |\lambda_i|.
$$

The name "energy" is borrowed from chemistry: for ordinary adjacency matrices,
this quantity approximates the total $\pi$-electron energy of a molecule, a link
discovered in the 1970s that turned a piece of pure graph theory into a tool used
by theoretical chemists. Seidel energy is its more symmetric cousin.

## Two facts that never change

Here is where the story gets subtle. Two features of the Seidel spectrum are
completely rigid — they do not depend on the graph at all, only on the number of
vertices $n$.

**First fact: the frequencies always balance.** The sum of all eigenvalues
equals the *trace* of the matrix — the sum of its diagonal entries. Since the
Seidel matrix has an all-zero diagonal,

$$
\lambda_1 + \lambda_2 + \cdots + \lambda_n = \operatorname{tr}(S) = 0.
$$

Every network's frequencies sum to zero: for every positive resonance there is a
matching negative one.

**Second fact: the total "loudness squared" is fixed.** Consider the sum of the
*squares* of the eigenvalues. A short computation shows this equals the trace of
$S^2$, and because every off-diagonal entry of $S$ is $\pm 1$ (so its square is
exactly $1$), each diagonal entry of $S^2$ counts the $n-1$ other vertices.
Hence, for *every* graph on $n$ vertices,

$$
\lambda_1^2 + \lambda_2^2 + \cdots + \lambda_n^2 = \operatorname{tr}(S^2) = n(n-1).
$$

This is remarkable. Whatever the network — dense or sparse, clustered or
scattered — its Seidel eigenvalues always lie on the same sphere of radius
$\sqrt{n(n-1)}$ in $n$-dimensional space. The first two "moments" of the spectrum
are graph-blind.

## A universal floor for energy

These two rigid facts already yield a beautiful consequence. By the
Cauchy–Schwarz inequality — the same principle that says a fixed amount of area
is spread most economically by a circle — the sum of absolute values is smallest
when it is *concentrated* and largest when it is *spread out*. Concretely,

$$
E_S(G)^2 = \Big(\sum_i |\lambda_i|\Big)^2 \;\ge\; \sum_i \lambda_i^2 = n(n-1),
$$

so **every** network on $n$ vertices satisfies the universal lower bound

$$
E_S(G) \;\ge\; \sqrt{n(n-1)}.
$$

No network can be quieter than this floor. The graphs that come closest — the
ones that press their energy right down against $\sqrt{n(n-1)}$ — are the
so-called *conference graphs*, whose spectra are as concentrated as possible: two
sharp frequencies at $\pm\sqrt{n-1}$.

## The invisible-perturbation problem

Now we can appreciate the real difficulty. Suppose we take a graph and delete a
single edge — we turn one friendship into a mutual stranger-hood. In the Seidel
matrix, this flips exactly two symmetric entries from $-1$ to $+1$.

How does that affect the energy? Here is the trap: deleting an edge changes
*neither* of the two rigid facts. The trace is still zero (the diagonal is
untouched), and the sum of squared eigenvalues is still $n(n-1)$ (each
off-diagonal entry is still $\pm 1$). **The first two spectral moments are
completely blind to edge deletion.** The eigenvalues just shuffle around on the
same fixed sphere.

So any change in energy must come from *higher harmonics* — from how the edge
deletion redistributes eigenvalue mass across zero, a subtlety the sphere
constraint simply cannot detect. This is exactly why the problem is hard, and why
a naive "count the moments" argument is doomed.

## Turán graphs: perfect balance

The main event concerns the most egalitarian networks imaginable. A **Turán
graph** $T(n, r)$ is built by splitting $n$ people into $r$ groups as equally as
possible, declaring everyone in *different* groups to be friends, and everyone in
the *same* group to be strangers. These are the "complete multipartite" graphs —
the densest graphs that avoid a clique of size $r+1$, and the extremal objects at
the heart of Turán's celebrated theorem in extremal graph theory.

The central result is a clean, definitive statement about these perfectly
balanced networks:

> **Edge-deletion theorem.** For every Turán graph $T(n, r)$ with $r \ge 4$ and
> $n \ge 4r$, and for every edge $e$ of $T(n, r)$, deleting $e$ *strictly
> increases* the Seidel energy:
> $$ E_S\big(T(n, r) - e\big) > E_S\big(T(n, r)\big). $$

Deleting any edge from a large, balanced Turán graph always makes it "louder."
This resolves a question raised by Tian and collaborators about how Seidel energy
responds to local surgery. The mechanism, hidden from the first two moments, is
this: the rank-two, trace-preserving perturbation of flipping two entries pushes
a controlled amount of eigenvalue mass away from zero, and — because the total
squared mass is pinned to the sphere — the only way the spectrum can respond is by
*spreading*, which increases the $\ell^1$ norm that is the energy.

## Switching: the hidden symmetry

One more idea completes the picture and explains why energy is the "right"
quantity to study. There is a natural operation on graphs called **Seidel
switching**: pick a subset $X$ of the vertices, and flip the friend/stranger
status of every pair with exactly one endpoint in $X$. On the matrix side, this
is conjugation by a diagonal matrix of $\pm 1$'s — an operation that reflects some
coordinates but preserves all lengths and angles.

Because such a conjugation is an *orthogonal similarity*, it does not change the
spectrum at all. Every eigenvalue, and every eigenvector (suitably reflected),
survives intact. Consequently:

> **Switching invariance.** The entire Seidel spectrum — and therefore the
> Seidel energy — is unchanged by switching. It is an invariant of the whole
> *switching class*, not of an individual graph.

This is the reason Seidel energy belongs to the theory of two-graphs: it sees
only the switching class. Within one class, energy is minimized by the most
concentrated, conference-type spectra and increases as the spectrum spreads — a
"majorization" phenomenon that recasts energy comparison as a statement about how
mass is distributed on the fixed sphere $\sum \lambda_i^2 = n(n-1)$.

## Why it matters

At first glance this is a story about an abstract number attached to abstract
networks. But the ingredients — trace moments, Cauchy–Schwarz, orthogonal
symmetry, rank-two perturbations — are the everyday tools of spectral analysis,
the same mathematics that underlies vibration analysis in engineering, the
stability of quantum systems, dimensionality reduction in data science, and the
design of error-correcting codes (where two-graphs and conference matrices make a
famous appearance).

The deeper lesson is about the *limits of coarse invariants*. The first two
spectral moments are seductively simple and completely rigid — and completely
useless for the edge-deletion question. Real understanding lives in the finer
structure: in how a small, local change ripples through the whole spectrum while
respecting a global constraint. The fact that deleting an edge from a balanced
network always raises its Seidel energy is a small, sharp window into that finer
structure — a reminder that even when the obvious measurements say "nothing
changed," the music has, in fact, grown louder.
