# The Topology of Knotted Light: How Laser Beams Get Tangled

*Aristotle — July 18, 2026*

A beam of light can do more than illuminate a surface. Its brightness can vanish along a twisting thread, its phase can wind around that darkness, and the thread itself can tie into a knot. Such fields are often called **knotted light**. The phrase sounds metaphorical, but the geometry is literal: in a three-dimensional optical field, a line of zero amplitude can close into the shape of a trefoil, a figure-eight knot, or something still more elaborate.

This creates an irresistible question. If a beam contains a knot, can one hear the shape of that knot in the beam’s angular momentum?

The answer explored here begins with a precise mathematical model. It produces a clean success for an infinite family of torus knots, including the trefoil and cinquefoil, and an equally important failure for the figure-eight knot. The distinction is not a numerical accident. It comes from where the roots of the knot’s Alexander polynomial live in the complex plane.

## A dial made of phase

Light is a wave, so it carries phase. Around an ordinary beam the phase may be nearly uniform, but around an optical vortex it winds. A mode with orbital angular momentum index $l$ acquires a phase factor like $e^{il\theta}$ as one travels through azimuthal angle $\theta$. This helical phase structure gives each photon orbital angular momentum proportional to $l$.

To compare angular momentum with knot data, imagine an angular phase dial with $N$ equally spaced positions. Its $l$th point is

$$
z_{N,l}=\exp\!\left(\frac{2\pi i l}{N}\right).
$$

Every point lies on the unit circle, and advancing $l$ simply walks around that circle. Given a polynomial $A(t)$ associated with a knot, the proposed **Alexander phase filter** selects the residue $l$ when

$$
A(z_{N,l})=0.
$$

This is a mathematical selection model, not by itself a derivation from electromagnetic field equations. Its value is that it asks a crisp question: which roots of the Alexander polynomial coincide with physically angular phases?

For the family of two-strand torus knots $T(2,p)$, where $p$ is odd, the relevant Alexander polynomial can be written as the alternating sum

$$
A_p(t)=t^{p-1}-t^{p-2}+\cdots-t+1.
$$

It satisfies the elementary identity

$$
(t+1)A_p(t)=t^p+1.
$$

When $p$ is an odd prime, this polynomial is exactly the cyclotomic polynomial $\Phi_{2p}(t)$. Cyclotomic polynomials are the natural algebraic objects for phase dials: their roots are precisely the primitive roots of unity.

## The coprimality law

A point $z_{N,l}$ is called a **primitive $N$th root of unity** if repeatedly multiplying it by itself returns to $1$ for the first time after exactly $N$ steps. The point $z_{N,1}$ is primitive, while $z_{N,l}=z_{N,1}^l$ may run around a shorter cycle. The elementary primitive-power criterion says that $z_{N,l}$ remains primitive exactly when

$$
\gcd(l,N)=1.
$$

That observation turns the optical root test into arithmetic.

**Prime torus-knot selection theorem.** Let $p$ be an odd prime. On the $2p$-point angular grid, the Alexander polynomial $A_p$ vanishes at $z_{2p,l}$ if and only if $l$ is coprime to $2p$:

$$
A_p(z_{2p,l})=0
\quad\Longleftrightarrow\quad
\gcd(l,2p)=1.
$$

The proof is a short chain of ideas. Because $A_p=\Phi_{2p}$, its zeros are exactly the primitive $2p$th roots of unity. Because $z_{2p,l}$ is the $l$th power of a primitive phase, it is primitive precisely when $l$ and $2p$ are coprime. A polynomial root problem has become a greatest-common-divisor test.

This theorem gives more than a list. It says that the selected channels form the unit group modulo $2p$, the collection of invertible residues. Their number is Euler’s totient $\varphi(2p)=p-1$. The spectral pattern is periodic modulo $2p$, symmetric under complex conjugation through $l\mapsto 2p-l$, and organized by modular arithmetic.

## Trefoil and cinquefoil: the dial lights up

The trefoil is $T(2,3)$. Its Alexander polynomial is

$$
A_3(t)=t^2-t+1=\Phi_6(t).
$$

Among the residues $0,1,2,3,4,5$, only $1$ and $5$ are coprime to $6$. Therefore the trefoil phase filter selects exactly

$$
l\equiv 1,5\pmod 6.
$$

The two phases are $e^{i\pi/3}$ and $e^{5i\pi/3}$, a conjugate pair. Substitution confirms that both make $t^2-t+1$ vanish.

The cinquefoil is $T(2,5)$. Its polynomial is

$$
A_5(t)=t^4-t^3+t^2-t+1=\Phi_{10}(t).
$$

The invertible residues modulo $10$ are $1,3,7,9$, so the selected channels are exactly

$$
l\equiv 1,3,7,9\pmod {10}.
$$

Again the roots arrive in conjugate pairs. Instead of searching numerically across a circle and deciding whether a small residual is “close enough” to zero, one can predict the answer exactly with the Euclidean algorithm.

This arithmetic description scales. For any odd prime $p$, scan a single period from $0$ through $2p-1$ and retain precisely the indices whose greatest common divisor with $2p$ is $1$. The polynomial does not need to be evaluated at all once the theorem is known.

## The figure-eight refuses to play

The figure-eight knot exposes the boundary of the proposal. Its Alexander polynomial, in the normalization used here, is

$$
F(t)=t^2-3t+1.
$$

The quadratic formula gives two reciprocal positive real roots,

$$
r_\pm=\frac{3\pm\sqrt5}{2}.
$$

One lies outside the unit circle and the other inside it. Neither lies on the unit circle. Therefore neither can equal an angular phase $e^{i\theta}$.

This can be shown without relying on decimal approximations.

**Figure-eight exclusion theorem.** For every complex number $z$ satisfying $|z|=1$,

$$
F(z)\ne 0.
$$

Consequently, for every positive grid size $N$ and every integer index $l$,

$$
F(z_{N,l})\ne 0.
$$

For a proof, suppose $F(z)=0$. Since $z\ne0$, divide by $z$ to obtain

$$
z+z^{-1}=3.
$$

On the unit circle, $z^{-1}=\overline z$, so the left side is $2\operatorname{Re}(z)$. But $|\operatorname{Re}(z)|\le1$, making its absolute value at most $2$, never $3$. This contradiction rules out every angular phase at once.

The point matters because it corrects a tempting but invalid move: taking the real roots $(3\pm\sqrt5)/2$, reducing those numbers modulo $1$, and calling the resulting fractions angular channels. Polynomial evaluation does not respect that operation. The equation $F(r)=0$ says nothing about $F(e^{2\pi i(r\bmod 1)})$. A root’s modulus and its argument encode different geometry.

The constant Alexander polynomial of the unknot offers an even simpler warning. Since the constant polynomial $1$ never vanishes, a literal root-selection rule yields no selected phase at all. If an optical convention reserves $l=0$ as a baseline unknot channel, that channel must be added as a separate convention; it does not follow from polynomial vanishing.

## Two kinds of spectral information

The torus-knot and figure-eight examples suggest a more nuanced picture. Roots on the unit circle naturally describe angular phase channels. Roots away from the circle may instead describe growth and decay.

Write a nonzero root as $re^{i\theta}$. Its argument $\theta$ is angular information; its modulus $r$ is radial information. For the prime torus knots considered here, every Alexander root has $r=1$, so the information is entirely angular. For the figure-eight knot, the roots are positive real and reciprocal. Their arguments are both $0$, but their logarithmic moduli are opposite:

$$
\log r_+=-\log r_-.
$$

This resembles a pair of growing and decaying radial modes. It points toward a repaired physical hypothesis: off-circle Alexander roots might govern evanescent or amplified radial behavior rather than orbital angular momentum channels.

A related statistic is the logarithmic Mahler measure, which collects the logarithms of root moduli outside the unit circle. Cyclotomic polynomials have Mahler measure $1$ and logarithmic measure $0$. The figure-eight polynomial has positive logarithmic measure $\log((3+\sqrt5)/2)$. Thus a single polynomial may carry both angular and radial signatures, but one should not confuse them.

## What an experiment would need to show

The mathematics establishes the consequences of an Alexander phase-filter model. It does not establish that a knot-shaped hologram automatically implements that filter. A physical experiment would need a mechanism connecting the transfer function of the optical system to $A(t)$, a clear definition of the measured OAM basis, and controls separating topological effects from ordinary diffraction.

The predictions are nevertheless sharp. For a trefoil design implementing the filter, one should see channels $1$ and $5$ modulo $6$. For a cinquefoil design, one should see $1,3,7,9$ modulo $10$. For a figure-eight design under the same root-of-unity rule, one should see no selected angular channel—not the real roots folded modulo $1$. If radial propagation is also measured, the figure-eight may instead reveal reciprocal exponential rates.

The prime family also gives an inverse clue. The number of selected channels is $p-1$, while the period is $2p$. Within this restricted family, either quantity identifies $p$. A spectral measurement could therefore recover the torus-knot parameter, provided the underlying optical filter truly realizes the polynomial rule.

## A knot, an angle, and an integer

The most striking feature of this story is how many languages meet in one equation. Knot theory supplies the Alexander polynomial. Complex analysis places its roots in the plane. Cyclotomic theory identifies special roots on the unit circle. Modular arithmetic labels the surviving angular channels. Optics provides the physical question that makes the labels meaningful.

For prime two-strand torus knots, these languages lock together perfectly: the allowed phase indices are exactly the integers invertible modulo $2p$. For the figure-eight knot, they separate just as decisively: its roots carry radial magnitude but no nontrivial unit-circle phase.

That contrast is more valuable than a universal slogan. Knotted light may indeed carry algebraic fingerprints of knots, but the fingerprint has components. Angles belong to orbital channels; moduli belong to growth and decay. Reading the knot correctly means knowing which part of the complex root one is actually measuring.
