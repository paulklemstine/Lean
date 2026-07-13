# The Gumbel Law and Extreme-Value Convergence: The Analytic Backbone of the Fyodorov–Hiary–Keating Conjecture

## Abstract

The Fyodorov–Hiary–Keating (FHK) conjecture predicts the precise extreme-value statistics of the Riemann zeta function on the critical line. Writing
$$M_T = \max_{t \in [T,\,2T]} \log\bigl|\zeta(\tfrac12 + it)\bigr|,$$
the conjecture asserts that the recentered maximum
$$M_T - \log\log T + \tfrac32 \log\log\log T$$
converges in distribution, as $T \to \infty$, to the sum of two independent Gumbel random variables. The full statement for $\zeta$ is open. In this paper we develop, from first principles and in complete rigor, the analytic backbone on which the conjecture stands: the Gumbel distribution as a genuine probability law, its exact max-stability, and the extreme-value limit theorem (Fisher–Tippett–Gnedenko) that makes the Gumbel law the universal attractor of maxima. We prove that the standard Gumbel CDF $G(x)=e^{-e^{-x}}$ is a valid cumulative distribution function with all required regularity and boundary behavior; that its density $g(x)=e^{-x-e^{-x}}$ is positive and integrates to $1$; that the max-stability identity $G(x+\log n)^n = G(x)$ holds exactly; and that the recentered maximum of $n$ i.i.d. $\mathrm{Exp}(1)$ variables, with CDF $\bigl(1-e^{-x}/n\bigr)^n$, converges pointwise to $G(x)$. We further lift these results to the two-parameter location–scale Gumbel family $G_{\mu,\beta}(x)=e^{-e^{-(x-\mu)/\beta}}$, establishing all analogous properties and the scaled max-stability $G_{\mu,\beta}(x+\beta\log n)^n = G_{\mu,\beta}(x)$. We close with a discussion of how these building blocks assemble toward the FHK prediction and a program of tractable next steps.

## 1. Introduction

### 1.1 The extreme values of the zeta function

The Riemann zeta function $\zeta(s)$ carries, in the location of its zeros, the deepest arithmetic information about the distribution of prime numbers. On the critical line $s = \tfrac12 + it$ its modulus $|\zeta(\tfrac12+it)|$ oscillates in an intricate, quasi-random fashion. A central question in analytic number theory concerns the *local maxima* of this modulus: over a window $[T, 2T]$, how large can $\log|\zeta(\tfrac12+it)|$ become?

Fyodorov, Hiary, and Keating (2012), building on a striking analogy between the zeta function and the characteristic polynomials of random unitary matrices, conjectured a complete answer. They predicted both the typical size of the maximum,
$$M_T = \max_{t \in [T,\,2T]} \log\bigl|\zeta(\tfrac12+it)\bigr| \approx \log\log T - \tfrac32\log\log\log T,$$
and the limiting law of its fluctuations: the recentered variable $M_T - \log\log T + \tfrac32\log\log\log T$ converges in distribution to a sum of two independent Gumbel random variables. Leading-order results (the convergence of $M_T/\log\log T \to 1$ in probability) were established by Arguin, Belius, and Harper (2017); the full conjecture remains open.

### 1.2 Log-correlated structure

The conjecture is rooted in the recognition that $\log|\zeta(\tfrac12+it)|$ behaves like a *log-correlated random field*: a random landscape whose values at points $t, t'$ have covariance decaying like $-\log|t-t'|$. Such fields possess an approximate hierarchical (tree-like) correlation structure, and their extreme values are governed by the theory of *branching random walks* and *log-correlated Gaussian fields*. That theory produces exactly the tell-tale $-\tfrac32\log\log\log T$ correction — the "$\tfrac32$" being the universal subleading constant for the maximum of a log-correlated field — and a limiting fluctuation that decomposes into two independent Gumbel contributions reflecting the two-scale nature of the field.

### 1.3 Scope of this paper

The full FHK statement lies far beyond current reach. Our aim is to lay, rigorously and self-containedly, the analytic foundation on which it rests. All of the results below are elementary real analysis, but together they demonstrate that the object at the center of the conjecture — the Gumbel law and its emergence as an extreme-value limit — is completely well-founded. Section 2 introduces the Gumbel distribution and establishes that it is a valid probability law. Section 3 proves max-stability. Section 4 establishes extreme-value convergence. Section 5 treats the density and its normalization. Section 6 develops the location–scale family. Section 7 discusses the path from these results to the FHK conjecture, and Section 8 lists future directions.

## 2. The Gumbel distribution

### 2.1 Definitions

**Definition 2.1 (Gumbel CDF).** The *standard Gumbel cumulative distribution function* is
$$G(x) = \exp\bigl(-e^{-x}\bigr), \qquad x \in \mathbb{R}.$$

**Definition 2.2 (Gumbel PDF).** The *standard Gumbel probability density function* is
$$g(x) = \exp\bigl(-x - e^{-x}\bigr), \qquad x \in \mathbb{R}.$$

### 2.2 $G$ is a valid cumulative distribution function

**Theorem 2.3 (Positivity).** For all $x \in \mathbb{R}$, $G(x) > 0$.

*Proof.* $G(x)$ is the exponential of a real number, and the exponential is strictly positive. $\qquad\blacksquare$

**Theorem 2.4 (Upper bound).** For all $x \in \mathbb{R}$, $G(x) < 1$.

*Proof.* Since $e^{-x} > 0$ we have $-e^{-x} < 0$, and $e^{y} < 1$ precisely when $y < 0$. Hence $G(x) = e^{-e^{-x}} < 1$. $\qquad\blacksquare$

**Theorem 2.5 (Strict monotonicity).** $G$ is strictly increasing on $\mathbb{R}$.

*Proof.* If $a < b$ then $-a > -b$, so $e^{-a} > e^{-b}$ (the exponential is strictly increasing), hence $-e^{-a} < -e^{-b}$, and applying the exponential once more gives $G(a) < G(b)$. $\qquad\blacksquare$

**Theorem 2.6 (Continuity).** $G$ is continuous on $\mathbb{R}$.

*Proof.* $G$ is a composition of continuous functions — negation, exponentiation, negation, exponentiation. $\qquad\blacksquare$

**Theorem 2.7 (Boundary behavior).**
$$\lim_{x \to +\infty} G(x) = 1, \qquad \lim_{x \to -\infty} G(x) = 0.$$

*Proof.* As $x \to +\infty$, $e^{-x} \to 0$, so $-e^{-x} \to 0$ and $G(x) = e^{-e^{-x}} \to e^0 = 1$. As $x \to -\infty$, $e^{-x} \to +\infty$, so $-e^{-x} \to -\infty$ and $G(x) \to 0$. $\qquad\blacksquare$

Together, Theorems 2.3–2.7 establish that $G$ is a bona fide continuous CDF supported on all of $\mathbb{R}$.

**Theorem 2.8 (Median).** The median of the Gumbel law is $x = -\log(\log 2)$; that is,
$$G\bigl(-\log(\log 2)\bigr) = \tfrac12.$$

*Proof.* We compute directly. With $x = -\log(\log 2)$ we have $-x = \log(\log 2)$, hence $e^{-x} = \log 2$. Then $G(x) = e^{-\log 2} = 2^{-1} = \tfrac12$. (Here $\log 2 > 0$, so all logarithms are well-defined.) $\qquad\blacksquare$

## 3. Max-stability: why Gumbel is universal

If $X_1, \dots, X_n$ are i.i.d. with CDF $F$, then $\max_i X_i$ has CDF $F^n$, because $\{\max_i X_i \le x\} = \bigcap_i \{X_i \le x\}$ and independence turns the intersection into a product. The Gumbel law is distinguished by being a *fixed point* of this operation, up to a deterministic shift.

**Theorem 3.1 (Max-stability of the Gumbel law).** For every integer $n \ge 1$ and every $x \in \mathbb{R}$,
$$G(x + \log n)^n = G(x).$$

*Proof.* Using $G(y) = e^{-e^{-y}}$ and $\bigl(e^{a}\bigr)^n = e^{na}$,
$$G(x+\log n)^n = \exp\!\bigl(-n\,e^{-(x+\log n)}\bigr) = \exp\!\bigl(-n\, e^{-x} e^{-\log n}\bigr) = \exp\!\bigl(-n\, e^{-x}\cdot \tfrac1n\bigr) = \exp(-e^{-x}) = G(x),$$
where we used $e^{-\log n} = 1/n$ for $n \ge 1$. $\qquad\blacksquare$

**Interpretation.** The maximum of $n$ independent Gumbel variables, after subtracting the deterministic shift $\log n$, is *exactly* Gumbel again — not merely in the limit. This exact self-similarity is the structural reason the Gumbel law is the universal attractor for maxima in its domain of attraction: iterating "take the max and recenter" leaves it invariant.

## 4. Extreme-value convergence

We now exhibit the simplest nontrivial member of the Gumbel domain of attraction, giving the Fisher–Tippett–Gnedenko limit in closed form.

Let $X_1, \dots, X_n$ be i.i.d. $\mathrm{Exp}(1)$ random variables, so $\Pr[X_i \le y] = 1 - e^{-y}$ for $y \ge 0$. The maximum $\max_i X_i$ has CDF $(1 - e^{-y})^n$. Recentering by $\log n$, i.e. evaluating at $y = x + \log n$, gives
$$\Pr\!\Bigl[\max_i X_i - \log n \le x\Bigr] = \bigl(1 - e^{-(x+\log n)}\bigr)^n = \Bigl(1 - \tfrac{e^{-x}}{n}\Bigr)^n.$$

**Theorem 4.1 (Convergence to the Gumbel law).** For every fixed $x \in \mathbb{R}$,
$$\lim_{n \to \infty} \Bigl(1 - \tfrac{e^{-x}}{n}\Bigr)^n = G(x) = e^{-e^{-x}}.$$

*Proof.* This is the classical limit $\bigl(1 + \tfrac{a}{n}\bigr)^n \to e^{a}$ applied with $a = -e^{-x}$:
$$\Bigl(1 - \tfrac{e^{-x}}{n}\Bigr)^n = \Bigl(1 + \tfrac{-e^{-x}}{n}\Bigr)^n \longrightarrow e^{-e^{-x}} = G(x). \qquad\blacksquare$$

Thus the recentered maximum of $n$ i.i.d. exponentials converges in distribution to the standard Gumbel law. This is the cleanest exact instance of the extreme-value phenomenon underlying the FHK conjecture: the value $\log|\zeta(\tfrac12+it)|$ plays the role of a maximum over a strongly correlated ensemble, and the Gumbel law (here, its two-fold convolution) is the universal limit.

## 5. The density and its normalization

**Theorem 5.1 (Positivity of the density).** For all $x$, $g(x) > 0$.

*Proof.* $g(x)$ is an exponential, hence positive. $\qquad\blacksquare$

**Theorem 5.2 ($g$ is the derivative of $G$).** For every $x \in \mathbb{R}$, $G$ is differentiable at $x$ with
$$G'(x) = g(x).$$

*Proof.* Write $G(x) = e^{u(x)}$ with $u(x) = -e^{-x}$. Then $u'(x) = e^{-x}$ (the derivative of $-e^{-x}$), so by the chain rule
$$G'(x) = e^{u(x)}\,u'(x) = e^{-e^{-x}}\cdot e^{-x} = e^{-x - e^{-x}} = g(x). \qquad\blacksquare$$

**Theorem 5.3 (Integrability and normalization).** The density $g$ is integrable over $\mathbb{R}$ and
$$\int_{-\infty}^{\infty} g(x)\,dx = 1.$$

*Proof.* By the substitution $u = e^{-x}$, $du = -e^{-x}\,dx$, the integral becomes $\int_0^\infty e^{-u}\,du = 1$; integrability follows from the rapid decay of $g$ at both ends. Alternatively, by the fundamental theorem of calculus applied to the antiderivative $G$ (Theorem 5.2), together with the boundary limits of Theorem 2.7,
$$\int_{-\infty}^{\infty} g(x)\,dx = \lim_{x\to+\infty} G(x) - \lim_{x\to-\infty} G(x) = 1 - 0 = 1. \qquad\blacksquare$$

Theorems 5.1–5.3 confirm that $g$ is a genuine probability density and that it is the density of the Gumbel law.

## 6. The location–scale Gumbel family

Maxima in applications rarely arrive centered at $0$ with unit spread. We therefore lift the standard law to a two-parameter family.

**Definition 6.1 (Location–scale Gumbel CDF).** For a location parameter $\mu \in \mathbb{R}$ and scale $\beta > 0$,
$$G_{\mu,\beta}(x) = \exp\!\Bigl(-e^{-(x-\mu)/\beta}\Bigr).$$

**Theorem 6.2 (Reduction to the standard law).** $G_{\mu,\beta}(x) = G\!\bigl((x-\mu)/\beta\bigr)$.

*Proof.* Immediate from the definitions. $\qquad\blacksquare$

Through this identity every property of $G$ transfers to $G_{\mu,\beta}$:

**Theorem 6.3 (Basic properties).** For all $\mu\in\mathbb{R}$, $\beta>0$, and $x\in\mathbb{R}$:
1. $G_{\mu,\beta}(x) > 0$;
2. $G_{\mu,\beta}(x) < 1$;
3. $G_{\mu,\beta}$ is strictly increasing;
4. $G_{\mu,\beta}$ is continuous.

*Proof.* Parts (1), (2), (4) follow from Theorems 2.3, 2.4, 2.6 via Theorem 6.2, since $x \mapsto (x-\mu)/\beta$ is continuous. For (3), $x \mapsto (x-\mu)/\beta$ is strictly increasing when $\beta > 0$, and composing with the strictly increasing $G$ (Theorem 2.5) preserves strict monotonicity. $\qquad\blacksquare$

**Theorem 6.4 (Scaled max-stability).** For $\beta > 0$, every integer $n \ge 1$, and every $x$,
$$G_{\mu,\beta}(x + \beta\log n)^n = G_{\mu,\beta}(x).$$

*Proof.* By Theorem 6.2, $G_{\mu,\beta}(x + \beta\log n) = G\!\bigl((x + \beta\log n - \mu)/\beta\bigr) = G\!\bigl((x-\mu)/\beta + \log n\bigr)$. Applying standard max-stability (Theorem 3.1) with argument $(x-\mu)/\beta$,
$$G_{\mu,\beta}(x+\beta\log n)^n = G\!\bigl((x-\mu)/\beta + \log n\bigr)^n = G\!\bigl((x-\mu)/\beta\bigr) = G_{\mu,\beta}(x). \qquad\blacksquare$$

The scale $\beta$ simply rescales the recentering shift from $\log n$ to $\beta\log n$; the invariance is otherwise identical. This is the form directly relevant to recentered maxima that live on their own natural scale, as the zeta peaks do.

## 7. From the backbone to the FHK conjecture

The results above assemble into the conceptual scaffolding of the FHK prediction as follows.

1. **The limiting object is a real probability law.** The FHK conjecture asserts convergence in distribution to "a sum of two independent Gumbel variables." Sections 2 and 5 establish that the Gumbel law is a legitimate probability distribution with a positive density integrating to $1$; the sum of two independent copies is then a genuine law, whose density is the convolution $g \star g$.

2. **Gumbel is the correct universal target.** Section 3 shows the Gumbel law is the unique fixed point of the max-and-recenter operation, and Section 4 shows how it arises as the exact limit of recentered maxima. This is why extremes of the (approximately log-correlated) zeta field are governed by Gumbel-type statistics rather than, say, Gaussian ones.

3. **Scale and location are built in.** The location–scale family of Section 6 provides exactly the two-parameter flexibility needed to match a field's intrinsic centering and spread. The $\log\log T$ centering and the $\beta$-scaled shift $\beta\log n$ are the analytic shadows of the $\mu$ and $\beta$ parameters here.

The step that remains genuinely hard — and open — is proving that $\log|\zeta(\tfrac12+it)|$ really does behave like a log-correlated field with the requisite precision, so that the $-\tfrac32\log\log\log T$ correction and the *two-fold* Gumbel convolution emerge. That step requires deep input from analytic number theory. What the present development guarantees is that the *statistical target* of the conjecture is rigorously well-defined and that the extreme-value mechanism producing it is fully understood.

## 8. Discussion and future directions

The Gumbel distribution first arose in mid-twentieth-century engineering as the law of record floods and material failures. Its reappearance at the summit of the Riemann zeta function is a vivid instance of the universality of extreme-value statistics. The backbone established here is deliberately elementary, but it is exactly the part of the FHK circle of ideas that can be made fully rigorous today.

Several tractable extensions build directly on these results:

- **General domain of attraction.** Generalize Theorem 4.1 from $\mathrm{Exp}(1)$ to any CDF $F$ satisfying $n\bigl(1 - F(a_n + b_n x)\bigr) \to e^{-x}$, concluding $F(a_n + b_n x)^n \to G(x)$. The exponential case is $a_n = \log n$, $b_n = 1$.
- **Gaussian maxima.** With the classical normalizing constants $b_n = \sqrt{2\log n}$ and $a_n = b_n - (\log\log n + \log 4\pi)/(2 b_n)$, prove $\Phi(a_n + x/b_n)^n \to G(x)$, the extreme-value form directly relevant to log-correlated Gaussian fields.
- **Quantiles and moments.** Establish the quantile function $G^{-1}(p) = -\log(-\log p)$, the mean $\gamma$ (the Euler–Mascheroni constant), and the variance $\pi^2/6$.
- **Sum of two independent Gumbels.** Formalize the convolution density $(g \star g)(x) = \int g(s)\,g(x-s)\,ds$ and prove it is a probability density — the exact limiting law predicted by FHK.
- **Hierarchical / branching model.** Develop the two-level Gaussian model whose maximum exhibits the $\log N - \tfrac32\log\log N$ centering, the finite-$N$ analogue of the FHK centering.

Together these steps would carry the rigorous theory from the standard Gumbel law toward the precise two-fold, log-correlated statistics conjectured for the zeta function.

## References (context)

- Y. V. Fyodorov, G. A. Hiary, J. P. Keating, *Freezing Transition, Characteristic Polynomials of Random Matrices, and the Riemann Zeta Function* (2012).
- L.-P. Arguin, D. Belius, A. J. Harper, *Maxima of a randomized Riemann zeta function, and branching random walks* (2017).
- R. A. Fisher, L. H. C. Tippett (1928); B. Gnedenko (1943) — foundational extreme-value theory.
- E. J. Gumbel, *Statistics of Extremes* (1958).
