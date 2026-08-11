# The Monoid of All Binary Operations, and the Shadow It Casts

## A multiplication table for multiplication tables

Take a set $X$ — the numbers $\{0,1\}$, the residues mod $7$, the words of a language, whatever you like. A *binary operation* on $X$ is nothing more than a rule that eats two elements and spits out a third: a function $f : X \times X \to X$. Addition is one. Subtraction is another. So is "return the first argument and ignore the second", and so are the $16$ different multiplication tables you can scribble on a $2 \times 2$ grid with entries in $\{0,1\}$.

There are a *lot* of these. On an $n$-element set there are exactly $n^{n^2}$ binary operations: four on a one-element set is one, sixteen on two elements, and a staggering $19{,}683$ on three. A set with a binary operation and no further axioms is called a **magma** — the most primitive algebraic object there is, algebra stripped of associativity, identity, commutativity, everything.

Here is the twist that turns this zoo into a subject. In 2008, H. S. Kim and J. Neggers observed that the collection of *all* binary operations on a fixed set is itself an algebraic object: you can multiply two binary operations and get a third. The recipe is

$$(f * g)(a,b) \;=\; g\bigl(f(a,b),\, f(b,a)\bigr).$$

Read it slowly. To compute $f * g$ at the pair $(a,b)$, you first run $f$ on the pair **both ways round** — forwards to get $f(a,b)$, backwards to get $f(b,a)$ — and then feed those two outputs to $g$. It is a strange-looking rule, and the first surprise is that it works: $*$ is associative, and it has an identity, namely the *left projection* $\ell(a,b) = a$. Indeed $(\ell * g)(a,b) = g(a,b)$ and $(f * \ell)(a,b) = f(a,b)$.

So the set of all binary operations on $X$ becomes a monoid — call it $\mathrm{Bin}(X)$, the **magma monoid**. Every conceivable algebra on $X$, from group laws to nonsense tables, is a single point in this monoid, and the monoid's internal structure encodes relationships between them.

This article is about what that structure actually looks like, and about one clean idea that explains almost all of it.

## The unfolding trick

The definition of $*$ looks arbitrary until you unfold it. To each operation $f$ associate a map on **pairs**:

$$\widehat{f} : X \times X \to X \times X, \qquad \widehat{f}(a,b) = \bigl(f(a,b),\, f(b,a)\bigr).$$

Instead of throwing away $f(b,a)$, we keep it. Now compute:

$$\widehat{f * g}(a,b) = \bigl((f*g)(a,b),\, (f*g)(b,a)\bigr) = \bigl(g(f(a,b), f(b,a)),\, g(f(b,a), f(a,b))\bigr) = \widehat{g}\bigl(\widehat{f}(a,b)\bigr).$$

The exotic product has become **composition**: $\widehat{f * g} = \widehat{g} \circ \widehat{f}$. The magma monoid is a monoid of transformations of $X \times X$ in disguise, with the order of multiplication reversed.

Which transformations? Write $\sigma(a,b) = (b,a)$ for the *reversal* of a pair. Then $\widehat{f}(\sigma(a,b)) = (f(b,a), f(a,b)) = \sigma(\widehat{f}(a,b))$: every $\widehat f$ commutes with reversal. Conversely, any map $T : X\times X \to X \times X$ commuting with $\sigma$ is $\widehat f$ for the operation $f(a,b) = $ first coordinate of $T(a,b)$, and $f$ is recovered uniquely. This is the **Representation Theorem**:

> **Theorem (Representation).** The magma monoid $\mathrm{Bin}(X)$ is anti-isomorphic to the centralizer of the reversal involution $\sigma$ inside the monoid of *all* self-maps of $X \times X$. Explicitly, $f \mapsto \widehat f$ is a bijection onto $\{T : T\sigma = \sigma T\}$ with $\widehat{f*g} = \widehat g \circ \widehat f$.

Everything below is the systematic exploitation of this one sentence. The magma monoid is a *symmetry-constrained transformation monoid*: transformations of the square $X \times X$ that respect the mirror reflection across the diagonal.

And the diagonal is where the drama is.

## The diagonal obstruction

In semigroup theory, the single most important local property of an element $f$ is **regularity**: does there exist $g$ with $f * g * f = f$? Such a $g$ is a *pseudo-inverse* — not an inverse, but a partial undoing, enough to make $f$ behave like a projection. Regularity is the backbone of the structure theory of finite semigroups.

For the monoid of *all* self-maps of a set, regularity is free: every map is regular. Pick a preimage for each point in the image, and you are done. Since $\mathrm{Bin}(X)$ sits inside such a monoid, one might expect the same. It fails, and the failure is beautiful.

The catch is that the pseudo-inverse must itself be a binary operation — that is, it must be a map on pairs *commuting with reversal*. And a reversal-commuting map sends the diagonal $\Delta = \{(x,x)\}$ into the diagonal: if $p = \sigma(p)$ then $T(p) = T(\sigma p) = \sigma(T p)$. So if you need to invert $\widehat f$ at a diagonal point, you must find a **diagonal** preimage. Off the diagonal you may choose freely, transporting your choice across the reflection; on the diagonal your hands are tied.

Which values of $f$ land on the diagonal? Exactly the *commutative values*: $\widehat f(a,b) = (f(a,b), f(b,a))$ lies on the diagonal precisely when $f(a,b) = f(b,a)$. And which values come from the diagonal? Those of the form $f(z,z)$. So:

> **Theorem (Regularity criterion).** A binary operation $f$ on $X$ is regular in the magma monoid if and only if every commutative value of $f$ is attained on the diagonal:
> $$\forall x, y \in X: \quad f(x,y) = f(y,x) \;\Longrightarrow\; \exists z \in X: \; f(z,z) = f(x,y).$$

This is a wonderfully cheap test. It replaces a quantifier over all $n^{n^2}$ candidate pseudo-inverses by a condition you can check by scanning the multiplication table.

Run it on the sixteen operations on $\{0,1\}$. Fourteen pass. Two fail — and they are exactly $\mathrm{XOR}$ and its negation $\mathrm{XNOR}$. Look at $\mathrm{XOR}$: it is commutative, so *every* value is a commutative value; but its diagonal is $0 \oplus 0 = 1 \oplus 1 = 0$, so the value $1$ is a commutative value never attained on the diagonal. There is no way to undo $\mathrm{XOR}$ within the world of binary operations. In particular, since $|X| \ge 2$ always supplies such an example (take $f(x,y) = a$ if $x = y$ and $b$ otherwise, with $a \neq b$):

> **Theorem.** $\mathrm{Bin}(X)$ is *not* a regular monoid whenever $X$ has at least two elements — even though the ambient transformation monoid of $X \times X$ is.

Worse (or better): the regular elements do not even form a submonoid. On $\{0,1\}$ there are two regular operations whose product is $\mathrm{XOR}$. Regularity is a genuinely local, fragile property here, not a subalgebra.

## Everything is a stabilizer

The diagonal argument feels special to reflections. It isn't. Strip it to the bone: $X \times X$ is a set acted on by a two-element group (generated by $\sigma$); binary operations are the equivariant self-maps; the diagonal is the set of points with non-trivial stabilizer. Read that way, the criterion generalizes to arbitrary symmetry:

> **Theorem (Equivariant regularity).** Let a group $G$ act on a set $Y$, and let $T$ be a $G$-equivariant self-map of $Y$. Then $T$ has a pseudo-inverse *among $G$-equivariant maps* if and only if every point $y$ in the image of $T$ has a preimage $z$ whose stabilizer contains the stabilizer of $y$.

The proof is an exercise in equivariant choice: pick one representative in each $G$-orbit of the image, choose a preimage with a large enough stabilizer, and transport it around the orbit by the group action. The stabilizer hypothesis is exactly the compatibility needed for the transport to be well defined — otherwise two group elements moving the representative to the same point would send the chosen preimage to two different places.

Two corollaries fall out immediately. If $G$ is trivial, we recover the classical fact that every self-map is regular. If $G$ acts *freely* on the image — no point is fixed by a non-identity element — then every equivariant map is regular. All obstruction lives at the fixed points. The magma monoid's diagonal is just the fixed-point set of the reflection, and the whole non-regularity of $\mathrm{Bin}(X)$ is the price of one mirror.

## Sorting the operations: Green's relations

Semigroup theorists organize a monoid by *divisibility*. Say $f$ and $g$ generate the same left ideal — each is a left multiple of the other — and you call them $\mathcal{L}$-equivalent; same for right multiples ($\mathcal{R}$), their intersection ($\mathcal{H}$), and the composite $\mathcal{D} = \mathcal{L} \circ \mathcal{R}$. These *Green's relations* are to a semigroup what conjugacy classes are to a group. For the magma monoid the unfolding trick computes them all.

Write $\mathrm{Im}(f) = \widehat f(X\times X)$ for the image of the unfolded map, and $\mathrm{Diag}(f) = \{(f(z,z), f(z,z)) : z \in X\}$ for its *diagonal image*.

> **Theorem (Green's relations).** For binary operations $f, g$ on $X$:
> - $f \mathrel{\mathcal{L}} g$ if and only if $\mathrm{Im}(f) = \mathrm{Im}(g)$ **and** $\mathrm{Diag}(f) = \mathrm{Diag}(g)$;
> - $f \mathrel{\mathcal{R}} g$ if and only if $\widehat f$ and $\widehat g$ have the same kernel, i.e. $\widehat f(p) = \widehat f(q) \iff \widehat g(p) = \widehat g(q)$;
> - $f \mathrel{\mathcal{D}} g$ if and only if some reversal-commuting map carries $\mathrm{Im}(g)$ bijectively onto $\mathrm{Im}(f)$ and $\mathrm{Diag}(g)$ onto $\mathrm{Diag}(f)$.

In the full transformation monoid the answers are the classical "same image", "same kernel", "same image size". Here each statement acquires a diagonal decoration — and only the left/image side does. The $\mathcal{R}$-criterion is exactly the classical one, because factoring *through* a map can be done equivariantly for free (outside the image you extend by the identity, which is already equivariant), whereas factoring *into* a map requires diagonal preimages.

Because the $\mathcal{D}$-criterion matches diagonal images with diagonal images, the diagonal obstruction is transported along $\mathcal{D}$: **regularity is constant on $\mathcal{D}$-classes**, hence on $\mathcal{L}$- and $\mathcal{R}$-classes. The two non-regular operations on a two-element set form a union of $\mathcal{D}$-classes. And, as in the general theory, an element is regular precisely when it is $\mathcal{L}$-equivalent (equivalently $\mathcal{R}$-equivalent) to an idempotent.

## Who commutes with everything? Almost nobody

Two operations are visibly special: the left projection $\ell(a,b) = a$, which is the identity of the monoid, and the **right projection** $r(a,b) = b$. A quick check gives $r * g = g * r$ for all $g$, and $r * r = \ell$: the right projection is a central involution. Are there others?

> **Theorem (Centre).** If $X$ has at least two elements, the centre of $\mathrm{Bin}(X)$ is exactly $\{\ell, r\}$, a group of order two.

The proof is a lovely piece of clone theory. Suppose $f$ is central. Test it against constant operations $c(a,b) = c$: centrality forces $f(c,c) = c$ for every $c$, so $f$ is *diagonally idempotent*. Now test it against the operations $(a,b) \mapsto h(a)$ for an arbitrary self-map $h$ of $X$: centrality forces

$$h(f(a,b)) = f(h(a), h(b)) \quad \text{for all } a,b,h.$$

In words: *every* self-map of $X$ is a homomorphism of the magma $(X, f)$. That is an enormously rigid demand. Pick two distinct points $a \neq b$ and the map $h$ that sends $b$ to $a$ and fixes everything else; the identity above collapses to $h(f(a,b)) = f(a,a) = a$, which forces $f(a,b) \in \{a, b\}$. Then transporting via the map sending $a \mapsto c$, $b \mapsto d$ shows that the same choice is made everywhere: either $f$ is the left projection throughout, or the right projection throughout. Out of $n^{n^2}$ operations, exactly two are central.

## Counting the invertible operations

An operation $f$ is invertible in $\mathrm{Bin}(X)$ exactly when the unfolded map $\widehat f$ is a **bijection** of $X \times X$. Combined with the Representation Theorem, the unit group of the magma monoid is the centralizer of the reversal permutation inside the symmetric group of $X \times X$ (with multiplication reversed).

Centralizers of permutations are classical: they depend only on the cycle type. On an $n$-element set, reversal has $n$ fixed points (the diagonal) and $m = \binom{n}{2} = n(n-1)/2$ transpositions (the off-diagonal mirror pairs). The centralizer of such an involution is $\mathrm{Sym}(n) \times (\mathbb{Z}/2 \wr \mathrm{Sym}(m))$: permute the fixed points freely, permute the transpositions among themselves, and independently flip each one.

> **Theorem (Order of the unit group).** For $X$ with $n$ elements, the number of invertible binary operations on $X$ is
> $$n! \cdot 2^{m} \cdot m!, \qquad m = \frac{n(n-1)}{2}.$$

For $n = 2$: $2 \cdot 2 \cdot 1 = 4$ invertible operations among $16$. For $n = 3$: $6 \cdot 8 \cdot 6 = 288$ among $19{,}683$. For $n=4$: $24 \cdot 64 \cdot 720 = 1{,}105{,}920$, out of $4^{16} \approx 4.3 \times 10^{9}$. The invertible part is a vanishing sliver: $n^{n^2}$ grows like a tower, $n!\,2^m m!$ merely like a factorial in $n^2/2$.

## The tropical corner

Now let the set carry structure, and watch the theory detect it.

**Tropical addition** — the operation $\min$, or $\max$ in the max-plus convention — is commutative and idempotent: $\min(x,x) = x$. Such operations are, from the monoid's point of view, remarkably inert. If $f$ is commutative and $g$ is diagonally idempotent then

$$(f*g)(a,b) = g(f(a,b), f(b,a)) = g(f(a,b), f(a,b)) = f(a,b),$$

so $f * g = f$. The commutative, diagonally idempotent operations form a **left-zero band**: in any product, the first factor wins and the rest are forgotten. Consequently all of them are $\mathcal{L}$-equivalent to one another (their unfolded images are all exactly the diagonal), they are all regular, and the submonoid generated by $\min$ and $\max$ is just the three-element set $\{\ell, \min, \max\}$ — every word in $\min$ and $\max$ collapses to its first letter.

**Tropical multiplication** — ordinary addition of exponents, $a \odot b = a + b$ — behaves completely differently. It is commutative, so every value is a commutative value; and its diagonal is $z \odot z = 2z$. The regularity criterion therefore reads: *every element of the value monoid must be a double*.

> **Theorem (Tropical multiplication).** Tropical multiplication over a value monoid $R$ is regular in the magma monoid if and only if every $r \in R$ can be written $r = s + s$.

Over $\mathbb{Q}$ or $\mathbb{R}$ this holds (halve), so tropical multiplication is regular. Over $\mathbb{Z}$ it fails: $1$ is odd, so the value $1$ is a commutative value never attained on the diagonal, and tropical multiplication over the integers is **not** regular. A purely semigroup-theoretic invariant of a monoid of abstract multiplication tables has just detected $2$-divisibility of the coefficient group.

## Why it matters

The magma monoid started life as a curiosity: a way of putting all algebras on a set into one bag and shaking it. What the transformation picture shows is that the bag has a spine. Every question about it — divisibility, invertibility, centrality, regularity — becomes a question about maps of the square $X \times X$ that respect a single reflection, and the answers all read off the interplay between the image, the kernel, and the diagonal.

The recurring lesson generalizes far beyond binary operations. Whenever you constrain transformations by a symmetry, the classical structure theory survives *except at the fixed points of the symmetry*, and the exact price is a stabilizer condition: an image point can only be inverted by a preimage at least as symmetric as itself. The diagonal obstruction in the magma monoid, the failure of $\mathrm{XOR}$ to have a pseudo-inverse, and the oddness of the integer $1$ blocking tropical multiplication are all the same phenomenon, viewed at three different magnifications.

That is a satisfying thing to be able to say about a monoid whose elements are, quite literally, all the ways of multiplying.
