# When Deleting a Connection Makes a Network Louder: The Surprising Arithmetic of Seidel Energy

## A puzzle hidden in a plus-and-minus grid

Imagine a social network split into two clubs — say, a group of $m$ mathematicians
and a group of $n$ musicians — where every mathematician knows every musician, but
no two people inside the same club have met. This is the *complete bipartite graph*
$K_{m,n}$, one of the most symmetric objects in all of combinatorics.

Now picture writing down a giant grid that records, for every pair of people,
whether they are friends. But instead of the usual "1 for friends, 0 for
strangers" bookkeeping, we use a subtler code invented by the Dutch mathematician
J. J. Seidel in the 1960s:

- put $0$ on the diagonal (nobody is their own acquaintance),
- put $-1$ where two people *are* connected,
- put $+1$ where two distinct people are *not* connected.

This grid is the **Seidel matrix** $S$. It can be written compactly as
$$S = J - I - 2A,$$
where $A$ is the ordinary adjacency matrix, $I$ is the identity, and $J$ is the
all-ones matrix. The Seidel matrix has a beautiful property: it barely notices the
difference between a graph and its "complement," which is why it shows up in the
theory of two-graphs, equiangular lines, and regular geometric configurations.

Every symmetric grid of numbers has a list of *eigenvalues* — special stretch
factors that capture the deepest geometry of the matrix. If you add up the absolute
values of all the eigenvalues, you get a single number called the **Seidel energy**:
$$\mathcal{E}(G) = \sum_i |\lambda_i|.$$
Energy-type quantities like this were originally introduced in theoretical
chemistry to estimate the total $\pi$-electron energy of a molecule, and they have
since become a favorite way to compress the "complexity" of a network into one
real number.

The question this article settles is deceptively simple:

> **If you erase a single friendship from $K_{m,n}$, does its Seidel energy go
> up?**

## The tidy spectrum of a complete bipartite graph

The first surprise is how clean the answer for the intact graph is. The Seidel
matrix of $K_{m,n}$ has a hidden one-dimensional skeleton. Assign the weight $+1$
to everyone in the first club and $-1$ to everyone in the second club, collecting
these into a vector $w$. Then a short calculation shows
$$S = w\,w^{\top} - I.$$
In words: apart from subtracting the identity, the entire Seidel matrix is just the
outer product of a single vector with itself — a **rank-one** object. Rank-one
matrices are the simplest non-trivial matrices in existence, and their spectra are
completely transparent.

Because $w$ has $m+n$ entries each equal to $\pm 1$, the dot product $w\cdot w$
equals $m+n$. The outer product $w w^{\top}$ therefore has exactly one nonzero
eigenvalue, namely $m+n$, with eigenvector $w$; every direction perpendicular to
$w$ is squashed to zero. Subtracting the identity shifts everything down by one, so
the Seidel spectrum of $K_{m,n}$ is

$$\boxed{\;m+n-1 \ \text{(once)}, \qquad -1 \ \text{(repeated } m+n-1 \text{ times)}.\;}$$

Equivalently, the characteristic polynomial factors as
$$(X+1)^{\,m+n-1}\,\bigl(X-(m+n-1)\bigr).$$
Adding up the absolute values gives the energy immediately:
$$\mathcal{E}(K_{m,n}) = (m+n-1) + (m+n-1)\cdot 1 = 2(m+n-1).$$

So the complete bipartite graph on $m+n$ vertices carries Seidel energy exactly
$2(m+n-1)$ — one of the tidiest closed forms you could hope for. For the humble
square $K_{2,2}$ (a four-cycle), this is $2\cdot 3 = 6$.

## What happens when a single edge disappears

Now delete one cross-club friendship, say between mathematician $a$ and musician
$b$. In the Seidel matrix this is a tiny edit: the two symmetric entries at
positions $(a,b)$ and $(b,a)$ flip from $-1$ to $+1$. Numerically the change is
minuscule. Spectrally, it is anything but.

The trick is to see the edited matrix as a *low-rank update* of the same $-I$
background. Writing $S'$ for the Seidel matrix after deletion, one can show
$$S' + I = U\,K\,U^{\top},$$
where $U$ is a tall matrix with only **three** columns — the weight vector $w$
together with the two indicator vectors pointing at $a$ and at $b$ — and $K$ is the
fixed $3\times 3$ core
$$K = \begin{pmatrix} 1 & 0 & 0 \\ 0 & 0 & 2 \\ 0 & 2 & 0 \end{pmatrix}.$$
So the deletion is a **rank-three** perturbation of $-I$. The classical
matrix-determinant lemma says the interesting part of the spectrum is governed
entirely by a tiny $3\times 3$ companion problem. Grinding through it (the Gram
matrix of the three columns has a clean closed form) collapses the characteristic
polynomial to

$$(X+1)^{\,m+n-3}\,(X-1)\,\bigl(X^2-(m+n-4)X-(3(m+n)-7)\bigr).$$

Let us write $N = m+n$ to keep the algebra readable. The eigenvalues are now:

- $-1$, repeated $N-3$ times (contributing $N-3$ to the energy);
- $+1$, once (contributing $1$);
- the two roots of the quadratic $X^2-(N-4)X-(3N-7)$.

The discriminant of that quadratic simplifies wonderfully:
$$(N-4)^2 + 4(3N-7) = N^2 + 4N - 12 = (N-2)(N+6).$$
Its two roots are $\tfrac{(N-4)\pm\sqrt{(N-2)(N+6)}}{2}$; one is positive and one is
negative, and their absolute values add up to exactly $\sqrt{(N-2)(N+6)}$. Summing
all contributions gives the second clean closed form of the story:

$$\boxed{\;\mathcal{E}(K_{m,n}-e) = (m+n-2) + \sqrt{(m+n-2)(m+n+6)}.\;}$$

Two combinatorial objects, two exact spectral formulas — no approximation anywhere.

## The sharp threshold

We can now answer the puzzle by comparing the two exact numbers. The energy strictly
increases exactly when
$$2(N-1) < (N-2) + \sqrt{(N-2)(N+6)},$$
which rearranges to $N < \sqrt{(N-2)(N+6)}$, i.e. $N^2 < N^2 + 4N - 12$, i.e.
$4N > 12$. The whole comparison therefore boils down to a single inequality:

$$\boxed{\;\text{deleting one edge raises the Seidel energy}\iff m+n \ge 4.\;}$$

This is the *sharp* threshold. It depends only on the **total** number of vertices,
not on how they are split between the two clubs.

## A published guess, and why it is wrong

Here is where the mathematics becomes a detective story. A previously published
conjecture predicted that the Seidel energy of $K_{m,n}$ rises under *any* single
edge deletion **precisely when both clubs have at least three members** — that is,
when $m \ge 3$ *and* $n \ge 3$. Earlier work had verified the increase under
various sufficient conditions, such as $(m,n)$ at least $(3,6)$, $(6,3)$, $(2,15)$,
$(15,2)$, or $(4,4)$, and it was natural to guess that "both parts $\ge 3$" was the
true dividing line.

The exact formulas above demolish this guess. Consider the smallest interesting
case, the square $K_{2,2}$, where each club has only two members. Here $m+n=4$, so
our threshold says the energy *must* increase. And indeed:

- **Before deletion:** $\mathcal{E}(K_{2,2}) = 2(4-1) = 6.$
- **After deletion:** $\mathcal{E}(K_{2,2}-e) = (4-2) + \sqrt{(4-2)(4+6)} = 2 + \sqrt{20} = 2 + 2\sqrt{5} \approx 6.472.$

The energy jumps from $6$ to $2+2\sqrt5$, a strict increase — even though *neither*
part reaches size three. The conjecture is false. The correct criterion is not
"both parts large" but simply "enough vertices in total," namely $m+n \ge 4$.

## Why this matters

Beyond settling one specific conjecture, the argument is a small showcase of a
recurring theme in mathematics: **a difficult analytic question dissolves once you
find the right low-rank structure.**

The Seidel energy is defined analytically — it is a sum of absolute values of
eigenvalues, quantities that in general resist exact computation. Yet for
$K_{m,n}$ the Seidel matrix is a rank-one perturbation of $-I$, and deleting an
edge nudges it only to rank three. Each time, the entire spectrum is dictated by a
matrix of size at most $3\times 3$, and the energy collapses to elementary
arithmetic and a single square root. The bridge that makes this rigorous is the
observation that the energy equals the sum of $|\text{root}|$ over the
characteristic polynomial, converting an eigenvalue computation into a
determinant computation.

This kind of exact spectral bookkeeping is not just aesthetically pleasing. Graph
energies are used as descriptors in chemistry, as measures of network robustness,
and as invariants in the study of strongly regular graphs and equiangular lines.
Knowing *exactly* how such an invariant responds to a local edit — and finding
that the response is governed by a clean, sharp arithmetic threshold — is precisely
the kind of quantitative control that makes these invariants useful.

And there is a pleasing moral: sometimes removing a connection from a network makes
its "energy" go *up*, not down. In the world of Seidel matrices, less structure can
mean more spectral spread — and the point at which this kicks in is not where
intuition first suggested, but exactly at $m+n=4$.
