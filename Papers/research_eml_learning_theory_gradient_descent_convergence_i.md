# Gradient Descent in the Tropical Limit: Sharpness, Dequantization, and Linear Convergence for Max-Plus Learning

**Aristotle**

**Date:** 2026-08-16

---

## Abstract

We develop a complete first-order learning theory for exp–log (EML) neural units in their tropical, or large-weight, limit. Three strands are combined. First, we quantify Maslov dequantization: a smooth log-sum-exp aggregator at temperature $T$ over $k$ terms differs from the corresponding max-plus fold by at most $T\log k$, uniformly in the input, so that an EML neuron converges to a tropical polynomial as $T\to 0^{+}$ (equivalently as the weight scale $s = 1/T \to \infty$). Second, we prove an exact dictionary in one variable: a function $\mathbb{R}\to\mathbb{R}$ is a tropical rational function — a difference of two finite maxima of affine functions — if and only if it is computed by a feed-forward rectifier network of arbitrary depth; both inclusions are given by explicit constructions in which each tropical monomial costs exactly one rectifier unit. Third, we analyse training. The tropical absolute-error empirical risk of a max-plus monomial is itself a tropical polynomial in the parameter, convex, $N$-Lipschitz, and — crucially — **sharp**: on an ordered odd sample of size $N=2m+1$ it satisfies $R(\theta) \ge R(\theta^\star) + |\theta-\theta^\star|$ with $\theta^\star$ the median residual, which is therefore the unique empirical risk minimizer. Fixed-step subgradient descent then attains the optimal general rate $O(DG/\sqrt n)$ in risk, and by sharpness the same rate in parameter error, with $G=N$. Sharpness further yields a genuinely faster regime: subgradient descent with Polyak steps contracts the squared distance to the optimum by the factor $1-\mu^2/G^2$ per iteration, giving $(\theta_n-\theta^\star)^2 \le (1-1/N^2)^n(\theta_0-\theta^\star)^2$ for tropical training, together with convergence of the trained model to a tropical rational minimizer. We show the boundary of the theory is sharp in the other sense too: an explicit three-sample instance exhibits an exact two-cycle under a fixed step, so that the iterates never come within distance $2$ of the unique minimizer. Finally, a risk-landscape equivalence shows that a function is tropical rational precisely when some rectifier network has the same empirical risk on *every* data set; hence tropical and rectifier training see literally identical landscapes and all rates transfer verbatim. The speed of first-order training is thus governed not by the parameterization but by two tropical invariants: the maximal slope $G$ and the sharpness constant $\mu$.

**Keywords:** tropical geometry, max-plus algebra, Maslov dequantization, rectifier networks, subgradient methods, sharpness / error bounds, Polyak step size, piecewise-linear optimization.

---

## 1. Introduction

### 1.1 Motivation

Neural networks built from rectifier nonlinearities compute piecewise-linear functions. This is not an approximation; it is an identity. Consequently the entire apparatus of smooth optimization — gradients, Hessians, strong convexity, smoothness constants — sits uneasily on the actual object being optimized, which has no second derivative anywhere and no first derivative on a codimension-one set.

Tropical geometry supplies the native language. In the max-plus semiring $(\mathbb{R}\cup\{-\infty\}, \oplus, \odot)$ with $a \oplus b = \max(a,b)$ and $a\odot b = a + b$, a polynomial is a finite maximum of affine functions and a rational function is a difference of two such maxima. The class of tropical rational functions in one variable is exactly the class of continuous piecewise-linear functions with finitely many pieces. That the class of rectifier networks coincides with it is folklore; what we supply here are explicit, constructive translations in both directions, with a tight accounting of cost (one rectifier per tropical monomial), and — more importantly — a *training theory* stated entirely in tropical invariants.

The second motivation is the appearance of smooth exp–log aggregators throughout modern architectures. Write

$$\mathrm{LSE}_T(u_1,\dots,u_k) \;=\; T\log\Bigl(\sum_{j=1}^k e^{u_j/T}\Bigr).$$

At $T=1$ this is the log-partition function; softmax attention, mixture gating, and energy-based blending are all instances. The parameter $T$ is a temperature, and $s=1/T$ is the overall weight scale. In the *large-weight* regime $s\to\infty$ the aggregator degenerates to $\max_j u_j$. This degeneration is Maslov dequantization, the semiring-level shadow of the zero-temperature limit in statistical mechanics. Our first task is to make it quantitative and uniform.

### 1.2 Contributions

1. **Quantitative dequantization (Section 3).** Two-sided bounds $\max_j u_j \le \mathrm{LSE}_T \le \max_j u_j + T\log k$, hence a uniform-in-input approximation of an EML neuron by a tropical polynomial with error $T\log k$, and convergence as $T\to 0^+$ and as $s\to\infty$.
2. **The tropical/rectifier dictionary (Section 4).** A function $f:\mathbb{R}\to\mathbb{R}$ is tropical rational iff a rectifier expression computes it. Both directions are constructive; the forward direction is a structural induction establishing that tropical rational functions form a lattice-ordered vector space closed under $\mathrm{relu}$, and the reverse is the identity $\max(u,v)=v+\mathrm{relu}(u-v)$ applied monomial by monomial.
3. **Sharpness of the tropical risk (Section 5).** For ordered residuals of odd sample size, $R(\theta) \ge R(\theta^\star) + |\theta-\theta^\star|$ with $\theta^\star$ the median. Uniqueness of the minimizer is an immediate corollary.
4. **Rates (Sections 6–7).** The classical $O(DG/\sqrt n)$ best-iterate bound for fixed steps, specialized to $G=N$; the automatic transfer to parameter error via sharpness; and a geometric rate $1-\mu^2/G^2$ per step for Polyak steps, instantiated as $1-1/N^2$.
5. **Negative result (Section 8).** An exact two-cycle for a fixed step, showing that "gradient descent converges" is false as literally stated in the tropical regime.
6. **Landscape equivalence (Section 9).** Tropical rationality is equivalent to having the same empirical risk as some rectifier network on every data set; the speed-up therefore comes from tropical geometry, not from parameterization.

---

## 2. Setting and definitions

Throughout, $\mathrm{relu}(u) = \max(u,0)$.

**Definition 2.1 (Max-plus fold).** For $b \in \mathbb{R}$ and a finite list $\ell = [y_1,\dots,y_r]$ of reals, define
$$\mathrm{tmax}(b;\ell) \;=\; \max\{b, y_1, \dots, y_r\},$$
with $\mathrm{tmax}(b;[\,]) = b$. This is the tropical sum $b \oplus y_1 \oplus \cdots \oplus y_r$ of a nonempty family; the base $b$ guarantees nonemptiness, so no $-\infty$ is needed.

**Definition 2.2 (Tropical polynomial function).** For a base pair $b=(b_1,b_2)\in\mathbb{R}^2$ and a finite list $\ell$ of pairs $t = (t_1,t_2) \in \mathbb{R}^2$, define
$$P_{b,\ell}(x) \;=\; \mathrm{tmax}\bigl(b_1 x + b_2;\; [\,t_1 x + t_2 : t \in \ell\,]\bigr) \;=\; \max\Bigl(b_1x+b_2,\ \max_{t\in\ell}(t_1x+t_2)\Bigr).$$
Each pair $(t_1,t_2)$ is a *tropical monomial* with slope $t_1$ and coefficient $t_2$. A function $f:\mathbb{R}\to\mathbb{R}$ **is a tropical polynomial** if $f = P_{b,\ell}$ for some $b,\ell$.

**Definition 2.3 (Tropical rational function).** $f:\mathbb{R}\to\mathbb{R}$ is *tropical rational* if $f = P - Q$ pointwise for tropical polynomials $P,Q$. (In the semiring, $P-Q$ is the tropical quotient $P \oslash Q$.)

**Definition 2.4 (Rectifier expressions).** The set of rectifier expressions is generated inductively by
$$e \;::=\; \mathrm{affine}(a,b) \;\mid\; e_1 + e_2 \;\mid\; c\cdot e \;\mid\; \mathrm{act}(e),$$
with semantics $\mathrm{affine}(a,b)(x) = ax+b$, $(e_1+e_2)(x) = e_1(x)+e_2(x)$, $(c\cdot e)(x) = c\,e(x)$, and $\mathrm{act}(e)(x) = \mathrm{relu}(e(x))$. Depth and width are unrestricted and weights are arbitrary reals; this is exactly the class of one-dimensional feed-forward rectifier networks.

**Definition 2.5 (Subgradient oracle).** A map $g:\mathbb{R}\to\mathbb{R}$ is a *subgradient oracle* for $f:\mathbb{R}\to\mathbb{R}$ if for all $x,y$,
$$f(x) + g(x)(y-x) \;\le\; f(y).$$
This affine-minorant property is all that the convergence analysis uses; in particular it entails convexity of $f$ and needs no differentiability.

**Definition 2.6 (Fixed-step subgradient descent).** $\theta_0 = x_0$ and $\theta_{k+1} = \theta_k - \eta\,g(\theta_k)$.

**Definition 2.7 (Polyak step).** Given the optimal value $f^\star$,
$$\mathrm{PS}(x) \;=\; \begin{cases} x, & g(x)=0,\\[2pt] x - \dfrac{f(x)-f^\star}{g(x)^2}\,g(x), & g(x)\neq 0,\end{cases}$$
and $\theta_{k+1} = \mathrm{PS}(\theta_k)$.

**Definition 2.8 (Tropical $L^1$ training problem).** For residual targets $y_0,\dots,y_{N-1}$,
$$R(x) \;=\; \sum_{i=0}^{N-1}|x - y_i|, \qquad g(x) \;=\; \sum_{i=0}^{N-1}\mathrm{sgn}^{+}(x-y_i), \quad \mathrm{sgn}^{+}(u) = \begin{cases}+1,& u\ge 0\\ -1,& u<0.\end{cases}$$

**Definition 2.9 (Tropical model and empirical risk).** The trainable max-plus monomial is $M_\theta(z) = z \odot \theta = z + \theta$, and for data $(X_i,Y_i)_{i<N}$ the empirical risk of a hypothesis $f$ is $\mathcal{R}(f) = \sum_{i<N}|f(X_i)-Y_i|$. Setting $y_i = Y_i - X_i$ gives $\mathcal{R}(M_\theta) = R(\theta)$ exactly.

**Definition 2.10 (Sharpness).** $f$ is *sharp with constant $\mu>0$ at $z$* with optimal value $f^\star = f(z)$ if
$$f^\star + \mu|x-z| \;\le\; f(x) \quad\text{for all } x.$$

---

## 3. Quantitative Maslov dequantization

**Definition 3.1 (Smooth EML aggregator).** For $T>0$, $b\in\mathbb{R}$ and a list $\ell$,
$$\mathrm{LSE}_T(b;\ell) \;=\; T\log\Bigl(e^{b/T} + \sum_{y\in\ell} e^{y/T}\Bigr).$$

This is generated by the exp–log primitive $\mathrm{eml}(x,y) = e^{x} - \log y$: exponentials are $\mathrm{eml}(\cdot,1)$ and logarithms are $1 - \mathrm{eml}(0,\cdot)$, so that
$$\mathrm{LSE}_T(b;\ell) = T\Bigl(1 - \mathrm{eml}\bigl(0,\ \mathrm{eml}(b/T,1) + \textstyle\sum_{y\in\ell}\mathrm{eml}(y/T,1)\bigr)\Bigr).$$
Thus the smooth aggregator is an EML expression in the strict sense, not merely an analogy.

**Theorem 3.2 (Lower dequantization bound).** For $T>0$, $\mathrm{tmax}(b;\ell) \le \mathrm{LSE}_T(b;\ell)$.

*Proof sketch.* Let $M = \mathrm{tmax}(b;\ell)$. The maximum is attained either by $b$ or by some element of $\ell$, so $e^{M/T}$ occurs among the summands; the remaining summands are positive. Hence $e^{M/T} \le e^{b/T} + \sum_{y\in\ell}e^{y/T}$. Apply $T\log(\cdot)$, which is increasing for $T>0$, and use $M = T\cdot(M/T)$. $\square$

**Theorem 3.3 (Upper dequantization bound with explicit error).** For $T>0$ and a list $\ell$ of length $r$,
$$\mathrm{LSE}_T(b;\ell) \;\le\; \mathrm{tmax}(b;\ell) + T\log(r+1).$$

*Proof sketch.* Every summand is at most $e^{M/T}$ with $M = \mathrm{tmax}(b;\ell)$, and there are $r+1$ of them, so the sum is at most $(r+1)e^{M/T}$. Apply $T\log(\cdot)$ and $\log(ab) = \log a + \log b$. $\square$

**Corollary 3.4 (Two-sided error).** $\bigl|\mathrm{LSE}_T(b;\ell) - \mathrm{tmax}(b;\ell)\bigr| \le T\log(r+1)$, and hence
$$\lim_{T\to 0^{+}} \mathrm{LSE}_T(b;\ell) = \mathrm{tmax}(b;\ell).$$

The convergence follows by squeezing between the constant $\mathrm{tmax}(b;\ell)$ and $\mathrm{tmax}(b;\ell)+T\log(r+1)$, both of which tend to $\mathrm{tmax}(b;\ell)$.

**Definition 3.5 (EML neuron).** $\;\mathcal{N}_T^{b,\ell}(x) = \mathrm{LSE}_T\bigl(b_1x+b_2;\ [t_1x+t_2 : t\in\ell]\bigr)$.

**Theorem 3.6 (Uniform approximation rate for a neuron).** For $T>0$ and every $x\in\mathbb{R}$,
$$\bigl|\mathcal{N}_T^{b,\ell}(x) - P_{b,\ell}(x)\bigr| \;\le\; T\log k, \qquad k = |\ell| + 1 .$$
Consequently $\mathcal{N}_T^{b,\ell} \to P_{b,\ell}$ pointwise as $T\to 0^{+}$, and the limit object is a tropical polynomial, hence tropical rational, hence exactly computable by a rectifier network (Section 4).

The bound is *uniform in $x$*: the error constant does not depend on the input, only on the number of tropical monomials, and only logarithmically. A layer of $k=1000$ units at $T=10^{-3}$ is within $6.9\times 10^{-3}$ of its tropical shadow everywhere on the line.

**Definition 3.7 (Large-weight scaling).** $\;\mathrm{LW}_s(b;\ell) = s^{-1}\log\bigl(e^{sb} + \sum_{y\in\ell}e^{sy}\bigr)$.

**Theorem 3.8 (Tropical limit in the large-weight regime).** For $s>0$, $\mathrm{LW}_s(b;\ell) = \mathrm{LSE}_{1/s}(b;\ell)$, and therefore
$$\lim_{s\to\infty}\mathrm{LW}_s(b;\ell) = \mathrm{tmax}(b;\ell),$$
with error at most $s^{-1}\log(r+1)$ for every $s>0$.

*Proof sketch.* The substitution $T = 1/s$ turns $y/T$ into $sy$ and $T\log(\cdot)$ into $s^{-1}\log(\cdot)$, identifying the two expressions; then squeeze between $\mathrm{tmax}(b;\ell)$ and $\mathrm{tmax}(b;\ell)+s^{-1}\log(r+1)$ along $s\to\infty$. $\square$

This is the regime relevant to learning: scaling all weights of an exp–log unit by a common large factor drives it to a max-plus unit at rate $O(1/s)$, with a constant that grows only logarithmically in the width.

---

## 4. The tropical/rectifier dictionary in one variable

### 4.1 The tropical product rule

**Lemma 4.1 (Pairwise-sum product rule).** For reals $b,b'$ and lists $\ell,\ell'$,
$$\mathrm{tmax}(b;\ell) + \mathrm{tmax}(b';\ell') \;=\; \mathrm{tmax}\bigl(b+b';\ \mathcal{S}\bigr),$$
where $\mathcal{S}$ is the list of all pairwise sums $u+v$ with $u \in \{b\}\cup\ell$, $v\in\{b'\}\cup\ell'$, excluding the base pair $b+b'$.

*Proof sketch.* Both sides are bounded above by each other. For $\le$: the two maxima are attained at some $u^\star, v^\star$, and $u^\star+v^\star$ is a member of the pairwise-sum family. For $\ge$: any pairwise sum $u+v$ satisfies $u \le \mathrm{tmax}(b;\ell)$ and $v\le \mathrm{tmax}(b';\ell')$. $\square$

In tropical language this is the statement that the tropical product of two tropical polynomials is a tropical polynomial whose monomials are the pairwise products (i.e. sums of exponent–coefficient data) of the factors. Combined with $c\max(u,v) = \max(cu,cv)$ for $c\ge0$, it gives:

**Proposition 4.2 (Closure of tropical polynomials).** Tropical polynomial functions are closed under pointwise addition (tropical multiplication), pointwise maximum (tropical addition), and multiplication by nonnegative scalars. They contain all affine functions and all constants.

### 4.2 Tropical rational functions form a lattice-ordered vector space

**Proposition 4.3.** The class of tropical rational functions is closed under: addition, negation, multiplication by arbitrary real scalars, pointwise $\max$, pointwise $\min$, and $f\mapsto \mathrm{relu}\circ f$.

*Proof sketch.* Write $f = P-Q$, $h = P'-Q'$ with all four factors tropical polynomials.
- **Addition:** $f + h = (P+P') - (Q+Q')$, and sums of tropical polynomials are tropical polynomials by Lemma 4.1.
- **Negation:** $-f = Q - P$.
- **Scalars:** for $c\ge 0$ use $cf = cP - cQ$ and Proposition 4.2; for $c<0$ use $cf = -((-c)f)$.
- **Maximum:** $\max(P-Q,\,P'-Q') = \max(P+Q',\,P'+Q) - (Q+Q')$; the first term is a max of tropical polynomials, hence tropical polynomial.
- **Minimum:** $\min(f,h) = -\max(-f,-h)$.
- **Rectifier:** $\mathrm{relu}(f) = \max(f, 0)$ and constants are tropical polynomials. $\square$

**Theorem 4.4 (Networks compute tropical rational functions).** Every rectifier expression evaluates to a tropical rational function.

*Proof sketch.* Structural induction on the expression, using Proposition 4.3 at each constructor: affine leaves are tropical rational; the three constructors correspond to addition, scalar multiplication, and the rectifier. $\square$

### 4.3 The converse construction

**Lemma 4.5 (Max as one rectifier).** $\max(u,v) = v + \mathrm{relu}(u-v)$ for all $u,v\in\mathbb{R}$.

*Proof.* If $u\le v$ both sides equal $v$; if $u\ge v$ both sides equal $u$. $\square$

**Construction 4.6.** Define a rectifier expression $E_{b,\ell}$ by recursion on $\ell$:
$$E_{b,[\,]} = \mathrm{affine}(b_1,b_2), \qquad E_{b,\,t::\ell} \;=\; E_{b,\ell} \;+\; \mathrm{act}\bigl(\mathrm{affine}(t_1,t_2) + (-1)\cdot E_{b,\ell}\bigr).$$

**Theorem 4.7.** $E_{b,\ell}(x) = P_{b,\ell}(x)$ for all $x$. Hence the tropical polynomial with $k$ monomials is computed by a rectifier expression with exactly $k-1$ rectifier units.

*Proof sketch.* Induction on $\ell$, applying Lemma 4.5 with $u = t_1x+t_2$ and $v = P_{b,\ell}(x)$ at each step. $\square$

**Theorem 4.8 (Every tropical rational function is a network).** If $f = P - Q$ with $P = P_{b,\ell}$, $Q = P_{b',\ell'}$, then the expression $E_{b,\ell} + (-1)\cdot E_{b',\ell'}$ computes $f$ exactly, with $|\ell| + |\ell'|$ rectifier units.

**Theorem 4.9 (Tropical/rectifier dictionary).** For $f:\mathbb{R}\to\mathbb{R}$:
$$f \text{ is tropical rational} \iff \exists\ \text{rectifier expression } e \text{ with } e(x)=f(x) \ \forall x.$$

*Proof.* $(\Rightarrow)$ Theorem 4.8. $(\Leftarrow)$ Theorem 4.4 plus the fact that tropical rationality is invariant under pointwise equality of functions. $\square$

The correspondence is exact and cost-preserving: **one rectifier per tropical monomial**. Depth in the network is traded for length of the monomial list, and the algebraic complexity of the tropical representation is the architectural size of the network.

### 4.4 Quantitative structure

**Proposition 4.10 (Slope-Lipschitz bound).** If all slopes of $P_{b,\ell}$ satisfy $|t_1| \le L$ (including the base), then $|P_{b,\ell}(x) - P_{b,\ell}(y)| \le L|x-y|$.

*Proof sketch.* Every affine piece $t_1x+t_2$ satisfies $t_1x + t_2 \le t_1y+t_2 + L|x-y| \le P_{b,\ell}(y) + L|x-y|$; take the maximum over pieces, then symmetrize in $x,y$. $\square$

**Proposition 4.11 (Convexity).** $P_{b,\ell}$ is convex on $\mathbb{R}$, being a pointwise maximum of affine functions.

These two facts identify the analytic invariants that will control training: the **largest absolute tropical slope** is the Lipschitz constant, hence the subgradient bound $G$; and convexity places the problem inside nonsmooth convex optimization, where the subgradient oracle of Definition 2.5 is the correct primitive.

---

## 5. Sharpness of the tropical $L^1$ risk

The tropical risk $R(x)=\sum_{i<N}|x-y_i|$ is the natural loss for a max-plus model: it is built from the same piecewise-linear vocabulary and it stays inside the tropical category.

**Proposition 5.1 (The loss is itself tropical).** $R$ is a tropical polynomial function of the parameter. Consequently $R$ is convex, piecewise linear with breakpoints at the $y_i$, and Lipschitz with constant $N$.

*Proof sketch.* $|x-y| = \max(x-y,\,y-x)$ is a tropical polynomial with two monomials, and tropical polynomials are closed under sums by Lemma 4.1; induct on $N$, with the empty sum equal to the constant $0$. Expanding, $R$ is a maximum of $2^N$ affine functions with slopes in $\{-N,-N+2,\dots,N\}$. $\square$

**Proposition 5.2 (Subgradient oracle and bound).** The sign sum $g(x) = \sum_{i<N}\mathrm{sgn}^{+}(x-y_i)$ is a subgradient oracle for $R$, and $|g(x)| \le N$ for all $x$.

*Proof sketch.* Termwise: if $y_i \le x$ then $|x-y_i| + (u-x) = u - y_i \le |u-y_i|$; if $y_i > x$ then $|x-y_i| - (u-x) = y_i - u \le |u-y_i|$. Sum over $i$. The bound is the triangle inequality with each term of modulus $1$. $\square$

**Lemma 5.3 (Betweenness).** If $v$ lies between $u$ and $w$ (in either order) then for all $x$,
$$|v-u| + |v-w| \;\le\; |x-u| + |x-w| .$$

*Proof sketch.* If $u \le v \le w$ then the left side is $w-u$, and the right side is at least $(x-u) + (w-x) = w-u$ by $\pm$-versions of $t\le|t|$. The other order is symmetric. $\square$

**Lemma 5.4 (Reflection identity).** For $N = 2m+1$,
$$2R(x) \;=\; \sum_{i=0}^{2m}\bigl(|x-y_i| + |x - y_{2m-i}|\bigr).$$

*Proof.* The index reflection $i \mapsto 2m-i$ is an involution of $\{0,\dots,2m\}$, so the second sum equals the first. $\square$

**Theorem 5.5 (Sharpness / error bound).** Let $N = 2m+1$ and suppose $y_0 \le y_1 \le \cdots \le y_{2m}$. Put $\theta^\star = y_m$ (the median). Then for every $x\in\mathbb{R}$,
$$R(\theta^\star) + |x - \theta^\star| \;\le\; R(x).$$
That is, $R$ is sharp at $\theta^\star$ with constant $\mu = 1$.

*Proof.* For each $i \in \{0,\dots,2m\}$ set
$$G_i \;=\; \bigl(|x-y_i| + |x-y_{2m-i}|\bigr) - \bigl(|y_m-y_i| + |y_m-y_{2m-i}|\bigr).$$
Monotonicity of the sample gives that $y_m$ lies between $y_i$ and $y_{2m-i}$: if $i\le m$ then $y_i \le y_m \le y_{2m-i}$, and if $i \ge m$ then $y_{2m-i}\le y_m \le y_i$. Lemma 5.3 therefore yields $G_i \ge 0$ for every $i$. The diagonal index $i=m$ gives $G_m = 2|x-y_m| - 0 = 2|x-\theta^\star|$. Since all terms are nonnegative, retaining only the diagonal one,
$$2|x-\theta^\star| \;=\; G_m \;\le\; \sum_{i=0}^{2m}G_i \;=\; 2R(x) - 2R(\theta^\star)$$
by Lemma 5.4 applied at $x$ and at $y_m$. Divide by $2$. $\square$

**Corollary 5.6 (Median optimality and uniqueness).** $R(\theta^\star)\le R(x)$ for all $x$, and any minimizer equals $\theta^\star$.

*Proof.* Optimality is Theorem 5.5 with $|x-\theta^\star|\ge0$ dropped. If $x$ is a minimizer, then $R(x)\le R(\theta^\star)$, so Theorem 5.5 forces $|x-\theta^\star|\le 0$, whence $x=\theta^\star$. $\square$

**Remark 5.7.** Sharpness is the piecewise-linear replacement for strong convexity. A $\mu$-strongly convex function obeys $f(x)\ge f^\star + \tfrac{\mu}{2}\|x-z\|^2$; the tropical loss obeys the *linear* lower bound $f(x) \ge f^\star + \mu\|x-z\|$, which is strictly stronger near the optimum. It is exactly this linear growth that a nonsmooth first-order method can exploit, and the reason a landscape with no curvature at all is nevertheless benign.

**Remark 5.8 (Sharpness is bounded by the slope).** For any $f$ with subgradient oracle $g$ bounded by $G$ and sharp with constant $\mu$ at $z$: evaluating sharpness at $x = z+1$ gives $f^\star + \mu \le f(z+1)$, while the affine minorant at $z+1$ evaluated at $z$ gives $f(z+1) \le f^\star + g(z+1) \le f^\star + G$. Hence $\mu \le G$, and the ratio $\mu/G \in (0,1]$ is a well-defined *tropical condition number*.

---

## 6. Fixed-step subgradient descent: the $O(1/\sqrt n)$ regime

**Theorem 6.1 (One-step energy inequality).** Let $g$ be a subgradient oracle for $f$ with $|g|\le G$, let $\eta\ge0$, and let $z,x\in\mathbb{R}$. Then
$$(x - \eta g(x) - z)^2 \;\le\; (x-z)^2 - 2\eta\bigl(f(x)-f(z)\bigr) + \eta^2G^2 .$$

*Proof sketch.* Expand the square: $(x-\eta g(x)-z)^2 = (x-z)^2 - 2\eta g(x)(x-z) + \eta^2 g(x)^2$. The affine-minorant property at $(x,z)$ gives $f(x)-f(z) \le g(x)(x-z)$, and $g(x)^2 \le G^2$. $\square$

**Theorem 6.2 (Telescoped bound).** With $\theta_k$ the fixed-step iterates from $\theta_0=x_0$,
$$2\eta\sum_{k=0}^{n-1}\bigl(f(\theta_k)-f(z)\bigr) + (\theta_n - z)^2 \;\le\; (x_0-z)^2 + n\eta^2G^2 .$$

*Proof sketch.* Induction on $n$, adding Theorem 6.1 at $x=\theta_n$ to the inductive hypothesis. $\square$

**Theorem 6.3 (Best-iterate bound).** For $\eta>0$ and $n\ge1$ there exists $k<n$ with
$$f(\theta_k) - f(z) \;\le\; \frac{(x_0-z)^2 + n\eta^2G^2}{2\eta n}.$$

*Proof sketch.* If every one of the $n$ gaps exceeded the right-hand side $B$, summing would give $nB < \sum_{k<n}(f(\theta_k)-f(z))$, contradicting Theorem 6.2 together with $(\theta_n-z)^2\ge0$ and $2\eta n B = (x_0-z)^2 + n\eta^2G^2$. $\square$

**Theorem 6.4 (Optimal fixed step).** Let $D = |x_0-z| > 0$, $G>0$, $n \ge 1$, and take $\eta = D/(G\sqrt n)$. Then some iterate $k<n$ satisfies
$$f(\theta_k) \;\le\; f(z) + \frac{DG}{\sqrt n}.$$

*Proof sketch.* Substituting $\eta$ into Theorem 6.3: the numerator becomes $D^2 + n\cdot \frac{D^2}{G^2n}\cdot G^2 = 2D^2$, and the denominator becomes $2Dn/(G\sqrt n) = 2D\sqrt n/G$. The quotient is $DG/\sqrt n$. $\square$

**Corollary 6.5 (Tropical instance).** For the tropical $L^1$ loss with $N$ samples, $G=N$ and the step $\eta = |x_0-z|/(N\sqrt n)$ gives an iterate before time $n$ with
$$R(\theta_k) \;\le\; R(z) + \frac{|x_0-z|\,N}{\sqrt n}$$
for *any* comparison parameter $z$.

**Theorem 6.6 (Parameter rate from sharpness).** For an ordered odd sample with median $\theta^\star$ and $\theta_0 \ne \theta^\star$, with $D = |\theta_0-\theta^\star|$ and step $\eta = D/(N\sqrt n)$, some $k<n$ satisfies simultaneously
$$R(\theta_k) \le R(\theta^\star) + \frac{DN}{\sqrt n} \qquad\text{and}\qquad |\theta_k - \theta^\star| \le \frac{DN}{\sqrt n}.$$

*Proof.* Take $z=\theta^\star$ in Corollary 6.5 and combine with Theorem 5.5, which converts a risk gap of $\varepsilon$ into a parameter error of at most $\varepsilon$. $\square$

The transfer in Theorem 6.6 is worth pausing on. For a general convex nonsmooth loss, small risk gap says nothing about proximity to the argmin: the landscape may have a long flat valley. Sharpness forbids valleys, and hence upgrades every risk guarantee into a parameter guarantee at no cost.

---

## 7. Polyak steps: geometric convergence

Section 6's $1/\sqrt n$ rate is optimal for *general* nonsmooth convex objectives, but tropical losses are not general. The Polyak rule converts sharpness into a linear rate.

**Theorem 7.1 (One-step contraction).** Let $g$ be a subgradient oracle for $f$ with $|g|\le G$, $G>0$, and suppose $f$ is sharp with constant $\mu>0$ at $z$, with $f^\star = f(z)$. Then for every $x$,
$$\bigl(\mathrm{PS}(x) - z\bigr)^2 \;\le\; \Bigl(1 - \frac{\mu^2}{G^2}\Bigr)(x-z)^2 .$$

*Proof.* By Remark 5.8, $\mu\le G$, so the factor $1-\mu^2/G^2$ lies in $[0,1)$.

*Degenerate case $g(x)=0$.* The minorant property gives $f(x) \le f(z) = f^\star$, while sharpness gives $f^\star + \mu|x-z|\le f(x)$. Hence $\mu|x-z|\le0$ and $x=z$; then $\mathrm{PS}(x) = x = z$ and both sides vanish.

*Main case $g(x)\neq0$.* Write $d = f(x)-f^\star \ge \mu|x-z| \ge 0$ and $t = d/g(x)^2 \ge 0$, so $\mathrm{PS}(x) = x - t\,g(x)$ and $t\,g(x)^2 = d$. Expanding,
$$\bigl(x - t g(x) - z\bigr)^2 = (x-z)^2 - 2t\,g(x)(x-z) + t^2g(x)^2 .$$
Convexity gives $d \le g(x)(x-z)$, and $t^2 g(x)^2 = t\,d$, so
$$\bigl(\mathrm{PS}(x)-z\bigr)^2 \;\le\; (x-z)^2 - 2td + td \;=\; (x-z)^2 - t\,d .$$
Finally, sharpness gives $d^2 \ge \mu^2(x-z)^2$ and $g(x)^2 \le G^2$, so
$$t\,d \;=\; \frac{d^2}{g(x)^2} \;\ge\; \frac{\mu^2(x-z)^2}{G^2}. \qquad\square$$

**Theorem 7.2 (Geometric convergence).** Under the hypotheses of Theorem 7.1, the Polyak iterates from $\theta_0$ satisfy
$$(\theta_n - z)^2 \;\le\; \Bigl(1-\frac{\mu^2}{G^2}\Bigr)^{n}(\theta_0 - z)^2 \qquad\text{for all } n\ge0 .$$

*Proof.* Induction on $n$, applying Theorem 7.1 at $\theta_n$ and multiplying the inductive hypothesis by the nonnegative factor $1-\mu^2/G^2$. $\square$

**Theorem 7.3 (Convergence).** $\theta_n \to z$ as $n\to\infty$.

*Proof sketch.* With $r = 1-\mu^2/G^2 \in [0,1)$, Theorem 7.2 gives $(\theta_n-z)^2 \le r^n(\theta_0-z)^2 \to 0$; a squeeze on $|\theta_n - z|$ finishes. $\square$

**Theorem 7.4 (Linear rate for tropical training).** Let $N = 2m+1$ with ordered residuals and median $\theta^\star = y_m$. Polyak-step subgradient descent on the tropical $L^1$ risk, initialized at $\theta_0$, satisfies for every $n$
$$(\theta_n - \theta^\star)^2 \;\le\; \Bigl(1 - \frac{1}{N^2}\Bigr)^{n}(\theta_0-\theta^\star)^2,$$
and $\theta_n \to \theta^\star$. Consequently the trained model converges pointwise, $M_{\theta_n}(z) \to M_{\theta^\star}(z)$ for every input $z$, to a tropical rational function that minimizes the tropical risk — and, by Theorem 4.9, to a function computed exactly by a rectifier network.

*Proof.* Apply Theorems 7.1–7.3 with $\mu = 1$ (Theorem 5.5) and $G = N$ (Proposition 5.2). Pointwise convergence of the model is continuity of $z + \cdot$. $\square$

**Comparison.** To reach parameter accuracy $\varepsilon$ from distance $D$:

| Method | Iterations needed |
|---|---|
| Fixed step $\eta = D/(N\sqrt n)$ | $n \gtrsim D^2N^2/\varepsilon^2$ |
| Polyak step | $n \gtrsim 2N^2\log(D/\varepsilon)$ |

The dependence on $\varepsilon$ collapses from polynomial to logarithmic. The dependence on the sample size is $N^2$ in both, reflecting that $G = N$ while $\mu = 1$: the tropical condition number is $\mu/G = 1/N$.

**Worked instance.** With samples $y = (0,1,2)$ so $N=3$, $\theta^\star = 1$, and $\theta_0 = 0$: the risk is $R(0)=3$, the optimum is $R(1)=2$, the subgradient at $0$ is $g(0) = 1 - 1 - 1 = -1$, so the Polyak step is $0 - \frac{3-2}{1}\cdot(-1) = 1$. One step lands exactly on the optimum. This is the extreme case of the geometric bound; the contraction factor $1-1/9$ is a worst-case guarantee, not a typical one.

---

## 8. The boundary: fixed steps can fail forever

The theory of Section 6 is a *best-iterate* theory with a shrinking step. It is natural to ask whether that caution is necessary. It is.

**Theorem 8.1 (Exact two-cycle).** Take samples $y = (0,1,2)$, so $N=3$ and the unique minimizer is $\theta^\star = 1$. Fixed-step subgradient descent with $\eta = 3$ initialized at $\theta_0 = 3$ produces
$$\theta_n \;=\; \begin{cases} 3, & n \text{ even},\\ -6, & n \text{ odd}.\end{cases}$$

*Proof sketch.* Induction. At $\theta=3$ all three samples satisfy $y_i \le 3$, so $g(3) = 3$ and the next iterate is $3 - 3\cdot3 = -6$. At $\theta=-6$ all three samples exceed $-6$, so $g(-6) = -3$ and the next iterate is $-6 + 9 = 3$. $\square$

**Corollary 8.2 (Permanent failure).** For every $n$, $|\theta_n - \theta^\star| \ge 2$.

Thus the literal statement "gradient descent on a tropical loss converges to a tropical rational minimizer" is **false** for a fixed step size. The mechanism is purely tropical: outside the convex hull of the data the subgradient is *constant* of magnitude $N$, so the iterate translates by the fixed amount $\eta N$ regardless of how far away it is. There is no restoring force proportional to the error — precisely the absence that curvature would have supplied. The correct statements are the best-iterate bound of Theorem 6.4 with a $1/\sqrt n$ step schedule, and the Polyak bound of Theorem 7.4, which is self-tuning and needs no step selection at all.

This also isolates what sharpness does and does not give. Sharpness bounds the loss *from below*; it says nothing about the step rule. A method that ignores the loss value (fixed step) cannot use sharpness, and it fails. A method that reads the loss value (Polyak) converts sharpness directly into contraction.

---

## 9. Comparison with rectifier networks

**Definition 9.1.** For a hypothesis $f:\mathbb{R}\to\mathbb{R}$ and data $(X_i,Y_i)_{i<N}$, the empirical risk is $\mathcal{R}_N(f;X,Y) = \sum_{i<N}|f(X_i)-Y_i|$.

**Theorem 9.2 (Risk-landscape equivalence).** For $f:\mathbb{R}\to\mathbb{R}$, the following are equivalent:
1. $f$ is tropical rational;
2. there is a rectifier expression $e$ with $\mathcal{R}_N(f;X,Y) = \mathcal{R}_N(e;X,Y)$ for every $N$ and all data $X,Y$.

*Proof.* $(1)\Rightarrow(2)$: Theorem 4.8 produces $e$ with $e = f$ pointwise; equal functions have equal risks. $(2)\Rightarrow(1)$: fix $x$ and apply the hypothesis to the one-point data set $N=1$, $X_0 = x$, $Y_0 = f(x)$. The left side is $|f(x)-f(x)| = 0$, so $|e(x)-f(x)| = 0$, i.e. $e(x)=f(x)$. As $x$ was arbitrary, $e=f$ pointwise, and $f$ is tropical rational by Theorem 4.4. $\square$

**Corollary 9.3.** The tropical hypothesis class and the rectifier hypothesis class have identical loss landscapes: the same minimizers, the same sharpness constants, the same Lipschitz constants, and hence exactly the same first-order convergence rates. Every rate in Sections 6–7 transfers verbatim.

**Corollary 9.4.** Each trained max-plus monomial $M_\theta(z) = z+\theta$ is computed exactly by a rectifier expression (indeed by an affine unit, with zero rectifiers), and every iterate along either trajectory therefore lies in both classes.

The interpretation is deflationary in a productive way. One might hope that the observed speed of training a rectifier network reflects something about the *architecture* — depth, over-parameterization, the shape of the rectifier. Theorem 9.2 says that, at the level of what a first-order method sees, the architecture contributes nothing that the tropical description does not already contain. The rate is determined by the pair $(\mu, G)$: the growth constant of the loss at the optimum and its largest slope. Both are read off from the tropical data — the sample geometry and the monomial slopes — and neither refers to the parameterization.

---

## 10. Algorithms

**Algorithm 1 (Tropical evaluation).** Evaluate $P_{b,\ell}(x)$ by a single fold: $\Theta(k)$ time, $\Theta(1)$ space, $k=|\ell|+1$.

**Algorithm 2 (Tropical-to-rectifier compilation).** Convert $P_{b,\ell}$ into a rectifier expression by the recursion of Construction 4.6: $\Theta(k)$ nodes, $k-1$ rectifiers, depth $\Theta(k)$ (or $\Theta(\log k)$ with a balanced pairwise variant using $\max(u,v)=v+\mathrm{relu}(u-v)$ on a binary tree).

**Algorithm 3 (Tropical product).** Given two tropical polynomials with $k$ and $k'$ monomials, form the pointwise-sum polynomial with $kk'$ monomials by Lemma 4.1: $\Theta(kk')$ time. Redundant monomials (those never attaining the maximum) can be pruned by an upper-hull sweep in $\Theta(kk'\log(kk'))$.

**Algorithm 4 (Polyak-step tropical training).** Given samples $y$, an initial $\theta_0$, and the optimal value $R^\star$: repeat $\theta \leftarrow \theta - \frac{R(\theta)-R^\star}{g(\theta)^2}g(\theta)$ until $g(\theta)=0$. Each iteration costs $\Theta(N)$; by Theorem 7.4 the number of iterations to accuracy $\varepsilon$ is $O(N^2\log(D/\varepsilon))$, for total $O(N^3\log(D/\varepsilon))$. (For the one-dimensional median problem, sorting solves the problem exactly in $\Theta(N\log N)$; the iterative method is of interest as the analysable prototype of the multivariate case, where no closed form exists.)

**Algorithm 5 (Dequantization schedule).** To train a smooth EML unit and land in the tropical regime: run at temperature $T_j$ with $T_j\downarrow 0$; Theorem 3.6 guarantees the objective at temperature $T_j$ is within $NT_j\log k$ of the tropical objective uniformly, so a schedule $T_j = \varepsilon/(2N\log k)$ makes the smooth surrogate's optimum $\varepsilon$-optimal for the tropical problem.

---

## 11. Discussion

### 11.1 Slope and sharpness replace smoothness and strong convexity

Every rate proved here is controlled by exactly two numbers:

- $G$, the **maximal tropical slope**, which is simultaneously the Lipschitz constant of the loss (Proposition 4.10) and the subgradient bound (Proposition 5.2);
- $\mu$, the **sharpness constant**, the linear growth rate of the loss away from the optimum (Theorem 5.5).

Their ratio $\mu/G \in (0,1]$ (Remark 5.8) plays the role that the inverse condition number $m/L$ plays for smooth strongly convex problems. The formal analogy is exact: smooth strongly convex gradient descent contracts by $1 - m/L$ per step; sharp Lipschitz Polyak descent contracts squared distance by $1-\mu^2/G^2$. In the tropical setting these constants are *combinatorial*: $G$ is the largest slope appearing among the tropical monomials, and $\mu$ is determined by which monomials are active at the optimum. No analytic estimate enters.

### 11.2 Why the loss stays tropical

A pleasing structural feature is closure: the model is tropical, the loss is tropical (Proposition 5.1), and every level set and subdifferential is polyhedral. Optimization never leaves the tropical category. This is not automatic — a squared-error loss on a tropical model is piecewise *quadratic*, and while that is smoother, it destroys the exact combinatorial description and, with it, the sharpness constant. The $L^1$ loss is the tropically natural choice, and it is also the one for which the theory is strongest.

### 11.3 Dequantization as a physical limit

The bound $\max \le \mathrm{LSE}_T \le \max + T\log k$ is the learning-theoretic form of the zero-temperature limit in statistical mechanics: $\mathrm{LSE}_T$ is $-T$ times a free energy, its $T\to0$ limit is a ground-state energy, and the $T\log k$ error is an entropy term bounded by the logarithm of the number of states. That the error is uniform in the input, and only logarithmic in the width, is what makes the tropical model a legitimate proxy rather than a caricature: a wide network at moderate weight scale is already extremely close to its combinatorial shadow.

### 11.4 Limits of the present analysis

The results are one-dimensional in the parameter and in the input. Two obstructions arise in higher dimension. First, the sharpness proof uses the reflection pairing $i\mapsto 2m-i$ and the betweenness lemma, both of which are one-dimensional; in $\mathbb{R}^d$ the $L^1$ minimizer is a coordinatewise median only when the loss separates across coordinates. Second, the identification of $G$ with the largest slope generalizes (as the largest dual norm of a monomial's gradient), but the identification of $\mu$ requires knowing which normal cone of the tropical hypersurface contains the optimum. The product rule of Lemma 4.1 generalizes verbatim to $\mathbb{R}^d$, so the algebra is not the difficulty; the geometry of the optimum is.

---

## 12. Future directions

**Conjecture 1 (A tropical condition number governs all first-order rates).** For a tropical rational loss $L$ on $\mathbb{R}^d$, with $G$ its maximal tropical slope and $\mu$ its sharpness constant at the minimizer, Polyak-step subgradient descent contracts the squared distance by exactly $1-\mu^2/G^2$ per step, and no first-order method beats $(1-\mu^2/G^2)^{n/2}$ on the worst instance with these invariants. The key point is that $\mu/G$ is a purely combinatorial quantity — the ratio between the smallest and largest slopes of the tropical normal fan at the optimum — so the optimization rate is computed from the geometry of a Newton polytope rather than from any analytic estimate. The one-variable case is settled here ($\mu=1$, $G=N$, contraction $1-1/N^2$), and the multivariate normal-fan machinery required for the matching lower bound is elementary polyhedral combinatorics.

**Conjecture 2 (Dequantization commutes with training).** Let $\theta_T(n)$ be the $n$-th gradient-descent iterate of the smooth EML network at temperature $T$, and $\theta_0(n)$ the $n$-th subgradient iterate of its tropical limit. Then $|\theta_T(n) - \theta_0(n)| \le C\,n\,T\log k$, and consequently the two training trajectories have the same limit set as $T\to0^{+}$. The reason to expect this is that the dequantization defect is uniformly $T\log k$ *per unit* (Theorem 3.6), so it can accumulate at most linearly along a trajectory of $1$-Lipschitz update maps; the missing ingredient is a discrete Grönwall argument for nonexpansive piecewise-linear update maps.

**Further problems.** (i) Multivariate tropical rational calculus: the pairwise-sum product rule generalizes, but a substitute for the median/betweenness argument is needed. (ii) Pruning: characterize which tropical monomials are *inessential* (never attain the maximum), giving a canonical minimal rectifier realization and a notion of tropical model compression with an exact, not approximate, guarantee. (iii) Stochastic and mini-batch Polyak steps for tropical losses, where $R^\star$ is unknown and must be estimated online. (iv) Generalization: sharpness at the empirical optimum plus a uniform bound on tropical slopes should yield fast (non-$\sqrt n$) excess-risk rates, since sharp empirical risk pins down the parameter, not merely the loss value. (v) Depth: the compilation of Construction 4.6 has depth linear in the number of monomials; quantifying the depth/monomial trade-off would give a tropical account of the expressivity benefits of depth.

---

## 13. Conclusion

Freezing an exp–log network — sending its weight scale to infinity, or its temperature to zero — costs at most $T\log k$ uniformly and turns it into a max-plus object. In one variable that object is exactly a rectifier network, monomial for monomial. Its absolute-error training landscape is a convex piecewise-linear function that is sharp with an explicit constant, and sharpness, not smoothness, is what determines how fast first-order methods run. With a fixed step the method may cycle forever; with a $1/\sqrt n$ schedule it achieves the optimal general rate; with the self-tuning Polyak step it converges geometrically at rate $1-\mu^2/G^2$, which for the tropical median problem is $1-1/N^2$. Since a rectifier network with the same function has an identical risk landscape, the speed is a property of the tropical geometry of the loss and not of the parameterization. Two combinatorial invariants — the largest slope and the growth constant — determine everything.
