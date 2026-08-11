# The Star Map Hidden Inside Pythagoras

*How the oldest theorem in mathematics draws a picture of the rational numbers — and why the picture is made of fans*

---

## A picture that shouldn't be there

Every schoolchild meets the triple $(3,4,5)$: three whole numbers with $3^2 + 4^2 = 5^2$. Fewer meet the fact that all of them — $(5,12,13)$, $(8,15,17)$, $(20,21,29)$, and infinitely many more — can be grown from that single seed by three simple rules, each triple sprouting exactly three children, forever, with no triple ever appearing twice. This infinite ternary tree of *primitive Pythagorean triples* has been rediscovered so many times that it has half a dozen names; we will call it the **Berggren tree**, after the Swedish mathematician who described it in 1934.

A tree of numbers is an abstract thing. But there is a way to *see* it. Euclid, two millennia earlier, had already shown that every primitive triple comes from a pair of whole numbers $(m,n)$ with $0 < n < m$, no common factor, and opposite parity, via
$$(a,b,c) = (m^2 - n^2,\ 2mn,\ m^2 + n^2).$$
So instead of drawing triples, draw their **seeds** $(m,n)$. And instead of plotting them on ordinary graph paper, plot each seed as the complex number
$$z(m,n) \;=\; \frac{n + i}{m} \;=\; \frac{n}{m} \;+\; \frac{i}{m},$$
a point in the upper half of the complex plane. Its horizontal position is the ratio $n/m$; its height is $1/m$, so big seeds sit low and small seeds sit high.

Do this for every seed with $m$ up to a few hundred, and something startling happens. The points do not form a haze. They form **stars**: sharp, straight rays fanning out from points on the bottom edge of the picture. There is an obvious fan at $0$ and another at $1$. Look harder and there are fans at $0.5$, at $0.333\ldots$, at $0.2$, at $0.4$ — apparently at every fraction, each fan a little fainter and a little narrower than the last.

Why should adding up squares of whole numbers produce a fireworks display? That is the question this article answers. The short version: the picture is *exactly* a picture of the rational numbers, drawn by Pythagoras, and every visible feature of it is a theorem.

## The right place to draw

The upper half-plane is not just a convenient sheet of paper. Equipped with the length element $ds = |dz|/\operatorname{Im} z$ — distances get cheaper the higher you go — it is the **Poincaré half-plane**, the standard model of hyperbolic geometry. In it, "straight lines" (geodesics) are vertical rays and semicircles meeting the real axis at right angles. The real axis itself is the *ideal boundary*, infinitely far away in every hyperbolic sense, yet visible at the bottom of the page.

Hyperbolic geometry is the natural home for this embedding because it makes the arithmetic legible. For instance, the hyperbolic distance from the base point $i$ to a node satisfies the exact identity
$$\cosh d\big(i,\ z(m,n)\big) \;=\; \frac{m^2 + n^2 + 1}{2m} \;=\; \frac{c+1}{2m},$$
where $c = m^2+n^2$ is the *hypotenuse* of the triple. The hypotenuse appears out of nowhere: the embedding only used $n/m$ and $1/m$, yet the hyperbolic radius knows the third side of the triangle. It follows that
$$\tfrac12 \log c \;\le\; d\big(i, z(m,n)\big) \;\le\; \tfrac12 \log\big(2(c+1)\big),$$
so a node's distance from the centre is $\tfrac12\log c$ to within an additive $\log 2$. The picture is organised into shells by hypotenuse.

That explains the radial coordinate. It does not explain the fans.

## Charge: one integer per fraction

Fix a fraction $p/q$ in lowest terms, thought of as a point on the bottom edge. Give each seed $(m,n)$ an integer, its **charge at $p/q$**:
$$\chi \;=\; p\,m - q\,n.$$

Now a one-line computation:
$$\frac{p}{q} - \frac{n}{m} \;=\; \frac{pm - qn}{qm} \;=\; \frac{\chi}{q} \cdot \frac{1}{m}.$$
The left side is the horizontal offset of the node from $p/q$; the far right is $\chi/q$ times the node's height. In other words:

> **Every seed of charge $\chi$ lies on the straight Euclidean line through the boundary point $p/q$ of slope $q/\chi$.**

That is the whole phenomenon. The fan at $p/q$ is the family of these lines, one for each integer charge; the visible rays are the *level sets of the charge*. There is nothing special about $0$ or $1$: **every rational boundary point carries a fan.** The stars at $0$ and $1$ are simply the charges $-n$ and $m-n$, the cases $q = 1$.

The lines are not hyperbolic straight lines — a Euclidean line hitting the boundary at an angle is not a geodesic. They are the next best thing, **hypercycles**: curves of constant distance from a geodesic. The precise statement is that a node of charge $\chi$ at $p/q$ sits at hyperbolic distance exactly
$$\operatorname{arsinh}\!\left(\frac{|\chi|}{q}\right)$$
from the vertical geodesic rising out of $p/q$. The charge is not just a label; it is a *width*, measured in hyperbolic units. A fan is a discrete ladder of hypercycles at the heights $\operatorname{arsinh}(1/q), \operatorname{arsinh}(2/q), \operatorname{arsinh}(3/q), \ldots$

## Half the rays are switched off — and parity decides which

Here the arithmetic bites. A Euclid seed must have $m+n$ odd. Suppose $p$ and $q$ are *both* odd — the fractions $1/3$, $1/5$, $3/5$, $1/1$. Then
$$\chi = pm - qn \equiv m - n \equiv m + n \equiv 1 \pmod 2,$$
so **every charge at such a point is odd**. Half the rays of the fan carry no node whatsoever. The fan at $1/3$ has rays of charge $\pm1, \pm3, \pm5,\ldots$ and empty slots at $\pm 2, \pm 4, \ldots$

If instead $p+q$ is odd — $1/2$, $1/4$, $2/5$, and $0/1$ — no such obstruction exists, and it turns out that *every* integer charge is realised, by infinitely many nodes. That is the harder half of the story, and it is settled by a change of variables. Because $p/q$ is in lowest terms one can pick integers $a,b$ with $pb - qa = 1$, and then the general solution of $pm - qn = k$ is
$$(m,n) \;=\; (kb + sq,\ ka + sp), \qquad s \in \mathbb{Z}.$$
This substitution has determinant $1$: it is a change of basis of the integer lattice. So it converts every arithmetic property of the *node* $(m,n)$ into an arithmetic property of the *pair* $(k, s)$ — most importantly, $m$ and $n$ are coprime exactly when $k$ and $s$ are, and $m+n = k(a+b) + s(p+q)$, an explicit linear function of the parameter. Choosing $s$ in a suitable residue class and large enough produces a genuine Euclid seed of the demanded charge, of arbitrarily large size.

Putting the two halves together gives a complete description of every fan in the picture:

> **Realisation Theorem.** For a fraction $p/q$ strictly between $0$ and $1$ in lowest terms, the set of charges realised by Euclid seeds is *all* of $\mathbb{Z}$ when $p+q$ is odd, and *exactly the odd integers* when $p+q$ is even. Every realised ray carries infinitely many nodes.

There is a pretty corollary about the *axis* of a fan — the ray of charge $0$, the vertical geodesic over $p/q$ itself. A seed has charge $0$ precisely when $pm = qn$, which for a primitive seed forces $(m,n) = (q,p)$: at most one node in the whole tree can sit on the axis of a given star, and it does so exactly when $p+q$ is odd. At $p/q = 1/2$ that unique node is $(2,1)$ — the root of the entire Berggren tree, the seed of $(3,4,5)$. The tree's origin sits precisely on the centre line of the fan at $0.5$.

## Why you only see a handful of fans

If every rational carries a fan, why does the picture show a dozen and not a continuum? Because fans have *width*, and width is inversely proportional to the denominator.

At plot height $y$, two nodes whose charges at $p/q$ differ by $d$ are separated horizontally by exactly $|d|\,y/q$. So adjacent rays of the fan at $p/q$ are $y/q$ apart. If your plot resolves features of size $\varepsilon$, the fan at $p/q$ is visible as a fan — rather than as an indistinguishable smear — precisely when
$$\frac{y}{q} \ \ge\ \varepsilon, \qquad\text{i.e.}\qquad q \ \le\ \frac{y}{\varepsilon}.$$

That is a *geometric* criterion converted into a purely *arithmetic* one: the visible star centres are exactly the fractions of denominator at most $Q = \lfloor y/\varepsilon\rfloor$ — the **Farey fractions of level $Q$**. Their number in $(0,1]$ is
$$\sum_{q=1}^{Q} \varphi(q),$$
where $\varphi$ is Euler's totient function. At height $y = 0.5$ with a resolution of one part in ten, $Q = 5$ and the count is $1+1+2+2+4 = 10$: the centres $1/1$, $1/2$, $1/3$, $2/3$, $1/4$, $3/4$, $1/5$, $2/5$, $3/5$, $4/5$ — precisely the fans one sees. The visual impression of "a star at $0.2$ but not at $0.19$" is the Farey sequence made visible.

## The innermost ray is a best approximation

The identity $\;n/m - p/q = -\chi/(qm)\;$ says something more than "the charge draws a line". It says the charge *measures how well $p/q$ approximates the node's slope*. Small charge means good approximation. The innermost rays of a fan, $|\chi| = 1$, consist of the nodes whose slope is a **Farey neighbour** of $p/q$: a unimodular partner, $qn - pm = \pm 1$.

Farey's classical theorem then guarantees that such a pair is unimprovable: if $qn - pm = 1$ then no fraction of denominator less than $q+m$ lies strictly between $p/q$ and $n/m$, and the bound is sharp because the mediant $(p+n)/(q+m)$ sits right there in the gap. So the brightest spokes of each fan are exactly the tree's best rational approximations to the fan's centre.

And the relation is reciprocal. Every seed $(m,n)$ with $m \ge 2$ is a Farey neighbour of *two* distinct fractions of denominator smaller than $m$, one on each side — one with charge $+1$, one with charge $-1$. **Every node of the tree is an innermost spoke of at least two of the visible fans.** No point in the star map is a bystander.

## How thin is a spoke?

A ray of large charge is infinite but sparse, and the sparsity is measured by a totient. Along a ray at an odd/odd rational with odd charge $k$, the unimodular parameter $s$ produces a genuine seed exactly when $\gcd(|k|, s) = 1$ — the parity condition is automatic, so coprimality is the *only* obstruction. Counting coprime residues in a window then gives:

> **Totient density law.** In any window of $2|k|$ consecutive parameters (past an explicit starting bound), the ray of charge $k$ carries exactly $2\varphi(|k|)$ nodes.

So a spoke has arithmetic density $\varphi(|k|)/|k|$. The spoke of charge $1$ is completely full; the spoke of charge $3$ is two-thirds full; the spoke of charge $15$ is only $8/15$ full and looks visibly dotted. Rays of highly composite charge are the faint ones. Direct enumeration confirms the law: on the fan at $1/3$, counting seeds with $m \le 20000$ gives densities $0.9999$ for $k=1$ and $0.6666$ for $k=3$, against the predicted $1$ and $2/3$.

## The tree shuffles the fans

The last surprise is that the three growth rules of the tree do not merely move nodes around — they move *whole fans*. Written on seeds, the rules are
$$B_1(m,n) = (2m-n,\ m), \qquad B_2(m,n) = (2m+n,\ m), \qquad B_3(m,n) = (m+2n,\ n),$$
and each has a shadow acting on the pair $(p,q)$ that labels a fan:
$$B_1:\ (p,q) \mapsto (2p-q,\ p), \qquad B_2:\ (p,q)\mapsto (2p-q,\ -p), \qquad B_3:\ (p,q)\mapsto(p,\ q-2p),$$
in such a way that the charge is preserved exactly: the charge of a moved node at the old fan equals the charge of the original node at the new fan. Charge is a conserved quantity of the tree, provided you let the fan move with it.

Two consequences. First, no rational is exceptional — the system of fans is permuted by the tree, so what is true of one fan is true of its whole orbit. In fact the fan at $k/(k+1)$ is carried onto the fan at $0$ by applying $B_1$ exactly $k$ times: infinitely many of the fans you can see are one and the same fan, transported.

Second — and this is the punchline of the whole picture — the parity of $p+q$ is *invariant* under transport. No word in the three rules can ever turn an odd-sum fan into an even-sum fan. The fan at $0$ (all charges) and the fan at $1$ (odd charges only) therefore lie in genuinely different classes, and the visual asymmetry between the two most conspicuous stars in the picture is permanent, not an accident of where we chose to root the tree.

## What the picture is

Step back. A tree of Pythagorean triples, plotted through a two-thousand-year-old parametrisation into a nineteenth-century geometry, produces a star map whose every feature turns out to be an exact statement about the rationals: a fan at each fraction, indexed by an integer charge that is simultaneously a hyperbolic width; half the rays extinguished by a parity rule that no growth of the tree can violate; a visibility threshold that reproduces the Farey sequence; innermost spokes that are best rational approximations; spoke densities counted by Euler's totient; and a global symmetry that permutes the fans while conserving the charge.

The picture, in other words, is not a picture *of* Pythagorean triples. It is a picture of the rational numbers, and the triples are the ink.
