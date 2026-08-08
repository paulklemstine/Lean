# Stars on the Rim: The Hidden Geometry of the Pythagorean Tree

## A picture that shouldn't have been there

Every right triangle with whole-number sides — $3,4,5$; $5,12,13$; $8,15,17$ — is a solution of
$$a^2 + b^2 = c^2.$$
There are infinitely many of them, and since antiquity people have wanted to know how they are organized. In 1963 the Dutch schoolteacher F. J. M. Barning found the answer, rediscovered in 1970 by A. Hall and again in 1934 by B. Berggren: **every** primitive Pythagorean triple (one with no common factor, written with the odd leg first) is obtained from $(3,4,5)$ by repeatedly applying exactly three integer matrices. Nothing is missed, nothing is repeated. The triples form a perfect infinite ternary tree, rooted at $(3,4,5)$.

The tree is a beautiful object, but it is hard to *see*. Each node is three big integers; the numbers explode; a drawing of the tree as a tree looks like a tangle of unreadable labels.

So here is a different idea. A triple $(a,b,c)$ determines a *direction*: the point
$$\mathrm{dir}(a,b,c) = \left(\tfrac{a}{c},\ \tfrac{b}{c}\right),$$
which, because $a^2+b^2=c^2$, lies exactly on the unit circle. Draw each triple at that angle, at a radius that creeps towards $1$ as the triple gets bigger — say radius $1 - 1/c$. Deep nodes of the tree crowd against the rim of a disc; shallow nodes stay near the middle. Then join each node to its three children.

Do this, and something startling happens. The picture is not a fuzzy spray. It is full of **structure**: lines that appear to radiate outward, and — much more strangely — tight *bundles of curves converging on isolated points of the boundary circle itself*, like light sources embedded in the rim. Stars.

Why would a plot of right triangles produce stars on a circle? This article explains what those stars are, exactly which points of the circle carry one, exactly how many curves each one has, and exactly what shape those curves take. The answers turn out to be uncommonly clean.

---

## Step one: right triangles are points on a light cone

Rewrite the Pythagorean equation as
$$Q(a,b,c) := a^2 + b^2 - c^2 = 0.$$

$Q$ is a quadratic form of signature $(2,1)$ — the same signature as the metric of two-dimensional spacetime. Its zero set is a **light cone**, and Pythagorean triples are precisely the integer points on it. The associated bilinear form
$$\langle v, w\rangle = v_1w_1 + v_2w_2 - v_3w_3$$
is the Minkowski product.

Now the crucial observation. Write the Berggren generators as maps on triples:
$$
\begin{aligned}
A(a,b,c) &= (\,a - 2b + 2c,\ \ 2a - b + 2c,\ \ 2a - 2b + 3c\,),\\
B(a,b,c) &= (\,a + 2b + 2c,\ \ 2a + b + 2c,\ \ 2a + 2b + 3c\,),\\
C(a,b,c) &= (-a + 2b + 2c,\ -2a + b + 2c,\ -2a + 2b + 3c\,).
\end{aligned}
$$
A one-line computation shows that all three preserve the Minkowski product exactly:
$$\langle Mv, Mw\rangle = \langle v,w\rangle \quad\text{for } M \in \{A,B,C\}.$$

So the three matrices that generate all Pythagorean triples are **Lorentz transformations with integer entries**. They lie in $O(2,1;\mathbb{Z})$, which is nothing other than the isometry group of the hyperbolic plane in its hyperboloid (Klein) model. And the map $\mathrm{dir}$ that we used to draw the picture is the map sending a null ray to its **ideal point** — a point on the circle at infinity of the hyperbolic plane.

The strange plot is therefore not a plot of arithmetic at all. It is a plot of a discrete group acting on the hyperbolic plane, and the stars are a phenomenon of hyperbolic geometry.

---

## Step two: distance on the rim is a Minkowski product

Everything that follows flows from one identity. For two Pythagorean triples $v = (a,b,c)$ and $p$, with positive hypotenuses $c_v$ and $c_p$,
$$\bigl\|\mathrm{dir}\,v - \mathrm{dir}\,p\bigr\|^2 \;=\; \frac{-2\langle v,p\rangle}{c_v\, c_p}.$$

The left side is a purely visual quantity: the squared straight-line (chordal) distance between the two dots you drew on the circle. The right side is pure arithmetic. Call the positive integer
$$d \;=\; -\langle v, p\rangle$$
the **charge** of $v$ at $p$.

Read the identity again. If a whole family of triples $v_1, v_2, v_3, \dots$ all have the *same* charge $d$ at some fixed triple $p$, and their hypotenuses run off to infinity, then the numerator on the right is frozen while the denominator explodes. The chordal distance to $\mathrm{dir}\,p$ collapses to zero.

**The Star Theorem.** *Let $p$ be a Pythagorean triple and let $v_1, v_2, \dots$ be Pythagorean triples with $\langle v_k, p\rangle = -d$ for all $k$ and hypotenuse tending to infinity. Then the plotted points $\mathrm{dir}\,v_k$ converge to $\mathrm{dir}\,p$.*

Each value of $d$ gives a *different* family, and every one of them runs into the same boundary point. That is the star: a fixed rational point of the rim, and a whole sheaf of curves diving into it, one curve per admissible charge.

In hyperbolic language, the level set $\{\langle v,p\rangle = -d\}$ is a **horocycle** based at the ideal point of $p$ — a circle internally tangent to the boundary. The star curves are horocycles. Their tangency to the circle is what makes them look bent rather than straight.

---

## Step three: the curves are exactly quadratically tangent

We can be far more precise than "the curves converge". Multiplying the fundamental identity by $c_v$:
$$c_v \cdot \bigl\|\mathrm{dir}\,v - \mathrm{dir}\,p\bigr\|^2 \;=\; \frac{2d}{c_p}.$$

The left side is not merely bounded, and not merely convergent — it is **exactly constant** along a horocycle. Every point of the spoke of charge $d$ satisfies the same identity, with no error term whatsoever.

Two consequences follow immediately, and they pin down the shape of the curve:

- $c_v^2 \cdot \|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2 \to \infty$ (the curve does not hug the rim as tightly as a first-order tangency would),
- $\sqrt{c_v} \cdot \|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2 \to 0$ (but it hugs it more tightly than a transversal crossing).

The contact order with the boundary circle is exactly **two**. A geodesic through the centre of the disc — a straight radius — meets the boundary with contact order one. That single unit of difference is precisely what your eye registers when it says "some of these are lines and some of them are curving into the edge."

And the drawing itself obeys an exact algebraic law. If a node of hypotenuse $c$ is drawn at radius $r = 1 - 1/c$ inside the disc, then along the spoke of charge $d$ at $p$ the angular and radial coordinates satisfy
$$\bigl\|\mathrm{dir}\,v - \mathrm{dir}\,p\bigr\|^2 = \frac{2d\,(1-r)}{c_p}.$$
The curve you see on screen is the graph of that relation — squared angular offset proportional to distance from the rim — with the single parameter $d/c_p$. The drawn points, though strictly inside the disc, still converge to the boundary star centre.

---

## Step four: two kinds of motion, and the visible difference

Why do the three generators behave so differently? Because they have different *conjugacy types* as hyperbolic isometries, and conjugacy type is exactly what the eye is picking up.

**$C$ is parabolic.** It preserves the linear quantity $c - a$: if $C(a,b,c) = (a',b',c')$ then $c' - a' = c - a$. Its iterates have an exact closed form which is *quadratic in the step number*:
$$C^k(a,b,c) = \bigl(c_k - d,\; b + 2kd,\; c_k\bigr), \qquad c_k = c + 2kb + 2k^2 d, \qquad d = c-a.$$
A quadratic polynomial in $k$ is the fingerprint of a rank-three unipotent Jordan block: $C$ is a parabolic isometry, and its orbits crawl along a horocycle. The point they crawl towards is the null direction where $c = a$, namely $(1,0,1)$, plotted at $(1,0)$.

**$A$ is parabolic too**, preserving $c-b$, with the mirror-image closed form
$$A^k(a,b,c) = \bigl(a + 2ke,\; c_k - e,\; c_k\bigr),\qquad c_k = c + 2ka + 2k^2 e, \qquad e = c-b,$$
accumulating at $(0,1)$.

**$B$ is hyperbolic.** It preserves nothing linear; it merely *negates* $a-b$, so $|a-b|$ is constant. Its hypotenuse obeys the Pell recursion
$$c_{k+2} = 6c_{k+1} - c_k,$$
whose characteristic roots are the units $3 \pm 2\sqrt{2} = (1\pm\sqrt{2})^2$ of $\mathbb{Z}[\sqrt2]$. Each step multiplies the hypotenuse by at least $5$ (asymptotically by $3+2\sqrt2 \approx 5.828$). An orbit of $B$ slides along a *geodesic*, and its limiting direction is where $a = b$ — that is, the point at angle $\pi/4$.

The difference in rates is stark and can be measured on the root triple. Starting from $(3,4,5)$, for every $k \geq 1$:
$$\frac{2}{17k^2} \;\le\; 1 - x\bigl(C^k(3,4,5)\bigr), \qquad\qquad \Bigl| x\bigl(B^k(3,4,5)\bigr) - \tfrac{\sqrt2}{2} \Bigr| \;\le\; \frac{1}{5\cdot 3^{k}},$$
where $x(\cdot)$ is the first plotted coordinate. The parabolic branch approaches its boundary point at the leisurely polynomial rate $\Theta(k^{-2})$ — slow enough that you can see the individual dots strung out along a curve. The hyperbolic branch reaches the rim exponentially fast — so fast that it registers as a single straight streak, a *radiating line*.

There is a punchline. The hyperbolic limit point sits at $x = \sqrt2/2$, which is **irrational**. No Pythagorean triple is ever plotted at an irrational direction, since $\mathrm{dir}$ always produces rationals. So at the $\pi/4$ point there is no star — only one lonely geodesic arriving and nothing waiting for it. **Stars occur only at rational ideal points.** The irrational directions of the circle are visited but never occupied.

---

## Step five: which stars exist, and how bright

Now the arithmetic returns, and it is sharp.

At the special point $(1,0)$ the charge is $d = c-a$. Which positive integers can occur? Not all of them. For a *primitive* triple with positive entries, the charge is severely quantized:

**Charge Quantization Theorem.** *If $a^2+b^2=c^2$ with $a,b,c>0$ and $\gcd(a,b)=1$, then $c-a$ is either twice a perfect square (when $a$ is odd) or an odd perfect square (when $a$ is even). Conversely, every such value is achieved: the triple $(2n+1,\,2n^2+2n,\,2n^2+2n+1)$ realises $c-a = 2n^2$, and $(4m,\,4m^2-1,\,4m^2+1)$ realises $c-a=(2m-1)^2$.*

So the admissible charges are exactly
$$\{2, 8, 18, 32, 50, \dots\} \cup \{1,9,25,49,\dots\},$$
a set of **density zero** in the integers. And since every node of the Berggren tree has odd first leg, inside the tree the spectrum shrinks further to precisely
$$\{2n^2 : n \ge 1\}.$$

This is why the star is a star and not a smear. The spokes are indexed by a sparse arithmetic set, so they are visibly *separate*. And they are quantitatively separate: two nodes with the same hypotenuse $c$ but charges $d$ and $d'$ satisfy
$$\frac{\|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2}{\|\mathrm{dir}\,v' - \mathrm{dir}\,p\|^2} = \frac{d}{d'},$$
so distinct charges are distinct visible curves, not a bookkeeping artefact.

The integer $n$ with $d = 2n^2$ deserves a name: the **spoke index**. It has a beautiful direct meaning. Write a triple in Euclid form,
$$\mathrm{eu}(m,n) = (m^2-n^2,\ 2mn,\ m^2+n^2),$$
and then the charge at $(1,0)$ is exactly $2n^2$ while the charge at $(0,1)$ is exactly $(m-n)^2$. **The spoke index of a node is simply its smaller Euclid parameter.** Better still, in these coordinates the three generators become almost trivially simple:
$$A: (m,n)\mapsto(2m-n,\ m), \qquad B: (m,n)\mapsto (2m+n,\ m), \qquad C: (m,n)\mapsto (m+2n,\ n).$$
This is the classical ternary tree on coprime pairs. Reading a word in the generators from the root, you can now *see* the star being drawn: $C$ leaves $n$ untouched — it slides you along your current spoke — while $A$ and $B$ promote $m$ to be the new $n$, throwing you outward onto a fresh spoke.

---

## Step six: a star at every rational point, each with infinitely many spokes

Two questions remain. *Where* are the stars, and how many curves does each one carry?

Both have complete answers, and they combine a piece of hyperbolic geometry with the classical completeness of the tree.

The geometric half is transport. Since every word $W$ in the generators is a Lorentz isometry, it carries the horocycle of charge $d$ based at $(1,0)$ to a horocycle of charge $d$ based at $W\cdot(1,0,1)$. And a small computation shows $A(1,0,1) = B(1,0,1) = (3,4,5)$ while $C(1,0,1) = (1,0,1)$. So the orbit of the point $(1,0)$ under the monoid is exactly $\{(1,0)\}$ together with the ideal points of all the tree's nodes. Conclusion: **every node of the tree is itself the centre of a star.** The root $(3,4,5)$, plotted at $(3/5, 4/5)$, is a star centre, and the family of nodes converging on it is completely explicit.

The arithmetic half is the Barning–Hall completeness theorem, proved by Fermat descent: every primitive triple with odd first leg and positive entries is $W\cdot(3,4,5)$ for some word $W$. Each of the three generators has an explicit inverse, and one shows that from any primitive triple other than the root, exactly one of the three inverses lands on another primitive triple with strictly smaller hypotenuse. Descent terminates only at $(3,4,5)$.

Combining them:

**Star Location Theorem.** *Every primitive Pythagorean direction $(a/c, b/c)$ with $a$ odd is a star centre: there is an infinite family of tree nodes whose plotted points converge to it.*

**Star Multiplicity Theorem.** *At every such point, the set of realised spoke charges is infinite. Each star has infinitely many distinct curves.*

The witnesses are as explicit as one could hope: the spoke of charge $2(n+1)^2$ at $(1,0)$ is the $C$-orbit of the $n$-th node of the $A$-branch, i.e. the family $C^j A^n (3,4,5)$ for $j = 0,1,2,\dots$; and the transport by $W$ carries this whole picture to any node you like. In fact the set of charges the tree actually draws at $(1,0)$ is *exactly* $\{2n^2 : n\ge1\}$ — no other value occurs, and every one of them occurs.

Finally, the rational directions in the first-quadrant arc are dense (given any target $t \in [0,1)$ and any tolerance, one can name explicit Euclid parameters $0<n<m$ with $\bigl|\frac{m^2-n^2}{m^2+n^2} - t\bigr|$ as small as desired). So the boundary circle carries a **dense set of stars**, and this — at last — is why the picture is speckled with them everywhere you look.

---

## Step seven: how fast does a branch reach the rim?

One more question the picture poses. Some branches shoot to the boundary and vanish; others creep. Which is which?

The answer is combinatorial in the address of the node. If $g$ is a word in the letters $A$, $B$, $C$ applied to the root, and $c(g)$ is the resulting hypotenuse, then
$$5 \cdot 3^{\#_B(g)} \;\le\; c(g) \;\le\; 5\cdot 7^{|g|},$$
where $\#_B(g)$ counts the letter $B$ and $|g|$ is the word length. Exponential escape to the boundary is *forced by, and only by, a positive density of $B$'s in the address*. A branch that avoids $B$ is trapped in the parabolic, polynomial regime — it draws a curve, not a line.

The same word-combinatorics controls how fast the star *fills in*. Because each generator at most triples the larger Euclid parameter, a node at depth $k$ has spoke index
$$n < 2\cdot 3^{k}.$$
So the $n$-th spoke of the star cannot appear before depth roughly $\log_3(n/2)$: the star fills in at most logarithmically fast. And this bound is sharp up to the constant. Along the hyperbolic branch $B^k$, the Euclid parameters are consecutive **Pell numbers** $1, 2, 5, 12, 29, 70, \dots$ (satisfying $P_{k+2} = 2P_{k+1}+P_k$), so the spoke index at depth $k$ is $P_k$ and obeys the sandwich
$$2^k \;\le\; n \;<\; 2\cdot 3^k.$$
Meanwhile along the parabolic branch $A^k$ the spoke index is only $k+1$, the slowest growth possible — reaching spoke $n$ takes depth $n-1$. The two Berggren regimes, hyperbolic and parabolic, are visible in the star's *filling rate* as well as in its *approach rate*.

---

## Why it matters

A frivolous plot turned out to be an accurate diagram of a discrete subgroup of $O(2,1)$ acting on the hyperbolic plane. Every visual feature came back with an exact theorem attached: the curves are horocycles; their tangency order is exactly two; their labels are quantized to twice-a-square; their centres are exactly the primitive rational directions; each centre carries infinitely many; the rate of escape is read off the density of one letter in the address.

This story is a small instance of a large modern theme. Apollonian circle packings, Markov triples, continued fractions, and the Pythagorean tree are all orbits of *thin groups* — infinite-index integer matrix groups whose orbits are simultaneously arithmetic objects and geometric fractals. The Pythagorean case is unusually transparent: the group is generated by three explicit matrices, the invariant form is $a^2+b^2-c^2$, and the "local-to-global" question ("which charges occur?") has a complete, elementary answer. It makes an ideal training ground for intuitions that are much harder to come by in the Apollonian setting.

There is also a lesson about how to look. The stars in the plot were not an artefact of the drawing method and they were not noise. They were a *conjugacy classification* — parabolic versus hyperbolic — rendered in ink. Pick the right picture, and the geometry tells you the algebra.

Next time you see $3,4,5$, you might remember that it is not just a triangle. It is a point of light on the rim of a hyperbolic disc, with infinitely many curves running into it, each labelled by twice a perfect square.
