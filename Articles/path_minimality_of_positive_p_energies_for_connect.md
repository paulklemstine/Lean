# The Humblest Graph: Why the Path Stores the Least Energy

Take any network you like — a web of friendships, a molecule's bonds, a map of
roads between towns. Strip away the labels and the geography, and what remains is
a *graph*: a set of dots (call them vertices) joined by lines (call them edges).
Hidden inside every such graph is a secret list of numbers, its *spectrum*, that
encodes the shape of the whole thing in a single sequence. And hidden inside that
spectrum is a notion of *energy*.

This article is about a surprisingly clean fact: among all the ways to connect
$n$ dots into a single connected piece, the plain, unbranched **path** — dots in
a line, like beads on a string — stores the *least* energy. It is the most
frugal connected shape there is. What makes the story satisfying is not just that
the statement is true, but *why* it is true: a piece of pure spectral magic turns
out to be nothing more than counting edges.

## What is the spectrum of a graph?

Every graph can be written down as a grid of $0$s and $1$s called its
**adjacency matrix** $A$. Number the vertices $1$ through $n$. Put a $1$ in row
$i$, column $j$ whenever vertices $i$ and $j$ are joined by an edge, and a $0$
otherwise. Because an edge between $i$ and $j$ is the same as an edge between $j$
and $i$, this grid is symmetric across its diagonal.

Symmetric grids of real numbers have a beautiful property, guaranteed by the
spectral theorem of linear algebra: they can be "diagonalized." Concretely, there
is a list of $n$ real numbers $\lambda_1, \lambda_2, \dots, \lambda_n$ — the
**eigenvalues** — that capture the essential action of $A$. This list is the
graph's spectrum. Two graphs that look different to the eye can share a spectrum;
two graphs that look similar can have wildly different ones. The spectrum is the
graph's fingerprint.

## From spectrum to energy

Physicists and chemists have long known that these eigenvalues behave like
energies. In the 1970s, the chemist Ivan Gutman defined the **energy** of a graph
as the sum of the absolute values of its eigenvalues, $\sum_k |\lambda_k|$, a
quantity that (for certain molecules) approximates the total energy of the
electrons buzzing around a carbon skeleton. That single idea launched a whole
industry of "graph energies."

Our story uses a close cousin. Fix an exponent $p$ and add up only the *positive*
eigenvalues, each raised to the power $p$:
$$
E_p^{+}(G) \;=\; \sum_{\lambda_k > 0} \lambda_k^{\,p}.
$$
This is the **positive $p$-energy**. When $p = 2$ it becomes
$E_2^{+}(G) = \sum_{\lambda_k > 0} \lambda_k^2$, a sum of squares of the positive
eigenvalues. The question we answer is: *among all connected graphs on $n$
vertices, which one minimizes this energy?*

## Bipartite graphs and the mirror spectrum

To make the question crisp, we focus on **bipartite** graphs: those whose
vertices split into two teams so that every edge runs between the teams, never
within one. Trees, grids, cycles of even length, honeycombs — all bipartite.
Bipartiteness leaves an unmistakable signature on the spectrum: it is perfectly
symmetric about zero. For every eigenvalue $\lambda$ in the list there sits a
partner $-\lambda$. The spectrum is a mirror image of itself.

That mirror symmetry has a delightful consequence. The positive eigenvalues and
the negative eigenvalues carry exactly the same energy. If you sum $\lambda^p$
over the positive side and sum $(-\lambda)^p$ over the negative side, you get the
same number. In symbols, writing $E_p^{-}$ for the negative-side energy,
$$
E_p^{+}(G) \;=\; E_p^{-}(G),
\qquad\text{so}\qquad
\sum_k |\lambda_k|^{\,p} \;=\; 2\, E_p^{+}(G).
$$
The full "absolute energy" is just twice the positive energy. For a bipartite
graph, the positive $p$-energy is therefore *half of a genuine norm* — the
Schatten $p$-norm of the spectrum, a standard measure of size for lists of
numbers. There is one subtle caveat worth flagging: this doubling relies on the
exponent $p$ being nonzero. At $p = 0$ a zero eigenvalue misbehaves — the
convention $0^0 = 1$ makes a single zero contribute to the absolute energy while
contributing nothing to either signed side — so the clean factor of two would
break. Paths with an odd number of vertices do have a zero eigenvalue, which is
exactly why this fine print matters. For every nonzero $p$, though, the identity
holds on the nose.

## The magic identity: energy is edges

Now comes the heart of the matter, and it is genuinely magical. Consider the sum
of the squares of *all* the eigenvalues:
$$
\sum_{i=1}^{n} \lambda_i^2.
$$
This is a spectral quantity — you seemingly need to diagonalize the matrix, find
all its eigenvalues, square them, and add. But there is a shortcut. In linear
algebra, the sum of the squares of the eigenvalues of a symmetric matrix equals
the **trace** of its square, that is, the sum of the diagonal entries of
$A \times A$. And for an adjacency matrix, that diagonal has a concrete meaning:
the $(v,v)$ entry of $A^2$ counts the number of length-two walks from a vertex
back to itself, which is exactly the **degree** of $v$ — the number of edges
touching it. Adding the degrees over all vertices double-counts every edge (each
edge has two ends), so
$$
\sum_{i=1}^{n} \lambda_i^2 \;=\; \operatorname{trace}(A^2)
\;=\; \sum_{v} \deg(v) \;=\; 2\,|E(G)|.
$$
The sum of the squares of the eigenvalues is *exactly twice the number of edges*.
No trigonometry, no computation of individual eigenvalues — a spectral quantity
collapses into a combinatorial one. This single identity is the bridge on which
everything else stands.

## Putting it together: the path wins

Everything now falls into place with almost embarrassing ease.

First, connectivity forces edges. To knit $n$ vertices into a single connected
piece you need at least $n-1$ edges — that is the minimum, achieved precisely by
the **trees**, the graphs with no redundant loops. Any spanning tree of a
connected graph already uses $n-1$ edges, so $|E(G)| \ge n-1$ for every connected
graph on $n$ vertices.

Second, the magic identity converts that edge count into energy:
$$
\sum_{i=1}^{n} \lambda_i^2 \;=\; 2\,|E(G)| \;\ge\; 2(n-1).
$$
So *every* connected graph on $n$ vertices has squared spectral energy at least
$2(n-1)$.

Third, the path $P_n$ — the simplest tree, just a line of $n$ dots — has exactly
$n-1$ edges, so it attains this bound exactly, with squared spectral energy
$2(n-1)$. The path is a minimizer.

Finally, for bipartite graphs the mirror symmetry halves everything cleanly. The
positive $2$-energy is half the total, so
$$
E_2^{+}(G) \;=\; |E(G)| \;\ge\; n-1 \;=\; E_2^{+}(P_n).
$$
**Among all connected bipartite graphs on $n$ vertices, the path minimizes the
positive $2$-energy, with the exact value $n-1$.** The humblest connected shape
is the thriftiest.

There is even a closed-form portrait of the path's spectrum to make the picture
concrete: the eigenvalues of $P_n$ are
$$
\lambda_k \;=\; 2\cos\!\left(\frac{(k+1)\pi}{n+1}\right), \qquad k = 0, 1, \dots, n-1,
$$
a fan of cosines spread evenly across the interval $(-2, 2)$. You can read the
mirror symmetry straight off this formula: replacing $k$ by $n-1-k$ flips the sign
of the cosine, so $\lambda_{n-1-k} = -\lambda_k$. Square them and add, and — after
a classical roots-of-unity cancellation of cosine sums — you land back on
$2(n-1)$, in perfect agreement with the edge count.

## Why it matters, and where it goes

At first glance this is a cute fact about one exponent, $p=2$. But it is the
*anchor* of a much larger picture. The exponent $p=2$ is special because there the
energy literally equals the edge count, and edges are easy to reason about. For
larger exponents $p \ge 2$ the same minimization is conjectured to hold — the path
should remain the frugal champion — but proving it requires a deeper tool called
*majorization*: the idea that the path's positive spectrum is, in a precise
ordering sense, the "most spread toward the middle," and that convex functions
like $t \mapsto t^p$ turn that spreading into an energy inequality via Karamata's
inequality. For strictly convex powers $p > 2$ one expects the path to be not just
*a* minimizer but the *unique* one, so that any connected graph which is not a path
is strictly more energetic.

The reframing as *half a Schatten norm* points to a second horizon. Once positive
energy is recognized as one half of a symmetric norm on the spectrum, extremal
questions become norm-optimization problems, sandwiched between the path (least
energetic) at one end and the balanced complete bipartite graph (most energetic)
at the other. And in the limit of very large $p$, the energy is dominated by the
single largest eigenvalue, so path-minimality merges with the classical fact that
the path minimizes the spectral radius among connected graphs, with
$\lambda_{\max}(P_n) = 2\cos(\pi/(n+1))$.

Why do such extremal facts matter beyond their elegance? Graph energies are used
as descriptors in chemistry, as complexity measures in network science, and as
regularizers in machine learning on graph-structured data. Knowing which shapes
sit at the extremes — the most and least energetic connected configurations —
tells us the range of behavior any real network can exhibit, and pins down the
lean, tree-like structures that sit at the bottom.

The moral is one that recurs throughout mathematics: a quantity that looks deeply
spectral, requiring the full machinery of eigenvalues, turns out to be counting
something you can see with your eyes. Squared energy is just twice the edges. And
once you know that, the fact that a line of beads is the most economical way to
connect the world becomes not a mystery, but an inevitability.
