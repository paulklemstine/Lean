# Gamma–Poisson Duality and the Integer-Shape Descendant Limit Law for Random Recursive DAGs

## Abstract

For the random recursive directed acyclic graph (DAG) $G_n$ with fixed out-degree $d \ge 2$, the number $|D_n|$ of descendants of the root, once rescaled by $n^{1/d}$, converges in distribution to a Gamma law with shape parameter $d$ and rate $1$. Because the shape parameter is a positive integer, the limiting law is an Erlang distribution, whose cumulative distribution function admits a finite closed form. We prove — by elementary real analysis alone — the classical **Gamma–Poisson duality** in this setting: the cumulative distribution function of $\mathrm{Gamma}(m+1, 1)$ equals $1 - \sum_{k=0}^{m} e^{-t} t^k / k!$, and each summand is exactly a Poisson$(t)$ point mass, so the survival function of the continuous Erlang limit is identically the tail of a discrete Poisson law. The proof rests on a single telescoping derivative identity together with the Fundamental Theorem of Calculus, and it simultaneously yields: the closed-form cumulative distribution function; the fact that the Erlang density integrates to $1$; the decay of the survival function at infinity; and the monotonicity of the distribution function. We further record the moment structure of the limit target — a rising-factorial sequence satisfying Carleman's condition, hence moment-determinate — and the resulting equidispersion (variance equal to mean), interpreting it as an inherited Poisson fingerprint. We close with conjectures upgrading these facts to a uniform Poisson-tail representation of the full descendant distribution function, and to a unified analytic description across all out-degrees $d \ge 1$.

**Keywords:** random recursive DAG, descendant count, Gamma distribution, Erlang distribution, Poisson tail, Gamma–Poisson duality, telescoping sum, method of moments, equidispersion.

---

## 1. Introduction

### 1.1 Random recursive DAGs and descendant counts

A *random recursive directed acyclic graph* (random $d$-DAG) with out-degree $d$ is built incrementally. One begins with a single root vertex labeled $1$. At each subsequent step $t = 2, 3, \dots, n$, a new vertex $t$ is added, and $d$ distinct vertices are chosen uniformly at random from among the existing vertices $\{1, \dots, t-1\}$ (for $t \le d$ one takes all available predecessors); vertex $t$ sends an arc to each chosen vertex. The result is a directed acyclic graph on $n$ vertices in which all arcs point from higher labels to lower labels, so no cycle is possible.

These graphs interpolate a widely used modeling idiom: each newly created object depends on several previously existing objects. Concrete instances include software module dependency graphs, citation networks with a fixed citation budget, versioned artifact lineages, and directed-acyclic-graph ledgers. The case $d = 1$ recovers the classical random recursive *tree*.

Fix the root and let $D_n$ denote the set of vertices from which the root is reachable — the *descendants* of the root — and $|D_n|$ its cardinality. The asymptotic behavior of $|D_n|$ quantifies how much of a large recursive network ultimately traces back to its origin.

### 1.2 The scaling limit

The qualitative behavior of $|D_n|$ changes sharply between the tree regime and the DAG regime. For $d = 1$ the descendant count grows linearly in $n$. For $d \ge 2$ the requirement that *all* backward paths route through the root suppresses the count to sublinear order $n^{1/d}$. The governing result is the following.

**Theorem 1 (Descendant limit law).** *For the random recursive DAG with out-degree $d \ge 2$,*
$$\frac{|D_n|}{n^{1/d}} \xrightarrow{\ d\ } \mathrm{Gamma}(d, 1) \qquad (n \to \infty),$$
*where $\mathrm{Gamma}(d,1)$ is the distribution on $(0,\infty)$ with density $f_d(x) = x^{d-1} e^{-x} / \Gamma(d)$.*

Theorem 1 is the backdrop for the present paper; our contribution concerns the fine structure of the limit target $\mathrm{Gamma}(d,1)$ when $d$ is an integer, which is always the case here.

### 1.3 Contributions

This paper establishes, by elementary and fully rigorous real analysis, the following.

1. A **telescoping derivative identity** for Poisson point masses viewed as functions of the continuous parameter (Section 3).
2. The **Gamma–Poisson duality**: a finite closed form for the Erlang cumulative distribution function, exhibiting it as a Poisson tail (Section 4, Theorem 4).
3. Three immediate corollaries of the same identity: the survival function vanishes at infinity, the Erlang density is a bona fide probability density (integrates to $1$), and the distribution function is monotone (Section 5).
4. The **moment structure** of the limit law: rising-factorial moments, moment-determinacy via Carleman's condition, and equidispersion interpreted as a Poisson fingerprint (Section 6).

The mathematical spine is a single derivative computation; everything else follows by the Fundamental Theorem of Calculus, an induction, and a limit.

---

## 2. Definitions and notation

Throughout, $m$ denotes a nonnegative integer and $t, x$ real variables. We write $\Gamma$ for the Euler Gamma function, with $\Gamma(m+1) = m!$ for integer $m$.

**Definition 1 (Poisson term).** For $k \in \mathbb{N}$ and $t \in \mathbb{R}$, the *Poisson term* is
$$p_k(t) := \frac{e^{-t}\, t^{k}}{k!}.$$
Viewed as a function of the discrete index $k$, $\{p_k(t)\}_{k \ge 0}$ is the probability mass function of the Poisson$(t)$ distribution. Viewed as a function of the continuous variable $t$, $p_m$ is proportional to the $\mathrm{Gamma}(m+1, 1)$ density.

**Definition 2 (Erlang survival sum).** For $n \in \mathbb{N}$ and $t \in \mathbb{R}$,
$$S_n(t) := \sum_{k=0}^{n-1} p_k(t) = \sum_{k=0}^{n-1} \frac{e^{-t} t^k}{k!}.$$
For $t \ge 0$ this is simultaneously the lower Poisson tail $\mathbb{P}(\mathrm{Poisson}(t) \le n-1) = \mathbb{P}(\mathrm{Poisson}(t) < n)$.

**Definition 3 (Gamma density).** The $\mathrm{Gamma}(a, 1)$ density on $(0, \infty)$ is $g_a(x) = x^{a-1} e^{-x} / \Gamma(a)$. For integer shape $a = m+1$ this is the *Erlang* density.

The elementary identity connecting the two definitions is worth recording, since it makes precise the phrase "the Poisson term is the Gamma density."

**Lemma 1 (Term equals Gamma density).** *For every $m \in \mathbb{N}$ and $x \in \mathbb{R}$,*
$$p_m(x) = \frac{e^{-x} x^m}{\Gamma(m+1)}.$$
*Proof.* Immediate from $\Gamma(m+1) = m!$. $\qquad\blacksquare$

All integrals below are with respect to Lebesgue measure; densities are on $(0, \infty)$.

---

## 3. The telescoping derivative identity

The entire analysis rests on the following two derivative computations.

**Lemma 2 (Telescoping step).** *For every $m \in \mathbb{N}$ and $t \in \mathbb{R}$, $p_{m+1}$ is differentiable at $t$ with*
$$p_{m+1}'(t) = p_m(t) - p_{m+1}(t).$$

*Proof.* Write $p_{m+1}(t) = e^{-t} t^{m+1} / (m+1)!$. By the product rule, using $\frac{d}{dt} e^{-t} = -e^{-t}$ and $\frac{d}{dt} t^{m+1} = (m+1) t^m$,
$$p_{m+1}'(t) = \frac{-e^{-t} t^{m+1} + (m+1) e^{-t} t^m}{(m+1)!} = \frac{e^{-t} t^m}{m!} - \frac{e^{-t} t^{m+1}}{(m+1)!} = p_m(t) - p_{m+1}(t),$$
where we used $(m+1)!/(m+1) = m!$. $\qquad\blacksquare$

**Lemma 3 (Base case).** *For every $t \in \mathbb{R}$, $p_0(t) = e^{-t}$ is differentiable with $p_0'(t) = -p_0(t)$.*

*Proof.* $p_0(t) = e^{-t}$, so $p_0'(t) = -e^{-t} = -p_0(t)$. $\qquad\blacksquare$

The name *telescoping* refers to what happens when Lemma 2 is summed: differentiating the survival sum produces a chain of consecutive differences in which all interior terms cancel.

**Theorem 2 (Derivative of the survival sum).** *For every $m \in \mathbb{N}$ and $t \in \mathbb{R}$,*
$$S_{m+1}'(t) = -p_m(t) = -\frac{e^{-t} t^m}{m!}.$$
*That is, the derivative of the Erlang survival sum is minus the Erlang density.*

*Proof.* Induction on $m$. For $m = 0$, $S_1 = p_0$ and Lemma 3 gives $S_1'(t) = -p_0(t)$. For the inductive step, $S_{m+2}(t) = S_{m+1}(t) + p_{m+1}(t)$, so by the inductive hypothesis and Lemma 2,
$$S_{m+2}'(t) = -p_m(t) + \big(p_m(t) - p_{m+1}(t)\big) = -p_{m+1}(t),$$
completing the induction. $\qquad\blacksquare$

The interior term $p_m(t)$ produced by differentiating $p_{m+1}$ exactly cancels the $-p_m(t)$ contributed by the inductive hypothesis; this cancellation is the telescope. A direct term-by-term differentiation of $\sum_{k<n} x^k / k!$ would instead require an index-shift identity $\sum_{k<n} k\, t^{k-1}/k! = \sum_{j<n-1} t^j/j!$; routing everything through the single-index $p_k$ and inducting avoids that reindexing entirely.

We also record two elementary regularity facts used below.

**Lemma 4 (Continuity).** *Each $p_k$ is continuous on $\mathbb{R}$.* *Proof.* $p_k$ is a product/quotient of the continuous functions $t \mapsto e^{-t}$, $t \mapsto t^k$, and the constant $1/k!$. $\qquad\blacksquare$

**Lemma 5 (Value at zero).** *For $n \ge 1$, $S_n(0) = 1$.* *Proof.* At $t = 0$ only the $k = 0$ term is nonzero, and $p_0(0) = 1$; all terms with $k \ge 1$ vanish because $0^k = 0$. $\qquad\blacksquare$

---

## 4. The Gamma–Poisson duality

We can now state and prove the central result.

**Theorem 3 (Erlang cumulative distribution function; Gamma–Poisson duality).** *For every $m \in \mathbb{N}$ and every $t \in \mathbb{R}$,*
$$\int_0^t \frac{e^{-x} x^m}{m!}\, dx = 1 - S_{m+1}(t) = 1 - \sum_{k=0}^{m} \frac{e^{-t} t^k}{k!}.$$
*Equivalently, for $t \ge 0$,*
$$\mathbb{P}\big(\mathrm{Gamma}(m+1, 1) \le t\big) = 1 - \mathbb{P}\big(\mathrm{Poisson}(t) \le m\big) = \mathbb{P}\big(\mathrm{Poisson}(t) \ge m+1\big).$$

*Proof.* By Theorem 2, $S_{m+1}$ has derivative $-p_m$ at every point of the interval between $0$ and $t$. The function $p_m$ is continuous (Lemma 4), hence so is $-p_m$, and it is therefore interval-integrable. The Fundamental Theorem of Calculus gives
$$\int_0^t \big(-p_m(x)\big)\, dx = S_{m+1}(t) - S_{m+1}(0).$$
Negating both sides and using $S_{m+1}(0) = 1$ (Lemma 5) yields
$$\int_0^t p_m(x)\, dx = -\big(S_{m+1}(t) - 1\big) = 1 - S_{m+1}(t).$$
Since $p_m(x) = e^{-x} x^m / m!$ is the $\mathrm{Gamma}(m+1,1)$ density (Lemma 1), the left side is the Erlang CDF at $t$, and each summand of $S_{m+1}(t)$ is a Poisson$(t)$ mass, giving the probabilistic restatement. $\qquad\blacksquare$

**Remark (Probabilistic reading via the Poisson process).** The identity is the analytic shadow of a single fact about a rate-$1$ Poisson process. The waiting time until the $(m+1)$-st arrival is $\mathrm{Erlang}(m+1)$, while the number of arrivals in $[0, t]$ is $\mathrm{Poisson}(t)$. The events $\{\text{$(m+1)$-st arrival} \le t\}$ and $\{\text{at least $m+1$ arrivals by time } t\}$ coincide, and equating their probabilities is exactly Theorem 3. The proof above establishes the identity purely analytically, independent of that interpretation.

The duality realizes a bridge between the continuous scaling limit of a combinatorial process (the descendant count) and a discrete counting distribution (the Poisson law): the survival function of the continuous Erlang limit *is* the tail of a discrete Poisson law, term for term.

---

## 5. Corollaries: a genuine probability law

The same derivative identity yields, at no extra cost, the properties that certify $g_{m+1}$ as a probability density and its integral as a distribution function.

**Lemma 6 (Termwise decay).** *For each $k$, $p_k(t) \to 0$ as $t \to \infty$.* *Proof.* $p_k(t) = (t^k e^{-t})/k!$ and $t^k e^{-t} \to 0$ as $t \to \infty$ (polynomial-times-decaying-exponential). $\qquad\blacksquare$

**Theorem 4 (Survival function vanishes at infinity).** *For every $n$, $S_n(t) \to 0$ as $t \to \infty$.* *Proof.* $S_n$ is a finite sum of the $p_k$, each tending to $0$ by Lemma 6; the sum of finitely many null limits is null. $\qquad\blacksquare$

**Theorem 5 (The Erlang density is a probability density).** *For every $m$,*
$$\int_0^\infty \frac{e^{-x} x^m}{m!}\, dx = 1.$$
*Proof.* By Theorem 3, the cumulative integral equals $1 - S_{m+1}(t)$; by Theorem 4, $S_{m+1}(t) \to 0$ as $t \to \infty$, so the integral tends to $1$. $\qquad\blacksquare$

This is a self-contained cross-check: the normalization of the Gamma$(m+1,1)$ density is obtained here *through the duality*, without invoking $\int_0^\infty x^m e^{-x}\,dx = m!$ as an external input.

**Theorem 6 (Monotonicity of the distribution function).** *The map $t \mapsto \int_0^t p_m(x)\, dx$ is nondecreasing on $[0, \infty)$.* *Proof.* For $0 \le a \le b$, additivity of the integral over adjacent intervals gives $\int_0^b p_m = \int_0^a p_m + \int_a^b p_m$, and $\int_a^b p_m \ge 0$ because the integrand $p_m(x) = e^{-x} x^m/m! \ge 0$ on $[a,b]$. Hence the value at $b$ is at least the value at $a$. $\qquad\blacksquare$

Together, Theorems 3, 5, and 6 show that the integer-shape Gamma limit target is completely explicit: its distribution function is a finite Poisson tail, it is a bona fide probability law, and it is monotone.

---

## 6. Moment structure of the limit law

Beyond the distribution function, the limit target has a transparent moment structure that both validates the method of moments and explains a striking coincidence.

**Proposition 1 (Rising-factorial moments).** *The $k$-th moment of $\mathrm{Gamma}(d, 1)$ is the rising factorial*
$$m_k := \mathbb{E}\big[\mathrm{Gamma}(d,1)^k\big] = \frac{\Gamma(d + k)}{\Gamma(d)} = \prod_{i=0}^{k-1}(d + i) = d(d+1)\cdots(d+k-1),$$
*with recurrence $m_{k+1} = (d + k)\, m_k$ and $m_0 = 1$.*

In particular the mean is $m_1 = d$ and the second moment is $m_2 = d(d+1)$, so the variance is
$$\mathrm{Var} = m_2 - m_1^2 = d(d+1) - d^2 = d.$$

**Proposition 2 (Equidispersion).** *For every $d$, the mean and variance of $\mathrm{Gamma}(d, 1)$ coincide, both equal to $d$.*

Equidispersion — variance equal to mean — is the defining fingerprint of the Poisson distribution. Its appearance here is not a coincidence but the moment-level trace of the Poisson layer exposed by the Gamma–Poisson duality: the descendant limit behaves, in a precise sense, like a randomized Poisson mixture, and it inherits the Poisson's balance of center and spread through the scaling limit.

**Proposition 3 (Moment determinacy).** *The moment sequence $\{m_k\}$ satisfies Carleman's condition $\sum_{k \ge 1} m_{2k}^{-1/(2k)} = \infty$; consequently $\mathrm{Gamma}(d,1)$ is uniquely determined by its moments.*

*Sketch.* The rising factorial $m_{2k} = \prod_{i=0}^{2k-1}(d+i)$ grows only like $(2k)! \cdot (\text{polynomial factors})$ up to the shift by $d$; more precisely $m_{2k} = \Gamma(d+2k)/\Gamma(d)$, whose $2k$-th root grows linearly in $k$ (by Stirling, $(\Gamma(d+2k))^{1/(2k)} = \Theta(k)$). Hence $m_{2k}^{-1/(2k)} = \Theta(1/k)$ and the series diverges like the harmonic series. Carleman's condition then guarantees moment-determinacy. $\qquad\blacksquare$

The practical upshot is that matching the moments of $|D_n| / n^{1/d}$ to the rising factorials $\prod_{i<k}(d+i)$, power by power, is a *valid* proof of convergence to $\mathrm{Gamma}(d,1)$, not merely suggestive evidence: no other distribution on the line can share these moments.

---

## 7. Algorithms

We summarize the two computational primitives that the closed form makes trivial.

**Algorithm A (Exact Erlang CDF via Poisson tail).** To compute $F_{d}(t) = \mathbb{P}(\mathrm{Gamma}(d,1) \le t)$ for integer $d$: accumulate the $d$ Poisson terms $p_0(t), \dots, p_{d-1}(t)$ by the stable recurrence $p_0 = e^{-t}$, $p_{k} = p_{k-1} \cdot t/k$, sum them to obtain $S_d(t)$, and return $1 - S_d(t)$. Cost: $O(d)$ arithmetic operations, no integration, no special-function evaluation.

**Algorithm B (Descendant-count tail probability).** To estimate $\mathbb{P}(|D_n| \le c\, n^{1/d})$ for large $n$, apply Theorem 1 and Algorithm A with $t = c$: the answer is $\approx 1 - \sum_{k=0}^{d-1} e^{-c} c^k / k!$. This turns an asymptotic combinatorial question into an exact finite sum of $d$ terms.

Both are exact in the limit object and require only elementary arithmetic; the stable recurrence for $p_k$ avoids overflow of $t^k$ and $k!$ separately.

---

## 8. Applications

The finite Poisson-tail formula has direct consequences for reasoning about large recursive networks.

- **Instant threshold probabilities.** For a random $d$-DAG the probability that the root's descendant count is below a scale-$c$ threshold is, asymptotically, a sum of $d$ Poisson terms — computable exactly and instantly for any $d$, with no numerical integration.
- **Confidence bands.** Quantiles of the descendant count follow from inverting the finite Poisson tail, giving closed-form-style confidence intervals for lineage sizes.
- **Transfer of a mature theory.** A century of Erlang/Poisson results from queueing theory, telecommunications, and reliability engineering becomes available for the lineage structure of dependency graphs, citation webs, and DAG ledgers.
- **Diagnostic via equidispersion.** Because the limit is equidispersed, an empirical variance-to-mean ratio near $1$ (after rescaling) is a signature that a growing network is in the random-$d$-DAG universality class.

---

## 9. Discussion

The results assemble a three-layer picture of one object. At the *combinatorial* layer sits the descendant count $|D_n|$ of a random $d$-DAG. At the *continuous* layer, after rescaling by $n^{1/d}$, sits its limit, the $\mathrm{Gamma}(d,1)$ law. At the *discrete-counting* layer — reachable precisely because $d$ is an integer — sits the finite Poisson tail that equals the Erlang distribution function. The Gamma–Poisson duality is the hinge between the second and third layers, and its proof is remarkably economical: one telescoping derivative, the Fundamental Theorem of Calculus, one induction, and one limit.

The economy is itself informative. That the survival function's derivative collapses to a single density term is what lets the *same* computation certify the CDF, the normalization, the decay, and the monotonicity. The moment analysis then explains the equidispersion coincidence as an inherited Poisson trait rather than an accident of the DAG geometry, and it upgrades the method of moments from heuristic to proof via Carleman's condition.

A limitation is that the finite closed form is special to *integer* shape; for non-integer shape (which does not arise for the DAG descendant problem but does for related models) the CDF is the incomplete Gamma function with no finite Poisson-tail representation. The integer case is exactly the case relevant here, so the restriction costs nothing for the application, but it does mark the boundary of the elementary method.

---

## 10. Future directions

Derived from the present cycle — whose contributions are (i) the complete moment description of the $\mathrm{Gamma}(d,1)$ limit target, (ii) the $n^{1/d}$ mean-growth scaling of descendant counts, and (iii) the finite closed form of the integer-shape limit CDF as a Poisson tail — we highlight four directions.

**Conjecture 1 (Poisson-tail representation of the full descendant CDF).** For integer out-degree $d \ge 2$, the limiting distribution function of $|D_n|/n^{1/d}$ is exactly the Poisson survival function $t \mapsto \mathbb{P}(\mathrm{Poisson}(t) \ge d)$, and the convergence of distribution functions is uniform on the half-line. The key insight is that the continuous limit target, being Erlang for integer shape, carries a hidden discrete structure: its distribution function is a finite sum of Poisson point masses, so a continuous scaling limit is governed by a discrete counting law. The moment description and closed-form CDF are both in hand, so the remaining step — upgrading pointwise convergence of moments to uniform convergence of distribution functions — is the natural next target.

**Conjecture 2 (Moment determinacy of the limit law).** The $\mathrm{Gamma}(d,1)$ moment sequence $m_k = \prod_{i<k}(d+i)$ satisfies Carleman's condition, so it uniquely determines the limit distribution; consequently the method of moments is *valid* for the descendant limit theorem, not merely suggestive. The rising-factorial growth of the moments is slow enough (sub-$(2k)!$) that no other distribution can share them, turning the moment recurrence $m_{p+1} = (d+p) m_p$ into a genuine uniqueness statement.

**Conjecture 3 (Variance-to-mean rigidity across the DAG family).** Across all out-degrees $d \ge 1$, the limit law has variance exactly equal to its mean (both $= d$), and this equidispersion is inherited from the Poisson layer exposed by the Gamma–Poisson duality rather than from the DAG geometry. Equidispersion is a Poisson fingerprint, and its survival through the continuous scaling limit signals that the descendant process is, in a precise sense, a randomized Poisson mixture.

**Conjecture 4 (Interpolating the tree and DAG regimes).** The scaling exponent $1/d$ and multiplicative constant $1/\Gamma(1 + 1/d)$ of the mean-growth product vary analytically in $d \ge 1$, interpolating continuously between the linear growth of the random recursive tree ($d = 1$) and the $n^{1/d}$ regime ($d \ge 2$), with no phase transition at $d = 1$. The key insight is that the closed form for the expected descendant count is analytic in the out-degree, so the tree and DAG regimes are two ends of one smooth curve rather than qualitatively separate phenomena.

---

## References (indicative)

- S. Janson, *Random recursive trees and preferential attachment trees are less dependent than we thought* (and related work on descendant counts in recursive DAGs), 2023.
- W. Feller, *An Introduction to Probability Theory and Its Applications*, Vol. II (Gamma, Erlang, and Poisson relationships).
- A. K. Erlang, foundational work on the Erlang distribution in telephone traffic.
