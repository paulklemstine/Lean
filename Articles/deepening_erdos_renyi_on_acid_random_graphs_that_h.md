# Erdős–Rényi on Acid: The Random Graphs That Refuse to Hallucinate

Imagine building a social network by flipping a coin for every possible friendship. With $n$ people, there are about $n^2/2$ possible connections; for each one you flip a biased coin that comes up "friends" with probability $p$. What you get is the most famous object in probabilistic combinatorics — the **Erdős–Rényi random graph** $G(n,p)$. It has a magical property: as you slowly increase $p$, the network stays fragmented into little islands until, right at the threshold $p = \tfrac{\log n}{n}$, it suddenly snaps together into a single connected whole. One extra edge, and an entire society becomes reachable.

That story is about *whether* edges exist. But what if we also cared about the *character* of each connection? What if an edge could carry a phase — a direction on the clock face of the complex plane — instead of a plain yes-or-no? This is the question that sends the ordinary theory somewhere stranger. Replace the probability $p$ by a **complex number** $z$, and let every present edge carry the same weight $z = re^{i\theta}$. Now the graph doesn't just exist; it *rotates*. The natural expectation, borrowed from the celebrated **circular law** of random matrix theory, is that the "frequencies" of such a network — the eigenvalues of its connection matrix — should smear out to fill a two-dimensional disk in the complex plane, like static filling a screen. A network that hallucinates: shimmering noise in every direction.

The surprise, and the subject of this article, is that it does exactly the opposite. When every edge shares a single complex amplitude, the graph's spectrum does **not** fill a disk. It collapses. Every last frequency snaps onto a single straight line through the origin. The random graph, given the chance to hallucinate in two dimensions, stubbornly speaks in one. We call this phenomenon **spectral line-locking**, and this article explains why it happens, why it is the *sharpest possible* obstruction to disk-filling behavior, and where the door to genuine two-dimensional chaos actually lies.

## The matrix behind the graph

Every graph has a shadow: its **adjacency matrix**. Number the vertices $1, 2, \dots, n$. The adjacency matrix $A$ is the $n \times n$ grid whose entry in row $i$, column $j$ records the connection from $i$ to $j$. In the classical world that entry is $1$ if $i$ and $j$ are friends and $0$ otherwise. In our world, we weight each present edge by the complex amplitude $z$:

$$A_{ij} = \begin{cases} z & \text{if } i \text{ and } j \text{ are connected}, \\ 0 & \text{otherwise}. \end{cases}$$

The eigenvalues of $A$ — the special numbers $\lambda$ for which there is a nonzero vibration pattern $v$ with $Av = \lambda v$ — are the "resonant frequencies" of the network. They govern how signals, rumors, epidemics, and random walks spread across it. For a real symmetric adjacency matrix, these frequencies are always real numbers strung along a line. For a general complex matrix, they can be anywhere in the plane. The question is: where do *ours* live?

The key structural observation is almost embarrassingly simple, and everything flows from it. Because *every* present edge carries the *same* weight $z$, the weighted matrix $A$ is just the plain zero-one adjacency matrix $B$ — the honest, real, symmetric record of who is connected to whom — scaled uniformly by $z$:

$$A = z \cdot B.$$

All of the randomness, all of the graph structure, lives inside the real symmetric matrix $B$. The complex number $z$ is nothing more than a single dial that rotates and stretches whatever $B$ already is.

## Why the spectrum locks to a line

Here is the heart of the matter. A real symmetric matrix (and more generally any **Hermitian** matrix, one equal to its own conjugate-transpose) has a rigid, beautiful constraint: **all of its eigenvalues are real**. There is no room for imaginary parts. The reason is a two-line computation that every student of linear algebra eventually meets, dressed up here as the **Rayleigh quotient**.

Suppose $Bv = \mu v$ for some nonzero vector $v$. Sandwich $B$ between $v$ and its conjugate: look at the number $\overline{v}^{\mathsf T} B\, v$. On one hand it equals $\mu \cdot \overline{v}^{\mathsf T} v$, and $\overline{v}^{\mathsf T} v = \sum_i |v_i|^2$ is a strictly positive real number. On the other hand, because $B$ equals its own conjugate-transpose, taking the complex conjugate of the whole expression leaves it unchanged — so the number is its own conjugate, i.e. real. A real number divided by a positive real number is real, forcing $\mu$ itself to be real. There is simply nowhere for an imaginary part to hide.

> **The Reality Theorem.** *If a matrix equals its own conjugate-transpose, then every eigenvalue attached to a nonzero eigenvector is a real number.*

Now watch what the single dial $z$ does. If $B v = \mu v$ with $\mu$ real, then multiplying through by $z$ gives

$$A v = (zB) v = z\mu\, v.$$

So $v$ is *also* an eigenvector of the complex-weighted matrix $A$, but now with eigenvalue $z\mu$ — the real number $\mu$ rotated and scaled by $z$. As $\mu$ ranges over the real spectrum of $B$, the products $z\mu$ trace out exactly the set

$$\{\, z\mu : \mu \in \mathbb{R} \,\} = \mathbb{R}\cdot z,$$

the single straight line through the origin in the direction of $z$. That is spectral line-locking. Every frequency of the complex random graph lives on one line, no matter how tangled or random the underlying connections are.

The result is stated in its strongest possible form. It does not merely say that the *known* eigenvalues behave this way; it says that **any** number $\lambda$ that is an eigenvalue of $A$ at all — any $\lambda$ with a nonzero $v$ satisfying $Av = \lambda v$ — must be of the form $z\mu$ for a genuine real $\mu$.

> **The Line-Locking Theorem.** *For an undirected connection pattern and any nonzero complex amplitude $z$, every eigenvalue $\lambda$ of the weighted adjacency matrix $A = zB$ can be written $\lambda = z\mu$ for some real number $\mu$. The entire spectrum lies on the line $\mathbb{R}\cdot z$.*

This is why the circular law — the two-dimensional disk of random matrix theory — can *never* appear for this model. A disk is genuinely two-dimensional; a line is one-dimensional. The obstruction is not approximate or asymptotic. It is exact, and it holds for every single finite graph.

## The global fingerprints of the dial

Two quantities summarize a matrix without reference to any choice of coordinates: its **determinant** and its **trace**. They are the matrix's most robust fingerprints, and the single dial $z$ leaves a clean mark on each.

Because scaling an $n \times n$ matrix by $z$ scales its determinant by $z$ once for each of its $n$ rows, we get an exact multiplicative law:

$$\det(A) = z^{\,n} \cdot \det(B).$$

The determinant of the complex graph is the determinant of the plain graph, amplified by the $n$-th power of the amplitude. Meanwhile the trace — the sum of the diagonal entries — vanishes entirely whenever the graph has no self-loops, since every diagonal entry is then zero. These are not restatements of the entrywise rule $A = zB$; they are *global*, basis-independent invariants, and they confirm that the amplitude acts as a single coherent gain on the whole structure at once.

## The outlier that escapes the crowd

If the spectrum is locked to a line, is there anything left to be surprised by? Yes: *where on the line* the frequencies sit. For a typical random graph most eigenvalues huddle near the origin, but one can leap far away. Consider the **complete graph** on $n$ vertices, where everyone is connected to everyone else. The perfectly democratic vibration pattern — the all-ones vector $(1,1,\dots,1)$, in which every vertex hums in unison — is an eigenvector, and a direct count shows its eigenvalue:

$$A\,(1,\dots,1) = (n-1)\,z\,(1,\dots,1).$$

Each vertex has $n-1$ neighbors, each contributing the amplitude $z$, so the eigenvalue is $(n-1)z$. This is the **mean-direction outlier**, the loud collective mode of the whole network singing together.

How far out does it sit? A natural back-of-the-envelope radius for where the bulk of a random spectrum should live is $\sqrt{n}\,|z|$ — the scale suggested by matching the total energy of the matrix. The outlier blows past it. A short inequality shows that for every order $n \ge 3$,

$$\big|(n-1)z\big| > \sqrt{n}\,|z|,$$

because $(n-1)^2 > n$ once $n \ge 3$. The collective mode escapes the heuristic disk decisively. And the threshold is sharp: at $n = 2$ the eigenvalue $z$ sits *inside* the radius $\sqrt{2}\,|z|$, so the phenomenon genuinely begins at $n = 3$. The famous four-vertex example that first hinted at this behavior turns out to be representative, not a small-number coincidence.

## What it means, and where the hallucinations really live

The moral is precise and, once seen, inevitable. **A single shared amplitude can only rotate and stretch a picture that is already one-dimensional.** All of the graph's randomness is trapped inside one real symmetric matrix, whose eigenvalues are condemned to be real; the complex dial then rigidly turns that real line to a slanted one. No amount of randomness in *which* edges appear can break this, because randomness in the edges only reshuffles the real matrix $B$ — it never touches the reality of its eigenvalues.

So if you truly want a random graph that hallucinates — whose spectrum blooms into a full two-dimensional disk in the spirit of the circular law — you must break the one thing holding the line together: the shared phase. Let each edge carry its *own* independent complex phase, or let connections point in a direction ($i \to j$ different from $j \to i$), and the clean factorization $A = zB$ shatters. Only then can the eigenvalues wander off the line and fill the plane. The line-locking theorem is thus more than a curiosity: by pinning down *exactly* what forces one-dimensionality, it tells future explorers precisely where the two-dimensional chaos must be hiding — not in the amplitude, but in the phases.

There is a pleasing echo here of the original Erdős–Rényi drama. That theory found a sharp threshold separating fragmentation from connection. This one finds a sharp dichotomy separating one-dimensional order from two-dimensional chaos — and locates the switch. Randomness, it turns out, is not automatically disorder. Give a random graph a single shared voice, and no matter how wildly its connections flicker, it will always sing on one note.
