# Higher-Dimensional Pythagorean Trees
### A guided tour: from $3^2+4^2=5^2$ to reflections in the light cone

---

## 1. A tree grown from a single triangle

Everyone knows $3^2+4^2=5^2$. Far fewer people know that **every** primitive Pythagorean triple —
every pair of whole-number legs with a whole-number hypotenuse and no common factor — grows from
that one triple by three simple linear rules:

$$
(a,b,c)\mapsto(a-2b+2c,\,2a-b+2c,\,2a-2b+3c),\quad
(a,b,c)\mapsto(a+2b+2c,\,2a+b+2c,\,2a+2b+3c),
$$
$$
(a,b,c)\mapsto(-a+2b+2c,\,-2a+b+2c,\,-2a+2b+3c).
$$

Applied to $(3,4,5)$ they produce $(5,12,13)$, $(21,20,29)$ and $(15,8,17)$; iterate and you get an
infinite, perfectly regular **ternary tree** containing every primitive triple exactly once.

The question this page answers is the obvious one: *what happens in higher dimensions?* A
**Pythagorean quadruple** is a solution of $a^2+b^2+c^2=d^2$ — an integer point at integer distance
from the origin in space, the smallest being $(1,2,2,3)$. Is there a tree for those? For
quintuples? For all $n$?

<details>
<summary><strong>Background: what "primitive" means and why it matters</strong></summary>

A tuple is *primitive* when the greatest common divisor of all its entries is $1$. Non-primitive
solutions are just integer multiples of primitive ones — $(2,4,4,6) = 2\cdot(1,2,2,3)$ — so all the
content is in the primitive case. As we will see, the greatest common divisor (the *content*) is
preserved by every move in this theory, which is exactly why the primitive solutions form a world
of their own, disconnected from their multiples. See
[Pythagorean quadruple](https://en.wikipedia.org/wiki/Pythagorean_quadruple) for the classical
background.
</details>

---

## 2. The secret: Pythagoras is a light cone

Rewrite the equation as
$$
x_1^2+\cdots+x_n^2-y^2 = 0 .
$$
That is the **Lorentz form** of signature $(n,1)$ — the spacetime interval of special relativity,
with $y$ as the time coordinate. Pythagorean $n$-tuples are the *integer points on the light cone*.

Any integer matrix $M$ with $M^{\mathsf T} J M = J$, where $J=\mathrm{diag}(1,\dots,1,-1)$, preserves
the form and hence permutes the solutions; such matrices have determinant $\pm1$, so their moves can
always be undone. Now take the all-ones vector $r=(1,\dots,1;1)$, whose Lorentz square is $n-1$, and
reflect in it:
$$
s_r(v) = v - \frac{2\langle v,r\rangle}{n-1}\,r, \qquad \langle v,r\rangle = x_1+\cdots+x_n-y .
$$
Because $r$ has all coordinates equal, this subtracts *the same number* from every coordinate.
Combine it with the $2^n$ sign patterns on the space coordinates and — this is the punchline — the
three classical moves above are exactly the $n=2$ case, one reflection viewed through three of the
four sign patterns. The fourth, all-plus, pattern is the **descent**, the move back toward the root.

> **The whole theory in one line.** The Pythagorean tree is a reflection in the light cone.

---

## 3. Where the ladder stops: turn the dimension dial

The shift subtracted from each coordinate is $\dfrac{2(\sum_i \varepsilon_i x_i - y)}{n-1}$. For
integer points to stay integer points, $n-1$ must divide $2$. Drag the dial below and watch the
mechanism live and die.

{{interactive_demo:1}}

So the Berggren mechanism exists in **exactly two dimensions**: $n=2$ (triples, shift $2(a+b-c)$)
and $n=3$ (quadruples, shift $a+b+c-d$). In dimension four the null vector $(1,1,1,1;2)$ is
displaced by $4/3$ in every coordinate and leaves the lattice for good. The dial also shows the
sharp growth constant
$$
\rho_n = \frac{\sqrt n+1}{\sqrt n-1},
$$
always a root of $(n-1)X^2-2(n+1)X+(n-1)$: for $n=2$ it is $3+2\sqrt2 = (1+\sqrt2)^2$, the square of
the [silver ratio](https://en.wikipedia.org/wiki/Silver_ratio); for $n=3$ it is $2+\sqrt3$, a root
of $X^2-4X+1$.

<details>
<summary><strong>Why $\rho_n$ is exactly the sharp bound (proof)</strong></summary>

One move sends the height $y$ to $y' = \dfrac{(n+1)y-2\sum_i\varepsilon_ix_i}{n-1}$. By
Cauchy–Schwarz, $\bigl|\sum_i \varepsilon_i x_i\bigr| \le \sqrt n \sqrt{\sum_i x_i^2} = \sqrt n\, y$
on the light cone, so
$$
y' \le \frac{(n+1)+2\sqrt n}{n-1}\,y = \frac{(\sqrt n+1)^2}{(\sqrt n-1)(\sqrt n+1)}\,y = \rho_n y .
$$
Equality holds when all the $\varepsilon_i x_i$ are equal and maximally negative: for $n=3$, take
$x_i = 1/\sqrt3$, $y=1$ and all signs $-1$, giving exactly $y' = 2+\sqrt3$. Since
$\rho_n^{-1} = \frac{\sqrt n-1}{\sqrt n+1}$ and $\rho_n+\rho_n^{-1} = \frac{2(n+1)}{n-1}$, the
constant satisfies $X^2-\frac{2(n+1)}{n-1}X+1 = 0$, which is the displayed quadratic.
</details>

---

## 4. The quadruple machine, hands-on

For quadruples the reflection is beautifully concrete. With $k = a+b+c-d$,
$$
(a,b,c,d) \longmapsto (a-k,\,b-k,\,c-k,\,d-k),
$$
an integer matrix, an involution, and a symmetry of the Lorentz form of signature $(3,1)$.
Attach the eight sign patterns $\varepsilon\in\{\pm1\}^3$ and you get eight moves, sending the height
$d$ to $2d-(\varepsilon_1a+\varepsilon_2b+\varepsilon_3c)$.

Play with it. Type a quadruple, or click one of the examples, and inspect all eight patterns at
once: which go down (parents), which go up (children), how the height ratio behaves, and what the
harmonic law of the next section says.

{{interactive_demo:0}}

Things worth trying in the widget:

* **$(1,4,8,9)$** — two parents, $(3,0,4,5)$ and $(3,2,6,7)$. This is where the tree property dies.
* **$(4,4,7,9)$** — one parent. Both cases occur infinitely often.
* **$(1,2,2,3)$** — a *neutral* move: the height does not change at all.
* Any node — the descent path always terminates at $(1,0,0,1)$.

<details>
<summary><strong>Why the descent always terminates (proof)</strong></summary>

Two inequalities do everything. First, for a primitive quadruple in the positive cone with $d>1$
the shift $k=a+b+c-d$ is strictly positive: if $a+b+c\le d$, squaring gives
$a^2+b^2+c^2+2(ab+bc+ca)\le d^2 = a^2+b^2+c^2$, so $ab+bc+ca\le0$; with non-negative entries this
forces at most one coordinate to be nonzero, and then primitivity gives $d=1$. Second, the new
height is positive: $(a+b+c)^2\le3(a^2+b^2+c^2)=3d^2<4d^2$, so $2d-(a+b+c)>0$. Hence the height
strictly decreases while the equation, the non-negativity and the greatest common divisor are all
preserved — and a strictly decreasing sequence of positive integers must stop. The stopping points
are the height-one nodes, i.e. the three permutations of $(1,0,0,1)$.

This gives the higher-dimensional analogue of the classical generation theorem: **every primitive
Pythagorean quadruple with non-negative space coordinates is reachable from $(1,0,0,1)$** using the
reflection, one sign change and the permutations of $a,b,c$.
</details>

---

## 5. The harmonic law: reciprocals decide the branching

Here is the heart of the matter. In dimension two, no move with a minus sign can ever descend,
because each leg is smaller than the hypotenuse: exactly one parent, always, hence a tree with
constant branching three. In dimension three, patterns with two or more minus signs still cannot
descend — but a pattern with a *single* minus sign can, and a two-line computation reveals when:

> **Harmonic Branching Law.** For a Pythagorean quadruple with positive entries, the move with a
> minus on $a$ descends if and only if
> $$a(b+c)<bc, \qquad\text{i.e.}\qquad \frac1b+\frac1c<\frac1a .$$

An Egyptian-fraction inequality controls the shape of the graph. Adding the inequality for two
different coordinates gives $2ab<0$, so it can hold for at most one of them: **a quadruple has at
most two parents**, and its branching number is $7$ or $6$.

<details>
<summary><strong>Proof of the harmonic law</strong></summary>

Descent for the pattern $(-,+,+)$ means $b+c-a>d$. Both sides are positive, so squaring is
reversible:
$$
(b+c-a)^2 > d^2 = a^2+b^2+c^2 .
$$
Expanding the left-hand side as $a^2+b^2+c^2+2bc-2ab-2ac$, the inequality becomes
$2bc-2ab-2ac>0$, i.e. $a(b+c)<bc$; dividing by $abc>0$ gives $\frac1b+\frac1c<\frac1a$. Conversely
$a(b+c)<bc$ forces $ab<bc$, so $a<c$ and $b+c-a>0$, and the same expansion run backwards yields
$b+c-a>d$. $\blacksquare$
</details>

Two explicit families settle the matter for good:

* $(1,\,2m,\,2m^2,\,2m^2+1)$ has **two** parents for every $m\ge2$, namely
  $(2m-1,0,2m^2-2m,2m^2-2m+1)$ and $(2m-1,2,2m^2-2m+2,2m^2-2m+3)$, of *different* heights;
* $(2m,\,2m,\,2m^2-1,\,2m^2+1)$ has exactly **one** parent for every $m\ge2$.

Both climb past any bound, so the branching number takes the values $6$ and $7$ infinitely often.
**The quadruple graph is not a tree.**

And on the boundary of the harmonic inequality — when $\frac1b+\frac1c=\frac1a$ — the move is
*neutral*: the height does not change. The smallest example is $(1,2,2,3)$, and there are
infinitely many.

<details>
<summary><strong>The neutral locus, completely parametrised</strong></summary>

The identity
$$
(b+c-a)^2-(a^2+b^2+c^2) = 2\bigl(bc-a(b+c)\bigr)
$$
says that $a(b+c)=bc$ *is* the statement $(b+c-a)^2=a^2+b^2+c^2$. So take any positive integers
$b,c$ whose sum divides their product, set
$$
a = \frac{bc}{b+c}, \qquad d = b+c-a,
$$
and $(a,b,c,d)$ is automatically a Pythagorean quadruple on the harmonic locus — and every one of
them arises this way. Choosing $b=m+1$, $c=m(m+1)$ gives the primitive family
$$
\bigl(m,\;m+1,\;m(m+1),\;m(m+1)+1\bigr) = (1,2,2,3),\,(2,3,6,7),\,(3,4,12,13),\,(4,5,20,21),\dots
$$
Nothing of the kind exists for triples: there, every non-descending move *strictly* increases the
hypotenuse.
</details>

Run the classifier yourself — it is three integer comparisons:

{{algorithm:2}}

---

## 6. The picture on the sphere

Divide a quadruple by its height. You land on the unit sphere $x^2+y^2+z^2=1$, the ideal boundary of
hyperbolic four-space in the [Poincaré ball model](https://en.wikipedia.org/wiki/Poincar%C3%A9_disk_model),
and the reflection acts there by a Möbius map: with the **shadow** $s=(a+b+c)/d$,
$$
u \longmapsto \frac{u-s+1}{2-s}, \qquad\text{and the height is multiplied by } 2-s .
$$
Cauchy–Schwarz gives $|s|\le\sqrt3$, so the multiplier lives in $[2-\sqrt3,\,2+\sqrt3]$.

The harmonic law is scale-invariant, so it does not see the size of a quadruple at all — only its
direction. That means two-parenthood is literally a **region on the sphere**. Here it is: red points
are nodes with a second parent, blue are nodes with a unique parent, black are the neutral ones,
and the red curves are the analytic boundary $\frac1y+\frac1z=\frac1x$.

{{visualization:1}}

The blue island in the middle is the set of "balanced" directions, where no coordinate is small
enough to satisfy the harmonic inequality. The conjectured density of two-parent nodes is exactly
the measure of the red region against the limiting distribution of primitive quadruples on the
sphere.

---

## 7. Counting: how fast do the numbers grow?

Two different growth rates must be kept apart.

* **Per step.** One move multiplies the height by a factor in $[2-\sqrt3,2+\sqrt3]$ for quadruples,
  and $[3-2\sqrt2,3+2\sqrt2]$ for triples. Steps are metrically *smaller* in dimension three.
* **In bulk.** The number of nodes of height at most $X$ grows like $X$ for triples and,
  empirically, like $X^2$ for quadruples — the boundary sphere has one more dimension to fill.

The three panels below show the branching landscape, the growth annulus (with the theoretical
bounds superimposed — nothing escapes them), and the running two-parent density.

{{visualization:0}}

{{demo:1}}

---

## 8. Algorithms

Two more algorithms complete the toolkit. The first walks a node down to the root along the
canonical spanning tree; the second grows the entire graph outward from the root — and, crucially,
needs a visited-set, because the graph has cycles.

{{algorithm:0}}

{{algorithm:1}}

<details>
<summary><strong>Why a canonical tree exists even though the graph is not a tree</strong></summary>

The all-plus pattern descends at *every* node above height one. So declare it *the* parent. It
preserves primitivity and non-negativity (after taking absolute values), strictly decreases the
height, and terminates at one of the three permutations of $(1,0,0,1)$. Its edges therefore form a
spanning tree of the quadruple graph. The right mental image for dimension three is a canonical
rooted tree *decorated* with extra edges — the harmonic second-parent edges and the neutral,
level-preserving ones. In dimension two the decoration is empty, and the tree is everything.
</details>

---

## 9. Everything at once

Finally, the full numerical demonstration: the integrality dichotomy, the identification of the
classical moves with the reflection, connectivity, branching counts, the harmonic law, the growth
constants, the boundary action and the groupoid invariants — all checked in exact integer
arithmetic.

{{demo:0}}

---

## 10. What to take away

| | triples ($n=2$) | quadruples ($n=3$) | $n\ge4$ |
|---|---|---|---|
| reflection shift | $2(a+b-c)$ | $a+b+c-d$ | fractional — no move |
| reachable from a root? | yes, from $(3,4,5)$ | yes, from $(1,0,0,1)$ | — |
| parents per node | exactly $1$ | $1$ or $2$ | — |
| children per node | $3$ | $6$ or $7$ | — |
| level-preserving moves | none | infinitely many | — |
| structure | tree | graph with cycles $+$ canonical spanning tree | — |
| sharp growth constant | $3+2\sqrt2=(1+\sqrt2)^2$ | $2+\sqrt3$ | $\frac{\sqrt n+1}{\sqrt n-1}$ formally |

The mechanism generalises; the tree does not; and what replaces the tree property is an
Egyptian-fraction law that the classical two-dimensional theory gives no hint of. Three open
problems remain, and all three are now sharply posed: the limiting density of two-parent nodes
(empirically about $0.68$ and rising), the exact quadratic growth law $N(X)\sim\kappa X^2$
(empirical exponent $1.96$), and the fine structure of the level sets stitched together by the
neutral moves.
