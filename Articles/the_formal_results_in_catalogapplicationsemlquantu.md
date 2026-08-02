# When a Complex Logarithm Lands Exactly on the Unit Circle

## A small existence theorem with a role in quantum-inspired transformations

The complex logarithm is usually introduced as the inverse of the exponential. Yet unlike the real logarithm, it does more than record size: it records angle as well. That dual role makes it a natural ingredient in transformations built from rotations, phases, and unitary operators—the mathematical language of quantum dynamics.

Consider the vertical line in the complex plane consisting of the points

$$
1+ti,\qquad t\in\mathbb{R},
$$

where $i^2=-1$. Apply the principal complex logarithm to each point and ask a geometric question: **does the resulting curve ever touch the unit circle?** In symbols, is there a nonzero real number $t$ such that

$$
\left|\log(1+ti)\right|=1?
$$

The answer is yes. More precisely, at least one positive solution lies in the explicit interval $[1/2,3]$, and reflection supplies a negative solution as well. At either solution, the logarithm is not merely a complex number of a convenient size: it is a unitary scalar, meaning that multiplication by it preserves complex lengths.

This result is an existence theorem, not a numerical coincidence. Its proof combines the geometry of the principal logarithm, two endpoint estimates, continuity, and symmetry.

## Why the question matters

A complex scalar $z$ is unitary exactly when

$$
\overline z z=z\overline z=1,
$$

which is equivalent to $|z|=1$. Such numbers are pure phases: multiplying by them rotates the complex plane without stretching it. In matrix mathematics, unitary matrices play the same role in higher dimensions. They preserve inner products, probabilities, and norms, which is why they govern closed quantum evolution and appear throughout signal processing, numerical linear algebra, and quantum-inspired machine learning.

One proposed family of nonlinear transformations has the schematic form

$$
\exp(iH_1)\,\log(I+iH_2),
$$

where $H_1$ and $H_2$ are Hermitian operators and $I$ is the identity. The exponential factor $\exp(iH_1)$ is unitary. The logarithmic factor is subtler: it need not be unitary, and it may even vanish. For example, if $H_2=0$, then $\log(I)=0$, so the entire product is zero rather than unitary.

This makes the scalar problem a clean first test. If $H_2=tI$, then the logarithmic factor becomes the scalar $\log(1+ti)$ times the identity. Finding $t$ with $|\log(1+ti)|=1$ therefore identifies a nontrivial parameter for which this factor is unitary. It does not by itself solve every matrix-coverage question, but it isolates and resolves an essential analytic step.

## What the principal logarithm does

For a nonzero complex number $z$, the principal logarithm is

$$
\log z=\ln|z|+i\operatorname{Arg}(z),
$$

where the principal argument $\operatorname{Arg}(z)$ lies in $(-\pi,\pi]$. Along the line $z=1+ti$, the real part is always positive. The line never meets the nonpositive real axis, where the principal logarithm has its branch cut. Consequently, the logarithm varies continuously for every real $t$.

Because

$$
|1+ti|=\sqrt{1+t^2}
$$

and, for this right-half-plane line,

$$
\operatorname{Arg}(1+ti)=\arctan t,
$$

we obtain the explicit identity

$$
\left|\log(1+ti)\right|^2
=
\left(\ln\sqrt{1+t^2}\right)^2+(\arctan t)^2.
$$

Define the real-valued function

$$
F(t)=\left|\log(1+ti)\right|.
$$

The problem becomes finding a point where $F(t)=1$. Geometrically, $t\mapsto\log(1+ti)$ traces a curve in the logarithm plane, and $F(t)$ measures the curve’s distance from the origin.

## The first landmark: inside at $t=1/2$

At $t=1/2$, the logarithm remains safely inside the unit circle. To see this without decimals, use the integral identity $\log(1+z)=\int_0^1 z/(1+sz)\,ds$ for $|z|<1$. Since $|1+sz|\geq1-s|z|$, it gives

$$
|\log(1+z)|\leq\int_0^1\frac{|z|}{1-s|z|}\,ds=-\ln(1-|z|).
$$

For $z=i/2$, this yields $|\log(1+i/2)|\leq\ln2$. The elementary bound $\ln2<3/4$ follows, for example, by integrating $1/x$ on $[1,2]$ and bounding it above by the trapezoidal area $3/4$; strictness follows because $1/x$ is strictly convex and not linear. Hence

$$
\left|\log\left(1+\frac{i}{2}\right)\right|<\frac34<1.
$$

Thus

$$
F\left(\frac12\right)<1.
$$

The exact numerical value is not important for the theorem. What matters is a strict inequality certified by a simple rational bound. The curve begins on the inside of the circle at the left endpoint of the chosen interval.

## The second landmark: outside at $t=3$

At $t=3$, it is enough to examine only the real part of the logarithm. Since

$$
|1+3i|=\sqrt{10},
$$

we have

$$
\operatorname{Re}\log(1+3i)=\ln\sqrt{10}.
$$

Now $e<3<\sqrt{10}$, so monotonicity of the real logarithm gives

$$
1=\ln e<\ln\sqrt{10}.
$$

The modulus of a complex number is at least the absolute value of its real part. Therefore

$$
1<\left|\operatorname{Re}\log(1+3i)\right|
\leq \left|\log(1+3i)\right|=F(3).
$$

At the right endpoint, the logarithmic curve lies outside the unit circle.

## The crossing theorem

We can now state the central result.

**Scalar Logarithmic Unit-Circle Theorem.** There exists a real number $t$ such that

$$
\frac12\leq t\leq 3,
\qquad t\neq0,
\qquad
\left|\log(1+ti)\right|=1.
$$

**Why it is true.** The function $F(t)=|\log(1+ti)|$ is continuous on the interval $[1/2,3]$. The endpoint estimates show that

$$
F\left(\frac12\right)<1<F(3).
$$

By the intermediate value theorem, a continuous function passing from below $1$ to above $1$ must equal $1$ somewhere in between. Because the whole interval is positive, the resulting $t$ is automatically nonzero.

The argument is pleasingly robust. It does not depend on guessing a decimal approximation to the root, and it does not assume the function is monotone. Continuity and opposite endpoint inequalities are enough.

## Every positive crossing has a mirror image

The picture has an exact symmetry. Complex conjugation sends

$$
1+ti\longmapsto 1-ti.
$$

Neither point lies on the branch cut, and the principal logarithm respects conjugation there:

$$
\log(1-ti)=\overline{\log(1+ti)}.
$$

Conjugation preserves modulus, so

$$
F(-t)=\left|\log(1-ti)\right|
=\left|\overline{\log(1+ti)}\right|
=F(t).
$$

Thus $F$ is even.

**Reflection Theorem.** For every real $t$,

$$
\left|\log(1-ti)\right|=\left|\log(1+ti)\right|.
$$

Consequently, if a positive $t$ satisfies $|\log(1+ti)|=1$, then $-t$ does too. The existence theorem therefore gives a matched pair of solutions, one on each side of the real axis.

## From unit modulus to a unitary scalar

Let

$$
z=\log(1+ti)
$$

at one of the crossing parameters. Since $|z|=1$ and $|z|^2=z\overline z$, we obtain

$$
z\overline z=\overline z z=1.
$$

This proves the final structural statement.

**Unitary Scalar Corollary.** There exists a nonzero real $t$ such that $\log(1+ti)$ is a unitary complex scalar.

Multiplication by this logarithm is therefore an exact rotation, with no amplification or attenuation. In a matrix setting, the scalar matrix $\log(1+ti)I$ should likewise act unitarily; establishing that lift in the desired operator framework is a natural next step.

## What has—and has not—been established

The theorem resolves the scalar intersection question completely at the level of existence. It gives:

1. a continuous scalar norm function $F(t)=|\log(1+ti)|$;
2. a certified positive interval $[1/2,3]$ containing a solution;
3. a negative partner for every positive solution; and
4. a genuine unitary scalar logarithmic factor.

It does not claim that the positive solution is unique. Numerical exploration suggests a much tighter location, but a numerical estimate is different from an analytic enclosure. Proving strict monotonicity of $F$ on $(0,\infty)$ would immediately establish uniqueness. From the explicit formula, that goal amounts to controlling the derivative of

$$
F(t)^2=rac14\ln^2(1+t^2)+(\arctan t)^2.
$$

Nor does the scalar theorem alone prove that every unitary matrix can be represented by the full exponential-logarithmic expression. That broader objective also requires a matrix theorem asserting that every finite-dimensional unitary matrix is the exponential of $iH$ for some Hermitian $H$, together with careful bookkeeping of scalar phases, determinants, and traces.

For determinant-one matrices such as those in $SU(2)$, the trace of the Hermitian generator controls the determinant of its exponential. Identifying the exact congruence condition modulo $2\pi$ is therefore part of the next layer of the problem.

A second route is normalization. Given an invertible logarithmic factor $L$, its polar normalization

$$
L(L^*L)^{-1/2}
$$

is expected to be unitary. This would replace the search for naturally unitary logarithms with a systematic method for turning invertible ones into unitary factors.

## A numerical window onto the geometry

Although the theorem needs no decimal approximation, computation helps make the crossing visible. For a chosen $t$, one evaluates

$$
F(t)=\sqrt{\frac14\ln^2(1+t^2)+(\arctan t)^2}.
$$

Sampling this function across $[1/2,3]$ produces a curve that starts below the horizontal line $F=1$ and ends above it. A bisection search then repeatedly halves an interval whose endpoint values straddle $1$. After $n$ steps, the initial width $5/2$ has shrunk to

$$
\frac{5}{2^{n+1}}.
$$

This is an excellent exploratory instrument, but its logical role should remain clear. Decimal sampling suggests where a root lies; the analytic endpoint bounds and continuity establish that a root must exist. Computation can guide a sharper conjecture—perhaps a much narrower rational interval—while proof explains why no rounding error can erase the crossing.

The same visualization shows the reflection symmetry immediately. Plotting $F(t)$ over a symmetric range produces a mirror image about the vertical axis. In the logarithm plane, the two points $\log(1+ti)$ and $\log(1-ti)$ are complex conjugates: one lies above the real axis and the other equally far below it. Their distances from the origin agree exactly.

## A bridge from elementary analysis to operator design

The core proof uses ingredients familiar from a first course in analysis: continuity, endpoint bounds, conjugation, and the intermediate value theorem. Yet the conclusion speaks directly to the design of phase-preserving transformations.

That is the larger lesson. Before asking whether an elaborate operator formula covers an entire matrix group, one can isolate a scalar slice and study its geometry exactly. Here the vertical line $1+ti$ becomes a curve under the complex logarithm. One point of that curve is provably inside the unit circle, another is provably outside, and continuity forces a crossing. Symmetry doubles it. The elementary identity $|z|=1$ then turns the crossing into unitarity.

A modest one-dimensional theorem thus supplies a concrete building block for a higher-dimensional program: choose a logarithmic factor that is already a pure phase, then investigate how Hermitian exponentials can steer that phase across the unitary group. The crossing is small, exact, and strategically placed—the kind of result from which a larger theory can grow.
