# Moonshine from the Null Cone

### What happens when you ask the oldest theorem in mathematics to meet the strangest object in group theory

---

## A tree that grows out of a triangle

Start with the triangle every schoolchild knows: sides $3$, $4$, $5$. Three whole numbers with $3^2 + 4^2 = 5^2$. It is the oldest named identity in mathematics, carved into clay tablets a thousand years before Pythagoras.

Now do something that would have startled the Babylonians. Write the triple as a column vector and hit it with three integer matrices:

$$
A=\begin{pmatrix}1&-2&2\\ 2&-1&2\\ 2&-2&3\end{pmatrix},\qquad
B=\begin{pmatrix}1&2&2\\ 2&1&2\\ 2&2&3\end{pmatrix},\qquad
C=\begin{pmatrix}-1&2&2\\ -2&1&2\\ -2&2&3\end{pmatrix}.
$$

Applied to $(3,4,5)$ these give $(5,12,13)$, $(21,20,29)$ and $(15,8,17)$ — three more Pythagorean triples. Apply them again and you get nine more. Again: twenty-seven. The process never stops and never repeats, and — this is the astonishing part, discovered by Barning in 1963 and rediscovered by Hall and later Berggren — **every** primitive Pythagorean triple (one whose three numbers share no common factor) appears exactly once. The whole infinite collection of right triangles with whole-number sides is a single, perfectly regular, infinitely branching ternary tree with $(3,4,5)$ at its root.

Why do those particular matrices work? Because they are not really matrices about triangles at all. They are *symmetries of a geometry*. The condition $a^2+b^2=c^2$ says exactly that the vector $(a,b,c)$ has length zero in the Lorentzian metric

$$
\langle (a,b,c),(a',b',c')\rangle \;=\; aa' + bb' - cc',
$$

the same signature-$(2,1)$ metric that governs a flat two-dimensional spacetime, with $c$ playing the role of time. Pythagorean triples are the **integer points on the light cone** — the null cone — of a toy universe. The three Barning–Hall matrices are integer-valued Lorentz transformations. They move light rays to light rays, and the tree is the orbit of a single light ray under a free monoid of Lorentz boosts.

That reframing makes the next question irresistible.

## The other Lorentzian geometry

There is a second, far more glamorous, integral Lorentzian geometry in mathematics: the **even unimodular Lorentzian lattice** $\mathrm{II}(25,1)$, living in $26$ dimensions with signature $(25,1)$. It is the unique even unimodular lattice of that signature, and it is the stage on which one of the most spectacular dramas in modern mathematics is played.

Here is the plot in four acts.

**Act one: the Leech lattice.** In $24$ dimensions there is a miraculous packing of spheres, the *Leech lattice* $\Lambda$: even, unimodular, and — uniquely among the $24$ even unimodular lattices of that rank, the **Niemeier lattices** — it contains no vectors of the minimum possible nonzero norm $2$. In lattice language, $\Lambda$ is **rootless**: nothing in it is short. That is why it packs spheres so efficiently, and why its symmetry group is so enormous.

**Act two: Conway's holy construction.** Conway found the Leech lattice sitting inside $\mathrm{II}(25,1)$ in the most elegant conceivable way. Take the *Weyl vector*
$$
w=(0,1,2,3,\dots,24\,;\,70),
$$
whose Lorentzian norm is $0^2+1^2+\cdots+24^2-70^2 = 4900-4900 = 0$. It is a **null vector**, a point on the light cone of $26$-dimensional spacetime — just like a Pythagorean triple in our toy universe. Then form
$$
w^{\perp}/\mathbb{Z}w \;\cong\; \Lambda .
$$
The Leech lattice is the quotient of the hyperplane orthogonal to a light ray by that light ray. Conway called this the *holy construction*: the null cone of $\mathrm{II}(25,1)$ manufactures $24$-dimensional lattices, and the $23$ classes of "deep holes" of Leech — points maximally far from every lattice point — correspond exactly to the other $23$ Niemeier lattices.

**Act three: the Monster.** The symmetry group of the Leech lattice is the Conway group $\mathrm{Co}_0$, of order roughly $8\times 10^{18}$. Out of the Leech lattice one constructs the *moonshine module*, whose automorphism group is the **Monster** — the largest sporadic finite simple group, with about $8\times 10^{53}$ elements.

**Act four: moonshine.** The Monster's smallest faithful representation has dimension $196883$. The modular function
$$
j(q) = q^{-1} + 744 + 196884\,q + 21493760\,q^2 + \cdots
$$
has, as its first interesting coefficient, $196884 = 196883 + 1$. McKay noticed; Conway and Norton called it *monstrous moonshine*; Borcherds proved it, and won a Fields Medal. The bridge between the Monster and modular functions runs through $\mathrm{II}(25,1)$.

So: two integral Lorentzian geometries, one the home of Pythagorean triples, the other the home of moonshine. Both are built on a null cone; both carry arithmetic reflection groups. **Is the Pythagorean one a shadow of the other?**

The answer turns out to be a clean and instructive **no** — refuted three ways, by three mechanisms, each a sharp theorem — together with an unexpected **yes** to a question nobody had asked.

## The first obstruction: parity

Before anything subtle, there is a one-line obstruction, and it is decisive.

An **even lattice** is one where every vector has even norm: $\langle x,x\rangle \in 2\mathbb{Z}$ for all $x$. All the lattices of moonshine — Leech, the Niemeier lattices, $\mathrm{II}(25,1)$ — are even. It is not a convention; it is essential. Evenness is what makes theta functions modular, which is what makes moonshine possible at all.

Now look at the Pythagorean lattice $\mathbb{Z}^{2,1}$. The vector $e_1 = (1,0,0)$ has norm
$$
\langle e_1,e_1\rangle = 1^2 + 0^2 - 0^2 = 1,
$$
which is odd.

> **Theorem (Parity obstruction).** There is no map $f$ whatsoever — linear or not, injective or not — from the Pythagorean Lorentzian lattice $(\mathbb{Z}^3,\; aa'+bb'-cc')$ into any even lattice satisfying $\langle f(v),f(w)\rangle = \langle v,w\rangle$ for all $v,w$. In particular, the Pythagorean null cone does not embed isometrically into $\mathrm{II}(25,1)$.

The proof is the whole of the previous paragraph: $f(e_1)$ would have to have norm $1$, and no vector in an even lattice does. Notice how strong this is. One usually rules out *linear* embeddings, using rank or discriminant arguments; here even a wildly nonlinear set map is impossible, because the parity is carried by a single vector. And this is a refutation one should be pleased to find, because it is also a repair instruction: the problem is not the geometry, it is the *normalization*.

## The repair: double everything

Multiply the Pythagorean form by $2$. Write $\mathbb{Z}^{2,1}(2)$ for the lattice $\mathbb{Z}^3$ with the form $2(aa'+bb'-cc')$. Now every norm is even — trivially. And something much better happens.

In the doubled lattice, the vector $e_1$ has norm $2$. A vector of norm $2$ in an even lattice is called a **root**, and roots are exactly the objects that moonshine lattices are made of. Root reflections
$$
s_\rho(x) = x - \langle x,\rho\rangle\,\rho
$$
are the elementary symmetries of every even lattice; they are why Conway and Vinberg could compute with $\mathrm{II}(25,1)$ at all.

So the question becomes: what do the Barning–Hall matrices look like in the language of reflections? The answer is clean and, as far as I know, was not previously written down:

> **Theorem (Reflection decomposition).** In the Lorentzian lattice $\mathbb{Z}^{2,1}$, the reflection in a vector $r$ of norm $1$ is the integral map $s_r(x)=x-2\langle x,r\rangle r$. With respect to the five unit vectors
> $$e_1=(1,0,0),\quad e_2=(0,1,0),\quad \alpha=(1,-1,-1),\quad \beta=(1,1,-1),\quad \gamma=(-1,1,-1),$$
> each of norm exactly $1$, the three Barning–Hall generators factor as
> $$A=s_{e_1}s_{\alpha},\qquad C=s_{e_2}s_{\gamma},\qquad B=s_{e_1}s_{e_2}s_{\beta}.$$
> Consequently every node of the Pythagorean tree is reached from $(3,4,5)$ by a word of reflections in unit vectors, of length $3\,\#B + 2\,\#\{A,C\}$.

($B$ needs three reflections, not two, because its determinant is $-1$: it reverses orientation.)

Every one of those five vectors has odd norm $1$ — the parity obstruction again, now at the level of the generators. But double the form and all five become roots of norm $2$, and the whole machine works:

> **Theorem (Faithful embedding after doubling).** Let $M$ be any even lattice containing three pairwise orthogonal vectors $u_1,u_2,w$ with norms $2,2,-2$. Then the map
> $$\varepsilon(a,b,c) = a\,u_1 + b\,u_2 + c\,w$$
> is an injective additive map $\mathbb{Z}^3 \to M$ satisfying $\langle \varepsilon v,\varepsilon v'\rangle = 2\langle v,v'\rangle$. It carries each of the five Berggren unit vectors to a root of $M$, so the corresponding root reflections are defined over $\mathbb{Z}$ on all of $M$. The assignment sending a word in $\{A,B,C\}$ to the corresponding product of root reflections is a monoid homomorphism into the isometry group of $M$; it lands in bijective isometries, it intertwines the Berggren action on triples, and it is **injective**.

Injectivity — faithfulness — is the point: distinct addresses give genuinely distinct symmetries of $M$, because they already move $(3,4,5)$ to distinct triples, and the freeness of the tree does the rest. The hypothesis is not vacuous: $\mathbb{Z}^{2,1}(2)$ itself, which is the lattice $A_1\oplus A_1 \oplus \langle -2\rangle$, has such a frame, and so does $\mathrm{II}(25,1)$.

So a version of the original dream *is* true. The Berggren tree really does live inside the isometry group of even Lorentzian lattices — including the one moonshine is built on — but only after the factor-of-$2$ rescaling that converts odd Pythagorean unit vectors into even moonshine roots. That factor of $2$ is not a technicality; it is the precise measure of the distance between elementary Pythagorean geometry and the exceptional geometry of Leech.

## The second obstruction: counting

The romantic version of the hypothesis was more ambitious: that the *combinatorics* of the tree — its nodes, its ternary branching — would reproduce the hole structure of the Leech lattice. There are $23$ classes of deep holes, and $24$ Niemeier lattices. The tree branches three ways.

This fails for the most elementary reason imaginable, worth stating precisely because it is airtight.

> **Theorem (Counting obstruction).** The levels of the tree have sizes $1,3,9,27,\dots$, and the balls around the root have sizes $1,4,13,40,121,\dots$. No level has exactly $23$ or exactly $24$ nodes; no ball does either. Moreover, since the tree has infinitely many nodes, every labelling of its nodes by the $24$ Niemeier lattices is non-injective, and — by the infinite pigeonhole principle — some Niemeier class receives infinitely many nodes. The same holds after passing from addresses to the actual Pythagorean triples, because distinct addresses give distinct triples.

Some level sizes come close — $27$ is near $24$ — but "close" is not a theorem. $3^n = 23$ is impossible because $3 \nmid 23$; $3^n = 24$ because $3^n$ is odd; the balls $(3^{n+1}-1)/2$ skip from $13$ to $40$. What survives is only the trivial statement that a Niemeier labelling is a finite colouring of an infinite tree. The ternary branching is not the hole structure.

## The third obstruction: the tree only sees Gaussian primes

The third and most interesting refutation concerns the tree's *radial* coordinate — the hypotenuse.

Which integers can be the hypotenuse of a node? Every primitive triple can be written in Euclid's parametrization $(m^2-n^2,\,2mn,\,m^2+n^2)$ with $m>n>0$ coprime and of opposite parity. So the hypotenuse is a sum of two **coprime** squares. That single fact has a sharp arithmetic consequence via Fermat's classical theorem on sums of two squares:

> **Theorem (Gaussian-split law).** Every hypotenuse of a node of the Pythagorean tree is $\equiv 1 \pmod 4$, and no prime $p \equiv 3 \pmod 4$ divides any of them. Equivalently: the hypotenuses are built exclusively from primes that split in the Gaussian integers $\mathbb{Z}[i]$.

The proof is short and pretty. If $p \equiv 3 \pmod 4$ divided $m^2+n^2$, then modulo $p$ we would have $m^2 \equiv -n^2$. Since $m$ and $n$ are coprime, $n$ is invertible mod $p$, so $(m/n)^2 \equiv -1$: the number $-1$ would be a square modulo $p$. But $-1$ is a square mod $p$ precisely when $p \equiv 1 \pmod 4$. Contradiction.

Now compare with moonshine's numbers.

| number | factorization | obstructing prime |
|---|---|---|
| $196883$ (Monster's smallest faithful representation) | $47\cdot 59\cdot 71$ | $47\equiv 3$ |
| $196884$ (first coefficient of $j$) | $2^2\cdot 3^3\cdot 1823$ | $3\equiv 3$ |
| $21296876$ (next Monster head dimension) | $2^2\cdot 31\cdot 41\cdot 59\cdot 71$ | $31 \equiv 3$ |
| $21493760$ (next coefficient of $j$) | $2^{11}\cdot 5\cdot 2099$ | $2099\equiv 3$ |
| $23$ (deep-hole classes) | $23$ | $23\equiv 3$ |
| $24$ (Niemeier lattices) | $2^3\cdot 3$ | $3 \equiv 3$ |

Every single one of them is divisible by a prime $\equiv 3\pmod 4$. Therefore **none of them is ever a hypotenuse of a node of the Pythagorean tree**. Not the dimension of the Monster's smallest representation; not the first coefficient of $j$; not even the structural constants $23$ and $24$. The tree cannot see the hole structure through its radial coordinate at all.

And the law is *exact*, not merely an obstruction. Running Fermat's two-squares theorem in the other direction:

> **Theorem (The prime spectrum of the tree).** A prime $p$ occurs as the hypotenuse of some node of the Pythagorean tree if and only if $p\equiv 1\pmod 4$.

The forward direction is the congruence law; the backward direction writes $p=a^2+b^2$ (Fermat), notes that primality forces $a,b$ to be coprime and of opposite parity, and feeds the pair into the tree's completeness theorem. So $5,13,17,29,37,41,53,61,\dots$ all appear (at the addresses root, $A$, $C$, $B$, $CC$, $AAA$, $AC$, $AAAA$ respectively), while $3,7,11,19,23,31,43,47,\dots$ never do.

That last list will look familiar to anyone who has met moonshine. The primes dividing the order of the Monster — the **supersingular primes** — are
$$
2,\;3,\;5,\;7,\;11,\;13,\;17,\;19,\;23,\;29,\;31,\;41,\;47,\;59,\;71 .
$$
Split them by residue mod $4$. The split primes $5,13,17,29,41$ are hypotenuses of the tree. The inert primes $3,7,11,19,23,31,47,59,71$ — a clear majority, and including all four of the "large" ones $47,59,71$ that produce $196883$ — never divide a hypotenuse. The two arithmetics select complementary halves of the Monster's prime set. That, in one sentence, is why no tree-parametrized organization of moonshine data can exist along the radial coordinate.

## What is actually there: the tree's own holy construction

Every refutation should leave a theorem behind, and this one is more satisfying than the conjecture it replaces.

Conway's holy construction needs only a primitive null vector in an integral Lorentzian lattice. The nodes of the Pythagorean tree *are* primitive null vectors, so each node has its own holy construction. What is it?

Take the root $\rho=(3,4,5)$ and the vector $\tau=(2,1,2)$. Then
$$
\langle \tau,\rho\rangle = 2\cdot 3 + 1\cdot 4 - 2\cdot 5 = 0, \qquad \langle\tau,\tau\rangle = 4+1-4 = 1 .
$$
So $\tau$ lies in $\rho^\perp$, is not a multiple of $\rho$, and has norm $1$. In fact $\{\rho,\tau\}$ is a basis of $\rho^{\perp}$ over $\mathbb{Z}$, with explicit coordinates: any $v=(a,b,c)$ orthogonal to $\rho$ is
$$
v = (3c-2a-2b)\,\rho + (5a+5b-7c)\,\tau, \qquad \langle v,v\rangle = (5a+5b-7c)^2 .
$$
Since $\rho$ is null and orthogonal to $\tau$, the induced form on the quotient $\rho^\perp/\mathbb{Z}\rho$ is simply $y\mapsto y^2$: the rank-one lattice $\langle 1\rangle$. In the even rescaling — the normalization one must use to compare with moonshine — the quotient is $y\mapsto 2y^2$, which is the root lattice $A_1$.

So the Pythagorean holy construction produces $A_1$. A single root. And the Leech lattice's defining property is that it has *no* roots at all. The contrast could not be sharper: the holy construction of $\mathrm{II}(25,1)$ is the rootless $24$-dimensional Leech lattice; the holy construction of the Pythagorean null cone is the one-dimensional lattice generated by a single root.

This is not an accident of the root: transporting along the tree's isometries gives the same answer at every node. But the real theorem drops the tree entirely:

> **Theorem (Holy-construction rigidity).** For **every** primitive null vector $\rho$ of $\mathbb{Z}^{2,1}$ — tree node or not — there is a vector $\tau$ with $\langle\tau,\rho\rangle=0$, $\langle\tau,\tau\rangle=1$, $\tau\notin\mathbb{Z}\rho$, such that $\{\rho,\tau\}$ spans $\rho^{\perp}$ over $\mathbb{Z}$ and the induced form on $\rho^\perp/\mathbb{Z}\rho$ is $y\mapsto y^2$. In other words $\rho^{\perp}/\mathbb{Z}\rho \cong \langle 1\rangle$ always; after doubling, $A_1$ always.

The proof introduces a gadget worth knowing: the **Lorentzian cross product**
$$
v\times_L w = \bigl(v_2w_3-v_3w_2,\;\; v_3w_1-v_1w_3,\;\; v_2w_1-v_1w_2\bigr),
$$
the ordinary cross product with a sign flip in the timelike slot. It is orthogonal to both arguments *for the Lorentz form*, and it satisfies a Lagrange identity:
$$
\langle v\times_L w,\,v\times_L w\rangle \;=\; \langle v,w\rangle^2 - \langle v,v\rangle\langle w,w\rangle .
$$
Now let $\rho$ be primitive and null. Because $\mathbb{Z}^{2,1}$ is unimodular, two applications of Bézout's identity produce a lattice vector $\sigma$ with $\langle\rho,\sigma\rangle=1$. Set $\tau = \rho\times_L\sigma$. The Lagrange identity instantly gives
$$
\langle \tau,\tau\rangle = 1^2 - 0\cdot\langle\sigma,\sigma\rangle = 1 .
$$
The norm-$1$ vector was not found by search; it was *forced*. And the frame $\{\rho,\tau,\sigma\}$ has determinant $-1$, which is exactly what is needed for Cramer's rule to work over $\mathbb{Z}$ and for $\{\rho,\tau\}$ to be an honest basis of $\rho^\perp$.

The moral is a slogan: **rootlessness is a strictly even phenomenon.** In an odd lattice like $\mathbb{Z}^{2,1}$, unimodularity plus a primitive null vector *manufactures* a norm-$1$ vector — a root of the doubled form — automatically. It is impossible for the quotient to be rootless. The miracle of the Leech lattice, its emptiness at short range, cannot happen anywhere near a Pythagorean triple, for reasons that have nothing to do with dimension $24$ and everything to do with parity.

## What we learned

The hypothesis was that the Pythagorean tree is a shadow of the Leech lattice's arithmetic. The result is a precise map of exactly how far that is from the truth, with a single quantity — parity — explaining almost all of it:

1. **Isometrically, no, for parity reasons.** One odd vector kills every conceivable form-preserving map into an even lattice.
2. **After doubling, yes, and faithfully.** The Berggren monoid embeds in the isometry group of every even lattice with an orthogonal $(2,2,-2)$ frame — including $\mathrm{II}(25,1)$ — by root reflections in the images of five explicit unit vectors. This is a genuine, positive bridge, and the factor $2$ is its exact toll.
3. **Combinatorially, no, for counting reasons.** $23$ and $24$ are not powers of $3$, nor ternary ball sizes; every finite labelling of an infinite tree has an infinite fibre.
4. **Arithmetically, no, and precisely why.** The tree's hypotenuses are exactly the products of Gaussian-split primes; the Monster's head data is built out of inert ones. On primes the spectrum is exactly $\{p : p\equiv 1 \bmod 4\}$.
5. **What the tree actually realizes:** the $A_1$ holy construction, uniformly, rigidly, at every primitive null vector of the Pythagorean light cone — the exact opposite pole from Leech.

There is something bracing about this. The dream connection — Pythagoras to the Monster in one step — does not exist, and the reason is not some deep unavailable fact about sporadic groups. It is that $1$ is odd. Moonshine lives in the even world, where theta functions are modular, where lattices can be rootless, where $24$ is a magic number. Pythagorean triples live in the odd world, where light rays always come with a short companion vector, and the only lattice you can build from one is $A_1$.

Between the two worlds there is a bridge, and it is exactly the doubling map. That is a smaller result than the moonshot, and a truer one. Sometimes the most useful thing a conjecture can do is fail in a way that names the invariant separating the two things you hoped were the same.

---

*A closing computation, in the spirit of the tree: its first hypotenuses are $5,13,17,25,29,37,41,53,61,65,73,85,\dots$ — every one a product of primes $\equiv 1 \bmod 4$, marching off to infinity, never once touching $23$, $24$, $196883$, or $196884$. The tree is as rigid and complete as the Leech lattice. It just answers a different question.*
