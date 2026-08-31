# Allocation, Deferral, and the Exact Arithmetic of an Adaptive Quadratic Sieve

**Author:** Aristotle
**Date:** 2026-08-31

---

## Abstract

We give a complete constants-layer theory of *adaptive scheduling* for a sieve in which
a cheap dial predicts each target's relation rate. The motivating measurement is an
adaptive quadratic sieve whose quadratic-residue dial is well calibrated (rank
correlation $0.739$ against the realised per-target yield, oracle dial $0.778$, larger
factor base $0.835$), yet in which the obvious use of the dial — reallocating sieve
length in inverse proportion to the predicted rate — *lost* $17.6\%$ of the total yield,
and lost $146.7\%$ when a floor clip was removed, while a rate-concentrator gained $8.6\%$
and a realised oracle bound sat $74.8\%$ above the baseline. We prove that all four signs
are forced by the allocation model alone, with no reference to calibration error.

Specifically, we show: (i) the inverse-rate policy yields the budget times the *harmonic*
mean of the rates while the uniform baseline yields the budget times the *arithmetic*
mean, so it can never win and loses strictly the moment two rates differ; (ii) the clipped
policy family is affine in the floor with slope $\sum r - n^2/\sum r^{-1} \ge 0$, so the
clip is a monotone parameter of one line whose endpoints are the unclipped policy and the
uniform baseline; (iii) concentrating on a maximal-rate target beats uniform and attains
the exact oracle bound $B \cdot r_{\max}$, whose gap over uniform is
$B(r_{\max} - \bar r)$ and whose ratio is at most the number of targets.

We then analyse the deployment that *did* work: using the dial to **defer** rather than
to reallocate. We prove a separation engine yielding *retention $\ge$ work fraction* for
concordant dials, a linear discordance budget $M\,|\mathrm{Disc}|$ for arbitrary dials, and
its sharp refinement by the **inversion mass** $\sum_{(j,i)\in \mathrm{Disc}}(r_j - r_i)$,
together with an exact two-sided identity expressing the retention deficit as inversion
mass minus concordance mass. We prove the policy space collapses: every maximal-yield
schedule of a given size is separated, the minimum-work quota-feasible schedule may be
taken separated, and hence a *single threshold* attains any attainable quota with
throughput at least that of full sieving; the excess of a threshold over a minimal
schedule is exactly its tie class, which is empty on a factor base.

Finally we compute the arithmetic layer exactly: for an odd prime $p$ with $N \not\equiv 0$,
$x^2 \equiv N \pmod p$ has exactly $2$ solutions per period if $N$ is a quadratic residue
and exactly $0$ otherwise, so the per-period hit rate is exactly $2/p$ or $0$. Consequently
the dial *is* the rate, the aggregate rate of a factor base $A$ is $2H_A$, the oracle
target is the smallest admissible prime with rate $2/p_{\min}$, and the headroom ratio is
exactly $|A|/(p_{\min} H_A)$, strictly below the crude ceiling $|A|$ once $|A| > 1$.

**Keywords:** quadratic sieve, adaptive allocation, AM–HM inequality, harmonic mean,
rank concordance, inversion mass, quadratic residues, threshold policy, throughput.

---

## 1. Introduction

### 1.1 The measurement

A sieve-based factoring run distributes a fixed computational budget over many
independent targets. Each target returns useful output (a *relation*) at some rate that
is not known in advance. A natural engineering idea is to build a cheap *dial* — a
predictor of the per-target rate computable before any expensive work is done — and then
schedule adaptively.

In the run that motivates this paper, the dial counted quadratic residues over small
primes. It performed well: Spearman rank correlation $0.739$ against the realised
per-target relation yield, against $0.778$ for an oracle dial evaluated on the same noisy
realisation, and $0.835$ on a factor base of $100$ primes. Twenty of twenty targets were
successfully factored end to end, with $1350$ relations independently reverified.

Four allocation outcomes were then measured against the uniform baseline (equal sieve
length per target):

| policy | outcome |
|---|---|
| sieve length $\propto 1/\text{predicted rate}$, with floor clip | $-17.6\%$ |
| same, floor clip removed | $-146.7\%$ |
| rate concentrator (budget pushed to high-rate targets) | $+8.6\%$ |
| realised oracle bound | $+74.8\%$ |

and separately, a *deployment flip*: thresholding the dial at its twentieth percentile
skipped $28.3\%$ of the work while retaining $89.5\%$ of the relations, a $28.9\%$
throughput gain. A hard tail of $40$ of $400$ targets was found to be unreachable at any
sieve depth.

### 1.2 The question, and the answer

The naive reading is that a dial with rank correlation $0.74$ is simply not accurate
enough to steer by, so the reallocation lost. This paper shows that reading is wrong in
a strong sense: **the losing policy loses for every rate vector, including one predicted
perfectly.** The sign of the inverse-rate rule is a property of the rule, and the floor
clip that made the loss survivable is a coordinate on an affine family whose slope is
exactly the AM–HM gap.

Everything below is stated at the *constants layer*: exact inequalities and identities
about a finite allocation model with no asymptotic parameters, no probabilistic
assumptions, and no calibration hypotheses beyond those explicitly named.

### 1.3 Structure

Section 2 fixes the allocation model. Section 3 proves the AM–HM core and the
inverse-rate loss. Section 4 analyses the floor clip. Section 5 gives the concentrator
and the oracle bound. Section 6 develops the deferral theory: separation, concordance,
discordance budgets, and the inversion-mass refinement. Section 7 proves the collapse of
the policy space to a single threshold, and the tie-slack identity. Section 8 computes
the arithmetic layer exactly. Section 9 states the two-sided threshold trade-off.
Section 10 gives algorithms; Section 11 numerical illustrations; Sections 12–13 discussion
and future work.

---

## 2. The allocation model

Fix a finite index set $s$ of targets, $|s| = n \ge 1$.

**Definition 2.1 (Rates and allocations).** A *rate vector* is a function
$r : s \to \mathbb{R}$; $r_i$ is the number of relations produced per unit of sieve length
spent on target $i$. An *allocation* is a function $\ell : s \to \mathbb{R}$ assigning a
sieve length to each target. The *yield* of $\ell$ against $r$ is
$$Y(r,\ell) \;=\; \sum_{i \in s} r_i\,\ell_i.$$
An allocation is *admissible for the budget $B$* if $\ell_i \ge 0$ for all $i$ and
$\sum_{i \in s}\ell_i = B$.

Note that the model is deliberately linear. Diminishing returns, dependence between
targets, and sieve-length nonlinearity are all absent; the point of the paper is that the
observed signs are already forced in this simplest model, so no richer model is needed to
explain them.

**Definition 2.2 (Three policies).** For a budget $B$:

- the **uniform baseline** $\ell^{\mathrm{unif}}_i = B/n$;
- the **inverse-rate policy** (for $r > 0$)
  $\displaystyle \ell^{\mathrm{inv}}_i = \frac{B\,r_i^{-1}}{\sum_{j \in s} r_j^{-1}}$;
- the **clipped inverse-rate policy with floor $f$**
  $\displaystyle \ell^{f}_i = f + \big(B - nf\big)\frac{r_i^{-1}}{\sum_{j\in s} r_j^{-1}}$.

Both $\ell^{\mathrm{inv}}$ and $\ell^{f}$ are budget-normalised: their coordinates sum to
$B$. Observe $\ell^{0} = \ell^{\mathrm{inv}}$ and $\ell^{B/n} = \ell^{\mathrm{unif}}$, so
the clipped family is a segment joining the two extreme policies.

- the **concentrator** on a target $i_0$: $\ell^{\mathrm{conc}}_i = B$ if $i = i_0$ and $0$
  otherwise.

**Definition 2.3 (Throughput).** For a nonempty set $K$ of targets all sieved to the same
length, the *throughput* is the mean rate
$$\mathrm{Th}(K) \;=\; \frac{1}{|K|}\sum_{i \in K} r_i,$$
i.e. relations per unit of work when work is proportional to $|K|$.

---

## 3. The inverse-rate policy must lose

### 3.1 The two yields

**Proposition 3.1 (Uniform yield).** $Y(r, \ell^{\mathrm{unif}}) = \dfrac{B}{n}\sum_{i\in s} r_i = B\cdot \operatorname{AM}(r).$

*Proof.* Immediate: $\sum_i r_i (B/n) = (B/n)\sum_i r_i$. $\square$

**Proposition 3.2 (Inverse-rate yield).** If $r_i > 0$ for all $i \in s$ and $s \ne \emptyset$,
$$Y(r, \ell^{\mathrm{inv}}) \;=\; \frac{Bn}{\sum_{i \in s} r_i^{-1}} \;=\; B\cdot\operatorname{HM}(r).$$

*Proof sketch.* Write $T = \sum_j r_j^{-1} > 0$. Each summand is
$r_i \cdot \big(B r_i^{-1}/T\big) = B/T$, independent of $i$; summing $n$ equal terms gives
$Bn/T$. $\square$

The inverse-rate policy is precisely the *equalising* policy: it makes every target
contribute the same number of relations. That is what makes it attractive and what makes
it lose.

### 3.2 The AM–HM core

**Theorem 3.3 (AM–HM, symmetrised form).** Let $r_i > 0$ for all $i \in s$, $|s| = n$. Then
$$n^2 \;\le\; \Big(\sum_{i \in s} r_i\Big)\Big(\sum_{i \in s} r_i^{-1}\Big).$$
If moreover there exist $a, b \in s$ with $r_a \ne r_b$, the inequality is strict.

*Proof.* Expand the product as a sum over ordered pairs:
$$\Big(\sum_i r_i\Big)\Big(\sum_j r_j^{-1}\Big) = \sum_{(i,j)\in s\times s} r_i r_j^{-1}.$$
The same product also equals $\sum_{(i,j)} r_j r_i^{-1}$, by exchanging the roles of the
two factors. Adding,
$$2\Big(\sum_i r_i\Big)\Big(\sum_j r_j^{-1}\Big) = \sum_{(i,j) \in s\times s}\Big(\frac{r_i}{r_j} + \frac{r_j}{r_i}\Big).$$
For positive $x,y$ one has the algebraic identity
$$\frac{x}{y} + \frac{y}{x} - 2 = \frac{(x-y)^2}{xy},$$
which is $\ge 0$, and $> 0$ exactly when $x \ne y$. Hence every one of the $n^2$ ordered
pairs contributes at least $2$ to the right-hand side, giving
$2\big(\sum r\big)\big(\sum r^{-1}\big) \ge 2n^2$. If $r_a \ne r_b$, the single pair
$(a,b)$ contributes strictly more than $2$, and the sum is strict. $\square$

The symmetrisation proof is worth isolating because it is the cleanest route to the
*strict* form, which is what the application needs: strictness is exactly the statement
that an informative dial makes the loss real rather than marginal.

### 3.3 The loss theorem

**Theorem 3.4 (Inverse-rate reallocation never wins).** Let $r_i > 0$ on a nonempty $s$
and let $B \ge 0$. Then
$$Y(r, \ell^{\mathrm{inv}}) \;\le\; Y(r, \ell^{\mathrm{unif}}).$$

*Proof.* By Propositions 3.1–3.2 the claim is $Bn/T \le B\Sigma/n$ where $T = \sum r^{-1} > 0$
and $\Sigma = \sum r$. Cross-multiplying by the positive quantities $T$ and $n$, this is
$Bn^2 \le B\,\Sigma T$, which follows from Theorem 3.3 and $B \ge 0$. $\square$

**Theorem 3.5 (Strict loss under an informative dial).** If in addition $r_a \ne r_b$ for
some $a,b \in s$ and $B > 0$, then
$$Y(r, \ell^{\mathrm{inv}}) \;<\; Y(r, \ell^{\mathrm{unif}}).$$

*Proof.* Identical, using the strict form of Theorem 3.3 and $B > 0$. $\square$

**Interpretation.** The rate vector in Theorems 3.4–3.5 is the *true* one. No predictor
appears anywhere in the statement. Therefore a dial with perfect calibration, deployed as
inverse-rate reallocation, still loses; and the loss is strictly positive precisely in the
regime where the dial carries information (unequal rates). The measured $-17.6\%$ is a
measurement of $1 - \operatorname{HM}(r)/\operatorname{AM}(r)$, not of predictor quality.

Quantitatively, the relative loss is exactly
$$1 - \frac{\operatorname{HM}(r)}{\operatorname{AM}(r)} = 1 - \frac{n^2}{\big(\sum r\big)\big(\sum r^{-1}\big)},$$
a scale-invariant functional of the rate distribution alone.

---

## 4. The floor clip is a coordinate, not a hack

**Theorem 4.1 (Affine clipped yield).** For a nonempty $s$, positive rates, and any $B, f$,
$$Y\big(r, \ell^{f}\big) \;=\; \frac{Bn}{T} \;+\; f\Big(\Sigma - \frac{n^2}{T}\Big), \qquad \Sigma = \sum_{i}r_i,\; T = \sum_i r_i^{-1}.$$

*Proof sketch.* Termwise,
$r_i \ell^f_i = r_i f + (B - nf)/T$, since the second piece again equalises across targets.
Summing gives $f\Sigma + n(B-nf)/T = Bn/T + f(\Sigma - n^2/T)$. $\square$

**Corollary 4.2 (Endpoints).** $\ell^{0} = \ell^{\mathrm{inv}}$ and $\ell^{B/n} = \ell^{\mathrm{unif}}$;
correspondingly $Y(\ell^0) = B\operatorname{HM}(r)$ and $Y(\ell^{B/n}) = B\operatorname{AM}(r)$.

*Proof.* At $f = 0$ the definition reduces literally to $\ell^{\mathrm{inv}}$. At $f = B/n$
the residual $B - nf$ vanishes, leaving the constant $B/n$. $\square$

**Theorem 4.3 (Monotonicity of the clip).** With positive rates on a nonempty $s$, the map
$f \mapsto Y(r, \ell^{f})$ is nondecreasing; it is *strictly* increasing as soon as two
rates differ.

*Proof.* By Theorem 4.1 the map is affine with slope $\Sigma - n^2/T$. By Theorem 3.3,
$\Sigma T \ge n^2$, and $T > 0$, so the slope is $\ge 0$; under $r_a \ne r_b$ the same
theorem gives $\Sigma T > n^2$, so the slope is $> 0$. $\square$

**Interpretation.** The two measured numbers $-17.6\%$ (clipped) and $-146.7\%$ (unclipped)
are two points of one straight line. Removing the clip is exactly travelling from an
interior point of the segment $[\,\ell^{\mathrm{inv}}, \ell^{\mathrm{unif}}\,]$ down to its
lower endpoint. There is no separate phenomenon to explain, and no clip value can push the
family above the uniform baseline, since the maximum over $f \in [0, B/n]$ is attained at
$f = B/n$, which *is* the baseline.

---

## 5. The concentrator and the exact oracle bound

**Proposition 5.1 (Concentrator yield).** If $i_0 \in s$, then
$Y(r, \ell^{\mathrm{conc}}) = r_{i_0}B$.

**Theorem 5.2 (The correct sign).** If $r_i \le r_{i_0}$ for all $i \in s$ and $B \ge 0$,
$$Y(r, \ell^{\mathrm{unif}}) \;\le\; Y(r, \ell^{\mathrm{conc}}).$$

*Proof.* $\sum_i r_i \le n\, r_{i_0}$, hence $B\sum_i r_i / n \le B r_{i_0}$. $\square$

**Theorem 5.3 (Oracle bound).** Let $r_i \le r_{i_0}$ on $s$, let $\ell_i \ge 0$ with
$\sum_i \ell_i = B$. Then $Y(r,\ell) \le r_{i_0} B$.

*Proof.* $\sum_i r_i \ell_i \le \sum_i r_{i_0}\ell_i = r_{i_0}B$, using $\ell_i \ge 0$
termwise. $\square$

**Theorem 5.4 (The bound is attained; it is the exact supremum).** Under the hypotheses of
Theorem 5.3, the concentrator on $i_0$ achieves $r_{i_0}B$ and dominates every admissible
allocation. Hence
$$\sup\{\,Y(r,\ell) : \ell \ge 0,\ \textstyle\sum \ell = B\,\} = B\,r_{\max},$$
attained.

**Corollary 5.5 (Exact headroom).** For nonempty $s$,
$$B\,r_{\max} - Y(r,\ell^{\mathrm{unif}}) = B\Big(r_{\max} - \frac{1}{n}\sum_{i} r_i\Big),$$
and, for nonnegative rates, $B\,r_{\max} \le n\,Y(r,\ell^{\mathrm{unif}})$.

*Proof.* The identity is a rearrangement of Proposition 3.1. The ratio bound follows from
$r_{\max} \le \sum_i r_i$ when all rates are nonnegative. $\square$

So the measured $+74.8\%$ oracle gap is bounded by the rate spread and by nothing else,
and cannot be an artefact of a loose bound: Theorem 5.4 says the bound is attained.

---

## 6. Deferral: the flip that wins

The reallocation results say what *not* to do. The deployment used the dial differently:
to decide which targets to work on at all, at a common sieve length.

**Definition 6.1 (Threshold sets).** For a dial $d : s \to \mathbb{R}$ and a threshold
$\theta$, the *kept* and *skipped* sets are
$$K_\theta = \{ i \in s : d_i \ge \theta \}, \qquad D_\theta = \{ i \in s : d_i < \theta\}.$$
They partition $s$.

**Definition 6.2 (Separation and concordance).** A split $s = K \sqcup D$ is *separated
with slack $c$* if $r_j \le r_i + c$ for all $i \in K$, $j \in D$; separated ($c=0$) means
every kept target is at least as good as every skipped one. A dial $d$ is *concordant*
with $r$ on $s$ if $d_i < d_j \Rightarrow r_i \le r_j$ for all $i,j \in s$.

Any monotone transform of the true rate is concordant; in particular the true rate is
concordant with itself (the oracle dial). A threshold on a concordant dial always produces
a separated split.

### 6.1 The separation engine

**Theorem 6.3 (Separation with slack).** If $s = K \sqcup D$ and $r_j \le r_i + c$ for all
$i \in K, j\in D$, then
$$|K|\sum_{i \in s} r_i \;\le\; |s|\sum_{i \in K} r_i \;+\; c\,|K|\,|D|.$$

*Proof sketch.* Write $\Sigma_K = \sum_K r$, $\Sigma_D = \sum_D r$, so $\sum_s r = \Sigma_K + \Sigma_D$
and $|s| = |K| + |D|$. Summing the hypothesis over all $(i,j) \in K \times D$ gives
$|K|\Sigma_D \le |D|\Sigma_K + c|K||D|$. Then
$$|K|\big(\Sigma_K + \Sigma_D\big) \le |K|\Sigma_K + |D|\Sigma_K + c|K||D| = |s|\Sigma_K + c|K||D|. \square$$

**Corollary 6.4 (Retention $\ge$ work fraction).** With $c = 0$ and $\sum_s r > 0$,
$$\frac{\sum_{i \in K} r_i}{\sum_{i \in s} r_i} \;\ge\; \frac{|K|}{|s|}.$$
Equivalently, $\mathrm{Th}(s) \le \mathrm{Th}(K)$: skipping by a separated rule never lowers
throughput. If some kept target strictly beats some skipped one, the inequality is strict.

This is exactly the shape of the measurement: $89.5\%$ of the relations retained for
$71.7\%$ of the work, a throughput gain of $+28.9\%$.

**Theorem 6.5 (An $\varepsilon$-accurate dial still wins, quantitatively).** If
$|d_i - r_i| \le \varepsilon$ for all $i \in s$, then for every threshold $\theta$,
$$|K_\theta|\sum_{i\in s} r_i \;\le\; |s|\sum_{i \in K_\theta} r_i \;+\; 2\varepsilon\,|K_\theta|\,|D_\theta|,$$
and in throughput form
$$\mathrm{Th}(s) \;\le\; \mathrm{Th}(K_\theta) \;+\; \frac{2\varepsilon |D_\theta|}{|s|}.$$

*Proof sketch.* For $i \in K_\theta$, $j \in D_\theta$ we have $d_j < \theta \le d_i$, hence
$r_j \le d_j + \varepsilon < d_i + \varepsilon \le r_i + 2\varepsilon$; apply Theorem 6.3
with $c = 2\varepsilon$ and divide. $\square$

A perfect dial recovers Corollary 6.4. The degradation is *linear in the accuracy*, and
the skip still wins whenever $2\varepsilon |D_\theta|/|s|$ is smaller than the throughput
gap the skip buys.

### 6.2 Rank error: discordance budgets

Accuracy in absolute value is the wrong currency for a rank-correlated dial. The right
currency is inversions.

**Definition 6.6 (Inversion set).** $\mathrm{Disc}(s;d,r) = \{(j,i) \in s\times s : d_j < d_i \text{ and } r_i < r_j\}$,
the ordered pairs the dial ranks backwards. Its cardinality is the unnormalised Kendall
discordance count.

**Theorem 6.7 (Linear discordance budget).** Suppose $0 \le r_i \le M$ on $s$. Then for every
$\theta$,
$$|K_\theta|\sum_{i \in s} r_i \;\le\; |s|\sum_{i\in K_\theta} r_i \;+\; M\,\big|\mathrm{Disc}(s;d,r)\big|,$$
and hence
$$\mathrm{Th}(s) \;\le\; \mathrm{Th}(K_\theta) \;+\; \frac{M\,|\mathrm{Disc}|}{|s|\,|K_\theta|}.$$

*Proof sketch.* Run Theorem 6.3's argument, but allow an exceptional set of pairs. For
$(j,i) \in D_\theta \times K_\theta$ *not* in $\mathrm{Disc}$, the dial's ordering
$d_j < \theta \le d_i$ forces $r_j \le r_i$, so the pair obeys separation; each exceptional
pair can contribute at most $M$ because $r_j - r_i \le M - 0 = M$. Summing gives the
penalty $M|\mathrm{Disc}|$. $\square$

With $\mathrm{Disc} = \emptyset$ this collapses to Corollary 6.4, so the budget is a
strict generalisation. Crucially the degradation is *linear*, not catastrophic, in the
number of inversions — which is why a dial with rank correlation well below $1$ still
retained $89.5\%$ of the relations.

### 6.3 The inversion-mass refinement

Theorem 6.7 charges every inversion the global maximum $M$, which is tight only when each
inversion pits a maximal target against a null one. The correct charge is the actual gap.

**Definition 6.8 (Inversion mass).**
$$\mathrm{IM}(s;d,r) \;=\; \sum_{(j,i)\in \mathrm{Disc}(s;d,r)} \big(r_j - r_i\big) \;\ge\; 0.$$

**Theorem 6.9 (Sharpened separation engine).** For *any* split $s = K \sqcup D$ — with no
boundedness and no sign hypothesis on $r$ —
$$|K|\sum_{i \in s} r_i \;\le\; |s|\sum_{i \in K} r_i \;+\; \sum_{(j,i)\in D\times K}\big(r_j - r_i\big)^{+},$$
where $x^{+} = \max(x,0)$.

*Proof sketch.* The exact identity
$$|K|\sum_{i\in s} r_i - |s|\sum_{i\in K} r_i \;=\; \sum_{(j,i) \in D\times K}\big(r_j - r_i\big)$$
follows by expanding the double sum as $|K|\Sigma_D - |D|\Sigma_K$ and substituting
$\sum_s r = \Sigma_K + \Sigma_D$, $|s| = |K| + |D|$. Then apply $x \le x^{+}$ termwise. $\square$

**Theorem 6.10 (Refined budget).** For every threshold $\theta$,
$$|K_\theta|\sum_{i \in s} r_i \;\le\; |s|\sum_{i \in K_\theta} r_i \;+\; \mathrm{IM}(s;d,r),$$
and $\mathrm{Th}(s) \le \mathrm{Th}(K_\theta) + \mathrm{IM}/(|s||K_\theta|)$.

*Proof sketch.* By Theorem 6.9 it suffices to bound the *kept inversion mass*
$\sum_{(j,i)\in D_\theta\times K_\theta}(r_j - r_i)^{+}$ by $\mathrm{IM}$. On such a pair
$d_j < \theta \le d_i$, so $(r_j - r_i)^{+}$ is nonzero exactly when $(j,i)$ is a
discordant pair, in which case it equals $r_j - r_i$; hence the kept mass is a subsum of
$\mathrm{IM}$ over nonnegative terms. $\square$

**Theorem 6.11 (Domination and consistency).**
(i) If $0 \le r \le M$ then $\mathrm{IM} \le M|\mathrm{Disc}|$, so Theorem 6.10 implies
Theorem 6.7; (ii) if every inversion has gap at most $g$ then $\mathrm{IM} \le g|\mathrm{Disc}|$
(a scale-free form); (iii) $\mathrm{IM} = 0$ if and only if $\mathrm{Disc} = \emptyset$, i.e. the
refinement is equality-preserving on concordant dials.

The refinement can be dramatically better. On three targets with rates $(10,3,2)$ and a
dial $(10,2,3)$ — correct on the dominant target, inverted on the two small ones — there is
exactly one inversion, the refined penalty is $1$, and the crude penalty is $10$.

**Theorem 6.12 (Exact deficit decomposition).** Define the *kept inversion mass* and *kept
concordance mass* at $\theta$:
$$\mathrm{IM}_\theta = \!\!\sum_{(j,i)\in D_\theta\times K_\theta}\!\!\big(r_j - r_i\big)^{+}, \qquad \mathrm{CM}_\theta = \!\!\sum_{(j,i)\in D_\theta \times K_\theta}\!\!\big(r_i - r_j\big)^{+}.$$
Then
$$|K_\theta|\sum_{i\in s} r_i - |s|\sum_{i \in K_\theta} r_i \;=\; \mathrm{IM}_\theta - \mathrm{CM}_\theta,$$
and consequently the sharpened budget
$$|K_\theta|\sum_{i\in s} r_i \;\le\; |s|\sum_{i\in K_\theta} r_i + \big(\mathrm{IM} - \mathrm{CM}_\theta\big).$$

*Proof sketch.* Use $x^{+} - (-x)^{+} = x$ termwise in the identity of Theorem 6.9. $\square$

This converts the one-sided budget into a ledger: the threshold *pays* the mass of the
pairs the dial inverts and *earns* the mass of the pairs it orders correctly. The
one-sided bound of Theorem 6.10 is tight exactly when the dial is never right about a
deferred/retained pair, i.e. $\mathrm{CM}_\theta = 0$ — a regime no informative dial is in.
This is the precise sense in which "Spearman $0.739$" is enough: what matters is not the
correlation coefficient but the *net* of paid and earned mass.

---

## 7. The policy space collapses to one real number

A deployment may in principle choose any subset $K \subseteq s$ of targets, subject to
collecting a relation quota $Q$. That is $2^{|s|}$ candidate schedules. We show the
optimum is always a threshold.

**Definition 7.1 (Separated schedule).** $T \subseteq s$ is *separated in $s$* if
$r_j \le r_i$ for every $i \in T$ and every $j \in s\setminus T$.

**Theorem 7.2 (Existence of best schedules).** For each $k \le |s|$ there is $T \subseteq s$
with $|T| = k$ maximising $\sum_{i\in T} r_i$ among all $k$-subsets.

*Proof.* Finitely many $k$-subsets; take a maximiser. $\square$

**Theorem 7.3 (Every maximiser is separated).** If $T\subseteq s$ maximises the total rate
among subsets of its own cardinality, then $T$ is separated in $s$.

*Proof.* Exchange argument. Suppose $i \in T$, $j \in s \setminus T$ with $r_j > r_i$.
Then $T' = (T \setminus \{i\}) \cup \{j\}$ has the same cardinality and total
$\sum_{T'} r = \sum_T r + (r_j - r_i) > \sum_T r$, contradicting maximality. $\square$

**Corollary 7.4 (Quota domination).** Any quota-feasible $K \subseteq s$ (i.e. $Q \le \sum_K r$)
is dominated at the same cost by a separated schedule of the same size.

**Theorem 7.5 (Minimum-work schedules may be taken separated).** If some $K \subseteq s$ has
$Q \le \sum_K r$, then there is $T \subseteq s$ with $Q \le \sum_T r$, $T$ separated in $s$,
and $|T| \le |K'|$ for every quota-feasible $K' \subseteq s$.

*Proof sketch.* Let $m$ be the least cardinality of a quota-feasible subset (well defined
by well-ordering of $\mathbb{N}$ and nonemptiness of the feasible set). Apply Theorem 7.2
at $k = m$ and Theorem 7.3. $\square$

**Lemma 7.6 (A separated set sits inside a threshold set).** For nonempty $T \subseteq s$,
$T \subseteq K_{\theta}$ with $\theta = \min_{i \in T} r_i$ and the dial taken to be $r$
itself. If moreover $r \ge 0$ on $s$, then $\sum_T r \le \sum_{K_\theta} r$, so the threshold
set is again quota-feasible.

**Theorem 7.7 (Threshold optimality).** Let $r \ge 0$ on $s$ and $Q > 0$ be attainable by
some subset. Then there is a threshold $\theta$ with
$$Q \;\le\; \sum_{i \in K_\theta} r_i \qquad\text{and}\qquad \mathrm{Th}(s) \;\le\; \mathrm{Th}(K_\theta).$$
Moreover the gain is strict as soon as the threshold defers a target strictly worse than
some retained one.

*Proof sketch.* Take the minimal separated feasible $T$ of Theorem 7.5, put
$\theta = \min_T r$, and combine Lemma 7.6 with Corollary 6.4 applied to the oracle dial
$d = r$ (which is concordant with itself). $\square$

So the deployment's search space collapses from $2^{|s|}$ subsets to one real parameter.
The skip-flip's threshold is not merely a good heuristic — it is the *shape* of the
optimum, and the only hypothesis is nonnegativity of rates.

### 7.1 Tie slack, and its arithmetic vanishing

A threshold retains *every* target at rate exactly $\theta$, so it may overshoot a minimal
schedule. The overshoot is exactly quantified.

**Definition 7.8 (Tie class).** $\mathrm{Tie}(\theta) = \{i \in s : r_i = \theta\}$.

**Theorem 7.9 (Excess equals tie class).** If $T$ is nonempty and separated in $s$ and
$\theta = \min_T r$, then, as sets,
$$K_\theta \setminus T \;=\; \mathrm{Tie}(\theta)\setminus T,$$
hence $|K_\theta| = |T| + |\mathrm{Tie}(\theta)\setminus T|$.

*Proof sketch.* $\subseteq$: if $i \in K_\theta \setminus T$ then $r_i \ge \theta$; separation
gives $r_i \le \min_T r = \theta$; so $r_i = \theta$. $\supseteq$: a tie member has
$r_i = \theta$, hence lies in $K_\theta$. $\square$

**Corollary 7.10 (No ties, no slack).** If $r$ is injective on $s$, then $K_\theta = T$
exactly: the threshold policy reproduces the minimum-work schedule on the nose.

The slack is not vacuous: on three targets with rates $(3,3,1)$ and quota $3$, the minimal
schedule has one element while the threshold at $\theta = 3$ retains two. But on a genuine
factor base it vanishes — see Theorem 8.7.

---

## 8. The arithmetic layer: the dial *is* the rate

Everything so far is allocation theory. The specific sieve supplies exact rates.

Fix a target integer $N$ and consider sieving values $x^2 - N$ for divisibility by a prime
$p$.

**Definition 8.1 (Per-period rate).** For a prime $p$,
$$\rho_N(p) \;=\; \frac{1}{p}\,\#\{\,x \in \{0,1,\dots,p-1\} : p \mid x^2 - N\,\},$$
the fraction of residues per period at which $p$ hits the sieve polynomial. A prime is
*admissible* for $N$ if it is odd, $N \not\equiv 0 \bmod p$, and $N$ is a quadratic residue
mod $p$.

**Theorem 8.2 (Exact solution counts).** Let $p$ be prime and $N \not\equiv 0 \bmod p$.

- If $p$ is odd and $N$ is a square mod $p$, then $x^2 \equiv N$ has exactly $2$ solutions.
- If $N$ is not a square mod $p$, then it has exactly $0$ solutions.

*Proof sketch.* If $N = b^2$ with $b \ne 0$, then $x^2 = b^2$ iff $(x-b)(x+b) = 0$ iff
$x = \pm b$ in the field $\mathbb{Z}/p$; for odd $p$, $b \ne -b$, so there are exactly two.
Non-squares have no solutions by definition. $\square$

**Corollary 8.3 (Exact rates).** For an admissible odd prime, $\rho_N(p) = 2/p$. For a
prime for which $N$ is a non-residue, $\rho_N(p) = 0$. Rates are always nonnegative.

*Proof sketch.* Counting solutions in a window of length $p$ is a bijection with counting
solutions in $\mathbb{Z}/p$ (reduction mod $p$ is a bijection from $\{0,\dots,p-1\}$), then
apply Theorem 8.2 and divide by $p$. $\square$

This is the crucial structural point: the quadratic-residue dial is not a statistical
proxy. **Up to the deterministic factor $2/p$, it is the rate itself.** The measured
Spearman coefficient below $1$ reflects noise in the *realised* finite-window yield, not
error in the dial.

**Theorem 8.4 (Non-residue primes are exactly null).** If $N$ is a quadratic non-residue
mod $p$, then $p$ divides *no* value $x^2 - N$ whatsoever, over all integers $x$. Hence its
empirical hit rate in every sieve window is identically $0$.

*Proof.* $p \mid x^2 - N$ would exhibit $N$ as the square of $x$ mod $p$. $\square$

**Corollary 8.5 (Null equaliser and the deferral instrument).** The yield of *any*
allocation is unchanged by deleting the null targets, and moving any positive amount of
budget off a null target onto a target of positive rate strictly increases the yield.
Consequently a hard tail of null targets (in the measurement, $40$ of $400$) is unreachable
by *any* amount of additional sieving: deferral, not depth, is the instrument.

**Theorem 8.6 (Small admissible primes carry the yield).** Among admissible odd primes,
$p \le q$ implies $\rho_N(q) \le \rho_N(p)$, since $2/p$ is decreasing in $p$; and
$\rho_N(p) > 0$ for admissible $p$.

This is the structural reason the concentrator gains and inverse-rate spreading loses: the
rate distribution over a factor base is genuinely spread, with the mass at the small primes.

**Theorem 8.7 (No ties on a factor base).** On a set $A$ of admissible odd primes, the rate
$p \mapsto 2/p$ is injective. Consequently (Corollary 7.10) the threshold policy is
*exactly* minimum-work: whenever a relation quota is attainable, there is a threshold whose
retained set meets the quota, has the minimum possible cardinality among all quota-feasible
schedules, and has throughput at least that of sieving the entire factor base.

**Theorem 8.8 (Aggregate factor-base rate).** Let $\mathrm{FB}$ be a factor base and
$A \subseteq \mathrm{FB}$ its admissible primes, every prime outside $A$ being inadmissible.
Then
$$R(\mathrm{FB}) \;=\; \sum_{p \in \mathrm{FB}} \rho_N(p) \;=\; \sum_{p \in A}\frac{2}{p} \;=\; 2H_A, \qquad H_A = \sum_{p\in A}\frac1p .$$
In particular the aggregate rate is a *deterministic arithmetic function* of the factor
base and $N$, not a statistical estimate, and $R(A) > 0$ for nonempty admissible $A$.

**Theorem 8.9 (Oracle target and exact headroom).** For a nonempty admissible $A$,
$$\max_{p \in A}\rho_N(p) \;=\; \frac{2}{p_{\min}}, \qquad p_{\min} = \min A,$$
so the oracle allocation is explicitly the smallest admissible prime. The ratio of the
oracle rate to the mean rate is exactly
$$\frac{\max_{p\in A}\rho_N(p)}{R(A)/|A|} \;=\; \frac{|A|}{p_{\min}\,H_A},$$
and this is *strictly* less than the crude ceiling $|A|$ whenever $|A| > 1$.

*Proof sketch.* The maximum is at the smallest prime by Theorem 8.6. Substituting
$R(A) = 2H_A$ into the ratio gives $(2/p_{\min})\cdot |A|/(2H_A)$. Strictness: for $|A|>1$,
$H_A > 1/p_{\min}$, so $p_{\min}H_A > 1$. $\square$

The crude bound of Corollary 5.5 said the headroom ratio is at most $|A|$; Theorem 8.9 says
it overshoots by exactly the factor $p_{\min}H_A$ — a quantity controlled by classical
estimates for sums of reciprocals of primes. As a worked instance, for $N = 2$ the primes
$7$ and $17$ are both admissible, the aggregate rate of $\{7,17\}$ is exactly
$2/7 + 2/17$, and the oracle target is $7$ with rate $2/7$.

---

## 9. The honest trade-off: throughput up, yield down

If skipping always helps, why not skip everything but the single best target? Because
the two objectives move oppositely.

**Theorem 9.1 (Throughput is monotone in the threshold).** For a concordant dial and
$\theta_1 \le \theta_2$ with $K_{\theta_2} \ne \emptyset$,
$$\mathrm{Th}(K_{\theta_1}) \;\le\; \mathrm{Th}(K_{\theta_2}).$$

*Proof sketch.* $K_{\theta_2} \subseteq K_{\theta_1}$ and $K_{\theta_2}$ is the
$\theta_2$-threshold set *of* $K_{\theta_1}$; apply Corollary 6.4 inside $K_{\theta_1}$,
using that concordance is inherited by subsets. $\square$

**Theorem 9.2 (Total yield is antitone in the threshold).** For nonnegative rates and
$\theta_1 \le \theta_2$,
$$\sum_{i\in K_{\theta_2}} r_i \;\le\; \sum_{i \in K_{\theta_1}} r_i,$$
strictly as soon as the higher threshold defers a target of positive rate.

**Corollary 9.3 (Quota-admissible thresholds form a down-set).** If $\theta_2$ meets the
quota and $\theta_1 \le \theta_2$, then $\theta_1$ meets it too. Hence the quota bounds
$\theta$ from above, and the operating point is the largest quota-feasible threshold.

This is the exact content of the headline pair "$+28.9\%$ throughput at $89.5\%$
retention": the two numbers are the two sides of a genuine trade-off, and the flip is
correct precisely when *work*, not relations, is the binding constraint.

---

## 10. Algorithms

Three procedures follow directly from the theory.

**(A) Allocation audit.** Given measured or predicted rates $r$, compute
$\operatorname{AM}(r)$, $\operatorname{HM}(r)$, $r_{\max}$, and hence the exact predicted
outcomes of every policy in Section 2 before running anything: the inverse-rate policy will
return $B\operatorname{HM}(r)$, the baseline $B\operatorname{AM}(r)$, the concentrator and
the oracle $Br_{\max}$. Cost: $O(n)$. This is the audit that would have prevented the
$-17.6\%$ run.

**(B) Clip-line evaluation.** Given $r$ and $B$, the clipped yield is the affine function
$Y(f) = Bn/T + f(\Sigma - n^2/T)$ on $f \in [0, B/n]$. Evaluate the slope; if it is positive
(equivalently, if the rates are not all equal) the optimum over the family is at the
right-hand endpoint, i.e. the uniform baseline. Cost: $O(n)$.

**(C) Optimal deferral schedule under a quota.** Sort targets by dial value descending;
accumulate rates until the quota is met; the resulting prefix is a minimum-work
quota-feasible schedule, realised by the threshold $\theta$ equal to its smallest dial
value. Report throughput before and after. Cost: $O(n\log n)$ for the sort, $O(n)$
thereafter. Correctness is Theorems 7.3, 7.5, 7.7, with exactness of the threshold form on
a factor base by Theorem 8.7.

A fourth, diagnostic, procedure computes the discordance ledger: enumerate ordered pairs,
accumulate $\mathrm{Disc}$, $\mathrm{IM}$, and, at a given $\theta$, $\mathrm{IM}_\theta$ and
$\mathrm{CM}_\theta$; the exact deficit identity of Theorem 6.12 then predicts the retention
shortfall before deployment. Cost: $O(n^2)$.

---

## 11. Numerical illustration

A three-target instance with rates $(1,2,5)$, budget $3$, reproduces the qualitative shape
of the measurement: $\operatorname{AM} = 8/3 \approx 2.667$, and
$\operatorname{HM} = 3/(1 + 1/2 + 1/5) = 3/1.7 \approx 1.765$, so the inverse-rate policy
yields $\approx 5.29$ against the baseline's $8$ — a loss of about $34\%$, of the same sign
as the measured $-17.6\%$. The concentrator yields $15$; the oracle bound is also $15$, a
headroom ratio of $15/8 = 1.875$, comfortably below the crude ceiling $3$. Deferring the
single worst target retains $7/8 = 87.5\%$ of the relations for $2/3 \approx 66.7\%$ of the
work (measured: $89.5\%$ for $71.7\%$), so throughput rises from $8/3$ to $7/2$.

For the discordance ledger, take rates $(10,3,2)$ with dial $(10,2,3)$: exactly one
inversion, inversion mass $1$, crude penalty $M|\mathrm{Disc}| = 10$ — a tenfold
overcharge by the unrefined bound.

For the arithmetic layer, take $N = 2$ and the factor base $\{7,17\}$: both primes are
admissible ($3^2 = 9 \equiv 2 \bmod 7$; $6^2 = 36 \equiv 2 \bmod 17$), the aggregate rate is
exactly $2/7 + 2/17 = 48/119$, the oracle target is $7$ with rate $2/7$, and the headroom
ratio is $|A|/(p_{\min}H_A) = 2/(7(1/7 + 1/17)) = 2 \cdot 119/(7\cdot 24) = 17/12 \approx 1.417$,
strictly below the crude ceiling $2$. By contrast $N = 2$ is a non-residue mod $5$, so $5$
divides no value $x^2 - 2$ at all and contributes rate exactly $0$ — a member of the hard
tail.

---

## 12. Discussion

**What the measurement was actually measuring.** The chief lesson is a separation of
concerns that is easy to lose in a production log: a *predictor* and a *policy* are
different objects, and the failure mode of the run was attributable entirely to the policy.
Theorems 3.4–3.5 make this airtight, because their statements never mention a predictor:
they compare two policies against the *true* rates. Any experiment measuring inverse-rate
reallocation against a uniform baseline is measuring
$1 - \operatorname{HM}(r)/\operatorname{AM}(r)$ and calling it dial performance.

**Why equalising is so tempting.** Inverse-rate allocation is the unique policy that makes
every target contribute the same yield (Proposition 3.2's proof). Fairness across targets
is a natural objective, and it is exactly orthogonal to total throughput. If the goal
really is per-target equity — for instance, if each target must individually reach a
relation count — then inverse-rate allocation is right and the AM–HM gap is the price of
that constraint, quantified exactly by Theorem 3.4.

**Clips as coordinates.** Engineering safeguards are often invisible to analysis because
they look like special cases. Theorem 4.1 shows this particular safeguard is a coordinate
on a one-parameter family joining two named policies, and Theorem 4.3 makes its
contribution monotone. The methodological point generalises: whenever a clip interpolates
between a proposed policy and a baseline, the clipped yield is worth computing as a
function of the clip parameter before attributing performance to either endpoint.

**Rank error is the right currency.** For deferral policies, absolute prediction error is a
crude and pessimistic instrument (Theorem 6.5's $2\varepsilon$ term scales with the rate
units). Inversions are dimensionless and, better, the *inversion mass* has the right units
and the right size. Theorem 6.12 goes further and shows the deficit is an exact ledger of
paid and earned mass. Because a well-calibrated dial earns much more mass than it pays,
this explains why a rank correlation far below $1$ suffices in practice.

**The arithmetic is not a heuristic.** In this application the rate is a closed-form
arithmetic quantity, $2/p$ or $0$. This has two consequences beyond precision. First, ties
are impossible, so the threshold policy is exactly optimal rather than optimal up to a tie
class (Theorem 8.7). Second, the hard tail is provably unreachable: no amount of extra work
converts a non-residue prime into a producer (Theorem 8.4). Any adaptive scheme that spends
*more* on low-yield targets — and inverse-rate allocation is precisely such a scheme — is
therefore pouring budget into an exactly null set. That, in one sentence, is why the
unclipped run lost more than $100\%$ of the baseline.

**Limitations.** The model is linear in sieve length. Real sieves have startup cost,
saturation as small primes exhaust their hits, and dependencies through the linear algebra
stage; total yield is only a proxy for the true objective, which is a full-rank relation
matrix. The results should therefore be read as governing the *marginal* allocation problem
at fixed sieve architecture. Similarly, the throughput objective assumes work is
proportional to the number of retained targets at a common sieve length; a mixed policy
(threshold *and* variable depth) is not covered.

---

## 13. Future directions

The theory settles the sign structure and much of the quantitative structure of adaptive
sieving at the constants layer:

- inverse-rate reallocation must lose, strictly once the dial is informative;
- the floor clip is a monotone parameter of one affine family, not a hack;
- the oracle bound $B \cdot r_{\max}$ is attained, hence exact;
- skipping by a concordant dial raises throughput, with a linear discordance budget when
  the dial is imperfect, refined to the inversion mass and then to an exact ledger;
- the null half of the mechanism is exact arithmetic: non-residue primes have per-period
  rate exactly $0$, admissible odd primes exactly $2/p$;
- the deployment policy space collapses: every maximal-yield schedule of a given size is
  separated, the minimum-work quota-feasible schedule may be taken separated, every
  separated schedule sits inside a single threshold, and on a factor base there are no
  ties.

Open directions:

1. **Nonlinear yield curves.** Replace $r_i\ell_i$ by a concave $g_i(\ell_i)$ modelling
   saturation. The AM–HM obstruction should generalise to a statement about the
   concave-conjugate of the yield curves; the question is whether the *sign* of the
   inverse-rate rule survives, and whether the clip remains a monotone coordinate.
2. **Mertens control of the headroom.** Theorem 8.9 gives the headroom ratio exactly as
   $|A|/(p_{\min}H_A)$. Combining this with classical estimates for $\sum_{p\le B} 1/p$
   over an admissible (density-$1/2$) subfamily should give a closed-form asymptotic for
   the maximal adaptive headroom of a factor base of bound $B$.
3. **Optimal thresholds under a joint constraint.** Section 9 shows throughput and total
   yield move oppositely in $\theta$. Characterising the Pareto frontier — and the optimal
   $\theta$ for a stated exchange rate between wall-clock and relations — remains open.
4. **Ledger-driven dial design.** Theorem 6.12 says a dial's value for deferral is
   $\mathrm{CM}_\theta - \mathrm{IM}_\theta$, not its correlation. Designing a dial that
   directly maximises the net mass, rather than a rank statistic, is a concrete and
   apparently unexplored objective.
5. **Beyond a single threshold.** The collapse theorem assumes a common sieve depth on the
   retained set. Allowing depth to vary reintroduces the allocation problem *inside* the
   retained set, where Section 5 says the optimum is degenerate (concentrate) and practice
   says otherwise; reconciling these requires the nonlinear model of direction 1.

---

## 14. Conclusion

The four measured numbers — $-17.6\%$, $-146.7\%$, $+8.6\%$, $+74.8\%$ — are one theorem
read four ways: the harmonic mean is below the arithmetic mean, the clipped family is the
affine segment joining them, the maximum is above the mean, and the maximum is exactly the
ceiling. None of them measures the dial. What the dial *is* good for is deferral, where
separation makes retention dominate the work fraction, imperfection costs at most a linear
inversion mass, and the optimal policy over all $2^n$ schedules is a single threshold. On a
quadratic-sieve factor base, where the rate is exactly $2/p$ or exactly $0$, that threshold
policy is exactly minimum-work, and the barren targets are barren by a theorem of
elementary number theory rather than by bad luck.
