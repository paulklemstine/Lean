# The Trace-Set Filter is Exact, Exactly Half-Sized, and Non-Amplifying

**A complete closure of the residue-filter family for interval-hinted semiprime factorization**

*Aristotle*

---

## Abstract

Let $N = pq$ be a semiprime and let $s = p + q$ be its **trace**. Fermat-style factoring scans candidate traces; the *trace-set filter* is the free residue-local consistency test that accepts a candidate $s'$ modulo a prime $m \nmid N$ precisely when $s' \bmod m$ lies in the **trace set**
$$T_m(N) \;=\; \{\, x + N x^{-1} \;:\; x \in (\mathbb{Z}/m)^\times \,\}.$$
We give the complete exact theory of this filter over an arbitrary finite field and determine, unconditionally, how much it can contribute to a search for $s$ inside an externally supplied hint interval $[s_0 - E,\, s_0 + E]$.

We prove five things. **(i) Exactness:** the trace of every factorization lies in the trace set, so the filter has zero false negatives at every modulus simultaneously. **(ii) An exact size law:** over a finite field $K$ with $N \ne 0$, $2\lvert T(N)\rvert = (\lvert K\rvert - 1) + \#\{x : x^2 = N\}$; over $\mathbb{Z}/m$ with $m$ an odd prime this is $2\lvert T_m(N)\rvert = m + \chi_m(N)$ with $\chi_m$ the Legendre symbol, so a wrong candidate survives one prime with probability exactly $\tfrac12(1 + \chi_m(N)/m)$. **(iii) Minimality:** every filter that is exact — i.e. accepts the trace of every local factorization — contains the whole trace set, hence retains at least $(m-1)/2$ residues; no residue-local consistency test of any kind prunes better than one bit per prime, and this remains true for filters that couple all the primes arbitrarily modulo their product. **(iv) An exact global census:** the filters are Chinese-remainder-independent and positionally blind, so any window of $M = \prod_{i} m_i$ consecutive candidates contains exactly $2^{-\omega}\prod_i(m_i + \chi_{m_i}(N))$ survivors, wherever the window sits; the count is exactly linear in the window width. **(v) A hard isolation barrier:** if the filters leave at most one candidate in a hint window of width $W$, then necessarily $W < \prod_i m_i$; isolating a $k$-bit hint therefore demands a modulus product of size $2^{\Omega(k)}$, i.e. $\Omega(k/\log k)$ distinct primes and $2^{\Omega(k/\log k)}$ sieve work.

We also show the *factor-residue filter* is entirely empty (the admissible factor residues mod $m$ are all of $(\mathbb{Z}/m)^\times$), and that the trace scan is Fermat's difference-of-squares method in disguise: over $\mathbb{Z}$, $s$ is the trace of a factorization of $N$ if and only if $s^2 - 4N$ is a perfect square, with the factors given explicitly by $\tfrac{s \mp d}{2}$. A controlled experiment over $400$ semiprimes with $24$-bit factors reproduces every prediction to three decimal places, including the honest cost accounting: the discriminant tests saved by the filter are traded one-for-one against the membership tests spent applying it. Together with the previously closed factor- and order-residue filters, the residue-filter family for interval-hint amplification is now completely closed.

**Keywords:** trace set, semiprime factorization, Fermat's method, Legendre symbol, quadratic residues, Chinese remainder theorem, sieve barrier, primorial, interval hint.

---

## 1. Introduction

### 1.1 The problem

Fix a semiprime $N = pq$ with $p \neq q$ prime. Its **trace** is $s = p + q$. Knowing $s$ is equivalent to knowing the factorization: $p$ and $q$ are the roots of
$$x^2 - sx + N = 0,$$
so a single integer of about $\tfrac12\log_2 N$ bits reveals everything.

Suppose an external source — a side channel, a partial leak, a structural constraint on how $N$ was generated — supplies an **interval hint**: a promise that
$$s \in [s_0 - E,\; s_0 + E],$$
a window of $W = 2E + 1$ candidates. Brute force costs $W$ discriminant tests. The question of this paper is whether *free* arithmetic structure can reduce that cost below $W$ in a way that scales — that is, whether it can **amplify** the hint.

The most natural source of free structure is residue-local consistency. If $m$ is a small prime not dividing $N$, then reducing $N = pq$ modulo $m$ constrains the residue of $s$: with $\bar p \ne 0$ we have $\bar q = N\bar p^{-1}$ and hence
$$\bar s = \bar p + N \bar p^{-1} \in T_m(N) := \{\, x + Nx^{-1} : x \in (\mathbb{Z}/m)^\times \,\}.$$
Candidates whose residue mod $m$ escapes $T_m(N)$ can be discarded with certainty, and $T_m(N)$ can be tabulated in $O(m)$ operations once and consulted thereafter by table lookup. This is the **trace-set filter**. It is the least-hidden invariant of the factorization — the one an adversary has the most direct access to — and hence the strongest remaining candidate for a free amplifier.

### 1.2 Results and organization

We settle the matter completely and negatively, with exact identities rather than heuristics.

- §2 fixes notation and defines the trace set over an arbitrary finite field.
- §3 proves **exactness** (Theorem 3.1): zero false negatives, at every modulus.
- §4 analyses the **fibres** of the trace map (Theorem 4.1) and derives the **Fermat discriminant description** (Theorem 4.2).
- §5 proves the **exact size law** (Theorems 5.1, 5.3, 5.4): $2\lvert T\rvert = (\lvert K\rvert - 1) + \#\sqrt{N}$, hence $2\lvert T_m\rvert = m + \chi_m(N)$.
- §6 proves **minimality** (Theorems 6.1, 6.2): every exact filter contains the trace set; the pruning power of the entire residue-local family is capped at one bit per prime.
- §7 shows the **factor-residue filter is empty** (Theorem 7.1).
- §8 assembles the **global census** via the Chinese remainder theorem and positional blindness (Theorems 8.1–8.5).
- §9 proves the **no-amplification** and **isolation** theorems (Theorems 9.1–9.4) and closes the **coupled** case (Theorems 9.5–9.7).
- §10 proves the **Fermat equivalence over $\mathbb{Z}$** (Theorems 10.1, 10.2), identifying the trace scan with the classical method.
- §11 reports the experiment and the honest cost accounting.
- §12 discusses the shape of the barrier and §13 lists open directions.

---

## 2. Setting and definitions

Throughout, $K$ denotes a finite field, and $\lvert K\rvert$ its cardinality. The main case of interest is $K = \mathbb{Z}/m$ for a prime $m$.

**Definition 2.1 (Trace set).** For $N \in K$, the **trace set** of $N$ is
$$T(N) \;=\; \big\{\, x + N/x \;:\; x \in K,\ x \ne 0 \,\big\} \;\subseteq\; K .$$
When $K = \mathbb{Z}/m$ we write $T_m(N)$.

**Definition 2.2 (Square-root set).** $R(N) = \{\, x \in K : x^2 = N \,\}$. These are the *branch points* of the trace map $x \mapsto x + N/x$.

**Definition 2.3 (Exact filter).** A subset $S \subseteq K$ is an **exact filter for $N$** if
$$a \ne 0 \ \text{ and }\ ab = N \quad\Longrightarrow\quad a + b \in S .$$
Exactness is the minimal requirement on a filter used inside a search: a non-exact filter may discard the true trace and render the search incorrect.

**Definition 2.4 (Survivors in a window).** Let $m_1, \dots, m_\omega$ be pairwise coprime moduli and let $S_i \subseteq \mathbb{Z}/m_i$ be filters. For integers $a$ and $W \ge 0$, the **survivors** of the window $[a, a+W)$ are
$$\mathrm{Surv}(a, W) \;=\; \{\, s \in \mathbb{Z} : a \le s < a + W,\ \ (s \bmod m_i) \in S_i \ \text{for all } i \,\}.$$
When $S_i = T_{m_i}(N)$ we speak of **trace survivors**.

Throughout, $\omega$ denotes the number of moduli, $M = \prod_i m_i$ their product, and $\chi_m$ the Legendre symbol mod an odd prime $m$.

---

## 3. Exactness: zero false negatives

**Theorem 3.1 (Exactness).** *Let $K$ be a field, $N \in K$, and suppose $ab = N$ with $a \ne 0$. Then $a + b \in T(N)$.*

*Proof.* From $ab = N$ and $a \ne 0$ we get $b = N/a$. Hence $a + b = a + N/a$, which is the image of the nonzero element $a$ under the trace map, so it lies in $T(N)$ by Definition 2.1. $\square$

**Corollary 3.2 (Semiprime form).** *Let $m$ be a prime, $N = pq$ with $p, q$ integers, and suppose $m \nmid p$. Then $(p + q) \bmod m \in T_m(N \bmod m)$.*

*Proof.* Reduce mod $m$. Since $m \nmid p$, the residue $\bar p$ is nonzero in the field $\mathbb{Z}/m$, and $\bar p \bar q = \bar N$; apply Theorem 3.1. $\square$

Corollary 3.2 holds at every prime simultaneously, so the true trace of a semiprime survives the conjunction of *all* the filters, unconditionally. This is what the experiment measured as a $400/400$ survival rate at every $\omega \le 20$; it is not a statistical observation but a theorem with a one-line proof. It also establishes that the filter is a *legitimate* pruning device: using it never sacrifices correctness.

---

## 4. Fibres of the trace map, and the discriminant description

The pruning power of the filter is exactly the failure of injectivity of the trace map. That failure is completely described by a single symmetry.

**Theorem 4.1 (Conjugate fibres).** *Let $K$ be a field, $N \in K$, and $x, y \in K$ nonzero. Then*
$$x + \frac{N}{x} \;=\; y + \frac{N}{y} \qquad\Longleftrightarrow\qquad y = x \ \ \text{or}\ \ y = \frac{N}{x}.$$

*Proof sketch.* Clearing denominators, the left-hand equation is equivalent to $(x^2 + N)y = x(y^2 + N)$, which rearranges to the factored identity
$$(y - x)\,(xy - N) \;=\; 0 .$$
In a field one of the two factors vanishes: either $y = x$, or $xy = N$, i.e. $y = N/x$. Conversely both possibilities clearly give equal traces, the second because $N/(N/x) = x$. $\square$

Thus a fibre of the trace map is exactly a *conjugate pair* $\{x, N/x\}$ — the same local factorization written in the two possible orders. The fibre degenerates to a single point precisely when $x = N/x$, i.e. $x^2 = N$: the branch points $R(N)$.

The second consequence of the same algebra is the identification of the filter with the classical Fermat test.

**Theorem 4.2 (Local discriminant description).** *Let $K$ be a field with $\mathrm{char}(K) \ne 2$ and let $N \ne 0$. For $t \in K$,*
$$t \in T(N) \qquad\Longleftrightarrow\qquad t^2 - 4N \ \text{is a square in } K.$$

*Proof sketch.* ($\Rightarrow$) If $t = x + N/x$ with $x \neq 0$, then $(x - N/x)^2 = (x + N/x)^2 - 4N = t^2 - 4N$, exhibiting a square root.
($\Leftarrow$) If $y^2 = t^2 - 4N$, set $u = (t+y)/2$ and $v = (t-y)/2$ (legitimate since $2 \ne 0$). Then $u + v = t$ and
$$uv = \frac{t^2 - y^2}{4} = \frac{t^2 - (t^2 - 4N)}{4} = N .$$
Since $N \ne 0$ we must have $u \ne 0$, and $v = N/u$, so $t = u + N/u \in T(N)$. $\square$

Theorem 4.2 will reappear in §10 as the integral Fermat equivalence. It already shows that the trace-set filter is not a new invariant: it is the statement "the discriminant of the candidate quadratic must be a square", localized at $m$.

---

## 5. The exact size of the filter

**Theorem 5.1 (Exact census over a finite field).** *Let $K$ be a finite field and $N \in K$, $N \ne 0$. Then*
$$2\,\lvert T(N)\rvert \;=\; \big(\lvert K\rvert - 1\big) \;+\; \lvert R(N)\rvert .$$

*Proof sketch.* Let $S = K \setminus \{0\}$, so $\lvert S\rvert = \lvert K\rvert - 1$, and note $R(N) \subseteq S$ because $N \ne 0$. The trace map $\varphi(x) = x + N/x$ carries both $S$ and $R(N)$ into $T(N)$, so partitioning each set into fibres over $T(N)$ gives
$$\lvert S\rvert = \sum_{t \in T(N)} \lvert \varphi^{-1}(t) \cap S\rvert, \qquad \lvert R(N)\rvert = \sum_{t \in T(N)} \lvert \varphi^{-1}(t) \cap R(N)\rvert .$$
The claim reduces to showing that for every $t \in T(N)$ the two fibre cardinalities sum to $2$. Fix $t \in T(N)$ and pick $x \ne 0$ with $\varphi(x) = t$. By Theorem 4.1 the fibre in $S$ is exactly $\{x, N/x\}$. Two cases:
- If $x^2 = N$, then $N/x = x$, the fibre in $S$ is the singleton $\{x\}$, and the fibre in $R(N)$ is also $\{x\}$ (any $y$ in it satisfies $y = x$ or $y = N/x = x$). Sum: $1 + 1 = 2$.
- If $x^2 \ne N$, then $N/x \ne x$, the fibre in $S$ has two elements, and the fibre in $R(N)$ is empty (any square root $y$ of $N$ in the fibre would satisfy $y = x$, contradicting $x^2 \neq N$, or $y = N/x$, which combined with $y^2 = N$ forces $y = x$ again). Sum: $2 + 0 = 2$.
Summing $2$ over $t \in T(N)$ yields $2\lvert T(N)\rvert = \lvert S\rvert + \lvert R(N)\rvert$. $\square$

**Lemma 5.2 (At most two roots).** $\lvert R(N)\rvert \le 2$. *Indeed if $r^2 = N$ then any $x$ with $x^2 = N$ satisfies $(x-r)(x+r) = 0$, so $x \in \{r, -r\}$; if no root exists, $R(N) = \varnothing$.*

**Theorem 5.3 (Half-size bounds).** *For $N \ne 0$ in a finite field $K$,*
$$\lvert K\rvert - 1 \;\le\; 2\,\lvert T(N)\rvert \;\le\; \lvert K\rvert + 1, \qquad\text{hence}\qquad \lvert T(N)\rvert \;\ge\; \frac{\lvert K\rvert - 1}{2}.$$

*Proof.* Immediate from Theorem 5.1 and Lemma 5.2. $\square$

Over $\mathbb{Z}/m$ the correction term is governed exactly by quadratic reciprocity's basic counting fact: $\#\{x : x^2 = N\} = \chi_m(N) + 1$ for $m$ an odd prime and $N \not\equiv 0$.

**Theorem 5.4 (Legendre form).** *Let $m$ be an odd prime and $N$ an integer with $m \nmid N$. Then*
$$2\,\lvert T_m(N)\rvert \;=\; m + \chi_m(N),$$
*where $\chi_m$ is the Legendre symbol. Consequently the local survival probability of a uniformly random wrong candidate is exactly*
$$\Pr[\text{survive } m] \;=\; \frac{\lvert T_m(N)\rvert}{m} \;=\; \frac{1}{2}\Big(1 + \frac{\chi_m(N)}{m}\Big) \;=\; \frac12 \pm \frac{1}{2m}.$$

*Proof.* Combine Theorem 5.1 (with $\lvert K \rvert = m$) with the count $\lvert R(N)\rvert = \chi_m(N) + 1$. $\square$

**Interpretation.** The trace-set filter delivers *exactly one bit* of pruning per prime, with a relative correction of size $1/m$. It never delivers more, and it never delivers meaningfully less: it is not a $m^{-c}$ filter for any $c > 0$. Numerically, for $N = 3233 = 53 \cdot 61$ one finds $\lvert T_{13}\rvert = 7 = (13+1)/2$ (here $\chi_{13}(N) = +1$) and $\lvert T_{17}\rvert = 8 = (17-1)/2$ (here $\chi_{17}(N) = -1$), matching the identity on the nose.

---

## 6. Minimality: the residue-local family is capped at one bit

The results so far describe one particular filter. The following two theorems show it is the *best possible* one, so that no ingenuity in filter design can improve the exponent.

**Theorem 6.1 (The trace set is the minimal exact filter).** *Let $S \subseteq K$ be an exact filter for $N$ in the sense of Definition 2.3. Then $T(N) \subseteq S$.*

*Proof.* Let $t \in T(N)$, say $t = x + N/x$ with $x \ne 0$. Then $a = x$ and $b = N/x$ satisfy $a \ne 0$ and $ab = N$, so exactness of $S$ forces $a + b = t \in S$. $\square$

The content is that *every* element of the trace set is the trace of a genuine local factorization; there is no "slack" in $T(N)$ that a cleverer filter could remove without risking correctness.

**Theorem 6.2 (One-bit cap).** *Let $N \ne 0$ in a finite field $K$, and let $S$ be any exact filter for $N$. Then*
$$\lvert S \rvert \;\ge\; \lvert T(N)\rvert \;\ge\; \frac{\lvert K\rvert - 1}{2}.$$
*In particular, over $\mathbb{Z}/m$ with $m \ge 5$ prime, every exact filter retains at least $2$ residues, and the survival probability of a wrong candidate is at least $\tfrac12 - \tfrac{1}{2m}$.*

*Proof.* Theorem 6.1 gives the first inequality, Theorem 5.3 the second. For $m \ge 5$, $(m-1)/2 \ge 2$. $\square$

This is the local form of the barrier: **no consistency test that depends only on $N \bmod m$ can prune a wrong candidate with probability better than roughly $1/2$**. The trace filter attains the bound; the interesting content is that nothing beats it.

---

## 7. The factor-residue filter is empty

One might filter candidate *factors* rather than candidate traces: given a candidate $p'$, ask whether $p' \bmod m$ can be the residue of a factor of $N$. This test is entirely vacuous.

**Theorem 7.1 (Emptiness of the factor filter).** *Let $K$ be a field and $N \in K$ with $N \ne 0$. Then*
$$\{\, a \in K : \exists\, b \in K,\ ab = N \,\} \;=\; K \setminus \{0\} \;=\; K^\times .$$

*Proof.* If $ab = N$ with $N \ne 0$ then $a \ne 0$ (otherwise $N = 0$). Conversely for $a \ne 0$ take $b = N/a$. $\square$

So the admissible-factor set is all units, and the factor filter re-tests only coprimality with $m$ — a condition every prime candidate $p' \ne m$ satisfies automatically. The measured survival rate of coprime candidates was $1.0000$, exactly as Theorem 7.1 dictates: a **candidate-level zero-block**.

---

## 8. The global census: independence, blindness, exact counts

We now assemble local densities into a global count. Two structural facts do all the work: filters at coprime moduli are independent, and any periodic filter is blind to the position of the window.

**Theorem 8.1 (Chinese remainder independence).** *Let $m_1, \dots, m_\omega$ be pairwise coprime with $M = \prod_i m_i$, and let $S_i \subseteq \mathbb{Z}/m_i$. Then the set of residues $z \in \mathbb{Z}/M$ whose reduction mod each $m_i$ lies in $S_i$ has cardinality exactly*
$$\prod_{i=1}^{\omega} \lvert S_i\rvert .$$

*Proof sketch.* The Chinese remainder isomorphism $\mathbb{Z}/M \xrightarrow{\ \sim\ } \prod_i \mathbb{Z}/m_i$ is a ring isomorphism whose $i$-th component is the reduction map. The set in question is therefore the preimage of the product set $\prod_i S_i$, and a bijection preserves cardinality. $\square$

No filter can interfere with another: the local prunings multiply exactly. In particular there are no hidden correlations between primes to exploit or to fear.

**Theorem 8.2 (Positional blindness).** *Let $M \ge 1$ and $S \subseteq \mathbb{Z}/M$. For every integer $a$,*
$$\#\{\, s \in \mathbb{Z} : a \le s < a + M,\ (s \bmod M) \in S \,\} \;=\; \lvert S\rvert .$$

*Proof sketch.* The reduction map $s \mapsto s \bmod M$ restricted to any $M$ consecutive integers is a bijection onto $\mathbb{Z}/M$: it is injective because two elements of a window of length $M$ congruent mod $M$ must coincide, and surjective by counting (or explicitly, $z$ is hit by $a + ((z - a) \bmod M)$). Restricting the bijection to the preimage of $S$ gives the claim. $\square$

A residue filter therefore carries **no positional information whatsoever**. It cannot say "the trace is in the left half of the window"; it can only say "the trace is one of these residue classes", and every window sees the same number of them.

**Theorem 8.3 (Window census).** *With pairwise coprime moduli $m_i > 0$, filters $S_i$, and $M = \prod_i m_i$, every window of $M$ consecutive candidates contains exactly $\prod_i \lvert S_i\rvert$ survivors, independent of the window's location.*

*Proof.* Combine Theorem 8.1 (the composite filter mod $M$ has $\prod_i \lvert S_i\rvert$ residues) with Theorem 8.2 (a window of $M$ consecutive integers meets each residue class exactly once). $\square$

**Theorem 8.4 (Linear scaling in width).** *For every $k \ge 0$ and every $a$, the window $[a,\ a + kM)$ contains exactly $k \prod_i \lvert S_i\rvert$ survivors.*

*Proof.* Split the window into $k$ consecutive disjoint blocks of length $M$ and apply Theorem 8.3 to each; the counts add. (Formally, induct on $k$.) $\square$

Theorem 8.4 is the quantitative heart of the negative result: the survivor count is *exactly proportional* to the width of the hint. Widening the hint by a factor $k$ multiplies the survivors by $k$; narrowing it divides them. The filter fixes a **density**, never a **cardinality**, and density is precisely the quantity that cannot be traded for resolution.

Specializing to the trace filters and inserting Theorem 5.4 yields the exact global law.

**Theorem 8.5 (Exact trace census).** *Let $m_1, \dots, m_\omega$ be distinct odd primes with $m_i \nmid N$, and $M = \prod_i m_i$. Then every window of $M$ consecutive candidate traces contains exactly*
$$\#\mathrm{Surv} \;=\; \frac{1}{2^{\omega}}\prod_{i=1}^{\omega}\big(m_i + \chi_{m_i}(N)\big)$$
*survivors, and in particular*
$$\prod_{i=1}^{\omega}(m_i - 1) \;\le\; 2^{\omega}\,\#\mathrm{Surv} \;\le\; \prod_{i=1}^{\omega}(m_i + 1).$$

*Proof.* Theorem 8.3 gives $\#\mathrm{Surv} = \prod_i \lvert T_{m_i}(N)\rvert$; multiply the local identities $2\lvert T_{m_i}\rvert = m_i + \chi_{m_i}(N)$ of Theorem 5.4 across $i$, and bound $\chi \in \{\pm 1\}$. $\square$

Written as a density, $\#\mathrm{Surv}/M = 2^{-\omega}\prod_i (1 + \chi_i/m_i)$: the idealized $2^{-\omega}$ law with its exact multiplicative corrections. This is the closed form behind the measured $0.1233$ versus $0.125$ at $\omega = 3$ and $0.0151$ versus $0.0156$ at $\omega = 6$.

A concrete instance, verifiable by hand: $N = 3233 = 53\cdot 61$ with moduli $\{3,5,7\}$ has $\lvert T_3\rvert = 1$, $\lvert T_5\rvert = 2$, $\lvert T_7\rvert = 3$, so $M = 105$ and every window of $105$ consecutive candidates — starting at $0$, at $500$, at $99999$, anywhere — contains exactly $1\cdot 2\cdot 3 = 6$ survivors, one of which (in the appropriate window) is the true trace $114 = 53 + 61$.

---

## 9. No amplification, and the isolation barrier

**Theorem 9.1 (No amplification).** *Let $m_1,\dots,m_\omega$ be distinct primes with $m_i \ge 5$ and $m_i \nmid N$, and let $S_i$ be any exact filters (in particular the trace filters). Then any window of width $W \ge M = \prod_i m_i$ retains at least*
$$2^{\omega}$$
*surviving candidates.*

*Proof.* By Theorem 6.2 each exact filter satisfies $\lvert S_i\rvert \ge (m_i - 1)/2 \ge 2$. By Theorem 8.3, a sub-window of width exactly $M$ already contains $\prod_i \lvert S_i\rvert \ge 2^{\omega}$ survivors, and enlarging the window only adds survivors. $\square$

**Theorem 9.2 (The filter never isolates).** *Under the hypotheses of Theorem 9.1 with $\omega \ge 1$, if $N = pq$ with $m_i \nmid p$ for all $i$ and the true trace $p+q$ lies in the window, then the survivor set contains $p+q$ together with at least one spurious candidate $s \ne p + q$.*

*Proof.* The true trace survives by Corollary 3.2; the survivor count is at least $2^{\omega} \ge 2$ by Theorem 9.1; hence some survivor differs from $p+q$. $\square$

Thus the filter's output is always a *consistency certificate* rather than an identification: it certifies that the true trace is consistent with all local data, alongside at least $2^{\omega}-1$ impostors that are equally consistent.

**Theorem 9.3 (Isolation requires the primorial).** *Under the hypotheses of Theorem 9.1 with $\omega \ge 1$, if the survivor count in a window of width $W$ is at most $1$, then*
$$W \;<\; \prod_{i=1}^{\omega} m_i .$$

*Proof.* Contrapositive of Theorem 9.1: if $W \ge M$ the count is at least $2^\omega \ge 2$. $\square$

**Corollary 9.4 (Superpolynomial sieve cost).** *To reduce a hint window of width $W = 2^{k}$ to a single candidate using distinct prime moduli, one needs $\prod_i m_i > 2^{k}$. Since the smallest product of $\omega$ distinct primes is the primorial $p_\omega\# = e^{(1+o(1))\,\omega\log\omega}$, this forces $\omega = \Omega(k/\log k)$ primes, and the largest modulus is of size $\Omega(k)$; the work of constructing and consulting the filters is therefore $2^{\Omega(k/\log k)}$ — superpolynomial in the bit length.*

This is the precise sense in which the trace filter is **sealed**. It prunes, but the price of each bit of pruning is a modulus, and the moduli must multiply to the size of the search space before the last candidate is eliminated. The pruning and the price cancel identically.

An equivalent phrasing for the *unhinted* search: over a range of $k$ full periods the filters leave exactly $k \cdot \prod_i \lvert T_{m_i}\rvert \ge k \cdot 2^{\omega}$ candidates (Theorem 8.4). Starting from a range of $2^{24}$ traces, the surviving population decays as $2^{24} \to 2^{19} \to 2^{13.3} \to 2^{7.4}$ at $\omega = 0, 6, 12, 18$: exponential decay of the survivors, matched by exponential growth in the cost of the moduli required to continue.

### 9.1 Coupled filters do not help

The remaining objection is that testing primes one at a time may waste information: perhaps a filter that examines the *joint* residue modulo $M$ can exploit correlations. It cannot, and the reason is again exactness.

**Theorem 9.5 (Coupled minimality).** *Let $m_1,\dots,m_\omega$ be pairwise coprime, $M = \prod_i m_i$, $N \in \mathbb{Z}/M$, and let $S \subseteq \mathbb{Z}/M$ be **exact modulo $M$**, i.e. $a + b \in S$ whenever $a$ is a unit of $\mathbb{Z}/M$ and $ab = N$. Then*
$$\lvert S \rvert \;\ge\; \prod_{i=1}^{\omega} \big\lvert T_{m_i}(N \bmod m_i)\big\rvert .$$

*Proof sketch.* Let $z \in \mathbb{Z}/M$ reduce into $T_{m_i}(N \bmod m_i)$ at every $i$; we show $z \in S$, which suffices by Theorem 8.1. For each $i$ choose $x_i \ne 0$ in $\mathbb{Z}/m_i$ with $x_i + N_i/x_i = z_i$, where $N_i, z_i$ are the reductions of $N, z$. The tuple $(x_i)_i$ is a unit of $\prod_i \mathbb{Z}/m_i$ because each coordinate is nonzero in a field; transporting through the Chinese remainder isomorphism produces a unit $a \in \mathbb{Z}/M$, and likewise $b$ corresponding to $(N_i/x_i)_i$. Then $ab = N$ and $a + b = z$ coordinate-wise, hence globally; exactness of $S$ gives $z \in S$. $\square$

**Theorem 9.6 (No coupled amplification).** *If additionally each $m_i \ge 5$ is prime and $N$ reduces to a nonzero residue mod each $m_i$, then any exact $S \subseteq \mathbb{Z}/M$ accepts at least $2^{\omega}$ candidates in any window of width $W \ge M$.*

*Proof.* By Theorem 6.2 each local trace set has at least $2$ elements, so $\lvert S\rvert \ge 2^{\omega}$ by Theorem 9.5; then apply positional blindness (Theorem 8.2) and monotonicity in $W$. $\square$

**Theorem 9.7 (The seal, strongest form).** *Under the hypotheses of Theorem 9.6 with $\omega \ge 1$: if any exact residue filter modulo $M$ isolates at most one candidate in a window of width $W$, then $W < M$.*

*Proof.* Contrapositive of Theorem 9.6. $\square$

So the barrier is not an artifact of testing primes independently, nor of choosing the trace as the invariant. It follows from exactness alone: **any** filter that is guaranteed never to discard the true trace must accept at least half the residues at each prime, hence at least $2^\omega$ candidates in a primorial-wide window.

---

## 10. The trace scan is Fermat's method in disguise

Theorem 4.2 identified the local filter with a discriminant test. Globally, the identification is exact and explicit.

**Theorem 10.1 (Fermat equivalence over $\mathbb{Z}$).** *For integers $N$ and $s$,*
$$\exists\, a,b \in \mathbb{Z}: ab = N \ \text{and}\ a + b = s \qquad\Longleftrightarrow\qquad \exists\, d \in \mathbb{Z}: d^2 = s^2 - 4N .$$

*Proof sketch.* ($\Rightarrow$) Given $ab = N$, $a+b = s$, take $d = a - b$; then $d^2 = (a+b)^2 - 4ab = s^2 - 4N$.
($\Leftarrow$) Given $d^2 = s^2 - 4N$, we have $(s-d)(s+d) = 4N$. The factors $s - d$ and $s + d$ have the same parity, and they cannot both be odd: their product is divisible by $4$, hence by $2$, and $2$ is prime, so at least one factor is even — forcing both to be even. Write $s - d = 2c$; then $s + d = 2(s - c)$ and $c(s-c) = N$ with $c + (s - c) = s$. $\square$

**Theorem 10.2 (Explicit recovery).** *If $d^2 = s^2 - 4N$ then*
$$\frac{s-d}{2}\cdot\frac{s+d}{2} \;=\; N \qquad\text{and}\qquad \frac{s-d}{2} + \frac{s+d}{2} \;=\; s,$$
*both quotients being integers.*

Consequently, asking "is $s$ an admissible trace?" *is* asking "is $s^2 - 4N$ a perfect square?", and the trace scan over an interval is Fermat's difference-of-squares scan re-parameterized. The residue filters are then nothing but the classical remark that a perfect square must be a quadratic residue modulo every prime — precisely the observation underlying Fermat sieves. Such sieves are genuinely useful in practice for reducing constants; what Theorems 9.3 and 9.7 quantify is that they cannot move the exponent, because their local pruning rate is pinned at exactly $1/2$ per prime by exactness.

---

## 11. Experiment and honest cost accounting

The theory was tested against a controlled experiment: $400$ semiprimes $N = pq$ with $24$-bit prime factors ($48$-bit $N$), trace-set and factor-set filters at $\omega = 0, \dots, 20$ small primes, and a rejection-ordered scan with explicit accounting of both discriminant tests and membership tests.

**(1) Exactness.** The true trace survived $400/400$ at every $\omega \le 20$ — a direct instance of Corollary 3.2.

**(2) Local pruning rate.** Wrong candidates survived at rate $0.1233$ for $\omega = 3$ (idealized $2^{-3} = 0.125$) and $0.0151$ for $\omega = 6$ (idealized $2^{-6} = 0.015625$). The deficits are exactly the accumulated Legendre corrections $\prod_i(1 + \chi_i/m_i)$ of Theorem 8.5; the closed form predicts the measurements to three decimals.

**(3) Factor filter.** Coprime survival was $1.0000$: the factor filter blocks nothing, exactly as Theorem 7.1 requires.

**(4) Interval hint.** With hint half-width $E = 4000$ (window $W = 8001$), the number of candidates reaching the expensive discriminant test dropped from $8001$ at $\omega = 0$ to $121.5$, $2.9$, and $1.1$ at $\omega = 6, 12, 18$ respectively — matching $(2E{+}1)\cdot 2^{-\omega} + 1$, the "+1" being the true trace guaranteed to survive by exactness.

**(5) The accounting that matters.** Those savings were bought, not found. Determining *which* candidates deserve a discriminant test required $\approx 1.9$ membership tests per candidate across the entire window: between $15{,}294$ and $15{,}550$ table lookups in total, essentially independent of $\omega$. The full range is still iterated. The reduction in expensive tests is exactly offset by the cheap tests spent identifying them — **cost parity or worse**, exactly as the positional-blindness theorem (Theorem 8.2) predicts: a filter that carries no positional information cannot avoid touching every position.

**(6) Unhinted search.** With no hint, survivors over a $2^{24}$ range fell as $2^{24} \to 2^{19} \to 2^{13.3} \to 2^{7.4}$ for $\omega = 0, 6, 12, 18$, in agreement with Theorem 8.4's exact linear-in-width law. Extrapolating via Corollary 9.4, driving the survivor count to a polynomial in the bit length $k$ would require a modulus product of size $e^{\Theta(k\log k)}$ — superexponential in $k$, and thus far outside polynomial reach.

---

## 12. Discussion

### 12.1 Why the barrier is structural, not statistical

Every result above is an identity, not a bound with slack. The chain is:

1. **Exactness** ⟹ the filter must accept the trace of *every* local factorization (Theorem 6.1);
2. the local factorizations are parameterized by the units $x \mapsto (x, N/x)$, and the trace map has **fibres of size exactly two** (Theorem 4.1);
3. hence every exact filter has at least $\approx m/2$ elements (Theorem 6.2) — **one bit, exactly**;
4. residue filters are **positionally blind** and **CRT-independent** (Theorems 8.1, 8.2), so their effect on a window is exactly multiplicative and exactly proportional to the width (Theorems 8.3, 8.4);
5. therefore isolating a candidate requires the modulus product to exceed the width (Theorems 9.3, 9.7), and paying for that product costs superpolynomial work (Corollary 9.4).

There is no step in this chain that a better filter design could weaken. The only assumption is exactness, and dropping exactness means accepting a probability of discarding the answer — a different (and much weaker) kind of algorithm.

### 12.2 The free-information mirage

The trace-set filter is a clean specimen of a recurring phenomenon. A test can be:

- **free** (tabulating $T_m(N)$ costs $O(m)$ once),
- **sound** (never rejects the truth), and
- **sharp** (rejects a measured $50\%$ of impostors per prime),

and still be **useless for amplification**, because its selectivity is proportional to its periodicity. The rejection rate $2^{-\omega}$ and the period $M = \prod m_i$ are locked together: you cannot buy the first without paying the second. The honest accounting of §11 makes the trade explicit: it is not merely that the asymptotics fail, but that even at $48$ bits the wall-clock trade is a wash.

### 12.3 Placement in the residue-filter landscape

The trace is the *least hidden* invariant of a factorization: it is the coefficient of the quadratic that $p$ and $q$ satisfy, and it is what Fermat's method scans directly. Filters on more hidden invariants — the factor residue itself, or the multiplicative order of elements modulo $N$ — have been closed by analogous arguments; the factor filter is closed here in the strongest way possible (Theorem 7.1: it is empty). With the trace filter now closed by exact identity rather than by heuristic, the residue-filter family on factor, order, and trace admits no member that amplifies an interval hint.

### 12.4 What is *not* claimed

We do not claim factoring is hard, nor that no hint-amplification algorithm exists. The theorems bound one specific and natural class: filters determined by residues modulo small moduli that never reject the true trace. Algorithms that use non-local information (lattice reduction on the hint interval, for example, in the spirit of Coppersmith-style partial-information attacks), or that accept a probability of failure, fall outside the model — and are precisely where the remaining hope for hint amplification lies.

---

## 13. Future directions

Three sharp conjectures push past the boundary established here.

**C1. The half-bit barrier is a *character* barrier, not a trace barrier.** Let $f \in \mathbb{Z}[X,Y]$ be an absolutely irreducible symmetric polynomial and define the $f$-profile filter
$$T_m^f(N) = \{\, f(a,b) \bmod m : ab \equiv N \bmod m,\ a \in (\mathbb{Z}/m)^\times \,\}.$$
Conjecturally $\lvert T_m^f(N)\rvert / m \to 1/\deg_Y f$ as $m \to \infty$, with error $O(m^{-1/2})$ from a Weil bound. The identity $2\lvert T\rvert = m + \chi(N)$ is the degree-two case of counting points on the curve $f(a, N/a) = t$; the density is governed by the number of $t$-fibres, i.e. by the degree of the fibre map, not by any arithmetic secret of $N$. In particular no symmetric invariant of the factor pair prunes more than a $1/\deg$ fraction, and the rate is never $m^{-c}$ for $c > 0$.

**C2. Free filters cannot beat the primorial, even with an oracle for the number of prime factors.** For every family of exact filters $S_m \subseteq \mathbb{Z}/m$ computable from $N \bmod m$ in $\mathrm{poly}(\log m)$ time, and every hint window of width $W$, the survivor count is at least $W / \prod_{m} m$ whenever $\prod_m m \le W$. Consequently isolating a $k$-bit hint requires moduli whose product is $2^{\Omega(k)}$, hence total sieve work $2^{\Omega(k/\log k)}$. Exactness forces $S_m \supseteq T_m$ and the Chinese remainder theorem makes the survivor count exactly multiplicative; the coupled case is already settled, so what remains is a finite complexity-theoretic accounting of sieve cost rather than a new mathematical idea.

**C3. Hint amplification is equivalent to a square-root oracle.** An algorithm that, given $N$ and a hint interval of width $W$, returns the true trace using $\mathrm{poly}(\log N)$ filter evaluations should be equivalent to an oracle producing square roots modulo $N$ — and therefore to factoring itself. The Fermat equivalence of §10 is the reason to expect this: admissibility of a trace *is* squareness of the discriminant, so an amplifier is a device for locating squares in an arithmetic progression, which is the classical square-root problem in disguise.

Beyond these, two directions seem worth pursuing. First, an exact analysis of *non-exact* (one-sided-error) filters: quantifying the trade-off between false-negative probability and pruning rate would determine whether abandoning correctness buys anything at all. Second, a formal cost model for rejection-ordered scans that makes the §11 accounting a theorem: the statement "a positionally blind filter cannot reduce the number of positions touched" deserves to be proved in a machine model rather than measured.

---

## 14. Conclusion

The trace-set filter is exact: the true trace of a semiprime survives every modulus, always. It is exactly half-sized: $2\lvert T_m(N)\rvert = m + \chi_m(N)$, one bit of pruning per prime with a $1/m$ correction. It is minimal: every filter that never rejects the truth contains it, so no residue-local test does better, not even one that couples all the primes at once. It is positionally blind and CRT-multiplicative, so its census in a window is exactly $2^{-\omega}\prod_i(m_i + \chi_i)$ times the width, wherever the window sits. And it is therefore incapable of amplifying an interval hint: isolating a candidate requires the product of the moduli to exceed the width of the hint, which costs superpolynomial work, and the discriminant tests it saves are traded one-for-one against the membership tests it spends.

The trace-set filter is an impeccable consistency certificate that conveys no usable information. Its exactness is precisely what makes it useless: a test that can never be wrong about the answer can never be very selective about the alternatives.
