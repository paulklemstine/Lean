# Calibration Equals Maximal Robustness: The Exact Breakdown Number of a Quota Rung

**Author:** Aristotle
**Date:** 2026-08-17

## Abstract

An ensemble of $n$ stochastic replications of an experiment — runs differing only in a random
seed — produces $n$ numerical readings. Reporting a single number means choosing a *rung* of the
ensemble's **quota ladder**: for each quota $m \in \{1,\dots,n\}$, the least budget at which at
least $m$ of the runs succeed, i.e. the $m$-th order statistic of the readings. We develop the
theory of these rungs along two independent axes and prove that the axes coincide.

On the probabilistic axis, modelling each seed as clearing a fixed bar independently with
probability $p$, the $m$-th rung's distribution function is the binomial upper tail
$R_n(m,p) = \sum_{j\ge m}\binom{n}{j}p^j(1-p)^{n-j}$. We prove the **parity law of calibration**:
$R_n(m,\tfrac12) = \tfrac12$ if and only if $2m = n+1$. Hence an ensemble admits a calibrated rung
iff $n$ is odd, and then it is unique; every even ensemble has none, with an explicit central
defect $\delta_r = \binom{2r}{r}2^{-(2r+1)}$ satisfying
$\tfrac{1}{2\sqrt{4r+1}} \le \delta_r \le \tfrac{1}{2\sqrt{3r+1}}$ and
$\delta_r\sqrt{r}\to \tfrac{1}{2\sqrt{\pi}}$, whose two central rungs nevertheless average to
exactly $1/2$.

On the combinatorial axis, we prove a two-sided bracket — $c$ corrupted seeds move a rung by at
most $c$ rungs of the *clean* ladder, in both directions — together with matching sharpness in
both directions, yielding the exact **breakdown number**
$\beta(n,m) = \min(m-1,\,n-m)$ of the $m$-th rung.

The main theorem, the **Calibration–Robustness Dichotomy**, states that for $n = 2r+1$ and
$1 \le m \le n$ the rung is calibrated iff $\beta(n,m) = r$: a parity constraint on binomial tails
and a counting constraint on adversarial corruptions select the same index. For even $n = 2r$
both properties fail together — no rung is calibrated, and the maximal breakdown number $r-1$ is
attained by two rungs — so parity is a single obstruction to a canonical centre.

We apply the theory to a concrete measurement: three seeds of an attention-sparsification
experiment at $(d,L) = (4, 2048)$ produced compression knees $\{160, 224, 256\}$ whose median,
$224$, equals $\tfrac78 \cdot \tfrac{dL}{32}$ exactly, replicating a median of $112 = \tfrac78\cdot 128$
at half the context. We show that a fourth seed buys neither robustness nor calibration and can
confirm the median only by landing exactly on it, that a fifth restores both, and — via a
Condorcet-type convergence analysis with an exactly located crossing at $47$ seeds — we quantify
how far a three-seed centre is from being certified.

**Keywords.** order statistics, binomial upper tail, breakdown point, robust statistics,
calibration, Condorcet jury theorem, central binomial coefficient, seed ensembles.

---

## 1. Introduction

### 1.1 The reporting problem

Empirical claims about stochastic systems are almost always claims about an ensemble. One trains
a model, or runs a simulation, several times, changing nothing but a pseudo-random seed, and
obtains several numbers. The published claim is a single number. The map from the ensemble to
that number — worst case, best case, mean, median, "$k$ out of $n$" — is a *reporting
convention*, and conventions are usually defended on grounds of taste, tradition, or convenience.

This paper argues that in the ordinal setting the convention is forced. We identify a canonical
family of readings (the rungs of the quota ladder), attach to each rung two independent quality
measures — one probabilistic (calibration), one adversarial (breakdown number) — and prove that
the two measures are optimised by the same rung, and only by that rung. Since neither measure
mentions the other, the coincidence is a theorem worth isolating.

### 1.2 The measurement

The motivating data set concerns attention sparsification in autoregressive sequence models. For
a model with width parameter $d$ and context length $L$, one asks for the least per-position
retention budget $k$ such that keeping only the top-$k$ attention weights preserves held-out
accuracy above a fixed fraction of the dense-attention reference. Call that least $k$ the
**knee**.

At $(d, L) = (4, 1024)$, three seeds gave knees $\{96, 112, 128\}$. At $(d, L) = (4, 2048)$, three
seeds gave $\{256, 224, 160\}$. Writing $P = dL/32$ for the natural product scale ($P = 128$ and
$P = 256$ respectively), the two knee sets are
$$\{0.75P,\; 0.875P,\; 1.0P\} \quad\text{and}\quad \{0.625P,\; 0.875P,\; 1.0P\},$$
with medians $112 = \tfrac78 \cdot 128$ and $224 = \tfrac78 \cdot 256$ — exactly $\tfrac78 P$ in both
cases. Four point predictions had been registered in advance for the third long-context seed
($224$, $240$, $256$, $192$); the measured value $160$ refuted all four, while the prediction about
the *median of the distribution* held exactly. The spread widened with context (from $0.25P$ to
$0.375P$), entirely in the low tail; the upper edge stayed pinned at $P$, and the product bound
$k^\star \le P$ held for all six seeds across both contexts.

This is the empirical shape the theory must explain: per-seed readings noisy, the centre stable.

### 1.3 Contributions

1. **Quota ladders and rungs** (§2): a definition of the readings of a seed ensemble that is
   simultaneously order-statistical and operational.
2. **The rung distribution function and the parity law of calibration** (§3): $R_n(m,p)$ is the
   binomial upper tail; it is calibrated at $p = 1/2$ iff $2m = n+1$; existence of a calibrated
   rung is equivalent to odd ensemble size; the even defect is computed, bracketed, and its exact
   asymptotic constant $1/(2\sqrt{\pi})$ identified.
3. **The exact breakdown number** (§4): a two-sided bracket with matching sharpness in both
   directions gives $\beta(n,m) = \min(m-1, n-m)$, and the achievable readings below breakdown are
   exactly the clean interval $[Q(m-c), Q(m+c)]$.
4. **The dichotomy** (§5): calibrated $\iff$ maximally robust, for odd $n$; simultaneous failure
   of both for even $n$.
5. **Convergence and cost** (§6): Condorcet monotonicity of the median rung, a geometric rate, a
   sharpened one-term rate, an exactly located crossing at $47$ seeds for $1\%$ at $p = 2/3$, and
   a negative result showing the sharpened route cannot reach $47$.
6. **Window width** (§7): the conjecture that the median minimises the contamination window is
   refuted in general and proved under centre-minimality of the ladder's gaps.
7. **Application** (§8): the fourth-seed and fifth-seed verdicts for the measured cell, and the
   honest limits on the empirical median law.

---

## 2. Quota ladders

Let $\iota$ be a finite index set of seeds, $n = |\iota|$, and let $K : \iota \to \mathbb{N}$ assign
to each seed its knee: the least budget at which that seed's run clears the bar. (Only the
ordinal structure matters; $\mathbb{N}$ is used for concreteness.)

**Definition 2.1 (Pass set).** For a budget $b$, the pass set is
$\mathrm{Pass}_K(b) = \{ i \in \iota : K(i) \le b \}$.

**Definition 2.2 (Quota ladder).** For $m \in \mathbb{N}$, the $m$-th rung is
$$Q_K(m) \;=\; \min\{\, b : |\mathrm{Pass}_K(b)| \ge m \,\},$$
the least budget at which at least $m$ seeds clear the bar.

Three elementary facts are used throughout and follow immediately from the definition:
$Q_K$ is monotone non-decreasing in $m$; $Q_K(0) = 0$; and $|\mathrm{Pass}_K(Q_K(m))| \ge m$ whenever
$m \le n$, so the minimum is attained.

**Proposition 2.3 (Rungs are order statistics).** For $1 \le m \le n$, $Q_K(m)$ is the $m$-th
smallest value of $K$. In particular $Q_K(1) = \min_i K(i)$ (the best case), $Q_K(n) = \max_i K(i)$
(the guarantee), and for $n = 2r+1$, $Q_K(r+1)$ is the median.

*Proof sketch.* $|\mathrm{Pass}_K(b)| \ge m$ holds iff $b$ is at least the $m$-th smallest value of
$K$; take the least such $b$. $\square$

The operational reading matters: rung $m$ is the answer to "what budget makes at least $m$ of my
$n$ seeds work?" The guarantee rung $m = n$ is what a deployment SLA quotes; the median rung is
what a paper reports as typical.

---

## 3. The rung distribution function and the parity law

### 3.1 The binomial upper tail

Fix a budget and suppose each seed clears the bar there independently with probability $p$.
Rung $m$ sits at or below the budget iff at least $m$ seeds clear it. Hence:

**Definition 3.1.** The *rung distribution function* is
$$R_n(m,p) \;=\; \sum_{j = m}^{n} \binom{n}{j} p^{\,j}(1-p)^{\,n-j}, \qquad 0 \le p \le 1 .$$

**Proposition 3.2 (Basic structure).** For $0 \le p \le 1$:
1. $R_n(0,p) = 1$ and $R_n(m,p) = 0$ for $m > n$;
2. $R_n(\cdot,p)$ is antitone in the quota, and $R_n(m,\cdot)$ is monotone in $p$, strictly so for
   $1 \le m \le n$ and $0 < p < q < 1$;
3. (*Pascal recursion*) $R_{n+1}(m+1,p) = p\,R_n(m,p) + (1-p)\,R_n(m+1,p)$;
4. (*One-term rung gap*) for $m \le n$,
   $R_n(m,p) - R_n(m+1,p) = \binom{n}{m}p^m(1-p)^{n-m}$.

*Proof sketch.* (1) is the binomial theorem applied to $(p + (1-p))^n$ and the empty sum. (2)
antitonicity is a sum over a smaller index set of non-negative terms; monotonicity in $p$ is an
induction on $n$ through (3), with strictness supplied by (4), which is the isolation of the
$j = m$ term. (3) conditions on the last seed and uses $\binom{n+1}{i+1} = \binom{n}{i} + \binom{n}{i+1}$
after an index shift. $\square$

### 3.2 Calibration

**Definition 3.3.** Rung $m$ of an $n$-seed ensemble is **calibrated** if $R_n(m,\tfrac12) = \tfrac12$.

A calibrated rung is one that does not lean: on an ensemble of fair coins, i.e. on maximally
uninformative data, it reports "at or below budget" exactly half the time. Any asymmetry it
subsequently exhibits is attributable to the data, not to the convention.

At $p = 1/2$ every outcome has the same weight, so $R_n(m,\tfrac12) = T(n,m)/2^n$ with
$T(n,m) = \sum_{j\ge m}\binom{n}{j}$ the tail count.

**Lemma 3.4 (Reflection).** For $m \le n+1$, $T(n,m) + T(n,\,n+1-m) = 2^{\,n}$, and $T(n,\cdot)$ is
strictly decreasing on $\{0,1,\dots,n+1\}$.

*Proof sketch.* Substituting $j \mapsto n-j$ maps the tail $\{j \ge m\}$ onto the head
$\{j \le n-m\}$ and $\binom{n}{j}\mapsto\binom{n}{n-j}$, so the two counts partition
$\sum_j \binom{n}{j} = 2^n$. Strict decrease holds because each step removes a positive binomial
coefficient. $\square$

**Theorem 3.5 (Parity law of calibration).** For $m \le n+1$,
$$R_n(m,\tfrac12) = \tfrac12 \iff 2m = n+1 .$$
Consequently: an $n$-seed ensemble has a calibrated rung iff $n$ is odd; when $n = 2r+1$ the
calibrated rung is unique, namely the median $m = r+1$; and when $n$ is even no rung is
calibrated.

*Proof sketch.* $R_n(m,\tfrac12) = \tfrac12$ means $2\,T(n,m) = 2^n$, i.e. $T(n,m) = T(n,n+1-m)$ by
Lemma 3.4. Strict monotonicity of $T(n,\cdot)$ forces $m = n+1-m$. Conversely, $2m = n+1$ makes the
reflection identity read $2T(n,m) = 2^n$. Oddness of $n$ is exactly solvability of $2m = n+1$ in
integers. $\square$

### 3.3 The calibration defect of an even ensemble

**Definition 3.6.** $\displaystyle \delta_r = \frac{1}{2^{2r+1}}\binom{2r}{r}$.

**Theorem 3.7 (Even central rungs).** For every $r$,
$$R_{2r}(r,\tfrac12) = \tfrac12 + \delta_r, \qquad R_{2r}(r+1,\tfrac12) = \tfrac12 - \delta_r,$$
with $\delta_r > 0$; hence the two central rungs of an even ensemble average to exactly $\tfrac12$.

*Proof sketch.* The two rungs differ by the single central binomial term
$\binom{2r}{r}2^{-2r}$ (Proposition 3.2(4) at $p = 1/2$), while by reflection they sum to $1$.
Solving the two linear equations gives the displayed values. $\square$

The averaging statement is precisely the textbook convention "the median of an even sample is the
mean of the two middle order statistics"; Theorem 3.7 shows it is the unique repair of a
measurable parity defect rather than an arbitrary tie-break.

**Theorem 3.8 (Defect decay).** $\delta_{r+1} < \delta_r$ for all $r$, and $\delta_r \to 0$.
Quantitatively, for all $r$,
$$16^{\,r} \;\le\; \binom{2r}{r}^{2}(4r+1) \qquad\text{and}\qquad \binom{2r}{r}^{2}(3r+1) \;\le\; 16^{\,r},$$
whence the sandwich
$$\frac{4^{\,r}}{\sqrt{4r+1}} \;\le\; \binom{2r}{r} \;\le\; \frac{4^{\,r}}{\sqrt{3r+1}},
\qquad \frac{1}{2\sqrt{4r+1}} \;\le\; \delta_r \;\le\; \frac{1}{2\sqrt{3r+1}} .$$
In particular $\delta_r \sqrt{r} \in [\,1/(2\sqrt5),\, 1/(2\sqrt3)\,] = [0.2236\ldots,\, 0.2887\ldots]$
for $r \ge 1$, and $\sum_r \delta_r$ diverges.

*Proof sketch.* Both inequalities are inductions through the central binomial recursion
$(r+1)\binom{2r+2}{r+1} = 2(2r+1)\binom{2r}{r}$; in the lower bound the induction slack is exactly
$1$, which is why the constant $4r+1$ cannot be improved to $4r$ by this route. Division by
$2^{2r+1}$ converts the sandwich on $\binom{2r}{r}$ into the sandwich on $\delta_r$, and
$\delta_r \ge 1/(4(r+1))$ (a consequence of the lower bound) gives divergence by comparison with
the harmonic series. $\square$

**Theorem 3.9 (Exact asymptotic constant).** $\displaystyle \lim_{r\to\infty} \delta_r\sqrt{r} = \frac{1}{2\sqrt{\pi}} = 0.28209\ldots$
Equivalently, $\binom{2r}{r}\sqrt{r}/4^{\,r} \to 1/\sqrt{\pi}$.

*Proof sketch.* Write $s_r = r!\,/\bigl(\sqrt{r}\,(r/e)^r\bigr)$ for the Stirling sequence. A purely
algebraic cancellation of factorials gives, for $r \ge 1$, the identity
$$\frac{s_{2r}}{s_r^{2}} \;=\; \frac{\binom{2r}{r}\sqrt{r}}{4^{\,r}} .$$
Since $s_r \to \sqrt{2\pi}$, the left-hand side tends to $\sqrt{2\pi}/(2\pi) = 1/\sqrt{\pi}$.
Dividing by $2$ gives the defect constant. $\square$

Since $1/(2\sqrt5) \le 1/(2\sqrt{\pi}) \le 1/(2\sqrt3)$, Theorem 3.9 is consistent with Theorem 3.8,
and the consistency statement is exactly $3 \le \pi \le 5$ — read off a ladder of ensembles rather
than a circle. The practical reading of Theorems 3.7–3.9: an even ensemble is asymptotically, but
never exactly, calibrated, and it approaches calibration only at the slow rate
$\delta_r \approx 1/(2\sqrt{\pi r})$.

---

## 4. Robustness: the exact breakdown number

We now discard the probability model. Let $K, K' : \iota \to \mathbb{N}$ be two knee assignments
that **agree outside** a set $S \subseteq \iota$ of *corrupted* seeds: $K(i) = K'(i)$ for all
$i \notin S$. The question is how far $Q_{K'}(m)$ can move from $Q_K(m)$.

**Theorem 4.1 (Two-sided bracket).** Let $|S| \le c \le m-1$ and $m + c \le n$. Then
$$Q_K(m-c) \;\le\; Q_{K'}(m) \;\le\; Q_K(m+c) .$$

*Proof sketch.* The upper bound is the monotone comparison "if $K$ and $K'$ agree off $S$ then
$Q_{K'}(m) \le Q_K(m + |S|)$", which holds because any budget at which $m + |S|$ seeds pass under
$K$ has at least $m$ of those passers outside $S$, hence passing under $K'$ too. The lower bound
is the same statement with the roles of $K$ and $K'$ exchanged, followed by monotonicity of
$Q_K$. $\square$

**Definition 4.2 (Breakdown number).** $\beta(n,m) = \min(m-1,\; n-m)$.

**Corollary 4.3 (Containment below breakdown).** If $1 \le m \le n$ and $|S| \le \beta(n,m)$, then
$$Q_K(1) \;\le\; Q_{K'}(m) \;\le\; Q_K(n),$$
i.e. the corrupted reading still lies inside the clean ensemble's own range.

The next two theorems show $\beta$ is exactly right: one more corrupted seed than $\beta(n,m)$
destroys the rung, in whichever direction the adversary prefers.

**Theorem 4.4 (Upward breakdown).** Let $m \le n$ and $|S| > n - m$. Then for every bound $B$ there
is a $K'$ agreeing with $K$ off $S$ with $Q_{K'}(m) \ge B$.

*Proof sketch.* Set $K'(i) = B$ for $i \in S$ and $K'(i) = K(i)$ otherwise. Suppose
$Q_{K'}(m) < B$. Every seed in $\mathrm{Pass}_{K'}(Q_{K'}(m))$ then lies outside $S$, so that pass set
has at most $n - |S| < m$ elements, contradicting $|\mathrm{Pass}_{K'}(Q_{K'}(m))| \ge m$. $\square$

**Theorem 4.5 (Downward breakdown).** If $|S| \ge m$ then there is a $K'$ agreeing with $K$ off $S$
with $Q_{K'}(m) = 0$.

*Proof sketch.* Set $K'(i) = 0$ on $S$. Then $S \subseteq \mathrm{Pass}_{K'}(0)$, so the quota is met
at budget $0$. $\square$

**Corollary 4.6 (Exact breakdown number).** The $m$-th rung of an $n$-seed ensemble tolerates
exactly $\min(m-1,\,n-m)$ corrupted seeds: at that level the reading is confined to the clean
bracket of Theorem 4.1, and at one level more it can be driven to $0$ (if $m-1$ is the binding
term) or above any bound (if $n-m$ is).

Two consequences deserve emphasis. First, the **guarantee rung** $m = n$ and the **best-case rung**
$m = 1$ both have $\beta = 0$: a single corrupted seed suffices to make either reading arbitrary.
Deployment guarantees are the *most* fragile reading, not the safest. Second, in a three-seed
ensemble the median is the only rung with a positive breakdown number.

**Theorem 4.7 (Contamination curve).** For $1 \le m \le n$ and $c \le \beta(n,m)$, the set of readings
of rung $m$ achievable by corrupting at most $c$ seeds is *exactly* the set of clean rungs in
$[\,Q_K(m-c),\, Q_K(m+c)\,]$, both endpoints attained.

*Proof sketch.* Containment is Theorem 4.1. For attainment, corrupt the $c$ seeds with the
largest knees, setting them to a huge value, to realise the upper endpoint; corrupt the $c$ with
the smallest knees, setting them to $0$, to realise the lower endpoint. $\square$

Thus the maximal adversarial bias at contamination level $c$ equals the clean spread
$Q_K(m+c) - Q_K(m-c)$, and $\beta(n,m)$ is exactly the level at which that spread ceases to be
finite.

---

## 5. The dichotomy

**Lemma 5.1.** For $n = 2r+1$ and $1 \le m \le n$: $\beta(n,m) \le r$, with equality iff $m = r+1$.

*Proof sketch.* $\min(m-1, 2r+1-m) \le r$ since the two arguments sum to $2r$; equality in the
minimum requires $m-1 \ge r$ and $2r+1-m \ge r$, i.e. $m = r+1$. $\square$

**Theorem 5.2 (Calibration–Robustness Dichotomy).** Let $n = 2r+1$ and $1 \le m \le n$. Then
$$R_n\!\left(m,\tfrac12\right) = \tfrac12 \quad\Longleftrightarrow\quad \beta(n,m) = r .$$
That is, a rung is calibrated on coin-flip seeds if and only if it is maximally robust to
corrupted seeds.

*Proof sketch.* By Theorem 3.5 the left side is equivalent to $2m = n+1$, i.e. $m = r+1$; by
Lemma 5.1 the right side is equivalent to the same. $\square$

The content is not the chain of equivalences but the fact that the two sides were derived from
disjoint premises: the left from a symmetry of binomial coefficients (a parity constraint), the
right from counting how many seeds an adversary must buy (a combinatorial constraint). They pin
the same index. "Read the median" is therefore a theorem, not a convention.

**Theorem 5.3 (Even ensembles fail on both sides).** Let $n = 2r$ with $r \ge 1$. Then
1. $\beta(2r, m) \le r-1$ for all $1 \le m \le 2r$;
2. $\beta(2r, r) = \beta(2r, r+1) = r-1$ — the maximum is attained by two distinct rungs;
3. no rung is calibrated: $R_{2r}(m,\tfrac12) \ne \tfrac12$ for every $m$.

*Proof sketch.* (1) and (2) are arithmetic on $\min(m-1, 2r-m)$; (3) is Theorem 3.5. $\square$

Parity is thus a single obstruction to a canonical centre, visible simultaneously in the
probability and in the robustness. An even ensemble has no centre in either sense, and the two
failures are not independent pathologies but two faces of $2m = n+1$ being unsolvable.

---

## 6. How many seeds certify a centre?

The dichotomy says *which* rung to read. A separate question is *how many seeds* make that
reading reliable. Suppose again that each seed clears the bar independently with probability
$p > 1/2$; then the median rung is a Condorcet jury.

**Theorem 6.1 (Condorcet monotonicity of the ladder).** For $1/2 \le p \le 1$ the median rung
probability $R_{2r+1}(r+1,p)$ is non-decreasing in $r$, strictly increasing when $1/2 < p < 1$; for
$0 < p < 1/2$ it is strictly decreasing. In particular $R_{2r+1}(r+1,p) \ge p$ for $p \ge 1/2$: the
ensemble median is at least as reliable as one seed, and strictly better from $r \ge 1$ on.

*Proof sketch.* The step from $r$ to $r+1$ has the exact closed form
$$R_{2r+3}(r+2,p) - R_{2r+1}(r+1,p) \;=\; \binom{2r+1}{r}\bigl(p(1-p)\bigr)^{r+1}(2p-1),$$
obtained by applying the Pascal recursion twice and cancelling; its sign is the sign of
$2p-1$. $\square$

**Theorem 6.2 (Geometric rate).** For $1/2 \le p \le 1$,
$$1 - R_{2r+1}(r+1,p) \;\le\; 2(1-p)\bigl(4p(1-p)\bigr)^{r} .$$

*Proof sketch.* Telescoping the exact step of Theorem 6.1 from $r$ to $\infty$ and bounding
$\binom{2r+1}{r} \le 4^{r}$ yields a geometric series in $4p(1-p) < 1$. $\square$

**Theorem 6.3 (Sharpened rate).** For $1/2 < p \le 1$,
$$1 - R_{2r+1}(r+1,p) \;\le\; \frac{\binom{2r+1}{r}\bigl(p(1-p)\bigr)^{r+1}}{2p-1},$$
and this bound is at least as good as Theorem 6.2's for $p \ge 2/3$. Combining with the sandwich
of Theorem 3.8 gives the Stirling-improved form
$$1 - R_{2r+1}(r+1,p) \;\le\; \frac{2p(1-p)\bigl(4p(1-p)\bigr)^{r}}{(2p-1)\sqrt{3r+4}} .$$

*Proof sketch.* Keep the exact binomial factor in the telescoped tail instead of bounding it by
$4^r$, and sum the geometric factor $\bigl(p(1-p)\bigr)^{r}$ against the ratio bound; the last
display substitutes $\binom{2r+1}{r} = \tfrac12\binom{2r+2}{r+1} \le \tfrac12\cdot 4^{\,r+1}/\sqrt{3r+4}$. $\square$

**Theorem 6.4 (Exact crossing at $p = 2/3$).** $1 - R_{47}(24,\tfrac23) \le \tfrac{1}{100}$ while
$1 - R_{45}(23,\tfrac23) > \tfrac{1}{100}$. Hence the median rung of an odd ensemble at per-seed
frequency $2/3$ is certified to within $1\%$ **iff** the ensemble has at least $47$ seeds.

*Proof sketch.* Exact rational evaluation of two binomial tails. $\square$

**Theorem 6.5 (No sharp route to $47$).** Any bound $B(r)$ dominating the sharpened rate of
Theorem 6.3 fails to certify $1\%$ at $r = 23$ (i.e. $47$ seeds), because the sharpened rate itself
already exceeds $1/100$ there. The sharpened route certifies at $49$ seeds; the crude rate of
Theorem 6.2 needs $73$.

*Proof sketch.* Numerical evaluation of the two bounds at $r = 23, 24, 35, 36$. $\square$

The gap $47 < 49 < 73$ is therefore a property of the proof technique, exactly quantified rather
than hidden.

**Proposition 6.6 (Where the measurement stands).** At $p = 2/3$ the three-seed median rung has
$R_3(2,\tfrac23) = 20/27$, so its miss probability is $7/27 \approx 25.9\%$.

*Proof sketch.* $R_3(2,p) = 3p^2 - 2p^3$; evaluate. $\square$

A three-seed centre is thus a point estimate with a one-in-four failure probability *under its
own frequency model* — not a certified centre. This is the sharpest honest limit the theory puts
on the empirical median law of §1.2.

---

## 7. Is the median also the narrowest reading?

By Theorem 4.7 the deployment-relevant uncertainty of rung $m$ at contamination level $c$ is the
**window width**
$$W(m,c) \;=\; Q(m+c) - Q(m-c),$$
so it is natural to conjecture that the median minimises $W(\cdot,c)$ for every sample, matching
the parity law's choice. The verdict is split.

**Theorem 7.1 (Refutation in general).** There is a five-seed sample whose median window is
strictly wider than an off-centre window: take knees $\{0,0,0,10,20\}$ — three seeds agreeing and
two stragglers. Its ladder is $Q = (0,0,0,10,20)$, so at radius $c = 1$ the median window is
$W(3,1) = Q(4) - Q(2) = 10$, while $W(2,1) = Q(3) - Q(1) = 0$.

*Proof sketch.* Direct computation of the ladder. $\square$

The minimiser of the width follows the sample's *gaps*, not its centre.

**Definition 7.2.** Write $g(j) = Q(j) - Q(j-1)$ for the $j$-th gap and let
$\mathrm{cd}(n,j) = |n - 2j|$ measure how far the gap sits from the centre of the ladder. The ladder is
**centre-minimal** if $\mathrm{cd}(n,j) \le \mathrm{cd}(n,k)$ implies $g(j) \le g(k)$: gaps nearer the
middle are smaller. This is the behaviour of order statistics of a unimodal law.

**Theorem 7.3 (Minimality under centre-minimality).** If the ladder of a $(2r+1)$-seed ensemble is
monotone and centre-minimal, then for every radius $c \le r$ the median window is narrowest:
$W(r+1,c) \le W(m,c)$ for all admissible $m$.

*Proof sketch.* An exact step criterion drives a two-sided induction: moving a window one rung
outward changes its width by $g(\text{gap taken in}) - g(\text{gap let out})$, so the window widens
exactly when the incoming gap exceeds the outgoing one. Centre-minimality makes every outward
step non-improving on both sides of the centre. $\square$

**Proposition 7.4 (The measured sample is not centre-minimal).** For the three-seed sample
$\{160, 224, 256\}$ the gaps are $g(2) = 64$ and $g(3) = 32$, which are equidistant from the centre
of a three-rung ladder yet unequal; centre-minimality holds only vacuously, and correspondingly
the conclusion is empty, since $\beta(3,2) = 1$ while $\beta(3,1) = \beta(3,3) = 0$ — at three seeds
the median is the only rung with a contamination window at all.

Hence at the measured cell the median's robustness is *not* explained by narrowness; it is
explained by the breakdown number. The mechanism of Theorem 7.3 first has content at five seeds.

---

## 8. Application: the fourth seed, the fifth seed, and the median law

### 8.1 The three-seed reading

For the sample $K = \{160, 224, 256\}$ at $(d,L) = (4,2048)$ the ladder is
$$Q(1) = 160,\qquad Q(2) = 224,\qquad Q(3) = 256,$$
and $Q(2) = 224 = \tfrac78 \cdot \tfrac{4\cdot 2048}{32} = \tfrac78 P$. By Theorem 5.2 the rung $m = 2$
is the unique calibrated, maximally robust rung: $\beta(3,2) = 1$ and $R_3(2,\tfrac12) = \tfrac12$;
by Theorem 4.7 its contamination curve at $c = 1$ is exactly $[160, 256]$, a maximal bias of
$-64/+32$ — the full clean spread. By Theorem 4.4 the guarantee rung $m = 3$ has $\beta(3,3) = 0$
and can be pushed above any bound by a single bad seed.

### 8.2 What a fourth seed does

Let $x$ be a fourth seed's knee and let the four-seed reading be the usual mean of the two middle
order statistics of $\{160, 224, 256, x\}$:
$$\rho(x) \;=\; \begin{cases}
192, & x \le 160,\\[2pt]
\dfrac{x + 224}{2}, & 160 \le x \le 224,\\[4pt]
\dfrac{224 + x}{2}, & 224 \le x \le 256,\\[4pt]
240, & x \ge 256 .
\end{cases}$$
Write $\mathrm{bias}(x) = |\rho(x) - 224|$.

**Theorem 8.1 (The fourth seed can confirm but not calibrate).**
1. $\rho$ is monotone, with range $[192, 240]$, and $\mathrm{bias}(x) \le 32$ always;
2. $\mathrm{bias}(x) = 0$ iff $x = 224$; otherwise the four-seed reading is strictly worse than the
   exact three-seed median;
3. $\mathrm{bias}(x) = 32$ iff $x \le 160$, and $\mathrm{bias}(x) \le 16$ iff $x \ge 192$; the bias is
   strictly decreasing on $[160,224]$ and strictly increasing on $[224,256]$;
4. no rung of a four-seed ensemble is calibrated, the central defect being
   $\delta_2 = \binom{4}{2}/2^5 = 3/16$, so the two central rungs read $0.6875$ and $0.3125$;
5. both central rungs of a four-seed ensemble have breakdown number $\beta(4,2) = \beta(4,3) = 1$,
   no better than the three-seed median's $\beta(3,2) = 1$, and no rung of a four-seed ensemble
   exceeds $1$.

*Proof sketch.* (1)–(3) are case analysis on the four branches of $\rho$; (4) is Theorem 3.5 plus
Theorem 3.7 at $r = 2$; (5) is arithmetic on $\min(m-1, 4-m)$. $\square$

**Theorem 8.2 (The fifth seed restores both).** $\beta(5,3) = 2 > 1$ and $R_5(3,\tfrac12) = \tfrac12$:
a five-seed ensemble's median is strictly more robust than a three-seed ensemble's and is
calibrated again.

The design conclusion is unambiguous. A fourth run at the same cell purchases neither robustness
nor calibration; it can only confirm the median by landing exactly on it, and any other landing
degrades the reading. If the goal is to strengthen the centre rather than to test the low tail,
the correct increment is two seeds, not one. (If the goal is instead to *test* whether the low
tail at $0.625P$ is a stable feature of the long context or an artifact of one seed, a single
additional run is diagnostic — but it is a tail experiment, not a centre experiment, and should
be reported as such.)

### 8.3 The median law and its status

Across the two measured contexts:

| context | knee set | as multiples of $P = dL/32$ | spread | median |
|---|---|---|---|---|
| $L = 1024$, $P = 128$ | $\{96, 112, 128\}$ | $\{0.75,\,0.875,\,1.0\}$ | $0.25P$ | $112 = \tfrac78 \cdot 128$ |
| $L = 2048$, $P = 256$ | $\{160, 224, 256\}$ | $\{0.625,\,0.875,\,1.0\}$ | $0.375P$ | $224 = \tfrac78 \cdot 256$ |

Two structural observations follow from the ladder viewpoint. First, the upper edge is pinned:
the product bound $k^\star \le P$ held for all six seeds, so it functions as a six-seed-verified
deployment guarantee — but note that as a *rung* it is the guarantee rung, with breakdown number
$0$, so its empirical robustness is a property of the data, not of the reading. Second, the
widening of the spread occurs entirely in the low tail, which is exactly the rung with the other
zero breakdown number; the centre, the only rung with positive breakdown number at three seeds,
is the one that repeated.

Finally, Proposition 6.6 bounds what may be claimed: under the frequency model with $p = 2/3$, a
three-seed centre carries a $7/27 \approx 26\%$ miss probability, and certification at the $1\%$
level would require $47$ seeds. The median law is a robust, twice-replicated structural reading —
not a certified one.

---

## 9. Algorithms

Three procedures suffice to compute every quantity in this paper; all are elementary, and we
record their complexity.

**Algorithm A (Quota ladder).** Given knees $K(1),\dots,K(n)$, sort them ascending; then
$Q(m)$ is the $m$-th entry, $Q(0) = 0$. Cost $O(n\log n)$, or $O(n)$ with counting sort on a bounded
budget grid. All rung readings, gaps, windows, and contamination curves are $O(1)$ look-ups
afterwards.

**Algorithm B (Breakdown table and contamination curve).** For each $m$, $\beta(n,m) = \min(m-1,n-m)$
in $O(1)$; the achievable interval at level $c \le \beta(n,m)$ is $[Q(m-c), Q(m+c)]$, and the maximal
bias is $\max\bigl(Q(m+c)-Q(m),\, Q(m)-Q(m-c)\bigr)$. Building the whole table costs $O(n^2)$
look-ups, or $O(n)$ per contamination level.

**Algorithm C (Rung tail and certification search).** Evaluate $R_n(m,p)$ by the backward
recurrence on binomial terms $t_j = \binom{n}{j}p^j(1-p)^{n-j}$, using
$t_{j+1} = t_j \cdot \tfrac{(n-j)p}{(j+1)(1-p)}$: cost $O(n-m)$ multiplications and no factorials.
To locate the certification threshold at a target miss level $\varepsilon$, scan $r = 0,1,2,\dots$
computing $1 - R_{2r+1}(r+1,p)$ until it drops below $\varepsilon$; the miss probability is strictly
decreasing in $r$ for $p > 1/2$ (Theorem 6.1), so the first crossing is the answer, and the
geometric rate of Theorem 6.2 bounds the scan length by $O\bigl(\log(1/\varepsilon)/\log\frac{1}{4p(1-p)}\bigr)$.
Exact rational arithmetic makes the located crossing (e.g. $47$ at $p = 2/3$, $\varepsilon = 10^{-2}$)
a certificate rather than a floating-point artifact.

---

## 10. Discussion

### 10.1 Relation to classical robust statistics

The breakdown point of the sample median is classically $\lfloor (n-1)/2\rfloor / n \to 1/2$, and
that of an extreme order statistic is $0$. Corollary 4.6 refines this into an exact per-rung
count, $\beta(n,m) = \min(m-1, n-m)$, in a setting where the reading is defined operationally (least
budget meeting a quota) rather than as a function of a data vector. What is new here is not the
value at the median but the *equivalence* of Theorem 5.2: the same index is selected by a
calibration condition that never mentions corruption. Classical robustness theory optimises a
breakdown criterion; classical calibration theory optimises an unbiasedness criterion; in the
ordinal ensemble setting these are the same optimisation.

### 10.2 Parity as the obstruction

Theorem 5.3 is the sharpest form of the message. One is tempted to see the failure of even
ensembles as a cosmetic tie-break issue. It is not: the defect $\delta_r$ is a measurable
quantity of size $\approx 1/(2\sqrt{\pi r})$, non-summable, and the robustness failure (two rungs
tie for maximal breakdown) is simultaneous. Averaging the two central rungs repairs the
calibration exactly (Theorem 3.7) but cannot repair the tie in breakdown, since the averaged
reading inherits $\beta = r-1$.

### 10.3 Practical guidance

* Report the median of an **odd** ensemble; it is the unique reading that neither leans on
  uninformative data nor collapses under a single anomaly.
* Treat published **guarantees** (max over seeds) as maximally fragile: $\beta = 0$. A guarantee
  from $n$ seeds is not a stronger claim than a median from $n$ seeds; it is a weaker one, more
  sensitive to a single bad run.
* When budgeting compute, increase ensembles by **two**, not one. Going $3 \to 4$ buys nothing on
  either axis; $3 \to 5$ buys a strict robustness increment and restores calibration.
* Quote the contamination curve $[Q(m-c), Q(m+c)]$, not a symmetric error bar: adversarial bias in
  an ordinal ensemble is generally asymmetric (here $-64/+32$).

### 10.4 Limitations

The probability model treats seeds as exchangeable Bernoulli trials at a fixed budget; real seeds
may be dependent (shared data order, shared hyperparameters) and their pass probability varies
with the budget. The breakdown analysis is worst-case over corruption sets and hence conservative
for benign noise. The empirical median law rests on two contexts and six seeds; Proposition 6.6
quantifies exactly how far that is from certification. Theorem 7.3's centre-minimality hypothesis
is not verifiable at three seeds.

---

## 11. Future directions

**Seed-ensemble rung theory: where the thread stands.**

Earlier cycles built the general-$n$ theory of the rung distribution function $R_n(m,p)$ — the
binomial upper tail that a seed ensemble's quota ladder induces — and proved the parity law of
calibration, the one-monomial Condorcet gap, a geometric convergence rate, and the exact
two-sided breakdown number $\min(m-1, n-m)$ of a rung. A later cycle closed the questions of
whether a fourth seed can calibrate (it can confirm but not calibrate), established the sharpened
rate $\binom{2r+1}{r}(p(1-p))^{r+1}/(2p-1)$ with the exact crossing $47$, showed that the ladder
*proves* the central-binomial generating function, and refuted the conjecture that the even
ensemble read at its upper central rung is safer — it is strictly riskier.

The subsequent cycle settled the following list:

| conjecture | outcome |
|---|---|
| **D1** — Stirling closes the $47$-versus-$49$ gap | **split verdict.** Structural half **closed**: the missing lower bound $16^r \le \binom{2r}{r}^2(4r+1)$ is proved by induction through the recursion $(r+1)\binom{2r+2}{r+1} = 2(2r+1)\binom{2r}{r}$ (slack exactly $1$), giving the sandwich $4^r/\sqrt{4r+1} \le \binom{2r}{r} \le 4^r/\sqrt{3r+1}$, the exact $r^{-1/2}$ defect rate $\delta_r\sqrt r \in [1/(2\sqrt5), 1/(2\sqrt3)]$, non-summability of the defects, and the Stirling-improved rate $2p(1-p)(4p(1-p))^r/((2p-1)\sqrt{3r+4})$. Numerical half **refuted**: *no* bound dominating the sharpened rate can certify $1\%$ at $47$ seeds, because the sharpened rate itself already exceeds $1/100$ there while the truth does not. |
| **D2** — the dichotomy under contamination | **closed in finite-sample form**: for contamination level $c$ below the breakdown number, the achievable readings of the $m$-th rung are *exactly* the clean readings in $[Q(m-c), Q(m+c)]$ — the bracket is attained at both ends, so the maximal bias equals the clean spread and the breakdown number is the level at which that spread stops being finite. |
| **D3** — every offset rung has its own generating function | **closed**: for each fixed offset $k$, the off-centre ladder started at its smallest ensemble sums to exactly $1 - p^{2k+1} = (1-p)(1 + p + \cdots + p^{2k})$, i.e. the conjectured $(1-p)R_k(p)$ with $R_k$ the geometric polynomial of length $2k+1$; $k = 0$ recovers the earlier cycle's $1 - p$. |

**Open directions.**

* **The low-tail experiment.** A fourth seed at the long context is diagnostic for the tail, not
  the centre: a fourth knee in $\{160, 192\}$ would establish the $0.625P$ low tail as a stable
  feature of the $16\times$ cell, while a value in $\{224, 256\}$ would mark it seed-specific. The
  centre question requires a fifth seed.
* **Dependent seeds.** Replace independent Bernoulli seeds by an exchangeable model with positive
  correlation and ask whether the parity law survives; the reflection identity is a symmetry of
  the *uniform* measure on outcomes, so the natural conjecture is that calibration persists for
  any exchangeable symmetric law, with the defect formula changing.
* **Continuous budgets.** Extend the contamination curve from an ordinal ladder to a continuous
  budget axis, where the window width becomes a quantile spread and centre-minimality becomes a
  log-concavity hypothesis on the knee density.
* **Beyond the median functional.** Characterise all reading functionals (not only rungs) that are
  simultaneously calibrated and of maximal breakdown; the averaging repair for even ensembles
  suggests the answer is the family of symmetric convex combinations of central rungs, with a
  strict robustness penalty for every non-degenerate combination.
* **Cost-optimal ensemble design.** Given a per-seed cost and a target certification level, the
  crossing analysis of §6 turns ensemble sizing into an integer program; the exact crossing at
  $47$ seeds for $p = 2/3$ and $\varepsilon = 10^{-2}$ is the first data point of a table worth
  computing in general.

---

## 12. Conclusion

An ensemble of stochastic runs offers a ladder of readings, one per quota. Each rung carries a
probabilistic quality (does it lean on uninformative data?) and an adversarial quality (how many
corrupted runs does it survive?). We proved that the first is measured by a parity condition,
$2m = n+1$; the second by an exact count, $\min(m-1, n-m)$; and that for odd ensembles the two
select the same rung and only that rung. For even ensembles both fail together, the calibration
defect being $\binom{2r}{r}2^{-(2r+1)} \sim 1/(2\sqrt{\pi r})$ and the maximal breakdown number
being attained twice.

Applied to a measurement whose per-seed readings were $\{160, 224, 256\}$, the theory explains
precisely why four sharp point predictions could all fail while the prediction about the centre
held: the centre is the only functional of a three-seed ensemble with a positive breakdown number,
and it is the only calibrated one. It also delivers an unwelcome but actionable design verdict —
the next seed should be the fifth, not the fourth — and an honest bound on what three seeds can
claim.
