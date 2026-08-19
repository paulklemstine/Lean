# The Price of Forgetting Where You Started

*How a single marked point turns a fuzzy classification of shapes into an exact one — and why the discrepancy is measured, to the element, by a centraliser.*

## A loop, a starting line, and a nagging ambiguity

Imagine a shape — a doughnut, a knotted tube, a coffee cup — and a piece of string laid on it in a closed loop. You can slide the string around, stretch it, let it wander, but you may not cut it or lift it off the surface. Two loops that can be slid into one another are, for the purposes of topology, the same loop. Collect all these classes of loops together and you get the *fundamental group* of the shape, the single most famous invariant in all of topology.

There is one small piece of bookkeeping in that definition that looks like a technicality and turns out to be the whole story. To multiply two loops — to travel around one and then the other — they must start at the same place. So the fundamental group is not attached to a shape $X$; it is attached to a shape *with a marked point*, a pair $(X, x)$, and it is written $\pi_1(X, x)$.

If the space is connected, mathematicians usually wave this away: move the basepoint from $x$ to $x'$ along a path, and you get an isomorphism $\pi_1(X, x) \cong \pi_1(X, x')$, so "the" fundamental group is well defined. But the wave of the hand hides a real cost. The isomorphism you get depends on the path you chose, and two different paths differ by a loop — that is, by conjugation. The fundamental group of a connected space is well defined only *up to an unspecified isomorphism*, and its self-comparisons are ambiguous by an inner automorphism.

This article is about exactly how much that ambiguity costs, and about the discovery that the cost can be computed on the nose. The answer is a single number attached to each map: **the index of a centraliser**.

## Spaces that are nothing but their loops

To isolate the phenomenon we work with the simplest spaces that have interesting loops and nothing else: the *homotopy $1$-types*, also known as *aspherical spaces* or *Eilenberg–MacLane spaces* $K(G,1)$. A connected space is of this kind if it has a prescribed fundamental group $G$ and no higher structure at all — no two-dimensional holes, no three-dimensional holes, nothing that a sphere of dimension $2$ or more could detect. The circle is one: its fundamental group is $\mathbb{Z}$ and it has nothing else. So is a figure-eight, whose fundamental group is the free group on two generators. So is a surface of genus $2$. So is the infinite-dimensional space built from any group $G$ whatsoever — every group is the fundamental group of some such space, and that space is unique up to homotopy.

For $1$-types there is an algebraic model so faithful that one may as well work with it directly: a **groupoid**. A groupoid is a collection of objects together with invertible arrows between them, composing associatively. Think of the objects as points of a space, and the arrows from $a$ to $b$ as homotopy classes of paths from $a$ to $b$. Composition is concatenation; invertibility is running a path backwards. From a space $X$ this construction — the *fundamental groupoid* — remembers precisely the $1$-type of $X$: its set of connected components, and the fundamental group at each basepoint, glued together by the path structure.

In this language the notions translate beautifully:

- A **connected** groupoid — one where every pair of objects is joined by at least one arrow — is a connected space.
- The arrows from an object $c$ back to itself form a group, the **vertex group** $\operatorname{Aut}(c)$: this is $\pi_1$ at the basepoint $c$.
- A **map** of $1$-types is a functor.
- A **homotopy** between two maps is a natural isomorphism.
- A **homotopy equivalence** is an equivalence of groupoids.
- The model of $K(G,1)$ is the groupoid with a single object $\star$ whose arrows $\star \to \star$ are the elements of $G$, composed by multiplication. Its vertex group is $G$ on the nose.

Everything we say from here on lives in this world, and every statement can be read either as a statement about groupoids or as a statement about aspherical spaces.

## The classical answer, and the fuzz in it

The classical classification of maps between aspherical spaces is a jewel of early algebraic topology. Since such a space is nothing but its fundamental group, a map between two of them should be nothing but a homomorphism of fundamental groups. And so it is — almost.

> **Unpointed Classification Theorem.** Let $X$ be a connected $1$-type with fundamental group $G$ and $Y$ a connected $1$-type with fundamental group $H$. Then homotopy classes of maps $X \to Y$ are in bijection with $\operatorname{Hom}(G, H)/\!\sim$, the set of homomorphisms $G \to H$ modulo conjugation by elements of $H$.

The quotient by conjugation is the fuzz. It is unavoidable in the unpointed world: a map $f : X \to Y$ does not induce a well-defined homomorphism $\pi_1(X) \to \pi_1(Y)$ until you decide where the basepoint goes and how to get back, and different decisions differ by conjugation.

Two irritating consequences follow. First, the classification is not *functorial* in the strict sense. The homomorphism induced by a composite $g \circ f$ is only conjugate to the composite of the induced homomorphisms; there is a conjugating element floating around, and it depends on choices. Second, the classification of self-maps gives the *outer* automorphism group: the homotopy self-equivalences of $K(G,1)$, up to homotopy, form $\operatorname{Out}(G) = \operatorname{Aut}(G)/\operatorname{Inn}(G)$, not $\operatorname{Aut}(G)$. The inner automorphisms have been dissolved. Where did they go?

## Nail down the basepoint and the fuzz vanishes

The remedy is old and obvious: remember the basepoint. What is new is how completely it works, and how precisely one can account for the difference.

Define a **pointed map** $(X,x) \to (Y,y)$ to be a map $F : X \to Y$ *together with* a chosen path $F(x) \rightsquigarrow y$ — in groupoid language, a functor together with a chosen isomorphism $F(x) \cong y$. Define a **pointed homotopy** between two such to be a homotopy $\alpha$ between the underlying maps that is *compatible with the chosen paths*: travelling along $\alpha$ at the basepoint and then along the second chosen path must equal the first chosen path.

Now there is nothing to choose. A pointed map induces a homomorphism of fundamental groups with no arbitrariness at all: conjugate the image of a loop by the chosen path, $a \mapsto p^{-1} \cdot F(a) \cdot p$. Call it $F_\#$.

> **Pointed Classification Theorem.** Let $(X,x)$ be a *connected* pointed $1$-type with fundamental group $G$, and $(Y,y)$ *any* pointed $1$-type — connected or not — with $\pi_1(Y,y) = H$. Then the assignment $F \mapsto F_\#$ is a bijection
> $$[(X,x),(Y,y)]_* \;\xrightarrow{\ \sim\ }\; \operatorname{Hom}(G,H).$$
> Pointed homotopy classes of pointed maps correspond exactly to homomorphisms — no quotient, no conjugation, nothing lost and nothing repeated.

Note what has been dropped: the target need not be connected. Only the source must be, and that is genuinely necessary — a disconnected source can be mapped in ways that no single homomorphism sees.

Two halves make the theorem. That pointed-homotopic maps induce the *same* homomorphism is a computation with the naturality square of the homotopy. The converse is the technical heart of the whole subject, and deserves a name of its own.

> **Prescribed-Homotopy Lemma.** Let $X$ be connected with basepoint $x$, let $F, G : X \to Y$ be maps, and let $h : F(x) \cong G(x)$ be *any* chosen path in the target between the images of the basepoint. Suppose $h$ intertwines the two induced actions of the fundamental group, that is, $F(a) \cdot h = h \cdot G(a)$ for every loop $a$ at $x$. Then there is a homotopy from $F$ to $G$ whose value at the basepoint is exactly $h$.

The proof is a pleasure. Connectedness lets us choose, once and for all, a path $\gamma_P$ from the basepoint $x$ to every point $P$ of $X$. At $P$ we define the homotopy to be the composite
$$F(\gamma_P)^{-1} \cdot h \cdot G(\gamma_P),$$
"travel back to the basepoint in the $F$-picture, cross over by $h$, travel out again in the $G$-picture". Naturality of this recipe is exactly the intertwining hypothesis applied to the loop $\gamma_P \cdot f \cdot \gamma_Q^{-1}$ obtained from an arbitrary arrow $f : P \to Q$ by closing it up through the basepoint. At the basepoint itself the chosen path is trivial, so the value there is $h$ — precisely as demanded.

Earlier accounts of the subject produce *some* homotopy when the induced homomorphisms are conjugate. This lemma produces a homotopy with a *prescribed* value at the basepoint, and that single strengthening is what converts an approximate classification into an exact one.

## Everything becomes strict

With basepoints in place, the algebra snaps into alignment.

**Strict functoriality.** The identity pointed map induces the identity homomorphism, and the composite of pointed maps induces exactly the composite of the induced homomorphisms: $(F \ast G)_\# = G_\# \circ F_\#$, an equality, not a conjugacy. The conjugating elements that obstructed the unpointed theory can all be taken to be the identity.

**A monoid isomorphism.** Pointed homotopy classes of pointed self-maps of $K(G,1)$ form a monoid under composition, and that monoid is isomorphic to $\operatorname{End}(G)$, the full endomorphism monoid of the group. In the unpointed theory the corresponding monoid is the far coarser monoid of *conjugacy classes* of endomorphisms.

**Pointed Whitehead theorem.** A pointed self-map of a connected $1$-type is a homotopy equivalence exactly when the induced endomorphism of the fundamental group is bijective; equivalently, exactly when its class is an invertible element of the monoid above. Consequently the group of pointed homotopy classes of pointed self-homotopy-equivalences of $K(G,1)$ is $\operatorname{Aut}(G)$ — the *full* automorphism group.

So there it is: the inner automorphisms that the unpointed theory dissolved are still present, and they are precisely the pointed self-equivalences that become homotopic to the identity once you forget the basepoint. A map of $K(G,1)$ that "conjugates by $g$" is a genuine, non-trivially-pointed self-map, homotopic to the identity only by a homotopy that drags the basepoint once around the loop $g$.

## Counting the loss exactly

Now the two theories can be compared. Forgetting the basepoint gives a map
$$[(X,x),(Y,y)]_* \longrightarrow [X,Y],$$
which under the two classifications is exactly the quotient map $\operatorname{Hom}(G,H) \to \operatorname{Hom}(G,H)/\text{conjugation}$. Two pointed classes have the same image if and only if the induced homomorphisms are conjugate in $H$. So the fibres of the forgetful map are the conjugation orbits, and orbits of a group action have a size dictated by the orbit–stabiliser theorem. The stabiliser of $\varphi$ under conjugation is the set of $u \in H$ with $u\varphi(g)u^{-1} = \varphi(g)$ for all $g$ — that is, the **centraliser of the image** $C_H(\varphi(G))$.

> **Fibre-Counting Theorem.** Let $(X,x)$ be a connected pointed $1$-type with fundamental group $G$, and $(Y,y)$ a pointed $1$-type with $\pi_1(Y,y) = H$. Over the unpointed homotopy class of a map inducing $\varphi : G \to H$, the fibre of the forgetful map has exactly
> $$\bigl[\,H : C_H(\varphi(G))\,\bigr]$$
> elements — the index in $H$ of the centraliser of the image of $\varphi$. The count is uniform: it depends only on $\varphi$, not on the space, the model, or the choice of basepoint.

Two extreme cases sharpen the picture.

**When $\varphi$ is the identity**, the image is all of $G$ and its centraliser is the centre $Z(G)$, so the fibre over the identity class has $[G : Z(G)] = |\operatorname{Inn}(G)|$ elements. This is the arithmetic underneath the slogan "$\operatorname{Aut}$ versus $\operatorname{Out}$": the group $\operatorname{Aut}(G)$ of pointed self-equivalence classes surjects onto the group $\operatorname{Out}(G)$ of unpointed ones with kernel of order $[G:Z(G)]$.

**When $H$ is abelian**, conjugation is trivial, every centraliser is everything, and every fibre is a single point. For a target with abelian fundamental group — $K(\mathbb{Z}/n,1)$, a torus, a circle — the basepoint carries no information whatsoever, and the pointed and unpointed classifications coincide. This is why the ambiguity is invisible in the classical examples that everybody meets first: covering spaces of the circle, degrees of maps of tori. Non-commutativity is precisely what makes the basepoint matter.

## The decisive experiment: $S_3$ and the numbers $1, 3, 6$

An abstract count is convincing only when you can watch it happen. The smallest non-abelian group is $S_3$, the symmetry group of a triangle, of order $6$ and with trivial centre. Take $X = Y = K(S_3, 1)$ and ask for all self-maps.

There are exactly $10$ homomorphisms $S_3 \to S_3$: the trivial one; three maps whose image is a two-element subgroup generated by a transposition (they factor through the sign homomorphism $S_3 \to \{\pm 1\}$, and then embed $\{\pm 1\}$ as one of the three transposition subgroups); and six automorphisms, all inner because $\operatorname{Out}(S_3)$ is trivial. Under conjugation these $10$ homomorphisms fall into exactly $3$ orbits, and the theorem predicts their sizes as centraliser indices:

| unpointed class | representative $\varphi$ | image | $C_{S_3}(\operatorname{im}\varphi)$ | fibre size |
|---|---|---|---|---|
| constant map | trivial | $\{1\}$ | all of $S_3$, order $6$ | $6/6 = 1$ |
| sign-and-swap | $g \mapsto \tau^{\operatorname{sgn}(g)}$ | $\{1, \tau\}$ | $\{1,\tau\}$, order $2$ | $6/2 = 3$ |
| identity | $\mathrm{id}$ | $S_3$ | $Z(S_3) = \{1\}$ | $6/1 = 6$ |

And $1 + 3 + 6 = 10$, as it must be. Each of these three predictions is a theorem in its own right:

- **One pointed class over the constant map.** The centraliser of the trivial image is the whole group.
- **Three pointed classes over the sign-and-swap map.** The centraliser of $\{1,\tau\}$ has order $2$.
- **Six pointed classes over the identity.** Because $S_3$ has trivial centre, $[S_3 : Z(S_3)] = 6$: the identity map of $K(S_3,1)$ has *six* pairwise non-pointed-homotopic pointed representatives, corresponding to the six inner automorphisms — all of them homotopic to one another the instant the basepoint is released.

The last line is the one worth pausing over. Here is a space whose identity map, the most trivial map imaginable, has six essentially different pointed forms. They are indistinguishable by any unpointed observation. They are distinguished by nothing more exotic than the record of where a single marked point travelled.

## Why this is worth caring about

The distinction between pointed and unpointed maps is not a bureaucratic nicety. It is the mechanism behind several phenomena that otherwise seem unrelated.

*Covering spaces.* The classification of connected coverings of a nice space $X$ by subgroups of $\pi_1(X,x)$ is a pointed statement. Unpointed, you classify coverings only up to conjugacy of subgroups — the same conjugation ambiguity, the same centraliser controlling how many pointed coverings sit over one unpointed one.

*Group cohomology and extensions.* Group extensions and their classification by cohomology are the algebraic shadow of maps of $K(G,1)$'s. The passage from $\operatorname{Aut}$ to $\operatorname{Out}$ — the very passage measured here by $[G : Z(G)]$ — is what makes the theory of extensions with non-abelian kernel subtle: an extension determines an outer action, and lifting it to an honest action is obstructed.

*Fibre bundles and gauge theory.* A bundle is classified by a map to a classifying space; changing the reference frame at a point conjugates the classifying data. "Global gauge transformations" are exactly the group $H$ acting by conjugation in the theorem above, and the centraliser of the image of a holonomy homomorphism is the *stabiliser* of a gauge field — physically, the unbroken subgroup. The number $[H : C_H(\varphi(G))]$ is the number of distinct frames, an orbit of a symmetry group.

*Computation.* Because the count is purely group-theoretic, it is decidable for finite groups by enumeration and, better, is a one-line consequence of orbit–stabiliser whenever the centraliser can be computed. There is no topology to do; the entire homotopy-theoretic question has been reduced to a subgroup index.

## The moral

Topologists say that a basepoint is a technical convenience. This is true in the sense that a coordinate system is a technical convenience: you can do without it, but the price is that everything you compute is defined only up to an unspecified change of coordinates. Here the change of coordinates is conjugation, and the price is exactly quantified.

Remember the basepoint and the theory becomes rigid: homotopy classes are homomorphisms, composition is composition, self-equivalences are automorphisms. Forget it and the theory becomes flexible but blurred: homotopy classes are conjugacy classes of homomorphisms, composition holds only up to a conjugator, self-equivalences are outer automorphisms. Between the two lies a fibration of finite sets whose every fibre has size the index of a centraliser — the exact, computable, elementwise measure of what forgetting costs.

For a space with abelian fundamental group the cost is nothing. For $K(S_3,1)$ it is $1$, $3$ and $6$.
