# Perturbation Theory on Theory-Space: A Meta-Theorem on the Unreasonable Effectiveness of Wrong Theories

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We develop a quantitative theory of *approximate correctness* for physical theories, in which a theory is an assignment of real predictions to phenomena and its deviation from the truth is organised as a convergent power series in a coupling parameter. Within this framework we prove a meta-theorem: for every approximately correct theory and every accuracy threshold $\eta > 0$ there is a coupling window $|\varepsilon| < \delta$, chosen independently of any competitor, on which the approximate theory strictly outpredicts *every* rival theory on the entire class of phenomena where that rival's error is at least $\eta$. We show that this class is nonempty whenever the rival is inexact anywhere, and that nowhere-exact theories are dense in theory space, so the hypothesis is generic rather than exceptional.

We then analyse the internal structure of wrongness. The tower of finite-order truncations of a perturbative theory — each of which is *knowingly* wrong, discarding infinitely many corrections — is shown to be strictly ordered by predictive accuracy on a common punctured coupling window: whenever the $M$-th correction is nonvanishing, every truncation of order $N > M$ strictly beats the $M$-th, and orders $0,\dots,K$ form a strict chain. This is the precise sense in which the wrongness of an approximately correct theory forms a convergent series *toward* the truth, monotonically in order and not merely in the limit.

Both main theorems are proved sharp. We exhibit an approximately correct theory that, at coupling $\varepsilon = 1/2$, is beaten by a crude and itself-wrong constant rival; and a two-term family for which, at $\varepsilon = 1$, the first-order truncation is strictly *worse* than the zeroth-order one. Thus "higher order is always better" and "the meta-theorem holds at every coupling" are both false, with explicit counterexamples, and both windows are explicit and quantitative.

Finally we establish three structural results on comparative adequacy: an *epistemic half-space theorem* (for any two distinct predictions, the set of possible worlds in which one beats the other is a nonempty, open, unbounded half-line, so predictive inferiority is never intrinsic); a *Condorcet cycle* of three theories on three phenomena, showing that majority empirical adequacy is not transitive and hence that comparative closeness-to-truth admits no consistent global ranking; and a construction of a sequence of theories, every one of which is wrong at every phenomenon, whose errors nevertheless converge uniformly to zero, reconciling the pessimistic meta-induction with convergent realism. Wilson's two-loop anomalous dimension at the Wilson–Fisher fixed point is treated as a worked instance.

**Keywords:** perturbation theory, theory-space, approximate correctness, truncation hierarchy, epistemology of science, Condorcet cycle, $\varepsilon$-expansion, convergent series.

---

## 1. Introduction

### 1.1 The phenomenon

Newtonian gravitation is false, and it is used to navigate spacecraft. The Bohr model is false, and it reproduces the hydrogen spectrum to four significant figures. The ideal gas law is false, and it designs refrigerators. Every truncated loop expansion in quantum field theory is false *by construction* — its author can name the infinitely many terms discarded — and such truncations constitute essentially all of the quantitative predictive content of the Standard Model.

The pattern is so pervasive that it has become a proverb ("all models are wrong, but some are useful") rather than an object of study. Our aim here is to make it an object of study: to identify a class of "approximately correct" theories, define predictive superiority precisely, and prove theorems delimiting exactly when and where an acknowledged falsehood outperforms its rivals.

### 1.2 The framework in one paragraph

We model a theory as a function from a set of phenomena to the reals, and the truth as another such function. An *approximately correct* theory is a member of a one-parameter family deforming the truth, whose deviation is a power series in a coupling $\varepsilon$ with geometrically bounded coefficients — uniformly across all phenomena. This deviation we call the *wrongness*. Convergence of the wrongness series, with a Cauchy-type bound uniform in the phenomenon, is the analytic engine driving everything else: it converts "the theory is nearly right" from a vague claim into a quantitative one with the correct order of quantifiers, and the meta-theorem then follows by comparing a small quantity to a bounded-below one.

### 1.3 Contributions

1. A definition of a perturbative family of theories with a uniform Cauchy bound, and quantitative convergence of the associated wrongness series (§2).
2. The meta-theorem on the unreasonable effectiveness of wrong theories, with the strong quantifier order in which the coupling window precedes the choice of rival, together with nonemptiness and genericity results (§3).
3. Structural results on comparative adequacy: the epistemic half-space theorem, the Condorcet obstruction to global rankings, optimality of every theory in some world, and the compatibility of universal falsity with uniform convergence (§4).
4. The wrongness hierarchy: two-sided tail estimates and the strict ordering of the tower of truncations (§5).
5. Sharpness: explicit counterexamples showing both main theorems fail outside their windows (§6).
6. A worked instance from critical phenomena: the two-loop $\varepsilon$-expansion (§7).

---

## 2. Perturbative theory-space and the wrongness series

### 2.1 Basic definitions

Throughout, $\Phi$ is an arbitrary set, whose elements we call **phenomena**. No structure on $\Phi$ is assumed; the results are uniform in $\Phi$, which is one of the points of the framework.

> **Definition 2.1 (Theory).** A *theory* on $\Phi$ is a function $T : \Phi \to \mathbb{R}$. We think of $T(p)$ as the numerical prediction the theory makes for the measurable quantity $p$.

> **Definition 2.2 (Perturbative family).** A *perturbative family of theories* over $\Phi$ consists of:
> - a *truth* function $t : \Phi \to \mathbb{R}$;
> - correction coefficients $a_n : \Phi \to \mathbb{R}$ for $n \in \mathbb{N}$;
> - constants $B \ge 0$ (the *bound*) and $r \ge 0$ (the *ratio*),
>
> subject to the **uniform Cauchy estimate**
> $$|a_n(p)| \;\le\; B\,r^{\,n} \qquad \text{for all } n \in \mathbb{N},\ p \in \Phi.$$

The estimate is precisely the classical Cauchy bound for the Taylor coefficients of a function analytic in a disc of radius $1/r$, imposed *uniformly in the phenomenon*. Thus a perturbative family is a germ of an analytic deformation of the truth, with $p$ as a spectator parameter, and $1/r$ is a lower bound for the radius of convergence valid at every phenomenon simultaneously.

> **Definition 2.3 (Wrongness, prediction, truncation).** For a perturbative family $T$, a coupling $\varepsilon \in \mathbb{R}$ and a phenomenon $p$, put
> $$w_n(\varepsilon,p) = a_n(p)\,\varepsilon^{\,n+1}, \qquad W(\varepsilon,p) = \sum_{n=0}^\infty w_n(\varepsilon,p),$$
> and define the *prediction* and the *$N$-th order truncation*
> $$T_\varepsilon(p) = t(p) + W(\varepsilon,p), \qquad T^{(N)}_\varepsilon(p) = t(p) + \sum_{n<N} w_n(\varepsilon,p).$$
> The quantity $W(\varepsilon,p)$ is the **wrongness** of the theory at $\varepsilon$ and $p$; by construction $T_\varepsilon(p) - t(p) = W(\varepsilon,p)$.

Note that the series begins at $\varepsilon^1$: at zero coupling the family is exactly true. The wrongness is thus a deformation that switches off with the coupling, which is the mathematical content of "approximately correct".

> **Definition 2.4 (Error and superiority).** For theories $T, C$ and a truth $t$, the *prediction error* is $E(T,p) = |T(p) - t(p)|$. We say $T$ **beats** $C$ at $p$, written $T \succ_p C$, if $E(T,p) < E(C,p)$. The *superiority region* is
> $$\mathrm{Sup}(T, C) = \{p \in \Phi : T \succ_p C\}.$$

Superiority is irreflexive ($T \not\succ_p T$) and asymmetric ($T \succ_p C$ implies $C \not\succ_p T$), being the pullback of the strict order on $\mathbb{R}$ along the error map. It is *not*, as §4.2 shows, aggregable into a transitive global relation.

### 2.2 Convergence of wrongness

> **Lemma 2.5 (Termwise geometric domination).** $|w_n(\varepsilon,p)| \le (B|\varepsilon|)\,(r|\varepsilon|)^n$ for all $n, p, \varepsilon$.
>
> *Proof.* $|w_n| = |a_n(p)|\,|\varepsilon|^{n+1} \le B r^n |\varepsilon|^{n+1} = (B|\varepsilon|)(r|\varepsilon|)^n$. $\square$

> **Proposition 2.6 (Absolute convergence).** If $r|\varepsilon| < 1$ then $\sum_n w_n(\varepsilon,p)$ converges absolutely for every $p$.
>
> *Proof.* Comparison with the convergent geometric series $\sum_n (B|\varepsilon|)(r|\varepsilon|)^n$, using Lemma 2.5. $\square$

> **Theorem 2.7 (Quantitative convergence of wrongness).** For $r|\varepsilon| < 1$ and every $p \in \Phi$,
> $$|W(\varepsilon,p)| \;\le\; \frac{B\,|\varepsilon|}{1 - r|\varepsilon|}.$$
>
> *Proof sketch.* By the triangle inequality for absolutely convergent series, $|W| \le \sum_n |w_n|$; by Lemma 2.5 and termwise comparison this is at most $\sum_n (B|\varepsilon|)(r|\varepsilon|)^n$, which sums to $B|\varepsilon|/(1 - r|\varepsilon|)$. $\square$

The essential feature is that the right-hand side contains no reference to $p$. The bound is uniform over the entire space of phenomena — over every experiment anyone might ever perform.

> **Theorem 2.8 (Uniform smallness of wrongness).** For every $\eta > 0$ there exists $\delta > 0$ such that
> $$|\varepsilon| < \delta \;\Longrightarrow\; |W(\varepsilon,p)| < \eta \quad \text{for all } p \in \Phi.$$
> One may take explicitly
> $$\delta = \min\!\left\{\frac{1}{2(r+1)},\ \frac{\eta}{2(B+1)}\right\}.$$
>
> *Proof sketch.* The first entry forces $r|\varepsilon| \le 1/2$, hence $1 - r|\varepsilon| \ge 1/2$, so Theorem 2.7 gives $|W| \le 2B|\varepsilon|$. The second entry forces $(B+1)|\varepsilon| < \eta/2$, hence $2B|\varepsilon| < \eta$. The additive $+1$'s make the expressions well-defined and positive even in the degenerate cases $B = 0$ or $r = 0$. $\square$

Equivalently, $\varepsilon \mapsto W(\varepsilon,p)$ tends to $0$ as $\varepsilon \to 0$, for each fixed $p$, and does so at a rate independent of $p$.

### 2.3 Asymptotic order of truncations

> **Definition 2.9.** A function $f : \mathbb{R} \to \mathbb{R}$ *vanishes to order $k$ at zero* if there are $C > 0$ and $\delta > 0$ with $|f(\varepsilon)| \le C|\varepsilon|^k$ whenever $|\varepsilon| < \delta$.

> **Lemma 2.10 (Tail bound).** For $r|\varepsilon| < 1$,
> $$\Big| W(\varepsilon,p) - \sum_{n<N} w_n(\varepsilon,p) \Big| \;\le\; \frac{B\,|\varepsilon|^{N+1} r^{N}}{1 - r|\varepsilon|}.$$
>
> *Proof sketch.* Split off the first $N$ terms; the remainder is $\sum_{m \ge 0} w_{m+N}$, and $|w_{m+N}| \le (B|\varepsilon|^{N+1}r^N)(r|\varepsilon|)^m$. Sum the geometric majorant. $\square$

> **Theorem 2.11 (Order of the truncation error).** For every $p$ and $N$, the function $\varepsilon \mapsto T_\varepsilon(p) - T^{(N)}_\varepsilon(p)$ vanishes to order $N+1$ at zero; explicitly, for $|\varepsilon| < 1/(2(r+1))$,
> $$\big|T_\varepsilon(p) - T^{(N)}_\varepsilon(p)\big| \;\le\; 2(B+1)(r+1)^N |\varepsilon|^{N+1}.$$
>
> *Proof sketch.* The window forces $1 - r|\varepsilon| \ge 1/2$; feed this into Lemma 2.10 and enlarge $B r^N$ to $(B+1)(r+1)^N$. $\square$

Thus a truncation is a theory whose deliberate wrongness is exactly of the order it advertises.

### 2.4 Linear structure

Perturbative families may be added and rescaled. Given families $T, S$, define $T \oplus S$ by adding truths and coefficients, with bound $B_T + B_S$ and ratio $\max(r_T, r_S)$; the Cauchy estimate is preserved since $r_T^n, r_S^n \le \max(r_T,r_S)^n$. Given $c \in \mathbb{R}$, define $c \odot T$ by scaling truth and coefficients, with bound $|c| B_T$ and the same ratio.

> **Proposition 2.12 (Linearity of wrongness).** Whenever the relevant series converge ($r_T|\varepsilon| < 1$ and $r_S|\varepsilon| < 1$),
> $$W_{T \oplus S}(\varepsilon,p) = W_T(\varepsilon,p) + W_S(\varepsilon,p), \qquad T_\varepsilon \oplus S_\varepsilon = T_\varepsilon + S_\varepsilon,$$
> and for any $c$, $W_{c \odot T}(\varepsilon,p) = c\, W_T(\varepsilon,p)$.
>
> *Proof sketch.* Termwise identities plus additivity and homogeneity of absolutely convergent sums. $\square$

Wrongness is therefore a *linear functional* on perturbative theory-space, which is what licenses the superposition arguments familiar from physical perturbation theory.

---

## 3. The meta-theorem

### 3.1 Statement and proof

> **Theorem 3.1 (Unreasonable effectiveness of wrong theories).** Let $T$ be a perturbative family with truth $t$, and let $\eta > 0$. Then there exists $\delta > 0$ such that for every coupling $\varepsilon$ with $|\varepsilon| < \delta$, every theory $C : \Phi \to \mathbb{R}$, and every phenomenon $p$ with $E(C,p) \ge \eta$, we have
> $$T_\varepsilon \succ_p C.$$
>
> *Proof.* Choose $\delta$ by Theorem 2.8 for the tolerance $\eta$. For $|\varepsilon| < \delta$ we have $E(T_\varepsilon, p) = |T_\varepsilon(p) - t(p)| = |W(\varepsilon,p)| < \eta \le E(C,p)$. $\square$

The proof is short; the content is in the quantifier order. The window $\delta$ is produced **before** the competitor $C$ and the phenomenon $p$ are named, and depends only on the internal data $(B, r)$ of the approximate theory and on the threshold $\eta$. In particular a single window works simultaneously against the class of *all* theories on $\Phi$ — a class of cardinality $2^{|\Phi|}$ or larger, containing every theory ever proposed and every theory that ever will be.

It is worth being explicit about what is *not* claimed. The theorem does not say $T_\varepsilon$ is true; generically $W(\varepsilon,p) \ne 0$ and it is false everywhere. It does not say $T_\varepsilon$ beats $C$ everywhere; on the set where $C$ happens to be very accurate, $C$ may well win. It says exactly that the region of $C$'s badness is a region of $T_\varepsilon$'s comparative goodness, and it identifies that region concretely.

> **Corollary 3.2 (Bad sets are superiority regions).** For every $\eta > 0$ there is $\delta > 0$ such that for all $|\varepsilon| < \delta$ and all theories $C$,
> $$\{p : E(C,p) \ge \eta\} \;\subseteq\; \mathrm{Sup}(T_\varepsilon, C).$$

> **Corollary 3.3 (Nonempty superiority region).** If $C(p_0) \ne t(p_0)$ for some $p_0$, then there is $\delta > 0$ such that $\mathrm{Sup}(T_\varepsilon, C) \ne \emptyset$ for all $|\varepsilon| < \delta$; indeed $p_0 \in \mathrm{Sup}(T_\varepsilon, C)$.
>
> *Proof.* Apply Theorem 3.1 with $\eta = E(C, p_0) > 0$. $\square$

### 3.2 The hypothesis is generic

Corollary 3.3 requires the rival to be inexact somewhere. One might worry this is restrictive. It is not.

> **Theorem 3.4 (Genericity of nowhere-exactness).** Let $\Phi$ be countable, let $T$ be any theory, $t$ any truth, and $\delta > 0$. Then there exists $c$ with $0 < c < \delta$ such that
> $$T(p) + c \ne t(p) \qquad \text{for every } p \in \Phi.$$
>
> *Proof.* The set $\mathcal{B} = \{\,t(p) - T(p) : p \in \Phi\,\}$ of "bad" shifts is the image of a countable set, hence countable. The interval $(0,\delta)$ has the cardinality of the continuum and is therefore not contained in $\mathcal{B}$. Any $c \in (0,\delta) \setminus \mathcal{B}$ works. $\square$

So an arbitrarily small perturbation makes any theory wrong at *every* phenomenon: nowhere-exact theories are dense in theory-space. Being exactly right somewhere is a measure-zero accident; the hypotheses of the meta-theorem describe the typical case.

### 3.3 Disagreement forces error

> **Proposition 3.5.** For any theories $T, C$, any truth $t$, and any $p$,
> $$|T(p) - C(p)| \;\le\; E(T,p) + E(C,p).$$
>
> *Proof.* $T(p) - C(p) = (T(p)-t(p)) - (C(p)-t(p))$; apply the triangle inequality. $\square$

Contrapositively: if two theories disagree by $D$ at a phenomenon, then whatever the truth, at least one of them errs by at least $D/2$ there. Scientific controversy is a lower bound on collective ignorance, and the bound is truth-independent — it can be computed by an observer who knows nothing about the world.

---

## 4. The structure of comparative adequacy

The meta-theorem describes when a fixed theory wins. This section examines what kind of relation "wins" is.

### 4.1 The epistemic half-space theorem

Fix a phenomenon and consider two predictions $a \ne b$ made there. Varying the unknown truth $t \in \mathbb{R}$ over all *possible worlds*, when does $a$ beat $b$?

> **Lemma 4.1.** For all $a, b, t \in \mathbb{R}$,
> $$|t - a| < |t - b| \iff (b-a)\,(2t - a - b) < 0.$$
>
> *Proof.* Both sides of the first inequality are nonnegative, so it is equivalent to $(t-a)^2 < (t-b)^2$; expanding and rearranging gives $0 < (b-a)(a+b-2t)$, i.e. $(b-a)(2t-a-b) < 0$. $\square$

> **Theorem 4.2 (Epistemic half-space theorem).** For $a \ne b$, the set of worlds
> $$\mathcal{W}(a \succ b) = \{t \in \mathbb{R} : |t-a| < |t-b|\}$$
> is open, contains $a$, and is unbounded: for every $M$ there is $t \in \mathcal{W}(a \succ b)$ with $|t| > M$.
>
> *Proof sketch.* By Lemma 4.1 the set is $\{t : (b-a)(2t-a-b) < 0\}$, the preimage of the open ray $(-\infty,0)$ under a nonconstant affine map, hence an open half-line. It contains $t = a$ since $|a-a| = 0 < |a - b|$. If $a < b$ the half-line is $t < (a+b)/2$ and is unbounded below; if $b < a$ it is $t > (a+b)/2$ and unbounded above. In either case witnesses of arbitrarily large modulus exist. $\square$

The moral: **predictive inferiority is never intrinsic to a theory.** Any theory that makes a definite prediction is optimal in an unbounded, open family of worlds — in particular in the world where it is exactly right, and in all worlds on that side of the midpoint. Superiority is a relation between a theory, a rival, and a world; it cannot be predicated of a theory alone. This generalises:

> **Theorem 4.3 (Every theory is optimal in some world).** Let $(F_i)_{i \in I}$ be a family of theories and $p$ a phenomenon at which $F_j(p) \ne F_i(p)$ for all $j \ne i$. Then there is a truth function $t$ such that $F_i \succ_p F_j$ for every $j \ne i$.
>
> *Proof.* Take $t = F_i$. Then $E(F_i,p) = 0$ while $E(F_j,p) = |F_j(p) - F_i(p)| > 0$ for $j \ne i$. $\square$

### 4.2 The Condorcet obstruction

Given that superiority is pointwise, the natural way to compare theories globally is to aggregate over phenomena. Say $X$ **majority-beats** $Y$ if $X$ beats $Y$ on a majority of phenomena. This relation is not transitive.

> **Theorem 4.4 (Condorcet cycle in theory-space).** Let $\Phi = \{p_1,p_2,p_3\}$, let the truth be $t \equiv 0$, and let
> $$A = (1,2,3), \qquad B = (2,3,1), \qquad C = (3,1,2)$$
> (listing the predictions at $p_1,p_2,p_3$; since $t = 0$ these are also the errors). Then $A$ majority-beats $B$, $B$ majority-beats $C$, and $C$ majority-beats $A$.
>
> *Proof.* $A$ beats $B$ at $p_1$ ($1 < 2$) and $p_2$ ($2 < 3$). $B$ beats $C$ at $p_1$ ($2<3$) and $p_3$ ($1 < 2$). $C$ beats $A$ at $p_2$ ($1 < 2$) and $p_3$ ($2 < 3$). Each is a $2$-out-of-$3$ majority. $\square$

> **Proposition 4.5.** $A$ does *not* majority-beat $C$: it wins only at $p_1$ ($1 < 3$), losing at $p_2$ ($2 > 1$) and $p_3$ ($3 > 2$).

> **Corollary 4.6 (Non-transitivity of empirical adequacy).** Majority empirical adequacy is not transitive: $A$ majority-beats $B$ and $B$ majority-beats $C$, yet $A$ does not majority-beat $C$. In particular it is not a preorder, and there is no linear ordering of theories by "closeness to truth" compatible with majority comparison over phenomena.

This is a genuine structural obstruction, of exactly Arrovian type. Any aggregation of pointwise errors into a total order on theory-space must sacrifice either transitivity or independence of the individual phenomena. The practical consequence is that **comparative adequacy should be modelled as a directed graph on theory-space, with cycles permitted, rather than as an order**. Debates about which of several theories is "closer to the truth" may be not merely unresolved but formally unresolvable, in the same way that a three-way election may have no Condorcet winner.

Note the contrast with Theorem 3.1: the meta-theorem escapes the obstruction precisely because it never aggregates. It compares one theory to one rival at one phenomenon, and the region on which it asserts victory is specified by an explicit, checkable condition on the rival.

### 4.3 Universal falsity is compatible with convergence

> **Theorem 4.7 (Pessimistic meta-induction is compatible with convergence).** For any truth $t : \Phi \to \mathbb{R}$ there exists a sequence of theories $(F_k)_{k \in \mathbb{N}}$ such that
> 1. $F_k(p) \ne t(p)$ for **every** $k$ and **every** $p$ — each theory is wrong at every phenomenon; and
> 2. the errors converge uniformly to zero: for every $\eta > 0$ there is $K$ with $E(F_k, p) < \eta$ for all $k \ge K$ and all $p$.
>
> *Proof.* Take $F_k = t + \frac{1}{k+1}$. Then $E(F_k,p) = \frac{1}{k+1} > 0$ for all $p$, giving (1); and given $\eta > 0$, choose $K > 1/\eta$, so that for $k \ge K$ we have $\frac{1}{k+1} < \frac{1}{K} < \eta$, giving (2). $\square$

The *pessimistic meta-induction* argues that since every past scientific theory has turned out to be false, present theories are probably false too, and therefore should not be believed. Theorem 4.7 shows the inference from "all false" to "no convergence" is invalid: a history consisting entirely of falsehoods is fully consistent with uniform convergence on the truth. Falsity is a binary predicate; approximate correctness is a magnitude; the meta-induction conflates them.

---

## 5. The wrongness hierarchy

We now turn from comparing a theory to external rivals, to comparing a theory to *itself at different orders*. Physicists do not sum perturbation series; they truncate them. Each truncation $T^{(N)}_\varepsilon$ is knowingly wrong. The question is whether the tower
$$T^{(0)}_\varepsilon,\; T^{(1)}_\varepsilon,\; T^{(2)}_\varepsilon,\; \dots$$
is ordered by predictive accuracy relative to the exact prediction $T_\varepsilon$.

### 5.1 Tails

> **Definition 5.1.** The *$N$-th tail* is $R_N(\varepsilon,p) = W(\varepsilon,p) - \sum_{n<N} w_n(\varepsilon,p)$: exactly the part of the correction discarded by the $N$-th truncation.

> **Lemma 5.2 (Truncation error is the tail).** $E\big(T^{(N)}_\varepsilon, p\big) = |R_N(\varepsilon,p)|$, where the error is measured against the exact prediction $T_\varepsilon$.
>
> *Proof.* $T^{(N)}_\varepsilon(p) - T_\varepsilon(p) = -R_N(\varepsilon,p)$; take absolute values. $\square$

> **Lemma 5.3 (Tail recursion).** $R_N = w_N + R_{N+1}$.
>
> *Proof.* Immediate from $\sum_{n<N+1} = \sum_{n<N} + w_N$. $\square$

The recursion is the whole mechanism: *the error of a truncation is its first neglected term plus the error of the next truncation.* If the first neglected term dominates, the ordering of errors is determined by the ordering of first neglected terms, which decrease geometrically.

> **Proposition 5.4 (Two-sided tail estimates).** Suppose $r|\varepsilon| \le 1/2$. Then
> $$\underbrace{|a_N(p)|\,|\varepsilon|^{N+1} \;-\; 2B\,r^{N+1}|\varepsilon|^{N+2}}_{\text{lower}} \;\le\; |R_N(\varepsilon,p)| \;\le\; \underbrace{2B\,r^{N}|\varepsilon|^{N+1}}_{\text{upper}}.$$
>
> *Proof sketch.* Upper: from Lemma 2.10 with $1 - r|\varepsilon| \ge 1/2$. Lower: by Lemma 5.3, $|w_N| = |R_N - R_{N+1}| \le |R_N| + |R_{N+1}|$, so $|R_N| \ge |w_N| - |R_{N+1}| \ge |a_N(p)||\varepsilon|^{N+1} - 2Br^{N+1}|\varepsilon|^{N+2}$ by the upper bound applied at order $N+1$. $\square$

The gap between the two bounds is one order in $\varepsilon$, which is exactly enough room for the next theorem.

### 5.2 Strict improvement

> **Theorem 5.5 (Wrongness hierarchy theorem).** Let $p$ be a phenomenon with $a_M(p) \ne 0$, and let $N > M$. Then there is $\delta > 0$ such that for every $\varepsilon$ with $0 < |\varepsilon| < \delta$,
> $$E\big(T^{(N)}_\varepsilon, p\big) \;<\; E\big(T^{(M)}_\varepsilon, p\big),$$
> the errors being measured against the exact prediction $T_\varepsilon$. One may take
> $$\delta = \min\left\{1,\ \frac{1}{2(r+1)},\ \frac{c}{2B\,(r^N + r^{M+1}) + 1}\right\}, \qquad c = |a_M(p)|.$$
>
> *Proof sketch.* The first two entries put the coupling in the half-disc $r|\varepsilon| \le 1/2$ and ensure $|\varepsilon| < 1$, so that $|\varepsilon|^{N+1} \le |\varepsilon|^{M+2}$ (as $N + 1 \ge M+2$). The third entry gives the decisive linear inequality
> $$|\varepsilon| \cdot 2B\,(r^N + r^{M+1}) < c .$$
> By Proposition 5.4, the finer truncation satisfies $|R_N| \le 2Br^N|\varepsilon|^{N+1} \le 2Br^N|\varepsilon|^{M+2}$, and the coarser one satisfies $|R_M| \ge c|\varepsilon|^{M+1} - 2Br^{M+1}|\varepsilon|^{M+2}$. It therefore suffices that
> $$2Br^N|\varepsilon|^{M+2} \;<\; c|\varepsilon|^{M+1} - 2Br^{M+1}|\varepsilon|^{M+2},$$
> i.e., dividing by $|\varepsilon|^{M+1} > 0$, that $|\varepsilon| \cdot 2B(r^N + r^{M+1}) < c$ — which is the decisive inequality. $\square$

The form of $\delta$ is instructive: it is (up to the harmless $+1$ regularisers) the ratio
$$\delta \;\sim\; \frac{\text{signal: the first term the coarse theory neglects}}{\text{noise: the geometric mass of what both theories neglect}}.$$
Higher order improves prediction exactly while the newly captured term outweighs everything still missing. This is the quantitative form of the physicist's instinct that a perturbative expansion is trustworthy while successive corrections are shrinking.

### 5.3 The tower as a strict chain

> **Theorem 5.6 (Uniform window for consecutive steps).** Let $K \in \mathbb{N}$ and suppose $a_M(p) \ne 0$ for all $M < K$. Then there is a single $\delta > 0$ such that for all $0 < |\varepsilon| < \delta$ and all $M < K$,
> $$E\big(T^{(M+1)}_\varepsilon, p\big) < E\big(T^{(M)}_\varepsilon, p\big).$$
>
> *Proof sketch.* Induction on $K$, taking at each stage the minimum of the inductively obtained window and the window supplied by Theorem 5.5 for the step $M = K$. Finitely many minima remain positive. $\square$

> **Theorem 5.7 (The tower is totally ordered).** Under the hypotheses of Theorem 5.6, there is a single $\delta > 0$ such that for all $0 < |\varepsilon| < \delta$ and all $M < N \le K$,
> $$E\big(T^{(N)}_\varepsilon, p\big) < E\big(T^{(M)}_\varepsilon, p\big).$$
>
> *Proof sketch.* Induction on $N$ using Theorem 5.6 and transitivity of $<$ on $\mathbb{R}$. $\square$

This is the precise version of the informal claim that *"the wrongness of an approximately correct theory forms a convergent series toward truth"*. Convergence alone (Theorem 2.8) only says the limit is right. Theorem 5.7 says the approach is **strictly monotone in the order of approximation**, on one common window: the successive knowing falsehoods of the perturbative tower are linearly ordered by empirical adequacy, each strictly better than all its predecessors.

Note the necessary exclusion of $\varepsilon = 0$. At zero coupling every truncation is exactly correct, and all the inequalities collapse to equalities. Strict improvement is a statement about the *punctured* window.

---

## 6. Sharpness: the windows are real

Both main theorems are stated inside a coupling window. We now show the windows are not artefacts of the proofs. The counterexamples use the *binomial family*: over a one-point phenomenon space with truth $0$, take $a_0 = \alpha$, $a_1 = \beta$, and $a_n = 0$ for $n \ge 2$, with bound $B = |\alpha| + |\beta|$ and ratio $r = 1$. Its wrongness series terminates:
$$W(\varepsilon) = \alpha\varepsilon + \beta\varepsilon^2 .$$

### 6.1 The meta-theorem needs its window

> **Theorem 6.1 (Sharpness of the meta-theorem).** There exist a perturbative family $T$, a coupling $\varepsilon$, a rival theory $C$, and a phenomenon $p$ such that $C(p) \ne t(p)$ — so $C$ is itself wrong — and yet $T_\varepsilon$ does **not** beat $C$ at $p$.
>
> *Proof.* Take the binomial family with $\alpha = 1, \beta = 0$, so $T_\varepsilon = \varepsilon$ around the truth $t = 0$; take the constant rival $C \equiv 1/4$ and $\varepsilon = 1/2$. Then $E(T_{1/2}) = 1/2$ while $E(C) = 1/4 < 1/2$. $\square$

At a coupling of size $1/2$ — not enormous — an approximately correct theory is beaten by a crude constant guess with no theoretical warrant whatsoever. The conclusion of Theorem 3.1 therefore genuinely fails without the restriction $|\varepsilon| < \delta$: it cannot be strengthened to "at every coupling". Physically, this is the fate of a perturbative calculation pushed to strong coupling: it becomes *worse than a rough phenomenological guess*.

### 6.2 Higher order is not always better

> **Theorem 6.2 (Sharpness of the hierarchy theorem).** There exist a perturbative family $T$, a coupling $\varepsilon$, and a phenomenon $p$ with $a_0(p) \ne 0$, such that
> $$E\big(T^{(0)}_\varepsilon, p\big) \;<\; E\big(T^{(1)}_\varepsilon, p\big),$$
> i.e. the *higher* truncation is strictly worse.
>
> *Proof.* Take the binomial family with $\alpha = 1, \beta = -3$, so $W(\varepsilon) = \varepsilon - 3\varepsilon^2$, and set $\varepsilon = 1$. Then $R_0 = W(1) = -2$ and $R_1 = W(1) - a_0\varepsilon = -2 - 1 = -3$. By Lemma 5.2 the errors are $|R_0| = 2$ and $|R_1| = 3$, so the first-order truncation errs by $3$ and the zeroth by $2$. $\square$

Adding a correction made the prediction worse. So Theorem 5.5 cannot be upgraded to a global statement; monotone improvement along the tower is a genuinely small-coupling phenomenon. This too has an exact physical counterpart: in strongly coupled regimes, and in asymptotic (divergent) series generally, increasing the loop order past a critical point degrades the prediction.

### 6.3 What the failures teach

Both failures have the same shape — *true inside a window, false outside it* — and in both cases the window is explicit and computable from the data $(B, r, \eta)$ or $(B, r, |a_M(p)|, N, M)$. The framework is therefore not merely a qualitative apologia for approximate theories; it is a criterion. Given the Cauchy data of an expansion and a threshold, one can compute the coupling range within which the guarantees hold, and outside which one is relying on luck.

---

## 7. Worked instance: the two-loop $\varepsilon$-expansion

The framework applies verbatim to one of the central computations of modern statistical physics. In the Wilson–Fisher analysis of critical phenomena, one studies scalar field theory in $d = 4 - \varepsilon$ dimensions; the interacting fixed point of the renormalisation-group flow exists at a coupling of order $\varepsilon$, and the anomalous dimension of the field at that fixed point is, at two loops,
$$\eta(\varepsilon) = \frac{\varepsilon^2}{54} + O(\varepsilon^3).$$

Viewed as a perturbative family over a one-point phenomenon space with truth $0$, this is exactly the binomial family with $a_0 = 0$, $a_1 = 1/54$:
$$W(\varepsilon) = 0 \cdot \varepsilon + \frac{1}{54}\varepsilon^2 = \eta(\varepsilon).$$

> **Theorem 7.1 (The meta-theorem for the $\varepsilon$-expansion).** For every accuracy threshold $\eta_0 > 0$ there exists $\delta > 0$ such that for every $\varepsilon$ with $|\varepsilon| < \delta$ and every rival theory $C$ whose error exceeds $\eta_0$, the two-loop prediction $\varepsilon^2/54$ beats $C$.
>
> *Proof.* Immediate from Theorem 3.1 applied to the family above, after identifying $T_\varepsilon$ with $\varepsilon \mapsto \varepsilon^2/54$. $\square$

Three observations. First, the two-loop formula *is* a knowingly wrong theory: infinitely many terms of the expansion are discarded, and the full series is in fact believed to be divergent (asymptotic). Second, the meta-theorem nonetheless certifies its superiority over all sufficiently-inaccurate rivals in a window near four dimensions. Third — and this is where §6 earns its keep — the physically interesting case is $\varepsilon = 1$ (three dimensions), which is *not* inside any small window; that the extrapolated formula still yields critical exponents accurate to a few percent for real fluids and magnets is a piece of good fortune that the present theorems do not explain and do not claim to.

---

## 8. Algorithms

The framework is effective: every window in the paper is given by a closed-form expression in the data. Three computational procedures follow.

### 8.1 Window computation for the meta-theorem

**Input:** bound $B$, ratio $r$, threshold $\eta$. **Output:** $\delta$ with the property of Theorem 3.1.
$$\delta = \min\left\{\frac{1}{2(r+1)},\ \frac{\eta}{2(B+1)}\right\}.$$
Cost: $O(1)$ arithmetic operations. Correctness is Theorem 2.8.

### 8.2 Window computation for the hierarchy

**Input:** $B$, $r$, $c = |a_M(p)|$, orders $M < N$. **Output:** $\delta$ as in Theorem 5.5:
$$\delta = \min\left\{1,\ \frac{1}{2(r+1)},\ \frac{c}{2B(r^N + r^{M+1}) + 1}\right\}.$$
Cost: $O(\log N)$ by fast exponentiation. For a chain of orders $0,\dots,K$ take the minimum over the $K$ consecutive steps, at cost $O(K \log K)$.

### 8.3 Superiority-region membership

**Input:** finitely many phenomena with rival predictions $C(p)$ and truths $t(p)$; a threshold $\eta$; a perturbative family and a coupling in the window. **Output:** the certified subset of phenomena on which the approximate theory wins.

The certified set is $\{p : |C(p) - t(p)| \ge \eta\}$, computable in $O(|\Phi|)$ evaluations without ever evaluating the approximate theory — the meta-theorem does the work. Comparing to the *actual* superiority region (which requires evaluating $W$) exhibits the certified set as a subset, quantifying how conservative the certificate is.

---

## 9. Discussion

### 9.1 What the framework explains

The framework locates the effectiveness of wrong theories in three distinct places.

*Uniformity.* The Cauchy bound is uniform in the phenomenon, so accuracy is bought across the whole domain of application at once. This is what allows the coupling window to be chosen before the rival, and it is why an approximate theory functions as a general-purpose instrument rather than a collection of fits.

*Locality of comparison.* Superiority is pointwise; the meta-theorem never needs to claim global dominance, only dominance where the rival is bad. This side-steps the Condorcet obstruction of §4.2 entirely.

*Order structure of truncation.* The tail recursion $R_N = w_N + R_{N+1}$ organises deliberate falsehoods into a strictly improving chain. This is why "compute one more order" is a rational research strategy despite every order being wrong.

### 9.2 Limitations

The Cauchy bound $|a_n(p)| \le Br^n$ excludes the *asymptotic* series with factorially growing coefficients, $|a_n| \sim n!\,r^n$, that occur throughout quantum field theory. For these there is no radius of convergence, the tower cannot improve forever, and the correct statement must involve an optimal truncation order — see §10.

The error functional is the absolute pointwise deviation. Realistic comparisons weight phenomena by experimental precision and involve vector-valued or distributional predictions. The half-space theorem generalises readily (a hyperplane bisector in a normed space); the Condorcet obstruction can only get worse.

Finally, the framework says nothing about *explanation*, *unification*, or *ontological correctness*. It is a theory of predictive accuracy, and its central negative result — that predictive superiority does not aggregate into a global ranking — should be read as a reason to expect that predictive accuracy alone cannot ground theory choice.

### 9.3 Relation to philosophy of science

Three classical positions receive precise counterparts here. *Instrumentalism*: the meta-theorem is an instrumentalist theorem par excellence — it certifies performance while remaining silent on truth. *Convergent realism*: Theorems 2.8 and 5.7 give the convergence such realism needs, without ever requiring a theory to be true. *The pessimistic meta-induction*: Theorem 4.7 shows the inference from universal past falsity to non-convergence is invalid. And Theorem 4.2 supplies a fourth: no theory is unconditionally inferior, so the appraisal of a theory is irreducibly a joint appraisal of theory and world.

---

## 10. Future work

**Asymptotic-series regime: optimal truncation.** For families with only a factorially divergent bound $|a_n| \le B\, n!\, r^n$, we conjecture a truncation order $N^*(\varepsilon) \asymp 1/(r|\varepsilon|)$ such that $T^{(N^*)}_\varepsilon$ beats every truncation of order $N \ne N^*(\varepsilon)$, with error exponentially small, $O(\exp(-1/(r|\varepsilon|)))$. The mechanism is visible already: the decisive inequality in Theorem 5.5 reverses once coefficient growth beats geometric decay, so the strict chain of Theorem 5.7 must *terminate* at a computable order rather than continue forever. All the analytic ingredients — the two-sided tail estimates of Proposition 5.4 — are stated for arbitrary coefficient bounds; only the geometric majorant needs replacing by a factorial one.

**Measure-theoretic effectiveness.** Equip the space of worlds (truth functions on a finite phenomenon set of size $k$) with Lebesgue measure on a bounded box. We conjecture that for any two distinct theories the set of worlds in which one majority-beats the other has strictly positive measure, and that for odd $k$ the two majority regions have measures summing to the total. The half-space theorem already exhibits each pointwise favouring set as an open half-line, so each majority region is a finite union of intersections of half-spaces — a polyhedral set whose measure is in principle computable.

**Directed-graph semantics for adequacy.** Given the Condorcet obstruction, comparative adequacy should be studied as a tournament on theory-space. Natural questions: which tournaments arise from error profiles; what the length distribution of cycles is; whether a Copeland- or Kemeny-style score can be justified as a canonical scalarisation.

**Windows as a research heuristic.** The explicit windows suggest a diagnostic for ongoing calculations: given estimated Cauchy data, compute the coupling range in which the next order is guaranteed to improve matters, and compare with the physical coupling of interest.

---

## Appendix: Summary of results

| Result | Statement |
|---|---|
| Quantitative convergence | $\vert W(\varepsilon,p)\vert \le B\vert\varepsilon\vert/(1 - r\vert\varepsilon\vert)$ for $r\vert\varepsilon\vert<1$, uniformly in $p$ |
| Uniform smallness | $\forall \eta>0\ \exists \delta>0$: $\vert\varepsilon\vert<\delta \Rightarrow \vert W(\varepsilon,p)\vert<\eta$ for all $p$ |
| Meta-theorem | $\forall \eta>0\ \exists\delta>0\ \forall \vert\varepsilon\vert<\delta\ \forall C\ \forall p$: $E(C,p)\ge\eta \Rightarrow T_\varepsilon \succ_p C$ |
| Nonempty superiority | $C$ inexact somewhere $\Rightarrow$ superiority region nonempty in a window |
| Genericity | Over countable $\Phi$, arbitrarily small shifts make a theory nowhere exact |
| Disagreement bound | $\vert T(p)-C(p)\vert \le E(T,p)+E(C,p)$ |
| Half-space theorem | $\{t : \vert t-a\vert<\vert t-b\vert\}$ is open, nonempty, unbounded for $a\ne b$ |
| Optimality in some world | Every pairwise-distinct member of a family is strictly best in some world |
| Condorcet cycle | $A=(1,2,3)$, $B=(2,3,1)$, $C=(3,1,2)$ cycle under majority beating |
| Non-transitivity | Majority empirical adequacy is not a preorder |
| Meta-induction | A uniformly-false sequence of theories can converge uniformly to truth |
| Two-sided tails | $\vert a_N\vert\vert\varepsilon\vert^{N+1} - 2Br^{N+1}\vert\varepsilon\vert^{N+2} \le \vert R_N\vert \le 2Br^N\vert\varepsilon\vert^{N+1}$ |
| Hierarchy theorem | $a_M(p)\ne0$, $N>M$ $\Rightarrow$ $T^{(N)}$ beats $T^{(M)}$ on a punctured window |
| Strict chain | Orders $0,\dots,K$ totally ordered by accuracy on one common window |
| Sharpness (meta) | At $\varepsilon=1/2$, $T_\varepsilon=\varepsilon$ is beaten by the wrong constant $1/4$ |
| Sharpness (hierarchy) | For $\varepsilon-3\varepsilon^2$ at $\varepsilon=1$, order $1$ is worse than order $0$ |
| $\varepsilon$-expansion | $\eta(\varepsilon)=\varepsilon^2/54$ is a perturbative family; the meta-theorem applies |
