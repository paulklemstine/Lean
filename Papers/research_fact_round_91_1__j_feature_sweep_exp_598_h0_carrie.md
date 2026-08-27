# Marginal Blindness and the Consecutive-Position Law of the Sieve Polynomial

**Author:** Aristotle
**Date:** 2026-08-27

---

## Abstract

We study the statistical structure of hit patterns produced by a quadratic sieve
polynomial $y_v = (s+v)^2 - N$, motivated by a pre-registered survey that
searched eight families of arithmetic features of the position index for a
carrier of an observed mid-window excess and found none (all enrichment ratios
$R \le 1.11$, best per-family $p = 0.36$). We prove that this null outcome was
structurally forced for the entire class of tests employed, and we derive the
exact law governing the joint structure that such tests cannot see.

Three results carry the argument. First, **marginal blindness**: on a product
sample space, if the hit set is row balanced — the same number of hits for each
value of the index — then the enrichment ratio of the cell cut out by *any*
function of the index is exactly $1$; conversely, flat single-row enrichment is
*equivalent* to row balance, so such a sweep extracts precisely one bit of
information from the data. We exhibit a hit set (the graph of a permutation)
that is flat on every marginal cell while a joint cell carries enrichment
$|B|$ over the global rate, unbounded as the space grows, and which is
simultaneously invisible in a regression view: every additive predictor
$f(a) + g(b)$ has $R^2 \le 0$.

Second, **selection-floor and max-statistic calibration**: pigeonhole forces the
best cell of any scan to reach the global rate, so an uncalibrated
"best-cell-exceeds-$1$" test has type-I error rate exactly $1$; an observation at
or below a median of the null max distribution has one-sided $p \ge 1/2$; the
$p$-value of a maximum is bounded by the sum of per-cell $p$-values; and
permutation $p$-values are exactly valid in finite samples. These give an
assumption-free dismissal of the survey's raw maximum $R = 1.5578$ against a
null median max of $1.6334$.

Third, the **consecutive-position law**. For an odd prime $q$ and nonzero square
target $N = r^2 \bmod q$, the set of positions with $q \mid y_v$ has exactly two
elements; two positions at lag $k \ne 0$ can both be hit only if $4N = k^2$, so
the lag-$k$ double-hit count is $0$ or $1$ and the empirical covariance of the
divisibility indicators equals $-4/q^2$ at all but exactly two lags
($k = \pm 2r$), where it equals $1/q - 4/q^2$. It is never zero for $q \ge 5$.
Chinese-remainder independence makes the covariance functional additive across
primes, so over a factor base of odd primes the counts of factor-base divisors at
consecutive positions have covariance exactly $-\sum_i 4/q_i^2$, uniformly
bounded by $2$ for distinct odd primes. The dependency is therefore a genuine,
accumulating, $O(1)$ effect concentrated on the smallest primes — precisely the
type of carrier that marginal sweeps are proved to miss.

**Keywords:** quadratic sieve, smoothness, marginal independence, enrichment
ratio, permutation test, multiple comparisons, Chinese remainder theorem,
covariance additivity.

---

## 1. Introduction

### 1.1 Setting

Let $N$ be a positive integer, $s = \lfloor \sqrt{N} \rfloor$, and consider the
sieve polynomial

$$y_v = (s+v)^2 - N, \qquad v = 0, 1, 2, \ldots$$

Congruence-of-squares factoring methods search for positions $v$ at which $y_v$
is smooth (has all prime factors below a bound). We call such a position a
**hit**. Empirically, hits are not uniform across a scan: a survey of a large
generated position file reported an excess of hits in a mid-window region
($u \in [0.55, 0.75]$, $n = 104{,}200$ positions) relative to flanks
($u \in [0.05,0.40) \cup (0.90,1.00]$, $n = 235{,}003$), with $9{,}594$ hits
distributed across $128$ windows.

The natural follow-up is to ask which property of the position index $j$ carries
the excess. Eight families were registered in advance: $j \bmod 4$,
$j \bmod 3$, $j \bmod 5$, $j \bmod 7$, the joint class $j \bmod 105$, terciles of
the small-prime-factor count $\omega(j)$, smoothness of $|j - \text{nearest square}|$,
and $10^6$-smoothness of $j$ itself. The decision rule required an enrichment
ratio $R \ge 1.15$ against the in-window complement, a family-wise max-statistic
permutation $p < 0.01$ with a Bonferroni factor $K = 8$, and a sign-consistent
difference-in-differences.

All eight families failed, with best cells
$R = 1.0748,\, 1.0314,\, 1.0785,\, 1.1111,\, 1.5578,\, 1.0107,\, 1.0224,\, 1.0232$
and adjusted $p$-values all equal to $1$. The single large-looking number,
$R = 1.5578$ at $j \equiv 73 \pmod{105}$ (cell size $1022$, $26$ hits), sat below
the null distribution's own median maximum over $105$ cells ($1.6334$;
$95$th percentile $1.8516$), with $226$ of $300$ null draws exceeding it, i.e.
a global permutation $p$-value of $0.754$.

### 1.2 Contributions

Rather than register a ninth feature family, we ask whether the null result was
*forced*. It was, and the proof is informative. This paper proves:

1. **Marginal blindness and its converse** (Section 3). Row balance implies every
   marginal enrichment ratio is exactly $1$, for every feature; and flat
   single-row enrichment implies row balance. A marginal sweep therefore has
   exactly one bit of resolving power.
2. **An unbounded marginally blind carrier** (Section 3.4), invisible in both the
   contingency and the regression view.
3. **Scan-statistic theory** (Section 4): the selection floor, the size-one
   failure of the uncalibrated max test, the median argument, the union bound
   behind Bonferroni, and exact finite-sample validity of permutation $p$-values.
4. **The local consecutive-position law** (Section 5): two roots per prime, the
   adjacency obstruction $4N = 1$, the pair dichotomy, and the exact covariance.
5. **The full lag spectrum** (Section 6): flat at $-4/q^2$ off a two-element
   exceptional set $k = \pm 2r$.
6. **Covariance additivity and the factor-base deficit law** (Section 7):
   $\operatorname{Cov} = -\sum_i 4/q_i^2$, strictly negative, and bounded by $2$
   uniformly in the size of the base.

Section 8 gives algorithms, Section 9 numerical corroboration, Section 10
applications and discussion, Section 11 open directions.

---

## 2. Notation and basic definitions

Throughout, all averages are with respect to the uniform measure on a finite
index set. For a finite nonempty set $I$ and $f : I \to \mathbb{R}$,

$$\operatorname{avg}(f) = \frac{1}{|I|} \sum_{i \in I} f(i), \qquad
\operatorname{Cov}(f,g) = \operatorname{avg}(fg) - \operatorname{avg}(f)\operatorname{avg}(g).$$

For a finite ambient set $I$, a **hit set** is a subset $H \subseteq I$, and for
a **cell** $C \subseteq I$ we define

$$\operatorname{rate}(H, C) = \frac{|H \cap C|}{|C|}, \qquad
\operatorname{globalRate}(H) = \frac{|H|}{|I|}, \qquad
\operatorname{enrich}(H,C) = \frac{\operatorname{rate}(H,C)}{\operatorname{rate}(H, C^{c})}.$$

The enrichment ratio $\operatorname{enrich}(H,C)$ is the quantity reported as $R$
in the survey: hit rate inside the cell over hit rate in its in-window
complement.

When the ambient set factors as $I = A \times B$ we call the first coordinate the
**index** (the position label $j$, whose arithmetic the sweep probes) and the
second the **residual** coordinate (everything else determining whether the
observation is a hit). For $S \subseteq A$, the **row cell** is
$\operatorname{row}(S) = S \times B$; note $\operatorname{row}(S)^c = \operatorname{row}(S^c)$.
The **row count** of $a \in A$ is $\rho_H(a) = |\{x \in H : x_1 = a\}|$, and $H$
is **row balanced with multiplicity $m$** if $\rho_H(a) = m$ for all $a \in A$.

A **feature** is any map $u : A \to \kappa$ into a finite set of values; its
**cells** are the preimages $u^{-1}(k)$, lifted to $I$ as
$\{x : u(x_1) = k\} = \operatorname{row}(u^{-1}(k))$. This is the only property of
the eight registered families that our theorems use: they are functions of the
index alone.

---

## 3. Marginal blindness

### 3.1 The rate of a row cell

**Lemma 3.1 (Row decomposition).** For any $H \subseteq A \times B$ and
$S \subseteq A$, $|H \cap \operatorname{row}(S)| = \sum_{a \in S} \rho_H(a)$.

*Proof.* The fibres $\{x \in H : x_1 = a\}$, $a \in S$, partition
$H \cap \operatorname{row}(S)$. $\square$

**Theorem 3.2 (Marginal blindness, rate form).** Let $H$ be row balanced with
multiplicity $m$ and let $S \subseteq A$ be nonempty. Then

$$\operatorname{rate}(H, \operatorname{row}(S)) = \frac{m}{|B|},$$

independently of $S$.

*Proof.* By Lemma 3.1 the numerator is $m|S|$ and $|\operatorname{row}(S)| = |S|\,|B|$;
the factor $|S|$ cancels. $\square$

**Theorem 3.3 (Marginal blindness, enrichment form).** If $H$ is row balanced with
multiplicity $m > 0$ and $S$ and $S^{c}$ are both nonempty, then
$\operatorname{enrich}(H, \operatorname{row}(S)) = 1$.

*Proof.* Both rates equal $m/|B| \ne 0$ by Theorem 3.2, using
$\operatorname{row}(S)^{c} = \operatorname{row}(S^{c})$. $\square$

**Corollary 3.4 (No feature of the index can carry an excess).** Let $H$ be row
balanced with multiplicity $m > 0$, let $u : A \to \kappa$ be *any* feature and
$k$ any value with $u^{-1}(k)$ and its complement nonempty. Then

$$\operatorname{enrich}\bigl(H, \{x : u(x_1) = k\}\bigr) = 1 .$$

The hypothesis $m > 0$ excludes only the degenerate empty-hit case, where the
ratio is $0/0$. Corollary 3.4 is the structural statement behind the survey's
verdict: the eight families were not unlucky; *no* family could have succeeded.

### 3.2 Rigidity: the converse

Flatness is not merely implied by row balance — it characterises it.

**Theorem 3.5 (Rigidity).** Let $|A| \ge 2$ and suppose every single-row cell has
enrichment $1$:
$\operatorname{enrich}(H, \operatorname{row}(\{a\})) = 1$ for all $a \in A$. Then
there is $m$ with $\rho_H(a) = m$ for all $a$, and $|H| = |A|\,m$.

*Proof sketch.* Fix $a$. Enrichment $1$ for the singleton row means
$\rho_H(a)/|B| = \bigl(|H| - \rho_H(a)\bigr) / \bigl((|A|-1)|B|\bigr)$, i.e.
$|A|\,\rho_H(a) = |H|$ for every $a$. Since $|A| \ge 2$ this determines
$\rho_H(a) = |H|/|A|$, the same value for all $a$. $\square$

**Theorem 3.6 (Complete characterisation).** For nonempty $H$ and $|A| \ge 2$:

$$\bigl(\forall a \in A:\ \operatorname{enrich}(H, \operatorname{row}(\{a\})) = 1\bigr)
\iff \bigl(\exists m > 0:\ H \text{ is row balanced with multiplicity } m\bigr).$$

*Proof.* ($\Rightarrow$) Theorem 3.5, with $m > 0$ because $H \ne \emptyset$.
($\Leftarrow$) Theorem 3.3 applied to $S = \{a\}$, whose complement is nonempty
since $|A| \ge 2$. $\square$

So the informational content of a flat marginal sweep is exactly one bit. This
is a statement about the *test*, not about the data-generating mechanism.

### 3.3 The permutation-graph carrier

**Definition 3.7.** For a bijection $\sigma : A \to B$, the **graph hit set** is
$G_\sigma = \{(a, \sigma(a)) : a \in A\}$.

**Lemma 3.8.** $G_\sigma$ is row balanced with multiplicity $1$, and
$|G_\sigma| = |A|$.

**Theorem 3.9 (A marginally blind carrier of unbounded strength).** Let
$|A| \ge 1$ and $\sigma : A \to B$ a bijection. Then

1. for every feature $u : A \to \kappa$ and every value $k$ with $u^{-1}(k)$ and
   its complement nonempty, $\operatorname{enrich}(G_\sigma, \{x : u(x_1)=k\}) = 1$;
2. the joint cell $G_\sigma$ itself satisfies
   $\operatorname{rate}(G_\sigma, G_\sigma) = 1 = |B| \cdot \operatorname{globalRate}(G_\sigma)$.

*Proof.* (1) is Corollary 3.4 with $m = 1$ via Lemma 3.8. (2) The cell is entirely
composed of hits, so its rate is $1$, whereas
$\operatorname{globalRate}(G_\sigma) = |A| / (|A|\,|B|) = 1/|B|$. $\square$

The enrichment of the joint cell over the global rate is $|B|$, i.e. arbitrarily
large, while every marginal cell reads exactly $1$. Marginal flatness carries no
evidence whatsoever against a joint carrier.

### 3.4 Two independent views of the same blindness

The blindness is not an artefact of contingency-table methodology.

**Theorem 3.10 (Two views).** Let $|A| \ge 2$ and $\sigma : A \to B$ a bijection,
and let $\mathbb{1}_{G_\sigma}$ denote the indicator of the graph hit set. Then
simultaneously:

* *(contingency view)* every marginal cell has enrichment exactly $1$;
* *(regression view)* every additive predictor $x \mapsto f(x_1) + g(x_2)$, with
  $f : A \to \mathbb{R}$ and $g : B \to \mathbb{R}$ completely arbitrary, has
  coefficient of determination $R^2 \le 0$ against the target
  $\mathbb{1}_{G_\sigma}$;
* *(joint view)* $\operatorname{rate}(G_\sigma, G_\sigma) = |B| \cdot \operatorname{globalRate}(G_\sigma)$.

The regression clause says that no additive model beats the constant model: the
best additive least-squares fit explains a non-positive fraction of variance.
Since a one-feature-at-a-time sweep is precisely a family of additive models, a
result of "$R \approx 1$ and $R^2 \approx 0$" is the *expected* output of both
methodologies in the presence of an arbitrarily strong joint carrier.

---

## 4. Scan statistics: floor, calibration, and validity

We now formalise the inferential half of the survey. Let $\Omega$ be a finite
nonempty null ensemble (e.g. permutation replicates) and $T : \Omega \to \mathbb{R}$
a statistic. The **one-sided permutation $p$-value** of an observed value $t$ is

$$p_T(t) = \frac{|\{\omega \in \Omega : T(\omega) \ge t\}|}{|\Omega|}.$$

Call $m$ a **median** of $T$ if $|\Omega| \le 2\,|\{\omega : T(\omega) \ge m\}|$
(the usual one-sided half-mass condition).

### 4.1 The selection floor

**Theorem 4.1 (Selection floor, counting form).** For any finite index set $I$,
feature $u : I \to \kappa$ and hit set $H \subseteq I$, there exists $k$ with

$$|H| \cdot |u^{-1}(k)| \;\le\; |H \cap u^{-1}(k)| \cdot |I| .$$

*Proof.* Suppose not, so the reverse strict inequality holds for every $k$.
Summing over $k$ and using $\sum_k |H \cap u^{-1}(k)| = |H|$ and
$\sum_k |u^{-1}(k)| = |I|$ gives $|H|\,|I| < |H|\,|I|$, a contradiction. $\square$

**Corollary 4.2 (Rate form).** Some nonempty cell has hit rate at least the global
rate: $\operatorname{rate}(H, u^{-1}(k)) \ge \operatorname{globalRate}(H)$.

**Corollary 4.3 (The raw scan statistic never drops below one).** Define the
uncalibrated scan statistic on a null draw $\omega$ with hit set $H_\omega$ by

$$M(\omega) = \max_{k \in \kappa} \frac{\operatorname{rate}(H_\omega, u^{-1}(k))}{\operatorname{globalRate}(H_\omega)} .$$

If $H_\omega \ne \emptyset$ for all $\omega$, then $M(\omega) \ge 1$ for all
$\omega$.

### 4.2 The uncalibrated maximum test has size one

**Theorem 4.4.** If $T(\omega) \ge 1$ for all $\omega \in \Omega$, then
$p_T(1) = 1$.

**Corollary 4.5.** $p_M(1) = 1$: the test "the best cell exceeds the global rate"
rejects on the entire null ensemble. Its type-I error rate is exactly $1$, so it
conveys no information about the data whatsoever.

This is the formal content of the survey's extreme-value demonstration: a raw
best-of-$105$ ratio, compared with $1$, is a statement about pigeonholes.

### 4.3 The median argument

**Theorem 4.6.** If $m$ is a median of $T$ and $t \le m$, then $p_T(t) \ge 1/2$.

*Proof.* $p_T$ is antitone in $t$, so $p_T(t) \ge p_T(m)$, and the median
condition gives $p_T(m) \ge 1/2$. $\square$

Applied with $T$ the max-of-$105$-cells ratio, null median $m = 1.6334$ and
observation $t = 1.5578 \le m$: the observation cannot be significant at any
level below $1/2$. No calibration constant, no distributional assumption, no
asymptotics. The empirical global permutation $p$-value, $0.754$, is consistent
with this bound.

**Theorem 4.7 (Sweep verdict).** If $t \le m$ for a median $m$ of $T$ and
$T \ge 1$ pointwise, then for every $\alpha < 1/2$ the observation is not
significant at level $\alpha$, while the naive threshold $1$ would have rejected
on the whole ensemble.

### 4.4 Union bound and Bonferroni

For a family of per-cell statistics $T_c : \Omega \to \mathbb{R}$, $c \in \kappa$,
let $T_{\max}(\omega) = \max_c T_c(\omega)$.

**Theorem 4.8 (Union bound).** $p_{T_{\max}}(t) \le \sum_{c \in \kappa} p_{T_c}(t)$.

*Proof.* $\{T_{\max} \ge t\} \subseteq \bigcup_c \{T_c \ge t\}$; take
cardinalities and divide by $|\Omega|$. $\square$

**Theorem 4.9 (Bonferroni validity).** If $p_{T_c}(t) \le \alpha / |\kappa|$ for
every $c$, then $p_{T_{\max}}(t) \le \alpha$.

This is exactly why a per-family raw $p = 0.36$ over $K = 8$ registered families
is not evidence, and why the adjusted values reported as $1.0$ are the honest
summary.

### 4.5 Exact finite-sample validity

**Theorem 4.10 (Permutation validity).** For every statistic $T$ and every
$\alpha \ge 0$,

$$\bigl|\{\omega \in \Omega : p_T(T(\omega)) \le \alpha\}\bigr| \;\le\; \alpha\,|\Omega| .$$

*Proof sketch.* Let $S = \{\omega : p_T(T(\omega)) \le \alpha\}$; if $S$ is empty
we are done. Otherwise pick $\omega_0 \in S$ minimising $T$ over $S$. Then
$S \subseteq \{\omega : T(\omega) \ge T(\omega_0)\}$, whose cardinality is
$p_T(T(\omega_0))\,|\Omega| \le \alpha\,|\Omega|$. $\square$

No exchangeability beyond the construction of the ensemble itself, and no
distributional assumption, is required. This is what licenses max-statistic
calibration as a valid procedure in the first place.

---

## 5. The local consecutive-position law

Fix an odd prime $q$ and work in $\mathbb{Z}/q$. Write $s$ and $N$ for the
reductions of $\lfloor\sqrt N\rfloor$ and $N$, and set

$$y_v = (s+v)^2 - N \in \mathbb{Z}/q, \qquad v \in \mathbb{Z}/q .$$

Define $D(s,N) = \{v : y_v = 0\}$ and, for a lag $k$,
$P_k(s,N) = \{v : y_v = 0 \text{ and } y_{v+k} = 0\}$. Write $P = P_1$.

**Theorem 5.1 (Two roots per prime).** For any $s$ and any $r$,
$D(s, r^2) = \{r - s,\ -r - s\}$. If moreover $r \ne 0$ and $q \ne 2$, then
$|D(s,r^2)| = 2$.

*Proof.* $(s+v)^2 = r^2$ iff $(s+v-r)(s+v+r) = 0$, and $\mathbb{Z}/q$ is a field.
Distinctness: the two roots coincide iff $2r = 0$, impossible for odd $q$ and
$r \ne 0$. $\square$

Thus each prime hits a fixed density $2/q$ of positions, *independently of the
target* $N$ (as long as it is a nonzero square). Any statistic that reads only
the single-position density is therefore constant across all such $N$: an
instance of marginal blindness at the level of the arithmetic.

**Theorem 5.2 (Adjacency obstruction).** If $v \in P(s,N)$ then $4N = 1$ in
$\mathbb{Z}/q$.

*Proof.* From $y_{v+1} - y_v = 0$ we get $2(s+v) + 1 = 0$. Multiply and combine
with $(s+v)^2 = N$: from $2(s+v) = -1$ we get $4(s+v)^2 = 1$, i.e. $4N = 1$. $\square$

**Theorem 5.3 (Exceptional locus is a divisor condition).** For an integer target
$N$, $4N \equiv 1 \pmod q$ iff $q \mid 4N - 1$. Hence the primes admitting an
adjacent double hit are exactly the prime divisors of $4N - 1$: a finite,
explicitly enumerable set.

**Theorem 5.4 (Pair dichotomy).** For odd $q$:

* if $4N \ne 1$, then $P(s,N) = \emptyset$;
* if $4N = 1$, then $P(s,N) = \{-2^{-1} - s\}$, a single element.

In particular $|P(s,N)| \in \{0,1\}$ — never the value $\approx 4/q$ that
independence of the two positions would predict.

*Proof.* The first clause is Theorem 5.2. For the second, $4N = 1$ forces
$N = (2^{-1})^2$; the condition $2(s+v) + 1 = 0$ has the unique solution
$s + v = -2^{-1}$, and one checks it does satisfy both equations. $\square$

### 5.1 The exact covariance

Let $\mathbb{1}(v) = [\,y_v = 0\,]$ and $\mathbb{1}^{+}(v) = [\,y_{v+1} = 0\,]$, both
real-valued statistics on $\mathbb{Z}/q$ with the uniform measure.

**Lemma 5.5.** $\operatorname{avg}(\mathbb{1}) = \operatorname{avg}(\mathbb{1}^{+}) = |D(s,N)|/q$
and $\operatorname{avg}(\mathbb{1}\,\mathbb{1}^{+}) = |P(s,N)|/q$.

(The shift invariance of the mean follows from $v \mapsto v+1$ being a bijection
of $\mathbb{Z}/q$.)

**Theorem 5.6 (Exact adjacent covariance).**

$$\operatorname{Cov}(\mathbb{1}, \mathbb{1}^{+}) = \frac{|P(s,N)|}{q} - \left(\frac{|D(s,N)|}{q}\right)^{2}.$$

**Corollary 5.7 (Generic case).** For odd $q$, $N = r^2$ with $r \ne 0$ and
$4r^2 \ne 1$:

$$\operatorname{Cov}(\mathbb{1}, \mathbb{1}^{+}) = -\frac{4}{q^{2}} \;<\; 0 .$$

**Corollary 5.8 (Exceptional case).** If instead $4r^2 = 1$:

$$\operatorname{Cov}(\mathbb{1}, \mathbb{1}^{+}) = \frac{1}{q} - \frac{4}{q^{2}},$$

which is strictly positive for $q > 4$.

**Theorem 5.9 (Consecutive positions are never independent).** For every prime
$q \ge 5$ and every nonzero square target, $\operatorname{Cov}(\mathbb{1}, \mathbb{1}^{+}) \ne 0$.

The contrast with Theorem 5.1 is the whole point: the marginal density is
$2/q$ in both regimes, while the pair statistic separates them by an $O(1/q)$
gap. This is a carrier of exactly the type Section 3 proves invisible to
one-coordinate-at-a-time analysis.

---

## 6. The full lag spectrum

The pre-registered follow-up concerns lag $1$, but the same computation yields
every lag at once, and the answer is rigid.

**Theorem 6.1 (Lag obstruction).** If $k \ne 0$ and $v \in P_k(s,N)$, then
$4N = k^2$.

*Proof.* Subtracting the two equations gives $k\,(2(s+v)+k) = 0$; since $k \ne 0$
and $\mathbb{Z}/q$ is a field, $2(s+v) = -k$, whence $4N = 4(s+v)^2 = k^2$. Note
that no hypothesis on $q$ beyond primality is needed. $\square$

**Theorem 6.2 (Lag dichotomy).** For odd $q$ and $k \ne 0$, $|P_k(s,N)| = 0$ if
$4N \ne k^2$ and $|P_k(s,N)| = 1$ if $4N = k^2$.

**Theorem 6.3 (Exact lag covariance).** With
$\mathbb{1}^{(k)}(v) = [\,y_{v+k} = 0\,]$,

$$\operatorname{Cov}(\mathbb{1}, \mathbb{1}^{(k)}) = \frac{|P_k(s,N)|}{q} - \left(\frac{|D(s,N)|}{q}\right)^{2}.$$

**Theorem 6.4 (Flat spectrum).** For odd $q$, $N = r^2$ with $r \ne 0$, and any
$k \ne 0$ with $k^2 \ne 4r^2$:

$$\operatorname{Cov}(\mathbb{1}, \mathbb{1}^{(k)}) = -\frac{4}{q^{2}},$$

with no dependence on $k$ whatsoever. On an exceptional lag the value jumps to
$1/q - 4/q^2$.

**Theorem 6.5 (Exactly two exceptional lags).** $4r^2 = k^2$ iff $k = 2r$ or
$k = -2r$, and for odd $q$ and $r \ne 0$ these are distinct. Hence exactly $2$ of
the $q-1$ nonzero lags carry the positive covariance, and all $q-3$ others carry
the same negative one.

**Theorem 6.6 (No lag is independent).** For $q \ge 5$, every nonzero lag has
nonzero covariance.

*Design consequence.* Because the spectrum is flat, a statistic that averages the
pair indicator over lags loses no signal while reducing variance — and the two
exceptional lags, being determined by $4N = k^2$, are known in advance for any
concrete target.

---

## 7. Accumulation over a factor base

A single prime is a local statement. Sieving uses a factor base, and the relevant
observable is the *count* of factor-base primes dividing $y_v$. Do per-prime
deficits reinforce or cancel?

### 7.1 Covariance additivity across independent coordinates

Let $I$ be a finite index set with a bijection $e : I \to A \times B$.

**Lemma 7.1 (Coordinate means).** For $g : A \to \mathbb{R}$,
$\operatorname{avg}\bigl(v \mapsto g(e(v)_1)\bigr) = \operatorname{avg}(g)$, and similarly for
the second coordinate.

**Lemma 7.2 (Product means factor).** For $g_1 : A \to \mathbb{R}$ and
$g_2 : B \to \mathbb{R}$,

$$\operatorname{avg}\bigl(v \mapsto g_1(e(v)_1)\, g_2(e(v)_2)\bigr) = \operatorname{avg}(g_1)\operatorname{avg}(g_2).$$

*Proof.* Transport the sum along $e$ and apply Fubini for finite sums:
$\sum_{(a,b)} g_1(a) g_2(b) = \bigl(\sum_a g_1\bigr)\bigl(\sum_b g_2\bigr)$;
divide by $|A|\,|B| = |I|$. $\square$

**Theorem 7.3 (Covariance additivity, two coordinates).** For
$f_1, g_1 : A \to \mathbb{R}$ and $f_2, g_2 : B \to \mathbb{R}$,

$$\operatorname{Cov}\bigl(f_1 \circ \pi_1 + f_2 \circ \pi_2,\; g_1 \circ \pi_1 + g_2 \circ \pi_2\bigr)
= \operatorname{Cov}(f_1, g_1) + \operatorname{Cov}(f_2, g_2),$$

where $\pi_i$ denote the coordinate projections composed with $e$. Every cross
term vanishes identically.

*Proof sketch.* Expand the product into four terms. The two diagonal terms give
$\operatorname{avg}(f_1 g_1)$ and $\operatorname{avg}(f_2 g_2)$ by Lemma 7.1; the two
cross terms factor by Lemma 7.2 into $\operatorname{avg}(f_1)\operatorname{avg}(g_2)$
and $\operatorname{avg}(g_1)\operatorname{avg}(f_2)$. The means of the sums split by
Lemma 7.1, and subtracting cancels exactly the cross terms. $\square$

**Theorem 7.4 (Covariance additivity, $n$ coordinates).** On a product
$\prod_{i=1}^{n} A_i$ of finite nonempty sets, for families
$f_i, g_i : A_i \to \mathbb{R}$,

$$\operatorname{Cov}\Bigl(v \mapsto \sum_i f_i(v_i),\; v \mapsto \sum_i g_i(v_i)\Bigr)
= \sum_{i=1}^{n} \operatorname{Cov}(f_i, g_i).$$

*Proof.* Induction on $n$, splitting off one factor at a time with Theorem 7.3.
All $n(n-1)$ cross terms vanish. $\square$

### 7.2 The factor-base count and its deficit law

Let $q_1, \ldots, q_n$ be odd primes and $Q = \prod_i q_i$. The Chinese remainder
theorem gives a ring isomorphism $\mathbb{Z}/Q \cong \prod_i \mathbb{Z}/q_i$ that
carries $v \mapsto v+1$ to the simultaneous shift by $1$ in every coordinate, so
Theorem 7.4 applies verbatim to shifted statistics. Define the **factor-base
count**

$$\Omega_F(v) = \sum_{i=1}^{n} [\, q_i \mid y_v \,],$$

read coordinatewise on $\prod_i \mathbb{Z}/q_i$.

**Theorem 7.5 (Two primes).** For odd primes $p, q$ with generic nonzero square
targets ($r_i \ne 0$, $4 r_i^2 \ne 1$),

$$\operatorname{Cov}\bigl(\Omega_F(v),\, \Omega_F(v+1)\bigr) = -\frac{4}{p^{2}} - \frac{4}{q^{2}} \;<\; 0 .$$

**Theorem 7.6 (Factor-base deficit law).** For a factor base of odd primes
$q_1, \dots, q_n$ with generic nonzero square targets,

$$\operatorname{Cov}\bigl(\Omega_F(v),\, \Omega_F(v+1)\bigr) = -\sum_{i=1}^{n} \frac{4}{q_i^{2}},$$

which is strictly negative as soon as $n \ge 1$.

*Proof.* Theorem 7.4 reduces the joint covariance to the sum of the per-prime
covariances; each is $-4/q_i^2$ by Corollary 5.7. $\square$

Nothing cancels: each prime contributes its own strictly negative deficit, and
the total is a plain sum. This is the precise sense in which the
consecutive-position dependency is a genuine accumulating signal.

### 7.3 The effect is $O(1)$

**Lemma 7.7 (Telescoping estimate).** For $M \ge 3$,
$\displaystyle\sum_{m=3}^{M-1} \frac{4}{m^{2}} \le 2 - \frac{4}{M-1}$.

*Proof.* Induction on $M$, using $4/m^2 \le 4/(m-1) - 4/m = 4/(m(m-1))$. $\square$

**Theorem 7.8 (Uniform bound).** For any factor base of *distinct* odd primes,

$$\sum_{i=1}^{n} \frac{4}{q_i^{2}} \;\le\; 2,$$

independently of $n$.

*Proof.* Distinctness lets the sum be rewritten over the image set
$\{q_1, \dots, q_n\} \subseteq \{3, 4, \ldots\}$; enlarge to a full interval and
apply Lemma 7.7. $\square$

The bound is not tight — the sum over *all* odd primes is
$4\sum_{q \text{ odd prime}} q^{-2} = 0.808990\ldots$, of which $q = 3$ and $q = 5$
contribute about $74.7\%$ — but it is uniform, which is the structurally
important point. The adjacent dependency neither diverges with the size of the
factor base nor washes out; it is an $O(1)$ effect dominated by the head of the
base.

---

## 8. Algorithms

We record the three procedures that operationalise the theory. Sizes: $q$ is a
prime, $n$ the factor-base size, $K$ the number of scanned cells, $B$ the number
of null replicates.

### 8.1 Exact local covariance evaluator

Given $q$, $s$, $N$ and a lag $k$, enumerate $v \in \mathbb{Z}/q$, mark
$y_v = 0$, and count single and double hits. Cost $O(q)$ time, $O(q)$ space (or
$O(1)$ space with two passes). The output is compared with the closed form
$|P_k|/q - (|D|/q)^2$, which by Theorems 5.6 and 6.4 equals $-4/q^2$ off the
exceptional lags. In practice one never needs the enumeration: $|D| = 2$ when $N$
is a nonzero square, and $|P_k| = [\,4N = k^2\,]$, so the covariance is available
in $O(1)$ after a single quadratic-residue test.

### 8.2 Factor-base deficit accumulator

Given a factor base $q_1 < \cdots < q_n$ and a target $N$, compute for each $i$
whether $N$ is a nonzero square mod $q_i$ (Euler criterion, $O(\log q_i)$ per
prime) and whether $4N \equiv 1$, then accumulate $-4/q_i^2$ (generic) or
$1/q_i - 4/q_i^2$ (exceptional). Total cost $O(n \log \max q_i)$. Correctness is
Theorem 7.6 plus Corollary 5.8; the exceptional coordinates are exactly the
primes dividing $4N - 1$, so they can also be found by factoring $4N-1$ once.

### 8.3 Calibrated scan

Given cell assignments, hit counts and a resampling scheme:

1. compute the observed maximum $R_{\text{obs}}$ over the $K$ cells;
2. for $b = 1, \dots, B$, resample under the null *preserving the strata and the
   dependence structure of the data* (for windowed detections, permute at the
   level of windows, not of individual positions) and record the maximum
   $R_b$ over the same $K$ cells;
3. report $p = \bigl(1 + |\{b : R_b \ge R_{\text{obs}}\}|\bigr) / (1 + B)$, and
   also the null median and $95$th percentile of the $R_b$.

Cost $O(B\,(n_{\text{hits}} + K))$. Corollary 4.3 guarantees $R_b \ge 1$ for
every $b$, so the comparison must be against the $R_b$, never against $1$;
Theorem 4.6 shows that $R_{\text{obs}}$ below the null median already forces
$p \ge 1/2$; Theorem 4.10 gives finite-sample validity. The resampling unit in
step 2 is decisive: an independence null under-disperses the maximum whenever
hits arrive in correlated batches, which manufactures spurious significance.

---

## 9. Numerical corroboration

Direct enumeration confirms every closed form.

*Local law.* For each odd prime $q \le 23$ and each nonzero square target, the
divisibility set has exactly two elements; the adjacent double-hit set is empty
except at the unique residue with $4N \equiv 1$, where it is a singleton — for
example $N \equiv 4 \pmod 5$, $N \equiv 2 \pmod 7$, $N \equiv 3 \pmod{11}$,
$N \equiv 10 \pmod{13}$.

*Covariance.* The empirical covariance of the indicator pair matches
$-4/q^2$ to machine precision in the generic case (e.g. $-0.0816326531$ for
$q = 7$) and $1/q - 4/q^2$ in the exceptional case (e.g. $+0.0612244898$ for
$q = 7$, $N \equiv 2$).

*Lag spectrum.* For $q = 13, r = 1$ the exceptional lags are $\{2, 11\} = \{\pm 2r\}$,
carrying $+0.0532544379$, while all ten remaining nonzero lags carry exactly
$-0.0236686391 = -4/169$.

*Additivity.* For the factor base $\{5,7,11\}$ over its full period $385$, the
joint covariance of the counts is $-0.274690504301$, equal both to the sum of the
three per-prime covariances and to $-\sum 4/q_i^2$, to twelve decimal places.

*Deficit.* Summing $4/q^2$ over all odd primes below $10^6$ gives $0.80898941$,
comfortably below the uniform bound $2$; the primes $3$ and $5$ alone supply
$74.7\%$ of the total, confirming small-prime domination.

*Marginal blindness.* On a $12 \times 12$ grid with the hit set the graph of
$a \mapsto 3a + 5 \bmod 12$, five different feature families (residues mod $2, 3, 4$,
the indicator of squares, and the parity of the binary digit sum) give
enrichment exactly $1.000000$ on every cell, with maximum deviation $0$, while
the joint cell has hit rate $1 = 12 \times$ the global rate.

*A real sieve trace.* Sieving the actual polynomial for the prime
$N = 1{,}000{,}000{,}000{,}039$ over $400{,}000$ consecutive positions with the
factor base of all odd primes below $500$ ($49$ of which split, $3$ of which are
exceptional), the measured lag-$1$ covariance of the divisor count is
$-0.093159$ against a predicted $-0.093322$: a discrepancy of $0.17\%$, with no
fitted parameter.

*Scan calibration.* Throwing $9{,}594$ hits at $105$ cells over $104{,}200$
positions, the minimum over null draws of the best-cell ratio is $1.18 > 1$
(illustrating the floor), and the null median maximum rises from $1.27$ under an
independence null to $1.71$ when hits arrive in clumps of six — bracketing the
survey's reported null median maximum of $1.6334$ and showing directly how the
resampling unit, not the data, determines whether $1.5578$ looks impressive.

---

## 10. Discussion

### 10.1 What a null sweep does and does not establish

The eight-family verdict should not be read as "there is no carrier". Under a
mild uniformity condition on the index — row balance, which the rigidity theorem
shows is *equivalent* to observing flatness — the outcome $R = 1$ was the only
possible one, for any feature whatsoever. Flatness is a property of the test.
Conversely, a sweep that *does* find an enriched marginal cell has, by the same
theorem, detected a violation of row balance, which is a meaningful but narrow
finding.

### 10.2 Design guidance

Three concrete recommendations follow.

1. **Report the floor.** A scan maximum should always be accompanied by the
   statement that the floor is $1$ by pigeonhole. Any comparison against $1$ is
   uninformative by Corollary 4.5.
2. **Calibrate against the distribution of maxima**, using a resampling unit that
   preserves the dependence structure of the data. Section 9 shows an order-unity
   change in the null median maximum from this choice alone.
3. **Pre-declare the alternative class.** Since marginal features can only test
   row balance, a search for a joint carrier must test joint statistics: pair
   counts, lagged covariances, or run-length statistics on consecutive positions.

### 10.3 Consequences for sieving practice

The deficit law has a direct algorithmic reading. For a factor base $F$ of odd
primes and a generic target, smoothness events at consecutive sieve positions are
*negatively* correlated, with covariance $-\sum_{q \in F} 4/q^2$ for the divisor
count. Consequences: (i) hits are slightly more spread out than a Poisson model
predicts, so variance estimates for yield built on independence are mildly
conservative in one direction and anti-conservative in another; (ii) the effect
is concentrated on the smallest primes, so it interacts with the standard
practice of omitting small primes from the sieve; (iii) on the exceptional locus
— primes dividing $4N - 1$ — the sign flips, giving a genuinely clustered
contribution, which is a rare but exactly identifiable configuration.

### 10.4 Relation to classical heuristics

The standard heuristic treats the events $\{q \mid y_v\}$ across positions as
independent with density $2/q$. Theorem 5.9 says that this is never exactly
correct at any lag: the true covariance is $-4/q^2$, so the correlation
coefficient is

$$\frac{-4/q^{2}}{\frac{2}{q}\left(1 - \frac{2}{q}\right)} = -\frac{2}{q-2},$$

small but systematically signed. The flat lag spectrum
(Theorem 6.4) says the heuristic fails equally at all lags, which is reassuring
for practice — the error does not concentrate anywhere — and Theorem 7.8 says the
aggregate error is $O(1)$.

### 10.5 Limitations

The consecutive-position law is exact modulo a single prime and, via Chinese
remainder additivity, exact for the count of factor-base divisors over a full
period. It is *not*, by itself, a statement about smoothness, which is a
threshold event on the whole factorisation; nor does it directly quantify how
much of an observed mid-window excess this dependency can explain. Bridging from
the divisor-count covariance to a smoothness-indicator covariance requires a
model of the tail of the factorisation, and is the natural next technical step.

---

## 11. Future work

* **From divisor counts to smoothness.** Convert the exact deficit law for
  $\Omega_F$ into a bound on the covariance of the smoothness indicator, e.g. by
  a Chebyshev or large-deviation argument on the count.
* **Exceptional-locus arithmetic.** The primes admitting adjacent double hits are
  exactly the divisors of $4N - 1$; a divisor-counting bound would quantify how
  much positive covariance an adversarially chosen $N$ can accumulate.
* **Higher-order joint structure.** Triples $(v, v+1, v+2)$ satisfy two
  simultaneous obstructions; the analogous exact count should be $0$ except on a
  codimension-two locus.
* **Power analysis for pair statistics.** Given the exact covariance, compute the
  sample size at which a lag-averaged pair statistic detects the effect, and
  compare with the sizes at which marginal sweeps are provably powerless.
* **Non-prime moduli and prime powers.** Extend the two-roots and obstruction
  analysis to $q^e$ and to composite moduli where the CRT factorisation is only
  partial.

---

## 12. Conclusion

A pre-registered sweep of eight arithmetic feature families of the position index
found no carrier for an observed mid-window excess of smooth sieve values. We
have shown that this outcome was structurally forced: under row balance — which
is *equivalent* to observing flat enrichment — every marginal feature returns
enrichment exactly $1$, while joint carriers of unbounded strength coexist with
that flatness, in both contingency and regression views. We have also shown that
the one large raw ratio, $R = 1.5578$ over $105$ cells, is fully explained by the
selection floor and extreme-value fluctuation of a max statistic: the floor is
$1$ by pigeonhole, so the uncalibrated test has size $1$, and an observation
below the null median max has $p \ge 1/2$ unconditionally.

Finally, we derived the exact law of the structure that marginal tests cannot
see. For each odd prime $q$ the divisibility set of $y_v = (s+v)^2 - N$ has two
elements; two positions at lag $k \ne 0$ are simultaneously hit only when
$4N = k^2$, so the covariance of the divisibility indicators is $-4/q^2$ at all
but two lags and $1/q - 4/q^2$ at those two, never zero for $q \ge 5$. Chinese
remainder independence makes these deficits add: over a factor base the counts at
consecutive positions have covariance exactly $-\sum_i 4/q_i^2$, strictly
negative, uniformly bounded by $2$, and dominated by the smallest primes. The
next study writes itself.
