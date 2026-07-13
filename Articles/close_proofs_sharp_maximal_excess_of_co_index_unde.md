# How to Glue Spheres: The Hidden Arithmetic of Symmetry

## A puzzle about antipodes

Stand on the surface of the Earth and imagine your *antipode* — the point on the exact opposite side of the globe. Every point has one, and the pairing is perfectly balanced: no place is its own antipode, and the pairing you-and-your-antipode is the same as your-antipode-and-you. A sphere carrying such a pairing is the simplest example of a *symmetric space*: a shape equipped with a way to swap each point with an "opposite."

This innocuous idea — a space that knows how to reflect itself — sits at the heart of some of the most striking theorems in modern mathematics. The most famous is the **Borsuk–Ulam theorem**: at any instant there are two antipodal points on the Earth's surface with exactly the same temperature and barometric pressure. Push the idea further and it powers results in combinatorics (how many colors you need to paint certain networks), in economics (fair division of a cake), and in data science. The common thread is a single number attached to every symmetric space, a number that measures *how much symmetry the space really contains.* That number is called the **co-index**.

This article is about a clean new law governing that number — a law about what happens to the co-index when you **glue two symmetric spaces together**.

## Measuring symmetry with a single number

How do you quantify "how symmetric" a space is? The trick, going back to Borsuk and Ulam, is to compare your space against a fixed family of yardsticks: the spheres themselves.

The circle $S^1$, the ordinary sphere $S^2$, the three-dimensional sphere $S^3$, and so on, all carry the antipodal pairing. They form a ladder of increasing symmetry: the higher the dimension, the "more room" the antipodal symmetry has to move around. The co-index of a symmetric space $K$ asks a simple question:

> *What is the largest sphere $S^n$ that can be mapped into $K$ in a way that respects the antipodal pairing?*

A map "respects the pairing" if it sends antipodes to antipodes — opposite points go to opposite points. If the biggest such sphere is $S^n$, we say $K$ has **co-index at least $n$**, written $\operatorname{coind}(K) \ge n$. Intuitively, a space that can absorb a big antipodal sphere is itself very symmetric; one that can only absorb a small sphere is symmetrically "thin."

The co-index is not just an abstract gadget. When a space is a network (a graph or a more elaborate combinatorial structure), its co-index bounds the number of colors needed to paint it so that related pieces get different colors. Lovász's celebrated resolution of the Kneser conjecture — a purely combinatorial statement about set systems — was proved exactly this way: build a symmetric space from the network, measure its co-index, and read off the answer.

## A discrete model you can compute with

To reason about these ideas concretely — and to compute — it helps to replace smooth spheres with combinatorial ones built from finitely many vertices. The cleanest such model is the **octahedral sphere**.

Take the ordinary octahedron: six vertices, arranged as three pairs of opposite points along three axes. Its surface is a triangulated $2$-sphere. The pattern generalizes. For each dimension $n$ we build a complex on $2(n+1)$ vertices, arranged as $n+1$ antipodal pairs. Concretely, the vertices are the pairs $(i, b)$ where $i$ runs over $n+1$ "axes" and $b$ is a sign ("$+$" or "$-$"). The antipodal map flips the sign: $(i,+) \leftrightarrow (i,-)$. A collection of vertices forms a genuine face of the shape precisely when **it never contains both ends of the same axis** — you may pick a $+$ or a $-$ from each axis, but never both. This is the *octahedral $n$-sphere* $\mathrm{Oct}(n)$, and geometrically it is a triangulation of the honest sphere $S^n$.

The virtue of this model is that everything becomes finite and checkable. A "symmetric space" is now an abstract simplicial complex — a downward-closed family of allowed vertex sets called *faces* — together with a fixed-point-free involution $\alpha$ that swaps vertices and carries faces to faces. The word **free** records the crucial condition that no vertex is its own antipode ($\alpha(v) \ne v$ for all $v$); this is what forbids a "collapse" of the symmetry and makes the co-index meaningful. And a symmetry-respecting map — an *equivariant simplicial map* — is just a function on vertices that commutes with the two antipodal maps and sends faces to faces. The co-index becomes:

$$\operatorname{coind}(K) \ge n \quad\Longleftrightarrow\quad \text{there is an equivariant simplicial map } \mathrm{Oct}(n) \to K.$$

## The operation that glues: the join

Now for the main character. Given two symmetric spaces $K$ and $L$, their **join** $K \star L$ is a way of gluing them together into a single, larger symmetric space. The recipe is remarkably simple. Put all the vertices of $K$ side by side with all the vertices of $L$ (a disjoint union). The antipodal map acts on each piece separately, using $K$'s antipode on $K$'s vertices and $L$'s antipode on $L$'s vertices. And a set of vertices is declared a face of $K \star L$ exactly when **its $K$-part is a face of $K$ and its $L$-part is a face of $L$** — with no cross-constraints tying the two sides together.

That "no cross-constraints" clause is the whole story. Because the two sides never interfere, a face of $K$ and a face of $L$ can always be combined into a face of $K \star L$. Geometrically, the join fills in *all* the line segments connecting a point of $K$ to a point of $L$. Joining two line segments gives a solid tetrahedron; joining two circles gives a $3$-sphere. In general, joining an $m$-sphere with an $n$-sphere yields a sphere one dimension higher than the sum:

$$S^m \star S^n \;\cong\; S^{m+n+1}.$$

That mysterious "$+1$" — the extra dimension created out of thin air by the gluing — is the fingerprint of the join, and it will show up again in the co-index law.

## The main theorem: co-indices add (with a bonus)

Here is the central result of this work.

> **Join Superadditivity of the Co-index.** For any two free symmetric spaces $K$ and $L$,
> $$\operatorname{coind}(K \star L) \;\ge\; \operatorname{coind}(K) + \operatorname{coind}(L) + 1.$$

In words: gluing two symmetric spaces does not merely add their symmetries — it adds them *and throws in a bonus unit*. The symmetry of the whole exceeds the sum of the symmetries of the parts. That surplus "$+1$" is precisely the extra dimension the join manufactures.

The proof is constructive and, at its core, a beautiful exercise in bookkeeping. Suppose $K$ can absorb the sphere $\mathrm{Oct}(m)$ and $L$ can absorb the sphere $\mathrm{Oct}(n)$; we must show $K \star L$ can absorb $\mathrm{Oct}(m+n+1)$. The key is an explicit "splitting" map that realizes the join homeomorphism $S^{m+n+1} \cong S^m \star S^n$ at the combinatorial level. The sphere $\mathrm{Oct}(m+n+1)$ has $m+n+2$ axes. We simply cut that range in two: the first $m+1$ axes are shipped to the $K$-side and the last $n+1$ axes to the $L$-side. Each vertex of the big sphere carries its sign along, and one checks — directly — that this map respects the antipodal pairing and sends non-conflicting vertex sets to non-conflicting vertex sets on each side. Composing this splitting with the two given absorbing maps produces an equivariant map $\mathrm{Oct}(m+n+1) \to K \star L$, which is exactly the co-index bound we wanted.

Two structural facts make the argument airtight. First, the join is a genuine *bifunctor*: any pair of symmetry-respecting maps $K \to K'$ and $L \to L'$ can be joined into a single symmetry-respecting map $K \star L \to K' \star L'$. Second, the octahedral spheres are closed under joining, in the sharpest possible sense — there is an explicit equivariant map

$$\mathrm{Oct}(m+n+1) \;\longrightarrow\; \mathrm{Oct}(m) \star \mathrm{Oct}(n),$$

the combinatorial incarnation of $S^{m+n+1} \cong S^m \star S^n$. Together these say the octahedral spheres form a *join-monoid*: their ladder of dimensions is nothing but addition-with-a-shift, $m \star n = m + n + 1$.

## Suspension, recovered for free

One special case is worth spotlighting because it recovers a classical phenomenon. The **suspension** of a space $K$ is what you get by joining it with the $0$-sphere $S^0$ — a single pair of antipodal points, which in our model is $\mathrm{Oct}(0)$. Geometrically, suspension takes $K$, adds a "north pole" and a "south pole," and cones off to both: it turns a circle into a $2$-sphere, a $2$-sphere into a $3$-sphere, and so on, always raising the dimension by exactly one.

Since the $0$-sphere has co-index $0$, plugging $L = S^0$ into the superadditivity law gives:

> **Suspension Raises Co-index.** For any free symmetric space $K$,
> $$\operatorname{coind}(S K) \;\ge\; \operatorname{coind}(K) + 1.$$

Each suspension is guaranteed to lift the co-index by at least one. This is the constructive engine behind a line of research (associated with Simonyi, Tardos, and Vrécica) into how sharply the co-index can jump. Our theorem shows that the suspension jump is just the smallest instance of a far more general join law: suspension is joining with the smallest possible sphere, and joining with $S^n$ raises the co-index by $n+1$.

## Dimensions, and the excess

There is a companion piece of bookkeeping about *dimension*. The dimension of a simplicial complex is one less than the number of vertices in its largest face. When you combine a top face of $K$ (say with $p+1$ vertices) and a top face of $L$ (say with $q+1$ vertices), the "no cross-constraints" rule guarantees their union is a face of $K \star L$, and — because the two sides live on disjoint vertex sets — it has $p + q + 2$ vertices. Hence

$$\dim(K \star L) \;\ge\; \dim(K) + \dim(L) + 1,$$

the exact same "$+1$" arithmetic that governs the co-index and matches the dimension law for joins of spheres.

The interplay between these two quantities — co-index and dimension — is where the deepest questions live. Every free symmetric space satisfies $\operatorname{coind}(K) \le \dim(K)$: you can never absorb a sphere bigger than the room you have. The gap between them,

$$\text{excess} \;=\; \dim(K) - \operatorname{coind}(K),$$

measures how far a space falls short of being "as symmetric as it could possibly be." A sphere has excess zero; more exotic spaces can have large excess, pinned below their dimension by a subtle Borsuk–Ulam obstruction. Because the join gives us a **dial for dimension that is independent of co-index**, it becomes a powerful tool for manufacturing spaces with any prescribed combination of dimension and co-index — the raw material for the *maximal-excess* program, which seeks, for every dimension $d \ge 2$ and every feasible target $c$ with $1 \le c \le d$, a $d$-dimensional space of co-index exactly $c$ whose suspension leaps all the way to co-index $d+1$.

## Why it matters

At first glance this is abstract machinery. But the co-index is a bridge between three worlds that rarely speak to one another:

- **Topology**, where spheres, suspensions, and joins are the basic vocabulary of shape;
- **Combinatorics**, where finite networks and their colorings are the objects of study; and
- **Symmetry**, the antipodal structure that turns qualitative pictures into hard numerical bounds.

The join is one of the oldest constructions in topology, and the co-index is one of the sharpest combinatorial tools to come out of it. What the superadditivity law provides is a clean, arithmetic bridge: *to combine two symmetric problems, you add their difficulty and then add one.* The extra "$+1$" — the surplus symmetry created by gluing — is not an accident of the construction. It is a genuine feature of how symmetry compounds, and it turns the family of spheres into a tidy additive ladder that any two problems can climb together.

The result proved here is the constructive, lower-bound half of the story: gluing always produces *at least* the predicted amount of symmetry. Whether it produces *exactly* that amount — the matching upper bound, which would pin the co-index of a join to $\operatorname{coind}(K) + \operatorname{coind}(L) + 1$ on the nose — is a deeper question requiring a genuinely different tool: an obstruction that detects when a sphere simply *cannot* be absorbed. That is the frontier. But the arithmetic of gluing, the surprising and beautiful "$+1$," is now on solid ground.
