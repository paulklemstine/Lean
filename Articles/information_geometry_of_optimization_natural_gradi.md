# Natural Gradient: When Optimization Learns the Shape of the Landscape

## The difference between a direction and a journey

Imagine hiking through a valley while carrying a map printed on rubber. In one direction the map has been stretched a thousandfold; in another it has been compressed. A step that looks short on the page may cross a mountain, while a large-looking displacement may barely move along the ground. Ordinary gradient descent trusts the printed coordinates. Natural gradient descent asks instead: what distance does the landscape itself assign to this move?

That question is central in information geometry. A family of probability distributions can be viewed as a curved space whose points are models and whose metric is the Fisher information matrix. Nearby parameters are close when the corresponding distributions are statistically hard to distinguish, not merely when their coordinate vectors have small Euclidean separation. If a loss function is $L(\theta)$ and the Fisher metric is $G(\theta)$, the natural-gradient direction is

$$
-G(\theta)^{-1}\nabla L(\theta).
$$

An Euler update with step size $\eta$ is therefore

$$
\theta^+=\theta-\eta G(\theta)^{-1}\nabla L(\theta).
$$

The inverse metric corrects for stretching in the coordinates. This makes natural gradient a principled form of preconditioning and explains its importance in statistics, machine learning, variational inference, and scientific models with strongly anisotropic parameters.

But a seductive slogan often goes too far: “natural gradient follows geodesics.” A geodesic is an intrinsically straight path on a curved manifold. Natural gradient selects an intrinsically steep tangent direction at the current point. Those are related facts, but they are not identical. Choosing the correct compass bearing does not guarantee that a straight coordinate step traces the curved road.

The exact results below draw that boundary sharply. They identify a setting in which metric conditioning disappears completely, derive exact constant-step and harmonic-step rates, explain the role of orthogonal energy, and give a one-dimensional counterexample showing that an Euler natural-gradient update need not land at a geodesic midpoint.

## Why the inverse metric is the right local direction

Start with a positive diagonal metric, represented by weights $w_1,\ldots,w_n>0$. Suppose the ordinary gradient at the current point is $g=(g_1,\ldots,g_n)$. For a proposed displacement $v$, consider the local model

$$
Q(v)=\sum_{i=1}^n\left(g_i v_i+\frac{w_i v_i^2}{2\eta}\right),
$$

where $\eta>0$. The first term predicts the loss change; the second charges for movement according to the metric. A direction with a large weight $w_i$ is expensive, while a direction with a small weight is cheap.

**Local steepest-descent theorem.** For positive $w_i$ and $\eta$, the displacement minimizing $Q$ is

$$
v_i^*=-\eta\frac{g_i}{w_i}.
$$

In matrix notation, $v^*=-\eta G^{-1}g$.

The proof is the familiar geometry of completing the square:

$$
g_i v_i+\frac{w_i v_i^2}{2\eta}
=
\frac{w_i}{2\eta}\left(v_i+\eta\frac{g_i}{w_i}\right)^2
-rac{\eta g_i^2}{2w_i}.
$$

Every squared term is nonnegative and vanishes exactly at $v_i^*$. Natural gradient is therefore not an arbitrary rescaling. It is the unique optimizer of the metric-aware quadratic model.

This theorem is local. It says which tangent vector best balances immediate improvement and intrinsic movement cost. It does not yet say how that vector should be transported across a manifold whose metric changes from point to point.

## The matched landscape where conditioning vanishes

The cleanest exact model uses the quadratic energy

$$
E_w(x)=\frac12\sum_{i=1}^n w_i x_i^2.
$$

Its Hessian is the diagonal matrix $G=\operatorname{diag}(w_1,\ldots,w_n)$, exactly matching the metric. The Euclidean gradient is $Gx$. Multiplying by $G^{-1}$ cancels every weight:

$$
G^{-1}\nabla E_w(x)=G^{-1}Gx=x.
$$

Thus one natural-gradient Euler step is simply

$$
x^+=(1-\eta)x.
$$

The largest weight might be a trillion times the smallest, yet the parameter update is the same scalar contraction in every coordinate.

**Exact one-step energy theorem.** For every real $\eta$,

$$
E_w(x^+)=(1-\eta)^2E_w(x).
$$

This follows by substituting $(1-\eta)x_i$ into each squared coordinate. Most importantly, the contraction factor contains no condition number $\kappa=\max_i w_i/\min_i w_i$.

Iterating gives an equally exact statement.

**Constant-step orbit theorem.** If $x_0$ is the initial point and

$$
x_{k+1}=(1-\eta)x_k,
$$

then

$$
x_k=(1-\eta)^k x_0
$$

and

$$
E_w(x_k)=\bigl((1-\eta)^2\bigr)^kE_w(x_0).
$$

When $0<\eta<1$, the factor $(1-\eta)^2$ lies strictly between zero and one, so the energy tends geometrically to zero. This is a genuine condition-number-free convergence law—but it depends on genuine matching. The objective curvature and the metric are the same matrix. The result does not justify a universal rate for arbitrary losses and arbitrary varying Fisher metrics.

For comparison, ordinary gradient descent on the same energy uses

$$
x_{k+1}=(I-\alpha G)x_k.
$$

A single step size $\alpha$ must accommodate all eigenvalues. With the conventional stable choice $\alpha=1/\max_i w_i$, the slowest coordinate contracts by $1-1/\kappa$. As $\kappa$ grows, that mode becomes painfully slow. Natural gradient cancels the anisotropy because the metric supplies exactly the missing scale.

This is optimization as geometry in its most transparent form: not a magical escape from all difficulty, but exact removal of coordinate distortion in a matched model.

## Harmonic steps: exact polynomial decay

Suppose the step size shrinks over time. At transition $k\to k+1$, choose

$$
\eta_k=\frac{1}{k+2}.
$$

The recurrence becomes

$$
x_{k+1}=\left(1-\frac{1}{k+2}\right)x_k
=\frac{k+1}{k+2}x_k.
$$

The factors telescope.

**Harmonic parameter theorem.** For every nonnegative integer $k$,

$$
x_k=\frac{x_0}{k+1}.
$$

Indeed, multiplying the transition factors gives

$$
\prod_{j=0}^{k-1}\frac{j+1}{j+2}=\frac{1}{k+1}.
$$

Because energy is quadratic, the objective decays with the square of the parameter scale.

**Harmonic energy theorem.** For every $k\ge 0$,

$$
E_w(x_k)=\frac{E_w(x_0)}{(k+1)^2}.
$$

This is stronger than a generic $O(1/k)$ upper bound, but it is polynomial rather than exponential. That distinction matters. Even a strongly convex quadratic does not yield exponential decay in iteration count when the step sizes themselves vanish harmonically. Strong convexity cannot undo a schedule whose cumulative action grows only logarithmically.

The lesson is not that harmonic steps are poor; they may be desirable under noise or uncertainty. The lesson is that convergence claims must name the schedule. Geometry, curvature, and step size work together.

## Pythagoras in the optimizer

There is also a coordinate-free way to see why independent modes contract cleanly. Let $x$ and $y$ be orthogonal vectors in a real inner-product space, so $\langle x,y\rangle=0$. Pythagoras gives

$$
\|x+y\|^2=\|x\|^2+\|y\|^2.
$$

Scaling both modes by $1-\eta$ yields the exact identity

$$
\|(1-\eta)(x+y)\|^2
=(1-\eta)^2\bigl(\|x\|^2+\|y\|^2\bigr).
$$

**Orthogonal-mode contraction theorem.** Every orthogonal component obeys the same scalar energy contraction, and their energies add without cross terms.

This Pythagorean viewpoint clarifies the spectral picture. In the matched constant metric, natural gradient turns all modes into equally scaled directions. The condition number disappears because no mode is privileged after measuring distance in the correct geometry.

## The geodesic trap

Now for the crucial limitation. Consider a positive one-dimensional region with metric

$$
ds^2=4x^2\,dx^2.
$$

The coordinate

$$
\Phi(x)=x^2
$$

flattens this metric because $d\Phi=2x\,dx$, hence $ds^2=d\Phi^2$. Geodesics are straight lines in the $\Phi$ coordinate. Therefore, the geodesic midpoint between $x=2$ and $x=1$ must satisfy

$$
\Phi(x_{\mathrm{mid}})=\frac{\Phi(2)+\Phi(1)}{2}=\frac{4+1}{2}=\frac52.
$$

Thus $x_{\mathrm{mid}}=\sqrt{5/2}$, approximately $1.5811$.

Now take a natural-gradient Euler step from $2$ with inverse metric $1/16$ at the start, loss derivative $8$, and unit step multiplier. Its endpoint is

$$
x_{\mathrm{Euler}}=2-\frac{1}{16}\cdot 8=\frac32.
$$

But

$$
\left(\frac32\right)^2=\frac94\ne\frac52.
$$

**Euler–geodesic separation theorem.** In this variable metric, the natural-gradient Euler endpoint is not the geodesic midpoint.

The example is deliberately one-dimensional: no high-dimensional complication can be blamed. Natural gradient chooses the metric-correct tangent direction at the start. Euler’s method then adds that tangent vector in the coordinate chart. An exact geodesic step would instead use the manifold’s exponential map—or a retraction designed to approximate it. When the metric varies, these operations differ.

## What survives—and what does not

The strongest defensible message is precise.

Natural gradient is intrinsic steepest descent for a local metric model. When a constant Fisher metric exactly matches a quadratic objective’s curvature, it removes spectral conditioning: constant steps give an exact geometric energy law, while the harmonic schedule $1/(k+2)$ gives the exact law $E_w(x_k)=E_w(x_0)/(k+1)^2$. Orthogonal modes contract according to the same Pythagorean scaling.

What does not survive is the unrestricted claim that every natural-gradient Euler update follows a geodesic, or that shortest-path language alone guarantees universal condition-number-free rates. Global convergence on a statistical manifold also depends on convexity, smoothness, completeness, curvature, injectivity radius, metric variation, and the update map used to move from the tangent space back to the manifold.

That sharper perspective is more useful than the slogan. It tells practitioners when natural gradient can be expected to neutralize ill-conditioning, what exact rate a schedule produces, and why replacing a coordinate Euler step by an exponential-map or controlled-retraction step may matter.

The same distinction guides numerical experiments. A meaningful benchmark should not merely show that one method descends faster on one dataset. It should vary the metric anisotropy while holding the intrinsic matched problem fixed, verify the predicted energy ratio at every iterate, and separately compare coordinate endpoints with intrinsic ones. In the constant model, changing the weights from nearly equal to wildly unequal leaves the natural-gradient contraction unchanged. Under harmonic steps, plotting energy against $k+1$ on logarithmic axes reveals the exact slope $-2$. In the curved one-dimensional model, plotting the flattening coordinate $\Phi(x)=x^2$ makes the missed midpoint visible: the Euler point lies below the required intrinsic halfway level.

These are small models, but that is their strength. Each strips away distractions and turns a broad geometric intuition into a statement that can be checked exactly. They serve as calibration cases for larger statistical systems: if an implementation advertised as natural gradient does not reproduce the matched cancellation, something is wrong; if a finite Euler step is described as geodesic without a retraction analysis, something is missing.

Optimization really is geometry—but geometry includes not only a metric and a direction, but also curvature and the rule by which a local direction becomes a global journey.
