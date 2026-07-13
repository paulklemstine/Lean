# The Logistic Map Is a Chebyshev Polynomial: An Exact Bridge Between Chaos and Orthogonal Polynomials

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

The logistic map $f(x) = 4x(1-x)$ at its fully chaotic parameter is the canonical
example of a smooth one-dimensional dynamical system with sensitive dependence on
initial conditions. The Chebyshev polynomials $T_m$, defined by
$T_m(\cos\theta) = \cos(m\theta)$, are foundational objects of approximation theory
and the theory of orthogonal polynomials. We prove that these two worlds coincide
exactly: the $n$-fold iterate of the logistic map equals a rescaled Chebyshev
polynomial of degree $2^{n}$,

$$f^{n}(x) = \frac{1 - T_{2^{n}}(1 - 2x)}{2}, \qquad \text{for every } x \in \mathbb{R}.$$

The identity is established first on the unit interval through the substitution
$x = \sin^2\varphi$, which conjugates the logistic map to angle doubling
$\varphi \mapsto 2\varphi$, and is then promoted to an identity of polynomials — valid
for all real (and complex) arguments — by the principle that polynomials agreeing at
infinitely many points are equal. As corollaries we obtain the exact algebraic depth
$\deg f^{n} = 2^{n}$, read directly from the Chebyshev degree, and a trigonometric
route to counting periodic points. We prove the base cases $n = 1$ and $n = 2$ of the
conjectured periodic-point law: $f$ has exactly $2 = 2^1$ fixed points $\{0, 3/4\}$,
and $f^{2}$ has exactly $4 = 2^2$ fixed points $\{0,\ 3/4,\ (5-\sqrt5)/8,\ (5+\sqrt5)/8\}$,
the latter obtained from the exact factorisation
$f^{2}(x) - x = -4x(x-\tfrac34)(16x^2 - 20x + 5)$.

## 1. Introduction

The logistic map $f(x) = 4x(1-x)$ is among the most studied dynamical systems in
mathematics and the sciences. On the unit interval $[0,1]$ it is a two-to-one,
measure-theoretically mixing transformation whose iterates exhibit the full apparatus
of deterministic chaos: exponential separation of nearby orbits, dense periodic
points, and topological transitivity. It served historically as the primary example
through which chaos, period-doubling cascades, and universal scaling entered the
scientific mainstream.

Chebyshev polynomials of the first kind, $T_m$, occupy an entirely different corner of
mathematics. They are the orthogonal polynomials for the weight $(1-t^2)^{-1/2}$ on
$[-1,1]$, they minimise the sup-norm among monic polynomials of fixed degree, and they
are indispensable in numerical analysis and approximation theory. Their defining
identity, $T_m(\cos\theta) = \cos(m\theta)$, encodes a semigroup structure under
composition: $T_m \circ T_k = T_{mk}$.

This paper makes precise, and proves, the sense in which the logistic map's dynamics
*are* the Chebyshev polynomials. The bridge is a classical conjugacy — angle doubling —
made exact and pushed to a statement about polynomials. Everything below is elementary
in its ingredients (double-angle formulas, the Chebyshev identity, the rigidity of
polynomials) yet the conclusion is striking: a chaotic smooth system's iterates are,
literally, orthogonal polynomials, and the exponential complexity of chaos is exactly
the index $2^{n}$ of a Chebyshev polynomial.

## 2. Definitions and preliminaries

**Definition 2.1 (Logistic map).** The *logistic map* is the function
$f:\mathbb{R}\to\mathbb{R}$ defined by $f(x) = 4x(1-x)$. Its restriction to $[0,1]$
maps the interval onto itself. We write $f^{n} = f \circ \cdots \circ f$ ($n$ times)
for the $n$-fold iterate, with $f^{0} = \mathrm{id}$.

**Definition 2.2 (Chebyshev polynomials of the first kind).** The polynomials
$T_m \in \mathbb{R}[X]$, $m \ge 0$, are determined by $T_0 = 1$, $T_1 = X$, and the
recurrence $T_{m+1} = 2X\,T_m - T_{m-1}$. They satisfy the characterising
trigonometric identity

$$T_m(\cos\theta) = \cos(m\theta), \qquad \theta \in \mathbb{R},$$

and $\deg T_m = m$ with leading coefficient $2^{m-1}$ for $m \ge 1$.

We record two elementary trigonometric identities used throughout:

- **Double angle:** $\sin(2\varphi) = 2\sin\varphi\cos\varphi$ and
  $\cos(2\varphi) = 1 - 2\sin^2\varphi$.
- **Half angle (power reduction):** $\sin^2\alpha = \dfrac{1 - \cos(2\alpha)}{2}$.

## 3. Semiconjugacy to angle doubling

The engine of the whole theory is that, in the coordinate $x = \sin^2\varphi$, the
logistic map is angle doubling.

**Theorem 3.1 (Semiconjugacy).** For all $\varphi \in \mathbb{R}$,

$$f(\sin^2\varphi) = \sin^2(2\varphi).$$

*Proof.* Using $1 - \sin^2\varphi = \cos^2\varphi$ and the double-angle formula,

$$f(\sin^2\varphi) = 4\sin^2\varphi(1 - \sin^2\varphi) = 4\sin^2\varphi\cos^2\varphi = (2\sin\varphi\cos\varphi)^2 = \sin^2(2\varphi). \qquad\square$$

Iterating Theorem 3.1 shows that applying $f$ a total of $n$ times multiplies the
angle by $2^{n}$.

**Theorem 3.2 (Iterated semiconjugacy).** For all $n \in \mathbb{N}$ and
$\varphi \in \mathbb{R}$,

$$f^{n}(\sin^2\varphi) = \sin^2(2^{n}\varphi).$$

*Proof.* Induction on $n$. The base case $n = 0$ is $f^{0}(\sin^2\varphi) = \sin^2\varphi = \sin^2(2^0\varphi)$.
For the inductive step, assume the claim for $k$. Then, using
$f^{k+1} = f \circ f^{k}$, the inductive hypothesis, and Theorem 3.1,

$$f^{k+1}(\sin^2\varphi) = f\bigl(f^{k}(\sin^2\varphi)\bigr) = f\bigl(\sin^2(2^{k}\varphi)\bigr) = \sin^2\bigl(2\cdot 2^{k}\varphi\bigr) = \sin^2(2^{k+1}\varphi). \qquad\square$$

## 4. The Chebyshev identity

We now connect the doubled-angle picture to the Chebyshev polynomials.

**Theorem 4.1.** For all $n \in \mathbb{N}$ and $\varphi \in \mathbb{R}$,

$$\sin^2(2^{n}\varphi) = \frac{1 - T_{2^{n}}(\cos 2\varphi)}{2}.$$

*Proof.* By the half-angle identity with $\alpha = 2^{n}\varphi$,

$$\sin^2(2^{n}\varphi) = \frac{1 - \cos(2\cdot 2^{n}\varphi)}{2} = \frac{1 - \cos(2^{n+1}\varphi)}{2}.$$

By the Chebyshev identity with $m = 2^{n}$ and $\theta = 2\varphi$,

$$T_{2^{n}}(\cos 2\varphi) = \cos(2^{n}\cdot 2\varphi) = \cos(2^{n+1}\varphi).$$

Substituting proves the claim. $\qquad\square$

Combining Theorems 3.2 and 4.1 gives the iterate on $[0,1]$ in Chebyshev form.

**Corollary 4.2 (Iterate on the unit interval).** For every $n \in \mathbb{N}$ and
every $x \in [0,1]$,

$$f^{n}(x) = \frac{1 - T_{2^{n}}(1 - 2x)}{2}.$$

*Proof.* Given $x \in [0,1]$, choose $\varphi = \arcsin\sqrt{x} \in [0,\pi/2]$, so that
$\sin\varphi = \sqrt{x}$ and $\sin^2\varphi = x$. Then $f^{n}(x) = f^{n}(\sin^2\varphi) = \sin^2(2^{n}\varphi)$
by Theorem 3.2, which equals $\tfrac12\bigl(1 - T_{2^{n}}(\cos 2\varphi)\bigr)$ by
Theorem 4.1. Finally $\cos 2\varphi = 1 - 2\sin^2\varphi = 1 - 2x$. $\qquad\square$

## 5. The polynomial bridge

Corollary 4.2 is an identity of *functions on $[0,1]$*. We upgrade it to an identity of
*polynomials*, valid for all real (indeed complex) $x$.

**Definition 5.1 (Chebyshev description).** Let

$$C_n(X) := \frac{1}{2} - \frac{1}{2}\,T_{2^{n}}(1 - 2X) \in \mathbb{R}[X],$$

so that $C_n(x) = \tfrac12\bigl(1 - T_{2^{n}}(1-2x)\bigr)$ for every real $x$.

**Definition 5.2 (Polynomial iterate).** Let $P_0(X) = X$ and
$P_{n+1}(X) = F(P_n(X))$ where $F(X) = 4X(1-X)$ is the logistic polynomial. By
construction $P_n(x) = f^{n}(x)$ for every real $x$, since polynomial composition
evaluates to functional composition.

**Theorem 5.3 (The iterate is a Chebyshev polynomial).** As elements of
$\mathbb{R}[X]$,

$$P_n = C_n.$$

*Proof.* By Corollary 4.2 and Definition 5.2, the polynomials $P_n$ and $C_n$ take
equal values at every point of $[0,1]$. The interval $[0,1]$ is infinite, and two
polynomials over a field (here $\mathbb{R}$, an integral domain) that agree at
infinitely many points must be equal: their difference $P_n - C_n$ has infinitely many
roots, hence is the zero polynomial. Therefore $P_n = C_n$. $\qquad\square$

**Theorem 5.4 (The bridge).** For every $n \in \mathbb{N}$ and *every* $x \in \mathbb{R}$,

$$f^{n}(x) = \frac{1 - T_{2^{n}}(1 - 2x)}{2}.$$

*Proof.* Evaluate the polynomial identity of Theorem 5.3 at $x$ and use
$P_n(x) = f^{n}(x)$ and $C_n(x) = \tfrac12(1 - T_{2^{n}}(1-2x))$. $\qquad\square$

Theorem 5.4 is the central result. It exhibits every iterate of the chaotic logistic
map as a single, classical, rescaled Chebyshev polynomial — an *exact* closed form,
not an approximation, holding on all of $\mathbb{R}$.

## 6. Algebraic depth via the Chebyshev degree

The exponential growth of the iterates' algebraic complexity is now a one-line
consequence of the Chebyshev degree.

**Theorem 6.1 (Degree of the Chebyshev description).** For all $n \in \mathbb{N}$,
$\deg C_n = 2^{n}$.

*Proof.* $T_{2^{n}}$ has degree $2^{n}$. Precomposition with the affine map
$X \mapsto 1 - 2X$ preserves degree, so $T_{2^{n}}(1-2X)$ has degree $2^{n}$; scaling
by $-\tfrac12$ and adding the constant $\tfrac12$ (of degree $0 < 2^{n}$) does not
change the degree. Hence $\deg C_n = 2^{n}$. $\qquad\square$

**Theorem 6.2 (Exponential algebraic depth).** For all $n \in \mathbb{N}$,

$$\deg f^{n} = \deg P_n = 2^{n}.$$

*Proof.* Immediate from Theorems 5.3 and 6.1. $\qquad\square$

Thus the folklore that "$f^{n}$ has degree $2^{n}$" is exactly the statement that
$\deg T_{2^{n}} = 2^{n}$. The exponential stretching of the dynamics (the factor $2^n$
by which angles are multiplied) and the exponential growth of algebraic complexity are
the same number.

## 7. Periodic points and the $2^{n}$ law

A point $x$ has period dividing $n$ when $f^{n}(x) = x$; these are the fixed points of
$f^{n}$ and form the periodic skeleton of the dynamics. By Theorem 5.4 the fixed-point
equation on $[0,1]$ becomes $T_{2^{n}}(1-2x) = 1-2x$; writing $x = \sin^2\varphi$ this
is the trigonometric equation

$$\cos(2^{n+1}\varphi) = \cos(2\varphi),$$

whose solution count in one period is exactly $2^{n}$. This is the conjectured
**$2^{n}$ law**: $f$ has precisely $2^{n}$ points of period dividing $n$. We settle the
first two cases exactly.

**Theorem 7.1 (Fixed points, $n=1$).** The set of fixed points of $f$ is
$\{0,\ 3/4\}$; in particular $f$ has exactly $2 = 2^{1}$ fixed points.

*Proof.* $f(x) = x$ means $4x(1-x) = x$, i.e. $x(3 - 4x) = 0$, whose roots are $x = 0$
and $x = 3/4$. These are distinct, giving cardinality $2$. $\qquad\square$

**Theorem 7.2 (Fixed points of $f^{2}$, $n=2$).** The set of fixed points of $f^{2}$
is

$$\left\{\,0,\ \tfrac{3}{4},\ \frac{5-\sqrt5}{8},\ \frac{5+\sqrt5}{8}\,\right\},$$

so $f^{2}$ has exactly $4 = 2^{2}$ fixed points.

*Proof.* A direct expansion yields the exact factorisation

$$f^{2}(x) - x = -4\,x\,\Bigl(x - \tfrac34\Bigr)\bigl(16x^2 - 20x + 5\bigr).$$

The factors $x$ and $x - 3/4$ give the period-one points $0$ and $3/4$. The quadratic
$16x^2 - 20x + 5$ has discriminant $400 - 320 = 80$, hence roots
$x = \dfrac{20 \pm \sqrt{80}}{32} = \dfrac{5 \pm \sqrt5}{8}$, a genuine period-two
orbit. Since $\sqrt5 > 0$, all four roots are distinct, giving cardinality $4$.
$\qquad\square$

The appearance of $\sqrt5$ ties the period-two orbit to the arithmetic of the regular
pentagon and the golden ratio. Both cases confirm the $2^{n}$ count.

## 8. Algorithms

The bridge yields exact symbolic and numerical procedures.

**Algorithm A (Chebyshev evaluation of the iterate).** To compute $f^{n}(x)$ for any
real $x$ without composing $f$ with itself: set $t = 1 - 2x$, evaluate $T_{2^{n}}(t)$
by the recurrence $T_0 = 1, T_1 = t, T_{k+1} = 2t\,T_k - T_{k-1}$ up to index $2^{n}$
(or by repeated composition $T_2\circ\cdots$ exploiting $T_{2m} = T_2\circ T_m$), and
return $(1 - T_{2^{n}}(t))/2$. This makes the closed form of Theorem 5.4 executable.

**Algorithm B (Angle-doubling orbit).** Given $x_0 \in [0,1]$, set
$\varphi_0 = \arcsin\sqrt{x_0}$ and iterate $\varphi_{k+1} = 2\varphi_k$; then
$f^{k}(x_0) = \sin^2\varphi_k$. This exhibits the orbit as pure angle doubling and
makes the exponential sensitivity manifest.

**Algorithm C (Periodic-point enumeration).** For period dividing $n$, solve
$\cos(2^{n+1}\varphi) = \cos(2\varphi)$ over one period, or equivalently find the roots
of the degree-$2^{n}$ polynomial $f^{n}(x) - x$; the theory predicts exactly $2^{n}$
roots in $[0,1]$.

## 9. Applications and discussion

**Transfer of tools.** Because iterates are Chebyshev polynomials, the mature toolkit
of orthogonal-polynomial theory — orthogonality relations, three-term recurrences,
extremal properties, root distributions (arcsine law) — becomes available for the
study of the logistic map's iterates, and conversely dynamical intuition (angle
doubling, symbolic coding) informs the polynomials.

**Invariant measure.** The arcsine distribution $\frac{1}{\pi\sqrt{x(1-x)}}\,dx$ on
$[0,1]$ is the invariant measure of the logistic map. It is precisely the pushforward
of the uniform measure on angles under $x = \sin^2\varphi$, and it is exactly the
Chebyshev orthogonality weight (after the affine change $x \mapsto 1 - 2x$). The
statistics of chaos and the orthogonality of the polynomials are one measure.

**Exact computation.** The closed form gives, for any $n$, a single-polynomial
description of the $n$-th iterate valid for all inputs, sidestepping the numerical
instability of naive iteration when only symbolic or high-precision endpoint values
are needed.

## 10. Future work

The immediate open problem is the inductive step of the $2^{n}$ law for general $n$,
formalising the count of solutions of $\cos(2^{n+1}\varphi) = \cos(2\varphi)$ — either
through the sawtooth geometry of the associated tent-map iterate or through the root
structure of $T_{2^{n}}$. A second direction is the systematic transfer of the
invariant (arcsine) measure between the two settings and the exploitation of Chebyshev
orthogonality to compute dynamical averages exactly. More broadly, one may ask which
other polynomial families arise as exact iterates of natural smooth maps, and whether
the Chebyshev semigroup law $T_m \circ T_k = T_{mk}$ has dynamical analogues beyond the
doubling case.

## 11. Conclusion

The logistic map at full chaos and the Chebyshev polynomials of approximation theory
are, iterate by iterate, the same functions: $f^{n}(x) = \tfrac12(1 - T_{2^{n}}(1-2x))$
for all real $x$. The identity follows from a single change of coordinates that
converts the map into angle doubling, and its promotion to a polynomial identity gives
exact degree and periodic-point information. Chaos and classical structure prove to be
two readings of one arithmetic fact — multiplication of an angle by $2^{n}$.
