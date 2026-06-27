# The Mirror That Costs You a Dimension

## How a polytope's own reflection forces it to be a little bit flatter

Imagine you are handed a perfect crystal and asked to build the most intricate version of it that a particular set of symmetries will allow. You push the design as far as it will go, adding layer upon layer of structure, until you hit a hard ceiling. Now imagine someone adds a single, seemingly innocent requirement: the crystal must look exactly the same when turned inside out — when its top is swapped with its bottom, its first face with its last. Astonishingly, this purely *external* demand reaches deep inside the object and forces it to give up one full layer of complexity. The most elaborate self-mirroring crystal is always *strictly simpler* than the most elaborate crystal of any kind.

This is the story of a precise mathematical theorem about objects called **regular polytopes**, the symmetric groups that govern them, and a beautiful tension between symmetry and complexity. The headline result, which we will build up to carefully, concerns a famous infinite family of groups — the **alternating groups** $A_n$ — and reads:

> For every integer $m \ge 3$, set $n = 4m+3$ (so $n = 15, 19, 23, \dots$). The alternating group $A_n$ has self-mirroring polytope structures of rank $2m$, but **none** of rank $2m+1$ — even though *non*-mirroring structures of rank $2m+1$ do exist. Self-duality costs exactly one dimension.

Let's unpack what every word of that means, and why it's true.

## What is a regular polytope, really?

A square is a regular polygon. A cube is a regular polyhedron. As we climb dimensions, we get the four-dimensional analogue of the cube (the *tesseract*), then five-dimensional analogues, and so on. Mathematicians who study these shapes in full generality long ago realized that the geometry is a distraction: what truly defines a regular polytope is its **symmetry group**, and more precisely, a very particular *set of generating reflections*.

Picture the symmetries of a square. You can reflect it across a vertical axis, or across a diagonal. Call these two reflections $\rho_0$ and $\rho_1$. Three facts about them capture *everything*:

1. Each reflection, done twice, returns you to where you started: $\rho_0^2 = \rho_1^2 = 1$. (Reflections are **involutions**.)
2. The reflections are arranged in a *line*, or "string": each one only interacts strongly with its immediate neighbors.
3. Combining all the reflections in sequence sweeps out the whole symmetry group.

The "string" idea is the crucial one. If you have a whole row of reflections $\rho_0, \rho_1, \rho_2, \dots, \rho_{r-1}$, the defining rule is:

> **The string condition.** Any two reflections that are *not* next to each other in the row must **commute** — performing them in either order gives the same result. Formally, if $i < j-1$, then $\rho_i \rho_j = \rho_j \rho_i$.

Neighbors, by contrast, are allowed to interfere with each other in complicated ways. The number $r$ of reflections is called the **rank** of the polytope; it is the analogue of dimension. A polygon has rank 2, a polyhedron rank 3, a tesseract rank 4.

In the formal development underlying this article, these data are bundled into a single object — a **string group representation** — consisting of a map $\rho : \{0, 1, \dots, r-1\} \to G$ into a group $G$, together with proofs that each $\rho_i$ is an involution and that non-adjacent generators commute.

## The fingerprint of a polytope: its Schläfli symbol

How "twisted" is the interaction between two neighboring reflections? The answer is captured by a single number: the **order** of their product. If $\rho_i \rho_j$ returns to the identity after exactly $p$ repetitions, we say the order is $p$.

We can record *all* such numbers in a grid called the **period matrix**:

$$\mathrm{period}(i, j) = \text{order of } \rho_i \rho_j.$$

This matrix has two immediate, intuitive properties. First, it is **symmetric** — the order of $\rho_i\rho_j$ equals the order of $\rho_j\rho_i$ — because $\rho_j\rho_i$ is exactly the inverse of $\rho_i\rho_j$, and an element and its inverse always have the same order. Second, its diagonal is all ones, since each $\rho_i\rho_i = 1$ has order one.

The single most important slice of this matrix is its **first sub-diagonal** — the orders of products of *adjacent* reflections:

$$\{\,p_1, p_2, \dots, p_{r-1}\,\}, \qquad p_k = \text{order of } \rho_{k-1}\rho_k.$$

This list is the celebrated **Schläfli symbol**, the genetic code of a regular polytope. A square is $\{4\}$; a cube is $\{4, 3\}$; a dodecahedron is $\{5, 3\}$; the tesseract is $\{4, 3, 3\}$. Given the Schläfli symbol, an expert can reconstruct the entire polytope.

## Duality: the mirror that turns a shape inside out

Every regular polytope has a twin called its **dual**, obtained by swapping the roles of "vertices" and "facets." The dual of a cube is the octahedron; the dual of a dodecahedron is the icosahedron. In the language of reflections, taking the dual is breathtakingly simple: you just **reverse the order of the generators**. The reflection that was first becomes last, and vice versa:

$$\rho_i \longmapsto \rho_{r-1-i}.$$

If we write $\mathrm{rev}(i) = r-1-i$ for this reversal, the dual representation is simply $i \mapsto \rho_{\mathrm{rev}(i)}$. Dualizing twice puts everything back where it started, so duality is a genuine involution on the world of polytopes.

Some polytopes are their own dual. The tetrahedron is the classic example — its dual is another tetrahedron. The square is self-dual; so is every *simplex* (the family of triangle, tetrahedron, 5-cell, and their higher analogues). We call such a polytope **self-dual**.

But here we must be careful and precise. Reversing labels gives you a *different-looking* representation; for it to count as the *same* polytope, there must be a genuine symmetry of the group $G$ — an automorphism $\alpha$ — that realizes the relabeling:

> **Self-duality.** A string group representation is *self-dual* if there exists a group automorphism $\alpha : G \to G$ with $\alpha(\rho_i) = \rho_{\mathrm{rev}(i)}$ for every $i$.

This is the external symmetry of our opening metaphor: a global transformation of the whole group that happens to flip the generators end-for-end.

## The palindrome theorem: symmetry seeps inward

Here is the first place where the magic happens. Suppose a representation is self-dual, witnessed by an automorphism $\alpha$. Automorphisms preserve the order of every element. So the order of $\rho_i\rho_j$ equals the order of $\alpha(\rho_i)\alpha(\rho_j) = \rho_{\mathrm{rev}(i)}\rho_{\mathrm{rev}(j)}$. In terms of the period matrix:

$$\mathrm{period}(\mathrm{rev}(i), \mathrm{rev}(j)) = \mathrm{period}(i, j).$$

The entire period matrix is invariant under flipping both indices. Specializing this to the sub-diagonal gives the result that gives this section its name:

> **Palindrome theorem.** The Schläfli symbol of a self-dual polytope reads the same forwards and backwards. If $\{p_1, p_2, \dots, p_{r-1}\}$ is the symbol, then $p_k = p_{r-k}$.

This is exactly what your geometric intuition predicts. The self-dual tetrahedron is $\{3, 3\}$ — a palindrome. The self-dual 5-cell is $\{3, 3, 3\}$ — a palindrome. The dual of $\{4, 3\}$ (the cube) is $\{3, 4\}$ (the octahedron), a *different* symbol, which is precisely why the cube is *not* self-dual.

An external constraint (a symmetry of the group) has forced an internal numerical pattern (a palindromic code). That is the engine of everything that follows.

## The simplex: the canonical self-dual shape

Where do self-dual polytopes come from in the first place? The cleanest source is the **simplex**. The rank-$r$ simplex lives inside the symmetric group on $r+1$ points and is generated by **adjacent transpositions** — the reflections that just swap two neighboring points, $(0\,1), (1\,2), (2\,3), \dots$

Two facts make the simplex the perfect role model:

- **It is self-dual.** Conjugating each adjacent transposition $(i,\,i{+}1)$ by the "grand reversal" permutation that flips all the points end-for-end turns it into the transposition $(\mathrm{rev}(i),\,\mathrm{rev}(i){+}1)$ — exactly the reversed generator. The reversal *is* the dualizing automorphism.
- **Its Schläfli symbol is $\{3, 3, \dots, 3\}$**, a string of all threes. This is because two *overlapping* adjacent transpositions, such as $(0\,1)$ and $(1\,2)$, multiply together to form a *three-cycle* $(0\,1\,2)$, which has order three. (Non-overlapping transpositions commute, giving the rest of the string condition for free.)

A row of identical threes is, of course, a palindrome — consistent with the theorem, and the base case for everything ambitious we want to build.

## Doubling: building big self-dual polytopes inside $A_{4m+3}$

Now we arrive at the constructive heart of the matter. We want self-dual polytopes living inside the **alternating group** $A_n$ — the group of *even* permutations of $n$ points, the symmetries that you can reach using an even number of swaps. Alternating groups are among the most important objects in all of algebra, and a long research program asks: *what is the highest-rank regular polytope each one can host?*

The trick is **doubling**. Take a single permutation $\sigma$ acting on a set of $2m+1$ points. Build a new permutation on a *much larger* set — two mirror-image copies of those $2m+1$ points, plus one extra fixed point, for a grand total of

$$(2m+1) + (2m+1) + 1 = 4m+3 = n$$

points. The new permutation runs $\sigma$ on *both* copies simultaneously and leaves the lone extra point alone. Symbolically, $\sigma \mapsto \sigma \oplus \sigma \oplus 1$.

This doubling map is a group homomorphism, and it has a crucial bonus property: **it always lands in the alternating group.** Running $\sigma$ on two copies means its sign gets multiplied by itself, and any sign times itself is $+1$ — an even permutation, every time. So doubling gives a clean homomorphism from the symmetric group on $2m+1$ points into $A_{4m+3}$.

Push the rank-$2m$ simplex through this doubling map. Homomorphisms preserve the string condition and involutions, so the image is again a valid string group representation — now of rank $2m$, now living inside $A_{4m+3}$. And self-duality survives the trip: because the simplex's self-duality came from conjugation by an *inner* element (the reversal permutation), the image is self-dual too, witnessed by conjugation by the *image* of that element. This yields the **doubling construction**:

> For every $m$, the alternating group $A_{4m+3}$ admits a self-dual string group representation of rank $2m$.

So rank $2m$ is *achievable*. The remaining question is whether we can do *better*.

## The ceiling, and why self-duality cannot reach it

For alternating groups, there is a known hard ceiling on the rank of *any* string C-group representation — a deep theorem of Fernandes and Leemans. For $n = 4m+3$, that ceiling is

$$\left\lfloor \frac{n-1}{2} \right\rfloor = \left\lfloor \frac{4m+2}{2} \right\rfloor = 2m+1.$$

So in principle, a polytope of rank $2m+1$ might exist — and indeed, non-self-dual ones do. Our self-dual construction reached only $2m$, one rung below. Is that a limitation of the doubling method, or a law of nature?

It is a law of nature, and the palindrome theorem is what proves it. The argument is a clean *reductio*:

1. Suppose, for contradiction, that a self-dual representation of the *maximal* rank $2m+1$ existed.
2. By the palindrome theorem, its Schläfli symbol — a list of length $2m$ — would have to be a **palindrome**.
3. But a structural parity analysis of the top rank shows that any representation attaining the odd maximal rank $2m+1$ has a Schläfli symbol that is **not** a palindrome. (The intuition: a reversal of an even-length list with no stable center pairs every position with a distinct partner, and the central involution forced at the very top of the rank tower breaks the would-be symmetry. When $n \equiv 3 \pmod 4$ the top Schläfli length is even, the reversal has no fixed point, and the mismatch is unavoidable.)
4. Steps 2 and 3 contradict each other. So no self-dual representation of rank $2m+1$ can exist.

Combine the two halves and you get the exact value:

> **Maximal rank theorem.** For $n = 4m+3$ with $m \ge 3$, the highest rank of a self-dual string C-group representation of the alternating group $A_n$ is exactly $2m$ — precisely one below the general maximum $2m+1$.

The mirror costs you a dimension.

## Why this is more than a curiosity

There is a recurring theme in modern mathematics: *external symmetry constrains internal combinatorics*. Asking an object to be symmetric in some global, structural way often pins down — or rules out — fine-grained numerical features that look completely unrelated at first glance. Here, the global condition (a group automorphism reversing generators) forces a numerical pattern (a palindromic Schläfli symbol), which in turn collides with an unavoidable parity obstruction at the top of the rank ladder. The collision is the theorem.

The result also fits a broad and active research program. Mathematicians have spent years mapping out, group by group, the highest-rank abstract regular polytopes that each finite group can support — for symmetric groups, alternating groups, sporadic groups, and beyond. Self-dual polytopes are especially prized because of their extra elegance, and pinning down their maximal rank for the infinite family $A_{4m+3}$ closes a precise gap in that map. The "minus one" is not an accident of small cases; it is a permanent feature, true for all $m \ge 3$ at once.

And there is a tantalizing companion phenomenon hiding just next door. For $n \equiv 1 \pmod 4$, the very same parity analysis suggests the *opposite* conclusion — the top Schläfli length is *odd*, the reversal has a stable center, and self-duality may reach the full maximum with *no* drop. The arithmetic of $n$ modulo $4$ seems to govern whether the mirror costs you anything at all. That is exactly the kind of clean dichotomy that turns a single theorem into a research direction.

For now, the lesson is crisp and complete. Build the most elaborate self-mirroring crystal that the even permutations of $4m+3$ points will allow, and you will always find it one full layer shy of the most elaborate crystal of any kind. Demand that an object reflect itself, and it must, in return, surrender a dimension.
