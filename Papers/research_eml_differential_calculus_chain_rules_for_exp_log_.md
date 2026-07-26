# Differential Structure of Exponential–Logarithmic Products

**Aristotle**  
**26 July 2026**

## Abstract

We study the differential structure of functions of the form $F(x)=e^{h(x)}\log(g(x))$ and of expressions assembled from exponentials, logarithms, addition, and multiplication. The ordinary product and chain rules yield

$$
F'(x)=e^{h(x)}\left(h'(x)\log(g(x))+\frac{g'(x)}{g(x)}\right)
$$

whenever $h$ and $g$ are differentiable and $g(x)\ne0$. Away from the additional divisor $\log(g(x))=0$, this admits the canonical multiplicative form

$$
F'(x)=F(x)\left(h'(x)+\frac{g'(x)}{g(x)\log(g(x))}\right).
$$

We show that the frequently proposed expression $F(h'+g'/g)$ is false by an exact counterexample. We then compute three successive derivatives of $e^{x^2}\log(x+1)$, proving that each retains an exponential shell and a logarithmic–polar normal form. The pole order at $x=-1$ grows by one under each differentiation, while transcendental nesting remains stable. Finally, on $x>0$, the fixed-depth representation $x^m=e^{m\log x}$ is compatible with the derivative $mx^{m-1}$. These results motivate guarded logarithmic differentiation, a bifiltration by compositional depth and pole order, and compact algorithms for repeated differentiation.

## 1. Introduction

Expressions combining exponential growth and logarithmic scaling occur throughout applied analysis. A product such as $e^{h(x)}\log(g(x))$ can represent an amplified information signal, a logarithmic correction to a growth law, or a local model with both rapid variation and a singular boundary. More elaborate expressions built using exponential, logarithm, addition, and multiplication will be called **EML expressions**.

The central structural question is not merely whether such expressions can be differentiated, but whether their derivatives retain an intelligible form. A naive expectation is that the logarithmic derivative of a product should split into a sum. That expectation is correct only when the logarithmic derivative is taken with respect to the actual factors. For $F=e^h\log g$, those factors are $e^h$ and $\log g$, so the second relative derivative is $(\log g)'/\log g$, not $g'/g$.

This distinction leads to four conclusions.

1. There is a robust unfactored rule requiring only $g(x)\ne0$.
2. A factorization through $F(x)$ requires the stronger condition $\log(g(x))\ne0$.
3. Omitting the latter logarithm produces a false formula, even for elementary functions.
4. Repeated differentiation can preserve transcendental shape while increasing rational pole order.

The paper develops these points from first principles. Section 2 introduces the expression class and relevant notions of local domain, depth, and pole order. Section 3 proves the general chain rules and gives a sharp counterexample. Section 4 derives the first three derivatives of a representative test function. Section 5 formulates the normal-form recurrence suggested by the computation. Section 6 treats positive monomials as constant-depth exp–log expressions. Sections 7 and 8 describe algorithms and applications, and Section 9 identifies open directions.

## 2. Definitions and preliminaries

### 2.1. EML expressions

An **EML expression** in one real variable is any finite expression obtained from the variable $x$, real constants, addition, multiplication, the exponential operation $u\mapsto e^u$, and the logarithmic operation $u\mapsto\log u$, wherever the latter is defined. Rational terms arise naturally after differentiation because

$$
\frac{d}{dx}\log(g(x))=\frac{g'(x)}{g(x)}.
$$

Accordingly, the differentiated class is most naturally viewed as an EML-rational class in which guarded reciprocals are permitted on regions where their denominators do not vanish.

The **compositional depth** of an expression is the maximum number of nested operations along a path from the root of its expression tree to a variable or constant. Exact conventions can differ—for example, whether leaves have depth zero or one—but the structural issue is invariant: a fixed-depth family does not acquire arbitrarily deep exponential or logarithmic nesting.

A **zero-free region** for a function $u$ is an interval on which $u(x)\ne0$. Factorizations involving $1/u$ are valid only on such regions. This elementary guard is crucial when symbolic transformations are intended to preserve domains.

### 2.2. Logarithmic derivatives

For a differentiable nonzero function $u$, its logarithmic derivative is

$$
\mathcal{L}(u)=\frac{u'}{u}.
$$

On a zero-free interval, products satisfy

$$
\mathcal{L}(uv)=\mathcal{L}(u)+\mathcal{L}(v).
$$

Applying this to $u=e^h$ and $v=\log g$ gives

$$
\mathcal{L}(F)=h'+\frac{(\log g)'}{\log g}
=h'+\frac{g'}{g\log g}.
$$

This short calculation already predicts the corrected factorization, but it also makes its domain restrictions visible: $g$ must be nonzero for $(\log g)'$, and $\log g$ must be nonzero for division by the second factor.

### 2.3. Logarithmic–polar normal forms

For the repeated-derivative example, we use the following terminology. An expression has **logarithmic–polar form of order $n$ at $x=-1$** if it can be written

$$
e^{x^2}\left(P(x)\log(x+1)+\sum_{k=1}^{n}\frac{Q_k(x)}{(x+1)^k}\right),
$$

where $P,Q_1,\ldots,Q_n$ are polynomials. The largest $k$ with $Q_k\not\equiv0$ is the pole order represented by the rational part. On the natural real domain $x>-1$, all terms are smooth, although the boundary behavior becomes increasingly singular as the derivative order rises.

## 3. Chain rules and the factorization obstruction

### Theorem 1. Unfactored exponential–logarithmic chain rule

Let $h$ and $g$ be real-valued functions differentiable at $x$, and suppose $g(x)\ne0$. Define

$$
F(t)=e^{h(t)}\log(g(t)).
$$

Then $F$ is differentiable at $x$ and

$$
F'(x)=e^{h(x)}\left(h'(x)\log(g(x))+\frac{g'(x)}{g(x)}\right).
$$

**Proof sketch.** The chain rule gives

$$
\frac{d}{dx}e^{h(x)}=e^{h(x)}h'(x)
$$

and, under $g(x)\ne0$,

$$
\frac{d}{dx}\log(g(x))=\frac{g'(x)}{g(x)}.
$$

The product rule therefore yields

$$
F'=e^h h'\log g+e^h\frac{g'}{g},
$$

and factoring only the common exponential gives the stated formula. Notice that no division by $\log g$ occurs, so the rule remains valid where $\log(g(x))=0$.

### Theorem 2. Guarded canonical factorization

Under the hypotheses of Theorem 1, assume additionally that $\log(g(x))\ne0$. Then

$$
F'(x)=F(x)\left(h'(x)+\frac{g'(x)}{g(x)\log(g(x))}\right).
$$

**Proof sketch.** Starting from Theorem 1, factor $e^{h(x)}\log(g(x))$ from both terms. The first term becomes $F(x)h'(x)$. The second becomes

$$
e^{h(x)}\frac{g'(x)}{g(x)}
=F(x)\frac{g'(x)}{g(x)\log(g(x))}.
$$

The additional nonvanishing condition is exactly what licenses this division.

### Proposition 3. The unguarded proposed factorization is false

The identity

$$
F'(x)=F(x)\left(h'(x)+\frac{g'(x)}{g(x)}\right)
$$

is not valid in general for $F=e^h\log g$.

**Proof.** Let $h(x)=0$ and $g(x)=e^x$. Then

$$
F(x)=e^0\log(e^x)=x,
$$

so $F'(2)=1$. The proposed right-hand side at $x=2$ is

$$
F(2)\left(0+\frac{e^2}{e^2}\right)=2.
$$

Since $1\ne2$, the identity fails.

### 3.1. Sharpness of the guards

The two theorems have deliberately different hypotheses. The condition $g(x)\ne0$ is needed to differentiate $\log(g(x))$ by the usual reciprocal rule. The stronger factorization also divides by $\log(g(x))$ and therefore excludes $g(x)=1$. At such a point, $F(x)=0$, but $F'(x)$ need not vanish.

The counterexample demonstrates this at $x=0$: there $g(0)=1$ and $F(0)=0$, but $F'(0)=1$. Thus a formula of the form $F'=F\cdot R$ cannot hold with a finite-valued $R$ at that point. The obstruction is the zero divisor of the logarithmic factor, not a failure of ordinary differentiability.

In standard real analysis one commonly assumes $g>0$ on an interval to use the real logarithm. Locally, however, the derivative identity itself is governed by nonvanishing. What matters for the factorization is the finer stratification into regions where both $g$ and $\log g$ avoid zero.

## 4. Three derivatives of $e^{x^2}\log(x+1)$

Let

$$
f_0(x)=e^{x^2}\log(x+1), \qquad x>-1.
$$

The interval $x>-1$ is the natural real domain. We now compute three derivatives and preserve the exponential shell at every stage.

### Theorem 4. First derivative

For $x>-1$,

$$
f_0'(x)=f_1(x),
$$

where

$$
f_1(x)=e^{x^2}\left(2x\log(x+1)+\frac{1}{x+1}\right).
$$

**Proof sketch.** Apply Theorem 1 with $h(x)=x^2$ and $g(x)=x+1$. Since $h'(x)=2x$ and $g'(x)=1$, substitution immediately gives the formula.

### Theorem 5. Second derivative

For $x>-1$,

$$
f_0''(x)=f_2(x),
$$

where

$$
f_2(x)=e^{x^2}\left(
(4x^2+2)\log(x+1)+\frac{4x}{x+1}-\frac{1}{(x+1)^2}
\right).
$$

**Proof sketch.** Write $f_1=e^{x^2}A_1$ with

$$
A_1=2x\log(x+1)+(x+1)^{-1}.
$$

Then

$$
f_1'=e^{x^2}(2xA_1+A_1').
$$

A direct calculation gives

$$
A_1'=2\log(x+1)+\frac{2x}{x+1}-\frac{1}{(x+1)^2}.
$$

Adding $2xA_1$ and collecting coefficients yields the displayed $f_2$.

### Theorem 6. Third derivative

For $x>-1$,

$$
f_0'''(x)=f_3(x),
$$

where

$$
f_3(x)=e^{x^2}\left(
(8x^3+12x)\log(x+1)
+\frac{12x^2+6}{x+1}
-\frac{6x}{(x+1)^2}
+\frac{2}{(x+1)^3}
\right).
$$

**Proof sketch.** Set

$$
A_2=(4x^2+2)\log(x+1)+\frac{4x}{x+1}-\frac{1}{(x+1)^2}.
$$

As before, $f_2'=e^{x^2}(2xA_2+A_2')$. Differentiate term by term:

$$
\begin{aligned}
A_2'={}&8x\log(x+1)+\frac{4x^2+2}{x+1}
+\frac{4}{x+1}-\frac{4x}{(x+1)^2}
+\frac{2}{(x+1)^3}.
\end{aligned}
$$

Meanwhile,

$$
2xA_2=(8x^3+4x)\log(x+1)
+\frac{8x^2}{x+1}-\frac{2x}{(x+1)^2}.
$$

Combining logarithmic terms gives $(8x^3+12x)\log(x+1)$. Combining equal pole orders gives the remaining three rational terms.

### 4.1. Numerical consistency

At $x=0$, the formulas simplify to

$$
f_0(0)=0,\qquad f_1(0)=1,\qquad f_2(0)=-1,\qquad f_3(0)=8.
$$

The value $f_1(0)=1$ again illustrates why factoring through $f_0$ is invalid at a zero of $\log(x+1)$. At $x=1$ the formulas become

$$
\begin{aligned}
f_0(1)&=e\log2,\\
f_1(1)&=e\left(2\log2+\frac12\right),\\
f_2(1)&=e\left(6\log2+\frac74\right),\\
f_3(1)&=e\left(20\log2+\frac{29}{4}\right).
\end{aligned}
$$

These values provide convenient benchmarks for numerical implementations.

## 5. A triangular normal-form mechanism

The three formulas are instances of a stable transformation. Suppose

$$
f_n(x)=e^{x^2}A_n(x).
$$

Then

$$
f_{n+1}(x)=e^{x^2}A_{n+1}(x),
\qquad
A_{n+1}=A_n'+2xA_n.
$$

Define the linear operator

$$
\mathcal{D}[A]=A'+2xA.
$$

Repeated differentiation of $f_0$ is equivalent to repeated application of $\mathcal{D}$ to $A_0=\log(x+1)$. The exponential shell is therefore invariant.

Assume more generally that

$$
A_n=P_n(x)\log(x+1)+\sum_{k=1}^{n}\frac{Q_{n,k}(x)}{(x+1)^k}.
$$

Differentiating the logarithmic part gives

$$
\frac{d}{dx}\bigl(P_n\log(x+1)\bigr)
=P_n'\log(x+1)+\frac{P_n}{x+1}.
$$

Differentiating a pole term gives

$$
\frac{d}{dx}\left(\frac{Q_{n,k}}{(x+1)^k}\right)
=\frac{Q_{n,k}'}{(x+1)^k}
-\frac{kQ_{n,k}}{(x+1)^{k+1}}.
$$

Adding $2xA_n$ leads to the triangular recurrences

$$
P_{n+1}=P_n'+2xP_n,
$$

$$
Q_{n+1,1}=P_n+Q_{n,1}'+2xQ_{n,1},
$$

and, for $2\le k\le n$,

$$
Q_{n+1,k}=Q_{n,k}'+2xQ_{n,k}-(k-1)Q_{n,k-1},
$$

with the new highest-pole coefficient

$$
Q_{n+1,n+1}=-nQ_{n,n}.
$$

Starting from $P_0=1$ and no pole coefficients, these recurrences reproduce the first three derivatives. They also explain why the maximal pole order increases by at most one at each step. If the top coefficient is nonzero, the final recurrence shows that the growth is exactly one step.

This recurrence supplies a strong conjectural all-orders normal form. The present results establish it explicitly through the third derivative; a complete all-orders proof and uniqueness theorem remain future work.

## 6. Constant-depth representations of positive monomials

A complementary phenomenon occurs for powers. Let $m$ be a positive integer. On $x>0$,

$$
M_m(x)=e^{m\log x}=x^m.
$$

The expression uses one logarithm inside one exponential, regardless of the magnitude of $m$. Thus algebraic degree may become arbitrarily large while compositional depth stays fixed.

### Theorem 7. Differentiation of depth-compressed monomials

For every nonnegative integer $n$ and every $x>0$,

$$
\frac{d}{dx}e^{(n+1)\log x}=(n+1)x^n.
$$

Moreover, the exp–log representation has constant compositional depth independent of $n$; under the convention that counts the logarithm, scalar multiplication, and outer exponential as three successive operation levels, its depth is exactly $3$.

**Proof sketch.** Since $x>0$, the inverse relation between exponential and logarithm gives

$$
e^{(n+1)\log x}=x^{n+1}.
$$

Differentiating the right-hand side yields $(n+1)x^n$. Alternatively, direct application of the chain rule gives

$$
e^{(n+1)\log x}\frac{n+1}{x}
=x^{n+1}\frac{n+1}{x}
=(n+1)x^n.
$$

The syntax of the expression always consists of the same three nested stages, so its depth does not depend on the exponent.

This theorem does not claim that every EML expression has a depth-preserving derivative. Rather, it supplies a concrete infinite family in which very high algebraic degree is compressed into fixed transcendental depth and ordinary differentiation respects the represented function.

## 7. Algorithms

### 7.1. Guarded differentiation of an exp–log product

Given symbolic descriptions of $h$, $g$, $h'$, and $g'$, the safest derivative constructor returns

$$
e^h\left(h'\log g+\frac{g'}{g}\right).
$$

A second normalization pass may return the factored form only after establishing that both $g$ and $\log g$ are nonzero on the region of interest.

**Algorithm.**

1. Differentiate $h$ and $g$ recursively.
2. construct the exponential factor $e^h$;
3. construct $h'\log g+g'/g$;
4. multiply the two expressions;
5. if zero-free certificates for $g$ and $\log g$ are available, optionally factor through $e^h\log g$;
6. otherwise retain the unfactored expression.

For expression trees, the local constructor uses a constant number of new nodes beyond the recursively computed derivatives. Without shared subexpressions, repeated differentiation can cause exponential textual growth. With a directed acyclic graph that shares $h$, $g$, and their derivatives, one differentiation pass is linear in the number of distinct input nodes, aside from simplification costs.

### 7.2. Coefficient recurrence for repeated derivatives

For the test family, store $P_n$ and the array $Q_{n,1},\ldots,Q_{n,n}$. Apply the recurrences of Section 5 using polynomial differentiation, multiplication by $2x$, and coefficient addition. If polynomial coefficients are stored densely and degrees are $O(n)$, producing all arrays through order $N$ takes $O(N^3)$ elementary coefficient operations by a straightforward implementation: there are $O(N^2)$ polynomial entries and each update costs $O(N)$. Sparse or structured polynomial representations may improve practical performance.

The recurrence avoids re-differentiating a fully expanded expression. It preserves the semantic blocks—logarithmic coefficient and pole coefficients—and exposes the singularity order directly.

### 7.3. Numerical validation

A practical numerical check compares each closed form with a central finite difference of the previous form:

$$
D_\varepsilon u(x)=\frac{u(x+\varepsilon)-u(x-\varepsilon)}{2\varepsilon}.
$$

For smooth points away from $x=-1$, the truncation error is $O(\varepsilon^2)$, while floating-point cancellation grows as $\varepsilon$ becomes too small. Multiple step sizes should therefore be reported. Such checks illustrate the formulas but do not replace the analytic derivations.

## 8. Applications and discussion

### 8.1. Sensitivity and relative growth

The factored formula gives a relative rate of change:

$$
\frac{F'}{F}=h'+\frac{g'}{g\log g}.
$$

On a zero-free interval, this separates exponential sensitivity, represented by $h'$, from logarithmic sensitivity, represented by $g'/(g\log g)$. This can be useful in parameter estimation and optimization, where relative changes often matter more than absolute changes.

Near a zero of $\log g$, however, the relative rate becomes singular even if $F'$ remains finite. Algorithms should switch to the unfactored formula there. The distinction is analogous to choosing coordinates: a relative coordinate chart fails at zero, while the underlying function remains regular.

### 8.2. Boundary-aware numerical computation

For $e^{x^2}\log(x+1)$, each derivative displays its powers of $(x+1)^{-1}$ explicitly. As $x$ approaches $-1$ from the right, higher derivatives become increasingly ill-conditioned. The normal form makes this behavior transparent and can guide adaptive precision, domain subdivision, or asymptotic treatment.

The stable exponential shell also suggests scaled evaluation. Rather than forming a potentially huge derivative directly, one may evaluate the inner logarithmic–polar factor and retain the scale $e^{x^2}$ separately. This is standard practice in computations involving extreme dynamic range.

### 8.3. Complexity as a bifiltration

A single notion of expression complexity obscures the example. The transcendental nesting does not grow, but the pole order does. A useful future calculus should therefore carry a pair

$$
(\text{transcendental depth},\text{pole order}).
$$

Differentiation may preserve or mildly increase the first coordinate while increasing the second by at most one. Such a bifiltration could support complexity guarantees for normalization and automatic differentiation.

### 8.4. Scope of the present results

The calculations establish exact local chain rules, a counterexample to an incorrect universal factorization, explicit formulas through the third derivative, and a constant-depth monomial family. They do not by themselves prove that the unrestricted EML class is closed under differentiation without extending the grammar by reciprocals. Indeed, derivatives of logarithms force $1/g$, and the corrected factorization can force $1/\log g$.

The natural closure statement is therefore about an EML-rational class with guarded reciprocals. Within such a class, domain annotations are not optional metadata; they are part of the mathematical meaning of every simplification.

## 9. Further structural consequences

### 9.1. Zeros versus singularities

The factorized derivative introduces an apparent pole wherever $\log(g(x))=0$. This pole belongs to the relative derivative $F'/F$, not necessarily to $F'$ itself. Suppose, for example, that $g(a)=1$ and $g'(a)\ne0$. Then $\log(g(a))=0$, while the unfactored rule gives

$$
F'(a)=e^{h(a)}g'(a),
$$

which is finite and nonzero. Locally, $F$ has a simple zero, so its logarithmic derivative behaves like $(x-a)^{-1}$. The singularity is therefore informative: it records the zero multiplicity of $F$ rather than a defect in the underlying derivative.

This observation suggests treating factored derivatives as objects attached to zero-free strata. Ordinary derivatives extend across some stratum boundaries, whereas logarithmic derivatives carry residue-like information about the zeros crossed. A global symbolic system should preserve the unfactored formula and use factored formulas as regional normal forms.

### 9.2. Degree evolution in the logarithmic coefficient

The recurrence

$$
P_{n+1}=P_n'+2xP_n,\qquad P_0=1,
$$

shows that $P_n$ has degree $n$. Its leading coefficient doubles at every step, so the leading term is $2^n x^n$. The first values are

$$
P_0=1,\qquad P_1=2x,\qquad P_2=4x^2+2,
\qquad P_3=8x^3+12x.
$$

These are precisely the logarithmic coefficients visible in the test calculation. They arise from repeated conjugation of differentiation by the exponential shell:

$$
e^{-x^2}\frac{d}{dx}\left(e^{x^2}A\right)=A'+2xA.
$$

Consequently, the logarithmic component can be studied independently of the pole array before the two are coupled by differentiation of $\log(x+1)$.

### 9.3. Evaluation strategies

The normal forms support region-dependent evaluation. Near $x=-1$, one should track pole terms explicitly and may require increased precision. Near a zero of the logarithmic factor, the unfactored derivative avoids dividing by a small $\log(g(x))$. For large positive $x$, it can be advantageous to retain a scaled result $e^{-x^2}f_n(x)=A_n(x)$ rather than form $f_n(x)$ directly.

These choices do not change the mathematics, but they expose why structural differentiation is useful. The same derivative can be represented in algebraically equivalent forms with very different numerical behavior. Domain guards and normal forms make the choice systematic rather than ad hoc.

## 10. Future work

Five directions emerge.

First, one should prove the all-orders logarithmic–polar normal form

$$
f_0^{(n)}(x)=e^{x^2}\left(P_n(x)\log(x+1)+
\sum_{k=1}^{n}\frac{Q_{n,k}(x)}{(x+1)^k}\right),
$$

establish uniqueness, and show that the top pole coefficient never vanishes.

Second, an EML grammar with guarded reciprocals should be equipped with two complexity measures: compositional depth and pole order. The goal is a differentiation theorem that controls both coordinates.

Third, logarithmic differentiation should be made divisor-sensitive. A nonzero expression may be stratified into zero-free intervals, with a canonical relative derivative on each interval and explicit transition behavior at zeros.

Fourth, the triangular coefficient arrays may possess bivariate exponential generating functions satisfying a first-order linear partial differential equation. Such a representation could reveal degree, sign, and asymptotic laws.

Fifth, compact expression graphs should be analyzed quantitatively. For fixed depth and derivative order, normalization may admit polynomial-size representations even when naive expanded formulas grow exponentially.

### 10.1. Criteria for an all-orders theorem

A satisfactory all-orders result should contain more than an existence statement. It should specify the coefficient recurrence, prove that the recurrence preserves integer coefficients, establish degree bounds for every polynomial, and show that the highest pole term is nonzero. It should also distinguish equality of functions on $x>-1$ from uniqueness of the displayed normal form. The latter requires a linear-independence argument separating the logarithmic term from rational functions.

For computation, the theorem should be paired with a normalization procedure and explicit complexity bounds. The mathematical recurrence already avoids uncontrolled nesting, but implementation size depends on whether common polynomial and denominator subexpressions are shared. Finally, domain statements should remain visible: every formula concerns the open interval $x>-1$, and asymptotic claims at $x=-1$ describe approach from the right rather than a derivative at the boundary.

These criteria turn the observed three-step pattern into a precise research program. They also prevent three distinct questions—existence, uniqueness, and efficient computation—from being conflated.

## 11. Conclusion

The derivative of $e^{h}\log g$ has a simple but carefully guarded structure. The universally useful local expression is

$$
e^h\left(h'\log g+\frac{g'}{g}\right),
$$

while factorization through the original function requires

$$
e^h\log g\left(h'+\frac{g'}{g\log g}\right).
$$

The extra factor $1/\log g$ and its zero-free condition cannot be omitted. The exact counterexample $e^0\log(e^x)=x$ makes the obstruction unmistakable.

For $e^{x^2}\log(x+1)$, three differentiations preserve an exponential–logarithmic architecture while increasing the maximal pole order from zero to three. For positive monomials, $e^{m\log x}$ gives a constant-depth representation compatible with the usual power rule. Together these observations separate transcendental nesting from singularity growth and provide a principled basis for guarded, structure-preserving differentiation.