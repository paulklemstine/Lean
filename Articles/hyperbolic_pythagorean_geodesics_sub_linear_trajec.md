# The Shortcut That Wasn't: Pythagorean Triples on a Hyperbolic Map

## A tree older than algebra

Every schoolchild meets $3^2 + 4^2 = 5^2$. Fewer meet the astonishing fact that
*every* primitive Pythagorean triple — every triple $(a,b,c)$ of positive integers
with $a^2 + b^2 = c^2$ and no common factor — descends from $(3,4,5)$ by a fixed
recipe, and does so exactly once.

The recipe is a tree. Each triple has precisely three children, obtained by
multiplying the column vector $(a,b,c)$ by one of three fixed $3\times 3$ integer
matrices. Start at $(3,4,5)$; apply the three matrices; you get $(5,12,13)$,
$(21,20,29)$, $(15,8,17)$. Apply them again, and again. Nothing is ever produced
twice, and nothing is ever missed. This is *Berggren's tree*, and it is one of the
most perfect objects in elementary number theory: an infinite ternary tree that
enumerates a set nobody had a right to expect could be enumerated so cleanly.

It is also, for exactly that reason, an object that keeps tempting people into a
dangerous hope. Pythagorean triples know about factoring. A number $N$ that can be
written as a sum of two squares in *two essentially different ways* is
automatically composite — Euler knew this in the 1740s, and his proof gives you a
factor by computing one greatest common divisor. So if you could navigate
Berggren's tree cleverly, hunting for two nodes that share a hypotenuse, you would
be factoring integers. And a tree with three-fold branching reaches depth $k$ nodes
of size roughly $3^k$ — so surely finding what you want takes only $O(\log N)$ steps?

This article is about what happens when you put that hope on a map: specifically,
on the hyperbolic plane. The map turns out to be exquisitely well adapted to the
tree — so well adapted that it lets us prove, with complete precision, that the
hope is false, and *why*.

## A change of coordinates, and a change of geometry

The first move is to stop looking at triples and start looking at their
**Euclid seeds**. Every primitive triple is
$$(a,b,c) = (m^2 - n^2,\; 2mn,\; m^2+n^2)$$
for a unique pair $(m,n)$ with $0 < n < m$, $\gcd(m,n) = 1$, and $m+n$ odd. In these
coordinates, Berggren's three ugly matrices become three beautifully simple linear
maps:
$$B_1 : (m,n) \mapsto (2m-n,\, m), \qquad B_2 : (m,n) \mapsto (2m+n,\, m), \qquad B_3 : (m,n) \mapsto (m+2n,\, n).$$
The root is $(2,1)$, which is $(3,4,5)$. Everything the tree does is now visible in
two integer coordinates instead of three.

The second move is geometric. Send each seed $(m,n)$ to the point
$$z(m,n) \;=\; \frac{n + i}{m} \;=\; \frac{n}{m} + \frac{i}{m}$$
in the **Poincaré upper half-plane** — the upper half of the complex plane, equipped
with the hyperbolic metric $ds = |dz|/y$ in which vertical distances are measured
logarithmically and horizontal distances are cheap high up and expensive down near
the real axis. The natural base point is $i$, and the root seed $(2,1)$ lands at
$(1+i)/2$.

Why this point? Because of a small miracle. In the half-plane, the hyperbolic
distance $d$ between two points $z_1, z_2$ satisfies
$\cosh d = 1 + \frac{|z_1 - z_2|^2}{2\,\mathrm{Im}(z_1)\,\mathrm{Im}(z_2)}$. Plug in
$z_1 = i$ and $z_2 = (n+i)/m$, clear denominators, and the mess collapses to

> **Exact Distance Formula.** For any $m > 0$,
> $$\cosh d\bigl(i,\, z(m,n)\bigr) \;=\; \frac{m^2 + n^2 + 1}{2m}.$$

The numerator is the *hypotenuse plus one*. The hyperbolic geometry of the
half-plane has, entirely of its own accord, produced the arithmetic invariant we
care about.

## Every triple is close to the origin

Write $c = m^2 + n^2$ for the hypotenuse. Since $\cosh d \approx \tfrac{1}{2}e^{d}$ for
large $d$, and since $n < m$ forces $m$ to be within a factor $\sqrt2$ of $\sqrt c$,
the formula immediately gives:

> **Logarithmic Trajectory Theorem.** For every Euclid seed $(m,n)$ with hypotenuse
> $c = m^2+n^2$,
> $$\left| \,d\bigl(i, z(m,n)\bigr) - \tfrac12 \log c \,\right| \;\le\; \log 2 .$$

This can be sharpened until almost nothing is left to sharpen. The lower bound
holds with *no* additive constant at all: $d \ge \tfrac12 \log c$, always. And the
upper bound is $d \le \tfrac12 \log\bigl(2(c+1)\bigr)$. So every node of the tree,
no matter how deep, lies in a half-open annulus of width only
$\tfrac12\log 2 \approx 0.3466$:
$$\tfrac12 \log c \;\le\; d \;<\; \tfrac12\log c + \tfrac12 \log 2 + o(1).$$

This is genuinely striking. The tree branches exponentially, its entries explode in
size, and yet in hyperbolic terms *nothing goes far away*. A triple with a
hypotenuse of a trillion sits at distance about $13.8$ from the origin. A triple with
a hypotenuse of $10^{100}$ sits at distance about $115$. The hyperbolic metric
compresses the whole arithmetic universe of Pythagorean triples onto a
logarithmic scale.

## The residual: reading the slope off the geometry

Distance is $\tfrac12 \log c$ plus a bounded correction. What *is* the correction?
Call it the **residual**,
$$\rho(m,n) \;=\; d\bigl(i, z(m,n)\bigr) - \tfrac12 \log\bigl(m^2 + n^2\bigr) .$$
Numerically it wanders around in $[0, 0.347)$ with no obvious pattern — until you
plot it against the *slope* $t = n/m$, at which point it lies almost perfectly on a
single curve. That curve is
$$\tilde\rho(t) \;=\; \tfrac12 \log\bigl(1 + t^2\bigr),$$
and the "almost" can be made exact. Setting $S = \sqrt{(c+1)^2 - 4m^2}$, one finds the
clean identity
$$\exp\bigl(\rho - \tilde\rho\bigr) \;=\; \frac{(c+1) + S}{2c},$$
and then the elementary factorisation
$$\bigl(S - (c-1)\bigr)\bigl(S + (c-1)\bigr) \;=\; (c+1)^2 - 4m^2 - (c-1)^2 \;=\; 4\bigl(c - m^2\bigr) \;=\; 4n^2$$
turns a catastrophic near-cancellation of two almost-equal quantities into a
harmless quotient. The conclusion is a two-sided bound with no slack left:

> **Residual Gap Theorem.** With $c = m^2+n^2$,
> $$\frac{n^2}{c^2 + n^2} \;\le\; \rho(m,n) - \tilde\rho(n/m) \;\le\; \frac{c+1}{c-1}\cdot\frac{n^2}{c^2+n^2}.$$
> In particular the gap equals $\dfrac{n^2}{c^2}\bigl(1 + O(1/c)\bigr)$, uniformly in the slope.

For the seed $(4,1)$ this pins the gap between $0.003448$ and $0.003676$; the true
value is $0.0036543\ldots$. So the residual really is a function of the slope alone,
to within an error that dies like the square of the hypotenuse.

## What each branch does to the residual

Now the tree and the geometry can talk to each other. Each of $B_1, B_2, B_3$
changes the slope $t = n/m$ in a definite way:
$$B_1: t \mapsto \frac{1}{2-t}, \qquad B_2 : t \mapsto \frac{1}{2+t}, \qquad B_3 : t \mapsto \frac{t}{1+2t}.$$
For $B_1$, the inequality $t \le 1/(2-t)$ is just $(1-t)^2 \ge 0$: the slope always goes
*up*. For $B_3$, dividing by $1 + 2t > 1$ always sends the slope *down*. So on those
two branches the slope model of the residual is monotone, and for a trivial reason.

$B_2$ is where it gets interesting. The map $t \mapsto 1/(2+t)$ has a fixed point at
$t = \sqrt2 - 1 \approx 0.4142$: above it the slope decreases, below it the slope
increases. So $B_2$ is monotone in one direction on some seeds and the other
direction on others, the dividing line being the algebraic condition
$m^2 = 2mn + n^2$.

But all of this is about the *model* $\tilde\rho$, and the model differs from the
truth by a term of size $n^2/c^2$. Right at the dividing line, the predicted change
in the residual is itself tiny — comparably tiny. Does the model's prediction
survive contact with the exact hyperbolic distance? That is the delicate question,
and the answer is yes, completely:

> **Exact Branch Monotonicity.** For *every* Euclid seed $(m,n)$:
> 1. $\rho(m,n) \le \rho(2m-n,\, m)$ — the residual never decreases along $B_1$;
> 2. $\rho(m+2n,\, n) \le \rho(m,n)$ — the residual never increases along $B_3$;
> 3. $\rho(2m+n,\, m) \le \rho(m,n)$ if $m^2 < 2mn + n^2$, and $\rho(m,n) \le \rho(2m+n,\, m)$ if $2mn + n^2 < m^2$.
>
> Moreover no Euclid seed satisfies $m^2 = 2mn+n^2$ exactly, so clause 3 is a genuine
> dichotomy with no case left open: the exact residual always moves in the direction
> the slope model predicts.

The reason no seed sits exactly on the line is charming: $m^2 = 2mn+n^2$ means
$(m-n)^2 = 2n^2$, i.e. $\sqrt 2$ is rational. Coprimality does the rest.

The proof of clause 3 has a sting in its tail. It works by bounding the slope gap
from below by an algebraic quantity and the residual gap from above by another, and
comparing. For most seeds the comparison holds for *real* $m,n$ and needs no
arithmetic. But there is a boundary layer: seeds with $m^2 = 2mn + n^2 + 1$, which
is to say $(m-n)^2 = 2n^2 + 1$ — a **Pell equation**, whose solutions are
$$(m,n) = (5,2),\ (29,12),\ (169,70),\ (985,408),\ \ldots$$
On this family the real-variable inequality genuinely *fails* (it breaks down near
the non-integral point $(m,n) \approx (3.80,\, 1.48)$), and one must use the integrality
consequence $n \ge 2$ forced by the Pell equation itself. At the smallest member,
$(5,2)$, the margin of victory is about $0.9\%$. The oldest Diophantine equation in
the book turns up as the exact obstruction, and closing the gap requires knowing that
you are standing on integers.

## The hope, and its refutation

Now back to factoring. Two nodes of the tree with the same hypotenuse $N$ give two
essentially distinct representations $N = m_1^2+n_1^2 = m_2^2+n_2^2$, and Euler's
identity converts that into a factorisation. In fact one gets the complete split at
once: for odd $N$ with both representations primitive,
$$\gcd\bigl(N,\, m_1m_2 + n_1n_2\bigr)\cdot\gcd\bigl(N,\, m_1n_2 + n_1m_2\bigr) \;=\; N,$$
with both factors strictly between $1$ and $N$. The smallest instance: $65 = 8^2+1^2 = 7^2+4^2$,
and $\gcd(65,\, 8\cdot7 + 1\cdot4) = \gcd(65,60) = 5$. The compositeness of $65$ has been
deduced from a collision of two points in the hyperbolic plane. And such collisions
are not rare: the seeds $(20j+9,\, 10j+2)$ and $(20j+7,\, 10j+6)$ collide for every
$j \ge 0$, both with hypotenuse $500j^2 + 400j + 85$, so collisions occur at every scale.

Better yet, colliding nodes are geometric *neighbours*. Both lie on the level set
$2m\cosh d = N+1$ — an "isohypotenuse" curve — so their distances from the origin
differ by at most $\log 2$. Everything the optimist could want: a short trajectory, a
tight annulus, an arithmetic payoff waiting at every collision.

And yet the whole programme dies, for a reason that is itself a theorem.

> **Quadratic Ball Growth.** For every $K \ge 256$, the hyperbolic ball of radius
> $R = \log K + 2$ about the base point $i$ contains at least $e^{2R}/300$ distinct
> Berggren nodes.

The exponent is $2R$, not $R$. Since a node of hypotenuse $c$ sits at distance
$\approx \tfrac12 \log c$, radius $R$ corresponds to hypotenuse $\approx e^{2R}$ — and the
theorem says the number of nodes inside is of that same order. The ball that is
*guaranteed* to contain a colliding pair for a target $N$ already contains on the
order of $N$ nodes.

This is a no-free-lunch result of a peculiarly satisfying kind. The compression is
real: distances are logarithmic. But hyperbolic space punishes compression with
volume. Everything is nearby, and there is an exponential amount of nearby. Short
geodesics, exponentially many of them.

Proving it is harder than it sounds, because the obstruction is arithmetic rather
than geometric. One must exhibit quadratically many *coprime* pairs of opposite
parity inside a box — that is, run a sieve. The count works out: in the box of even
$m \in (2K, 4K]$ and odd $n \in [1,2K]$, at least $K^2/4$ of the $K^2$ pairs are coprime.

## Depth versus distance

There is a last twist, and it is the one that kills the literal "$O(\log N)$ path
length" slogan. Distance and depth are not the same thing.

Depth is well defined: the tree really is a tree. Every Euclid seed is reachable
from $(2,1)$, and reachable at exactly one depth — the inverse move is a clean
trichotomy in the slope, with $n/m \in (\tfrac12,1)$, $(\tfrac13,\tfrac12)$, $(0,\tfrac13)$
selecting $B_1$, $B_2$, $B_3$ respectively.

At depth $k$ one has $m \le 2\cdot 3^k$, hence $\log c \le \log 8 + k\log 9$, hence
$$2\,d\bigl(i,z\bigr) \;\le\; \log 32 + k \log 9 .$$
Distance is bounded by depth. Is depth bounded by distance? No — catastrophically
not. Consider the **left spine**, obtained by applying $B_1$ over and over:
$$(2,1) \to (3,2) \to (4,3) \to (5,4) \to \cdots$$
The node at depth $k$ is the seed $(k+2, k+1)$, whose hypotenuse is only
$2k^2 + 6k + 5$. Its hyperbolic distance from the origin is about $\log k$, but its depth
is $k \approx \sqrt{c/2}$. There is no constant $C$ with $\text{depth} \le C\cdot\text{distance}$;
this is not merely unproven, it is false.

The **middle spine**, generated by $B_2$, behaves oppositely: its first coordinates
are the Pell numbers $2, 5, 12, 29, 70, \ldots$, the hypotenuse is at least $4^{k+1}$, and
$k \log 2 \le d$. On this branch, depth and distance are commensurable. And this
gives the one form of the original slogan that is true:

> **Logarithmic Reach.** For every $N \ge 1$ there is a node of the tree at depth
> $k = \lfloor \log_2 N\rfloor$ whose hypotenuse is at least $N$, and $k \log 2 \le \log N$.

You can *reach* size $N$ in $\Theta(\log N)$ steps — along the Pell spine, which is
where the tree grows fastest. What you cannot do is reach a *specified* node in
$O(\log N)$ steps, because most nodes of size $N$ are not on that spine, and some sit
at depth $\Theta(\sqrt N)$. And even if you could navigate perfectly, the ball you
would have to search has volume $\asymp N$.

## What the map was really for

The programme announced at the outset — factor $N$ in $O(\log N)$ by minimising
geodesic energy in the Poincaré disk — is dead, and the geometry killed it.
That is not a disappointment; it is what a good map is for. Before the map, the
question "can Berggren's tree factor integers quickly?" was a vague hope. After the
map, it is a precise statement about volume growth in hyperbolic space, and the
answer is a clean no with a quantitative reason attached.

What survives is arguably more interesting than what was hoped for. There is an
exact formula, $\cosh d = (c+1)/(2m)$, connecting a Riemannian distance to a
Pythagorean hypotenuse. There is a rigidity statement — every triple in the universe
lives in an annulus of width $0.347$ — that turns an unbounded arithmetic object into a
bounded geometric one. There is a residual that reads off the slope of the triple to
accuracy $n^2/c^2$. There is a complete dichotomy for how each of the three branches
moves that residual, valid for the exact hyperbolic metric and not merely for its
asymptotic model, whose last unresolved case is a Pell family and needs
integrality to close. And there is a sharp no-free-lunch theorem explaining, in
purely geometric language, why none of this yields a fast factoring algorithm.

The negative result is the load-bearing one. A conjecture that dies with an
explicit counterexample — the left spine, depth $k$, hypotenuse $2k^2+6k+5$ — and a
structural obstruction — exponential volume — has told you something permanent about
the landscape. The tree is beautiful; the hyperbolic plane is the right place to
look at it; and the reason integer factorisation is hard survives the change of
coordinates intact.
