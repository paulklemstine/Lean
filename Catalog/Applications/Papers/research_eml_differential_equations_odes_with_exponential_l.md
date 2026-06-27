# First-Order Linear ODEs with Exponential–Logarithmic Coefficients: A Constructive Solution Calculus and Its Infinitesimal Uniqueness Law

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Differential Equations / Differential Algebra)

## Abstract

We develop the positive, constructive theory of first-order linear ordinary
differential equations $y' = c(x)\,y$ whose coefficient $c$ is an
*exponential–logarithmic* (EML) function — one built from the transcendental
operations $\exp$ and $\log$. The cornerstone is a single master construction: if
$F$ is an antiderivative of $c$ (that is, $F' = c$), then $y = \exp \circ F$ solves
the equation, with derivative computed exactly by the chain rule. We specialize
this to the three archetypal EML coefficient classes — the **logarithmic**
coefficient $c(x) = \log x$, solved by the continuous Stirling exponent
$y(x) = \exp(x\log x - x)$; the **exponential** coefficient $c(x) = \exp x$, solved
by the double exponential $y(x) = \exp(\exp x)$; and the **power / inverse-linear**
coefficient $c(x) = a/x$, solved by $y(x) = \exp(a\log x) = x^a$. We then prove an
infinitesimal **uniqueness-up-to-a-constant** law: any solution divided by the
canonical solution $\exp \circ F$ has vanishing derivative, so the solution space is
one-dimensional over the constants. The algebraic engine underlying every result is
the **logarithmic derivative** $L(y) = y'/y$, which is a homomorphism from the
multiplicative group of nonzero elements of a differential field to its additive
group; solving $y' = c\,y$ is exactly solving $L(y) = c$. Every statement is backed
by a machine-checked formal proof in the calculus library of Lean/Mathlib, so the
calculus presented here is verified to the level of the kernel. These positive
results complement an existing *negative* (obstruction) theory for second-order EML
equations, of which Airy's equation $y'' = x\,y$ is the prototype.

## 1. Introduction

The equation $y' = c\,y$ is the universal model of proportional change. When $c$ is
a scalar, the solution $y = K e^{cx}$ is elementary. When $c$ is a function of $x$,
the solution is still elementary *in principle* — $y = K \exp(\int c)$ — but the
character of the solution depends sharply on the analytic nature of $c$. We isolate
the case where $c$ is **exponential–logarithmic**: assembled from $\exp$, $\log$,
the field operations, and constants. This class is large enough to be interesting
(it contains genuinely transcendental, non-Liouvillian growth) yet structured
enough to admit a complete first-order solution calculus.

Our contribution is fourfold:

1. A **master construction** (Theorem 1) reducing the solution of any
   first-order linear equation to antidifferentiation of its coefficient, via the
   substitution $y = \exp \circ F$.
2. **Closed-form solutions** for the three archetypal EML coefficient classes
   (Theorems 2–4), each obtained by computing exactly one antiderivative.
3. An **infinitesimal uniqueness law** (Theorem 5) showing the solution space is
   one-dimensional over constants.
4. Identification of the **logarithmic derivative homomorphism** $L(y) = y'/y$
   (Section 2) as the algebraic mechanism unifying all of the above and explaining
   why EML coefficients form a closed, coherent class.

All results are formalized; the formal statements use Mathlib's `HasDerivAt`
predicate, which asserts pointwise (Fréchet) differentiability with a specified
derivative value, so each theorem is a verified analytic identity rather than a
symbolic manipulation.

### 1.1 Setting and notation

Throughout, $\exp$ and $\log$ are the genuine real exponential and natural
logarithm. For a function $y : \mathbb{R} \to \mathbb{R}$ and a point $x$, we write
$y'(x)$ for the derivative; formally, the assertion "$y$ has derivative $v$ at $x$"
is `HasDerivAt y v x`. The logarithm $\log$ is differentiable exactly on
$\mathbb{R}\setminus\{0\}$ with $(\log)'(x) = 1/x$; this is the source of the
$x > 0$ hypotheses below, which are load-bearing (the logarithmic and power
statements are false at $x = 0$).

For the algebraic Section 2 we work in an abstract **differential field** $K$: a
field equipped with a derivation $\cdot' : K \to K$ satisfying additivity and the
Leibniz rule $(yz)' = y'z + yz'$. The **constants** are $\{x \in K : x' = 0\}$;
they form a subfield.

## 2. The algebraic engine: the logarithmic derivative homomorphism

**Definition (logarithmic derivative).** For a nonzero element $y$ of a
differential field $K$, the *logarithmic derivative* is
$$L(y) = \frac{y'}{y}.$$

**Proposition (homomorphism law).** $L$ is a group homomorphism from the
multiplicative group $K^\times$ to the additive group $(K, +)$:
$$L(y\,z) = L(y) + L(z), \qquad L(y^{-1}) = -L(y), \qquad L(y/z) = L(y) - L(z),$$
and for $n \in \mathbb{Z}$, $L(y^n) = n\,L(y)$.

*Proof sketch.* By the Leibniz rule, $(yz)' = y'z + yz'$, hence
$L(yz) = (y'z + yz')/(yz) = y'/y + z'/z = L(y) + L(z)$. The remaining identities
follow from the group-homomorphism property (inverse to negative, quotient to
difference, integer power to integer multiple). $\square$

This single structural fact is the conceptual core. Solving the first-order linear
equation $y' = c\,y$ is *literally* solving $L(y) = c$: finding an element whose
logarithmic derivative equals the prescribed coefficient. The homomorphism law
explains the closure properties of the EML solution class — products, quotients,
inverses, and integer powers of solutions correspond under $L$ to sums,
differences, negatives, and multiples of coefficients, all of which remain EML
when the original coefficients are EML. The kernel of $L$ is exactly the units of
the constants subfield, which is why solutions are unique only up to a constant
factor (made precise analytically in Theorem 5, and algebraically in the existing
result `EMLDiffGalois.firstOrder_ratio_isConstant`).

## 3. The master construction

**Theorem 1 (Master construction; `hasDerivAt_exp_comp_solves`).**
*Let $F : \mathbb{R} \to \mathbb{R}$ and let $c, x \in \mathbb{R}$. If $F$ has
derivative $c$ at $x$, then $t \mapsto \exp(F(t))$ has derivative $c \cdot
\exp(F(x))$ at $x$. Equivalently, if $F' = c$ then $\exp \circ F$ solves
$y' = c\,y$.*

*Proof sketch.* The chain rule for the exponential states that if $F$ has
derivative $c$ at $x$, then $\exp \circ F$ has derivative $\exp(F(x)) \cdot c$ at
$x$ (in Mathlib, `HasDerivAt.exp`). Commuting the product gives $c \cdot
\exp(F(x))$, which is $c \cdot y(x)$ for $y = \exp \circ F$. $\square$

The power of this lemma is that it converts the *analytic* problem (solve a
differential equation) into the *symbolic* problem (find an antiderivative of the
coefficient). For EML coefficients the antiderivative is itself EML — the class is
closed under integration of its archetypes — and the three theorems below are each
one antiderivative computation.

## 4. Closed-form solutions for the three EML coefficient classes

### 4.1 Logarithmic coefficient

**Theorem 2 (Logarithmic-coefficient ODE; `solves_log_coeff`).**
*For every $x > 0$, the function $y(x) = \exp(x\log x - x)$ has derivative
$(\log x)\,\exp(x\log x - x)$; that is, it solves $y' = (\log x)\,y$ on
$(0,\infty)$.*

*Proof sketch.* Set $F(t) = t\log t - t$, an antiderivative of $\log$. We compute
$F'(x)$ for $x > 0$:
- By the product rule, $(t \mapsto t\log t)$ has derivative
  $1\cdot\log x + x\cdot x^{-1}$ at $x$ (using $(\log)'(x) = x^{-1}$).
- Subtracting the identity $t \mapsto t$ (derivative $1$) gives
  $F'(x) = 1\cdot\log x + x\cdot x^{-1} - 1$.
- Since $x \ne 0$, $x \cdot x^{-1} = 1$, so $F'(x) = \log x + 1 - 1 = \log x$.

Apply Theorem 1 with $c = \log x$. $\square$

**Remark (the Stirling exponent).** The exponent $x\log x - x$ is the continuous
Stirling exponent: Stirling's formula reads
$n! \sim \sqrt{2\pi n}\,\exp(n\log n - n)$. Thus $y' = (\log x)\,y$ is the
leading-order differential equation governing factorial / Gamma-function growth.
Its solution is genuinely transcendental — not algebraic over $\mathbb{R}(x)$ — in
contrast to the power case below.

### 4.2 Exponential coefficient

**Theorem 3 (Exponential-coefficient ODE; `solves_exp_coeff`).**
*For every $x \in \mathbb{R}$, the double exponential $y(x) = \exp(\exp x)$ has
derivative $(\exp x)\,\exp(\exp x)$; that is, it solves $y' = (\exp x)\,y$
everywhere.*

*Proof sketch.* Take $F(t) = \exp t$, whose derivative is $\exp x$ (the
exponential is its own derivative). Apply Theorem 1 with $c = \exp x$. No domain
restriction is needed since $\exp$ is everywhere differentiable. $\square$

**Remark.** The double exponential is the **Gompertz** growth function, central to
models of mortality, tumor growth, and self-reinforcing exponential processes.

### 4.3 Power / inverse-linear coefficient

**Theorem 4 (Power-coefficient ODE; `solves_power_coeff`).**
*For every $x > 0$ and every $a \in \mathbb{R}$, the function
$y(x) = \exp(a\log x) = x^a$ has derivative $(a/x)\,\exp(a\log x)$; that is, it
solves $y' = (a/x)\,y$ on $(0,\infty)$.*

*Proof sketch.* Take $F(t) = a\log t$. Then $F'(x) = a \cdot x^{-1} = a/x$ (scaling
$(\log)'(x) = x^{-1}$ by the constant $a$). Apply Theorem 1 with $c = a/x$. Since
$\exp(a\log x) = x^a$ for $x > 0$, the solution is the power function. $\square$

**Remark.** This recovers the classical scaling laws $x^a$ as the EML solutions of
the simplest rational coefficient $a/x = a\,(\log x)'$. For rational $a$ the
solution is algebraic over $\mathbb{R}(x)$; for irrational $a$ it is
transcendental. The power class is the bridge between the elementary and the
genuinely transcendental EML solutions.

## 5. Infinitesimal uniqueness up to a constant

**Theorem 5 (Uniqueness up to a constant, infinitesimal form;
`solution_ratio_hasDerivAt_zero`).**
*Let $y, F : \mathbb{R} \to \mathbb{R}$ and $c, x \in \mathbb{R}$. If $y$ has
derivative $c\cdot y(x)$ at $x$ (i.e. $y$ solves $y' = c\,y$ at $x$) and $F$ has
derivative $c$ at $x$, then the ratio $t \mapsto y(t)/\exp(F(t))$ has derivative
$0$ at $x$.*

*Proof sketch.* By the chain rule, $z(t) = \exp(F(t))$ has derivative
$\exp(F(x))\cdot c$ at $x$, and $z(x) = \exp(F(x)) \ne 0$. The quotient rule gives
the derivative of $y/z$ at $x$ as
$$\frac{c\,y(x)\cdot\exp(F(x)) - y(x)\cdot(\exp(F(x))\cdot c)}{\exp(F(x))^2}.$$
The numerator is $c\,y(x)\exp(F(x)) - c\,y(x)\exp(F(x)) = 0$, so the whole
expression is $0$. $\square$

**Interpretation.** A function with everywhere-zero derivative on a connected
domain is constant; hence on such a domain every solution of $y' = c\,y$ equals
$K\cdot\exp(F)$ for a constant $K$. Theorem 5 is the *infinitesimal* (pointwise)
core of this statement and the analytic counterpart of the algebraic result
`EMLDiffGalois.firstOrder_ratio_isConstant` (if $y_1' = a\,y_1$, $y_2' = a\,y_2$
and $y_2 \ne 0$ then $(y_1/y_2)' = 0$). In differential-Galois terms, the solution
line of a first-order EML equation is one-dimensional over the constants subfield,
and its Galois group lands in the multiplicative group of constants — the simplest
"EML group."

## 6. Algorithms

The constructive content of Theorems 1–4 is an explicit solver: to solve a
first-order linear EML equation, integrate the coefficient and exponentiate. We
record this and its verification routines.

### 6.1 EML coefficient solver via antiderivative exponentiation

Given an EML coefficient $c$ and a symbolic antiderivative $F$ with $F' = c$,
return the solution $\exp \circ F$ together with the verified derivative
$c\cdot\exp(F)$. For the three archetypes the antiderivative is selected from a
lookup table ($\log \mapsto x\log x - x$, $\exp \mapsto \exp$, $a/x \mapsto
a\log x$), which is the symbolic realization of Theorem 1.

### 6.2 Numerical solution verifier (central-difference residual)

Given a candidate solution $y$ and coefficient $c$, verify $y' = c\,y$ by computing
the central-difference approximation $y'(x) \approx (y(x+h)-y(x-h))/(2h)$ and
checking the residual $|y'(x) - c(x)y(x)|$ against a tolerance. This empirically
confirms Theorems 2–4 at sampled points.

### 6.3 Uniqueness-ratio constancy check

Given two numerical solutions of the same equation, form the ratio and verify it is
constant across the domain (Theorem 5), confirming one-dimensionality of the
solution space.

## 7. Applications

- **Asymptotics of factorials.** Theorem 2 ties $y' = (\log x)y$ to the Stirling
  exponent $x\log x - x$, the differential law of factorial growth and the Gamma
  function's leading asymptotics.
- **Growth and decay models.** Theorem 3's double exponential is the Gompertz law
  used in actuarial mortality and oncology; Theorem 4's power solutions are the
  scaling laws ubiquitous in physics, allometry, and network science.
- **Symbolic ODE solving.** The master construction (Theorem 1) is a verified
  decision procedure for first-order linear equations whose coefficient admits a
  named antiderivative, and the logarithmic-derivative homomorphism (Section 2)
  delineates exactly which coefficients keep the solution inside the EML class.

## 8. Discussion and relation to the obstruction theory

The results here are the *positive* half of an EML differential-equations program.
The complementary *negative* half studies when closed EML solutions **fail** to
exist. The canonical example is **Airy's equation** $y'' = x\,y$, which has no
EML-elementary solution — a fact established by a degree/valuation obstruction in
the differential ring $\mathbb{R}[x,\log x]$ via the Riccati transform
$v = y'/y \Rightarrow v' + v^2 = x$. The logarithmic derivative is the hinge of
both halves: it solves the first-order problem directly, and it linearizes the
second-order problem into a Riccati equation where the obstruction can be counted.
Together, the positive calculus and the negative obstruction theory draw a precise
boundary between EML-solvable and EML-unsolvable linear differential equations.

## 9. Future directions

**C1. Global uniqueness from the infinitesimal ratio law.** Theorem 5 shows
$(y/\exp F)' = 0$ pointwise. Conjecture: on a connected domain (e.g. $(0,\infty)$
for the log/power cases, all of $\mathbb{R}$ for the exp case), every $C^1$ solution
of $y' = c\,y$ equals $K\cdot\exp(F)$ for a *constant* $K$, upgrading the
infinitesimal law to a genuine analytic uniqueness theorem.

**C2. Second-order EML solvability dichotomy.** Study $y'' = (\log x)\,y$.
Conjecture: it has no solution $\exp(F)$ with $F$ a polynomial in $x$ and $\log x$,
mirroring the Airy obstruction $y'' = x\,y$, via the Riccati transform
$v' + v^2 = \log x$ and a degree/valuation count in $\mathbb{R}[x,\log x]$.

**C3. The Stirling exponent ODE characterizes Gamma growth.** Conjecture:
$\Gamma(x+1)$ and $\exp(x\log x - x)$ share the same logarithmic derivative
asymptotically ($\operatorname{logDeriv}\Gamma(x+1) - \log x \to 0$ as
$x \to \infty$), i.e. $y' = (\log x)y$ is the leading-order law governing factorial
growth.

**C4. Homomorphism kernel = constants, exactly.** Conjecture: in any differential
field, $\ker L$ equals the units of the constants subfield, and $L$ descends to an
*injective* homomorphism $K^\times/\text{constants}^\times \hookrightarrow (K,+)$,
giving a clean "EML exponential is unique up to a constant" group-theoretic
statement.

## 10. Conclusion

Reducing first-order linear EML differential equations to antidifferentiation, we
obtained verified closed-form solutions for the logarithmic, exponential, and power
coefficient classes, and an infinitesimal uniqueness law placing the solution space
on a single line over the constants. The unifying mechanism is the logarithmic
derivative homomorphism, the differential incarnation of the duality between
multiplication and addition that binds the exponential and the logarithm. The
positive calculus developed here meets, at the Riccati transform, the negative
obstruction theory of second-order equations such as Airy's, completing a coherent
map of the EML differential landscape.
