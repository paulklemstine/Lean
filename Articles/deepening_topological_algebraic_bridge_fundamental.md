# The Shape of a Group

## What a space remembers when you forget almost everything

Imagine you are handed a rubber shape and told you may stretch it, bend it, and squash it, but never tear or glue. Two shapes that can be deformed into one another this way are, for a topologist, *the same*. This is a brutal kind of forgetting: a coffee cup and a doughnut become indistinguishable, a solid ball becomes a point, and every question about distance, angle, and curvature evaporates.

What survives the forgetting? The most famous survivor is the **fundamental group**. Pick a point $x$ in a space $X$ and consider all the loops that start and end at $x$. Two loops count as equal if one can be slid continuously into the other. You can compose loops — run around the first, then the second — and every loop can be run backwards, so these loop-classes form a group, written $\pi_1(X,x)$. For a circle, the loops are classified by how many times you wind around, so $\pi_1(S^1) \cong \mathbb{Z}$. For a doughnut surface (a torus), you can wind around the hole and around the tube independently, so $\pi_1(T^2) \cong \mathbb{Z}^2$.

The fundamental group is a beautiful invariant, but on its own it is far from a complete one: a sphere and a point both have trivial fundamental group, yet nobody would call them the same. So here is the question this article is about:

> **For which spaces is the fundamental group the whole story — and once we know it is, what exactly does the group tell us?**

The answer turns out to be startlingly complete, and it converts topology into pure algebra with no residue.

---

## Homotopy $1$-types: spaces with nothing above dimension one

The right class of spaces is the class of **homotopy $1$-types**: spaces whose only interesting topology lives in dimension one. Concretely, all higher homotopy groups $\pi_2, \pi_3, \dots$ vanish. A connected homotopy $1$-type with fundamental group $G$ is called an **Eilenberg–MacLane space** $K(G,1)$, or an *aspherical* space. Such a space exists for every group $G$ and is unique up to deformation. Examples are everywhere:

- the circle is a $K(\mathbb{Z},1)$;
- the $n$-dimensional torus is a $K(\mathbb{Z}^n,1)$;
- the infinite-dimensional lens space is a $K(\mathbb{Z}/n,1)$;
- every closed surface of genus $\ge 1$ is aspherical;
- a bouquet of $k$ circles is a $K(F_k,1)$ for the free group $F_k$.

There is a marvellously economical way to think about a homotopy $1$-type: as a **groupoid**. A groupoid is a small category in which every arrow is invertible. Given a space, take its points as objects and its homotopy classes of paths as arrows; composition is concatenation, and every path can be reversed. Under this dictionary:

- the **objects** of the groupoid are the points of the space;
- the **connected components** of the groupoid are the path components, i.e. $\pi_0$;
- the **arrows from $x$ to itself**, i.e. the automorphism group $\mathrm{Aut}(x)$, are exactly $\pi_1(X,x)$;
- a **continuous map** becomes a functor, and a **homotopy** between maps becomes a natural isomorphism between functors.

So a $K(G,1)$ is just a *connected groupoid whose vertex group is $G$* — and the very simplest one has a single object $\star$ with arrow set $G$. That tiny gadget, a group viewed as a one-object groupoid, is a perfectly good stand-in for an infinite-dimensional lens space. Everything below is carried out in this language, where a "space" is a groupoid, a "map" is a functor, and "homotopic" means "naturally isomorphic".

The first pillar is the classification of objects and maps:

> **Classification of $1$-types.** A connected homotopy $1$-type is determined up to homotopy equivalence by its fundamental group: two connected $1$-types are equivalent if and only if their fundamental groups are isomorphic. Moreover, for connected $1$-types the homotopy classes of maps are
> $$[K(G,1),\,K(H,1)] \;\cong\; \mathrm{Hom}(G,H)/\text{conjugation}.$$

That last formula is worth savouring. A map between aspherical spaces is nothing but a homomorphism of fundamental groups, and two homomorphisms give homotopic maps exactly when they differ by conjugation in the target — the conjugation is the residue of not having chosen where the basepoint goes. Topology has been replaced, exactly and without loss, by group theory.

---

## Counting the symmetries of a space

Once you know what all maps $X \to X$ look like, you can ask the natural next question: what are the **self-symmetries** of $X$ up to homotopy? Compose two self-maps and you get a self-map; homotopy classes therefore form a *monoid* $[X,X]$, and inside it sits the group $\mathrm{hAut}(X)$ of invertible classes, the **homotopy self-equivalences**. This group is a genuinely subtle invariant — for honest spaces it is usually very hard to compute.

For $1$-types it is completely computable. Composing the classification formula with itself gives:

> **The self-map monoid.** For a connected $1$-type $X$ with $\pi_1 = G$, the monoid of homotopy classes of self-maps is isomorphic to the monoid of conjugacy classes of endomorphisms of $G$, with composition induced by composition of homomorphisms.

> **Invertibility criterion (a Whitehead-type statement).** A homotopy class of self-maps of a $1$-type is invertible in the monoid $[X,X]$ if and only if it is represented by an honest homotopy equivalence.

> **The symmetry theorem.** For a connected $1$-type $X$ with $\pi_1 = G$,
> $$\mathrm{hAut}(X)\;\cong\;\mathrm{Out}(G)\;=\;\mathrm{Aut}(G)/\mathrm{Inn}(G).$$

Here $\mathrm{Inn}(G)$ is the group of *inner* automorphisms $g \mapsto aga^{-1}$; the quotient $\mathrm{Out}(G)$ is the group of **outer** automorphisms. Inner automorphisms disappear because conjugating a homomorphism does not change the homotopy class of the corresponding map — geometrically, an inner automorphism is realised by dragging the basepoint around a loop, which is a homotopy, not new symmetry.

There is one more layer. Symmetries of a space form not just a group but a *$2$-group*: not only can two self-maps be equal up to homotopy, but two homotopies can be equal up to a higher homotopy. The bottom layer of this $2$-group is $\mathrm{hAut}$; the top layer consists of self-homotopies of the identity map. Those, too, are pinned down exactly:

> **Self-homotopies of the identity.** The self-homotopies of the identity map of a connected $1$-type with fundamental group $G$ form the **centre** $Z(G)$.

So the entire automorphism $2$-group of an aspherical space is $(\mathrm{Out}\,G,\; Z(G))$: outer automorphisms on the bottom, the centre on top. The two most classical "defects" of a group — the failure of automorphisms to be inner, and the failure of the group to be centreless — are precisely the two layers of symmetry of its space.

---

## The theorem in action

The strength of a general theorem is measured by what it computes.

**The circle.** $\pi_1(S^1) = \mathbb{Z}$, and every endomorphism of $\mathbb{Z}$ is multiplication by an integer $d$. Since $\mathbb{Z}$ is abelian, conjugation does nothing, and the monoid of self-maps of the circle is the multiplicative monoid $(\mathbb{Z},\cdot)$ — the classical **degree**. Two self-maps of the circle are homotopic exactly when they have the same degree; a self-map is an equivalence exactly when its degree is $\pm 1$. Hence $\mathrm{hAut}(S^1) \cong \mathbb{Z}/2$: the identity and the reflection. Two symmetries, no more.

**The torus.** $\pi_1(T^n) = \mathbb{Z}^n$ is abelian, so $\mathrm{Out} = \mathrm{Aut}$, and automorphisms of $\mathbb{Z}^n$ are invertible integer matrices:
$$\mathrm{hAut}(T^n)\;\cong\;\mathrm{GL}_n(\mathbb{Z}).$$
For $n=1$ this is $\{\pm 1\}$, recovering degree $\pm 1$; for $n = 2$ it is the classical statement that self-equivalences of the two-torus are classified by $2 \times 2$ integer matrices of determinant $\pm 1$ — the very matrices that govern continued fractions, the modular group, and Anosov diffeomorphisms.

**Lens spaces and Euler's totient.** Take $G = \mathbb{Z}/n$. Again abelian, so $\mathrm{hAut} = \mathrm{Aut}(\mathbb{Z}/n)$, and an automorphism is multiplication by a unit mod $n$. Therefore

> **The totient theorem.** The infinite lens space $K(\mathbb{Z}/n,1)$ has homotopy self-equivalence group isomorphic to the unit group $(\mathbb{Z}/n)^{\times}$, and hence exactly
> $$\#\,\mathrm{hAut}\bigl(K(\mathbb{Z}/n,1)\bigr) \;=\; \varphi(n)$$
> homotopy classes of self-homotopy-equivalences, where $\varphi$ is Euler's totient function.

This is a genuine bridge: a purely homotopy-theoretic count is answered by the most elementary function in number theory. For $n = 1$ and $n = 2$ the count is $1$: those spaces are **homotopy rigid**, admitting no symmetry at all beyond the identity. For $n=5$ the count is $4$. For a prime $p$ it is $p-1$. And because $\varphi$ oscillates wildly — $\varphi(30) = 8$ while $\varphi(31) = 30$ — the symmetry group of $K(\mathbb{Z}/n,1)$ leaps up and down with $n$ in a way no coarse topological reasoning would predict.

**Rigidity without triviality.** One might guess that a space with lots of loops has lots of symmetry. Not so. Take $G = S_3$, the symmetric group on three letters: nonabelian, of order $6$. Every automorphism of $S_3$ is inner, so $\mathrm{Out}(S_3) = 1$; and $Z(S_3) = 1$. Therefore $K(S_3,1)$ is **completely rigid**: its only self-homotopy-equivalence is the identity, and the identity has no nontrivial self-homotopy. A space with a nonabelian fundamental group can be perfectly stiff.

**Nonabelian symmetry.** Contrast the Klein four group $V = (\mathbb{Z}/2)^2$. It is abelian with trivial inner automorphisms, so $\mathrm{hAut}(K(V,1)) \cong \mathrm{Aut}(V)$, which permutes the three nonidentity elements arbitrarily and therefore has order $6$ and is *nonabelian*. So the symmetry group of a space with an abelian fundamental group can itself be nonabelian.

---

## Breaking the space into pieces

All of the above assumed connectedness. What if the space falls apart into pieces? Every $1$-type is the disjoint union of its connected components, so this is the last thing to understand, and the answer completes the picture.

Two extremes are easy to imagine. If all the pieces are points — a totally disconnected $1$-type, all fundamental groups trivial — then a self-map is just a function on the set of components, and

> the monoid of self-maps is the full transformation monoid of $\pi_0$, and $\mathrm{hAut}$ is the **symmetric group** $\mathrm{Sym}(\pi_0)$.

Pure combinatorics. At the other extreme a connected space contributes only $\mathrm{Out}(\pi_1)$ — pure algebra. The general case has to interpolate, and it does so through a *matrix* description. Here is the idea. A map out of a connected space cannot split: its image is connected, so it lands inside a single component of the target. Consequently a self-map of $\bigsqcup_i C_i$ consists of

1. a rule $\sigma$ saying which component each component goes to, and
2. for each $i$, a homotopy class of maps $C_i \to C_{\sigma(i)}$.

That is precisely a *matrix* with one nonzero entry per column, and composition multiplies these matrices. Formally:

> **Matrix description of self-maps.** For an arbitrary family $(C_i)_{i \in \iota}$ of connected $1$-types, the monoid of homotopy classes of self-maps of $\bigsqcup_i C_i$ is isomorphic to the monoid of pairs $\langle \sigma, P\rangle$ with $\sigma : \iota \to \iota$ and $P_i \in [C_i, C_{\sigma(i)}]$, multiplied by
> $$\langle \sigma,P\rangle \cdot \langle \tau, Q\rangle = \bigl\langle \sigma\circ\tau,\; i \mapsto Q_i \text{ followed by } P_{\tau(i)}\bigr\rangle .$$

Restricting to the invertible elements gives the structure theorem. A self-equivalence permutes the components, so there is a homomorphism $\mathrm{hAut}\bigl(\bigsqcup_i C_i\bigr) \to \mathrm{Sym}(\pi_0)$, and both its image and its kernel can be identified exactly:

> **Structure of the symmetry group of a disconnected $1$-type.** The sequence
> $$1 \longrightarrow \prod_i \mathrm{Out}\bigl(\pi_1 C_i\bigr) \longrightarrow \mathrm{hAut}\Bigl(\bigsqcup_i C_i\Bigr) \longrightarrow \mathrm{Sym}'(\pi_0) \longrightarrow 1$$
> is exact, where $\mathrm{Sym}'(\pi_0)$ is the group of those permutations $\sigma$ of the components for which $C_i$ is homotopy equivalent to $C_{\sigma(i)}$ for every $i$. Moreover the self-homotopies of the identity form $\prod_i Z(\pi_1 C_i)$.

In words: **a symmetry of a disconnected space is a shuffle of look-alike pieces followed by an internal symmetry of each piece**, and nothing else. Only pieces of the same homotopy type can be interchanged — a topological version of the obvious statement that you may only swap identical parts.

Both extremes drop out. If every piece is a copy of the same $K(G,1)$, every permutation is achievable and the extension splits into a **wreath product**
$$\mathrm{hAut}\Bigl(\bigsqcup_{i \in \iota} K(G,1)\Bigr) \;\cong\; \mathrm{Out}(G) \wr \mathrm{Sym}(\iota) \;=\; \bigl(\iota \to \mathrm{Out}(G)\bigr) \rtimes \mathrm{Sym}(\iota),$$
of order $|\mathrm{Out}(G)|^n \cdot n!$ for $n$ copies. If, on the other hand, no two pieces are equivalent, no permutation is achievable and the answer collapses to the plain product $\prod_i \mathrm{Out}(\pi_1 C_i)$.

Two concrete illustrations pin down the extremes. Take the disjoint union of a circle and an infinite lens space with fundamental group $\mathbb{Z}/3$. Their fundamental groups are $\mathbb{Z}$ and $\mathbb{Z}/3$, one infinite and one finite, so the two pieces have *different homotopy types* and cannot be swapped. Each piece has exactly two symmetries ($\mathrm{Out}(\mathbb{Z}) = \{\pm 1\}$, and $\varphi(3) = 2$), so

> the space $K(\mathbb{Z},1) \sqcup K(\mathbb{Z}/3,1)$ has exactly $2 \times 2 = 4$ homotopy classes of self-homotopy-equivalences, none of which moves a component.

Contrast three copies of the rigid space $K(S_3,1)$: each copy has *no* internal symmetry, but the copies are interchangeable, so the symmetry group is exactly $\mathrm{Sym}(3)$, of order $6$ — all symmetry is relabelling. And two copies of $K(V,1)$ for the Klein four group have $6^2\cdot 2 = 72$ symmetries, mixing both sources.

---

## Why it matters

There is a moral here that runs deeper than the individual computations. Aspherical spaces are the exact place where topology and group theory become the same subject. The dictionary is complete in every direction: spaces ↔ groups, maps ↔ homomorphisms up to conjugacy, symmetries ↔ outer automorphisms, higher symmetries ↔ centres, components ↔ index sets, and disjoint unions ↔ matrix and wreath constructions. Nothing is lost in translation, and everything is computable in principle from a presentation of the groups involved.

This is why aspherical spaces are the natural home of some of the hardest open problems in topology — the Borel conjecture, the Farrell–Jones conjecture, geometric group theory as a whole. When a space is aspherical, all of its topology is encoded in a group, and questions about the space become questions about the group. What the results above make precise is the *homotopy-theoretic* half of that program, in complete generality: not just which spaces are classified by their fundamental groups, but exactly how many symmetries they have, which symmetries mix which pieces, and how the higher structure sits on top.

And along the way, the count of symmetries of an infinite lens space turned out to be Euler's totient function. It is a small thing, but it is exactly the sort of small thing that tells you the dictionary is real: ask a question about rubber shapes, and receive an answer from elementary number theory.
