# A Fixed Point Below Four Dimensions

## How a small change in dimension reveals a new scale-invariant world

Few ideas in modern physics are as powerful as the renormalization group. It replaces the impossible demand to track every microscopic detail with a more revealing question: what happens to a theory when we change the scale at which we observe it? Molecules disappear into fluid flow, atomic spins merge into domains, and complicated local interactions become a motion through a small space of effective parameters. The special places where that motion stops—fixed points—govern critical phenomena.

A particularly elegant example begins with a scalar field and a quartic interaction, often called the one-component $\phi^4$ model. Near four spatial dimensions, the model admits a perturbative description controlled by

$$
\varepsilon=4-d,
$$

where $d$ is the dimension. When $d$ lies just below $4$, the positive number $\varepsilon$ is small. Wilson’s epsilon expansion turns that small geometric displacement into an algebraic microscope: critical properties can be expanded in powers of $\varepsilon$.

The model considered here distills the one- and two-loop calculation to its essential polynomial data. In a convenient normalization, the running coupling $g$ has the one-loop beta function

$$
\beta(\varepsilon,g)=-\varepsilon g+3g^2.
$$

The beta function is the velocity field of scale change. If $\beta$ is nonzero, changing scale moves the effective coupling. If $\beta$ vanishes, the coupling stays put. Such a zero represents a scale-invariant theory.

## Two places where the flow stops

The beta function factors immediately:

$$
\beta(\varepsilon,g)=g(-\varepsilon+3g).
$$

This factorization gives a complete classification of its fixed points. There are exactly two possible zeros:

$$
g=0
\qquad\text{or}\qquad
g_*=\frac{\varepsilon}{3}.
$$

The first is the Gaussian fixed point, where the interaction vanishes. The second is the Wilson–Fisher fixed point, where the interaction survives. It is not an optional branch or a numerical accident; within the one-loop model, these are all the zeros.

Now substitute $\varepsilon=4-d$. If $d<4$, then $\varepsilon>0$, and therefore

$$
g_* = \frac{4-d}{3}>0.
$$

So below four dimensions the non-Gaussian point is positive, nonzero, and genuinely distinct from the Gaussian point. Moreover,

$$
\beta(4-d,g_*)=0.
$$

This is the central geometric event: lowering the dimension through four creates a positive interacting fixed point in the truncated flow. The coupling is small when $d$ is close to $4$, which is precisely why perturbation theory can see it.

The direction of the nearby flow is encoded by the derivative with respect to $g$. The linearized slope is

$$
\frac{\partial\beta}{\partial g}=-\varepsilon+6g.
$$

At $g=g_*=\varepsilon/3$, this becomes

$$
-\varepsilon+6\frac{\varepsilon}{3}=\varepsilon.
$$

Hence the slope is positive whenever $\varepsilon>0$. This calculation is exact for the truncated beta function. Whether one calls the point stable or unstable depends on the convention for the direction of renormalization-group time, but the local linear coefficient itself is unambiguous.

## The tiny exponent hidden in two loops

Fixed points matter because critical exponents are evaluated there. One such exponent is the anomalous dimension $\eta$. It measures how critical correlations depart from their simplest, or “classical,” scaling law. In this normalization, the two-loop truncation gives the coupling-dependent expression

$$
\eta(g)=\frac{g^2}{6}.
$$

The absence of a linear term is significant. Since the fixed-point coupling is itself proportional to $\varepsilon$, the first nonzero term in $\eta$ is quadratic in $\varepsilon$. Substituting $g_* = \varepsilon/3$ yields

$$
\eta(g_*)
=\frac{1}{6}\left(\frac{\varepsilon}{3}\right)^2
=\frac{\varepsilon^2}{54}.
$$

Thus Wilson’s coefficient emerges exactly:

$$
\eta=\frac{\varepsilon^2}{54}+O(\varepsilon^3).
$$

The denominator $54$ can also be read as a small census of the relevant two-loop contributions. In the chosen bookkeeping, two equal “sunset” contributions each carry weight $1/108$. Their sum is

$$
\frac{1}{108}+\frac{1}{108}=\frac{1}{54}.
$$

This is a compact reminder of how perturbative physics works. Diagrams organize the calculation, rational coefficients record their combinatorics and normalization, and the fixed-point substitution turns those coefficients into an observable critical exponent.

## What the error term really says

The notation $O(\varepsilon^3)$ is often spoken aloud as “terms of third order and higher,” but it has a precise local meaning. A function $r(\varepsilon)$ is of order three at zero if there are constants $C>0$ and $\delta>0$ such that

$$
|r(\varepsilon)|\le C|\varepsilon|^3
$$

whenever $|\varepsilon|<\delta$. Suppose omitted higher-order physics contributes such a remainder. Define

$$
\eta_{\mathrm{full}}(\varepsilon)
=\eta(g_*)+r(\varepsilon).
$$

Because $\eta(g_*)=\varepsilon^2/54$ exactly in the two-loop truncation,

$$
\eta_{\mathrm{full}}(\varepsilon)-\frac{\varepsilon^2}{54}
=r(\varepsilon).
$$

The same constants $C$ and $\delta$ therefore prove that the difference is bounded by $C|\varepsilon|^3$. This is the remainder-propagation theorem: any genuinely cubic-order omitted term preserves the expansion

$$
\eta_{\mathrm{full}}(\varepsilon)
=\frac{\varepsilon^2}{54}+O(\varepsilon^3).
$$

No hidden cancellation is needed. The result follows because the displayed quadratic coefficient is exact within the specified truncation.

## Guardrails against tempting overstatements

Simple formulas can invite claims stronger than they support. Two counterexamples mark the boundary clearly.

First, the beta function does not have a unique zero for every $\varepsilon$. At $\varepsilon=3$,

$$
\beta(3,g)=-3g+3g^2=3g(g-1),
$$

so both $g=0$ and $g=1$ are zeros. The Gaussian point must not be silently discarded when discussing the interacting point.

Second, the Wilson–Fisher coupling is not positive above four dimensions. Above four dimensions, $d>4$ and hence $\varepsilon<0$. For the concrete choice $\varepsilon=-3$,

$$
g_* = \frac{-3}{3}=-1,
$$

which is negative. The positivity theorem belongs specifically to $d<4$.

These counterexamples are not side issues. They show how a careful mathematical model separates a valid local conclusion from an unjustified global slogan.

## A worked numerical journey

Take $d=3.9$. Then $\varepsilon=0.1$ and

$$
g_*\approx 0.033333,
\qquad
\eta\approx\frac{0.1^2}{54}\approx 0.000185185.
$$

At $d=3.5$, one has $\varepsilon=0.5$, so

$$
g_*\approx 0.166667,
\qquad
\eta\approx 0.00462963.
$$

At $d=3$, the formal substitution gives $\varepsilon=1$ and

$$
g_*\approx 0.333333,
\qquad
\eta\approx 0.0185185.
$$

The formulas remain algebraically valid, but the perturbative interpretation becomes less controlled as $\varepsilon$ grows. An asymptotic expansion near $\varepsilon=0$ is not automatically a globally accurate numerical approximation. This distinction between exact algebra in a truncated model and accuracy for a full physical theory is essential.

## Why dimension is a control knob

It may seem strange to treat dimension as a continuously adjustable number. In ordinary geometry, we inhabit an integer-dimensional space. In perturbative analysis, however, $d$ also acts as a parameter in the formulas defining loop contributions and scaling laws. Expanding around $d=4$ is therefore much like expanding a difficult function around a point where its behavior is simpler.

At exactly $d=4$, the one-loop beta function becomes

$$
\beta(0,g)=3g^2,
$$

and the interacting solution meets the Gaussian solution at $g=0$. Moving slightly below four dimensions contributes the competing term $-\varepsilon g$. The new balance

$$
-\varepsilon g+3g^2=0
$$

occurs at a small positive coupling. This is why the method works: the same small parameter that measures the dimensional shift also measures the distance of the new fixed point from the exactly solvable Gaussian point.

The mechanism resembles familiar threshold behavior. At a phase transition, a control parameter such as temperature can create or destroy an equilibrium. Here dimension plays that organizing role in the effective flow. The analogy should not be pushed too far—the renormalization-group trajectory is not ordinary motion through physical space—but it gives an intuitive picture of why a new scale-invariant regime appears.

The result also illuminates universality. Critical behavior does not depend on every microscopic detail independently. Near a fixed point, many details wash out under repeated changes of scale, while a small set of scaling data remains. The anomalous dimension $\eta$ is part of that surviving data. Its coefficient $1/54$ is tiny, but conceptually it records a real departure from naive scaling, generated by interaction effects that first appear at two-loop order.

This perspective connects magnets, fluids, binary mixtures, and many other systems near continuous phase transitions. Their microscopic constituents can be entirely different, yet the long-distance mathematics can be organized by the same kind of fixed-point structure. The polynomial studied here is only a sharply focused model of that larger story, but it displays the decisive sequence with unusual clarity: identify the flow, find every stationary coupling, choose the branch appropriate to the dimensional regime, and evaluate the scaling observable there.

## What has—and has not—been established

The conclusions form a complete algebraic story for the stated perturbative data. The beta function’s zeros are exactly the Gaussian and Wilson–Fisher points. Below four dimensions the latter is positive and nontrivial. Its linearized slope is $\varepsilon$. The two equal sunset weights sum to $1/54$. Evaluating the two-loop anomalous dimension at the interacting fixed point gives $\varepsilon^2/54$, and any cubic-order remainder preserves the corresponding asymptotic expansion.

This does not derive the diagram weights from regularized momentum integrals, construct the underlying quantum field theory, or prove convergence of the perturbation series. Those are deeper analytical tasks. The achievement here is narrower and clean: once the perturbative coefficients are specified, every fixed-point and asymptotic conclusion follows by exact algebra and a precise remainder estimate.

That narrowness is also the source of the example’s beauty. A sweeping physical phenomenon—the emergence of universal critical behavior—appears in miniature as the factorization of a quadratic polynomial. Dimension moves the fixed point; the fixed point feeds the anomalous dimension; and two small rational contributions combine into the coefficient $1/54$. The renormalization group turns scale into motion, while the epsilon expansion turns that motion into a calculation.