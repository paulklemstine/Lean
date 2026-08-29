# The Oracle-Realization Gap for the Fermat Navigation Sensor

### A quantified circularity barrier, an exact crediting law, and the divisor-lattice structure of Fermat scan cost

**Author:** Aristotle
**Date:** 2026-08-29

---

## Abstract

We study a one-bit statistic of an odd semiprime $N = pq$ that we call the *navigation sensor*:
the indicator $\mathbf{1}\{d(N) \le B\}$ of the **Fermat gap** $d(N) = \frac{p+q}{2} -
\lfloor\sqrt N\rfloor$ falling below a threshold $B$. Empirically this sensor carries
$0.479797$ bits of mutual information about a hidden target bit at a peak threshold
$B = 22758$ (hit rate $0.2053$), yet no query policy computable from $N$ alone, given a budget
of $295$ menu queries, recovers a nonzero fraction of it once crediting is performed inside
bands of comparable $\log N$: strict crediting is $0\%$ for every such policy across two
independently seeded populations, while the oracle itself carries $73.5$–$76.8\%$ of the peak
within those same bands.

We give a complete structural account of this discrepancy in seven theorems.

1. **Circularity, exactly.** For odd $p \le q$, the pair $(N, d)$ recovers $p$ and $q$ by two
   integer square roots. The sensor's underlying statistic is logically equivalent to the
   factorisation, and an oracle answering $\mathbf{1}\{d \le B\}$ for all $B$ yields a factoring
   algorithm.
2. **The budget law.** For a semiprime, a Fermat scan of budget $k$ succeeds if and only if
   $d \le k$. The geometric channel realizes the sensor at price exactly $B$ and never below.
3. **Residue blindness.** For every modulus $L \ne 0$ and every threshold $B$ there is a pair of
   semiprimes congruent mod $L$ with opposite sensor values; hence residue-only policies realize
   *exactly* zero, not approximately zero.
4. **The exact crediting law.** For a finite population $P$, a statistic $T$, and a Boolean
   target $s$, the minimum error over $T$-measurable policies equals the sum over $T$-classes of
   the class minority count, attained by the class-wise majority vote. If all classes are
   balanced the minimum is $|P|/2$: strict crediting is *identically* zero.
5. **Adaptivity is free of charge.** Modelling adaptive policies as decision trees over a query
   menu, menu-indistinguishable samples receive identical verdicts from every tree of every
   depth; a depth-$k$ tree has at most $2^k$ leaves, so it is a $T$-measurable policy for a
   statistic of at most $2^k$ classes and item 4 applies verbatim.
6. **Divisor-lattice structure.** For arbitrary odd $N$ the scan cost is
   $\min_{e \mid N,\, 1 < e < N} \bigl(\frac{e + N/e}{2} - \lfloor\sqrt N\rfloor\bigr)$; a
   doubling device removes the parity hypothesis and covers every positive $N$.
7. **Density of the Fermat-close population.** For fixed $B$, the count of $N \le X$ with a
   Fermat-close factorisation is $O(\sqrt B \cdot X^{3/4})$, unconditionally and explicitly, so
   the observed hit rate $0.2053$ is a finite-population artefact.

Together these convert an experimental verdict of "partial realization gap, attributed to
circularity" into a proved decomposition: roughly three quarters of the peak is genuine geometry
priced at $B$ probes (unaffordable at a $295$-query budget, a factor of $77$), and the remaining
quarter is a population prior with provably vanishing density. The concrete witness
$N = 955277 \cdot 1044727 = 998{,}003{,}674{,}379$, with $d = 1001$, lies strictly inside the
reported window $295 < d \le 22758$: the sensor fires and the affordable scan misses.

**Keywords:** Fermat factorisation, integer square root, navigation sensor, mutual information,
minimum-error crediting, decision trees, divisor lattice, density of near-square semiprimes.

---

## 1. Introduction

### 1.1 Setting

A recurring pattern in the empirical study of hard number-theoretic problems is the *promising
sensor*: a statistic that correlates strongly with a quantity of interest, reproduces across
independent samples, and yet stubbornly refuses to become an algorithm. The usual informal
diagnosis is **circularity** — the statistic is secretly a function of the very secret it is
supposed to predict. The diagnosis is almost always correct and almost never quantified.

This paper quantifies one instance completely.

The instance concerns Fermat's factorisation method, an idea of the 1640s. Given an odd
$N = pq$, both factors odd, set

$$a = \frac{p+q}{2}, \qquad h = \frac{q-p}{2},$$

both integers, and observe $a^2 - h^2 = pq = N$. The method searches for such a representation
by scanning $a$ upward from $\lceil\sqrt N\rceil$ and testing whether $a^2 - N$ is a perfect
square. The cost of the scan is governed by a single number.

**Definition 1.1 (Fermat gap).** For odd $p, q$ with $p \le q$ and $N = pq$, the **Fermat gap**
is
$$d(p,q) \;=\; \operatorname{mid}(p,q) - \lfloor\sqrt N\rfloor, \qquad \operatorname{mid}(p,q) = \frac{p+q}{2}.$$

**Definition 1.2 (Navigation sensor).** For a threshold $B \in \mathbb{N}$,
$$s_B(p,q) \;=\; \mathbf{1}\{\,d(p,q) \le B\,\} \in \{0,1\}.$$

### 1.2 The empirical phenomenon

On a laboratory population of odd semiprimes the sensor was measured, with bias-corrected
mutual-information estimates, against a hidden target bit $b_1$. The measurement records:

| quantity | value |
|---|---|
| peak mutual information $I(s_B; b_1)$ | $0.479797$ bits |
| peak threshold $B$ | $22758$ |
| sensor hit rate at peak | $0.2053$ |
| replication (independent seed) | $0.4948$ bits, same $B = 22758$ |
| query budget of the competing policies | $295$ distinct menu items |
| best pooled ("lenient") policy realization | $0.167$–$0.172$ bits ($33.8$–$35.9\%$ of peak) |
| best stratified ("strict") policy realization | $0\%$, every policy, both seeds |
| oracle within-strata excess | $0.3634$–$0.3687$ bits ($73.5$–$76.8\%$ of peak) |
| best policy within strata | $\le 0.0018$ bits ($0.25$–$0.50\%$ of the oracle's) |
| residue-only ("MODONLY") residual | $0.0008$–$0.0032$ bits |
| pooled $z$-score / within-strata $z$-score | $+118 \ldots +128$ / $\le 2.3$ |
| sham-control maximum raw signal | $0.0020$ bits, credited $0$ |

The pattern is unambiguous: an enormous pooled effect that evaporates upon stratification, a
residue channel indistinguishable from noise, and an oracle that retains three quarters of its
information *within* strata where no policy retains any.

The purpose of this paper is to explain each row of that table by a theorem.

### 1.3 Contributions and organisation

Section 2 fixes notation and proves the parametrisation lemmas. Section 3 proves the circularity
theorem and the oracle-to-factoring reduction. Section 4 proves the budget law and exhibits the
concrete witness inside the reported window. Section 5 proves the unboundedness of the gap
(menu exhaustion). Section 6 proves exact residue blindness. Section 7 develops the exact
crediting law for statistic-measurable policies and derives the balanced-strata corollary.
Section 8 treats adaptive policies as decision trees. Section 9 generalises the budget law to
the divisor lattice of an arbitrary $N$. Section 10 proves the density bound. Section 11
assembles the decomposition of the $0.48$-bit peak and discusses applications; Section 12 lists
future directions.

---

## 2. Preliminaries

Throughout, $\lfloor\sqrt{\cdot}\rfloor$ denotes the integer square root: the greatest $m$ with
$m^2 \le n$. All variables are non-negative integers; subtraction is truncated, and every
statement below is arranged so that the subtractions performed are genuine.

**Lemma 2.1 (Half-difference).** If $p, q$ are odd with $p \le q$, then $q = p + 2h$ for a
unique $h \ge 0$, namely $h = \frac{q-p}{2}$.

*Proof.* Write $p = 2a+1$, $q = 2b+1$ with $a \le b$; take $h = b - a$. $\square$

Under the substitution $q = p + 2h$ the basic quantities become transparent:

**Lemma 2.2 (Parametrisation).** For all $p, h$:
$$\operatorname{mid}(p, p+2h) = p + h, \qquad (p+h)^2 = p(p+2h) + h^2, \qquad
\lfloor\sqrt{p(p+2h)}\rfloor \le p + h.$$

*Proof.* The first is $\frac{p + (p+2h)}{2} = p+h$. The second expands. The third follows from
the second, since $p(p+2h) \le (p+h)^2$ and the integer square root is monotone with
$\lfloor\sqrt{m^2}\rfloor = m$. $\square$

**Corollary 2.3 (AM–GM, integer form; defining identity of the gap).** For odd $p \le q$,
$$\lfloor\sqrt{pq}\rfloor \le \operatorname{mid}(p,q), \qquad\text{hence}\qquad
\lfloor\sqrt{pq}\rfloor + d(p,q) = \operatorname{mid}(p,q).$$

The truncated subtraction in Definition 1.1 is therefore harmless: the gap is a genuine
difference.

**Lemma 2.4 (Midpoint excess).** For odd $p \le q$,
$\operatorname{mid}(p,q)^2 = pq + \left(\frac{q-p}{2}\right)^2$.

*Proof.* Substitute $q = p+2h$ and apply Lemma 2.2. $\square$

**Lemma 2.5 (Difference of squares in $\mathbb{N}$).** For $b \le a$, $(a-b)(a+b) = a^2 - b^2$.

---

## 3. Circularity, exactly

The first theorem is the formal content of "barrier 6". It says the sensor's underlying
statistic is not a proxy for the factorisation but a *coordinate change* of it.

**Definition 3.1 (Recovery maps).** For $N, d \in \mathbb{N}$ put $A = \lfloor\sqrt N\rfloor + d$
and
$$\rho(N,d) = A - \bigl\lfloor\sqrt{A^2 - N}\bigr\rfloor, \qquad
\rho^{+}(N,d) = A + \bigl\lfloor\sqrt{A^2 - N}\bigr\rfloor.$$

**Theorem 3.2 (Circularity Theorem).** Let $p \le q$ be odd and $N = pq$. Then
$$\rho\bigl(N, d(p,q)\bigr) = p, \qquad \rho^{+}\bigl(N, d(p,q)\bigr) = q.$$

*Proof.* Write $q = p + 2h$. By Corollary 2.3 and Lemma 2.2,
$A = \lfloor\sqrt N\rfloor + d(p,q) = \operatorname{mid}(p,q) = p+h$. By Lemma 2.2 again,
$A^2 - N = (p+h)^2 - p(p+2h) = h^2$, whose integer square root is exactly $h$. Hence
$\rho = (p+h) - h = p$ and $\rho^{+} = (p+h)+h = q$. $\square$

Two integer square roots, no search: the gap *is* the factorisation.

The thresholded sensor is only marginally weaker, because the family
$\{s_B\}_{B \in \mathbb{N}}$ determines $d$ by its least accepting index.

**Lemma 3.3 (Least accepting threshold).** Let $O : \mathbb{N} \to \{0,1\}$ satisfy
$O(B) = s_B(p,q)$ for all $B$. Then $O$ accepts some threshold, and the least $B$ with
$O(B) = 1$ equals $d(p,q)$.

*Proof.* $O(d(p,q)) = \mathbf{1}\{d \le d\} = 1$, so the set of accepting thresholds is nonempty.
If $O(n) = 1$ then $d \le n$; so no $n < d$ accepts. $\square$

**Theorem 3.4 (Oracle-to-Factoring Reduction).** Let $p \le q$ be odd, $N = pq$, and let $O$ be
any oracle with $O(B) = s_B(p,q)$ for all $B$. Writing $B^\star$ for the least accepting
threshold of $O$, we have $\rho(N, B^\star) = p$ and $\rho^{+}(N, B^\star) = q$.

*Proof.* Combine Lemma 3.3 with Theorem 3.2. $\square$

**Remark 3.5.** $B^\star$ is found by binary search in $O(\log d)$ oracle calls once any
accepting threshold is known, and $d \le \frac{p+q}{2} \le N$, so the reduction is efficient.
A statistic whose oracle implies factoring is not a candidate for realization by a lightweight
$N$-computable policy — this is the qualitative reason the experiment's verdict was
foreordained. What the theorems below supply is the *quantitative* version.

---

## 4. The budget law: the geometric channel is priced exactly

Fermat's scan is the one channel that genuinely realizes the sensor. We price it.

**Definition 4.1 (Scan hit).** For $N, k \in \mathbb{N}$, say that a **Fermat scan of budget
$k$ hits $N$**, written $\mathrm{ScanHit}(N,k)$, if there exist $i \le k$ and $b$ with
$$\bigl(\lfloor\sqrt N\rfloor + i\bigr)^2 = N + b^2 \qquad\text{and}\qquad
\lfloor\sqrt N\rfloor + i - b > 1.$$

The guard $a - b > 1$ excludes the trivial representation
$N = \bigl(\frac{N+1}{2}\bigr)^2 - \bigl(\frac{N-1}{2}\bigr)^2$, valid for every odd $N$, which
would otherwise make every odd number a hit at astronomical budget and render the notion vacuous.

**Theorem 4.2 (Budget Law).** Let $p \le q$ be odd primes and $N = pq$. Then for every $k$,
$$\mathrm{ScanHit}(N,k) \iff d(p,q) \le k.$$

*Proof.* ($\Leftarrow$) Take $i = d(p,q)$ and $b = \frac{q-p}{2}$. By Corollary 2.3,
$\lfloor\sqrt N\rfloor + i = \operatorname{mid}(p,q)$, and Lemma 2.4 gives
$\operatorname{mid}(p,q)^2 = N + b^2$. For the guard, $\operatorname{mid}(p,q) - b = p > 2$ since
$p$ is an odd prime, whence $p \ge 3$.

($\Rightarrow$) Suppose the scan hits with witnesses $i \le k$ and $b$; set
$a = \lfloor\sqrt N\rfloor + i$. From $a^2 = N + b^2$ and Lemma 2.5, $(a-b)(a+b) = N = pq$, with
$a - b \ge 2$ and $a - b \le a + b$. Since $p$ is prime and $p \mid (a-b)(a+b)$, one of the two
factors is divisible by $p$; a short case analysis using primality of $q$ shows the only
possibility consistent with $a-b \ge 2$ is $\{a-b, a+b\} = \{p, q\}$, hence
$(a-b)+(a+b) = p+q$, i.e. $a = \operatorname{mid}(p,q)$. By Corollary 2.3, $i = d(p,q)$, and
$i \le k$ gives the claim. $\square$

Theorem 4.2 is the exact statement that the geometric channel realizes $s_B$ *at price $B$ and
never below*. The scan cannot get lucky early, because a semiprime has no factorisation other
than the intended one.

### 4.1 A concrete inhabitant of the reported window

The experimental window is $295 < d \le 22758$: thresholds where the sensor fires but the
$295$-query menu cannot reach. It is nonempty and easy to inhabit.

**Proposition 4.3 (Witness).** $955277$ and $1044727$ are prime,
$$N = 955277 \cdot 1044727 = 998{,}003{,}674{,}379, \qquad \lfloor\sqrt N\rfloor = 999001,
\qquad d = \tfrac{955277+1044727}{2} - 999001 = 1000002 - 999001 = 1001.$$
Consequently $s_{22758}(955277, 1044727) = 1$ while $\neg\,\mathrm{ScanHit}(N, 295)$.

*Proof.* Primality is a finite check. The square-root computation: $999001^2 = 998{,}002{,}998{,}001
\le N$ and $999002^2 = 998{,}004{,}996{,}004 > N$. The two consequences follow from
$1001 \le 22758$ and $1001 > 295$ via Theorem 4.2. $\square$

This one number exhibits the realization gap without any statistics at all: an affordable
procedure returns $0$ where the sensor returns $1$.

---

## 5. Menu exhaustion: the gap is unbounded

A fixed menu of $295$ queries — or of any finite size — can only distinguish finitely many
behaviours. The population it faces does not.

**Theorem 5.1 (Quantitative lower bound on the gap).** Let $p, q$ be odd with
$q \ge p + 2\bigl(k + 2pk + 1\bigr)$. Then $d(p,q) > k$.

*Proof.* Write $q = p + 2h$, so $h \ge k + 2pk + 1$. Put $m = h - k$, so $m \ge 2pk + 1$. Then
$$p(p+2h) = (p+h)^2 - h^2 \quad\text{and}\quad (p+m)^2 - p(p+2h) = m^2 - 2pk - \ldots$$
more directly: since $m^2 \ge (2pk+1)m > 2pk$, one checks $p(p+2h) < (p+m)^2$, hence
$\lfloor\sqrt{p(p+2h)}\rfloor < p+m$. With $\operatorname{mid} = p+h = p+k+m$ we get
$d = \operatorname{mid} - \lfloor\sqrt N\rfloor > (p+k+m) - (p+m) = k$. $\square$

**Corollary 5.2 (Unbounded gaps).** For every budget $k$ and every bound $n$ there is a prime
$q > n$ with $d(3, q) > k$. Consequently $\{N : N = 3q,\ q \text{ prime},\ d(3,q) > k\}$ is
infinite.

*Proof.* Euclid's theorem supplies a prime $q$ exceeding
$\max\bigl(n+1,\ 3 + 2(k + 6k + 1)\bigr)$; apply Theorem 5.1 with $p=3$. The set is unbounded
above, hence infinite. $\square$

So for every finite budget there are infinitely many population members whose realization
requires more. The experimental observation that policy performance was *flat in $B$ past
roughly $64$ queries* — the menu class exhausting at $295$ — is the finite shadow of
Corollary 5.2.

---

## 6. Residue blindness: exactly zero, not approximately zero

The measured residue-only residual was $0.0008$–$0.0032$ bits. We show the truth is exact zero,
for every modulus and every threshold, by exhibiting a colliding pair.

**Theorem 6.1 (Residue-menu blindness).** For every $L \ge 1$ and every $B$ there exist odd
primes $p, q_1, q_2$ with $p \le q_1$, $p \le q_2$, such that
$$p q_1 \equiv p q_2 \pmod L, \qquad d(p, q_1) \le B < d(p, q_2).$$

*Proof.* Choose a prime $p > \max(L, 2)$; then $\gcd(p, L) = 1$ and $p$ is odd. Take $q_1 = p$.
Then $\operatorname{mid}(p,p) = p$ and $\lfloor\sqrt{p\cdot p}\rfloor = p$, so $d(p,q_1) = 0 \le B$.
By Dirichlet's theorem on primes in arithmetic progressions there is a prime
$q_2 \equiv p \pmod L$ with $q_2 > p + 2(B + 2pB + 1)$; then $d(p,q_2) > B$ by Theorem 5.1. And
$pq_1 = p\cdot p \equiv p\cdot q_2 = pq_2 \pmod L$ because $q_1 = p \equiv q_2$. $\square$

**Remark 6.2.** The pair is genuinely mixed: one member is a prime square $p^2$, the other a
semiprime with distinct factors. Prime squares are legitimate members of the odd-semiprime
population, and the sensor's value on them ($d = 0$) is correct, not degenerate.

**Corollary 6.3 (Every residue-only policy errs).** For every $L \ge 1$, every $B$, and every
$f : \mathbb{N} \to \{0,1\}$, there are semiprimes $N_1 = pq_1$ and $N_2 = pq_2$ as in
Theorem 6.1 with
$$f(N_1 \bmod L) \ne s_B(p,q_1) \quad\text{or}\quad f(N_2 \bmod L) \ne s_B(p,q_2).$$

*Proof.* $N_1 \equiv N_2 \pmod L$, so $f$ returns the same value on both, while the sensor
returns $1$ and $0$ respectively. $\square$

Corollary 6.3 applies simultaneously to any finite family of moduli, since a policy reading
$N \bmod L_1, \ldots, N \bmod L_r$ is a policy reading $N \bmod \operatorname{lcm}(L_i)$. The
"$0.0008$ bits" of the experiment is sampling noise around a theorem.

---

## 7. What "percentage of an oracle realized" means

Mutual information does not decompose in a way that makes "$34\%$ of a sensor realized" a
well-defined quantity. The right primitive is *minimum error under an information constraint*,
and it has an exact closed form.

### 7.1 Setup

Let $P$ be a finite population, $\kappa$ a set of *classes*, $T : P \to \kappa$ a **statistic**
(everything a policy may read: residues, magnitude stratum, a vector of menu-query answers,
$\ldots$), and $s : P \to \{0,1\}$ a **target**. A **$T$-measurable policy** is a function
$f : \kappa \to \{0,1\}$, with error count
$$\mathrm{err}(P, T, s, f) \;=\; \#\{\,i \in P : f(T(i)) \ne s(i)\,\}.$$

For $Q \subseteq P$ let $\mathrm{minority}(Q, s) = \min\bigl(\#\{i \in Q : s(i)=1\},\
\#\{i \in Q : s(i)=0\}\bigr)$, and define the **irreducible error**
$$\mathrm{irr}(P, T, s) \;=\; \sum_{c \in T(P)} \mathrm{minority}\bigl(T^{-1}(c) \cap P,\, s\bigr).$$

### 7.2 The law

**Lemma 7.1 (Fibrewise decomposition).** $\mathrm{err}(P,T,s,f) = \sum_{c \in T(P)}
\#\{i \in P : T(i)=c,\ f(T(i)) \ne s(i)\}$.

*Proof.* The mismatch set is partitioned by the fibres of $T$. $\square$

**Lemma 7.2 (Class-level error).** Fix $c$ and write $Q = T^{-1}(c) \cap P$. If $f(c) = 1$ the
policy's errors within $Q$ are exactly the members with $s = 0$; if $f(c) = 0$ they are exactly
those with $s = 1$.

*Proof.* On $Q$, $f(T(i)) = f(c)$ is constant. $\square$

**Theorem 7.3 (Lower bound).** For every $f$, $\mathrm{irr}(P,T,s) \le \mathrm{err}(P,T,s,f)$.

*Proof.* By Lemmas 7.1 and 7.2, the $c$-term of the error is either the count of $0$s or the
count of $1$s in the class, both of which are at least the minimum of the two. Sum. $\square$

**Definition 7.4 (Majority vote).** $\mathrm{maj}(c) = 1$ if $\#\{i \in T^{-1}(c) \cap P : s(i)=0\}
\le \#\{i \in T^{-1}(c) \cap P : s(i)=1\}$, and $0$ otherwise.

**Theorem 7.5 (Attainment).** $\mathrm{err}(P,T,s,\mathrm{maj}) = \mathrm{irr}(P,T,s)$.

*Proof.* By Lemma 7.2 the $c$-term of the majority vote's error is the smaller of the two class
counts, i.e. the class minority. Sum. $\square$

**Theorem 7.6 (Exact Crediting Law).** $\mathrm{irr}(P,T,s)$ is the *least* element of
$\{\mathrm{err}(P,T,s,f) : f : \kappa \to \{0,1\}\}$.

*Proof.* Theorem 7.3 gives the lower bound; Theorem 7.5 exhibits a policy attaining it.
$\square$

Attainment matters methodologically: a claim of "zero realization" is worthless if it rests on a
lower bound that no policy meets. Here the optimum is explicit.

### 7.3 The strict-crediting verdict as a theorem

**Definition 7.7 (Balanced statistic).** $T$ is **balanced** for $s$ on $P$ if every class
$c \in T(P)$ satisfies $\#\{i \in T^{-1}(c)\cap P : s(i)=1\} = \#\{i \in T^{-1}(c)\cap P : s(i)=0\}$.

**Theorem 7.8 (Balanced strata give exactly zero).** If $T$ is balanced for $s$ on $P$, then
$$2\cdot\mathrm{irr}(P,T,s) = |P|,$$
i.e. the least error of any $T$-measurable policy is exactly half the population.

*Proof.* In a balanced class $Q$, the two counts are equal and sum to $|Q|$, so
$2\,\mathrm{minority}(Q,s) = |Q|$. Sum over classes, using that the classes partition $P$.
$\square$

This is the precise form of the reported "strict within-strata crediting $0\%$". It also
explains the pooled/stratified discrepancy without appeal to statistics: pooling *merges*
classes with unequal base rates, creating unbalanced merged classes in which the majority vote
profits — not from any knowledge of the target, but from the base rate itself. Refining the
partition until each class is balanced removes the profit identically. In slogan form:

> **Pooling changes the target, not the information.**

A pooled $z$ of $+118$ alongside a within-strata $z \le 2.3$ is not a paradox; it is
Theorem 7.8 with a base-rate channel bolted on.

### 7.4 Instantiation at the navigation sensor

**Theorem 7.9 (Zero realization, concretely).** For every $L \ge 1$ and every $B$ there is a
two-point population $P = \{(p,q_1), (p,q_2)\}$ of semiprimes such that the residue statistic
$T(p,q) = (pq) \bmod L$ satisfies $\mathrm{err}(P, T, s_B, f) > 0$ for every $f$.

*Proof.* Take the pair of Theorem 6.1. The two points lie in one $T$-class and carry opposite
target values, so that class has minority $1$; apply Theorem 7.3. $\square$

On this population $T$ is balanced, so Theorem 7.8 applies: the minimum error is exactly
$|P|/2 = 1$. The residue statistic realizes precisely nothing.

---

## 8. Adaptivity buys resolution, not information

The strongest laboratory policies were *adaptive*: each query was chosen in the light of earlier
answers. We model this faithfully and show it changes nothing.

**Definition 8.1 (Query tree).** Over a sample space $\iota$, a **query tree** is either a leaf
$\mathrm{leaf}(v)$ with $v \in \{0,1\}$, or an internal node $\mathrm{node}(m, t_1, t_0)$ where
$m : \iota \to \{0,1\}$ is a query and $t_1, t_0$ are query trees. Evaluation is
$$\mathrm{eval}(\mathrm{leaf}(v), i) = v, \qquad
\mathrm{eval}(\mathrm{node}(m,t_1,t_0), i) = \begin{cases}\mathrm{eval}(t_1, i) & m(i)=1\\
\mathrm{eval}(t_0, i) & m(i)=0.\end{cases}$$
A tree **uses the menu** $M \subseteq \{0,1\}^{\iota}$ if every internal node's query lies in
$M$. Depth and leaf count are defined as usual: $\mathrm{depth}(\mathrm{leaf}) = 0$,
$\mathrm{depth}(\mathrm{node}(m,t_1,t_0)) = 1 + \max(\mathrm{depth}\,t_1, \mathrm{depth}\,t_0)$,
and $\#\mathrm{leaves}(\mathrm{node}(m,t_1,t_0)) = \#\mathrm{leaves}(t_1) + \#\mathrm{leaves}(t_0)$.

**Theorem 8.2 (Capacity).** Every query tree $t$ satisfies
$\#\mathrm{leaves}(t) \le 2^{\mathrm{depth}(t)}$.

*Proof.* Induction. A leaf has $1 \le 2^0$. For a node of depth
$1 + \max(\mathrm{depth}\,t_1, \mathrm{depth}\,t_0)$, each child has at most
$2^{\max(\mathrm{depth}\,t_1,\mathrm{depth}\,t_0)}$ leaves by induction and monotonicity of
$2^{(\cdot)}$; the sum is at most $2 \cdot 2^{\max} = 2^{1+\max}$. $\square$

Theorem 8.2 is the bridge to Section 7: a depth-$k$ adaptive policy induces the statistic
"which leaf did this sample reach", which has at most $2^k$ classes, so the Exact Crediting Law
applies to adaptive policies verbatim, with $|\kappa| \le 2^k$.

**Theorem 8.3 (Adaptivity buys nothing).** Let $M$ be a menu and $t$ a tree using $M$. If
$i, j \in \iota$ satisfy $m(i) = m(j)$ for every $m \in M$, then
$\mathrm{eval}(t, i) = \mathrm{eval}(t, j)$.

*Proof.* Induction on $t$. A leaf is constant. At a node with query $m \in M$ we have
$m(i) = m(j)$, so both samples descend into the same child, to which the induction hypothesis
applies. $\square$

**Corollary 8.4 (Every tree errs on an indistinguishable pair).** With $M, t, i, j$ as above,
if a target $s$ satisfies $s(i) \ne s(j)$, then $\mathrm{eval}(t,i) \ne s(i)$ or
$\mathrm{eval}(t,j) \ne s(j)$.

*Proof.* If both matched, then $s(i) = \mathrm{eval}(t,i) = \mathrm{eval}(t,j) = s(j)$ by
Theorem 8.3, contradiction. $\square$

**Theorem 8.5 (No adaptive residue policy realizes the sensor).** Fix $L \ge 1$ and $B$. Let
$M_L = \bigl\{\,(p,q) \mapsto \mathbf{1}\{pq \equiv r \pmod L\} \;:\; r \in \mathbb{N}\,\bigr\}$
be the residue menu. Then there are odd primes $p, q_1, q_2$ with $q_1 \ne q_2$ such that
*every* query tree over $M_L$, of any depth and however fitted, errs on $(p,q_1)$ or on
$(p,q_2)$.

*Proof.* Take the pair of Theorem 6.1. Since $pq_1 \equiv pq_2 \pmod L$, every $m \in M_L$
agrees on the two samples. The sensor values differ ($1$ and $0$). Apply Corollary 8.4.
$\square$

Note the strength of the quantifier order: the pair is chosen *before* the tree, and works for
all trees at once — including trees of depth far exceeding the menu size. Adaptivity, ensembling,
and unlimited fitting are all irrelevant against indistinguishability.

---

## 9. The divisor-lattice structure of scan cost

The budget law of Section 4 assumed a semiprime, i.e. it presupposed the factorisation. Removing
that assumption reveals what the sensor really measures.

**Lemma 9.1.** A divisor of an odd number is odd.

**Theorem 9.2 (From a split to a hit).** Let $N = uv$ with $u, v$ odd, $1 < u \le v$, and
$\frac{u+v}{2} \le \lfloor\sqrt N\rfloor + k$. Then $\mathrm{ScanHit}(N,k)$.

*Proof.* Write $v = u + 2h$. Then $(u+h)^2 = N + h^2$ and $\lfloor\sqrt N\rfloor \le u+h \le
\lfloor\sqrt N\rfloor + k$, so $i = (u+h) - \lfloor\sqrt N\rfloor \le k$ and $b = h$ witness the
hit; the guard holds because $(u+h) - h = u > 1$. $\square$

**Theorem 9.3 (Divisor-Lattice Navigation Law).** For odd $N$ and every $k$,
$$\mathrm{ScanHit}(N,k) \iff \exists\, e \mid N,\ 1 < e < N,\ \frac{e + N/e}{2} \le \lfloor\sqrt N\rfloor + k.$$

*Proof.* ($\Leftarrow$) is Theorem 9.2 applied to the pair $\{e, N/e\}$ in increasing order,
both odd by Lemma 9.1. ($\Rightarrow$) Given a hit with $a = \lfloor\sqrt N\rfloor + i$ and $b$,
Lemma 2.5 gives $(a-b)(a+b) = N$, so $e := a-b$ divides $N$, $e \ge 2$ by the guard, and
$e < N$ since $N/e = a+b \ge 2$. Finally $\frac{e + N/e}{2} = \frac{(a-b)+(a+b)}{2} = a \le
\lfloor\sqrt N\rfloor + k$. $\square$

**Definition 9.4 (Navigation cost).** For composite odd $N$,
$$\mathrm{cost}(N) \;=\; \min_{\substack{e \mid N\\ 1 < e < N}}
\left(\frac{e + N/e}{2} - \lfloor\sqrt N\rfloor\right),$$
so that $\mathrm{ScanHit}(N,k) \iff \mathrm{cost}(N) \le k$.

**Corollary 9.5 (Safety criterion).** If every nontrivial divisor $e$ of odd $N$ has
$\frac{e+N/e}{2} > \lfloor\sqrt N\rfloor + k$, then no scan of budget $k$ succeeds.

**Corollary 9.6 (Semiprime specialisation).** For $N = pq$ with $p \le q$ odd primes, the
divisor lattice has a single nontrivial pair, so $\mathrm{cost}(N) = d(p,q)$ and Theorem 9.3
reduces to Theorem 4.2.

**Remark 9.7 (Composites are easier).** Because the cost is a *minimum* over the divisor
lattice, richly composite $N$ tend to be cheap: the minimum is typically attained at an interior
divisor near $\sqrt N$, not at an extreme pair. This is the correct way to see Fermat's method —
not as a factoring algorithm for near-square semiprimes, but as a proximity search in the
divisor lattice whose cost is the distance from $\lfloor\sqrt N\rfloor$ to the nearest
divisor-pair midpoint.

### 9.1 Removing the parity hypothesis

For even $N$ the midpoint $\frac{e + N/e}{2}$ need not be an integer (e.g. $N = 12$, $e = 3$),
so Theorem 9.3 genuinely requires oddness. Doubling repairs this.

**Definition 9.8 (Doubled scan).** $\mathrm{ScanHit}_2(N,k)$ holds if there are $i \le k$ and
$b$ with $\bigl(\lfloor\sqrt{4N}\rfloor + i\bigr)^2 = 4N + b^2$ and
$\lfloor\sqrt{4N}\rfloor + i - b > 2$.

The guard is strengthened from $>1$ to $>2$ because $4N = (N+1)^2 - (N-1)^2$ always yields
$a - b = 2$.

**Theorem 9.9 (Parity-free navigation law).** For every $N \ge 1$ and every $k$,
$$\mathrm{ScanHit}_2(N,k) \iff \exists\, e \mid N,\ 1 < e < N,\ e + \frac{N}{e} \le \lfloor\sqrt{4N}\rfloor + k.$$

*Proof sketch.* ($\Leftarrow$) With $N = ef$, $1 < e \le f$, one has $(e+f)^2 = 4N + (f-e)^2$
and $\lfloor\sqrt{4N}\rfloor \le e+f$, so $i = (e+f) - \lfloor\sqrt{4N}\rfloor$ and $b = f-e$
witness the hit, with $(e+f)-(f-e) = 2e > 2$. ($\Rightarrow$) From
$(a-b)(a+b) = 4N$ one checks $a-b$ and $a+b$ have the same parity (their sum is $2a$) and their
product is even, hence both are even; writing $a-b = 2e$, $a+b = 2f$ gives $ef = N$ with
$1 < e \le f$, and the guard $a - b > 2$ forces $e > 1$. Finally
$e + f = \frac{(a-b)+(a+b)}{2} = a \le \lfloor\sqrt{4N}\rfloor + k$. $\square$

---

## 10. Density: the hit rate is a finite-population artefact

The reported hit rate $0.2053$ raises the question whether one fifth of semiprimes really are
Fermat-close. They are not, and the proof is a two-parameter count with no analytic input.

**Definition 10.1.** For $X, B \in \mathbb{N}$ let
$$\mathcal{C}(X,B) \;=\; \bigl\{\,N \le X \;:\; \exists\, p \le q \text{ odd with } N = pq \text{ and } d(p,q) \le B\,\bigr\}.$$

**Theorem 10.2 (Parametrisation).** Every $N \in \mathcal{C}(X,B)$ is of the form $a^2 - h^2$
with
$$a \le \lfloor\sqrt X\rfloor + B \qquad\text{and}\qquad h \le \bigl\lfloor\sqrt{2B(\lfloor\sqrt X\rfloor + B)}\bigr\rfloor.$$

*Proof.* Take $a = \operatorname{mid}(p,q)$ and $h = \frac{q-p}{2}$; then $N = a^2 - h^2$ by
Lemma 2.4. From $d(p,q) \le B$ and Corollary 2.3, $a = \lfloor\sqrt N\rfloor + d \le
\lfloor\sqrt N\rfloor + B \le \lfloor\sqrt X\rfloor + B$. For $h$: squaring
$a \le \lfloor\sqrt N\rfloor + B$ gives
$$a^2 \le \lfloor\sqrt N\rfloor^2 + 2B\lfloor\sqrt N\rfloor + B^2 \le N + 2B\lfloor\sqrt X\rfloor + B^2
\le N + 2B(\lfloor\sqrt X\rfloor + B),$$
using $\lfloor\sqrt N\rfloor^2 \le N$; since $h^2 = a^2 - N$, we get
$h^2 \le 2B(\lfloor\sqrt X\rfloor+B)$. $\square$

**Theorem 10.3 (Counting bound).**
$$\bigl|\mathcal{C}(X,B)\bigr| \;\le\; \bigl(\lfloor\sqrt X\rfloor + B + 1\bigr)\cdot
\Bigl(\bigl\lfloor\sqrt{2B(\lfloor\sqrt X\rfloor+B)}\bigr\rfloor + 1\Bigr).$$

*Proof.* By Theorem 10.2, $\mathcal{C}(X,B)$ is contained in the image of the box of admissible
pairs $(a,h)$ under $(a,h) \mapsto a^2 - h^2$; the image of a finite set is no larger than the
set. $\square$

**Lemma 10.4 (Submultiplicativity of the integer square root).**
$\lfloor\sqrt{uv}\rfloor \le (\lfloor\sqrt u\rfloor+1)(\lfloor\sqrt v\rfloor+1)$.

*Proof.* $u < (\lfloor\sqrt u\rfloor+1)^2$ and $v < (\lfloor\sqrt v\rfloor+1)^2$, so
$uv < \bigl((\lfloor\sqrt u\rfloor+1)(\lfloor\sqrt v\rfloor+1)\bigr)^2$. $\square$

**Corollary 10.5 ($X^{3/4}$ shape).**
$$\bigl|\mathcal{C}(X,B)\bigr| \;\le\; \bigl(\lfloor\sqrt X\rfloor + B + 1\bigr)\cdot
\Bigl(\bigl(\lfloor\sqrt{2B}\rfloor+1\bigr)\bigl(\lfloor\sqrt{\lfloor\sqrt X\rfloor+B}\rfloor+1\bigr) + 1\Bigr)
\;=\; O\!\left(\sqrt{B}\,X^{3/4}\right).$$

**Corollary 10.6 (Vanishing density).** For fixed $B$, $\bigl|\mathcal{C}(X,B)\bigr| / X =
O\bigl(\sqrt B \cdot X^{-1/4}\bigr) \to 0$ as $X \to \infty$.

**Remark 10.7.** The bound counts a superset — every difference of two squares in the box, not
merely the semiprimes — so it is generous, and still vanishing. Consequently a *fixed* positive
hit rate is impossible asymptotically, and the observed $0.2053$ must be attributed to the
laboratory population's construction (its size-ratio coupling: support-edge effects in the
independent and unilogarithmic samplers, and truncation of the larger factor in the ratio
sampler). This converts the report's honest caveat into a proved limitation, and it is the
reason the roughly $24\%$ "between-strata" slice cannot be a statement about semiprimes in
general.

---

## 11. The decomposition of the $0.48$-bit peak

We can now account for the measurement row by row.

**(a) The peak is real and reproducible.** $0.479797$ bits at $B = 22758$, reproduced bit-exactly
on regeneration and at $0.4948$ bits on a fresh seed with the same peak location. Nothing in this
paper disputes it.

**(b) About three quarters of it is geometry, priced at $B$ probes.** The measured within-strata
oracle excess of $0.3634$–$0.3687$ bits ($73.5$–$76.8\%$ of peak) corresponds to the Budget Law
(Theorem 4.2): the information is the position of $\frac{p+q}{2}$ relative to $\sqrt N$, and it is
realizable — by a scan of $B$ probes and not one probe fewer. With $B = 22758$ against a
$295$-item menu, the price exceeds the budget by a factor of $77$. Proposition 4.3 exhibits a
single number in the resulting window. Independently, a full scan at peak budget was measured to
miss $79.5\%$ of samples, consistent with the median gap of $215782$ in the population — an order
of magnitude beyond even $B$.

**(c) The remaining quarter is a population prior.** The lenient pooled credit of $0.167$–$0.172$
bits is the between-magnitude-strata base-rate channel. Theorem 7.8 explains mechanically why it
survives pooling and dies under stratification; Corollary 10.6 explains why it is a property of
the finite sample rather than of semiprimes.

**(d) The residue channel carries nothing.** Theorem 6.1 and Corollary 6.3 make the measured
$0.0008$–$0.0032$ bits an exact zero, and Theorem 8.5 extends this to adaptive residue policies
of any depth. The parabola-mirror ensembles that produced almost the entire lenient signal
($0.161$–$0.167$ of $0.164$–$0.172$ bits) were reading magnitude, not residue.

**(e) The oracle is factoring-hard.** Theorems 3.2 and 3.4: the sensor's statistic recovers the
factorisation by two integer square roots, and the thresholded family recovers it by binary
search. This is the barrier, stated exactly.

**Summary.** The $0.48$-bit peak is not a leak. It splits into an expensive-but-real geometric
component (three quarters, priced at $B$ probes) and a sampling artefact (one quarter, of
vanishing density). No policy reading only $N$ through a bounded menu — static or adaptive —
recovers any of the first, and the second is not a property of the problem. The peak remains
unrealized, and now provably so.

### 11.1 Methodological transfer

Theorem 7.6 is not about factoring. It says: *given an explicit statistic $T$, the minimum error
of any $T$-measurable predictor of a Boolean target is the sum of the class minorities, attained
by the class-wise majority vote.* Three consequences generalise well beyond this paper.

1. **"Percentage of an oracle realized" must name a statistic.** Without one, the phrase is not
   well-posed. With one, it is a closed form.
2. **Pooled evaluation banks the base rate.** Theorem 7.8 makes the difference between pooled and
   stratified crediting a theorem, not a matter of taste. Any evaluation that reports a large
   pooled effect should also report the stratified effect, and the gap between them is exactly the
   base-rate channel.
3. **Capacity bounds transfer to adaptivity.** Theorem 8.2 converts any adaptive procedure of
   depth $k$ into a $T$-measurable policy with $|\kappa| \le 2^k$, so the crediting law applies to
   adaptive learners, ensembles, and staged pipelines without modification.

---

## 12. Discussion and future directions

### 12.1 What survived, what failed, and why

*Survived, true and structural.* The circularity claim, the budget law, and the residue null are
exact statements, not statistical estimates. In particular the strict "$0\%$" is a theorem for
residue statistics rather than a measurement.

*Needed a different definition.* "Percentage of the oracle peak realized" has no
information-theoretic meaning until one fixes the statistic the policy may read. Recast as a
minimum-error functional it becomes a closed form (the sum of class minorities) with an explicit
optimal policy.

*Genuinely population-dependent.* The reported hit rate. The $X^{3/4}$ count shows the
Fermat-close density vanishes, so the roughly $24\%$ between-strata slice cannot be a statement
about semiprimes in general.

### 12.2 Future directions

**1. Divisor-Lattice Navigation Spectrum.** The key insight is that the scan cost of an odd $N$
is a minimum over its whole divisor lattice, $\mathrm{cost}(N) = \min_{e \mid N,\, 1<e<N}
\bigl(\frac{e+N/e}{2} - \lfloor\sqrt N\rfloor\bigr)$, not a property of a distinguished pair of
prime factors. This invites a systematic study of the *navigation spectrum* of $N$: the multiset
$\bigl\{\frac{e+N/e}{2} - \lfloor\sqrt N\rfloor : e \mid N,\ 1<e<N\bigr\}$. Natural questions:
how does the minimum distribute over integers with a prescribed number of divisors; for which
composites is the minimum attained at an interior divisor rather than an extreme pair; and does
the spectrum's shape yield a usable safety criterion (Corollary 9.5) for cryptographic modulus
selection beyond the classical near-square condition?

**2. Sharpening the Fermat-close count.** Theorem 10.3 counts all differences of squares in the
admissible box, a superset of the semiprimes. Restricting to genuine semiprimes should reduce the
count substantially — plausibly to $O(\sqrt B \cdot X^{3/4}/\log^2 X)$ by standard heuristics —
and an unconditional improvement would sharpen the statement that the observed hit rate is an
artefact. A matching lower bound of order $\sqrt B \cdot X^{3/4}$ for the difference-of-squares
count would show Theorem 10.3 is tight in shape.

**3. Randomized policies.** The decision-tree model of Section 8 covers deterministic policies
whose queries are functions of the sample. Randomized policies — mixing over trees, or using
random query selection — are not covered, and would require an averaging argument. The expected
result is that randomization cannot help against indistinguishability either (a distribution over
trees is still constant on menu-equivalence classes in expectation), but the statement and its
constant deserve to be worked out, particularly in the regime where the policy is allowed a
small error probability.

**4. Continuous crediting.** The Exact Crediting Law is stated for $0/1$ loss and Boolean
targets. Extending it to proper scoring rules (log-loss, Brier) would connect the minimum-error
functional back to the mutual-information language of the original measurement, and would say
precisely how many bits a statistic realizes rather than how many mistakes it forces. The
expected form is a class-wise conditional-entropy sum, with the majority vote replaced by the
class-wise conditional distribution.

**5. Other campaign sensors.** The pipeline of this paper — price the channel that realizes the
sensor, prove the cheap channels blind, make crediting exact, bound the population density — is
generic. It should be applied to the other sensors of the campaign to determine which, if any,
survive stratified crediting; the machinery is indifferent to the specific statistic.

### 12.3 Limitations

The results are unconditional and elementary, but they are also *structural*, and structural
results do not bound every conceivable policy. Specifically: (i) randomized policies are outside
the decision-tree model (direction 3); (ii) the residue-blindness construction uses a prime
square $p^2$ as one member of the colliding pair, which is legitimate but atypical — a
construction with two distinct-factor semiprimes would be aesthetically preferable, though the
sensor value $d = 0$ on $p^2$ is entirely correct; (iii) the density bound is asymptotic and says
nothing about how large $X$ must be before the observed hit rate must fall, so it refutes the
persistence of $0.2053$ without quantifying the crossover; and (iv) all statements concern the
Fermat navigation sensor specifically and transfer to other sensors only through the
methodological content of Sections 7 and 8.

---

## 13. Conclusion

The Fermat navigation sensor carries nearly half a bit about a hidden target, and none of it is
reachable by a bounded query policy that sees only $N$. We have shown why, exactly: the sensor's
underlying statistic recovers the factorisation by two integer square roots; the one channel that
realizes it — Fermat's scan — costs exactly $B$ probes and never fewer, against a budget of
$295$; the residue channel is provably blind at every modulus, adaptively as well as statically;
the crediting arithmetic that produced "$34\%$ pooled, $0\%$ stratified" is a closed-form minimum
over class minorities, identically half the population when strata are balanced; and the observed
hit rate that made the population look favourable has density $O(\sqrt B \cdot X^{-1/4})$ and
must vanish.

What began as a barrier attributed informally to circularity is now a measured quantity: three
quarters of the peak is real geometry priced beyond the budget, one quarter is a sampling
artefact, and zero is realizable. The compass was accurate. It was pointing at the answer.
