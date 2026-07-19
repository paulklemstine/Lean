# Natural Gradient as Metric Preconditioning: Exact Rates and the Boundary of Geodesic Interpretation

**Aristotle**  
**July 19, 2026**

## Abstract

Natural gradient descent replaces the Euclidean gradient of a loss by its inverse-metric transform. This construction is frequently described as geodesic motion on the statistical manifold, but that description conflates an intrinsic tangent direction with an exact manifold integrator. We give a self-contained analysis separating these notions. First, for a positive diagonal metric we show that the inverse-metric direction globally minimizes the standard local linear-plus-quadratic model. Second, for a quadratic objective whose Hessian matches a constant metric, we derive exact condition-number-free dynamics: a constant step $\eta$ multiplies the objective by $(1-\eta)^2$ per iteration, and the harmonic schedule $\eta_k=1/(k+2)$ gives the exact parameter law $x_k=x_0/(k+1)$ and objective law $E(x_k)=E(x_0)/(k+1)^2$. A coordinate-free orthogonal-mode identity explains the result through Pythagorean energy decomposition. Third, a one-dimensional variable metric provides an explicit counterexample: a natural-gradient Euler endpoint does not equal the geodesic midpoint. The results identify a rigorous surviving principle—exact curvature matching removes coordinate conditioning in the flat constant-metric model—while showing why global geodesic and universal convergence claims require exponential maps or controlled retractions together with curvature, smoothness, and convexity assumptions.

## 1. Introduction

Optimization depends on how displacement is measured. In Euclidean gradient descent, the vector $-\nabla L(\theta)$ is the direction producing the largest first-order decrease per unit Euclidean length. A statistical model, however, carries a distinguished local geometry. If $p_\theta$ is a smooth family of probability distributions, the Fisher information matrix

$$
G(\theta)=\mathbb{E}_{p_\theta}\!\left[\nabla_\theta\log p_\theta\,\nabla_\theta\log p_\theta^{\mathsf T}\right]
$$

measures local statistical distinguishability. Where $G(\theta)$ is positive definite, it defines a Riemannian metric. The natural gradient is

$$
\operatorname{grad}_G L(\theta)=G(\theta)^{-1}\nabla L(\theta),
$$

and the usual natural-gradient Euler update is

$$
\theta_{k+1}=\theta_k-\eta_kG(\theta_k)^{-1}\nabla L(\theta_k).
$$

The inverse metric acts as a preconditioner: coordinate directions that the metric regards as expensive are suppressed, while directions regarded as cheap are amplified. Because the construction is metric-aware, it is tempting to identify the update itself with a geodesic step. That identification is generally false. The natural gradient is a tangent vector. An Euler update adds that vector in a chosen coordinate chart. A geodesic update instead maps a tangent vector back to the manifold through the Riemannian exponential map,

$$
\theta_{k+1}=\operatorname{Exp}_{\theta_k}\!\left(-\eta_k\operatorname{grad}_G L(\theta_k)\right).
$$

The two agree in flat affine coordinates for a constant metric, but need not agree when the metric varies.

This paper develops an exact model that exposes both the power and the limitation of natural gradient. The positive result is stronger than an asymptotic estimate: in a matched constant-metric quadratic, every iterate and every energy value can be written in closed form, independently of the metric condition number. The negative result is likewise exact: in a one-dimensional curved coordinate, the Euler endpoint fails a simple algebraic test for being the geodesic midpoint.

The paper makes five claims, each with an elementary proof:

1. The inverse-metric direction minimizes a local linear-plus-metric-quadratic model.
2. A matched natural-gradient step contracts quadratic energy by exactly $(1-\eta)^2$.
3. Constant steps yield geometric convergence whenever $0<\eta<1$.
4. Harmonic steps yield exact $1/(k+1)$ parameter decay and $1/(k+1)^2$ energy decay.
5. Natural-gradient Euler motion is not, in general, exact geodesic motion.

These statements do not establish a universal rate for arbitrary objectives or arbitrary Fisher manifolds. Rather, they locate precisely where condition-number cancellation occurs and identify the geometric ingredients missing from an unrestricted claim.

## 2. Geometric and optimization preliminaries

### 2.1 Riemannian steepest descent

Let $M$ be a smooth parameter manifold. At a point $\theta\in M$, a positive-definite bilinear form $G(\theta)$ assigns squared norm

$$
\|v\|_{G(\theta)}^2=v^{\mathsf T}G(\theta)v
$$

to a tangent vector $v$. The differential of a smooth loss $L$ acts as

$$
dL_\theta(v)=\nabla L(\theta)^{\mathsf T}v
$$

in local coordinates. The Riemannian gradient is the unique tangent vector satisfying

$$
\langle \operatorname{grad}_G L(\theta),v\rangle_{G(\theta)}=dL_\theta(v)
$$

for every $v$. In coordinates this identity gives

$$
\operatorname{grad}_G L(\theta)=G(\theta)^{-1}\nabla L(\theta).
$$

Thus the natural gradient is steepest descent relative to Fisher length, not Euclidean length.

### 2.2 Geodesics and update maps

A geodesic is a curve $\gamma$ whose covariant acceleration vanishes. In coordinates it solves

$$
\ddot\gamma^k+
\sum_{i,j}\Gamma^k_{ij}(\gamma)\dot\gamma^i\dot\gamma^j=0,
$$

where the Christoffel symbols $\Gamma^k_{ij}$ depend on first derivatives of the metric. Given $v\in T_\theta M$, the exponential map $\operatorname{Exp}_\theta(v)$ is the point reached at unit time by the geodesic starting at $\theta$ with velocity $v$.

By contrast, coordinate Euler addition sends $(\theta,v)$ to $\theta+v$. It sees the metric only through the chosen tangent vector; it does not include the Christoffel correction that bends a geodesic. A retraction $R_\theta(v)$ is an intermediate construction satisfying $R_\theta(0)=\theta$ and having identity differential at zero. Retractions approximate the exponential map to a specified local order, but generic coordinate addition need not be exact.

### 2.3 Condition number

For a positive diagonal matrix $G=\operatorname{diag}(w_1,\ldots,w_n)$, define

$$
\kappa(G)=\frac{\max_i w_i}{\min_i w_i}.
$$

Euclidean first-order methods on the quadratic with Hessian $G$ generally have rates governed by the spread of eigenvalues. A result is condition-number-free in the present setting if its contraction factor does not involve $\kappa(G)$ or any individual $w_i$.

## 3. The local metric model

Fix positive weights $w_i>0$, a gradient vector $g\in\mathbb{R}^n$, and a step parameter $\eta>0$. Let $G=\operatorname{diag}(w_1,\ldots,w_n)$. Define the local model

$$
Q_{g,G,\eta}(v)
=g^{\mathsf T}v+\frac{1}{2\eta}v^{\mathsf T}Gv
=\sum_{i=1}^n\left(g_iv_i+\frac{w_iv_i^2}{2\eta}\right).
$$

The linear term is the first-order predicted change in the objective. The quadratic term penalizes intrinsic step length. The factor $1/\eta$ controls the tradeoff.

### Theorem 1 (Local metric-model minimization)

For $w_i>0$ and $\eta>0$, the unique global minimizer of $Q_{g,G,\eta}$ is

$$
v^*=-\eta G^{-1}g,
$$

or componentwise,

$$
v_i^*=-\eta\frac{g_i}{w_i}.
$$

#### Proof sketch

Complete the square independently in every coordinate:

$$
g_iv_i+\frac{w_iv_i^2}{2\eta}
=rac{w_i}{2\eta}
\left(v_i+\eta\frac{g_i}{w_i}\right)^2
-rac{\eta g_i^2}{2w_i}.
$$

Because $w_i/(2\eta)>0$, the squared term is nonnegative and vanishes exactly when $v_i=-\eta g_i/w_i$. Summing the identities proves global minimality and uniqueness. Equivalently, differentiating gives $g+Gv/\eta=0$, while the Hessian $G/\eta$ is positive definite.

### Interpretation

The theorem establishes the precise sense in which natural gradient is steepest descent. It is not merely a heuristic normalization. It solves a well-defined optimization problem in the tangent space. Nevertheless, the theorem is entirely local: $G$ is evaluated at the current point and the model contains no derivatives of $G$. Consequently it cannot, by itself, imply that the finite endpoint of coordinate addition lies on a geodesic.

## 4. Matched quadratic energy

Let $w=(w_1,\ldots,w_n)$ have positive entries and define

$$
E_w(x)=\frac12\sum_{i=1}^n w_ix_i^2
=\frac12x^{\mathsf T}Gx.
$$

The unique minimizer is $x^*=0$. Its Euclidean gradient and Hessian are

$$
\nabla E_w(x)=Gx,
\qquad
\nabla^2E_w(x)=G.
$$

The metric is said to be matched because it equals the objective Hessian. Applying the inverse metric gives

$$
G^{-1}\nabla E_w(x)=x.
$$

Hence the natural-gradient Euler map with step $\eta$ is

$$
T_\eta(x)=x-\eta x=(1-\eta)x.
$$

The metric weights cancel before iteration begins.

### Theorem 2 (Exact one-step energy contraction)

For every $x\in\mathbb{R}^n$ and every real $\eta$,

$$
E_w(T_\eta(x))=(1-\eta)^2E_w(x).
$$

#### Proof sketch

Substitute $T_\eta(x)_i=(1-\eta)x_i$ into the definition:

$$
E_w(T_\eta(x))
=\frac12\sum_iw_i(1-\eta)^2x_i^2
=(1-\eta)^2E_w(x).
$$

No bound or approximation is involved.

### Consequences

The contraction factor is independent of the dimension, the largest and smallest metric weights, and their ratio. If $\eta=1$, one step reaches the minimizer exactly. If $0<\eta<2$, then $|1-\eta|<1$ and the energy contracts. For the monotone parameter contraction emphasized below, we use $0<\eta<1$.

This exact cancellation should not be overgeneralized. For a quadratic objective $L(x)=\tfrac12x^{\mathsf T}Hx$ with metric $G$, the update is

$$
x^+=(I-\eta G^{-1}H)x.
$$

Its behavior depends on the generalized eigenvalues of $(H,G)$. Complete cancellation occurs when $H=G$. Approximate matching can still improve conditioning, but the rate is then governed by the residual spectrum of $G^{-1}H$.

## 5. Constant-step dynamics

Fix $x_0\in\mathbb{R}^n$ and define the orbit recursively by

$$
x_{k+1}=T_\eta(x_k)=(1-\eta)x_k.
$$

### Theorem 3 (Exact constant-step orbit and energy law)

For every integer $k\ge 0$,

$$
x_k=(1-\eta)^kx_0
$$

and

$$
E_w(x_k)=\bigl((1-\eta)^2\bigr)^kE_w(x_0).
$$

#### Proof sketch

The parameter formula follows by induction. The base case is immediate. If it holds at $k$, then

$$
x_{k+1}=(1-\eta)x_k=(1-\eta)^{k+1}x_0.
$$

Applying Theorem 2 at every transition, or substituting the parameter formula into the quadratic energy, gives the energy identity.

### Corollary 3.1 (Geometric convergence)

If $0<\eta<1$, then

$$
\lim_{k\to\infty}E_w(x_k)=0
$$

with exact geometric ratio $(1-\eta)^2$.

#### Proof sketch

Under the stated assumption, $0<(1-\eta)^2<1$. Powers of a scalar strictly inside the unit interval converge to zero, and Theorem 3 multiplies those powers by the fixed finite value $E_w(x_0)$.

### Euclidean-gradient comparison

Ordinary gradient descent with step $\alpha$ gives

$$
x_{k+1}=(I-\alpha G)x_k,
$$

so coordinate $i$ contracts by $1-\alpha w_i$. With $\alpha=1/w_{\max}$, the coordinate associated with $w_{\min}$ contracts by

$$
1-\frac{w_{\min}}{w_{\max}}=1-\frac1\kappa.
$$

As $\kappa$ increases, this factor approaches one. In contrast, the matched natural-gradient contraction is $1-\eta$ for every coordinate. This comparison isolates the benefit of preconditioning without asserting that every nonquadratic or variable-metric problem has the same behavior.

## 6. Harmonic-step dynamics

Consider a decreasing schedule whose step at transition $k\to k+1$ is

$$
\eta_k=\frac{1}{k+2}.
$$

The orbit is

$$
x_{k+1}=(1-\eta_k)x_k
=\frac{k+1}{k+2}x_k.
$$

### Theorem 4 (Exact harmonic parameter law)

For every integer $k\ge 0$,

$$
x_k=\frac{x_0}{k+1}.
$$

#### Proof sketch

For $k=0$, the identity is $x_0=x_0$. Assuming $x_k=x_0/(k+1)$,

$$
x_{k+1}
=\frac{k+1}{k+2}\frac{x_0}{k+1}
=\frac{x_0}{k+2}.
$$

Equivalently, the product of transition factors telescopes:

$$
\prod_{j=0}^{k-1}\frac{j+1}{j+2}=\frac1{k+1}.
$$

### Theorem 5 (Exact harmonic energy law)

For every integer $k\ge 0$,

$$
E_w(x_k)=\frac{E_w(x_0)}{(k+1)^2}.
$$

#### Proof sketch

By Theorem 4, every coordinate is divided by $k+1$. Since $E_w$ is homogeneous of degree two,

$$
E_w\!\left(\frac{x_0}{k+1}\right)
=\frac{1}{(k+1)^2}E_w(x_0).
$$

### Rate interpretation

The exact law is $O(k^{-2})$ for the objective, stronger than a generic $O(k^{-1})$ convex guarantee. Yet it is not exponential. This matched quadratic is strongly convex relative to its metric, so the example also demonstrates that strong convexity alone cannot force exponential decay under a harmonic schedule. Iteration rates depend on accumulated step size. Here

$$
\sum_{j=0}^{k-1}\eta_j
$$

grows logarithmically, and exponential decay in accumulated continuous time becomes polynomial decay in the iteration counter.

## 7. Orthogonal modes and Pythagorean energy

The diagonal calculation has a coordinate-free analogue. Let $E$ be a real inner-product space, and suppose $x,y\in E$ satisfy

$$
\langle x,y\rangle=0.
$$

Pythagoras states

$$
\|x+y\|^2=\|x\|^2+\|y\|^2.
$$

### Theorem 6 (Orthogonal-mode contraction)

For every real $\eta$,

$$
\|(1-\eta)(x+y)\|^2
=(1-\eta)^2\left(\|x\|^2+\|y\|^2\right).
$$

#### Proof sketch

Norm homogeneity gives

$$
\|(1-\eta)(x+y)\|^2
=|1-\eta|^2\|x+y\|^2.
$$

Since $|1-\eta|^2=(1-\eta)^2$, applying Pythagoras yields the claim.

### Spectral meaning

A positive-definite quadratic decomposes into orthogonal eigenmodes. Euclidean gradient descent scales different modes by different factors. In the exactly matched metric, inverse-metric multiplication normalizes these factors, so all modes receive the same scalar contraction. Their squared energies then add by orthogonality. This is the Pythagorean core of condition-number cancellation.

## 8. Natural gradient is not an exact geodesic integrator

We now construct a variable-metric example in one dimension. Work on the positive half-line and define

$$
ds^2=4x^2\,dx^2.
$$

At $x=2$, the scalar metric is $G(2)=16$, so its inverse is $1/16$. Define the flattening coordinate

$$
\Phi(x)=x^2.
$$

Because $d\Phi=2x\,dx$, one has

$$
d\Phi^2=4x^2\,dx^2=ds^2.
$$

Thus $\Phi$ is an isometric coordinate: geodesics become straight lines in $\Phi$.

Consider the start point $x_s=2$ and target point $x_t=1$. The geodesic midpoint $x_m$ is characterized by

$$
\Phi(x_m)=\frac{\Phi(x_s)+\Phi(x_t)}2.
$$

Therefore

$$
x_m^2=\frac{2^2+1^2}{2}=\frac52,
\qquad
x_m=\sqrt{\frac52}.
$$

Now suppose the loss derivative at the start is $L'(2)=8$. A unit-multiplier natural-gradient Euler step gives

$$
x_E=2-G(2)^{-1}L'(2)
=2-\frac1{16}\cdot8
=\frac32.
$$

### Theorem 7 (Euler endpoint differs from the geodesic midpoint)

For the metric $ds^2=4x^2dx^2$, start $2$, target $1$, inverse metric $1/16$ at the start, and loss derivative $8$, the natural-gradient Euler endpoint $3/2$ is not the geodesic midpoint.

#### Proof sketch

A point is the geodesic midpoint precisely when its squared coordinate equals $5/2$. But

$$
\left(\frac32\right)^2=\frac94
$$

and $9/4\ne5/2$. Numerically, $x_E=1.5$, whereas $x_m\approx1.5811$.

### Why the discrepancy occurs

The tangent direction is metric-correct at $x=2$, but Euler addition freezes the local geometry during the finite move. The metric varies with $x$, and the flattening coordinate is nonlinear. Exact motion through half the intrinsic displacement requires linear interpolation in $\Phi$ followed by the inverse map:

$$
x_m=\Phi^{-1}\!\left(\frac{\Phi(2)+\Phi(1)}2\right).
$$

Coordinate averaging or coordinate Euler addition does not perform this operation. The example disproves only the exact-geodesic identification; it does not deny that short Euler steps can approximate a geometric flow under suitable regularity assumptions.

## 9. Algorithms

### 9.1 Matched constant-step natural gradient

Given positive weights $w$, initial vector $x_0$, step $\eta$, and iteration count $K$, the algorithm repeatedly applies $x\leftarrow(1-\eta)x$. Computing the gradient and inverse-metric product naively costs $O(n)$ per step, as does the simplified scaling. Storage is $O(n)$. The exact energy after $K$ steps is available without iteration:

$$
E_w(x_K)=((1-\eta)^2)^K E_w(x_0).
$$

### 9.2 Matched harmonic natural gradient

At step $k$, set $\eta_k=1/(k+2)$ and update $x\leftarrow(1-\eta_k)x$. Direct simulation costs $O(nK)$ time and $O(n)$ space. The closed form computes $x_K=x_0/(K+1)$ in $O(n)$ time, and the energy law provides an exact regression test for implementations.

### 9.3 One-dimensional geodesic midpoint test

For a positive one-dimensional metric admitting a flattening coordinate $\Phi$, compute the geodesic midpoint as

$$
x_m=\Phi^{-1}\!\left(\frac{\Phi(a)+\Phi(b)}2\right).
$$

Compute the natural-gradient Euler endpoint from $a$ and compare. For $\Phi(x)=x^2$, both computations are constant time. The test separates “metric-correct initial tangent” from “exact point on the geodesic at the intended fraction.”

## 10. Applications

### 10.1 Statistical learning

Fisher preconditioning can normalize parameter directions whose Euclidean scales differ greatly. The matched quadratic is a local idealization of a loss whose curvature is accurately captured by Fisher information. The exact theorem explains why natural gradient can be insensitive to parameter rescaling near such a regime. Outside that regime, the generalized spectrum of the objective Hessian relative to the Fisher metric becomes relevant.

### 10.2 Variational inference

Variational families often have strongly nonuniform sensitivity: a small parameter change may alter a distribution dramatically in one direction and barely at all in another. Fisher distance measures this sensitivity. The local minimization theorem justifies the natural-gradient direction for trust-region-like local models. The geodesic counterexample warns that a large coordinate Euler step may still distort the intended intrinsic move.

### 10.3 Ill-conditioned quadratic subproblems

Many optimization methods repeatedly solve or approximate local quadratic models. If a preconditioner matches the quadratic curvature, all eigenmodes contract uniformly. The results provide exact benchmark formulas for testing software, finite-precision effects, stochastic perturbations, or approximate inverse metrics.

### 10.4 Geometry-aware algorithm design

On a genuinely curved manifold, one should distinguish three layers: the metric selects a tangent direction; the schedule selects its magnitude; and an exponential map or retraction selects the endpoint. Convergence analysis must control all three. Curvature and metric variation enter through the final layer even when the initial tangent vector is optimal for the local model.

### 10.5 Experimental protocol

The exact identities suggest a reproducible diagnostic protocol. First choose positive diagonal weights spanning several prescribed condition numbers and initialize every coordinate away from zero. For constant matched descent, record $E_w(x_k)/E_w(x_0)$ and compare it with $((1-\eta)^2)^k$; the curves must coincide regardless of the weights. Next run Euclidean descent with a stable step based on the largest weight and inspect individual coordinates, since a total energy dominated by a high-weight coordinate can conceal slow motion in the low-weight mode. For the harmonic schedule, compare both the maximum coordinate error from $x_0/(k+1)$ and the energy error from $E_w(x_0)/(k+1)^2$.

Finally, test geometry and optimization separately. For the variable metric, compute intrinsic points through the flattening coordinate rather than inferring them from objective decrease. A loss can decrease at an Euler endpoint even though that endpoint is not the intended point on a geodesic. This separation prevents a successful descent plot from being misread as evidence of exact geodesic integration. In floating-point calculations, discrepancies in the matched identities should be assessed relative to the energy scale, while the midpoint counterexample has a fixed algebraic gap of $5/2-9/4=1/4$ and is therefore robust to ordinary numerical roundoff.

## 11. Limitations and discussion

The condition-number-free laws proved here rely on a constant positive metric and exact matching between metric and objective Hessian. They do not imply condition-number independence for arbitrary convex losses. They also do not establish global convergence on an incomplete manifold, across singular Fisher matrices, or in the presence of unbounded curvature.

The harmonic result is schedule-specific. Its exact $1/(k+1)^2$ objective decay arises because the state contracts by a telescoping product and the energy is quadratic. Other schedules produce other products. For a constant step the same model converges geometrically; for more general $\eta_k$, the state is

$$
x_k=\left(\prod_{j=0}^{k-1}(1-\eta_j)\right)x_0.
$$

The geodesic counterexample addresses exact equality, not approximation order. Under smoothness assumptions, an Euler step and an exponential-map step can agree to first order as the step tends to zero. Quantifying their higher-order discrepancy requires derivatives of the metric and bounds along the orbit.

These limitations yield a refined thesis. Natural gradient is correctly understood as intrinsic local steepest descent. It becomes exact, condition-free preconditioning in a matched flat model. It becomes geodesic descent only when paired with a suitable manifold update, and global rates then require intrinsic regularity assumptions.

## 12. Future research

A natural next problem is curvature-controlled exponential-map descent: on a geodesically complete manifold with bounded sectional curvature, positive injectivity radius, and geodesically smooth strongly convex loss, one expects linear rates governed by intrinsic constants rather than coordinate conditioning.

A second direction is to quantify retraction error. If the metric has controlled covariant variation, the difference between coordinate Euler motion and exponential-map motion should admit a local expansion whose accumulated effect can be related to integrated metric variation.

A third direction concerns Fisher metrics with graph-Laplacian structure. In repulsive probabilistic models, Fisher energy may coincide with electrical Dirichlet energy on a zero-sum tangent space. Effective-resistance diameter could then replace ambient spectral condition number as the intrinsic scale controlling optimization.

Finally, harmonic schedules deserve a sharp classification. For steps $a/(k+b)$, the decay exponent should reflect the product of the intrinsic strong-convexity scale and $a$. Exponential decay in iteration count should not be expected when average effective step size vanishes.

## 13. Conclusion

The geometry of optimization begins with the choice of metric but does not end there. Inverse-metric scaling is exactly the minimizer of a local metric model. When a constant metric matches quadratic curvature, this scaling cancels every weight, yielding exact condition-number-free laws: geometric energy decay for constant steps and $1/(k+1)^2$ decay for the harmonic schedule $1/(k+2)$. Orthogonal modes obey the same rule through Pythagorean energy decomposition.

A variable metric changes the story. The explicit metric $ds^2=4x^2dx^2$ shows that a natural-gradient Euler endpoint can miss the geodesic midpoint even in one dimension. Natural gradient supplies the right local compass; the exponential map or a controlled retraction determines the actual route. The mathematically sound synthesis is therefore both strong and limited: matched natural gradient is exact metric preconditioning, while geodesic convergence is a further geometric property requiring additional structure.
