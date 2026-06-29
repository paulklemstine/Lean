# The Constant That Refuses to Confess

## A number caught between counting and curves

Add up the reciprocals of the whole numbers, one at a time:

$$H_n = 1 + \frac{1}{2} + \frac{1}{3} + \cdots + \frac{1}{n}.$$

This is the *harmonic number*, and it grows — slowly, stubbornly, forever. There is no ceiling it cannot eventually climb above. But it climbs at a very particular pace. If you compare it to the natural logarithm $\ln n$, which also grows without bound, you find that the two stay almost in lockstep. The gap between them does not blow up and does not collapse. Instead it settles, with uncanny calm, onto a single fixed number:

$$\gamma = \lim_{n \to \infty} \left( H_n - \ln n \right) = 0.5772156649\ldots$$

This number is the **Euler–Mascheroni constant**. It is one of the most famous constants in mathematics, sitting in the same pantheon as $\pi$ and $e$ — and yet, unlike those two, it guards a secret we still cannot pry loose. We do not know whether $\gamma$ is rational or irrational. Nobody has ever written it as a fraction, and nobody has ever proved that it cannot be written as one. After more than two and a half centuries, the constant simply refuses to confess.

This article is about a clean, modern way to *understand* $\gamma$ — to pin it down as an honest, convergent sum of positive pieces, to see those pieces as slivers of area under a curve, to measure exactly how fast the approximations close in, and finally to look squarely at why the irrationality question is so hard, by reducing it to a single sharp demand.

## Turning a limit into a sum you can trust

A limit like $\lim (H_n - \ln n)$ is a promise that *something* settles down, but it does not, by itself, hand you a transparent recipe. The first move is to convert it into a genuine infinite series — and, better still, a series whose every term points the same direction.

Consider, for each whole number $k \ge 1$, the quantity

$$g(k) = \frac{1}{k} - \ln\!\left(1 + \frac{1}{k}\right).$$

Here $1/k$ is the next reciprocal you would add to the harmonic sum, and $\ln(1 + 1/k) = \ln(k+1) - \ln k$ is exactly the amount the logarithm grows over that same step. So $g(k)$ measures the *discrepancy* between counting and the curve at step $k$.

Two facts make this term special.

**It is always positive.** This follows from one of the most useful inequalities in all of analysis: for any $x > 0$,
$$\ln(1 + x) < x.$$
The logarithm of $1+x$ always falls short of $x$ itself. Setting $x = 1/k$ gives $\ln(1 + 1/k) < 1/k$, so $g(k) > 0$ for every $k$. Each step contributes a strictly positive sliver.

**The slivers telescope.** When you add up the first $n$ of them, the logarithms collapse like a folding spyglass — $\ln 2 - \ln 1$, then $\ln 3 - \ln 2$, then $\ln 4 - \ln 3$, and so on — leaving only the outermost survivor:

$$\sum_{k=1}^{n} g(k) = \left( 1 + \frac{1}{2} + \cdots + \frac{1}{n} \right) - \ln(n+1) = H_n - \ln(n+1).$$

This is the heart of the matter. The partial sums of our positive series are *exactly* the harmonic-minus-logarithm quantities that define $\gamma$. Since every term is positive, these partial sums climb steadily upward, never overshooting, and they climb toward the single value they are converging on. We may therefore write, with full confidence,

$$\gamma = \sum_{k=1}^{\infty} \left( \frac{1}{k} - \ln\!\left(1 + \frac{1}{k}\right)\right),$$

a convergent sum of positive terms whose running totals are a sequence of explicit lower bounds creeping up on $\gamma$ from below.

## The same number, drawn as area

There is a second way to see each sliver $g(k)$ — not as a subtraction, but as a region. Over the interval from $k$ to $k+1$, compare two heights: the flat line at height $1/k$ and the gently falling curve $1/y$. At the left end, $y = k$, they touch. As $y$ increases to $k+1$, the curve $1/y$ dips below the flat line. The thin region trapped between them has area

$$\int_{k}^{k+1} \left( \frac{1}{k} - \frac{1}{y} \right)\, dy = \frac{1}{k} - \big(\ln(k+1) - \ln k\big) = g(k).$$

So each term of our series is literally the area of a little curved triangle squeezed between a step and a hyperbola. Stitch all these intervals together and a beautiful picture emerges. Define the **staircase function** $1/\lfloor x \rfloor$, which on each interval $[k, k+1)$ holds steady at the value $1/k$, then drops to $1/(k+1)$ at the next integer. It is the harmonic sum drawn as a staircase descending over the hyperbola $1/x$. The total area trapped between the staircase and the curve, all the way out to infinity, is exactly the Euler–Mascheroni constant:

$$\gamma = \int_{1}^{\infty} \left( \frac{1}{\lfloor x \rfloor} - \frac{1}{x} \right)\, dx.$$

This is one of the constant's most evocative faces. The harmonic numbers are a staircase; the logarithm is a smooth curve; and $\gamma$ is the permanent, finite amount by which the staircase outpaces the curve — the accumulated "overshoot" of discrete counting over continuous growth, drawn as a single sliver of area.

## How fast does the staircase close in?

A representation is only as useful as the speed at which it converges. Here the analysis is sharp and satisfying. The key is a precise upper bound on each sliver. Using the next term of the logarithm's Taylor expansion — $\ln(1+x) = x - \tfrac{x^2}{2} + \cdots$ — one can prove the clean inequality

$$g(k) < \frac{1}{2k^2}.$$

Each sliver shrinks at least as fast as $1/(2k^2)$. Because the leftover tail of the series is dominated by the tail of $\sum 1/(2k^2)$, which a standard comparison bounds by $1/(2n)$, we obtain an explicit error estimate for the approximation:

$$0 < \gamma - \big(H_n - \ln(n+1)\big) = \gamma - \sum_{k=1}^{n} g(k) < \frac{1}{2n}.$$

In words: the $n$-th partial sum underestimates $\gamma$, but never by more than $1/(2n)$. To get $\gamma$ to within one part in a thousand, take roughly five hundred terms. This is honest, certified convergence — not a heuristic, but a guaranteed envelope shrinking to zero at a known rate. (The series converges only polynomially fast, which is why specialists chasing billions of digits use far more aggressive accelerations; but for understanding the constant, the transparent $1/(2n)$ envelope is exactly what one wants.)

## A family with $\gamma$ at its head

The Euler–Mascheroni constant does not live alone. It is the first of an infinite dynasty, the **Stieltjes constants** $\gamma_0, \gamma_1, \gamma_2, \ldots$, defined by the same counting-minus-curve template but with the reciprocals weighted by powers of a logarithm:

$$\gamma_m = \lim_{n\to\infty} \left( \sum_{k=1}^{n} \frac{(\ln k)^m}{k} - \frac{(\ln n)^{m+1}}{m+1} \right).$$

When $m = 0$, the powers of the logarithm collapse to $1$, the correction term becomes $\ln n$, and the formula reads $\sum_{k=1}^n 1/k - \ln n = H_n - \ln n$ — which is precisely our constant. So

$$\gamma_0 = \gamma.$$

The Stieltjes constants are not a curiosity invented for symmetry. They are the coefficients that appear when the Riemann zeta function $\zeta(s)$ — the central object of analytic number theory — is expanded around its one singular point at $s = 1$:

$$\zeta(s) = \frac{1}{s-1} + \sum_{m=0}^{\infty} \frac{(-1)^m}{m!}\,\gamma_m\,(s-1)^m.$$

The simple pole $1/(s-1)$ captures the blow-up; everything finite and subtle about $\zeta$ near that pole is encoded in the Stieltjes constants, with $\gamma$ leading the procession. To understand $\gamma$, then, is to grab the first thread of the zeta function's deepest local structure.

## Why the confession never comes

Now to the secret. Why, with all these clean representations, can we not decide whether $\gamma$ is a fraction?

The answer lies in a principle so simple it sounds like a children's puzzle, yet it powers nearly every irrationality proof ever written — including Apéry's celebrated 1978 proof that $\zeta(3)$ is irrational. The principle is this: **there is no integer strictly between $0$ and $1$.**

Suppose you want to prove some number $x$ is irrational. The strategy is to manufacture, for each $n$, a combination of $x$ with whole-number coefficients,

$$L_n = a_n + b_n\, x \qquad (a_n, b_n \in \mathbb{Z}),$$

and to arrange two things at once: each $L_n$ is *nonzero*, yet the whole sequence $L_n \to 0$. If you can do that, $x$ must be irrational. The reason is exactly the children's puzzle. If $x$ were a fraction $p/q$, then $L_n = a_n + b_n (p/q) = (a_n q + b_n p)/q$ would be a whole number divided by the fixed denominator $q$. A nonzero quantity of that form cannot be smaller than $1/q$ in size — its numerator is a nonzero integer, and the smallest a nonzero integer can be is $1$. So all the $L_n$ would be trapped at distance at least $1/q$ from zero, and they could never sneak down to $0$. The contradiction forces $x$ to be irrational.

What is striking is that this criterion is not merely sufficient — it is an exact *characterization*. A real number $x$ is irrational **if and only if** such nonzero integer linear forms $a_n + b_n x \to 0$ exist. The forward direction is the engine above; the converse follows from Dirichlet's classical theorem on rational approximation, which guarantees that every irrational number is approximated by fractions $p/q$ to within $1/q^2$, far closer than the universal $1/q$ floor that protects rationals. Those exceptionally good approximations are precisely the linear forms that march to zero.

This reframes the open problem with surgical precision. To prove $\gamma$ irrational, one must *construct* integer sequences $a_n, b_n$ with $a_n + b_n \gamma$ nonzero and tending to zero. And here our series shows exactly where the difficulty hides. The harmonic part $H_n$ is friendly: its denominators are completely cleared by multiplying through by the least common multiple of $1, \ldots, n$, an integer whose size the Prime Number Theorem controls precisely (it grows like $e^{n}$). The harmonic numbers are *almost* integers in disguise. But the price of converting $H_n$ into $\gamma$ is the additive correction $\ln(n+1)$ — and the logarithm of an integer is a transcendental, irrational quantity that flatly refuses to be cleared by any common denominator. The obstruction is not the counting. It is the curve.

## The shape of the unknown

So the Euler–Mascheroni constant sits exactly on a fault line in mathematics. On one side is the discrete, integer-friendly world of harmonic sums, where everything can be cleared and counted. On the other is the smooth, transcendental world of the logarithm, where common denominators dissolve. The constant $\gamma$ is the precise, finite measure of the distance between those two worlds — beautifully representable as a positive series, as a sliver of area beneath a staircase, as the head of the Stieltjes dynasty, and as the first coefficient in the local life of the zeta function. We can compute it to billions of digits and bound its approximations to a guaranteed $1/(2n)$. We simply cannot yet say whether it is a fraction.

Most experts are confident it is irrational — probably transcendental. The conjectured path forward is to find integer combinations that simultaneously tame the harmonic denominators *and* approximate the stubborn logarithm closely enough that the exponential common denominator can absorb the error. Recent sharp estimates on both halves of that balance — the size of $\mathrm{lcm}(1, \ldots, n)$ on one side, rational approximations to logarithms on the other — have, for the first time, brought the two error budgets onto the same scale. The number may yet confess. When it does, the proof will turn, as so many before it, on the humble and unbreakable fact that there is no integer between zero and one.
