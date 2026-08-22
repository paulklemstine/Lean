# Exact-Rate Batches, Splitting Trees and Largest-Lag Greedy: Fair Schedules for Arbitrary Positive Rate Profiles

**Author:** Aristotle
**Date:** 2026-08-22

## Abstract

A rate profile assigns to each of $k$ clients a positive integer rate $r_i$; the period is $R = \sum_{i<k} r_i$, and a schedule is a map $f$ from time slots $\{0,1,2,\dots\}$ to clients whose counters are $N_i(t) = \#\{u<t : f(u) = i\}$. The discrepancy of client $i$ at time $t$ is $D_i(t) = R\,N_i(t) - r_i t$, and $|D_i(t)|/R$ measures, in whole services, how far the client is from its entitlement. We give a complete analysis of three constructions, valid for *every* client count and *every* positive rate profile, without arithmetic hypotheses on the rates.

First, prefix sums cut one period into pairwise disjoint half-open batches $[P_i, P_{i+1})$ of exactly the prescribed sizes; repeating the tiling gives the *block schedule*, whose counter admits the exact closed form
$$N_i(t) = \lfloor t/R\rfloor\, r_i + \min\bigl(r_i,\, (t \bmod R) - P_i\bigr)^+ .$$
Every fairness property of the block schedule is a corollary of this identity: exactness at all multiples of the period, the **sharp** two-sided bound $-r_i P_i \le D_i(t) \le r_i (R - P_{i+1})$ with both ends attained, the fairness constant $\max_i r_i(R - r_i)$, and bounded waiting in every window of $R - r_i + 1$ slots. We show that with $k \ge 2$ positive rates *no* schedule is exact at all times, that the block schedule is exact precisely at multiples of the period, and that any $B$-fair schedule satisfies $B \ge R - r_{f(0)}$, from which round robin is optimal for the uniform profile.

Second, we show that the naive multi-client generalisation of the two-client Bresenham (Beatty) schedule — differencing floors of scaled prefix sums — is *not realisable by any schedule* for $k \ge 3$, although it coincides with Bresenham for $k = 2$; the profile $(3,1,3)$ produces a candidate counter that decreases.

Third, we introduce *splitting trees*: binary trees whose leaves are the clients and whose internal nodes split the slot stream by the two-client Bresenham rule. We prove that the recursive schedule of a well-formed splitting tree $T$ satisfies $|W N_i(t) - w_i t| \le W\cdot\operatorname{depth}(T)$, a bound that involves only the *shape* of the tree and not the rates. Balanced trees then give, for every $k$ and every positive profile, an explicit schedule of normalised discrepancy at most $\lceil \log_2 k\rceil$ — in contrast with the $\Theta(R)$ discrepancy of the block schedule already for the profile $(c,c)$.

Finally we analyse the online largest-lag greedy rule, prove that it never lets a client run a full period ahead ($D_i(t) \le R-1$) and is $(k-1)(R-1)$-fair, and report a computational refutation of the natural conjecture that it is unit-fair: the profile $(1,1,1,5,5,5)$ reaches normalised lag $19/18$, and the family $(1^m, c^m)$ pushes this towards $3/2$.

**Keywords:** fair scheduling, rate profile, discrepancy, prefix sums, Bresenham/Beatty sequences, splitting trees, largest-lag greedy, apportionment.

---

## 1. Introduction

A single indivisible resource must be handed out one slot at a time to $k$ competing clients whose entitlements are described by positive integer rates. The question is not whether long-run frequencies can be met — they trivially can — but how far from its entitlement a client can be forced at any finite time, and which constructions attain the optimum.

This problem is the common core of a surprising variety of subjects. In networking it is weighted round robin and deficit round robin. In operating systems it is proportional-share CPU scheduling. In manufacturing it is the *product rate variation* problem of mixed-model assembly lines. In political science it is *apportionment*: the "staying within quota" property of divisor methods is precisely a discrepancy bound. In number theory it is the theory of Beatty sequences and the Fraenkel conjecture on exact covers; in computer graphics it is Bresenham's line algorithm. The unifying object is a sequence over a finite alphabet whose letter frequencies must track prescribed real densities uniformly in time — a one-dimensional discrepancy problem with an integrality constraint.

Our contribution is a complete and hypothesis-free treatment of three constructions:

1. the **block schedule** built from prefix sums, with an exact closed-form counter from which sharp fairness and waiting-time bounds follow;
2. **splitting-tree schedules**, which achieve normalised discrepancy $\lceil \log_2 k\rceil$ for every profile, together with the proof that the naive nested-floor generalisation of Bresenham fails to be a schedule at all;
3. the online **largest-lag greedy** rule, with a proved one-sided unit bound and a computational refutation of the two-sided one.

Section 2 fixes notation. Section 3 develops the block schedule. Section 4 proves the impossibility results. Section 5 treats two clients. Section 6 gives the obstruction for the nested-floor construction. Section 7 develops splitting trees. Section 8 analyses greedy. Section 9 gives algorithms and complexity, Section 10 applications, Section 11 discussion and open problems.

---

## 2. Setting and definitions

**Definition 2.1 (Rate profile, prefix sums, period).** A *rate profile* on $k \ge 1$ clients is a $k$-tuple $r = (r_0,\dots,r_{k-1})$ of positive integers. Its prefix sums are
$$P_i \;=\; \sum_{j<i} r_j \quad (0 \le i \le k), \qquad P_0 = 0,$$
and its *period* (or total rate) is $R = P_k$. We always assume $R > 0$; positivity of the individual rates is assumed where stated.

**Definition 2.2 (Schedule, counter, discrepancy).** A *schedule* is a function $f : \mathbb{N} \to \mathbb{N}$; it is a schedule *on $k$ clients* if $f(t) < k$ for all $t$. Its counters are
$$N^f_i(t) \;=\; \#\{u < t : f(u) = i\},$$
so $N^f_i(0) = 0$, $N^f_i(t+1) = N^f_i(t) + [f(t) = i]$, each $N^f_i$ is non-decreasing, and $\sum_{i<k} N^f_i(t) = t$ when $f$ takes values below $k$.

The *discrepancy* of client $i$ at time $t$ is
$$D_i(t) \;=\; R\,N^f_i(t) - r_i\,t \;\in\; \mathbb{Z},$$
a positive value meaning the client is *ahead* (a lead) and a negative value meaning it is *behind* (a lag). Note the zero-sum identity
$$\sum_{i<k} D_i(t) \;=\; R\,t - R\,t \;=\; 0 . \tag{2.1}$$

**Definition 2.3 (Fairness).** A schedule $f$ is *$B$-fair* for the profile $(r,k)$ if
$$|D_i(t)| \;\le\; B \qquad \text{for all } i < k \text{ and all } t \in \mathbb{N}.$$
The *normalised discrepancy* of $f$ is $\sup_{i,t} |D_i(t)| / R$, measured in whole services. Fairness is scale-invariant in the sense that replacing $r$ by $m r$ multiplies both $R$ and $B$ by $m$.

**Definition 2.4 (Exactness).** A schedule is *exact at time $t$* if $R\,N_i(t) = r_i t$ for all $i < k$; equivalently $D_i(t) = 0$ for all $i$.

---

## 3. Exact-rate batches and the block schedule

### 3.1 Prefix sums tile a period

**Definition 3.1 (Batches).** For a profile $r$ put $B_i = [P_i, P_{i+1}) \cap \mathbb{Z} = \{P_i, \dots, P_{i+1}-1\}$.

**Proposition 3.2 (Exact-rate disjoint batches).** $|B_i| = r_i$; the batches $B_0,\dots,B_{k-1}$ are pairwise disjoint; and $\bigcup_{i<k} B_i = \{0,1,\dots,R-1\}$. Consequently $\sum_{i<k}|B_i| = R$.

*Proof sketch.* $|B_i| = P_{i+1} - P_i = r_i$. For $i < j$, every element of $B_i$ is $< P_{i+1} \le P_j$ by monotonicity of the prefix sums, and every element of $B_j$ is $\ge P_j$, so the two are disjoint. The union is the telescoping decomposition of $[P_0, P_k) = [0,R)$ at the cut points $P_1 < \dots < P_{k-1}$ (weakly increasing in general, strictly when the rates are positive). $\square$

**Definition 3.3 (Block index and block schedule).** For $0 \le s < R$ let $\beta(s)$ be the unique index $i < k$ with $s \in B_i$; equivalently $\beta(s) = \#\{i < k : P_{i+1} \le s\}$, the counting form that makes $\beta$ a manifest function of the prefix sums. The *block schedule* is
$$\mathrm{blk}(t) \;=\; \beta(t \bmod R),$$
and we write $N_i(t)$ for its counters when no confusion arises.

Uniqueness in Definition 3.3 is the statement that $P_i \le s < P_{i+1}$ pins down $i$, which follows from Proposition 3.2.

### 3.2 The closed-form counter

**Theorem 3.4 (Counter formula).** Let $R>0$ and $i<k$. For all $t \in \mathbb{N}$,
$$N_i(t) \;=\; \left\lfloor \frac{t}{R}\right\rfloor r_i \;+\; \min\bigl(r_i,\; (t \bmod R) - P_i\bigr)^{+}, \tag{3.1}$$
where $x^+ = \max(x,0)$ (equivalently, in truncated natural-number subtraction, $\min(r_i, (t\bmod R) \dot- P_i)$).

*Proof sketch.* Induction on $t$. At $t = 0$ both sides vanish. For the step, $N_i(t+1) = N_i(t) + [\mathrm{blk}(t) = i]$, and $\mathrm{blk}(t) = i$ holds exactly when $P_i \le t \bmod R < P_{i+1} = P_i + r_i$. Write $s = t \bmod R$ and split on the position of $s$: if $s < P_i$ the right-hand side of (3.1) is unchanged as $s$ increments and the indicator is $0$; if $P_i \le s < P_i + r_i$ the clamped term increases by exactly $1$ and the indicator is $1$; if $s \ge P_i + r_i$ the clamped term is saturated at $r_i$ and the indicator is $0$. The remaining case is the wrap $s = R-1 \mapsto 0$, where $\lfloor t/R\rfloor$ increases by $1$ and the clamped term drops from $r_i$ to $0$, so the total is unchanged apart from the $+r_i$ that the completed period contributes; the arithmetic identity $R\lfloor t/R\rfloor + (t \bmod R) = t$ and $P_i + r_i \le R$ close the case analysis. $\square$

Theorem 3.4 is the engine of the entire section: each result below is obtained by substituting a specific $t$ into (3.1) and doing integer arithmetic.

**Corollary 3.5 (Exactness at period boundaries).** $N_i(nR) = n\,r_i$ for all $n$, hence $D_i(nR) = 0$.

*Proof sketch.* Put $t = nR$ in (3.1): $\lfloor t/R\rfloor = n$ and $t \bmod R = 0 \le P_i$, so the clamped term is $0$. $\square$

**Theorem 3.6 (Sharp two-sided discrepancy bound).** For $R>0$, $i<k$ and all $t$,
$$-\,r_i\,P_i \;\le\; D_i(t) \;\le\; r_i\,(R - P_{i+1}). \tag{3.2}$$
Moreover both bounds are attained: $D_i(P_i) = -r_i P_i$ and $D_i(P_{i+1}) = r_i (R - P_{i+1})$.

*Proof sketch.* Write $t = Rq + s$ with $0\le s<R$ and $c = \min(r_i, (s - P_i)^+)$, so that by (3.1) $N_i(t) = q r_i + c$ and
$$D_i(t) \;=\; R\,(q r_i + c) - r_i (Rq + s) \;=\; R\,c - r_i\,s .$$
The complete periods cancel exactly — this is the point of the closed form. Now three cases. If $s \le P_i$ then $c = 0$ and $D_i(t) = -r_i s \in [-r_i P_i, 0]$. If $P_i \le s \le P_{i+1}$ then $c = s - P_i$ and $D_i(t) = R(s-P_i) - r_i s = (R - r_i)s - R P_i$, which is non-decreasing in $s$ (as $r_i \le R$), hence lies between its values at $s = P_i$, namely $-r_i P_i$, and at $s = P_{i+1}$, namely $r_i (R - P_{i+1})$. If $s \ge P_{i+1}$ then $c = r_i$ and $D_i(t) = r_i(R - s)$, decreasing in $s$, hence between $0$ and $r_i (R - P_{i+1})$. Attainment: $t = P_i$ gives $N_i = 0$, and $t = P_{i+1}$ gives $N_i = r_i$, by (3.1). $\square$

The interpretation is exact and pleasant: **a client's worst lag is its own rate times the total mass scheduled before it, and its worst lead is its rate times the total mass scheduled after it.**

**Corollary 3.7 (Absolute bound and fairness constant).** $|D_i(t)| \le r_i\,(R - r_i)$ for all $t$, and therefore the block schedule is $B$-fair with
$$B \;=\; \max_{i<k}\; r_i\,(R - r_i).$$

*Proof sketch.* In (3.2), $r_i P_i \le r_i (R - r_i)$ because $P_i + r_i = P_{i+1} \le R$, and likewise $r_i(R - P_{i+1}) \le r_i(R - r_i)$ because $P_{i+1} \ge r_i$. Take the maximum over clients. $\square$

For the balanced two-client profile $(c,c)$, Corollary 3.7 gives $B = c^2$ and Theorem 3.6 shows this is attained, so the normalised discrepancy of the block schedule is $c/2$: unbounded.

**Theorem 3.8 (No starvation; sharp waiting window).** If $r_i > 0$ then for every $t$ there is $s$ with $t \le s < t + (R - r_i + 1)$ and $\mathrm{blk}(s) = i$. The window length $R - r_i + 1$ cannot be shortened, since the block schedule serves client $i$ in one contiguous run of length $r_i$ per period.

*Proof sketch.* Let $s_0 = t \bmod R$ and $q = \lfloor t/R\rfloor$. If $s_0 < P_i$, the slot $Rq + P_i$ works; if $P_i \le s_0 < P_{i+1}$, the slot $t$ itself works; if $s_0 \ge P_{i+1}$, the slot $R(q+1) + P_i$ works, and in each case the displacement from $t$ is at most $R - r_i$ because the gap between consecutive service runs of client $i$ is exactly $R - r_i$. $\square$

**Theorem 3.9 (Round robin and self-similarity).**
(i) For the uniform profile $r \equiv 1$ on $k$ clients, $\mathrm{blk}(t) = t \bmod k$.
(ii) For $m \ge 1$, the block schedule of the scaled profile $m r$ satisfies $\mathrm{blk}_{mr}(t) = \mathrm{blk}_r(\lfloor t/m\rfloor)$: multiplying all rates by $m$ slows the schedule by exactly the factor $m$.

*Proof sketch.* (i) $P_i = i$ and $R = k$, so $\beta(s) = s$. (ii) $P^{mr}_i = m P_i$, so $P^{mr}_i \le s \iff P_i \le \lfloor s/m\rfloor$, whence $\beta_{mr}(s) = \beta_r(\lfloor s/m \rfloor)$; combine with $\lfloor (t \bmod mR)/m\rfloor = \lfloor t/m\rfloor \bmod R$. $\square$

---

## 4. Impossibility and optimality

**Theorem 4.1 (No exact schedule).** Let $k \ge 2$ and let all rates be positive. Then there is no schedule $f$ on $k$ clients with $R\,N^f_i(t) = r_i t$ for all $i<k$ and all $t$.

*Proof sketch.* Let $j = f(0)$. Then $N^f_j(1) = 1$, so exactness at $t=1$ forces $R = r_j$. But there is some $j' \ne j$ with $j' < k$, and $r_j + r_{j'} \le R$ with $r_{j'} > 0$ gives $r_j < R$, a contradiction. $\square$

**Theorem 4.2 (The block schedule is exact exactly at period boundaries).** Let $k \ge 2$ with all rates positive. Then the block schedule is exact at time $t$ if and only if $R \mid t$.

*Proof sketch.* Sufficiency is Corollary 3.5. Conversely, suppose $0 < s = t \bmod R < R$ and the schedule is exact at $t$. By the computation in Theorem 3.6, exactness for client $i$ means $R c_i = r_i s$ with $c_i = \min(r_i, (s-P_i)^+)$. Client $\beta(s)$, whose block contains $s$, and any other client with positive rate cannot both satisfy this: for a client entirely before $s$ one gets $R r_i = r_i s$, i.e. $s = R$; for a client entirely after $s$ one gets $0 = r_i s$, i.e. $s = 0$. Since $k \ge 2$ there is at least one client other than $\beta(s)$ and it falls into one of these two cases, a contradiction. $\square$

**Theorem 4.3 (Universal fairness lower bound).** If $f$ is a schedule on $k$ clients and $f$ is $B$-fair for $(r,k)$, then $B \ge R - r_{f(0)}$. In particular $B \ge \min_{i<k}(R - r_i)$.

*Proof sketch.* $N^f_{f(0)}(1) = 1$, so $D_{f(0)}(1) = R - r_{f(0)}$, and $B$-fairness at $t = 1$ gives the claim. $\square$

**Corollary 4.4 (Optimality of round robin).** For the uniform profile on $k$ clients, the block schedule (i.e. round robin) is $(k-1)$-fair, and every schedule on $k$ clients that is $B$-fair satisfies $B \ge k-1$.

*Proof sketch.* Corollary 3.7 with $r_i = 1$, $R = k$, gives $B = k-1$; Theorem 4.3 with $r_{f(0)} = 1$ gives $B \ge k-1$. $\square$

Thus for the uniform profile the exact optimum is known, and the elementary schedule attains it. For non-uniform profiles the block schedule is far from optimal, as Sections 5 and 7 show.

---

## 5. Two clients: the Bresenham schedule

**Definition 5.1.** For $0 \le a \le R$ with $R>0$, the *Bresenham schedule* $\mathrm{bres}_{a,R}$ serves client $0$ in slot $t$ if $\lfloor ta/R\rfloor < \lfloor (t+1)a/R\rfloor$ and client $1$ otherwise. It is the schedule of the two-client profile $(a, R-a)$.

**Proposition 5.2 (Counters are Beatty staircases).** $N_0(t) = \lfloor ta/R \rfloor$ and $N_1(t) = t - \lfloor ta/R\rfloor$ for all $t$.

*Proof sketch.* Induction on $t$: the increment of $\lfloor ta/R\rfloor$ is $0$ or $1$ because $a \le R$, and the rule serves client $0$ exactly when that increment is $1$. The second identity follows since exactly one client is served per slot. $\square$

**Theorem 5.3 (Unit discrepancy).** $\mathrm{bres}_{a,R}$ is $(R-1)$-fair for $(a, R-a)$: for both clients and all $t$,
$$\bigl| R\,N_i(t) - r_i\,t \bigr| \;\le\; R-1 .$$

*Proof sketch.* With $ta = R\lfloor ta/R\rfloor + \rho$, $0 \le \rho \le R-1$, one has $R N_0(t) - a t = -\rho \in [-(R-1),0]$ and, using $N_1 = t - N_0$ and $r_1 = R-a$, $R N_1(t) - (R-a)t = \rho \in [0, R-1]$. $\square$

**Theorem 5.4 (Separation from the block schedule).** For $c \ge 2$ and the profile $(c,c)$ (so $R = 2c$), the Bresenham schedule is $(R-1)$-fair while the block schedule is not: at $t = c$ the block schedule has $D_0(c) = c^2 > R-1$.

*Proof sketch.* $N^{\mathrm{blk}}_0(c) = c$ by Theorem 3.4, so $D_0(c) = 2c\cdot c - c\cdot c = c^2$, and $c^2 > 2c-1$ for $c \ge 2$. $\square$

**Theorem 5.5 (Sharp waiting bounds).** For $0 < a \le R$, client $0$ is served at least once in every window of $\lceil R/a\rceil$ consecutive slots; for $a < R$, client $1$ is served at least once in every window of $\lceil R/(R-a)\rceil$ consecutive slots.

*Proof sketch.* Over a window of length $g = \lceil R/a\rceil$ the quantity $\lfloor ta/R \rfloor$ increases, because $g a \ge R$ implies $\lfloor (t+g)a/R\rfloor \ge \lfloor (ta + R)/R\rfloor = \lfloor ta/R\rfloor + 1$; an increase of the counter forces a service inside the window. The second statement is symmetric, exchanging the roles of the two clients. $\square$

**Theorem 5.6 (Periodicity and exactness).** $\mathrm{bres}_{a,R}(t+R) = \mathrm{bres}_{a,R}(t)$, and $N_0(nR) = na$, $N_1(nR) = n(R-a)$.

*Proof sketch.* $(t+R)a/R = ta/R + a$ with $a$ an integer, so the two floors defining the rule shift by the same integer. $\square$

---

## 6. The nested-floor obstruction for $k \ge 3$

Since the two-client counters are differences of floors, one is tempted to define, for a general profile,
$$\widehat N_i(t) \;=\; \left\lfloor \frac{t\,P_{i+1}}{R}\right\rfloor - \left\lfloor \frac{t\,P_i}{R}\right\rfloor . \tag{6.1}$$
These "nested floors" have the correct long-run frequencies, telescope to $\sum_i \widehat N_i(t) = t$, and reduce to Bresenham for $k=2$.

**Proposition 6.1 ($k=2$).** For the profile $(a, R-a)$ one has $\widehat N_i(t) = N^{\mathrm{bres}}_i(t)$ for $i \in \{0,1\}$ and all $t$.

*Proof sketch.* $P_1 = a$, $P_2 = R$, so $\widehat N_0(t) = \lfloor ta/R\rfloor - 0$ and $\widehat N_1(t) = t - \lfloor ta/R\rfloor$; apply Proposition 5.2. $\square$

**Theorem 6.2 (Obstruction).** There is a profile with $k = 3$ and all rates positive such that no schedule $f$ satisfies $N^f_i(t) = \widehat N_i(t)$ for all $i<3$ and all $t$. Explicitly, for $r = (3,1,3)$ (so $R = 7$, $P = (0,3,4,7)$),
$$\widehat N_1(2) = \left\lfloor \tfrac{8}{7}\right\rfloor - \left\lfloor \tfrac{6}{7}\right\rfloor = 1, \qquad \widehat N_1(3) = \left\lfloor \tfrac{12}{7}\right\rfloor - \left\lfloor \tfrac{9}{7}\right\rfloor = 0 .$$

*Proof sketch.* Counters of schedules are non-decreasing in $t$; the displayed values decrease. $\square$

Conceptually, $\widehat N_i$ counts the jumps of the Beatty sequence of slope $P_{i+1}/R$ minus those of slope $P_i/R$; a *simultaneous* jump of the two staircases makes the difference fall. Whether such collisions occur is a purely arithmetic property of the pair $(P_i, P_{i+1}, R)$, which suggests a classification problem (Section 11). The practical consequence is that the multi-client theory must be built differently — which is what splitting trees do.

---

## 7. Splitting trees: logarithmic discrepancy for every profile

**Definition 7.1 (Splitting tree).** A *splitting tree* is a finite binary tree $T$ whose leaves carry a client label $i$ and a rate $w$: $T ::= \mathrm{leaf}(i,w) \mid \mathrm{node}(T_\ell, T_r)$. Define
- the *weight* $\mathrm{wt}(\mathrm{leaf}(i,w)) = w$, $\mathrm{wt}(\mathrm{node}(T_\ell,T_r)) = \mathrm{wt}(T_\ell) + \mathrm{wt}(T_r)$;
- the *depth* $\operatorname{depth}(\mathrm{leaf}) = 0$, $\operatorname{depth}(\mathrm{node}(T_\ell,T_r)) = 1 + \max(\operatorname{depth} T_\ell, \operatorname{depth} T_r)$;
- the *label set* $\mathrm{lab}(\mathrm{leaf}(i,w)) = \{i\}$, $\mathrm{lab}(\mathrm{node}) = \mathrm{lab}(T_\ell)\cup\mathrm{lab}(T_r)$;
- the *rate of a label*, $\mathrm{rate}_T(j) = w\,[j=i]$ at a leaf and the sum of the children's values at a node.

$T$ is *well formed* if every leaf rate is positive and the label sets of the two children of each node are disjoint (so each client occurs at most once).

**Definition 7.2 (Recursive Bresenham schedule of a tree).**
$$\mathrm{sch}_{\mathrm{leaf}(i,w)}(t) = i, \qquad
\mathrm{sch}_{\mathrm{node}(T_\ell,T_r)}(t) =
\begin{cases}
\mathrm{sch}_{T_\ell}\!\left(\left\lfloor \tfrac{t\,\mathrm{wt}(T_\ell)}{W}\right\rfloor\right) & \text{if } \mathrm{bres}_{\mathrm{wt}(T_\ell),\,W}(t) = 0,\\[4pt]
\mathrm{sch}_{T_r}\!\left(t - \left\lfloor \tfrac{t\,\mathrm{wt}(T_\ell)}{W}\right\rfloor\right) & \text{otherwise,}
\end{cases}$$
where $W = \mathrm{wt}(T_\ell) + \mathrm{wt}(T_r)$.

The definition says: the two-client Bresenham rule with rates $(\mathrm{wt}(T_\ell), \mathrm{wt}(T_r))$ decides which subtree owns the slot, and the chosen subtree sees the slot on its *own* clock — the left subtree's local time is $\lfloor t\,\mathrm{wt}(T_\ell)/W\rfloor$, which by Proposition 5.2 is exactly the number of slots it has received so far, and symmetrically for the right subtree. Consequently the counters compose:
$$N^{\mathrm{sch}_T}_i(t) = N^{\mathrm{sch}_{T_\ell}}_i\!\left(\left\lfloor \tfrac{t\,\mathrm{wt}(T_\ell)}{W}\right\rfloor\right) \quad (i \in \mathrm{lab}(T_\ell)), \tag{7.1}$$
and symmetrically on the right. Identity (7.1) is the technical heart of the construction: it turns the schedule into an honest recursion on subtrees.

**Theorem 7.3 (Splitting-tree discrepancy).** Let $T$ be a well-formed splitting tree with weight $W$. Then for every label $i$ and every $t$,
$$\bigl| W\,N^{\mathrm{sch}_T}_i(t) - \mathrm{rate}_T(i)\,t \bigr| \;\le\; W \cdot \operatorname{depth}(T).$$
Equivalently, the normalised discrepancy of $\mathrm{sch}_T$ is at most $\operatorname{depth}(T)$ — a bound depending only on the *shape* of the tree, never on the rates.

*Proof sketch.* Induction on $T$. For a leaf, $N_i(t) = t\,[i = \text{label}]$ and the discrepancy is $0 = W\cdot 0$. For a node with children of weights $A = \mathrm{wt}(T_\ell)$, $B = \mathrm{wt}(T_r)$, $W = A+B$, take $i \in \mathrm{lab}(T_\ell)$ (the other case is symmetric) and let $m = \lfloor tA/W\rfloor$ be the left subtree's local time, $w = \mathrm{rate}_{T_\ell}(i)$, $c = N^{\mathrm{sch}_{T_\ell}}_i(m)$. Two estimates combine:

* by Theorem 5.3, the *node* is fair to the whole left subtree: $|W m - A t| \le W - 1$, i.e. the left subtree receives its share of slots up to one slot;
* by the induction hypothesis applied to $T_\ell$: $|A c - w\, m| \le A\cdot \operatorname{depth}(T_\ell)$.

The two estimates combine through the exact identity
$$A\,(W c - w t) \;=\; W\,(A c - w m) \;+\; w\,(W m - A t),$$
which one checks by expanding both sides. Taking absolute values and using $w \le A$,
$$A\,\bigl|W c - w t\bigr| \;\le\; W\,\bigl|A c - w m\bigr| + w\,\bigl|W m - A t\bigr| \;\le\; W A \operatorname{depth}(T_\ell) + A (W-1),$$
whence $|Wc - wt| \le W\operatorname{depth}(T_\ell) + (W-1) < W(\operatorname{depth}(T_\ell) + 1) \le W \operatorname{depth}(T)$. The single splitting level therefore costs strictly less than one additional unit of normalised discrepancy, and the errors accumulate additively along a root-to-leaf path rather than multiplicatively. $\square$

**Definition 7.4 (Balanced trees).** For a rate function $w$ and integers $\mathrm{base}, n$ with $n \ge 1$ let
$$\mathrm{bal}(w,\mathrm{base},1) = \mathrm{leaf}(\mathrm{base}, w_{\mathrm{base}}), \qquad
\mathrm{bal}(w,\mathrm{base},n) = \mathrm{node}\bigl(\mathrm{bal}(w,\mathrm{base},\lfloor n/2\rfloor),\, \mathrm{bal}(w,\mathrm{base}+\lfloor n/2\rfloor, \lceil n/2\rceil)\bigr)$$
for $n \ge 2$. The *perfect* tree $\mathrm{perf}(w,d,\mathrm{base})$ over $2^d$ clients is the special case in which every split is exactly in half.

**Lemma 7.5.** $\mathrm{bal}(w,\mathrm{base},n)$ is well formed whenever the rates $w_{\mathrm{base}},\dots,w_{\mathrm{base}+n-1}$ are positive; its label set is $\{\mathrm{base},\dots,\mathrm{base}+n-1\}$; its weight is $\sum_{j=\mathrm{base}}^{\mathrm{base}+n-1} w_j$; its rate function agrees with $w$ on its labels; and $\operatorname{depth} \mathrm{bal}(w,\mathrm{base},n) \le \lceil \log_2 n\rceil$. For the perfect tree over $2^d$ clients the depth is exactly $d$.

*Proof sketch.* Strong induction on $n$: the two halves have disjoint index ranges (hence disjoint labels), their weights add, and $\max(\lceil \log_2\lfloor n/2\rfloor\rceil, \lceil\log_2\lceil n/2\rceil\rceil) + 1 \le \lceil \log_2 n\rceil$ for $n \ge 2$. $\square$

**Theorem 7.6 (Logarithmic fairness for every profile).** For every $k \ge 1$ and every profile of positive rates $r$, the schedule $\mathrm{sch}_{\mathrm{bal}(r,0,k)}$ is $B$-fair with
$$B \;=\; R\cdot \lceil \log_2 k\rceil,$$
i.e. its normalised discrepancy is at most $\lceil \log_2 k \rceil$.

*Proof sketch.* Combine Theorem 7.3 with Lemma 7.5, noting $\mathrm{wt} = R$ and $\mathrm{rate} = r$ on the labels $\{0,\dots,k-1\}$. $\square$

**Corollary 7.7.** Three clients with arbitrary positive rates admit an explicit schedule of normalised discrepancy at most $2$; four clients likewise (using the perfect tree of depth $2$); $2^d$ clients admit one of normalised discrepancy at most $d$.

The contrast with Section 3 is stark: the block schedule's normalised discrepancy is $\Theta(R)$ already for $(c,c)$, whereas the tree schedule's bound is a function of $k$ alone. Numerically, the tree bound is not tight — e.g. the profile $(1,1,1,97)$ has $\lceil\log_2 4\rceil = 2$ and realises $1.94$, while $(1,1,1)$ realises $0.67$ against a bound of $2$ — but it is uniform over all profiles, which is exactly what no rate-based construction achieves.

---

## 8. The online largest-lag greedy rule

The tree schedule is computed offline from the profile. The classical online alternative is:

**Definition 8.1 (Greedy largest-lag).** Given counters $N_i(t)$, serve at slot $t$ a client maximising the objective
$$\mathrm{obj}_i(t) \;=\; r_i\,(t+1) - R\,N_i(t),$$
with ties broken by smallest index. Write $\mathrm{lag}_i(t) = r_i t - R N_i(t) = -D_i(t)$, so $\mathrm{obj}_i(t) = \mathrm{lag}_i(t) + r_i$.

**Lemma 8.2 (Zero-sum identities).** $\sum_{i<k}\mathrm{lag}_i(t) = 0$ and $\sum_{i<k}\mathrm{obj}_i(t) = R$ for all $t$.

*Proof sketch.* The counters sum to $t$ and the rates sum to $R$; substitute. $\square$

**Lemma 8.3 (The served client is owed at least one unit).** If $R > 0$ and $k \ge 1$ then $\mathrm{obj}_{p(t)}(t) \ge 1$, where $p(t)$ is the client chosen by the greedy rule.

*Proof sketch.* By Lemma 8.2 the $k$ objective values sum to $R \ge 1$; if the maximum were $\le 0$ the sum would be $\le 0$. Hence the maximum, attained at $p(t)$, is $\ge 1$. $\square$

**Theorem 8.4 (No client ever leads by a full period).** For every profile with $R>0$ and every $i, t$,
$$\mathrm{lag}_i(t) \;\ge\; -(R-1), \qquad \text{equivalently} \qquad D_i(t) \;\le\; R-1 .$$

*Proof sketch.* Induction on $t$; at $t=0$ all lags vanish. For the step, $\mathrm{lag}_i(t+1) = \mathrm{obj}_i(t) - R\,[i = p(t)]$. If $i \ne p(t)$ then $\mathrm{lag}_i(t+1) = \mathrm{lag}_i(t) + r_i \ge \mathrm{lag}_i(t) \ge -(R-1)$. If $i = p(t)$ then $\mathrm{lag}_i(t+1) = \mathrm{obj}_i(t) - R \ge 1 - R$ by Lemma 8.3. $\square$

**Theorem 8.5 (Two-sided bound; greedy is $(k-1)(R-1)$-fair).** For $k \ge 2$, $R>0$, all $i<k$ and all $t$,
$$\mathrm{lag}_i(t) \;\le\; (k-1)(R-1), \qquad \text{hence} \qquad |D_i(t)| \;\le\; (k-1)(R-1).$$

*Proof sketch.* By Lemma 8.2, $\mathrm{lag}_i(t) = -\sum_{j\ne i} \mathrm{lag}_j(t)$, and each of the $k-1$ terms is $\ge -(R-1)$ by Theorem 8.4. $\square$

**Theorem 8.6 (Separation from the block schedule).** For the profile $(c,c)$ with $c \ge 2$, greedy satisfies $D_i(t) \le R-1$ for all $i,t$, while the block schedule has $D_0(c) = c^2 > R-1$.

*Proof sketch.* Theorem 8.4 and Theorem 5.4. $\square$

### 8.1 Greedy is not unit-fair

Theorem 8.4 gives the *lead* side of a would-be unit-fairness statement, and it is tight up to $1$: the natural conjecture is that greedy also satisfies $\mathrm{lag}_i(t) \le R-1$, i.e. normalised discrepancy strictly below one service for every $k$ and every profile — the multi-client analogue of Theorem 5.3. Small profiles support it: over an exhaustive sweep of all primitive profiles with $k \le 6$ and rates $\le 6$, most maxima are well below $1$.

The conjecture is nevertheless false. Direct simulation of Definition 8.1 on the profile
$$r = (1,1,1,5,5,5), \qquad R = 18, \qquad k = 6,$$
gives the state $N(11) = (1,1,1,3,3,2)$ at $t = 11$, whence
$$\mathrm{lag}_5(11) \;=\; 5\cdot 11 - 18\cdot 2 \;=\; 19 \;>\; 18 \;=\; R,$$
a normalised lag of $19/18 \approx 1.056$. (The lead bound $D_i(t)\le 17$ of Theorem 8.4 is respected throughout, as it must be.) The failure is systematic. For the two-block family $r = (1^m, c^m)$ the observed normalised discrepancy increases monotonically in both $m$ and $c$: $1.056$ at $(m,c) = (3,5)$; $1.25$ at $(6,9)$; $1.325$ at $(12,9)$; $1.422$ at $(20,50)$; $1.438$ at $(30,50)$ — approaching, but apparently never reaching, $3/2$.

The mechanism is visible in the data: the many rate-$1$ clients are individually cheap to keep happy, so the objective favours the heavy clients, and the heavy clients then round-robin among themselves, letting the last of them slip nearly two heavy-cycles behind before the objective forces a correction. Consequently we replace the unit-fairness conjecture by:

**Conjecture 8.7 (Universal constant for greedy).** There is an absolute constant $C$ — conjecturally $C = 3/2$, not attained — such that for every $k$, every positive rate profile and every $t$, the greedy largest-lag schedule satisfies $|D_i(t)| < C\,R$.

Note that even $C = O(1)$ would be a substantial strengthening of Theorem 8.5, whose bound $(k-1)(R-1)$ degrades with $k$; and any such bound would place greedy in the same regime as the splitting-tree schedules, but *online*.

---

## 9. Algorithms and complexity

We record the three schedules as algorithms. Throughout, $k$ is the number of clients and $R$ the period; arithmetic is on integers of size $O(\log(Rt))$.

**(A) Block schedule by prefix sums.** Precompute $P_0,\dots,P_k$ in $O(k)$ time. To answer "who owns slot $t$?", compute $s = t \bmod R$ and binary search for the unique $i$ with $P_i \le s < P_{i+1}$: $O(\log k)$ per slot, $O(k)$ memory. The counter of any client at any time is available in $O(1)$ from the closed form (3.1) — no simulation required, so the schedule supports random access into the arbitrarily distant future.

**(B) Splitting-tree schedule.** Build the balanced tree in $O(k)$ time and store subtree weights. To answer "who owns slot $t$?", walk from the root: at a node with weights $(A,B)$ and current local time $\tau$, compute $m = \lfloor \tau A/(A+B)\rfloor$ and $m' = \lfloor (\tau+1)A/(A+B)\rfloor$; if $m < m'$ descend left with local time $m$, else descend right with local time $\tau - m$. The walk costs $O(\operatorname{depth}) = O(\log k)$ integer multiplications and divisions per slot, with $O(k)$ memory, and — like (A) — needs no history: slot $t$ can be answered without computing slots $< t$. Guarantee: normalised discrepancy $\le \lceil \log_2 k\rceil$ (Theorem 7.6).

**(C) Greedy largest-lag.** Maintain the counters. Each slot, select $\arg\max_i\, (r_i(t+1) - R N_i(t))$: $O(k)$ per slot naively, or $O(\log k)$ per slot with a priority queue keyed by $\mathrm{lag}_i(t) + r_i$, since serving a client decreases its key by exactly $R$ and all keys grow by their own $r_i$ each slot (implement the common drift by storing $\mathrm{lag}_i(t) - $ a global offset, or equivalently by keying on the *virtual finish time* $R N_i / r_i$, which is the standard weighted-fair-queueing trick). Guarantees: $D_i(t) \le R-1$ always (Theorem 8.4) and $|D_i(t)| \le (k-1)(R-1)$ (Theorem 8.5); it is stateful, so it cannot answer a query about a far-future slot without simulating.

The three occupy distinct points on the trade-off curve:

| Schedule | Exact at | Normalised discrepancy | Per-slot cost | Random access |
|---|---|---|---|---|
| Block (prefix sums) | every multiple of $R$ (and only there) | $\max_i r_i(R-r_i)/R$, i.e. $\Theta(R)$ in the worst case | $O(\log k)$ | yes |
| Splitting tree | at multiples of $R$ | $\le \lceil\log_2 k\rceil$, independent of rates | $O(\log k)$ | yes |
| Greedy | at multiples of $R$ | lead $< 1$ always; lag $\le k-1$ proved, $\approx 1.44$ observed | $O(\log k)$ amortised | no |

---

## 10. Applications

**Packet scheduling and weighted fair queueing.** With $r_i$ the weight of flow $i$, $D_i(t)$ is exactly the *service lag* used to define fairness in the deficit-round-robin literature. Theorem 3.6 quantifies precisely why "give each flow its quantum in turn" (the block schedule) is bursty: the burst is $r_i P_i$, the mass ahead of the flow in the cycle. Theorem 7.6 says a hierarchical scheduler — a balanced tree of two-way splits — bounds burstiness by $\lceil\log_2 k\rceil$ packets regardless of how skewed the weights are; hierarchical schedulers are used in practice for exactly this reason, and the theorem gives a clean worst-case justification.

**Mixed-model assembly lines (product rate variation).** Given demands $r_i$ for $k$ product variants over a shift of $R$ units, one wants a launch sequence whose cumulative production tracks the demand ratios. $|D_i(t)|/R$ is precisely the "maximum deviation" objective. Theorem 4.1 says the deviation cannot be zero; Theorem 4.3 gives a universal lower bound; the tree schedule gives a constructive $\lceil\log_2 k\rceil$ guarantee for arbitrary demands.

**Apportionment.** Interpreting $t$ as a house size and $r_i$ as populations, $N_i(t)$ is a seat allocation and $|D_i(t)| < R$ is exactly the classical "staying within quota" condition. Theorem 8.4 says the greedy largest-lag (= largest-remainder-style) method never exceeds the upper quota, while Section 8.1 exhibits explicit populations for which it violates the lower quota — the discrete phenomenon behind the well-known incompatibility between quota and population monotonicity in apportionment theory.

**Real-time and CPU scheduling.** For periodic tasks with rates $r_i/R$, the *pfair* fairness criterion is $|D_i(t)| < R$. Theorem 8.4 gives half of pfairness for the greedy rule at no cost, and the splitting tree yields a deterministic, precomputable schedule whose worst-case error grows only logarithmically in the number of tasks.

**Cache and stride scheduling.** Stride scheduling assigns each client a stride $R/r_i$ and serves the smallest virtual time — the same object as greedy in disguise. The counterexample of Section 8.1 shows that the frequently-quoted "within one service" folklore claim for stride scheduling fails for $k \ge 6$ with a two-scale weight distribution.

---

## 11. Discussion and open problems

Three principles emerge.

*Prefix sums are the right coordinates.* The batch decomposition, the closed-form counter, the sharp two-sided bounds, the waiting-window length, and the nested-floor obstruction are all statements about the position of $t \bmod R$ relative to the cut points $P_i$.

*Exactness and smoothness are inequivalent and quantifiably so.* No schedule is exact at all times (Theorem 4.1); the schedule that is exact as often as possible pays $\Theta(R)$ in discrepancy (Theorem 3.6, Theorem 5.4); the smooth schedules pay nothing in discrepancy and gain exactness only at multiples of the period.

*Fairness is a property of decomposition, not of arithmetic.* The bound $\lceil\log_2 k\rceil$ holds with no hypotheses on the rates because the construction recursively halves the *client set*. This is why the naive rate-based generalisation of Bresenham fails (Theorem 6.2) while the tree-based one succeeds.

Open problems, roughly in order of appeal.

1. **The constant for greedy (Conjecture 8.7).** Is there an absolute $C$ with $|D_i(t)| < CR$ for the greedy rule, and is $C = 3/2$? The lead side is settled (Theorem 8.4); the lag side is the negated sum of the other leads, which yields $(k-1)(R-1)$ for free, so the whole problem is to quantify the cancellation among leads. A potential function on the sorted lag vector, or an amortised argument tracking the multiset of lags of the "heavy" clients, appears to be the right tool, and the family $(1^m, c^m)$ is the extremal candidate to beat.

2. **A schedule of normalised discrepancy $< 1$ for all profiles?** For $k=2$ it exists (Theorem 5.3), for general $k$ our best constructive bound is $\lceil\log_2 k\rceil$. Is there, for every $k$ and every positive profile, a schedule with $|D_i(t)| \le R - 1$? Known results on the *chairman assignment problem* suggest a bound close to $1$ should be attainable; making it constructive and hypothesis-free is open here.

3. **Rate-profile classification of nested-floor schedulability.** For which profiles is the nested-floor counter (6.1) realisable? A drop of $\widehat N_i$ is exactly a simultaneous increment of the Beatty sequences of slopes $P_i/R$ and $P_{i+1}/R$; realisability should therefore be equivalent to an arithmetic non-collision condition on $\gcd(P_i, R)$ and the residues of $P_i s$ modulo $R$ for $s$ in a prescribed interval. A clean iff-statement would characterise exactly which multi-client profiles admit "pure Beatty" schedules, connecting to the Fraenkel conjecture on exact covers by Beatty sequences.

4. **Optimal tree shapes.** Theorem 7.3 charges one unit of discrepancy per level, so the natural optimisation is to minimise the *weighted* depth: a Huffman-style tree with the heavy clients near the root should beat the balanced tree for skewed profiles. Is $\lceil \log_2 k\rceil$ improvable to something like the entropy $H(r/R)$ of the normalised profile? Our numerics on $(1,1,1,97)$ (bound $2$, realised $1.94$) suggest the balanced tree is not optimal for skewed rates.

5. **Lower bounds beyond the first slot.** Theorem 4.3 uses only $t=1$. What is the true minimum over all schedules of the worst-case normalised discrepancy for a given profile? For the uniform profile it is $(k-1)/k$ (Corollary 4.4). A matching general lower bound — presumably of the form $\max_i (1 - r_i/R)$ up to constants — would close the gap with the tree construction for small $k$.

6. **Multi-resource and dynamic profiles.** All of the above is one server with fixed rates. The counter formula (3.1) extends verbatim to $m$ identical parallel servers by scaling time; what happens to the sharp bounds, and to the tree construction, when clients arrive and depart (so $R$ changes) is open even for $k=2$.

---

## 12. Summary of results

- **Exact-rate batches.** Prefix sums cut $\{0,\dots,R-1\}$ into pairwise disjoint batches of sizes exactly $r_0,\dots,r_{k-1}$ (Proposition 3.2).
- **Closed-form counter.** $N_i(t) = \lfloor t/R\rfloor r_i + \min(r_i, (t\bmod R) - P_i)^+$ for the block schedule (Theorem 3.4).
- **Sharp discrepancy.** $-r_i P_i \le D_i(t) \le r_i(R - P_{i+1})$, both attained (Theorem 3.6); fairness constant $\max_i r_i(R-r_i)$ (Corollary 3.7).
- **Exactness.** $D_i(nR) = 0$ always (Corollary 3.5); with $k \ge 2$ positive rates the block schedule is exact *only* at multiples of $R$ (Theorem 4.2) and no schedule whatsoever is exact at all times (Theorem 4.1).
- **No starvation.** Every client is served in every window of $R - r_i + 1$ slots, and the window is sharp (Theorem 3.8).
- **Optimality of round robin.** Any $B$-fair schedule has $B \ge R - r_{f(0)}$ (Theorem 4.3); round robin attains $k-1$ for the uniform profile (Corollary 4.4).
- **Two clients.** The Bresenham schedule is $(R-1)$-fair with Beatty counters (Theorem 5.3), has sharp waiting windows $\lceil R/r_i\rceil$ (Theorem 5.5), and strictly beats the block schedule on $(c,c)$ (Theorem 5.4).
- **Obstruction.** The nested-floor generalisation of Bresenham is not realisable by any schedule for $k \ge 3$, though it *is* Bresenham for $k=2$ (Theorem 6.2, Proposition 6.1).
- **Splitting trees.** Normalised discrepancy $\le \operatorname{depth}(T)$ for any well-formed tree (Theorem 7.3), hence $\le \lceil\log_2 k\rceil$ for every client count and every positive profile via balanced trees (Theorem 7.6).
- **Greedy.** Never leads by a full period, $D_i(t)\le R-1$ (Theorem 8.4); $(k-1)(R-1)$-fair (Theorem 8.5); not unit-fair — the profile $(1,1,1,5,5,5)$ reaches lag $19 > R = 18$ (Section 8.1).
