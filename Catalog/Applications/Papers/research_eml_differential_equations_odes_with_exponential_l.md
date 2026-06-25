# An Elementary Degree Obstruction to Exponential–Polynomial Solutions of Airy's Equation

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Applications (Differential Equations / Differential Algebra)

## Abstract

Airy's equation $y'' = x\,y$ is the canonical second-order linear ordinary
differential equation whose solutions — the Airy functions $\mathrm{Ai}$ and
$\mathrm{Bi}$ — are not elementary. We give a complete, self-contained, and
machine-verified proof that no *exponential–polynomial* solves Airy's equation:
if $q,p \in \mathbb{R}[X]$ with $q \neq 0$, then $f(x) = q(x)\,e^{p(x)}$ does not
satisfy $f'' = x f$. The proof rests on a single algebraic object, the **Airy
coefficient**
$$ \operatorname{airyCoeff}(q,p) = q'' + 2 q' p' + q\,p'' + q\,(p')^2 \in \mathbb{R}[X], $$
characterized by the analytic identity $\big(q\,e^{p}\big)'' =
\operatorname{airyCoeff}(q,p)\cdot e^{p}$. Cancelling the nowhere-vanishing factor
$e^{p}$ reduces the differential equation to the polynomial identity
$\operatorname{airyCoeff}(q,p) = X\cdot q$, which we refute by a degree (indeed a
*parity*) argument: when $p' \neq 0$ the leading term $q\,(p')^2$ forces
$\deg \operatorname{airyCoeff}(q,p) = \deg q + 2\deg p'$, an excess of $2\deg p'$
over $\deg q$, whereas $X\cdot q$ has excess exactly $1$; even cannot equal odd.
The degenerate case $p' = 0$ yields $\operatorname{airyCoeff}(q,p) = q''$, whose
degree is strictly below that of $X\cdot q$. We discuss the embedding of this
result in differential Galois theory and the Risch–Kovacic algorithmic framework,
and outline several generalizations: arbitrary second-order polynomial-coefficient
operators, higher-order Airy-type equations $y^{(n)} = x y$, the complex case, and
an effective decision procedure for $q\,e^{p}$ closed forms.

## 1. Introduction

### 1.1 Background

Airy's differential equation,
$$ y'' = x\,y, \tag{Airy} $$
was introduced by G. B. Airy in 1838 in the study of caustics and the intensity
of light near a fold (e.g., the bright fringes of a rainbow). It is the simplest
linear ODE exhibiting a *turning point*: the qualitative behavior of solutions
changes from oscillatory (for $x<0$) to exponential (for $x>0$) as the coefficient
$x$ changes sign. Its two standard real solutions $\mathrm{Ai}(x)$ and
$\mathrm{Bi}(x)$ are entire transcendental functions of fundamental importance in
optics, quantum mechanics (the WKB connection problem), asymptotic analysis, and
random matrix theory (the Tracy–Widom distribution).

It is classical that the Airy functions are *not elementary*: they cannot be
expressed as finite combinations of polynomials, exponentials, logarithms, and
algebraic functions. The modern explanation is differential Galois theory
(Picard–Vessiot theory): the differential Galois group of (Airy) over
$\mathbb{C}(x)$ is $\mathrm{SL}_2(\mathbb{C})$, which is not solvable, so by the
Liouville–Kolchin criterion (Airy) has no Liouvillian solution.

This paper isolates a particularly transparent, elementary fragment of that fact.
Rather than invoke the full Galois machinery, we directly refute the most natural
and most common closed-form ansatz — a polynomial times the exponential of a
polynomial — using nothing more than the product/chain rules and the arithmetic of
polynomial degrees. The result is sharp, fully rigorous, and has been formalized
and machine-checked.

### 1.2 The exponential–polynomial ansatz

By an **exponential–polynomial** we mean a function of the form
$$ f(x) = q(x)\,e^{p(x)}, \qquad q,p \in \mathbb{R}[X]. \tag{EP} $$
This family is closed under differentiation and contains, as special cases: all
polynomials ($p = 0$); the elementary exponentials $e^{cx}$; Gaussians
$e^{-x^2}$; and products such as $x^k e^{p(x)}$. It is exactly the natural
"first guess" one writes down when attempting a closed-form solution of a linear
ODE, and it constitutes the leaf of the Liouvillian tower obtained by a single
exponential extension over $\mathbb{R}(x)$ with a polynomial prefactor.

### 1.3 Main result

> **Theorem (no exponential–polynomial solves Airy).** Let $q,p \in
> \mathbb{R}[X]$ with $q \neq 0$. Then $f = q\,e^{p}$ does **not** satisfy
> $f'' = x f$ on $\mathbb{R}$. Equivalently, there is no nonzero $q$ such that
> $$ \forall x \in \mathbb{R}, \quad \frac{d^2}{dx^2}\!\left[q(x)e^{p(x)}\right]
> = x\,q(x)\,e^{p(x)}. $$

In the formalization this is the theorem `no_exp_poly_solves_airy`. The proof is
assembled from an algebraic core (`airyCoeff`, `airyCoeff_eq`,
`degree_airyCoeff_eq`, `airyCoeff_ne_X_mul`) and an analytic bridge
(`hasDerivAt_poly_mul_exp`, `second_deriv_poly_mul_exp`).

### 1.4 Organization

Section 2 fixes notation. Section 3 defines the Airy coefficient and proves the
algebraic identity that characterizes it. Section 4 carries out the degree/parity
analysis culminating in the impossibility $\operatorname{airyCoeff}(q,p) \neq
X\cdot q$. Section 5 establishes the analytic bridge, computing the second
derivative of $q\,e^{p}$. Section 6 assembles the main theorem. Section 7 places
the result in the context of differential Galois theory and Liouvillian
solvability. Section 8 gives an algorithmic reading. Section 9 discusses
generalizations and open directions.

## 2. Preliminaries and notation

We work in the polynomial ring $\mathbb{R}[X]$ and write $X$ for the indeterminate.
For $g \in \mathbb{R}[X]$ we write $g'$ (or $\operatorname{D} g$) for the formal
derivative, $\deg g \in \mathbb{Z}_{\ge 0} \cup \{-\infty\}$ for the degree, with
the convention $\deg 0 = -\infty$. We use the standard facts:

- **(D1)** $\deg(g+h) \le \max(\deg g, \deg h)$, with equality when $\deg g \neq
  \deg h$.
- **(D2)** $\deg(gh) = \deg g + \deg h$ over the integral domain $\mathbb{R}[X]$
  (with the usual conventions for the zero polynomial).
- **(D3)** $\deg g' \le \deg g - 1$ for $g \neq 0$ (and $\deg g' = \deg g - 1$ in
  characteristic $0$ when $\deg g \ge 1$).
- **(D4)** A polynomial is determined by its values: if $g(x) = h(x)$ for all
  $x \in \mathbb{R}$ then $g = h$ (extensionality over the infinite field
  $\mathbb{R}$; `Polynomial.funext`).

For the analytic part we use the evaluation map $g \mapsto (x \mapsto g(x))$,
written $\operatorname{eval}_x g$, the differentiability of polynomial evaluation
(`Polynomial.hasDerivAt`), and the chain rule for $\exp$
(`HasDerivAt.exp`). The exponential satisfies $e^{t} > 0$ for all $t$, in
particular $e^{t} \neq 0$ (`Real.exp_pos`, `Real.exp_ne_zero`).

## 3. The Airy coefficient

### 3.1 Definition

The crucial observation is that differentiating $q\,e^{p}$ preserves the shape
"polynomial times $e^{p}$" and acts on the polynomial prefactor by the
first-order *linear differential operator*
$$ L_p : \mathbb{R}[X] \to \mathbb{R}[X], \qquad L_p(g) = g' + g\,p'. $$
Indeed $\frac{d}{dx}\big(g\,e^{p}\big) = (g' + g p')\,e^{p} = (L_p g)\,e^{p}$.
Iterating, $\big(q\,e^{p}\big)'' = (L_p^2 q)\,e^{p}$. Expanding $L_p^2$ motivates
the following definition.

> **Definition 3.1 (`airyCoeff`).** For $q,p \in \mathbb{R}[X]$,
> $$ \operatorname{airyCoeff}(q,p) \;=\; q'' + 2\,q'\,p' + q\,p'' + q\,(p')^2. $$

### 3.2 The operator identity

> **Lemma 3.2 (`airyCoeff_eq`).** For all $q,p \in \mathbb{R}[X]$,
> $$ L_p\big(L_p q\big) = \operatorname{airyCoeff}(q,p), \qquad\text{i.e.}\qquad
> \big(q' + q p'\big)' + \big(q' + q p'\big)\,p' = \operatorname{airyCoeff}(q,p). $$

*Proof.* Expand the left-hand side using linearity of the derivative and the
Leibniz rule $(gh)' = g'h + gh'$:
$$
(q' + q p')' + (q' + q p')p' = q'' + (q' p' + q p'') + (q' p' + q (p')^2)
= q'' + 2 q' p' + q p'' + q (p')^2,
$$
which is exactly $\operatorname{airyCoeff}(q,p)$. $\;\;\blacksquare$

This is a pure identity in the differential ring $(\mathbb{R}[X], {}')$ and
requires no analysis.

## 4. Degree analysis and the algebraic obstruction

### 4.1 Exact degree of the Airy coefficient

> **Lemma 4.1 (`degree_airyCoeff_eq`).** If $q \neq 0$ and $p' \neq 0$, then
> $$ \deg \operatorname{airyCoeff}(q,p) = \deg q + 2\,\deg p'. $$

*Proof.* Write $d = \deg q \ge 0$ and $m = \deg p' \ge 0$. Compare the degrees of
the four summands of $\operatorname{airyCoeff}(q,p)$:
$$
\deg q'' \le d - 2, \quad \deg(2 q' p') \le (d-1)+m, \quad
\deg(q p'') \le d + (m-1), \quad \deg(q (p')^2) = d + 2m,
$$
using (D2)–(D3); the last is an equality because $q \neq 0$ and $p' \neq 0$ make
$q(p')^2 \neq 0$ over the integral domain $\mathbb{R}[X]$. Each of the first three
degrees is strictly less than $d + 2m$: indeed $d-2 < d+2m$, and
$(d-1)+m < d+2m \iff -1 < m$ (true since $m \ge 0$), and $d+m-1 < d+2m \iff
-1 < m$. By (D1), the unique strictly-dominant term $q(p')^2$ determines the
degree, so $\deg \operatorname{airyCoeff}(q,p) = d + 2m$. (Formally one writes
$\operatorname{airyCoeff}(q,p) = q(p')^2 + R$ with $\deg R < d+2m$ and applies
`degree_add_eq_left_of_degree_lt`; the boundary subcase $m = 0$, i.e. $p'$ a
nonzero constant, is handled separately, where the three lower terms have degrees
$\le d-2$, $\le d-1$, $\le d-1$, again all $< d = d+2m$.) $\;\;\blacksquare$

### 4.2 The core obstruction

> **Theorem 4.2 (`airyCoeff_ne_X_mul`).** For every $q \neq 0$ and every $p$,
> $$ \operatorname{airyCoeff}(q,p) \neq X\cdot q. $$

*Proof.* Two cases.

**Case $p' \neq 0$.** By Lemma 4.1, $\deg \operatorname{airyCoeff}(q,p) = \deg q +
2\deg p'$. On the other hand $\deg(X\cdot q) = \deg q + 1$ by (D2) since $X$ has
degree $1$ and $q \neq 0$. If the two polynomials were equal their degrees would
coincide, giving $\deg q + 2\deg p' = \deg q + 1$, i.e. $2\deg p' = 1$. This is
impossible: $2\deg p'$ is even and $1$ is odd. Hence
$\operatorname{airyCoeff}(q,p) \neq X\cdot q$.

**Case $p' = 0$.** Then $\operatorname{airyCoeff}(q,p) = q''$ (the three terms
containing $p'$ or $p''$ vanish, and $p'' = (p')' = 0$). By (D3),
$\deg q'' \le \deg q - 2 < \deg q + 1 = \deg(X\cdot q)$. (If $\deg q = 0$, then
$q'' = 0 \neq X\cdot q$ since $X\cdot q \neq 0$ for $q \neq 0$.) In all subcases
the degrees differ, so $\operatorname{airyCoeff}(q,p) \neq X\cdot q$.
$\;\;\blacksquare$

The conceptual content is a **parity invariant**: multiplication by $X$ raises
degree by the *odd* number $1$, while the dominant nonlinear term $q(p')^2$ of the
Airy coefficient raises it by the *even* number $2\deg p'$. No exponent $p$ can
reconcile the two.

## 5. The analytic bridge

We now connect the algebra to genuine derivatives of $\mathbb{R}\to\mathbb{R}$
functions.

> **Lemma 5.1 (`hasDerivAt_poly_mul_exp`).** For polynomials $p,g$ and any
> $x \in \mathbb{R}$, the function $y \mapsto g(y)\,e^{p(y)}$ is differentiable at
> $x$ with
> $$ \frac{d}{dy}\Big[g(y)e^{p(y)}\Big]_{y=x} = (g' + g p')(x)\,e^{p(x)}. $$

*Proof.* The polynomial evaluations $y \mapsto g(y)$ and $y\mapsto p(y)$ are
differentiable with derivatives $g'(x)$ and $p'(x)$ (`Polynomial.hasDerivAt`). By
the chain rule for $\exp$ (`HasDerivAt.exp`), $y\mapsto e^{p(y)}$ has derivative
$p'(x)e^{p(x)}$. The product rule then gives
$$ g'(x)e^{p(x)} + g(x)\,p'(x)e^{p(x)} = (g'(x) + g(x)p'(x))\,e^{p(x)}
= (g' + g p')(x)\,e^{p(x)}. \;\;\blacksquare$$

> **Theorem 5.2 (`second_deriv_poly_mul_exp`).** For polynomials $q,p$ and any
> $x \in \mathbb{R}$,
> $$ \frac{d^2}{dx^2}\Big[q(x)e^{p(x)}\Big]
> = \operatorname{airyCoeff}(q,p)(x)\,e^{p(x)}. $$

*Proof.* By Lemma 5.1 the first derivative of $y\mapsto q(y)e^{p(y)}$ is the
function $y \mapsto (q' + q p')(y)\,e^{p(y)}$, an exponential–polynomial with
prefactor $L_p q = q' + q p'$. Applying Lemma 5.1 again to this prefactor, the
second derivative is
$$ \big(L_p(L_p q)\big)(x)\,e^{p(x)} = \operatorname{airyCoeff}(q,p)(x)\,e^{p(x)},$$
where the last equality is the operator identity Lemma 3.2 (`airyCoeff_eq`).
$\;\;\blacksquare$

## 6. Proof of the main theorem

> **Theorem 6.1 (`no_exp_poly_solves_airy`).** Let $q,p \in \mathbb{R}[X]$ with
> $q \neq 0$. There is no way for $f = q\,e^{p}$ to satisfy
> $f''(x) = x\,f(x)$ for all $x \in \mathbb{R}$.

*Proof.* Suppose, for contradiction, that for every $x \in \mathbb{R}$,
$$ \frac{d^2}{dx^2}\Big[q(x)e^{p(x)}\Big] = x\,\big(q(x)e^{p(x)}\big). $$
By Theorem 5.2 the left side equals $\operatorname{airyCoeff}(q,p)(x)\,e^{p(x)}$,
so for all $x$,
$$ \operatorname{airyCoeff}(q,p)(x)\,e^{p(x)} = x\,q(x)\,e^{p(x)}. $$
Since $e^{p(x)} > 0$ is never zero (`Real.exp_pos`), divide both sides by
$e^{p(x)}$ to obtain the pointwise polynomial equality
$$ \operatorname{airyCoeff}(q,p)(x) = x\,q(x) = (X\cdot q)(x) \qquad
\text{for all } x \in \mathbb{R}. $$
By polynomial extensionality over the infinite field $\mathbb{R}$ (D4,
`Polynomial.funext`), this forces the equality of *polynomials*
$\operatorname{airyCoeff}(q,p) = X\cdot q$. But this contradicts Theorem 4.2
(`airyCoeff_ne_X_mul`), which asserts exactly that no such equality holds for
$q \neq 0$. The contradiction completes the proof. $\;\;\blacksquare$

The logical skeleton is therefore: *analytic identity* (Thm 5.2) $+$
*nonvanishing of $\exp$* $+$ *extensionality* (D4) reduce the ODE to a polynomial
identity, which the *degree/parity obstruction* (Thm 4.2) refutes.

## 6A. Worked examples

We illustrate the mechanism on concrete candidate solutions; in each case the
Airy coefficient is computed from Definition 3.1 and compared with $X\cdot q$.

**Example 1 ($f = e^{x}$).** Here $q = 1$, $p = X$, so $q' = q'' = 0$, $p' = 1$,
$p'' = 0$. Then
$$ \operatorname{airyCoeff}(1, X) = 0 + 0 + 0 + 1\cdot 1^2 = 1, $$
while $X\cdot q = X$. Indeed $(e^{x})'' = e^{x} \neq x\,e^{x}$; the identity
$\operatorname{airyCoeff} = X q$ would read $1 = X$, false. The degrees are $0$
and $1$ — even excess $0$ versus odd excess $1$.

**Example 2 ($f = x^2 e^{2x}$).** Here $q = X^2$, $p = 2X$, so $q' = 2X$,
$q'' = 2$, $p' = 2$, $p'' = 0$. Then
$$ \operatorname{airyCoeff}(X^2, 2X) = 2 + 2\cdot(2X)\cdot 2 + 0 + X^2\cdot 2^2
= 4X^2 + 8X + 2, $$
of degree $2 = \deg q + 2\deg p' = 2 + 0$, while $X\cdot q = X^3$ has degree $3$.
The degrees already disagree, confirming $f$ is not a solution.

**Example 3 (Gaussian $f = e^{-x^2}$).** Here $q = 1$, $p = -X^2$, so $p' = -2X$,
$p'' = -2$, $(p')^2 = 4X^2$. Then
$$ \operatorname{airyCoeff}(1, -X^2) = 0 + 0 + 1\cdot(-2) + 1\cdot 4X^2
= 4X^2 - 2, $$
of degree $2 = \deg q + 2\deg p' = 0 + 2$, an even excess of $2$ over
$\deg q = 0$, while $X\cdot q = X$ has degree $1$. The parity mismatch is
explicit: the squared exponent term $q(p')^2$ contributes degree $2$, never the
odd degree $1$ demanded by multiplication by $X$.

**Example 4 (constant exponent, $p$ constant).** If $p = c$ is constant then
$p' = 0$ and $\operatorname{airyCoeff}(q, c) = q''$. For $q = X^2$ this is the
constant $2$, of degree $0$, far below $\deg(X\cdot q) = 3$. Thus even allowing a
scalar multiplier $e^{c}$ in front of a polynomial cannot help.

These examples show the obstruction is not an artifact of large degrees: it
already bites on the smallest natural candidates. In every instance the residual
$\operatorname{airyCoeff}(q,p) - X\cdot q$ is a visibly nonzero polynomial, and
the leading behavior is dictated by the parity of the degree.

## 7. Differential-Galois context

### 7.1 Liouvillian solutions

A function is **Liouvillian** over $\mathbb{R}(x)$ (or $\mathbb{C}(x)$) if it lies
in a tower of differential field extensions obtained by successively adjoining
exponentials of, integrals of, and algebraic functions over previously
constructed fields. The exponential–polynomials (EP) are precisely the simplest
Liouvillian functions of "exponential of a polynomial" type with polynomial
prefactor — one exponential extension $e^{p}$ over $\mathbb{R}(x)$, intersected
with $\mathbb{R}[x]\cdot e^{p}$.

### 7.2 The Galois-theoretic statement

Kolchin's theorem states that a linear ODE has a Liouvillian solution if and only
if the connected component of its differential Galois group is solvable. For
(Airy) the Galois group over $\mathbb{C}(x)$ is $\mathrm{SL}_2(\mathbb{C})$, which
is connected and *not* solvable; hence (Airy) has no Liouvillian solution at all —
a fortiori none of EP type. Our Theorem 6.1 reproves the EP-specific consequence
by entirely elementary means, replacing the group-theoretic nonsolvability of
$\mathrm{SL}_2$ with a one-line parity count. The trade-off is scope (we restrict
to the EP ansatz) for transparency and complete elementarity.

### 7.3 The Kovacic algorithm

Kovacic's algorithm is a decision procedure that, given a second-order linear ODE
$y'' = r(x)y$ with $r \in \mathbb{C}(x)$, determines whether it has a Liouvillian
solution and, if so, computes one; it is organized around the four conjugacy
classes of algebraic subgroups of $\mathrm{SL}_2(\mathbb{C})$. Run on (Airy) with
$r(x)=x$, every case of Kovacic's algorithm fails, certifying the absence of
Liouvillian solutions. The degree obstruction of this paper can be seen as the
shadow, for the EP ansatz, of the "Case 1" exponential search in Kovacic's
algorithm: there one seeks a solution of the form $e^{\int \omega}$ with $\omega$
rational, and the degree bookkeeping that defeats it is exactly our parity
mismatch.

## 8. Algorithmic reading

The proof is constructive in a strong sense: it converts an analytic existence
question into a *finite* algebraic feasibility question. Fix degree bounds
$\deg q \le d$, $\deg p \le e$, and write $q = \sum_{i=0}^{d} a_i X^i$,
$p = \sum_{j=0}^{e} b_j X^j$. Then $\operatorname{airyCoeff}(q,p) - X\cdot q$ is a
polynomial whose coefficients are explicit (quadratic) polynomial expressions in
$(a_i, b_j)$. Asking whether some EP of bounded degree solves a given polynomial
ODE is asking whether this system of polynomial equations has a solution with
$q \neq 0$ — a decidable question (e.g. by Gröbner bases / real quantifier
elimination). Theorem 4.2 shows that for (Airy) the system is infeasible for
*every* bound, because the leading-degree equation $2\deg p' = 1$ is already
unsatisfiable. This is the seed of an effective classifier for $q\,e^{p}$
solutions of arbitrary polynomial-coefficient linear ODEs (see §9.4).

## 9. Generalizations and future directions

The argument is a reusable template — *factor out $e^{p}$, then compare
degrees* — and extends along several axes.

### 9.1 General second-order operators

Replace the right-hand side $x\,y$ by $b(x)y + a(x)y'$ with $a,b\in\mathbb{R}[X]$.
Factoring out $e^{p}$ turns $f'' = b f + a f'$ into the single polynomial identity
$\operatorname{airyCoeff}(q,p) = b\,q + a\,(q' + q p')$, and a finite
degree-matching system governs the solvable cases, reusing the present
infrastructure with only the target polynomial changed.

### 9.2 Higher-order Airy-type equations

For $y^{(n)} = x\,y$ with $n \ge 3$, the $n$-th derivative of $q\,e^{p}$ factors
as $(\operatorname{coeff}_n(q,p))\,e^{p}$, where $\operatorname{coeff}_n$ is the
universal differential polynomial defined by the recursion
$\operatorname{coeff}_{n+1} = \operatorname{coeff}_n' + \operatorname{coeff}_n\,p'$
(i.e. iterating $L_p$). Its leading term is $q\,(p')^{n}$, so the degree excess is
$n\,\deg p'$, and a degree/parity obstruction generalizes the present argument.

### 9.3 Complex and entire prefactors

Over $\mathbb{C}$ the cancellation of $e^{p}$ still holds (it never vanishes) and
polynomial extensionality over the infinite field $\mathbb{C}$ transports the
algebraic identity unchanged, so the obstruction lifts verbatim from
$\mathbb{R}[X]$ to $\mathbb{C}[X]$. A further step asks whether any *entire*
prefactor $g$ of controlled growth gives $g\,e^{p}$ solving (Airy); here the
algebra must be supplemented with growth/order estimates.

### 9.4 Effective classification

Turn the obstruction into a decision procedure: given a polynomial-coefficient
linear ODE, decide and *construct* all $q\,e^{p}$ solutions by solving the finite
polynomial system of §8, connecting to the Risch and Kovacic algorithms for
Liouvillian solutions. The reduction to a single polynomial identity provides a
precise, machine-checked specification against which such a solver can be
verified.

### 9.5 Spectral / WKB interpretation

The parity obstruction admits a WKB reading: a leading exponential ansatz
$e^{p}$ for $y'' = xy$ would require $(p')^2 \approx x$, i.e. $p' \approx
x^{1/2}$, which is not a polynomial — the "$1/2$" is precisely the fractional
exponent that the integer degree count detects as the impossible equation
$2\deg p' = 1$. This links the elementary algebra to the asymptotic
$\mathrm{Ai}(x) \sim \tfrac{1}{2\sqrt{\pi}} x^{-1/4} e^{-\frac{2}{3} x^{3/2}}$ for
$x\to+\infty$, whose exponent $\tfrac23 x^{3/2}$ is manifestly non-polynomial.

## 10. Conclusion

We have given a fully rigorous, elementary, and machine-verified proof that no
exponential–polynomial $q\,e^{p}$ (with $q \neq 0$) solves Airy's equation
$y'' = x y$. The argument distils the deep differential-Galois nonsolvability of
Airy into a one-line parity fact about polynomial degrees, mediated by the Airy
coefficient $\operatorname{airyCoeff}(q,p) = q'' + 2q'p' + qp'' + q(p')^2$ and its
defining identity $(q e^{p})'' = \operatorname{airyCoeff}(q,p)\,e^{p}$. Beyond the
specific result, the method is a portable engine for ruling out — or, in solvable
cases, constructing — closed-form $q\,e^{p}$ solutions of polynomial-coefficient
linear ODEs.

## Appendix A. Index of formalized results

- `airyCoeff` — Definition 3.1, the polynomial $q'' + 2q'p' + qp'' + q(p')^2$.
- `airyCoeff_eq` — Lemma 3.2, the operator identity $L_p(L_p q) =
  \operatorname{airyCoeff}(q,p)$.
- `degree_airyCoeff_eq` — Lemma 4.1, $\deg\operatorname{airyCoeff}(q,p) =
  \deg q + 2\deg p'$ when $q\neq 0$, $p'\neq 0$.
- `airyCoeff_ne_X_mul` — Theorem 4.2, $\operatorname{airyCoeff}(q,p) \neq X q$ for
  $q\neq 0$.
- `hasDerivAt_poly_mul_exp` — Lemma 5.1, the first-derivative formula.
- `second_deriv_poly_mul_exp` — Theorem 5.2, $(q e^{p})'' =
  \operatorname{airyCoeff}(q,p)\,e^{p}$.
- `no_exp_poly_solves_airy` — Theorem 6.1, the main impossibility result.
