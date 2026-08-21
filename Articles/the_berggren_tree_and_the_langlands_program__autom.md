# The Silver Thread: How a Tree of Right Triangles Almost Touched the Langlands Program

## A tree that contains every right triangle

Take the triangle with sides $3$, $4$, $5$. It is the most famous object in elementary mathematics: three whole numbers with $3^2 + 4^2 = 5^2$. Now apply three fixed integer matrices to the column vector $(3,4,5)$:

$$A = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix}, \qquad B = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix}, \qquad C = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}.$$

Each of them turns a Pythagorean triple into a larger Pythagorean triple — they preserve the quadratic form $a^2 + b^2 - c^2$, so they are integral symmetries of the *light cone* of $2{+}1$-dimensional spacetime. Applying them to $(3,4,5)$ gives $(5,12,13)$, $(21,20,29)$, $(15,8,17)$. Applying them again gives nine more triples, then twenty-seven, and so on.

The astonishing classical fact — found by Barning in 1963 and rediscovered by Berggren in 1934 and again by Hall — is that this ternary tree hits **every** primitive Pythagorean triple exactly once. Every right triangle with coprime whole-number sides has a unique address: a finite word like $BBAC$ in the three-letter alphabet $\{A,B,C\}$. The tree is *free*: no two different words give the same triangle.

A free ternary tree has a natural boundary at infinity — the set of infinite addresses $\{A,B,C\}^{\mathbb{N}}$. That is a Cantor set, exactly the object you get by repeatedly splitting an interval into three pieces and keeping the endpoints' addresses. Every infinite path down the tree is a point of the boundary, and every boundary point is a "direction to infinity" among Pythagorean triples.

This article is about a very tempting conjecture concerning that boundary, and about what turned out to be true instead.

## The silver number appears

Look at the middle generator $B$. Its characteristic polynomial factors as

$$\det(XI - B) = (X+1)\,(X^2 - 6X + 1),$$

and the quadratic factor has roots

$$3 \pm 2\sqrt{2}.$$

These are not random numbers. In the ring $\mathbb{Z}[\sqrt 2]$ of numbers $x + y\sqrt 2$ with $x,y$ integers, the *fundamental unit* is the **silver ratio** $1 + \sqrt 2$ — the smallest number greater than $1$ in that ring with an inverse also in the ring, namely $\sqrt 2 - 1$. And

$$(1+\sqrt 2)^2 = 3 + 2\sqrt 2.$$

So the eigenvalue of the middle Berggren generator is precisely the square of the fundamental unit of the real quadratic field $\mathbb{Q}(\sqrt 2)$. The other eigenvalue $3 - 2\sqrt{2}$ is its inverse and its Galois conjugate.

This is not a coincidence, and one can say exactly where it comes from. Define the **silver coordinate** of a triple:

$$\zeta(a,b,c) = (a+b) + c\sqrt{2} \in \mathbb{Z}[\sqrt 2].$$

Then a two-line computation shows the middle generator acts by *pure multiplication*:

$$\zeta(Bv) = (3 + 2\sqrt 2)\,\zeta(v).$$

Multiplication by a unit of $\mathbb{Z}[\sqrt 2]$. The arithmetic of a real quadratic field, living inside a tree of right triangles.

The root $(3,4,5)$ has silver coordinate $7 + 5\sqrt 2 = (1+\sqrt 2)^3$. Therefore the $n$-th node down the "all-$B$" path — call it the **spine** — has

$$\zeta = (1 + \sqrt 2)^{2n+3},$$

the odd powers of the silver ratio. The spine is literally an orbit of the unit group of $\mathbb{Z}[\sqrt 2]$: $(3,4,5)$, then $(21,20,29)$, then $(119,120,169)$, then $(697,696,985)$. Notice the legs: $|a - b| = 1$ every time. These are the *almost-isoceles* Pythagorean triples, and they are exactly the solutions of the **negative Pell equation**

$$(a+b)^2 - 2c^2 = -1,$$

or equivalently $c^2 - 2ab = 1$: the area-and-hypotenuse identity of the near-square right triangles.

There is one more layer. In the classical Euclid parametrization $(a,b,c) = (m^2 - n^2,\, 2mn,\, m^2+n^2)$, the generator $B$ becomes the two-by-two integer matrix $\begin{pmatrix} 2 & 1 \\ 1 & 0\end{pmatrix}$, whose eigenvalues are $1 \pm \sqrt 2$ — the fundamental unit itself. The three-dimensional eigenvalue is the square of the two-dimensional one. The silver ratio is a *spinor* eigenvalue of the tree.

## The moonshot

Here is where the story gets ambitious. The Langlands program — the great unifying vision of modern number theory — predicts that arithmetic objects attached to a number field $F$ correspond to *automorphic forms*, analytic objects governed by a commuting family of "Hecke operators." For a real quadratic field like $\mathbb{Q}(\sqrt 2)$, the relevant automorphic forms are **Hilbert modular forms**, and the relevant group is the Hilbert modular group $\mathrm{SL}(2, \mathbb{Z}[\sqrt 2])$.

Meanwhile, boundaries of regular trees are the classical playground of Hecke theory. For a $(q+1)$-regular tree, the *adjacency operator* on the boundary plays the role of a local Hecke operator at a prime with residue field of size $q$, and the theory of automorphic forms on such trees is a complete, beautiful, well-understood picture.

The Berggren tree is $3$-regular in its descending direction: $q + 1 = 3$, so $q = 2$. And $2$ is precisely the ramified prime of $\mathbb{Q}(\sqrt 2)$, with $(\sqrt 2)^2 = (2)$ and residue field of size $q = 2$. The temptation is irresistible:

> **The moonshot.** The boundary of the Berggren tree — the $3$-adic Cantor set — carries a space of automorphic forms for the Hilbert modular group of $\mathbb{Q}(\sqrt 2)$, with a Hecke eigenbasis whose eigenvalues are the silver units $3 \pm 2\sqrt 2$; and the correspondence realizes Langlands for $\mathrm{GL}(2)$ over $\mathbb{Q}(\sqrt 2)$.

It would be a spectacular bridge: from the $3$-$4$-$5$ triangle straight into the deepest structure in number theory.

It is false. And the interesting thing is *how precisely* it is false — three independent obstructions, each of which turns into a clean theorem, and together they identify what the tree really is.

## Obstruction one: the tree is rational

An arithmetic group carries an invariant that no change of coordinates can hide: the field generated by the traces of its elements. For the Hilbert modular group $\mathrm{SL}(2,\mathbb{Z}[\sqrt 2])$, that field is $\mathbb{Q}(\sqrt 2)$ — the matrix $\begin{pmatrix} 1+\sqrt 2 & -1 \\ 1 & 0 \end{pmatrix}$ has trace $1 + \sqrt 2$, and in its three-dimensional adjoint form the trace is $(1+\sqrt 2)^2 - 1 = 2 + 2\sqrt 2$. Both irrational.

The Berggren generators, by contrast, are *integer* matrices: $\operatorname{tr} A = 3$, $\operatorname{tr} B = 5$, $\operatorname{tr} C = 3$. Products of integer matrices are integer matrices, so:

> **Theorem (Rational trace field).** Every element of the monoid generated by $A$, $B$, $C$ has rational-integer trace. Since trace is invariant under conjugation, no matrix with irrational trace — in particular no adjoint image of a Hilbert modular element of trace $1+\sqrt 2$ — is conjugate to an element of the Berggren monoid.

So the Berggren tree does **not** generate a Hilbert modular group, in any coordinate system whatsoever. It sits inside the integral Lorentz group $\mathrm{O}(2,1;\mathbb{Z})$, an arithmetic group defined over $\mathbb{Q}$. In the spin picture, the three generators are the $\mathrm{GL}(2,\mathbb{Z})$ matrices $\begin{pmatrix}2&-1\\1&0\end{pmatrix}$, $\begin{pmatrix}2&1\\1&0\end{pmatrix}$, $\begin{pmatrix}1&2\\0&1\end{pmatrix}$. Utterly rational.

$\mathbb{Q}(\sqrt 2)$ is an *eigenvalue* field here, not a field of definition. A single hyperbolic matrix over $\mathbb{Z}$ can have quadratic irrational eigenvalues without its group being defined over a quadratic field — indeed every hyperbolic element of $\mathrm{SL}(2,\mathbb{Z})$ does.

## Obstruction two: the boundary's Hecke algebra is degenerate

Forget groups for a moment; build the Hecke theory directly on the boundary and see what it says.

Let $\mathrm{Bdry} = \{A,B,C\}^{\mathbb{N}}$ be the space of infinite addresses, and let an *observable* be any real-valued function $f$ on it. Two operators act naturally:

- the **transfer (Hecke) operator**, summing over the three children,
  $$(Tf)(w) = \sum_{x \in \{A,B,C\}} f(x \frown w),$$
  where $x \frown w$ is the address $w$ with the letter $x$ prepended;
- the **shift operator**, $(Uf)(w) = f(\sigma w)$, where $\sigma$ deletes the first letter.

These are the honest tree analogues of the local Hecke operator and the translation operator. Now compute. Since deleting the letter you just prepended returns you where you started, $T(Uf)(w) = \sum_{x} f(w) = 3 f(w)$, i.e.

$$TU = 3\,\mathrm{id}.$$

Consequently the composite $H = UT$ — the Hecke operator as seen on the boundary itself — satisfies

$$H^2 = 3H.$$

That single quadratic relation determines everything. It says $E = \tfrac13 H$ is an **idempotent**: $E^2 = E$. The space of observables splits canonically and uniquely,

$$\mathrm{Obs} = \operatorname{im} U \ \oplus\ \ker T,$$

into the $3$-eigenspace and the $0$-eigenspace of $H$; every observable $f$ is uniquely $f = g + h$ with $Hg = 3g$ and $Hh = 0$, namely $g = \tfrac13 Hf$. And here is the punchline:

> **Theorem (Spectral dichotomy).** If $f \neq 0$ and $Hf = \lambda f$, then $\lambda = 0$ or $\lambda = 3$. The spectrum of the boundary Hecke operator is exactly $\{0, 3\}$.

The proof is one line from $H^2 = 3H$: applying $H$ twice gives $\lambda^2 f = 3\lambda f$, so $\lambda(\lambda - 3) = 0$. Both values occur: the constant function $1$ has $H\mathbf 1 = 3\cdot \mathbf 1$ (the trivial, or Eisenstein, eigenform of a $3$-regular tree, with the degree eigenvalue $q+1 = 3$), while the mean-zero function of the first letter — $+1$ on addresses beginning with $A$, $-1$ on those beginning with $B$, $0$ on those beginning with $C$ — is killed by $H$.

So the boundary *does* carry a Hecke algebra. But it is degenerate: a rank-one Hecke pair with a two-point spectrum, the trivial eigenvalue and zero. There is no rich eigenbasis, no family of Hecke eigenforms with varying eigenvalues — nothing that could support an interesting automorphic spectrum.

In particular:

> **Theorem (Falsification).** The silver units $3 \pm 2\sqrt 2$ are not eigenvalues of the boundary Hecke operator. Since $3 + 2\sqrt{2} \approx 5.828$ and $3 - 2\sqrt{2} \approx 0.172$ are neither $0$ nor $3$, no nonzero observable satisfies $Hf = (3\pm2\sqrt2) f$.

And even hypothetically, they could not have been. The Ramanujan–Petersson bound demands that the Hecke eigenvalue of a *tempered* automorphic form at a prime with residue field of size $q$ satisfies $|\lambda| \le 2\sqrt q$. Here $q = 2$, so the bound is $2\sqrt 2 \approx 2.828$ — and both $3$ and $3 + 2\sqrt 2$ exceed it. Furthermore, a genuine unramified representation of $\mathrm{GL}(2)$ with trivial central character has Satake parameters multiplying to $q = 2$, whereas

$$(3 + 2\sqrt2)(3 - 2\sqrt2) = 9 - 8 = 1 \neq 2.$$

The pair $(3+2\sqrt2, 3-2\sqrt2)$ is a *unit* pair, not a Satake pair. Its product is $1$ because they are conjugate units of norm one — beautiful arithmetic, but the wrong normalization for automorphy.

## Obstruction three: the quadratic field lives on one line

The third obstruction is the most vivid. Where in the tree does $\mathbb{Q}(\sqrt 2)$ actually appear?

Take any node on the light cone, $a^2 + b^2 = c^2$. The norm of its silver coordinate is

$$N(\zeta(a,b,c)) = (a+b)^2 - 2c^2 = a^2 + 2ab + b^2 - 2c^2 = -(a-b)^2,$$

using $a^2+b^2 = c^2$. So the silver coordinate is a unit of $\mathbb{Z}[\sqrt 2]$ **exactly when $|a - b| = 1$** — the almost-isoceles triples again.

Now track the leg difference $d = a - b$ along the tree. The three generators do:

$$A:\ d \mapsto -(a+b), \qquad B:\ d \mapsto -d, \qquad C:\ d \mapsto a+b.$$

The letter $B$ preserves $|d|$ forever; the letters $A$ and $C$ replace it by the *sum* $a+b$, which is at least $7$ and grows without bound, and once destroyed the unit property never returns. That gives a complete classification:

> **Theorem (Unit locus).** A node of the Berggren tree has unit silver coordinate — equivalently is almost-isoceles, equivalently solves the negative Pell equation — if and only if its address is a word in the single letter $B$. Consequently, in the boundary Cantor set, the set of infinite addresses all of whose truncations are unit nodes is the single point $BBBB\ldots$.

One point, of Hausdorff dimension $0$, inside a Cantor set of full dimension. The real quadratic field does not live on the boundary; it lives on a single geodesic axis whose endpoint happens to lie on that boundary.

## What the tree really is

Once you know that, the whole picture snaps into focus, and it comes from a spectral trichotomy of the three-letter alphabet.

The generators $A$ and $C$ have characteristic polynomial $(X-1)^3$; they satisfy $(A-I)^3 = 0$ but $(A-I)^2 \neq 0$. They are **unipotent** — parabolic isometries of the hyperbolic plane, with a single maximal Jordan block. Each fixes a *rational* point of the light cone: $A$ fixes $(0,1,1)$ and $C$ fixes $(1,0,1)$, the degenerate "triangles" at the two ends of the parameter range. Parabolic motions have polynomial orbits, and indeed the pure branches are exactly quadratic:

$$A^n(3,4,5) = (2n+3,\ 2n^2+6n+4,\ 2n^2+6n+5), \qquad C^n(3,4,5) = (4n^2+8n+3,\ 4n+4,\ 4n^2+8n+5).$$

The generator $B$, by contrast, is **hyperbolic**: eigenvalues $-1$ and $3 \pm 2\sqrt 2$, with the two light-like eigenvectors $(1,1,\pm\sqrt2)$ and the space-like eigenvector $(1,-1,0)$. Its two ideal fixed points are *quadratic irrational* — it has no rational light-like eigendirection at all, because a rational null vector fixed by $B$ would force $2y^2 = x^2$ with $y \neq 0$, contradicting the irrationality of $\sqrt 2$. Its branch grows exponentially:

$$c_n = \frac{7+5\sqrt2}{2\sqrt2}\,(3+2\sqrt2)^n \;+\; \frac{7-5\sqrt2}{2\sqrt2}\,(3-2\sqrt2)^n.$$

The second term is negative and smaller than $1/2$ in absolute value, so the hypotenuse $c_n$ is simply the **nearest integer** to $\frac{7+5\sqrt2}{2\sqrt2}(3+2\sqrt2)^n$. The spectral eigenvalue of the hyperbolic generator is literally the growth rate of the triangles along its axis: $c_{n+1}/c_n \to 3+2\sqrt2$. And the direction converges too, at an exactly computable rate: for every $n$,

$$\left(\frac{a_n+b_n}{c_n}\right)^2 = 2 - \frac{1}{c_n^2},$$

so $(a_n+b_n)/c_n \to \sqrt 2$ with error $O(c_n^{-2})$. The almost-isoceles triangles march off toward the irrational boundary direction $\sqrt 2$ — the attracting eigenvector of $B$ — and the negative Pell equation is exactly the statement that the error term is as small as it can be.

Even the "$L$-function" is there, in the right shape but with the wrong normalization. The hypotenuses satisfy the Pell recursion $c_{n+2} = 6c_{n+1} - c_n$, whose reciprocal characteristic polynomial factors as

$$1 - 6x + x^2 = \bigl(1 - (3+2\sqrt2)x\bigr)\bigl(1 - (3-2\sqrt2)x\bigr).$$

That is exactly the shape of an unramified local Euler factor with Satake parameters $3 \pm 2\sqrt2$ — a perfect mirage. But since the parameters multiply to $1$ instead of $q = 2$, it is the Euler factor of a real quadratic unit, not of a Hilbert modular form.

## The moral

The correct slogan is:

> **The Berggren tree is a $\mathbb{Q}$-arithmetic object whose hyperbolic elements have real quadratic multipliers. $\mathbb{Q}(\sqrt 2)$ is an eigenvalue field, not a field of definition.**

This is a satisfying kind of negative result: not "we could not find the structure," but "here are three independent theorems proving the structure is absent, and here is exactly what is present instead." The tree's arithmetic content is genuine and beautiful — the silver coordinate really does intertwine the middle generator with multiplication by the fundamental unit squared, the spine really is the unit orbit and really does solve the negative Pell equation — but it is confined to one geodesic.

It is also a useful cautionary tale about numerical coincidence. Everything lined up: a $3$-regular tree, $q = 2$, the ramified prime of $\mathbb{Q}(\sqrt 2)$, eigenvalues that are units of $\mathbb{Z}[\sqrt2]$, an Euler factor of exactly the right shape. Five suggestive coincidences, and not one of them survives contact with the two invariants that actually distinguish arithmetic groups and automorphic representations: the trace field and the Satake normalization. A quantity of the right *shape* is not a quantity of the right *kind*.

And it leaves the real question sharpened. The Berggren tree is a free monoid of Lorentz isometries with two parabolic letters fixing rational cusps and one hyperbolic letter with a quadratic irrational axis. The automorphic theory it should be compared with is that of $\mathrm{O}(2,1;\mathbb{Z}) \sim \mathrm{GL}(2,\mathbb{Z})$ over $\mathbb{Q}$ — classical modular forms — and the natural next question is what its boundary measure, its geodesic flow, and its distribution of leg-difference statistics say about *that* theory. The silver thread runs through the tree; it just does not weave the whole cloth.
