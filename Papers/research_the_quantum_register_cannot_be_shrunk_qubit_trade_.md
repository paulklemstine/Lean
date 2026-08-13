# The Register Threshold of Order Finding: Truncation, Sample Fungibility, and an Exact Success Density

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

Shor's order-finding algorithm is conventionally run with a phase register of
$\ell = 2\lceil \log_2 N \rceil$ qubits. We ask whether that register can be
truncated: if only the top $t$ bits of the Fourier outcome are measured, can the
order $r$ still be recovered by taking more samples? We answer the question
completely, with matching upper and lower bounds, in two independent
measurement models.

We prove a two-sided **register threshold**: for any bound $R$ on the order, a
$t$-bit register determines the continued-fraction target whenever
$R^2 \le 2^t$ (equivalently $t \ge 2\log_2 R + 2$), and fails to determine it
whenever $2^t < R(R-1)$ (equivalently $t + 1 \le 2\log_2 R$). Hence
$t_{\min} = 2\log_2 R + O(1)$. The optimistic prediction $t_{\min} = \log_2 r +
O(\log\log r)$ is refuted: a register of $\log_2 R + c$ bits is ambiguous for
every constant $c$ as soon as $R > 2^c + 1$. The same quadratic threshold is
established in the strictest *dyadic-grid* model, via an elementary Farey count
showing that at least $R^2/4$ distinct reduced fractions of denominator $\le 2R$
lie in $(0,1)$.

Below the weaker collapse threshold $2^t \le r$ the situation is worse than
ambiguity: the truncated outcome map is surjective onto the whole $t$-bit
alphabet, so the *sets of observable records coincide* for all orders in
$[2^t, R]$, and no estimator with any sample budget and unbounded computation
can be correct for two distinct such orders. A truncated sample carries exactly
$\min(2^t, r)$ symbols; identifying an order out of a family $S$ therefore costs
$m\cdot t \ge \log_2 |S|$ bits in total. A permanent divisor ambiguity — orders
$r$ and $rs$ have nested outcome supports at *every* register size — shows that
no support-only estimator ever exists.

Above the threshold the only remaining obstruction is $\gcd(k,r) > 1$, and it is
repaired by sampling. A record recovers the order if and only if the sampled
numerators are jointly coprime to $r$, equivalently if and only if the sampled
residues generate $\mathbb{Z}/r\mathbb{Z}$. We count the successful records
exactly: their number is Jordan's totient
$J_m(r) = \sum_{d \mid r}\mu(d)(r/d)^m = r^m \prod_{p \mid r}(1 - p^{-m})$, so
the failure probability of $m$ samples is exactly
$1 - \prod_{p\mid r}(1-p^{-m})$, which is $< 2^{-(m-1)}$ uniformly in $r$; in
particular two samples succeed for a strict majority of records, for every
order. The final resource ledger is $2\log_2 r + O(1)$ qubits — rigid — against
$O(1)$ samples — nearly free. Since $r \sim N$ for a random base modulo a
semiprime, $t_{\min} \approx 2\log_2 N$: Shor's register is forced.

**Keywords:** order finding, continued fractions, Farey separation, phase
estimation, register truncation, Jordan totient, Möbius inversion, sample
complexity.

---

## 1. Introduction

### 1.1 The question

Shor's factoring algorithm reduces factoring an integer $N$ to **order
finding**: given $a$ with $\gcd(a,N) = 1$, find the least $r \ge 1$ with
$a^r \equiv 1 \pmod N$. The quantum subroutine is phase estimation applied to
multiplication by $a$; it returns a measurement outcome encoding a real number
$$x \;\approx\; \frac{k}{r}, \qquad 0 \le k < r,$$
with $k$ approximately uniform, and the classical post-processing recovers $k/r$
— hence $r$ — by continued fractions. The standard analysis takes the phase
register to have $\ell = 2\lceil \log_2 N\rceil$ qubits, guaranteeing the
accuracy $|x - k/r| < 1/(2r^2)$ under which the continued-fraction step is
provably correct.

Qubits are the scarcest resource in every projected implementation. The natural
engineering question is therefore whether $\ell$ can be reduced by *truncating*
the register: measuring only the top $t$ bits of the outcome and compensating
with a larger number of samples. Because the classical post-processor is free to
be arbitrarily clever, and because $m$ independent samples of $t$ bits carry
$mt$ bits in total, one might hope for a smooth qubit–sample trade curve — say,
$t = \log_2 r + O(\log\log r)$ with polynomially many samples.

### 1.2 The answer

There is no such trade curve. The behaviour is a sharp trichotomy with a wall at
$t \approx 2\log_2 r$:

1. **$t \le \log_2 r$ (collapse).** The observable data are *identical* for all
   orders $\ge 2^t$. No estimator, with any sample budget, is correct for two of
   them.
2. **$\log_2 r < t < 2\log_2 r$ (single-shot ambiguity).** The
   continued-fraction target itself is undetermined by a $t$-bit reading; two
   distinct legitimate orders remain compatible with one outcome.
3. **$t \ge 2\log_2 r + O(1)$ (recovery).** The target is determined, and the
   only residual obstruction — the sample-dependent gcd defect — is repaired by
   a constant number of extra samples with failure probability $< 2^{-(m-1)}$.

The threshold's location is not quantum-mechanical in origin. It is the
elementary fact that distinct rationals of denominator $\le R$ are separated by
at least $1/R^2$, so an interval of width $2^{-t}$ contains at most one of them
precisely when $2^t \gtrsim R^2$. The exponent $2$ is the product of the two
denominators in that separation bound.

### 1.3 Contributions and organisation

Section 2 fixes the two measurement models. Section 3 proves the two-sided
resolution threshold in the tolerance model and refutes the linear prediction.
Section 4 proves the classical collapse below $\log_2 r$ bits, computes the
exact capacity of a truncated sample, and establishes the permanent divisor
ambiguity and the product bound $mt \ge \log_2|S|$. Section 5 characterises
successful records arithmetically and group-theoretically. Section 6 counts
successful records exactly (Jordan's totient) and derives uniform concentration.
Section 7 re-proves the quadratic threshold in the dyadic-grid model via a Farey
count. Section 8 combines depth and width into an irreducibility statement and
exhibits arithmetic instances realising every order. Section 9 discusses
consequences, limitations, and future directions; algorithms are collected in
Section 10.

---

## 2. The models

Throughout, $r \ge 1$ denotes the true order, $k$ a sampled numerator with
$0 \le k < r$, and $R$ an a-priori bound on the order (in the factoring
application, $R = N$).

**Definition 2.1 (order fraction).** For $k, r \in \mathbb{N}$ with $r > 0$, the
*order fraction* is the rational number $k/r$. Its reduced denominator is
$$\operatorname{den}(k/r) \;=\; \frac{r}{\gcd(k,r)} .$$
In particular the reduced denominator equals $r$ exactly when
$\gcd(k,r) = 1$.

**Definition 2.2 (tolerance model).** A $t$-bit phase register has *resolution*
$\operatorname{res}(t) = 2^{-(t+1)}$. A rational $q$ is *compatible* with an
observed phase $x \in \mathbb{R}$ if
$$|x - q| \;<\; \operatorname{res}(t) \;=\; 2^{-(t+1)} .$$
Two rationals are *confusable at $t$ bits* if some $x$ is compatible with both.
This is the model in which Shor's continued-fraction step is analysed: the
outcome $m$ localises the phase to the interval of radius $2^{-(t+1)}$ about
$m/2^t$.

**Definition 2.3 (grid model).** A $t$-bit *truncated register* reports, for the
exact phase $k/r$, the cell index
$$\operatorname{out}_t(r,k) \;=\; \left\lfloor \frac{2^t k}{r}\right\rfloor
 \;\in\; \{0,1,\dots,2^t-1\} \quad (0 \le k < r),$$
and two phases are confusable exactly when they lie in the same dyadic cell,
i.e. when $\lfloor 2^t x\rfloor = \lfloor 2^t x'\rfloor$. The set of outcomes
realised at order $r$ is $\mathcal{O}_t(r) = \{\operatorname{out}_t(r,k) : 0 \le
k < r\}$. A *record* is a finite list of outcomes; an *estimator* is an
arbitrary function from records to $\mathbb{N}$, with no computational
restriction.

The grid model is strictly the harsher of the two — it discards even the
sub-cell information that a tolerance interval retains — and Section 7 shows the
threshold is the same in both. Lemma 7.5 shows the two models describe the same
measurement on order fractions: the dyadic cell of $k/r$ *is*
$\operatorname{out}_t(r,k)$.

---

## 3. The resolution threshold

### 3.1 Separation of rationals

**Theorem 3.1 (Farey separation).** *For distinct rationals $a \ne b$,*
$$|a - b| \;\ge\; \frac{1}{\operatorname{den}(a)\cdot \operatorname{den}(b)} .$$

*Proof.* Write $a = p/q$, $b = p'/q'$ in lowest terms. Then
$(a-b)qq' = pq' - p'q =: z \in \mathbb{Z}$, and $z \ne 0$ since $a \ne b$;
hence $|a-b| \cdot qq' = |z| \ge 1$. $\square$

Everything in this section is a corollary of Theorem 3.1 together with the
triangle inequality.

### 3.2 Sufficiency

**Theorem 3.2 (unique continued-fraction target).** *Let $R, t \in \mathbb{N}$
with $R^2 \le 2^t$. If $q_1, q_2$ are rationals with reduced denominators at
most $R$, both compatible with the same phase $x$ at $t$ bits, then
$q_1 = q_2$.*

*Proof.* Suppose $q_1 \ne q_2$. By the triangle inequality,
$$|q_1 - q_2| \;\le\; |x - q_1| + |x - q_2| \;<\; 2\cdot 2^{-(t+1)} \;=\; 2^{-t}.$$
By Theorem 3.1 and $\operatorname{den}(q_i) \le R$,
$$|q_1 - q_2| \;\ge\; \frac{1}{\operatorname{den}(q_1)\operatorname{den}(q_2)}
 \;\ge\; \frac{1}{R^2} \;\ge\; 2^{-t},$$
a contradiction. $\square$

**Corollary 3.3 (order-level uniqueness).** *Let $R^2 \le 2^t$. If two samples
$k_1/r_1$ and $k_2/r_2$ have numerators coprime to their orders, orders bounded
by $R$, and are both compatible with the same phase $x$, then $r_1 = r_2$.*

*Proof.* Coprimality makes the reduced denominator of $k_i/r_i$ equal to $r_i$
(Definition 2.1); apply Theorem 3.2 and read off denominators. $\square$

In bit form, using $R < 2^{\lfloor \log_2 R\rfloor + 1}$:

**Corollary 3.4 (sufficiency in bits).** *If $t \ge 2\lfloor\log_2 R\rfloor + 2$
then a $t$-bit register determines the continued-fraction target among all
fractions of reduced denominator at most $R$.*

### 3.3 Necessity

The extremal configuration is the neighbouring pair $1/R$ and $1/(R-1)$.

**Lemma 3.5 (nearest pair).** *For $R \ge 2$,*
$$\frac{1}{R-1} - \frac{1}{R} \;=\; \frac{1}{R(R-1)} \;>\; 0 .$$
*Both fractions are reduced, with denominators $R$ and $R-1$; both are honest
order fractions, arising from a sample $k = 1$ at orders $R$ and $R-1$
respectively.*

**Theorem 3.6 (ambiguity below the threshold).** *Let $R \ge 2$ and
$2^t < R(R-1)$. Then there exists a phase $x$ compatible at $t$ bits with both
$1/R$ and $1/(R-1)$. In particular a $t$-bit register cannot decide between the
orders $R$ and $R-1$, and no post-processing can.*

*Proof.* Take $x$ to be the midpoint of the two fractions. Each is at distance
$\tfrac12 \cdot \tfrac{1}{R(R-1)} = (2R(R-1))^{-1}$ from $x$, and
$2^t < R(R-1)$ gives $2^{t+1} < 2R(R-1)$, i.e.
$(2R(R-1))^{-1} < 2^{-(t+1)} = \operatorname{res}(t)$. So both are
compatible with $x$. $\square$

**Theorem 3.7 (the two-sided threshold).** *For every $R \ge 3$:*

*(a) if $t \ge 2\lfloor\log_2 R\rfloor + 2$, all fractions of reduced
denominator $\le R$ compatible with one phase coincide;*

*(b) if $t + 1 \le 2\lfloor\log_2 R\rfloor$, there is a phase compatible with
two distinct fractions of reduced denominator $\le R$.*

*Hence the minimal usable register size satisfies*
$$2\log_2 R - 1 \;\le\; t_{\min} \;\le\; 2\log_2 R + 2, \qquad
t_{\min} = 2\log_2 R + O(1).$$

*Proof.* (a) is Corollary 3.4. For (b): $2^{\lfloor \log_2 R\rfloor} \le R$
gives $2^{t+1} \le 2^{2\lfloor\log_2 R\rfloor} \le R^2$, so
$2^t \le R^2/2 < R(R-1)$ for $R \ge 3$, and Theorem 3.6 applies. $\square$

### 3.4 Refutation of the linear prediction

**Theorem 3.8 (no linear register).** *For all constants $c \ge 0$: if
$R > 2^c + 1$ and $2^t \le 2^c R$, then there is a phase compatible with two
distinct fractions of reduced denominator $\le R$. In particular a register of
$\log_2 R + c$ bits is ambiguous for every constant $c$, and no additive
correction of size $o(\log R)$ — in particular none of size $O(\log\log R)$ —
suffices.*

*Proof.* $2^c < R - 1$ gives $2^t \le 2^c R < R(R-1)$; apply Theorem 3.6.
$\square$

This settles the resource question in the negative: the exponent $2$ in
$t_{\min} \sim 2\log_2 r$ is real, not an artifact of a lossy analysis.

---

## 4. Below the threshold: classical collapse, capacity, permanent ambiguity

Section 3 shows the *decoding problem* is ill-posed below $2\log_2 R$ bits. One
might still hope the *statistics* of many coarse samples distinguish orders.
They do not — and for $t \le \log_2 r$ the failure is total.

### 4.1 Surjectivity and collapse

**Theorem 4.1 (surjectivity of the truncated outcome).** *If $2^t \le r$, then
for every $m < 2^t$ there is $k < r$ with $\operatorname{out}_t(r,k) = m$.*

*Proof sketch.* Write $mr = 2^t q + s$ with $0 \le s < 2^t$ and set
$k = \lceil mr/2^t\rceil$. Since $2^t \le r$, the half-open window
$[mr/2^t, (m+1)r/2^t)$ has length $r/2^t \ge 1$ and therefore contains an
integer $k$; that $k$ satisfies $m \le 2^tk/r < m+1$, i.e.
$\lfloor 2^tk/r\rfloor = m$, and $k < r$ because $m < 2^t$. $\square$

**Corollary 4.2 (order-independent alphabet).** *If $2^t \le r$ then
$\mathcal{O}_t(r) = \{0,1,\dots,2^t-1\}$ — independent of $r$.*

**Corollary 4.3 (records coincide).** *If $2^t \le r$ and $2^t \le r'$, then a
list $L$ of outcomes is realisable at order $r$ if and only if it is realisable
at order $r'$ — for records of arbitrary length.*

**Theorem 4.4 (samples do not help).** *Let $r \ne r'$ with $2^t \le r$ and
$2^t \le r'$. There is no estimator $A$ (an arbitrary function from records to
$\mathbb{N}$, with no bound on record length or computation) such that $A$
returns $r$ on every record realisable at order $r$ and $r'$ on every record
realisable at order $r'$.*

*Proof.* Pick any record $L$ realisable at $r$. By Corollary 4.3 it is also
realisable at $r'$, so $r = A(L) = r'$, contradiction. $\square$

**Corollary 4.5 (the collapse window).** *All $R - 2^t + 1$ orders in
$[2^t, R]$ emit exactly the same set of records, namely all lists over
$\{0,\dots,2^t-1\}$.*

This is the "classical collapse" of the experiment: below $\log_2 r$ bits the
sample budget is irrelevant because the data distributions do not merely
overlap, their supports are equal.

### 4.2 Capacity of a truncated sample

**Theorem 4.6 (exact capacity).** *For $r > 0$,*
$$\bigl|\{\operatorname{out}_t(r,k) : 0 \le k < r\}\bigr| \;=\; \min(2^t, r).$$

*Proof sketch.* If $2^t \le r$ the image is the full alphabet by Corollary 4.2,
of size $2^t$. If $r \le 2^t$ the map is strictly increasing on $[0,r)$ —
because $2^t(k+1) \ge 2^tk + r$ forces $\lfloor 2^t(k+1)/r\rfloor >
\lfloor 2^tk/r\rfloor$ — hence injective, and the image has size $r$. $\square$

So a single truncated sample is worth $\min(t, \log_2 r)$ bits about the phase,
never more. Below the collapse threshold the register is *saturated*: it emits
its full alphabet regardless of $r$.

### 4.3 The product bound

**Theorem 4.7 (sample-count lower bound).** *Let $S$ be a finite family of
candidate orders, $A$ an arbitrary estimator, and suppose that for each $r \in S$
there is a record $L(r)$ of exactly $m$ symbols from the $t$-bit alphabet with
$A(L(r)) = r$. Then*
$$|S| \;\le\; (2^t)^m, \qquad\text{i.e.}\qquad m\cdot t \;\ge\; \log_2 |S| .$$

*Proof.* $r \mapsto L(r)$ is injective (if $L(r) = L(r')$ then
$r = A(L(r)) = A(L(r')) = r'$), and lands in a set of size $(2^t)^m$. $\square$

**Corollary 4.8 (the exchange rate on the collapse window).** *Identifying every
order in $[2^t, R]$ from $m$ truncated samples requires
$R - 2^t + 1 \le (2^t)^m$, i.e. $m \cdot t \ge \log_2(R - 2^t + 1)$.*

Qubits and samples are exchangeable *only* through their product $mt$, and only
above the collapse threshold: inside the window the requirement can never be
met, because by Theorem 4.4 no such estimator exists at any $m$.

### 4.4 A permanent obstruction: divisor ambiguity

**Theorem 4.9 (nested supports).** *If $r \mid r'$ and $r' > 0$, then
$\mathcal{O}_t(r) \subseteq \mathcal{O}_t(r')$ for **every** $t$.*

*Proof.* Write $r' = sr$. Then $k/r = (sk)/(sr)$ exactly, so the outcome of $k$
at order $r$ equals the outcome of $sk$ at order $r'$, and $sk < r'$. $\square$

**Corollary 4.10 (no support-only estimator).** *For $r > 0$ and $s > 1$, no
estimator that depends only on the **set** of outcomes observed (rather than
their multiplicities) can be correct for both $r$ and $rs$ — at any register
size $t$ and any sample budget.*

Adding qubits never removes divisor ambiguity. Only *frequencies* — the
statistics repaired in Section 5 — can.

---

## 5. Above the threshold: what samples buy

Above the resolution threshold the target fraction is determined, but continued
fractions return $k/r$ *in lowest terms*, whose denominator is $r/\gcd(k,r)$.

**Definition 5.1.** The *recovered order* from one sample is
$\rho(k,r) := \operatorname{den}(k/r) = r/\gcd(k,r)$. For a record
$K = (k_1,\dots,k_m)$ the *record estimate* is
$\widehat{r}(K) := \operatorname{lcm}\bigl(\rho(k_1,r),\dots,\rho(k_m,r)\bigr)$,
with $\widehat r(\varnothing) = 1$. The *record gcd* is
$g(K) := \gcd(k_1,\dots,k_m)$ (with $g(\varnothing) = 0$).

**Proposition 5.2.** *$\rho(k,r) \mid r$ always; $\rho(k,r) = r$ iff
$\gcd(k,r) = 1$; and $\rho(k,r) < r$ strictly whenever $\gcd(k,r) > 1$.*

**Theorem 5.3 (the sample criterion, sharp).** *For $r > 0$ and any record $K$,*
$$\widehat{r}(K) = r \iff \gcd\bigl(g(K),\, r\bigr) = 1 .$$

*Proof sketch.* ($\Leftarrow$) Each $\rho(k_i,r)$ divides $r$, so
$d := \widehat r(K)$ divides $r$. Suppose $d < r$ and pick a prime
$p \mid r/d$. For each $i$ we have $\rho(k_i,r) \mid d \mid r$, hence
$(r/d) \mid r/\rho(k_i,r) = \gcd(k_i,r)$, so $p \mid k_i$. Therefore
$p \mid g(K)$ and $p \mid r$, contradicting joint coprimality.
($\Rightarrow$) If $\gcd(g(K),r) \ne 1$, choose a prime $p$ dividing it. Then
$p \mid k_i$ and $p \mid r$ for all $i$, so each $\rho(k_i,r) = r/\gcd(k_i,r)$
divides $r/p$; hence $\widehat r(K) \mid r/p < r$. $\square$

**Corollary 5.4 (two samples).** *If $\gcd(\gcd(k_1,k_2), r) = 1$ then
$\operatorname{lcm}(\rho(k_1,r),\rho(k_2,r)) = r$, even if each sample alone
under-reports.*

### 5.1 The group-theoretic reading

**Theorem 5.5.** *For $r > 0$, $\rho(k,r)$ is the additive order of $k$ in
$\mathbb{Z}/r\mathbb{Z}$, i.e. the size of the subgroup $\langle k\rangle$.*

*Proof.* The additive order of $k$ modulo $r$ is $r/\gcd(k,r)$. $\square$

**Lemma 5.6 (Bézout along a record).** *The residue of $g(K)$ lies in the
additive subgroup of $\mathbb{Z}/r\mathbb{Z}$ generated by the residues of the
entries of $K$.*

*Proof sketch.* Induct along the record: $\gcd(a, g) = \alpha a + \beta g$ for
integers $\alpha,\beta$ by Bézout, and integer multiples and sums stay in the
subgroup. $\square$

**Theorem 5.7 (generation criterion).** *For $r > 0$ the residues of a record
$K$ generate $\mathbb{Z}/r\mathbb{Z}$ if and only if $\gcd(g(K), r) = 1$.
Consequently*
$$\widehat r(K) = r \iff \langle \bar k_1, \dots, \bar k_m\rangle = \mathbb{Z}/r\mathbb{Z}.$$

*Proof sketch.* If the closure is everything, then $1$ is an integer combination
of the $k_i$ modulo $r$, so $\gcd(g(K), r) = 1$. Conversely, if
$\gcd(g(K), r) = 1$ then some multiple of $g(K)$ is $\equiv 1 \pmod r$, and
$g(K)$ lies in the closure by Lemma 5.6, so $1$ does; combine with Theorem 5.3.
$\square$

This is the precise content of "qubit–sample fungibility": additional samples
*enlarge the observed subgroup* of $\mathbb{Z}/r\mathbb{Z}$ until it is
everything. Below the resolution threshold, additional qubits enlarge nothing at
all (Theorem 4.4).

---

## 6. How many samples? An exact count

Fix $r \ge 1$ and $m \ge 1$. Let $\mathcal{A}(r,m) = \{0,\dots,r-1\}^m$ be the
set of all length-$m$ records of numerators ($|\mathcal{A}| = r^m$), and let
$$\mathcal{G}(r,m) = \{K \in \mathcal{A}(r,m) : \gcd(g(K), r) = 1\}$$
be the *good* records — exactly those that recover the order, by Theorem 5.3.
Write $\mathcal{B} = \mathcal{A}\setminus\mathcal{G}$ for the bad records and
$\omega(r)$ for the number of distinct prime divisors of $r$.

### 6.1 Union bound and existence

**Theorem 6.1 (bad records are rare).** *For $r > 0$,*
$$|\mathcal{B}(r,m)| \cdot 2^m \;\le\; \omega(r)\, r^m,$$
*i.e. at most a fraction $\omega(r)2^{-m}$ of records fails.*

*Proof sketch.* $K$ is bad iff some prime $p \mid r$ divides every entry. For
fixed $p$, the number of such records is $(r/p)^m \le (r/2)^m$; sum over the
$\omega(r)$ primes. $\square$

**Corollary 6.2 (existence).** *A good record of length $m$ exists whenever
$\omega(r) < 2^m$. Since $2^{\omega(r)} \le r$ gives
$\omega(r) \le \lfloor\log_2 r\rfloor$, $m = \lfloor\log_2\log_2 r\rfloor + 1$
samples always suffice.*

### 6.2 Density with no $\omega$ loss

The union bound is lossy. The following elementary estimate removes the
$\omega(r)$ factor entirely.

**Lemma 6.3 (prime tail).** *For every finite set $S$ of primes,*
$$\sum_{p\in S} \frac{1}{p^2} \;<\; \frac12 .$$

*Proof sketch.* The primes $2,3,5,7$ contribute $\tfrac14 + \tfrac19 +
\tfrac1{25} + \tfrac1{49} = \tfrac{18589}{44100} < 0.4216$. Every other prime is
an odd number $\ge 11$, i.e. of the form $2k+1$ with $k \ge 5$, and distinct
primes give distinct $k$; from $(2k+1)^{-2} \le (4k)^{-1} - (4(k+1))^{-1}$ the
remaining terms telescope to at most $1/20$. The total is
$< 0.4216 + 0.05 < 0.5$. $\square$

**Theorem 6.4 (majority success at two samples).** *For every $r \ge 1$ and
every $m \ge 2$,*
$$r^m \;<\; 2\,|\mathcal{G}(r,m)| ,$$
*i.e. strictly more than half of all length-$m$ records recover the order —
uniformly in $r$, with no dependence on $\omega(r)$.*

*Proof sketch.* $|\mathcal{B}| \le \sum_{p \mid r}(r/p)^m \le r^m\sum_{p\mid r}
p^{-m} \le r^m \sum_{p \mid r} p^{-2} < r^m/2$ by Lemma 6.3; combine with
$|\mathcal{G}| + |\mathcal{B}| = r^m$. $\square$

**Theorem 6.5 (exponential concentration).** *For $r \ge 1$ and $m \ge 2$,*
$$2^{m-1}\,|\mathcal{B}(r,m)| \;<\; r^m, \qquad\text{hence}\qquad
\bigl(2^{m-1}-1\bigr)r^m \;<\; 2^{m-1}|\mathcal{G}(r,m)| .$$
*The failure probability of $m$ samples is $< 2^{-(m-1)}$, uniformly in $r$.*

*Proof sketch.* $\sum_{p\mid r} p^{-m} \le 2^{-(m-2)}\sum_{p \mid r}p^{-2} <
2^{-(m-1)}$, using $p^{-m} \le 2^{-(m-2)}p^{-2}$ for $p \ge 2$. $\square$

### 6.3 The exact count: Jordan's totient

The bounds above are consequences of an exact formula.

**Theorem 6.6 (divisor identity).** *For $n > 0$ and any $m$,*
$$\sum_{d \mid n} |\mathcal{G}(d,m)| \;=\; n^m .$$

*Proof sketch.* Partition $\mathcal{A}(n,m)$ by the value
$e = \gcd(g(K), n) \in \operatorname{div}(n)$. The rescaling
$K \mapsto K/e$ is a bijection from the level set $\{K : \gcd(g(K),n) = e\}$
onto $\mathcal{G}(n/e, m)$: dividing every entry by $e$ divides the record gcd
by $e$, multiplying by $e$ multiplies it back. Summing cardinalities over the
divisors and reindexing $e \mapsto n/e$ gives the identity. $\square$

**Theorem 6.7 (Möbius form).** *For $r > 0$,*
$$|\mathcal{G}(r,m)| \;=\; \sum_{d \mid r} \mu(d)\left(\frac{r}{d}\right)^{m}.$$

*Proof.* Möbius inversion applied to Theorem 6.6. $\square$

**Theorem 6.8 (Euler product / Jordan totient).** *For $r > 0$,*
$$|\mathcal{G}(r,m)| \;=\; r^m \prod_{p \mid r}\left(1 - \frac{1}{p^{m}}\right)
\;=\; J_m(r).$$
*Equivalently, the success probability of a uniformly random length-$m$ record
is exactly $\prod_{p\mid r}(1 - p^{-m})$, and the failure probability is exactly
$1 - \prod_{p\mid r}(1-p^{-m})$.*

*Proof sketch.* In Theorem 6.7 only squarefree divisors contribute, since
$\mu$ vanishes elsewhere; the squarefree divisors of $r$ are the products of
subsets of the prime divisors, and $\mu(\prod_{p\in T} p) = (-1)^{|T|}$. Hence
the sum factors as $r^m \prod_{p \mid r}(1 - p^{-m})$. $\square$

For $m = 1$ this is Euler's $\varphi$ and reproduces the familiar statement that
a single Shor sample succeeds with probability $\varphi(r)/r$. For $m \ge 2$ it
gives the ledger: the failure probability is
$1 - \prod_{p\mid r}(1-p^{-m}) \le \omega(r)2^{-m}$ (Theorem 6.1) and
$< 2^{-(m-1)}$ (Theorem 6.5), the latter uniformly in $r$. It is worth
emphasising that the classical constant $6/\pi^2 \approx 0.6079$ — the density
of coprime pairs — is a *limiting average* over $r$; the uniform-in-$r$ constant
is $1/2$, attained in the limit along $r$ with many small prime factors.

---

## 7. The same threshold in the strictest model

The tolerance model of Definition 2.2 could be criticised as an artifact. We now
re-prove the quadratic threshold in the grid model, where the register reports
only $\lfloor 2^t x\rfloor$.

### 7.1 A Farey count

Let $C(R) = \#\{(a,b) \in [1,R]^2 : \gcd(a,b) = 1\}$.

**Lemma 7.1 (gcd fibration).** *For every $R$,*
$$R^2 \;=\; \sum_{d=1}^{R} C\!\left(\left\lfloor \frac{R}{d}\right\rfloor\right).$$

*Proof.* Every pair in $[1,R]^2$ has a unique gcd $d$; dividing by $d$ is a
bijection onto the coprime pairs in $[1,\lfloor R/d\rfloor]^2$. $\square$

**Lemma 7.2 (tail bound).** $\sum_{d \ge 2} d^{-2} \le 3/4$, and hence
$\sum_{d=2}^{R} \lfloor R/d\rfloor^2 \le \tfrac34 R^2$.

**Theorem 7.3 (a quarter of pairs are coprime).** *For every $R$,
$R^2 \le 4\,C(R)$.*

*Proof.* From Lemma 7.1, $R^2 \le C(R) + \sum_{d\ge2}\lfloor R/d\rfloor^2 \le
C(R) + \tfrac34 R^2$, so $\tfrac14 R^2 \le C(R)$. $\square$

**Corollary 7.4 (many Farey fractions).** *The map $(a,b)\mapsto a/(a+b)$ sends
distinct coprime pairs in $[1,R]^2$ to distinct reduced fractions in $(0,1)$ of
denominator at most $2R$. Hence at least $R^2/4$ such fractions exist.*

### 7.2 The grid threshold

**Lemma 7.5 (the models agree).** *For all $t, r, k$, the dyadic cell of the
order fraction is the truncated outcome:
$\lfloor 2^t \cdot (k/r)\rfloor = \operatorname{out}_t(r,k)$.*

**Theorem 7.6 (grid ambiguity).** *If $4\cdot 2^t < R^2$, there exist distinct
reduced fractions $q_1 \ne q_2$ in $(0,1)$ with denominators at most $2R$ and
$\lfloor 2^t q_1\rfloor = \lfloor 2^t q_2 \rfloor$.*

*Proof.* By Corollary 7.4 there are more than $2^t$ such fractions, and only
$2^t$ cells are available in $(0,1)$; pigeonhole. $\square$

**Theorem 7.7 (grid separation).** *If $R^2 \le 2^t$, then distinct reduced
fractions of denominator at most $R$ always lie in distinct cells.*

*Proof sketch.* Two rationals in the same cell differ by less than $2^{-t} \le
R^{-2}$, contradicting Theorem 3.1. $\square$

**Theorem 7.8 (two-sided grid threshold).** *For all $R, t$: if $R^2 \le 2^t$
the $t$-bit grid register separates all fractions of denominator $\le R$; if
$4\cdot2^t < R^2$ it fails to separate two fractions of denominator $\le 2R$.
The critical number of cells lies between $R^2/4$ and $R^2$, so again
$t_{\min} = 2\log_2 R + O(1)$.*

**Corollary 7.9 (bit form).** *If a $t$-bit grid register separates all reduced
fractions of denominator $\le D$ in $(0,1)$, then $2\log_2 D < t + 6$.*

**Corollary 7.10 (order fractions collide).** *If $4\cdot 2^t < R^2$ then there
are distinct order fractions $k/r \ne k'/r'$ with $r, r' \le 2R$ producing the
same truncated register outcome.*

The threshold is thus not an artifact of the tolerance model: no reasonable
model of truncation weakens the $2\log_2 r$ requirement.

---

## 8. Both axes of the channel are forced

The threshold above is a *depth* bound: each retained frequency must be read to
$2\log_2 r$ bits. It composes with the *width* bound for Fourier sampling: a
scheme whose sampled frequencies determine an arbitrary period-$r$ signal on
$\mathbb{Z}/r\mathbb{Z}$ must query at least $r$ frequencies (otherwise two
distinct signals agree on all sampled frequencies, by dimension count).

**Theorem 8.1 (irreducible channel).** *Consider a Fourier-sampling scheme on
$\mathbb{Z}/r\mathbb{Z}$ with frequency index set of size $K$, whose readings
determine the signal. Then $K \ge r$ (width). Moreover if each outcome is read
to only $t$ bits with $t + 1 \le 2\lfloor\log_2 R\rfloor$, where $R \ge 3$ bounds
the order, the continued-fraction target is undetermined (depth). Neither axis
can be traded for the other.*

**Theorem 8.2 (realised at genuine instances).** *For every $r \ge 3$, the
Mersenne modulus $N = 2^r - 1$ with base $a = 2$ has multiplicative order
exactly $r$. Hence, at every scale, there is an honest order-finding instance to
which the depth bound applies: a register with $t + 1 \le 2\lfloor\log_2
r\rfloor$ bits leaves the target ambiguous, while $t \ge 2\lfloor\log_2
r\rfloor + 2$ determines it.*

The threshold is therefore not an artifact of an abstract model of "orders": all
orders occur.

**Theorem 8.3 (trichotomy).** *Fix $R \ge 3$. Then:*

1. *(Collapse) For all $t$ and all distinct $r, r' \ge 2^t$, no estimator using
   any number of truncated samples is correct for both.*
2. *(Ambiguity) For all $t$ with $t + 1 \le 2\lfloor\log_2 R\rfloor$, there is a
   phase compatible with two distinct fractions of denominator $\le R$.*
3. *(Recovery) For all $t \ge 2\lfloor\log_2 R\rfloor + 2$ and all $0 < r \le R$:
   if the post-processor returns, for each sample $k$ of a record, some fraction
   of denominator $\le R$ compatible with the same observed phase as $k/r$, and
   the numerators are jointly coprime to $r$, then the least common multiple of
   the returned denominators is exactly $r$.*

Statement 3 is the end-to-end guarantee: above the threshold, *honest* continued
fraction post-processing of a good record returns the order exactly, because
uniqueness (Theorem 3.2) forces the returned fraction to be the true reduced
$k/r$, and Theorem 5.3 then assembles the order from the lcm.

---

## 9. Discussion

### 9.1 Consequence for Shor's algorithm

For a random base $a$ modulo a semiprime $N$, the order $r$ is typically of size
comparable to $N$ (it is a divisor of $\lambda(N)$, and the typical divisor is
large). Substituting $r \sim N$ into Theorem 3.7:
$$t_{\min} \;\approx\; 2\log_2 N \;\approx\; \ell = 2\lceil \log_2 N\rceil .$$
The conventional register size is not a comfortable margin; it is the minimum.
**The quantum channel cannot be shrunk by truncation.**

More importantly, the failure mode below the threshold is not "degraded
performance": by Theorem 4.4 the observable records of different orders are
*identical*, so the estimation problem has no solution at all, independently of
sample budget and computational power. Truncation is not a lossy compression of
the quantum advantage; below threshold it destroys it outright.

### 9.2 The shape of the trade

The results assemble into a clean ledger:

| resource | requirement | character |
|---|---|---|
| register depth | $2\log_2 r + O(1)$ bits | rigid; no sample budget substitutes |
| channel width | $\ge r$ frequencies | rigid |
| samples | $m \ge 2$ for success prob. $> 1/2$; $m$ for failure $< 2^{-(m-1)}$; $\log_2\log_2 r + 1$ for guaranteed existence | nearly free |

"Fungibility" holds only in the third row, and only above the threshold, where
it has the exact group-theoretic meaning of Theorem 5.7: samples enlarge the
observed subgroup of $\mathbb{Z}/r\mathbb{Z}$.

### 9.3 Scope and limitations

The lower bounds are information-theoretic and unconditional: they hold for
arbitrary, even non-uniform and computationally unbounded, post-processing, and
they hold for the harshest and the mildest reasonable models of what a truncated
register reports. What they do *not* rule out is a different quantum
subroutine — one that does not produce a phase estimate at all. The statements
here concern order finding by phase estimation plus rational reconstruction: for
that architecture, the register size is forced. They also do not address noisy
or biased phase distributions, where the outcome $k$ is not exactly uniform; the
support-level arguments of Section 4 are insensitive to the distribution, but
the density statements of Section 6 assume uniform numerators.

Finally, the counting in Section 6 assumes numerators drawn uniformly from
$\{0,\dots,r-1\}$, which matches the idealised phase-estimation distribution.
For the true (slightly non-uniform) Shor distribution the same criterion applies
sample by sample; only the exact constants in the density statements change.

### 9.4 Future directions

The salient directions
are: extending the analysis to noisy phase distributions and to partially
truncated registers where low-order bits are measured with error rather than
discarded; quantifying the interaction between the depth threshold and error
correction overheads; sharpening the grid-model constants from the interval
$[R^2/4, R^2]$ to the exact critical cell count; and exploring whether the
divisor ambiguity of Theorem 4.9 has an analogue for hidden-subgroup problems
beyond the cyclic case.

---

## 10. Algorithms

**A. Truncated register simulation.** Given $t, r$ and a numerator $k$, emit
$\lfloor 2^tk/r\rfloor$. Cost $O(1)$ big-integer operations. Used to generate the
records analysed above; by Lemma 7.5 it is exactly the dyadic cell of $k/r$.

**B. Continued-fraction reconstruction.** Given an outcome $m$ at $t$ bits and a
denominator bound $R$, compute the continued-fraction convergents of $m/2^t$ and
return the last convergent with denominator $\le R$. This is the honest
post-processor; by Theorem 3.2 its output is the unique compatible fraction when
$R^2 \le 2^t$. Cost $O(\log R)$ Euclidean steps.

**C. Record assembly.** Given reconstructed denominators $d_1,\dots,d_m$, return
$\operatorname{lcm}(d_1,\dots,d_m)$. By Theorem 5.3 this equals $r$ exactly when
the numerators are jointly coprime to $r$. Cost $O(m\log r)$.

**D. Exact success density.** Given $r$ and $m$, return
$r^m\prod_{p\mid r}(1-p^{-m})$ by factoring $r$ and taking the product over its
prime divisors. Cost: one factorisation plus $O(\omega(r))$ multiplications.
Theorem 6.8 guarantees agreement with brute-force enumeration of good records.

**E. Threshold locator.** Given $r$, return the least $t$ such that a $t$-bit
register separates all reduced fractions of denominator $\le r$: by Theorems 7.7
and 7.8 this is $\lceil 2\log_2 r\rceil$ up to a small additive constant, and can
be located exactly by binary search using a Farey-neighbour collision test.

---

## 11. Conclusion

Truncating Shor's phase register does not trade qubits for samples; it destroys
the algorithm. The exact location of the wall, $t_{\min} = 2\log_2 r + O(1)$, is
dictated by the separation of rationals of bounded denominator, and it holds in
both the tolerance and the dyadic-grid models of truncation, and for genuine
arithmetic instances of every order. Below the wall the observable data of
distinct orders coincide identically, so no sample budget and no post-processing
help. Above it, the residual gcd obstruction is characterised exactly — a record
succeeds iff its residues generate $\mathbb{Z}/r\mathbb{Z}$ — and counted
exactly by Jordan's totient $J_m(r) = r^m\prod_{p\mid r}(1-p^{-m})$, giving a
failure probability below $2^{-(m-1)}$ uniformly in the order. Since $r$ is
typically comparable to $N$, the required register is $\approx 2\log_2 N$ bits:
exactly the register Shor specified, and not one bit fewer.
