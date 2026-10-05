# Position Pays: The Balance Law $1/(\sqrt r-1)$ for Sqrt-Descending Trial Division and the Stratum Beyond the Residue Cap

**Aristotle**

*October 2026*

---

## Abstract

We study how much the **order** in which trial divisors are visited affects the cost of trial division on semiprimes $N = pq$ with primes $p \le q$. Costs are counted as expected numbers of divisibility tests. The pool of candidates is fixed at $\{2,\dots,\lfloor\sqrt N\rfloor\}$, and only the visitation order changes.

For the ascending order and for the *sqrt-descending* order, which is Fermat's order applied to divisibility tests, we prove exact costs $p-1$ and $\lfloor\sqrt N\rfloor+1-p$. These sum to $\lfloor\sqrt N\rfloor$. We prove that the crossover between the two orders is a sharp wall at $q = 4p$, and that near-squares are cheap: $2(\mathrm{desc}-1) \le q-p$. Dropping the floor, the per-instance speedup depends on the balance ratio $r = q/p$ alone and equals $S(r) = 1/(\sqrt r - 1)$. This function is strictly decreasing and unbounded as $r\to1^+$, and it exceeds a threshold $k$ exactly on the window $1<r<(1+1/k)^2$.

Set against the theorem that no residue-class filter improves expected cost by more than $4/3$, the law gives a **barrier map**. On $1<r<49/16$ the positional speedup strictly exceeds that of every residue filter, for every modulus. At $r=49/16$ it equals $4/3$ exactly, and beyond it never exceeds $4/3$.

We explain why the two results do not conflict with a **separation theorem**: some visitation order strictly beats a cyclic-shift sham control if and only if the target's marginal over candidates is non-uniform. We also show that Fermat's order is the Bayes-optimal order for every prior increasing towards $\sqrt N$.

These results account for a sham-controlled experiment that measured a $5.19\times$ expected speedup, against $1.65\times$ for the sham. The experiment split this into two mechanisms with opposite gradients across balance strata. We prove that the two mechanisms are orthogonal: range truncation at a lower bound $L$ saves exactly $L-2$ ascending tests and no descending tests. We also prove pointwise bands for the strata $q/p\in(1,5/4]$, $[5/4,2]$ and $[2,4]$, namely $[4+2\sqrt5,\infty)$, $[1+\sqrt2,4+2\sqrt5]$ and $[1,1+\sqrt2]$, which by the mediant principle carry over to ratios of expected costs. The measured stratum speedups $20.67$, $4.74$ and $1.97$ lie inside these bands.

---

## 1. Introduction

Trial division is the baseline of integer factorisation. To factor a composite $N$, test candidate divisors $d \le \sqrt N$ until one divides. For a semiprime $N=pq$ with $p\le q$, the pool $\{2,\dots,\lfloor\sqrt N\rfloor\}$ contains exactly one divisor, the prime $p$. Every test spent before reaching $p$ is pure overhead.

There are two classical ways to reduce that overhead.

1. **Filter by residue.** Skip even candidates, keep only candidates coprime to $6$ or $30$, and so on. These *residue dials* discard a fixed fraction of the pool. A previously established theorem, the *residue cap*, shows that no residue dial, whatever its modulus and choice of retained classes, improves the expected number of tests by more than a factor $4/3$. The reason is that the residue of the hidden prime is uniformly distributed over the retained classes, so a residue filter shrinks the pool without moving the target forward in it.

2. **Reorder by position.** Keep the pool and visit it in a different order. Fermat's factorisation method starts at $\sqrt N$ because balanced semiprimes have both factors near $\sqrt N$. We apply that order to divisibility tests: visit $\lfloor\sqrt N\rfloor, \lfloor\sqrt N\rfloor-1, \dots, 2$.

A guess made before measurement held that positional effects, like residue effects, would be capped below $2\times$. A sham-controlled experiment refuted it: the sqrt-descending order gave a $5.19\times$ expected speedup. This paper supplies the mathematics behind that measurement. We give exact costs, a closed-form speedup law, the precise location where the law crosses the residue cap, a structural theorem explaining why position escapes a cap that binds residues, and a decomposition of the measured effect into two provably orthogonal mechanisms.

**Accounting convention.** All costs are numbers of divisibility tests, which measure information. They are not wall-clock times. We make no claim about the asymptotic complexity of factoring. The results concern the relative value of positional and residue information within trial division.

### 1.1 Summary of results

- **Exact costs and complementarity (Theorem 2.3).** For primes $p\le q$, $\mathrm{asc}(pq) = p-1$ and $\mathrm{desc}(pq) = \lfloor\sqrt{pq}\rfloor + 1 - p$, so $\mathrm{asc}+\mathrm{desc} = \lfloor\sqrt{pq}\rfloor$.
- **Balance wall (Theorem 2.4).** If $q<4p$ then $\mathrm{desc}\le\mathrm{asc}+1$. If $q\ge4p$ then $\mathrm{asc}+2\le\mathrm{desc}$.
- **Near-squares are cheap (Theorem 2.5).** $2(\mathrm{desc}-1)\le q-p$. In particular $q\le p+3$ implies $\mathrm{desc}\le2$.
- **Fermat–trial complementarity (Theorem 2.6).** $\mathrm{desc} + \bigl(\tfrac{p+q}{2} - \lfloor\sqrt N\rfloor\bigr) = \tfrac{q-p}{2}+1$.
- **Speedup law (Theorem 3.1).** $p/(\sqrt{pq}-p) = S(q/p)$ with $S(r)=1/(\sqrt r-1)$.
- **Shape of the law (Theorems 3.2–3.4).** Balance windows, strict monotonicity, unboundedness.
- **Barrier map (Theorem 4.2).** Position beats every residue dial on $1<r<49/16$. Equality holds at $49/16$, and position is capped by $4/3$ beyond it.
- **Separation theorem (Theorem 5.5).** A strict positional gain over the sham exists if and only if the marginal is non-uniform.
- **Bayes optimality (Theorems 5.6–5.8).** The rearrangement inequality. Fermat's order is optimal for increasing priors and strictly beats the sham for strictly increasing ones.
- **Orthogonality of mechanisms (Theorem 6.1).** Truncation at $L$ saves $L-2$ ascending tests and $0$ descending tests.
- **Stratum bands and the mediant principle (Theorems 6.3–6.5).** Pointwise bands on the three strata transfer to ratios of expected costs. The measured values lie inside them.

---

## 2. The finite model and exact costs

### 2.1 Pools, orders and cost

**Definition 2.1 (pool, order, cost).** The *standard pool* of $N$ is $\mathcal P(N) = \{2,3,\dots,\lfloor\sqrt N\rfloor\}$. A *visitation order* is given by a key function $\kappa:\mathbb N\to\mathbb N$, and candidates are tested in increasing key order. The *scan cost* of $\kappa$ on a pool $P$ is the number of candidates whose key does not exceed the key of any divisor of $N$ in $P$:
$$\mathrm{cost}_P(\kappa, N) = \#\{\, d\in P : \kappa(d)\le\kappa(e)\ \text{for every}\ e\in P\ \text{with}\ e\mid N \,\}.$$
In words, it counts every candidate visited no later than the first hit. If $P$ contains no divisor, the whole pool is paid for. The *ascending* order is $\kappa(d)=d$, with cost $\mathrm{asc}(N)$. The *sqrt-descending* order is $\kappa(d) = N-d$, with cost $\mathrm{desc}(N)$, and it visits the largest candidates first.

**Lemma 2.2 (unique hit).** Let $p\le q$ be primes. The only divisor of $pq$ in $\mathcal P(pq)$ is $p$, and $p\in\mathcal P(pq)$.

*Proof.* From $p\le q$ we get $p^2\le pq$, so $p\le\lfloor\sqrt{pq}\rfloor$. Since $p\ge2$, $p$ lies in the pool. A divisor $d\ge2$ of $pq$ is one of $p$, $q$ or $pq$. The value $pq$ exceeds $\sqrt{pq}$. If $q$ lay in the pool then $q^2\le pq$, so $q\le p$, hence $q=p$ and the divisor is $p$ anyway. $\square$

### 2.2 Exact costs

**Theorem 2.3 (exact costs; complementarity).** For primes $p\le q$ and $N = pq$,
$$\mathrm{asc}(N) = p-1,\qquad \mathrm{desc}(N) = \lfloor\sqrt N\rfloor+1-p,\qquad \mathrm{asc}(N)+\mathrm{desc}(N) = \lfloor\sqrt N\rfloor.$$

*Proof.* By Lemma 2.2 the cost of any order is the number of pool elements whose key is at most the key of $p$. For the ascending key these are $\{2,\dots,p\}$, a set of $p-1$ elements. For the descending key, $N-d\le N-p$ if and only if $d\ge p$, giving $\{p,\dots,\lfloor\sqrt N\rfloor\}$, a set of $\lfloor\sqrt N\rfloor+1-p$ elements. Adding the two counts gives the third identity. $\square$

The two scans split the pool at the hit $p$. Each pays for its own side, and $p$ is counted by both.

**Example.** For $N = 101\cdot103 = 10403$ we have $\lfloor\sqrt N\rfloor = 101$. The ascending scan pays $100$ tests and the descending scan pays $1$.

### 2.3 The balance wall

**Theorem 2.4 (balance wall at $4$).** Let $p\le q$ be primes.
1. If $q<4p$, then $\mathrm{desc}(pq)\le\mathrm{asc}(pq)+1$.
2. If $q\ge4p$, then $\mathrm{asc}(pq)+2\le\mathrm{desc}(pq)$.

*Proof.* (1) $pq<4p^2=(2p)^2$ gives $\lfloor\sqrt{pq}\rfloor<2p$, that is $\lfloor\sqrt{pq}\rfloor\le 2p-1$. So $\mathrm{desc} = \lfloor\sqrt{pq}\rfloor+1-p\le p = \mathrm{asc}+1$. (2) $pq\ge4p^2$ gives $\lfloor\sqrt{pq}\rfloor\ge2p$. So $\mathrm{desc}\ge p+1 = \mathrm{asc}+2$. $\square$

### 2.4 Near-squares

**Theorem 2.5 (gap bound).** For primes $p\le q$, $2(\mathrm{desc}(pq)-1)\le q-p$. Consequently, if $q\le p+3$ then $\mathrm{desc}(pq)\le2$.

*Proof.* AM–GM in floor form gives $2\lfloor\sqrt{pq}\rfloor\le p+q$. To see this, if $2s>p+q$ with $s=\lfloor\sqrt{pq}\rfloor$, then $4pq \ge 4s^2>(p+q)^2$, which contradicts $(p-q)^2\ge0$. Hence $2(\lfloor\sqrt{pq}\rfloor - p)\le q-p$, and $\mathrm{desc}-1 = \lfloor\sqrt{pq}\rfloor-p$. When $q-p\le3$, integrality forces $\mathrm{desc}-1\le1$. $\square$

So a twin-type semiprime is found in at most two tests by the descending scan, however large it is, while the ascending scan pays $p-1$.

### 2.5 Fermat's method and trial division share the work

For odd primes $p\le q$ put $a = (p+q)/2$ and $b=(q-p)/2$, so that $N=a^2-b^2$. Fermat's method walks $x = \lceil\sqrt N\rceil,\lceil\sqrt N\rceil+1,\dots$ upward until $x^2-N$ is a square, and succeeds at $x=a$. Measured from $\lfloor\sqrt N\rfloor$, it takes $a-\lfloor\sqrt N\rfloor$ steps.

**Theorem 2.6 (Fermat–trial complementarity).** For primes $p\le q$,
$$\mathrm{desc}(pq) + \Bigl(\Bigl\lfloor\tfrac{p+q}{2}\Bigr\rfloor - \lfloor\sqrt{pq}\rfloor\Bigr) = \Bigl\lfloor\tfrac{q-p}{2}\Bigr\rfloor + 1.$$

*Proof.* Substitute $\mathrm{desc} = \lfloor\sqrt{pq}\rfloor+1-p$. The square roots cancel, using $p\le\lfloor\sqrt{pq}\rfloor\le(p+q)/2$ from Lemma 2.2 and the AM–GM step above, which keeps truncated subtraction exact. What remains is $\lfloor(p+q)/2\rfloor - p + 1 = \lfloor(q-p)/2\rfloor+1$. $\square$

The descending trial scan walks $\lfloor\sqrt N\rfloor\downarrow p$ and Fermat walks $\lfloor\sqrt N\rfloor\uparrow a$. Together they cover $[p,a]$ exactly once. The two classical methods are the two halves of one walk outward from the square root.

---

## 3. The speedup law

Removing the floor, the ascending cost is $p$ (up to $O(1)$) and the descending cost is $\sqrt{pq}-p$.

**Definition 3.0.** For $r>1$, the *positional speedup* is $S(r) = \dfrac{1}{\sqrt r-1}$.

**Theorem 3.1 (the law).** For real $0<p<q$,
$$\frac{p}{\sqrt{pq}-p} = S(q/p).$$

*Proof.* $\sqrt{pq} = \sqrt{p^2\cdot(q/p)} = p\sqrt{q/p}$, so $\sqrt{pq}-p = p(\sqrt{q/p}-1)$, which is nonzero since $q/p>1$. Cancel $p$. $\square$

The positional speedup therefore depends only on the balance ratio. This is why mechanism (a) in Section 6 is a pure function of $q/p$.

**Theorem 3.2 (balance windows).** For $r>1$ and $k>0$,
$$k<S(r)\iff r<\left(1+\tfrac1k\right)^2,\qquad k\le S(r)\iff r\le\left(1+\tfrac1k\right)^2.$$

*Proof.* Since $\sqrt r-1>0$, $k<1/(\sqrt r-1)$ is equivalent to $k\sqrt r<k+1$, that is $\sqrt r<1+1/k$. Both sides are positive, so this is equivalent to $r<(1+1/k)^2$. The non-strict case is identical. $\square$

| threshold $k$ | window $r<(1+1/k)^2$ |
|---|---|
| $4/3$ (residue cap) | $49/16 = 3.0625$ |
| $2$ | $2.25$ |
| $5.19$ | $\approx1.4225$ |
| $10$ | $1.21$ |
| $20.67$ | $\approx1.0991$ |

**Theorem 3.3 (monotonicity).** $S$ is strictly decreasing on $(1,\infty)$.

*Proof.* $r\mapsto\sqrt r$ is strictly increasing, so $\sqrt r-1$ is strictly increasing and positive, and its reciprocal is strictly decreasing. $\square$

**Theorem 3.4 (unboundedness).** For every real $k$ there is $r>1$ with $S(r)>k$.

*Proof.* Let $m=\max(k,1)$ and $r=(1+\frac{1}{2m})^2>1$. By Theorem 3.2, $S(r)\ge 2m>k$. $\square$

**Special values.** $S(5/4) = 4+2\sqrt5\approx8.472$, $S(2) = 1+\sqrt2\approx2.414$, $S(49/16)=4/3$ and $S(4)=1$.

*Proof sketch.* $\sqrt{5/4}=\sqrt5/2$, and $1/(\sqrt5/2-1) = 2/(\sqrt5-2) = 2(\sqrt5+2)$. Next, $1/(\sqrt2-1) = \sqrt2+1$. Then $\sqrt{49/16}=7/4$ gives $1/(3/4)=4/3$, and $\sqrt4=2$ gives $1$. $\square$

---

## 4. The barrier map

**Definition 4.1 (residue dial).** Fix a modulus $M\ge1$ and a set $K$ of unit residue classes modulo $M$. The *residue dial* $(M,K)$ tests only the candidates whose residue mod $M$ lies in $K$. Its speedup is the ratio of the expected test count of the unfiltered scan to that of the filtered scan, when the hidden prime's residue is uniformly distributed over the unit classes. The *residue cap* is the established theorem that every residue dial has speedup at most $4/3$, for every $M$ and every $K$.

**Theorem 4.2 (barrier map).**
1. For every $r$ with $1<r<49/16$, every modulus $M$ and every set $K$ of unit classes, the speedup of the residue dial $(M,K)$ is strictly less than $S(r)$.
2. $S(49/16) = 4/3$, and $S(r)\le4/3$ for every $r\ge49/16$.

*Proof.* (1) By Theorem 3.2 with $k=4/3$, $S(r)>4/3$ if and only if $r<(1+3/4)^2 = 49/16$. Combine this with the residue cap. (2) $\sqrt{49/16}=7/4$ gives $S(49/16)=4/3$. For $r>49/16$, Theorem 3.3 gives $S(r)<S(49/16)$. $\square$

The residue cap and the positional gain are therefore separated by a sharp wall in balance space at $q/p = 49/16$. On the near-square side, positional information is strictly more valuable than any residue information. On the far side, it is not. Section 5 identifies the structural reason.

---

## 5. Why position escapes a cap that binds residues

### 5.1 An abstract model of ordered search

Let there be $n=m+1$ candidates, indexed $0,\dots,m$. The target is candidate $i$ with weight $\mu_i\in\mathbb R$; for probabilities, $\mu_i\ge0$ and $\sum\mu_i=1$, but the algebra holds for any reals. A *visitation order* is a permutation $\sigma$, and candidate $i$ is tested at step $\sigma(i)+1$.

**Definition 5.1 (order cost, sham).**
$$C_\mu(\sigma) = \sum_i \mu_i\,(\sigma(i)+1),\qquad \mathrm{Sham}(\mu) = \Bigl(\sum_i\mu_i\Bigr)\frac{n+1}{2}.$$
For $k\in\mathbb Z/n$, the *cyclic shift* of $\sigma$ by $k$ is $\sigma_k(i) = \sigma(i)+k \bmod n$.

**Lemma 5.2 (uniform-marginal lemma).** If $\mu$ is constant, then $C_\mu(\sigma) = \mathrm{Sham}(\mu)$ for every order $\sigma$.

*Proof.* $\sum_i(\sigma(i)+1) = \sum_{j=0}^{m}(j+1) = n(n+1)/2$ for every permutation. $\square$

**Lemma 5.3 (the cyclic sham).** For every $\mu$ and every $\sigma$,
$$\sum_{k\in\mathbb Z/n} C_\mu(\sigma_k) = n\cdot\mathrm{Sham}(\mu).$$
So the sham is the average of the $n$ cyclic shifts of any real order.

*Proof.* Exchange the sums. For each fixed $i$, as $k$ ranges over $\mathbb Z/n$ the position $\sigma(i)+k$ ranges over all of $\mathbb Z/n$, so $\sum_k(\sigma_k(i)+1) = n(n+1)/2$. $\square$

This justifies the experimental sham control. It is not an artificial baseline but the average cost of genuine orders.

**Lemma 5.4 (discrete derivative).** With $\mathrm{last}=m$,
$$C_\mu(\sigma_{k+1}) - C_\mu(\sigma_k) = \sum_i\mu_i - n\,\mu_{\sigma^{-1}(\mathrm{last}-k)}.$$

*Proof.* Shifting by one more step raises every position by one, except the candidate sitting at position $\mathrm{last}$, which wraps from $m$ to $0$ and so changes by $1-n$. That candidate is $\sigma^{-1}(\mathrm{last}-k)$. $\square$

**Theorem 5.5 (separation theorem).** There is an order $\sigma$ with $C_\mu(\sigma)<\mathrm{Sham}(\mu)$ if and only if $\mu$ is not constant. More precisely, if $\mu$ is not constant then for *every* order $\sigma$ some cyclic shift $\sigma_k$ strictly beats the sham.

*Proof.* If $\mu$ is constant, Lemma 5.2 rules out a strict gain. Conversely, suppose every shift of $\sigma$ costs at least the sham. By Lemma 5.3 the shifts average exactly to the sham. A family of nonnegative excesses that sums to zero is identically zero, so every shift costs exactly the sham. Lemma 5.4 then gives $n\,\mu_{\sigma^{-1}(\mathrm{last}-k)} = \sum_i\mu_i$ for every $k$. As $k$ varies, $\sigma^{-1}(\mathrm{last}-k)$ runs over all candidates, so every $\mu_i$ equals the mean, and $\mu$ is constant. $\square$

**Interpretation.** Residue filters act on a marginal that is uniform over residue classes, which is the regime of Lemma 5.2. That is the source of the $4/3$ cap. A balance-concentrated ensemble of semiprimes induces a marginal over pool *positions* that is strongly skewed towards $\sqrt N$, which is the regime of Theorem 5.5. The residue cap and the measured positional gain sit on opposite sides of this equivalence, so they cannot contradict each other.

### 5.2 The Bayes order and Fermat's order

**Theorem 5.6 (Bayes order is optimal).** If $\sigma$ antivaries with $\mu$, meaning $\sigma(i)<\sigma(j)\Rightarrow\mu_i\ge\mu_j$ so that heavier candidates come first, then $C_\mu(\sigma)\le C_\mu(\tau)$ for every order $\tau$.

*Proof.* This is the rearrangement inequality. Among all pairings of the weights with the positions $1,\dots,n$, the sum of products is smallest when the two sequences are oppositely ordered. $\square$

**Theorem 5.7 (Fermat's order is Bayes for balance priors).** Index the pool from smallest candidate ($0$) to largest ($m$). If $\mu$ is nondecreasing, so that mass piles up towards $\sqrt N$, then the reversal order $\sigma(i)=m-i$, which is the sqrt-descending scan, minimises $C_\mu$. Dually, if $\mu$ is nonincreasing, the ascending scan is optimal.

*Proof.* Under the reversal, $\sigma(i)<\sigma(j)$ means $i>j$, and monotonicity gives $\mu_i\ge\mu_j$. Apply Theorem 5.6. $\square$

**Theorem 5.8 (strict gain).** If $n\ge2$ and $\mu$ is strictly increasing, the sqrt-descending order strictly beats the sham.

*Proof.* $\mu$ is not constant, so by Theorem 5.5 some order beats the sham. By Theorem 5.7 the descending order is at least as good as that order. $\square$

---

## 6. Two mechanisms, opposite gradients

### 6.1 Range truncation is orthogonal to the balance bet

In the experiment every prime is below $B=2^{17}$. Then $q<B$ forces $p = N/q>N/B$, so the magnitude of $N$ alone reveals a lower bound $L\le p$. The *truncated pool* is $\mathcal P_L(N) = \{\max(2,L),\dots,\lfloor\sqrt N\rfloor\}$.

**Theorem 6.1 (orthogonality).** Let $p\le q$ be primes and $2\le L\le p$. Then
$$\mathrm{cost}_{\mathcal P_L}(\text{asc}, pq) = p+1-L = \mathrm{asc}(pq) - (L-2),\qquad \mathrm{cost}_{\mathcal P_L}(\text{desc}, pq) = \mathrm{desc}(pq).$$
Truncation saves exactly $L-2$ ascending tests and no descending tests.

*Proof.* $\mathcal P_L\subseteq\mathcal P$, and it still contains $p$, so $p$ remains the unique hit. The ascending scan now visits $\{L,\dots,p\}$, which has $p+1-L$ elements. The descending scan visits $\{p,\dots,\lfloor\sqrt N\rfloor\}$ as before, because it never went below $p$. $\square$

Mechanism (a), the balance bet, removes work at the *top* of the pool. Mechanism (b), truncation, removes work at the *bottom*. Mechanism (a) is a function of $q/p$ alone (Theorem 3.1). Mechanism (b) depends on how close $q$ sits to the pool ceiling $B$, which is unrelated to balance. The opposite stratum gradients observed in the experiment are therefore structural, not fitted.

### 6.2 Stratum bands

**Theorem 6.2 (pointwise bands).**
- If $1<r\le5/4$, then $S(r)\ge4+2\sqrt5$.
- If $5/4\le r\le2$, then $1+\sqrt2\le S(r)\le4+2\sqrt5$.
- If $2\le r\le4$, then $1\le S(r)\le1+\sqrt2$.

*Proof.* Use monotonicity (Theorem 3.3) and the special values $S(5/4)$, $S(2)$ and $S(4)$. $\square$

An experiment reports ratios of *expected* costs, $\mathbb E[\mathrm{asc}]/\mathbb E[\mathrm{desc}]$, not averages of per-instance ratios. The bands transfer through the following elementary fact.

**Theorem 6.3 (mediant principle).** Let $s$ be a nonempty finite index set and $b_i>0$. If $L\,b_i\le a_i\le U\,b_i$ for every $i\in s$, then
$$L\le\frac{\sum_{i\in s}a_i}{\sum_{i\in s}b_i}\le U.$$

*Proof.* Sum the inequalities and divide by $\sum b_i>0$. $\square$

**Theorem 6.4 (stratum band for expected speedups).** Let $(p_i,q_i)_{i\in s}$ be a finite nonempty sample of positive reals with $r_1p_i\le q_i\le r_2p_i$, where $1<r_1\le r_2$. Then
$$S(r_2)\;\le\;\frac{\sum_i p_i}{\sum_i\bigl(\sqrt{p_iq_i}-p_i\bigr)}\;\le\;S(r_1).$$

*Proof.* Each denominator term is positive because $p_i<\sqrt{p_iq_i}$. By Theorem 3.1, $p_i = S(q_i/p_i)(\sqrt{p_iq_i}-p_i)$. Since $r_1\le q_i/p_i\le r_2$, monotonicity gives $S(r_2)\le S(q_i/p_i)\le S(r_1)$. Apply Theorem 6.3. $\square$

**Theorem 6.5 (consistency of the measurement).** The measured mechanism-(a) stratum speedups satisfy
$$4+2\sqrt5\le20.67,\qquad 1+\sqrt2\le4.74\le4+2\sqrt5,\qquad 1\le1.97\le1+\sqrt2,$$
and $1+\sqrt2>4/3$, so both the near-square and the middle bands clear the residue cap.

*Proof.* $2<\sqrt5<3$ and $1.4<\sqrt2<1.5$. $\square$

---

## 7. The experiment

The measurement that motivated this work was carried out as follows.

- **Ensemble.** Semiprimes $N=pq$ with primes drawn from a finite pool below $2^{17}$. There were $30{,}000$ instances per batch and $5$ batches, with a fixed seed.
- **Cost.** Expected number of divisibility tests until the hidden factor is found.
- **Control.** A sham that applies the same ordering machinery to a uniformly random cyclic shift. By Lemma 5.3 it is the average of real orders.
- **Headline.** The sqrt-descending order gives an expected speedup of **$5.1936\times$** over the ascending scan. The sham gives $1.65\times$, so real/sham $=3.16$. The prior guess that the positional gain would stay below $2\times$ is refuted.
- **Decomposition by stratum** $q/p\in\{[1,1.25],[1.25,2],[2,4]\}$:

| mechanism | $[1,1.25]$ | $[1.25,2]$ | $[2,4]$ |
|---|---|---|---|
| (a) balance bet | $20.67\times$ | $4.74\times$ | $1.97\times$ |
| (b) learned range truncation ($p\ge N/2^{17}$) | $4.35\times$ | $4.73\times$ | $6.91\times$ |

- **Learned ordering.** A learned Bayes ordering scored $3.37\times$ on test data only. This refuted a claim that the smooth posterior collapses to a fixed order at the pool's truncation edge, while a designed degenerate-ordering check still passed $30000/30000$. The learned selector's apparent edge over plain sqrt-descending was inflation from the training data. **The honest computable frontier is plain sqrt-descending.**
- **Ledger.** Seven entries were recorded, including one self-refutation by a learned model and one feature found to be vacuous.

Sections 2–6 explain every structural feature of this table. Mechanism (a) depends on balance alone and decays with imbalance, with stratum values inside the proved bands. Mechanism (b) is orthogonal to (a) and governed by the pool ceiling. The overall gain is possible because the positional marginal is non-uniform, which is exactly the hypothesis that the residue cap lacks.

---

## 8. Algorithms

**Algorithm A (sqrt-descending trial division).**
Input $N$. For $d = \lfloor\sqrt N\rfloor, \lfloor\sqrt N\rfloor-1, \dots, 2$: if $d\mid N$, return $d$. Return "prime".
On a semiprime it uses exactly $\lfloor\sqrt N\rfloor+1-p$ tests (Theorem 2.3) and at most $(q-p)/2+1$ (Theorem 2.5).

**Algorithm B (truncated scans).**
Given a certified lower bound $L\le p$, for example $L=\lceil N/B\rceil$ when all factors are below $B$, scan $\{\max(2,L),\dots,\lfloor\sqrt N\rfloor\}$ in either order. The ascending scan costs $p+1-L$ and the descending scan costs $\lfloor\sqrt N\rfloor+1-p$ (Theorem 6.1).

**Algorithm C (Bayes order).**
Given a prior $\mu$ over pool positions, visit candidates in decreasing $\mu$. This is optimal by Theorem 5.6. For priors increasing towards $\sqrt N$ it coincides with Algorithm A (Theorem 5.7).

**Algorithm D (sham control).**
Draw $k$ uniformly from $\mathbb Z/n$ and visit the pool in the order $\sigma_k$. Its expected cost is $\mathrm{Sham}(\mu)$ for every $\sigma$ (Lemma 5.3).

---

## 9. Discussion

**The barrier map.** Two kinds of side information about a hidden prime factor have now been quantified. *Residue information* is capped at $4/3$, a theorem resting on a uniform marginal. *Positional information* obeys $S(r)=1/(\sqrt r-1)$, which is unbounded at near-squares. The two meet at the wall $r=49/16$. They are separated by exactly the scope of the uniform-marginal lemma, as Theorem 5.5 makes precise.

**Cryptographic reading.** For RSA-type moduli the lesson is the classical one, now with exact constants: closely spaced factors are dangerous. Theorems 2.5 and 2.6 put trial division and Fermat's method on the same footing, as two halves of a walk out from $\sqrt N$, and Theorem 3.2 gives the precise balance window for any target speedup. We stress that these are statements about test counts within trial division, a deliberately simple model. They are not statements about the hardness of factoring properly generated moduli.

**Information, not time.** Every number here counts divisibility tests. Reordering costs nothing per test, so test counts are a faithful proxy for the information content of the order. Wall-clock effects such as memory access and branch prediction lie outside the model.

**Honest frontier.** Theorem 5.6 says the Bayes order is optimal *for the true prior*. A learned prior that is over-fitted to training data can do worse than a simple structured order. That is what the experiment found: $3.37\times$ for the learned order, against $5.19\times$ for plain sqrt-descending.

---

## 10. Future work

1. **Optimal interleaved schedule.** Because the two mechanisms attack opposite ends of the pool (Theorem 6.1), a schedule that alternates descending steps from $\lfloor\sqrt N\rfloor$ with ascending steps from the truncation edge $L$, in a ratio $\lambda:1$, has a min-of-two-walks cost. We conjecture that $\max_\lambda S(\lambda)$ strictly exceeds both pure orders on the experimental ensemble, by at least a factor $1.3$ over $5.19$.
2. **Fermat walk duality.** A two-sided walk from $\lfloor\sqrt N\rfloor$ that stops at the first success of either downward trial division or upward Fermat search costs $\min(\mathrm{desc},\mathrm{fermat})$. By Theorem 2.6 the two costs sum to $(q-p)/2+1$, so this minimum is at most half of that. We conjecture that on $q/p\in[1,1.25]$ the Fermat side wins for all but an $O(1/\sqrt p)$ fraction of instances.
3. **Prime-only pools.** Restricting the pool to primes changes costs from interval lengths to prime-counting differences. The analogue of $S(r)$ should involve $\pi(\sqrt N)-\pi(p)$, and the wall should move accordingly.
4. **Joint residue–position filters.** Since residue information is uniform along positions, combining a residue dial with the descending order should multiply the two speedups. Proving this product law, and that it is optimal, would complete the barrier map.

---

## Appendix: numerical illustration

A synthetic ensemble drawn independently of the experiment (primes below $2^{17}$, $3000$ semiprimes per stratum) gives $\mathbb E[\mathrm{asc}]/\mathbb E[\mathrm{desc}]$ values of $18.70$, $4.20$ and $1.60$ on the three strata. Each lies inside the bands of Theorem 6.2. Brute-force scans on random semiprimes confirm the identities of Theorems 2.3–2.6 and 6.1 in every case tested. Exhaustive enumeration of all $720$ orders on $6$ candidates confirms Lemma 5.2, Lemma 5.3, Theorem 5.5 and Theorem 5.6 for random priors.
