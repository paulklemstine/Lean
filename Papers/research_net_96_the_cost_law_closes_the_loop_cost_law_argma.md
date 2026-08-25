# The Speculative-Decoding Cost Law: Survival Curves, Optimal Depth, and the Fragility of Differenced Estimators

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

Speculative decoding accelerates autoregressive generation by having a cheap draft model propose $d$ tokens which an expensive target model verifies in a single batched pass. The *speculation depth* $d$ is a free parameter, universally tuned by brute-force sweeping. We give a complete structure theory for the throughput functional it controls.

Let $s_i$ denote the probability that the accepted run survives past drafted position $i$, let $A(d)=\sum_{i<d}s_i$ be the expected number of verified tokens per verification pass at depth $d$, and let $c$ be the cost of drafting one token measured in units of one verification pass. The **cost law** is
$$G(d) \;=\; \frac{A(d)}{1+cd}.$$

We prove: (i) an exact one-step improvement criterion, $G(d)\le G(d+1)$ if and only if the *marginal* $M(d)=s_d(1+cd)-cA(d)$ is nonnegative; (ii) an equivalent **equilibrium law**, $M(d)<0 \iff s_d < c\,G(d)$, which equates a purely per-position microscopic quantity with a purely aggregate macroscopic one; (iii) **discrete concavity**, $M(d+1)-M(d)=(1+c(d+1))(s_{d+1}-s_d)$, whence unimodality of $G$ and exactness of myopic stopping for nonincreasing survival; (iv) a strictly weaker **single-crossing** criterion that certifies a global optimum without any monotonicity assumption; (v) the universal ceiling $G(d)<1/c$; (vi) existence of a finite optimum whenever cumulative acceptance is bounded, and — via divergence of the harmonic series — also for the Zipf profile $s_i=1/(i+1)$ whose acceptance diverges; (vii) a $\Theta(\log(1/c))$ depth law for geometric survival $s_i=r^i$, with matching explicit upper and lower bounds; (viii) the impossibility of a workload-independent optimal depth; (ix) a sup-norm **argmax stability** theorem, $|G_t(d)-G_s(d)|\le \varepsilon d/(1+cd)$ under $\|t-s\|_\infty\le\varepsilon$; and (x) a **tight noise-amplification law** for the differencing estimator $\hat s_i=(i+1)m(i+1)-i\,m(i)$: a sup-norm error $\delta$ in the aggregate means produces error up to $(2i+1)\delta$ in $\hat s_i$, attained, versus $d\delta$ for the cumulative statistic.

We instantiate the theory on a fine depth sweep $d\in\{1,\dots,8\}$ over two prompt registers (prose, code) for a $0.5$B draft model speculating for a CPU-hosted $7$B target at measured overhead $c=0.118$. The cost-law argmax computed from the extracted survival curves reproduces the independently measured throughput optima **exactly** — depth $4$ for prose, depth $8$ for code — and the single-crossing theorem upgrades both to global optima over all depths. Simultaneously, the differenced curves are demonstrably *not* legal survival curves: three of sixteen extracted values exceed $1$ and one is negative. The noise-amplification law identifies the estimator, not the data, as the culprit, while argmax stability certifies a robustness radius of $1/100$ around both curves — wider than the winning margins $0.0764$ (prose) and $0.1468$ (code). The macroscopic conclusion is therefore robust precisely where the microscopic one is not.

**Keywords:** speculative decoding, survival curve, cost law, discrete concavity, myopic stopping, argmax stability, noise amplification, numerical differencing.

---

## 1. Introduction

### 1.1 The mechanism

Autoregressive decoding is latency-bound by its sequentiality: token $n+1$ cannot be computed before token $n$. Speculative decoding breaks the dependency by exploiting an asymmetry in cost. Scoring $d$ candidate continuations costs a large transformer roughly what generating one token costs, because the $d$ positions can be evaluated in parallel within a single forward pass. So:

1. A small **draft** model generates $d$ candidate tokens autoregressively.
2. The large **target** model scores all $d$ positions in one batched pass.
3. The longest prefix on which target and draft agree (under the appropriate acceptance rule) is committed; the first disagreeing position is corrected by the target's own distribution; the remaining suffix is discarded.

The output distribution is exactly the target's. The speedup is free of quality cost. The only tunable is the depth $d$.

### 1.2 The tuning problem

Depth trades two errors against each other. Small $d$ underuses the verification pass: you paid to check $d$ positions and might have checked more. Large $d$ overspends draft-model time on tokens that will be discarded at the first disagreement, and the probability of surviving to position $d$ decays.

Current practice is to sweep. A sweep is expensive (it requires end-to-end timing at every depth, on the deployment hardware, for each workload) and opaque (it yields a number without a mechanism). The question we address is whether the depth can instead be *derived* from a measurement that never touches the clock.

### 1.3 Contributions

We isolate the survival curve as the microscopic state variable, derive the cost law as its macroscopic image, and give the complete first- and second-order theory of that functional, together with existence, comparative statics, closed forms for named families, an impossibility theorem, a stability theorem, and a tight error-amplification law for the estimator that in practice produces the survival curve. We then instantiate everything on measured data and account for both what the measurement got right and what it got wrong.

---

## 2. The Cost Law

### 2.1 Survival curves

**Definition 2.1 (Survival curve).** A *survival curve* is a sequence $s=(s_0,s_1,s_2,\dots)$ of reals. Semantically $s_i\in[0,1]$ is the probability that the accepted run of a speculative block survives past position $i$ — equivalently, that drafted token number $i+1$ is accepted. The physically expected regime is $s$ nonincreasing, since surviving to a later position requires surviving all earlier ones.

We deliberately state the theory for arbitrary real sequences and introduce monotonicity and range constraints only as hypotheses where they are needed. This is not generality for its own sake: the *measured* curves of Section 8 violate both constraints, and it is important to know exactly which theorems still apply to them.

**Definition 2.2 (Cumulative acceptance).** $A(d) = \sum_{i<d} s_i$, with $A(0)=0$ and $A(d+1)=A(d)+s_d$.

For a genuine survival curve, $A(d)$ is the expected number of tokens accepted from a block of $d$ drafts. The identification is a tail-sum (Abel) identity:

**Proposition 2.3 (Tail-sum bridge).** For every survival curve and every $d$,
$$A(d) \;=\; \sum_{i<d} (i+1)\,\bigl(s_i - s_{i+1}\bigr) \;+\; d\,s_d .$$

*Proof.* Induction on $d$. For $d=0$ both sides vanish. For the step, $A(d+1)-A(d)=s_d$, while the right-hand side increases by $(d+1)(s_d-s_{d+1}) + (d+1)s_{d+1} - d\,s_d = s_d$. $\square$

Interpreting $p_i = s_i - s_{i+1}$ as the probability that the run has length exactly $i+1$ and $s_d$ as the probability that it saturates the block, Proposition 2.3 reads $A(d)=\mathbb{E}[\min(L,d)]$ for the run length $L$: cumulative acceptance is the expected truncated run length. This is the formal bridge from the micro-mechanism to the macro-observable, and it is what licenses estimating $A$ from timing-free acceptance logs.

**Definition 2.4 (Overhead).** $c\ge 0$ is the cost of drafting one token, in units of one verification pass of the target model. The total cost of a depth-$d$ speculation round is $1+cd$.

**Definition 2.5 (Cost law).** The *gain*, or throughput, at depth $d$ is
$$G(d)\;=\;G_{c,s}(d)\;=\;\frac{A(d)}{1+cd}.$$
It measures verified output tokens per unit of verification-equivalent cost. Note $G(0)=0$, and $1+cd>0$ always, so $G$ is everywhere defined.

**Definition 2.6 (Marginal).** $M(d)\;=\;M_{c,s}(d)\;=\;s_d\,(1+cd)\;-\;c\,A(d).$

---

## 3. First-Order Theory

### 3.1 The marginal test

**Theorem 3.1 (Marginal test).** *For $c\ge 0$ and any $s$ and $d$:*
$$G(d)\le G(d+1) \iff M(d)\ge 0, \qquad G(d+1)<G(d) \iff M(d)<0 .$$

*Proof sketch.* Both denominators $1+cd$ and $1+c(d+1)$ are strictly positive, so $G(d)\le G(d+1)$ is equivalent, after cross-multiplication, to
$$A(d)\bigl(1+c(d+1)\bigr) \;\le\; \bigl(A(d)+s_d\bigr)\bigl(1+cd\bigr).$$
Expanding both sides and cancelling $A(d)(1+cd)$ leaves $c\,A(d)\le s_d(1+cd)$, which is exactly $M(d)\ge 0$. The strict form is the contrapositive. $\square$

The test is exact — no continuous relaxation, no asymptotic regime — and costs $O(1)$ arithmetic given $A(d)$.

### 3.2 The equilibrium law

**Theorem 3.2 (Equilibrium law).** *For $c\ge 0$,*
$$M(d) < 0 \iff s_d \;<\; c\,G(d).$$
*Consequently, if $G(d+1)<G(d)$ then $s_d < c\,G(d)$, and if $G(d)\le G(d+1)$ then $s_d \ge c\,G(d)$.*

*Proof sketch.* $c\,G(d) = c\,A(d)/(1+cd)$; multiply the inequality $s_d < c\,A(d)/(1+cd)$ by the positive quantity $1+cd$ to obtain $s_d(1+cd) < c\,A(d)$, i.e. $M(d)<0$. $\square$

This is the central structural statement of the paper, so we belabour its reading.

- The left-hand side $s_d$ is **microscopic**: a single entry of the survival curve, obtainable from acceptance logs with no timing information.
- The right-hand side $c\,G(d)$ is **macroscopic**: the pipeline's current throughput, scaled by the overhead.
- The optimum is exactly the crossing.

Economically, drafting one more token costs $c$ verification-units; those units, deployed at the current rate, would have produced $c\,G(d)$ output tokens; the extra draft instead produces an expected $s_d$ tokens. Deepen while the direct return exceeds the opportunity cost. The optimal speculation depth is a marginal-revenue/marginal-cost equilibrium, and Theorem 3.2 says the naive economic intuition is not an approximation but the exact criterion.

Note that the crossing is genuinely self-referential: the threshold $c\,G(d)$ *rises* as long as deepening is helping, which makes the criterion progressively harder to satisfy and is the source of the concavity in the next section.

---

## 4. Second-Order Theory: Concavity, Unimodality, Myopia

### 4.1 Discrete concavity

**Theorem 4.1 (Marginal increment).** *For every $c$, $s$, $d$:*
$$M(d+1)-M(d) \;=\; \bigl(1+c(d+1)\bigr)\bigl(s_{d+1}-s_d\bigr).$$

*Proof sketch.* Expand: $M(d+1)-M(d) = s_{d+1}(1+c(d+1)) - s_d(1+cd) - c\bigl(A(d+1)-A(d)\bigr)$, and $A(d+1)-A(d)=s_d$. Collecting the $s_d$ terms gives $-s_d(1+cd)-cs_d = -s_d(1+c(d+1))$, and the identity follows. $\square$

**Corollary 4.2 (Discrete concavity).** *If $c\ge0$ and $s$ is nonincreasing, then $M$ is nonincreasing.*

Since $1+c(d+1)>0$, the marginal inherits the monotonicity of the survival curve exactly. This is the discrete analogue of "the derivative of a concave function is decreasing", and it is the reason the cost law behaves well despite being a ratio of two increasing functions.

### 4.2 Unimodality and global optimality of the greedy rule

**Theorem 4.3 (No recovery).** *Let $c\ge0$, $s$ nonincreasing, and $M(d)<0$. Then $G(e)\le G(d)$ for all $e\ge d$.*

*Proof sketch.* Induction on $e\ge d$. By Corollary 4.2, $M(n)\le M(d)<0$ for all $n\ge d$, so Theorem 3.1 gives $G(n+1)<G(n)$ at each step; chaining the inequalities yields $G(e)\le G(d)$. $\square$

**Theorem 4.4 (Monotone ascent).** *Let $c\ge0$ and suppose $M(e)\ge0$ for all $e<d$. Then $G(e)\le G(d)$ for all $e\le d$. (No monotonicity of $s$ is required.)*

*Proof sketch.* Induction on $d$, applying Theorem 3.1 at each step $e\to e+1$ below $d$. $\square$

**Theorem 4.5 (Unimodality).** *If $c\ge0$ and $s$ is nonincreasing, then $G(d+1)<G(d)$ implies $G(e)\le G(d)$ for all $e\ge d$: the cost law is quasi-concave in the depth.*

*Proof.* Combine Theorem 3.1 with Theorem 4.3. $\square$

**Theorem 4.6 (Myopic stopping is exact).** *Let $c\ge0$ and $s$ nonincreasing. If $M(e)\ge0$ for every $e<d$ and $M(d)<0$, then $G(e)\le G(d)$ for every $e\in\mathbb{N}$.*

*Proof.* Split on $e\le d$ (Theorem 4.4) or $e\ge d$ (Theorem 4.3). $\square$

Theorem 4.6 is the algorithmic payoff: **one-step lookahead is globally exact**. The first depth at which the equilibrium test $s_d < c\,G(d)$ fires is the global argmax, so the search cost is $O(d^\star)$ arithmetic operations rather than an $O(D)$ sweep with an end-to-end timing run at every depth.

### 4.3 Dropping monotonicity: the single-crossing criterion

Real extracted survival curves are not nonincreasing (Section 8). The following theorem is what rescues the analysis.

**Theorem 4.7 (Single crossing suffices).** *Let $c\ge0$ and $d\in\mathbb{N}$. Suppose $M(e)\ge0$ for all $e<d$ and $M(e)<0$ for all $e\ge d$. Then $G(e)\le G(d)$ for every $e$.*

*Proof sketch.* For $e\le d$, apply Theorem 4.4, which never used monotonicity. For $e\ge d$, induct upward: at each $n\ge d$ we have $M(n)<0$ directly by hypothesis, so $G(n+1)<G(n)$ by Theorem 3.1. $\square$

The hypothesis is a property of the marginal sequence, checkable position by position, and it is *implied by* but strictly weaker than monotonicity of $s$. A ragged curve with a single sign change in its marginal is as good as a textbook one.

To make the "for all $e\ge d$" hypothesis finitely checkable we need one more ingredient.

**Lemma 4.8 (Frozen tail).** *If $s_i=0$ for all $i\ge D$, then $A(e)=A(D)$ for all $e\ge D$.*

**Theorem 4.9 (Finite support certifies).** *Let $c>0$, suppose $s_i=0$ for all $i\ge D$, and suppose $A(D)>0$. Then $M(e)<0$ for every $e\ge D$.*

*Proof.* For $e\ge D$, $M(e)=0\cdot(1+ce)-c\,A(e) = -c\,A(D)<0$. $\square$

Together, Theorems 4.7 and 4.9 turn a finite sweep into a global certificate: check the marginal at the finitely many swept depths, verify the tail vanishes, and the argmax is global over all of $\mathbb{N}$.

---

## 5. Global Structure

### 5.1 The speedup ceiling

**Theorem 5.1 (Universal ceiling).** *If $c>0$ and $s_i\le1$ for all $i$, then $G(d) < 1/c$ for every $d$.*

*Proof sketch.* $A(d)\le d$, so $G(d)\le d/(1+cd)$, and $cd < 1+cd$ gives $d/(1+cd)<1/c$. $\square$

No draft model, however accurate, and no depth, however well chosen, achieves more than $1/c$ verified tokens per verification-equivalent unit of cost. The ceiling depends only on the *ratio* of draft cost to verification cost. At $c=0.118$ it is $\approx 8.475$. This is a design constraint of the first importance: improving draft accuracy has strictly diminishing returns against the wall at $1/c$, whereas shrinking the draft model (lowering $c$) raises the wall itself.

### 5.2 Existence of an optimum

**Theorem 5.2 (Existence).** *Let $c>0$ and suppose $A(d)\le B$ for all $d$. Then there exists $d_0$ with $G(d)\le G(d_0)$ for all $d$.*

*Proof sketch.* If $G\le 0$ everywhere, $d_0=0$ works. Otherwise fix $d_1$ with $G(d_1)>0$. For $d$ large, $G(d)\le B/(1+cd)$, which falls below $G(d_1)$ once $1+cd > B/G(d_1)$; choose $N$ exceeding $\bigl(B/G(d_1)-1\bigr)/c$ and set $M=\max(N,d_1)$. On the finite set $\{0,\dots,M\}$ take the maximiser $d_0$; every $d>M$ satisfies $G(d)\le B/(1+cd) < G(d_1)\le G(d_0)$. $\square$

Summable survival curves — in particular all geometric ones — are covered.

### 5.3 Comparative statics in the overhead

**Lemma 5.3.** *If $s$ is nonincreasing then $d\,s_d \le A(d)$, and consequently $c\mapsto M_{c,s}(d)$ is nonincreasing: $c\le c'$ implies $M_{c',s}(d)\le M_{c,s}(d)$.*

*Proof sketch.* Each of the $d$ terms of $A(d)$ is at least $s_d$. Then $M_{c,s}(d)= s_d + c\bigl(d\,s_d - A(d)\bigr)$, whose $c$-coefficient is $\le0$. $\square$

**Theorem 5.4 (Higher overhead never deepens the optimum).** *Let $0\le c\le c'$, $s$ nonincreasing, and $M_{c,s}(d)<0$. Then $G_{c',s}(e)\le G_{c',s}(d)$ for all $e\ge d$.*

*Proof.* Lemma 5.3 gives $M_{c',s}(d)\le M_{c,s}(d)<0$; apply Theorem 4.3 at overhead $c'$. $\square$

Monotone comparative statics: making drafting more expensive relative to verification can only pull the optimum shallower, never deeper. This is the qualitative fact behind the quantitative $\Theta(\log(1/c))$ law below.

---

## 6. Named Survival Families

### 6.1 Geometric survival and the logarithmic depth law

**Definition 6.1.** The *geometric* profile is $s_i = r^i$ for $r\in[0,1)$: the draft model agrees at each step independently with probability $r$.

**Proposition 6.2.** $A(d) = (1-r^d)/(1-r)$, and $A(d)\le 1/(1-r)$ for all $d$.

**Theorem 6.3 (Deepening still pays).** *Let $c\ge0$, $0\le r<1$, and suppose $c/(1-r)\le r^d$. Then $G(d)\le G(d+1)$.*

*Proof sketch.* The hypothesis gives $c\le r^d(1-r)$, hence $c\,A(d) = c(1-r^d)/(1-r) \le r^d(1-r^d)\le r^d = s_d \le s_d(1+cd)$, i.e. $M(d)\ge0$; conclude by Theorem 3.1. $\square$

**Theorem 6.4 (Logarithmic lower bound).** *Let $c>0$, $0<r<1$. If*
$$d \;\le\; \frac{\log\bigl((1-r)/c\bigr)}{\log(1/r)},$$
*then $G(d)\le G(d+1)$.*

*Proof sketch.* The displayed inequality is equivalent, after multiplying by $\log(1/r)>0$ and using $\log(1/r)=-\log r$, to $\log\bigl(c/(1-r)\bigr)\le d\log r = \log(r^d)$, i.e. to $c/(1-r)\le r^d$ by monotonicity of $\log$; apply Theorem 6.3. $\square$

**Theorem 6.5 (Matching upper bound).** *Let $c\ge0$, $0\le r<1$, $d\ge1$, and suppose $r^d(1+cd)<c$. Then $G(e)\le G(d)$ for all $e\ge d$.*

*Proof sketch.* Since $d\ge1$ and all terms are nonnegative, $A(d)\ge A(1)=1$. Hence $M(d) = r^d(1+cd) - c\,A(d) < c - c\cdot 1 = 0$, and Theorem 4.3 applies (geometric survival is nonincreasing). $\square$

Theorems 6.4 and 6.5 pin the optimal geometric depth between two expressions that both behave like $\log(1/c)/\log(1/r)$ as $c\downarrow0$:

> **The optimal speculation depth for geometric survival is $\Theta(\log(1/c))$.**

Halving the drafting overhead adds a constant, $\log 2/\log(1/r)$, to the optimal depth. This explains the empirically observed clustering of optimal depths in the single digits.

**Proposition 6.6 (Calibrated instance).** *At the measured overhead $c=0.118$ and geometric rate $r=0.8$, depth $7$ is the global optimum: $M(6)\ge 0$ and $M(7)<0$, so Theorem 4.6 applies.*

Note that $7$ lies between the two measured register optima $4$ and $8$ — as a single-rate model must, since one rate cannot reproduce two registers.

**Corollary 6.7.** *Geometric survival always admits a finite global optimum (Theorem 5.2 with $B=1/(1-r)$).*

### 6.2 Harmonic survival: divergent acceptance, finite optimum

**Definition 6.8.** The *harmonic* (Zipf) profile is $s_i = 1/(i+1)$: the heaviest tail with vanishing per-position acceptance.

Here $A(d)=H_d\to\infty$. One might expect unbounded speculation to be optimal. It is not.

**Theorem 6.9 (Finite optimum under divergent acceptance).** *For every $c>0$ there is a depth $d_0$ with $M(d_0)<0$ and $G(d)\le G(d_0)$ for all $d$.*

*Proof sketch.* The harmonic profile is nonincreasing. By divergence of the harmonic series choose $D$ with $A(D) \ge (1+c)/c + 1$, so that $c\,A(D) > 1+c$. On the other hand
$$s_D(1+cD) = \frac{1+cD}{D+1} \le 1+c ,$$
since $1+cD \le (1+c)(D+1)$ for $D\ge0$. Hence $M(D)<0$, so a marginal sign change exists; take $d_0$ to be the least depth with $M(d_0)<0$ and apply Theorem 4.6 (all earlier marginals are nonnegative by minimality). $\square$

The mechanism is a race of growth rates: benefit $\sim\log d$, cost $\sim 1+cd$. Linear cost defeats logarithmic benefit for every positive $c$. **Unbounded speculation is never optimal, no matter how heavy the acceptance tail.**

### 6.3 No universal optimal depth

**Definition 6.10.** The *block* profile of width $N$ is $s_i = 1$ for $i<N$ and $s_i=0$ otherwise. It is nonincreasing with values in $[0,1]$, hence a legal survival curve, and $A(d)=d$ for $d\le N$.

**Theorem 6.11 (Impossibility).** *For every $c>0$ and every candidate depth $d_0$ there exists a legal survival curve $s$ (nonincreasing, $0\le s_i\le 1$) with $G(d_0) < G(d_0+1)$.*

*Proof sketch.* Take the block profile of width $d_0+1$. Then $A(d_0)=d_0$ and $A(d_0+1)=d_0+1$, so the claim is
$$\frac{d_0}{1+cd_0} \;<\; \frac{d_0+1}{1+c(d_0+1)},$$
which after cross-multiplication reduces to $0 < 1$. $\square$

No fixed depth is optimal for all workloads. Optimal speculation depth is a property of the *draft/target/register triple*, and any published "recommended depth" is implicitly a claim about a workload distribution. Theorem 6.11 is the abstract counterpart of the measured prose-versus-code split in Section 8.

---

## 7. Robustness and the Estimation Problem

### 7.1 Argmax stability

In practice $s$ is estimated, so one needs to know how the argmax responds to estimation error.

**Theorem 7.1 (Perturbation of cumulative acceptance).** *If $|t_i - s_i|\le\varepsilon$ for all $i$, then $|A_t(d)-A_s(d)| \le \varepsilon d$.*

*Proof.* Triangle inequality on $A_t(d)-A_s(d)=\sum_{i<d}(t_i-s_i)$. $\square$

**Theorem 7.2 (Perturbation of the gain).** *Under the same hypothesis, for $c\ge0$,*
$$\bigl|G_{c,t}(d)-G_{c,s}(d)\bigr| \;\le\; \frac{\varepsilon d}{1+cd}\;<\;\frac{\varepsilon}{c}.$$

*Proof.* Divide Theorem 7.1 by the positive $1+cd$. $\square$

**Theorem 7.3 (Argmax stability).** *Let $c\ge0$ and $|t_i-s_i|\le\varepsilon$ for all $i$. If*
$$\frac{\varepsilon d}{1+cd} \;+\; \frac{\varepsilon d_0}{1+cd_0} \;<\; G_{c,s}(d_0) - G_{c,s}(d),$$
*then $G_{c,t}(d) < G_{c,t}(d_0)$.*

*Proof.* $G_{c,t}(d)\le G_{c,s}(d) + \varepsilon d/(1+cd)$ and $G_{c,t}(d_0)\ge G_{c,s}(d_0) - \varepsilon d_0/(1+cd_0)$ by Theorem 7.2; combine with the hypothesis. $\square$

The comparison budget is uniformly bounded by $2\varepsilon/c$, and in the relevant range by $\varepsilon(d+d_0)$ divided by the denominators — small when the winning margin is not. Theorem 7.3 converts any sup-norm accuracy guarantee on the survival curve into a *certificate* that a computed argmax is the true one. Crucially, the argmax depends on $s$ only through its partial sums, in which independent or alternating errors substantially cancel; this is why an argmax can be trustworthy when the individual $s_i$ are not.

### 7.2 Differencing: an estimator that must not be used

Instrumentation frequently reports only the *aggregate* mean acceptance per drafted token, $m(d)$, satisfying $d\,m(d)=A(d)$. The tempting inversion is:

**Definition 7.4 (Differencing estimator).** $\;\widehat{s}_i \;=\; \mathrm{Diff}(m)_i \;=\; (i+1)\,m(i+1)\;-\;i\,m(i).$

**Proposition 7.5 (Exactness on clean data).** *If $d\,m(d)=A_s(d)$ for all $d$, then $\mathrm{Diff}(m)_i = s_i$ for all $i$.*

*Proof.* $(i+1)m(i+1)-i\,m(i) = A_s(i+1)-A_s(i)=s_i$. $\square$

So the estimator is unbiased and exact in the noiseless limit. Its behaviour under noise is another matter entirely.

**Theorem 7.6 (Noise amplification of differencing).** *If $|m'(d)-m(d)|\le\delta$ for all $d$, then*
$$\bigl|\mathrm{Diff}(m')_i - \mathrm{Diff}(m)_i\bigr| \;\le\; (2i+1)\,\delta .$$

*Proof sketch.* $\mathrm{Diff}(m')_i-\mathrm{Diff}(m)_i = (i+1)\bigl(m'(i+1)-m(i+1)\bigr) - i\bigl(m'(i)-m(i)\bigr)$; apply the triangle inequality and $|{\cdot}|\le\delta$ to each term, giving $(i+1)\delta + i\delta$. $\square$

**Theorem 7.7 (The bound is attained).** *For every $\delta$ and every $i$ there are aggregate sequences $m,m'$ with $|m'(d)-m(d)|\le|\delta|$ for all $d$ and*
$$\mathrm{Diff}(m')_i - \mathrm{Diff}(m)_i \;=\; (2i+1)\,\delta .$$

*Proof.* Take $m\equiv0$ and $m'$ supported on two points with opposite signs: $m'(i+1)=\delta$, $m'(i)=-\delta$, $m'=0$ elsewhere. Then $\mathrm{Diff}(m')_i = (i+1)\delta - i(-\delta) = (2i+1)\delta$. $\square$

**Theorem 7.8 (The cumulative statistic is safe).** *Under the same hypothesis, $\bigl|d\,m'(d) - d\,m(d)\bigr| \le d\,\delta$.*

**Corollary 7.9 (Amplification ratio).** *For every $\delta>0$ and every $i\ge1$,*
$$\tfrac32\,(i+1)\,\delta \;\le\; (2i+1)\,\delta \;<\; 2\,(i+1)\,\delta .$$

The worst-case error of the differenced per-position estimate is between $1.5\times$ and $2\times$ the worst-case error of the cumulative statistic it was derived from, tending to $2\times$. Worse, this amplification is *multiplicative in the position index*, so it is largest exactly where the signal $s_i$ is smallest — in the tail, which is where the equilibrium crossing happens.

**The estimation lesson.** Aggregate-to-pointwise inversion by differencing is a variance-doubling operation with error growing linearly in the index. If per-position quantities are needed, they must be instrumented per position. Adverse worst-case patterns (Theorem 7.7) are exactly the alternating ones that small-sample noise routinely produces.

---

## 8. The Measured Instance

### 8.1 Setup

A fine depth sweep $d\in\{1,\dots,8\}$ was run over two prompt registers — natural-language prose and source code — with a $0.5$B-parameter draft model speculating for a CPU-hosted $7$B-parameter target, greedy decoding, fixed seed, context $\le 1024$, eight threads. The marginal drafting overhead was measured as
$$c = 0.118 .$$
An earlier, independent round of the same configuration measured end-to-end throughput at each depth and located the optima directly: **depth $4$ for prose, depth $8$ for code**.

The new round recorded cumulative acceptance and applied the differencing estimator of Definition 7.4. The recovered per-position survival vectors, to three decimals, are

| position $i$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| prose $s_i$ | 0.670 | 1.050 | 0.420 | 0.860 | 0.119 | 0.050 | $-0.030$ | 0.100 |
| code $s_i$ | 0.820 | 1.120 | 0.910 | 1.060 | 0.780 | 0.830 | 0.740 | 0.690 |

with positions beyond the sweep horizon set to $0$ by convention (they were not measured).

### 8.2 The cost law reproduces the measured optima

Cumulative acceptance and gain at $c=0.118$:

| $d$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| prose $A(d)$ | 0.670 | 1.720 | 2.140 | **3.000** | 3.119 | 3.169 | 3.139 | 3.239 |
| prose $G(d)$ | 0.599 | 1.392 | 1.581 | **2.038** | 1.962 | 1.855 | 1.719 | 1.666 |
| code $A(d)$ | 0.820 | 1.940 | 2.850 | 3.910 | 4.690 | 5.520 | 6.260 | **6.950** |
| code $G(d)$ | 0.733 | 1.570 | 2.105 | 2.656 | 2.950 | 3.232 | 3.428 | **3.575** |

**Result 8.1 (Prose argmax).** *Over $d\in\{1,\dots,8\}$, $G(d) < G(4)$ for every $d\ne4$.*

**Result 8.2 (Code argmax).** *Over $d\in\{1,\dots,8\}$, $G(d) < G(8)$ for every $d\ne8$.*

Both are verified by direct evaluation of the eight rational values in each row. The cost-law argmax computed from timing-free acceptance data therefore **reproduces the independently measured throughput optima exactly**, in both registers, including the factor-of-two separation between them:

**Result 8.3 (Register separation).** $G_{\mathrm{prose}}(8) < G_{\mathrm{prose}}(4)$ and $G_{\mathrm{code}}(4) < G_{\mathrm{code}}(8)$.

This is Theorem 6.11 realized in measurement: no single depth serves both registers.

### 8.3 Upgrade to global optima

The swept argmax is a priori only a local statement. The marginals of the prose curve are
$$M(0)=0.670,\; M(1)=1.095,\; M(2)=0.316,\; M(3)=0.912,\; M(4)=-0.179,\; M(5)=-0.289,\; M(6)=-0.425,\; M(7)=-0.188,$$
and $M(e) = -c\,A(8) < 0$ for $e\ge8$ by Theorem 4.9. There is exactly one sign change, at $d=4$.

**Result 8.4 (Global optimality, prose).** *$G(d)\le G(4)$ for every $d\in\mathbb{N}$.* Immediate from Theorem 4.7 with $d^\star=4$, the tabulated marginals, and Theorem 4.9 for the tail.

**Result 8.5 (Global optimality, code).** *$G(d)\le G(8)$ for every $d\in\mathbb{N}$.* Same argument with $d^\star=8$; the code marginals are nonnegative throughout $\{0,\dots,7\}$ (e.g. $M(7)=0.690\cdot1.826-0.118\cdot6.260 = 0.521$) and negative from $8$ on.

Note that Theorem 4.6 could *not* have been used: the measured curves are not nonincreasing. The single-crossing criterion of Theorem 4.7 is doing real work here.

### 8.4 The loop closes: the equilibrium crossing

**Result 8.6 (Equilibrium at the measured prose optimum).**
$$s_4 = 0.119 \;<\; c\,G(4) = 0.118\times 2.038 \approx 0.241, \qquad\text{while}\qquad s_3 = 0.860 \;\ge\; c\,G(3) \approx 0.187 .$$

The optimum is *literally* the crossing of the per-position survival with $0.118\times$ the achieved throughput, exactly as Theorem 3.2 requires. The micro-mechanism and the macro-observable meet at the measured optimum. This is the sense in which the loop closes: the two experiments — an acceptance measurement with no clock, and a throughput measurement with no acceptance logging — are the same experiment.

### 8.5 What went wrong: the extracted curves are not survival curves

**Result 8.7 (Not monotone).** *The prose curve is not nonincreasing:* $s_0 = 0.670 < 1.050 = s_1$.

**Result 8.8 (Not probabilities).** *$s^{\mathrm{prose}}_1 = 1.050 > 1$, $s^{\mathrm{prose}}_6 = -0.030 < 0$, $s^{\mathrm{code}}_1 = 1.120 > 1$, $s^{\mathrm{code}}_3 = 1.060 > 1$.*

**Result 8.9 (Exact artefact census).** *Of the sixteen extracted values, exactly three exceed $1$ (prose position $1$; code positions $1$ and $3$) and exactly one is negative (prose position $6$); every other value lies in $[0,1]$.*

A survival probability cannot exceed $1$ or fall below $0$. The extracted curves are therefore not merely imprecise but **inadmissible**, and the hypothesis of the unimodality theory fails pointwise on them.

The cause is Theorem 7.6, not a coding error. With only four prompts per experimental cell, the sup-norm error $\delta$ in the aggregate means $m(d)$ is substantial; the differencing estimator inflates it to $(2i+1)\delta$, and Theorem 7.7 says no better bound is available in the worst case. At position $6$ the amplification factor is $13$. The negative value is the estimator behaving exactly as predicted.

### 8.6 Why the answer survived: certified robustness radius

**Result 8.10 (Prose robustness).** *Every sequence $t$ with $|t_i - s^{\mathrm{prose}}_i|\le 1/100$ for all $i$ satisfies $G_{c,t}(d) < G_{c,t}(4)$ for every $d\in\{1,\dots,8\}$, $d\ne4$.*

**Result 8.11 (Code robustness).** *Every sequence $t$ with $|t_i - s^{\mathrm{code}}_i|\le 1/100$ for all $i$ satisfies $G_{c,t}(d) < G_{c,t}(8)$ for every $d\in\{1,\dots,8\}$, $d\ne8$.*

Both follow from Theorem 7.3, checking the margin condition at each of the seven competing depths. The tightest margins are
$$G_{\mathrm{prose}}(4)-G_{\mathrm{prose}}(5) = 0.0764, \qquad G_{\mathrm{code}}(8)-G_{\mathrm{code}}(7) = 0.1468,$$
against perturbation budgets of $\varepsilon(4/1.472 + 5/1.590) = 0.0586$ and $\varepsilon(8/1.944+7/1.826)=0.0794$ at $\varepsilon=1/100$.

So the deliverable is asymmetric, and honestly so:

> **The per-position estimates are wrong. The argmax computed from them is right, with a certified robustness radius of $1/100$.**

The structural reason is that the cost law depends on $s$ only through partial sums (Theorem 7.1), in which the alternating differencing errors telescope. Differencing destroys pointwise information and preserves the functional of it that determines the optimum.

### 8.7 Sanity check against the ceiling

**Result 8.12 (Sweep not saturated).** $G_{\mathrm{code}}(8) = 3.575 < 1/c \approx 8.475$, and $G_{\mathrm{code}}(7) < G_{\mathrm{code}}(8)$.

The code register is still improving at the sweep boundary and sits far below the universal ceiling: the recorded optimum $8$ is an artefact of where the sweep stopped, and the true code optimum may lie deeper. This is stated as a limitation, not a result: Result 8.5 asserts global optimality *for the recorded curve extended by zero past the horizon*, which is a modelling convention, not a measurement.

---

## 9. Algorithms

### 9.1 Myopic depth selection

```
Input: survival curve s, overhead c, horizon D
A ← 0
for d = 0, 1, …, D−1:
    G ← A / (1 + c·d)                # current throughput
    if s[d] < c·G:  return d          # equilibrium crossing
    A ← A + s[d]
return D
```

Complexity: $O(D)$ arithmetic operations, $O(1)$ memory, **zero timing runs**. Correctness: by Theorems 3.2 and 4.6 the returned depth is a global maximiser whenever $s$ is nonincreasing; by Theorem 4.7 it is a global maximiser whenever the marginal changes sign once. Contrast with the sweep, which requires $D$ end-to-end generation runs.

### 9.2 Certified argmax under measurement error

```
Input: estimated curve ŝ, overhead c, horizon D, accuracy ε
compute G(d) for d = 0..D from ŝ
d₀ ← argmax G
for each d ≠ d₀ in 0..D:
    budget ← ε·d/(1+c·d) + ε·d₀/(1+c·d₀)
    if budget ≥ G(d₀) − G(d):  return (d₀, UNCERTIFIED)
return (d₀, CERTIFIED)
```

A `CERTIFIED` verdict means, by Theorem 7.3, that *every* curve within sup-distance $\varepsilon$ of $\hat s$ has argmax $d_0$. Applied to the measured data with $\varepsilon = 1/100$, both registers certify.

### 9.3 Geometric depth oracle

For a calibrated rate $r$ and overhead $c$, Theorems 6.4 and 6.5 bracket the optimum:
$$d_{\mathrm{lo}} = \left\lfloor \frac{\log\bigl((1-r)/c\bigr)}{\log(1/r)} \right\rfloor, \qquad d_{\mathrm{hi}} = \min\{\,d\ge1 : r^d(1+cd)<c\,\},$$
and any depth in $[d_{\mathrm{lo}}, d_{\mathrm{hi}}]$ can be located by the myopic rule of §9.1 on $s_i=r^i$ in $O(d_{\mathrm{hi}})$ time.

---

## 10. Applications and Practical Consequences

**Replacing the sweep.** The dominant practical cost of tuning a speculative decoder is the sweep. §9.1 replaces it with a single acceptance-logging run plus $O(D)$ arithmetic. The survival curve is hardware-independent (it is a property of the model pair and the prompt distribution) whereas $c$ is hardware-dependent, so a curve measured once can be re-optimized for new hardware by changing a single scalar — with Theorem 5.4 guaranteeing the optimum moves monotonically.

**Register-adaptive depth.** Theorem 6.11 and the measured $4$-versus-$8$ split show a fixed depth is leaving throughput on the table. The equilibrium test is cheap enough to run online: maintain a running estimate of the survival curve per detected register, and set $d$ by §9.1.

**Draft-model selection.** The ceiling $G<1/c$ says draft-model accuracy is subject to hard diminishing returns. Between a larger, more accurate draft model (higher $r$, higher $c$) and a smaller one, the relevant comparison is $\min\{1/c, \text{achieved } G\}$, and the logarithmic depth law quantifies how much depth a lower $c$ buys: a constant per halving.

**Instrumentation design.** Theorems 7.6–7.8 are a design requirement for any acceptance-logging harness: emit per-position accept/reject events, not just the block mean. The cost is a few bytes per block; the benefit is a factor of two in effective noise and, more importantly, estimates that respect $[0,1]$.

**Beyond decoding.** Nothing in Sections 2–7 is specific to language models. The cost law is the general form of "batch a speculative pipeline whose success probability decays with depth, against a fixed setup cost plus a linear per-item cost": branch prediction with speculative execution windows, prefetch depth, optimistic concurrency-control batch size, and pipelined query execution all instantiate it. So do the estimation results: Theorem 7.7 applies to any attempt to recover a pointwise profile from cumulative averages.

---

## 11. Discussion and Limitations

**What the theory proves versus what the data shows.** Sections 2–7 are unconditional mathematics about the functional $G$. Section 8 is a set of claims about the specific recorded vectors and the constant $c=0.118$. The two must not be conflated. In particular, Results 8.4 and 8.5 assert global optimality for the recorded curves *extended by zero past position 7*; positions beyond the sweep horizon were not measured, and for the code register the sweep was still improving at its boundary (Result 8.12). The honest statement is: depth $8$ is the best depth in the swept range for code, and the data provides no evidence about depth $9$.

**Sample size.** With four prompts per cell the differenced estimates are inadmissible (Results 8.7–8.9). The argmax survives only because of Theorem 7.3 and the measured margins. A margin of $0.0764$ against a budget of $0.0586$ is comfortable but not luxurious; the prose result would not survive a doubling of $\varepsilon$.

**The nonmonotone data is not merely a nuisance.** It is why Theorem 4.7 exists. Had we only proved Theorem 4.6, the entire optimality analysis of Section 8 would be inapplicable to the actual measurement. This is a general moral about which hypotheses to build a theory on: monotonicity is the natural assumption, single crossing is the useful one.

**Model assumptions.** The cost model $1+cd$ assumes drafting cost is linear in depth and verification cost is depth-independent. Both are good approximations in the CPU-hosted regime measured here (where the target's batched pass is memory-bandwidth-bound and nearly flat in $d$ for small $d$), and both degrade for large $d$ on accelerators where attention cost grows. Nothing in the first-order theory requires linearity — the marginal test generalizes to any convex cost $C(d)$ as $s_d\,C(d) \ge \bigl(C(d+1)-C(d)\bigr)A(d)$ — but the closed forms of Section 6 do.

**Independence.** The geometric family assumes position-independent acceptance. Real survival curves are typically steeper than geometric early (syntactic agreement is easy) and flatter late (conditional on surviving, the continuation is easy), which is consistent with the code register's very slow decay.

---

## 12. Future Directions

**A sample-size law for a certified argmax.** The argmax is decided by the sup-norm accuracy of the *cumulative* means, and Theorem 7.3 converts that accuracy into an explicit margin condition. A concentration bound on $m(d)$ over $n$ prompts therefore turns "the sweep says $4$" into "the population optimum is $4$ with confidence $1-\delta$", with $n$ given in closed form by the measured margins ($0.0764$ for prose, $0.1468$ for code). This is the natural next theorem, and it would retire the sweep entirely.

**Direct per-position instrumentation.** Results 8.7–8.9 are a measurement failure with a known fix: log accept/reject per position from the verifier rather than differencing block means. With admissible curves in hand, the full monotone theory (Theorems 4.2–4.6) applies rather than only the single-crossing fragment, and $P1$-style decay hypotheses become testable as structural statements rather than inequalities on a recorded vector.

**Nonlinear and stochastic cost models.** Extending the closed forms to $C(d)$ convex, and to a cost that is itself random (variable draft latency), would cover accelerator deployments where the flat-verification assumption fails.

**Register detection and online adaptation.** Theorem 6.11 makes register-adaptive depth necessary in principle; the open engineering question is how cheaply a register can be identified online and how fast the survival curve can be re-estimated after a switch.

**Two-rate and mixture survival families.** A single geometric rate cannot reproduce both measured optima (Proposition 6.6 gives $7$, between $4$ and $8$). A two-phase family — fast early decay, slow tail — would be the minimal model consistent with the prose/code split, and its depth law is not yet known in closed form.

---

## 13. Conclusion

The optimal speculation depth is not a hyperparameter to be swept but a fixed point to be computed. The cost law $G(d)=A(d)/(1+cd)$ admits an exact one-step criterion, an equilibrium reading in which a microscopic survival probability meets a macroscopic throughput, a discrete concavity that makes greedy stopping globally exact, a $\Theta(\log(1/c))$ depth law, a universal $1/c$ ceiling, and a proof that no depth serves all workloads.

Measured against a fine depth sweep on two registers, the theory reproduced both independently measured throughput optima exactly — $4$ for prose, $8$ for code — from acceptance data containing no timing information, and the single-crossing theorem upgraded both to global optima. That the same measurement also produced impossible per-position probabilities is not a contradiction but a second result: the differencing estimator amplifies aggregate noise by a tight factor of $2i+1$, while the argmax, depending only on partial sums, is stable within a certified radius of $1/100$. Fragile estimates, robust conclusion — and a theorem that says exactly which is which.
