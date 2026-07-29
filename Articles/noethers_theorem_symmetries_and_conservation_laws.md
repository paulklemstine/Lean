# The Geometry of What Cannot Change

## How symmetry writes the conservation laws of nature

A planet can race around its star for millions of years without losing the rule that guides its motion. A puck can glide across ideal ice without choosing a privileged place to stop. A spinning satellite can turn in empty space while preserving an invisible arrow called angular momentum. These facts look like separate chapters of physics: energy, momentum, rotation, gravitation. Noether’s theorem reveals that they are sentences in one language.

The language is symmetry. If an experiment can be shifted in time without changing its governing action, energy is conserved. If it can be shifted in space, momentum is conserved. If it can be rotated, angular momentum is conserved. The connection is not merely poetic. It follows from a compact differential cancellation, and that cancellation also illuminates the hidden geometry of planetary orbits.

This article develops that thread from first principles. The setting is a finite-dimensional real space with an inner product, written $x\cdot y$. A trajectory is a position $q(t)$ with velocity $v(t)=q'(t)$. Its generalized momentum is $p(t)$, and the Euler–Lagrange force is $F(t)=p'(t)$. These equations are deliberately broad: they include ordinary particles, coupled coordinates, and many reduced mechanical systems.

## The charge hidden inside a symmetry

An infinitesimal symmetry tells us how to nudge a trajectory. Let $\xi(t)$ be the symmetry generator: at time $t$, the virtual displacement is $\xi(t)$. A symmetry may change the Lagrangian by a total time derivative without changing the equations of motion. That harmless endpoint contribution is represented by a scalar boundary term $B(t)$.

Along a physical trajectory, infinitesimal invariance becomes the identity

$$
F(t)\cdot \xi(t)+p(t)\cdot \xi'(t)=B'(t).
$$

The associated Noether charge is defined by

$$
J(t)=p(t)\cdot \xi(t)-B(t).
$$

Now differentiate. Since $p'(t)=F(t)$, the product rule gives

$$
J'(t)=F(t)\cdot \xi(t)+p(t)\cdot \xi'(t)-B'(t)=0.
$$

A differentiable function with zero derivative is constant. We therefore obtain the central result.

**Noether’s First Theorem.** Suppose $q'(t)=v(t)$ and $p'(t)=F(t)$, and suppose a differentiable generator $\xi(t)$ with differentiable boundary term $B(t)$ satisfies

$$
F(t)\cdot \xi(t)+p(t)\cdot \xi'(t)=B'(t)
$$

for every time $t$. Then the charge $J(t)=p(t)\cdot\xi(t)-B(t)$ is conserved: for any two times $s$ and $t$,

$$
J(s)=J(t).
$$

The proof is the one-line cancellation above. Its power comes from what can be substituted for $\xi$ and $B$.

## Time, space, and rotation

For an autonomous mechanical system, shifting the clock does not change the action. The infinitesimal displacement caused by a time shift is the velocity, so $\xi(t)=v(t)$, and the boundary term is the Lagrangian value $L(t)$. The Noether charge becomes

$$
E(t)=p(t)\cdot v(t)-L(t).
$$

**Energy Conservation from Time Translation.** If time translation satisfies the infinitesimal invariance identity with generator $v$ and boundary term $L$, then $E(s)=E(t)$ for all $s$ and $t$.

This formula includes the familiar kinetic-plus-potential energy. For a standard Lagrangian $L=T-U$ with momentum paired with velocity so that $p\cdot v=2T$, it yields $E=T+U$.

Space translation is even more direct. Choose a fixed direction $a$. A translation has constant generator $\xi(t)=a$, hence $\xi'(t)=0$, and it needs no boundary term. Invariance in direction $a$ says $F(t)\cdot a=0$. The charge is the corresponding component of momentum.

**Directional Momentum Conservation.** If $p'(t)=F(t)$ and $F(t)\cdot a=0$ for every $t$, then

$$
p(s)\cdot a=p(t)\cdot a
$$

for every pair of times. If this holds for every direction $a$, the entire momentum vector is constant.

Rotations bring in three-dimensional geometry. For vectors in $\mathbb{R}^3$, write $x\times y$ for the cross product. Rotation about a fixed axis $a$ has infinitesimal generator $a\times q(t)$. Its scalar charge is

$$
p(t)\cdot\bigl(a\times q(t)\bigr),
$$

which, by the scalar triple-product identity, is the component along $a$ of the angular momentum

$$
\mathbf{L}(t)=q(t)\times p(t).
$$

**Rotational Charge Theorem.** If the derivative of $p(t)\cdot(a\times q(t))$ vanishes for every $t$, then this rotational charge has the same value at all times.

The physically important central-force case makes the cancellation visible. Suppose canonical momentum equals velocity, $p(t)=v(t)$, and the force always points along the radius, so $F(t)=c(t)q(t)$ for some scalar $c(t)$. The cross-product rule gives

$$
\mathbf{L}'(t)=v(t)\times p(t)+q(t)\times F(t).
$$

Both terms vanish: a vector crossed with itself is zero, and $q\times(cq)=0$. Thus follows the next result.

**Central-Force Angular Momentum Theorem.** Under the derivative rule above, if $p=v$ and $F(t)$ is parallel to $q(t)$ at every time, then $q(t)\times p(t)$ is constant.

This conserved vector fixes the orbital plane. A three-dimensional central-force problem immediately collapses to two-dimensional motion in the plane perpendicular to $\mathbf{L}$.

## Kepler’s orbit and a hidden arrow

Now specialize to the inverse-square attraction of the Kepler problem. Take unit mass and gravitational parameter $\mu$. For position $q(t)\in\mathbb{R}^3$, define the radius

$$
r(t)=\lVert q(t)\rVert=\sqrt{q(t)\cdot q(t)}.
$$

The acceleration is

$$
v'(t)=-\frac{\mu}{r(t)^3}q(t).
$$

The Kepler energy is

$$
E_K(t)=\frac12 v(t)\cdot v(t)-\frac{\mu}{r(t)}.
$$

Its derivative separates into two terms:

$$
E_K'(t)=v(t)\cdot\left(-\frac{\mu}{r(t)^3}q(t)\right)
+\frac{\mu}{r(t)^3}q(t)\cdot v(t).
$$

The dot product is symmetric, so the terms cancel exactly.

**Kepler Energy Theorem.** Whenever the displayed derivative identity holds along a Kepler trajectory away from collision, $E_K(s)=E_K(t)$ for every $s$ and $t$.

Kepler motion has more structure than central-force conservation alone predicts. Define the Runge–Lenz vector

$$
\mathbf{A}(t)=v(t)\times\bigl(q(t)\times v(t)\bigr)-\frac{\mu}{r(t)}q(t).
$$

For the inverse-square equation, differentiating this expression and applying the product rules for cross products and the inverse radius makes every term cancel. Equivalently, once the differential identity $\mathbf{A}'(t)=0$ has been established, constancy follows immediately.

**Runge–Lenz Conservation Theorem.** If a differentiable Kepler state satisfies $\mathbf{A}'(t)=0$ for every $t$, then $\mathbf{A}(s)=\mathbf{A}(t)$ for every pair of times.

Unlike angular momentum, which points perpendicular to the orbital plane, $\mathbf{A}$ lies in that plane and points toward periapsis, the point of closest approach. Its magnitude encodes eccentricity. It is a hidden arrow: not obvious from spatial rotation alone, yet rigid throughout the orbit.

## From conservation to conic sections

The final bridge is purely algebraic. At a single state, let $r=\lVert q\rVert>0$ and set

$$
\mathbf{A}=v\times(q\times v)-\frac{\mu}{r}q,
\qquad
\mathbf{L}=q\times v.
$$

Taking the dot product of $\mathbf{A}$ with $q$ gives

$$
\mathbf{A}\cdot q=\lVert\mathbf{L}\rVert^2-\mu r.
$$

**Conic-Bridge Identity.** If $q\cdot q=r^2$, then the preceding identity holds.

To see why, use the cyclic scalar triple-product relation:

$$
\bigl(v\times(q\times v)\bigr)\cdot q
=(q\times v)\cdot(q\times v)=\lVert\mathbf{L}\rVert^2.
$$

The remaining term is $-(\mu/r)(q\cdot q)=-\mu r$.

Because $\mathbf{A}$ and $\mathbf{L}$ are constant, choose polar angle $\theta$ in the orbital plane measured from $\mathbf{A}$. Then $\mathbf{A}\cdot q=\lVert\mathbf{A}\rVert r\cos\theta$. Writing $\ell=\lVert\mathbf{L}\rVert^2/\mu$ and $e=\lVert\mathbf{A}\rVert/\mu$, the identity rearranges to

$$
r=\frac{\ell}{1+e\cos\theta}.
$$

That is the polar equation of a conic with focus at the origin. Values $0\le e<1$, $e=1$, and $e>1$ correspond respectively to ellipses, parabolas, and hyperbolas. The conservation law does not merely say that the orbit repeats a number; it determines the orbit’s shape and orientation.

## Why the idea travels so far

The same architecture appears wherever a variational principle meets symmetry. A symmetry supplies a generator. The action changes, at most, by an endpoint term. The Euler–Lagrange equation converts the variation into a total derivative. A charge emerges whose derivative is zero.

In engineering, conservation laws provide diagnostics for numerical integrators: if a simulated isolated orbit steadily gains energy, the computation is drifting away from the modeled dynamics. In astronomy, angular momentum reduces orbital motion to a plane, while the Runge–Lenz vector identifies periapsis and eccentricity. In modern physics, continuous internal symmetries lead to conserved charges that need not resemble ordinary motion through space at all.

Noether’s theorem is therefore less a single conservation law than a conservation-law factory. Time homogeneity prints energy; spatial homogeneity prints momentum; isotropy prints angular momentum. In the Kepler problem, additional structure prints the hidden vector that draws a conic in the sky. Symmetry tells us not only what a system may do, but what, through every possible motion, it is forbidden to forget.
