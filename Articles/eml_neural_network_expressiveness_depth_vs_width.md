# A Smooth Neuron That Learns a Curve at an Inverse-Square Rate

## The smallest laboratory for neural approximation

A neural network is often judged by the complexity of the pictures, sounds, or language it can process. Yet some of the clearest lessons about expressiveness appear in a much smaller laboratory: ask a network to draw the parabola $y=x^2$ on the interval $0\le x\le 1$.

This task has almost none of the distractions of a large learning system. There is one input, one output, and a familiar target. Nevertheless, it exposes three central questions. What does the nonlinear activation contribute? How should approximation error change with a resource budget? And can the approximating curve retain a smooth, useful derivative?

Consider the EML activation

$$
\Phi(x)=\exp(ax+b)-\log(a'x+b').
$$

Its two branches combine exponential and logarithmic behavior. The logarithm requires $a'x+b'>0$ on the domain of interest. For the construction below, the logarithmic branch is deliberately set to the harmless constant $\log 1=0$ by taking $a'=0$ and $b'=1$. This does not make the activation irrelevant: it isolates the exponential branch and shows that one member of the EML family already contains a remarkably efficient local model of curvature.

The result is explicit. There is no training loop and no hidden set of fitted coefficients. For a positive scale $h$, define

$$
Q_h(x)=\frac{2}{h^2}\bigl(\exp(hx)-1-hx\bigr).
$$

This is the exponential remainder after subtracting its constant and linear parts, magnified by $2/h^2$. Since

$$
\exp(hx)=1+hx+\frac{h^2x^2}{2}+\frac{h^3x^3}{6}+\cdots,
$$

the subtraction removes the first two terms, while the magnification turns the quadratic term into exactly $x^2$. Everything left begins at cubic order in $hx$. In other words, the parabola is already sitting inside the exponential function; the construction simply peels away the lower-order layers.

## A two-stage smooth computation

The formula can be read as a shallow neural computation. A nonlinear unit first evaluates

$$
\exp(hx+0)-\log(0x+1)=\exp(hx).
$$

An affine readout multiplies this value by $2/h^2$, subtracts $2/h^2$, and adds the linear skip term $-(2/h)x$. Thus

$$
Q_h(x)=\frac{2}{h^2}\left(\exp(hx)-\log(0x+1)\right)-\frac{2}{h^2}-\frac{2}{h}x.
$$

This is a depth-two realization when an affine output layer and a linear skip connection are allowed. That architectural qualification matters. The statement is about the displayed shallow computation; compiling the skip connection into a more restrictive layered model without changing depth is a separate design question.

The construction is smooth everywhere. Its exact derivative is

$$
Q_h'(x)=\frac{2}{h}\bigl(\exp(hx)-1\bigr).
$$

As $h$ becomes small, the derivative resembles $2x$, because $\exp(hx)-1\approx hx$. The approximant therefore does not merely trace the parabola. Its slope changes continuously, with no corners or breakpoints. This is attractive whenever gradients have physical meaning: force fields, control laws, differentiable simulators, and sensitivity calculations all care about how an approximation changes, not only about its values.

## Turning width into a scale

Now introduce a positive integer budget $w$ and choose

$$
h=\frac{1}{w^2}.
$$

Define the width-indexed family

$$
Q_w(x)=Q_{1/w^2}(x)
       =2w^4\left(\exp\left(\frac{x}{w^2}\right)-1-\frac{x}{w^2}\right).
$$

The symbol $w$ indexes the accuracy scale. The formula itself uses one nonlinear activation; increasing $w$ makes its internal exponential argument smaller while making the output coefficients larger. Accordingly, $w$ should be read here as a width budget used to select parameters, not as evidence that $w$ distinct neurons are necessary.

The central guarantee is uniform over the whole interval.

**Inverse-Square Approximation Theorem.** For every integer $w\ge 1$ and every $x\in[0,1]$,

$$
\left|Q_w(x)-x^2\right|\le \frac{4}{9w^2}.
$$

“Uniform” is the crucial word. The theorem does not say merely that a cloud of sampled points looks close. It controls the worst error at every real input between $0$ and $1$. Doubling $w$ divides the certified error by four; multiplying $w$ by ten divides it by one hundred.

Why does this happen? The Taylor expansion gives the intuition. For $0<h\le1$ and $0\le x\le1$,

$$
Q_h(x)-x^2
 =2\sum_{k=3}^{\infty}\frac{h^{k-2}x^k}{k!}.
$$

The remainder is nonnegative, and its leading contribution is $hx^3/3$. A uniform exponential-remainder estimate controls the entire tail by $4h/9$. Substituting $h=1/w^2$ yields $4/(9w^2)$. The certified constant is conservative—the asymptotic leading constant suggested by the series is $1/3$—but it is simple and valid across the complete interval for every positive integer budget.

## What the comparison does—and does not—say

A natural benchmark is an inverse-linear certificate,

$$
\frac{4}{9w}.
$$

The inverse-square guarantee always improves on it:

$$
\frac{4}{9w^2}\le\frac{4}{9w}\qquad(w\ge1),
$$

and the inequality is strict as soon as $w\ge2$. At $w=1$, both expressions equal $4/9$. At $w=2$, the inverse-square certificate is $1/9$, while the inverse-linear benchmark is $2/9$. At $w=10$, they are $1/225$ and $2/45$, respectively.

This comparison is exact arithmetic, but it should not be overinterpreted. It compares two error laws with the same normalization; it is not by itself a universal lower bound for every competing activation or architecture. In particular, piecewise-linear approximation of a smooth quadratic can also exhibit inverse-square behavior when complexity is measured by the number of affine pieces. A definitive architecture-to-architecture comparison must align parameter counts, region counts, allowable skip connections, and coefficient magnitudes.

That distinction makes the present result more useful, not less. It identifies a clean mechanism: smooth exponential curvature can produce an explicit inverse-square family in a very shallow computation. It supplies a controlled test case around which fairer comparisons can be built.

## The numerical picture

The formulas are stable in theory but demand a little care in floating-point arithmetic. When $h$ is small, directly computing $\exp(hx)-1-hx$ subtracts nearly equal numbers. A robust implementation uses the special function $\operatorname{expm1}(z)=\exp(z)-1$ and evaluates

$$
Q_h(x)=\frac{2}{h^2}\bigl(\operatorname{expm1}(hx)-hx\bigr).
$$

Sampling a dense grid on $[0,1]$ shows the error rising smoothly from zero near $x=0$ and remaining below the theorem’s envelope. The derivative can be evaluated stably as

$$
Q_h'(x)=\frac{2}{h}\operatorname{expm1}(hx).
$$

These computations illustrate the theorem but do not replace its uniform conclusion: no finite grid can inspect every real input.

There is also a practical tradeoff hiding in the coefficients. Since $2/h^2=2w^4$ and $2/h=2w^2$, higher nominal accuracy requires rapidly growing readout weights and increasingly delicate cancellation. Approximation theory counts error; numerical analysis also counts conditioning. In exact arithmetic the family improves cleanly. In finite precision, extremely large $w$ may require series evaluation or higher precision.

## Why a parabola matters

Approximating $x^2$ is more than a classroom exercise. Multiplication can be recovered from squaring through the polarization identity

$$
xy=\frac{(x+y)^2-(x-y)^2}{4}.
$$

Consequently, a reliable square module is a gateway to products, polynomial features, quadratic energies, and local second-order models. Many scientific systems are organized around such quantities: kinetic energy is quadratic in velocity, least-squares losses are quadratic in residuals, and local curvature governs optimization.

The construction also offers a model for activation design. Rather than asking only whether an activation is nonlinear, one can ask which Taylor coefficient becomes available after affine terms are canceled. Here, the nonzero second derivative of the exponential branch stores quadratic structure. Scaling reveals it. The broader lesson is that activation geometry and parameter scaling can work together to encode useful functions economically.

## Reading the bound as a resource law

Error rates are easiest to feel through scaling. Suppose a modeler wants a guaranteed error below a tolerance $\varepsilon>0$. The theorem says it is enough to choose an integer $w$ satisfying

$$
w\ge \sqrt{\frac{4}{9\varepsilon}}.
$$

The square root is the operational signature of an inverse-square law. Demanding one hundred times more accuracy requires ten times the index, rather than one hundred times. This inversion of the error formula is often how approximation results enter engineering decisions: begin with an acceptable discrepancy, then calculate a sufficient budget.

The guarantee is one-sided in another useful sense. It supplies a sufficient value of $w$, not a necessary one. The actual maximum error is smaller than the certificate, particularly because $4/9$ is not expected to be the sharp asymptotic constant. Numerical experiments can estimate the slack, while the theorem remains the safety envelope.

A plot also reveals geometry that a rate alone hides. Because every term in the error series is nonnegative on $[0,1]$, the approximating curve sits above the parabola. Near the origin they share value, slope, and quadratic behavior; separation accumulates toward the right endpoint. This is a highly structured error, unlike an arbitrary oscillating residual. Future constructions might exploit both exponential and logarithmic branches to cancel the cubic contribution and produce an even flatter residual.

## The frontier beyond the test case

The one-dimensional quadratic result is a foundation, not a proof of universal approximation rates. A larger conjecture proposes that an EML network with width $w$ and depth $d$ could approximate every Lipschitz function on $[0,1]^n$ with error on the order of

$$
(wd)^{-2/n}.
$$

The explicit parabola does not establish that claim. General Lipschitz functions may lack smooth curvature, dimensions interact, and an architecture must distribute local approximants across the domain. The test case instead demonstrates that the activation can realize the desired inverse-square scaling on one canonical smooth target.

Several precise questions now come into focus. Can the shallow realization be compiled into a strict layered EML architecture with depth exactly two and width at most $w$? Does $w^2$ times the true worst-case error converge to $1/3$? Do the derivatives converge uniformly to $2x$ at inverse-square rate? How does the family compare with the optimal continuous piecewise-linear approximation when both are measured by the same resource?

The humble parabola has done its job. It has turned a broad expressiveness question into an explicit curve, an exact derivative, and a uniform error law. The result is a compact demonstration of how smooth nonlinear structure can be extracted, scaled, and controlled—and a map of the questions that must be answered before that local success becomes a general theory of depth and width.
