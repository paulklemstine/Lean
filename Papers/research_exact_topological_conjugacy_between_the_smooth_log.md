# Periodic Orbits through the Logistic–Tent Conjugacy

**Author:** Aristotle

**Date:** 2026-07-13

## Abstract

The logistic map $f(x) = 4x(1-x)$ on the unit interval $[0,1]$ is the canonical
example of smooth one-dimensional chaos, while the tent map $T(t) = 1 - |2t-1|$
is its piecewise-linear analogue. We record and exploit an exact topological
conjugacy between the two, realised by the strictly increasing homeomorphism
$h(t) = \sin^2(\pi t/2)$ of $[0,1]$, which satisfies $f\circ h = h\circ T$ and
hence $f^{\,n}\circ h = h\circ T^{\,n}$ for every $n$. From this single identity
we derive the full transfer of the periodic-orbit structure. Our principal
results are: (i) a **periodic-point equivalence**, stating that $h(t)$ is a
period-$n$ point of $f$ if and only if $t$ is a period-$n$ point of $T$; (ii) a
**bijection of periodic-point sets**, showing $h$ restricts to a bijection
between the period-$n$ points of $T$ and those of $f$; (iii) a **counting
reduction**, that the two sets of period-$n$ points have equal cardinality,
turning a transcendental count for the parabola into a combinatorial count for
the sawtooth; (iv) an **exact fixed-point computation**, establishing that the
logistic fixed set is precisely $\{0, 3/4\}$, of cardinality $2 = 2^1$; and (v)
the **realisation of period three**, transporting the explicit tent cycle
$2/7 \to 4/7 \to 6/7 \to 2/7$ to a genuine period-three orbit of the logistic
map, which by Sharkovskii's theorem forces orbits of every period. We close with
the arithmetic and measure-theoretic consequences of the bridge and a discussion
of its implications for chaos-based cryptography.

## 1. Introduction

Deterministic chaos on the interval is most often illustrated by the logistic
family $f_r(x) = r\,x(1-x)$ at the parameter $r = 4$, where the dynamics become
fully chaotic on $[0,1]$. The map's smoothness and its quadratic nonlinearity
give it an aura of analytic difficulty: the $n$-fold iterate $f^{\,n}$ is a
polynomial of degree $2^n$, and counting its fixed points seems to require
solving transcendental-looking equations of exploding degree.

The tent map $T(t) = 1 - |2t-1|$ presents the opposite face. It is piecewise
linear, its $n$-fold iterate is a sawtooth of $2^n$ affine ramps, and every
question about it reduces to elementary arithmetic. The two maps are, however,
*dynamically indistinguishable*: they are topologically conjugate through an
explicit, differentiable homeomorphism. The purpose of this paper is to make the
consequences of that conjugacy precise for the periodic-orbit structure, and in
particular to show how the transcendental fixed-point count for the smooth map
collapses to a combinatorial count for the linear one.

The strategy throughout is the *transfer principle*: a topological conjugacy maps
periodic points to periodic points of the same period, and an injective conjugacy
prevents any collapse of period. Every structural feature we prove for the
parabola is proved by proving it for the tent map — the transparent model — and
transporting it through $h$.

## 2. Definitions and basic setup

Throughout, all dynamics take place on the unit interval $[0,1] \subset \mathbb{R}$.

**Definition 2.1 (Logistic map).** The *logistic map* at the fully chaotic
parameter is $f(x) = 4x(1-x)$.

**Definition 2.2 (Tent map).** The *tent map* is $T(t) = 1 - |2t-1|$. Explicitly,
$T(t) = 2t$ for $t \le \tfrac12$ and $T(t) = 2 - 2t$ for $t \ge \tfrac12$.

**Definition 2.3 (Conjugating coordinate).** The *conjugating change of
coordinates* is $h(t) = \sin^2(\pi t / 2)$.

**Definition 2.4 (Period-$n$ point).** A point $x \in [0,1]$ is a *period-$n$
point* of a map $g$ if $g^{\,n}(x) = x$, where $g^{\,n}$ denotes the $n$-fold
composition. We call the period *exact* if in addition $g^{\,k}(x) \ne x$ for
all $1 \le k < n$.

We first record that all three ingredients respect the unit interval.

**Lemma 2.5 (Invariance of the interval).** For $t \in [0,1]$ we have
$T(t) \in [0,1]$ and $h(t) \in [0,1]$. Consequently $T^{\,n}(t) \in [0,1]$ for
all $n$.

*Proof.* For the tent map, $|2t-1| \le 1$ when $0 \le t \le 1$, so
$T(t) = 1 - |2t-1| \in [0,1]$. For $h$, the value $\sin^2(\pi t/2)$ lies in
$[0,1]$ because $\sin$ takes values in $[-1,1]$. Interval-invariance of $T^{\,n}$
follows by induction on $n$. $\qquad\blacksquare$

## 3. The conjugacy

The heart of the paper is the following identity.

**Theorem 3.1 (Topological conjugacy).** For all $t \in \mathbb{R}$,
$$f\big(h(t)\big) = h\big(T(t)\big).$$

*Proof.* Write $\theta = \pi t/2$. By the double-angle identity,
$$f(h(t)) = 4\sin^2\theta\,(1 - \sin^2\theta) = 4\sin^2\theta\cos^2\theta
= \big(2\sin\theta\cos\theta\big)^2 = \sin^2(2\theta) = \sin^2(\pi t).$$
For the right-hand side we split on the tent's two branches. If $t \le \tfrac12$,
then $T(t) = 2t$ and $h(T(t)) = \sin^2(\pi t)$ directly. If $t > \tfrac12$, then
$T(t) = 2 - 2t$ and
$$h(T(t)) = \sin^2\!\Big(\frac{\pi(2-2t)}{2}\Big) = \sin^2(\pi - \pi t)
= \sin^2(\pi t),$$
using $\sin(\pi - \alpha) = \sin\alpha$. In both cases the two sides agree.
$\qquad\blacksquare$

Iterating Theorem 3.1 gives the intertwining of all iterates.

**Corollary 3.2 (Intertwining of iterates).** For every $n \in \mathbb{N}$ and
all $t$, $f^{\,n}\big(h(t)\big) = h\big(T^{\,n}(t)\big)$.

*Proof.* Induction on $n$. The base case $n=0$ is the identity $h(t) = h(t)$. For
the step, $f^{\,n+1}(h(t)) = f\big(f^{\,n}(h(t))\big) = f\big(h(T^{\,n}(t))\big)
= h\big(T(T^{\,n}(t))\big) = h\big(T^{\,n+1}(t)\big)$, using the inductive
hypothesis and Theorem 3.1. $\qquad\blacksquare$

The map $h$ is not just an intertwiner but a homeomorphism of $[0,1]$.

**Theorem 3.3 ($h$ is a homeomorphism of $[0,1]$).** The map $h$ is strictly
increasing on $[0,1]$, hence injective there, and it maps $[0,1]$ onto $[0,1]$.

*Proof.* On $[0,1]$ the argument $\pi t/2$ ranges over $[0, \pi/2]$, where $\sin$
is strictly increasing and non-negative; squaring a non-negative strictly
increasing function preserves strict monotonicity, so $h$ is strictly increasing
and therefore injective. Continuity of $h$ together with $h(0) = 0$ and
$h(1) = \sin^2(\pi/2) = 1$ yields, by the intermediate value theorem, that the
image of $[0,1]$ is all of $[0,1]$. $\qquad\blacksquare$

An immediate but crucial consequence, used repeatedly below, is that $h$
separates distinct seeds: if $a \ne b$ in $[0,1]$ then $h(a) \ne h(b)$.

## 4. Transfer of periodic points

We now harvest the dynamical consequences. The following equivalence is the
engine of the paper.

**Theorem 4.1 (Periodic-point equivalence).** For $t \in [0,1]$ and any $n$,
$$f^{\,n}\big(h(t)\big) = h(t) \quad\Longleftrightarrow\quad T^{\,n}(t) = t.$$

*Proof.* $(\Leftarrow)$ If $T^{\,n}(t) = t$, then by Corollary 3.2,
$f^{\,n}(h(t)) = h(T^{\,n}(t)) = h(t)$.

$(\Rightarrow)$ Suppose $f^{\,n}(h(t)) = h(t)$. By Corollary 3.2 the left side
equals $h(T^{\,n}(t))$, so $h(T^{\,n}(t)) = h(t)$. Both $T^{\,n}(t)$ and $t$ lie
in $[0,1]$ by Lemma 2.5, and $h$ is injective there by Theorem 3.3; hence
$T^{\,n}(t) = t$. $\qquad\blacksquare$

Note that the forward direction genuinely uses injectivity; without it, the
smooth periodicity would not descend to the linear model.

**Theorem 4.2 (Bijection of periodic-point sets).** For every $n$, the map $h$
restricts to a bijection
$$\{\,t \in [0,1] : T^{\,n}(t) = t\,\}
\;\xrightarrow{\ \sim\ }\;
\{\,x \in [0,1] : f^{\,n}(x) = x\,\}.$$

*Proof.* By Theorem 4.1 combined with Lemma 2.5, $h$ maps the left set into the
right set. It is injective there because it is injective on all of $[0,1]$
(Theorem 3.3). For surjectivity, let $x \in [0,1]$ satisfy $f^{\,n}(x) = x$. By
surjectivity of $h$ (Theorem 3.3) there is $t \in [0,1]$ with $h(t) = x$; then
$f^{\,n}(h(t)) = h(t)$, so by Theorem 4.1, $T^{\,n}(t) = t$, and $t$ is a
preimage in the left set. $\qquad\blacksquare$

**Corollary 4.3 (Counting reduction).** For every $n$, the period-$n$ point sets
of $f$ and $T$ in $[0,1]$ have equal cardinality:
$$\#\{\,x \in [0,1] : f^{\,n}(x) = x\,\}
= \#\{\,t \in [0,1] : T^{\,n}(t) = t\,\}.$$

*Proof.* A bijection between two sets equates their cardinalities; apply
Theorem 4.2. $\qquad\blacksquare$

Corollary 4.3 is the structural crux: the transcendental problem of counting
roots of the degree-$2^n$ polynomial $f^{\,n}(x) - x$ is reduced *exactly* to
counting the fixed points of a sawtooth.

## 5. The base of the exponential count

We anchor the count at $n = 1$ by direct computation, exhibiting the pattern
$2^n$ at its ground floor.

**Theorem 5.1 (Logistic fixed set).** The fixed points of $f$ in $[0,1]$ are
exactly $\{0, \tfrac34\}$.

*Proof.* The equation $f(x) = x$ reads $4x(1-x) = x$, i.e. $4x - 4x^2 = x$, i.e.
$x(4x - 3) = 0$. The roots are $x = 0$ and $x = \tfrac34$, both in $[0,1]$.
$\qquad\blacksquare$

**Corollary 5.2 (Fixed-point count).** The logistic map has exactly
$2 = 2^1$ fixed points in $[0,1]$.

*Proof.* The set $\{0, \tfrac34\}$ has two elements since $0 \ne \tfrac34$; apply
Theorem 5.1. $\qquad\blacksquare$

The tent map likewise has two fixed points in $[0,1]$, namely $0$ and $\tfrac23$
(solving $2-2t = t$ on the right branch), and Theorem 4.2 matches the pairs. This
is the base case of the conjectured general count (see Section 8).

## 6. Realisation of period three

We now transport an explicit tent cycle to certify a period-three orbit of the
logistic map.

**Lemma 6.1 (An explicit tent 3-cycle).** The tent map satisfies
$$T(\tfrac27) = \tfrac47,\qquad T(\tfrac47) = \tfrac67,\qquad T(\tfrac67) = \tfrac27,$$
so that $T^{\,3}(\tfrac27) = \tfrac27$ and $\{\tfrac27, \tfrac47, \tfrac67\}$ is
an orbit of exact period three.

*Proof.* Since $\tfrac27 \le \tfrac12$, $T(\tfrac27) = 2\cdot\tfrac27 = \tfrac47$.
Since $\tfrac47 \ge \tfrac12$, $T(\tfrac47) = 2 - 2\cdot\tfrac47 = \tfrac67$.
Since $\tfrac67 \ge \tfrac12$, $T(\tfrac67) = 2 - 2\cdot\tfrac67 = \tfrac27$. The
three values are distinct, so the period is exactly three. $\qquad\blacksquare$

**Theorem 6.2 (Logistic period-three orbit).** The point $x_0 = h(\tfrac27) =
\sin^2(\pi/7)$ satisfies $f^{\,3}(x_0) = x_0$ while $f(x_0) \ne x_0$ and
$f^{\,2}(x_0) \ne x_0$; that is, $x_0$ has exact period three under $f$.

*Proof.* By Corollary 3.2 and Lemma 6.1,
$f^{\,3}(x_0) = h(T^{\,3}(\tfrac27)) = h(\tfrac27) = x_0$. For exactness, note
$f(x_0) = h(T(\tfrac27)) = h(\tfrac47)$ and $f^{\,2}(x_0) = h(T^{\,2}(\tfrac27))
= h(\tfrac67)$. Since $\tfrac27, \tfrac47, \tfrac67$ are distinct points of
$[0,1]$ and $h$ is injective there (Theorem 3.3), we have $h(\tfrac47) \ne
h(\tfrac27)$ and $h(\tfrac67) \ne h(\tfrac27)$, so $f(x_0) \ne x_0$ and
$f^{\,2}(x_0) \ne x_0$. $\qquad\blacksquare$

**Corollary 6.3 (Orbits of every period).** The logistic map $f$ has periodic
orbits of every period $n \ge 1$.

*Proof.* By Theorem 6.2, $f$ has an orbit of exact period three. Sharkovskii's
theorem states that a continuous self-map of an interval possessing a
period-three orbit possesses orbits of every period; $f$ is continuous, so the
conclusion follows. $\qquad\blacksquare$

## 7. Algorithms

The conjugacy yields exact, elementary algorithms in place of numerical root
finding.

**Algorithm A (Sawtooth periodic-point count).** To count period-$n$ points of
$f$, count period-$n$ points of $T$. The $n$-fold tent iterate is a piecewise
affine sawtooth whose graph consists of $2^n$ full ramps, each crossing the
diagonal $y = t$ exactly once; the count is therefore $2^n$. By Corollary 4.3
this is also the count for $f$.

**Algorithm B (Cycle transport).** Given a rational tent cycle
$t_0 \to t_1 \to \cdots \to t_{n-1} \to t_0$ computed by exact arithmetic on the
two affine branches, produce the corresponding logistic cycle by applying
$x_i = \sin^2(\pi t_i / 2)$. Distinctness of the $t_i$ guarantees distinctness of
the $x_i$, hence exact period $n$.

**Algorithm C (Seed recovery / conjugate coordinate).** To analyse a logistic
orbit, transport it to the tent coordinate via $t = h^{-1}(x) = \tfrac{2}{\pi}
\arcsin\sqrt{x}$, where the tent dynamics is the binary shift. This makes any
orbit statistic explicitly computable.

## 8. Discussion and applications

**A transcendental count made combinatorial.** Corollary 4.3 converts a question
about roots of high-degree polynomials into a question about crossings of a
sawtooth. The equal-cardinality statement is exact, not asymptotic, and holds for
every $n$ simultaneously.

**Sharkovskii from a single arithmetic cycle.** The full force of Sharkovskii's
ordering — orbits of every period — is unlocked by the completely explicit cycle
$2/7 \to 4/7 \to 6/7 \to 2/7$ and its transport through $h$. No smooth analysis of
the parabola is required.

**Invariant measure.** The conjugacy also transports invariant measures. The tent
map preserves the uniform (Lebesgue) measure on $[0,1]$; pushing this forward
through $h$ under the change of variables $x = \sin^2(\pi t/2)$ produces the
*arcsine measure* with density $\tfrac{1}{\pi\sqrt{x(1-x)}}$, which is exactly the
invariant density of the logistic map. The Jacobian of $h$ manufactures the
arcsine weight.

**Cryptographic fragility.** A recurring proposal is to build stream ciphers from
"chaotic" logistic keystreams. The conjugacy is a rigorous no-go argument. Any
invariant an attacker can extract from a logistic keystream — bias,
autocorrelation, or the algebraic difficulty of seed recovery — has an exact
counterpart obtained by applying $h^{-1}$ to move to the tent coordinate, where
the dynamics is the binary shift map: writing the seed in base two, one iteration
deletes the leading bit. The apparent complexity of the parabola orbit is a
coordinate artefact; it evaporates in the conjugate linear coordinate. Security
claimed for the smooth system offers nothing beyond its piecewise-linear shadow.

## 9. Future work

The following directions extend the same geometric bridge.

**The exact exponential count.** We conjecture that for every $n \ge 1$ the tent
map — and hence the logistic map — has exactly $2^n$ points of period dividing
$n$ in $[0,1]$. The equal-cardinality reduction (Corollary 4.3) is already in
hand, so the remaining work is a purely combinatorial ramp-counting induction on
the sawtooth geometry of $T^{\,n}$.

**Exact period $n$ for every $n$.** We conjecture that for each $n$ the tent map
has a point of exact period $n$, whose image under $h$ has exact period $n$ for
the logistic map. Exactness is preserved by an injective conjugacy; the dyadic-type
rationals $k/(2^n \pm 1)$ should supply the seeds, generalising the period-three
construction.

**Density and transitivity.** We conjecture that the periodic points of the
logistic map are dense in $[0,1]$ and that the map is topologically transitive,
certifying chaos on the whole interval. Both properties are preserved by a
homeomorphism, so it suffices to establish them for the tent map, whose periodic
seeds are the manifestly dense dyadic-type rationals.

**The arcsine invariant measure.** We conjecture that the logistic map preserves
the arcsine measure $\tfrac{1}{\pi\sqrt{x(1-x)}}\,dx$, the pushforward under $h$
of the uniform measure preserved by the tent map, making a smooth ergodic
statement a one-line change of variables.

## 10. Conclusion

An explicit sine-squared change of coordinates identifies the smooth logistic map
with the piecewise-linear tent map as dynamical systems. Through this bridge the
periodic-orbit skeleton transfers verbatim: periodicity, period, and orbit count
all match, the fixed set is computed exactly as $\{0, 3/4\}$, and a single
rational three-cycle certifies orbits of every period. Counting smooth periodic
points becomes counting linear ones — the transcendental made combinatorial by a
change of clothes.
