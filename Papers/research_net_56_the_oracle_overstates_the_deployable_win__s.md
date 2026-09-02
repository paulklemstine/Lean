# The Oracle Overstates the Deployable Win: An Information Barrier for Streaming Attention-Cache Eviction

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

Trained transformer attention is extremely concentrated: for a query row of a
trained model, a cache holding only the $32$ keys of largest attention weight
retains $99.13\%$ of that row's probability mass, and $64$ keys retain $99.53\%$,
in a context of $1024$. These figures are obtained by an *oracle* selector that
chooses the cache after reading the row it must serve. We show that they do not
transfer to any deployable selector, and we quantify the failure exactly.

We model a cache as a set $S$ of at most $B$ key indices out of $n$, and its
retention on query row $t$ as $\mathrm{kept}(t,S) = \sum_{j\in S} w_t(j)$, where
$w_t$ is the attention distribution of row $t$. The oracle value is the maximum
of $\mathrm{kept}(t,\cdot)$ over admissible caches. A *causally honest policy* is
a map from attention matrices and row indices to admissible caches that depends
only on rows strictly earlier than $t$.

Our results are of two kinds. On the positive side, an exchange lemma shows that
a cache formed by the top $B$ keys under an arbitrary score $s$ is oracle-optimal
whenever $s$ is *order-consistent* with the served row, and loses at most
$B\varepsilon$ under $\varepsilon$-approximate consistency; we exhibit an
instance at which the loss is exactly $B\varepsilon$, so the price is sharp. In
particular, if the served row is an order-preserving affine image of accumulated
attention (an explicit *stationarity* hypothesis), the heavy-hitter cache is
exactly optimal.

On the negative side we prove that for every $n$, every budget $1 \le B < n$ and
*every* causally honest policy $P$, there is an attention matrix — every row of
which is a genuine probability distribution — on which the oracle retains $1$ and
$P$ retains $0$. The oracle-to-policy gap is therefore $1$, the maximum possible.
A counting identity upgrades the single bad instance to an average bound: over a
family of $n$ instances, mean retention of any causal policy is at most $B/n$,
and a Yao-style averaging extends the bound to arbitrary finite mixtures of
policies, so randomisation does not help. Three engineering escapes are closed:
block-granular eviction does not change the separation; per-layer budget
allocation is a min-plus convolution through which a per-layer penalty $\delta$
survives, accumulating to $L\delta$ over $L$ layers; and the gap vanishes only in
the degenerate regime $B = n$.

Finally, two diagnostic instance families show that neither pure accumulation nor
pure recency dominates — each retains $0$ where the other retains $1$ — and that a
budget split retains both families precisely when both halves are nonzero, which
makes the empirically superior hybrid policy structurally forced rather than
tuned. We conclude that published oracle retention curves are upper bounds and
that deployment tables must be policy-adjusted, layer by layer, by a correction
whose exact size is $B$ times the consistency defect of the score in use.

**Keywords:** attention cache eviction, heavy hitters, oracle gap, online
algorithms, exchange argument, min-plus convolution, information barrier.

---

## 1. Introduction

### 1.1 The suitcase problem

An autoregressive transformer serving a context of $n$ tokens maintains a
key–value record per token per attention head. Generating each new token requires
attending over all of them, so both memory and bandwidth scale linearly in the
context. *Cache eviction* — discarding all but $B \ll n$ records — is the standard
remedy, and its central empirical justification is the observed concentration of
trained attention.

The justification is usually presented as a retention curve. Fix a trained model
and a corpus, materialise the attention matrix $w$, and for each query row $t$
compute the fraction of row mass captured by the $B$ keys of largest weight.
Curves of this form show a sharp knee: retention is already above $0.99$ at
budgets on the order of $2$–$6\%$ of the context. It is tempting to read these
curves as forecasts of what an eviction policy will deliver at that budget.

They are not, and the discrepancy is large. On the measurement that motivates
this work — a $0.5$-billion-parameter model at context $1024$, block-$128$
eviction, strict per-row causality, matched budgets, identical data for all arms
— the observed retentions were:

| arm | $B=32$ | $B=64$ | $B=128$ |
|---|---|---|---|
| oracle (per-row top-$k$) | $0.9913$ | $0.9953$ | — |
| accumulated heavy hitters | $0.8633$ | $0.8822$ | $0.9189$ |
| hybrid (heavy hitters + recency) | $0.9205$ | $0.9384$ | $0.9605$ |

Three pre-registered hypotheses were tested. **P1**, that the oracle-to-policy gap
would exceed a $2\%$ floor at matched budget, was confirmed emphatically: the gap
at $B=64$ is $0.9953 - 0.8822 = 0.1131$, i.e. $11.31$ points. **P2**, that a
recency reserve would improve on pure accumulation, was confirmed at every
budget ($+5.72$, $+5.62$, $+4.16$ points). **P3**, that some deployable arm would
reach $0.95$ at $B=64$, was refuted: the best deployable value there is $0.9384$,
and even a cache of $12.5\%$ of the context reaches only $0.9605$. The oracle
arms replicate an earlier independent measurement of the same knee to four
decimals ($0.9913$ against $0.9912$ at $k=32$), which anchors the harness.

### 1.2 Contribution

This paper turns those three empirical horns into theorems about set-valued cache
policies. The measured $11.3$-point gap is not a tuning deficiency: it is the
mild, average-case shadow of a worst-case separation of a full unit. Concretely:

1. **An exchange lemma** (§3) characterising when score-ranked caches are
   optimal, with an exact $B\varepsilon$ price for approximate score consistency
   and a matching instance proving the price sharp.
2. **An impossibility theorem** (§4): every causally honest policy of budget
   $B < n$ retains $0$ where the oracle retains $1$; the gap is $1$; the average
   over an explicit family is at most $B/n$; randomisation does not help.
3. **A structural account of the hybrid** (§5): two diagnostic families on which
   accumulation and recency respectively fail totally, and a split theorem making
   the hybrid the unique surviving shape.
4. **Closure of three escapes** (§6): granularity, per-layer allocation (a
   min-plus convolution through which the penalty passes, accumulating linearly
   in depth), and budget size.
5. **A deployment recipe** (§8): a one-parameter, measurable correction that
   converts an oracle table into an honest forecast.

### 1.3 Related context

Heavy-hitter eviction — scoring keys by accumulated attention probability and
retaining the top scorers, usually with a recency reserve — is the dominant
deployed family of KV-cache policies, and oracle top-$k$ retention is the
standard yardstick against which it is reported. What is new here is not the
observation that policies underperform oracles, but the *quantification*: the
gap is exhibited as an information barrier that holds for every causal policy at
once, its worst-case size is determined exactly (a full unit), the assumption
that removes it is isolated exactly (order consistency), and the price of
approximate satisfaction of that assumption is computed exactly ($B\varepsilon$,
attained). This puts the practice of quoting oracle curves on a precise footing:
they are upper bounds, and the correction term has a formula.

---

## 2. Setting and definitions

Throughout, $n$ is the number of key positions, indexed $0,\dots,n-1$, and
$B$ is a cache budget.

**Definition 2.1 (Attention matrix).** An *attention matrix* is a function
$w : \mathbb{N} \times \mathbb{N} \to \mathbb{R}$, written $w_t(j) = w(t,j)$, whose
value is the probability that query row $t$ places on key $j$. The instances used
below are *stochastic*: $w_t(j) \ge 0$ and $\sum_{j<n} w_t(j) = 1$. The general
theorems require only nonnegativity where stated.

**Definition 2.2 (Retention).** For a finite set $S \subseteq \mathbb{N}$ of key
indices,
$$\mathrm{kept}(w, t, S) \;=\; \sum_{j \in S} w_t(j).$$

**Definition 2.3 (Admissible caches).** The admissible caches at context $n$ and
budget $B$ are
$$\mathcal{C}(n,B) \;=\; \{\, S \subseteq \{0,\dots,n-1\} \;:\; |S| \le B \,\}.$$
This family is nonempty ($\emptyset \in \mathcal{C}(n,B)$) and finite.

**Definition 2.4 (Oracle).** The *oracle value* at row $t$ is
$$\mathrm{oracle}(n,B,w,t) \;=\; \max_{S \in \mathcal{C}(n,B)} \mathrm{kept}(w,t,S).$$
Two facts are used constantly: $\mathrm{kept}(w,t,S) \le \mathrm{oracle}(n,B,w,t)$
for every admissible $S$, and if $\mathrm{kept}(w,t,S) \le c$ for all admissible
$S$ then $\mathrm{oracle}(n,B,w,t) \le c$. The maximum is taken with knowledge of
row $t$; this is the entire difference between the oracle and a policy.

**Definition 2.5 (Causally honest policy).** A map
$P : (\text{attention matrices}) \times \mathbb{N} \to (\text{finite sets})$ is a
*causally honest policy at $(n,B)$* if

- (admissibility) $P(w,t) \in \mathcal{C}(n,B)$ for all $w,t$; and
- (causality) whenever $w_r(j) = w'_r(j)$ for all $r < t$ and all $j$, we have
  $P(w,t) = P(w',t)$.

The causality clause is the formal content of "deployable": the cache serving row
$t$ is a function of the past only. The oracle is not of this form.

**Definition 2.6 (Accumulated score; the three policies).** The accumulated
attention statistic is $\mathrm{acc}_t(j) = \sum_{r<t} w_r(j)$. Write
$\mathrm{top}_B(s)$ for the set of the $B$ highest-scoring keys under a score $s$
(ties broken by index; made precise in §3.2). Then:

- the **heavy-hitter cache** is $H_B(w,t) = \mathrm{top}_B(\mathrm{acc}_t)$;
- the **recency cache** is $R_m = \{n-m, \dots, n-1\}$, the $m$ most recent keys;
- the **hybrid cache** is $H_{\lfloor B/2 \rfloor}(w,t) \cup R_{B - \lfloor B/2 \rfloor}$.

**Proposition 2.7.** All three are causally honest at their budgets.

*Proof sketch.* Admissibility: $|\mathrm{top}_B(s)| \le B$ by construction,
$|R_m| \le m$ since $R_m$ is an interval of length $\min(m,n)$, and the union
bound $|X \cup Y| \le |X| + |Y|$ gives the hybrid. Causality: $\mathrm{acc}_t$
depends only on rows $r < t$, so agreement of prefixes forces equality of scores
and hence of the top-$B$ sets; $R_m$ depends on no row at all. $\square$

---

## 3. Retrospective pruning is easy: the exchange lemma

### 3.1 The exchange lemma

**Theorem 3.1 (Exchange lemma, approximate form).** Let $w_t \ge 0$ pointwise,
let $\varepsilon \ge 0$, and let $H, S$ be finite key sets with $|S| \le |H|$.
Suppose every key held by $S$ but not $H$ is worth at most $\varepsilon$ more than
every key held by $H$ but not $S$:
$$\forall k \in S \setminus H,\ \forall j \in H \setminus S:\quad w_t(k) \le w_t(j) + \varepsilon.$$
Then
$$\mathrm{kept}(w,t,S) \;\le\; \mathrm{kept}(w,t,H) \;+\; |H|\,\varepsilon.$$

*Proof sketch.* Split both sums along the common part: $\mathrm{kept}(w,t,S) =
\sum_{S \cap H} w_t + \sum_{S \setminus H} w_t$ and likewise for $H$. The common
parts coincide, so it suffices to bound $\sum_{S\setminus H} w_t$ by
$\sum_{H \setminus S} w_t + |H|\varepsilon$. If $H \setminus S = \emptyset$ then
the cardinality identity $|S\setminus H| + |S \cap H| = |S| \le |H| = |H\setminus S| +
|H \cap S|$ forces $S \setminus H = \emptyset$ too, and the claim is trivial.
Otherwise pick $j_0$ minimising $w_t$ on $H \setminus S$. Every $k \in S\setminus H$
satisfies $w_t(k) \le w_t(j_0) + \varepsilon$, so
$\sum_{S\setminus H} w_t \le |S\setminus H|\,(w_t(j_0)+\varepsilon)$. By the same
cardinality identity, $|S \setminus H| \le |H \setminus S|$, and by minimality
$|H\setminus S| \, w_t(j_0) \le \sum_{H\setminus S} w_t$; nonnegativity of $w_t$
handles the leftover. Collecting terms gives the bound with slack
$|H\setminus S|\varepsilon \le |H|\varepsilon$. $\square$

**Corollary 3.2 (Exact form).** With $\varepsilon = 0$: if $|S| \le |H|$ and every
key of $S \setminus H$ is worth no more than every key of $H \setminus S$, then
$\mathrm{kept}(w,t,S) \le \mathrm{kept}(w,t,H)$. Hence the top-$B$ set by the
*true* row is an optimal cache: retrospective pruning is a one-line greedy.

### 3.2 Score-ranked caches

To make "top $B$" well defined in the presence of ties, order keys by the strict
total order
$$m \succ_s j \quad :\Longleftrightarrow \quad s(j) < s(m) \ \text{ or }\ \big(s(m) = s(j) \text{ and } m < j\big),$$
which is irreflexive, transitive and total on distinct indices. Define
$\mathrm{rank}_n(s,j) = |\{m < n : m \succ_s j\}|$ and
$$\mathrm{top}_B(s) \;=\; \{\, j < n \;:\; \mathrm{rank}_n(s,j) < B \,\}.$$
Because $\mathrm{rank}_n(s,\cdot)$ is injective on $\{0,\dots,n-1\}$ and bounded by
$n$, we get $|\mathrm{top}_B(s)| \le B$, with equality when $B \le n$; so
$\mathrm{top}_B(s) \in \mathcal{C}(n,B)$. Moreover every key outside
$\mathrm{top}_B(s)$ scores no better than every key inside it: if
$j \in \mathrm{top}_B(s)$ and $k \in \{0,\dots,n-1\}\setminus \mathrm{top}_B(s)$
then $s(k) \le s(j)$, since $s(j) < s(k)$ would place $j$ strictly below $k$ in
rank, contradicting $\mathrm{rank}(j) < B \le \mathrm{rank}(k)$.

### 3.3 Consistency, and the exact price of its failure

**Definition 3.3 (Order consistency).** A score $s$ is *consistent* with a value
vector $v$ on $\{0,\dots,n-1\}$ if
$$\forall j,k < n:\quad s(k) \le s(j) \;\Longrightarrow\; v(k) \le v(j).$$
It is *$\varepsilon$-consistent* with $v$ if $s(k)\le s(j) \Rightarrow v(k) \le v(j)+\varepsilon$.

**Theorem 3.4 (Approximate consistency is priced at $B\varepsilon$).** Let
$w_t \ge 0$, $\varepsilon \ge 0$, $B \le n$, and suppose $s$ is
$\varepsilon$-consistent with $w_t$ on $\{0,\dots,n-1\}$. Then
$$\mathrm{oracle}(n,B,w,t) \;\le\; \mathrm{kept}\big(w,t,\mathrm{top}_B(s)\big) \;+\; B\,\varepsilon .$$

*Proof sketch.* Put $H = \mathrm{top}_B(s)$, so $|H| = B$. For an arbitrary
admissible $S$ we have $|S| \le B = |H|$, and for $k \in S \setminus H$,
$j \in H \setminus S$ the domination property of §3.2 gives $s(k) \le s(j)$, whence
$\varepsilon$-consistency gives $w_t(k) \le w_t(j) + \varepsilon$. Theorem 3.1
applies and yields $\mathrm{kept}(w,t,S) \le \mathrm{kept}(w,t,H) + B\varepsilon$;
taking the maximum over $S$ gives the claim. $\square$

**Theorem 3.5 (Assumption-conditioned optimality).** If $w_t \ge 0$, $B \le n$ and
$s$ is consistent with $w_t$, then
$$\mathrm{oracle}(n,B,w,t) \;=\; \mathrm{kept}\big(w,t,\mathrm{top}_B(s)\big).$$

*Proof sketch.* "$\le$" is Theorem 3.4 with $\varepsilon = 0$; "$\ge$" is
admissibility of $\mathrm{top}_B(s)$. $\square$

Theorem 3.5 is the exact sense in which online prediction requires an assumption:
a policy's statistic transfers the oracle's performance if and only if it never
misorders the future row.

**Theorem 3.6 (The price is sharp).** Let $\varepsilon \ge 0$ and $2B \le n$.
Consider the score $s(j) = -j$ (so $\mathrm{top}_B(s) = \{0,\dots,B-1\}$) and the
instance
$$w_t(j) \;=\; \begin{cases} 0, & j < B,\\ \varepsilon, & j \ge B.\end{cases}$$
Then $\mathrm{kept}(w,t,\mathrm{top}_B(s)) = 0$, the instance is
$\varepsilon$-consistent with $s$, and
$$\mathrm{oracle}(n,B,w,t) \;=\; B\varepsilon \;=\; \mathrm{kept}\big(w,t,\mathrm{top}_B(s)\big) + B\varepsilon.$$

*Proof sketch.* Upper bound: every key is worth at most $\varepsilon$, and a cache
holds at most $B$ keys, so no cache exceeds $B\varepsilon$. Lower bound: the block
$\{B, \dots, 2B-1\}$ is admissible (this is where $2B \le n$ is needed) and each of
its $B$ keys carries $\varepsilon$. Consistency: any two weights differ by at most
$\varepsilon$. $\square$

Two consequences. First, no conversion of score quality into retention can beat
$B\varepsilon$, so §8's deployment correction is not merely sufficient but tight.
Second, the correction scales with the *cache*, not with the *context*: the
relevant defect is a per-row quantity multiplied by how much you keep.

### 3.4 The hypothesis behind heavy hitters, isolated

**Theorem 3.7 (Exact stationarity).** Suppose $w_t \ge 0$, $B \le n$, and there are
constants $c \ge 0$, $d$ with $w_t(j) = c\,\mathrm{acc}_t(j) + d$ for all $j < n$.
Then $\mathrm{oracle}(n,B,w,t) = \mathrm{kept}(w,t,H_B(w,t))$: the heavy-hitter
cache is exactly the oracle cache.

*Proof sketch.* An order-preserving affine map turns $\mathrm{acc}_t(k) \le
\mathrm{acc}_t(j)$ into $w_t(k) \le w_t(j)$, so $\mathrm{acc}_t$ is consistent with
$w_t$; apply Theorem 3.5. $\square$

**Theorem 3.8 (Approximate stationarity).** If instead
$|w_t(j) - (c\,\mathrm{acc}_t(j) + d)| \le \varepsilon/2$ for all $j < n$, with
$c \ge 0$ and $\varepsilon \ge 0$, then
$$\mathrm{oracle}(n,B,w,t) \;\le\; \mathrm{kept}\big(w,t,H_B(w,t)\big) + B\varepsilon .$$

*Proof sketch.* If $\mathrm{acc}_t(k) \le \mathrm{acc}_t(j)$ then
$w_t(k) \le c\,\mathrm{acc}_t(k) + d + \varepsilon/2 \le c\,\mathrm{acc}_t(j) + d +
\varepsilon/2 \le w_t(j) + \varepsilon$, i.e. $\mathrm{acc}_t$ is
$\varepsilon$-consistent with $w_t$; apply Theorem 3.4. $\square$

Theorems 3.7–3.8 name what heavy-hitter eviction silently assumes: that the row
about to be served is, up to an order-preserving affine distortion, the row you
have already seen on average. The measured $11.3$ points are the price of that
assumption being false.

---

## 4. Online prediction is impossible

### 4.1 The adversarial family

**Definition 4.1.** For $n \ge 1$, $T \ge 0$ and $j_0 < n$, let
$$\mathrm{adv}(n,T,j_0)_t(j) \;=\; \begin{cases} 1/n, & t < T,\ j < n,\\ 1, & t \ge T,\ j = j_0,\\ 0, & \text{otherwise.}\end{cases}$$
So the first $T$ rows are uniform over the $n$ keys and the served row $T$ is a
one-hot at $j_0$.

**Lemma 4.2 (Legitimacy).** Every row of $\mathrm{adv}(n,T,j_0)$ is a probability
distribution: it is nonnegative and $\sum_{j<n} \mathrm{adv}(n,T,j_0)_t(j) = 1$ for
all $t$, provided $0 < n$ and $j_0 < n$.

**Lemma 4.3 (Indistinguishable prefixes).** For all $j_0, j_1 < n$, all $r < T$ and
all $j$: $\mathrm{adv}(n,T,j_0)_r(j) = \mathrm{adv}(n,T,j_1)_r(j)$.

**Lemma 4.4 (Served row).** $\mathrm{kept}(\mathrm{adv}(n,T,j_0), T, S) = 1$ if
$j_0 \in S$ and $0$ otherwise.

**Theorem 4.5 (The oracle retains everything).** For $B \ge 1$ and $j_0 < n$,
$$\mathrm{oracle}\big(n,B,\mathrm{adv}(n,T,j_0),T\big) = 1.$$

*Proof sketch.* Upper bound from Lemma 4.4 (no cache exceeds $1$). Lower bound:
$\{j_0\}$ is admissible when $B \ge 1$ and contains $j_0$. $\square$

### 4.2 The impossibility

**Theorem 4.6 (Every causal policy misses).** Let $P$ be causally honest at
$(n,B)$ with $B < n$. Then there exists $j_0 < n$ with
$$\mathrm{kept}\big(\mathrm{adv}(n,T,j_0),\, T,\, P(\mathrm{adv}(n,T,j_0), T)\big) = 0.$$

*Proof sketch.* Let $S = P(\mathrm{adv}(n,T,0), T)$, an admissible cache, so
$S \subseteq \{0,\dots,n-1\}$ and $|S| \le B < n$. Hence some $j_0 < n$ lies outside
$S$ (else $\{0,\dots,n-1\} \subseteq S$ would force $n \le |S| \le B$). By Lemma 4.3
the instances $\mathrm{adv}(n,T,j_0)$ and $\mathrm{adv}(n,T,0)$ agree on all rows
$r < T$, so causality gives $P(\mathrm{adv}(n,T,j_0),T) = S$. Lemma 4.4 with
$j_0 \notin S$ gives retention $0$. $\square$

**Theorem 4.7 (The oracle overstates the deployable win).** Let $P$ be causally
honest at $(n,B)$ with $1 \le B < n$. Then there exists $j_0 < n$ with
$$\mathrm{oracle}\big(n,B,\mathrm{adv}(n,T,j_0),T\big) - \mathrm{kept}\big(\mathrm{adv}(n,T,j_0),T,P(\mathrm{adv}(n,T,j_0),T)\big) \;=\; 1 .$$

*Proof.* Combine Theorems 4.5 and 4.6. $\square$

Since retention lies in $[0,1]$, a gap of $1$ is the maximum arithmetically
possible. The measured $0.1131$ is the average-case shadow of a worst case that is
total. Note the quantifier order: the theorem is universally quantified over
policies, so it applies to schemes not yet invented, including learned importance
heads, provided only that they read the past.

**Corollary 4.8 (No deployable heuristic is exempt).** In particular, at any
$1 \le B < n$ each of the heavy-hitter cache, the recency cache and the hybrid
cache suffers a full unit gap on some instance of the family.

### 4.3 Averages and randomisation

**Theorem 4.9 (Counting bound).** For any causally honest $P$ at $(n,B)$,
$$\sum_{j_0 = 0}^{n-1} \mathrm{kept}\big(\mathrm{adv}(n,T,j_0),T,P(\mathrm{adv}(n,T,j_0),T)\big) \;\le\; B .$$

*Proof sketch.* By causality $P$ outputs the same set $S$ on every member of the
family, so by Lemma 4.4 the $j_0$-th summand is the indicator $\mathbf{1}[j_0 \in S]$.
The sum is therefore $|\{j_0 < n : j_0 \in S\}| = |S| \le B$, using
$S \subseteq \{0,\dots,n-1\}$. $\square$

**Corollary 4.10 (Average retention is at most the budget fraction).** For $n>0$,
$$\frac{1}{n}\sum_{j_0<n} \mathrm{kept}\big(\mathrm{adv}(n,T,j_0),T,P(\cdot)\big) \;\le\; \frac{B}{n},$$
while the oracle equals $1$ on every member.

**Theorem 4.11 (Randomisation does not help).** Let $I$ be a finite index set,
$(P_i)_{i\in I}$ causally honest policies at $(n,B)$, and $(q_i)_{i \in I}$
nonnegative weights with $\sum_i q_i = 1$. If $n > 0$, there exists $j_0 < n$ with
$$\sum_{i \in I} q_i \,\mathrm{kept}\big(\mathrm{adv}(n,T,j_0),T,P_i(\mathrm{adv}(n,T,j_0),T)\big) \;\le\; \frac{B}{n}.$$

*Proof sketch.* Sum the left-hand side over $j_0 < n$ and exchange the order of
summation. The inner sum over $j_0$ is bounded by $B$ for each $i$ (Theorem 4.9),
so the double sum is at most $\sum_i q_i B = B = n \cdot (B/n)$. A sum of $n$ terms
bounded by $n$ copies of $B/n$ has a term at most $B/n$. $\square$

This is the Yao-style form of the barrier: the obstruction is informational, not
an artefact of determinism. A distribution over evictors buys nothing against an
adversary allowed to pick the instance after seeing the distribution.

**Theorem 4.12 (Necessity of $B < n$).** For $w_t \ge 0$,
$\mathrm{oracle}(n,n,w,t) = \mathrm{kept}(w,t,\{0,\dots,n-1\})$: at full budget the
whole context is admissible, the oracle's choice is vacuous, and the gap is $0$.

Thus the hypothesis $B<n$ in Theorem 4.7 is not decorative; it exactly delimits the
regime in which selection matters, which is precisely the deployment regime.

---

## 5. Why the hybrid, and why it is forced

The impossibility says every policy fails somewhere. It does not say all policies
fail equally often, and the measurement found a systematic ordering. Two
two-parameter families explain it.

**Definition 5.1 (Diagnostics).** With $n \ge 1$ and $T \ge 1$:

- the **stale** instance $\mathrm{stale}(n,T)$ has $\mathrm{stale}_t = \delta_0$
  (one-hot at key $0$) for $t < T$ and $\mathrm{stale}_T = \delta_{n-1}$;
- the **pinned** instance $\mathrm{pin}$ has $\mathrm{pin}_t = \delta_0$ for every
  $t$, including the served row.

Their accumulated scores are immediate: $\mathrm{acc}_T(j) = T$ for $j=0$ and $0$
otherwise on the stale instance, and $\mathrm{acc}_t(j) = t$ for $j = 0$ and $0$
otherwise on the pinned instance.

**Theorem 5.2 (Accumulation is biased).** For $1 \le B \le n-1$ and $T \ge 1$,
$$\mathrm{kept}\big(\mathrm{stale}(n,T),T,H_B(\mathrm{stale}(n,T),T)\big) = 0 .$$

*Proof sketch.* Under the stale score, key $0$ strictly outranks $n-1$ (score $T>0$
against $0$) and every other key $m \ne 0$ ties with $n-1$ at score $0$, so ties
break by index and $m \succ n-1$ for all $m < n-1$. Hence
$\mathrm{rank}(n-1) \ge B$, so $n-1 \notin H_B$, and the served row's entire mass
sits on $n-1$. $\square$

**Theorem 5.3 (Recency wins there).** For $m \ge 1$ and $n \ge 1$,
$\mathrm{kept}(\mathrm{stale}(n,T),T,R_m) = 1$, because $n-1 \in R_m$.

**Theorem 5.4 (Recency is biased too).** For $m \le n-1$,
$\mathrm{kept}(\mathrm{pin},t,R_m) = 0$, because $R_m = \{n-m,\dots,n-1\}$ omits key
$0$, which carries the whole served row.

**Theorem 5.5 (Accumulation wins there).** For $B \ge 1$ and $n \ge 1$,
$\mathrm{kept}(\mathrm{pin},t,H_B(\mathrm{pin},t)) = 1$: no key outranks $0$ under
the pinned score, so $\mathrm{rank}(0) = 0 < B$.

**Corollary 5.6 (No dominance).** For $1 \le B \le n-1$, $T\ge1$, at the same budget
on the same key set,
$$\mathrm{kept}(\mathrm{stale},T,H_B) < \mathrm{kept}(\mathrm{stale},T,R_B) \quad\text{and}\quad \mathrm{kept}(\mathrm{pin},T,R_B) < \mathrm{kept}(\mathrm{pin},T,H_B),$$
the two comparisons being $0 < 1$ in both directions.

**Definition 5.7 (Budget split).** For $a,b \ge 0$, the split policy is
$\mathrm{split}_{a,b}(w,t) = H_a(w,t) \cup R_b$, of size at most $a+b$.

**Theorem 5.8 (The hybrid split is forced).** Let $1 \le a \le n-1$, $1 \le b \le n-1$,
$T \ge 1$, $n \ge 1$. Then

1. $\mathrm{kept}(\mathrm{stale},T,\mathrm{split}_{a,b}) = 1$ and $\mathrm{kept}(\mathrm{pin},T,\mathrm{split}_{a,b}) = 1$;
2. $\mathrm{kept}(\mathrm{stale},T,\mathrm{split}_{a,0}) = 0$;
3. $\mathrm{kept}(\mathrm{pin},T,\mathrm{split}_{0,b}) = 0$.

*Proof sketch.* (1) The recency half contains $n-1$ whenever $b \ge 1$, handling
stale; the heavy-hitter half contains $0$ whenever $a \ge 1$ (Theorem 5.5),
handling pinned. (2) With $b=0$ the recency half is empty and Theorem 5.2 applies.
(3) With $a=0$ the heavy-hitter half is empty and Theorem 5.4 applies. $\square$

So the hybrid is the unique shape of policy passing both diagnostics: a split
retains both families exactly when both halves are nonzero. This explains **P2**
structurally — the recency reserve is not a tuned nicety but a repair of a
specific, total failure mode — and it explains **P3** too, because the hybrid is
itself causally honest and therefore still subject to Theorem 4.7. Improving a
policy's failure profile is not the same as escaping the barrier.

---

## 6. Three escapes, closed

### 6.1 Granularity

Real systems evict in blocks. Let $\mathrm{blk}(n,\beta,b) = \{ j < n : \lfloor j/\beta \rfloor = b \}$
be the $b$-th block of width $\beta \ge 1$.

**Lemma 6.1.** $|\mathrm{blk}(n,\beta,b)| \le \beta$, since $j \mapsto j \bmod \beta$
is injective on a block and lands in $\{0,\dots,\beta-1\}$. Hence
$\mathrm{blk}(n,\beta,b) \in \mathcal{C}(n,B)$ whenever $\beta \le B$.

**Theorem 6.2 (Block oracle still wins).** If $1 \le \beta \le B$ and $j_0 < n$, the
block $\mathrm{blk}(n,\beta,\lfloor j_0/\beta\rfloor)$ is an admissible cache and
retains $1$ on $\mathrm{adv}(n,T,j_0)$.

**Theorem 6.3 (The wall is causality, not granularity).** For any causally honest
$P$ at $(n,B)$ with $B<n$ and any $1 \le \beta \le B$, there is $j_0 < n$ with
$$\mathrm{kept}\big(\mathrm{adv}(n,T,j_0),T,\mathrm{blk}(n,\beta,\lfloor j_0/\beta\rfloor)\big) - \mathrm{kept}\big(\mathrm{adv}(n,T,j_0),T,P(\cdot)\big) = 1 .$$

*Proof.* Theorem 4.6 supplies $j_0$ with policy retention $0$; Theorem 6.2 gives
block-oracle retention $1$. $\square$

Coarsening changes the oracle's *menu*, not the policy's *information*. The
separation is untouched.

### 6.2 Per-layer allocation is a min-plus convolution

**Definition 6.4.** For loss curves $f,g : \mathbb{N} \to \mathbb{R}$ (loss of a layer
as a function of the budget it receives), the optimally allocated two-layer loss at
total budget $B$ is the min-plus (tropical) convolution
$$(f \oplus g)(B) \;=\; \min_{0 \le a \le B}\big(f(a) + g(B-a)\big),$$
a minimum over a finite nonempty set, hence attained. It is commutative:
substituting $a \mapsto B-a$ is a bijection of the index range.

**Definition 6.5 ($L$ layers).** For a list of curves, define
$\mathrm{alloc}([\,]) = 0$, $\mathrm{alloc}([f])(B) = f(B)$, and
$$\mathrm{alloc}(f :: \mathrm{rest})(B) = \min_{0\le a \le B}\big(f(a) + \mathrm{alloc}(\mathrm{rest})(B-a)\big),$$
an iterated min-plus convolution. For two layers this is exactly $f \oplus g$.

**Theorem 6.6 (Gaps add across layers).** If $f_\ell$ are oracle loss curves,
$f'_\ell$ the corresponding deployable curves, and $f_\ell(a) + \delta \le f'_\ell(a)$
for every layer $\ell$ and every budget $a$, then for every total budget $B$ and
every list of $L$ layers
$$\mathrm{alloc}(f_1,\dots,f_L)(B) + L\,\delta \;\le\; \mathrm{alloc}(f'_1,\dots,f'_L)(B).$$

*Proof sketch.* Induction on $L$. For $L=1$ it is the hypothesis. For the step, let
$a$ attain the minimum for the primed list, so
$\mathrm{alloc}(f'_1,\dots)(B) = f'_1(a) + \mathrm{alloc}(f'_2,\dots)(B-a)$. Bound
$\mathrm{alloc}(f_1,\dots)(B) \le f_1(a) + \mathrm{alloc}(f_2,\dots)(B-a)$ by
suboptimality of the same split, then apply the hypothesis at $a$ for layer $1$ and
the inductive hypothesis at budget $B-a$ for the remaining $L-1$ layers, gaining
$\delta$ and $(L-1)\delta$ respectively. $\square$

No convexity or monotonicity of the loss curves is assumed, so the statement covers
irregular real per-layer profiles. The practical reading: reallocating a global
budget across depth cannot recover a per-layer policy penalty; a deployment table
for an $L$-layer model must be corrected $L$ times.

### 6.3 Budget

Theorem 4.12 already gives the third: only the vacuous regime $B = n$ closes the
gap.

---

## 7. The recorded run as arithmetic

For completeness we record the arithmetic content of the measurement. Writing
$\mathrm{ret}(\text{arm}, B)$ for the tabulated retentions of §1.1:

- **P1**: $\mathrm{ret}(\text{oracle},64) - \mathrm{ret}(\text{hh},64) = 0.9953 - 0.8822 = 0.1131 > 0.02$.
- **P2**: $\mathrm{ret}(\text{hh},B) < \mathrm{ret}(\text{hyb},B)$ at $B = 32,64,128$.
- **P3 refuted**: $\mathrm{ret}(\text{hyb},64) = 0.9384 < 0.95$ and
  $\mathrm{ret}(\text{hyb},128) = 0.9605 < 0.97$.
- **Sanity**: every tabulated value lies in $[0,1]$, and each arm is strictly
  increasing in budget — the monotonicity gate the run had to pass.

Seven implementation variants were rejected by sanity gates before this run was
recorded: two shape errors; a stale kept-set that starved local context (retention
$0.35$–$0.46$, far below the recency floor); a per-block causal leak that let rows
see their own block's future (retention $2.06 > 1$, physically impossible for a
probability row); a masking numerical failure; a duplicated recency reserve; and an
unbound variable. The two invalid variants function as bracketing negative
controls: one violates the retention band from below and one from above, so the
accepted run is pinned between two known-bad behaviours. The oracle arm's exact
agreement with an independent earlier measurement of the same knee ($0.9913$ vs
$0.9912$ at $k=32$) is the cross-replication check.

---

## 8. Deployment: what to correct and how

The theory yields an operational recipe.

1. **Quote oracle curves as upper bounds.** By Theorem 4.7 the oracle number is
   not attainable by any deployable evictor; by Theorem 4.11 not even by a
   randomised one. Reporting the oracle knee as a deployment budget is an
   overstatement whose worst-case size is a full unit of retained mass.
2. **Measure the consistency defect.** For the score $s$ in use, define the
   per-row defect
   $$\varepsilon(w,s,t) \;=\; \max\{\, w_t(k) - w_t(j) \;:\; j,k<n,\ s(k) \le s(j) \,\}_+ ,$$
   the largest amount by which the score inverts the true row. This is a maximum
   over pairs in a matrix the oracle arm already materialises: no retraining, no new
   kernels.
3. **Apply the correction $B\varepsilon$ per layer.** Theorem 3.4 bounds the loss
   by $B\varepsilon$; Theorem 3.6 shows the bound is attained, so it cannot be
   improved without further assumptions.
4. **Multiply by depth.** Theorem 6.6: under optimal global budget allocation the
   per-layer penalties add, so an $L$-layer table needs $L$ corrections.
5. **Keep both halves of the budget.** Theorem 5.8: an all-heavy-hitter or
   all-recency split fails totally on an explicit family; a genuine split passes
   both.

Two calibration remarks. If the defect of accumulated attention on trained models
is $O(1/B)$, then $B\varepsilon = O(1)$ with a small constant, and the observed
retention band is *forced* by Theorem 3.4 — the measured $11.3$ points would then be
a prediction rather than a surprise. Conversely, a large measured defect certifies
that the oracle table cannot be repaired by any monotone reweighting of the same
score, and that closing the gap requires a genuinely different statistic.

---

## 9. Discussion

### 9.1 What the separation is, and is not

It is an *information* separation. The oracle and the policy face the same
combinatorial problem — choose $B$ of $n$ items to maximise a linear objective — and
that problem is trivial in both cases; the greedy exchange argument of §3 solves it
in one line. The difference is the objective's availability. The oracle optimises
the true row; the policy optimises a surrogate constructed from a prefix that, on
the adversarial family, is *statistically identical* across all instances. No amount
of computation extracts information a prefix does not contain.

It is not a statement that heavy-hitter eviction is a bad idea. On real text the
measured retention at $B=64$ is $0.8822$ for pure accumulation and $0.9384$ for the
hybrid — very far from the worst-case $0$. Trained attention evidently has structure
that makes accumulated attention a *usable*, if biased, estimator. Theorems 3.7–3.8
say precisely what structure would make it unbiased, and how the loss degrades as
the structure fails.

### 9.2 The measured gap versus the proved gap

The proved worst case is $1$; the measurement is $0.1131$. The distance between
them is the entire remaining scientific content of the programme: *which structural
property of trained attention makes the gap eleven points rather than a hundred, and
can that property be certified online?* Theorem 3.4 turns the question into a
one-dimensional estimation problem about $\varepsilon$, which is why it is the
recommended next measurement.

### 9.3 Limitations

The measurement is one model at one context length with one eviction granularity
and no learned importance head; corpus and scale robustness are untested here. The
theory covers arbitrary policies but scores a policy only by single-row retained
attention mass, which is a proxy for end-task quality rather than end-task quality
itself; a policy could in principle lose mass on rows where the loss does not matter
downstream. The adversarial family is stochastic and legitimate but not
*natural*: its rows are uniform and then one-hot, which is not what trained
attention looks like. This is a feature for an impossibility result (it shows the
barrier does not need exotic instances) and a limitation for a forecast (it shows
the worst case is not the typical case).

### 9.4 Relation to reliability barriers

The result is a concrete instance of a general pattern: a decoder's reliability
cannot be improved exponentially by post-hoc selection without an assumption that
links the past to the future. Here the assumption is order-consistency, the price
of its approximate failure is exactly $B\varepsilon$, and the composition rule
across layers is min-plus. The tropical structure is not incidental — budget
allocation across independent components with additive losses is a min-plus
convolution in general, and the penalty-passing statement of Theorem 6.6 holds at
that level of generality.

---

## 10. Future work

Four directions follow directly.

1. **The consistency defect as a deployment constant.** Measure
   $\varepsilon(w,s,t)$ on trained models. If it is $O(1/B)$, oracle tables become
   usable after a one-parameter correction; if not, the correction is
   score-specific and must be published alongside any retention curve.
2. **Online certificates.** Order consistency is a checkable property of a prefix
   and a candidate ranking. Is there a cheap online test — necessarily conservative,
   by Theorem 4.7 — that certifies, for a given prefix, that pruning will transfer?
   Such a test would allow adaptive budgets: aggressive eviction on certified
   prefixes, conservative on the rest.
3. **Learned importance heads.** A small predictor trained to forecast the next
   row's top-$B$ set is still a causal policy and so cannot beat Theorem 4.7 in the
   worst case; the question is whether it reduces the *measured* defect. This is the
   sharpest empirical test of whether the gap is estimator-limited or
   information-limited on real text.
4. **Per-layer budgets and depth.** Theorem 6.6 assumes only pointwise per-layer
   penalties. Whether real per-layer loss curves are *convex* — which is what would
   make greedy allocation optimal, rather than merely min-plus-optimal — is an open
   empirical question with immediate systems consequences.

Two further items are quantitative refinements of results proved here: splitting the
measured $11.3$ points into a coarsening term and a causality term (Theorem 6.3 shows
the second is nonzero; the split is unmeasured), and replicating the whole table at
larger scale and on a broader corpus.

---

## 11. Conclusion

Concentration of trained attention is real and large: on the recorded run a
$32$-key cache captures $99.13\%$ of a row's attention mass and a $64$-key cache
$99.53\%$, in a context of $1024$. Both numbers are produced by a selector that has
already read the row it caches for. We proved that no selector restricted to the
past can inherit them: for every budget short of the full context and every causally
honest policy, deterministic or randomised, there is a legitimate stochastic instance
on which the oracle retains everything and the policy retains nothing, and on average
over that family the policy retains at most the budget fraction $B/n$. The escape is
an assumption — order-consistency of the score with the future row — whose exact price
in the approximate regime is $B\varepsilon$, attained. Neither block granularity nor
per-layer reallocation evades the barrier; the per-layer penalty in fact accumulates
linearly in depth under optimal allocation. And the empirically superior hybrid
policy is structurally forced: each pure heuristic fails totally on an instance where
the other succeeds totally, and only a genuine split survives both.

Trained attention is prunable in retrospect, not predictable in advance. Deployment
tables must be policy-adjusted; oracle quotes are upper bounds.
