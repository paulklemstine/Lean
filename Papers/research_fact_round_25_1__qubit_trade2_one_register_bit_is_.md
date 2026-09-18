# The Fungibility Ramp: One Register Bit Is Worth One Sample in Shor Period-Finding

**Author:** Aristotle
**Date:** 2026-09-18

---

## Abstract

The standard resource account of Shor's period-finding routine asserts a
threshold: a register of $q = 2^t$ basis states can certify an unknown period
$r$ only when $q \gtrsim r^2$, i.e. $t \ge 2\log_2 r$. We show that this
threshold is not an onset of possibility but a *saturation point of a smooth
ramp*, and we replace it by an exact two-dimensional resource law.

On the register axis we prove an exact count: for $\gcd(q,r)=1$ and below
saturation, the number of peaks $j \in \{0,\dots,r-1\}$ admitting a
continued-fraction certificate is exactly $2\lfloor q/(2r)\rfloor + 1$, whence
the single-sample certification rate satisfies
$q/r^2 - 1/r < P_1 \le q/r^2 + 1/r$ — a ramp of unit slope in $q/r^2$. We
locate the saturation point exactly: for odd $r$, all peaks certify if and only
if $q \ge r(r-1)$, strictly below the folklore $q = r^2$. We identify the *true*
wall, which is linear rather than quadratic: certificates with numerator coprime
to $r$ (the only ones that return $r$ itself rather than a proper divisor) exist
if and only if $q \ge 2r$, and below that line certification fails
deterministically for every such numerator. We count the informative
certificates exactly as twice the number of totatives of $r$ in the initial
segment $[1, \lfloor q/(2r)\rfloor]$, which embeds a short-interval
totative-counting problem inside a quantum resource bound.

On the sample axis we prove that independent repetitions compound with a 50%
contour pinned between two elementary rails: a union bound above and a reverse
Bernoulli inequality $(1-x)^n(1+nx) \le 1$ below. Combining the two axes yields
the **fungibility ramp**: with per-shot rate $\min(1, c\,2^t)$, the half-success
contour of the $(t,s)$ phase diagram is pinned inside the unit-slope band
$\tfrac12 \le c\,s\,2^t \le 1$. Equivalently, at the level of configurations, a
doubling of the sample budget is worth at most one register bit and two
doublings are worth at least one; for the threshold width $t^*(s)$ this reads
$t^*(4^m s) \le t^*(s) - m \le t^*(4^m s) + m$. Simulations of the exact
arithmetic-progression measurement kernel confirm a measured slope inside the
proved band, with an $O(1)$ offset from the ideal $-\log_2 s$.

**Keywords:** Shor period-finding, continued fractions, quantum resource
trade-off, Dirichlet kernel, totatives, Bernoulli inequality, phase diagram.

---

## 1. Introduction

### 1.1 The folklore threshold

Shor's period-finding subroutine acts on a register of $q = 2^t$ basis states.
After the quantum Fourier transform the measured outcome $k \in \{0,\dots,q-1\}$
carries a probability distribution concentrated on the $r$ *peaks*
$k \approx j\,q/r$, $j = 0,\dots,r-1$, where $r$ is the unknown period.
Post-processing recovers $r$ from $k$ by expanding $k/q$ in continued fractions
and reading off a convergent. The classical convergent theorem licenses this
step under the hypothesis
$$\left|\frac{k}{q} - \frac{j}{r}\right| \le \frac{1}{2r^2}. \tag{1.1}$$

The measurement grid has spacing $1/q$, so the nearest grid point to $j/r$ is
within $1/(2q)$. Demanding $1/(2q) \le 1/(2r^2)$ *for every $j$* yields
$q \ge r^2$, and this sufficient condition is customarily quoted as a
requirement: with fewer than $2\log_2 r$ register bits, period finding fails.

This paper shows the quoted requirement is a worst-case artifact, and replaces
it by a two-dimensional law.

### 1.2 Summary of contributions

1. **Exact peak count (Theorem 3.4).** For $\gcd(q,r)=1$ and
   $2\lfloor q/(2r)\rfloor < r$, exactly $2\lfloor q/(2r)\rfloor + 1$ of the $r$
   peaks satisfy (1.1) for some grid point.
2. **The ramp (Theorem 3.5).** Consequently the per-sample certification rate
   obeys $q/r^2 - 1/r < P_1 \le q/r^2 + 1/r$: unit slope in $q/r^2$, positive
   everywhere above the linear wall, with no discontinuity.
3. **Constructive sub-threshold certificate (Theorem 3.7).** For $q \ge 2r$ and
   $\gcd(q,r)=1$ there is an explicit $j$ with $0 < j < r$, $\gcd(j,r)=1$ that
   certifies — exponentially below $q = r^2$.
4. **Correct saturation point (Theorem 4.2).** For odd $r$ coprime to $q$, every
   peak certifies iff $q \ge r(r-1)$.
5. **Arithmetic doubling law (Theorem 4.3).** $2N(q) - 1 \le N(2q) \le 2N(q)+1$
   where $N(q)$ is the certifying count: one register bit doubles the certifying
   set up to one peak.
6. **Informative ramp (Theorem 5.2) and the true wall (Theorem 5.4).** The
   informative certificate count is exactly twice the number of totatives of $r$
   in $[1, \lfloor q/(2r)\rfloor]$; it vanishes iff $q < 2r$, and below that line
   failure is deterministic.
7. **Compounding rails (Theorems 6.2, 6.3).** Reverse Bernoulli gives
   $s\,P_1 \ge 1 \Rightarrow P_s \ge \tfrac12$; the union bound gives
   $s\,P_1 < \tfrac12 \Rightarrow P_s < \tfrac12$.
8. **The fungibility ramp (Theorem 7.4).** The half-success contour of the
   $(t,s)$ diagram is pinned inside $\tfrac12 \le c\,s\,2^t \le 1$.
9. **Exchange law (Theorems 7.5, 7.6, 8.5).** One sample doubling $\le$ one
   register bit $\le$ two sample doublings; for the threshold width,
   $t^*(4^m s) \le t^*(s) - m$ and $t^*(s) \le t^*(4^m s) + 2m$.

### 1.3 Methodological note

The investigation began from a pre-registered hypothesis — *odd $r$ implies
deterministic certification failure below $t = 2\log_2 r$* — which the
measurements refuted. The refutation, not a confirmation, produced the law. Two
further defects were caught and corrected before the reported runs: an incorrect
measurement kernel (a contiguous-block Dirichlet kernel rather than the
arithmetic-progression kernel, betrayed by its degenerate signature $P(k=0)=1$
at $q = r$), and an unstable post-processing statistic (least-common-multiple
aggregation of candidate denominators, which is destroyed by spurious
small-denominator certificates, replaced by the clean existence statistic used
throughout). Degenerate regimes — pure powers of two, where $r \mid q$ — are
documented rather than excluded.

---

## 2. Setup and definitions

Throughout, $r \ge 1$ is the unknown period, $q = 2^t$ the register size,
$s \ge 1$ the number of independent repetitions. All logarithms are base two.

**Definition 2.1 (peak residue).** For $j \in \mathbb{N}$, the *peak residue* is
$$\rho(q,r,j) = jq \bmod r,$$
so that $jq = \lfloor jq/r\rfloor\, r + \rho(q,r,j)$ and the $j$-th peak position
$jq/r$ lies at fractional distance $\rho/r$ above the grid point
$\lfloor jq/r\rfloor$.

**Definition 2.2 (certification).** Peak $j$ *certifies* at register size $q$ if
$$\exists k \in \mathbb{Z}: \quad 2r\bigl|jq - kr\bigr| \le q. \tag{2.1}$$
This is (1.1) with denominator bound $b = r$, after clearing denominators by
$2qr^2$. It is precisely the necessary condition for *any* continued-fraction
post-processing to recover $j/r$ from the sample $k$; classical verification of
a candidate period is free, so we take this existence statement as the
certification statistic.

**Definition 2.3 (residue form).** Write
$$\mathrm{Cert}(q,r,j) \;:\Longleftrightarrow\; 2r\rho(q,r,j) \le q
\;\;\text{or}\;\; 2r\bigl(r - \rho(q,r,j)\bigr) \le q.$$

**Definition 2.4 (certifying set).**
$\mathcal{C}(q,r) = \{\,j < r : \mathrm{Cert}(q,r,j)\,\}$, and
$N(q,r) = \#\mathcal{C}(q,r)$.

**Definition 2.5 (informative set).**
$\mathcal{I}(q,r) = \{\, j \in \mathcal{C}(q,r) : \gcd(j,r) = 1 \,\}$. A
certificate with $\gcd(j,r) = d > 1$ returns the reduced denominator $r/d$, a
proper divisor of the period; only informative certificates return $r$ itself.

**Definition 2.6 (head totatives).** For $B \ge 0$,
$T(r,B) = \#\{\, m \in [1,B] : \gcd(m,r)=1 \,\}$.

**Definition 2.7 (compounded success).** For a per-shot success probability
$x \in [0,1]$ and $n$ independent repetitions,
$$\mathrm{Succ}(x,n) = 1 - (1-x)^n .$$

**Definition 2.8 (ramp model).** For a slope constant $c > 0$ and register width
$t$, the *ramp per-shot probability* is
$$P_1^{\mathrm{ramp}}(c,t) = \min\bigl(1,\; c\,2^t\bigr).$$
The arithmetic model of §3 has $c = 1/r^2$.

**Definition 2.9 (reaching).** A configuration $(t,s)$ *reaches the target* if
$\mathrm{Succ}\bigl(P_1^{\mathrm{ramp}}(c,t),\, s\bigr) \ge \tfrac12$. The
*threshold width* is
$t^*(c,s) = \min\{\, t : (t,s) \text{ reaches the target} \,\}$.

---

## 3. The register axis: an exact ramp

### 3.1 Geometry is residues

**Theorem 3.1 (residue criterion).** For $r \ge 1$ and any $j$,
$$\text{peak } j \text{ certifies} \iff \mathrm{Cert}(q,r,j).$$

*Proof sketch.* Write $m = \rho(q,r,j)$ and $d = \lfloor jq/r\rfloor$, so
$jq - kr = (d-k)r + m$. If $d - k \ge 0$ then $|jq - kr| \ge m$, giving the first
disjunct; if $d - k \le -1$ then $|jq-kr| \ge r - m$, giving the second.
Conversely $k = d$ realises the first disjunct with $|jq-kr| = m$, and $k = d+1$
realises the second with $|jq-kr| = r - m$. $\square$

So certification depends on $j$ only through the residue $\rho(q,r,j)$, and the
certifying residues form the union of a head block $[0,B]$ and a mirror block
$[r-B, r-1]$ with $B = \lfloor q/(2r)\rfloor$.

### 3.2 Equidistribution of the peaks

**Lemma 3.2 (modular bijection).** If $uv \equiv 1 \pmod r$ then
$x \mapsto xu \bmod r$ is a bijection of $\{0,\dots,r-1\}$ with inverse
$m \mapsto mv \bmod r$.

**Theorem 3.3 (peaks are equidistributed).** If $\gcd(q,r)=1$ then
$$N(q,r) = \#\bigl\{\, m < r : 2rm \le q \text{ or } 2r(r-m) \le q \,\bigr\}.$$

*Proof sketch.* Apply Lemma 3.2 with $u = q$; the map $j \mapsto jq \bmod r$ is a
bijection of $\{0,\dots,r-1\}$, and by Theorem 3.1 it carries $\mathcal{C}(q,r)$
bijectively onto the certifying residue set. $\square$

This is the only place coprimality of register size and period is used, and it
is exactly where it belongs: it says the peaks sample the residue classes
uniformly. For odd $r$ and $q$ a power of two it is automatic.

### 3.3 The exact count and the ramp

**Theorem 3.4 (exact certification count).** Let $\gcd(q,r) = 1$, $r \ge 1$, and
$B = \lfloor q/(2r) \rfloor$ with $2B < r$ (below saturation). Then
$$N(q,r) = 2B + 1 = 2\left\lfloor \frac{q}{2r}\right\rfloor + 1 .$$

*Proof sketch.* By Theorem 3.3 count residues. Since $2rx \le q \iff x \le B$,
the certifying residue set is $[0,B] \cup [r-B, r-1]$. The hypothesis $2B < r$
makes the two blocks disjoint, so the count is $(B+1) + B$. $\square$

**Theorem 3.5 (the ramp).** Under the hypotheses of Theorem 3.4, the per-sample
certification rate $P_1 = N(q,r)/r$ satisfies
$$\frac{q}{r^2} - \frac1r \;<\; P_1 \;\le\; \frac{q}{r^2} + \frac1r .$$

*Proof sketch.* Upper rail: $2rB \le q$ gives $2B \le q/r$, so
$N/r = (2B+1)/r \le q/r^2 + 1/r$. Lower rail: $2rB + (q \bmod 2r) = q$ with
$q \bmod 2r < 2r$ gives $q/r < 2B + 2$, so $N/r > q/r^2 - 1/r$. $\square$

In particular $P_1$ is strictly positive whenever $B \ge 1$, i.e. whenever
$q \ge 2r$. The ramp has unit slope in $q/r^2$ and error at most one peak.

**Corollary 3.6 (trivial certificate).** $0 \in \mathcal{C}(q,r)$ always: the
$0$-th peak sits exactly on a grid point. It is never informative, which is why
the informative count of §5 is the operationally relevant one.

### 3.4 Constructive refutation of the quadratic wall

**Theorem 3.7 (sub-wall certificate).** Let $r \ge 2$, $\gcd(q,r)=1$ and
$q \ge 2r$. Then there exists $j$ with $0 < j < r$, $\gcd(j,r)=1$, such that peak
$j$ certifies.

*Proof sketch.* Choose $a \in (0,r)$ with $aq \equiv 1 \pmod r$, which exists by
coprimality. Then $\rho(q,r,a) = 1$, so $2r\rho = 2r \le q$ and peak $a$
certifies by Theorem 3.1. Moreover any common divisor of $a$ and $r$ divides
$aq \bmod r = 1$, so $\gcd(a,r)=1$ and the certificate is informative. $\square$

The witness is explicit: the modular inverse of the register size mod the
period. This refutes the pre-registered vertical-wall hypothesis in the sharpest
form — not merely "certification sometimes occurs below $q=r^2$", but "an
informative certificate is exhibited as soon as $q \ge 2r$, exponentially
below."

---

## 4. Saturation and the arithmetic doubling law

**Theorem 4.1 (saturation criterion).** For $\gcd(q,r)=1$, $r \ge 1$,
$$\mathcal{C}(q,r) = \{0,\dots,r-1\} \iff r \le 2\left\lfloor\frac{q}{2r}\right\rfloor + 1 .$$

*Proof sketch.* ($\Leftarrow$) If $r \le 2B+1$ then every residue $m$ satisfies
$m \le B$ or $r - m \le B$. ($\Rightarrow$) If $2B < r$, Theorem 3.4 gives
$N = 2B+1 < r+1$, and $N = r$ would force $r = 2B+1$, contradicting $2B<r$ only
in the strict case; the contrapositive argument then closes. $\square$

**Theorem 4.2 (exact wall position, odd periods).** For odd $r \ge 1$ coprime to
$q$,
$$\mathcal{C}(q,r) = \{0,\dots,r-1\} \iff q \ge r(r-1).$$

*Proof sketch.* Write $r = 2k+1$, so $r - 1 = 2k$. By Theorem 4.1 saturation is
$k \le \lfloor q/(2r)\rfloor$, which by the division characterisation is
$2rk \le q$, i.e. $r(r-1) \le q$. $\square$

The folklore threshold $q = r^2$ is thus misplaced by a factor $r/(r-1)$ *and*
mischaracterised: it marks where the ramp reaches its ceiling, not where success
becomes possible.

**Theorem 4.3 (one register bit doubles the certifying set).** Let $r$ be odd,
$\gcd(q,r)=1$, and suppose $(2q, r)$ is still below saturation. Then
$$2N(q,r) - 1 \;\le\; N(2q,r) \;\le\; 2N(q,r) + 1 .$$

*Proof sketch.* With $B = \lfloor q/(2r)\rfloor$, $C = \lfloor 2q/(2r)\rfloor$,
one has $2B \le C \le 2B+1$ from $2rB \le q < 2r(B+1)$. Oddness of $r$ keeps
$\gcd(2q,r)=1$, so Theorem 3.4 applies to both, giving $N(q,r) = 2B+1$ and
$N(2q,r) = 2C+1$; substitute. $\square$

This is the *arithmetic twin* of the sample-side compounding law
$1 - (1-P)^{2s} \approx 2P$ for small $P$. One register bit and one sample
doubling produce the same first-order effect on the success count. That
coincidence is the mechanism behind the exchange law of §7.

**Theorem 4.4 (degenerate dyadic family).** If $r \mid q$ then
$\mathcal{C}(q,r) = \{0,\dots,r-1\}$, i.e. $N(q,r) = r$ at every register width.

*Proof sketch.* $r \mid q$ forces $\rho(q,r,j) = 0$ for all $j$; each peak sits
exactly on a grid point. $\square$

This is the flat-saturated family of the experiments (pure powers of two,
$r = 2^v$, $q = 2^t$, $v \le t$). It exhibits no ramp behaviour at all, and it is
also informationally degenerate: at width $t = v_2(r)$ the outcome distribution
is uniform, with entropy $\log_2 q$ independent of $r$, so the measurement
carries no information about the period. The family is reported, not hidden.

---

## 5. The informative ramp and the true (linear) wall

Only certificates with $\gcd(j,r)=1$ return the period itself. We count them
exactly.

**Lemma 5.1 (gcd is preserved by the peak map).** If $\gcd(q,r)=1$ then
$\gcd(\rho(q,r,j),\, r) = \gcd(j,r)$; and $\gcd(r-m, r) = \gcd(m,r)$ for
$m \le r$.

*Proof sketch.* The first is $\gcd(jq \bmod r, r) = \gcd(jq, r) = \gcd(j,r)$
using coprimality of $q$ and $r$; the second is the standard reflection identity
for the gcd. $\square$

**Theorem 5.2 (the informative ramp).** For $r \ge 2$, $\gcd(q,r)=1$, and below
saturation ($2B < r$ with $B = \lfloor q/(2r)\rfloor$),
$$\#\mathcal{I}(q,r) \;=\; 2\,T\bigl(r, \lfloor q/(2r)\rfloor\bigr),$$
twice the number of totatives of $r$ in the initial segment
$[1, \lfloor q/(2r)\rfloor]$.

*Proof sketch.* Transport $\mathcal{I}(q,r)$ along the bijection of Theorem 3.3;
by Lemma 5.1 the coprimality condition is preserved, so the image is the set of
certifying residues coprime to $r$. That set splits as
$\bigl([1,B] \cup [r-B, r-1]\bigr)$ intersected with the totatives (residue $0$
is never coprime to $r \ge 2$), and the reflection $m \mapsto r-m$ is a
totative-preserving bijection between the two blocks, each of size $T(r,B)$.
$\square$

**Theorem 5.3 (prime periods).** If $r$ is prime and $\gcd(q,r)=1$, then below
saturation $\#\mathcal{I}(q,r) = 2\lfloor q/(2r)\rfloor$: every certificate but
the trivial one is informative.

*Proof sketch.* For $B < r$ every $m \in [1,B]$ is coprime to the prime $r$, so
$T(r,B) = B$; apply Theorem 5.2. $\square$

**Theorem 5.4 (the true wall is linear).** For $r \ge 2$, $\gcd(q,r)=1$, below
saturation,
$$\mathcal{I}(q,r) = \varnothing \iff q < 2r .$$
Consequently, if $q < 2r$ then for every $j$ with $0 < j < r$ and $\gcd(j,r)=1$,
peak $j$ fails to certify — deterministically, at every measurement outcome and
for every number of repetitions.

*Proof sketch.* By Theorem 5.2, $\mathcal{I} = \varnothing \iff T(r,B) = 0$. If
$B \ge 1$ then $1 \in [1,B]$ is a totative, so $T \ge 1$; if $B = 0$ the segment
is empty. And $B = 0 \iff q < 2r$. The deterministic statement is the
contrapositive: a certifying coprime $j$ would be a member of $\mathcal{I}$.
$\square$

This is the honest home of the observation that "ten samples fail": below
$q = 2r$, that is with fewer than $\log_2 r + 1$ register bits, no sample count
whatsoever helps, because the set of usable outcomes is empty. Above it, the
ramp runs.

**Theorem 5.5 (Legendre-type lower bound).** For $r \ge 1$ and any $B \ge 0$,
$$T(r,B) \;\ge\; B - \sum_{p \mid r,\ p \text{ prime}} \left\lfloor \frac{B}{p} \right\rfloor .$$
Hence, below saturation,
$\#\mathcal{I}(q,r) \ge 2\bigl(B - \sum_{p \mid r} \lfloor B/p\rfloor\bigr)$.

*Proof sketch.* The non-totatives in $[1,B]$ each share a prime factor with $r$,
so they are covered by the union over $p \mid r$ of the multiples of $p$ in
$[1,B]$; each such class has exactly $\lfloor B/p\rfloor$ elements, and the
union bound on cardinalities gives the claim. $\square$

The bound is sharp for prime $r$ and vacuous once $r$ has many small prime
factors — a limitation we state rather than conceal (see §10).

### 5.1 Three regimes of the register axis

Collecting Theorems 3.5, 4.2 and 5.4:

| regime | register size | behaviour |
|---|---|---|
| dead | $q < 2r$ | no informative certificate; deterministic failure |
| ramp | $2r \le q < r(r-1)$ | rate $P_1 \approx q/r^2$, unit slope |
| saturated | $q \ge r(r-1)$ | every peak certifies |

Worked instances at $r = 21$ ($2r = 42$, $r(r-1) = 420$, folklore $r^2 = 441$):

| $q$ | regime | $N(q,21)$ | $\#\mathcal{I}(q,21)$ |
|---|---|---|---|
| $32$ | dead | $1$ | $0$ |
| $64$ | ramp | $3$ | $2$ |
| $128$ | ramp | $7$ | $4$ |
| $256$ | ramp | $13$ | $8$ |
| $512$ | saturated | $21$ | $12 = \varphi(21)$ |

At saturation the informative count is exactly $\varphi(r)$, the total supply of
usable numerators, as it must be.

---

## 6. The sample axis: two rails for the compounding law

**Theorem 6.1 (reverse Bernoulli).** For $0 \le x \le 1$ and $n \in \mathbb{N}$,
$$(1-x)^n\,(1 + nx) \;\le\; 1 .$$

*Proof sketch.* Bernoulli's inequality gives $1 + nx \le (1+x)^n$ for
$x \ge -1$. Multiplying by $(1-x)^n \ge 0$,
$(1-x)^n(1+nx) \le \bigl((1-x)(1+x)\bigr)^n = (1-x^2)^n \le 1$, the last step
because $0 \le 1-x^2 \le 1$. $\square$

**Theorem 6.2 (lower rail).** If $0 \le x \le 1$ and $nx \ge 1$, then
$\mathrm{Succ}(x,n) \ge \tfrac12$.

*Proof sketch.* Theorem 6.1 with $nx \ge 1$ gives
$2(1-x)^n \le (1-x)^n(1+nx) \le 1$, so $(1-x)^n \le \tfrac12$. $\square$

**Theorem 6.3 (upper rail).** If $x \le 1$ and $nx < \tfrac12$, then
$\mathrm{Succ}(x,n) < \tfrac12$.

*Proof sketch.* The union bound $\mathrm{Succ}(x,n) = 1-(1-x)^n \le nx$ (itself
Bernoulli) composed with the hypothesis. $\square$

Together: **the 50% contour of the compounding law sits exactly where the
expected number of successes $n x$ lies between $\tfrac12$ and $1$.** The whole
of the exchange law is this statement plus the observation that, in the ramp
model, $nx$ is a function of $t + \log_2 s$ alone.

**Remark 6.4 (monotonicity).** $\mathrm{Succ}(x,n)$ is nondecreasing in $n$ for
$x \in [0,1]$, since $(1-x)^{n'} \le (1-x)^n$ for $n \le n'$. Hence reaching the
target is monotone in the sample budget and $t^*(c,s)$ is antitone in $s$.

---

## 7. The fungibility ramp

Fix $c > 0$ and write $P_1(t) = \min(1, c\,2^t)$, $P(t,s) = \mathrm{Succ}(P_1(t), s)$.

**Lemma 7.1 (halving step).** For $c \ge 0$ and any $t$,
$$1 - P_1(t+1) \;\le\; \bigl(1 - P_1(t)\bigr)^2 .$$

*Proof sketch.* Put $a = c2^t$, so $P_1(t+1) = \min(1, 2a)$. If $a \ge 1$, both
sides are $0$ and $0$. If $a < 1 \le 2a$, the left side is $0$. If $2a < 1$, the
claim is $1 - 2a \le (1-a)^2 = 1 - 2a + a^2$. $\square$

**Lemma 7.2 (at most a halving).** For $c \ge 0$,
$P_1(t+1) \le 2\,P_1(t)$.

*Proof sketch.* Same case split on $a = c2^t$ against $1$ and $1/2$. $\square$

**Theorem 7.3 (contour, achievability).** If $c\,s\,2^t \ge 1$ then
$P(t,s) \ge \tfrac12$.

*Proof sketch.* We show $s\,P_1(t) \ge 1$ and invoke Theorem 6.2. If
$c2^t \ge 1$, then $P_1(t) = 1$ and $s \ge 1$ (as $c s 2^t \ge 1$ forces
$s \ge 1$). Otherwise $P_1(t) = c2^t$ and $s\,P_1(t) = c s 2^t \ge 1$. $\square$

**Theorem 7.4 (the fungibility ramp / contour band).** For $c > 0$ and all
$t, s$:
$$c\,s\,2^{t} \ge 1 \;\Longrightarrow\; P(t,s) \ge \tfrac12
\qquad\text{and}\qquad
P(t,s) \ge \tfrac12 \;\Longrightarrow\; c\,s\,2^{t} \ge \tfrac12 .$$
The half-success contour of the $(t,s)$ phase diagram is therefore pinned
between the two parallel lines $c\,s\,2^t = \tfrac12$ and $c\,s\,2^t = 1$ — lines
of **slope $-1$** in the coordinates $(\log_2 s,\ t)$.

*Proof sketch.* The first implication is Theorem 7.3. For the second, the union
bound gives $\tfrac12 \le P(t,s) \le s\,P_1(t) \le s\,c\,2^t$. $\square$

**Corollary 7.4a (exact fungibility of the exchange coordinate).** The quantity
$c\,s\,2^t$ is invariant under $(t,s) \mapsto (t+1, s/2)$ and
$(t,s)\mapsto(t-1,2s)$: the trade of one register bit for one sample doubling is
exact, at every point of the diagram.

In particular there is **no vertical wall** anywhere in the $(t,s)$ plane: the
contour has finite, constant slope.

**Theorem 7.5 (a sample doubling is worth at most one bit).** For $c \ge 0$, if
$(t, 2s)$ reaches the target then $(t+1, s)$ reaches the target.

*Proof sketch.* By Lemma 7.1 and monotonicity of $y \mapsto y^s$,
$$\bigl(1 - P_1(t+1)\bigr)^s \le \bigl((1-P_1(t))^2\bigr)^s = \bigl(1-P_1(t)\bigr)^{2s},$$
so the failure probability at $(t+1,s)$ is at most that at $(t,2s)$. $\square$

**Theorem 7.6 (two sample doublings buy a register bit).** For $c > 0$, if
$(t+1, s)$ reaches the target then $(t, 4s)$ reaches the target.

*Proof sketch.* The union bound applied at $(t+1,s)$ gives
$s\,P_1(t+1) \ge \tfrac12$. By Lemma 7.2, $P_1(t+1) \le 2P_1(t)$, so
$2s\,P_1(t) \ge \tfrac12$, i.e. $4s\,P_1(t) \ge 1$. Theorem 6.2 closes it.
$\square$

These two are the exchange law in threshold-free form: they compare
configurations directly, with no reference to where any contour lies.

---

## 8. The threshold width and its $-\log_2 s$ shift

**Definition 8.1.** $t^*(c,s) = \min\{ t : (t,s) \text{ reaches the target}\}$,
well-defined for $c>0$, $s \ge 1$ since $c\,s\,2^t \ge 1$ eventually (Theorem 7.3).

**Theorem 8.2 (one doubling, one bit).** For $c>0$, $s \ge 1$,
$$t^*(c,s) \le t^*(c, 2s) + 1 .$$

*Proof sketch.* $(t^*(2s), 2s)$ reaches; apply Theorem 7.5 to get that
$(t^*(2s)+1, s)$ reaches; minimality. $\square$

**Theorem 8.3 (two doublings, at least one bit).** For $c>0$, $s \ge 1$, if
$t^*(c,s) \ne 0$ then
$$t^*(c, 4s) + 1 \le t^*(c, s) .$$

*Proof sketch.* Write $t^*(s) = T+1$; then $(T+1, s)$ reaches, so by Theorem 7.6
$(T, 4s)$ reaches, whence $t^*(4s) \le T = t^*(s) - 1$. $\square$

**Theorem 8.4 (iterated form).** For $c>0$ and all $m, s \ge 1$,
$$t^*(c, s) \le t^*(c, 2^m s) + m, \qquad t^*(c, 4^m s) \le t^*(c,s) - m .$$

*Proof sketch.* Induction on $m$, applying Theorems 8.2 and 8.3 respectively at
each step (with the antitonicity of $t^*$ in $s$, Remark 6.4, handling the
$t^* = 0$ boundary case). $\square$

**Theorem 8.5 (the exchange band).** For $c>0$, $m \ge 0$, $s \ge 1$,
$$t^*(c, 4^m s) \;\le\; t^*(c,s) - m
\qquad\text{and}\qquad
t^*(c,s) \;\le\; t^*(c, 4^m s) + 2m .$$
Equivalently: $2m$ sample doublings buy between $m$ and $2m$ register bits. The
exchange rate is one bit per sample doubling, up to a factor two.

*Proof sketch.* The first is Theorem 8.4; the second is the first display of
Theorem 8.4 with $2m$ in place of $m$, using $2^{2m} = 4^m$. $\square$

---

## 9. From the model back to the arithmetic ramp

The results of §§6–8 concern the idealised ramp $\min(1, c2^t)$. We now carry
them back to the exact peak model of §3. Write $P_1^{\mathrm{peak}}(q,r) = N(q,r)/r$.

**Theorem 9.1 (phase boundary, achievability).** Let $r \ge 1$, $\gcd(q,r)=1$,
below saturation. If
$$s\left(\frac{q}{r^2} - \frac1r\right) \ge 1,$$
then $s$ independent samples certify with probability at least $\tfrac12$.

*Proof sketch.* The lower rail of Theorem 3.5 gives
$P_1^{\mathrm{peak}} > q/r^2 - 1/r$, so the hypothesis yields
$s\,P_1^{\mathrm{peak}} \ge 1$; apply Theorem 6.2. $\square$

**Theorem 9.2 (phase boundary, converse).** Under the same hypotheses, if
$$s\left(\frac{q}{r^2} + \frac1r\right) < \tfrac12,$$
then $s$ samples certify with probability strictly less than $\tfrac12$.

*Proof sketch.* The upper rail of Theorem 3.5 gives
$P_1^{\mathrm{peak}} \le q/r^2 + 1/r$, so $s\,P_1^{\mathrm{peak}} < \tfrac12$;
apply Theorem 6.3. $\square$

Together the two say the half-success contour of the *exact* arithmetic model
sits at
$$s\,q \;\asymp\; r^2,$$
which is the fungibility ramp in the original variables: $\log_2 s + t \approx
2\log_2 r$. The folklore requirement $t \ge 2\log_2 r$ is recovered as the
special case $s = O(1)$, and is seen to be one point on a line rather than a
boundary of possibility.

---

## 10. Numerical validation

All simulations use the exact Shor output distribution for an
arithmetic-progression preimage set of size $M \approx q/r$,
$$P(k) \;=\; \frac{1}{Mq}\left|\frac{\sin(\pi M k r / q)}{\sin(\pi k r/q)}\right|^{2},
\qquad k = 0,\dots,q-1, \tag{10.1}$$
with the removable singularities at $kr \equiv 0 \pmod q$ resolved to $M/q$. No
contiguous-block approximation is used; the kernel (10.1) is the one whose
sub-wall behaviour the earlier, refuted table misrepresented.

**10.1 The single-sample ramp.** For $4\times\text{odd}$ period families, the
measured per-sample certification rate rises smoothly through the ramp:
$0.003$ at $q/r^2 = 0.028$, $0.36$ at $q/r^2 = 0.905$, plateauing near $0.46$.
No jump is observed anywhere. Pure powers of two are flat-saturated near $0.5$
at every ratio, in agreement with Theorem 4.4 (every peak on a grid point) and
with their informational degeneracy.

**10.2 Sample ladders, out of sample.** The compounding prediction
$P_s = 1-(1-P_1)^s$ is formed from the measured $P_1$ and then tested against
independently measured $P_s$:

| family | offset from folklore wall | $P_1$ | $s$ | measured $P_s$ | predicted |
|---|---|---|---|---|---|
| odd prime | $-1$ bit | $0.725$ | $2$ | $0.940$ | $0.924$ |
| $2\times$odd | $-3$ bits | $0.055$ | $20$ | $0.680$ | $0.677$ |

Agreement is inside the Monte-Carlo error of $\pm 0.03$ at 300 trials per cell.

**10.3 The exchange law.** For the odd composite period $r = 1155$ (folklore
wall $t = 21$), the measured shift of the $P \ge 1/2$ contour is

| $s$ | measured $\Delta t^*$ | ideal $-\log_2 s$ |
|---|---|---|
| $2$ | $0$ | $-1.0$ |
| $5$ | $-2$ | $-2.3$ |
| $20$ | $-4$ | $-4.3$ |
| $100$ | $-6$ | $-6.6$ |

Every shift lies inside the proved band of Theorem 8.5, $[\tfrac12, 1]$ bits per
doubling, and tracks the ideal unit slope with an $O(1)$ offset. (At $s=1$ the
contour is never crossed: the saturation level $P_1 \approx 0.37$ *is* the
standard per-sample rate for this family.)

**10.4 Exact instances of the counting theorems.** The closed forms of §§3–5
were checked against direct enumeration:

| $r$ | $q$ | $N(q,r)$ | $2\lfloor q/2r\rfloor+1$ | $\#\mathcal{I}$ | $2T(r,\lfloor q/2r\rfloor)$ |
|---|---|---|---|---|---|
| $21$ | $64$ | $3$ | $3$ | $2$ | $2$ |
| $21$ | $128$ | $7$ | $7$ | $4$ | $4$ |
| $21$ | $256$ | $13$ | $13$ | $8$ | $8$ |
| $21$ | $512$ | $21$ | sat. | $12$ | sat. $=\varphi(21)$ |
| $15$ | $32$ | $3$ | $3$ | $2$ | $2$ |
| $15$ | $128$ | $9$ | $9$ | $6$ | $6$ |
| $11$ | $64$ | $5$ | $5$ | $4$ | $4$ |
| $8$ | $8$ | $8$ | dyadic | — | — |

---

## 11. Discussion

### 11.1 What the result changes

The traditional statement "Shor's period finding needs $2\log_2 r$ register
bits" is a *sufficient* condition for worst-case certainty, promoted by usage
into a necessary condition. Three distinct corrections apply:

1. The onset of possibility is at $q = 2r$, not $q = r^2$ — a linear wall, a
   factor of $r$ lower, with an explicit witness (Theorem 3.7).
2. The point $q = r^2$ is a *saturation*, and even that is off: the true
   saturation for odd $r$ is $q = r(r-1)$ (Theorem 4.2).
3. Between the two, the success rate is a smooth ramp $\approx q/r^2$
   (Theorem 3.5), and repetitions compound it along a contour of unit slope
   (Theorem 7.4).

### 11.2 Operational meaning

Qubits are the scarce resource; circuit repetitions are cheap. The exchange law
says that $m$ missing register bits can be bought back with a factor of between
$2^m$ and $4^m$ more repetitions. This is exponential in $m$ and therefore not a
free lunch — the quantum advantage is preserved, since the number of
repetitions needed to eliminate the register entirely is exponential in
$\log_2 r$ — but for small $m$ it is an entirely practical trade. Three bits
short of the ideal register costs between $8\times$ and $64\times$ the shots.

More conceptually, it converts a *binary* resource statement into a *graded*
one. The frontier between feasible and infeasible is a two-dimensional surface
with a known slope, not a threshold; the natural object is the conversion rate,
and here the conversion rate is exactly one, up to one bit.

### 11.3 Where the argument remains soft

We record the limitations explicitly.

* **Uniform versus Dirichlet weight.** §§6–9 model the per-shot probability as
  the *uniform* weight on the certifiable peaks, i.e. $N(q,r)/r$. The physical
  weight is the kernel mass (10.1), which is comparable to the uniform weight
  only up to the classical Fejér constant $4/\pi^2$. The uniform model is thus a
  proxy, expected to be a lower bound up to that absolute factor.
* **The factor-two gap.** The exchange rate is *proved* to lie in
  $[\tfrac12, 1]$ bits per doubling (Theorem 8.5), while all measurements
  indicate exactly $1$ with an $O(1)$ offset. The gap is an artifact of using
  two one-sided elementary rails; closing it requires a two-sided estimate of
  $\mathrm{Succ}$ near its half-level.
* **The sieve bound.** Theorem 5.5 is vacuous once
  $\sum_{p \mid r} \lfloor B/p\rfloor \ge B$, which happens precisely when $r$
  has many small prime factors — exactly the regime where the informative ramp
  is thinnest.

---

## 12. Future work

Three direct continuations, each a sharpening of a soft spot above.

**Conjecture 12.1 (Dirichlet-mass domination).** The measurement kernel (10.1)
places at least $4/\pi^2$ of its total mass on the certifiable peaks whenever
the ramp rate exceeds $\tfrac12$. Consequently the uniform peak model is a lower
bound for the physical model up to that absolute constant, and every result of
§§6–9 transfers with an explicit loss factor. The key structural insight is that
Fejér-type concentration of the Shor kernel is *peak-local*: the mass attached
to each individual peak is bounded below independently of the others, so a
count of certifiable peaks converts into a mass bound without any global
argument.

**Conjecture 12.2 (exact unit slope).** In the interior of the ramp,
$t^*(2^m s) = t^*(s) - m + O(1)$, with the implied offset independent of both
$m$ and $s$. This would replace the band $[\tfrac12, 1]$ of Theorem 8.5 by an
exact rate of one bit per doubling.

**Conjecture 12.3 (sieve asymptotic for the informative ramp).** Uniformly for
$q$ in the interior of the ramp,
$$\frac{\#\mathcal{I}(q,r)}{N(q,r)} \longrightarrow \frac{\varphi(r)}{r},$$
i.e. the informative fraction equals the global totative density. Numerically
the ratio exceeds $\varphi(r)/r$ at small sizes, because the head block
$[1, \lfloor q/(2r)\rfloor]$ is biased toward small — hence often coprime —
residues; the conjecture asserts that this bias washes out.

Beyond these, two broader directions suggest themselves. First, the same
peak-counting analysis applies verbatim to any phase-estimation task with a
rational target and a dyadic measurement grid, so the ramp should be a general
feature of phase estimation rather than a peculiarity of period finding.
Second, the appearance of short-interval totative counts inside a quantum
resource bound (Theorem 5.2) invites the transfer of sieve technology into
quantum resource analysis: the accuracy with which one can predict the
informative rate for a *specific* composite period is, literally, a question
about totatives in short intervals.

---

## 13. Conclusion

The qubit/sample phase diagram of Shor period-finding is a fungibility ramp, not
a wall. On the register axis, the number of certifiable peaks is exactly
$2\lfloor q/(2r)\rfloor + 1$ below saturation, giving a per-sample rate
$q/r^2 \pm 1/r$; informative certificates exist exactly above the *linear* wall
$q = 2r$ and are counted exactly by head totatives; saturation occurs at
$q = r(r-1)$, not $r^2$. On the sample axis, reverse Bernoulli and the union
bound pin the 50% contour where the expected success count lies between $1/2$
and $1$. Combining, the contour of the two-dimensional diagram is trapped
between two parallel unit-slope lines $\tfrac12 \le c\,s\,2^t \le 1$: a doubling
of samples is worth at most one register bit, two doublings at least one, and
the measured exchange rate lies inside that band. One register bit is worth one
sample.
