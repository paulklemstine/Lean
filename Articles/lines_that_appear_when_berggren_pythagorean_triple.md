# The Pythagorean Star Map

*What happens when you plot every right triangle in the hyperbolic plane*

---

## A picture that shouldn't be so tidy

Start with something everyone learns at school: the right triangles with whole-number sides. $3,4,5$. Then $5,12,13$. Then $8,15,17$, $7,24,25$, $20,21,29$. There are infinitely many of them, and if you throw out the ones that are just scaled copies of smaller ones, you are left with the *primitive* Pythagorean triples — an infinite, ragged-looking list of integer triples $(A,B,C)$ with $A^2+B^2=C^2$.

Now do something that a Greek geometer would not have thought of. Every primitive triple comes from a pair of whole numbers by Euclid's ancient recipe:
$$A = m^2-n^2, \qquad B = 2mn, \qquad C = m^2+n^2,$$
where $m>n>0$ share no common factor and are of opposite parity — one even, one odd. Call such a pair $(m,n)$ a *seed*. The seed $(2,1)$ gives $(3,4,5)$; the seed $(3,2)$ gives $(5,12,13)$; the seed $(4,1)$ gives $(15,8,17)$. Every primitive triple comes from exactly one seed.

A seed is just two numbers, so we can plot it as a point. But instead of plotting $(m,n)$ on ordinary graph paper, plot the complex number
$$z(m,n) \;=\; \frac{n+i}{m} \;=\; \frac{n}{m} + \frac{i}{m}.$$
Horizontally this places the triangle at the ratio $n/m$, its *slope*; vertically at the height $1/m$, so bigger triangles sink towards the horizontal axis. And then declare that the upper half of the plane is not flat but *hyperbolic*: distances near the bottom edge are stretched enormously, so that the horizontal axis is infinitely far away — it is a horizon, not an edge. This is the Poincaré half-plane, the workhorse model of the non-Euclidean geometry that Bolyai and Lobachevsky discovered and Poincaré made concrete.

Plot a few thousand triangles this way and you expect a fog of dots. What you get instead is a **star map**. Straight lines fan out from the point $0$ on the horizon. Another fan blazes at $1$. Look closer and there are fans at $0.5$, at $0.333\ldots$, at $0.2$, at $0.4$ — smaller, tighter, but unmistakably there. A single white ray strides out from the centre in even, purposeful steps.

None of this is an accident of the drawing. Every one of those features is a theorem, and this article explains them.

---

## The first surprise: the hypotenuse is a distance

Before the fans, one clean fact sets the stage. Take the point $i$ (the seed of nothing in particular; it is just the natural centre of the picture) and measure the hyperbolic distance from $i$ to the node of the seed $(m,n)$. Hyperbolic distance is defined by a rather forbidding integral, but here it collapses to arithmetic:
$$\cosh\big(\text{distance from } i \text{ to } z(m,n)\big) \;=\; \frac{m^2+n^2+1}{2m}.$$
The numerator is the hypotenuse $C = m^2+n^2$, plus one. The hypotenuse of the triangle, a quantity built from the *squares* of the seed coordinates, appears as the hyperbolic cosine of a distance — even though the embedding only ever used $n/m$ and $1/m$.

The consequence is a law of the picture: the distance out from the centre is
$$\tfrac12\log C \;+\; \text{a small correction, always between } 0 \text{ and } 0.3466.$$
Triangles with hypotenuse near $C$ all live in a thin annulus at radius $\tfrac12\log C$. The radial coordinate of the star map is, essentially, the logarithm of the hypotenuse.

That settles *how far out*. The interesting question is *in which direction* — and that is where the fans live.

---

## The charge: one integer that explains a ray

Pick a rational number on the horizon and write it in lowest terms as $p/q$: perhaps $0 = 0/1$, or $1 = 1/1$, or $1/2$, or $1/3$. Now attach to each seed $(m,n)$ a single whole number, which we will call its **charge at $p/q$**:
$$\chi \;=\; pm - qn.$$

That is the whole idea. Everything follows from it.

**First, the charge draws a line.** A short computation gives
$$\frac{p}{q} - \frac{n}{m} \;=\; \frac{\chi}{q}\cdot\frac{1}{m},$$
which says: *horizontal displacement from $p/q$ equals $\chi/q$ times the height*. That is the equation of a straight ray emanating from the boundary point $p/q$ with fixed slope. Every seed with the same charge lies on the same ray, and different charges give different rays. **The radial lines of the star map are the level sets of the charge.** The whole fan at $p/q$ is the family of rays, one per integer value of $\chi$, and its angular spacing is set by $1/q$.

**Second, those rays are geometrically real.** A Euclidean straight ray from a boundary point is *not* a hyperbolic straight line — the true straight lines here are vertical rays and semicircles meeting the horizon at right angles. But there is an exact hyperbolic meaning, and it is even better. The distance from the node of charge $\chi$ to the vertical line rising out of $p/q$ is
$$\operatorname{arsinh}\frac{|\chi|}{q},$$
a number that depends on the node *only through its charge*. Curves at a constant distance from a straight line are called **hypercycles** — in ordinary flat geometry they would just be parallel lines, but hyperbolic geometry has no parallels in that sense, and hypercycles are genuinely curved objects. So each ray of the fan is a hypercycle, and the fan is a discrete ladder of hypercycles at the heights $\operatorname{arsinh}(1/q), \operatorname{arsinh}(2/q), \operatorname{arsinh}(3/q),\ldots$

The charge is thus a *conserved quantity with a metric meaning*: it is a hyperbolic width, measured in rungs of a ladder whose spacing depends on the denominator of the star's centre.

---

## Missing rays: a fan can be half empty

Here is where the arithmetic starts to bite. Look at the fan at $1/3$. Its rays should sit at charges $\ldots,-2,-1,0,1,2,\ldots$. Enumerate the seeds and you find charges $\pm1,\pm3,\pm5,\pm7,\ldots$ — and never an even one. **Half the fan is switched off.**

The reason is a one-line parity argument. A seed has $m+n$ odd, so exactly one of $m,n$ is even. If $p$ and $q$ are both odd, then $pm-qn$ is (even $-$ odd) or (odd $-$ even), and either way it is odd. So:

> **If $p$ and $q$ are both odd, every seed has odd charge at $p/q$, and the even rays of that fan are empty.**

The condition "$p$ and $q$ both odd" is the same as "$p+q$ even". And when $p+q$ is odd there is no obstruction at all: every integer charge occurs. So the fans come in exactly two flavours:

* **Full fans** ($p+q$ odd): $0$, $1/2$, $1/4$, $2/5$, $3/4$, … Every integer charge is realised.
* **Half fans** ($p+q$ even): $1$, $1/3$, $1/5$, $3/5$, $3/7$, … Only odd charges are realised.

This explains something that had been a curiosity about the two most obvious fans in the picture. The fan at $0$ realises every charge; the fan at $1$ realises only the odd ones. The two most conspicuous features of the star map are not mirror images of each other — and now we know why: $0 = 0/1$ has $p+q$ odd, and $1 = 1/1$ has $p+q$ even.

### The hole in the middle

There is a companion fact about the central ray of a fan — the ray of charge $0$, which is the vertical straight line rising out of $p/q$. It can carry at most one node, and only one candidate ever qualifies: the seed $(q,p)$, the star's own centre read backwards. That pair is a genuine seed exactly when $p+q$ is odd.

So a full fan has a bright node sitting exactly on its axis, and a half fan has a **hole** there. And the axis node of the fan at $1/2$ is the seed $(2,1)$: the triple $(3,4,5)$, the root of the entire tree of Pythagorean triples, the first right triangle anybody ever learns. The fan you notice at $0.5$ in the picture is centred on the origin of the whole structure.

Conversely, every unobstructed ray really is populated — and infinitely so. There is a slick way to see this. Choose whole numbers $a,b$ with $pb-qa=1$ (possible exactly because $p/q$ is in lowest terms) and set
$$(m,n) \;=\; (kb+sq,\ ka+sp).$$
As the parameter $s$ runs over the integers, this runs over *all* integer pairs of charge $k$ — and because the substitution has determinant $1$, it carries the arithmetic of $(m,n)$ faithfully onto the arithmetic of the pair $(k,s)$: the two coordinates $m,n$ share no factor exactly when $k$ and $s$ share no factor. The forbidding condition "$m$ and $n$ coprime, of opposite parity" turns into a transparent condition on $s$. Choose $s$ large, coprime to $k$, in the right parity class, and you have your node.

---

## How thick is a ray? Ask Euler

A ray is infinite. But it is not uniformly dense along its length, and the pattern of gaps is a beautiful piece of classical number theory.

Fix a fan at an odd/odd rational — the fan at $1/3$, say — and fix an odd charge $k$. Walk along the ray by increasing the parameter $s$. Which values of $s$ give genuine seeds? By the dictionary above: exactly those coprime to $|k|$. And how many integers in a stretch of consecutive integers are coprime to a fixed number $K$? That is precisely the question Euler's totient function $\varphi$ answers. In any window of $2K$ consecutive integers there are exactly $2\varphi(K)$ coprime to $K$. Hence:

> **Totient density law.** On the ray of odd charge $k$, every window of $2|k|$ consecutive parameters contains exactly $2\varphi(|k|)$ nodes. The ray has arithmetic density $\varphi(|k|)/|k|$.

Concretely: the innermost ray, charge $1$, is completely full — density $1$. The ray of charge $3$ has density $2/3$. The ray of charge $5$: $4/5$. The ray of charge $15$: $8/15$, barely half. And this is *visible*. In a high-resolution rendering, rays of prime charge look like solid lines of light, while rays of highly composite charge look perceptibly dotted. The multiplicative structure of the ray's *label* has become an optical property of the ray.

There is a refinement, too. Splitting the window by the parity of the parameter gives $\varphi(2K)$ nodes in one class and $2\varphi(K)-\varphi(2K)$ in the other — which, for odd $K$, is $\varphi(K)$ in each. The two halves of a ray are exactly equally populated.

---

## Why the charge is really about approximation

Rewrite the ray identity one more way:
$$\frac{n}{m} - \frac{p}{q} \;=\; -\frac{\chi}{qm}.$$
The charge is the numerator of the error in approximating the slope $n/m$ by the fraction $p/q$. Small charge means good approximation, in exactly the scale-invariant sense that number theorists care about. The rays of the fan at $p/q$ are the *levels of approximation quality*:
$$\Big|\frac{n}{m}-\frac{p}{q}\Big| \le \frac{K}{qm} \quad\Longleftrightarrow\quad |\chi| \le K.$$

The innermost ray, $|\chi| = 1$, is therefore the set of nodes whose slope is a **Farey neighbour** of $p/q$ — the unimodular partners, the fractions from which $p/q$ is separated by exactly $1/(qm)$ and by nothing simpler. Farey's classical theorem then says something strong: if $p/q$ and $n/m$ are Farey neighbours, no fraction of denominator smaller than $q+m$ can be squeezed strictly between them, and the mediant $(p+n)/(q+m)$ shows the bound cannot be improved.

So the innermost spoke of every fan is a chain of best approximations to the fan's centre. And — this is the fact that puts the whole star system beyond suspicion of being a decorative coincidence — **every node of the tree lies on the innermost spoke of two different fans**, one on each side, both of denominator smaller than the node's own $m$. There are no leftover points. The star map is not a few bright fans over a generic haze; it is fans all the way down, and every triangle in the picture is an innermost, best-approximating node of two of them.

---

## Why you see only a handful of fans

If every rational carries a fan, and rationals are dense, why isn't the picture a uniform smear?

Because of resolution. Two adjacent rays of the fan at $p/q$ — charges $k$ and $k+1$ — are separated, at plot height $y$, by exactly
$$\frac{y}{q}.$$
The gap depends on nothing but the denominator. A fan at a fraction with $q=2$ has rays a quarter of the frame apart at mid-height; a fan at a fraction with $q=100$ has rays five thousandths of the frame apart and dissolves into a blur.

So at a given plotting resolution $\varepsilon$, the fans you can actually resolve are exactly those with
$$q \;\le\; \frac{y}{\varepsilon},$$
and the visible star centres are precisely the **Farey fractions** of level $Q = \lfloor y/\varepsilon\rfloor$ — all fractions in lowest terms with denominator at most $Q$. There are $\varphi(1)+\varphi(2)+\cdots+\varphi(Q)$ of them between $0$ and $1$.

Put in numbers: at mid-height with a resolution of one part in ten, $Q=5$ and there are exactly ten resolvable centres in $(0,1]$:
$$\tfrac11,\ \tfrac12,\ \tfrac13,\ \tfrac23,\ \tfrac14,\ \tfrac34,\ \tfrac15,\ \tfrac25,\ \tfrac35,\ \tfrac45,$$
plus the centre at $0$ itself. That is exactly the list of fans the eye picks out — $0$, $1$, $0.5$, $0.333$, $0.2$ and their companions. Sharpen the resolution tenfold and $Q$ jumps to $50$, and the number of visible fans jumps to $774$. The count grows like $Q^2$ (with the classical constant $3/\pi^2 \approx 0.304$), so **doubling your resolution roughly quadruples the number of stars you can see.** The star map has no finest scale; it is a Farey structure, revealing more of itself the closer you look.

---

## The tree moves the stars

One more layer. The Pythagorean triples are not merely a set; they form a *tree*. Berggren showed in 1934 that three fixed integer transformations, applied over and over starting from $(3,4,5)$, generate every primitive triple exactly once — no repeats, no omissions. In the seed coordinates the three moves are wonderfully simple:
$$B_1(m,n)=(2m-n,\,m), \qquad B_2(m,n)=(2m+n,\,m), \qquad B_3(m,n)=(m+2n,\,n).$$

What do these do to the fans? They *transport* them. Each move comes with a linear transformation on the star parameter $(p,q)$:
$$T_1(p,q) = (2p-q,\,p),\qquad T_2(p,q)=(2p-q,\,-p),\qquad T_3(p,q)=(p,\,q-2p),$$
and the charge is exactly conserved:
$$\chi_{p/q}\big(B_i(m,n)\big) \;=\; \chi_{T_i(p,q)}(m,n).$$
Moving a node by a tree step is the same as moving the fan by the corresponding linear step. The fans are not independent objects sitting at unrelated rationals; the tree action shuffles them among each other, which is the deep reason no rational boundary point is special.

Two consequences.

**A permanent asymmetry.** Every one of the three transports preserves the parity of $p+q$ — check: $(2p-q)+p = 3p-q$, $(2p-q)-p = p-q$, $p+(q-2p) = q-p$, all of the same parity as $p+q$. So the full fans and the half fans lie in *different* classes, and no sequence of tree moves, however long, can ever carry the fan at $0$ onto the fan at $1$. Their visual difference is not an artefact of where we chose to root the tree. It is permanent.

**Infinitely many fans are one fan.** Take the "ladder" of fractions $1/2,\ 2/3,\ 3/4,\ 4/5,\ldots$, marching towards $1$. One application of $T_1$ walks the ladder down a rung — $T_1(k+1,k+2) = (k,k+1)$ — so the word $B_1^{\,k}$ carries the fan at $k/(k+1)$ exactly onto the fan at $0$. All the fans on that ladder are copies of the same fan, seen from different depths of the tree. Each of them is a full fan (since $k+(k+1)$ is odd), and none of them is ever a copy of the fan at $1$.

---

## The single ray

One last feature of the picture deserves mention, because it is the only one that is not a fan. Among the three moves, $B_1$ and $B_3$ are *parabolic* on the boundary: they slide the slope towards the rational tips $1$ and $0$ ever more slowly, so their orbits are exactly the rays we have been discussing, gliding tangentially into the horizon with steps that shrink to nothing.

The middle move $B_2$ is different. On slopes it acts as $t\mapsto 1/(2+t)$, whose fixed point is $\sqrt2-1$ — an irrational number, so not a star centre at all. Iterating $B_2$ from the root gives the seeds
$$(2,1),\ (5,2),\ (12,5),\ (29,12),\ (70,29),\ (169,70),\ \ldots$$
whose entries are consecutive Pell numbers. This orbit is a genuine hyperbolic geodesic, traversed at a constant pace: the step lengths converge to
$$\log(1+\sqrt2) \;=\; 0.881373\ldots,$$
the logarithm of the *silver ratio*, the quiet cousin of the golden ratio that governs $\sqrt2$ the way the golden ratio governs $\sqrt5$. Measured numerically, the successive steps along this spine are $0.9624$, $0.8838$, $0.8838$, $0.8814$, $0.8814$, $0.8814$ — converging fast.

So the picture contains exactly two dynamical regimes: infinitely many families of rays whose steps die away as they slide into rational tips, and one lone geodesic marching off at constant speed toward an irrational one.

---

## What the star map is telling us

Step back and the whole picture resolves into a single sentence: *the angular structure of the Pythagorean triples, seen hyperbolically, is the Farey structure of the rationals.*

The radial coordinate is the logarithm of the hypotenuse. The angular coordinate is organised by a family of fans, one per rational boundary point, each fan a discrete ladder of hypercycles indexed by an integer charge. Whether a fan is full or half empty is decided by a single parity bit. How thickly a given ray is populated is decided by Euler's totient function applied to the charge. Which fans you can see is decided by the Farey level of your resolution. And the tree itself acts on the collection of fans by integer linear maps, shuffling them while preserving both the charges and the parity bit.

There is something satisfying in how completely arithmetic the answers are. Almost every quantity here is *exact*: the distance to the centre, the distance to the axis of a fan, the ray spacing, the node count in a window. The reason is that the embedding hides nothing — the imaginary part is $1/m$ and the real part is $n/m$, so the seed is visible in the coordinates, and every hyperbolic invariant is a rational function of the two integers with a single $\operatorname{arsinh}$ or $\operatorname{arcosh}$ wrapped around it, which monotonicity strips away.

And that, in the end, is the pleasure of the object. A schoolroom fact — the integer right triangles — placed in the geometry of Bolyai and Lobachevsky, produces a picture whose every line, gap, and brightness is a piece of elementary number theory made visible: parity, coprimality, totients, and Farey fractions, drawn in light on the hyperbolic plane.
