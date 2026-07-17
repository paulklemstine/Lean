# An Integer Line Curved into the Poincaré Disk

## A rigorous first step toward hyperbolic arithmetic

The integers usually arrive as points on an endless straight road:

$$
\ldots,-3,-2,-1,0,1,2,3,\ldots
$$

Hyperbolic geometry invites a different picture. In the Poincaré disk, the whole infinite hyperbolic plane is compressed into the interior of an ordinary Euclidean circle. The boundary circle is not part of the plane; it represents infinity. A traveler can move forever while remaining, in the Euclidean picture, inside the disk and drawing ever closer to its rim.

Can an integer line be placed inside this curved world without losing its arithmetic identity? A particularly clean answer comes from the modular group, one of the central symmetry groups connecting geometry and number theory. The construction below bends a copy of the integers into the disk, gives an exact formula for every point, and reveals how counting, symmetry, and escape to infinity look after the bending.

This is not yet a theory of “hyperbolic primes.” It is something more foundational: an exact model showing which parts of ordinary integer structure survive a geometric transport, and which further claims require genuinely new definitions.

## From the upper half-plane to the disk

Begin with the upper half-plane

$$
\mathbb H=\{z\in\mathbb C:\operatorname{Im}z>0\}.
$$

The modular transformation $z\mapsto z+n$, for $n\in\mathbb Z$, slides points horizontally. Starting from $i$, its translation orbit is the row of points $n+i$. The Cayley transform

$$
C(z)=\frac{z-i}{z+i}
$$

maps the upper half-plane onto the open unit disk

$$
\mathbb D=\{w\in\mathbb C:|w|<1\}.
$$

Applying $C$ to $n+i$ produces the modular orbit point

$$
p_n=C(n+i)=\frac{n}{n+2i}.
$$

This single formula is the heart of the story. It turns a geometric construction into elementary arithmetic: every coordinate, distance comparison, and finite count can be read from the index $n$. Multiplying by the complex conjugate of the denominator gives

$$
p_n=\frac{n^2}{n^2+4}-i\frac{2n}{n^2+4}.
$$

Thus positive indices lie below the real axis, negative indices lie above it, and $p_0=0$. The points trace two reflected arms that leave the center and crowd toward the boundary point $1$.

## An exact radial law

The squared Euclidean radius is especially simple:

$$
|p_n|^2=\frac{n^2}{n^2+4}.
$$

This identity immediately proves that every point lies strictly inside the disk, because $n^2<n^2+4$. It also quantifies the remaining gap to the ideal boundary:

$$
1-|p_n|^2=\frac{4}{n^2+4}.
$$

The deficit decays quadratically in $|n|$. For example,

$$
|p_0|^2=0,\qquad |p_1|^2=\frac15,\qquad
|p_2|^2=\frac12,\qquad |p_3|^2=\frac9{13}.
$$

As $n$ tends through the positive integers to infinity, both $|p_n|^2$ and $|p_n|$ tend to $1$. In the disk picture, the orbit approaches the rim. Hyperbolically, however, the rim remains infinitely far away. The visual accumulation is therefore not a failure of discreteness; it is the signature of a cusp extending to infinity.

There is a precise theorem behind this picture.

**Radial Escape Theorem.** For $p_n=n/(n+2i)$, every $p_n$ belongs to $\mathbb D$, and

$$
\lim_{n\to\infty}|p_n|^2=\lim_{n\to\infty}|p_n|=1.
$$

Moreover, the exact squared-radius defect is $4/(n^2+4)$.

The proof needs only the displayed radius formula. The denominator always exceeds the numerator, and division by $n^2$ shows that $n^2/(n^2+4)$ tends to $1$.

## The orbit does not forget the integers

Curving the integer line would be of little use if different integers collapsed onto the same point. They do not.

**Faithfulness Theorem.** If $p_m=p_n$, then $m=n$.

Indeed,

$$
\frac{m}{m+2i}=\frac{n}{n+2i}
$$

implies, after cross-multiplication,

$$
m(n+2i)=n(m+2i).
$$

The real products cancel, leaving $2mi=2ni$, and hence $m=n$. The map $n\mapsto p_n$ is injective. Consequently, the disk contains infinitely many distinct points of this modular orbit, even though all of them fit inside a bounded Euclidean circle.

Reflection is equally exact:

$$
p_{-n}=\overline{p_n}.
$$

Thus changing the sign of an integer becomes reflection across the real axis. The familiar symmetry of the integer line survives as a geometric mirror symmetry.

## Radius recovers absolute value

The radius does not remember the sign—reflected points are equally far from the origin—but it remembers absolute size perfectly.

**Radial Order Theorem.** For any integers $m$ and $n$,

$$
|p_m|^2\le |p_n|^2
\quad\Longleftrightarrow\quad
m^2\le n^2.
$$

To see why, substitute the exact radial law. Cross-multiplication by the positive denominators reduces the comparison to

$$
m^2(n^2+4)\le n^2(m^2+4),
$$

and the common term $m^2n^2$ cancels. What remains is precisely $m^2\le n^2$.

This result says that Euclidean radial depth in the disk is a perfect encoding of ordinary absolute value on the orbit. The disk has curved the line, but it has not scrambled its magnitude order.

## Exact counting inside radial cutoffs

Choose a nonnegative integer $N$ and draw the closed Euclidean disk centered at the origin whose boundary passes through $p_N$. Which orbit points does it contain? The radial order theorem answers exactly:

$$
|p_n|^2\le |p_N|^2
\quad\Longleftrightarrow\quad
|n|\le N.
$$

Therefore the points inside are precisely

$$
p_{-N},p_{-(N-1)},\ldots,p_{-1},p_0,p_1,\ldots,p_{N-1},p_N.
$$

Injectivity guarantees that none are repeated, so their number is

$$
2N+1.
$$

**Exact Orbit-Counting Theorem.** The closed radial cutoff determined by $p_N$ contains exactly $2N+1$ distinct modular orbit points.

This elementary law is a useful benchmark. It converts a geometric counting problem into a transparent lattice count. It also warns us to specify the metric and the population being counted. These are orbit points, not tessellation vertices, primes, or closed geodesics; the cutoff is Euclidean radius in the disk picture, not hyperbolic distance.

## The hyperbolic distance hidden in the formula

The disk model has its own natural distance. From the origin to a point of Euclidean modulus $r$, the hyperbolic distance is

$$
d_{\mathbb D}(0,w)=2\operatorname{artanh}(r)
=\log\frac{1+r}{1-r}.
$$

For the orbit, $r=|n|/\sqrt{n^2+4}$. A standard identity then yields

$$
d_{\mathbb D}(0,p_n)=2\operatorname{arsinh}\left(\frac{|n|}{2}\right).
$$

This formula follows analytically from the established radius law and explains the cusp geometry: for large $|n|$, the distance grows like $2\log |n|$. Euclidean radii crowd near $1$, while hyperbolic distances continue to increase without bound.

It also suggests a different counting question. A hyperbolic ball of radius $R$ contains those indices satisfying

$$
2\operatorname{arsinh}\left(\frac{|n|}{2}\right)\le R,
$$

or equivalently $|n|\le 2\sinh(R/2)$. The count therefore grows exponentially in $R/2$, after taking the integer part. This derived observation belongs specifically to the one-dimensional translation orbit; it should not be confused with prime-geodesic asymptotics for a hyperbolic surface.

## Where arithmetic ends and geometry begins

Because $n\mapsto p_n$ is injective, one may transport ordinary operations to the orbit by declaring

$$
p_m\oplus p_n=p_{m+n},\qquad
p_m\odot p_n=p_{mn}.
$$

These operations make the orbit a ring isomorphic to $\mathbb Z$. Unique factorization then follows, but for a clear reason: the arithmetic has been copied from the ordinary integers through the parametrization. Hyperbolic geometry has supplied a striking representation, not a new factorization theorem.

This distinction matters when speaking about hyperbolic primes. Several natural geometric objects compete for that name: selected orbit points, vertices of a tessellation, primitive closed geodesics, or primitive conjugacy classes of a group. They are not interchangeable. A set of tessellation vertices does not automatically carry addition and multiplication, and an orbit is not automatically a ring.

The established geometric analogue of primes on finite-area hyperbolic surfaces is closer to primitive closed geodesics. Their lengths enter the Selberg zeta function, whose structure reflects both group theory and spectral geometry. Any proposed hyperbolic zeta series must therefore specify exactly what is summed, which norm or length is used, what multiplicities occur, and where the series converges before questions about functional equations or zeros become meaningful.

## A disciplined road toward curved number theory

The modular orbit provides a sturdy first platform. Its achievements are exact and complete:

* every integer maps to a point strictly inside the Poincaré disk;
* distinct integers map to distinct points;
* negation becomes complex conjugation;
* squared radius is exactly $n^2/(n^2+4)$;
* radial order is exactly order by $|n|$;
* the first $2N+1$ indices are exactly the points inside the cutoff through $p_N$;
* the orbit approaches the ideal boundary while remaining infinite and discrete in hyperbolic geometry.

From here, the next serious steps are clear. One can develop the full fractional-linear action of determinant-one matrices, prove metric preservation, encode primitive hyperbolic conjugacy classes, and define zeta functions from canonical length data. Numerical searches for zeros would then require certified complex bounds and argument-principle counts, not merely floating-point plots.

The larger dream—number theory on curved spaces—remains compelling. Discrete symmetries of curved surfaces already influence dynamics, spectral theory, and mathematical physics; an arithmetic language for them could reveal common structures behind apparently different counting problems. Yet precision matters most at the point where metaphor becomes definition.

The orbit also offers a lesson about mathematical modeling. A picture may suggest primes clustering at a boundary, but the picture alone does not say what multiplication means, whether factorization is intrinsic, or which distance controls growth. Exact identities settle those questions one at a time. Here they show that the observed clustering is cusp geometry, while the count $2N+1$ is inherited from a symmetric interval of indices.

Thus the most persuasive beginnings are not grand analogies. They are exact formulas such as

$$
|p_n|^2=\frac{n^2}{n^2+4},
$$

where arithmetic and geometry meet without ambiguity. Here an infinite integer line folds into a finite-looking disk, sign becomes reflection, magnitude becomes radius, and infinity becomes a boundary that can be approached forever but never reached.