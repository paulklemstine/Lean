# When a Group *Is* a Space

## The strange afterlife of the fundamental group

Take a shape — a coffee cup, a pretzel, a knotted loop of rope — and ask the simplest topological question you can: what happens if you walk in a circle on it? Start at a point, wander around, come back. Two such round trips are "the same" if you can slide one continuously into the other without leaving the shape and without letting go of the starting point. Compose two trips by doing one after the other. What you get is a group: the **fundamental group** $\pi_1(X,x)$, invented by Poincaré in 1895 and still the first serious invariant every topologist meets.

The fundamental group is a translator. It takes a geometric object and returns an algebraic one. And, like every translator, it loses something. A sphere and a point both have trivial fundamental group, yet a sphere is emphatically not a point. So the natural question — *how much does $\pi_1$ actually remember?* — has an easy pessimistic answer: not everything.

The interesting question is the optimistic one. **Is there a class of spaces for which $\pi_1$ remembers everything?** And if so, can we say precisely, and completely, what the dictionary between geometry and algebra looks like on that class — not just for objects, but for maps between them?

This article is about a complete answer, sharpened at every edge: what the dictionary translates, why it is a perfect translation, exactly how badly it fails the moment you weaken the hypotheses, and what the correct invariant is when it does fail.

## Flattening space: the 1-type

The trick is to throw away everything the fundamental group cannot see, and see what is left.

Imagine a space in which loops can be interesting but *spheres* cannot: any map of a 2-sphere into it can be shrunk to a point, and the same for 3-spheres, 4-spheres, and so on forever. Such a space is called an **aspherical space**, or an **Eilenberg–MacLane space** $K(G,1)$ when its fundamental group is $G$. The circle is one: its fundamental group is $\mathbb{Z}$, and it has no higher structure at all. So is an infinite genus-$g$ surface, so is the space of configurations of $n$ points in the plane (whose fundamental group is the braid group), so is any complete Riemannian manifold with non-positive curvature.

These objects are called **homotopy 1-types**: everything about them lives in dimension $\le 1$. And a 1-type has a perfect finite-dimensional shadow. Instead of the space, keep only:

- its points, and
- the homotopy classes of paths between them.

Paths compose; every path can be run backwards; running a path and then its reverse is the same as standing still. What you have written down is a **groupoid**: a category in which every arrow is invertible. This is the *fundamental groupoid* $\Pi_1(X)$, and for a 1-type it is not merely an invariant — it is a faithful replacement for the space. From this point on we can, and will, do topology by doing algebra.

Two pieces of vocabulary. For an object $c$ of a groupoid $\mathcal{C}$, the arrows from $c$ to itself form a group $\mathrm{Aut}(c)$, the **vertex group** — this is the fundamental group based at $c$. And $\mathcal{C}$ is **connected at $c$** if every object is isomorphic to $c$; this is the algebraic form of path-connectedness. A connected groupoid is exactly a $K(G,1)$ with $G = \mathrm{Aut}(c)$. Finally, the correct notion of "same shape" for groupoids is **equivalence of categories**, which corresponds precisely to homotopy equivalence of spaces.

## The first theorem: shape is group

The starting point of the story, which everything below deepens, is this.

> **Theorem (Classification of connected 1-types).** Two connected groupoids are equivalent if and only if their vertex groups are isomorphic.

So for aspherical spaces, the answer to "how much does $\pi_1$ remember?" is: *all of it*. A group and a connected 1-type are the same information wearing different clothes. The circle is $\mathbb{Z}$. A surface of genus 2 is its (rather complicated) surface group. The braid group *is* the configuration space.

That is a satisfying theorem about *objects*. But mathematics is never only about objects; it is about maps. If a group is a space, what is a homomorphism?

## The second theorem: homomorphism is map, and conjugacy is homotopy

Here is where the dictionary becomes genuinely useful. Two results, and they fit together.

**Realization.** Let $\mathcal{C}$ be a connected 1-type with basepoint $c$, and let $\mathcal{D}$ be any 1-type with a chosen point $d_0$. Then *every* group homomorphism
$$\varphi : \mathrm{Aut}(c) \longrightarrow \mathrm{Aut}(d_0)$$
is induced by an actual map of 1-types. Nothing algebraic is unrealizable: the map $[\,K(G,1), K(H,1)\,] \to \mathrm{Hom}(G,H)$ is surjective.

The construction is disarmingly simple, and worth savouring. Because $\mathcal{C}$ is connected, choose once and for all, for each object $X$, a path $p_X$ from the basepoint $c$ to $X$ (with $p_c$ the constant path). Now any arrow $g : X \to Y$, however far from the basepoint it lives, can be dragged home: the composite
$$\ell(g) \;=\; p_X \cdot g \cdot p_Y^{-1}$$
is a *loop at $c$*, an element of $\mathrm{Aut}(c)$. This "loop-of" operation reverses composition-order bookkeeping in the obvious way and sends identities to the identity. So we may define a functor that crushes every object of $\mathcal{C}$ to the single point $d_0$ and sends the arrow $g$ to $\varphi(\ell(g))$. It is a map of 1-types, and on fundamental groups it is exactly $\varphi$, because a loop at the basepoint is its own dragged-home version. Every homomorphism, realized.

**Homotopy is conjugation.** Realization is surjective, but it is not injective — and the failure is completely understood. When are two maps of 1-types homotopic? The homotopy-theoretic notion of "homotopy between maps" translates into "natural isomorphism between functors", and there is an exact criterion:

> **Theorem (Homotopies are conjugations).** Let $\mathcal{C}$ be connected at $c$, and let $F, G$ be two maps out of $\mathcal{C}$. Then $F$ and $G$ are homotopic if and only if there is a single isomorphism $h : F(c) \to G(c)$ that intertwines the two induced actions of the fundamental group: $F(a) \cdot h = h \cdot G(a)$ for every loop $a$ at $c$.

One direction is a one-liner: a homotopy, evaluated at the basepoint, gives $h$, and naturality is exactly the intertwining. The other direction is the interesting one, and it is where connectedness earns its keep: from the single datum $h$ at the basepoint, one *propagates* the homotopy to all of $\mathcal{C}$ by conjugating with the chosen paths,
$$h_X \;=\; F(p_X)^{-1} \cdot h \cdot G(p_X),$$
and then checks — this is the technical heart — that the result does not depend on which path was chosen, precisely because two choices differ by a loop, and loops are intertwined by hypothesis. Path-independence then upgrades to naturality on the nose.

Specialize this to the two homomorphisms $\varphi, \psi : G \to H$ and their realizations, and the intertwining condition collapses to a single, familiar statement: there exists $u \in H$ with $\psi(a) = u\,\varphi(a)\,u^{-1}$ for all $a$. Conjugacy. So:

> **Theorem (Classification of maps).** For connected 1-types, homotopy classes of maps correspond bijectively to conjugacy classes of homomorphisms:
> $$[\,K(G,1),\,K(H,1)\,] \;\;\cong\;\; \mathrm{Hom}(G,H)\big/\text{conjugation}.$$

There is the dictionary, complete on both objects and morphisms: *spaces are groups, maps are homomorphisms, homotopies are conjugations.* And the dictionary respects composition — the homomorphism induced by a composite of maps is conjugate to the composite of the induced homomorphisms, so the correspondence is an exact identity once one passes to conjugacy classes.

## Counting: how many homomorphisms hide inside one map?

Because the correspondence is a quotient, one can ask a quantitative question: given a homotopy class of maps, how many homomorphisms realize it? The answer is a clean piece of group theory.

Conjugation makes $H$ act on $\mathrm{Hom}(G,H)$, and the homomorphisms realizing a given homotopy class are exactly one orbit. What stabilizes $\varphi$? An element $u$ fixes $\varphi$ precisely when it commutes with every element of the image, i.e. lies in the **centralizer** $C_H(\varphi(G))$. The orbit–stabilizer theorem then gives:

> **Theorem (Fibres of the classification).** The homomorphisms inducing a fixed homotopy class of maps form a coset space $H / C_H(\varphi(G))$; in particular their number equals the index $[H : C_H(\varphi(G))]$.

Two extremes make this vivid. If $\varphi$ is trivial, the centralizer is all of $H$ and the fibre is a single point — the constant map is homotopically rigid. If $\varphi$ is surjective onto a centreless group, the centralizer is the centre of $H$, which is trivial, so the fibre has $|H|$ elements: one full copy of $H$'s worth of homomorphisms, all describing the same map up to homotopy.

## Whitehead's theorem, in one dimension

There is a second classical question the dictionary answers. Suppose a map between spaces induces an isomorphism on fundamental groups. Must it be a homotopy equivalence? In general, no — that is the whole point of higher homotopy. But for 1-types:

> **Whitehead's Theorem for 1-types.** A map between *connected* 1-types which induces an isomorphism on fundamental groups is a homotopy equivalence. Conversely, every homotopy equivalence induces an isomorphism on fundamental groups.

The proof is a pleasing three-step argument, each step a direct translation of a property of $\varphi$:

- **Injectivity on $\pi_1$ makes the map faithful.** Two arrows $f, g : X \to Y$ with the same image have loops-at-the-basepoint with the same image; injectivity forces $\ell(f) = \ell(g)$; conjugating back by the chosen paths recovers $f = g$.
- **Surjectivity on $\pi_1$ makes the map full.** Given a target arrow, drag it home with the chosen paths, pull it back through $\varphi$, and push it out again.
- **Connectedness of the target makes the map essentially surjective**, for free: every object of the target is isomorphic to the image of the basepoint.

Fully faithful plus essentially surjective is exactly an equivalence. It is a genuinely one-dimensional miracle: in this world, $\pi_1$-isomorphism *is* homotopy equivalence.

## Sharpness: what breaks, and how badly

Every hypothesis above deserves a stress test, and the most instructive result in this circle of ideas is a counterexample.

Take two spaces: a single point, and a two-point space with the discrete topology. Their fundamental groups are both trivial. Are they homotopy equivalent? Obviously not — one is connected and the other is not. That much is the familiar warning that connectedness cannot be dropped, and its algebraic shadow is exact: the one-object discrete groupoid and the two-object discrete groupoid have isomorphic (trivial) vertex groups at every basepoint, are not both connected, and are not equivalent.

But the counterexample is far sharper than the $\pi_1$-level statement suggests, and this is the punchline. In a totally disconnected space — one whose only connected subsets are points — *every* higher homotopy group vanishes too. The reason is simple and complete: an $n$-dimensional cube is connected; the continuous image of a connected set is connected; a connected subset of a totally disconnected space is a single point. So every based map of a cube is constant, and $\pi_n$ is trivial for all $n \ge 1$.

Therefore:

> **Theorem (No family of homotopy groups suffices).** The one-point space and the discrete two-point space have isomorphic homotopy groups in *every* degree, yet they are not homotopy equivalent.

This is a much stronger failure than "$\pi_1$ is not a complete invariant". It says that *no* amount of higher homotopy data — the entire infinite tower $\pi_1, \pi_2, \pi_3, \dots$ — can rescue a classification if you refuse to look at the set of connected components. Whitehead's theorem in every dimension is a statement about connected spaces for a reason, and this pair of spaces is the reason.

## The missing invariant, and the complete answer

So what *is* the complete invariant of an arbitrary 1-type, connected or not? The counterexample tells us what is missing — the set of components — and it turns out that this is the only thing missing.

Write $\pi_0(\mathcal{C})$ for the set of isomorphism classes of objects of a groupoid: the algebraic form of "the set of connected components". It is a homotopy invariant, since an equivalence of groupoids induces a bijection on components, and it is a single point exactly when the 1-type is connected. On the opposite extreme, for totally disconnected 1-types — those whose only arrows are identities, all of whose fundamental groups are trivial — the set of components is a *complete* invariant: two such are equivalent precisely when their component sets are in bijection. So $\pi_0$ is exactly the information $\pi_1$ was missing in the extreme case.

The general theorem interpolates between the two extremes, and its proof is a decomposition.

> **Theorem (Decomposition into components).** Every 1-type is equivalent to the disjoint union, over its set of connected components, of the connected 1-types sitting on those components.

One assembles the pieces by the obvious functor from the disjoint union back into the whole; it is faithful because arrows never leave a component, full because a component is a full subgroupoid, and essentially surjective because every object lies in its own component.

> **Theorem (Gluing).** A disjoint union of connected 1-types is determined by its indexing set together with the fundamental groups of the pieces: two such unions are equivalent if and only if there is a bijection of indexing sets under which corresponding fundamental groups are isomorphic.

Here the forward direction uses the fact that objects in different summands are never isomorphic — so an equivalence must permute the summands — while the backward direction glues the component-wise equivalences supplied by the classification of connected 1-types.

Putting the two together gives the theorem the whole story has been building toward.

> **Theorem (Complete invariant for arbitrary 1-types).** Two homotopy 1-types are homotopy equivalent if and only if there is a bijection between their sets of connected components under which the fundamental groups of corresponding components are isomorphic.

The invariant is the pair: $\pi_0$, together with the family of fundamental groups indexed by $\pi_0$. Nothing more; nothing less. The point-versus-two-points counterexample is not a defect in the theory but its boundary condition made visible: those two spaces have the same fundamental groups and different $\pi_0$, and the theorem says that is exactly why they differ.

## Why anyone should care

Beyond the tidiness, this dictionary is a working tool.

Aspherical spaces are everywhere in mathematics. Closed surfaces of genus at least one, configuration spaces of points in the plane, complements of many knots and links, locally symmetric spaces, non-positively curved manifolds, classifying spaces of discrete groups — all are $K(G,1)$'s. For all of them, the results above say that questions about maps, homotopies, and homotopy equivalences are *literally* questions about homomorphisms and conjugacy, which are finite computations when the groups are finite or finitely presented.

Concretely: if $G$ and $H$ are finite groups, the set of homotopy classes of maps between the corresponding aspherical spaces is a finite set that can be enumerated by a computer — list the homomorphisms $G \to H$, group them into conjugation orbits, count. The orbit sizes are not arbitrary; they are indices of centralizers, and they must sum to $|\mathrm{Hom}(G,H)|$. This is the kind of statement one can check, and it is the kind of computation that turns a classification theorem into an algorithm.

There is also a philosophical payoff. Mathematics is full of *bridges*: constructions that turn objects of one kind into objects of another. Most bridges leak. The fundamental group leaks badly in general — that is why homotopy theory is hard. What the results here identify is a precise region in which the bridge does not leak at all: on 1-types, algebra and topology are not merely analogous, they are the same subject in two notations, and the correspondence extends from objects to maps to homotopies between maps, with the failure modes classified exactly. Finding those regions — and marking their borders with counterexamples as sharp as a point versus two points — is a large part of what mathematics is for.
