# The Pythagorean Star Map

*How the oldest theorem in mathematics draws a constellation on the edge of hyperbolic space — and why that constellation refuses to help you break a code.*

---

## A picture that should not have structure

Start with something every schoolchild knows: the right triangles with whole-number sides. $3,4,5$. $5,12,13$. $8,15,17$. There are infinitely many of them, and since Euclid we have known exactly how to make them all. Pick two coprime whole numbers $m > n > 0$ of opposite parity — one even, one odd — and set
$$a = m^2 - n^2, \qquad b = 2mn, \qquad c = m^2 + n^2 .$$
Then $a^2 + b^2 = c^2$, every primitive triple arises this way, and each one arises exactly once. The pair $(m,n)$ is the triple's *seed*: $(2,1)$ seeds $(3,4,5)$, $(3,2)$ seeds $(5,12,13)$, $(4,1)$ seeds $(15,8,17)$.

In 1934 the Swedish mathematician B. Berggren noticed something remarkable: the triples are not merely infinite, they are a **tree**. From $(3,4,5)$ three simple operations produce three new triples; from each of those, three more; and every primitive triple appears once and only once somewhere in this infinite ternary tree. In seed coordinates the three moves are startlingly simple:
$$B_1(m,n) = (2m-n,\ m), \qquad B_2(m,n) = (2m+n,\ m), \qquad B_3(m,n) = (m+2n,\ n).$$
That is the whole of Pythagorean arithmetic, compressed into three lines.

Now do something that Berggren could not have imagined doing: **plot it**. Send each seed $(m,n)$ to the complex number
$$z(m,n) = \frac{n + i}{m},$$
a point in the upper half of the plane, at horizontal position $n/m$ and height $1/m$. Nothing in this recipe is subtle. It merely records the two ratios that a seed naturally has.

Do this for every seed with $m$ up to a few hundred and look at the result. You do *not* see a haze of dots. You see a **star map**: sharp straight lines fanning out from the point $0$ on the bottom edge, another fan from the point $1$, fainter but unmistakable fans at $0.2$, at $0.333\ldots$, at $0.5$, and — once you know to look — at $0.6$. There is a bright single ray marching diagonally off into the interior. And there are no fans at all in between: at $\sqrt2 - 1 = 0.4142\ldots$, dense with points as it is, no line ever forms.

Why? That is the question this article answers, and the answer is that **every single feature of the picture is a theorem.** The fans are exactly the rational numbers. Their brightness is a totient. Their sharpness is a parity. And the one bright diagonal ray is the silver ratio.

---

## The metric that turns arithmetic into geometry

The upper half-plane is not just a piece of paper. Equipped with the length element $ds = |dz| / \operatorname{Im} z$, it becomes the **hyperbolic plane**: a world of constant negative curvature where the shortest paths are vertical lines and semicircles meeting the horizontal axis at right angles, and where the axis itself is infinitely far away — an "ideal boundary" you can approach forever but never reach.

The first miracle is how the plot interacts with this geometry. The hyperbolic distance from the base point $i$ to a node satisfies
$$\cosh d\big(i,\ z(m,n)\big) \;=\; \frac{m^2 + n^2 + 1}{2m} \;=\; \frac{c+1}{2m},$$
where $c$ is the **hypotenuse** of the triple. We never put the hypotenuse into the picture — we used only $n/m$ and $1/m$ — and yet the hypotenuse is what the hyperbolic metric reads off. A short computation then pins the radius:
$$\tfrac12 \log c \;\le\; d\big(i, z(m,n)\big) \;\le\; \tfrac12 \log\big(2(c+1)\big),$$
so each triple sits at hyperbolic radius $\tfrac12 \log c$, give or take less than $\log 2$. The tree grows outward in perfect lockstep with the size of its hypotenuses; every triple wears its hypotenuse as a distance badge.

That is the radial coordinate. The star map is about the *angular* one.

---

## Charges: what makes a fan

Fix a rational number $p/q$ on the boundary, written in lowest terms — say $1/3$. Through it draw all the straight Euclidean lines going up into the half-plane. A node $z(m,n)$ lies on exactly one of them, the one satisfying
$$\operatorname{Re} z \;=\; \frac{p}{q} + \frac{k}{q}\,\operatorname{Im} z, \qquad\text{where}\qquad \boxed{\,k \;=\; qn - pm\,}.$$
This integer $k$ is the node's **star charge** at $p/q$. Since $\operatorname{Re}z = n/m$ and $\operatorname{Im} z = 1/m$, the identity is one line of algebra — but it is the hinge of everything. The fans in the picture are the *level sets of the charge*: all the nodes of a given charge at a given rational lie on one perfectly straight line, and that line is what your eye sees.

These lines have a name in hyperbolic geometry. The vertical line rising out of $p/q$ is a genuine geodesic; a tilted straight line through $p/q$ is a **hypercycle**, the locus of points at constant distance from that geodesic. And the distance is exactly
$$d\big(z(m,n),\ \gamma_{p/q}\big) \;=\; \operatorname{arsinh}\frac{|k|}{q}.$$
So the charge is not a bookkeeping index; it *is* the width of the ray, measured in the hyperbolic metric. The star at $p/q$ is a pencil of parallel curves, and the charge counts which one you are on.

Two more facts make the rays visible rather than merely definable. First, consecutive nodes along one ray get hyperbolically **closer and closer**: the step length tends to $0$. A ray is an infinite path of shrinking steps, which is precisely why it renders as a smooth continuous line instead of a scatter of separated dots. Second, the ray **runs into its own tip**: its nodes converge to the boundary point $p/q$ itself. Every rational number on the edge is approached by the tree along a straight line aimed directly at it.

---

## Why there is no fan at $\sqrt2 - 1$

Here is the sharpest statement in the whole story, and it is almost embarrassingly easy once you see it.

> **No star at an irrational point.** If two nodes of the tree lie on a single straight Euclidean line through an irrational boundary point $\alpha$, then they are the same node.

The proof is three lines. If $z(m,n)$ and $z(m',n')$ both lie on the line through $\alpha$ of slope parameter $c$, then $n = \alpha m + c$ and $n' = \alpha m' + c$; subtracting, $\alpha(m - m') = n - n'$. If $m \ne m'$, then $\alpha = (n-n')/(m-m')$ is a ratio of integers — rational, contradiction. So $m = m'$, and then $n = n'$.

Irrational boundary points are still *crowded* with nodes; they are limits of the picture. But they can never be the centre of a fan, because a fan requires two nodes to be collinear with the tip, and collinearity with an irrational tip forces the two nodes to coincide. **The stars sit at the rationals because straightness is a rational phenomenon.** This single observation converts a vague visual impression into a dichotomy with no exceptions.

---

## Which fans do you actually see? A parity law

So every rational carries a pencil of potential rays. Why do only a handful stand out?

Because the pencils differ in **resolution** — how far apart, in the eye's terms, consecutive rays of a fan sit. Adjacent populated rays at $p/q$ differ by $1$ in charge, and hence by $1/q$ in the $\sinh$ of their width. Large $q$ means a fan whose rays are packed too tightly to resolve; it blurs into the background. Small $q$ means a wide-open, unmistakable fan. That alone explains why $0 = 0/1$ and $1 = 1/1$ dominate the picture, with $1/2$, $1/3$, $1/5$ behind them.

But there is a second, subtler effect, and it is a **parity obstruction**. Recall that a seed has $m + n$ odd. Suppose $p$ and $q$ are *both odd*. Then, modulo $2$,
$$k = qn - pm \equiv n + m \equiv 1,$$
so **every charge at a both-odd rational is odd.** Half the pencil is simply empty; the populated rays are twice as far apart. Conversely, when $p+q$ is odd there is no obstruction, and every integer charge is realised by infinitely many nodes: with a Bézout identity $qx - py = 1$ and $A = 1 + k(x+y) + 2k^2 j$, the pairs $(m,n) = (qA+yk,\ pA+xk)$ are genuine seeds of charge exactly $k$, with $m \to \infty$. So the spectrum is completely determined:

> **Spectrum.** At a boundary rational $p/q$ in lowest terms, an integer $k$ is the charge of some node if and only if $p + q$ is odd or $k$ is odd.

Combine the two effects. Define the **resolution** of the star at $p/q$ to be
$$\delta(p/q) \;=\; \frac{1}{q} \ \text{ if } p+q \text{ is odd}, \qquad \delta(p/q) \;=\; \frac{2}{q} \ \text{ if } p, q \text{ are both odd}.$$
Two nodes on different rays of the star at $p/q$ have $\sinh$-widths differing by at least $\delta(p/q)$, and this bound is attained. Now simply rank the rationals of $[0,1]$ by $\delta$. Which ones have $\delta \ge 2/5$?

$$0, \qquad \tfrac15, \qquad \tfrac13, \qquad \tfrac12, \qquad \tfrac35, \qquad 1.$$

Numerically: $0$, $0.2$, $0.333$, $0.5$, $0.6$, $1$. **Those are exactly the fans that a rendered star map shows** — including the one at $0.6$, which is easy to miss until you are told it should be there. And note who is *missing*: $1/4 = 0.25$, despite having a smaller denominator than $1/5$. Its denominator is even, so $p+q$ is odd, so it suffers no parity doubling: $\delta(1/4) = 1/4 < 2/5$, while $\delta(1/5) = 2/5$ because $1$ and $5$ are both odd. The parity law is not a footnote. It is what decides whether you see a fan at $0.2$ but not at $0.25$.

The hierarchy is also provably finite at every scale: for any threshold $\varepsilon > 0$, only finitely many rationals in $[0,1]$ have $\delta \ge \varepsilon$. Zoom in and new fans appear, always finitely many at a time, forever.

---

## How bright is a ray? Euler's totient answers

Resolution says how far apart the rays of a fan are. **Brightness** says how densely a single ray is populated — and here a classical function of number theory walks on stage.

Along the ray of charge $k$ at $p/q$, the lattice points are $(m + tq,\ n + tp)$, but only some of them are legitimate seeds: they must be coprime and of opposite parity. The change of variables that untangles this is again the Bézout matrix $qx - py = 1$: the integer points of the ray are exactly
$$(m,n) = (qA + yk,\ pA + xk), \qquad A \in \mathbb{Z},$$
and in this coordinate the coprimality condition becomes stunningly simple:
$$\gcd(m,n) = 1 \iff \gcd(A, k) = 1 .$$
**The charge is the only arithmetic obstruction on a ray.** A ray of charge $\pm 1$ has *no* obstruction at all: every lattice point on it is primitive. Those unit rays are the brightest lines of every fan — the ones that leap out of the plot.

Counting the rest is now a residue count, and it yields a clean trichotomy. Take a window of $2k$ consecutive values of the ray parameter. The number of genuine nodes in it is
- $2\varphi(k)$ if $p$ and $q$ are both odd (with $k$ necessarily odd);
- $2\varphi(k)$ if $p+q$ is odd and $k$ is even;
- $\varphi(k) = \varphi(2k)$ if $p+q$ is odd and $k$ is odd — exactly **half brightness**.

Here $\varphi$ is Euler's totient, counting integers up to $k$ coprime to $k$. So a ray of prime charge $r$ has density $1 - 1/r$; a ray of charge $1$ has density $1$; a ray of charge $105 = 3\cdot5\cdot7$ has density $\tfrac{2}{3}\cdot\tfrac{4}{5}\cdot\tfrac{6}{7} = 0.457$ and looks visibly dotted.

And notice the beautiful compensation hiding in the trichotomy. At a both-odd rational the rays are spaced *twice* as far apart — but each is *twice* as bright. At a mixed-parity rational the rays are twice as dense, and each is half as bright. The total amount of light is conserved; parity only decides how it is distributed between resolution and intensity.

---

## The one ray that is not a fan

Among the three Berggren moves, two of them are the fan-makers. The move $B_1$ preserves the quantity $m-n$, and $B_3$ preserves $n$; these are exactly the charges at the boundary points $1$ and $0$. So the $B_1$-orbits *are* the rays of the $1$-star, and the $B_3$-orbits are the rays of the $0$-star. As boundary maps on the slope $t = n/m$, both are **parabolic**: in the right coordinate they are simply $x \mapsto x+1$ and $x \mapsto x+2$, and their orbits crawl into their rational fixed points at rate $\Theta(1/k)$ — slowing down forever, hence the shrinking steps.

The middle move $B_2$ is a different animal. On slopes it acts as $t \mapsto 1/(2+t)$, which contracts by a factor of $4$ toward the fixed point
$$t_\star = \sqrt2 - 1,$$
an *irrational* number. It is **hyperbolic**, not parabolic. Its orbit from the root runs through the Pell numbers, $(2,1), (5,2), (12,5), (29,12), (70,29), \ldots$, and the ratios $m_{k+1}/m_k$ converge to the silver ratio $1+\sqrt2$. Its steps do not shrink; they converge to
$$\log(1+\sqrt2) = 0.881373\ldots,$$
the translation length of the isometry. This is the lone bright diagonal in the picture: a genuine geodesic traversed at constant speed, marching away from $i$ forever while the fans slide tangentially into the boundary.

That is the metric trichotomy in one sentence: **fan steps go to zero, spine steps go to $\log(1+\sqrt2)$**, and the visual difference between a fan and the spine is precisely the difference between a parabolic and a hyperbolic isometry. The spine's tip is irrational — and by the no-star theorem, an irrational tip can never grow a fan. The two phenomena are two faces of the same coin.

---

## The cryptographic punchline: a beautiful map that leads nowhere

Why would anyone plot Pythagorean triples hyperbolically in the first place? There is a tempting reason. A number $N$ that has two *different* representations as a sum of two squares is a number you can factor, by a method Euler already knew: if $N = m_1^2 + n_1^2 = m_2^2 + n_2^2$ with distinct representations, then with the "pivot" $P = m_1m_2 + n_1n_2$,
$$\gcd(N, P) \cdot \gcd(N,\ m_1n_2 + n_1m_2) \;=\; N,$$
with both factors non-trivial. For $N = 65 = 8^2+1^2 = 7^2+4^2$: $P = 60$, $\gcd(65,60) = 5$, and the complementary factor is $\gcd(65,39) = 13$.

Two representations of $N$ are two nodes of our tree with the same hypotenuse — a **collision**. Both sit at hyperbolic radius $\tfrac12\log N + O(1)$; they are close in the radial direction. Might a short hyperbolic walk find one from the other, factoring $N$ geometrically?

No — and the geometry says so twice, sharply.

First, the two colliding nodes are *pushed apart in proportion to the secret they reveal*. Writing $g = \gcd(N,P)$ for the divisor Euler's method extracts, an exact computation with the Brahmagupta–Fibonacci identity gives
$$\cosh d(z_1, z_2) \;\ge\; 1 + \frac{g}{2}, \qquad\text{so}\qquad d(z_1,z_2) \;\ge\; \log g - \log 2 .$$
The more useful the collision, the farther apart its two witnesses. For a balanced factorisation, where $g \ge \sqrt N$, the two nodes are essentially antipodal on their shared circle: $d \ge \tfrac12 \log N - \log 2$. Knowing one witness tells you nothing about where to look for the other.

Second, and decisively, count the candidates. A node lies within hyperbolic distance $R$ of $i$ exactly when $(m - \cosh R)^2 + n^2 \le \sinh^2 R$ — a transcendental condition that collapses to an ordinary Euclidean disc in the seed plane. Counting lattice points in that disc shows the ball of radius $R$ contains $\Theta(e^{2R})$ nodes, matching the growth of hyperbolic *area*: the tree is a uniform net, not a sparse skeleton. The smallest ball guaranteed to contain a collision for $N$ has radius $\approx \tfrac12 \log N + \log 2$ — and therefore contains $\Theta(N)$ nodes.

The hyperbolic metric compresses the search space and the search target by exactly the same exponential factor. The geodesic to the answer is short; the number of places the answer could be is linear in $N$. Trial enumeration in $O(\sqrt N)$ remains the better bet. The star map is a genuinely beautiful object, and it is a genuinely useless oracle — which is itself worth knowing, because "this attractive structure does not weaken the problem" is exactly the sort of statement cryptography is built on.

---

## What the picture was telling us

Look again at the plot. Every mark on it now has a name.

The bright fans at $0$ and $1$ are the orbits of the two parabolic Berggren moves, hypercycles at hyperbolic width $\operatorname{arsinh}(n)$ and $\operatorname{arsinh}(m-n)$ from the geodesics over $0$ and $1$. The fainter fans at $1/2$, $1/3$, $1/5$, $3/5$ are the rationals of resolution at least $2/5$ — a finite, computable list in which even denominators are penalised, which is why $0.25$ is absent and $0.2$ is present. The dotted texture of an individual ray is Euler's totient. The absence of any fan at $\sqrt2-1$, or at any other irrational, is the impossibility of three collinear points with an irrational tip. The lone diagonal is the silver ratio, striding out at $\log(1+\sqrt2)$ per step. And the fact that none of it helps you factor a number is a theorem about volume growth in negative curvature.

There is an old prejudice that a picture is where mathematics starts and proof is where it ends. Here they are the same thing. The plot is not an illustration of the theorems; the plot *is* the theorems, drawn at a resolution the eye happens to be good at. Somebody typed a few lines of plotting code, saw lines that should not have been there, and asked why. The answer turned out to be a parity law, a totient, an irrationality argument, and the silver ratio — all of them hiding, for two and a half thousand years, inside $3^2 + 4^2 = 5^2$.
