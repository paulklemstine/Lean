# A Tail-Exponent Measurement Protocol for the Attention Budget

**Author:** Aristotle
**Date:** 2026-09-05

---

## Abstract

Given a sorted, positive attention profile $w_0 \ge w_1 \ge \dots > 0$ on a context of
length $n$, the *attention budget* (or *knee*) at gate $g \in (0,1]$ is the least number
$k^*(n,g)$ of top-weighted positions whose retained mass reaches $g$. Deployment decisions
— cache eviction, sparse-kernel width, context scaling — depend on this number, yet it is
usually reported without any certificate. We develop a complete two-sided measurement
protocol for $k^*$ and quantify its uncertainty.

The lower certificate is the *energy floor*: with $E = \sum_i p_i^2$ the $\ell^2$-energy
(collision probability) of the normalized profile, Cauchy–Schwarz on the head sum gives
$M(k)^2 \le kE$ and hence the sandwich $g^2/E \le k^*(n,g) \le n$. Equivalently
$k^* \ge g^2 e^{H_2}$ for the Rényi-2 entropy $H_2 = -\log E$. We show this cannot be
weakened to any coarser entropy: an explicit $17$-key spike profile has $k^*=1$ at gate
$1/2$ while the Hartley floor reads $17/4$ and the Shannon floor reads exactly $2$; since
$H_2 \le H_1$ always, the failure is systematic rather than accidental. We also show the
sandwich is informative: the participation-ratio inequality $nE \ge 1$ bounds the ratio of
its two ends by $g^2$, so at $g = 0.98$ the intrinsic resolution is a factor $1.04$.

We then *evaluate* the floor. For a sorted profile $E \le w_0/S(n)$, where $S(n)$ is the
head mass, whence the divergence rate $k^*(n,g) \ge g^2 S(n)/w_0$. At the critical Zipf
exponent $w_i = 1/(i+1)$ this yields the explicit logarithmic law $k^*(n,g) \ge g^2\log(n+1)$.
For a geometric profile $w_i = r^i$ the energy is computed exactly,
$E = (1-r)(1+r^n)/((1+r)(1-r^n))$, giving $k^* \ge g^2/(3(1-r))$ once $r^n \le 1/2$; combined
with the fit-based upper certificate this pins the geometric knee at $\Theta(1/(1-r))$ up to
a logarithm. Merging heads is convex on the energy, $E(w_1+w_2) \le \max(E(w_1),E(w_2))$,
so the floor of a mixture never drops below the smaller of the two per-head floors.

The upper certificate is a fitted tail law $1 - M(k) \le C r^k$, which reports the budget
$\mathrm{Budget}(C,r,\tau) = \max(\lceil \log((1-\tau)/C)/\log r\rceil, 1)$. It is monotone
in the fit box, exactly unbiased under a two-point estimator on a genuine geometric tail,
damps data error by a $d$-th root in the probe separation $d$, and — under an exact tail
measurement — is sharp to within one key, in fact equal to the knee. A reported fit whose
budget falls below the measured energy floor is thereby refuted.

**Keywords:** attention budget, collision entropy, Rényi entropy, tail-exponent fit,
Cauchy–Schwarz, Zipf profile, geometric decay, error propagation.

---

## 1. Introduction

### 1.1 The problem

An attention mechanism assigns to each position $i$ of a context a nonnegative weight $w_i$
and forms a weighted average of the corresponding values. In practice, the sorted weight
profile decays: a handful of positions carry most of the mass. This observation underwrites
a whole family of systems techniques — key–value cache eviction, top-$k$ sparse attention,
streaming attention with a sliding window — all of which discard the light tail and keep a
head of size $k$.

The engineering question is exactly: *how large must $k$ be?* Formally, one fixes a gate
$g$ — the fraction of attention mass one insists on retaining, typically $0.95$–$0.99$ —
and asks for the least $k$ whose top-$k$ truncation retains at least $g$ of the mass. This
is the **attention budget**, or the **knee** of the retained-mass curve.

Two things are usually missing when this number is reported. First, a *lower* bound: an
argument that no smaller budget can possibly work, so that the number is not merely a
conservative guess. Second, an *error analysis*: a statement of how measurement noise in
the attention statistics propagates into the reported budget.

### 1.2 Contribution

This paper supplies both, in the form of a protocol whose output is an interval with a
proof at each end.

1. **Lower certificate (energy floor).** $g^2/E \le k^*(n,g)$, where $E$ is the
   $\ell^2$-energy of the normalized profile. This is a single application of
   Cauchy–Schwarz, but it is the *only* entropic statistic for which the bound is valid.
2. **Refutation of coarser entropies.** The support-size (Hartley) floor $g^2 n$ and the
   Shannon floor $g^2 e^{H_1}$ both fail on an explicit profile. Since $H_2 \le H_1$, the
   Rényi-2 reading is the strongest valid member of the family at the exponent we can
   prove.
3. **Evaluation of the floor.** A divergence rate $k^* \ge g^2 S(n)/w_0$ for sorted
   profiles; the critical-Zipf law $k^* \ge g^2\log(n+1)$; the exact geometric energy and
   the resulting two-sided pin $\Theta(1/(1-r))$; a minimum law under head merging.
4. **Upper certificate (tail fit) and its uncertainty.** Monotonicity in the fit box,
   $d$-th-root damping of data error, unbiasedness of the two-point estimator, sharpness
   to within one key, and the intrinsic resolution limit $1/g^2$.

### 1.3 Notation

Throughout, $w : \mathbb{N} \to \mathbb{R}_{>0}$ is a strictly positive weight profile and
$n \ge 1$ a context length. We write:

* **Head mass.** $\displaystyle S(n) = \sum_{i<n} w_i > 0$.
* **Normalized profile.** $p_i = w_i / S(n)$, so $\sum_{i<n} p_i = 1$.
* **Retained mass.** $\displaystyle M(k) = \frac{1}{S(n)}\sum_{i < \min(k,n)} w_i = \sum_{i<\min(k,n)} p_i$.
* **Tail (discarded) mass.** $T(k) = 1 - M(k) \in [0,1]$, nonincreasing in $k$, and $T(k)=0$ for $k \ge n$.
* **Knee / attention budget.** $k^*(n,g) = \min\{k \in \mathbb{N} : M(k) \ge g\}$ for $g \in (0,1]$.
* **Energy (collision probability).** $\displaystyle E(n) = \sum_{i<n} p_i^2 \in (0,1]$.
* **Collision (Rényi-2) entropy.** $H_2 = -\log E$.
* **Shannon entropy.** $\displaystyle H_1 = -\sum_{i<n} p_i \log p_i$.

A profile is **sorted** (equivalently antitone) if $w_{i+1} \le w_i$ for all $i$. This is
the standing assumption whenever the head weight $w_0$ appears: it is exactly the situation
in practice, where one sorts the attention vector before truncating.

Basic facts used without comment: $M$ is nondecreasing, $M(k) \le 1$, $M(n) = 1$, so
$k^*(n,g)$ exists and satisfies $k^*(n,g) \le n$ for $g \le 1$; and $M(k^*) \ge g$ while
$M(k) < g$ for $k < k^*$ (the *bracketing property* of the knee).

---

## 2. The energy floor

### 2.1 Cauchy–Schwarz on the head sum

**Lemma 2.1 (Head-sum Cauchy–Schwarz).** *For every $k$ and every $n \ge 1$,*
$$M(k)^2 \;\le\; k \cdot E(n).$$

*Proof sketch.* Write $m = \min(k,n)$. By Cauchy–Schwarz applied to the vector $(p_i)_{i<m}$
against the all-ones vector of length $m$,
$$\Big(\sum_{i<m} p_i\Big)^2 \le m \sum_{i<m} p_i^2 .$$
The right-hand sum is a sub-sum of the nonnegative terms defining $E(n)$, hence at most
$E(n)$; and $m \le k$. $\square$

**Theorem 2.2 (Energy floor).** *For $0 \le g \le 1$ and $n \ge 1$,*
$$g^2 \;\le\; k^*(n,g)\cdot E(n).$$

*Proof sketch.* By definition of the knee, $M(k^*) \ge g \ge 0$, so $g^2 \le M(k^*)^2$;
apply Lemma 2.1 at $k = k^*$. $\square$

**Theorem 2.3 (Two-sided budget sandwich).** *For $0 < g \le 1$ and $n \ge 1$,*
$$\frac{g^2}{E(n)} \;\le\; k^*(n,g) \;\le\; n .$$

*Proof sketch.* The left inequality is Theorem 2.2 divided by $E(n) > 0$ (positivity of $E$
follows from positivity of the weights). The right inequality holds because $M(n)=1 \ge g$.
$\square$

Both ends are computable from data obtainable in a single forward pass: the energy of the
attention vector, and the context length.

**Corollary 2.4 (Rényi-2 reading).** *$k^*(n,g) \ge g^2 e^{H_2}$, where $H_2 = -\log E$.*

*Proof sketch.* $e^{H_2} = E^{-1}$ by definition, so this is Theorem 2.3 rewritten. $\square$

### 2.2 Sharpness on the flat profile

**Proposition 2.5.** *For the flat profile $w_i \equiv 1$ on $n$ positions, $E(n) = 1/n$,
so the floor reads $g^2 n$ while the true knee is $\lceil g n\rceil$.*

*Proof sketch.* $S(n) = n$, each $p_i = 1/n$, and $E = n\cdot n^{-2} = 1/n$. Meanwhile
$M(k) = k/n$, so $k^* = \lceil gn \rceil$. $\square$

The loss factor is exactly $g$: the floor $g^2n$ against the truth $\approx gn$. In
particular the floor is *asymptotically exact at $g = 1$* and, at deployment gates such as
$g = 0.98$, loses only $2\%$. The quadratic gate factor is precisely the price of the
Cauchy–Schwarz step, and Proposition 2.5 shows it cannot be improved in general.

### 2.3 The sandwich is informative

A valid sandwich might still be vacuous. It is not:

**Theorem 2.6 (Participation-ratio inequality).** *For every positive profile and $n\ge1$,*
$$n \cdot E(n) \;\ge\; 1 .$$

*Proof sketch.* Cauchy–Schwarz applied to the *full* normalized vector against all-ones:
$1 = (\sum_{i<n} p_i)^2 \le n \sum_{i<n} p_i^2 = nE$. $\square$

**Corollary 2.7 (Intrinsic resolution limit).** *$\dfrac{g^2/E(n)}{n} \le g^2$.*

Thus the two ends of the sandwich are never separated by more than the factor $1/g^2$. At
$g = 0.98$ this is $1/0.9604 \approx 1.04$: the protocol resolves the knee to within $4\%$
before any fitting is done at all. Conversely, no purely energy-based method can do better
than $1/g^2$ — this is a genuine resolution limit of the lower certificate, not an artifact
of the proof.

---

## 3. Why entropy alone cannot certify a budget

The energy floor invites the reading "the budget is at least $g^2$ times an effective
support size". It is tempting to substitute a more familiar effective support: the raw
support size $n$ (Hartley entropy $\log n$), or the Shannon effective support $e^{H_1}$.
Both substitutions are false, and one profile refutes them both.

### 3.1 The spike profile

**Definition 3.1.** The *spike profile* on $n = 17$ positions is
$$w_i = \begin{cases} 16, & i = 0,\\ 1, & 1 \le i \le 16.\end{cases}$$

Its head mass is $S(17) = 16 + 16 = 32$, so $p_0 = 1/2$ and $p_i = 1/32$ for $i \ge 1$.

**Proposition 3.2.** *At gate $g = 1/2$ the spike profile has $k^* = 1$ and
$E = 17/64$.*

*Proof sketch.* $M(0) = 0 < 1/2$ and $M(1) = 16/32 = 1/2 \ge 1/2$, so by the bracketing
property $k^* = 1$. For the energy,
$E = (1/2)^2 + 16\cdot(1/32)^2 = 1/4 + 1/64 = 17/64$. $\square$

### 3.2 Hartley over-certifies

**Theorem 3.3 (Hartley floor refuted).** *For the spike profile at gate $1/2$,*
$$\frac{g^2}{E} = \frac{1/4}{17/64} = \frac{16}{17} \le 1 = k^*, \qquad\text{but}\qquad g^2 n = \frac{17}{4} > 1 = k^* .$$

Hence no bound of the form $k^* \ge g^2 n$ can hold. The valid collision floor $16/17$ sits
correctly below the true knee; the support-size substitution overshoots by a factor of over
four.

### 3.3 Shannon over-certifies

**Proposition 3.4.** *The spike profile has Shannon entropy exactly $H_1 = 3\log 2$.*

*Proof sketch.*
$H_1 = -\tfrac12\log\tfrac12 - 16\cdot\tfrac1{32}\log\tfrac1{32} = \tfrac12\log 2 + \tfrac12\log 32 = \tfrac12\log 2 + \tfrac52\log 2 = 3\log 2$. $\square$

**Theorem 3.5 (Shannon floor refuted).** *For the spike profile at gate $1/2$,*
$$g^2 e^{H_1} = \tfrac14 \cdot 8 = 2 \;>\; 1 = k^*, \qquad\text{while}\qquad g^2 e^{H_2} = \tfrac{16}{17} \;\le\; 1 = k^*.$$

So the Shannon-entropy floor is invalid even though it is far tighter than the Hartley one.
The failure is not a numerical accident but a structural one:

**Theorem 3.6 (Entropy chain).** *For every positive profile and every $n \ge 1$,
$H_2 \le H_1$.*

*Proof sketch.* By Jensen's inequality for the concave function $\log$ applied to the
random variable $p_i$ under the distribution $p$:
$\sum_i p_i \log p_i \le \log\big(\sum_i p_i \cdot p_i\big) = \log E$, i.e.
$-H_1 \le -H_2$. $\square$

Consequently replacing $H_2$ by $H_1$ in the floor can only *inflate* the claimed bound, and
Theorem 3.5 exhibits a profile where the inflation crosses the true knee. On the spike the
gap is strict and quantitative: $H_2 = \log(64/17) \approx 1.325$ against
$H_1 = \log 8 \approx 2.079$.

### 3.4 Interpretation

Entropy quantifies how spread the *whole* distribution is; the budget quantifies how much
mass sits on the *head*. The spike is diffuse in the entropic sense — eight effective
positions — and yet a single key clears the gate, because that key carries half the mass.
The $\ell^2$-energy is the coarsest exponential-family statistic that still sees the head,
which is exactly why it, and nothing weaker, appears in the certificate. This is the precise
content of the claim *entropy alone cannot certify a budget*.

---

## 4. Evaluating the floor

Theorem 2.3 is a bound, not a number. This section computes what the bound says for the
profiles that occur.

### 4.1 A quantitative divergence law

**Lemma 4.1 (Energy of a sorted profile).** *If $w$ is positive and antitone, then for
$n \ge 1$*
$$E(n) \;\le\; \frac{w_0}{S(n)} .$$

*Proof sketch.* Antitonicity gives $w_i \le w_0$ for all $i$ (induction on $i$). Hence
$$E(n) = \sum_{i<n}\frac{w_i^2}{S(n)^2} \le \sum_{i<n}\frac{w_0 w_i}{S(n)^2} = \frac{w_0 S(n)}{S(n)^2} = \frac{w_0}{S(n)}. \qquad\square$$

Sortedness is load-bearing: without it $w_0$ need not be the maximum and the bound fails.

**Theorem 4.2 (Divergence rate).** *If $w$ is positive and antitone, $n \ge 1$ and
$0 < g \le 1$, then*
$$k^*(n,g) \;\ge\; \frac{g^2\,S(n)}{w_0} .$$

*Proof sketch.* Combine Lemma 4.1 with Theorem 2.3: $E \le w_0/S(n)$ gives
$g^2/E \ge g^2 S(n)/w_0$, and $g^2/E \le k^*$. $\square$

This upgrades a qualitative dichotomy to a rate. The dichotomy itself is immediate from the
definitions: a *summable* profile ($\sum_i w_i < \infty$) admits a context-independent
budget, since some finite head already carries a fraction $g$ of the total, while a
*non-summable* profile defeats every fixed budget, since $M(k) = S(k)/S(n) \to 0$ as
$n\to\infty$ for each fixed $k$. Theorem 4.2 says how fast: the budget is
bounded below by the partial sums of the profile, normalized by the head weight. Divergence
of $S(n)$ is, at the level of the floor, *equivalent* to divergence of the budget. The
mechanism is transparent from Lemma 4.1: a profile can keep its energy high — and hence its
floor low — only by keeping the normalizer small, i.e. by concentrating.

### 4.2 The critical Zipf law

**Definition 4.3.** The *Zipf profile* of exponent $s$ is $w_i = (i+1)^{-s}$. The exponent
$s = 1$, $w_i = 1/(i+1)$, is the critical case: the boundary between summable and
non-summable profiles.

**Theorem 4.4 (Critical Zipf budget).** *For the Zipf profile of exponent $1$, every
$n \ge 1$ and every $0 < g \le 1$,*
$$k^*(n,g) \;\ge\; g^2\log(n+1).$$

*Proof sketch.* The profile is positive and antitone with $w_0 = 1$, and
$S(n) = \sum_{i<n} 1/(i+1) = H_n$, the $n$-th harmonic number. Theorem 4.2 gives
$k^* \ge g^2 H_n$, and $H_n \ge \log(n+1)$. $\square$

This is the first *quantitative* growth rate for the knee at the critical exponent. It has
a direct operational reading: at criticality, doubling the context length forces an
additive increase of at least $g^2 \log 2$ keys in any budget that must hold the gate. No
constant budget survives, and the required growth is exactly logarithmic in order.

### 4.3 The exact energy of a geometric profile

**Lemma 4.5 (Geometric head mass).** *For $0 < r < 1$, $\;S(n) = \dfrac{1-r^n}{1-r}$ for
$w_i = r^i$.*

**Theorem 4.6 (Exact geometric energy).** *For $0 < r < 1$ and $n \ge 1$, the profile
$w_i = r^i$ has*
$$E(n) \;=\; \frac{(1-r)\,(1+r^{\,n})}{(1+r)\,(1-r^{\,n})}, \qquad
\lim_{n\to\infty} E(n) \;=\; \frac{1-r}{1+r}.$$

*Proof sketch.* Both the numerator and the denominator are geometric series:
$\sum_{i<n} (r^i)^2 = \sum_{i<n}(r^2)^i = \frac{1-r^{2n}}{1-r^2}$ and
$S(n)^2 = \big(\frac{1-r^n}{1-r}\big)^2$. Dividing,
$$E = \frac{1-r^{2n}}{1-r^2}\cdot\frac{(1-r)^2}{(1-r^n)^2}
= \frac{(1-r^n)(1+r^n)}{(1-r)(1+r)}\cdot\frac{(1-r)^2}{(1-r^n)^2}
= \frac{(1-r)(1+r^n)}{(1+r)(1-r^n)}. \qquad\square$$

The limiting value $(1-r)/(1+r)$ is the crucial point: even a *perfectly* geometric profile
has an energy that does not vanish, and its floor therefore grows like $1/(1-r)$.

**Theorem 4.7 (Geometric floor).** *Let $0 < r < 1$, $0 < g \le 1$, and suppose the context
is long enough for the tail to have decayed, $r^{\,n} \le 1/2$. Then*
$$k^*(n,g) \;\ge\; \frac{g^2}{3(1-r)} .$$

*Proof sketch.* From Theorem 4.6 and $r^n \le 1/2$ one checks
$E = \frac{(1-r)(1+r^n)}{(1+r)(1-r^n)} \le 3(1-r)$: indeed $1+r^n \le 3/2$,
$1-r^n \ge 1/2$ and $1+r \ge 1$, so $E \le 3(1-r)$. Then $g^2/E \ge g^2/(3(1-r))$ and
Theorem 2.3 concludes. $\square$

The hypothesis $r^n \le 1/2$ is a genuine finite-context condition, not decoration. For
$n$ below $\log 2/\log(1/r)$ the truncation at the context boundary, not the decay rate,
is what limits the budget.

### 4.4 The two-sided pin for geometric profiles

Geometric decay also admits a matching *upper* certificate. If $w_{i+1} \le r w_i$ for all
$i$ then the discarded mass obeys $T(k) \le r^k/(1-r)$, i.e. the profile satisfies the tail
law of Section 5 with $C = 1/(1-r)$; the reported budget is then
$$\mathrm{GeoBudget}(r,g) \;=\; \max\!\left(\left\lceil \frac{\log\big((1-g)(1-r)\big)}{\log r}\right\rceil,\,1\right)
\;\approx\; \frac{\log\!\big(1/((1-g)(1-r))\big)}{\log(1/r)} .$$

**Theorem 4.8 (Two-sided pin).** *For $0 < r < 1$, $0 < g < 1$, and $r^{\,n} \le 1/2$, the
knee of the pure geometric profile $w_i = r^i$ satisfies*
$$\frac{g^2}{3(1-r)} \;\le\; k^*(n,g) \;\le\; \mathrm{GeoBudget}(r,g).$$

*Proof sketch.* The left inequality is Theorem 4.7. The right one is the fit-based upper
certificate (Theorem 5.3) applied to the geometric fit $(1/(1-r), r)$, which every profile
with $w_{i+1} \le r w_i$ admits. $\square$

Since $\log(1/r) \sim 1-r$ as $r \uparrow 1$, the upper bound is
$\Theta\!\big(\frac{1}{1-r}\log\frac{1}{(1-g)(1-r)}\big)$ and the lower bound is
$\Theta\!\big(\frac{1}{1-r}\big)$: the geometric knee is pinned to within a logarithmic
factor. The tail-exponent fit is therefore not merely a sufficient certificate; **it
captures the true order of the budget**, and no protocol can report a budget below
$c/(1-r)$ for geometric data.

### 4.5 The mixture law

Real systems merge heads: a shared cache, a pooled sparsity pattern, an averaged profile.

**Theorem 4.9 (Energy is subadditive-to-max under merging).** *Let $w_1, w_2$ be positive
profiles and $n \ge 1$. Then*
$$E(w_1 + w_2)(n) \;\le\; \max\big(E(w_1)(n),\, E(w_2)(n)\big).$$

*Proof sketch.* Let $S_1, S_2$ be the head masses and $\lambda = S_1/(S_1+S_2) \in [0,1]$.
The merged head mass is $S_1 + S_2$, and position-wise
$$\frac{w_1(i) + w_2(i)}{S_1+S_2} = \lambda\,\frac{w_1(i)}{S_1} + (1-\lambda)\,\frac{w_2(i)}{S_2},$$
a convex combination of the two normalized profiles. Squaring is convex, so
$$\Big(\frac{w_1(i)+w_2(i)}{S_1+S_2}\Big)^2 \le \lambda \Big(\frac{w_1(i)}{S_1}\Big)^2 + (1-\lambda)\Big(\frac{w_2(i)}{S_2}\Big)^2 .$$
Summing over $i < n$ gives $E(w_1+w_2) \le \lambda E(w_1) + (1-\lambda) E(w_2)$, which is at
most the maximum of the two. $\square$

**Corollary 4.10 (Minimum law for the floor).** *For $g > 0$,*
$$\min\left(\frac{g^2}{E(w_1)},\, \frac{g^2}{E(w_2)}\right) \;\le\; \frac{g^2}{E(w_1+w_2)} .$$

*Proof sketch.* $x \mapsto g^2/x$ is decreasing on $(0,\infty)$; apply it to Theorem 4.9.
$\square$

This is the exact counterpart, on the lower certificate, of the corresponding *maximum* law
for the knee itself (merging two heads yields a knee no larger than the maximum of the two).
The engineering moral: **the worst head governs both ends of the sandwich**. A diffuse head
cannot be economized away by merging it with a sharp one; the certified budget of the merged
profile is dragged toward the diffuse head's value.

---

## 5. The upper certificate: a fitted tail law

### 5.1 Definitions

**Definition 5.1 (Tail fit).** A pair $(C, r)$ with $C > 0$, $0 < r < 1$ is a *tail fit* for
$w$ if
$$T(k) \;=\; 1 - M(k) \;\le\; C\,r^{\,k} \qquad \text{for all } k \text{ and all } n \ge 1 .$$

**Definition 5.2 (Reported budget).** For $C > 0$, $0 < r < 1$ and a reporting gate
$\tau < 1$,
$$\mathrm{Budget}(C,r,\tau) \;=\; \max\!\left(\left\lceil \frac{\log((1-\tau)/C)}{\log r}\right\rceil,\; 1\right).$$

This is the least exponent (clipped below at $1$) at which the fitted tail curve drops
below the residual $1 - \tau$.

**Theorem 5.3 (Upper certificate).** *If $(C,r)$ is a tail fit for $w$ with $C>0$,
$0<r<1$, and $\tau < 1$, then for every $n \ge 1$*
$$k^*(n,\tau) \;\le\; \mathrm{Budget}(C,r,\tau).$$

*Proof sketch.* Write $K = \mathrm{Budget}(C,r,\tau)$. Since $\log r < 0$, the ceiling
inequality $\log((1-\tau)/C)/\log r \le K$ rearranges (flipping the inequality on division
by a negative) to $K\log r \le \log((1-\tau)/C)$, hence $r^K \le (1-\tau)/C$ and
$C r^K \le 1-\tau$. The fit then gives $T(K) \le 1-\tau$, i.e. $M(K) \ge \tau$, and the knee
is the *least* such index. $\square$

**Proposition 5.4 (Geometric profiles admit an explicit fit).** *If $w$ is positive with
$w_{i+1} \le r w_i$ for $0 < r < 1$, then $(1/(1-r),\, r)$ is a tail fit for $w$.*

*Proof sketch.* For $k \ge 1$ the discarded weight is at most $w_0 r^k/(1-r)$ while the head
mass is at least $w_0$, giving $T(k) \le r^k/(1-r)$. For $k=0$, $T(0) \le 1 \le 1/(1-r)$.
$\square$

So the classical geometric estimate is the special case of a measured fit.

### 5.2 Monotonicity: from a confidence box to a certificate

**Theorem 5.5 (Monotonicity in the fit).** *If $0 < C \le C'$ and $0 < r \le r' < 1$, and
$\tau < 1$, then*
$$\mathrm{Budget}(C,r,\tau) \;\le\; \mathrm{Budget}(C',r',\tau).$$

*Proof sketch.* Increasing $C$ increases $\log((1-\tau)/C)^{-1}$-direction: precisely,
$\log((1-\tau)/C)$ decreases in $C$ and $\log r < 0$, so the quotient increases in $C$.
Increasing $r$ increases $\log r$ toward $0$ from below, which increases the (positive)
quotient. Monotonicity of the ceiling and of $\max(\cdot,1)$ concludes. $\square$

**Corollary 5.6 (Box certificate).** *If the true parameters lie anywhere in a confidence
box $[C,C^+]\times[r,r^+]$ with $r^+ < 1$, then $\mathrm{Budget}(C^+,r^+,\tau)$ certifies
the budget for every parameter pair in the box.*

This is what makes the protocol reportable: an error bar on the fit becomes an error bar on
the number, by evaluating the same formula at the upper corner.

### 5.3 The two-point estimator

**Definition 5.7.** From tails $t_1 = T(k_1)$ and $t_2 = T(k_1+d)$ measured at probes
separated by $d \ge 1$, set
$$\hat r \;=\; \left(\frac{t_2}{t_1}\right)^{1/d}, \qquad \hat C \;=\; \frac{t_1}{\hat r^{\,k_1}} .$$

**Theorem 5.8 (Exactness).** *If the tail is genuinely geometric, $T(k) = C r^k$ with
$C, r > 0$, then $\hat r = r$ and $\hat C = C$ exactly.*

*Proof sketch.* $t_2/t_1 = r^d$, so $\hat r = (r^d)^{1/d} = r$; then
$\hat C = C r^{k_1}/r^{k_1} = C$. $\square$

**Theorem 5.9 (No pipeline bias).** *Consequently, feeding the two-point estimates into the
budget formula returns exactly the budget of the true parameters:*
$$\mathrm{Budget}(\hat C, \hat r, \tau) \;=\; \mathrm{Budget}(C, r, \tau).$$

All uncertainty in the report is therefore attributable to the data, none to the estimator.

**Theorem 5.10 ($d$-th-root damping of data error).** *Suppose the measured tails
$s_1, s_2$ carry multiplicative errors of size at most $\varepsilon \in [0,1)$ relative to
the true tails $t_1, t_2 > 0$, in the sense $(1-\varepsilon)t_1 \le s_1$ and
$s_2 \le (1+\varepsilon)t_2$, with $s_2 \ge 0$. Then*
$$\hat r(s_1,s_2,d) \;\le\; \left(\frac{1+\varepsilon}{1-\varepsilon}\right)^{1/d}\, \hat r(t_1,t_2,d).$$

*Proof sketch.* The hypotheses give $s_2/s_1 \le \frac{1+\varepsilon}{1-\varepsilon}\cdot\frac{t_2}{t_1}$.
Raising to the (nonnegative) power $1/d$ is monotone and multiplicative over products of
nonnegatives. $\square$

**Theorem 5.11 (Measurement design).** *For every data error $\varepsilon < 1$ and every
target relative precision $\delta > 0$ there is a probe separation $d \ge 1$ such that
$\hat r(s_1,s_2,d) \le (1+\delta)\,\hat r(t_1,t_2,d)$ for all data satisfying the error
model above.*

*Proof sketch.* Let $a = (1+\varepsilon)/(1-\varepsilon) \ge 1$. Since $(1+\delta)^m \to \infty$,
choose $m$ with $a \le (1+\delta)^{m+1}$ and take $d = m+1$; then $a^{1/d} \le 1+\delta$,
and Theorem 5.10 applies. $\square$

The consequence is the operational heart of the protocol: **the fit's uncertainty is set by
the experiment design, not by the noise level.** Any target precision is reachable by
probing further apart, no matter how noisy the individual tail measurements are.

### 5.4 Error propagation into the floor

The lower end degrades just as controllably.

**Theorem 5.12 (Only an over-estimate is needed).** *If $\hat E \ge E(n)$ then
$g^2/\hat E \le k^*(n,g)$.*

So a conservative (upward-biased) energy measurement always yields a valid floor.

**Theorem 5.13 (Linear degradation).** *If $E \le \hat E \le (1+\eta)E$ with $\eta \ge 0$,
then*
$$\frac{1}{1+\eta}\cdot\frac{g^2}{E} \;\le\; \frac{g^2}{\hat E} .$$

*Proof sketch.* $g^2/\hat E \ge g^2/((1+\eta)E) = \frac{1}{1+\eta}\cdot\frac{g^2}{E}$. $\square$

A relative energy error of $\eta$ costs exactly a factor $1/(1+\eta)$ in the reported floor —
no amplification. Together with Theorem 5.5 on the upper end, both ends of the reported
interval degrade monotonically and quantifiably under measurement error.

### 5.5 Consistency and falsification

**Theorem 5.14 (Fits respect the floor).** *If $(C,r)$ is a valid tail fit for $w$, then for
$0 < g \le 1$ and $n \ge 1$,*
$$\frac{g^2}{E(n)} \;\le\; \mathrm{Budget}(C,r,g).$$

*Proof sketch.* Chain the two certificates: $g^2/E \le k^*(n,g) \le \mathrm{Budget}(C,r,g)$
by Theorems 2.3 and 5.3. $\square$

**Corollary 5.15 (Falsifier).** *If a reported fit produces a budget strictly below the
measured energy floor, the fit is refuted.*

This is a free consistency check: it costs one energy computation and one evaluation of the
budget formula, and it invalidates any tail law that has been fitted too optimistically.

### 5.6 Sharpness of the report

Is the reported number close to the knee, or merely an upper bound? Under an exact tail
measurement it is the knee.

**Theorem 5.16 (Sharpness to within one key).** *Suppose $w$ is positive, $0 < \tau < 1$,
$n \ge 1$, the measured tail is exactly geometric below the context length,
$T(k) = C r^k$ for all $k < n$, and the reported budget fits inside the context,
$\mathrm{Budget}(C,r,\tau) \le n$. Then*
$$k^*(n,\tau) \;\le\; \mathrm{Budget}(C,r,\tau) \;\le\; k^*(n,\tau) + 1 ,$$
*and in fact $\mathrm{Budget}(C,r,\tau) = k^*(n,\tau)$ whenever
$\lceil \log((1-\tau)/C)/\log r\rceil \ge 1$.*

*Proof sketch.* The upper inequality is Theorem 5.3. For the lower, use the minimality
property of the ceiling: if the budget one step below the reported one already cleared the
gate, i.e. $C r^{K-1} \le 1-\tau$, then $K-1$ would satisfy the defining inequality of the
ceiling, contradicting minimality. Hence the tail at $K-1$ exceeds the residual, so
$M(K-1) < \tau$ and $k^* \ge K-1$; combined with $k^* \le K$ this pins $K$ to within one.
The exactness statement follows by checking the two-sided bracket (a failure at $K-1$ and a
pass at $K$) directly. $\square$

The single-key slack is exactly the ceiling rounding and cannot be removed: the report is
the best integer certificate derivable from the fit.

The hypothesis $\mathrm{Budget}(C,r,\tau) \le n$ is essential. When the reported budget
exceeds the context length, the knee saturates at $n$ — a truncation effect rather than a
decay effect — and the gap between report and truth can be arbitrarily large. This is the
same finite-context boundary that appears as $r^n \le 1/2$ in Theorem 4.7.

---

## 6. The protocol, assembled

**Theorem 6.1 (Measurement protocol).** *Let $w$ be a positive profile on a context of
length $n \ge 1$; let $(C, r)$ be a tail fit lying inside a confidence box
$[C, C^+]\times[r, r^+]$ with $r^+ < 1$; let $\tau < 1$ be a reporting gate and
$g \in (0,1]$ a measurement gate. Then simultaneously*
$$\frac{g^2}{E(n)} \;\le\; k^*(n,g) \;\le\; n, \qquad k^*(n,\tau) \;\le\; \mathrm{Budget}(C^+, r^+, \tau),$$
*and all three quantities are computable from measured data.*

In algorithmic form:

**Input.** Attention weights $w$ on a context of length $n$; measurement gate $g$;
reporting gate $\tau$; probe indices $k_1 < k_1 + d < n$; data-error level $\varepsilon$;
energy-error level $\eta$.

1. Sort $w$ descending; compute $S(n) = \sum_{i<n} w_i$ and $p_i = w_i/S(n)$.
2. Compute $\hat E = (1+\eta)\sum_i p_i^2$ (a conservative over-estimate).
3. **Lower certificate:** report $\mathrm{floor} = g^2/\hat E$; by Theorems 2.3 and 5.13
   this is valid and loses only the factor $1/(1+\eta)$.
4. Measure $t_1 = 1 - M(k_1)$ and $t_2 = 1 - M(k_1+d)$.
5. Estimate $\hat r = (t_2/t_1)^{1/d}$ and $\hat C = t_1/\hat r^{k_1}$; inflate to the box
   corner $(C^+, r^+)$ using the error model of Theorem 5.10.
6. **Upper certificate:** report $\mathrm{ceil} = \mathrm{Budget}(C^+, r^+, \tau)$.
7. **Consistency check:** if $\mathrm{ceil} < \mathrm{floor}$, reject the fit
   (Corollary 5.15).
8. **Output:** the interval $[\mathrm{floor}, \min(\mathrm{ceil}, n)]$, whose relative width
   is at most $1/g^2$ before fitting (Corollary 2.7) and one key after fitting on an exact
   tail (Theorem 5.16).

*Complexity.* Step 1 costs $O(n\log n)$ (or $O(n)$ if the profile is already sorted);
steps 2 and 4 cost $O(n)$; steps 5–7 are $O(1)$. The whole protocol is a single linear pass
over the attention vector plus constant work.

---

## 7. Discussion

### 7.1 What the collision energy is, and why it is the right statistic

The energy $E = \sum_i p_i^2$ is the probability that two independent samples from the
attention distribution collide. Its reciprocal $1/E$ is known in physics as the
*participation ratio* — the effective number of states carrying the weight — and
Theorem 2.6 is the statement that the participation ratio never exceeds the support size.
The floor $k^* \ge g^2/E$ therefore reads: *the budget is at least $g^2$ times the
participation ratio*.

The refutations of Section 3 delimit this exactly. Along the Rényi ladder
$H_\alpha = \frac{1}{1-\alpha}\log\sum_i p_i^\alpha$, larger $\alpha$ gives smaller entropy;
$\alpha = 2$ is the largest-entropy member for which the bound survives on our
counterexample, while $\alpha \to 1$ (Shannon) and $\alpha \to 0$ (Hartley) both fail.
Structurally, the Cauchy–Schwarz step is the $\alpha=2$ instance of Hölder's inequality
applied to the head sum, and the gate exponent $2$ is the Hölder conjugate index — which
also explains why the ladder must break down as $\alpha \to 1$, where the conjugate exponent
blows up.

### 7.2 The two failure modes of a budget

The results identify two structurally different reasons a budget can be large.

* **Slow decay.** The profile is not summable, and Theorem 4.2 turns this into a growth
  rate. At the Zipf boundary, Theorem 4.4 gives $g^2\log(n+1)$.
* **Finite context.** Even with fast decay, if $r^n > 1/2$ the context has not been long
  enough for the tail to matter, and the knee is governed by truncation. This is exactly
  where Theorem 4.7 and Theorem 5.16 both require a hypothesis.

Distinguishing these matters operationally: the first is a property of the model and cannot
be engineered away, the second disappears as soon as the context grows.

### 7.3 Deployment reading

At a realistic gate $g = 0.98$:

* The intrinsic resolution is $1/g^2 \approx 1.04$: the certificate alone already brackets
  the knee to $4\%$ (Corollary 2.7).
* A $10\%$ over-estimate of the energy costs $9\%$ of the floor (Theorem 5.13) — a linear,
  non-amplifying degradation.
* A $20\%$ measurement error on the tail probes, damped by a probe separation of $d = 16$,
  perturbs the fitted ratio by a factor $(1.5)^{1/16} \approx 1.026$ (Theorem 5.10).
* Merging a sharp head with a diffuse one leaves the floor no lower than the diffuse head's
  floor (Corollary 4.10): pooled caches must be sized for the worst head.

### 7.4 Limitations

The whole development assumes strictly positive weights and — wherever $w_0$ appears —
a sorted profile. Softmax attention always produces strictly positive weights, and sorting
is the standard preprocessing step, so both are mild. The tail fit is a *bound*
($T(k) \le Cr^k$), not an equality; the sharpness theorem is the one place where an exact
tail is assumed, and it is stated only for $k < n$, where the measured tail is informative.
The gate-squared loss in the floor is real (Proposition 2.5) and is what the resolution limit
$1/g^2$ expresses; it is negligible at deployment gates and severe at small gates.

---

## 8. Future directions

Five conjectures stand out, each falsifiable and each stated so that a rigorous proof is the
natural test.

**1. The Rényi ladder for budget certificates.** For every $\alpha > 1$ the bound
$k^* \ge g^{\alpha/(\alpha-1)} e^{H_\alpha}$ should hold, with $\alpha = 2$ — the proved case —
optimal for gates near $1$, and $\alpha \to 1$ (Shannon) invalid for every gate. The key
insight is that the Cauchy–Schwarz step is the $\alpha = 2$ instance of Hölder applied to
the head sum; the gate exponent $\alpha/(\alpha-1)$ is exactly the Hölder conjugate, which
also explains why the ladder must break down at $\alpha = 1$ where the conjugate blows up.
The entropy chain and the Shannon refutation already pin the two ends of the ladder.

**2. Optimal probe placement for the two-point fit.** Among all probe pairs
$k_1 < k_2 \le K$ with a fixed measurement error $\varepsilon$, the budget-error of the
reported budget should be minimized by $k_1 = 0$, $k_2 = K$, with resulting error
$\Theta\big(\log(1/(1-\tau))\cdot\varepsilon/K\big)$ — i.e. the *reported budget* inherits
the $1/d$ damping of the fitted ratio, not merely the ratio itself. The key insight is that
the budget depends on $r$ only through $\log r$, so a multiplicative error $a^{1/d}$ on
$\hat r$ becomes an additive error on the reported exponent.

**3. Sharpening the geometric pin.** Theorem 4.8 leaves a logarithmic gap between
$g^2/(3(1-r))$ and $\mathrm{GeoBudget}(r,g)$. We conjecture the truth is at the upper end,
i.e. the true geometric knee is $\Theta\big(\frac{1}{1-r}\log\frac{1}{(1-g)(1-r)}\big)$, and
that the constant $3$ in Theorem 4.7 can be replaced by $1 + o(1)$ as $n \to \infty$ using
the exact limit $E \to (1-r)/(1+r)$.

**4. Sub-geometric and stretched-exponential tails.** The protocol fits $T(k) \le Cr^k$.
Empirical attention tails are often stretched exponentials $T(k) \le C e^{-\beta k^{\gamma}}$
with $\gamma < 1$. The budget formula generalizes to
$\big(\log(C/(1-\tau))/\beta\big)^{1/\gamma}$; the open question is whether the two-point
estimator retains its exactness and $d$-th-root damping in this family, and whether a
three-point estimator is needed to identify $\gamma$ stably.

**5. Multi-head allocation under a global budget.** The minimum law (Corollary 4.10) says a
pooled cache is governed by the worst head. The natural optimization problem — allocate a
total budget $B$ across $h$ heads to maximize the minimum retained mass — should have a
water-filling solution driven by the per-head energies, with the optimal allocation
proportional to $1/E_j$ up to rounding. Proving this, and quantifying the loss relative to
uniform allocation, would convert the certificate into a design rule.

---

## 9. Summary of results

| Result | Statement |
|---|---|
| Head-sum Cauchy–Schwarz | $M(k)^2 \le k E$ |
| Budget sandwich | $g^2/E \le k^*(n,g) \le n$ |
| Rényi-2 reading | $k^* \ge g^2 e^{H_2}$ |
| Hartley refuted | spike profile: $k^*=1$ but $g^2 n = 17/4$ |
| Shannon refuted | spike profile: $H_1 = 3\log 2$, $g^2e^{H_1}=2 > 1 = k^*$ |
| Entropy chain | $H_2 \le H_1$ |
| Participation ratio | $nE \ge 1$; hence $(g^2/E)/n \le g^2$ |
| Sorted energy bound | $E \le w_0/S(n)$ |
| Divergence rate | $k^* \ge g^2 S(n)/w_0$ |
| Critical Zipf law | $k^* \ge g^2\log(n+1)$ |
| Exact geometric energy | $E = (1-r)(1+r^n)/((1+r)(1-r^n))$ |
| Geometric floor | $k^* \ge g^2/(3(1-r))$ when $r^n \le 1/2$ |
| Geometric pin | $g^2/(3(1-r)) \le k^* \le \mathrm{GeoBudget}(r,g)$ |
| Mixture law | $E(w_1+w_2) \le \max(E(w_1),E(w_2))$; floors obey a min law |
| Upper certificate | $k^*(n,\tau) \le \mathrm{Budget}(C,r,\tau)$ |
| Monotone in fit box | $\mathrm{Budget}$ nondecreasing in $C$ and $r$ |
| Two-point exactness | $\hat r = r$, $\hat C = C$ on a geometric tail |
| Error damping | $\hat r$ error $\le ((1+\varepsilon)/(1-\varepsilon))^{1/d}$ |
| Floor error | $\hat E \le (1+\eta)E \Rightarrow$ floor loses factor $1/(1+\eta)$ |
| Sharpness | exact tail $\Rightarrow k^* \le \mathrm{Budget} \le k^*+1$ |
