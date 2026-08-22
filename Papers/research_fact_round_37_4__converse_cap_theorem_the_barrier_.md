# The Universal Cap $4/3$ for Residue-Dial Speedups

### An exact single-pass law, its converse for the congruence stratum, and the accounting boundary at $2$

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

We study the maximal speedup that congruence information can confer on a single-pass scanning search — the setting in which a factoring or divisor-search algorithm is told, for free, whether the residue class of its target modulo $M$ lies in a prescribed set $K$. We prove an *exact* law: if $\theta = |K|/\varphi(M)$ is the density of the filter, the expected cost of the dial-aware scan, normalised by the unfiltered baseline, is exactly $1 - \theta + \theta^{2}$, so that

$$\mathrm{Speedup}(\theta) = \frac{1}{1-\theta+\theta^{2}}.$$

Completing the square yields the **universal cap** $\mathrm{Speedup} \le 4/3$, with equality if and only if $\theta = 1/2$; trivial filters give exactly $1$. The law depends on $K$ only through $|K|$, from which we deduce a family of converse statements: no character-theoretic, symbol-theoretic, positional, or interval structure can beat a plain half-density set (structure blindness); reading a dial against either factor of a semiprime gives *identically* the same speedup (which-factor blindness, an identity rather than an approximation); and composing dials on coprime moduli via the Chinese Remainder Theorem multiplies densities and therefore inherits the same cap. The last point separates two currencies: the *capacity* $\log_2(1/\theta)$ of a battery is unbounded, whereas the *work* $\log_2 \mathrm{Speedup}$ it purchases is at most $\log_2(4/3) = 0.41504\ldots$ bits and tends to $0$ as capacity grows.

We then locate, precisely, the discrepancy between our constant $4/3$ and the barrier $2$ that the literature asks about. Under *expected-position* accounting — charging the algorithm the index at which the target is found, with free reordering inside each branch of the dial reading — we prove an optimality lemma for arbitrary schedules and deduce a strict barrier of $2$, approached but never attained. Under a multi-symbol generalisation we prove the order-free identity $2\sum_i \theta_i(\theta_1+\cdots+\theta_i) = (\sum_i \theta_i)^2 + \sum_i \theta_i^2$ and the cap hierarchy $2r/(r+1)$, again strictly below $2$ and converging to it. Finally we identify the exact boundary of the theorem: if the dial's answer permits the algorithm to *skip* rejected blocks, the cost becomes $\sum_i \theta_i^2$ and a balanced $r$-symbol reveal buys exactly $r$, so no universal cap survives. The constant $4/3$ is therefore a theorem about single-pass scan-order algorithms, and the difference between it and $r$ is exactly the difference between reordering work and eliding it.

**Keywords:** residue dial, congruence filter, scan-order algorithm, speedup cap, Chinese Remainder Theorem, power-residue characters, information-versus-work separation.

---

## 1. Introduction

### 1.1 The question

Consider the most naive divisor search imaginable. To factor $N$ one enumerates candidate divisors and tests each. The enumeration proceeds through a finite set of *classes* — for our purposes, the reduced residue classes modulo some auxiliary modulus $M$ — and the algorithm's cost is the number of classes it must examine before reaching the one containing the target.

Number theory offers an abundance of congruence restrictions on the divisors of $N$. If $N \equiv c \pmod M$, the classes of $p$ and $q$ in $N = pq$ are constrained; quadratic reciprocity restricts the prime divisors of values of quadratic forms; higher power-residue symbols restrict divisors in the corresponding cyclotomic settings. Each such restriction supplies a subset $K$ of the class space with the promise that the target's class does or does not lie in $K$.

We call the pair (a subset $K$, plus the promise) a **residue dial**, and we ask the natural question: *how much can such a dial accelerate the scan?*

Folklore, and a body of empirical work, records a barrier near $2$ — a residue dial never buys a factor-two speedup. The empirical curves, however, do not saturate at $2$; they saturate visibly lower. The purpose of this paper is to replace the empirical curve by an exact law, to prove the converse (an upper bound valid for *every* dial in the congruence stratum, not merely for the ones that were tried), and to explain in full where the number $2$ comes from and why the provable constant is $4/3$.

### 1.2 Results

Our contributions are:

1. **An exact law** (§3). For any filter in any finite class space with a uniform target, the normalised expected cost of the dial-aware single-pass scan is exactly $1 - \theta + \theta^2$.
2. **The universal cap** (§3.3). $\mathrm{Speedup} \le 4/3$, with an exact equality characterisation at $\theta = 1/2$, a full description of the monotonicity of the curve, and attainment for genuine residue dials whenever $\varphi(M)$ is even.
3. **Structure blindness and its corollaries** (§4). The law sees only $|K|$. Hence symbol dials built from characters of any order, positional dials, and interval dials all obey the same cap; and which-factor blindness for semiprimes becomes an identity via the involution $u \mapsto cu^{-1}$.
4. **Batteries and the bit-currency separation** (§5). CRT composition multiplies densities; the cap survives; capacity bits are unbounded while work bits are capped by $\log_2(4/3) < 1$ and tend to $0$.
5. **The accounting analysis** (§6). An optimality lemma for arbitrary dial-aware schedules, the expected-position formula $(k+j)(k+j+1)/(k(k+1)+j(j+1))$, and the strict barrier $2$ with sharpness at balanced blocks.
6. **The multi-symbol hierarchy and the boundary** (§7). The order-free identity, the caps $2r/(r+1)$, and the failure of any cap once skipping is permitted.

### 1.3 Notation

Throughout, $\alpha$ denotes a finite class space with $n = |\alpha| > 0$ elements; $K \subseteq \alpha$ is a filter with $k = |K|$; $\theta = k/n \in [0,1]$ is its density. For a modulus $M \ge 1$ we write $(\mathbb{Z}/M)^\times$ for the unit group, of order $\varphi(M)$, and take $\alpha = (\mathbb{Z}/M)^\times$ for genuine residue dials. Logarithms $\log_2$ are to base two. All expectations are over a target class drawn uniformly from $\alpha$.

---

## 2. The model

### 2.1 Definition of the scan

**Definition 2.1 (Class space and target).** A *class space* is a nonempty finite set $\alpha$. The *target* $t \in \alpha$ is a uniform random element.

**Definition 2.2 (Residue dial).** A *dial* on $\alpha$ is a subset $K \subseteq \alpha$. Its *reading* on target $t$ is the bit $[t \in K]$. Its *density* is $\theta = |K|/|\alpha|$.

**Definition 2.3 (Single-pass dial-aware scan).** A *single-pass scan* examines classes one at a time and pays one unit per class examined; a class once scheduled is paid for. The dial-aware scan uses the reading to reorder: it schedules the $k$ classes of $K$ first; if the target is among them it terminates having paid the whole first phase, and otherwise it falls back on the full scan of all $n$ classes. Its cost is therefore

$$\mathrm{cost}_K(t) \;=\; \begin{cases} k, & t \in K,\\ n, & t \notin K.\end{cases}$$

Two features of Definition 2.3 deserve comment, because the constant $4/3$ is entirely a consequence of them.

*Worst-case in phase.* A phase that scans $m$ classes is charged $m$, not the position within the phase at which the target happened to sit. This is the accounting appropriate to a scan whose per-class work is not separable — a batched sieve, a vectorised trial-division pass, a wheel — where the phase is the atomic unit of work. §6 treats the alternative.

*No skipping.* The dial reorders but does not eliminate. If the reading is negative, the algorithm has learned that the target is in the complement, but in this model it cannot jump directly to the complement without paying for the classes it has already scheduled. §7.4 treats the alternative, where the cap disappears.

**Definition 2.4 (Expected cost and speedup).**
$$\mathrm{EC}(K) \;=\; \frac{1}{n}\sum_{t \in \alpha} \mathrm{cost}_K(t), \qquad \mathrm{Speedup} \;=\; \frac{n}{\mathrm{EC}(K)},$$
the baseline being the unfiltered scan of cost $n$.

### 2.2 The cost function

**Definition 2.5 (Dial cost).** For $\theta \in \mathbb{R}$ set
$$D(\theta) \;=\; 1 - \theta + \theta^{2}, \qquad S(\theta) \;=\; \frac{1}{D(\theta)}.$$

We record for later use that $D$ is defined and positive on all of $\mathbb{R}$, so $S$ is a globally defined smooth function; no domain restriction to $[0,1]$ is needed for the analytic statements, though densities of course lie in $[0,1]$.

---

## 3. The exact law and the universal cap

### 3.1 Claim A: the law

**Theorem 3.1 (Exact single-pass law).** *Let $\alpha$ be a class space with $n > 0$ elements and let $K \subseteq \alpha$ with $|K| = k$ and $\theta = k/n$. Then*
$$\mathrm{EC}(K) \;=\; n\,D(\theta) \;=\; n\bigl(1 - \theta + \theta^{2}\bigr), \qquad \frac{\mathrm{EC}(K)}{n} = D(\theta), \qquad \frac{n}{\mathrm{EC}(K)} = S(\theta).$$

*Proof.* Split the sum defining $\mathrm{EC}$ over the indicator of membership in $K$. Writing $\mathbf{1}_K(t)$ for the indicator,
$$\mathrm{cost}_K(t) = k\,\mathbf{1}_K(t) + n\,(1 - \mathbf{1}_K(t)),$$
and $\sum_t \mathbf{1}_K(t) = k$, $\sum_t (1-\mathbf{1}_K(t)) = n-k$. Hence
$$\sum_t \mathrm{cost}_K(t) = k\cdot k + (n-k)\cdot n = k^2 + n^2 - kn.$$
Dividing by $n$ and substituting $k = \theta n$ gives $\mathrm{EC}(K) = \theta^2 n + n - \theta n = n(1-\theta+\theta^2)$. Since $D(\theta) > 0$ (Lemma 3.2), the reciprocal statement follows. $\square$

The proof uses nothing about $\alpha$ beyond finiteness and nothing about $K$ beyond its cardinality. That is the source of every converse in this paper.

### 3.2 Positivity and the completed square

**Lemma 3.2 (Cost floor).** *For all real $\theta$, $D(\theta) \ge 3/4$, with equality iff $\theta = 1/2$. In particular $D(\theta) > 0$ always.*

*Proof.* $D(\theta) - \tfrac34 = \theta^2 - \theta + \tfrac14 = (\theta - \tfrac12)^2 \ge 0$, and a square vanishes iff its base does. $\square$

Also $D(0) = D(1) = 1$ and $D(1/2) = 3/4$.

### 3.3 The cap

**Theorem 3.3 (Universal cap).** *For every $\theta$,*
$$S(\theta) \;\le\; \frac43,$$
*with equality if and only if $\theta = 1/2$; and $S(1/2) = 4/3$.*

*Proof.* Immediate from Lemma 3.2 and the fact that $x \mapsto 1/x$ is strictly decreasing on $(0,\infty)$: $D(\theta) \ge 3/4 > 0$ gives $S(\theta) \le 4/3$, and equality in one is equality in the other. $\square$

**Corollary 3.4 (Barrier-$4$ converse, asked form).** *For every $\theta$, $S(\theta) < 2$. No residue dial buys a factor-two speedup in the single-pass scan model.*

*Proof.* $4/3 < 2$. $\square$

**Proposition 3.5 (Trivial filters).** *$S(0) = S(1) = 1$: keeping nothing and keeping everything both buy exactly nothing.*

**Proposition 3.6 (Nontrivial filters help).** *If $0 < \theta < 1$ then $S(\theta) > 1$.*

*Proof.* $1 - D(\theta) = \theta - \theta^2 = \theta(1-\theta) > 0$, so $D(\theta) < 1$ and $S(\theta) > 1$. $\square$

**Theorem 3.7 (Shape of the curve).** *$S$ is strictly increasing on $[0, 1/2]$ and strictly decreasing on $[1/2, 1]$. Consequently $4/3$ is the greatest value attained by $S$ on $[0,1]$, and it is attained at $\theta = 1/2$ alone.*

*Proof.* $D'(\theta) = 2\theta - 1$, negative on $(0,1/2)$ and positive on $(1/2,1)$; $S = 1/D$ with $D > 0$ reverses the sense. The extremal statement then follows from Theorem 3.3 together with $S(1/2) = 4/3$. $\square$

Theorem 3.7 carries a practical warning. Aggressive filters are on the *wrong* side of the hill, not merely suboptimal by a little. A dial of density $10^{-2}$ discards $99\%$ of the class space yet buys $S = 1.0102\ldots$; a dial of density $10^{-6}$ buys $1.000001$. In a single-pass scan the dominant term of the cost is the probability of a *miss*, and a very selective filter misses almost always.

### 3.4 Genuine residue dials

**Definition 3.8.** For $M \ge 1$ and $K \subseteq (\mathbb{Z}/M)^\times$, the density is $\theta_M(K) = |K|/\varphi(M)$.

That $0 \le \theta_M(K) \le 1$ follows from $|K| \le |(\mathbb{Z}/M)^\times| = \varphi(M)$ and $\varphi(M) > 0$.

**Theorem 3.9 (Cap for residue dials).** *For every modulus $M$ and every $K \subseteq (\mathbb{Z}/M)^\times$, $S(\theta_M(K)) \le 4/3$.*

**Theorem 3.10 (Attainment).** *If $\varphi(M)$ is even — in particular for every $M > 2$ — there exists $K \subseteq (\mathbb{Z}/M)^\times$ with $S(\theta_M(K)) = 4/3$; indeed every $K$ with $2|K| = \varphi(M)$ works.*

*Proof.* Write $\varphi(M) = 2m$. Choose any subset $K$ of the unit group with $|K| = m$; such a subset exists since $m \le \varphi(M)$. Then $\theta_M(K) = m/(2m) = 1/2$ and Theorem 3.3 applies. That $\varphi(M)$ is even for $M>2$ is classical. $\square$

**Theorem 3.11 (Exact attainment criterion).** *$S(\theta_M(K)) = 4/3$ if and only if $2|K| = \varphi(M)$.*

*Proof.* By Theorem 3.3, equality holds iff $\theta_M(K) = 1/2$, i.e. $|K|/\varphi(M) = 1/2$, i.e. $2|K| = \varphi(M)$ (clearing denominators is legitimate since $\varphi(M) > 0$). $\square$

---

## 4. Converse statements: structure blindness

### 4.1 The blindness lemma

**Theorem 4.1 (Lemma B2: structure blindness).** *Let $K, L \subseteq (\mathbb{Z}/M)^\times$ with $|K| = |L|$. Then $S(\theta_M(K)) = S(\theta_M(L))$.*

*Proof.* Equal cardinalities give equal densities, and $S$ is a function of the density. $\square$

**Theorem 4.2 (Cross-modulus blindness).** *If $K \subseteq (\mathbb{Z}/M)^\times$ and $L \subseteq (\mathbb{Z}/M')^\times$ have $\theta_M(K) = \theta_{M'}(L)$, their speedups coincide. Neither the modulus, nor its factorisation, nor the arithmetic content of the dial enters the law.*

Trivial as proofs, these statements are strong as *converses*: they assert that an entire design space collapses. Any construction one might attempt — subgroups, cosets, unions of character fibres, sets defined by reciprocity conditions, sets chosen adversarially, sets chosen at random — is worth exactly what its cardinality is worth, and nothing more.

### 4.2 Symbol dials: characters of every order

**Definition 4.3 (Symbol dial).** Let $f : (\mathbb{Z}/M)^\times \to S$ be any *reading* into a finite symbol set (a Dirichlet character, a power-residue symbol of order $r$, or a tuple of several such readings), and let $T \subseteq S$. The associated symbol dial is
$$K_{f,T} = \{ u \in (\mathbb{Z}/M)^\times : f(u) \in T \}.$$

**Theorem 4.4 (No character content helps).** *For every reading $f$ and every symbol subset $T$, $S(\theta_M(K_{f,T})) \le 4/3$.*

**Theorem 4.5 (Fibre mixing is invisible).** *If $|K_{f,T}| = |L|$ for an arbitrary dial $L$, then $S(\theta_M(K_{f,T})) = S(\theta_M(L))$.*

**Theorem 4.6 (Half-density symbol dials attain the cap).** *If $2|K_{f,T}| = \varphi(M)$, then $S(\theta_M(K_{f,T})) = 4/3$ exactly, for any $f$ and any $T$.*

The cases $r = 3$ (cubic reading, three symbols) and $r = 5$ (quintic reading, five symbols) are the ones for which nontrivial behaviour was conjectured: one hopes that an unbalanced union of character fibres, exploiting the arithmetic of the fibres themselves, might outperform a structureless half-density set. Theorems 4.4–4.6 say that it cannot. The $n = 3$ and $n = 5$ caps are also $4/3$, attained at *any* half-density subset. Whatever information the higher symbols encode about the target, the single-pass scan model compresses it into one integer before the cost function ever sees it.

### 4.3 Positional and interval witnesses

The blindness runs further than congruences.

**Theorem 4.7 (Positional dials).** *Let $\alpha$ be any finite class space with $n > 0$ elements and $K \subseteq \alpha$ arbitrary — positional, interval, congruence, or mixed. Then the realised speedup $n/\mathrm{EC}(K)$ is at most $4/3$.*

*Proof.* Theorem 3.1 identifies $n/\mathrm{EC}(K)$ with $S(|K|/n)$; apply Theorem 3.3. $\square$

**Corollary 4.8 (Interval dials).** *Let $\alpha = \{0,1,\ldots,n-1\}$ be the scan positions and let $K = \{i : a \le i < b\}$ be an interval dial. Then its speedup is at most $4/3$.*

This closes the framing question for witnesses that are not residue classes. Positional and interval tests — filters that constrain *where in the scan* the target lies — have historically been treated as a separate family. In the worst-case-in-phase accounting they are not: they are dials, and they obey the same law.

### 4.4 Corollary A2: which-factor blindness as an identity

Let $N = pq$ with $N \equiv c \pmod M$, $c$ a unit. If $u$ is the class of $p$ and $v$ the class of $q$, then $uv = c$.

**Definition 4.9 (Factor swap).** For a unit $c$, define $\sigma_c : (\mathbb{Z}/M)^\times \to (\mathbb{Z}/M)^\times$ by $\sigma_c(u) = c u^{-1}$.

**Lemma 4.10.** *$\sigma_c$ is an involution, hence a bijection; and if $uv = c$ then $\sigma_c(u) = v$.*

*Proof.* $\sigma_c(\sigma_c(u)) = c (cu^{-1})^{-1} = c c^{-1} u = u$. If $uv = c$ then $cu^{-1} = uvu^{-1} = v$ by commutativity. $\square$

**Theorem 4.11 (Which-factor blindness).** *For every unit $c$ and every dial $K \subseteq (\mathbb{Z}/M)^\times$,*
$$\theta_M(\sigma_c(K)) = \theta_M(K), \qquad\text{hence}\qquad S(\theta_M(\sigma_c(K))) = S(\theta_M(K)).$$
*Reading a dial against the first factor of a semiprime and reading it against the second give exactly the same speedup.*

*Proof.* $\sigma_c$ is injective, so $|\sigma_c(K)| = |K|$; apply Theorem 4.1. $\square$

The point is the word *exactly*. This phenomenon had been reported as an empirical near-coincidence in factor-side simulations; it is in fact an identity, valid for every $M$, every $c$, and every $K$, and it reduces to the observation that a bijection preserves cardinality.

---

## 5. Batteries: CRT composition and the bit-currency separation

### 5.1 Composition

**Definition 5.1 (CRT battery).** Let $m, n$ be coprime. The Chinese Remainder Theorem gives an isomorphism of unit groups
$$\chi : (\mathbb{Z}/mn)^\times \;\xrightarrow{\ \sim\ }\; (\mathbb{Z}/m)^\times \times (\mathbb{Z}/n)^\times.$$
Given dials $K_1$ on $m$ and $K_2$ on $n$, their *composition* is $K_1 \otimes K_2 = \chi^{-1}(K_1 \times K_2)$.

**Lemma 5.2 (Composition is logical AND).** *$u \in K_1 \otimes K_2$ if and only if the first CRT component of $u$ lies in $K_1$ and the second lies in $K_2$. Consequently $|K_1 \otimes K_2| = |K_1|\,|K_2|$.*

**Theorem 5.3 (Densities multiply).** *$\theta_{mn}(K_1 \otimes K_2) = \theta_m(K_1)\,\theta_n(K_2)$.*

*Proof.* Combine Lemma 5.2 with the multiplicativity $\varphi(mn) = \varphi(m)\varphi(n)$ for coprime $m,n$. $\square$

**Theorem 5.4 (Battery cap).** *$S(\theta_{mn}(K_1 \otimes K_2)) \le 4/3$, and $< 2$.*

Iterating, define the density of a battery $\{\theta_i\}$ of dials on pairwise coprime moduli as $\Theta = \prod_i \theta_i$.

**Theorem 5.5 (Batteries compose for free).** *For every finite list of densities $\theta_i \in [0,1]$, the composite density satisfies $0 \le \Theta \le 1$, and $S(\Theta) \le 4/3 < 2$. Moreover adding a dial can only decrease the composite density: $\Theta' = \theta\Theta \le \Theta$ for $\theta \le 1$.*

*Proof.* The bounds on $\Theta$ are an induction on the list, using $0 \le ab \le 1$ for $a,b \in [0,1]$. The cap is Theorem 3.3 applied at $\Theta$. $\square$

"For free" is deliberately double-edged. Composition costs nothing structurally — the CRT does the bookkeeping — and it *buys* nothing beyond what a single dial buys. Worse, by the monotonicity of Theorem 3.7, each additional dial pushes $\Theta$ down toward $0$, i.e. down the far side of the hill toward speedup $1$.

### 5.2 Two currencies

**Definition 5.6.** For a dial of density $\theta \in (0,1]$:
$$\mathrm{Cap}(\theta) = -\log_2 \theta \ \ \text{(capacity bits)}, \qquad \mathrm{Work}(\theta) = \log_2 S(\theta) \ \ \text{(work bits)}.$$

Capacity is the information the reading conveys about the target's class; work is the logarithm of the realised acceleration, i.e. the number of binary halvings of the running time actually achieved.

**Lemma 5.7.** *A battery of $n$ half-density dials has composite density $2^{-n}$ and capacity exactly $n$ bits.*

*Proof.* $\mathrm{Cap}(2^{-n}) = -\log_2 2^{-n} = n$. $\square$

**Theorem 5.8 (Capacity is unbounded).** *For every $B$ there is $n$ with $\mathrm{Cap}(2^{-n}) \ge B$.*

**Theorem 5.9 (Work is capped).** *For every $\theta$, $\mathrm{Work}(\theta) \le \log_2(4/3) = 0.415037\ldots < 1$.*

*Proof.* $S(\theta) > 0$ and $S(\theta) \le 4/3$; $\log_2$ is increasing; $\log_2(4/3) < \log_2 2 = 1$. $\square$

**Theorem 5.10 (Bit-currency separation).** *For every capacity budget $B$ there exists a battery with at least $B$ capacity bits whose work bits are at most $\log_2(4/3) < 1$.*

**Theorem 5.11 (Vanishing exchange rate).** *As $n \to \infty$, $\mathrm{Work}(2^{-n}) \to 0$.*

*Proof.* $2^{-n} \to 0$; $S$ is continuous everywhere (its denominator $D$ never vanishes, Lemma 3.2); $S(0) = 1$; hence $S(2^{-n}) \to 1$ and $\log_2 S(2^{-n}) \to \log_2 1 = 0$. $\square$

This is the sharpest statement of the paper's economic content. A battery of composed residue dials whose measured capacity is, say, $12.7235$ bits purchases at most $\log_2(4/3) = 0.41504$ work bits — a conversion rate below $3.3\%$ — and the rate degrades to zero as the battery grows. **Capacity bits and work bits are different currencies.** The temptation to read an information-theoretic accumulation as an algorithmic gain is precisely the error the cap forbids.

---

## 6. The accounting analysis: where the $2$ lives

Everything above uses *worst-case-in-phase* accounting: a phase that scans $m$ classes is charged $m$. The literature's barrier of $2$ belongs to a different, more generous accounting, and this section isolates the difference exactly.

### 6.1 Expected-position accounting

Charge the algorithm the *position* at which the target is found, and allow it to order classes freely inside each branch of the dial reading. A blind scan of $n$ classes then costs $(n+1)/2$ on average. A dial-aware algorithm sees the reading first, and so may use one order for the kept block (size $k$) and another for the rejected block (size $j = n - k$).

**Definition 6.1 (Schedule).** A *schedule* is a pair of maps $\pi_{\mathrm{in}} : K \to \mathbb{Z}_{\ge 1}$ and $\pi_{\mathrm{out}} : \alpha \setminus K \to \mathbb{Z}_{\ge 1}$, each injective on its domain. The total cost is
$$\mathrm{Tot} = \sum_{t \in K} \pi_{\mathrm{in}}(t) + \sum_{t \notin K} \pi_{\mathrm{out}}(t).$$

### 6.2 The optimality lemma

**Lemma 6.2 (Triangular lower bound).** *Let $S$ be a finite set of size $m$ and $p : S \to \mathbb{Z}$ injective with $p(t) \ge 1$ for all $t$. Then*
$$\sum_{t \in S} p(t) \;\ge\; \frac{m(m+1)}{2}.$$

*Proof.* The image $p(S)$ is a set of $m$ distinct integers, each at least $1$. Any such set has sum at least $1 + 2 + \cdots + m = m(m+1)/2$: order the image increasingly as $x_1 < x_2 < \cdots < x_m$; then $x_i \ge i$ by induction ($x_1 \ge 1$, and $x_{i+1} > x_i \ge i$ forces $x_{i+1} \ge i+1$). Injectivity transports the sum over $S$ to the sum over the image. $\square$

**Theorem 6.3 (Schedule optimality).** *For every schedule,*
$$\mathrm{Tot} \;\ge\; \frac{k(k+1)}{2} + \frac{j(j+1)}{2}.$$

*Proof.* Split $\mathrm{Tot}$ into the two branch sums and apply Lemma 6.2 to each. $\square$

Theorem 6.3 is the load-bearing statement of this section: it converts the value of one particular strategy into an upper bound over *all* dial-aware strategies. No cleverness of ordering, within either branch, can do better than the triangular sums.

### 6.3 The barrier

**Definition 6.4.** For block sizes $k, j$ with $k + j > 0$,
$$A(k,j) \;=\; \frac{(k+j)(k+j+1)}{k(k+1) + j(j+1)}.$$

The numerator is twice the baseline expected cost $\tfrac{n+1}{2}$ times $n$; the denominator is twice the optimal total; so $A(k,j)$ is the ratio of the blind expected cost to the best achievable dial-aware expected cost.

**Theorem 6.5 (Realised speedup is bounded by $A$).** *For every schedule, the realised speedup*
$$\frac{n(n+1)}{2\,\mathrm{Tot}} \;\le\; A(k,j).$$

*Proof.* Theorem 6.3 bounds $\mathrm{Tot}$ from below by $\tfrac12(k(k+1)+j(j+1))$; the denominator of the left side is therefore at least the denominator of $A$, and $n = k+j$ identifies the numerators. $\square$

**Theorem 6.6 (Strict barrier $2$).** *For all $k, j$ with $k + j > 0$, $A(k,j) < 2$.*

*Proof.* Clearing the positive denominator, the claim is
$$(k+j)(k+j+1) < 2\bigl(k(k+1) + j(j+1)\bigr),$$
i.e. $k^2 + 2kj + j^2 + k + j < 2k^2 + 2j^2 + 2k + 2j$, i.e. $0 < (k-j)^2 + k + j$. Since $k+j > 0$, this holds. $\square$

**Theorem 6.7 (Sharpness at balanced blocks).** *For $m \ge 1$, $A(m,m) = \dfrac{2m+1}{m+1} = 2 - \dfrac{1}{m+1}$, and $A(m,m) \to 2$ as $m \to \infty$.*

*Proof.* $A(m,m) = 2m(2m+1)/(2m(m+1)) = (2m+1)/(m+1)$; the limit is immediate from the displayed rewriting. $\square$

**Theorem 6.8 (The accounting gap is real).** *For every $\varepsilon > 0$: (i) every dial has worst-case-in-phase speedup $\le 4/3$; (ii) $4/3 < 2$; (iii) some balanced dial has expected-position speedup strictly between $2 - \varepsilon$ and $2$.*

*Proof.* (i) is Theorem 3.3, (ii) is arithmetic, and (iii) follows from Theorem 6.7 by choosing $m$ with $1/(m+1) < \varepsilon$, together with Theorem 6.6. $\square$

**Remark 6.9 (On reporting the right constant).** The two accountings answer different questions and give different constants. In the worst-case-in-phase framing the *provable* universal constant is $4/3$; reporting the familiar "$\le 2$" there would be true but strictly weaker, and reporting "$= 2$" would be false. The number $2$ is the supremum of the expected-position accounting, approached and never attained. Precision about which accounting is in force is not pedantry here — it is the entire difference between the two headline constants.

---

## 7. Multi-symbol dials and the boundary of the theorem

### 7.1 The prefix cost

**Definition 7.1.** An *$r$-symbol dial* partitions the class space into blocks of densities $\theta_1, \ldots, \theta_r \ge 0$ with $\sum_i \theta_i = 1$, scanned in the given order. A target in block $i$ costs the total density of blocks $1$ through $i$, so the normalised expected cost is
$$C(\theta) \;=\; \sum_{i=1}^{r} \theta_i \sum_{j \le i} \theta_j, \qquad \mathrm{MultiSpeedup}(\theta) = \frac{1}{C(\theta)}.$$

### 7.2 Order-freeness

**Theorem 7.2 (Order-free identity).**
$$2\,C(\theta) \;=\; \Bigl(\sum_{i} \theta_i\Bigr)^{2} + \sum_{i} \theta_i^{2}.$$

*Proof.* Write $C(\theta) = \sum_{i,j} [\,j \le i\,]\,\theta_i\theta_j$. Swapping names in the double sum shows $C(\theta) = \sum_{i,j} [\,i \le j\,]\,\theta_i\theta_j$ as well. Adding the two expressions, and using for each pair $(i,j)$ the pointwise identity
$$[\,j\le i\,]\theta_i\theta_j + [\,i \le j\,]\theta_i\theta_j = \theta_i\theta_j + [\,i = j\,]\theta_i\theta_j$$
(check the three cases $i<j$, $i=j$, $i>j$), we obtain $2C(\theta) = \sum_{i,j}\theta_i\theta_j + \sum_i \theta_i^2$, which is the claim. $\square$

**Corollary 7.3 (No scan order is better than another).** *$C(\theta \circ \sigma) = C(\theta)$ for every permutation $\sigma$ of the blocks.*

*Proof.* The right side of Theorem 7.2 depends only on $\sum_i \theta_i$ and $\sum_i \theta_i^2$, both permutation-invariant. $\square$

This is worth stating loudly because it contradicts a natural heuristic. One expects a rearrangement inequality to reward scheduling the densest block first. It does not: in this cost model the schedule is irrelevant, and any effort spent optimising the block order is wasted.

**Corollary 7.4.** *If $\sum_i \theta_i = 1$ then $C(\theta) = \tfrac12\bigl(1 + \sum_i \theta_i^2\bigr)$.*

### 7.3 The cap hierarchy

**Theorem 7.5 (Cost floor for $r$ blocks).** *If $r \ge 1$ and $\sum_i \theta_i = 1$ then $C(\theta) \ge \dfrac{r+1}{2r}$.*

*Proof.* Cauchy–Schwarz gives $1 = (\sum_i \theta_i)^2 \le r \sum_i \theta_i^2$, so $\sum_i \theta_i^2 \ge 1/r$. Insert into Corollary 7.4. $\square$

**Theorem 7.6 (Cap hierarchy).** *An $r$-symbol single-pass dial satisfies*
$$\mathrm{MultiSpeedup}(\theta) \;\le\; \frac{2r}{r+1},$$
*with equality at uniform blocks $\theta_i = 1/r$.*

*Proof.* The bound is the reciprocal of Theorem 7.5. At $\theta_i = 1/r$, $\sum_i \theta_i^2 = 1/r$, so $C = (1 + 1/r)/2 = (r+1)/(2r)$ and the reciprocal is exactly $2r/(r+1)$. $\square$

**Proposition 7.7 (Consistency with the binary case).** *For $r = 2$ with blocks $(t, 1-t)$, $C = D(t) = 1 - t + t^2$, and the cap $2\cdot 2/(2+1) = 4/3$ recovers Theorem 3.3.*

**Theorem 7.8 (The hierarchy is strictly below $2$ and converges to it).** *For every $r \ge 1$, $\dfrac{2r}{r+1} < 2$; and $\dfrac{2r}{r+1} = 2 - \dfrac{2}{r+1} \to 2$ as $r \to \infty$.*

The hierarchy reads $4/3,\ 3/2,\ 8/5,\ 5/3,\ 12/7, \ldots$. Once again the folklore's $2$ appears as a supremum and the value of nothing.

### 7.4 The boundary: skipping breaks the cap

**Definition 7.9 (Full reveal).** Suppose the dial's answer *names* the target's block and the algorithm may then scan that block alone, skipping the rest. Its normalised cost is
$$R(\theta) \;=\; \sum_i \theta_i^{2}.$$

**Proposition 7.10.** *If $\theta_i \ge 0$ and $\sum_i \theta_i = 1$ then $R(\theta) \le C(\theta)$: full reveal is never worse than a single-pass scan.*

*Proof.* $\sum_i \theta_i^2 \le (\sum_i \theta_i)^2 = 1$, and $C(\theta) = (1 + \sum_i \theta_i^2)/2 \ge \sum_i \theta_i^2$ is equivalent to $\sum_i\theta_i^2 \le 1$. $\square$

**Theorem 7.11 (No cap under skipping).** *A balanced $r$-symbol full reveal buys exactly $r$: $1/R = r$ for $\theta_i = 1/r$. In particular the binary full reveal buys exactly $2$.*

*Proof.* $R = r \cdot (1/r)^2 = 1/r$. $\square$

Theorem 7.11 is the precise boundary of the converse. The constant $4/3$ is not a statement about congruence information as such; it is a statement about *scan-order algorithms*, in which the dial reorders work but cannot elide it. Grant the algorithm the power to skip, and the speedup is $r$, unbounded in $r$. The binary case of the reveal model gives exactly $2$ — which is, at last, the genuine origin of the barrier the literature asks about.

---

## 8. Numerical corroboration

The analytic statements above were checked numerically before and after they were proved; we record the experiments for reproducibility.

- **Monte Carlo of the law.** Sampling uniform targets against random filters over a range of moduli, with $1{,}065{,}538$ samples in total, the maximum deviation of the empirical normalised cost from $1 - \theta + \theta^2$ was $2.94 \times 10^{-4}$, with a $\chi^2$ goodness-of-fit $z$-score of $-1.67$ — comfortably consistent with the exact law.
- **Exhaustive enumeration, single dials.** For $m = 3, 4, 7, 11$, every subset of the unit group was enumerated and the realised speedup computed. Every maximum equalled $1.3333333333$ to the printed precision, attained precisely at the half-density subsets.
- **Exhaustive enumeration, batteries.** For product moduli $M = 12, 15, 21, 33$, all $2^{20}$ subset pairs in the CRT decomposition were enumerated. Again every maximum equalled $1.3333333333$: composition never exceeded the single-dial cap.
- **Semiprime simulations.** Simulated scans against genuine semiprimes agreed with the law within $\pm 0.006$, including structure-blindness controls in which dials of equal size but wildly different arithmetic structure (subgroups, cosets, random scatters, character fibres) were compared and found indistinguishable.
- **Adversarial search.** A deliberate attempt to beat the cap, sweeping the top-$40$ most promising filter families under the same accounting, produced nothing approaching $2\times$; the best observed value was the predicted $4/3$.

The numerics play no logical role — the theorems are proved unconditionally — but they were decisive in catching modelling errors, of which the most consequential was the accounting confusion resolved in §6.

---

## 9. Discussion

### 9.1 What the cap does and does not say

The theorem is a converse for the *congruence stratum*: every residue dial, every symbol dial of every order, every positional or interval dial, and every CRT battery is capped at $4/3$ under worst-case-in-phase accounting. It is not a statement about factoring in general, and it does not touch algorithms that use congruence information in ways other than reordering a scan — factor-base construction, lattice sieving with genuine elimination, or any method that discards candidates rather than deferring them.

What it does say, forcefully, is that the *reordering channel* is exhausted at $4/3$. If a proposed accelerant works by scheduling likely classes earlier, its ceiling is known, small, and independent of how deep the number theory behind the scheduling is.

### 9.2 A profitability threshold

The absolute saving of a density-$\theta$ dial, in classes not scanned, is
$$n - n D(\theta) = n(\theta - \theta^2) \;\le\; \frac{n}{4},$$
maximised at $\theta = 1/2$. Charging $c$ per dial reading turns the cap into a hard budget line:

> **A filter whose reading costs more than a quarter of a full scan can never pay for itself, whatever its density.**

Because the saving is an exact expression rather than an estimate, this threshold is effective, not asymptotic.

### 9.3 Residual gap to a full converse

Three items separate the present theorem from a fully general converse.

1. **Positional and interval witnesses.** Corollary 4.8 covers these within the same accounting; what remains is witnesses whose cost is not uniform across positions.
2. **Superconstant-cost tests.** Factor-local methods that spend more than $O(1)$ per candidate escape the scan-order framing altogether; the cap does not constrain them.
3. **Effectivisation at cryptographic sizes.** The uniformity assumption on the target class enters at exactly one place — a single summation — and quantifying its failure for genuine semiprime factor distributions at cryptographic scale is a concrete, and we believe tractable, task (see §10.3).

---

## 10. Future directions

### 10.1 Where exactly does skipping become available?

The $4/3$ cap holds for single-pass scans and fails, with an $r$-fold speedup, for full reveals. Real sieving sits between: one can skip a class only after paying to recognise it. The cap should therefore be a function of the *skip budget*, giving a one-parameter family interpolating $4/3$ and $r$, indexed by the fraction of rejected classes the algorithm may skip for free. Both endpoints now live in one framework, so the interpolant is a single definition away.

### 10.2 Cost-charged filters and the zero-profit threshold

Reading a dial is charged nothing above. Charging $c$ per reading converts the cap into the profitability threshold of §9.2: no filter whose reading costs more than a quarter of a full scan can pay for itself. Because the saving $n(\theta-\theta^2)$ is exact, the threshold can be made numerically precise for concrete filter families.

### 10.3 Discrepancy-perturbed law

The exact law assumes a uniform target class. A total-variation bound $\Delta$ on the deviation from uniformity should perturb the cost by $O(\Delta)$ and nothing else, since uniformity enters at exactly one summation. This makes the perturbation linear and effective at cryptographic sizes.

### 10.4 Adaptive batteries

The batteries treated here are non-adaptive: all readings are taken before scanning begins. Adaptivity changes the *schedule* but not the partition of the class space, and the optimality lemma (Theorem 6.3) is already stated for arbitrary schedules — so the adaptive case should be reachable without new machinery.

### 10.5 Non-uniform per-class costs

Throughout, examining a class costs one unit. Weighting classes by genuine trial-division cost turns the triangular lower bound of Lemma 6.2 into a rearrangement problem with a nontrivial optimum, and Corollary 7.3's order-freeness would be expected to fail. Identifying the weighted analogue of $4/3$ is open.

---

## 11. Conclusion

The empirical converse curve for residue-dial speedups is now a theorem for the entire congruence stratum. The law
$$\mathrm{Speedup}(\theta) = \frac{1}{1 - \theta + \theta^2}$$
is exact, structure-blind, modulus-blind, character-blind, factor-blind and composition-blind; its universal cap is $4/3$, attained exactly at half density and at no other; trivial filters buy exactly $1$; CRT batteries inherit the cap, so that unbounded capacity bits purchase at most $\log_2(4/3) = 0.41504$ work bits and asymptotically none. The number $2$ that the folklore remembers is real but belongs elsewhere: it is the strict, unattained supremum of expected-position accounting, the limit of the multi-symbol hierarchy $2r/(r+1)$, and the exact value of a binary *full reveal* — the model in which the algorithm may skip what the dial rejects. Between "reorder the work" and "skip the work" lies the whole distance from $4/3$ to $2$.
