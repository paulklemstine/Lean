# The Fingerprint an Edge Cannot Hide

## When a graph refuses to notice a change

Imagine you have a network — a social graph, a molecule, a communications
grid — and you tear out a single connection. Something changes, obviously. But
what if the most natural "energy" measurement of that network stared straight at
the missing link and reported: *nothing happened*? And what if a slightly deeper
measurement immediately caught the change red-handed, with an exact accounting of
its size and direction?

That tension — one lens that is stubbornly blind and another that is razor
sharp — is the heart of the story below. It is a story about a particular way of
turning a graph into a matrix, about the *moments* of that matrix's spectrum, and
about what those moments can and cannot see.

## Turning a graph into a matrix of signs

Take any finite simple graph: a collection of vertices, some pairs of which are
joined by edges. There are many ways to encode such a graph as a matrix. The most
famous is the adjacency matrix, which puts a $1$ where two vertices are joined and
a $0$ everywhere else. But there is a more democratic cousin, the **Seidel
matrix**, which treats "connected" and "not connected" as equal and opposite.

Given a graph on $n$ vertices, its Seidel matrix $S$ is the $n \times n$ matrix
with entries

$$
S_{ij} = \begin{cases}
\;\;0 & \text{if } i = j,\\
-1 & \text{if } i \text{ and } j \text{ are adjacent},\\
+1 & \text{if } i \neq j \text{ and they are not adjacent}.
\end{cases}
$$

So the diagonal is all zeros, and every off-diagonal entry is either $+1$ or
$-1$. It is a matrix built entirely out of signs. Because $S$ is symmetric
($S_{ij} = S_{ji}$), it has $n$ real eigenvalues $\lambda_1, \dots, \lambda_n$,
its *Seidel spectrum*. The **Seidel energy** of the graph is the total size of
that spectrum,

$$
E_S = |\lambda_1| + |\lambda_2| + \cdots + |\lambda_n|,
$$

the sum of the absolute values of the eigenvalues. Energy is a single number that
compresses the entire spectrum into one measure of "spectral spread." It is the
quantity we will interrogate.

## The moments: cheap summaries of an expensive spectrum

Computing all $n$ eigenvalues of a matrix is expensive. But there are cheap
summaries called **spectral moments**. The $k$-th moment is the sum of the
$k$-th powers of the eigenvalues, and — beautifully — it equals the trace of the
$k$-th power of the matrix, no eigenvalue computation required:

$$
\sum_i \lambda_i^{\,k} = \operatorname{tr}(S^k).
$$

The first three moments already tell a vivid story.

**First moment.** Since the diagonal of $S$ is all zeros,
$\operatorname{tr}(S) = 0$. The eigenvalues always balance around zero: whatever
mass sits on the positive side is matched on the negative side.

**Second moment.** Here is the first surprise. For *any* graph on $n$ vertices,

$$
\operatorname{tr}(S^2) = \sum_i \lambda_i^2 = n(n-1).
$$

The reason is elementary: $\operatorname{tr}(S^2)$ is the sum of the squares of
*all* the entries of $S$, and every one of the $n(n-1)$ off-diagonal entries is
$\pm 1$, whose square is $1$, no matter which graph you started with. The graph
has vanished from the answer. Every Seidel spectrum, for every graph on $n$
vertices, lives on the same sphere $\sum_i \lambda_i^2 = n(n-1)$.

This single fact has a striking consequence. By the Cauchy–Schwarz inequality,

$$
E_S = \sum_i |\lambda_i| \ge \frac{\big(\sum_i \lambda_i^2\big)^{1/2}}{1}
\cdot \text{(something)} \quad\Longrightarrow\quad E_S \ge \sqrt{n(n-1)}.
$$

More precisely, Cauchy–Schwarz applied to the vector of eigenvalues and a cleverly
chosen companion gives a **universal energy floor**: no graph on $n$ vertices can
have Seidel energy below $\sqrt{n(n-1)}$. Every graph, however sparse or dense,
sits above this line.

## The blindness

Now delete a single edge. Say vertices $a$ and $b$ were joined; cut the link.
What happens to the Seidel matrix? Only two entries move: $S_{ab}$ and $S_{ba}$
each flip from $-1$ (adjacent) to $+1$ (non-adjacent). Every other entry is
untouched.

But those two entries were $\pm 1$ before and $\pm 1$ after. Their *squares*
are unchanged. So $\operatorname{tr}(S^2) = n(n-1)$ before and after: the second
moment does not so much as twitch. The most natural spectral summary is
completely **blind to edge deletion**.

This blindness is not a flaw; it is a warning. It explains why questions about how
Seidel energy responds to adding or removing edges are genuinely delicate. The
easy invariant — the one that pins the spectrum to a sphere — simply cannot
resolve the change. If you want to see the edge, you must look at a finer lens.

## The lens that sees: the third moment

That finer lens is the third moment, $\operatorname{tr}(S^3)$. And here is the
central result of this work, stated for a general symmetric, zero-diagonal
matrix and any pair of positions.

**The edge-flip formula.** Let $M$ be any real symmetric matrix with zeros on
the diagonal. Pick two distinct positions $a \neq b$ and a weight $c$, and form
the *rank-two perturbation* $P$ that adds $c$ to the entries $M_{ab}$ and
$M_{ba}$ (and nothing else). Then the third moment changes by an exact,
closed-form amount:

$$
\operatorname{tr}\big((M+P)^3\big) - \operatorname{tr}(M^3)
\;=\; 6\,c\,(M^2)_{ab}.
$$

The change depends on nothing but the weight $c$ and a *single entry* of the
squared matrix, $(M^2)_{ab} = \sum_k M_{ak} M_{kb}$. Everything else cancels. The
cancellation is not luck: the cubic expansion produces terms
$\operatorname{tr}(M^3)$, $3\operatorname{tr}(M^2 P)$,
$3\operatorname{tr}(M P^2)$, and $\operatorname{tr}(P^3)$, and the last two vanish
*precisely because $M$ has a zero diagonal*. The zero diagonal — the very feature
that made the diagonal-blind second moment constant — is what makes the third
moment's response so clean.

Now specialize to Seidel matrices. Deleting the edge $\{a,b\}$ moves those two
entries from $-1$ to $+1$, an additive change of $+2$ each — exactly the flip with
weight $c = 2$. Plugging in, the third Seidel moment changes by

$$
\operatorname{tr}(S(G-e)^3) - \operatorname{tr}(S(G)^3)
\;=\; 12\,(S^2)_{ab}.
$$

The quantity $(S^2)_{ab}$ is a purely combinatorial count — a signed tally of the
other vertices $k$ and how each relates to $a$ and to $b$. It is generically
nonzero. So while the second moment shrugs, the third moment reports the edit with
a precise magnitude and a definite sign.

## A triangle worth a thousand words

The smallest possible example makes the whole phenomenon visible at a glance. Take
the triangle $K_3$: three vertices, all pairwise joined. Its Seidel matrix has
every off-diagonal entry equal to $-1$. A direct computation gives

$$
\operatorname{tr}(S^2) = 6, \qquad \operatorname{tr}(S^3) = -6.
$$

Now delete one edge, turning the triangle into a path on three vertices, $P_3$.
Two entries flip from $-1$ to $+1$. Recompute:

$$
\operatorname{tr}(S^2) = 6 \;\;(\text{unchanged!}), \qquad
\operatorname{tr}(S^3) = +6.
$$

The second moment sat perfectly still at $6$. The third moment leapt from $-6$ to
$+6$ — a jump of exactly $12$. And the formula predicted it: the flipped position
has $(S^2)_{ab} = 1$, and $12 \times 1 = 12$. One tiny edit; two lenses; one blind,
one perfectly calibrated.

## An energy that ignores how many edges you have

There is a final twist that overturns a tempting intuition. One might guess that
denser graphs — more edges — should have more Seidel energy. They do not, and the
reason is a clean symmetry.

Take a graph and form its **complement**: keep the same vertices, but swap every
"connected" for "not connected" and vice versa. In the Seidel matrix, this turns
every $-1$ into $+1$ and every $+1$ into $-1$. In other words, complementation
simply negates the matrix: $S(\overline{G}) = -S(G)$.

Negating a matrix negates its eigenvalues, and negating a number does not change
its absolute value. So the Seidel energy of a graph and the energy of its
complement are *identical*:

$$
E_S(\overline{G}) = E_S(G).
$$

A sparse graph and its dense complement — with wildly different edge counts —
carry exactly the same Seidel energy. Whatever Seidel energy measures, it is
emphatically **not** a monotone function of the number of edges. The naive
"more edges, more energy" heuristic is simply false, and the symmetry says so in
one line.

## Why this matters

The moral is a general one about measurement. When you compress a rich object — a
spectrum, a distribution, a signal — into a few summary numbers, you inherit both
their power and their blind spots. The Seidel second moment is a wonderful
invariant precisely *because* it is constant: it pins every graph to a common
sphere and hands you a universal energy floor for free. But that same constancy
means it cannot resolve a local edit. To see the edit you must climb to the next
moment, where the zero-diagonal structure conspires to give you an exact,
interpretable formula rather than a mess.

Spectral moments of sign matrices sit at a crossroads of combinatorics and linear
algebra, and they appear wherever people study graphs through their eigenvalues:
in network science, in the theory of strongly regular graphs and two-graphs, in
error-correcting codes, and in the design of experiments. The lesson here — know
which moment sees your change, and exploit the structure that makes it clean — is
a small but sharp instrument, and the triangle-to-path example shows it working in
the palm of your hand.
