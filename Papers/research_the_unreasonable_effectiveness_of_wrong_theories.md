# The Unreasonable Effectiveness of Wrong Theories: A Perturbative Geometry of Theory-Space

## Abstract

We develop a rigorous geometric framework in which physical theories are points of a real inner-product space, the truth is a distinguished point, and the *wrongness* of a theory is its distance to the truth. Within this framework we prove a meta-theorem answering, in precise mathematical terms, why approximately correct theories are so effective — and why theories known to be wrong nevertheless remain indispensable. Three families of results are established. First, a **perturbative convergence theory**: sequences of corrections that sum to the truth-gap drive wrongness to zero, with an explicit tail bound and, under geometric decay of corrections, an explicit exponential convergence rate $M r^{n}/(1-r)$. Second, a **non-degeneracy principle**: a theory equals the truth if and only if it predicts every phenomenon perfectly. Third, the central **meta-theorem**: whenever two theories fail in non-parallel directions, there exists a phenomenon on which the "wrong" theory predicts the truth *exactly* while its rival errs — so a globally worse theory can strictly out-predict a globally better one locally. All results hold over an arbitrary real inner-product space and are developed from first principles.

## 1. Introduction

The history of physics is a history of superseded theories, yet each superseded theory was, and often still is, extraordinarily useful. This tension — global falsity coexisting with local, sometimes exact, predictive success — is usually discussed philosophically. We give it a mathematical treatment.

Our thesis is that once "theories," "truth," "phenomena," and "wrongness" are modeled geometrically, the effectiveness of wrong theories ceases to be mysterious and becomes a theorem about inner-product spaces. The essential ideas are:

- **Theory-space** is a real inner-product space $E$; each theory is a point.
- **Truth** is a fixed point $\tau \in E$.
- **Wrongness** is Euclidean distance to truth.
- **Phenomena** are directions (unit-free vectors) $u \in E$; a theory's prediction is the linear functional $\langle T, u\rangle$, and its prediction error is $|\langle T - \tau, u\rangle|$.

From these definitions we recover perturbation theory (the summation of corrections), a quantitative theory of convergence rates, and a geometric explanation for why wrong theories win on their own turf.

The modeling choices deserve a word of justification. Representing a theory by its predictions is standard operationalism: two theories that make identical predictions on every conceivable measurement are, for our purposes, the same point of $E$. Representing a phenomenon by a direction rather than a point encodes the idea that an experiment probes a *contrast* — a linear combination of observables — and that its outcome, for a given theory, is the value of that linear functional. Wrongness as Euclidean distance is the least committal choice consistent with an inner-product geometry, and it is exactly the quantity minimized by least-squares fitting, orthogonal projection, and countless estimation procedures. The framework is therefore not exotic: it is the ambient geometry already implicit in how physical predictions are compared to data. What is new is the systematic use of that geometry to prove statements *about theories as a class*, rather than about any single theory.

### 1.1 Contributions

1. A clean axiomatization of theory-space and wrongness (Section 2).
2. Lipschitz stability of wrongness under corrections (Theorem 3.1).
3. A convergence theorem: perturbative corrections summing to the truth-gap send wrongness to zero (Theorem 3.3), with a tail bound (Theorem 3.4) and its vanishing (Theorem 3.5).
4. An explicit exponential convergence rate under geometric decay of corrections (Theorem 3.6).
5. A non-degeneracy principle characterizing truth by phenomena (Theorem 4.2).
6. The exactness of a wrong theory on phenomena orthogonal to its error (Theorem 4.3).
7. The meta-theorem: a wrong theory strictly out-predicts a non-parallel rival on a constructed phenomenon (Theorem 4.4).

## 2. The geometry of theory-space

Throughout, $E$ is a real vector space. For the metric results we require only a norm; for the phenomenological results we require a real inner product $\langle\cdot,\cdot\rangle$ with induced norm $\|v\| = \sqrt{\langle v, v\rangle}$.

**Definition 2.1 (Theory, truth, wrongness).** A *theory* is a point $T \in E$. A distinguished point $\tau \in E$ is the *truth*. The *wrongness* of $T$ (relative to $\tau$) is
$$w(T) := \|T - \tau\|.$$

**Definition 2.2 (Phenomenon, prediction, prediction error).** A *phenomenon* is a vector $u \in E$ interpreted as a measurement direction. The *prediction* of theory $T$ on $u$ is $\langle T, u\rangle$. The *prediction error* is
$$\mathrm{err}(T, u) := |\langle T - \tau, u\rangle|.$$

**Proposition 2.3 (Basic properties).** For all $T$: $w(T) \ge 0$, and $w(\tau) = 0$.

*Proof.* Immediate from $w(T) = \|T-\tau\|$ and the norm axioms. $\square$

Wrongness inherits from the norm the familiar metric structure: it is symmetric in the sense that $\|T - \tau\| = \|\tau - T\|$, and it satisfies the triangle inequality $w(T_1) \le w(T_2) + \|T_1 - T_2\|$. The second inequality is the seed of the Lipschitz stability result below: no theory can be much wronger than a nearby theory. We emphasize that the results of this paper never require $E$ to be finite-dimensional; the metric layer requires only a normed space (Banach, once completeness is invoked for infinite correction series), and the phenomenological layer requires only an inner product. In the finite-dimensional case one may picture $E = \mathbb{R}^d$ with the usual dot product, and every statement specializes to elementary linear algebra.

**Definition 2.4 (Perturbative sequence).** Given a base theory $T_0 \in E$ and a sequence of *corrections* $c : \mathbb{N} \to E$, the $n$-th *partial theory* is
$$T_n := T_0 + \sum_{i=0}^{n-1} c_i.$$
In particular $T_0$ is the base theory (empty sum).

## 3. Perturbative convergence theory

This section uses only the normed-space structure of $E$.

**Theorem 3.1 (Lipschitz stability of wrongness).** For any theory $T$ and correction $c$,
$$|\,w(T + c) - w(T)\,| \le \|c\|.$$

*Proof sketch.* By definition $w(T+c) - w(T) = \|T + c - \tau\| - \|T - \tau\|$. The reverse triangle inequality $|\,\|x\| - \|y\|\,| \le \|x - y\|$ applied to $x = T + c - \tau$ and $y = T - \tau$ gives the bound, since $x - y = c$. $\square$

This says the wrongness functional is $1$-Lipschitz in the correction: bounded interventions cause bounded changes in accuracy, ruling out pathological sensitivity. The constant $1$ is sharp: taking $c$ parallel to $T - \tau$ and pointing away from $\tau$ makes $w(T + c) - w(T) = \|c\|$ exactly. Stability of this kind is what legitimizes the incremental methodology of physics: were wrongness able to swing wildly under small corrections, no perturbative program could be trusted, because a tiny modeling adjustment could catastrophically degrade every prediction.

**Lemma 3.2 (Exactness criterion).** $w(T) = 0$ if and only if $T = \tau$.

*Proof.* $\|T - \tau\| = 0 \iff T - \tau = 0 \iff T = \tau$. $\square$

**Theorem 3.3 (Convergence to truth).** Suppose the corrections sum to the truth-gap in the sense that the series $\sum_i c_i$ converges to $\tau - T_0$. Then
$$w(T_n) \xrightarrow[n\to\infty]{} 0,$$
i.e. the partial theories converge to the truth.

*Proof sketch.* If $\sum_{i=0}^{n-1} c_i \to \tau - T_0$, then $T_n = T_0 + \sum_{i=0}^{n-1} c_i \to \tau$ by continuity of vector addition. Composition with the continuous norm gives $w(T_n) = \|T_n - \tau\| \to \|\tau - \tau\| = 0$. $\square$

**Theorem 3.4 (Perturbative tail bound).** Suppose $E$ is complete and the correction norms are summable, $\sum_i \|c_i\| < \infty$. Let $\tau = T_0 + \sum_i c_i$ be the fully corrected theory. Then the residual wrongness after $n$ terms is bounded by the tail of the norm series:
$$w(T_n) \le \sum_{i=0}^{\infty} \|c_{i+n}\|.$$

*Proof sketch.* Absolute summability implies summability, so $\sum_i c_i$ exists. Splitting the series at $n$ gives $\sum_i c_i = \sum_{i<n} c_i + \sum_i c_{i+n}$, hence $T_n - \tau = \sum_{i<n} c_i - \sum_i c_i = -\sum_i c_{i+n}$. Taking norms and applying the triangle inequality for infinite sums, $w(T_n) = \|\sum_i c_{i+n}\| \le \sum_i \|c_{i+n}\|$. $\square$

**Theorem 3.5 (Vanishing of the tail bound).** For any correction sequence $c$, the tail bound tends to zero:
$$\sum_{i=0}^{\infty} \|c_{i+n}\| \xrightarrow[n\to\infty]{} 0.$$

*Proof sketch.* The tails of a convergent nonnegative series vanish as the starting index increases; this is the standard fact that the sequence of tail sums of a summable series tends to $0$. $\square$

Together, Theorems 3.4 and 3.5 upgrade qualitative convergence to quantitative control: at every stage one can bound how far the truth remains, and that bound is guaranteed to close. The distinction between Theorem 3.3 and Theorem 3.4 is worth stressing. Theorem 3.3 needs only that the *vector* series converges; it makes no assumption on the sizes of individual corrections and gives no rate. Theorem 3.4 assumes *absolute* summability — a genuinely stronger hypothesis, since in infinite dimensions there exist convergent series that are not absolutely convergent — and in return delivers a computable residual certificate. In practice one almost always has control of $\sum_i \|c_i\|$ (for instance from a physical estimate of the size of each correction term), so Theorem 3.4 is the workhorse.

**Theorem 3.6 (Explicit exponential rate).** Suppose $E$ is complete and the corrections decay geometrically: there exist $M \ge 0$ and $0 \le r < 1$ with $\|c_i\| \le M r^{i}$ for all $i$. With $\tau = T_0 + \sum_i c_i$, the residual wrongness decays exponentially:
$$w(T_n) \le \frac{M\, r^{n}}{1 - r}.$$

*Proof sketch.* Geometric decay makes $\sum_i \|c_i\|$ summable (dominated by $M\sum_i r^i$), so Theorem 3.4 applies and $w(T_n) \le \sum_i \|c_{i+n}\|$. Bounding termwise, $\sum_i \|c_{i+n}\| \le \sum_i M r^{i+n} = M r^{n} \sum_i r^{i} = M r^{n}/(1-r)$, using the geometric series sum $\sum_{i\ge 0} r^i = 1/(1-r)$ for $0 \le r < 1$. $\square$

Theorem 3.6 is the mathematical core of practical perturbation theory: a fixed convergence ratio $r$ yields error decreasing by a constant factor per term, so a small number of corrections achieves high accuracy. Quantitatively, to certify residual wrongness below a tolerance $\varepsilon$ it suffices to take
$$n \ge \frac{\log\!\big(\varepsilon (1-r)/M\big)}{\log r},$$
which is logarithmic in $1/\varepsilon$: each additional decimal digit of accuracy costs a fixed number of correction terms. This is precisely the empirical experience of perturbative calculations in physics, where a handful of terms in a well-behaved expansion pins a quantity down to many significant figures. The theorem also exposes the failure mode: as $r \to 1^-$ the prefactor $1/(1-r)$ and the required $n$ both blow up, the mathematical signature of an asymptotic-but-slowly-convergent (or divergent) series.

## 4. The phenomenological layer and the meta-theorem

We now use the inner product. Phenomena are directions, and predictions are inner products.

**Lemma 4.1 (Exactness on orthogonal phenomena).** If a phenomenon $u$ is orthogonal to a theory's error vector, i.e. $\langle T - \tau, u\rangle = 0$, then $\mathrm{err}(T, u) = 0$: the theory predicts $u$ *exactly*, regardless of how wrong it is overall.

*Proof.* $\mathrm{err}(T,u) = |\langle T - \tau, u\rangle| = |0| = 0$. $\square$

This is the crucial asymmetry: wrongness is a single vector $T - \tau$, and a theory is flawless on the entire hyperplane orthogonal to that vector.

**Theorem 4.2 (Non-degeneracy: truth is characterized by phenomena).** A theory equals the truth if and only if it predicts every phenomenon perfectly:
$$T = \tau \iff \forall u \in E,\ \langle T - \tau, u\rangle = 0.$$

*Proof sketch.* ($\Rightarrow$) If $T = \tau$ then $T - \tau = 0$ and every inner product vanishes. ($\Leftarrow$) If $\langle T - \tau, u\rangle = 0$ for all $u$, take $u = T - \tau$; then $\langle T-\tau, T-\tau\rangle = 0$, so by positive-definiteness $T - \tau = 0$, i.e. $T = \tau$. $\square$

Thus no genuinely wrong theory can be perfect on all phenomena simultaneously — perfection everywhere is exactly truth.

**Theorem 4.3 (The exact-prediction hyperplane).** For a wrong theory $T \ne \tau$, the set of phenomena on which $T$ is exactly right is the orthogonal complement of its error vector,
$$\{u \in E : \mathrm{err}(T,u) = 0\} = (T - \tau)^{\perp},$$
a closed hyperplane of codimension one. When $\dim E \ge 2$ this set is infinite.

*Proof sketch.* $\mathrm{err}(T,u) = 0 \iff \langle T-\tau, u\rangle = 0 \iff u \in (T-\tau)^\perp$. Since $T - \tau \ne 0$, its orthogonal complement is a hyperplane. $\square$

**Theorem 4.4 (Meta-theorem: a wrong theory out-predicts a non-parallel rival).** Let $A$ (our theory) and $B$ (a rival) be theories, and let $\tau$ be the truth. Assume:
1. $A$ is genuinely wrong: $A \ne \tau$;
2. the errors are non-parallel: $B - \tau \ne r\,(A - \tau)$ for every scalar $r \in \mathbb{R}$.

Then there exists a phenomenon $u$ on which $A$ is exactly right while $B$ is wrong:
$$\mathrm{err}(A, u) = 0 < \mathrm{err}(B, u).$$

*Proof sketch.* Write $a = A - \tau$ and $b = B - \tau$. Since $A \ne \tau$, $\langle a, a\rangle > 0$. Perform one Gram–Schmidt step: set
$$t = \frac{\langle b, a\rangle}{\langle a, a\rangle}, \qquad u = b - t\, a.$$
Then $u$ is orthogonal to $a$: indeed $\langle u, a\rangle = \langle b, a\rangle - t\langle a, a\rangle = 0$. Hence by Lemma 4.1, $\mathrm{err}(A, u) = |\langle a, u\rangle| = 0$: $A$ is exactly right on $u$.

For $B$, compute $\langle b, u\rangle = \langle b, b - t a\rangle = \langle b, b\rangle - t\langle b, a\rangle$. But $u = b - t a$ is nonzero: were $u = 0$, we would have $b = t a$, i.e. $B - \tau = t(A - \tau)$, contradicting non-parallelism. Since $u \ne 0$, $\|u\|^2 > 0$, and a short computation gives $\langle b, u\rangle = \langle u + t a, u\rangle = \langle u, u\rangle + t\langle a, u\rangle = \|u\|^2 > 0$. Therefore $\mathrm{err}(B, u) = |\langle b, u\rangle| = \|u\|^2 > 0$. Combining, $\mathrm{err}(A,u) = 0 < \mathrm{err}(B,u)$. $\square$

**Remark 4.5 (Interpretation).** The meta-theorem is not a claim that wrong theories are secretly correct. Globally, $w(A) \ge w(B)$ is entirely possible — $B$ may be nearer the truth on the whole. The theorem isolates a *phenomenon* aligned with the part of $B$'s error that $A$'s error cannot account for. On that measurement, $A$'s error is orthogonal (hence null) while $B$'s is not. Locality of measurement, not global superiority, is what lets a wrong theory win.

**Remark 4.6 (Necessity of non-parallelism).** The hypothesis that the errors are non-parallel cannot be dropped. If $B - \tau = r(A - \tau)$ for some scalar $r$, then the two theories fail in the very same direction, and every phenomenon on which $A$ is exactly right (the hyperplane $(A-\tau)^\perp$) is also a phenomenon on which $B$ is exactly right. In that degenerate case no separating phenomenon exists, and the more accurate theory dominates everywhere it matters. The generic situation, however, is non-parallelism: in dimension $d \ge 2$ the set of error vectors parallel to a fixed one is a single line, a measure-zero exception. Thus for “almost every” pair of distinct wrong theories, each out-predicts the other on a suitable class of phenomena — a striking symmetry, since it means predictive superiority is never total.

**Corollary 4.7 (Mutual domination).** If $A \ne \tau$, $B \ne \tau$, and the errors of $A$ and $B$ are non-parallel, then there is a phenomenon on which $A$ out-predicts $B$ *and* a phenomenon on which $B$ out-predicts $A$. Neither wrong theory is uniformly better than the other. *Proof.* Apply Theorem 4.4 twice, swapping the roles of $A$ and $B$; the non-parallelism hypothesis is symmetric. $\square$

## 5. Algorithms

The proofs are constructive and translate directly into computation.

**Algorithm A (Winning-phenomenon construction).** Given errors $a = A - \tau$ (nonzero) and $b = B - \tau$ non-parallel to $a$, compute $t = \langle b,a\rangle/\langle a,a\rangle$ and return $u = b - t a$. Then $\mathrm{err}(A,u) = 0$ and $\mathrm{err}(B,u) = \|u\|^2 > 0$. Complexity: $O(d)$ in dimension $d$ (two inner products and an axpy).

**Algorithm B (Perturbative refinement with certified error).** Given $T_0$, corrections $c_i$, and a geometric bound $\|c_i\| \le M r^i$, iterate $T_{n+1} = T_n + c_n$ while reporting the certified residual $M r^{n}/(1-r)$. Stop when the certificate drops below a tolerance $\varepsilon$, which occurs after $n \ge \log(\varepsilon(1-r)/M)/\log r$ steps. Complexity: $O(d)$ per step; number of steps logarithmic in $1/\varepsilon$.

## 6. Applications

- **History and philosophy of science.** The framework formalizes why superseded theories (Newtonian gravity, ray optics, ideal gases) persist: each governs the hyperplane of phenomena orthogonal to its error, and on suitable phenomena out-predicts more accurate but differently-miscalibrated rivals.
- **Numerical analysis and physics.** Theorem 3.6 is the abstract skeleton of convergence-rate estimates for perturbation series and iterative solvers; the tail bound provides a computable stopping criterion.
- **Model selection.** The meta-theorem cautions that global accuracy metrics can be beaten pointwise; it motivates task-aware selection of "locally exact" models over globally superior ones.

## 7. Discussion

The results split naturally into a *diachronic* half — convergence and rates explaining why the sequence of corrected theories approaches truth, and how fast — and a *synchronic* half — the non-degeneracy principle and meta-theorem explaining why, at any fixed time, many wrong theories coexist, each exact on its own domain. The unifying object is the error vector $T - \tau$: its magnitude is wrongness, its direction determines the hyperplane of exact predictions, and the relation between two error vectors decides which theory wins a given phenomenon.

A limitation is the linearity of the model: predictions are linear functionals of the theory. Nonlinear observables and dynamical theory-spaces (where theories are operators) are natural generalizations.

## 8. Future work

- **Variable convergence ratios.** Relax geometric decay to $\|c_{i+1}\| \le r_i \|c_i\|$ and derive product-form residual bounds.
- **Large phenomenon classes.** Develop Theorem 4.3 into a dimension theory of exact-prediction sets, quantifying "how large" a wrong theory's domain of exactness is.
- **Best rival among many.** For a finite family of rivals, prove existence of a phenomenon on which our theory is a strict pointwise minimizer of prediction error (a max–min/separating-hyperplane refinement).
- **Measure-theoretic version.** Place a measure $\mu$ on phenomena, define weighted error $\int |\langle T - \tau, u\rangle|^2\, d\mu(u)$, and prove an $L^2$ analogue: a wrong theory can have smaller weighted error than a rival on classes where the rival's error concentrates.
- **Operator theory-spaces.** Replace static points by operators/dynamical systems and study wrongness under evolution.

## 9. Conclusion

By treating theories as points, truth as a target, and phenomena as directions, we converted a philosophical puzzle into geometry. Wrongness converges — often exponentially — under perturbative correction; truth is exactly the theory perfect on all phenomena; and every wrong theory, failing in its own direction, commands a hyperplane of phenomena on which it is exactly right and can strictly out-predict a rival. The effectiveness of wrong theories is not unreasonable: it is the geometry of error.
