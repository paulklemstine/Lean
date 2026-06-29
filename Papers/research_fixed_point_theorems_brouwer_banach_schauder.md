# Fixed Point Theorems via Discrete Parity: Sperner, Brouwer, Banach, and the Shadow of Schauder

**Author:** Aristotle
**Date:** 2026-06-22
**Domain:** Geometry / Combinatorial Topology

## Abstract

We present a unified, fully formalized development of three pillars of fixed point
theory, organized around a single elementary engine: the parity of colour changes
along a path. From the one-dimensional Sperner lemma — that a two-colouring of a
path with mismatched endpoints exhibits an odd, hence nonzero, number of
bichromatic edges — we derive the one-dimensional Brouwer fixed point theorem for
continuous self-maps of the interval. We then treat the metric side of the theory:
for an affine contraction $f(x) = ax + b$ with $|a| < 1$ we prove that Picard
iteration converges to the unique fixed point $b/(1-a)$ (the affine Banach
principle), and that whenever such a map preserves an interval, its fixed point is
localized inside that interval — the one-dimensional shadow of the retraction step
underlying Schauder's theorem. All results are stated inline with full proof
sketches. The combinatorial parity argument (`sperner_parity`,
`sperner_exists_change`) is reusable as the boundary base case for higher
dimensional Sperner and Brouwer theorems, and the affine analysis
(`affine_iterate_tendsto`, `affine_fixedPoint_mem_Icc`) provides explicit,
quantitative witnesses for the contraction principle.

## 1. Introduction

A *fixed point* of a self-map $f : X \to X$ is a point $x^*$ with $f(x^*) = x^*$.
Fixed point theorems assert the existence (and sometimes the computability) of
such points under structural hypotheses on $X$ and $f$. They are foundational
across analysis and its applications: the Picard–Lindelöf theorem on existence and
uniqueness of solutions to ordinary differential equations, the solvability of
Fredholm and Volterra integral equations, the existence of Nash equilibria, and
the convergence of iterative numerical schemes are all fixed point statements.

Three theorems dominate the landscape:

1. **Brouwer's theorem.** Every continuous self-map of a nonempty compact convex
   subset of $\mathbb{R}^n$ has a fixed point. It is purely topological: no
   metric, no contraction, only continuity.
2. **Banach's contraction principle.** Every contraction of a nonempty complete
   metric space has a *unique* fixed point, and Picard iteration converges to it
   geometrically. It is constructive and quantitative.
3. **Schauder's theorem.** Every continuous self-map of a nonempty compact convex
   subset of a Banach space has a fixed point — the infinite-dimensional extension
   of Brouwer, obtained by finite-dimensional approximation and retraction.

This paper develops the combinatorial route to Brouwer through Sperner's lemma and
the analytic route to Banach through explicit iteration, and exhibits the
finite-dimensional core of Schauder via affine localization. The unifying thread
is that all three reduce, at base, to elementary and fully mechanizable facts —
in the topological case, to whether a number is even or odd.

## 2. Definitions

### Definition 2.1 (Colour-change count)

Let $c : \mathbb{N} \to \{\,\text{R}, \text{B}\,\}$ be a two-colouring of the
non-negative integers (modelling the vertices of a path; in the formalization the
palette is `Bool`). For $n \in \mathbb{N}$ define the **change count**
$$\mathrm{changes}(c, n) \;=\; \#\{\, i \in \mathbb{N} : i < n,\ c(i) \neq c(i+1) \,\},$$
the number of bichromatic edges among the first $n$ edges of the path
$0 - 1 - \dots - n$. In Lean this is realized via `Finset` filtering over
`Finset.range n`.

### Definition 2.2 (Affine self-map)

For real parameters $a, b$, the **affine map** is $f_{a,b}(x) = ax + b$. Its
$n$-fold iterate is written $f_{a,b}^{[n]}$. When $a \ne 1$ its unique fixed point
is
$$x^* = \frac{b}{1-a},$$
the solution of $ax + b = x$.

### Definition 2.3 (Contraction)

A map $f : \mathbb{R} \to \mathbb{R}$ is a **contraction with ratio $a$** if
$|f(x) - f(y)| \le a\,|x - y|$ for all $x, y$ and some $0 \le a < 1$. The affine
map $f_{a,b}$ is a contraction with ratio $|a|$ precisely when $|a| < 1$.

## 3. The one-dimensional Sperner lemma

The combinatorial engine is a parity invariant of the change count.

### Lemma 3.1 (Change recurrence — `changes_succ`)

For every colouring $c$ and every $n$,
$$\mathrm{changes}(c, n+1) \;=\; \mathrm{changes}(c, n) + \mathbf{1}[\,c(n) \neq c(n+1)\,],$$
where $\mathbf{1}[\cdot]$ is the indicator ($1$ if true, $0$ otherwise).

*Proof sketch.* The edge set $\{i < n+1\}$ is the disjoint union of $\{i < n\}$
and the singleton $\{n\}$. Filtering by the predicate "$c(i) \neq c(i+1)$" and
taking cardinalities splits accordingly; the singleton contributes $1$ exactly
when $c(n) \neq c(n+1)$. Formally this is `Finset.range_succ` together with
`Finset.filter_insert` and `Finset.card_insert`. $\qquad\blacksquare$

### Theorem 3.2 (Sperner parity — `sperner_parity`)

For every colouring $c$ and every $n$,
$$\mathrm{changes}(c, n)\ \text{is odd} \iff c(0) \neq c(n).$$
Equivalently, $\mathrm{changes}(c, n) \bmod 2 = \mathbf{1}[\,c(0) \neq c(n)\,]$.

*Proof sketch.* Induct on $n$. For $n = 0$ the count is $0$ (even) and
$c(0) = c(0)$, so both sides are false/zero. For the step, apply Lemma 3.1. There
are two cases for the new edge $(n, n+1)$:

- If $c(n) = c(n+1)$, the count is unchanged so its parity is unchanged, and the
  endpoint comparison $c(0)$ vs $c(n+1) = c(n)$ is unchanged. The biconditional is
  preserved.
- If $c(n) \neq c(n+1)$, the count increases by $1$ so its parity flips, and the
  endpoint comparison flips as well (since $c(n+1) \neq c(n)$, the relation between
  $c(0)$ and $c(n+1)$ is the negation of that between $c(0)$ and $c(n)$).

In both cases the inductive hypothesis transfers. This is a telescoping parity
argument; mechanically it is `Nat.rec` plus case analysis on the `Bool` equality
`decide (c n = c (n+1))`. $\qquad\blacksquare$

### Corollary 3.3 (Existence of a change — `sperner_exists_change`)

If $c(0) \neq c(n)$, then there exists $i < n$ with $c(i) \neq c(i+1)$.

*Proof sketch.* By Theorem 3.2 the count $\mathrm{changes}(c, n)$ is odd, hence
strictly positive. A nonempty filtered `Finset` has a witnessing element
(`Finset.card_pos` ⇒ `Finset.Nonempty`), which is exactly an index $i < n$ with
$c(i) \neq c(i+1)$. $\qquad\blacksquare$

Corollary 3.3 is the discrete intermediate value principle: a binary signal that
disagrees at its two ends must flip somewhere in between. It is the base case for
boundary-counting (discrete Stokes) arguments in higher-dimensional Sperner
theory.

## 4. Brouwer in one dimension

### Theorem 4.1 (One-dimensional Brouwer — `brouwer_one_dim`)

Let $f : \mathbb{R} \to \mathbb{R}$ be continuous and suppose $f(x) \in [0,1]$ for
all $x \in [0,1]$. Then there exists $x^* \in [0,1]$ with $f(x^*) = x^*$.

*Proof sketch.* Consider $g(x) = f(x) - x$, continuous on $[0,1]$. At the left
endpoint, $g(0) = f(0) - 0 = f(0) \ge 0$ because $f(0) \in [0,1]$. At the right
endpoint, $g(1) = f(1) - 1 \le 0$ because $f(1) \in [0,1]$. By the intermediate
value theorem (`intermediate_value_Icc`, or its continuous-image formulation),
$g$ attains $0$ somewhere in $[0,1]$, yielding $x^*$ with $f(x^*) = x^*$.

The combinatorial proof underlying this analytic shortcut is the content of
Corollary 3.3: sample $[0,1]$ and colour each sample by the sign of $g$ (red where
$g > 0$, "push right"; blue where $g < 0$, "push left"). The endpoints receive
opposite colours, so by Corollary 3.3 adjacent samples of opposite colour exist;
refining the sampling and invoking continuity collapses the bracketing interval to
a genuine zero of $g$. The discrete parity guarantees the bracket exists at every
scale; completeness of $\mathbb{R}$ delivers the limit. $\qquad\blacksquare$

Theorem 4.1 is the one-dimensional instance of Brouwer. Its higher-dimensional
form replaces the two-colour path by an $(n{+}1)$-colour triangulation of an
$n$-simplex; the parity of fully coloured cells (the full Sperner lemma) plays the
role of Theorem 3.2, and a fixed-point-free map would produce a colouring with no
fully coloured cell, contradicting the parity.

## 5. The finite-dimensional shadow of Schauder

Schauder's theorem extends Brouwer to compact convex subsets of Banach spaces by
finite-dimensional approximation followed by a retraction onto the convex set. The
essential localization step — that the fixed point produced lives inside the
preserved set — is already visible for affine maps in one dimension.

### Theorem 5.1 (Affine fixed-point localization — `affine_fixedPoint_mem_Icc`)

Let $f(x) = ax + b$ with $0 \le a < 1$, and let $\ell \le h$. If $f$ maps the
interval $[\ell, h]$ into itself (i.e. $f(\ell) \in [\ell, h]$ and
$f(h) \in [\ell, h]$, equivalently $f(x) \in [\ell, h]$ for all $x \in [\ell, h]$
by monotonicity), then the fixed point satisfies
$$x^* = \frac{b}{1-a} \in [\ell, h].$$

*Proof sketch.* Since $0 \le a < 1$, $f$ is monotone nondecreasing, so $f$ maps
$[\ell, h]$ into itself iff $f(\ell) \ge \ell$ and $f(h) \le h$. The first gives
$a\ell + b \ge \ell$, i.e. $b \ge (1-a)\ell$, hence $b/(1-a) \ge \ell$ (dividing
by $1 - a > 0$). The second gives $ah + b \le h$, i.e. $b \le (1-a)h$, hence
$b/(1-a) \le h$. Therefore $x^* = b/(1-a) \in [\ell, h]$. Mechanically this is two
applications of `div_le_iff`/`le_div_iff` with $1 - a > 0$ and membership in
`Set.Icc`. $\qquad\blacksquare$

Theorem 5.1 is the $n = 1$ instance of Schauder's retraction step: the self-map
condition forces the fixed point to remain in the trapping set, so no retraction
back onto the set is actually needed — the fixed point never left. In higher
dimensions and infinite dimensions, the general Schauder argument restores this
property via a retraction onto the compact convex set after a Brouwer fixed point
is located on a finite-dimensional approximant.

## 6. Banach's contraction principle for affine maps

### Theorem 6.1 (Affine Picard convergence — `affine_iterate_tendsto`)

Let $f(x) = ax + b$ with $|a| < 1$. Then for every starting point $x_0$,
$$f^{[n]}(x_0) \longrightarrow \frac{b}{1-a} \qquad (n \to \infty).$$

*Proof sketch.* Let $x^* = b/(1-a)$, the fixed point. A one-line induction gives
the closed form of the orbit:
$$f^{[n]}(x_0) - x^* = a^{n}\,(x_0 - x^*).$$
Indeed $f^{[0]}(x_0) - x^* = x_0 - x^*$, and
$f^{[n+1]}(x_0) - x^* = f(f^{[n]}(x_0)) - x^* = a\,f^{[n]}(x_0) + b - (a x^* + b) =
a\,(f^{[n]}(x_0) - x^*)$, completing the induction. Since $|a| < 1$, $a^n \to 0$
(`tendsto_pow_atTop_nhds_zero_of_abs_lt_one`), so $a^n (x_0 - x^*) \to 0$ and
$f^{[n]}(x_0) \to x^*$. $\qquad\blacksquare$

### Remark 6.2 (Quantitative a-posteriori bound)

The closed form $f^{[n]}(x_0) - x^* = a^n(x_0 - x^*)$ makes the convergence rate
*exact*: $|f^{[n]}(x_0) - x^*| = |a|^n\,|x_0 - x^*|$. Combined with the geometric
series identity $x_0 - x^* = (x_0 - f(x_0))/(1-a)$ for affine maps, this yields the
classical a-posteriori Picard estimate
$$\bigl|f^{[n]}(x_0) - x^*\bigr| \;=\; \frac{|a|^n}{|1-a|}\,\bigl|x_0 - f(x_0)\bigr|,$$
which is the affine case of the general contraction bound
$\mathrm{dist}(f^{[n]}(x_0), x^*) \le \tfrac{a^n}{1-a}\,\mathrm{dist}(x_0, f(x_0))$
— and here it holds with *equality*, a rare tight constant. (Stated as a remark:
the equality witness is the natural next formalization target, Conjecture 4 below.)

## 7. Algorithms

### 7.1 Sperner change-locator

Given a finite colour array, scan adjacent pairs and return the first index where
the colour flips. Theorem 3.2 guarantees that, when the endpoints disagree, the
total number of flips is odd, so this scan terminates with a witness (Corollary
3.3). Complexity $O(n)$ in the array length.

### 7.2 Affine Picard iterator with certified error

Given $a, b, x_0$ with $|a| < 1$ and a tolerance $\varepsilon$, iterate
$x \mapsto a x + b$. Using the exact bound of Remark 6.2, the number of iterations
needed for $|x_n - x^*| \le \varepsilon$ is
$$n \ge \frac{\log\!\bigl(\varepsilon (1-|a|) / |x_0 - f(x_0)|\bigr)}{\log |a|},$$
so the loop is certified to stop after a predictable number of steps. Each step is
$O(1)$.

## 8. Applications

- **Ordinary differential equations.** The Picard–Lindelöf existence-uniqueness
  theorem is Banach's principle applied to the integral operator
  $(Tu)(t) = u_0 + \int_{t_0}^{t} F(s, u(s))\,ds$ on a space of continuous
  functions; under a Lipschitz condition on $F$, $T$ is a contraction, and the
  affine model (Theorem 6.1) is the linear prototype $u' = au + b$.
- **Integral equations.** Fredholm and Volterra equations of the second kind,
  $u = g + \lambda K u$ with $K$ an integral operator, are solved by Banach (small
  $\lambda$, contraction) or by Schauder (compact $K$, no smallness), with
  Theorem 5.1 modelling the localization of the solution.
- **Economics and game theory.** Brouwer (Theorem 4.1 in 1D, its simplex form in
  general) underlies the existence of competitive equilibria and Nash equilibria
  via best-response maps of compact convex strategy sets.
- **Numerical analysis.** Theorem 6.1 and Remark 6.2 are the convergence and
  error-control backbone of fixed-point iteration schemes, including the linear
  stationary iterations (Jacobi, Gauss–Seidel) whose iteration matrices are
  affine.

## 9. Discussion

The architecture of this development is deliberately layered. The topological
guarantee (Brouwer) is reduced to a parity fact (Sperner), which is in turn a
one-line recurrence (Lemma 3.1) plus an induction (Theorem 3.2). This makes the
existence of fixed points *combinatorially certifiable*: no analysis is needed to
know that a bracket exists, only the observation that an odd number is nonzero.
The metric theory (Banach) is, by contrast, *constructive and quantitative*: the
affine closed form turns convergence into an explicit geometric decay with an
exact error constant. Schauder sits above both, and its finite-dimensional core —
the trapping property of Theorem 5.1 — is the bridge between the existence-only and
the constructive worlds.

A notable feature is the reusability of the parity engine. The lemmas
`changes_succ`, `sperner_parity`, and `sperner_exists_change` are stated for an
arbitrary `Bool`-colouring of $\mathbb{N}$ and form the boundary base case for the
planar Sperner lemma, where the number of tricoloured cells equals, modulo $2$,
the number of bichromatic boundary edges — a count the one-dimensional result
already shows is odd.

## 10. Future work

The following directions extend the present results.

1. **Two-dimensional Sperner.** Formalize the planar Sperner lemma: a
   boundary-admissible proper $3$-colouring of a triangulated triangle contains an
   odd number of fully tricoloured cells. The one-dimensional parity engine serves
   as the boundary base case via a discrete Stokes identity.
2. **Two-dimensional Brouwer.** Derive Brouwer for continuous self-maps of the
   closed $2$-simplex from the planar Sperner lemma, lifting the
   `brouwer_one_dim` template one dimension.
3. **Finite-dimensional Schauder.** Prove a Schauder-type theorem for continuous
   self-maps of a compact convex $K \subseteq \mathbb{R}^n$ via retraction onto
   $K$ followed by Brouwer; Theorem 5.1 is the $n = 1$ retraction instance.
4. **Quantitative Banach.** Promote Remark 6.2 to a proved equality witness: the
   affine a-posteriori bound holds with equality, giving a rare tight constant for
   the contraction-mapping estimate.

## 11. Conclusion

Three of the most consequential existence theorems in mathematics — Brouwer,
Banach, and Schauder — admit a common, elementary backbone. The topological side
rests on the parity of colour changes along a path (`sperner_parity`,
`sperner_exists_change`), which forces the one-dimensional Brouwer theorem
(`brouwer_one_dim`). The metric side rests on the explicit geometric decay of
affine iterates to $b/(1-a)$ (`affine_iterate_tendsto`), the constructive content
of Banach's principle, with the fixed point trapped inside any preserved interval
(`affine_fixedPoint_mem_Icc`), the finite-dimensional shadow of Schauder. Together
they show that the guarantee "something stays put" is, at its core, a statement
about counting and about geometric series.
