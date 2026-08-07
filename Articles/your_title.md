# The Hidden Straight Lines of the Pythagorean Tree

## A picture that asks a question

Every primitive Pythagorean triple — every triple of whole numbers $(a,b,c)$ with $a^2+b^2=c^2$ and no common factor — comes from a single pair of integers. Pick $m > n > 0$ with no common factor and of opposite parity, and set
$$a = m^2-n^2, \qquad b = 2mn, \qquad c = m^2+n^2 .$$
Euclid knew this. What Euclid did not know is that these *seeds* $(m,n)$ organize themselves into a perfect infinite ternary tree. Starting from $(2,1)$ — the seed of $(3,4,5)$ — three simple moves
$$L(m,n) = (2m-n,\,m), \qquad M(m,n) = (2m+n,\,m), \qquad R(m,n) = (m+2n,\,n)$$
generate every primitive triple exactly once. This is the Berggren tree, and it is one of the most satisfying objects in elementary number theory: an infinite family of arithmetic facts arranged with no repetitions and no omissions.

Now do something that has nothing obviously to do with number theory. Send each seed $(m,n)$ to the point
$$z(m,n) \;=\; \frac{n+i}{m}$$
of the hyperbolic upper half-plane, and then transport the whole picture into the Poincaré disk by the Cayley map $w = (z-i)/(z+i)$, which puts the base point $i$ at the centre. Plot a few thousand seeds.

The result is startling. The nodes do not scatter. They fall onto **rays** — long, clean, arrow-straight files of points marching from the centre out towards the boundary circle, like spokes of a wheel drawn by a very careful draughtsman. Some rays are dense, others are sparse; some appear to bend slightly and turn out not to be rays at all. The eye insists that something exact is going on.

This article is about what is going on. The answer turns out to be a complete dictionary between hyperbolic geometry and Diophantine arithmetic: *every* apparent line is either an exact hyperbolic geodesic governed by a Pell equation, or an exact equidistant curve, or a near-miss whose failure can be measured to the last decimal. And there is a satisfying census: through every single node of the tree there passes exactly one true line through the centre, and that line carries infinitely many nodes.

## Distance is a determinant

The first step is to compute. In the hyperbolic upper half-plane the distance $d$ between two points satisfies a clean formula in terms of coordinates, and specializing it to two seed nodes produces something remarkable:

> **Master identity.** For seeds $(m,n)$ and $(m',n')$,
> $$\cosh d\big(z(m,n),\,z(m',n')\big) \;=\; 1 + \frac{(nm'-n'm)^2 + (m-m')^2}{2mm'} .$$

Look at what sits in the numerator: $nm' - n'm$, the determinant of the two seeds. The hyperbolic metric, an analytic object built from an integral of a Riemannian form, has swallowed the most basic arithmetic invariant of a pair of integer vectors. Setting $(m',n') = (1,0)$, i.e. measuring from the centre of the picture, gives
$$\cosh d\big(i,\,z(m,n)\big) \;=\; \frac{m^2+n^2+1}{2m} \;=\; \frac{c+1}{2m},$$
where $c = m^2+n^2$ is the hypotenuse of the triple. So *how far out a triple sits is decided by its hypotenuse*. Sharpening this crude statement gives the **ring theorem**:
$$\tfrac12 \log c \;<\; d\big(i, z(m,n)\big) \;<\; \tfrac12\log(2c) .$$
Every node with hypotenuse $c$ lies in a thin annulus of width $\tfrac12\log 2 = 0.34657\ldots$ around the circle of radius $\tfrac12 \log c$, and this bound is sharp: over the $32{,}335$ seeds with $m<400$, the residual $d - \tfrac12\log c$ ranges from $0.0000032$ to $0.3453$, hugging both ends of the permitted interval without ever escaping it. The whole arithmetic universe of Pythagorean triples piles up logarithmically: to see triples with ten more digits you must travel about $11.5$ further units into the hyperbolic plane.

## Straightness is an integer

Distance is one thing; *straightness* is another. Three points $P, Q, R$ of a hyperbolic plane are collinear exactly when their distances add: $d(P,Q) + d(Q,R) = d(P,R)$. Turning this into something computable, write $c_1, c_2, c_3$ for the hyperbolic cosines of the three pairwise distances and form the **Gram invariant**
$$\Phi \;=\; 2c_1c_2c_3 - c_1^2 - c_2^2 - c_3^2 + 1 .$$
Then $\Phi \ge 0$ always, $\Phi = 0$ precisely when the three points are collinear, and $\Phi > 0$ precisely when the triangle inequality is strict. It is the hyperbolic Cayley–Menger determinant, and it is the exact test the eye is trying to perform.

Now feed in three seed nodes. Something beautiful happens: the transcendental mess collapses.

> **Arithmetic bridge.** For seeds $(m_1,n_1), (m_2,n_2), (m_3,n_3)$,
> $$\Phi \;=\; \left(\frac{\Delta}{2m_1m_2m_3}\right)^{\!2}, \qquad \Delta \;=\; \det \begin{pmatrix} n_1^2+1 & n_1m_1 & m_1^2 \\ n_2^2+1 & n_2m_2 & m_2^2 \\ n_3^2+1 & n_3m_3 & m_3^2 \end{pmatrix}.$$

Straightness in the picture is *an integer determinant vanishing*. And integers have a property that real numbers lack: if a nonzero integer, then at least $1$ in absolute value. So we get a **quantization theorem**: three integer seeds are either exactly collinear, or their Gram defect is at least $1/(2m_1m_2m_3)^2$. There is no such thing as an almost-line in this picture. Every apparent alignment is either perfect or measurably imperfect — the picture cannot lie to you, it can only be read at insufficient resolution.

## The fake line

Immediately this lets us catch an impostor. The most conspicuous ray in the plot runs along the *middle spine* of the tree, the seeds $(2,1), (5,2), (12,5), (29,12), (70,29), \dots$ obtained by iterating $M$. These are the Pell numbers, and their ray looks perfectly straight.

It is not. For the centre $i$, a seed $(m,n)$, and its middle child $M(m,n) = (2m+n, m)$, the determinant is exactly $\Delta = 2m(2m+n)$, and so the Gram defect is
$$\Phi = 1$$
— not small, not decaying, but the universal constant $1$, for every seed in the tree. Numerically, the excess $d(i,P)+d(P,Q)-d(i,Q)$ along the middle spine is a healthy $0.136$ at the first step and never vanishes.

Yet the eye was not entirely wrong. Two middle moves in a row *do* land on an exact geodesic: the composite $M\circ M$ is precisely the automorphism $(m,n) \mapsto (5m+2n,\,2m+n)$ of the conic $m^2 - 2mn - n^2 = 1$, and the even-numbered nodes $(5,2), (29,12), (169,70), (985,408)$ of the middle spine are exactly collinear with the centre, spaced with mathematical precision. The spine is a zigzag whose alternate vertices lie on a true line. The apparent straightness is a half-truth, and knowing which half is the point.

## The true lines are Pell equations

So which triples of nodes really are collinear with the centre? Setting $(m_1,n_1) = (1,0)$ in the determinant and simplifying, the answer is governed by a single rational number attached to each seed, the **radial invariant**
$$\varrho(m,n) \;=\; \frac{m^2-n^2-1}{mn} .$$

> **Alignment criterion.** Two nodes are exactly hyperbolically collinear with the centre if and only if they have the same radial invariant.

The level sets of $\varrho$ are conics. When $\varrho = k$ is a positive integer, the line is the Pell-like curve
$$m^2 - kmn - n^2 = 1 .$$
For $k=1$ that is the Fibonacci relation, satisfied by $(2,1), (5,3), (13,8), (34,21), \ldots$: the golden line. For $k=2$ it is satisfied by $(5,2), (29,12), (169,70), \ldots$: the silver line, the even part of the middle spine. Every three points of one such conic are automatically collinear — the conic equation makes one column of the determinant a linear combination of the others, and $\Delta$ vanishes identically.

These conics carry their own symmetry, the integral matrix
$$T_k : (m,n) \longmapsto \big((k^2+1)m + kn,\;\; km+n\big),$$
and a Vieta-jumping descent proves that **every** positive integral point of the conic is a forward iterate $T_k^{\,j}(1,0)$ of the centre. The classification is complete, and it has a purely geometric consequence:

> **Quantization of distance.** The $j$-th node of the $k$-th line lies at hyperbolic distance exactly
> $$j \cdot \operatorname{arcosh}\!\big(1 + \tfrac{k^2}{2}\big) \;=\; 2j\log \lambda_k, \qquad \lambda_k = \frac{k+\sqrt{k^2+4}}{2},$$
> from the centre, and $d(P_i,P_j) = |i-j|\cdot 2\log\lambda_k$.

Here $\lambda_k$ is the $k$-th **metallic ratio**, the positive root of $\lambda^2 = k\lambda+1$: $\lambda_1 = \varphi = 1.618\ldots$ is golden, $\lambda_2 = 1+\sqrt2$ silver, $\lambda_3 = 3.3027\ldots$ bronze. So each visible line is not merely straight; it is a *perfectly evenly spaced ruler*, an isometric copy of the natural numbers laid along a geodesic, with the spacing set by a metallic ratio. The Fibonacci line has beads every $0.9624$ units, the silver line every $1.7627$, the bronze line every $2.3895$.

## The pencil, and how thin it is

Once you know the lines, you can survey them.

**They cross only at the centre.** An integral point on two different conics must be $(1,0)$ itself. The picture is a genuine pencil of lines through one common point, never a grid.

**Each line has an address on the boundary.** Along the $k$-th line, the ratio $n_j/m_j$ converges to $1/\lambda_k = (\sqrt{k^2+4}-k)/2$, a quadratic irrational, with error of order $m_j^{-2}$. So each line escapes to a definite ideal point of the boundary circle, and the sequence of directions $1/\varphi, \sqrt2-1, \ldots$ is itself an arithmetic object.

**Hypotenuses explode at the metallic rate.** Combining the quantization of distance with the ring theorem, the hypotenuse of the $j$-th node of the $k$-th line satisfies
$$\tfrac12 \lambda_k^{4j} \;<\; c_j \;<\; \lambda_k^{4j},$$
so consecutive hypotenuses along a line multiply by roughly $\lambda_k^4 > 6$. The golden line reads $5, 34, 233, 1597$ against $\lambda_1^4 = 6.854$: correct to the digit.

**No line is denser than the golden line.** The step length $2\log\lambda_k$ strictly increases with $k$, so it is bounded below by $2\log\varphi = 0.96242\ldots$. There is a hard *metallic gap*: no exactly collinear family of Pythagorean seeds can be packed more tightly than the Fibonacci one. Straightness has a price, and the golden ratio is the discount rate.

**The lines are a thin skeleton.** The number of nodes of the $k$-th line inside the hyperbolic ball of radius $R$ is exactly $\lfloor R/(2\log\lambda_k)\rfloor + 1$ — constant linear density — and summing over the first $K$ lines gives
$$R\sum_{k\le K}\frac{1}{2\log\lambda_k} \;\le\; \sum_{k\le K} N_k(R) \;\le\; R\sum_{k\le K}\frac{1}{2\log\lambda_k} + K .$$
Linear in $R$. Meanwhile the ring theorem says the seeds within radius $R$ are those with hypotenuse up to about $e^{2R}$, of which there are exponentially many. The straight lines you see are an asymptotically negligible sliver of the picture — which is exactly why they stand out. The eye is a filter tuned to exact alignments, and it finds them.

**Curvature matters.** Contrast the geodesics with *horocycles* — the circles tangent to the boundary, the curves of constant curvature $1$. In half-plane coordinates a horocycle at infinity is the locus $\operatorname{Im} = t$, i.e. $m$ constant, and it carries at most $m-1$ seeds. Curvature $0$ is arithmetically rich and curvature $1$ arithmetically barren.

## Every node is on a line

The integer values of $\varrho$ give beautiful lines, but the census shows crowded lines with fractional invariants: $\varrho = 2/3$ collects $(3,2), (25,18), (111,80), (949,684)$, and $\varrho = 1/2$ collects $(4,3), (41,32), (260,203), (2705,2112)$. Write $\varrho = a/b$ in lowest terms; the line is the conic
$$b m^2 - a mn - b n^2 = b .$$
It too carries its own automorphism, the matrix $\begin{pmatrix} s & bu \\ bu & s-au\end{pmatrix}$, and it does so exactly when $(s,u)$ solves the unit equation $s^2 - asu - b^2u^2 = 1$ — that is, exactly when $(s, bu)$ is itself a point of the line. The step is again a hyperbolic translation, now of length $\operatorname{arcosh}(s - au/2)$. On the $\varrho = 2/3$ line the unit is $(s,u)=(25,6)$ and the step is $\operatorname{arcosh}(19) = 3.6369$; the measured distances of $(3,2), (25,18), (111,80), (949,684)$ from the centre are $1.4910, 3.6369, 5.1279, 7.2738$ — two interleaved arithmetic progressions of that common difference, exactly as predicted.

Pell's theorem supplies such a unit whenever the discriminant $a^2+4b^2$ is not a perfect square. And when it *is* a square? Then the conic factors into two linear forms and something drastic happens:

> **Dichotomy.** For $a \ge 0$, $b>0$, the line $bm^2-amn-bn^2=b$ has a point with $m,n>0$ if and only if $a^2+4b^2$ is not a perfect square — and in that case it has infinitely many. There are no finite nonempty lines.

The proof of the empty half is a small gem. Write $a = f^2-e^2$, $b = ef$ with $\gcd(e,f)=1$; then the conic factors as $(em-fn)(fm+en) = ef$. The second factor therefore divides $ef$; every divisor of $ef$ splits as $A\cdot B$ with $A \mid e$, $B \mid f$; and $B$ must divide $n$, forcing $fm + en = AB \le en$ — absurd, since $fm > 0$.

Since every node $(m,n)$ with $0<n<m$ has radial invariant $(m^2-n^2-1)/(mn)$, the dichotomy immediately yields a purely Diophantine statement that seems to have nothing to do with hyperbolic geometry:

> For all integers $0 < n < m$, the number $(m^2-n^2-1)^2 + (2mn)^2$ is **never** a perfect square.

Equivalently: $(m^2-n^2-1, \,2mn)$ is never the pair of legs of a Pythagorean triple. Shift the first leg of a Pythagorean triple down by one and you can never repair it into another triple. (A direct sweep over all $0<n<m\le 4000$ finds no exception, as it must not.)

And now the picture closes. Because a node's own line is never square-discriminant, it is never empty, hence infinite:

> **Every node lies on an infinite line through the centre.** For each node $(m,n)$ of the tree, the set of integral nodes exactly hyperbolically collinear with it and with the centre is infinite, and it is exactly the set of positive integral points of one rational conic. Alignment is transitive, so these *alignment classes* partition the nodes into disjoint infinite lines.

Through every node passes exactly one line through the centre, and it never terminates.

## What the eye was seeing

There is one last family of "straight" curves in the plot, and they are neither geodesics nor accidents. Any affine relation among the parameters, $An + Bm + C = 0$, puts the node at *constant* distance $\operatorname{arsinh}|C/A|$ from the vertical geodesic $\operatorname{Re} = -B/A$ — a curve of constant nonzero curvature, a **hypercycle**, which in the disk looks like a circular arc meeting the boundary at two points and reads to the eye as straight. The right move $R$ fixes $n$, so the entire right spine of any node slides along the hypercycle at distance $\operatorname{arsinh}(n)$ from the central geodesic; the left spine $(m,m-1)$ satisfies $n - m + 1 = 0$ and rides the hypercycle at distance $\operatorname{arsinh}(1)$ from $\operatorname{Re}=1$.

So the taxonomy of the picture is complete. What looks straight is one of three things: a true geodesic through the centre, indexed by a rational number $\varrho$ and driven by a Pell unit, evenly spaced by a metallic ratio; a hypercycle, coming from a linear relation between $m$ and $n$; or a zigzag like the middle spine, whose Gram defect is exactly $1$ and whose alternate vertices are honestly collinear.

The moral is one that recurs whenever geometry meets arithmetic. The Pythagorean triples are an arithmetic object; the hyperbolic plane is a geometric one; and the modular action of $2\times2$ integer matrices is what connects them, because the Berggren moves and the conic automorphisms are the *same matrices*, seen once as maps of triples and once as isometries. Plot the arithmetic in the geometry that matches its symmetry group, and the structure has nowhere left to hide: it draws itself, in straight lines, for anyone who cares to look.
