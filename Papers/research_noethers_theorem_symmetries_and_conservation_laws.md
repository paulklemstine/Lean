# Continuous Symmetries, Conserved Charges, and the Geometry of Kepler Motion

**Aristotle**  
**July 29, 2026**

## Abstract

We present a self-contained finite-dimensional formulation of Noether’s first theorem in classical mechanics and develop its principal mechanical consequences. A trajectory is described by position $q$, velocity $v$, generalized momentum $p$, and force $F$, satisfying $q'=v$ and $p'=F$. An infinitesimal variational symmetry consists of a differentiable generator $\xi$ and a differentiable boundary term $B$ whose on-trajectory first variation obeys $F\cdot\xi+p\cdot\xi'=B'$. The Noether charge $J=p\cdot\xi-B$ then has zero derivative and is constant. Time translation yields energy, spatial translation yields directional linear momentum, and rotation yields components of angular momentum. For central forces, angular momentum conservation follows directly from zero torque. We then specialize to the Kepler inverse-square problem, proving conservation of Kepler energy and stating the differential conservation of the Runge–Lenz vector. A scalar triple-product identity connects the Runge–Lenz invariant to the conic equation of the orbit. The treatment separates universal variational reasoning, elementary differential identities, and three-dimensional geometric algebra, thereby clarifying which assumptions are responsible for each conservation law.

## 1. Introduction

Conservation laws are among the most effective tools in classical mechanics. They reduce differential equations, constrain possible trajectories, expose qualitative behavior, and provide sensitive diagnostics for numerical calculations. Their common origin is symmetry: invariance under a continuous family of transformations produces a quantity that remains constant along physical motion.

The aim of this paper is to isolate that mechanism with minimal hypotheses and then trace it through the standard examples. The central statement requires only a finite-dimensional real inner-product space, differentiable curves, an Euler–Lagrange momentum equation, and an on-trajectory infinitesimal variation identity. This formulation is broad enough to include ordinary Euclidean particles and systems of generalized coordinates, while remaining elementary enough that the proof reduces to the product rule.

After establishing the general theorem, we examine three familiar symmetry types. Time translation associates the velocity generator and Lagrangian boundary term with the energy $p\cdot v-L$. Translation in a fixed spatial direction associates a constant generator with the corresponding component of momentum. Rotation about an axis associates the generator $a\times q$ with the corresponding angular-momentum component.

The Kepler problem supplies a particularly rich application. The inverse-square force conserves energy and angular momentum, but it also conserves the Runge–Lenz vector. This additional vector determines the orientation and eccentricity of the orbit. Its dot product with position yields an algebraic bridge from dynamics to conic geometry.

The conclusions are exact implications. Whenever the specified derivative identities hold on an interval, the corresponding charges are constant there. Collision points, at which the inverse radius is undefined, must be excluded from the Kepler discussion.

## 2. Kinematic and variational framework

### 2.1 State variables

Let $V$ be a finite-dimensional real inner-product space with inner product $x\cdot y$. Let

$$
q,v,p,F:\mathbb{R}\to V
$$

be differentiable curves where required. We interpret $q(t)$ as position, $v(t)$ as velocity, $p(t)$ as generalized momentum, and $F(t)$ as generalized force.

**Definition 2.1 (Euler–Lagrange trajectory).** A quadruple $(q,v,p,F)$ is an Euler–Lagrange trajectory if, at every time $t$,

$$
q'(t)=v(t),\qquad p'(t)=F(t).
$$

The second equation is the first-order momentum form of the Euler–Lagrange equations. For a regular Lagrangian $L(q,v,t)$, one ordinarily has $p=\partial L/\partial v$ and $F=\partial L/\partial q$ along the trajectory. The theorem below needs only the displayed derivative equations, not a particular coordinate formula for $L$.

### 2.2 Infinitesimal symmetries and boundary terms

A one-parameter transformation changes the trajectory infinitesimally in the direction of a generator $\xi(t)\in V$. Strict invariance of the Lagrangian is not necessary. It is enough that the action changes by an endpoint contribution, represented locally by the total derivative of a scalar function $B(t)$.

**Definition 2.2 (On-trajectory variational symmetry).** Given momentum $p$ and force $F$, an infinitesimal variational symmetry is a pair of differentiable functions

$$
\xi:\mathbb{R}\to V,\qquad B:\mathbb{R}\to\mathbb{R},
$$

such that, along the trajectory,

$$
F(t)\cdot\xi(t)+p(t)\cdot\xi'(t)=B'(t)
$$

for every $t$.

This is the on-trajectory first-variation identity. The term $B$ permits quasi-invariance: adding a total derivative to a Lagrangian changes the action only through endpoint data and leaves the Euler–Lagrange equations unchanged.

**Definition 2.3 (Noether charge).** The charge associated with $(\xi,B)$ is

$$
J(t)=p(t)\cdot\xi(t)-B(t).
$$

The negative sign of the boundary term is forced by the first-variation identity.

## 3. Noether’s first theorem

**Theorem 3.1 (Differential Noether identity).** Let $(q,v,p,F)$ be an Euler–Lagrange trajectory and $(\xi,B)$ an on-trajectory variational symmetry. Then

$$
J'(t)=0
$$

at every time $t$.

**Proof sketch.** Differentiate $J=p\cdot\xi-B$ and apply the product rule for the inner product:

$$
J'=p'\cdot\xi+p\cdot\xi'-B'.
$$

Substitute $p'=F$. The result is

$$
J'=F\cdot\xi+p\cdot\xi'-B',
$$

which vanishes by the variational-symmetry identity. $\square$

**Theorem 3.2 (Noether’s First Theorem).** Under the hypotheses of Theorem 3.1, the Noether charge is conserved. For all times $s$ and $t$ in the connected interval of definition,

$$
p(s)\cdot\xi(s)-B(s)=p(t)\cdot\xi(t)-B(t).
$$

**Proof sketch.** The differential identity gives $J'=0$ everywhere. The mean value theorem, or equivalently the standard constant-function criterion, implies that $J$ is constant on the interval. $\square$

The theorem separates dynamics from symmetry. The equation $p'=F$ supplies the dynamical substitution, while $F\cdot\xi+p\cdot\xi'=B'$ supplies the symmetry cancellation. Neither ingredient alone produces the conserved charge.

## 4. Translation symmetries

### 4.1 Time translation and energy

Suppose the system is autonomous, so the action has no preferred origin of time. Under an infinitesimal shift of the time parameter, the trajectory changes in the velocity direction. The corresponding generator is $\xi=v$, and the relevant boundary term is the Lagrangian value along the trajectory, denoted $L(t)$.

**Definition 4.1 (Autonomous energy).** For velocity $v$, momentum $p$, and Lagrangian value $L$, define

$$
E(t)=p(t)\cdot v(t)-L(t).
$$

**Theorem 4.2 (Energy conservation from time translation).** Let $(q,v,p,F)$ be an Euler–Lagrange trajectory. Assume time translation supplies the on-trajectory identity

$$
F(t)\cdot v(t)+p(t)\cdot v'(t)=L'(t)
$$

for every $t$. Then, for all $s$ and $t$,

$$
E(s)=E(t).
$$

**Proof sketch.** Apply Noether’s theorem with $\xi=v$ and $B=L$. The resulting charge $p\cdot v-L$ is precisely $E$. $\square$

For a natural mechanical Lagrangian $L=T-U$ with quadratic kinetic energy, Euler’s identity gives $p\cdot v=2T$, so $E=T+U$. The abstract formula is more general and remains meaningful for nonstandard kinetic terms.

### 4.2 Spatial translation and momentum

Let $a\in V$ be a fixed direction. An infinitesimal spatial translation has constant generator $\xi(t)=a$ and therefore $\xi'(t)=0$. Taking $B=0$, the symmetry identity reduces to $F(t)\cdot a=0$.

**Theorem 4.3 (Directional momentum conservation).** Let $(q,v,p,F)$ be an Euler–Lagrange trajectory, and let $a\in V$. If

$$
F(t)\cdot a=0
$$

for every $t$, then

$$
p(s)\cdot a=p(t)\cdot a
$$

for all $s$ and $t$.

**Proof sketch.** Use the constant generator $\xi=a$ and zero boundary term. The Noether charge is $p\cdot a$, and the symmetry condition is exactly the assumed vanishing of the force component. $\square$

If the hypothesis holds for every $a$, then $F=0$ and all components of $p$ are conserved. More generally, each unbroken translation direction contributes one conserved momentum component.

## 5. Rotations and angular momentum

We now specialize to $V=\mathbb{R}^3$. Let $x\times y$ denote the cross product and define the angular momentum

$$
\mathbf{L}(t)=q(t)\times p(t).
$$

For a fixed axis vector $a$, the infinitesimal generator of rotation about that axis is

$$
\xi(t)=a\times q(t).
$$

The associated scalar charge is

$$
J_a(t)=p(t)\cdot(a\times q(t)).
$$

By cyclic invariance of the scalar triple product,

$$
p\cdot(a\times q)=a\cdot(q\times p)=a\cdot\mathbf{L}.
$$

Thus rotational symmetry about $a$ conserves the component of angular momentum along $a$.

**Theorem 5.1 (Rotational charge conservation).** Fix $a\in\mathbb{R}^3$. If $J_a$ is differentiable and

$$
J_a'(t)=0
$$

for every $t$, then

$$
p(s)\cdot(a\times q(s))=p(t)\cdot(a\times q(t))
$$

for all $s$ and $t$.

**Proof sketch.** This is the zero-derivative criterion applied to $J_a$. In a variational derivation, the hypothesis arises from rotational invariance through Theorem 3.1. $\square$

A complementary torque argument gives vector conservation for central forces.

**Theorem 5.2 (Angular momentum under a central force).** Assume the cross-product derivative rule

$$
\mathbf{L}'(t)=v(t)\times p(t)+q(t)\times F(t).
$$

Suppose also that $p(t)=v(t)$ and that the force is central: for every $t$ there exists a scalar $c(t)$ such that

$$
F(t)=c(t)q(t).
$$

Then angular momentum is conserved:

$$
\mathbf{L}(s)=\mathbf{L}(t)
$$

for all $s$ and $t$.

**Proof sketch.** Substitute $p=v$ and $F=cq$ into the derivative rule. Since $v\times v=0$ and $q\times(cq)=c(q\times q)=0$, one has $\mathbf{L}'=0$. Constancy follows. $\square$

If $\mathbf{L}\ne0$, then $q(t)\cdot\mathbf{L}=0$ for every $t$, so the trajectory remains in the fixed plane perpendicular to $\mathbf{L}$. This planar reduction is one of the immediate geometric benefits of conservation.

## 6. The Kepler inverse-square problem

### 6.1 Equations and energy

Let $q(t)\in\mathbb{R}^3\setminus\{0\}$ and $v(t)=q'(t)$. Define

$$
r(t)=\lVert q(t)\rVert=\sqrt{q(t)\cdot q(t)}.
$$

For unit mass and gravitational parameter $\mu>0$, the Kepler equation is

$$
v'(t)=-\frac{\mu}{r(t)^3}q(t).
$$

The force is parallel to $q$, so Theorem 5.2 conserves $q\times v$. The Kepler energy is

$$
E_K(t)=\frac12 v(t)\cdot v(t)-\frac{\mu}{r(t)}.
$$

**Theorem 6.1 (Kepler energy conservation).** Suppose $E_K$ is differentiable and its derivative is expressed by the chain and product rules as

$$
E_K'(t)=v(t)\cdot\left(-\frac{\mu}{r(t)^3}q(t)\right)
+\frac{\mu}{r(t)^3}q(t)\cdot v(t).
$$

Then $E_K$ is constant: $E_K(s)=E_K(t)$ for all $s$ and $t$.

**Proof sketch.** Symmetry of the dot product gives $v\cdot q=q\cdot v$. The two displayed terms are additive inverses, hence $E_K'=0$. $\square$

The derivative identity itself follows from $v'= -\mu q/r^3$ and

$$
\frac{d}{dt}\left(\frac{1}{r}\right)=-\frac{q\cdot v}{r^3}.
$$

The theorem states the exact algebraic cancellation once these analytic derivative rules are available.

### 6.2 The Runge–Lenz invariant

Define the angular momentum per unit mass by

$$
\mathbf{L}(t)=q(t)\times v(t)
$$

and the Runge–Lenz vector by

$$
\mathbf{A}(t)=v(t)\times\mathbf{L}(t)-\frac{\mu}{r(t)}q(t).
$$

Equivalently,

$$
\mathbf{A}(t)=v(t)\times\bigl(q(t)\times v(t)\bigr)-\frac{\mu}{r(t)}q(t).
$$

**Theorem 6.2 (Runge–Lenz conservation).** Let $q$ and $v$ be differentiable away from collision. If the inverse-square equation and the derivative rules for cross products and inverse radius yield

$$
\mathbf{A}'(t)=0
$$

for every $t$, then

$$
\mathbf{A}(s)=\mathbf{A}(t)
$$

for all $s$ and $t$.

**Proof sketch.** Apply the constant-function criterion componentwise to the vector-valued curve $\mathbf{A}$. For completeness, the differential cancellation can be seen as follows. Since $\mathbf{L}'=0$ under a central force,

$$
\frac{d}{dt}(v\times\mathbf{L})=v'\times\mathbf{L}.
$$

Substitute $v'=-\mu q/r^3$ and expand $q\times(q\times v)=q(q\cdot v)-v r^2$. This gives

$$
v'\times\mathbf{L}
=\mu\left(\frac{v}{r}-\frac{q(q\cdot v)}{r^3}\right).
$$

On the other hand,

$$
\frac{d}{dt}\left(\frac{\mu q}{r}\right)
=\mu\left(\frac{v}{r}-\frac{q(q\cdot v)}{r^3}\right).
$$

The two derivatives cancel in $\mathbf{A}'$. $\square$

The vector $\mathbf{A}$ lies in the orbital plane because both $v\times\mathbf{L}$ and $q$ do. It points toward periapsis for a noncircular orbit. Its magnitude will become the eccentricity after normalization by $\mu$.

## 7. The bridge from invariants to conic geometry

The connection between the Runge–Lenz vector and conic sections rests on a pointwise vector identity.

**Theorem 7.1 (Runge–Lenz conic bridge).** Let $q,v\in\mathbb{R}^3$, let $r\ne0$, and assume

$$
q\cdot q=r^2.
$$

Define

$$
\mathbf{A}=v\times(q\times v)-\frac{\mu}{r}q,
\qquad
\mathbf{L}=q\times v.
$$

Then

$$
\mathbf{A}\cdot q=\mathbf{L}\cdot\mathbf{L}-\mu r.
$$

**Proof sketch.** Expand the left-hand side:

$$
\mathbf{A}\cdot q
=\bigl(v\times(q\times v)\bigr)\cdot q
-\frac{\mu}{r}(q\cdot q).
$$

The cyclic scalar triple-product identity gives

$$
\bigl(v\times(q\times v)\bigr)\cdot q
=(q\times v)\cdot(q\times v)=\mathbf{L}\cdot\mathbf{L}.
$$

The radius assumption changes the second term to $-(\mu/r)r^2=-\mu r$. $\square$

For the physical radius $r=\lVert q\rVert>0$, let $\theta$ be the angle from the fixed vector $\mathbf{A}$ to $q$ in the orbital plane. Then

$$
\mathbf{A}\cdot q=\lVert\mathbf{A}\rVert r\cos\theta.
$$

Substitution into Theorem 7.1 yields

$$
\lVert\mathbf{A}\rVert r\cos\theta
=\lVert\mathbf{L}\rVert^2-\mu r.
$$

Rearranging and introducing

$$
e=\frac{\lVert\mathbf{A}\rVert}{\mu},
\qquad
\ell=\frac{\lVert\mathbf{L}\rVert^2}{\mu},
$$

one obtains

$$
r=\frac{\ell}{1+e\cos\theta}.
$$

This is the focus-centered polar equation of a conic. The dimensionless constant $e$ is its eccentricity: $0\le e<1$ gives an ellipse, $e=1$ a parabola, and $e>1$ a hyperbola. The direction of $\mathbf{A}$ fixes the periapsis direction, while $\mathbf{L}$ fixes the orbital plane and semilatus rectum.

## 8. Computational realization

The invariants suggest a direct numerical pipeline for inspecting an orbit. Given sampled states $(q_i,v_i)$ and a gravitational parameter $\mu$, compute

$$
r_i=\lVert q_i\rVert,
$$

$$
E_i=\frac12\lVert v_i\rVert^2-\frac{\mu}{r_i},
$$

$$
\mathbf{L}_i=q_i\times v_i,
$$

and

$$
\mathbf{A}_i=v_i\times\mathbf{L}_i-\frac{\mu}{r_i}q_i.
$$

For exact Kepler motion, these quantities are independent of $i$. In floating-point simulation they vary slightly; the maximum deviation from the initial value measures numerical drift. This does not prove that an approximate trajectory is exact, but it is a strong structural diagnostic.

A second algorithm reconstructs the predicted conic from one noncollision state. It computes $\ell=\lVert\mathbf{L}\rVert^2/\mu$ and $e=\lVert\mathbf{A}\rVert/\mu$, then evaluates $r(\theta)=\ell/(1+e\cos\theta)$ wherever the denominator is nonzero. The sign of the energy provides a compatible classification when $\mu>0$: negative, zero, and positive energy correspond to elliptic, parabolic, and hyperbolic regimes, respectively.

For numerical integration, a symplectic method is often preferable to a generic explicit method because its long-term invariant behavior better reflects Hamiltonian geometry. Nevertheless, no finite-step method should be expected to preserve all Kepler invariants exactly unless it is specifically designed to do so.

## 9. Applications and interpretation

The abstract theorem has three distinct uses. First, it derives quantities that reduce equations of motion. Conservation of energy converts a second-order scalar problem into a first-order relation; conservation of angular momentum reduces a central-force trajectory to a plane. Second, it classifies motion. In the Kepler problem, the Runge–Lenz vector converts dynamical information into conic parameters. Third, it audits computation: invariant drift reveals integration error, unstable step sizes, or incorrect force implementation.

The boundary term $B$ is conceptually important. A transformation need not leave the Lagrangian pointwise unchanged. It may alter it by a total derivative while preserving the action up to endpoint values. The conserved charge must then include $-B$. Omitting this term would incorrectly discard legitimate quasi-symmetries.

The finite-dimensional inner-product formulation also clarifies the assumptions. The proof of the general theorem uses only differentiability, the momentum equation, bilinearity of the inner product, and the variation identity. Three-dimensional cross products enter only for angular momentum and Kepler geometry. Thus the general Noether mechanism is not tied to three-dimensional space.

## 10. Limitations and future work

The present account starts from the on-trajectory first-variation identity rather than deriving it from invariance of an integral action under a differentiable one-parameter group. A fuller treatment would specify admissible variations, endpoint conditions, and differentiation under the integral sign.

The geometry is finite-dimensional and linear. Configuration manifolds require tangent and cotangent bundles, fiber derivatives of the Lagrangian, and momentum maps. Lie-group actions would unify multiple generators and encode equivariance. In Hamiltonian language, conservation becomes the vanishing Poisson bracket $\{J,H\}=0$.

For the Kepler problem, the analytic product and chain rules can be developed directly from $q'=v$ and $v'=-\mu q/\lVert q\rVert^3$, with collision explicitly excluded. One may then derive the polar conic equation as a theorem about the entire trajectory and combine it with the conserved energy to classify all noncollision orbits. Finally, the Poisson brackets among angular momentum and Runge–Lenz components reveal the hidden symmetry algebra of bound Kepler motion.

## 11. Conclusion

Noether’s theorem follows from a precise cancellation. The momentum equation transforms the derivative of $p\cdot\xi-B$ into the infinitesimal variation of the action, and symmetry sets that variation to zero. Time translation produces energy, spatial translation produces momentum, and rotation produces angular momentum. In the inverse-square problem, energy and angular momentum are joined by the Runge–Lenz vector. The identity

$$
\mathbf{A}\cdot q=\lVert\mathbf{L}\rVert^2-\mu r
$$

then turns conserved vectors into the polar equation of a conic. The resulting chain—from symmetry, to differential cancellation, to invariant, to geometry—captures both the economy and the explanatory force of modern analytical mechanics.
