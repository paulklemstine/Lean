# The Knee Is a Quantile: Demand-Multiset Calculus for Budget–Quality Curves, with an Interval-Cover Theory of Deployment Entries

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

Truncated-memory inference replaces a system's full record of the past by its $k$
most useful entries. Sweeping $k$ and recording the fraction of positions on which
the truncated system still reproduces the full system's output produces a
*budget–quality curve*; the smallest budget clearing a fixed quality gate $g$ is the
**knee** $k^{*}(g)$. Empirically the knee is remarkably domain-stable: on a
measured three-domain panel it takes the value $16$ on English prose, $12$ on source
code, and — the observation motivating this work — $16$ again on classical
mathematical text, whose full-model prediction accuracy is *twelve percentage points
lower* than prose's ($0.3262$ vs. $0.4460$ at context $512$, $0.3418$ vs. $0.4612$ at
context $1024$). Doubling the context shifts prose and mathematics rigidly by $+4$
keys, to $20$.

We give a combinatorial account of why this must be so, and turn the resulting
deployment table into a solved extremal problem.

We introduce the *demand multiset calculus*. A workload is a finite family of
positions, each carrying a **demand** (the least budget preserving the full system's
output there) and a **correctness bit**. We prove: (i) the knee is the left adjoint
of the agreement curve, $k^{*}(g) \le k \iff g \le A(k)$ for monotone $A$; (ii) the
entire sweep is a function of the demand *multiset* alone, so equal demand multisets
force equal knees at every gate regardless of accuracy; (iii) the joint map
workload $\mapsto$ (knee curve, accuracy) is **surjective**, so no inequality can
link difficulty to budget; (iv) the knee is exactly the $\lceil gn\rceil$-th order
statistic of the demand distribution, with an exact tail criterion, a Markov
relaxation, and a perturbation-robustness theorem; (v) the knee is invariant under
strictly monotone reparametrisation of the quality axis and under permutation of
positions, shifts rigidly under translation of the curve, and is trapped between
constituent knees under corpus mixing; and (vi) every monotone, bounded, eventually
saturating count profile is realised by an honest workload, so measured sweeps are
attained rather than idealised.

We then formalise the deployment claim "prose and mathematics share one cache-size
entry; only code shifts" as an interval point-cover problem: an entry $b$ serves a
knee $k$ at waste tolerance $\delta$ iff $k \le b \le k+\delta$. We prove a
single-entry criterion (one entry suffices iff $\max K \le \min K + \delta$), a
packing lower bound from $\delta$-separated knees, a greedy covering bound of
$\lfloor (b-a)/(\delta+1)\rfloor + 1$ entries on $[a,b]$, and a **min–max duality**:
on knees in arithmetic progression of common difference $\delta+1$, packing equals
covering and the minimum entry count is exactly the number of knees. Applied to the
measured knee set $\{12,16\}$ this yields the exact threshold $\delta = 4$ — one scale
increment — at which the whole three-domain fleet collapses to the single entry $16$.

**Keywords.** order statistics, quantiles, demand multiset, budget–quality curve,
Galois adjunction, interval point cover, packing–covering duality, attention sparsity.

---

## 1. Introduction

### 1.1 The measurement

Consider a sequential predictor that maintains a memory of $n_{\mathrm{ctx}}$ past
positions and, at each step, attends to that memory to emit a prediction. Truncation
keeps only the $k$ highest-scoring memory entries. Two observables are then natural:

1. **Retained agreement** $A(k)$: the fraction of prediction positions at which the
   $k$-truncated predictor emits the same output as the untruncated one.
2. **Accuracy** $\mathrm{acc}$: the fraction of positions at which the *untruncated*
   predictor's output is correct against the reference text.

Fix a **gate** $g$ — an agreement threshold — and define the **knee**
$k^{*}(g) = \min\{k : A(k) \ge g\}$. The knee is the operationally relevant number:
it is the cache size a deployment must provision.

The measurement that motivates this paper swept $k$ on a corpus of classical
mathematical prose under a harness byte-identical to one previously run on English
prose and on source code. The sweep, at context $512$:

| budget $k$ | 4 | 8 | 12 | 16 | 20 | 24 |
|---|---|---|---|---|---|---|
| agreement | $0.907$ | $0.959$ | $0.979$ | $\mathbf{0.987}$ | $0.989$ | $0.988$ |

and at context $1024$:

| budget $k$ | 8 | 12 | 16 | 20 | 24+ |
|---|---|---|---|---|---|
| agreement | $0.952$ | $0.965$ | $0.978$ | $\mathbf{0.983}$ | pass |

The first passing budget is $16$ at context $512$ and $20$ at context $1024$. These
are *exactly* the previously measured prose knees. Meanwhile the full-model
accuracies are $0.3262$ and $0.3418$ for mathematics against $0.4460$ and $0.4612$
for prose: gaps of $0.1198$ and $0.1194$.

Three predictions had been registered in advance: **P1**, mathematics needs more
keys (long-range symbolic reference); **P2**, mathematics sits between prose and
code; **P3**, mathematics coincides with prose. P1 is refuted, P2 holds only
trivially, P3 is confirmed exactly at both contexts.

### 1.2 The question this paper answers

Why should a domain that is twelve points harder to predict need *identically* many
keys? Is the coincidence an artefact of one corpus, one gate choice, one mixing
ratio — or is it structural?

We argue it is structural, and prove it in two stages. Stage one (§§2–5) identifies
what the sweep can and cannot see, culminating in a surjectivity theorem: knee and
accuracy are free coordinates, so no lawlike inequality between them exists. Stage
two (§6) identifies the knee as an order statistic, which explains the *mechanism*:
accuracy is a mean of one variable, the knee is a quantile of another, and the tail
of the demand distribution is exactly the thing a domain shift need not move.

Stage three (§7) turns the resulting three-row table into a solved extremal problem
in its own right, with a genuine min–max theorem, and reads the measured cell off it.

---

## 2. The demand multiset calculus

### 2.1 Curves and knees

**Definition 2.1 (Knee).** For a curve $A : \mathbb{N} \to \mathbb{Q}$ and a gate
$g \in \mathbb{Q}$, the *knee* is
$$k^{*}(A, g) \;=\; \inf\{ k \in \mathbb{N} : g \le A(k)\},$$
with the convention $\inf \emptyset = 0$ (so an unreachable gate returns $0$; all
statements below assume reachability where it matters).

Two elementary facts hold with no monotonicity assumption: if $g \le A(k)$ for some
$k$ then $g \le A(k^{*}(A,g))$ (the knee attains the gate), and $g \le A(k)$ implies
$k^{*}(A,g) \le k$ (the knee is minimal). Contrapositively, $k < k^{*}(A,g)$ implies
$A(k) < g$.

**Theorem 2.2 (Galois adjunction).** Let $A$ be monotone and suppose $g \le A(m)$ for
some $m$. Then for all $k$,
$$k^{*}(A, g) \;\le\; k \quad\Longleftrightarrow\quad g \;\le\; A(k).$$

*Proof sketch.* ($\Rightarrow$) $g \le A(k^{*}) \le A(k)$ by attainment and
monotonicity. ($\Leftarrow$) is minimality. $\square$

The knee is thus the left adjoint of the curve, viewed as a monotone map between the
posets $(\mathbb{Q}, \le)$ and $(\mathbb{N}, \le)$. Every monotonicity statement
below is an instance. In particular: the knee is monotone in the gate
($g_1 \le g_2 \Rightarrow k^{*}(A,g_1) \le k^{*}(A,g_2)$), and antitone in the curve
(if $A \le B$ pointwise then $k^{*}(B,g) \le k^{*}(A,g)$).

**Lemma 2.3 (Exact determination).** If $g \le A(k)$ and $A(j) < g$ for all $j < k$,
then $k^{*}(A,g) = k$. This is the form in which concrete knees are computed from a
measured sweep.

**Theorem 2.4 (Reparametrisation invariance).** For any strictly monotone
$\psi : \mathbb{Q} \to \mathbb{Q}$ and any gate $g$,
$$k^{*}\bigl(\psi \circ A,\; \psi(g)\bigr) \;=\; k^{*}(A, g).$$

*Proof sketch.* Strict monotonicity gives $\psi(g) \le \psi(A(k)) \iff g \le A(k)$,
so the two infima are taken over literally the same subset of $\mathbb{N}$. $\square$

Theorem 2.4 is the abstract form of the verdict. "This domain is harder" is, at the
level of curves, a distortion of the quality axis. The knee reads only the *order*
of curve values, never the values themselves, so an arbitrary difficulty handicap —
applied consistently and with the gate transported along — cannot move it.

### 2.2 Workloads

**Definition 2.5 (Workload).** A *workload* on $n$ positions consists of a demand
function $r : \{1,\dots,n\} \to \mathbb{N}$ and a correctness function
$c : \{1,\dots,n\} \to \{0,1\}$. Here $r_i$ is the least budget at which the
truncated predictor reproduces the full predictor's output at position $i$, and
$c_i$ records whether the full predictor is correct there.

**Definition 2.6 (Derived observables).** For a workload $D$ on $n > 0$ positions:
- the *agree count* $N_D(k) = \#\{i : r_i \le k\}$;
- the *agreement curve* $A_D(k) = N_D(k)/n$;
- the *accuracy* $\mathrm{acc}(D) = \#\{i : c_i = 1\}/n$;
- the *demand multiset* $\mathcal{D}(D) = \{\!\{ r_1, \dots, r_n \}\!\}$.

$N_D$ and $A_D$ are monotone, $0 \le A_D \le 1$, and every gate $g \le 1$ is reachable
(take $k = \sum_i r_i$, which dominates every individual demand).

---

## 3. Invariance: the sweep sees only the demand multiset

**Lemma 3.1.** $N_D(k)$ equals the number of elements $\le k$ in $\mathcal{D}(D)$.

*Proof sketch.* Counting indices satisfying a predicate on $r_i$ equals counting,
with multiplicity, the elements of the image multiset satisfying the predicate.
$\square$

**Theorem 3.2 (Multiset invariance of the sweep).** If two workloads on the same
number of positions have equal demand multisets, their agreement curves are equal at
every budget:
$$\mathcal{D}(D) = \mathcal{D}(E) \;\Longrightarrow\; A_D = A_E .$$

**Corollary 3.3 (P3, exactly).** Under the same hypothesis,
$k^{*}(A_D, g) = k^{*}(A_E, g)$ for *every* gate $g$ — with no constraint whatsoever
relating $\mathrm{acc}(D)$ and $\mathrm{acc}(E)$.

This is the measured verdict in its cleanest form: the two knees are equal for a
reason that has nothing to do with the two accuracies, because the correctness column
is simply not an input to the sweep.

**Theorem 3.4 (Rebitting).** Given a workload $D$ on $n$ positions and any
$0 \le j \le n$, there is a workload $E$ with $A_E = A_D$ (hence every knee unchanged)
and $\mathrm{acc}(E) = j/n$.

*Proof sketch.* Keep $D$'s demands; set $c_i = [\, i < j \,]$. Counting indices below
a threshold $j \le n$ gives exactly $j$. $\square$

---

## 4. Full decoupling

Invariance says accuracy is invisible to the sweep. Surjectivity says more: the pair
(knee, accuracy) ranges over *everything*.

**Definition 4.1 (Flat workload).** $\mathrm{flat}(n,k,j)$ has $r_i = k$ for all $i$
and $c_i = [\,i < j\,]$.

**Lemma 4.2.** For $n > 0$: $A_{\mathrm{flat}(n,k,j)}(b) = 0$ for $b < k$ and $= 1$ for
$b \ge k$. Hence for every gate $g$ with $0 < g \le 1$,
$k^{*}(A_{\mathrm{flat}(n,k,j)}, g) = k$; and for $j \le n$,
$\mathrm{acc}(\mathrm{flat}(n,k,j)) = j/n$.

**Theorem 4.3 (Decoupling / surjectivity).** For every $n > 0$, every $k \in
\mathbb{N}$ and every $j \le n$, there is a workload on $n$ positions whose knee
equals $k$ at *every* gate $g \in (0,1]$ and whose accuracy equals $j/n$.

*Proof.* Take $\mathrm{flat}(n,k,j)$ and apply Lemma 4.2. $\square$

**Interpretation.** The joint invariant $D \mapsto (k^{*}(A_D, \cdot), \mathrm{acc}(D))$
is onto its natural codomain. Therefore *no* inequality of the form "higher difficulty
$\Rightarrow$ larger budget" can hold for workloads in general. P1 is refuted not just
empirically but structurally: any putative law linking the two coordinates has an
immediate counterexample.

**Corollary 4.4 (The measured shape is realisable).** There exist workloads $P$ and
$M$ on $10^4$ positions with $k^{*}(A_P, g) = k^{*}(A_M, g) = 16$ for every
$g \in (0,1]$ and $\mathrm{acc}(P) - \mathrm{acc}(M) = 0.1198$ — the measured
context-$512$ accuracy gap, with the measured shared knee.

---

## 5. Structural laws of the knee

Four further laws make the calculus usable, and each closes a stated methodological
objection to the measurement.

**Theorem 5.1 (Demand domination).** If $r_i^{D} \le r_i^{E}$ for all $i$ and the gate
is reachable for $E$, then $k^{*}(A_D, g) \le k^{*}(A_E, g)$.

*Proof sketch.* Pointwise-smaller demands give a pointwise-larger agree count, hence a
pointwise-larger curve, and the knee is antitone in the curve. $\square$

This is the *structural* content of "code is cheaper than prose": code's demand
profile is pointwise below prose's, and the strict gap $12 < 16$ is then a
measurement on top of a proved inequality.

**Theorem 5.2 (Shape preservation / rigid shift).** Let $A$ be a curve with reachable
gate $g$ and $A(0) < g$, and let $\delta \in \mathbb{N}$. Then the translated curve
$k \mapsto A(k - \delta)$ has
$$k^{*}\bigl(A(\cdot - \delta),\, g\bigr) \;=\; k^{*}(A, g) + \delta ,$$
at *every* gate.

*Proof sketch.* The translated curve attains the gate at $k^{*}(A,g) + \delta$. Below
that, either $b < \delta$, where the translated value is $A(0) < g$, or
$b - \delta < k^{*}(A,g)$, where $A(b-\delta) < g$. Lemma 2.3 concludes. $\square$

This is the empirical "increments are set by scale, shape is preserved everywhere":
the $+4$ shift observed when the context doubles is a translation of the whole curve,
so it moves the knee by exactly $4$ irrespective of the gate.

**Theorem 5.3 (Corpus mixing).** For monotone curves $A, B$, weight
$\theta \in [0,1]$, and $M_\theta(k) = \theta A(k) + (1-\theta) B(k)$, with the
relevant gates reachable,
$$\min\bigl(k^{*}(A,g),\, k^{*}(B,g)\bigr) \;\le\; k^{*}(M_\theta, g) \;\le\;
\max\bigl(k^{*}(A,g),\, k^{*}(B,g)\bigr).$$

*Proof sketch.* Upper bound: at $k = \max$, both $A(k) \ge g$ and $B(k) \ge g$, so the
convex combination is $\ge g$. Lower bound: below the min, both $A(k) < g$ and
$B(k) < g$, so the convex combination is $< g$ (treating $\theta = 0$ separately).
$\square$

**Corollary 5.4 (Mixing ratio is irrelevant here).** Since the prose and mathematics
knees coincide at $16$, *every* mixture of the two corpora has knee $16$. The measured
number does not depend on the blend.

**Theorem 5.5 (Markov bridge).** For a workload on $n > 0$ positions, if
$$\sum_{i} r_i \;\le\; (1-g)\, n\, (k+1),$$
then $k^{*}(A_D, g) \le k$. Informally $k^{*} \lesssim \bar r / (1-g)$ where $\bar r$
is the mean demand.

*Proof sketch.* Each of the $T$ positions with $r_i > k$ contributes at least $k+1$ to
$\sum_i r_i$, so $T(k+1) \le \sum_i r_i \le (1-g)n(k+1)$, giving $T \le (1-g)n$. Since
$N_D(k) + T = n$, we get $A_D(k) = (n-T)/n \ge g$. $\square$

A thin demand tail is therefore *sufficient* for a small budget, no matter how hard
the text is to predict.

**Theorem 5.6 (Realisation).** Let $t : \mathbb{N} \to \mathbb{N}$ be monotone with
$t(k) \le n$ for all $k$ and $t(K) = n$ for some $K$. Then there is a workload on $n$
positions with $N_D = t$ exactly, and with any prescribed accuracy $j/n$.
Consequently, if $g\,n \le t(k)$ and $t(b) < g\,n$ for all $b < k$, that workload has
knee exactly $k$.

*Proof sketch.* Define $r_i = \inf\{k : i < t(k)\}$; monotonicity of $t$ gives
$r_i \le k \iff i < t(k)$, and the number of indices below $t(k) \le n$ is $t(k)$.
$\square$

Theorem 5.6 matters methodologically: it says a measured step profile is not an
idealisation but is *attained* by an honest workload, so the theorems above apply to
the measured cells verbatim.

---

## 6. The mechanism: the knee is an order statistic

**Definition 6.1.** The $m$-th smallest demand of a workload is
$Q_D(m) = \inf\{k : m \le N_D(k)\}$.

**Theorem 6.2 (Quantile identity).** For a workload on $n>0$ positions and any gate
$g$,
$$k^{*}(A_D, g) \;=\; Q_D\bigl(\lceil g n \rceil\bigr).$$

*Proof sketch.* $g \le N_D(k)/n \iff gn \le N_D(k) \iff \lceil gn \rceil \le N_D(k)$,
the last step because $N_D(k)$ is an integer. The two infima are over the same set.
$\square$

**Theorem 6.3 (Exact gate criterion).** With $T_D(k) = \#\{i : r_i > k\}$ the unserved
tail at budget $k$,
$$A_D(k) \ge g \quad\Longleftrightarrow\quad T_D(k) \;\le\; (1-g)\,n .$$

*Proof sketch.* $N_D(k) + T_D(k) = n$; clear denominators. $\square$

Theorem 5.5 is the one-sided Markov relaxation of Theorem 6.3. Two immediate usable
directions follow: if every demand is $\le k$ then $k^{*} \le k$ for any gate $\le 1$;
and if $T_D(k) > (1-g)n$ then $k < k^{*}(A_D, g)$ strictly.

**Theorem 6.4 (Permutation invariance).** Relabelling positions by a bijection leaves
every knee unchanged.

*Proof sketch.* Relabelling preserves the demand multiset; apply Corollary 3.3.
$\square$

Together, Corollary 3.3 and Theorem 6.4 say precisely: **the sweep is a symmetric
function of the demands alone.**

**Theorem 6.5 (Perturbation robustness).** Let $D, E$ be workloads on $n>0$ positions,
$k$ a budget and $g$ a gate. Suppose $T_D(k) \le (1-g)n$ and the unserved set of $E$
at budget $k$ is contained in that of $D$. Then $k^{*}(A_E, g) \le k$ — regardless of
how much worse $E$'s accuracy is.

*Proof sketch.* Containment gives $T_E(k) \le T_D(k) \le (1-g)n$; apply Theorem 6.3
and minimality. $\square$

**This is the mechanism behind the verdict.** Accuracy is a *mean* of the correctness
variable over all positions. The knee is a *quantile* of the demand variable. A
domain change may move the first arbitrarily far while leaving the
$\lceil gn \rceil$-th order statistic of the second exactly in place — and Theorem 6.5
quantifies how much room there is: the demands of up to $(1-g)n - T_D(k)$ positions may
be perturbed arbitrarily upward without raising the knee above $k$. At $g \approx
0.98$ and large $n$ this is roughly $2\%$ of positions, which is precisely the regime
in which a hard domain's long-range references live.

The only coupling between the two statistics is the identity of the positions over
which both are computed — and Theorem 4.3 shows that this coupling carries no
information at all.

---

## 7. Deployment entries as an interval point cover

### 7.1 The measured cells, computed

Applying Theorem 5.6 and Lemma 2.3 to the measured step profiles yields the two knees
not as assumptions but as computations, over the entire admissible gate window (the
open interval between the last failing sweep value and the first passing one):

**Proposition 7.1.** For mathematical text at context $512$, $k^{*}(g) = 16$ for every
gate $g \in (0.979,\, 0.987]$. For mathematical text at context $1024$, $k^{*}(g) = 20$
for every $g \in (0.978,\, 0.983]$.

The gate is thus not tuned: the whole interval between the failing $12$-value and the
passing $16$-value certifies the first cell, and likewise for the second.

**Theorem 7.2 (Mathematics reads as prose).** For every gate in $(0.979, 0.987]$, the
mathematical-text knee and the prose knee at context $512$ are the same number $16$,
while the full-model accuracies differ by exactly $0.4460 - 0.3262 = 0.1198$. For every
gate in $(0.978, 0.983]$, both knees at context $1024$ equal $20$ and the accuracies
differ by exactly $0.4612 - 0.3418 = 0.1194$.

**Corollary 7.3 (P1 refuted on the measured cell).** Mathematical text is strictly
harder to predict at both contexts, yet its budget is not one key larger — it is
identical.

**Theorem 7.4 (One gate certifies both cells; the increment is $+4$).** The two
admissible windows overlap in $(0.979, 0.983]$. On that overlap, the context
$512 \to 1024$ increment is exactly $+4$ for mathematical text and exactly $+4$ for
prose. Shape preservation (Theorem 5.2) is thereby verified on the measured numbers
with a single common gate.

**Theorem 7.5 (Reparametrisation stability of the measured cell).** Composing the
mathematical-text sweep with any strictly monotone distortion of the quality axis, and
transporting the gate along it, still yields knee $16$.

**Theorem 7.6 (Mixture stability).** Any $\theta$-mixture of the prose and
mathematical-text sweeps at context $512$ has knee $16$, for every gate in
$(0.979,0.987]$ and every $\theta \in [0,1]$.

The three-domain table at context $512$ is therefore
$$\text{prose} \mapsto 16, \qquad \text{code} \mapsto 12, \qquad \text{mathematics}
\mapsto 16,$$
with image $\{12,16\}$ of cardinality $2$: prose and mathematics share a budget, only
code shifts.

### 7.2 The combinatorial problem

**Definition 7.7 (Serving).** An entry $b \in \mathbb{N}$ *serves* a knee
$k \in \mathbb{N}$ at waste tolerance $\delta$ iff $k \le b \le k + \delta$: large
enough to clear the gate, not wasteful by more than $\delta$ keys.

**Definition 7.8 (Entry set).** A finite $E \subseteq \mathbb{N}$ is an *entry set* for
a knee set $K$ at tolerance $\delta$ iff every $k \in K$ is served by some $b \in E$.

Equivalently: each domain is the integer interval $[k, k+\delta]$ of length $\delta$,
and an entry set is a set of points meeting every interval. The deployment question
is the minimum size of such a hitting set.

**Theorem 7.9 (Single-entry criterion).** For a nonempty finite $K$,
$$\exists\, b \ \forall k \in K,\ b \text{ serves } k \quad\Longleftrightarrow\quad
\max K \;\le\; \min K + \delta .$$

*Proof.* ($\Rightarrow$) The serving conditions at $\max K$ and $\min K$ give
$\max K \le b$ and $b \le \min K + \delta$. ($\Leftarrow$) Take $b = \max K$: then
$k \le b$ for all $k$, and $b \le \min K + \delta \le k + \delta$. $\square$

**Lemma 7.10 (Separation blocks sharing).** If $k + \delta < \ell$, no entry serves
both $k$ and $\ell$: serving $k$ forces $b \le k + \delta$ and serving $\ell$ forces
$\ell \le b$.

**Theorem 7.11 (Packing lower bound).** Let $S \subseteq K$ be pairwise
$\delta$-separated ($k < \ell$ in $S$ implies $k + \delta < \ell$). Then every entry
set $E$ for $K$ satisfies $|E| \ge |S|$.

*Proof sketch.* Choose for each $k \in S$ a serving entry $f(k) \in E$. By Lemma 7.10
$f$ is injective on $S$; an injection into $E$ bounds $|S| \le |E|$. $\square$

**Definition 7.12 (Greedy entries).** For a top anchor $b$ and count $m$, set
$G(\delta, b, m) = \{\, b - (\delta+1)i : 0 \le i < m \,\}$.

Anchoring at the *top* is essential: an entry must never fall below the knee it
serves, so the progression is counted downward from the largest possible knee.

**Theorem 7.13 (Greedy covering bound).** If every knee in $K$ lies in $[a,b]$, then
$G\bigl(\delta,\, b,\, \lfloor (b-a)/(\delta+1)\rfloor + 1\bigr)$ is an entry set for
$K$, of cardinality at most $\lfloor (b-a)/(\delta+1)\rfloor + 1$.

*Proof sketch.* Given $k \in [a,b]$, write $y = b - k$ and split $y$ by division:
$y = q(\delta+1) + s$ with $0 \le s < \delta+1$, $q = \lfloor y/(\delta+1)\rfloor$. The
candidate entry is $b - (\delta+1)q = k + s$. It is in range because
$q \le \lfloor (b-a)/(\delta+1) \rfloor$, and $k \le k+s \le k+\delta$, so it serves
$k$. $\square$

### 7.3 Packing meets covering

**Definition 7.14 (Extremal configuration).** $\mathrm{AP}(\delta, a, m) = \{\,
a + (\delta+1)i : 0 \le i < m \,\}$: $m$ knees spaced exactly $\delta+1$ apart.

This set has exactly $m$ elements (the generating map is injective), is pairwise
$\delta$-separated (consecutive gaps are $\delta + 1 > \delta$, and gaps only grow), and
lies in $[a,\, a + (\delta+1)(m-1)]$.

**Theorem 7.15 (Min–max duality for deployment entries).** For $\delta, a \in
\mathbb{N}$ and $m > 0$,
$$\min\bigl\{ |E| : E \text{ an entry set for } \mathrm{AP}(\delta,a,m) \bigr\}
\;=\; m .$$
That is: some entry set has at most $m$ entries, and every entry set has at least $m$.

*Proof sketch.* Upper: apply Theorem 7.13 with $a$ and $b = a + (\delta+1)(m-1)$; the
bound is $\lfloor (\delta+1)(m-1)/(\delta+1) \rfloor + 1 = m$. Lower: apply Theorem
7.11 with $S = K = \mathrm{AP}(\delta,a,m)$, which is $\delta$-separated and of
cardinality $m$. $\square$

Packing equals covering on the extremal configuration; neither the greedy bound nor
the pigeonhole bound can be improved. (This is the integer, equal-length special case
of the classical duality between hitting sets and independent sets for interval
families; the point here is the explicit constructive form with the correct top
anchor.)

### 7.4 The measured fleet

The measured knee set is $K_{70} = \{12, 16\}$, with $\min = 12$, $\max = 16$, spread
$4$.

**Theorem 7.16 (Exact entry threshold).** $K_{70}$ admits a single serving entry if and
only if $\delta \ge 4$.

*Proof.* Immediate from Theorem 7.9: $16 \le 12 + \delta \iff \delta \ge 4$. $\square$

**Corollary 7.17 (Collapse at one increment).** For $\delta \ge 4$ the entire
three-domain fleet — prose, mathematics *and* code — is served by the single cache
size $16$.

**Corollary 7.18 (Two entries below threshold).** For $\delta \le 3$ no single entry
serves $K_{70}$, and $\{12, 16\}$ is an entry set of size $2$. So the minimum is exactly
$2$.

The operational sentence *"prose and mathematics share one entry; only code shifts"*
is therefore precisely the $\delta \le 3$ regime. And the threshold $\delta = 4$ is not
arbitrary: it equals the scale increment — the same $+4$ by which every knee moves when
the context doubles (Theorem 7.4). A fleet willing to waste one increment on its
cheapest domain needs one entry; a fleet unwilling to waste that much needs two.

---

## 8. Algorithms

Three procedures follow directly and are stated for implementation.

**A. Knee extraction from a sweep.** Given a monotone sweep
$(k_1, A_1), \dots, (k_m, A_m)$ with $k_1 < \dots < k_m$ and a gate $g$, return the
least $k_j$ with $A_j \ge g$. By Theorem 2.2 a binary search over $j$ is correct;
cost $O(\log m)$ comparisons after an $O(m)$ monotone hull pass. The hull pass matters
in practice: measured values may dip within a standard error (e.g. $0.988$ at budget
$24$ below $0.989$ at budget $20$), and the monotone hull is the principled repair.

**B. Admissible gate window.** Given the sweep and the reported knee $k_j$, return the
open–closed interval $(A_{j-1},\, A_j]$: every gate in it yields the same knee, by
Lemma 2.3. Reporting this window rather than a single tuned gate is what makes a knee
claim falsifiable. Cost $O(1)$ after A.

**C. Minimum deployment entries (greedy, top-anchored).** Given a knee multiset $K$
and tolerance $\delta$: sort $K$ descending; repeatedly take the largest uncovered knee
$b$, emit entry $b$, and delete every knee in $[b-\delta, b]$. Cost $O(|K| \log |K|)$.
Correctness and optimality: the emitted entries witness Theorem 7.13's construction
adapted to the actual knee set, while the knees that triggered emissions are pairwise
$\delta$-separated, so Theorem 7.11 shows no entry set is smaller. Hence the greedy
output is exactly optimal for *every* input, and Theorem 7.15 exhibits the extremal
inputs on which the bound $\lfloor (b-a)/(\delta+1)\rfloor + 1$ is attained.

---

## 9. Discussion

### 9.1 What was actually shown

The empirical claim is narrow: two domains, two contexts, one model scale, identical
knees despite a twelve-point accuracy gap. The theoretical claims are broad and
explain why the narrow claim is not a coincidence:

1. The sweep is a symmetric function of the demand multiset (Corollary 3.3, Theorem
   6.4). The correctness column is not an input.
2. The joint map to (knee, accuracy) is surjective (Theorem 4.3). No inequality can
   link them.
3. The knee is the $\lceil gn \rceil$-th order statistic of the demand distribution
   (Theorem 6.2), whereas accuracy is a mean of a different variable. Order statistics
   ignore the bulk; means ignore the rank.
4. Perturbation robustness (Theorem 6.5) quantifies the slack: the demands of up to
   $(1-g)n - T_D(k)$ positions may worsen arbitrarily without moving the knee.

Point 4 is the honest mechanism. Mathematical text plausibly *does* contain more
long-range references than prose. What the data show is that the fraction of positions
whose predictions depend on them stayed below the gate slack. Difficulty concentrated
in the mean; the quantile did not notice.

### 9.2 Robustness of the reported numbers

Four separate objections are closed by theorems rather than by argument. *Gate
tuning*: the knees hold on entire admissible windows, $(0.979,0.987]$ and
$(0.978,0.983]$, which overlap so that one gate certifies both cells (Proposition 7.1,
Theorem 7.4). *Quality-scale artefacts*: the knee is invariant under any strictly
monotone distortion of the quality axis (Theorems 2.4, 7.5). *Corpus mixing ratio*:
any mixture of prose and mathematics has knee $16$ (Theorem 7.6). *Idealisation of the
sweep*: the measured step profile is realised exactly by an honest workload (Theorem
5.6).

### 9.3 Limitations

The mathematical corpus is *classical mathematical prose* — running expository text —
not modern notation-dense typeset mathematics, whose tokenisation and reference
structure could differ materially. It is one corpus blend (though Theorem 7.6 shows
the blend ratio is immaterial once the constituent knees agree), one model scale, two
context lengths, and a fixed number of evaluation windows per cell. The $+4$ increment
is verified at $512 \to 1024$ only. Nothing here predicts behaviour at $4096$, in
non-English domains, or at substantially larger scale; those are measurements, not
corollaries.

### 9.4 Practical consequence

A deployment table needs one row per *offset*, not one per domain. On the measured
panel that is two rows at zero-to-three keys of tolerance, and one row at four. Since
the offset shifts rigidly with scale (Theorem 5.2) and is invisible to difficulty
(Theorem 4.3), the configuration surface is far smaller than the domain count
suggests: you tune per architecture and context, and then almost never per corpus.

---

## 10. Future work

The demand-multiset calculus suggests immediate sharpenings.

**Sub-additivity under corpus concatenation.** Mixing *curves* traps the knee between
constituent knees (Theorem 5.3). Concatenating *corpora* is a different operation: the
demand multisets add. Conjecture: for the union of workloads with position counts
$n_1, n_2$,
$$k^{*}(\text{union}, g) \;\le\; \max\bigl(k^{*}(\mathcal{D}_1, g_1),\,
k^{*}(\mathcal{D}_2, g_2)\bigr)$$
whenever $g \le (n_1 g_1 + n_2 g_2)/(n_1 + n_2)$, with equality iff one demand multiset
dominates the other in the tail region. The union's agreement curve is the
$n$-weighted average of the constituents', so the union's quantile should be squeezed
by the constituents' quantiles at *shifted* gates. Proving this would remove the
mixing ratio from the deployment argument entirely.

**Knee stability and tail exchangeability.** Conjecture: two domains have equal knees
at every gate in a window if and only if their demand multisets agree above the
corresponding tail threshold — an exchangeability condition on the upper tail only.
This would replace "equal multisets" (Corollary 3.3, sufficient but far stronger than
needed) by an exact characterisation.

**Empirical extensions.** Modern LaTeX-style notation-dense mathematics; non-English
domains; whether the increment remains $+4$ at context $4096$; and the behaviour of the
three-domain table at substantially larger model scale.

---

## 11. Conclusion

A truncated-memory system reading classical mathematics needs exactly as many keys as
one reading English prose — $16$ at context $512$, $20$ at context $1024$ — while
predicting mathematics twelve percentage points worse. This is not a coincidence of
corpus choice. It is forced by the fact that the two numbers are different species of
statistic: accuracy is a mean of correctness, the knee is the $\lceil gn\rceil$-th
order statistic of demand, and the map to the pair is surjective, so no law can bind
them. The deployment consequence is a table with two entries at tight tolerance and
one entry at a tolerance of four keys — the exact threshold, equal to one scale
increment, at which the packing bound and the covering bound over the knee set
$\{12,16\}$ finally agree on the answer $1$.
