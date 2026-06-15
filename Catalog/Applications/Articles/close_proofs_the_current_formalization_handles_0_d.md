# How Many Friendships Can You Have Before a Triangle Appears?

## A puzzle about crowds, connections, and the unavoidable

Imagine a party with one hundred guests. Some pairs of people know each
other; most do not. You, the host, have a strange goal: you want to
maximize the number of acquaintanceships in the room — to pack in as many
mutual hellos as possible — while obeying a single, oddly specific rule.
**No three guests may all know one another.** No cozy triangles of mutual
friends.

How many handshakes can you allow before a triangle becomes
mathematically unavoidable?

This is not an idle riddle. It is the seed of an entire branch of
mathematics called *extremal graph theory*, the study of how much
structure a network can carry before some pattern is forced to appear. It
turns out the answer to the party puzzle is beautiful, exact, and over a
century old — and it generalizes into one of the most elegant results in
all of combinatorics. This article tells that story, states the theorems
precisely, and shows how they fit together like gears in a single machine.

## Networks as graphs

Mathematicians strip the party down to its bones. Each guest becomes a
**vertex** — a dot. Each acquaintanceship becomes an **edge** — a line
connecting two dots. The whole social fabric becomes a *graph*: a set of
dots, some joined by lines. A graph with `n` vertices can have at most
`n(n−1)/2` edges, the case where everyone knows everyone (the "complete
graph").

A **triangle** is three vertices, each pair joined by an edge — three
mutual friends. A graph with no triangle at all is called *triangle-free*.
The party puzzle asks: among all triangle-free graphs on `n` vertices,
which has the most edges, and how many is that?

## Mantel's answer

In 1907 the Dutch mathematician Willem Mantel gave the answer, and it is
astonishingly clean.

> **Mantel's Theorem.** A triangle-free graph on `n` vertices has at most
> `n²/4` edges.

For one hundred guests, that ceiling is `100²/4 = 2500` acquaintanceships.
Allow even one more, and a triangle of mutual friends must appear
somewhere in the room — there is no way to avoid it.

And the bound is *tight*: you can actually reach 2500. Split the hundred
guests into two groups of fifty. Let every guest in the first group know
every guest in the second group, but let no two guests *within* the same
group know each other. Count the handshakes: `50 × 50 = 2500`. Is there a
triangle? A triangle would need three people, and by the pigeonhole
principle two of them must fall in the same group — but same-group guests
are strangers, so no triangle can form. The "balanced bipartite" party is
the unique champion.

This single construction — split the crowd into balanced groups, connect
everything *across* groups and nothing *within* — is the heart of the
whole theory.

## The proof in one breath

The proof of Mantel's theorem we formalized is the elegant *degree
counting* argument, and it is worth savoring because it reveals *why* the
bound is `n²/4` rather than some other number.

The **degree** of a vertex is its number of friends. Here is the key
observation about triangle-free graphs:

> **If two people `u` and `v` are friends, they share no common friend.**

Why? A common friend `w` would mean `u`, `v`, `w` are all mutually
acquainted — a triangle, which is forbidden. So in a triangle-free graph,
for any edge `{u, v}`, the friend-set of `u` and the friend-set of `v` are
*disjoint*. Since both friend-sets live among the `n` guests, their sizes
add up to at most `n`:

> **For every edge `{u, v}`:  `deg(u) + deg(v) ≤ n`.**

Now sum this inequality over all edges. On the right we get `n · |E|`,
where `|E|` is the edge count. On the left, a small miracle: each vertex
`v` contributes its degree once for each of its `deg(v)` edges, so the
total is exactly the sum of *squared* degrees, `∑ deg(v)²`. We have proven

> `∑ deg(v)² ≤ n · |E|.`

The finish comes from a tool every mathematician carries: the
**Cauchy–Schwarz inequality**, which here says

> `n · ∑ deg(v)² ≥ (∑ deg(v))².`

And the sum of all degrees has a famous value. Every edge has two
endpoints, so it is counted twice when you add up degrees — the
**handshaking lemma**: `∑ deg(v) = 2|E|`. Substituting,

> `(2|E|)² = (∑ deg(v))² ≤ n · ∑ deg(v)² ≤ n · (n · |E|) = n² · |E|.`

So `4|E|² ≤ n²·|E|`, and dividing by `|E|` gives `4|E| ≤ n²`. That is
Mantel's theorem, falling out of two summation tricks and one classical
inequality. We formalized every step, including the two workhorses
(degree energy via Cauchy–Schwarz, and the triangle-free degree bound) as
reusable lemmas.

## Beyond triangles: Turán's theorem

Mantel forbade triangles — complete graphs on *three* vertices, written
`K₃`. What if we forbid `K₄` (four mutual friends), or `K₅`, or in general
`K_{p+1}`? This is the great generalization found by Pál Turán in 1941, and
it launched the field.

The answer reuses Mantel's winning idea. To avoid `K_{p+1}`, don't split
the crowd into 2 balanced groups — split it into `p` balanced groups.
Connect every pair of guests in *different* groups; connect no one inside
a group. This is the **Turán graph** `T(n, p)`. In our formalization we
build it concretely: label the guests `0, 1, …, n−1`, and declare two
guests adjacent exactly when they leave different remainders upon division
by `p`. The remainder classes are the `p` groups.

Why is the Turán graph free of `K_{p+1}`? The same pigeonhole magic that
killed triangles. A clique of `p+1` guests would need `p+1` people landing
in `p` remainder classes, so two of them share a class — but same-class
guests are strangers, so they cannot both belong to a clique. We proved
exactly this:

> **Turán Graph Clique-Freeness.** For every `n` and every `p ≥ 1`, the
> Turán graph `T(n, p)` contains no clique on `p+1` vertices; it is
> `K_{p+1}`-free.

Turán's full theorem then asserts that `T(n, p)` is not merely *an*
example but *the* optimal one: it has the maximum possible number of edges
among all `K_{p+1}`-free graphs. Mantel is the case `p = 2`. Our
formalization establishes the extremal construction's defining property —
its clique-freeness — and proves the `p = 2` optimality bound (Mantel) in
full.

## A foundational tool: peeling off a vertex

Hidden inside Turán-type arguments is a quiet but powerful lemma that we
isolated and proved, because it is the engine of the *inductive* approach
to these theorems:

> **Neighborhood Clique-Free Lemma.** If a graph `G` has no clique on `r`
> vertices, then for any vertex `v`, the friends of `v` contain no clique
> on `r−1` vertices.

The reasoning is irresistibly simple. Suppose, among `v`'s friends, you
found `r−1` people all mutually acquainted — an `(r−1)`-clique. Every one
of them is, by definition, a friend of `v`. So throw `v` into the group:
now you have `r` people, all mutually acquainted, because the original
`r−1` were a clique *and* each was joined to `v`. That is an `r`-clique,
contradicting the assumption that `G` had none. Therefore no such
`(r−1)`-clique can hide in a neighborhood. This lemma lets you prove
clique bounds by induction on `r`, peeling off one vertex at a time.

## When triangles already exist: a repair algorithm

So far we have asked how to *avoid* triangles. A different, very practical
question is: *given* a messy network full of triangles, how cheaply can we
make it triangle-free by deleting edges? Think of removing the minimum
number of conflicting connections to break every forbidden cozy trio.

We proved a constructive guarantee — an algorithm with a certificate:

> **Greedy Triangle Removal.** For any graph `G`, there exists a
> triangle-free graph `H` obtainable from `G` by deleting edges, with the
> number of deletions at most the number of triangles in `G`.

The algorithm is exactly what you'd try first: while a triangle remains,
pick one and delete one of its three edges. Each deletion destroys at
least the triangle you targeted, so the process terminates, and you never
delete more edges than there were triangles to begin with. The theorem
turns this intuition into a verified bound on the "edit distance" from any
graph to triangle-freeness. We also proved that this notion of edit
distance behaves sensibly: it is symmetric (the cost to turn `G` into `H`
equals the cost to turn `H` into `G`), and zero exactly when the two
graphs are identical.

## The reusable machinery

A good theory is more than its headline results; it is a toolbox. Along
the way we packaged several pieces of independently useful infrastructure,
each formally proved:

- **The degree-energy bound** `n · ∑ deg(v)² ≥ (∑ deg(v))²`, a clean
  Cauchy–Schwarz statement about any graph, usable in any degree-based
  extremal argument.
- **The handshaking lemma** `2|E| = ∑ deg(v)`, connecting the global edge
  count to local degrees.
- **Disjoint neighborhoods in triangle-free graphs**, the geometric heart
  of Mantel's proof, stated as its own lemma.
- **Monotonicity of the lower shadow**, a fact from the theory of set
  systems: if one family of sets sits inside another, the family of all
  their "one-element-smaller" subsets respects the same inclusion. This is
  a building block toward the celebrated Kruskal–Katona theorem on the
  shadows of set families, hinting at how extremal graph theory connects
  to extremal *set* theory.

## Why this matters beyond the party

Extremal graph theory is the mathematics of *unavoidable structure*, and
that idea reaches far past any party. Network engineers ask how densely
they can wire a system before certain costly substructures appear.
Computer scientists use triangle-counting and triangle-removal as
primitives in clustering, community detection, and the analysis of social
and biological networks. The "split into balanced groups" construction is
the combinatorial skeleton behind error-correcting codes and the design of
robust communication networks. And the Cauchy–Schwarz-plus-handshaking
technique — translate a global constraint into a local degree inequality,
then sum — is one of the most transferable moves in all of discrete
mathematics.

There is also a deeper philosophical pull. These theorems say that
*scarcity of structure has a price*: you cannot keep adding connections
indefinitely while forbidding a pattern; sooner or later the pattern is
forced. The exact location of that threshold — `n²/4` for triangles,
`(1 − 1/p)·n²/2` for `K_{p+1}` — is not arbitrary. It is dictated by the
single most symmetric construction imaginable: divide the world into equal
parts and connect across the divides.

## The view from the summit

We began with a host counting handshakes and ended with a century of
mathematics: Mantel's `n²/4` ceiling, Turán's `p`-part generalization, the
inductive neighborhood lemma that drives the proofs, a constructive repair
algorithm with a provable cost bound, and a toolbox of degree-energy and
shadow lemmas. Every one of these statements has been pinned down with
complete rigor.

The next time you are in a crowded room, look around and count. Somewhere
above two-thousand-five-hundred acquaintances among a hundred people, a
triangle of mutual friends is hiding — not by chance, but by theorem.
