# The Shape of All Doughnuts

## A tour of Teichmüller space, where every torus in the universe is a single point

Take a rectangle of paper, glue the left edge to the right edge, then glue the top edge to the bottom edge. You have made a torus — mathematically, at least; physically you have made a mess, because paper does not stretch. The object you have built is *flat*: an ant walking on it never feels any curvature, and yet the surface closes up on itself like the surface of a doughnut.

Now ask a deceptively simple question. **How many different such tori are there?**

Not "how many shapes of doughnut", which is a question about how a torus sits in three-dimensional space. The question is intrinsic: how many genuinely different *flat geometries* can live on a torus? A square gives one. A long thin rectangle gives another — an ant living there would notice that walking one way brings you home quickly and walking the other way takes forever. A slanted parallelogram gives another still.

The answer is one of the most beautiful facts in geometry. The set of all flat tori is *itself* a geometric object — a surface, with its own distances, its own straight lines, its own curvature. It has two sharp conical corner points and one infinitely long trumpet-shaped horn. It is the smallest and most vivid example of a *moduli space*, and its study opened the door to Teichmüller theory: the geometry of the space of all shapes of a surface.

This article is a tour of that space. Everything here is a precise theorem, and we will state each one as we come to it.

---

## Coordinates on the space of shapes

A flat torus is a plane divided by a lattice: take the complex plane $\mathbb{C}$ and a lattice $\Lambda$ of translations, and glue $z$ to $z + \lambda$ for every $\lambda \in \Lambda$. Every lattice has a basis of two vectors; rotating and scaling the plane (which does not change the *shape*, only the size and orientation) we may take the first basis vector to be $1$. The second is then some complex number $\tau$, and we may as well assume it lies in the upper half plane
$$\mathbb{H} = \{\tau \in \mathbb{C} : \operatorname{Im}\tau > 0\}.$$

So each point $\tau$ of the upper half plane is a flat torus $\mathbb{C}/(\mathbb{Z} + \mathbb{Z}\tau)$, *together with the choice of basis $(1,\tau)$* — geometers call that choice a **marking**, and it is the difference between the two spaces we will meet. The upper half plane, viewed this way, is called the **Teichmüller space of the torus**: the space of *marked* flat tori. The point $\tau = i$ is the square torus. The point $\tau = 2i$ is a torus twice as tall as it is wide. The point $\rho = -\tfrac12 + \tfrac{\sqrt3}{2}i$ is the *hexagonal* torus, made from the tiling of the plane by regular hexagons, and it will turn out to be the most special torus of all.

## How far apart are two shapes?

Here is where Teichmüller's idea enters. If two tori are different shapes, there is no way to map one to the other without distorting. So *measure the distortion*, and call two tori close when the best possible map between them distorts least.

To make this precise, look at a linear map of the plane. Any real-linear map of $\mathbb{C}$ can be written uniquely as
$$f(z) = a z + b\bar z, \qquad a,b \in \mathbb{C}.$$
Its Jacobian determinant is $|a|^2 - |b|^2$; the map preserves orientation and is invertible exactly when $|b| < |a|$. Such a map takes the unit circle to an ellipse, and the ratio of the ellipse's major axis to its minor axis is
$$K(f) = \frac{|a| + |b|}{|a| - |b|}.$$
This number is the **dilatation** of $f$ — the amount by which it fails to be a rotation-and-scaling. Writing $\mu = b/a$, the *Beltrami coefficient*, we have the classical formula $K = \frac{1+|\mu|}{1-|\mu|}$. Two facts are immediate and essential: $K \ge 1$ always, and $K = 1$ exactly when $b = 0$, that is, exactly when $f$ is complex-linear, hence a rotation composed with a scaling — *conformal*, distorting no angles at all.

For distortion to define a *distance*, composing two maps must not distort more than the two distortions multiplied. That is:

> **Submultiplicativity of the dilatation.** For invertible orientation-preserving real-linear maps $f, g$ of the plane, $K(f\circ g) \le K(f)\,K(g)$. Moreover $K(f^{-1}) = K(f)$.

The proof of this is prettier than one expects, and it is not an inequality at heart but an identity. If $f$ has coefficients $(a,b)$ and $g$ has $(c,d)$, then $f \circ g$ has coefficients $A = ac + b\bar d$ and $B = ad + b\bar c$, and one computes
$$|A|^2 - |B|^2 = \bigl(|a|^2-|b|^2\bigr)\bigl(|c|^2-|d|^2\bigr).$$
The cross terms cancel exactly. This is nothing but the multiplicativity of the Jacobian determinant, and it is the whole game: rewriting the dilatation as $K = (|a|+|b|)^2 / (|a|^2-|b|^2)$ — "a squared operator norm over a determinant" — the numerator obeys the crude triangle bound $|A| + |B| \le (|a|+|b|)(|c|+|d|)$ and the denominator obeys the exact product rule, and submultiplicativity falls out. (The naive attempt to bound the two axes separately *fails*: the triangle inequality gives $|A| \ge |a||c| - |b||d|$ and $|B| \le |a||d| + |b||c|$, so it only yields $|A|-|B| \ge (|a|-|b|)(|c|-|d|) - 2|b||d|$ — it loses exactly the term $2|b||d|$. The determinant identity recovers it.)

Now the **Teichmüller distance** between two marked tori $\tau$ and $\tau'$ is
$$d_T(\tau,\tau') = \tfrac12 \log K,$$
where $K$ is the least distortion of any map from one torus to the other respecting the marking. For the torus there is a clean answer, because the extremal map is the obvious one:

> **Uniqueness and extremality of the affine map.** There is exactly one real-linear map of the plane sending $1 \mapsto 1$ and $\tau \mapsto \tau'$, namely the map with coefficients
> $$a = \frac{\tau' - \bar\tau}{\tau - \bar\tau}, \qquad b = \frac{\tau - \tau'}{\tau - \bar\tau},$$
> and its dilatation is
> $$K(\tau,\tau') = \frac{\bigl(|\tau' - \bar\tau| + |\tau'-\tau|\bigr)^2}{4\,\operatorname{Im}\tau\,\operatorname{Im}\tau'}.$$

Uniqueness makes extremality free: being the only candidate, it is the best one.

## The first surprise: distortion is hyperbolic geometry

Two centuries of mathematics have made the upper half plane famous for a different reason: it carries the **hyperbolic metric**, the model of non-Euclidean geometry in which "straight lines" are semicircles meeting the real axis at right angles, and in which the angles of a triangle sum to less than $\pi$. It is a completely different structure, defined by a Riemannian metric, with nothing obviously to do with stretching ellipses.

> **Main theorem.** The Teichmüller metric on the space of marked flat tori is exactly one half of the hyperbolic metric:
> $$d_T(\tau,\tau') = \tfrac12\, d_{\mathbb{H}}(\tau,\tau').$$
> Equivalently, the extremal distortion between two marked tori is the exponential of their hyperbolic distance: $K(\tau,\tau') = e^{\,d_{\mathbb{H}}(\tau,\tau')}$.

An analytic extremal problem on the left; a classical Riemannian metric on the right. The bridge is a Pythagoras-like identity for the reflection $\bar\tau$ of $\tau$ across the real axis,
$$|\tau' - \bar\tau|^2 = |\tau' - \tau|^2 + 4\operatorname{Im}\tau\operatorname{Im}\tau',$$
which, when both sides of the theorem are fed into the hyperbolic cosine, makes them literally the same rational function. The factor $\tfrac12$ cannot be scaled away — it is why the Teichmüller metric of the torus has curvature $-4$ rather than $-1$.

Distances are now easy to compute, and the space is easy to travel through. The **stretch line** $\sigma_t$ = the torus $\mathbb{C}/\langle 1, i e^{2t}\rangle$ is a unit-speed geodesic: $d_T(\sigma_s,\sigma_t) = |t-s|$, exactly, with the triangle inequality becoming an equality along the line. Along it the distortion grows like $e^{2|t-s|}$ — distortion is exponential in distance, which is why the definition took a logarithm in the first place. In particular the space of marked tori has infinite diameter.

## Forgetting the marking: the orbifold appears

So far we have been remembering which basis we chose. Forget it, and something interesting happens: the same *unmarked* torus is now represented by many points of $\mathbb{H}$. A lattice basis can be changed by any integer matrix of determinant one, and the resulting change of $\tau$ is the Möbius transformation
$$\tau \longmapsto \frac{a\tau+b}{c\tau+d}, \qquad \begin{pmatrix}a&b\\c&d\end{pmatrix} \in SL(2,\mathbb{Z}).$$
This group is the **mapping class group** of the torus, and it acts by isometries of the Teichmüller metric. The space of *unmarked* tori — the **moduli space** — is the quotient, with the natural distance
$$d_M(\tau,\tau') = \inf_{g} \; d_T(\tau, g\cdot\tau').$$

Three phenomena are visible in this quotient, and remarkably all three are read off from a single formula. For $g$ with entries $a,b,c,d$ and $z = x+iy$,
$$\cosh d_{\mathbb{H}}(z, g\cdot z) \;=\; \frac{(a+d)^2 - 2}{2} \;+\; \frac{\bigl(c(x^2+y^2) - (a-d)x - b\bigr)^2}{2y^2}.$$
Everything about how far $g$ moves a point is governed by the trace $a+d$ and one perfect square. The three classical cases $|{\rm tr}| < 2$, $=2$, $>2$ are exactly the three ways a torus map can behave.

**Cone points.** The matrix $\left(\begin{smallmatrix}0&-1\\1&0\end{smallmatrix}\right)$ fixes the square torus $i$: the square torus is symmetric under a quarter turn. The matrix $\left(\begin{smallmatrix}0&-1\\1&1\end{smallmatrix}\right)$ fixes the hexagonal torus $\rho$, with order three. Because these points have symmetry, the quotient is not a smooth surface but an **orbifold** — near $i$ it is a cone of angle $\pi$, near $\rho$ a cone of angle $2\pi/3$. And the two are genuinely different points: solving $g\cdot i = i$ over the integers forces $a=d$, $b=-c$, hence $a^2+c^2=1$, which has only four solutions, all squaring to $\pm 1$ — so the symmetry group at $i$ has order two in the projective group while at $\rho$ it has order three, and no change of basis can turn one torus into the other.

**The cusp.** The shear $\tau \mapsto \tau+1$ moves *every* point a positive distance — precisely, $\cosh d_{\mathbb{H}}(\tau,\tau+1) = 1 + 1/(2(\operatorname{Im}\tau)^2)$ — and yet that distance tends to $0$ as $\operatorname{Im}\tau \to \infty$. Its infimum is zero and is never attained. This is the trumpet: the moduli space is not compact, and its non-compactness is entirely the story of long thin tori.

## The shortest loop, and the best doughnut in the world

There is one number attached to a flat torus that everything else can be measured against: the length of its shortest closed geodesic — its **systole** — compared with its area. Since the torus $\mathbb{C}/(\mathbb{Z}+\mathbb{Z}\tau)$ has area $\operatorname{Im}\tau$ and its closed geodesics have lengths $|m+n\tau|$, the natural scale-invariant quantity is
$$\operatorname{sys}(\tau) \;=\; \min_{(m,n) \ne (0,0)} \frac{|m+n\tau|^2}{\operatorname{Im}\tau}.$$
The minimum is genuinely attained (only finitely many lattice vectors are short), the quantity is unchanged by change of basis, so it is a function on the moduli space itself.

> **Hermite's constant in dimension two.** For every flat torus, $\operatorname{sys}(\tau) \le 2/\sqrt3$, and the bound is sharp: it is attained exactly at the hexagonal torus, where $\operatorname{sys}(\rho) = 2/\sqrt3 \approx 1.1547$. At the square torus $\operatorname{sys}(i) = 1$.

The hexagonal torus is, in this precise sense, the *roundest possible doughnut*: no flat torus packs as much shortest-loop length into as little area. This is the two-dimensional case of the sphere-packing constant $\gamma_2$, and the proof is a reduction-theory argument: push $\tau$ into the standard fundamental domain, where the imaginary part is at least $\sqrt3/2$, and the shortest vector is the horizontal one.

The systole is also a superb *measuring instrument* for the moduli space, because it varies slowly:
$$\bigl|\log \operatorname{sys}(z) - \log \operatorname{sys}(w)\bigr| \le d_{\mathbb{H}}(z,w).$$
Three consequences follow, and they are the technical heart of the subject.

*First*, distinct shapes are far apart. Since $\operatorname{sys}$ takes the value $1$ on the whole orbit of the square torus and $2/\sqrt3$ at the hexagonal one, the two cone points satisfy $d_M(\rho, i) \ge \tfrac12\log(2/\sqrt3) > 0$ — a lower bound for an infimum over an infinite group, obtained with no compactness whatever.

*Second*, the group acts **properly discontinuously**: for any two tori and any bound $R$, only finitely many changes of basis move one within distance $R$ of the other. This is arithmetic, not analysis — it says the quadratic form $|c w + d|^2$ takes any bounded value only finitely often on the integers. Consequently every symmetry group is finite, the infimum defining $d_M$ is a *minimum*, and $d_M(\tau,\tau') = 0$ if and only if the two tori really are the same shape. The moduli space is a genuine metric space.

*Third*, the systole measures exactly how far out into the trumpet you have gone:
$$\Bigl| \, d_M(\rho, \tau) - \tfrac12\log\frac{1}{\operatorname{sys}(\tau)} \, \Bigr| \;\le\; \tfrac12 \log 5 .$$
Distance to the hexagonal point and the logarithm of the reciprocal systole agree up to a universal additive constant — the multiplicative constant is exactly $1$. From this, **Mahler's compactness criterion** for planar lattices follows: for every $\varepsilon > 0$ there is a single compact set $K \subset \mathbb{H}$ such that *every* torus with $\operatorname{sys} \ge \varepsilon$ has a representative in $K$. The thick part of moduli space is compact; the moduli space is a proper metric space, with compact balls.

## Two loops, not one: Minkowski's theorem

A thin torus has one very short loop. Does it also have a second short one? No — and the sharp form of that statement is a "collar lemma": if $(m,n)$ realizes the systole, then every independent lattice direction $(p,q)$ satisfies
$$\frac{|p + q\tau|^2}{\operatorname{Im}\tau} \;\ge\; \frac{1}{\operatorname{sys}(\tau)} .$$
Short forces long, reciprocally. The proof is an identity, not an estimate: for $u = m+n\tau$, $v = p+q\tau$, Lagrange's identity gives $|u|^2|v|^2 = (\operatorname{Re}\bar u v)^2 + (\operatorname{Im} \bar u v)^2$ and $\operatorname{Im}\bar u v = (mq-np)\operatorname{Im}\tau$, so the whole statement reduces to "a nonzero integer has square at least $1$". In particular, on the thin part $\operatorname{sys}(\tau) < 1$, the shortest closed geodesic is *unique* up to reversal.

Defining the second successive minimum $\operatorname{sys}_2(\tau)$ as the smallest normalized value achieved by a lattice direction independent of the shortest one, one gets the sharp two-sided bound of Minkowski:

> **Minkowski's second theorem for tori.** For every flat torus, $\;1 \le \operatorname{sys}(\tau)\cdot\operatorname{sys}_2(\tau) \le 4/3$. The upper bound $4/3$ holds exactly at the hexagonal torus and its images, and the lower bound $1$ holds exactly at the rectangular tori. On the standard fundamental domain the product has the closed form $|\tau|^2/(\operatorname{Im}\tau)^2$.

So the product of the two successive minima is a second shape coordinate: maximal precisely at the roundest torus, minimal precisely at the rectangular ones. The two extremes of Minkowski's inequality are exactly the hexagonal point and the rectangular locus — no other tori.

## Dynamics: how much can a shape be stretched?

Return to the mapping class group, and take a matrix of trace larger than $2$ in absolute value — say Arnold's cat map $\left(\begin{smallmatrix}2&1\\1&1\end{smallmatrix}\right)$, the transformation whose repeated application scrambles a picture of a cat beyond recognition. Such a map is *Anosov*: it stretches the torus by a factor $\lambda$ in one direction and squeezes it by $1/\lambda$ in the other. How far does it move a point of moduli space?

> **Translation length.** For $g$ with $|{\rm tr}\,g| > 2$, the minimum of $d_T(\tau, g\cdot\tau)$ over all marked tori is attained (on the *axis* of $g$) and equals
> $$\log \lambda(g), \qquad \lambda(g) = \frac{|{\rm tr}\,g| + \sqrt{({\rm tr}\,g)^2-4}}{2}.$$

This is the torus case of a theorem of Bers: the minimal displacement of a pseudo-Anosov mapping class in Teichmüller space is the logarithm of its stretch factor. The *metric* invariant on the left is computed by an *arithmetic* invariant on the right — the trace of an integer matrix.

Because traces are integers, the possible answers are quantized. Every trace with $|{\rm tr}| > 2$ has $|{\rm tr}| \ge 3$, so:

> **The length spectrum.** The set of translation lengths of Anosov classes of the torus is exactly
> $$\{\,\operatorname{arcosh}(n/2) \;=\; \log\tfrac{n+\sqrt{n^2-4}}{2} \;:\; n \in \mathbb{Z},\ n \ge 3 \,\},$$
> every value being realized by the explicit matrix $\left(\begin{smallmatrix}n&-1\\1&0\end{smallmatrix}\right)$. The parametrization is strictly increasing, the set is discrete (a length $\le M$ forces $|{\rm tr}| \le 2e^M$, so only finitely many lengths lie below any bound), it is unbounded, and its least element is
> $$\log\frac{3+\sqrt5}{2} = 2\log\varphi \approx 0.9624,$$
> attained by the cat map, where $\varphi = (1+\sqrt5)/2$ is the golden ratio.

The moduli space of tori therefore has a *spectral gap*: no nontrivial Anosov class moves any shape by less than twice the logarithm of the golden ratio. The number of lengths below $L$ is $\lfloor 2\cosh L\rfloor - 2 \sim e^L$: exponential growth, the classical shape of a length spectrum.

## What we have seen

From one question — how many doughnuts are there? — a whole landscape:

- the upper half plane as the space of marked flat tori, with distance measured by optimal distortion, equal to half the hyperbolic distance;
- a quotient by an arithmetic group producing an orbifold with two cone points, of angles $\pi$ and $2\pi/3$, and one cusp;
- the hexagonal torus as the unique extremal shape, giving Hermite's constant $\gamma_2 = 2/\sqrt3$;
- the systole as a proper exhaustion function, comparable to the distance from the hexagonal point up to $\tfrac12\log 5$, and the compactness of the thick part;
- successive minima with product confined to $[1,4/3]$, extremal exactly at the hexagonal and the rectangular tori;
- and a length spectrum $\{\operatorname{arcosh}(n/2)\}_{n\ge 3}$, whose bottom is the golden ratio squared.

Every one of these statements is the toy model of a far harder theorem about surfaces of higher genus — Bers' theorem on pseudo-Anosov stretch factors, Mumford's compactness criterion, the thick-thin decomposition, Royden's theorem that the Teichmüller metric is the Kobayashi metric. The torus is where you can see all of it at once, drawn in closed form on a single sheet of paper. That is why, a century after Teichmüller, it is still the first thing anyone learns.
