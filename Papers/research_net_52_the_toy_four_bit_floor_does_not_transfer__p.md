# The Arithmetic of Round-to-Nearest Quantization: Sharp Mesh Constants, Sawtooth Bias, and the Non-Existence of a Bit-Only Damage Floor

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Uniform round-to-nearest (RTN) quantization of neural network weights is
commonly discussed in terms of a *bit floor*: a claim that a given bit budget
costs at most a given amount of accuracy. We show that no such claim can be a
theorem. The worst-case defect of an absmax $b$-bit RTN quantizer applied to a
width-$n$ tensor of amplitude $A$, transferred through a $K$-Lipschitz loss, is
exactly $K n A / 2^{b+1}$, and this value is attained; consequently, for every bit
budget $b$ and every damage budget $c$ there exists an amplitude, a weight tensor
of that amplitude, and a $1$-Lipschitz loss on which the $b$-bit quantizer causes
damage exceeding $c$. A floor stated in bits alone is therefore vacuous — it is a
statement about the amplitudes of the tensors on which it was calibrated.

Around this negative result we develop the exact arithmetic of RTN meshes. We
prove: (i) the mesh bound $|\mathrm{round}_\Delta(x) - x| \le \Delta/2$ with the
constant $1/2$ sharp, and the exact halving law $\Delta(b+1) = \Delta(b)/2$;
(ii) an exact grouping gain, namely that partitioning a tensor into groups
replaces the maximum group amplitude by the mean and repairs exactly half the
total amplitude deficit; (iii) an exact period sum for the *signed* rounding
error on a $q$-level mesh, $\lfloor q/2 \rfloor - (q-1)/2$, which is $0$ for odd
$q$ and $1/2$ for even $q$, hence every dyadic (hardware) grid carries an
irreducible half-step bias, and this first moment is invariant under every
coprime multiplier; (iv) a bridge to extremal graph theory: the integer $L^1$
rounding energy of a $q$-level mesh equals the Mantel–Turán number
$\lfloor q^2/4 \rfloor = \mathrm{ex}(q; K_3)$; (v) an exact single-layer
sensitivity for a product network, showing that sensitivity is *antitone* in a
layer's own weight magnitude, so an observed depth gradient measures the depth
profile of amplitudes rather than depth itself; and (vi) an AM–GM water-filling
law for optimal mixed-precision allocation, with the optimum $b_i = B/n +
\log_2 A_i - \overline{\log_2 A}$ and a witness that uniform precision is
strictly suboptimal.

These results were developed alongside a controlled measurement campaign on a
pretrained $0.5$B-parameter transformer, in which naive per-channel four-bit RTN
cost $+0.79$ nats of cross-entropy against a $\le 0.05$ prediction inherited from
small from-scratch models — a sixteen-fold miss — while grouping by $128$ repaired
roughly $60\%$ of the damage. The theory explains both numbers.

**Keywords:** round-to-nearest quantization, absmax mesh, sawtooth function,
Turán number, Dedekind sums, water-filling, Lipschitz transfer, mixed precision.

---

## 1. Introduction

### 1.1 The empirical provocation

Post-training quantization replaces each real weight by a nearby point of a
coarse grid. The simplest scheme, *absmax round-to-nearest*, computes the largest
magnitude $A$ in a tensor (or in a channel, or in a group of consecutive weights),
lays down $2^{b+1}$ evenly spaced levels of spacing $\Delta = A/2^b$ across
$[-A, A]$, and rounds every weight to the nearest level. It has no calibration
data, no optimization, and no hyperparameters beyond $b$ and the scope of $A$.

A body of experience on small networks trained from scratch had suggested that
$b = 4$ is essentially free. Applying exactly that scheme, per output channel, to
every linear weight of a pretrained $0.5$B-parameter transformer produced the
following (baseline cross-entropy reproduced bit-exactly at $2.8697$, baseline
accuracy $0.4460$):

| arm | $\Delta$CE | retained accuracy |
|---|---|---|
| 8-bit | $+0.0044$ | $0.9985$ |
| 6-bit | $+0.0353$ | $0.9904$ |
| 5-bit | $+0.1281$ | $0.9620$ |
| **4-bit** | **$+0.7879$** | **$0.7630$** |
| 3-bit | $+9.2262$ | $0.0367$ |
| 2-bit | $+14.0588$ | $0.0001$ |
| 4-bit, first 12 layers only | $+0.3885$ | $0.8904$ |
| 4-bit, last 12 layers only | $+0.4054$ | $0.8635$ |
| 4-bit, group-128 | $+0.3180$ | $0.9060$ |
| 3-bit, group-128 | $+2.7220$ | $0.3987$ |

Four qualitative facts stand out: damage is strictly monotone in the mesh and
already nonzero at eight bits; the cliff between five and three bits is severe;
the deeper half is slightly worse than the shallower half; and grouping — a change
in the *scope* of the amplitude, not in the bit count — repairs about $60\%$ of the
four-bit damage and rescues the three-bit arm from destruction.

### 1.2 What this paper does

We isolate the arithmetic responsible for each of these facts and prove it
exactly. The organising observation is that **the bit budget never appears
alone**: it appears only inside the mesh $\Delta = A/2^b$, always multiplied by an
amplitude. Every sharp constant we establish is therefore a constant in
$(A, n, b)$, never in $b$; and the impossibility of a bit-only floor
(Theorem 3.7) is the immediate consequence.

Sections 2–3 develop the scalar and vector mesh theory and the non-transfer
theorem. Section 4 studies the *signed* error and its rigidity. Section 5
establishes the Turán bridge for the *absolute* error. Section 6 treats depth
compounding and layer sensitivity. Section 7 gives the mixed-precision optimum.
Section 8 returns to the measurements. Section 9 discusses limitations and open
problems.

---

## 2. The scalar quantizer and its sharp constant

**Definition 2.1 (RTN).** For $\Delta > 0$, the *round-to-nearest quantizer* onto
the mesh $\Delta\mathbb{Z}$ is
$$\mathrm{rtn}_\Delta(x) \;=\; \Delta \cdot \mathrm{round}(x/\Delta),$$
where $\mathrm{round}$ maps a real to a nearest integer, breaking ties upwards.

**Definition 2.2 (absmax mesh).** For a tensor of amplitude $A > 0$ and a bit
budget $b \in \mathbb{N}$, the mesh is $\Delta(A, b) = A / 2^b$.

**Proposition 2.3 (halving and monotonicity).** $\Delta(A, b+1) = \Delta(A,b)/2$;
consequently $b \mapsto \Delta(A,b)$ is strictly decreasing for $A > 0$, and
strictly positive for every $b$. Moreover $A \le A'$ implies
$\Delta(A,b) \le \Delta(A',b)$.

*Proof.* $A/2^{b+1} = (A/2^b)/2$; strict antitonicity follows from
$2^b < 2^c$ for $b < c$; monotonicity in $A$ from division by a positive
quantity. $\square$

The last clause is the reason grouping works: a group's amplitude never exceeds
the whole tensor's, hence neither does its mesh.

**Theorem 2.4 (mesh bound).** For every $\Delta > 0$ and every $x \in \mathbb{R}$,
$$\bigl|\mathrm{rtn}_\Delta(x) - x\bigr| \;\le\; \frac{\Delta}{2}.$$

*Proof.* $\mathrm{rtn}_\Delta(x) - x = \Delta\bigl(\mathrm{round}(x/\Delta) - x/\Delta\bigr)$,
and the distance from a real to a nearest integer is at most $1/2$; multiply by
$\Delta > 0$. $\square$

**Theorem 2.5 (exact attainment).** $\mathrm{rtn}_\Delta(\Delta/2) = \Delta$, hence
$\mathrm{rtn}_\Delta(\Delta/2) - \Delta/2 = \Delta/2$ exactly.

*Proof.* $(\Delta/2)/\Delta = 1/2$, and rounding $1/2$ with upward tie-breaking
gives $1$. $\square$

**Corollary 2.6 (the constant $1/2$ is sharp).** If $c \in \mathbb{R}$ satisfies
$|\mathrm{rtn}_\Delta(x) - x| \le c\,\Delta$ for all $x$, then $c \ge 1/2$.

*Proof.* Evaluate at $x = \Delta/2$ and use Theorem 2.5. $\square$

Corollary 2.6 is the formal content of the experimental observation that the mesh
bound "behaves as if sharp": there is no slack in the constant to be recovered by
a better analysis of RTN. Any improvement must change the *algorithm*, not the
bound.

---

## 3. Tensors, Lipschitz transfer, grouping, and the non-existence of a bit floor

**Definition 3.1.** For $\Delta : \{1,\dots,n\} \to (0,\infty)$ and a weight vector
$w \in \mathbb{R}^n$, the coordinatewise quantizer is
$Q_\Delta(w)_i = \mathrm{rtn}_{\Delta_i}(w_i)$.

**Theorem 3.2 ($L^1$ defect).**
$\sum_{i=1}^n |Q_\Delta(w)_i - w_i| \le \sum_{i=1}^n \Delta_i/2$. In particular for a
uniform mesh $\Delta_i \equiv \Delta$, the bound is $n\Delta/2$.

*Proof.* Sum Theorem 2.4 coordinatewise. $\square$

**Theorem 3.3 (the aggregate bound is attained).** For the all-midpoints tensor
$w_i \equiv \Delta/2$ with uniform mesh $\Delta$,
$$\sum_{i=1}^n |Q_\Delta(w)_i - w_i| = \frac{n\Delta}{2}.$$

*Proof.* Each coordinate contributes exactly $\Delta/2$ by Theorem 2.5. $\square$

**Theorem 3.4 (Lipschitz transfer).** Let $f : \mathbb{R}^n \to \mathbb{R}$ satisfy
$|f(u) - f(v)| \le K \sum_i |u_i - v_i|$ with $K \ge 0$. Then for uniform mesh
$\Delta > 0$ and every $w$,
$$\bigl|f(Q_\Delta(w)) - f(w)\bigr| \;\le\; \frac{K\,n\,\Delta}{2}
\;=\; \frac{K\,n\,A}{2^{\,b+1}}.$$

*Proof.* Compose the Lipschitz hypothesis with Theorem 3.2. $\square$

**Theorem 3.5 (the transfer constant is sharp).** For every $n$ and every
$\Delta > 0$ there exist a $1$-Lipschitz functional $f$ and a weight tensor $w$ with
$$\bigl|f(Q_\Delta(w)) - f(w)\bigr| = \frac{n\Delta}{2}.$$

*Proof.* Take $f(u) = \sum_i u_i$, which is $1$-Lipschitz for the $\ell^1$ metric by
the triangle inequality, and $w_i \equiv \Delta/2$; apply Theorem 3.3, noting that
all coordinate errors have the same sign so no cancellation occurs. $\square$

The sharpness witnesses are exactly the *coherent-sign* configurations: every
coordinate at a cell midpoint, every error pointing the same way. This is worth
holding on to — it is the configuration that error-feedback schemes are designed
to destroy (see §9).

### 3.1 Grouping

Partition a tensor into $n$ groups and let $\Delta_i$ be the mesh of group $i$,
with $D$ the mesh the whole tensor would have had. By Proposition 2.3,
$\Delta_i \le D$ for every $i$.

**Theorem 3.6 (grouping never hurts; strictly helps; exact gain).** If
$\Delta_i \le D$ for all $i$, then $\sum_i \Delta_i/2 \le nD/2$, with strict
inequality as soon as $\Delta_{i_0} < D$ for some $i_0$. Moreover the repaired
damage is exactly
$$\frac{nD}{2} - \sum_{i=1}^n \frac{\Delta_i}{2} \;=\; \frac{1}{2}\sum_{i=1}^n (D - \Delta_i).$$

*Proof.* Summation of inequalities gives the first two claims; the identity is
$\sum_i (D - \Delta_i) = nD - \sum_i \Delta_i$ divided by $2$. $\square$

Reading Theorem 3.6 in terms of amplitudes: the ungrouped guarantee is governed by
$\max_g A_g$ (the global amplitude), the grouped guarantee by
$\mathrm{mean}_g A_g$. The relative repair is therefore
$$1 - \frac{\mathrm{mean}_g A_g}{\max_g A_g},$$
a quantity computable in one pass over a checkpoint. The measured $\approx 60\%$
repair at group-$128$ is a prediction about the amplitude dispersion of the model's
weight channels — the theory says which number to compute.

### 3.2 The main negative result

**Theorem 3.7 (no bits-only damage floor).** For every bit budget
$b \in \mathbb{N}$ and every $c \in \mathbb{R}$ there exist an amplitude $A > 0$, a
weight vector $w$ with $|w_i| \le A$, and a $1$-Lipschitz functional $f$ such that
the $b$-bit absmax RTN quantizer with mesh $\Delta(A,b) = A/2^b$ satisfies
$$\bigl|f(Q_{\Delta(A,b)}(w)) - f(w)\bigr| \;>\; c.$$

*Proof.* Work in dimension $1$. Set $A = (|c| + 1)\,2^{\,b+1}$, so that
$\Delta(A,b)/2 = A/2^{b+1} = |c| + 1$. Take $f(u) = u_1$ (which is $1$-Lipschitz),
and $w_1 = \Delta(A,b)/2$, which satisfies $|w_1| \le A$ because
$\Delta(A,b) = A/2^b \le A$. By Theorem 2.5 the quantizer moves $w_1$ by exactly
$\Delta(A,b)/2 = |c| + 1 > c$. $\square$

**Interpretation.** Any assertion of the form "*$b$ bits cost at most $c$*",
quantified over weight tensors, is false. The bit budget enters the damage only
through the mesh $A/2^b$, and the amplitude $A$ is a free parameter of the input,
not of the scheme. A "four-bit floor" measured on small from-scratch models is a
measurement of *their* amplitude–width profile; transported to a pretrained
transformer, whose per-channel amplitude is set by a small number of outlier
weights, it has no reason to hold and in fact fails by a factor of $16$. Theorem
3.7 upgrades the empirical refutation to a structural one: the refuted hypothesis
was not merely wrong, it was unstatable.

---

## 4. The signed error: exact period bias and multiplier rigidity

Bit budgets aside, rounding has a characteristic waveform whose *first moment* is
exactly computable.

**Definition 4.1 (sawtooth).** $s(x) = \mathrm{round}(x) - x$, the signed rounding
error at unit mesh.

**Proposition 4.2.** $s$ is $1$-periodic, $|s(x)| \le 1/2$ for all $x$, and
$s(1/2) = 1/2$.

**Lemma 4.3 (a period of a rational mesh).** For $0 < j < q$,
$\mathrm{round}(j/q) = 0$ if $2j < q$ and $1$ if $2j \ge q$ (the tie $2j = q$ rounds
up). Consequently $|s(j/q)| = \min(j, q-j)/q$.

**Theorem 4.4 (exact period sum).** For $q \ge 1$,
$$\sum_{j=0}^{q-1} s\!\left(\frac{j}{q}\right)
= \left\lfloor \frac{q}{2} \right\rfloor - \frac{q-1}{2}.$$

*Proof sketch.* Split the sum. The rounded values contribute
$\#\{j < q : 2j \ge q\} = \lfloor q/2 \rfloor$, since the set of such $j$ is the
integer interval $[\lceil q/2 \rceil, q)$. The subtracted arguments contribute
$\sum_{j<q} j/q = (q-1)/2$. $\square$

**Corollary 4.5 (parity dichotomy).**
$$\sum_{j=0}^{q-1} s\!\left(\frac{j}{q}\right) =
\begin{cases} 0, & q \text{ odd},\\[3pt] \tfrac12, & q \text{ even}.\end{cases}$$

*Proof.* For $q = 2m+1$: $\lfloor q/2 \rfloor = m$ and $(q-1)/2 = m$. For $q = 2m$:
$\lfloor q/2 \rfloor = m$ and $(q-1)/2 = m - 1/2$. $\square$

**Corollary 4.6 (every hardware grid is biased).** For every $b \ge 1$, the dyadic
mesh with $q = 2^b$ levels satisfies
$\sum_{j<2^b} s(j/2^b) = 1/2$.

**Corollary 4.7 (the bias does not wash out).** For even $q$ the *mean* signed
error is $1/(2q)$: a coherent drift of order $1/q$ per weight, not cancellation.

The contrast with §5 is the point: individual signed errors are $O(1/q)$ and
almost perfectly cancel, whereas absolute errors are $\Theta(1)$ per weight in mesh
units and never cancel.

**Theorem 4.8 (multiplier invariance of the first moment).** Let $\gcd(p, q) = 1$,
$q \ge 1$. Then
$$\sum_{k=0}^{q-1} s\!\left(\frac{kp}{q}\right)
= \sum_{j=0}^{q-1} s\!\left(\frac{j}{q}\right)
= \left\lfloor \frac{q}{2} \right\rfloor - \frac{q-1}{2}.$$
In particular every arithmetic progression modulo an odd $q$ is unbiased, and
every arithmetic progression modulo an even $q$ carries exactly the same half-step
bias.

*Proof sketch.* Two ingredients. First, $s(a/q)$ depends only on $a \bmod q$,
because $a/q = (a \bmod q)/q + \lfloor a/q \rfloor$ and $s$ is $1$-periodic under
integer shifts. Second, $k \mapsto kp \bmod q$ is a bijection of
$\{0,\dots,q-1\}$ when $p$ is a unit modulo $q$ (it is injective because $p$ is
invertible, hence surjective by finiteness). Reindexing the sum along this
bijection gives the standard mesh sum. $\square$

Theorem 4.8 is a *rigidity* statement: no relabelling of the mesh by a coprime
multiplier can alter the accumulated signed error. Whatever advantage a cleverer
quantizer obtains, it cannot come from the first moment; it must live in the
second moment, where — by analogy with the classical theory of Dedekind sums — one
expects genuine $(p,q)$-dependence. This is precisely where error-compensating
methods operate.

---

## 5. The absolute error is a Turán number

**Theorem 5.1 (division-free $L^1$ identity).** For every $q \ge 0$,
$$4 \sum_{j=0}^{q-1} \min(j,\, q-j) \;+\; (q \bmod 2) \;=\; q^2 .$$

*Proof sketch.* Split the range at the midpoint. Below the midpoint
($2j < q$, i.e. $j < \lceil q/2 \rceil$) one has $\min(j, q-j) = j$, contributing the
triangular number $\sum_{i < \lceil q/2 \rceil} i$. At or above the midpoint one has
$\min(j, q-j) = q - j$, and reindexing gives $\sum_{i < \lfloor q/2 \rfloor} i +
\lfloor q/2 \rfloor$. Adding the two triangular numbers and clearing denominators
by parity yields the identity. $\square$

**Corollary 5.2 (Mantel–Turán bridge).**
$$\sum_{j=0}^{q-1} \min(j,\, q-j) \;=\; \left\lfloor \frac{q^2}{4} \right\rfloor
\;=\; \mathrm{ex}(q; K_3),$$
the maximum number of edges in a triangle-free graph on $q$ vertices (Mantel's
theorem), attained by the balanced complete bipartite graph
$K_{\lfloor q/2 \rfloor, \lceil q/2 \rceil}$.

*Proof.* Immediate from Theorem 5.1 by integer division. $\square$

The coincidence is not accidental: both quantities are the value of the same
discrete optimisation, "split $q$ into two parts as evenly as possible and
multiply". In the rounding problem, the two parts are the sub-midpoint and
super-midpoint halves of a period; in the graph problem, the two sides of the
bipartition.

**Theorem 5.3 ($L^1$ rounding energy of a rational mesh).** For $q \ge 1$,
$$\sum_{j=0}^{q-1} \left| s\!\left(\frac{j}{q}\right) \right|
= \frac{q^2 - (q \bmod 2)}{4q}
= \frac{\lfloor q^2/4 \rfloor}{q}.$$

*Proof.* By Lemma 4.3 the left side is $\frac{1}{q}\sum_j \min(j, q-j)$; apply
Corollary 5.2. $\square$

**Corollary 5.4 (a quarter-step, always).** For $q \ge 1$,
$$\frac{q}{4} - \frac{1}{4q} \;\le\; \sum_{j=0}^{q-1}\left|s\!\left(\frac{j}{q}\right)\right|
\;\le\; \frac{q}{4},$$
so the mean absolute rounding error per grid point is a quarter of a mesh unit,
to within $O(1/q^2)$.

Together, §4 and §5 give the exact accounting for one period of a $q$-level mesh:
total signed error $\in \{0, 1/2\}$; total absolute error $\lfloor q^2/4 \rfloor / q
\approx q/4$. The ratio between them, $\Theta(q^2)$, is the headroom available to any
scheme that redistributes signed error rather than shrinking it.

---

## 6. Depth: compounding, exact sensitivity, and what a depth gradient measures

Model an $n$-layer chain by the product $\prod_{i<n} w_i$ of scalar gains.

**Lemma 6.1.** If $|v_i| \le M$ for all $i < n$ with $M \ge 0$, then
$\left|\prod_{i<n} v_i\right| \le M^n$.

**Theorem 6.2 (compounding law).** Let $M, \delta \ge 0$, and let $w, e$ satisfy
$|w_i| \le M$ and $|e_i| \le \delta$ for $i < n$. Then
$$\left|\prod_{i<n}(w_i + e_i) - \prod_{i<n} w_i\right| \;\le\; (M+\delta)^n - M^n.$$

*Proof sketch.* Induction on $n$. Writing $P = \prod_{i<n} w_i$ and
$\tilde P = \prod_{i<n}(w_i + e_i)$, the step splits
$\tilde P (w_n + e_n) - P w_n$ as $(\tilde P - P) w_n + \tilde P e_n$, bounds the
first term by the inductive hypothesis times $M$ and the second by
$(M+\delta)^n \delta$, and adds. $\square$

**Theorem 6.3 (attainment).** With $w_i \equiv M$ and $e_i \equiv \delta$ the bound
of Theorem 6.2 holds with equality: $(M+\delta)^n - M^n$.

**Theorem 6.4 (depth cliff).** Fix $M \ge 1$ and $\delta > 0$ (the half-mesh of a bit
budget). For every $c \in \mathbb{R}$ there is a depth $n$ with
$(M+\delta)^n - M^n > c$.

*Proof sketch.* $(M+\delta)^n - M^n \ge n\,\delta\,M^{n-1} \ge n\delta$ for $M \ge 1$, and
$n\delta$ is unbounded. $\square$

So there is no depth-uniform damage floor either — the same structural failure as
Theorem 3.7, now in the depth variable. But the sharper statement is exact and
more informative:

**Theorem 6.5 (exact single-layer sensitivity).** For $k < n$ and $t \in \mathbb{R}$,
$$\prod_{i<n} \bigl(w_i + t\,[\,i = k\,]\bigr) - \prod_{i<n} w_i
\;=\; t \prod_{i \ne k,\; i<n} w_i .$$

*Proof.* Factor out index $k$ from both products; the complementary product is
identical in both terms. $\square$

**Theorem 6.6 (sensitivity is antitone in the layer's own weight).** Let $a, b < n$
with $w_a \ne 0$ and $|w_a| \le |w_b|$. Then
$$\left|\prod_{i \ne b} w_i\right| \;\le\; \left|\prod_{i \ne a} w_i\right|.$$

*Proof sketch.* Both complementary products equal the full product divided by the
omitted factor (in absolute value, with the convention handled by removing the
common factors $w_a w_b$). Since $|w_a| \le |w_b|$, dividing by the smaller factor
yields the larger complementary product. $\square$

**Interpretation.** The measured depth gradient — last-half $+0.4054$ versus
first-half $+0.3885$ — is real but it is *not a law of depth*. Theorem 6.5 says a
layer's sensitivity is the product of every *other* layer's gain, and Theorem 6.6
says the layers with the smallest weights are the most sensitive. A depth gradient
is thus a readout of the depth profile of weight magnitudes in the particular
checkpoint. Reverse the profile and the gradient reverses. This is the same lesson
as Theorem 3.7 from a second direction: amplitudes, not indices, govern damage.

---

## 7. Optimal mixed precision: a water-filling law

Suppose $n$ tensors with amplitudes $A_1, \dots, A_n > 0$ share a total budget
$B = \sum_i b_i$ of bits, and that the worst-case damage of tensor $i$ is
proportional to $A_i 2^{-b_i}$ (Theorem 3.4, with width absorbed into $A_i$).

**Definition 7.1.** $\mathrm{cost}(A, b) = \sum_{i=1}^n A_i 2^{-b_i}$.

**Theorem 7.2 (water-filling lower bound).** For every allocation $b$ with
$\sum_i b_i = B$,
$$\mathrm{cost}(A, b) \;\ge\; n \left(\prod_{i=1}^n A_i\right)^{1/n} 2^{-B/n}.$$

*Proof sketch.* Apply the arithmetic–geometric mean inequality to the positive
numbers $z_i = A_i 2^{-b_i}$:
$\frac{1}{n}\sum_i z_i \ge \left(\prod_i z_i\right)^{1/n}$. The geometric mean is
$\left(\prod_i A_i\right)^{1/n} \cdot 2^{-\left(\sum_i b_i\right)/n}
= \left(\prod_i A_i\right)^{1/n} 2^{-B/n}$. Multiply by $n$. $\square$

**Definition 7.3 (water-filling allocation).**
$$b_i^\star \;=\; \frac{B}{n} \;+\; \log_2 A_i \;-\; \frac{1}{n}\sum_{j=1}^n \log_2 A_j .$$

**Proposition 7.4.** $\sum_i b_i^\star = B$.

**Theorem 7.5 (the bound is attained).**
$$\mathrm{cost}(A, b^\star) \;=\; n \left(\prod_{i=1}^n A_i\right)^{1/n} 2^{-B/n}.$$

*Proof sketch.* $2^{-b_i^\star} = 2^{-B/n} \cdot A_i^{-1} \cdot
2^{\overline{\log_2 A}}$, where $\overline{\log_2 A}$ is the mean log-amplitude, so
each term $A_i 2^{-b_i^\star}$ equals the *same* value
$2^{-B/n}\left(\prod_j A_j\right)^{1/n}$ — the equality case of AM–GM. Summing $n$
identical terms gives the claim. $\square$

**Theorem 7.6 (uniform precision is strictly suboptimal).** With $n = 2$,
$A = (1, 4)$ and net budget $B = 0$: the uniform allocation $b = (0,0)$ costs
$1 + 4 = 5$, whereas $b = (-1, 1)$ also spends $B = 0$ and costs
$1\cdot 2 + 4 \cdot \tfrac12 = 4 < 5$.

**Interpretation.** The invariant that governs a memory budget is the *geometric
mean* of the amplitudes, not their maximum or sum; and the optimal policy grants
each tensor a number of extra bits equal to its log-amplitude excess over the
mean. Uniform precision is optimal only when all amplitudes coincide. This is the
formal reason that grouping (which equalises amplitudes within scope) and
mixed-precision schedules (which equalise damage across scopes) both help, and
they help for different reasons: grouping lowers the mean amplitude, allocation
exploits its dispersion.

---

## 8. Reconciliation with the measurements

We can now read the experimental table through the theory.

* **Monotonicity and nonzero eight-bit damage.** Proposition 2.3 gives a strictly
  decreasing, never-zero mesh; Corollary 2.6 gives sharpness of the $1/2$ constant.
  Damage is expected to be strictly monotone in $b$ with an $8$-bit value that is
  small but measurably nonzero — as observed ($+0.0044$).
* **The failure of the four-bit floor.** Theorem 3.7: no bits-only floor exists.
  The prediction $\le 0.05$ encoded the amplitude–width profile of small
  from-scratch models. Pretrained transformer channels have large outliers, hence
  large $A$, hence a coarse $\Delta = A/2^4$ for the bulk of the (small) weights.
  Sixteen-fold overrun requires no additional mechanism.
* **Grouping repairs $\approx 60\%$.** Theorem 3.6 with the amplitude reading: the
  repair fraction is $1 - \mathrm{mean}_g A_g / \max_g A_g$, a one-pass measurable
  quantity. That the same intervention rescues the three-bit arm follows because
  the guarantee is *linear* in the amplitude at fixed $b$.
* **The depth gradient.** Theorems 6.5–6.6: real, but a statement about the depth
  profile of weight magnitudes, not about depth. Its smallness ($+0.4054$ versus
  $+0.3885$) is consistent with a mild, non-monotone magnitude profile.
* **The catastrophe at two bits.** Theorem 6.2 with $\delta = A/2^{3}$: compounding
  through $L$ layers multiplies the per-layer relative perturbation, and
  $(M+\delta)^n - M^n$ explodes once $\delta$ is a constant fraction of $M$.
* **What to do next.** Theorem 3.5 identifies the sharp configurations as
  *coherent-sign* ones, and Corollary 4.6 shows that the sign coherence is not
  accidental on dyadic grids: every hardware grid carries a half-step signed bias
  per period. Both point at error compensation, not scale selection, as the next
  lever.

**Deployment reading.** For a memory-constrained host: plain per-channel RTN below
six bits is not deployable; group-wise four-bit is the entry point; further
compression requires error compensation. The $(\text{bits} \times \text{grouping})$
surface is the deployment table, and the theory above says which two numbers of a
checkpoint — the maximum and the mean group amplitude — determine it.

---

## 9. Discussion, limitations, and open problems

### 9.1 Limitations

The measurement campaign covers one model at one context length with
round-to-nearest only; embeddings and normalisation parameters were left
unquantized; no error compensation was applied. The theory is worst-case: the
constants of §§2–3 are attained, but attained at adversarial (coherent-sign,
all-midpoint) configurations, and real weight distributions are not adversarial.
What the theory rules out is a *guarantee* stated in bits, not a *typical-case
regularity* stated in bits — but a typical-case regularity is exactly what a
"four-bit floor" is usually taken to be, and the measurement shows that this too
fails to transfer across weight distributions.

### 9.2 Open problems

**(i) Second-order rigidity and Dedekind sums.** Theorem 4.8 shows the *first*
moment of the rounding error is invariant under every coprime multiplier. The
second moment $\sum_{j<q} s(jp/q)^2$ should be a Dedekind-sum-like function of the
pair $(p, q)$ and therefore *not* multiplier-invariant. Since the first-moment
rigidity is settled, any exploitable multiplier dependence must live at second
order — precisely where compensation schemes operate. Making this quantitative
would give a principled account of why permuting or rescaling channels can help.

**(ii) Group-wise repair equals amplitude dispersion.** Theorem 3.6 makes the
repaired damage exactly half the amplitude deficit, so the measured $\approx 60\%$
repair at group-$128$ should equal $1 - \mathrm{mean}(A_g)/\max(A)$ for the actual
checkpoint. This is a falsifiable, one-pass, quantitative prediction, not a
direction.

**(iii) Compensation beats scale choice, provably.** Error feedback re-injects the
signed residual of each rounding decision into the next, which should replace the
$n\Delta/2$ worst-case $\ell^1$ bound by an $O(\sqrt{n}\,\Delta)$ bound. The
justification is structural: the configurations attaining $n\Delta/2$ (Theorem 3.5)
are exactly the coherent-sign ones, and feedback destroys sign coherence by
construction. Both endpoints of the comparison — the sharp uncompensated constant
and the coherence structure of the extremal examples — are now available.

**(iv) Joint weight–memory budgets.** §7 optimises bits across tensors. Real
deployment must jointly budget weights and the key–value cache, whose amplitude
statistics differ; the water-filling law extends formally but the amplitudes must
be measured.

**(v) Tail-aware mixed precision.** If a network's parameters split into a shared
core and a task-specific tail, §7 suggests quantizing the core harder than the
tail exactly when the core's log-amplitude sits below the mean — again, a
measurable criterion rather than a heuristic.

### 9.3 Summary

The bit budget never acts alone. Every sharp constant in RTN quantization is a
constant in *amplitude times width divided by $2^{b+1}$*, and the impossibility of
a bit-only floor follows in one line. Everything else in this paper describes what
does control the damage: amplitude dispersion (which grouping compresses and
mixed precision exploits), sign coherence (which is rigid at first order and is
the target of compensation), and the depth profile of weight magnitudes (which
masquerades as a law of depth). The absolute rounding energy of a $q$-level mesh
being the Mantel–Turán number $\lfloor q^2/4 \rfloor$ is a pleasant reminder that
the arithmetic of rounding is genuinely arithmetic.
