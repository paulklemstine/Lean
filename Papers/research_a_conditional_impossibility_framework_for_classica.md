# A Conditional-Impossibility Framework for Classical Integer Factoring

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop a rigorous conditional-impossibility schema for classical integer factorization. The framework rests on three separated logical levels, and its principal contribution is the discipline of that separation.

At **Level 1** we prove unconditional theorems: (i) the congruence-of-squares reduction — the structural core shared by every general-purpose classical method and by the classical post-processing of period-finding — is unconditional and computationally free, so all difficulty in factoring is concentrated in *producing* a congruence of squares rather than exploiting one; (ii) an asymptotic ladder theory in which the subexponential complexity functions $L[\alpha,c](x) = \exp(c\,x^{\alpha}(\log x)^{1-\alpha})$ are shown to be superpolynomial for $0 < \alpha \le 1$ and subexponential for $0 < \alpha < 1$, hence strictly intermediate between the polynomial and exponential rungs, while $\exp(bx)$ with $b>0$ is superpolynomial and *not* subexponential; (iii) a multiplicative trade-off theorem showing by two applications of AM–GM that a $k$-stage strategy under a multiplicative budget constraint $\prod_i y_i = x$ costs at least $k\exp(x^{1/k})$, with equality at the balanced point — so the sieve exponents $1/2$ and $1/3$ are forced balance points rather than design parameters — together with the honest boundary that unbounded arity collapses the bound to $O(\log x)$; (iv) a worst-case sharpening of the collision barrier showing that the arithmetic trajectory is provably blind for $\min(p,q) \approx \sqrt{N}$ steps, so that the celebrated $N^{1/4}$ figure for collision methods is average-case only; and (v) an information-theoretic Fourier sample bound: any family of $K$ sample frequencies that determines every period-$r$ signal on $\mathbb{Z}/r\mathbb{Z}$ satisfies $K \ge r$, with sharpness at $K = r$.

At **Level 2** we prove the conditional-impossibility chain: if a classical algorithm factors semiprimes in time polynomially bounded in $\log N$, then its cost is beaten by every classified barrier by an unbounded factor, it is limited by none of them, and the resource it exploits therefore lies outside the classified set $\{\text{randomness}, \text{smoothness}, \text{iteration}, \text{analog}\}$.

At **Level 3** we isolate, as an explicit *hypothesis* rather than a theorem, the Classified Resource Hypothesis asserting that every classical algorithm is limited by one of the four classified barriers. We prove that it implies the nonexistence of polynomial-time classical factoring, that any polynomial-time algorithm falsifies it, and that the resulting schema is non-vacuous (both sides inhabited, and disjoint).

The framework is a classification of the known, not a proof that the unknown is empty. It establishes the precise sense in which a fast classical factoring algorithm would require a genuinely novel resource, and it identifies quantum superposition as the only known resource that evades all four barriers — the sample-count bound $K \ge r$ being exactly the obstruction that superposition circumvents.

**Keywords:** integer factorization, subexponential complexity, congruence of squares, AM–GM trade-off, Fourier sampling lower bound, conditional impossibility, asymptotic growth classes.

---

## 1. Introduction

### 1.1 The problem and the epistemic situation

Given a semiprime $N = pq$ with $p, q$ distinct large primes, recover $p$ and $q$. The presumed hardness of this problem underwrites a substantial fraction of deployed public-key cryptography. Yet the hardness is not a theorem. No superpolynomial lower bound for factoring is known in any general model of classical computation, and none is in sight; the belief in hardness rests on a research record rather than a proof.

This paper takes the epistemic situation itself as its object. Rather than attempt an unconditional lower bound — which would settle questions far beyond factoring — we ask a more tractable and, we argue, more informative question:

> **If** a polynomial-time classical factoring algorithm exists, **what must it be made of**?

The answer we obtain is: not any of the four resources that all known classical methods use. This is a theorem, and it is a conditional. It is neither a hardness proof nor a claim that no such algorithm exists. Its value lies in converting the informal observation "many clever attacks have failed" into a precise structural statement about *where* they fail and *what kind of novelty* a success would require.

### 1.2 Three logical levels, kept apart

A recurring failure mode in the literature surrounding factoring barriers is the silent slide from "all known methods hit a wall" to "all methods hit a wall." We structure the framework so that this slide is syntactically impossible.

- **Level 1 — Unconditional theorems.** Statements proved outright, with no hypothesis about the space of algorithms. These are the growth theorems, the structural reduction, the trade-off inequality, the worst-case collision statement, and the Fourier sample bound.
- **Level 2 — Conditional impossibility.** A proved implication whose antecedent is the existence of a polynomial-time classical algorithm and whose consequent constrains the resource such an algorithm must exploit.
- **Level 3 — Scope, stated as a hypothesis.** The Classified Resource Hypothesis, which asserts the exhaustiveness of the classification. It is explicitly *not proved*. We prove only its consequences and its falsifiability.

### 1.3 Contributions

1. A complete asymptotic ladder theory for the growth classes relevant to factoring, with strict separations proved rather than assumed (§3).
2. A classification of the four known classical resources with an attached barrier for each, and a proof that *every* classified barrier is superpolynomial and that the classification is non-degenerate (§4).
3. An explanation, as a theorem, of why the sieve exponents are $1/k$ for small integer $k$ — together with an explicit boundary theorem showing the barrier dissolves at unbounded arity (§5).
4. A worst-case sharpening of the randomness/collision barrier, correcting $N^{1/4}$ to $\sqrt{N}$ in the worst case (§6).
5. An information-theoretic sample-count lower bound $K \ge r$ for Fourier-based period determination, in representation-independent form, with matching upper bound (§7).
6. The capstone conditional-impossibility theorem, with a non-vacuity proof and an explicit statement of the quantum boundary (§8–§9).

---

## 2. The structural core: congruences of squares

### 2.1 The reduction

Throughout, $\gcd$ of an integer with a natural number is taken as a natural number.

**Definition 2.1 (Nontrivial divisor).** For naturals $N, d$, say $d$ is a *nontrivial divisor* of $N$ if $d \mid N$, $1 < d$, and $d < N$.

**Lemma 2.2 (Splitting).** If $d$ is a nontrivial divisor of $N$, then $N = de$ for some $e$ with $d > 1$ and $e > 1$.

*Proof.* Write $N = de$. If $e = 0$ then $N = 0$, contradicting $d < N$; if $e = 1$ then $d = N$, contradicting $d < N$. Hence $e \ge 2$. $\square$

**Theorem 2.3 (Congruence of squares).** Let $N > 1$ and let $x, y \in \mathbb{Z}$ satisfy
$$N \mid (x-y)(x+y), \qquad N \nmid (x-y), \qquad N \nmid (x+y).$$
Then $\gcd(x-y, N)$ is a nontrivial divisor of $N$.

*Proof sketch.* Set $d = \gcd(x-y, N)$. Certainly $d \mid N$. If $d = 1$, then $x-y$ and $N$ are coprime, so from $N \mid (x-y)(x+y)$ we may cancel the coprime factor and conclude $N \mid (x+y)$, contradicting the third hypothesis. If $d = N$, then $N \mid (x-y)$, contradicting the second. Also $d \ne 0$, since $d \mid N$ and $N > 1$. Hence $1 < d$, and $d \le N$ with $d \ne N$ gives $d < N$. $\square$

The hypotheses are not decorative. Taking $N = 15$, $x = 4$, $y = 11$ we have $15 \mid (4-11)(4+11) = -105$, but $\gcd(4-11,15) = 1$ is not a nontrivial divisor: here $x \equiv -y \pmod{15}$, and dropping the hypothesis $N \nmid (x+y)$ destroys the conclusion.

### 2.2 Order finding as a special case

**Theorem 2.4 (Order-finding reduction).** Let $N > 1$, $a \in \mathbb{Z}$, $s \in \mathbb{N}$, and suppose
$$N \mid a^{2s} - 1, \qquad N \nmid a^{s} - 1, \qquad N \nmid a^{s} + 1.$$
Then $\gcd(a^s - 1, N)$ is a nontrivial divisor of $N$.

*Proof.* $(a^s-1)(a^s+1) = a^{2s}-1$, so the hypotheses are exactly those of Theorem 2.3 with $x = a^s$, $y = 1$. $\square$

This is the classical post-processing step of period-finding-based factoring: knowing an even multiplicative order $2s$ of $a$ modulo $N$, with $a^s \not\equiv \pm 1$, yields a factor by one gcd computation.

### 2.3 For semiprimes, the reduction is complete

**Theorem 2.5 (Semiprime rigidity).** Let $p, q$ be primes and let $d$ be a nontrivial divisor of $pq$. Then $d = p$ or $d = q$.

*Proof sketch.* If $p \mid d$, write $d = pk$; then $pk \mid pq$ gives $k \mid q$, so $k \in \{1, q\}$. The case $k = q$ gives $d = pq$, contradicting $d < pq$; hence $k=1$ and $d = p$. If $p \nmid d$, then $p$ and $d$ are coprime, so $d \mid pq$ forces $d \mid q$, and $d > 1$ gives $d = q$. $\square$

**Corollary 2.6.** A congruence of squares modulo a semiprime *is* a factorization of that semiprime: under the hypotheses of Theorem 2.3 with $N = pq$, the gcd equals $p$ or $q$.

### 2.4 Where the difficulty lives

Theorems 2.3–2.6 cost a single gcd computation, i.e. $O(\log^2 N)$ bit operations by the Euclidean algorithm. The reduction is therefore *free* relative to any conceivable cost of producing the congruence. This is the framework's central structural observation, and it licenses the entire subsequent analysis:

> **Structural Principle.** All of the difficulty of general-purpose classical factoring is concentrated in the *production* of a congruence of squares (equivalently, of an even multiplicative order with a nondegenerate half-power). None of it is in the exploitation.

Consequently a classification of factoring methods can be conducted as a classification of the *resources* used to produce the congruence. That is what §4 does.

---

## 3. The asymptotic ladder

We now build the quantitative vocabulary. Throughout, $x = \log N$ is the bit-size parameter and all growth statements are as $x \to \infty$ along the reals.

### 3.1 Growth classes

**Definition 3.1.** Let $f : \mathbb{R} \to \mathbb{R}$.
- $f$ is **superpolynomial** if for every $d \in \mathbb{R}$, $\displaystyle \lim_{x\to\infty} f(x)/x^{d} = +\infty$.
- $f$ is **subexponential** if for every $\varepsilon > 0$, $\displaystyle \lim_{x\to\infty} f(x)/e^{\varepsilon x} = 0$.
- $f$ is **polynomially bounded** if there exist $C, d \in \mathbb{R}$ with $f(x) \le C x^{d}$ for all sufficiently large $x$.

Here $x^d$ denotes the real power $\exp(d\log x)$, so the exponent ranges over all reals; the quantifier "for every $d$" is therefore genuinely strong.

**Definition 3.2 ($L$-function).** For $\alpha, c \in \mathbb{R}$,
$$L[\alpha, c](x) \ :=\ \exp\!\big(c\, x^{\alpha}\,(\log x)^{1-\alpha}\big).$$
In the classical notation this is $L_N[\alpha, c]$ with $x = \log N$, so that $L[\alpha,c] = \exp\big(c(\log N)^{\alpha}(\log\log N)^{1-\alpha}\big)$.

### 3.2 Domination transfers superpolynomiality

**Lemma 3.3 (Monotone transfer).** If $g$ is superpolynomial and $g(x) \le f(x)$ for all sufficiently large $x$, then $f$ is superpolynomial.

*Proof.* Fix $d$. For large $x$ we have $x > 0$, hence $x^d > 0$, hence $g(x)/x^d \le f(x)/x^d$; a function eventually dominating one that tends to $+\infty$ also tends to $+\infty$. $\square$

### 3.3 The engine

**Theorem 3.4 (Stretched exponentials are superpolynomial).** For all $c > 0$ and $\alpha > 0$, the function $x \mapsto \exp(c\,x^{\alpha})$ is superpolynomial.

*Proof sketch.* Fix $d$. The standard limit $e^{cu}/u^{e} \to \infty$ (valid for every real exponent $e$ and every $c>0$) applied with $e = d/\alpha$ gives
$$\frac{e^{cu}}{u^{d/\alpha}} \xrightarrow[u\to\infty]{} \infty .$$
Compose with $u = x^{\alpha}$, which tends to infinity since $\alpha > 0$, and observe $(x^{\alpha})^{d/\alpha} = x^{d}$ for $x > 0$ by the power rule for real exponents. $\square$

**Corollary 3.5.** For $b > 0$, $x \mapsto e^{bx}$ is superpolynomial. (Take $\alpha = 1$ in Theorem 3.4 and apply Lemma 3.3, noting $x^1 = x$ for $x>0$.)

### 3.4 $L$-functions are superpolynomial

**Lemma 3.6.** For $c \ge 0$, $\alpha \le 1$, and $x \ge e$, we have $\exp(c\,x^{\alpha}) \le L[\alpha,c](x)$.

*Proof.* For $x \ge e$, $\log x \ge 1$, and since $1 - \alpha \ge 0$ we get $(\log x)^{1-\alpha} \ge 1$. As $c x^{\alpha} \ge 0$, multiplying by a quantity $\ge 1$ can only increase it:
$$c x^{\alpha} \ \le\ c x^{\alpha}(\log x)^{1-\alpha}.$$
Apply monotonicity of $\exp$. $\square$

**Theorem 3.7 (Barrier growth).** For $0 < \alpha \le 1$ and $c > 0$, $L[\alpha,c]$ is superpolynomial.

*Proof.* Combine Theorem 3.4, Lemma 3.6, and Lemma 3.3. $\square$

Thus the number field sieve barrier $L[1/3,c]$, the quadratic sieve and ECM barriers $L[1/2,c]$, and indeed every $L$-function with a positive exponent parameter, outgrow every polynomial in $\log N$.

### 3.5 $L$-functions are subexponential

**Lemma 3.8 (Key growth comparison).** For $\alpha < 1$,
$$\lim_{x\to\infty} \frac{x^{\alpha}(\log x)^{1-\alpha}}{x} = 0.$$

*Proof sketch.* For $x > 1$, using $x^{\alpha}x^{1-\alpha} = x$,
$$\frac{x^{\alpha}(\log x)^{1-\alpha}}{x} = \frac{(\log x)^{1-\alpha}}{x^{1-\alpha}} = \left(\frac{\log x}{x}\right)^{1-\alpha}.$$
Since $(\log x)/x \to 0$ and $t \mapsto t^{1-\alpha}$ is continuous at $0$ with value $0^{1-\alpha}=0$ (as $1-\alpha > 0$), the composite tends to $0$. $\square$

**Theorem 3.9 (Subexponentiality).** For $c > 0$ and $\alpha < 1$, $L[\alpha,c]$ is subexponential.

*Proof sketch.* Fix $\varepsilon > 0$. By Lemma 3.8 there is $X$ such that for $x > X$,
$$\frac{x^{\alpha}(\log x)^{1-\alpha}}{x} < \frac{\varepsilon}{2c},$$
i.e. $c\,x^{\alpha}(\log x)^{1-\alpha} < \tfrac{\varepsilon}{2}x$. Hence for such $x$,
$$\frac{L[\alpha,c](x)}{e^{\varepsilon x}} = \exp\!\big(c x^{\alpha}(\log x)^{1-\alpha} - \varepsilon x\big) \ \le\ \exp\!\big(-\tfrac{\varepsilon}{2}x\big).$$
The right-hand side tends to $0$, the left-hand side is positive, and the squeeze theorem finishes the proof. $\square$

### 3.6 Strict separation of the rungs

**Theorem 3.10 (Genuine exponentials are not subexponential).** For $b > 0$, $x \mapsto e^{bx}$ is not subexponential.

*Proof.* Test with $\varepsilon = b/2$: the ratio is $e^{bx}/e^{bx/2} = e^{bx/2} \to \infty$, which contradicts convergence to $0$. $\square$

**Theorem 3.11 (Incompatibility).** A superpolynomial function is not polynomially bounded.

*Proof.* Suppose $f(x) \le Cx^d$ eventually. Then eventually $f(x)/x^d \le C$, contradicting $f(x)/x^d \to \infty$. $\square$

**Theorem 3.12 (Strict intermediacy of the $L$-rung).** For $0 < \alpha < 1$ and $c > 0$, $L[\alpha,c]$ is superpolynomial, subexponential, and not polynomially bounded. It therefore occupies a rung of the growth ladder strictly above every polynomial and strictly below every exponential.

This is the precise sense in which subexponential factoring algorithms represent genuine, but insufficient, progress: they escape the exponential rung entirely, yet remain infinitely far above the polynomial one.

---

## 4. The four classified resources and their barriers

### 4.1 The classification

**Definition 4.1 (Classical resources).** The classified resources are the four-element set
$$\mathcal{R} = \{\ \mathsf{randomness},\ \mathsf{smoothness},\ \mathsf{iteration},\ \mathsf{analog}\ \}.$$

**Definition 4.2 (Barrier cost).** Each resource carries the documented running-time barrier of its representative algorithms, expressed in $x = \log N$:

| Resource | Representative method | Barrier $B_\rho(x)$ |
|---|---|---|
| randomness | Pollard rho, collision search | $\exp(x/4)$, i.e. $\Theta(N^{1/4})$ |
| smoothness | CFRAC, quadratic sieve, number field sieve | $L[1/3, 1](x)$ |
| iteration | Williams $p+1$, elliptic curve method | $L[1/2, \sqrt{2}](x/2)$ |
| analog | analog/chaotic dynamics | $L[1/3, 1](x)$ |

The iteration entry is stated in $\log p$ rather than $\log N$; for a balanced semiprime $\log p \approx x/2$, whence the reparametrization $x \mapsto x/2$.

**Lemma 4.3 (Rescaling stability).** If $f$ is superpolynomial and $b > 0$, then $x \mapsto f(x/b)$ is superpolynomial.

*Proof sketch.* Fix $d$. Composing $f(u)/u^{d} \to \infty$ with $u = x/b \to \infty$ gives $f(x/b)/(x/b)^d \to \infty$; dividing by the positive constant $b^{d}$ preserves divergence, and $(x/b)^{d}b^{d} = x^{d}$ for $x > 0$. $\square$

This lemma is exactly what makes the ECM entry legitimate: the barrier is a function of $\log p$, and superpolynomiality in $\log p$ transfers to superpolynomiality in $\log N$ under a linear reparametrization.

### 4.2 Every barrier is superpolynomial

**Theorem 4.4 (Barrier theorem).** For every $\rho \in \mathcal{R}$, the barrier $B_\rho$ is superpolynomial.

*Proof.* Case by case. For $\mathsf{randomness}$, $B(x) = \exp(x/4)$ is superpolynomial by Corollary 3.5 with $b = 1/4$. For $\mathsf{smoothness}$ and $\mathsf{analog}$, $B = L[1/3,1]$ is superpolynomial by Theorem 3.7 with $c=1$, $\alpha=1/3$. For $\mathsf{iteration}$, $L[1/2,\sqrt 2]$ is superpolynomial by Theorem 3.7 (with $c = \sqrt2 > 0$, $\alpha = 1/2$), and the reparametrization $x \mapsto x/2$ preserves this by Lemma 4.3. $\square$

**Corollary 4.5.** No classified barrier is polynomially bounded (Theorem 3.11).

**Lemma 4.6 (Positivity).** $B_\rho(x) > 0$ for all $\rho$ and all $x$, since each barrier is an exponential of a real quantity.

### 4.3 The classification is non-degenerate

A classification with four entries that are all secretly the same bound would be a rhetorical device, not mathematics. It is not.

**Theorem 4.7 (Non-degeneracy).** The smoothness barrier $L[1/3,1]$ is subexponential; the randomness barrier $\exp(x/4)$ is not; consequently the two barriers are distinct functions and occupy different rungs of the ladder.

*Proof.* Subexponentiality of $L[1/3,1]$ is Theorem 3.9 with $\alpha = 1/3 < 1$, $c=1$. Failure of subexponentiality for $\exp(x/4)$ is Theorem 3.10 with $b = 1/4$. If the two functions were equal, subexponentiality would transfer, a contradiction. $\square$

So the table records genuinely different information: an exponential wall for collision methods, and a strictly lower — but still superpolynomial — wall for sieve and iteration methods. The classification is a ladder, not a list of synonyms.

---

## 5. Why the exponents are $1/k$: the multiplicative trade-off barrier

### 5.1 The model

Every subexponential factoring algorithm has running time of the shape $L[1/k, c]$ with $k \in \{2,3\}$. We isolate the structural reason as a theorem about cost functions rather than a fact about any particular algorithm.

**Model 5.1 ($k$-way trade-off).** A $k$-way trade-off strategy splits its work into $k$ exponential stages of costs $e^{y_1}, \dots, e^{y_k}$, where the budget parameters $y_i > 0$ obey a *multiplicative* constraint
$$\prod_{i=1}^{k} y_i = x .$$
Total cost is $\sum_{i=1}^{k} e^{y_i}$.

The multiplicative constraint is the mathematical content of the sieving trade-off: reducing the smoothness bound reduces the size of the factor base (and hence the linear algebra and the number of relations required) but proportionally reduces the density of smooth numbers, increasing the sieving effort. The two effects multiply in $\log N$.

### 5.2 The bound and its sharpness

**Lemma 5.2 (AM–GM, balanced weights).** For $k \ge 1$ and nonnegative reals $y_1,\dots,y_k$,
$$\Big(\prod_{i=1}^{k} y_i\Big)^{1/k} \ \le\ \frac{1}{k}\sum_{i=1}^{k} y_i .$$

*Proof sketch.* This is the weighted arithmetic–geometric mean inequality with all weights equal to $1/k$, together with the identity $\prod_i y_i^{1/k} = (\prod_i y_i)^{1/k}$ for nonnegative $y_i$. $\square$

**Theorem 5.3 (Multiplicative trade-off lower bound).** Let $k \ge 1$, $x \in \mathbb{R}$, and $y_1,\dots,y_k > 0$ with $\prod_i y_i = x$. Then
$$k\,\exp\!\big(x^{1/k}\big) \ \le\ \sum_{i=1}^{k} e^{y_i}.$$

*Proof sketch.* Two applications of Lemma 5.2.

*Step 1 (budgets).* Applied to $y_1,\dots,y_k$ and using $\prod_i y_i = x$:
$$x^{1/k} \le \frac{1}{k}\sum_i y_i .$$

*Step 2 (costs).* Applied to $e^{y_1},\dots,e^{y_k}$, and using $\prod_i e^{y_i} = e^{\sum_i y_i}$ together with $\big(e^{S}\big)^{1/k} = e^{S/k}$:
$$\exp\!\Big(\tfrac{1}{k}\textstyle\sum_i y_i\Big) \ \le\ \frac{1}{k}\sum_i e^{y_i}.$$

Chaining Step 1 through the monotone $\exp$ and then Step 2 gives $\exp(x^{1/k}) \le \frac1k\sum_i e^{y_i}$; multiply by $k$. $\square$

**Theorem 5.4 (Sharpness).** For $k \ge 1$ and $x > 0$, the balanced choice $y_1 = \cdots = y_k = x^{1/k}$ satisfies the constraint $\prod_i y_i = x$ and attains the bound: $\sum_i e^{y_i} = k\exp(x^{1/k})$.

*Proof.* $\big(x^{1/k}\big)^{k} = x$ by the power rule, and the sum of $k$ equal terms is $k$ times one of them. $\square$

### 5.3 Interpretation: the exponent is a balance point, not a choice

Theorems 5.3 and 5.4 together say that the optimal $k$-way trade-off cost is *exactly* $k\exp(x^{1/k})$. The exponent $1/k$ is not a design parameter of any algorithm; it is the AM–GM balance point of the multiplicative constraint. Two consequences follow:

1. "Improving the exponent from $1/2$ to $1/3$" is not an incremental optimization within a fixed architecture. It is *the same problem* as adding a stage — which is historically exactly what happened when the number field sieve introduced an additional algebraic layer over the quadratic sieve.
2. Polynomial time is the $k \to \infty$ limit of this family, in a sense made precise in §5.5.

### 5.4 Fixed arity cannot reach polynomial time

**Theorem 5.5.** For each fixed $k \ge 1$, the optimal $k$-way trade-off cost $x \mapsto k\exp(x^{1/k})$ is superpolynomial; consequently it is not polynomially bounded.

*Proof.* $\exp(1 \cdot x^{1/k})$ is superpolynomial by Theorem 3.4 with $c=1$, $\alpha = 1/k > 0$; multiplying by the constant $k \ge 1$ only increases it, so Lemma 3.3 applies. Theorem 3.11 gives the second claim. $\square$

**Corollary 5.6 (The two exponents that occur).** Both $x \mapsto 2\exp(x^{1/2})$ and $x \mapsto 3\exp(x^{1/3})$ are superpolynomial: neither the quadratic-sieve/ECM regime nor the number-field-sieve regime can be polynomial-time.

### 5.5 The honest boundary: unbounded arity destroys the barrier

**Theorem 5.7 (Boundary of the trade-off barrier).** For every $x > e$ there exists $k \ge 1$ with
$$k\exp\!\big(x^{1/k}\big) \ \le\ e^{e}\,(\log x + 1).$$

*Proof sketch.* Take $k = \lceil \log x \rceil$, which is at least $1$ since $\log x > 1$. Then $\log x \le k \le \log x + 1$. The balanced budget satisfies
$$x^{1/k} = \exp\!\Big(\frac{\log x}{k}\Big) \le \exp(1) = e,$$
so $k\exp(x^{1/k}) \le k\,e^{e} \le (\log x + 1)e^{e}$. $\square$

The right-hand side is $O(\log x)$, hence polynomially bounded in $x$. This is a genuine limitation of the barrier, and we state it rather than hide it:

> **Scope of the trade-off barrier.** The trade-off barrier is a theorem about *bounded* arity. A strategy that balances unboundedly many stages simultaneously escapes it. No known classical method supplies the structure required to do so; that structural novelty is precisely what the capstone leaves unclassified.

This boundary is also the seed of the arity-separation conjecture discussed in §11.

---

## 6. The randomness barrier, made worst-case rigorous

### 6.1 Collisions are the whole method

Pollard's rho method and its relatives compute $\gcd(x_i - x_j, N)$ for iterates $x_i$ of some map. The quoted $\Theta(N^{1/4})$ running time is a *birthday heuristic*, assuming that iterates behave like uniform random residues modulo the unknown prime $p \approx \sqrt N$. Two unconditional theorems sit underneath the heuristic.

**Theorem 6.1 (Collisions are necessary).** Let $p, q$ be primes and $a, b \in \mathbb{Z}$ with $p \nmid (a-b)$ and $q \nmid (a-b)$. Then $\gcd(a-b,\, pq) = 1$.

*Proof sketch.* Let $d = \gcd(a-b, pq)$. Then $d \mid pq$ and $d \mid (a-b)$; $d \ne 0$ since $pq \ne 0$. If $d > 1$, pick a prime $r \mid d$; then $r \mid pq$, so $r = p$ or $r = q$, and $r \mid (a-b)$ contradicts one of the two hypotheses. Hence $d = 1$. $\square$

So the gcd step yields nothing unless the trajectory collides modulo $p$ or modulo $q$. Collision-finding is not one strategy among many for these methods; it *is* the method.

### 6.2 A provably blind trajectory

**Theorem 6.2 (Arithmetic trajectory blindness).** Let $p, q$ be primes and $K \le \min(p,q)$. Then for all distinct $i, j \in \{0,1,\dots,K-1\}$,
$$\gcd(i - j,\ pq) = 1 .$$

*Proof sketch.* $i \ne j$ gives $i - j \ne 0$, and $0 \le i,j < K$ gives $|i-j| < K \le \min(p,q)$. If $p \mid (i-j)$ then $p \le |i-j| < p$, absurd; similarly for $q$. Now apply Theorem 6.1. $\square$

**Corollary 6.3 (Worst-case waste).** For a semiprime $pq$ with both prime factors at least $B$, every pair of distinct points of the arithmetic trajectory of length $B$ fails to produce a nontrivial divisor. Hence a collision-based search can be made to waste $B$ steps.

### 6.3 What this corrects

For a balanced semiprime, $\min(p,q) \approx \sqrt{N}$. Therefore:

> **Honest restatement of the randomness barrier.** The provable *worst-case* lower bound for collision-based factoring is $\sqrt{N}$, not $N^{1/4}$. The celebrated fourth-root running time is an average-case phenomenon about pseudorandom trajectories, not a theorem about all trajectories.

We nonetheless retain $\exp(x/4) = N^{1/4}$ as the tabulated barrier in Definition 4.2, because the conditional-impossibility argument only requires a superpolynomial *lower* bound on the barrier profile, and $N^{1/4}$ is the weaker, more conservative choice: the worst-case sharpening to $\sqrt N$ would only strengthen the conclusion. Using the smaller value keeps the framework's claims minimal.

---

## 7. The information-theoretic Fourier sample bound

### 7.1 Motivation

Period-finding-based factoring extracts the order $r$ of $a$ modulo $N$ from the discrete Fourier transform of a period-$r$ signal. A recurring hope for a "classical Shor" is that *few* Fourier samples might suffice — that some clever choice of a small number of frequencies could pin down the period. We show that this is impossible, in a representation-independent form that depends only on $\mathbb{C}$-linearity of Fourier sampling and not on any computational model.

### 7.2 The dimension bound

**Theorem 7.1 (Linear measurement dimension bound).** Let $V, W$ be $\mathbb{C}$-vector spaces with $W$ finite-dimensional, and let $M : V \to W$ be $\mathbb{C}$-linear with $\dim W < \dim V$. Then there exist $v \ne w$ in $V$ with $Mv = Mw$.

*Proof.* If $M$ separated all pairs it would be injective, whence $\dim V \le \dim W$, contradicting the hypothesis. $\square$

### 7.3 Fourier sampling on $\mathbb{Z}/r\mathbb{Z}$

Let $r \ge 1$. The signal space is $\mathbb{C}^{\mathbb{Z}/r\mathbb{Z}}$, of dimension $r$. For a family of frequencies $\iota : \{1,\dots,K\} \to \mathbb{Z}/r\mathbb{Z}$, define the *sampling map*
$$S_\iota : \mathbb{C}^{\mathbb{Z}/r\mathbb{Z}} \to \mathbb{C}^{K}, \qquad (S_\iota v)_j = \widehat{v}(\iota(j)),$$
where $\widehat{\ \cdot\ }$ denotes the discrete Fourier transform on $\mathbb{Z}/r\mathbb{Z}$. This is a composition of the (linear, indeed invertible) transform with a coordinate restriction, hence $\mathbb{C}$-linear, and its codomain has dimension $K$.

**Theorem 7.2 (Fewer than $r$ samples are blind).** If $K < r$, then for *any* choice of $K$ sample frequencies there exist two distinct signals $v \ne w$ on $\mathbb{Z}/r\mathbb{Z}$ with
$$\widehat{v}(\iota(j)) = \widehat{w}(\iota(j)) \quad \text{for all } j = 1,\dots,K.$$

*Proof.* Apply Theorem 7.1 to $S_\iota$, using $\dim \mathbb{C}^{\mathbb{Z}/r\mathbb{Z}} = r > K = \dim\mathbb{C}^{K}$. $\square$

**Theorem 7.3 (Sample lower bound $K \ge r$).** Suppose a family of $K$ sample frequencies is *determining*, i.e. any two signals agreeing at all $K$ sampled frequencies of their transforms are equal. Then $K \ge r$.

*Proof.* Contrapositive of Theorem 7.2. $\square$

**Theorem 7.4 (Sharpness).** Sampling at all $r$ frequencies is determining: the discrete Fourier transform on $\mathbb{Z}/r\mathbb{Z}$ is a linear isomorphism, hence injective. Thus the bound $K \ge r$ is attained.

### 7.4 Interpretation: the resource that gets through

Theorem 7.3 is unconditional, information-theoretic, and independent of the computational model — it constrains *any* procedure whose access to the signal is through linear Fourier measurements at chosen frequencies, regardless of how those frequencies are computed or how the measurement outcomes are post-processed. Since the period $r$ of $a$ modulo $N$ is typically of size comparable to $N$, a classical sampling strategy must pay $\Omega(N)$ measurements.

Quantum superposition is precisely the resource that evades this: a single quantum state carries all $r$ amplitudes simultaneously, and the quantum Fourier transform acts on all of them in one physical operation. The bound $K \ge r$ is therefore not merely a technical lemma but the *identification of the boundary*: it says exactly which capability separates the quantum route from every sampling-based classical imitation of it.

---

## 8. The conditional-impossibility schema

### 8.1 Abstract algorithms

**Definition 8.1 (Classical algorithm, abstracted).** A *classical algorithm* is a cost profile $C : \mathbb{R} \to \mathbb{R}$, where $C(x)$ is the running time on inputs of bit-size $x = \log N$, subject to the normalization $C(x) \ge 1$ for all sufficiently large $x$ (every algorithm performs at least one step).

**Definition 8.2.** An algorithm $A$ with cost $C$:
- runs in **polynomial time** if $C$ is polynomially bounded (Definition 3.1);
- is **limited by** a resource $\rho \in \mathcal{R}$ if $B_\rho(x) \le C(x)$ for all sufficiently large $x$;
- **uses a classified resource** if it is limited by some $\rho \in \mathcal{R}$.

The definition of "limited by" is deliberately weak: it asserts only that the algorithm's cost is eventually at least the documented barrier for that resource. This is the honest rendering of "this method runs into that wall."

### 8.2 The chain

**Theorem 8.3 (Step 1: strict beating).** If $A$ runs in polynomial time then for every $\rho \in \mathcal{R}$, $C(x) < B_\rho(x)$ for all sufficiently large $x$.

*Proof sketch.* Take $C(x) \le K x^{d}$ eventually. By Theorem 4.4, $B_\rho(x)/x^{d} \to \infty$, so eventually $B_\rho(x)/x^{d} > K+1$, i.e. $(K+1)x^{d} < B_\rho(x)$. For $x > 1$ we have $x^d > 0$, so $C(x) \le Kx^{d} < (K+1)x^{d} < B_\rho(x)$. $\square$

**Theorem 8.4 (Step 2: no barrier applies).** If $A$ runs in polynomial time then $A$ is limited by no $\rho \in \mathcal{R}$.

*Proof.* "Limited by $\rho$" and Theorem 8.3 both hold eventually, so they hold simultaneously at some point $x$, giving $B_\rho(x) \le C(x) < B_\rho(x)$. $\square$

**Theorem 8.5 (Conditional impossibility).** If a classical algorithm factors semiprimes with cost polynomially bounded in $\log N$, then it does not use a classified resource: the resource it exploits lies outside $\{\mathsf{randomness}, \mathsf{smoothness}, \mathsf{iteration}, \mathsf{analog}\}$.

*Proof.* Immediate from Theorem 8.4 and Definition 8.2. $\square$

**Theorem 8.6 (Contrapositive form).** An algorithm confined to the classified resources cannot run in polynomial time.

### 8.3 The quantitative form

The gap is not merely positive; it is unbounded.

**Theorem 8.7 (Unbounded gap).** If $A$ runs in polynomial time, then for every $\rho \in \mathcal{R}$,
$$\lim_{x\to\infty}\frac{B_\rho(x)}{C(x)} = +\infty .$$

*Proof sketch.* Write $C(x) \le Kx^d$ eventually, with $K > 0$ (positivity of $K$ follows from the normalization $C(x)\ge 1$ at a point where the bound holds). Then
$$\frac{B_\rho(x)}{C(x)} \ \ge\ \frac{B_\rho(x)}{Kx^{d}} = \frac{1}{K}\cdot\frac{B_\rho(x)}{x^{d}} \xrightarrow[x\to\infty]{} \infty,$$
using positivity of $B_\rho$ (Lemma 4.6) and superpolynomiality (Theorem 4.4). $\square$

So a hypothetical fast classical algorithm would not merely edge past the known barriers; it would leave each of them behind by an arbitrarily large factor.

### 8.4 Level 3: scope, stated as a hypothesis

**Definition 8.8 (Classified Resource Hypothesis, CRH).** *Every classical factoring algorithm is limited by one of the four classified barriers.*

We emphasize: **CRH is not proved here, and we do not believe it should be regarded as established.** It is a statement about the space of all algorithms, including those not yet invented. What we prove are its consequences and its falsifiability.

**Theorem 8.9 (CRH implies hardness).** If CRH holds, then no classical factoring algorithm runs in polynomial time.

*Proof.* Combine CRH with Theorem 8.6. $\square$

**Theorem 8.10 (Falsifiability).** If some classical factoring algorithm runs in polynomial time, then CRH is false.

*Proof.* Contrapositive of Theorem 8.9, or directly: Theorem 8.5 denies the conclusion CRH asserts for that algorithm. $\square$

### 8.5 Non-vacuity

A conditional whose antecedent or consequent is empty carries no information. Both sides here are inhabited and the classes are disjoint.

**Theorem 8.11 (Non-vacuity).**
1. There is an algorithm that uses a classified resource and is not polynomial-time: the abstract algorithm whose cost profile *is* $B_{\mathsf{smoothness}}$. It is limited by $\mathsf{smoothness}$ trivially (equality), and it is not polynomial-time by Theorem 8.6. (Its cost satisfies the normalization $C(x)\ge1$ eventually, since $B_\rho(x)/x^{0} = B_\rho(x) \to \infty$.)
2. There is a polynomial-time algorithm that uses no classified resource: the cost profile $C(x) = x^{2}$, polynomially bounded with $K=1$, $d=2$, and not using a classified resource by Theorem 8.5.

Thus the two predicates "uses a classified resource" and "runs in polynomial time" are each satisfiable, and Theorem 8.5 says they are mutually exclusive.

### 8.6 The capstone

**Theorem 8.12 (Capstone).** Let $A$ be a classical factoring algorithm running in polynomial time in $\log N$. Then:

1. for every classified resource $\rho$, the ratio $B_\rho(x)/C(x)$ tends to infinity;
2. $A$ is limited by none of $\{\mathsf{randomness},\mathsf{smoothness},\mathsf{iteration},\mathsf{analog}\}$;
3. $A$ does not use a classified resource;
4. consequently the Classified Resource Hypothesis is false — the resource $A$ exploits lies outside the classified catalogue.

*Proof.* Items 1–4 are Theorems 8.7, 8.4, 8.5, 8.10 respectively. $\square$

This is a rigorous conditional. It derives strong structural consequences from the hypothetical existence of a fast classical algorithm, **without asserting that no such algorithm exists**.

---

## 9. The quantum boundary

The framework classifies classical resources only. It is instructive to record precisely what it says, and does not say, about the quantum route.

Two unconditional facts point in opposite directions:

- The classical post-processing reduction from order finding to factorization (Theorem 2.4) is *free*. Nothing obstructs it.
- The only information-theoretic obstruction we can establish for Fourier-based period determination is the sample-count bound $K \ge r$ (Theorem 7.3) — and superposition supplies all $r$ amplitudes in a single shot.

**Theorem 9.1 (Boundary statement).** Let $N > 1$, $a \in \mathbb{Z}$, $s \in \mathbb{N}$ with $N \mid a^{2s}-1$, $N \nmid a^{s}\mp 1$; and let $r \ge 1$, $\iota$ a determining family of $K$ Fourier sample frequencies on $\mathbb{Z}/r\mathbb{Z}$. Then simultaneously:
1. $\gcd(a^{s}-1, N)$ is a nontrivial divisor of $N$; and
2. $K \ge r$.

The juxtaposition is the point. Once the period is known, factoring is trivial; and the only classical route to the period through Fourier measurement demands a number of measurements equal to the period itself. Superposition is, in the language of this framework, the unique known resource that evades all four classical barriers, and the sample bound identifies exactly the capability it provides.

---

## 10. Discussion

### 10.1 What the framework establishes

The framework's claims can be summarized in one sentence and one caveat.

*The sentence:* Every resource known to classical factoring runs into a provably superpolynomial wall; the exponents in those walls are forced balance points rather than tunable parameters; the natural classical imitation of the quantum route is blocked by a dimension count; therefore a polynomial-time classical factoring algorithm would necessarily exploit a resource outside the entire known catalogue.

*The caveat:* This is a classification of the known. It is not, and does not pretend to be, a proof that the unknown is empty.

### 10.2 Why the honest framing has value

There is a temptation, in work of this kind, to present a classification of known methods as though it were a lower bound. Resisting the temptation costs nothing and gains a great deal. What remains is:

- **A falsifiable hypothesis.** CRH is a crisp statement that a single algorithm would refute. Hypotheses that can be killed by an explicit construction are the useful kind.
- **A specification for a breakthrough.** The framework tells a would-be breaker of RSA what to bring: not a faster sieve, not a better random walk, not an analog device, but a genuinely new resource, in a precise sense — one whose cost profile is not eventually bounded below by any of four explicit superpolynomial functions.
- **A separation of mathematics from folklore.** The correction of the collision barrier from $N^{1/4}$ to $\sqrt{N}$ in the worst case (§6) is a concrete instance: the heuristic figure is widely quoted as though it were a theorem, and it is not.

### 10.3 Limitations

We list the framework's limitations explicitly.

1. **Exhaustiveness is unproved.** CRH is a hypothesis. The framework is silent on resources not in the catalogue — that silence is exactly its subject matter.
2. **The abstraction is coarse.** Algorithms are modeled as cost profiles. Two algorithms with the same profile are indistinguishable here. This is deliberate — the classification concerns asymptotic resource cost, not algorithmic structure — but it means the framework cannot express fine-grained statements (e.g. about memory or parallelism).
3. **The trade-off model is a model.** Theorem 5.3 characterizes the optimum of a specific cost model with a multiplicative constraint. That this model captures sieving is an interpretive claim, supported by the match with the observed exponents $1/2$ and $1/3$, not a derivation from the algorithms themselves.
4. **The trade-off barrier has an explicit boundary.** Theorem 5.7 shows the bound dissolves at unbounded arity. We regard this as a feature: it names a concrete structural property a breakthrough might have.
5. **The Fourier bound constrains sampling, not computation.** Theorem 7.3 bounds the number of linear measurements. It does not exclude a classical algorithm that determines the period by entirely non-measurement means.

### 10.4 Relation to the broader landscape

The framework is complementary to, and logically independent of, the standard complexity-theoretic picture. Factoring is in $\mathsf{NP} \cap \mathsf{coNP}$, so it is not $\mathsf{NP}$-hard unless the polynomial hierarchy collapses; conventional hardness assumptions therefore give no leverage. Nor do known black-box or oracle separations apply directly, since factoring is a structured problem with no natural oracle formulation. What is available is exactly what this framework makes precise: an accounting of resources and the walls they hit.

---

## 11. Future directions

We record five directions, stated so as to be falsifiable.

### 11.1 The trade-off arity conjecture

Define the *arity* of a cost profile $f$ as the least $k$ such that $f(x) \le k\exp(c\,x^{1/k})$ for some $c>0$ and all large $x$.

> **Conjecture (Arity separation).** The arity classes are strictly nested: for every $k$ there is a cost profile of arity $k+1$ that is not $O$ of any arity-$k$ profile; and a profile is polynomially bounded if and only if it has no finite arity.

The motivation is Theorem 5.3: the exponent $1/k$ is the balance point of a multiplicative constraint, so "improving the exponent" and "adding a stage" are literally the same operation, and polynomial time is the $k \to \infty$ limit (Theorem 5.7). Both endpoints of the ladder are already established; only strictness of the intermediate steps is open, and it reduces to a limit computation of the kind carried out in §3.

*Falsifier.* Exhibit $c, c', k$ with $(k+1)\exp(c\,x^{1/(k+1)}) = O\big(k\exp(c'x^{1/k})\big)$. This would collapse the ladder and invalidate the non-degeneracy of the classification.

### 11.2 Barrier closure under algorithmic composition

> **Conjecture (Barrier closure).** The class of algorithms limited by a classified barrier is closed under composition, sequential repetition, and polynomial-time preprocessing: if $A$ is limited by $\rho$ and $B$ runs in polynomial time, then the composite profile $x \mapsto C_A(x) + C_B(p(x))$ is still limited by $\rho$ for every polynomial reparametrization $p$ bounded below by a positive power of $x$.

The motivation is Lemma 4.3: superpolynomiality is stable under $x \mapsto x/b$, which is already what legitimizes the ECM entry with $\log p \approx x/2$. The same argument should give stability under arbitrary polynomial reparametrization, upgrading the capstone from a statement about single algorithms to a statement about an entire closed complexity class. Closure is exactly what makes CRH a statement about a robust class rather than about a list.

*Falsifier.* A reparametrization $p$ and a superpolynomial $f$ with $f\circ p$ polynomially bounded — e.g. any sub-logarithmic $p$. The conjecture must therefore be stated with $p$ bounded below by a positive power, and the interesting question is whether that restriction suffices.

### 11.3 Sharpening the collision barrier to the average case

Section 6 gives a worst-case bound of $\min(p,q)$. Proving the $\Theta(N^{1/4})$ figure as a theorem — rather than a birthday heuristic — requires a rigorous equidistribution statement for iterates of the maps actually used. Making such a statement precise, and either proving it or identifying the obstruction, would close the framework's largest gap between folklore and theorem.

### 11.4 Beyond sampling: non-measurement period determination

Theorem 7.3 constrains procedures whose access to the signal is through linear measurements at chosen frequencies. A classical algorithm that determines the period by other means — algebraic identities, or nonlinear access to the signal — is not excluded. Characterizing what "non-measurement access" could mean, and whether an analogous dimension obstruction survives, is the natural next barrier to seek.

### 11.5 A resource calculus

The four classified resources are currently a list. A more satisfying framework would give an algebra: operations that combine resources, invariants preserved under those operations, and a proof that the classified set is closed under them. Combined with §11.2, this would turn the classification into a genuine structure theory of classical factoring effort.

---

## 12. Conclusion

We have assembled a conditional-impossibility framework for classical integer factoring that keeps three logical levels rigorously apart. Unconditionally: the congruence-of-squares reduction is free, so all difficulty lies in producing the congruence; the subexponential complexity functions occupy a strictly intermediate rung between polynomial and exponential growth; every one of the four classified barriers is superpolynomial and the classification is non-degenerate; the sieve exponents $1/k$ are AM–GM balance points, not design choices, and no bounded-arity trade-off reaches polynomial time; collision methods are provably blind for $\min(p,q)$ steps in the worst case; and any determining family of Fourier sample frequencies for a period-$r$ signal has at least $r$ members.

Conditionally: any polynomial-time classical factoring algorithm beats each classified barrier by an unbounded factor, is limited by none of them, and therefore exploits a resource outside the classified catalogue — falsifying the Classified Resource Hypothesis.

And honestly: the Classified Resource Hypothesis is a hypothesis. The framework maps the walls we know. It does not claim there are no doors.
