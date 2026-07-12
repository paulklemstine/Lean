# The Escape Radius Theorem for the Quadratic Family: Elementary Dynamics of $z \mapsto z^2 + c$

## Abstract

The Mandelbrot set $M$ is the set of complex parameters $c$ for which the orbit
of $0$ under the quadratic map $f_c(z) = z^2 + c$ remains bounded. We give a
complete, self-contained development of the elementary metric dynamics of this
recurrence, culminating in the classical **escape-radius theorem**: if at any
stage an orbit reaches a point $z$ with $\|z\| > 2$ while the parameter satisfies
$\|c\| \le \|z\|$, then the orbit diverges geometrically, obeying the explicit
lower bound $\|f_c^{\,n}(z)\| \ge \|z\|\,(\|z\|-1)^n$. As an immediate
consequence, any parameter with $\|c\| > 2$ escapes, so $M$ is contained in the
closed disk of radius $2$: $M \subseteq \overline{B}(0,2)$. The single analytic
ingredient is the reverse triangle inequality
$\|z^2 + c\| \ge \|z\|^2 - \|c\|$; everything else is induction and elementary
estimation. We complement the containment result with two exact membership
computations, $0 \in M$ and $-1 \in M$, the latter exhibiting the period-$2$
cycle at the center of the largest bulb. We close by relating the framework to
the number theory of the bulbs — the correspondence between rational internal
angles $p/q$ and attracting cycles of period $q$ — and outline the theorems that
build on the escape estimate.

**Keywords:** Mandelbrot set, quadratic recurrence, complex dynamics, escape
radius, reverse triangle inequality, geometric divergence, bounded orbits,
period-2 bulb.

---

## 1. Introduction

Complex dynamics studies the iteration of holomorphic maps of the complex plane.
The single most studied family is the **quadratic family**
$$f_c(z) = z^2 + c, \qquad c \in \mathbb{C},$$
because every quadratic polynomial is conjugate to exactly one member of this
family, and because the family already exhibits the full richness of the theory.
The associated parameter object is the **Mandelbrot set**
$$M = \{\, c \in \mathbb{C} : \text{the orbit } 0, f_c(0), f_c^{2}(0), \dots
\text{ is bounded} \,\}.$$

Everything computational about $M$ rests on one prior question: *given a
parameter $c$, how can one prove an orbit escapes to infinity in finite time?*
The answer is the **escape-radius theorem**. It supplies a threshold — the value
$2$ — beyond which divergence is certain, converting an infinite limiting
question into a finite, checkable condition. It is the theoretical foundation of
every algorithm that renders the Mandelbrot set, and the first structural fact
about $M$: that it is bounded, and in fact contained in a disk of radius $2$.

This paper presents the theorem and its proof in full, from first principles,
assuming only the norm structure of $\mathbb{C}$ and the (reverse) triangle
inequality. The development is deliberately elementary: the entire chain of
reasoning reduces to one inequality iterated with care. We also verify two exact
membership facts and situate the results within the broader arithmetic geometry
of the bulbs.

## 2. Definitions and setup

Throughout, $\|\cdot\|$ denotes the complex modulus on $\mathbb{C}$, which is
multiplicative ($\|zw\| = \|z\|\,\|w\|$, hence $\|z^2\| = \|z\|^2$) and satisfies
the triangle inequality.

**Definition 2.1 (Quadratic step).** For a parameter $c \in \mathbb{C}$, define
the map
$$f_c : \mathbb{C} \to \mathbb{C}, \qquad f_c(z) = z^2 + c.$$

**Definition 2.2 (Critical orbit).** The *orbit of $0$* under $f_c$ is the
sequence $(z_n)_{n \ge 0}$ defined recursively by
$$z_0 = 0, \qquad z_{n+1} = f_c(z_n) = z_n^2 + c.$$
Equivalently $z_n = f_c^{\,n}(0)$, the $n$-fold composition of $f_c$ applied to
$0$. We call $0$ the *critical point* because it is the unique point where
$f_c'$ vanishes; its orbit governs the global dynamics.

**Definition 2.3 (Bounded orbit).** A parameter $c$ has a *bounded orbit* if
there exists a real bound $R$ with $\|z_n\| \le R$ for all $n \ge 0$.

**Definition 2.4 (Mandelbrot set).**
$$M = \{\, c \in \mathbb{C} : c \text{ has a bounded orbit} \,\}.$$

Two elementary identities anchor the recursion. First, the orbit begins
$$z_1 = f_c(0) = 0^2 + c = c,$$
so **the first iterate of the critical point is the parameter itself**; this is
the hinge that connects the abstract escape estimate to the concrete set $M$.
Second, from stage $1$ onward the orbit is the forward iteration of $f_c$ started
at $c$: $z_{n+1} = f_c^{\,n}(c)$.

## 3. The one-step lower bound

Every subsequent estimate flows from a single application of the reverse
triangle inequality.

**Lemma 3.1 (One-step lower bound).** For all $c, z \in \mathbb{C}$,
$$\|f_c(z)\| \;=\; \|z^2 + c\| \;\ge\; \|z\|^2 - \|c\|.$$

*Proof.* The triangle inequality gives $\|(z^2 + c) - c\| \le \|z^2 + c\| +
\|c\|$; but the left side is $\|z^2\| = \|z\|^2$. Rearranging,
$\|z\|^2 - \|c\| \le \|z^2 + c\|$. $\qquad\blacksquare$

Interpretation: the multiplicative amplifier $z \mapsto z^2$ squares the
magnitude exactly, while the additive term $c$ can pull the result back toward
the origin by no more than $\|c\|$.

## 4. One-step growth past the escape radius

**Lemma 4.1 (Strict growth).** Suppose $\|z\| > 2$ and $\|c\| \le \|z\|$. Then
$$\|z\| < \|f_c(z)\|.$$

*Proof.* Write $r = \|z\| > 2$. By Lemma 3.1,
$$\|f_c(z)\| \ge r^2 - \|c\| \ge r^2 - r = r(r-1).$$
Since $r > 2$, we have $r - 1 > 1$, so $r(r-1) > r = \|z\|$. Combining,
$\|z\| < r(r-1) \le \|f_c(z)\|$. $\qquad\blacksquare$

The proof reveals the crucial *self-reproduction* of the hypotheses: after one
step the new magnitude $\|f_c(z)\|$ exceeds $\|z\| > 2$, so it is still greater
than $2$; and it still dominates $\|c\|$ because $\|c\| \le \|z\| < \|f_c(z)\|$.
The escape condition is invariant under the dynamics, which is exactly what makes
induction possible.

## 5. Geometric escape

**Theorem 5.1 (Geometric escape estimate).** Suppose $\|z\| > 2$ and
$\|c\| \le \|z\|$. Then for every $n \ge 0$,
$$\big\| f_c^{\,n}(z) \big\| \;\ge\; \|z\| \,\big(\|z\| - 1\big)^n.$$

*Proof.* Induct on $n$. For $n = 0$ the claim is $\|z\| \le \|z\|$. Assume the
bound holds for $n$; abbreviate $w = f_c^{\,n}(z)$. By the inductive hypothesis
and $\|z\|-1 > 1$ we have, in particular, $\|w\| \ge \|z\|(\|z\|-1)^n \ge \|z\|$,
so $\|w\| \ge \|z\| > 2$ and $\|w\| \ge \|c\|$. Applying Lemma 3.1 to $w$,
$$\big\| f_c^{\,n+1}(z) \big\| = \|f_c(w)\| \ge \|w\|^2 - \|c\|
\ge \|w\|^2 - \|w\| = \|w\|\big(\|w\| - 1\big).$$
Since $\|w\| \ge \|z\|(\|z\|-1)^n$ and $\|w\| - 1 \ge \|z\| - 1$ (because
$\|w\| \ge \|z\|$),
$$\|w\|\big(\|w\|-1\big) \ge \|z\|(\|z\|-1)^n \cdot (\|z\|-1)
= \|z\|(\|z\|-1)^{n+1},$$
completing the induction. $\qquad\blacksquare$

**Corollary 5.2 (Unbounded orbit).** Under the hypotheses of Theorem 5.1, the
sequence $\big(\|f_c^{\,n}(z)\|\big)_{n\ge0}$ is unbounded; indeed for every
$R \in \mathbb{R}$ there is an $n$ with $\|f_c^{\,n}(z)\| > R$.

*Proof.* Since $\|z\| - 1 > 1$, the geometric sequence
$n \mapsto \|z\|(\|z\|-1)^n$ tends to $+\infty$. By Theorem 5.1 the orbit norms
dominate this divergent sequence, hence also tend to $+\infty$. $\qquad
\blacksquare$

## 6. The escape criterion and containment

We now connect the abstract estimate to $M$ using the identity $z_1 = c$.

**Theorem 6.1 (Escape criterion).** If $\|c\| > 2$, then the orbit of $0$ under
$f_c$ is unbounded; consequently $c \notin M$.

*Proof.* The orbit reaches $z_1 = c$, which satisfies $\|c\| > 2$ and trivially
$\|c\| \le \|c\|$. Apply Corollary 5.2 with $z = c$: the forward iterates
$f_c^{\,n}(c) = z_{n+1}$ are unbounded. Hence no uniform bound $R$ can hold for
the orbit, so $c$ does not have a bounded orbit and $c \notin M$. $\qquad
\blacksquare$

**Theorem 6.2 (Escape-radius theorem / containment).** Every parameter of the
Mandelbrot set satisfies $\|c\| \le 2$. Equivalently,
$$M \;\subseteq\; \overline{B}(0, 2) = \{\, c \in \mathbb{C} : \|c\| \le 2 \,\}.$$

*Proof.* Contrapositive of Theorem 6.1: if $\|c\| > 2$ then $c \notin M$.
Therefore $c \in M$ forces $\|c\| \le 2$, and membership in $M$ implies
membership in the closed disk of radius $2$. $\qquad\blacksquare$

The bound $2$ is sharp for the containment statement: the parameter $c = -2$
lies in $M$ (its critical orbit is $0 \to -2 \to 2 \to 2 \to \cdots$, bounded),
and $\|-2\| = 2$, so the set genuinely reaches the boundary circle.

## 7. Exact membership examples

Containment describes where $M$ cannot be; the following two computations
confirm that $M$ is nonempty and exhibit its simplest dynamical behaviors.

**Proposition 7.1 ($0 \in M$).** The parameter $c = 0$ lies in $M$.

*Proof.* For $c = 0$ the recurrence is $z_{n+1} = z_n^2$ with $z_0 = 0$, so
$z_n = 0$ for all $n$ by induction. The orbit is bounded by $R = 0$. $\qquad
\blacksquare$

The origin is the fixed point $z = 0$ of $f_0$ and lies at the center of the main
cardioid of $M$.

**Proposition 7.2 ($-1 \in M$; the period-2 cycle).** The parameter $c = -1$
lies in $M$, and its critical orbit is the $2$-cycle
$$0 \;\to\; -1 \;\to\; 0 \;\to\; -1 \;\to\; \cdots.$$

*Proof.* With $c = -1$: $z_0 = 0$, $z_1 = 0^2 - 1 = -1$, $z_2 = (-1)^2 - 1 = 0$,
and the pattern repeats with period $2$. Formally, a two-line induction shows
$z_n \in \{0, -1\}$ for every $n$, whence $\|z_n\| \le 1$ for all $n$. The orbit
is bounded by $R = 1$, so $-1 \in M$. $\qquad\blacksquare$

The point $c = -1$ is the center of the largest bulb attached to the main
cardioid: the *period-2 bulb*. It is the simplest instance of the general
principle that bulbs of $M$ host attracting cycles.

## 8. The number theory of the bulbs

The two membership examples hint at a rich arithmetic structure. The main
cardioid of $M$ is the locus of parameters $c$ for which $f_c$ has an attracting
fixed point; it is parametrized by
$$c = \frac{\mu}{2} - \frac{\mu^2}{4}, \qquad |\mu| \le 1,$$
where $\mu = f_c'(\text{fixed point})$ is the multiplier. On the boundary circle
$|\mu| = 1$, writing $\mu = e^{2\pi i \,p/q}$ with $p/q \in \mathbb{Q}$ in lowest
terms, a bulb of period $q$ is born by a parabolic bifurcation. This is the
sense in which **each bulb corresponds to a rational number $p/q$**: the internal
angle $p/q$ selects where on the cardioid the bulb attaches, and $q$ is the
period of the attracting cycle that becomes active inside it.

The largest bulb, at internal angle $1/2$ (multiplier $\mu = -1$), is the
period-2 bulb; its center is precisely $c = -1$, matching Proposition 7.2. The
bulbs at $1/3$ and $2/3$ carry period-3 cycles, those at $1/4$ and $3/4$ period-4
cycles, and so on. The classical *Farey* arrangement of these fractions around
the cardioid encodes how the bulbs are ordered and how new bulbs appear between
existing ones — a genuine piece of number theory written into the geometry of
the fractal. The escape-radius theorem is the entry point to this theory: it
guarantees the arena (the disk of radius $2$) inside which all of this structure
lives.

## 9. Algorithmic significance

The escape-radius theorem is the mathematical justification for the standard
**escape-time algorithm** used to render $M$. For each pixel $c$, one iterates
the recurrence and monitors $\|z_n\|$. The moment $\|z_n\| > 2$, Theorem 6.1
guarantees the orbit will diverge, so the iteration halts and reports the escape
time $n$ (which drives the coloring). If a preset iteration cap is reached with
$\|z_n\|$ still $\le 2$, the pixel is provisionally classified as belonging to
$M$ (colored black). Correctness of the *escape* branch is exactly Theorem 6.1;
the containment Theorem 6.2 guarantees that the entire set fits in a fixed
viewport of radius $2$, so no part of $M$ is ever missed by a bounded rendering
window.

The geometric estimate of Theorem 5.1 further quantifies convergence: once the
threshold is crossed, the norm at least multiplies by $\|z\| - 1 > 1$ each step,
so escape is detected within a small number of additional iterations — the
algorithm never needs to iterate far past the radius.

## 10. Discussion and future work

The results above form the elementary metric backbone of quadratic complex
dynamics. Building on them, the natural next theorems are:

1. **Sharper escape criterion.** Generalize the trigger from "the orbit reaches
   $c$ with $\|c\| > 2$" to "the orbit reaches *any* stage $z_n$ with
   $\|z_n\| > \max(\|c\|, 2)$." The same geometric machinery applies starting
   from that stage, yielding escape from an arbitrary escaping point of the
   critical orbit.

2. **Compactness of $M$.** Combine the containment $M \subseteq \overline{B}(0,2)$
   with the closedness of $M$. Closedness follows because each condition
   "$\|z_n\| \le 2$" is closed (the iterates depend continuously on $c$) and $M$
   is the countable intersection of these closed conditions; a bounded closed
   subset of $\mathbb{C}$ is compact.

3. **The real spine $[-2, 1/4] \subseteq M \cap \mathbb{R}$.** For real
   $c \in [-2, 1/4]$ the real orbit is trapped in an invariant interval
   $[\beta, |c|]$ around the attracting fixed point $\beta$, giving a bounded
   orbit. This interval is the real "spine" of the cardioid.

4. **The main cardioid.** Prove that $c \in M$ whenever $f_c$ has an attracting
   or neutral fixed point, yielding the parametrization
   $c = \mu/2 - \mu^2/4$, $|\mu| \le 1$, via a fixed-point and derivative
   analysis.

5. **Period-$q$ bulbs and rationals $p/q$.** Establish the correspondence
   between internal angle $p/q$ and attracting cycles of period $q$. The
   period-2 case is exactly Proposition 7.2; the general case requires the theory
   of parabolic bifurcations.

6. **Connectedness of $M$ (Douady–Hubbard).** The deep theorem that $M$ is
   connected uses potential theory on the complement of $M$; the escape estimate
   here is the first input, providing the Green's function's behavior near
   infinity.

## 11. Conclusion

From the single inequality $\|z^2 + c\| \ge \|z\|^2 - \|c\|$ we derived, by
elementary induction, that any orbit exceeding magnitude $2$ (with the parameter
no larger) diverges geometrically, and therefore that the Mandelbrot set is
confined to the closed disk of radius $2$. Two exact computations placed the
origin and the period-2 center $-1$ inside the set. The argument is a model of
economy: the most intricate object in elementary mathematics is fenced in by the
most basic estimate in analysis.
