# A Tree That Grows Every Right Triangle

## How three matrices, a single seed, and a quarter of a circle explain why perfect right triangles are both everywhere and almost nowhere

Take a sheet of graph paper and try to draw a right triangle whose three sides
are all whole numbers. If you have not seen the trick, this is surprisingly
hard: almost every triangle you draw will have an irrational hypotenuse. The
famous ones — $3,4,5$ and $5,12,13$ — feel like lucky accidents, isolated gems
scattered through the integers.

They are not accidents. They are the nodes of a single tree.

In 1934 the Swedish mathematician B. Berggren discovered something remarkable:
there are exactly three integer matrices which, applied over and over to the
starting triangle $(3,4,5)$, generate *every* primitive right triangle exactly
once. No triangle is missed. No triangle appears twice. The entire, apparently
chaotic population of Pythagorean triples is in fact a perfectly regular ternary
tree, growing from one seed.

This article is about a question you can ask once you know that: **if you draw a
box, how much of the box does the tree fill?**

---

## The three matrices

Write a triple as a column vector $(a,b,c)$, meaning the triangle with legs $a$
and $b$ and hypotenuse $c$. Berggren's three matrices are

$$
B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},
\qquad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},
\qquad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}.
$$

Feed them $(3,4,5)$ and watch:

$$
B_1(3,4,5) = (5,12,13),\qquad B_2(3,4,5) = (21,20,29),\qquad B_3(3,4,5)=(15,8,17).
$$

All three outputs are right triangles. Apply the matrices again to each of
those and you get nine more; then twenty-seven; and so on forever. The first
few generations look like this:

```
                       (3,4,5)
        ┌─────────────────┼─────────────────┐
    (5,12,13)         (21,20,29)        (15,8,17)
   ┌────┼────┐       ┌────┼────┐      ┌────┼────┐
(7,24,25) ...     (39,80,89) ...   (33,56,65) ...
```

Two facts make this a *theorem* rather than a curiosity.

**Closure.** Every triple the tree produces is a genuine primitive right
triangle: the sides satisfy $a^2+b^2=c^2$, they are all positive, the two legs
share no common factor, and — a detail that will matter enormously — the *first*
leg $a$ is always odd. This is a direct algebraic check: if $a^2+b^2=c^2$ then
expanding $B_i(a,b,c)$ and simplifying returns the Pythagorean identity again,
and a short parity argument keeps the first coordinate odd.

**Completeness.** Conversely, every positive primitive triple with odd first
leg appears somewhere in the tree. This is the deep half, and it is proved by
*descent*. Given such a triple $(a,b,c)$ that is not the seed, define its
candidate parent's hypotenuse

$$w = 3c - 2a - 2b.$$

One shows $0 < w < c$: strictly smaller than what you started with. Two further
linear forms,

$$u = a + 2b - 2c, \qquad v = 2a + b - 2c,$$

decide *which* of the three inverse matrices to apply — their sign pattern
selects a unique legal parent, and $(\pm u, \pm v, w)$ is again a positive
primitive triple with odd first leg. Since the hypotenuse strictly decreases at
every step and hypotenuses are positive integers, the descent must terminate,
and the only place it can terminate is at $(3,4,5)$. Running the descent
backwards writes the original triple as a word in $B_1,B_2,B_3$.

Put together: **the Berggren tree is exactly the set of positive primitive
Pythagorean triples with odd first leg.** And the tree is *free*: two different
words in the three matrices never produce the same triple, so each triple has
exactly one address.

---

## Now draw a box

Fix a height $H$ and consider the cube of integer points

$$\{(a,b,c) : 1 \le a,b,c \le H\},$$

which contains $H^3$ triples. How many of those $H^3$ points are Berggren
triangles?

The answer, sharp on both sides, is: **about $H$ of them — no more, no fewer, up
to a constant factor.**

$$\frac{H}{100} \;\le\; \#\{\text{tree triples in the box}\} \;\le\; \min\left(4H,\ \left(\lfloor\sqrt H\rfloor + 1\right)^2\right)
\qquad (H \ge 5).$$

Two very different arguments produce the two sides.

### The ceiling: a pair of squares

Here is the trick that gives the upper bound. If $(a,b,c)$ is a primitive triple
with $a$ odd, then

$$c + a = 2m^2, \qquad c - a = 2n^2$$

for integers $m$ and $n$. (This follows from the classical parametrisation
$a = m^2-n^2$, $b=2mn$, $c=m^2+n^2$.) So the map

$$(a,b,c) \;\longmapsto\; (c+a,\ c-a)$$

sends every tree triple in the box to a pair of *doubled squares*. It is
injective: from $c+a$ and $c-a$ you recover $a$ and $c$, and then $b$ is
determined by $b^2 = c^2-a^2$ with $b>0$. And if $c \le H$ then $m^2 \le H$ and
$n^2 \le H$, so $m$ and $n$ each range over at most $\lfloor \sqrt H\rfloor + 1$
values. Counting the target set gives at most $(\lfloor\sqrt H\rfloor+1)^2$
triples — which, since $\lfloor\sqrt H\rfloor^2 \le H$, is at most $4H$.

Notice how little work this is. Two subtractions turn a three-dimensional
counting problem into a two-dimensional one, and the constraint "must be a
square" collapses the dimension count from $H^2$ to $H$.

### The floor: how many fractions are in lowest terms?

The lower bound runs the parametrisation the other way. Take any pair of
integers $1 \le n < m$ that are **coprime** and of **opposite parity** (one even,
one odd). Then

$$(m^2-n^2,\ 2mn,\ m^2+n^2)$$

is a primitive triple with odd first leg, hence a node of the tree; and if
$m^2+n^2 \le H$ it sits inside the box. Different pairs give different triples.
So the question becomes: *how many coprime opposite-parity pairs fit in a
quarter disc of radius $\sqrt H$?*

This is a classical density question in disguise. The probability that two
random integers are coprime is $6/\pi^2 \approx 0.608$ — a fact that goes back
to Dirichlet. An effective, completely elementary version suffices here: among
all pairs in a square $[1,X]^2$, the *non*-coprime ones are counted by
overcounting, for each $g \ge 2$, the multiples of $g$; that gives at most
$\sum_{g \ge 2} (X/g)^2 \le \tfrac{25}{36}X^2$ bad pairs, hence at least
$\tfrac{11}{36}X^2$ coprime ones. Symmetry $n \leftrightarrow m$ costs another
factor $2$, and discarding the same-parity pairs costs at most another factor
$2$ (if $n$ and $m$ are both odd and coprime, then $\tfrac{m+n}2, \tfrac{m-n}2$
is a coprime opposite-parity pair — an injection). Chaining these losses
through the parametrisation gives the constant $1/100$. It is crude, but it is
unconditional and explicit.

### The consequence: a vanishing fraction

The box has $H^3$ points; the tree contributes at most $4H$ of them. Therefore

$$\frac{\#\{\text{tree triples in the box}\}}{H^3} \;\le\; \frac{4}{H} \;\longrightarrow\; 0.$$

Perfect right triangles are **vanishingly rare**. If you throw a dart at the box
$[1,H]^3$ for large $H$, your chance of hitting a Pythagorean triple decays like
$1/H^2$. At $H = 20\,000$ there are $3186$ tree triples among $8\times10^{12}$
lattice points — a proportion of about $4 \times 10^{-10}$.

---

## The twist: rare, but complete

Rare among *all* triples — but that is only half the story, and it is the less
interesting half. The original question also asked how the tree compares to the
population it actually lives in: the primitive Pythagorean triples themselves.
There the expectation was that the tree should capture a $(1-o(1))$ proportion
of them.

It does better. It captures **all** of them, exactly, with no error term.

Here is why. In a primitive Pythagorean triple, exactly one of the two legs is
odd. (Both cannot be even — they are coprime. Both cannot be odd, because then
$c^2 \equiv 2 \pmod 4$, and no square is $2$ mod $4$.) The tree, we said,
consists precisely of the triples whose *first* leg is odd. So swapping the two
legs is a perfect pairing between the triples the tree contains and the triples
it does not:

**Every primitive Pythagorean triple in the box is in the tree, or becomes a
tree triple after swapping its two legs.**

Counting ordered triples, this says

$$\#\{\text{primitive triples in the box}\} = 2 \cdot \#\{\text{tree triples in the box}\}.$$

The "$1-o(1)$" in the original conjecture is really an exact $1$: as a set of
*triangles* (unordered legs), the Berggren tree is not merely dense in the
primitive Pythagorean triples — it *is* them.

So the picture is a pleasing tension. The tree fills a vanishing sliver of the
box, $\Theta(H)$ points out of $H^3$; and yet inside that sliver it misses
nothing. The rarity is a statement about the ambient space; the completeness is
a statement about the tree.

---

## What the constant really is

The bounds above pin the count between $H/100$ and $H$. Computation says the
truth is far more precise. The count of tree triples with all entries at most
$H$ begins

| $H$ | count | count$/H$ |
|---|---|---|
| $1\,000$ | $158$ | $0.1580$ |
| $5\,000$ | $792$ | $0.1584$ |
| $100\,000$ | $15\,919$ | $0.15919$ |
| $400\,000$ | $63\,669$ | $0.159172$ |
| $1\,000\,000\,000$ | $159\,154\,994$ | $0.15915499$ |

and the ratio is converging, unmistakably, to

$$\frac{1}{2\pi} = 0.15915494\ldots$$

Where does $\pi$ come from in a problem about right triangles with integer
sides? From the geometry hidden in the parametrisation. The counting problem is
*exactly equivalent* — a bijection, not an estimate — to counting lattice points
$(n,m)$ with $0 < n < m$, $\gcd(n,m)=1$, $n+m$ odd, and $m^2+n^2 \le H$. That is
a count of **visible** points (points you can see from the origin, with nothing
blocking the line of sight) in a **quarter disc** of radius $\sqrt H$, restricted
to the wedge below the diagonal, filtered by parity. Assemble the three factors:

$$\underbrace{\frac{\pi H}{8}}_{\text{area of the wedge}} \times
\underbrace{\frac{6}{\pi^2}}_{\text{visible}} \times
\underbrace{\frac{2}{3}}_{\text{opposite parity}} \;=\; \frac{H}{2\pi}.$$

The area of the eighth-disc supplies the $\pi$ upstairs; the coprimality density
$6/\pi^2$ — the reciprocal of $\zeta(2)$ — supplies a $\pi^2$ downstairs; and
the parity filter, which among coprime pairs keeps two out of three, supplies
the $2/3$. Everything cancels down to $1/(2\pi)$.

This is a Lehmer-type constant, and turning the heuristic into a theorem with an
error term is the natural next target. The bijection with the visible-point
count is already exact and unconditional; what remains is a Gauss circle problem
carrying a Möbius weight, and one expects

$$\#\{\text{tree triples in } [1,H]^3\} = \frac{H}{2\pi} + O\!\left(\sqrt H \log H\right).$$

---

## Two speeds of growth

One last feature deserves mention, because it explains why the tree looks so
lopsided when you draw it.

The three matrices do not grow triangles at the same rate. $B_2$ is
*hyperbolic*: it multiplies the hypotenuse by more than $5$ each time — the exact
expansion factor is the silver-ratio square $3+2\sqrt2 = 5.8284\ldots$, and the
hypotenuses along the pure-$B_2$ branch are

$$5,\quad 29,\quad 169,\quad 985,\quad 5741,\quad 33461,\ \ldots$$

racing off exponentially. (These are alternate Pell numbers, and the triangles
they carry, $(3,4,5), (21,20,29), (119,120,169), \ldots$, are the ones whose legs
differ by one.)

$B_3$, by contrast, is *unipotent* — parabolic. It has $1$ as its only
eigenvalue, and it preserves the quantity $c - a$. Applying it $k$ times to
$(3,4,5)$ gives a beautifully explicit family:

$$\bigl(4(k+1)^2 - 1,\ \ 4(k+1),\ \ 4(k+1)^2 + 1\bigr) = (3,4,5), (15,8,17), (35,12,37), (63,16,65),\ldots$$

The hypotenuse grows only *quadratically* in the depth. So while a generic node
at depth $d$ has hypotenuse at most $5 \cdot 6^d$, the parabolic spine reaches
depth $k$ with hypotenuse just $4(k+1)^2+1$. Inside the box of height $H$ the
tree therefore reaches depth of order $\sqrt H$ — and this is *seed-independent*:
starting from any primitive triple with hypotenuse $c$, the parabolic orbit
contributes at least $K$ distinct triangles to the box whenever $7K^2c \le H$.

The resulting shape is extraordinarily unbalanced: at height $H = 100\,000$ the
tree holds $15\,919$ triangles whose *typical* depth is about $15$ — logarithmic
in $H$, as one expects from an exponentially branching structure — while its
deepest node sits at depth $222$, out along a nearly-linear parabolic tendril.
A dense exponential bush with a few long thin whiskers.

---

## Why this matters

The story here is a small, complete instance of a pattern that recurs all over
number theory. A set defined by a *rule of generation* (apply these matrices,
starting here) turns out to coincide with a set defined by a *property*
(primitive, Pythagorean, odd first leg) — and once you know that, the counting
question migrates into geometry, where it becomes a question about visible
lattice points in a disc, and $\pi$ appears out of nowhere.

Along the way we get three quantitatively different answers to "how common are
Pythagorean triples?", and all three are correct:

- Among all integer triples in a box: **vanishingly rare**, a fraction $O(1/H^2)$.
- Among triples in a box, counted linearly: **exactly $\Theta(H)$**, with density
  approaching $1/(2\pi)$ per unit of height.
- Among primitive Pythagorean triples: **all of them**, no exceptions, once you
  allow the two legs to be written in either order.

Rarity and completeness are not in conflict. They are answers to different
questions — and knowing which question you are asking is, as usual, most of the
mathematics.
