# A Root Law for Optimal Batch Size under Sub-Quadratic Multiplication

**Author:** Aristotle
**Date:** 2026-09-11

---

## Abstract

Batching amortises a fixed setup cost across many candidates, but the arithmetic
that makes batching possible becomes super-linearly expensive as the batch grows.
We study the resulting per-candidate cost

$$C_{A,c,q,\mu}(k) \;=\; \frac{A}{k} + c + q\bigl(k^{\mu-1}-1\bigr), \qquad k \in (0,\infty),$$

where $A>0$ is the per-batch setup, $c$ the flat per-candidate cost, $q>0$ the
multiplication-penalty scale, and $\mu$ the multiplication exponent of the
underlying big-integer arithmetic ($\mu = 2$ schoolbook, $\mu = \log_2 3$ Karatsuba,
$\mu \to 1$ for FFT-based products and for the idealised flat operation model).

Our main theorem is a **root law**: for every $\mu > 1$ the cost has a unique global
minimiser
$$k^{*} = \left(\frac{A}{(\mu-1)q}\right)^{1/\mu},
\qquad C(k^{*}) = c - q + \mu(\mu-1)^{\frac{1-\mu}{\mu}}A^{\frac{\mu-1}{\mu}}q^{\frac{1}{\mu}},$$
recovering the classical square-root law $k^{*} = \sqrt{A/q}$, $C(k^{*}) = c - q + 2\sqrt{Aq}$, exactly at $\mu=2$, and degenerating at $\mu = 1$ to a strictly
decreasing cost with no interior optimum. The proof is derivative-free: it reduces
to Bernoulli's inequality via a *balance principle* stating that a batch size $t$ is
optimal precisely when the amortised setup equals $(\mu-1)$ times the marginal
multiplication penalty.

Around this core we develop four structural consequences. (i) *Universal collapse*:
in units of $k^{*}$ the whole cost curve is $(c-q) + q(k^{*})^{\mu-1}S_\mu(\theta)$
with the two-parameter shape $S_\mu(\theta) = (\mu-1)/\theta + \theta^{\mu-1}$, so
$A$ and $q$ affect only the vertical scale. (ii) *Flatness*: $S_\mu(\theta) - \mu \le (\mu-1)(\theta-1)^2/\theta$, so mis-sizing is a second-order error and the optimum is
a plateau. (iii) *Multiplicative but not additive convexity*: the cost is convex in
$\log k$ for every $\mu$, but fails to be convex in $k$ as soon as $\mu < 2$ (explicit
witness). (iv) *Unimodality and the discrete optimum*: the cost strictly decreases on
$(0,k^{*}]$ and strictly increases on $[k^{*},\infty)$, hence the best integer batch
is $\lfloor k^{*}\rfloor$ or $\lceil k^{*}\rceil$ and ternary search converges.

Finally we resolve the motivating engineering question. In the batch-smoothness-test
setting, batching beats solo testing exactly for pools of size at most
$M^{*}(\mu) = \bigl(1+(s_1-c_1)/q\bigr)^{1/(\mu-1)}$, a $1/(\mu-1)$-th root of the
setup/penalty ratio. At $\mu=2$ this is the linear crossover $1+(s_1-c_1)/q$
calibrated to a measured $M^{*} \approx 1715$; for $\mu \le 2$ the crossover is never
smaller, at $\mu=3/2$ it equals $1715^2 \approx 2.94\times10^{6}$, and it diverges as
$\mu \downarrow 1$. The observed batch-versus-solo reversal is therefore a property
of schoolbook arithmetic, not of batching.

**Keywords:** batch amortisation, multiplication exponent, Karatsuba, weighted
AM–GM, Bernoulli's inequality, multiplicative convexity, unimodality, smoothness
testing.

---

## 1. Introduction

### 1.1 The engineering situation

Batch algorithms trade a per-batch setup cost against a super-linear per-batch
arithmetic cost. The canonical example, and the one that motivates this work, is
*batch smoothness testing*: given a stream of integer candidates, decide for each
whether it factors completely over a fixed set of small primes. The batched method
forms the product of a block of $k$ candidates and tests the whole block against a
precomputed product of primes, so that one expensive setup (product tree, modular
reduction) serves $k$ candidates.

Naively, larger blocks are always better: the setup is amortised over more work. In
practice the measured cost curve turns around. In one calibration the turn happened
near $k \approx 1715$ candidates; beyond that, testing candidates one at a time was
cheaper. Yet in a different cost model — one that counts *operations* rather than
*machine words*, so that a multiplication costs one tick regardless of operand size
— no reversal appears at all, even at $k = 512$.

Two models, two qualitatively different answers. Something in the modelling, not in
the algorithm, is responsible. This paper identifies it precisely: the
**multiplication exponent**.

### 1.2 The cost model

Let $k>0$ denote the (real-valued, for now) batch size and count cost *per
candidate*.

- **Setup.** A fixed cost $A > 0$ per batch contributes $A/k$ per candidate.
- **Flat cost.** A per-candidate cost $c \in \mathbb{R}$, independent of $k$.
- **Multiplication penalty.** A batch of $k$ candidates produces an integer roughly
  $k$ times as long as a single candidate. If multiplying two $n$-word integers
  costs $\Theta(n^{\mu})$ word operations, the batch product costs $\Theta(k^{\mu})$
  where a single candidate costs $\Theta(1)$, i.e. $\Theta(k^{\mu-1})$ per candidate.
  Normalising so that a batch of one carries no penalty gives $q(k^{\mu-1}-1)$ with
  $q > 0$.

**Definition 1.1 (Per-candidate block cost).** For $A, q > 0$, $c, \mu \in \mathbb{R}$ and $k > 0$,
$$C_{A,c,q,\mu}(k) \;:=\; \frac{A}{k} \;+\; c \;+\; q\bigl(k^{\mu-1}-1\bigr),$$
where $k^{\mu-1}$ denotes the real power $\exp((\mu-1)\log k)$.

We write $C(k)$ when the parameters are clear. Relevant exponents: $\mu = 2$
(schoolbook), $\mu = \log_2 3 \approx 1.585$ (Karatsuba), $\mu = \log_3 5 \approx 1.465$ (Toom–3), $\mu \to 1^{+}$ (FFT-based multiplication, up to logarithmic
factors, and the flat operation model).

**Definition 1.2 (Candidate optimum and optimal value).** For $A, q>0$ and $\mu>1$,
$$k^{*}(A,q,\mu) := \left(\frac{A}{(\mu-1)q}\right)^{1/\mu}, \qquad
C^{*}(A,c,q,\mu) := c - q + \mu(\mu-1)^{\frac{1-\mu}{\mu}}A^{\frac{\mu-1}{\mu}}q^{\frac{1}{\mu}}.$$

### 1.3 Contributions

1. **The root law** (§3): $k^{*}$ is the unique global minimiser of $C$ on
   $(0,\infty)$, with value $C^{*}$; existence and uniqueness in the strong
   $\exists!$ form.
2. **A derivative-free proof** (§2): a *balance principle* reducing the whole
   optimisation to Bernoulli's inequality, robust enough to be reused for
   unimodality and for the auxiliary comparison arguments.
3. **Degeneracies and consistency** (§4): the $\mu=2$ specialisation reproduces the
   square-root law; the $\mu=1$ case has no interior optimum; the optimum diverges
   quantitatively as $\mu \downarrow 1$ and is antitone in $\mu$.
4. **Geometry of the curve** (§5): universal collapse, quadratic flatness of the
   optimum, homogeneity/scaling laws, multiplicative convexity, and an explicit
   failure of ordinary convexity for $\mu<2$.
5. **The discrete optimum** (§6): strict unimodality, hence the best integer batch is
   a neighbour of $k^{*}$, and ternary search is correct.
6. **The batch-versus-solo crossover** (§7): a root law for the crossover pool size,
   its $\mu = 2$ linear specialisation, monotonicity in $\mu$, divergence as
   $\mu\downarrow 1$, and a calibrated numerical instance.

---

## 2. The analytic engine: Bernoulli and a balance principle

Everything in this paper rests on one inequality, presented in three equivalent
guises.

**Lemma 2.1 (Bernoulli's inequality for real exponents).** For $u \ge 0$ and
$\mu \ge 1$,
$$\mu u \;\le\; u^{\mu} + (\mu-1).$$
If moreover $\mu > 1$ and $u \ne 1$, the inequality is strict.

*Proof sketch.* Apply the standard real-exponent Bernoulli inequality
$1 + \mu s \le (1+s)^{\mu}$ for $s \ge -1$, $\mu\ge1$, with $s = u-1$, and rearrange.
Strictness for $s \ne 0$, $\mu>1$ is the strict form of the same inequality. $\square$

**Lemma 2.2 (Weighted AM–GM, normalised).** For $u > 0$ and $\mu \ge 1$,
$$\mu \;\le\; \frac{\mu-1}{u} + u^{\mu-1},$$
with strict inequality whenever $\mu > 1$ and $u \ne 1$.

*Proof sketch.* Using $u\cdot u^{\mu-1} = u^{\mu}$,
$$\frac{\mu-1}{u} + u^{\mu-1} - \mu \;=\; \frac{u^{\mu} + (\mu-1) - \mu u}{u},$$
and the numerator is nonnegative (resp. positive) by Lemma 2.1. $\square$

Lemma 2.2 is the weighted arithmetic–geometric mean inequality with weights
$\bigl(\tfrac{\mu-1}{\mu},\tfrac1\mu\bigr)$ applied to $u^{-1}$ and $u^{\mu-1}$: the
geometric mean is $\bigl(u^{-(\mu-1)}u^{\mu-1}\bigr)^{1/\mu}=1$. It is the exact
statement that the shape function of §5 is minimised at $1$.

The next definition is the conceptual heart of the paper.

**Definition 2.3 (Balanced point).** Given $q>0$, $\mu>1$ and $A>0$, a point $t>0$ is
*balanced* if
$$A \;=\; q(\mu-1)\,t^{\mu},$$
equivalently $\dfrac{A}{t} = (\mu-1)\cdot q\,t^{\mu-1}$: the amortised setup equals
$(\mu-1)$ times the marginal multiplication penalty.

**Lemma 2.4 (Factorisation around a balanced point).** For $t, k > 0$,
$$\frac{q(\mu-1)t^{\mu}}{k} + q\,k^{\mu-1}
\;=\; q\,t^{\mu-1}\left(\frac{\mu-1}{k/t} + \left(\frac{k}{t}\right)^{\mu-1}\right).$$

*Proof sketch.* Write $k = (k/t)\cdot t$, use $(xy)^{p} = x^{p}y^{p}$ for positive
$x,y$ and $t\cdot t^{\mu-1}=t^{\mu}$, then clear denominators. $\square$

**Theorem 2.5 (Balance principle).** Let $q>0$, $\mu>1$, $t>0$ and suppose
$A = q(\mu-1)t^{\mu}$. Then for all $k>0$,
$$q\,\mu\,t^{\mu-1} \;\le\; \frac{A}{k} + q\,k^{\mu-1},$$
with equality at $k=t$ and strict inequality for $k \ne t$.

*Proof sketch.* Substitute the factorisation of Lemma 2.4 and apply Lemma 2.2 with
$u = k/t$, scaling by the positive factor $q\,t^{\mu-1}$. Equality at $k=t$ follows
from $t\cdot t^{\mu-1} = t^{\mu}$:
$A/t + q t^{\mu-1} = q(\mu-1)t^{\mu-1} + qt^{\mu-1} = q\mu t^{\mu-1}$. $\square$

Theorem 2.5 already contains the root law; what remains is bookkeeping to identify
the balanced point in closed form and to evaluate the optimal value.

---

## 3. The root law

**Lemma 3.1.** For $A,q>0$ and $\mu>1$, $k^{*} = (A/((\mu-1)q))^{1/\mu}$ is positive
and balanced: $A = q(\mu-1)(k^{*})^{\mu}$.

*Proof sketch.* Positivity is immediate from positivity of the base. Raising to the
$\mu$: $((A/((\mu-1)q))^{1/\mu})^{\mu} = A/((\mu-1)q)$ since $(1/\mu)\cdot\mu = 1$
and the base is positive; multiply out. $\square$

**Lemma 3.2 (Equipartition at the optimum).** With $A,q>0$, $\mu>1$,
$$\frac{A}{k^{*}} \;=\; (\mu-1)\bigl(q\,(k^{*})^{\mu-1}\bigr).$$
At $\mu=2$ this is the classical "setup share equals penalty share"; as $\mu \downarrow 1$ the setup share collapses, which is precisely why the optimum escapes
to infinity.

**Lemma 3.3 (Closed form of the optimal value).**
$$q\,\mu\,(k^{*})^{\mu-1} \;=\; \mu(\mu-1)^{\frac{1-\mu}{\mu}}A^{\frac{\mu-1}{\mu}}q^{\frac{1}{\mu}}.$$

*Proof sketch.* $(k^{*})^{\mu-1} = (A/((\mu-1)q))^{(\mu-1)/\mu}$ by the power rule.
Split the quotient with $(x/y)^{p} = x^{p}/y^{p}$ and $(xy)^{p} = x^{p}y^{p}$, use
$(\mu-1)^{(1-\mu)/\mu} = \bigl((\mu-1)^{(\mu-1)/\mu}\bigr)^{-1}$ and
$q/q^{(\mu-1)/\mu} = q^{1/\mu}$ (because $1/\mu = 1-(\mu-1)/\mu$). $\square$

**Theorem 3.4 (Root law).** Let $A, q > 0$ and $\mu > 1$. Then for every $k > 0$,
$$C^{*}(A,c,q,\mu) \;\le\; C_{A,c,q,\mu}(k),$$
with equality if and only if $k = k^{*}(A,q,\mu)$. Consequently the set of attained
costs $\{C(k) : k>0\}$ has least element $C^{*}$, and
$$\exists!\, t>0 \ \text{such that}\ \forall k>0,\ C(t) \le C(k).$$

*Proof sketch.* By Lemma 3.1, $k^{*}$ is balanced, so Theorem 2.5 gives
$q\mu(k^{*})^{\mu-1} \le A/k + qk^{\mu-1}$ for all $k>0$, strictly unless $k=k^{*}$.
Adding $c - q$ to both sides and rewriting the left-hand side with Lemma 3.3 yields
$C^{*} \le C(k)$, with equality iff $k = k^{*}$. The $\exists!$ statement follows:
$k^{*}$ is a minimiser, and any minimiser $t$ satisfies $C(t) \le C(k^{*}) = C^{*}$,
which forces $t = k^{*}$ by the strictness clause. $\square$

Theorem 3.4 refutes, for this cost model, the alternative hypothesis that the
optimum might fail to be unique or fail to be of root type. Whatever additional
structure a real machine exhibits (cache tiers, allocator behaviour, threshold
switching inside the arithmetic library), it is *not* captured by this model — the
model itself has exactly one optimum, always a root.

---

## 4. Specialisations and degeneracies

### 4.1 Schoolbook arithmetic: $\mu = 2$

**Proposition 4.1.** $C_{A,c,q,2}(k) = A/k + c + q(k-1)$, and
$$k^{*}(A,q,2) = \sqrt{A/q}, \qquad C^{*}(A,c,q,2) = c - q + 2\sqrt{Aq}.$$
Hence for $A,q>0$ and $k>0$,
$$\frac{A}{k}+c+q(k-1) = c - q + 2\sqrt{Aq} \iff k = \sqrt{A/q}.$$

*Proof sketch.* Substitute $\mu = 2$ in Definitions 1.1–1.2 and simplify
$(\cdot)^{1/2} = \sqrt{\cdot}$, $(\mu-1)^{(1-\mu)/\mu} = 1$,
$A^{1/2}q^{1/2} = \sqrt{Aq}$. The equivalence is Theorem 3.4 at $\mu=2$. $\square$

The classical square-root rule is therefore not a separate fact but the $\mu = 2$
shadow of the root law.

### 4.2 The flat model: $\mu = 1$

**Proposition 4.2.** $C_{A,c,q,1}(k) = A/k + c$; for $A>0$ this is strictly
decreasing in $k$, so for every $k>0$ there is $k' > k$ with $C(k') < C(k)$: no
interior optimum exists.

*Proof sketch.* At $\mu=1$ the penalty is $q(k^{0}-1) = 0$. Strict antitonicity of
$k \mapsto A/k$ for $A>0$ is immediate. $\square$

This is the "bigger is always better" regime: in an operation-count model, or with
idealised linear-time multiplication, batching never reverses.

### 4.3 The transition: how the optimum escapes

**Theorem 4.3 (Divergence as $\mu \downarrow 1$).** Let $q>0$, $1<\mu\le 2$ and
$M \ge 1$. If
$$\mu - 1 \;\le\; \frac{A}{q\,M^{2}},$$
then $k^{*}(A,q,\mu) \ge M$.

*Proof sketch.* The hypothesis gives $(\mu-1)qM^{2} \le A$, i.e. $M^{2} \le A/((\mu-1)q)$. Since $M \ge 1$ and $\mu \le 2$ we have $M^{\mu} \le M^{2}$, hence
$M^{\mu} \le A/((\mu-1)q)$; raising to the power $1/\mu$ and using
$(M^{\mu})^{1/\mu} = M$ finishes. $\square$

**Theorem 4.4 (Antitonicity in the exponent).** Let $A,q>0$ and $1 < \mu_1 \le \mu_2$, and assume $(\mu_1-1)q \le A$ (equivalently $k^{*}(A,q,\mu_1)\ge 1$). Then
$$k^{*}(A,q,\mu_2) \;\le\; k^{*}(A,q,\mu_1).$$

*Proof sketch.* Two monotonicity steps on $B_i := A/((\mu_i-1)q)$. First
$B_2 \le B_1$ and $x \mapsto x^{1/\mu_2}$ is monotone on $[0,\infty)$, so
$B_2^{1/\mu_2} \le B_1^{1/\mu_2}$. Second, $B_1 \ge 1$ and $1/\mu_2 \le 1/\mu_1$, so
$B_1^{1/\mu_2} \le B_1^{1/\mu_1}$. $\square$

**Example 4.5.** With $A = 1000$, $q = 10^{-3}$: $k^{*}(\mu=2) = \sqrt{10^{6}} = 1000$, while $k^{*}(\mu=3/2) = (2\cdot10^{6})^{2/3} \approx 15874 > 1000$.
Sub-quadratic arithmetic strictly increases the optimal batch.

---

## 5. Geometry of the cost curve

### 5.1 Universal collapse

**Definition 5.1 (Shape function).** For $\mu, \theta$ with $\theta>0$,
$$S_{\mu}(\theta) \;:=\; \frac{\mu-1}{\theta} + \theta^{\mu-1}.$$
Note $S_{\mu}(1) = \mu$.

**Theorem 5.2 (Universal collapse).** For $A,q>0$, $\mu>1$, $\theta>0$,
$$C_{A,c,q,\mu}\bigl(\theta\,k^{*}\bigr) \;=\; (c-q) \;+\; q\,(k^{*})^{\mu-1}\cdot S_{\mu}(\theta).$$
In particular $C^{*} = (c-q) + q(k^{*})^{\mu-1}\mu$.

*Proof sketch.* Apply Lemma 2.4 with $t = k^{*}$, $k = \theta k^{*}$, so that
$k/t = \theta$, and substitute the balance relation $A = q(\mu-1)(k^{*})^{\mu}$ of
Lemma 3.1. The constant terms $c - q$ are untouched. Setting $\theta = 1$ and using
$S_\mu(1)=\mu$ together with Theorem 3.4 gives the value statement. $\square$

Interpretation: measured in units of the optimal batch, *every* batching cost curve
with the same multiplication exponent is the same curve. The setup $A$ and the
penalty $q$ enter only through the vertical scale $q(k^{*})^{\mu-1}$ and the additive
offset $c-q$. Two consequences: (a) cost curves from different machines can be
overlaid after a two-parameter rescaling; (b) any measured feature that survives the
collapse — for example a second local minimum — is evidence of structure *outside*
the model.

### 5.2 The optimum is a plateau

**Theorem 5.3 (Lower bound).** For $\mu \ge 1$ and $\theta > 0$, $S_{\mu}(\theta) \ge \mu$. (This is Lemma 2.2.)

**Theorem 5.4 (Quadratic flatness).** For $1 < \mu \le 2$ and $\theta > 0$,
$$S_{\mu}(\theta) \;\le\; \mu + \frac{(\mu-1)(\theta-1)^{2}}{\theta}.$$

*Proof sketch.* The reverse Bernoulli inequality for exponents in $[0,1]$ gives
$\theta^{\mu-1} \le 1 + (\mu-1)(\theta-1)$ (valid since $0 \le \mu - 1 \le 1$).
Multiply the claim through by $\theta > 0$: it becomes
$(\mu-1) + \theta^{\mu} \le \mu\theta + (\mu-1)(\theta-1)^{2}$ after collecting terms,
which follows from the displayed bound together with $\theta>0$ by elementary
algebra. $\square$

**Corollary 5.5 (Cost of mis-sizing).** For $A,q>0$, $1<\mu\le2$, $\theta>0$,
$$C\bigl(\theta k^{*}\bigr) \;\le\; C^{*} \;+\; q\,(k^{*})^{\mu-1}\cdot\frac{(\mu-1)(\theta-1)^{2}}{\theta}.$$

Numerically, in shape units the relative overhead of using $\theta k^{*}$ instead of
$k^{*}$ is at most $\frac{\mu-1}{\mu}\cdot\frac{(\theta-1)^{2}}{\theta}$. For
$\mu = 2$: $\theta = 1.2$ costs at most $1.7\%$; $\theta = 2$ at most $25\%$;
$\theta = 1.05$ at most $0.12\%$. The excess is $O((\theta-1)^{2})$, and the
prefactor $\mu-1$ shrinks with the exponent, so faster arithmetic yields flatter
plateaus. This is why measured optima are broad regions rather than sharp minima,
and why a coarse geometric grid search suffices in practice.

### 5.3 Scaling and homogeneity

**Proposition 5.6.** For $\lambda>0$, $A,q>0$, $\mu>1$:
1. $k^{*}(\lambda A, q, \mu) = \lambda^{1/\mu}\,k^{*}(A,q,\mu)$;
2. $k^{*}(A, \lambda q, \mu) = \lambda^{-1/\mu}\,k^{*}(A,q,\mu)$;
3. $k^{*}(\lambda A, \lambda q, \mu) = k^{*}(A,q,\mu)$;
4. $A_1 < A_2 \implies k^{*}(A_1,q,\mu) < k^{*}(A_2,q,\mu)$;
5. $C^{*}(\lambda A, c, \lambda q, \mu) - (c - \lambda q) = \lambda\bigl(C^{*}(A,c,q,\mu) - (c-q)\bigr)$.

*Proof sketch.* (1)–(3) follow from $(\lambda x)^{p} = \lambda^{p}x^{p}$ and
$(\lambda^{-1})^{p} = \lambda^{-p}$ applied to the base $A/((\mu-1)q)$. (4) is strict
monotonicity of $x \mapsto x^{1/\mu}$. (5) follows from
$\lambda^{(\mu-1)/\mu}\lambda^{1/\mu} = \lambda$ applied to the closed form of
$C^{*}$. $\square$

Item (5) with (3) is the precise sense in which library-level constant factors
**relocate but never remove** the optimum: scaling setup and penalty together leaves
the optimal batch fixed and multiplies the excess cost by the same factor, while
scaling them separately moves the optimum by a $\mu$-th root of the ratio.

### 5.4 Multiplicative convexity, and the failure of ordinary convexity

**Theorem 5.7 (Geometric convexity).** Let $A, q \ge 0$, $k_1,k_2>0$ and
$w \in [0,1]$. Then for every $\mu$,
$$C_{A,c,q,\mu}\bigl(k_1^{w}k_2^{1-w}\bigr) \;\le\; w\,C_{A,c,q,\mu}(k_1) + (1-w)\,C_{A,c,q,\mu}(k_2).$$

*Proof sketch.* Treat the two nonconstant terms separately, each by the two-point
weighted AM–GM inequality $x^{w}y^{1-w} \le wx + (1-w)y$ for $x,y\ge0$.
For the setup term, $A/(k_1^{w}k_2^{1-w}) = (A/k_1)^{w}(A/k_2)^{1-w}$; for the
penalty term, $(k_1^{w}k_2^{1-w})^{\mu-1} = (k_1^{\mu-1})^{w}(k_2^{\mu-1})^{1-w}$.
Multiply the penalty bound by $q \ge 0$ and add. $\square$

Equivalently: $\log k \mapsto C(e^{\log k})$ is convex. This is the structural reason
the optimum is a *root* of $A/q$: in logarithmic coordinates the cost is a sum of two
exponentials with slopes $-1$ and $\mu-1$, whose minimiser is a weighted geometric
mean of the parameters with weights $\bigl(\tfrac{1}{\mu}, \tfrac{\mu-1}{\mu}\bigr)$.

**Theorem 5.8 (Ordinary convexity fails below $\mu = 2$).** The function
$k \mapsto C_{1,0,1,3/2}(k) = 1/k + \sqrt{k} - 1$ is not convex on $(0,\infty)$. An
explicit witness: with $k_1 = 4$, $k_2 = 100$, midpoint $52$,
$$\tfrac12\bigl(C(4) + C(100)\bigr) \;<\; C(52).$$

*Proof sketch.* $C(4) = 1/4 + 2 - 1 = 1.25$ and $C(100) = 1/100 + 10 - 1 = 9.01$, so
the average is $5.13$. On the other hand $\sqrt{52} > 7.2$, so
$C(52) > 1/52 + 7.2 - 1 > 6.2 > 5.13$. $\square$

For $\mu = 2$ the cost *is* convex ($A/k$ and $qk$ are both convex), so Theorem 5.8
isolates a genuinely sub-quadratic phenomenon: below the quadratic model, convexity
survives only in the multiplicative sense. Practically, this means that optimisation
routines that assume convexity in $k$ (Newton on the raw variable, secant bracketing
with convexity certificates) lose their guarantees, while the same routines applied
to $\log k$ remain valid.

---

## 6. Unimodality and the discrete optimum

An implementation must choose an integer batch size. A priori, knowing the real
minimiser $k^{*}$ says nothing about $\arg\min_{n \in \mathbb{Z}_{\ge1}} C(n)$: a
function can have its real minimum in one place and its integer minimum far away.
Strict unimodality rules this out.

**Lemma 6.1 (Auxiliary setups).** Let $A,q>0$, $\mu>1$ and put $A'(k) := q(\mu-1)k^{\mu}$, so that $k$ is the balanced point of the cost with setup $A'(k)$.
Then $A'(k) \le A$ for $0 < k \le k^{*}$ and $A'(k) \ge A$ for $k \ge k^{*}$.

*Proof sketch.* $A = q(\mu-1)(k^{*})^{\mu}$ and $x \mapsto x^{\mu}$ is monotone on
$[0,\infty)$. $\square$

**Theorem 6.2 (Strict unimodality).** Let $A,q>0$, $\mu>1$.
1. $C$ is strictly decreasing on $(0,k^{*}]$: if $0<k_1<k_2\le k^{*}$ then
   $C(k_2) < C(k_1)$.
2. $C$ is strictly increasing on $[k^{*},\infty)$: if $k^{*}\le k_1 < k_2$ then
   $C(k_1) < C(k_2)$.

*Proof sketch (balance shift).* For (1), set $A' := q(\mu-1)k_2^{\mu}$, so $k_2$ is
the balanced point of the auxiliary cost with setup $A'$. Theorem 2.5 gives
$$\frac{A'}{k_2} + q k_2^{\mu-1} \;=\; q\mu k_2^{\mu-1} \;<\; \frac{A'}{k_1} + q k_1^{\mu-1}.$$
By Lemma 6.1, $A' \le A$, and the discrepancy between the true and auxiliary costs is
$(A-A')/k$, which is nonincreasing in $k$: $(A-A')/k_2 \le (A-A')/k_1$. Writing
$A/k_i = A'/k_i + (A-A')/k_i$ and adding the two displayed relations gives
$C(k_2) < C(k_1)$. Part (2) is symmetric with $A' := q(\mu-1)k_1^{\mu} \ge A$ and the
discrepancy $-(A'-A)/k$. $\square$

The point of the argument is that it is *entirely order-theoretic*: it uses no
derivative, only the balance principle applied to a shifted problem plus the
monotonicity of $k \mapsto 1/k$.

**Theorem 6.3 (The best integer batch is a neighbour of $k^{*}$).** Let $A,q>0$,
$\mu>1$. For every integer $n \ge 1$,
$$\min\Bigl\{\,C\bigl(\max(1,\lfloor k^{*}\rfloor)\bigr),\ C\bigl(\lceil k^{*}\rceil\bigr)\Bigr\} \;\le\; C(n).$$

*Proof sketch.* If $n \le k^{*}$ then $n \le \lfloor k^{*}\rfloor$, and by Theorem
6.2(1) applied on $(0,k^{*}]$ we get $C(\lfloor k^{*}\rfloor) \le C(n)$ (equality if
$n = \lfloor k^{*}\rfloor$). If $n > k^{*}$ then $\lceil k^{*}\rceil \le n$, and
Theorem 6.2(2) gives $C(\lceil k^{*}\rceil) \le C(n)$. In either case the minimum of
the two neighbour costs bounds $C(n)$. The clamp $\max(1,\cdot)$ only matters when
$k^{*}<1$, where $\lfloor k^{*}\rfloor = 0$ is not an admissible batch and the
smallest admissible batch $n=1$ is optimal. $\square$

**Corollary 6.4 (Search correctness).** Since $C$ is strictly unimodal on
$(0,\infty)$ and its restriction to the integers inherits unimodality, ternary search
(or the Fibonacci/golden-section search) over an integer bracket $[1, N]$ containing
$\lceil k^{*}\rceil$ returns the exact discrete optimum in $O(\log N)$ evaluations;
no local minimum can trap it.

---

## 7. The batch-versus-solo crossover

The tuning question in the field is binary: *should I batch this pool at all?*

**Definition 7.1 (Solo and batch per-candidate costs at exponent $\mu$).** Let $s_1$
be the cost of testing one candidate alone, $c_1$ the flat per-candidate cost inside
a batch and $q$ the multiplication-penalty scale. The per-candidate batch cost for a
pool of size $k$ is
$$B_{\mu}(k) \;=\; q\bigl(k^{\mu-1}-1\bigr) + c_1 .$$
(At $\mu=2$ this is the per-candidate form of the schoolbook word-model batch cost.)

**Definition 7.2 (Crossover pool size).** For $q>0$, $\mu>1$,
$$M^{*}(\mu) \;:=\; \left(1 + \frac{s_1-c_1}{q}\right)^{\frac{1}{\mu-1}} .$$

**Theorem 7.3 (Root form of the crossover).** Let $q>0$, $\mu>1$, $k>0$ and assume
$1 + (s_1-c_1)/q \ge 0$. Then
$$B_{\mu}(k) \le s_1 \iff k \le M^{*}(\mu).$$

*Proof sketch.* Rearranging, $B_{\mu}(k) \le s_1$ is equivalent to
$k^{\mu-1} \le (q + s_1 - c_1)/q = 1 + (s_1-c_1)/q$. Since $\mu-1>0$, the map
$x \mapsto x^{\mu-1}$ is a strictly increasing bijection of $[0,\infty)$, and
$\bigl(M^{*}(\mu)\bigr)^{\mu-1} = 1 + (s_1-c_1)/q$ because
$\tfrac{1}{\mu-1}\cdot(\mu-1) = 1$. Comparing $k^{\mu-1}$ with
$(M^{*})^{\mu-1}$ therefore compares $k$ with $M^{*}$. $\square$

**Corollary 7.4 (Schoolbook specialisation).** $M^{*}(2) = 1 + (s_1-c_1)/q$. The
crossover in the schoolbook word model is *linear* in the setup/penalty ratio; the
linearity is an artefact of $\mu=2$, not a feature of batching. Calibrated to a
measured crossover of $1715$ candidates, the calibration reads $s_1 - c_1 = 1714\,q$.

**Theorem 7.5 (Sub-quadratic arithmetic only delays the reversal).** If $q>0$,
$1<\mu\le2$ and $c_1 \le s_1$, then $M^{*}(2) \le M^{*}(\mu)$.

*Proof sketch.* Write $R := 1 + (s_1-c_1)/q \ge 1$. Since $\mu \le 2$ we have
$1/(\mu-1) \ge 1$, and $x \mapsto R^{x}$ is nondecreasing for $R \ge 1$; hence
$R^{1} \le R^{1/(\mu-1)}$. $\square$

**Theorem 7.6 (Divergence of the crossover as $\mu \downarrow 1$).** Let $q>0$,
$\mu>1$, $c_1 \le s_1$, $M \ge 1$, and put $R := 1 + (s_1-c_1)/q$. If
$$(\mu-1)\log M \;\le\; \log R,$$
then $M \le M^{*}(\mu)$.

*Proof sketch.* The hypothesis is $\log M \le \tfrac{1}{\mu-1}\log R$, which by
$M > 0$, $R > 0$ is exactly the logarithmic form of $M \le R^{1/(\mu-1)}$. $\square$

So for any target pool size $M$, all exponents $\mu \le 1 + \log R/\log M$ have no
reversal below $M$. With $R = 1715$ and $M = 512$ this covers every
$\mu \le 1 + \log 1715/\log 512 \approx 2.19$ — comfortably including the whole
sub-quadratic range, which is why measurements in the operation-count model up to
$k = 512$ observed no reversal.

**Proposition 7.7 (Calibrated Karatsuba-range instance).** If $s_1 - c_1 = 1714\,q$
with $q>0$, then $M^{*}(3/2) = 1715^{2} = 2\,941\,225$.

*Proof sketch.* $R = 1715$ and $1/(\mu-1) = 2$ at $\mu = 3/2$. $\square$

The reversal that was measured at $1715$ candidates in the schoolbook model would,
with $\mu = 3/2$ arithmetic, occur only beyond $2.9\times10^{6}$ candidates — far
outside any realistic pool. In this precise sense the reversal is a property of
schoolbook arithmetic.

---

## 8. Algorithms

Three procedures fall directly out of the theory.

**Algorithm A (Closed-form batch sizing).** Given calibration constants
$(A, c, q, \mu)$, return $k^{*} = (A/((\mu-1)q))^{1/\mu}$ if $\mu>1$, and report "no
finite optimum — take the largest feasible batch" if $\mu \le 1$. Then return
$\arg\min$ over $\{\max(1,\lfloor k^{*}\rfloor), \lceil k^{*}\rceil\}$ of $C$, which
by Theorem 6.3 is the exact integer optimum. Cost: $O(1)$ transcendental operations.

**Algorithm B (Calibration by three measurements).** The model has three free
parameters at fixed $\mu$. Measuring per-candidate cost $y_i$ at three batch sizes
$k_i$ gives a linear system in $(A, c, q)$ with rows $(1/k_i,\ 1,\ k_i^{\mu-1}-1)$;
solve it (or least-squares over more points) and feed the result to Algorithm A. If
$\mu$ is itself unknown, fit it by one-dimensional search: for each candidate $\mu$
the inner problem is linear, so the outer problem is a well-conditioned scalar fit.
The universal collapse (Theorem 5.2) provides the diagnostic: after rescaling to
shape coordinates, points from *all* calibrations must fall on the single curve
$S_\mu$; systematic deviation indicates model failure (e.g. a cache tier).

**Algorithm C (Model-free ternary search).** If the cost is only available as a
black-box measurement, exploit Theorem 6.2: the function is strictly unimodal, so
integer ternary search on a bracket $[1,N]$ converges to the exact discrete optimum
in $O(\log N)$ measurements. This requires no knowledge of $A$, $c$, $q$ or $\mu$ and
is the recommended autotuning strategy; the closed form then serves as a
sanity check and as an extrapolation device across machines.

---

## 9. Applications and discussion

**Batch smoothness testing.** The originating application. The theory says: (i) the
reversal is real but attributable to the multiplication exponent; (ii) the optimum
is a $\mu$-th root of the setup/penalty ratio; (iii) the crossover pool size is a
$1/(\mu-1)$-th root of the same ratio; (iv) all of it is robust to library constant
factors, which merely relocate the optimum.

**Inventory theory and beyond.** At $\mu = 2$ the root law is the economic order
quantity formula $Q^{*} = \sqrt{2DK/h}$: setup $\leftrightarrow$ ordering cost,
penalty $\leftrightarrow$ holding cost. The root law generalises EOQ to holding costs
that grow like a power of the order size, with the same balance interpretation — at
the optimum, ordering cost is $(\mu-1)$ times holding cost.

**Systems tuning generally.** Any amortisation problem of the form "fixed cost per
group, super-linear cost within a group" is an instance: I/O blocking, GPU kernel
batching, cryptographic batch verification, database bulk inserts, gradient
accumulation in machine learning. The plateau theorem is the practically important
one: within a factor of two of $k^{*}$ the overhead is bounded by $(\mu-1)/2$ in
shape units, so exact tuning is rarely worth the engineering.

**What the model does not capture.** The universal collapse theorem is a sharp
falsifiability statement: a single-tier model has *exactly one* optimum. Any measured
cost curve with two local minima is therefore outside the model, and the most likely
culprit is a memory hierarchy — the effective exponent $\mu$ jumps when the working
set spills a cache level. Similarly, real multiplication libraries switch algorithms
at thresholds, so $\mu$ is piecewise constant in the operand size, hence in $k$.

---

## 10. Future work

1. **Cache-tier cost laws and piecewise root optima.** A memory hierarchy makes the
   multiplication exponent a step function of the batch size, so the global cost is a
   finite gluing of root laws, each valid on its own tier, and the true optimum is the
   best of finitely many tier-local optima — a discrete selection problem on top of a
   continuous one. The universal-collapse theorem makes this testable: a single-tier
   model has exactly one optimum, so any measured second local minimum is direct
   evidence of a tier boundary, and the collapse gives a parameter-free way to detect
   it.
2. **Root laws for arbitrary superadditive penalty profiles.** The balance principle
   never used the specific form $k^{\mu-1}$; it used only that the penalty is
   multiplicatively convex and that the amortised setup $A/k$ is multiplicatively
   convex with the opposite slope. Replacing $k^{\mu-1}$ by an arbitrary regularly
   varying penalty $P(k)$ should give a unique optimum wherever the elasticity
   $kP'(k)/P(k)$ crosses $1$, with the root law as the constant-index case. This is
   the regime FFT multiplication lives in: $k\log k\log\log k$ is not a pure power,
   but its index is slowly varying.
3. **Sharp constant in the flatness bound.** The bound $(\mu-1)(\theta-1)^{2}/\theta$
   is Bernoulli-derived, whereas the true excess $S_\mu(\theta) - \mu$ has exact
   Taylor coefficient $\mu(\mu-1)/2$ at $\theta = 1$. Identifying the largest interval
   on which the crude bound stays within a fixed factor of the truth would convert
   the qualitative "plateau" statement into a quantitative tuning tolerance.
4. **Stochastic batch sizes and heterogeneous candidates.** Real streams have
   variable candidate sizes; the effective batch length is then random, and the
   relevant object is $\mathbb{E}[C]$. Multiplicative convexity suggests studying the
   problem in log-coordinates, where Jensen's inequality gives a clean one-sided
   bound.
5. **Multi-level batching.** Product trees are themselves recursive batchings.
   Optimising the branching factor at each level of a tree, with a root law at each
   level, is a natural nested version of the present problem.

---

## 11. Conclusion

The per-candidate cost of batching, $A/k + c + q(k^{\mu-1}-1)$, has for every
multiplication exponent $\mu > 1$ a unique optimal batch size
$k^{*} = (A/((\mu-1)q))^{1/\mu}$ with optimal cost
$c - q + \mu(\mu-1)^{(1-\mu)/\mu}A^{(\mu-1)/\mu}q^{1/\mu}$, and it degenerates to
"bigger is always better" exactly at $\mu = 1$. The classical square-root rule is the
$\mu = 2$ case. The curve collapses to a universal two-parameter shape, the optimum
is a quadratically flat plateau, the cost is multiplicatively (but for $\mu<2$ not
additively) convex, the discrete optimum is a neighbour of $k^{*}$, and the
batch-versus-solo crossover is a $1/(\mu-1)$-th root of the setup/penalty ratio. The
measured reversal in batch smoothness testing is thereby explained as a property of
schoolbook arithmetic rather than of batching.
