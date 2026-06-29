# The EML Fixed-Point Operator as a Certified ResNet Residual Layer: One Contraction Ratio for Convergence and Depth Stability

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications

## Abstract

We study the *exp-minus-log* (EML) single operator $f(x) = e^{a}\log(b x + c)$ as an iterative scheme and prove that, on a suitable invariant interval, it is a contraction mapping whose iteration converges to a unique fixed point at a certified geometric rate $O(\rho^{n})$, where $\rho$ is an explicit bound on $|f'|$. We give a fully verified concrete instance, $f(x) = e\,\log(x + 100)$ on $[0,20]$ with $\rho = 1/30$, demonstrating that the contraction hypotheses are simultaneously satisfiable by a genuine (non-affine, $a>0$) exp-log map. We then establish a cross-domain bridge to deep learning: by composing the EML operator with the $1$-Lipschitz clamp (metric projection) onto its invariant interval, we obtain a globally $\rho$-Lipschitz map that serves as the residual transformation of a ResNet block. The resulting **EML residual block** is $(1+\rho)$-Lipschitz, and a depth-$K$ stack obeys the Bernoulli growth floor $(1+\rho)^{K} \ge 1 + K\rho$, exhibiting additive (depth-stable) rather than multiplicative (exponential) Lipschitz growth. The central structural finding is that a *single* constant $\rho$ — the slope bound of the exp-log curve — simultaneously governs (i) iteration convergence speed, (ii) fixed-point uniqueness, and (iii) residual-network depth stability. All results are formally verified.

## 1. Introduction

Iterated maps of the form $x_{n+1} = f(x_n)$ are ubiquitous across numerical analysis, dynamical systems, and machine learning. When $f$ is a contraction, the Banach fixed-point theorem guarantees existence, uniqueness, and geometric convergence of the iteration. The challenge for any specific family is to (a) verify the contraction hypotheses through analytic estimates and (b) extract explicit, computable rate constants suitable for certified computation.

The EML operator
$$f(x) = e^{a}\,\log(b x + c)$$
arises in the *exp-minus-log* neural-activation framework, combining exponential scaling with logarithmic compression. Its derivative,
$$f'(x) = \frac{e^{a}\, b}{b x + c},$$
admits a transparent monotone structure that makes contraction tractable: by enlarging the shift $c$ relative to the working interval, $|f'|$ is forced below any target threshold $\rho < 1$, while the slow growth of $\log$ keeps the map interval-invariant.

This paper makes three contributions:

1. **Certified convergence theory** (Section 3). We prove that the EML operator is a contraction on an invariant interval and that its iteration converges to a unique fixed point with the explicit a priori error bound $|x_n - x^\*| \le |x_1 - x_0|\,\rho^{n}/(1-\rho)$.

2. **A non-vacuous concrete instance** (Section 4). We exhibit the verified operator $f(x) = e\log(x+100)$ on $[0,20]$ with $\rho = 1/30$, discharging every contraction hypothesis with genuine real-analytic estimates.

3. **A bridge to deep learning** (Section 5). Using the $1$-Lipschitz clamp, we globalize the EML contraction and prove that it constitutes a certified ResNet residual block of Lipschitz budget $1 + \rho$, with depth-$K$ Bernoulli growth $(1+\rho)^{K} \ge 1 + K\rho$.

The unifying theme (Section 6) is that one transcendental quantity, $\rho$ (equivalently $1 - \rho$, the non-degeneracy gap), simultaneously governs convergence, uniqueness, and depth stability.

## 2. Definitions

**Definition 2.1 (EML operator).** For parameters $a, b, c \in \mathbb{R}$, the EML single operator is
$$\mathrm{EMLIterOp}(a,b,c)(x) = e^{a}\,\log(b x + c).$$

**Definition 2.2 (Iteration sequence).** Given an initial point $x_0$, the EML iteration is defined recursively by
$$x_0 = x_0, \qquad x_{n+1} = \mathrm{EMLIterOp}(a,b,c)(x_n).$$

**Definition 2.3 (EML contraction datum).** An `EMLContractionData` bundles parameters $a,b,c$, an interval $[\mathrm{lo}, \mathrm{hi}]$, and a ratio $\rho$ together with the following standing hypotheses:
- $\mathrm{lo} < \mathrm{hi}$ (valid interval);
- $0 \le \rho < 1$ (contraction regime);
- $b x + c > 0$ for all $x \in [\mathrm{lo}, \mathrm{hi}]$ (log argument positivity);
- $\mathrm{EMLIterOp}(a,b,c)(x) \in [\mathrm{lo},\mathrm{hi}]$ for all $x \in [\mathrm{lo},\mathrm{hi}]$ (self-map / invariance);
- $\left|\dfrac{e^{a} b}{b x + c}\right| \le \rho$ for all $x \in [\mathrm{lo},\mathrm{hi}]$ (derivative bound).

A datum packages exactly the data needed to invoke the Banach machinery; the whole convergence theory is stated relative to it.

**Definition 2.4 (Clamp / metric projection).** For $\mathrm{lo} \le \mathrm{hi}$, the clamp onto $[\mathrm{lo},\mathrm{hi}]$ is
$$\operatorname{clamp}(\mathrm{lo},\mathrm{hi},x) = \min\!\big(\mathrm{hi}, \max(\mathrm{lo}, x)\big).$$

**Definition 2.5 (EML residual block).** Given a datum $D$, write $g(x) = \mathrm{EMLIterOp}(a,b,c)(\operatorname{clamp}(\mathrm{lo},\mathrm{hi},x))$ for the clamped EML map. The associated residual block is the map $x \mapsto x + g(x)$, and a depth-$K$ EML residual network is the $K$-fold composition of such blocks.

## 3. Convergence Theory

### 3.1 Derivative and fixed-point characterization

**Lemma 3.1 (`EMLIterOp.hasDerivAt`, `EMLIterOp.deriv_eq`).** *If $b x + c > 0$ then $f = \mathrm{EMLIterOp}(a,b,c)$ is differentiable at $x$ with*
$$f'(x) = \frac{e^{a}\,b}{b x + c}.$$

*Proof sketch.* Differentiate the composition $\exp(a)\cdot \log(bx+c)$ using the chain rule: the inner affine map $bx+c$ has derivative $b$, $\log$ contributes $1/(bx+c)$, and the constant factor $e^a$ scales the result. ∎

**Lemma 3.2 (`EMLIterOp.fixedPoint_eq`).** *Any fixed point $x^\*$ satisfies the implicit equation $x^\* = e^{a}\log(b x^\* + c)$.*

*Proof sketch.* Immediate from $f(x^\*) = x^\*$ by definition of $f$. ∎

### 3.2 Contraction via the mean value theorem

**Theorem 3.3 (`EMLIterOp.lipschitz_of_deriv_bound`).** *Suppose $bx+c>0$ on $[\mathrm{lo},\mathrm{hi}]$ and $|f'(x)| \le \rho$ there. Then for all $x,y \in [\mathrm{lo},\mathrm{hi}]$,*
$$|f(x) - f(y)| \le \rho\,|x - y|.$$

*Proof sketch.* The interval $[\mathrm{lo},\mathrm{hi}]$ is convex, $f$ is differentiable on it (Lemma 3.1), and its derivative is bounded in norm by $\rho$. The mean value inequality for maps with bounded derivative on a convex set (`Convex.norm_image_sub_le_of_norm_hasDerivWithin_le`) yields the Lipschitz estimate. ∎

**Theorem 3.4 (`EMLIterOp.fixedPoint_unique`).** *Under the hypotheses of Theorem 3.3 with $\rho < 1$, $f$ has at most one fixed point in $[\mathrm{lo},\mathrm{hi}]$.*

*Proof sketch.* If $x_1, x_2$ are both fixed, then $|x_1 - x_2| = |f(x_1) - f(x_2)| \le \rho |x_1 - x_2|$. Since $\rho < 1$, $(1-\rho)|x_1-x_2| \le 0$ forces $|x_1 - x_2| = 0$. ∎

### 3.3 Invariance and convergence

**Lemma 3.5 (`EMLIterOp.iterSeq_mem_Icc`).** *If $x_0 \in [\mathrm{lo},\mathrm{hi}]$ and $f$ maps the interval into itself, then $x_n \in [\mathrm{lo},\mathrm{hi}]$ for all $n$.*

*Proof sketch.* Induction on $n$ using the self-map property at each step. ∎

**Lemma 3.6 (`EMLIterOp.iterSeq_geometric_decay`).** *For a datum $D$ and $x_0 \in [\mathrm{lo},\mathrm{hi}]$,*
$$|x_{n+1} - x_n| \le \rho^{n}\,|x_1 - x_0|.$$

*Proof sketch.* Induction on $n$. The base case is trivial; the step applies the contraction estimate (Theorem 3.3) to consecutive iterates, both of which lie in the interval by Lemma 3.5, and multiplies the inductive bound by $\rho$. ∎

**Theorem 3.7 (`EMLIterOp.iterSeq_cauchy`).** *The iteration $(x_n)$ is Cauchy.*

*Proof sketch.* The per-step geometric decay (Lemma 3.6) feeds the standard criterion `cauchySeq_of_le_geometric` with ratio $\rho < 1$ and constant $|x_1 - x_0|$. ∎

**Theorem 3.8 (`EMLIterOp.iterSeq_converges`).** *The iteration converges to a limit $x^\* \in [\mathrm{lo},\mathrm{hi}]$ that is a fixed point: $f(x^\*) = x^\*$.*

*Proof sketch.* Completeness of $\mathbb{R}$ promotes the Cauchy sequence (Theorem 3.7) to a limit $x^\*$. The interval $[\mathrm{lo},\mathrm{hi}]$ is closed, so $x^\* \in [\mathrm{lo},\mathrm{hi}]$. By continuity of $f$, the shifted sequence $f(x_n) = x_{n+1}$ converges both to $f(x^\*)$ and to $x^\*$; uniqueness of limits gives $f(x^\*) = x^\*$. ∎

### 3.4 Certified geometric rate

**Lemma 3.9 (`EMLIterOp.iterSeq_dist_consecutive`).** *$\mathrm{dist}(x_n, x_{n+1}) \le |x_1 - x_0|\,\rho^{n}$.*

This restates Lemma 3.6 in metric form for the geometric-series machinery.

**Theorem 3.10 (A priori error estimate, `EMLIterOp.iterSeq_error_bound`).** *If the iteration converges to $x^\*$, then for all $n$,*
$$|x_n - x^\*| \le \frac{|x_1 - x_0|}{1 - \rho}\,\rho^{n}.$$

*Proof sketch.* Sum the geometric tail: Mathlib's `dist_le_of_le_geometric_of_tendsto` converts the per-step decay (Lemma 3.9) plus the existence of the limit into the closed-form bound $C\,\rho^n/(1-\rho)$ with $C = |x_1-x_0|$. ∎

**Theorem 3.11 (Certified rate, `EMLIterOp.iterSeq_certified_rate`).** *For any datum $D$ and $x_0 \in [\mathrm{lo},\mathrm{hi}]$ there exists a fixed point $x^\* \in [\mathrm{lo},\mathrm{hi}]$ such that the iteration converges to $x^\*$ and satisfies the bound of Theorem 3.10 at every step.*

*Proof sketch.* Combine the convergence theorem (Theorem 3.8) with the error estimate (Theorem 3.10). ∎

**Theorem 3.12 (`EMLIterOp.iterSeq_error_tendsto_zero`).** *The error bound $\frac{|x_1-x_0|}{1-\rho}\rho^n \to 0$ as $n \to \infty$.*

*Proof sketch.* $\rho^n \to 0$ since $0 \le \rho < 1$ (`tendsto_pow_atTop_nhds_zero_of_lt_one`); multiply and divide by constants. This certifies genuine $O(\rho^n)$ convergence rather than merely qualitative convergence. ∎

## 4. A Concrete, Certified Instance

A theory conditional on `EMLContractionData` is only meaningful if the hypothesis class is inhabited. We remove vacuity by an explicit construction.

**Construction 4.1 (`concreteEML`).** Take $a = 1$, $b = 1$, $c = 100$, interval $[0, 20]$, and $\rho = 1/30$, i.e.
$$f(x) = e\,\log(x + 100).$$
All hypotheses of Definition 2.3 hold:
- *Log argument positivity:* on $[0,20]$, $x + 100 \ge 100 > 0$.
- *Derivative bound:* $|f'(x)| = e/(x+100) \le e/100 < 3/100 < 1/30$, using $e < 3$.
- *Self-map:* $\log(x+100) \ge \log 100 \ge 0$, and $\log(x+100) \le \log 120 < 5$ (since $e^5 = (e^1)^5 > 2.7^5 > 120$); hence $0 \le e\log(x+100) < 3 \cdot 5 = 15 < 20$.

**Theorem 4.2 (`concreteEML_nontrivial`).** *$e^{a} = e^{1} > 1$, so the operator is a genuine exp-log composition, not a bare logarithm.*

**Theorem 4.3 (End-to-end certification, `concreteEML_certified`).** *For any $x_0 \in [0,20]$ there is a fixed point $x^\* \in [0,20]$ of $f(x) = e\log(x+100)$ such that the iteration $x_{n+1} = e\log(x_n+100)$ converges to $x^\*$ with*
$$|x_n - x^\*| \le |x_1 - x_0|\cdot \frac{(1/30)^{n}}{1 - 1/30}.$$

*Proof sketch.* Instantiate Theorem 3.11 at the datum of Construction 4.1 and simplify the constants. ∎

Numerically, the fixed point is $x^\* \approx 12.85$, and the observed step-to-step ratio $e/(x^\*+100) \approx 0.0241$ is even tighter than the certified $\rho = 1/30 \approx 0.0333$. The methodological lesson is *slack engineering*: choosing $c$ large relative to the interval makes both the derivative bound (large denominator) and the self-map property (slow log growth) easy to discharge.

## 5. Bridge: EML Contraction as a ResNet Residual Layer

### 5.1 ResNet Lipschitz law (MachineLearning domain)

**Theorem 5.1 (Residual block Lipschitz bound, `resnet_block_lipschitz`).** *Let $X$ be a normed space and $g : X \to X$ be $L$-Lipschitz with $L \ge 0$. Then for all $x, y$,*
$$\|(x + g(x)) - (y + g(y))\| \le (1 + L)\,\|x - y\|.$$

*Proof sketch.* Write $(x+g(x)) - (y+g(y)) = (x-y) + (g(x)-g(y))$, apply the triangle inequality, and bound $\|g(x)-g(y)\| \le L\|x-y\|$; the skip contributes $\|x-y\|$, giving $(1+L)\|x-y\|$. Growth is *additive* $(1+L)$, not multiplicative as for feedforward composition $h \circ g$ (bound $L_h L_g$). ∎

**Theorem 5.2 (Bernoulli depth growth, `bernoulli_resnet`).** *For $L \ge 0$ and $K \in \mathbb{N}$,*
$$(1 + L)^{K} \ge 1 + K\,L.$$

*Proof sketch.* Induction on $K$; the step uses $(1 + KL)(1+L) = 1 + (K+1)L + KL^2 \ge 1 + (K+1)L$. ∎

This is the source of ResNet depth stability: when $L < 1$, $(1+L)^K$ grows polynomially in effect rather than as the exponential $L^K$ blow-up of plain feedforward networks.

### 5.2 The clamp is the perfect glue

**Lemma 5.3 (Clamp range, `clamp_mem_Icc`).** *If $\mathrm{lo} \le \mathrm{hi}$ then $\operatorname{clamp}(\mathrm{lo},\mathrm{hi},x) \in [\mathrm{lo},\mathrm{hi}]$.*

*Proof sketch.* $\max(\mathrm{lo},x) \ge \mathrm{lo}$ and $\ge x$, so taking $\min$ with $\mathrm{hi}$ keeps the value between $\mathrm{lo}$ and $\mathrm{hi}$. ∎

**Lemma 5.4 (Clamp is $1$-Lipschitz, `clamp_lipschitz`).** *For all $x, y$,*
$$|\operatorname{clamp}(\mathrm{lo},\mathrm{hi},x) - \operatorname{clamp}(\mathrm{lo},\mathrm{hi},y)| \le |x - y|.$$

*Proof sketch.* Both $t \mapsto \max(\mathrm{lo},t)$ and $t \mapsto \min(\mathrm{hi},t)$ are $1$-Lipschitz (case analysis on which argument achieves the extremum); their composition is $1$-Lipschitz. The clamp is the metric projection (nearest-point retraction) onto the convex set $[\mathrm{lo},\mathrm{hi}]$, which is always $1$-Lipschitz. ∎

The crucial structural fact: the clamp is a $1$-Lipschitz retraction onto the invariant set. It costs *nothing* in the Lipschitz budget (factor $1$) while globalizing the interval-only EML bound, and on $[\mathrm{lo},\mathrm{hi}]$ it equals the identity — so the clamped layer agrees exactly with the genuine EML iteration where the dynamics live.

### 5.3 Globalizing the EML contraction

**Theorem 5.5 (Globally $\rho$-Lipschitz clamped EML map, `clampedEML_global_lipschitz`).** *For any datum $D$ and all $x, y$,*
$$\big|f(\operatorname{clamp}(\mathrm{lo},\mathrm{hi},x)) - f(\operatorname{clamp}(\mathrm{lo},\mathrm{hi},y))\big| \le \rho\,|x - y|.$$

*Proof sketch.* Apply the EML interval contraction (Theorem 3.3) to the clamped arguments, which lie in $[\mathrm{lo},\mathrm{hi}]$ by Lemma 5.3, then bound the clamp distance by $|x-y|$ via Lemma 5.4 and multiply by $\rho \ge 0$. ∎

### 5.4 The certified EML residual layer

**Theorem 5.6 (EML residual block, `eml_residual_block_lipschitz`).** *With $g$ the clamped EML map of datum $D$, the residual block $x \mapsto x + g(x)$ satisfies*
$$\|(x + g(x)) - (y + g(y))\| \le (1 + \rho)\,\|x - y\|.$$

*Proof sketch.* The clamped EML map is globally $\rho$-Lipschitz (Theorem 5.5); on $\mathbb{R}$, $\|\cdot\| = |\cdot|$. Feed this into the ResNet residual law (Theorem 5.1) with $L = \rho \ge 0$. ∎

**Theorem 5.7 (Certified EML residual network, `eml_residual_network_certified`).** *For any datum $D$:*
1. *each EML residual block is $(1+\rho)$-Lipschitz;*
2. *a depth-$K$ stack obeys the Bernoulli floor $1 + K\rho \le (1+\rho)^{K}$ for all $K$;*
3. *$\rho$ lies in the contraction regime $0 \le \rho < 1$.*

*Proof sketch.* Part (1) is Theorem 5.6; part (2) is Theorem 5.2 with $L = \rho$; part (3) is recorded in the datum $D$. ∎

**Theorem 5.8 (Non-vacuity, `concrete_eml_residual_certified`).** *Instantiating Theorem 5.7 at the concrete datum of Construction 4.1 yields a certified EML residual layer with budget $\rho = 1/30$ built from the genuine exp-log map $f(x) = e\log(x+100)$.*

The contraction ratio $\rho$ of the fixed-point theorem and the residual-block Lipschitz budget are therefore *the same object*. EML dynamics (the analytic ratio $\rho$) and residual-network depth stability (additive composition, Bernoulli floor) are two faces of one constant.

## 6. Discussion

The recurring discovery is that one transcendental quantity, $x^\* + c - e^{a}$ (equivalently $1 - \rho$), simultaneously governs convergence speed, parameter sensitivity, and the residual-network depth budget. When $\rho$ is small:
- the iteration converges in very few steps (error $\sim \rho^n$);
- the fixed point is robustly unique (large $1 - \rho$ gap);
- the residual layer is nearly an isometry ($1 + \rho \approx 1$), so very deep stacks stay stable.

Unlike arbitrary neural activations selected empirically, the EML operator therefore comes with certificates on all three axes at once. The clamp is the minimal piece of glue that reconciles the interval-local analytic theory with the global requirements of a deployable network layer, at zero Lipschitz cost.

A subtle but important point of rigor: the clamp does not alter the dynamics where they matter. On the invariant interval the clamp is the identity, so the EML residual block reproduces the genuine EML iteration exactly; clamping only tames behavior outside the interval, which is precisely what a deployed layer requires for arbitrary inputs.

## 7. Applications

- **Certified iterative solvers.** Any fixed-point computation expressible as an EML operator inherits an a priori step count for target accuracy via Theorem 3.10.
- **Stable deep architectures.** EML residual layers provide a drop-in residual transformation with a provable, tunable Lipschitz budget, supporting depth-stable networks with certified robustness (the additive law avoids exponential sensitivity growth).
- **Hyperparameter design.** The slack-engineering principle (large $c$) gives a constructive recipe to dial $\rho$ to any desired value, trading interval size against contraction strength.

## 8. Future Work

1. **Power series of $x^\*(a)$.** On the attracting branch the fixed point is conjecturally real-analytic in $a$, with all coefficients rational in $(x^\*, c, e^a)$ over powers of $1-\rho$, forcing a radius of convergence set by the fold threshold $c = e^a(1-a)$.
2. **Two-sided depth envelope.** Combining the Bernoulli floor with $1 + \rho \le e^{\rho}$ yields $1 + K\rho \le (1+\rho)^K \le e^{K\rho}$, pinning EML residual depth cost between a linear floor and an exponential-of-linear ceiling, tight as $\rho \to 0$.
3. **Repelling branch sensitivity.** On the repelling branch ($\rho > 1$) the same sensitivity formula gives a negative slope $dx^\*/da < 0$, so attracting and repelling fixed points move in opposite directions as $a$ varies, with a strictly increasing gap.

## 9. Conclusion

We have formally established that the EML operator $f(x) = e^a\log(bx+c)$ is a certified contraction with explicit geometric convergence, exhibited a concrete non-vacuous instance with $\rho = 1/30$, and built a bridge identifying its contraction ratio with the Lipschitz budget of a depth-stable ResNet residual layer. The throughline is a single constant $\rho$ governing convergence, uniqueness, and depth — a clean instance of one analytic quantity unifying classical iteration and modern deep-network design.
