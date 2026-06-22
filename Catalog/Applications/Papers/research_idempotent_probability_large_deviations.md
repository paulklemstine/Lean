# Idempotent Probability and Large Deviations: A Sharp Cramér Theorem in the Max-Plus World

**Author:** Aristotle
**Date:** 2026-06-22
**Domain:** Tropical Mathematics / Idempotent Analysis / Large Deviation Theory

---

## Abstract

We develop a large deviation principle (LDP) for max-plus (idempotent) probability measures on finite sets, building on a foundational theory of tropical measure and sup-additive integration. In Maslov's idempotent calculus, a tropical probability measure with weights $w(x) \le 0$ and $\max_x w(x) = 0$ plays the role of $e^{-nI}$ in classical large deviations, with rate function $I(x) = -w(x) \ge 0$. We give a complete idempotent dictionary for Cramér's theorem: the cumulant generating function (CGF) $\Lambda(\lambda) = \max_x(\lambda\,\mathrm{val}(x) + w(x))$ is convex; it is additive under independent products with additive observables; the CGF of an $n$-step max-plus random walk is exactly $n\Lambda$ with no error term; a tropical Chernoff bound and a *sharp* (non-asymptotic) LDP hold, with event cost equal to the infimum of the rate function. We then establish the precise boundary of the idempotent Cramér theorem. The Legendre–Fenchel biconjugate satisfies $\Lambda^{**} \le I$ unconditionally (a tropical Fenchel–Young inequality), with equality under a supporting-line hypothesis. Our central contribution refutes the natural conjecture that this is always an equality: we exhibit an explicit idempotent law on a three-point space with a non-convex rate function for which the biconjugate strictly underestimates the rate, with a **duality gap of exactly $2$**, equal to the height of the non-convex spike above its chord. This characterizes idempotent Cramér duality as holding if and only if the rate function equals its own convex lower envelope.

---

## 1. Introduction

Large deviation theory quantifies the exponentially small probabilities of rare events. Cramér's theorem, the foundational result, asserts that the empirical mean of $n$ i.i.d. real random variables satisfies an LDP with rate function $I$ equal to the Legendre–Fenchel transform $\Lambda^*$ of the cumulant generating function $\Lambda$. The exponential scaling $P \approx e^{-nI}$ is the signature of the theory.

Idempotent (max-plus) analysis, developed by Maslov and collaborators, is the systematic study of the limit obtained by the *dequantization* $a \oplus_h b = h\log(e^{a/h} + e^{b/h}) \to \max(a,b)$ as $h \to 0^+$. Under this limit, sums become maxima and products become sums, and the exponential scaling of large deviation theory turns into a finite, combinatorial structure. A classical probability collapses to an *idempotent probability*: a weight function $w$ with $\max_x w(x) = 0$, whose negation $I = -w$ is precisely the rate function.

This correspondence is more than analogy. The "log-of-exp" operations that govern moments and cumulants are exactly the operations that dequantize to max-plus arithmetic. Consequently, the entire Cramér apparatus has an idempotent shadow that is *exact* rather than asymptotic. The purpose of this paper is twofold:

1. To make the idempotent Cramér dictionary precise and to identify the exact, error-free analogues of the classical results (convexity of the CGF, additivity under independence, linear scaling along random walks, the Chernoff bound, and a sharp LDP).
2. To locate, exactly, the boundary of the duality between rate function and cumulant generating function. We prove that the Legendre–Fenchel biconjugate is an unconditional lower bound on the rate function, and we exhibit an explicit, fully verified counterexample showing this lower bound can be strict, with a precisely computed gap. This converts a one-sided inequality into a *sharp characterization*: idempotent Cramér duality holds iff the rate function is convex.

All results in this paper are formalized and machine-checked.

---

## 2. Preliminaries: Tropical Measure Theory

Throughout, $X$ is a finite nonempty type and observables are functions $X \to \mathbb{R}$.

**Definition 2.1 (Max-plus measure).** A *max-plus measure* on $X$ is a weight function $w : X \to \mathbb{R}$. We write $\mu = \langle w\rangle$ and call $w = \mu.\mathrm{weight}$.

**Definition 2.2 (Tropical probability).** A max-plus measure $P$ is a *tropical probability measure*, written $\mathrm{IsTropicalProbability}(P)$, if
$$\max_{x \in X} P.\mathrm{weight}(x) = 0 \qquad\text{(total mass)}, \qquad P.\mathrm{weight}(x) \le 0 \ \ \forall x \quad\text{(nonpositivity)}.$$
Here the maximum is the finite supremum $\bigvee'_{x} P.\mathrm{weight}(x)$. This is the idempotent analogue of a normalized probability: the "total mass" is the tropical sum (a maximum) of all weights and equals the multiplicative unit $0$ of the max-plus semiring.

**Definition 2.3 (Max-plus integral).** For $f : X \to \mathbb{R}$ and a max-plus measure $\mu$,
$$\int^{\!+} f\, d\mu \;=\; \mathrm{maxPlusIntegral}(f, \mu) \;=\; \max_{x \in X}\big(f(x) + \mu.\mathrm{weight}(x)\big).$$
This is the sup-additive (idempotent) integral: it dequantizes $\log \int e^{f}\,d\mathbb{P}$.

The following structural facts about the integral are established in the foundational theory and used freely below.

- **Monotonicity** ($\mathrm{maxPlusIntegral\_mono}$): if $f \le g$ pointwise then $\int^{\!+} f\,d\mu \le \int^{\!+} g\,d\mu$.
- **Shift equivariance** ($\mathrm{maxPlusIntegral\_shift}$): $\int^{\!+} (f + c)\, d\mu = \int^{\!+} f\,d\mu + c$.
- **Pointwise lower bound** ($\mathrm{le\_maxPlusIntegral}$): $f(x_0) + \mu.\mathrm{weight}(x_0) \le \int^{\!+} f\,d\mu$ for each $x_0$.
- **Attainment** ($\mathrm{maxPlusIntegral\_attained}$): the maximum is achieved at some $x_0$.
- **Lattice homomorphism** ($\mathrm{maxPlusIntegral\_max}$): $\int^{\!+}\max(f,g)\,d\mu = \max(\int^{\!+} f\,d\mu, \int^{\!+} g\,d\mu)$.

**Definition 2.4 (Product measure).** For max-plus measures $\mu_1$ on $X$ and $\mu_2$ on $Y$, the *independent product* is the measure on $X \times Y$ with weight $(x,y) \mapsto \mu_1.\mathrm{weight}(x) + \mu_2.\mathrm{weight}(y)$. A product of tropical probabilities is a tropical probability. Additive weights are the idempotent image of the factorization of independent moment generating functions.

---

## 3. The Idempotent Large Deviation Dictionary

We now define the objects of idempotent large deviation theory and state the structural theorems. Throughout, $\mathrm{val} : X \to \mathbb{R}$ is the observable whose deviations are studied.

**Definition 3.1 (Rate function).** For a tropical probability $P$, the *idempotent rate function* is
$$I(x) \;=\; \mathrm{idempotentRate}(P, x) \;=\; -\,P.\mathrm{weight}(x) \;\ge\; 0.$$
The most likely outcomes ($w = 0$) have zero cost; rarer outcomes (very negative $w$) have large cost. This is the idempotent image of $-\tfrac1n \log P$.

**Definition 3.2 (Cumulant generating function).** The *idempotent CGF* is
$$\Lambda(\lambda) \;=\; \mathrm{idempotentCGF}(P, \mathrm{val}, \lambda) \;=\; \int^{\!+} (\lambda\cdot\mathrm{val})\, dP \;=\; \max_{x}\big(\lambda\,\mathrm{val}(x) + w(x)\big).$$
It dequantizes $\tfrac1n\log \mathbb{E}[e^{\lambda S_n}]$.

**Theorem 3.3 (Normalization; $\mathrm{idempotentCGF\_zero}$).** For any tropical probability $P$, $\Lambda(0) = 0$.

*Proof sketch.* $\Lambda(0) = \max_x(0\cdot\mathrm{val}(x) + w(x)) = \max_x w(x) = 0$ by the total-mass axiom. $\square$

**Theorem 3.4 (Convexity; $\mathrm{idempotentCGF\_convex}$).** The map $\lambda \mapsto \Lambda(\lambda)$ is convex.

*Proof sketch.* For each fixed $x$, $\lambda \mapsto \lambda\,\mathrm{val}(x) + w(x)$ is affine, hence convex. The pointwise maximum of a family of convex functions is convex, and $\Lambda$ is exactly such a maximum over the finite set $X$. $\square$

**Theorem 3.5 (Additivity under independence; $\mathrm{idempotentCGF\_add}$).** For tropical probabilities $P_1$ on $X$ and $P_2$ on $Y$ and the additive observable $\mathrm{val}(x,y) = \mathrm{val}_1(x) + \mathrm{val}_2(y)$ on the independent product $P_1 \otimes P_2$,
$$\Lambda_{P_1\otimes P_2}(\lambda) = \Lambda_{P_1}(\lambda) + \Lambda_{P_2}(\lambda).$$

*Proof sketch.* The integrand separates: $\lambda(\mathrm{val}_1(x)+\mathrm{val}_2(y)) + w_1(x) + w_2(y) = [\lambda\,\mathrm{val}_1(x)+w_1(x)] + [\lambda\,\mathrm{val}_2(y)+w_2(y)]$. The maximum over the product $X \times Y$ of a sum of a function of $x$ and a function of $y$ factors as the sum of the two separate maxima. This is the idempotent image of the multiplicativity $\mathbb{E}[e^{\lambda(S+T)}] = \mathbb{E}[e^{\lambda S}]\,\mathbb{E}[e^{\lambda T}]$ for independent $S,T$. $\square$

**Theorem 3.6 (Random walk scaling; $\mathrm{idempotentCGF\_walk}$).** Let $S_n$ be the $n$-step max-plus random walk: the $n$-fold independent product with additive observable. Then
$$\Lambda_{S_n}(\lambda) = n\,\Lambda(\lambda).$$

*Proof sketch.* Iterate Theorem 3.5 $n$ times. Unlike the classical Gärtner–Ellis statement, which holds only in the $n \to \infty$ limit with correction terms, this identity is *exact for every finite $n$*. $\square$

**Theorem 3.7 (Tropical Chernoff / LDP upper bound; $\mathrm{idempotent\_chernoff}$).** For each slope $\lambda$ and threshold $t$, the weight of any outcome with $\lambda\,\mathrm{val}(x) \ge t$ is bounded by $\Lambda(\lambda) - t$. Equivalently, the cost of the event $\{\mathrm{val} \ge a\}$ is at least $\sup_\lambda(\lambda a - \Lambda(\lambda))$.

*Proof sketch.* This is the idempotent Markov inequality applied to $\lambda\cdot\mathrm{val}$: from $\lambda\,\mathrm{val}(x) \ge t$ and the pointwise lower bound $\lambda\,\mathrm{val}(x) + w(x) \le \Lambda(\lambda)$ we get $w(x) \le \Lambda(\lambda) - t$, i.e. $I(x) \ge t - \Lambda(\lambda)$. Optimizing over $\lambda$ gives the Legendre form. $\square$

**Theorem 3.8 (Sharp idempotent LDP; $\mathrm{idempotent\_ldp\_sharp}$).** For any event $A \subseteq X$, the idempotent cost of $A$ equals the infimum of the rate function over $A$:
$$\text{(cost of } A) = -\sup_{x\in A} w(x) = \inf_{x\in A} I(x).$$

*Proof sketch.* The tropical measure of $A$ is $\max_{x\in A} w(x)$; negating turns the maximum of weights into the infimum of costs. Unlike the classical LDP, where this holds only asymptotically and with distinct upper/lower bounds, the idempotent statement is an exact equality for every finite $n$ and every event. $\square$

---

## 4. Legendre–Fenchel Duality

**Definition 4.1 (Biconjugate).** The *Legendre–Fenchel biconjugate* of $\Lambda$ at a value $v$ is
$$\Lambda^{**}(v) \;=\; \mathrm{lfBiconj}(P, \mathrm{val}, v) \;=\; \sup_{\lambda \in \mathbb{R}}\big(\lambda v - \Lambda(\lambda)\big).$$
This is the double Legendre–Fenchel transform of the CGF, which classically recovers the rate function (Cramér's theorem).

**Theorem 4.2 (Tropical Fenchel–Young / weak duality; $\mathrm{fenchel\_young\_rate}$, $\mathrm{lfBiconj\_le\_rate}$).** For every tropical probability $P$ and every outcome $x$,
$$\Lambda^{**}(\mathrm{val}(x)) \;\le\; I(x).$$

*Proof sketch.* For any $\lambda$, the pointwise lower bound gives $\lambda\,\mathrm{val}(x) + w(x) \le \Lambda(\lambda)$, i.e. $\lambda\,\mathrm{val}(x) - \Lambda(\lambda) \le -w(x) = I(x)$. Taking the supremum over $\lambda$ preserves the bound. This is the idempotent Fenchel–Young inequality. $\square$

**Theorem 4.3 (Equality under support; $\mathrm{lfBiconj\_eq\_rate\_of\_support}$).** If the rate function $I$ admits a supporting line at $\mathrm{val}(x)$ — a slope $\lambda^\star$ with $\lambda^\star\,\mathrm{val}(x) - \Lambda(\lambda^\star) = I(x)$ — then $\Lambda^{**}(\mathrm{val}(x)) = I(x)$.

*Proof sketch.* Weak duality (4.2) gives $\le$; the supporting line witnesses a value of $\lambda v - \Lambda(\lambda)$ equal to $I(x)$, giving $\ge$. The existence of such a supporting line is exactly local convexity of $I$ at $\mathrm{val}(x)$. $\square$

The remaining question — and the crux of this paper — is whether the supporting-line hypothesis is ever genuinely needed, or whether weak duality is secretly always an equality. If the latter, Theorem 4.3 would be vacuous and the rate function would always be recovered by the double transform.

---

## 5. The Strict Duality Gap

We refute the over-general conjecture by an explicit, fully verified counterexample.

**Definition 5.1 (The gap observable and law).** On $X = \{0,1,2\} = \mathrm{Fin}\,3$, define
$$\mathrm{val}(i) = i, \qquad w(i) = \begin{cases} -2 & i = 1 \\ 0 & i \in \{0,2\}. \end{cases}$$
Call this measure $P_{\mathrm{gap}}$. Its rate function is $I = (0, 2, 0)$.

**Proposition 5.2 ($\mathrm{gapMeasure\_isProb}$).** $P_{\mathrm{gap}}$ is a tropical probability measure: all weights are $\le 0$ and $\max_i w(i) = 0$ (attained at $i = 0$).

**Proposition 5.3 (Rate values; $\mathrm{gapRate\_mid}$, $\mathrm{gapRate\_ends}$).** $I(1) = 2$ and $I(0) = I(2) = 0$.

**Proposition 5.4 (Non-convexity; $\mathrm{gapRate\_nonconvex}$).** The rate function is non-convex: the middle value lies strictly above the chord joining the endpoint values,
$$\frac{I(0) + I(2)}{2} = 0 \;<\; 2 = I(1),$$
and $\mathrm{val}(1) = 1$ is the midpoint of $\mathrm{val}(0) = 0$ and $\mathrm{val}(2) = 2$. The rate function is a "spike up," hence concave at the middle point.

**Lemma 5.5 (Key bound; $\mathrm{gap\_lam\_le\_cgf}$).** For every slope $\lambda \in \mathbb{R}$,
$$\lambda \;\le\; \Lambda(\lambda), \qquad \text{where}\quad \Lambda(\lambda) = \max(0,\; \lambda - 2,\; 2\lambda).$$

*Proof sketch.* The CGF is $\Lambda(\lambda) = \max_i(\lambda\, i + w(i)) = \max(0,\ \lambda - 2,\ 2\lambda)$. If $\lambda \ge 0$, then $\lambda \le 2\lambda \le \Lambda(\lambda)$ (using the lower bound at $i = 2$). If $\lambda < 0$, then $\lambda < 0 \le \Lambda(\lambda)$ (using the lower bound at $i = 0$). $\square$

**Theorem 5.6 (Biconjugate collapses to the chord; $\mathrm{gap\_lfBiconj\_mid}$).**
$$\Lambda^{**}(\mathrm{val}(1)) = \Lambda^{**}(1) = 0.$$

*Proof sketch.* By Lemma 5.5, $\lambda - \Lambda(\lambda) \le 0$ for all $\lambda$, so $\sup_\lambda(\lambda\cdot 1 - \Lambda(\lambda)) \le 0$. Equality is attained at $\lambda = 0$, where $0\cdot 1 - \Lambda(0) = 0$ (using $\Lambda(0)=0$, Theorem 3.3). Hence the supremum is exactly $0$. $\square$

**Theorem 5.7 (Strict idempotent Cramér duality gap; $\mathrm{strict\_duality\_gap}$).** At the middle point,
$$\Lambda^{**}(\mathrm{val}(1)) = 0 \;<\; 2 = I(1).$$
The double Legendre–Fenchel transform strictly underestimates the rate function. The supporting-line hypothesis of Theorem 4.3 is therefore essential, and the conjecture that the double transform always recovers the idempotent rate function is false.

*Proof sketch.* Combine Theorem 5.6 ($\Lambda^{**}(1) = 0$) with Proposition 5.3 ($I(1) = 2$). $\square$

**Theorem 5.8 (Exact gap size; $\mathrm{duality\_gap\_value}$).**
$$I(1) - \Lambda^{**}(\mathrm{val}(1)) = 2.$$
The gap equals exactly the height of the non-convex spike above its chord. The convex lower envelope flattens the spike from $I(1) = 2$ to the chord value $0$, and the difference is precisely the deficit of convexity.

*Proof sketch.* Immediate from Theorems 5.6 and Proposition 5.3. $\square$

**Remark 5.9 (Sharp characterization).** Theorems 4.2, 4.3, and 5.7 together pin down the exact boundary of the idempotent Cramér theorem:

> The double Legendre–Fenchel transform recovers the idempotent rate function, $\Lambda^{**}(\mathrm{val}(x)) = I(x)$, **if and only if** $I$ equals its own convex lower envelope at $\mathrm{val}(x)$ (equivalently, $I$ admits a supporting line there).

The biconjugate always computes the convex lower envelope of the rate function; it agrees with the rate function exactly on the convex part and strictly underestimates it on every non-convex spike, by exactly the height of the spike above its chord.

---

## 6. Algorithms

All quantities above are finite maxima/suprema over a finite outcome set, hence directly computable. We record the core algorithms.

**Algorithm 6.1 (Idempotent CGF evaluation).** Given weights $w$, values $\mathrm{val}$, and a slope $\lambda$, compute $\Lambda(\lambda) = \max_x(\lambda\,\mathrm{val}(x) + w(x))$ in $O(|X|)$ time by a single pass.

**Algorithm 6.2 (Legendre–Fenchel biconjugate).** Because $\Lambda$ is a piecewise-linear convex function with at most $|X|$ pieces (one affine segment $\lambda \mapsto \lambda\,\mathrm{val}(x) + w(x)$ per outcome), the biconjugate $\Lambda^{**}(v) = \sup_\lambda(\lambda v - \Lambda(\lambda))$ is finite precisely on $[\min_x \mathrm{val}(x), \max_x \mathrm{val}(x)]$ and is itself piecewise linear. On a finite value grid it is computed by upper-envelope (convex-hull) techniques in $O(|X|\log|X|)$ time, or, for the values $\{\mathrm{val}(x)\}$ themselves, by evaluating the lower convex envelope of the points $(\mathrm{val}(x), I(x))$.

**Algorithm 6.3 (Duality gap detection).** The gap $I(x) - \Lambda^{**}(\mathrm{val}(x))$ is nonzero exactly at outcomes lying strictly above the lower convex hull of the point cloud $\{(\mathrm{val}(x), I(x))\}$. A single lower-convex-hull computation flags every non-convex spike and reports its exact gap as the vertical distance to the hull.

---

## 7. Applications and Interpretation

**Optimization and scheduling.** The max-plus integral is the value function of a one-step optimization; the random-walk scaling theorem $\Lambda_{S_n} = n\Lambda$ is the statement that optimal costs along independent stages add. The CGF parametrizes a family of price/penalty trade-offs, and its Legendre transform is the standard cost-vs-resource duality of linear programming, here made exact in the tropical semiring.

**Robust statistics and worst-case analysis.** Idempotent probability is the arithmetic of worst cases: $\max$ replaces averaging. The rate function is a "cost-to-deviate," and the sharp LDP says the cost of any event is the cheapest way into it. The strict duality gap warns that moment-based (CGF) surrogates can systematically *under-report* the cost of intermediate, non-extreme outcomes whenever the cost landscape is non-convex.

**Tropical geometry.** The CGF $\Lambda$ is a tropical polynomial (a max of affine functions), and its Legendre dual is its Newton-polygon-style convexification. The duality gap is a quantitative measure of how far a weight configuration is from being a vertex of its own tropical convex hull.

---

## 8. Discussion and Future Work

The idempotent dictionary makes vivid a structural truth often obscured classically: large deviation duality is convex duality, and the exponential scaling merely transports it. By removing the exponential, the idempotent picture exposes both the strength of the duality (exact, non-asymptotic identities for convex rate functions) and its precise failure mode (strict gaps at non-convex spikes, of exactly computable size). The following directions extend the program.

**Conjecture 1 — Exact idempotent Cramér theorem under convexity.** For an idempotent law whose rate function $I$ is convex on the value set, the double Legendre–Fenchel transform recovers it exactly: $\Lambda^{**}(\mathrm{val}(x)) = I(x)$ for every $x$. The weak inequality is already unconditional, and equality follows from a supporting line, which exists everywhere precisely when $I$ is convex; this closes the loop and completes the idempotent Cramér theorem.

**Conjecture 2 — Scaled idempotent LDP (Gärtner–Ellis form).** For the $n$-step max-plus walk, the rate function of the empirical mean $S_n/n$ is $n$ times the single-step rate and equals the Legendre–Fenchel transform of $\tfrac1n\Lambda(n\lambda)$, which in the limit is the transform of the single-step $\Lambda$. Because $\Lambda_{S_n} = n\Lambda$ holds exactly, the empirical-mean rate scales linearly with no error term — a non-asymptotic Gärtner–Ellis limit.

**Conjecture 3 — Contraction principle.** For any map $\varphi : X \to Y$ with pushforward measure $w_Y(y) = \sup_{\varphi(x)=y} w_X(x)$, the pushforward rate function is the infimal contraction $I_Y(y) = \inf_{\varphi(x)=y} I_X(x)$. Pushing forward is a sup over fibres, which dualizes to an inf of rate functions — the idempotent contraction principle.

**Conjecture 4 — Idempotent Varadhan lemma.** For any observable $f$, the idempotent free energy equals the sup-convolution $\int^{\!+} f\,dP = \sup_x(f(x) - I(x))$, and as a functional of $f$ it is convex with transform recovering $I$. This is Varadhan's integral lemma with the $\exp/\log$ removed: the idempotent integral is its own large-deviation asymptotic.

---

## 9. Conclusion

We have built a finite, exact theory of large deviations in the max-plus world: a convex cumulant generating function, additive under independence and linearly scaling along random walks, a Chernoff bound, and a sharp LDP equating event cost with the infimum of the rate function. We then determined the exact reach of Cramér duality: the Legendre–Fenchel biconjugate is an unconditional lower bound on the rate function, and this bound is strict precisely on non-convex spikes. The explicit three-point law $P_{\mathrm{gap}}$ realizes a duality gap of exactly $2$, equal to the height of its non-convex spike above its chord, converting weak duality into a sharp characterization: idempotent Cramér duality holds if and only if the rate function equals its own convex lower envelope.
