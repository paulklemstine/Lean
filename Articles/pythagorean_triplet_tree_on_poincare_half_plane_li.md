# The Pythagorean Star Map

## What happens when you draw every right triangle in the hyperbolic plane

---

### A picture that demands an explanation

Start with the oldest theorem in mathematics and one of the youngest geometries, and put them in the same room.

The oldest theorem gives you the *Pythagorean triples*: whole numbers with $a^2 + b^2 = c^2$. The primitive ones — those with no common factor — are produced, as Euclid knew, by a pair of integers $(m,n)$ with $0 < n < m$, $\gcd(m,n)=1$, and $m+n$ odd:
$$a = m^2 - n^2, \qquad b = 2mn, \qquad c = m^2 + n^2 .$$
Call such a pair a **seed**. The seed $(2,1)$ gives $(3,4,5)$; the seed $(3,2)$ gives $(5,12,13)$; $(4,1)$ gives $(15,8,17)$.

These seeds are not a shapeless heap. In 1934 B. Berggren noticed that they form an infinite *ternary tree*: from the root $(2,1)$, three simple moves
$$B_1(m,n) = (2m-n,\ m), \qquad B_2(m,n) = (2m+n,\ m), \qquad B_3(m,n) = (m+2n,\ n)$$
generate every primitive triple, each exactly once, with no repetitions and no omissions. It is one of the most perfectly organised objects in elementary number theory: a free tree, three children per node, containing all of Pythagoras.

The young geometry is the **Poincaré upper half-plane** $\mathbb{H}$: the set of complex numbers with positive imaginary part, equipped with the distance in which a step of Euclidean size $|dz|$ costs $|dz|/\operatorname{Im} z$. Near the real axis, distances explode; the real line itself is infinitely far away, an unreachable horizon that geometers call the *ideal boundary*.

Now put the seeds into that geometry by the simplest recipe imaginable:
$$z(m,n) = \frac{n+i}{m} = \frac{n}{m} + \frac{i}{m}.$$
Plot a few thousand of them. What appears on the screen is not a cloud. It is a **star map**: hundreds of razor-straight lines radiating out of two special points on the horizon — the point $0$ and the point $1$ — crossed by a family of nested arcs, with a single conspicuous ray marching diagonally off to infinity. It looks less like number theory than like a long-exposure photograph of a spiral galaxy.

This article explains that picture. Every feature of it — every line, every arc, the two centres, the diagonal ray, even the fact that the two stars have *different numbers of lines* — turns out to be a precise theorem.

---

### The first surprise: the hypotenuse is a distance

Fix the base point $i$ and ask how far a seed's node is from it. The half-plane distance obeys $\cosh d(z,w) = 1 + |z-w|^2/(2\operatorname{Im}z\operatorname{Im}w)$, and a two-line computation with $z=i$, $w=(n+i)/m$ yields something startling:

> **The distance formula.** For every seed $(m,n)$, with $c = m^2+n^2$ the hypotenuse of the corresponding triple,
> $$\cosh d_{\mathbb{H}}\big(i,\, z(m,n)\big) \;=\; \frac{m^2+n^2+1}{2m} \;=\; \frac{c+1}{2m}.$$

The embedding used only the ratio $n/m$ and the height $1/m$; nowhere did we mention $m^2+n^2$. Yet the hypotenuse of the triangle appears, unbidden, as the numerator of a hyperbolic cosine. Because $n<m$ forces $\sqrt{c/2} < m \le \sqrt{c}$, this pins the distance almost exactly:
$$\tfrac12 \log c \;\le\; d_{\mathbb{H}}\big(i, z(m,n)\big) \;\le\; \tfrac12\log\big(2(c+1)\big),$$
with the lower bound *exact* — no additive constant at all. Hyperbolic radius is half the logarithm of the hypotenuse, to within a band of width $\tfrac12\log 2 = 0.3466\ldots$. The nested arcs in the picture are the level sets of this function, and the triples are sorted onto them by size.

Even the residual $\rho = d - \tfrac12\log c$ is completely known: it equals $\tfrac12\log(1+t^2)$, a function of the *slope* $t = n/m$ alone, up to a discrepancy of exactly $n^2/c^2\,(1+O(1/c))$. So a node's radius encodes its hypotenuse and its fine position within the band encodes its shape.

---

### The second surprise: the stars are exactly two, and they are grids

Why lines? A line through the boundary point $1$, in the half-plane, is the set of $z$ with $1 - \operatorname{Re}z = u \operatorname{Im} z$ for a fixed real $u$ (its reciprocal slope). Plug in $z(m,n)$:
$$1 - \frac{n}{m} = \frac{m-n}{m} = (m-n)\cdot \frac{1}{m}.$$
So the node sits on the line through $1$ with parameter $u = m-n$ — *exactly*, on the nose. Likewise
$$\operatorname{Re} z(m,n) = \frac{n}{m} = n \cdot \frac{1}{m},$$
so it sits on the line through $0$ with parameter $n$.

Every node therefore lies on one line of a star centred at $1$ and one line of a star centred at $0$, and it is determined by that pair. Change coordinates from $(m,n)$ to the **charges** $(u,n) = (m-n,\, n)$, and the entire seed set becomes a transparent object:

> **The grid theorem.** The set of Berggren nodes, in charge coordinates, is exactly the grid
> $$\{(u,n)\ :\ u \text{ odd},\ \ \gcd(u,n)=1\}.$$
> A node is the intersection of one line of the $1$-star with one line of the $0$-star.

This is the whole picture in one sentence. Two pencils of lines; the visible nodes are the coprime intersections; and the odd-parity condition (which is just the classical requirement that $m+n$ be odd) is what makes the two stars *different*:

> **Quantisation.** The star at $1$ contains only the lines of **odd** charge $u = 1, 3, 5, \ldots$; the star at $0$ contains the line of **every** charge $n = 1, 2, 3, \ldots$. In particular the line of charge $2$ exists in one star and not the other, so the two stars are not mirror images.

Look at the picture again and you can see it: the fan at $1$ is sparser, missing every other ray.

And there is more in the picture than two stars. The same one-line computation works at any rational $p/q$ in lowest terms:
$$\frac{p}{q} - \operatorname{Re}z(m,n) = \frac{pm-qn}{q}\cdot\operatorname{Im}z(m,n),$$
so the nodes with $q \mid m$ form a quantised star at $p/q$ too. Every rational point of the horizon has its own little fan; $0$ and $1$ are simply the case $q=1$, where the lines are densest and the parameters smallest. Zoom into a rendered picture and the smaller fans appear, at $1/2$, at $1/3$, at $2/5$, everywhere.

---

### The lines are not lines

Here the hyperbolic geometry has the last word. A Euclidean straight line touching the horizon at $1$ is *not* a hyperbolic geodesic (those are the vertical rays and the semicircles orthogonal to the horizon). It is a **hypercycle**: the locus of points at a constant distance from a genuine geodesic, the hyperbolic analogue of a pair of railway tracks that stay a fixed width apart but of which only one is straight.

> **The hypercycle theorem.** A node $z(m,n)$ lies at hyperbolic distance exactly $\operatorname{arsinh}(m-n)$ from the vertical geodesic joining $1$ to $\infty$, and at distance exactly $\operatorname{arsinh}(n)$ from the vertical geodesic joining $0$ to $\infty$. These are *least* distances, attained at the foot of the perpendicular.

So the charges $u$ and $n$ are not bookkeeping devices: they are hyperbolic *widths*. The star at $1$ is a family of tracks running alongside a single geodesic at the quantised distances $\operatorname{arsinh} 1, \operatorname{arsinh} 3, \operatorname{arsinh} 5, \ldots$, and the star at $0$ at the distances $\operatorname{arsinh} 1, \operatorname{arsinh}2, \operatorname{arsinh}3,\ldots$. The "lines" in the picture are curves of constant width — which is exactly why they look straight and are not.

---

### The tree runs along the star lines

Why should the *tree* respect this pattern? Because each of Berggren's three moves treats the two charges differently. Compute:

- $B_1(m,n) = (2m-n, m)$ leaves $u = m-n$ **unchanged** and increases $n$;
- $B_3(m,n) = (m+2n, n)$ leaves $n$ **unchanged** and increases $u$;
- $B_2(m,n) = (2m+n, m)$ increases **both**.

So for each node, exactly one move slides it along its $1$-star line, exactly one slides it along its $0$-star line, and the third jumps transversally. Iterating gives closed forms of beautiful simplicity:
$$B_1^{\,k}(n+u,\ n) = \big(n + (k{+}1)u,\ n + ku\big), \qquad B_3^{\,k}(m,n) = (m + 2kn,\ n).$$
The first is a pure translation, the second a pure shear. **The radiating lines of the picture are the $B_1$- and $B_3$-orbits of the tree.**

How many orbits fit on one line? A line of charge $u$ is an infinite arithmetic progression of nodes, and the translation $B_1$ moves each node forward by one period; the maximal arms therefore correspond to residues, and coprimality selects which residues occur. The count is a classical function:

> **The totient law of the stars.** For every charge $q \ge 1$, the star line of charge $q$ — in either star — carries exactly $\varphi(2q)$ maximal arms, where $\varphi$ is Euler's totient function.

The line of charge $5$ in the $0$-star, for instance, carries $\varphi(10)=4$ arms. Euler's function counts the strands of the Pythagorean star.

---

### Two speeds: crawling to the horizon, or marching

The picture contains one feature that no star line explains: a solitary ray shooting out diagonally. That is the orbit of the *middle* move, and it lives in a different dynamical world.

Watch what the three moves do to the slope $t = n/m$. They are Möbius maps:
$$B_1: t \mapsto \frac{1}{2-t}, \qquad B_2: t \mapsto \frac{1}{2+t}, \qquad B_3: t \mapsto \frac{t}{1+2t}.$$
They send the interval $(0,1)$ into $(\tfrac12,1)$, $(\tfrac13,\tfrac12)$ and $(0,\tfrac13)$ respectively — three disjoint windows, which is a second proof that the tree never collides with itself.

The outer two are **parabolic**. In the coordinate $x = 1/(1-t)$ the map $B_1$ is simply $x \mapsto x+1$; in the coordinate $x = 1/t$ the map $B_3$ is $x \mapsto x+2$. Translations. Their orbits therefore have exact closed forms and converge to the boundary points $1$ and $0$ at the leisurely parabolic rate
$$k\big(1 - t_k\big) \to 1 \qquad\text{and}\qquad k\, t_k \to \tfrac12 .$$
Error of order $1/k$: a crawl.

The middle move is **hyperbolic**, and its behaviour is categorically different. It has a fixed point,
$$t_\star = \sqrt2 - 1,$$
the *silver slope*, and it contracts towards it by a factor of at least $4$ at every step:
$$\big|B_2^{\,k}(t) - t_\star\big| \;\le\; 4^{-k}\,|t - t_\star| .$$
Exponential convergence. And $\sqrt2 - 1$ is **irrational** — so the middle orbit does *not* head for a cusp of the star map. It heads for an irrational point of the horizon that no star line can reach.

The metric consequence is the sharpest statement in the subject. Measure the hyperbolic length of each single step of a path down the tree. Along a star arm the steps satisfy, exactly,
$$\cosh(\text{step}) = 1 + \frac{u^2(u^2+1)}{2A(A+u)}, \qquad A = \text{the current } m,$$
which tends to $1$: **the steps shrink to zero**. The arm is an infinite path of finite-and-shrinking increments, covering only logarithmic distance — $\log k - \log 2 \le d \le \log k + \log(n+2u) + \tfrac32 \log 2$ after $k$ steps. That is why the arms read as smooth curves gliding into the horizon.

Along the middle spine the same computation gives the opposite:

> **The step trichotomy.** Along a parabolic star arm the hyperbolic step lengths tend to $0$. Along the middle spine they tend to $\log(1+\sqrt2) = 0.8814\ldots$, the translation length of the silver ratio.

That single number is the reason the diagonal ray is visible at all: it is a genuine geodesic being traversed at constant speed, roughly $0.88$ units per generation forever, while every other branch of the tree is decelerating into the boundary. The seeds along it are the Pell numbers $(2,1), (5,2), (12,5), (29,12), (70,29), (169,70), \ldots$, characterised by the Pell invariant $m^2 - 2mn - n^2 = \pm1$, and the ratios $m_{k+1}/m_k$ obey the recursion $r \mapsto 2 + 1/r$ and converge to the silver ratio $1+\sqrt2$ at rate $4^{-k}$.

---

### The stars are an optical illusion — a beautiful one

A finite picture shows two stars. The truth is more generous.

> **Density of the limit set.** Every point of the interval $[0,1]$ on the horizon is an accumulation point of Berggren nodes. For every target $t$ and every tolerance $\varepsilon$, there is a seed whose slope is within $\varepsilon$ of $t$ *and* whose height is below $\varepsilon$.

The proof is a one-line construction that ought to be better known: take $m = 2^K$ a power of two and $n$ any odd number below it. Coprimality is automatic (an odd number shares no factor with a power of $2$) and the parity condition is automatic too. The odd numbers are $2$-dense, so these *dyadic seeds* approximate every direction. So the tree radiates in every direction at once; the two stars are simply the directions in which the radiation is organised into visible straight lines rather than diffuse haze.

---

### And the arcs: circles that are circles

The nested arcs are the hyperbolic circles $d(i,\cdot) = R$, and the distance formula converts them into something a schoolchild can draw. Rearranging $\cosh d = (m^2+n^2+1)/(2m) \le \cosh R$ gives

> **The circle theorem.** A node lies in the hyperbolic ball of radius $R$ about $i$ if and only if the integer point $(m,n)$ lies in the ordinary Euclidean disc
> $$(m - \cosh R)^2 + n^2 \;\le\; \sinh^2 R .$$

A transcendental hyperbolic condition becomes a lattice-point count in a Euclidean disc. Counting the seeds inside gives $\Theta(e^{2R})$ nodes — precisely the growth rate of hyperbolic *area*, so the tree is a uniform net in the plane it inhabits. The disc picture even predicts the constant: the disc, rescaled, meets the seed cone $0<n<m$ in a region of area $\tfrac\pi4 + \tfrac12$; Euclid seeds have density $4/\pi^2$ among integer pairs (coprimality contributes $6/\pi^2$, opposite parity another factor $2/3$); and the product gives
$$\#\mathcal{B}(R) \;\sim\; \frac{\pi+2}{4\pi^2}\, e^{2R} \;=\; 0.1302380\ldots\, e^{2R}.$$
Direct enumeration at $R = 3,\ldots,8$ gives ratios $0.12890,\ 0.13016,\ 0.13012,\ 0.13020,\ 0.13024,\ 0.13024$. The agreement is striking; the theorem is still open.

---

### The sting in the tail: geometry does not factor numbers

Now the part of the story that failed, which is often the most instructive part.

Euler's factorisation method says: if an odd $N$ has two *essentially different* representations as a sum of two squares, then $N$ is composite and you can extract a factor for free, by two greatest-common-divisor computations. The classic example is $65 = 8^2+1^2 = 7^2+4^2$, from which $\gcd(65, 8\cdot 7 + 1\cdot 4) = \gcd(65,60) = 5$ and $\gcd(65, 8\cdot4+1\cdot7) = \gcd(65,39)=13$.

Two seeds with the same hypotenuse are exactly such a pair — a **collision** in the tree. And by the distance formula, both colliding nodes sit at radius $\tfrac12\log N + O(1)$: they are hyperbolic near-neighbours, both on the same thin annulus. Surely, then, one can *walk* from one to the other in a few steps and factor $N$ in logarithmic time?

No. Two exact results kill it.

First, the collision distance is known precisely. Writing $P = m_1m_2 + n_1n_2$ for the **Euler pivot**, the Brahmagupta–Fibonacci identity yields
$$\cosh d(z_1,z_2) \;=\; 1 + \frac{(N^2 - P^2) + (m_1-m_2)^2}{2m_1m_2},$$
and since the extracted divisor $g$ divides both $N$ and $P$ while $P<N$, the deficit $N-P$ is at least $g$. Hence
$$\cosh d(z_1,z_2) \;\ge\; 1 + \tfrac{g}{2}, \qquad\text{so}\qquad d(z_1,z_2) \;\ge\; \log g - \log 2 .$$
*The two nodes are pushed apart in proportion to the very divisor they reveal.* If the collision extracts the larger factor ($N \le g^2$), then $d(z_1,z_2) \ge \tfrac12\log N - \log 2$: the pair is essentially antipodal on its annulus, and no local search around one witness will ever bump into the other. For $65$ the bound reads $\log 5 - \log 2 = 0.916$, and the true separation is $2.573$.

Second, and decisively, the annulus is crowded. The ball guaranteed to contain the collision has radius about $\tfrac12 \log N + \log 2$, and by the volume count it already contains $\Theta(e^{2R}) = \Theta(N)$ nodes. The hyperbolic metric compresses the search *space* and the search *target* by exactly the same exponential factor. There is no shortcut. Trial enumeration over $\sqrt N$ values of $m$ remains the honest algorithm, and the geometry has nothing better to offer.

---

### What the picture was telling us

The star map turns out to be a complete dictionary. The radial coordinate is half the logarithm of the hypotenuse. The angular fine structure is the slope. The two stars are the two conserved charges $m-n$ and $n$ of the tree's parabolic moves, and they are hyperbolic widths, quantised odd on one side and unrestricted on the other, with $\varphi(2q)$ strands per line. The lone diagonal ray is the tree's one hyperbolic isometry, translating by $\log(1+\sqrt2)$ per step toward an irrational point of the horizon. The arcs are Euclidean discs in disguise. The haze between the rays is the tree's limit set, which is everything.

And Pythagoras, five thousand years on, still has a geometry we had not looked at.
