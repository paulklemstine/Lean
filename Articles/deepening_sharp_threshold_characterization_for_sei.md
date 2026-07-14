# When Removing Edges Makes a Network *Louder*: The Seidel Energy of Complete Bipartite Graphs

## A number attached to a shape

Take any network — a web of dots connected by lines. Mathematicians have long
searched for a single number that captures its overall "shape," a summary that
survives the messiness of the diagram and speaks only to its deep structure. One
of the most elegant such numbers is called **energy**.

The name is not an accident. If you think of a graph as a vibrating structure —
a drum head, a molecule, a bridge — its natural modes of vibration are governed
by a table of numbers called a *matrix*, and the frequencies of those modes are
that matrix's *eigenvalues*. The energy is simply the total size of all those
frequencies added up, ignoring whether each points up or down. Big energy means
a rich, complex spectrum of vibrations; small energy means a placid one.

This article is about a particular flavor of energy — **Seidel energy** — and a
surprising discovery about it: for a large and important family of networks,
*deleting connections can make the energy go up*. Cutting a wire can make the
whole structure ring louder. And we can say exactly when.

## Complete bipartite graphs: the cleanest networks there are

The networks we study are the **complete bipartite graphs**, written
$K_{m,n}$. Picture two teams: a left team with $m$ players and a right team with
$n$ players. Every left player is connected to every right player, and there are
no connections *within* a team. Think of $m$ authors each of whom has
co-written with all of $n$ editors; or $m$ power plants each feeding all of $n$
cities. These graphs are the "perfect crystals" of graph theory: maximally
symmetric, utterly regular, and a favorite testing ground for every new idea.

To measure the energy we first need the right matrix. The classical choice is
the **adjacency matrix**, which records a $1$ wherever two dots are joined. The
Seidel viewpoint takes a cleverer bookkeeping, assigning
$$S = J - I - 2A,$$
where $A$ is the adjacency matrix, $I$ is the identity, and $J$ is the all-ones
matrix. In plain terms: put $-1$ where two vertices are joined, $+1$ where they
are not, and $0$ down the diagonal. This "$\pm 1$" encoding treats *presence* and
*absence* of an edge on an equal footing, which turns out to be exactly the right
democracy for many questions.

For a complete bipartite graph the Seidel matrix has a beautiful secret. Assign
to every left-team vertex the label $+1$ and to every right-team vertex the label
$-1$, collecting these into a single vector $w$. Then
$$S = w\,w^{\mathsf T} - I.$$
The entire matrix is built from *one vector*, plus a subtraction of the
identity. This is what mathematicians call **rank one** structure, and it is
gold: it means the spectrum can be read off almost by inspection. The Seidel
matrix of $K_{m,n}$ has just two distinct eigenvalues, and its **Seidel energy**
comes out to the clean formula
$$E\big(K_{m,n}\big) = 2\,(m+n-1).$$

That is our baseline. Now the drama begins.

## What happens when you cut a wire?

Suppose we snip a single connection between a left player and a right player. In
the Seidel encoding, that entry flips from $-1$ (joined) to $+1$ (not joined) —
a small, local change. But small local changes can ripple through a whole
spectrum. It has been known that deleting one edge from $K_{m,n}$ is a modest
perturbation of the matrix, and that the energy strictly increases precisely when
$m+n \ge 4$. Below that, the graph is too small for the effect to take hold.

This raised a tantalizing question. The literature had established a scattered
list of *threshold conditions* under which deleting an edge provably raises the
energy — pairs of sizes like $(3,6)$, $(6,3)$, $(2,15)$, $(15,2)$, and $(4,4)$.
The suspicion was that these thresholds were **not sharp**: mere artifacts of the
proof technique, not real barriers in the mathematics. To go *deeper* than the
one-edge story, we ask what happens when we cut **two** wires at once — and
whether any threshold survives.

## Two cuts, and a spectrum in closed form

Here is the setup. Remove **two independent edges** from $K_{m,n}$: two
connections that share no endpoint. Say we cut the edge from left player $a_0$ to
right player $b_0$, and the edge from a *different* left player $a_1$ to a
*different* right player $b_1$. (Independence — $a_0 \ne a_1$ and $b_0 \ne b_1$ —
is what keeps the algebra clean and, as it happens, what makes the theorem
sharpest.)

Two edge deletions perturb the Seidel matrix in five directions at once — a
**rank-five** change to the pristine rank-one original. That sounds worse, but
the miracle is that it is still completely solvable. The characteristic
polynomial, the master equation whose roots are all the eigenvalues, factors
entirely:
$$\chi(X) = (X+1)^{\,m+n-5}\,(X-1)^2\,(X+3)\,\Big(X^2 - (m{+}n{-}4)\,X - \big(3(m{+}n){-}11\big)\Big).$$

Read off the roots and you get the full **Seidel spectrum** of the two-edge-
deleted graph. Writing $N = m+n$ for the total number of vertices:
$$\underbrace{-1,\dots,-1}_{N-5},\quad \underbrace{1,\,1}_{2},\quad -3,\quad
\frac{(N-4) \pm \sqrt{(N+2)^2 - 32}}{2}.$$

Most of the eigenvalues are frozen at $-1$; a handful jump to fixed integer
values $1$, $1$, and $-3$; and two genuinely new eigenvalues emerge from a
quadratic, one positive and one negative, carrying a square root that depends on
the size of the graph.

## The energy, and the vanishing threshold

Summing the sizes of all these eigenvalues gives the punchline. The two new
quadratic roots have opposite signs, so together they contribute exactly
$\sqrt{(N+2)^2-32}$. Adding the rest, the Seidel energy of $K_{m,n}$ with two
independent edges removed is
$$E_2 = (m+n) + \sqrt{(m+n+2)^2 - 32}.$$

Compare this to the baseline $2(m+n-1) = 2N-2$. The energy strictly increases
exactly when
$$N + \sqrt{(N+2)^2 - 32} > 2N - 2,
\quad\text{i.e.}\quad \sqrt{(N+2)^2 - 32} > N - 2.$$
Square both sides: $(N+2)^2 - 32 > (N-2)^2$, which simplifies to $8N > 32$, that
is $N > 4$. In other words, the energy goes up for **every** $N \ge 5$.

This is the heart of the matter. Two independent edges can only *exist* in
$K_{m,n}$ when both parts have at least two vertices, so $m,n \ge 2$ and hence
$N \ge 4$; and $N = 4$ (the graph $K_{2,2}$, whose only two independent edges form
a perfect matching) is a special degenerate case sitting exactly on the boundary
where the square root would go imaginary. For every genuinely two-independent-edge
deletion — that is, whenever $m,n \ge 2$ and $m+n \ge 5$ — the energy strictly
increases.

**There is no threshold obstruction at all.** The scattered conditions
$(3,6)$, $(2,15)$, $(4,4)$ and the rest were indeed not sharp. Once you delete
two independent edges, the energy *always* rises. The one-edge story had a real
barrier at $N \ge 4$; the two-edge story has none beyond the bare requirement that
the two edges can exist and not collapse into a perfect matching.

## A tiny example you can check by hand

The smallest graph where two independent edges live is $K_{2,3}$: two left
players, three right players, six edges in all. Its baseline Seidel energy is
$2(2+3-1) = 8$. Delete two independent edges and the formula predicts
$$E_2 = 5 + \sqrt{(5+2)^2 - 32} = 5 + \sqrt{17} \approx 9.123.$$
Sure enough, the energy jumps from $8$ to $5 + \sqrt{17}$ — an unambiguous
increase in the very smallest case, with no room for a threshold to hide.

## Why "louder after cutting" is not a paradox

It feels backwards that removing structure should amplify a global measure. The
resolution lies in what energy really counts. Seidel energy rewards *spread* in
the spectrum — a diversity of vibration frequencies, some large positive, some
large negative. A pristine complete bipartite graph is spectrally dull: its
Seidel matrix has only two distinct eigenvalues, an extreme concentration.
Cutting edges breaks the perfect symmetry and splinters that concentration,
spawning new eigenvalues that fan out from the crowd. The two fresh roots
$\frac{(N-4)\pm\sqrt{(N+2)^2-32}}{2}$ are exactly those splinters, and their
combined magnitude $\sqrt{(N+2)^2-32}$ is what tips the balance upward.

So the paradox dissolves: destroying symmetry creates spectral variety, and
spectral variety is precisely what energy measures.

## The bigger picture

This result is a small, sharp window into a much larger landscape. The same
technique — recognizing that a few edge deletions perturb the matrix in only a
handful of directions, and then boiling the whole spectral problem down to a tiny
core matrix — extends naturally. Delete $k$ independent edges (a *matching* of
size $k$) and the same machinery predicts a Seidel spectrum
$$\{-1\}^{N-2k-1} \cup \{1\}^{k} \cup \{-3\}^{k-1} \cup
\left\{ \frac{(N-4)\pm\sqrt{(N+2)^2 - 16k}}{2}\right\},$$
with energy $E_k = (N + 2k - 4) + \sqrt{(N+2)^2 - 16k}$ and a predicted sharp
threshold $N \ge k+3$ — meaning, once $k \ge 2$, the energy essentially always
rises. Other frontiers beckon too: deleting edges that *share* a vertex (a star
or a path), the delicate perfect-matching case $N = 2k$, and the leap from
bipartite to multipartite networks, where the rank-one magic gives way to a
richer rank-$r$ structure.

What began as a question about one number attached to one family of graphs turns
into a clean, complete story: cut two independent wires in any complete bipartite
network large enough to have them, and it will always ring a little louder. And
now we know exactly by how much: $(m+n) + \sqrt{(m+n+2)^2 - 32}$.
