# Nonexistence of Polynomial Solutions for Airy's Equation and Its Riccati Form

## Abstract

We prove two sharp nonexistence results concerning Airy's differential
equation, the classical second-order linear equation $y'' = x\,y$ that governs
wave amplitudes near a caustic. Working purely algebraically in the polynomial
ring $\mathbb{R}[x]$ equipped with the formal derivative, we show that the only
polynomial $p$ satisfying $p'' = x\,p$ is the zero polynomial, and that the
associated Riccati equation $u' + u^2 = x$ — obtained from the logarithmic
derivative substitution — has no polynomial solution at all. Both proofs are
elementary degree-counting arguments, requiring no analysis, no convergence
considerations, and no real-valued functions: they rest only on the additivity
of degree under multiplication, the strict degree drop under differentiation,
and the dominance of a strictly higher-degree summand. We isolate the structural
core of these arguments, explain why they generalize to equations of the form
$p'' = q\,p$ for any coefficient $q$ of positive degree and to higher-order
analogues $p^{(k)} = x\,p$, and discuss the consequences for the
transcendence of the Airy function and for the differential algebra of
equations with polynomial coefficients.

## 1. Introduction

Airy's equation
$$ y'' = x\,y \tag{1} $$
arose in George Biddell Airy's 1838 study of the intensity of light near a
caustic. It is the simplest second-order linear ordinary differential equation
whose coefficient varies linearly with the independent variable, and as such it
sits at a boundary: for $x < 0$ its solutions oscillate, while for $x > 0$ they
behave exponentially. Its solutions, the Airy functions $\operatorname{Ai}(x)$
and $\operatorname{Bi}(x)$, are ubiquitous in optics, semiclassical quantum
mechanics (the connection problem at a turning point), the asymptotics of
orthogonal polynomials, and the Tracy–Widom laws of random matrix theory.

Despite the analytic richness of its solutions, equation (1) has a coefficient,
$x$, that is itself a polynomial. It is therefore natural to ask whether (1)
admits solutions within the simplest possible function class — the polynomials.
Many classical equations do: Legendre's, Hermite's, Laguerre's, and Chebyshev's
equations all possess polynomial eigensolutions. The purpose of this paper is to
establish, with complete rigor and by entirely elementary means, that Airy's
equation does **not**.

We prove two results.

1. **(Linear form.)** The only $p \in \mathbb{R}[x]$ with $p'' = x\,p$ is
   $p = 0$.
2. **(Riccati form.)** No $p \in \mathbb{R}[x]$ satisfies $p'' + (p')^2 = x$.

The Riccati form is the equation satisfied by the antiderivative of a
logarithmic derivative of a solution of (1); we elaborate on this connection in
Section 5. Both proofs are degree-counting arguments carried out in the formal
polynomial ring, so they make no reference to limits, convergence, or
real-analytic structure. This algebraic stance is what makes the results both
sharp and effortlessly generalizable.

## 2. Preliminaries: the degree calculus

Throughout, $\mathbb{R}[x]$ denotes the ring of polynomials in one indeterminate
$x$ over the real numbers, and for a polynomial $p$ we write $p'$ for its
**formal derivative**, defined termwise by $\frac{d}{dx} x^n = n\,x^{n-1}$ and
extended linearly. The formal derivative satisfies the usual product and power
rules purely algebraically.

For a nonzero polynomial $p$, $\deg p$ denotes its **degree**, the largest $n$
with a nonzero coefficient of $x^n$. We adopt the convention used throughout
that for the **natural-number degree** $\operatorname{natDeg}$ one has
$\operatorname{natDeg} 0 = 0$, with the understanding that the zero polynomial
is handled separately whenever degree comparisons are made. All inequalities
below involving truncated subtraction on $\mathbb{N}$ are interpreted in the
natural numbers (so $a - b = 0$ when $b \ge a$); this matches the way the proofs
manipulate degrees and is harmless because the cases that matter have $a \ge b$.

We record the three facts that drive every argument in this paper.

**Lemma 2.1 (Degree of a product with $x$).** For any nonzero $p \in
\mathbb{R}[x]$,
$$ \deg(x\,p) = \deg p + 1. $$

*Proof.* Multiplication by $x$ sends $\sum_k a_k x^k$ to $\sum_k a_k x^{k+1}$.
If $a_n$ is the leading coefficient of $p$ (so $a_n \ne 0$ and $n = \deg p$),
then $a_n x^{n+1}$ is the leading term of $x\,p$, and it does not vanish because
$\mathbb{R}$ has no zero divisors. Hence $\deg(x\,p) = n + 1$. $\qquad\blacksquare$

**Lemma 2.2 (Degree drop under differentiation).** For any $p \in
\mathbb{R}[x]$,
$$ \deg(p') \le \deg p - 1, $$
and consequently $\deg(p'') \le \deg p - 2$.

*Proof.* Differentiating $\sum_k a_k x^k$ gives $\sum_k k\,a_k x^{k-1}$, every
term of which has degree strictly less than the corresponding term of $p$. Thus
$\deg(p') \le \deg p - 1$. Applying the bound twice gives $\deg(p'') \le
(\deg p - 1) - 1 = \deg p - 2$. $\qquad\blacksquare$

**Lemma 2.3 (Dominance of a strictly larger summand).** If $a, b \in
\mathbb{R}[x]$ satisfy $\deg a < \deg b$, then
$$ \deg(a + b) = \deg b. $$

*Proof.* The coefficient of $x^{\deg b}$ in $a + b$ equals the leading
coefficient of $b$ (since $a$ contributes nothing in that degree), which is
nonzero, and no higher-degree term appears. $\qquad\blacksquare$

**Lemma 2.4 (Degree of a square).** For any $p \in \mathbb{R}[x]$,
$$ \deg(p^2) = 2 \deg p. $$

*Proof.* The leading term of $p^2$ is the square of the leading term of $p$,
whose coefficient is the square of a nonzero real and hence nonzero. $\qquad\blacksquare$

These four lemmas are the entire toolbox.

## 3. The linear form

**Theorem 3.1 (No nonzero polynomial solution of Airy's equation).** Let $p \in
\mathbb{R}[x]$ satisfy
$$ p'' = x\,p. \tag{2} $$
Then $p = 0$.

*Proof.* Suppose for contradiction that $p \ne 0$, and set $n = \deg p$.

Comparing the two sides of (2) as equal polynomials, they must have equal
degree. By Lemma 2.1, the right-hand side satisfies
$$ \deg(x\,p) = n + 1. $$
By Lemma 2.2, the left-hand side satisfies
$$ \deg(p'') \le n - 2. $$
Since $p'' = x\,p$, these two quantities are the same number, so
$$ n + 1 = \deg(p'') \le n - 2, $$
whence $n + 1 \le n - 2$, i.e. $3 \le 0$, a contradiction. Therefore $p = 0$.
Conversely $p = 0$ does satisfy (2), since $0 = x \cdot 0$. $\qquad\blacksquare$

The proof exposes the mechanism precisely: multiplication by $x$ raises the
degree by one, while two differentiations lower it by two, creating a permanent
gap of three between the two sides. No polynomial can bridge a gap that the
equation itself forces open.

## 4. The Riccati form

We now turn to the nonlinear companion equation
$$ p'' + (p')^2 = x. \tag{3} $$
Equation (3) is the equation satisfied by an antiderivative of a logarithmic
derivative of a solution of (1); see Section 5. Whereas the linear form admits
the trivial solution $p = 0$, the Riccati form admits none at all.

**Theorem 4.1 (No polynomial solution of the Riccati form).** There is no
$p \in \mathbb{R}[x]$ satisfying $p'' + (p')^2 = x$.

*Proof.* Suppose such a $p$ exists. Write $q = p'$ and let $d = \deg q$ (the
natural-number degree, so $d = 0$ when $q$ is constant). By Lemma 2.4,
$$ \deg(q^2) = 2d, $$
and by Lemma 2.2 applied to $q = p'$,
$$ \deg(p'') = \deg(q') \le d - 1. $$
We consider two cases according to the value of $d$.

**Case $d = 0$.** Then $q$ is a constant, so $q' = p'' = 0$ and $q^2$ is a
constant; thus the left-hand side $p'' + q^2$ is a constant, of degree $\le 0$.
By the degree-of-a-sum bound,
$$ \deg\bigl(p'' + (p')^2\bigr) \le \max\{\deg(p''),\, \deg(q^2)\} \le 0. $$
But equation (3) asserts this equals $\deg(x) = 1$, so $1 \le 0$, a
contradiction.

**Case $d \ge 1$.** Then $\deg(q^2) = 2d \ge 2$, while $\deg(p'') \le d - 1 <
2d$. The two summands therefore have strictly different degrees, and by Lemma
2.3 the larger one dominates:
$$ \deg\bigl(p'' + (p')^2\bigr) = \deg(q^2) = 2d. $$
Equation (3) forces this to equal $\deg(x) = 1$, so $2d = 1$ with $d \ge 1$, a
contradiction (and indeed $2d \ge 2 > 1$ already suffices).

In both cases we reach a contradiction, so no polynomial $p$ satisfies (3).
$\qquad\blacksquare$

The asymmetry between Theorems 3.1 and 4.1 is worth emphasizing. The linear
equation is homogeneous, so $p = 0$ is automatically a solution and the theorem
is a uniqueness statement (the *only* solution is zero). The Riccati equation is
inhomogeneous — its right-hand side is the nonzero polynomial $x$ — so even the
zero polynomial fails, and the conclusion is outright nonexistence.

## 5. From the linear equation to the Riccati equation

The two theorems are not independent curiosities; the Riccati equation is the
standard nonlinear shadow of the linear one. Given a (sufficiently smooth,
locally nonvanishing) solution $y$ of $y'' = x\,y$, introduce the logarithmic
derivative
$$ w = \frac{y'}{y}. $$
Then $w' = \frac{y''}{y} - \left(\frac{y'}{y}\right)^2 = x - w^2$, i.e.
$$ w' + w^2 = x. \tag{4} $$
Equation (4) is the **Riccati form** of Airy's equation in the variable $w$.
Writing $w = p'$ for an antiderivative $p$ recasts (4) as (3). Thus a polynomial
solution of the Riccati form would correspond to a solution of Airy's equation
whose logarithmic derivative is a polynomial — the kind of "elementary" closed
form one might hope for. Theorem 4.1 shows no such closed form exists at the
level of polynomials, reinforcing Theorem 3.1 from the nonlinear side.

It bears stressing that Theorems 3.1 and 4.1 are proved entirely within the
formal polynomial ring; the analytic substitution above is given only to explain
*why* the Riccati form is the natural object to study. The proofs themselves
never leave algebra.

## 6. Generalizations

The degree calculus of Section 2 is robust, and both theorems generalize with no
new ideas.

**Theorem 6.1 (Polynomial coefficient of positive degree).** Let $q \in
\mathbb{R}[x]$ be a fixed nonzero polynomial with $\deg q \ge 1$. Then the only
$p \in \mathbb{R}[x]$ satisfying $p'' = q\,p$ is $p = 0$.

*Sketch.* If $p \ne 0$ with $\deg p = n$, then $\deg(q\,p) = \deg q + n \ge n +
1$ by additivity of degree over the domain $\mathbb{R}[x]$, while $\deg(p'') \le
n - 2$. The inequality $n + 1 \le \deg q + n = \deg(p'') \le n - 2$ is again
impossible. Airy's equation is the case $q = x$. $\qquad\blacksquare$

**Theorem 6.2 (Higher-order analogue).** For any integer $k \ge 1$, the only
$p \in \mathbb{R}[x]$ satisfying $p^{(k)} = x\,p$ is $p = 0$.

*Sketch.* The $k$-th derivative obeys $\deg(p^{(k)}) \le n - k$, while
$\deg(x\,p) = n + 1$. Since $n + 1 > n - k$ for every $k \ge 0$, the degrees can
never match unless $p = 0$. $\qquad\blacksquare$

**Arbitrary base ring.** Lemmas 2.1, 2.3, and 2.4 use only that the coefficient
ring is a nontrivial commutative ring without zero divisors — an integral
domain — so that the leading coefficient of a product is the product of the
leading coefficients and hence nonzero. Consequently Theorems 3.1, 4.1, 6.1, and
6.2 hold verbatim over any integral domain $R$ in place of $\mathbb{R}$, e.g.
$\mathbb{Z}$, $\mathbb{Q}$, $\mathbb{C}$, or a polynomial ring over a field. The
real numbers play no special role.

## 7. Discussion and consequences

**Transcendence of the Airy function.** Theorem 3.1 is the first rung on the
ladder of statements asserting that the Airy function is not "elementary."
Because the homogeneous solution space of (1) is two-dimensional and contains no
nonzero polynomial, every nonzero solution — in particular $\operatorname{Ai}$
and $\operatorname{Bi}$ — must be genuinely transcendental over the polynomials.
The Airy function does possess an everywhere-convergent power series and an
integral representation $\operatorname{Ai}(x) = \frac{1}{\pi}\int_0^\infty
\cos\!\left(\frac{t^3}{3} + xt\right)\,dt$, but it cannot be truncated to, or
captured by, any finite polynomial expression.

**The value of negative results.** Nonexistence theorems function as
*signposts*: they tell solvers and algorithm designers which ansätze are futile.
A symbolic ODE solver searching for polynomial solutions of (1) can terminate
immediately with the certificate provided by Theorem 3.1, and a search for a
polynomial logarithmic derivative can be pruned by Theorem 4.1. Degree-counting
certificates of this kind are cheap to check and, as Section 6 shows, easy to
extend to whole families of equations.

**Methodological remark.** The proofs deliberately avoid analysis. By
formulating Airy's equation in the formal polynomial ring with the formal
derivative, the statement "Airy's equation has no polynomial solution" becomes a
finite combinatorial fact about degrees, fully decidable by inspection of two
integers. This is a recurring advantage of the algebraic viewpoint on
differential equations: questions that look analytic become questions about the
degree, valuation, or factorization structure of polynomials.

## 8. Future work

Several natural directions remain.

* **Coefficients of arbitrary positive degree.** Theorem 6.1 generalizes the
  linear form to $p'' = q\,p$ for any nonzero $q$ with $\deg q \ge 1$; a fuller
  treatment would characterize exactly which polynomial coefficients $q$ (now
  allowing $\deg q = 0$, where Hermite-type polynomial solutions reappear) admit
  nonzero polynomial solutions, recovering the classical orthogonal-polynomial
  families as the boundary case.
* **General base rings.** Restating all results over an arbitrary integral
  domain $R$, or more weakly over a nontrivial commutative ring with no zero
  divisors, would maximize reusability and clarify exactly which ring-theoretic
  hypotheses the degree calculus requires.
* **Higher-order and mixed analogues.** Beyond $p^{(k)} = x\,p$, one can study
  Riccati-type identities mixing several derivatives, where the same comparison
  (left-hand degree $\le n - k$, right-hand degree $n + 1$) continues to forbid
  nonzero polynomial solutions.
* **Formal power series.** Airy's equation *does* admit formal power-series
  solutions in $\mathbb{R}[[x]]$, organized by the recurrence on coefficients
  induced by (1). Contrasting the polynomial nonexistence proved here with the
  power-series existence theory would give a complete picture of where, in the
  hierarchy of formal function classes, the solutions of Airy's equation first
  appear.

## 9. Conclusion

Airy's equation $y'' = x\,y$, for all its analytic depth, hides a purely
combinatorial secret: it cannot be solved by a polynomial, and neither can its
Riccati companion $u' + u^2 = x$. The proofs are short, elementary, and sharp —
a comparison of two integers, the degrees of the two sides — and they extend
without effort to a broad family of related equations and to any integral domain
of coefficients. They illustrate, in microcosm, how an algebraic reading of a
differential equation can settle a question about its solutions with finality
and economy.
