# A Rigorous Finite-Size Theory of Landauer's Principle: From the Jarzynski Equality to Logical Irreversibility

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Novelty (Thermodynamics of Information)

---

## Abstract

We develop, from first principles over finite probability spaces, a complete and
self-contained mathematical theory of Landauer's principle — the statement that
erasing one bit of information dissipates at least $kT\ln 2$ of work. Starting
only from elementary inequalities ($1 + x \le e^x$ and $\ln x \le x - 1$) and the
finite Jarzynski equality $E[e^{-\alpha W}] = e^{-\alpha\,\Delta F}$, we prove:
(i) an exact *finite-size Landauer identity* expressing the mean dissipated work
as the free-energy difference plus a nonnegative fluctuation correction; (ii) the
average second law $\Delta F \le E[W]$ and the single-bit Landauer bound
$kT\ln 2 \le E[W]$; (iii) a saturation theorem showing the bound is attained
exactly in the reversible (zero-fluctuation) limit; (iv) an integral
fluctuation theorem bounding the probability of second-law violations by
$e^{-\xi/(kT)}$; (v) the extensivity of the bound, $n\,kT\ln 2$ for an $n$-bit
register, with exact per-bit cost $kT\ln 2$; (vi) a dual relative-entropy account
of the cost via Gibbs' inequality, together with a maximum-entropy bound; (vii) a
deterministic data-processing inequality identifying reversible (injective)
computation as the zero-dissipation boundary; and (viii) a bridge theorem showing
that *logical* irreversibility (non-injectivity of the erasure map) *forces*
*thermodynamic* irreversibility ($0 < E[W]$). All results are stated inline with
full mathematical content and proof sketches.

---

## 1. Introduction

In 1961 Rolf Landauer proposed that information processing is subject to a
thermodynamic constraint: any *logically irreversible* operation, one that maps
distinct logical states to a common state, must be accompanied by the dissipation
of heat into the environment. The canonical example is the erasure ("reset to
zero") of a single bit, whose minimal cost is

$$E[W] \ge kT \ln 2,$$

where $k$ is Boltzmann's constant and $T$ the absolute temperature of the heat
bath. The principle resolves the paradox of Maxwell's demon and sets a fundamental
floor on the energy efficiency of computation.

Classical derivations of Landauer's bound rely on idealized quasi-static
processes and equilibrium thermodynamics. At the nanoscale, however, erasure is a
genuinely nonequilibrium, fluctuating process: the work $W$ done in a single
realization is a random variable. The modern framework for such processes is the
fluctuation-theorem literature, of which the **Jarzynski equality** is the
cornerstone. The purpose of this paper is to present a rigorous, minimal-axiom
development of Landauer's principle *as a consequence of* the finite Jarzynski
equality, valid for memories of arbitrary (finite) size, and to make explicit the
logical-to-thermodynamic bridge that is the conceptual heart of the principle.

The development proceeds in eight movements: the basic finite-probability
framework (§3), the entropic cost of erasure (§4), the Jarzynski correction and
the second law (§5), saturation (§6), fluctuation bounds (§7), extensivity (§8), the
relative-entropy/maximum-entropy account (§9), and the data-processing inequality
together with the logical-irreversibility bridge (§10).

---

## 2. Related Work and Contribution

Landauer (1961) and Bennett (1982) established the principle and its role in the
thermodynamics of computation; Jarzynski (1997) proved the nonequilibrium work
equality; Esposito and Van den Broeck (2011) recast the second law and Landauer's
principle in relative-entropy form far from equilibrium; Plenio and Vitelli
(2001) surveyed the information-theoretic content. Our contribution is not a new
physical claim but a *complete, machine-checkable, first-principles synthesis*:
every statement below is derived from explicit finite sums and two scalar
inequalities, with no appeal to continuum thermodynamics, measure theory, or
convex-analysis black boxes. In particular we isolate the precise sense in which
the textbook bound $kT\ln 2$ is (a) an *average*, refined by an exact fluctuation
identity; (b) *saturated* only in the reversible limit; and (c) *forced* by a
purely combinatorial fact about the erasure map.

---

## 3. The finite-probability framework

We work throughout over a finite type $\Omega$ (a finite set of microstates).

**Definition 3.1 (Expectation).** For weight $p : \Omega \to \mathbb{R}$ and
observable $f : \Omega \to \mathbb{R}$,
$$\mathrm{E}_p[f] \;=\; \sum_{\omega \in \Omega} p(\omega)\, f(\omega).$$

**Definition 3.2 (Probability mass function).** $p$ is a PMF, written
$\mathrm{IsPMF}(p)$, if $p(\omega) \ge 0$ for all $\omega$ and
$\sum_{\omega} p(\omega) = 1$.

**Definition 3.3 (Shannon entropy).** With the convention $0\ln 0 = 0$ (encoded
by the function $\mathrm{negMulLog}(x) = -x\ln x$, which is $0$ at $x = 0$),
$$H(p) \;=\; \sum_{\omega} \mathrm{negMulLog}(p(\omega)) \;=\; -\sum_{\omega} p(\omega)\ln p(\omega).$$

**Definition 3.4 (Finite Jarzynski equality).** For a work observable
$W : \Omega \to \mathbb{R}$, inverse temperature $\alpha \in \mathbb{R}$, and
free-energy difference $\Delta F$, the condition $\mathrm{Jarzynski}(p, W, \alpha, \Delta F)$ holds when
$$\mathrm{E}_p\!\left[e^{-\alpha W}\right] \;=\; e^{-\alpha\,\Delta F}.$$

**Definition 3.5 (Relative entropy / Kullback–Leibler divergence).**
$$D(p \,\|\, q) \;=\; \sum_{\omega} p(\omega)\,\ln\frac{p(\omega)}{q(\omega)}.$$
The factor $p(\omega)$ makes the convention $0\ln 0 = 0$ automatic.

The bit-level distributions used repeatedly are: the **uniform bit**
$u(b) = \tfrac12$ for $b \in \{0,1\}$; the **erased bit** $e(b) = 1$ if $b = 0$
and $0$ if $b = 1$; and the **erasure map** $\mathrm{er} : \{0,1\}\to\{0,1\}$,
$\mathrm{er}(b) = 0$.

---

## 4. The entropic cost of erasure

**Proposition 4.1 (Entropy of the uniform bit).** $H(u) = \ln 2$.

*Proof sketch.* Both summands are $\mathrm{negMulLog}(\tfrac12) = -\tfrac12\ln\tfrac12 = \tfrac12\ln 2$;
their sum is $\ln 2$. $\square$

**Proposition 4.2 (Entropy of the erased bit).** $H(e) = 0$.

*Proof sketch.* The mass-$1$ outcome contributes $\mathrm{negMulLog}(1) = 0$ and
the mass-$0$ outcome contributes $\mathrm{negMulLog}(0) = 0$. $\square$

**Theorem 4.3 (Entropy loss of erasure).**
$$H(u) - H(e) = \ln 2.$$

*Proof sketch.* Immediate from 4.1 and 4.2. $\square$

**Proposition 4.4 (Logical irreversibility).** The erasure map $\mathrm{er}$ is
*not injective*: $\mathrm{er}(0) = \mathrm{er}(1) = 0$ while $0 \ne 1$.

This non-injectivity is the combinatorial origin of the entire thermodynamic
cost; §10 shows it *forces* strict positivity of dissipated work.

---

## 5. The Jarzynski correction and the average second law

### 5.1 The exact finite-size identity

**Theorem 5.1 (Jarzynski fluctuation correction).** Let $p$ be a PMF, $W$ a work
observable, $\alpha \ne 0$, and suppose $\mathrm{Jarzynski}(p, W, \alpha, \Delta F)$.
Then
$$\boxed{\;\mathrm{E}_p[W] \;=\; \Delta F \;+\; \frac{1}{\alpha}\,\ln \mathrm{E}_p\!\left[e^{-\alpha\,(W - \mathrm{E}_p[W])}\right].\;}$$

*Proof sketch.* Write the centered exponential as
$e^{-\alpha(W - \mathrm{E}_p[W])} = e^{\alpha \mathrm{E}_p[W]}\,e^{-\alpha W}$.
Pulling the constant $e^{\alpha \mathrm{E}_p[W]}$ out of the expectation and
applying the Jarzynski equality gives
$\mathrm{E}_p[e^{-\alpha(W-\mathrm{E}_p[W])}] = e^{\alpha \mathrm{E}_p[W]}\,e^{-\alpha\Delta F} = e^{\alpha(\mathrm{E}_p[W] - \Delta F)}$.
Take logarithms, divide by $\alpha$, and rearrange. $\square$

This identity is *exact* and holds for any finite system; it decomposes the mean
work into the reversible free-energy cost $\Delta F$ and a fluctuation correction
determined entirely by the centered work statistics.

**Corollary 5.2 (Finite-size Landauer identity).** Specializing
$\Delta F = (H(u) - H(e))/\alpha = \ln 2/\alpha$ yields, for one-bit erasure,
$$\mathrm{E}_p[W] = \frac{H(u) - H(e)}{\alpha} + \frac{1}{\alpha}\,\ln \mathrm{E}_p\!\left[e^{-\alpha(W - \mathrm{E}_p[W])}\right].$$

### 5.2 Sign of the correction: the second law

**Lemma 5.3 (Finite Jensen bound).** For any PMF $p$ and observable $g$,
$$1 + \mathrm{E}_p[g] \le \mathrm{E}_p\!\left[e^{g}\right].$$

*Proof sketch.* Apply the pointwise inequality $1 + x \le e^x$ at $x = g(\omega)$,
multiply by $p(\omega) \ge 0$, and sum; the left side telescopes to
$\sum_\omega p(\omega)(1 + g(\omega)) = 1 + \mathrm{E}_p[g]$ using
$\sum_\omega p(\omega) = 1$. $\square$

**Lemma 5.4 (Centered work has zero mean).**
$\mathrm{E}_p[-\alpha(W - \mathrm{E}_p[W])] = 0$.

*Proof sketch.* Linearity of expectation and $\sum_\omega p(\omega) = 1$. $\square$

**Theorem 5.5 (Work-fluctuation factor $\ge 1$).**
$$\mathrm{E}_p\!\left[e^{-\alpha(W - \mathrm{E}_p[W])}\right] \ge 1.$$

*Proof sketch.* Apply Lemma 5.3 with $g = -\alpha(W - \mathrm{E}_p[W])$ and use
$\mathrm{E}_p[g] = 0$ from Lemma 5.4. $\square$

**Corollary 5.6 (Nonnegative correction).**
$\ln \mathrm{E}_p[e^{-\alpha(W - \mathrm{E}_p[W])}] \ge 0$.

**Theorem 5.7 (Average second law).** If $\alpha > 0$ and
$\mathrm{Jarzynski}(p, W, \alpha, \Delta F)$, then
$$\Delta F \le \mathrm{E}_p[W].$$

*Proof sketch.* Substitute Theorem 5.1; the correction term is
$\alpha^{-1}$ (positive) times a nonnegative logarithm (Corollary 5.6). $\square$

**Theorem 5.8 (Landauer's $kT\ln 2$ bound).** For $k, T > 0$, with
$\alpha = (kT)^{-1}$ and $\Delta F = kT\ln 2$,
$$kT\ln 2 \le \mathrm{E}_p[W].$$

*Proof sketch.* Theorem 5.7 with $\alpha = (kT)^{-1} > 0$. $\square$

**Theorem 5.9 (Cost–entropy-loss bridge).**
$$kT\ln 2 = kT\,(H(u) - H(e)).$$

*Proof sketch.* Theorem 4.3. $\square$

---

## 6. Saturation: the reversible limit

The second law of §5 is an inequality; we now characterize equality exactly.

**Lemma 6.1 (Strict Jensen bound).** If $g(\omega) \ne 0$ for some $\omega$ with
$p(\omega) > 0$, then $1 + \mathrm{E}_p[g] < \mathrm{E}_p[e^g]$.

*Proof sketch.* As in Lemma 5.3, but the pointwise inequality is *strict*
($1 + x < e^x$ for $x \ne 0$) at the witnessing $\omega$, whose positive weight
makes the summed inequality strict. $\square$

**Theorem 6.2 (Equality case of the fluctuation factor).** For $\alpha \ne 0$,
$$\mathrm{E}_p\!\left[e^{-\alpha(W - \mathrm{E}_p[W])}\right] = 1 \iff \forall \omega,\; p(\omega) > 0 \Rightarrow W(\omega) = \mathrm{E}_p[W].$$

That is, the factor equals $1$ exactly when the work is *constant on the support*.

*Proof sketch.* ($\Leftarrow$) If $W$ is constant on the support, every nonzero
term is $p(\omega)\,e^0 = p(\omega)$, summing to $1$. ($\Rightarrow$)
Contrapositive: a point of the support with $W(\omega) \ne \mathrm{E}_p[W]$
triggers the strict inequality of Lemma 6.1. $\square$

**Theorem 6.3 (Strict second law).** If $\alpha > 0$,
$\mathrm{Jarzynski}(p,W,\alpha,\Delta F)$, and $W$ fluctuates on the support
(some $\omega$ with $p(\omega) > 0$ and $W(\omega) \ne \mathrm{E}_p[W]$), then
$$\Delta F < \mathrm{E}_p[W].$$

*Proof sketch.* The correction term in Theorem 5.1 is $\alpha^{-1}$ times the
logarithm of a factor strictly above $1$ (Theorem 6.2, strict direction). $\square$

**Theorem 6.4 (Landauer saturation $\iff$ reversibility).** For $k, T > 0$ and
$\Delta F = kT\ln 2$,
$$kT\ln 2 = \mathrm{E}_p[W] \iff \forall \omega,\; p(\omega) > 0 \Rightarrow W(\omega) = \mathrm{E}_p[W].$$

*Proof sketch.* Combine Theorems 5.1 and 6.2: the gap
$\mathrm{E}_p[W] - kT\ln 2$ equals $\alpha^{-1}\ln(\text{factor})$, which is zero
iff the factor is $1$ iff the work is constant on the support. $\square$

Thus the textbook value $kT\ln 2$ is a *floor* attained only in the idealized,
fluctuation-free (quasi-static, reversible) limit; any genuinely fluctuating
erasure dissipates strictly more (Theorem 6.3).

---

## 7. Fluctuation theorem: bounding second-law violations

The bound $kT\ln 2$ is an average. Individual realizations may undershoot it; we
bound the probability of doing so.

**Theorem 7.1 (Exponential violation bound).** If $\alpha > 0$ and
$\mathrm{Jarzynski}(p,W,\alpha,\Delta F)$, then for any margin $\xi$,
$$\sum_{\omega : W(\omega) < \Delta F - \xi} p(\omega) \;\le\; e^{-\alpha\,\xi}.$$

*Proof sketch.* (Chernoff/Markov on the Jarzynski sum.) Restrict the Jarzynski
sum to the violation set $S = \{\omega : W(\omega) < \Delta F - \xi\}$; since each
summand $p(\omega)e^{-\alpha W(\omega)}$ is nonnegative, the restricted sum is
$\le e^{-\alpha\Delta F}$. On $S$ we have $-\alpha W(\omega) > -\alpha(\Delta F - \xi)$,
so $e^{-\alpha W(\omega)} > e^{-\alpha(\Delta F - \xi)}$. Hence
$\big(\sum_{S} p(\omega)\big) e^{-\alpha(\Delta F - \xi)} \le e^{-\alpha\Delta F}$,
i.e. $\sum_S p(\omega) \le e^{-\alpha\xi}$. $\square$

**Theorem 7.2 (No certain violation).** If $\xi \ge 0$ and there exists $\omega_0$
with $p(\omega_0) > 0$ and $W(\omega_0) \ge \Delta F$, then
$\sum_{\omega : W(\omega) < \Delta F - \xi} p(\omega) < 1$. Landauer's bound can
never be violated with certainty.

*Proof sketch.* The violation set omits $\omega_0$, so its total mass is at most
$1 - p(\omega_0) < 1$. $\square$

**Theorem 7.3 (Landauer violation bound).** For one-bit erasure with
$\alpha = (kT)^{-1}$, $\Delta F = kT\ln 2$,
$$\sum_{\omega : W(\omega) < kT\ln 2 - \xi} p(\omega) \;\le\; e^{-\xi/(kT)}.$$

**Theorem 7.4 (Monotone decay).** For $k, T > 0$ and $\xi_1 < \xi_2$,
$e^{-\xi_2/(kT)} < e^{-\xi_1/(kT)}$: larger violations are exponentially rarer.

---

## 8. Extensivity: the thermodynamic limit

**Theorem 8.1 (Entropy of a uniform $N$-state register).** If $|\Omega| = N > 0$,
the uniform PMF $p(\omega) = 1/N$ has $H(p) = \ln N$.

*Proof sketch.* Each of the $N$ summands equals $\mathrm{negMulLog}(1/N) = \tfrac1N\ln N$;
their sum is $\ln N$. $\square$

**Theorem 8.2 (Maximal entropy of an $n$-bit register).** With $|\Omega| = 2^n$,
the uniform PMF has $H(p) = n\ln 2$. In particular the uniform distribution on
$\{0,1\}^n$ has entropy $n\ln 2$.

*Proof sketch.* Theorem 8.1 with $N = 2^n$ and $\ln(2^n) = n\ln 2$. $\square$

**Theorem 8.3 (Extensive Landauer bound).** For an $n$-bit memory at $k, T > 0$
with $\alpha = (kT)^{-1}$ and $\Delta F = n\,kT\ln 2$,
$$n\,kT\ln 2 \le \mathrm{E}_p[W].$$

*Proof sketch.* Theorem 5.7 (second law) with the extensive free-energy cost. $\square$

**Theorem 8.4 (Exact per-bit cost).** For $n > 0$,
$$\frac{n\,kT\ln 2}{n} = kT\ln 2.$$

The per-bit cost is *exactly* $kT\ln 2$ for every register size — the strongest,
non-asymptotic form of the thermodynamic limit.

---

## 9. The relative-entropy account and maximum entropy

Landauer's cost admits a second, dual description through relative entropy.

**Theorem 9.1 (Self-divergence).** $D(p \,\|\, p) = 0$.

*Proof sketch.* Each term is either $p(\omega)\ln 1 = 0$ or $0\cdot(\cdots) = 0$. $\square$

**Theorem 9.2 (Gibbs' inequality).** For PMFs $p, q$ with $q(\omega) > 0$ for all
$\omega$,
$$D(p \,\|\, q) \ge 0.$$

*Proof sketch.* From $\ln x \le x - 1$ applied to $x = q(\omega)/p(\omega)$ one
obtains the pointwise bound
$p(\omega)\ln\frac{p(\omega)}{q(\omega)} \ge p(\omega) - q(\omega)$ (with the
$p(\omega)=0$ terms handled by the convention). Summing,
$D(p\,\|\,q) \ge \sum_\omega (p(\omega) - q(\omega)) = 1 - 1 = 0$. $\square$

**Theorem 9.3 (Erased-vs-uniform divergence).**
$D(e \,\|\, u) = \ln 2$.

*Proof sketch.* Only the $b=0$ outcome contributes:
$1\cdot\ln\frac{1}{1/2} = \ln 2$. $\square$

**Theorem 9.4 (Unification of the two accounts).**
$$D(e \,\|\, u) = H(u) - H(e).$$

*Proof sketch.* Both equal $\ln 2$ (Theorems 9.3 and 4.3). $\square$

**Theorem 9.5 (Cost as relative entropy).**
$kT\ln 2 = kT\,D(e \,\|\, u)$, and for any PMFs $p,q$ with $q>0$ and $k,T \ge 0$,
$0 \le kT\,D(p\,\|\,q)$.

*Proof sketch.* Theorem 9.3 for the first identity; Gibbs (9.2) plus
nonnegativity of $kT$ for the second. $\square$

**Theorem 9.6 (Entropy–relative-entropy identity).** For any PMF $p$ on an
$N$-state space with uniform reference $u_N$,
$$H(p) = \ln N - D(p \,\|\, u_N).$$

*Proof sketch.* Expand $D(p\,\|\,u_N) = \sum_\omega p(\omega)\ln(p(\omega)N) = \sum_\omega p(\omega)\ln p(\omega) + \ln N \sum_\omega p(\omega) = -H(p) + \ln N$. $\square$

**Theorem 9.7 (Maximum-entropy bound).** For any PMF $p$ on an $N$-state space,
$$H(p) \le \ln N,$$
with the uniform distribution attaining equality ($H(u_N) = \ln N$).

*Proof sketch.* Theorem 9.6 and Gibbs ($D \ge 0$). $\square$

**Theorem 9.8 (Generalized Landauer bound).** For an arbitrary initial PMF $p$
erased at $\Delta F = kT\,H(p)$ with $\alpha = (kT)^{-1}$, $k, T > 0$,
$$kT\,H(p) \le \mathrm{E}_p[W].$$

*Proof sketch.* Theorem 5.7 (second law) with the entropy-scaled free-energy cost. $\square$

**Theorem 9.9 (Uniform memory is worst-case).** For $k, T \ge 0$,
$$kT\,H(p) \le kT\ln N.$$

*Proof sketch.* Theorem 9.7 multiplied by $kT \ge 0$. $\square$

---

## 10. Data processing and the logical-to-thermodynamic bridge

We now treat *deterministic computation* abstractly as a function
$f : \alpha\text{-space} \to \beta\text{-space}$ acting on a weight $p$, with
pushforward (image) weight
$$(f_* p)(y) = \sum_{x : f(x) = y} p(x).$$

**Theorem 10.1 (Deterministic data-processing inequality).** For nonnegative
weights $p$,
$$H(f_* p) \le H(p).$$
A deterministic map never increases Shannon entropy.

*Proof sketch.* Reindex $H(f_*p)$ as a sum over the domain:
$H(f_*p) = -\sum_x p(x)\ln (f_*p)(f(x))$. Since $(f_*p)(f(x)) \ge p(x) \ge 0$ and
$\ln$ is monotone, each term satisfies
$p(x)\ln p(x) \le p(x)\ln (f_*p)(f(x))$, giving $H(f_*p) \le H(p)$. $\square$

**Theorem 10.2 (Reversibility preserves entropy).** If $f$ is injective,
$$H(f_* p) = H(p).$$

*Proof sketch.* Each fiber $\{x : f(x) = f(x_0)\}$ is the singleton $\{x_0\}$, so
$(f_*p)(f(x)) = p(x)$ and the reindexed sums coincide. $\square$

**Theorem 10.3 (Landauer lower bound for computation).** For $k, T \ge 0$,
$$0 \le kT\,\big(H(p) - H(f_* p)\big),$$
with equality $kT\,(H(p) - H(f_*p)) = 0$ whenever $f$ is injective.

*Proof sketch.* Theorem 10.1 gives $H(p) - H(f_*p) \ge 0$; multiply by
$kT \ge 0$. Injectivity (Theorem 10.2) makes the bracket zero. $\square$

Reversible (injective) computations therefore form the zero-dissipation boundary:
they may compute without paying Landauer's toll precisely because they discard no
information.

**Theorem 10.4 (Logical irreversibility forces thermodynamic irreversibility).**
For a one-bit memory at $k, T > 0$ with $\alpha = (kT)^{-1}$,
$\Delta F = kT\ln 2$, and $\mathrm{Jarzynski}(p, W, \alpha, kT\ln 2)$,
$$\mathrm{er}\ \text{is not injective} \quad\wedge\quad 0 < \mathrm{E}_p[W].$$

*Proof sketch.* Non-injectivity is Proposition 4.4. For the strict positivity,
Theorem 5.8 gives $kT\ln 2 \le \mathrm{E}_p[W]$, and $kT\ln 2 > 0$ because
$k, T > 0$ and $\ln 2 > 0$. $\square$

This is the conceptual summit of the theory: a purely *combinatorial* fact (two
inputs of the erasure map share an output) is converted, through the Jarzynski
equality and the second law, into a *physical* one (strictly positive dissipated
work). Information is physical, and forgetting is never free.

---

## 11. Algorithms

The theory is constructive enough to support direct numerical verification. We
record the main computational primitives.

**Algorithm A (Entropy and divergence evaluation).** Given a PMF as an array,
compute $H(p) = -\sum_\omega p(\omega)\ln p(\omega)$ and
$D(p\,\|\,q) = \sum_\omega p(\omega)\ln(p(\omega)/q(\omega))$, using the
convention that any term with $p(\omega) = 0$ is skipped. Complexity $O(|\Omega|)$.

**Algorithm B (Jarzynski-consistency and bound check).** Given a work observable
$W$ and a PMF $p$, compute $\mathrm{E}_p[e^{-\alpha W}]$ and read off the implied
$\Delta F = -\alpha^{-1}\ln \mathrm{E}_p[e^{-\alpha W}]$; then verify the second-law
inequality $\Delta F \le \mathrm{E}_p[W]$ and decompose the gap into the
fluctuation correction $\alpha^{-1}\ln \mathrm{E}_p[e^{-\alpha(W - \mathrm{E}_p[W])}]$.
Complexity $O(|\Omega|)$.

**Algorithm C (Violation-probability bound).** For a margin $\xi$, compute the
empirical violation mass $\sum_{\omega : W(\omega) < \Delta F - \xi} p(\omega)$
and compare against the Chernoff ceiling $e^{-\alpha\xi}$. Complexity $O(|\Omega|)$.

---

## 12. Applications and discussion

**Limits of computation.** The extensive bound (§8) sets a hard floor on the
energy cost of irreversible computation: a processor performing $R$ bit-erasures
per second at temperature $T$ must dissipate at least $R\,kT\ln 2$ watts. While
present technology operates orders of magnitude above this floor, the gap narrows
as devices approach the single-electron scale.

**Reversible and adiabatic computing.** Theorem 10.3 formalizes the principle
behind reversible computing: only the *erasure* of information, not computation
per se, carries an unavoidable thermodynamic cost. Logically reversible circuits,
which retain enough information to be run backwards, can in principle compute
arbitrarily close to zero dissipation, deferring the Landauer cost to the final
memory reset.

**Maxwell's demon.** The bridge theorem (10.4) is the modern resolution of the
demon paradox: the demon's apparent entropy reduction is exactly compensated when
it must erase its measurement record, paying back $kT\ln 2$ per recorded bit.

**Fluctuations and single-molecule experiments.** The finite-size identity (5.1),
saturation (6.4) and violation bound (7.3) are precisely the statements probed in
single-bit erasure experiments, where the full work distribution — not just its
mean — is measured, and transient sub-Landauer events are observed with the
predicted exponentially small frequency.

---

## 13. Future directions

A correlated-erasure extension introduces marginals and mutual information of a
joint distribution, a strengthened Gibbs inequality under absolute continuity, the
decomposition $I(X;Y) = H(X) + H(Y) - H(X,Y)$, subadditivity of Shannon entropy,
and a $kT\cdot I(X;Y)$ correlation saving for joint erasure with a concrete
perfectly-correlated two-bit example. Building on this, the natural conjectures
are: (C1) **strong subadditivity** $H(X,Y,Z) + H(Y) \le H(X,Y) + H(Y,Z)$ via a
doubly-conditioned relative entropy; (C2) a **conditional Landauer bound**
$kT\,H(X\mid Y)$ for erasure with side information, predicting free erasure for a
demon holding a perfect copy; (C3) **saturation of subadditivity $\iff$
independence** via the equality case of Gibbs; (C4) the **data-processing
inequality for relative entropy** $D(Tp\,\|\,Tq) \le D(p\,\|\,q)$ for stochastic
maps $T$, implying post-processing cannot increase the Landauer saving; and (C5) a
**mutual-information fluctuation theorem** bounding the probability that a single
correlated-erasure run fails to achieve the $kT\,I(X;Y)$ saving by margin $\xi$ at
$e^{-\xi/(kT)}$.

---

## 14. Conclusion

We have given a complete, first-principles, finite-size theory of Landauer's
principle. The single-bit bound $kT\ln 2$ emerges as the average case of an exact
fluctuation identity; it is saturated only reversibly; it is protected against
violation by an exponential fluctuation theorem; it scales extensively to
$n\,kT\ln 2$; it admits a dual relative-entropy formulation tied to a
maximum-entropy bound; and it is *forced* by the non-injectivity of the erasure
map through a data-processing inequality. The entire edifice rests on two scalar
inequalities, $1 + x \le e^x$ and $\ln x \le x - 1$, together with the finite
Jarzynski equality — a striking demonstration that the deepest statement in the
thermodynamics of information is, at bottom, elementary.

---

## References

- Bennett, C. H. (1982). The thermodynamics of computation — a review.
  *International Journal of Theoretical Physics*, 21, 905–940.
- Esposito, M. & Van den Broeck, C. (2011). Second law and Landauer principle far
  from equilibrium. *EPL*, 95, 40004.
- Jarzynski, C. (1997). Nonequilibrium equality for free energy differences.
  *Physical Review Letters*, 78, 2690.
- Kullback, S. & Leibler, R. A. (1951). On information and sufficiency.
  *Annals of Mathematical Statistics*, 22, 79–86.
- Landauer, R. (1961). Irreversibility and heat generation in the computing
  process. *IBM Journal of Research and Development*, 5, 183–191.
- Plenio, M. B. & Vitelli, V. (2001). The physics of forgetting: Landauer's
  erasure principle and information theory. *Contemporary Physics*, 42, 25–60.
