# The Loop That Remembers Everything — and the One Thing It Forgets

## A shape you can hear

Imagine a shape you are allowed to touch but never see. You can walk loops inside it, and you can compare loops: two loops are "the same" if one can be slid continuously onto the other without leaving the space. Concatenating loops gives you a multiplication; reversing a loop gives you an inverse. Out of pure walking, an algebraic object appears — the *fundamental group* $\pi_1$ of the space.

This is the oldest bridge in topology, and its charm is that it turns a question about rubber sheets into a question about symbols. A circle has fundamental group $\mathbb{Z}$: a loop is remembered only by how many times it winds around, and windings add. A torus — the surface of a doughnut — has fundamental group $\mathbb{Z}^2$: a loop is remembered by how many times it goes around the hole and how many times it goes through it. A figure eight has a free group on two generators, where the two loops refuse to commute.

The natural next question is the one every invariant must eventually face: **how much does it remember?** If two spaces have the same fundamental group, must they be the same space?

The honest answer is a beautiful pair of extremes, and this article is about both of them.

## First extreme: for one-dimensional shapes, the group remembers *everything*

Not all spaces are visible to $\pi_1$. A sphere has trivial fundamental group — every loop on a sphere shrinks to a point — and so does a single point, yet no one would confuse the two. The sphere hides its complexity in higher dimensions, in two-dimensional and three-dimensional holes that loops simply cannot feel.

So restrict attention to the spaces where there is nothing above dimension one to hide: the *aspherical* spaces of dimension one, classically written $K(G,1)$. These are connected spaces in which every loop that can be filled in has already been accounted for by $\pi_1$, and in which no higher-dimensional holes exist at all. The circle is one. The torus is one. The figure eight is one. So is every surface of genus at least one.

For these spaces the invariant is perfect:

> **Theorem (complete invariance).** Two spaces of type $K(G,1)$ and $K(H,1)$ are equivalent precisely when $G$ and $H$ are isomorphic groups. Moreover, every group $G$ arises: there is a $K(G,1)$ for each one, unique up to equivalence.

This turns topology into algebra with no residue. A statement about the shapes is a statement about the groups, in both directions. It is the sort of dictionary that mathematicians live for, and it is the reason the objects $K(G,1)$ are sometimes described as "groups drawn as spaces."

There is a clean combinatorial way to see this. Package a space's loops-and-paths structure into a *groupoid*: objects are points, arrows are paths up to sliding, every arrow is invertible. In a connected space, any two points are joined by an arrow, and a short argument — choose, once and for all, a path from a basepoint to each other point — collapses the whole groupoid onto the loops at a single point. What remains is exactly the group $\pi_1$, and the collapse is an equivalence. All of the information was in the loops at one point; the rest was bookkeeping.

## Second extreme: the group forgets how a subgroup *sits*

Now change the question. Instead of asking what $\pi_1$ says about a space, ask what it says about the *ways of unrolling* that space.

Unrolling is the notion of a **covering**. A covering of a space $X$ is a space $\tilde X$ with a map to $X$ that looks, over every small patch of $X$, like a stack of disjoint copies of that patch. The number of copies is the *degree*, or number of sheets. Coverings are the geometry of ambiguity: the real line covers the circle by winding infinitely, wrapping $t \mapsto (\cos 2\pi t, \sin 2\pi t)$; the circle covers itself $n$-fold by $z \mapsto z^n$; the sphere double-covers the projective plane by identifying antipodes.

Coverings of a $K(G,1)$ have an entirely algebraic description, and it is the technical heart of everything below. Walk a loop in the base; the sheets of the covering get permuted. This *monodromy* makes the fibre — the set of sheets over a point — into a set acted on by $G = \pi_1$. That is the whole story:

> **Coverings are $G$-sets.** Coverings of a $K(G,1)$ correspond exactly to sets $X$ equipped with an action of $G$. The covering is connected precisely when the action is transitive (any sheet can be carried to any other). In that case, choosing a sheet $x$, the fundamental group of the covering space is the *stabiliser* $\operatorname{Stab}_G(x) = \{g : g\cdot x = x\}$, and the number of sheets is the index of that subgroup in $G$.

So a connected covering of a $K(G,1)$ is again a $K(H,1)$, for $H$ a subgroup of $\pi_1$, and the two are tied together: subgroup of index $n$ $\leftrightarrow$ covering with $n$ sheets.

Here is the surprise. The subgroup $H$ is not just an abstract group in this picture. It is a *subgroup*: it has an address inside $G$. And two subgroups can be abstractly identical while sitting in completely different places.

Consider the Klein four group $V = \mathbb{Z}/2 \times \mathbb{Z}/2$ and the corresponding space $K(V,1)$. Inside $V$ there are exactly three subgroups of order two — the first coordinate axis, the second coordinate axis, and the diagonal $\{(0,0),(1,1)\}$. Each has index two, so each gives a connected *double* covering of $K(V,1)$. Now:

- All three subgroups are isomorphic to $\mathbb{Z}/2$. So **all three covering spaces have the same fundamental group**, and in fact the same homotopy type: each is a $K(\mathbb{Z}/2, 1)$.
- All three coverings have exactly **two sheets**.
- Yet **no two of them are isomorphic as coverings**. There is no way to match up the sheets over the base compatibly with the projection.

The invariant fails, and fails as loudly as it can. The homotopy type of the total space and the number of sheets — everything you can measure by looking at $\tilde X$ alone — are identical, and still the coverings are different. What distinguishes them is not the isomorphism class of $H$ but its *position* in $G$.

This is not a small-group accident. Given **any** group $G$ that admits a surjection $\varphi$ onto $\mathbb{Z}/2$, work over the base $K(G \times \mathbb{Z}/2,\,1)$. Two index-two subgroups present themselves: the "untwisted" one $G \times \{0\}$, and the "twisted" graph $\{(g,\varphi(g)) : g \in G\}$. Both are isomorphic to $G$; both give double coverings whose total spaces are copies of $K(G,1)$; and the two coverings are never isomorphic. Taking $G = S_3$, the symmetric group on three letters, gives the phenomenon over a non-abelian base.

## The correct invariant: not the subgroup, and not its isomorphism class, but its conjugacy class

If equality of abstract fundamental groups is too coarse, is equality of subgroups right? No — it is too *fine*, and the reason is a jewel of the theory.

Take $G = S_3$ acting on three letters. The stabiliser of the letter $0$ and the stabiliser of the letter $1$ are different subgroups of $S_3$ (each of order two, generated by a different transposition). But the transposition swapping $0$ and $1$ conjugates one into the other. And the two three-sheeted coverings they classify are genuinely, unambiguously **isomorphic**: renaming the sheets does the job.

The exact answer is the topological analogue of Galois theory:

> **The Galois correspondence for coverings.** Two connected coverings of a $K(G,1)$, classified by subgroups $H$ and $K$ of $G$, are isomorphic if and only if $H$ and $K$ are *conjugate*: $K = gHg^{-1}$ for some $g \in G$. There is a covering map from the first to the second exactly when $H$ is contained in a conjugate of $K$. And if you insist on matching a chosen sheet to a chosen sheet — a *pointed* isomorphism — then the criterion sharpens to $H = K$ on the nose.

Read together with the two examples, this pins the classification down from both sides. The Klein group shows that isomorphism of fundamental groups is too coarse an equivalence; the symmetric group shows that equality of subgroups is too fine; conjugacy is exactly right. The conjugating element $g$ is precisely the freedom to move the basepoint of the covering along a loop of the base — the ambiguity is geometric, and the algebra records it exactly.

The rest of the classical dictionary falls out of the same picture:

- **Deck transformations.** The symmetries of a covering over a fixed base form its deck group, and it equals $N_G(H)/H$ — the normaliser of $H$ modulo $H$. A covering is *regular* (its deck group shuffles the sheets transitively, so the covering is maximally symmetric) exactly when $H$ is a normal subgroup.
- **The universal cover.** Take $H$ trivial. The covering is simply connected, and its deck group is all of $G$: the space $K(G,1)$ is the quotient of a contractible-in-loops object by a free $G$-action. This is the sense in which every group *is* a symmetry group of an unrolled space.
- **The exact sequence.** For a regular covering with total space a $K(N,1)$ and deck group $Q$, one has $1 \to N \to G \to Q \to 1$. Read backwards: **group extensions are regular coverings**. Any surjection $G \twoheadrightarrow Q$ with kernel $N$ *is* the data of a regular covering of $K(G,1)$ with total space $K(N,1)$ and deck group $Q$.
- **Free groups.** Every connected covering of a $K(F,1)$ with $F$ free again has free fundamental group. Translated out of the covering language, this is the Nielsen–Schreier theorem: *every subgroup of a free group is free.* A theorem about words, proved by unrolling a bouquet of circles.
- **Intersections.** Two coverings can be laid over one another to form their fibre product. Its connected pieces are indexed by the double cosets $H \backslash G / K$, the piece through a given point being classified by $H \cap gKg^{-1}$. The fibre product is connected exactly when $G = HK$.

## Counting the unrollings of a circle and of a doughnut

Abstract classification is satisfying; explicit counts are irresistible.

**The circle.** Here $\pi_1 = \mathbb{Z}$, and every subgroup of $\mathbb{Z}$ is $n\mathbb{Z}$ for a unique $n \ge 0$ — so a subgroup is *determined by its index*. Therefore:

> **Two connected coverings of the circle are isomorphic exactly when they have the same number of sheets**, every number of sheets occurs, and "infinitely many sheets" is the universal cover, the real line spiralling over the circle.

So over the circle, degree is a complete invariant. That is the sharpest possible classification — and, as the Klein four group already showed, it is a privilege of the circle, not a general law.

**The torus.** Here $\pi_1 = \mathbb{Z}^2$, and now degree is far from complete. Counting the connected coverings of degree $n$ means counting the finite-index subgroups (sublattices) of $\mathbb{Z}^2$ of index $n$. Every such sublattice has a unique *normal form*: it is spanned by $(a,0)$ and $(c,d)$ with $a,d>0$, $ad=n$, and $0 \le c < a$. Counting the pairs $(a,c)$ gives one clean formula:

$$\#\{\text{connected } n\text{-sheeted coverings of the torus}\} \;=\; \sum_{a \mid n} a \;=\; \sigma(n).$$

The doughnut has $\sigma(2)=3$ double coverings, $\sigma(3)=4$ triple coverings, $\sigma(4)=7$ quadruple coverings, and for a prime $p$ exactly $p+1$ of degree $p$. And because the base is abelian, conjugation does nothing, so these are pairwise non-isomorphic on the nose — the count is exact, not an upper bound.

The punchline is the failure of $\pi_1$ at full strength. **Every** finite-index subgroup of $\mathbb{Z}^2$ is again isomorphic to $\mathbb{Z}^2$ (it contains $n\mathbb{Z}^2$, so it has rank two, and as a subgroup of a rank-two lattice it has rank at most two). Hence:

> **Every connected finite-sheeted covering of the torus is again a torus.**

There are infinitely many non-isomorphic connected coverings of the torus, $\sigma(n)$ in each degree $n$, and every single total space is a torus. If you were handed the covering space and told only its shape, you would learn nothing at all about which covering you had.

## Double coverings are cohomology classes

One last translation, and perhaps the prettiest. Double coverings are the special case $n=2$, and index-two subgroups are automatically normal. That collapses the conjugacy ambiguity entirely: two double coverings are isomorphic precisely when their subgroups are *equal*.

Better still, an index-two subgroup is the kernel of a unique homomorphism $\varphi : G \to \mathbb{Z}/2$, and a homomorphism into $\mathbb{Z}/2$ is determined by its kernel. So:

> **The connected double coverings of a $K(G,1)$ correspond bijectively to the nonzero homomorphisms $G \to \mathbb{Z}/2$** — that is, to the nonzero classes of the mod-two cohomology group $H^1(G;\mathbb{F}_2)$. The covering attached to $\varphi$ has total space a $K(\ker\varphi, 1)$.

This is why "orientation double cover" and "first Stiefel–Whitney class" are the same idea wearing two hats: a double covering *is* a mod-two character.

For an odd prime $p$ the picture splits in exactly two places, and one can see precisely why. First, a normal subgroup of index $p$ is the kernel of a surjection onto $\mathbb{Z}/p$, but no longer of a *unique* one: rescaling by an automorphism of $\mathbb{Z}/p$ leaves the kernel unchanged, and there are $p-1$ automorphisms, so exactly $p-1$ surjective characters share each kernel. Second, an index-$p$ subgroup need not be normal — but not for free: a non-normal subgroup of prime index $p$ forces $|G|$ to have a prime factor smaller than $p$. At the smallest prime divisor of $|G|$, every subgroup of that index is normal and the character theory is exact. Above it, irregularity can appear, and does: the stabiliser of a point in $S_3$ acting on three letters has index three, is not normal, and is its own normaliser, so the associated three-sheeted covering has a **trivial** deck group despite having three sheets. Both corrections are visible at $p=2$ only in their degenerate forms — $2-1=1$ character per kernel, and no non-normal subgroups at all — which is exactly why the double-covering story is so clean.

## Why the two extremes belong together

It is tempting to read "the fundamental group is a complete invariant" and "the fundamental group is not a complete invariant" as a contradiction, or as a story of an invariant that succeeded and then failed. It is neither. It is a lesson about what an invariant is *for*.

The fundamental group classifies $K(G,1)$ spaces perfectly because those spaces contain no information beyond their loops. It fails to classify their coverings because a covering is not a space — it is a space *together with a map*, and the map remembers where the subgroup lives. The correct invariant is not a group but a group *inside another group*, taken up to the ambiguity of moving a basepoint: the conjugacy class of a subgroup.

Once that is understood, the whole subject organises itself. Subgroups become coverings; normal subgroups become symmetric coverings; the trivial subgroup becomes the universal cover; quotient groups become deck groups; subgroups of free groups become bouquets of circles unrolled; intersections become double cosets; index-two subgroups become mod-two cohomology classes; and sublattices of $\mathbb{Z}^2$ become the $\sigma(n)$ ways of unrolling a doughnut.

The invariant that "fails" is the one that tells you exactly what is going on. That is usually how it goes.
