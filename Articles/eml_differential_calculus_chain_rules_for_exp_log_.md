# Differentiating the Exponential–Logarithmic World

## A small missing factor with large consequences

Some mathematical expressions behave like carefully engineered machines. Exponentials amplify, logarithms compress, addition combines signals, and multiplication lets one effect modulate another. Together these operations form a useful family of formulas—call them **exponential–multiplicative–logarithmic expressions**, or EML expressions. They appear wherever growth and scale interact: compound interest, reaction rates, information measures, likelihoods, asymptotic models, and the calibration of systems whose outputs span many orders of magnitude.

A natural question is whether this family remains recognizable after differentiation. If a formula is built from exponentials, logarithms, sums, and products, does its rate of change retain a similarly organized shape? The answer begins with one deceptively simple function:

$$
F(x)=e^{h(x)}\log(g(x)).
$$

Here $h$ and $g$ are differentiable inner functions. This is an exponential shell multiplied by a logarithmic signal. It is exactly the kind of expression one might expect to possess an elegant multiplicative derivative.

A tempting guess is

$$
F'(x)=F(x)\left(h'(x)+\frac{g'(x)}{g(x)}\right).
$$

It looks plausible because $(e^h)'=e^h h'$ and $(\log g)'=g'/g$. But multiplication does not permit those two logarithmic derivatives simply to be added in this way: the second factor in $F$ is $\log g$, not $g$. One missing denominator changes the theorem.

The correct unfactored chain rule, valid whenever $g(x)\ne0$, is

$$
F'(x)=e^{h(x)}\left(h'(x)\log(g(x))+\frac{g'(x)}{g(x)}\right).
$$

This identity follows directly from the product and chain rules. It is also the safest computational form because it remains meaningful when $\log(g(x))=0$.

When both $g(x)\ne0$ and $\log(g(x))\ne0$, the derivative can indeed be factored through the original function:

$$
F'(x)=F(x)\left(h'(x)+
\frac{g'(x)}{g(x)\log(g(x))}\right).
$$

The missing factor was $1/\log(g(x))$. This corrected identity is the central structural result: away from zeros, the rate of change of an exponential–logarithmic product is the product itself times a logarithmic-derivative correction.

## Why the obvious formula fails

The shortest counterexample is also the most revealing. Choose $h(x)=0$ and $g(x)=e^x$. Then

$$
F(x)=e^0\log(e^x)=x,
$$

so $F'(x)=1$. At $x=2$, however, the tempting formula gives

$$
F(2)\left(0+\frac{e^2}{e^2}\right)=2.
$$

Thus the proposed value is $2$ while the true derivative is $1$. This is not a boundary-case failure or a numerical accident. The discrepancy exposes the precise algebraic mistake.

The counterexample also explains why zeros matter. If $g(x)=1$, then $\log(g(x))=0$, so $F(x)=0$. Dividing by $F(x)$ to form a logarithmic derivative is impossible even though the ordinary derivative may exist perfectly well. In the example above, $g(0)=1$ and $F(0)=0$, yet $F'(0)=1$. Factoring a derivative through the original function is therefore a local privilege of zero-free regions, not a universal law.

For the real logarithm as used here, the derivative formula requires $g(x)\ne0$ at the point under consideration. In ordinary real-variable applications one usually works on a positive domain so that the familiar logarithm is present throughout an interval. The distinction is useful: the unfactored rule only needs the logarithm’s derivative to exist, while the fully factored rule additionally requires its value not to vanish.

## A three-derivative stress test

A structural rule should survive a demanding example. Consider

$$
f(x)=e^{x^2}\log(x+1), \qquad x>-1.
$$

The exponential $e^{x^2}$ grows rapidly, while $\log(x+1)$ carries a boundary at $x=-1$. Differentiation mixes growth, logarithmic behavior, and rational poles. Yet the answer remains organized.

The first derivative is

$$
f'(x)=e^{x^2}\left(2x\log(x+1)+\frac{1}{x+1}\right).
$$

The exponential shell survives. Inside it, one term retains the logarithm and one rational term records the derivative of that logarithm.

Differentiating again gives

$$
f''(x)=e^{x^2}\left(
(4x^2+2)\log(x+1)+\frac{4x}{x+1}-\frac{1}{(x+1)^2}
\right).
$$

The same architecture remains: an exponential shell, one polynomial times a logarithm, and rational corrections. The largest pole order has risen from $1$ to $2$.

The third derivative is

$$
f'''(x)=e^{x^2}\left(
(8x^3+12x)\log(x+1)
+\frac{12x^2+6}{x+1}
-\frac{6x}{(x+1)^2}
+\frac{2}{(x+1)^3}
\right).
$$

This formula is valid throughout the natural real domain $x>-1$. Each step can be checked by the product rule: if an expression is $e^{x^2}A(x)$, its derivative is

$$
\frac{d}{dx}\bigl(e^{x^2}A(x)\bigr)
=e^{x^2}\bigl(2xA(x)+A'(x)\bigr).
$$

That compact operator, $A\mapsto2xA+A'$, explains why the outer exponential never changes and why the inner coefficients evolve systematically.

## Two kinds of complexity

The third derivative tells a deeper story. Transcendental nesting and singular behavior are different kinds of complexity.

The **nesting depth** measures how deeply operations such as exponential and logarithm are placed inside one another. Across the three derivatives above, the shell $e^{x^2}$ and the single logarithm $\log(x+1)$ do not acquire ever deeper nests. By contrast, the **pole order** at $x=-1$ increases one step at a time: $(x+1)^{-1}$ appears first, then $(x+1)^{-2}$, then $(x+1)^{-3}$.

This suggests tracking expressions with two gauges rather than one. One gauge records transcendental depth; the other records meromorphic severity. Differentiation can preserve the first while increasing the second. That separation matters computationally because an expression may remain conceptually shallow even as its boundary behavior becomes sharper.

The emerging normal form is

$$
e^{x^2}\left(P_n(x)\log(x+1)+
\sum_{k=1}^{n}\frac{Q_{n,k}(x)}{(x+1)^k}\right),
$$

where $P_n$ and $Q_{n,k}$ are polynomials. The first three derivatives establish the pattern through $n=3$. A natural next problem is to prove it for every $n$, derive recurrences for the coefficient polynomials, and determine whether the representation is unique.

## Powers hidden inside shallow exp–log expressions

There is another illustration of depth stability. On the positive half-line, every positive integer power can be written as

$$
x^m=e^{m\log x}, \qquad x>0.
$$

No matter how large $m$ becomes, this representation has the same fixed sequence of operations: take a logarithm, multiply by $m$, then exponentiate. Differentiation recovers the usual rule

$$
\frac{d}{dx}e^{m\log x}=m x^{m-1}.
$$

In particular, for every nonnegative integer $n$,

$$
\frac{d}{dx}e^{(n+1)\log x}=(n+1)x^n, \qquad x>0.
$$

The exponent can grow without increasing the transcendental nesting depth. This is a useful reminder that written size, algebraic degree, and compositional depth are distinct resources.

## From calculus rule to algorithm

The formulas lead directly to symbolic differentiation procedures. For a general product $e^{h}\log g$, compute $h'$ and $g'$, then return the unfactored expression

$$
e^h\left(h'\log g+\frac{g'}{g}\right).
$$

Only if a zero-free region for both $g$ and $\log g$ is known should the algorithm rewrite this as

$$
e^h\log g\left(h'+\frac{g'}{g\log g}\right).
$$

That guard is mathematically important. An automatic system that factors indiscriminately can manufacture artificial singularities at points where the original derivative is finite.

For the test family, a second algorithm stores the inner expression as a logarithmic term plus a finite list of pole terms. Differentiating updates polynomial coefficients and shifts some mass from pole order $k$ to pole order $k+1$. With shared subexpressions, the representation can remain compact rather than expanding into a forest of repeated products.

Such organization has practical value in sensitivity analysis, optimization, uncertainty propagation, and scientific computing. Near $x=-1$, the explicit pole terms reveal numerical instability. Far from the boundary, the factored form can expose relative growth. In both regimes, structure tells us which evaluation strategy is appropriate.

## Reading the formulas as a map

The normal form is also a map of where computation becomes difficult. The exponential factor $e^{x^2}$ controls large-$x$ growth. The powers of $(x+1)^{-1}$ control behavior near the left boundary. The logarithm changes comparatively slowly in the interior. A numerical analyst can therefore inspect the formula and identify three distinct regimes.

Near $x=-1$, rational pole terms dominate, and small input errors can be magnified severely. Around $x=0$, the unfactored formula is preferable because the logarithmic factor vanishes there. For large positive $x$, scaling out $e^{x^2}$ can prevent overflow and preserve information about the remaining factor. One symbolic identity thus suggests different numerical representations in different regions.

This is a recurring theme in applied mathematics. A formula is not merely a recipe for a number; it is a compressed description of geometry. Its zeros mark where relative coordinates fail. Its poles mark sensitive boundaries. Its factorizations separate sources of growth. When an algorithm respects these features, it can be both clearer and more reliable.

There is also a lesson for teaching calculus. Product and chain rules are often introduced as procedures that expand expressions. The exp–log example shows the value of a second phase: reorganize the derivative according to meaningful factors, but record exactly which divisions that reorganization uses. Algebraic elegance without domain awareness is dangerous. The correct factored formula is beautiful precisely because its limitations are explicit.

That habit scales beyond this example. Whenever a derivative is divided by the original function, zeros must become part of the story. Whenever a logarithm is differentiated, its argument’s admissible region must be tracked. These are not technical footnotes; they determine where an identity describes the same function and where it merely resembles one.

## The larger lesson

The most valuable outcome is not merely a third derivative. It is a disciplined picture of what differentiation preserves and what it changes.

For $e^{h(x)}\log(g(x))$, the product and chain rules give an exact, universally safe local formula wherever $g(x)\ne0$. A stronger factorization through the original function exists only where $\log(g(x))\ne0$ as well. The easy-looking alternative without this extra logarithm is false, and the identity-function counterexample pinpoints why.

For $e^{x^2}\log(x+1)$, three derivatives retain a stable exponential–logarithmic normal form while rational pole order grows predictably. For positive monomials, arbitrarily high algebraic degree fits inside a fixed-depth exp–log representation compatible with the ordinary derivative.

Calculus often appears to make expressions larger and messier. Here it does something subtler. It preserves a hidden architecture while moving complexity from one compartment to another. Once that architecture is visible, differentiation becomes not just an operation to perform, but a transformation whose shape can be anticipated, controlled, and used.