# Exponential–Logarithmic Differential Equations: Closed-Form Solvability and the Failure of Kovacic's First Two Cases for Airy's Equation

**Author:** Aristotle
**Date:** 2026-08-04

---

## Abstract

We develop a self-contained theory of *exponential–logarithmic* (EML) functions — the real functions generated from the identity, real constants, addition, multiplication, inversion, $\exp$ and $\log$ — and use it to analyse the closed-form solvability of the second-order linear equation $y'' = r\,y$ with polynomial coefficient $r$, with the Airy equation $y'' = x\,y$ as the guiding case.

Three groups of results are established. First, a *syntax* for EML functions together with a symbolic derivative operator and a pointwise regularity predicate, for which we prove **correctness of symbolic differentiation**: on its regularity locus, an EML expression defines a differentiable function whose analytic derivative is exactly the function defined by the symbolically differentiated expression, and regularity propagates to the derivative. This makes the class of EML functions provably closed under differentiation and permits induction over all closed forms at once. As an application we give the complete solution theory of the first-order linear EML equation $y' = c\,y$: exponentials of antiderivatives are solutions, and every solution is a constant multiple of one.

Second, we establish the algebraic obstructions underlying **Kovacic's first case**. Via the Riccati correspondence $u = y'/y$, we prove that for polynomial $r$ of *odd* degree the equation $u' + u^{2} = r$ has no solution in the rational function field; that a polynomial Riccati solution has its degree and leading coefficient completely determined by $r$ ($\deg r = 2\deg u$, $\operatorname{lc} r = (\operatorname{lc} u)^{2}$); and that for $r\ne 0$ the linear equation $y'' = r y$ has no nonzero rational solution. Combining with the analytic Riccati correspondence yields: **Airy's equation admits no EML solution of exponential type $y = e^{F}$ with $F'$ rational.** We show the odd-degree hypothesis is sharp: for $r = x^{2}+1$, $u = x$ solves the Riccati equation and $y = e^{x^{2}/2}$ is a genuine EML solution.

Third, we treat **Kovacic's second case**. We derive analytically the second symmetric power equation $v''' = 4rv' + 2r'v$ satisfied by any product $v = y_1y_2$ of solutions, we compute the exact leading coefficient of the cleared right-hand side for $r = x$, namely $\bigl(4(\deg P - \deg Q)+2\bigr)\operatorname{lc}(P)\operatorname{lc}(Q)^{3}$, and we show it can never vanish in characteristic zero while the cleared left-hand side has strictly smaller degree. Hence $v''' = 4xv' + 2v$ has no nonzero polynomial and no nonzero rational solution, and consequently **no product of two solutions of Airy's equation is a nonzero rational function**.

Together these results exclude Kovacic's cases 1 and 2 for Airy's equation and reduce the classical transcendence statement to two elementary arithmetic facts: $2p$ is even while $2q+1$ is odd, and $4k+2 \neq 0$ for every integer $k$.

**Keywords:** exponential–logarithmic functions, closed-form solvability, Riccati equation, Kovacic algorithm, Airy equation, symmetric power equation, differential Galois theory, degree counting.

---

## 1. Introduction

### 1.1 The problem

Airy's equation
$$y'' = x\,y \tag{1.1}$$
was introduced in 1838 in the study of light intensity near a caustic. It is the canonical model of a *turning point*: for $x<0$ its solutions oscillate with slowly decreasing wavelength, for $x>0$ they grow or decay exponentially, and the transition at $x = 0$ governs phenomena from the supernumerary rainbow to quantum tunnelling, from radio propagation past the horizon to the edge scaling limits of random matrix ensembles.

Its solutions $\operatorname{Ai}$ and $\operatorname{Bi}$ are entire functions with an everywhere-convergent power series, an integral representation, and well-understood asymptotics; they are, however, not expressible in elementary closed form. Our purpose is to make that impossibility precise and to prove the parts of it accessible by finite algebraic means.

### 1.2 What "closed form" means here

We fix a concrete and syntactic notion.

> **Definition 1.1 (EML expression).** The set of *exponential–logarithmic (EML) expressions* is the smallest set of finite trees containing the symbol $X$ and a symbol $\underline{c}$ for each real constant $c$, and closed under the formation rules $A + B$, $A \cdot B$, $A^{-1}$, $\exp A$, $\log A$.

> **Definition 1.2 (Interpretation).** The *evaluation* $\llbracket \cdot \rrbracket : \text{EML} \to (\mathbb{R} \to \mathbb{R})$ is defined recursively by
> $$\llbracket X\rrbracket(x)=x,\quad \llbracket \underline c\rrbracket(x)=c,\quad \llbracket A+B\rrbracket = \llbracket A\rrbracket+\llbracket B\rrbracket,\quad \llbracket A\cdot B\rrbracket = \llbracket A\rrbracket\llbracket B\rrbracket,$$
> $$\llbracket A^{-1}\rrbracket(x)=\bigl(\llbracket A\rrbracket(x)\bigr)^{-1},\quad \llbracket \exp A\rrbracket(x)=e^{\llbracket A\rrbracket(x)},\quad \llbracket \log A\rrbracket(x)=\log \llbracket A\rrbracket(x),$$
> with the conventions $0^{-1} = 0$ and $\log t = 0$ for $t \le 0$ used as junk values outside the regular locus defined below.

The junk-value convention makes evaluation a total function; it never enters a theorem, because all analytic statements are made at *regular* points.

> **Definition 1.3 (Regularity).** The predicate $\operatorname{Reg}(E, x)$ ("$E$ is regular at $x$") is defined recursively: $\operatorname{Reg}(X,x)$ and $\operatorname{Reg}(\underline c, x)$ always hold; $\operatorname{Reg}(A+B,x)$ and $\operatorname{Reg}(A\cdot B,x)$ hold iff both $\operatorname{Reg}(A,x)$ and $\operatorname{Reg}(B,x)$ do; $\operatorname{Reg}(\exp A, x)$ iff $\operatorname{Reg}(A,x)$; and $\operatorname{Reg}(A^{-1},x)$, resp. $\operatorname{Reg}(\log A, x)$, iff $\operatorname{Reg}(A,x)$ **and** $\llbracket A\rrbracket(x)\ne 0$.

Thus regularity is exactly the condition that no inversion and no logarithm in the tree has vanishing argument.

The class of EML functions contains every function usually called elementary: $x^{a} = \exp(a\log x)$ on $x>0$; $\sqrt{x}$; rational functions; and — over the complexification — the trigonometric and hyperbolic families, since $\cos u = \tfrac12(e^{iu}+e^{-iu})$. Fixing the syntax is what allows us to quantify over *all* closed forms simultaneously; without it, "there is no formula" is not a mathematical statement.

### 1.3 Overview of the results

* §2 develops the differential calculus of EML expressions: a symbolic derivative $D$, correctness of $D$, propagation of regularity, and the complete theory of the first-order equation.
* §3 recalls the Riccati correspondence and proves it for genuine real functions.
* §4 contains the algebraic obstructions for Kovacic's case 1: the odd-degree Riccati theorem, the degree determination theorem, and the non-existence of rational solutions of $y'' = ry$ for $r \ne 0$.
* §5 assembles these into the analytic statement that Airy admits no EML solution of exponential type with rational logarithmic derivative, and proves sharpness of the odd-degree hypothesis.
* §6 treats Kovacic's case 2: the second symmetric power, its cleared-denominator form, the exact top coefficient, and the conclusion that no product of Airy solutions is rational.
* §7 discusses algorithms, §8 applications, §9 future work.

---

## 2. The differential calculus of EML expressions

### 2.1 Symbolic differentiation

> **Definition 2.1 (Symbolic derivative).** Define $D : \text{EML} \to \text{EML}$ by
> $$D(X) = \underline 1, \qquad D(\underline c) = \underline 0, \qquad D(A+B) = D A + D B,$$
> $$D(A\cdot B) = (DA)\cdot B + A\cdot (DB), \qquad D(A^{-1}) = \underline{(-1)}\cdot\bigl(DA \cdot (A^{-1}\cdot A^{-1})\bigr),$$
> $$D(\exp A) = DA \cdot \exp A, \qquad D(\log A) = DA \cdot A^{-1}.$$

Every right-hand side is again an EML expression: **the class of closed forms is syntactically closed under differentiation.** This is the structural reason a second-order equation can be attacked by algebra at all.

> **Theorem 2.2 (Correctness of symbolic differentiation).** Let $E$ be an EML expression and $x \in \mathbb{R}$ with $\operatorname{Reg}(E,x)$. Then $\llbracket E\rrbracket$ is differentiable at $x$ and
> $$\bigl(\llbracket E\rrbracket\bigr)'(x) = \llbracket DE\rrbracket(x).$$

*Proof sketch.* Structural induction on $E$. The base cases $X$ and $\underline c$ are the derivative of the identity and of a constant. The cases $A+B$ and $A\cdot B$ are the sum and product rules applied to the inductive hypotheses, which are available since regularity of a sum or product is regularity of both factors. For $A^{-1}$ regularity supplies $\llbracket A\rrbracket(x)\ne 0$, so the reciprocal rule applies and gives $-\llbracket DA\rrbracket(x)/\llbracket A\rrbracket(x)^{2}$, which is precisely $\llbracket D(A^{-1})\rrbracket(x)$. For $\exp A$ and $\log A$ one composes with the inductive hypothesis, using $\llbracket A\rrbracket(x)\neq 0$ in the logarithmic case. $\square$

> **Theorem 2.3 (Propagation of regularity).** If $\operatorname{Reg}(E,x)$ then $\operatorname{Reg}(DE, x)$.

*Proof sketch.* Structural induction again; one checks that every inversion or logarithm occurring in $DE$ occurs already in $E$, applied to the same argument. For instance $D(A^{-1})$ contains only the inversions of $A$ (twice) and those inside $DA$, and the inductive hypothesis handles the latter. $\square$

Theorems 2.2 and 2.3 together give the statement one actually uses: *an EML function may be differentiated arbitrarily often on the regularity locus of the original expression, never leaving that locus and never leaving the EML class.*

### 2.2 First-order linear equations

> **Theorem 2.4 (Exponentials solve first-order linear equations).** Let $F$ be an EML expression regular at $x$. Then the EML function $y = \exp\circ\,\llbracket F\rrbracket$ is differentiable at $x$ and
> $$y'(x) = \llbracket DF\rrbracket(x)\;y(x).$$

*Proof sketch.* Apply Theorem 2.2 to the expression $\exp F$, whose symbolic derivative is $DF\cdot \exp F$ by definition. $\square$

> **Theorem 2.5 (Uniqueness up to a constant).** Let $F$ be regular at every point of $\mathbb{R}$ and let $y : \mathbb{R}\to\mathbb{R}$ satisfy $y'(x) = \llbracket DF\rrbracket(x)\,y(x)$ for all $x$. Then there is a constant $K$ with $y(x) = K\,e^{\llbracket F\rrbracket(x)}$ for all $x$.

*Proof sketch.* Put $g(x) = y(x)e^{-\llbracket F\rrbracket(x)}$. By Theorem 2.2 applied to $F$ and the product rule,
$$g'(x) = y'(x)e^{-\llbracket F\rrbracket(x)} - \llbracket DF\rrbracket(x)\,y(x)e^{-\llbracket F\rrbracket(x)} = 0 .$$
A function with vanishing derivative on all of $\mathbb{R}$ is constant, so $g \equiv g(0) =: K$; multiplying back by $e^{\llbracket F\rrbracket(x)}$ gives the claim. $\square$

**Consequence.** The first-order linear EML equation is *completely solved*: closed-form solvability of $y' = c\,y$ is equivalent to existence of an EML antiderivative of $c$, and the solution space is then one-dimensional, spanned by a nowhere-vanishing exponential. All genuinely new phenomena therefore begin in order two.

---

## 3. The Riccati correspondence

The passage from the linear second-order equation to a first-order nonlinear one is the mechanism by which the *shape* of a solution becomes an algebraic condition.

> **Theorem 3.1 (Linear $\Rightarrow$ Riccati).** Let $r, y, u, w : \mathbb{R}\to\mathbb{R}$ with $y$ nowhere zero, $y' = u\,y$, $u' = w$ (i.e. $w$ is the derivative of $u$), and $(u\,y)' = r\,y$. Then
> $$w + u^{2} = r \quad\text{pointwise.}$$

*Proof sketch.* Differentiating $y' = uy$ by the product rule gives $y'' = u'y + u y' = (w + u^{2})y$. Comparing with $y'' = ry$ yields $(w+u^{2}-r)\,y = 0$ pointwise; since $y$ never vanishes, the first factor vanishes. $\square$

> **Theorem 3.2 (Riccati $\Rightarrow$ linear).** Conversely, if $u' = w$, $w + u^{2} = r$ and $y' = uy$, then $(u y)' = r y$, i.e. $y'' = ry$.

*Proof sketch.* $(uy)' = u'y + uy' = wy + u^{2}y = ry$. $\square$

> **Lemma 3.3 (Logarithmic derivatives add).** If $f, g$ are differentiable and nonvanishing at $x$, then
> $$(fg)'(x) = \left(\frac{f'(x)}{f(x)} + \frac{g'(x)}{g(x)}\right)f(x)g(x).$$

*Proof sketch.* Product rule and division by $f(x)g(x)$. $\square$

Lemma 3.3 is the group law behind the exponential parametrisation: logarithmic differentiation converts the multiplicative structure of nonvanishing solutions into the additive structure of their Riccati counterparts. It is the reason a *product* of two solutions has a manageable equation (Theorem 6.1) and hence the reason Kovacic's case 2 is decidable.

### 3.1 Kovacic's trichotomy

For $y'' = ry$ with $r$ rational, if any nonzero solution is Liouvillian (built from rational functions by finitely many integrations, exponentiations and algebraic extensions) then exactly one of the following holds:

1. **Case 1.** Some solution satisfies $y'/y \in \mathbb{C}(x)$.
2. **Case 2.** Case 1 fails but some solution has $y'/y$ algebraic of degree $2$; equivalently, some product $y_1y_2$ of two solutions lies in $\mathbb{C}(x)$, i.e. the second symmetric power equation has a rational solution.
3. **Case 3.** All solutions are algebraic over $\mathbb{C}(x)$, of degree $4$, $6$ or $12$.

Each case leaves a *rational* fingerprint, and this is what makes closed-form solvability decidable. §§4–5 eliminate case 1 for Airy; §6 eliminates case 2.

---

## 4. Algebraic obstructions I: rational Riccati solutions

Throughout this section $K$ is a field, $K[X]$ its polynomial ring, and $\operatorname{lc}$ denotes the leading coefficient. We write $p = \deg P$, $q = \deg Q$.

### 4.1 The Wronskian numerator

> **Definition 4.1.** For $P, Q \in K[X]$, the *Wronskian numerator* is $W(P,Q) := P'Q - PQ'$. It is the numerator of the derivative of $P/Q$: formally, $(P/Q)' = W(P,Q)/Q^{2}$.

> **Lemma 4.2 (Degree drop).** For nonzero $A, B \in K[X]$ and any $c \in K$,
> $$\deg\bigl(A'B - c\,(A B')\bigr) < \deg A + \deg B .$$
> In particular $\deg W(P,Q) < p + q$ for nonzero $P,Q$ (take $c=1$).

*Proof sketch.* $\deg A' < \deg A$, hence $\deg(A'B) \le \deg A' + \deg B < \deg A + \deg B$; similarly $\deg(AB') < \deg A + \deg B$; multiplying by the constant $c$ cannot raise the degree; the degree of a difference is at most the maximum of the degrees. $\square$

> **Lemma 4.3 (Top coefficient of $A'B$).** If $\deg A + \deg B \ge 1$ then the coefficient of $x^{\deg A + \deg B - 1}$ in $A'B$ equals $(\deg A)\operatorname{lc}(A)\operatorname{lc}(B)$.

*Proof sketch.* If $\deg A = 0$ then $A' = 0$ and both sides vanish. Otherwise index shift: since $\deg A' \le \deg A - 1$, the coefficient of $x^{(\deg A - 1) + \deg B}$ in $A'B$ is $[x^{\deg A - 1}]A' \cdot \operatorname{lc}(B)$, and $[x^{\deg A - 1}]A' = (\deg A)\operatorname{lc}(A)$ by the coefficientwise formula for the derivative. $\square$

> **Proposition 4.4 (Top coefficient of the Wronskian numerator).** For $P, Q \in K[X]$,
> $$[x^{\,p+q-1}]\;W(P,Q) = (p - q)\,\operatorname{lc}(P)\operatorname{lc}(Q),$$
> where $p - q$ is read in $K$ via the canonical map $\mathbb{Z}\to K$.

*Proof sketch.* Apply Lemma 4.3 to $P'Q$ and, after commuting the factors, to $Q'P$, and subtract; the products $\operatorname{lc}(P)\operatorname{lc}(Q)$ factor out. The degenerate case $p+q = 0$ (both constant) is immediate since then $W = 0$ and $p-q=0$. $\square$

Proposition 4.4 is the quantitative heart of §6. Note the phenomenon it exposes: the Wronskian numerator has *strictly smaller* degree than $p+q$ exactly when $p \equiv q$ in $K$ — i.e. in characteristic zero, exactly when $p = q$ — and otherwise degree exactly $p+q-1$.

### 4.2 The odd-degree obstruction

Clearing denominators in $u' + u^{2} = r$ with $u = P/Q$ gives
$$P'Q - PQ' + P^{2} \;=\; r\,Q^{2}. \tag{4.1}$$

> **Theorem 4.5 (Odd-degree Riccati obstruction).** Let $r \in K[X]$ have odd degree. Then there are no $P, Q \in K[X]$ with $Q \ne 0$ satisfying (4.1). Equivalently, $u' + u^{2} = r$ has no solution in the rational function field $K(x)$.

*Proof sketch.* First, $r \ne 0$ (the zero polynomial has degree $0$ in the natural-number convention used here, which is even, so an odd degree forces $r \ne 0$). If $P = 0$, (4.1) reads $0 = rQ^{2}$, impossible. So assume $P, Q \ne 0$ and split:

*Case $q \le p$.* By Lemma 4.2, $\deg W(P,Q) < p+q \le 2p = \deg P^{2}$. Hence the left-hand side of (4.1) has degree exactly $2p$. The right-hand side has degree $\deg r + 2q$. Therefore $2p = \deg r + 2q$, so $\deg r = 2(p-q)$ is even — contradicting oddness.

*Case $p < q$.* Then $\deg W(P,Q) < p + q \le \deg r + 2q$ (using $\deg r \ge 1$, which follows from oddness) and $\deg P^{2} = 2p < \deg r + 2q$. So the left-hand side has degree strictly less than $\deg r + 2q$, which is the degree of the right-hand side — contradiction. $\square$

> **Corollary 4.6 (Airy Riccati).** The equation $u' + u^{2} = x$ has no rational solution: for all $P, Q \in K[X]$ with $Q \neq 0$,
> $$P'Q - PQ' + P^{2} \;\ne\; X\,Q^{2}.$$

*Proof.* $\deg X = 1$ is odd; apply Theorem 4.5. $\square$

### 4.3 Degree determination for polynomial Riccati solutions

> **Theorem 4.7 (Degree and leading coefficient are forced).** Let $u \in K[X]$ be nonzero with $u' + u^{2} = r$. Then
> $$\deg r = 2\deg u \qquad\text{and}\qquad \operatorname{lc}(r) = \operatorname{lc}(u)^{2}.$$

*Proof sketch.* $\deg u' < \deg u \le 2\deg u = \deg u^{2}$, so in the sum $u' + u^{2}$ the term $u^{2}$ dominates: the degree and the leading coefficient of the sum are those of $u^{2}$, namely $2\deg u$ and $\operatorname{lc}(u)^{2}$. $\square$

This is the finiteness statement that makes Kovacic's polynomial search terminate: given $r$, the degree of a putative polynomial Riccati solution is not merely bounded but *determined*, and its leading coefficient is determined up to sign; the remaining coefficients then satisfy a triangular system.

> **Corollary 4.8.** $u' + u^{2} = x$ has no *polynomial* solution: $\deg x = 1$ is not twice a natural number, and $u=0$ gives $0 \ne x$. $\square$

### 4.4 No rational solutions of $y'' = ry$

Successive quotient-rule numerators of $v = P/Q$ are
$$v' = \frac{W}{Q^{2}},\qquad W := P'Q - PQ', \tag{4.2}$$
$$v'' = \frac{B}{Q^{3}},\qquad B := W'Q - 2WQ', \tag{4.3}$$
$$v''' = \frac{Z}{Q^{4}},\qquad Z := B'Q - 3BQ'. \tag{4.4}$$
(Each identity is the quotient rule together with the cancellation of one factor of $Q$ from numerator and denominator.)

> **Theorem 4.9 (No rational solutions).** Let $r, P, Q \in K[X]$ with $r \ne 0$, $P \ne 0$, $Q \ne 0$. Then
> $$W'Q - 2WQ' \;\ne\; r\,P\,Q^{2}, \qquad W = P'Q - PQ',$$
> i.e. $y'' = ry$ has no nonzero rational solution $y = P/Q$.

*Proof sketch.* Substituting (4.2)–(4.3) into $v''=rv$ and multiplying by $Q^{3}$ gives exactly the displayed identity. If $W = 0$ the left-hand side is $0$ while the right-hand side is a product of nonzero polynomials, a contradiction. Otherwise Lemma 4.2 twice: $\deg W < p+q$, and $\deg(W'Q - 2WQ') < \deg W + q < p + 2q$. But the right-hand side has degree $\deg r + p + 2q \ge p + 2q$. Contradiction. $\square$

> **Corollary 4.10 (Airy has no rational solution).** Taking $r = x$: no nonzero rational function solves $y'' = xy$. In particular no nonzero polynomial does — which one also sees directly, since $\deg y'' < \deg y < \deg(xy)$. $\square$

---

## 5. From algebra to analysis: Kovacic case 1 fails for Airy

The algebraic theorems above concern formal polynomial identities. The following results transfer them to genuine real functions.

> **Theorem 5.1 (No nowhere-vanishing solution has rational logarithmic derivative).** Let $P, Q$ be real polynomials with $Q$ nowhere vanishing on $\mathbb{R}$. Let $y : \mathbb{R}\to\mathbb{R}$ be nowhere zero with
> $$y'(x) = \frac{P(x)}{Q(x)}\,y(x)\quad\text{and}\quad \Bigl(\tfrac{P}{Q}\,y\Bigr)'(x) = x\,y(x)\qquad\text{for all }x .$$
> Then a contradiction follows: no such $y$ exists.

*Proof sketch.* By the quotient rule, $u := P/Q$ has derivative $\bigl(P'Q - PQ'\bigr)/Q^{2}$ at every $x$ (using $Q(x)\ne 0$). Uniqueness of derivatives applied to the two expressions for $(uy)'$ gives
$$\Bigl(x - \frac{P'Q-PQ'}{Q^{2}}(x) - \Bigl(\frac{P}{Q}(x)\Bigr)^{2}\Bigr)\,y(x) = 0 ,$$
and since $y(x)\neq0$ the bracket vanishes for every real $x$; this is the pointwise Riccati equation. Multiplying by $Q(x)^{2}$ yields
$$\bigl(P'Q - PQ' + P^{2}\bigr)(x) = \bigl(X\,Q^{2}\bigr)(x)\qquad\text{for all }x\in\mathbb{R} .$$
Two real polynomials agreeing at every real point are equal, so we obtain the polynomial identity forbidden by Corollary 4.6. $\square$

> **Theorem 5.2 (Airy has no EML solution of exponential type).** Let $F$ be an EML expression regular at every real point whose derivative is a rational function: $\llbracket DF\rrbracket = P/Q$ with $Q$ nowhere vanishing. Then $y = e^{\llbracket F\rrbracket}$ does **not** solve $y'' = x\,y$.

*Proof sketch.* By Theorem 2.4, $y' = \llbracket DF\rrbracket\,y = (P/Q)\,y$, and $y = e^{\llbracket F\rrbracket}$ is nowhere zero. If in addition $y'' = xy$, Theorem 5.1 applies and gives a contradiction. $\square$

This is precisely the failure of Kovacic's **first case** for Airy's equation: no solution of $y'' = xy$ has a rational logarithmic derivative, so no solution is of the form $\exp\int(\text{rational})$.

### 5.1 Sharpness

The odd-degree hypothesis in Theorem 4.5 cannot be dropped.

> **Proposition 5.3 (Even degree: an explicit counterexample).** For $r = x^{2}+1$ the Riccati equation $u'+u^{2} = r$ has the polynomial solution $u = x$; in cleared form, with $P = X$, $Q = 1$,
> $$P'Q - PQ' + P^{2} = 1 + X^{2} = (X^{2}+1)\cdot 1^{2} = r\,Q^{2}.$$
> Correspondingly $y = e^{x^{2}/2}$ satisfies $y' = x\,y$ and $y'' = (x^{2}+1)\,y$, so $y'' = ry$ has a genuine EML solution of exponential type.

*Proof sketch.* Direct computation: $\frac{d}{dx}e^{x^{2}/2} = x e^{x^{2}/2}$ by the chain rule, and differentiating once more, $\frac{d}{dx}\bigl(xe^{x^{2}/2}\bigr) = e^{x^{2}/2} + x^{2}e^{x^{2}/2} = (x^{2}+1)e^{x^{2}/2}$. $\square$

So the obstruction for Airy is neither the smallness of the coefficient nor a general feature of non-constant coefficients; it is exactly the **parity** of $\deg r$.

---

## 6. Kovacic case 2: the second symmetric power

### 6.1 The symmetric square equation

> **Theorem 6.1 (Second symmetric power).** Let $y_1, y_2$ be twice differentiable with $y_i'' = r\,y_i$, and let $r$ be differentiable. Put $v = y_1y_2$. Then
> $$v' = y_1'y_2 + y_1y_2', \qquad v'' = 2y_1'y_2' + 2r\,v, \qquad v''' = 4r\,v' + 2r'\,v. \tag{6.1}$$

*Proof sketch.* The first identity is the product rule. Differentiating it and substituting $y_i'' = ry_i$ gives $v'' = y_1''y_2 + 2y_1'y_2' + y_1y_2'' = 2y_1'y_2' + 2rv$. Differentiating once more, $\bigl(2y_1'y_2'\bigr)' = 2(ry_1)y_2' + 2y_1'(ry_2) = 2r\,v'$ and $\bigl(2rv\bigr)' = 2r'v + 2rv'$, whence $v''' = 4rv' + 2r'v$. $\square$

Equation (6.1) is the *second symmetric power* of $y''=ry$: a third-order linear equation whose solution space is spanned by the three products $y_1^{2}, y_1y_2, y_2^{2}$ of a basis of solutions. Kovacic's case 2 for $y'' = ry$ holds only if (6.1) admits a nonzero rational solution. For Airy, $r = x$ and $r' = 1$, so the symmetric square is
$$v''' = 4x\,v' + 2v. \tag{6.2}$$

### 6.2 No polynomial solution

> **Theorem 6.2.** Let $K$ be a field of characteristic zero. Then (6.2) has no nonzero polynomial solution: for $0 \neq v \in K[X]$,
> $$v''' \;\ne\; 4X\,v' + 2v .$$

*Proof sketch.* Let $n = \deg v$ and $\ell = \operatorname{lc}(v) \ne 0$. On the left, $\deg v''' \le n-3 < n$ (with the convention that repeated differentiation of a constant gives $0$), so $[x^{n}]v''' = 0$; more carefully, $\deg v'' \le n$ always, and the coefficient formula for the derivative gives $[x^{n}]v''' = (n+1)[x^{n+1}]v'' = 0$ since $\deg v'' \le n$. On the right,
$$[x^{n}]\bigl(4Xv' + 2v\bigr) = 4[x^{n-1}]v' + 2\ell = 4n\ell + 2\ell = (4n+2)\ell .$$
Since $K$ has characteristic zero, $4n+2 \ne 0$ in $K$ for every $n \in \mathbb{N}$, and $\ell \ne 0$; hence the right-hand coefficient is nonzero while the left-hand one vanishes. $\square$

The key numerical fact is that $4n+2$ is a positive integer, hence invertible in $\mathbb{Q}\subseteq K$. Equivalently: $4n+2 \equiv 2 \pmod 4$ is never zero.

### 6.3 No rational solution

Substituting $v = P/Q$ into (6.2) via (4.2)–(4.4) and multiplying by $Q^{4}$ turns the equation into a polynomial identity. It is convenient to name the two sides.

> **Definition 6.3.** For $P,Q \in K[X]$ set $W := P'Q - PQ'$, $B := W'Q - 2WQ'$, $Z := B'Q - 3BQ'$, and
> $$\Phi(P,Q) := 4X\,W + 2PQ \quad(\text{the \emph{core}}), \qquad \Psi(P,Q) := \Phi(P,Q)\,Q^{2} = 4X\,W\,Q^{2} + 2P\,Q^{3}.$$
> Then $v = P/Q$ solves (6.2) if and only if $Z = \Psi(P,Q)$.

> **Lemma 6.4 (Degree of the left-hand side).** For nonzero $P, Q$,
> $$\deg Z < p + 3q .$$

*Proof sketch.* Three applications of Lemma 4.2, with degenerate cases handled by noting that if $W=0$ then $B=Z=0$, and if $B=0$ then $Z=0$:
$$\deg W < p+q,\qquad \deg B < \deg W + q < p+2q, \qquad \deg Z < \deg B + q < p+3q. \ \square$$

> **Lemma 6.5 (Top coefficient of the core).** For nonzero $P,Q$,
> $$[x^{\,p+q}]\,\Phi(P,Q) = \bigl(4(p-q)+2\bigr)\operatorname{lc}(P)\operatorname{lc}(Q), \qquad \deg \Phi(P,Q) \le p+q .$$

*Proof sketch.* By Proposition 4.4, $[x^{p+q-1}]W = (p-q)\operatorname{lc}(P)\operatorname{lc}(Q)$; multiplication by $X$ shifts the index by one, so $[x^{p+q}](4XW) = 4(p-q)\operatorname{lc}(P)\operatorname{lc}(Q)$. Also $[x^{p+q}](2PQ) = 2\operatorname{lc}(P)\operatorname{lc}(Q)$ because $\deg(PQ) = p+q$. Summing gives the coefficient. For the degree bound: $\deg(XW) \le 1 + \deg W \le p+q$ by Lemma 4.2, and $\deg(PQ) = p+q$. $\square$

> **Lemma 6.6 (Top coefficient of the cleared right-hand side).** For nonzero $P,Q$ over a field of characteristic zero,
> $$[x^{\,p+3q}]\,\Psi(P,Q) = \bigl(4(p-q)+2\bigr)\operatorname{lc}(P)\operatorname{lc}(Q)^{3} \;\ne\; 0 .$$

*Proof sketch.* Since $\Psi = \Phi\cdot Q^{2}$ and $\deg\Phi \le p+q$, the coefficient of $x^{(p+q)+2q}$ in the product is $[x^{p+q}]\Phi\cdot \operatorname{lc}(Q^{2}) = [x^{p+q}]\Phi\cdot\operatorname{lc}(Q)^{2}$ — this is the elementary fact that if $\deg f \le m$ then $[x^{m + \deg g}](fg) = [x^{m}]f\cdot\operatorname{lc}(g)$. Now apply Lemma 6.5. Nonvanishing: $\operatorname{lc}(P), \operatorname{lc}(Q)\neq 0$, and $4(p-q)+2 \ne 0$ in $K$ because it is the image of a nonzero integer (indeed $4k+2\ne0$ for every $k\in\mathbb{Z}$) under $\mathbb{Z}\hookrightarrow K$. $\square$

> **Theorem 6.7 (No rational solution of the Airy symmetric square).** Let $K$ have characteristic zero and let $P,Q \in K[X]$ be nonzero. Then $Z \ne \Psi(P,Q)$; that is, $v''' = 4xv' + 2v$ has no nonzero rational solution.

*Proof sketch.* If $Z = \Psi(P,Q)$ then by Lemma 6.4 the coefficient of $x^{p+3q}$ in $Z$ vanishes, since $Z$ has degree strictly below $p+3q$. But by Lemma 6.6 that coefficient equals $\bigl(4(p-q)+2\bigr)\operatorname{lc}(P)\operatorname{lc}(Q)^{3}\ne 0$. Contradiction. $\square$

Note that Theorem 6.7 subsumes Theorem 6.2 (take $Q = 1$), but the polynomial case is worth stating separately: it is the version that appears as a subroutine in the algorithmic search, and its proof exhibits the arithmetic obstruction $4n+2\ne0$ in its purest form.

### 6.4 The analytic capstone

To transfer Theorem 6.7 to real functions we need the analytic quotient rules matching (4.2)–(4.4).

> **Lemma 6.8 (Rational derivatives).** Let $P, Q$ be real polynomials with $Q$ nowhere vanishing, and let $W, B, Z$ be as in Definition 6.3. Then for every $x\in\mathbb{R}$:
> $$\Bigl(\tfrac{P}{Q}\Bigr)'(x) = \frac{W(x)}{Q(x)^{2}},\qquad \Bigl(\tfrac{W}{Q^{2}}\Bigr)'(x) = \frac{B(x)}{Q(x)^{3}},\qquad \Bigl(\tfrac{B}{Q^{3}}\Bigr)'(x) = \frac{Z(x)}{Q(x)^{4}} .$$

*Proof sketch.* Polynomials are differentiable with derivative given by the formal derivative. Apply the quotient rule; in the second case the denominator derivative is $2QQ'$ and the resulting denominator $Q^{4}$ cancels one factor of $Q$ against the numerator; in the third case the denominator derivative is $3Q^{2}Q'$ and $Q^{6}$ cancels down to $Q^{4}$. $\square$

> **Theorem 6.9 (Products of Airy solutions are never rational).** Let $y_1, y_2 : \mathbb{R}\to\mathbb{R}$ satisfy $y_i'' = x\,y_i$ for all $x$, let $P,Q$ be real polynomials with $P \ne 0$ and $Q$ nowhere vanishing, and suppose
> $$y_1(x)\,y_2(x) = \frac{P(x)}{Q(x)} \qquad\text{for all }x\in\mathbb{R}.$$
> Then a contradiction follows. Hence no product of two solutions of Airy's equation is a nonzero rational function (with nowhere-vanishing denominator).

*Proof sketch.* Put $v = y_1y_2$. By Theorem 6.1 with $r(x)=x$, $r'(x)=1$,
$$v'(x) = y_1y_2' + y_1'y_2,\qquad v''(x) = 2y_1'y_2' + 2x\,v,\qquad v'''(x) = 4x\,v'(x) + 2v(x).$$
On the other hand $v = P/Q$, so by Lemma 6.8 and uniqueness of derivatives, applied three times in succession,
$$v' = \frac{W}{Q^{2}},\qquad v'' = \frac{B}{Q^{3}},\qquad v''' = \frac{Z}{Q^{4}}$$
pointwise. Substituting into $v''' = 4xv' + 2v$ gives, for every real $x$,
$$\frac{Z(x)}{Q(x)^{4}} = 4x\,\frac{W(x)}{Q(x)^{2}} + 2\,\frac{P(x)}{Q(x)} .$$
Multiplying by $Q(x)^{4}\neq 0$ yields $Z(x) = \bigl(4xW(x) + 2P(x)Q(x)\bigr)Q(x)^{2} = \Psi(P,Q)(x)$ for all real $x$; since two real polynomials agreeing everywhere are equal, $Z = \Psi(P,Q)$, contradicting Theorem 6.7. $\square$

This is exactly the failure of Kovacic's **second case** for Airy's equation.

---

## 7. Algorithms

The proofs above are effective, and each yields a decision procedure operating on finitely many integers and field elements.

### 7.1 Symbolic differentiation with regularity certification

Represent an EML expression as a tree. The recursion of Definition 2.1 computes $DE$ in time linear in the size of $E$ (each node produces $O(1)$ new nodes), with the size of $DE$ bounded by a constant multiple of the size of $E$ per differentiation. Regularity at a point $x$ is checked by evaluating bottom-up and testing the argument of every $\text{inv}$ and $\log$ node against zero; this is again linear. Theorems 2.2–2.3 certify that the output is the analytic derivative and that the certification is stable under further differentiation.

### 7.2 The Kovacic case-1 test for polynomial coefficients

Given $r\in K[X]$:

1. If $\deg r$ is odd, report **no rational Riccati solution** (Theorem 4.5) — hence no solution of $y''=ry$ with rational logarithmic derivative. Cost: $O(1)$ after reading $\deg r$.
2. If $\deg r = 2m$ is even, a polynomial Riccati solution must have degree exactly $m$ and leading coefficient a square root of $\operatorname{lc}(r)$ (Theorem 4.7). Substituting $u = \sum_{i\le m} c_i x^{i}$ into $u' + u^{2} = r$ and comparing coefficients from the top down determines $c_{m-1}, c_{m-2},\dots$ successively by *linear* equations (each $c_j$ appears linearly, multiplied by $2c_m \ne 0$, in the coefficient of $x^{m+j}$), so the search costs $O(m^{2})$ field operations and either produces the unique candidate or reports failure at the first inconsistent coefficient.

### 7.3 The rational-solution test for $y'' = ry$

Compute $W = P'Q - PQ'$ and $B = W'Q - 2WQ'$ for symbolic $P, Q$ of prescribed degrees, and compare $\deg B < \deg P + 2\deg Q$ with $\deg(rPQ^{2}) = \deg r + \deg P + 2\deg Q$. When $r\ne0$ the comparison is always strict, so the test is a constant-time degree comparison (Theorem 4.9), with no search required.

### 7.4 The Kovacic case-2 test for Airy

For candidate degrees $p, q \ge 0$, evaluate the *obstruction constant*
$$\kappa(p,q) := 4(p-q) + 2 .$$
By Lemmas 6.4 and 6.6 the identity $Z = \Psi(P,Q)$ forces $\kappa(p,q)\operatorname{lc}(P)\operatorname{lc}(Q)^{3} = 0$; in characteristic zero $\kappa(p,q)\ne0$ always, so the test rejects immediately for all $(p,q)$. The pseudocode is a two-line certificate rather than a search — the point of the theory is precisely to replace an unbounded search by a closed-form obstruction.

A useful *numerical* companion procedure, implemented in the accompanying demonstrations, is a least-squares Padé fit: compute a solution of Airy's equation by its power series, fit a rational function of prescribed degrees to the product $y_1y_2$, and observe that the residual of the symmetric square equation cannot be driven to zero — a finite-precision shadow of Theorem 6.9.

---

## 8. Applications and interpretation

**Why the theory matters computationally.** Computer algebra systems attempt closed-form integration and ODE solving by exactly the strategy formalised here: encode "closed form" syntactically, reduce solvability to a rational-function question, and test that question by degree bookkeeping. Theorem 2.2 is the correctness statement for the first step; Theorems 4.5, 4.7, 4.9 and 6.7 are the tests. An impossibility theorem is not a negative result for a solver — it is what allows the solver to *terminate with certainty* rather than search forever.

**Why the theory matters for Airy specifically.** Knowing that no elementary formula exists redirects effort to the representations that do work:
$$y(x) = \sum_{n \ge 0} a_n x^{n}, \qquad a_{n+3} = \frac{a_n}{(n+3)(n+2)},$$
which converges on all of $\mathbb{C}$ (the coefficients decay faster than any geometric sequence); the integral $\operatorname{Ai}(x)=\frac1\pi\int_0^{\infty}\cos\bigl(\tfrac{t^{3}}{3}+xt\bigr)\,dt$; and the asymptotic expansions $\operatorname{Ai}(x)\sim \tfrac{1}{2\sqrt\pi}x^{-1/4}e^{-\frac23 x^{3/2}}$ and $\operatorname{Ai}(-x)\sim \tfrac{1}{\sqrt\pi}x^{-1/4}\sin\bigl(\tfrac23x^{3/2}+\tfrac\pi4\bigr)$ for $x\to+\infty$. These are the correct objects of study, and the transcendence theorem is what certifies that they are irreducible to anything simpler.

**Physical reading.** Airy's equation is the local normal form of a Schrödinger operator near a classical turning point: linearising a potential $V$ around a point where $V(x_0)=E$ gives $\psi'' = c(x-x_0)\psi$. The failure of Kovacic's cases 1 and 2 says that the turning-point connection problem — matching an oscillatory region to an exponential one — is genuinely non-elementary. The WKB approximation, which produces elementary expressions on either side of the turning point, must break down precisely at the turning point, and the theorems here explain why no elementary patch can be found: the connection function is not built from exponentials and logarithms.

**The structure of the obstruction.** Both fatal computations reduce to arithmetic:

| Case | Cleared identity | Obstruction |
|---|---|---|
| 1 (rational log-derivative) | $P'Q-PQ'+P^{2} = rQ^{2}$ | LHS has even degree $2p$ (or too small a degree); RHS has odd degree $\deg r + 2q$ |
| 2 (rational product) | $Z = (4XW+2PQ)Q^{2}$ | RHS has nonzero coefficient $\bigl(4(p-q)+2\bigr)\operatorname{lc} P\operatorname{lc} Q^{3}$ in degree $p+3q$; LHS has degree $<p+3q$ |

In both rows the analytic content has been fully converted into a statement about integers: *$\deg r$ is odd*, and *$4k+2 \ne 0$*. This is the characteristic mechanism of differential Galois theory in miniature.

**Sharpness and the boundary of the phenomenon.** Proposition 5.3 shows the results are not vacuous generalities about non-constant coefficients: $y''=(x^{2}+1)y$ has the closed-form solution $e^{x^{2}/2}$. More generally, for even $\deg r = 2m$ the degree-determination theorem localises the search to a single candidate degree; solvability then depends on finitely many coefficient conditions. The dichotomy odd/even is thus not merely a proof artefact but a genuine structural divide for polynomial coefficients.

---

## 9. Discussion and future directions

The development above establishes: a syntax for exponential–logarithmic functions with a verified symbolic derivative; the complete solution theory of the first-order linear equation $y' = c\,y$; the Kovacic degree/leading-coefficient determination step for polynomial Riccati solutions; the non-existence of rational solutions of $u'+u^{2}=r$ for $r$ of odd degree; the non-existence of nonzero rational solutions of $y''=ry$ for $r\ne0$; the fact that Airy's equation has no EML solution of exponential type $y = e^{F}$ with $F'$ rational (failure of Kovacic's **first** case); and the analytic and algebraic form of the failure of Kovacic's **second** case, namely that the second symmetric power equation $v'''=4xv'+2v$ has no nonzero polynomial or rational solution, so no product of two solutions of Airy's equation is a nonzero rational function.

Natural next steps:

1. **Kovacic case 3.** Cases 1 and 2 are now ruled out for Airy. A full "Airy has no Liouvillian solution" theorem still needs case 3: the solution is algebraic of degree $4$, $6$ or $12$, which amounts to a finite list of candidate exponent patterns and a rationality test on the fourth (and twelfth) symmetric power. The pattern used for the symmetric square — clear denominators, compare the top coefficient with a strict degree bound — should transfer verbatim.

2. **Algebraic solutions.** Show directly that no nonzero solution of $y''=xy$ is algebraic over $\mathbb{C}(x)$, by pushing the Riccati equation into a finite extension and repeating the degree count with valuations.

3. **Differential Galois group of Airy.** With cases 1–3 excluded, the Picard–Vessiot group of Airy's equation is all of $\mathrm{SL}_2$. A lightweight substitute for the full Picard–Vessiot machinery is the Wronskian-determinant torsor: the solution space is two-dimensional and carries an $\mathrm{SL}_2$-equivariant Wronskian pairing.

4. **Towers and Liouville's theorem.** The EML syntax is a *syntactic* tower. The next structural theorem is Liouville's: if an elementary antiderivative of an EML function exists, it lies in a tower obtained by adjoining logarithms of the original field, with constant coefficients. This would let one state "$e^{-x^{2}}$ has no EML antiderivative" within the present framework.

5. **Riccati with rational (not just polynomial) coefficient.** Extending the odd-degree obstruction from polynomial $r$ to $r \in K(x)$ requires a local analysis at each pole (the residue equation $c^{2}=c$ at a simple pole), which is the remaining ingredient of the pole part of Kovacic's algorithm.

6. **Effective decision procedure.** The degree determination theorem pins the degree and leading coefficient of a polynomial Riccati solution; assembling this with the pole analysis and the symmetric-power tests would give a complete, certified implementation of Kovacic's algorithm for polynomial and then rational coefficients.

---

## 10. Conclusion

By fixing a syntax for exponential–logarithmic functions and proving that symbolic differentiation is analytically correct on the regularity locus, we obtain a framework in which "there is no closed-form solution" becomes a provable statement rather than an informal one. Within that framework, the Riccati correspondence converts the closed-form solvability of $y''=ry$ into rational-function questions, and those questions are settled by degree counts.

For Airy's equation the outcome is decisive at the first two levels of Kovacic's trichotomy: no solution has a rational logarithmic derivative, and no product of two solutions is a rational function. The mechanisms are, respectively, the parity of $\deg(xQ^{2}) = 2\deg Q + 1$ and the non-vanishing of the integer $4(\deg P - \deg Q) + 2$. What began as a question about the transcendence of a special function ends as arithmetic modulo $2$ and $4$ — which is, in the end, exactly what impossibility proofs in differential algebra are for.
