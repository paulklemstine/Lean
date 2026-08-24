# Depth-Independence of the Held-Out Logit Margin: A Rigidity Theory for Attention-Truncation Knees

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study the relationship between the *knee* of an attention-truncation curve —
the least top-$k$ budget sufficient to preserve a model's decision — and the
*held-out logit margin* of the model that produced it. Under a scale-free
attention tail of amplitude $A$, a Lipschitz depth leg, and a bounded linear
read-out of constant $L\cdot B$, the budget the margin channel demands at depth
$d$ is $k^*(d,m) = 4LBA\,d\,\mathrm{ctx}/m$. We prove a **pinning theorem**: if
this equals a measured depth-linear knee $d\,\mathrm{ctx}/c$, then the margin is
forced to $m = 4cLBA$, in which the depth does not appear; at the calibrated
$c = 32$ this is $m = 128\,LBA$. Because the exact hypothesis is unavailable in
practice, we replace it with a measurement band and prove the **band theorem**:
knees measured within relative tolerance $\eta < 1$ of the depth-linear law at
two depths confine the ratio of implied margins to
$[(1-\eta)/(1+\eta),\,(1+\eta)/(1-\eta)]$, with the depths, the context, the
amplitude and the read-out constant all cancelling. The headline instance is that
a knee measured to $\pm 1/21$ certifies margins flat to $\pm 10\%$, and this
window is attained, hence sharp. We show that the naive $m(d) \propto 1/d$
expectation is *logically incompatible* with knees in the band, give a decision
rule with an explicit $\pm 50\%$ noise budget, and prove exponent rigidity: a
power-law fit $m(d) = m_1 d^{-\alpha}$ to a $\pm 10\%$-flat margin forces
$|\alpha| \le \log(10/9)/\log 4 \approx 0.076$, hence $\alpha \ne 1$, and
$\alpha = 0$ exactly in the noiseless case. We identify the band as a ball in the
Hilbert projective metric, under which the margin map is an isometry — explaining
the cancellations structurally — and deduce that the margin channel does *not*
accumulate error along the depth ladder. On the measurement-theoretic side we
prove that a geometric budget grid of step $\rho$ confines the implied margin
ratio to exactly $[1/\rho, \rho]$, so a dyadic sweep ($\rho = 2$) cannot test the
claim, while a step $\rho \le 11/10$ certifies it — an if-and-only-if. Finally we
supply the protocol: the reported statistic must be a median (the mean has
breakdown point $0$), the seed budget must satisfy $2k < n$ (two seeds per depth
are provably insufficient, three tolerate one failure), and an executable
majority verdict is proved sound and sharp. The whole development reduces to one
dimensionless invariant: the attention deficit at the selected budget, in units
of $m/(LB)$, lies in $[1/8, 1/4]$.

**Keywords:** attention truncation, logit margin, depth scaling, Hilbert
projective metric, breakdown point, experimental design, power-law rigidity.

---

## 1. Introduction

### 1.1 The question

Fix a training corpus, a tokeniser, and a context length $\mathrm{ctx}$. Train
three transformer-style stacks that differ only in depth: $d = 4$, $8$, $16$. On
a held-out split, measure the *logit margin* — the gap between the top logit and
the runner-up — and take the median over seeds. How does this quantity scale with
$d$?

The folk answer is that it shrinks. Approximation error compounds through layers,
so the "usable" confidence at the output of a sixteen-layer stack should be about
a quarter of that of a four-layer stack. We will call this the **naive
hypothesis**, $m(d) \propto d^{-1}$.

This paper develops the opposite prediction and, more importantly, the
machinery that makes the disagreement *decidable* with the measurements one can
actually take.

### 1.2 The mechanism in one line

Attention weights are top-heavy. For a scale-free profile of amplitude $A$ at
context $\mathrm{ctx}$, the attention mass discarded by a top-$k$ truncation is
$$\mathrm{tail}(k) \;=\; \frac{A\cdot\mathrm{ctx}}{k}. \tag{1.1}$$
Perturbations of magnitude $\varepsilon$ injected into each of $d$ Lipschitz
layers move the top of the stack by at most $d\varepsilon$ (the *depth leg*); a
bounded linear read-out of constant $L\cdot B$ converts a hidden perturbation
into a logit perturbation. A truncation is admissible when the resulting logit
perturbation stays below the margin $m$. Solving for the least sufficient budget
gives the **knee**
$$k^*(d,m) \;=\; \frac{4\,L\,B\,A\,d\,\mathrm{ctx}}{m}. \tag{1.2}$$
Budget sweeps in this regime report
$$k^*_{\text{measured}} \;=\; \frac{d\cdot\mathrm{ctx}}{32}. \tag{1.3}$$

### 1.3 Contributions

1. **Pinning (§3).** Equating (1.2) with a depth-linear law $d\,\mathrm{ctx}/c$
   forces $m = 4cLBA$ — depth-free. At $c = 32$, $m = 128\,LBA$.
2. **The band theorem and its sharpness (§4).** The exact hypothesis is replaced
   by a relative tolerance; the conclusion becomes a two-sided bound on the
   *ratio* of implied margins, free of every nuisance parameter, and attained.
3. **Refutation and decision rule (§5).** The naive hypothesis is inconsistent
   with in-band knees; a threshold at $0.45$ separates the hypotheses under
   $\pm 50\%$ multiplicative noise.
4. **Exponent rigidity (§6).** Both the margin side and the knee side of a
   power-law ansatz force $\alpha \approx 0$, and exactly $0$ in the exact case.
5. **Projective geometry of the band (§7).** The margin map is an isometry of the
   Hilbert projective metric; hence the cancellations, and hence non-accumulation
   along the depth ladder.
6. **Measurement theory (§8).** Grid step $\rho$ $\Rightarrow$ ratio band exactly
   $[1/\rho,\rho]$; dyadic grids cannot certify $\pm 10\%$; $\rho \le 11/10$ can,
   and is necessary.
7. **Protocol (§9).** Median over seeds, $2k < n$, executable majority verdict
   with soundness and sharpness.
8. **Rigidity of the assumptions (§10) and the dimensionless invariant (§11).**

---

## 2. Setting and notation

Throughout, $A > 0$ is the tail amplitude, $\mathrm{ctx} > 0$ the context length,
$L > 0$ and $B > 0$ the read-out constants, $d \in \mathbb{N}_{>0}$ the depth, and
$m > 0$ the held-out logit margin. We write $LB$ for the product $L\cdot B$.

**Definition 2.1 (Scale-free attention tail).** The mass discarded by a top-$k$
truncation at context $\mathrm{ctx}$ with amplitude $A$ is
$\mathrm{tail}_A(\mathrm{ctx}, k) = A\,\mathrm{ctx}/k$. More generally, an
exponent-$\beta$ tail is $A\,\mathrm{ctx}/k^{\beta}$.

**Definition 2.2 (Margin channel).** The budget demanded at depth $d$ by a model
of margin $m$ is
$$\mathrm{knee}(d, m) \;=\; \frac{4\,L\,B\,A\,d\,\mathrm{ctx}}{m}.$$

**Definition 2.3 (Implied margin).** Given a *measured* knee $K > 0$ at depth $d$,
the margin implied by the mechanism is the unique solution of
$\mathrm{knee}(d,m) = K$, namely
$$m(d,K) \;=\; \frac{4\,L\,B\,A\,d\,\mathrm{ctx}}{K}.$$

The implied margin is positive whenever $L, B, A, \mathrm{ctx}, d, K$ are, and it
solves the channel equation by construction: substituting $m(d,K)$ back into
Definition 2.2 returns $K$.

**Definition 2.4 (Relative tolerance).** For $\eta \ge 0$ we say $x$ is *within
relative tolerance $\eta$ of $y$*, written $x \in \mathrm{Rel}_\eta(y)$, if
$|x - y| \le \eta\, y$. When $y > 0$ this is equivalent to
$(1-\eta)y \le x \le (1+\eta)y$; if moreover $\eta < 1$, then $x > 0$.

**Definition 2.5 (Median).** For a finite list $\ell$ of rationals, $m$ is a
*median* of $\ell$ if at most half of the entries are $\le m$ and at most half are
$\ge m$ in the usual two-sided counting sense; concretely, neither
$\#\{x \in \ell : x \le m\}$ nor $\#\{x \in \ell : x \ge m\}$ is less than half of
$|\ell|$. Medians need not be unique; all statements below are proved for *every*
median of the reported log.

---

## 3. Pinning: the depth cancels

**Theorem 3.1 (Pinning with a general calibration constant).**
*Let $d \ge 1$, $\mathrm{ctx} > 0$, $m > 0$, $c > 0$, and suppose the margin
channel reproduces a depth-linear knee:*
$$\frac{4LBA\,d\,\mathrm{ctx}}{m} \;=\; \frac{d\,\mathrm{ctx}}{c}.$$
*Then $m = 4\,c\,L\,B\,A$.*

*Proof sketch.* Clearing the denominator $m$ gives
$4LBA\,d\,\mathrm{ctx} = (d\,\mathrm{ctx}/c)\,m$, i.e.
$(4cLBA)\,(d\,\mathrm{ctx}) = m\,(d\,\mathrm{ctx})$. Since $d\,\mathrm{ctx} \ne 0$,
cancel it. $\square$

The identity $d\,\mathrm{ctx} \ne 0$ is the whole argument: the depth appears on
both sides of the channel equation with the same power, and the context likewise.
Nothing about the value of $d$ is used, so the conclusion is uniform in depth.

**Corollary 3.2 (Calibrated pinning).** *With the fitted constant $c = 32$, the
margin is forced to $m = 128\,L\,B\,A$.*

This is the numerical claim under test: three depths, one number, no $d$ in it.

**Remark 3.3.** Theorem 3.1 is an *exact* statement, and therefore untestable as
it stands: it presupposes that the knee is known without error. Sections 4–5
repair this.

---

## 4. The band theorem

### 4.1 Statement

**Theorem 4.1 (Band theorem).**
*Let $L, B, A, \mathrm{ctx}, c > 0$, let $d_1, d_2 \ge 1$, and let
$0 \le \eta < 1$. Suppose*
$$K_1 \in \mathrm{Rel}_\eta\!\left(\frac{d_1 \mathrm{ctx}}{c}\right), \qquad
K_2 \in \mathrm{Rel}_\eta\!\left(\frac{d_2 \mathrm{ctx}}{c}\right).$$
*Then*
$$\frac{1-\eta}{1+\eta} \;\le\; \frac{m(d_1, K_1)}{m(d_2, K_2)} \;\le\;
\frac{1+\eta}{1-\eta}.$$

*Proof sketch.* Write $P = 4LBA$. By Definition 2.3,
$$\frac{m(d_1,K_1)}{m(d_2,K_2)} = \frac{P\,d_1\mathrm{ctx}/K_1}{P\,d_2\mathrm{ctx}/K_2}
= \frac{d_1 K_2}{d_2 K_1},$$
so $P$ and $\mathrm{ctx}$ cancel identically. Since $\eta < 1$ and the reference
values are positive, both $K_i$ are positive, so the denominator $d_2 K_1$ is
positive. Substituting the two-sided bounds
$(1-\eta)\,d_i\mathrm{ctx}/c \le K_i \le (1+\eta)\,d_i\mathrm{ctx}/c$ into
numerator and denominator gives
$$\frac{d_1 \cdot (1-\eta) d_2 \mathrm{ctx}/c}{d_2 \cdot (1+\eta) d_1 \mathrm{ctx}/c}
\;\le\; \frac{d_1 K_2}{d_2 K_1} \;\le\;
\frac{d_1 \cdot (1+\eta) d_2 \mathrm{ctx}/c}{d_2 \cdot (1-\eta) d_1 \mathrm{ctx}/c},$$
and in both bounds the factor $d_1 d_2 \mathrm{ctx}/c$ cancels, leaving
$(1-\eta)/(1+\eta)$ and $(1+\eta)/(1-\eta)$. $\square$

**Remark 4.2 (What has cancelled).** Five quantities disappear: the two depths,
the context, the tail amplitude $A$, and the read-out constant $LB$. The last two
are exactly the quantities one cannot measure directly. The prediction has no
free parameter, so it cannot be rescued after the fact by refitting a constant.

### 4.2 The headline instance and its sharpness

**Theorem 4.3 (Depth-independence to $\pm 10\%$).**
*If the knees at two depths are each measured within relative tolerance $1/21$ of
$d\,\mathrm{ctx}/32$, then*
$$0.9 \;\le\; \frac{m(d_1,K_1)}{m(d_2,K_2)} \;\le\; 1.1.$$

*Proof sketch.* Apply Theorem 4.1 with $c = 32$, $\eta = 1/21$, and evaluate:
$(1+1/21)/(1-1/21) = (22/21)/(20/21) = 11/10$, and reciprocally $10/11$. Since
$10/11 \ge 0.9$ and $11/10 \le 1.1$, the stated window follows. $\square$

The tolerance $1/21 \approx 4.76\%$ is precisely the value for which
$(1+\eta)/(1-\eta) = 11/10$; solving $\,(1+\eta)/(1-\eta) = 1.1$ gives
$\eta = 1/21$.

**Corollary 4.4 (Flatness across the ladder).** *If the sweep reports a knee
within $\pm 1/21$ of $d\,\mathrm{ctx}/32$ at every depth, then the implied margins
at any two depths agree to $\pm 10\%$ — in particular at all pairs drawn from
$\{4, 8, 16\}$.* (Immediate: Theorem 4.3 is applied pairwise, the hypothesis
being depth-uniform.)

**Theorem 4.5 (Sharpness of the window).**
*For any $L,B,A,\mathrm{ctx} > 0$ and any depths $d_1, d_2 \ge 1$ there exist
$K_1, K_2$ inside the $\pm 1/21$ band with*
$$\frac{m(d_1,K_1)}{m(d_2,K_2)} \;=\; 1.1 .$$

*Proof sketch.* Take $K_1 = (1-\tfrac{1}{21})\,d_1\mathrm{ctx}/32$ and
$K_2 = (1+\tfrac{1}{21})\,d_2\mathrm{ctx}/32$. Each lies exactly on an edge of its
band, hence within it. The ratio formula $d_1 K_2/(d_2 K_1)$ evaluates to
$(1+1/21)/(1-1/21) = 11/10$. $\square$

Thus $\pm 10\%$ is not a conservative rounding of the $\pm 1/21$ hypothesis: it is
the exact image of that hypothesis. No argument from the same data can certify a
tighter window; tightening the conclusion requires tightening the measurement.

---

## 5. Refutation of the naive hypothesis, and a decision rule

**Theorem 5.1 (The naive quarter is excluded).**
*Suppose the knees at $d = 4$ and $d = 16$ both lie within relative tolerance
$1/21$ of $d\,\mathrm{ctx}/32$. Then it is impossible that*
$$m(16, K_{16}) \;=\; \tfrac{1}{4}\, m(4, K_4).$$

*Proof sketch.* By Theorem 4.3 applied with $d_1 = 16$, $d_2 = 4$, the ratio
$m(16,K_{16})/m(4,K_4)$ is at least $0.9$. The implied margin at $d = 4$ is
positive, so the naive identity would make the ratio exactly $1/4 = 0.25 < 0.9$,
a contradiction. $\square$

**Remark 5.2 (Why "refutation" and not "disfavoured").** The two hypotheses are
not two fits to the same data whose residuals one compares. Given in-band knees,
the naive relation is *false as a matter of arithmetic*. Consequently a measured
ratio near $1/4$ should be read as evidence against the premises — against the
depth-linear knee, or against the margin channel — rather than as a
recalibration of a constant.

**Theorem 5.3 (Threshold test with a noise budget).**
*Let $r \ge 0$ be the true ratio $m(16)/m(4)$ and suppose the harness reports
$\hat r = r(1+e)$ with $|e| \le 1/2$. Then the rule "accept iff $\hat r > 0.45$"
is correct on both sides:*
- *if $r \ge 0.9$ (the mechanism's band) then $\hat r \ge 0.45$;*
- *if $r \le 0.275$ (the naive value $0.25$, inflated by $10\%$) then
  $\hat r < 0.45$.*

*Proof sketch.* From $|e| \le 1/2$ we get $1 + e \ge 1/2$ and $1 + e \le 3/2$. For
the first claim, $r \ge 0.9$ gives $\hat r = r(1+e) \ge 0.9 \times 0.5 = 0.45$. For
the second, $r \le 0.275$ and $r \ge 0$ give
$\hat r \le 0.275 \times 1.5 = 0.4125 < 0.45$. $\square$

The separation margin is comfortable in both directions ($0.45$ versus $0.4125$
on the reject side, exactly $0.45$ on the accept side at the worst case), because
the hypotheses differ by a factor of nearly four while the noise is only a factor
of $1.5$.

---

## 6. Power-law rigidity

Rather than choosing between two hypotheses, one may fit a family.

**Definition 6.1.** The power-law margin ansatz is
$m_\alpha(d) = m_1 \, d^{-\alpha}$ with $m_1 > 0$.

**Lemma 6.2 (Prefactor-free ratio).** $m_\alpha(16)/m_\alpha(4) = 4^{-\alpha}$.

*Proof sketch.* $16 = 4^2$, so
$m_\alpha(16)/m_\alpha(4) = 4^{-2\alpha}/4^{-\alpha} = 4^{-\alpha}$; the prefactor
cancels. $\square$

**Theorem 6.3 (Exponent bound from a flat margin).**
*If $0.9 \le m_\alpha(16)/m_\alpha(4) \le 1.1$ then*
$$|\alpha| \;\le\; \frac{\log(10/9)}{\log 4} \;\approx\; 0.0760.$$

*Proof sketch.* By Lemma 6.2 the hypothesis reads
$9/10 \le 4^{-\alpha} \le 11/10$. Taking logarithms and using
$\log(4^{-\alpha}) = -\alpha \log 4$ gives
$\log(9/10) \le -\alpha \log 4 \le \log(11/10)$. Now
$\log(9/10) = -\log(10/9)$ and $\log(11/10) \le \log(10/9)$ (since
$11/10 \le 10/9$, because $99 \le 100$). Hence
$|-\alpha \log 4| \le \log(10/9)$; divide by $\log 4 > 0$. $\square$

**Corollary 6.4 (The naive exponent is excluded).** *Under the hypotheses of
Theorem 6.3, $\alpha \ne 1$.* Indeed $\alpha = 1$ would require
$\log 4 \le \log(10/9)$, i.e. $4 \le 10/9$, which is false. The two candidate
exponents are separated by a factor of about $13$ in the bound.

**Theorem 6.5 (Exact flatness forces $\alpha = 0$).**
*If $m_\alpha(16) = m_\alpha(4)$ then $\alpha = 0$.*

*Proof sketch.* Both values are positive, so the ratio is $1$; by Lemma 6.2,
$4^{-\alpha} = 1$, so $-\alpha \log 4 = 0$, and $\log 4 \ne 0$. $\square$

So a flat margin is not merely a slowly varying one: within the power-law family
the exponent is exactly zero.

### 6.1 The same exponent, read from the knee

**Definition 6.6.** The knee demanded by a margin $m$ at depth $d$ is
$\mathrm{knee}(d,m) = 4LBA\,d\,\mathrm{ctx}/m$ (Definition 2.2).

**Theorem 6.7 (Knee ratio under a power-law margin).**
$$\frac{\mathrm{knee}(16, m_\alpha(16))}{\mathrm{knee}(4, m_\alpha(4))}
\;=\; 4^{\,1+\alpha}.$$

*Proof sketch.* The knee is proportional to $d/m$, so the ratio is
$(16/4) \cdot m_\alpha(4)/m_\alpha(16) = 4 \cdot (4^{-\alpha})^{-1} = 4\cdot 4^{\alpha}$.
The factor $4$ is the depth leg; the factor $4^{\alpha}$ is margin drift. $\square$

**Corollary 6.8 (Measured knee ratio forces $\alpha = 0$).** *A measured knee
ratio of exactly $4$ between $d = 4$ and $d = 16$ forces $\alpha = 0$.*
(From $4^{1+\alpha} = 4$, take logarithms: $(1+\alpha)\log 4 = \log 4$.) The
constraint is satisfiable — $\alpha = 0$ realises the ratio $4$ — so the statement
is not vacuous.

**Theorem 6.9 (Equivalence: depth-linear knee $\iff$ depth-free margin).**
*Fix $A, L, B > 0$, $d, \mathrm{ctx} \ge 1$ with $32 \mid d\,\mathrm{ctx}$. Then:*
1. *(Forward) every $m > 0$ satisfying
   $4LBA\,d\,\mathrm{ctx}/m = d\,\mathrm{ctx}/32$ equals $128\,LBA$;*
2. *(Backward) with the margin fixed at $128\,LBA$, the least budget $k \ge 1$
   satisfying the end-to-end criterion
   $d\cdot \mathrm{tail}_A(\mathrm{ctx},k) \le 128LBA/(4LB)$ is exactly
   $d\,\mathrm{ctx}/32$.*

*Proof sketch.* (1) is Corollary 3.2. For (2), the right-hand side simplifies to
$32A$; the criterion $d\,A\,\mathrm{ctx}/k \le 32A$ is equivalent to
$k \ge d\,\mathrm{ctx}/32$, whose least integer solution under the divisibility
hypothesis is exactly $d\,\mathrm{ctx}/32$. $\square$

Thus the depth leg of the mechanism and the depth-independence of the margin are
two readings of a single statement: the linear growth of $k^*$ is carried
entirely by error accumulation over layers, with a constant margin.

---

## 7. The band is a projective ball

### 7.1 The metric

**Definition 7.1 (Log-ratio distance).** For $x, y > 0$,
$$\rho(x,y) \;=\; \bigl|\log(x/y)\bigr|.$$

This is the Hilbert projective metric on the positive ray. It is nonnegative,
symmetric ($\rho(y,x) = \rho(x,y)$, since $\log(y/x) = -\log(x/y)$), satisfies the
triangle inequality (from $x/z = (x/y)(y/z)$, $\log$ of a product, and the
triangle inequality for $|\cdot|$), and is invariant under common positive
rescaling: $\rho(\lambda x, \lambda y) = \rho(x,y)$.

### 7.2 The margin map is an isometry

**Theorem 7.2 (Isometry).**
*For $L, B, A, \mathrm{ctx} > 0$, $d_1, d_2 \ge 1$ and $K_1, K_2 > 0$,*
$$\rho\bigl(m(d_1,K_1),\, m(d_2,K_2)\bigr) \;=\;
\rho\!\left(\frac{K_2}{d_2},\, \frac{K_1}{d_1}\right).$$

*Proof sketch.* $m(d_i,K_i) = (4LBA\,\mathrm{ctx}) \cdot d_i/K_i$. The common
positive factor $4LBA\,\mathrm{ctx}$ is a projective rescaling and drops out of
the ratio, leaving $(d_1/K_1)\big/(d_2/K_2) = (K_2/d_2)\big/(K_1/d_1)$. $\square$

**Corollary 7.3 (The band is a ball).** *Knees measured within relative tolerance
$\eta < 1$ of the depth-linear law put the implied margins within log-ratio
distance $\log\frac{1+\eta}{1-\eta}$ of one another.* (Take logarithms of the two
bounds of Theorem 4.1, using $\log\frac{1-\eta}{1+\eta} = -\log\frac{1+\eta}{1-\eta}$.)

This is the structural explanation of Remark 4.2. The amplitude $A$, the read-out
constant $LB$ and the context $\mathrm{ctx}$ enter the margin map only as a common
multiplicative factor, and the Hilbert metric is by construction blind to such
factors. Their disappearance is geometry, not algebraic luck.

### 7.3 Non-accumulation along the depth ladder

Because $\rho$ is a metric, the comparison between $d = 4$ and $d = 16$ could be
made by chaining through $d = 8$, at a cost of
$2\log\frac{1+\eta}{1-\eta}$. The direct comparison costs
$\log\frac{1+\eta}{1-\eta}$.

**Proposition 7.4 (Direct beats chained).** *For $0 < \eta < 1$,*
$$\log\frac{1+\eta}{1-\eta} \;<\; 2\log\frac{1+\eta}{1-\eta},$$
*because $\frac{1+\eta}{1-\eta} > 1$ makes the logarithm strictly positive.*

Trivial as the inequality is, its content is not: it says the bound on the margin
comparison does not degrade with the number of intermediate depths. Error
accumulation is real in this system, but it lives in the *depth leg* — the
composition of Lipschitz layers, where perturbations genuinely add — and not in
the margin statement. That contrast is precisely the point of the experiment.

---

## 8. Measurement theory: which sweeps can test the claim

### 8.1 Grid reporting

Budget sweeps evaluate a finite set of candidate budgets and report the first one
that passes.

**Definition 8.1 (Grid report).** A sweep on a geometric grid of step $\rho \ge 1$
reports a value $K$ with $K_{\text{true}} \le K \le \rho\,K_{\text{true}}$.

**Theorem 8.2 (What a grid of step $\rho$ can say).**
*If the true knees obey the depth-linear law exactly and are reported on a
geometric grid of step $\rho \ge 1$, then*
$$\frac{1}{\rho} \;\le\; \frac{m(d_1,K_1)}{m(d_2,K_2)} \;\le\; \rho.$$

*Proof sketch.* As in Theorem 4.1 the ratio equals $d_1K_2/(d_2K_1)$. Bound $K_2$
above by $\rho\,d_2\mathrm{ctx}/32$ and $K_1$ below by $d_1\mathrm{ctx}/32$ for
the upper bound; reverse the roles for the lower. All common factors cancel.
$\square$

**Theorem 8.3 (The grid band is attained).** *There are reports consistent with
the grid — one depth reported exactly, the other overshooting by the full step —
whose implied margin ratio is exactly $\rho$.* (Take $K_1 = d_1\mathrm{ctx}/32$
and $K_2 = \rho\,d_2\mathrm{ctx}/32$.)

**Corollary 8.4 (A dyadic sweep cannot test the claim).** *For a doubling grid,
$\rho = 2$, so there are consistent measurement outcomes with implied margin
ratio $2 > 1.1$. A dyadic knee sweep therefore carries no information about the
depth scaling of the margin at $\pm 10\%$ precision.*

This is a strong negative result about a common practice: reporting
$k^* = 16, 32, 64$ across three depths from a doubling sweep looks like a clean
confirmation of linearity, but the same data are compatible with a factor-two
margin drift.

**Theorem 8.5 (Fine grids certify, and are necessary).**
*A geometric sweep of step $\rho$ forces the implied margin ratio into
$[0.9, 1.1]$ whenever $\rho \le 11/10$; and if $\rho > 11/10$, there exist
consistent reports whose implied ratio exceeds $1.1$. Hence: a geometric sweep
certifies the $\pm 10\%$ claim if and only if $\rho \le 11/10$.*

*Proof sketch.* Sufficiency: by Theorem 8.2 the ratio lies in $[1/\rho, \rho]
\subseteq [10/11, 11/10] \subseteq [0.9, 1.1]$. Necessity: Theorem 8.3 attains
$\rho > 11/10 > 1.1$. $\square$

This is an actionable instruction: refine the budget grid to $10\%$
multiplicative steps, or interpolate the knee between grid points.

### 8.2 Aggregation over seeds

**Proposition 8.6 (The mean has breakdown point zero).** *Consider six runs all
reporting the ratio $1$, of which one is corrupted to $100$ (a crashed forward
pass reporting a garbage logit margin). The reported mean is $35/2 = 17.5$,
outside the acceptance band, whereas $1$ is still a median of the corrupted log.*

**Theorem 8.7 (The median inherits the band).** *Let $x$ be the list of genuine
per-run ratios and $y$ the reported list of the same length, differing in at most
$k$ positions with $2k < |x|$. If every genuine value lies in $[9/10, 11/10]$,
then **every** median of $y$ lies in $[9/10, 11/10]$.*

*Proof sketch.* A median of $y$ must have at least half the entries of $y$ weakly
below it and at least half weakly above. If it were below $9/10$, then all
entries weakly below it would be out of band, and out-of-band entries of $y$ can
only be corrupted positions, of which there are at most $k < |x|/2$ — a counting
contradiction. Symmetrically above. $\square$

**Corollary 8.8.** *Under the hypotheses of Theorem 8.7, the reported median
cannot equal $1/4$, nor anything below $9/10$.*

---

## 9. The protocol

**Definition 9.1 (Acceptance predicate).** A reported ratio $r$ *passes* if
$9/10 \le r \le 11/10$. This is decidable on the rationals a harness prints, and
it is non-vacuous on both sides: $r = 1$ passes and $r = 1/4$ fails.

**Theorem 9.2 (Seed budget).** *With $n$ runs per depth of which at most $k$ are
corrupted, and all genuine per-run ratios in band, every median of the reported
log passes provided $2k < n$.* (Theorem 8.7 with the count bounded by $k$.)

**Theorem 9.3 (Two seeds are provably insufficient).** *For any target value $t$
there is a two-run log $y$ differing from the clean log $[1,1]$ in at most one
position, for which $t$ is a median of $y$.* Hence with two seeds a single
crashed run — or an adversary — can install *any* value as the reported median.

**Theorem 9.4 (Three seeds tolerate one failure).** *Any three-run log whose
genuine values lie in band, with at most one run corrupted, reports a median that
passes.* (Theorem 9.2 with $n = 3$, $k = 1$: $2 < 3$.)

### 9.1 An executable verdict

The tests above compare the reported log to a hypothetical clean log. A harness
does not have the clean log. The following rule needs only the reported numbers.

**Theorem 9.5 (Majority rule).** *Let $\ell$ be a list of rationals and
$a \le b$. If strictly more than half of the entries of $\ell$ lie in $[a,b]$,
then every median of $\ell$ lies in $[a,b]$.*

*Proof sketch.* Suppose a median $m < a$. Every entry weakly below $m$ is then
$< a$, hence outside $[a,b]$; so the count of entries weakly below $m$ is at most
the count of out-of-band entries, which is strictly less than half of $|\ell|$.
That contradicts the defining property of a median. The case $m > b$ is
symmetric. $\square$

**Definition 9.6 (The verdict).** *Accept the depth-independence claim if and
only if strictly more than half of the reported per-run margin ratios lie in
$[0.9, 1.1]$.*

**Theorem 9.7 (Soundness).** *If the verdict accepts, then every median of the
reported log passes — with no assumption about which runs are genuine.*
(Theorem 9.5 with $[a,b] = [9/10, 11/10]$.)

**Theorem 9.8 (Strictness is necessary).** *The strict majority cannot be
weakened to "at least half": the four-run log $[1, 1, 2, 2]$ has exactly half its
entries in band and admits the out-of-band median $2$.*

**Example 9.9 (Worked synthetic log).** The six-run log
$$[\,1,\; 1.02,\; 0.98,\; 1.04,\; 0.97,\; 1.01\,]$$
(three depths, two seeds each, ratios taken relative to the $d = 4$, seed-1 run)
lies entirely inside the band, so the verdict fires and every median passes,
excluding the naive $1/4$. Conversely the log
$[1/4, 1/4, 1/4, 1/4, 1/4, 1/4]$ makes the verdict fail. *(Synthetic
illustration of the decision procedure, not measured data.)*

---

## 10. Rigidity of the assumptions

Two objections could undercut everything above: that the functional form of the
margin channel was chosen to produce the conclusion, and that the tail exponent
was assumed.

### 10.1 The margin channel is forced

**Theorem 10.1 (Rigidity of the margin channel).**
*Let $K : \mathbb{N}_{>0} \times \mathbb{R}_{>0} \to \mathbb{R}$ be any rule
assigning to a depth $d$ and a margin $m$ the budget a truncation criterion
demands. Assume:*
1. *inverse homogeneity in the margin: $K(d, cm) = K(d,m)/c$ for all $c > 0$ — a
   model whose logits are $c$ times better tolerates $c$ times more truncation,
   the only dimensionally consistent behaviour for a threshold criterion;*
2. *a linear depth leg: $K(d,m) = d\,K(1,m)$ — the content of error accumulation
   through Lipschitz layers.*

*Then $K(d,m) = d\,K(1,1)/m$ for all $d \ge 1$, $m > 0$.*

*Proof sketch.* Apply (1) at $d = 1$ with $c = m$ and base margin $1$:
$K(1, m\cdot 1) = K(1,1)/m$. Substitute into (2). $\square$

**Corollary 10.2.** *With the single calibration $K(1,1) = 4LBA\,\mathrm{ctx}$,
the forced form is exactly the margin channel of Definition 2.2.* Only one number
is empirical; there is no functional freedom left, so the depth-independence
prediction is not an artefact of a parametrisation.

### 10.2 The tail exponent is forced, quantitatively

**Theorem 10.3 (Exponent rigidity from the knee ratio).**
*Under a scale-free tail $A\,\mathrm{ctx}/k^{\beta}$, the least sufficient budget
scales like $(A\,d\,\mathrm{ctx}/\delta)^{1/\beta}$, so the knee ratio between
$d = 4$ and $d = 16$ is $4^{1/\beta}$. If that ratio is measured within relative
tolerance $\eta < 1$ of the value $4$, then*
$$\left|\frac{1}{\beta} - 1\right| \;\le\; \frac{\log\bigl(1/(1-\eta)\bigr)}{\log 4}.$$

*Proof sketch.* The hypothesis is
$(1-\eta)\cdot 4 \le 4^{1/\beta} \le (1+\eta)\cdot 4$. Take logarithms:
$\log(1-\eta) + \log 4 \le (1/\beta)\log 4 \le \log(1+\eta) + \log 4$, i.e.
$\log(1-\eta) \le (1/\beta - 1)\log 4 \le \log(1+\eta)$. Since
$(1+\eta)(1-\eta) = 1 - \eta^2 \le 1$, we have
$\log(1+\eta) \le -\log(1-\eta) = \log\frac{1}{1-\eta}$, so both sides are bounded
by $\log\frac{1}{1-\eta}$ in absolute value. Divide by $\log 4 > 0$. $\square$

**Corollary 10.4 (Exact case).** *A knee ratio measured at exactly $4$ forces
$\beta = 1$: the scale-free profile of Definition 2.1.*

**Corollary 10.5 (A quadratic tail is excluded).** *If the knee ratio is within
relative tolerance $\eta < 1/2$ of $4$, then $\beta \ne 2$.* Indeed $\beta = 2$
would need $\tfrac{1}{2} \le \log\frac{1}{1-\eta}/\log 4 = \log\frac{1}{1-\eta}/(2\log 2)$,
i.e. $\log\frac{1}{1-\eta} \ge \log 2$, i.e. $\eta \ge 1/2$. A $1/k^2$ attention
tail would have produced a knee ratio of $2$, not $4$.

---

## 11. The dimensionless invariant, and the bridge between measurements

**Theorem 11.1 (Deficit window, free of depth and context).**
*With the margin pinned at $m = 128\,LBA$ and any context $\mathrm{ctx} \ge 32$,
the attention mass discarded at the selected budget satisfies*
$$16A \;\le\; \mathrm{tail}\bigl(k^*\bigr) \;\le\; 32A,$$
*equivalently $\;m/(8LB) \le \mathrm{tail}(k^*) \le m/(4LB)$ — the same window at
every depth and every admissible context.*

*Proof sketch.* The two-sided margin law bounds the deficit at the selected budget
between $m/(8LB)$ and $m/(4LB)$ whenever the budget request is at least one unit;
substituting $m = 128LBA$ turns these into $16A$ and $32A$. The hypothesis
$\mathrm{ctx} \ge 32$ is exactly what makes the request nondegenerate. $\square$

**Theorem 11.2 (The dimensionless invariant).**
*Under the same hypotheses,*
$$\frac{1}{8} \;\le\; \frac{\mathrm{tail}(k^*)\cdot LB}{m} \;\le\; \frac{1}{4}.$$

*Proof sketch.* Divide Theorem 11.1 through by $m = 128LBA$ and multiply by
$LB$: the bounds $16A$ and $32A$ become $16A\cdot LB/(128LBA) = 1/8$ and
$32A \cdot LB/(128LBA) = 1/4$. $\square$

No depth, no context, no amplitude, no read-out constant survives. A single
measured pair — the discarded attention mass at the knee and the held-out margin,
at any one cell of the grid — is a complete test of the margin channel.

**Theorem 11.3 (Amplitude from a single margin).** *A margin measured at one cell
fixes the tail amplitude: $A = m/(128\,LB)$.* Consequently one forward pass
supports two distinct readings: the constant, and — through Theorem 4.3 — the
depth scaling. The two experiments share their single measurement.

---

## 12. Algorithms

The theory yields three procedures a harness can run.

**Algorithm A (Implied-margin band test).** Given knees $K_1, K_2$ at depths
$d_1, d_2$, a calibration $c$, and a tolerance $\eta$: verify
$|K_i - d_i\mathrm{ctx}/c| \le \eta\, d_i \mathrm{ctx}/c$ for $i = 1,2$; compute
$r = d_1K_2/(d_2K_1)$; certify $r \in [(1-\eta)/(1+\eta), (1+\eta)/(1-\eta)]$.
Cost: $O(1)$. Correctness: Theorem 4.1.

**Algorithm B (Grid adequacy).** Given a candidate geometric grid step $\rho$ and
a target window $[1/w, w]$: report *adequate* iff $\rho \le w$. Justified by
Theorems 8.2, 8.3 and 8.5: the achievable window is exactly $[1/\rho, \rho]$.
Cost: $O(1)$; the corresponding grid has
$\lceil \log(k_{\max}/k_{\min})/\log \rho\rceil$ points, so the sweep cost grows
only logarithmically in the budget range and like $1/\log\rho$ in the precision.

**Algorithm C (Majority verdict).** Given the reported list $\ell$ of per-run
margin ratios: count $N_{\text{in}} = \#\{x \in \ell : 0.9 \le x \le 1.1\}$;
accept iff $2N_{\text{in}} > |\ell|$. Cost: $O(|\ell|)$, one pass. Soundness:
Theorem 9.7; sharpness: Theorem 9.8.

---

## 13. Discussion

**What the result is not.** It is not a claim that deeper networks are more
confident. It is a conditional: *given* the margin channel and a measured
depth-linear knee, the margin is depth-free. The value of the conditional is that
its two sides are separately measurable, so it can be broken.

**What makes it testable.** Three features. First, complete cancellation of
nuisance parameters (Remark 4.2): nothing can be refitted after the fact. Second,
a factor-four separation between the hypotheses (§5), which survives $50\%$
multiplicative noise. Third, sharpness (Theorems 4.5, 8.3, 9.8): each conclusion
is the exact image of its hypothesis, so the protocol's requirements — a $\pm 1/21$
knee, a $\rho \le 11/10$ grid, a strict majority — are necessary, not cautious.

**What it says about existing sweeps.** Corollary 8.4 is the sobering item. The
tidy dyadic observation $k^* = 16, 32, 64$ at $d = 4, 8, 16$ is fully compatible
with a factor-two margin drift, so it cannot serve as evidence for or against the
depth leg at the precision claimed. Similarly, Theorem 9.3 shows that a two-seed
protocol reporting a median cannot support any claim at all under a single
failure. Both defects are cheap to fix.

**Structural reading.** The isometry of Theorem 7.2 is the conceptual centre. The
map from measured knees to implied margins is a projective transformation of the
positive ray; the quantities that cannot be measured ($A$, $LB$) enter only as
projective rescalings, and are therefore invisible to the only statement one is
making — a statement about ratios. This is why an experiment about an unmeasurable
constant becomes an experiment about a pure number.

**Limitations.** (i) The tail model is scale-free; §10.2 bounds the damage
quantitatively but does not eliminate the assumption. (ii) The depth leg is a
worst-case Lipschitz composition bound; if the true accumulation is sublinear,
the pinned margin acquires a residual depth dependence, which the exponent bound
of Theorem 6.3 would then absorb into a nonzero $\alpha$. (iii) The band theorem
treats measurement error as a deterministic relative bound rather than a
distribution; the median machinery of §8.2 handles gross errors, but a full
probabilistic treatment of small errors is not attempted here. (iv) The
$\pm 10\%$ claim is about *ratios*; the absolute value $128\,LBA$ requires an
independent estimate of $A$ or of $LB$.

---

## 14. Future directions

**Projective rigidity of the whole (depth $\times$ context) grid.** The map from
the full measured grid $k^*(d, \mathrm{ctx})$ to the implied margins is an
isometry of the Hilbert projective metric on the positive cone; the conjecture is
that its image is a single point up to a ball of radius
$\log\frac{1+\eta}{1-\eta}$ — in particular that the grid's cells cannot exhibit
more than that total spread, however they are paired. Since the pairwise map is
already known to be an isometry, the multi-cell statement is a question about the
diameter of the image of a product of intervals: convex geometry, not statistics.
A violation would localise the failure to one cell rather than impugning the
mechanism as a whole.

**Optimal grid design as an information-theoretic problem.** Among sweeps with a
fixed number $N$ of budget evaluations per cell, is the geometric grid the unique
minimiser of the worst-case implied-margin window? Theorems 8.2–8.5 give the
answer for geometric grids; the extremal question over all grids is open.

**Sublinear depth legs.** Replace the worst-case linear accumulation by
$d^{\gamma}$ with $\gamma \le 1$ and re-derive the pinning theorem. The margin
would then be pinned to a value carrying $d^{\gamma - 1}$, and the exponent bound
of Theorem 6.3 becomes a *measurement of $\gamma$* rather than a consistency
check.

**Probabilistic bands.** Replace the deterministic tolerance $\eta$ by a
concentration statement over seeds, and ask for the smallest $n$ such that the
reported median lies in $[0.9, 1.1]$ with prescribed confidence. Theorem 9.2 is
the adversarial version; the stochastic version would set the seed budget from
observed variance rather than from a worst case.

**Beyond the median.** The verdict of §9.1 uses only order statistics. Trimmed
means and $M$-estimators have breakdown points between those of the mean and the
median; the question is whether any of them improves the seed budget while
retaining a soundness theorem as clean as Theorem 9.5.

---

## 15. Summary of results

| Result | Statement |
|---|---|
| Pinning | Channel $=$ depth-linear knee $d\,\mathrm{ctx}/c$ $\Rightarrow$ $m = 4cLBA$; at $c=32$, $m = 128LBA$ |
| Band theorem | Knees within $\pm\eta$ $\Rightarrow$ margin ratio in $[\frac{1-\eta}{1+\eta}, \frac{1+\eta}{1-\eta}]$ |
| Headline | $\eta = 1/21$ $\Rightarrow$ margins flat to $\pm 10\%$, at every pair of depths |
| Sharpness | The value $1.1$ is attained inside the $\pm 1/21$ band |
| Refutation | $m(16) = m(4)/4$ is inconsistent with in-band knees |
| Decision rule | Threshold $0.45$ correct on both sides under $\pm 50\%$ noise |
| Exponent bound | $\pm 10\%$ flatness $\Rightarrow \lvert\alpha\rvert \le \log(10/9)/\log 4 \approx 0.076$, so $\alpha \ne 1$ |
| Exact exponent | Exactly equal margins $\Rightarrow \alpha = 0$; measured knee ratio $4$ $\Rightarrow \alpha = 0$ |
| Equivalence | Depth-linear knee $\iff$ depth-free margin $128LBA$ |
| Isometry | Margin map is an isometry of $\rho(x,y) = \lvert\log(x/y)\rvert$; band is a ball |
| Non-accumulation | Direct depth comparison strictly beats chaining through intermediate depths |
| Grid theory | Step $\rho$ $\Rightarrow$ ratio band exactly $[1/\rho, \rho]$; dyadic fails; $\rho \le 11/10$ iff certifies |
| Aggregation | Mean breakdown $0$; every median of an in-band-majority log is in band |
| Seeds | $2k < n$; two seeds insufficient; three tolerate one failure |
| Verdict | Strict-majority rule sound; strictness necessary ($[1,1,2,2]$) |
| Channel rigidity | Inverse homogeneity $+$ linear depth $\Rightarrow K(d,m) = d\,K(1,1)/m$ |
| Tail rigidity | Knee ratio within $\pm\eta$ of $4$ $\Rightarrow \lvert 1/\beta - 1\rvert \le \log\frac{1}{1-\eta}/\log 4$; $\beta = 1$ exactly; $\beta \ne 2$ |
| Invariant | $\mathrm{tail}(k^*)\cdot LB/m \in [1/8, 1/4]$, free of $d$, $\mathrm{ctx}$, $A$, $LB$ |
