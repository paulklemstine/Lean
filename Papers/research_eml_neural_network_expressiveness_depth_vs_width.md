# Explicit Inverse-Square Approximation of a Quadratic by a Shallow EML Unit

**Aristotle**  
**August 1, 2026**

## Abstract

We study a one-dimensional test of expressiveness for the EML activation family

$$
\Phi_{a,b,a',b'}(x)=\exp(ax+b)-\log(a'x+b'),
$$

on domains where $a'x+b'>0$. For a positive scale $h$, we introduce the smooth quadratic approximant

$$
Q_h(x)=\frac{2}{h^2}\bigl(\exp(hx)-1-hx\bigr).
$$

It is realized by one EML nonlinear unit with parameters $(a,b,a',b')=(h,0,0,1)$, followed by an affine readout and a linear skip connection. Its exact derivative is

$$
Q_h'(x)=\frac{2}{h}\bigl(\exp(hx)-1\bigr).
$$

Indexing the scale by a positive integer budget $w$ through $h=w^{-2}$ gives

$$
Q_w(x)=2w^4\left(\exp\left(\frac{x}{w^2}\right)-1-\frac{x}{w^2}\right).
$$

For every $w\ge1$, this family satisfies the uniform certificate

$$
\sup_{x\in[0,1]}|Q_w(x)-x^2|\le\frac{4}{9w^2}.
$$

The inverse-square bound is no greater than the matched inverse-linear benchmark $4/(9w)$ for every positive integral $w$, and is strictly smaller for $w\ge2$. We give proof sketches, stable evaluation algorithms, numerical diagnostics, and a careful account of what this test case does and does not establish. In particular, the result is an explicit smooth approximation theorem for a canonical target, not a general depth-width theorem for arbitrary Lipschitz functions and not an architecture-independent lower bound against piecewise-linear networks.

## 1. Introduction

Depth-width tradeoffs ask how a network’s approximation power changes as computational resources are rearranged. General theorems are difficult because several notions of complexity coexist: number of nonlinear units, number of trainable parameters, number of affine regions, depth, coefficient magnitude, and permissible skip connections. A useful first step is therefore to isolate a target for which every component of the construction is visible.

The target $f(x)=x^2$ on $[0,1]$ is particularly informative. It is smooth, nonlinear, and exactly characterized by constant curvature. It also plays a structural role in multiplication and polynomial approximation. The EML activation combines exponential and logarithmic branches. We ask whether its smooth nonlinear geometry can be converted into an explicit approximation of the quadratic, and how the error scales under a prescribed width-indexed choice of parameters.

The key observation is elementary but powerful: the second-order Taylor coefficient of the exponential is $1/2$. Subtracting the constant and linear terms from $\exp(hx)$ and multiplying the remainder by $2/h^2$ exposes $x^2$. The remaining terms are controlled uniformly on $[0,1]$. Choosing $h=w^{-2}$ then converts a first-order bound in $h$ into an inverse-square bound in $w$.

Our contribution consists of four linked results. First, the approximant has an explicit depth-two realization using one EML unit, an affine readout, and a linear skip. Second, it has an exact smooth derivative. Third, it obeys a uniform error certificate $4/(9w^2)$. Fourth, this certificate dominates the matched inverse-linear benchmark, strictly beyond $w=1$.

Two qualifications should be stated at the outset. The construction uses a single nonlinear unit for each $w$; $w$ indexes the scale chosen within a width budget and is not the literal number of active units. Moreover, the logarithmic branch is specialized to the constant $\log 1=0$. Thus the result proves expressiveness of the EML family through an embedded exponential subfamily. It does not assert that both branches are necessary for this target.

## 2. Definitions and architectural model

### 2.1 The EML activation

**Definition 2.1 (EML activation).** Let $a,b,a',b'\in\mathbb R$, and let $D\subseteq\mathbb R$ satisfy $a'x+b'>0$ for all $x\in D$. The associated EML activation on $D$ is

$$
\Phi_{a,b,a',b'}(x)=\exp(ax+b)-\log(a'x+b').
$$

The positivity condition is required only to make the real logarithm well-defined. In the construction below, $(a',b')=(0,1)$, so the logarithmic input is identically $1$ and the condition holds on all of $\mathbb R$.

### 2.2 The scale-dependent quadratic approximant

**Definition 2.2 (Exponential quadratic approximant).** For $h\ne0$, define

$$
Q_h(x)=\frac{2}{h^2}\bigl(\exp(hx)-1-hx\bigr).
$$

Although the formula is singular at $h=0$, for each fixed $x$ it has the limit $x^2$ as $h\to0$. We use only positive $h$.

**Definition 2.3 (Width-indexed approximant).** For an integer $w\ge1$, set

$$
h_w=\frac{1}{w^2}
$$

and define

$$
Q_w(x)=Q_{h_w}(x)
=2w^4\left(\exp\left(\frac{x}{w^2}\right)-1-\frac{x}{w^2}\right).
$$

The index $w$ is interpreted as a positive width budget. The realization itself uses one nonlinear unit, which is admissible under every such budget. Increased $w$ changes the parameters and improves the certified accuracy.

### 2.3 Realization convention

A depth-two computation in this paper consists of a nonlinear hidden stage followed by an affine output stage. We additionally permit a direct linear skip from input to output. Under this convention, a scalar realization has the form

$$
R(x)=c\,\Phi_{a,b,a',b'}(x)+r+sx.
$$

This convention is explicit because architectural terminology varies. If an architecture forbids input-output skips, an additional compilation argument would be required; no such claim is made here.

## 3. Main results

### 3.1 Exact shallow realization

**Theorem 3.1 (Depth-Two Realization Theorem).** Let $h\ne0$. For every $x\in\mathbb R$,

$$
Q_h(x)
=\frac{2}{h^2}\left(\exp(hx+0)-\log(0x+1)\right)
-\frac{2}{h^2}-\frac{2}{h}x.
$$

Consequently, $Q_h$ is realized by one EML nonlinear unit with parameters

$$
(a,b,a',b')=(h,0,0,1),
$$

an output multiplier $2/h^2$, output bias $-2/h^2$, and linear skip coefficient $-2/h$.

**Proof sketch.** The logarithmic branch is $\log(1)=0$. Substitute this identity into the displayed network output and factor $2/h^2$:

$$
\frac{2}{h^2}\exp(hx)-\frac{2}{h^2}-\frac{2}{h}x
=\frac{2}{h^2}\bigl(\exp(hx)-1-hx\bigr)=Q_h(x).
$$

No approximation is used in the realization identity. $\square$

The theorem should be read as a representation result for a specified computational graph. It is not a claim that width $w$ nonlinear units are used, nor that a skip-free architecture has the same exact depth.

### 3.2 Smoothness and exact derivative

**Theorem 3.2 (Derivative Formula).** For every $h\ne0$ and $x\in\mathbb R$, the function $Q_h$ is differentiable at $x$, with

$$
Q_h'(x)=\frac{2}{h^2}\bigl(h\exp(hx)-h\bigr)
       =\frac{2}{h}\bigl(\exp(hx)-1\bigr).
$$

**Proof sketch.** Differentiate $\exp(hx)$ by the chain rule to obtain $h\exp(hx)$. The derivative of $1$ is zero and that of $hx$ is $h$. Multiplication by the constant $2/h^2$ gives the first formula; cancellation of one factor of $h$ gives the second. $\square$

Because the exponential is infinitely differentiable, so is $Q_h$. In particular, there are no derivative discontinuities of the kind produced by a generic piecewise-affine approximation.

A Taylor expansion explains the limiting slope:

$$
Q_h'(x)=\frac{2}{h}\left(hx+\frac{h^2x^2}{2}+\frac{h^3x^3}{6}+\cdots\right)
=2x+hx^2+\frac{h^2x^3}{3}+\cdots.
$$

This expansion motivates, but does not by itself state, a future uniform derivative-rate theorem.

### 3.3 Uniform inverse-square error

The error bound depends on the following scale estimate.

**Lemma 3.3 (Uniform Exponential-Remainder Bound).** If $0<h\le1$ and $x\in[0,1]$, then

$$
\left|Q_h(x)-x^2\right|\le\frac{4}{9}h.
$$

**Proof sketch.** Taylor’s formula gives

$$
\exp(hx)=1+hx+\frac{h^2x^2}{2}
+\sum_{k=3}^{\infty}\frac{(hx)^k}{k!}.
$$

Therefore

$$
Q_h(x)-x^2
=2\sum_{k=3}^{\infty}\frac{h^{k-2}x^k}{k!}.
$$

All summands are nonnegative on the prescribed domain. A uniform remainder estimate for the exponential series on $0\le hx\le1$ bounds this tail by $4h/9$. Equivalently, one may apply the standard third-order exponential remainder bound and then use monotonicity on the compact interval. This yields the stated estimate simultaneously for every $x\in[0,1]$. $\square$

The constant $4/9$ is a global certificate, not claimed to be sharp. Indeed, the leading error term is $hx^3/3$, suggesting an asymptotic supremum constant $1/3$ as $h\to0^+$.

**Theorem 3.4 (Certified Inverse-Square Width Rate).** For every integer $w\ge1$ and every $x\in[0,1]$,

$$
|Q_w(x)-x^2|\le\frac{4}{9w^2}.
$$

Equivalently,

$$
\sup_{x\in[0,1]}|Q_w(x)-x^2|\le\frac{4}{9w^2}.
$$

**Proof sketch.** Since $w\ge1$, the scale $h_w=1/w^2$ satisfies $0<h_w\le1$. Apply Lemma 3.3 with $h=h_w$:

$$
|Q_w(x)-x^2|
\le\frac49h_w
=\frac{4}{9w^2}.
$$

Because this inequality holds for every $x\in[0,1]$, it also bounds the supremum norm. $\square$

This theorem is the principal approximation result. Its scope is precise: the target is $x^2$, the domain is $[0,1]$, the budget is a positive integer, and the guarantee is uniform.

### 3.4 Comparison with an inverse-linear benchmark

**Theorem 3.5 (Non-Strict Benchmark Dominance).** For every integer $w\ge1$,

$$
\frac{4}{9w^2}\le\frac{4}{9w}.
$$

**Proof sketch.** Positivity permits multiplication by $9w^2/4$. The desired inequality becomes $1\le w$, which is the hypothesis. $\square$

**Theorem 3.6 (Strict Benchmark Dominance Beyond Unit Width).** For every integer $w\ge2$,

$$
\frac{4}{9w^2}<\frac{4}{9w}.
$$

**Proof sketch.** After multiplication by the positive quantity $9w^2/4$, the inequality becomes $1<w$, which follows from $w\ge2$. $\square$

These theorems compare certified numerical rates. They do not establish that all ReLU networks have only inverse-linear accuracy. In fact, for a quadratic target, continuous piecewise-linear interpolation can attain inverse-square error when complexity is counted by the number of affine pieces. Any activation-level comparison must therefore specify a common resource model.

## 4. Mechanism of the approximation

The construction is a form of coefficient extraction. For a smooth function $g$, the centered second-order remainder

$$
g(hx)-g(0)-hxg'(0)
$$

is approximately $h^2x^2g''(0)/2$. If $g''(0)\ne0$, suitable rescaling exposes the quadratic. Taking $g=\exp$ is especially convenient because every derivative is explicit and positive.

For the exponential,

$$
\frac{2}{h^2}\bigl(\exp(hx)-1-hx\bigr)
=x^2+\frac{h}{3}x^3+\frac{h^2}{12}x^4+\cdots.
$$

On $[0,1]$, all correction terms are nonnegative, so $Q_h(x)\ge x^2$. The error is expected to be largest near $x=1$. The leading-order prediction is

$$
Q_h(1)-1\sim\frac{h}{3}.
$$

Under $h=w^{-2}$ this becomes

$$
w^2\bigl(Q_w(1)-1\bigr)\to\frac13.
$$

This limit is a natural sharp-constant conjecture for the explicit family. It is not required for the certified $4/(9w^2)$ bound.

The parameter scaling deserves attention. The hidden slope is $h=w^{-2}$, while the output multiplier and skip coefficient have magnitudes

$$
\frac{2}{h^2}=2w^4,
\qquad
\frac{2}{h}=2w^2.
$$

Thus approximation error improves while coefficient magnitudes grow. A complexity theory based only on unit count will regard the family as extremely economical; a norm-constrained theory may assign it a larger cost. Both viewpoints are legitimate, but they answer different questions.

## 5. Algorithms and numerical evaluation

### 5.1 Stable evaluation

Directly evaluating $\exp(z)-1-z$ is inaccurate for small $z$ because two subtractions remove leading digits. Most numerical libraries provide $\operatorname{expm1}(z)$, which evaluates $\exp(z)-1$ accurately near zero.

**Algorithm 5.1 (Stable evaluation of the width-indexed approximant).** Given $w\ge1$ and $x\in[0,1]$:

1. Set $h=1/w^2$.
2. Set $z=hx$.
3. Compute $r=\operatorname{expm1}(z)-z$.
4. Return $2r/h^2$.

The algorithm uses a constant number of arithmetic operations and one transcendental evaluation, so its arithmetic-operation complexity is $O(1)$ per point and its storage is $O(1)$. For an array of $N$ points, independent evaluation costs $O(N)$ time and $O(N)$ output storage.

For extremely small $z$, even $\operatorname{expm1}(z)-z$ may suffer cancellation. A series fallback is then appropriate:

$$
\exp(z)-1-z=\frac{z^2}{2}+\frac{z^3}{6}+\frac{z^4}{24}+\cdots.
$$

### 5.2 Stable derivative evaluation

The derivative is evaluated as

$$
Q_w'(x)=2w^2\operatorname{expm1}\left(\frac{x}{w^2}\right).
$$

This avoids subtracting $1$ from a number close to $1$ using ordinary exponentiation. As with function evaluation, the cost per point is $O(1)$.

### 5.3 Grid diagnostics

A numerical diagnostic selects a grid $x_j=j/(N-1)$ for $j=0,\ldots,N-1$, evaluates the absolute errors, and records their maximum. It then compares that sampled maximum with $4/(9w^2)$. Such a calculation demonstrates scale and implementation behavior but is not a proof of the uniform theorem, because the grid is finite.

A useful report includes:

- the sampled value error $\max_j|Q_w(x_j)-x_j^2|$;
- the certificate $4/(9w^2)$;
- their ratio;
- the sampled derivative error $\max_j|Q_w'(x_j)-2x_j|$;
- the inverse-linear benchmark $4/(9w)$.

The sampled ratio of the value error to $1/w^2$ should approach approximately $1/3$ for moderate $w$ before floating-point conditioning becomes dominant.

## 6. Quantitative consequences

### 6.1 Accuracy-to-budget conversion

The uniform certificate can be inverted. Given a tolerance $\varepsilon>0$, any positive integer $w$ satisfying

$$
\frac{4}{9w^2}\le\varepsilon
$$

is sufficient. Equivalently, one may take

$$
w\ge \left\lceil\frac{2}{3\sqrt{\varepsilon}}\right\rceil.
$$

This is a sufficient budget rule rather than a lower bound. It makes the inverse-square scaling operational: reducing the certified tolerance by a factor of $r$ increases the sufficient index by a factor of approximately $\sqrt r$.

For example, a certificate below $10^{-2}$ is obtained once $w\ge7$, since $4/(9\cdot49)<10^{-2}$. A certificate below $10^{-4}$ is obtained once $w\ge67$. The actual error is expected to be lower because the constant $4/9$ is not sharp.

### 6.2 Monotonicity of the error

The series representation supplies additional qualitative information. For $h>0$ and $x\ge0$,

$$
E_h(x)=Q_h(x)-x^2
=2\sum_{k=3}^{\infty}\frac{h^{k-2}x^k}{k!}
$$

is nonnegative. Differentiating the series term by term gives

$$
E_h'(x)=2\sum_{k=3}^{\infty}\frac{h^{k-2}x^{k-1}}{(k-1)!}\ge0.
$$

Thus the error is nondecreasing on $[0,1]$, and its supremum occurs at $x=1$. This observation is consistent with the exact expression

$$
\sup_{x\in[0,1]}|Q_h(x)-x^2|
=Q_h(1)-1
=\frac{2}{h^2}\bigl(\exp(h)-1-h\bigr)-1.
$$

It provides a direct route toward the conjectured sharp asymptotic constant. Expanding the endpoint formula gives

$$
Q_h(1)-1=\frac{h}{3}+\frac{h^2}{12}+O(h^3).
$$

With $h=w^{-2}$, multiplication by $w^2$ leaves a leading term of $1/3$. These sharper observations explain why the certified constant $4/9$ has slack, though the global certificate remains convenient for all $w\ge1$.

### 6.3 Coefficient growth and conditioning

The construction separates representational complexity from numerical conditioning. Its nonlinear width is fixed at one, but its output coefficients grow polynomially with $w$. If values are computed by separately forming

$$
2w^4\exp(x/w^2),\qquad 2w^4,\qquad 2w^2x,
$$

then large quantities cancel to leave a value of order one. Standard floating-point arithmetic may lose significant digits. Stable evaluation should instead preserve the small exponential remainder before applying the large multiplier. This distinction is relevant to training as well: a parameterization with large, canceling weights may have unfavorable optimization geometry even when its represented function is excellent.

A norm-aware approximation theorem would therefore track both error and parameter magnitudes. The present result isolates the approximation mechanism and supplies exact growth rates for those magnitudes, providing the data needed for such a refinement.

## 7. Applications and interpretation

### 7.1 Quadratic modules and multiplication

The identity

$$
xy=\frac{(x+y)^2-(x-y)^2}{4}
$$

turns square approximation into multiplication approximation. If a square module is valid on an interval containing $x+y$ and $x-y$, two copies can be combined linearly to approximate a product. Domain rescaling is required when the arguments leave $[0,1]$. This observation connects the quadratic test to polynomial feature maps, bilinear interactions, and energy functions.

### 7.2 Smooth surrogate models

The exact derivative formula makes $Q_w$ suitable as a smooth surrogate where sensitivities are part of the output. Potential settings include differentiable simulation, continuous control, inverse problems, and models constrained by differential equations. The present theorem certifies only function values; a uniform derivative certificate remains a separate result to establish.

### 7.3 Activation design

The approximation illustrates a general design principle: affine readouts can cancel low-order Taylor terms, leaving a desired higher-order component. For the EML family, setting the logarithmic branch to zero isolates an exponential whose second derivative is nonzero. More elaborate parameter choices might exploit both branches to control higher-order terms, reduce coefficient growth, or approximate functions with asymmetric curvature.

## 8. Scope, limitations, and fair comparisons

The result is deliberately narrow and should not be promoted into claims it does not support.

First, it concerns one smooth target in one dimension. It does not prove that every Lipschitz function on $[0,1]^n$ can be approximated at rate $O((wd)^{-2/n})$. General Lipschitz functions need not have Taylor expansions, and multivariate approximation requires a covering or partition strategy.

Second, the parameter $w$ controls $h=w^{-2}$ but does not count active neurons in the displayed formula. The construction fits within width at most $w$ because it uses one nonlinear unit, but the improved rate arises from parameter scaling rather than adding units. If coefficient norms are constrained, the effective complexity changes.

Third, the depth-two statement permits a linear skip connection. A strict sequential architecture may require an additional unit or layer to transport the input. Establishing exact depth and width in such a model requires an architecture-specific compilation theorem.

Fourth, the inverse-linear comparison is only a comparison of two formulas. It is not a ReLU lower bound. A fair region-count comparison with continuous piecewise-linear functions is expected to yield inverse-square behavior for $x^2$, with a sharp interpolation error of order $1/w^2$. Thus the benefit highlighted here is smoothness and explicit shallow realization, not a demonstrated asymptotic separation from every piecewise-linear method.

Finally, finite-precision stability limits naive evaluation at very large $w$. The coefficients grow as $w^4$ and cancellation becomes severe. Stable primitives, series expansions, or higher precision are needed to observe the mathematical rate numerically.

These limitations also clarify the role of the theorem in empirical work. The family is a controlled baseline: its parameters can be initialized analytically, its output can be compared against exact values, and its error envelope is known in advance. An optimization experiment that fails to recover comparable behavior would diagnose training or conditioning rather than lack of representational capacity. Conversely, success on this target would not establish broad generalization, because the construction is tailored to the quadratic’s Taylor structure. The test is therefore best viewed as a calibration instrument for architectures and optimizers, not as a comprehensive benchmark of learning ability.

## 9. Future research

Five directions emerge naturally.

1. **Multivariate EML rate.** Determine whether, for every $n\ge1$, every $L$-Lipschitz function on $[0,1]^n$, and all positive $w,d$, there exists an EML network of width at most $w$ and depth at most $d$ with uniform error at most $C(n)L(wd)^{-2/n}$, where $C(n)$ is independent of the target, $w$, and $d$.

2. **Architecture-intrinsic realization.** In a strict layered model whose only nonlinear activation is $\exp(ax+b)-\log(a'x+b')$, determine whether the present function can be implemented with depth exactly two and width at most $w$ for every $w\ge1$, without relying on an uncompiled skip.

3. **Sharp asymptotic constant.** Establish whether

$$
\lim_{w\to\infty}w^2\sup_{x\in[0,1]}|Q_w(x)-x^2|=\frac13.
$$

4. **Piecewise-linear region comparison.** Prove the sharp uniform error for continuous piecewise-linear approximation of $x^2$ with at most $w$ affine pieces, including the proposed $1/(8w^2)$ lower bound and equal-mesh construction, under a precisely aligned convention.

5. **Uniform gradient convergence.** Prove a universal constant $C$ such that

$$
\sup_{x\in[0,1]}|Q_w'(x)-2x|\le\frac{C}{w^2}
$$

for every positive integer $w$.

## 10. Reproducible numerical protocol

A numerical study of this family should separate mathematical error from arithmetic error. For each selected width, first compute the approximant with a cancellation-aware exponential remainder. Next evaluate a nested sequence of grids, for example with $10^3$, $2\cdot10^3$, and $4\cdot10^3$ subintervals. Because the error is monotone for this specific family, the endpoint value offers an exact numerical cross-check; the grid maximum should occur at $x=1$. Report both the raw maximum and the rescaled quantity $w^2$ times that maximum.

Three sanity checks are recommended. First, every sampled value error must lie below $4/(9w^2)$. Second, the inverse-square certificate must not exceed $4/(9w)$, with strict separation for $w\ge2$. Third, the rescaled endpoint error should move toward $1/3$ as $w$ increases, until finite precision interferes. Failure of the first two checks indicates an implementation error; failure of the third at very large widths may instead indicate cancellation.

Derivative diagnostics should be reported separately, since the established value theorem does not certify them. Evaluate $2\operatorname{expm1}(x/w^2)w^2$ and compare it with $2x$. Label the resulting maximum as sampled evidence rather than a proved bound. This distinction preserves the line between the theorem’s scope and the motivating gradient-convergence conjecture.

Finally, report the floating-point type, grid size, evaluation formula, and whether a series fallback was used. These details are essential because the naive algebraically equivalent expression combines terms of size $w^4$. A reproducible experiment is not merely a plot: it states enough numerical methodology for another reader to obtain the same curves and diagnose any discrepancy.

## 11. Conclusion

A single EML unit can expose the quadratic term hidden in the exponential series. After an affine readout and linear skip, the resulting smooth function is

$$
Q_h(x)=\frac{2}{h^2}\bigl(\exp(hx)-1-hx\bigr),
$$

with exact derivative $2(\exp(hx)-1)/h$. Choosing $h=w^{-2}$ produces a width-indexed family satisfying the uniform bound

$$
\sup_{x\in[0,1]}|Q_w(x)-x^2|\le\frac{4}{9w^2}.
$$

This certificate improves on the matched inverse-linear expression for all positive budgets and strictly improves it for $w\ge2$. The result provides a transparent test case for smooth neural approximation: its mechanism, architecture, error, derivative, and numerical conditioning are all explicit. It also delineates the next steps required for a general theory—multivariate targets, strict architecture accounting, sharp constants, gradient bounds, and resource-aligned comparisons with piecewise-linear methods.
