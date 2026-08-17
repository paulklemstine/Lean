# Counting Dots to See a Shape

## How a single number, measured at every magnification, pins down a body in space

Imagine a photograph taken through a strange camera. The camera cannot see colour, or edges, or
even where anything is. It reports exactly one number: *how many points of a perfectly regular
grid fall inside the object being photographed*. You are allowed to zoom in and out as much as
you like — that is, to scale the object by any positive real factor $t$ — and you may slide the
object around, but only by whole numbers of grid steps. Every measurement returns a single
integer.

Can you reconstruct the object?

The surprising answer is yes: essentially completely. This article explains why, and what makes
the argument work.

---

## The enumerator

Fix the standard grid $\mathbb{Z}^d$ of points with integer coordinates in $d$-dimensional space,
and fix a bounded set $P \subseteq \mathbb{R}^d$ — a disc, a triangle, a coffee-cup cross-section,
anything that fits inside some ball. For a real scaling parameter $t > 0$ write

$$L_P(t) \;=\; \bigl|\, tP \cap \mathbb{Z}^d \,\bigr|,$$

the number of grid points inside the shape magnified by $t$. Because $k \in tP$ exactly when
$k/t \in P$, an equivalent description is often more useful: $L_P(t)$ counts the points of the
*rescaled grid* $\tfrac{1}{t}\mathbb{Z}^d$ that lie in the original $P$. Magnifying the shape and
refining the grid are the same operation viewed from two sides.

Two easy examples set the scale. In dimension one, for the half-open unit interval $[0,1)$ one
has exactly
$$L_{[0,1)}(t) = \lceil t \rceil \quad \text{for every } t > 0,$$
so $L(5/2) = 3$, $L(4) = 4$, $L(1/3) = 1$. And for the unit square in the plane,
$L_{[0,1)^2}(t) = \lceil t\rceil^2$. In both cases $L_P(t)/t^d \to 1$, which is the volume. That
is no accident.

Classically one only ever plugs *integer* values of $t$ into $L_P$. For a polytope with rational
vertices this produces the celebrated Ehrhart quasi-polynomial, a piece of combinatorics with a
long and beautiful history. But integers are a very coarse set of magnifications, and the
Ehrhart data famously fails to determine the polytope: many different polytopes share the same
counting function. The moment one allows *all real* $t$, the situation changes dramatically.

---

## First: the enumerator knows the volume

The first theorem is the classical intuition made exact.

> **Counting Theorem.** Let $P \subseteq \mathbb{R}^d$ be bounded, measurable, and let its
> topological boundary have zero volume. Then
> $$\lim_{t \to \infty} \frac{L_P(t)}{t^{d}} \;=\; \operatorname{vol}(P).$$

Sets whose boundary is negligible are exactly the *Jordan measurable* sets: discs, polytopes,
convex bodies, and every reasonable region one draws. (Every bounded convex set qualifies
automatically — a convex body's boundary always has zero volume.)

The proof is prettier than the usual "cover with little cubes" argument, because it makes the
covering *exact*. Attach to each grid point $k$ the half-open cube
$$C_t(k) \;=\; \prod_{i=1}^{d}\Bigl[\tfrac{k_i}{t}, \tfrac{k_i+1}{t}\Bigr),$$
of side $1/t$, sitting with its lower corner at $k/t$. These cubes tile space: every point $x$
lies in exactly one of them, namely the cube indexed by $\lfloor t x\rfloor$ (floor taken
coordinate by coordinate). Now define the *rounded copy* of $P$:
$$A_t \;=\; \Bigl\{\, x \in \mathbb{R}^d \;:\; \tfrac{\lfloor t x \rfloor}{t} \in P \,\Bigr\}.$$
In words: round $x$ down to the nearest point of the grid $\tfrac1t\mathbb{Z}^d$, and ask whether
the rounded point is in $P$. Then $A_t$ is precisely the union of the cubes attached to the grid
points counted by $L_P(t)$, and those cubes are pairwise disjoint. Hence the *exact* identity,
valid for every single $t > 0$ with no error term at all:
$$\operatorname{vol}(A_t) \;=\; \frac{L_P(t)}{t^{d}}.$$

All the analysis is now packed into one clean question: does $\operatorname{vol}(A_t)$ converge
to $\operatorname{vol}(P)$? It does. Rounding moves a point by at most $1/t$, so if $x$ is
strictly inside $P$ it eventually lies in $A_t$, and if it is strictly outside it eventually lies
outside $A_t$. The only points where this can fail are boundary points — and the boundary was
assumed negligible. All the sets $A_t$ with $t \ge 1$ sit inside one fixed ball, which supplies
the domination needed to pass to the limit. That is the whole proof.

An immediate consequence: two bounded Jordan measurable sets with the same enumerator
$L_P(t) = L_Q(t)$ for all real $t>0$ have the same volume. So the data already sees one global
invariant. Can it see the shape?

---

## Second: the enumerator, plus integer sliding, knows *everything*

Here is the main theorem. Let $L_{P+v}(t) = |t(P+v) \cap \mathbb{Z}^d|$ denote the enumerator of
$P$ shifted by an integer vector $v \in \mathbb{Z}^d$.

> **Uniqueness Theorem.** Let $P, Q \subseteq \mathbb{R}^d$ be bounded measurable sets whose
> boundaries have zero volume. If
> $$L_{P+v}(t) = L_{Q+v}(t) \qquad \text{for every real } t > 0 \text{ and every } v \in \mathbb{Z}^d,$$
> then $P$ and $Q$ agree up to a set of volume zero: their indicator functions are equal almost
> everywhere.

> **Corollary (convex bodies).** If $P$ and $Q$ are in addition bounded convex sets with nonempty
> interior, then they have the same interior and the same closure — that is, they are the *same
> body*.

This subsumes and unifies earlier uniqueness results known separately for rational polytopes and
for symmetric convex bodies, results whose original proofs required elaborate,
case-specific geometric constructions. The argument below needs none of that.

### The trick: make the grid so coarse it can only see one point

The heart of the matter is a piece of deliberate under-sampling. Suppose both $P$ and $Q$ live
inside the ball of radius $R$ about the origin. Choose $t$ so small that the grid spacing $1/t$
exceeds $2R$, the diameter of that ball. Then the grid $\tfrac1t\mathbb{Z}^d$ is so sparse that
**at most one** of its points can possibly lie in the ball: two distinct grid points differ by at
least $1/t > 2R$ in some coordinate, and no two points of the ball are that far apart.

Shifting is what lets us aim. If we translate by an integer vector $v$, the counted grid becomes
$\tfrac1t\mathbb{Z}^d - v$, still of spacing $1/t$, but now positioned differently. So the
measurement
$$L_{P+v}(t) \;=\; \bigl|\{\, k \in \mathbb{Z}^d \;:\; k/t - v \in P \,\}\bigr|$$
is either $0$ or $1$, and it equals $1$ *exactly when the single visible grid point lies in $P$*.
The enumerator has become a one-bit oracle: point a very sparse grid at a chosen location and ask
"is this point in the set?"

Which locations can we aim at? Writing $s = 1/t$ for the spacing, the visible point is
$$x \;=\; s\,k - v, \qquad k, v \in \mathbb{Z}^d, \quad s > 2R.$$
This is the master lemma: **for every point of that form, membership in $P$ and membership in $Q$
must agree.** (Points outside the ball are in neither set, so they are handled for free.)

### Every rational point is reachable

Now the arithmetic. Given any rational point $x = a/N$ with $a \in \mathbb{Z}^d$ and
$N \geq 1$ an integer, set
$$M = \lceil 2R \rceil + 2, \qquad s = M + \frac1N, \qquad k = a, \qquad v = M a .$$
Then $s > 2R$ as required, and
$$s\,k - v \;=\; a\Bigl(M + \frac1N\Bigr) - Ma \;=\; \frac{a}{N} \;=\; x .$$
The probe lands exactly on $x$. Hence:

> **Rational rigidity.** If two bounded sets have the same integer-translate enumerator data, then
> they contain *exactly* the same rational points — with no measurability, convexity or
> regularity hypothesis whatsoever.

That is a startlingly strong statement obtained from a startlingly cheap argument. One chooses a
grid spacing that is an integer plus $1/N$; the integer part is absorbed by the integer
translation, and the leftover $1/N$ is precisely the resolution needed to hit $a/N$.

### From rational points to the theorem

The rational points are dense, so the last step is soft. If $x$ lies in the interior of $P$, a
whole ball around $x$ is inside $P$; that ball contains rational points; those rational points
belong to $Q$ as well; hence $x$ lies in the closure of $Q$. So
$$\operatorname{int}(P) \subseteq \overline{Q}, \qquad \operatorname{int}(Q) \subseteq \overline{P}.$$
Off the two boundaries — a set of full measure, by hypothesis — being in a set is the same as
being in its interior and the same as being in its closure, so membership in $P$ and $Q$ agrees
almost everywhere. That is the Uniqueness Theorem.

For convex bodies one can do better than "almost everywhere", because a convex set with nonempty
interior satisfies $\operatorname{int}(\overline{K}) = \operatorname{int}(K)$ and
$\overline{\operatorname{int}(K)} = \overline{K}$. Feeding the two inclusions above through these
identities gives $\operatorname{int}(P) = \operatorname{int}(Q)$ and
$\overline{P} = \overline{Q}$ exactly. A convex body is completely determined by how many grid
points its integer translates contain at each real magnification.

---

## Two sharper endpoints

The theorem's "almost everywhere" is not laziness — in general the data really cannot see a
single stray point in a generic position. But two variants sharpen it in different directions.

**Dimension one is rigid on the nose.** On the line, take $k = 1$ and any integer $n$ with
$s = x + n > 2R$; then $s\cdot 1 - n = x$. Every real point is reachable, not merely every
rational one. So two bounded subsets of $\mathbb{R}$ with the same integer-translate enumerators
are *literally equal as sets* — no measurability, no boundary condition, no exceptions. What
fails in higher dimension is only that a single spacing $s$ must serve all $d$ coordinates at
once, which is why the reachable set shrinks to $\{sk - v\}$ and, in effect, to $\mathbb{Q}^d$.

**Allowing real slides restores exact equality in every dimension.**

> **Rigidity for real translates.** If $P, Q \subseteq \mathbb{R}^d$ are bounded and
> $L_{P+y}(t) = L_{Q+y}(t)$ for every real $t > 0$ and *every* real vector $y \in \mathbb{R}^d$,
> then $P = Q$ exactly.

The proof is a single line of the same idea: to test whether $x \in P$, take
$t = 1/(2R+1)$ and $y = -x$. The origin is then a counted grid point precisely when $x \in P$,
and sparseness guarantees it is the *only* candidate. This pinpoints exactly where the difficulty
of the main theorem lies: with real translates you can aim anywhere, so nothing is lost; with
integer translates you can only aim at a countable dense set, and a null set of information is
irretrievably lost.

---

## The Fourier side of the story

There is a second, more analytic way to see the information content of the enumerator, and it
explains the phrase "Fourier-analytic" in the theorem's pedigree. Instead of merely counting the
grid points inside $tP$, weight them. For a bounded continuous $g : \mathbb{R}^d \to \mathbb{C}$,

> **Weighted Counting Theorem.** For $P$ bounded with negligible boundary,
> $$\frac{1}{t^{d}} \sum_{k \in tP \cap \mathbb{Z}^d} g\!\left(\frac{k}{t}\right) \;\xrightarrow[t \to \infty]{}\; \int_{P} g(x)\, dx .$$

Taking $g \equiv 1$ recovers the Counting Theorem. Taking the character
$g(x) = e^{-2\pi i \langle \xi, x\rangle}$ gives something far more interesting:

> **Fourier recovery.** For every frequency $\xi \in \mathbb{R}^d$,
> $$\frac{1}{t^{d}} \sum_{k \in tP \cap \mathbb{Z}^d} e^{-2\pi i \langle \xi,\, k/t \rangle} \;\xrightarrow[t \to \infty]{}\; \widehat{\mathbf{1}_P}(\xi) \;=\; \int_{P} e^{-2\pi i \langle \xi, x \rangle}\, dx .$$

The proof is the same exact cube identity as before, now applied to the step function
$x \mapsto \mathbf{1}_{A_t}(x)\, g(\lfloor tx\rfloor / t)$, whose integral is *exactly*
$t^{-d} \sum_{k} g(k/t)$; dominated convergence, with all $A_t$ trapped in one ball and $|g|$
bounded, finishes it.

The consequence is conceptually the punchline: the lattice data determines the entire Fourier
transform of the indicator function of $P$, at every frequency. And the Fourier transform
determines $\mathbf{1}_P$ almost everywhere. Where the sparse-grid proof reads the indicator
directly, one point at a time, the Fourier proof reads all of it at once through its spectrum.
Two proofs, one theorem, complementary intuitions: local sampling versus global spectra.

---

## Why anyone should care

**Lattices are the currency of modern cryptography.** Post-quantum schemes rest on the difficulty
of problems about points of a lattice inside a body — finding short vectors, decoding to the
nearest lattice point, or estimating $|K \cap \Lambda|$ for a convex $K$. The Counting Theorem is
the heuristic that every such analysis begins with ("the number of lattice points is about the
volume"); the exact cube identity turns that heuristic into an equality plus an explicitly
controlled discretisation. And the Uniqueness Theorem says something with a security flavour:
*counting queries leak the shape*. An adversary who can only learn how many lattice points a
secret region contains, but who may choose the scale freely and shift by lattice vectors, learns
the region completely. Any protocol whose security relies on hiding a body behind counting
statistics is, in this idealised model, insecure.

**Tomography without directions.** Classical geometric tomography reconstructs a body from
its sections or projections. Here the probe is different — arithmetic rather than geometric — and
the reconstruction is total. The sparse-grid argument is not just an existence proof: it is an
explicit algorithm. To decide whether $a/N$ lies in the unknown body inside radius $R$, issue a
single query at $t = 1/(M + 1/N)$ with $M = \lceil 2R\rceil + 2$, translated by $Ma$, and read
off the answer as $0$ or $1$.

**A lesson about sampling.** Most of analysis is spent worrying about sampling *finely enough* —
Nyquist rates, aliasing, resolution. The engine of this theorem is the exact opposite: deliberate
under-sampling. By making the grid absurdly coarse, so coarse that it can contain at most one
point of the body, one converts a global count into a local yes/no. Then one uses arithmetic —
the fact that spacing $M + 1/N$ combined with an integer shift $Ma$ lands exactly on $a/N$ — to
steer that single visible point wherever one likes. Coarseness is what buys locality; arithmetic
is what buys aim.

That is the whole idea, and it is small enough to carry in your head. Zoom out until the grid can
see only one point of the shape. Slide by an integer amount so that the visible point is exactly
where you want to look. Ask "how many?" The answer is a single bit, and enough of those bits
reconstruct the world.
