# The Detection Window of Sequential-Multiple Curve Factoring, and the Addition-Chain Barrier

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We give a complete group-theoretic analysis of the "lite" variant of the
elliptic curve factoring method, in which one walks the *sequential* multiples
$P, 2P, \dots, B\!\cdot\!P$ of a random base point rather than the
least-common-multiple ladder $\operatorname{lcm}(1,\dots,B)\cdot P$ of true ECM.
Our results are sharp and unconditional.

We prove that the sequential arm annihilates a base point exactly when its order
is at most $B$, whereas true ECM succeeds exactly when the order is $B$-smooth;
the separation is strict and large. Taking into account the elliptic involution
$Q \mapsto -Q$, which is what a real implementation actually detects through a
failed modular inversion, we determine the exact detection window: for $B \ge 3$
the run $P, 2P, \dots, BP$ exhibits a repeated $x$-coordinate **if and only if**
$\operatorname{ord}(P) \le 2B - 1$, and a point of order exactly $2B$ is
invisible, so both endpoints are sharp. We count the visible set: in any finite
abelian group in which $d \cdot a = 0$ has at most $d^k$ solutions, at most
$B^{k+1}$ points have order $\le B$; in the cyclic case the count is exactly
$\sum_{d \mid |G|,\, d \le B} \varphi(d) \le B^2$.

These counts force the scaling law. With $B$ fixed, any campaign reaching
success probability $1/2$ needs at least $p/(2B^2)$ curves, a budget of exponent
$1$; and for every fixed $B$ and every constant $c$ there is a $p$ with
$c\sqrt p < p/(2B^2)$. Consequently a *fixed* stage-one bound cannot exhibit
square-root ("birthday") scaling, and a reported slope of $0.48$ per $\log_2 p$
over a four-bit range must be attributed either to the narrowness of that range,
to censoring, or to an *effective* bound that grows with $p$. We make the last
option quantitative: a measured budget exponent $1-\alpha$ corresponds to
$B_{\mathrm{eff}} = p^{\alpha/2}$, so $0.48$ predicts $B_{\mathrm{eff}} \approx
p^{0.26}$, numerically indistinguishable from the fixed $B_1 = 50$ over
$k = 16 \dots 20$. The exact crossover is $B \asymp p^{1/4}$, which yields
precisely a $\sqrt p$ budget.

Finally we establish a universal per-operation barrier. Modelling a stage-one
computation as an addition chain — each new multiple a sum of two already
computed ones — we prove $m_t \le 2^t$, attained by the doubling ladder and
missed exponentially by the sequential run, whose $t$-th entry is $t+1$. A run
whose multiples are bounded by $M$ detects only orders $\le 2M$, whatever the
multiples are; hence for $t \ge 3$ the doubling ladder annihilates a point of
order $2^t$ that the sequential run of equal length cannot see. We also show
that the sequential *shape* is itself suboptimal: at three additions the
geometric visiting set $\{1,2,4,8\}$ detects the orders $9, 10, 12$ that the
sequential set $\{1,2,3,4\}$ misses.

---

## 1. Introduction

### 1.1 The mechanism

Let $N = pq$ be a semiprime with $p$ the smaller unknown prime. Lenstra's
elliptic curve method (ECM) factors $N$ by performing elliptic curve arithmetic
over the ring $\mathbb{Z}/N$. The group law on a Weierstrass curve

$$E : y^2 = x^3 + ax + b$$

requires, at each addition, the inversion of a difference of coordinates. Over
$\mathbb{Z}/N$ such an inversion is computed by the extended Euclidean
algorithm, which succeeds when the denominator is coprime to $N$ and otherwise
returns $\gcd(\text{denominator}, N)$ — a nontrivial factor.

The relevant reduction is modulo the hidden prime $p$. The curve reduces to a
genuine elliptic curve over $\mathbb{F}_p$ whose group $E(\mathbb{F}_p)$ is
abelian of order in the Hasse interval $[p+1-2\sqrt p,\ p+1+2\sqrt p]$, and is
of the form $\mathbb{Z}/m \oplus \mathbb{Z}/n$ with $n \mid m$. A denominator
vanishes modulo $p$ exactly when the two points being combined share an
$x$-coordinate modulo $p$; since a Weierstrass curve is stable under the
*elliptic involution* $Q \mapsto -Q$ and this is the only source of coincident
abscissae, two affine points share an $x$-coordinate exactly when they are equal
or opposite.

We therefore work entirely inside a finite abelian group $G$ (written
additively), with a base point $P \in G$, and we encode the geometry by the
relation

$$\mathrm{XEq}(a,b) \quad :\Longleftrightarrow \quad a = b \ \text{ or } \ a = -b.$$

### 1.2 The two arms

**True ECM (stage one).** Fix a bound $B$ and set
$k = \operatorname{lcm}(1, 2, \dots, B)$. Compute $k \cdot P$. Success — meaning
$k\cdot P = 0$ in $E(\mathbb{F}_p)$ — occurs exactly when
$\operatorname{ord}(P) \mid k$, i.e. when the order is **$B$-smooth**. The
exponent $k$ is enormous ($\operatorname{lcm}(1,\dots,50) > 3 \cdot 10^{21}$)
but is reached in $O(B)$ point operations via a binary ladder.

**The lite arm.** Fix $B$ and walk

$$P,\ 2P,\ 3P,\ \dots,\ B\cdot P,$$

one addition per step, watching for a failed inversion. This is *explicitly not*
true ECM: no lcm is formed and no smoothness is exploited.

### 1.3 Experimental context and the question

A campaign over random curves with $B_1 = 50$, running $j = 3, \dots, 50$,
reported $1200/1200$ successes at $k = 16$ bits and $1163/1200$ at $k = 20$
bits ($3.1\%$ censoring), with an across-$k$ curve-budget slope of $0.48$ per
$\log_2 p$. On the same target population, trial division measured $0.84$,
Pollard's rho $0.52$, and Fermat's method $0.50$ — placing the lite arm
apparently on the birthday line beside rho and Fermat.

Two questions follow. *Is a birthday exponent compatible with the structure of
the lite arm?* And *what is the true exponent?* We answer both: no, and $1$.

A ledger note: the first implementation was instantly degenerate, because the
running point at $j = 2$ still equalled the base point, so every denominator
vanished on every curve; the fix was an explicit doubling. Theorem 3.4 below
shows this failure mode is precisely the bottom end of the detection window.

---

## 2. The lite window is the order window

Throughout, $G$ is an additive group and $P \in G$ has finite order
$\operatorname{ord}(P) > 0$. We write $\operatorname{lcm}(1,\dots,B)$ as
$\lambda(B)$; note $\lambda(B) > 0$ and $n \mid \lambda(B)$ for every
$1 \le n \le B$.

**Definition 2.1 (Lite hit).** The lite arm *hits* if $j \cdot P = 0$ for some
$j$ with $2 \le j \le B$.

**Definition 2.2 (ECM hit).** True ECM *hits* if $\lambda(B) \cdot P = 0$.

**Theorem 2.3 (The lite arm sees exactly the small orders).** *For $B \ge 2$ and
$P$ of finite positive order, the lite arm hits if and only if
$\operatorname{ord}(P) \le B$.*

*Proof.* ($\Rightarrow$) If $jP = 0$ with $2 \le j \le B$, then
$\operatorname{ord}(P) \mid j$; a positive divisor of a positive integer is at
most that integer, so $\operatorname{ord}(P) \le j \le B$.
($\Leftarrow$) Write $d = \operatorname{ord}(P) \le B$. If $d = 1$ then $P = 0$
and $j = 2$ works (legal since $B \ge 2$). If $d \ge 2$, take $j = d$: it lies
in $[2, B]$ and $dP = 0$. $\square$

**Theorem 2.4 (True ECM sees exactly the smooth orders).** *True ECM hits if and
only if $\operatorname{ord}(P) \mid \lambda(B)$.*

*Proof.* Immediate from the characterisation $n \cdot P = 0 \iff
\operatorname{ord}(P) \mid n$. $\square$

**Corollary 2.5 (Lite implies ECM).** *For $B \ge 2$, a lite hit is an ECM hit.*

*Proof.* By Theorem 2.3 the order $d$ satisfies $1 \le d \le B$, hence
$d \mid \lambda(B)$, hence Theorem 2.4 applies. $\square$

**Theorem 2.6 (The separation is strict).** *In $\mathbb{Z}/96$ with $B = 50$,
true ECM annihilates the generator while the lite arm does not.*

*Proof.* The generator has order $96 = 2^5 \cdot 3$. Both $32 \le 50$ and
$3 \le 50$, and $\gcd(32,3) = 1$, so $96 = 32 \cdot 3$ divides $\lambda(50)$;
Theorem 2.4 gives the ECM hit. Since $96 > 50$, Theorem 2.3 denies the lite hit.
$\square$

The moral: the lite arm has replaced a *divisibility* condition — satisfied by
the abundant smooth numbers — with an *inequality*, satisfied only by a
vanishing fraction of orders.

---

## 3. The sharp $x$-coordinate detection window

A real implementation detects not only $jP = 0$ but any repeated
$x$-coordinate in the run.

**Definition 3.1 ($x$-collision).** The run of length $B$ has an *$x$-collision*
if there exist $1 \le i < j \le B$ with $\mathrm{XEq}(iP, jP)$.

**Lemma 3.2 (Collisions are divisibilities).** *For $i \le j$,*
$$\mathrm{XEq}(iP, jP) \iff \operatorname{ord}(P) \mid (j - i) \ \text{ or }\ \operatorname{ord}(P) \mid (i + j).$$

*Proof.* $iP = jP$ iff $i \equiv j \pmod{\operatorname{ord}(P)}$ iff
$\operatorname{ord}(P) \mid j - i$ (using $i \le j$). And
$iP = -(jP)$ iff $(i+j)P = 0$ iff $\operatorname{ord}(P) \mid i + j$. $\square$

The two clauses have very different reach. Differences within $[1,B]$ span
$[1, B-1]$; sums span $[3, 2B-1]$. The involution therefore roughly doubles the
window, and the union is exactly an interval.

**Theorem 3.3 (Sharp detection window).** *Let $B \ge 3$ and let $P$ have finite
positive order $d$. Then the run $P, 2P, \dots, BP$ has an $x$-collision if and
only if $d \le 2B - 1$.*

*Proof.* ($\Rightarrow$) By Lemma 3.2 either $d \mid j - i$ with
$0 < j - i \le B - 1$, giving $d \le B - 1$; or $d \mid i + j$ with
$0 < i + j \le 2B - 1$, giving $d \le 2B-1$.

($\Leftarrow$) Three cases.

- $d \le B - 1$: take $(i, j) = (1, 1 + d)$. Both indices lie in $[1, B]$, and
  $d \mid j - i = d$.
- $d = B$: take $(i, j) = (1, B-1)$; since $B \ge 3$ these are legal and
  distinct, and $i + j = B = d$.
- $B < d \le 2B - 1$: take $(i,j) = (d - B,\ B)$. Then $1 \le d - B \le B - 1 <
  B$, so both indices are legal and $i < j$, and $i + j = d$. $\square$

**Theorem 3.4 (Sharpness at the top).** *For $B \ge 3$, a base point of order
exactly $2B$ produces no $x$-collision in a run of length $B$.*

*Proof.* Immediate from Theorem 3.3, since $2B > 2B - 1$. $\square$

Thus the detection window is exactly the interval $[1, 2B-1]$ of orders, and it
cannot be widened by any analysis of the same run.

**Theorem 3.5 (The two-torsion degeneracy).** *For $P$ of finite positive order,
$2P = 0$ if and only if $\operatorname{ord}(P) \le 2$.*

*Proof.* $2P = 0$ iff $\operatorname{ord}(P) \mid 2$ iff
$\operatorname{ord}(P) \in \{1,2\}$. $\square$

This is the formal shape of the implementation ledger's v1 bug. An
implementation whose running point at $j=2$ has not been advanced past $P$
effectively asserts $\mathrm{XEq}(P,P)$, manufacturing the
"$\operatorname{ord} \le 2$" event on *every* curve, and reporting an immediate
zero denominator universally. The observed instant degeneracy was the algorithm
correctly reporting the only order it had been misled into seeing.

---

## 4. Counting the visible set

The per-curve success probability is the density of the visible set.

**Theorem 4.1 (General visible-set bound).** *Let $G$ be a finite abelian group
in which, for every $d \ge 1$, the equation $d \cdot a = 0$ has at most $d^k$
solutions. Then*
$$\#\{\, a \in G : \operatorname{ord}(a) \le B \,\} \le B^{k+1}.$$

*Proof.* Fibre the set $\{\operatorname{ord}(a) \le B\}$ over the exact order
$d$, which lies in $\{1, \dots, B\}$ since orders are positive. The fibre at $d$
is contained in $\{a : d \cdot a = 0\}$, of cardinality at most
$d^k \le B^k$. Summing $B$ fibres gives $B \cdot B^k = B^{k+1}$. $\square$

**Corollary 4.2 (Cyclic case).** *In a finite cyclic group,
$\#\{\operatorname{ord}(a) \le B\} \le B^2$.*

*Proof.* In a cyclic group $d\cdot a = 0$ has at most $d$ solutions, i.e.
$k = 1$. $\square$

Since $E(\mathbb{F}_p) \cong \mathbb{Z}/m \oplus \mathbb{Z}/n$, the general
elliptic case satisfies the hypothesis with $k = 2$, giving the bound $B^3$.
Either way the visible mass is **polynomial in $B$ and independent of $p$** —
the decisive structural fact.

**Theorem 4.3 (Exact cyclic count).** *In a finite cyclic group $G$,*
$$\#\{\, a \in G : \operatorname{ord}(a) \le B \,\} \;=\; \sum_{\substack{d \mid |G| \\ 1 \le d \le B}} \varphi(d).$$

*Proof.* Fibre over the exact order as above. In a cyclic group of order $n$
there are exactly $\varphi(d)$ elements of order $d$ when $d \mid n$, and none
otherwise; the fibres at non-divisors are empty. $\square$

No lcm appears in this formula, and no notion of smoothness: the lite arm's
reach is a *truncated divisor sum*, nothing more.

**Theorem 4.4 (The detection gap, concretely).** *Let $G$ be cyclic of order
$1058400 = 2^5 \cdot 3^3 \cdot 5^2 \cdot 7^2$ and let $B = 50$. Then true ECM
annihilates every point of $G$, while the lite arm's visible set has at most
$2500$ elements — a factor of more than $400$ smaller than $|G|$.*

*Proof.* Each of $32, 27, 25, 49$ is at most $50$ and they are pairwise coprime,
so their product $1058400$ divides $\lambda(50)$. Every $a \in G$ has order
dividing $|G| = 1058400 \mid \lambda(50)$, so $\lambda(50)\cdot a = 0$ by
Theorem 2.4. The lite bound is Corollary 4.2 with $B = 50$, giving $2500$; and
$2500 \cdot 400 = 10^6 < 1058400$. $\square$

For calibration: $\lambda(50) > 50^2$ by a wide margin (indeed
$1058400 \mid \lambda(50)$ already forces $\lambda(50) > 10^6$), so the reach of
the lcm ladder exceeds the entire lite window by orders of magnitude at the same
nominal bound.

---

## 5. Scaling: a fixed bound forces a linear budget

**Lemma 5.1 (Union bound).** *For $q \le 1$ and $C \in \mathbb{N}$,*
$$1 - (1-q)^C \le Cq.$$

*Proof.* Bernoulli's inequality $1 + Ca \le (1+a)^C$ with $a = -q \ge -1$ gives
$1 - Cq \le (1-q)^C$; rearrange. $\square$

**Theorem 5.2 (Curve-budget lower bound).** *Let each of $C$ independent curves
succeed with probability $q \le \min(1, B^2/p)$. If*
$$C < \frac{p}{2B^2},$$
*then the overall success probability $1 - (1-q)^C$ is strictly less than
$1/2$.*

*Proof.* By Lemma 5.1, $1 - (1-q)^C \le Cq \le C\cdot B^2/p <
\frac{p}{2B^2}\cdot\frac{B^2}{p} = \frac12$. $\square$

The hypothesis $q \le B^2/p$ is exactly Corollary 4.2 combined with
$|E(\mathbb{F}_p)| \approx p$: a uniformly random base point lands in a visible
set of size $\le B^2$ inside a group of size $\approx p$.

**Theorem 5.3 (A fixed window refutes square-root scaling).** *For every fixed
$B \ge 1$ and every constant $c \in \mathbb{R}$ there exists $p \ge 1$ with*
$$c\sqrt p \;<\; \frac{p}{2B^2}.$$

*Proof.* Choose an integer $m > \max(1,\ 2cB^2)$ and set $p = m^2$. Then
$\sqrt p = m$, and $\frac{p}{2B^2} = \frac{m^2}{2B^2} > \frac{m \cdot
2cB^2}{2B^2} = cm = c\sqrt p$. $\square$

**Consequence.** With $B$ fixed the required curve budget is $\Theta(p)$ — an
exponent of $1$ in $\log p$, not $1/2$. The reported slope of $0.48$ cannot be
an asymptotic property of the fixed-window lite structure. An uncensored
replication over genuine random curves, retaining all targets rather than
discarding the $3.1\%$ on which the run did not terminate, yields a slope of
$0.99$–$1.03$ over precisely the reported $k = 16 \to 20$ range, in agreement
with Theorem 5.2.

**Theorem 5.4 (Exponent bookkeeping).** *For $p > 0$ and any real $\alpha$,*
$$\frac{p}{p^{\alpha}} = p^{1-\alpha}.$$

*Proof.* $p^{1-\alpha} = p^1 \cdot p^{-\alpha}$. $\square$

**Theorem 5.5 (Effective stage-one bound from a measured slope).** *For $p > 0$,
$B > 0$ and real $\alpha$,*
$$B^2 = p^{\alpha} \iff B = p^{\alpha/2}.$$

*Proof.* If $B^2 = p^\alpha$ then $B = \sqrt{B^2} = (p^\alpha)^{1/2} =
p^{\alpha/2}$ using $B > 0$. Conversely $(p^{\alpha/2})^2 = p^{\alpha}$.
$\square$

**Interpretation.** Suppose a campaign's per-curve visible mass is $p^\alpha$;
Theorem 5.4 says its budget is $p^{1-\alpha}$, so a measured budget exponent of
$s$ means $\alpha = 1 - s$. Since the visible mass of the lite arm is $B^2$,
Theorem 5.5 converts this into an effective stage-one bound

$$B_{\mathrm{eff}} = p^{\alpha/2} = p^{(1-s)/2}.$$

For the reported $s = 0.48$: $\alpha = 0.52$ and $B_{\mathrm{eff}} \approx
p^{0.26}$. At $k = 16$ bits this is $2^{0.26 \times 16} = 2^{4.16} \approx 18$;
at $k = 20$ it is $2^{5.2} \approx 37$. The fixed bound actually deployed was
$B_1 = 50 = 2^{5.64}$. Over a four-bit range the two are numerically
indistinguishable, and this is precisely the masquerade that Theorem 5.3
forbids asymptotically.

**Theorem 5.6 (Exact crossover).** *For $m \ge 1$, taking $p = m^4$ and
$B = m = p^{1/4}$ gives*
$$\frac{p}{2B^2} = \frac{\sqrt p}{2}.$$

*Proof.* $p/(2m^2) = m^4/(2m^2) = m^2/2 = \sqrt{m^4}/2$. $\square$

So a genuine square-root budget corresponds *exactly* to a stage-one bound
growing like $p^{1/4}$.

**Theorem 5.7 (Matching Pollard's rho requires abandoning smoothness).** *For
$p, B \ge 1$,*
$$\frac{p}{4B} \le \sqrt p \iff \sqrt p \le 4B.$$

*Proof.* $\frac{p}{4B} \le \sqrt p \iff p \le 4B\sqrt p \iff \sqrt p \cdot
\sqrt p \le 4B \sqrt p \iff \sqrt p \le 4B$, dividing by $\sqrt p > 0$.
$\square$

Reaching constant success probability costs the lite arm about $p/(4B^2)$
curves, hence about $p/(4B)$ point operations; rho costs $\sqrt p$. Theorem 5.7
says the lite arm matches rho if and only if $B \gtrsim \sqrt p$ — at which
point the "smoothness bound" is a birthday search and the curve structure is
buying nothing.

**Theorem 5.8 (Guaranteed hits cost more than $\sqrt N$).** *Model a lite
campaign by the finite set $S$ of inspected points, with $|S| \le C\cdot B$ over
$C$ curves of $B$ multiples each. Let $N = pq$ with $q \le p$. If the campaign is
guaranteed to exhibit a collision of residues modulo $p$ — i.e. for every
function $f$ taking values in $\{0,\dots,p-1\}$ there are distinct $x, y \in S$
with $f(x) = f(y)$ — then*
$$\lfloor \sqrt{N} \rfloor < C\cdot B.$$

*Proof.* A guaranteed collision under all $p$-valued functions forces
$|S| > p \ge \sqrt{pq} = \sqrt N$ by pigeonhole (if $|S| \le p$ an injective $f$
exists). Combine with $|S| \le CB$. $\square$

The sequential-multiple structure therefore buys nothing at all against the
generic birthday barrier.

---

## 6. The addition-chain barrier

We now abstract away from the specific schedule and ask what *any* stage-one
computation can achieve per point operation.

**Definition 6.1 (Addition chain).** An *addition chain* is a sequence
$(m_t)_{t \ge 0}$ of positive integers with $m_0 = 1$ such that for every $t$
there exist $i, j \le t$ with $m_{t+1} = m_i + m_j$.

This is precisely the class of multiples reachable by curve additions: at each
step you may add any two points already computed, and nothing else.

**Theorem 6.2 (Per-operation barrier).** *For every addition chain and every
$t$, $m_t \le 2^t$.*

*Proof.* Strong induction on $t$. For $t = 0$, $m_0 = 1 = 2^0$. For $t+1$, write
$m_{t+1} = m_i + m_j$ with $i, j \le t$. By induction $m_i \le 2^i \le 2^t$ and
$m_j \le 2^j \le 2^t$, so $m_{t+1} \le 2^t + 2^t = 2^{t+1}$. $\square$

**Definition 6.3.** The *sequential chain* is $m_t = t + 1$ (with $m_{t+1} =
m_t + m_0$); the *doubling chain* is $m_t = 2^t$ (with $m_{t+1} = m_t + m_t$).
Both are addition chains.

**Corollary 6.4 (The barrier is attained).** *The doubling chain satisfies
$m_t = 2^t$, hence dominates every addition chain entrywise: $2^t$ is exactly
the optimum reach after $t$ operations.*

**Lemma 6.5.** *For $t \ge 3$, $\;2t + 1 < 2^t$.*

*Proof.* Induction from $t = 3$: $7 < 8$. If $2t+1 < 2^t$ then
$2(t+1)+1 = 2t + 3 \le (2t+1) + 2 < 2^t + 2 \le 2^t + 2^t = 2^{t+1}$ for
$t \ge 1$. $\square$

**Corollary 6.6.** *For $t \ge 3$ the sequential chain's entry $t+1$ is strictly
below the doubling chain's $2^t$; indeed the sequential entry is linear while
the barrier is exponential.*

**Theorem 6.7 (Bounded reach bounds detection).** *Let $P$ be a point of finite
order and suppose a run forms multiples $i, j \le M$ with $i < j$ and
$\mathrm{XEq}(iP, jP)$. Then $\operatorname{ord}(P) \le 2M$.*

*Proof.* By Lemma 3.2, $\operatorname{ord}(P)$ divides $j - i$ (positive, and
$\le M$) or $i + j$ (positive, and $\le 2M$). In either case a positive divisor
is at most its multiple. $\square$

The point of Theorem 6.7 is its indifference to the schedule: only the size of
the largest multiple matters.

**Theorem 6.8 (Exponential versus linear at equal cost).** *For $t \ge 3$,
consider the group $\mathbb{Z}/2^t$ with base point the generator, of order
$2^t$. Then*

1. *the doubling chain's $t$-th multiple annihilates it:
   $2^t \cdot 1 = 0$ in $\mathbb{Z}/2^t$; while*
2. *the sequential run of the same length $t$ — visiting $1, \dots, t+1$ — has
   no $x$-collision.*

*Proof.* (1) is definitional. For (2), by Theorem 3.3 an $x$-collision in a run
of length $B = t+1$ requires order $\le 2(t+1) - 1 = 2t + 1$; but the order is
$2^t > 2t+1$ by Lemma 6.5. $\square$

So the lite arm does not merely forfeit smoothness relative to true ECM: at
equal operation count it forfeits an exponential factor of raw reach.

---

## 7. Which visiting sets detect which orders

Theorem 6.7 shows that *reach* controls detection; we now show that *shape* does
too, even at fixed reach and fixed cost.

**Definition 7.1 (Detection by a visiting set).** For a finite set
$J \subseteq \mathbb{N}$ of multiples and an integer $d \ge 1$, say $J$
*detects* $d$ if there exist $i, j \in J$ with $i < j$ and
$d \mid j - i$ or $d \mid i + j$.

**Theorem 7.2 (Visiting sets detect by divisibility).** *For a point $P$ of
finite order and any finite $J \subseteq \mathbb{N}$, the run over $J$ has an
$x$-coordinate coincidence — i.e. there are $i < j$ in $J$ with
$\mathrm{XEq}(iP, jP)$ — if and only if $J$ detects $\operatorname{ord}(P)$.*

*Proof.* Apply Lemma 3.2 pairwise. $\square$

The sequential run is the special case $J = \{1, \dots, B\}$, and Theorem 3.3 is
the statement that $\{1,\dots,B\}$ detects exactly $\{1, \dots, 2B-1\}$.

**Theorem 7.3 (The sequential shape is suboptimal).** *At three additions
(four visited multiples):*

1. *$J_{\mathrm{seq}} = \{1,2,3,4\}$ detects every $d \in \{1,\dots,7\}$ and no
   larger $d$;*
2. *$J_{\mathrm{geo}} = \{1,2,4,8\}$ detects $9$, $10$ and $12$, none of which
   $J_{\mathrm{seq}}$ detects.*

*Proof.* Finite verification. For $J_{\mathrm{seq}}$ the pairwise differences
are $\{1,2,3\}$ and sums $\{3,4,5,6,7\}$; the detected set is the set of
divisors of these values, which is exactly $\{1,\dots,7\}$, and $7$ is the
largest value available. For $J_{\mathrm{geo}}$ the differences are
$\{1,2,3,4,6,7\}$ and the sums are $\{3,5,6,9,10,12\}$; thus $9, 10, 12$ are
detected, and each exceeds $7$. $\square$

**Corollary 7.4.** *A base point of order $12$ is found by the run over
$\{1,2,4,8\}$ and missed by the run over $\{1,2,3,4\}$, at the identical cost of
three curve additions.*

The sequential run therefore maximises the *contiguous* window while minimising
the *reach*. It is optimal for a criterion that no factoring campaign has ever
cared about.

---

## 8. Algorithms

We record the three computational procedures implicit in the analysis.

### 8.1 Exact lite-visible-set counter

Given a cyclic group order $n$ and a bound $B$, compute
$\sum_{d \mid n,\, d \le B} \varphi(d)$ by enumerating divisors of $n$ up to $B$
and summing totients. Complexity: $O(\sqrt n + B\log\log B)$ with a sieve of
totients up to $B$. This gives the *exact* per-curve success probability
numerator for a cyclic curve group, against which the bound $B^2$ of Corollary
4.2 can be checked for tightness.

### 8.2 Detection-set enumerator for an arbitrary visiting schedule

Given a finite visiting set $J$, compute the set of orders it detects: form all
pairwise differences and sums, and return the union of their divisor sets.
Complexity $O(|J|^2 \cdot \sqrt{\max J})$. This is the computational content of
Theorem 7.2 and is what produces the comparison of Theorem 7.3.

### 8.3 Budget-exponent estimator

Given per-curve success probabilities $q(p)$ measured or predicted at several
$p$, estimate the exponent $s$ in $C(p) \asymp p^{s}$ by least squares of
$\log_2 C$ against $\log_2 p$, and convert to an effective stage-one bound via
$B_{\mathrm{eff}} = p^{(1-s)/2}$ (Theorem 5.5). Complexity $O(\text{samples})$.
The essential diagnostic is to run this estimator over a *wide* range of $p$;
Theorem 5.3 guarantees that with fixed $B$ the estimate converges to $1$, while
over a four-bit window it may report anything.

---

## 9. Discussion

### 9.1 What the theorems say about the measurement

The reported plane of four exponents — trial division $0.84$, rho $0.52$,
Fermat $0.50$, lite $0.48$ — is internally coherent as a description of a
dataset and misleading as a description of asymptotics. Theorem 5.2 pins the
lite exponent at $1$ for any fixed $B$; Theorem 5.3 shows no constant can rescue
a square-root reading. The number $0.48$ survives only under a change of
normalisation (measuring against $\log_2 N$ of a balanced semiprime, which
halves the exponent) or under the hypothesis of an effective growing window
$B_{\mathrm{eff}} \approx p^{0.26}$, which Theorem 5.5 makes precise and which a
constant $50$ imitates over four bits and only there.

### 9.2 Why "birthday scaling" is the wrong frame

Pollard's rho attains $\sqrt p$ because it *accumulates state*: after $n$ steps
its trajectory offers $\binom{n}{2}$ candidate collisions, and the birthday
bound is exactly the statement that this quadratic supply of pairs meets a
linear supply of slots at $n \asymp \sqrt p$. The lite arm accumulates nothing
across curves: each curve is a fresh independent Bernoulli trial in a fresh
group, and the trials never combine. A method whose successes are independent
Bernoulli trials with fixed success probability $q$ has budget $\Theta(1/q)$,
and here $1/q \ge p/B^2 = \Theta(p)$. The exponent $1$ is not a defect of the
particular implementation; it is a theorem about the absence of accumulation.

Any future definition of "birthday scaling" for a curve-based method should
therefore be phrased against accumulated state, not against a per-curve window.

### 9.3 The single integer that governs everything

Theorems 6.2 and 6.7 combine into a slogan: after $t$ operations the largest
multiple formed is at most $2^t$, and a run whose multiples are bounded by $M$
detects only orders $\le 2M$. Every stage-one method is therefore an argument
about how efficiently to spend $t$ operations climbing toward the ceiling $2^t$.
True ECM spends optimally *and* converts reach into a divisibility condition,
cashing in against the abundance of smooth numbers. The doubling ladder spends
optimally but converts reach into an interval condition. The sequential run does
neither: it attains reach $t+1$ against a ceiling of $2^t$, and converts it into
an interval.

### 9.4 Practical implications

- **Never fix a stage-one bound while measuring an exponent.** A fixed parameter
  will imitate a growing one over any sufficiently narrow range; the imitation
  is a mathematical certainty, not an experimental accident.
- **Report uncensored budgets.** Discarding the $3.1\%$ of targets on which a
  campaign fails to terminate systematically biases the fitted exponent
  downward, since the discarded cases are precisely the expensive ones.
- **Prefer non-contiguous visiting schedules if using sequential-style runs.**
  Theorem 7.3 shows the contiguous schedule is the worst choice for reach at
  fixed cost.

---

## 10. Future directions

**The smoothness-free barrier.** All of the lite arm's loss appears to be
captured by a single integer: the largest multiple it ever forms. We conjecture
that for *any* stage-one computation using $t$ curve operations, the probability
that a random curve is factored is at most $c \cdot 2^{2t}/p$, with the order of
equality attained by the doubling ladder — so that no reordering of sequential
multiples can beat $p^{1-o(1)}$ curve budgets unless $t \gtrsim \log p$.
Theorem 6.2 already supplies the reach bound $2^t$, and Theorem 6.7 converts
reach into detected orders; what is missing is the counting step over group
orders in the Hasse interval.

**Hasse-interval divisor mass.** The per-curve success probability is a
divisor-mass average over the Hasse interval, not a birthday probability. We
conjecture that for fixed $B$, the average over curves of
$\#\{P : \operatorname{ord}(P) \le B\}/|E|$ equals
$$\frac{1}{p}\sum_{d \le B} \frac{\varphi(d)}{d} \cdot \bigl(1 + O(p^{-1/2})\bigr) \;\approx\; \frac{0.61\,B}{p}.$$
The constant $6/\pi^2 \approx 0.608$ is the natural candidate, since
$\sum_{d \le B}\varphi(d)/d \sim (6/\pi^2)B$. Measured budgets are consistent
with this.

**A sharp comparison of visiting schedules.** Given a budget of $t$ additions,
which visiting set $J$ maximises the number of detected orders below a target
$D$ — equivalently, maximises $\#\{d \le D : J \text{ detects } d\}$? Theorem
7.3 shows the contiguous set is not optimal; a full characterisation of the
optimum, presumably related to perfect difference sets and $B_h[g]$ sets, is
open.

**Restoring smoothness cheaply.** Is there a schedule interpolating between the
sequential run and the lcm ladder that recovers a nontrivial fraction of ECM's
smoothness advantage at sub-lcm cost? The divisibility criterion of Theorem 7.2
makes this a purely combinatorial question about difference and sum sets.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Lite window | The sequential run annihilates $P$ iff $\operatorname{ord}(P) \le B$ |
| ECM window | True ECM annihilates $P$ iff $\operatorname{ord}(P)$ is $B$-smooth |
| Strict separation | Order $96$ is $50$-smooth but invisible to the lite arm at $B=50$ |
| Sharp detection window | For $B \ge 3$: $x$-collision $\iff \operatorname{ord}(P) \le 2B-1$; order $2B$ invisible |
| Two-torsion degeneracy | $2P = 0 \iff \operatorname{ord}(P) \le 2$ (the v1 bug) |
| Visible-set bound | $\le B^{k+1}$ points if $d\cdot a = 0$ has $\le d^k$ solutions; $\le B^2$ cyclic |
| Exact count | $\sum_{d \mid |G|,\, d \le B}\varphi(d)$ in the cyclic case |
| Detection gap | Order $1058400$: ECM sees all, lite sees $\le 2500$ |
| Budget lower bound | Fewer than $p/(2B^2)$ curves give success probability $< 1/2$ |
| Fixed-$B$ refutation | For all fixed $B$ and all $c$, some $p$ has $c\sqrt p < p/(2B^2)$ |
| Effective bound | Measured budget exponent $s$ $\Rightarrow$ $B_{\mathrm{eff}} = p^{(1-s)/2}$ |
| Crossover | $B = p^{1/4}$ gives exactly a $\sqrt p /2$ budget |
| Rho comparison | Lite matches rho iff $\sqrt p \le 4B$ |
| Addition-chain barrier | $m_t \le 2^t$, attained by the doubling ladder |
| Reach bounds detection | Multiples $\le M$ detect only orders $\le 2M$ |
| Exponential gap | For $t \ge 3$: doubling kills order $2^t$, sequential run of length $t$ cannot see it |
| Shape matters | $\{1,2,4,8\}$ detects $9,10,12$; $\{1,2,3,4\}$ detects exactly $1..7$ |
